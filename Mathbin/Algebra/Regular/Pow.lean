/-
Copyright (c) 2021 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa

! This file was ported from Lean 3 source module algebra.regular.pow
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Iterate
import Mathbin.Algebra.Regular.Basic

/-!
# Regular elements

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Implementation details

Group powers and other definitions import a lot of the algebra hierarchy.
Lemmas about them are kept separate to be able to provide `is_regular` early in the
algebra hierarchy.

-/


variable {R : Type _} {a b : R}

section Monoid

variable [Monoid R]

#print IsLeftRegular.pow /-
/-- Any power of a left-regular element is left-regular. -/
theorem IsLeftRegular.pow (n : ℕ) (rla : IsLeftRegular a) : IsLeftRegular (a ^ n) := by
  simp only [IsLeftRegular, ← mul_left_iterate, rla.iterate n]
#align is_left_regular.pow IsLeftRegular.pow
-/

#print IsRightRegular.pow /-
/-- Any power of a right-regular element is right-regular. -/
theorem IsRightRegular.pow (n : ℕ) (rra : IsRightRegular a) : IsRightRegular (a ^ n) := by
  rw [IsRightRegular, ← mul_right_iterate]; exact rra.iterate n
#align is_right_regular.pow IsRightRegular.pow
-/

#print IsRegular.pow /-
/-- Any power of a regular element is regular. -/
theorem IsRegular.pow (n : ℕ) (ra : IsRegular a) : IsRegular (a ^ n) :=
  ⟨IsLeftRegular.pow n ra.left, IsRightRegular.pow n ra.right⟩
#align is_regular.pow IsRegular.pow
-/

#print IsLeftRegular.pow_iff /-
/-- An element `a` is left-regular if and only if a positive power of `a` is left-regular. -/
theorem IsLeftRegular.pow_iff {n : ℕ} (n0 : 0 < n) : IsLeftRegular (a ^ n) ↔ IsLeftRegular a :=
  by
  refine' ⟨_, IsLeftRegular.pow n⟩
  rw [← Nat.succ_pred_eq_of_pos n0, pow_succ']
  exact IsLeftRegular.of_mul
#align is_left_regular.pow_iff IsLeftRegular.pow_iff
-/

#print IsRightRegular.pow_iff /-
/-- An element `a` is right-regular if and only if a positive power of `a` is right-regular. -/
theorem IsRightRegular.pow_iff {n : ℕ} (n0 : 0 < n) : IsRightRegular (a ^ n) ↔ IsRightRegular a :=
  by
  refine' ⟨_, IsRightRegular.pow n⟩
  rw [← Nat.succ_pred_eq_of_pos n0, pow_succ]
  exact IsRightRegular.of_mul
#align is_right_regular.pow_iff IsRightRegular.pow_iff
-/

#print IsRegular.pow_iff /-
/-- An element `a` is regular if and only if a positive power of `a` is regular. -/
theorem IsRegular.pow_iff {n : ℕ} (n0 : 0 < n) : IsRegular (a ^ n) ↔ IsRegular a :=
  ⟨fun h => ⟨(IsLeftRegular.pow_iff n0).mp h.left, (IsRightRegular.pow_iff n0).mp h.right⟩, fun h =>
    ⟨IsLeftRegular.pow n h.left, IsRightRegular.pow n h.right⟩⟩
#align is_regular.pow_iff IsRegular.pow_iff
-/

end Monoid

