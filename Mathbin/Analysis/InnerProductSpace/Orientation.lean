/-
Copyright (c) 2022 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers, Heather Macbeth
-/
import Mathbin.Analysis.InnerProductSpace.GramSchmidtOrtho
import Mathbin.LinearAlgebra.Orientation

/-!
# Orientations of real inner product spaces.

This file provides definitions and proves lemmas about orientations of real inner product spaces.

## Main definitions

* `orthonormal_basis.adjust_to_orientation` takes an orthonormal basis and an orientation, and
  returns an orthonormal basis with that orientation: either the original orthonormal basis, or one
  constructed by negating a single (arbitrary) basis vector.
* `orientation.fin_orthonormal_basis` is an orthonormal basis, indexed by `fin n`, with the given
  orientation.
* `orientation.volume_form` is a nonvanishing top-dimensional alternating form on an oriented real
  inner product space, uniquely defined by compatibility with the orientation and inner product
  structure.

## Main theorems

* `orientation.volume_form_apply_le` states that the result of applying the volume form to a set of
  `n` vectors, where `n` is the dimension the inner product space, is bounded by the product of the
  lengths of the vectors.
* `orientation.abs_volume_form_apply_of_pairwise_orthogonal` states that the result of applying the
  volume form to a set of `n` orthogonal vectors, where `n` is the dimension the inner product
  space, is equal up to sign to the product of the lengths of the vectors.

-/


noncomputable section

variable {E : Type _} [InnerProductSpace ℝ E]

open FiniteDimensional

open BigOperators RealInnerProductSpace

namespace OrthonormalBasis

variable {ι : Type _} [Fintype ι] [DecidableEq ι] [ne : Nonempty ι] (e f : OrthonormalBasis ι ℝ E)
  (x : Orientation ℝ E ι)

/-- The change-of-basis matrix between two orthonormal bases with the same orientation has
determinant 1. -/
theorem det_to_matrix_orthonormal_basis_of_same_orientation (h : e.toBasis.Orientation = f.toBasis.Orientation) :
    e.toBasis.det f = 1 := by
  apply (e.det_to_matrix_orthonormal_basis_real f).resolve_right
  have : 0 < e.to_basis.det f := by
    rw [e.to_basis.orientation_eq_iff_det_pos] at h
    simpa using h
  linarith

/-- The change-of-basis matrix between two orthonormal bases with the opposite orientations has
determinant -1. -/
theorem det_to_matrix_orthonormal_basis_of_opposite_orientation (h : e.toBasis.Orientation ≠ f.toBasis.Orientation) :
    e.toBasis.det f = -1 := by
  contrapose! h
  simp [e.to_basis.orientation_eq_iff_det_pos, (e.det_to_matrix_orthonormal_basis_real f).resolve_right h]

variable {e f}

/-- Two orthonormal bases with the same orientation determine the same "determinant" top-dimensional
form on `E`, and conversely. -/
theorem same_orientation_iff_det_eq_det :
    e.toBasis.det = f.toBasis.det ↔ e.toBasis.Orientation = f.toBasis.Orientation := by
  constructor
  · intro h
    dsimp [Basis.orientation]
    congr
    
  · intro h
    rw [e.to_basis.det.eq_smul_basis_det f.to_basis]
    simp [e.det_to_matrix_orthonormal_basis_of_same_orientation f h]
    

variable (e f)

/-- Two orthonormal bases with opposite orientations determine opposite "determinant"
top-dimensional forms on `E`. -/
theorem det_eq_neg_det_of_opposite_orientation (h : e.toBasis.Orientation ≠ f.toBasis.Orientation) :
    e.toBasis.det = -f.toBasis.det := by
  rw [e.to_basis.det.eq_smul_basis_det f.to_basis]
  simp [e.det_to_matrix_orthonormal_basis_of_opposite_orientation f h]

section AdjustToOrientation

include ne

/-- `orthonormal_basis.adjust_to_orientation`, applied to an orthonormal basis, preserves the
property of orthonormality. -/
theorem orthonormalAdjustToOrientation : Orthonormal ℝ (e.toBasis.adjustToOrientation x) := by
  apply e.orthonormal.orthonormal_of_forall_eq_or_eq_neg
  simpa using e.to_basis.adjust_to_orientation_apply_eq_or_eq_neg x

