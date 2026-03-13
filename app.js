import { getRules, getSkillCells } from "./generated/bend-api.js";

const root = document.querySelector("#app");
if (!root) {
  throw new Error("Missing #app");
}

const rules = getRules();
const BOARD_W = rules.boardW;
const BOARD_H = rules.boardH;
const DAMAGE = rules.damage;

const DIRECTIONS = [
  { x: 0, y: -1, label: "Up" },
  { x: 0, y: 1, label: "Down" },
  { x: -1, y: 0, label: "Left" },
  { x: 1, y: 0, label: "Right" },
];

const SKILLS = {
  1: [0, 1, 2, 3].map((rot) => getSkillCells(1, rot)),
  2: [0, 1, 2, 3].map((rot) => getSkillCells(2, rot)),
  3: [0, 1, 2, 3].map((rot) => getSkillCells(3, rot)),
};

function waitAction() {
  return { kind: "wait" };
}

function moveAction(dir) {
  return { kind: "move", dir };
}

function attackAction(skill, origin, rot) {
  return {
    kind: "attack",
    skill,
    origin: { x: origin.x, y: origin.y },
    rot,
  };
}

function clonePos(pos) {
  return { x: pos.x, y: pos.y };
}

function makeInitialState() {
  return {
    round: 1,
    level: 1,
    playerHp: rules.maxHp,
    enemyHp: rules.maxHp,
    player: clonePos(rules.playerStart),
    enemy: clonePos(rules.enemyStart),
    queue: [waitAction(), waitAction(), waitAction()],
    queueLen: 0,
    queueLocked: false,
    mode: { kind: "plan" },
    winner: 0,
  };
}

let game = makeInitialState();

function inBounds(x, y) {
  return x >= 0 && x < BOARD_W && y >= 0 && y < BOARD_H;
}

function clamp(value, min, max) {
  return Math.min(max, Math.max(min, value));
}

function addPos(pos, cell) {
  return {
    x: pos.x + cell.x,
    y: pos.y + cell.y,
  };
}

function samePos(a, b) {
  return a.x === b.x && a.y === b.y;
}

function stepFree(pos, dir) {
  const delta = DIRECTIONS[dir];
  if (!delta) return clonePos(pos);
  return {
    x: clamp(pos.x + delta.x, 0, BOARD_W - 1),
    y: clamp(pos.y + delta.y, 0, BOARD_H - 1),
  };
}

function stepBlocked(pos, dir, other) {
  const next = stepFree(pos, dir);
  return samePos(next, other) ? clonePos(pos) : next;
}

function plannedPlayerPos(state) {
  let pos = clonePos(state.player);
  for (const action of state.queue) {
    if (action.kind === "move") {
      pos = stepFree(pos, action.dir);
    }
  }
  return pos;
}

function plannedPlayerTrail(state) {
  let pos = clonePos(state.player);
  const trail = [];

  for (const action of state.queue) {
    if (action.kind === "move") {
      pos = stepFree(pos, action.dir);
      trail.push({
        x: pos.x,
        y: pos.y,
        step: trail.length + 1,
      });
    }
  }

  return trail;
}

function previewCellsFor(skill, rot, origin) {
  return SKILLS[skill][rot].map((cell) => addPos(origin, cell)).filter((cell) => inBounds(cell.x, cell.y));
}

function placementValid(skill, rot, origin, actorPos) {
  const shape = SKILLS[skill][rot];
  const world = shape.map((cell) => addPos(origin, cell));
  if (world.some((cell) => !inBounds(cell.x, cell.y))) {
    return false;
  }
  return world.some((cell) => samePos(cell, actorPos));
}

function previewHitsFor(skill, rot, origin, actorPos) {
  return previewCellsFor(skill, rot, origin).filter((cell) => !samePos(cell, actorPos));
}

function attackHits(skill, rot, origin, actorPos, targetPos) {
  if (!placementValid(skill, rot, origin, actorPos)) {
    return false;
  }
  return previewHitsFor(skill, rot, origin, actorPos).some((cell) => samePos(cell, targetPos));
}

