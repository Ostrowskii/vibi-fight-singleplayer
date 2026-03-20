import /U32/ as U32

def default_hp() -> U32:
  50

def skill_count() -> U32:
  34

def empty_item_slot() -> U32:
  0

def default_setup_skill(side: U32, slot: U32) -> U32:
  match side slot:
    case _ 0:
      2
    case _ 1:
      3
    case _ 2:
      4
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
    case 9:
      0
    case 10:
      10
    case 11:
      10
    case 12:
      10
    case 13:
      10
    case 14:
      10
    case 15:
      10
    case 16:
      10
    case 17:
      10
    case 18:
      10
    case 19:
      10
    case 20:
      10
    case 21:
      10
    case 22:
      10
    case 23:
      10
    case 24:
      10
    case 25:
      10
    case 26:
      10
    case 27:
      10
    case 28:
      10
    case 29:
      10
    case 30:
      10
    case 31:
      10
    case 32:
      10
    case 33:
      10
    case 34:
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
    case 9:
      3
    case 10:
      2
    case 11:
      3
    case 12:
      4
    case 13:
      5
    case 14:
      6
    case 15:
      7
    case 16:
      8
    case 17:
      10
    case 18:
      11
    case 19:
      12
    case 20:
      13
    case 21:
      6
    case 22:
      7
    case 23:
      8
    case 24:
      9
    case 25:
      10
    case 26:
      11
    case 27:
      4
    case 28:
      5
    case 29:
      6
    case 30:
      7
    case 31:
      8
    case 32:
      9
    case 33:
      10
    case 34:
      0
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
    case 9:
      2
    case 10:
      1
    case 11:
      1
    case 12:
      1
    case 13:
      1
    case 14:
      0
    case 15:
      0
    case 16:
      0
    case 17:
      0
    case 18:
      0
    case 19:
      0
    case 20:
      0
    case 21:
      1
    case 22:
      1
    case 23:
      1
    case 24:
      1
    case 25:
      1
    case 26:
      1
    case 27:
      2
    case 28:
      2
    case 29:
      2
    case 30:
      2
    case 31:
      2
    case 32:
      2
    case 33:
      2
    case 34:
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
    case 9:
      "Ma3"
    case 10:
      "Ra2"
    case 11:
      "Ra3"
    case 12:
      "Ra4"
    case 13:
      "Ra5"
    case 14:
      "Me6"
    case 15:
      "Me7"
    case 16:
      "Me8"
    case 17:
      "Me10"
    case 18:
      "Me11"
    case 19:
      "Me12"
    case 20:
      "Me13"
    case 21:
      "Ra6"
    case 22:
      "Ra7"
    case 23:
      "Ra8"
    case 24:
      "Ra9"
    case 25:
      "Ra10"
    case 26:
      "Ra11"
    case 27:
      "Ma4"
    case 28:
      "Ma5"
    case 29:
      "Ma6"
    case 30:
      "Ma7"
    case 31:
      "Ma8"
    case 32:
      "Ma9"
    case 33:
      "Ma10"
    case 34:
      "Me0"
    case _:
      "?"

def cell_attack() -> U32:
  1

def cell_dist_attack() -> U32:
  1

def cell_hook() -> U32:
  2

def cell_ice() -> U32:
  4

def cell_fire() -> U32:
  8

def cell_player() -> U32:
  16

def skill_base_w(skill: U32) -> U32:
  match skill:
    case 1:
      4
    case 2:
      4
    case 3:
      3
    case 4:
      4
    case 5:
      8
    case 6:
      8
    case 7:
      7
    case 8:
      9
    case 9:
      7
    case 10:
      9
    case 11:
      9
    case 12:
      9
    case 13:
      9
    case 14:
      5
    case 15:
      3
    case 16:
      3
    case 17:
      3
    case 18:
      3
    case 19:
      3
    case 20:
      3
    case 21:
      9
    case 22:
      9
    case 23:
      9
    case 24:
      9
    case 25:
      9
    case 26:
      9
    case 27:
      7
    case 28:
      7
    case 29:
      7
    case 30:
      7
    case 31:
      7
    case 32:
      7
    case 33:
      7
    case 34:
      2
    case _:
      0

