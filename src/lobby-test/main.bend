import /App/
import /HTML/
import /Attr/
import /U32/ as U32
import /shared/fight/ as Fight

type Loadout {
  loadout{s1: U32, s2: U32, s3: U32}
}

type ItemLoadout {
  item_loadout{i1: U32, i2: U32, i3: U32}
}

type LobbyTestState {
  lobby_test_state{
    player_loadout: Loadout,
    bot_loadout: Loadout,
    player_filter: U32,
    bot_filter: U32,
    player_items: ItemLoadout,
    bot_items: ItemLoadout,
  }
}

type LobbyTestEvent {
  evt_toggle_skill{side: U32, skill: U32}
  evt_set_filter{side: U32, filter: U32}
  evt_ignore{}
}

def loadout_default() -> Loadout:
  loadout{
    Fight.default_setup_skill(0, 0),
    Fight.default_setup_skill(0, 1),
    Fight.default_setup_skill(0, 2),
  }

def item_loadout_default() -> ItemLoadout:
  item_loadout{
    Fight.default_setup_item(0, 0),
    Fight.default_setup_item(0, 1),
    Fight.default_setup_item(0, 2),
  }

init : LobbyTestState =
  lobby_test_state{loadout_default(), loadout_default(), 0, 0, item_loadout_default(), item_loadout_default()}

def on_event(evt: LobbyTestEvent, state: LobbyTestState) -> LobbyTestState:
  match evt:
    case evt_toggle_skill{side, skill}:
      _state_toggle_skill(state, side, skill)
    case evt_set_filter{side, filter}:
      _state_set_filter(state, side, filter)
    case _:
      state

def _state_toggle_skill(state: LobbyTestState, side: U32, skill: U32) -> LobbyTestState:
  match state:
    case lobby_test_state{player_loadout, bot_loadout, player_filter, bot_filter, player_items, bot_items}:
      match side:
        case 0:
          next = _loadout_toggle(player_loadout, skill);
          _state_toggle_skill_next_player(_loadout_count(next), player_loadout, next, bot_loadout, player_filter, bot_filter, player_items, bot_items)
        case _:
          next = _loadout_toggle(bot_loadout, skill);
          _state_toggle_skill_next_bot(_loadout_count(next), player_loadout, bot_loadout, next, player_filter, bot_filter, player_items, bot_items)

def _state_toggle_skill_next_player(count: U32, current_player_loadout: Loadout, next_player_loadout: Loadout, bot_loadout: Loadout, player_filter: U32, bot_filter: U32, player_items: ItemLoadout, bot_items: ItemLoadout) -> LobbyTestState:
  match count:
    case 0:
      lobby_test_state{current_player_loadout, bot_loadout, player_filter, bot_filter, player_items, bot_items}
    case _:
      lobby_test_state{next_player_loadout, bot_loadout, player_filter, bot_filter, player_items, bot_items}

def _state_toggle_skill_next_bot(count: U32, player_loadout: Loadout, current_bot_loadout: Loadout, next_bot_loadout: Loadout, player_filter: U32, bot_filter: U32, player_items: ItemLoadout, bot_items: ItemLoadout) -> LobbyTestState:
  match count:
    case 0:
      lobby_test_state{player_loadout, current_bot_loadout, player_filter, bot_filter, player_items, bot_items}
    case _:
      lobby_test_state{player_loadout, next_bot_loadout, player_filter, bot_filter, player_items, bot_items}

def _state_set_filter(state: LobbyTestState, side: U32, filter: U32) -> LobbyTestState:
  match state:
    case lobby_test_state{player_loadout, bot_loadout, player_filter, bot_filter, player_items, bot_items}:
      match side:
        case 0:
          lobby_test_state{player_loadout, bot_loadout, _next_filter(player_filter, filter), bot_filter, player_items, bot_items}
        case _:
          lobby_test_state{player_loadout, bot_loadout, player_filter, _next_filter(bot_filter, filter), player_items, bot_items}

def _next_filter(active: U32, selected: U32) -> U32:
  match active === selected:
    case 0:
      selected
    case _:
      0

def _loadout_slot(loadout_value: Loadout, idx: U32) -> U32:
  match loadout_value:
    case loadout{s1, s2, s3}:
      match idx:
        case 0:
          s1
        case 1:
          s2
        case _:
          s3

