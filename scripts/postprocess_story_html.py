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
  1: {name: "Me1", classLabel: "Melee"},
  2: {name: "Me2", classLabel: "Melee"},
  3: {name: "Me3", classLabel: "Melee"},
  4: {name: "Me4", classLabel: "Melee"},
  5: {name: "Ma1", classLabel: "Mage"},
  6: {name: "Ma2", classLabel: "Mage"},
  7: {name: "Me5", classLabel: "Melee"},
  8: {name: "Ra1", classLabel: "Ranged"},
  9: {name: "Ma3", classLabel: "Mage"},
  10: {name: "Ra2", classLabel: "Ranged"},
  11: {name: "Ra3", classLabel: "Ranged"},
  12: {name: "Ra4", classLabel: "Ranged"},
  13: {name: "Ra5", classLabel: "Ranged"},
};

const __STORY_ARMORS = [
  {param: "ab", name: "Calcado", hp: 10},
  {param: "al", name: "Calca", hp: 20},
  {param: "ac", name: "Peitoral", hp: 40},
  {param: "ah", name: "Capacete", hp: 30},
];

const __STORY_SHOPS = {
  1: {title: "Wizard's Tower", eyebrow: "Loja de magia", skills: [5, 6, 9], armors: []},
  2: {title: "The Bowyer's Workshop", eyebrow: "Loja de arqueiro", skills: [8, 10, 11, 12, 13], armors: []},
  3: {title: "The Blacksmith's Forge", eyebrow: "Loja de espadas e armaduras", skills: [2, 3, 4, 7], armors: [0, 1, 2, 3]},
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

function __story_parse_items() {
  const raw = (__story_params.get("items") || "").trim();
  if (!raw) {
    return [];
  }
  const seen = new Set();
  const items = [];
  for (const chunk of raw.split(",")) {
    const value = Number.parseInt(chunk, 10);
    if (!Number.isFinite(value) || value < 1 || value > 13 || seen.has(value)) {
      continue;
    }
    seen.add(value);
    items.push(value >>> 0);
  }
  return items;
}

function __story_parse_loadout() {
  const loadout = {
    s1: __story_parse_u32("ps1", 1),
    s2: __story_parse_u32("ps2", 0),
    s3: __story_parse_u32("ps3", 0),
  };
  if ((loadout.s1 >>> 0) === 0) {
    loadout.s1 = 1;
  }
  return loadout;
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
    pendingPurchase: null,
    warningOpen: 0,
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

function __story_skill_class_label(skill) {
  return (__STORY_SKILLS[skill] && __STORY_SKILLS[skill].classLabel) || "";
}

function __story_skill_image(skill) {
  return "../assets/skills/" + __story_skill_name(skill) + ".svg";
}

function __story_item_owned(state, skill) {
  return state.items.includes(skill >>> 0);
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
  params.set("campaign", "1");
  params.set("level", String(state.level >>> 0));
  params.set("gold", String(state.gold >>> 0));
  params.set("reward", "200");
  params.set("php", String(__story_total_hp(state)));
  params.set("bhp", "30");
  params.set("ps1", String(state.loadout.s1 >>> 0));
  params.set("ps2", String(state.loadout.s2 >>> 0));
  params.set("ps3", String(state.loadout.s3 >>> 0));
  params.set("bs1", "1");
  params.set("bs2", "0");
  params.set("bs3", "0");
  params.set("ab", String(state.armor[0] >>> 0));
  params.set("al", String(state.armor[1] >>> 0));
  params.set("ac", String(state.armor[2] >>> 0));
  params.set("ah", String(state.armor[3] >>> 0));
  if (state.items.length > 0) {
    params.set("items", state.items.join(","));
  }
  return "../fight/?" + params.toString();
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
.story-shop-panel__body{display:grid;gap:14px;min-width:0;min-height:0;overflow:auto;align-content:start;}
.story-shop-panel__section{display:grid;gap:12px;min-width:0;align-content:start;}
.story-shop-panel__section-title{font-size:12px;letter-spacing:.14em;text-transform:uppercase;color:#e0c28d;font-weight:900;}
.story-shop-panel__grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(96px,1fr));gap:14px;min-width:0;align-content:start;}
.story-shop-card{aspect-ratio:1/1;padding:10px;display:grid;place-items:center;border:1px solid #c6a26a;border-radius:16px;background:rgba(255,244,221,.94);color:#24190f;text-align:center;cursor:pointer;}
.story-shop-card__art{width:100%;height:100%;display:grid;place-items:center;padding:8px;border:1px solid #ccb287;background:#ead9bb;overflow:hidden;}
.story-shop-card__art--armor{background:#d4bc95;color:#654523;}
.story-shop-card__image{display:block;width:100%;height:100%;object-fit:contain;}
.story-shop-card__armor-bonus{font-size:14px;font-weight:900;letter-spacing:.06em;}
.story-shop-empty{padding:14px;border:1px dashed rgba(233,208,163,.36);color:#e2cfb1;font-size:13px;}
.story-armor__grid{grid-template-columns:repeat(2,32px);gap:8px 10px;}
.story-armor__item{gap:4px;}
.story-armor__slot{width:32px;}
.story-armor__slot-label{font-size:9px;letter-spacing:.05em;}
.story-owned__row{display:flex;gap:10px;align-items:stretch;min-width:100%;width:max-content;min-height:64px;}
.story-owned__empty{min-width:200px;padding:10px 12px;display:grid;place-items:center;border:1px dashed rgba(233,208,163,.36);color:#d8bea0;font-size:12px;}
.story-owned__skill{width:76px;min-height:86px;padding:8px;display:grid;justify-items:center;align-content:start;gap:5px;border:1px solid #c6a26a;border-radius:12px;background:rgba(255,244,221,.92);text-align:center;}
.story-owned__skill-art{width:40px;height:40px;display:grid;place-items:center;padding:3px;border:1px solid #ccb287;background:#ead9bb;overflow:hidden;}
.story-owned__skill-image{display:block;width:100%;height:100%;object-fit:contain;}
.story-owned__skill-name{font-size:10px;font-weight:800;color:#24190f;line-height:1.2;}
.story-modal-host{position:absolute;inset:0;z-index:20;pointer-events:none;}
.story-modal-layer{position:absolute;inset:0;display:grid;place-items:center;padding:24px;background:rgba(20,12,6,.58);pointer-events:auto;}
.story-purchase-modal{position:relative;z-index:1;width:min(100%,760px);display:grid;gap:18px;padding:24px;background:rgba(104,61,28,.98);border:2px solid #4b2d14;box-shadow:0 24px 60px rgba(8,4,1,.45);}
.story-purchase-modal__title{margin:0;font-size:32px;line-height:1;color:#fff4dd;}
.story-purchase-modal__hero{display:grid;place-items:center;}
.story-purchase-modal__art{width:min(220px,100%);aspect-ratio:1/1;display:grid;place-items:center;padding:14px;border:1px solid #ccb287;background:#ead9bb;overflow:hidden;}
.story-purchase-modal__art--armor{background:#d4bc95;color:#654523;}
.story-purchase-modal__image{display:block;width:100%;height:100%;object-fit:contain;}
.story-purchase-modal__armor-bonus{font-size:26px;font-weight:900;letter-spacing:.06em;}
.story-purchase-modal__details{display:grid;grid-template-columns:180px minmax(0,1fr);gap:14px;}
.story-purchase-modal__cost{min-height:120px;padding:16px;display:grid;align-content:start;gap:8px;border:1px solid #7b5a32;background:rgba(82,49,25,.9);color:#fff4dd;}
.story-purchase-modal__cost-label,.story-purchase-modal__description-label{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:#e0c28d;font-weight:900;}
.story-purchase-modal__cost-value{font-size:28px;line-height:1;font-weight:900;}
.story-purchase-modal__description{min-height:120px;padding:16px;border:1px dashed rgba(233,208,163,.36);background:rgba(82,49,25,.48);}
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
  .story-shop-panel__grid{grid-template-columns:repeat(2,minmax(0,1fr));}
  .story-purchase-modal{width:100%;}
}
@media (max-width:640px){
  .story-shop-panel__head{flex-direction:column;align-items:stretch;}
  .story-shop-panel__grid{grid-template-columns:repeat(2,minmax(0,1fr));}
  .story-purchase-modal{padding:20px;}
  .story-purchase-modal__title{font-size:28px;}
  .story-purchase-modal__details{grid-template-columns:1fr;}
  .story-purchase-modal__confirm{align-items:stretch;}
  .story-purchase-modal__actions{width:100%;}
  .story-purchase-modal__button{flex:1 1 0;}
}
`;
  document.head.appendChild(style);
}

function __story_render_skill_slot(skill, idx) {
  const name = skill === 0 ? "Vazio" : __story_skill_name(skill);
  const art = skill === 0
    ? '<span class="story-slot__art story-slot__art--empty"></span>'
    : '<span class="story-slot__art"><img class="story-slot__image" src="' + __story_skill_image(skill) + '" alt="' + name + '" /></span>';
  const className = skill === 0 ? "story-slot story-slot--empty" : "story-slot";
  return '<div class="' + className + '"><span class="story-slot__index">' + (idx + 1) + '</span><span class="story-slot__name">' + name + '</span>' + art + '</div>';
}

function __story_render_armor_slot(state, idx) {
  const armor = __STORY_ARMORS[idx];
  const filled = __story_armor_owned(state, idx) ? " story-armor__slot--filled" : "";
  return '<div class="story-armor__item"><div class="story-armor__slot' + filled + '"></div><div class="story-armor__slot-label">' + armor.name + '</div></div>';
}

function __story_render_owned_row(state) {
  if (state.items.length === 0) {
    return '<div class="story-owned__empty">Nenhuma skill comprada ainda.</div>';
  }
  return state.items.map((skill) => {
    const name = __story_skill_name(skill);
    return '<div class="story-owned__skill"><span class="story-owned__skill-art"><img class="story-owned__skill-image" src="' + __story_skill_image(skill) + '" alt="' + name + '" /></span><span class="story-owned__skill-name">' + name + '</span></div>';
  }).join("");
}

function __story_purchase_name(kind, value) {
  if (kind === "armor") {
    return (__STORY_ARMORS[value] && __STORY_ARMORS[value].name) || "Armadura";
  }
  return __story_skill_name(value >>> 0);
}

function __story_purchase_cost(_kind, _value) {
  return 100;
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

function __story_open_purchase(state, kind, value) {
  state.pendingPurchase = {kind, value: value >>> 0};
  state.warningOpen = 0;
}

function __story_close_purchase(state) {
  state.pendingPurchase = null;
  state.warningOpen = 0;
}

function __story_confirm_purchase(state) {
  const pending = state.pendingPurchase;
  if (!pending) {
    return;
  }
  const cost = __story_purchase_cost(pending.kind, pending.value);
  if ((state.gold >>> 0) < (cost >>> 0)) {
    state.warningOpen = 1;
    return;
  }
  state.gold = ((state.gold >>> 0) - (cost >>> 0)) >>> 0;
  if (pending.kind === "armor") {
    state.armor[pending.value >>> 0] = 1;
  } else if (!__story_item_owned(state, pending.value >>> 0)) {
    state.items = state.items.concat([pending.value >>> 0]);
  }
  __story_close_purchase(state);
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

function __story_render_purchase_modal(state) {
  const pending = state.pendingPurchase;
  if (!pending) {
    return "";
  }
  const name = __story_purchase_name(pending.kind, pending.value);
  const cost = __story_purchase_cost(pending.kind, pending.value);
  let warning = "";
  if ((state.warningOpen >>> 0) !== 0) {
    warning = '<div class="story-warning-modal"><h3 class="story-warning-modal__title">Gold insuficiente</h3><p class="story-warning-modal__copy">Voce nao tem gold suficiente para essa compra.</p><div class="story-warning-modal__actions"><button type="button" class="story-purchase-modal__button story-purchase-modal__button--confirm" data-warning-ok="1">OK</button></div></div>';
  }
  return '<div class="story-modal-layer"><div class="story-purchase-modal"><h2 class="story-purchase-modal__title">' + name + '</h2><div class="story-purchase-modal__hero">' + __story_render_purchase_art(pending.kind, pending.value, 1) + '</div><div class="story-purchase-modal__details"><div class="story-purchase-modal__cost"><div class="story-purchase-modal__cost-label">Custo</div><div class="story-purchase-modal__cost-value">' + cost + ' gold</div></div><div class="story-purchase-modal__description"><div class="story-purchase-modal__description-label">Descricao</div></div></div><div class="story-purchase-modal__confirm"><div class="story-purchase-modal__confirm-copy">Confirmar compra?</div><div class="story-purchase-modal__actions"><button type="button" class="story-purchase-modal__button story-purchase-modal__button--confirm" data-purchase-confirm="1">Sim</button><button type="button" class="story-purchase-modal__button" data-purchase-cancel="1">Nao</button></div></div></div>' + warning + '</div>';
}

function __story_bind_shop_events(root, state, render) {
  root.city.querySelectorAll("[data-shop-open]").forEach((node) => {
    node.addEventListener("click", () => {
      state.openShop = Number.parseInt(node.getAttribute("data-shop-open") || "0", 10) >>> 0;
      __story_close_purchase(state);
      render();
    });
  });
  root.city.querySelectorAll("[data-shop-close]").forEach((node) => {
    node.addEventListener("click", () => {
      state.openShop = 0;
      __story_close_purchase(state);
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
      __story_open_purchase(state, kind, value >>> 0);
      render();
    });
  });
  if (!root.modalHost) {
    return;
  }
  root.modalHost.querySelectorAll("[data-purchase-cancel]").forEach((node) => {
    node.addEventListener("click", () => {
      __story_close_purchase(state);
      render();
    });
  });
  root.modalHost.querySelectorAll("[data-purchase-confirm]").forEach((node) => {
    node.addEventListener("click", () => {
      __story_confirm_purchase(state);
      render();
    });
  });
  root.modalHost.querySelectorAll("[data-warning-ok]").forEach((node) => {
    node.addEventListener("click", () => {
      state.warningOpen = 0;
      render();
    });
  });
}

function __story_render_inventory(root, state) {
  if (root.meta) {
    root.meta.textContent = "Level " + (state.level >>> 0) + " - Gold " + (state.gold >>> 0);
  }
  if (root.hpValue) {
    root.hpValue.textContent = String(__story_total_hp(state));
  }
  if (root.slotRow) {
    root.slotRow.innerHTML = [
      __story_render_skill_slot(state.loadout.s1 >>> 0, 0),
      __story_render_skill_slot(state.loadout.s2 >>> 0, 1),
      __story_render_skill_slot(state.loadout.s3 >>> 0, 2),
    ].join("");
  }
  if (root.armorGrid) {
    root.armorGrid.innerHTML = [
      __story_render_armor_slot(state, 0),
      __story_render_armor_slot(state, 1),
      __story_render_armor_slot(state, 2),
      __story_render_armor_slot(state, 3),
    ].join("");
  }
  if (root.ownedRow) {
    root.ownedRow.innerHTML = __story_render_owned_row(state);
  }
  if (root.duel) {
    root.duel.setAttribute("href", __story_build_duel_href(state));
  }
}

function __story_render_modals(root, state) {
  if (root.modalHost) {
    root.modalHost.innerHTML = __story_render_purchase_modal(state);
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
    meta: document.querySelector(".story-inventory__meta"),
    duel: document.querySelector(".story-duel"),
    hpValue: document.querySelector(".story-hp-card__value"),
    slotRow: document.querySelector(".story-slot-row"),
    armorGrid: document.querySelector(".story-armor__grid"),
    ownedRow: document.querySelector(".story-owned__row"),
    shopCells: {
      1: document.querySelector(".story-city__cell--wizard"),
      2: document.querySelector(".story-city__cell--bowyer"),
      3: document.querySelector(".story-city__cell--forge"),
    },
  };
  const render = () => {
    __story_render_inventory(root, state);
    __story_render_shops(root, state, render);
    __story_render_modals(root, state);
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
