from __future__ import annotations
import argparse
from pathlib import Path
import sys
import numpy as np


def _ensure_repo_root_on_path():
    here = Path(__file__).resolve()
    repo = here.parents[2] if len(here.parents) >= 3 else here.parent
    if str(repo) not in sys.path:
        sys.path.insert(0, str(repo))


def main():
    _ensure_repo_root_on_path()
    p = argparse.ArgumentParser(description="Dump one (K,Din) window from features into x.npy for C++ demo")
    p.add_argument("--feat_root", type=str, default=r"./data/features/logo_2100")
    p.add_argument("--export_json", type=str, default=r"./export_logo_2100/export.json")
    p.add_argument("--out_path", type=str, default=r"./export_logo_2100/x.npy")
    p.add_argument("--sample", type=int, default=0)
    args = p.parse_args()

    import json
    K = 12
    try:
        meta = json.load(open(args.export_json, 'r', encoding='utf-8'))
        K = int(meta.get('model', {}).get('seq_len', K))
    except Exception:
        pass

    from refactor.datasets.frames_lazy import FramesLazyDataset
    ds = FramesLazyDataset(root=args.feat_root, seq_len=K, predict='current')
    xb, _ = ds[int(max(0, min(args.sample, len(ds)-1)))]
    x = xb.numpy().astype('float32')
    out = Path(args.out_path)
    out.parent.mkdir(parents=True, exist_ok=True)
    np.save(out, x)
    print({"x_path": str(out.resolve()), "shape": list(x.shape)})


if __name__ == "__main__":
    main()

