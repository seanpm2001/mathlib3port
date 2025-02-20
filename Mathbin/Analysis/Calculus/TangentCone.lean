/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module analysis.calculus.tangent_cone
! leanprover-community/mathlib commit 2ed2c6310e6f1c5562bdf6bfbda55ebbf6891abe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Topology
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Analysis.SpecificLimits.Basic

/-!
# Tangent cone

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we define two predicates `unique_diff_within_at 𝕜 s x` and `unique_diff_on 𝕜 s`
ensuring that, if a function has two derivatives, then they have to coincide. As a direct
definition of this fact (quantifying on all target types and all functions) would depend on
universes, we use a more intrinsic definition: if all the possible tangent directions to the set
`s` at the point `x` span a dense subset of the whole subset, it is easy to check that the
derivative has to be unique.

Therefore, we introduce the set of all tangent directions, named `tangent_cone_at`,
and express `unique_diff_within_at` and `unique_diff_on` in terms of it.
One should however think of this definition as an implementation detail: the only reason to
introduce the predicates `unique_diff_within_at` and `unique_diff_on` is to ensure the uniqueness
of the derivative. This is why their names reflect their uses, and not how they are defined.

## Implementation details

Note that this file is imported by `fderiv.lean`. Hence, derivatives are not defined yet. The
property of uniqueness of the derivative is therefore proved in `fderiv.lean`, but based on the
properties of the tangent cone we prove here.
-/


variable (𝕜 : Type _) [NontriviallyNormedField 𝕜]

open Filter Set

open scoped Topology

section TangentCone

variable {E : Type _} [AddCommMonoid E] [Module 𝕜 E] [TopologicalSpace E]

#print tangentConeAt /-
/-- The set of all tangent directions to the set `s` at the point `x`. -/
def tangentConeAt (s : Set E) (x : E) : Set E :=
  {y : E |
    ∃ (c : ℕ → 𝕜) (d : ℕ → E),
      (∀ᶠ n in atTop, x + d n ∈ s) ∧
        Tendsto (fun n => ‖c n‖) atTop atTop ∧ Tendsto (fun n => c n • d n) atTop (𝓝 y)}
#align tangent_cone_at tangentConeAt
-/

#print UniqueDiffWithinAt /-
/-- A property ensuring that the tangent cone to `s` at `x` spans a dense subset of the whole space.
The main role of this property is to ensure that the differential within `s` at `x` is unique,
hence this name. The uniqueness it asserts is proved in `unique_diff_within_at.eq` in `fderiv.lean`.
To avoid pathologies in dimension 0, we also require that `x` belongs to the closure of `s` (which
is automatic when `E` is not `0`-dimensional).
 -/
@[mk_iff]
structure UniqueDiffWithinAt (s : Set E) (x : E) : Prop where
  dense_tangent_cone : Dense (Submodule.span 𝕜 (tangentConeAt 𝕜 s x) : Set E)
  mem_closure : x ∈ closure s
#align unique_diff_within_at UniqueDiffWithinAt
-/

#print UniqueDiffOn /-
/-- A property ensuring that the tangent cone to `s` at any of its points spans a dense subset of
the whole space.  The main role of this property is to ensure that the differential along `s` is
unique, hence this name. The uniqueness it asserts is proved in `unique_diff_on.eq` in
`fderiv.lean`. -/
def UniqueDiffOn (s : Set E) : Prop :=
  ∀ x ∈ s, UniqueDiffWithinAt 𝕜 s x
#align unique_diff_on UniqueDiffOn
-/

end TangentCone

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable {G : Type _} [NormedAddCommGroup G] [NormedSpace ℝ G]

variable {𝕜} {x y : E} {s t : Set E}

section TangentCone

-- This section is devoted to the properties of the tangent cone.
open NormedField

#print tangentCone_univ /-
theorem tangentCone_univ : tangentConeAt 𝕜 univ x = univ :=
  by
  refine' univ_subset_iff.1 fun y hy => _
  rcases exists_one_lt_norm 𝕜 with ⟨w, hw⟩
  refine' ⟨fun n => w ^ n, fun n => (w ^ n)⁻¹ • y, univ_mem' fun n => mem_univ _, _, _⟩
  · simp only [norm_pow]
    exact tendsto_pow_atTop_atTop_of_one_lt hw
  · convert tendsto_const_nhds
    ext n
    have : w ^ n * (w ^ n)⁻¹ = 1 := by
      apply mul_inv_cancel
      apply pow_ne_zero
      simpa [norm_eq_zero] using (ne_of_lt (lt_trans zero_lt_one hw)).symm
    rw [smul_smul, this, one_smul]
