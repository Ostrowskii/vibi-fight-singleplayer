#!/usr/bin/env python3

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
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
        "bundle_kind": "game_test",
    },
]


PATCH_TEMPLATE = r"""
/* __vibi_turn_patch:start */
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
  return ({$: "loadout", s1: 1, s2: 0, s3: 0});
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
    return href === __VIBI_LOBBY_HREF || text === "Voltar lobby" || text === "Voltar para lobby";
  });
  if (!link) {
    link = document.createElement("a");
  }
  link.className = "button button--menu button--menu-secondary nav-link";
  link.href = __VIBI_LOBBY_HREF;
  link.textContent = __VIBI_LOBBY_LABEL;
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
    __vibiPatchBattleLobbyButton();
    if (typeof MutationObserver === "undefined" || !document.body) {
      return;
    }
    const observer = new MutationObserver(() => __vibiPatchBattleLobbyButton());
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

__vibiObserveBattleLobbyButton();
"""


PLAY_EXTRA_PATCH = r"""
const __VIBI_LOBBY_COPY_TEXT = "Selecione ate 3 skills por lado. Se um lado entrar vazio, ele recebe Me1 por padrao na partida.";

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
    return "\n\n".join(part for part in parts if part) + "\n"


def build_patch(module_path: str, bundle_kind: str) -> str:
    text = PATCH_TEMPLATE.replace("__VIBI_EXTRA_PATCH__", build_extra_patch(bundle_kind))
    replacements = {
        "__SKILL_CLASS_ID_FN__": encode_symbol("/shared/fight", "skill_class_id"),
        "__SKILL_HOOK_PULL_FN__": encode_symbol("/shared/fight", "skill_hook_pull"),
        "__ACTION_SET_FN__": encode_symbol(module_path, "_action_set"),
        "__QUEUE3_FN__": encode_symbol(module_path, "_queue3"),
        "__QUEUE_WAITS_FN__": encode_symbol(module_path, "_queue_waits"),
        "__PLAYBACK_TOTAL_STEPS_FN__": encode_symbol(module_path, "_playback_total_steps"),
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