def skill_base_h(skill: U32) -> U32:
  match skill:
    case 1:
      1
    case 2:
      4
    case 3:
      3
    case 4:
      4
    case 5:
      3
    case 6:
      3
    case 7:
      1
    case 8:
      5
    case 9:
      5
    case 10:
      5
    case 11:
      5
    case 12:
      5
    case 13:
      5
    case 14:
      1
    case 15:
      3
    case 16:
      2
    case 17:
      3
    case 18:
      3
    case 19:
      2
    case 20:
      3
    case 21:
      5
    case 22:
      5
    case 23:
      5
    case 24:
      5
    case 25:
      5
    case 26:
      5
    case 27:
      3
    case 28:
      3
    case 29:
      5
    case 30:
      3
    case 31:
      5
    case 32:
      3
    case 33:
      3
    case 34:
      1
    case _:
      0

def skill_base_cell(skill: U32, x: U32, y: U32) -> U32:
  match skill y x:
    case 1 0 0:
      cell_attack()
    case 1 0 1:
      cell_attack()
    case 1 0 2:
      cell_attack()
    case 1 0 3:
      cell_attack()

    case 2 0 3:
      cell_attack()
    case 2 1 2:
      cell_attack()
    case 2 2 1:
      cell_attack()
    case 2 3 0:
      cell_attack()

    case 3 0 0:
      cell_attack()
    case 3 0 2:
      cell_attack()
    case 3 1 1:
      cell_attack()
    case 3 2 0:
      cell_attack()
    case 3 2 2:
      cell_attack()

    case 4 0 0:
      cell_attack()
    case 4 1 0:
      cell_attack()
    case 4 2 0:
      cell_attack()
    case 4 3 0:
      cell_attack()
    case 4 3 1:
      cell_attack()

    case 5 0 1:
      cell_player()
    case 5 0 6:
      cell_ice()
    case 5 1 0:
      cell_player()
    case 5 1 5:
      cell_ice()
    case 5 1 6:
      cell_ice()
    case 5 1 7:
      cell_ice()
    case 5 2 1:
      cell_player()
    case 5 2 6:
      cell_ice()

    case 6 0 1:
      cell_player()
    case 6 0 6:
      cell_fire()
    case 6 1 0:
      cell_player()
    case 6 1 5:
      cell_fire()
    case 6 1 6:
      cell_fire()
    case 6 1 7:
      cell_fire()
    case 6 2 1:
      cell_player()
    case 6 2 6:
      cell_fire()

    case 7 0 0:
      cell_hook()
    case 7 0 1:
      cell_hook()
    case 7 0 2:
      cell_hook()
    case 7 0 3:
      cell_hook()
    case 7 0 4:
      cell_hook()
    case 7 0 5:
      cell_hook()
    case 7 0 6:
      cell_hook()

    case 8 0 0:
      cell_player()
    case 8 0 2:
      cell_player()
    case 8 1 0:
      cell_player()
    case 8 1 2:
      cell_player()
    case 8 2 0:
      cell_player()
    case 8 0 6:
      cell_dist_attack()
    case 8 1 6:
      cell_dist_attack()
    case 8 2 2:
      cell_player()
    case 8 2 4:
      cell_dist_attack()
    case 8 2 5:
      cell_dist_attack()
    case 8 2 6:
      cell_dist_attack()
    case 8 2 7:
      cell_dist_attack()
    case 8 2 8:
      cell_dist_attack()
    case 8 3 0:
      cell_player()
    case 8 3 2:
      cell_player()
    case 8 3 6:
      cell_dist_attack()
    case 8 4 0:
      cell_player()
    case 8 4 2:
      cell_player()
    case 8 4 6:
      cell_dist_attack()

    case 9 0 6:
      cell_ice()
    case 9 1 1:
      cell_player()
    case 9 1 5:
      cell_ice()
    case 9 2 0:
      cell_player()
    case 9 2 1:
      cell_player()
    case 9 2 2:
      cell_player()
    case 9 2 4:
      cell_ice()
    case 9 3 1:
      cell_player()
    case 9 3 5:
      cell_ice()
    case 9 4 6:
      cell_ice()

    case 10 0 0:
      cell_player()
    case 10 0 2:
      cell_player()
    case 10 0 6:
      cell_dist_attack()
    case 10 0 8:
      cell_dist_attack()
    case 10 1 0:
      cell_player()
    case 10 1 2:
      cell_player()
    case 10 1 6:
      cell_dist_attack()
    case 10 1 8:
      cell_dist_attack()
    case 10 2 0:
      cell_player()
    case 10 2 2:
      cell_player()
    case 10 2 6:
      cell_dist_attack()
    case 10 2 8:
      cell_dist_attack()
    case 10 3 0:
      cell_player()
    case 10 3 2:
      cell_player()
    case 10 3 6:
      cell_dist_attack()
    case 10 3 8:
      cell_dist_attack()
    case 10 4 0:
      cell_player()
    case 10 4 2:
      cell_player()
    case 10 4 6:
      cell_dist_attack()
    case 10 4 8:
      cell_dist_attack()

    case 11 0 0:
      cell_player()
    case 11 0 2:
      cell_player()
    case 11 1 0:
      cell_player()
    case 11 1 2:
      cell_player()
    case 11 1 7:
      cell_dist_attack()
    case 11 2 0:
      cell_player()
    case 11 2 2:
      cell_player()
    case 11 2 5:
      cell_dist_attack()
    case 11 2 6:
      cell_dist_attack()
    case 11 2 7:
      cell_dist_attack()
    case 11 2 8:
      cell_dist_attack()
    case 11 3 0:
      cell_player()
    case 11 3 2:
      cell_player()
    case 11 3 7:
      cell_dist_attack()
    case 11 4 0:
      cell_player()
    case 11 4 2:
      cell_player()

    case 12 0 0:
      cell_player()
    case 12 0 2:
      cell_player()
    case 12 0 7:
      cell_dist_attack()
    case 12 1 0:
      cell_player()
    case 12 1 2:
      cell_player()
    case 12 1 6:
      cell_dist_attack()
    case 12 2 0:
      cell_player()
    case 12 2 2:
      cell_player()
    case 12 2 5:
      cell_dist_attack()
    case 12 2 6:
      cell_dist_attack()
    case 12 2 7:
      cell_dist_attack()
    case 12 3 0:
      cell_player()
    case 12 3 2:
      cell_player()
    case 12 3 6:
      cell_dist_attack()
    case 12 4 0:
      cell_player()
    case 12 4 2:
      cell_player()
    case 12 4 7:
      cell_dist_attack()

    case 13 0 0:
      cell_player()
    case 13 0 2:
      cell_player()
    case 13 0 8:
      cell_dist_attack()
    case 13 1 0:
      cell_player()
    case 13 1 2:
      cell_player()
    case 13 1 8:
      cell_dist_attack()
    case 13 2 0:
      cell_player()
    case 13 2 2:
      cell_player()
    case 13 2 5:
      cell_dist_attack()
    case 13 2 6:
      cell_dist_attack()
    case 13 2 7:
      cell_dist_attack()
    case 13 2 8:
      cell_dist_attack()
    case 13 3 0:
      cell_player()
    case 13 3 2:
      cell_player()
    case 13 3 8:
      cell_dist_attack()
    case 13 4 0:
      cell_player()
    case 13 4 2:
      cell_player()
    case 13 4 8:
      cell_dist_attack()

    case 14 0 0:
      cell_player()
    case 14 0 1:
      cell_hook()
    case 14 0 2:
      cell_hook()
    case 14 0 3:
      cell_hook()
    case 14 0 4:
      cell_dist_attack() | cell_hook()

    case 15 0 0:
      cell_attack()
    case 15 1 0:
      cell_attack()
    case 15 1 1:
      cell_attack()
    case 15 2 1:
      cell_attack()
    case 15 2 2:
      cell_attack()

    case 16 0 1:
      cell_attack()
    case 16 1 0:
      cell_attack()
    case 16 1 1:
      cell_attack()
    case 16 1 2:
      cell_attack()

    case 17 0 1:
      cell_attack()
    case 17 1 0:
      cell_attack()
    case 17 1 1:
      cell_attack()
    case 17 1 2:
      cell_attack()
    case 17 2 1:
      cell_attack()

    case 18 0 0:
      cell_attack()
    case 18 1 0:
      cell_attack()
    case 18 2 0:
      cell_attack()
    case 18 2 1:
      cell_attack()
    case 18 2 2:
      cell_attack()

    case 19 0 0:
      cell_attack()
    case 19 0 2:
      cell_attack()
    case 19 1 0:
      cell_attack()
    case 19 1 1:
      cell_attack()
    case 19 1 2:
      cell_attack()

    case 20 0 0:
      cell_attack()
    case 20 0 2:
      cell_attack()
    case 20 1 0:
      cell_attack()
    case 20 1 2:
      cell_attack()
    case 20 2 0:
      cell_attack()
    case 20 2 2:
      cell_attack()

    case 21 0 0:
      cell_player()
    case 21 0 2:
      cell_player()
    case 21 0 7:
      cell_dist_attack()
    case 21 1 0:
      cell_player()
    case 21 1 2:
      cell_player()
    case 21 1 7:
      cell_dist_attack()
    case 21 2 0:
      cell_player()
    case 21 2 2:
      cell_player()
    case 21 2 7:
      cell_dist_attack()
    case 21 3 0:
      cell_player()
    case 21 3 2:
      cell_player()
    case 21 3 7:
      cell_dist_attack()
    case 21 4 0:
      cell_player()
    case 21 4 2:
      cell_player()
    case 21 4 7:
      cell_dist_attack()

    case 22 0 0:
      cell_player()
    case 22 0 2:
      cell_player()
    case 22 0 8:
      cell_dist_attack()
    case 22 1 0:
      cell_player()
    case 22 1 2:
      cell_player()
    case 22 1 6:
      cell_dist_attack()
    case 22 2 0:
      cell_player()
    case 22 2 2:
      cell_player()
    case 22 3 0:
      cell_player()
    case 22 3 2:
      cell_player()
    case 22 3 6:
      cell_dist_attack()
    case 22 4 0:
      cell_player()
    case 22 4 2:
      cell_player()
    case 22 4 8:
      cell_dist_attack()

    case 23 0 0:
      cell_player()
    case 23 0 2:
      cell_player()
    case 23 0 6:
      cell_dist_attack()
    case 23 0 7:
      cell_dist_attack()
    case 23 0 8:
      cell_dist_attack()
    case 23 1 0:
      cell_player()
    case 23 1 2:
      cell_player()
    case 23 1 6:
      cell_dist_attack()
    case 23 1 7:
      cell_dist_attack()
    case 23 1 8:
      cell_dist_attack()
    case 23 2 0:
      cell_player()
    case 23 2 2:
      cell_player()
    case 23 2 6:
      cell_dist_attack()
    case 23 2 7:
      cell_dist_attack()
    case 23 2 8:
      cell_dist_attack()
    case 23 3 0:
      cell_player()
    case 23 3 2:
      cell_player()
    case 23 4 0:
      cell_player()
    case 23 4 2:
      cell_player()

    case 24 0 0:
      cell_player()
    case 24 0 2:
      cell_player()
    case 24 0 8:
      cell_dist_attack()
    case 24 1 0:
      cell_player()
    case 24 1 2:
      cell_player()
    case 24 1 7:
      cell_dist_attack()
    case 24 2 0:
      cell_player()
    case 24 2 2:
      cell_player()
    case 24 2 6:
      cell_dist_attack()
    case 24 3 0:
      cell_player()
    case 24 3 2:
      cell_player()
    case 24 3 5:
      cell_dist_attack()
    case 24 4 0:
      cell_player()
    case 24 4 2:
      cell_player()
    case 24 4 4:
      cell_dist_attack()

    case 25 0 0:
      cell_player()
    case 25 0 2:
      cell_player()
    case 25 1 0:
      cell_player()
    case 25 1 2:
      cell_player()
    case 25 2 0:
      cell_player()
    case 25 2 2:
      cell_player()
    case 25 2 6:
      cell_dist_attack()
    case 25 3 0:
      cell_player()
    case 25 3 2:
      cell_player()
    case 25 3 6:
      cell_dist_attack()
    case 25 3 7:
      cell_dist_attack()
    case 25 3 8:
      cell_dist_attack()
    case 25 4 0:
      cell_player()
    case 25 4 2:
      cell_player()
    case 25 4 6:
      cell_dist_attack()
    case 25 4 7:
      cell_dist_attack()
    case 25 4 8:
      cell_dist_attack()

    case 26 0 0:
      cell_player()
    case 26 0 2:
      cell_player()
    case 26 0 6:
      cell_dist_attack()
    case 26 0 8:
      cell_dist_attack()
    case 26 1 0:
      cell_player()
    case 26 1 2:
      cell_player()
    case 26 1 7:
      cell_dist_attack()
    case 26 2 0:
      cell_player()
    case 26 2 2:
      cell_player()
    case 26 3 0:
      cell_player()
    case 26 3 2:
      cell_player()
    case 26 3 7:
      cell_dist_attack()
    case 26 4 0:
      cell_player()
    case 26 4 2:
      cell_player()
    case 26 4 6:
      cell_dist_attack()
    case 26 4 8:
      cell_dist_attack()

    case 27 0 1:
      cell_player()
    case 27 0 6:
      cell_fire()
    case 27 1 0:
      cell_player()
    case 27 1 5:
      cell_fire()
    case 27 1 6:
      cell_dist_attack() | cell_fire()
    case 27 2 1:
      cell_player()
    case 27 2 6:
      cell_fire()

    case 28 0 1:
      cell_player()
    case 28 0 5:
      cell_ice()
    case 28 1 0:
      cell_player()
    case 28 1 4:
      cell_dist_attack() | cell_ice()
    case 28 1 6:
      cell_dist_attack() | cell_ice()
    case 28 2 1:
      cell_player()
    case 28 2 5:
      cell_ice()

    case 29 0 2:
      cell_player()
    case 29 1 1:
      cell_player()
    case 29 1 4:
      cell_fire()
    case 29 1 5:
      cell_dist_attack() | cell_fire()
    case 29 1 6:
      cell_fire()
    case 29 2 0:
      cell_player()
    case 29 2 4:
      cell_fire()
    case 29 2 5:
      cell_fire()
    case 29 2 6:
      cell_fire()
    case 29 3 1:
      cell_player()
    case 29 3 4:
      cell_fire()
    case 29 3 5:
      cell_dist_attack() | cell_fire()
    case 29 3 6:
      cell_fire()
    case 29 4 2:
      cell_player()

    case 30 0 1:
      cell_player()
    case 30 0 5:
      cell_ice()
    case 30 0 6:
      cell_dist_attack() | cell_ice()
    case 30 1 0:
      cell_player()
    case 30 1 4:
      cell_ice()
    case 30 1 5:
      cell_ice()
    case 30 1 6:
      cell_ice()
    case 30 2 1:
      cell_player()
    case 30 2 5:
      cell_ice()
    case 30 2 6:
      cell_dist_attack() | cell_ice()

    case 31 0 2:
      cell_player()
    case 31 0 6:
      cell_dist_attack() | cell_fire()
    case 31 1 1:
      cell_player()
    case 31 1 5:
      cell_dist_attack() | cell_fire()
    case 31 2 0:
      cell_player()
    case 31 2 4:
      cell_dist_attack() | cell_fire()
    case 31 3 1:
      cell_player()
    case 31 3 5:
      cell_dist_attack() | cell_fire()
    case 31 4 2:
      cell_player()
    case 31 4 6:
      cell_dist_attack() | cell_fire()

    case 32 0 1:
      cell_player()
    case 32 0 5:
      cell_fire()
    case 32 1 0:
      cell_player()
    case 32 1 4:
      cell_dist_attack() | cell_fire()
    case 32 1 5:
      cell_fire()
    case 32 1 6:
      cell_dist_attack() | cell_fire()
    case 32 2 1:
      cell_player()
    case 32 2 5:
      cell_fire()

    case 33 0 1:
      cell_player()
    case 33 0 6:
      cell_dist_attack() | cell_ice()
    case 33 1 0:
      cell_player()
    case 33 1 5:
      cell_ice()
    case 33 1 6:
      cell_ice()
    case 33 2 1:
      cell_player()
    case 33 2 6:
      cell_dist_attack() | cell_ice()

    case 34 0 0:
      cell_attack()
    case 34 0 1:
      cell_attack()

    case _ _ _:
      0

