/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Johan Commelin, Mario Carneiro

! This file was ported from Lean 3 source module data.mv_polynomial.variables
! leanprover-community/mathlib commit 2f5b500a507264de86d666a5f87ddb976e2d8de4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Order
import Mathbin.Data.MvPolynomial.Rename

/-!
# Degrees and variables of polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file establishes many results about the degree and variable sets of a multivariate polynomial.

The *variable set* of a polynomial $P \in R[X]$ is a `finset` containing each $x \in X$
that appears in a monomial in $P$.

The *degree set* of a polynomial $P \in R[X]$ is a `multiset` containing, for each $x$ in the
variable set, $n$ copies of $x$, where $n$ is the maximum number of copies of $x$ appearing in a
monomial of $P$.

## Main declarations

* `mv_polynomial.degrees p` : the multiset of variables representing the union of the multisets
  corresponding to each non-zero monomial in `p`.
  For example if `7 ≠ 0` in `R` and `p = x²y+7y³` then `degrees p = {x, x, y, y, y}`

* `mv_polynomial.vars p` : the finset of variables occurring in `p`.
  For example if `p = x⁴y+yz` then `vars p = {x, y, z}`

* `mv_polynomial.degree_of n p : ℕ` : the total degree of `p` with respect to the variable `n`.
  For example if `p = x⁴y+yz` then `degree_of y p = 1`.

* `mv_polynomial.total_degree p : ℕ` :
  the max of the sizes of the multisets `s` whose monomials `X^s` occur in `p`.
  For example if `p = x⁴y+yz` then `total_degree p = 5`.

## Notation

As in other polynomial files, we typically use the notation:

+ `σ τ : Type*` (indexing the variables)

+ `R : Type*` `[comm_semiring R]` (the coefficients)

+ `s : σ →₀ ℕ`, a function from `σ` to `ℕ` which is zero away from a finite set.
This will give rise to a monomial in `mv_polynomial σ R` which mathematicians might call `X^s`

+ `r : R`

+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians

+ `p : mv_polynomial σ R`

-/


noncomputable section

open Set Function Finsupp AddMonoidAlgebra

open scoped BigOperators

universe u v w

variable {R : Type u} {S : Type v}

namespace MvPolynomial

variable {σ τ : Type _} {r : R} {e : ℕ} {n m : σ} {s : σ →₀ ℕ}

section CommSemiring

variable [CommSemiring R] {p q : MvPolynomial σ R}

section Degrees

/-! ### `degrees` -/


#print MvPolynomial.degrees /-
/-- The maximal degrees of each variable in a multi-variable polynomial, expressed as a multiset.

(For example, `degrees (x^2 * y + y^3)` would be `{x, x, y, y, y}`.)
-/
def degrees (p : MvPolynomial σ R) : Multiset σ :=
  letI := Classical.decEq σ
  p.support.sup fun s : σ →₀ ℕ => s.toMultiset
#align mv_polynomial.degrees MvPolynomial.degrees
-/

#print MvPolynomial.degrees_def /-
theorem degrees_def [DecidableEq σ] (p : MvPolynomial σ R) :
    p.degrees = p.support.sup fun s : σ →₀ ℕ => s.toMultiset := by convert rfl
#align mv_polynomial.degrees_def MvPolynomial.degrees_def
-/

#print MvPolynomial.degrees_monomial /-
theorem degrees_monomial (s : σ →₀ ℕ) (a : R) : degrees (monomial s a) ≤ s.toMultiset := by
  classical
  refine' Finset.sup_le fun t h => _
  have := Finsupp.support_single_subset h
  rw [Finset.mem_singleton] at this 
  rw [this]
#align mv_polynomial.degrees_monomial MvPolynomial.degrees_monomial
-/

#print MvPolynomial.degrees_monomial_eq /-
theorem degrees_monomial_eq (s : σ →₀ ℕ) (a : R) (ha : a ≠ 0) :
    degrees (monomial s a) = s.toMultiset := by
  classical
  refine' le_antisymm (degrees_monomial s a) <| Finset.le_sup <| _
  rw [support_monomial, if_neg ha, Finset.mem_singleton]
#align mv_polynomial.degrees_monomial_eq MvPolynomial.degrees_monomial_eq
-/

#print MvPolynomial.degrees_C /-
theorem degrees_C (a : R) : degrees (C a : MvPolynomial σ R) = 0 :=
  Multiset.le_zero.1 <| degrees_monomial _ _
#align mv_polynomial.degrees_C MvPolynomial.degrees_C
-/

#print MvPolynomial.degrees_X' /-
theorem degrees_X' (n : σ) : degrees (X n : MvPolynomial σ R) ≤ {n} :=
  le_trans (degrees_monomial _ _) <| le_of_eq <| toMultiset_single _ _
#align mv_polynomial.degrees_X' MvPolynomial.degrees_X'
-/

#print MvPolynomial.degrees_X /-
@[simp]
theorem degrees_X [Nontrivial R] (n : σ) : degrees (X n : MvPolynomial σ R) = {n} :=
  (degrees_monomial_eq _ (1 : R) one_ne_zero).trans (toMultiset_single _ _)
#align mv_polynomial.degrees_X MvPolynomial.degrees_X
-/

#print MvPolynomial.degrees_zero /-
@[simp]
theorem degrees_zero : degrees (0 : MvPolynomial σ R) = 0 := by rw [← C_0]; exact degrees_C 0
#align mv_polynomial.degrees_zero MvPolynomial.degrees_zero
-/

#print MvPolynomial.degrees_one /-
@[simp]
theorem degrees_one : degrees (1 : MvPolynomial σ R) = 0 :=
  degrees_C 1
#align mv_polynomial.degrees_one MvPolynomial.degrees_one
-/

#print MvPolynomial.degrees_add /-
theorem degrees_add [DecidableEq σ] (p q : MvPolynomial σ R) :
    (p + q).degrees ≤ p.degrees ⊔ q.degrees := by
  classical
  simp_rw [degrees_def]
  refine' Finset.sup_le fun b hb => _
  have := Finsupp.support_add hb
  rw [Finset.mem_union] at this 
  cases this
  · exact le_sup_of_le_left (Finset.le_sup this)
  · exact le_sup_of_le_right (Finset.le_sup this)
