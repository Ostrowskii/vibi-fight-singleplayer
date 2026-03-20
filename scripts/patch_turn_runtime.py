#!/usr/bin/env python3

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
FIGHT_PATH = ROOT / "src" / "shared" / "fight" / "_.bend"
PATCH_START = "/* __vibi_turn_patch:start */"
PATCH_END = "/* __vibi_turn_patch:end */"

TARGETS = [
    {
        "path": ROOT / "play" / "index.html",
        "module_path": "/play/main",
        "marker": "__run_app(n2f706c61792f6d61696e());",
        "bundle_kind": "play",
    },
    {
        "path": ROOT / "game-test" / "index.html",
        "module_path": "/game-test/main",
        "marker": "const __game_test_params =",
        "bundle_kind": "game_test",
    },
    {
        "path": ROOT / "fight" / "index.html",
        "module_path": "/game_test/main",
        "marker": "const __fight_params =",
        "bundle_kind": "fight",
    },
]


PATCH_TEMPLATE = r"""
/* __vibi_turn_patch:start */
const __vibiTurnOrigSkillCountBase = __SKILL_COUNT_FN__;
const __vibiTurnOrigSkillDamageBase = __SKILL_DAMAGE_FN__;
const __vibiTurnOrigSkillRankBase = __SKILL_RANK_FN__;
const __vibiTurnOrigSkillClassIdBase = __SKILL_CLASS_ID_FN__;
const __vibiTurnOrigSkillNameBase = __SKILL_NAME_FN__;
const __vibiTurnOrigSkillBaseWBase = __SKILL_BASE_W_FN__;
const __vibiTurnOrigSkillBaseHBase = __SKILL_BASE_H_FN__;
const __vibiTurnOrigSkillBaseCellBase = __SKILL_BASE_CELL_FN__;
const __VIBI_TURN_EXTRA_SKILLS = __EXTRA_SKILLS_JSON__;

function __vibiTurnExtraSkillMeta(skill) {
  return __VIBI_TURN_EXTRA_SKILLS[skill >>> 0] || null;
}

function __vibiTurnExtraSkillBaseCell(skill, x, y) {
  const extra = __vibiTurnExtraSkillMeta(skill >>> 0);
  if (!extra) {
    return __vibiTurnOrigSkillBaseCellBase(skill >>> 0, x >>> 0, y >>> 0);
  }
  const key = (x >>> 0) + "," + (y >>> 0);
  const value = extra.cells[key];
  return value === undefined ? 0 : (value >>> 0);
}

const __vibiTurnSkillCountOverride = function() {
  return __EXTRA_SKILL_COUNT__;
};
__SKILL_COUNT_FN__ = __vibiTurnSkillCountOverride;

const __vibiTurnSkillDamageOverride = function(skill) {
  const extra = __vibiTurnExtraSkillMeta(skill >>> 0);
  if (extra) {
    return extra.damage >>> 0;
  }
  return __vibiTurnOrigSkillDamageBase(skill >>> 0);
};
__SKILL_DAMAGE_FN__ = __vibiTurnSkillDamageOverride;

const __vibiTurnSkillRankOverride = function(skill) {
  const extra = __vibiTurnExtraSkillMeta(skill >>> 0);
  if (extra) {
    return extra.rank >>> 0;
  }
  return __vibiTurnOrigSkillRankBase(skill >>> 0);
};
__SKILL_RANK_FN__ = __vibiTurnSkillRankOverride;

const __vibiTurnSkillClassIdOverride = function(skill) {
  const extra = __vibiTurnExtraSkillMeta(skill >>> 0);
  if (extra) {
    return extra.classId >>> 0;
  }
  return __vibiTurnOrigSkillClassIdBase(skill >>> 0);
};
__SKILL_CLASS_ID_FN__ = __vibiTurnSkillClassIdOverride;

const __vibiTurnSkillNameOverride = function(skill) {
  const extra = __vibiTurnExtraSkillMeta(skill >>> 0);
  if (extra) {
    return extra.name;
  }
  return __vibiTurnOrigSkillNameBase(skill >>> 0);
};
__SKILL_NAME_FN__ = __vibiTurnSkillNameOverride;

const __vibiTurnSkillBaseWOverride = function(skill) {
  const extra = __vibiTurnExtraSkillMeta(skill >>> 0);
  if (extra) {
    return extra.w >>> 0;
  }
  return __vibiTurnOrigSkillBaseWBase(skill >>> 0);
};
__SKILL_BASE_W_FN__ = __vibiTurnSkillBaseWOverride;

const __vibiTurnSkillBaseHOverride = function(skill) {
  const extra = __vibiTurnExtraSkillMeta(skill >>> 0);
  if (extra) {
    return extra.h >>> 0;
  }
  return __vibiTurnOrigSkillBaseHBase(skill >>> 0);
};
__SKILL_BASE_H_FN__ = __vibiTurnSkillBaseHOverride;

const __vibiTurnSkillBaseCellOverride = function(skill, x, y) {
  return __vibiTurnExtraSkillBaseCell(skill >>> 0, x >>> 0, y >>> 0);
};
__SKILL_BASE_CELL_FN__ = __vibiTurnSkillBaseCellOverride;

const __VIBI_SHARED_SKILL_COUNT = __SKILL_COUNT_FN__() >>> 0;

const __vibiTurnWait = () => ({$: "wait"});

function __vibiTurnList4(a, b, c, d) {
  return ({
    $: "cons",
    head: a,
    tail: ({
      $: "cons",
      head: b,
      tail: ({
        $: "cons",
        head: c,
        tail: ({
          $: "cons",
          head: d,
          tail: ({$: "nil"}),
        }),
      }),
    }),
  });
}

function __vibiTurnPlan(queue, queueLen, queueLocked, mode) {
  return ({
    $: "game_plan",
    queue,
    queue_len: queueLen >>> 0,
    queue_locked: queueLocked >>> 0,
    mode,
  });
}

function __vibiTurnState(state, queue, queueLen, queueLocked, mode) {
  return ({
    $: "game_state",
    meta: state.meta,
    arena: state.arena,
    plan: __vibiTurnPlan(queue, queueLen, queueLocked, mode),
  });
}

function __vibiTurnPlanMode(runtime) {
  return ({$: "plan", runtime});
}

function __vibiTurnTargetMode(skill, rot, origin, runtime, baseLen) {
  return ({
    $: "target",
    skill: skill >>> 0,
    rot: rot >>> 0,
    origin,
    runtime,
    base_len: baseLen >>> 0,
  });
}

function __vibiTurnIsAttack(action) {
  return !!action && action.$ === "attack";
}

function __vibiTurnSkillClass(skill) {
  return __SKILL_CLASS_ID_FN__(skill >>> 0) >>> 0;
}

function __vibiTurnBaseLen(mode, queueLen) {
  if (mode && typeof mode.base_len === "number") {
    return mode.base_len >>> 0;
  }
  return queueLen >>> 0;
}

function __vibiTurnPosEq(a, b) {
  return ((a.x >>> 0) === (b.x >>> 0)) && ((a.y >>> 0) === (b.y >>> 0));
}

function __vibiTurnAbsDiff(a, b) {
  a >>>= 0;
  b >>>= 0;
  return a >= b ? ((a - b) >>> 0) : ((b - a) >>> 0);
}

function __vibiTurnDist(a, b) {
  return Math.max(
    __vibiTurnAbsDiff(a.x >>> 0, b.x >>> 0),
    __vibiTurnAbsDiff(a.y >>> 0, b.y >>> 0),
  ) >>> 0;
}

function __vibiTurnTrimQueue(queue, queueLen, baseLen) {
  let next = queue;
  for (let idx = queueLen >>> 0; idx > (baseLen >>> 0); --idx) {
    next = __ACTION_SET_FN__(next, (idx - 1) >>> 0, __vibiTurnWait());
  }
  return next;
}

function __vibiTurnBonusReady(state) {
  if (!state || state.$ !== "game_state") {
    return false;
  }
  const plan = state.plan;
  const mode = plan && plan.mode;
  if (!plan || !mode || mode.$ !== "target") {
    return false;
  }
  const baseLen = __vibiTurnBaseLen(mode, plan.queue_len);
  return __vibiTurnSkillClass(mode.skill) === 1
    && (plan.queue_len >>> 0) === (baseLen >>> 0)
    && (plan.queue_locked >>> 0) === 0
    && (plan.queue_len >>> 0) < 3;
}

function __vibiTurnPreviewInputState(state, dir) {
  if (!state || state.$ !== "game_state") {
    return state;
  }
  const mode = state.plan && state.plan.mode;
  if (mode && mode.$ === "playback") {
    return state;
  }
  if (mode && mode.$ === "target") {
    return __MOVE_TARGET_STATE_FN__(state, dir >>> 0);
  }
  return __QUEUE_MOVE_STATE_FN__(state, dir >>> 0);
}

function __vibiTurnMoveTargetBonusState(state, dir) {
  if (!state || state.$ !== "game_state") {
    return state;
  }
  const plan = state.plan;
  const mode = plan && plan.mode;
  if (!plan || !mode || mode.$ !== "target" || !__vibiTurnBonusReady(state)) {
    return state;
  }
  const baseLen = __vibiTurnBaseLen(mode, plan.queue_len);
  const planned = __PLANNED_POS_FROM_QUEUE_FN__(state.arena.player, plan.queue);
  const next = __STEP_BLOCKED_PLAYER_FN__(planned, dir >>> 0, state.arena.bots);
  if (__vibiTurnPosEq(planned, next)) {
    return state;
  }
  const queue = __ACTION_SET_FN__(
    plan.queue,
    plan.queue_len >>> 0,
    ({$: "move", dir: dir >>> 0}),
  );
  const nextMode = __vibiTurnTargetMode(
    mode.skill,
    mode.rot,
    mode.origin,
    mode.runtime,
    baseLen,
  );
  return __vibiTurnState(
    state,
    queue,
    ((plan.queue_len >>> 0) + 1) >>> 0,
    plan.queue_locked >>> 0,
    nextMode,
  );
}

function __vibiTurnBandScore(classId, dist, hasAttack, movesUsed) {
  if ((classId >>> 0) === 0) {
    return [
      hasAttack ? 0 : 1,
      dist >>> 0,
      movesUsed >>> 0,
    ];
  }
  const min = (classId >>> 0) === 1 ? 8 : 7;
  const max = (classId >>> 0) === 1 ? 9 : 8;
  const center = min;
  const inBand = dist >= min && dist <= max;
  const distError = inBand ? 0 : (dist < min ? (min - dist) : (dist - max));
  const centerError = __vibiTurnAbsDiff(dist >>> 0, center >>> 0);
  return [
    inBand ? 0 : 1,
    hasAttack ? 0 : 1,
    distError >>> 0,
    centerError >>> 0,
    movesUsed >>> 0,
  ];
}

function __vibiTurnBetterCandidate(next, best) {
  if (best === null) {
    return true;
  }
  for (let idx = 0; idx < next.score.length; ++idx) {
    const a = next.score[idx] >>> 0;
    const b = best.score[idx] >>> 0;
    if (a < b) {
      return true;
    }
    if (a > b) {
      return false;
    }
  }
  return false;
}

function __vibiTurnQueueFromMoves(moves, attack) {
  const slots = [__vibiTurnWait(), __vibiTurnWait(), __vibiTurnWait(), __vibiTurnWait()];
  for (let idx = 0; idx < moves.length && idx < 4; ++idx) {
    slots[idx] = ({$: "move", dir: moves[idx] >>> 0});
  }
  if (moves.length < 4) {
    slots[moves.length] = attack;
  }
  return __vibiTurnList4(slots[0], slots[1], slots[2], slots[3]);
}

function __vibiTurnBuildBotPlan(player, enemy, bots, botIdx, round, botLoadout) {
  const fallbackSkill = __ROUND_SKILL_FN__(round >>> 0, botLoadout) >>> 0;
  let best = null;

  const consider = (moves) => {
    let pos = enemy;
    for (const dir of moves) {
      const next = __STEP_BLOCKED_BOT_FN__(pos, dir >>> 0, player, bots, botIdx >>> 0);
      if (__vibiTurnPosEq(pos, next)) {
        return;
      }
      pos = next;
    }

    const hitAttack = __FIND_ATTACK_FN__(pos, player, botLoadout);
    const hasAttack = __vibiTurnIsAttack(hitAttack);
    const planSkill = hasAttack ? (hitAttack.skill >>> 0) : fallbackSkill;
    const classId = __vibiTurnSkillClass(planSkill);
    if (moves.length > 2 && classId !== 1) {
      return;
    }

    const attack = hasAttack ? hitAttack : __FIRST_VALID_ATTACK_FN__(planSkill, pos);
    const dist = __vibiTurnDist(pos, player);
    const candidate = {
      score: __vibiTurnBandScore(classId, dist, hasAttack, moves.length),
      queue: __vibiTurnQueueFromMoves(moves, attack),
    };
    if (__vibiTurnBetterCandidate(candidate, best)) {
      best = candidate;
    }
  };

  consider([]);

  for (let dir1 = 0; dir1 < 4; ++dir1) {
    consider([dir1]);
    for (let dir2 = 0; dir2 < 4; ++dir2) {
      consider([dir1, dir2]);
      for (let dir3 = 0; dir3 < 4; ++dir3) {
        consider([dir1, dir2, dir3]);
      }
    }
  }

  return best === null ? __QUEUE_WAITS_FN__() : best.queue;
}

__QUEUE3_FN__ = function(a, b, c) {
  return __vibiTurnList4(a, b, c, __vibiTurnWait());
};

__QUEUE_WAITS_FN__ = function() {
  return __vibiTurnList4(__vibiTurnWait(), __vibiTurnWait(), __vibiTurnWait(), __vibiTurnWait());
};

__PLAYBACK_TOTAL_STEPS_FN__ = function(botTotal) {
  return Math.imul(4, (((botTotal >>> 0) + 1) >>> 0)) >>> 0;
};

__PLAYBACK_ACTOR_OF_IDX_FN__ = function(idx, botTotal) {
  const turn = (idx >>> 0) % (((botTotal >>> 0) + 1) >>> 0);
  if ((turn >>> 0) === 1) {
    return 0;
  }
  return 1;
};

__PLAYBACK_ACTOR_IDX_OF_IDX_FN__ = function(idx, botTotal) {
  const turn = (idx >>> 0) % (((botTotal >>> 0) + 1) >>> 0);
  if ((turn >>> 0) <= 1) {
    return 0;
  }
  return ((turn >>> 0) - 1) >>> 0;
};

__START_TARGET_APPLY_FN__ = function(
  round,
  level,
  botTotal,
  playerHp,
  player,
  bots,
  queue,
  queueLen,
  queueLocked,
  runtime,
  skill,
) {
  const origin = __DEFAULT_TARGET_ORIGIN_FN__(
    skill >>> 0,
    __PLANNED_POS_FROM_QUEUE_FN__(player, queue),
  );
  return ({
    $: "game_state",
    meta: ({$: "game_meta", round: round >>> 0, level: level >>> 0, bot_total: botTotal >>> 0}),
    arena: ({$: "game_arena", player_hp: playerHp >>> 0, player, bots, winner: 0}),
    plan: __vibiTurnPlan(
      queue,
      queueLen >>> 0,
      queueLocked >>> 0,
      __vibiTurnTargetMode(skill >>> 0, 0, origin, runtime, queueLen >>> 0),
    ),
  });
};

__MOVE_TARGET_STATE_FN__ = function(state, dir) {
  if (!state || state.$ !== "game_state") {
    return state;
  }
  const plan = state.plan;
  const mode = plan && plan.mode;
  if (!plan || !mode || mode.$ !== "target") {
    return state;
  }
  const baseLen = __vibiTurnBaseLen(mode, plan.queue_len);
  const nextMode = __vibiTurnTargetMode(
    mode.skill,
    mode.rot,
    __STEP_TARGET_ORIGIN_FN__(mode.origin, dir >>> 0),
    mode.runtime,
    baseLen,
  );
  return __vibiTurnState(
    state,
    plan.queue,
    plan.queue_len >>> 0,
    plan.queue_locked >>> 0,
    nextMode,
  );
};

__ROTATE_TARGET_STATE_FN__ = function(state, clockwise) {
  if (!state || state.$ !== "game_state") {
    return state;
  }
  const plan = state.plan;
  const mode = plan && plan.mode;
  if (!plan || !mode || mode.$ !== "target") {
    return state;
  }
  const add = (clockwise >>> 0) === 0 ? 3 : 1;
  const rot = ((mode.rot >>> 0) + add) % 4;
  const baseLen = __vibiTurnBaseLen(mode, plan.queue_len);
  const nextMode = __vibiTurnTargetMode(
    mode.skill,
    rot >>> 0,
    __ROTATE_TARGET_ORIGIN_FN__(mode.skill, mode.rot, rot >>> 0, mode.origin),
    mode.runtime,
    baseLen,
  );
  return __vibiTurnState(
    state,
    plan.queue,
    plan.queue_len >>> 0,
    plan.queue_locked >>> 0,
    nextMode,
  );
};

__CANCEL_TARGET_STATE_FN__ = function(state) {
  if (!state || state.$ !== "game_state") {
    return state;
  }
  const plan = state.plan;
  const mode = plan && plan.mode;
  if (!plan || !mode || mode.$ !== "target") {
    return state;
  }
  const baseLen = __vibiTurnBaseLen(mode, plan.queue_len);
  const queue = __vibiTurnTrimQueue(plan.queue, plan.queue_len >>> 0, baseLen);
  return __vibiTurnState(
    state,
    queue,
    baseLen,
    0,
    __vibiTurnPlanMode(mode.runtime),
  );
};

__MOVE_INPUT_TARGET_FN__ = function(state, dir, active) {
  if ((active >>> 0) === 0) {
    return __QUEUE_MOVE_STATE_FN__(state, dir >>> 0);
  }
  return __vibiTurnBonusReady(state)
    ? __vibiTurnMoveTargetBonusState(state, dir >>> 0)
    : __MOVE_TARGET_STATE_FN__(state, dir >>> 0);
};

const __vibiOrigKeyEvent = __KEY_EVENT_FN__;
__KEY_EVENT_FN__ = function(key) {
  switch (key >>> 0) {
    case 37:
      return ({$: "evt_preview_left"});
    case 38:
      return ({$: "evt_preview_up"});
    case 39:
      return ({$: "evt_preview_right"});
    case 40:
      return ({$: "evt_preview_down"});
    default:
      return __vibiOrigKeyEvent(key >>> 0);
  }
};

const __vibiOrigOnMatchEvent = __ON_MATCH_EVENT_FN__;
__ON_MATCH_EVENT_FN__ = function(evt, state, lobby) {
  switch (evt && evt.$) {
    case "evt_preview_up":
      return __vibiTurnPreviewInputState(state, 0);
    case "evt_preview_down":
      return __vibiTurnPreviewInputState(state, 1);
    case "evt_preview_left":
      return __vibiTurnPreviewInputState(state, 2);
    case "evt_preview_right":
      return __vibiTurnPreviewInputState(state, 3);
    default:
      return __vibiOrigOnMatchEvent(evt, state, lobby);
  }
};

__BUILD_BOT_PLAN_FN__ = function(player, enemy, bots, botIdx, round, botLoadout) {
  return __vibiTurnBuildBotPlan(player, enemy, bots, botIdx, round, botLoadout);
};
__VIBI_EXTRA_PATCH__
/* __vibi_turn_patch:end */
"""


