/-
Copyright (c) 2020 Aaron Anderson, Jalex Stark. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson, Jalex Stark

! This file was ported from Lean 3 source module linear_algebra.matrix.charpoly.coeff
! leanprover-community/mathlib commit 4280f5f32e16755ec7985ce11e189b6cd6ff6735
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.Expand
import Mathbin.LinearAlgebra.Matrix.Charpoly.Basic

/-!
# Characteristic polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We give methods for computing coefficients of the characteristic polynomial.

## Main definitions

- `matrix.charpoly_degree_eq_dim` proves that the degree of the characteristic polynomial
  over a nonzero ring is the dimension of the matrix
- `matrix.det_eq_sign_charpoly_coeff` proves that the determinant is the constant term of the
  characteristic polynomial, up to sign.
- `matrix.trace_eq_neg_charpoly_coeff` proves that the trace is the negative of the (d-1)th
  coefficient of the characteristic polynomial, where d is the dimension of the matrix.
  For a nonzero ring, this is the second-highest coefficient.

-/


noncomputable section

universe u v w z

open Polynomial Matrix

open scoped BigOperators Polynomial

variable {R : Type u} [CommRing R]

variable {n G : Type v} [DecidableEq n] [Fintype n]

variable {α β : Type v} [DecidableEq α]

open Finset

variable {M : Matrix n n R}

#print charmatrix_apply_natDegree /-
theorem charmatrix_apply_natDegree [Nontrivial R] (i j : n) :
    (charmatrix M i j).natDegree = ite (i = j) 1 0 := by
  by_cases i = j <;> simp [h, ← degree_eq_iff_nat_degree_eq_of_pos (Nat.succ_pos 0)]
#align charmatrix_apply_nat_degree charmatrix_apply_natDegree
-/

#print charmatrix_apply_natDegree_le /-
theorem charmatrix_apply_natDegree_le (i j : n) : (charmatrix M i j).natDegree ≤ ite (i = j) 1 0 :=
  by split_ifs <;> simp [h, nat_degree_X_sub_C_le]
#align charmatrix_apply_nat_degree_le charmatrix_apply_natDegree_le
-/

namespace Matrix

variable (M)