function defaultTargetOrigin(skill, actorPos) {
  const anchor = SKILLS[skill][0][0];
  return {
    x: Math.max(0, actorPos.x - anchor.x),
    y: Math.max(0, actorPos.y - anchor.y),
  };
}

function queueMoveState(state, dir) {
  if (state.winner || state.mode.kind !== "plan" || state.queueLocked || state.queueLen >= 2) {
    return state;
  }
  const next = stepFree(plannedPlayerPos(state), dir);
  if (samePos(next, plannedPlayerPos(state))) {
    return state;
  }
  const newState = structuredClone(state);
  newState.queue[newState.queueLen] = moveAction(dir);
  newState.queueLen += 1;
  return newState;
}

function startTargetState(state, skill) {
  if (state.winner || state.queueLocked || state.queueLen >= 3) {
    return state;
  }
  const newState = structuredClone(state);
  newState.mode = {
    kind: "target",
    skill,
    rot: 0,
    origin: defaultTargetOrigin(skill, plannedPlayerPos(state)),
  };
  return newState;
}

function moveTargetState(state, dir) {
  if (state.mode.kind !== "target") {
    return state;
  }
  const newState = structuredClone(state);
  newState.mode.origin = stepFree(newState.mode.origin, dir);
  return newState;
}

function rotateTargetState(state, clockwise) {
  if (state.mode.kind !== "target") {
    return state;
  }
  const newState = structuredClone(state);
  newState.mode.rot = (newState.mode.rot + (clockwise ? 1 : 3)) % 4;
  return newState;
}

function cancelTargetState(state) {
  if (state.mode.kind !== "target") {
    return state;
  }
  const newState = structuredClone(state);
  newState.mode = { kind: "plan" };
  return newState;
}

function confirmTargetState(state) {
  if (state.mode.kind !== "target") {
    return state;
  }
  const actorPos = plannedPlayerPos(state);
  if (!placementValid(state.mode.skill, state.mode.rot, state.mode.origin, actorPos)) {
    return state;
  }
  const newState = structuredClone(state);
  newState.queue[newState.queueLen] = attackAction(state.mode.skill, state.mode.origin, state.mode.rot);
  newState.queueLen += 1;
  newState.queueLocked = true;
  newState.mode = { kind: "plan" };
  return newState;
}

function clearRoundPlanState(state) {
  if (state.winner) {
    return state;
  }

  const newState = structuredClone(state);
  newState.queue = [waitAction(), waitAction(), waitAction()];
  newState.queueLen = 0;
  newState.queueLocked = false;
  newState.mode = { kind: "plan" };
  return newState;
}

function firstValidAttack(skill, actorPos) {
  for (let rot = 0; rot < 4; rot += 1) {
    for (let y = 0; y < BOARD_H; y += 1) {
      for (let x = 0; x < BOARD_W; x += 1) {
        const origin = { x, y };
        if (placementValid(skill, rot, origin, actorPos)) {
          return attackAction(skill, origin, rot);
        }
      }
    }
  }
  return waitAction();
}

function findAttack(actorPos, targetPos) {
  for (let skill = 1; skill <= 3; skill += 1) {
    for (let rot = 0; rot < 4; rot += 1) {
      for (let y = 0; y < BOARD_H; y += 1) {
        for (let x = 0; x < BOARD_W; x += 1) {
          const origin = { x, y };
          if (attackHits(skill, rot, origin, actorPos, targetPos)) {
            return attackAction(skill, origin, rot);
          }
        }
      }
    }
  }
  return null;
}

function chaseDir(enemyPos, playerPos) {
  const dx = playerPos.x - enemyPos.x;
  const dy = playerPos.y - enemyPos.y;
  const horizontal = dx > 0 ? 3 : dx < 0 ? 2 : null;
  const vertical = dy > 0 ? 1 : dy < 0 ? 0 : null;

  if (horizontal === null && vertical === null) return null;
  if (horizontal === null) return vertical;
  if (vertical === null) return horizontal;
  if (Math.abs(dx) >= Math.abs(dy)) return horizontal;
  return vertical;
}

