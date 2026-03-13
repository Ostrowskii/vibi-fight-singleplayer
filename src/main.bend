import /App/
import /HTML/
import /Attr/
import /U32/ as U32

# main.bend
# =========
# Single-file Bend web app for the fight prototype.

type Pos {
  pos{x: U32, y: U32}
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
  plan{}
  target{skill: U32, rot: U32, origin: Pos}
}

type GameState {
  game_state{
    round: U32,
    level: U32,
    player_hp: U32,
    enemy_hp: U32,
    player: Pos,
    enemy: Pos,
    queue: List(Action),
    queue_len: U32,
    queue_locked: U32,
    mode: Mode,
    winner: U32,
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

def state_init() -> GameState:
  game_state{
    1,
    1,
    50,
    50,
    pos{6, 4},
    pos{11, 4},
    _queue_waits(),
    0,
    0,
    _plan_mode(),
    0,
  }

def skill_len(skill: U32) -> U32:
  match skill:
    case 1:
      4
    case 2:
      5
    case 3:
      5
    case _:
      0

def skill_point(skill: U32, rot: U32, idx: U32) -> Pos:
  match skill rot idx:
    case 1 0 0:
      pos{3, 0}
    case 1 0 1:
      pos{2, 1}
    case 1 0 2:
      pos{1, 2}
    case 1 0 3:
      pos{0, 3}
    case 1 1 0:
      pos{0, 0}
    case 1 1 1:
      pos{1, 1}
    case 1 1 2:
      pos{2, 2}
    case 1 1 3:
      pos{3, 3}
    case 1 2 0:
      pos{3, 0}
    case 1 2 1:
      pos{2, 1}
    case 1 2 2:
      pos{1, 2}
    case 1 2 3:
      pos{0, 3}
    case 1 3 0:
      pos{0, 0}
    case 1 3 1:
      pos{1, 1}
    case 1 3 2:
      pos{2, 2}
    case 1 3 3:
      pos{3, 3}
    case 2 _ 0:
      pos{0, 0}
    case 2 _ 1:
      pos{2, 0}
    case 2 _ 2:
      pos{1, 1}
    case 2 _ 3:
      pos{0, 2}
    case 2 _ 4:
      pos{2, 2}
    case 3 0 0:
      pos{0, 0}
    case 3 0 1:
      pos{0, 1}
    case 3 0 2:
      pos{0, 2}
    case 3 0 3:
      pos{0, 3}
    case 3 0 4:
      pos{1, 3}
    case 3 1 0:
      pos{3, 0}
    case 3 1 1:
      pos{2, 0}
    case 3 1 2:
      pos{1, 0}
    case 3 1 3:
      pos{0, 0}
    case 3 1 4:
      pos{0, 1}
    case 3 2 0:
      pos{3, 3}
    case 3 2 1:
      pos{3, 2}
    case 3 2 2:
      pos{3, 1}
    case 3 2 3:
      pos{3, 0}
    case 3 2 4:
      pos{2, 0}
    case 3 3 0:
      pos{0, 3}
    case 3 3 1:
      pos{1, 3}
    case 3 3 2:
      pos{2, 3}
    case 3 3 3:
      pos{3, 3}
    case 3 3 4:
      pos{3, 2}
    case _ _ _:
      pos{0, 0}

def planned_player_pos(state: GameState) -> Pos:
  match state:
    case game_state{_, _, _, _, player, _, queue, _, _, _, _}:
      _planned_pos_from_queue(player, queue)

def movement_trail(state: GameState) -> List(TrailStep):
  match state:
    case game_state{_, _, _, _, player, _, queue, _, _, _, _}:
      _movement_trail_from_queue(player, queue, 1)

def preview_tiles(state: GameState) -> List(Pos):
  match state:
    case game_state{_, _, _, _, _, _, _, _, _, mode, _}:
      active = _mode_is_target(mode);
      match active:
        case 0:
          _pos_nil()
        case _:
          _preview_tiles_for(_mode_skill(mode), _mode_rot(mode), _mode_origin(mode), 0)

def preview_hits(state: GameState) -> List(Pos):
  match state:
    case game_state{_, _, _, _, player, _, queue, _, _, mode, _}:
      active = _mode_is_target(mode);
      match active:
        case 0:
          _pos_nil()
        case _:
          actor = _planned_pos_from_queue(player, queue);
          _preview_hits_for(_mode_skill(mode), _mode_rot(mode), _mode_origin(mode), actor, 0)

def target_valid(state: GameState) -> U32:
  match state:
    case game_state{_, _, _, _, player, _, queue, _, _, mode, _}:
      active = _mode_is_target(mode);
      match active:
        case 0:
          0
        case _:
          actor = _planned_pos_from_queue(player, queue);
          _placement_valid(_mode_skill(mode), _mode_rot(mode), _mode_origin(mode), actor)

def queue_move_state(state: GameState, dir: U32) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      _queue_move_w(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner, dir)

def start_target_state(state: GameState, skill: U32) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      _start_target_w(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner, skill)

def move_target_state(state: GameState, dir: U32) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
        case _:
          origin = _mode_origin(mode);
          skill = _mode_skill(mode);
          rot = _mode_rot(mode);
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, _target_mode(skill, rot, _step_free(origin, dir)), winner)

def rotate_target_state(state: GameState, clockwise: U32) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
        case _:
          add = _rotate_step(clockwise);
          rot = (_mode_rot(mode) + add) % 4;
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, _target_mode(_mode_skill(mode), rot, _mode_origin(mode)), winner)

def cancel_target_state(state: GameState) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
        case _:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, _plan_mode(), winner)

