/-
Copyright (c) 2023 Luke Mantle. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Luke Mantle, Jake Levinson

! This file was ported from Lean 3 source module ring_theory.polynomial.hermite.gaussian
! leanprover-community/mathlib commit d07a9c875ed7139abfde6a333b2be205c5bd404e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Polynomial.Hermite.Basic
import Mathbin.Analysis.Calculus.Deriv.Pow
import Mathbin.Analysis.Calculus.Deriv.Add
import Mathbin.Analysis.SpecialFunctions.Exp
import Mathbin.Analysis.SpecialFunctions.ExpDeriv

/-!
# Hermite polynomials and Gaussians

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file shows that the Hermite polynomial `hermite n` is (up to sign) the
polynomial factor occurring in the `n`th derivative of a gaussian.

## Results

* `polynomial.deriv_gaussian_eq_hermite_mul_gaussian`:
  The Hermite polynomial is (up to sign) the polynomial factor occurring in the
  `n`th derivative of a gaussian.

## References

* [Hermite Polynomials](https://en.wikipedia.org/wiki/Hermite_polynomials)

-/


noncomputable section

open Polynomial

namespace Polynomial

#print Polynomial.deriv_gaussian_eq_hermite_mul_gaussian /-
/-- `hermite n` is (up to sign) the factor appearing in `deriv^[n]` of a gaussian -/
theorem deriv_gaussian_eq_hermite_mul_gaussian (n : ℕ) (x : ℝ) :
    (deriv^[n]) (fun y => Real.exp (-(y ^ 2 / 2))) x =
      (-1 : ℝ) ^ n * aeval x (hermite n) * Real.exp (-(x ^ 2 / 2)) :=
  by
  rw [mul_assoc]
  induction' n with n ih generalizing x
  · rw [Function.iterate_zero_apply, pow_zero, one_mul, hermite_zero, C_1, map_one, one_mul]
  · replace ih : (deriv^[n]) _ = _ := _root_.funext ih
    have deriv_gaussian :
      deriv (fun y => Real.exp (-(y ^ 2 / 2))) x = -x * Real.exp (-(x ^ 2 / 2)) := by
      simp [mul_comm, ← neg_mul]
    rw [Function.iterate_succ_apply', ih, deriv_const_mul_field, deriv_mul, pow_succ (-1 : ℝ),
      deriv_gaussian, hermite_succ, map_sub, map_mul, aeval_X, Polynomial.deriv_aeval]
    ring
    · apply Polynomial.differentiable_aeval
    · simp
#align polynomial.deriv_gaussian_eq_hermite_mul_gaussian Polynomial.deriv_gaussian_eq_hermite_mul_gaussian
-/

#print Polynomial.hermite_eq_deriv_gaussian /-
theorem hermite_eq_deriv_gaussian (n : ℕ) (x : ℝ) :
    aeval x (hermite n) =
      (-1 : ℝ) ^ n * (deriv^[n]) (fun y => Real.exp (-(y ^ 2 / 2))) x / Real.exp (-(x ^ 2 / 2)) :=
  by
  rw [deriv_gaussian_eq_hermite_mul_gaussian]
  field_simp [Real.exp_ne_zero]
  rw [← @smul_eq_mul ℝ _ ((-1) ^ n), ← inv_smul_eq_iff₀, mul_assoc, smul_eq_mul, ← inv_pow, ←
    neg_inv, inv_one]
  exact pow_ne_zero _ (by norm_num)
#align polynomial.hermite_eq_deriv_gaussian Polynomial.hermite_eq_deriv_gaussian
-/

#print Polynomial.hermite_eq_deriv_gaussian' /-
theorem hermite_eq_deriv_gaussian' (n : ℕ) (x : ℝ) :
    aeval x (hermite n) =
      (-1 : ℝ) ^ n * (deriv^[n]) (fun y => Real.exp (-(y ^ 2 / 2))) x * Real.exp (x ^ 2 / 2) :=
  by
  rw [hermite_eq_deriv_gaussian, Real.exp_neg]
  field_simp [Real.exp_ne_zero]
#align polynomial.hermite_eq_deriv_gaussian' Polynomial.hermite_eq_deriv_gaussian'
-/

end Polynomial