/-- Given an orthonormal basis and an orientation, return an orthonormal basis giving that
orientation: either the original basis, or one constructed by negating a single (arbitrary) basis
vector. -/
def adjustToOrientation : OrthonormalBasis ι ℝ E :=
  (e.toBasis.adjustToOrientation x).toOrthonormalBasis (e.orthonormalAdjustToOrientation x)

theorem to_basis_adjust_to_orientation : (e.adjustToOrientation x).toBasis = e.toBasis.adjustToOrientation x :=
  (e.toBasis.adjustToOrientation x).to_basis_to_orthonormal_basis _

/-- `adjust_to_orientation` gives an orthonormal basis with the required orientation. -/
@[simp]
theorem orientation_adjust_to_orientation : (e.adjustToOrientation x).toBasis.Orientation = x := by
  rw [e.to_basis_adjust_to_orientation]
  exact e.to_basis.orientation_adjust_to_orientation x

/-- Every basis vector from `adjust_to_orientation` is either that from the original basis or its
negation. -/
theorem adjust_to_orientation_apply_eq_or_eq_neg (i : ι) :
    e.adjustToOrientation x i = e i ∨ e.adjustToOrientation x i = -e i := by
  simpa [← e.to_basis_adjust_to_orientation] using e.to_basis.adjust_to_orientation_apply_eq_or_eq_neg x i

theorem det_adjust_to_orientation :
    (e.adjustToOrientation x).toBasis.det = e.toBasis.det ∨ (e.adjustToOrientation x).toBasis.det = -e.toBasis.det := by
  simpa using e.to_basis.det_adjust_to_orientation x

theorem abs_det_adjust_to_orientation (v : ι → E) : |(e.adjustToOrientation x).toBasis.det v| = |e.toBasis.det v| := by
  simp [to_basis_adjust_to_orientation]

end AdjustToOrientation

end OrthonormalBasis

namespace Orientation

variable {n : ℕ}

open OrthonormalBasis

/-- An orthonormal basis, indexed by `fin n`, with the given orientation. -/
protected def finOrthonormalBasis (hn : 0 < n) (h : finrank ℝ E = n) (x : Orientation ℝ E (Fin n)) :
    OrthonormalBasis (Fin n) ℝ E := by
  haveI := Fin.pos_iff_nonempty.1 hn
  haveI := finite_dimensional_of_finrank (h.symm ▸ hn : 0 < finrank ℝ E)
  exact ((stdOrthonormalBasis _ _).reindex <| finCongr h).adjustToOrientation x

/-- `orientation.fin_orthonormal_basis` gives a basis with the required orientation. -/
@[simp]
theorem fin_orthonormal_basis_orientation (hn : 0 < n) (h : finrank ℝ E = n) (x : Orientation ℝ E (Fin n)) :
    (x.finOrthonormalBasis hn h).toBasis.Orientation = x := by
  haveI := Fin.pos_iff_nonempty.1 hn
  haveI := finite_dimensional_of_finrank (h.symm ▸ hn : 0 < finrank ℝ E)
  exact ((stdOrthonormalBasis _ _).reindex <| finCongr h).orientation_adjust_to_orientation x

section VolumeForm

variable [_i : Fact (finrank ℝ E = n)] (o : Orientation ℝ E (Fin n))

include _i o

/-- The volume form on an oriented real inner product space, a nonvanishing top-dimensional
alternating form uniquely defined by compatibility with the orientation and inner product structure.
-/
irreducible_def volumeForm : AlternatingMap ℝ E ℝ (Fin n) := by
  classical
  cases n
  · let opos : AlternatingMap ℝ E ℝ (Fin 0) := AlternatingMap.constOfIsEmpty ℝ E (1 : ℝ)
    exact o.eq_or_eq_neg_of_is_empty.by_cases (fun _ => opos) fun _ => -opos
    
  · exact (o.fin_orthonormal_basis n.succ_pos _i.out).toBasis.det
    

omit _i o

@[simp]
theorem volume_form_zero_pos [_i : Fact (finrank ℝ E = 0)] :
    Orientation.volumeForm (positiveOrientation : Orientation ℝ E (Fin 0)) =
      AlternatingMap.constLinearEquivOfIsEmpty 1 :=
  by simp [volume_form, Or.by_cases, if_pos]

