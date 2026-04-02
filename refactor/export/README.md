# Deprecated

This directory is now a compatibility layer only.

The canonical deployment export implementation has moved to:

- `refactor/bittrue/pack.py`
- `refactor/bittrue/cli.py`
- `refactor/bittrue/schema.json`

Existing wrappers are kept here only to avoid breaking older commands.

New export or FPGA-reference work should be added under `refactor/bittrue/`.
