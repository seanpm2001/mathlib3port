/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Johan Commelin, Mario Carneiro

! This file was ported from Lean 3 source module data.mv_polynomial.rename
! leanprover-community/mathlib commit 2f5b500a507264de86d666a5f87ddb976e2d8de4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Basic

/-!
# Renaming variables of polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file establishes the `rename` operation on multivariate polynomials,
which modifies the set of variables.

## Main declarations

* `mv_polynomial.rename`
* `mv_polynomial.rename_equiv`

## Notation

As in other polynomial files, we typically use the notation:

+ `σ τ α : Type*` (indexing the variables)

+ `R S : Type*` `[comm_semiring R]` `[comm_semiring S]` (the coefficients)

+ `s : σ →₀ ℕ`, a function from `σ` to `ℕ` which is zero away from a finite set.
This will give rise to a monomial in `mv_polynomial σ R` which mathematicians might call `X^s`

+ `r : R` elements of the coefficient ring

+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians

+ `p : mv_polynomial σ α`

-/


noncomputable section

open scoped BigOperators

open Set Function Finsupp AddMonoidAlgebra

open scoped BigOperators

variable {σ τ α R S : Type _} [CommSemiring R] [CommSemiring S]

namespace MvPolynomial

section Rename

#print MvPolynomial.rename /-
/-- Rename all the variables in a multivariable polynomial. -/
def rename (f : σ → τ) : MvPolynomial σ R →ₐ[R] MvPolynomial τ R :=
  aeval (X ∘ f)
#align mv_polynomial.rename MvPolynomial.rename
-/

#print MvPolynomial.rename_C /-
@[simp]
theorem rename_C (f : σ → τ) (r : R) : rename f (C r) = C r :=
  eval₂_C _ _ _
#align mv_polynomial.rename_C MvPolynomial.rename_C
-/

#print MvPolynomial.rename_X /-
@[simp]
theorem rename_X (f : σ → τ) (i : σ) : rename f (X i : MvPolynomial σ R) = X (f i) :=
  eval₂_X _ _ _
#align mv_polynomial.rename_X MvPolynomial.rename_X
-/

#print MvPolynomial.map_rename /-
theorem map_rename (f : R →+* S) (g : σ → τ) (p : MvPolynomial σ R) :
    map f (rename g p) = rename g (map f p) :=
  MvPolynomial.induction_on p (fun a => by simp only [map_C, rename_C])
    (fun p q hp hq => by simp only [hp, hq, AlgHom.map_add, RingHom.map_add]) fun p n hp => by
    simp only [hp, rename_X, map_X, RingHom.map_mul, AlgHom.map_mul]
#align mv_polynomial.map_rename MvPolynomial.map_rename
-/

#print MvPolynomial.rename_rename /-
@[simp]
theorem rename_rename (f : σ → τ) (g : τ → α) (p : MvPolynomial σ R) :
    rename g (rename f p) = rename (g ∘ f) p :=
  show rename g (eval₂ C (X ∘ f) p) = _
    by
    simp only [rename, aeval_eq_eval₂_hom]
    simp [eval₂_comp_left _ C (X ∘ f) p, (· ∘ ·), eval₂_C, eval_X]
    apply eval₂_hom_congr _ rfl rfl
    ext1; simp only [comp_app, RingHom.coe_comp, eval₂_hom_C]
#align mv_polynomial.rename_rename MvPolynomial.rename_rename
-/

#print MvPolynomial.rename_id /-
@[simp]
theorem rename_id (p : MvPolynomial σ R) : rename id p = p :=
  eval₂_eta p
#align mv_polynomial.rename_id MvPolynomial.rename_id
-/

#print MvPolynomial.rename_monomial /-
theorem rename_monomial (f : σ → τ) (d : σ →₀ ℕ) (r : R) :
    rename f (monomial d r) = monomial (d.mapDomain f) r :=
  by
  rw [rename, aeval_monomial, monomial_eq, Finsupp.prod_mapDomain_index]
  · rfl
  · exact fun n => pow_zero _
  · exact fun n i₁ i₂ => pow_add _ _ _
#align mv_polynomial.rename_monomial MvPolynomial.rename_monomial
-/

#print MvPolynomial.rename_eq /-
theorem rename_eq (f : σ → τ) (p : MvPolynomial σ R) :
    rename f p = Finsupp.mapDomain (Finsupp.mapDomain f) p :=
  by
  simp only [rename, aeval_def, eval₂, Finsupp.mapDomain, algebra_map_eq, X_pow_eq_monomial, ←
    monomial_finsupp_sum_index]
  rfl
#align mv_polynomial.rename_eq MvPolynomial.rename_eq
-/

