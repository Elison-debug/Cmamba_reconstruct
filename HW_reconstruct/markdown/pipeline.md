# 🚀 Mamba SSM – 4×4×4 Pipeline Array Memory Scheduling  
_Memory Access Pattern & Bank Mapping Overview_

---

## 🧩 Pipeline Execution Schedule  

| **Cycle** | **Array1 Input** | **Array2 (acc1+input)** | **Array3 (acc1+acc2+input)** | **Array4 (acc1+acc2+acc3+input)** | **Output** |
|:----------|:-----------------|:-------------------------|:------------------------------|:----------------------------------|:------------|
| 1 | col0–3 | - | - | - | - |
| 2 | col16–19 | col0–3 + col4–7 | - | - | - |
| 3 | col32–35 | col16–19 + col20–23 | col0–3 + col4–7 + col8–11 | - | - |
| 4 | col48–51 | col32–35 + col36–39 | col16–19 + col20–23 + col24–27 | col0–3 + col4–7 + col8–11 + col12–15 | ✅ tile0 output |
| 5 | col64–67 | col48–51 + col52–55 | col32–35 + col36–39 + col40–43 | col16–19 + col20–23 + col24–27 + col28–31 | ✅ tile1 output |
| 6 | col80–83 | col64–67 + col68–71 | col48–51 + col52–55 + col56–59 | col32–35 + col36–39 + col40–43 + col44–47 | ✅ tile2 output |
| 7 | col96–99 | col80–83 + col84–87 | col64–67 + col68–71 + col72–75 | col48–51 + col52–55 + col56–59 + col60–63 | ✅ tile3 output |

---

 ## 🧮 Weight Input Column Scheduling (Revised)

;; | **Cycle Range** | **Array1 Columns** | **Array2 Columns** | **Array3 Columns** | **Array4 Columns** | **Description** |
;; |:----------------|:------------------|:------------------|:------------------|:------------------|:----------------|
;; | 1               | col0–3            | -                 | -                 | -                 | Array1 preloads the first 4×4 weight block. |
;; | 2               | col16–19          | col4–7            | -                 | -                 | Array2 joins with its corresponding weight block. |
;; | 3               | col32–35          | col20–23          | col8–11           | -                 | Array3 starts loading; pipeline warming up. |
;; | 4               | col48–51          | col36–39          | col24–27          | col12–15          | All arrays active, pipeline fully filled. |
;; | 5–61            | continue pattern with +16 column stride per array | same pattern | same pattern | same pattern | Steady-state operation for first tile (xt[0:3]). |
;; | 62              | col64–67          | col52–55          | col40–43          | col28–31          | Array1 preloads next weight block (for xt[4:7]). |
;; | 63              | col80–83          | col68–71          | col56–59          | col44–47          | Array2 switches to next weight block. |
;; | 64              | col96–99          | col84–87          | col72–75          | col60–63          | Array3 switches to next weight block. |
;; | 65–125          | col112–115 → col176–179 | col100–103 → col164–167 | col88–91 → col152–155 | col76–79 → col140–143 | All arrays now operate with new weights (steady state for xt[4:7]). |
;; | 126             | col128–131        | col116–119        | col104–107        | col92–95          | Array1 preloads next (third) weight block (for xt[8:11]). |
;; | 127             | col144–147        | col132–135        | col120–123        | col108–111        | Array2 switches to new weights. |
;; | 128             | col160–163        | col148–151        | col136–139        | col124–127        | Array3 switches to new weights. |
;; | 129–189         | continue pattern with +16 stride per array | same pattern | same pattern | same pattern | All arrays operate with updated weights; cycle repeats every 64 cycles. |

;; > 🔹 Each array fetches one 4×4 column block per cycle.  
;; > 🔹 Column spacing between adjacent arrays = 12 columns (3 blocks).  
;; > 🔹 From Cycle 4 onward, one tile result is produced per cycle.

