/-
Copyright (c) 2021 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes
-/
import Mathbin.Data.MvPolynomial.Variables

/-!
# Polynomials supported by a set of variables

This file contains the definition and lemmas about `mv_polynomial.supported`.

## Main definitions

* `mv_polynomial.supported` : Given a set `s : set σ`, `supported R s` is the subalgebra of
  `mv_polynomial σ R` consisting of polynomials whose set of variables is contained in `s`.
  This subalgebra is isomorphic to `mv_polynomial s R`

## Tags
variables, polynomial, vars
-/


universe u v w

namespace MvPolynomial

variable {σ τ : Type _} {R : Type u} {S : Type v} {r : R} {e : ℕ} {n m : σ}

section CommSemiring

variable [CommSemiring R] {p q : MvPolynomial σ R}

variable (R)

/-- The set of polynomials whose variables are contained in `s` as a `subalgebra` over `R`. -/
noncomputable def supported (s : Set σ) : Subalgebra R (MvPolynomial σ R) :=
  Algebra.adjoin R (X '' s)
#align mv_polynomial.supported MvPolynomial.supported

variable {σ R}

open Classical

open Algebra

theorem supported_eq_range_rename (s : Set σ) : supported R s = (rename (coe : s → σ)).range := by
  rw [supported, Set.image_eq_range, adjoin_range_eq_range_aeval, rename]
#align mv_polynomial.supported_eq_range_rename MvPolynomial.supported_eq_range_rename

/-- The isomorphism between the subalgebra of polynomials supported by `s` and `mv_polynomial s R`-/
noncomputable def supportedEquivMvPolynomial (s : Set σ) : supported R s ≃ₐ[R] MvPolynomial s R :=
  (Subalgebra.equivOfEq _ _ (supported_eq_range_rename s)).trans
    (AlgEquiv.ofInjective (rename (coe : s → σ)) (rename_injective _ Subtype.val_injective)).symm
#align mv_polynomial.supported_equiv_mv_polynomial MvPolynomial.supportedEquivMvPolynomial

@[simp]
theorem supported_equiv_mv_polynomial_symm_C (s : Set σ) (x : R) :
    (supportedEquivMvPolynomial s).symm (c x) = algebraMap R (supported R s) x := by
  ext1
  simp [supported_equiv_mv_polynomial, MvPolynomial.algebra_map_eq]
#align mv_polynomial.supported_equiv_mv_polynomial_symm_C MvPolynomial.supported_equiv_mv_polynomial_symm_C

@[simp]
theorem supported_equiv_mv_polynomial_symm_X (s : Set σ) (i : s) :
    (↑((supportedEquivMvPolynomial s).symm (x i : MvPolynomial s R)) : MvPolynomial σ R) = x i := by
  simp [supported_equiv_mv_polynomial]
#align mv_polynomial.supported_equiv_mv_polynomial_symm_X MvPolynomial.supported_equiv_mv_polynomial_symm_X

variable {s t : Set σ}

theorem mem_supported : p ∈ supported R s ↔ ↑p.vars ⊆ s := by
  rw [supported_eq_range_rename, AlgHom.mem_range]
  constructor
  · rintro ⟨p, rfl⟩
    refine' trans (Finset.coe_subset.2 (vars_rename _ _)) _
    simp
    
  · intro hs
    exact exists_rename_eq_of_vars_subset_range p (coe : s → σ) Subtype.val_injective (by simpa)
    
#align mv_polynomial.mem_supported MvPolynomial.mem_supported

theorem supported_eq_vars_subset : (supported R s : Set (MvPolynomial σ R)) = { p | ↑p.vars ⊆ s } :=
  Set.ext fun _ => mem_supported
#align mv_polynomial.supported_eq_vars_subset MvPolynomial.supported_eq_vars_subset

@[simp]
theorem mem_supported_vars (p : MvPolynomial σ R) : p ∈ supported R (↑p.vars : Set σ) := by rw [mem_supported]
#align mv_polynomial.mem_supported_vars MvPolynomial.mem_supported_vars

variable (s)

theorem supported_eq_adjoin_X : supported R s = Algebra.adjoin R (X '' s) :=
  rfl
#align mv_polynomial.supported_eq_adjoin_X MvPolynomial.supported_eq_adjoin_X

@[simp]
theorem supported_univ : supported R (Set.univ : Set σ) = ⊤ := by simp [Algebra.eq_top_iff, mem_supported]
#align mv_polynomial.supported_univ MvPolynomial.supported_univ

@[simp]
theorem supported_empty : supported R (∅ : Set σ) = ⊥ := by simp [supported_eq_adjoin_X]
#align mv_polynomial.supported_empty MvPolynomial.supported_empty

variable {s}

theorem supported_mono (st : s ⊆ t) : supported R s ≤ supported R t :=
  Algebra.adjoin_mono (Set.image_subset _ st)
#align mv_polynomial.supported_mono MvPolynomial.supported_mono

@[simp]
theorem X_mem_supported [Nontrivial R] {i : σ} : x i ∈ supported R s ↔ i ∈ s := by simp [mem_supported]
#align mv_polynomial.X_mem_supported MvPolynomial.X_mem_supported

@[simp]
theorem supported_le_supported_iff [Nontrivial R] : supported R s ≤ supported R t ↔ s ⊆ t := by
  constructor
  · intro h i
    simpa using @h (X i)
    
  · exact supported_mono
    
#align mv_polynomial.supported_le_supported_iff MvPolynomial.supported_le_supported_iff

theorem supported_strict_mono [Nontrivial R] : StrictMono (supported R : Set σ → Subalgebra R (MvPolynomial σ R)) :=
  strict_mono_of_le_iff_le fun _ _ => supported_le_supported_iff.symm
#align mv_polynomial.supported_strict_mono MvPolynomial.supported_strict_mono

theorem exists_restrict_to_vars (R : Type _) [CommRing R] {F : MvPolynomial σ ℤ} (hF : ↑F.vars ⊆ s) :
    ∃ f : (s → R) → R, ∀ x : σ → R, f (x ∘ coe : s → R) = aeval x F := by classical
  rw [← mem_supported, supported_eq_range_rename, AlgHom.mem_range] at hF
  cases' hF with F' hF'
  use fun z => aeval z F'
  intro x
  simp only [← hF', aeval_rename]
#align mv_polynomial.exists_restrict_to_vars MvPolynomial.exists_restrict_to_vars

end CommSemiring

end MvPolynomial

