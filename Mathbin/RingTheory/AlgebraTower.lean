/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module ring_theory.algebra_tower
! leanprover-community/mathlib commit 932872382355f00112641d305ba0619305dc8642
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Tower
import Mathbin.Algebra.Invertible
import Mathbin.Algebra.Module.BigOperators
import Mathbin.LinearAlgebra.Basis

/-!
# Towers of algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We set up the basic theory of algebra towers.
An algebra tower A/S/R is expressed by having instances of `algebra A S`,
`algebra R S`, `algebra R A` and `is_scalar_tower R S A`, the later asserting the
compatibility condition `(r • s) • a = r • (s • a)`.

In `field_theory/tower.lean` we use this to prove the tower law for finite extensions,
that if `R` and `S` are both fields, then `[A:R] = [A:S] [S:A]`.

In this file we prepare the main lemma:
if `{bi | i ∈ I}` is an `R`-basis of `S` and `{cj | j ∈ J}` is a `S`-basis
of `A`, then `{bi cj | i ∈ I, j ∈ J}` is an `R`-basis of `A`. This statement does not require the
base rings to be a field, so we also generalize the lemma to rings in this file.
-/


open scoped Pointwise

universe u v w u₁

variable (R : Type u) (S : Type v) (A : Type w) (B : Type u₁)

namespace IsScalarTower

section Semiring

variable [CommSemiring R] [CommSemiring S] [Semiring A] [Semiring B]

variable [Algebra R S] [Algebra S A] [Algebra S B] [Algebra R A] [Algebra R B]

variable [IsScalarTower R S A] [IsScalarTower R S B]

variable (R S A B)

#print IsScalarTower.Invertible.algebraTower /-
/-- Suppose that `R -> S -> A` is a tower of algebras.
If an element `r : R` is invertible in `S`, then it is invertible in `A`. -/
def Invertible.algebraTower (r : R) [Invertible (algebraMap R S r)] :
    Invertible (algebraMap R A r) :=
  Invertible.copy (Invertible.map (algebraMap S A) (algebraMap R S r)) (algebraMap R A r)
    (IsScalarTower.algebraMap_apply R S A r)
#align is_scalar_tower.invertible.algebra_tower IsScalarTower.Invertible.algebraTower
-/

#print IsScalarTower.invertibleAlgebraCoeNat /-
/-- A natural number that is invertible when coerced to `R` is also invertible
when coerced to any `R`-algebra. -/
def invertibleAlgebraCoeNat (n : ℕ) [inv : Invertible (n : R)] : Invertible (n : A) :=
  haveI : Invertible (algebraMap ℕ R n) := inv
  invertible.algebra_tower ℕ R A n
#align is_scalar_tower.invertible_algebra_coe_nat IsScalarTower.invertibleAlgebraCoeNat
-/

end Semiring

section CommSemiring

variable [CommSemiring R] [CommSemiring A] [CommSemiring B]

variable [Algebra R A] [Algebra A B] [Algebra R B] [IsScalarTower R A B]

end CommSemiring

end IsScalarTower

section AlgebraMapCoeffs

variable {R} (A) {ι M : Type _} [CommSemiring R] [Semiring A] [AddCommMonoid M]

variable [Algebra R A] [Module A M] [Module R M] [IsScalarTower R A M]

variable (b : Basis ι R M) (h : Function.Bijective (algebraMap R A))

#print Basis.algebraMapCoeffs /-
/-- If `R` and `A` have a bijective `algebra_map R A` and act identically on `M`,
then a basis for `M` as `R`-module is also a basis for `M` as `R'`-module. -/
@[simps]
noncomputable def Basis.algebraMapCoeffs : Basis ι A M :=
  b.mapCoeffs (RingEquiv.ofBijective _ h) fun c x => by simp
#align basis.algebra_map_coeffs Basis.algebraMapCoeffs
-/

#print Basis.algebraMapCoeffs_apply /-
theorem Basis.algebraMapCoeffs_apply (i : ι) : b.algebraMapCoeffs A h i = b i :=
  b.mapCoeffs_apply _ _ _
#align basis.algebra_map_coeffs_apply Basis.algebraMapCoeffs_apply
-/

#print Basis.coe_algebraMapCoeffs /-
@[simp]
theorem Basis.coe_algebraMapCoeffs : (b.algebraMapCoeffs A h : ι → M) = b :=
  b.coe_mapCoeffs _ _
#align basis.coe_algebra_map_coeffs Basis.coe_algebraMapCoeffs
-/

end AlgebraMapCoeffs

section Semiring

open Finsupp

open scoped BigOperators Classical

universe v₁ w₁

variable {R S A}

variable [CommSemiring R] [Semiring S] [AddCommMonoid A]