theorem volume_form_zero_neg [_i : Fact (finrank ℝ E = 0)] :
    Orientation.volumeForm (-positive_orientation : Orientation ℝ E (Fin 0)) =
      -AlternatingMap.constLinearEquivOfIsEmpty 1 :=
  by
  dsimp [volume_form, Or.by_cases, positive_orientation]
  apply if_neg
  rw [ray_eq_iff, same_ray_comm]
  intro h
  simpa using congr_arg alternating_map.const_linear_equiv_of_is_empty.symm (eq_zero_of_same_ray_self_neg h)

include _i o

/-- The volume form on an oriented real inner product space can be evaluated as the determinant with
respect to any orthonormal basis of the space compatible with the orientation. -/
theorem volume_form_robust (b : OrthonormalBasis (Fin n) ℝ E) (hb : b.toBasis.Orientation = o) :
    o.volumeForm = b.toBasis.det := by
  cases n
  · have : o = positive_orientation := hb.symm.trans b.to_basis.orientation_is_empty
    simp [volume_form, Or.by_cases, dif_pos this]
    
  · dsimp [volume_form]
    rw [same_orientation_iff_det_eq_det, hb]
    exact o.fin_orthonormal_basis_orientation _ _
    

/-- The volume form on an oriented real inner product space can be evaluated as the determinant with
respect to any orthonormal basis of the space compatible with the orientation. -/
theorem volume_form_robust_neg (b : OrthonormalBasis (Fin n) ℝ E) (hb : b.toBasis.Orientation ≠ o) :
    o.volumeForm = -b.toBasis.det := by
  cases n
  · have : positive_orientation ≠ o := by rwa [b.to_basis.orientation_is_empty] at hb
    simp [volume_form, Or.by_cases, dif_neg this.symm]
    
  let e : OrthonormalBasis (Fin n.succ) ℝ E := o.fin_orthonormal_basis n.succ_pos (Fact.out _)
  dsimp [volume_form]
  apply e.det_eq_neg_det_of_opposite_orientation b
  convert hb.symm
  exact o.fin_orthonormal_basis_orientation _ _

@[simp]
theorem volume_form_neg_orientation : (-o).volumeForm = -o.volumeForm := by
  cases n
  · refine' o.eq_or_eq_neg_of_is_empty.by_cases _ _ <;> rintro rfl <;> simp [volume_form_zero_neg]
    
  let e : OrthonormalBasis (Fin n.succ) ℝ E := o.fin_orthonormal_basis n.succ_pos (Fact.out _)
  have h₁ : e.to_basis.orientation = o := o.fin_orthonormal_basis_orientation _ _
  have h₂ : e.to_basis.orientation ≠ -o := by
    symm
    rw [e.to_basis.orientation_ne_iff_eq_neg, h₁]
  rw [o.volume_form_robust e h₁, (-o).volume_form_robust_neg e h₂]

theorem volume_form_robust' (b : OrthonormalBasis (Fin n) ℝ E) (v : Fin n → E) : |o.volumeForm v| = |b.toBasis.det v| :=
  by
  cases n
  · refine' o.eq_or_eq_neg_of_is_empty.by_cases _ _ <;> rintro rfl <;> simp
    
  · rw [o.volume_form_robust (b.adjust_to_orientation o) (b.orientation_adjust_to_orientation o),
      b.abs_det_adjust_to_orientation]
    