def _loadout_contains(loadout_value: Loadout, skill: U32) -> U32:
  (_loadout_slot(loadout_value, 0) === skill)
  | (_loadout_slot(loadout_value, 1) === skill)
  | (_loadout_slot(loadout_value, 2) === skill)

def _loadout_count(loadout_value: Loadout) -> U32:
  _loadout_nonzero(_loadout_slot(loadout_value, 0))
  + _loadout_nonzero(_loadout_slot(loadout_value, 1))
  + _loadout_nonzero(_loadout_slot(loadout_value, 2))

def _loadout_nonzero(skill: U32) -> U32:
  match skill:
    case 0:
      0
    case _:
      1

def _loadout_toggle(loadout_value: Loadout, skill: U32) -> Loadout:
  match loadout_value:
    case loadout{s1, s2, s3}:
      _loadout_toggle_slots(s1, s2, s3, skill)

def _loadout_toggle_slots(s1: U32, s2: U32, s3: U32, skill: U32) -> Loadout:
  match s1 === skill:
    case 0:
      _loadout_toggle_slot2(s1, s2, s3, skill)
    case _:
      loadout{s2, s3, 0}

def _loadout_toggle_slot2(s1: U32, s2: U32, s3: U32, skill: U32) -> Loadout:
  match s2 === skill:
    case 0:
      _loadout_toggle_slot3(s1, s2, s3, skill)
    case _:
      loadout{s1, s3, 0}

def _loadout_toggle_slot3(s1: U32, s2: U32, s3: U32, skill: U32) -> Loadout:
  match s3 === skill:
    case 0:
      _loadout_toggle_add(s1, s2, s3, skill)
    case _:
      loadout{s1, s2, 0}

def _loadout_toggle_add(s1: U32, s2: U32, s3: U32, skill: U32) -> Loadout:
  match s1 === 0:
    case 0:
      _loadout_toggle_add_second(s1, s2, s3, skill)
    case _:
      loadout{skill, s2, s3}

def _loadout_toggle_add_second(s1: U32, s2: U32, s3: U32, skill: U32) -> Loadout:
  match s2 === 0:
    case 0:
      _loadout_toggle_add_third(s1, s2, s3, skill)
    case _:
      loadout{s1, skill, s3}

def _loadout_toggle_add_third(s1: U32, s2: U32, s3: U32, skill: U32) -> Loadout:
  _loadout_toggle_add_third_w(_loadout_nonzero(s3), s1, s2, s3, skill)

def _loadout_toggle_add_third_w(occupied: U32, s1: U32, s2: U32, s3: U32, skill: U32) -> Loadout:
  match occupied:
    case 0:
      loadout{s1, s2, skill}
    case _:
      loadout{s1, s2, s3}

def render(state: LobbyTestState) -> HTML(LobbyTestEvent):
  <main class="menu-page menu-page--lobby">
    <style>{text{css()}}</style>
    <section class="menu-card lobby-shell">
      <div class="lobby-header">
        <div>
          <div class="menu-eyebrow">{text{"Lobby Test"}}</div>
          <h1 class="menu-title menu-title--lobby">{text{"Selecao separada do combate"}}</h1>
          <p class="menu-copy menu-copy--compact">{text{"Esta tela cuida so do lobby. O combate roda separado em /game-test/."}}</p>
        </div>
        <a class="button button--menu button--menu-secondary nav-link" href="../">{text{"Voltar"}}</a>
      </div>

      <div class="lobby-grid">
        {_side_card(state, 0)}
        {_side_card(state, 1)}
      </div>

      <div class="lobby-footer">
        <p class="menu-copy menu-copy--compact">{text{"Itens seguem reservados no contrato do game-test como slots vazios (0)."}}
        </p>
        <a class={_play_link_class(state)} href={_play_link_href(state)}>{text{"Abrir game-test"}}</a>
      </div>
    </section>
  </main>

