/-
Copyright (c) 2022 Hans Parshall. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Hans Parshall

! This file was ported from Lean 3 source module analysis.normed_space.star.matrix
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Matrix
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Data.IsROrC.Basic
import Mathbin.LinearAlgebra.UnitaryGroup

/-!
# Unitary matrices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file collects facts about the unitary matrices over `𝕜` (either `ℝ` or `ℂ`).
-/


open scoped BigOperators Matrix

variable {𝕜 m n E : Type _}

section EntrywiseSupNorm

variable [IsROrC 𝕜] [Fintype n] [DecidableEq n]

#print entry_norm_bound_of_unitary /-
theorem entry_norm_bound_of_unitary {U : Matrix n n 𝕜} (hU : U ∈ Matrix.unitaryGroup n 𝕜)
    (i j : n) : ‖U i j‖ ≤ 1 :=
  by
  -- The norm squared of an entry is at most the L2 norm of its row.
  have norm_sum : ‖U i j‖ ^ 2 ≤ ∑ x, ‖U i x‖ ^ 2 :=
    by
    apply Multiset.single_le_sum
    · intro x h_x
      rw [Multiset.mem_map] at h_x 
      cases' h_x with a h_a
      rw [← h_a.2]
      apply sq_nonneg
    · rw [Multiset.mem_map]
      use j
      simp only [eq_self_iff_true, Finset.mem_univ_val, and_self_iff, sq_eq_sq]
  -- The L2 norm of a row is a diagonal entry of U ⬝ Uᴴ
  have diag_eq_norm_sum : (U ⬝ Uᴴ) i i = ∑ x : n, ‖U i x‖ ^ 2 := by
    simp only [Matrix.mul_apply, Matrix.conjTranspose_apply, ← starRingEnd_apply, IsROrC.mul_conj,
      IsROrC.normSq_eq_def', IsROrC.ofReal_pow]
  -- The L2 norm of a row is a diagonal entry of U ⬝ Uᴴ, real part
  have re_diag_eq_norm_sum : IsROrC.re ((U ⬝ Uᴴ) i i) = ∑ x : n, ‖U i x‖ ^ 2 :=
    by
    rw [IsROrC.ext_iff] at diag_eq_norm_sum 
    rw [diag_eq_norm_sum.1]
    norm_cast
  -- Since U is unitary, the diagonal entries of U ⬝ Uᴴ are all 1
  have mul_eq_one : U ⬝ Uᴴ = 1 := unitary.mul_star_self_of_mem hU
  have diag_eq_one : IsROrC.re ((U ⬝ Uᴴ) i i) = 1 := by
    simp only [mul_eq_one, eq_self_iff_true, Matrix.one_apply_eq, IsROrC.one_re]
  -- Putting it all together
  rw [← sq_le_one_iff (norm_nonneg (U i j)), ← diag_eq_one, re_diag_eq_norm_sum]
  exact norm_sum
#align entry_norm_bound_of_unitary entry_norm_bound_of_unitary
-/

attribute [local instance] Matrix.normedAddCommGroup

#print entrywise_sup_norm_bound_of_unitary /-
/-- The entrywise sup norm of a unitary matrix is at most 1. -/
theorem entrywise_sup_norm_bound_of_unitary {U : Matrix n n 𝕜} (hU : U ∈ Matrix.unitaryGroup n 𝕜) :
    ‖U‖ ≤ 1 := by
  simp_rw [pi_norm_le_iff_of_nonneg zero_le_one]
  intro i j
  exact entry_norm_bound_of_unitary hU _ _
#align entrywise_sup_norm_bound_of_unitary entrywise_sup_norm_bound_of_unitary
-/

end EntrywiseSupNorm

