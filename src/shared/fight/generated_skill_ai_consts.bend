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
    case _:
      area_box{0, 0, 0, 0}
