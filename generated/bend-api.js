import * as runtime from "./runtime.generated.js";

function hexPath(path) {
  return Array.from(new TextEncoder().encode(path), (byte) =>
    byte.toString(16).padStart(2, "0")
  ).join("");
}

function resolve(path) {
  const name = `n2f${hexPath(path)}`;
  const got = runtime[name];
  if (typeof got !== "function") {
    throw new Error(`Missing Bend export: ${path}`);
  }
  return got();
}

function listToJs(list, itemToJs) {
  const out = [];
  let cur = list;
  while (cur?.$ === "cons") {
    out.push(itemToJs(cur.head));
    cur = cur.tail;
  }
  return out;
}

function listFromJs(items, itemToBend) {
  let out = { $: "nil" };
  for (let index = items.length - 1; index >= 0; index -= 1) {
    out = {
      $: "cons",
      head: itemToBend(items[index]),
      tail: out,
    };
  }
  return out;
}

function posToJs(pos) {
  return {
    x: pos.x >>> 0,
    y: pos.y >>> 0,
  };
}

function posToBend(pos) {
  return {
    $: "pos",
    x: pos.x >>> 0,
    y: pos.y >>> 0,
  };
}

function actionToJs(action) {
  switch (action.$) {
    case "wait":
      return { kind: "wait" };
    case "move":
      return { kind: "move", dir: action.dir >>> 0 };
    case "attack":
      return {
        kind: "attack",
        skill: action.skill >>> 0,
        anchor: posToJs(action.anchor),
        rot: action.rot >>> 0,
      };
    default:
      throw new Error(`Unknown Bend action: ${action.$}`);
  }
}

function actionToBend(action) {
  switch (action.kind) {
    case "wait":
      return { $: "wait" };
    case "move":
      return { $: "move", dir: action.dir >>> 0 };
    case "attack":
      return {
        $: "attack",
        skill: action.skill >>> 0,
        anchor: posToBend(action.anchor),
        rot: action.rot >>> 0,
      };
    default:
      throw new Error(`Unknown JS action: ${action.kind}`);
  }
}

function modeToJs(mode) {
  switch (mode.$) {
    case "plan":
      return { kind: "plan" };
    case "target":
      return {
        kind: "target",
        skill: mode.skill >>> 0,
        rot: mode.rot >>> 0,
        origin: posToJs(mode.origin),
      };
    default:
      throw new Error(`Unknown Bend mode: ${mode.$}`);
  }
}

function modeToBend(mode) {
  switch (mode.kind) {
    case "plan":
      return { $: "plan" };
    case "target":
      return {
        $: "target",
        skill: mode.skill >>> 0,
        rot: mode.rot >>> 0,
        origin: posToBend(mode.origin),
      };
    default:
      throw new Error(`Unknown JS mode: ${mode.kind}`);
  }
}

function trailStepToJs(step) {
  return {
    x: step.x >>> 0,
    y: step.y >>> 0,
    step: step.step >>> 0,
  };
}

function actionSimToJs(sim) {
  return {
    from: posToJs(sim.from),
    to: posToJs(sim.to),
    targetPos: posToJs(sim.target_pos),
    attackTiles: listToJs(sim.attack_tiles, posToJs),
    nextState: stateToJs(sim.next_state),
    hit: sim.hit >>> 0,
    playerDied: sim.player_died >>> 0,
    enemyDied: sim.enemy_died >>> 0,
  };
}

function stateToJs(state) {
  return {
    round: state.round >>> 0,
    level: state.level >>> 0,
    playerHp: state.player_hp >>> 0,
    enemyHp: state.enemy_hp >>> 0,
    player: posToJs(state.player),
    enemy: posToJs(state.enemy),
    queue: listToJs(state.queue, actionToJs),
    queueLen: state.queue_len >>> 0,
    queueLocked: state.queue_locked >>> 0,
    mode: modeToJs(state.mode),
    winner: state.winner >>> 0,
  };
}

function stateToBend(state) {
  return {
    $: "game_state",
    round: state.round >>> 0,
    level: state.level >>> 0,
    player_hp: state.playerHp >>> 0,
    enemy_hp: state.enemyHp >>> 0,
    player: posToBend(state.player),
    enemy: posToBend(state.enemy),
    queue: listFromJs(state.queue, actionToBend),
    queue_len: state.queueLen >>> 0,
    queue_locked: state.queueLocked >>> 0,
    mode: modeToBend(state.mode),
    winner: state.winner >>> 0,
  };
}

