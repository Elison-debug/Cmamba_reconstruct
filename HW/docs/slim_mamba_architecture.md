# Slim-Mamba Architecture

## 1. Design Goal

The hardware in this tree is organized as a fixed shell plus a reconfigurable
compute core. The external interface stays stable:

- PS-side loading format stays unchanged
- the board shell stays unchanged
- the system-level entry point is still a four-block chain

What changes is the internal organization of the compute core. The design is
structured so that each block exposes a clear sequence of stages and the chain
top can configure each block independently.

## 2. Top-Level Structure

The current implementation is split into three levels:

1. `slim_mamba_chain4_top`
   - project-facing top level
   - binds the board-shell contract to the four-block core
   - forwards one descriptor per block and one stage directory per block
2. `slim_mamba_chain4`
   - four-block chain core
   - owns chain-level launch and block-to-block sequencing
   - instantiates one `slim_mamba_block_from_stage_dir` per block
3. `slim_mamba_block`
   - single block datapath
   - owns the local stage order and the local control contract

This keeps the top level small while still making the internal execution order
visible in the RTL.

## 3. Block Execution Order

One block executes the following stages in order:

1. `RMSNorm` on the incoming hidden state
2. `in_proj` on the shared linear fabric
3. `u`-branch activation fill into local SRAM
4. `SSM` stage for dt projection, gating, state update, and p capture
5. `out_proj` on the shared linear fabric

The stage order is fixed. The per-block configuration decides how the linear
stages behave, whether state scan uses scaled update mode, and whether state
starts in a continuous or cleared mode.

## 4. Block Configuration

The block descriptor lives in `slm_block_cfg_pkg`.

`slm_block_cfg_t` contains:

- `inproj_desc`
- `dt_desc`
- `outproj_desc`
- `use_scaled_state_scan`
- `state_continuous_default`

The helper constructors build a descriptor from a small set of flags or from
fully specified linear descriptors. That keeps the top-level parameters short
while still allowing a chain to configure each block independently.

The chain top exposes:

- `BLOCK_CFG_B0`
- `BLOCK_CFG_B1`
- `BLOCK_CFG_B2`
- `BLOCK_CFG_B3`

Each block can therefore run with a different operator profile without
changing the chain interface.

## 5. Linear Stage Abstraction

The unified linear stage is implemented by `slm_linear_stage`.

It is parameterized by `slm_linear_role_t`:

- `SLM_LINEAR_INPROJ`
- `SLM_LINEAR_DTPROJ`
- `SLM_LINEAR_OUTPROJ`

The stage keeps the same structural shell while the role selects the local
read/write ports and control contract. This makes the stage reusable across
the three linear uses in the block.

The corresponding lifecycle wrapper is `slm_linear_controller`, which owns:

- launch request acceptance
- busy/done tracking
- descriptor exposure while a stage is active

## 6. Shared Fabric Scheduling

The linear stages feed a single shared MAC fabric through
`slm_fabric_scheduler`.

The scheduler arbitrates among the three linear users:

- `dt_proj`
- `in_proj`
- `out_proj`

The current policy is intentionally simple because the stages are not active
at the same time in the baseline chain schedule. The module boundary is
explicit so the policy can be changed later without rewiring block internals.

## 7. State Stage

`slm_ssm_stage` owns the recurrent state path.

It handles:

- dt projection launch and completion
- z-branch stream and gate preparation
- state update and clear control
- p-row capture for the later out-projection stage

This keeps the recurrent part of the block readable as one stage rather than
as a collection of loosely coupled helper blocks.

## 8. Chain Control

The chain-level controllers keep the four blocks in order.

- `slm_chain_controller` owns chain start, block launch requests, and block
  completion tracking.
- `slm_block_launch_ctrl` turns a block-level launch request into a one-cycle
  start pulse and returns the block busy/done signals in a consistent format.
- `slm_block_controller` sequences the local block stages.

This separation lets the chain keep its own timing policy while the block
still retains local stage ownership.

## 9. Stage Directory Wrapper

`slim_mamba_block_from_stage_dir` binds a stage directory to a block
instance.

The wrapper resolves the memory images for:

- in-projection weights
- dt weights
- out-projection weights
- norm gamma
- bias
- state scaling tables

This keeps the top-level interface short and makes block instantiation a
matter of selecting a directory plus a descriptor.

## 10. Verification Flow

The current verification flow is organized around three checks:

1. `slim_block_smoke`
   - checks the block control handshake and completion path
2. `slim_chain4_debug`
   - compares the four-block chain output against the golden vectors
3. `legacy_chain4_debug`
   - keeps the original reference path available as a baseline comparison

The current run scripts also support GUI debugging through
`run_xsim_hw_gui.py`.

## 11. What This Structure Is Good For

This organization is useful because it makes three things explicit:

- stage ownership
- block-local configuration
- chain-level composition

That makes the code easier to explain, easier to test, and easier to extend
with new scheduling policies or timing partitions later.
