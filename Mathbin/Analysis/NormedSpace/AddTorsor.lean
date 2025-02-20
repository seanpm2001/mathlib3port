/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.normed_space.add_torsor
! leanprover-community/mathlib commit 837f72de63ad6cd96519cde5f1ffd5ed8d280ad0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Analysis.Normed.Group.AddTorsor
import Mathbin.LinearAlgebra.AffineSpace.MidpointZero
import Mathbin.LinearAlgebra.AffineSpace.AffineSubspace
import Mathbin.Topology.Instances.RealVectorSpace

/-!
# Torsors of normed space actions.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains lemmas about normed additive torsors over normed spaces.
-/


noncomputable section

open scoped NNReal Topology

open Filter

variable {α V P W Q : Type _} [SeminormedAddCommGroup V] [PseudoMetricSpace P] [NormedAddTorsor V P]
  [NormedAddCommGroup W] [MetricSpace Q] [NormedAddTorsor W Q]

section NormedSpace

variable {𝕜 : Type _} [NormedField 𝕜] [NormedSpace 𝕜 V] [NormedSpace 𝕜 W]

open AffineMap

#print AffineSubspace.isClosed_direction_iff /-
theorem AffineSubspace.isClosed_direction_iff (s : AffineSubspace 𝕜 Q) :
    IsClosed (s.direction : Set W) ↔ IsClosed (s : Set Q) :=
  by
  rcases s.eq_bot_or_nonempty with (rfl | ⟨x, hx⟩); · simp [isClosed_singleton]
  rw [← (IsometryEquiv.vaddConst x).toHomeomorph.symm.isClosed_image,
    AffineSubspace.coe_direction_eq_vsub_set_right hx]
  rfl
#align affine_subspace.is_closed_direction_iff AffineSubspace.isClosed_direction_iff
-/

#print dist_center_homothety /-
@[simp]
theorem dist_center_homothety (p₁ p₂ : P) (c : 𝕜) :
    dist p₁ (homothety p₁ c p₂) = ‖c‖ * dist p₁ p₂ := by
  simp [homothety_def, norm_smul, ← dist_eq_norm_vsub, dist_comm]
#align dist_center_homothety dist_center_homothety
-/

#print nndist_center_homothety /-
@[simp]
theorem nndist_center_homothety (p₁ p₂ : P) (c : 𝕜) :
    nndist p₁ (homothety p₁ c p₂) = ‖c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_center_homothety _ _ _
#align nndist_center_homothety nndist_center_homothety
-/

#print dist_homothety_center /-
@[simp]
theorem dist_homothety_center (p₁ p₂ : P) (c : 𝕜) :
    dist (homothety p₁ c p₂) p₁ = ‖c‖ * dist p₁ p₂ := by rw [dist_comm, dist_center_homothety]
#align dist_homothety_center dist_homothety_center
-/

#print nndist_homothety_center /-
@[simp]
theorem nndist_homothety_center (p₁ p₂ : P) (c : 𝕜) :
    nndist (homothety p₁ c p₂) p₁ = ‖c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_homothety_center _ _ _
#align nndist_homothety_center nndist_homothety_center
-/

#print dist_lineMap_lineMap /-
@[simp]
theorem dist_lineMap_lineMap (p₁ p₂ : P) (c₁ c₂ : 𝕜) :
    dist (lineMap p₁ p₂ c₁) (lineMap p₁ p₂ c₂) = dist c₁ c₂ * dist p₁ p₂ :=
  by
  rw [dist_comm p₁ p₂]
  simp only [line_map_apply, dist_eq_norm_vsub, vadd_vsub_vadd_cancel_right, ← sub_smul, norm_smul,
    vsub_eq_sub]
#align dist_line_map_line_map dist_lineMap_lineMap
-/

#print nndist_lineMap_lineMap /-
@[simp]
theorem nndist_lineMap_lineMap (p₁ p₂ : P) (c₁ c₂ : 𝕜) :
    nndist (lineMap p₁ p₂ c₁) (lineMap p₁ p₂ c₂) = nndist c₁ c₂ * nndist p₁ p₂ :=
  NNReal.eq <| dist_lineMap_lineMap _ _ _ _
#align nndist_line_map_line_map nndist_lineMap_lineMap
-/

#print lipschitzWith_lineMap /-
theorem lipschitzWith_lineMap (p₁ p₂ : P) : LipschitzWith (nndist p₁ p₂) (lineMap p₁ p₂ : 𝕜 → P) :=
  LipschitzWith.of_dist_le_mul fun c₁ c₂ =>
    ((dist_lineMap_lineMap p₁ p₂ c₁ c₂).trans (mul_comm _ _)).le
#align lipschitz_with_line_map lipschitzWith_lineMap
-/