def skill_len(skill: U32) -> U32:
  _skill_group_count(skill, 2, 0, 0)

def skill_point_x(skill: U32, rot: U32, idx: U32) -> U32:
  base_x = _skill_point_base_x(skill, idx);
  base_y = _skill_point_base_y(skill, idx);
  _skill_rot_x(rot % 4, skill_base_w(skill), skill_base_h(skill), base_x, base_y)

def skill_point_y(skill: U32, rot: U32, idx: U32) -> U32:
  base_x = _skill_point_base_x(skill, idx);
  base_y = _skill_point_base_y(skill, idx);
  _skill_rot_y(rot % 4, skill_base_w(skill), skill_base_h(skill), base_x, base_y)

def skill_player_mask(skill: U32, idx: U32) -> U32:
  _mask_has(_skill_cell_mask_at_idx(skill, idx), cell_player())

def skill_effect_mask(skill: U32, idx: U32) -> U32:
  _skill_cell_mask_at_idx(skill, idx) & 15

def _skill_point_base_x(skill: U32, idx: U32) -> U32:
  anchors = _skill_anchor_count(skill);
  match _u32_lt(idx, anchors):
    case 0:
      _skill_point_in_group_x(skill, idx - anchors, 1, 0, 0)
    case _:
      _skill_point_in_group_x(skill, idx, 0, 0, 0)