#align mv_polynomial.degrees_add MvPolynomial.degrees_add
-/

#print MvPolynomial.degrees_sum /-
theorem degrees_sum {ι : Type _} [DecidableEq σ] (s : Finset ι) (f : ι → MvPolynomial σ R) :
    (∑ i in s, f i).degrees ≤ s.sup fun i => (f i).degrees := by
  classical
  refine' s.induction _ _
  · simp only [Finset.sum_empty, Finset.sup_empty, degrees_zero]; exact le_rfl
  · intro i s his ih
    rw [Finset.sup_insert, Finset.sum_insert his]
    exact le_trans (degrees_add _ _) (sup_le_sup_left ih _)
#align mv_polynomial.degrees_sum MvPolynomial.degrees_sum
-/

#print MvPolynomial.degrees_mul /-
theorem degrees_mul (p q : MvPolynomial σ R) : (p * q).degrees ≤ p.degrees + q.degrees := by
  classical
  refine' Finset.sup_le fun b hb => _
  have := support_mul p q hb
  simp only [Finset.mem_biUnion, Finset.mem_singleton] at this 
  rcases this with ⟨a₁, h₁, a₂, h₂, rfl⟩
  rw [Finsupp.toMultiset_add]
  exact add_le_add (Finset.le_sup h₁) (Finset.le_sup h₂)
#align mv_polynomial.degrees_mul MvPolynomial.degrees_mul
-/

#print MvPolynomial.degrees_prod /-
theorem degrees_prod {ι : Type _} (s : Finset ι) (f : ι → MvPolynomial σ R) :
    (∏ i in s, f i).degrees ≤ ∑ i in s, (f i).degrees := by
  classical
  refine' s.induction _ _
  · simp only [Finset.prod_empty, Finset.sum_empty, degrees_one]
  · intro i s his ih
    rw [Finset.prod_insert his, Finset.sum_insert his]
    exact le_trans (degrees_mul _ _) (add_le_add_left ih _)
#align mv_polynomial.degrees_prod MvPolynomial.degrees_prod
-/

#print MvPolynomial.degrees_pow /-
theorem degrees_pow (p : MvPolynomial σ R) : ∀ n : ℕ, (p ^ n).degrees ≤ n • p.degrees
  | 0 => by rw [pow_zero, degrees_one]; exact Multiset.zero_le _
  | n + 1 => by
    rw [pow_succ, add_smul, add_comm, one_smul]
    exact le_trans (degrees_mul _ _) (add_le_add_left (degrees_pow n) _)
#align mv_polynomial.degrees_pow MvPolynomial.degrees_pow
-/

#print MvPolynomial.mem_degrees /-
theorem mem_degrees {p : MvPolynomial σ R} {i : σ} :
    i ∈ p.degrees ↔ ∃ d, p.coeff d ≠ 0 ∧ i ∈ d.support := by
  simp only [degrees, Multiset.mem_sup, ← mem_support_iff, Finsupp.mem_toMultiset, exists_prop]
#align mv_polynomial.mem_degrees MvPolynomial.mem_degrees
-/

#print MvPolynomial.le_degrees_add /-
theorem le_degrees_add {p q : MvPolynomial σ R} (h : p.degrees.Disjoint q.degrees) :
    p.degrees ≤ (p + q).degrees := by
  classical
  apply Finset.sup_le
  intro d hd
  rw [Multiset.disjoint_iff_ne] at h 
  rw [Multiset.le_iff_count]
  intro i
  rw [degrees, Multiset.count_finset_sup]
  simp only [Finsupp.count_toMultiset]
  by_cases h0 : d = 0
  · simp only [h0, zero_le, Finsupp.zero_apply]
  · refine' @Finset.le_sup _ _ _ _ (p + q).support _ d _
    rw [mem_support_iff, coeff_add]
    suffices q.coeff d = 0 by rwa [this, add_zero, coeff, ← Finsupp.mem_support_iff]
    rw [← Finsupp.support_eq_empty, ← Ne.def, ← Finset.nonempty_iff_ne_empty] at h0 
    obtain ⟨j, hj⟩ := h0
    contrapose! h
    rw [mem_support_iff] at hd 
    refine' ⟨j, _, j, _, rfl⟩
    all_goals rw [mem_degrees]; refine' ⟨d, _, hj⟩; assumption
#align mv_polynomial.le_degrees_add MvPolynomial.le_degrees_add
-/

#print MvPolynomial.degrees_add_of_disjoint /-
theorem degrees_add_of_disjoint [DecidableEq σ] {p q : MvPolynomial σ R}
    (h : Multiset.Disjoint p.degrees q.degrees) : (p + q).degrees = p.degrees ∪ q.degrees :=
  by
  apply le_antisymm
  · apply degrees_add
  · apply Multiset.union_le
    · apply le_degrees_add h
    · rw [add_comm]; apply le_degrees_add h.symm
#align mv_polynomial.degrees_add_of_disjoint MvPolynomial.degrees_add_of_disjoint
-/

#print MvPolynomial.degrees_map /-
theorem degrees_map [CommSemiring S] (p : MvPolynomial σ R) (f : R →+* S) :
    (map f p).degrees ⊆ p.degrees := by
  dsimp only [degrees]
  apply Multiset.subset_of_le
  apply Finset.sup_mono
  apply MvPolynomial.support_map_subset
#align mv_polynomial.degrees_map MvPolynomial.degrees_map
-/

#print MvPolynomial.degrees_rename /-
theorem degrees_rename (f : σ → τ) (φ : MvPolynomial σ R) :
    (rename f φ).degrees ⊆ φ.degrees.map f := by
  classical
  intro i
  rw [mem_degrees, Multiset.mem_map]
  rintro ⟨d, hd, hi⟩
  obtain ⟨x, rfl, hx⟩ := coeff_rename_ne_zero _ _ _ hd
  simp only [map_domain, Finsupp.mem_support_iff] at hi 
  rw [sum_apply, Finsupp.sum] at hi 
  contrapose! hi
  rw [Finset.sum_eq_zero]
  intro j hj
  simp only [exists_prop, mem_degrees] at hi 
  specialize hi j ⟨x, hx, hj⟩
  rw [single_apply, if_neg hi]
#align mv_polynomial.degrees_rename MvPolynomial.degrees_rename
-/