#print dist_lineMap_left /-
@[simp]
theorem dist_lineMap_left (p₁ p₂ : P) (c : 𝕜) : dist (lineMap p₁ p₂ c) p₁ = ‖c‖ * dist p₁ p₂ := by
  simpa only [line_map_apply_zero, dist_zero_right] using dist_lineMap_lineMap p₁ p₂ c 0
#align dist_line_map_left dist_lineMap_left
-/

#print nndist_lineMap_left /-
@[simp]
theorem nndist_lineMap_left (p₁ p₂ : P) (c : 𝕜) :
    nndist (lineMap p₁ p₂ c) p₁ = ‖c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_lineMap_left _ _ _
#align nndist_line_map_left nndist_lineMap_left
-/

#print dist_left_lineMap /-
@[simp]
theorem dist_left_lineMap (p₁ p₂ : P) (c : 𝕜) : dist p₁ (lineMap p₁ p₂ c) = ‖c‖ * dist p₁ p₂ :=
  (dist_comm _ _).trans (dist_lineMap_left _ _ _)
#align dist_left_line_map dist_left_lineMap
-/

#print nndist_left_lineMap /-
@[simp]
theorem nndist_left_lineMap (p₁ p₂ : P) (c : 𝕜) :
    nndist p₁ (lineMap p₁ p₂ c) = ‖c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_left_lineMap _ _ _
#align nndist_left_line_map nndist_left_lineMap
-/

