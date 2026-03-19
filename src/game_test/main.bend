import /App/
import /HTML/
import /Attr/
import /U32/ as U32
import /shared/fight/ as Fight

# main.bend
# =========
# Single-file Bend web app for the fight prototype.

type Pos {
  pos{x: U32, y: U32}
}

type Terrain {
  terrain{pos: Pos, owner: U32, effect: U32, turns: U32}
}

type RuntimeData {
  runtime_data{terrain: List(Terrain), player_fire: U32, player_ice: U32}
}

type Bot {
  bot{pos: Pos, hp: U32, fire: U32, ice: U32}
}

type Rules {
  rules{
    board_w: U32,
    board_h: U32,
    player_start: Pos,
    enemy_start: Pos,
    max_hp: U32,
    damage: U32,
  }
}

type Action {
  wait{}
  move{dir: U32}
  attack{skill: U32, anchor: Pos, rot: U32}
}

type Mode {
  plan{runtime: RuntimeData}
  target{skill: U32, rot: U32, origin: Pos, runtime: RuntimeData}
  playback{idx: U32, phase: U32, actor: U32, actor_idx: U32, action: Action, sim: ActionSim, bot_plans: List(List(Action)), runtime: RuntimeData}
}

type Screen {
  home{}
  play_lobby{}
  story{}
  battle{}
}

type Loadout {
  loadout{s1: U32, s2: U32, s3: U32}
}

type LobbyState {
  lobby_state{
    player_hp: U32,
    bot_hp: U32,
    player_loadout: Loadout,
    bot_loadout: Loadout,
    player_filter: U32,
    bot_filter: U32,
  }
}

type GameMeta {
  game_meta{
    round: U32,
    level: U32,
    bot_total: U32,
  }
}

type GameArena {
  game_arena{
    player_hp: U32,
    player: Pos,
    bots: List(Bot),
    winner: U32,
  }
}

type GamePlan {
  game_plan{
    queue: List(Action),
    queue_len: U32,
    queue_locked: U32,
    mode: Mode,
  }
}

type GameState {
  game_state{
    meta: GameMeta,
    arena: GameArena,
    plan: GamePlan,
  }
}

type AppState {
  app_state{
    screen: Screen,
    lobby: LobbyState,
    game: GameState,
  }
}

type TrailStep {
  trail_step{x: U32, y: U32, step: U32}
}

type ActionSim {
  action_sim{
    from: Pos,
    to: Pos,
    target_pos: Pos,
    attack_tiles: List(Pos),
    next_state: GameState,
    hit: U32,
    player_died: U32,
    enemy_died: U32,
  }
}

type FightEvent {
  evt_go_home{}
  evt_open_play{}
  evt_open_story{}
  evt_lobby_play{}
  evt_lobby_player_hp_dec{}
  evt_lobby_player_hp_inc{}
  evt_lobby_bot_hp_dec{}
  evt_lobby_bot_hp_inc{}
  evt_lobby_skill{side: U32, skill: U32}
  evt_lobby_filter{side: U32, filter: U32}
  evt_move_up{}
  evt_move_down{}
  evt_move_left{}
  evt_move_right{}
  evt_skill_1{}
  evt_skill_2{}
  evt_skill_3{}
  evt_rotate_left{}
  evt_rotate_right{}
  evt_confirm{}
  evt_ready{}
  evt_escape{}
  evt_clear{}
  evt_reset{}
  evt_bot_count_dec{}
  evt_bot_count_inc{}
  evt_tick{}
  evt_ignore{}
}

def rules_get() -> Rules:
  rules{
    18,
    9,
    pos{6, 4},
    pos{11, 4},
    50,
      10,
  }

def _runtime_empty() -> RuntimeData:
  runtime_data{[], 0, 0}

def loadout_default() -> Loadout:
  loadout{
    Fight.default_setup_skill(0, 0),
    Fight.default_setup_skill(0, 1),
    Fight.default_setup_skill(0, 2),
  }

def lobby_init() -> LobbyState:
  lobby_state{Fight.default_hp(), Fight.default_hp(), loadout_default(), loadout_default(), 0, 0}

def app_init() -> AppState:
  lobby = lobby_init();
  app_state{play_lobby{}, lobby, _game_from_lobby(lobby)}

def game_test_app_init() -> AppState:
  game_test_app_from_slots_items(
    Fight.default_setup_skill(0, 0),
    Fight.default_setup_skill(0, 1),
    Fight.default_setup_skill(0, 2),
    Fight.default_setup_skill(0, 0),
    Fight.default_setup_skill(0, 1),
    Fight.default_setup_skill(0, 2),
    Fight.default_setup_item(0, 0),
    Fight.default_setup_item(0, 1),
    Fight.default_setup_item(0, 2),
    Fight.default_setup_item(1, 0),
    Fight.default_setup_item(1, 1),
    Fight.default_setup_item(1, 2)
  )

def game_test_app_from_slots_items(ps1: U32, ps2: U32, ps3: U32, bs1: U32, bs2: U32, bs3: U32, pi1: U32, pi2: U32, pi3: U32, bi1: U32, bi2: U32, bi3: U32) -> AppState:
  player_loadout = _loadout_from_slots(ps1, ps2, ps3);
  bot_loadout = _loadout_from_slots(bs1, bs2, bs3);
  lobby = _lobby_battle_loadouts(_lobby_from_loadouts(player_loadout, bot_loadout));
  app_state{battle{}, lobby, _game_from_lobby(lobby)}

def fight_app_init() -> AppState:
  game_test_app_init()

def fight_app_from_slots(ps1: U32, ps2: U32, ps3: U32, bs1: U32, bs2: U32, bs3: U32) -> AppState:
  game_test_app_from_slots_items(ps1, ps2, ps3, bs1, bs2, bs3, 0, 0, 0, 0, 0, 0)

def _sanitize_skill_slot(skill: U32) -> U32:
  match skill:
    case 0:
      0
    case value:
      _sanitize_skill_slot_nonzero(value, value <= Fight.skill_count())

def _sanitize_skill_slot_nonzero(value: U32, inside_range: U32) -> U32:
  match inside_range:
    case 0:
      0
    case _:
      value

def _loadout_from_slots(s1: U32, s2: U32, s3: U32) -> Loadout:
  loadout{_sanitize_skill_slot(s1), _sanitize_skill_slot(s2), _sanitize_skill_slot(s3)}

def _lobby_from_loadouts(player_loadout: Loadout, bot_loadout: Loadout) -> LobbyState:
  lobby_state{Fight.default_hp(), Fight.default_hp(), player_loadout, bot_loadout, 0, 0}

def _loadout_with_default_fallback(loadout_value: Loadout) -> Loadout:
  _loadout_with_default_fallback_count(loadout_value, _loadout_count(loadout_value))

def _loadout_with_default_fallback_count(loadout_value: Loadout, count: U32) -> Loadout:
  match count:
    case 0:
      loadout{2, 0, 0}
    case _:
      loadout_value

def _lobby_battle_loadouts(lobby: LobbyState) -> LobbyState:
  player_loadout = _loadout_with_default_fallback(_lobby_player_loadout(lobby));
  bot_loadout = _loadout_with_default_fallback(_lobby_bot_loadout(lobby));
  _lobby_with_bot_loadout(_lobby_with_player_loadout(lobby, player_loadout), bot_loadout)

def state_init() -> GameState:
  state_init_count(1)

def _meta(round: U32, level: U32, bot_total: U32) -> GameMeta:
  game_meta{round, level, bot_total}

def _arena(player_hp: U32, player: Pos, bots: List(Bot), winner: U32) -> GameArena:
  game_arena{player_hp, player, bots, winner}

def _plan_state(queue: List(Action), queue_len: U32, queue_locked: U32, mode: Mode) -> GamePlan:
  game_plan{queue, queue_len, queue_locked, mode}

def _game_from_lobby(lobby: LobbyState) -> GameState:
  match lobby:
    case lobby_state{player_hp, bot_hp, _, _, _, _}:
      game_state{
        _meta(1, 1, 1),
        _arena(player_hp, pos{6, 4}, _init_bots_with_hp(1, 0, bot_hp), 0),
        _plan_state(_queue_waits(), 0, 0, _plan_mode(_runtime_empty())),
      }

def state_init_count(bot_total: U32) -> GameState:
  total = _clamp_bot_total(bot_total);
  game_state{
    _meta(1, 1, total),
    _arena(Fight.default_hp(), pos{6, 4}, _init_bots(total, 0), 0),
    _plan_state(_queue_waits(), 0, 0, _plan_mode(_runtime_empty())),
  }

def _clamp_bot_total(bot_total: U32) -> U32:
  capped = _min_u32(bot_total, 25);
  match capped:
    case 0:
      1
    case _:
      capped

def _init_bots(remaining: U32, idx: U32) -> List(Bot):
  match remaining:
    case 0:
      []
    case count:
      bot{_spawn_bot_pos(idx), Fight.default_hp(), 0, 0}<>_init_bots(count - 1, idx + 1)

def _init_bots_with_hp(remaining: U32, idx: U32, hp: U32) -> List(Bot):
  match remaining:
    case 0:
      []
    case count:
      bot{_spawn_bot_pos(idx), hp, 0, 0}<>_init_bots_with_hp(count - 1, idx + 1, hp)

def _spawn_bot_pos(idx: U32) -> Pos:
  match idx:
    case 0:
      pos{11, 4}
    case extra_idx:
      _spawn_extra_bot_pos(extra_idx - 1)

def _spawn_extra_bot_pos(extra_idx: U32) -> Pos:
  col_idx = extra_idx / 5;
  row_idx = extra_idx % 5;
  pos{_spawn_extra_bot_col(col_idx), row_idx * 2}

def _spawn_extra_bot_col(col_idx: U32) -> U32:
  match col_idx:
    case 0:
      17
    case 1:
      15
    case 2:
      13
    case 3:
      9
    case _:
      7

def skill_len(skill: U32) -> U32:
  Fight.skill_len(skill)

def skill_point(skill: U32, rot: U32, idx: U32) -> Pos:
  pos{
    Fight.skill_point_x(skill, rot, idx),
    Fight.skill_point_y(skill, rot, idx),
  }

def _skill_effect_mask(skill: U32, idx: U32) -> U32:
  Fight.skill_effect_mask(skill, idx)

def _skill_player_mask(skill: U32, idx: U32) -> U32:
  Fight.skill_player_mask(skill, idx)

def _effect_has(mask: U32, flag: U32) -> U32:
  Fight.effect_has(mask, flag)

def _effect_damage(mask: U32) -> U32:
  Fight.effect_damage(mask)

def _effect_hook(mask: U32) -> U32:
  Fight.effect_hook(mask)

def _effect_ice(mask: U32) -> U32:
  Fight.effect_ice(mask)

def _effect_fire(mask: U32) -> U32:
  Fight.effect_fire(mask)

def _skill_hook_pull(skill: U32) -> U32:
  Fight.skill_hook_pull(skill)

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

def _loadout_contains(loadout_value: Loadout, skill: U32) -> U32:
  (_loadout_slot(loadout_value, 0) === skill)
  | (_loadout_slot(loadout_value, 1) === skill)
  | (_loadout_slot(loadout_value, 2) === skill)

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

def _loadout_cycle_skill(loadout_value: Loadout, round: U32) -> U32:
  count = _loadout_count(loadout_value);
  match count:
    case 0:
      0
    case total:
      _loadout_slot(loadout_value, round % total)

def _loadout_hp_player(lobby: LobbyState) -> U32:
  match lobby:
    case lobby_state{player_hp, _, _, _, _, _}:
      player_hp

def _loadout_hp_bot(lobby: LobbyState) -> U32:
  match lobby:
    case lobby_state{_, bot_hp, _, _, _, _}:
      bot_hp

def _lobby_player_loadout(lobby: LobbyState) -> Loadout:
  match lobby:
    case lobby_state{_, _, player_loadout, _, _, _}:
      player_loadout

def _lobby_bot_loadout(lobby: LobbyState) -> Loadout:
  match lobby:
    case lobby_state{_, _, _, bot_loadout, _, _}:
      bot_loadout

def _lobby_player_filter(lobby: LobbyState) -> U32:
  match lobby:
    case lobby_state{_, _, _, _, player_filter, _}:
      player_filter

def _lobby_bot_filter(lobby: LobbyState) -> U32:
  match lobby:
    case lobby_state{_, _, _, _, _, bot_filter}:
      bot_filter

def _lobby_with_player_hp(lobby: LobbyState, player_hp: U32) -> LobbyState:
  match lobby:
    case lobby_state{_, bot_hp, player_loadout, bot_loadout, player_filter, bot_filter}:
      lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, player_filter, bot_filter}

def _lobby_with_bot_hp(lobby: LobbyState, bot_hp: U32) -> LobbyState:
  match lobby:
    case lobby_state{player_hp, _, player_loadout, bot_loadout, player_filter, bot_filter}:
      lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, player_filter, bot_filter}

def _lobby_with_player_loadout(lobby: LobbyState, player_loadout: Loadout) -> LobbyState:
  match lobby:
    case lobby_state{player_hp, bot_hp, _, bot_loadout, player_filter, bot_filter}:
      lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, player_filter, bot_filter}

def _lobby_with_bot_loadout(lobby: LobbyState, bot_loadout: Loadout) -> LobbyState:
  match lobby:
    case lobby_state{player_hp, bot_hp, player_loadout, _, player_filter, bot_filter}:
      lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, player_filter, bot_filter}

def _lobby_with_player_filter(lobby: LobbyState, player_filter: U32) -> LobbyState:
  match lobby:
    case lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, _, bot_filter}:
      lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, player_filter, bot_filter}

def _lobby_with_bot_filter(lobby: LobbyState, bot_filter: U32) -> LobbyState:
  match lobby:
    case lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, player_filter, _}:
      lobby_state{player_hp, bot_hp, player_loadout, bot_loadout, player_filter, bot_filter}

def _hp_step_down(hp: U32) -> U32:
  _max_u32(_sub_floor(hp, 10), 10)

def _hp_step_up(hp: U32) -> U32:
  _min_u32(hp + 10, 200)

def _meta_round(meta: GameMeta) -> U32:
  match meta:
    case game_meta{round, _, _}:
      round

def _meta_level(meta: GameMeta) -> U32:
  match meta:
    case game_meta{_, level, _}:
      level

def _meta_bot_total(meta: GameMeta) -> U32:
  match meta:
    case game_meta{_, _, bot_total}:
      bot_total

def _arena_player_hp(arena: GameArena) -> U32:
  match arena:
    case game_arena{player_hp, _, _, _}:
      player_hp

def _arena_player(arena: GameArena) -> Pos:
  match arena:
    case game_arena{_, player, _, _}:
      player

def _arena_bots(arena: GameArena) -> List(Bot):
  match arena:
    case game_arena{_, _, bots, _}:
      bots

def _arena_winner(arena: GameArena) -> U32:
  match arena:
    case game_arena{_, _, _, winner}:
      winner

def _plan_queue(plan_value: GamePlan) -> List(Action):
  match plan_value:
    case game_plan{queue, _, _, _}:
      queue

def _plan_queue_len(plan_value: GamePlan) -> U32:
  match plan_value:
    case game_plan{_, queue_len, _, _}:
      queue_len

def _plan_queue_locked(plan_value: GamePlan) -> U32:
  match plan_value:
    case game_plan{_, _, queue_locked, _}:
      queue_locked

def _plan_mode_value(plan_value: GamePlan) -> Mode:
  match plan_value:
    case game_plan{_, _, _, mode}:
      mode

def planned_player_pos(state: GameState) -> Pos:
  match state:
    case game_state{_, arena, plan_value}:
      _planned_pos_from_queue(_arena_player(arena), _plan_queue(plan_value))

def movement_trail(state: GameState) -> List(TrailStep):
  match state:
    case game_state{_, arena, plan_value}:
      _movement_trail_from_queue(_arena_player(arena), _plan_queue(plan_value), 1)

def preview_tiles(state: GameState) -> List(Pos):
  match state:
    case game_state{_, arena, plan_value}:
      actor = _planned_pos_from_queue(_arena_player(arena), _plan_queue(plan_value));
      mode = _plan_mode_value(plan_value);
      active = _mode_is_target(mode);
      match active:
        case 0:
          _pos_nil()
        case _:
          _preview_tiles_for(_mode_skill(mode), _mode_rot(mode), _mode_origin(mode), actor, 0)

def preview_anchor_tiles(state: GameState) -> List(Pos):
  match state:
    case game_state{_, arena, plan_value}:
      actor = _planned_pos_from_queue(_arena_player(arena), _plan_queue(plan_value));
      mode = _plan_mode_value(plan_value);
      active = _mode_is_target(mode);
      match active:
        case 0:
          _pos_nil()
        case _:
          _preview_anchor_tiles_for(_mode_skill(mode), _mode_rot(mode), _mode_origin(mode), actor, 0)

def preview_hits(state: GameState) -> List(Pos):
  match state:
    case game_state{_, arena, plan_value}:
      player = _arena_player(arena);
      queue = _plan_queue(plan_value);
      mode = _plan_mode_value(plan_value);
      active = _mode_is_target(mode);
      match active:
        case 0:
          _pos_nil()
        case _:
          actor = _planned_pos_from_queue(player, queue);
          _preview_hits_for(_mode_skill(mode), _mode_rot(mode), _mode_origin(mode), actor, 0)

def target_valid(state: GameState) -> U32:
  match state:
    case game_state{_, arena, plan_value}:
      player = _arena_player(arena);
      queue = _plan_queue(plan_value);
      mode = _plan_mode_value(plan_value);
      active = _mode_is_target(mode);
      match active:
        case 0:
          0
        case _:
          actor = _planned_pos_from_queue(player, queue);
          _placement_valid(_mode_skill(mode), _mode_rot(mode), _mode_origin(mode), actor)

def queue_move_state(state: GameState, dir: U32) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      _queue_move_w(
        _meta_round(meta),
        _meta_level(meta),
        _meta_bot_total(meta),
        _arena_player_hp(arena),
        _arena_player(arena),
        _arena_bots(arena),
        _plan_queue(plan_value),
        _plan_queue_len(plan_value),
        _plan_queue_locked(plan_value),
        _plan_mode_value(plan_value),
        _arena_winner(arena),
        dir
      )