variable [Algebra R S] [Module S A] [Module R A] [IsScalarTower R S A]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print linearIndependent_smul /-
theorem linearIndependent_smul {ι : Type v₁} {b : ι → S} {ι' : Type w₁} {c : ι' → A}
    (hb : LinearIndependent R b) (hc : LinearIndependent S c) :
    LinearIndependent R fun p : ι × ι' => b p.1 • c p.2 :=
  by
  rw [linearIndependent_iff'] at hb hc ; rw [linearIndependent_iff'']; rintro s g hg hsg ⟨i, k⟩
  by_cases hik : (i, k) ∈ s
  · have h1 : ∑ i in s.image Prod.fst ×ˢ s.image Prod.snd, g i • b i.1 • c i.2 = 0 := by rw [← hsg];
      exact
        (Finset.sum_subset Finset.subset_product fun p _ hp =>
            show g p • b p.1 • c p.2 = 0 by rw [hg p hp, zero_smul]).symm
    rw [Finset.sum_product_right] at h1 
    simp_rw [← smul_assoc, ← Finset.sum_smul] at h1 
    exact hb _ _ (hc _ _ h1 k (Finset.mem_image_of_mem _ hik)) i (Finset.mem_image_of_mem _ hik)
  exact hg _ hik
#align linear_independent_smul linearIndependent_smul
-/

#print Basis.smul /-
/-- `basis.smul (b : basis ι R S) (c : basis ι S A)` is the `R`-basis on `A`
where the `(i, j)`th basis vector is `b i • c j`. -/
noncomputable def Basis.smul {ι : Type v₁} {ι' : Type w₁} (b : Basis ι R S) (c : Basis ι' S A) :
    Basis (ι × ι') R A :=
  Basis.ofRepr
    (c.repr.restrictScalars R ≪≫ₗ
      (Finsupp.lcongr (Equiv.refl _) b.repr ≪≫ₗ
        ((finsuppProdLEquiv R).symm ≪≫ₗ
          Finsupp.lcongr (Equiv.prodComm ι' ι) (LinearEquiv.refl _ _))))
#align basis.smul Basis.smul
-/

#print Basis.smul_repr /-
@[simp]
theorem Basis.smul_repr {ι : Type v₁} {ι' : Type w₁} (b : Basis ι R S) (c : Basis ι' S A) (x ij) :
    (b.smul c).repr x ij = b.repr (c.repr x ij.2) ij.1 := by simp [Basis.smul]
#align basis.smul_repr Basis.smul_repr
-/

#print Basis.smul_repr_mk /-
theorem Basis.smul_repr_mk {ι : Type v₁} {ι' : Type w₁} (b : Basis ι R S) (c : Basis ι' S A)
    (x i j) : (b.smul c).repr x (i, j) = b.repr (c.repr x j) i :=
  b.smul_repr c x (i, j)
#align basis.smul_repr_mk Basis.smul_repr_mk
-/

#print Basis.smul_apply /-
@[simp]
theorem Basis.smul_apply {ι : Type v₁} {ι' : Type w₁} (b : Basis ι R S) (c : Basis ι' S A) (ij) :
    (b.smul c) ij = b ij.1 • c ij.2 := by
  obtain ⟨i, j⟩ := ij
  rw [Basis.apply_eq_iff]
  ext ⟨i', j'⟩
  rw [Basis.smul_repr, LinearEquiv.map_smul, Basis.repr_self, Finsupp.smul_apply,
    Finsupp.single_apply]
  dsimp only
  split_ifs with hi
  · simp [hi, Finsupp.single_apply]
  · simp [hi]
#align basis.smul_apply Basis.smul_apply
-/

end Semiring

section Ring

variable {R S}

variable [CommRing R] [Ring S] [Algebra R S]

#print Basis.algebraMap_injective /-
theorem Basis.algebraMap_injective {ι : Type _} [NoZeroDivisors R] [Nontrivial S]
    (b : Basis ι R S) : Function.Injective (algebraMap R S) :=
  have : NoZeroSMulDivisors R S := b.NoZeroSMulDivisors
  NoZeroSMulDivisors.algebraMap_injective R S
#align basis.algebra_map_injective Basis.algebraMap_injective
-/

end Ring

section AlgHomTower

variable {A} {C D : Type _} [CommSemiring A] [CommSemiring C] [CommSemiring D] [Algebra A C]
  [Algebra A D]

variable (f : C →ₐ[A] D) (B) [CommSemiring B] [Algebra A B] [Algebra B C] [IsScalarTower A B C]

#print AlgHom.restrictDomain /-
/-- Restrict the domain of an `alg_hom`. -/
def AlgHom.restrictDomain : B →ₐ[A] D :=
  f.comp (IsScalarTower.toAlgHom A B C)
#align alg_hom.restrict_domain AlgHom.restrictDomain
-/

#print AlgHom.extendScalars /-
/-- Extend the scalars of an `alg_hom`. -/
def AlgHom.extendScalars : @AlgHom B C D _ _ _ _ (f.restrictDomain B).toRingHom.toAlgebra :=
  { f with commutes' := fun _ => rfl }
#align alg_hom.extend_scalars AlgHom.extendScalars
-/

variable {B}

#print algHomEquivSigma /-
/-- `alg_hom`s from the top of a tower are equivalent to a pair of `alg_hom`s. -/
def algHomEquivSigma : (C →ₐ[A] D) ≃ Σ f : B →ₐ[A] D, @AlgHom B C D _ _ _ _ f.toRingHom.toAlgebra
    where
  toFun f := ⟨f.restrictDomain B, f.extendScalars B⟩
  invFun fg :=
    let alg := fg.1.toRingHom.toAlgebra
    fg.2.restrictScalars A
  left_inv f := by dsimp only; ext; rfl
  right_inv := by
    rintro ⟨⟨f, _, _, _, _, _⟩, g, _, _, _, _, hg⟩
    obtain rfl : f = fun x => g (algebraMap B C x) := by ext; exact (hg x).symm
    rfl
#align alg_hom_equiv_sigma algHomEquivSigma
-/

end AlgHomTower

