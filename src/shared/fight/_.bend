import /U32/ as U32

def default_hp() -> U32:
  50

def skill_count() -> U32:
  4

def empty_item_slot() -> U32:
  0

def default_setup_skill(side: U32, slot: U32) -> U32:
  match side slot:
    case _ 0:
      1
    case _ 1:
      2
    case _ 2:
      3
    case _ _:
      0

def default_setup_item(side: U32, slot: U32) -> U32:
  0

def skill_damage(skill: U32) -> U32:
  match skill:
    case 1:
      10
    case 2:
      10
    case 3:
      10
    case 4:
      10
    case _:
      0

def skill_rank(skill: U32) -> U32:
  match skill:
    case 1:
      1
    case 2:
      2
    case 3:
      3
    case 4:
      4
    case _:
      0

def skill_class_id(skill: U32) -> U32:
  match skill:
    case 1:
      0
    case 2:
      0
    case 3:
      0
    case 4:
      0
    case _:
      0

def skill_class_short(skill: U32) -> String:
  skill_class_short_id(skill_class_id(skill))

def skill_class_short_id(class_id: U32) -> String:
  match class_id:
    case 0:
      "Me"
    case 1:
      "Ra"
    case 2:
      "Ma"
    case _:
      "?"

def skill_class_label(skill: U32) -> String:
  skill_class_label_id(skill_class_id(skill))

def skill_class_label_id(class_id: U32) -> String:
  match class_id:
    case 0:
      "Melee"
    case 1:
      "Ranged"
    case 2:
      "Mage"
    case _:
      "Unknown"

def skill_name(skill: U32) -> String:
  rank = skill_rank(skill);
  match rank:
    case 0:
      "?"
    case value:
      skill_class_short(skill) ++ U32.show(value)

def skill_len(skill: U32) -> U32:
  match skill:
    case 1:
      4
    case 2:
      4
    case 3:
      5
    case 4:
      5
    case _:
      0

def skill_point_x(skill: U32, rot: U32, idx: U32) -> U32:
  match skill rot idx:
    case 1 0 0:
      0
    case 1 0 1:
      1
    case 1 0 2:
      2
    case 1 0 3:
      3
    case 1 1 0:
      0
    case 1 1 1:
      0
    case 1 1 2:
      0
    case 1 1 3:
      0
    case 1 2 0:
      0
    case 1 2 1:
      1
    case 1 2 2:
      2
    case 1 2 3:
      3
    case 1 3 0:
      0
    case 1 3 1:
      0
    case 1 3 2:
      0
    case 1 3 3:
      0
    case 2 0 0:
      3
    case 2 0 1:
      2
    case 2 0 2:
      1
    case 2 0 3:
      0
    case 2 1 0:
      0
    case 2 1 1:
      1
    case 2 1 2:
      2
    case 2 1 3:
      3
    case 2 2 0:
      3
    case 2 2 1:
      2
    case 2 2 2:
      1
    case 2 2 3:
      0
    case 2 3 0:
      0
    case 2 3 1:
      1
    case 2 3 2:
      2
    case 2 3 3:
      3
    case 3 _ 0:
      0
    case 3 _ 1:
      2
    case 3 _ 2:
      1
    case 3 _ 3:
      0
    case 3 _ 4:
      2
    case 4 0 0:
      0
    case 4 0 1:
      0
    case 4 0 2:
      0
    case 4 0 3:
      0
    case 4 0 4:
      1
    case 4 1 0:
      3
    case 4 1 1:
      2
    case 4 1 2:
      1
    case 4 1 3:
      0
    case 4 1 4:
      0
    case 4 2 0:
      3
    case 4 2 1:
      3
    case 4 2 2:
      3
    case 4 2 3:
      3
    case 4 2 4:
      2
    case 4 3 0:
      0
    case 4 3 1:
      1
    case 4 3 2:
      2
    case 4 3 3:
      3
    case 4 3 4:
      3
    case _ _ _:
      0

def skill_point_y(skill: U32, rot: U32, idx: U32) -> U32:
  match skill rot idx:
    case 1 0 0:
      0
    case 1 0 1:
      0
    case 1 0 2:
      0
    case 1 0 3:
      0
    case 1 1 0:
      0
    case 1 1 1:
      1
    case 1 1 2:
      2
    case 1 1 3:
      3
    case 1 2 0:
      0
    case 1 2 1:
      0
    case 1 2 2:
      0
    case 1 2 3:
      0
    case 1 3 0:
      0
    case 1 3 1:
      1
    case 1 3 2:
      2
    case 1 3 3:
      3
    case 2 0 0:
      0
    case 2 0 1:
      1
    case 2 0 2:
      2
    case 2 0 3:
      3
    case 2 1 0:
      0
    case 2 1 1:
      1
    case 2 1 2:
      2
    case 2 1 3:
      3
    case 2 2 0:
      0
    case 2 2 1:
      1
    case 2 2 2:
      2
    case 2 2 3:
      3
    case 2 3 0:
      0
    case 2 3 1:
      1
    case 2 3 2:
      2
    case 2 3 3:
      3
    case 3 _ 0:
      0
    case 3 _ 1:
      0
    case 3 _ 2:
      1
    case 3 _ 3:
      2
    case 3 _ 4:
      2
    case 4 0 0:
      0
    case 4 0 1:
      1
    case 4 0 2:
      2
    case 4 0 3:
      3
    case 4 0 4:
      3
    case 4 1 0:
      0
    case 4 1 1:
      0
    case 4 1 2:
      0
    case 4 1 3:
      0
    case 4 1 4:
      1
    case 4 2 0:
      3
    case 4 2 1:
      2
    case 4 2 2:
      1
    case 4 2 3:
      0
    case 4 2 4:
      0
    case 4 3 0:
      3
    case 4 3 1:
      3
    case 4 3 2:
      3
    case 4 3 3:
      3
    case 4 3 4:
      2
    case _ _ _:
      0