def _side_card(state: LobbyTestState, side: U32) -> HTML(LobbyTestEvent):
  loadout_value = _side_loadout(state, side);
  filter = _side_filter(state, side);
  <section class="card lobby-card">
    <div class="stat-label">{text{_side_title(side)}}</div>
    <div class="stat-label stat-label--spaced">{text{"Slots equipados"}}</div>
    <div class="lobby-slot-strip">
      {_equipped_skill_card(loadout_value, 0)}
      {_equipped_skill_card(loadout_value, 1)}
      {_equipped_skill_card(loadout_value, 2)}
    </div>
    <div class="lobby-skill-head">
      <div class="stat-label stat-label--spaced">{text{"Skills disponiveis"}}</div>
      <div class="skill-filter-row">
        {_filter_button(side, filter, 0)}
        {_filter_button(side, filter, 1)}
        {_filter_button(side, filter, 2)}
        {_filter_button(side, filter, 3)}
      </div>
    </div>
    <div class="skill-pool-wrap">
      <div class="skill-pool-grid">
        {_skill_card(side, loadout_value, filter, 1)}
        {_skill_card(side, loadout_value, filter, 2)}
        {_skill_card(side, loadout_value, filter, 3)}
        {_skill_card(side, loadout_value, filter, 4)}
        {_skill_card(side, loadout_value, filter, 5)}
        {_skill_card(side, loadout_value, filter, 6)}
        {_skill_card(side, loadout_value, filter, 7)}
        {_skill_card(side, loadout_value, filter, 8)}
        {_skill_card(side, loadout_value, filter, 9)}
        {_skill_card(side, loadout_value, filter, 10)}
        {_skill_card(side, loadout_value, filter, 11)}
        {_skill_card(side, loadout_value, filter, 12)}
        {_skill_card(side, loadout_value, filter, 13)}
      </div>
    </div>
  </section>

def _side_title(side: U32) -> String:
  match side:
    case 0:
      "Player"
    case _:
      "Bot inimigo"

def _side_loadout(state: LobbyTestState, side: U32) -> Loadout:
  match state:
    case lobby_test_state{player_loadout, bot_loadout, _, _, _, _}:
      match side:
        case 0:
          player_loadout
        case _:
          bot_loadout

def _side_filter(state: LobbyTestState, side: U32) -> U32:
  match state:
    case lobby_test_state{_, _, player_filter, bot_filter, _, _}:
      match side:
        case 0:
          player_filter
        case _:
          bot_filter

def _equipped_skill_card(loadout_value: Loadout, idx: U32) -> HTML(LobbyTestEvent):
  skill = _loadout_slot(loadout_value, idx);
  <div class={_equipped_skill_class(skill)}>
    <span class="skill-key">{text{U32.show(idx + 1)}}</span>
    <span class="skill-caption">{text{_skill_name(skill)}}</span>
    {_skill_visual(skill)}
  </div>

def _equipped_skill_class(skill: U32) -> String:
  match skill:
    case 0:
      "skill-preview skill-preview--static skill-preview--empty"
    case _:
      "skill-preview skill-preview--static"

def _filter_button(side: U32, active: U32, filter: U32) -> HTML(LobbyTestEvent):
  <button {..._button_attrs(_filter_button_class(active, filter), evt_set_filter{side, filter})}>
    {text{_filter_label(filter)}}
  </button>

def _filter_button_class(active: U32, filter: U32) -> String:
  _filter_button_class_selected(active === filter)

def _filter_button_class_selected(selected: U32) -> String:
  match selected:
    case 0:
      "skill-filter-button"
    case _:
      "skill-filter-button skill-filter-button--active"

def _filter_label(filter: U32) -> String:
  match filter:
    case 0:
      "All"
    case 1:
      "Ranged"
    case 2:
      "Mage"
    case _:
      "Melee"

def _skill_card(side: U32, loadout_value: Loadout, filter: U32, skill: U32) -> HTML(LobbyTestEvent):
  <button {..._button_attrs(_skill_card_class(loadout_value, filter, skill), evt_toggle_skill{side, skill})}>
    <span class="skill-pool-card__label">{text{_skill_name(skill)}}</span>
    {_skill_visual(skill)}
  </button>

def _skill_card_class(loadout_value: Loadout, filter: U32, skill: U32) -> String:
  selected = _loadout_contains(loadout_value, skill);
  show = _filter_matches(filter, skill);
  _skill_card_class_visible(selected, show)

def _skill_card_class_visible(selected: U32, show: U32) -> String:
  match show:
    case 0:
      "skill-pool-card skill-pool-card--hidden"
    case _:
      _skill_card_class_selected(selected)

