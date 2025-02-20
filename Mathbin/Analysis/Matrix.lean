/-
Copyright (c) 2021 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth, Eric Wieser

! This file was ported from Lean 3 source module analysis.matrix
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Analysis.NormedSpace.PiLp
import Mathbin.Analysis.InnerProductSpace.PiL2

/-!
# Matrices as a normed space

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we provide the following non-instances for norms on matrices:

* The elementwise norm:

  * `matrix.seminormed_add_comm_group`
  * `matrix.normed_add_comm_group`
  * `matrix.normed_space`

* The Frobenius norm:

  * `matrix.frobenius_seminormed_add_comm_group`
  * `matrix.frobenius_normed_add_comm_group`
  * `matrix.frobenius_normed_space`
  * `matrix.frobenius_normed_ring`
  * `matrix.frobenius_normed_algebra`

* The $L^\infty$ operator norm:

  * `matrix.linfty_op_seminormed_add_comm_group`
  * `matrix.linfty_op_normed_add_comm_group`
  * `matrix.linfty_op_normed_space`
  * `matrix.linfty_op_non_unital_semi_normed_ring`
  * `matrix.linfty_op_semi_normed_ring`
  * `matrix.linfty_op_non_unital_normed_ring`
  * `matrix.linfty_op_normed_ring`
  * `matrix.linfty_op_normed_algebra`

These are not declared as instances because there are several natural choices for defining the norm
of a matrix.
-/


noncomputable section

open scoped BigOperators NNReal Matrix

namespace Matrix

variable {R l m n α β : Type _} [Fintype l] [Fintype m] [Fintype n]

/-! ### The elementwise supremum norm -/


section LinfLinf

section SeminormedAddCommGroup

variable [SeminormedAddCommGroup α] [SeminormedAddCommGroup β]

#print Matrix.seminormedAddCommGroup /-
/-- Seminormed group instance (using sup norm of sup norm) for matrices over a seminormed group. Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
protected def seminormedAddCommGroup : SeminormedAddCommGroup (Matrix m n α) :=
  Pi.seminormedAddCommGroup
#align matrix.seminormed_add_comm_group Matrix.seminormedAddCommGroup
-/

attribute [local instance] Matrix.seminormedAddCommGroup

#print Matrix.norm_le_iff /-
theorem norm_le_iff {r : ℝ} (hr : 0 ≤ r) {A : Matrix m n α} : ‖A‖ ≤ r ↔ ∀ i j, ‖A i j‖ ≤ r := by
  simp [pi_norm_le_iff_of_nonneg hr]
#align matrix.norm_le_iff Matrix.norm_le_iff
-/

#print Matrix.nnnorm_le_iff /-
theorem nnnorm_le_iff {r : ℝ≥0} {A : Matrix m n α} : ‖A‖₊ ≤ r ↔ ∀ i j, ‖A i j‖₊ ≤ r := by
  simp [pi_nnnorm_le_iff]
#align matrix.nnnorm_le_iff Matrix.nnnorm_le_iff
-/

#print Matrix.norm_lt_iff /-
theorem norm_lt_iff {r : ℝ} (hr : 0 < r) {A : Matrix m n α} : ‖A‖ < r ↔ ∀ i j, ‖A i j‖ < r := by
  simp [pi_norm_lt_iff hr]
#align matrix.norm_lt_iff Matrix.norm_lt_iff
-/

#print Matrix.nnnorm_lt_iff /-
theorem nnnorm_lt_iff {r : ℝ≥0} (hr : 0 < r) {A : Matrix m n α} : ‖A‖₊ < r ↔ ∀ i j, ‖A i j‖₊ < r :=
  by simp [pi_nnnorm_lt_iff hr]
#align matrix.nnnorm_lt_iff Matrix.nnnorm_lt_iff
-/

#print Matrix.norm_entry_le_entrywise_sup_norm /-
theorem norm_entry_le_entrywise_sup_norm (A : Matrix m n α) {i : m} {j : n} : ‖A i j‖ ≤ ‖A‖ :=
  (norm_le_pi_norm (A i) j).trans (norm_le_pi_norm A i)
#align matrix.norm_entry_le_entrywise_sup_norm Matrix.norm_entry_le_entrywise_sup_norm
-/

#print Matrix.nnnorm_entry_le_entrywise_sup_nnnorm /-
theorem nnnorm_entry_le_entrywise_sup_nnnorm (A : Matrix m n α) {i : m} {j : n} : ‖A i j‖₊ ≤ ‖A‖₊ :=
  (nnnorm_le_pi_nnnorm (A i) j).trans (nnnorm_le_pi_nnnorm A i)
