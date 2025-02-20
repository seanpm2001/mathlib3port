/-
Copyright (c) 2022 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Heather Macbeth

! This file was ported from Lean 3 source module geometry.manifold.vector_bundle.tangent
! leanprover-community/mathlib commit 30faa0c3618ce1472bf6305ae0e3fa56affa3f95
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Manifold.VectorBundle.Basic

/-! # Tangent bundles

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the tangent bundle as a smooth vector bundle.

Let `M` be a smooth manifold with corners with model `I` on `(E, H)`. We define the tangent bundle
of `M` using the `vector_bundle_core` construction indexed by the charts of `M` with fibers `E`.
Given two charts `i, j : local_homeomorph M H`, the coordinate change between `i` and `j` at a point
`x : M` is the derivative of the composite
```
  I.symm   i.symm    j     I
E -----> H -----> M --> H --> E
```
within the set `range I ⊆ E` at `I (i x) : E`.
This defines a smooth vector bundle `tangent_bundle` with fibers `tangent_space`.

## Main definitions

* `tangent_space I M x` is the fiber of the tangent bundle at `x : M`, which is defined to be `E`.

* `tangent_bundle I M` is the total space of `tangent_space I M`, proven to be a smooth vector
  bundle.
-/


open Bundle Set SmoothManifoldWithCorners LocalHomeomorph ContinuousLinearMap

open scoped Manifold Topology Bundle

noncomputable section

