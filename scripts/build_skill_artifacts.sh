#!/usr/bin/env bash
set -euo pipefail

python3 scripts/generate_skill_ai_consts.py
python3 scripts/generate_skill_svgs.py
