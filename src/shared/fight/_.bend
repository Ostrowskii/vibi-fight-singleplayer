import /U32/ as U32

def default_hp() -> U32:
  50

def skill_count() -> U32:
  8

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
    case 5:
      0
    case 6:
      0
    case 7:
      0
    case 8:
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
    case 5:
      1
    case 6:
      2
    case 7:
      5
    case 8:
      1
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
    case 5:
      2
    case 6:
      2
    case 7:
      0
    case 8:
      1
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
  match skill:
    case 1:
      "Me1"
    case 2:
      "Me2"
    case 3:
      "Me3"
    case 4:
      "Me4"
    case 5:
      "Ma1"
    case 6:
      "Ma2"
    case 7:
      "Me5"
    case 8:
      "Ra1"
    case _:
      "?"

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
    case 5:
      8
    case 6:
      8
    case 7:
      7
    case 8:
      14
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
    case 5 0 0:
      1
    case 5 0 1:
      0
    case 5 0 2:
      1
    case 5 0 3:
      6
    case 5 0 4:
      5
    case 5 0 5:
      6
    case 5 0 6:
      7
    case 5 0 7:
      6
    case 5 1 0:
      2
    case 5 1 1:
      1
    case 5 1 2:
      0
    case 5 1 3:
      2
    case 5 1 4:
      1
    case 5 1 5:
      1
    case 5 1 6:
      1
    case 5 1 7:
      0
    case 5 2 0:
      6
    case 5 2 1:
      7
    case 5 2 2:
      6
    case 5 2 3:
      1
    case 5 2 4:
      2
    case 5 2 5:
      1
    case 5 2 6:
      0
    case 5 2 7:
      1
    case 5 3 0:
      0
    case 5 3 1:
      1
    case 5 3 2:
      2
    case 5 3 3:
      0
    case 5 3 4:
      1
    case 5 3 5:
      1
    case 5 3 6:
      1
    case 5 3 7:
      2
    case 6 0 0:
      1
    case 6 0 1:
      0
    case 6 0 2:
      1
    case 6 0 3:
      6
    case 6 0 4:
      5
    case 6 0 5:
      6
    case 6 0 6:
      7
    case 6 0 7:
      6
    case 6 1 0:
      2
    case 6 1 1:
      1
    case 6 1 2:
      0
    case 6 1 3:
      2
    case 6 1 4:
      1
    case 6 1 5:
      1
    case 6 1 6:
      1
    case 6 1 7:
      0
    case 6 2 0:
      6
    case 6 2 1:
      7
    case 6 2 2:
      6
    case 6 2 3:
      1
    case 6 2 4:
      2
    case 6 2 5:
      1
    case 6 2 6:
      0
    case 6 2 7:
      1
    case 6 3 0:
      0
    case 6 3 1:
      1
    case 6 3 2:
      2
    case 6 3 3:
      0
    case 6 3 4:
      1
    case 6 3 5:
      1
    case 6 3 6:
      1
    case 6 3 7:
      2
    case 7 0 0:
      0
    case 7 0 1:
      1
    case 7 0 2:
      2
    case 7 0 3:
      3
    case 7 0 4:
      4
    case 7 0 5:
      5
    case 7 0 6:
      6
    case 7 1 0:
      0
    case 7 1 1:
      0
    case 7 1 2:
      0
    case 7 1 3:
      0
    case 7 1 4:
      0
    case 7 1 5:
      0
    case 7 1 6:
      0
    case 7 2 0:
      0
    case 7 2 1:
      1
    case 7 2 2:
      2
    case 7 2 3:
      3
    case 7 2 4:
      4
    case 7 2 5:
      5
    case 7 2 6:
      6
    case 7 3 0:
      0
    case 7 3 1:
      0
    case 7 3 2:
      0
    case 7 3 3:
      0
    case 7 3 4:
      0
    case 7 3 5:
      0
    case 7 3 6:
      0
    case 8 0 0:
      2
    case 8 0 1:
      1
    case 8 0 2:
      0
    case 8 0 3:
      1
    case 8 0 4:
      2
    case 8 0 5:
      6
    case 8 0 6:
      6
    case 8 0 7:
      4
    case 8 0 8:
      5
    case 8 0 9:
      6
    case 8 0 10:
      7
    case 8 0 11:
      8
    case 8 0 12:
      6
    case 8 0 13:
      6
    case 8 1 0:
      4
    case 8 1 1:
      3
    case 8 1 2:
      2
    case 8 1 3:
      1
    case 8 1 4:
      0
    case 8 1 5:
      4
    case 8 1 6:
      3
    case 8 1 7:
      2
    case 8 1 8:
      2
    case 8 1 9:
      2
    case 8 1 10:
      2
    case 8 1 11:
      2
    case 8 1 12:
      1
    case 8 1 13:
      0
    case 8 2 0:
      6
    case 8 2 1:
      7
    case 8 2 2:
      8
    case 8 2 3:
      7
    case 8 2 4:
      6
    case 8 2 5:
      2
    case 8 2 6:
      2
    case 8 2 7:
      4
    case 8 2 8:
      3
    case 8 2 9:
      2
    case 8 2 10:
      1
    case 8 2 11:
      0
    case 8 2 12:
      2
    case 8 2 13:
      2
    case 8 3 0:
      0
    case 8 3 1:
      1
    case 8 3 2:
      2
    case 8 3 3:
      3
    case 8 3 4:
      4
    case 8 3 5:
      0
    case 8 3 6:
      1
    case 8 3 7:
      2
    case 8 3 8:
      2
    case 8 3 9:
      2
    case 8 3 10:
      2
    case 8 3 11:
      2
    case 8 3 12:
      3
    case 8 3 13:
      4
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
    case 5 0 0:
      0
    case 5 0 1:
      1
    case 5 0 2:
      2
    case 5 0 3:
      0
    case 5 0 4:
      1
    case 5 0 5:
      1
    case 5 0 6:
      1
    case 5 0 7:
      2
    case 5 1 0:
      1
    case 5 1 1:
      0
    case 5 1 2:
      1
    case 5 1 3:
      6
    case 5 1 4:
      5
    case 5 1 5:
      6
    case 5 1 6:
      7
    case 5 1 7:
      6
    case 5 2 0:
      2
    case 5 2 1:
      1
    case 5 2 2:
      0
    case 5 2 3:
      2
    case 5 2 4:
      1
    case 5 2 5:
      1
    case 5 2 6:
      1
    case 5 2 7:
      0
    case 5 3 0:
      6
    case 5 3 1:
      7
    case 5 3 2:
      6
    case 5 3 3:
      1
    case 5 3 4:
      2
    case 5 3 5:
      1
    case 5 3 6:
      0
    case 5 3 7:
      1
    case 6 0 0:
      0
    case 6 0 1:
      1
    case 6 0 2:
      2
    case 6 0 3:
      0
    case 6 0 4:
      1
    case 6 0 5:
      1
    case 6 0 6:
      1
    case 6 0 7:
      2
    case 6 1 0:
      1
    case 6 1 1:
      0
    case 6 1 2:
      1
    case 6 1 3:
      6
    case 6 1 4:
      5
    case 6 1 5:
      6
    case 6 1 6:
      7
    case 6 1 7:
      6
    case 6 2 0:
      2
    case 6 2 1:
      1
    case 6 2 2:
      0
    case 6 2 3:
      2
    case 6 2 4:
      1
    case 6 2 5:
      1
    case 6 2 6:
      1
    case 6 2 7:
      0
    case 6 3 0:
      6
    case 6 3 1:
      7
    case 6 3 2:
      6
    case 6 3 3:
      1
    case 6 3 4:
      2
    case 6 3 5:
      1
    case 6 3 6:
      0
    case 6 3 7:
      1
    case 7 0 0:
      0
    case 7 0 1:
      0
    case 7 0 2:
      0
    case 7 0 3:
      0
    case 7 0 4:
      0
    case 7 0 5:
      0
    case 7 0 6:
      0
    case 7 1 0:
      0
    case 7 1 1:
      1
    case 7 1 2:
      2
    case 7 1 3:
      3
    case 7 1 4:
      4
    case 7 1 5:
      5
    case 7 1 6:
      6
    case 7 2 0:
      0
    case 7 2 1:
      0
    case 7 2 2:
      0
    case 7 2 3:
      0
    case 7 2 4:
      0
    case 7 2 5:
      0
    case 7 2 6:
      0
    case 7 3 0:
      0
    case 7 3 1:
      1
    case 7 3 2:
      2
    case 7 3 3:
      3
    case 7 3 4:
      4
    case 7 3 5:
      5
    case 7 3 6:
      6
    case 8 0 0:
      0
    case 8 0 1:
      1
    case 8 0 2:
      2
    case 8 0 3:
      3
    case 8 0 4:
      4
    case 8 0 5:
      0
    case 8 0 6:
      1
    case 8 0 7:
      2
    case 8 0 8:
      2
    case 8 0 9:
      2
    case 8 0 10:
      2
    case 8 0 11:
      2
    case 8 0 12:
      3
    case 8 0 13:
      4
    case 8 1 0:
      2
    case 8 1 1:
      1
    case 8 1 2:
      0
    case 8 1 3:
      1
    case 8 1 4:
      2
    case 8 1 5:
      6
    case 8 1 6:
      6
    case 8 1 7:
      4
    case 8 1 8:
      5
    case 8 1 9:
      6
    case 8 1 10:
      7
    case 8 1 11:
      8
    case 8 1 12:
      6
    case 8 1 13:
      6
    case 8 2 0:
      4
    case 8 2 1:
      3
    case 8 2 2:
      2
    case 8 2 3:
      1
    case 8 2 4:
      0
    case 8 2 5:
      4
    case 8 2 6:
      3
    case 8 2 7:
      2
    case 8 2 8:
      2
    case 8 2 9:
      2
    case 8 2 10:
      2
    case 8 2 11:
      2
    case 8 2 12:
      1
    case 8 2 13:
      0
    case 8 3 0:
      6
    case 8 3 1:
      7
    case 8 3 2:
      8
    case 8 3 3:
      7
    case 8 3 4:
      6
    case 8 3 5:
      2
    case 8 3 6:
      2
    case 8 3 7:
      4
    case 8 3 8:
      3
    case 8 3 9:
      2
    case 8 3 10:
      1
    case 8 3 11:
      0
    case 8 3 12:
      2
    case 8 3 13:
      2
    case _ _ _:
      0

