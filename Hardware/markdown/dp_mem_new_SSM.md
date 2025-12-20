# 🧱 Bank–Column Mapping (Nbank = 6), for SlimMamba(256,256)

| **Bank ID** | **tile_id (4×4 block IDs)** | **Count**     |
| ----------- | --------------------------- | ------------- |
| **bank0**   | 0, 6, 12, …, **4092**       | **683 tiles** |
| **bank1**   | 1, 7, 13, …, **4093**       | **683 tiles** |
| **bank2**   | 2, 8, 14, …, **4094**       | **683 tiles** |
| **bank3**   | 3, 9, 15, …, **4095**       | **683 tiles** |
| **bank4**   | 4, 10, 16, …, **4090**      | **682 tiles** |
| **bank5**   | 5, 11, 17, …, **4091**      | **682 tiles** |

# 🕓 Timeline + Bank Access Visualization (Nbank = 6), for SlimMamba(256,256)

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