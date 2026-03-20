#!/usr/bin/env python3

from __future__ import annotations

import argparse
import html
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlencode


ROOT = Path(__file__).resolve().parents[1]
FIGHT_HTML = ROOT / "fight" / "index.html"
RESULT_RE = re.compile(
    r'<script id="vibi-sim-result" type="application/json">(.*?)</script>',
    re.DOTALL,
)

SKILLS = {
    1: "Me1",
    2: "Me2",
    3: "Me3",
    4: "Me4",
    5: "Ma1",
    6: "Ma2",
    7: "Me5",
    8: "Ra1",
    9: "Ma3",
    10: "Ra2",
    11: "Ra3",
    12: "Ra4",
    13: "Ra5",
    14: "Me6",
    15: "Me7",
    16: "Me8",
    17: "Me10",
    18: "Me11",
    19: "Me12",
    20: "Me13",
    21: "Ra6",
    22: "Ra7",
    23: "Ra8",
    24: "Ra9",
    25: "Ra10",
    26: "Ra11",
    27: "Ma4",
    28: "Ma5",
    29: "Ma6",
    30: "Ma7",
    31: "Ma8",
    32: "Ma9",
    33: "Ma10",
    34: "Me0",
}

# Lethal skills in the current ruleset: direct damage or fire that can end fights.
ELIGIBLE_SKILL_IDS = [
    1, 2, 3, 4, 6, 8, 10, 11, 12, 13, 14, 15,
    16, 17, 18, 19, 20,
    34,
    21, 22, 23, 24, 25, 26,
    27, 28, 29, 30, 31, 32, 33,
]
DEFAULT_ROUND_CAP = 40


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Run AI-vs-AI skill matchups through the fight runtime.",
    )
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--skill", help="Run one skill against all eligible skills, e.g. Me1")
    group.add_argument(
        "--duel",
        nargs=2,
        metavar=("PLAYER_SKILL", "BOT_SKILL"),
        help="Run a single duel, e.g. --duel Me1 Ra3",
    )
    parser.add_argument(
        "--json-out",
        help="Write the detailed report to this JSON path.",
    )
    parser.add_argument(
        "--round-cap",
        type=int,
        default=DEFAULT_ROUND_CAP,
        help=f"Round cap for the technical sim mode (default: {DEFAULT_ROUND_CAP}).",
    )
    parser.add_argument(
        "--chrome-bin",
        help="Path to a Chrome/Chromium binary. Defaults to auto-detect.",
    )
    return parser.parse_args()


def detect_chrome(explicit: str | None) -> str:
    if explicit:
        return explicit
    for name in ("google-chrome", "google-chrome-stable", "chromium", "chromium-browser"):
        path = shutil.which(name)
        if path:
            return path
    raise SystemExit("chrome binary not found; pass --chrome-bin")


def normalize_skill_name(name: str) -> str:
    return name.strip().lower()


def skill_id_from_name(name: str) -> int:
    wanted = normalize_skill_name(name)
    for skill_id, skill_name in SKILLS.items():
        if normalize_skill_name(skill_name) == wanted:
            return skill_id
    raise SystemExit(f"unknown skill: {name}")


def skill_name(skill_id: int) -> str:
    return SKILLS[skill_id]


def fight_url(player_skill: int, bot_skill: int, round_cap: int) -> str:
    params = urlencode(
        {
            "sim": "botvbot",
            "simcap": str(round_cap),
            "ps1": str(player_skill),
            "ps2": "0",
            "ps3": "0",
            "bs1": str(bot_skill),
            "bs2": "0",
            "bs3": "0",
        }
    )
    return f"{FIGHT_HTML.resolve().as_uri()}?{params}"


def virtual_time_budget_ms(round_cap: int) -> int:
    return max(12_000, int(round_cap) * 1_200)


def extract_result(dom: str) -> dict[str, object]:
    match = RESULT_RE.search(dom)
    if not match:
        raise RuntimeError("technical result node not found in dumped DOM")
    payload = html.unescape(match.group(1))
    return json.loads(payload)


