/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module analysis.special_functions.trigonometric.chebyshev
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Complex.Basic
import Mathbin.Data.Complex.Exponential
import Mathbin.Data.Polynomial.AlgebraMap
import Mathbin.RingTheory.Polynomial.Chebyshev

/-!
# Multiple angle formulas in terms of Chebyshev polynomials

This file gives the trigonometric characterizations of Chebyshev polynomials, for both the real
(`real.cos`) and complex (`complex.cos`) cosine.
-/


namespace Polynomial.Chebyshev

open Polynomial

variable {R A : Type _} [CommRing R] [CommRing A] [Algebra R A]

@[simp]
theorem aeval_T (x : A) (n : ℕ) : aeval x (t R n) = (t A n).eval x := by
  rw [aeval_def, eval₂_eq_eval_map, map_T]
#align polynomial.chebyshev.aeval_T Polynomial.Chebyshev.aeval_T

@[simp]
theorem aeval_U (x : A) (n : ℕ) : aeval x (u R n) = (u A n).eval x := by
  rw [aeval_def, eval₂_eq_eval_map, map_U]
#align polynomial.chebyshev.aeval_U Polynomial.Chebyshev.aeval_U

@[simp]
theorem algebra_map_eval_T (x : R) (n : ℕ) :
    algebraMap R A ((t R n).eval x) = (t A n).eval (algebraMap R A x) := by
  rw [← aeval_algebra_map_apply_eq_algebra_map_eval, aeval_T]
#align polynomial.chebyshev.algebra_map_eval_T Polynomial.Chebyshev.algebra_map_eval_T

@[simp]
theorem algebra_map_eval_U (x : R) (n : ℕ) :
    algebraMap R A ((u R n).eval x) = (u A n).eval (algebraMap R A x) := by
  rw [← aeval_algebra_map_apply_eq_algebra_map_eval, aeval_U]
#align polynomial.chebyshev.algebra_map_eval_U Polynomial.Chebyshev.algebra_map_eval_U

@[simp, norm_cast]
theorem complex_of_real_eval_T : ∀ x n, ((t ℝ n).eval x : ℂ) = (t ℂ n).eval x :=
  @algebra_map_eval_T ℝ ℂ _ _ _
#align polynomial.chebyshev.complex_of_real_eval_T Polynomial.Chebyshev.complex_of_real_eval_T

@[simp, norm_cast]
theorem complex_of_real_eval_U : ∀ x n, ((u ℝ n).eval x : ℂ) = (u ℂ n).eval x :=
  @algebra_map_eval_U ℝ ℂ _ _ _
#align polynomial.chebyshev.complex_of_real_eval_U Polynomial.Chebyshev.complex_of_real_eval_U

/-! ### Complex versions -/


section Complex

open Complex

variable (θ : ℂ)

/-- The `n`-th Chebyshev polynomial of the first kind evaluates on `cos θ` to the
value `cos (n * θ)`. -/
@[simp]
theorem T_complex_cos : ∀ n, (t ℂ n).eval (cos θ) = cos (n * θ)
  | 0 => by simp only [T_zero, eval_one, Nat.cast_zero, zero_mul, cos_zero]
  | 1 => by simp only [eval_X, one_mul, T_one, Nat.cast_one]
  | n + 2 => by
    simp only [eval_X, eval_one, T_add_two, eval_sub, eval_bit0, Nat.cast_succ, eval_mul]
    rw [T_complex_cos (n + 1), T_complex_cos n]
    have aux : sin θ * sin θ = 1 - cos θ * cos θ := by
      rw [← sin_sq_add_cos_sq θ]
      ring
    simp only [Nat.cast_add, Nat.cast_one, add_mul, cos_add, one_mul, sin_add, mul_assoc, aux]
    ring
#align polynomial.chebyshev.T_complex_cos Polynomial.Chebyshev.T_complex_cos

/-- The `n`-th Chebyshev polynomial of the second kind evaluates on `cos θ` to the
value `sin ((n + 1) * θ) / sin θ`. -/
@[simp]
theorem U_complex_cos (n : ℕ) : (u ℂ n).eval (cos θ) * sin θ = sin ((n + 1) * θ) := by
  induction' n with d hd
  · simp only [U_zero, Nat.cast_zero, eval_one, mul_one, zero_add, one_mul]
  · rw [U_eq_X_mul_U_add_T]
    simp only [eval_add, eval_mul, eval_X, T_complex_cos, add_mul, mul_assoc, hd, one_mul]
    conv_rhs => rw [sin_add, mul_comm]
    push_cast
    simp only [add_mul, one_mul]
#align polynomial.chebyshev.U_complex_cos Polynomial.Chebyshev.U_complex_cos

end Complex

-- ### Real versions
section Real

open Real

variable (θ : ℝ) (n : ℕ)

/-- The `n`-th Chebyshev polynomial of the first kind evaluates on `cos θ` to the
value `cos (n * θ)`. -/
@[simp]
theorem T_real_cos : (t ℝ n).eval (cos θ) = cos (n * θ) := by exact_mod_cast T_complex_cos θ n
#align polynomial.chebyshev.T_real_cos Polynomial.Chebyshev.T_real_cos

/-- The `n`-th Chebyshev polynomial of the second kind evaluates on `cos θ` to the
value `sin ((n + 1) * θ) / sin θ`. -/
@[simp]
theorem U_real_cos : (u ℝ n).eval (cos θ) * sin θ = sin ((n + 1) * θ) := by
  exact_mod_cast U_complex_cos θ n
#align polynomial.chebyshev.U_real_cos Polynomial.Chebyshev.U_real_cos

end Real

end Polynomial.Chebyshev

