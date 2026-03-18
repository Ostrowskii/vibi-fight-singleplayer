#!/usr/bin/env python3

from __future__ import annotations

import re
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIGHT_PATH = ROOT / "src" / "shared" / "fight" / "_.bend"
OUT_PATH = ROOT / "src" / "shared" / "fight" / "generated_skill_ai_consts.bend"

PRIMARY_TOKENS = {"cell_player", "cell_attack", "cell_dist_attack"}
REMOTE_TOKENS = {"cell_dist_attack", "cell_ice", "cell_fire"}


@dataclass(frozen=True)
class Point:
    x: int
    y: int


@dataclass(frozen=True)
class Delta:
    x_neg: int
    x_mag: int
    y_neg: int
    y_mag: int


@dataclass(frozen=True)
class AreaBox:
    x1: int
    y1: int
    x2: int
    y2: int


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


def parse_base_cell_tokens(block: str) -> dict[tuple[int, int, int], tuple[str, ...]]:
    result: dict[tuple[int, int, int], tuple[str, ...]] = {}
    current: tuple[int, int, int] | None = None
    for line in block.splitlines():
        stripped = line.strip()
        case_match = re.match(r"case (\d+) (\d+) (\d+):", stripped)
        if case_match:
            current = tuple(int(case_match.group(i)) for i in range(1, 4))  # type: ignore[assignment]
            continue
        if current is not None and stripped and not stripped.startswith("case "):
            tokens = tuple(re.findall(r"(cell_[a-z_]+)\(\)", stripped))
            result[current] = tokens
            current = None
    return result


def to_delta(a: Point, b: Point) -> Delta:
    dx = a.x - b.x
    dy = a.y - b.y
    return Delta(1 if dx < 0 else 0, abs(dx), 1 if dy < 0 else 0, abs(dy))


def pick_top_right(points: list[Point]) -> Point:
    return min(points, key=lambda p: (p.y, -p.x))


def pick_bottom_right(points: list[Point]) -> Point:
    return max(points, key=lambda p: (p.y, p.x))


def pick_top_left(points: list[Point]) -> Point:
    return min(points, key=lambda p: (p.y, p.x))


def pick_bottom_left(points: list[Point]) -> Point:
    return max(points, key=lambda p: (p.y, -p.x))


def row_groups(points: list[Point]) -> dict[int, list[Point]]:
    out: dict[int, list[Point]] = {}
    for point in points:
        out.setdefault(point.y, []).append(point)
    return out


def emit_case_u32(name: str, values: dict[int, int], default: str = "0") -> str:
    lines = [f"def {name}(skill: U32) -> U32:", "  match skill:"]
    for skill in sorted(values):
        lines.append(f"    case {skill}:")
        lines.append(f"      {values[skill]}")
    lines.append("    case _:")
    lines.append(f"      {default}")
    return "\n".join(lines) + "\n"


def emit_case_delta(name: str, values: dict[int, Delta]) -> str:
    lines = [f"def {name}(skill: U32) -> DeltaPos:", "  match skill:"]
    for skill in sorted(values):
        value = values[skill]
        lines.append(f"    case {skill}:")
        lines.append(
            "      delta_pos{"
            f"{value.x_neg}, {value.x_mag}, {value.y_neg}, {value.y_mag}"
            "}"
        )
    lines.append("    case _:")
    lines.append("      delta_pos{0, 0, 0, 0}")
    return "\n".join(lines) + "\n"


def emit_case_area(name: str, values: dict[int, AreaBox]) -> str:
    lines = [f"def {name}(skill: U32) -> AreaBox:", "  match skill:"]
    for skill in sorted(values):
        value = values[skill]
        lines.append(f"    case {skill}:")
        lines.append(f"      area_box{{{value.x1}, {value.y1}, {value.x2}, {value.y2}}}")
    lines.append("    case _:")
    lines.append("      area_box{0, 0, 0, 0}")
    return "\n".join(lines) + "\n"


def emit_case_point_count(name: str, values: dict[int, list[Point]]) -> str:
    return emit_case_u32(name, {skill: len(points) for skill, points in values.items()})


def emit_case_point_axis(name: str, values: dict[int, list[Point]], axis: str) -> str:
    lines = [f"def {name}(skill: U32, idx: U32) -> U32:", "  match skill idx:"]
    for skill in sorted(values):
        points = values[skill]
        for idx, point in enumerate(points):
            value = point.x if axis == "x" else point.y
            lines.append(f"    case {skill} {idx}:")
            lines.append(f"      {value}")
    lines.append("    case _ _:")
    lines.append("      0")
    return "\n".join(lines) + "\n"


