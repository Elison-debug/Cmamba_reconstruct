# Slim-Mamba hardware project notes

## Default Vivado project

The default GUI project is now:

- `E:/course/smamba/HW/project_slim_mamba_c01_hw/project_slim_mamba_c01_hw.xpr`

Its project-facing top is:

- `E:/course/smamba/HW/rtl/shell/slim_mamba_chain4_project_top.sv`

This wrapper fixes the default hardware case to `final_hw/cases/c01` and binds:

- the four block stage directories
- the sigmoid lookup table
- the block descriptors used by the four-block chain

As a result, opening the project in Vivado no longer depends on manual parameter
entry for `STAGE_DIR_B0..B3`, and the relevant `.mem` / `.hex` files are added
to the project file list.

## What is already unified in the linear path

The current linear path unification is real, but limited to the stage boundary
and the shared execution contract.

Unified pieces:

- `E:/course/smamba/HW/rtl/shell/slm_linear_cfg_pkg.sv`
  - role definitions and stage-level configuration types
- `E:/course/smamba/HW/rtl/shell/slm_linear_controller.sv`
  - common launch / busy / done lifecycle controller
- `E:/course/smamba/HW/rtl/shell/slm_linear_stage.sv`
  - common operator-facing stage contract
- `E:/course/smamba/HW/rtl/shell/slm_fabric_scheduler.sv`
  - shared MAC-fabric arbitration boundary
- `E:/course/smamba/HW/rtl/common/slm_weight_bank_store.sv`
  - shared banked weight-store backend now used by `in_proj`, `dt_proj`, and
    `out_proj`

This means the block-level control logic already sees the three linear
operators through one common stage abstraction.

## What is not yet unified

The internal datapath scheduler is still role-specific.

`slm_linear_stage.sv` currently dispatches to:

- `reuse_in_proj_scheduler`
- `reuse_ssm_dt_scheduler`
- `reuse_out_proj_scheduler`

So the project does **not** yet have one fully shared linear datapath kernel.
The current design has unified:

- the stage boundary
- the control contract
- the fabric-facing interface

but it has **not** unified:

- weight-bank traversal
- source-vector read scheduling
- output writeback sequencing
- the role-specific pipeline state machine

The weight storage backend is now shared, so the remaining duplication is no
longer in the ROM banking itself. It is now concentrated in the scheduler-side
traversal and writeback logic.

## Practical implication

For project use, this is already useful:

- the block controller sees one linear-stage abstraction
- the chain top sees one block abstraction
- the Vivado project can elaborate the default case directly

For a paper-oriented “fully reusable operator” claim, this is still not enough.
That stronger claim requires a deeper refactor inside the linear datapath.

## Recommended next refactor target

The next meaningful unification step is to split the three legacy schedulers
into two layers:

1. A shared backend that owns the common matrix-vector execution machinery
2. Thin role-specific adapters that only define traversal and endpoint policy

The backend should absorb the logic that is structurally common across the
three operators:

- scale-memory access
- fabric launch / drain timing
- requantization
- shared matrix-tile staging registers

The packed weight-bank ROM access is already on this shared path. The next
beneficial extraction should therefore start from the timing / traversal side,
not from the storage primitive itself.

## Other places that still need the same scrutiny

There are still modules in the `slm_*` path that expose a cleaned-up boundary
but delegate the full inner implementation to an older execution core:

- `E:/course/smamba/HW/rtl/shell/slm_linear_stage.sv`
  - unified stage contract, role-specific schedulers underneath
- `E:/course/smamba/HW/rtl/shell/slm_fabric_scheduler.sv`
  - cleaned arbitration boundary, but still backed by `reuse_shared_mac_fabric`
- `E:/course/smamba/HW/rtl/shell/slm_ssm_stage.sv`
  - explicit state-stage boundary, but the selective-state datapath still uses
    `reuse_ssm_core`, `reuse_pt_capture`, and the existing gate/readout helpers

These are the most relevant remaining “same interface, older core underneath”
cases in the current Slim-Mamba path.

The role adapters should then provide only the pieces that really differ:

- source operand origin
- row / group address traversal
- destination buffering and writeback format

