import /U32/ as U32

type DeltaPos {
  delta_pos{x_neg: U32, x_mag: U32, y_neg: U32, y_mag: U32}
}

type AreaBox {
  area_box{x1: U32, y1: U32, x2: U32, y2: U32}
}

def skill_has_anchor_consts(skill: U32) -> U32:
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
      1
    case 6:
      1
    case 7:
      0
    case 8:
      1
    case 9:
      1
    case 10:
      1
    case 11:
      1
    case 12:
      1
    case 13:
      1
    case 14:
      1
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
      1
    case 28:
      1
    case 29:
      1
    case 30:
      1
    case 31:
      1
    case 32:
      1
    case 33:
      1
    case _:
      0

def skill_delta_diag_top_left_down_right(skill: U32) -> DeltaPos:
  match skill:
    case 1:
      delta_pos{0, 0, 0, 0}
    case 2:
      delta_pos{0, 0, 0, 0}
    case 3:
      delta_pos{0, 0, 0, 0}
    case 4:
      delta_pos{0, 0, 0, 0}
    case 5:
      delta_pos{1, 5, 1, 2}
    case 6:
      delta_pos{1, 5, 1, 2}
    case 7:
      delta_pos{0, 0, 0, 0}
    case 8:
      delta_pos{1, 4, 1, 4}
    case 9:
      delta_pos{1, 5, 1, 3}
    case 10:
      delta_pos{1, 4, 1, 4}
    case 11:
      delta_pos{1, 5, 1, 3}
    case 12:
      delta_pos{1, 5, 1, 4}
    case 13:
      delta_pos{1, 6, 1, 4}
    case 14:
      delta_pos{1, 4, 0, 0}
    case 15:
      delta_pos{0, 0, 0, 0}
    case 16:
      delta_pos{0, 0, 0, 0}
    case 17:
      delta_pos{0, 0, 0, 0}
    case 18:
      delta_pos{0, 0, 0, 0}
    case 19:
      delta_pos{0, 0, 0, 0}
    case 20:
      delta_pos{0, 0, 0, 0}
    case 21:
      delta_pos{1, 5, 1, 4}
    case 22:
      delta_pos{1, 6, 1, 4}
    case 23:
      delta_pos{1, 4, 1, 2}
    case 24:
      delta_pos{1, 2, 1, 4}
    case 25:
      delta_pos{1, 4, 1, 4}
    case 26:
      delta_pos{1, 4, 1, 4}
    case 27:
      delta_pos{1, 5, 1, 2}
    case 28:
      delta_pos{1, 4, 1, 2}
    case 29:
      delta_pos{1, 2, 1, 3}
    case 30:
      delta_pos{1, 4, 1, 2}
    case 31:
      delta_pos{1, 4, 1, 4}
    case 32:
      delta_pos{1, 4, 1, 2}
    case 33:
      delta_pos{1, 5, 1, 2}
    case _:
      delta_pos{0, 0, 0, 0}

