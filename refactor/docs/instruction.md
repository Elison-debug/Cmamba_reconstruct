# Grid-Aware Mamba RF Localization Pipeline  

## Comprehensive Implementation Guide

This document describes how to implement a *grid-aware* radio localization pipeline using the **Mamba** model family.  
Each `grid` corresponds to a unique physical trajectory or route.  
The goal is to ensure **clean generalization**, where training, evaluation, and testing are all performed **per grid**,  
without temporal leakage, data overlap, or state carry-over.

---

## 📁 Project Directory Structure

```txt
project/
├── data/
│ ├── radio/ # raw CSI or CIR data per grid
│ ├── truth/ # raw grid truth data per grid
│ └── features/
│   ├── logo/ # windowed feature samples (per grid)
│     ├── json/ # json data for nxy (pergrid) 
│     ├── npy / # feats/ts/xy.npy 
│     └── stats.json # mean/std computed on train windows only
├── test_out/
│ ├── train/
│ ├── test/
│ └── eval/
├── ckpt_refactor/
└── refactor/
  ├── core/ #core mamba scripts(python)
    ├── preprocess.py # data splitting + windowing + feature gen
    ├── dataset.py # unified dataset & normalization
    ├── sampler.py # grid-pure batch sampler
    ├── train.py   # training loop with grid-pure batches
    ├── eval.py    # per-grid evaluation and reporting
    └── utils_logging.py
```

---

## 🎯 Objectives

- **Improve phase and dynamics robustness** through better preprocessing.

---

## 🧩 1. Preprocessing: LOGO + Embargo + Windowing

### 1.1 Key CLI or YAML Arguments

| Argument | Type | Default | Description |
|-----------|------|----------|--------------|
| `--split` | str | `logo` | `logo` (leave-one-grid-out) or `oddeven` (legacy) |
| `--logo_holdout_gids` | str | `""` | comma-separated list of held-out grid IDs (e.g., `"2,5,14"`) |
| `--embargo_sec` | float | `20.0` | seconds of temporal buffer (removed near split boundaries) |
| `--fps` | int | `50` | frames per second |
| `--win_len` | int | `64` | window length (frames per sample) |
| `--train_stride` | int | `32` | stride between consecutive train windows |
| `--eval_stride` | int | `64` | stride for eval/test windows (≥ win_len) |
| `--phase_center` | bool | `True` | subtract mean phase per tap/antenna |
| `--append_delta` | bool | `True` | append time-difference features |
| `--dtype` | str | `float32` | feature dtype |

---

### 1.2 Why This Design

- **LOGO split** ensures test routes are truly unseen.  
- **Embargo** prevents temporal overlap between sets.  
- **Windowing during preprocessing** guarantees that train/eval/test samples never share frames.  
- **Phase centering** removes global phase rotation noise.  
- **Delta channels** highlight motion and dynamic variations.

---

### 1.3 Split Logic

```python
def _role_of_gid(gid, args, holdout):
    if args.split == "oddeven":
        train_is_odd = (args.odd_even == "odd")
        is_odd = (gid % 2 == 1)
        return "train" if (is_odd == train_is_odd) else "eval"
    else:  # LOGO mode
        return "eval" if gid in holdout else "train"
```

1.4 Window Construction
python
Copy code
def secs_to_frames(sec: float, fps: int) -> int:
    return int(round(max(0.0, sec) * max(1, fps)))

def build_windows(L: int, K: int, stride: int, start: int, end: int):
    i = start
    while i + K <= end:
        yield (i, i + K)
        i += stride
1.5 Feature Extraction Example

```python
Copy code
def cir_features_batch(Y, Ltap, phase_center=True, append_delta=True):
    D = np.fft.ifft(Y, axis=1)[:, :Ltap, :]                # (T, Ltap, A)
    p = np.sqrt(np.mean(np.abs(D)**2, axis=(0,1), keepdims=True)) + 1e-8
    Dn = D / p

    if phase_center:
        ph = np.angle(Dn)
        ph -= np.mean(ph, axis=0, keepdims=True)
        Dn = np.abs(Dn) * np.exp(1j * ph)

    T, L, A = Dn.shape
    feat_cir = np.stack([Dn.real, Dn.imag], axis=2).transpose(0,1,3,2).reshape(T, L*A*2)
    power = np.log1p(np.mean(np.abs(D)**2, axis=1))        # (T, A)
    feats = np.concatenate([feat_cir.astype(np.float32), power.astype(np.float32)], axis=1)

    if append_delta:
        d = np.zeros_like(feats)
        d[1:] = feats[1:] - feats[:-1]
        feats = np.concatenate([feats, d], axis=1)

    return feats
```