#print MvPolynomial.rename_injective /-
theorem rename_injective (f : σ → τ) (hf : Function.Injective f) :
    Function.Injective (rename f : MvPolynomial σ R → MvPolynomial τ R) :=
  by
  have :
    (rename f : MvPolynomial σ R → MvPolynomial τ R) = Finsupp.mapDomain (Finsupp.mapDomain f) :=
    funext (rename_eq f)
  rw [this]
  exact Finsupp.mapDomain_injective (Finsupp.mapDomain_injective hf)
#align mv_polynomial.rename_injective MvPolynomial.rename_injective
-/

section

variable {f : σ → τ} (hf : Function.Injective f)

open scoped Classical

#print MvPolynomial.killCompl /-
/-- Given a function between sets of variables `f : σ → τ` that is injective with proof `hf`,
  `kill_compl hf` is the `alg_hom` from `R[τ]` to `R[σ]` that is left inverse to
  `rename f : R[σ] → R[τ]` and sends the variables in the complement of the range of `f` to `0`. -/
def killCompl : MvPolynomial τ R →ₐ[R] MvPolynomial σ R :=
  aeval fun i => if h : i ∈ Set.range f then X <| (Equiv.ofInjective f hf).symm ⟨i, h⟩ else 0
#align mv_polynomial.kill_compl MvPolynomial.killCompl
-/

#print MvPolynomial.killCompl_comp_rename /-
theorem killCompl_comp_rename : (killCompl hf).comp (rename f) = AlgHom.id R _ :=
  algHom_ext fun i => by dsimp;
    rw [rename, kill_compl, aeval_X, aeval_X, dif_pos, Equiv.ofInjective_symm_apply]
#align mv_polynomial.kill_compl_comp_rename MvPolynomial.killCompl_comp_rename
-/

#print MvPolynomial.killCompl_rename_app /-
@[simp]
theorem killCompl_rename_app (p : MvPolynomial σ R) : killCompl hf (rename f p) = p :=
  AlgHom.congr_fun (killCompl_comp_rename hf) p
#align mv_polynomial.kill_compl_rename_app MvPolynomial.killCompl_rename_app
-/

end

section

variable (R)

#print MvPolynomial.renameEquiv /-
/-- `mv_polynomial.rename e` is an equivalence when `e` is. -/
@[simps apply]
def renameEquiv (f : σ ≃ τ) : MvPolynomial σ R ≃ₐ[R] MvPolynomial τ R :=
  { rename f with
    toFun := rename f
    invFun := rename f.symm
    left_inv := fun p => by rw [rename_rename, f.symm_comp_self, rename_id]
    right_inv := fun p => by rw [rename_rename, f.self_comp_symm, rename_id] }
#align mv_polynomial.rename_equiv MvPolynomial.renameEquiv
-/

#print MvPolynomial.renameEquiv_refl /-
@[simp]
theorem renameEquiv_refl : renameEquiv R (Equiv.refl σ) = AlgEquiv.refl :=
  AlgEquiv.ext rename_id
#align mv_polynomial.rename_equiv_refl MvPolynomial.renameEquiv_refl
-/

#print MvPolynomial.renameEquiv_symm /-
@[simp]
theorem renameEquiv_symm (f : σ ≃ τ) : (renameEquiv R f).symm = renameEquiv R f.symm :=
  rfl
#align mv_polynomial.rename_equiv_symm MvPolynomial.renameEquiv_symm
-/

#print MvPolynomial.renameEquiv_trans /-
@[simp]
theorem renameEquiv_trans (e : σ ≃ τ) (f : τ ≃ α) :
    (renameEquiv R e).trans (renameEquiv R f) = renameEquiv R (e.trans f) :=
  AlgEquiv.ext (rename_rename e f)
#align mv_polynomial.rename_equiv_trans MvPolynomial.renameEquiv_trans
-/

end

section

variable (f : R →+* S) (k : σ → τ) (g : τ → S) (p : MvPolynomial σ R)

#print MvPolynomial.eval₂_rename /-
theorem eval₂_rename : (rename k p).eval₂ f g = p.eval₂ f (g ∘ k) := by
  apply MvPolynomial.induction_on p <;> · intros; simp [*]
#align mv_polynomial.eval₂_rename MvPolynomial.eval₂_rename
-/

#print MvPolynomial.eval₂Hom_rename /-
theorem eval₂Hom_rename : eval₂Hom f g (rename k p) = eval₂Hom f (g ∘ k) p :=
  eval₂_rename _ _ _ _
#align mv_polynomial.eval₂_hom_rename MvPolynomial.eval₂Hom_rename
-/

#print MvPolynomial.aeval_rename /-
theorem aeval_rename [Algebra R S] : aeval g (rename k p) = aeval (g ∘ k) p :=
  eval₂Hom_rename _ _ _ _
