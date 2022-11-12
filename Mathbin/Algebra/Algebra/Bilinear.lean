/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Yury Kudryashov
-/
import Mathbin.Algebra.Algebra.Basic
import Mathbin.Algebra.Hom.Iterate
import Mathbin.Algebra.Hom.NonUnitalAlg
import Mathbin.LinearAlgebra.TensorProduct

/-!
# Facts about algebras involving bilinear maps and tensor products

We move a few basic statements about algebras out of `algebra.algebra.basic`,
in order to avoid importing `linear_algebra.bilinear_map` and
`linear_algebra.tensor_product` unnecessarily.
-/


open TensorProduct

open Module

namespace LinearMap

section NonUnitalNonAssoc

variable (R A : Type _) [CommSemiring R] [NonUnitalNonAssocSemiring A] [Module R A] [SmulCommClass R A A]
  [IsScalarTower R A A]

/-- The multiplication in a non-unital non-associative algebra is a bilinear map.

A weaker version of this for semirings exists as `add_monoid_hom.mul`. -/
def mul : A →ₗ[R] A →ₗ[R] A :=
  LinearMap.mk₂ R (· * ·) add_mul smul_mul_assoc mul_add mul_smul_comm
#align linear_map.mul LinearMap.mul

/-- The multiplication map on a non-unital algebra, as an `R`-linear map from `A ⊗[R] A` to `A`. -/
def mul' : A ⊗[R] A →ₗ[R] A :=
  TensorProduct.lift (mul R A)
#align linear_map.mul' LinearMap.mul'

variable {A}

/-- The multiplication on the left in a non-unital algebra is a linear map. -/
def mulLeft (a : A) : A →ₗ[R] A :=
  mul R A a
#align linear_map.mul_left LinearMap.mulLeft

/-- The multiplication on the right in an algebra is a linear map. -/
def mulRight (a : A) : A →ₗ[R] A :=
  (mul R A).flip a
#align linear_map.mul_right LinearMap.mulRight

/-- Simultaneous multiplication on the left and right is a linear map. -/
def mulLeftRight (ab : A × A) : A →ₗ[R] A :=
  (mulRight R ab.snd).comp (mulLeft R ab.fst)
#align linear_map.mul_left_right LinearMap.mulLeftRight

@[simp]
theorem mul_left_to_add_monoid_hom (a : A) : (mulLeft R a : A →+ A) = AddMonoidHom.mulLeft a :=
  rfl
#align linear_map.mul_left_to_add_monoid_hom LinearMap.mul_left_to_add_monoid_hom

@[simp]
theorem mul_right_to_add_monoid_hom (a : A) : (mulRight R a : A →+ A) = AddMonoidHom.mulRight a :=
  rfl
#align linear_map.mul_right_to_add_monoid_hom LinearMap.mul_right_to_add_monoid_hom

variable {R}

@[simp]
theorem mul_apply' (a b : A) : mul R A a b = a * b :=
  rfl
#align linear_map.mul_apply' LinearMap.mul_apply'

@[simp]
theorem mul_left_apply (a b : A) : mulLeft R a b = a * b :=
  rfl
#align linear_map.mul_left_apply LinearMap.mul_left_apply

@[simp]
theorem mul_right_apply (a b : A) : mulRight R a b = b * a :=
  rfl
#align linear_map.mul_right_apply LinearMap.mul_right_apply

@[simp]
theorem mul_left_right_apply (a b x : A) : mulLeftRight R (a, b) x = a * x * b :=
  rfl
#align linear_map.mul_left_right_apply LinearMap.mul_left_right_apply

@[simp]
theorem mul'_apply {a b : A} : mul' R A (a ⊗ₜ b) = a * b := by
  simp only [LinearMap.mul', TensorProduct.lift.tmul, mul_apply']
#align linear_map.mul'_apply LinearMap.mul'_apply

@[simp]
theorem mul_left_zero_eq_zero : mulLeft R (0 : A) = 0 :=
  (mul R A).map_zero
#align linear_map.mul_left_zero_eq_zero LinearMap.mul_left_zero_eq_zero

@[simp]
theorem mul_right_zero_eq_zero : mulRight R (0 : A) = 0 :=
  (mul R A).flip.map_zero
#align linear_map.mul_right_zero_eq_zero LinearMap.mul_right_zero_eq_zero

end NonUnitalNonAssoc

section NonUnital

variable (R A : Type _) [CommSemiring R] [NonUnitalSemiring A] [Module R A] [SmulCommClass R A A] [IsScalarTower R A A]

/-- The multiplication in a non-unital algebra is a bilinear map.

A weaker version of this for non-unital non-associative algebras exists as `linear_map.mul`. -/
def _root_.non_unital_alg_hom.lmul : A →ₙₐ[R] EndCat R A :=
  { mul R A with
    map_mul' := by
      intro a b
      ext c
      exact mul_assoc a b c,
    map_zero' := by
      ext a
      exact zero_mul a }
#align linear_map._root_.non_unital_alg_hom.lmul linear_map._root_.non_unital_alg_hom.lmul

variable {R A}

@[simp]
theorem _root_.non_unital_alg_hom.coe_lmul_eq_mul : ⇑(NonUnitalAlgHom.lmul R A) = mul R A :=
  rfl
#align linear_map._root_.non_unital_alg_hom.coe_lmul_eq_mul linear_map._root_.non_unital_alg_hom.coe_lmul_eq_mul

