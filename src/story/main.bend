import /App/
import /HTML/
import /U32/ as U32
import /shared/fight/ as Fight

type StoryScreen {
  city{}
  game_over{}
  victory{}
}

type Loadout {
  loadout{s1: U32, s2: U32, s3: U32}
}

type ArmorSlots {
  armor_slots{boots: U32, legs: U32, chest: U32, helmet: U32}
}

type StoryState {
  story_state{
    screen: StoryScreen,
    current_level: U32,
    gold: U32,
    items: List(U32),
    loadout: Loadout,
    armor: ArmorSlots,
  }
}

type StoryEvent {
  evt_ignore{}
}

init : StoryState =
  story_app_init()

def story_app_init() -> StoryState:
  story_app_from_query(0, 1, 0)

def story_app_from_query(screen_id: U32, current_level: U32, gold: U32) -> StoryState:
  story_state{
    _story_screen_from_id(screen_id),
    _campaign_level_clamp(current_level),
    gold,
    [],
    _campaign_default_loadout(),
    _armor_empty()
  }

def on_event(evt: StoryEvent, state: StoryState) -> StoryState:
  state

def render(state: StoryState) -> HTML(StoryEvent):
  screen = _story_screen(state);
  <main class={_story_page_class(screen)}>
    <style>{text{css()}}</style>
    {_render_story_screen_w(screen, state)}
  </main>

def _story_screen(state: StoryState) -> StoryScreen:
  match state:
    case story_state{screen, _, _, _, _, _}:
      screen

def _story_level(state: StoryState) -> U32:
  match state:
    case story_state{_, current_level, _, _, _, _}:
      current_level

def _story_gold(state: StoryState) -> U32:
  match state:
    case story_state{_, _, gold, _, _, _}:
      gold

def _story_loadout(state: StoryState) -> Loadout:
  match state:
    case story_state{_, _, _, _, loadout_value, _}:
      loadout_value

def _story_armor(state: StoryState) -> ArmorSlots:
  match state:
    case story_state{_, _, _, _, _, armor}:
      armor

def _story_page_class(screen: StoryScreen) -> String:
  match screen:
    case city{}:
      "story-page story-page--city"
    case _:
      "story-page story-page--end"

def _render_story_screen_w(screen: StoryScreen, state: StoryState) -> HTML(StoryEvent):
  match screen:
    case city{}:
      _render_city(state)
    case game_over{}:
      _render_end_screen(state, 0)
    case victory{}:
      _render_end_screen(state, 1)

def _render_city(state: StoryState) -> HTML(StoryEvent):
  <section class="story-city">
    <div class="story-city__backdrop"></div>
    <div class="story-city__line story-city__line--vertical"></div>
    <div class="story-city__line story-city__line--horizontal"></div>

    <section class="story-city__cell story-city__cell--wizard">
      {_shop_button("Wizard's Tower")}
    </section>

    <section class="story-city__cell story-city__cell--inventory">
      <div class="story-inventory">
        <div class="story-inventory__head">
          <div>
            <div class="story-inventory__title">{text{"Inventario"}}</div>
            <div class="story-inventory__meta">{text{"Level " ++ U32.show(_story_level(state)) ++ " - Gold " ++ U32.show(_story_gold(state))}}</div>
          </div>
          <a class="story-duel" href={_story_duel_href(state)}>{text{"Duel"}}</a>
        </div>

        <div class="story-equipped-row">
          <div class="story-hp-card">
            <span class="story-hp-card__label">{text{"HP total"}}</span>
            <strong class="story-hp-card__value">{text{U32.show(_story_total_hp(state))}}</strong>
          </div>

          <div class="story-slot-row">
            {_story_skill_slot(_story_loadout(state), 0)}
            {_story_skill_slot(_story_loadout(state), 1)}
            {_story_skill_slot(_story_loadout(state), 2)}
          </div>
        </div>

        <div class="story-owned-row">
          <div class="story-armor">
            <div class="story-armor__title">{text{"Armadura"}}</div>
            <div class="story-armor__grid">
              {_story_armor_slot(_story_armor(state), 0)}
              {_story_armor_slot(_story_armor(state), 1)}
              {_story_armor_slot(_story_armor(state), 2)}
              {_story_armor_slot(_story_armor(state), 3)}
            </div>
          </div>

          <div class="story-owned">
            <div class="story-owned__title">{text{"Skills compradas"}}</div>
            <div class="story-owned__track">
              <div class="story-owned__viewport">
                <div class="story-owned__row"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section class="story-city__cell story-city__cell--bowyer">
      {_shop_button("The Bowyer's Workshop")}
    </section>

    <section class="story-city__cell story-city__cell--forge">
      {_shop_button("The Blacksmith's Forge")}
    </section>
  </section>