#align mv_polynomial.aeval_rename MvPolynomial.aeval_rename
-/

#print MvPolynomial.rename_eval₂ /-
theorem rename_eval₂ (g : τ → MvPolynomial σ R) :
    rename k (p.eval₂ C (g ∘ k)) = (rename k p).eval₂ C (rename k ∘ g) := by
  apply MvPolynomial.induction_on p <;> · intros; simp [*]
#align mv_polynomial.rename_eval₂ MvPolynomial.rename_eval₂
-/

#print MvPolynomial.rename_prod_mk_eval₂ /-
theorem rename_prod_mk_eval₂ (j : τ) (g : σ → MvPolynomial σ R) :
    rename (Prod.mk j) (p.eval₂ C g) = p.eval₂ C fun x => rename (Prod.mk j) (g x) := by
  apply MvPolynomial.induction_on p <;> · intros; simp [*]
#align mv_polynomial.rename_prodmk_eval₂ MvPolynomial.rename_prod_mk_eval₂
-/

#print MvPolynomial.eval₂_rename_prod_mk /-
theorem eval₂_rename_prod_mk (g : σ × τ → S) (i : σ) (p : MvPolynomial τ R) :
    (rename (Prod.mk i) p).eval₂ f g = eval₂ f (fun j => g (i, j)) p := by
  apply MvPolynomial.induction_on p <;> · intros; simp [*]
#align mv_polynomial.eval₂_rename_prodmk MvPolynomial.eval₂_rename_prod_mk
-/

#print MvPolynomial.eval_rename_prod_mk /-
theorem eval_rename_prod_mk (g : σ × τ → R) (i : σ) (p : MvPolynomial τ R) :
    eval g (rename (Prod.mk i) p) = eval (fun j => g (i, j)) p :=
  eval₂_rename_prod_mk (RingHom.id _) _ _ _
#align mv_polynomial.eval_rename_prodmk MvPolynomial.eval_rename_prod_mk
-/

end