COMMON_EXTRA_PATCH = r"""
const __VIBI_LOBBY_HREF = "https://ostrowskii.github.io/vibi-fight-singleplayer/play/";
const __VIBI_LOBBY_LABEL = "Voltar lobby";

function __vibiBattleSearchParams() {
  if (typeof window === "undefined") {
    return new URLSearchParams();
  }
  return new URLSearchParams(window.location.search);
}

function __vibiBattleParseU32(params, name, fallback) {
  const raw = params.get(name);
  if (raw === null || raw === "") {
    return fallback >>> 0;
  }
  const num = Number.parseInt(raw, 10);
  if (!Number.isFinite(num) || num < 0) {
    return fallback >>> 0;
  }
  return num >>> 0;
}

function __vibiBattleFlag(params, name) {
  return __vibiBattleParseU32(params, name, 0) === 0 ? 0 : 1;
}

function __vibiBattleItemsRaw(params) {
  const raw = (params.get("items") || "").trim();
  if (!raw) {
    return "";
  }
  const seen = new Set();
  const values = [];
  for (const chunk of raw.split(",")) {
    const num = Number.parseInt(chunk, 10);
    if (!Number.isFinite(num) || num < 1 || num > __VIBI_SHARED_SKILL_COUNT || seen.has(num)) {
      continue;
    }
    seen.add(num);
    values.push(num >>> 0);
  }
  return values.join(",");
}

function __vibiBattleIsCampaign() {
  const params = __vibiBattleSearchParams();
  return (params.get("campaign") || "") === "1";
}

function __vibiBattleStoryHref() {
  const params = __vibiBattleSearchParams();
  const next = new URLSearchParams();
  next.set("screen", "city");
  next.set("level", String(__vibiBattleParseU32(params, "level", 1)));
  next.set("gold", String(__vibiBattleParseU32(params, "gold", 0)));
  next.set("ps1", String(__vibiBattleParseU32(params, "ps1", 34)));
  next.set("ps2", String(__vibiBattleParseU32(params, "ps2", 0)));
  next.set("ps3", String(__vibiBattleParseU32(params, "ps3", 0)));
  next.set("ab", String(__vibiBattleFlag(params, "ab")));
  next.set("al", String(__vibiBattleFlag(params, "al")));
  next.set("ac", String(__vibiBattleFlag(params, "ac")));
  next.set("ah", String(__vibiBattleFlag(params, "ah")));
  const items = __vibiBattleItemsRaw(params);
  if (items) {
    next.set("items", items);
  }
  return "../story/?" + next.toString();
}

function __vibiBattleReturnLink() {
  if (__vibiBattleIsCampaign()) {
    return {
      href: __vibiBattleStoryHref(),
      label: "Voltar city",
    };
  }
  return {
    href: __VIBI_LOBBY_HREF,
    label: __VIBI_LOBBY_LABEL,
  };
}

const __vibiOrigDefaultSetupSkill = __DEFAULT_SETUP_SKILL_FN__;
__DEFAULT_SETUP_SKILL_FN__ = function(side, slot) {
  switch (slot >>> 0) {
    case 0:
      return 2;
    case 1:
      return 3;
    case 2:
      return 4;
    default:
      return __vibiOrigDefaultSetupSkill(side >>> 0, slot >>> 0);
  }
};

function __vibiLobbyCount(loadout) {
  if (!loadout || loadout.$ !== "loadout") {
    return 0;
  }
  let count = 0;
  if ((loadout.s1 >>> 0) !== 0) {
    count += 1;
  }
  if ((loadout.s2 >>> 0) !== 0) {
    count += 1;
  }
  if ((loadout.s3 >>> 0) !== 0) {
    count += 1;
  }
  return count >>> 0;
}

function __vibiLobbyFallbackLoadout(loadout) {
  if (__vibiLobbyCount(loadout) !== 0) {
    return loadout;
  }
  return ({$: "loadout", s1: 2, s2: 0, s3: 0});
}

function __vibiLobbyBattleLoadouts(lobby) {
  if (!lobby || lobby.$ !== "lobby_state") {
    return lobby;
  }
  return ({
    $: "lobby_state",
    player_hp: lobby.player_hp >>> 0,
    bot_hp: lobby.bot_hp >>> 0,
    player_loadout: __vibiLobbyFallbackLoadout(lobby.player_loadout),
    bot_loadout: __vibiLobbyFallbackLoadout(lobby.bot_loadout),
    player_filter: lobby.player_filter >>> 0,
    bot_filter: lobby.bot_filter >>> 0,
  });
}

function __vibiLobbyAppWithBattleLoadouts(app) {
  if (!app || app.$ !== "app_state") {
    return app;
  }
  return ({
    $: "app_state",
    screen: app.screen,
    lobby: __vibiLobbyBattleLoadouts(app.lobby),
    game: app.game,
  });
}

const __vibiOrigSkillHookPull = __SKILL_HOOK_PULL_FN__;
__SKILL_HOOK_PULL_FN__ = function(skill) {
  if ((skill >>> 0) === 5) {
    return 2;
  }
  return __vibiOrigSkillHookPull(skill >>> 0);
};

const __vibiOrigFightAppFromSlots = __FIGHT_APP_FROM_SLOTS_FN__;
__FIGHT_APP_FROM_SLOTS_FN__ = function(ps1, ps2, ps3, bs1, bs2, bs3) {
  return __vibiLobbyAppWithBattleLoadouts(
    __vibiOrigFightAppFromSlots(
      ps1 >>> 0,
      ps2 >>> 0,
      ps3 >>> 0,
      bs1 >>> 0,
      bs2 >>> 0,
      bs3 >>> 0,
    ),
  );
};

function __vibiTurnRemainingAllWaits(state, idx, botPlans) {
  if (!state || state.$ !== "game_state") {
    return false;
  }
  const botTotal = __STATE_BOT_TOTAL_FN__(state) >>> 0;
  const queue = __STATE_QUEUE_FN__(state);
  const totalSteps = __PLAYBACK_TOTAL_STEPS_FN__(botTotal) >>> 0;
  for (let current = idx >>> 0; current < totalSteps; ++current) {
    const action = __PLAYBACK_ACTION_FN__(queue, botPlans, current >>> 0, botTotal);
    if ((__ACTION_KIND_FN__(action) >>> 0) !== 0) {
      return false;
    }
  }
  return true;
}

const __vibiOrigPlaybackStartState = __PLAYBACK_START_STATE_FN__;
__PLAYBACK_START_STATE_FN__ = function(state, idx, botPlans) {
  if (__vibiTurnRemainingAllWaits(state, idx >>> 0, botPlans)) {
    return __RESET_ROUND_PLANNING_STATE_FN__(state);
  }
  return __vibiOrigPlaybackStartState(state, idx >>> 0, botPlans);
};

function __vibiEnsureBattleModalStyle() {
  if (typeof document === "undefined") {
    return;
  }
  if (document.getElementById("vibi-battle-modal-style")) {
    return;
  }
  const style = document.createElement("style");
  style.id = "vibi-battle-modal-style";
  style.textContent = ".board-wrap{isolation:isolate;}.modal{z-index:30;}.modal__card{position:relative;z-index:31;}";
  document.head.appendChild(style);
}

function __vibiPatchBattleLobbyButton() {
  if (typeof document === "undefined") {
    return;
  }
  const actions = document.querySelector(".controls--actions");
  if (!actions) {
    return;
  }
  const reset = Array.from(actions.children).find((node) => ((node.textContent || "").trim() === "Reset partida"));
  let link = Array.from(actions.querySelectorAll("a")).find((node) => {
    const text = (node.textContent || "").trim();
    const href = node.getAttribute("href") || "";
    return href === __VIBI_LOBBY_HREF || text === "Voltar lobby" || text === "Voltar para lobby" || text === "Voltar city";
  });
  if (!link) {
    link = document.createElement("a");
  }
  const nav = __vibiBattleReturnLink();
  const className = "button button--menu button--menu-secondary nav-link";
  if (link.className !== className) {
    link.className = className;
  }
  if ((link.getAttribute("href") || "") != nav.href) {
    link.href = nav.href;
  }
  if ((link.textContent || "") !== nav.label) {
    link.textContent = nav.label;
  }
  if (reset && reset.parentNode === actions) {
    if (reset.nextElementSibling !== link) {
      reset.insertAdjacentElement("afterend", link);
    }
  } else if (link.parentNode !== actions) {
    actions.appendChild(link);
  }
}

function __vibiObserveBattleLobbyButton() {
  if (typeof document === "undefined") {
    return;
  }
  const start = () => {
    __vibiEnsureBattleModalStyle();
    __vibiPatchBattleLobbyButton();
    if (typeof MutationObserver === "undefined" || !document.body) {
      return;
    }
    const observer = new MutationObserver(() => __vibiPatchBattleLobbyButton());
    observer.observe(document.body, {
      childList: true,
      subtree: true,
    });
  };
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, {once: true});
  } else {
    start();
  }
}

__vibiObserveBattleLobbyButton();
"""