| **Cycle** | **Array1 Columns**                     | **Array2 Columns**     | **Array3 Columns**     | **Array4 Columns**     | **Description**                                      |
| :-------: | :------------------------------------- | :--------------------- | :--------------------- | :--------------------- | :--------------------------------------------------- |
|   **1**   | col0–3                                 | –                      | –                      | –                      | ARRAY1 preloads first 4×4 block (tile1).             |
|   **2**   | col16–19                               | col4–7                 | –                      | –                      | ARRAY2 begins tile1.                                 |
|   **3**   | col32–35                               | col20–23               | col8–11                | –                      | ARRAY3 begins tile1 (3-cycle stagger).               |
|   **4**   | col48–51                               | col36–39               | col24–27               | col12–15               | ARRAY4 joins; pipeline full.                         |
|  **5–16** | continue +16 stride                    | same                   | same                   | same                   | Steady-state loading of tile1.                       |
|   **17**  | **col256–259 → tile2 row-block start** | col244–247             | col232–235             | col220–223             | **ARRAY1 starts tile2 (row4–7).**                    |
|   **18**  | col272–275                             | **col260–263 → tile2** | col248–251             | col236–239             | **ARRAY2 switches to tile2.**                        |
|   **19**  | col288–291                             | col276–279             | **col264–267 → tile2** | col252–255             | **ARRAY3 switches to tile2.**                        |
|   **20**  | col304–307                             | col292–295             | col280–283             | **col268–271 → tile2** | **ARRAY4 switches to tile2 (tile1 fully consumed).** |
| **21–37** | continue +16 stride                    | same                   | same                   | same                   | Steady-state operation for tile2.                    |
|   **38**  | **next tile (tile3) preload**          | –                      | –                      | –                      | ARRAY1 starts tile3.                                 |
|   **39**  | –                                      | **tile3 preload**      | –                      | –                      | ARRAY2 starts tile3.                                 |
|   **40**  | –                                      | –                      | **tile3 preload**      | –                      | ARRAY3 starts tile3.                                 |
|   **41**  | –                                      | –                      | –                      | **tile3 preload**      | ARRAY4 starts tile3 (3-cycle stagger).               |
| **42–58** | continue +16 stride                    | same                   | same                   | same                   | Steady tile3 operation.                              |

---

## 📈 Column Index Progression  

| **Array** | **Column Start Points** | **Δ (Increment)** |
|:----------|:-----------------------|:------------------|
| Array1 | 0 → 16 → 32 → 48 → 64 | +16 each step |
| Array2 | 4 → 20 → 36 → 52 | +16 each step |
| Array3 | 8 → 24 → 40 | +16 each step |
| Array4 | 12 → 28 | +16 each step |

---

## 🔍 Column Spacing Between Arrays  

| **Cycle** | **Array1→Array2 Δ** | **Array2→Array3 Δ** | **Array3→Array4 Δ** |
|:----------|:--------------------|:--------------------|:--------------------|
| 2 | 16−4 = **12** | - | - |
| 3 | 32−20 = **12** | 20−8 = **12** | - |
| 4 | 48−36 = **12** | 36−24 = **12** | 24−12 = **12** |
| 5 | 64−52 = **12** | 52−40 = **12** | 40−28 = **12** |

> ✅ **Conclusion:**  
> Column spacing between adjacent arrays within the same cycle = **12 columns**.

---

## 🧠 Bank Design Summary  

**Bank Count:**  
N<sub>bank</sub> = n<sub>array</sub> × block_offset  

**Bank Mapping Function:**  
bank_id = (⌊col / 4⌋ + 3 × array_id) mod N<sub>bank</sub>

---
### Conflict-Free Condition

We want the `bank_id` values accessed by the four arrays to be **all different**, i.e.:

for any $n_1 \neq n_2$.

Since `block_id` is fixed within the same cycle, the difference condition becomes:

$$
3(n_1 - n_2) \not\equiv 0 \pmod{N_{\text{bank}}}
$$

That is:

> **The accesses will be conflict-free if and only if the greatest common divisor (GCD) of 3 and $N_{\text{bank}}$ does not divide the total number of arrays (4).**

We therefore need to find the smallest $N_{\text{bank}}$ such that

$$
3(n_1 - n_2) \bmod N_{\text{bank}} \neq 0
$$

for all $n_1, n_2 \in \{0,1,2,3\}$.

---

### Verification Table

| $N_{\text{bank}}$ | Access sequence (for `block_id = 0`) | Conflict-free? |
|:--|:--|:--|
| 4  | (0, 3, 2, 1) | ✅ All distinct, but too short; pattern overlaps when `block_id` increases |
| 6  | (0, 3, 0, 3) | ❌ Repeats |
| 8  | (0, 3, 6, 1) | ❌ Temporal Conflict |
| 9  | (0, 3, 6, 0) | ❌ Repeats |
| **12** | **(0, 3, 6, 9)** | ✅ Perfectly distinct and periodic |

