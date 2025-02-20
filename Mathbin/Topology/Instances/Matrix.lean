/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash, Eric Wieser

! This file was ported from Lean 3 source module topology.instances.matrix
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.InfiniteSum.Basic
import Mathbin.Topology.Algebra.Ring.Basic
import Mathbin.Topology.Algebra.Star
import Mathbin.LinearAlgebra.Matrix.NonsingularInverse
import Mathbin.LinearAlgebra.Matrix.Trace

/-!
# Topological properties of matrices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file is a place to collect topological results about matrices.

## Main definitions:

* `matrix.topological_ring`: square matrices form a topological ring

## Main results

* Continuity:
  * `continuous.matrix_det`: the determinant is continuous over a topological ring.
  * `continuous.matrix_adjugate`: the adjugate is continuous over a topological ring.
* Infinite sums
  * `matrix.transpose_tsum`: transpose commutes with infinite sums
  * `matrix.diagonal_tsum`: diagonal commutes with infinite sums
  * `matrix.block_diagonal_tsum`: block diagonal commutes with infinite sums
  * `matrix.block_diagonal'_tsum`: non-uniform block diagonal commutes with infinite sums
-/


open Matrix

open scoped Matrix

variable {X α l m n p S R : Type _} {m' n' : l → Type _}

instance [TopologicalSpace R] : TopologicalSpace (Matrix m n R) :=
  Pi.topologicalSpace

instance [TopologicalSpace R] [T2Space R] : T2Space (Matrix m n R) :=
  Pi.t2Space

/-! ### Lemmas about continuity of operations -/


section Continuity

variable [TopologicalSpace X] [TopologicalSpace R]

instance [SMul α R] [ContinuousConstSMul α R] : ContinuousConstSMul α (Matrix m n R) :=
  Pi.continuousConstSMul

instance [TopologicalSpace α] [SMul α R] [ContinuousSMul α R] : ContinuousSMul α (Matrix m n R) :=
  Pi.continuousSMul

instance [Add R] [ContinuousAdd R] : ContinuousAdd (Matrix m n R) :=
  Pi.continuousAdd

instance [Neg R] [ContinuousNeg R] : ContinuousNeg (Matrix m n R) :=
  Pi.continuousNeg

instance [AddGroup R] [TopologicalAddGroup R] : TopologicalAddGroup (Matrix m n R) :=
  Pi.topologicalAddGroup

#print continuous_matrix /-
/-- To show a function into matrices is continuous it suffices to show the coefficients of the
resulting matrix are continuous -/
@[continuity]
theorem continuous_matrix [TopologicalSpace α] {f : α → Matrix m n R}
    (h : ∀ i j, Continuous fun a => f a i j) : Continuous f :=
  continuous_pi fun _ => continuous_pi fun j => h _ _
#align continuous_matrix continuous_matrix
-/

#print Continuous.matrix_elem /-
theorem Continuous.matrix_elem {A : X → Matrix m n R} (hA : Continuous A) (i : m) (j : n) :
    Continuous fun x => A x i j :=
  (continuous_apply_apply i j).comp hA
#align continuous.matrix_elem Continuous.matrix_elem
-/

#print Continuous.matrix_map /-
@[continuity]
theorem Continuous.matrix_map [TopologicalSpace S] {A : X → Matrix m n S} {f : S → R}
    (hA : Continuous A) (hf : Continuous f) : Continuous fun x => (A x).map f :=
  continuous_matrix fun i j => hf.comp <| hA.matrix_elem _ _
#align continuous.matrix_map Continuous.matrix_map
-/

#print Continuous.matrix_transpose /-
@[continuity]
theorem Continuous.matrix_transpose {A : X → Matrix m n R} (hA : Continuous A) :
    Continuous fun x => (A x)ᵀ :=
  continuous_matrix fun i j => hA.matrix_elem j i
#align continuous.matrix_transpose Continuous.matrix_transpose
-/

#print Continuous.matrix_conjTranspose /-
theorem Continuous.matrix_conjTranspose [Star R] [ContinuousStar R] {A : X → Matrix m n R}
    (hA : Continuous A) : Continuous fun x => (A x)ᴴ :=
  hA.matrix_transpose.matrix_map continuous_star
#align continuous.matrix_conj_transpose Continuous.matrix_conjTranspose
-/

instance [Star R] [ContinuousStar R] : ContinuousStar (Matrix m m R) :=
  ⟨continuous_id.matrix_conjTranspose⟩