PLAY_EXTRA_PATCH = r"""
const __VIBI_LOBBY_COPY_TEXT = "Selecione ate 3 skills por lado. Se um lado entrar vazio, ele recebe Me2 por padrao na partida.";

__APP_TOGGLE_PLAYER_SKILL_NEXT_FN__ = function(app, lobby, next) {
  return __APP_WITH_LOBBY_FN__(app, __LOBBY_WITH_PLAYER_LOADOUT_FN__(lobby, next));
};

__APP_TOGGLE_BOT_SKILL_NEXT_FN__ = function(app, lobby, next) {
  return __APP_WITH_LOBBY_FN__(app, __LOBBY_WITH_BOT_LOADOUT_FN__(lobby, next));
};

const __vibiOrigAppStartMatch = __APP_START_MATCH_FN__;
__APP_START_MATCH_FN__ = function(app) {
  return __vibiOrigAppStartMatch(
    __APP_WITH_LOBBY_FN__(app, __vibiLobbyBattleLoadouts(__APP_LOBBY_FN__(app))),
  );
};

__LOBBY_PLAY_READY_FN__ = function(_lobby) {
  return 1;
};

const __vibiOrigLobbyFilterMatches = __LOBBY_FILTER_MATCHES_FN__;
__LOBBY_FILTER_MATCHES_FN__ = function(filter, skill) {
  if ((skill >>> 0) === 1) {
    return 0;
  }
  return __vibiOrigLobbyFilterMatches(filter >>> 0, skill >>> 0);
};

function __vibiPatchLobbyCopy() {
  if (typeof document === "undefined") {
    return;
  }
  const node = document.querySelector(".lobby-footer .menu-copy");
  if (node && node.textContent !== __VIBI_LOBBY_COPY_TEXT) {
    node.textContent = __VIBI_LOBBY_COPY_TEXT;
  }
}

function __vibiObserveLobbyCopy() {
  if (typeof document === "undefined") {
    return;
  }
  const start = () => {
    __vibiPatchLobbyCopy();
    if (typeof MutationObserver === "undefined" || !document.body) {
      return;
    }
    const observer = new MutationObserver(() => __vibiPatchLobbyCopy());
    observer.observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true,
    });
  };
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, {once: true});
  } else {
    start();
  }
}

__vibiObserveLobbyCopy();
"""