def _skill_card_class_selected(selected: U32) -> String:
  match selected:
    case 0:
      "skill-pool-card"
    case _:
      "skill-pool-card skill-pool-card--selected"

def _filter_matches(filter: U32, skill: U32) -> U32:
  match filter:
    case 0:
      1
    case 1:
      Fight.skill_class_id(skill) === 1
    case 2:
      Fight.skill_class_id(skill) === 2
    case _:
      Fight.skill_class_id(skill) === 0

def _play_link_class(state: LobbyTestState) -> String:
  _play_link_class_ready(_play_ready(state))

def _play_link_class_ready(ready: U32) -> String:
  match ready:
    case 0:
      "button button--menu nav-link nav-link--disabled"
    case _:
      "button button--menu nav-link"

def _play_link_href(state: LobbyTestState) -> String:
  player = _side_loadout(state, 0);
  bot = _side_loadout(state, 1);
  player_items = _player_items(state);
  bot_items = _bot_items(state);
  _play_link_href_state(_play_ready(state), player, bot, player_items, bot_items)

def _play_link_href_state(ready: U32, player: Loadout, bot: Loadout, player_items: ItemLoadout, bot_items: ItemLoadout) -> String:
  match ready:
    case 0:
      "#"
    case _:
      _play_link_href_ready(player, bot, player_items, bot_items)

def _play_link_href_ready(player: Loadout, bot: Loadout, player_items: ItemLoadout, bot_items: ItemLoadout) -> String:
  "../game-test/?ps1=" ++ U32.show(_loadout_slot(player, 0))
  ++ "&ps2=" ++ U32.show(_loadout_slot(player, 1))
  ++ "&ps3=" ++ U32.show(_loadout_slot(player, 2))
  ++ "&bs1=" ++ U32.show(_loadout_slot(bot, 0))
  ++ "&bs2=" ++ U32.show(_loadout_slot(bot, 1))
  ++ "&bs3=" ++ U32.show(_loadout_slot(bot, 2))
  ++ "&pi1=" ++ U32.show(_item_slot(player_items, 0))
  ++ "&pi2=" ++ U32.show(_item_slot(player_items, 1))
  ++ "&pi3=" ++ U32.show(_item_slot(player_items, 2))
  ++ "&bi1=" ++ U32.show(_item_slot(bot_items, 0))
  ++ "&bi2=" ++ U32.show(_item_slot(bot_items, 1))
  ++ "&bi3=" ++ U32.show(_item_slot(bot_items, 2))

def _play_ready(state: LobbyTestState) -> U32:
  _loadout_nonzero(_loadout_count(_side_loadout(state, 0))) & _loadout_nonzero(_loadout_count(_side_loadout(state, 1)))

def _player_items(state: LobbyTestState) -> ItemLoadout:
  match state:
    case lobby_test_state{_, _, _, _, player_items, _}:
      player_items

def _bot_items(state: LobbyTestState) -> ItemLoadout:
  match state:
    case lobby_test_state{_, _, _, _, _, bot_items}:
      bot_items

def _item_slot(items: ItemLoadout, idx: U32) -> U32:
  match items:
    case item_loadout{i1, i2, i3}:
      match idx:
        case 0:
          i1
        case 1:
          i2
        case _:
          i3

def _button_attrs(class_name: String, evt: LobbyTestEvent) -> List(Attr(LobbyTestEvent)):
  [attr{"type", "button"}, attr{"class", class_name}, on_click{evt}]

def _skill_visual(skill: U32) -> HTML(LobbyTestEvent):
  match skill:
    case 0:
      <span class="skill-grid-frame skill-grid-frame--empty"></span>
    case current_skill:
      <span class="skill-grid-frame">
        <img class="skill-grid-art" src={_skill_image_src(current_skill)} alt={_skill_name(current_skill)} />
      </span>

def _skill_image_src(skill: U32) -> String:
  "../assets/skills/" ++ _skill_name(skill) ++ ".svg"

def _skill_name(skill: U32) -> String:
  match skill:
    case 0:
      "Vazio"
    case current_skill:
      Fight.skill_name(current_skill)