#align matrix.nnnorm_entry_le_entrywise_sup_nnnorm Matrix.nnnorm_entry_le_entrywise_sup_nnnorm
-/

#print Matrix.nnnorm_map_eq /-
@[simp]
theorem nnnorm_map_eq (A : Matrix m n α) (f : α → β) (hf : ∀ a, ‖f a‖₊ = ‖a‖₊) :
    ‖A.map f‖₊ = ‖A‖₊ := by simp_rw [Pi.nnnorm_def, Matrix.map_apply, hf]
#align matrix.nnnorm_map_eq Matrix.nnnorm_map_eq
-/

#print Matrix.norm_map_eq /-
@[simp]
theorem norm_map_eq (A : Matrix m n α) (f : α → β) (hf : ∀ a, ‖f a‖ = ‖a‖) : ‖A.map f‖ = ‖A‖ :=
  (congr_arg (coe : ℝ≥0 → ℝ) <| nnnorm_map_eq A f fun a => Subtype.ext <| hf a : _)
#align matrix.norm_map_eq Matrix.norm_map_eq
-/

#print Matrix.nnnorm_transpose /-
@[simp]
theorem nnnorm_transpose (A : Matrix m n α) : ‖Aᵀ‖₊ = ‖A‖₊ := by simp_rw [Pi.nnnorm_def];
  exact Finset.sup_comm _ _ _
#align matrix.nnnorm_transpose Matrix.nnnorm_transpose
-/

#print Matrix.norm_transpose /-
@[simp]
theorem norm_transpose (A : Matrix m n α) : ‖Aᵀ‖ = ‖A‖ :=
  congr_arg coe <| nnnorm_transpose A
#align matrix.norm_transpose Matrix.norm_transpose
-/

#print Matrix.nnnorm_conjTranspose /-
@[simp]
theorem nnnorm_conjTranspose [StarAddMonoid α] [NormedStarGroup α] (A : Matrix m n α) :
    ‖Aᴴ‖₊ = ‖A‖₊ :=
  (nnnorm_map_eq _ _ nnnorm_star).trans A.nnnorm_transpose
#align matrix.nnnorm_conj_transpose Matrix.nnnorm_conjTranspose
-/

#print Matrix.norm_conjTranspose /-
@[simp]
theorem norm_conjTranspose [StarAddMonoid α] [NormedStarGroup α] (A : Matrix m n α) : ‖Aᴴ‖ = ‖A‖ :=
  congr_arg coe <| nnnorm_conjTranspose A
#align matrix.norm_conj_transpose Matrix.norm_conjTranspose
-/

instance [StarAddMonoid α] [NormedStarGroup α] : NormedStarGroup (Matrix m m α) :=
  ⟨norm_conjTranspose⟩

#print Matrix.nnnorm_col /-
@[simp]
theorem nnnorm_col (v : m → α) : ‖col v‖₊ = ‖v‖₊ := by simp [Pi.nnnorm_def]
#align matrix.nnnorm_col Matrix.nnnorm_col
-/

#print Matrix.norm_col /-
@[simp]
theorem norm_col (v : m → α) : ‖col v‖ = ‖v‖ :=
  congr_arg coe <| nnnorm_col v
#align matrix.norm_col Matrix.norm_col
-/

#print Matrix.nnnorm_row /-
@[simp]
theorem nnnorm_row (v : n → α) : ‖row v‖₊ = ‖v‖₊ := by simp [Pi.nnnorm_def]
#align matrix.nnnorm_row Matrix.nnnorm_row
-/

#print Matrix.norm_row /-
@[simp]
theorem norm_row (v : n → α) : ‖row v‖ = ‖v‖ :=
  congr_arg coe <| nnnorm_row v
#align matrix.norm_row Matrix.norm_row
-/

#print Matrix.nnnorm_diagonal /-
@[simp]
theorem nnnorm_diagonal [DecidableEq n] (v : n → α) : ‖diagonal v‖₊ = ‖v‖₊ :=
  by
  simp_rw [Pi.nnnorm_def]
  congr 1 with i : 1
  refine' le_antisymm (Finset.sup_le fun j hj => _) _
  · obtain rfl | hij := eq_or_ne i j
    · rw [diagonal_apply_eq]
    · rw [diagonal_apply_ne _ hij, nnnorm_zero]
      exact zero_le _
  · refine' Eq.trans_le _ (Finset.le_sup (Finset.mem_univ i))
    rw [diagonal_apply_eq]