#print Continuous.matrix_col /-
@[continuity]
theorem Continuous.matrix_col {A : X → n → R} (hA : Continuous A) : Continuous fun x => col (A x) :=
  continuous_matrix fun i j => (continuous_apply _).comp hA
#align continuous.matrix_col Continuous.matrix_col
-/

#print Continuous.matrix_row /-
@[continuity]
theorem Continuous.matrix_row {A : X → n → R} (hA : Continuous A) : Continuous fun x => row (A x) :=
  continuous_matrix fun i j => (continuous_apply _).comp hA
#align continuous.matrix_row Continuous.matrix_row
-/

#print Continuous.matrix_diagonal /-
@[continuity]
theorem Continuous.matrix_diagonal [Zero R] [DecidableEq n] {A : X → n → R} (hA : Continuous A) :
    Continuous fun x => diagonal (A x) :=
  continuous_matrix fun i j => ((continuous_apply i).comp hA).if_const _ continuous_zero
#align continuous.matrix_diagonal Continuous.matrix_diagonal
-/

#print Continuous.matrix_dotProduct /-
@[continuity]
theorem Continuous.matrix_dotProduct [Fintype n] [Mul R] [AddCommMonoid R] [ContinuousAdd R]
    [ContinuousMul R] {A : X → n → R} {B : X → n → R} (hA : Continuous A) (hB : Continuous B) :
    Continuous fun x => dotProduct (A x) (B x) :=
  continuous_finset_sum _ fun i _ =>
    ((continuous_apply i).comp hA).mul ((continuous_apply i).comp hB)
#align continuous.matrix_dot_product Continuous.matrix_dotProduct
-/

#print Continuous.matrix_mul /-
/-- For square matrices the usual `continuous_mul` can be used. -/
@[continuity]
theorem Continuous.matrix_mul [Fintype n] [Mul R] [AddCommMonoid R] [ContinuousAdd R]
    [ContinuousMul R] {A : X → Matrix m n R} {B : X → Matrix n p R} (hA : Continuous A)
    (hB : Continuous B) : Continuous fun x => (A x).mul (B x) :=
  continuous_matrix fun i j =>
    continuous_finset_sum _ fun k _ => (hA.matrix_elem _ _).mul (hB.matrix_elem _ _)
#align continuous.matrix_mul Continuous.matrix_mul
-/

instance [Fintype n] [Mul R] [AddCommMonoid R] [ContinuousAdd R] [ContinuousMul R] :
    ContinuousMul (Matrix n n R) :=
  ⟨continuous_fst.matrixMul continuous_snd⟩

instance [Fintype n] [NonUnitalNonAssocSemiring R] [TopologicalSemiring R] :
    TopologicalSemiring (Matrix n n R) where

instance [Fintype n] [NonUnitalNonAssocRing R] [TopologicalRing R] : TopologicalRing (Matrix n n R)
    where

#print Continuous.matrix_vecMulVec /-
@[continuity]
theorem Continuous.matrix_vecMulVec [Mul R] [ContinuousMul R] {A : X → m → R} {B : X → n → R}
    (hA : Continuous A) (hB : Continuous B) : Continuous fun x => vecMulVec (A x) (B x) :=
  continuous_matrix fun i j => ((continuous_apply _).comp hA).mul ((continuous_apply _).comp hB)
#align continuous.matrix_vec_mul_vec Continuous.matrix_vecMulVec
-/

#print Continuous.matrix_mulVec /-
@[continuity]
theorem Continuous.matrix_mulVec [NonUnitalNonAssocSemiring R] [ContinuousAdd R] [ContinuousMul R]
    [Fintype n] {A : X → Matrix m n R} {B : X → n → R} (hA : Continuous A) (hB : Continuous B) :
    Continuous fun x => (A x).mulVec (B x) :=
  continuous_pi fun i => ((continuous_apply i).comp hA).matrix_dotProduct hB
#align continuous.matrix_mul_vec Continuous.matrix_mulVec
-/

#print Continuous.matrix_vecMul /-
@[continuity]
theorem Continuous.matrix_vecMul [NonUnitalNonAssocSemiring R] [ContinuousAdd R] [ContinuousMul R]
    [Fintype m] {A : X → m → R} {B : X → Matrix m n R} (hA : Continuous A) (hB : Continuous B) :
    Continuous fun x => vecMul (A x) (B x) :=
  continuous_pi fun i => hA.matrix_dotProduct <| continuous_pi fun j => hB.matrix_elem _ _