def confirm_target_state(state: GameState) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      active = _mode_is_target(mode);
      match active:
        case 0:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
        case _:
          skill = _mode_skill(mode);
          rot = _mode_rot(mode);
          origin = _mode_origin(mode);
          actor = _planned_pos_from_queue(player, queue);
          valid = _placement_valid(skill, rot, origin, actor);
          match valid:
            case 0:
              _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
            case _:
              anchor = _anchor_for_origin(skill, rot, origin, actor, 0);
              queue = _action_set(queue, queue_len, _attack_action(skill, anchor, rot));
              _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len + 1, 1, _plan_mode(), winner)

def clear_round_plan_state(state: GameState) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      match winner:
        case 0:
          _state(round, level, player_hp, enemy_hp, player, enemy, _queue_waits(), 0, 0, _plan_mode(), 0)
        case k:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, k)

def pop_last_planned_action_state(state: GameState) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      _pop_last_w(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)

def build_bot_plan(state: GameState) -> List(Action):
  match state:
    case game_state{round, _, player_hp, enemy_hp, player, enemy, _, _, _, _, winner}:
      _build_bot_plan_w(round, player_hp, enemy_hp, player, enemy, winner)

def resolve_actor_action_state(state: GameState, actor: U32, action: Action) -> GameState:
  match actor:
    case 0:
      _resolve_player_action_state(state, action)
    case _:
      _resolve_enemy_action_state(state, action)

def reset_round_planning_state(state: GameState) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, _, _, _, _, winner}:
      _reset_round_planning_w(round, level, player_hp, enemy_hp, player, enemy, winner)

def simulate_actor_action(state: GameState, actor: U32, action: Action) -> ActionSim:
  match actor:
    case 0:
      _simulate_player_action(state, action)
    case _:
      _simulate_enemy_action(state, action)

def _state(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32,
) -> GameState:
  game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}

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

def _plan_mode() -> Mode:
  plan{}

def _target_mode(skill: U32, rot: U32, origin: Pos) -> Mode:
  target{skill, rot, origin}

def _queue_waits() -> List(Action):
  _queue3(_wait_action(), _wait_action(), _wait_action())

def _rotate_step(clockwise: U32) -> U32:
  match clockwise:
    case 0:
      3
    case _:
      1

def _queue_move_w(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, dir: U32,
) -> GameState:
  match winner:
    case 0:
      _queue_move_plan(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, _mode_is_plan(mode), dir)
    case k:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, k)

def _queue_move_plan(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, plan_mode: U32, dir: U32,
) -> GameState:
  match plan_mode:
    case 0:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, 0)
    case _:
      _queue_move_lock(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, dir)

def _queue_move_lock(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, dir: U32,
) -> GameState:
  match queue_locked:
    case 0:
      _queue_move_len(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, 0, mode, dir)
    case lock:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, lock, mode, 0)

def _queue_move_len(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, dir: U32,
) -> GameState:
  match queue_len:
    case 0:
      _queue_move_ok(round, level, player_hp, enemy_hp, player, enemy, queue, 0, queue_locked, 0, dir)
    case 1:
      _queue_move_ok(round, level, player_hp, enemy_hp, player, enemy, queue, 1, queue_locked, 0, dir)
    case q:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, q, queue_locked, mode, 0)

def _start_target_w(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, skill: U32,
) -> GameState:
  match winner:
    case 0:
      _start_target_lock(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, skill)
    case k:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, k)

def _start_target_lock(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, skill: U32,
) -> GameState:
  match queue_locked:
    case 0:
      _start_target_len(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, 0, mode, skill)
    case lock:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, lock, mode, 0)

def _start_target_len(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, skill: U32,
) -> GameState:
  match queue_len:
    case 3:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, 3, queue_locked, mode, 0)
    case q:
      _start_target_apply(round, level, player_hp, enemy_hp, player, enemy, queue, q, queue_locked, skill)

def _pop_last_w(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32,
) -> GameState:
  match winner:
    case 0:
      _pop_last_plan(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, _mode_is_plan(mode))
    case k:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, k)

def _pop_last_plan(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, plan_mode: U32,
) -> GameState:
  match plan_mode:
    case 0:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, 0)
    case _:
      _pop_last_len(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode)

def _pop_last_len(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode,
) -> GameState:
  match queue_len:
    case 0:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, 0, queue_locked, mode, 0)
    case q:
      last = q - 1;
      queue = _action_set(queue, last, _wait_action());
      lock = _queue_has_attack(queue);
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, last, lock, _plan_mode(), 0)

def _start_target_apply(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, skill: U32,
) -> GameState:
  _state(
    round,
    level,
    player_hp,
    enemy_hp,
    player,
    enemy,
    queue,
    queue_len,
    queue_locked,
    _target_mode(skill, 0, _default_target_origin(skill, _planned_pos_from_queue(player, queue))),
    0
  )

def _queue_move_ok(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, winner: U32, dir: U32,
) -> GameState:
  planned = _planned_pos_from_queue(player, queue);
  next = _step_free(planned, dir);
  same = _pos_eq(planned, next);
  match same:
    case 0:
      queue = _action_set(queue, queue_len, _move_action(dir));
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len + 1, queue_locked, _plan_mode(), winner)
    case _:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, _plan_mode(), winner)

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

def _preview_tiles_for(skill: U32, rot: U32, origin: Pos, idx: U32) -> List(Pos):
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      cell = _pos_add(origin, skill_point(skill, rot, idx));
      rest = _preview_tiles_for(skill, rot, origin, idx + 1);
      inside = _pos_inside(cell);
      match inside:
        case 0:
          rest
        case _:
          _pos_cons(cell, rest)
    case _:
      _pos_nil()