1.6 Saving Windowed Data

```python
# Determine role (train or eval)
role = _role_of_gid(gid, args, holdout)
E = secs_to_frames(args.embargo_sec, args.fps)
K = args.win_len
L = feats.shape[0]

if role == "train":
    cut = int(0.8 * L)
    windows = list(build_windows(L, K, args.train_stride, 0, cut - E))
else:
    windows = list(build_windows(L, K, args.eval_stride, E, L - E))

X = np.stack([feats[s:e] for s,e in windows])
Y = np.stack([xy_gt[e-1] for s,e in windows])
TS = np.stack([ts[s:e] for s,e in windows])

np.savez(os.path.join(out_dir, f"{gid:03d}.npz"),
         feats=X.astype(np.float32),
         xy=Y.astype(np.float32),
         ts=TS.astype(np.float64),
         meta=json.dumps({"role": role, "win_len": K,
                          "stride": args.train_stride if role=="train" else args.eval_stride,
                          "embargo_sec": args.embargo_sec}))
```

1.7 Global Statistics (Train-Only)

```python
# compute over all train windows
mean = np.mean(total_sum / total_count, axis=0)
std  = np.sqrt(total_sumsq / total_count - mean**2)
std  = np.maximum(std, 1e-2)  # std floor
json.dump({"mean": mean.tolist(), "std": std.tolist()}, open("stats.json","w"))
```

🧠 2. Dataset and Normalization
2.1 Dataset Structure

```python
class GridWindowDataset(Dataset):
    def __init__(self, root, split, stats, normalize=True):
        self.files = sorted(Path(root, split).glob("*.npz"))
        self.mean, self.std = stats["mean"], stats["std"]
        self.normalize = normalize
        self.grid_to_indices, self.samples = {}, []
        for i, f in enumerate(self.files):
            data = np.load(f, allow_pickle=True)
            gid = int(Path(f).stem)
            X, Y = data["feats"], data["xy"]
            for j in range(X.shape[0]):
                self.samples.append((gid, j, X[j], Y[j]))
            self.grid_to_indices[gid] = list(range(len(self.samples)-X.shape[0], len(self.samples)))
        self.unique_grids = list(self.grid_to_indices.keys())

    def __getitem__(self, idx):
        gid, j, x, y = self.samples[idx]
        if self.normalize:
            x = (x - self.mean) / self.std
        return torch.tensor(x), torch.tensor(y), gid

    def __len__(self):
        return len(self.samples)
```

⚙️ 3. Grid-Pure Batching
3.1 Option A: Multi-Loader Round-Robin

```python
grid_loaders = {gid: DataLoader(ds_gid, batch_size=BS, shuffle=True, drop_last=True)
                for gid, ds_gid in per_grid_datasets.items()}
iters = {gid: iter(loader) for gid, loader in grid_loaders.items()}
order = list(grid_loaders.keys())

for epoch in range(EPOCHS):
    for step, gid in enumerate(cycle(order)):
        try:
            batch = next(iters[gid])
        except StopIteration:
            iters[gid] = iter(grid_loaders[gid])
            batch = next(iters[gid])
        if hasattr(model, "reset_state"):
            model.reset_state()
        loss = train_step(model, batch)
```

3.2 Option B: Custom GridBatchSampler
```python
Copy code
class GridBatchSampler(Sampler):
    def __init__(self, grid_to_indices, batch_size):
        self.g2i = {g: i[:] for g,i in grid_to_indices.items()}
        self.bs = batch_size
    def __iter__(self):
        import random
        for g in self.g2i: random.shuffle(self.g2i[g])
        ptr = {g:0 for g in self.g2i}
        done=False
        order=list(self.g2i.keys())
        while not done:
            done=True
            for g in order:
                i=ptr[g]
                if i < len(self.g2i[g]):
                    done=False
                    batch=self.g2i[g][i:i+self.bs]
                    ptr[g]+=self.bs
                    if batch: yield batch
    def __len__(self):
        import math
        return sum(math.ceil(len(v)/self.bs) for v in self.g2i.values())
```