def _render_end_screen(state: StoryState, won: U32) -> HTML(StoryEvent):
  <section class="story-end">
    <div class="story-end__card">
      <div class="story-end__eyebrow">{text{_story_end_eyebrow(won)}}</div>
      <h1 class="story-end__title">{text{_story_end_title(won)}}</h1>
      <p class="story-end__copy">{text{_story_end_copy(state, won)}}</p>
      <div class="story-end__actions">
        <a class="story-link" href="../">{text{"Voltar ao menu"}}</a>
        <a class="story-link story-link--primary" href="?screen=city&level=1&gold=0">{text{"Reiniciar campanha"}}</a>
      </div>
    </div>
  </section>

def _shop_button(label: String) -> HTML(StoryEvent):
  <button type="button" class="story-shop-button" disabled="disabled">
    {text{label}}
  </button>

def _story_skill_slot(loadout_value: Loadout, idx: U32) -> HTML(StoryEvent):
  skill = _loadout_slot(loadout_value, idx);
  <div class={_story_skill_slot_class(skill)}>
    <span class="story-slot__index">{text{U32.show(idx + 1)}}</span>
    <span class="story-slot__name">{text{_story_skill_slot_label(skill)}}</span>
    {_story_skill_visual(skill)}
  </div>

def _story_skill_slot_class(skill: U32) -> String:
  match skill:
    case 0:
      "story-slot story-slot--empty"
    case _:
      "story-slot"

def _story_skill_slot_label(skill: U32) -> String:
  match skill:
    case 0:
      "Vazio"
    case current_skill:
      Fight.skill_name(current_skill)

def _story_skill_visual(skill: U32) -> HTML(StoryEvent):
  match skill:
    case 0:
      <span class="story-slot__art story-slot__art--empty"></span>
    case current_skill:
      <span class="story-slot__art">
        <img class="story-slot__image" src={_skill_image_src(current_skill)} alt={Fight.skill_name(current_skill)} />
      </span>

def _skill_image_src(skill: U32) -> String:
  "../assets/skills/" ++ Fight.skill_name(skill) ++ ".svg"

def _story_armor_slot(armor: ArmorSlots, idx: U32) -> HTML(StoryEvent):
  <div class="story-armor__item">
    <div class={_story_armor_slot_class(_armor_slot(armor, idx))}></div>
    <div class="story-armor__slot-label">{text{_armor_slot_label(idx)}}</div>
  </div>

def _story_armor_slot_class(equipped: U32) -> String:
  match equipped:
    case 0:
      "story-armor__slot"
    case _:
      "story-armor__slot story-armor__slot--filled"

def _story_duel_href(state: StoryState) -> String:
  level = _story_level(state);
  loadout_value = _story_loadout(state);
  "../fight/?campaign=1"
  ++ "&level=" ++ U32.show(level)
  ++ "&gold=" ++ U32.show(_story_gold(state))
  ++ "&reward=" ++ U32.show(_campaign_reward_gold(level))
  ++ "&php=" ++ U32.show(_campaign_player_hp(level))
  ++ "&bhp=" ++ U32.show(_campaign_bot_hp(level))
  ++ "&ps1=" ++ U32.show(_loadout_slot(loadout_value, 0))
  ++ "&ps2=" ++ U32.show(_loadout_slot(loadout_value, 1))
  ++ "&ps3=" ++ U32.show(_loadout_slot(loadout_value, 2))
  ++ "&bs1=1&bs2=0&bs3=0"

