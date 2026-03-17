from pathlib import Path


FIGHT_RUN = "__run_app(n2f66696768742f6d61696e());"

BOOTSTRAP = """const __fight_params = new URLSearchParams(window.location.search);
const __fight_skill_count = n2f7368617265642f66696768742f736b696c6c5f636f756e74();
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
__fight_app.init = n2f706c61792f6d61696e2f66696768745f6170705f66726f6d5f736c6f7473()(
  __fight_parse_slot("ps1", 1)
)(
  __fight_parse_slot("ps2", 2)
)(
  __fight_parse_slot("ps3", 3)
)(
  __fight_parse_slot("bs1", 1)
)(
  __fight_parse_slot("bs2", 2)
)(
  __fight_parse_slot("bs3", 3)
);
__run_app(__fight_app);"""


def main() -> None:
  path = Path("fight/index.html")
  text = path.read_text()
  if FIGHT_RUN not in text:
    raise SystemExit("fight bootstrap marker not found")
  path.write_text(text.replace(FIGHT_RUN, BOOTSTRAP, 1))


if __name__ == "__main__":
  main()
