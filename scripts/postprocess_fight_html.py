from pathlib import Path


FIGHT_RUN = "__run_app(n2f66696768742f6d61696e());"
BOOTSTRAP_START = 'const __fight_params = new URLSearchParams(window.location.search);'
BOOTSTRAP_END = "__run_app(__fight_app);"

BOOTSTRAP = """const __fight_params = new URLSearchParams(window.location.search);
const __fight_skill_count = $n2f7368617265642f66696768742f736b696c6c5f636f756e74();
function __fight_parse_slot(name, fallback) {
  const raw = __fight_params.get(name);
  if (raw === null || raw === "") {
    return fallback;
  }
  const num = Number.parseInt(raw, 10);
  if (!Number.isFinite(num)) {
    return fallback;
  }
  if (num < 0) {
    return 0;
  }
  if (num > __fight_skill_count) {
    return fallback;
  }
  return num >>> 0;
}
const __fight_app = n2f66696768742f6d61696e();
__fight_app.init = n2f67616d655f746573742f6d61696e2f66696768745f6170705f66726f6d5f736c6f7473()(
  __fight_parse_slot("ps1", 2)
)(
  __fight_parse_slot("ps2", 3)
)(
  __fight_parse_slot("ps3", 4)
)(
  __fight_parse_slot("bs1", 2)
)(
  __fight_parse_slot("bs2", 3)
)(
  __fight_parse_slot("bs3", 4)
);
__run_app(__fight_app);"""


def main() -> None:
  path = Path("fight/index.html")
  text = path.read_text()
  if FIGHT_RUN in text:
    path.write_text(text.replace(FIGHT_RUN, BOOTSTRAP, 1))
    return
  if BOOTSTRAP_START not in text or BOOTSTRAP_END not in text:
    raise SystemExit("fight bootstrap marker not found")
  start = text.index(BOOTSTRAP_START)
  end = text.index(BOOTSTRAP_END, start) + len(BOOTSTRAP_END)
  path.write_text(text[:start] + BOOTSTRAP + text[end:])


if __name__ == "__main__":
  main()
