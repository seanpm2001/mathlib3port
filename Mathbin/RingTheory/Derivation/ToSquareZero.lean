/-
Copyright © 2020 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri, Andrew Yang

! This file was ported from Lean 3 source module ring_theory.derivation.to_square_zero
! leanprover-community/mathlib commit 5c1efce12ba86d4901463f61019832f6a4b1a0d0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Derivation.Basic
import Mathbin.RingTheory.Ideal.QuotientOperations

/-!
# Results

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

- `derivation_to_square_zero_equiv_lift`: The `R`-derivations from `A` into a square-zero ideal `I`
  of `B` corresponds to the lifts `A →ₐ[R] B` of the map `A →ₐ[R] B ⧸ I`.

-/


section ToSquareZero

universe u v w

variable {R : Type u} {A : Type v} {B : Type w} [CommSemiring R] [CommSemiring A] [CommRing B]

variable [Algebra R A] [Algebra R B] (I : Ideal B) (hI : I ^ 2 = ⊥)

#print diffToIdealOfQuotientCompEq /-
/-- If `f₁ f₂ : A →ₐ[R] B` are two lifts of the same `A →ₐ[R] B ⧸ I`,
  we may define a map `f₁ - f₂ : A →ₗ[R] I`. -/
def diffToIdealOfQuotientCompEq (f₁ f₂ : A →ₐ[R] B)
    (e : (Ideal.Quotient.mkₐ R I).comp f₁ = (Ideal.Quotient.mkₐ R I).comp f₂) : A →ₗ[R] I :=
  LinearMap.codRestrict (I.restrictScalars _) (f₁.toLinearMap - f₂.toLinearMap)
    (by
      intro x
      change f₁ x - f₂ x ∈ I
      rw [← Ideal.Quotient.eq, ← Ideal.Quotient.mkₐ_eq_mk R, ← AlgHom.comp_apply, e]
      rfl)
#align diff_to_ideal_of_quotient_comp_eq diffToIdealOfQuotientCompEq
-/

#print diffToIdealOfQuotientCompEq_apply /-
@[simp]
theorem diffToIdealOfQuotientCompEq_apply (f₁ f₂ : A →ₐ[R] B)
    (e : (Ideal.Quotient.mkₐ R I).comp f₁ = (Ideal.Quotient.mkₐ R I).comp f₂) (x : A) :
    ((diffToIdealOfQuotientCompEq I f₁ f₂ e) x : B) = f₁ x - f₂ x :=
  rfl
#align diff_to_ideal_of_quotient_comp_eq_apply diffToIdealOfQuotientCompEq_apply
-/

variable [Algebra A B] [IsScalarTower R A B]