def skill_delta_diag_down_left_top_right(skill: U32) -> DeltaPos:
  match skill:
    case 1:
      delta_pos{0, 0, 0, 0}
    case 2:
      delta_pos{0, 0, 0, 0}
    case 3:
      delta_pos{0, 0, 0, 0}
    case 4:
      delta_pos{0, 0, 0, 0}
    case 5:
      delta_pos{1, 5, 0, 2}
    case 6:
      delta_pos{1, 5, 0, 2}
    case 7:
      delta_pos{0, 0, 0, 0}
    case 8:
      delta_pos{1, 4, 0, 4}
    case 9:
      delta_pos{1, 5, 0, 3}
    case 10:
      delta_pos{1, 4, 0, 4}
    case 11:
      delta_pos{1, 5, 0, 3}
    case 12:
      delta_pos{1, 5, 0, 4}
    case 13:
      delta_pos{1, 6, 0, 4}
    case 14:
      delta_pos{1, 4, 0, 0}
    case 15:
      delta_pos{0, 0, 0, 0}
    case 16:
      delta_pos{0, 0, 0, 0}
    case 17:
      delta_pos{0, 0, 0, 0}
    case 18:
      delta_pos{0, 0, 0, 0}
    case 19:
      delta_pos{0, 0, 0, 0}
    case 20:
      delta_pos{0, 0, 0, 0}
    case 21:
      delta_pos{1, 5, 0, 4}
    case 22:
      delta_pos{1, 6, 0, 4}
    case 23:
      delta_pos{1, 4, 0, 4}
    case 24:
      delta_pos{1, 6, 0, 4}
    case 25:
      delta_pos{1, 4, 0, 2}
    case 26:
      delta_pos{1, 4, 0, 4}
    case 27:
      delta_pos{1, 5, 0, 2}
    case 28:
      delta_pos{1, 4, 0, 2}
    case 29:
      delta_pos{1, 2, 0, 3}
    case 30:
      delta_pos{1, 4, 0, 2}
    case 31:
      delta_pos{1, 4, 0, 4}
    case 32:
      delta_pos{1, 4, 0, 2}
    case 33:
      delta_pos{1, 5, 0, 2}
    case _:
      delta_pos{0, 0, 0, 0}

def skill_same_row_right_min_diff(skill: U32) -> U32:
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
      5
    case 6:
      5
    case 7:
      0
    case 8:
      2
    case 9:
      2
    case 10:
      4
    case 11:
      3
    case 12:
      3
    case 13:
      3
    case 14:
      4
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
      5
    case 22:
      4
    case 23:
      4
    case 24:
      2
    case 25:
      4
    case 26:
      4
    case 27:
      5
    case 28:
      4
    case 29:
      3
    case 30:
      4
    case 31:
      4
    case 32:
      4
    case 33:
      5
    case _:
      0

def skill_same_row_right_min_pos_count(skill: U32) -> U32:
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
      3
    case 6:
      3
    case 7:
      0
    case 8:
      1
    case 9:
      1
    case 10:
      5
    case 11:
      1
    case 12:
      1
    case 13:
      1
    case 14:
      1
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
      5
    case 22:
      2
    case 23:
      3
    case 24:
      1
    case 25:
      3
    case 26:
      2
    case 27:
      3
    case 28:
      3
    case 29:
      2
    case 30:
      3
    case 31:
      5
    case 32:
      3
    case 33:
      3
    case _:
      0

def skill_same_row_right_min_pos_x(skill: U32, idx: U32) -> U32:
  match skill idx:
    case 5 0:
      1
    case 5 1:
      0
    case 5 2:
      1
    case 6 0:
      1
    case 6 1:
      0
    case 6 2:
      1
    case 8 0:
      2
    case 9 0:
      2
    case 10 0:
      2
    case 10 1:
      2
    case 10 2:
      2
    case 10 3:
      2
    case 10 4:
      2
    case 11 0:
      2
    case 12 0:
      2
    case 13 0:
      2
    case 14 0:
      0
    case 21 0:
      2
    case 21 1:
      2
    case 21 2:
      2
    case 21 3:
      2
    case 21 4:
      2
    case 22 0:
      2
    case 22 1:
      2
    case 23 0:
      2
    case 23 1:
      2
    case 23 2:
      2
    case 24 0:
      2
    case 25 0:
      2
    case 25 1:
      2
    case 25 2:
      2
    case 26 0:
      2
    case 26 1:
      2
    case 27 0:
      1
    case 27 1:
      0
    case 27 2:
      1
    case 28 0:
      1
    case 28 1:
      0
    case 28 2:
      1
    case 29 0:
      1
    case 29 1:
      1
    case 30 0:
      1
    case 30 1:
      0
    case 30 2:
      1
    case 31 0:
      2
    case 31 1:
      1
    case 31 2:
      0
    case 31 3:
      1
    case 31 4:
      2
    case 32 0:
      1
    case 32 1:
      0
    case 32 2:
      1
    case 33 0:
      1
    case 33 1:
      0
    case 33 2:
      1
    case _ _:
      0

