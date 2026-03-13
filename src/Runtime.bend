# Runtime.bend
# ============
# Static fight data exported to JS through the Bend compiler.

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

def rules_get() -> Rules:
  rules{
    18,
    9,
    pos{6, 4},
    pos{11, 4},
    50,
    10,
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