Hence, **12 is the smallest number of banks** that guarantees conflict-free parallel access for four arrays with a stride of 3 blocks between them.
---
## 🧱 Bank–Column Mapping  

| **Bank ID** | **col_block_id (4-column block IDs)** | **Column Range** |
|:-------------|:-------------------------------------|:-----------------|
| **bank0** | 0, 12, 24, 36, 48, 60 | col0–3, 48–51, 96–99, 144–147, 192–195, 240–243 |
| **bank1** | 1, 13, 25, 37, 49, 61 | col4–7, 52–55, 100–103, 148–151, 196–199, 244–247 |
| **bank2** | 2, 14, 26, 38, 50, 62 | col8–11, 56–59, 104–107, 152–155, 200–203, 248–251 |
| **bank3** | 3, 15, 27, 39, 51, 63 | col12–15, 60–63, 108–111, 156–159, 204–207, 252–255 |
| **bank4** | 4, 16, 28, 40, 52 | col16–19, 64–67, 112–115, 160–163, 208–211 |
| **bank5** | 5, 17, 29, 41, 53 | col20–23, 68–71, 116–119, 164–167, 212–215 |
| **bank6** | 6, 18, 30, 42, 54 | col24–27, 72–75, 120–123, 168–171, 216–219 |
| **bank7** | 7, 19, 31, 43, 55 | col28–31, 76–79, 124–127, 172–175, 220–223 |
| **bank8** | 8, 20, 32, 44, 56 | col32–35, 80–83, 128–131, 176–179, 224–227 |
| **bank9** | 9, 21, 33, 45, 57 | col36–39, 84–87, 132–135, 180–183, 228–231 |
| **bank10** | 10, 22, 34, 46, 58 | col40–43, 88–91, 136–139, 184–187, 232–235 |
| **bank11** | 11, 23, 35, 47, 59 | col44–47, 92–95, 140–143, 188–191, 236–239 |

> ✅ Each bank stores every 12th 4×4 column block (stride = 12).  
> ✅ Round-robin distribution guarantees conflict-free parallel reads.

---
##🕓 Timeline + Bank Access Visualization
---
| **Cycle** | **Array1 → bank** | **Array2 → bank** | **Array3 → bank** | **Array4 → bank** | **Banks Active (total)** |
|:----------:|:------------------:|:------------------:|:------------------:|:------------------:|:-------------------------:|
| **1** | bank0 | – | – | – | bank0 |
| **2** | bank4 | bank1 | – | – | bank4, bank1 |
| **3** | bank8 | bank5 | bank2 | – | bank8, bank5, bank2 |
| **4** | bank0 | bank9 | bank6 | bank3 | bank0, bank9, bank6, bank3 |
| **5** | bank4 | bank10 | bank7 | bank1 | bank4, bank10, bank7, bank1 |
| **6** | bank8 | bank11 | bank2 | bank5 | bank8, bank11, bank2, bank5 |
| **7** | bank0 | bank3 | bank6 | bank9 | bank0, bank3, bank6, bank9 |
| **8** | bank4 | bank7 | bank10 | bank1 | bank4, bank7, bank10, bank1 |
| **9** | bank8 | bank11 | bank2 | bank5 | bank8, bank11, bank2, bank5 |
| **10** | bank0 | bank3 | bank6 | bank9 | bank0, bank3, bank6, bank9 |
| **11** | bank4 | bank7 | bank10 | bank1 | bank4, bank7, bank10, bank1 |
| **12** | bank8 | bank11 | bank2 | bank5 | bank8, bank11, bank2, bank5 |

> 🧠 **Interpretation:**
> - Each cycle activates **4 of 12 banks** (one per array).  
> - Pattern repeats every 4 cycles with stride = 3 banks per array.  
> - Guarantees **conflict-free**, full-bandwidth parallel read for all 4 arrays.  
> - From Cycle 4 onward, one 4×4 tile result is produced each cycle.