That is the point where the project moves from “common shell around role-specific
schedulers” to “one reusable linear execution backend with role adapters”.

## Current cycle profile and what it means

A dedicated probe testbench now measures the busy duration of the block stages:

- `E:/course/smamba/HW/tb/tb_slim_stage_cycle_probe.sv`

With the current shared linear execution core, the measured cycle counts are:

- total block cycles: `5443`
- `in_proj` busy cycles: `2337`
- `dt_proj` scheduler busy cycles: `1665`
- whole SSM stage busy cycles: `1829`
- `out_proj` busy cycles: `897`

Two points matter here:

1. `dt_proj` by itself is not the right comparison target for `in_proj`
   because the selective-state recurrence, gate path, and `p_t` capture are
   outside the `dt_proj` scheduler and remain inside the SSM stage.
2. The three linear operators do not have the same number of output row tiles:
   - `in_proj`: `128 -> 512`, so `128` row tiles
   - `dt_proj`: `256 -> 256`, so `64` row tiles
   - `out_proj`: `256 -> 128`, so `32` row tiles

So the lower `dt_proj` busy count does not mean that the whole SSM path is
intrinsically cheaper than the input projection. It reflects both different
row-tile counts and the fact that the non-linear state path is accounted for
elsewhere.

## Why the original dt path looks structurally more efficient

The original `dt_proj` scheduler differs from the original `in_proj` and
`out_proj` schedulers in one important way:

- `dt_proj` preloads the full input vector into a local cache once
- later row-tile computations reuse that cache

The original `in_proj` and `out_proj` paths repeatedly issue source SRAM reads
while stepping over output tiles. The current refactor already imports the
preload-cache idea into the shared linear execution core:

- `E:/course/smamba/HW/rtl/linear/slm_linear_gemv_core.sv`

This is a real architectural change, but it is only the first half of the
optimization. By itself, caching the source vector does not remove the fixed
per-row-tile control cost.

## Can the three linear operators be unified?

Yes, but only if “unified” means one shared execution backend plus thin role
adapters, not one identical wrapper around three different schedulers.

The common backend now has a realistic scope:

- source-vector preload
- banked weight fetch
- 4x4x4 MAC issue/drain schedule
- result capture
- requantization

The remaining role-specific pieces are:

- where the source vector comes from (`h_t`, activated `u_t`, or cached state input)
- how tiles are ordered
- whether results are written to SRAM or emitted as a stream

The current project already follows this direction for `in_proj` and `out_proj`.
`dt_proj` still needs to be absorbed into the same backend more deeply.

## Can the three linear operators be pipelined?

Yes, but not in the naive “3x speedup” sense.

### What is feasible

- `SSM -> out_proj` row-wise pipelining is structurally feasible.
  As soon as `p_t` rows are produced and stored, `out_proj` can consume them
  without waiting for the entire frame to finish.
- A shared linear engine can serve the three operators under a scheduler that
  switches contexts between stage descriptors.
- Cross-block pipelining is also feasible once block-local buffering and start
  ownership are cleaned up.

### What is not immediately free

- `in_proj -> dt_proj` is not a simple row-wise pipeline in the current
  algorithm. `dt_proj` consumes the whole activated `u_t` vector for each
  output row tile, so a later stage cannot start from only one early `u_t`
  tile unless the datapath is redesigned to accumulate partial sums across
  time.
- `z_t` and the gate path have their own ordering constraints. Even if the
  `u_t` path is streamed earlier, the state update for row `t` still needs the
  matching gate information and recurrence state alignment.

So a full three-stage intra-block pipeline requires more than a control tweak.
It requires:

- multi-context accumulation or partial-sum retention for `dt_proj`
- a row/tile ordering policy that aligns `u_t`, `z_t`, and state-update use
- explicit stream/buffer contracts between stages

## Practical speedup bound

Even if the three linear operators could overlap perfectly, the upper bound is
not close to `3x`, because:

- the operators have different row-tile counts
- the SSM stage contains non-linear work outside `dt_proj`
- the current block contains stage-boundary overhead that is not linear-only

Using the current busy counts as a rough guide:

- serial linear busy budget: `2337 + 1665 + 897 = 4899`
- ideal lower bound under perfect overlap: approximately `max(2337, 1665, 897) = 2337`

