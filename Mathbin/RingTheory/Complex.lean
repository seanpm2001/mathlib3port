/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module ring_theory.complex
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Complex.Module
import Mathbin.RingTheory.Norm
import Mathbin.RingTheory.Trace

/-! # Lemmas about `algebra.trace` and `algebra.norm` on `ℂ` 

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


open Complex

#print Algebra.leftMulMatrix_complex /-
theorem Algebra.leftMulMatrix_complex (z : ℂ) :
    Algebra.leftMulMatrix Complex.basisOneI z = !![z.re, -z.im; z.im, z.re] :=
  by
  ext i j
  rw [Algebra.leftMulMatrix_eq_repr_mul, Complex.coe_basisOneI_repr, Complex.coe_basisOneI, mul_re,
    mul_im, Matrix.of_apply]
  fin_cases j
  · simp_rw [Matrix.cons_val_zero, one_re, one_im, MulZeroClass.mul_zero, mul_one, sub_zero,
      zero_add]
    fin_cases i <;> rfl
  · simp_rw [Matrix.cons_val_one, Matrix.head_cons, I_re, I_im, MulZeroClass.mul_zero, mul_one,
      zero_sub, add_zero]
    fin_cases i <;> rfl
#align algebra.left_mul_matrix_complex Algebra.leftMulMatrix_complex
-/

#print Algebra.trace_complex_apply /-
theorem Algebra.trace_complex_apply (z : ℂ) : Algebra.trace ℝ ℂ z = 2 * z.re :=
  by
  rw [Algebra.trace_eq_matrix_trace Complex.basisOneI, Algebra.leftMulMatrix_complex,
    Matrix.trace_fin_two]
  exact (two_mul _).symm
#align algebra.trace_complex_apply Algebra.trace_complex_apply
-/

#print Algebra.norm_complex_apply /-
theorem Algebra.norm_complex_apply (z : ℂ) : Algebra.norm ℝ z = z.normSq :=
  by
  rw [Algebra.norm_eq_matrix_det Complex.basisOneI, Algebra.leftMulMatrix_complex,
    Matrix.det_fin_two, norm_sq_apply]
  simp
#align algebra.norm_complex_apply Algebra.norm_complex_apply
-/

#print Algebra.norm_complex_eq /-
theorem Algebra.norm_complex_eq : Algebra.norm ℝ = normSq.toMonoidHom :=
  MonoidHom.ext Algebra.norm_complex_apply
#align algebra.norm_complex_eq Algebra.norm_complex_eq
-/

