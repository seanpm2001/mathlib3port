/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module data.set.intervals.iso_Ioo
! leanprover-community/mathlib commit e04043d6bf7264a3c84bc69711dc354958ca4516
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Monotone.Odd
import Mathbin.Tactic.FieldSimp

/-!
# Order isomorphism between a linear ordered field and `(-1, 1)`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we provide an order isomorphism `order_iso_Ioo_neg_one_one` between the open interval
`(-1, 1)` in a linear ordered field and the whole field.
-/


open Set

#print orderIsoIooNegOneOne /-
/-- In a linear ordered field, the whole field is order isomorphic to the open interval `(-1, 1)`.
We consider the actual implementation to be a "black box", so it is irreducible.
-/
irreducible_def orderIsoIooNegOneOne (k : Type _) [LinearOrderedField k] : k ≃o Ioo (-1 : k) 1 :=
  by
  refine' StrictMono.orderIsoOfRightInverse _ _ (fun x => x / (1 - |x|)) _
  · refine' cod_restrict (fun x => x / (1 + |x|)) _ fun x => abs_lt.1 _
    have H : 0 < 1 + |x| := (abs_nonneg x).trans_lt (lt_one_add _)
    calc
      |x / (1 + |x|)| = |x| / (1 + |x|) := by rw [abs_div, abs_of_pos H]
      _ < 1 := (div_lt_one H).2 (lt_one_add _)
  · refine' (strictMono_of_odd_strictMonoOn_nonneg _ _).codRestrict _
    · intro x; simp only [abs_neg, neg_div]
    · rintro x (hx : 0 ≤ x) y (hy : 0 ≤ y) hxy
      simp [abs_of_nonneg, mul_add, mul_comm x y, div_lt_div_iff, hx.trans_lt (lt_one_add _),
        hy.trans_lt (lt_one_add _), *]
  · refine' fun x => Subtype.ext _
    have : 0 < 1 - |(x : k)| := sub_pos.2 (abs_lt.2 x.2)
    field_simp [abs_div, this.ne', abs_of_pos this]
#align order_iso_Ioo_neg_one_one orderIsoIooNegOneOne
-/

