from __future__ import annotations

from collections import defaultdict
from typing import Dict, Iterable, Iterator, List, Sequence

import numpy as np
from torch.utils.data import Sampler


class GridPureBatchSampler(Sampler[List[int]]):
    """
    Batch sampler that yields grid‑pure batches for FramesLazyDataset.

    It groups dataset samples by their source file index (grid) using the
    dataset.index tuples (fi, s, t), and then round‑robins across grids so that
    each emitted batch contains indices from exactly one grid.

    This enforces the "grid‑pure batching" constraint to avoid cross‑grid state
    contamination and aligns training with per‑grid generalization goals.
    """

    def __init__(
        self,
        dataset: object,
        batch_size: int,
        *,
        drop_last: bool = True,
        shuffle_files: bool = True,
        shuffle_within: bool = True,
        seed: int = 42,
    ) -> None:
        super().__init__(None)
        self.dataset = dataset
        self.batch_size = int(batch_size)
        self.drop_last = bool(drop_last)
        self.shuffle_files = bool(shuffle_files)
        self.shuffle_within = bool(shuffle_within)
        self.rng = np.random.RandomState(seed)

        # Build mapping: file index -> list of sample indices (into dataset)
        by_file: Dict[int, List[int]] = defaultdict(list)
        index = getattr(dataset, "index", None)
        if not isinstance(index, Sequence):
            raise ValueError("dataset must expose 'index' as a sequence of (fi, s, t) triples")
        for global_idx, triplet in enumerate(index):  # type: ignore[arg-type]
            if not (isinstance(triplet, (tuple, list)) and len(triplet) == 3):
                raise ValueError("dataset.index elements must be (fi, s, t)")
            fi = int(triplet[0])
            by_file[fi].append(global_idx)
        self.by_file: Dict[int, List[int]] = by_file
        self.files: List[int] = sorted(by_file.keys())

        # Precompute length (number of batches)
        n_batches = 0
        for fi in self.files:
            n = len(self.by_file[fi]) // self.batch_size
            if not self.drop_last and (len(self.by_file[fi]) % self.batch_size) > 0:
                n += 1
            n_batches += n
        self._len = n_batches

    def __len__(self) -> int:  # number of batches
        return self._len

    def __iter__(self) -> Iterator[List[int]]:
        # Local copies with optional shuffling
        file_order = list(self.files)
        if self.shuffle_files:
            self.rng.shuffle(file_order)
        # within‑file permutations and cursors
        pools: Dict[int, List[int]] = {}
        ptr: Dict[int, int] = {}
        for fi in file_order:
            pool = list(self.by_file[fi])
            if self.shuffle_within:
                self.rng.shuffle(pool)
            pools[fi] = pool
            ptr[fi] = 0

        # Round‑robin across files until all exhausted
        alive = set(file_order)
        while alive:
            for fi in list(file_order):
                if fi not in alive:
                    continue
                pool = pools[fi]
                cur = ptr[fi]
                if cur >= len(pool):
                    alive.discard(fi)
                    continue
                nxt = cur + self.batch_size
                batch = pool[cur:nxt]
                if len(batch) < self.batch_size and self.drop_last:
                    alive.discard(fi)
                    continue
                ptr[fi] = nxt
                yield batch