#align matrix.nnnorm_diagonal Matrix.nnnorm_diagonal
-/

#print Matrix.norm_diagonal /-
@[simp]
theorem norm_diagonal [DecidableEq n] (v : n → α) : ‖diagonal v‖ = ‖v‖ :=
  congr_arg coe <| nnnorm_diagonal v
#align matrix.norm_diagonal Matrix.norm_diagonal
-/

/-- Note this is safe as an instance as it carries no data. -/
@[nolint fails_quickly]
instance [Nonempty n] [DecidableEq n] [One α] [NormOneClass α] : NormOneClass (Matrix n n α) :=
  ⟨(norm_diagonal _).trans <| norm_one⟩

end SeminormedAddCommGroup

#print Matrix.normedAddCommGroup /-
/-- Normed group instance (using sup norm of sup norm) for matrices over a normed group.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
protected def normedAddCommGroup [NormedAddCommGroup α] : NormedAddCommGroup (Matrix m n α) :=
  Pi.normedAddCommGroup
#align matrix.normed_add_comm_group Matrix.normedAddCommGroup
-/

section NormedSpace

attribute [local instance] Matrix.seminormedAddCommGroup

variable [NormedField R] [SeminormedAddCommGroup α] [NormedSpace R α]

#print Matrix.normedSpace /-
/-- Normed space instance (using sup norm of sup norm) for matrices over a normed space.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
protected def normedSpace : NormedSpace R (Matrix m n α) :=
  Pi.normedSpace
#align matrix.normed_space Matrix.normedSpace
-/

end NormedSpace

end LinfLinf

/-! ### The $L_\infty$ operator norm

This section defines the matrix norm $\|A\|_\infty = \operatorname{sup}_i (\sum_j \|A_{ij}\|)$.

Note that this is equivalent to the operator norm, considering $A$ as a linear map between two
$L^\infty$ spaces.
-/


section LinftyOp

#print Matrix.linftyOpSeminormedAddCommGroup /-
/-- Seminormed group instance (using sup norm of L1 norm) for matrices over a seminormed group. Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
protected def linftyOpSeminormedAddCommGroup [SeminormedAddCommGroup α] :
    SeminormedAddCommGroup (Matrix m n α) :=
  (by infer_instance : SeminormedAddCommGroup (m → PiLp 1 fun j : n => α))
#align matrix.linfty_op_seminormed_add_comm_group Matrix.linftyOpSeminormedAddCommGroup
-/

#print Matrix.linftyOpNormedAddCommGroup /-
/-- Normed group instance (using sup norm of L1 norm) for matrices over a normed ring.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
protected def linftyOpNormedAddCommGroup [NormedAddCommGroup α] :
    NormedAddCommGroup (Matrix m n α) :=
  (by infer_instance : NormedAddCommGroup (m → PiLp 1 fun j : n => α))
#align matrix.linfty_op_normed_add_comm_group Matrix.linftyOpNormedAddCommGroup
-/

#print Matrix.linftyOpNormedSpace /-
/-- Normed space instance (using sup norm of L1 norm) for matrices over a normed space.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
protected def linftyOpNormedSpace [NormedField R] [SeminormedAddCommGroup α] [NormedSpace R α] :
    NormedSpace R (Matrix m n α) :=
  (by infer_instance : NormedSpace R (m → PiLp 1 fun j : n => α))
#align matrix.linfty_op_normed_space Matrix.linftyOpNormedSpace
-/

section SeminormedAddCommGroup

variable [SeminormedAddCommGroup α]

#print Matrix.linfty_op_norm_def /-
theorem linfty_op_norm_def (A : Matrix m n α) :
    ‖A‖ = ((Finset.univ : Finset m).sup fun i : m => ∑ j : n, ‖A i j‖₊ : ℝ≥0) := by
  simp [Pi.norm_def, PiLp.nnnorm_eq_sum ENNReal.one_ne_top]
#align matrix.linfty_op_norm_def Matrix.linfty_op_norm_def
-/

#print Matrix.linfty_op_nnnorm_def /-
theorem linfty_op_nnnorm_def (A : Matrix m n α) :
    ‖A‖₊ = (Finset.univ : Finset m).sup fun i : m => ∑ j : n, ‖A i j‖₊ :=
  Subtype.ext <| linfty_op_norm_def A
#align matrix.linfty_op_nnnorm_def Matrix.linfty_op_nnnorm_def
-/

