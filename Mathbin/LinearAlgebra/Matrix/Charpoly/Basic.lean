/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module linear_algebra.matrix.charpoly.basic
! leanprover-community/mathlib commit 4280f5f32e16755ec7985ce11e189b6cd6ff6735
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Matrix.Adjugate
import Mathbin.RingTheory.PolynomialAlgebra
import Mathbin.Tactic.ApplyFun
import Mathbin.Tactic.Squeeze

/-!
# Characteristic polynomials and the Cayley-Hamilton theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define characteristic polynomials of matrices and
prove the Cayley–Hamilton theorem over arbitrary commutative rings.

See the file `matrix/charpoly/coeff` for corollaries of this theorem.

## Main definitions

* `matrix.charpoly` is the characteristic polynomial of a matrix.

## Implementation details

We follow a nice proof from http://drorbn.net/AcademicPensieve/2015-12/CayleyHamilton.pdf
-/


noncomputable section

universe u v w

open Polynomial Matrix

open scoped BigOperators Polynomial

variable {R : Type u} [CommRing R]

variable {n : Type w} [DecidableEq n] [Fintype n]

open Finset

#print charmatrix /-
/-- The "characteristic matrix" of `M : matrix n n R` is the matrix of polynomials $t I - M$.
The determinant of this matrix is the characteristic polynomial.
-/
def charmatrix (M : Matrix n n R) : Matrix n n R[X] :=
  Matrix.scalar n (X : R[X]) - (C : R →+* R[X]).mapMatrix M
#align charmatrix charmatrix
-/

#print charmatrix_apply /-
theorem charmatrix_apply (M : Matrix n n R) (i j : n) :
    charmatrix M i j = X * (1 : Matrix n n R[X]) i j - C (M i j) :=
  rfl
#align charmatrix_apply charmatrix_apply
-/

#print charmatrix_apply_eq /-
@[simp]
theorem charmatrix_apply_eq (M : Matrix n n R) (i : n) :
    charmatrix M i i = (X : R[X]) - C (M i i) := by
  simp only [charmatrix, sub_left_inj, Pi.sub_apply, scalar_apply_eq, RingHom.mapMatrix_apply,
    map_apply, DMatrix.sub_apply]
#align charmatrix_apply_eq charmatrix_apply_eq
-/

#print charmatrix_apply_ne /-
@[simp]
theorem charmatrix_apply_ne (M : Matrix n n R) (i j : n) (h : i ≠ j) :
    charmatrix M i j = -C (M i j) := by
  simp only [charmatrix, Pi.sub_apply, scalar_apply_ne _ _ _ h, zero_sub, RingHom.mapMatrix_apply,
    map_apply, DMatrix.sub_apply]
#align charmatrix_apply_ne charmatrix_apply_ne
-/

#print matPolyEquiv_charmatrix /-
theorem matPolyEquiv_charmatrix (M : Matrix n n R) : matPolyEquiv (charmatrix M) = X - C M :=
  by
  ext k i j
  simp only [matPolyEquiv_coeff_apply, coeff_sub, Pi.sub_apply]
  by_cases h : i = j
  · subst h; rw [charmatrix_apply_eq, coeff_sub]
    simp only [coeff_X, coeff_C]
    split_ifs <;> simp
  · rw [charmatrix_apply_ne _ _ _ h, coeff_X, coeff_neg, coeff_C, coeff_C]
    split_ifs <;> simp [h]
#align mat_poly_equiv_charmatrix matPolyEquiv_charmatrix
-/

#print charmatrix_reindex /-
theorem charmatrix_reindex {m : Type v} [DecidableEq m] [Fintype m] (e : n ≃ m) (M : Matrix n n R) :
    charmatrix (reindex e e M) = reindex e e (charmatrix M) :=
  by
  ext i j x
  by_cases h : i = j
  all_goals simp [h]
#align charmatrix_reindex charmatrix_reindex
-/

#print Matrix.charpoly /-
/-- The characteristic polynomial of a matrix `M` is given by $\det (t I - M)$.
-/
def Matrix.charpoly (M : Matrix n n R) : R[X] :=
  (charmatrix M).det
#align matrix.charpoly Matrix.charpoly
-/

#print Matrix.charpoly_reindex /-
theorem Matrix.charpoly_reindex {m : Type v} [DecidableEq m] [Fintype m] (e : n ≃ m)
    (M : Matrix n n R) : (reindex e e M).charpoly = M.charpoly :=
  by
  unfold Matrix.charpoly
  rw [charmatrix_reindex, Matrix.det_reindex_self]
#align matrix.charpoly_reindex Matrix.charpoly_reindex
-/

#print Matrix.aeval_self_charpoly /-
-- This proof follows http://drorbn.net/AcademicPensieve/2015-12/CayleyHamilton.pdf
/-- The **Cayley-Hamilton Theorem**, that the characteristic polynomial of a matrix,
applied to the matrix itself, is zero.

This holds over any commutative ring.

See `linear_map.aeval_self_charpoly` for the equivalent statement about endomorphisms.
-/
theorem Matrix.aeval_self_charpoly (M : Matrix n n R) : aeval M M.charpoly = 0 :=
  by
  -- We begin with the fact $χ_M(t) I = adjugate (t I - M) * (t I - M)$,
  -- as an identity in `matrix n n R[X]`.
  have h : M.charpoly • (1 : Matrix n n R[X]) = adjugate (charmatrix M) * charmatrix M :=
    (adjugate_mul _).symm
  -- Using the algebra isomorphism `matrix n n R[X] ≃ₐ[R] polynomial (matrix n n R)`,
  -- we have the same identity in `polynomial (matrix n n R)`.
  apply_fun matPolyEquiv at h 
  simp only [mat_poly_equiv.map_mul, matPolyEquiv_charmatrix] at h 
  -- Because the coefficient ring `matrix n n R` is non-commutative,
  -- evaluation at `M` is not multiplicative.
  -- However, any polynomial which is a product of the form $N * (t I - M)$
  -- is sent to zero, because the evaluation function puts the polynomial variable
  -- to the right of any coefficients, so everything telescopes.
  apply_fun fun p => p.eval M at h 
  rw [eval_mul_X_sub_C] at h 
  -- Now $χ_M (t) I$, when thought of as a polynomial of matrices
  -- and evaluated at some `N` is exactly $χ_M (N)$.
  rw [matPolyEquiv_smul_one, eval_map] at h 
  -- Thus we have $χ_M(M) = 0$, which is the desired result.
  exact h
#align matrix.aeval_self_charpoly Matrix.aeval_self_charpoly
-/