#align continuous.matrix_vec_mul Continuous.matrix_vecMul
-/

#print Continuous.matrix_submatrix /-
@[continuity]
theorem Continuous.matrix_submatrix {A : X → Matrix l n R} (hA : Continuous A) (e₁ : m → l)
    (e₂ : p → n) : Continuous fun x => (A x).submatrix e₁ e₂ :=
  continuous_matrix fun i j => hA.matrix_elem _ _
#align continuous.matrix_submatrix Continuous.matrix_submatrix
-/

#print Continuous.matrix_reindex /-
@[continuity]
theorem Continuous.matrix_reindex {A : X → Matrix l n R} (hA : Continuous A) (e₁ : l ≃ m)
    (e₂ : n ≃ p) : Continuous fun x => reindex e₁ e₂ (A x) :=
  hA.matrix_submatrix _ _
#align continuous.matrix_reindex Continuous.matrix_reindex
-/

#print Continuous.matrix_diag /-
@[continuity]
theorem Continuous.matrix_diag {A : X → Matrix n n R} (hA : Continuous A) :
    Continuous fun x => Matrix.diag (A x) :=
  continuous_pi fun _ => hA.matrix_elem _ _
#align continuous.matrix_diag Continuous.matrix_diag
-/

#print continuous_matrix_diag /-
-- note this doesn't elaborate well from the above
theorem continuous_matrix_diag : Continuous (Matrix.diag : Matrix n n R → n → R) :=
  show Continuous fun x : Matrix n n R => Matrix.diag x from continuous_id.matrix_diag
#align continuous_matrix_diag continuous_matrix_diag
-/

#print Continuous.matrix_trace /-
@[continuity]
theorem Continuous.matrix_trace [Fintype n] [AddCommMonoid R] [ContinuousAdd R]
    {A : X → Matrix n n R} (hA : Continuous A) : Continuous fun x => trace (A x) :=
  continuous_finset_sum _ fun i hi => hA.matrix_elem _ _
#align continuous.matrix_trace Continuous.matrix_trace
-/

#print Continuous.matrix_det /-
@[continuity]
theorem Continuous.matrix_det [Fintype n] [DecidableEq n] [CommRing R] [TopologicalRing R]
    {A : X → Matrix n n R} (hA : Continuous A) : Continuous fun x => (A x).det :=
  by
  simp_rw [Matrix.det_apply]
  refine' continuous_finset_sum _ fun l _ => Continuous.const_smul _ _
  refine' continuous_finset_prod _ fun l _ => hA.matrix_elem _ _
#align continuous.matrix_det Continuous.matrix_det
-/

#print Continuous.matrix_updateColumn /-
@[continuity]
theorem Continuous.matrix_updateColumn [DecidableEq n] (i : n) {A : X → Matrix m n R}
    {B : X → m → R} (hA : Continuous A) (hB : Continuous B) :
    Continuous fun x => (A x).updateColumn i (B x) :=
  continuous_matrix fun j k =>
    (continuous_apply k).comp <|
      ((continuous_apply _).comp hA).update i ((continuous_apply _).comp hB)
#align continuous.matrix_update_column Continuous.matrix_updateColumn
-/

#print Continuous.matrix_updateRow /-
@[continuity]
theorem Continuous.matrix_updateRow [DecidableEq m] (i : m) {A : X → Matrix m n R} {B : X → n → R}
    (hA : Continuous A) (hB : Continuous B) : Continuous fun x => (A x).updateRow i (B x) :=
  hA.update i hB
#align continuous.matrix_update_row Continuous.matrix_updateRow
-/

#print Continuous.matrix_cramer /-
@[continuity]
theorem Continuous.matrix_cramer [Fintype n] [DecidableEq n] [CommRing R] [TopologicalRing R]
    {A : X → Matrix n n R} {B : X → n → R} (hA : Continuous A) (hB : Continuous B) :
    Continuous fun x => (A x).cramer (B x) :=
  continuous_pi fun i => (hA.matrix_updateColumn _ hB).matrix_det
#align continuous.matrix_cramer Continuous.matrix_cramer
-/

