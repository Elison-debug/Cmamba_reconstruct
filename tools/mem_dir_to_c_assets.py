import argparse
from pathlib import Path


def sanitize_symbol(name: str) -> str:
    out = []
    for ch in name:
        if ch.isalnum() or ch == "_":
            out.append(ch)
        else:
            out.append("_")
    sym = "".join(out)
    if not sym:
        sym = "data"
    if sym[0].isdigit():
        sym = "_" + sym
    return sym


def strip_line(raw: str) -> str:
    line = raw.strip()
    if not line:
        return ""
    if "//" in line:
        line = line.split("//", 1)[0].strip()
    if "#" in line:
        line = line.split("#", 1)[0].strip()
    if line.lower().startswith("0x"):
        line = line[2:]
    return line.strip()


def collect_mem_files(root: Path):
    return sorted([p for p in root.rglob("*.mem") if p.is_file()])


def relative_symbol(root: Path, mem_path: Path):
    rel = mem_path.relative_to(root)
    rel_no_suffix = rel.with_suffix("")
    parts = [sanitize_symbol(p) for p in rel_no_suffix.parts]
    return sanitize_symbol("_".join(parts) + "_mem")


def parse_mem_file(mem_path: Path):
    """
    返回:
      {
        "mode": "u64" or "bytes",
        "lines": [clean hex string per line],
        "u64_values": [...],      # only for mode=u64
        "byte_values": [...],     # only for mode=bytes
        "line_count": int,
        "max_hex_len": int,
        "bytes_per_line": int or 0,
      }
    """
    clean_lines = []
    max_hex_len = 0

    with mem_path.open("r", encoding="utf-8") as f:
        for lineno, raw in enumerate(f, 1):
            line = strip_line(raw)
            if not line:
                continue

            # 必须是纯 hex
            try:
                int(line, 16)
            except ValueError:
                raise ValueError(f"{mem_path}:{lineno} 非法十六进制数据: {raw.rstrip()}")

            clean_lines.append(line)
            max_hex_len = max(max_hex_len, len(line))

    if not clean_lines:
        return {
            "mode": "u64",
            "lines": [],
            "u64_values": [],
            "byte_values": [],
            "line_count": 0,
            "max_hex_len": 0,
            "bytes_per_line": 0,
        }

    if max_hex_len <= 16:
        u64_values = [int(line, 16) for line in clean_lines]
        return {
            "mode": "u64",
            "lines": clean_lines,
            "u64_values": u64_values,
            "byte_values": [],
            "line_count": len(clean_lines),
            "max_hex_len": max_hex_len,
            "bytes_per_line": 8,
        }

    # 否则按 raw bytes 存，每行保留自己的宽度
    byte_values = []
    bytes_per_line = None

    for line in clean_lines:
        # 如果是奇数个 hex，前面补 0
        if len(line) % 2 == 1:
            line = "0" + line

        line_bytes = bytes.fromhex(line)
        byte_values.extend(line_bytes)

        if bytes_per_line is None:
            bytes_per_line = len(line_bytes)
        elif bytes_per_line != len(line_bytes):
            # 如果每行宽度不一致，也允许，但记成 0 表示不固定
            bytes_per_line = 0

    return {
        "mode": "bytes",
        "lines": clean_lines,
        "u64_values": [],
        "byte_values": byte_values,
        "line_count": len(clean_lines),
        "max_hex_len": max_hex_len,
        "bytes_per_line": bytes_per_line if bytes_per_line is not None else 0,
    }


def format_u64_values(values, per_line=4):
    lines = []
    row = []
    for i, v in enumerate(values):
        row.append(f"0x{v:016X}ULL")
        if len(row) == per_line or i == len(values) - 1:
            lines.append("    " + ", ".join(row))
            row = []
    return ",\n".join(lines)


def format_u8_values(values, per_line=16):
    lines = []
    row = []
    for i, v in enumerate(values):
        row.append(f"0x{v:02X}")
        if len(row) == per_line or i == len(values) - 1:
            lines.append("    " + ", ".join(row))
            row = []
    return ",\n".join(lines)