function fallbackPlan(state) {
  const chosenSkill = ((state.round - 1) % 3) + 1;
  const dir1 = chaseDir(state.enemy, state.player);
  const pos1 = dir1 === null ? clonePos(state.enemy) : stepFree(state.enemy, dir1);
  const dir2 = chaseDir(pos1, state.player);
  const pos2 = dir2 === null ? clonePos(pos1) : stepFree(pos1, dir2);
  return [
    dir1 === null ? waitAction() : moveAction(dir1),
    dir2 === null ? waitAction() : moveAction(dir2),
    firstValidAttack(chosenSkill, pos2),
  ];
}

function buildBotPlan(state) {
  const immediate = findAttack(state.enemy, state.player);
  if (immediate) {
    return [immediate, waitAction(), waitAction()];
  }

  for (let dir = 0; dir < 4; dir += 1) {
    const pos1 = stepFree(state.enemy, dir);
    if (samePos(pos1, state.enemy)) continue;
    const attack = findAttack(pos1, state.player);
    if (attack) {
      return [moveAction(dir), attack, waitAction()];
    }
  }

  for (let dir1 = 0; dir1 < 4; dir1 += 1) {
    const pos1 = stepFree(state.enemy, dir1);
    if (samePos(pos1, state.enemy)) continue;
    for (let dir2 = 0; dir2 < 4; dir2 += 1) {
      const pos2 = stepFree(pos1, dir2);
      if (samePos(pos2, pos1)) continue;
      const attack = findAttack(pos2, state.player);
      if (attack) {
        return [moveAction(dir1), moveAction(dir2), attack];
      }
    }
  }

  return fallbackPlan(state);
}

function computeWinner(playerHp, enemyHp) {
  if (playerHp <= 0 && enemyHp <= 0) return 3;
  if (enemyHp <= 0) return 1;
  if (playerHp <= 0) return 2;
  return 0;
}

function resolveActorAction(state, actor, action) {
  if (state.winner) return;
  if (actor === "player" && state.playerHp <= 0) return;
  if (actor === "enemy" && state.enemyHp <= 0) return;

  const selfKey = actor === "player" ? "player" : "enemy";
  const otherKey = actor === "player" ? "enemy" : "player";
  const hpKey = actor === "player" ? "enemyHp" : "playerHp";

  if (action.kind === "wait") {
    return;
  }

  if (action.kind === "move") {
    state[selfKey] = stepBlocked(state[selfKey], action.dir, state[otherKey]);
    return;
  }

  if (attackHits(action.skill, action.rot, action.origin, state[selfKey], state[otherKey])) {
    state[hpKey] = Math.max(0, state[hpKey] - DAMAGE);
    state.winner = computeWinner(state.playerHp, state.enemyHp);
  }
}

function readyRoundState(state) {
  if (state.winner || state.mode.kind === "target") {
    return state;
  }

  const next = structuredClone(state);
  const botQueue = buildBotPlan(state);

  for (let slot = 0; slot < 3; slot += 1) {
    resolveActorAction(next, "player", next.queue[slot]);
    if (next.winner) break;
    resolveActorAction(next, "enemy", botQueue[slot]);
    if (next.winner) break;
  }

  next.queue = [waitAction(), waitAction(), waitAction()];
  next.queueLen = 0;
  next.queueLocked = false;
  next.mode = { kind: "plan" };
  if (!next.winner) {
    next.round += 1;
  }
  return next;
}

function getViewState(state) {
  const actorPos = plannedPlayerPos(state);
  const movementTrail = plannedPlayerTrail(state);
  const targetValid =
    state.mode.kind === "target"
      ? placementValid(state.mode.skill, state.mode.rot, state.mode.origin, actorPos)
      : false;

  return {
    ...state,
    plannedPlayer: actorPos,
    movementTrail,
    previewTiles:
      state.mode.kind === "target"
        ? previewCellsFor(state.mode.skill, state.mode.rot, state.mode.origin)
        : [],
    previewHits:
      state.mode.kind === "target"
        ? previewHitsFor(state.mode.skill, state.mode.rot, state.mode.origin, actorPos)
        : [],
    targetValid,
  };
}

function dirLabel(dir) {
  return DIRECTIONS[dir]?.label ?? "Wait";
}

