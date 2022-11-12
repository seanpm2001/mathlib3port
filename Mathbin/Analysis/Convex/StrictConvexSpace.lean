/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Yury Kudryashov
-/
import Mathbin.Analysis.Convex.Strict
import Mathbin.Analysis.Convex.Topology
import Mathbin.Analysis.Normed.Order.Basic
import Mathbin.Analysis.NormedSpace.Pointwise
import Mathbin.Analysis.NormedSpace.AffineIsometry

/-!
# Strictly convex spaces

This file defines strictly convex spaces. A normed space is strictly convex if all closed balls are
strictly convex. This does **not** mean that the norm is strictly convex (in fact, it never is).

## Main definitions

`strict_convex_space`: a typeclass saying that a given normed space over a normed linear ordered
field (e.g., `ℝ` or `ℚ`) is strictly convex. The definition requires strict convexity of a closed
ball of positive radius with center at the origin; strict convexity of any other closed ball follows
from this assumption.

## Main results

In a strictly convex space, we prove

- `strict_convex_closed_ball`: a closed ball is strictly convex.
- `combo_mem_ball_of_ne`, `open_segment_subset_ball_of_ne`, `norm_combo_lt_of_ne`:
  a nontrivial convex combination of two points in a closed ball belong to the corresponding open
  ball;
- `norm_add_lt_of_not_same_ray`, `same_ray_iff_norm_add`, `dist_add_dist_eq_iff`:
  the triangle inequality `dist x y + dist y z ≤ dist x z` is a strict inequality unless `y` belongs
  to the segment `[x -[ℝ] z]`.
- `isometry.affine_isometry_of_strict_convex_space`: an isometry of `normed_add_torsor`s for real
  normed spaces, strictly convex in the case of the codomain, is an affine isometry.

We also provide several lemmas that can be used as alternative constructors for `strict_convex ℝ E`:

- `strict_convex_space.of_strict_convex_closed_unit_ball`: if `closed_ball (0 : E) 1` is strictly
  convex, then `E` is a strictly convex space;

- `strict_convex_space.of_norm_add`: if `∥x + y∥ = ∥x∥ + ∥y∥` implies `same_ray ℝ x y` for all
  `x y : E`, then `E` is a strictly convex space.

## Implementation notes

While the definition is formulated for any normed linear ordered field, most of the lemmas are
formulated only for the case `𝕜 = ℝ`.

## Tags

convex, strictly convex
-/


open Set Metric

open Convex Pointwise

/-- A *strictly convex space* is a normed space where the closed balls are strictly convex. We only
require balls of positive radius with center at the origin to be strictly convex in the definition,
then prove that any closed ball is strictly convex in `strict_convex_closed_ball` below.

See also `strict_convex_space.of_strict_convex_closed_unit_ball`. -/
class StrictConvexSpace (𝕜 E : Type _) [NormedLinearOrderedField 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E] :
  Prop where
  strict_convex_closed_ball : ∀ r : ℝ, 0 < r → StrictConvex 𝕜 (ClosedBall (0 : E) r)
#align strict_convex_space StrictConvexSpace

variable (𝕜 : Type _) {E : Type _} [NormedLinearOrderedField 𝕜] [NormedAddCommGroup E] [NormedSpace 𝕜 E]

/-- A closed ball in a strictly convex space is strictly convex. -/
theorem strict_convex_closed_ball [StrictConvexSpace 𝕜 E] (x : E) (r : ℝ) : StrictConvex 𝕜 (ClosedBall x r) := by
  cases' le_or_lt r 0 with hr hr
  · exact (subsingleton_closed_ball x hr).StrictConvex
    
  rw [← vadd_closed_ball_zero]
  exact (StrictConvexSpace.strict_convex_closed_ball r hr).vadd _
#align strict_convex_closed_ball strict_convex_closed_ball

variable [NormedSpace ℝ E]

/-- A real normed vector space is strictly convex provided that the unit ball is strictly convex. -/
theorem StrictConvexSpace.ofStrictConvexClosedUnitBall [LinearMap.CompatibleSmul E E 𝕜 ℝ]
    (h : StrictConvex 𝕜 (ClosedBall (0 : E) 1)) : StrictConvexSpace 𝕜 E :=
  ⟨fun r hr => by simpa only [smul_closed_unit_ball_of_nonneg hr.le] using h.smul r⟩
#align strict_convex_space.of_strict_convex_closed_unit_ball StrictConvexSpace.ofStrictConvexClosedUnitBall