#print MvPolynomial.degrees_map_of_injective /-
theorem degrees_map_of_injective [CommSemiring S] (p : MvPolynomial σ R) {f : R →+* S}
    (hf : Injective f) : (map f p).degrees = p.degrees := by
  simp only [degrees, MvPolynomial.support_map_of_injective _ hf]
#align mv_polynomial.degrees_map_of_injective MvPolynomial.degrees_map_of_injective
-/

#print MvPolynomial.degrees_rename_of_injective /-
theorem degrees_rename_of_injective {p : MvPolynomial σ R} {f : σ → τ} (h : Function.Injective f) :
    degrees (rename f p) = (degrees p).map f := by
  classical
  simp only [degrees, Multiset.map_finset_sup p.support Finsupp.toMultiset f h,
    support_rename_of_injective h, Finset.sup_image]
  refine' Finset.sup_congr rfl fun x hx => _
  exact (Finsupp.toMultiset_map _ _).symm
#align mv_polynomial.degrees_rename_of_injective MvPolynomial.degrees_rename_of_injective
-/

end Degrees

section Vars

/-! ### `vars` -/


#print MvPolynomial.vars /-
/-- `vars p` is the set of variables appearing in the polynomial `p` -/
def vars (p : MvPolynomial σ R) : Finset σ :=
  letI := Classical.decEq σ
  p.degrees.to_finset
#align mv_polynomial.vars MvPolynomial.vars
-/

#print MvPolynomial.vars_def /-
theorem vars_def [DecidableEq σ] (p : MvPolynomial σ R) : p.vars = p.degrees.toFinset := by
  convert rfl
#align mv_polynomial.vars_def MvPolynomial.vars_def
-/

#print MvPolynomial.vars_0 /-
@[simp]
theorem vars_0 : (0 : MvPolynomial σ R).vars = ∅ := by
  classical rw [vars_def, degrees_zero, Multiset.toFinset_zero]
#align mv_polynomial.vars_0 MvPolynomial.vars_0
-/

#print MvPolynomial.vars_monomial /-
@[simp]
theorem vars_monomial (h : r ≠ 0) : (monomial s r).vars = s.support := by
  classical rw [vars_def, degrees_monomial_eq _ _ h, Finsupp.toFinset_toMultiset]
#align mv_polynomial.vars_monomial MvPolynomial.vars_monomial
-/

#print MvPolynomial.vars_C /-
@[simp]
theorem vars_C : (C r : MvPolynomial σ R).vars = ∅ := by
  classical rw [vars_def, degrees_C, Multiset.toFinset_zero]
#align mv_polynomial.vars_C MvPolynomial.vars_C
-/

#print MvPolynomial.vars_X /-
@[simp]
theorem vars_X [Nontrivial R] : (X n : MvPolynomial σ R).vars = {n} := by
  rw [X, vars_monomial (one_ne_zero' R), Finsupp.support_single_ne_zero _ (one_ne_zero' ℕ)]
#align mv_polynomial.vars_X MvPolynomial.vars_X
-/

#print MvPolynomial.mem_vars /-
theorem mem_vars (i : σ) : i ∈ p.vars ↔ ∃ (d : σ →₀ ℕ) (H : d ∈ p.support), i ∈ d.support := by
  simp only [vars, Multiset.mem_toFinset, mem_degrees, mem_support_iff, exists_prop]
#align mv_polynomial.mem_vars MvPolynomial.mem_vars
-/

#print MvPolynomial.mem_support_not_mem_vars_zero /-
theorem mem_support_not_mem_vars_zero {f : MvPolynomial σ R} {x : σ →₀ ℕ} (H : x ∈ f.support)
    {v : σ} (h : v ∉ vars f) : x v = 0 :=
  by
  letI := Classical.decEq σ
  rw [vars_def, Multiset.mem_toFinset] at h 
  rw [← Finsupp.not_mem_support_iff]
  contrapose! h
  rw [degrees_def]
  rw [show f.support = insert x f.support from Eq.symm <| Finset.insert_eq_of_mem H]
  rw [Finset.sup_insert]
  simp only [Multiset.mem_union, Multiset.sup_eq_union]
  left
  rwa [← to_finset_to_multiset, Multiset.mem_toFinset] at h 
#align mv_polynomial.mem_support_not_mem_vars_zero MvPolynomial.mem_support_not_mem_vars_zero
-/

#print MvPolynomial.vars_add_subset /-
theorem vars_add_subset [DecidableEq σ] (p q : MvPolynomial σ R) : (p + q).vars ⊆ p.vars ∪ q.vars :=
  by
  intro x hx
  simp only [vars, Finset.mem_union, Multiset.mem_toFinset] at hx ⊢
  simpa using Multiset.mem_of_le (degrees_add _ _) hx
#align mv_polynomial.vars_add_subset MvPolynomial.vars_add_subset
-/

#print MvPolynomial.vars_add_of_disjoint /-
theorem vars_add_of_disjoint [DecidableEq σ] (h : Disjoint p.vars q.vars) :
    (p + q).vars = p.vars ∪ q.vars :=
  by
  apply Finset.Subset.antisymm (vars_add_subset p q)
  intro x hx
  simp only [vars_def, Multiset.disjoint_toFinset] at h hx ⊢
  rw [degrees_add_of_disjoint h, Multiset.toFinset_union]
  exact hx
#align mv_polynomial.vars_add_of_disjoint MvPolynomial.vars_add_of_disjoint
-/

section Mul

#print MvPolynomial.vars_mul /-
theorem vars_mul [DecidableEq σ] (φ ψ : MvPolynomial σ R) : (φ * ψ).vars ⊆ φ.vars ∪ ψ.vars :=
  by
  intro i
  simp only [mem_vars, Finset.mem_union]
  rintro ⟨d, hd, hi⟩
  rw [mem_support_iff, coeff_mul] at hd 
  contrapose! hd; cases hd
  rw [Finset.sum_eq_zero]
  rintro ⟨d₁, d₂⟩ H
  rw [Finsupp.mem_antidiagonal] at H 
  subst H
  obtain H | H : i ∈ d₁.support ∨ i ∈ d₂.support := by
    simpa only [Finset.mem_union] using Finsupp.support_add hi
  · suffices coeff d₁ φ = 0 by simp [this]
    rw [coeff, ← Finsupp.not_mem_support_iff]; intro; solve_by_elim
  · suffices coeff d₂ ψ = 0 by simp [this]
    rw [coeff, ← Finsupp.not_mem_support_iff]; intro; solve_by_elim