theorem commute_mul_left_right (a b : A) : Commute (mulLeft R a) (mulRight R b) := by
  ext c
  exact (mul_assoc a c b).symm
#align linear_map.commute_mul_left_right LinearMap.commute_mul_left_right

@[simp]
theorem mul_left_mul (a b : A) : mulLeft R (a * b) = (mulLeft R a).comp (mulLeft R b) := by
  ext
  simp only [mul_left_apply, comp_apply, mul_assoc]
#align linear_map.mul_left_mul LinearMap.mul_left_mul

@[simp]
theorem mul_right_mul (a b : A) : mulRight R (a * b) = (mulRight R b).comp (mulRight R a) := by
  ext
  simp only [mul_right_apply, comp_apply, mul_assoc]
#align linear_map.mul_right_mul LinearMap.mul_right_mul

end NonUnital

section Semiring

variable (R A : Type _) [CommSemiring R] [Semiring A] [Algebra R A]

/-- The multiplication in an algebra is an algebra homomorphism into the endomorphisms on
the algebra.

A weaker version of this for non-unital algebras exists as `non_unital_alg_hom.mul`. -/
def _root_.algebra.lmul : A →ₐ[R] EndCat R A :=
  { LinearMap.mul R A with
    map_one' := by
      ext a
      exact one_mul a,
    map_mul' := by
      intro a b
      ext c
      exact mul_assoc a b c,
    map_zero' := by
      ext a
      exact zero_mul a,
    commutes' := by
      intro r
      ext a
      exact (Algebra.smul_def r a).symm }
#align linear_map._root_.algebra.lmul linear_map._root_.algebra.lmul

variable {R A}

@[simp]
theorem _root_.algebra.coe_lmul_eq_mul : ⇑(Algebra.lmul R A) = mul R A :=
  rfl
#align linear_map._root_.algebra.coe_lmul_eq_mul linear_map._root_.algebra.coe_lmul_eq_mul

@[simp]
theorem mul_left_eq_zero_iff (a : A) : mulLeft R a = 0 ↔ a = 0 := by
  constructor <;> intro h
  · rw [← mul_one a, ← mul_left_apply a 1, h, LinearMap.zero_apply]
    
  · rw [h]
    exact mul_left_zero_eq_zero
    
#align linear_map.mul_left_eq_zero_iff LinearMap.mul_left_eq_zero_iff

@[simp]
theorem mul_right_eq_zero_iff (a : A) : mulRight R a = 0 ↔ a = 0 := by
  constructor <;> intro h
  · rw [← one_mul a, ← mul_right_apply a 1, h, LinearMap.zero_apply]
    
  · rw [h]
    exact mul_right_zero_eq_zero
    
#align linear_map.mul_right_eq_zero_iff LinearMap.mul_right_eq_zero_iff

@[simp]
theorem mul_left_one : mulLeft R (1 : A) = LinearMap.id := by
  ext
  simp only [LinearMap.id_coe, one_mul, id.def, mul_left_apply]
#align linear_map.mul_left_one LinearMap.mul_left_one

@[simp]
theorem mul_right_one : mulRight R (1 : A) = LinearMap.id := by
  ext
  simp only [LinearMap.id_coe, mul_one, id.def, mul_right_apply]
#align linear_map.mul_right_one LinearMap.mul_right_one

@[simp]
theorem pow_mul_left (a : A) (n : ℕ) : mulLeft R a ^ n = mulLeft R (a ^ n) := by
  simpa only [mul_left, ← Algebra.coe_lmul_eq_mul] using ((Algebra.lmul R A).map_pow a n).symm
#align linear_map.pow_mul_left LinearMap.pow_mul_left

@[simp]
theorem pow_mul_right (a : A) (n : ℕ) : mulRight R a ^ n = mulRight R (a ^ n) := by
  simp only [mul_right, ← Algebra.coe_lmul_eq_mul]
  exact LinearMap.coe_injective (((mul_right R a).coe_pow n).symm ▸ mul_right_iterate a n)
#align linear_map.pow_mul_right LinearMap.pow_mul_right

end Semiring

section Ring

variable {R A : Type _} [CommSemiring R] [Ring A] [Algebra R A]

theorem mul_left_injective [NoZeroDivisors A] {x : A} (hx : x ≠ 0) : Function.Injective (mulLeft R x) :=
  letI : IsDomain A := { ‹Ring A›, ‹NoZeroDivisors A› with exists_pair_ne := ⟨x, 0, hx⟩ }
  mul_right_injective₀ hx
#align linear_map.mul_left_injective LinearMap.mul_left_injective

theorem mul_right_injective [NoZeroDivisors A] {x : A} (hx : x ≠ 0) : Function.Injective (mulRight R x) :=
  letI : IsDomain A := { ‹Ring A›, ‹NoZeroDivisors A› with exists_pair_ne := ⟨x, 0, hx⟩ }
  mul_left_injective₀ hx
#align linear_map.mul_right_injective LinearMap.mul_right_injective

theorem mul_injective [NoZeroDivisors A] {x : A} (hx : x ≠ 0) : Function.Injective (mul R A x) :=
  letI : IsDomain A := { ‹Ring A›, ‹NoZeroDivisors A› with exists_pair_ne := ⟨x, 0, hx⟩ }
  mul_right_injective₀ hx
#align linear_map.mul_injective LinearMap.mul_injective

end Ring

end LinearMap