def _preview_hits_for(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> List(Pos):
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      cell = _pos_add(origin, skill_point(skill, rot, idx));
      rest = _preview_hits_for(skill, rot, origin, actor, idx + 1);
      inside = _pos_inside(cell);
      same = _pos_eq(cell, actor);
      keep = inside & (1 ^ same);
      match keep:
        case 0:
          rest
        case _:
          _pos_cons(cell, rest)
    case _:
      _pos_nil()

def _placement_valid(skill: U32, rot: U32, origin: Pos, actor: Pos) -> U32:
  _placement_all_in(skill, rot, origin, 0) & _placement_covers(skill, rot, origin, actor, 0)

def _placement_all_in(skill: U32, rot: U32, origin: Pos, idx: U32) -> U32:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      cell = _pos_add(origin, skill_point(skill, rot, idx));
      inside = _pos_inside(cell);
      match inside:
        case 0:
          0
        case _:
          _placement_all_in(skill, rot, origin, idx + 1)
    case _:
      1

def _placement_covers(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> U32:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      cell = _pos_add(origin, skill_point(skill, rot, idx));
      same = _pos_eq(cell, actor);
      match same:
        case 0:
          _placement_covers(skill, rot, origin, actor, idx + 1)
        case _:
          1
    case _:
      0

def _preview_hit_contains(skill: U32, rot: U32, origin: Pos, actor: Pos, target: Pos, idx: U32) -> U32:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      cell = _pos_add(origin, skill_point(skill, rot, idx));
      inside = _pos_inside(cell);
      same_actor = _pos_eq(cell, actor);
      same_target = _pos_eq(cell, target);
      hit = inside & (1 ^ same_actor) & same_target;
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
  anchor = skill_point(skill, 0, 0);
  _origin_from_anchor(actor, anchor)

def _origin_from_anchor(actor: Pos, anchor: Pos) -> Pos:
  match actor:
    case pos{ax, ay}:
      match anchor:
        case pos{sx, sy}:
          pos{_sub_floor(ax, sx), _sub_floor(ay, sy)}

def _anchor_for_origin(skill: U32, rot: U32, origin: Pos, actor: Pos, idx: U32) -> Pos:
  len = skill_len(skill);
  stop = idx === len;
  match stop:
    case 0:
      local = skill_point(skill, rot, idx);
      world = _pos_add(origin, local);
      same = _pos_eq(world, actor);
      match same:
        case 0:
          _anchor_for_origin(skill, rot, origin, actor, idx + 1)
        case _:
          local
    case _:
      pos{0, 0}

def _build_bot_plan_w(round: U32, player_hp: U32, enemy_hp: U32, player: Pos, enemy: Pos, winner: U32) -> List(Action):
  stopped = winner | _hp_empty(player_hp) | _hp_empty(enemy_hp);
  match stopped:
    case 0:
      _build_bot_plan(player, enemy, round)
    case _:
      _queue_waits()

def _build_bot_plan(player: Pos, enemy: Pos, round: U32) -> List(Action):
  immediate = _find_attack(enemy, player);
  hit = _action_is_attack(immediate);
  match hit:
    case 0:
      one_move = _find_one_move_plan(enemy, player, 0);
      one_hit = _queue_has_attack(one_move);
      match one_hit:
        case 0:
          two_move = _find_two_move_plan(enemy, player, 0);
          two_hit = _queue_has_attack(two_move);
          match two_hit:
            case 0:
              _fallback_plan(round, enemy, player)
            case _:
              two_move
        case _:
          one_move
    case _:
      _queue3(immediate, _wait_action(), _wait_action())

def _find_one_move_plan(enemy: Pos, player: Pos, dir: U32) -> List(Action):
  match dir:
    case 4:
      _queue_waits()
    case d:
      pos1 = _step_free(enemy, d);
      same = _pos_eq(pos1, enemy);
      match same:
        case 0:
          attack = _find_attack(pos1, player);
          hit = _action_is_attack(attack);
          match hit:
            case 0:
              _find_one_move_plan(enemy, player, d + 1)
            case _:
              _queue3(_move_action(d), attack, _wait_action())
        case _:
          _find_one_move_plan(enemy, player, d + 1)

def _find_two_move_plan(enemy: Pos, player: Pos, dir1: U32) -> List(Action):
  match dir1:
    case 4:
      _queue_waits()
    case d1:
      pos1 = _step_free(enemy, d1);
      same = _pos_eq(pos1, enemy);
      match same:
        case 0:
          plan = _find_two_move_from(enemy, player, d1, pos1, 0);
          hit = _queue_has_attack(plan);
          match hit:
            case 0:
              _find_two_move_plan(enemy, player, d1 + 1)
            case _:
              plan
        case _:
          _find_two_move_plan(enemy, player, d1 + 1)

def _find_two_move_from(enemy: Pos, player: Pos, dir1: U32, pos1: Pos, dir2: U32) -> List(Action):
  match dir2:
    case 4:
      _queue_waits()
    case d2:
      pos2 = _step_free(pos1, d2);
      same = _pos_eq(pos2, pos1);
      match same:
        case 0:
          attack = _find_attack(pos2, player);
          hit = _action_is_attack(attack);
          match hit:
            case 0:
              _find_two_move_from(enemy, player, dir1, pos1, d2 + 1)
            case _:
              _queue3(_move_action(dir1), _move_action(d2), attack)
        case _:
          _find_two_move_from(enemy, player, dir1, pos1, d2 + 1)

def _fallback_plan(round: U32, enemy: Pos, player: Pos) -> List(Action):
  skill = _round_skill(round);
  dir1 = _chase_dir(enemy, player);
  pos1 = _step_or_stay(enemy, dir1);
  dir2 = _chase_dir(pos1, player);
  pos2 = _step_or_stay(pos1, dir2);
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
      origin = _origin_from_anchor(actor, anchor);
      valid = _placement_valid(skill, rot, origin, actor);
      match valid:
        case 0:
          _first_valid_attack_anchor(skill, actor, rot, idx + 1)
        case _:
          _attack_action(skill, anchor, rot)
    case _:
      _wait_action()

def _find_attack(actor: Pos, target: Pos) -> Action:
  attack1 = _find_attack_rot(actor, target, 1, 0);
  hit1 = _action_is_attack(attack1);
  match hit1:
    case 0:
      attack2 = _find_attack_rot(actor, target, 2, 0);
      hit2 = _action_is_attack(attack2);
      match hit2:
        case 0:
          _find_attack_rot(actor, target, 3, 0)
        case _:
          attack2
    case _:
      attack1

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
      origin = _origin_from_anchor(actor, anchor);
      hit = _attack_hits(skill, rot, origin, actor, target);
      match hit:
        case 0:
          _find_attack_anchor(actor, target, skill, rot, idx + 1)
        case _:
          _attack_action(skill, anchor, rot)
    case _:
      _wait_action()

def _resolve_player_action_state(state: GameState, action: Action) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      stopped = winner | _hp_empty(player_hp);
      match stopped:
        case 0:
          _resolve_player_action(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner, action)
        case _:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)

def _resolve_enemy_action_state(state: GameState, action: Action) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      stopped = winner | _hp_empty(enemy_hp);
      match stopped:
        case 0:
          _resolve_enemy_action(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner, action)
        case _:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)