section General

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] {E' : Type _} [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H : Type _}
  [TopologicalSpace H] {I : ModelWithCorners 𝕜 E H} {H' : Type _} [TopologicalSpace H']
  {I' : ModelWithCorners 𝕜 E' H'} {M : Type _} [TopologicalSpace M] [ChartedSpace H M]
  [SmoothManifoldWithCorners I M] {M' : Type _} [TopologicalSpace M'] [ChartedSpace H' M']
  [SmoothManifoldWithCorners I' M'] {F : Type _} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable (I)

#print contDiffOn_fderiv_coord_change /-
/-- Auxiliary lemma for tangent spaces: the derivative of a coordinate change between two charts is
  smooth on its source. -/
theorem contDiffOn_fderiv_coord_change (i j : atlas H M) :
    ContDiffOn 𝕜 ∞ (fderivWithin 𝕜 (j.1.extend I ∘ (i.1.extend I).symm) (range I))
      ((i.1.extend I).symm ≫ j.1.extend I).source :=
  by
  have h : ((i.1.extend I).symm ≫ j.1.extend I).source ⊆ range I := by
    rw [i.1.extend_coord_change_source]; apply image_subset_range
  intro x hx
  refine' (ContDiffWithinAt.fderivWithin_right _ I.unique_diff le_top <| h hx).mono h
  refine'
    (LocalHomeomorph.contDiffOn_extend_coord_change I (subset_maximal_atlas I j.2)
          (subset_maximal_atlas I i.2) x hx).mono_of_mem
      _
  exact i.1.extend_coord_change_source_mem_nhdsWithin j.1 I hx
#align cont_diff_on_fderiv_coord_change contDiffOn_fderiv_coord_change
-/

variable (M)

open SmoothManifoldWithCorners

#print tangentBundleCore /-
/-- Let `M` be a smooth manifold with corners with model `I` on `(E, H)`.
Then `vector_bundle_core I M` is the vector bundle core for the tangent bundle over `M`.
It is indexed by the atlas of `M`, with fiber `E` and its change of coordinates from the chart `i`
to the chart `j` at point `x : M` is the derivative of the composite
```
  I.symm   i.symm    j     I
E -----> H -----> M --> H --> E
```
within the set `range I ⊆ E` at `I (i x) : E`. -/
@[simps]
def tangentBundleCore : VectorBundleCore 𝕜 M E (atlas H M)
    where
  baseSet i := i.1.source
  isOpen_baseSet i := i.1.open_source
  indexAt := achart H
  mem_baseSet_at := mem_chart_source H
  coordChange i j x :=
    fderivWithin 𝕜 (j.1.extend I ∘ (i.1.extend I).symm) (range I) (i.1.extend I x)
  coordChange_self i x hx v :=
    by
    rw [Filter.EventuallyEq.fderivWithin_eq, fderivWithin_id', ContinuousLinearMap.id_apply]
    · exact I.unique_diff_at_image
    · filter_upwards [i.1.extend_target_mem_nhdsWithin I hx] with y hy
      exact (i.1.extend I).right_inv hy
    · simp_rw [Function.comp_apply, i.1.extend_left_inv I hx]
  continuousOn_coordChange i j :=
    by
    refine'
      (contDiffOn_fderiv_coord_change I i j).ContinuousOn.comp ((i.1.continuousOn_extend I).mono _)
        _
    · rw [i.1.extend_source]; exact inter_subset_left _ _
    simp_rw [← i.1.extend_image_source_inter, maps_to_image]
  coordChange_comp := by
    rintro i j k x ⟨⟨hxi, hxj⟩, hxk⟩ v
    rw [fderivWithin_fderivWithin, Filter.EventuallyEq.fderivWithin_eq]
    · have := i.1.extend_preimage_mem_nhds I hxi (j.1.extend_source_mem_nhds I hxj)
      filter_upwards [nhdsWithin_le_nhds this] with y hy
      simp_rw [Function.comp_apply, (j.1.extend I).left_inv hy]
    · simp_rw [Function.comp_apply, i.1.extend_left_inv I hxi, j.1.extend_left_inv I hxj]
    ·
      exact
        (cont_diff_within_at_extend_coord_change' I (subset_maximal_atlas I k.2)
              (subset_maximal_atlas I j.2) hxk hxj).DifferentiableWithinAt
          le_top
    ·
      exact
        (cont_diff_within_at_extend_coord_change' I (subset_maximal_atlas I j.2)
              (subset_maximal_atlas I i.2) hxj hxi).DifferentiableWithinAt
          le_top
    · intro x hx; exact mem_range_self _
    · exact I.unique_diff_at_image
    · rw [Function.comp_apply, i.1.extend_left_inv I hxi]
#align tangent_bundle_core tangentBundleCore
-/

variable {M}

#print tangentBundleCore_coordChange_achart /-
theorem tangentBundleCore_coordChange_achart (x x' z : M) :
    (tangentBundleCore I M).coordChange (achart H x) (achart H x') z =
      fderivWithin 𝕜 (extChartAt I x' ∘ (extChartAt I x).symm) (range I) (extChartAt I x z) :=
  rfl
#align tangent_bundle_core_coord_change_achart tangentBundleCore_coordChange_achart
-/

#print TangentSpace /-
/-- The tangent space at a point of the manifold `M`. It is just `E`. We could use instead
`(tangent_bundle_core I M).to_topological_vector_bundle_core.fiber x`, but we use `E` to help the
kernel.
-/
@[nolint unused_arguments]
def TangentSpace (x : M) : Type _ :=
  E
deriving TopologicalSpace, AddCommGroup, TopologicalAddGroup
#align tangent_space TangentSpace
-/

variable (M)

#print TangentBundle /-
-- is empty if the base manifold is empty
/-- The tangent bundle to a smooth manifold, as a Sigma type. Defined in terms of
`bundle.total_space` to be able to put a suitable topology on it. -/
@[nolint has_nonempty_instance, reducible]
def TangentBundle :=
  Bundle.TotalSpace (TangentSpace I : M → Type _)
#align tangent_bundle TangentBundle
-/

local notation "TM" => TangentBundle I M

section TangentBundleInstances

/- In general, the definition of tangent_space is not reducible, so that type class inference
does not pick wrong instances. In this section, we record the right instances for
them, noting in particular that the tangent bundle is a smooth manifold. -/
section

variable {M} (x : M)

instance : Module 𝕜 (TangentSpace I x) := by delta_instance tangent_space

instance : Inhabited (TangentSpace I x) :=
  ⟨0⟩

instance {x : M} : ContinuousAdd (TangentSpace I x) := by delta_instance tangent_space

end

instance : TopologicalSpace TM :=
  (tangentBundleCore I M).toTopologicalSpace

instance : FiberBundle E (TangentSpace I : M → Type _) :=
  (tangentBundleCore I M).FiberBundle

instance : VectorBundle 𝕜 E (TangentSpace I : M → Type _) :=
  (tangentBundleCore I M).VectorBundle

namespace TangentBundle

#print TangentBundle.chartAt /-
protected theorem chartAt (p : TM) :
    chartAt (ModelProd H E) p =
      ((tangentBundleCore I M).toFiberBundleCore.localTriv (achart H p.1)).toLocalHomeomorph ≫ₕ
        (chartAt H p.1).Prod (LocalHomeomorph.refl E) :=
  rfl
#align tangent_bundle.chart_at TangentBundle.chartAt
-/

#print TangentBundle.chartAt_toLocalEquiv /-
theorem chartAt_toLocalEquiv (p : TM) :
    (chartAt (ModelProd H E) p).toLocalEquiv =
      (tangentBundleCore I M).toFiberBundleCore.localTrivAsLocalEquiv (achart H p.1) ≫
        (chartAt H p.1).toLocalEquiv.Prod (LocalEquiv.refl E) :=
  rfl
#align tangent_bundle.chart_at_to_local_equiv TangentBundle.chartAt_toLocalEquiv
-/

#print TangentBundle.trivializationAt_eq_localTriv /-
theorem trivializationAt_eq_localTriv (x : M) :
    trivializationAt E (TangentSpace I) x =
      (tangentBundleCore I M).toFiberBundleCore.localTriv (achart H x) :=
  rfl
#align tangent_bundle.trivialization_at_eq_local_triv TangentBundle.trivializationAt_eq_localTriv
-/

#print TangentBundle.trivializationAt_source /-
@[simp, mfld_simps]
theorem trivializationAt_source (x : M) :
    (trivializationAt E (TangentSpace I) x).source = π _ ⁻¹' (chartAt H x).source :=
  rfl
#align tangent_bundle.trivialization_at_source TangentBundle.trivializationAt_source
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print TangentBundle.trivializationAt_target /-
@[simp, mfld_simps]
theorem trivializationAt_target (x : M) :
    (trivializationAt E (TangentSpace I) x).target = (chartAt H x).source ×ˢ univ :=
  rfl
#align tangent_bundle.trivialization_at_target TangentBundle.trivializationAt_target
-/

#print TangentBundle.trivializationAt_baseSet /-
@[simp, mfld_simps]
theorem trivializationAt_baseSet (x : M) :
    (trivializationAt E (TangentSpace I) x).baseSet = (chartAt H x).source :=
  rfl
#align tangent_bundle.trivialization_at_base_set TangentBundle.trivializationAt_baseSet
-/

#print TangentBundle.trivializationAt_apply /-
theorem trivializationAt_apply (x : M) (z : TM) :
    trivializationAt E (TangentSpace I) x z =
      (z.1,
        fderivWithin 𝕜 ((chartAt H x).extend I ∘ ((chartAt H z.1).extend I).symm) (range I)
          ((chartAt H z.1).extend I z.1) z.2) :=
  rfl
#align tangent_bundle.trivialization_at_apply TangentBundle.trivializationAt_apply
-/

#print TangentBundle.trivializationAt_fst /-
@[simp, mfld_simps]
theorem trivializationAt_fst (x : M) (z : TM) : (trivializationAt E (TangentSpace I) x z).1 = z.1 :=
  rfl
#align tangent_bundle.trivialization_at_fst TangentBundle.trivializationAt_fst
-/

#print TangentBundle.mem_chart_source_iff /-
@[simp, mfld_simps]
theorem mem_chart_source_iff (p q : TM) :
    p ∈ (chartAt (ModelProd H E) q).source ↔ p.1 ∈ (chartAt H q.1).source := by
  simp only [FiberBundle.chartedSpace_chartAt, mfld_simps]
#align tangent_bundle.mem_chart_source_iff TangentBundle.mem_chart_source_iff
-/

#print TangentBundle.mem_chart_target_iff /-
@[simp, mfld_simps]
theorem mem_chart_target_iff (p : H × E) (q : TM) :
    p ∈ (chartAt (ModelProd H E) q).target ↔ p.1 ∈ (chartAt H q.1).target := by
  simp (config := { contextual := true }) only [FiberBundle.chartedSpace_chartAt,
    and_iff_left_iff_imp, mfld_simps]
#align tangent_bundle.mem_chart_target_iff TangentBundle.mem_chart_target_iff
-/

#print TangentBundle.coe_chartAt_fst /-
@[simp, mfld_simps]
theorem coe_chartAt_fst (p q : TM) : ((chartAt (ModelProd H E) q) p).1 = chartAt H q.1 p.1 :=
  rfl
#align tangent_bundle.coe_chart_at_fst TangentBundle.coe_chartAt_fst
-/

#print TangentBundle.coe_chartAt_symm_fst /-
@[simp, mfld_simps]
theorem coe_chartAt_symm_fst (p : H × E) (q : TM) :
    ((chartAt (ModelProd H E) q).symm p).1 = ((chartAt H q.1).symm : H → M) p.1 :=
  rfl
#align tangent_bundle.coe_chart_at_symm_fst TangentBundle.coe_chartAt_symm_fst
-/

#print TangentBundle.trivializationAt_continuousLinearMapAt /-
@[simp, mfld_simps]
theorem trivializationAt_continuousLinearMapAt {b₀ b : M}
    (hb : b ∈ (trivializationAt E (TangentSpace I) b₀).baseSet) :
    (trivializationAt E (TangentSpace I) b₀).continuousLinearMapAt 𝕜 b =
      (tangentBundleCore I M).coordChange (achart H b) (achart H b₀) b :=
  (tangentBundleCore I M).localTriv_continuousLinearMapAt hb
#align tangent_bundle.trivialization_at_continuous_linear_map_at TangentBundle.trivializationAt_continuousLinearMapAt
-/

#print TangentBundle.trivializationAt_symmL /-
@[simp, mfld_simps]
theorem trivializationAt_symmL {b₀ b : M}
    (hb : b ∈ (trivializationAt E (TangentSpace I) b₀).baseSet) :
    (trivializationAt E (TangentSpace I) b₀).symmL 𝕜 b =
      (tangentBundleCore I M).coordChange (achart H b₀) (achart H b) b :=
  (tangentBundleCore I M).localTriv_symmL hb
#align tangent_bundle.trivialization_at_symmL TangentBundle.trivializationAt_symmL
-/

#print TangentBundle.coordChange_model_space /-
@[simp, mfld_simps]
theorem coordChange_model_space (b b' x : F) :
    (tangentBundleCore 𝓘(𝕜, F) F).coordChange (achart F b) (achart F b') x = 1 := by
  simpa only [tangentBundleCore_coordChange, mfld_simps] using
    fderivWithin_id uniqueDiffWithinAt_univ
#align tangent_bundle.coord_change_model_space TangentBundle.coordChange_model_space
-/

#print TangentBundle.symmL_model_space /-
@[simp, mfld_simps]
theorem symmL_model_space (b b' : F) :
    (trivializationAt F (TangentSpace 𝓘(𝕜, F)) b).symmL 𝕜 b' = (1 : F →L[𝕜] F) :=
  by
  rw [TangentBundle.trivializationAt_symmL, coord_change_model_space]
  apply mem_univ
#align tangent_bundle.symmL_model_space TangentBundle.symmL_model_space
-/

#print TangentBundle.continuousLinearMapAt_model_space /-
@[simp, mfld_simps]
theorem continuousLinearMapAt_model_space (b b' : F) :
    (trivializationAt F (TangentSpace 𝓘(𝕜, F)) b).continuousLinearMapAt 𝕜 b' = (1 : F →L[𝕜] F) :=
  by
  rw [TangentBundle.trivializationAt_continuousLinearMapAt, coord_change_model_space]
  apply mem_univ
#align tangent_bundle.continuous_linear_map_at_model_space TangentBundle.continuousLinearMapAt_model_space
-/

end TangentBundle

#print tangentBundleCore.isSmooth /-
instance tangentBundleCore.isSmooth : (tangentBundleCore I M).IsSmooth I :=
  by
  refine' ⟨fun i j => _⟩
  rw [SmoothOn, contMDiffOn_iff_source_of_mem_maximalAtlas (subset_maximal_atlas I i.2),
    contMDiffOn_iff_contDiffOn]
  refine' ((contDiffOn_fderiv_coord_change I i j).congr fun x hx => _).mono _
  · rw [LocalEquiv.trans_source'] at hx 
    simp_rw [Function.comp_apply, tangentBundleCore_coordChange, (i.1.extend I).right_inv hx.1]
  · exact (i.1.extend_image_source_inter j.1 I).Subset
  · apply inter_subset_left
#align tangent_bundle_core.is_smooth tangentBundleCore.isSmooth
-/

#print TangentBundle.smoothVectorBundle /-
instance TangentBundle.smoothVectorBundle : SmoothVectorBundle E (TangentSpace I : M → Type _) I :=
  (tangentBundleCore I M).SmoothVectorBundle _
#align tangent_bundle.smooth_vector_bundle TangentBundle.smoothVectorBundle
-/

end TangentBundleInstances

/-! ## The tangent bundle to the model space -/


#print tangentBundle_model_space_chartAt /-
/-- In the tangent bundle to the model space, the charts are just the canonical identification
between a product type and a sigma type, a.k.a. `equiv.sigma_equiv_prod`. -/
@[simp, mfld_simps]
theorem tangentBundle_model_space_chartAt (p : TangentBundle I H) :
    (chartAt (ModelProd H E) p).toLocalEquiv = (Equiv.sigmaEquivProd H E).toLocalEquiv :=
  by
  ext x : 1
  · ext; · rfl
    exact (tangentBundleCore I H).coordChange_self (achart _ x.1) x.1 (mem_achart_source H x.1) x.2
  · intro x; ext; · rfl; apply hEq_of_eq
    exact (tangentBundleCore I H).coordChange_self (achart _ x.1) x.1 (mem_achart_source H x.1) x.2
  simp_rw [TangentBundle.chartAt, FiberBundleCore.localTriv, FiberBundleCore.localTrivAsLocalEquiv,
    VectorBundleCore.toFiberBundleCore_baseSet, tangentBundleCore_baseSet]
  simp only [mfld_simps]
#align tangent_bundle_model_space_chart_at tangentBundle_model_space_chartAt
-/

#print tangentBundle_model_space_coe_chartAt /-
@[simp, mfld_simps]
theorem tangentBundle_model_space_coe_chartAt (p : TangentBundle I H) :
    ⇑(chartAt (ModelProd H E) p) = Equiv.sigmaEquivProd H E := by unfold_coes;
  simp_rw [tangentBundle_model_space_chartAt]; rfl
#align tangent_bundle_model_space_coe_chart_at tangentBundle_model_space_coe_chartAt
-/

#print tangentBundle_model_space_coe_chartAt_symm /-
@[simp, mfld_simps]
theorem tangentBundle_model_space_coe_chartAt_symm (p : TangentBundle I H) :
    ((chartAt (ModelProd H E) p).symm : ModelProd H E → TangentBundle I H) =
      (Equiv.sigmaEquivProd H E).symm :=
  by
  unfold_coes
  simp_rw [LocalHomeomorph.symm_toLocalEquiv, tangentBundle_model_space_chartAt]; rfl
#align tangent_bundle_model_space_coe_chart_at_symm tangentBundle_model_space_coe_chartAt_symm
-/

#print tangentBundleCore_coordChange_model_space /-
theorem tangentBundleCore_coordChange_model_space (x x' z : H) :
    (tangentBundleCore I H).coordChange (achart H x) (achart H x') z = ContinuousLinearMap.id 𝕜 E :=
  by ext v; exact (tangentBundleCore I H).coordChange_self (achart _ z) z (mem_univ _) v
#align tangent_bundle_core_coord_change_model_space tangentBundleCore_coordChange_model_space
-/

variable (H)

#print tangentBundleModelSpaceHomeomorph /-
/-- The canonical identification between the tangent bundle to the model space and the product,
as a homeomorphism -/
def tangentBundleModelSpaceHomeomorph : TangentBundle I H ≃ₜ ModelProd H E :=
  {
    Equiv.sigmaEquivProd H
      E with
    continuous_toFun := by
      let p : TangentBundle I H := ⟨I.symm (0 : E), (0 : E)⟩
      have : Continuous (chart_at (ModelProd H E) p) :=
        by
        rw [continuous_iff_continuousOn_univ]
        convert LocalHomeomorph.continuousOn _
        simp only [TangentSpace.fiberBundle, mfld_simps]
      simpa only [mfld_simps] using this
    continuous_invFun :=
      by
      let p : TangentBundle I H := ⟨I.symm (0 : E), (0 : E)⟩
      have : Continuous (chart_at (ModelProd H E) p).symm :=
        by
        rw [continuous_iff_continuousOn_univ]
        convert LocalHomeomorph.continuousOn _
        simp only [mfld_simps]
      simpa only [mfld_simps] using this }
#align tangent_bundle_model_space_homeomorph tangentBundleModelSpaceHomeomorph
-/

#print tangentBundleModelSpaceHomeomorph_coe /-
@[simp, mfld_simps]
theorem tangentBundleModelSpaceHomeomorph_coe :
    (tangentBundleModelSpaceHomeomorph H I : TangentBundle I H → ModelProd H E) =
      Equiv.sigmaEquivProd H E :=
  rfl
#align tangent_bundle_model_space_homeomorph_coe tangentBundleModelSpaceHomeomorph_coe
-/

#print tangentBundleModelSpaceHomeomorph_coe_symm /-
@[simp, mfld_simps]
theorem tangentBundleModelSpaceHomeomorph_coe_symm :
    ((tangentBundleModelSpaceHomeomorph H I).symm : ModelProd H E → TangentBundle I H) =
      (Equiv.sigmaEquivProd H E).symm :=
  rfl
#align tangent_bundle_model_space_homeomorph_coe_symm tangentBundleModelSpaceHomeomorph_coe_symm
-/

section inTangentCoordinates

variable (I I') {M M' H H'} {N : Type _}

#print inCoordinates_tangent_bundle_core_model_space /-
/-- The map `in_coordinates` for the tangent bundle is trivial on the model spaces -/
theorem inCoordinates_tangent_bundle_core_model_space (x₀ x : H) (y₀ y : H') (ϕ : E →L[𝕜] E') :
    inCoordinates E (TangentSpace I) E' (TangentSpace I') x₀ x y₀ y ϕ = ϕ :=
  by
  refine' (vector_bundle_core.in_coordinates_eq _ _ _ _ _).trans _
  · exact mem_univ x
  · exact mem_univ y
  simp_rw [tangentBundleCore_indexAt, tangentBundleCore_coordChange_model_space,
    ContinuousLinearMap.id_comp, ContinuousLinearMap.comp_id]
#align in_coordinates_tangent_bundle_core_model_space inCoordinates_tangent_bundle_core_model_space
-/

#print inTangentCoordinates /-
/-- When `ϕ x` is a continuous linear map that changes vectors in charts around `f x` to vectors
in charts around `g x`, `in_tangent_coordinates I I' f g ϕ x₀ x` is a coordinate change of
this continuous linear map that makes sense from charts around `f x₀` to charts around `g x₀`
by composing it with appropriate coordinate changes.
Note that the type of `ϕ` is more accurately
`Π x : N, tangent_space I (f x) →L[𝕜] tangent_space I' (g x)`.
We are unfolding `tangent_space` in this type so that Lean recognizes that the type of `ϕ` doesn't
actually depend on `f` or `g`.

This is the underlying function of the trivializations of the hom of (pullbacks of) tangent spaces.
-/
def inTangentCoordinates (f : N → M) (g : N → M') (ϕ : N → E →L[𝕜] E') : N → N → E →L[𝕜] E' :=
  fun x₀ x => inCoordinates E (TangentSpace I) E' (TangentSpace I') (f x₀) (f x) (g x₀) (g x) (ϕ x)
#align in_tangent_coordinates inTangentCoordinates
-/

#print inTangentCoordinates_model_space /-
theorem inTangentCoordinates_model_space (f : N → H) (g : N → H') (ϕ : N → E →L[𝕜] E') (x₀ : N) :
    inTangentCoordinates I I' f g ϕ x₀ = ϕ := by
  simp_rw [inTangentCoordinates, inCoordinates_tangent_bundle_core_model_space]
#align in_tangent_coordinates_model_space inTangentCoordinates_model_space
-/

#print inTangentCoordinates_eq /-
theorem inTangentCoordinates_eq (f : N → M) (g : N → M') (ϕ : N → E →L[𝕜] E') {x₀ x : N}
    (hx : f x ∈ (chartAt H (f x₀)).source) (hy : g x ∈ (chartAt H' (g x₀)).source) :
    inTangentCoordinates I I' f g ϕ x₀ x =
      (tangentBundleCore I' M').coordChange (achart H' (g x)) (achart H' (g x₀)) (g x) ∘L
        ϕ x ∘L (tangentBundleCore I M).coordChange (achart H (f x₀)) (achart H (f x)) (f x) :=
  (tangentBundleCore I M).inCoordinates_eq (tangentBundleCore I' M') (ϕ x) hx hy
#align in_tangent_coordinates_eq inTangentCoordinates_eq
-/

end inTangentCoordinates

end General

section Real

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] {H : Type _} [TopologicalSpace H]
  {I : ModelWithCorners ℝ E H} {M : Type _} [TopologicalSpace M] [ChartedSpace H M]
  [SmoothManifoldWithCorners I M]

instance {x : M} : PathConnectedSpace (TangentSpace I x) := by delta_instance tangent_space

end Real