#align mv_polynomial.vars_mul MvPolynomial.vars_mul
-/

#print MvPolynomial.vars_one /-
@[simp]
theorem vars_one : (1 : MvPolynomial σ R).vars = ∅ :=
  vars_C
#align mv_polynomial.vars_one MvPolynomial.vars_one
-/

#print MvPolynomial.vars_pow /-
theorem vars_pow (φ : MvPolynomial σ R) (n : ℕ) : (φ ^ n).vars ⊆ φ.vars := by
  classical
  simp_rw [vars_def]
  induction' n with n ih
  · simp
  · rw [pow_succ]
    apply Finset.Subset.trans (vars_mul _ _)
    exact Finset.union_subset (Finset.Subset.refl _) ih
#align mv_polynomial.vars_pow MvPolynomial.vars_pow
-/

#print MvPolynomial.vars_prod /-
/-- The variables of the product of a family of polynomials
are a subset of the union of the sets of variables of each polynomial.
-/
theorem vars_prod {ι : Type _} [DecidableEq σ] {s : Finset ι} (f : ι → MvPolynomial σ R) :
    (∏ i in s, f i).vars ⊆ s.biUnion fun i => (f i).vars := by
  classical
  apply s.induction_on
  · simp
  · intro a s hs hsub
    simp only [hs, Finset.biUnion_insert, Finset.prod_insert, not_false_iff]
    apply Finset.Subset.trans (vars_mul _ _)
    exact Finset.union_subset_union (Finset.Subset.refl _) hsub
#align mv_polynomial.vars_prod MvPolynomial.vars_prod
-/

section IsDomain

variable {A : Type _} [CommRing A] [IsDomain A]

#print MvPolynomial.vars_C_mul /-
theorem vars_C_mul (a : A) (ha : a ≠ 0) (φ : MvPolynomial σ A) : (C a * φ).vars = φ.vars :=
  by
  ext1 i
  simp only [mem_vars, exists_prop, mem_support_iff]
  apply exists_congr
  intro d
  apply and_congr _ Iff.rfl
  rw [coeff_C_mul, mul_ne_zero_iff, eq_true ha, true_and_iff]
#align mv_polynomial.vars_C_mul MvPolynomial.vars_C_mul
-/

end IsDomain

end Mul

section Sum

variable {ι : Type _} (t : Finset ι) (φ : ι → MvPolynomial σ R)

#print MvPolynomial.vars_sum_subset /-
theorem vars_sum_subset [DecidableEq σ] :
    (∑ i in t, φ i).vars ⊆ Finset.biUnion t fun i => (φ i).vars := by
  classical
  apply t.induction_on
  · simp
  · intro a s has hsum
    rw [Finset.biUnion_insert, Finset.sum_insert has]
    refine'
      Finset.Subset.trans (vars_add_subset _ _) (Finset.union_subset_union (Finset.Subset.refl _) _)
    assumption
#align mv_polynomial.vars_sum_subset MvPolynomial.vars_sum_subset
-/

#print MvPolynomial.vars_sum_of_disjoint /-
theorem vars_sum_of_disjoint [DecidableEq σ] (h : Pairwise <| (Disjoint on fun i => (φ i).vars)) :
    (∑ i in t, φ i).vars = Finset.biUnion t fun i => (φ i).vars := by
  classical
  apply t.induction_on
  · simp
  · intro a s has hsum
    rw [Finset.biUnion_insert, Finset.sum_insert has, vars_add_of_disjoint, hsum]
    unfold Pairwise on_fun at h 
    rw [hsum]
    simp only [Finset.disjoint_iff_ne] at h ⊢
    intro v hv v2 hv2
    rw [Finset.mem_biUnion] at hv2 
    rcases hv2 with ⟨i, his, hi⟩
    refine' h _ _ hv _ hi
    rintro rfl
    contradiction
#align mv_polynomial.vars_sum_of_disjoint MvPolynomial.vars_sum_of_disjoint
-/

end Sum

section Map

variable [CommSemiring S] (f : R →+* S)

variable (p)

#print MvPolynomial.vars_map /-
theorem vars_map : (map f p).vars ⊆ p.vars := by simp [vars, degrees_map]
#align mv_polynomial.vars_map MvPolynomial.vars_map
-/

variable {f}

#print MvPolynomial.vars_map_of_injective /-
theorem vars_map_of_injective (hf : Injective f) : (map f p).vars = p.vars := by
  simp [vars, degrees_map_of_injective _ hf]
#align mv_polynomial.vars_map_of_injective MvPolynomial.vars_map_of_injective
-/

#print MvPolynomial.vars_monomial_single /-
theorem vars_monomial_single (i : σ) {e : ℕ} {r : R} (he : e ≠ 0) (hr : r ≠ 0) :
    (monomial (Finsupp.single i e) r).vars = {i} := by
  rw [vars_monomial hr, Finsupp.support_single_ne_zero _ he]
#align mv_polynomial.vars_monomial_single MvPolynomial.vars_monomial_single
-/

#print MvPolynomial.vars_eq_support_biUnion_support /-
theorem vars_eq_support_biUnion_support [DecidableEq σ] :
    p.vars = p.support.biUnion Finsupp.support := by ext i; rw [mem_vars, Finset.mem_biUnion]
#align mv_polynomial.vars_eq_support_bUnion_support MvPolynomial.vars_eq_support_biUnion_support
-/

end Map

end Vars

section DegreeOf

/-! ### `degree_of` -/


#print MvPolynomial.degreeOf /-
/-- `degree_of n p` gives the highest power of X_n that appears in `p` -/
def degreeOf (n : σ) (p : MvPolynomial σ R) : ℕ :=
  letI := Classical.decEq σ
  p.degrees.count n
#align mv_polynomial.degree_of MvPolynomial.degreeOf
-/

#print MvPolynomial.degreeOf_def /-
theorem degreeOf_def [DecidableEq σ] (n : σ) (p : MvPolynomial σ R) :
    p.degreeOf n = p.degrees.count n := by convert rfl
#align mv_polynomial.degree_of_def MvPolynomial.degreeOf_def
-/