#print Continuous.matrix_adjugate /-
@[continuity]
theorem Continuous.matrix_adjugate [Fintype n] [DecidableEq n] [CommRing R] [TopologicalRing R]
    {A : X → Matrix n n R} (hA : Continuous A) : Continuous fun x => (A x).adjugate :=
  continuous_matrix fun j k =>
    (hA.matrix_transpose.matrix_updateColumn k continuous_const).matrix_det
#align continuous.matrix_adjugate Continuous.matrix_adjugate
-/

#print continuousAt_matrix_inv /-
/-- When `ring.inverse` is continuous at the determinant (such as in a `normed_ring`, or a
`topological_field`), so is `matrix.has_inv`. -/
theorem continuousAt_matrix_inv [Fintype n] [DecidableEq n] [CommRing R] [TopologicalRing R]
    (A : Matrix n n R) (h : ContinuousAt Ring.inverse A.det) : ContinuousAt Inv.inv A :=
  (h.comp continuous_id.matrix_det.ContinuousAt).smul continuous_id.matrix_adjugate.ContinuousAt
#align continuous_at_matrix_inv continuousAt_matrix_inv
-/

-- lemmas about functions in `data/matrix/block.lean`
section BlockMatrices

#print Continuous.matrix_fromBlocks /-
@[continuity]
theorem Continuous.matrix_fromBlocks {A : X → Matrix n l R} {B : X → Matrix n m R}
    {C : X → Matrix p l R} {D : X → Matrix p m R} (hA : Continuous A) (hB : Continuous B)
    (hC : Continuous C) (hD : Continuous D) :
    Continuous fun x => Matrix.fromBlocks (A x) (B x) (C x) (D x) :=
  continuous_matrix fun i j => by
    cases i <;> cases j <;> refine' Continuous.matrix_elem _ i j <;> assumption
#align continuous.matrix_from_blocks Continuous.matrix_fromBlocks
-/

#print Continuous.matrix_blockDiagonal /-
@[continuity]
theorem Continuous.matrix_blockDiagonal [Zero R] [DecidableEq p] {A : X → p → Matrix m n R}
    (hA : Continuous A) : Continuous fun x => blockDiagonal (A x) :=
  continuous_matrix fun ⟨i₁, i₂⟩ ⟨j₁, j₂⟩ =>
    (((continuous_apply i₂).comp hA).matrix_elem i₁ j₁).if_const _ continuous_zero
#align continuous.matrix_block_diagonal Continuous.matrix_blockDiagonal
-/

#print Continuous.matrix_blockDiag /-
@[continuity]
theorem Continuous.matrix_blockDiag {A : X → Matrix (m × p) (n × p) R} (hA : Continuous A) :
    Continuous fun x => blockDiag (A x) :=
  continuous_pi fun i => continuous_matrix fun j k => hA.matrix_elem _ _
#align continuous.matrix_block_diag Continuous.matrix_blockDiag
-/

#print Continuous.matrix_blockDiagonal' /-
@[continuity]
theorem Continuous.matrix_blockDiagonal' [Zero R] [DecidableEq l]
    {A : X → ∀ i, Matrix (m' i) (n' i) R} (hA : Continuous A) :
    Continuous fun x => blockDiagonal' (A x) :=
  continuous_matrix fun ⟨i₁, i₂⟩ ⟨j₁, j₂⟩ =>
    by
    dsimp only [block_diagonal'_apply']
    split_ifs
    · subst h
      exact ((continuous_apply i₁).comp hA).matrix_elem i₂ j₂
    · exact continuous_const
#align continuous.matrix_block_diagonal' Continuous.matrix_blockDiagonal'
-/

