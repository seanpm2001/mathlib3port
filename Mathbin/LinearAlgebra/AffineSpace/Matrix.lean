/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module linear_algebra.affine_space.matrix
! leanprover-community/mathlib commit fe8d0ff42c3c24d789f491dc2622b6cac3d61564
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.AffineSpace.Basis
import Mathbin.LinearAlgebra.Determinant

/-!
# Matrix results for barycentric co-ordinates

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Results about the matrix of barycentric co-ordinates for a family of points in an affine space, with
respect to some affine basis.
-/


open scoped Affine BigOperators Matrix

open Set

universe u₁ u₂ u₃ u₄

variable {ι : Type u₁} {k : Type u₂} {V : Type u₃} {P : Type u₄}

variable [AddCommGroup V] [affine_space V P]

namespace AffineBasis

section Ring

variable [Ring k] [Module k V] (b : AffineBasis ι k P)

#print AffineBasis.toMatrix /-
/-- Given an affine basis `p`, and a family of points `q : ι' → P`, this is the matrix whose
rows are the barycentric coordinates of `q` with respect to `p`.

It is an affine equivalent of `basis.to_matrix`. -/
noncomputable def toMatrix {ι' : Type _} (q : ι' → P) : Matrix ι' ι k := fun i j => b.Coord j (q i)
#align affine_basis.to_matrix AffineBasis.toMatrix
-/