def start_target_state(state: GameState, skill: U32) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      _start_target_w(
        _meta_round(meta),
        _meta_level(meta),
        _meta_bot_total(meta),
        _arena_player_hp(arena),
        _arena_player(arena),
        _arena_bots(arena),
        _plan_queue(plan_value),
        _plan_queue_len(plan_value),
        _plan_queue_locked(plan_value),
        _plan_mode_value(plan_value),
        _arena_winner(arena),
        skill
      )

def move_target_state(state: GameState, dir: U32) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
        case _:
          origin = _mode_origin(mode);
          skill = _mode_skill(mode);
          rot = _mode_rot(mode);
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, _target_mode(skill, rot, _step_target_origin(origin, dir), _mode_runtime(mode)), winner)

def rotate_target_state(state: GameState, clockwise: U32) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
        case _:
          add = _rotate_step(clockwise);
          skill = _mode_skill(mode);
          old_rot = _mode_rot(mode);
          rot = (old_rot + add) % 4;
          origin = _rotate_target_origin(skill, old_rot, rot, _mode_origin(mode));
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, _target_mode(skill, rot, origin, _mode_runtime(mode)), winner)

def cancel_target_state(state: GameState) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
        case _:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, _plan_mode(_mode_runtime(mode)), winner)

def confirm_target_state(state: GameState) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
        case _:
          skill = _mode_skill(mode);
          rot = _mode_rot(mode);
          origin = _mode_origin(mode);
          actor = _planned_pos_from_queue(player, queue);
          valid = _placement_valid(skill, rot, origin, actor);
          match valid:
            case 0:
              _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
            case _:
              queue = _action_set(queue, queue_len, _attack_action(skill, origin, rot));
              _state(round, level, bot_total, player_hp, player, bots, queue, queue_len + 1, 1, _plan_mode(_mode_runtime(mode)), winner)

def clear_round_plan_state(state: GameState) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      match winner | _mode_is_playback(mode):
        case 0:
          _state(round, level, bot_total, player_hp, player, bots, _queue_waits(), 0, 0, _plan_mode(_mode_runtime(mode)), 0)
        case k:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, k)

def pop_last_planned_action_state(state: GameState) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      _pop_last_w(
        _meta_round(meta),
        _meta_level(meta),
        _meta_bot_total(meta),
        _arena_player_hp(arena),
        _arena_player(arena),
        _arena_bots(arena),
        _plan_queue(plan_value),
        _plan_queue_len(plan_value),
        _plan_queue_locked(plan_value),
        _plan_mode_value(plan_value),
        _arena_winner(arena)
      )

def build_bot_plan(state: GameState, bot_loadout: Loadout) -> List(List(Action)):
  match state:
    case game_state{meta, arena, _}:
      _build_all_bot_plans(_meta_round(meta), _arena_player_hp(arena), _arena_player(arena), _arena_bots(arena), _arena_winner(arena), 0, bot_loadout)

def resolve_actor_action_state(state: GameState, actor: U32, actor_idx: U32, action: Action) -> GameState:
  match actor:
    case 0:
      _resolve_player_action_state(state, action)
    case _:
      _resolve_bot_action_state(state, actor_idx, action)

def reset_round_planning_state(state: GameState) -> GameState:
  _reset_round_planning_state(state)

def simulate_actor_action(state: GameState, actor: U32, actor_idx: U32, action: Action) -> ActionSim:
  match actor:
    case 0:
      _simulate_player_action(state, action)
    case _:
      _simulate_bot_action(state, actor_idx, action)

def _state(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32,
) -> GameState:
  game_state{
    _meta(round, level, bot_total),
    _arena(player_hp, player, bots, winner),
    _plan_state(queue, queue_len, queue_locked, mode),
  }

def _set_mode_state(state: GameState, mode: Mode) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      _state(
        _meta_round(meta),
        _meta_level(meta),
        _meta_bot_total(meta),
        _arena_player_hp(arena),
        _arena_player(arena),
        _arena_bots(arena),
        _plan_queue(plan_value),
        _plan_queue_len(plan_value),
        _plan_queue_locked(plan_value),
        mode,
        _arena_winner(arena)
      )

def _wait_action() -> Action:
  wait{}

def _move_action(dir: U32) -> Action:
  move{dir}

def _attack_action(skill: U32, anchor: Pos, rot: U32) -> Action:
  attack{skill, anchor, rot}

def _queue3(a: Action, b: Action, c: Action) -> List(Action):
  a<>b<>c<>[]

def _pos_nil() -> List(Pos):
  []

def _pos_cons(head: Pos, tail: List(Pos)) -> List(Pos):
  head<>tail

def _trail_nil() -> List(TrailStep):
  []

def _trail_cons(head: TrailStep, tail: List(TrailStep)) -> List(TrailStep):
  head<>tail

def _terrain_nil() -> List(Terrain):
  []

def _terrain_cons(head: Terrain, tail: List(Terrain)) -> List(Terrain):
  head<>tail

def _plan_mode(runtime: RuntimeData) -> Mode:
  plan{runtime}

def _target_mode(skill: U32, rot: U32, origin: Pos, runtime: RuntimeData) -> Mode:
  target{skill, rot, origin, runtime}

def _playback_mode(
  idx: U32, phase: U32, actor: U32, actor_idx: U32,
  action: Action, sim: ActionSim, bot_plans: List(List(Action)), runtime: RuntimeData,
) -> Mode:
  playback{idx, phase, actor, actor_idx, action, sim, bot_plans, runtime}

def _queue_waits() -> List(Action):
  _queue3(_wait_action(), _wait_action(), _wait_action())

def _rotate_step(clockwise: U32) -> U32:
  match clockwise:
    case 0:
      3
    case _:
      1

def _queue_move_w(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, dir: U32,
) -> GameState:
  match winner:
    case 0:
      _queue_move_plan(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, _mode_is_plan(mode), dir)
    case k:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, k)

def _queue_move_plan(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, plan_mode: U32, dir: U32,
) -> GameState:
  match plan_mode:
    case 0:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, 0)
    case _:
      match _status_move_locked(_runtime_player_ice(_mode_runtime(mode))):
        case 0:
          _queue_move_lock(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, dir)
        case _:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, 0)

def _queue_move_lock(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, dir: U32,
) -> GameState:
  match queue_locked:
    case 0:
      _queue_move_len(round, level, bot_total, player_hp, player, bots, queue, queue_len, 0, mode, dir)
    case lock:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, lock, mode, 0)

def _queue_move_len(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, dir: U32,
) -> GameState:
  match queue_len:
    case 0:
      _queue_move_ok(round, level, bot_total, player_hp, player, bots, queue, 0, queue_locked, 0, _mode_runtime(mode), dir)
    case 1:
      _queue_move_ok(round, level, bot_total, player_hp, player, bots, queue, 1, queue_locked, 0, _mode_runtime(mode), dir)
    case q:
      _state(round, level, bot_total, player_hp, player, bots, queue, q, queue_locked, mode, 0)

def _start_target_w(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, skill: U32,
) -> GameState:
  match winner:
    case 0:
      _start_target_lock(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, skill)
    case k:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, k)

def _start_target_lock(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, skill: U32,
) -> GameState:
  match queue_locked:
    case 0:
      _start_target_len(round, level, bot_total, player_hp, player, bots, queue, queue_len, 0, mode, skill)
    case lock:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, lock, mode, 0)

def _start_target_len(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, skill: U32,
) -> GameState:
  match queue_len:
    case 3:
      _state(round, level, bot_total, player_hp, player, bots, queue, 3, queue_locked, mode, 0)
    case q:
      _start_target_apply(round, level, bot_total, player_hp, player, bots, queue, q, queue_locked, _mode_runtime(mode), skill)

def _pop_last_w(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32,
) -> GameState:
  match winner:
    case 0:
      _pop_last_plan(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, _mode_is_plan(mode))
    case k:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, k)

def _pop_last_plan(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, plan_mode: U32,
) -> GameState:
  match plan_mode:
    case 0:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, 0)
    case _:
      _pop_last_len(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode)

def _pop_last_len(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode,
) -> GameState:
  match queue_len:
    case 0:
      _state(round, level, bot_total, player_hp, player, bots, queue, 0, queue_locked, mode, 0)
    case q:
      last = q - 1;
      queue = _action_set(queue, last, _wait_action());
      lock = _queue_has_attack(queue);
      _state(round, level, bot_total, player_hp, player, bots, queue, last, lock, _plan_mode(_mode_runtime(mode)), 0)

def _start_target_apply(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, runtime: RuntimeData, skill: U32,
) -> GameState:
  _state(
    round,
    level,
    bot_total,
    player_hp,
    player,
    bots,
    queue,
    queue_len,
    queue_locked,
    _target_mode(skill, 0, _default_target_origin(skill, _planned_pos_from_queue(player, queue)), runtime),
    0
  )

def _queue_move_ok(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, winner: U32, runtime: RuntimeData, dir: U32,
) -> GameState:
  planned = _planned_pos_from_queue(player, queue);
  next = _step_blocked_player(planned, dir, bots);
  same = _pos_eq(planned, next);
  match same:
    case 0:
      queue = _action_set(queue, queue_len, _move_action(dir));
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len + 1, queue_locked, _plan_mode(runtime), winner)
    case _:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, _plan_mode(runtime), winner)

def _planned_pos_from_queue(pos: Pos, queue: List(Action)) -> Pos:
  match queue:
    case []:
      pos
    case hd<>tl:
      kind = _action_kind(hd);
      match kind:
        case 1:
          _planned_pos_from_queue(_step_free(pos, _action_dir(hd)), tl)
        case _:
          _planned_pos_from_queue(pos, tl)

def _movement_trail_from_queue(pos: Pos, queue: List(Action), step: U32) -> List(TrailStep):
  match queue:
    case []:
      _trail_nil()
    case hd<>tl:
      kind = _action_kind(hd);
      match kind:
        case 1:
          nxt = _step_free(pos, _action_dir(hd));
          _trail_cons(_trail_step_of_pos(nxt, step), _movement_trail_from_queue(nxt, tl, step + 1))
        case _:
          _movement_trail_from_queue(pos, tl, step)

