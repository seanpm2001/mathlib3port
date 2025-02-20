/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module analysis.normed_space.int
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Field.Basic

/-!
# The integers as normed ring

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains basic facts about the integers as normed ring.

Recall that `‖n‖` denotes the norm of `n` as real number.
This norm is always nonnegative, so we can bundle the norm together with this fact,
to obtain a term of type `nnreal` (the nonnegative real numbers).
The resulting nonnegative real number is denoted by `‖n‖₊`.
-/


open scoped BigOperators

namespace Int

#print Int.nnnorm_coe_units /-
theorem nnnorm_coe_units (e : ℤˣ) : ‖(e : ℤ)‖₊ = 1 := by
  obtain rfl | rfl := Int.units_eq_one_or e <;>
    simp only [Units.coe_neg_one, Units.val_one, nnnorm_neg, nnnorm_one]
#align int.nnnorm_coe_units Int.nnnorm_coe_units
-/

#print Int.norm_coe_units /-
theorem norm_coe_units (e : ℤˣ) : ‖(e : ℤ)‖ = 1 := by
  rw [← coe_nnnorm, Int.nnnorm_coe_units, NNReal.coe_one]
#align int.norm_coe_units Int.norm_coe_units
-/

#print Int.nnnorm_coe_nat /-
@[simp]
theorem nnnorm_coe_nat (n : ℕ) : ‖(n : ℤ)‖₊ = n :=
  Real.nnnorm_coe_nat _
#align int.nnnorm_coe_nat Int.nnnorm_coe_nat
-/

#print Int.toNat_add_toNat_neg_eq_nnnorm /-
@[simp]
theorem toNat_add_toNat_neg_eq_nnnorm (n : ℤ) : ↑n.toNat + ↑(-n).toNat = ‖n‖₊ := by
  rw [← Nat.cast_add, to_nat_add_to_nat_neg_eq_nat_abs, NNReal.coe_natAbs]
#align int.to_nat_add_to_nat_neg_eq_nnnorm Int.toNat_add_toNat_neg_eq_nnnorm
-/

#print Int.toNat_add_toNat_neg_eq_norm /-
@[simp]
theorem toNat_add_toNat_neg_eq_norm (n : ℤ) : ↑n.toNat + ↑(-n).toNat = ‖n‖ := by
  simpa only [NNReal.coe_nat_cast, NNReal.coe_add] using
    congr_arg (coe : _ → ℝ) (to_nat_add_to_nat_neg_eq_nnnorm n)
#align int.to_nat_add_to_nat_neg_eq_norm Int.toNat_add_toNat_neg_eq_norm
-/

end Int