#print AffineBasis.toMatrix_apply /-
@[simp]
theorem toMatrix_apply {ι' : Type _} (q : ι' → P) (i : ι') (j : ι) :
    b.toMatrix q i j = b.Coord j (q i) :=
  rfl
#align affine_basis.to_matrix_apply AffineBasis.toMatrix_apply
-/

#print AffineBasis.toMatrix_self /-
@[simp]
theorem toMatrix_self [DecidableEq ι] : b.toMatrix b = (1 : Matrix ι ι k) :=
  by
  ext i j
  rw [to_matrix_apply, coord_apply, Matrix.one_eq_pi_single, Pi.single_apply]
#align affine_basis.to_matrix_self AffineBasis.toMatrix_self
-/

variable {ι' : Type _} [Fintype ι'] [Fintype ι] (b₂ : AffineBasis ι k P)

#print AffineBasis.toMatrix_row_sum_one /-
theorem toMatrix_row_sum_one {ι' : Type _} (q : ι' → P) (i : ι') : ∑ j, b.toMatrix q i j = 1 := by
  simp
#align affine_basis.to_matrix_row_sum_one AffineBasis.toMatrix_row_sum_one
-/

#print AffineBasis.affineIndependent_of_toMatrix_right_inv /-
/-- Given a family of points `p : ι' → P` and an affine basis `b`, if the matrix whose rows are the
coordinates of `p` with respect `b` has a right inverse, then `p` is affine independent. -/
theorem affineIndependent_of_toMatrix_right_inv [DecidableEq ι'] (p : ι' → P) {A : Matrix ι ι' k}
    (hA : b.toMatrix p ⬝ A = 1) : AffineIndependent k p :=
  by
  rw [affineIndependent_iff_eq_of_fintype_affineCombination_eq]
  intro w₁ w₂ hw₁ hw₂ hweq
  have hweq' : (b.to_matrix p).vecMul w₁ = (b.to_matrix p).vecMul w₂ :=
    by
    ext j
    change ∑ i, w₁ i • b.coord j (p i) = ∑ i, w₂ i • b.coord j (p i)
    rw [← finset.univ.affine_combination_eq_linear_combination _ _ hw₁, ←
      finset.univ.affine_combination_eq_linear_combination _ _ hw₂, ←
      finset.univ.map_affine_combination p w₁ hw₁, ← finset.univ.map_affine_combination p w₂ hw₂,
      hweq]
  replace hweq' := congr_arg (fun w => A.vec_mul w) hweq'
  simpa only [Matrix.vecMul_vecMul, ← Matrix.mul_eq_mul, hA, Matrix.vecMul_one] using hweq'
#align affine_basis.affine_independent_of_to_matrix_right_inv AffineBasis.affineIndependent_of_toMatrix_right_inv
-/

#print AffineBasis.affineSpan_eq_top_of_toMatrix_left_inv /-
/-- Given a family of points `p : ι' → P` and an affine basis `b`, if the matrix whose rows are the
coordinates of `p` with respect `b` has a left inverse, then `p` spans the entire space. -/
theorem affineSpan_eq_top_of_toMatrix_left_inv [DecidableEq ι] [Nontrivial k] (p : ι' → P)
    {A : Matrix ι ι' k} (hA : A ⬝ b.toMatrix p = 1) : affineSpan k (range p) = ⊤ :=
  by
  suffices ∀ i, b i ∈ affineSpan k (range p)
    by
    rw [eq_top_iff, ← b.tot, affineSpan_le]
    rintro q ⟨i, rfl⟩
    exact this i
  intro i
  have hAi : ∑ j, A i j = 1 := by
    calc
      ∑ j, A i j = ∑ j, A i j * ∑ l, b.to_matrix p j l := by simp
      _ = ∑ j, ∑ l, A i j * b.to_matrix p j l := by simp_rw [Finset.mul_sum]
      _ = ∑ l, ∑ j, A i j * b.to_matrix p j l := by rw [Finset.sum_comm]
      _ = ∑ l, (A ⬝ b.to_matrix p) i l := rfl
      _ = 1 := by simp [hA, Matrix.one_apply, Finset.filter_eq]
  have hbi : b i = finset.univ.affine_combination k p (A i) :=
    by
    apply b.ext_elem
    intro j
    rw [b.coord_apply, finset.univ.map_affine_combination _ _ hAi,
      finset.univ.affine_combination_eq_linear_combination _ _ hAi]
    change _ = (A ⬝ b.to_matrix p) i j
    simp_rw [hA, Matrix.one_apply, @eq_comm _ i j]
  rw [hbi]
  exact affineCombination_mem_affineSpan hAi p
#align affine_basis.affine_span_eq_top_of_to_matrix_left_inv AffineBasis.affineSpan_eq_top_of_toMatrix_left_inv
-/

#print AffineBasis.toMatrix_vecMul_coords /-
/-- A change of basis formula for barycentric coordinates.

See also `affine_basis.to_matrix_inv_mul_affine_basis_to_matrix`. -/
@[simp]
theorem toMatrix_vecMul_coords (x : P) : (b.toMatrix b₂).vecMul (b₂.coords x) = b.coords x :=
  by
  ext j
  change _ = b.coord j x
  conv_rhs => rw [← b₂.affine_combination_coord_eq_self x]
  rw [Finset.map_affineCombination _ _ _ (b₂.sum_coord_apply_eq_one x)]
  simp [Matrix.vecMul, Matrix.dotProduct, to_matrix_apply, coords]
#align affine_basis.to_matrix_vec_mul_coords AffineBasis.toMatrix_vecMul_coords
-/

variable [DecidableEq ι]

#print AffineBasis.toMatrix_mul_toMatrix /-
theorem toMatrix_mul_toMatrix : b.toMatrix b₂ ⬝ b₂.toMatrix b = 1 :=
  by
  ext l m
  change (b₂.to_matrix b).vecMul (b.coords (b₂ l)) m = _
  rw [to_matrix_vec_mul_coords, coords_apply, ← to_matrix_apply, to_matrix_self]
#align affine_basis.to_matrix_mul_to_matrix AffineBasis.toMatrix_mul_toMatrix
-/

#print AffineBasis.isUnit_toMatrix /-
theorem isUnit_toMatrix : IsUnit (b.toMatrix b₂) :=
  ⟨{  val := b.toMatrix b₂
      inv := b₂.toMatrix b
      val_inv := b.toMatrix_mul_toMatrix b₂
      inv_val := b₂.toMatrix_mul_toMatrix b }, rfl⟩
#align affine_basis.is_unit_to_matrix AffineBasis.isUnit_toMatrix
-/

#print AffineBasis.isUnit_toMatrix_iff /-
theorem isUnit_toMatrix_iff [Nontrivial k] (p : ι → P) :
    IsUnit (b.toMatrix p) ↔ AffineIndependent k p ∧ affineSpan k (range p) = ⊤ :=
  by
  constructor
  · rintro ⟨⟨B, A, hA, hA'⟩, rfl : B = b.to_matrix p⟩
    rw [Matrix.mul_eq_mul] at hA hA' 
    exact
      ⟨b.affine_independent_of_to_matrix_right_inv p hA,
        b.affine_span_eq_top_of_to_matrix_left_inv p hA'⟩
  · rintro ⟨h_tot, h_ind⟩
    let b' : AffineBasis ι k P := ⟨p, h_tot, h_ind⟩
    change IsUnit (b.to_matrix b')
    exact b.is_unit_to_matrix b'
#align affine_basis.is_unit_to_matrix_iff AffineBasis.isUnit_toMatrix_iff
-/

end Ring

section CommRing

variable [CommRing k] [Module k V] [DecidableEq ι] [Fintype ι]

variable (b b₂ : AffineBasis ι k P)

#print AffineBasis.toMatrix_inv_vecMul_toMatrix /-
/-- A change of basis formula for barycentric coordinates.

See also `affine_basis.to_matrix_vec_mul_coords`. -/
@[simp]
theorem toMatrix_inv_vecMul_toMatrix (x : P) :
    (b.toMatrix b₂)⁻¹.vecMul (b.coords x) = b₂.coords x :=
  by
  have hu := b.is_unit_to_matrix b₂
  rw [Matrix.isUnit_iff_isUnit_det] at hu 
  rw [← b.to_matrix_vec_mul_coords b₂, Matrix.vecMul_vecMul, Matrix.mul_nonsing_inv _ hu,
    Matrix.vecMul_one]
#align affine_basis.to_matrix_inv_vec_mul_to_matrix AffineBasis.toMatrix_inv_vecMul_toMatrix
-/

#print AffineBasis.det_smul_coords_eq_cramer_coords /-
/-- If we fix a background affine basis `b`, then for any other basis `b₂`, we can characterise
the barycentric coordinates provided by `b₂` in terms of determinants relative to `b`. -/
theorem det_smul_coords_eq_cramer_coords (x : P) :
    (b.toMatrix b₂).det • b₂.coords x = (b.toMatrix b₂)ᵀ.cramer (b.coords x) :=
  by
  have hu := b.is_unit_to_matrix b₂
  rw [Matrix.isUnit_iff_isUnit_det] at hu 
  rw [← b.to_matrix_inv_vec_mul_to_matrix, Matrix.det_smul_inv_vecMul_eq_cramer_transpose _ _ hu]
#align affine_basis.det_smul_coords_eq_cramer_coords AffineBasis.det_smul_coords_eq_cramer_coords
-/

end CommRing

end AffineBasis