def _preview_tiles_for(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> List(Pos):
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      rest = _preview_tiles_for(skill, rot, origin, actor, idx + 1);
      inside = _skill_world_inside(actor, origin, local);
      match inside:
        case 0:
          rest
        case _:
          _pos_cons(_skill_world_pos(actor, origin, local), rest)
    case _:
      _pos_nil()

def _preview_anchor_tiles_for(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> List(Pos):
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      rest = _preview_anchor_tiles_for(skill, rot, origin, actor, idx + 1);
      inside = _skill_world_inside(actor, origin, local);
      keep = inside & _skill_player_mask(skill, idx);
      match keep:
        case 0:
          rest
        case _:
          _pos_cons(_skill_world_pos(actor, origin, local), rest)
    case _:
      _pos_nil()

def _preview_hits_for(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> List(Pos):
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      rest = _preview_hits_for(skill, rot, origin, actor, idx + 1);
      inside = _skill_world_inside(actor, origin, local);
      same = _pos_eq(local, origin);
      keep = inside & (1 ^ same) & _skill_has_effect(skill, idx);
      match keep:
        case 0:
          rest
        case _:
          _pos_cons(_skill_world_pos(actor, origin, local), rest)
    case _:
      _pos_nil()

def _effect_tiles_for(skill: U32, rot: U32, origin: Pos, actor: Pos, flag: U32, idx: U32) -> List(Pos):
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      rest = _effect_tiles_for(skill, rot, origin, actor, flag, idx + 1);
      inside = _skill_world_inside(actor, origin, local);
      same = _pos_eq(local, origin);
      code = _skill_effect_mask(skill, idx);
      keep = inside & (1 ^ same) & _effect_has(code, flag);
      match keep:
        case 0:
          rest
        case _:
          _pos_cons(_skill_world_pos(actor, origin, local), rest)
    case _:
      _pos_nil()

def _placement_valid(skill: U32, rot: U32, origin: Pos, actor: Pos) -> U32:
  _placement_covers(skill, rot, origin, actor, 0)
  & _placement_has_visible_effect(skill, rot, origin, actor, 0)

def _placement_covers(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> U32:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      same = _pos_eq(local, origin);
      match same & _skill_can_anchor_at(skill, idx):
        case 0:
          _placement_covers(skill, rot, origin, actor, idx + 1)
        case _:
          1
    case _:
      0

def _placement_has_visible_effect(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> U32:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      inside = _skill_world_inside(actor, origin, local);
      same = _pos_eq(local, origin);
      useful = inside & (1 ^ same) & _skill_has_effect(skill, idx);
      match useful:
        case 0:
          _placement_has_visible_effect(skill, rot, origin, actor, idx + 1)
        case _:
          1
    case _:
      0

def _preview_hit_contains(skill: U32, rot: U32, origin: Pos, actor: Pos, target: Pos, idx: U32) -> U32:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      inside = _skill_world_inside(actor, origin, local);
      same_actor = _pos_eq(local, origin);
      same_target = _pos_eq(_skill_world_pos(actor, origin, local), target);
      hit = inside & (1 ^ same_actor) & same_target & _skill_has_effect(skill, idx);
      match hit:
        case 0:
          _preview_hit_contains(skill, rot, origin, actor, target, idx + 1)
        case _:
          1
    case _:
      0

def _attack_hits(skill: U32, rot: U32, origin: Pos, actor: Pos, target: Pos) -> U32:
  valid = _placement_valid(skill, rot, origin, actor);
  match valid:
    case 0:
      0
    case _:
      _preview_hit_contains(skill, rot, origin, actor, target, 0)

def _default_target_origin(skill: U32, actor: Pos) -> Pos:
  _default_anchor_for_skill(skill, 0, 0)

def _rotate_target_origin(skill: U32, old_rot: U32, new_rot: U32, origin: Pos) -> Pos:
  match _skill_uses_player_tiles(skill, 0):
    case 0:
      origin
    case _:
      old_default = _default_anchor_for_skill(skill, old_rot, 0);
      match _pos_eq(origin, old_default):
        case 0:
          origin
        case _:
          _default_anchor_for_skill(skill, new_rot, 0)

def _step_target_origin(origin: Pos, dir: U32) -> Pos:
  match origin:
    case pos{x, y}:
      match dir:
        case 0:
          pos{x, y + 1}
        case 1:
          pos{x, _sub_floor(y, 1)}
        case 2:
          pos{x + 1, y}
        case 3:
          pos{_sub_floor(x, 1), y}
        case _:
          pos{x, y}

def _origin_from_anchor(actor: Pos, anchor: Pos) -> Pos:
  match actor:
    case pos{ax, ay}:
      match anchor:
        case pos{sx, sy}:
          pos{_sub_floor(ax, sx), _sub_floor(ay, sy)}

def _skill_world_inside(actor: Pos, origin: Pos, local: Pos) -> U32:
  match actor:
    case pos{ax, ay}:
      match origin:
        case pos{ox, oy}:
          match local:
            case pos{lx, ly}:
              _skill_world_axis_inside(ax, ox, lx, 18) & _skill_world_axis_inside(ay, oy, ly, 9)

def _skill_world_axis_inside(actor_axis: U32, origin_axis: U32, local_axis: U32, limit: U32) -> U32:
  match _u32_gte(local_axis, origin_axis):
    case 0:
      _u32_gte(actor_axis, _sub_floor(origin_axis, local_axis))
    case _:
      _u32_lt(actor_axis + _sub_floor(local_axis, origin_axis), limit)

def _skill_world_pos(actor: Pos, origin: Pos, local: Pos) -> Pos:
  match actor:
    case pos{ax, ay}:
      match origin:
        case pos{ox, oy}:
          match local:
            case pos{lx, ly}:
              pos{_skill_world_axis_pos(ax, ox, lx), _skill_world_axis_pos(ay, oy, ly)}

def _skill_world_axis_pos(actor_axis: U32, origin_axis: U32, local_axis: U32) -> U32:
  match _u32_gte(local_axis, origin_axis):
    case 0:
      _sub_floor(actor_axis, _sub_floor(origin_axis, local_axis))
    case _:
      actor_axis + _sub_floor(local_axis, origin_axis)

def _anchor_for_origin(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> Pos:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      world = _pos_add(origin, local);
      same = _pos_eq(world, actor) & _skill_can_anchor_at(skill, idx);
      match same:
        case 0:
          _anchor_for_origin(skill, rot, origin, actor, idx + 1)
        case _:
          local
    case _:
      pos{0, 0}

def _default_anchor_for_skill(skill: U32, rot: U32, idx: U32) -> Pos:
  match _skill_uses_player_tiles(skill, 0):
    case 0:
      _first_anchor_for_skill(skill, rot, idx)
    case _:
      _preferred_anchor_for_skill(skill, rot)

def _first_anchor_for_skill(skill: U32, rot: U32, idx: U32) -> Pos:
  len = skill_len(skill);
  match idx === len:
    case 0:
      point = skill_point(skill, rot, idx);
      match _skill_can_anchor_at(skill, idx):
        case 0:
          _first_anchor_for_skill(skill, rot, idx + 1)
        case _:
          point
    case _:
      pos{0, 0}

def _preferred_anchor_for_skill(skill: U32, rot: U32) -> Pos:
  first = _first_anchor_for_skill(skill, rot, 0);
  min_x = _anchor_min_x(skill, rot, 0, _pos_x(first));
  max_x = _anchor_max_x(skill, rot, 0, _pos_x(first));
  min_y = _anchor_min_y(skill, rot, 0, _pos_y(first));
  max_y = _anchor_max_y(skill, rot, 0, _pos_y(first));
  _preferred_anchor_for_skill_pick(skill, rot, 0, min_x + max_x, min_y + max_y, first, _anchor_center_dist(first, min_x + max_x, min_y + max_y))

def _preferred_anchor_for_skill_pick(
  skill: U32, rot: U32, idx: U32,
  center_x2: U32, center_y2: U32,
  best: Pos, best_dist: U32,
) -> Pos:
  len = skill_len(skill);
  match idx === len:
    case 0:
      point = skill_point(skill, rot, idx);
      match _skill_can_anchor_at(skill, idx):
        case 0:
          _preferred_anchor_for_skill_pick(skill, rot, idx + 1, center_x2, center_y2, best, best_dist)
        case _:
          dist = _anchor_center_dist(point, center_x2, center_y2);
          match _u32_lt(dist, best_dist):
            case 0:
              _preferred_anchor_for_skill_pick(skill, rot, idx + 1, center_x2, center_y2, best, best_dist)
            case _:
              _preferred_anchor_for_skill_pick(skill, rot, idx + 1, center_x2, center_y2, point, dist)
    case _:
      best

def _anchor_center_dist(point: Pos, center_x2: U32, center_y2: U32) -> U32:
  _abs_diff(_pos_x(point) + _pos_x(point), center_x2)
  + _abs_diff(_pos_y(point) + _pos_y(point), center_y2)

def _anchor_min_x(skill: U32, rot: U32, idx: U32, current: U32) -> U32:
  len = skill_len(skill);
  match idx === len:
    case 0:
      point = skill_point(skill, rot, idx);
      match _skill_can_anchor_at(skill, idx):
        case 0:
          _anchor_min_x(skill, rot, idx + 1, current)
        case _:
          _anchor_min_x(skill, rot, idx + 1, _min_u32(current, _pos_x(point)))
    case _:
      current

def _anchor_max_x(skill: U32, rot: U32, idx: U32, current: U32) -> U32:
  len = skill_len(skill);
  match idx === len:
    case 0:
      point = skill_point(skill, rot, idx);
      match _skill_can_anchor_at(skill, idx):
        case 0:
          _anchor_max_x(skill, rot, idx + 1, current)
        case _:
          _anchor_max_x(skill, rot, idx + 1, _max_u32(current, _pos_x(point)))
    case _:
      current

def _anchor_min_y(skill: U32, rot: U32, idx: U32, current: U32) -> U32:
  len = skill_len(skill);
  match idx === len:
    case 0:
      point = skill_point(skill, rot, idx);
      match _skill_can_anchor_at(skill, idx):
        case 0:
          _anchor_min_y(skill, rot, idx + 1, current)
        case _:
          _anchor_min_y(skill, rot, idx + 1, _min_u32(current, _pos_y(point)))
    case _:
      current

def _anchor_max_y(skill: U32, rot: U32, idx: U32, current: U32) -> U32:
  len = skill_len(skill);
  match idx === len:
    case 0:
      point = skill_point(skill, rot, idx);
      match _skill_can_anchor_at(skill, idx):
        case 0:
          _anchor_max_y(skill, rot, idx + 1, current)
        case _:
          _anchor_max_y(skill, rot, idx + 1, _max_u32(current, _pos_y(point)))
    case _:
      current

def _skill_uses_player_tiles(skill: U32, idx: U32) -> U32:
  len = skill_len(skill);
  match idx === len:
    case 0:
      match _skill_player_mask(skill, idx):
        case 0:
          _skill_uses_player_tiles(skill, idx + 1)
        case _:
          1
    case _:
      0

def _skill_can_anchor_at(skill: U32, idx: U32) -> U32:
  match _skill_uses_player_tiles(skill, 0):
    case 0:
      1
    case _:
      _skill_player_mask(skill, idx)

def _skill_has_effect(skill: U32, idx: U32) -> U32:
  1 ^ (_skill_effect_mask(skill, idx) === 0)

def _bot_pos(item: Bot) -> Pos:
  match item:
    case bot{pos_value, _, _, _}:
      pos_value

def _bot_hp(item: Bot) -> U32:
  match item:
    case bot{_, hp, _, _}:
      hp

def _bot_fire(item: Bot) -> U32:
  match item:
    case bot{_, _, fire, _}:
      fire

def _bot_ice(item: Bot) -> U32:
  match item:
    case bot{_, _, _, ice}:
      ice

def _bot_alive(item: Bot) -> U32:
  1 ^ _hp_empty(_bot_hp(item))

def _bot_with_pos(item: Bot, next_pos: Pos) -> Bot:
  match item:
    case bot{_, hp, fire, ice}:
      bot{next_pos, hp, fire, ice}

def _bot_with_hp(item: Bot, next_hp: U32) -> Bot:
  match item:
    case bot{pos_value, _, fire, ice}:
      bot{pos_value, next_hp, fire, ice}

def _bot_with_fire(item: Bot, fire: U32) -> Bot:
  match item:
    case bot{pos_value, hp, _, ice}:
      bot{pos_value, hp, fire, ice}

def _bot_with_ice(item: Bot, ice: U32) -> Bot:
  match item:
    case bot{pos_value, hp, fire, _}:
      bot{pos_value, hp, fire, ice}

def _bot_at(items: List(Bot), idx: U32) -> Bot:
  match items:
    case []:
      bot{pos{0, 0}, 0, 0, 0}
    case head<>tail:
      match idx:
        case 0:
          head
        case step:
          _bot_at(tail, step - 1)

def _bot_set(items: List(Bot), idx: U32, next_bot: Bot) -> List(Bot):
  match items:
    case []:
      []
    case head<>tail:
      match idx:
        case 0:
          next_bot<>tail
        case step:
          head<>_bot_set(tail, step - 1, next_bot)

def _bot_pos_at(items: List(Bot), idx: U32) -> Pos:
  _bot_pos(_bot_at(items, idx))

def _bot_hp_at(items: List(Bot), idx: U32) -> U32:
  _bot_hp(_bot_at(items, idx))

def _bot_dead_at(items: List(Bot), idx: U32) -> U32:
  _hp_empty(_bot_hp_at(items, idx))

def _bots_any_alive(items: List(Bot)) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      match _bot_alive(head):
        case 0:
          _bots_any_alive(tail)
        case _:
          1

def _bots_live_has_pos(items: List(Bot), target: Pos) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      same = _pos_eq(_bot_pos(head), target);
      live = _bot_alive(head);
      match same & live:
        case 0:
          _bots_live_has_pos(tail, target)
        case _:
          1

def _bots_other_live_has_pos(items: List(Bot), ignore_idx: U32, target: Pos) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      match ignore_idx:
        case 0:
          _bots_live_has_pos(tail, target)
        case step:
          same = _pos_eq(_bot_pos(head), target);
          live = _bot_alive(head);
          match same & live:
            case 0:
              _bots_other_live_has_pos(tail, step - 1, target)
            case _:
              1

def _bots_hit_any_tiles(items: List(Bot), tiles: List(Pos)) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      live = _bot_alive(head);
      same = _pos_list_has(tiles, _bot_pos(head));
      match live & same:
        case 0:
          _bots_hit_any_tiles(tail, tiles)
        case _:
          1

def _damage_bots_on_tiles(items: List(Bot), tiles: List(Pos), amount: U32) -> List(Bot):
  match items:
    case []:
      []
    case head<>tail:
      live = _bot_alive(head);
      hit = _pos_list_has(tiles, _bot_pos(head));
      next_bot = _damage_bot_hit(head, live & hit, amount);
      next_bot<>_damage_bots_on_tiles(tail, tiles, amount)

def _damage_bot_hit(item: Bot, hit: U32, amount: U32) -> Bot:
  match hit:
    case 0:
      item
    case _:
      _bot_with_hp(item, _damage_hp_by(_bot_hp(item), amount))

def _bots_any_died_between(before: List(Bot), after: List(Bot)) -> U32:
  match before:
    case []:
      0
    case bh<>bt:
      match after:
        case []:
          0
        case ah<>at:
          died = _died_between(_bot_hp(bh), _bot_hp(ah));
          match died:
            case 0:
              _bots_any_died_between(bt, at)
            case _:
              1

def _first_live_bot_pos(items: List(Bot)) -> Pos:
  match items:
    case []:
      pos{0, 0}
    case head<>tail:
      match _bot_alive(head):
        case 0:
          _first_live_bot_pos(tail)
        case _:
          _bot_pos(head)

def _bot_hp_at_pos(items: List(Bot), target: Pos) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      same = _pos_eq(_bot_pos(head), target);
      live = _bot_alive(head);
      match same & live:
        case 0:
          _bot_hp_at_pos(tail, target)
        case _:
          _bot_hp(head)

def _live_bot_count(items: List(Bot)) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      _bot_alive(head) + _live_bot_count(tail)

def _bot_move_locked(item: Bot) -> U32:
  _status_move_locked(_bot_ice(item))

def _hook_step_toward(from_pos: Pos, to_pos: Pos) -> Pos:
  match from_pos:
    case pos{fx, fy}:
      match to_pos:
        case pos{tx, ty}:
          pos{_hook_step_axis(fx, tx), _hook_step_axis(fy, ty)}

def _hook_step_axis(from_value: U32, to_value: U32) -> U32:
  match _u32_lt(from_value, to_value):
    case 0:
      match _u32_lt(to_value, from_value):
        case 0:
          from_value
        case _:
          from_value - 1
    case _:
      from_value + 1

def _hook_distance(actor: Pos, target: Pos) -> U32:
  _max_u32(_abs_diff(_pos_x(actor), _pos_x(target)), _abs_diff(_pos_y(actor), _pos_y(target)))

def _hook_pull_target(target: Pos, actor: Pos, player: Pos, bots: List(Bot), ignore_idx: U32, steps: U32) -> Pos:
  match steps:
    case 0:
      target
    case remaining:
      next = _hook_step_toward(target, actor);
      blocked = _pos_eq(next, actor) | _pos_eq(next, player) | _bots_other_live_has_pos(bots, ignore_idx, next);
      match blocked:
        case 0:
          _hook_pull_target(next, actor, player, bots, ignore_idx, remaining - 1)
        case _:
          target

def _hook_closest_bot_idx(items: List(Bot), actor: Pos, tiles: List(Pos), idx: U32, best_idx: U32, best_dist: U32) -> U32:
  match items:
    case []:
      best_idx
    case head<>tail:
      live = _bot_alive(head);
      hit = _pos_list_has(tiles, _bot_pos(head));
      dist = _hook_distance(actor, _bot_pos(head));
      better = _u32_lt(dist, best_dist);
      take = live & hit & better;
      match take:
        case 0:
          _hook_closest_bot_idx(tail, actor, tiles, idx + 1, best_idx, best_dist)
        case _:
          _hook_closest_bot_idx(tail, actor, tiles, idx + 1, idx, dist)

def _hook_player_bots(actor: Pos, bots: List(Bot), tiles: List(Pos), pull: U32) -> List(Bot):
  idx = _hook_closest_bot_idx(bots, actor, tiles, 0, 99, 99);
  match idx:
    case 99:
      bots
    case target_idx:
      current = _bot_at(bots, target_idx);
      next_pos = _hook_pull_target(_bot_pos(current), actor, actor, bots, target_idx, pull);
      _bot_set(bots, target_idx, _bot_with_pos(current, next_pos))

def _hook_bot_player(actor: Pos, player: Pos, bots: List(Bot), bot_idx: U32, tiles: List(Pos), pull: U32) -> Pos:
  match _pos_list_has(tiles, player):
    case 0:
      player
    case _:
      _hook_pull_target(player, actor, actor, bots, bot_idx, pull)

def _apply_player_fire_and_ice(player_hp: U32, player: Pos, runtime: RuntimeData) -> RuntimeData:
  terrain = _runtime_terrain(runtime);
  fire_now = _fire_refresh_ticks(_runtime_player_fire(runtime), _terrain_has_fire_at(terrain, player));
  ice_now = _ice_after_round(_runtime_player_ice(runtime), _terrain_has_ice_at(terrain, player));
  _runtime_with_player_ice(_runtime_with_player_fire(runtime, _fire_store_after_tick(fire_now)), ice_now)

def _player_fire_damage(runtime: RuntimeData, player: Pos) -> U32:
  fire_now = _fire_refresh_ticks(_runtime_player_fire(runtime), _terrain_has_fire_at(_runtime_terrain(runtime), player));
  _fire_damage_for_ticks(fire_now)

def _apply_bots_status_round(items: List(Bot), terrain: List(Terrain)) -> List(Bot):
  match items:
    case []:
      []
    case head<>tail:
      pos_value = _bot_pos(head);
      fire_now = _fire_refresh_ticks(_bot_fire(head), _terrain_has_fire_at(terrain, pos_value));
      ice_now = _ice_after_round(_bot_ice(head), _terrain_has_ice_at(terrain, pos_value));
      hp_after = _damage_hp_by(_bot_hp(head), _fire_damage_for_ticks(fire_now));
      bot{pos_value, hp_after, _fire_store_after_tick(fire_now), ice_now}<>_apply_bots_status_round(tail, terrain)

def _build_all_bot_plans(round: U32, player_hp: U32, player: Pos, bots: List(Bot), winner: U32, idx: U32, bot_loadout: Loadout) -> List(List(Action)):
  _build_all_bot_plans_items(round, player_hp, player, bots, bots, winner, idx, bot_loadout)

def _build_all_bot_plans_items(round: U32, player_hp: U32, player: Pos, all_bots: List(Bot), items: List(Bot), winner: U32, idx: U32, bot_loadout: Loadout) -> List(List(Action)):
  match items:
    case []:
      []
    case _<>tail:
      _build_bot_plan_w(round, player_hp, player, all_bots, idx, winner, bot_loadout)<>_build_all_bot_plans_items(round, player_hp, player, all_bots, tail, winner, idx + 1, bot_loadout)

def _build_bot_plan_w(round: U32, player_hp: U32, player: Pos, bots: List(Bot), bot_idx: U32, winner: U32, bot_loadout: Loadout) -> List(Action):
  stopped = winner | _hp_empty(player_hp) | _bot_dead_at(bots, bot_idx);
  match stopped:
    case 0:
      _build_bot_plan_locked(_bot_move_locked(_bot_at(bots, bot_idx)), player, _bot_pos_at(bots, bot_idx), bots, bot_idx, round, bot_loadout)
    case _:
      _queue_waits()

def _build_bot_plan_locked(locked: U32, player: Pos, enemy: Pos, bots: List(Bot), bot_idx: U32, round: U32, bot_loadout: Loadout) -> List(Action):
  match locked:
    case 0:
      _build_bot_plan(player, enemy, bots, bot_idx, round, bot_loadout)
    case _:
      _build_bot_locked_plan(enemy, player, bot_loadout)

def _build_bot_locked_plan(enemy: Pos, player: Pos, bot_loadout: Loadout) -> List(Action):
  attack = _find_attack(enemy, player, bot_loadout);
  hit = _action_is_attack(attack);
  match hit:
    case 0:
      _queue_waits()
    case _:
      _queue3(attack, _wait_action(), _wait_action())

def _build_bot_plan(player: Pos, enemy: Pos, bots: List(Bot), bot_idx: U32, round: U32, bot_loadout: Loadout) -> List(Action):
  _build_bot_simple_plan(round, enemy, player, bots, bot_idx, bot_loadout)

def _build_bot_simple_plan(round: U32, enemy: Pos, player: Pos, bots: List(Bot), bot_idx: U32, bot_loadout: Loadout) -> List(Action):
  dir1 = _chase_dir(enemy, player);
  pos1 = _step_or_stay_bot(enemy, dir1, player, bots, bot_idx);
  _build_bot_simple_plan_step2(round, enemy, player, bots, bot_idx, bot_loadout, dir1, pos1)

def _build_bot_simple_plan_step2(round: U32, enemy: Pos, player: Pos, bots: List(Bot), bot_idx: U32, bot_loadout: Loadout, dir1: U32, pos1: Pos) -> List(Action):
  dir2 = _chase_dir(pos1, player);
  pos2 = _step_or_stay_bot(pos1, dir2, player, bots, bot_idx);
  attack2 = _find_attack(pos2, player, bot_loadout);
  hit2 = _action_is_attack(attack2);
  match hit2:
    case 0:
      _fallback_plan(round, enemy, player, bots, bot_idx, bot_loadout)
    case _:
      _queue3(_move_or_wait(dir1), _move_or_wait(dir2), attack2)

def _find_one_move_plan(enemy: Pos, player: Pos, bots: List(Bot), bot_idx: U32, dir: U32, bot_loadout: Loadout) -> List(Action):
  match dir:
    case 4:
      _queue_waits()
    case d:
      pos1 = _step_blocked_bot(enemy, d, player, bots, bot_idx);
      same = _pos_eq(pos1, enemy);
      match same:
        case 0:
          attack = _find_attack(pos1, player, bot_loadout);
          hit = _action_is_attack(attack);
          match hit:
            case 0:
              _find_one_move_plan(enemy, player, bots, bot_idx, d + 1, bot_loadout)
            case _:
              _queue3(_move_action(d), attack, _wait_action())
        case _:
          _find_one_move_plan(enemy, player, bots, bot_idx, d + 1, bot_loadout)

def _find_two_move_plan(enemy: Pos, player: Pos, bots: List(Bot), bot_idx: U32, dir1: U32, bot_loadout: Loadout) -> List(Action):
  match dir1:
    case 4:
      _queue_waits()
    case d1:
      pos1 = _step_blocked_bot(enemy, d1, player, bots, bot_idx);
      same = _pos_eq(pos1, enemy);
      match same:
        case 0:
          plan = _find_two_move_from(enemy, player, bots, bot_idx, d1, pos1, 0, bot_loadout);
          hit = _queue_has_attack(plan);
          match hit:
            case 0:
              _find_two_move_plan(enemy, player, bots, bot_idx, d1 + 1, bot_loadout)
            case _:
              plan
        case _:
          _find_two_move_plan(enemy, player, bots, bot_idx, d1 + 1, bot_loadout)

def _find_two_move_from(enemy: Pos, player: Pos, bots: List(Bot), bot_idx: U32, dir1: U32, pos1: Pos, dir2: U32, bot_loadout: Loadout) -> List(Action):
  match dir2:
    case 4:
      _queue_waits()
    case d2:
      pos2 = _step_blocked_bot(pos1, d2, player, bots, bot_idx);
      same = _pos_eq(pos2, pos1);
      match same:
        case 0:
          attack = _find_attack(pos2, player, bot_loadout);
          hit = _action_is_attack(attack);
          match hit:
            case 0:
              _find_two_move_from(enemy, player, bots, bot_idx, dir1, pos1, d2 + 1, bot_loadout)
            case _:
              _queue3(_move_action(dir1), _move_action(d2), attack)
        case _:
          _find_two_move_from(enemy, player, bots, bot_idx, dir1, pos1, d2 + 1, bot_loadout)

def _fallback_plan(round: U32, enemy: Pos, player: Pos, bots: List(Bot), bot_idx: U32, bot_loadout: Loadout) -> List(Action):
  skill = _round_skill(round, bot_loadout);
  dir1 = _chase_dir(enemy, player);
  pos1 = _step_or_stay_bot(enemy, dir1, player, bots, bot_idx);
  dir2 = _chase_dir(pos1, player);
  pos2 = _step_or_stay_bot(pos1, dir2, player, bots, bot_idx);
  _queue3(_move_or_wait(dir1), _move_or_wait(dir2), _first_valid_attack(skill, pos2))

def _first_valid_attack(skill: U32, actor: Pos) -> Action:
  _first_valid_attack_rot(skill, actor, 0)

def _first_valid_attack_rot(skill: U32, actor: Pos, rot: U32) -> Action:
  match rot:
    case 4:
      _wait_action()
    case r:
      attack = _first_valid_attack_anchor(skill, actor, r, 0);
      hit = _action_is_attack(attack);
      match hit:
        case 0:
          _first_valid_attack_rot(skill, actor, r + 1)
        case _:
          attack

def _first_valid_attack_anchor(skill: U32, actor: Pos, rot: U32, idx: U32) -> Action:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      anchor = skill_point(skill, rot, idx);
      valid = _placement_valid(skill, rot, anchor, actor);
      match valid:
        case 0:
          _first_valid_attack_anchor(skill, actor, rot, idx + 1)
        case _:
          _attack_action(skill, anchor, rot)
    case _:
      _wait_action()

def _find_attack(actor: Pos, target: Pos, loadout_value: Loadout) -> Action:
  _find_attack_slot(actor, target, loadout_value, 0)

def _find_attack_slot(actor: Pos, target: Pos, loadout_value: Loadout, idx: U32) -> Action:
  match idx:
    case 3:
      _wait_action()
    case slot_idx:
      skill = _loadout_slot(loadout_value, slot_idx);
      match skill:
        case 0:
          _find_attack_slot(actor, target, loadout_value, slot_idx + 1)
        case current_skill:
          attack = _find_attack_rot(actor, target, current_skill, 0);
          hit = _action_is_attack(attack);
          match hit:
            case 0:
              _find_attack_slot(actor, target, loadout_value, slot_idx + 1)
            case _:
              attack

def _find_attack_rot(actor: Pos, target: Pos, skill: U32, rot: U32) -> Action:
  match rot:
    case 4:
      _wait_action()
    case r:
      attack = _find_attack_anchor(actor, target, skill, r, 0);
      hit = _action_is_attack(attack);
      match hit:
        case 0:
          _find_attack_rot(actor, target, skill, r + 1)
        case _:
          attack

def _find_attack_anchor(actor: Pos, target: Pos, skill: U32, rot: U32, idx: U32) -> Action:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      anchor = skill_point(skill, rot, idx);
      hit = _attack_hits(skill, rot, anchor, actor, target);
      match hit:
        case 0:
          _find_attack_anchor(actor, target, skill, rot, idx + 1)
        case _:
          _attack_action(skill, anchor, rot)
    case _:
      _wait_action()

def _resolve_player_action_state(state: GameState, action: Action) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      stopped = winner | _hp_empty(player_hp);
      match stopped:
        case 0:
          _resolve_player_action(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner, action)
        case _:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)

def _resolve_bot_action_state(state: GameState, bot_idx: U32, action: Action) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      stopped = winner | _bot_dead_at(bots, bot_idx);
      match stopped:
        case 0:
          _resolve_bot_action(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner, bot_idx, action)
        case _:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)

def _resolve_player_action(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, action: Action,
) -> GameState:
  match action:
    case wait{}:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
    case move{dir}:
      match _status_move_locked(_runtime_player_ice(_mode_runtime(mode))):
        case 0:
          _state(round, level, bot_total, player_hp, _step_blocked_player(player, dir, bots), bots, queue, queue_len, queue_locked, mode, winner)
        case _:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
    case attack{skill, anchor, rot}:
      _resolve_player_attack_with_runtime(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, _mode_runtime(mode), winner, skill, anchor, rot)

def _resolve_player_attack_with_runtime(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action), queue_len: U32, queue_locked: U32,
  runtime: RuntimeData, winner: U32, skill: U32, anchor: Pos, rot: U32,
) -> GameState:
  hook_tiles = _effect_tiles_for(skill, rot, anchor, player, 2, 0);
  damage_tiles = _effect_tiles_for(skill, rot, anchor, player, 1, 0);
  ice_tiles = _effect_tiles_for(skill, rot, anchor, player, 4, 0);
  fire_tiles = _effect_tiles_for(skill, rot, anchor, player, 8, 0);
  bots_after_hook = _hook_player_bots(player, bots, hook_tiles, _skill_hook_pull(skill));
  bots_after_damage = _damage_bots_on_tiles(bots_after_hook, damage_tiles, Fight.skill_damage(skill));
  terrain_ice = _terrain_apply_tiles(_runtime_terrain(runtime), 0, 1, 10, ice_tiles);
  terrain_fire = _terrain_apply_tiles(terrain_ice, 0, 2, 5, fire_tiles);
  next_runtime = _runtime_with_terrain(runtime, terrain_fire);
  next_winner = _compute_winner(player_hp, bots_after_damage);
  _state(round, level, bot_total, player_hp, player, bots_after_damage, queue, queue_len, queue_locked, _plan_mode(next_runtime), next_winner)

def _resolve_bot_action(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, bot_idx: U32, action: Action,
) -> GameState:
  enemy = _bot_pos_at(bots, bot_idx);
  kind = _action_kind(action);
  _resolve_bot_action_kind(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner, bot_idx, action, enemy, kind)

def _resolve_bot_action_kind(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32,
  bot_idx: U32, action: Action, enemy: Pos, kind: U32,
) -> GameState:
  match kind:
    case 0:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
    case 1:
      match _bot_move_locked(_bot_at(bots, bot_idx)):
        case 0:
          dir = _action_dir(action);
          next_bots = _move_bot_in_list(bots, bot_idx, _step_blocked_bot(enemy, dir, player, bots, bot_idx));
          _state(round, level, bot_total, player_hp, player, next_bots, queue, queue_len, queue_locked, mode, winner)
        case _:
          _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)
    case _:
      _resolve_bot_attack(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, _mode_runtime(mode), winner, bot_idx, enemy, action)

def _resolve_bot_attack(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, runtime: RuntimeData, winner: U32,
  bot_idx: U32, enemy: Pos, action: Action,
) -> GameState:
  skill = _action_skill(action);
  anchor = _action_anchor(action);
  rot = _action_rot(action);
  hook_tiles = _effect_tiles_for(skill, rot, anchor, enemy, 2, 0);
  damage_tiles = _effect_tiles_for(skill, rot, anchor, enemy, 1, 0);
  ice_tiles = _effect_tiles_for(skill, rot, anchor, enemy, 4, 0);
  fire_tiles = _effect_tiles_for(skill, rot, anchor, enemy, 8, 0);
  next_player = _hook_bot_player(enemy, player, bots, bot_idx, hook_tiles, _skill_hook_pull(skill));
  hit = _pos_list_has(damage_tiles, next_player);
  next_player_hp = _damage_hp_by(player_hp, _attack_damage_amount(skill, hit));
  terrain_ice = _terrain_apply_tiles(_runtime_terrain(runtime), 1, 1, 10, ice_tiles);
  terrain_fire = _terrain_apply_tiles(terrain_ice, 1, 2, 5, fire_tiles);
  next_runtime = _runtime_with_terrain(runtime, terrain_fire);
  next_winner = _compute_winner(next_player_hp, bots);
  _state(round, level, bot_total, next_player_hp, next_player, bots, queue, queue_len, queue_locked, _plan_mode(next_runtime), next_winner)

def _attack_damage_amount(skill: U32, hit: U32) -> U32:
  match hit:
    case 0:
      0
    case _:
      Fight.skill_damage(skill)

def _simulate_player_action(state: GameState, action: Action) -> ActionSim:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      current_state = _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner);
      kind = _action_kind(action);
      _simulate_player_action_kind(current_state, player_hp, player, bots, action, kind)

def _simulate_player_action_kind(
  current_state: GameState, player_hp: U32, player: Pos, bots: List(Bot), action: Action, kind: U32,
) -> ActionSim:
  match kind:
    case 0:
      _action_sim(player, player, _first_live_bot_pos(bots), _pos_nil(), current_state, 0, 0, 0)
    case 1:
      dir = _action_dir(action);
      next_state = _resolve_player_action_state(current_state, move{dir});
      _action_sim(player, _state_player(next_state), _first_live_bot_pos(bots), _pos_nil(), next_state, 0, 0, 0)
    case _:
      _simulate_player_attack(current_state, player_hp, player, bots, action)

def _simulate_player_attack(
  current_state: GameState, player_hp: U32, player: Pos, bots: List(Bot), action: Action,
) -> ActionSim:
  skill = _action_skill(action);
  anchor = _action_anchor(action);
  rot = _action_rot(action);
  attack_tiles = _preview_hits_for(skill, rot, anchor, player, 0);
  hit = _bots_hit_any_tiles(bots, attack_tiles);
  next_state = _resolve_player_action_state(current_state, attack{skill, anchor, rot});
  bot_died = _bots_any_died_between(bots, _state_bots(next_state));
  _action_sim(player, player, _first_live_bot_pos(bots), attack_tiles, next_state, hit, 0, bot_died)

def _simulate_bot_action(state: GameState, bot_idx: U32, action: Action) -> ActionSim:
  match state:
    case game_state{meta, arena, plan_value}:
      round = _meta_round(meta);
      level = _meta_level(meta);
      bot_total = _meta_bot_total(meta);
      player_hp = _arena_player_hp(arena);
      player = _arena_player(arena);
      bots = _arena_bots(arena);
      queue = _plan_queue(plan_value);
      queue_len = _plan_queue_len(plan_value);
      queue_locked = _plan_queue_locked(plan_value);
      mode = _plan_mode_value(plan_value);
      winner = _arena_winner(arena);
      enemy = _bot_pos_at(bots, bot_idx);
      current_state = _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner);
      kind = _action_kind(action);
      _simulate_bot_action_kind(current_state, player_hp, player, bots, bot_idx, action, enemy, kind)