def _resolve_player_action(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, action: Action,
) -> GameState:
  match action:
    case wait{}:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
    case move{dir}:
      _state(round, level, player_hp, enemy_hp, _step_blocked(player, dir, enemy), enemy, queue, queue_len, queue_locked, mode, winner)
    case attack{skill, anchor, rot}:
      origin = _origin_from_anchor(player, anchor);
      hit = _attack_hits(skill, rot, origin, player, enemy);
      match hit:
        case 0:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
        case _:
          next_enemy_hp = _damage_hp(enemy_hp);
          next_winner = _compute_winner(player_hp, next_enemy_hp);
          _state(round, level, player_hp, next_enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, next_winner)

def _resolve_enemy_action(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32, action: Action,
) -> GameState:
  match action:
    case wait{}:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
    case move{dir}:
      _state(round, level, player_hp, enemy_hp, player, _step_blocked(enemy, dir, player), queue, queue_len, queue_locked, mode, winner)
    case attack{skill, anchor, rot}:
      origin = _origin_from_anchor(enemy, anchor);
      hit = _attack_hits(skill, rot, origin, enemy, player);
      match hit:
        case 0:
          _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)
        case _:
          next_player_hp = _damage_hp(player_hp);
          next_winner = _compute_winner(next_player_hp, enemy_hp);
          _state(round, level, next_player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, next_winner)

def _simulate_player_action(state: GameState, action: Action) -> ActionSim:
  match state action:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner} wait{}:
      current_state = _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner);
      _action_sim(player, player, enemy, _pos_nil(), current_state, 0, 0, 0)
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner} move{dir}:
      current_state = _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner);
      next_state = _resolve_player_action_state(current_state, move{dir});
      _action_sim(player, _state_player(next_state), enemy, _pos_nil(), next_state, 0, 0, 0)
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner} attack{skill, anchor, rot}:
      current_state = _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner);
      origin = _origin_from_anchor(player, anchor);
      attack_tiles = _preview_hits_for(skill, rot, origin, player, 0);
      hit = _attack_hits(skill, rot, origin, player, enemy);
      next_state = _resolve_player_action_state(current_state, attack{skill, anchor, rot});
      enemy_died = _died_between(enemy_hp, _state_enemy_hp(next_state));
      _action_sim(player, player, enemy, attack_tiles, next_state, hit, 0, enemy_died)

def _simulate_enemy_action(state: GameState, action: Action) -> ActionSim:
  match state action:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner} wait{}:
      current_state = _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner);
      _action_sim(enemy, enemy, player, _pos_nil(), current_state, 0, 0, 0)
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner} move{dir}:
      current_state = _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner);
      next_state = _resolve_enemy_action_state(current_state, move{dir});
      _action_sim(enemy, _state_enemy(next_state), player, _pos_nil(), next_state, 0, 0, 0)
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner} attack{skill, anchor, rot}:
      current_state = _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner);
      origin = _origin_from_anchor(enemy, anchor);
      attack_tiles = _preview_hits_for(skill, rot, origin, enemy, 0);
      hit = _attack_hits(skill, rot, origin, enemy, player);
      next_state = _resolve_enemy_action_state(current_state, attack{skill, anchor, rot});
      player_died = _died_between(player_hp, _state_player_hp(next_state));
      _action_sim(enemy, enemy, player, attack_tiles, next_state, hit, player_died, 0)

def _action_sim(
  from: Pos, to: Pos, target_pos: Pos, attack_tiles: List(Pos),
  next_state: GameState, hit: U32, player_died: U32, enemy_died: U32,
) -> ActionSim:
  action_sim{from, to, target_pos, attack_tiles, next_state, hit, player_died, enemy_died}

def _reset_round_planning_state(state: GameState) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, _, _, _, _, winner}:
      _reset_round_planning_w(round, level, player_hp, enemy_hp, player, enemy, winner)

