/-
Copyright (c) 2020 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying, Eric Wieser

! This file was ported from Lean 3 source module linear_algebra.quadratic_form.isometry
! leanprover-community/mathlib commit c20927220ef87bb4962ba08bf6da2ce3cf50a6dd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.QuadraticForm.Basic

/-!
# Isometries with respect to quadratic forms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `quadratic_form.isometry`: `linear_equiv`s which map between two different quadratic forms
* `quadratic_form.equvialent`: propositional version of the above

## Main results

* `equivalent_weighted_sum_squares`: in finite dimensions, any quadratic form is equivalent to a
  parametrization of `quadratic_form.weighted_sum_squares`.
-/


variable {ι R K M M₁ M₂ M₃ V : Type _}

namespace QuadraticForm

variable [Semiring R]

variable [AddCommMonoid M] [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [Module R M] [Module R M₁] [Module R M₂] [Module R M₃]

#print QuadraticForm.Isometry /-
/-- An isometry between two quadratic spaces `M₁, Q₁` and `M₂, Q₂` over a ring `R`,
is a linear equivalence between `M₁` and `M₂` that commutes with the quadratic forms. -/
@[nolint has_nonempty_instance]
structure Isometry (Q₁ : QuadraticForm R M₁) (Q₂ : QuadraticForm R M₂) extends M₁ ≃ₗ[R] M₂ where
  map_app' : ∀ m, Q₂ (to_fun m) = Q₁ m
#align quadratic_form.isometry QuadraticForm.Isometry
-/

#print QuadraticForm.Equivalent /-
/-- Two quadratic forms over a ring `R` are equivalent
if there exists an isometry between them:
a linear equivalence that transforms one quadratic form into the other. -/
def Equivalent (Q₁ : QuadraticForm R M₁) (Q₂ : QuadraticForm R M₂) :=
  Nonempty (Q₁.Isometry Q₂)
#align quadratic_form.equivalent QuadraticForm.Equivalent
-/

namespace Isometry

variable {Q₁ : QuadraticForm R M₁} {Q₂ : QuadraticForm R M₂} {Q₃ : QuadraticForm R M₃}

instance : Coe (Q₁.Isometry Q₂) (M₁ ≃ₗ[R] M₂) :=
  ⟨Isometry.toLinearEquiv⟩

@[simp]
theorem toLinearEquiv_eq_coe (f : Q₁.Isometry Q₂) : f.toLinearEquiv = f :=
  rfl
#align quadratic_form.isometry.to_linear_equiv_eq_coe QuadraticForm.Isometry.toLinearEquiv_eq_coe

instance : CoeFun (Q₁.Isometry Q₂) fun _ => M₁ → M₂ :=
  ⟨fun f => ⇑(f : M₁ ≃ₗ[R] M₂)⟩

#print QuadraticForm.Isometry.coe_toLinearEquiv /-
@[simp]
theorem coe_toLinearEquiv (f : Q₁.Isometry Q₂) : ⇑(f : M₁ ≃ₗ[R] M₂) = f :=
  rfl
#align quadratic_form.isometry.coe_to_linear_equiv QuadraticForm.Isometry.coe_toLinearEquiv
-/

#print QuadraticForm.Isometry.map_app /-
@[simp]
theorem map_app (f : Q₁.Isometry Q₂) (m : M₁) : Q₂ (f m) = Q₁ m :=
  f.map_app' m
#align quadratic_form.isometry.map_app QuadraticForm.Isometry.map_app
-/

#print QuadraticForm.Isometry.refl /-
/-- The identity isometry from a quadratic form to itself. -/
@[refl]
def refl (Q : QuadraticForm R M) : Q.Isometry Q :=
  { LinearEquiv.refl R M with map_app' := fun m => rfl }
#align quadratic_form.isometry.refl QuadraticForm.Isometry.refl
-/

#print QuadraticForm.Isometry.symm /-
/-- The inverse isometry of an isometry between two quadratic forms. -/
@[symm]
def symm (f : Q₁.Isometry Q₂) : Q₂.Isometry Q₁ :=
  { (f : M₁ ≃ₗ[R] M₂).symm with
    map_app' := by intro m; rw [← f.map_app]; congr; exact f.to_linear_equiv.apply_symm_apply m }
#align quadratic_form.isometry.symm QuadraticForm.Isometry.symm
-/

#print QuadraticForm.Isometry.trans /-
/-- The composition of two isometries between quadratic forms. -/
@[trans]
def trans (f : Q₁.Isometry Q₂) (g : Q₂.Isometry Q₃) : Q₁.Isometry Q₃ :=
  { (f : M₁ ≃ₗ[R] M₂).trans (g : M₂ ≃ₗ[R] M₃) with
    map_app' := by intro m; rw [← f.map_app, ← g.map_app]; rfl }
#align quadratic_form.isometry.trans QuadraticForm.Isometry.trans
-/

end Isometry

namespace Equivalent

variable {Q₁ : QuadraticForm R M₁} {Q₂ : QuadraticForm R M₂} {Q₃ : QuadraticForm R M₃}

#print QuadraticForm.Equivalent.refl /-
@[refl]
theorem refl (Q : QuadraticForm R M) : Q.Equivalent Q :=
  ⟨Isometry.refl Q⟩
#align quadratic_form.equivalent.refl QuadraticForm.Equivalent.refl
-/

#print QuadraticForm.Equivalent.symm /-
@[symm]
theorem symm (h : Q₁.Equivalent Q₂) : Q₂.Equivalent Q₁ :=
  h.elim fun f => ⟨f.symm⟩
#align quadratic_form.equivalent.symm QuadraticForm.Equivalent.symm
-/

#print QuadraticForm.Equivalent.trans /-
@[trans]
theorem trans (h : Q₁.Equivalent Q₂) (h' : Q₂.Equivalent Q₃) : Q₁.Equivalent Q₃ :=
  h'.elim <| h.elim fun f g => ⟨f.trans g⟩
#align quadratic_form.equivalent.trans QuadraticForm.Equivalent.trans
-/

end Equivalent

variable [Fintype ι] {v : Basis ι R M}

#print QuadraticForm.isometryOfCompLinearEquiv /-
/-- A quadratic form composed with a `linear_equiv` is isometric to itself. -/
def isometryOfCompLinearEquiv (Q : QuadraticForm R M) (f : M₁ ≃ₗ[R] M) :
    Q.Isometry (Q.comp (f : M₁ →ₗ[R] M)) :=
  { f.symm with
    map_app' := by
      intro
      simp only [comp_apply, LinearEquiv.coe_coe, LinearEquiv.toFun_eq_coe,
        LinearEquiv.apply_symm_apply, f.apply_symm_apply] }
#align quadratic_form.isometry_of_comp_linear_equiv QuadraticForm.isometryOfCompLinearEquiv
-/

#print QuadraticForm.isometryBasisRepr /-
/-- A quadratic form is isometric to its bases representations. -/
noncomputable def isometryBasisRepr (Q : QuadraticForm R M) (v : Basis ι R M) :
    Isometry Q (Q.basis_repr v) :=
  isometryOfCompLinearEquiv Q v.equivFun.symm
#align quadratic_form.isometry_basis_repr QuadraticForm.isometryBasisRepr
-/

variable [Field K] [Invertible (2 : K)] [AddCommGroup V] [Module K V]

#print QuadraticForm.isometryWeightedSumSquares /-
/-- Given an orthogonal basis, a quadratic form is isometric with a weighted sum of squares. -/
noncomputable def isometryWeightedSumSquares (Q : QuadraticForm K V)
    (v : Basis (Fin (FiniteDimensional.finrank K V)) K V) (hv₁ : (associated Q).IsOrthoᵢ v) :
    Q.Isometry (weightedSumSquares K fun i => Q (v i)) :=
  by
  let iso := Q.isometry_basis_repr v
  refine' ⟨iso, fun m => _⟩
  convert iso.map_app m
  rw [basis_repr_eq_of_is_Ortho _ _ hv₁]
#align quadratic_form.isometry_weighted_sum_squares QuadraticForm.isometryWeightedSumSquares
-/

variable [FiniteDimensional K V]

open BilinForm

#print QuadraticForm.equivalent_weightedSumSquares /-
theorem equivalent_weightedSumSquares (Q : QuadraticForm K V) :
    ∃ w : Fin (FiniteDimensional.finrank K V) → K, Equivalent Q (weightedSumSquares K w) :=
  let ⟨v, hv₁⟩ := exists_orthogonal_basis (associated_isSymm _ Q)
  ⟨_, ⟨Q.isometryWeightedSumSquares v hv₁⟩⟩
#align quadratic_form.equivalent_weighted_sum_squares QuadraticForm.equivalent_weightedSumSquares
-/

#print QuadraticForm.equivalent_weightedSumSquares_units_of_nondegenerate' /-
theorem equivalent_weightedSumSquares_units_of_nondegenerate' (Q : QuadraticForm K V)
    (hQ : (associated Q).Nondegenerate) :
    ∃ w : Fin (FiniteDimensional.finrank K V) → Kˣ, Equivalent Q (weightedSumSquares K w) :=
  by
  obtain ⟨v, hv₁⟩ := exists_orthogonal_basis (associated_is_symm _ Q)
  have hv₂ := hv₁.not_is_ortho_basis_self_of_nondegenerate hQ
  simp_rw [is_ortho, associated_eq_self_apply] at hv₂ 
  exact ⟨fun i => Units.mk0 _ (hv₂ i), ⟨Q.isometry_weighted_sum_squares v hv₁⟩⟩
#align quadratic_form.equivalent_weighted_sum_squares_units_of_nondegenerate' QuadraticForm.equivalent_weightedSumSquares_units_of_nondegenerate'
-/

end QuadraticForm