def _simulate_bot_action_kind(
  current_state: GameState, player_hp: U32, player: Pos, bots: List(Bot),
  bot_idx: U32, action: Action, enemy: Pos, kind: U32,
) -> ActionSim:
  match kind:
    case 0:
      _action_sim(enemy, enemy, player, _pos_nil(), current_state, 0, 0, 0)
    case 1:
      dir = _action_dir(action);
      next_state = _resolve_bot_action_state(current_state, bot_idx, move{dir});
      _action_sim(enemy, _bot_pos_at(_state_bots(next_state), bot_idx), player, _pos_nil(), next_state, 0, 0, 0)
    case _:
      _simulate_bot_attack(current_state, player_hp, player, bot_idx, action, enemy)

def _simulate_bot_attack(
  current_state: GameState, player_hp: U32, player: Pos, bot_idx: U32, action: Action, enemy: Pos,
) -> ActionSim:
  skill = _action_skill(action);
  anchor = _action_anchor(action);
  rot = _action_rot(action);
  attack_tiles = _preview_hits_for(skill, rot, anchor, enemy, 0);
  hit = _attack_hits(skill, rot, anchor, enemy, player);
  next_state = _resolve_bot_action_state(current_state, bot_idx, attack{skill, anchor, rot});
  player_died = _died_between(_state_player_hp(current_state), _state_player_hp(next_state));
  _action_sim(enemy, enemy, player, attack_tiles, next_state, hit, player_died, 0)

def _action_sim(
  from: Pos, to: Pos, target_pos: Pos, attack_tiles: List(Pos),
  next_state: GameState, hit: U32, player_died: U32, enemy_died: U32,
) -> ActionSim:
  action_sim{from, to, target_pos, attack_tiles, next_state, hit, player_died, enemy_died}

def _action_sim_next_state(sim: ActionSim) -> GameState:
  match sim:
    case action_sim{_, _, _, _, next_state, _, _, _}:
      next_state

def _action_sim_from(sim: ActionSim) -> Pos:
  match sim:
    case action_sim{from, _, _, _, _, _, _, _}:
      from

def _action_sim_to(sim: ActionSim) -> Pos:
  match sim:
    case action_sim{_, to, _, _, _, _, _, _}:
      to

def _action_sim_attack_tiles(sim: ActionSim) -> List(Pos):
  match sim:
    case action_sim{_, _, _, attack_tiles, _, _, _, _}:
      attack_tiles

def _reset_round_planning_state(state: GameState) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      _reset_round_planning_mode(
        _meta_round(meta),
        _meta_level(meta),
        _meta_bot_total(meta),
        _arena_player_hp(arena),
        _arena_player(arena),
        _arena_bots(arena),
        _plan_mode_value(plan_value),
        _arena_winner(arena)
      )

def _reset_round_planning_mode(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), mode: Mode, winner: U32,
) -> GameState:
  _reset_round_planning_w(round, level, bot_total, player_hp, player, bots, _mode_runtime(mode), winner)

def _reset_round_planning_w(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), runtime: RuntimeData, winner: U32,
) -> GameState:
  current_terrain = _runtime_terrain(runtime);
  next_runtime_status = _apply_player_fire_and_ice(player_hp, player, runtime);
  next_player_hp = _damage_hp_by(player_hp, _player_fire_damage(runtime, player));
  next_bots = _apply_bots_status_round(bots, current_terrain);
  next_runtime = _runtime_with_terrain(next_runtime_status, _terrain_tick(current_terrain));
  computed_winner = _compute_winner(next_player_hp, next_bots);
  next_winner = _winner_after_round_reset(winner, computed_winner);
  next_round = _round_after_reset(round, winner);
  _state(next_round, level, bot_total, next_player_hp, player, next_bots, _queue_waits(), 0, 0, _plan_mode(next_runtime), next_winner)

def _winner_after_round_reset(winner: U32, computed: U32) -> U32:
  match winner:
    case 0:
      computed
    case k:
      k

def _round_after_reset(round: U32, winner: U32) -> U32:
  match winner:
    case 0:
      round + 1
    case _:
      round

def _hp_empty(hp: U32) -> U32:
  match hp:
    case 0:
      1
    case _:
      0

def _died_between(before: U32, after: U32) -> U32:
  (1 ^ _hp_empty(before)) & _hp_empty(after)

def _compute_winner(player_hp: U32, bots: List(Bot)) -> U32:
  _compute_winner_state(_hp_empty(player_hp), _bots_any_alive(bots))

def _compute_winner_state(player_dead: U32, any_alive: U32) -> U32:
  match player_dead:
    case 0:
      _compute_winner_alive(any_alive)
    case _:
      _compute_winner_dead(any_alive)

def _compute_winner_alive(any_alive: U32) -> U32:
  match any_alive:
    case 0:
      1
    case _:
      0

def _compute_winner_dead(any_alive: U32) -> U32:
  match any_alive:
    case 0:
      3
    case _:
      2

def _round_skill(round: U32, loadout_value: Loadout) -> U32:
  _loadout_cycle_skill(loadout_value, round)

def _move_or_wait(dir: U32) -> Action:
  match dir:
    case 4:
      _wait_action()
    case d:
      _move_action(d)

def _step_or_stay(pos: Pos, dir: U32) -> Pos:
  match dir:
    case 4:
      pos
    case d:
      _step_free(pos, d)

def _chase_dir(enemy: Pos, player: Pos) -> U32:
  match enemy:
    case pos{ex, ey}:
      match player:
        case pos{px, py}:
          horiz = _chase_horizontal(ex, px);
          vert = _chase_vertical(ey, py);
          horiz_none = horiz === 4;
          vert_none = vert === 4;
          match horiz_none:
            case 0:
              match vert_none:
                case 0:
                  use_horiz = _u32_gte(_abs_diff(px, ex), _abs_diff(py, ey));
                  match use_horiz:
                    case 0:
                      vert
                    case _:
                      horiz
                case _:
                  horiz
            case _:
              match vert_none:
                case 0:
                  vert
                case _:
                  4

def _chase_horizontal(from_x: U32, to_x: U32) -> U32:
  lt = _u32_lt(from_x, to_x);
  gt = _u32_lt(to_x, from_x);
  match lt:
    case 0:
      match gt:
        case 0:
          4
        case _:
          2
    case _:
      3

def _chase_vertical(from_y: U32, to_y: U32) -> U32:
  lt = _u32_lt(from_y, to_y);
  gt = _u32_lt(to_y, from_y);
  match lt:
    case 0:
      match gt:
        case 0:
          4
        case _:
          0
    case _:
      1
def _queue_has_attack(queue: List(Action)) -> U32:
  match queue:
    case []:
      0
    case hd<>tl:
      hit = _action_is_attack(hd);
      match hit:
        case 0:
          _queue_has_attack(tl)
        case _:
          1

def _action_at(queue: List(Action), idx: U32) -> Action:
  match queue:
    case []:
      wait{}
    case hd<>tl:
      match idx:
        case 0:
          hd
        case k:
          _action_at(tl, k - 1)

def _action_set(queue: List(Action), idx: U32, val: Action) -> List(Action):
  match queue:
    case []:
      []
    case hd<>tl:
      match idx:
        case 0:
          val<>tl
        case k:
          hd<>_action_set(tl, k - 1, val)

def _state_queue(state: GameState) -> List(Action):
  match state:
    case game_state{_, _, plan_value}:
      _plan_queue(plan_value)