GAME_TEST_EXTRA_PATCH = r"""
const __vibiOrigGameTestAppFromSlotsItems = __GAME_TEST_APP_FROM_SLOTS_ITEMS_FN__;
__GAME_TEST_APP_FROM_SLOTS_ITEMS_FN__ = function(ps1, ps2, ps3, bs1, bs2, bs3, pi1, pi2, pi3, bi1, bi2, bi3) {
  return __vibiLobbyAppWithBattleLoadouts(
    __vibiOrigGameTestAppFromSlotsItems(
      ps1 >>> 0,
      ps2 >>> 0,
      ps3 >>> 0,
      bs1 >>> 0,
      bs2 >>> 0,
      bs3 >>> 0,
      pi1 >>> 0,
      pi2 >>> 0,
      pi3 >>> 0,
      bi1 >>> 0,
      bi2 >>> 0,
      bi3 >>> 0,
    ),
  );
};
"""


FIGHT_EXTRA_PATCH = r"""
const __VIBI_CAMPAIGN_PARAMS = new URLSearchParams(window.location.search);

function __vibiCampaignEnabled() {
  return (__VIBI_CAMPAIGN_PARAMS.get("campaign") || "") === "1";
}

function __vibiCampaignParseU32(name, fallback) {
  const raw = __VIBI_CAMPAIGN_PARAMS.get(name);
  if (raw === null || raw === "") {
    return fallback >>> 0;
  }
  const num = Number.parseInt(raw, 10);
  if (!Number.isFinite(num) || num < 0) {
    return fallback >>> 0;
  }
  return num >>> 0;
}

function __vibiCampaignLevel() {
  const level = __vibiCampaignParseU32("level", 1);
  if (level < 1) {
    return 1;
  }
  if (level > 12) {
    return 12;
  }
  return level >>> 0;
}

function __vibiCampaignGold() {
  return __vibiCampaignParseU32("gold", 0);
}

function __vibiCampaignReward() {
  return __vibiCampaignParseU32("reward", 200);
}

function __vibiCampaignPlayerHp() {
  const hp = __vibiCampaignParseU32("php", 50);
  return hp === 0 ? 50 : (hp >>> 0);
}

function __vibiCampaignArmorBonus(bootsParam, legsParam, chestParam, helmetParam) {
  let total = 0;
  if ((__vibiCampaignFlag(bootsParam) >>> 0) !== 0) {
    total = (total + 10) >>> 0;
  }
  if ((__vibiCampaignFlag(legsParam) >>> 0) !== 0) {
    total = (total + 20) >>> 0;
  }
  if ((__vibiCampaignFlag(chestParam) >>> 0) !== 0) {
    total = (total + 40) >>> 0;
  }
  if ((__vibiCampaignFlag(helmetParam) >>> 0) !== 0) {
    total = (total + 30) >>> 0;
  }
  return total >>> 0;
}

function __vibiCampaignBotHp() {
  const hp = __vibiCampaignParseU32("bhp", 30);
  const total = ((hp === 0 ? 30 : (hp >>> 0)) + __vibiCampaignArmorBonus("bb", "bl", "bc", "bh")) >>> 0;
  return total === 0 ? 30 : (total >>> 0);
}

function __vibiCampaignStarterLoadout() {
  return ({$: "loadout", s1: 34, s2: 0, s3: 0});
}

function __vibiCampaignFallbackBotLoadout() {
  return ({$: "loadout", s1: 1, s2: 0, s3: 0});
}

function __vibiCampaignSkillParam(name, fallback) {
  const skill = __vibiCampaignParseU32(name, fallback);
  if (skill > __VIBI_SHARED_SKILL_COUNT) {
    return fallback >>> 0;
  }
  return skill >>> 0;
}

function __vibiCampaignPlayerLoadout() {
  const loadout = ({
    $: "loadout",
    s1: __vibiCampaignSkillParam("ps1", 34),
    s2: __vibiCampaignSkillParam("ps2", 0),
    s3: __vibiCampaignSkillParam("ps3", 0),
  });
  if ((loadout.s1 >>> 0) === 0 && (loadout.s2 >>> 0) === 0 && (loadout.s3 >>> 0) === 0) {
    return __vibiCampaignStarterLoadout();
  }
  return loadout;
}

function __vibiCampaignBotLoadout() {
  const loadout = ({
    $: "loadout",
    s1: __vibiCampaignSkillParam("bs1", 1),
    s2: __vibiCampaignSkillParam("bs2", 0),
    s3: __vibiCampaignSkillParam("bs3", 0),
  });
  if ((loadout.s1 >>> 0) === 0 && (loadout.s2 >>> 0) === 0 && (loadout.s3 >>> 0) === 0) {
    return __vibiCampaignFallbackBotLoadout();
  }
  return loadout;
}

function __vibiCampaignItemsRaw() {
  const raw = (__VIBI_CAMPAIGN_PARAMS.get("items") || "").trim();
  if (!raw) {
    return "";
  }
  const seen = new Set();
  const values = [];
  for (const chunk of raw.split(",")) {
    const num = Number.parseInt(chunk, 10);
    if (!Number.isFinite(num) || num < 1 || num > __VIBI_SHARED_SKILL_COUNT || seen.has(num)) {
      continue;
    }
    seen.add(num);
    values.push(num >>> 0);
  }
  return values.join(",");
}

function __vibiCampaignFlag(name) {
  return __vibiCampaignParseU32(name, 0) === 0 ? 0 : 1;
}

function __vibiCampaignBotWithHp(bot, hp) {
  if (!bot || bot.$ !== "bot") {
    return bot;
  }
  return ({
    $: "bot",
    pos: bot.pos,
    hp: hp >>> 0,
    fire: bot.fire >>> 0,
    ice: bot.ice >>> 0,
  });
}

function __vibiCampaignBotsWithHp(items, hp) {
  if (!items || items.$ !== "cons") {
    return items;
  }
  return ({
    $: "cons",
    head: __vibiCampaignBotWithHp(items.head, hp >>> 0),
    tail: __vibiCampaignBotsWithHp(items.tail, hp >>> 0),
  });
}

function __vibiCampaignApplyFightApp(app) {
  if (!__vibiCampaignEnabled()) {
    return app;
  }
  if (!app || app.$ !== "app_state" || !app.lobby || !app.game) {
    return app;
  }
  const level = __vibiCampaignLevel();
  const playerHp = __vibiCampaignPlayerHp();
  const botHp = __vibiCampaignBotHp();
  const playerLoadout = __vibiCampaignPlayerLoadout();
  const botLoadout = __vibiCampaignBotLoadout();
  return ({
    $: "app_state",
    screen: app.screen,
    lobby: ({
      $: "lobby_state",
      player_hp: playerHp >>> 0,
      bot_hp: botHp >>> 0,
      player_loadout: playerLoadout,
      bot_loadout: botLoadout,
      player_filter: 0,
      bot_filter: 0,
    }),
    game: ({
      $: "game_state",
      meta: ({
        $: "game_meta",
        round: app.game.meta.round >>> 0,
        level: level >>> 0,
        bot_total: app.game.meta.bot_total >>> 0,
      }),
      arena: ({
        $: "game_arena",
        player_hp: playerHp >>> 0,
        player: app.game.arena.player,
        bots: __vibiCampaignBotsWithHp(app.game.arena.bots, botHp >>> 0),
        winner: app.game.arena.winner >>> 0,
      }),
      plan: app.game.plan,
    }),
  });
}

const __vibiOrigFightAppFromSlotsCampaign = __FIGHT_APP_FROM_SLOTS_FN__;
__FIGHT_APP_FROM_SLOTS_FN__ = function(ps1, ps2, ps3, bs1, bs2, bs3) {
  return __vibiCampaignApplyFightApp(
    __vibiOrigFightAppFromSlotsCampaign(
      ps1 >>> 0,
      ps2 >>> 0,
      ps3 >>> 0,
      bs1 >>> 0,
      bs2 >>> 0,
      bs3 >>> 0,
    ),
  );
};

function __vibiCampaignIsGateLevel(level) {
  return (level >>> 0) !== 0 && ((level >>> 0) % 4) === 0;
}

function __vibiCampaignNextLevel(level) {
  const next = ((level >>> 0) + 1) >>> 0;
  return next > 12 ? 12 : next;
}

function __vibiCampaignStoryHref(screen, level, gold) {
  const params = new URLSearchParams();
  params.set("screen", screen);
  params.set("level", String(level >>> 0));
  params.set("gold", String(gold >>> 0));
  params.set("ps1", String(__vibiCampaignSkillParam("ps1", 34)));
  params.set("ps2", String(__vibiCampaignSkillParam("ps2", 0)));
  params.set("ps3", String(__vibiCampaignSkillParam("ps3", 0)));
  params.set("ab", String(__vibiCampaignFlag("ab")));
  params.set("al", String(__vibiCampaignFlag("al")));
  params.set("ac", String(__vibiCampaignFlag("ac")));
  params.set("ah", String(__vibiCampaignFlag("ah")));
  const items = __vibiCampaignItemsRaw();
  if (items) {
    params.set("items", items);
  }
  return "../story/?" + params.toString();
}

function __vibiCampaignOutcome(result) {
  const level = __vibiCampaignLevel();
  const gold = __vibiCampaignGold();
  const reward = __vibiCampaignReward();
  if (result === "Vitoria") {
    const total = (gold + reward) >>> 0;
    if ((level >>> 0) >= 12) {
      return ({
        title: "Vitoria final",
        note: "Gold ganho neste round: " + reward + ".",
        href: __vibiCampaignStoryHref("victory", 12, total),
        label: "OK",
      });
    }
    return ({
      title: "Level vencido",
      note: "Gold ganho neste round: " + reward + ".",
      href: __vibiCampaignStoryHref("city", __vibiCampaignNextLevel(level), total),
      label: "OK",
    });
  }
  if (__vibiCampaignIsGateLevel(level)) {
    return ({
      title: "Game Over",
      note: "Esse level precisava ser vencido para continuar.",
      href: __vibiCampaignStoryHref("game_over", level, gold),
      label: "OK",
    });
  }
  return ({
    title: "Level perdido",
    note: "Voce pode seguir para o proximo level.",
    href: __vibiCampaignStoryHref("city", __vibiCampaignNextLevel(level), gold),
    label: "OK",
  });
}

function __vibiEnsureCampaignModalStyle() {
  if (typeof document === "undefined" || !document.head) {
    return;
  }
  if (document.getElementById("vibi-campaign-modal-style")) {
    return;
  }
  const style = document.createElement("style");
  style.id = "vibi-campaign-modal-style";
  style.textContent = ".vibi-campaign-note{margin:0;color:#6b593c;line-height:1.6;text-align:center;}.vibi-campaign-action{min-width:160px;}.vibi-campaign-tutorial{white-space:normal;}";
  document.head.appendChild(style);
}

function __vibiPatchCampaignOutcomeModal() {
  if (!__vibiCampaignEnabled() || typeof document === "undefined") {
    return;
  }
  const card = document.querySelector(".modal--visible .modal__card");
  if (!card) {
    return;
  }
  const title = card.querySelector(".modal__title");
  if (!title) {
    return;
  }
  let result = card.getAttribute("data-vibi-campaign-result") || "";
  if (!result) {
    result = (title.textContent || "").trim();
    if (result !== "Vitoria" && result !== "Derrota" && result !== "Empate") {
      return;
    }
    card.setAttribute("data-vibi-campaign-result", result);
  }
  const eyebrow = card.querySelector(".modal__eyebrow");
  if (eyebrow && eyebrow.textContent !== "Campanha") {
    eyebrow.textContent = "Campanha";
  }
  const outcome = __vibiCampaignOutcome(result);
  if (title.textContent !== outcome.title) {
    title.textContent = outcome.title;
  }
  let note = card.querySelector(".vibi-campaign-note");
  if (!note) {
    note = document.createElement("p");
    note.className = "vibi-campaign-note";
    title.insertAdjacentElement("afterend", note);
  }
  if (note.textContent !== outcome.note) {
    note.textContent = outcome.note;
  }
  const existingButton = card.querySelector("button, a");
  let action = card.querySelector(".vibi-campaign-action");
  if (!action) {
    action = document.createElement("a");
    action.className = ((existingButton && existingButton.className) || "button") + " vibi-campaign-action";
    if (existingButton && existingButton.parentNode === card) {
      existingButton.replaceWith(action);
    } else {
      card.appendChild(action);
    }
  }
  if ((action.getAttribute("href") || "") !== outcome.href) {
    action.setAttribute("href", outcome.href);
  }
  if ((action.textContent || "") !== outcome.label) {
    action.textContent = outcome.label;
  }
}

function __vibiObserveCampaignOutcomeModal() {
  if (!__vibiCampaignEnabled() || typeof document === "undefined") {
    return;
  }
  const start = () => {
    __vibiEnsureCampaignModalStyle();
    __vibiPatchCampaignOutcomeModal();
    if (typeof MutationObserver === "undefined" || !document.body) {
      return;
    }
    const observer = new MutationObserver(() => __vibiPatchCampaignOutcomeModal());
    observer.observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true,
    });
  };
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, {once: true});
  } else {
    start();
  }
}

function __vibiPatchCampaignSidebar() {
  if (!__vibiCampaignEnabled() || typeof document === "undefined") {
    return;
  }
  const sidebar = document.querySelector(".sidebar");
  if (!sidebar) {
    return;
  }
  const cards = Array.from(sidebar.querySelectorAll(".card"));
  if (cards.length < 3) {
    return;
  }
  const level = __vibiCampaignLevel();
  const gate = (__vibiCampaignIsGateLevel(level) >>> 0) !== 0;
  const reward = __vibiCampaignReward();
  const status = cards[0];
  const statusHtml =
    '<div class="stat-label">Campanha</div>' +
    '<div class="stat-value sidebar-round">Level ' + (level >>> 0) + '</div>' +
    '<div class="stat-label stat-label--spaced">Tipo</div>' +
    '<p class="sidebar-phase">' + (gate ? 'Rodada eliminatoria' : 'Duelo comum') + '</p>' +
    '<p class="help help--spaced">' + (gate ? 'Se perder aqui, a campanha acaba.' : 'Se perder aqui, voce avanca mesmo sem vencer.') + '</p>' +
    '<p class="help help--spaced">Recompensa deste duelo: ' + (reward >>> 0) + ' gold.</p>';
  if (status.innerHTML !== statusHtml) {
    status.innerHTML = statusHtml;
  }

  const controls = cards[2];
  const label = controls.querySelector(".stat-label");
  if (label && label.textContent !== "Controles e tutorial") {
    label.textContent = "Controles e tutorial";
  }
  let tutorial = controls.querySelector(".vibi-campaign-tutorial");
  if (!tutorial) {
    tutorial = document.createElement("p");
    tutorial.className = "help help--spaced vibi-campaign-tutorial";
    controls.appendChild(tutorial);
  }
  const tutorialText = "Tutorial: planeje ate 3 acoes. Use WASD/setas para mover ou ajustar a mira, 1/2/3 para entrar na skill, Q/E para girar, Space para confirmar a mira e Enter para resolver o round.";
  if ((tutorial.textContent || "") !== tutorialText) {
    tutorial.textContent = tutorialText;
  }
}

function __vibiObserveCampaignSidebar() {
  if (!__vibiCampaignEnabled() || typeof document === "undefined") {
    return;
  }
  const start = () => {
    __vibiEnsureCampaignModalStyle();
    __vibiPatchCampaignSidebar();
    if (typeof MutationObserver === "undefined" || !document.body) {
      return;
    }
    const observer = new MutationObserver(() => __vibiPatchCampaignSidebar());
    observer.observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true,
    });
  };
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, {once: true});
  } else {
    start();
  }
}

function __vibiSimEnabled() {
  return (__VIBI_CAMPAIGN_PARAMS.get("sim") || "") === "botvbot";
}

function __vibiSimParseSkill(name, fallback) {
  const skill = __vibiCampaignParseU32(name, fallback >>> 0);
  if ((skill >>> 0) > (__VIBI_SHARED_SKILL_COUNT >>> 0)) {
    return fallback >>> 0;
  }
  return skill >>> 0;
}

function __vibiSimNormalizeLoadout(loadout, fallbackSkill) {
  if (((loadout.s1 >>> 0) | (loadout.s2 >>> 0) | (loadout.s3 >>> 0)) !== 0) {
    return loadout;
  }
  return ({$: "loadout", s1: fallbackSkill >>> 0, s2: 0, s3: 0});
}

const __VIBI_SIM_PLAYER_LOADOUT = __vibiSimNormalizeLoadout(({
  $: "loadout",
  s1: __vibiSimParseSkill("ps1", 2),
  s2: __vibiSimParseSkill("ps2", 0),
  s3: __vibiSimParseSkill("ps3", 0),
}), 2);

const __VIBI_SIM_BOT_LOADOUT = __vibiSimNormalizeLoadout(({
  $: "loadout",
  s1: __vibiSimParseSkill("bs1", 2),
  s2: __vibiSimParseSkill("bs2", 0),
  s3: __vibiSimParseSkill("bs3", 0),
}), 2);

const __VIBI_SIM_ROUND_CAP = (() => {
  const cap = __vibiCampaignParseU32("simcap", 40);
  return (cap >>> 0) === 0 ? 40 : (cap >>> 0);
})();

function __vibiSimBotAlive(bot) {
  return !!bot && bot.$ === "bot" && (bot.hp >>> 0) !== 0;
}

function __vibiSimFirstLiveBot(bots) {
  let node = bots;
  while (node && node.$ === "cons") {
    if (__vibiSimBotAlive(node.head)) {
      return node.head;
    }
    node = node.tail;
  }
  return null;
}

function __vibiSimQueueLen(queue) {
  let len = 0;
  let node = queue;
  let idx = 0;
  while (node && node.$ === "cons" && idx < 4) {
    if ((__ACTION_KIND_FN__(node.head) >>> 0) !== 0) {
      len += 1;
    }
    node = node.tail;
    idx += 1;
  }
  return len >>> 0;
}

function __vibiSimQueueLocked(queue) {
  let node = queue;
  let idx = 0;
  while (node && node.$ === "cons" && idx < 4) {
    if (__vibiTurnIsAttack(node.head)) {
      return 1;
    }
    node = node.tail;
    idx += 1;
  }
  return 0;
}

function __vibiSimPlayerMoveLocked(state) {
  if (!state || state.$ !== "game_state") {
    return false;
  }
  const mode = state.plan && state.plan.mode;
  const runtime = mode && mode.runtime;
  const ice = runtime && typeof runtime.player_ice === "number"
    ? (runtime.player_ice >>> 0)
    : 0;
  return ice !== 0 && (ice % 2) === 1;
}

function __vibiSimStateWithQueue(state, queue) {
  return __vibiTurnState(
    state,
    queue,
    __vibiSimQueueLen(queue),
    __vibiSimQueueLocked(queue),
    state.plan.mode,
  );
}

function __vibiSimBuildPlayerPlan(state, loadout) {
  if (!state || state.$ !== "game_state") {
    return __QUEUE_WAITS_FN__();
  }
  const actor = state.arena.player;
  const targetBot = __vibiSimFirstLiveBot(state.arena.bots);
  if (!targetBot) {
    return __QUEUE_WAITS_FN__();
  }
  const target = targetBot.pos;
  if (__vibiSimPlayerMoveLocked(state)) {
    const lockedAttack = __FIND_ATTACK_FN__(actor, target, loadout);
    return __vibiTurnIsAttack(lockedAttack)
      ? __QUEUE3_FN__(lockedAttack, __vibiTurnWait(), __vibiTurnWait())
      : __QUEUE_WAITS_FN__();
  }

  const fallbackSkill = __ROUND_SKILL_FN__(state.meta.round >>> 0, loadout) >>> 0;
  let best = null;

  const consider = (moves) => {
    let pos = actor;
    for (const dir of moves) {
      const next = __STEP_BLOCKED_PLAYER_FN__(pos, dir >>> 0, state.arena.bots);
      if (__vibiTurnPosEq(pos, next)) {
        return;
      }
      pos = next;
    }

    const hitAttack = __FIND_ATTACK_FN__(pos, target, loadout);
    const hasAttack = __vibiTurnIsAttack(hitAttack);
    const planSkill = hasAttack ? (hitAttack.skill >>> 0) : fallbackSkill;
    const classId = __vibiTurnSkillClass(planSkill);
    if (moves.length > 2 && classId !== 1) {
      return;
    }

    const attack = hasAttack ? hitAttack : __FIRST_VALID_ATTACK_FN__(planSkill, pos);
    const dist = __vibiTurnDist(pos, target);
    const candidate = {
      score: __vibiTurnBandScore(classId, dist, hasAttack, moves.length),
      queue: __vibiTurnQueueFromMoves(moves, attack),
    };
    if (__vibiTurnBetterCandidate(candidate, best)) {
      best = candidate;
    }
  };

  consider([]);

  for (let dir1 = 0; dir1 < 4; ++dir1) {
    consider([dir1]);
    for (let dir2 = 0; dir2 < 4; ++dir2) {
      consider([dir1, dir2]);
      for (let dir3 = 0; dir3 < 4; ++dir3) {
        consider([dir1, dir2, dir3]);
      }
    }
  }

  return best === null ? __QUEUE_WAITS_FN__() : best.queue;
}

function __vibiSimOutcomePayload(state) {
  const round = state && state.$ === "game_state" ? (state.meta.round >>> 0) : 0;
  const winnerCode = state && state.$ === "game_state" ? (state.arena.winner >>> 0) : 0;
  let done = 0;
  let result = "running";
  let reason = "running";

  if (winnerCode === 1) {
    done = 1;
    result = "player";
    reason = "winner";
  } else if (winnerCode === 2) {
    done = 1;
    result = "bot";
    reason = "winner";
  } else if (winnerCode === 3) {
    done = 1;
    result = "draw";
    reason = "mutual_kill";
  } else if ((round >>> 0) > (__VIBI_SIM_ROUND_CAP >>> 0)) {
    done = 1;
    result = "draw";
    reason = "round_cap";
  }

  return {
    mode: "botvbot",
    done,
    result,
    reason,
    round,
    round_cap: __VIBI_SIM_ROUND_CAP >>> 0,
    winner_code: winnerCode,
    ps1: __VIBI_SIM_PLAYER_LOADOUT.s1 >>> 0,
    ps2: __VIBI_SIM_PLAYER_LOADOUT.s2 >>> 0,
    ps3: __VIBI_SIM_PLAYER_LOADOUT.s3 >>> 0,
    bs1: __VIBI_SIM_BOT_LOADOUT.s1 >>> 0,
    bs2: __VIBI_SIM_BOT_LOADOUT.s2 >>> 0,
    bs3: __VIBI_SIM_BOT_LOADOUT.s3 >>> 0,
    player_hp: state && state.$ === "game_state" ? (state.arena.player_hp >>> 0) : 0,
    bot_hp: state && state.$ === "game_state" && __vibiSimFirstLiveBot(state.arena.bots)
      ? (__vibiSimFirstLiveBot(state.arena.bots).hp >>> 0)
      : 0,
  };
}

function __vibiSimEnsureResultNode() {
  if (typeof document === "undefined") {
    return null;
  }
  let node = document.getElementById("vibi-sim-result");
  if (!node) {
    node = document.createElement("script");
    node.id = "vibi-sim-result";
    node.type = "application/json";
    (document.body || document.documentElement || document.head).appendChild(node);
  }
  return node;
}

function __vibiSimSyncResult(state) {
  if (!__vibiSimEnabled()) {
    return;
  }
  const node = __vibiSimEnsureResultNode();
  if (!node) {
    return;
  }
  node.textContent = JSON.stringify(__vibiSimOutcomePayload(state));
}

function __vibiSimMaybeAdvanceState(state) {
  if (!__vibiSimEnabled() || !state || state.$ !== "game_state") {
    return state;
  }
  __vibiSimSyncResult(state);
  const outcome = __vibiSimOutcomePayload(state);
  if ((outcome.done >>> 0) !== 0) {
    return state;
  }
  const mode = state.plan && state.plan.mode;
  if (!mode || mode.$ !== "plan") {
    return state;
  }
  const queuedState = __vibiSimStateWithQueue(
    state,
    __vibiSimBuildPlayerPlan(state, __VIBI_SIM_PLAYER_LOADOUT),
  );
  __vibiSimSyncResult(queuedState);
  const nextState = __READY_ROUND_STATE_FN__(queuedState, __VIBI_SIM_BOT_LOADOUT);
  __vibiSimSyncResult(nextState);
  return nextState;
}

const __vibiOrigFightAppFromSlotsSim = __FIGHT_APP_FROM_SLOTS_FN__;
__FIGHT_APP_FROM_SLOTS_FN__ = function(ps1, ps2, ps3, bs1, bs2, bs3) {
  const app = __vibiOrigFightAppFromSlotsSim(
    ps1 >>> 0,
    ps2 >>> 0,
    ps3 >>> 0,
    bs1 >>> 0,
    bs2 >>> 0,
    bs3 >>> 0,
  );
  if (!__vibiSimEnabled() || !app || app.$ !== "app_state" || !app.game) {
    return app;
  }
  const nextGame = __vibiSimMaybeAdvanceState(app.game);
  return ({
    $: "app_state",
    screen: app.screen,
    lobby: app.lobby,
    game: nextGame,
  });
};

const __vibiOrigResetRoundPlanningStateSim = __RESET_ROUND_PLANNING_STATE_FN__;
__RESET_ROUND_PLANNING_STATE_FN__ = function(state) {
  const nextState = __vibiOrigResetRoundPlanningStateSim(state);
  return __vibiSimMaybeAdvanceState(nextState);
};

const __vibiOrigOnMatchEventSim = __ON_MATCH_EVENT_FN__;
__ON_MATCH_EVENT_FN__ = function(evt, state, lobby) {
  let nextState = __vibiOrigOnMatchEventSim(evt, state, lobby);
  if (!__vibiSimEnabled() || !evt || evt.$ !== "evt_tick") {
    __vibiSimSyncResult(nextState);
    return nextState;
  }
  let guard = 0;
  while (nextState && nextState.$ === "game_state") {
    __vibiSimSyncResult(nextState);
    const outcome = __vibiSimOutcomePayload(nextState);
    const mode = nextState.plan && nextState.plan.mode;
    if ((outcome.done >>> 0) !== 0 || !mode || mode.$ !== "playback") {
      break;
    }
    nextState = __vibiOrigOnMatchEventSim(evt, nextState, lobby);
    guard += 1;
    if (guard > 512) {
      break;
    }
  }
  __vibiSimSyncResult(nextState);
  return nextState;
};

__vibiObserveCampaignOutcomeModal();
__vibiObserveCampaignSidebar();
"""

