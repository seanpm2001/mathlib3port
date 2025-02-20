/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module linear_algebra.matrix.absolute_value
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.AbsoluteValue
import Mathbin.LinearAlgebra.Matrix.Determinant

/-!
# Absolute values and matrices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves some bounds on matrices involving absolute values.

## Main results

 * `matrix.det_le`: if the entries of an `n × n` matrix are bounded by `x`,
   then the determinant is bounded by `n! x^n`
 * `matrix.det_sum_le`: if we have `s` `n × n` matrices and the entries of each
   matrix are bounded by `x`, then the determinant of their sum is bounded by `n! (s * x)^n`
 * `matrix.det_sum_smul_le`: if we have `s` `n × n` matrices each multiplied by
   a constant bounded by `y`, and the entries of each matrix are bounded by `x`,
   then the determinant of the linear combination is bounded by `n! (s * y * x)^n`
-/


open scoped BigOperators

open scoped Matrix

namespace Matrix

open Equiv Finset

variable {R S : Type _} [CommRing R] [Nontrivial R] [LinearOrderedCommRing S]

variable {n : Type _} [Fintype n] [DecidableEq n]

#print Matrix.det_le /-
theorem det_le {A : Matrix n n R} {abv : AbsoluteValue R S} {x : S} (hx : ∀ i j, abv (A i j) ≤ x) :
    abv A.det ≤ Nat.factorial (Fintype.card n) • x ^ Fintype.card n :=
  calc
    abv A.det = abv (∑ σ : Perm n, _) := congr_arg abv (det_apply _)
    _ ≤ ∑ σ : Perm n, abv _ := (abv.sum_le _ _)
    _ = ∑ σ : Perm n, ∏ i, abv (A (σ i) i) :=
      (sum_congr rfl fun σ hσ => by rw [abv.map_units_int_smul, abv.map_prod])
    _ ≤ ∑ σ : Perm n, ∏ i : n, x :=
      (sum_le_sum fun _ _ => prod_le_prod (fun _ _ => abv.NonNeg _) fun _ _ => hx _ _)
    _ = ∑ σ : Perm n, x ^ Fintype.card n :=
      (sum_congr rfl fun _ _ => by rw [prod_const, Finset.card_univ])
    _ = Nat.factorial (Fintype.card n) • x ^ Fintype.card n := by
      rw [sum_const, Finset.card_univ, Fintype.card_perm]
#align matrix.det_le Matrix.det_le
-/

#print Matrix.det_sum_le /-
theorem det_sum_le {ι : Type _} (s : Finset ι) {A : ι → Matrix n n R} {abv : AbsoluteValue R S}
    {x : S} (hx : ∀ k i j, abv (A k i j) ≤ x) :
    abv (det (∑ k in s, A k)) ≤
      Nat.factorial (Fintype.card n) • (Finset.card s • x) ^ Fintype.card n :=
  det_le fun i j =>
    calc
      abv ((∑ k in s, A k) i j) = abv (∑ k in s, A k i j) := by simp only [sum_apply]
      _ ≤ ∑ k in s, abv (A k i j) := (abv.sum_le _ _)
      _ ≤ ∑ k in s, x := (sum_le_sum fun k _ => hx k i j)
      _ = s.card • x := sum_const _
#align matrix.det_sum_le Matrix.det_sum_le
-/

#print Matrix.det_sum_smul_le /-
theorem det_sum_smul_le {ι : Type _} (s : Finset ι) {c : ι → R} {A : ι → Matrix n n R}
    {abv : AbsoluteValue R S} {x : S} (hx : ∀ k i j, abv (A k i j) ≤ x) {y : S}
    (hy : ∀ k, abv (c k) ≤ y) :
    abv (det (∑ k in s, c k • A k)) ≤
      Nat.factorial (Fintype.card n) • (Finset.card s • y * x) ^ Fintype.card n :=
  by
  simpa only [smul_mul_assoc] using
    det_sum_le s fun k i j =>
      calc
        abv (c k * A k i j) = abv (c k) * abv (A k i j) := abv.map_mul _ _
        _ ≤ y * x := mul_le_mul (hy k) (hx k i j) (abv.nonneg _) ((abv.nonneg _).trans (hy k))
#align matrix.det_sum_smul_le Matrix.det_sum_smul_le
-/

end Matrix