/-- Let `v` be an indexed family of `n` vectors in an oriented `n`-dimensional real inner
product space `E`. The output of the volume form of `E` when evaluated on `v` is bounded in absolute
value by the product of the norms of the vectors `v i`. -/
theorem abs_volume_form_apply_le (v : Fin n → E) : |o.volumeForm v| ≤ ∏ i : Fin n, ∥v i∥ := by
  cases n
  · refine' o.eq_or_eq_neg_of_is_empty.by_cases _ _ <;> rintro rfl <;> simp
    
  haveI : FiniteDimensional ℝ E := fact_finite_dimensional_of_finrank_eq_succ n
  have : finrank ℝ E = Fintype.card (Fin n.succ) := by simpa using _i.out
  let b : OrthonormalBasis (Fin n.succ) ℝ E := gramSchmidtOrthonormalBasis this v
  have hb : b.to_basis.det v = ∏ i, ⟪b i, v i⟫ := gram_schmidt_orthonormal_basis_det this v
  rw [o.volume_form_robust' b, hb, Finset.abs_prod]
  apply Finset.prod_le_prod
  · intro i hi
    positivity
    
  intro i hi
  convert abs_real_inner_le_norm (b i) (v i)
  simp [b.orthonormal.1 i]

theorem volume_form_apply_le (v : Fin n → E) : o.volumeForm v ≤ ∏ i : Fin n, ∥v i∥ :=
  (le_abs_self _).trans (o.abs_volume_form_apply_le v)

/-- Let `v` be an indexed family of `n` orthogonal vectors in an oriented `n`-dimensional
real inner product space `E`. The output of the volume form of `E` when evaluated on `v` is, up to
sign, the product of the norms of the vectors `v i`. -/
theorem abs_volume_form_apply_of_pairwise_orthogonal {v : Fin n → E} (hv : Pairwise fun i j => ⟪v i, v j⟫ = 0) :
    |o.volumeForm v| = ∏ i : Fin n, ∥v i∥ := by
  cases n
  · refine' o.eq_or_eq_neg_of_is_empty.by_cases _ _ <;> rintro rfl <;> simp
    
  haveI : FiniteDimensional ℝ E := fact_finite_dimensional_of_finrank_eq_succ n
  have hdim : finrank ℝ E = Fintype.card (Fin n.succ) := by simpa using _i.out
  let b : OrthonormalBasis (Fin n.succ) ℝ E := gramSchmidtOrthonormalBasis hdim v
  have hb : b.to_basis.det v = ∏ i, ⟪b i, v i⟫ := gram_schmidt_orthonormal_basis_det hdim v
  rw [o.volume_form_robust' b, hb, Finset.abs_prod]
  by_cases h:∃ i, v i = 0
  obtain ⟨i, hi⟩ := h
  · rw [Finset.prod_eq_zero (Finset.mem_univ i), Finset.prod_eq_zero (Finset.mem_univ i)] <;> simp [hi]
    
  push_neg  at h
  congr
  ext i
  have hb : b i = ∥v i∥⁻¹ • v i := gram_schmidt_orthonormal_basis_apply_of_orthogonal hdim hv (h i)
  simp only [hb, inner_smul_left, real_inner_self_eq_norm_mul_norm, IsROrC.conj_to_real]
  rw [abs_of_nonneg]
  · have : ∥v i∥ ≠ 0 := by simpa using h i
    field_simp
    
  · positivity
    

/-- The output of the volume form of an oriented real inner product space `E` when evaluated on an
orthonormal basis is ±1. -/
theorem abs_volume_form_apply_of_orthonormal (v : OrthonormalBasis (Fin n) ℝ E) : |o.volumeForm v| = 1 := by
  simpa [o.volume_form_robust' v v] using congr_arg abs v.to_basis.det_self

theorem volume_form_map {F : Type _} [InnerProductSpace ℝ F] [Fact (finrank ℝ F = n)] (φ : E ≃ₗᵢ[ℝ] F) (x : Fin n → F) :
    (Orientation.map (Fin n) φ.toLinearEquiv o).volumeForm x = o.volumeForm (φ.symm ∘ x) := by
  cases n
  · refine' o.eq_or_eq_neg_of_is_empty.by_cases _ _ <;> rintro rfl <;> simp
    
  let e : OrthonormalBasis (Fin n.succ) ℝ E := o.fin_orthonormal_basis n.succ_pos (Fact.out _)
  have he : e.to_basis.orientation = o := o.fin_orthonormal_basis_orientation n.succ_pos (Fact.out _)
  have heφ : (e.map φ).toBasis.Orientation = Orientation.map (Fin n.succ) φ.to_linear_equiv o := by
    rw [← he]
    exact e.to_basis.orientation_map φ.to_linear_equiv
  rw [(Orientation.map (Fin n.succ) φ.to_linear_equiv o).volume_form_robust (e.map φ) heφ]
  rw [o.volume_form_robust e he]
  simp

/-- The volume form is invariant under pullback by a positively-oriented isometric automorphism. -/
theorem volume_form_comp_linear_isometry_equiv (φ : E ≃ₗᵢ[ℝ] E) (hφ : 0 < (φ.toLinearEquiv : E →ₗ[ℝ] E).det)
    (x : Fin n → E) : o.volumeForm (φ ∘ x) = o.volumeForm x := by
  convert o.volume_form_map φ (φ ∘ x)
  · symm
    rwa [← o.map_eq_iff_det_pos φ.to_linear_equiv] at hφ
    rw [_i.out, Fintype.card_fin]
    
  · ext
    simp
    

end VolumeForm

end Orientation

