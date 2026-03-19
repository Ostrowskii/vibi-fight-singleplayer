#!/usr/bin/env python3

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIGHT_PATH = ROOT / "src" / "shared" / "fight" / "_.bend"
OUT_DIR = ROOT / "assets" / "skills"

CELL_BITS = {
    "cell_attack": 1,
    "cell_dist_attack": 1,
    "cell_hook": 2,
    "cell_ice": 4,
    "cell_fire": 8,
    "cell_player": 16,
}

COLORS = {
    "anchor": ("#58d8e8", None),
    "attack": ("#ddb151", None),
    "hook": ("#9ff25e", None),
    "ice": ("#70aee4", None),
    "fire": ("#df8d39", None),
    "attack_hook": ("#d94933", "#9ff25e"),
    "attack_ice": ("#d94933", "#70aee4"),
    "attack_fire": ("#d94933", "#df8d39"),
}


def extract_block(source: str, name: str) -> str:
    pattern = rf"^def {re.escape(name)}\([^\n]*\) -> [^:]+:\n(.*?)(?=^def |\Z)"
    match = re.search(pattern, source, re.MULTILINE | re.DOTALL)
    if not match:
        raise RuntimeError(f"Could not find block for {name}")
    return match.group(1)


def parse_single_value_cases(block: str) -> dict[int, str]:
    result: dict[int, str] = {}
    current: int | None = None
    for line in block.splitlines():
        stripped = line.strip()
        case_match = re.match(r"case (\d+):", stripped)
        if case_match:
            current = int(case_match.group(1))
            continue
        if current is not None and stripped and not stripped.startswith("case "):
            result[current] = stripped.strip('"')
            current = None
    return result


def parse_single_u32_cases(block: str) -> dict[int, int]:
    raw = parse_single_value_cases(block)
    return {key: int(value) for key, value in raw.items()}


def parse_base_cells(block: str) -> dict[tuple[int, int, int], int]:
    result: dict[tuple[int, int, int], int] = {}
    current: tuple[int, int, int] | None = None
    for line in block.splitlines():
        stripped = line.strip()
        case_match = re.match(r"case (\d+) (\d+) (\d+):", stripped)
        if case_match:
            current = tuple(int(case_match.group(i)) for i in range(1, 4))  # type: ignore[assignment]
            continue
        if current is not None and stripped and not stripped.startswith("case "):
            bits = 0
            for token in re.findall(r"(cell_[a-z_]+)\(\)", stripped):
                bits |= CELL_BITS[token]
            result[current] = bits
            current = None
    return result


def cell_style(mask: int) -> tuple[str, str | None]:
    has_attack = bool(mask & 1)
    has_hook = bool(mask & 2)
    has_ice = bool(mask & 4)
    has_fire = bool(mask & 8)
    has_player = bool(mask & 16)

    if has_player:
        return COLORS["anchor"]
    if has_attack and has_hook:
        return COLORS["attack_hook"]
    if has_attack and has_ice:
        return COLORS["attack_ice"]
    if has_attack and has_fire:
        return COLORS["attack_fire"]
    if has_attack:
        return COLORS["attack"]
    if has_hook:
        return COLORS["hook"]
    if has_ice:
        return COLORS["ice"]
    if has_fire:
        return COLORS["fire"]
    return ("#f8efd7", None)


def build_svg(name: str, width: int, height: int, cells: dict[tuple[int, int], int]) -> str:
    occupied = [(x, y) for (x, y), mask in cells.items() if mask]
    if not occupied:
        return (
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" '
            'role="img" aria-label="Skill vazia"></svg>\n'
        )

    min_x = min(x for x, _ in occupied)
    max_x = max(x for x, _ in occupied)
    min_y = min(y for _, y in occupied)
    max_y = max(y for _, y in occupied)
    trim_w = max_x - min_x + 1
    trim_h = max_y - min_y + 1

    canvas = 64
    padding = 4
    gap = 1
    max_dim = max(trim_w, trim_h)
    cell = max(2, (canvas - (padding * 2) - (gap * (max_dim - 1))) // max_dim)
    real_w = trim_w * cell + (trim_w - 1) * gap
    real_h = trim_h * cell + (trim_h - 1) * gap
    offset_x = (canvas - real_w) // 2
    offset_y = (canvas - real_h) // 2

    parts = [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64" '
        f'role="img" aria-label="{name}">',
        f'<title>{name}</title>',
    ]

    for y in range(trim_h):
        for x in range(trim_w):
            mask = cells.get((x + min_x, y + min_y), 0)
            if not mask:
                continue
            fill, stroke = cell_style(mask)
            px = offset_x + x * (cell + gap)
            py = offset_y + y * (cell + gap)
            attrs = [
                f'x="{px}"',
                f'y="{py}"',
                f'width="{cell}"',
                f'height="{cell}"',
                f'fill="{fill}"',
            ]
            if stroke:
                attrs.append(f'stroke="{stroke}"')
                attrs.append('stroke-width="2"')
            parts.append(f"<rect {' '.join(attrs)} rx=\"1\" ry=\"1\" />")

    parts.append("</svg>")
    return "\n".join(parts) + "\n"


def main() -> None:
    source = FIGHT_PATH.read_text()
    names = parse_single_value_cases(extract_block(source, "skill_name"))
    widths = parse_single_u32_cases(extract_block(source, "skill_base_w"))
    heights = parse_single_u32_cases(extract_block(source, "skill_base_h"))
    base_cells = parse_base_cells(extract_block(source, "skill_base_cell"))

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    for skill_id, name in sorted(names.items()):
        width = widths[skill_id]
        height = heights[skill_id]
        cells: dict[tuple[int, int], int] = {}
        for y in range(height):
            for x in range(width):
                cells[(x, y)] = base_cells.get((skill_id, y, x), 0)
        svg = build_svg(name, width, height, cells)
        (OUT_DIR / f"{name}.svg").write_text(svg)


if __name__ == "__main__":
    main()