def _reset_round_planning_w(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, winner: U32,
) -> GameState:
  next_round = _round_after_reset(round, winner);
  _state(next_round, level, player_hp, enemy_hp, player, enemy, _queue_waits(), 0, 0, _plan_mode(), winner)

def _round_after_reset(round: U32, winner: U32) -> U32:
  match winner:
    case 0:
      round + 1
    case _:
      round

def _damage_hp(hp: U32) -> U32:
  _sub_floor(hp, 10)

def _hp_empty(hp: U32) -> U32:
  match hp:
    case 0:
      1
    case _:
      0

def _died_between(before: U32, after: U32) -> U32:
  (1 ^ _hp_empty(before)) & _hp_empty(after)

def _compute_winner(player_hp: U32, enemy_hp: U32) -> U32:
  both = _hp_empty(player_hp) & _hp_empty(enemy_hp);
  match both:
    case 0:
      player_dead = _hp_empty(player_hp);
      match player_dead:
        case 0:
          enemy_dead = _hp_empty(enemy_hp);
          match enemy_dead:
            case 0:
              0
            case _:
              1
        case _:
          2
    case _:
      3

def _round_skill(round: U32) -> U32:
  match round % 3:
    case 1:
      1
    case 2:
      2
    case _:
      3

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
    case game_state{_, _, _, _, _, _, queue, _, _, _, _}:
      queue

def _state_player(state: GameState) -> Pos:
  match state:
    case game_state{_, _, _, _, player, _, _, _, _, _, _}:
      player

def _state_enemy(state: GameState) -> Pos:
  match state:
    case game_state{_, _, _, _, _, enemy, _, _, _, _, _}:
      enemy

def _state_player_hp(state: GameState) -> U32:
  match state:
    case game_state{_, _, player_hp, _, _, _, _, _, _, _, _}:
      player_hp

def _state_enemy_hp(state: GameState) -> U32:
  match state:
    case game_state{_, _, _, enemy_hp, _, _, _, _, _, _, _}:
      enemy_hp

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

def _action_is_attack(action: Action) -> U32:
  kind = _action_kind(action);
  match kind:
    case 2:
      1
    case _:
      0

def _mode_is_plan(mode: Mode) -> U32:
  match mode:
    case plan{}:
      1
    case _:
      0

def _mode_is_target(mode: Mode) -> U32:
  match mode:
    case target{_, _, _}:
      1
    case _:
      0

def _mode_skill(mode: Mode) -> U32:
  match mode:
    case target{skill, _, _}:
      skill
    case _:
      0

def _mode_rot(mode: Mode) -> U32:
  match mode:
    case target{_, rot, _}:
      rot
    case _:
      0

def _mode_origin(mode: Mode) -> Pos:
  match mode:
    case target{_, _, origin}:
      origin
    case _:
      pos{0, 0}

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

def _step_blocked(pos: Pos, dir: U32, other: Pos) -> Pos:
  next = _step_free(pos, dir);
  same = _pos_eq(next, other);
  match same:
    case 0:
      next
    case _:
      pos

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

def _abs_diff(a: U32, b: U32) -> U32:
  _sub_floor(a, b) + _sub_floor(b, a)

# App logic

def ready_round_state(state: GameState) -> GameState:
  match state:
    case game_state{round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner}:
      _ready_round_state_w(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)

def _ready_round_state_w(
  round: U32, level: U32, player_hp: U32, enemy_hp: U32,
  player: Pos, enemy: Pos, queue: List(Action),
  queue_len: U32, queue_locked: U32, mode: Mode, winner: U32,
) -> GameState:
  match winner | _mode_is_target(mode):
    case 0:
      _ready_round_state_run(
        _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner),
        queue,
        _build_bot_plan_w(round, player_hp, enemy_hp, player, enemy, winner)
      )
    case _:
      _state(round, level, player_hp, enemy_hp, player, enemy, queue, queue_len, queue_locked, mode, winner)

def _ready_round_state_run(current: GameState, player_queue: List(Action), bot_queue: List(Action)) -> GameState:
  s1 = _resolve_player_action_state(current, _action_at(player_queue, 0));
  s2 = _resolve_enemy_action_state(s1, _action_at(bot_queue, 0));
  s3 = _resolve_player_action_state(s2, _action_at(player_queue, 1));
  s4 = _resolve_enemy_action_state(s3, _action_at(bot_queue, 1));
  s5 = _resolve_player_action_state(s4, _action_at(player_queue, 2));
  s6 = _resolve_enemy_action_state(s5, _action_at(bot_queue, 2));
  _reset_round_planning_state(s6)

def _confirm_and_ready_state(state: GameState) -> GameState:
  active = _state_target_active(state);
  match active:
    case 0:
      state
    case _:
      valid = target_valid(state);
      match valid:
        case 0:
          state
        case _:
          ready_round_state(confirm_target_state(state))

def _move_input_state(state: GameState, dir: U32) -> GameState:
  active = _state_target_active(state);
  match active:
    case 0:
      queue_move_state(state, dir)
    case _:
      move_target_state(state, dir)

def _rotate_input_state(state: GameState, clockwise: U32) -> GameState:
  active = _state_target_active(state);
  match active:
    case 0:
      state
    case _:
      rotate_target_state(state, clockwise)

def _escape_input_state(state: GameState) -> GameState:
  active = _state_target_active(state);
  match active:
    case 0:
      pop_last_planned_action_state(state)
    case _:
      cancel_target_state(state)

def _skill_input_state(state: GameState, skill: U32) -> GameState:
  start_target_state(state, skill)

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