def css() -> String:
  ""
  ++ ":root{--bg:#d3bb94;--panel:#efe2c6;--card:#f7ecd3;--text:#2a2115;--muted:#6b593c;--border:#7a613c;--button:#966320;--button-alt:#b58a43;}*{box-sizing:border-box;}html,body{margin:0;width:100%;height:100%;background:var(--bg);color:var(--text);font-family:'Trebuchet MS','Segoe UI',sans-serif;}body{min-height:100svh;}button{font:inherit;cursor:pointer;}a{text-decoration:none;}"
  ++ ".menu-page{min-height:100svh;padding:32px 24px;display:grid;place-items:center;overflow:auto;}.menu-page--lobby{place-items:start center;}.menu-card{width:min(100%,1120px);padding:24px;background:var(--panel);border:1px solid var(--border);}.menu-eyebrow{font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:var(--muted);font-weight:800;}.menu-title{margin:0;font-size:44px;line-height:1;}.menu-title--lobby{font-size:36px;}.menu-copy{margin:0;color:var(--muted);line-height:1.6;max-width:56ch;}.menu-copy--compact{max-width:none;}.button{border:none;border-radius:999px;padding:11px 15px;font:inherit;font-weight:800;color:#fff8eb;background:var(--button);}.button--menu{min-width:140px;justify-content:center;}.button--menu-secondary{background:var(--button-alt);}.nav-link{display:inline-flex;align-items:center;justify-content:center;text-decoration:none;}.nav-link--disabled{opacity:.56;pointer-events:none;}"
  ++ ".lobby-shell{width:min(100%,1120px);display:grid;grid-template-rows:auto minmax(0,1fr) auto;gap:20px;}.lobby-header{display:flex;justify-content:space-between;gap:12px;align-items:flex-start;}.lobby-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;align-items:start;}.lobby-card{min-height:0;display:grid;grid-template-rows:auto auto auto minmax(0,1fr);gap:12px;align-content:start;}.lobby-slot-strip{display:flex;gap:10px;flex-wrap:wrap;}.lobby-skill-head{display:flex;align-items:center;justify-content:space-between;gap:12px;}.lobby-footer{display:flex;justify-content:space-between;gap:14px;align-items:center;flex-wrap:wrap;}.card{padding:14px 16px;background:var(--card);border:1px solid #bda173;}.stat-label{font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);}.stat-label--spaced{margin-top:12px;display:block;}"
  ++ ".skill-filter-row{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end;}.skill-filter-button{border:none;border-radius:999px;padding:8px 12px;background:var(--panel);color:var(--text);font-size:12px;font-weight:800;}.skill-filter-button--active{background:var(--button);color:#fff8eb;}.skill-pool-wrap{min-height:0;overflow:auto;padding-right:4px;}.skill-pool-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;}.skill-pool-card{aspect-ratio:1/1;border:1px solid #bda173;border-radius:16px;padding:12px;display:grid;justify-items:center;align-content:start;gap:6px;background:var(--card);color:var(--text);text-align:center;}.skill-pool-card--selected{border-color:var(--button);background:#f1dfb8;}.skill-pool-card--hidden{display:none;}.skill-pool-card__label{font-size:12px;font-weight:800;color:var(--text);}"
  ++ ".skill-preview{width:106px;min-height:122px;padding:10px;display:grid;justify-items:center;align-content:start;gap:6px;border:1px solid #bda173;border-radius:14px;background:var(--card);color:var(--text);text-align:center;}.skill-preview--empty{opacity:.72;}.skill-preview--static{pointer-events:none;}.skill-key{font-size:11px;font-weight:900;letter-spacing:.14em;color:var(--muted);}.skill-caption{font-size:12px;font-weight:700;color:var(--text);line-height:1.2;}.skill-grid-frame{width:64px;height:64px;display:grid;place-items:center;padding:4px;border:1px solid #ccb287;background:var(--panel);overflow:hidden;}.skill-grid-frame--empty{background:#f2e5cb;}.skill-grid-art{display:block;width:100%;height:100%;object-fit:contain;}"
  ++ "@media (max-width:980px){.menu-page{padding:20px 14px;}.lobby-grid{grid-template-columns:1fr;}.skill-filter-row{justify-content:flex-start;}.skill-pool-grid{grid-template-columns:repeat(2,minmax(0,1fr));}}"

main : App =
  app{LobbyTestState, LobbyTestEvent, init, render, on_event}