def _state_player(state: GameState) -> Pos:
  match state:
    case game_state{_, arena, _}:
      _arena_player(arena)

def _state_bots(state: GameState) -> List(Bot):
  match state:
    case game_state{_, arena, _}:
      _arena_bots(arena)

def _state_bot_total(state: GameState) -> U32:
  match state:
    case game_state{meta, _, _}:
      _meta_bot_total(meta)

def _state_player_hp(state: GameState) -> U32:
  match state:
    case game_state{_, arena, _}:
      _arena_player_hp(arena)

def _state_runtime(state: GameState) -> RuntimeData:
  _mode_runtime(_state_mode_value(state))

def _trail_step_of_pos(p: Pos, step: U32) -> TrailStep:
  match p:
    case pos{x, y}:
      trail_step{x, y, step}

def _action_kind(action: Action) -> U32:
  match action:
    case wait{}:
      0
    case move{_}:
      1
    case attack{_, _, _}:
      2

def _action_dir(action: Action) -> U32:
  match action:
    case move{dir}:
      dir
    case _:
      0

def _action_skill(action: Action) -> U32:
  match action:
    case attack{skill, _, _}:
      skill
    case _:
      0

def _action_anchor(action: Action) -> Pos:
  match action:
    case attack{_, anchor, _}:
      anchor
    case _:
      pos{0, 0}

def _action_rot(action: Action) -> U32:
  match action:
    case attack{_, _, rot}:
      rot
    case _:
      0

def _action_is_attack(action: Action) -> U32:
  kind = _action_kind(action);
  match kind:
    case 2:
      1
    case _:
      0

def _mode_is_plan(mode: Mode) -> U32:
  match mode:
    case plan{_}:
      1
    case _:
      0

def _mode_is_target(mode: Mode) -> U32:
  match mode:
    case target{_, _, _, _}:
      1
    case _:
      0

def _mode_is_playback(mode: Mode) -> U32:
  match mode:
    case playback{_, _, _, _, _, _, _, _}:
      1
    case _:
      0

def _mode_runtime(mode: Mode) -> RuntimeData:
  match mode:
    case plan{runtime}:
      runtime
    case target{_, _, _, runtime}:
      runtime
    case playback{_, _, _, _, _, _, _, runtime}:
      runtime

def _mode_skill(mode: Mode) -> U32:
  match mode:
    case target{skill, _, _, _}:
      skill
    case _:
      0

def _mode_rot(mode: Mode) -> U32:
  match mode:
    case target{_, rot, _, _}:
      rot
    case _:
      0

def _mode_origin(mode: Mode) -> Pos:
  match mode:
    case target{_, _, origin, _}:
      origin
    case _:
      pos{0, 0}

def _mode_playback_idx(mode: Mode) -> U32:
  match mode:
    case playback{idx, _, _, _, _, _, _, _}:
      idx
    case _:
      0

def _mode_playback_phase(mode: Mode) -> U32:
  match mode:
    case playback{_, phase, _, _, _, _, _, _}:
      phase
    case _:
      0

def _mode_playback_actor(mode: Mode) -> U32:
  match mode:
    case playback{_, _, actor, _, _, _, _, _}:
      actor
    case _:
      0

def _mode_playback_actor_idx(mode: Mode) -> U32:
  match mode:
    case playback{_, _, _, actor_idx, _, _, _, _}:
      actor_idx
    case _:
      0

def _mode_playback_action(mode: Mode) -> Action:
  match mode:
    case playback{_, _, _, _, action, _, _, _}:
      action
    case _:
      _wait_action()

def _mode_playback_sim(mode: Mode) -> ActionSim:
  match mode:
    case playback{_, _, _, _, _, sim, _, _}:
      sim
    case _:
      _action_sim(pos{0, 0}, pos{0, 0}, pos{0, 0}, _pos_nil(), state_init(), 0, 0, 0)

def _mode_playback_plans(mode: Mode) -> List(List(Action)):
  match mode:
    case playback{_, _, _, _, _, _, bot_plans, _}:
      bot_plans
    case _:
      []

def _runtime_terrain(runtime: RuntimeData) -> List(Terrain):
  match runtime:
    case runtime_data{terrain, _, _}:
      terrain

def _runtime_player_fire(runtime: RuntimeData) -> U32:
  match runtime:
    case runtime_data{_, player_fire, _}:
      player_fire

def _runtime_player_ice(runtime: RuntimeData) -> U32:
  match runtime:
    case runtime_data{_, _, player_ice}:
      player_ice

def _runtime_with_terrain(runtime: RuntimeData, terrain: List(Terrain)) -> RuntimeData:
  runtime_data{terrain, _runtime_player_fire(runtime), _runtime_player_ice(runtime)}

def _runtime_with_player_fire(runtime: RuntimeData, player_fire: U32) -> RuntimeData:
  runtime_data{_runtime_terrain(runtime), player_fire, _runtime_player_ice(runtime)}

def _runtime_with_player_ice(runtime: RuntimeData, player_ice: U32) -> RuntimeData:
  runtime_data{_runtime_terrain(runtime), _runtime_player_fire(runtime), player_ice}

def _terrain_pos(item: Terrain) -> Pos:
  match item:
    case terrain{pos_value, _, _, _}:
      pos_value

def _terrain_owner(item: Terrain) -> U32:
  match item:
    case terrain{_, owner, _, _}:
      owner

def _terrain_effect(item: Terrain) -> U32:
  match item:
    case terrain{_, _, effect, _}:
      effect

def _terrain_turns(item: Terrain) -> U32:
  match item:
    case terrain{_, _, _, turns}:
      turns

def _terrain_make(pos_value: Pos, owner: U32, effect: U32, turns: U32) -> Terrain:
  terrain{pos_value, owner, effect, turns}

def _terrain_replace(items: List(Terrain), pos_value: Pos, owner: U32, effect: U32, turns: U32) -> List(Terrain):
  match items:
    case []:
      _terrain_cons(_terrain_make(pos_value, owner, effect, turns), _terrain_nil())
    case head<>tail:
      match _pos_eq(_terrain_pos(head), pos_value):
        case 0:
          _terrain_cons(head, _terrain_replace(tail, pos_value, owner, effect, turns))
        case _:
          _terrain_cons(_terrain_make(pos_value, owner, effect, turns), tail)

def _terrain_apply_tiles(items: List(Terrain), owner: U32, effect: U32, turns: U32, tiles: List(Pos)) -> List(Terrain):
  match tiles:
    case []:
      items
    case head<>tail:
      _terrain_apply_tiles(_terrain_replace(items, head, owner, effect, turns), owner, effect, turns, tail)

def _terrain_tick(items: List(Terrain)) -> List(Terrain):
  match items:
    case []:
      []
    case head<>tail:
      turns = _terrain_turns(head);
      match turns:
        case 0:
          _terrain_tick(tail)
        case 1:
          _terrain_tick(tail)
        case value:
          _terrain_make(_terrain_pos(head), _terrain_owner(head), _terrain_effect(head), value - 1)<>_terrain_tick(tail)

def _terrain_effect_at(items: List(Terrain), cell_pos: Pos) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      same = _pos_eq(_terrain_pos(head), cell_pos);
      match same:
        case 0:
          _terrain_effect_at(tail, cell_pos)
        case _:
          _terrain_effect(head)

def _terrain_has_ice_at(items: List(Terrain), cell_pos: Pos) -> U32:
  _terrain_effect_at(items, cell_pos) === 1

def _terrain_has_fire_at(items: List(Terrain), cell_pos: Pos) -> U32:
  _terrain_effect_at(items, cell_pos) === 2

def _status_move_locked(ice: U32) -> U32:
  _u32_lt(0, ice) & ((ice % 2) === 1)

def _fire_refresh_ticks(current: U32, on_fire: U32) -> U32:
  match on_fire:
    case 0:
      current
    case _:
      3

def _fire_damage_for_ticks(ticks: U32) -> U32:
  match ticks:
    case 0:
      0
    case _:
      5

def _fire_store_after_tick(ticks: U32) -> U32:
  match ticks:
    case 0:
      0
    case value:
      value - 1

def _ice_after_round(current: U32, on_ice: U32) -> U32:
  match on_ice:
    case 0:
      0
    case _:
      current + 1

def _damage_hp_by(hp: U32, amount: U32) -> U32:
  _sub_floor(hp, amount)

def _pos_eq(a: Pos, b: Pos) -> U32:
  match a:
    case pos{ax, ay}:
      match b:
        case pos{bx, by}:
          (ax === bx) & (ay === by)

def _pos_add(a: Pos, b: Pos) -> Pos:
  match a:
    case pos{ax, ay}:
      match b:
        case pos{bx, by}:
          pos{ax + bx, ay + by}

def _pos_x(value: Pos) -> U32:
  match value:
    case pos{x, _}:
      x

def _pos_y(value: Pos) -> U32:
  match value:
    case pos{_, y}:
      y

def _pos_inside(p: Pos) -> U32:
  match p:
    case pos{x, y}:
      _in_bounds(x, y)

def _in_bounds(x: U32, y: U32) -> U32:
  ((x / 18) === 0) & ((y / 9) === 0)

def _step_up(pos: Pos) -> Pos:
  match pos:
    case pos{x, 0}:
      pos{x, 0}
    case pos{x, y}:
      pos{x, y - 1}

def _step_down(pos: Pos) -> Pos:
  match pos:
    case pos{x, 8}:
      pos{x, 8}
    case pos{x, y}:
      pos{x, y + 1}

def _step_left(pos: Pos) -> Pos:
  match pos:
    case pos{0, y}:
      pos{0, y}
    case pos{x, y}:
      pos{x - 1, y}

def _step_right(pos: Pos) -> Pos:
  match pos:
    case pos{17, y}:
      pos{17, y}
    case pos{x, y}:
      pos{x + 1, y}

def _step_free(pos: Pos, dir: U32) -> Pos:
  match dir:
    case 0:
      _step_up(pos)
    case 1:
      _step_down(pos)
    case 2:
      _step_left(pos)
    case 3:
      _step_right(pos)
    case _:
      pos

def _step_blocked_player(pos: Pos, dir: U32, bots: List(Bot)) -> Pos:
  next = _step_free(pos, dir);
  blocked = _bots_live_has_pos(bots, next);
  match blocked:
    case 0:
      next
    case _:
      pos

def _step_blocked_bot(pos: Pos, dir: U32, player: Pos, bots: List(Bot), bot_idx: U32) -> Pos:
  next = _step_free(pos, dir);
  blocked = _pos_eq(next, player) | _bots_other_live_has_pos(bots, bot_idx, next);
  match blocked:
    case 0:
      next
    case _:
      pos

def _step_or_stay_bot(pos: Pos, dir: U32, player: Pos, bots: List(Bot), bot_idx: U32) -> Pos:
  match dir:
    case 4:
      pos
    case d:
      _step_blocked_bot(pos, d, player, bots, bot_idx)

def _move_bot_in_list(bots: List(Bot), bot_idx: U32, next_pos: Pos) -> List(Bot):
  current = _bot_at(bots, bot_idx);
  _bot_set(bots, bot_idx, _bot_with_pos(current, next_pos))

def _sub_floor(a: U32, b: U32) -> U32:
  match a b:
    case x 0:
      x
    case 0 y:
      0
    case x y:
      _sub_floor(x - 1, y - 1)

def _u32_lt(a: U32, b: U32) -> U32:
  match a b:
    case 0 0:
      0
    case 0 y:
      1
    case x 0:
      0
    case x y:
      _u32_lt(x - 1, y - 1)

def _u32_gte(a: U32, b: U32) -> U32:
  1 ^ _u32_lt(a, b)

def _min_u32(a: U32, b: U32) -> U32:
  match _u32_lt(a, b):
    case 0:
      b
    case _:
      a

def _max_u32(a: U32, b: U32) -> U32:
  match _u32_lt(a, b):
    case 0:
      a
    case _:
      b

def _abs_diff(a: U32, b: U32) -> U32:
  _sub_floor(a, b) + _sub_floor(b, a)

def _app_screen(app: AppState) -> Screen:
  match app:
    case app_state{screen, _, _}:
      screen

def _app_lobby(app: AppState) -> LobbyState:
  match app:
    case app_state{_, lobby, _}:
      lobby

def _app_game(app: AppState) -> GameState:
  match app:
    case app_state{_, _, game}:
      game

def _app_with_screen(app: AppState, screen: Screen) -> AppState:
  match app:
    case app_state{_, lobby, game}:
      app_state{screen, lobby, game}

def _app_with_lobby(app: AppState, lobby: LobbyState) -> AppState:
  match app:
    case app_state{screen, _, game}:
      app_state{screen, lobby, game}

def _app_with_game(app: AppState, game: GameState) -> AppState:
  match app:
    case app_state{screen, lobby, _}:
      app_state{screen, lobby, game}

def _screen_is_home(screen: Screen) -> U32:
  match screen:
    case home{}:
      1
    case _:
      0

def _screen_is_play_lobby(screen: Screen) -> U32:
  match screen:
    case play_lobby{}:
      1
    case _:
      0

def _screen_is_story(screen: Screen) -> U32:
  match screen:
    case story{}:
      1
    case _:
      0

def _screen_is_match(screen: Screen) -> U32:
  match screen:
    case battle{}:
      1
    case _:
      0

# App logic

def ready_round_state(state: GameState, bot_loadout: Loadout) -> GameState:
  match state:
    case game_state{meta, arena, plan_value}:
      _ready_round_state_w(
        _meta_round(meta),
        _meta_level(meta),
        _meta_bot_total(meta),
        _arena_player_hp(arena),
        _arena_player(arena),
        _arena_bots(arena),
        _plan_queue(plan_value),
        _plan_queue_len(plan_value),
        _plan_queue_locked(plan_value),
        _plan_mode_value(plan_value),
        _arena_winner(arena),
        bot_loadout
      )

def _ready_round_state_w(
  round: U32, level: U32, bot_total: U32, player_hp: U32,
  player: Pos, bots: List(Bot), queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, bot_loadout: Loadout,
) -> GameState:
  match winner | _mode_is_target(mode) | _mode_is_playback(mode):
    case 0:
      current = _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner);
      _playback_start_state(current, 0, _build_all_bot_plans(round, player_hp, player, bots, winner, 0, bot_loadout))
    case _:
      _state(round, level, bot_total, player_hp, player, bots, queue, queue_len, queue_locked, mode, winner)

def _confirm_and_ready_state(state: GameState, bot_loadout: Loadout) -> GameState:
  match _state_playback_active(state):
    case 0:
      _confirm_and_ready_target(state, _state_target_active(state), bot_loadout)
    case _:
      state

def _confirm_and_ready_target(state: GameState, active: U32, bot_loadout: Loadout) -> GameState:
  match active:
    case 0:
      ready_round_state(state, bot_loadout)
    case _:
      _confirm_and_ready_valid(state, target_valid(state), bot_loadout)

def _confirm_and_ready_valid(state: GameState, valid: U32, bot_loadout: Loadout) -> GameState:
  match valid:
    case 0:
      state
    case _:
      ready_round_state(confirm_target_state(state), bot_loadout)

def playback_tick_state(state: GameState) -> GameState:
  _playback_tick_mode(state, _state_mode_value(state))

def _playback_tick_mode(state: GameState, mode: Mode) -> GameState:
  match mode:
    case playback{idx, phase, actor, actor_idx, action, sim, bot_plans, _}:
      _playback_tick_idx(state, idx, phase, actor, actor_idx, action, sim, bot_plans)
    case _:
      state

def _playback_tick_idx(state: GameState, idx: U32, phase: U32, actor: U32, actor_idx: U32, action: Action, sim: ActionSim, bot_plans: List(List(Action))) -> GameState:
  match phase:
    case 0:
      _playback_apply_state(sim, idx, actor, actor_idx, action, bot_plans)
    case _:
      _playback_advance_state(_action_sim_next_state(sim), idx, bot_plans)

def _playback_start_state(state: GameState, idx: U32, bot_plans: List(List(Action))) -> GameState:
  match _playback_remaining_all_waits(state, idx, bot_plans):
    case 0:
      bot_total = _state_bot_total(state);
      actor = _playback_actor_of_idx(idx, bot_total);
      actor_idx = _playback_actor_idx_of_idx(idx, bot_total);
      action = _playback_action(_state_queue(state), bot_plans, idx, bot_total);
      sim = simulate_actor_action(state, actor, actor_idx, action);
      _set_mode_state(state, _playback_mode(idx, 0, actor, actor_idx, action, sim, bot_plans, _state_runtime(state)))
    case _:
      _reset_round_planning_state(state)

def _playback_remaining_all_waits(state: GameState, idx: U32, bot_plans: List(List(Action))) -> U32:
  bot_total = _state_bot_total(state);
  total_steps = _playback_total_steps(bot_total);
  _playback_remaining_all_waits_w(state, idx, bot_plans, bot_total, total_steps)

def _playback_remaining_all_waits_w(state: GameState, idx: U32, bot_plans: List(List(Action)), bot_total: U32, total_steps: U32) -> U32:
  match idx < total_steps:
    case 0:
      1
    case _:
      action = _playback_action(_state_queue(state), bot_plans, idx, bot_total);
      match _action_kind(action):
        case 0:
          _playback_remaining_all_waits_w(state, idx + 1, bot_plans, bot_total, total_steps)
        case _:
          0

def _playback_apply_state(sim: ActionSim, idx: U32, actor: U32, actor_idx: U32, action: Action, bot_plans: List(List(Action))) -> GameState:
  next_state = _action_sim_next_state(sim);
  _set_mode_state(next_state, _playback_mode(idx, 1, actor, actor_idx, action, sim, bot_plans, _state_runtime(next_state)))

def _playback_advance_state(state: GameState, idx: U32, bot_plans: List(List(Action))) -> GameState:
  match _state_winner(state):
    case 0:
      _playback_advance_live(state, idx, bot_plans)
    case _:
      _reset_round_planning_state(state)

def _playback_advance_live(state: GameState, idx: U32, bot_plans: List(List(Action))) -> GameState:
  last_idx = _playback_total_steps(_state_bot_total(state)) - 1;
  match idx === last_idx:
    case 0:
      _playback_start_state(state, idx + 1, bot_plans)
    case _:
      _reset_round_planning_state(state)