def skill_same_row_right_min_pos_y(skill: U32, idx: U32) -> U32:
  match skill idx:
    case 5 0:
      0
    case 5 1:
      1
    case 5 2:
      2
    case 6 0:
      0
    case 6 1:
      1
    case 6 2:
      2
    case 8 0:
      2
    case 9 0:
      2
    case 10 0:
      0
    case 10 1:
      1
    case 10 2:
      2
    case 10 3:
      3
    case 10 4:
      4
    case 11 0:
      2
    case 12 0:
      2
    case 13 0:
      2
    case 14 0:
      0
    case 21 0:
      0
    case 21 1:
      1
    case 21 2:
      2
    case 21 3:
      3
    case 21 4:
      4
    case 22 0:
      1
    case 22 1:
      3
    case 23 0:
      0
    case 23 1:
      1
    case 23 2:
      2
    case 24 0:
      4
    case 25 0:
      2
    case 25 1:
      3
    case 25 2:
      4
    case 26 0:
      0
    case 26 1:
      4
    case 27 0:
      0
    case 27 1:
      1
    case 27 2:
      2
    case 28 0:
      0
    case 28 1:
      1
    case 28 2:
      2
    case 29 0:
      1
    case 29 1:
      3
    case 30 0:
      0
    case 30 1:
      1
    case 30 2:
      2
    case 31 0:
      0
    case 31 1:
      1
    case 31 2:
      2
    case 31 3:
      3
    case 31 4:
      4
    case 32 0:
      0
    case 32 1:
      1
    case 32 2:
      2
    case 33 0:
      0
    case 33 1:
      1
    case 33 2:
      2
    case _ _:
      0

def skill_same_row_left_max_diff(skill: U32) -> U32:
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
      7
    case 6:
      7
    case 7:
      0
    case 8:
      8
    case 9:
      4
    case 10:
      8
    case 11:
      8
    case 12:
      7
    case 13:
      8
    case 14:
      4
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
      7
    case 22:
      8
    case 23:
      8
    case 24:
      8
    case 25:
      8
    case 26:
      8
    case 27:
      6
    case 28:
      6
    case 29:
      6
    case 30:
      6
    case 31:
      4
    case 32:
      6
    case 33:
      6
    case _:
      0

def skill_same_row_left_max_pos_count(skill: U32) -> U32:
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
      1
    case 6:
      1
    case 7:
      0
    case 8:
      1
    case 9:
      3
    case 10:
      5
    case 11:
      1
    case 12:
      3
    case 13:
      5
    case 14:
      1
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
      5
    case 22:
      2
    case 23:
      3
    case 24:
      1
    case 25:
      2
    case 26:
      2
    case 27:
      1
    case 28:
      1
    case 29:
      1
    case 30:
      1
    case 31:
      5
    case 32:
      1
    case 33:
      1
    case _:
      0

def skill_same_row_left_max_pos_x(skill: U32, idx: U32) -> U32:
  match skill idx:
    case 5 0:
      0
    case 6 0:
      0
    case 8 0:
      0
    case 9 0:
      1
    case 9 1:
      0
    case 9 2:
      1
    case 10 0:
      0
    case 10 1:
      0
    case 10 2:
      0
    case 10 3:
      0
    case 10 4:
      0
    case 11 0:
      0
    case 12 0:
      0
    case 12 1:
      0
    case 12 2:
      0
    case 13 0:
      0
    case 13 1:
      0
    case 13 2:
      0
    case 13 3:
      0
    case 13 4:
      0
    case 14 0:
      0
    case 21 0:
      0
    case 21 1:
      0
    case 21 2:
      0
    case 21 3:
      0
    case 21 4:
      0
    case 22 0:
      0
    case 22 1:
      0
    case 23 0:
      0
    case 23 1:
      0
    case 23 2:
      0
    case 24 0:
      0
    case 25 0:
      0
    case 25 1:
      0
    case 26 0:
      0
    case 26 1:
      0
    case 27 0:
      0
    case 28 0:
      0
    case 29 0:
      0
    case 30 0:
      0
    case 31 0:
      2
    case 31 1:
      1
    case 31 2:
      0
    case 31 3:
      1
    case 31 4:
      2
    case 32 0:
      0
    case 33 0:
      0
    case _ _:
      0