#print Matrix.linfty_op_nnnorm_col /-
@[simp]
theorem linfty_op_nnnorm_col (v : m → α) : ‖col v‖₊ = ‖v‖₊ :=
  by
  rw [linfty_op_nnnorm_def, Pi.nnnorm_def]
  simp
#align matrix.linfty_op_nnnorm_col Matrix.linfty_op_nnnorm_col
-/

#print Matrix.linfty_op_norm_col /-
@[simp]
theorem linfty_op_norm_col (v : m → α) : ‖col v‖ = ‖v‖ :=
  congr_arg coe <| linfty_op_nnnorm_col v
#align matrix.linfty_op_norm_col Matrix.linfty_op_norm_col
-/

#print Matrix.linfty_op_nnnorm_row /-
@[simp]
theorem linfty_op_nnnorm_row (v : n → α) : ‖row v‖₊ = ∑ i, ‖v i‖₊ := by simp [linfty_op_nnnorm_def]
#align matrix.linfty_op_nnnorm_row Matrix.linfty_op_nnnorm_row
-/

#print Matrix.linfty_op_norm_row /-
@[simp]
theorem linfty_op_norm_row (v : n → α) : ‖row v‖ = ∑ i, ‖v i‖ :=
  (congr_arg coe <| linfty_op_nnnorm_row v).trans <| by simp [NNReal.coe_sum]
#align matrix.linfty_op_norm_row Matrix.linfty_op_norm_row
-/