#align tangent_cone_univ tangentCone_univ
-/

#print tangentCone_mono /-
theorem tangentCone_mono (h : s ⊆ t) : tangentConeAt 𝕜 s x ⊆ tangentConeAt 𝕜 t x :=
  by
  rintro y ⟨c, d, ds, ctop, clim⟩
  exact ⟨c, d, mem_of_superset ds fun n hn => h hn, Ctop, clim⟩
#align tangent_cone_mono tangentCone_mono
-/

#print tangentConeAt.lim_zero /-
/-- Auxiliary lemma ensuring that, under the assumptions defining the tangent cone,
the sequence `d` tends to 0 at infinity. -/
theorem tangentConeAt.lim_zero {α : Type _} (l : Filter α) {c : α → 𝕜} {d : α → E}
    (hc : Tendsto (fun n => ‖c n‖) l atTop) (hd : Tendsto (fun n => c n • d n) l (𝓝 y)) :
    Tendsto d l (𝓝 0) :=
  by
  have A : tendsto (fun n => ‖c n‖⁻¹) l (𝓝 0) := tendsto_inv_at_top_zero.comp hc
  have B : tendsto (fun n => ‖c n • d n‖) l (𝓝 ‖y‖) := (continuous_norm.tendsto _).comp hd
  have C : tendsto (fun n => ‖c n‖⁻¹ * ‖c n • d n‖) l (𝓝 (0 * ‖y‖)) := A.mul B
  rw [MulZeroClass.zero_mul] at C 
  have : ∀ᶠ n in l, ‖c n‖⁻¹ * ‖c n • d n‖ = ‖d n‖ :=
    by
    apply (eventually_ne_of_tendsto_norm_atTop hc 0).mono fun n hn => _
    rw [norm_smul, ← mul_assoc, inv_mul_cancel, one_mul]
    rwa [Ne.def, norm_eq_zero]
  have D : tendsto (fun n => ‖d n‖) l (𝓝 0) := tendsto.congr' this C
  rw [tendsto_zero_iff_norm_tendsto_zero]
  exact D
#align tangent_cone_at.lim_zero tangentConeAt.lim_zero
-/

#print tangentCone_mono_nhds /-
theorem tangentCone_mono_nhds (h : 𝓝[s] x ≤ 𝓝[t] x) : tangentConeAt 𝕜 s x ⊆ tangentConeAt 𝕜 t x :=
  by
  rintro y ⟨c, d, ds, ctop, clim⟩
  refine' ⟨c, d, _, Ctop, clim⟩
  suffices : tendsto (fun n => x + d n) at_top (𝓝[t] x)
  exact tendsto_principal.1 (tendsto_inf.1 this).2
  refine' (tendsto_inf.2 ⟨_, tendsto_principal.2 ds⟩).mono_right h
  simpa only [add_zero] using tendsto_const_nhds.add (tangentConeAt.lim_zero at_top Ctop clim)
#align tangent_cone_mono_nhds tangentCone_mono_nhds
-/

#print tangentCone_congr /-
/-- Tangent cone of `s` at `x` depends only on `𝓝[s] x`. -/
theorem tangentCone_congr (h : 𝓝[s] x = 𝓝[t] x) : tangentConeAt 𝕜 s x = tangentConeAt 𝕜 t x :=
  Subset.antisymm (tangentCone_mono_nhds <| le_of_eq h) (tangentCone_mono_nhds <| le_of_eq h.symm)
#align tangent_cone_congr tangentCone_congr
-/

