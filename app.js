import {
  getRules,
  getSkillCells,
  createInitialState,
  getPlannedPlayerPos,
  getMovementTrail,
  getPreviewTiles,
  getPreviewHits,
  isTargetValid,
  queueMoveState as bendQueueMoveState,
  startTargetState as bendStartTargetState,
  moveTargetState as bendMoveTargetState,
  rotateTargetState as bendRotateTargetState,
  cancelTargetState as bendCancelTargetState,
  confirmTargetState as bendConfirmTargetState,
  clearRoundPlanState as bendClearRoundPlanState,
  popLastPlannedActionState as bendPopLastPlannedActionState,
  getBotPlan as bendGetBotPlan,
  resetRoundPlanningState as bendResetRoundPlanningState,
  simulateActorAction as bendSimulateActorAction,
} from "./generated/bend-api.js";

const root = document.querySelector("#app");
if (!root) {
  throw new Error("Missing #app");
}

const rules = getRules();
const BOARD_W = rules.boardW;
const BOARD_H = rules.boardH;
const MOVE_ANIM_MS = 240;
const BLOCKED_MOVE_ANIM_MS = 180;
const ATTACK_ANIM_MS = 520;
const WAIT_ANIM_MS = 120;
const SLOT_GAP_MS = 90;
const DEATH_ANIM_MS = 560;
const SKILL_PREVIEW_GAP = 1;
const SKILL_PREVIEW_PADDING = 1;
const SKILL_PREVIEW_BOX = 53;
const SKILL_PREVIEW_MIN_CELL = 4;

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

function buildSkillPreview(cells) {
  let minX = Infinity;
  let minY = Infinity;
  let maxX = -Infinity;
  let maxY = -Infinity;

  for (const cell of cells) {
    minX = Math.min(minX, cell.x);
    minY = Math.min(minY, cell.y);
    maxX = Math.max(maxX, cell.x);
    maxY = Math.max(maxY, cell.y);
  }

  const width = maxX - minX + 1;
  const height = maxY - minY + 1;
  const usableBox = SKILL_PREVIEW_BOX - (SKILL_PREVIEW_PADDING * 2);
  const cellByWidth = Math.floor((usableBox - ((width - 1) * SKILL_PREVIEW_GAP)) / width);
  const cellByHeight = Math.floor((usableBox - ((height - 1) * SKILL_PREVIEW_GAP)) / height);
  const cellSize = Math.max(SKILL_PREVIEW_MIN_CELL, Math.min(cellByWidth, cellByHeight));

  return {
    width,
    height,
    cellSize,
    pixelWidth: (width * cellSize) + ((width - 1) * SKILL_PREVIEW_GAP) + (SKILL_PREVIEW_PADDING * 2),
    pixelHeight: (height * cellSize) + ((height - 1) * SKILL_PREVIEW_GAP) + (SKILL_PREVIEW_PADDING * 2),
    cells: cells.map((cell) => ({
      x: cell.x - minX,
      y: cell.y - minY,
    })),
  };
}

const SKILL_PREVIEWS = {
  1: buildSkillPreview(SKILLS[1][0]),
  2: buildSkillPreview(SKILLS[2][0]),
  3: buildSkillPreview(SKILLS[3][0]),
};

function clonePos(pos) {
  return { x: pos.x, y: pos.y };
}

function makeInitialState() {
  return createInitialState();
}

let game = makeInitialState();
let playback = null;

function sleep(ms) {
  return new Promise((resolve) => {
    globalThis.setTimeout(resolve, ms);
  });
}

function isResolving() {
  return playback !== null;
}

function samePos(a, b) {
  return a.x === b.x && a.y === b.y;
}

function queueMoveState(state, dir) {
  return bendQueueMoveState(state, dir);
}

function startTargetState(state, skill) {
  return bendStartTargetState(state, skill);
}

function moveTargetState(state, dir) {
  return bendMoveTargetState(state, dir);
}

function rotateTargetState(state, clockwise) {
  return bendRotateTargetState(state, clockwise);
}

function cancelTargetState(state) {
  return bendCancelTargetState(state);
}

function confirmTargetState(state) {
  return bendConfirmTargetState(state);
}

function clearRoundPlanState(state) {
  return bendClearRoundPlanState(state);
}