def _skill_point_base_y(skill: U32, idx: U32) -> U32:
  anchors = _skill_anchor_count(skill);
  match _u32_lt(idx, anchors):
    case 0:
      _skill_point_in_group_y(skill, idx - anchors, 1, 0, 0)
    case _:
      _skill_point_in_group_y(skill, idx, 0, 0, 0)

def _skill_point_in_group_x(skill: U32, idx: U32, group_id: U32, x: U32, y: U32) -> U32:
  width = skill_base_w(skill);
  height = skill_base_h(skill);
  match y === height:
    case 0:
      match x === width:
        case 0:
          match _skill_cell_in_group(skill, x, y, group_id):
            case 0:
              _skill_point_in_group_x(skill, idx, group_id, x + 1, y)
            case _:
              match idx === 0:
                case 0:
                  _skill_point_in_group_x(skill, idx - 1, group_id, x + 1, y)
                case _:
                  x
        case _:
          _skill_point_in_group_x(skill, idx, group_id, 0, y + 1)
    case _:
      0

def _skill_point_in_group_y(skill: U32, idx: U32, group_id: U32, x: U32, y: U32) -> U32:
  width = skill_base_w(skill);
  height = skill_base_h(skill);
  match y === height:
    case 0:
      match x === width:
        case 0:
          match _skill_cell_in_group(skill, x, y, group_id):
            case 0:
              _skill_point_in_group_y(skill, idx, group_id, x + 1, y)
            case _:
              match idx === 0:
                case 0:
                  _skill_point_in_group_y(skill, idx - 1, group_id, x + 1, y)
                case _:
                  y
        case _:
          _skill_point_in_group_y(skill, idx, group_id, 0, y + 1)
    case _:
      0