def run_duel(chrome_bin: str, player_skill: int, bot_skill: int, round_cap: int) -> dict[str, object]:
    url = fight_url(player_skill, bot_skill, round_cap)
    cmd = [
        chrome_bin,
        "--headless=new",
        "--disable-gpu",
        "--no-sandbox",
        "--disable-breakpad",
        "--disable-crash-reporter",
        "--disable-dev-shm-usage",
        "--no-first-run",
        "--no-default-browser-check",
        "--allow-file-access-from-files",
        f"--virtual-time-budget={virtual_time_budget_ms(round_cap)}",
        "--dump-dom",
        url,
    ]
    proc = subprocess.run(
        cmd,
        check=False,
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        raise RuntimeError(proc.stderr.strip() or "chrome headless failed")
    result = extract_result(proc.stdout)
    if int(result.get("done", 0)) == 0:
        raise RuntimeError(f"simulation did not finish for {skill_name(player_skill)} vs {skill_name(bot_skill)}")
    return result


def classify_matchup(player_skill: int, bot_skill: int, payload: dict[str, object]) -> dict[str, object]:
    result = str(payload.get("result", "running"))
    if result == "player":
        outcome = "win"
        winner = skill_name(player_skill)
    elif result == "bot":
        outcome = "loss"
        winner = skill_name(bot_skill)
    else:
        outcome = "draw"
        winner = "draw"
    return {
        "player_skill": skill_name(player_skill),
        "bot_skill": skill_name(bot_skill),
        "outcome": outcome,
        "winner": winner,
        "reason": str(payload.get("reason", "")),
        "round": int(payload.get("round", 0)),
        "raw": payload,
    }


def run_matchups(chrome_bin: str, pairs: list[tuple[int, int]], round_cap: int) -> list[dict[str, object]]:
    results: list[dict[str, object]] = []
    total = len(pairs)
    for index, (player_skill, bot_skill) in enumerate(pairs, start=1):
        label = f"[{index}/{total}] {skill_name(player_skill)} vs {skill_name(bot_skill)}"
        print(label, file=sys.stderr)
        payload = run_duel(chrome_bin, player_skill, bot_skill, round_cap)
        results.append(classify_matchup(player_skill, bot_skill, payload))
    return results


def aggregate_outcome(results: list[dict[str, object]], skill_a: str, skill_b: str) -> str:
    if skill_a == skill_b:
        return "draw"
    wins_a = 0
    wins_b = 0
    for item in results:
        player = str(item["player_skill"])
        bot = str(item["bot_skill"])
        winner = str(item["winner"])
        if {player, bot} != {skill_a, skill_b}:
            continue
        if winner == skill_a:
            wins_a += 1
        elif winner == skill_b:
            wins_b += 1
    if wins_a > wins_b:
        return "win"
    if wins_b > wins_a:
        return "loss"
    return "draw"


def summary_for_skill(results: list[dict[str, object]], target_skill: str, eligible_names: list[str]) -> dict[str, list[str]]:
    wins: list[str] = []
    losses: list[str] = []
    draws: list[str] = []
    for opponent in eligible_names:
        outcome = aggregate_outcome(results, target_skill, opponent)
        if outcome == "win":
            wins.append(opponent)
        elif outcome == "loss":
            losses.append(opponent)
        else:
            draws.append(opponent)
    return {
        "wins": wins,
        "losses": losses,
        "draws": draws,
    }


def build_report(results: list[dict[str, object]], round_cap: int) -> dict[str, object]:
    eligible_names = [skill_name(skill_id) for skill_id in ELIGIBLE_SKILL_IDS]
    summary: dict[str, dict[str, list[str]]] = {}
    for name in eligible_names:
        summary[name] = summary_for_skill(results, name, eligible_names)
    return {
        "mode": "botvbot",
        "round_cap": round_cap,
        "skills": eligible_names,
        "matchups": results,
        "summary": summary,
    }


def print_skill_summary(skill: str, summary: dict[str, list[str]]) -> None:
    print(skill)
    print("vence:", ", ".join(summary["wins"]) or "-")
    print("perde:", ", ".join(summary["losses"]) or "-")
    print("empata:", ", ".join(summary["draws"]) or "-")


def print_full_summary(report: dict[str, object]) -> None:
    summary = report["summary"]
    assert isinstance(summary, dict)
    for skill in report["skills"]:
        assert isinstance(skill, str)
        print_skill_summary(skill, summary[skill])
        print()


def write_json(path_str: str, report: dict[str, object]) -> None:
    path = Path(path_str)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, ensure_ascii=True, indent=2) + "\n")


def main() -> None:
    args = parse_args()
    chrome_bin = detect_chrome(args.chrome_bin)
    round_cap = args.round_cap if args.round_cap > 0 else DEFAULT_ROUND_CAP

    if args.duel:
        player_skill = skill_id_from_name(args.duel[0])
        bot_skill = skill_id_from_name(args.duel[1])
        pairs = [(player_skill, bot_skill)]
        if player_skill != bot_skill:
            pairs.append((bot_skill, player_skill))
        results = run_matchups(chrome_bin, pairs, round_cap)
    elif args.skill:
        player_skill = skill_id_from_name(args.skill)
        pairs = [(player_skill, bot_skill) for bot_skill in ELIGIBLE_SKILL_IDS]
        pairs += [(bot_skill, player_skill) for bot_skill in ELIGIBLE_SKILL_IDS if bot_skill != player_skill]
        results = run_matchups(chrome_bin, pairs, round_cap)
    else:
        pairs: list[tuple[int, int]] = []
        for idx, player_skill in enumerate(ELIGIBLE_SKILL_IDS):
            pairs.append((player_skill, player_skill))
            for bot_skill in ELIGIBLE_SKILL_IDS[idx + 1:]:
                pairs.append((player_skill, bot_skill))
                pairs.append((bot_skill, player_skill))
        results = run_matchups(chrome_bin, pairs, round_cap)

    report = build_report(results, round_cap)

    if args.duel:
        player_name = skill_name(player_skill)
        bot_name = skill_name(bot_skill)
        outcome = aggregate_outcome(results, player_name, bot_name)
        print(f"{player_name} vs {bot_name}: {outcome}")
    elif args.skill:
        target = skill_name(skill_id_from_name(args.skill))
        print_skill_summary(target, report["summary"][target])
    else:
        print_full_summary(report)

    if args.json_out:
        write_json(args.json_out, report)


if __name__ == "__main__":
    main()
