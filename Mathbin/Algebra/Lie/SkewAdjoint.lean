/-
Copyright (c) 2020 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.skew_adjoint
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.Matrix
import Mathbin.LinearAlgebra.Matrix.BilinearForm

/-!
# Lie algebras of skew-adjoint endomorphisms of a bilinear form

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

When a module carries a bilinear form, the Lie algebra of endomorphisms of the module contains a
distinguished Lie subalgebra: the skew-adjoint endomorphisms. Such subalgebras are important
because they provide a simple, explicit construction of the so-called classical Lie algebras.

This file defines the Lie subalgebra of skew-adjoint endomorphims cut out by a bilinear form on
a module and proves some basic related results. It also provides the corresponding definitions and
results for the Lie algebra of square matrices.

## Main definitions

  * `skew_adjoint_lie_subalgebra`
  * `skew_adjoint_lie_subalgebra_equiv`
  * `skew_adjoint_matrices_lie_subalgebra`
  * `skew_adjoint_matrices_lie_subalgebra_equiv`

## Tags

lie algebra, skew-adjoint, bilinear form
-/


universe u v w w₁

section SkewAdjointEndomorphisms

open BilinForm

variable {R : Type u} {M : Type v} [CommRing R] [AddCommGroup M] [Module R M]

variable (B : BilinForm R M)

#print BilinForm.isSkewAdjoint_bracket /-
theorem BilinForm.isSkewAdjoint_bracket (f g : Module.End R M) (hf : f ∈ B.skewAdjointSubmodule)
    (hg : g ∈ B.skewAdjointSubmodule) : ⁅f, g⁆ ∈ B.skewAdjointSubmodule :=
  by
  rw [mem_skew_adjoint_submodule] at *
  have hfg : is_adjoint_pair B B (f * g) (g * f) := by rw [← neg_mul_neg g f]; exact hf.mul hg
  have hgf : is_adjoint_pair B B (g * f) (f * g) := by rw [← neg_mul_neg f g]; exact hg.mul hf
  change BilinForm.IsAdjointPair B B (f * g - g * f) (-(f * g - g * f)); rw [neg_sub]
  exact hfg.sub hgf
#align bilin_form.is_skew_adjoint_bracket BilinForm.isSkewAdjoint_bracket
-/