So the absolute best-case overlap is closer to a bit above `2x` for the linear
portion, not `3x` for the whole block.

## Recommended next refactor target for pipelining

The next architecture step should not be “start all three stages earlier” in
the current controller. It should be:

1. Replace the frame-level stage barriers with explicit tile-stream contracts.
2. Make `out_proj` able to consume `p_t` as a running stream instead of after a
   full-stage barrier.
3. Redesign `dt_proj` around partial accumulation if true `in_proj -> dt_proj`
   overlap is desired.

That is the path that turns the current block from a sequential stage machine
into a real pipelined operator graph.

## What Route A actually achieves

Route A keeps the `p` SRAM and launches `out_proj` early, but limits the early
phase to SRAM preload only. GEMV compute is held off until the SSM stage has
finished.

This path is now implemented and validated in the current RTL. The measured
effect is:

- original SRAM-gated path: `5443` total block cycles
- Route A SRAM-preload overlap path: `5379` total block cycles

So the recovered speedup is only `64` cycles.

This number is not accidental. With the current shared GEMV backend:

- `out_proj` still requires the full `p_t` frame before compute can start
- the `p` SRAM preload itself is only `64` tiles deep
- the preload path reads one tile per cycle

Therefore, Route A can remove at most the post-SSM `p`-buffer read phase. It
cannot recover the much larger historical speedup by itself.

The practical implication is important for the paper narrative:

- the `p` SRAM is not just a debug residue; it is a useful inter-stage
  decoupling store
- but under the current backend, it only enables a small preload overlap
- the large earlier speedup must have come from a more aggressive overlap mode
  than “SRAM preload first, compute later”

## Streaming `p_t` refactor: current state

The latest block-local refactor removes the full-stage barrier between the
state path and `out_proj` consumption.

Structural changes:

- `E:/course/smamba/HW/rtl/shell/slm_ssm_stage.sv`
  - now exposes the generated `p_t` tiles as a stream
  - still writes the same tiles into local `p` SRAM for observability and
    debug
- `E:/course/smamba/HW/rtl/linear/slm_linear_gemv_core.sv`
  - now supports two preload modes for the source vector:
    - SRAM preload
    - stream preload
- `E:/course/smamba/HW/rtl/linear/slm_out_proj_scheduler.sv`
  - now preloads `p_t` directly from the state-stage stream
  - no longer depends on the `p` SRAM read path for functional execution
- `E:/course/smamba/HW/rtl/shell/slm_block_controller.sv`
  - now launches `out_proj` together with the SSM stage so the output stage
    can preload `p_t` while the state update is still running

This is the first real intra-block overlap in the new path. The block is still
not fully pipelined, but the `SSM -> out_proj` boundary is no longer a pure
frame-level barrier.

Measured effect with the same probe bench:

- previous total block cycles: `5443`
- current total block cycles: `3721`

Current per-stage probe output after the stream-preload change:

- total block cycles: `3721`
- `in_proj` busy cycles: `2337`
- `dt_proj` scheduler busy cycles: `996`
- whole SSM stage busy cycles: `191`
- `out_proj` busy cycles: `1005`

The `dt_proj` and SSM counts should now be read differently than before,
because the out stage starts earlier and its preload overlaps with the state
stage. The useful conclusion is not that the state stage became intrinsically
cheap, but that the old `p capture -> SRAM -> out_proj start` barrier is no
longer dominating the block latency.

## What this means for operator partitioning

The current behavior makes a clearer architectural split visible:

- `in_proj` and `dt_proj` still have same-frame dependence through the
  activated `u_t` path
- `out_proj` only depends on the emitted `p_t` stream

That suggests a more credible long-term architecture than “three fully
equivalent linear stages”:

1. One shared projection operator for the front half of the block
   - `in_proj`
   - `dt_proj`
2. One trailing output operator for `out_proj`
   - optionally dedicated if throughput matters more than area

This split matches the actual data-dependence graph better than forcing all
three operators into one identical pipeline story.

## Answering the main architecture concerns

### 1. `4x4x4` is hard-coded rather than proven or switchable

This concern still stands.

The new path has cleaned stage boundaries and descriptors, but the execution
kernel still assumes the same physical tile shape in:

- the shared MAC fabric
- the banked weight layout
- the preload/cache schedule
- the output-row grouping logic

So `4x4x4` is currently an implementation-fixed microarchitecture, not yet a
descriptor-selected design point. For a stronger paper claim, the next step
would be to lift tile shape into a smaller set of architectural parameters and
show at least one alternative build point.

### 2. The shared MAC fabric is still serial reuse, not reconfigurable scheduling

This also still stands in substance.

`slm_fabric_scheduler.sv` is cleaner than the old manager, but it still chooses
one owner at a time and forwards that owner's matrices into the same fabric.
That is shared execution, not yet a higher-level reconfigurable schedule.

What improved is:

- the arbitration boundary is explicit
- the ownership policy can now evolve independently
- the out stage can overlap preload with another owner's compute

What is still missing is:

- descriptor-driven slot scheduling
- multi-context issue queues
- a proof that the fabric schedule itself is configurable, not just reused

### 3. The three linear schedulers were highly isomorphic but not abstracted

This is only partially resolved, but meaningfully better than before.

Resolved pieces:

- one shared weight-store backend
- one shared GEMV execution core for `in_proj` and `out_proj`
- one source contract that now supports both SRAM preload and stream preload
- one stage-level role interface in `slm_linear_stage.sv`

Still unresolved:

- `dt_proj` is not yet absorbed into the same execution core
- traversal and issue policy are still not one generic scheduler template

So the answer is: the worst duplication is no longer in storage and requant
plumbing, but the project has not yet reached a single generic linear
scheduler.

### 4. The top-level configurability was partly fake

This has improved substantially in the new path.

The block behavior is now tied to:

- `slm_linear_desc_t`
- `slm_block_cfg_t`
- the per-block configuration fields carried into the chain

The current `slm_*` path does not rely on the old style of exposing config
ports and then overriding them internally with constants. The remaining issue
is different: some descriptors still do not control as much of the real
microarchitecture as their names may suggest.

So the “fake configurability” problem is much smaller, but the descriptors are
still not powerful enough to justify a fully reconfigurable claim.

### 5. The top-level block orchestration was strictly serial

This is no longer fully true.

The front half remains serial because it reflects true dependence:

- `RMSNorm -> in_proj -> u activation fill -> SSM`

But the block is no longer strictly serial end-to-end, because:

- `out_proj` is launched together with `SSM`
- `out_proj` now consumes `p_t` through a stream-preload path

So the old criticism remains valid for the `in_proj -> dt_proj` boundary, but
it is no longer valid for `SSM -> out_proj`.

### 6. The SSM recurrence path is still tightly coupled

This concern still stands.

The current SSM stage boundary is cleaner, but the internal state-update path is
still a very specific chain:

- dt MAC output
- gate preparation
- bias/sigmoid/runtime scale logic
- state update
- `p_t` emission

This is still a block-specific recurrence pipeline, not a generic interchangeable
operator graph. For publication, it should be presented honestly as a specialized
state-update engine, not overclaimed as a fully generic operator.

### 7. Runtime scaling is promising but expensive and tightly coupled

This also still stands, and it is probably one of the strongest paper angles.

The runtime scaling path is valuable because it addresses numeric robustness
under fixed-point recurrence, but the current implementation also explains why
the state stage becomes timing-sensitive:

- per-lane runtime scale logic is in the active recurrence path
- the path is tightly interleaved with gate/state update control
- the scaling policy is not yet separated as an independently swappable service

A stronger next architecture step would be to factor runtime scaling into a
clearer micro-stage contract with explicit latency and buffering, so it can be
analyzed and optimized as a first-class block.

## Recommended next step

The most coherent next step is no longer “force all three linear stages into
one identical scheduler”. It is:

1. keep the new stream-preload `SSM -> out_proj` path
2. decide explicitly whether `out_proj` should stay on the shared fabric or use
   a dedicated trailing operator
3. focus the shared front-half operator on `in_proj + dt_proj`
4. only then decide whether `dt_proj` should be fully absorbed into the shared
   GEMV backend or remain a specialized state-front-end adapter

That path aligns better with the real dependence graph and gives a more
defensible architecture story for a paper.
