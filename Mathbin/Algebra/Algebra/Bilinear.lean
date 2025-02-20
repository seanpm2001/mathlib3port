/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.algebra.bilinear
! leanprover-community/mathlib commit 832f7b9162039c28b9361289c8681f155cae758f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Basic
import Mathbin.Algebra.Hom.Iterate
import Mathbin.Algebra.Hom.NonUnitalAlg
import Mathbin.LinearAlgebra.TensorProduct

/-!
# Facts about algebras involving bilinear maps and tensor products

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We move a few basic statements about algebras out of `algebra.algebra.basic`,
in order to avoid importing `linear_algebra.bilinear_map` and
`linear_algebra.tensor_product` unnecessarily.
-/


open scoped TensorProduct

open Module

namespace LinearMap

section NonUnitalNonAssoc

variable (R A : Type _) [CommSemiring R] [NonUnitalNonAssocSemiring A] [Module R A]
  [SMulCommClass R A A] [IsScalarTower R A A]

#print LinearMap.mul /-
/-- The multiplication in a non-unital non-associative algebra is a bilinear map.

A weaker version of this for semirings exists as `add_monoid_hom.mul`. -/
def mul : A →ₗ[R] A →ₗ[R] A :=
  LinearMap.mk₂ R (· * ·) add_mul smul_mul_assoc mul_add mul_smul_comm
#align linear_map.mul LinearMap.mul
-/

#print LinearMap.mul' /-
/-- The multiplication map on a non-unital algebra, as an `R`-linear map from `A ⊗[R] A` to `A`. -/
def mul' : A ⊗[R] A →ₗ[R] A :=
  TensorProduct.lift (mul R A)
#align linear_map.mul' LinearMap.mul'
-/

variable {A}

#print LinearMap.mulLeft /-
/-- The multiplication on the left in a non-unital algebra is a linear map. -/
def mulLeft (a : A) : A →ₗ[R] A :=
  mul R A a
#align linear_map.mul_left LinearMap.mulLeft
-/

#print LinearMap.mulRight /-
/-- The multiplication on the right in an algebra is a linear map. -/
def mulRight (a : A) : A →ₗ[R] A :=
  (mul R A).flip a
#align linear_map.mul_right LinearMap.mulRight
-/

#print LinearMap.mulLeftRight /-
/-- Simultaneous multiplication on the left and right is a linear map. -/
def mulLeftRight (ab : A × A) : A →ₗ[R] A :=
  (mulRight R ab.snd).comp (mulLeft R ab.fst)
#align linear_map.mul_left_right LinearMap.mulLeftRight
-/

#print LinearMap.mulLeft_toAddMonoidHom /-
@[simp]
theorem mulLeft_toAddMonoidHom (a : A) : (mulLeft R a : A →+ A) = AddMonoidHom.mulLeft a :=
  rfl
#align linear_map.mul_left_to_add_monoid_hom LinearMap.mulLeft_toAddMonoidHom
-/

#print LinearMap.mulRight_toAddMonoidHom /-
@[simp]
theorem mulRight_toAddMonoidHom (a : A) : (mulRight R a : A →+ A) = AddMonoidHom.mulRight a :=
  rfl
#align linear_map.mul_right_to_add_monoid_hom LinearMap.mulRight_toAddMonoidHom
-/

variable {R}

#print LinearMap.mul_apply' /-
@[simp]
theorem mul_apply' (a b : A) : mul R A a b = a * b :=
  rfl
#align linear_map.mul_apply' LinearMap.mul_apply'
-/

#print LinearMap.mulLeft_apply /-
@[simp]
theorem mulLeft_apply (a b : A) : mulLeft R a b = a * b :=
  rfl
#align linear_map.mul_left_apply LinearMap.mulLeft_apply
-/

#print LinearMap.mulRight_apply /-
@[simp]
theorem mulRight_apply (a b : A) : mulRight R a b = b * a :=
  rfl
#align linear_map.mul_right_apply LinearMap.mulRight_apply
-/

#print LinearMap.mulLeftRight_apply /-
@[simp]
theorem mulLeftRight_apply (a b x : A) : mulLeftRight R (a, b) x = a * x * b :=
  rfl