const rulesGet = resolve("Runtime/rules_get");
const stateInit = resolve("Runtime/state_init");
const skillLen = resolve("Runtime/skill_len");
const skillPoint = resolve("Runtime/skill_point");
const plannedPlayerPos = resolve("Runtime/planned_player_pos");
const movementTrail = resolve("Runtime/movement_trail");
const previewTiles = resolve("Runtime/preview_tiles");
const previewHits = resolve("Runtime/preview_hits");
const targetValid = resolve("Runtime/target_valid");
const queueMoveStateRaw = resolve("Runtime/queue_move_state");
const startTargetStateRaw = resolve("Runtime/start_target_state");
const moveTargetStateRaw = resolve("Runtime/move_target_state");
const rotateTargetStateRaw = resolve("Runtime/rotate_target_state");
const cancelTargetStateRaw = resolve("Runtime/cancel_target_state");
const confirmTargetStateRaw = resolve("Runtime/confirm_target_state");
const clearRoundPlanStateRaw = resolve("Runtime/clear_round_plan_state");
const popLastPlannedActionStateRaw = resolve("Runtime/pop_last_planned_action_state");
const buildBotPlanRaw = resolve("Runtime/build_bot_plan");
const resolveActorActionStateRaw = resolve("Runtime/resolve_actor_action_state");
const resetRoundPlanningStateRaw = resolve("Runtime/reset_round_planning_state");
const simulateActorActionRaw = resolve("Runtime/simulate_actor_action");

export function getRules() {
  return {
    boardW: rulesGet.board_w >>> 0,
    boardH: rulesGet.board_h >>> 0,
    playerStart: posToJs(rulesGet.player_start),
    enemyStart: posToJs(rulesGet.enemy_start),
    maxHp: rulesGet.max_hp >>> 0,
    damage: rulesGet.damage >>> 0,
  };
}

export function getSkillCells(skill, rot) {
  const count = skillLen(skill >>> 0) >>> 0;
  const out = [];
  const pointAtRotation = skillPoint(skill >>> 0)(rot >>> 0);
  for (let index = 0; index < count; index += 1) {
    out.push(posToJs(pointAtRotation(index >>> 0)));
  }
  return out;
}

export function createInitialState() {
  return stateToJs(stateInit);
}

export function getPlannedPlayerPos(state) {
  return posToJs(plannedPlayerPos(stateToBend(state)));
}

export function getMovementTrail(state) {
  return listToJs(movementTrail(stateToBend(state)), trailStepToJs);
}

export function getPreviewTiles(state) {
  return listToJs(previewTiles(stateToBend(state)), posToJs);
}

export function getPreviewHits(state) {
  return listToJs(previewHits(stateToBend(state)), posToJs);
}

export function isTargetValid(state) {
  return targetValid(stateToBend(state)) >>> 0;
}

export function queueMoveState(state, dir) {
  return stateToJs(queueMoveStateRaw(stateToBend(state))(dir >>> 0));
}

export function startTargetState(state, skill) {
  return stateToJs(startTargetStateRaw(stateToBend(state))(skill >>> 0));
}

export function moveTargetState(state, dir) {
  return stateToJs(moveTargetStateRaw(stateToBend(state))(dir >>> 0));
}

export function rotateTargetState(state, clockwise) {
  return stateToJs(rotateTargetStateRaw(stateToBend(state))(clockwise ? 1 : 0));
}

export function cancelTargetState(state) {
  return stateToJs(cancelTargetStateRaw(stateToBend(state)));
}

export function confirmTargetState(state) {
  return stateToJs(confirmTargetStateRaw(stateToBend(state)));
}

export function clearRoundPlanState(state) {
  return stateToJs(clearRoundPlanStateRaw(stateToBend(state)));
}

export function popLastPlannedActionState(state) {
  return stateToJs(popLastPlannedActionStateRaw(stateToBend(state)));
}

export function getBotPlan(state) {
  return listToJs(buildBotPlanRaw(stateToBend(state)), actionToJs);
}

export function resolveActorActionState(state, actor, action) {
  const actorId = actor === "enemy" || actor === 1 ? 1 : 0;
  return stateToJs(
    resolveActorActionStateRaw(stateToBend(state))(actorId >>> 0)(actionToBend(action))
  );
}

export function resetRoundPlanningState(state) {
  return stateToJs(resetRoundPlanningStateRaw(stateToBend(state)));
}

export function simulateActorAction(state, actor, action) {
  const actorId = actor === "enemy" || actor === 1 ? 1 : 0;
  return actionSimToJs(
    simulateActorActionRaw(stateToBend(state))(actorId >>> 0)(actionToBend(action))
  );
}