#print Matrix.charpoly_sub_diagonal_degree_lt /-
theorem charpoly_sub_diagonal_degree_lt :
    (M.charpoly - ∏ i : n, (X - C (M i i))).degree < ↑(Fintype.card n - 1) :=
  by
  rw [charpoly, det_apply', ← insert_erase (mem_univ (Equiv.refl n)),
    sum_insert (not_mem_erase (Equiv.refl n) univ), add_comm]
  simp only [charmatrix_apply_eq, one_mul, Equiv.Perm.sign_refl, id.def, Int.cast_one,
    Units.val_one, add_sub_cancel, Equiv.coe_refl]
  rw [← mem_degree_lt]; apply Submodule.sum_mem (degree_lt R (Fintype.card n - 1))
  intro c hc; rw [← C_eq_int_cast, C_mul']
  apply Submodule.smul_mem (degree_lt R (Fintype.card n - 1)) ↑↑(Equiv.Perm.sign c)
  rw [mem_degree_lt]; apply lt_of_le_of_lt degree_le_nat_degree _; rw [WithBot.coe_lt_coe]
  apply lt_of_le_of_lt _ (Equiv.Perm.fixed_point_card_lt_of_ne_one (ne_of_mem_erase hc))
  apply le_trans (Polynomial.natDegree_prod_le univ fun i : n => charmatrix M (c i) i) _
  rw [card_eq_sum_ones]; rw [sum_filter]; apply sum_le_sum
  intros; apply charmatrix_apply_natDegree_le
#align matrix.charpoly_sub_diagonal_degree_lt Matrix.charpoly_sub_diagonal_degree_lt
-/

#print Matrix.charpoly_coeff_eq_prod_coeff_of_le /-
theorem charpoly_coeff_eq_prod_coeff_of_le {k : ℕ} (h : Fintype.card n - 1 ≤ k) :
    M.charpoly.coeff k = (∏ i : n, (X - C (M i i))).coeff k :=
  by
  apply eq_of_sub_eq_zero; rw [← coeff_sub]; apply Polynomial.coeff_eq_zero_of_degree_lt
  apply lt_of_lt_of_le (charpoly_sub_diagonal_degree_lt M) _; rw [WithBot.coe_le_coe]; apply h
#align matrix.charpoly_coeff_eq_prod_coeff_of_le Matrix.charpoly_coeff_eq_prod_coeff_of_le
-/

#print Matrix.det_of_card_zero /-
theorem det_of_card_zero (h : Fintype.card n = 0) (M : Matrix n n R) : M.det = 1 := by
  rw [Fintype.card_eq_zero_iff] at h ; suffices M = 1 by simp [this]; ext i; exact h.elim i
#align matrix.det_of_card_zero Matrix.det_of_card_zero
-/

#print Matrix.charpoly_degree_eq_dim /-
theorem charpoly_degree_eq_dim [Nontrivial R] (M : Matrix n n R) :
    M.charpoly.degree = Fintype.card n :=
  by
  by_cases Fintype.card n = 0
  · rw [h]; unfold charpoly; rw [det_of_card_zero]; · simp; · assumption
  rw [← sub_add_cancel M.charpoly (∏ i : n, (X - C (M i i)))]
  have h1 : (∏ i : n, (X - C (M i i))).degree = Fintype.card n :=
    by
    rw [degree_eq_iff_nat_degree_eq_of_pos]; swap; apply Nat.pos_of_ne_zero h
    rw [nat_degree_prod']; simp_rw [nat_degree_X_sub_C]; unfold Fintype.card; simp
    simp_rw [(monic_X_sub_C _).leadingCoeff]; simp
  rw [degree_add_eq_right_of_degree_lt]; exact h1; rw [h1]
  apply lt_trans (charpoly_sub_diagonal_degree_lt M); rw [WithBot.coe_lt_coe]
  rw [← Nat.pred_eq_sub_one]; apply Nat.pred_lt; apply h
#align matrix.charpoly_degree_eq_dim Matrix.charpoly_degree_eq_dim
-/

#print Matrix.charpoly_natDegree_eq_dim /-
theorem charpoly_natDegree_eq_dim [Nontrivial R] (M : Matrix n n R) :
    M.charpoly.natDegree = Fintype.card n :=
  natDegree_eq_of_degree_eq_some (charpoly_degree_eq_dim M)
#align matrix.charpoly_nat_degree_eq_dim Matrix.charpoly_natDegree_eq_dim
-/

#print Matrix.charpoly_monic /-
theorem charpoly_monic (M : Matrix n n R) : M.charpoly.Monic :=
  by
  nontriviality
  by_cases Fintype.card n = 0; · rw [charpoly, det_of_card_zero h]; apply monic_one
  have mon : (∏ i : n, (X - C (M i i))).Monic := by
    apply monic_prod_of_monic univ fun i : n => X - C (M i i); simp [monic_X_sub_C]
  rw [← sub_add_cancel (∏ i : n, (X - C (M i i))) M.charpoly] at mon 
  rw [monic] at *; rw [leading_coeff_add_of_degree_lt] at mon ; rw [← mon]
  rw [charpoly_degree_eq_dim]; rw [← neg_sub]; rw [degree_neg]
  apply lt_trans (charpoly_sub_diagonal_degree_lt M); rw [WithBot.coe_lt_coe]
  rw [← Nat.pred_eq_sub_one]; apply Nat.pred_lt; apply h
#align matrix.charpoly_monic Matrix.charpoly_monic
-/

#print Matrix.trace_eq_neg_charpoly_coeff /-
theorem trace_eq_neg_charpoly_coeff [Nonempty n] (M : Matrix n n R) :
    trace M = -M.charpoly.coeff (Fintype.card n - 1) :=
  by
  rw [charpoly_coeff_eq_prod_coeff_of_le]; swap; rfl
  rw [Fintype.card, prod_X_sub_C_coeff_card_pred univ (fun i : n => M i i) Fintype.card_pos,
    neg_neg, trace]
  rfl
#align matrix.trace_eq_neg_charpoly_coeff Matrix.trace_eq_neg_charpoly_coeff
-/

#print Matrix.matPolyEquiv_eval /-
-- I feel like this should use polynomial.alg_hom_eval₂_algebra_map
theorem matPolyEquiv_eval (M : Matrix n n R[X]) (r : R) (i j : n) :
    (matPolyEquiv M).eval ((scalar n) r) i j = (M i j).eval r :=
  by
  unfold Polynomial.eval; unfold eval₂
  trans Polynomial.sum (matPolyEquiv M) fun (e : ℕ) (a : Matrix n n R) => (a * (scalar n) r ^ e) i j
  · unfold Polynomial.sum; rw [sum_apply]; dsimp; rfl
  · simp_rw [← RingHom.map_pow, ← (scalar.commute _ _).Eq]
    simp only [coe_scalar, Matrix.one_mul, RingHom.id_apply, Pi.smul_apply, smul_eq_mul, mul_eq_mul,
      Algebra.smul_mul_assoc]
    have h : ∀ x : ℕ, (fun (e : ℕ) (a : R) => r ^ e * a) x 0 = 0 := by simp
    simp only [Polynomial.sum, matPolyEquiv_coeff_apply, mul_comm]
    apply (Finset.sum_subset (support_subset_support_matPolyEquiv _ _ _) _).symm
    intro n hn h'n
    rw [not_mem_support_iff] at h'n 
    simp only [h'n, MulZeroClass.zero_mul]
#align matrix.mat_poly_equiv_eval Matrix.matPolyEquiv_eval
-/

#print Matrix.eval_det /-
theorem eval_det (M : Matrix n n R[X]) (r : R) :
    Polynomial.eval r M.det = (Polynomial.eval (scalar n r) (matPolyEquiv M)).det :=
  by
  rw [Polynomial.eval, ← coe_eval₂_ring_hom, RingHom.map_det]
  apply congr_arg det; ext; symm; convert mat_poly_equiv_eval _ _ _ _
#align matrix.eval_det Matrix.eval_det
-/

#print Matrix.det_eq_sign_charpoly_coeff /-
theorem det_eq_sign_charpoly_coeff (M : Matrix n n R) :
    M.det = (-1) ^ Fintype.card n * M.charpoly.coeff 0 :=
  by
  rw [coeff_zero_eq_eval_zero, charpoly, eval_det, matPolyEquiv_charmatrix, ← det_smul]
  simp
#align matrix.det_eq_sign_charpoly_coeff Matrix.det_eq_sign_charpoly_coeff
-/

end Matrix

variable {p : ℕ} [Fact p.Prime]

#print matPolyEquiv_eq_x_pow_sub_c /-
theorem matPolyEquiv_eq_x_pow_sub_c {K : Type _} (k : ℕ) [Field K] (M : Matrix n n K) :
    matPolyEquiv ((expand K k : K[X] →+* K[X]).mapMatrix (charmatrix (M ^ k))) =
      X ^ k - C (M ^ k) :=
  by
  ext m
  rw [coeff_sub, coeff_C, matPolyEquiv_coeff_apply, RingHom.mapMatrix_apply, Matrix.map_apply,
    AlgHom.coe_toRingHom, DMatrix.sub_apply, coeff_X_pow]
  by_cases hij : i = j
  · rw [hij, charmatrix_apply_eq, AlgHom.map_sub, expand_C, expand_X, coeff_sub, coeff_X_pow,
      coeff_C]
    split_ifs with mp m0 <;> simp only [Matrix.one_apply_eq, DMatrix.zero_apply]
  · rw [charmatrix_apply_ne _ _ _ hij, AlgHom.map_neg, expand_C, coeff_neg, coeff_C]
    split_ifs with m0 mp <;>
      simp only [hij, zero_sub, DMatrix.zero_apply, sub_zero, neg_zero, Matrix.one_apply_ne, Ne.def,
        not_false_iff]
#align mat_poly_equiv_eq_X_pow_sub_C matPolyEquiv_eq_x_pow_sub_c
-/

namespace Matrix

#print Matrix.aeval_eq_aeval_mod_charpoly /-
/-- Any matrix polynomial `p` is equivalent under evaluation to `p %ₘ M.charpoly`; that is, `p`
is equivalent to a polynomial with degree less than the dimension of the matrix. -/
theorem aeval_eq_aeval_mod_charpoly (M : Matrix n n R) (p : R[X]) :
    aeval M p = aeval M (p %ₘ M.charpoly) :=
  (aeval_modByMonic_eq_self_of_root M.charpoly_monic M.aeval_self_charpoly).symm
#align matrix.aeval_eq_aeval_mod_charpoly Matrix.aeval_eq_aeval_mod_charpoly
-/

#print Matrix.pow_eq_aeval_mod_charpoly /-
/-- Any matrix power can be computed as the sum of matrix powers less than `fintype.card n`.

TODO: add the statement for negative powers phrased with `zpow`. -/
theorem pow_eq_aeval_mod_charpoly (M : Matrix n n R) (k : ℕ) :
    M ^ k = aeval M (X ^ k %ₘ M.charpoly) := by rw [← aeval_eq_aeval_mod_charpoly, map_pow, aeval_X]
#align matrix.pow_eq_aeval_mod_charpoly Matrix.pow_eq_aeval_mod_charpoly
-/

end Matrix

section Ideal

#print coeff_charpoly_mem_ideal_pow /-
theorem coeff_charpoly_mem_ideal_pow {I : Ideal R} (h : ∀ i j, M i j ∈ I) (k : ℕ) :
    M.charpoly.coeff k ∈ I ^ (Fintype.card n - k) :=
  by
  delta charpoly
  rw [Matrix.det_apply, finset_sum_coeff]
  apply sum_mem
  rintro c -
  rw [coeff_smul, Submodule.smul_mem_iff']
  have : ∑ x : n, 1 = Fintype.card n := by rw [Finset.sum_const, card_univ, smul_eq_mul, mul_one]
  rw [← this]
  apply coeff_prod_mem_ideal_pow_tsub
  rintro i - (_ | k)
  · rw [tsub_zero, pow_one, charmatrix_apply, coeff_sub, coeff_X_mul_zero, coeff_C_zero, zero_sub,
      neg_mem_iff]
    exact h (c i) i
  · rw [Nat.succ_eq_one_add, tsub_self_add, pow_zero, Ideal.one_eq_top]
    exact Submodule.mem_top
#align coeff_charpoly_mem_ideal_pow coeff_charpoly_mem_ideal_pow
-/

end Ideal