#print Continuous.matrix_blockDiag' /-
@[continuity]
theorem Continuous.matrix_blockDiag' {A : X → Matrix (Σ i, m' i) (Σ i, n' i) R}
    (hA : Continuous A) : Continuous fun x => blockDiag' (A x) :=
  continuous_pi fun i => continuous_matrix fun j k => hA.matrix_elem _ _
#align continuous.matrix_block_diag' Continuous.matrix_blockDiag'
-/

end BlockMatrices

end Continuity

/-! ### Lemmas about infinite sums -/


section tsum

variable [Semiring α] [AddCommMonoid R] [TopologicalSpace R] [Module α R]

#print HasSum.matrix_transpose /-
theorem HasSum.matrix_transpose {f : X → Matrix m n R} {a : Matrix m n R} (hf : HasSum f a) :
    HasSum (fun x => (f x)ᵀ) aᵀ :=
  (hf.map (Matrix.transposeAddEquiv m n R) continuous_id.matrix_transpose : _)
#align has_sum.matrix_transpose HasSum.matrix_transpose
-/

#print Summable.matrix_transpose /-
theorem Summable.matrix_transpose {f : X → Matrix m n R} (hf : Summable f) :
    Summable fun x => (f x)ᵀ :=
  hf.HasSum.matrix_transpose.Summable
#align summable.matrix_transpose Summable.matrix_transpose
-/

#print summable_matrix_transpose /-
@[simp]
theorem summable_matrix_transpose {f : X → Matrix m n R} :
    (Summable fun x => (f x)ᵀ) ↔ Summable f :=
  (Summable.map_iff_of_equiv (Matrix.transposeAddEquiv m n R)
      (@continuous_id (Matrix m n R) _).matrix_transpose continuous_id.matrix_transpose :
    _)
#align summable_matrix_transpose summable_matrix_transpose
-/

#print Matrix.transpose_tsum /-
theorem Matrix.transpose_tsum [T2Space R] {f : X → Matrix m n R} : (∑' x, f x)ᵀ = ∑' x, (f x)ᵀ :=
  by
  by_cases hf : Summable f
  · exact hf.has_sum.matrix_transpose.tsum_eq.symm
  · have hft := summable_matrix_transpose.not.mpr hf
    rw [tsum_eq_zero_of_not_summable hf, tsum_eq_zero_of_not_summable hft, transpose_zero]
#align matrix.transpose_tsum Matrix.transpose_tsum
-/

#print HasSum.matrix_conjTranspose /-
theorem HasSum.matrix_conjTranspose [StarAddMonoid R] [ContinuousStar R] {f : X → Matrix m n R}
    {a : Matrix m n R} (hf : HasSum f a) : HasSum (fun x => (f x)ᴴ) aᴴ :=
  (hf.map (Matrix.conjTransposeAddEquiv m n R) continuous_id.matrix_conjTranspose : _)
#align has_sum.matrix_conj_transpose HasSum.matrix_conjTranspose
-/

#print Summable.matrix_conjTranspose /-
theorem Summable.matrix_conjTranspose [StarAddMonoid R] [ContinuousStar R] {f : X → Matrix m n R}
    (hf : Summable f) : Summable fun x => (f x)ᴴ :=
  hf.HasSum.matrix_conjTranspose.Summable
#align summable.matrix_conj_transpose Summable.matrix_conjTranspose
-/

#print summable_matrix_conjTranspose /-
@[simp]
theorem summable_matrix_conjTranspose [StarAddMonoid R] [ContinuousStar R] {f : X → Matrix m n R} :
    (Summable fun x => (f x)ᴴ) ↔ Summable f :=
  (Summable.map_iff_of_equiv (Matrix.conjTransposeAddEquiv m n R)
      (@continuous_id (Matrix m n R) _).matrix_conjTranspose continuous_id.matrix_conjTranspose :
    _)
#align summable_matrix_conj_transpose summable_matrix_conjTranspose
-/

#print Matrix.conjTranspose_tsum /-
theorem Matrix.conjTranspose_tsum [StarAddMonoid R] [ContinuousStar R] [T2Space R]
    {f : X → Matrix m n R} : (∑' x, f x)ᴴ = ∑' x, (f x)ᴴ :=
  by
  by_cases hf : Summable f
  · exact hf.has_sum.matrix_conj_transpose.tsum_eq.symm
  · have hft := summable_matrix_conj_transpose.not.mpr hf
    rw [tsum_eq_zero_of_not_summable hf, tsum_eq_zero_of_not_summable hft, conj_transpose_zero]
#align matrix.conj_transpose_tsum Matrix.conjTranspose_tsum
-/

#print HasSum.matrix_diagonal /-
theorem HasSum.matrix_diagonal [DecidableEq n] {f : X → n → R} {a : n → R} (hf : HasSum f a) :
    HasSum (fun x => diagonal (f x)) (diagonal a) :=
  (hf.map (diagonalAddMonoidHom n R) <| Continuous.matrix_diagonal <| continuous_id : _)
#align has_sum.matrix_diagonal HasSum.matrix_diagonal
-/

#print Summable.matrix_diagonal /-
theorem Summable.matrix_diagonal [DecidableEq n] {f : X → n → R} (hf : Summable f) :
    Summable fun x => diagonal (f x) :=
  hf.HasSum.matrix_diagonal.Summable
#align summable.matrix_diagonal Summable.matrix_diagonal
-/

#print summable_matrix_diagonal /-
@[simp]
theorem summable_matrix_diagonal [DecidableEq n] {f : X → n → R} :
    (Summable fun x => diagonal (f x)) ↔ Summable f :=
  (Summable.map_iff_of_leftInverse (@Matrix.diagonalAddMonoidHom n R _ _)
      (Matrix.diagAddMonoidHom n R) (Continuous.matrix_diagonal continuous_id)
      continuous_matrix_diag fun A => diag_diagonal A :
    _)
#align summable_matrix_diagonal summable_matrix_diagonal
-/

#print Matrix.diagonal_tsum /-
theorem Matrix.diagonal_tsum [DecidableEq n] [T2Space R] {f : X → n → R} :
    diagonal (∑' x, f x) = ∑' x, diagonal (f x) :=
  by
  by_cases hf : Summable f
  · exact hf.has_sum.matrix_diagonal.tsum_eq.symm
  · have hft := summable_matrix_diagonal.not.mpr hf
    rw [tsum_eq_zero_of_not_summable hf, tsum_eq_zero_of_not_summable hft]
    exact diagonal_zero
#align matrix.diagonal_tsum Matrix.diagonal_tsum
-/

#print HasSum.matrix_diag /-
theorem HasSum.matrix_diag {f : X → Matrix n n R} {a : Matrix n n R} (hf : HasSum f a) :
    HasSum (fun x => diag (f x)) (diag a) :=
  (hf.map (diagAddMonoidHom n R) continuous_matrix_diag : _)
#align has_sum.matrix_diag HasSum.matrix_diag
-/

#print Summable.matrix_diag /-
theorem Summable.matrix_diag {f : X → Matrix n n R} (hf : Summable f) :
    Summable fun x => diag (f x) :=
  hf.HasSum.matrix_diag.Summable
#align summable.matrix_diag Summable.matrix_diag
-/

section BlockMatrices

#print HasSum.matrix_blockDiagonal /-
theorem HasSum.matrix_blockDiagonal [DecidableEq p] {f : X → p → Matrix m n R}
    {a : p → Matrix m n R} (hf : HasSum f a) :
    HasSum (fun x => blockDiagonal (f x)) (blockDiagonal a) :=
  (hf.map (blockDiagonalAddMonoidHom m n p R) <| Continuous.matrix_blockDiagonal <| continuous_id :
    _)
#align has_sum.matrix_block_diagonal HasSum.matrix_blockDiagonal
-/

#print Summable.matrix_blockDiagonal /-
theorem Summable.matrix_blockDiagonal [DecidableEq p] {f : X → p → Matrix m n R} (hf : Summable f) :
    Summable fun x => blockDiagonal (f x) :=
  hf.HasSum.matrix_blockDiagonal.Summable
#align summable.matrix_block_diagonal Summable.matrix_blockDiagonal
-/

#print summable_matrix_blockDiagonal /-
theorem summable_matrix_blockDiagonal [DecidableEq p] {f : X → p → Matrix m n R} :
    (Summable fun x => blockDiagonal (f x)) ↔ Summable f :=
  (Summable.map_iff_of_leftInverse (Matrix.blockDiagonalAddMonoidHom m n p R)
      (Matrix.blockDiagAddMonoidHom m n p R) (Continuous.matrix_blockDiagonal continuous_id)
      (Continuous.matrix_blockDiag continuous_id) fun A => blockDiag_blockDiagonal A :
    _)
#align summable_matrix_block_diagonal summable_matrix_blockDiagonal
-/

#print Matrix.blockDiagonal_tsum /-
theorem Matrix.blockDiagonal_tsum [DecidableEq p] [T2Space R] {f : X → p → Matrix m n R} :
    blockDiagonal (∑' x, f x) = ∑' x, blockDiagonal (f x) :=
  by
  by_cases hf : Summable f
  · exact hf.has_sum.matrix_block_diagonal.tsum_eq.symm
  · have hft := summable_matrix_block_diagonal.not.mpr hf
    rw [tsum_eq_zero_of_not_summable hf, tsum_eq_zero_of_not_summable hft]
    exact block_diagonal_zero
#align matrix.block_diagonal_tsum Matrix.blockDiagonal_tsum
-/

#print HasSum.matrix_blockDiag /-
theorem HasSum.matrix_blockDiag {f : X → Matrix (m × p) (n × p) R} {a : Matrix (m × p) (n × p) R}
    (hf : HasSum f a) : HasSum (fun x => blockDiag (f x)) (blockDiag a) :=
  (hf.map (blockDiagAddMonoidHom m n p R) <| Continuous.matrix_blockDiag continuous_id : _)
#align has_sum.matrix_block_diag HasSum.matrix_blockDiag
-/

#print Summable.matrix_blockDiag /-
theorem Summable.matrix_blockDiag {f : X → Matrix (m × p) (n × p) R} (hf : Summable f) :
    Summable fun x => blockDiag (f x) :=
  hf.HasSum.matrix_blockDiag.Summable
#align summable.matrix_block_diag Summable.matrix_blockDiag
-/

#print HasSum.matrix_blockDiagonal' /-
theorem HasSum.matrix_blockDiagonal' [DecidableEq l] {f : X → ∀ i, Matrix (m' i) (n' i) R}
    {a : ∀ i, Matrix (m' i) (n' i) R} (hf : HasSum f a) :
    HasSum (fun x => blockDiagonal' (f x)) (blockDiagonal' a) :=
  (hf.map (blockDiagonal'AddMonoidHom m' n' R) <|
      Continuous.matrix_blockDiagonal' <| continuous_id :
    _)
#align has_sum.matrix_block_diagonal' HasSum.matrix_blockDiagonal'
-/

#print Summable.matrix_blockDiagonal' /-
theorem Summable.matrix_blockDiagonal' [DecidableEq l] {f : X → ∀ i, Matrix (m' i) (n' i) R}
    (hf : Summable f) : Summable fun x => blockDiagonal' (f x) :=
  hf.HasSum.matrix_blockDiagonal'.Summable
#align summable.matrix_block_diagonal' Summable.matrix_blockDiagonal'
-/

#print summable_matrix_blockDiagonal' /-
theorem summable_matrix_blockDiagonal' [DecidableEq l] {f : X → ∀ i, Matrix (m' i) (n' i) R} :
    (Summable fun x => blockDiagonal' (f x)) ↔ Summable f :=
  (Summable.map_iff_of_leftInverse (Matrix.blockDiagonal'AddMonoidHom m' n' R)
      (Matrix.blockDiag'AddMonoidHom m' n' R) (Continuous.matrix_blockDiagonal' continuous_id)
      (Continuous.matrix_blockDiag' continuous_id) fun A => blockDiag'_blockDiagonal' A :
    _)
#align summable_matrix_block_diagonal' summable_matrix_blockDiagonal'
-/

#print Matrix.blockDiagonal'_tsum /-
theorem Matrix.blockDiagonal'_tsum [DecidableEq l] [T2Space R]
    {f : X → ∀ i, Matrix (m' i) (n' i) R} :
    blockDiagonal' (∑' x, f x) = ∑' x, blockDiagonal' (f x) :=
  by
  by_cases hf : Summable f
  · exact hf.has_sum.matrix_block_diagonal'.tsum_eq.symm
  · have hft := summable_matrix_block_diagonal'.not.mpr hf
    rw [tsum_eq_zero_of_not_summable hf, tsum_eq_zero_of_not_summable hft]
    exact block_diagonal'_zero
#align matrix.block_diagonal'_tsum Matrix.blockDiagonal'_tsum
-/

#print HasSum.matrix_blockDiag' /-
theorem HasSum.matrix_blockDiag' {f : X → Matrix (Σ i, m' i) (Σ i, n' i) R}
    {a : Matrix (Σ i, m' i) (Σ i, n' i) R} (hf : HasSum f a) :
    HasSum (fun x => blockDiag' (f x)) (blockDiag' a) :=
  (hf.map (blockDiag'AddMonoidHom m' n' R) <| Continuous.matrix_blockDiag' continuous_id : _)
#align has_sum.matrix_block_diag' HasSum.matrix_blockDiag'
-/

#print Summable.matrix_blockDiag' /-
theorem Summable.matrix_blockDiag' {f : X → Matrix (Σ i, m' i) (Σ i, n' i) R} (hf : Summable f) :
    Summable fun x => blockDiag' (f x) :=
  hf.HasSum.matrix_blockDiag'.Summable
#align summable.matrix_block_diag' Summable.matrix_blockDiag'
-/

end BlockMatrices

end tsum

