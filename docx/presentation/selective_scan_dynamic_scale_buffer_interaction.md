# Selective Scan Dynamic Scale: Buffer and Quantization Interaction

This note focuses on how the current selective scan dynamic-scale path is connected in RTL, especially how the buffer interacts with the scale-generation logic and the quantization module.

## What Selective Scan Computes

Selective scan is the recurrent state update inside the Mamba block. For each time step and channel, it blends the previous state with the current input:

```text
s_t = lambda_t * s_{t-1} + (1 - lambda_t) * u_t
```

where:

```text
lambda_t : decay/update coefficient from dt sigmoid
u_t      : activated input branch, usually u_act
s_t      : updated scan state and scan output
```

So the scan stage is not a normal linear layer. It is the stateful part of the block: it keeps memory across sequence positions and produces the `ssm` output used by the gate path.

## Purpose

The selective scan update is:

```text
s_new = lambda * s_prev + (1 - lambda) * u
```

In the hardware path, `u` arrives as Q8.8, but the state can be stored as a scaled int16 value. Therefore the scan path needs two scale factors:

```text
u_to_state_q16      : convert u_q88 into scaled-state integer
state_to_q88_q16    : convert scaled state back to Q8.8 output
```

The scale path is not zero-latency. It needs time to compute or fetch the scale values. The buffer keeps the data token stable and aligned while this happens.

## Ping-pong Buffer Architecture

```mermaid
flowchart LR
    U[Upstream join output<br/>from axis_vec_join2]
    U --> T["One 4-lane scan token<br/>lam vector Q0.16<br/>u vector Q8.8<br/>state address"]

    T --> IN[Input latch<br/>in_lam_r / in_u_r / in_addr_r]

    IN --> SG[4 lane scale generators<br/>reuse_runtime_scale_lane_seq x4]
    SG --> S0["u_to_state_q16 vector"]
    SG --> S1["state_to_q88_q16 vector"]

    IN --> WA{{write bank select<br/>wr_ptr}}
    S0 --> WA
    S1 --> WA

    subgraph PP[reuse_state_scale_pingpong]
        B0["Bank 0<br/>addr<br/>lam vector<br/>u vector<br/>u2s vector<br/>s2q vector"]
        B1["Bank 1<br/>addr<br/>lam vector<br/>u vector<br/>u2s vector<br/>s2q vector"]
    end

    WA --> B0
    WA --> B1

    B0 --> RA{{read bank select<br/>rd_ptr}}
    B1 --> RA

    RA --> OUT["Aligned output token<br/>lambda vector<br/>u vector<br/>state address<br/>u_to_state scale vector<br/>state_to_q88 scale vector"]

    OUT --> EW[Downstream consumer<br/>ew_update_vec4]
    EW --> Q0[u quantization<br/>u_q88 * u_to_state_q16 >> 16]
    EW --> Q1[state update<br/>lam*s_prev + (1-lam)*u_scaled]
    EW --> Q2[output conversion<br/>s_new * state_to_q88_q16 >> 16]
```

The upstream side produces one 4-lane token per valid joined transfer. The ping-pong buffer stores both the original token and the scale vectors generated from that token. The downstream `ew_update_vec4` consumes the aligned bundle: `lambda`, `u`, `state_addr`, `u_to_state_q16`, and `state_to_q88_q16`.

## How the Buffer Interacts with Scale

`reuse_state_scale_pingpong` receives one scan token:

```text
lambda_q016
u_q88
state address
```

It then:

1. stores the token in one ping-pong bank;
2. sends `u_q88` to `reuse_runtime_scale_lane_seq`;
3. waits until all lane scale values are ready;
4. outputs the original token together with its matching scale vectors.

This guarantees:

```text
lambda/u/address and scale values belong to the same token
```

Without the buffer, the input stream could advance before the scale values are ready, causing token-scale misalignment or forcing the whole upstream pipeline to stall.

## How the Buffer Interacts with `ew_update_vec4`

The buffer output connects to `ew_update_vec4` as:

```text
out_lam_vec                -> lam_vec
out_u_vec                  -> u_vec
out_addr                   -> s_addr
out_u_to_state_scale_vec   -> u_to_state_scale_vec
out_state_to_q88_scale_vec -> state_to_q88_scale_vec
```

`ew_update_vec4` only consumes the token when both sides handshake:

```text
scale_pipe_valid && ew_in_ready
```

So the buffer also acts as a backpressure boundary between scale preparation and scan update.

## How `ew_update_vec4` Uses the Quantization Module

Inside `ew_update_vec4`, `requant_round_sat_engine` is used three times in the scaled-state path.

### 1. Q8.8 input to scaled int16

```text
u_scaled = round((u_q88 * u_to_state_q16) >> 16)
```

This uses:

```text
USE_SCALE = 1
scale_vec = u_to_state_scale_vec
SAT_MODE  = 1
ROUND_MODE = 1
```

### 2. State update requantization

```text
acc = lam_q15 * s_prev + (32768 - lam_q15) * u_scaled
s_new = round(acc >> 15)
```

This uses the quantization engine mainly as:

```text
right shift by 15
round-to-nearest-even
saturate to int16
```

### 3. Scaled state to Q8.8 output

```text
ssm_q88 = round((s_new * state_to_q88_q16) >> 16)
```

This uses:

```text
USE_SCALE = 1
scale_vec = state_to_q88_scale_vec
SAT_MODE  = 1
ROUND_MODE = 1
```

## Why Ping-pong Buffering Helps

The ping-pong structure allows two roles to overlap:

```text
Bank A: hold/output a token whose scale is ready
Bank B: accept/prepare the next token
```

This improves decoupling between:

```text
input stream timing
scale generation latency
ew_update consumption timing
```

It also makes backpressure easier to handle because `ew_update_vec4` does not need to directly stall the original upstream producer for every scale-generation cycle.

## Key Point

The buffer is not only a storage element. It is the synchronization point between:

```text
data token: lambda, u, state address
scale token: u_to_state_q16, state_to_q88_q16
compute token: ew_update_vec4 state update
```

The quantization engine then applies these scale values at the exact conversion points needed by the scaled-state selective scan.
