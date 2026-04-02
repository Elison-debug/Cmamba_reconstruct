# Deprecated

This directory contains older INT16 backend experiments (`Q8.8` style kernels and LUT utilities).

It is not part of the current mainline deployment plan.

The preferred deployment-side reference flow is now:

- model export: `refactor/export`
- bit-true software reference: `refactor/bittrue`
- training/QAT path: `refactor/quant`

Do not attach new FPGA deployment work to this directory unless you explicitly decide to revive the old INT16 route.