def main() -> None:
    source = FIGHT_PATH.read_text()
    names = parse_single_value_cases(extract_block(source, "skill_name"))
    widths = parse_single_u32_cases(extract_block(source, "skill_base_w"))
    heights = parse_single_u32_cases(extract_block(source, "skill_base_h"))
    base_cells = parse_base_cell_tokens(extract_block(source, "skill_base_cell"))

    has_anchor_consts: dict[int, int] = {}
    diag1: dict[int, Delta] = {}
    diag2: dict[int, Delta] = {}
    right_min_diff: dict[int, int] = {}
    right_min_positions: dict[int, list[Point]] = {}
    left_max_diff: dict[int, int] = {}
    left_max_positions: dict[int, list[Point]] = {}
    areas: dict[int, AreaBox] = {}

    for skill_id in sorted(names):
        width = widths[skill_id]
        height = heights[skill_id]
        cells: dict[tuple[int, int], tuple[str, ...]] = {}
        for y in range(height):
            for x in range(width):
                cells[(x, y)] = base_cells.get((skill_id, y, x), ())

        points_p: list[Point] = []
        points_remote: list[Point] = []
        occupied: list[Point] = []
        has_attack = False
        has_dist_attack = False

        for (x, y), tokens in cells.items():
            if not tokens:
                continue
            occupied.append(Point(x, y))
            primary_count = sum(1 for token in tokens if token in PRIMARY_TOKENS)
            if primary_count > 1:
                raise RuntimeError(
                    f"{names[skill_id]} has an invalid tile at ({x}, {y}) mixing A/D/P"
                )
            if "cell_player" in tokens:
                points_p.append(Point(x, y))
            if "cell_attack" in tokens:
                has_attack = True
            if "cell_dist_attack" in tokens:
                has_dist_attack = True
            if any(token in REMOTE_TOKENS for token in tokens):
                points_remote.append(Point(x, y))

        has_p = bool(points_p)
        has_anchor_consts[skill_id] = 1 if has_p else 0

        if has_p and has_attack:
            raise RuntimeError(f"{names[skill_id]} has P and A in the same skill")
        if has_dist_attack and not has_p:
            raise RuntimeError(f"{names[skill_id]} has D but no P")

        if not has_p:
            diag1[skill_id] = Delta(0, 0, 0, 0)
            diag2[skill_id] = Delta(0, 0, 0, 0)
            right_min_diff[skill_id] = 0
            right_min_positions[skill_id] = []
            left_max_diff[skill_id] = 0
            left_max_positions[skill_id] = []
            min_x = min(point.x for point in occupied)
            min_y = min(point.y for point in occupied)
            max_x = max(point.x for point in occupied)
            max_y = max(point.y for point in occupied)
            areas[skill_id] = AreaBox(min_x, min_y, max_x, max_y)
            continue

        if not points_remote:
            raise RuntimeError(f"{names[skill_id]} has P but no D/I/F tiles")

        p_top = pick_top_right(points_p)
        p_bottom = pick_bottom_right(points_p)
        remote_bottom = pick_bottom_left(points_remote)
        remote_top = pick_top_left(points_remote)

        diag1[skill_id] = to_delta(p_top, remote_bottom)
        diag2[skill_id] = to_delta(p_bottom, remote_top)

        p_by_row = row_groups(points_p)
        remote_by_row = row_groups(points_remote)

        right_row_candidates: list[tuple[int, Point]] = []
        left_row_candidates: list[tuple[int, Point, Point]] = []

        for row, p_row in p_by_row.items():
            remote_row = remote_by_row.get(row)
            if not remote_row:
                continue

            right_p = max(p_row, key=lambda point: point.x)
            first_remote = min(remote_row, key=lambda point: point.x)
            right_row_candidates.append((abs(first_remote.x - right_p.x), right_p))

            left_p = min(p_row, key=lambda point: point.x)
            last_remote = max(remote_row, key=lambda point: point.x)
            left_row_candidates.append((abs(last_remote.x - left_p.x), left_p, last_remote))

        if right_row_candidates:
            min_diff = min(diff for diff, _ in right_row_candidates)
            right_min_diff[skill_id] = min_diff
            right_min_positions[skill_id] = sorted(
                [point for diff, point in right_row_candidates if diff == min_diff],
                key=lambda point: (point.y, point.x),
            )
        else:
            right_min_diff[skill_id] = 0
            right_min_positions[skill_id] = []

        if left_row_candidates:
            max_diff = max(diff for diff, _, _ in left_row_candidates)
            selected = [(point, remote) for diff, point, remote in left_row_candidates if diff == max_diff]
            left_max_diff[skill_id] = max_diff
            left_max_positions[skill_id] = sorted(
                [point for point, _ in selected],
                key=lambda point: (point.y, point.x),
            )
            chosen_point, chosen_remote = selected[0]
            x2 = chosen_remote.x
        else:
            left_max_diff[skill_id] = 0
            left_max_positions[skill_id] = []
            x2 = max(point.x for point in occupied)

        x1 = min(remote_bottom.x, remote_top.x)
        y1 = min(remote_bottom.y, remote_top.y)
        y2 = max(remote_bottom.y, remote_top.y)
        areas[skill_id] = AreaBox(x1, y1, x2, y2)

    output = """import /U32/ as U32

type DeltaPos {
  delta_pos{x_neg: U32, x_mag: U32, y_neg: U32, y_mag: U32}
}

type AreaBox {
  area_box{x1: U32, y1: U32, x2: U32, y2: U32}
}

"""
    output += emit_case_u32("skill_has_anchor_consts", has_anchor_consts)
    output += "\n"
    output += emit_case_delta("skill_delta_diag_top_left_down_right", diag1)
    output += "\n"
    output += emit_case_delta("skill_delta_diag_down_left_top_right", diag2)
    output += "\n"
    output += emit_case_u32("skill_same_row_right_min_diff", right_min_diff)
    output += "\n"
    output += emit_case_point_count("skill_same_row_right_min_pos_count", right_min_positions)
    output += "\n"
    output += emit_case_point_axis("skill_same_row_right_min_pos_x", right_min_positions, "x")
    output += "\n"
    output += emit_case_point_axis("skill_same_row_right_min_pos_y", right_min_positions, "y")
    output += "\n"
    output += emit_case_u32("skill_same_row_left_max_diff", left_max_diff)
    output += "\n"
    output += emit_case_point_count("skill_same_row_left_max_pos_count", left_max_positions)
    output += "\n"
    output += emit_case_point_axis("skill_same_row_left_max_pos_x", left_max_positions, "x")
    output += "\n"
    output += emit_case_point_axis("skill_same_row_left_max_pos_y", left_max_positions, "y")
    output += "\n"
    output += emit_case_area("skill_use_area", areas)

    OUT_PATH.write_text(output)


if __name__ == "__main__":
    main()
