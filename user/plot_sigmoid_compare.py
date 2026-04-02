# plot_sigmoid_compare.py
import csv
import math
import re

LOG = r"""
[19000] SEND idx=0  in_q88=256,0,-256,-768
[29000] OUT  got=bb27,8000,44d9,0c24  exp=bb27,8000,44d9,0c24
[31000] SEND idx=1  in_q88=512,128,-128,-512
[37000] OUT  got=e17c,9f59,60a7,1e84  exp=e17c,9f59,60a7,1e84
[39000] SEND idx=2  in_q88=1023,512,-512,-1024
[45000] OUT  got=fb61,e17c,1e84,049b  exp=fb61,e17c,1e84,049b
[47000] SEND idx=3  in_q88=0,0,0,0
[53000] OUT  got=8000,8000,8000,8000  exp=8000,8000,8000,8000
[55000] SEND idx=4  in_q88=256,256,256,256
[61000] OUT  got=bb27,bb27,bb27,bb27  exp=bb27,bb27,bb27,bb27
[63000] SEND idx=5  in_q88=-256,-256,-256,-256
[69000] OUT  got=44d9,44d9,44d9,44d9  exp=44d9,44d9,44d9,44d9
[71000] SEND idx=6  in_q88=128,256,512,768
[77000] OUT  got=9f59,bb27,e17c,f3dc  exp=9f59,bb27,e17c,f3dc
[79000] SEND idx=7  in_q88=-128,-256,-512,-768
[85000] OUT  got=60a7,44d9,1e84,0c24  exp=60a7,44d9,1e84,0c24
[87000] SEND idx=8  in_q88=-15000,15000,-20000,20000
[93000] OUT  got=049b,fb61,049b,fb61  exp=049b,fb61,049b,fb61
[95000] SEND idx=9  in_q88=1,0,30000,-30000
[101000] OUT  got=8040,8000,fb61,049b  exp=8040,8000,fb61,049b
[103000] SEND idx=10  in_q88=-1023,-1024,1022,1023
[115000] OUT  got=049f,049b,fb5c,fb61  exp=049f,049b,fb5c,fb61
[117000] SEND idx=11  in_q88=-900,-700,350,600
[123000] OUT  got=0764,0f9c,cc03,e995  exp=0764,0f9c,cc03,e995
"""

def sigmoid(x):
    return 1.0 / (1.0 + math.exp(-x))

def q016(x):
    return int(round(x * 65536))

def clamp_q88_to_float(x_q88):
    x = x_q88 / 256.0
    if x < -4.0:
        return -4.0
    if x >= 4.0:
        return 1023 / 256.0  # 3.99609375
    return x

# parse
send_re = re.compile(r"SEND idx=\d+\s+in_q88=([-\d,]+)")
out_re = re.compile(r"OUT\s+got=([0-9a-fA-F,]+)")

in_list = []
got_list = []

for line in LOG.strip().splitlines():
    m = send_re.search(line)
    if m:
        in_list.extend(int(x) for x in m.group(1).split(","))
    m = out_re.search(line)
    if m:
        got_list.extend(int(x, 16) for x in m.group(1).split(","))

assert len(in_list) == len(got_list), "input/output length mismatch"

# compute
xs = [clamp_q88_to_float(xq) for xq in in_list]
y_true = [sigmoid(x) for x in xs]
y_hw = [yq / 65536.0 for yq in got_list]

# write CSV
with open("sigmoid_compare.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(
        ["x_q88", "x_float", "x_clamp", "hw_q016", "hw_float", "true_float", "true_q016", "err_q016"]
    )
    for xq, x, xcl, yq, yh, yt in zip(in_list, [v/256.0 for v in in_list], xs, got_list, y_hw, y_true):
        writer.writerow(
            [xq, f"{x:.6f}", f"{xcl:.6f}", f"0x{yq:04x}", f"{yh:.6f}", f"{yt:.6f}", q016(yt), yq - q016(yt)]
        )

print("Saved: sigmoid_compare.csv")
