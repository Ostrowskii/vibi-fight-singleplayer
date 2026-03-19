#!/usr/bin/env python3

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "story" / "index.html"
MARKER = "__run_app(n2f73746f72792f6d61696e());"
PATCH_START = "/* __vibi_story_patch:start */"
PATCH_END = "/* __vibi_story_patch:end */"


def encode_symbol(module_path: str, name: str) -> str:
    separator = "#" if name.startswith("_") else "/"
    return "n" + (module_path + separator + name).encode().hex()


PATCH = f"""
/* __vibi_story_patch:start */
const __story_params = new URLSearchParams(window.location.search);

function __story_parse_u32(name, fallback) {{
  const raw = __story_params.get(name);
  if (raw === null || raw === "") {{
    return fallback >>> 0;
  }}
  const num = Number.parseInt(raw, 10);
  if (!Number.isFinite(num) || num < 0) {{
    return fallback >>> 0;
  }}
  return num >>> 0;
}}

function __story_screen_id() {{
  const raw = (__story_params.get("screen") || "").toLowerCase();
  switch (raw) {{
    case "game_over":
      return 1;
    case "victory":
      return 2;
    default:
      return 0;
  }}
}}

const __story_app = n2f73746f72792f6d61696e();
__story_app.init = {encode_symbol("/story/main", "story_app_from_query")}()(
  __story_screen_id()
)(
  __story_parse_u32("level", 1)
)(
  __story_parse_u32("gold", 0)
);
__run_app(__story_app);
/* __vibi_story_patch:end */
""".strip()


def patch_text(text: str) -> str:
    if PATCH_START in text and PATCH_END in text:
        start = text.index(PATCH_START)
        end = text.index(PATCH_END) + len(PATCH_END)
        return text[:start] + PATCH + "\n\n" + text[end:]

    if MARKER not in text:
        raise SystemExit("marker not found for story/index.html")

    return text.replace(MARKER, PATCH + "\n\n", 1)


def main() -> None:
    TARGET.write_text(patch_text(TARGET.read_text()))


if __name__ == "__main__":
    main()