def generate_header(out_h: Path, assets):
    guard = sanitize_symbol(out_h.stem.upper()) + "_H"

    lines = []
    lines.append(f"#ifndef {guard}")
    lines.append(f"#define {guard}")
    lines.append("")
    lines.append("#include <stdint.h>")
    lines.append("")
    lines.append("typedef enum {")
    lines.append("    MEM_ASSET_U64 = 0,")
    lines.append("    MEM_ASSET_BYTES = 1")
    lines.append("} mem_asset_kind_t;")
    lines.append("")
    lines.append("typedef struct {")
    lines.append("    const char *name;")
    lines.append("    mem_asset_kind_t kind;")
    lines.append("    const void *data;")
    lines.append("    uint32_t count;          /* u64元素个数或byte个数 */")
    lines.append("    uint32_t line_count;")
    lines.append("    uint32_t max_hex_len;")
    lines.append("    uint32_t bytes_per_line; /* 仅对BYTES模式有意义，0表示不固定 */")
    lines.append("} mem_asset_t;")
    lines.append("")

    for asset in assets:
        if asset["mode"] == "u64":
            lines.append(f"extern const uint64_t {asset['symbol']}[];")
            lines.append(f"extern const uint32_t {asset['symbol']}_len;")
        else:
            lines.append(f"extern const uint8_t {asset['symbol']}[];")
            lines.append(f"extern const uint32_t {asset['symbol']}_len;")
        lines.append("")

    lines.append("extern const mem_asset_t g_mem_assets[];")
    lines.append("extern const uint32_t g_mem_assets_count;")
    lines.append("")
    lines.append("#endif")

    out_h.write_text("\n".join(lines) + "\n", encoding="utf-8")


def generate_source(out_c: Path, header_name: str, assets):
    lines = []
    lines.append(f'#include "{header_name}"')
    lines.append("")

    for asset in assets:
        lines.append(f"/* Source: {asset['relpath']} */")
        if asset["mode"] == "u64":
            lines.append(f"const uint64_t {asset['symbol']}[] = {{")
            if asset["u64_values"]:
                lines.append(format_u64_values(asset["u64_values"]))
            lines.append("};")
            lines.append(f"const uint32_t {asset['symbol']}_len = {len(asset['u64_values'])}U;")
        else:
            lines.append(f"const uint8_t {asset['symbol']}[] = {{")
            if asset["byte_values"]:
                lines.append(format_u8_values(asset["byte_values"]))
            lines.append("};")
            lines.append(f"const uint32_t {asset['symbol']}_len = {len(asset['byte_values'])}U;")
        lines.append("")

    lines.append("const mem_asset_t g_mem_assets[] = {")
    for asset in assets:
        kind = "MEM_ASSET_U64" if asset["mode"] == "u64" else "MEM_ASSET_BYTES"
        count = len(asset["u64_values"]) if asset["mode"] == "u64" else len(asset["byte_values"])
        lines.append(
            f'    {{"{asset["relpath"]}", {kind}, {asset["symbol"]}, '
            f'{count}U, {asset["line_count"]}U, {asset["max_hex_len"]}U, {asset["bytes_per_line"]}U}},'
        )
    lines.append("};")
    lines.append("")
    lines.append(f"const uint32_t g_mem_assets_count = {len(assets)}U;")

    out_c.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main():
    parser = argparse.ArgumentParser(description="Recursively convert all .mem files under a directory into one C asset file")
    parser.add_argument("root", help="root directory to scan recursively")
    parser.add_argument("-o", "--outdir", default="generated", help="output directory")
    parser.add_argument("--header", default="mem_assets.h", help="output header file name")
    parser.add_argument("--source", default="mem_assets.c", help="output source file name")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    outdir = Path(args.outdir).resolve()
    outdir.mkdir(parents=True, exist_ok=True)

    if not root.exists() or not root.is_dir():
        raise NotADirectoryError(f"输入目录不存在或不是目录: {root}")

    mem_files = collect_mem_files(root)
    if not mem_files:
        raise FileNotFoundError(f"目录下未找到任何 .mem 文件: {root}")

    assets = []
    seen_symbols = set()

    for mem_path in mem_files:
        parsed = parse_mem_file(mem_path)
        relpath = mem_path.relative_to(root).as_posix()
        symbol = relative_symbol(root, mem_path)

        if symbol in seen_symbols:
            raise ValueError(f"符号名冲突: {symbol} <- {relpath}")
        seen_symbols.add(symbol)

        assets.append({
            "path": mem_path,
            "relpath": relpath,
            "symbol": symbol,
            **parsed,
        })

    out_h = outdir / args.header
    out_c = outdir / args.source

    generate_header(out_h, assets)
    generate_source(out_c, out_h.name, assets)

    print(f"扫描目录: {root}")
    print(f"找到 .mem 文件数: {len(assets)}")
    print(f"输出头文件: {out_h}")
    print(f"输出源文件: {out_c}")
    print("")
    print("前10个文件：")
    for asset in assets[:10]:
        if asset["mode"] == "u64":
            count = len(asset["u64_values"])
        else:
            count = len(asset["byte_values"])
        print(
            f"  {asset['relpath']} -> {asset['symbol']} "
            f"[mode={asset['mode']}, count={count}, line_count={asset['line_count']}, max_hex_len={asset['max_hex_len']}]"
        )


if __name__ == "__main__":
    main()