function actionLabel(action) {
  if (action.kind === "wait") {
    return "Parado";
  }
  if (action.kind === "move") {
    return `Mover ${dirLabel(action.dir)}`;
  }
  return `Ataque ${action.skill} (rot ${action.rot})`;
}

function phaseLabel(snap) {
  if (snap.winner !== 0) {
    return "Combate encerrado";
  }
  if (snap.mode.kind === "target") {
    return `Mira da habilidade ${snap.mode.skill}`;
  }
  return "Planejando round";
}

function winnerText(winner) {
  if (winner === 1) return "Vitoria do player";
  if (winner === 2) return "Vitoria da IA";
  if (winner === 3) return "Empate";
  return "";
}

function keyForPos(pos) {
  return `${pos.x}:${pos.y}`;
}

function boardCellMarkup(snap) {
  const previewSet = new Set(snap.previewTiles.map(keyForPos));
  const hitSet = new Set(snap.previewHits.map(keyForPos));
  const trailMap = new Map(snap.movementTrail.map((step) => [keyForPos(step), step.step]));
  const previewInvalid = snap.mode.kind === "target" && !snap.targetValid;
  const showPlannedPlayer = !samePos(snap.player, snap.plannedPlayer);
  const cells = [];

  for (let y = 0; y < BOARD_H; y += 1) {
    for (let x = 0; x < BOARD_W; x += 1) {
      const key = `${x}:${y}`;
      const classes = ["cell"];
      const trailStep = trailMap.get(key) ?? null;
      if (previewSet.has(key)) {
        classes.push("preview");
        if (previewInvalid) {
          classes.push("invalid");
        }
      }
      if (trailStep !== null) {
        classes.push("route");
      }
      if (hitSet.has(key)) {
        classes.push("hit");
      }

      let actor = "";
      let overlay = "";
      if (snap.player.x === x && snap.player.y === y) {
        actor = '<div class="actor player">P</div>';
      } else if (snap.enemy.x === x && snap.enemy.y === y) {
        actor = '<div class="actor enemy">AI</div>';
      }
      if (trailStep !== null) {
        overlay += `<div class="trail-badge">${trailStep}</div>`;
      }
      if (showPlannedPlayer && snap.plannedPlayer.x === x && snap.plannedPlayer.y === y) {
        overlay += '<div class="actor ghost">P</div>';
      }

      cells.push(`<div class="${classes.join(" ")}">${actor}${overlay}</div>`);
    }
  }

  return cells.join("");
}

function controlsMarkup(snap) {
  if (snap.winner !== 0) {
    return "Reset partida para recomecar.";
  }
  if (snap.mode.kind === "target") {
    return "WASD/setas movem a preview. Q/E giram. Space confirma. Esc cancela. Limpar jogada apaga a fila atual.";
  }
  return "WASD/setas enfileiram ate 2 movimentos. 1/2/3 entram na mira. Enter resolve o round. Limpar jogada apaga a fila atual.";
}