def _story_end_eyebrow(won: U32) -> String:
  match won:
    case 0:
      "Campanha"
    case _:
      "Campanha completa"

def _story_end_title(won: U32) -> String:
  match won:
    case 0:
      "Game Over"
    case _:
      "Vitoria final"

def _story_end_copy(state: StoryState, won: U32) -> String:
  match won:
    case 0:
      "Voce caiu em um level obrigatorio. Gold final: " ++ U32.show(_story_gold(state)) ++ "."
    case _:
      "Voce fechou os 12 levels da campanha placeholder com " ++ U32.show(_story_gold(state)) ++ " gold."

def _story_screen_from_id(screen_id: U32) -> StoryScreen:
  match screen_id:
    case 1:
      game_over{}
    case 2:
      victory{}
    case _:
      city{}

def _campaign_default_loadout() -> Loadout:
  loadout{1, 0, 0}

def _armor_empty() -> ArmorSlots:
  armor_slots{0, 0, 0, 0}

def _armor_slot(armor: ArmorSlots, idx: U32) -> U32:
  match armor:
    case armor_slots{boots, legs, chest, helmet}:
      match idx:
        case 0:
          boots
        case 1:
          legs
        case 2:
          chest
        case _:
          helmet

def _armor_slot_label(idx: U32) -> String:
  match idx:
    case 0:
      "Calcado"
    case 1:
      "Calca"
    case 2:
      "Peitoral"
    case _:
      "Capacete"

def _story_total_hp(state: StoryState) -> U32:
  50 + _armor_total_hp_bonus(_story_armor(state))

def _armor_total_hp_bonus(armor: ArmorSlots) -> U32:
  _armor_bonus_for_slot(0, _armor_slot(armor, 0))
  + _armor_bonus_for_slot(1, _armor_slot(armor, 1))
  + _armor_bonus_for_slot(2, _armor_slot(armor, 2))
  + _armor_bonus_for_slot(3, _armor_slot(armor, 3))

def _armor_bonus_for_slot(idx: U32, equipped: U32) -> U32:
  match equipped:
    case 0:
      0
    case _:
      _armor_slot_hp_value(idx)

def _armor_slot_hp_value(idx: U32) -> U32:
  match idx:
    case 0:
      10
    case 1:
      20
    case 2:
      40
    case _:
      30

def _campaign_level_clamp(level: U32) -> U32:
  match level:
    case 0:
      1
    case value:
      _campaign_level_clamp_upper(value, value <= 12)

def _campaign_level_clamp_upper(level: U32, inside_range: U32) -> U32:
  match inside_range:
    case 0:
      12
    case _:
      level

def _campaign_player_hp(level: U32) -> U32:
  50

def _campaign_bot_hp(level: U32) -> U32:
  30

def _campaign_reward_gold(level: U32) -> U32:
  200

def _loadout_slot(loadout_value: Loadout, idx: U32) -> U32:
  match loadout_value:
    case loadout{s1, s2, s3}:
      match idx:
        case 0:
          s1
        case 1:
          s2
        case 2:
          s3
        case _:
          0

def css() -> String:
  _base_css()
  ++ _city_layout_css()
  ++ _inventory_css()
  ++ _end_screen_css()
  ++ _responsive_css()

def _base_css() -> String:
  ""
  ++ ":root{--bg:#2c2216;--panel:#e7d0ac;--panel-strong:#6f4720;--card:#f2dfbf;--text:#24190f;--muted:#6d5438;--line:#b38f53;--gold:#d8a326;--gold-deep:#8c6006;--cream:#fff4dd;--button:#74441b;}*{box-sizing:border-box;}html,body{margin:0;width:100%;height:100%;background:var(--bg);color:var(--text);font-family:'Trebuchet MS','Segoe UI',sans-serif;}body{min-height:100svh;}a{text-decoration:none;color:inherit;}button{font:inherit;}"