/-- If `∥x + y∥ = ∥x∥ + ∥y∥` implies that `x y : E` are in the same ray, then `E` is a strictly
convex space. -/
theorem StrictConvexSpace.ofNormAdd (h : ∀ x y : E, ∥x + y∥ = ∥x∥ + ∥y∥ → SameRay ℝ x y) : StrictConvexSpace ℝ E := by
  refine' StrictConvexSpace.ofStrictConvexClosedUnitBall ℝ fun x hx y hy hne a b ha hb hab => _
  have hx' := hx
  have hy' := hy
  rw [← closure_closed_ball, closure_eq_interior_union_frontier, frontier_closed_ball (0 : E) one_ne_zero] at hx hy
  cases hx
  · exact (convex_closed_ball _ _).combo_interior_self_mem_interior hx hy' ha hb.le hab
    
  cases hy
  · exact (convex_closed_ball _ _).combo_self_interior_mem_interior hx' hy ha.le hb hab
    
  rw [interior_closed_ball (0 : E) one_ne_zero, mem_ball_zero_iff]
  have hx₁ : ∥x∥ = 1 := mem_sphere_zero_iff_norm.1 hx
  have hy₁ : ∥y∥ = 1 := mem_sphere_zero_iff_norm.1 hy
  have ha' : ∥a∥ = a := Real.norm_of_nonneg ha.le
  have hb' : ∥b∥ = b := Real.norm_of_nonneg hb.le
  calc
    ∥a • x + b • y∥ < ∥a • x∥ + ∥b • y∥ := (norm_add_le _ _).lt_of_ne fun H => hne _
    _ = 1 := by simpa only [norm_smul, hx₁, hy₁, mul_one, ha', hb']
    
  simpa only [norm_smul, hx₁, hy₁, ha', hb', mul_one, smul_comm a, smul_right_inj ha.ne', smul_right_inj hb.ne'] using
    (h _ _ H).norm_smul_eq.symm
#align strict_convex_space.of_norm_add StrictConvexSpace.ofNormAdd