def _skill_cell_mask_at_idx(skill: U32, idx: U32) -> U32:
  x = _skill_point_base_x(skill, idx);
  y = _skill_point_base_y(skill, idx);
  skill_base_cell(skill, x, y)

def _skill_anchor_count(skill: U32) -> U32:
  _skill_group_count(skill, 0, 0, 0)

def _skill_group_count(skill: U32, group_id: U32, x: U32, y: U32) -> U32:
  width = skill_base_w(skill);
  height = skill_base_h(skill);
  match y === height:
    case 0:
      match x === width:
        case 0:
          match _skill_cell_in_group(skill, x, y, group_id):
            case 0:
              _skill_group_count(skill, group_id, x + 1, y)
            case _:
              1 + _skill_group_count(skill, group_id, x + 1, y)
        case _:
          _skill_group_count(skill, group_id, 0, y + 1)
    case _:
      0

def _skill_cell_present(skill: U32, x: U32, y: U32) -> U32:
  1 ^ (skill_base_cell(skill, x, y) === 0)

def _skill_cell_is_anchor(skill: U32, x: U32, y: U32) -> U32:
  _mask_has(skill_base_cell(skill, x, y), cell_player())

def _skill_cell_in_group(skill: U32, x: U32, y: U32, group_id: U32) -> U32:
  match group_id:
    case 0:
      _skill_cell_is_anchor(skill, x, y)
    case 1:
      (1 ^ _skill_cell_is_anchor(skill, x, y)) & _skill_cell_present(skill, x, y)
    case _:
      _skill_cell_present(skill, x, y)

def _skill_rot_x(rot: U32, width: U32, height: U32, x: U32, y: U32) -> U32:
  match rot:
    case 0:
      x
    case 1:
      height - 1 - y
    case 2:
      width - 1 - x
    case _:
      y

def _skill_rot_y(rot: U32, width: U32, height: U32, x: U32, y: U32) -> U32:
  match rot:
    case 0:
      y
    case 1:
      x
    case 2:
      height - 1 - y
    case _:
      width - 1 - x

def _mask_has(mask: U32, flag: U32) -> U32:
  match mask & flag:
    case 0:
      0
    case _:
      1

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

def effect_has(mask: U32, flag: U32) -> U32:
  _mask_has(mask, flag)

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
    case 5:
      2
    case _:
      4
