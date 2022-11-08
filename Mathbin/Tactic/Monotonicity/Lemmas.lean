/-
Copyright (c) 2019 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon
-/
import Mathbin.Algebra.Order.Group.Abs
import Mathbin.Algebra.Order.Ring.Basic
import Mathbin.Algebra.Order.Sub.Canonical
import Mathbin.Data.Set.Lattice
import Mathbin.Tactic.Monotonicity.Basic

variable {α : Type _}

open Set

attribute [mono]
  inter_subset_inter union_subset_union sUnion_mono Union₂_mono sInter_subset_sInter Inter₂_mono image_subset preimage_mono prod_mono Monotone.set_prod seq_mono image2_subset OrderEmbedding.monotone

attribute [mono]
  upper_bounds_mono_set lower_bounds_mono_set upper_bounds_mono_mem lower_bounds_mono_mem upper_bounds_mono lower_bounds_mono BddAbove.mono BddBelow.mono

attribute [mono]
  add_le_add mul_le_mul neg_le_neg mul_lt_mul_of_pos_left mul_lt_mul_of_pos_right mul_le_mul_of_nonneg_left mul_le_mul_of_nonneg_right mul_le_mul_of_nonpos_left mul_le_mul_of_nonpos_right imp_imp_imp le_implies_le_of_le_of_le tsub_lt_tsub_left_of_le tsub_lt_tsub_right_of_le tsub_le_tsub abs_le_abs sup_le_sup inf_le_inf

attribute [mono left] add_lt_add_of_le_of_lt mul_lt_mul'

attribute [mono right] add_lt_add_of_lt_of_le mul_lt_mul

