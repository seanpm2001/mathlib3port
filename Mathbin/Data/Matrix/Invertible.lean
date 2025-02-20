/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module data.matrix.invertible
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Invertible
import Mathbin.Data.Matrix.Basic

/-! # Extra lemmas about invertible matrices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Many of the `invertible` lemmas are about `*`; this restates them to be about `⬝`.

For lemmas about the matrix inverse in terms of the determinant and adjugate, see `matrix.has_inv`
in `linear_algebra/matrix/nonsingular_inverse.lean`.
-/


open scoped Matrix

variable {m n : Type _} {α : Type _}

variable [Fintype n] [DecidableEq n] [Semiring α]

namespace Matrix

#print Matrix.invOf_mul_self /-
/-- A copy of `inv_of_mul_self` using `⬝` not `*`. -/
protected theorem invOf_mul_self (A : Matrix n n α) [Invertible A] : ⅟ A ⬝ A = 1 :=
  invOf_mul_self A
#align matrix.inv_of_mul_self Matrix.invOf_mul_self
-/

#print Matrix.mul_invOf_self /-
/-- A copy of `mul_inv_of_self` using `⬝` not `*`. -/
protected theorem mul_invOf_self (A : Matrix n n α) [Invertible A] : A ⬝ ⅟ A = 1 :=
  mul_invOf_self A
#align matrix.mul_inv_of_self Matrix.mul_invOf_self
-/

#print Matrix.invOf_mul_self_assoc /-
/-- A copy of `inv_of_mul_self_assoc` using `⬝` not `*`. -/
protected theorem invOf_mul_self_assoc (A : Matrix n n α) (B : Matrix n m α) [Invertible A] :
    ⅟ A ⬝ (A ⬝ B) = B := by rw [← Matrix.mul_assoc, Matrix.invOf_mul_self, Matrix.one_mul]
#align matrix.inv_of_mul_self_assoc Matrix.invOf_mul_self_assoc
-/

#print Matrix.mul_invOf_self_assoc /-
/-- A copy of `mul_inv_of_self_assoc` using `⬝` not `*`. -/
protected theorem mul_invOf_self_assoc (A : Matrix n n α) (B : Matrix n m α) [Invertible A] :
    A ⬝ (⅟ A ⬝ B) = B := by rw [← Matrix.mul_assoc, Matrix.mul_invOf_self, Matrix.one_mul]
#align matrix.mul_inv_of_self_assoc Matrix.mul_invOf_self_assoc
-/

#print Matrix.mul_invOf_mul_self_cancel /-
/-- A copy of `mul_inv_of_mul_self_cancel` using `⬝` not `*`. -/
protected theorem mul_invOf_mul_self_cancel (A : Matrix m n α) (B : Matrix n n α) [Invertible B] :
    A ⬝ ⅟ B ⬝ B = A := by rw [Matrix.mul_assoc, Matrix.invOf_mul_self, Matrix.mul_one]
#align matrix.mul_inv_of_mul_self_cancel Matrix.mul_invOf_mul_self_cancel
-/

#print Matrix.mul_mul_invOf_self_cancel /-
/-- A copy of `mul_mul_inv_of_self_cancel` using `⬝` not `*`. -/
protected theorem mul_mul_invOf_self_cancel (A : Matrix m n α) (B : Matrix n n α) [Invertible B] :
    A ⬝ B ⬝ ⅟ B = A := by rw [Matrix.mul_assoc, Matrix.mul_invOf_self, Matrix.mul_one]
#align matrix.mul_mul_inv_of_self_cancel Matrix.mul_mul_invOf_self_cancel
-/

#print Matrix.invertibleMul /-
/-- A copy of `invertible_mul` using `⬝` not `*`. -/
@[reducible]
protected def invertibleMul (A B : Matrix n n α) [Invertible A] [Invertible B] :
    Invertible (A ⬝ B) :=
  { invertibleMul _ _ with invOf := ⅟ B ⬝ ⅟ A }
#align matrix.invertible_mul Matrix.invertibleMul
-/

#print Invertible.matrixMul /-
/-- A copy of `invertible.mul` using `⬝` not `*`.-/
@[reducible]
def Invertible.matrixMul {A B : Matrix n n α} (ha : Invertible A) (hb : Invertible B) :
    Invertible (A ⬝ B) :=
  invertibleMul _ _
#align invertible.matrix_mul Invertible.matrixMul
-/

#print Matrix.invOf_mul /-
protected theorem invOf_mul {A B : Matrix n n α} [Invertible A] [Invertible B]
    [Invertible (A ⬝ B)] : ⅟ (A ⬝ B) = ⅟ B ⬝ ⅟ A :=
  invOf_mul _ _
#align matrix.inv_of_mul Matrix.invOf_mul
-/

#print Matrix.invertibleOfInvertibleMul /-
/-- A copy of `invertible_of_invertible_mul` using `⬝` not `*`. -/
@[reducible]
protected def invertibleOfInvertibleMul (a b : Matrix n n α) [Invertible a] [Invertible (a ⬝ b)] :
    Invertible b :=
  { invertibleOfInvertibleMul a b with invOf := ⅟ (a ⬝ b) ⬝ a }
#align matrix.invertible_of_invertible_mul Matrix.invertibleOfInvertibleMul
-/

#print Matrix.invertibleOfMulInvertible /-
/-- A copy of `invertible_of_mul_invertible` using `⬝` not `*`. -/
@[reducible]
protected def invertibleOfMulInvertible (a b : Matrix n n α) [Invertible (a ⬝ b)] [Invertible b] :
    Invertible a :=
  { invertibleOfMulInvertible a b with invOf := b ⬝ ⅟ (a ⬝ b) }
#align matrix.invertible_of_mul_invertible Matrix.invertibleOfMulInvertible
-/

end Matrix

#print Invertible.matrixMulLeft /-
/-- A copy of `invertible.mul_left` using `⬝` not `*`. -/
@[reducible]
def Invertible.matrixMulLeft {a : Matrix n n α} (ha : Invertible a) (b : Matrix n n α) :
    Invertible b ≃ Invertible (a ⬝ b)
    where
  toFun hb := Matrix.invertibleMul a b
  invFun hab := Matrix.invertibleOfInvertibleMul a _
  left_inv hb := Subsingleton.elim _ _
  right_inv hab := Subsingleton.elim _ _
#align invertible.matrix_mul_left Invertible.matrixMulLeft
-/

#print Invertible.matrixMulRight /-
/-- A copy of `invertible.mul_right` using `⬝` not `*`. -/
@[reducible]
def Invertible.matrixMulRight (a : Matrix n n α) {b : Matrix n n α} (ha : Invertible b) :
    Invertible a ≃ Invertible (a ⬝ b)
    where
  toFun hb := Matrix.invertibleMul a b
  invFun hab := Matrix.invertibleOfMulInvertible _ b
  left_inv hb := Subsingleton.elim _ _
  right_inv hab := Subsingleton.elim _ _
#align invertible.matrix_mul_right Invertible.matrixMulRight
-/