def _city_layout_css() -> String:
  ""
  ++ ".story-page{min-height:100svh;}.story-page--city{position:relative;overflow:hidden;}.story-page--end{display:grid;place-items:center;padding:24px;background:radial-gradient(circle at top,#5c3a1c 0%,#2c2216 62%);}.story-city{position:relative;min-height:100svh;display:grid;grid-template-columns:repeat(2,minmax(0,1fr));grid-template-rows:repeat(2,minmax(0,1fr));}.story-city__backdrop{position:absolute;inset:0;background-image:linear-gradient(rgba(26,16,9,.36),rgba(26,16,9,.62)),url('../assets/background/background-para-substituir.png');background-size:cover;background-position:center;}.story-city__line{position:absolute;background:rgba(226,194,137,.58);box-shadow:0 0 0 1px rgba(78,51,22,.38);z-index:1;}.story-city__line--vertical{top:0;bottom:0;left:50%;width:2px;transform:translateX(-1px);}.story-city__line--horizontal{left:0;right:0;top:50%;height:2px;transform:translateY(-1px);}.story-city__cell{position:relative;z-index:2;min-height:50svh;padding:34px;display:grid;align-content:center;justify-items:center;}.story-city__cell--inventory{align-content:start;justify-items:end;}.story-shop-button{min-width:min(100%,320px);padding:20px 26px;border:1px solid rgba(255,235,201,.72);border-radius:20px;background:rgba(62,35,12,.8);color:#fff2da;font-size:22px;font-weight:900;letter-spacing:.03em;box-shadow:0 16px 42px rgba(18,10,4,.32);}.story-shop-button[disabled]{opacity:1;cursor:default;}"

