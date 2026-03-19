#!/usr/bin/env python3

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TARGETS = [
    ROOT / "fight" / "index.html",
    ROOT / "game-test" / "index.html",
]

PATCH_START = "/* __vibi_perf_patch:start */"
PATCH_END = "/* __vibi_perf_patch:end */"
GAME_MAIN_PREFIXES = (
    "n2f67616d655f746573742f6d61696e",
    "n2f67616d652d746573742f6d61696e",
)

PATCH_TEMPLATE = r"""
/* __vibi_perf_patch:start */
// Performance priority order:
// 1. preprocess and cache skill matrices/visuals on load
// 2. preload and retain skill assets at startup
// 3. reuse preallocated grid buffers
// 4. debounce DOM work with setTimeout until requestAnimationFrame exists
// 5. cache previews by skill+rotation
const __VIBI_RENDER_DEBOUNCE_MS = 8;
const __vibiOrigSkillCountBase = $n2f7368617265642f66696768742f736b696c6c5f636f756e74;
const __vibiOrigSkillDamageBase = $n2f7368617265642f66696768742f736b696c6c5f64616d616765;
const __vibiOrigSkillRankBase = $n2f7368617265642f66696768742f736b696c6c5f72616e6b;
const __vibiOrigSkillClassIdBase = $n2f7368617265642f66696768742f736b696c6c5f636c6173735f6964;
const __vibiOrigSkillNameBase = $n2f7368617265642f66696768742f736b696c6c5f6e616d65;
const __vibiOrigSkillBaseWBase = $n2f7368617265642f66696768742f736b696c6c5f626173655f77;
const __vibiOrigSkillBaseHBase = $n2f7368617265642f66696768742f736b696c6c5f626173655f68;
const __vibiOrigSkillBaseCellBase = $n2f7368617265642f66696768742f736b696c6c5f626173655f63656c6c;

function __vibiExtraSkillBaseCell(skill, x, y) {
  skill >>>= 0;
  x >>>= 0;
  y >>>= 0;
  if (skill === 14) {
    if (y !== 0) {
      return 0;
    }
    if (x === 0) {
      return 16;
    }
    if (x === 1 || x === 2 || x === 3) {
      return 2;
    }
    if (x === 4) {
      return 3;
    }
    return 0;
  }
  if (skill === 15) {
    if (y === 0 && x === 0) {
      return 1;
    }
    if (y === 1 && (x === 0 || x === 1)) {
      return 1;
    }
    if (y === 2 && (x === 1 || x === 2)) {
      return 1;
    }
    return 0;
  }
  return __vibiOrigSkillBaseCellBase(skill, x, y);
}

const __vibiSkillCountOverride = function() {
  return 15;
};
$n2f7368617265642f66696768742f736b696c6c5f636f756e74 = __vibiSkillCountOverride;

const __vibiSkillDamageOverride = function(skill) {
  if ((skill >>> 0) === 14 || (skill >>> 0) === 15) {
    return 10;
  }
  return __vibiOrigSkillDamageBase(skill >>> 0);
};
$n2f7368617265642f66696768742f736b696c6c5f64616d616765 = __vibiSkillDamageOverride;

const __vibiSkillRankOverride = function(skill) {
  if ((skill >>> 0) === 14) {
    return 6;
  }
  if ((skill >>> 0) === 15) {
    return 7;
  }
  return __vibiOrigSkillRankBase(skill >>> 0);
};
$n2f7368617265642f66696768742f736b696c6c5f72616e6b = __vibiSkillRankOverride;

const __vibiSkillClassIdOverride = function(skill) {
  if ((skill >>> 0) === 14 || (skill >>> 0) === 15) {
    return 0;
  }
  return __vibiOrigSkillClassIdBase(skill >>> 0);
};
$n2f7368617265642f66696768742f736b696c6c5f636c6173735f6964 = __vibiSkillClassIdOverride;

const __vibiSkillNameOverride = function(skill) {
  if ((skill >>> 0) === 14) {
    return "Me6";
  }
  if ((skill >>> 0) === 15) {
    return "Me7";
  }
  return __vibiOrigSkillNameBase(skill >>> 0);
};
$n2f7368617265642f66696768742f736b696c6c5f6e616d65 = __vibiSkillNameOverride;

const __vibiSkillBaseWOverride = function(skill) {
  if ((skill >>> 0) === 14) {
    return 5;
  }
  if ((skill >>> 0) === 15) {
    return 3;
  }
  return __vibiOrigSkillBaseWBase(skill >>> 0);
};
$n2f7368617265642f66696768742f736b696c6c5f626173655f77 = __vibiSkillBaseWOverride;

const __vibiSkillBaseHOverride = function(skill) {
  if ((skill >>> 0) === 14) {
    return 1;
  }
  if ((skill >>> 0) === 15) {
    return 3;
  }
  return __vibiOrigSkillBaseHBase(skill >>> 0);
};
$n2f7368617265642f66696768742f736b696c6c5f626173655f68 = __vibiSkillBaseHOverride;

const __vibiSkillBaseCellOverride = function(skill, x, y) {
  return __vibiExtraSkillBaseCell(skill >>> 0, x >>> 0, y >>> 0);
};
$n2f7368617265642f66696768742f736b696c6c5f626173655f63656c6c = __vibiSkillBaseCellOverride;

const __vibiSkillCount = $n2f7368617265642f66696768742f736b696c6c5f636f756e74();
const __vibiGridPool = Array.from({ length: 256 }, () => new Uint32Array(9));
let __vibiGridPoolIndex = 0;
const __vibiSkillCache = new Array((__vibiSkillCount >>> 0) + 1);
const __vibiSkillAssets = new Map();

function __vibiLeaseRows() {
  const rows = __vibiGridPool[__vibiGridPoolIndex];
  __vibiGridPoolIndex = (__vibiGridPoolIndex + 1) % __vibiGridPool.length;
  rows.fill(0);
  return rows;
}

function __vibiPos(x, y) {
  return ({ $: "pos", x: x >>> 0, y: y >>> 0 });
}

function __vibiPointEq(a, b) {
  return (a.x >>> 0) === (b.x >>> 0) && (a.y >>> 0) === (b.y >>> 0);
}

function __vibiAxisInside(actorAxis, originAxis, localAxis, limit) {
  actorAxis >>>= 0;
  originAxis >>>= 0;
  localAxis >>>= 0;
  limit >>>= 0;
  if (localAxis < originAxis) {
    return actorAxis >= (originAxis - localAxis);
  }
  return (actorAxis + (localAxis - originAxis)) < limit;
}

function __vibiWorldInside(actor, origin, local) {
  return __vibiAxisInside(actor.x, origin.x, local.x, 18)
    && __vibiAxisInside(actor.y, origin.y, local.y, 9);
}

function __vibiAxisPos(actorAxis, originAxis, localAxis) {
  actorAxis >>>= 0;
  originAxis >>>= 0;
  localAxis >>>= 0;
  if (localAxis < originAxis) {
    return (actorAxis - (originAxis - localAxis)) >>> 0;
  }
  return (actorAxis + (localAxis - originAxis)) >>> 0;
}

function __vibiWorldPos(actor, origin, local) {
  return {
    x: __vibiAxisPos(actor.x, origin.x, local.x),
    y: __vibiAxisPos(actor.y, origin.y, local.y),
  };
}

function __vibiMark(rows, point) {
  const x = point.x >>> 0;
  const y = point.y >>> 0;
  if (x < 18 && y < 9) {
    rows[y] |= (1 << x);
  }
}

function __vibiListFromWorldPoints(points, rows) {
  let list = ({ $: "nil" });
  for (let i = points.length - 1; i >= 0; --i) {
    const point = points[i];
    list = ({ $: "cons", head: __vibiPos(point.x, point.y), tail: list });
  }
  Object.defineProperty(list, "__grid_rows", {
    value: rows,
    configurable: true,
  });
  return list;
}

function __vibiCachedWorldList(points, actor, origin, skipOrigin) {
  const rows = __vibiLeaseRows();
  const worldPoints = [];
  for (const local of points) {
    if (!__vibiWorldInside(actor, origin, local)) {
      continue;
    }
    if (skipOrigin && __vibiPointEq(local, origin)) {
      continue;
    }
    const world = __vibiWorldPos(actor, origin, local);
    __vibiMark(rows, world);
    worldPoints.push(world);
  }
  return __vibiListFromWorldPoints(worldPoints, rows);
}

function __vibiHasVisibleEffect(points, actor, origin) {
  for (const local of points) {
    if (__vibiWorldInside(actor, origin, local) && !__vibiPointEq(local, origin)) {
      return 1;
    }
  }
  return 0;
}

function __vibiLocalHas(points, target) {
  for (const local of points) {
    if (__vibiPointEq(local, target)) {
      return 1;
    }
  }
  return 0;
}

function __vibiGridHas(rows, target) {
  if (!rows || !target || target.$ !== "pos") {
    return false;
  }
  const x = target.x >>> 0;
  const y = target.y >>> 0;
  if (x >= 18 || y >= 9) {
    return false;
  }
  return ((rows[y] >>> 0) & (1 << x)) !== 0;
}

function __vibiFrame(skill, rot) {
  const skillCache = __vibiSkillCache[skill >>> 0];
  if (!skillCache) {
    return null;
  }
  return skillCache.frames[(rot >>> 0) & 3];
}

(function __vibiInitSkillCache() {
  for (let skill = 1; skill <= (__vibiSkillCount >>> 0); ++skill) {
    const len = $n2f7368617265642f66696768742f736b696c6c5f6c656e(skill) >>> 0;
    const playerMask = new Array(len);
    const effectMask = new Array(len);
    let usesPlayer = false;
    for (let idx = 0; idx < len; ++idx) {
      const player = $n2f7368617265642f66696768742f736b696c6c5f706c617965725f6d61736b(skill, idx) >>> 0;
      const effect = $n2f7368617265642f66696768742f736b696c6c5f6566666563745f6d61736b(skill, idx) >>> 0;
      playerMask[idx] = player;
      effectMask[idx] = effect;
      if (player !== 0) {
        usesPlayer = true;
      }
    }

    const frames = new Array(4);
    for (let rot = 0; rot < 4; ++rot) {
      const all = [];
      const canAnchor = [];
      const previewAnchor = [];
      const effectAll = [];
      const effectByFlag = { 1: [], 2: [], 4: [], 8: [] };
      for (let idx = 0; idx < len; ++idx) {
        const point = {
          x: $n2f7368617265642f66696768742f736b696c6c5f706f696e745f78(skill, rot, idx) >>> 0,
          y: $n2f7368617265642f66696768742f736b696c6c5f706f696e745f79(skill, rot, idx) >>> 0,
        };
        all.push(point);
        if (playerMask[idx] !== 0) {
          previewAnchor.push(point);
        }
        if (usesPlayer ? playerMask[idx] !== 0 : true) {
          canAnchor.push(point);
        }
        const effect = effectMask[idx] >>> 0;
        if (effect !== 0) {
          effectAll.push(point);
        }
        if ((effect & 1) !== 0) {
          effectByFlag[1].push(point);
        }
        if ((effect & 2) !== 0) {
          effectByFlag[2].push(point);
        }
        if ((effect & 4) !== 0) {
          effectByFlag[4].push(point);
        }
        if ((effect & 8) !== 0) {
          effectByFlag[8].push(point);
        }
      }
      frames[rot] = { all, canAnchor, previewAnchor, effectAll, effectByFlag };
    }

    const name = $n2f7368617265642f66696768742f736b696c6c5f6e616d65(skill);
    __vibiSkillCache[skill] = { len, playerMask, effectMask, frames, name };

    const image = new Image();
    image.decoding = "async";
    image.src = `../assets/skills/${name}.svg`;
    __vibiSkillAssets.set(skill, image);
  }
})();

const __vibiOrigSkillLen = $n2f7368617265642f66696768742f736b696c6c5f6c656e;
const __vibiOrigSkillPointX = $n2f7368617265642f66696768742f736b696c6c5f706f696e745f78;
const __vibiOrigSkillPointY = $n2f7368617265642f66696768742f736b696c6c5f706f696e745f79;
const __vibiOrigSkillPlayerMask = $n2f7368617265642f66696768742f736b696c6c5f706c617965725f6d61736b;
const __vibiOrigSkillEffectMask = $n2f7368617265642f66696768742f736b696c6c5f6566666563745f6d61736b;
const __vibiOrigPreviewTilesFor = __GAME_PRIVATE__707265766965775f74696c65735f666f72;
const __vibiOrigPreviewAnchorTilesFor = __GAME_PRIVATE__707265766965775f616e63686f725f74696c65735f666f72;
const __vibiOrigPreviewHitsFor = __GAME_PRIVATE__707265766965775f686974735f666f72;
const __vibiOrigEffectTilesFor = __GAME_PRIVATE__6566666563745f74696c65735f666f72;
const __vibiOrigPlacementValid = __GAME_PRIVATE__706c6163656d656e745f76616c6964;
const __vibiOrigPreviewHitContains = __GAME_PRIVATE__707265766965775f6869745f636f6e7461696e73;
const __vibiOrigPosListHas = __GAME_PRIVATE__706f735f6c6973745f686173;

$n2f7368617265642f66696768742f736b696c6c5f6c656e = function(skill) {
  const cached = __vibiSkillCache[skill >>> 0];
  return cached ? (cached.len >>> 0) : __vibiOrigSkillLen(skill);
};

$n2f7368617265642f66696768742f736b696c6c5f706f696e745f78 = function(skill, rot, idx) {
  const frame = __vibiFrame(skill, rot);
  const point = frame && frame.all[idx >>> 0];
  return point ? (point.x >>> 0) : __vibiOrigSkillPointX(skill, rot, idx);
};

$n2f7368617265642f66696768742f736b696c6c5f706f696e745f79 = function(skill, rot, idx) {
  const frame = __vibiFrame(skill, rot);
  const point = frame && frame.all[idx >>> 0];
  return point ? (point.y >>> 0) : __vibiOrigSkillPointY(skill, rot, idx);
};

$n2f7368617265642f66696768742f736b696c6c5f706c617965725f6d61736b = function(skill, idx) {
  const cached = __vibiSkillCache[skill >>> 0];
  const value = cached && cached.playerMask[idx >>> 0];
  return value === undefined ? __vibiOrigSkillPlayerMask(skill, idx) : (value >>> 0);
};

$n2f7368617265642f66696768742f736b696c6c5f6566666563745f6d61736b = function(skill, idx) {
  const cached = __vibiSkillCache[skill >>> 0];
  const value = cached && cached.effectMask[idx >>> 0];
  return value === undefined ? __vibiOrigSkillEffectMask(skill, idx) : (value >>> 0);
};

__GAME_PRIVATE__707265766965775f74696c65735f666f72 = function(skill, rot, origin, actor, idx) {
  const frame = __vibiFrame(skill, rot);
  return frame ? __vibiCachedWorldList(frame.all, actor, origin, false) : __vibiOrigPreviewTilesFor(skill, rot, origin, actor, idx);
};

__GAME_PRIVATE__707265766965775f616e63686f725f74696c65735f666f72 = function(skill, rot, origin, actor, idx) {
  const frame = __vibiFrame(skill, rot);
  return frame ? __vibiCachedWorldList(frame.previewAnchor, actor, origin, false) : __vibiOrigPreviewAnchorTilesFor(skill, rot, origin, actor, idx);
};

__GAME_PRIVATE__707265766965775f686974735f666f72 = function(skill, rot, origin, actor, idx) {
  const frame = __vibiFrame(skill, rot);
  return frame ? __vibiCachedWorldList(frame.effectAll, actor, origin, true) : __vibiOrigPreviewHitsFor(skill, rot, origin, actor, idx);
};

__GAME_PRIVATE__6566666563745f74696c65735f666f72 = function(skill, rot, origin, actor, flag, idx) {
  const frame = __vibiFrame(skill, rot);
  if (!frame) {
    return __vibiOrigEffectTilesFor(skill, rot, origin, actor, flag, idx);
  }
  const points = frame.effectByFlag[flag >>> 0] || [];
  return __vibiCachedWorldList(points, actor, origin, true);
};

__GAME_PRIVATE__706c6163656d656e745f76616c6964 = function(skill, rot, origin, actor) {
  const frame = __vibiFrame(skill, rot);
  if (!frame) {
    return __vibiOrigPlacementValid(skill, rot, origin, actor);
  }
  if (!__vibiLocalHas(frame.canAnchor, origin)) {
    return 0;
  }
  return __vibiHasVisibleEffect(frame.effectAll, actor, origin);
};

__GAME_PRIVATE__707265766965775f6869745f636f6e7461696e73 = function(skill, rot, origin, actor, target, idx) {
  const frame = __vibiFrame(skill, rot);
  if (!frame) {
    return __vibiOrigPreviewHitContains(skill, rot, origin, actor, target, idx);
  }
  for (const local of frame.effectAll) {
    if (__vibiPointEq(local, origin) || !__vibiWorldInside(actor, origin, local)) {
      continue;
    }
    const world = __vibiWorldPos(actor, origin, local);
    if (__vibiPointEq(world, target)) {
      return 1;
    }
  }
  return 0;
};

__GAME_PRIVATE__706f735f6c6973745f686173 = function(items, target) {
  const rows = items && items.__grid_rows;
  if (rows) {
    return __vibiGridHas(rows, target) ? 1 : 0;
  }
  return __vibiOrigPosListHas(items, target);
};

__run_app = function(app) {
  if (app === null || typeof app !== "object" || app.$ !== "app") {
    throw new Error("main is not an App value");
  }
  let state = __app_fld(app, "init", 2);
  const render = __app_fld(app, "render", 3);
  const on_event = __app_fld(app, "on_event", 4);
  if (typeof render !== "function" || typeof on_event !== "function") {
    throw new Error("invalid App handlers");
  }
  const root = document.getElementById("app");
  if (root === null) {
    throw new Error("missing #app mount node");
  }

  let view = __app_decode_html(render(state));
  let dom = null;
  let flushTimer = null;
  let hasPendingRender = false;

  function flush() {
    flushTimer = null;
    if (!hasPendingRender) {
      return;
    }
    hasPendingRender = false;
    const next = __app_decode_html(render(state));
    dom = __app_patch(dom, view, next, dispatch);
    view = next;
  }

  function scheduleFlush() {
    hasPendingRender = true;
    if (flushTimer !== null) {
      clearTimeout(flushTimer);
    }
    flushTimer = setTimeout(flush, __VIBI_RENDER_DEBOUNCE_MS);
  }

  function dispatch(msg) {
    const got = on_event(msg);
    if (typeof got !== "function") {
      throw new Error("invalid on_event function");
    }
    state = got(state);
    scheduleFlush();
  }

  dom = __app_mount(view, dispatch);
  root.replaceChildren(dom);
};
/* __vibi_perf_patch:end */
"""

def detect_game_main_prefix(text: str) -> str:
    for prefix in GAME_MAIN_PREFIXES:
        if prefix + "235f72756e74696d655f656d707479" in text:
            return prefix
    raise SystemExit("game main prefix not found")


def build_patch(text: str) -> str:
    private_prefix = "$" + detect_game_main_prefix(text) + "235f"
    return PATCH_TEMPLATE.replace("__GAME_PRIVATE__", private_prefix)


def patch_text(text: str) -> str:
    marker = "const __fight_params ="
    if marker not in text:
        marker = "const __game_test_params ="
    if marker not in text:
        raise SystemExit("bootstrap marker not found")

    patch = build_patch(text)

    if PATCH_START in text and PATCH_END in text:
        start = text.index(PATCH_START)
        end = text.index(PATCH_END) + len(PATCH_END)
        return text[:start] + patch.strip() + "\n\n" + text[end:]

    return text.replace(marker, patch.strip() + "\n\n" + marker, 1)


def main() -> None:
    for path in TARGETS:
        path.write_text(patch_text(path.read_text()))


if __name__ == "__main__":
    main()