#print dist_lineMap_right /-
@[simp]
theorem dist_lineMap_right (p₁ p₂ : P) (c : 𝕜) : dist (lineMap p₁ p₂ c) p₂ = ‖1 - c‖ * dist p₁ p₂ :=
  by simpa only [line_map_apply_one, dist_eq_norm'] using dist_lineMap_lineMap p₁ p₂ c 1
#align dist_line_map_right dist_lineMap_right
-/

#print nndist_lineMap_right /-
@[simp]
theorem nndist_lineMap_right (p₁ p₂ : P) (c : 𝕜) :
    nndist (lineMap p₁ p₂ c) p₂ = ‖1 - c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_lineMap_right _ _ _
#align nndist_line_map_right nndist_lineMap_right
-/

#print dist_right_lineMap /-
@[simp]
theorem dist_right_lineMap (p₁ p₂ : P) (c : 𝕜) : dist p₂ (lineMap p₁ p₂ c) = ‖1 - c‖ * dist p₁ p₂ :=
  (dist_comm _ _).trans (dist_lineMap_right _ _ _)
#align dist_right_line_map dist_right_lineMap
-/

#print nndist_right_lineMap /-
@[simp]
theorem nndist_right_lineMap (p₁ p₂ : P) (c : 𝕜) :
    nndist p₂ (lineMap p₁ p₂ c) = ‖1 - c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_right_lineMap _ _ _
#align nndist_right_line_map nndist_right_lineMap
-/

#print dist_homothety_self /-
@[simp]
theorem dist_homothety_self (p₁ p₂ : P) (c : 𝕜) :
    dist (homothety p₁ c p₂) p₂ = ‖1 - c‖ * dist p₁ p₂ := by
  rw [homothety_eq_line_map, dist_lineMap_right]
#align dist_homothety_self dist_homothety_self
-/

#print nndist_homothety_self /-
@[simp]
theorem nndist_homothety_self (p₁ p₂ : P) (c : 𝕜) :
    nndist (homothety p₁ c p₂) p₂ = ‖1 - c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_homothety_self _ _ _
#align nndist_homothety_self nndist_homothety_self
-/

#print dist_self_homothety /-
@[simp]
theorem dist_self_homothety (p₁ p₂ : P) (c : 𝕜) :
    dist p₂ (homothety p₁ c p₂) = ‖1 - c‖ * dist p₁ p₂ := by rw [dist_comm, dist_homothety_self]
#align dist_self_homothety dist_self_homothety
-/

#print nndist_self_homothety /-
@[simp]
theorem nndist_self_homothety (p₁ p₂ : P) (c : 𝕜) :
    nndist p₂ (homothety p₁ c p₂) = ‖1 - c‖₊ * nndist p₁ p₂ :=
  NNReal.eq <| dist_self_homothety _ _ _
#align nndist_self_homothety nndist_self_homothety
-/

section invertibleTwo

variable [Invertible (2 : 𝕜)]

#print dist_left_midpoint /-
@[simp]
theorem dist_left_midpoint (p₁ p₂ : P) : dist p₁ (midpoint 𝕜 p₁ p₂) = ‖(2 : 𝕜)‖⁻¹ * dist p₁ p₂ := by
  rw [midpoint, dist_comm, dist_lineMap_left, invOf_eq_inv, ← norm_inv]
#align dist_left_midpoint dist_left_midpoint
-/

#print nndist_left_midpoint /-
@[simp]
theorem nndist_left_midpoint (p₁ p₂ : P) :
    nndist p₁ (midpoint 𝕜 p₁ p₂) = ‖(2 : 𝕜)‖₊⁻¹ * nndist p₁ p₂ :=
  NNReal.eq <| dist_left_midpoint _ _
#align nndist_left_midpoint nndist_left_midpoint
-/

#print dist_midpoint_left /-
@[simp]
theorem dist_midpoint_left (p₁ p₂ : P) : dist (midpoint 𝕜 p₁ p₂) p₁ = ‖(2 : 𝕜)‖⁻¹ * dist p₁ p₂ := by
  rw [dist_comm, dist_left_midpoint]
#align dist_midpoint_left dist_midpoint_left
-/

#print nndist_midpoint_left /-
@[simp]
theorem nndist_midpoint_left (p₁ p₂ : P) :
    nndist (midpoint 𝕜 p₁ p₂) p₁ = ‖(2 : 𝕜)‖₊⁻¹ * nndist p₁ p₂ :=
  NNReal.eq <| dist_midpoint_left _ _
#align nndist_midpoint_left nndist_midpoint_left
-/

#print dist_midpoint_right /-
@[simp]
theorem dist_midpoint_right (p₁ p₂ : P) : dist (midpoint 𝕜 p₁ p₂) p₂ = ‖(2 : 𝕜)‖⁻¹ * dist p₁ p₂ :=
  by rw [midpoint_comm, dist_midpoint_left, dist_comm]
#align dist_midpoint_right dist_midpoint_right
-/

#print nndist_midpoint_right /-
@[simp]
theorem nndist_midpoint_right (p₁ p₂ : P) :
    nndist (midpoint 𝕜 p₁ p₂) p₂ = ‖(2 : 𝕜)‖₊⁻¹ * nndist p₁ p₂ :=
  NNReal.eq <| dist_midpoint_right _ _
#align nndist_midpoint_right nndist_midpoint_right
-/

#print dist_right_midpoint /-
@[simp]
theorem dist_right_midpoint (p₁ p₂ : P) : dist p₂ (midpoint 𝕜 p₁ p₂) = ‖(2 : 𝕜)‖⁻¹ * dist p₁ p₂ :=
  by rw [dist_comm, dist_midpoint_right]
#align dist_right_midpoint dist_right_midpoint
-/

#print nndist_right_midpoint /-
@[simp]
theorem nndist_right_midpoint (p₁ p₂ : P) :
    nndist p₂ (midpoint 𝕜 p₁ p₂) = ‖(2 : 𝕜)‖₊⁻¹ * nndist p₁ p₂ :=
  NNReal.eq <| dist_right_midpoint _ _
#align nndist_right_midpoint nndist_right_midpoint
-/

#print dist_midpoint_midpoint_le' /-
theorem dist_midpoint_midpoint_le' (p₁ p₂ p₃ p₄ : P) :
    dist (midpoint 𝕜 p₁ p₂) (midpoint 𝕜 p₃ p₄) ≤ (dist p₁ p₃ + dist p₂ p₄) / ‖(2 : 𝕜)‖ :=
  by
  rw [dist_eq_norm_vsub V, dist_eq_norm_vsub V, dist_eq_norm_vsub V, midpoint_vsub_midpoint] <;>
    try infer_instance
  rw [midpoint_eq_smul_add, norm_smul, invOf_eq_inv, norm_inv, ← div_eq_inv_mul]
  exact div_le_div_of_le_of_nonneg (norm_add_le _ _) (norm_nonneg _)
#align dist_midpoint_midpoint_le' dist_midpoint_midpoint_le'
-/

#print nndist_midpoint_midpoint_le' /-
theorem nndist_midpoint_midpoint_le' (p₁ p₂ p₃ p₄ : P) :
    nndist (midpoint 𝕜 p₁ p₂) (midpoint 𝕜 p₃ p₄) ≤ (nndist p₁ p₃ + nndist p₂ p₄) / ‖(2 : 𝕜)‖₊ :=
  dist_midpoint_midpoint_le' _ _ _ _
#align nndist_midpoint_midpoint_le' nndist_midpoint_midpoint_le'
-/

end invertibleTwo

#print antilipschitzWith_lineMap /-
theorem antilipschitzWith_lineMap {p₁ p₂ : Q} (h : p₁ ≠ p₂) :
    AntilipschitzWith (nndist p₁ p₂)⁻¹ (lineMap p₁ p₂ : 𝕜 → Q) :=
  AntilipschitzWith.of_le_mul_dist fun c₁ c₂ => by
    rw [dist_lineMap_lineMap, NNReal.coe_inv, ← dist_nndist, mul_left_comm,
      inv_mul_cancel (dist_ne_zero.2 h), mul_one]
#align antilipschitz_with_line_map antilipschitzWith_lineMap
-/

variable (𝕜)

#print eventually_homothety_mem_of_mem_interior /-
theorem eventually_homothety_mem_of_mem_interior (x : Q) {s : Set Q} {y : Q} (hy : y ∈ interior s) :
    ∀ᶠ δ in 𝓝 (1 : 𝕜), homothety x δ y ∈ s :=
  by
  rw [(NormedAddCommGroup.nhds_basis_norm_lt (1 : 𝕜)).eventually_iff]
  cases' eq_or_ne y x with h h; · use 1; simp [h.symm, interior_subset hy]
  have hxy : 0 < ‖y -ᵥ x‖ := by rwa [norm_pos_iff, vsub_ne_zero]
  obtain ⟨u, hu₁, hu₂, hu₃⟩ := mem_interior.mp hy
  obtain ⟨ε, hε, hyε⟩ := metric.is_open_iff.mp hu₂ y hu₃
  refine' ⟨ε / ‖y -ᵥ x‖, div_pos hε hxy, fun δ (hδ : ‖δ - 1‖ < ε / ‖y -ᵥ x‖) => hu₁ (hyε _)⟩
  rw [lt_div_iff hxy, ← norm_smul, sub_smul, one_smul] at hδ 
  rwa [homothety_apply, Metric.mem_ball, dist_eq_norm_vsub W, vadd_vsub_eq_sub_vsub]
#align eventually_homothety_mem_of_mem_interior eventually_homothety_mem_of_mem_interior
-/

#print eventually_homothety_image_subset_of_finite_subset_interior /-
theorem eventually_homothety_image_subset_of_finite_subset_interior (x : Q) {s : Set Q} {t : Set Q}
    (ht : t.Finite) (h : t ⊆ interior s) : ∀ᶠ δ in 𝓝 (1 : 𝕜), homothety x δ '' t ⊆ s :=
  by
  suffices ∀ y ∈ t, ∀ᶠ δ in 𝓝 (1 : 𝕜), homothety x δ y ∈ s
    by
    simp_rw [Set.image_subset_iff]
    exact (Filter.eventually_all_finite ht).mpr this
  intro y hy
  exact eventually_homothety_mem_of_mem_interior 𝕜 x (h hy)
#align eventually_homothety_image_subset_of_finite_subset_interior eventually_homothety_image_subset_of_finite_subset_interior
-/

end NormedSpace

variable [NormedSpace ℝ V] [NormedSpace ℝ W]

#print dist_midpoint_midpoint_le /-
theorem dist_midpoint_midpoint_le (p₁ p₂ p₃ p₄ : V) :
    dist (midpoint ℝ p₁ p₂) (midpoint ℝ p₃ p₄) ≤ (dist p₁ p₃ + dist p₂ p₄) / 2 := by
  simpa using dist_midpoint_midpoint_le' p₁ p₂ p₃ p₄
#align dist_midpoint_midpoint_le dist_midpoint_midpoint_le
-/

#print nndist_midpoint_midpoint_le /-
theorem nndist_midpoint_midpoint_le (p₁ p₂ p₃ p₄ : V) :
    nndist (midpoint ℝ p₁ p₂) (midpoint ℝ p₃ p₄) ≤ (nndist p₁ p₃ + nndist p₂ p₄) / 2 :=
  dist_midpoint_midpoint_le _ _ _ _
#align nndist_midpoint_midpoint_le nndist_midpoint_midpoint_le
-/

#print AffineMap.ofMapMidpoint /-
/-- A continuous map between two normed affine spaces is an affine map provided that
it sends midpoints to midpoints. -/
def AffineMap.ofMapMidpoint (f : P → Q) (h : ∀ x y, f (midpoint ℝ x y) = midpoint ℝ (f x) (f y))
    (hfc : Continuous f) : P →ᵃ[ℝ] Q :=
  AffineMap.mk' f
    (↑((AddMonoidHom.ofMapMidpoint ℝ ℝ
            ((AffineEquiv.vaddConst ℝ (f <| Classical.arbitrary P)).symm ∘
              f ∘ AffineEquiv.vaddConst ℝ (Classical.arbitrary P))
            (by simp) fun x y => by simp [h]).toRealLinearMap <|
        by
        apply_rules [Continuous.vadd, Continuous.vsub, continuous_const, hfc.comp, continuous_id]))
    (Classical.arbitrary P) fun p => by simp
#align affine_map.of_map_midpoint AffineMap.ofMapMidpoint
-/