#align linear_map.mul_left_right_apply LinearMap.mulLeftRight_apply
-/

#print LinearMap.mul'_apply /-
@[simp]
theorem mul'_apply {a b : A} : mul' R A (a ⊗ₜ b) = a * b :=
  rfl
#align linear_map.mul'_apply LinearMap.mul'_apply
-/

#print LinearMap.mulLeft_zero_eq_zero /-
@[simp]
theorem mulLeft_zero_eq_zero : mulLeft R (0 : A) = 0 :=
  (mul R A).map_zero
#align linear_map.mul_left_zero_eq_zero LinearMap.mulLeft_zero_eq_zero
-/

#print LinearMap.mulRight_zero_eq_zero /-
@[simp]
theorem mulRight_zero_eq_zero : mulRight R (0 : A) = 0 :=
  (mul R A).flip.map_zero
#align linear_map.mul_right_zero_eq_zero LinearMap.mulRight_zero_eq_zero
-/

end NonUnitalNonAssoc

section NonUnital

variable (R A : Type _) [CommSemiring R] [NonUnitalSemiring A] [Module R A] [SMulCommClass R A A]
  [IsScalarTower R A A]

#print NonUnitalAlgHom.lmul /-
/-- The multiplication in a non-unital algebra is a bilinear map.