def _move_input_state(state: GameState, dir: U32) -> GameState:
  match _state_playback_active(state):
    case 0:
      _move_input_target(state, dir, _state_target_active(state))
    case _:
      state

def _move_input_target(state: GameState, dir: U32, active: U32) -> GameState:
  match active:
    case 0:
      queue_move_state(state, dir)
    case _:
      move_target_state(state, dir)

def _rotate_input_state(state: GameState, clockwise: U32) -> GameState:
  match _state_playback_active(state):
    case 0:
      _rotate_input_target(state, clockwise, _state_target_active(state))
    case _:
      state

def _rotate_input_target(state: GameState, clockwise: U32, active: U32) -> GameState:
  match active:
    case 0:
      state
    case _:
      rotate_target_state(state, clockwise)

def _escape_input_state(state: GameState) -> GameState:
  match _state_playback_active(state):
    case 0:
      _escape_input_target(state, _state_target_active(state))
    case _:
      state

def _escape_input_target(state: GameState, active: U32) -> GameState:
  match active:
    case 0:
      pop_last_planned_action_state(state)
    case _:
      cancel_target_state(state)

def _skill_input_state(state: GameState, skill: U32) -> GameState:
  match _state_playback_active(state):
    case 0:
      _skill_input_value(state, skill)
    case _:
      state

def _skill_input_value(state: GameState, skill: U32) -> GameState:
  match skill:
    case 0:
      state
    case current_skill:
      start_target_state(state, current_skill)

def key_event(key: U32) -> FightEvent:
  match key:
    case 37:
      evt_move_left{}
    case 65:
      evt_move_left{}
    case 38:
      evt_move_up{}
    case 87:
      evt_move_up{}
    case 39:
      evt_move_right{}
    case 68:
      evt_move_right{}
    case 40:
      evt_move_down{}
    case 83:
      evt_move_down{}
    case 49:
      evt_skill_1{}
    case 50:
      evt_skill_2{}
    case 51:
      evt_skill_3{}
    case 81:
      evt_rotate_left{}
    case 69:
      evt_rotate_right{}
    case 32:
      evt_confirm{}
    case 13:
      evt_ready{}
    case 27:
      evt_escape{}
    case 67:
      evt_clear{}
    case 82:
      evt_reset{}
    case _:
      evt_ignore{}

def _on_match_event(evt: FightEvent, state: GameState, lobby: LobbyState) -> GameState:
  match evt:
    case evt_move_up{}:
      _move_input_state(state, 0)
    case evt_move_down{}:
      _move_input_state(state, 1)
    case evt_move_left{}:
      _move_input_state(state, 2)
    case evt_move_right{}:
      _move_input_state(state, 3)
    case evt_skill_1{}:
      _skill_input_state(state, _loadout_slot(_lobby_player_loadout(lobby), 0))
    case evt_skill_2{}:
      _skill_input_state(state, _loadout_slot(_lobby_player_loadout(lobby), 1))
    case evt_skill_3{}:
      _skill_input_state(state, _loadout_slot(_lobby_player_loadout(lobby), 2))
    case evt_rotate_left{}:
      _rotate_input_state(state, 0)
    case evt_rotate_right{}:
      _rotate_input_state(state, 1)
    case evt_confirm{}:
      _confirm_and_ready_state(state, _lobby_bot_loadout(lobby))
    case evt_ready{}:
      ready_round_state(state, _lobby_bot_loadout(lobby))
    case evt_escape{}:
      _escape_input_state(state)
    case evt_clear{}:
      clear_round_plan_state(state)
    case evt_reset{}:
      _game_from_lobby(lobby)
    case evt_tick{}:
      playback_tick_state(state)
    case evt_ignore{}:
      state
    case _:
      state

def _event_kind(evt: FightEvent) -> U32:
  match evt:
    case evt_go_home{}:
      1
    case evt_open_play{}:
      2
    case evt_open_story{}:
      3
    case evt_lobby_play{}:
      4
    case evt_lobby_player_hp_dec{}:
      5
    case evt_lobby_player_hp_inc{}:
      6
    case evt_lobby_bot_hp_dec{}:
      7
    case evt_lobby_bot_hp_inc{}:
      8
    case evt_lobby_skill{}:
      9
    case evt_lobby_filter{}:
      35
    case _:
      0

def on_event(evt: FightEvent, app: AppState) -> AppState:
  lobby = _app_lobby(app);
  app_state{battle{}, lobby, _on_match_event(evt, _app_game(app), lobby)}

# Rendering helpers

init : AppState =
  game_test_app_init()

def render(app: AppState) -> HTML(FightEvent):
  fight_render(app)

def fight_render(app: AppState) -> HTML(FightEvent):
  <div class="page">
    <style>{text{css()}}</style>
    <div {..._tick_attrs(_app_game(app))}></div>
    {_render_match_screen(app)}
  </div>

def _render_match_screen(app: AppState) -> HTML(FightEvent):
  state = _app_game(app);
  lobby = _app_lobby(app);
  planned = _render_planned_pos(state);
  trail = _render_trail(state);
  preview = _render_preview_tiles(state);
  preview_anchor = _render_preview_anchor_tiles(state);
  hits = _render_preview_hits(state);
  flash_hits = _render_attack_flash_active(state);
  hit_owner = _render_hit_owner(state);
  valid = _render_target_valid(state);
  board = U32.grid(HTML(FightEvent), 18, 9, _board_cell(state, _loadout_hp_bot(lobby), planned, trail, preview, preview_anchor, hits, flash_hits, hit_owner, valid));
  <main class="shell" tabindex="0" style="outline:none" on_key_down={key_event}>
    <section class="board-stage">
      <div class="board-stack">
        <section class="board-wrap board-wrap-large">
          <div class="board">{...board}</div>
          {_winner_modal(state)}
        </section>

        <section class="board-underbar">
          <div class="player-hp-card card">
            <div class="stat-label">Player HP</div>
            <div class="stat-value">{text{_hp_text(_state_player_hp(state), _loadout_hp_player(lobby))}}</div>
          </div>

          <div class="queue-inline">
            {_queue_slot(state, 0)}
            {_queue_slot(state, 1)}
            {_queue_slot(state, 2)}
          </div>

          <div class="skill-strip">
            {_equipped_skill_preview_card(state, _lobby_player_loadout(lobby), 0)}
            {_equipped_skill_preview_card(state, _lobby_player_loadout(lobby), 1)}
            {_equipped_skill_preview_card(state, _lobby_player_loadout(lobby), 2)}
          </div>
        </section>
      </div>
    </section>

    <aside class="sidebar">
      <section class="card sidebar-status">
        <div class="stat-label">Round</div>
        <div class="stat-value sidebar-round">{text{U32.show(_state_round(state))}}</div>
        <div class="stat-label stat-label--spaced">Estado</div>
        <p class="sidebar-phase">{text{_mode_text(state)}}</p>
        <p class="help help--spaced">{text{"Bots vivos: " ++ U32.show(_live_bot_count(_state_bots(state))) ++ "/" ++ U32.show(_state_bot_total(state))}}</p>
        {_winner_sidebar_text(state)}
        {_preview_sidebar_text(state, planned)}
        {_playback_sidebar_text(state)}
      </section>

      <section class="card">
        <div class="stat-label">Acoes</div>
        <div class="controls controls--actions">
          <button {..._button_attrs("button alt", evt_ready{})}>{text{"Ready"}}</button>
          <button {..._button_attrs("button", evt_reset{})}>{text{"Reset partida"}}</button>
          <a class="button button--menu button--menu-secondary nav-link" href="https://ostrowskii.github.io/vibi-fight-singleplayer/play/">{text{"Voltar lobby"}}</a>
        </div>
      </section>

      <section class="card">
        <div class="stat-label">Controles</div>
        <p class="help">{text{_controls_text(state)}}</p>
        {_target_sidebar_text(state)}
        {_playback_help_text(state)}
      </section>
    </aside>
  </main>

def _winner_sidebar_text(state: GameState) -> HTML(FightEvent):
  _winner_sidebar_text_w(_state_winner(state))

def _winner_sidebar_text_w(winner: U32) -> HTML(FightEvent):
  <p class={_winner_sidebar_class(winner)}>{text{_winner_sidebar_text_value(winner)}}</p>

def _winner_sidebar_class(winner: U32) -> String:
  match winner:
    case 0:
      "winner winner--hidden"
    case _:
      "winner"

def _winner_sidebar_text_value(winner: U32) -> String:
  match winner:
    case 0:
      ""
    case result:
      _winner_title(result)

def _preview_sidebar_text(state: GameState, planned: Pos) -> HTML(FightEvent):
  match _state_playback_active(state):
    case 0:
      _preview_sidebar_text_w(_state_queue_len_or_target(state), planned)
    case _:
      <p class="help help--spaced help--hidden">{text{""}}</p>

def _preview_sidebar_text_w(show: U32, planned: Pos) -> HTML(FightEvent):
  <p class={_help_spaced_class(show)}>{text{_preview_sidebar_text_value(show, planned)}}</p>

def _preview_sidebar_text_value(show: U32, planned: Pos) -> String:
  match show:
    case 0:
      ""
    case _:
      "Preview do player: " ++ _pos_text(planned)

def _playback_sidebar_text(state: GameState) -> HTML(FightEvent):
  _playback_sidebar_text_active(_state_playback_active(state), state)

def _playback_sidebar_text_active(active: U32, state: GameState) -> HTML(FightEvent):
  <p class={_help_spaced_class(active)}>{text{_playback_sidebar_text_value(active, state)}}</p>

def _playback_sidebar_text_value(active: U32, state: GameState) -> String:
  match active:
    case 0:
      ""
    case _:
      "Ator atual: " ++ _actor_label(_state_playback_actor(state), _state_playback_actor_idx(state)) ++ ". Acao atual: " ++ _action_label(_state_playback_action(state)) ++ "."

def _controls_text(state: GameState) -> String:
  _controls_text_active(_state_target_active(state))

def _controls_text_active(active: U32) -> String:
  match active:
    case 0:
      "WASD/setas enfileiram ate 2 movimentos. 1/2/3 entram na mira. Space confirma o turno; se a mira estiver valida, ele confirma o ataque e ja da Ready. Esc desfaz a ultima decisao. Enter resolve o round. Reset partida reinicia a luta."
    case _:
      "WASD/setas movem a preview. Q/E giram. Space confirma o ataque e ja resolve o round. Esc cancela a mira. Reset partida reinicia a luta."

def _target_sidebar_text(state: GameState) -> HTML(FightEvent):
  _target_sidebar_text_active(_state_target_active(state), state)

def _target_sidebar_text_active(active: U32, state: GameState) -> HTML(FightEvent):
  <p class={_help_spaced_class(active)}>{text{_target_sidebar_text_value(active, state)}}</p>

def _target_sidebar_text_value(active: U32, state: GameState) -> String:
  match active:
    case 0:
      ""
    case _:
      _skill_name(_state_target_skill(state)) ++ ", rotacao " ++ U32.show(_state_target_rot(state)) ++ ", encaixe " ++ _pos_text(_state_target_origin(state)) ++ ", preview " ++ _target_valid_text(target_valid(state)) ++ "."

def _playback_help_text(state: GameState) -> HTML(FightEvent):
  _playback_help_text_active(_state_playback_active(state), state)

def _playback_help_text_active(active: U32, state: GameState) -> HTML(FightEvent):
  <p class={_help_spaced_class(active)}>{text{_playback_help_text_value(active, state)}}</p>

def _playback_help_text_value(active: U32, state: GameState) -> String:
  match active:
    case 0:
      ""
    case _:
      _playback_info_text(state)

def _help_spaced_class(active: U32) -> String:
  match active:
    case 0:
      "help help--spaced help--hidden"
    case _:
      "help help--spaced"

def _state_queue_len_or_target(state: GameState) -> U32:
  match _state_target_active(state):
    case 0:
      _state_queue_len_nonzero(_state_queue(state))
    case _:
      1

def _state_queue_len_nonzero(queue: List(Action)) -> U32:
  _state_queue_len_nonzero_first(_action_kind(_action_at(queue, 0)), _action_kind(_action_at(queue, 1)), _action_kind(_action_at(queue, 2)))

def _state_queue_len_nonzero_first(k0: U32, k1: U32, k2: U32) -> U32:
  match k0:
    case 0:
      _state_queue_len_nonzero_second(k1, k2)
    case _:
      1

def _state_queue_len_nonzero_second(k1: U32, k2: U32) -> U32:
  match k1:
    case 0:
      _state_queue_len_nonzero_third(k2)
    case _:
      1

def _state_queue_len_nonzero_third(k2: U32) -> U32:
  match k2:
    case 0:
      0
    case _:
      1

def _target_valid_text(valid: U32) -> String:
  match valid:
    case 0:
      "invalida"
    case _:
      "valida"

def _render_planned_pos(state: GameState) -> Pos:
  match _state_playback_active(state):
    case 0:
      planned_player_pos(state)
    case _:
      _state_player(state)

def _render_trail(state: GameState) -> List(TrailStep):
  match _state_playback_active(state):
    case 0:
      movement_trail(state)
    case _:
      _trail_nil()

def _render_preview_tiles(state: GameState) -> List(Pos):
  match _state_playback_active(state):
    case 0:
      preview_tiles(state)
    case _:
      _pos_nil()

def _render_preview_anchor_tiles(state: GameState) -> List(Pos):
  match _state_playback_active(state):
    case 0:
      preview_anchor_tiles(state)
    case _:
      _pos_nil()

def _render_preview_hits(state: GameState) -> List(Pos):
  match _state_playback_active(state):
    case 0:
      preview_hits(state)
    case _:
      _render_playback_attack_hits(state, _state_playback_action(state), _state_playback_phase(state))

def _render_hit_owner(state: GameState) -> U32:
  match _state_playback_active(state):
    case 0:
      _render_preview_hit_owner(state)
    case _:
      _render_playback_hit_owner(state)

def _render_preview_hit_owner(state: GameState) -> U32:
  match _state_target_active(state):
    case 0:
      0
    case _:
      1

def _render_playback_hit_owner(state: GameState) -> U32:
  kind = _action_kind(_state_playback_action(state));
  match kind:
    case 2:
      _render_playback_hit_owner_actor(_state_playback_actor(state))
    case _:
      0

def _render_playback_hit_owner_actor(actor: U32) -> U32:
  match actor:
    case 0:
      1
    case _:
      2

def _render_playback_attack_hits(state: GameState, action: Action, phase: U32) -> List(Pos):
  match phase:
    case 0:
      _render_playback_attack_hits_action(state, action)
    case _:
      _pos_nil()

def _render_playback_attack_hits_action(state: GameState, action: Action) -> List(Pos):
  match action:
    case attack{_, _, _}:
      _action_sim_attack_tiles(_state_playback_sim(state))
    case _:
      _pos_nil()

def _render_attack_flash_active(state: GameState) -> U32:
  match _state_playback_active(state):
    case 0:
      0
    case _:
      _render_attack_flash_phase(_state_playback_action(state), _state_playback_phase(state))

def _render_attack_flash_phase(action: Action, phase: U32) -> U32:
  match phase:
    case 0:
      _render_attack_flash_action(action)
    case _:
      0

def _render_attack_flash_action(action: Action) -> U32:
  match action:
    case attack{_, _, _}:
      1
    case _:
      0

def _render_bump_active(state: GameState) -> U32:
  match _state_playback_active(state):
    case 0:
      0
    case _:
      _render_bump_playback(_state_playback_action(state), _state_playback_phase(state), _state_playback_sim(state))

def _render_bump_playback(action: Action, phase: U32, sim: ActionSim) -> U32:
  match phase:
    case 0:
      _render_bump_action(action, sim)
    case _:
      0

def _render_bump_action(action: Action, sim: ActionSim) -> U32:
  kind = _action_kind(action);
  match kind:
    case 1:
      _pos_eq(_action_sim_from(sim), _action_sim_to(sim))
    case _:
      0

def _render_target_valid(state: GameState) -> U32:
  match _state_playback_active(state):
    case 0:
      target_valid(state)
    case _:
      0

def _tick_attrs(state: GameState) -> List(Attr(FightEvent)):
  match _state_playback_active(state):
    case 0:
      _tick_attrs_idle()
    case _:
      _tick_attrs_playback()

def _tick_attrs_idle() -> List(Attr(FightEvent)):
  [attr{"class", "timer-hook"}]

def _tick_attrs_playback() -> List(Attr(FightEvent)):
  [attr{"class", "timer-hook"}, every_ms{420, evt_tick{}}]

def _equipped_skill_preview_card(state: GameState, loadout_value: Loadout, idx: U32) -> HTML(FightEvent):
  skill = _loadout_slot(loadout_value, idx);
  <button {..._equipped_skill_preview_attrs(state, idx, skill)}>
    <span class="skill-key">{text{U32.show(idx + 1)}}</span>
    <span class="skill-caption">{text{_equipped_skill_caption(skill)}}</span>
    {_skill_visual(skill)}
  </button>

def _equipped_skill_caption(skill: U32) -> String:
  match skill:
    case 0:
      "Vazio"
    case current_skill:
      _skill_name(current_skill)

def _equipped_skill_preview_attrs(state: GameState, idx: U32, skill: U32) -> List(Attr(FightEvent)):
  enabled = (1 ^ _state_playback_active(state)) & _loadout_nonzero(skill);
  _button_attrs_enabled(_equipped_skill_preview_class(state, skill), _equipped_skill_evt(idx), enabled)

def _equipped_skill_evt(idx: U32) -> FightEvent:
  match idx:
    case 0:
      evt_skill_1{}
    case 1:
      evt_skill_2{}
    case _:
      evt_skill_3{}

def _equipped_skill_preview_class(state: GameState, skill: U32) -> String:
  match skill:
    case 0:
      "skill-preview skill-preview--empty"
    case current_skill:
      _equipped_skill_preview_class_active(_state_target_skill_is(state, current_skill))

