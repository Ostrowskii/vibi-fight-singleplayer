from pathlib import Path


GAME_TEST_RUN = "__run_app(n2f67616d652d746573742f6d61696e());"
BOOTSTRAP_START = 'const __game_test_params = new URLSearchParams(window.location.search);'
BOOTSTRAP_END = "__run_app(__game_test_app);"

BOOTSTRAP = """const __game_test_params = new URLSearchParams(window.location.search);
const __game_test_skill_count = $n2f7368617265642f66696768742f736b696c6c5f636f756e74();
function __game_test_parse_skill(name, fallback) {
  const raw = __game_test_params.get(name);
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
  if (num > __game_test_skill_count) {
    return fallback;
  }
  return num >>> 0;
}
function __game_test_parse_item(name, fallback) {
  const raw = __game_test_params.get(name);
  if (raw === null || raw === "") {
    return fallback;
  }
  const num = Number.parseInt(raw, 10);
  if (!Number.isFinite(num) || num < 0) {
    return fallback;
  }
  return num >>> 0;
}
const __game_test_app = n2f67616d652d746573742f6d61696e();
__game_test_app.init = n2f67616d652d746573742f6d61696e2f67616d655f746573745f6170705f66726f6d5f736c6f74735f6974656d73()(
  __game_test_parse_skill("ps1", 2)
)(
  __game_test_parse_skill("ps2", 3)
)(
  __game_test_parse_skill("ps3", 4)
)(
  __game_test_parse_skill("bs1", 2)
)(
  __game_test_parse_skill("bs2", 3)
)(
  __game_test_parse_skill("bs3", 4)
)(
  __game_test_parse_item("pi1", 0)
)(
  __game_test_parse_item("pi2", 0)
)(
  __game_test_parse_item("pi3", 0)
)(
  __game_test_parse_item("bi1", 0)
)(
  __game_test_parse_item("bi2", 0)
)(
  __game_test_parse_item("bi3", 0)
);
__run_app(__game_test_app);"""


def main() -> None:
  path = Path("game-test/index.html")
  text = path.read_text()
  if GAME_TEST_RUN in text:
    path.write_text(text.replace(GAME_TEST_RUN, BOOTSTRAP, 1))
    return
  if BOOTSTRAP_START not in text or BOOTSTRAP_END not in text:
    raise SystemExit("game-test bootstrap marker not found")
  start = text.index(BOOTSTRAP_START)
  end = text.index(BOOTSTRAP_END, start) + len(BOOTSTRAP_END)
  path.write_text(text[:start] + BOOTSTRAP + text[end:])


if __name__ == "__main__":
  main()
