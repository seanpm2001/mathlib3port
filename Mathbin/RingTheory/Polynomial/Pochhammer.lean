/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module ring_theory.polynomial.pochhammer
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Abel
import Mathbin.Data.Polynomial.Eval

/-!
# The Pochhammer polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define and prove some basic relations about
`pochhammer S n : S[X] := X * (X + 1) * ... * (X + n - 1)`
which is also known as the rising factorial. A version of this definition
that is focused on `nat` can be found in `data.nat.factorial` as `nat.asc_factorial`.

## Implementation

As with many other families of polynomials, even though the coefficients are always in `ℕ`,
we define the polynomial with coefficients in any `[semiring S]`.

## TODO

There is lots more in this direction:
* q-factorials, q-binomials, q-Pochhammer.
-/


universe u v

open Polynomial

open scoped Polynomial

section Semiring

variable (S : Type u) [Semiring S]

#print pochhammer /-
/-- `pochhammer S n` is the polynomial `X * (X+1) * ... * (X + n - 1)`,
with coefficients in the semiring `S`.
-/
noncomputable def pochhammer : ℕ → S[X]
  | 0 => 1
  | n + 1 => X * (pochhammer n).comp (X + 1)
#align pochhammer pochhammer
-/

#print pochhammer_zero /-
@[simp]
theorem pochhammer_zero : pochhammer S 0 = 1 :=
  rfl
#align pochhammer_zero pochhammer_zero
-/

#print pochhammer_one /-
@[simp]
theorem pochhammer_one : pochhammer S 1 = X := by simp [pochhammer]
#align pochhammer_one pochhammer_one
-/

#print pochhammer_succ_left /-
theorem pochhammer_succ_left (n : ℕ) : pochhammer S (n + 1) = X * (pochhammer S n).comp (X + 1) :=
  by rw [pochhammer]
#align pochhammer_succ_left pochhammer_succ_left
-/

section

variable {S} {T : Type v} [Semiring T]

#print pochhammer_map /-
@[simp]
theorem pochhammer_map (f : S →+* T) (n : ℕ) : (pochhammer S n).map f = pochhammer T n :=
  by
  induction' n with n ih
  · simp
  · simp [ih, pochhammer_succ_left, map_comp]
#align pochhammer_map pochhammer_map
-/

end

#print pochhammer_eval_cast /-
@[simp, norm_cast]
theorem pochhammer_eval_cast (n k : ℕ) : ((pochhammer ℕ n).eval k : S) = (pochhammer S n).eval k :=
  by
  rw [← pochhammer_map (algebraMap ℕ S), eval_map, ← eq_natCast (algebraMap ℕ S), eval₂_at_nat_cast,
    Nat.cast_id, eq_natCast]
#align pochhammer_eval_cast pochhammer_eval_cast
-/

#print pochhammer_eval_zero /-
theorem pochhammer_eval_zero {n : ℕ} : (pochhammer S n).eval 0 = if n = 0 then 1 else 0 :=
  by
  cases n
  · simp
  · simp [X_mul, Nat.succ_ne_zero, pochhammer_succ_left]
#align pochhammer_eval_zero pochhammer_eval_zero
-/

#print pochhammer_zero_eval_zero /-
theorem pochhammer_zero_eval_zero : (pochhammer S 0).eval 0 = 1 := by simp
#align pochhammer_zero_eval_zero pochhammer_zero_eval_zero
-/

#print pochhammer_ne_zero_eval_zero /-
@[simp]
theorem pochhammer_ne_zero_eval_zero {n : ℕ} (h : n ≠ 0) : (pochhammer S n).eval 0 = 0 := by
  simp [pochhammer_eval_zero, h]
#align pochhammer_ne_zero_eval_zero pochhammer_ne_zero_eval_zero
-/