def _equipped_skill_preview_class_active(active: U32) -> String:
  match active:
    case 0:
      "skill-preview"
    case _:
      "skill-preview skill-preview--active"

def _skill_visual(skill: U32) -> HTML(FightEvent):
  match skill:
    case 0:
      <span class="skill-grid-frame skill-grid-frame--empty"></span>
    case current_skill:
      <span class="skill-grid-frame">
        <img class="skill-grid-art" src={_skill_image_src(current_skill)} alt={_skill_name(current_skill)} />
      </span>

def _skill_image_src(skill: U32) -> String:
  "../assets/skills/" ++ _skill_name(skill) ++ ".svg"

def _queue_slot(state: GameState, idx: U32) -> HTML(FightEvent):
  <div class={_queue_slot_class(state, idx)}>
    <div class="queue-slot__index">{text{"Slot " ++ U32.show(idx + 1)}}</div>
    <div class="queue-slot__value">{text{_action_label(_action_at(_state_queue(state), idx))}}</div>
  </div>

def _queue_slot_class(state: GameState, idx: U32) -> String:
  _queue_slot_class_state(_queue_slot_is_active(state, idx), _queue_slot_is_enemy_turn(state, idx))

def _queue_slot_class_state(active: U32, enemy_turn: U32) -> String:
  match active:
    case 0:
      "queue-slot"
    case _:
      _queue_slot_class_enemy(enemy_turn)

def _queue_slot_class_enemy(enemy_turn: U32) -> String:
  match enemy_turn:
    case 0:
      "queue-slot queue-slot--active"
    case _:
      "queue-slot queue-slot--active queue-slot--enemy-turn"

def _queue_slot_is_active(state: GameState, idx: U32) -> U32:
  match _state_playback_active(state):
    case 0:
      0
    case _:
      _playback_slot_of_idx(_state_playback_idx(state), _state_bot_total(state)) === idx

def _queue_slot_is_enemy_turn(state: GameState, idx: U32) -> U32:
  match _queue_slot_is_active(state, idx):
    case 0:
      0
    case _:
      _state_playback_actor(state)

def _board_cell(
  state: GameState,
  bot_max_hp: U32,
  planned: Pos,
  trail: List(TrailStep),
  preview: List(Pos),
  preview_anchor: List(Pos),
  hits: List(Pos),
  flash_hits: U32,
  hit_owner: U32,
  valid: U32,
  x: U32,
  y: U32,
) -> HTML(FightEvent):
  _board_cell_at(state, bot_max_hp, planned, trail, preview, preview_anchor, hits, flash_hits, hit_owner, valid, pos{x, y})

def _board_cell_at(
  state: GameState,
  bot_max_hp: U32,
  planned: Pos,
  trail: List(TrailStep),
  preview: List(Pos),
  preview_anchor: List(Pos),
  hits: List(Pos),
  flash_hits: U32,
  hit_owner: U32,
  valid: U32,
  cell_pos: Pos,
) -> HTML(FightEvent):
  <div class={_board_cell_class(state, planned, trail, preview, preview_anchor, hits, flash_hits, hit_owner, valid, cell_pos)}>
    {_board_cell_actor(state, bot_max_hp, cell_pos)}
    {_board_cell_ghost(state, planned, cell_pos)}
    {_board_cell_route(trail, cell_pos)}
  </div>

def _board_cell_class(
  state: GameState,
  planned: Pos,
  trail: List(TrailStep),
  preview: List(Pos),
  preview_anchor: List(Pos),
  hits: List(Pos),
  flash_hits: U32,
  hit_owner: U32,
  valid: U32,
  pos: Pos,
) -> String:
  ""
  ++ "cell"
  ++ _board_cell_terrain_class(_runtime_terrain(_state_runtime(state)), pos)
  ++ _board_cell_preview_class(preview, preview_anchor, valid, pos)
  ++ _board_cell_hit_class(hits, flash_hits, hit_owner, pos)
  ++ _board_cell_route_class(trail, pos)

def _board_cell_terrain_class(terrain: List(Terrain), cell_pos: Pos) -> String:
  _board_cell_terrain_class_w(_terrain_effect_at(terrain, cell_pos))

def _board_cell_terrain_class_w(effect: U32) -> String:
  match effect:
    case 1:
      " cell--terrain-ice"
    case 2:
      " cell--terrain-fire"
    case _:
      ""

def _board_cell_preview_class(preview: List(Pos), preview_anchor: List(Pos), valid: U32, cell_pos: Pos) -> String:
  _board_cell_preview_class_anchor(_pos_list_has(preview_anchor, cell_pos), _pos_list_has(preview, cell_pos), valid)

def _board_cell_preview_class_anchor(anchor_hit: U32, hit: U32, valid: U32) -> String:
  match anchor_hit:
    case 0:
      _board_cell_preview_class_hit(hit, valid)
    case _:
      _board_cell_preview_anchor_class(valid)

def _board_cell_preview_class_hit(hit: U32, valid: U32) -> String:
  match hit:
    case 0:
      ""
    case _:
      match valid:
        case 0:
          " cell--preview cell--preview-invalid"
        case _:
          " cell--preview"

def _board_cell_preview_anchor_class(valid: U32) -> String:
  match valid:
    case 0:
      " cell--preview-anchor cell--preview-invalid"
    case _:
      " cell--preview-anchor"

def _board_cell_hit_class(hits: List(Pos), flash_hits: U32, hit_owner: U32, cell_pos: Pos) -> String:
  _board_cell_hit_class_hit(_pos_list_has(hits, cell_pos), flash_hits, hit_owner)

def _board_cell_hit_class_hit(hit: U32, flash_hits: U32, hit_owner: U32) -> String:
  match hit:
    case 0:
      ""
    case _:
      _board_cell_hit_flash_class(flash_hits, hit_owner)

def _board_cell_hit_flash_class(flash_hits: U32, hit_owner: U32) -> String:
  match flash_hits:
    case 0:
      " cell--hit" ++ _board_cell_hit_owner_class(hit_owner)
    case _:
      " cell--hit cell--attack-flash" ++ _board_cell_hit_owner_class(hit_owner) ++ _board_cell_flash_owner_class(hit_owner)

def _board_cell_hit_owner_class(hit_owner: U32) -> String:
  match hit_owner:
    case 1:
      " cell--hit-player"
    case 2:
      " cell--hit-enemy"
    case _:
      ""

def _board_cell_flash_owner_class(hit_owner: U32) -> String:
  match hit_owner:
    case 1:
      " cell--attack-flash-player"
    case 2:
      " cell--attack-flash-enemy"
    case _:
      ""

def _board_cell_route_class(trail: List(TrailStep), cell_pos: Pos) -> String:
  _board_cell_route_class_step(_trail_step_at(trail, cell_pos))

def _board_cell_route_class_step(step: U32) -> String:
  match step:
    case 0:
      ""
    case _:
      " cell--route"

def _board_cell_actor(state: GameState, bot_max_hp: U32, cell_pos: Pos) -> HTML(FightEvent):
  <div class={_board_cell_actor_class(state, cell_pos)}>{text{_board_cell_actor_text(state, bot_max_hp, cell_pos)}}</div>

def _board_cell_actor_class(state: GameState, cell_pos: Pos) -> String:
  match _pos_eq(_state_player(state), cell_pos):
    case 0:
      _board_cell_bot_actor_class(_state_bots(state), cell_pos) ++ _board_cell_actor_bump_class(state, cell_pos)
    case _:
      "actor actor--player" ++ _board_cell_actor_bump_class(state, cell_pos)

def _board_cell_actor_bump_class(state: GameState, cell_pos: Pos) -> String:
  active = _render_bump_active(state);
  same = _pos_eq(cell_pos, _action_sim_from(_state_playback_sim(state)));
  _board_cell_actor_bump_state(active & same, _action_dir(_state_playback_action(state)))

def _board_cell_actor_bump_state(show: U32, dir: U32) -> String:
  match show:
    case 0:
      ""
    case _:
      _board_cell_actor_bump_dir(dir)

def _board_cell_actor_bump_dir(dir: U32) -> String:
  match dir:
    case 0:
      " actor--bump actor--bump-up"
    case 1:
      " actor--bump actor--bump-down"
    case 2:
      " actor--bump actor--bump-left"
    case 3:
      " actor--bump actor--bump-right"
    case _:
      " actor--bump"

def _board_cell_bot_actor_class(bots: List(Bot), cell_pos: Pos) -> String:
  bot_hp = _bot_hp_at_pos(bots, cell_pos);
  dead = _hp_empty(bot_hp);
  _board_cell_bot_actor_class_dead(dead)

def _board_cell_bot_actor_class_dead(dead: U32) -> String:
  match dead:
    case 0:
      "actor actor--enemy"
    case _:
      "actor actor--hidden"

def _board_cell_actor_text(state: GameState, bot_max_hp: U32, cell_pos: Pos) -> String:
  match _pos_eq(_state_player(state), cell_pos):
    case 0:
      _board_cell_bot_actor_text(_state_bots(state), bot_max_hp, cell_pos)
    case _:
      "P"

def _board_cell_bot_actor_text(bots: List(Bot), bot_max_hp: U32, cell_pos: Pos) -> String:
  bot_hp = _bot_hp_at_pos(bots, cell_pos);
  match _hp_empty(bot_hp):
    case 0:
      _hp_text(bot_hp, bot_max_hp)
    case _:
      ""

def _board_cell_ghost(state: GameState, planned: Pos, cell_pos: Pos) -> HTML(FightEvent):
  <div class={_board_cell_ghost_class(_pos_eq(_state_player(state), planned), _pos_eq(planned, cell_pos))}>{text{_board_cell_ghost_text(_pos_eq(_state_player(state), planned), _pos_eq(planned, cell_pos))}}</div>

def _board_cell_ghost_class(same_now: U32, same_cell: U32) -> String:
  _board_cell_ghost_class_visible((1 ^ same_now) & same_cell)

def _board_cell_ghost_class_visible(show: U32) -> String:
  match show:
    case 0:
      "ghost ghost--hidden"
    case _:
      "ghost"

def _board_cell_ghost_text(same_now: U32, same_cell: U32) -> String:
  _board_cell_ghost_text_visible((1 ^ same_now) & same_cell)

def _board_cell_ghost_text_visible(show: U32) -> String:
  match show:
    case 0:
      ""
    case _:
      "P"

def _board_cell_route(trail: List(TrailStep), cell_pos: Pos) -> HTML(FightEvent):
  step = _trail_step_at(trail, cell_pos);
  <div class={_board_cell_route_badge_class(step)}>{text{_board_cell_route_badge_text(step)}}</div>

def _board_cell_route_badge_class(step: U32) -> String:
  match step:
    case 0:
      "trail trail--hidden"
    case _:
      "trail"

def _board_cell_route_badge_text(step: U32) -> String:
  match step:
    case 0:
      ""
    case s:
      U32.show(s)

def _winner_modal(state: GameState) -> HTML(FightEvent):
  winner = _state_winner(state);
  <div class={_winner_modal_class(winner)}>
    <div class={_winner_modal_card_class(winner)}>
      <div class="modal__eyebrow">{text{"Fim da partida"}}</div>
      <h2 class="modal__title">{text{_winner_modal_title(winner)}}</h2>
      <button {..._button_attrs("button", evt_reset{})}>
        {text{"Jogar novamente"}}
      </button>
    </div>
  </div>

def _winner_modal_class(winner: U32) -> String:
  match winner:
    case 0:
      "modal"
    case _:
      "modal modal--visible"

def _winner_modal_card_class(winner: U32) -> String:
  match winner:
    case 0:
      "modal__card modal__card--hidden"
    case _:
      "modal__card"

def _winner_modal_title(winner: U32) -> String:
  match winner:
    case 0:
      ""
    case result:
      _winner_title(result)

def _bot_count_dec_attrs(state: GameState) -> List(Attr(FightEvent)):
  _button_attrs_enabled("button", evt_bot_count_dec{}, _u32_lt(1, _state_bot_total(state)))

def _bot_count_inc_attrs(state: GameState) -> List(Attr(FightEvent)):
  _button_attrs_enabled("button", evt_bot_count_inc{}, _u32_lt(_state_bot_total(state), 25))

def _button_attrs(class_name: String, evt: FightEvent) -> List(Attr(FightEvent)):
  [attr{"type", "button"}, attr{"class", class_name}, on_click{evt}]

def _button_disabled_attrs(class_name: String) -> List(Attr(FightEvent)):
  [attr{"type", "button"}, attr{"class", class_name}, attr{"disabled", "disabled"}]

def _button_attrs_enabled(class_name: String, evt: FightEvent, enabled: U32) -> List(Attr(FightEvent)):
  match enabled:
    case 0:
      _button_disabled_attrs(class_name)
    case _:
      _button_attrs(class_name, evt)

def _confirm_button_attrs(state: GameState) -> List(Attr(FightEvent)):
  enabled = _state_target_active(state) & target_valid(state);
  _button_attrs_enabled("button", evt_confirm{}, enabled)

def _skill_button_attrs(state: GameState, skill: U32) -> List(Attr(FightEvent)):
  match skill:
    case 1:
      _button_attrs(_skill_button_class(state, 1), evt_skill_1{})
    case 2:
      _button_attrs(_skill_button_class(state, 2), evt_skill_2{})
    case _:
      _button_attrs(_skill_button_class(state, 3), evt_skill_3{})

def _skill_button_class(state: GameState, skill: U32) -> String:
  _skill_button_class_active(_state_target_skill_is(state, skill))

def _skill_button_class_active(active: U32) -> String:
  match active:
    case 0:
      "button button--secondary"
    case _:
      "button button--secondary button--active"

def _skill_name(skill: U32) -> String:
  Fight.skill_name(skill)

def _skill_class_label(skill: U32) -> String:
  Fight.skill_class_label(skill)

def _action_label(action: Action) -> String:
  match action:
    case wait{}:
      "Parado"
    case move{dir}:
      "Mover " ++ _dir_label(dir)
    case attack{skill, anchor, rot}:
      "Ataque " ++ _skill_name(skill)

def _dir_label(dir: U32) -> String:
  match dir:
    case 0:
      "Up"
    case 1:
      "Down"
    case 2:
      "Left"
    case 3:
      "Right"
    case _:
      "Wait"

def _playback_total_steps(bot_total: U32) -> U32:
  3 * (bot_total + 1)

def _playback_slot_of_idx(idx: U32, bot_total: U32) -> U32:
  idx / (bot_total + 1)

def _playback_turn_of_idx(idx: U32, bot_total: U32) -> U32:
  idx % (bot_total + 1)

def _playback_actor_of_idx(idx: U32, bot_total: U32) -> U32:
  match _playback_turn_of_idx(idx, bot_total):
    case 0:
      1
    case 1:
      0
    case _:
      1

def _playback_actor_idx_of_idx(idx: U32, bot_total: U32) -> U32:
  match _playback_turn_of_idx(idx, bot_total):
    case 0:
      0
    case 1:
      0
    case step:
      step - 1

def _bot_plan_at(items: List(List(Action)), idx: U32) -> List(Action):
  match items:
    case []:
      _queue_waits()
    case head<>tail:
      match idx:
        case 0:
          head
        case step:
          _bot_plan_at(tail, step - 1)

def _playback_action(queue: List(Action), bot_plans: List(List(Action)), idx: U32, bot_total: U32) -> Action:
  slot = _playback_slot_of_idx(idx, bot_total);
  actor = _playback_actor_of_idx(idx, bot_total);
  actor_idx = _playback_actor_idx_of_idx(idx, bot_total);
  _playback_action_actor(actor, queue, bot_plans, actor_idx, slot)

def _playback_action_actor(actor: U32, queue: List(Action), bot_plans: List(List(Action)), actor_idx: U32, slot: U32) -> Action:
  match actor:
    case 0:
      _action_at(queue, slot)
    case _:
      plan = _bot_plan_at(bot_plans, actor_idx);
      _action_at(plan, slot)

def _playback_actor_label(actor: U32, actor_idx: U32) -> String:
  match actor:
    case 0:
      "Player"
    case _:
      "Bot " ++ U32.show(actor_idx + 1)

def _actor_label(actor: U32, actor_idx: U32) -> String:
  _playback_actor_label(actor, actor_idx)

def _playback_info_text(state: GameState) -> String:
  _playback_info_text_active(state, _state_playback_active(state))

def _playback_info_text_active(state: GameState, active: U32) -> String:
  match active:
    case 0:
      ""
    case _:
      _playback_info_text_now(state, _state_playback_idx(state), _state_playback_plans(state))

def _playback_info_text_now(state: GameState, idx: U32, bot_plans: List(List(Action))) -> String:
  "Executando slot "
  ++ U32.show(_playback_slot_of_idx(idx, _state_bot_total(state)) + 1)
  ++ ": "
  ++ _playback_actor_label(_state_playback_actor(state), _state_playback_actor_idx(state))
  ++ " - "
  ++ _action_label(_playback_action(_state_queue(state), bot_plans, idx, _state_bot_total(state)))

def _mode_text(state: GameState) -> String:
  _mode_text_w(_state_winner(state), _state_mode_value(state))

def _mode_text_w(winner: U32, mode: Mode) -> String:
  match winner:
    case 0:
      _mode_text_mode(mode)
    case _:
      "Combate encerrado"

def _mode_text_mode(mode: Mode) -> String:
  match mode:
    case plan{_}:
      "Planejando round"
    case target{skill, rot, origin, _}:
      "Mira de " ++ _skill_name(skill) ++ " rot " ++ U32.show(rot) ++ " encaixe " ++ _pos_text(origin)
    case playback{_, _, _, _, _, _, _, _}:
      "Resolvendo round"

def _phase_label(state: GameState) -> String:
  _phase_label_w(_state_winner(state), _state_mode_value(state), target_valid(state))

def _phase_label_w(winner: U32, mode: Mode, valid: U32) -> String:
  match winner:
    case 0:
      _phase_label_mode(mode, valid)
    case result:
      _winner_title(result)

def _phase_label_mode(mode: Mode, valid: U32) -> String:
  match mode:
    case plan{_}:
      "Planning"
    case target{_, _, _, _}:
      _phase_label_target(valid)
    case playback{_, _, _, _, _, _, _, _}:
      "Playback"