#print derivationToSquareZeroOfLift /-
/-- Given a tower of algebras `R → A → B`, and a square-zero `I : ideal B`, each lift `A →ₐ[R] B`
of the canonical map `A →ₐ[R] B ⧸ I` corresponds to a `R`-derivation from `A` to `I`. -/
def derivationToSquareZeroOfLift (f : A →ₐ[R] B)
    (e : (Ideal.Quotient.mkₐ R I).comp f = IsScalarTower.toAlgHom R A (B ⧸ I)) : Derivation R A I :=
  by
  refine'
    {
      diffToIdealOfQuotientCompEq I f (IsScalarTower.toAlgHom R A B)
        _ with
      map_one_eq_zero' := _
      leibniz' := _ }
  · rw [e]; ext; rfl
  · ext; change f 1 - algebraMap A B 1 = 0; rw [map_one, map_one, sub_self]
  · intro x y
    let F := diffToIdealOfQuotientCompEq I f (IsScalarTower.toAlgHom R A B) (by rw [e]; ext; rfl)
    have : (f x - algebraMap A B x) * (f y - algebraMap A B y) = 0 :=
      by
      rw [← Ideal.mem_bot, ← hI, pow_two]
      convert Ideal.mul_mem_mul (F x).2 (F y).2 using 1
    ext
    dsimp only [Submodule.coe_add, Submodule.coe_mk, LinearMap.coe_mk,
      diffToIdealOfQuotientCompEq_apply, Submodule.coe_smul_of_tower, IsScalarTower.coe_toAlgHom',
      LinearMap.toFun_eq_coe]
    simp only [map_mul, sub_mul, mul_sub, Algebra.smul_def] at this ⊢
    rw [sub_eq_iff_eq_add, sub_eq_iff_eq_add] at this 
    rw [this]
    ring
#align derivation_to_square_zero_of_lift derivationToSquareZeroOfLift
-/

#print derivationToSquareZeroOfLift_apply /-
theorem derivationToSquareZeroOfLift_apply (f : A →ₐ[R] B)
    (e : (Ideal.Quotient.mkₐ R I).comp f = IsScalarTower.toAlgHom R A (B ⧸ I)) (x : A) :
    (derivationToSquareZeroOfLift I hI f e x : B) = f x - algebraMap A B x :=
  rfl
#align derivation_to_square_zero_of_lift_apply derivationToSquareZeroOfLift_apply
-/

#print liftOfDerivationToSquareZero /-
/-- Given a tower of algebras `R → A → B`, and a square-zero `I : ideal B`, each `R`-derivation
from `A` to `I` corresponds to a lift `A →ₐ[R] B` of the canonical map `A →ₐ[R] B ⧸ I`. -/
@[simps (config := { attrs := [] })]
def liftOfDerivationToSquareZero (f : Derivation R A I) : A →ₐ[R] B :=
  {
    ((I.restrictScalars R).Subtype.comp f.toLinearMap + (IsScalarTower.toAlgHom R A B).toLinearMap :
      A →ₗ[R] B) with
    toFun := fun x => f x + algebraMap A B x
    map_one' := by rw [map_one, f.map_one_eq_zero, Submodule.coe_zero, zero_add]
    map_mul' := fun x y =>
      by
      have : (f x : B) * f y = 0 := by rw [← Ideal.mem_bot, ← hI, pow_two];
        convert Ideal.mul_mem_mul (f x).2 (f y).2 using 1
      simp only [map_mul, f.leibniz, add_mul, mul_add, Submodule.coe_add,
        Submodule.coe_smul_of_tower, Algebra.smul_def, this]
      ring
    commutes' := fun r => by
      simp only [Derivation.map_algebraMap, eq_self_iff_true, zero_add, Submodule.coe_zero, ←
        IsScalarTower.algebraMap_apply R A B r]
    map_zero' :=
      ((I.restrictScalars R).Subtype.comp f.toLinearMap +
          (IsScalarTower.toAlgHom R A B).toLinearMap).map_zero }
#align lift_of_derivation_to_square_zero liftOfDerivationToSquareZero
-/

#print liftOfDerivationToSquareZero_mk_apply /-
@[simp]
theorem liftOfDerivationToSquareZero_mk_apply (d : Derivation R A I) (x : A) :
    Ideal.Quotient.mk I (liftOfDerivationToSquareZero I hI d x) = algebraMap A (B ⧸ I) x :=
  by
  rw [liftOfDerivationToSquareZero_apply, map_add, ideal.quotient.eq_zero_iff_mem.mpr (d x).Prop,
    zero_add]
  rfl
#align lift_of_derivation_to_square_zero_mk_apply liftOfDerivationToSquareZero_mk_apply
-/

#print derivationToSquareZeroEquivLift /-
/-- Given a tower of algebras `R → A → B`, and a square-zero `I : ideal B`,
there is a 1-1 correspondance between `R`-derivations from `A` to `I` and
lifts `A →ₐ[R] B` of the canonical map `A →ₐ[R] B ⧸ I`. -/
@[simps]
def derivationToSquareZeroEquivLift :
    Derivation R A I ≃
      { f : A →ₐ[R] B // (Ideal.Quotient.mkₐ R I).comp f = IsScalarTower.toAlgHom R A (B ⧸ I) } :=
  by
  refine'
    ⟨fun d => ⟨liftOfDerivationToSquareZero I hI d, _⟩, fun f =>
      (derivationToSquareZeroOfLift I hI f.1 f.2 : _), _, _⟩
  · ext x; exact liftOfDerivationToSquareZero_mk_apply I hI d x
  · intro d; ext x; exact add_sub_cancel (d x : B) (algebraMap A B x)
  · rintro ⟨f, hf⟩; ext x; exact sub_add_cancel (f x) (algebraMap A B x)
#align derivation_to_square_zero_equiv_lift derivationToSquareZeroEquivLift
-/

end ToSquareZero

