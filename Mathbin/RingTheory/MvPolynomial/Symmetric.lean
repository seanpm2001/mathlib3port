/-
Copyright (c) 2020 Hanting Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Hanting Zhang, Johan Commelin

! This file was ported from Lean 3 source module ring_theory.mv_polynomial.symmetric
! leanprover-community/mathlib commit 2f5b500a507264de86d666a5f87ddb976e2d8de4
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.MvPolynomial.Rename
import Mathbin.Data.MvPolynomial.CommRing
import Mathbin.Algebra.Algebra.Subalgebra.Basic

/-!
# Symmetric Polynomials and Elementary Symmetric Polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines symmetric `mv_polynomial`s and elementary symmetric `mv_polynomial`s.
We also prove some basic facts about them.

## Main declarations

* `mv_polynomial.is_symmetric`

* `mv_polynomial.symmetric_subalgebra`

* `mv_polynomial.esymm`

## Notation

+ `esymm σ R n`, is the `n`th elementary symmetric polynomial in `mv_polynomial σ R`.

As in other polynomial files, we typically use the notation:

+ `σ τ : Type*` (indexing the variables)

+ `R S : Type*` `[comm_semiring R]` `[comm_semiring S]` (the coefficients)

+ `r : R` elements of the coefficient ring

+ `i : σ`, with corresponding monomial `X i`, often denoted `X_i` by mathematicians

+ `φ ψ : mv_polynomial σ R`

-/


open Equiv (Perm)

open scoped BigOperators

noncomputable section

namespace Multiset

variable {R : Type _} [CommSemiring R]

#print Multiset.esymm /-
/-- The `n`th elementary symmetric function evaluated at the elements of `s` -/
def esymm (s : Multiset R) (n : ℕ) : R :=
  ((s.powersetLen n).map Multiset.prod).Sum
#align multiset.esymm Multiset.esymm
-/

#print Finset.esymm_map_val /-
theorem Finset.esymm_map_val {σ} (f : σ → R) (s : Finset σ) (n : ℕ) :
    (s.val.map f).esymm n = (s.powersetLen n).Sum fun t => t.Prod f := by
  simpa only [esymm, powerset_len_map, ← Finset.map_val_val_powersetLen, map_map]
#align finset.esymm_map_val Finset.esymm_map_val
-/

end Multiset

namespace MvPolynomial

variable {σ : Type _} {R : Type _}

variable {τ : Type _} {S : Type _}

#print MvPolynomial.IsSymmetric /-
/-- A `mv_polynomial φ` is symmetric if it is invariant under
permutations of its variables by the  `rename` operation -/
def IsSymmetric [CommSemiring R] (φ : MvPolynomial σ R) : Prop :=
  ∀ e : Perm σ, rename e φ = φ
#align mv_polynomial.is_symmetric MvPolynomial.IsSymmetric
-/

variable (σ R)

#print MvPolynomial.symmetricSubalgebra /-
/-- The subalgebra of symmetric `mv_polynomial`s. -/
def symmetricSubalgebra [CommSemiring R] : Subalgebra R (MvPolynomial σ R)
    where
  carrier := setOf IsSymmetric
  algebraMap_mem' r e := rename_C e r
  mul_mem' a b ha hb e := by rw [AlgHom.map_mul, ha, hb]
  add_mem' a b ha hb e := by rw [AlgHom.map_add, ha, hb]
#align mv_polynomial.symmetric_subalgebra MvPolynomial.symmetricSubalgebra
-/

variable {σ R}

#print MvPolynomial.mem_symmetricSubalgebra /-
@[simp]
theorem mem_symmetricSubalgebra [CommSemiring R] (p : MvPolynomial σ R) :
    p ∈ symmetricSubalgebra σ R ↔ p.IsSymmetric :=
  Iff.rfl
#align mv_polynomial.mem_symmetric_subalgebra MvPolynomial.mem_symmetricSubalgebra
-/

namespace IsSymmetric

section CommSemiring

variable [CommSemiring R] [CommSemiring S] {φ ψ : MvPolynomial σ R}

#print MvPolynomial.IsSymmetric.C /-
@[simp]
theorem C (r : R) : IsSymmetric (C r : MvPolynomial σ R) :=
  (symmetricSubalgebra σ R).algebraMap_mem r
#align mv_polynomial.is_symmetric.C MvPolynomial.IsSymmetric.C
-/

#print MvPolynomial.IsSymmetric.zero /-
@[simp]
theorem zero : IsSymmetric (0 : MvPolynomial σ R) :=
  (symmetricSubalgebra σ R).zero_mem
#align mv_polynomial.is_symmetric.zero MvPolynomial.IsSymmetric.zero
-/

#print MvPolynomial.IsSymmetric.one /-
@[simp]
theorem one : IsSymmetric (1 : MvPolynomial σ R) :=
  (symmetricSubalgebra σ R).one_mem
