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

function posToJs(pos) {
  return {
    x: pos.x >>> 0,
    y: pos.y >>> 0,
  };
}

const rulesGet = resolve("Runtime/rules_get");
const skillLen = resolve("Runtime/skill_len");
const skillPoint = resolve("Runtime/skill_point");

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
