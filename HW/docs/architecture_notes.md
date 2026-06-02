# Architecture Notes

## Design intent

The new block is structured as:

1. `slm_block_controller`
2. `slm_gemv_dispatcher`
3. `slm_gemv_scheduler`
4. `slm_shared_gemv_engine`
5. `slm_state_datapath`

The controller submits jobs rather than toggling stage-local start pulses in a
hardcoded sequence. A block therefore becomes a composition of:

- front-end preprocessing
- shared linear operators
- recurrent state update
- output projection and residual closure

## First implementation target

The first target remains the current deployed Slim-Mamba block:

- RMSNorm
- in-projection
- DWConv + SiLU on the state branch
- dt/lambda generation
- gated recurrent update
- output gate
- out projection

The architecture should however make these steps explicit enough that later
replacements such as:

- fixed-scale vs runtime-scale state update
- DWConv bypass
- dedicated vs shared linear engines

can be compared without rewriting the whole block.

## Non-goals in the first step

- changing the board shell
- changing PS-side traffic format
- supporting arbitrary runtime graph reconfiguration
- preserving every legacy module or interface

