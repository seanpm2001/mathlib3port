/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module analysis.special_functions.complex.circle
! leanprover-community/mathlib commit 4280f5f32e16755ec7985ce11e189b6cd6ff6735
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Complex.Circle
import Mathbin.Analysis.SpecialFunctions.Complex.Log

/-!
# Maps on the unit circle

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove some basic lemmas about `exp_map_circle` and the restriction of `complex.arg`
to the unit circle. These two maps define a local equivalence between `circle` and `ℝ`, see
`circle.arg_local_equiv` and `circle.arg_equiv`, that sends the whole circle to `(-π, π]`.
-/


open Complex Function Set

open scoped Real

namespace circle

#print circle.injective_arg /-
theorem injective_arg : Injective fun z : circle => arg z := fun z w h =>
  Subtype.ext <| ext_abs_arg ((abs_coe_circle z).trans (abs_coe_circle w).symm) h
#align circle.injective_arg circle.injective_arg
-/

#print circle.arg_eq_arg /-
@[simp]
theorem arg_eq_arg {z w : circle} : arg z = arg w ↔ z = w :=
  injective_arg.eq_iff
#align circle.arg_eq_arg circle.arg_eq_arg
-/

end circle

#print arg_expMapCircle /-
theorem arg_expMapCircle {x : ℝ} (h₁ : -π < x) (h₂ : x ≤ π) : arg (expMapCircle x) = x := by
  rw [expMapCircle_apply, exp_mul_I, arg_cos_add_sin_mul_I ⟨h₁, h₂⟩]
#align arg_exp_map_circle arg_expMapCircle
-/

#print expMapCircle_arg /-
@[simp]
theorem expMapCircle_arg (z : circle) : expMapCircle (arg z) = z :=
  circle.injective_arg <| arg_expMapCircle (neg_pi_lt_arg _) (arg_le_pi _)
#align exp_map_circle_arg expMapCircle_arg
-/

namespace circle

#print circle.argLocalEquiv /-
/-- `complex.arg ∘ coe` and `exp_map_circle` define a local equivalence between `circle and `ℝ` with
`source = set.univ` and `target = set.Ioc (-π) π`. -/
@[simps (config := { fullyApplied := false })]
noncomputable def argLocalEquiv : LocalEquiv circle ℝ
    where
  toFun := arg ∘ coe
  invFun := expMapCircle
  source := univ
  target := Ioc (-π) π
  map_source' z _ := ⟨neg_pi_lt_arg _, arg_le_pi _⟩
  map_target' := mapsTo_univ _ _
  left_inv' z _ := expMapCircle_arg z
  right_inv' x hx := arg_expMapCircle hx.1 hx.2
#align circle.arg_local_equiv circle.argLocalEquiv
-/

#print circle.argEquiv /-
/-- `complex.arg` and `exp_map_circle` define an equivalence between `circle and `(-π, π]`. -/
@[simps (config := { fullyApplied := false })]
noncomputable def argEquiv : circle ≃ Ioc (-π) π
    where
  toFun z := ⟨arg z, neg_pi_lt_arg _, arg_le_pi _⟩
  invFun := expMapCircle ∘ coe
  left_inv z := argLocalEquiv.left_inv trivial
  right_inv x := Subtype.ext <| argLocalEquiv.right_inv x.2
#align circle.arg_equiv circle.argEquiv
-/

end circle

#print leftInverse_expMapCircle_arg /-
theorem leftInverse_expMapCircle_arg : LeftInverse expMapCircle (arg ∘ coe) :=
  expMapCircle_arg
#align left_inverse_exp_map_circle_arg leftInverse_expMapCircle_arg
-/

#print invOn_arg_expMapCircle /-
theorem invOn_arg_expMapCircle : InvOn (arg ∘ coe) expMapCircle (Ioc (-π) π) univ :=
  circle.argLocalEquiv.symm.InvOn
#align inv_on_arg_exp_map_circle invOn_arg_expMapCircle
-/

#print surjOn_expMapCircle_neg_pi_pi /-
theorem surjOn_expMapCircle_neg_pi_pi : SurjOn expMapCircle (Ioc (-π) π) univ :=
  circle.argLocalEquiv.symm.SurjOn
#align surj_on_exp_map_circle_neg_pi_pi surjOn_expMapCircle_neg_pi_pi
-/

#print expMapCircle_eq_expMapCircle /-
theorem expMapCircle_eq_expMapCircle {x y : ℝ} :
    expMapCircle x = expMapCircle y ↔ ∃ m : ℤ, x = y + m * (2 * π) :=
  by
  rw [Subtype.ext_iff, expMapCircle_apply, expMapCircle_apply, exp_eq_exp_iff_exists_int]
  refine' exists_congr fun n => _
  rw [← mul_assoc, ← add_mul, mul_left_inj' I_ne_zero, ← of_real_one, ← of_real_bit0, ← of_real_mul,
    ← of_real_int_cast, ← of_real_mul, ← of_real_add, of_real_inj]