def skill_player_mask(skill: U32, idx: U32) -> U32:
  match skill idx:
    case 5 0:
      1
    case 5 1:
      1
    case 5 2:
      1
    case 6 0:
      1
    case 6 1:
      1
    case 6 2:
      1
    case 8 0:
      1
    case 8 1:
      1
    case 8 2:
      1
    case 8 3:
      1
    case 8 4:
      1
    case _ _:
      0

def skill_effect_mask(skill: U32, idx: U32) -> U32:
  match skill idx:
    case 1 _:
      1
    case 2 _:
      1
    case 3 _:
      1
    case 4 _:
      1
    case 5 3:
      4
    case 5 4:
      4
    case 5 5:
      4
    case 5 6:
      4
    case 5 7:
      4
    case 6 3:
      8
    case 6 4:
      8
    case 6 5:
      8
    case 6 6:
      8
    case 6 7:
      8
    case 7 _:
      2
    case 8 5:
      1
    case 8 6:
      1
    case 8 7:
      1
    case 8 8:
      1
    case 8 9:
      1
    case 8 10:
      1
    case 8 11:
      1
    case 8 12:
      1
    case 8 13:
      1
    case _ _:
      0

def effect_has(mask: U32, flag: U32) -> U32:
  match mask & flag:
    case 0:
      0
    case _:
      1

def effect_damage(mask: U32) -> U32:
  effect_has(mask, 1)

def effect_hook(mask: U32) -> U32:
  effect_has(mask, 2)

def effect_ice(mask: U32) -> U32:
  effect_has(mask, 4)

def effect_fire(mask: U32) -> U32:
  effect_has(mask, 8)

def skill_hook_pull(skill: U32) -> U32:
  match skill:
    case _:
      4
