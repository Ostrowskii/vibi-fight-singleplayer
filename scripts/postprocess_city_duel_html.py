from pathlib import Path
import shutil


def main() -> None:
  source = Path("fight/index.html")
  target = Path("city-duel/index.html")
  if not source.exists():
    raise SystemExit("fight/index.html not found")
  target.parent.mkdir(parents=True, exist_ok=True)
  shutil.copyfile(source, target)


if __name__ == "__main__":
  main()
