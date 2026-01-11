## 📘 1. Mathematical Basis for Bank Mapping

Given the weight access pattern:

- Each cycle loads 4 columns → 1 block
- Arrays read blocks in strides of 16 columns (4 blocks):
  
\[
block\_id(cycle) = 4(cycle - 1)
\]

When mapped into memory banks using modulo:
\[
bank\_id = block\_id \bmod N_{\text{bank}}
\]

This produces a modular sequence:
\[
a_k = 4k \bmod N_{\text{bank}}
\]

---

## 📘 2. Number of Distinct Residue Classes

A fundamental theorem from number theory states:

> The number of distinct residues produced by  
> \( a_k = stride \cdot k \mod N \)  
> is  
> \[
\#\text{class} = \frac{N}{\gcd(N, stride)}
\]

This is the orbit size of stride under the cyclic group \( \mathbb{Z}_N \).

For our stride = 4, the residue class count becomes:

\[
\#\text{class} = \frac{N_{\text{bank}}}{\gcd(N_{\text{bank}}, 4)}
\]

---

## 📘 3. Why residue classes matter?

The number of residue classes determines:

- how evenly `block_id` values distribute across banks  
- how many banks are actually exercised in the access pattern  
- whether different arrays can be mapped to *different residue classes*  
- whether **dual-port RAM** (up to 2 reads per bank per cycle) is sufficient  
- whether **temporal conflicts** occur (due to 2-cycle read latency)

In a **single-port** design, we typically require:

\[
\#\text{class} \ge 4 
\]

so that 4 arrays can be mapped to four distinct classes without 3-way conflicts.

However, in a **dual-port** design like ours:

- arrays are naturally grouped into two pairs (A1/A3 and A2/A4),  
- each pair can share a bank using two ports,  
- therefore **3 residue classes are sufficient** to schedule the two pairs safely.

Thus:

- with single-port RAM → class ≥ 4 is necessary  
- with dual-port RAM → class ≥ 3 is sufficient

---

## 📘 4. Residue Class Table (Key Result)

| Nbank | gcd(N,4) | #class | Status |
|------:|----------:|--------:|--------|
| 4 | 4 | 1 | ❌ impossible |
| 6 | 2 | 3 | ✔️ feasible with dual-port pairing |
| 8 | 4 | 2 | ❌ not feasible |
| 10 | 2 | 5 | ✔️ ideal (most uniform distribution) |
| 12 | 4 | 3 | ✔️ feasible (original over-provisioned design) |

Summary:

- **6-bank → the smallest feasible configuration.**  
  - Residue classes = 3  
  - Arrays must be scheduled in two pairs (A1/A3 and A2/A4)  
  - Dual-port RAM ensures both pairs can safely coexist  
  - Requires careful pairing but fully correct and stable

- **10-bank → the most robust configuration.**  
  - Residue classes = 5  
  - Very uniform distribution of accesses  
  - No special scheduling constraints  
  - Naturally conflict-free and temporally safe


## 🧩 Choosing the Number of Banks

### ✔ Requirement:
We must support 4 arrays reading in parallel, with:

- dual-port RAM (up to 2 reads per bank per cycle)
- 2-cycle read latency (no temporal conflict allowed)
- fixed block_stride = 4

---

## 🟥 Why 6-bank is viable?

- Only 3 residue classes → {0,2,4}
- Pairs must be carefully placed into banks to avoid 3-way collision
- Dual-port must be strictly port-alternated cycle-by-cycle
- Works, but fragile

---

## 🟧 Why 10-bank is optimal?

- 5 residue classes → {0,4,8,2,6}
- Bank usage is maximally even
- Dual-port is naturally balanced
- No special scheduling required
- No temporal conflict risk

---

## 📌 Final design choice:
- **6-bank** → smallest feasible (requires careful scheduling)
- **10-bank** → recommended (best balance, most robust)

# 🧱 Bank–Column Mapping (Nbank = 6)

### Residue classes for block_id = 4k mod 6:
{0, 4, 2}

| **Bank ID** | **col_block_id (4-column block IDs)**                                   | **Column Range** |
|-------------|---------------------------------------------------------------------------|------------------|
| **bank0** | 0, 6, 12, 18, 24, 30, 36, 42, 48, 54, 60 | col0–3, 24–27, 48–51, 72–75, 96–99, 120–123, 144–147, 168–171, 192–195, 216–219, 240–243 |
| **bank1** | 1, 7, 13, 19, 25, 31, 37, 43, 49, 55, 61 | col4–7, 28–31, 52–55, 76–79, 100–103, 124–127, 148–151, 172–175, 196–199, 220–223, 244–247 |
| **bank2** | 2, 8, 14, 20, 26, 32, 38, 44, 50, 56, 62 | col8–11, 32–35, 56–59, 80–83, 104–107, 128–131, 152–155, 176–179, 200–203, 224–227, 248–251 |
| **bank3** | 3, 9, 15, 21, 27, 33, 39, 45, 51, 57, 63 | col12–15, 36–39, 60–63, 84–87, 108–111, 132–135, 156–159, 180–183, 204–207, 228–231, 252–255 |
| **bank4** | 4, 10, 16, 22, 28, 34, 40, 46, 52, 58     | col16–19, 40–43, 64–67, 88–91, 112–115, 136–139, 160–163, 184–187, 208–211, 232–235 |
| **bank5** | 5, 11, 17, 23, 29, 35, 41, 47, 53, 59     | col20–23, 44–47, 68–71, 92–95, 116–119, 140–143, 164–167, 188–191, 212–215, 236–239 |

# 🕓 Timeline + Bank Access Visualization (Nbank = 6)

| **Cycle** | **A1 → bank** | **A2 → bank** | **A3 → bank** | **A4 → bank** | **Banks Active** |
|:--------:|:--------------:|:--------------:|:--------------:|:--------------:|:-----------------:|
| **1** | bank0 | –      | –      | –      | {0} |
| **2** | bank4 | bank1 | –      | –      | {1,4} |
| **3** | bank2 | bank5 | bank2 | –      | {2,5} |
| **4** | bank0 | bank3 | bank0 | bank3 | {0,3} |
| **5** | bank4 | bank1 | bank4 | bank1 | {1,4} |
| **6** | bank2 | bank5 | bank2 | bank5 | {2,5} |
| **7** | bank0 | bank3 | bank0 | bank3 | {0,3} |
| **8** | bank4 | bank1 | bank4 | bank1 | {1,4} |
| **9** | bank2 | bank5 | bank2 | bank5 | {2,5} |
| **10** | bank0 | bank3 | bank0 | bank3 | {0,3} |
| **11** | bank4 | bank1 | bank4 | bank1 | {1,4} |
| **12** | bank2 | bank5 | bank2 | bank5 | {2,5} |