#align mv_polynomial.is_symmetric.one MvPolynomial.IsSymmetric.one
-/

#print MvPolynomial.IsSymmetric.add /-
theorem add (hφ : IsSymmetric φ) (hψ : IsSymmetric ψ) : IsSymmetric (φ + ψ) :=
  (symmetricSubalgebra σ R).add_mem hφ hψ
#align mv_polynomial.is_symmetric.add MvPolynomial.IsSymmetric.add
-/

#print MvPolynomial.IsSymmetric.mul /-
theorem mul (hφ : IsSymmetric φ) (hψ : IsSymmetric ψ) : IsSymmetric (φ * ψ) :=
  (symmetricSubalgebra σ R).mul_mem hφ hψ
#align mv_polynomial.is_symmetric.mul MvPolynomial.IsSymmetric.mul
-/

#print MvPolynomial.IsSymmetric.smul /-
theorem smul (r : R) (hφ : IsSymmetric φ) : IsSymmetric (r • φ) :=
  (symmetricSubalgebra σ R).smul_mem hφ r
#align mv_polynomial.is_symmetric.smul MvPolynomial.IsSymmetric.smul
-/

#print MvPolynomial.IsSymmetric.map /-
@[simp]
theorem map (hφ : IsSymmetric φ) (f : R →+* S) : IsSymmetric (map f φ) := fun e => by
  rw [← map_rename, hφ]
#align mv_polynomial.is_symmetric.map MvPolynomial.IsSymmetric.map
-/

end CommSemiring

section CommRing

variable [CommRing R] {φ ψ : MvPolynomial σ R}

#print MvPolynomial.IsSymmetric.neg /-
theorem neg (hφ : IsSymmetric φ) : IsSymmetric (-φ) :=
  (symmetricSubalgebra σ R).neg_mem hφ
#align mv_polynomial.is_symmetric.neg MvPolynomial.IsSymmetric.neg
-/

#print MvPolynomial.IsSymmetric.sub /-
theorem sub (hφ : IsSymmetric φ) (hψ : IsSymmetric ψ) : IsSymmetric (φ - ψ) :=
  (symmetricSubalgebra σ R).sub_mem hφ hψ
#align mv_polynomial.is_symmetric.sub MvPolynomial.IsSymmetric.sub
-/

end CommRing

end IsSymmetric

section ElementarySymmetric

open Finset

variable (σ R) [CommSemiring R] [CommSemiring S] [Fintype σ] [Fintype τ]

#print MvPolynomial.esymm /-
/-- The `n`th elementary symmetric `mv_polynomial σ R`. -/
def esymm (n : ℕ) : MvPolynomial σ R :=
  ∑ t in powersetLen n univ, ∏ i in t, X i
#align mv_polynomial.esymm MvPolynomial.esymm
-/

#print MvPolynomial.esymm_eq_multiset_esymm /-
/-- The `n`th elementary symmetric `mv_polynomial σ R` is obtained by evaluating the
`n`th elementary symmetric at the `multiset` of the monomials -/
theorem esymm_eq_multiset_esymm : esymm σ R = (Finset.univ.val.map X).esymm :=
  funext fun n => (Finset.univ.esymm_map_val X n).symm
#align mv_polynomial.esymm_eq_multiset_esymm MvPolynomial.esymm_eq_multiset_esymm
-/

#print MvPolynomial.aeval_esymm_eq_multiset_esymm /-
theorem aeval_esymm_eq_multiset_esymm [Algebra R S] (f : σ → S) (n : ℕ) :
    aeval f (esymm σ R n) = (Finset.univ.val.map f).esymm n := by
  simp_rw [esymm, aeval_sum, aeval_prod, aeval_X, esymm_map_val]
#align mv_polynomial.aeval_esymm_eq_multiset_esymm MvPolynomial.aeval_esymm_eq_multiset_esymm
-/