CELL_BITS = {
    "cell_attack": 1,
    "cell_dist_attack": 1,
    "cell_hook": 2,
    "cell_ice": 4,
    "cell_fire": 8,
    "cell_player": 16,
}


def extract_block(source: str, name: str) -> str:
    pattern = rf"^def {re.escape(name)}\([^\n]*\) -> [^:]+:\n(.*?)(?=^def |\Z)"
    match = re.search(pattern, source, re.MULTILINE | re.DOTALL)
    if not match:
        raise RuntimeError(f"Could not find block for {name}")
    return match.group(1)


def parse_skill_count(source: str) -> int:
    match = re.search(r"^def skill_count\(\) -> U32:\n\s+(\d+)", source, re.MULTILINE)
    if not match:
        raise RuntimeError("Could not find skill_count")
    return int(match.group(1))


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


def build_extra_skills_json() -> tuple[int, str]:
    source = FIGHT_PATH.read_text()
    skill_count = parse_skill_count(source)
    names = parse_single_value_cases(extract_block(source, "skill_name"))
    damages = parse_single_u32_cases(extract_block(source, "skill_damage"))
    ranks = parse_single_u32_cases(extract_block(source, "skill_rank"))
    class_ids = parse_single_u32_cases(extract_block(source, "skill_class_id"))
    widths = parse_single_u32_cases(extract_block(source, "skill_base_w"))
    heights = parse_single_u32_cases(extract_block(source, "skill_base_h"))
    base_cells = parse_base_cells(extract_block(source, "skill_base_cell"))

    extras: dict[int, dict[str, object]] = {}
    for skill_id in sorted(names):
        if skill_id <= 13:
            continue
        width = widths[skill_id]
        height = heights[skill_id]
        cells: dict[str, int] = {}
        for y in range(height):
            for x in range(width):
                bits = base_cells.get((skill_id, y, x), 0)
                if bits != 0:
                    cells[f"{x},{y}"] = bits
        extras[skill_id] = {
            "name": names[skill_id],
            "damage": damages[skill_id],
            "rank": ranks[skill_id],
            "classId": class_ids[skill_id],
            "w": width,
            "h": height,
            "cells": cells,
        }
    return skill_count, json.dumps(extras, separators=(",", ":"))


