#!/usr/bin/env python3

from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "story" / "index.html"
MARKER = "__run_app(n2f73746f72792f6d61696e());"
PATCH_START = "/* __vibi_story_patch:start */"
PATCH_END = "/* __vibi_story_patch:end */"


def encode_symbol(module_path: str, name: str) -> str:
    separator = "#" if name.startswith("_") else "/"
    return "n" + (module_path + separator + name).encode().hex()


PATCH = r"""
/* __vibi_story_patch:start */
const __story_params = new URLSearchParams(window.location.search);

const __STORY_SKILLS = {
  1: {name: "Me1", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 2100},
  2: {name: "Me2", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 900},
  3: {name: "Me3", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 1360},
  4: {name: "Me4", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 2300},
  5: {name: "Ma1", classLabel: "Mage", customDescription: "", legends: ["P", "I"], damage: 0, pull: 0, cost: 460},
  6: {name: "Ma2", classLabel: "Mage", customDescription: "", legends: ["P", "F"], damage: 0, pull: 0, cost: 680},
  7: {name: "Me5", classLabel: "Melee", customDescription: "", legends: ["H"], damage: 0, pull: 2, cost: 360},
  8: {name: "Ra1", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 3000},
  9: {name: "Ma3", classLabel: "Mage", customDescription: "", legends: ["P", "I"], damage: 0, pull: 0, cost: 820},
  10: {name: "Ra2", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 1160},
  11: {name: "Ra3", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 2600},
  12: {name: "Ra4", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 800},
  13: {name: "Ra5", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 980},
  14: {name: "Me6", classLabel: "Melee", customDescription: "", legends: ["P", "D", "H"], damage: 10, pull: 4, cost: 140},
  15: {name: "Me7", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 1280},
  16: {name: "Me8", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 1980},
  17: {name: "Me10", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 1740},
  18: {name: "Me11", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 1240},
  19: {name: "Me12", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 1820},
  20: {name: "Me13", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 1900},
  21: {name: "Ra6", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 560},
  22: {name: "Ra7", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 620},
  23: {name: "Ra8", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 1580},
  24: {name: "Ra9", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 1080},
  25: {name: "Ra10", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 1500},
  26: {name: "Ra11", classLabel: "Ranged", customDescription: "", legends: ["P", "D"], damage: 10, pull: 0, cost: 760},
  27: {name: "Ma4", classLabel: "Mage", customDescription: "", legends: ["P", "D", "F"], damage: 10, pull: 0, cost: 420},
  28: {name: "Ma5", classLabel: "Mage", customDescription: "", legends: ["P", "D", "I"], damage: 10, pull: 0, cost: 280},
  29: {name: "Ma6", classLabel: "Mage", customDescription: "", legends: ["P", "D", "F"], damage: 10, pull: 0, cost: 480},
  30: {name: "Ma7", classLabel: "Mage", customDescription: "", legends: ["P", "D", "I"], damage: 10, pull: 0, cost: 220},
  31: {name: "Ma8", classLabel: "Mage", customDescription: "", legends: ["P", "D", "F"], damage: 10, pull: 0, cost: 340},
  32: {name: "Ma9", classLabel: "Mage", customDescription: "", legends: ["P", "D", "F"], damage: 10, pull: 0, cost: 240},
  33: {name: "Ma10", classLabel: "Mage", customDescription: "", legends: ["P", "D", "I"], damage: 10, pull: 0, cost: 180},
  34: {name: "Me0", classLabel: "Melee", customDescription: "", legends: ["A"], damage: 10, pull: 0, cost: 0},
};

const __STORY_SKILL_COUNT = 34;

const __STORY_LEGEND_COLORS = {
  P: "#58d8e8",
  A: "#ddb151",
  D: "#ddb151",
  H: "#2f7d32",
  I: "#70aee4",
  F: "#df8d39",
};

const __STORY_LEGEND_ORDER = ["P", "A", "D", "H", "I", "F"];

const __STORY_ARMORS = [
  {param: "ab", name: "Calcado", hp: 10, cost: 250},
  {param: "al", name: "Calca", hp: 20, cost: 450},
  {param: "ac", name: "Peitoral", hp: 40, cost: 1100},
  {param: "ah", name: "Capacete", hp: 30, cost: 700},
];

const __STORY_SHOPS = {
  1: {title: "Wizard's Tower", eyebrow: "Loja de magia", skills: [33, 30, 32, 28, 31, 27, 5, 29, 6, 9], armors: []},
  2: {title: "The Bowyer's Workshop", eyebrow: "Loja de arqueiro", skills: [21, 22, 26, 12, 13, 24, 10, 25, 23, 11, 8], armors: []},
  3: {title: "The Blacksmith's Forge", eyebrow: "Loja de espadas e armaduras", skills: [14, 7, 2, 18, 15, 3, 17, 19, 20, 16, 1, 4], armors: [0, 1, 2, 3]},
};

function __story_parse_u32(name, fallback) {
  const raw = __story_params.get(name);
  if (raw === null || raw === "") {
    return fallback >>> 0;
  }
  const num = Number.parseInt(raw, 10);
  if (!Number.isFinite(num) || num < 0) {
    return fallback >>> 0;
  }
  return num >>> 0;
}

function __story_parse_flag(name) {
  return __story_parse_u32(name, 0) === 0 ? 0 : 1;
}

function __story_screen_id() {
  const raw = (__story_params.get("screen") || "").toLowerCase();
  switch (raw) {
    case "game_over":
      return 1;
    case "victory":
      return 2;
    default:
      return 0;
  }
}

function __story_parse_level() {
  const level = __story_parse_u32("level", 1);
  if (level < 1) {
    return 1;
  }
  if (level > 12) {
    return 12;
  }
  return level >>> 0;
}

function __story_campaign_bot_loadout(level) {
  switch (level >>> 0) {
    case 2: return {s1: 14, s2: 33, s3: 0};
    case 3: return {s1: 15, s2: 21, s3: 0};
    case 4: return {s1: 2, s2: 22, s3: 0};
    case 5: return {s1: 3, s2: 12, s3: 33};
    case 6: return {s1: 18, s2: 13, s3: 27};
    case 7: return {s1: 3, s2: 10, s3: 6};
    case 8: return {s1: 16, s2: 24, s3: 29};
    case 9: return {s1: 17, s2: 23, s3: 28};
    case 10: return {s1: 19, s2: 25, s3: 10};
    case 11: return {s1: 20, s2: 11, s3: 23};
    case 12: return {s1: 4, s2: 8, s3: 11};
    default: return {s1: 1, s2: 0, s3: 0};
  }
}

function __story_campaign_bot_hp(level) {
  switch (level >>> 0) {
    case 2: return 30;
    case 3: return 34;
    case 4: return 38;
    case 5: return 44;
    case 6: return 50;
    case 7: return 58;
    case 8: return 66;
    case 9: return 75;
    case 10: return 85;
    case 11: return 96;
    case 12: return 108;
    default: return 30;
  }
}

function __story_campaign_reward_gold(level) {
  switch (level >>> 0) {
    case 2: return 220;
    case 3: return 250;
    case 4: return 290;
    case 5: return 340;
    case 6: return 400;
    case 7: return 480;
    case 8: return 570;
    case 9: return 670;
    case 10: return 790;
    case 11: return 930;
    case 12: return 1100;
    default: return 200;
  }
}

function __story_campaign_bot_armor(level) {
  switch (level >>> 0) {
    case 3: return [1, 0, 0, 0];
    case 4: return [0, 1, 0, 0];
    case 5: return [1, 1, 0, 0];
    case 6: return [0, 0, 1, 0];
    case 7: return [1, 1, 1, 1];
    case 8: return [1, 1, 1, 1];
    case 9: return [1, 1, 1, 1];
    case 10: return [1, 1, 1, 1];
    case 11: return [1, 1, 1, 1];
    case 12: return [1, 1, 1, 1];
    default: return [0, 0, 0, 0];
  }
}

function __story_campaign_is_gate_level(level) {
  switch (level >>> 0) {
    case 4:
    case 8:
    case 12:
      return 1;
    default:
      return 0;
  }
}

function __story_duel_label(state) {
  return (__story_campaign_is_gate_level(state.level >>> 0) >>> 0) !== 0
    ? "Rodada eliminatoria"
    : "Duel";
}

function __story_parse_items() {
  const raw = (__story_params.get("items") || "").trim();
  if (!raw) {
    return [];
  }
  const seen = new Set();
  const items = [];
  for (const chunk of raw.split(",")) {
    const value = Number.parseInt(chunk, 10);
    if (!Number.isFinite(value) || value < 1 || value > __STORY_SKILL_COUNT || seen.has(value)) {
      continue;
    }
    seen.add(value);
    items.push(value >>> 0);
  }
  return items;
}

function __story_parse_loadout() {
  return {
    s1: __story_parse_u32("ps1", 34),
    s2: __story_parse_u32("ps2", 0),
    s3: __story_parse_u32("ps3", 0),
  };
}

function __story_parse_open_shop() {
  const value = __story_parse_u32("shop", 0);
  return value >= 1 && value <= 3 ? value : 0;
}

function __story_parse_state() {
  return {
    screen: (__story_params.get("screen") || "city").toLowerCase(),
    level: __story_parse_level(),
    gold: __story_parse_u32("gold", 0),
    items: __story_parse_items(),
    loadout: __story_parse_loadout(),
    armor: [
      __story_parse_flag("ab"),
      __story_parse_flag("al"),
      __story_parse_flag("ac"),
      __story_parse_flag("ah"),
    ],
    openShop: __story_parse_open_shop(),
    pendingModal: null,
    warningOpen: 0,
    warningMessage: "",
  };
}

function __story_total_hp(state) {
  let total = 50;
  for (let idx = 0; idx < __STORY_ARMORS.length; ++idx) {
    if ((state.armor[idx] >>> 0) !== 0) {
      total += __STORY_ARMORS[idx].hp;
    }
  }
  return total >>> 0;
}

function __story_skill_name(skill) {
  return (__STORY_SKILLS[skill] && __STORY_SKILLS[skill].name) || "Vazio";
}

function __story_skill_meta(skill) {
  return __STORY_SKILLS[skill >>> 0] || null;
}

function __story_skill_class_label(skill) {
  return (__STORY_SKILLS[skill] && __STORY_SKILLS[skill].classLabel) || "";
}

function __story_skill_image(skill) {
  return "../assets/skills/" + __story_skill_name(skill) + ".svg";
}

function __story_escape_html(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function __story_skill_damage(skill) {
  const meta = __story_skill_meta(skill);
  return meta ? (meta.damage >>> 0) : 0;
}

function __story_skill_pull(skill) {
  const meta = __story_skill_meta(skill);
  return meta ? (meta.pull >>> 0) : 0;
}

function __story_skill_custom_description(skill) {
  const meta = __story_skill_meta(skill);
  return meta ? (meta.customDescription || "") : "";
}

function __story_skill_legends(skill) {
  const meta = __story_skill_meta(skill);
  if (!meta || !Array.isArray(meta.legends)) {
    return [];
  }
  return __STORY_LEGEND_ORDER.filter((code) => meta.legends.includes(code));
}

function __story_loadout_empty(loadout) {
  return (loadout.s1 >>> 0) === 0 && (loadout.s2 >>> 0) === 0 && (loadout.s3 >>> 0) === 0;
}

function __story_set_loadout_slot(state, idx, skill) {
  const next = skill >>> 0;
  switch (idx >>> 0) {
    case 0:
      state.loadout.s1 = next;
      break;
    case 1:
      state.loadout.s2 = next;
      break;
    case 2:
      state.loadout.s3 = next;
      break;
    default:
      break;
  }
}

function __story_duel_loadout(state) {
  if (!__story_loadout_empty(state.loadout)) {
    return state.loadout;
  }
  return {s1: 34, s2: 0, s3: 0};
}

function __story_owned_skills(state) {
  const owned = [34];
  for (const skill of state.items) {
    const value = skill >>> 0;
    if (value !== 0 && !owned.includes(value)) {
      owned.push(value);
    }
  }
  return owned;
}

function __story_skill_equipped(state, skill) {
  const value = skill >>> 0;
  return (state.loadout.s1 >>> 0) === value || (state.loadout.s2 >>> 0) === value || (state.loadout.s3 >>> 0) === value;
}

function __story_visible_owned_skills(state) {
  return __story_owned_skills(state).filter((skill) => !__story_skill_equipped(state, skill >>> 0));
}

function __story_first_free_slot(state) {
  if ((state.loadout.s1 >>> 0) === 0) {
    return 0;
  }
  if ((state.loadout.s2 >>> 0) === 0) {
    return 1;
  }
  if ((state.loadout.s3 >>> 0) === 0) {
    return 2;
  }
  return 99;
}

function __story_item_owned(state, skill) {
  return __story_owned_skills(state).includes(skill >>> 0);
}

function __story_armor_owned(state, slot) {
  return (state.armor[slot] >>> 0) !== 0;
}

function __story_build_story_search(screen, state) {
  const params = new URLSearchParams();
  params.set("screen", screen);
  params.set("level", String(state.level >>> 0));
  params.set("gold", String(state.gold >>> 0));
  params.set("ps1", String(state.loadout.s1 >>> 0));
  params.set("ps2", String(state.loadout.s2 >>> 0));
  params.set("ps3", String(state.loadout.s3 >>> 0));
  params.set("ab", String(state.armor[0] >>> 0));
  params.set("al", String(state.armor[1] >>> 0));
  params.set("ac", String(state.armor[2] >>> 0));
  params.set("ah", String(state.armor[3] >>> 0));
  if (state.items.length > 0) {
    params.set("items", state.items.join(","));
  }
  if ((state.openShop >>> 0) !== 0 && screen === "city") {
    params.set("shop", String(state.openShop >>> 0));
  }
  return params;
}

function __story_build_duel_href(state) {
  const params = new URLSearchParams();
  const duelLoadout = __story_duel_loadout(state);
  const botLoadout = __story_campaign_bot_loadout(state.level >>> 0);
  const botArmor = __story_campaign_bot_armor(state.level >>> 0);
  params.set("campaign", "1");
  params.set("level", String(state.level >>> 0));
  params.set("gold", String(state.gold >>> 0));
  params.set("reward", String(__story_campaign_reward_gold(state.level >>> 0)));
  params.set("php", String(__story_total_hp(state)));
  params.set("bhp", String(__story_campaign_bot_hp(state.level >>> 0)));
  params.set("ps1", String(duelLoadout.s1 >>> 0));
  params.set("ps2", String(duelLoadout.s2 >>> 0));
  params.set("ps3", String(duelLoadout.s3 >>> 0));
  params.set("bs1", String(botLoadout.s1 >>> 0));
  params.set("bs2", String(botLoadout.s2 >>> 0));
  params.set("bs3", String(botLoadout.s3 >>> 0));
  params.set("ab", String(state.armor[0] >>> 0));
  params.set("al", String(state.armor[1] >>> 0));
  params.set("ac", String(state.armor[2] >>> 0));
  params.set("ah", String(state.armor[3] >>> 0));
  params.set("bb", String(botArmor[0] >>> 0));
  params.set("bl", String(botArmor[1] >>> 0));
  params.set("bc", String(botArmor[2] >>> 0));
  params.set("bh", String(botArmor[3] >>> 0));
  if (state.items.length > 0) {
    params.set("items", state.items.join(","));
  }
  return "../city-duel/?" + params.toString();
}

function __story_sync_url(state) {
  if (typeof history === "undefined" || !history.replaceState) {
    return;
  }
  const next = window.location.pathname + "?" + __story_build_story_search("city", state).toString();
  if (window.location.search !== next.slice(window.location.pathname.length)) {
    history.replaceState(null, "", next);
  }
}

function __story_ensure_style() {
  if (typeof document === "undefined" || !document.head || document.getElementById("vibi-story-hub-style")) {
    return;
  }
  const style = document.createElement("style");
  style.id = "vibi-story-hub-style";
  style.textContent = `
.story-city__cell--wizard{align-content:start;justify-items:start;}
.story-city__cell--bowyer{align-content:end;justify-items:start;}
.story-city__cell--forge{align-content:end;justify-items:end;}
.story-shop-button{cursor:pointer;}
.story-city__cell--shop-open{padding:0;align-content:stretch;justify-items:stretch;}
.story-shop-panel{width:100%;height:100%;min-height:0;display:grid;grid-template-rows:auto minmax(0,1fr);gap:14px;padding:24px;background:rgba(104,61,28,.94);border:2px solid #4b2d14;box-shadow:none;justify-self:stretch;align-self:stretch;}
.story-shop-panel__head{display:flex;justify-content:space-between;gap:16px;align-items:flex-start;}
.story-shop-panel__eyebrow{font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:#e0c28d;font-weight:900;}
.story-shop-panel__title{font-size:28px;font-weight:900;line-height:1;color:#fff4dd;}
.story-shop-panel__close{width:42px;height:42px;display:grid;place-items:center;border:1px solid rgba(255,235,201,.72);border-radius:12px;background:rgba(62,35,12,.8);color:#fff2da;font-size:18px;font-weight:900;cursor:pointer;}
.story-shop-panel__body{display:grid;gap:14px;min-width:0;min-height:0;overflow-y:auto;overflow-x:hidden;align-content:start;}
.story-shop-panel__section{display:grid;gap:12px;min-width:0;align-content:start;}
.story-shop-panel__section-title{font-size:12px;letter-spacing:.14em;text-transform:uppercase;color:#e0c28d;font-weight:900;}
.story-shop-panel__grid{display:grid;grid-auto-flow:column;grid-auto-columns:96px;gap:14px;min-width:0;width:100%;overflow-x:auto;overflow-y:hidden;align-content:start;padding:0 0 6px;scrollbar-width:none;-ms-overflow-style:none;}
.story-shop-panel__grid::-webkit-scrollbar{height:0;}
.story-shop-panel__grid:hover{scrollbar-width:thin;}
.story-shop-panel__grid:hover::-webkit-scrollbar{height:8px;}
.story-shop-panel__grid::-webkit-scrollbar-thumb{background:rgba(224,194,141,.52);border-radius:999px;}
.story-shop-panel__grid::-webkit-scrollbar-track{background:transparent;}
.story-shop-card{aspect-ratio:1/1;padding:10px;display:grid;place-items:center;border:1px solid #c6a26a;border-radius:16px;background:rgba(255,244,221,.94);color:#24190f;text-align:center;cursor:pointer;}
.story-shop-card__art{width:100%;height:100%;display:grid;place-items:center;padding:2px;border:1px solid rgba(204,178,135,.42);background:#ead9bb;overflow:hidden;}
.story-shop-card__art--armor{background:#d4bc95;color:#654523;}
.story-shop-card__image{display:block;width:66%;height:66%;object-fit:contain;}
.story-shop-card__armor-bonus{font-size:14px;font-weight:900;letter-spacing:.06em;}
.story-shop-empty{padding:14px;border:1px dashed rgba(233,208,163,.36);color:#e2cfb1;font-size:13px;}
.story-inventory{width:min(100%,700px);display:grid;gap:12px;padding:18px;background:rgba(104,61,28,.92);border:2px solid #4b2d14;box-shadow:0 22px 60px rgba(17,10,4,.34);align-content:start;}
.story-inventory__head{display:flex;justify-content:space-between;gap:16px;align-items:flex-start;}
.story-inventory__title{font-size:28px;font-weight:900;line-height:1;color:#fff4dd;}
.story-inventory__meta{margin-top:6px;font-size:13px;letter-spacing:.08em;text-transform:uppercase;color:#e0c28d;}
.story-duel{display:inline-flex;align-items:center;justify-content:center;min-width:126px;padding:12px 18px;border-radius:14px;border:2px solid #d8a326;background:#f1c54a;color:#8c6006;font-weight:900;box-shadow:0 12px 30px rgba(111,71,0,.24);}
.story-inventory__body{display:grid;grid-template-columns:minmax(122px,148px) minmax(0,1fr);gap:14px;align-items:start;}
.story-inventory__column{display:grid;gap:10px;align-content:start;min-width:0;}
.story-pane{display:grid;gap:10px;padding:12px;background:rgba(79,48,23,.94);border:1px solid #6c4320;align-content:start;}
.story-pane__eyebrow{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:#e0c28d;font-weight:900;}
.story-summary{display:grid;align-content:start;min-height:0;padding:0;background:transparent;border:none;}
.story-summary__value{font-size:32px;line-height:1;color:#fff4dd;}
.story-loadout__grid{--story-loadout-size:clamp(60px,5.2vw,66px);display:grid;grid-template-columns:repeat(3,var(--story-loadout-size));gap:6px;justify-self:start;width:max-content;}
.story-loadout-slot{width:var(--story-loadout-size);height:var(--story-loadout-size);padding:0;display:grid;place-items:center;border-radius:12px;background:transparent;text-align:center;font:inherit;-webkit-appearance:none;-moz-appearance:none;appearance:none;box-sizing:border-box;box-shadow:none;outline:none;overflow:hidden;}
.story-loadout-slot[role="button"]{cursor:pointer;}
.story-loadout-slot--filled{border:1px solid rgba(233,208,163,.32);background:rgba(255,244,221,.04);}
.story-loadout-slot--empty{background:#6f4720;border:1px dashed rgba(233,208,163,.36);}
.story-loadout-slot__placeholder{display:block;width:100%;height:100%;}
.story-loadout-slot__image{display:block;width:88%;height:88%;object-fit:contain;background:transparent;border:none;box-shadow:none;pointer-events:none;}
.story-gear__grid{display:grid;grid-template-columns:repeat(2,52px);gap:10px 12px;align-content:start;}
.story-gear__item{display:grid;justify-items:start;gap:5px;}
.story-gear__slot{width:52px;aspect-ratio:1/1;border:1px solid #7b5a32;background:rgba(111,71,32,.78);box-shadow:inset 0 0 0 1px rgba(255,236,209,.06);}
.story-gear__slot--filled{background:rgba(170,128,68,.92);}
.story-gear__slot-label{font-size:10px;letter-spacing:.06em;text-transform:uppercase;color:#f1dfbb;line-height:1.2;}
.story-library__track{width:min(100%,420px);min-width:260px;min-height:0;padding:0;border:none;background:transparent;box-shadow:none;}
.story-library__viewport{width:100%;overflow-x:auto;overflow-y:hidden;padding-bottom:2px;}
.story-library__row{display:flex;gap:10px;align-items:stretch;min-width:100%;width:max-content;min-height:88px;}
.story-library__empty{min-width:200px;padding:10px 12px;display:grid;place-items:center;border:1px dashed rgba(233,208,163,.36);background:#6f4720;color:#d8bea0;font-size:12px;}
.story-library__skill{width:88px;aspect-ratio:1/1;padding:6px;display:grid;place-items:center;border:1px solid #7b5a32;border-radius:12px;background:#6f4720;cursor:pointer;font:inherit;-webkit-appearance:none;appearance:none;}
.story-library__skill-image{display:block;width:86%;height:86%;object-fit:contain;}
.story-modal-host{position:absolute;inset:0;z-index:20;pointer-events:none;}
.story-modal-layer{position:absolute;inset:0;display:grid;place-items:center;padding:24px;background:rgba(20,12,6,.58);pointer-events:auto;}
.story-purchase-modal{position:relative;z-index:1;width:min(100%,760px);display:grid;gap:18px;padding:24px;background:rgba(104,61,28,.98);border:2px solid #4b2d14;box-shadow:0 24px 60px rgba(8,4,1,.45);}
.story-purchase-modal__title{margin:0;font-size:32px;line-height:1;color:#fff4dd;}
.story-purchase-modal__body{display:grid;grid-template-columns:minmax(220px,260px) minmax(0,1fr);gap:18px;align-items:stretch;}
.story-purchase-modal__left{display:grid;grid-template-rows:auto auto;gap:14px;}
.story-purchase-modal__left--equip{grid-template-rows:1fr;align-content:center;}
.story-purchase-modal__hero{display:grid;place-items:center;}
.story-purchase-modal__art{width:min(220px,100%);aspect-ratio:1/1;display:grid;place-items:center;padding:14px;border:1px solid #ccb287;background:#ead9bb;overflow:hidden;}
.story-purchase-modal__art--armor{background:#d4bc95;color:#654523;}
.story-purchase-modal__image{display:block;width:100%;height:100%;object-fit:contain;}
.story-purchase-modal__armor-bonus{font-size:26px;font-weight:900;letter-spacing:.06em;}
.story-purchase-modal__cost{min-height:120px;padding:16px;display:grid;align-content:start;gap:8px;border:1px solid #7b5a32;background:rgba(82,49,25,.9);color:#fff4dd;}
.story-purchase-modal__cost-label,.story-purchase-modal__section-label{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:#e0c28d;font-weight:900;}
.story-purchase-modal__cost-value{font-size:28px;line-height:1;font-weight:900;}
.story-purchase-modal__right{min-height:100%;display:grid;grid-template-rows:auto auto;gap:14px;align-content:start;}
.story-purchase-modal__section{min-height:0;padding:16px;border:1px dashed rgba(233,208,163,.36);background:rgba(82,49,25,.48);display:grid;gap:10px;align-content:start;}
.story-purchase-modal__description-copy{min-height:86px;margin:0;color:#fff1d7;line-height:1.55;white-space:pre-wrap;}
.story-purchase-modal__description-copy--empty{opacity:.4;}
.story-purchase-modal__legend-list{display:grid;gap:10px;}
.story-purchase-modal__legend-item{display:grid;grid-template-columns:auto minmax(0,1fr);gap:10px;align-items:start;}
.story-purchase-modal__legend-swatch{width:14px;height:14px;margin-top:4px;border:1px solid rgba(42,24,7,.38);background:var(--story-legend-color,#ddb151);}
.story-purchase-modal__legend-copy{color:#fff1d7;line-height:1.5;}
.story-purchase-modal__confirm{display:flex;justify-content:space-between;gap:14px;align-items:center;flex-wrap:wrap;color:#fff4dd;}
.story-purchase-modal__confirm-copy{font-size:18px;font-weight:800;}
.story-purchase-modal__actions{display:flex;gap:10px;flex-wrap:wrap;}
.story-purchase-modal__button{display:inline-flex;align-items:center;justify-content:center;min-width:120px;padding:12px 18px;border:1px solid rgba(255,235,201,.72);border-radius:12px;background:rgba(62,35,12,.88);color:#fff2da;font-weight:900;cursor:pointer;}
.story-purchase-modal__button--confirm{background:#f1c54a;color:#8c6006;border-color:#d8a326;}
.story-warning-modal{position:absolute;z-index:2;width:min(100%,340px);display:grid;gap:14px;padding:20px;background:rgba(104,61,28,.99);border:2px solid #4b2d14;box-shadow:0 24px 60px rgba(8,4,1,.5);}
.story-warning-modal__title{margin:0;font-size:24px;line-height:1;color:#fff4dd;}
.story-warning-modal__copy{margin:0;color:#f0ddbc;line-height:1.5;}
.story-warning-modal__actions{display:flex;justify-content:flex-end;}
@media (max-width:900px){
  .story-city__cell--inventory,.story-city__cell--wizard,.story-city__cell--bowyer,.story-city__cell--forge{justify-items:stretch;align-content:start;}
  .story-city__cell--shop-open{padding:0 18px;}
  .story-shop-panel{height:auto;min-height:0;}
  .story-shop-panel__grid{grid-auto-columns:92px;}
  .story-purchase-modal{width:100%;}
  .story-inventory{width:100%;min-height:0;}
}
@media (max-width:640px){
  .story-inventory__head{flex-direction:column;align-items:stretch;}
  .story-duel{width:100%;}
  .story-inventory__body{grid-template-columns:1fr;}
  .story-loadout__grid{--story-loadout-size:clamp(54px,18vw,60px);gap:5px;}
  .story-library__track{width:100%;min-width:0;}
  .story-library__row{min-height:80px;}
  .story-library__skill{width:80px;}
  .story-gear__grid{grid-template-columns:repeat(2,52px);}
  .story-shop-panel__head{flex-direction:column;align-items:stretch;}
  .story-shop-panel__grid{grid-auto-columns:84px;}
  .story-purchase-modal{padding:20px;}
  .story-purchase-modal__title{font-size:28px;}
  .story-purchase-modal__body{grid-template-columns:1fr;}
  .story-purchase-modal__confirm{align-items:stretch;}
  .story-purchase-modal__actions{width:100%;}
  .story-purchase-modal__button{flex:1 1 0;}
}
`;
  document.head.appendChild(style);
}

function __story_render_skill_slot(skill, idx) {
  const name = skill === 0 ? "Vazio" : __story_skill_name(skill);
  if ((skill >>> 0) === 0) {
    return '<div class="story-loadout-slot story-loadout-slot--empty"><span class="story-loadout-slot__placeholder" aria-hidden="true"></span></div>';
  }
  return '<div class="story-loadout-slot story-loadout-slot--filled" data-unequip-slot="' + (idx >>> 0) + '" role="button" tabindex="0" aria-label="Desequipar ' + name + '"><img class="story-loadout-slot__image" src="' + __story_skill_image(skill) + '" alt="' + name + '" /></div>';
}

function __story_render_armor_slot(state, idx) {
  const armor = __STORY_ARMORS[idx];
  const filled = __story_armor_owned(state, idx) ? " story-gear__slot--filled" : "";
  return '<div class="story-gear__item"><div class="story-gear__slot' + filled + '"></div><div class="story-gear__slot-label">' + armor.name + '</div></div>';
}

function __story_render_owned_row(state) {
  const visible = __story_visible_owned_skills(state);
  if (visible.length === 0) {
    return '<div class="story-library__empty">Nenhuma skill disponivel para equipar.</div>';
  }
  return visible.map((skill) => {
    const name = __story_skill_name(skill);
    return '<button type="button" class="story-library__skill" data-equip-open="' + (skill >>> 0) + '"><img class="story-library__skill-image" src="' + __story_skill_image(skill) + '" alt="' + name + '" /></button>';
  }).join("");
}

function __story_render_inventory_shell(state) {
  const armorGrid = [
    __story_render_armor_slot(state, 0),
    __story_render_armor_slot(state, 1),
    __story_render_armor_slot(state, 2),
    __story_render_armor_slot(state, 3),
  ].join("");
  const loadoutGrid = [
    __story_render_skill_slot(state.loadout.s1 >>> 0, 0),
    __story_render_skill_slot(state.loadout.s2 >>> 0, 1),
    __story_render_skill_slot(state.loadout.s3 >>> 0, 2),
  ].join("");
  const ownedRow = __story_render_owned_row(state);
  return [
    '<div class="story-inventory__head">',
      '<div>',
        '<div class="story-inventory__title">Inventario</div>',
        '<div class="story-inventory__meta">Level ' + (state.level >>> 0) + ' - Gold ' + (state.gold >>> 0) + '</div>',
      '</div>',
      '<a class="story-duel" href="' + __story_build_duel_href(state) + '">' + __story_duel_label(state) + '</a>',
    '</div>',
    '<div class="story-inventory__body">',
      '<div class="story-inventory__column story-inventory__column--sidebar">',
        '<section class="story-pane story-pane--summary">',
          '<div class="story-pane__eyebrow">HP total</div>',
          '<div class="story-summary"><strong class="story-summary__value">' + String(__story_total_hp(state)) + '</strong></div>',
        '</section>',
        '<section class="story-pane story-pane--gear">',
          '<div class="story-pane__eyebrow">Armadura</div>',
          '<div class="story-gear__grid">' + armorGrid + '</div>',
        '</section>',
      '</div>',
      '<div class="story-inventory__column story-inventory__column--main">',
        '<section class="story-pane story-pane--loadout">',
          '<div class="story-pane__eyebrow">Skills equipadas</div>',
          '<div class="story-loadout__grid">' + loadoutGrid + '</div>',
        '</section>',
        '<section class="story-pane story-pane--library">',
          '<div class="story-pane__eyebrow">Skills compradas</div>',
          '<div class="story-library__track"><div class="story-library__viewport"><div class="story-library__row">' + ownedRow + '</div></div></div>',
        '</section>',
      '</div>',
    '</div>',
  ].join("");
}

function __story_purchase_name(kind, value) {
  if (kind === "armor") {
    return (__STORY_ARMORS[value] && __STORY_ARMORS[value].name) || "Armadura";
  }
  return __story_skill_name(value >>> 0);
}

function __story_purchase_cost(kind, value) {
  if (kind === "armor") {
    const armor = __STORY_ARMORS[value >>> 0];
    return armor ? (armor.cost >>> 0) : 0;
  }
  const meta = __story_skill_meta(value >>> 0);
  return meta ? (meta.cost >>> 0) : 0;
}

function __story_render_purchase_art(kind, value, large) {
  if (kind === "armor") {
    const armor = __STORY_ARMORS[value];
    const className = large
      ? "story-purchase-modal__art story-purchase-modal__art--armor"
      : "story-shop-card__art story-shop-card__art--armor";
    const bonusClass = large
      ? "story-purchase-modal__armor-bonus"
      : "story-shop-card__armor-bonus";
    return '<span class="' + className + '"><span class="' + bonusClass + '">HP +' + armor.hp + '</span></span>';
  }
  const name = __story_skill_name(value >>> 0);
  if (large) {
    return '<span class="story-purchase-modal__art"><img class="story-purchase-modal__image" src="' + __story_skill_image(value >>> 0) + '" alt="' + name + '" /></span>';
  }
  return '<span class="story-shop-card__art"><img class="story-shop-card__image" src="' + __story_skill_image(value >>> 0) + '" alt="' + name + '" /></span>';
}

function __story_render_purchase_description(kind, value) {
  if (kind === "armor") {
    const armor = __STORY_ARMORS[value >>> 0];
    return armor ? ('Aumenta seu HP total em ' + (armor.hp >>> 0) + '.') : "";
  }
  return __story_skill_custom_description(value >>> 0);
}

function __story_render_legend_text(skill, code) {
  const damage = __story_skill_damage(skill);
  const pull = __story_skill_pull(skill);
  switch (code) {
    case "P":
      return "Espaco de encaixe do jogador. Nao causa dano.";
    case "A":
      return "Espaco de encaixe do jogador e tambem de dano. Acerta o alvo encaixado nessa area e causa " + (damage >>> 0) + " de dano.";
    case "D":
      return "Espaco de encaixe de dano. Causa " + (damage >>> 0) + " de dano.";
    case "H":
      return "Puxa o alvo atingido na direcao do jogador por " + (pull >>> 0) + " tiles.";
    case "I":
      return "Aplica gelo no tile. Quem tocar ou passar por gelo, perde movimento no proximmo turno.";
    case "F":
      return "Aplica fogo no tile. Quem estiver sobre fogo recebe 5 de dano por turno, e o dano de queimado continua por 2 turnos depois de sair.";
    default:
      return "";
  }
}

function __story_render_purchase_legends(kind, value) {
  if (kind !== "skill") {
    return "";
  }
  const legends = __story_skill_legends(value >>> 0);
  if (legends.length === 0) {
    return "";
  }
  return legends.map((code) => {
    const color = __STORY_LEGEND_COLORS[code] || "#ddb151";
    const text = __story_escape_html(__story_render_legend_text(value >>> 0, code));
    return '<div class="story-purchase-modal__legend-item"><span class="story-purchase-modal__legend-swatch" style="--story-legend-color:' + color + ';"></span><span class="story-purchase-modal__legend-copy">' + text + '</span></div>';
  }).join("");
}

function __story_open_modal(state, mode, kind, value) {
  state.pendingModal = {mode, kind, value: value >>> 0};
  state.warningOpen = 0;
  state.warningMessage = "";
}

function __story_open_warning(state, message) {
  state.warningOpen = 1;
  state.warningMessage = message;
}

function __story_close_modal(state) {
  state.pendingModal = null;
  state.warningOpen = 0;
  state.warningMessage = "";
}

function __story_unequip_slot(state, idx) {
  __story_set_loadout_slot(state, idx >>> 0, 0);
}

function __story_confirm_purchase(state, pending) {
  const cost = __story_purchase_cost(pending.kind, pending.value);
  if ((state.gold >>> 0) < (cost >>> 0)) {
    __story_open_warning(state, "Voce nao tem gold suficiente para essa compra.");
    return;
  }
  state.gold = ((state.gold >>> 0) - (cost >>> 0)) >>> 0;
  if (pending.kind === "armor") {
    state.armor[pending.value >>> 0] = 1;
  } else if (!__story_item_owned(state, pending.value >>> 0)) {
    state.items = state.items.concat([pending.value >>> 0]);
  }
  __story_close_modal(state);
}

function __story_confirm_equip(state, pending) {
  const skill = pending.value >>> 0;
  if (!__story_item_owned(state, skill)) {
    __story_open_warning(state, "Essa skill nao esta disponivel no inventario.");
    return;
  }
  if (__story_skill_equipped(state, skill)) {
    __story_open_warning(state, "Essa skill ja esta equipada.");
    return;
  }
  const slot = __story_first_free_slot(state);
  if ((slot >>> 0) >= 3) {
    __story_open_warning(state, "Nao ha slot disponivel para equipar essa skill.");
    return;
  }
  __story_set_loadout_slot(state, slot, skill);
  __story_close_modal(state);
}

function __story_confirm_modal(state) {
  const pending = state.pendingModal;
  if (!pending) {
    return;
  }
  if (pending.mode === "purchase") {
    __story_confirm_purchase(state, pending);
    return;
  }
  if (pending.mode === "equip") {
    __story_confirm_equip(state, pending);
  }
}

function __story_render_shop_skill_card(state, skill) {
  if (__story_item_owned(state, skill)) {
    return "";
  }
  return '<button type="button" class="story-shop-card" data-purchase-open="skill:' + (skill >>> 0) + '">' + __story_render_purchase_art("skill", skill >>> 0, 0) + '</button>';
}

function __story_render_shop_armor_card(state, idx) {
  if (__story_armor_owned(state, idx)) {
    return "";
  }
  return '<button type="button" class="story-shop-card" data-purchase-open="armor:' + (idx >>> 0) + '">' + __story_render_purchase_art("armor", idx >>> 0, 0) + '</button>';
}

function __story_render_shop_panel(state, shopId) {
  const shop = __STORY_SHOPS[shopId];
  if (!shop) {
    return "";
  }
  const skillCards = shop.skills.map((skill) => __story_render_shop_skill_card(state, skill)).filter(Boolean).join("");
  const armorCards = shop.armors.map((slot) => __story_render_shop_armor_card(state, slot)).filter(Boolean).join("");
  let body = "";
  if ((shopId >>> 0) === 3) {
    body += '<div class="story-shop-panel__body">';
    body += '<div class="story-shop-panel__section"><div class="story-shop-panel__section-title">Habilidades</div><div class="story-shop-panel__grid">' + skillCards + '</div></div>';
    body += '<div class="story-shop-panel__section"><div class="story-shop-panel__section-title">Armaduras</div><div class="story-shop-panel__grid">' + armorCards + '</div></div>';
    if (!skillCards && !armorCards) {
      body += '<div class="story-shop-empty">Tudo comprado nesta loja.</div>';
    }
    body += '</div>';
  } else {
    body += '<div class="story-shop-panel__section"><div class="story-shop-panel__grid">' + skillCards + '</div>';
    if (!skillCards) {
      body += '<div class="story-shop-empty">Tudo comprado nesta loja.</div>';
    }
    body += '</div>';
  }
  return '<div class="story-shop-panel"><div class="story-shop-panel__head"><div><div class="story-shop-panel__eyebrow">' + shop.eyebrow + '</div><div class="story-shop-panel__title">' + shop.title + '</div></div><button type="button" class="story-shop-panel__close" data-shop-close="1">X</button></div>' + body + '</div>';
}

function __story_render_shop_button(shopId) {
  return '<button type="button" class="story-shop-button" data-shop-open="' + shopId + '">' + __STORY_SHOPS[shopId].title + '</button>';
}

function __story_render_pending_modal(state) {
  const pending = state.pendingModal;
  if (!pending) {
    return "";
  }
  const name = __story_purchase_name(pending.kind, pending.value);
  const description = __story_render_purchase_description(pending.kind, pending.value);
  const legends = __story_render_purchase_legends(pending.kind, pending.value);
  const descriptionClass = description ? "story-purchase-modal__description-copy" : "story-purchase-modal__description-copy story-purchase-modal__description-copy--empty";
  const descriptionHtml = description ? __story_escape_html(description) : "&nbsp;";
  let right = '<div class="story-purchase-modal__right"><div class="story-purchase-modal__section"><div class="story-purchase-modal__section-label">Descricao</div><p class="' + descriptionClass + '">' + descriptionHtml + '</p></div>';
  if (legends) {
    right += '<div class="story-purchase-modal__section"><div class="story-purchase-modal__section-label">Legenda</div><div class="story-purchase-modal__legend-list">' + legends + '</div></div>';
  }
  right += "</div>";
  let warning = "";
  if ((state.warningOpen >>> 0) !== 0) {
    warning = '<div class="story-warning-modal"><h3 class="story-warning-modal__title">Aviso</h3><p class="story-warning-modal__copy">' + __story_escape_html(state.warningMessage || "Nao foi possivel concluir essa acao.") + '</p><div class="story-warning-modal__actions"><button type="button" class="story-purchase-modal__button story-purchase-modal__button--confirm" data-warning-ok="1">OK</button></div></div>';
  }
  if (pending.mode === "equip") {
    return '<div class="story-modal-layer"><div class="story-purchase-modal"><h2 class="story-purchase-modal__title">' + name + '</h2><div class="story-purchase-modal__body"><div class="story-purchase-modal__left story-purchase-modal__left--equip"><div class="story-purchase-modal__hero">' + __story_render_purchase_art("skill", pending.value, 1) + '</div></div>' + right + '</div><div class="story-purchase-modal__confirm"><div class="story-purchase-modal__confirm-copy">Equipar no primeiro slot disponivel?</div><div class="story-purchase-modal__actions"><button type="button" class="story-purchase-modal__button story-purchase-modal__button--confirm" data-modal-confirm="1">Sim</button><button type="button" class="story-purchase-modal__button" data-modal-cancel="1">Nao</button></div></div></div>' + warning + '</div>';
  }
  const cost = __story_purchase_cost(pending.kind, pending.value);
  return '<div class="story-modal-layer"><div class="story-purchase-modal"><h2 class="story-purchase-modal__title">' + name + '</h2><div class="story-purchase-modal__body"><div class="story-purchase-modal__left"><div class="story-purchase-modal__hero">' + __story_render_purchase_art(pending.kind, pending.value, 1) + '</div><div class="story-purchase-modal__cost"><div class="story-purchase-modal__cost-label">Custo</div><div class="story-purchase-modal__cost-value">' + cost + ' gold</div></div></div>' + right + '</div><div class="story-purchase-modal__confirm"><div class="story-purchase-modal__confirm-copy">Confirmar compra?</div><div class="story-purchase-modal__actions"><button type="button" class="story-purchase-modal__button story-purchase-modal__button--confirm" data-modal-confirm="1">Sim</button><button type="button" class="story-purchase-modal__button" data-modal-cancel="1">Nao</button></div></div></div>' + warning + '</div>';
}

function __story_bind_shop_events(root, state, render) {
  root.city.querySelectorAll("[data-shop-open]").forEach((node) => {
    node.addEventListener("click", () => {
      state.openShop = Number.parseInt(node.getAttribute("data-shop-open") || "0", 10) >>> 0;
      __story_close_modal(state);
      render();
    });
  });
  root.city.querySelectorAll("[data-shop-close]").forEach((node) => {
    node.addEventListener("click", () => {
      state.openShop = 0;
      __story_close_modal(state);
      render();
    });
  });
  root.city.querySelectorAll("[data-purchase-open]").forEach((node) => {
    node.addEventListener("click", () => {
      const raw = node.getAttribute("data-purchase-open") || "";
      const parts = raw.split(":");
      if (parts.length !== 2) {
        return;
      }
      const kind = parts[0];
      const value = Number.parseInt(parts[1] || "0", 10);
      if (!Number.isFinite(value) || value < 0) {
        return;
      }
      __story_open_modal(state, "purchase", kind, value >>> 0);
      render();
    });
  });
  if (!root.modalHost) {
    return;
  }
}

function __story_bind_inventory_events(root, state, render) {
  if (!root.inventory) {
    return;
  }
  root.inventory.querySelectorAll("[data-unequip-slot]").forEach((node) => {
    const run = () => {
      const idx = Number.parseInt(node.getAttribute("data-unequip-slot") || "99", 10);
      if (!Number.isFinite(idx) || idx < 0 || idx > 2) {
        return;
      }
      __story_unequip_slot(state, idx >>> 0);
      __story_close_modal(state);
      render();
    };
    node.addEventListener("click", run);
    node.addEventListener("keydown", (event) => {
      if (event.key !== "Enter" && event.key !== " ") {
        return;
      }
      event.preventDefault();
      run();
    });
  });
  root.inventory.querySelectorAll("[data-equip-open]").forEach((node) => {
    node.addEventListener("click", () => {
      const value = Number.parseInt(node.getAttribute("data-equip-open") || "0", 10);
      if (!Number.isFinite(value) || value < 1) {
        return;
      }
      __story_open_modal(state, "equip", "skill", value >>> 0);
      render();
    });
  });
}

function __story_bind_modal_events(root, state, render) {
  if (!root.modalHost) {
    return;
  }
  root.modalHost.querySelectorAll("[data-modal-cancel]").forEach((node) => {
    node.addEventListener("click", () => {
      __story_close_modal(state);
      render();
    });
  });
  root.modalHost.querySelectorAll("[data-modal-confirm]").forEach((node) => {
    node.addEventListener("click", () => {
      __story_confirm_modal(state);
      render();
    });
  });
  root.modalHost.querySelectorAll("[data-warning-ok]").forEach((node) => {
    node.addEventListener("click", () => {
      state.warningOpen = 0;
      state.warningMessage = "";
      render();
    });
  });
}

function __story_render_inventory(root, state) {
  if (root.inventory) {
    root.inventory.innerHTML = __story_render_inventory_shell(state);
  }
}

function __story_render_modals(root, state) {
  if (root.modalHost) {
    root.modalHost.innerHTML = __story_render_pending_modal(state);
  }
}

function __story_render_shops(root, state, render) {
  for (const shopId of [1, 2, 3]) {
    const cell = root.shopCells[shopId];
    if (!cell) {
      continue;
    }
    cell.classList.toggle("story-city__cell--shop-open", (state.openShop >>> 0) === shopId);
    cell.innerHTML = (state.openShop >>> 0) === shopId
      ? __story_render_shop_panel(state, shopId)
      : __story_render_shop_button(shopId);
  }
  __story_bind_shop_events(root, state, render);
}

function __story_patch_city() {
  const city = document.querySelector(".story-city");
  if (!city) {
    return;
  }
  __story_ensure_style();
  const state = __story_parse_state();
  let modalHost = city.querySelector(".story-modal-host");
  if (!modalHost) {
    modalHost = document.createElement("div");
    modalHost.className = "story-modal-host";
    city.appendChild(modalHost);
  }
  const root = {
    city,
    modalHost,
    inventory: document.querySelector(".story-inventory"),
    shopCells: {
      1: document.querySelector(".story-city__cell--wizard"),
      2: document.querySelector(".story-city__cell--bowyer"),
      3: document.querySelector(".story-city__cell--forge"),
    },
  };
  const render = () => {
    __story_render_inventory(root, state);
    __story_bind_inventory_events(root, state, render);
    __story_render_shops(root, state, render);
    __story_render_modals(root, state);
    __story_bind_modal_events(root, state, render);
    __story_sync_url(state);
  };
  render();
}

const __story_app = n2f73746f72792f6d61696e();
__story_app.init = __INIT_FN__()(
  __story_screen_id()
)(
  __story_parse_level()
)(
  __story_parse_u32("gold", 0)
);
__run_app(__story_app);

function __story_start_patch() {
  if (typeof document === "undefined") {
    return;
  }
  const run = () => __story_patch_city();
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", run, {once: true});
  } else {
    requestAnimationFrame(run);
  }
}

__story_start_patch();
/* __vibi_story_patch:end */
""".strip().replace("__INIT_FN__", encode_symbol("/story/main", "story_app_from_query"))


def patch_text(text: str) -> str:
    if PATCH_START in text and PATCH_END in text:
        start = text.index(PATCH_START)
        end = text.index(PATCH_END) + len(PATCH_END)
        return text[:start] + PATCH + "\n\n" + text[end:]

    if MARKER not in text:
        raise SystemExit("marker not found for story/index.html")

    return text.replace(MARKER, PATCH + "\n\n", 1)


def main() -> None:
    TARGET.write_text(patch_text(TARGET.read_text()))


if __name__ == "__main__":
    main()