#print pochhammer_succ_right /-
theorem pochhammer_succ_right (n : ℕ) : pochhammer S (n + 1) = pochhammer S n * (X + n) :=
  by
  suffices h : pochhammer ℕ (n + 1) = pochhammer ℕ n * (X + n)
  · apply_fun Polynomial.map (algebraMap ℕ S) at h 
    simpa only [pochhammer_map, Polynomial.map_mul, Polynomial.map_add, map_X,
      Polynomial.map_nat_cast] using h
  induction' n with n ih
  · simp
  ·
    conv_lhs =>
      rw [pochhammer_succ_left, ih, mul_comp, ← mul_assoc, ← pochhammer_succ_left, add_comp, X_comp,
        nat_cast_comp, add_assoc, add_comm (1 : ℕ[X]), ← Nat.cast_succ]
#align pochhammer_succ_right pochhammer_succ_right
-/

#print pochhammer_succ_eval /-
theorem pochhammer_succ_eval {S : Type _} [Semiring S] (n : ℕ) (k : S) :
    (pochhammer S (n + 1)).eval k = (pochhammer S n).eval k * (k + n) := by
  rw [pochhammer_succ_right, mul_add, eval_add, eval_mul_X, ← Nat.cast_comm, ← C_eq_nat_cast,
    eval_C_mul, Nat.cast_comm, ← mul_add]
#align pochhammer_succ_eval pochhammer_succ_eval
-/

#print pochhammer_succ_comp_X_add_one /-
theorem pochhammer_succ_comp_X_add_one (n : ℕ) :
    (pochhammer S (n + 1)).comp (X + 1) =
      pochhammer S (n + 1) + (n + 1) • (pochhammer S n).comp (X + 1) :=
  by
  suffices
    (pochhammer ℕ (n + 1)).comp (X + 1) =
      pochhammer ℕ (n + 1) + (n + 1) * (pochhammer ℕ n).comp (X + 1)
    by simpa [map_comp] using congr_arg (Polynomial.map (Nat.castRingHom S)) this
  nth_rw 2 [pochhammer_succ_left]
  rw [← add_mul, pochhammer_succ_right ℕ n, mul_comp, mul_comm, add_comp, X_comp, nat_cast_comp,
    add_comm ↑n, ← add_assoc]
#align pochhammer_succ_comp_X_add_one pochhammer_succ_comp_X_add_one
-/

#print Polynomial.mul_X_add_nat_cast_comp /-
theorem Polynomial.mul_X_add_nat_cast_comp {p q : S[X]} {n : ℕ} :
    (p * (X + n)).comp q = p.comp q * (q + n) := by
  rw [mul_add, add_comp, mul_X_comp, ← Nat.cast_comm, nat_cast_mul_comp, Nat.cast_comm, mul_add]
#align polynomial.mul_X_add_nat_cast_comp Polynomial.mul_X_add_nat_cast_comp
-/

#print pochhammer_mul /-
theorem pochhammer_mul (n m : ℕ) :
    pochhammer S n * (pochhammer S m).comp (X + n) = pochhammer S (n + m) :=
  by
  induction' m with m ih
  · simp
  ·
    rw [pochhammer_succ_right, Polynomial.mul_X_add_nat_cast_comp, ← mul_assoc, ih,
      Nat.succ_eq_add_one, ← add_assoc, pochhammer_succ_right, Nat.cast_add, add_assoc]
#align pochhammer_mul pochhammer_mul
-/

#print pochhammer_nat_eq_ascFactorial /-
theorem pochhammer_nat_eq_ascFactorial (n : ℕ) :
    ∀ k, (pochhammer ℕ k).eval (n + 1) = n.ascFactorial k
  | 0 => by erw [eval_one] <;> rfl
  | t + 1 => by
    rw [pochhammer_succ_right, eval_mul, pochhammer_nat_eq_ascFactorial t]
    suffices n.asc_factorial t * (n + 1 + t) = n.asc_factorial (t + 1) by simpa
    rw [Nat.ascFactorial_succ, add_right_comm, mul_comm]