def encode_symbol(module_path: str, name: str, with_dollar: bool = True) -> str:
    separator = "#" if name.startswith("_") else "/"
    encoded = ("n" + (module_path + separator + name).encode().hex())
    return f"${encoded}" if with_dollar else encoded


def build_extra_patch(bundle_kind: str) -> str:
    parts = [COMMON_EXTRA_PATCH.strip()]
    if bundle_kind == "play":
        parts.append(PLAY_EXTRA_PATCH.strip())
    elif bundle_kind == "game_test":
        parts.append(GAME_TEST_EXTRA_PATCH.strip())
    elif bundle_kind == "fight":
        parts.append(FIGHT_EXTRA_PATCH.strip())
    return "\n\n".join(part for part in parts if part) + "\n"


def build_patch(module_path: str, bundle_kind: str) -> str:
    text = PATCH_TEMPLATE.replace("__VIBI_EXTRA_PATCH__", build_extra_patch(bundle_kind))
    extra_skill_count, extra_skills_json = build_extra_skills_json()
    replacements = {
        "__EXTRA_SKILL_COUNT__": str(extra_skill_count),
        "__EXTRA_SKILLS_JSON__": extra_skills_json,
        "__SKILL_COUNT_RAW_FN__": encode_symbol("/shared/fight", "skill_count", with_dollar=False),
        "__SKILL_COUNT_FN__": encode_symbol("/shared/fight", "skill_count"),
        "__SKILL_DAMAGE_RAW_FN__": encode_symbol("/shared/fight", "skill_damage", with_dollar=False),
        "__SKILL_DAMAGE_FN__": encode_symbol("/shared/fight", "skill_damage"),
        "__SKILL_RANK_RAW_FN__": encode_symbol("/shared/fight", "skill_rank", with_dollar=False),
        "__SKILL_RANK_FN__": encode_symbol("/shared/fight", "skill_rank"),
        "__SKILL_CLASS_ID_RAW_FN__": encode_symbol("/shared/fight", "skill_class_id", with_dollar=False),
        "__SKILL_CLASS_ID_FN__": encode_symbol("/shared/fight", "skill_class_id"),
        "__SKILL_NAME_RAW_FN__": encode_symbol("/shared/fight", "skill_name", with_dollar=False),
        "__SKILL_NAME_FN__": encode_symbol("/shared/fight", "skill_name"),
        "__SKILL_BASE_W_RAW_FN__": encode_symbol("/shared/fight", "skill_base_w", with_dollar=False),
        "__SKILL_BASE_W_FN__": encode_symbol("/shared/fight", "skill_base_w"),
        "__SKILL_BASE_H_RAW_FN__": encode_symbol("/shared/fight", "skill_base_h", with_dollar=False),
        "__SKILL_BASE_H_FN__": encode_symbol("/shared/fight", "skill_base_h"),
        "__SKILL_BASE_CELL_RAW_FN__": encode_symbol("/shared/fight", "skill_base_cell", with_dollar=False),
        "__SKILL_BASE_CELL_FN__": encode_symbol("/shared/fight", "skill_base_cell"),
        "__SKILL_HOOK_PULL_FN__": encode_symbol("/shared/fight", "skill_hook_pull"),
        "__DEFAULT_SETUP_SKILL_FN__": encode_symbol("/shared/fight", "default_setup_skill"),
        "__ACTION_SET_FN__": encode_symbol(module_path, "_action_set"),
        "__QUEUE3_FN__": encode_symbol(module_path, "_queue3"),
        "__QUEUE_WAITS_FN__": encode_symbol(module_path, "_queue_waits"),
        "__PLAYBACK_TOTAL_STEPS_FN__": encode_symbol(module_path, "_playback_total_steps"),
        "__PLAYBACK_ACTOR_OF_IDX_FN__": encode_symbol(module_path, "_playback_actor_of_idx"),
        "__PLAYBACK_ACTOR_IDX_OF_IDX_FN__": encode_symbol(module_path, "_playback_actor_idx_of_idx"),
        "__PLAYBACK_START_STATE_FN__": encode_symbol(module_path, "_playback_start_state"),
        "__PLAYBACK_ACTION_FN__": encode_symbol(module_path, "_playback_action"),
        "__START_TARGET_APPLY_FN__": encode_symbol(module_path, "_start_target_apply"),
        "__MOVE_TARGET_STATE_FN__": encode_symbol(module_path, "move_target_state"),
        "__ROTATE_TARGET_STATE_FN__": encode_symbol(module_path, "rotate_target_state"),
        "__CANCEL_TARGET_STATE_FN__": encode_symbol(module_path, "cancel_target_state"),
        "__MOVE_INPUT_TARGET_FN__": encode_symbol(module_path, "_move_input_target"),
        "__KEY_EVENT_FN__": encode_symbol(module_path, "key_event"),
        "__ON_MATCH_EVENT_FN__": encode_symbol(module_path, "_on_match_event"),
        "__BUILD_BOT_PLAN_FN__": encode_symbol(module_path, "_build_bot_plan"),
        "__QUEUE_MOVE_STATE_FN__": encode_symbol(module_path, "queue_move_state"),
        "__PLANNED_POS_FROM_QUEUE_FN__": encode_symbol(module_path, "_planned_pos_from_queue"),
        "__STEP_BLOCKED_PLAYER_FN__": encode_symbol(module_path, "_step_blocked_player"),
        "__STEP_BLOCKED_BOT_FN__": encode_symbol(module_path, "_step_blocked_bot"),
        "__STATE_BOT_TOTAL_FN__": encode_symbol(module_path, "_state_bot_total"),
        "__STATE_QUEUE_FN__": encode_symbol(module_path, "_state_queue"),
        "__ACTION_KIND_FN__": encode_symbol(module_path, "_action_kind"),
        "__RESET_ROUND_PLANNING_STATE_FN__": encode_symbol(module_path, "_reset_round_planning_state"),
        "__READY_ROUND_STATE_FN__": encode_symbol(module_path, "ready_round_state"),
        "__DEFAULT_TARGET_ORIGIN_FN__": encode_symbol(module_path, "_default_target_origin"),
        "__STEP_TARGET_ORIGIN_FN__": encode_symbol(module_path, "_step_target_origin"),
        "__ROTATE_TARGET_ORIGIN_FN__": encode_symbol(module_path, "_rotate_target_origin"),
        "__ROUND_SKILL_FN__": encode_symbol(module_path, "_round_skill"),
        "__FIND_ATTACK_FN__": encode_symbol(module_path, "_find_attack"),
        "__FIRST_VALID_ATTACK_FN__": encode_symbol(module_path, "_first_valid_attack"),
        "__FIGHT_APP_FROM_SLOTS_FN__": encode_symbol(module_path, "fight_app_from_slots"),
        "__APP_START_MATCH_FN__": encode_symbol(module_path, "_app_start_match"),
        "__APP_LOBBY_FN__": encode_symbol(module_path, "_app_lobby"),
        "__APP_WITH_LOBBY_FN__": encode_symbol(module_path, "_app_with_lobby"),
        "__APP_TOGGLE_PLAYER_SKILL_NEXT_FN__": encode_symbol(module_path, "_app_toggle_player_skill_next"),
        "__APP_TOGGLE_BOT_SKILL_NEXT_FN__": encode_symbol(module_path, "_app_toggle_bot_skill_next"),
        "__LOBBY_WITH_PLAYER_LOADOUT_FN__": encode_symbol(module_path, "_lobby_with_player_loadout"),
        "__LOBBY_WITH_BOT_LOADOUT_FN__": encode_symbol(module_path, "_lobby_with_bot_loadout"),
        "__LOBBY_PLAY_READY_FN__": encode_symbol(module_path, "_lobby_play_ready"),
        "__LOBBY_FILTER_MATCHES_FN__": encode_symbol(module_path, "_lobby_filter_matches"),
        "__GAME_TEST_APP_FROM_SLOTS_ITEMS_FN__": encode_symbol(module_path, "game_test_app_from_slots_items"),
    }

    for old, new in replacements.items():
        text = text.replace(old, new)
    return text


def patch_text(text: str, module_path: str, marker: str, bundle_kind: str) -> str:
    if marker not in text:
        raise SystemExit(f"marker not found for {module_path}")

    patch = build_patch(module_path, bundle_kind)

    if PATCH_START in text and PATCH_END in text:
        start = text.index(PATCH_START)
        end = text.index(PATCH_END) + len(PATCH_END)
        return text[:start] + patch.strip() + "\n\n" + text[end:]

    return text.replace(marker, patch.strip() + "\n\n" + marker, 1)


def main() -> None:
    for target in TARGETS:
        path = target["path"]
        module_path = target["module_path"]
        marker = target["marker"]
        bundle_kind = target["bundle_kind"]
        path.write_text(patch_text(path.read_text(), module_path, marker, bundle_kind))


if __name__ == "__main__":
    main()