A weaker version of this for non-unital non-associative algebras exists as `linear_map.mul`. -/
def NonUnitalAlgHom.lmul : A →ₙₐ[R] End R A :=
  { mul R A with
    map_mul' := by intro a b; ext c; exact mul_assoc a b c
    map_zero' := by ext a; exact MulZeroClass.zero_mul a }
#align non_unital_alg_hom.lmul NonUnitalAlgHom.lmul
-/

variable {R A}

#print NonUnitalAlgHom.coe_lmul_eq_mul /-
@[simp]
theorem NonUnitalAlgHom.coe_lmul_eq_mul : ⇑(NonUnitalAlgHom.lmul R A) = mul R A :=
  rfl
#align non_unital_alg_hom.coe_lmul_eq_mul NonUnitalAlgHom.coe_lmul_eq_mul
-/

#print LinearMap.commute_mulLeft_right /-
theorem commute_mulLeft_right (a b : A) : Commute (mulLeft R a) (mulRight R b) := by ext c;
  exact (mul_assoc a c b).symm
#align linear_map.commute_mul_left_right LinearMap.commute_mulLeft_right
-/

#print LinearMap.mulLeft_mul /-
@[simp]
theorem mulLeft_mul (a b : A) : mulLeft R (a * b) = (mulLeft R a).comp (mulLeft R b) := by ext;
  simp only [mul_left_apply, comp_apply, mul_assoc]
#align linear_map.mul_left_mul LinearMap.mulLeft_mul
-/

#print LinearMap.mulRight_mul /-
@[simp]
theorem mulRight_mul (a b : A) : mulRight R (a * b) = (mulRight R b).comp (mulRight R a) := by ext;
  simp only [mul_right_apply, comp_apply, mul_assoc]
#align linear_map.mul_right_mul LinearMap.mulRight_mul
-/

end NonUnital

section Semiring

variable (R A : Type _) [CommSemiring R] [Semiring A] [Algebra R A]

#print Algebra.lmul /-
/-- The multiplication in an algebra is an algebra homomorphism into the endomorphisms on
the algebra.

A weaker version of this for non-unital algebras exists as `non_unital_alg_hom.mul`. -/
def Algebra.lmul : A →ₐ[R] End R A :=
  { LinearMap.mul R A with
    map_one' := by ext a; exact one_mul a
    map_mul' := by intro a b; ext c; exact mul_assoc a b c
    map_zero' := by ext a; exact MulZeroClass.zero_mul a
    commutes' := by intro r; ext a; exact (Algebra.smul_def r a).symm }
#align algebra.lmul Algebra.lmul
-/

variable {R A}

#print Algebra.coe_lmul_eq_mul /-
@[simp]
theorem Algebra.coe_lmul_eq_mul : ⇑(Algebra.lmul R A) = mul R A :=
  rfl
#align algebra.coe_lmul_eq_mul Algebra.coe_lmul_eq_mul
-/

#print LinearMap.mulLeft_eq_zero_iff /-
@[simp]
theorem mulLeft_eq_zero_iff (a : A) : mulLeft R a = 0 ↔ a = 0 :=
  by
  constructor <;> intro h
  · rw [← mul_one a, ← mul_left_apply a 1, h, LinearMap.zero_apply]
  · rw [h]; exact mul_left_zero_eq_zero
#align linear_map.mul_left_eq_zero_iff LinearMap.mulLeft_eq_zero_iff
-/

#print LinearMap.mulRight_eq_zero_iff /-
@[simp]
theorem mulRight_eq_zero_iff (a : A) : mulRight R a = 0 ↔ a = 0 :=
  by
  constructor <;> intro h
  · rw [← one_mul a, ← mul_right_apply a 1, h, LinearMap.zero_apply]
  · rw [h]; exact mul_right_zero_eq_zero
#align linear_map.mul_right_eq_zero_iff LinearMap.mulRight_eq_zero_iff
-/

#print LinearMap.mulLeft_one /-
@[simp]
theorem mulLeft_one : mulLeft R (1 : A) = LinearMap.id := by ext;
  simp only [LinearMap.id_coe, one_mul, id.def, mul_left_apply]
#align linear_map.mul_left_one LinearMap.mulLeft_one
-/

#print LinearMap.mulRight_one /-
@[simp]
theorem mulRight_one : mulRight R (1 : A) = LinearMap.id := by ext;
  simp only [LinearMap.id_coe, mul_one, id.def, mul_right_apply]
#align linear_map.mul_right_one LinearMap.mulRight_one
-/

#print LinearMap.pow_mulLeft /-
@[simp]
theorem pow_mulLeft (a : A) (n : ℕ) : mulLeft R a ^ n = mulLeft R (a ^ n) := by
  simpa only [mul_left, ← Algebra.coe_lmul_eq_mul] using ((Algebra.lmul R A).map_pow a n).symm
#align linear_map.pow_mul_left LinearMap.pow_mulLeft
-/

#print LinearMap.pow_mulRight /-
@[simp]
theorem pow_mulRight (a : A) (n : ℕ) : mulRight R a ^ n = mulRight R (a ^ n) :=
  by
  simp only [mul_right, ← Algebra.coe_lmul_eq_mul]
  exact
    LinearMap.coe_injective (((mul_right R a).val_pow_eq_pow_val n).symm ▸ mul_right_iterate a n)
#align linear_map.pow_mul_right LinearMap.pow_mulRight
-/

end Semiring

section Ring

variable {R A : Type _} [CommSemiring R] [Ring A] [Algebra R A]

#print LinearMap.mulLeft_injective /-
theorem mulLeft_injective [NoZeroDivisors A] {x : A} (hx : x ≠ 0) :
    Function.Injective (mulLeft R x) :=
  by
  letI : Nontrivial A := ⟨⟨x, 0, hx⟩⟩
  letI := NoZeroDivisors.to_isDomain A
  exact mul_right_injective₀ hx
#align linear_map.mul_left_injective LinearMap.mulLeft_injective
-/

#print LinearMap.mulRight_injective /-
theorem mulRight_injective [NoZeroDivisors A] {x : A} (hx : x ≠ 0) :
    Function.Injective (mulRight R x) :=
  by
  letI : Nontrivial A := ⟨⟨x, 0, hx⟩⟩
  letI := NoZeroDivisors.to_isDomain A
  exact mul_left_injective₀ hx
#align linear_map.mul_right_injective LinearMap.mulRight_injective
-/

#print LinearMap.mul_injective /-
theorem mul_injective [NoZeroDivisors A] {x : A} (hx : x ≠ 0) : Function.Injective (mul R A x) :=
  by
  letI : Nontrivial A := ⟨⟨x, 0, hx⟩⟩
  letI := NoZeroDivisors.to_isDomain A
  exact mul_right_injective₀ hx
#align linear_map.mul_injective LinearMap.mul_injective
-/

end Ring

end LinearMap