#print MvPolynomial.degreeOf_eq_sup /-
theorem degreeOf_eq_sup (n : σ) (f : MvPolynomial σ R) :
    degreeOf n f = f.support.sup fun m => m n := by
  classical
  rw [degree_of_def, degrees_def, Multiset.count_finset_sup]
  congr
  ext
  simp
#align mv_polynomial.degree_of_eq_sup MvPolynomial.degreeOf_eq_sup
-/

#print MvPolynomial.degreeOf_lt_iff /-
theorem degreeOf_lt_iff {n : σ} {f : MvPolynomial σ R} {d : ℕ} (h : 0 < d) :
    degreeOf n f < d ↔ ∀ m : σ →₀ ℕ, m ∈ f.support → m n < d := by
  rwa [degree_of_eq_sup n f, Finset.sup_lt_iff]
#align mv_polynomial.degree_of_lt_iff MvPolynomial.degreeOf_lt_iff
-/

#print MvPolynomial.degreeOf_zero /-
@[simp]
theorem degreeOf_zero (n : σ) : degreeOf n (0 : MvPolynomial σ R) = 0 := by
  simp only [degree_of, degrees_zero, Multiset.count_zero]
#align mv_polynomial.degree_of_zero MvPolynomial.degreeOf_zero
-/

#print MvPolynomial.degreeOf_C /-
@[simp]
theorem degreeOf_C (a : R) (x : σ) : degreeOf x (C a : MvPolynomial σ R) = 0 := by
  simp [degree_of, degrees_C]
#align mv_polynomial.degree_of_C MvPolynomial.degreeOf_C
-/

#print MvPolynomial.degreeOf_X /-
theorem degreeOf_X [DecidableEq σ] (i j : σ) [Nontrivial R] :
    degreeOf i (X j : MvPolynomial σ R) = if i = j then 1 else 0 :=
  by
  by_cases c : i = j
  · simp only [c, if_true, eq_self_iff_true, degree_of, degrees_X, Multiset.count_singleton]
  simp [c, if_false, degree_of, degrees_X]
#align mv_polynomial.degree_of_X MvPolynomial.degreeOf_X
-/

#print MvPolynomial.degreeOf_add_le /-
theorem degreeOf_add_le (n : σ) (f g : MvPolynomial σ R) :
    degreeOf n (f + g) ≤ max (degreeOf n f) (degreeOf n g) := by
  classical
  repeat' rw [degree_of_def]
  apply (Multiset.count_le_of_le n (degrees_add f g)).trans
  dsimp
  rw [Multiset.count_union]
#align mv_polynomial.degree_of_add_le MvPolynomial.degreeOf_add_le
-/

#print MvPolynomial.monomial_le_degreeOf /-
theorem monomial_le_degreeOf (i : σ) {f : MvPolynomial σ R} {m : σ →₀ ℕ} (h_m : m ∈ f.support) :
    m i ≤ degreeOf i f := by
  rw [degree_of_eq_sup i]
  apply Finset.le_sup h_m
#align mv_polynomial.monomial_le_degree_of MvPolynomial.monomial_le_degreeOf
-/

#print MvPolynomial.degreeOf_mul_le /-
-- TODO we can prove equality here if R is a domain
theorem degreeOf_mul_le (i : σ) (f g : MvPolynomial σ R) :
    degreeOf i (f * g) ≤ degreeOf i f + degreeOf i g := by
  classical
  repeat' rw [degree_of_def]
  convert Multiset.count_le_of_le i (degrees_mul f g)
  rw [Multiset.count_add]
#align mv_polynomial.degree_of_mul_le MvPolynomial.degreeOf_mul_le
-/

#print MvPolynomial.degreeOf_mul_X_ne /-
theorem degreeOf_mul_X_ne {i j : σ} (f : MvPolynomial σ R) (h : i ≠ j) :
    degreeOf i (f * X j) = degreeOf i f := by
  classical
  repeat' rw [degree_of_eq_sup i]
  rw [support_mul_X]
  simp only [Finset.sup_map]
  congr
  ext
  simp only [single, Nat.one_ne_zero, add_right_eq_self, addRightEmbedding_apply, coe_mk,
    Pi.add_apply, comp_app, ite_eq_right_iff, Finsupp.coe_add, Pi.single_eq_of_ne h]
#align mv_polynomial.degree_of_mul_X_ne MvPolynomial.degreeOf_mul_X_ne
-/