def _phase_label_target(valid: U32) -> String:
  match valid:
    case 0:
      "Target Invalid"
    case _:
      "Target Ready"

def _phase_chip_class(state: GameState) -> String:
  _phase_chip_class_w(_state_winner(state), _state_mode_value(state))

def _phase_chip_class_w(winner: U32, mode: Mode) -> String:
  match winner:
    case 0:
      _phase_chip_class_mode(mode)
    case _:
      "chip chip--over"

def _phase_chip_class_mode(mode: Mode) -> String:
  match mode:
    case plan{_}:
      "chip chip--plan"
    case target{_, _, _, _}:
      "chip chip--target"
    case playback{_, _, _, _, _, _, _, _}:
      "chip chip--target"

def _winner_title(winner: U32) -> String:
  match winner:
    case 1:
      "Vitoria"
    case 2:
      "Derrota"
    case 3:
      "Empate"
    case _:
      ""

def _hp_text(hp: U32, max_hp: U32) -> String:
  U32.show(hp) ++ "/" ++ U32.show(max_hp)

def _pos_text(pos_value: Pos) -> String:
  match pos_value:
    case pos{x, y}:
      "(" ++ U32.show(x) ++ ", " ++ U32.show(y) ++ ")"

def _pos_list_has(items: List(Pos), target: Pos) -> U32:
  match items:
    case []:
      0
    case head<>tail:
      match _pos_eq(head, target):
        case 0:
          _pos_list_has(tail, target)
        case _:
          1

def _trail_step_at(items: List(TrailStep), target: Pos) -> U32:
  match items:
    case []:
      0
    case trail_step{x, y, step}<>tail:
      match _pos_eq(pos{x, y}, target):
        case 0:
          _trail_step_at(tail, target)
        case _:
          step

def _state_round(state: GameState) -> U32:
  match state:
    case game_state{meta, _, _}:
      _meta_round(meta)

def _state_winner(state: GameState) -> U32:
  match state:
    case game_state{_, arena, _}:
      _arena_winner(arena)

def _state_mode_value(state: GameState) -> Mode:
  match state:
    case game_state{_, _, plan_value}:
      _plan_mode_value(plan_value)

def _state_target_active(state: GameState) -> U32:
  _mode_is_target(_state_mode_value(state))

def _state_target_skill(state: GameState) -> U32:
  _mode_skill(_state_mode_value(state))

def _state_target_rot(state: GameState) -> U32:
  _mode_rot(_state_mode_value(state))

def _state_target_origin(state: GameState) -> Pos:
  _mode_origin(_state_mode_value(state))

def _state_target_skill_is(state: GameState, skill: U32) -> U32:
  active = _state_target_active(state);
  match active:
    case 0:
      0
    case _:
      _state_target_skill(state) === skill

def _state_playback_active(state: GameState) -> U32:
  _mode_is_playback(_state_mode_value(state))

def _state_playback_idx(state: GameState) -> U32:
  _mode_playback_idx(_state_mode_value(state))

def _state_playback_phase(state: GameState) -> U32:
  _mode_playback_phase(_state_mode_value(state))

def _state_playback_actor(state: GameState) -> U32:
  _mode_playback_actor(_state_mode_value(state))

def _state_playback_actor_idx(state: GameState) -> U32:
  _mode_playback_actor_idx(_state_mode_value(state))

def _state_playback_action(state: GameState) -> Action:
  _mode_playback_action(_state_mode_value(state))

def _state_playback_sim(state: GameState) -> ActionSim:
  _mode_playback_sim(_state_mode_value(state))

def _state_playback_plans(state: GameState) -> List(List(Action)):
  _mode_playback_plans(_state_mode_value(state))

def base_css() -> String:
  ""
  ++ ":root{--bg:#d3bb94;--panel:#efe2c6;--card:#f7ecd3;--text:#2a2115;--muted:#6b593c;--border:#7a613c;--board-frame:#6f5634;--grid:#7f6541;--cell:#f8efd7;--preview:#ddb151;--preview-anchor:#58d8e8;--preview-anchor-deep:#1494a8;--preview-hook:#e2bf48;--preview-ice:#70aee4;--preview-fire:#df8d39;--invalid:#cf6c5b;--hit-player:#2a74d8;--hit-player-deep:#184889;--hit-enemy:#d94933;--hit-enemy-deep:#8f2416;--route:#c9dff5;--player:#1f78db;--enemy:#32933a;--ghost:#5b9fe7;--button:#966320;--button-alt:#66794a;--danger:#b74431;--sidebar-width:278px;--cell-size:clamp(42px,3.3vw,52px);--board-shell-padding:12px;--board-width:calc((var(--cell-size) * 18) + 19px);--board-shell-width:calc(var(--board-width) + (var(--board-shell-padding) * 2) + 2px);}"
  ++ "*{box-sizing:border-box;}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:var(--bg);color:var(--text);font-family:'Trebuchet MS','Segoe UI',sans-serif;}body{overflow:hidden;}button{font:inherit;cursor:pointer;}#app,.page{width:100%;min-height:100svh;overflow:hidden;}.play-screen-stack{width:100%;min-height:100svh;}.play-screen--hidden{display:none;}"

def layout_css() -> String:
  ""
  ++ ".shell{width:100%;height:100svh;display:grid;grid-template-columns:minmax(0,1fr) var(--sidebar-width);overflow:hidden;}.board-stage{min-width:0;min-height:0;display:grid;grid-template-columns:minmax(0,2fr) minmax(0,var(--board-shell-width)) minmax(0,1fr);align-items:center;overflow:auto;overscroll-behavior:contain;}.board-stack{width:var(--board-shell-width);display:grid;gap:14px;grid-column:2;}.board-wrap{position:relative;padding:var(--board-shell-padding);background:var(--board-frame);border:1px solid var(--border);overflow:hidden;isolation:isolate;}.board-wrap-large{width:var(--board-shell-width);}"
  ++ ".board{width:var(--board-width);display:grid;grid-template-columns:repeat(18,var(--cell-size));gap:1px;padding:1px;background:var(--grid);}.cell{position:relative;aspect-ratio:1/1;min-width:0;background:var(--cell);display:grid;place-items:center;overflow:hidden;}.cell--terrain-ice{background:#d9eef6;}.cell--terrain-fire{background:#f0c08b;}.cell--preview{background:var(--preview);}.cell--preview-anchor{background:var(--preview-anchor);}.cell--preview-invalid{background:var(--invalid);}.cell--hit-player{box-shadow:inset 0 0 0 2px var(--hit-player);}.cell--hit-enemy{box-shadow:inset 0 0 0 2px var(--hit-enemy);}.cell--route{background:var(--route);}"
  ++ ".board-underbar{width:100%;padding:12px;display:flex;gap:12px;align-items:stretch;background:var(--panel);border:1px solid var(--border);}.player-hp-card{width:116px;padding:12px 14px;background:var(--card);border:1px solid #bda173;}.queue-inline{min-width:0;flex:1 1 auto;display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px;}.queue-slot{padding:12px 14px;background:var(--panel);border:1px solid #c8ae83;}.queue-slot--active{background:#f1dfb8;border-color:var(--button);}.queue-slot--enemy-turn{border-color:var(--enemy);}.queue-slot__index{font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:var(--muted);}.queue-slot__value{margin-top:6px;font-weight:700;}"
  ++ ".skill-strip{display:flex;gap:10px;align-items:stretch;}.sidebar{min-width:0;min-height:0;padding:18px;display:grid;gap:14px;align-content:start;overflow:auto;overscroll-behavior:contain;border-left:1px solid var(--border);background:var(--panel);}.card{padding:14px 16px;background:var(--card);border:1px solid #bda173;}.stat-label{font-size:11px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);}.stat-label--spaced{margin-top:12px;display:block;}.stat-value{margin-top:6px;font-size:28px;font-weight:800;}.sidebar-round{margin-top:2px;}.sidebar-phase{margin:0;font-size:22px;font-weight:800;line-height:1.2;}.controls{display:flex;gap:10px;flex-wrap:wrap;}.controls--actions{margin-top:12px;display:flex;gap:10px;flex-wrap:wrap;}.help{margin:0;color:var(--muted);line-height:1.5;}.help--hidden,.winner--hidden,.modal__card--hidden,.actor--hidden{display:none;}.help--spaced{margin-top:10px;}.help--playback{margin-top:8px;}.winner{margin:10px 0 0;color:#8f2416;font-weight:800;}"
  ++ "@media (max-width:1180px){.shell{grid-template-columns:minmax(0,1fr) var(--sidebar-width);}}"
  ++ "@media (max-width:980px){.page{height:100svh;overflow:auto;}.shell{min-height:100%;height:auto;display:block;overflow:visible;}.board-stage{display:block;padding:0;overflow:visible;}.board-stack{width:min(100%,var(--board-shell-width));margin:0 auto;grid-column:auto;gap:12px;}.board-wrap-large{width:100%;}.board{width:min(100%,var(--board-width));grid-template-columns:repeat(18,minmax(0,1fr));}.board-underbar{flex-direction:column;}.player-hp-card{width:auto;}.sidebar{border:none;padding:12px 0 14px;overflow:visible;background:transparent;}.skill-strip{overflow:auto;max-width:100%;padding-bottom:2px;}.menu-page{padding:20px 14px;}.menu-page--lobby{overflow:auto;}.lobby-grid{grid-template-columns:1fr;}.lobby-shell{max-height:none;}.lobby-card{height:auto;overflow:visible;grid-template-rows:auto auto auto auto auto;}.skill-filter-row{justify-content:flex-start;}.skill-pool-grid{grid-template-columns:repeat(2,minmax(0,1fr));}.skill-pool-wrap{max-height:none;overflow:visible;padding-right:0;}}"

def menu_css() -> String:
  ""
  ++ ".menu-page{min-height:100svh;padding:32px 24px;display:grid;place-items:center;overflow:auto;}.menu-page--lobby{height:100svh;place-items:start center;overflow:auto;}.menu-card{width:min(100%,1120px);padding:24px;background:var(--panel);border:1px solid var(--border);}.hero-card{width:min(100%,520px);display:grid;gap:18px;justify-items:center;text-align:center;padding:36px 28px;}.story-card{width:min(100%,640px);display:grid;gap:16px;justify-items:start;}.menu-eyebrow{font-size:12px;letter-spacing:.18em;text-transform:uppercase;color:var(--muted);font-weight:800;}.menu-title{margin:0;font-size:44px;line-height:1;}.menu-title--lobby{font-size:36px;}.menu-copy{margin:0;color:var(--muted);line-height:1.6;max-width:56ch;}.menu-copy--compact{max-width:none;}.menu-actions{display:flex;gap:12px;flex-wrap:wrap;}.menu-actions--stacked{width:min(100%,280px);display:grid;grid-template-columns:1fr;}.menu-actions--stacked .button{width:100%;}.lobby-shell{width:min(100%,1120px);max-height:calc(100svh - 64px);display:grid;grid-template-rows:auto minmax(0,1fr) auto;gap:20px;}.lobby-header{display:flex;justify-content:space-between;gap:12px;align-items:flex-start;}.lobby-grid{min-height:0;display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:18px;align-items:stretch;}.lobby-card{min-height:0;height:100%;overflow:hidden;display:grid;grid-template-rows:auto auto auto auto minmax(0,1fr);gap:12px;align-content:start;}.lobby-slot-strip{display:flex;gap:10px;flex-wrap:wrap;}.lobby-skill-head{display:flex;align-items:flex-start;justify-content:space-between;gap:12px;}.skill-filter-row{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end;}.skill-filter-button{border:none;border-radius:999px;padding:8px 12px;background:var(--panel);color:var(--text);font-size:12px;font-weight:800;}.skill-filter-button--active{background:var(--button);color:#fff8eb;}.skill-pool-wrap{min-height:0;overflow:auto;padding-right:4px;}.skill-pool-grid{display:grid;grid-template-columns:repeat(4,minmax(0,1fr));gap:12px;}.lobby-footer{display:flex;justify-content:space-between;gap:14px;align-items:center;flex-wrap:wrap;}"

def component_css() -> String:
  ""
  ++ ".button{border:none;border-radius:999px;padding:11px 15px;cursor:pointer;font:inherit;font-weight:800;color:#fff8eb;background:var(--button);}.button.alt{background:var(--button-alt);}.button.ghost{background:var(--danger);}.button--menu{min-width:140px;justify-content:center;}.button--menu-secondary{background:#b58a43;}.button--stepper{padding:10px 0;min-width:0;border-radius:12px;background:var(--button);}.button:disabled{opacity:.56;cursor:default;}.nav-link{display:inline-flex;align-items:center;justify-content:center;text-decoration:none;}.nav-link--disabled{opacity:.56;pointer-events:none;}"
  ++ ".actor{position:absolute;inset:14%;display:grid;place-items:center;font-size:clamp(12px,1.25vw,18px);font-weight:900;color:#fff8eb;z-index:2;}.actor--player{background:var(--player);font-size:clamp(14px,1.15vw,18px);}.actor--enemy{background:var(--enemy);inset:10%;padding:0 4px;font-size:clamp(8px,.85vw,12px);line-height:1;letter-spacing:-.02em;text-align:center;}.actor--bump{will-change:transform;}.actor--bump-up{animation:actor-bump-up .18s ease-out 1;}.actor--bump-down{animation:actor-bump-down .18s ease-out 1;}.actor--bump-left{animation:actor-bump-left .18s ease-out 1;}.actor--bump-right{animation:actor-bump-right .18s ease-out 1;}.ghost{position:absolute;inset:18%;display:grid;place-items:center;background:transparent;color:var(--ghost);border:3px solid var(--ghost);font-size:clamp(12px,1.05vw,16px);font-weight:900;z-index:1;}.ghost--hidden{display:none;}.trail{position:absolute;top:4px;left:4px;min-width:18px;height:18px;padding:0 5px;display:grid;place-items:center;font-size:11px;font-weight:900;line-height:1;color:#fff8eb;background:var(--player);z-index:4;}.trail--hidden{display:none;}.cell--attack-flash{animation-duration:.42s;animation-timing-function:linear;animation-iteration-count:1;}.cell--attack-flash-player{animation-name:attack-flash-player;}.cell--attack-flash-enemy{animation-name:attack-flash-enemy;}.cell--attack-flash .trail,.cell--attack-flash .ghost,.cell--attack-flash .actor{z-index:5;}@keyframes actor-bump-up{0%{transform:translateY(0);}45%{transform:translateY(-12%);}100%{transform:translateY(0);}}@keyframes actor-bump-down{0%{transform:translateY(0);}45%{transform:translateY(12%);}100%{transform:translateY(0);}}@keyframes actor-bump-left{0%{transform:translateX(0);}45%{transform:translateX(-12%);}100%{transform:translateX(0);}}@keyframes actor-bump-right{0%{transform:translateX(0);}45%{transform:translateX(12%);}100%{transform:translateX(0);}}@keyframes attack-flash-player{0%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}15%{background:var(--hit-player);box-shadow:inset 0 0 0 2px var(--hit-player-deep);}30%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}45%{background:var(--hit-player);box-shadow:inset 0 0 0 2px var(--hit-player-deep);}60%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}75%{background:var(--hit-player);box-shadow:inset 0 0 0 2px var(--hit-player-deep);}100%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}}@keyframes attack-flash-enemy{0%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}15%{background:var(--hit-enemy);box-shadow:inset 0 0 0 2px var(--hit-enemy-deep);}30%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}45%{background:var(--hit-enemy);box-shadow:inset 0 0 0 2px var(--hit-enemy-deep);}60%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}75%{background:var(--hit-enemy);box-shadow:inset 0 0 0 2px var(--hit-enemy-deep);}100%{background:var(--cell);box-shadow:inset 0 0 0 2px transparent;}}"
  ++ ".skill-preview{width:106px;min-height:122px;padding:10px;display:grid;justify-items:center;align-content:start;gap:6px;border:1px solid #bda173;border-radius:14px;background:var(--card);color:var(--text);text-align:center;}.skill-preview--active{border-color:var(--button);background:#f1dfb8;}.skill-preview--empty{opacity:.72;}.skill-preview--static{pointer-events:none;}.skill-key{font-size:11px;font-weight:900;letter-spacing:.14em;color:var(--muted);}.skill-caption{font-size:12px;font-weight:700;color:var(--text);line-height:1.2;}.skill-grid-frame{width:64px;height:64px;display:grid;place-items:center;padding:4px;border:1px solid #ccb287;background:var(--panel);overflow:hidden;}.skill-grid-frame--empty{background:#f2e5cb;}.skill-grid-art{display:block;width:100%;height:100%;object-fit:contain;}.skill-pool-card{aspect-ratio:1/1;border:1px solid #bda173;border-radius:16px;padding:12px;display:grid;justify-items:center;align-content:start;gap:6px;background:var(--card);color:var(--text);text-align:center;}.skill-pool-card--selected{border-color:var(--button);background:#f1dfb8;}.skill-pool-card--hidden{display:none;}.skill-pool-card__label{font-size:12px;font-weight:800;color:var(--text);}.skill-pool-card__meta{font-size:11px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);}.stepper--static{grid-template-columns:minmax(82px,auto);}"
  ++ ".modal{position:absolute;inset:0;display:grid;place-items:center;padding:16px;opacity:0;pointer-events:none;background:rgba(42,33,21,0);z-index:30;}.modal--visible{opacity:1;pointer-events:auto;background:rgba(42,33,21,.46);}.modal__card{position:relative;z-index:31;width:min(100%,340px);display:grid;gap:12px;justify-items:center;padding:24px 22px;background:var(--card);border:1px solid #bda173;}.modal__eyebrow{font-size:12px;letter-spacing:.16em;text-transform:uppercase;color:var(--muted);font-weight:800;}.modal__title{margin:0;font-size:34px;line-height:1;}.timer-hook{display:none;}"

def css() -> String:
  base_css()
  ++ layout_css()
  ++ component_css()

main : App =
  app{AppState, FightEvent, init, render, on_event}