#print skewAdjointLieSubalgebra /-
/-- Given an `R`-module `M`, equipped with a bilinear form, the skew-adjoint endomorphisms form a
Lie subalgebra of the Lie algebra of endomorphisms. -/
def skewAdjointLieSubalgebra : LieSubalgebra R (Module.End R M) :=
  { B.skewAdjointSubmodule with lie_mem' := B.isSkewAdjoint_bracket }
#align skew_adjoint_lie_subalgebra skewAdjointLieSubalgebra
-/

variable {N : Type w} [AddCommGroup N] [Module R N] (e : N ≃ₗ[R] M)

#print skewAdjointLieSubalgebraEquiv /-
/-- An equivalence of modules with bilinear forms gives equivalence of Lie algebras of skew-adjoint
endomorphisms. -/
def skewAdjointLieSubalgebraEquiv :
    skewAdjointLieSubalgebra (B.comp (↑e : N →ₗ[R] M) ↑e) ≃ₗ⁅R⁆ skewAdjointLieSubalgebra B :=
  by
  apply LieEquiv.ofSubalgebras _ _ e.lie_conj
  ext f
  simp only [LieSubalgebra.mem_coe, Submodule.mem_map_equiv, LieSubalgebra.mem_map_submodule,
    coe_coe]
  exact (BilinForm.isPairSelfAdjoint_equiv (-B) B e f).symm
#align skew_adjoint_lie_subalgebra_equiv skewAdjointLieSubalgebraEquiv
-/

#print skewAdjointLieSubalgebraEquiv_apply /-
@[simp]
theorem skewAdjointLieSubalgebraEquiv_apply (f : skewAdjointLieSubalgebra (B.comp ↑e ↑e)) :
    ↑(skewAdjointLieSubalgebraEquiv B e f) = e.lieConj f := by simp [skewAdjointLieSubalgebraEquiv]
#align skew_adjoint_lie_subalgebra_equiv_apply skewAdjointLieSubalgebraEquiv_apply
-/

#print skewAdjointLieSubalgebraEquiv_symm_apply /-
@[simp]
theorem skewAdjointLieSubalgebraEquiv_symm_apply (f : skewAdjointLieSubalgebra B) :
    ↑((skewAdjointLieSubalgebraEquiv B e).symm f) = e.symm.lieConj f := by
  simp [skewAdjointLieSubalgebraEquiv]
#align skew_adjoint_lie_subalgebra_equiv_symm_apply skewAdjointLieSubalgebraEquiv_symm_apply
-/

end SkewAdjointEndomorphisms

section SkewAdjointMatrices

open scoped Matrix

variable {R : Type u} {n : Type w} [CommRing R] [DecidableEq n] [Fintype n]

variable (J : Matrix n n R)

#print Matrix.lie_transpose /-
theorem Matrix.lie_transpose (A B : Matrix n n R) : ⁅A, B⁆ᵀ = ⁅Bᵀ, Aᵀ⁆ :=
  show (A * B - B * A)ᵀ = Bᵀ * Aᵀ - Aᵀ * Bᵀ by simp
#align matrix.lie_transpose Matrix.lie_transpose
-/

#print Matrix.isSkewAdjoint_bracket /-
theorem Matrix.isSkewAdjoint_bracket (A B : Matrix n n R) (hA : A ∈ skewAdjointMatricesSubmodule J)
    (hB : B ∈ skewAdjointMatricesSubmodule J) : ⁅A, B⁆ ∈ skewAdjointMatricesSubmodule J :=
  by
  simp only [mem_skewAdjointMatricesSubmodule] at *
  change ⁅A, B⁆ᵀ ⬝ J = J ⬝ (-⁅A, B⁆); change Aᵀ ⬝ J = J ⬝ (-A) at hA ;
  change Bᵀ ⬝ J = J ⬝ (-B) at hB 
  simp only [← Matrix.mul_eq_mul] at *
  rw [Matrix.lie_transpose, LieRing.of_associative_ring_bracket,
    LieRing.of_associative_ring_bracket, sub_mul, mul_assoc, mul_assoc, hA, hB, ← mul_assoc, ←
    mul_assoc, hA, hB]
  noncomm_ring
#align matrix.is_skew_adjoint_bracket Matrix.isSkewAdjoint_bracket
-/

#print skewAdjointMatricesLieSubalgebra /-
/-- The Lie subalgebra of skew-adjoint square matrices corresponding to a square matrix `J`. -/
def skewAdjointMatricesLieSubalgebra : LieSubalgebra R (Matrix n n R) :=
  { skewAdjointMatricesSubmodule J with lie_mem' := J.isSkewAdjoint_bracket }
#align skew_adjoint_matrices_lie_subalgebra skewAdjointMatricesLieSubalgebra
-/

#print mem_skewAdjointMatricesLieSubalgebra /-
@[simp]
theorem mem_skewAdjointMatricesLieSubalgebra (A : Matrix n n R) :
    A ∈ skewAdjointMatricesLieSubalgebra J ↔ A ∈ skewAdjointMatricesSubmodule J :=
  Iff.rfl
#align mem_skew_adjoint_matrices_lie_subalgebra mem_skewAdjointMatricesLieSubalgebra
-/

#print skewAdjointMatricesLieSubalgebraEquiv /-
/-- An invertible matrix `P` gives a Lie algebra equivalence between those endomorphisms that are
skew-adjoint with respect to a square matrix `J` and those with respect to `PᵀJP`. -/
def skewAdjointMatricesLieSubalgebraEquiv (P : Matrix n n R) (h : Invertible P) :
    skewAdjointMatricesLieSubalgebra J ≃ₗ⁅R⁆ skewAdjointMatricesLieSubalgebra (Pᵀ ⬝ J ⬝ P) :=
  LieEquiv.ofSubalgebras _ _ (P.lieConj h).symm
    (by
      ext A
      suffices
        P.lie_conj h A ∈ skewAdjointMatricesSubmodule J ↔
          A ∈ skewAdjointMatricesSubmodule (Pᵀ ⬝ J ⬝ P)
        by
        simp only [LieSubalgebra.mem_coe, Submodule.mem_map_equiv, LieSubalgebra.mem_map_submodule,
          coe_coe]
        exact this
      simp [Matrix.IsSkewAdjoint, J.is_adjoint_pair_equiv' _ _ P (isUnit_of_invertible P)])
#align skew_adjoint_matrices_lie_subalgebra_equiv skewAdjointMatricesLieSubalgebraEquiv
-/

#print skewAdjointMatricesLieSubalgebraEquiv_apply /-
theorem skewAdjointMatricesLieSubalgebraEquiv_apply (P : Matrix n n R) (h : Invertible P)
    (A : skewAdjointMatricesLieSubalgebra J) :
    ↑(skewAdjointMatricesLieSubalgebraEquiv J P h A) = P⁻¹ ⬝ ↑A ⬝ P := by
  simp [skewAdjointMatricesLieSubalgebraEquiv]
#align skew_adjoint_matrices_lie_subalgebra_equiv_apply skewAdjointMatricesLieSubalgebraEquiv_apply
-/

#print skewAdjointMatricesLieSubalgebraEquivTranspose /-
/-- An equivalence of matrix algebras commuting with the transpose endomorphisms restricts to an
equivalence of Lie algebras of skew-adjoint matrices. -/
def skewAdjointMatricesLieSubalgebraEquivTranspose {m : Type w} [DecidableEq m] [Fintype m]
    (e : Matrix n n R ≃ₐ[R] Matrix m m R) (h : ∀ A, (e A)ᵀ = e Aᵀ) :
    skewAdjointMatricesLieSubalgebra J ≃ₗ⁅R⁆ skewAdjointMatricesLieSubalgebra (e J) :=
  LieEquiv.ofSubalgebras _ _ e.toLieEquiv
    (by
      ext A
      suffices J.is_skew_adjoint (e.symm A) ↔ (e J).IsSkewAdjoint A by simpa [this]
      simp [Matrix.IsSkewAdjoint, Matrix.IsAdjointPair, ← Matrix.mul_eq_mul, ← h, ←
        Function.Injective.eq_iff e.injective])
#align skew_adjoint_matrices_lie_subalgebra_equiv_transpose skewAdjointMatricesLieSubalgebraEquivTranspose
-/

#print skewAdjointMatricesLieSubalgebraEquivTranspose_apply /-
@[simp]
theorem skewAdjointMatricesLieSubalgebraEquivTranspose_apply {m : Type w} [DecidableEq m]
    [Fintype m] (e : Matrix n n R ≃ₐ[R] Matrix m m R) (h : ∀ A, (e A)ᵀ = e Aᵀ)
    (A : skewAdjointMatricesLieSubalgebra J) :
    (skewAdjointMatricesLieSubalgebraEquivTranspose J e h A : Matrix m m R) = e A :=
  rfl
#align skew_adjoint_matrices_lie_subalgebra_equiv_transpose_apply skewAdjointMatricesLieSubalgebraEquivTranspose_apply
-/

#print mem_skewAdjointMatricesLieSubalgebra_unit_smul /-
theorem mem_skewAdjointMatricesLieSubalgebra_unit_smul (u : Rˣ) (J A : Matrix n n R) :
    A ∈ skewAdjointMatricesLieSubalgebra (u • J) ↔ A ∈ skewAdjointMatricesLieSubalgebra J :=
  by
  change A ∈ skewAdjointMatricesSubmodule (u • J) ↔ A ∈ skewAdjointMatricesSubmodule J
  simp only [mem_skewAdjointMatricesSubmodule, Matrix.IsSkewAdjoint, Matrix.IsAdjointPair]
  constructor <;> intro h
  · simpa using congr_arg (fun B => u⁻¹ • B) h
  · simp [h]
#align mem_skew_adjoint_matrices_lie_subalgebra_unit_smul mem_skewAdjointMatricesLieSubalgebra_unit_smul
-/

end SkewAdjointMatrices

