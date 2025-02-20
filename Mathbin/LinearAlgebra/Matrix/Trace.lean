/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Patrick Massot, Casper Putz, Anne Baanen

! This file was ported from Lean 3 source module linear_algebra.matrix.trace
! leanprover-community/mathlib commit d64d67d000b974f0d86a2be7918cf800be6271c8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Matrix.Basic

/-!
# Trace of a matrix

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the trace of a matrix, the map sending a matrix to the sum of its diagonal
entries.

See also `linear_algebra.trace` for the trace of an endomorphism.

## Tags

matrix, trace, diagonal

-/


open scoped BigOperators Matrix

namespace Matrix

variable {ι m n p : Type _} {α R S : Type _}

variable [Fintype m] [Fintype n] [Fintype p]

section AddCommMonoid

variable [AddCommMonoid R]

#print Matrix.trace /-
/-- The trace of a square matrix. For more bundled versions, see:
* `matrix.trace_add_monoid_hom`
* `matrix.trace_linear_map`
-/
def trace (A : Matrix n n R) : R :=
  ∑ i, diag A i
#align matrix.trace Matrix.trace
-/

variable (n R)

#print Matrix.trace_zero /-
@[simp]
theorem trace_zero : trace (0 : Matrix n n R) = 0 :=
  (Finset.sum_const (0 : R)).trans <| smul_zero _
#align matrix.trace_zero Matrix.trace_zero
-/

variable {n R}

#print Matrix.trace_add /-
@[simp]
theorem trace_add (A B : Matrix n n R) : trace (A + B) = trace A + trace B :=
  Finset.sum_add_distrib
#align matrix.trace_add Matrix.trace_add
-/

#print Matrix.trace_smul /-
@[simp]
theorem trace_smul [Monoid α] [DistribMulAction α R] (r : α) (A : Matrix n n R) :
    trace (r • A) = r • trace A :=
  Finset.smul_sum.symm
#align matrix.trace_smul Matrix.trace_smul
-/

#print Matrix.trace_transpose /-
@[simp]
theorem trace_transpose (A : Matrix n n R) : trace Aᵀ = trace A :=
  rfl
#align matrix.trace_transpose Matrix.trace_transpose
-/

#print Matrix.trace_conjTranspose /-
@[simp]
theorem trace_conjTranspose [StarAddMonoid R] (A : Matrix n n R) : trace Aᴴ = star (trace A) :=
  (star_sum _ _).symm
#align matrix.trace_conj_transpose Matrix.trace_conjTranspose
-/

variable (n α R)

#print Matrix.traceAddMonoidHom /-
/-- `matrix.trace` as an `add_monoid_hom` -/
@[simps]
def traceAddMonoidHom : Matrix n n R →+ R
    where
  toFun := trace
  map_zero' := trace_zero n R
  map_add' := trace_add
#align matrix.trace_add_monoid_hom Matrix.traceAddMonoidHom
-/

#print Matrix.traceLinearMap /-
/-- `matrix.trace` as a `linear_map` -/
@[simps]
def traceLinearMap [Semiring α] [Module α R] : Matrix n n R →ₗ[α] R
    where
  toFun := trace
  map_add' := trace_add
  map_smul' := trace_smul
#align matrix.trace_linear_map Matrix.traceLinearMap
-/

variable {n α R}

#print Matrix.trace_list_sum /-
@[simp]
theorem trace_list_sum (l : List (Matrix n n R)) : trace l.Sum = (l.map trace).Sum :=
  map_list_sum (traceAddMonoidHom n R) l
#align matrix.trace_list_sum Matrix.trace_list_sum
-/

#print Matrix.trace_multiset_sum /-
@[simp]
theorem trace_multiset_sum (s : Multiset (Matrix n n R)) : trace s.Sum = (s.map trace).Sum :=
  map_multiset_sum (traceAddMonoidHom n R) s
#align matrix.trace_multiset_sum Matrix.trace_multiset_sum
-/

#print Matrix.trace_sum /-
@[simp]
theorem trace_sum (s : Finset ι) (f : ι → Matrix n n R) :
    trace (∑ i in s, f i) = ∑ i in s, trace (f i) :=
  map_sum (traceAddMonoidHom n R) f s
#align matrix.trace_sum Matrix.trace_sum
-/

end AddCommMonoid

section AddCommGroup

variable [AddCommGroup R]