#print MvPolynomial.esymm_eq_sum_subtype /-
/-- We can define `esymm σ R n` by summing over a subtype instead of over `powerset_len`. -/
theorem esymm_eq_sum_subtype (n : ℕ) :
    esymm σ R n = ∑ t : { s : Finset σ // s.card = n }, ∏ i in (t : Finset σ), X i :=
  sum_subtype _ (fun _ => mem_powerset_len_univ_iff) _
#align mv_polynomial.esymm_eq_sum_subtype MvPolynomial.esymm_eq_sum_subtype
-/

#print MvPolynomial.esymm_eq_sum_monomial /-
/-- We can define `esymm σ R n` as a sum over explicit monomials -/
theorem esymm_eq_sum_monomial (n : ℕ) :
    esymm σ R n = ∑ t in powersetLen n univ, monomial (∑ i in t, Finsupp.single i 1) 1 :=
  by
  simp_rw [monomial_sum_one]
  rfl
#align mv_polynomial.esymm_eq_sum_monomial MvPolynomial.esymm_eq_sum_monomial
-/

#print MvPolynomial.esymm_zero /-
@[simp]
theorem esymm_zero : esymm σ R 0 = 1 := by
  simp only [esymm, powerset_len_zero, sum_singleton, prod_empty]
#align mv_polynomial.esymm_zero MvPolynomial.esymm_zero
-/

#print MvPolynomial.map_esymm /-
theorem map_esymm (n : ℕ) (f : R →+* S) : map f (esymm σ R n) = esymm σ S n := by
  simp_rw [esymm, map_sum, map_prod, map_X]
#align mv_polynomial.map_esymm MvPolynomial.map_esymm
-/

#print MvPolynomial.rename_esymm /-
theorem rename_esymm (n : ℕ) (e : σ ≃ τ) : rename e (esymm σ R n) = esymm τ R n :=
  calc
    rename e (esymm σ R n) = ∑ x in powersetLen n univ, ∏ i in x, X (e i) := by
      simp_rw [esymm, map_sum, map_prod, rename_X]
    _ = ∑ t in powersetLen n (univ.map e.toEmbedding), ∏ i in t, X i := by
      simp [Finset.powersetLen_map, -Finset.map_univ_equiv]
    _ = ∑ t in powersetLen n univ, ∏ i in t, X i := by rw [Finset.map_univ_equiv]
#align mv_polynomial.rename_esymm MvPolynomial.rename_esymm
-/

#print MvPolynomial.esymm_isSymmetric /-
theorem esymm_isSymmetric (n : ℕ) : IsSymmetric (esymm σ R n) := by intro; rw [rename_esymm]
#align mv_polynomial.esymm_is_symmetric MvPolynomial.esymm_isSymmetric
-/

#print MvPolynomial.support_esymm'' /-
theorem support_esymm'' (n : ℕ) [DecidableEq σ] [Nontrivial R] :
    (esymm σ R n).support =
      (powersetLen n (univ : Finset σ)).biUnion fun t =>
        (Finsupp.single (∑ i : σ in t, Finsupp.single i 1) (1 : R)).support :=
  by
  rw [esymm_eq_sum_monomial]
  simp only [← single_eq_monomial]
  convert Finsupp.support_sum_eq_biUnion (powerset_len n (univ : Finset σ)) _
  intro s t hst
  rw [Finset.disjoint_left]
  simp only [Finsupp.support_single_ne_zero _ one_ne_zero, mem_singleton]
  rintro a h rfl
  have := congr_arg Finsupp.support h
  rw [Finsupp.support_sum_eq_biUnion, Finsupp.support_sum_eq_biUnion] at this 
  · simp only [Finsupp.support_single_ne_zero _ one_ne_zero, bUnion_singleton_eq_self] at this 
    exact absurd this hst.symm
  all_goals intro x y; simp [Finsupp.support_single_disjoint]
#align mv_polynomial.support_esymm'' MvPolynomial.support_esymm''
-/

#print MvPolynomial.support_esymm' /-
theorem support_esymm' (n : ℕ) [DecidableEq σ] [Nontrivial R] :
    (esymm σ R n).support =
      (powersetLen n (univ : Finset σ)).biUnion fun t => {∑ i : σ in t, Finsupp.single i 1} :=
  by
  rw [support_esymm'']
  congr
  funext
  exact Finsupp.support_single_ne_zero _ one_ne_zero
#align mv_polynomial.support_esymm' MvPolynomial.support_esymm'
-/

#print MvPolynomial.support_esymm /-
theorem support_esymm (n : ℕ) [DecidableEq σ] [Nontrivial R] :
    (esymm σ R n).support =
      (powersetLen n (univ : Finset σ)).image fun t => ∑ i : σ in t, Finsupp.single i 1 :=
  by rw [support_esymm']; exact bUnion_singleton
#align mv_polynomial.support_esymm MvPolynomial.support_esymm
-/

#print MvPolynomial.degrees_esymm /-
theorem degrees_esymm [Nontrivial R] (n : ℕ) (hpos : 0 < n) (hn : n ≤ Fintype.card σ) :
    (esymm σ R n).degrees = (univ : Finset σ).val := by
  classical
  have : (Finsupp.toMultiset ∘ fun t : Finset σ => ∑ i : σ in t, Finsupp.single i 1) = Finset.val :=
    by funext; simp [Finsupp.toMultiset_sum_single]
  rw [degrees_def, support_esymm, sup_image, this, ← comp_sup_eq_sup_comp]
  · obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero hpos.ne'
    simpa using powerset_len_sup _ _ (Nat.lt_of_succ_le hn)
  · intros
    simp only [union_val, sup_eq_union]
    congr
  · rfl
#align mv_polynomial.degrees_esymm MvPolynomial.degrees_esymm
-/

end ElementarySymmetric

end MvPolynomial

