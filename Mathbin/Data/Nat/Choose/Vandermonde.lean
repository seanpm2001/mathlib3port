/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module data.nat.choose.vandermonde
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.Coeff
import Mathbin.Data.Nat.Choose.Basic

/-!

# Vandermonde's identity

In this file we prove Vandermonde's identity (`nat.add_choose_eq`):
`(m + n).choose k = ∑ (ij : ℕ × ℕ) in antidiagonal k, m.choose ij.1 * n.choose ij.2`

We follow the algebraic proof from
https://en.wikipedia.org/wiki/Vandermonde%27s_identity#Algebraic_proof .

-/


open BigOperators

open Polynomial Finset.Nat

/-- Vandermonde's identity -/
theorem Nat.add_choose_eq (m n k : ℕ) :
    (m + n).choose k = ∑ ij : ℕ × ℕ in antidiagonal k, m.choose ij.1 * n.choose ij.2 :=
  by
  calc
    (m + n).choose k = ((X + 1) ^ (m + n)).coeff k := _
    _ = ((X + 1) ^ m * (X + 1) ^ n).coeff k := by rw [pow_add]
    _ = ∑ ij : ℕ × ℕ in antidiagonal k, m.choose ij.1 * n.choose ij.2 := _
    
  · rw [coeff_X_add_one_pow, Nat.cast_id]
  · rw [coeff_mul, Finset.sum_congr rfl]
    simp only [coeff_X_add_one_pow, Nat.cast_id, eq_self_iff_true, imp_true_iff]
#align nat.add_choose_eq Nat.add_choose_eq