#print MvPolynomial.degreeOf_mul_X_eq /-
-- TODO in the following we have equality iff f ≠ 0
theorem degreeOf_mul_X_eq (j : σ) (f : MvPolynomial σ R) :
    degreeOf j (f * X j) ≤ degreeOf j f + 1 := by
  classical
  repeat' rw [degree_of_def]
  apply (Multiset.count_le_of_le j (degrees_mul f (X j))).trans
  simp only [Multiset.count_add, add_le_add_iff_left]
  convert Multiset.count_le_of_le j (degrees_X' j)
  rw [Multiset.count_singleton_self]
#align mv_polynomial.degree_of_mul_X_eq MvPolynomial.degreeOf_mul_X_eq
-/

#print MvPolynomial.degreeOf_rename_of_injective /-
theorem degreeOf_rename_of_injective {p : MvPolynomial σ R} {f : σ → τ} (h : Function.Injective f)
    (i : σ) : degreeOf (f i) (rename f p) = degreeOf i p := by
  classical simp only [degree_of_def, degrees_rename_of_injective h,
    Multiset.count_map_eq_count' f p.degrees h]
#align mv_polynomial.degree_of_rename_of_injective MvPolynomial.degreeOf_rename_of_injective
-/

end DegreeOf

section TotalDegree

/-! ### `total_degree` -/


#print MvPolynomial.totalDegree /-
/-- `total_degree p` gives the maximum |s| over the monomials X^s in `p` -/
def totalDegree (p : MvPolynomial σ R) : ℕ :=
  p.support.sup fun s => s.Sum fun n e => e
#align mv_polynomial.total_degree MvPolynomial.totalDegree
-/

#print MvPolynomial.totalDegree_eq /-
theorem totalDegree_eq (p : MvPolynomial σ R) :
    p.totalDegree = p.support.sup fun m => m.toMultiset.card :=
  by
  rw [total_degree]
  congr; funext m
  exact (Finsupp.card_toMultiset _).symm
#align mv_polynomial.total_degree_eq MvPolynomial.totalDegree_eq
-/

#print MvPolynomial.totalDegree_le_degrees_card /-
theorem totalDegree_le_degrees_card (p : MvPolynomial σ R) : p.totalDegree ≤ p.degrees.card := by
  classical
  rw [total_degree_eq]
  exact Finset.sup_le fun s hs => Multiset.card_le_of_le <| Finset.le_sup hs
#align mv_polynomial.total_degree_le_degrees_card MvPolynomial.totalDegree_le_degrees_card
-/

#print MvPolynomial.totalDegree_C /-
@[simp]
theorem totalDegree_C (a : R) : (C a : MvPolynomial σ R).totalDegree = 0 :=
  Nat.eq_zero_of_le_zero <|
    Finset.sup_le fun n hn => by
      have := Finsupp.support_single_subset hn
      rw [Finset.mem_singleton] at this 
      subst this
      exact le_rfl
#align mv_polynomial.total_degree_C MvPolynomial.totalDegree_C
-/

#print MvPolynomial.totalDegree_zero /-
@[simp]
theorem totalDegree_zero : (0 : MvPolynomial σ R).totalDegree = 0 := by
  rw [← C_0] <;> exact total_degree_C (0 : R)
#align mv_polynomial.total_degree_zero MvPolynomial.totalDegree_zero
-/

#print MvPolynomial.totalDegree_one /-
@[simp]
theorem totalDegree_one : (1 : MvPolynomial σ R).totalDegree = 0 :=
  totalDegree_C (1 : R)
#align mv_polynomial.total_degree_one MvPolynomial.totalDegree_one
-/

#print MvPolynomial.totalDegree_X /-
@[simp]
theorem totalDegree_X {R} [CommSemiring R] [Nontrivial R] (s : σ) :
    (X s : MvPolynomial σ R).totalDegree = 1 :=
  by
  rw [total_degree, support_X]
  simp only [Finset.sup, sum_single_index, Finset.fold_singleton, sup_bot_eq]
#align mv_polynomial.total_degree_X MvPolynomial.totalDegree_X
-/

#print MvPolynomial.totalDegree_add /-
theorem totalDegree_add (a b : MvPolynomial σ R) :
    (a + b).totalDegree ≤ max a.totalDegree b.totalDegree :=
  Finset.sup_le fun n hn => by
    classical
    have := Finsupp.support_add hn
    rw [Finset.mem_union] at this 
    cases this
    · exact le_max_of_le_left (Finset.le_sup this)
    · exact le_max_of_le_right (Finset.le_sup this)
#align mv_polynomial.total_degree_add MvPolynomial.totalDegree_add
-/

#print MvPolynomial.totalDegree_add_eq_left_of_totalDegree_lt /-
theorem totalDegree_add_eq_left_of_totalDegree_lt {p q : MvPolynomial σ R}
    (h : q.totalDegree < p.totalDegree) : (p + q).totalDegree = p.totalDegree := by
  classical
  apply le_antisymm
  · rw [← max_eq_left_of_lt h]
    exact total_degree_add p q
  by_cases hp : p = 0
  · simp [hp]
  obtain ⟨b, hb₁, hb₂⟩ :=
    p.support.exists_mem_eq_sup (finsupp.support_nonempty_iff.mpr hp) fun m : σ →₀ ℕ =>
      m.to_multiset.card
  have hb : ¬b ∈ q.support := by
    contrapose! h
    rw [total_degree_eq p, hb₂, total_degree_eq]
    apply Finset.le_sup h
  have hbb : b ∈ (p + q).support :=
    by
    apply support_sdiff_support_subset_support_add
    rw [Finset.mem_sdiff]
    exact ⟨hb₁, hb⟩
  rw [total_degree_eq, hb₂, total_degree_eq]
  exact Finset.le_sup hbb
#align mv_polynomial.total_degree_add_eq_left_of_total_degree_lt MvPolynomial.totalDegree_add_eq_left_of_totalDegree_lt
-/

#print MvPolynomial.totalDegree_add_eq_right_of_totalDegree_lt /-
theorem totalDegree_add_eq_right_of_totalDegree_lt {p q : MvPolynomial σ R}
    (h : q.totalDegree < p.totalDegree) : (q + p).totalDegree = p.totalDegree := by
  rw [add_comm, total_degree_add_eq_left_of_total_degree_lt h]
#align mv_polynomial.total_degree_add_eq_right_of_total_degree_lt MvPolynomial.totalDegree_add_eq_right_of_totalDegree_lt
-/

#print MvPolynomial.totalDegree_mul /-
theorem totalDegree_mul (a b : MvPolynomial σ R) :
    (a * b).totalDegree ≤ a.totalDegree + b.totalDegree :=
  Finset.sup_le fun n hn => by
    classical
    have := AddMonoidAlgebra.support_mul a b hn
    simp only [Finset.mem_biUnion, Finset.mem_singleton] at this 
    rcases this with ⟨a₁, h₁, a₂, h₂, rfl⟩
    rw [Finsupp.sum_add_index']
    · exact add_le_add (Finset.le_sup h₁) (Finset.le_sup h₂)
    · intro a; rfl
    · intro a b₁ b₂; rfl
#align mv_polynomial.total_degree_mul MvPolynomial.totalDegree_mul
-/

#print MvPolynomial.totalDegree_smul_le /-
theorem totalDegree_smul_le [CommSemiring S] [DistribMulAction R S] (a : R) (f : MvPolynomial σ S) :
    (a • f).totalDegree ≤ f.totalDegree :=
  Finset.sup_mono support_smul
#align mv_polynomial.total_degree_smul_le MvPolynomial.totalDegree_smul_le
-/

#print MvPolynomial.totalDegree_pow /-
theorem totalDegree_pow (a : MvPolynomial σ R) (n : ℕ) : (a ^ n).totalDegree ≤ n * a.totalDegree :=
  by
  induction' n with n ih
  · simp only [Nat.zero_eq, MulZeroClass.zero_mul, pow_zero, total_degree_one]
  rw [pow_succ]
  calc
    total_degree (a * a ^ n) ≤ a.total_degree + (a ^ n).totalDegree := total_degree_mul _ _
    _ ≤ a.total_degree + n * a.total_degree := (add_le_add_left ih _)
    _ = (n + 1) * a.total_degree := by rw [add_mul, one_mul, add_comm]
#align mv_polynomial.total_degree_pow MvPolynomial.totalDegree_pow
-/

#print MvPolynomial.totalDegree_monomial /-
@[simp]
theorem totalDegree_monomial (s : σ →₀ ℕ) {c : R} (hc : c ≠ 0) :
    (monomial s c : MvPolynomial σ R).totalDegree = s.Sum fun _ e => e := by
  classical simp [total_degree, support_monomial, if_neg hc]
#align mv_polynomial.total_degree_monomial MvPolynomial.totalDegree_monomial
-/

#print MvPolynomial.totalDegree_X_pow /-
@[simp]
theorem totalDegree_X_pow [Nontrivial R] (s : σ) (n : ℕ) :
    (X s ^ n : MvPolynomial σ R).totalDegree = n := by simp [X_pow_eq_monomial, one_ne_zero]
#align mv_polynomial.total_degree_X_pow MvPolynomial.totalDegree_X_pow
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print MvPolynomial.totalDegree_list_prod /-
theorem totalDegree_list_prod :
    ∀ s : List (MvPolynomial σ R), s.Prod.totalDegree ≤ (s.map MvPolynomial.totalDegree).Sum
  | [] => by rw [@List.prod_nil (MvPolynomial σ R) _, total_degree_one] <;> rfl
  | p::ps => by
    rw [@List.prod_cons (MvPolynomial σ R) _, List.map, List.sum_cons]
    exact le_trans (total_degree_mul _ _) (add_le_add_left (total_degree_list_prod ps) _)
#align mv_polynomial.total_degree_list_prod MvPolynomial.totalDegree_list_prod
-/

#print MvPolynomial.totalDegree_multiset_prod /-
theorem totalDegree_multiset_prod (s : Multiset (MvPolynomial σ R)) :
    s.Prod.totalDegree ≤ (s.map MvPolynomial.totalDegree).Sum :=
  by
  refine' Quotient.inductionOn s fun l => _
  rw [Multiset.quot_mk_to_coe, Multiset.coe_prod, Multiset.coe_map, Multiset.coe_sum]
  exact total_degree_list_prod l
#align mv_polynomial.total_degree_multiset_prod MvPolynomial.totalDegree_multiset_prod
-/

#print MvPolynomial.totalDegree_finset_prod /-
theorem totalDegree_finset_prod {ι : Type _} (s : Finset ι) (f : ι → MvPolynomial σ R) :
    (s.Prod f).totalDegree ≤ ∑ i in s, (f i).totalDegree :=
  by
  refine' le_trans (total_degree_multiset_prod _) _
  rw [Multiset.map_map]
  rfl
#align mv_polynomial.total_degree_finset_prod MvPolynomial.totalDegree_finset_prod
-/

#print MvPolynomial.totalDegree_finset_sum /-
theorem totalDegree_finset_sum {ι : Type _} (s : Finset ι) (f : ι → MvPolynomial σ R) :
    (s.Sum f).totalDegree ≤ Finset.sup s fun i => (f i).totalDegree :=
  by
  induction' s using Finset.cons_induction with a s has hind
  · exact zero_le _
  · rw [Finset.sum_cons, Finset.sup_cons, sup_eq_max]
    exact (MvPolynomial.totalDegree_add _ _).trans (max_le_max le_rfl hind)
#align mv_polynomial.total_degree_finset_sum MvPolynomial.totalDegree_finset_sum
-/

#print MvPolynomial.exists_degree_lt /-
theorem exists_degree_lt [Fintype σ] (f : MvPolynomial σ R) (n : ℕ)
    (h : f.totalDegree < n * Fintype.card σ) {d : σ →₀ ℕ} (hd : d ∈ f.support) : ∃ i, d i < n :=
  by
  contrapose! h
  calc
    n * Fintype.card σ = ∑ s : σ, n := by
      rw [Finset.sum_const, Nat.nsmul_eq_mul, mul_comm, Finset.card_univ]
    _ ≤ ∑ s, d s := (Finset.sum_le_sum fun s _ => h s)
    _ ≤ d.sum fun i e => e := by rw [Finsupp.sum_fintype]; intros; rfl
    _ ≤ f.total_degree := Finset.le_sup hd
#align mv_polynomial.exists_degree_lt MvPolynomial.exists_degree_lt
-/

#print MvPolynomial.coeff_eq_zero_of_totalDegree_lt /-
theorem coeff_eq_zero_of_totalDegree_lt {f : MvPolynomial σ R} {d : σ →₀ ℕ}
    (h : f.totalDegree < ∑ i in d.support, d i) : coeff d f = 0 := by
  classical
  rw [total_degree, Finset.sup_lt_iff] at h 
  · specialize h d; rw [mem_support_iff] at h 
    refine' not_not.mp (mt h _); exact lt_irrefl _
  · exact lt_of_le_of_lt (Nat.zero_le _) h
#align mv_polynomial.coeff_eq_zero_of_total_degree_lt MvPolynomial.coeff_eq_zero_of_totalDegree_lt
-/

#print MvPolynomial.totalDegree_rename_le /-
theorem totalDegree_rename_le (f : σ → τ) (p : MvPolynomial σ R) :
    (rename f p).totalDegree ≤ p.totalDegree :=
  Finset.sup_le fun b => by
    intro h
    rw [rename_eq] at h 
    classical
    have h' := Finsupp.mapDomain_support h
    rw [Finset.mem_image] at h' 
    rcases h' with ⟨s, hs, rfl⟩
    rw [Finsupp.sum_mapDomain_index]
    exact le_trans le_rfl (Finset.le_sup hs)
    exact fun _ => rfl
    exact fun _ _ _ => rfl
#align mv_polynomial.total_degree_rename_le MvPolynomial.totalDegree_rename_le
-/

end TotalDegree

section EvalVars

/-! ### `vars` and `eval` -/


variable [CommSemiring S]

#print MvPolynomial.eval₂Hom_eq_constantCoeff_of_vars /-
theorem eval₂Hom_eq_constantCoeff_of_vars (f : R →+* S) {g : σ → S} {p : MvPolynomial σ R}
    (hp : ∀ i ∈ p.vars, g i = 0) : eval₂Hom f g p = f (constantCoeff p) :=
  by
  conv_lhs => rw [p.as_sum]
  simp only [RingHom.map_sum, eval₂_hom_monomial]
  by_cases h0 : constant_coeff p = 0
  on_goal 1 =>
    rw [h0, f.map_zero, Finset.sum_eq_zero]
    intro d hd
  on_goal 2 =>
    rw [Finset.sum_eq_single (0 : σ →₀ ℕ)]
    · rw [Finsupp.prod_zero_index, mul_one]
      rfl
    intro d hd hd0
  repeat'
    obtain ⟨i, hi⟩ : d.support.nonempty :=
      by
      rw [constant_coeff_eq, coeff, ← Finsupp.not_mem_support_iff] at h0 
      rw [Finset.nonempty_iff_ne_empty, Ne.def, Finsupp.support_eq_empty]
      rintro rfl; contradiction
    rw [Finsupp.prod, Finset.prod_eq_zero hi, MulZeroClass.mul_zero]
    rw [hp, zero_pow (Nat.pos_of_ne_zero <| finsupp.mem_support_iff.mp hi)]
    rw [mem_vars]
    exact ⟨d, hd, hi⟩
  · rw [constant_coeff_eq, coeff, ← Ne.def, ← Finsupp.mem_support_iff] at h0 
    intro; contradiction
#align mv_polynomial.eval₂_hom_eq_constant_coeff_of_vars MvPolynomial.eval₂Hom_eq_constantCoeff_of_vars
-/

#print MvPolynomial.aeval_eq_constantCoeff_of_vars /-
theorem aeval_eq_constantCoeff_of_vars [Algebra R S] {g : σ → S} {p : MvPolynomial σ R}
    (hp : ∀ i ∈ p.vars, g i = 0) : aeval g p = algebraMap _ _ (constantCoeff p) :=
  eval₂Hom_eq_constantCoeff_of_vars _ hp
#align mv_polynomial.aeval_eq_constant_coeff_of_vars MvPolynomial.aeval_eq_constantCoeff_of_vars
-/

#print MvPolynomial.eval₂Hom_congr' /-
theorem eval₂Hom_congr' {f₁ f₂ : R →+* S} {g₁ g₂ : σ → S} {p₁ p₂ : MvPolynomial σ R} :
    f₁ = f₂ →
      (∀ i, i ∈ p₁.vars → i ∈ p₂.vars → g₁ i = g₂ i) →
        p₁ = p₂ → eval₂Hom f₁ g₁ p₁ = eval₂Hom f₂ g₂ p₂ :=
  by
  rintro rfl h rfl
  rename' p₁ => p, f₁ => f
  rw [p.as_sum]
  simp only [RingHom.map_sum, eval₂_hom_monomial]
  apply Finset.sum_congr rfl
  intro d hd
  congr 1
  simp only [Finsupp.prod]
  apply Finset.prod_congr rfl
  intro i hi
  have : i ∈ p.vars := by rw [mem_vars]; exact ⟨d, hd, hi⟩
  rw [h i this this]
#align mv_polynomial.eval₂_hom_congr' MvPolynomial.eval₂Hom_congr'
-/

#print MvPolynomial.hom_congr_vars /-
/-- If `f₁` and `f₂` are ring homs out of the polynomial ring and `p₁` and `p₂` are polynomials,
  then `f₁ p₁ = f₂ p₂` if `p₁ = p₂` and `f₁` and `f₂` are equal on `R` and on the variables
  of `p₁`.  -/
theorem hom_congr_vars {f₁ f₂ : MvPolynomial σ R →+* S} {p₁ p₂ : MvPolynomial σ R}
    (hC : f₁.comp C = f₂.comp C) (hv : ∀ i, i ∈ p₁.vars → i ∈ p₂.vars → f₁ (X i) = f₂ (X i))
    (hp : p₁ = p₂) : f₁ p₁ = f₂ p₂ :=
  calc
    f₁ p₁ = eval₂Hom (f₁.comp C) (f₁ ∘ X) p₁ := RingHom.congr_fun (by ext <;> simp) _
    _ = eval₂Hom (f₂.comp C) (f₂ ∘ X) p₂ := (eval₂Hom_congr' hC hv hp)
    _ = f₂ p₂ := RingHom.congr_fun (by ext <;> simp) _
#align mv_polynomial.hom_congr_vars MvPolynomial.hom_congr_vars
-/

#print MvPolynomial.exists_rename_eq_of_vars_subset_range /-
theorem exists_rename_eq_of_vars_subset_range (p : MvPolynomial σ R) (f : τ → σ) (hfi : Injective f)
    (hf : ↑p.vars ⊆ Set.range f) : ∃ q : MvPolynomial τ R, rename f q = p :=
  ⟨aeval (fun i : σ => Option.elim' 0 X <| partialInv f i) p,
    by
    show (rename f).toRingHom.comp _ p = RingHom.id _ p
    refine' hom_congr_vars _ _ _
    · ext1
      simp [algebra_map_eq]
    · intro i hip _
      rcases hf hip with ⟨i, rfl⟩
      simp [partial_inv_left hfi]
    · rfl⟩
#align mv_polynomial.exists_rename_eq_of_vars_subset_range MvPolynomial.exists_rename_eq_of_vars_subset_range
-/

#print MvPolynomial.vars_rename /-
theorem vars_rename [DecidableEq τ] (f : σ → τ) (φ : MvPolynomial σ R) :
    (rename f φ).vars ⊆ φ.vars.image f := by
  intro i hi
  simp only [vars, exists_prop, Multiset.mem_toFinset, Finset.mem_image] at hi ⊢
  simpa only [Multiset.mem_map] using degrees_rename _ _ hi
#align mv_polynomial.vars_rename MvPolynomial.vars_rename
-/

#print MvPolynomial.mem_vars_rename /-
theorem mem_vars_rename (f : σ → τ) (φ : MvPolynomial σ R) {j : τ} (h : j ∈ (rename f φ).vars) :
    ∃ i : σ, i ∈ φ.vars ∧ f i = j := by
  classical simpa only [exists_prop, Finset.mem_image] using vars_rename f φ h
#align mv_polynomial.mem_vars_rename MvPolynomial.mem_vars_rename
-/

end EvalVars

end CommSemiring

end MvPolynomial