def on_event(evt: FightEvent, state: GameState) -> GameState:
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
      _skill_input_state(state, 1)
    case evt_skill_2{}:
      _skill_input_state(state, 2)
    case evt_skill_3{}:
      _skill_input_state(state, 3)
    case evt_rotate_left{}:
      _rotate_input_state(state, 0)
    case evt_rotate_right{}:
      _rotate_input_state(state, 1)
    case evt_confirm{}:
      _confirm_and_ready_state(state)
    case evt_ready{}:
      ready_round_state(state)
    case evt_escape{}:
      _escape_input_state(state)
    case evt_clear{}:
      clear_round_plan_state(state)
    case evt_reset{}:
      state_init()
    case evt_ignore{}:
      state

# Rendering helpers

init : GameState =
  state_init()

def render(state: GameState) -> HTML(FightEvent):
  planned = planned_player_pos(state);
  trail = movement_trail(state);
  preview = preview_tiles(state);
  hits = preview_hits(state);
  valid = target_valid(state);
  board = U32.grid(HTML(FightEvent), 18, 9, _board_cell(state, planned, trail, preview, hits, valid));
  <div class="page">
    <style>{text{css()}}</style>
    <main class="shell" tabindex="0" style="outline:none" on_key_down={key_event}>
      <section class="topbar">
        <div class="topbar__left">
          <div class="chip">{text{"Round " ++ U32.show(_state_round(state))}}</div>
          <div class={_phase_chip_class(state)}>{text{_phase_label(state)}}</div>
        </div>
        <button {..._button_attrs("button button--ghost", evt_reset{})}>
          {text{"Reset"}}
        </button>
      </section>

      <section class="board-wrap">
        <div class="board">{...board}</div>
        {_winner_modal(state)}
      </section>

      <section class="underbar">
        <div class="panel panel--hp">
          <div class="panel__label">Player HP</div>
          <div class="panel__value">{text{_hp_text(_state_player_hp(state))}}</div>
        </div>
        <div class="panel panel--queue">
          <div class="panel__label">Slots</div>
          <div class="queue-row">
            {_queue_slot(state, 0)}
            {_queue_slot(state, 1)}
            {_queue_slot(state, 2)}
          </div>
        </div>
      </section>

      <section class="controls-grid">
        <div class="panel">
          <div class="panel__label">Moves</div>
          <div class="dpad">
            <div></div>
            <button {..._button_attrs("button", evt_move_up{})}>{text{"Up"}}</button>
            <div></div>
            <button {..._button_attrs("button", evt_move_left{})}>{text{"Left"}}</button>
            <button {..._button_attrs("button", evt_move_down{})}>{text{"Down"}}</button>
            <button {..._button_attrs("button", evt_move_right{})}>{text{"Right"}}</button>
          </div>
        </div>

        <div class="panel">
          <div class="panel__label">Skills</div>
          <div class="button-row">
            <button {..._skill_button_attrs(state, 1)}>{text{"Skill 1"}}</button>
            <button {..._skill_button_attrs(state, 2)}>{text{"Skill 2"}}</button>
            <button {..._skill_button_attrs(state, 3)}>{text{"Skill 3"}}</button>
          </div>
          <div class="button-row button-row--compact">
            <button {..._button_attrs("button button--secondary", evt_rotate_left{})}>{text{"Q"}}</button>
            <button {..._confirm_button_attrs(state)}>{text{"Space"}}</button>
            <button {..._button_attrs("button button--secondary", evt_rotate_right{})}>{text{"E"}}</button>
          </div>
        </div>

        <div class="panel">
          <div class="panel__label">Actions</div>
          <div class="button-row">
            <button {..._button_attrs("button", evt_ready{})}>{text{"Ready"}}</button>
            <button {..._button_attrs("button button--secondary", evt_clear{})}>{text{"Clear"}}</button>
            <button {..._button_attrs("button button--secondary", evt_escape{})}>{text{"Esc"}}</button>
          </div>
        </div>
      </section>

      <section class="info-grid">
        <div class="panel">
          <div class="panel__label">State</div>
          <p class="help">{text{_mode_text(state)}}</p>
          <p class="help">{text{"Player preview: " ++ _pos_text(planned)}}</p>
          <p class="help">{text{"Enemy HP: " ++ _hp_text(_state_enemy_hp(state))}}</p>
        </div>
        <div class="panel">
          <div class="panel__label">Controls</div>
          <p class="help">{text{"WASD/setas movem ou mexem a mira. 1/2/3 entram na mira. Q/E giram. Space confirma e resolve. Enter da ready. Esc cancela ou desfaz."}}</p>
        </div>
      </section>
    </main>
  </div>

def _queue_slot(state: GameState, idx: U32) -> HTML(FightEvent):
  <div class="queue-slot">
    <div class="queue-slot__index">{text{"Slot " ++ U32.show(idx + 1)}}</div>
    <div class="queue-slot__value">{text{_action_label(_action_at(_state_queue(state), idx))}}</div>
  </div>

def _board_cell(
  state: GameState,
  planned: Pos,
  trail: List(TrailStep),
  preview: List(Pos),
  hits: List(Pos),
  valid: U32,
  x: U32,
  y: U32,
) -> HTML(FightEvent):
  _board_cell_at(state, planned, trail, preview, hits, valid, pos{x, y})

def _board_cell_at(
  state: GameState,
  planned: Pos,
  trail: List(TrailStep),
  preview: List(Pos),
  hits: List(Pos),
  valid: U32,
  cell_pos: Pos,
) -> HTML(FightEvent):
  <div class={_board_cell_class(state, planned, trail, preview, hits, valid, cell_pos)}>
    {_board_cell_actor(state, cell_pos)}
    {_board_cell_ghost(state, planned, cell_pos)}
    {_board_cell_route(trail, cell_pos)}
  </div>