#print MvPolynomial.exists_finset_rename /-
/-- Every polynomial is a polynomial in finitely many variables. -/
theorem exists_finset_rename (p : MvPolynomial σ R) :
    ∃ (s : Finset σ) (q : MvPolynomial { x // x ∈ s } R), p = rename coe q := by
  classical
  apply induction_on p
  · intro r; exact ⟨∅, C r, by rw [rename_C]⟩
  · rintro p q ⟨s, p, rfl⟩ ⟨t, q, rfl⟩
    refine' ⟨s ∪ t, ⟨_, _⟩⟩
    ·
      refine' rename (Subtype.map id _) p + rename (Subtype.map id _) q <;>
        simp (config := { contextual := true }) only [id.def, true_or_iff, or_true_iff,
          Finset.mem_union, forall_true_iff]
    · simp only [rename_rename, AlgHom.map_add]; rfl
  · rintro p n ⟨s, p, rfl⟩
    refine' ⟨insert n s, ⟨_, _⟩⟩
    · refine' rename (Subtype.map id _) p * X ⟨n, s.mem_insert_self n⟩
      simp (config := { contextual := true }) only [id.def, or_true_iff, Finset.mem_insert,
        forall_true_iff]
    · simp only [rename_rename, rename_X, Subtype.coe_mk, AlgHom.map_mul]; rfl
#align mv_polynomial.exists_finset_rename MvPolynomial.exists_finset_rename
-/

#print MvPolynomial.exists_finset_rename₂ /-
/-- `exists_finset_rename` for two polyonomials at once: for any two polynomials `p₁`, `p₂` in a
  polynomial semiring `R[σ]` of possibly infinitely many variables, `exists_finset_rename₂` yields
  a finite subset `s` of `σ` such that both `p₁` and `p₂` are contained in the polynomial semiring
  `R[s]` of finitely many variables. -/
theorem exists_finset_rename₂ (p₁ p₂ : MvPolynomial σ R) :
    ∃ (s : Finset σ) (q₁ q₂ : MvPolynomial s R), p₁ = rename coe q₁ ∧ p₂ = rename coe q₂ :=
  by
  obtain ⟨s₁, q₁, rfl⟩ := exists_finset_rename p₁
  obtain ⟨s₂, q₂, rfl⟩ := exists_finset_rename p₂
  classical
  use s₁ ∪ s₂
  use rename (Set.inclusion <| s₁.subset_union_left s₂) q₁
  use rename (Set.inclusion <| s₁.subset_union_right s₂) q₂
  constructor <;> simpa
#align mv_polynomial.exists_finset_rename₂ MvPolynomial.exists_finset_rename₂
-/

#print MvPolynomial.exists_fin_rename /-
/-- Every polynomial is a polynomial in finitely many variables. -/
theorem exists_fin_rename (p : MvPolynomial σ R) :
    ∃ (n : ℕ) (f : Fin n → σ) (hf : Injective f) (q : MvPolynomial (Fin n) R), p = rename f q :=
  by
  obtain ⟨s, q, rfl⟩ := exists_finset_rename p
  let n := Fintype.card { x // x ∈ s }
  let e := Fintype.equivFin { x // x ∈ s }
  refine' ⟨n, coe ∘ e.symm, subtype.val_injective.comp e.symm.injective, rename e q, _⟩
  rw [← rename_rename, rename_rename e]
  simp only [Function.comp, Equiv.symm_apply_apply, rename_rename]
#align mv_polynomial.exists_fin_rename MvPolynomial.exists_fin_rename
-/

end Rename

#print MvPolynomial.eval₂_cast_comp /-
theorem eval₂_cast_comp (f : σ → τ) (c : ℤ →+* R) (g : τ → R) (p : MvPolynomial σ ℤ) :
    eval₂ c (g ∘ f) p = eval₂ c g (rename f p) :=
  MvPolynomial.induction_on p (fun n => by simp only [eval₂_C, rename_C])
    (fun p q hp hq => by simp only [hp, hq, rename, eval₂_add, AlgHom.map_add]) fun p n hp => by
    simp only [hp, rename, aeval_def, eval₂_X, eval₂_mul]
#align mv_polynomial.eval₂_cast_comp MvPolynomial.eval₂_cast_comp
-/

section Coeff

#print MvPolynomial.coeff_rename_mapDomain /-
@[simp]
theorem coeff_rename_mapDomain (f : σ → τ) (hf : Injective f) (φ : MvPolynomial σ R) (d : σ →₀ ℕ) :
    (rename f φ).coeff (d.mapDomain f) = φ.coeff d := by
  classical
  apply induction_on' φ
  · intro u r
    rw [rename_monomial, coeff_monomial, coeff_monomial]
    simp only [(Finsupp.mapDomain_injective hf).eq_iff]
  · intros; simp only [*, AlgHom.map_add, coeff_add]
#align mv_polynomial.coeff_rename_map_domain MvPolynomial.coeff_rename_mapDomain
-/

#print MvPolynomial.coeff_rename_eq_zero /-
theorem coeff_rename_eq_zero (f : σ → τ) (φ : MvPolynomial σ R) (d : τ →₀ ℕ)
    (h : ∀ u : σ →₀ ℕ, u.mapDomain f = d → φ.coeff u = 0) : (rename f φ).coeff d = 0 := by
  classical
  rw [rename_eq, ← not_mem_support_iff]
  intro H
  replace H := map_domain_support H
  rw [Finset.mem_image] at H 
  obtain ⟨u, hu, rfl⟩ := H
  specialize h u rfl
  simp at h hu 
  contradiction
#align mv_polynomial.coeff_rename_eq_zero MvPolynomial.coeff_rename_eq_zero
-/

#print MvPolynomial.coeff_rename_ne_zero /-
theorem coeff_rename_ne_zero (f : σ → τ) (φ : MvPolynomial σ R) (d : τ →₀ ℕ)
    (h : (rename f φ).coeff d ≠ 0) : ∃ u : σ →₀ ℕ, u.mapDomain f = d ∧ φ.coeff u ≠ 0 := by
  contrapose! h; apply coeff_rename_eq_zero _ _ _ h
#align mv_polynomial.coeff_rename_ne_zero MvPolynomial.coeff_rename_ne_zero
-/

#print MvPolynomial.constantCoeff_rename /-
@[simp]
theorem constantCoeff_rename {τ : Type _} (f : σ → τ) (φ : MvPolynomial σ R) :
    constantCoeff (rename f φ) = constantCoeff φ :=
  by
  apply φ.induction_on
  · intro a; simp only [constant_coeff_C, rename_C]
  · intro p q hp hq; simp only [hp, hq, RingHom.map_add, AlgHom.map_add]
  · intro p n hp; simp only [hp, rename_X, constant_coeff_X, RingHom.map_mul, AlgHom.map_mul]
#align mv_polynomial.constant_coeff_rename MvPolynomial.constantCoeff_rename
-/

end Coeff

section Support

#print MvPolynomial.support_rename_of_injective /-
theorem support_rename_of_injective {p : MvPolynomial σ R} {f : σ → τ} [DecidableEq τ]
    (h : Function.Injective f) : (rename f p).support = Finset.image (mapDomain f) p.support :=
  by
  rw [rename_eq]
  exact Finsupp.mapDomain_support_of_injective (map_domain_injective h) _
#align mv_polynomial.support_rename_of_injective MvPolynomial.support_rename_of_injective
-/

end Support

end MvPolynomial