#print Matrix.linfty_op_nnnorm_diagonal /-
@[simp]
theorem linfty_op_nnnorm_diagonal [DecidableEq m] (v : m → α) : ‖diagonal v‖₊ = ‖v‖₊ :=
  by
  rw [linfty_op_nnnorm_def, Pi.nnnorm_def]
  congr 1 with i : 1
  refine' (Finset.sum_eq_single_of_mem _ (Finset.mem_univ i) fun j hj hij => _).trans _
  · rw [diagonal_apply_ne' _ hij, nnnorm_zero]
  · rw [diagonal_apply_eq]
#align matrix.linfty_op_nnnorm_diagonal Matrix.linfty_op_nnnorm_diagonal
-/

#print Matrix.linfty_op_norm_diagonal /-
@[simp]
theorem linfty_op_norm_diagonal [DecidableEq m] (v : m → α) : ‖diagonal v‖ = ‖v‖ :=
  congr_arg coe <| linfty_op_nnnorm_diagonal v
#align matrix.linfty_op_norm_diagonal Matrix.linfty_op_norm_diagonal
-/

end SeminormedAddCommGroup

section NonUnitalSeminormedRing

variable [NonUnitalSeminormedRing α]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (k j) -/
#print Matrix.linfty_op_nnnorm_mul /-
theorem linfty_op_nnnorm_mul (A : Matrix l m α) (B : Matrix m n α) : ‖A ⬝ B‖₊ ≤ ‖A‖₊ * ‖B‖₊ :=
  by
  simp_rw [linfty_op_nnnorm_def, Matrix.mul_apply]
  calc
    (finset.univ.sup fun i => ∑ k, ‖∑ j, A i j * B j k‖₊) ≤
        finset.univ.sup fun i => ∑ (k) (j), ‖A i j‖₊ * ‖B j k‖₊ :=
      Finset.sup_mono_fun fun i hi =>
        Finset.sum_le_sum fun k hk => nnnorm_sum_le_of_le _ fun j hj => nnnorm_mul_le _ _
    _ = finset.univ.sup fun i => ∑ j, ‖A i j‖₊ * ∑ k, ‖B j k‖₊ := by
      simp_rw [@Finset.sum_comm _ m n, Finset.mul_sum]
    _ ≤ finset.univ.sup fun i => ∑ j, ‖A i j‖₊ * finset.univ.sup fun i => ∑ j, ‖B i j‖₊ :=
      (Finset.sup_mono_fun fun i hi =>
        Finset.sum_le_sum fun j hj => mul_le_mul_of_nonneg_left (Finset.le_sup hj) (zero_le _))
    _ ≤ (finset.univ.sup fun i => ∑ j, ‖A i j‖₊) * finset.univ.sup fun i => ∑ j, ‖B i j‖₊ := by
      simp_rw [← Finset.sum_mul, ← NNReal.finset_sup_mul]
#align matrix.linfty_op_nnnorm_mul Matrix.linfty_op_nnnorm_mul
-/

#print Matrix.linfty_op_norm_mul /-
theorem linfty_op_norm_mul (A : Matrix l m α) (B : Matrix m n α) : ‖A ⬝ B‖ ≤ ‖A‖ * ‖B‖ :=
  linfty_op_nnnorm_mul _ _
#align matrix.linfty_op_norm_mul Matrix.linfty_op_norm_mul
-/

#print Matrix.linfty_op_nnnorm_mulVec /-
theorem linfty_op_nnnorm_mulVec (A : Matrix l m α) (v : m → α) : ‖A.mulVec v‖₊ ≤ ‖A‖₊ * ‖v‖₊ :=
  by
  rw [← linfty_op_nnnorm_col (A.mul_vec v), ← linfty_op_nnnorm_col v]
  exact linfty_op_nnnorm_mul A (col v)
#align matrix.linfty_op_nnnorm_mul_vec Matrix.linfty_op_nnnorm_mulVec
-/

#print Matrix.linfty_op_norm_mulVec /-
theorem linfty_op_norm_mulVec (A : Matrix l m α) (v : m → α) : ‖Matrix.mulVec A v‖ ≤ ‖A‖ * ‖v‖ :=
  linfty_op_nnnorm_mulVec _ _
#align matrix.linfty_op_norm_mul_vec Matrix.linfty_op_norm_mulVec
-/

end NonUnitalSeminormedRing

#print Matrix.linftyOpNonUnitalSemiNormedRing /-
/-- Seminormed non-unital ring instance (using sup norm of L1 norm) for matrices over a semi normed
non-unital ring. Not declared as an instance because there are several natural choices for defining
the norm of a matrix. -/
@[local instance]
protected def linftyOpNonUnitalSemiNormedRing [NonUnitalSeminormedRing α] :
    NonUnitalSeminormedRing (Matrix n n α) :=
  { Matrix.linftyOpSeminormedAddCommGroup, Matrix.instNonUnitalRing with
    norm_mul := linfty_op_norm_mul }
#align matrix.linfty_op_non_unital_semi_normed_ring Matrix.linftyOpNonUnitalSemiNormedRing
-/

#print Matrix.linfty_op_normOneClass /-
/-- The `L₁-L∞` norm preserves one on non-empty matrices. Note this is safe as an instance, as it
carries no data. -/
instance linfty_op_normOneClass [SeminormedRing α] [NormOneClass α] [DecidableEq n] [Nonempty n] :
    NormOneClass (Matrix n n α) where norm_one := (linfty_op_norm_diagonal _).trans norm_one
#align matrix.linfty_op_norm_one_class Matrix.linfty_op_normOneClass
-/

#print Matrix.linftyOpSemiNormedRing /-
/-- Seminormed ring instance (using sup norm of L1 norm) for matrices over a semi normed ring.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
protected def linftyOpSemiNormedRing [SeminormedRing α] [DecidableEq n] :
    SeminormedRing (Matrix n n α) :=
  { Matrix.linftyOpNonUnitalSemiNormedRing, Matrix.instRing with }
#align matrix.linfty_op_semi_normed_ring Matrix.linftyOpSemiNormedRing
-/

#print Matrix.linftyOpNonUnitalNormedRing /-
/-- Normed non-unital ring instance (using sup norm of L1 norm) for matrices over a normed
non-unital ring. Not declared as an instance because there are several natural choices for defining
the norm of a matrix. -/
@[local instance]
protected def linftyOpNonUnitalNormedRing [NonUnitalNormedRing α] :
    NonUnitalNormedRing (Matrix n n α) :=
  { Matrix.linftyOpNonUnitalSemiNormedRing with }
#align matrix.linfty_op_non_unital_normed_ring Matrix.linftyOpNonUnitalNormedRing
-/

#print Matrix.linftyOpNormedRing /-
/-- Normed ring instance (using sup norm of L1 norm) for matrices over a normed ring.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
protected def linftyOpNormedRing [NormedRing α] [DecidableEq n] : NormedRing (Matrix n n α) :=
  { Matrix.linftyOpSemiNormedRing with }
#align matrix.linfty_op_normed_ring Matrix.linftyOpNormedRing
-/

#print Matrix.linftyOpNormedAlgebra /-
/-- Normed algebra instance (using sup norm of L1 norm) for matrices over a normed algebra. Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
protected def linftyOpNormedAlgebra [NormedField R] [SeminormedRing α] [NormedAlgebra R α]
    [DecidableEq n] : NormedAlgebra R (Matrix n n α) :=
  { Matrix.linftyOpNormedSpace with }
#align matrix.linfty_op_normed_algebra Matrix.linftyOpNormedAlgebra
-/

end LinftyOp

/-! ### The Frobenius norm

This is defined as $\|A\| = \sqrt{\sum_{i,j} \|A_{ij}\|^2}$.
When the matrix is over the real or complex numbers, this norm is submultiplicative.
-/


section frobenius

open scoped Matrix BigOperators

#print Matrix.frobeniusSeminormedAddCommGroup /-
/-- Seminormed group instance (using frobenius norm) for matrices over a seminormed group. Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
def frobeniusSeminormedAddCommGroup [SeminormedAddCommGroup α] :
    SeminormedAddCommGroup (Matrix m n α) :=
  (by infer_instance : SeminormedAddCommGroup (PiLp 2 fun i : m => PiLp 2 fun j : n => α))
#align matrix.frobenius_seminormed_add_comm_group Matrix.frobeniusSeminormedAddCommGroup
-/

#print Matrix.frobeniusNormedAddCommGroup /-
/-- Normed group instance (using frobenius norm) for matrices over a normed group.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
def frobeniusNormedAddCommGroup [NormedAddCommGroup α] : NormedAddCommGroup (Matrix m n α) :=
  (by infer_instance : NormedAddCommGroup (PiLp 2 fun i : m => PiLp 2 fun j : n => α))
#align matrix.frobenius_normed_add_comm_group Matrix.frobeniusNormedAddCommGroup
-/

#print Matrix.frobeniusNormedSpace /-
/-- Normed space instance (using frobenius norm) for matrices over a normed space.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
def frobeniusNormedSpace [NormedField R] [SeminormedAddCommGroup α] [NormedSpace R α] :
    NormedSpace R (Matrix m n α) :=
  (by infer_instance : NormedSpace R (PiLp 2 fun i : m => PiLp 2 fun j : n => α))
#align matrix.frobenius_normed_space Matrix.frobeniusNormedSpace
-/

section SeminormedAddCommGroup

variable [SeminormedAddCommGroup α] [SeminormedAddCommGroup β]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print Matrix.frobenius_nnnorm_def /-
theorem frobenius_nnnorm_def (A : Matrix m n α) :
    ‖A‖₊ = (∑ (i) (j), ‖A i j‖₊ ^ (2 : ℝ)) ^ (1 / 2 : ℝ) := by
  simp_rw [PiLp.nnnorm_eq_of_L2, NNReal.sq_sqrt, NNReal.sqrt_eq_rpow, NNReal.rpow_two]
#align matrix.frobenius_nnnorm_def Matrix.frobenius_nnnorm_def
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print Matrix.frobenius_norm_def /-
theorem frobenius_norm_def (A : Matrix m n α) :
    ‖A‖ = (∑ (i) (j), ‖A i j‖ ^ (2 : ℝ)) ^ (1 / 2 : ℝ) :=
  (congr_arg coe (frobenius_nnnorm_def A)).trans <| by simp [NNReal.coe_sum]
#align matrix.frobenius_norm_def Matrix.frobenius_norm_def
-/

#print Matrix.frobenius_nnnorm_map_eq /-
@[simp]
theorem frobenius_nnnorm_map_eq (A : Matrix m n α) (f : α → β) (hf : ∀ a, ‖f a‖₊ = ‖a‖₊) :
    ‖A.map f‖₊ = ‖A‖₊ := by simp_rw [frobenius_nnnorm_def, Matrix.map_apply, hf]
#align matrix.frobenius_nnnorm_map_eq Matrix.frobenius_nnnorm_map_eq
-/

#print Matrix.frobenius_norm_map_eq /-
@[simp]
theorem frobenius_norm_map_eq (A : Matrix m n α) (f : α → β) (hf : ∀ a, ‖f a‖ = ‖a‖) :
    ‖A.map f‖ = ‖A‖ :=
  (congr_arg (coe : ℝ≥0 → ℝ) <| frobenius_nnnorm_map_eq A f fun a => Subtype.ext <| hf a : _)
#align matrix.frobenius_norm_map_eq Matrix.frobenius_norm_map_eq
-/

#print Matrix.frobenius_nnnorm_transpose /-
@[simp]
theorem frobenius_nnnorm_transpose (A : Matrix m n α) : ‖Aᵀ‖₊ = ‖A‖₊ := by
  rw [frobenius_nnnorm_def, frobenius_nnnorm_def, Finset.sum_comm]; rfl
#align matrix.frobenius_nnnorm_transpose Matrix.frobenius_nnnorm_transpose
-/

#print Matrix.frobenius_norm_transpose /-
@[simp]
theorem frobenius_norm_transpose (A : Matrix m n α) : ‖Aᵀ‖ = ‖A‖ :=
  congr_arg coe <| frobenius_nnnorm_transpose A
#align matrix.frobenius_norm_transpose Matrix.frobenius_norm_transpose
-/

#print Matrix.frobenius_nnnorm_conjTranspose /-
@[simp]
theorem frobenius_nnnorm_conjTranspose [StarAddMonoid α] [NormedStarGroup α] (A : Matrix m n α) :
    ‖Aᴴ‖₊ = ‖A‖₊ :=
  (frobenius_nnnorm_map_eq _ _ nnnorm_star).trans A.frobenius_nnnorm_transpose
#align matrix.frobenius_nnnorm_conj_transpose Matrix.frobenius_nnnorm_conjTranspose
-/

#print Matrix.frobenius_norm_conjTranspose /-
@[simp]
theorem frobenius_norm_conjTranspose [StarAddMonoid α] [NormedStarGroup α] (A : Matrix m n α) :
    ‖Aᴴ‖ = ‖A‖ :=
  congr_arg coe <| frobenius_nnnorm_conjTranspose A
#align matrix.frobenius_norm_conj_transpose Matrix.frobenius_norm_conjTranspose
-/

#print Matrix.frobenius_normedStarGroup /-
instance frobenius_normedStarGroup [StarAddMonoid α] [NormedStarGroup α] :
    NormedStarGroup (Matrix m m α) :=
  ⟨frobenius_norm_conjTranspose⟩
#align matrix.frobenius_normed_star_group Matrix.frobenius_normedStarGroup
-/

#print Matrix.frobenius_norm_row /-
@[simp]
theorem frobenius_norm_row (v : m → α) : ‖row v‖ = ‖(PiLp.equiv 2 _).symm v‖ :=
  by
  rw [frobenius_norm_def, Fintype.sum_unique, PiLp.norm_eq_of_L2, Real.sqrt_eq_rpow]
  simp only [row_apply, Real.rpow_two, PiLp.equiv_symm_apply]
#align matrix.frobenius_norm_row Matrix.frobenius_norm_row
-/

#print Matrix.frobenius_nnnorm_row /-
@[simp]
theorem frobenius_nnnorm_row (v : m → α) : ‖row v‖₊ = ‖(PiLp.equiv 2 _).symm v‖₊ :=
  Subtype.ext <| frobenius_norm_row v
#align matrix.frobenius_nnnorm_row Matrix.frobenius_nnnorm_row
-/

#print Matrix.frobenius_norm_col /-
@[simp]
theorem frobenius_norm_col (v : n → α) : ‖col v‖ = ‖(PiLp.equiv 2 _).symm v‖ :=
  by
  simp_rw [frobenius_norm_def, Fintype.sum_unique, PiLp.norm_eq_of_L2, Real.sqrt_eq_rpow]
  simp only [col_apply, Real.rpow_two, PiLp.equiv_symm_apply]
#align matrix.frobenius_norm_col Matrix.frobenius_norm_col
-/

#print Matrix.frobenius_nnnorm_col /-
@[simp]
theorem frobenius_nnnorm_col (v : n → α) : ‖col v‖₊ = ‖(PiLp.equiv 2 _).symm v‖₊ :=
  Subtype.ext <| frobenius_norm_col v
#align matrix.frobenius_nnnorm_col Matrix.frobenius_nnnorm_col
-/

#print Matrix.frobenius_nnnorm_diagonal /-
@[simp]
theorem frobenius_nnnorm_diagonal [DecidableEq n] (v : n → α) :
    ‖diagonal v‖₊ = ‖(PiLp.equiv 2 _).symm v‖₊ :=
  by
  simp_rw [frobenius_nnnorm_def, ← Finset.sum_product', Finset.univ_product_univ,
    PiLp.nnnorm_eq_of_L2]
  let s := (Finset.univ : Finset n).map ⟨fun i : n => (i, i), fun i j h => congr_arg Prod.fst h⟩
  rw [← Finset.sum_subset (Finset.subset_univ s) fun i hi his => _]
  · rw [Finset.sum_map, NNReal.sqrt_eq_rpow]
    dsimp
    simp_rw [diagonal_apply_eq, NNReal.rpow_two]
  · suffices i.1 ≠ i.2 by rw [diagonal_apply_ne _ this, nnnorm_zero, NNReal.zero_rpow two_ne_zero]
    intro h
    exact finset.mem_map.not.mp his ⟨i.1, Finset.mem_univ _, Prod.ext rfl h⟩
#align matrix.frobenius_nnnorm_diagonal Matrix.frobenius_nnnorm_diagonal
-/

#print Matrix.frobenius_norm_diagonal /-
@[simp]
theorem frobenius_norm_diagonal [DecidableEq n] (v : n → α) :
    ‖diagonal v‖ = ‖(PiLp.equiv 2 _).symm v‖ :=
  (congr_arg coe <| frobenius_nnnorm_diagonal v : _).trans rfl
#align matrix.frobenius_norm_diagonal Matrix.frobenius_norm_diagonal
-/

end SeminormedAddCommGroup

#print Matrix.frobenius_nnnorm_one /-
theorem frobenius_nnnorm_one [DecidableEq n] [SeminormedAddCommGroup α] [One α] :
    ‖(1 : Matrix n n α)‖₊ = NNReal.sqrt (Fintype.card n) * ‖(1 : α)‖₊ :=
  by
  refine' (frobenius_nnnorm_diagonal _).trans _
  simp_rw [PiLp.nnnorm_equiv_symm_const ENNReal.two_ne_top, NNReal.sqrt_eq_rpow]
  simp only [ENNReal.toReal_div, ENNReal.one_toReal, ENNReal.toReal_bit0]
#align matrix.frobenius_nnnorm_one Matrix.frobenius_nnnorm_one
-/

section IsROrC

variable [IsROrC α]

#print Matrix.frobenius_nnnorm_mul /-
theorem frobenius_nnnorm_mul (A : Matrix l m α) (B : Matrix m n α) : ‖A ⬝ B‖₊ ≤ ‖A‖₊ * ‖B‖₊ :=
  by
  simp_rw [frobenius_nnnorm_def, Matrix.mul_apply]
  rw [← NNReal.mul_rpow, @Finset.sum_comm _ n m, Finset.sum_mul_sum, Finset.sum_product]
  refine' NNReal.rpow_le_rpow _ one_half_pos.le
  refine' Finset.sum_le_sum fun i hi => Finset.sum_le_sum fun j hj => _
  rw [← NNReal.rpow_le_rpow_iff one_half_pos, ← NNReal.rpow_mul,
    mul_div_cancel' (1 : ℝ) two_ne_zero, NNReal.rpow_one, NNReal.mul_rpow]
  dsimp only
  have :=
    @nnnorm_inner_le_nnnorm α _ _ _ _ ((PiLp.equiv 2 fun i => α).symm fun j => star (A i j))
      ((PiLp.equiv 2 fun i => α).symm fun k => B k j)
  simpa only [PiLp.equiv_symm_apply, PiLp.inner_apply, IsROrC.inner_apply, starRingEnd_apply,
    Pi.nnnorm_def, PiLp.nnnorm_eq_of_L2, star_star, nnnorm_star, NNReal.sqrt_eq_rpow,
    NNReal.rpow_two] using this
#align matrix.frobenius_nnnorm_mul Matrix.frobenius_nnnorm_mul
-/

#print Matrix.frobenius_norm_mul /-
theorem frobenius_norm_mul (A : Matrix l m α) (B : Matrix m n α) : ‖A ⬝ B‖ ≤ ‖A‖ * ‖B‖ :=
  frobenius_nnnorm_mul A B
#align matrix.frobenius_norm_mul Matrix.frobenius_norm_mul
-/

#print Matrix.frobeniusNormedRing /-
/-- Normed ring instance (using frobenius norm) for matrices over `ℝ` or `ℂ`.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
def frobeniusNormedRing [DecidableEq m] : NormedRing (Matrix m m α) :=
  {
    Matrix.frobeniusSeminormedAddCommGroup with
    norm := Norm.norm
    norm_mul := frobenius_norm_mul }
#align matrix.frobenius_normed_ring Matrix.frobeniusNormedRing
-/

#print Matrix.frobeniusNormedAlgebra /-
/-- Normed algebra instance (using frobenius norm) for matrices over `ℝ` or `ℂ`.  Not
declared as an instance because there are several natural choices for defining the norm of a
matrix. -/
@[local instance]
def frobeniusNormedAlgebra [DecidableEq m] [NormedField R] [NormedAlgebra R α] :
    NormedAlgebra R (Matrix m m α) :=
  { Matrix.frobeniusNormedSpace with }
#align matrix.frobenius_normed_algebra Matrix.frobeniusNormedAlgebra
-/

end IsROrC

end frobenius

end Matrix

