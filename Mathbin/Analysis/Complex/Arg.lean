/-
Copyright (c) 2022 Eric Rodriguez. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Rodriguez

! This file was ported from Lean 3 source module analysis.complex.arg
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Basic
import Mathbin.Analysis.SpecialFunctions.Complex.Arg

/-!
# Rays in the complex numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file links the definition `same_ray ℝ x y` with the equality of arguments of complex numbers,
the usual way this is considered.

## Main statements

* `complex.same_ray_iff` : Two complex numbers are on the same ray iff one of them is zero, or they
  have the same argument.
* `complex.abs_add_eq/complex.abs_sub_eq`: If two non zero complex numbers have the same argument,
  then the triangle inequality is an equality.

-/


variable {x y : ℂ}

namespace Complex

#print Complex.sameRay_iff /-
theorem sameRay_iff : SameRay ℝ x y ↔ x = 0 ∨ y = 0 ∨ x.arg = y.arg :=
  by
  rcases eq_or_ne x 0 with (rfl | hx)
  · simp
  rcases eq_or_ne y 0 with (rfl | hy)
  · simp
  simp only [hx, hy, false_or_iff, sameRay_iff_norm_smul_eq, arg_eq_arg_iff hx hy]
  field_simp [hx, hy]
  rw [mul_comm, eq_comm]
#align complex.same_ray_iff Complex.sameRay_iff
-/

#print Complex.sameRay_iff_arg_div_eq_zero /-
theorem sameRay_iff_arg_div_eq_zero : SameRay ℝ x y ↔ arg (x / y) = 0 :=
  by
  rw [← Real.Angle.toReal_zero, ← arg_coe_angle_eq_iff_eq_to_real, same_ray_iff]
  by_cases hx : x = 0; · simp [hx]
  by_cases hy : y = 0; · simp [hy]
  simp [hx, hy, arg_div_coe_angle, sub_eq_zero]
#align complex.same_ray_iff_arg_div_eq_zero Complex.sameRay_iff_arg_div_eq_zero
-/

#print Complex.abs_add_eq_iff /-
theorem abs_add_eq_iff : (x + y).abs = x.abs + y.abs ↔ x = 0 ∨ y = 0 ∨ x.arg = y.arg :=
  sameRay_iff_norm_add.symm.trans sameRay_iff
#align complex.abs_add_eq_iff Complex.abs_add_eq_iff
-/

#print Complex.abs_sub_eq_iff /-
theorem abs_sub_eq_iff : (x - y).abs = |x.abs - y.abs| ↔ x = 0 ∨ y = 0 ∨ x.arg = y.arg :=
  sameRay_iff_norm_sub.symm.trans sameRay_iff
#align complex.abs_sub_eq_iff Complex.abs_sub_eq_iff
-/

#print Complex.sameRay_of_arg_eq /-
theorem sameRay_of_arg_eq (h : x.arg = y.arg) : SameRay ℝ x y :=
  sameRay_iff.mpr <| Or.inr <| Or.inr h
#align complex.same_ray_of_arg_eq Complex.sameRay_of_arg_eq
-/

#print Complex.abs_add_eq /-
theorem abs_add_eq (h : x.arg = y.arg) : (x + y).abs = x.abs + y.abs :=
  (sameRay_of_arg_eq h).norm_add
#align complex.abs_add_eq Complex.abs_add_eq
-/

#print Complex.abs_sub_eq /-
theorem abs_sub_eq (h : x.arg = y.arg) : (x - y).abs = ‖x.abs - y.abs‖ :=
  (sameRay_of_arg_eq h).norm_sub
#align complex.abs_sub_eq Complex.abs_sub_eq
-/

end Complex