#align pochhammer_nat_eq_asc_factorial pochhammer_nat_eq_ascFactorial
-/

#print pochhammer_nat_eq_descFactorial /-
theorem pochhammer_nat_eq_descFactorial (a b : ℕ) :
    (pochhammer ℕ b).eval a = (a + b - 1).descFactorial b :=
  by
  cases b
  · rw [Nat.descFactorial_zero, pochhammer_zero, Polynomial.eval_one]
  rw [Nat.add_succ, Nat.succ_sub_succ, tsub_zero]
  cases a
  ·
    rw [pochhammer_ne_zero_eval_zero _ b.succ_ne_zero, zero_add,
      Nat.descFactorial_of_lt b.lt_succ_self]
  ·
    rw [Nat.succ_add, ← Nat.add_succ, Nat.add_descFactorial_eq_ascFactorial,
      pochhammer_nat_eq_ascFactorial]
#align pochhammer_nat_eq_desc_factorial pochhammer_nat_eq_descFactorial
-/

end Semiring

section StrictOrderedSemiring

variable {S : Type _} [StrictOrderedSemiring S]

#print pochhammer_pos /-
theorem pochhammer_pos (n : ℕ) (s : S) (h : 0 < s) : 0 < (pochhammer S n).eval s :=
  by
  induction' n with n ih
  · simp only [Nat.zero_eq, pochhammer_zero, eval_one]; exact zero_lt_one
  · rw [pochhammer_succ_right, mul_add, eval_add, ← Nat.cast_comm, eval_nat_cast_mul, eval_mul_X,
      Nat.cast_comm, ← mul_add]
    exact mul_pos ih (lt_of_lt_of_le h ((le_add_iff_nonneg_right _).mpr (Nat.cast_nonneg n)))
#align pochhammer_pos pochhammer_pos
-/

end StrictOrderedSemiring

section Factorial

open scoped Nat

variable (S : Type _) [Semiring S] (r n : ℕ)

#print pochhammer_eval_one /-
@[simp]
theorem pochhammer_eval_one (S : Type _) [Semiring S] (n : ℕ) :
    (pochhammer S n).eval (1 : S) = (n ! : S) := by
  rw_mod_cast [pochhammer_nat_eq_ascFactorial, Nat.zero_ascFactorial]
#align pochhammer_eval_one pochhammer_eval_one
-/

#print factorial_mul_pochhammer /-
theorem factorial_mul_pochhammer (S : Type _) [Semiring S] (r n : ℕ) :
    (r ! : S) * (pochhammer S n).eval (r + 1) = (r + n)! := by
  rw_mod_cast [pochhammer_nat_eq_ascFactorial, Nat.factorial_mul_ascFactorial]
#align factorial_mul_pochhammer factorial_mul_pochhammer
-/

#print pochhammer_nat_eval_succ /-
theorem pochhammer_nat_eval_succ (r : ℕ) :
    ∀ n : ℕ, n * (pochhammer ℕ r).eval (n + 1) = (n + r) * (pochhammer ℕ r).eval n
  | 0 => by
    by_cases h : r = 0
    · simp only [h, MulZeroClass.zero_mul, zero_add]
    · simp only [pochhammer_eval_zero, MulZeroClass.zero_mul, if_neg h, MulZeroClass.mul_zero]
  | k + 1 => by simp only [pochhammer_nat_eq_ascFactorial, Nat.succ_ascFactorial, add_right_comm]
#align pochhammer_nat_eval_succ pochhammer_nat_eval_succ
-/

#print pochhammer_eval_succ /-
theorem pochhammer_eval_succ (r n : ℕ) :
    (n : S) * (pochhammer S r).eval (n + 1 : S) = (n + r) * (pochhammer S r).eval n := by
  exact_mod_cast congr_arg Nat.cast (pochhammer_nat_eval_succ r n)
#align pochhammer_eval_succ pochhammer_eval_succ
-/

end Factorial