---
;; ## 🕓 xt Input Scheduling (Revised)  
;; | **Cycle Range** | **Array1** | **Array2** | **Array3** | **Array4** | **Description** |
;; |:----------------|:-----------|:-----------|:-----------|:-----------|:----------------|
;; | 1               | xt[0:3]    | -          | -          | -          | Array1 preloads the initial xt. |
;; | 2               | xt[0:3]    | xt[0:3]    | -          | -          | Array2 joins with the same xt. |
;; | 3               | xt[0:3]    | xt[0:3]    | xt[0:3]    | xt[0:3]    | Array3 and Array4 join, pipeline fully filled. |
;; | 4–61            | xt[0:3]    | xt[0:3]    | xt[0:3]    | xt[0:3]    | All arrays operate with the first xt block (steady state). |
;; | 62              | xt[4:7]    | xt[0:3]    | xt[0:3]    | xt[0:3]    | Array1 preloads the next xt (pipeline transition begins). |
;; | 63              | xt[4:7]    | xt[4:7]    | xt[0:3]    | xt[0:3]    | Array2 switches to the new xt. |
;; | 64              | xt[4:7]    | xt[4:7]    | xt[4:7]    | xt[0:3]    | Array3 switches to the new xt. |
;; | 65–125          | xt[4:7]    | xt[4:7]    | xt[4:7]    | xt[4:7]    | All arrays now operate with the second xt block (steady state). |
;; | 126             | xt[8:11]   | xt[4:7]    | xt[4:7]    | xt[4:7]    | Array1 preloads the next xt block. |
;; | 127             | xt[8:11]   | xt[8:11]   | xt[4:7]    | xt[4:7]    | Array2 switches to the new xt block. |
;; | 128             | xt[8:11]   | xt[8:11]   | xt[8:11]   | xt[4:7]    | Array3 switches to the new xt block; pipeline transition repeats every 64 cycles. |
;; ---

;; ### 🧾 Notes
;; - Each 4×4 block = 16 weights (aligned with MAC array width).  
;; - 12-bank mapping ensures **conflict-free** parallel access for 4 arrays.  
;; - Mapping function `(col_blk + 3×array_id) % 12` provides even bank utilization.  
;; - Proper **bank interleaving** is key to achieving simultaneous row-and-column fetching.

| **Cycle** | **Array1**   | **Array2**   | **Array3**   | **Array4**   | **Description**                           |
| :-------: | :----------- | :----------- | :----------- | :----------- | :---------------------------------------- |
|   **1**   | xt[0:3]      | –            | –            | –            | ARRAY1 begins tile1 (xt block0).          |
|   **2**   | xt[0:3]      | xt[0:3]      | –            | –            | ARRAY2 joins tile1.                       |
|   **3**   | xt[0:3]      | xt[0:3]      | xt[0:3]      | –            | ARRAY3 joins tile1.                       |
|   **4**   | xt[0:3]      | xt[0:3]      | xt[0:3]      | xt[0:3]      | ARRAY4 joins tile1; steady begins.        |
|  **5–16** | xt[0:3]      | xt[0:3]      | xt[0:3]      | xt[0:3]      | tile1 steady-state.                       |
|   **17**  | **xt[4:7]**  | xt[0:3]      | xt[0:3]      | xt[0:3]      | **ARRAY1 starts tile2 (next row-block).** |
|   **18**  | xt[4:7]      | **xt[4:7]**  | xt[0:3]      | xt[0:3]      | **ARRAY2 switches to tile2.**             |
|   **19**  | xt[4:7]      | xt[4:7]      | **xt[4:7]**  | xt[0:3]      | **ARRAY3 switches to tile2.**             |
|   **20**  | xt[4:7]      | xt[4:7]      | xt[4:7]      | **xt[4:7]**  | **ARRAY4 switches; tile1 finishes.**      |
| **21–33** | xt[4:7]      | xt[4:7]      | xt[4:7]      | xt[4:7]      | tile2 steady-state.                       |
|   **34**  | **xt[8:11]** | xt[4:7]      | xt[4:7]      | xt[4:7]      | ARRAY1 starts tile3.                      |
|   **35**  | xt[8:11]     | **xt[8:11]** | xt[4:7]      | xt[4:7]      | ARRAY2 switches.                          |
|   **36**  | xt[8:11]     | xt[8:11]     | **xt[8:11]** | xt[4:7]      | ARRAY3 switches.                          |
|   **37**  | xt[8:11]     | xt[8:11]     | xt[8:11]     | **xt[8:11]** | ARRAY4 switches; tile2 ends.              |