def _board_cell_class(
  state: GameState,
  planned: Pos,
  trail: List(TrailStep),
  preview: List(Pos),
  hits: List(Pos),
  valid: U32,
  pos: Pos,
) -> String:
  ""
  ++ "cell"
  ++ _board_cell_preview_class(preview, valid, pos)
  ++ _board_cell_hit_class(hits, pos)
  ++ _board_cell_route_class(trail, pos)

def _board_cell_preview_class(preview: List(Pos), valid: U32, cell_pos: Pos) -> String:
  _board_cell_preview_class_hit(_pos_list_has(preview, cell_pos), valid)

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

def _board_cell_hit_class(hits: List(Pos), cell_pos: Pos) -> String:
  _board_cell_hit_class_hit(_pos_list_has(hits, cell_pos))

def _board_cell_hit_class_hit(hit: U32) -> String:
  match hit:
    case 0:
      ""
    case _:
      " cell--hit"

def _board_cell_route_class(trail: List(TrailStep), cell_pos: Pos) -> String:
  _board_cell_route_class_step(_trail_step_at(trail, cell_pos))

def _board_cell_route_class_step(step: U32) -> String:
  match step:
    case 0:
      ""
    case _:
      " cell--route"

def _board_cell_actor(state: GameState, cell_pos: Pos) -> HTML(FightEvent):
  match _pos_eq(_state_player(state), cell_pos):
    case 0:
      _board_cell_enemy_actor(_pos_eq(_state_enemy(state), cell_pos), _hp_empty(_state_enemy_hp(state)), _state_enemy_hp(state))
    case _:
      <div class="actor actor--player">{text{"P"}}</div>

def _board_cell_enemy_actor(enemy_here: U32, enemy_dead: U32, enemy_hp: U32) -> HTML(FightEvent):
  match enemy_here:
    case 0:
      <div class="cell__actor-wrap"></div>
    case _:
      _board_cell_enemy_alive(enemy_dead, enemy_hp)

def _board_cell_enemy_alive(enemy_dead: U32, enemy_hp: U32) -> HTML(FightEvent):
  match enemy_dead:
    case 0:
      <div class="actor actor--enemy">{text{_hp_text(enemy_hp)}}</div>
    case _:
      <div class="cell__actor-wrap"></div>

def _board_cell_ghost(state: GameState, planned: Pos, cell_pos: Pos) -> HTML(FightEvent):
  _board_cell_ghost_flags(_pos_eq(_state_player(state), planned), _pos_eq(planned, cell_pos))

def _board_cell_ghost_flags(same_now: U32, same_cell: U32) -> HTML(FightEvent):
  match same_cell:
    case 0:
      <div class="ghost ghost--hidden"></div>
    case _:
      _board_cell_ghost_now(same_now)

def _board_cell_ghost_now(same_now: U32) -> HTML(FightEvent):
  match same_now:
    case 0:
      <div class="ghost">{text{"P"}}</div>
    case _:
      <div class="ghost ghost--hidden"></div>

def _board_cell_route(trail: List(TrailStep), cell_pos: Pos) -> HTML(FightEvent):
  _board_cell_route_step(_trail_step_at(trail, cell_pos))

def _board_cell_route_step(step: U32) -> HTML(FightEvent):
  match step:
    case 0:
      <div class="trail trail--hidden"></div>
    case s:
      <div class="trail">{text{U32.show(s)}}</div>

def _winner_modal(state: GameState) -> HTML(FightEvent):
  _winner_modal_w(_state_winner(state))

def _winner_modal_w(winner: U32) -> HTML(FightEvent):
  match winner:
    case 0:
      <div class="modal"></div>
    case result:
      <div class="modal modal--visible">
        <div class="modal__card">
          <div class="modal__eyebrow">{text{"Fim da partida"}}</div>
          <h2 class="modal__title">{text{_winner_title(result)}}</h2>
          <button {..._button_attrs("button", evt_reset{})}>
            {text{"Jogar novamente"}}
          </button>
        </div>
      </div>

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

def _action_label(action: Action) -> String:
  match action:
    case wait{}:
      "Parado"
    case move{dir}:
      "Mover " ++ _dir_label(dir)
    case attack{skill, anchor, rot}:
      "Ataque " ++ U32.show(skill)

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
    case plan{}:
      "Planejando round"
    case target{skill, rot, origin}:
      "Mira da skill " ++ U32.show(skill) ++ " rot " ++ U32.show(rot) ++ " origem " ++ _pos_text(origin)

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
    case plan{}:
      "Planning"
    case target{_, _, _}:
      _phase_label_target(valid)

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
    case plan{}:
      "chip chip--plan"
    case target{_, _, _}:
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

def _hp_text(hp: U32) -> String:
  U32.show(hp) ++ "/50"

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
    case game_state{round, _, _, _, _, _, _, _, _, _, _}:
      round

def _state_winner(state: GameState) -> U32:
  match state:
    case game_state{_, _, _, _, _, _, _, _, _, _, winner}:
      winner

def _state_mode_value(state: GameState) -> Mode:
  match state:
    case game_state{_, _, _, _, _, _, _, _, _, mode, _}:
      mode

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

