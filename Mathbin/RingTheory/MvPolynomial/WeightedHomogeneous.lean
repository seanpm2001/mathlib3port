/-
Copyright (c) 2022 María Inés de Frutos-Fernández. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antoine Chambert-Loir, María Inés de Frutos-Fernández

! This file was ported from Lean 3 source module ring_theory.mv_polynomial.weighted_homogeneous
! leanprover-community/mathlib commit 2f5b500a507264de86d666a5f87ddb976e2d8de4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GradedMonoid
import Mathbin.Data.MvPolynomial.Variables

/-!
# Weighted homogeneous polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

It is possible to assign weights (in a commutative additive monoid `M`) to the variables of a
multivariate polynomial ring, so that monomials of the ring then have a weighted degree with
respect to the weights of the variables. The weights are represented by a function `w : σ → M`,
where `σ` are the indeterminates.

A multivariate polynomial `φ` is weighted homogeneous of weighted degree `m : M` if all monomials
occuring in `φ` have the same weighted degree `m`.

## Main definitions/lemmas

* `weighted_total_degree' w φ` : the weighted total degree of a multivariate polynomial with respect
to the weights `w`, taking values in `with_bot M`.

* `weighted_total_degree w φ` : When `M` has a `⊥` element, we can define the weighted total degree
of a multivariate polynomial as a function taking values in `M`.

* `is_weighted_homogeneous w φ m`: a predicate that asserts that `φ` is weighted homogeneous
of weighted degree `m` with respect to the weights `w`.

* `weighted_homogeneous_submodule R w m`: the submodule of homogeneous polynomials
of weighted degree `m`.

* `weighted_homogeneous_component w m`: the additive morphism that projects polynomials
onto their summand that is weighted homogeneous of degree `n` with respect to `w`.

* `sum_weighted_homogeneous_component`: every polynomial is the sum of its weighted homogeneous
components.
-/


noncomputable section

open scoped BigOperators

open Set Function Finset Finsupp AddMonoidAlgebra

variable {R M : Type _} [CommSemiring R]

namespace MvPolynomial

variable {σ : Type _}

section AddCommMonoid

variable [AddCommMonoid M]

/-! ### `weighted_degree'` -/


#print MvPolynomial.weightedDegree' /-
/-- The `weighted degree'` of the finitely supported function `s : σ →₀ ℕ` is the sum
  `∑(s i)•(w i)`. -/
def weightedDegree' (w : σ → M) : (σ →₀ ℕ) →+ M :=
  (Finsupp.total σ M ℕ w).toAddMonoidHom
#align mv_polynomial.weighted_degree' MvPolynomial.weightedDegree'
-/

section SemilatticeSup

variable [SemilatticeSup M]

#print MvPolynomial.weightedTotalDegree' /-
/-- The weighted total degree of a multivariate polynomial, taking values in `with_bot M`. -/
def weightedTotalDegree' (w : σ → M) (p : MvPolynomial σ R) : WithBot M :=
  p.support.sup fun s => weightedDegree' w s
#align mv_polynomial.weighted_total_degree' MvPolynomial.weightedTotalDegree'
-/

#print MvPolynomial.weightedTotalDegree'_eq_bot_iff /-
/-- The `weighted_total_degree'` of a polynomial `p` is `⊥` if and only if `p = 0`. -/
theorem weightedTotalDegree'_eq_bot_iff (w : σ → M) (p : MvPolynomial σ R) :
    weightedTotalDegree' w p = ⊥ ↔ p = 0 :=
  by
  simp only [weighted_total_degree', Finset.sup_eq_bot_iff, mem_support_iff, WithBot.coe_ne_bot,
    MvPolynomial.eq_zero_iff]
  exact forall_congr' fun _ => Classical.not_not
#align mv_polynomial.weighted_total_degree'_eq_bot_iff MvPolynomial.weightedTotalDegree'_eq_bot_iff
-/