theorem StrictConvexSpace.of_norm_add_lt_aux {a b c d : ℝ} (ha : 0 < a) (hab : a + b = 1) (hc : 0 < c) (hd : 0 < d)
    (hcd : c + d = 1) (hca : c ≤ a) {x y : E} (hy : ∥y∥ ≤ 1) (hxy : ∥a • x + b • y∥ < 1) : ∥c • x + d • y∥ < 1 := by
  have hbd : b ≤ d := by
    refine' le_of_add_le_add_left (hab.trans_le _)
    rw [← hcd]
    exact add_le_add_right hca _
  have h₁ : 0 < c / a := div_pos hc ha
  have h₂ : 0 ≤ d - c / a * b := by
    rw [sub_nonneg, mul_comm_div, ← le_div_iff' hc]
    exact div_le_div hd.le hbd hc hca
  calc
    ∥c • x + d • y∥ = ∥(c / a) • (a • x + b • y) + (d - c / a * b) • y∥ := by
      rw [smul_add, ← mul_smul, ← mul_smul, div_mul_cancel _ ha.ne', sub_smul, add_add_sub_cancel]
    _ ≤ ∥(c / a) • (a • x + b • y)∥ + ∥(d - c / a * b) • y∥ := norm_add_le _ _
    _ = c / a * ∥a • x + b • y∥ + (d - c / a * b) * ∥y∥ := by rw [norm_smul_of_nonneg h₁.le, norm_smul_of_nonneg h₂]
    _ < c / a * 1 + (d - c / a * b) * 1 :=
      add_lt_add_of_lt_of_le (mul_lt_mul_of_pos_left hxy h₁) (mul_le_mul_of_nonneg_left hy h₂)
    _ = 1 := by
      nth_rw 0 [← hab]
      rw [mul_add, div_mul_cancel _ ha.ne', mul_one, add_add_sub_cancel, hcd]
    
#align strict_convex_space.of_norm_add_lt_aux StrictConvexSpace.of_norm_add_lt_aux

/-- Strict convexity is equivalent to `∥a • x + b • y∥ < 1` for all `x` and `y` of norm at most `1`
and all strictly positive `a` and `b` such that `a + b = 1`. This shows that we only need to check
it for fixed `a` and `b`. -/
theorem StrictConvexSpace.ofNormAddLt {a b : ℝ} (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1)
    (h : ∀ x y : E, ∥x∥ ≤ 1 → ∥y∥ ≤ 1 → x ≠ y → ∥a • x + b • y∥ < 1) : StrictConvexSpace ℝ E := by
  refine' StrictConvexSpace.ofStrictConvexClosedUnitBall _ fun x hx y hy hxy c d hc hd hcd => _
  rw [interior_closed_ball (0 : E) one_ne_zero, mem_ball_zero_iff]
  rw [mem_closed_ball_zero_iff] at hx hy
  obtain hca | hac := le_total c a
  · exact StrictConvexSpace.of_norm_add_lt_aux ha hab hc hd hcd hca hy (h _ _ hx hy hxy)
    
  rw [add_comm] at hab hcd⊢
  refine' StrictConvexSpace.of_norm_add_lt_aux hb hab hd hc hcd _ hx _
  · refine' le_of_add_le_add_right (hcd.trans_le _)
    rw [← hab]
    exact add_le_add_left hac _
    
  · rw [add_comm]
    exact h _ _ hx hy hxy
    
#align strict_convex_space.of_norm_add_lt StrictConvexSpace.ofNormAddLt

variable [StrictConvexSpace ℝ E] {x y z : E} {a b r : ℝ}

/-- If `x ≠ y` belong to the same closed ball, then a convex combination of `x` and `y` with
positive coefficients belongs to the corresponding open ball. -/
theorem combo_mem_ball_of_ne (hx : x ∈ ClosedBall z r) (hy : y ∈ ClosedBall z r) (hne : x ≠ y) (ha : 0 < a) (hb : 0 < b)
    (hab : a + b = 1) : a • x + b • y ∈ Ball z r := by
  rcases eq_or_ne r 0 with (rfl | hr)
  · rw [closed_ball_zero, mem_singleton_iff] at hx hy
    exact (hne (hx.trans hy.symm)).elim
    
  · simp only [← interior_closed_ball _ hr] at hx hy⊢
    exact strict_convex_closed_ball ℝ z r hx hy hne ha hb hab
    
#align combo_mem_ball_of_ne combo_mem_ball_of_ne

/-- If `x ≠ y` belong to the same closed ball, then the open segment with endpoints `x` and `y` is
included in the corresponding open ball. -/
theorem open_segment_subset_ball_of_ne (hx : x ∈ ClosedBall z r) (hy : y ∈ ClosedBall z r) (hne : x ≠ y) :
    OpenSegment ℝ x y ⊆ Ball z r :=
  (open_segment_subset_iff _).2 fun a b => combo_mem_ball_of_ne hx hy hne
#align open_segment_subset_ball_of_ne open_segment_subset_ball_of_ne

/-- If `x` and `y` are two distinct vectors of norm at most `r`, then a convex combination of `x`
and `y` with positive coefficients has norm strictly less than `r`. -/
theorem norm_combo_lt_of_ne (hx : ∥x∥ ≤ r) (hy : ∥y∥ ≤ r) (hne : x ≠ y) (ha : 0 < a) (hb : 0 < b) (hab : a + b = 1) :
    ∥a • x + b • y∥ < r := by
  simp only [← mem_ball_zero_iff, ← mem_closed_ball_zero_iff] at hx hy⊢
  exact combo_mem_ball_of_ne hx hy hne ha hb hab
#align norm_combo_lt_of_ne norm_combo_lt_of_ne

/-- In a strictly convex space, if `x` and `y` are not in the same ray, then `∥x + y∥ < ∥x∥ +
∥y∥`. -/
theorem norm_add_lt_of_not_same_ray (h : ¬SameRay ℝ x y) : ∥x + y∥ < ∥x∥ + ∥y∥ := by
  simp only [same_ray_iff_inv_norm_smul_eq, not_or, ← Ne.def] at h
  rcases h with ⟨hx, hy, hne⟩
  rw [← norm_pos_iff] at hx hy
  have hxy : 0 < ∥x∥ + ∥y∥ := add_pos hx hy
  have :=
    combo_mem_ball_of_ne (inv_norm_smul_mem_closed_unit_ball x) (inv_norm_smul_mem_closed_unit_ball y) hne
      (div_pos hx hxy) (div_pos hy hxy) (by rw [← add_div, div_self hxy.ne'])
  rwa [mem_ball_zero_iff, div_eq_inv_mul, div_eq_inv_mul, mul_smul, mul_smul, smul_inv_smul₀ hx.ne',
    smul_inv_smul₀ hy.ne', ← smul_add, norm_smul, Real.norm_of_nonneg (inv_pos.2 hxy).le, ← div_eq_inv_mul,
    div_lt_one hxy] at this
#align norm_add_lt_of_not_same_ray norm_add_lt_of_not_same_ray

theorem lt_norm_sub_of_not_same_ray (h : ¬SameRay ℝ x y) : ∥x∥ - ∥y∥ < ∥x - y∥ := by
  nth_rw 0 [← sub_add_cancel x y]  at h⊢
  exact sub_lt_iff_lt_add.2 (norm_add_lt_of_not_same_ray fun H' => h <| H'.add_left SameRay.rfl)
#align lt_norm_sub_of_not_same_ray lt_norm_sub_of_not_same_ray

theorem abs_lt_norm_sub_of_not_same_ray (h : ¬SameRay ℝ x y) : |∥x∥ - ∥y∥| < ∥x - y∥ := by
  refine' abs_sub_lt_iff.2 ⟨lt_norm_sub_of_not_same_ray h, _⟩
  rw [norm_sub_rev]
  exact lt_norm_sub_of_not_same_ray (mt SameRay.symm h)
#align abs_lt_norm_sub_of_not_same_ray abs_lt_norm_sub_of_not_same_ray

/-- In a strictly convex space, two vectors `x`, `y` are in the same ray if and only if the triangle
inequality for `x` and `y` becomes an equality. -/
theorem same_ray_iff_norm_add : SameRay ℝ x y ↔ ∥x + y∥ = ∥x∥ + ∥y∥ :=
  ⟨SameRay.norm_add, fun h => not_not.1 fun h' => (norm_add_lt_of_not_same_ray h').Ne h⟩
#align same_ray_iff_norm_add same_ray_iff_norm_add

/-- If `x` and `y` are two vectors in a strictly convex space have the same norm and the norm of
their sum is equal to the sum of their norms, then they are equal. -/
theorem eq_of_norm_eq_of_norm_add_eq (h₁ : ∥x∥ = ∥y∥) (h₂ : ∥x + y∥ = ∥x∥ + ∥y∥) : x = y :=
  (same_ray_iff_norm_add.mpr h₂).eq_of_norm_eq h₁
#align eq_of_norm_eq_of_norm_add_eq eq_of_norm_eq_of_norm_add_eq

/-- In a strictly convex space, two vectors `x`, `y` are not in the same ray if and only if the
triangle inequality for `x` and `y` is strict. -/
theorem not_same_ray_iff_norm_add_lt : ¬SameRay ℝ x y ↔ ∥x + y∥ < ∥x∥ + ∥y∥ :=
  same_ray_iff_norm_add.Not.trans (norm_add_le _ _).lt_iff_ne.symm
#align not_same_ray_iff_norm_add_lt not_same_ray_iff_norm_add_lt

theorem same_ray_iff_norm_sub : SameRay ℝ x y ↔ ∥x - y∥ = |∥x∥ - ∥y∥| :=
  ⟨SameRay.norm_sub, fun h => not_not.1 fun h' => (abs_lt_norm_sub_of_not_same_ray h').ne' h⟩
#align same_ray_iff_norm_sub same_ray_iff_norm_sub

theorem not_same_ray_iff_abs_lt_norm_sub : ¬SameRay ℝ x y ↔ |∥x∥ - ∥y∥| < ∥x - y∥ :=
  same_ray_iff_norm_sub.Not.trans <| ne_comm.trans (abs_norm_sub_norm_le _ _).lt_iff_ne.symm
#align not_same_ray_iff_abs_lt_norm_sub not_same_ray_iff_abs_lt_norm_sub

/-- In a strictly convex space, the triangle inequality turns into an equality if and only if the
middle point belongs to the segment joining two other points. -/
theorem dist_add_dist_eq_iff : dist x y + dist y z = dist x z ↔ y ∈ [x -[ℝ] z] := by
  simp only [mem_segment_iff_same_ray, same_ray_iff_norm_add, dist_eq_norm', sub_add_sub_cancel', eq_comm]
#align dist_add_dist_eq_iff dist_add_dist_eq_iff

theorem norm_midpoint_lt_iff (h : ∥x∥ = ∥y∥) : ∥(1 / 2 : ℝ) • (x + y)∥ < ∥x∥ ↔ x ≠ y := by
  rw [norm_smul, Real.norm_of_nonneg (one_div_nonneg.2 zero_le_two), ← inv_eq_one_div, ← div_eq_inv_mul,
    div_lt_iff (@zero_lt_two ℝ _ _), mul_two, ← not_same_ray_iff_of_norm_eq h, not_same_ray_iff_norm_add_lt, h]
#align norm_midpoint_lt_iff norm_midpoint_lt_iff

variable {F : Type _} [NormedAddCommGroup F] [NormedSpace ℝ F]

variable {PF : Type _} {PE : Type _} [MetricSpace PF] [MetricSpace PE]

variable [NormedAddTorsor F PF] [NormedAddTorsor E PE]

include E

theorem eq_line_map_of_dist_eq_mul_of_dist_eq_mul {x y z : PE} (hxy : dist x y = r * dist x z)
    (hyz : dist y z = (1 - r) * dist x z) : y = AffineMap.lineMap x z r := by
  have : y -ᵥ x ∈ [(0 : E) -[ℝ] z -ᵥ x] := by
    rw [← dist_add_dist_eq_iff, dist_zero_left, dist_vsub_cancel_right, ← dist_eq_norm_vsub', ← dist_eq_norm_vsub', hxy,
      hyz, ← add_mul, add_sub_cancel'_right, one_mul]
  rcases eq_or_ne x z with (rfl | hne)
  · obtain rfl : y = x := by simpa
    simp
    
  · rw [← dist_ne_zero] at hne
    rcases this with ⟨a, b, ha, hb, hab, H⟩
    rw [smul_zero, zero_add] at H
    have H' := congr_arg norm H
    rw [norm_smul, Real.norm_of_nonneg hb, ← dist_eq_norm_vsub', ← dist_eq_norm_vsub', hxy, mul_left_inj' hne] at H'
    rw [AffineMap.line_map_apply, ← H', H, vsub_vadd]
    
#align eq_line_map_of_dist_eq_mul_of_dist_eq_mul eq_line_map_of_dist_eq_mul_of_dist_eq_mul

theorem eq_midpoint_of_dist_eq_half {x y z : PE} (hx : dist x y = dist x z / 2) (hy : dist y z = dist x z / 2) :
    y = midpoint ℝ x z := by
  apply eq_line_map_of_dist_eq_mul_of_dist_eq_mul
  · rwa [inv_of_eq_inv, ← div_eq_inv_mul]
    
  · rwa [inv_of_eq_inv, ← one_div, sub_half, one_div, ← div_eq_inv_mul]
    
#align eq_midpoint_of_dist_eq_half eq_midpoint_of_dist_eq_half

namespace Isometry

include F

/-- An isometry of `normed_add_torsor`s for real normed spaces, strictly convex in the case of
the codomain, is an affine isometry.  Unlike Mazur-Ulam, this does not require the isometry to
be surjective.  -/
noncomputable def affineIsometryOfStrictConvexSpace {f : PF → PE} (hi : Isometry f) : PF →ᵃⁱ[ℝ] PE :=
  { AffineMap.ofMapMidpoint f
      (fun x y => by
        apply eq_midpoint_of_dist_eq_half
        · rw [hi.dist_eq, hi.dist_eq, dist_left_midpoint, Real.norm_of_nonneg zero_le_two, div_eq_inv_mul]
          
        · rw [hi.dist_eq, hi.dist_eq, dist_midpoint_right, Real.norm_of_nonneg zero_le_two, div_eq_inv_mul]
          )
      hi.Continuous with
    norm_map := fun x => by simp [AffineMap.ofMapMidpoint, ← dist_eq_norm_vsub E, hi.dist_eq] }
#align isometry.affine_isometry_of_strict_convex_space Isometry.affineIsometryOfStrictConvexSpace

@[simp]
theorem coe_affine_isometry_of_strict_convex_space {f : PF → PE} (hi : Isometry f) :
    ⇑hi.affineIsometryOfStrictConvexSpace = f :=
  rfl
#align isometry.coe_affine_isometry_of_strict_convex_space Isometry.coe_affine_isometry_of_strict_convex_space

@[simp]
theorem affine_isometry_of_strict_convex_space_apply {f : PF → PE} (hi : Isometry f) (p : PF) :
    hi.affineIsometryOfStrictConvexSpace p = f p :=
  rfl
#align isometry.affine_isometry_of_strict_convex_space_apply Isometry.affine_isometry_of_strict_convex_space_apply

end Isometry