def skill_same_row_left_max_pos_y(skill: U32, idx: U32) -> U32:
  match skill idx:
    case 5 0:
      1
    case 6 0:
      1
    case 8 0:
      2
    case 9 0:
      1
    case 9 1:
      2
    case 9 2:
      3
    case 10 0:
      0
    case 10 1:
      1
    case 10 2:
      2
    case 10 3:
      3
    case 10 4:
      4
    case 11 0:
      2
    case 12 0:
      0
    case 12 1:
      2
    case 12 2:
      4
    case 13 0:
      0
    case 13 1:
      1
    case 13 2:
      2
    case 13 3:
      3
    case 13 4:
      4
    case 14 0:
      0
    case 21 0:
      0
    case 21 1:
      1
    case 21 2:
      2
    case 21 3:
      3
    case 21 4:
      4
    case 22 0:
      0
    case 22 1:
      4
    case 23 0:
      0
    case 23 1:
      1
    case 23 2:
      2
    case 24 0:
      0
    case 25 0:
      3
    case 25 1:
      4
    case 26 0:
      0
    case 26 1:
      4
    case 27 0:
      1
    case 28 0:
      1
    case 29 0:
      2
    case 30 0:
      1
    case 31 0:
      0
    case 31 1:
      1
    case 31 2:
      2
    case 31 3:
      3
    case 31 4:
      4
    case 32 0:
      1
    case 33 0:
      1
    case _ _:
      0

def skill_use_area(skill: U32) -> AreaBox:
  match skill:
    case 1:
      area_box{0, 0, 3, 0}
    case 2:
      area_box{0, 0, 3, 3}
    case 3:
      area_box{0, 0, 2, 2}
    case 4:
      area_box{0, 0, 1, 3}
    case 5:
      area_box{6, 0, 7, 2}
    case 6:
      area_box{6, 0, 7, 2}
    case 7:
      area_box{0, 0, 6, 0}
    case 8:
      area_box{6, 0, 8, 4}
    case 9:
      area_box{6, 0, 5, 4}
    case 10:
      area_box{6, 0, 8, 4}
    case 11:
      area_box{7, 1, 8, 3}
    case 12:
      area_box{7, 0, 7, 4}
    case 13:
      area_box{8, 0, 8, 4}
    case 14:
      area_box{4, 0, 4, 0}
    case 15:
      area_box{0, 0, 2, 2}
    case 16:
      area_box{0, 0, 2, 1}
    case 17:
      area_box{0, 0, 2, 2}
    case 18:
      area_box{0, 0, 2, 2}
    case 19:
      area_box{0, 0, 2, 1}
    case 20:
      area_box{0, 0, 2, 2}
    case 21:
      area_box{7, 0, 7, 4}
    case 22:
      area_box{8, 0, 8, 4}
    case 23:
      area_box{6, 0, 8, 2}
    case 24:
      area_box{4, 0, 8, 4}
    case 25:
      area_box{6, 2, 8, 4}
    case 26:
      area_box{6, 0, 8, 4}
    case 27:
      area_box{6, 0, 6, 2}
    case 28:
      area_box{5, 0, 6, 2}
    case 29:
      area_box{4, 1, 6, 3}
    case 30:
      area_box{5, 0, 6, 2}
    case 31:
      area_box{6, 0, 6, 4}
    case 32:
      area_box{5, 0, 6, 2}
    case 33:
      area_box{6, 0, 6, 2}
    case _:
      area_box{0, 0, 0, 0}