function popLastPlannedActionState(state) {
  return bendPopLastPlannedActionState(state);
}

function actorLabel(actor) {
  return actor === "player" ? "Player" : "IA";
}

function actorClass(actor) {
  return actor === "player" ? "player" : "enemy";
}

function hpText(hp) {
  return `${hp}/${rules.maxHp}`;
}

function playbackLabel(action) {
  if (!action) {
    return "";
  }
  if (action.kind === "wait") {
    return "parado";
  }
  if (action.kind === "move") {
    return "movimento";
  }
  return `ataque ${action.skill}`;
}

function winnerTitle(winner) {
  if (winner === 1) return "Vitoria";
  if (winner === 2) return "Derrota";
  if (winner === 3) return "Empate";
  return "";
}

function getViewState(state) {
  const resolving = isResolving();
  const actorPos = resolving ? clonePos(state.player) : getPlannedPlayerPos(state);
  const movementTrail = resolving ? [] : getMovementTrail(state);
  const targetValid =
    !resolving && state.mode.kind === "target" ? Boolean(isTargetValid(state)) : false;

  return {
    ...state,
    plannedPlayer: actorPos,
    movementTrail,
    previewTiles:
      !resolving && state.mode.kind === "target" ? getPreviewTiles(state) : [],
    previewHits:
      !resolving && state.mode.kind === "target" ? getPreviewHits(state) : [],
    targetValid,
    resolving,
    playback,
    flashTiles: playback?.attackTiles ?? [],
    moveOverlay: playback?.move ?? null,
    deathOverlay: playback?.death ?? null,
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
  if (snap.playback) {
    return `Resolvendo slot ${snap.playback.slot}: ${actorLabel(snap.playback.actor)} ${playbackLabel(snap.playback.action)}`;
  }
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

function boardOverlayMarkup(snap) {
  const layers = [];

  if (snap.moveOverlay) {
    const { actor, from, to, dir } = snap.moveOverlay;
    const deltaX = to.x - from.x;
    const deltaY = to.y - from.y;
    const bump = DIRECTIONS[dir] ?? { x: 0, y: 0 };
    const classes = ["actor-float", actorClass(actor)];
    if (deltaX === 0 && deltaY === 0) {
      classes.push("blocked");
    }

    layers.push(`
      <div class="board-anim-layer" aria-hidden="true">
        <div
          class="${classes.join(" ")}"
          style="--grid-x:${from.x}; --grid-y:${from.y}; --delta-x:${deltaX}; --delta-y:${deltaY}; --bump-x:${bump.x}; --bump-y:${bump.y}"
        >${actor === "player" ? "P" : hpText(snap.enemyHp)}</div>
      </div>
    `);
  }

  if (snap.deathOverlay) {
    layers.push(`
      <div class="board-anim-layer" aria-hidden="true">
        <div
          class="actor actor-death ${actorClass(snap.deathOverlay.actor)}"
          style="--grid-x:${snap.deathOverlay.pos.x}; --grid-y:${snap.deathOverlay.pos.y}"
        ></div>
      </div>
    `);
  }

  return layers.join("");
}

function skillPreviewMarkup(snap) {
  return [1, 2, 3]
    .map((skill) => {
      const preview = SKILL_PREVIEWS[skill];
      const filled = new Set(preview.cells.map((cell) => keyForPos(cell)));
      const active = snap.mode.kind === "target" && snap.mode.skill === skill;
      const disabled = snap.resolving ? "disabled" : "";
      const cells = [];

      for (let y = 0; y < preview.height; y += 1) {
        for (let x = 0; x < preview.width; x += 1) {
          const key = `${x}:${y}`;
          cells.push(`<span class="skill-mini-cell ${filled.has(key) ? "filled" : ""}"></span>`);
        }
      }

      return `
        <button class="skill-preview ${active ? "active" : ""}" data-skill="${skill}" ${disabled} aria-label="Skill ${skill}">
          <span class="skill-key">${skill}</span>
          <span
            class="skill-grid"
            style="--mini-cols:${preview.width}; --mini-rows:${preview.height}; --mini-cell-size:${preview.cellSize}px; width:${preview.pixelWidth}px; height:${preview.pixelHeight}px"
          >
            ${cells.join("")}
          </span>
        </button>
      `;
    })
    .join("");
}

function boardCellMarkup(snap) {
  const previewSet = new Set(snap.previewTiles.map(keyForPos));
  const hitSet = new Set(snap.previewHits.map(keyForPos));
  const flashSet = new Set(snap.flashTiles.map(keyForPos));
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
      if (flashSet.has(key)) {
        classes.push("attack-flash");
      }

      let actor = "";
      let overlay = "";
      const hidingMovingPlayer =
        snap.moveOverlay?.actor === "player" && snap.player.x === x && snap.player.y === y;
      const hidingMovingEnemy =
        (snap.moveOverlay?.actor === "enemy" || snap.deathOverlay?.actor === "enemy") &&
        snap.enemy.x === x &&
        snap.enemy.y === y;
      if (snap.player.x === x && snap.player.y === y && !hidingMovingPlayer) {
        actor = '<div class="actor player">P</div>';
      } else if (snap.enemyHp > 0 && snap.enemy.x === x && snap.enemy.y === y && !hidingMovingEnemy) {
        actor = `<div class="actor enemy enemy-hp">${hpText(snap.enemyHp)}</div>`;
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
  if (snap.resolving) {
    return "Round em resolucao. Aguarde a animacao de cada slot terminar.";
  }
  if (snap.winner !== 0) {
    return "Reset partida para recomecar.";
  }
  if (snap.mode.kind === "target") {
    return "WASD/setas movem a preview. Q/E giram. Space confirma o ataque e ja resolve o round. Esc cancela a mira. Limpar jogada apaga a fila atual.";
  }
  return "WASD/setas enfileiram ate 2 movimentos. 1/2/3 entram na mira. Space em uma mira valida confirma o ataque e ja da Ready. Esc desfaz a ultima decisao. Enter resolve o round. Limpar jogada apaga a fila atual.";
}

async function animateActorAction(slot, actor, action) {
  if (game.winner) {
    return;
  }
  if (actor === "player" && game.playerHp <= 0) {
    return;
  }
  if (actor === "enemy" && game.enemyHp <= 0) {
    return;
  }

  const outcome = bendSimulateActorAction(game, actor, action);

  if (action.kind === "wait") {
    playback = { slot, actor, action, move: null, attackTiles: [], death: null };
    game = outcome.nextState;
    render();
    await sleep(WAIT_ANIM_MS);
    return;
  }

  if (action.kind === "move") {
    const from = clonePos(outcome.from);
    const to = clonePos(outcome.to);
    game = outcome.nextState;
    playback = {
      slot,
      actor,
      action,
      move: {
        actor,
        dir: action.dir,
        from,
        to,
      },
      attackTiles: [],
      death: null,
    };
    render();
    await sleep(samePos(from, to) ? BLOCKED_MOVE_ANIM_MS : MOVE_ANIM_MS);
    playback = { slot, actor, action, move: null, attackTiles: [], death: null };
    render();
    await sleep(SLOT_GAP_MS);
    return;
  }

  const deathPos = clonePos(outcome.targetPos);
  playback = { slot, actor, action, move: null, attackTiles: outcome.attackTiles, death: null };
  render();
  await sleep(ATTACK_ANIM_MS);
  game = outcome.nextState;
  if (outcome.enemyDied) {
    playback = {
      slot,
      actor,
      action,
      move: null,
      attackTiles: [],
      death: {
        actor: "enemy",
        pos: deathPos,
      },
    };
    render();
    await sleep(DEATH_ANIM_MS);
  }
  playback = { slot, actor, action, move: null, attackTiles: [], death: null };
  render();
  await sleep(SLOT_GAP_MS);
}

async function resolveRoundAnimated() {
  if (isResolving() || game.winner || game.mode.kind === "target") {
    return;
  }

  const botQueue = bendGetBotPlan(game);
  playback = { slot: 1, actor: "player", action: game.queue[0], move: null, attackTiles: [], death: null };
  render();

  try {
    for (let slot = 0; slot < 3; slot += 1) {
      await animateActorAction(slot + 1, "player", game.queue[slot]);
      if (game.winner) {
        break;
      }
      await animateActorAction(slot + 1, "enemy", botQueue[slot]);
      if (game.winner) {
        break;
      }
    }
  } finally {
    game = bendResetRoundPlanningState(game);
    playback = null;
    render();
  }
}

function render() {
  const snap = getViewState(game);
  const controlsDisabled = snap.resolving ? "disabled" : "";

  root.innerHTML = `
    <div class="shell">
      <div class="left-rail" aria-hidden="true"></div>

      <section class="board-stage">
        <div class="board-stack">
          <div class="board-wrap board-wrap-large">
            <div class="board">${boardCellMarkup(snap)}${boardOverlayMarkup(snap)}</div>
          </div>

          <section class="board-underbar">
            <div class="player-hp-card">
              <div class="stat-label">Player HP</div>
              <div class="stat-value">${hpText(snap.playerHp)}</div>
            </div>

            <div class="queue-inline">
              ${snap.queue
                .map(
                  (action, index) => `
                    <div class="queue-slot ${snap.playback?.slot === index + 1 ? "active" : ""} ${
                      snap.playback?.slot === index + 1 && snap.playback.actor === "enemy" ? "enemy-turn" : ""
                    }">
                      <div class="slot-index">Slot ${index + 1}</div>
                      <div class="slot-value">${actionLabel(action)}</div>
                    </div>
                  `
                )
                .join("")}
            </div>

            <div class="skill-strip">
              ${skillPreviewMarkup(snap)}
            </div>
          </section>
        </div>
      </section>

      <aside class="panel sidebar">
        <section class="card sidebar-status">
          <div class="stat-label">Round</div>
          <div class="stat-value sidebar-round">${snap.round}</div>
          <div class="stat-label" style="margin-top:12px">Estado</div>
          <p class="sidebar-phase">${phaseLabel(snap)}</p>
          ${
            snap.winner !== 0
              ? `<p class="winner" style="margin-top:10px">${winnerText(snap.winner)}</p>`
              : ""
          }
          ${
            !snap.resolving && (snap.queueLen > 0 || snap.mode.kind === "target")
              ? `<p class="help" style="margin-top:10px">Preview do player: (${snap.plannedPlayer.x}, ${snap.plannedPlayer.y})</p>`
              : ""
          }
          ${
            snap.playback
              ? `<p class="help" style="margin-top:10px">Ator atual: ${actorLabel(snap.playback.actor)}. Acao atual: ${actionLabel(
                  snap.playback.action
                )}.</p>`
              : ""
          }
        </section>

        <section class="card">
          <div class="stat-label">Acoes</div>
          <div class="controls" style="margin-top:12px">
            <button class="alt" data-ready ${controlsDisabled}>Ready</button>
            <button data-clear ${controlsDisabled}>Limpar jogada</button>
            <button class="ghost" data-reset ${controlsDisabled}>Reset partida</button>
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

      ${
        snap.winner !== 0 && !snap.resolving
          ? `
            <div class="result-modal-backdrop">
              <section class="result-modal">
                <div class="eyebrow">Fim da partida</div>
                <h2 class="result-title">${winnerTitle(snap.winner)}</h2>
                <p class="result-text">Jogar novamente?</p>
                <button class="alt" data-reset-modal>Reset partida</button>
              </section>
            </div>
          `
          : ""
      }
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
    void resolveRoundAnimated();
  });

  root.querySelector("[data-clear]")?.addEventListener("click", () => {
    game = clearRoundPlanState(game);
    render();
  });

  root.querySelector("[data-reset]")?.addEventListener("click", () => {
    game = makeInitialState();
    playback = null;
    render();
  });

  root.querySelector("[data-reset-modal]")?.addEventListener("click", () => {
    game = makeInitialState();
    playback = null;
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

  if (isResolving()) {
    return;
  }

  if (key === "Enter" && snap.mode.kind !== "target") {
    void resolveRoundAnimated();
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
      const next = confirmTargetState(game);
      const confirmed = game.mode.kind === "target" && next.mode.kind !== "target";
      game = next;
      if (confirmed) {
        void resolveRoundAnimated();
        return;
      }
    } else if (key === "Escape") {
      game = cancelTargetState(game);
    }
    render();
    return;
  }

  if (key === "Escape") {
    game = popLastPlannedActionState(game);
    render();
    return;
  }

  if (dir !== null) {
    game = queueMoveState(game, dir);
    render();
  }
});

render();