Usage:

```python
Copy code
sampler = GridBatchSampler(dataset.grid_to_indices, batch_size=BS)
train_loader = DataLoader(dataset, batch_sampler=sampler, num_workers=4)
```

3.3 Balance Across Grids
Cap max_windows_per_grid or oversample smaller grids to avoid dominance.

Ensure each grid appears roughly equally per epoch.

🚀 4. Training Loop
4.1 Core Loop

```python
for epoch in range(EPOCHS):
    model.train()
    for batch in train_loader:
        x, y, gid = batch
        if hasattr(model, "reset_state"): model.reset_state()
        pred = model(x)
        loss = criterion(pred, y)
        loss.backward()
        optimizer.step(); optimizer.zero_grad()
```

4.2 Reset State Between Grids
Always call model.reset_state() when:

Starting a new batch.

Switching between grids.

This prevents hidden states from leaking across routes.

📊 5. Evaluation & Reporting
5.1 Per-Grid Evaluation

```python
def eval_one_grid(model, dataset, gid, batch_size=256):
    idx = dataset.grid_to_indices[gid]
    subset = Subset(dataset, idx)
    loader = DataLoader(subset, batch_size=batch_size, shuffle=False)
    if hasattr(model, "reset_state"): model.reset_state()
    return evaluate(model, loader)  # returns dict of metrics
```

5.2 Macro Summary

```python
metrics = {}
    for gid in sorted(dataset.unique_grids):
        metrics[gid] = eval_one_grid(model, dataset, gid)

    macro = {k: np.mean([v[k] for v in metrics.values()]) for k in metrics[list(metrics.keys())[0]]}
    log_metrics(metrics, macro)
```

📈 6. Metrics to Report
Metric	Description
MAE	Mean Absolute Error (meters)
RMSE	Root Mean Square Error
CDF@50/75/90	Percentiles of position error (cm)
Macro Mean	Average over all grids

Plot CDF curves per grid to visualize generalization differences.

🧮 7. Optional: Heteroscedastic Regression Head
Replace fixed-output regression with a (mu, logvar) head and use Gaussian NLL loss:

```python
def gaussian_nll(mu, logvar, y):
    inv_var = torch.exp(-logvar)
    return 0.5 * torch.mean(((y - mu)**2) * inv_var + logvar)
```

Why: Increases robustness to measurement noise and domain shifts.

📜 8. Config Templates

```txt
preprocess.yaml
yaml
Copy code
split: logo
logo_holdout_gids: "2,5"
embargo_sec: 20.0
fps: 50
win_len: 64
train_stride: 32
eval_stride: 64
phase_center: true
append_delta: true
dtype: float32
train.yaml
yaml
Copy code
batch_size: 128
epochs: 60
optimizer: adamw
lr: 2e-4
grid_pure_batching: sampler
max_windows_per_grid: 10000
loss: gaussian_nll
aux_velocity: false
eval.yaml
yaml
Copy code
batch_size: 256
metrics: [MAE, RMSE, CDF50, CDF75, CDF90]
aggregate: macro
```

⚠️ 9. Common Pitfalls Checklist

 Any overlapping window between train/eval/test → No!

 Embargo shorter than window length → Increase to ≥ 2×win_len or ≥10–30s

 Normalization includes eval/test → No! Train-only stats.

 Mixed-grid batches → Forbidden.

 Hidden state not reset between grids → Reset every batch.

 Grid imbalance → Resample or truncate.

 Only overall metrics logged → Add per-grid logs.

✅ 10. Summary

Step	What to Implement	Why It Matters
Preprocessing	LOGO + Embargo + Windowing	Prevents data leakage, ensures fair splits
Feature Extraction	Phase-centering + Δ-channel	Improves phase/dynamics invariance
Normalization	Train-only global stats	Keeps eval/test consistent
Training	Grid-pure batches, state reset	Avoids cross-grid contamination
Evaluation	Per-grid + macro metrics	Measures real generalization
Loss	Gaussian NLL (optional)	Better under distribution shifts

End of document.