#align exp_map_circle_eq_exp_map_circle expMapCircle_eq_expMapCircle
-/

#print periodic_expMapCircle /-
theorem periodic_expMapCircle : Periodic expMapCircle (2 * π) := fun z =>
  expMapCircle_eq_expMapCircle.2 ⟨1, by rw [Int.cast_one, one_mul]⟩
#align periodic_exp_map_circle periodic_expMapCircle
-/

#print expMapCircle_two_pi /-
@[simp]
theorem expMapCircle_two_pi : expMapCircle (2 * π) = 1 :=
  periodic_expMapCircle.Eq.trans expMapCircle_zero
#align exp_map_circle_two_pi expMapCircle_two_pi
-/

#print expMapCircle_sub_two_pi /-
theorem expMapCircle_sub_two_pi (x : ℝ) : expMapCircle (x - 2 * π) = expMapCircle x :=
  periodic_expMapCircle.sub_eq x
#align exp_map_circle_sub_two_pi expMapCircle_sub_two_pi
-/

#print expMapCircle_add_two_pi /-
theorem expMapCircle_add_two_pi (x : ℝ) : expMapCircle (x + 2 * π) = expMapCircle x :=
  periodic_expMapCircle x
#align exp_map_circle_add_two_pi expMapCircle_add_two_pi
-/

#print Real.Angle.expMapCircle /-
/-- `exp_map_circle`, applied to a `real.angle`. -/
noncomputable def Real.Angle.expMapCircle (θ : Real.Angle) : circle :=
  periodic_expMapCircle.lift θ
#align real.angle.exp_map_circle Real.Angle.expMapCircle
-/

#print Real.Angle.expMapCircle_coe /-
@[simp]
theorem Real.Angle.expMapCircle_coe (x : ℝ) : Real.Angle.expMapCircle x = expMapCircle x :=
  rfl
#align real.angle.exp_map_circle_coe Real.Angle.expMapCircle_coe
-/

#print Real.Angle.coe_expMapCircle /-
theorem Real.Angle.coe_expMapCircle (θ : Real.Angle) : (θ.expMapCircle : ℂ) = θ.cos + θ.sin * I :=
  by
  induction θ using Real.Angle.induction_on
  simp [Complex.exp_mul_I]
#align real.angle.coe_exp_map_circle Real.Angle.coe_expMapCircle
-/

#print Real.Angle.expMapCircle_zero /-
@[simp]
theorem Real.Angle.expMapCircle_zero : Real.Angle.expMapCircle 0 = 1 := by
  rw [← Real.Angle.coe_zero, Real.Angle.expMapCircle_coe, expMapCircle_zero]
#align real.angle.exp_map_circle_zero Real.Angle.expMapCircle_zero
-/

#print Real.Angle.expMapCircle_neg /-
@[simp]
theorem Real.Angle.expMapCircle_neg (θ : Real.Angle) :
    Real.Angle.expMapCircle (-θ) = (Real.Angle.expMapCircle θ)⁻¹ :=
  by
  induction θ using Real.Angle.induction_on
  simp_rw [← Real.Angle.coe_neg, Real.Angle.expMapCircle_coe, expMapCircle_neg]
#align real.angle.exp_map_circle_neg Real.Angle.expMapCircle_neg
-/

#print Real.Angle.expMapCircle_add /-
@[simp]
theorem Real.Angle.expMapCircle_add (θ₁ θ₂ : Real.Angle) :
    Real.Angle.expMapCircle (θ₁ + θ₂) = Real.Angle.expMapCircle θ₁ * Real.Angle.expMapCircle θ₂ :=
  by
  induction θ₁ using Real.Angle.induction_on
  induction θ₂ using Real.Angle.induction_on
  exact expMapCircle_add θ₁ θ₂
#align real.angle.exp_map_circle_add Real.Angle.expMapCircle_add
-/

#print Real.Angle.arg_expMapCircle /-
@[simp]
theorem Real.Angle.arg_expMapCircle (θ : Real.Angle) :
    (arg (Real.Angle.expMapCircle θ) : Real.Angle) = θ :=
  by
  induction θ using Real.Angle.induction_on
  rw [Real.Angle.expMapCircle_coe, expMapCircle_apply, exp_mul_I, ← of_real_cos, ← of_real_sin, ←
    Real.Angle.cos_coe, ← Real.Angle.sin_coe, arg_cos_add_sin_mul_I_coe_angle]
#align real.angle.arg_exp_map_circle Real.Angle.arg_expMapCircle
-/