function render() {
  const snap = getViewState(game);

  root.innerHTML = `
    <div class="shell">
      <div class="left-rail" aria-hidden="true"></div>

      <section class="board-stage">
        <div class="board-wrap board-wrap-large">
          <div class="board">${boardCellMarkup(snap)}</div>
        </div>
      </section>

      <aside class="panel sidebar">
        <section class="card hero-card">
          <div class="eyebrow">Single Player Prototype</div>
          <h1 class="title title-side">Vibi Fight</h1>
          <p class="subtitle subtitle-side">Grid 9x18, round em 3 slots, 3 skills e fila de acoes em teclado.</p>
          <div class="round-chip round-chip-side">Round ${snap.round}</div>
        </section>

        <section class="stat-grid">
          <div class="card">
            <div class="stat-label">Player HP</div>
            <div class="stat-value">${snap.playerHp}</div>
          </div>
          <div class="card">
            <div class="stat-label">Enemy HP</div>
            <div class="stat-value">${snap.enemyHp}</div>
          </div>
        </section>

        <section class="card">
          <div class="stat-label">Estado</div>
          <p class="stat-value" style="font-size:22px">${phaseLabel(snap)}</p>
          ${
            snap.winner !== 0
              ? `<p class="winner" style="margin-top:10px">${winnerText(snap.winner)}</p>`
              : ""
          }
          ${
            snap.queueLen > 0 || snap.mode.kind === "target"
              ? `<p class="help" style="margin-top:10px">Preview do player: (${snap.plannedPlayer.x}, ${snap.plannedPlayer.y})</p>`
              : ""
          }
        </section>

        <section class="card">
          <div class="stat-label">Fila do Player</div>
          <div class="queue">
            ${snap.queue
              .map(
                (action, index) => `
                  <div class="queue-slot">
                    <div class="slot-index">Slot ${index + 1}</div>
                    <div class="slot-value">${actionLabel(action)}</div>
                  </div>
                `
              )
              .join("")}
          </div>
        </section>

        <section class="card">
          <div class="stat-label">Habilidades</div>
          <div class="skills" style="margin-top:12px">
            <button data-skill="1">Skill 1</button>
            <button data-skill="2">Skill 2</button>
            <button data-skill="3">Skill 3</button>
          </div>
        </section>

        <section class="card">
          <div class="stat-label">Acoes</div>
          <div class="controls" style="margin-top:12px">
            <button class="alt" data-ready>Ready</button>
            <button data-clear>Limpar jogada</button>
            <button class="ghost" data-reset>Reset partida</button>
          </div>
        </section>

        <section class="card">
          <div class="stat-label">Controles</div>
          <p class="help" style="margin-top:10px">${controlsMarkup(snap)}</p>
          ${
            snap.mode.kind === "target"
              ? `<p class="help" style="margin-top:8px">Skill ${snap.mode.skill}, rotacao ${snap.mode.rot}, origem (${snap.mode.origin.x}, ${snap.mode.origin.y}), preview ${
                  snap.targetValid ? "valida" : "invalida"
                }.</p>`
              : ""
          }
        </section>
      </aside>
    </div>
  `;

  root.querySelectorAll("[data-skill]").forEach((button) => {
    button.addEventListener("click", () => {
      const skill = Number(button.getAttribute("data-skill"));
      game = startTargetState(game, skill);
      render();
    });
  });

  root.querySelector("[data-ready]")?.addEventListener("click", () => {
    game = readyRoundState(game);
    render();
  });

  root.querySelector("[data-clear]")?.addEventListener("click", () => {
    game = clearRoundPlanState(game);
    render();
  });

  root.querySelector("[data-reset]")?.addEventListener("click", () => {
    game = makeInitialState();
    render();
  });
}

function dirFromKey(key) {
  if (key === "w" || key === "ArrowUp") return 0;
  if (key === "s" || key === "ArrowDown") return 1;
  if (key === "a" || key === "ArrowLeft") return 2;
  if (key === "d" || key === "ArrowRight") return 3;
  return null;
}

window.addEventListener("keydown", (event) => {
  const snap = getViewState(game);
  const key = event.key.length === 1 ? event.key.toLowerCase() : event.key;
  const dir = dirFromKey(key);
  const relevant =
    dir !== null ||
    key === "1" ||
    key === "2" ||
    key === "3" ||
    key === "q" ||
    key === "e" ||
    key === " " ||
    key === "Escape" ||
    key === "Enter";

  if (!relevant) {
    return;
  }

  event.preventDefault();

  if (key === "Enter" && snap.mode.kind !== "target") {
    game = readyRoundState(game);
    render();
    return;
  }

  if (key === "1" || key === "2" || key === "3") {
    game = startTargetState(game, Number(key));
    render();
    return;
  }

  if (snap.mode.kind === "target") {
    if (dir !== null) {
      game = moveTargetState(game, dir);
    } else if (key === "q") {
      game = rotateTargetState(game, false);
    } else if (key === "e") {
      game = rotateTargetState(game, true);
    } else if (key === " ") {
      game = confirmTargetState(game);
    } else if (key === "Escape") {
      game = cancelTargetState(game);
    }
    render();
    return;
  }

  if (dir !== null) {
    game = queueMoveState(game, dir);
    render();
  }
});

render();