def base_css() -> String:
  ""
  ++ ":root{--bg:#f3f1ea;--panel:#fbfaf6;--border:#c7c0af;--text:#1f1c17;--muted:#6b6252;--grid:#b5ad98;--cell:#efe8d7;--preview:#d9ecff;--invalid:#f8d2d2;--hit:#ef4d4d;--route:#e6d9a8;--player:#2f63d8;--enemy:#218354;--ghost:#8db1ff;--button:#201d18;--button-alt:#e6dfcf;}"
  ++ "*{box-sizing:border-box;}html,body{margin:0;height:100%;background:var(--bg);color:var(--text);font-family:'Trebuchet MS',sans-serif;}body{overflow:hidden;}button{font:inherit;cursor:pointer;}#app,.page{min-height:100svh;}"

def layout_css() -> String:
  ""
  ++ ".shell{width:min(100%,1200px);min-height:100svh;height:100svh;margin:0 auto;padding:12px;display:grid;grid-template-rows:auto minmax(0,1fr) auto auto auto;gap:12px;overflow:hidden;}"
  ++ ".topbar{display:flex;justify-content:space-between;align-items:center;gap:12px;}.topbar__left{display:flex;align-items:center;gap:8px;flex-wrap:wrap;}.chip{display:inline-flex;align-items:center;justify-content:center;padding:8px 12px;border-radius:999px;border:1px solid var(--border);background:var(--panel);font-size:.78rem;font-weight:700;letter-spacing:.04em;text-transform:uppercase;}.chip--plan{background:#f2ead7;}.chip--target{background:#d9ecff;}.chip--over{background:#f8d2d2;}"
  ++ ".board-wrap{position:relative;min-height:0;overflow:auto;border:1px solid var(--border);background:var(--panel);border-radius:18px;padding:12px;}.board{display:grid;grid-template-columns:repeat(18,minmax(0,1fr));min-width:900px;border:1px solid var(--grid);background:var(--grid);gap:1px;}.cell{position:relative;aspect-ratio:1/1;min-width:0;background:var(--cell);display:grid;place-items:center;overflow:hidden;}.cell--preview{background:var(--preview);}.cell--preview-invalid{background:var(--invalid);}.cell--hit{box-shadow:inset 0 0 0 2px var(--hit);}.cell--route{outline:2px solid var(--route);outline-offset:-2px;}"
  ++ ".underbar,.controls-grid,.info-grid{display:grid;gap:12px;}.underbar{grid-template-columns:220px minmax(0,1fr);}.controls-grid{grid-template-columns:1fr 1fr 1fr;}.info-grid{grid-template-columns:1fr 1fr;}.panel{padding:12px;border:1px solid var(--border);border-radius:16px;background:var(--panel);min-width:0;}.panel__label{margin:0 0 10px;color:var(--muted);font-size:.78rem;font-weight:700;letter-spacing:.05em;text-transform:uppercase;}.panel__value{font-size:1.4rem;font-weight:700;}.queue-row,.button-row{display:flex;gap:8px;flex-wrap:wrap;}.button-row--compact{margin-top:8px;}.queue-slot{min-width:0;flex:1;padding:10px;border:1px solid var(--border);border-radius:14px;background:#fff;}.queue-slot__index{font-size:.72rem;color:var(--muted);text-transform:uppercase;font-weight:700;}.queue-slot__value{margin-top:6px;font-weight:700;}"
  ++ ".dpad{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:8px;}.help{margin:0;color:var(--muted);line-height:1.45;}"
  ++ "@media (max-width:980px){.shell{grid-template-rows:auto minmax(0,1fr) auto auto auto;}.underbar,.controls-grid,.info-grid{grid-template-columns:1fr;}}"

def component_css() -> String:
  ""
  ++ ".button{display:inline-flex;align-items:center;justify-content:center;min-height:42px;padding:10px 14px;border:1px solid var(--button);border-radius:12px;background:var(--button);color:#fff;font-weight:700;}.button--secondary{background:var(--button-alt);color:var(--text);border-color:var(--border);}.button--ghost{background:transparent;color:var(--text);border-color:var(--border);}.button--active{outline:2px solid var(--player);outline-offset:1px;}.button:disabled{opacity:.45;cursor:not-allowed;}"
  ++ ".actor{position:relative;z-index:2;display:inline-flex;align-items:center;justify-content:center;min-width:34px;min-height:34px;padding:4px 6px;border-radius:999px;font-weight:700;font-size:.74rem;border:1px solid rgba(0,0,0,.08);}.actor--player{background:var(--player);color:#fff;}.actor--enemy{background:var(--enemy);color:#fff;}"
  ++ ".ghost{position:absolute;inset:auto auto 6px 6px;z-index:1;display:inline-flex;align-items:center;justify-content:center;width:24px;height:24px;border-radius:999px;background:var(--ghost);color:#fff;font-size:.68rem;font-weight:700;opacity:.85;}.ghost--hidden{display:none;}.trail{position:absolute;top:4px;left:4px;z-index:1;display:inline-flex;align-items:center;justify-content:center;min-width:20px;height:20px;padding:0 4px;border-radius:999px;background:#fff;color:var(--text);font-size:.66rem;font-weight:700;border:1px solid var(--border);}.trail--hidden{display:none;}"
  ++ ".modal{position:absolute;inset:0;display:grid;place-items:center;padding:16px;opacity:0;pointer-events:none;background:rgba(20,17,12,0);}.modal--visible{opacity:1;pointer-events:auto;background:rgba(20,17,12,.38);}.modal__card{display:grid;gap:12px;justify-items:center;padding:20px;border-radius:18px;background:#fff;border:1px solid var(--border);min-width:min(100%,280px);}.modal__eyebrow{font-size:.76rem;color:var(--muted);text-transform:uppercase;font-weight:700;}.modal__title{margin:0;font-size:1.5rem;}"

def css() -> String:
  base_css()
  ++ layout_css()
  ++ component_css()

main : App =
  app{GameState, FightEvent, init, render, on_event}