#print tangentCone_inter_nhds /-
/-- Intersecting with a neighborhood of the point does not change the tangent cone. -/
theorem tangentCone_inter_nhds (ht : t ∈ 𝓝 x) : tangentConeAt 𝕜 (s ∩ t) x = tangentConeAt 𝕜 s x :=
  tangentCone_congr (nhdsWithin_restrict' _ ht).symm
#align tangent_cone_inter_nhds tangentCone_inter_nhds
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print subset_tangentCone_prod_left /-
/-- The tangent cone of a product contains the tangent cone of its left factor. -/
theorem subset_tangentCone_prod_left {t : Set F} {y : F} (ht : y ∈ closure t) :
    LinearMap.inl 𝕜 E F '' tangentConeAt 𝕜 s x ⊆ tangentConeAt 𝕜 (s ×ˢ t) (x, y) :=
  by
  rintro _ ⟨v, ⟨c, d, hd, hc, hy⟩, rfl⟩
  have : ∀ n, ∃ d', y + d' ∈ t ∧ ‖c n • d'‖ < ((1 : ℝ) / 2) ^ n :=
    by
    intro n
    rcases mem_closure_iff_nhds.1 ht _
        (eventually_nhds_norm_smul_sub_lt (c n) y (pow_pos one_half_pos n)) with
      ⟨z, hz, hzt⟩
    exact ⟨z - y, by simpa using hzt, by simpa using hz⟩
  choose d' hd' using this
  refine' ⟨c, fun n => (d n, d' n), _, hc, _⟩
  show ∀ᶠ n in at_top, (x, y) + (d n, d' n) ∈ s ×ˢ t
  · filter_upwards [hd] with n hn
    simp [hn, (hd' n).1]
  · apply tendsto.prod_mk_nhds hy _
    refine' squeeze_zero_norm (fun n => (hd' n).2.le) _
    exact tendsto_pow_atTop_nhds_0_of_lt_1 one_half_pos.le one_half_lt_one
#align subset_tangent_cone_prod_left subset_tangentCone_prod_left
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print subset_tangentCone_prod_right /-
/-- The tangent cone of a product contains the tangent cone of its right factor. -/
theorem subset_tangentCone_prod_right {t : Set F} {y : F} (hs : x ∈ closure s) :
    LinearMap.inr 𝕜 E F '' tangentConeAt 𝕜 t y ⊆ tangentConeAt 𝕜 (s ×ˢ t) (x, y) :=
  by
  rintro _ ⟨w, ⟨c, d, hd, hc, hy⟩, rfl⟩
  have : ∀ n, ∃ d', x + d' ∈ s ∧ ‖c n • d'‖ < ((1 : ℝ) / 2) ^ n :=
    by
    intro n
    rcases mem_closure_iff_nhds.1 hs _
        (eventually_nhds_norm_smul_sub_lt (c n) x (pow_pos one_half_pos n)) with
      ⟨z, hz, hzs⟩
    exact ⟨z - x, by simpa using hzs, by simpa using hz⟩
  choose d' hd' using this
  refine' ⟨c, fun n => (d' n, d n), _, hc, _⟩
  show ∀ᶠ n in at_top, (x, y) + (d' n, d n) ∈ s ×ˢ t
  · filter_upwards [hd] with n hn
    simp [hn, (hd' n).1]
  · apply tendsto.prod_mk_nhds _ hy
    refine' squeeze_zero_norm (fun n => (hd' n).2.le) _
    exact tendsto_pow_atTop_nhds_0_of_lt_1 one_half_pos.le one_half_lt_one
#align subset_tangent_cone_prod_right subset_tangentCone_prod_right
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print mapsTo_tangentCone_pi /-
/-- The tangent cone of a product contains the tangent cone of each factor. -/
theorem mapsTo_tangentCone_pi {ι : Type _} [DecidableEq ι] {E : ι → Type _}
    [∀ i, NormedAddCommGroup (E i)] [∀ i, NormedSpace 𝕜 (E i)] {s : ∀ i, Set (E i)} {x : ∀ i, E i}
    {i : ι} (hi : ∀ (j) (_ : j ≠ i), x j ∈ closure (s j)) :
    MapsTo (LinearMap.single i : E i →ₗ[𝕜] ∀ j, E j) (tangentConeAt 𝕜 (s i) (x i))
      (tangentConeAt 𝕜 (Set.pi univ s) x) :=
  by
  rintro w ⟨c, d, hd, hc, hy⟩
  have : ∀ (n) (j) (_ : j ≠ i), ∃ d', x j + d' ∈ s j ∧ ‖c n • d'‖ < (1 / 2 : ℝ) ^ n :=
    by
    intro n j hj
    rcases mem_closure_iff_nhds.1 (hi j hj) _
        (eventually_nhds_norm_smul_sub_lt (c n) (x j) (pow_pos one_half_pos n)) with
      ⟨z, hz, hzs⟩
    exact ⟨z - x j, by simpa using hzs, by simpa using hz⟩
  choose! d' hd's hcd'
  refine'
    ⟨c, fun n => Function.update (d' n) i (d n), hd.mono fun n hn j hj' => _, hc,
      tendsto_pi_nhds.2 fun j => _⟩
  · rcases em (j = i) with (rfl | hj) <;> simp [*]
  · rcases em (j = i) with (rfl | hj)
    · simp [hy]
    · suffices tendsto (fun n => c n • d' n j) at_top (𝓝 0) by simpa [hj]
      refine' squeeze_zero_norm (fun n => (hcd' n j hj).le) _
      exact tendsto_pow_atTop_nhds_0_of_lt_1 one_half_pos.le one_half_lt_one
#align maps_to_tangent_cone_pi mapsTo_tangentCone_pi
-/

#print mem_tangentCone_of_openSegment_subset /-
/-- If a subset of a real vector space contains an open segment, then the direction of this
segment belongs to the tangent cone at its endpoints. -/
theorem mem_tangentCone_of_openSegment_subset {s : Set G} {x y : G} (h : openSegment ℝ x y ⊆ s) :
    y - x ∈ tangentConeAt ℝ s x :=
  by
  let c := fun n : ℕ => (2 : ℝ) ^ (n + 1)
  let d := fun n : ℕ => (c n)⁻¹ • (y - x)
  refine' ⟨c, d, Filter.univ_mem' fun n => h _, _, _⟩
  show x + d n ∈ openSegment ℝ x y
  · rw [openSegment_eq_image]
    refine' ⟨(c n)⁻¹, ⟨_, _⟩, _⟩
    · rw [inv_pos]; apply pow_pos; norm_num
    · apply inv_lt_one; apply one_lt_pow _ (Nat.succ_ne_zero _); norm_num
    · simp only [d, sub_smul, smul_sub, one_smul]; abel
  show Filter.Tendsto (fun n : ℕ => ‖c n‖) Filter.atTop Filter.atTop
  · have : (fun n : ℕ => ‖c n‖) = c := by ext n; exact abs_of_nonneg (pow_nonneg (by norm_num) _)
    rw [this]
    exact (tendsto_pow_atTop_atTop_of_one_lt (by norm_num)).comp (tendsto_add_at_top_nat 1)
  show Filter.Tendsto (fun n : ℕ => c n • d n) Filter.atTop (𝓝 (y - x))
  · have : (fun n : ℕ => c n • d n) = fun n => y - x :=
      by
      ext n
      simp only [d, smul_smul]
      rw [mul_inv_cancel, one_smul]
      exact pow_ne_zero _ (by norm_num)
    rw [this]
    apply tendsto_const_nhds
#align mem_tangent_cone_of_open_segment_subset mem_tangentCone_of_openSegment_subset
-/

#print mem_tangentCone_of_segment_subset /-
/-- If a subset of a real vector space contains a segment, then the direction of this
segment belongs to the tangent cone at its endpoints. -/
theorem mem_tangentCone_of_segment_subset {s : Set G} {x y : G} (h : segment ℝ x y ⊆ s) :
    y - x ∈ tangentConeAt ℝ s x :=
  mem_tangentCone_of_openSegment_subset ((openSegment_subset_segment ℝ x y).trans h)
#align mem_tangent_cone_of_segment_subset mem_tangentCone_of_segment_subset
-/

end TangentCone

section UniqueDiff

/-!
### Properties of `unique_diff_within_at` and `unique_diff_on`

This section is devoted to properties of the predicates
`unique_diff_within_at` and `unique_diff_on`. -/


#print UniqueDiffOn.uniqueDiffWithinAt /-
theorem UniqueDiffOn.uniqueDiffWithinAt {s : Set E} {x} (hs : UniqueDiffOn 𝕜 s) (h : x ∈ s) :
    UniqueDiffWithinAt 𝕜 s x :=
  hs x h
#align unique_diff_on.unique_diff_within_at UniqueDiffOn.uniqueDiffWithinAt
-/

#print uniqueDiffWithinAt_univ /-
theorem uniqueDiffWithinAt_univ : UniqueDiffWithinAt 𝕜 univ x := by
  rw [uniqueDiffWithinAt_iff, tangentCone_univ]; simp
#align unique_diff_within_at_univ uniqueDiffWithinAt_univ
-/

#print uniqueDiffOn_univ /-
theorem uniqueDiffOn_univ : UniqueDiffOn 𝕜 (univ : Set E) := fun x hx => uniqueDiffWithinAt_univ
#align unique_diff_on_univ uniqueDiffOn_univ
-/

#print uniqueDiffOn_empty /-
theorem uniqueDiffOn_empty : UniqueDiffOn 𝕜 (∅ : Set E) := fun x hx => hx.elim
#align unique_diff_on_empty uniqueDiffOn_empty
-/

#print UniqueDiffWithinAt.mono_nhds /-
theorem UniqueDiffWithinAt.mono_nhds (h : UniqueDiffWithinAt 𝕜 s x) (st : 𝓝[s] x ≤ 𝓝[t] x) :
    UniqueDiffWithinAt 𝕜 t x :=
  by
  simp only [uniqueDiffWithinAt_iff] at *
  rw [mem_closure_iff_nhdsWithin_neBot] at h ⊢
  exact ⟨h.1.mono <| Submodule.span_mono <| tangentCone_mono_nhds st, h.2.mono st⟩
#align unique_diff_within_at.mono_nhds UniqueDiffWithinAt.mono_nhds
-/

#print UniqueDiffWithinAt.mono /-
theorem UniqueDiffWithinAt.mono (h : UniqueDiffWithinAt 𝕜 s x) (st : s ⊆ t) :
    UniqueDiffWithinAt 𝕜 t x :=
  h.mono_nhds <| nhdsWithin_mono _ st
#align unique_diff_within_at.mono UniqueDiffWithinAt.mono
-/

#print uniqueDiffWithinAt_congr /-
theorem uniqueDiffWithinAt_congr (st : 𝓝[s] x = 𝓝[t] x) :
    UniqueDiffWithinAt 𝕜 s x ↔ UniqueDiffWithinAt 𝕜 t x :=
  ⟨fun h => h.mono_nhds <| le_of_eq st, fun h => h.mono_nhds <| le_of_eq st.symm⟩
#align unique_diff_within_at_congr uniqueDiffWithinAt_congr
-/

#print uniqueDiffWithinAt_inter /-
theorem uniqueDiffWithinAt_inter (ht : t ∈ 𝓝 x) :
    UniqueDiffWithinAt 𝕜 (s ∩ t) x ↔ UniqueDiffWithinAt 𝕜 s x :=
  uniqueDiffWithinAt_congr <| (nhdsWithin_restrict' _ ht).symm
#align unique_diff_within_at_inter uniqueDiffWithinAt_inter
-/

#print UniqueDiffWithinAt.inter /-
theorem UniqueDiffWithinAt.inter (hs : UniqueDiffWithinAt 𝕜 s x) (ht : t ∈ 𝓝 x) :
    UniqueDiffWithinAt 𝕜 (s ∩ t) x :=
  (uniqueDiffWithinAt_inter ht).2 hs
#align unique_diff_within_at.inter UniqueDiffWithinAt.inter
-/

#print uniqueDiffWithinAt_inter' /-
theorem uniqueDiffWithinAt_inter' (ht : t ∈ 𝓝[s] x) :
    UniqueDiffWithinAt 𝕜 (s ∩ t) x ↔ UniqueDiffWithinAt 𝕜 s x :=
  uniqueDiffWithinAt_congr <| (nhdsWithin_restrict'' _ ht).symm
#align unique_diff_within_at_inter' uniqueDiffWithinAt_inter'
-/

#print UniqueDiffWithinAt.inter' /-
theorem UniqueDiffWithinAt.inter' (hs : UniqueDiffWithinAt 𝕜 s x) (ht : t ∈ 𝓝[s] x) :
    UniqueDiffWithinAt 𝕜 (s ∩ t) x :=
  (uniqueDiffWithinAt_inter' ht).2 hs
#align unique_diff_within_at.inter' UniqueDiffWithinAt.inter'
-/

#print uniqueDiffWithinAt_of_mem_nhds /-
theorem uniqueDiffWithinAt_of_mem_nhds (h : s ∈ 𝓝 x) : UniqueDiffWithinAt 𝕜 s x := by
  simpa only [univ_inter] using unique_diff_within_at_univ.inter h
#align unique_diff_within_at_of_mem_nhds uniqueDiffWithinAt_of_mem_nhds
-/

#print IsOpen.uniqueDiffWithinAt /-
theorem IsOpen.uniqueDiffWithinAt (hs : IsOpen s) (xs : x ∈ s) : UniqueDiffWithinAt 𝕜 s x :=
  uniqueDiffWithinAt_of_mem_nhds (IsOpen.mem_nhds hs xs)
#align is_open.unique_diff_within_at IsOpen.uniqueDiffWithinAt
-/

#print UniqueDiffOn.inter /-
theorem UniqueDiffOn.inter (hs : UniqueDiffOn 𝕜 s) (ht : IsOpen t) : UniqueDiffOn 𝕜 (s ∩ t) :=
  fun x hx => (hs x hx.1).inter (IsOpen.mem_nhds ht hx.2)
#align unique_diff_on.inter UniqueDiffOn.inter
-/

#print IsOpen.uniqueDiffOn /-
theorem IsOpen.uniqueDiffOn (hs : IsOpen s) : UniqueDiffOn 𝕜 s := fun x hx =>
  IsOpen.uniqueDiffWithinAt hs hx
#align is_open.unique_diff_on IsOpen.uniqueDiffOn
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print UniqueDiffWithinAt.prod /-
/-- The product of two sets of unique differentiability at points `x` and `y` has unique
differentiability at `(x, y)`. -/
theorem UniqueDiffWithinAt.prod {t : Set F} {y : F} (hs : UniqueDiffWithinAt 𝕜 s x)
    (ht : UniqueDiffWithinAt 𝕜 t y) : UniqueDiffWithinAt 𝕜 (s ×ˢ t) (x, y) :=
  by
  rw [uniqueDiffWithinAt_iff] at hs ht ⊢
  rw [closure_prod_eq]
  refine' ⟨_, hs.2, ht.2⟩
  have : _ ≤ Submodule.span 𝕜 (tangentConeAt 𝕜 (s ×ˢ t) (x, y)) :=
    Submodule.span_mono
      (union_subset (subset_tangentCone_prod_left ht.2) (subset_tangentCone_prod_right hs.2))
  rw [LinearMap.span_inl_union_inr, SetLike.le_def] at this 
  exact (hs.1.Prod ht.1).mono this
#align unique_diff_within_at.prod UniqueDiffWithinAt.prod
-/

#print UniqueDiffWithinAt.univ_pi /-
theorem UniqueDiffWithinAt.univ_pi (ι : Type _) [Finite ι] (E : ι → Type _)
    [∀ i, NormedAddCommGroup (E i)] [∀ i, NormedSpace 𝕜 (E i)] (s : ∀ i, Set (E i)) (x : ∀ i, E i)
    (h : ∀ i, UniqueDiffWithinAt 𝕜 (s i) (x i)) : UniqueDiffWithinAt 𝕜 (Set.pi univ s) x := by
  classical
  simp only [uniqueDiffWithinAt_iff, closure_pi_set] at h ⊢
  refine' ⟨(dense_pi univ fun i _ => (h i).1).mono _, fun i _ => (h i).2⟩
  norm_cast
  simp only [← Submodule.iSup_map_single, iSup_le_iff, LinearMap.map_span, Submodule.span_le, ←
    maps_to']
  exact fun i => (mapsTo_tangentCone_pi fun j hj => (h j).2).mono subset.rfl Submodule.subset_span
#align unique_diff_within_at.univ_pi UniqueDiffWithinAt.univ_pi
-/

#print UniqueDiffWithinAt.pi /-
theorem UniqueDiffWithinAt.pi (ι : Type _) [Finite ι] (E : ι → Type _)
    [∀ i, NormedAddCommGroup (E i)] [∀ i, NormedSpace 𝕜 (E i)] (s : ∀ i, Set (E i)) (x : ∀ i, E i)
    (I : Set ι) (h : ∀ i ∈ I, UniqueDiffWithinAt 𝕜 (s i) (x i)) :
    UniqueDiffWithinAt 𝕜 (Set.pi I s) x := by
  classical
  rw [← Set.univ_pi_piecewise_univ]
  refine' UniqueDiffWithinAt.univ_pi _ _ _ _ fun i => _
  by_cases hi : i ∈ I <;> simp [*, uniqueDiffWithinAt_univ]
#align unique_diff_within_at.pi UniqueDiffWithinAt.pi
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print UniqueDiffOn.prod /-
/-- The product of two sets of unique differentiability is a set of unique differentiability. -/
theorem UniqueDiffOn.prod {t : Set F} (hs : UniqueDiffOn 𝕜 s) (ht : UniqueDiffOn 𝕜 t) :
    UniqueDiffOn 𝕜 (s ×ˢ t) := fun ⟨x, y⟩ h => UniqueDiffWithinAt.prod (hs x h.1) (ht y h.2)
#align unique_diff_on.prod UniqueDiffOn.prod
-/

#print UniqueDiffOn.pi /-
/-- The finite product of a family of sets of unique differentiability is a set of unique
differentiability. -/
theorem UniqueDiffOn.pi (ι : Type _) [Finite ι] (E : ι → Type _) [∀ i, NormedAddCommGroup (E i)]
    [∀ i, NormedSpace 𝕜 (E i)] (s : ∀ i, Set (E i)) (I : Set ι)
    (h : ∀ i ∈ I, UniqueDiffOn 𝕜 (s i)) : UniqueDiffOn 𝕜 (Set.pi I s) := fun x hx =>
  UniqueDiffWithinAt.pi _ _ _ _ _ fun i hi => h i hi (x i) (hx i hi)
#align unique_diff_on.pi UniqueDiffOn.pi
-/

#print UniqueDiffOn.univ_pi /-
/-- The finite product of a family of sets of unique differentiability is a set of unique
differentiability. -/
theorem UniqueDiffOn.univ_pi (ι : Type _) [Finite ι] (E : ι → Type _)
    [∀ i, NormedAddCommGroup (E i)] [∀ i, NormedSpace 𝕜 (E i)] (s : ∀ i, Set (E i))
    (h : ∀ i, UniqueDiffOn 𝕜 (s i)) : UniqueDiffOn 𝕜 (Set.pi univ s) :=
  UniqueDiffOn.pi _ _ _ _ fun i _ => h i
#align unique_diff_on.univ_pi UniqueDiffOn.univ_pi
-/

#print uniqueDiffWithinAt_convex /-
/-- In a real vector space, a convex set with nonempty interior is a set of unique
differentiability at every point of its closure. -/
theorem uniqueDiffWithinAt_convex {s : Set G} (conv : Convex ℝ s) (hs : (interior s).Nonempty)
    {x : G} (hx : x ∈ closure s) : UniqueDiffWithinAt ℝ s x :=
  by
  rcases hs with ⟨y, hy⟩
  suffices y - x ∈ interior (tangentConeAt ℝ s x)
    by
    refine' ⟨Dense.of_closure _, hx⟩
    simp [(Submodule.span ℝ (tangentConeAt ℝ s x)).eq_top_of_nonempty_interior'
        ⟨y - x, interior_mono Submodule.subset_span this⟩]
  rw [mem_interior_iff_mem_nhds]
  replace hy : interior s ∈ 𝓝 y := IsOpen.mem_nhds isOpen_interior hy
  apply mem_of_superset ((isOpenMap_sub_right x).image_mem_nhds hy)
  rintro _ ⟨z, zs, rfl⟩
  refine' mem_tangentCone_of_openSegment_subset (subset.trans _ interior_subset)
  exact conv.open_segment_closure_interior_subset_interior hx zs
#align unique_diff_within_at_convex uniqueDiffWithinAt_convex
-/

#print uniqueDiffOn_convex /-
/-- In a real vector space, a convex set with nonempty interior is a set of unique
differentiability. -/
theorem uniqueDiffOn_convex {s : Set G} (conv : Convex ℝ s) (hs : (interior s).Nonempty) :
    UniqueDiffOn ℝ s := fun x xs => uniqueDiffWithinAt_convex conv hs (subset_closure xs)
#align unique_diff_on_convex uniqueDiffOn_convex
-/

#print uniqueDiffOn_Ici /-
theorem uniqueDiffOn_Ici (a : ℝ) : UniqueDiffOn ℝ (Ici a) :=
  uniqueDiffOn_convex (convex_Ici a) <| by simp only [interior_Ici, nonempty_Ioi]
#align unique_diff_on_Ici uniqueDiffOn_Ici
-/

#print uniqueDiffOn_Iic /-
theorem uniqueDiffOn_Iic (a : ℝ) : UniqueDiffOn ℝ (Iic a) :=
  uniqueDiffOn_convex (convex_Iic a) <| by simp only [interior_Iic, nonempty_Iio]
#align unique_diff_on_Iic uniqueDiffOn_Iic
-/

#print uniqueDiffOn_Ioi /-
theorem uniqueDiffOn_Ioi (a : ℝ) : UniqueDiffOn ℝ (Ioi a) :=
  isOpen_Ioi.UniqueDiffOn
#align unique_diff_on_Ioi uniqueDiffOn_Ioi
-/

#print uniqueDiffOn_Iio /-
theorem uniqueDiffOn_Iio (a : ℝ) : UniqueDiffOn ℝ (Iio a) :=
  isOpen_Iio.UniqueDiffOn
#align unique_diff_on_Iio uniqueDiffOn_Iio
-/

#print uniqueDiffOn_Icc /-
theorem uniqueDiffOn_Icc {a b : ℝ} (hab : a < b) : UniqueDiffOn ℝ (Icc a b) :=
  uniqueDiffOn_convex (convex_Icc a b) <| by simp only [interior_Icc, nonempty_Ioo, hab]
#align unique_diff_on_Icc uniqueDiffOn_Icc
-/

#print uniqueDiffOn_Ico /-
theorem uniqueDiffOn_Ico (a b : ℝ) : UniqueDiffOn ℝ (Ico a b) :=
  if hab : a < b then
    uniqueDiffOn_convex (convex_Ico a b) <| by simp only [interior_Ico, nonempty_Ioo, hab]
  else by simp only [Ico_eq_empty hab, uniqueDiffOn_empty]
#align unique_diff_on_Ico uniqueDiffOn_Ico
-/

#print uniqueDiffOn_Ioc /-
theorem uniqueDiffOn_Ioc (a b : ℝ) : UniqueDiffOn ℝ (Ioc a b) :=
  if hab : a < b then
    uniqueDiffOn_convex (convex_Ioc a b) <| by simp only [interior_Ioc, nonempty_Ioo, hab]
  else by simp only [Ioc_eq_empty hab, uniqueDiffOn_empty]
#align unique_diff_on_Ioc uniqueDiffOn_Ioc
-/

#print uniqueDiffOn_Ioo /-
theorem uniqueDiffOn_Ioo (a b : ℝ) : UniqueDiffOn ℝ (Ioo a b) :=
  isOpen_Ioo.UniqueDiffOn
#align unique_diff_on_Ioo uniqueDiffOn_Ioo
-/

#print uniqueDiffOn_Icc_zero_one /-
/-- The real interval `[0, 1]` is a set of unique differentiability. -/
theorem uniqueDiffOn_Icc_zero_one : UniqueDiffOn ℝ (Icc (0 : ℝ) 1) :=
  uniqueDiffOn_Icc zero_lt_one
#align unique_diff_on_Icc_zero_one uniqueDiffOn_Icc_zero_one
-/

#print uniqueDiffWithinAt_Ioo /-
theorem uniqueDiffWithinAt_Ioo {a b t : ℝ} (ht : t ∈ Set.Ioo a b) :
    UniqueDiffWithinAt ℝ (Set.Ioo a b) t :=
  IsOpen.uniqueDiffWithinAt isOpen_Ioo ht
#align unique_diff_within_at_Ioo uniqueDiffWithinAt_Ioo
-/

#print uniqueDiffWithinAt_Ioi /-
theorem uniqueDiffWithinAt_Ioi (a : ℝ) : UniqueDiffWithinAt ℝ (Ioi a) a :=
  uniqueDiffWithinAt_convex (convex_Ioi a) (by simp) (by simp)
#align unique_diff_within_at_Ioi uniqueDiffWithinAt_Ioi
-/

#print uniqueDiffWithinAt_Iio /-
theorem uniqueDiffWithinAt_Iio (a : ℝ) : UniqueDiffWithinAt ℝ (Iio a) a :=
  uniqueDiffWithinAt_convex (convex_Iio a) (by simp) (by simp)
#align unique_diff_within_at_Iio uniqueDiffWithinAt_Iio
-/

end UniqueDiff