#print MvPolynomial.weightedTotalDegree'_zero /-
/-- The `weighted_total_degree'` of the zero polynomial is `⊥`. -/
theorem weightedTotalDegree'_zero (w : σ → M) : weightedTotalDegree' w (0 : MvPolynomial σ R) = ⊥ :=
  by simp only [weighted_total_degree', support_zero, Finset.sup_empty]
#align mv_polynomial.weighted_total_degree'_zero MvPolynomial.weightedTotalDegree'_zero
-/

section OrderBot

variable [OrderBot M]

#print MvPolynomial.weightedTotalDegree /-
/-- When `M` has a `⊥` element, we can define the weighted total degree of a multivariate
  polynomial as a function taking values in `M`. -/
def weightedTotalDegree (w : σ → M) (p : MvPolynomial σ R) : M :=
  p.support.sup fun s => weightedDegree' w s
#align mv_polynomial.weighted_total_degree MvPolynomial.weightedTotalDegree
-/

#print MvPolynomial.weightedTotalDegree_coe /-
/-- This lemma relates `weighted_total_degree` and `weighted_total_degree'`. -/
theorem weightedTotalDegree_coe (w : σ → M) (p : MvPolynomial σ R) (hp : p ≠ 0) :
    weightedTotalDegree' w p = ↑(weightedTotalDegree w p) :=
  by
  rw [Ne.def, ← weighted_total_degree'_eq_bot_iff w p, ← Ne.def, WithBot.ne_bot_iff_exists] at hp 
  obtain ⟨m, hm⟩ := hp
  apply le_antisymm
  · simp only [weighted_total_degree, weighted_total_degree', Finset.sup_le_iff, WithBot.coe_le_coe]
    intro b
    exact Finset.le_sup
  · simp only [weighted_total_degree]
    have hm' : weighted_total_degree' w p ≤ m := le_of_eq hm.symm
    rw [← hm]
    simpa [weighted_total_degree'] using hm'
#align mv_polynomial.weighted_total_degree_coe MvPolynomial.weightedTotalDegree_coe
-/

#print MvPolynomial.weightedTotalDegree_zero /-
/-- The `weighted_total_degree` of the zero polynomial is `⊥`. -/
theorem weightedTotalDegree_zero (w : σ → M) : weightedTotalDegree w (0 : MvPolynomial σ R) = ⊥ :=
  by simp only [weighted_total_degree, support_zero, Finset.sup_empty]
#align mv_polynomial.weighted_total_degree_zero MvPolynomial.weightedTotalDegree_zero
-/

#print MvPolynomial.le_weightedTotalDegree /-
theorem le_weightedTotalDegree (w : σ → M) {φ : MvPolynomial σ R} {d : σ →₀ ℕ}
    (hd : d ∈ φ.support) : weightedDegree' w d ≤ φ.weightedTotalDegree w :=
  le_sup hd
#align mv_polynomial.le_weighted_total_degree MvPolynomial.le_weightedTotalDegree
-/

end OrderBot

end SemilatticeSup

#print MvPolynomial.IsWeightedHomogeneous /-
/-- A multivariate polynomial `φ` is weighted homogeneous of weighted degree `m` if all monomials
  occuring in `φ` have weighted degree `m`. -/
def IsWeightedHomogeneous (w : σ → M) (φ : MvPolynomial σ R) (m : M) : Prop :=
  ∀ ⦃d⦄, coeff d φ ≠ 0 → weightedDegree' w d = m
#align mv_polynomial.is_weighted_homogeneous MvPolynomial.IsWeightedHomogeneous
-/

variable (R)

#print MvPolynomial.weightedHomogeneousSubmodule /-
/-- The submodule of homogeneous `mv_polynomial`s of degree `n`. -/
def weightedHomogeneousSubmodule (w : σ → M) (m : M) : Submodule R (MvPolynomial σ R)
    where
  carrier := {x | x.IsWeightedHomogeneous w m}
  smul_mem' r a ha c hc := by
    rw [coeff_smul] at hc 
    exact ha (right_ne_zero_of_mul hc)
  zero_mem' d hd := False.elim (hd <| coeff_zero _)
  add_mem' a b ha hb c hc := by
    rw [coeff_add] at hc 
    obtain h | h : coeff c a ≠ 0 ∨ coeff c b ≠ 0 := by contrapose! hc; simp only [hc, add_zero]
    · exact ha h
    · exact hb h
#align mv_polynomial.weighted_homogeneous_submodule MvPolynomial.weightedHomogeneousSubmodule
-/

#print MvPolynomial.mem_weightedHomogeneousSubmodule /-
@[simp]
theorem mem_weightedHomogeneousSubmodule (w : σ → M) (m : M) (p : MvPolynomial σ R) :
    p ∈ weightedHomogeneousSubmodule R w m ↔ p.IsWeightedHomogeneous w m :=
  Iff.rfl
#align mv_polynomial.mem_weighted_homogeneous_submodule MvPolynomial.mem_weightedHomogeneousSubmodule
-/

variable (R)

#print MvPolynomial.weightedHomogeneousSubmodule_eq_finsupp_supported /-
/-- The submodule ` weighted_homogeneous_submodule R w m` of homogeneous `mv_polynomial`s of
  degree `n` is equal to the `R`-submodule of all `p : (σ →₀ ℕ) →₀ R` such that
  `p.support ⊆ {d | weighted_degree' w d = m}`. While equal, the former has a
  convenient definitional reduction. -/
theorem weightedHomogeneousSubmodule_eq_finsupp_supported (w : σ → M) (m : M) :
    weightedHomogeneousSubmodule R w m = Finsupp.supported _ R {d | weightedDegree' w d = m} :=
  by
  ext
  simp only [mem_supported, Set.subset_def, Finsupp.mem_support_iff, mem_coe]
  rfl
#align mv_polynomial.weighted_homogeneous_submodule_eq_finsupp_supported MvPolynomial.weightedHomogeneousSubmodule_eq_finsupp_supported
-/

variable {R}

#print MvPolynomial.weightedHomogeneousSubmodule_mul /-
/-- The submodule generated by products `Pm *Pn` of weighted homogeneous polynomials of degrees `m`
  and `n` is contained in the submodule of weighted homogeneous polynomials of degree `m + n`. -/
theorem weightedHomogeneousSubmodule_mul (w : σ → M) (m n : M) :
    weightedHomogeneousSubmodule R w m * weightedHomogeneousSubmodule R w n ≤
      weightedHomogeneousSubmodule R w (m + n) :=
  by
  rw [Submodule.mul_le]
  intro φ hφ ψ hψ c hc
  rw [coeff_mul] at hc 
  obtain ⟨⟨d, e⟩, hde, H⟩ := Finset.exists_ne_zero_of_sum_ne_zero hc
  have aux : coeff d φ ≠ 0 ∧ coeff e ψ ≠ 0 :=
    by
    contrapose! H
    by_cases h : coeff d φ = 0 <;>
      simp_all only [Ne.def, not_false_iff, MulZeroClass.zero_mul, MulZeroClass.mul_zero]
  rw [← finsupp.mem_antidiagonal.mp hde, ← hφ aux.1, ← hψ aux.2, map_add]
#align mv_polynomial.weighted_homogeneous_submodule_mul MvPolynomial.weightedHomogeneousSubmodule_mul
-/

#print MvPolynomial.isWeightedHomogeneous_monomial /-
/-- Monomials are weighted homogeneous. -/
theorem isWeightedHomogeneous_monomial (w : σ → M) (d : σ →₀ ℕ) (r : R) {m : M}
    (hm : weightedDegree' w d = m) : IsWeightedHomogeneous w (monomial d r) m := by
  classical
  intro c hc
  rw [coeff_monomial] at hc 
  split_ifs at hc  with h
  · subst c; exact hm
  · contradiction
#align mv_polynomial.is_weighted_homogeneous_monomial MvPolynomial.isWeightedHomogeneous_monomial
-/

#print MvPolynomial.isWeightedHomogeneous_of_total_degree_zero /-
/-- A polynomial of weighted_total_degree `⊥` is weighted_homogeneous of degree `⊥`. -/
theorem isWeightedHomogeneous_of_total_degree_zero [SemilatticeSup M] [OrderBot M] (w : σ → M)
    {p : MvPolynomial σ R} (hp : weightedTotalDegree w p = (⊥ : M)) :
    IsWeightedHomogeneous w p (⊥ : M) := by
  intro d hd
  have h := weighted_total_degree_coe w p (mv_polynomial.ne_zero_iff.mpr ⟨d, hd⟩)
  simp only [weighted_total_degree', hp] at h 
  rw [eq_bot_iff, ← WithBot.coe_le_coe, ← h]
  exact Finset.le_sup (mem_support_iff.mpr hd)
#align mv_polynomial.is_weighted_homogeneous_of_total_degree_zero MvPolynomial.isWeightedHomogeneous_of_total_degree_zero
-/

#print MvPolynomial.isWeightedHomogeneous_C /-
/-- Constant polynomials are weighted homogeneous of degree 0. -/
theorem isWeightedHomogeneous_C (w : σ → M) (r : R) :
    IsWeightedHomogeneous w (C r : MvPolynomial σ R) 0 :=
  isWeightedHomogeneous_monomial _ _ _ (map_zero _)
#align mv_polynomial.is_weighted_homogeneous_C MvPolynomial.isWeightedHomogeneous_C
-/

variable (R)

#print MvPolynomial.isWeightedHomogeneous_zero /-
/-- 0 is weighted homogeneous of any degree. -/
theorem isWeightedHomogeneous_zero (w : σ → M) (m : M) :
    IsWeightedHomogeneous w (0 : MvPolynomial σ R) m :=
  (weightedHomogeneousSubmodule R w m).zero_mem
#align mv_polynomial.is_weighted_homogeneous_zero MvPolynomial.isWeightedHomogeneous_zero
-/

#print MvPolynomial.isWeightedHomogeneous_one /-
/-- 1 is weighted homogeneous of degree 0. -/
theorem isWeightedHomogeneous_one (w : σ → M) : IsWeightedHomogeneous w (1 : MvPolynomial σ R) 0 :=
  isWeightedHomogeneous_C _ _
#align mv_polynomial.is_weighted_homogeneous_one MvPolynomial.isWeightedHomogeneous_one
-/

#print MvPolynomial.isWeightedHomogeneous_X /-
/-- An indeterminate `i : σ` is weighted homogeneous of degree `w i`. -/
theorem isWeightedHomogeneous_X (w : σ → M) (i : σ) :
    IsWeightedHomogeneous w (X i : MvPolynomial σ R) (w i) :=
  by
  apply is_weighted_homogeneous_monomial
  simp only [weighted_degree', LinearMap.toAddMonoidHom_coe, total_single, one_nsmul]
#align mv_polynomial.is_weighted_homogeneous_X MvPolynomial.isWeightedHomogeneous_X
-/

namespace IsWeightedHomogeneous

variable {R} {φ ψ : MvPolynomial σ R} {m n : M}

#print MvPolynomial.IsWeightedHomogeneous.coeff_eq_zero /-
/-- The weighted degree of a weighted homogeneous polynomial controls its support. -/
theorem coeff_eq_zero {w : σ → M} (hφ : IsWeightedHomogeneous w φ n) (d : σ →₀ ℕ)
    (hd : weightedDegree' w d ≠ n) : coeff d φ = 0 := by have aux := mt (@hφ d) hd;
  rwa [Classical.not_not] at aux 
#align mv_polynomial.is_weighted_homogeneous.coeff_eq_zero MvPolynomial.IsWeightedHomogeneous.coeff_eq_zero
-/

#print MvPolynomial.IsWeightedHomogeneous.inj_right /-
/-- The weighted degree of a nonzero weighted homogeneous polynomial is well-defined. -/
theorem inj_right {w : σ → M} (hφ : φ ≠ 0) (hm : IsWeightedHomogeneous w φ m)
    (hn : IsWeightedHomogeneous w φ n) : m = n :=
  by
  obtain ⟨d, hd⟩ : ∃ d, coeff d φ ≠ 0 := exists_coeff_ne_zero hφ
  rw [← hm hd, ← hn hd]
#align mv_polynomial.is_weighted_homogeneous.inj_right MvPolynomial.IsWeightedHomogeneous.inj_right
-/

#print MvPolynomial.IsWeightedHomogeneous.add /-
/-- The sum of two weighted homogeneous polynomials of degree `n` is weighted homogeneous of
  weighted degree `n`. -/
theorem add {w : σ → M} (hφ : IsWeightedHomogeneous w φ n) (hψ : IsWeightedHomogeneous w ψ n) :
    IsWeightedHomogeneous w (φ + ψ) n :=
  (weightedHomogeneousSubmodule R w n).add_mem hφ hψ
#align mv_polynomial.is_weighted_homogeneous.add MvPolynomial.IsWeightedHomogeneous.add
-/

#print MvPolynomial.IsWeightedHomogeneous.sum /-
/-- The sum of weighted homogeneous polynomials of degree `n` is weighted homogeneous of
  weighted degree `n`. -/
theorem sum {ι : Type _} (s : Finset ι) (φ : ι → MvPolynomial σ R) (n : M) {w : σ → M}
    (h : ∀ i ∈ s, IsWeightedHomogeneous w (φ i) n) : IsWeightedHomogeneous w (∑ i in s, φ i) n :=
  (weightedHomogeneousSubmodule R w n).sum_mem h
#align mv_polynomial.is_weighted_homogeneous.sum MvPolynomial.IsWeightedHomogeneous.sum
-/

#print MvPolynomial.IsWeightedHomogeneous.mul /-
/-- The product of weighted homogeneous polynomials of weighted degrees `m` and `n` is weighted
  homogeneous of weighted degree `m + n`. -/
theorem mul {w : σ → M} (hφ : IsWeightedHomogeneous w φ m) (hψ : IsWeightedHomogeneous w ψ n) :
    IsWeightedHomogeneous w (φ * ψ) (m + n) :=
  weightedHomogeneousSubmodule_mul w m n <| Submodule.mul_mem_mul hφ hψ
#align mv_polynomial.is_weighted_homogeneous.mul MvPolynomial.IsWeightedHomogeneous.mul
-/

#print MvPolynomial.IsWeightedHomogeneous.prod /-
/-- A product of weighted homogeneous polynomials is weighted homogeneous, with weighted degree
  equal to the sum of the weighted degrees. -/
theorem prod {ι : Type _} (s : Finset ι) (φ : ι → MvPolynomial σ R) (n : ι → M) {w : σ → M} :
    (∀ i ∈ s, IsWeightedHomogeneous w (φ i) (n i)) →
      IsWeightedHomogeneous w (∏ i in s, φ i) (∑ i in s, n i) :=
  by
  classical
  apply Finset.induction_on s
  · intro; simp only [is_weighted_homogeneous_one, Finset.sum_empty, Finset.prod_empty]
  · intro i s his IH h
    simp only [his, Finset.prod_insert, Finset.sum_insert, not_false_iff]
    apply (h i (Finset.mem_insert_self _ _)).mul (IH _)
    intro j hjs
    exact h j (Finset.mem_insert_of_mem hjs)
#align mv_polynomial.is_weighted_homogeneous.prod MvPolynomial.IsWeightedHomogeneous.prod
-/

#print MvPolynomial.IsWeightedHomogeneous.weighted_total_degree /-
/-- A non zero weighted homogeneous polynomial of weighted degree `n` has weighted total degree
  `n`. -/
theorem weighted_total_degree [SemilatticeSup M] {w : σ → M} (hφ : IsWeightedHomogeneous w φ n)
    (h : φ ≠ 0) : weightedTotalDegree' w φ = n :=
  by
  simp only [weighted_total_degree']
  apply le_antisymm
  · simp only [Finset.sup_le_iff, mem_support_iff, WithBot.coe_le_coe]
    exact fun d hd => le_of_eq (hφ hd)
  · obtain ⟨d, hd⟩ : ∃ d, coeff d φ ≠ 0 := exists_coeff_ne_zero h
    simp only [← hφ hd, Finsupp.sum]
    replace hd := finsupp.mem_support_iff.mpr hd
    exact Finset.le_sup hd
#align mv_polynomial.is_weighted_homogeneous.weighted_total_degree MvPolynomial.IsWeightedHomogeneous.weighted_total_degree
-/

#print MvPolynomial.IsWeightedHomogeneous.WeightedHomogeneousSubmodule.gcomm_monoid /-
/-- The weighted homogeneous submodules form a graded monoid. -/
instance WeightedHomogeneousSubmodule.gcomm_monoid {w : σ → M} :
    SetLike.GradedMonoid (weightedHomogeneousSubmodule R w)
    where
  one_mem := isWeightedHomogeneous_one R w
  mul_mem i j xi xj := IsWeightedHomogeneous.mul
#align mv_polynomial.is_weighted_homogeneous.weighted_homogeneous_submodule.gcomm_monoid MvPolynomial.IsWeightedHomogeneous.WeightedHomogeneousSubmodule.gcomm_monoid
-/

end IsWeightedHomogeneous

variable {R}

#print MvPolynomial.weightedHomogeneousComponent /-
/-- `weighted_homogeneous_component w n φ` is the part of `φ` that is weighted homogeneous of
  weighted degree `n`, with respect to the weights `w`.
  See `sum_weighted_homogeneous_component` for the statement that `φ` is equal to the sum
  of all its weighted homogeneous components. -/
def weightedHomogeneousComponent (w : σ → M) (n : M) : MvPolynomial σ R →ₗ[R] MvPolynomial σ R :=
  (Submodule.subtype _).comp <| Finsupp.restrictDom _ _ {d | weightedDegree' w d = n}
#align mv_polynomial.weighted_homogeneous_component MvPolynomial.weightedHomogeneousComponent
-/

section WeightedHomogeneousComponent

variable {w : σ → M} (n : M) (φ ψ : MvPolynomial σ R)

#print MvPolynomial.coeff_weightedHomogeneousComponent /-
theorem coeff_weightedHomogeneousComponent [DecidableEq M] (d : σ →₀ ℕ) :
    coeff d (weightedHomogeneousComponent w n φ) =
      if weightedDegree' w d = n then coeff d φ else 0 :=
  Finsupp.filter_apply (fun d : σ →₀ ℕ => weightedDegree' w d = n) φ d
#align mv_polynomial.coeff_weighted_homogeneous_component MvPolynomial.coeff_weightedHomogeneousComponent
-/

#print MvPolynomial.weightedHomogeneousComponent_apply /-
theorem weightedHomogeneousComponent_apply [DecidableEq M] :
    weightedHomogeneousComponent w n φ =
      ∑ d in φ.support.filterₓ fun d => weightedDegree' w d = n, monomial d (coeff d φ) :=
  Finsupp.filter_eq_sum (fun d : σ →₀ ℕ => weightedDegree' w d = n) φ
#align mv_polynomial.weighted_homogeneous_component_apply MvPolynomial.weightedHomogeneousComponent_apply
-/

#print MvPolynomial.weightedHomogeneousComponent_isWeightedHomogeneous /-
/-- The `n` weighted homogeneous component of a polynomial is weighted homogeneous of
weighted degree `n`. -/
theorem weightedHomogeneousComponent_isWeightedHomogeneous :
    (weightedHomogeneousComponent w n φ).IsWeightedHomogeneous w n := by
  classical
  intro d hd
  contrapose! hd
  rw [coeff_weighted_homogeneous_component, if_neg hd]
#align mv_polynomial.weighted_homogeneous_component_is_weighted_homogeneous MvPolynomial.weightedHomogeneousComponent_isWeightedHomogeneous
-/

#print MvPolynomial.weightedHomogeneousComponent_C_mul /-
@[simp]
theorem weightedHomogeneousComponent_C_mul (n : M) (r : R) :
    weightedHomogeneousComponent w n (C r * φ) = C r * weightedHomogeneousComponent w n φ := by
  simp only [C_mul', LinearMap.map_smul]
#align mv_polynomial.weighted_homogeneous_component_C_mul MvPolynomial.weightedHomogeneousComponent_C_mul
-/

#print MvPolynomial.weightedHomogeneousComponent_eq_zero' /-
theorem weightedHomogeneousComponent_eq_zero'
    (h : ∀ d : σ →₀ ℕ, d ∈ φ.support → weightedDegree' w d ≠ n) :
    weightedHomogeneousComponent w n φ = 0 := by
  classical
  rw [weighted_homogeneous_component_apply, sum_eq_zero]
  intro d hd
  rw [mem_filter] at hd 
  exfalso
  exact h _ hd.1 hd.2
#align mv_polynomial.weighted_homogeneous_component_eq_zero' MvPolynomial.weightedHomogeneousComponent_eq_zero'
-/

#print MvPolynomial.weightedHomogeneousComponent_eq_zero /-
theorem weightedHomogeneousComponent_eq_zero [SemilatticeSup M] [OrderBot M]
    (h : weightedTotalDegree w φ < n) : weightedHomogeneousComponent w n φ = 0 := by
  classical
  rw [weighted_homogeneous_component_apply, sum_eq_zero]
  intro d hd
  rw [mem_filter] at hd 
  exfalso
  apply lt_irrefl n
  nth_rw 1 [← hd.2]
  exact lt_of_le_of_lt (le_weighted_total_degree w hd.1) h
#align mv_polynomial.weighted_homogeneous_component_eq_zero MvPolynomial.weightedHomogeneousComponent_eq_zero
-/

#print MvPolynomial.weightedHomogeneousComponent_finsupp /-
theorem weightedHomogeneousComponent_finsupp :
    (Function.support fun m => weightedHomogeneousComponent w m φ).Finite :=
  by
  suffices
    (Function.support fun m => weighted_homogeneous_component w m φ) ⊆
      (fun d => weighted_degree' w d) '' φ.support
    by
    exact finite.subset ((fun d : σ →₀ ℕ => (weighted_degree' w) d) '' ↑(support φ)).toFinite this
  intro m hm
  by_contra hm'; apply hm
  simp only [mem_support, Ne.def] at hm 
  simp only [Set.mem_image, not_exists, not_and] at hm' 
  exact weighted_homogeneous_component_eq_zero' m φ hm'
#align mv_polynomial.weighted_homogeneous_component_finsupp MvPolynomial.weightedHomogeneousComponent_finsupp
-/

variable (w)

#print MvPolynomial.sum_weightedHomogeneousComponent /-
/-- Every polynomial is the sum of its weighted homogeneous components. -/
theorem sum_weightedHomogeneousComponent :
    (finsum fun m => weightedHomogeneousComponent w m φ) = φ := by
  classical
  rw [finsum_eq_sum _ (weighted_homogeneous_component_finsupp φ)]
  ext1 d
  simp only [coeff_sum, coeff_weighted_homogeneous_component]
  rw [Finset.sum_eq_single (weighted_degree' w d)]
  · rw [if_pos rfl]
  · intro m hm hm'; rw [if_neg hm'.symm]
  · intro hm; rw [if_pos rfl]
    simp only [finite.mem_to_finset, mem_support, Ne.def, Classical.not_not] at hm 
    have := coeff_weighted_homogeneous_component (_ : M) φ d
    rw [hm, if_pos rfl, coeff_zero] at this 
    exact this.symm
#align mv_polynomial.sum_weighted_homogeneous_component MvPolynomial.sum_weightedHomogeneousComponent
-/

variable {w}

#print MvPolynomial.weightedHomogeneousComponent_weighted_homogeneous_polynomial /-
/-- The weighted homogeneous components of a weighted homogeneous polynomial. -/
theorem weightedHomogeneousComponent_weighted_homogeneous_polynomial [DecidableEq M] (m n : M)
    (p : MvPolynomial σ R) (h : p ∈ weightedHomogeneousSubmodule R w n) :
    weightedHomogeneousComponent w m p = if m = n then p else 0 :=
  by
  simp only [mem_weighted_homogeneous_submodule] at h 
  ext x
  rw [coeff_weighted_homogeneous_component]
  by_cases zero_coeff : coeff x p = 0
  · split_ifs
    all_goals simp only [zero_coeff, coeff_zero]
  · rw [h zero_coeff]
    simp only [show n = m ↔ m = n from eq_comm]
    split_ifs with h1
    · rfl
    · simp only [coeff_zero]
#align mv_polynomial.weighted_homogeneous_component_weighted_homogeneous_polynomial MvPolynomial.weightedHomogeneousComponent_weighted_homogeneous_polynomial
-/

end WeightedHomogeneousComponent

end AddCommMonoid

section CanonicallyOrderedAddMonoid

variable [CanonicallyOrderedAddMonoid M] {w : σ → M} (φ : MvPolynomial σ R)

#print MvPolynomial.weightedHomogeneousComponent_zero /-
/-- If `M` is a `canonically_ordered_add_monoid`, then the `weighted_homogeneous_component`
  of weighted degree `0` of a polynomial is its constant coefficient. -/
@[simp]
theorem weightedHomogeneousComponent_zero [NoZeroSMulDivisors ℕ M] (hw : ∀ i : σ, w i ≠ 0) :
    weightedHomogeneousComponent w 0 φ = C (coeff 0 φ) := by
  classical
  ext1 d
  rcases em (d = 0) with (rfl | hd)
  · simp only [coeff_weighted_homogeneous_component, if_pos, map_zero, coeff_zero_C]
  · rw [coeff_weighted_homogeneous_component, if_neg, coeff_C, if_neg (Ne.symm hd)]
    simp only [weighted_degree', LinearMap.toAddMonoidHom_coe, Finsupp.total_apply, Finsupp.sum,
      sum_eq_zero_iff, Finsupp.mem_support_iff, Ne.def, smul_eq_zero, not_forall, not_or,
      and_self_left, exists_prop]
    simp only [Finsupp.ext_iff, Finsupp.coe_zero, Pi.zero_apply, not_forall] at hd 
    obtain ⟨i, hi⟩ := hd
    exact ⟨i, hi, hw i⟩
#align mv_polynomial.weighted_homogeneous_component_zero MvPolynomial.weightedHomogeneousComponent_zero
-/

end CanonicallyOrderedAddMonoid

end MvPolynomial