def _inventory_css() -> String:
  ""
  ++ ".story-inventory{width:min(100%,700px);display:grid;gap:14px;padding:22px;background:rgba(104,61,28,.92);border:2px solid #4b2d14;box-shadow:0 22px 60px rgba(17,10,4,.34);}.story-inventory__head{display:flex;justify-content:space-between;gap:16px;align-items:flex-start;}.story-inventory__title{font-size:28px;font-weight:900;line-height:1;color:var(--cream);}.story-inventory__meta{margin-top:6px;font-size:13px;letter-spacing:.08em;text-transform:uppercase;color:#e0c28d;}.story-duel{display:inline-flex;align-items:center;justify-content:center;min-width:126px;padding:12px 18px;border-radius:14px;border:2px solid var(--gold);background:#f1c54a;color:var(--gold-deep);font-weight:900;box-shadow:0 12px 30px rgba(111,71,0,.24);}"
  ++ ".story-equipped-row,.story-owned-row{display:grid;grid-template-columns:110px minmax(0,1fr);gap:14px;align-items:start;}.story-hp-card{min-height:112px;padding:12px 10px;display:grid;align-content:center;gap:6px;background:rgba(82,49,25,.9);border:1px solid #7b5a32;color:var(--cream);}.story-hp-card__label{font-size:11px;letter-spacing:.12em;text-transform:uppercase;color:#e0c28d;}.story-hp-card__value{font-size:30px;line-height:1;}.story-slot-row{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;justify-content:stretch;padding:10px;border:1px solid #7b5a32;border-radius:16px;background:rgba(88,53,28,.9);box-shadow:inset 0 0 0 1px rgba(255,236,209,.05);}.story-slot{width:100%;aspect-ratio:1/1;min-height:0;padding:8px;display:grid;place-items:center;border:1px solid #c6a26a;border-radius:14px;background:rgba(255,244,221,.95);text-align:center;}.story-slot--empty{opacity:.72;}.story-slot__index{font-size:11px;font-weight:900;letter-spacing:.14em;color:var(--muted);}.story-slot__name{font-size:12px;font-weight:800;color:var(--text);}.story-slot__art{width:64px;height:64px;display:grid;place-items:center;padding:4px;border:1px solid #ccb287;background:#ead9bb;overflow:hidden;}.story-slot__art--empty{background:#d8c09b;}.story-slot__image{display:block;width:100%;height:100%;object-fit:contain;}"
  ++ ".story-armor,.story-owned{display:grid;gap:10px;min-width:0;}.story-armor__title,.story-owned__title{font-size:12px;letter-spacing:.14em;text-transform:uppercase;color:#e0c28d;font-weight:900;}.story-armor__grid{display:grid;grid-template-columns:repeat(2,48px);gap:10px 12px;align-content:start;}.story-armor__item{display:grid;justify-items:start;gap:5px;}.story-armor__slot{width:48px;aspect-ratio:1/1;border:1px solid #7b5a32;background:rgba(79,48,23,.86);box-shadow:inset 0 0 0 1px rgba(255,236,209,.06);}.story-armor__slot--filled{background:rgba(170,128,68,.92);}.story-armor__slot-label{font-size:10px;letter-spacing:.06em;text-transform:uppercase;color:#f1dfbb;line-height:1.2;}"
  ++ ".story-owned__track{min-height:86px;padding:10px;border:1px solid #7b5a32;background:rgba(88,53,28,.9);box-shadow:inset 0 0 0 1px rgba(255,236,209,.05);}.story-owned__viewport{width:100%;height:100%;overflow-x:auto;overflow-y:hidden;}.story-owned__row{display:flex;gap:10px;align-items:stretch;min-width:100%;width:max-content;min-height:64px;}.story-owned__skill{width:76px;min-height:86px;padding:8px;display:grid;justify-items:center;align-content:start;gap:5px;border:1px solid #c6a26a;border-radius:12px;background:rgba(255,244,221,.92);text-align:center;}.story-owned__skill-art{width:40px;height:40px;display:grid;place-items:center;padding:3px;border:1px solid #ccb287;background:#ead9bb;overflow:hidden;}.story-owned__skill-image{display:block;width:100%;height:100%;object-fit:contain;}.story-owned__skill-name{font-size:10px;font-weight:800;color:var(--text);line-height:1.2;}"

def _end_screen_css() -> String:
  ""
  ++ ".story-end{width:min(100%,560px);}.story-end__card{display:grid;gap:16px;padding:30px 28px;background:var(--panel);border:1px solid var(--line);box-shadow:0 18px 48px rgba(17,10,4,.26);}.story-end__eyebrow{font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:var(--muted);font-weight:800;}.story-end__title{margin:0;font-size:44px;line-height:1;}.story-end__copy{margin:0;color:var(--muted);line-height:1.6;}.story-end__actions{display:flex;gap:12px;flex-wrap:wrap;}.story-link{display:inline-flex;align-items:center;justify-content:center;min-width:160px;padding:12px 18px;border-radius:999px;background:#c49a54;color:#fff6e7;font-weight:900;}.story-link--primary{background:var(--button);}"

def _responsive_css() -> String:
  ""
  ++ "@media (max-width:900px){.story-city{grid-template-columns:1fr;grid-template-rows:none;padding:20px 0;gap:18px;}.story-city__line{display:none;}.story-city__cell{min-height:auto;padding:0 18px;}.story-city__cell--inventory{justify-items:stretch;}.story-inventory{width:100%;min-height:0;}.story-shop-button{width:100%;font-size:18px;}}"
  ++ "@media (max-width:640px){.story-page--end{padding:16px;}.story-end__card{padding:24px 20px;}.story-end__title{font-size:34px;}.story-inventory__head{flex-direction:column;align-items:stretch;}.story-duel{width:100%;}.story-equipped-row,.story-owned-row{grid-template-columns:1fr;}.story-slot-row{grid-template-columns:1fr;}.story-armor__grid{grid-template-columns:repeat(2,48px);}.story-owned__row{min-height:64px;}}"

main : App =
  app{StoryState, StoryEvent, init, render, on_event}