#print Matrix.trace_sub /-
@[simp]
theorem trace_sub (A B : Matrix n n R) : trace (A - B) = trace A - trace B :=
  Finset.sum_sub_distrib
#align matrix.trace_sub Matrix.trace_sub
-/

#print Matrix.trace_neg /-
@[simp]
theorem trace_neg (A : Matrix n n R) : trace (-A) = -trace A :=
  Finset.sum_neg_distrib
#align matrix.trace_neg Matrix.trace_neg
-/

end AddCommGroup

section One

variable [DecidableEq n] [AddCommMonoidWithOne R]

#print Matrix.trace_one /-
@[simp]
theorem trace_one : trace (1 : Matrix n n R) = Fintype.card n := by
  simp_rw [trace, diag_one, Pi.one_def, Finset.sum_const, nsmul_one, Finset.card_univ]
#align matrix.trace_one Matrix.trace_one
-/

end One

section Mul

#print Matrix.trace_transpose_mul /-
@[simp]
theorem trace_transpose_mul [AddCommMonoid R] [Mul R] (A : Matrix m n R) (B : Matrix n m R) :
    trace (Aᵀ ⬝ Bᵀ) = trace (A ⬝ B) :=
  Finset.sum_comm
#align matrix.trace_transpose_mul Matrix.trace_transpose_mul
-/

#print Matrix.trace_mul_comm /-
theorem trace_mul_comm [AddCommMonoid R] [CommSemigroup R] (A : Matrix m n R) (B : Matrix n m R) :
    trace (A ⬝ B) = trace (B ⬝ A) := by rw [← trace_transpose, ← trace_transpose_mul, transpose_mul]
#align matrix.trace_mul_comm Matrix.trace_mul_comm
-/

#print Matrix.trace_mul_cycle /-
theorem trace_mul_cycle [NonUnitalCommSemiring R] (A : Matrix m n R) (B : Matrix n p R)
    (C : Matrix p m R) : trace (A ⬝ B ⬝ C) = trace (C ⬝ A ⬝ B) := by
  rw [trace_mul_comm, Matrix.mul_assoc]
#align matrix.trace_mul_cycle Matrix.trace_mul_cycle
-/

#print Matrix.trace_mul_cycle' /-
theorem trace_mul_cycle' [NonUnitalCommSemiring R] (A : Matrix m n R) (B : Matrix n p R)
    (C : Matrix p m R) : trace (A ⬝ (B ⬝ C)) = trace (C ⬝ (A ⬝ B)) := by
  rw [← Matrix.mul_assoc, trace_mul_comm]
#align matrix.trace_mul_cycle' Matrix.trace_mul_cycle'
-/

#print Matrix.trace_col_mul_row /-
@[simp]
theorem trace_col_mul_row [NonUnitalNonAssocSemiring R] (a b : n → R) :
    trace (col a ⬝ row b) = dotProduct a b := by simp [dot_product, trace]
#align matrix.trace_col_mul_row Matrix.trace_col_mul_row
-/

end Mul

section Fin

variable [AddCommMonoid R]

/-! ### Special cases for `fin n`

While `simp [fin.sum_univ_succ]` can prove these, we include them for convenience and consistency
with `matrix.det_fin_two` etc.
-/


#print Matrix.trace_fin_zero /-
@[simp]
theorem trace_fin_zero (A : Matrix (Fin 0) (Fin 0) R) : trace A = 0 :=
  rfl
#align matrix.trace_fin_zero Matrix.trace_fin_zero
-/

#print Matrix.trace_fin_one /-
theorem trace_fin_one (A : Matrix (Fin 1) (Fin 1) R) : trace A = A 0 0 :=
  add_zero _
#align matrix.trace_fin_one Matrix.trace_fin_one
-/

#print Matrix.trace_fin_two /-
theorem trace_fin_two (A : Matrix (Fin 2) (Fin 2) R) : trace A = A 0 0 + A 1 1 :=
  congr_arg ((· + ·) _) (add_zero (A 1 1))
#align matrix.trace_fin_two Matrix.trace_fin_two
-/

#print Matrix.trace_fin_three /-
theorem trace_fin_three (A : Matrix (Fin 3) (Fin 3) R) : trace A = A 0 0 + A 1 1 + A 2 2 := by
  rw [← add_zero (A 2 2), add_assoc]; rfl
#align matrix.trace_fin_three Matrix.trace_fin_three
-/

end Fin

end Matrix

