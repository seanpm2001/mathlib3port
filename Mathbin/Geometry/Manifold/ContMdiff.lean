/-
Copyright (c) 2020 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Floris van Doorn

! This file was ported from Lean 3 source module geometry.manifold.cont_mdiff
! leanprover-community/mathlib commit 30faa0c3618ce1472bf6305ae0e3fa56affa3f95
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Manifold.SmoothManifoldWithCorners
import Mathbin.Geometry.Manifold.LocalInvariantProperties

/-!
# Smooth functions between smooth manifolds

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define `Cⁿ` functions between smooth manifolds, as functions which are `Cⁿ` in charts, and prove
basic properties of these notions.

## Main definitions and statements

Let `M ` and `M'` be two smooth manifolds, with respect to model with corners `I` and `I'`. Let
`f : M → M'`.

* `cont_mdiff_within_at I I' n f s x` states that the function `f` is `Cⁿ` within the set `s`
  around the point `x`.
* `cont_mdiff_at I I' n f x` states that the function `f` is `Cⁿ` around `x`.
* `cont_mdiff_on I I' n f s` states that the function `f` is `Cⁿ` on the set `s`
* `cont_mdiff I I' n f` states that the function `f` is `Cⁿ`.
* `cont_mdiff_on.comp` gives the invariance of the `Cⁿ` property under composition
* `cont_mdiff_iff_cont_diff` states that, for functions between vector spaces,
  manifold-smoothness is equivalent to usual smoothness.

We also give many basic properties of smooth functions between manifolds, following the API of
smooth functions between vector spaces.

## Implementation details

Many properties follow for free from the corresponding properties of functions in vector spaces,
as being `Cⁿ` is a local property invariant under the smooth groupoid. We take advantage of the
general machinery developed in `local_invariant_properties.lean` to get these properties
automatically. For instance, the fact that being `Cⁿ` does not depend on the chart one considers
is given by `lift_prop_within_at_indep_chart`.

For this to work, the definition of `cont_mdiff_within_at` and friends has to
follow definitionally the setup of local invariant properties. Still, we recast the definition
in terms of extended charts in `cont_mdiff_on_iff` and `cont_mdiff_iff`.
-/


open Set Function Filter ChartedSpace SmoothManifoldWithCorners

open scoped Topology Manifold

/-! ### Definition of smooth functions between manifolds -/


variable {𝕜 : Type _} [NontriviallyNormedField 𝕜]
  -- declare a smooth manifold `M` over the pair `(E, H)`.
  {E : Type _}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] {H : Type _} [TopologicalSpace H]
  (I : ModelWithCorners 𝕜 E H) {M : Type _} [TopologicalSpace M] [ChartedSpace H M]
  [Is : SmoothManifoldWithCorners I M]
  -- declare a smooth manifold `M'` over the pair `(E', H')`.
  {E' : Type _}
  [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H' : Type _} [TopologicalSpace H']
  (I' : ModelWithCorners 𝕜 E' H') {M' : Type _} [TopologicalSpace M'] [ChartedSpace H' M']
  [I's : SmoothManifoldWithCorners I' M']
  -- declare a manifold `M''` over the pair `(E'', H'')`.
  {E'' : Type _}
  [NormedAddCommGroup E''] [NormedSpace 𝕜 E''] {H'' : Type _} [TopologicalSpace H'']
  {I'' : ModelWithCorners 𝕜 E'' H''} {M'' : Type _} [TopologicalSpace M''] [ChartedSpace H'' M'']
  -- declare a smooth manifold `N` over the pair `(F, G)`.
  {F : Type _}
  [NormedAddCommGroup F] [NormedSpace 𝕜 F] {G : Type _} [TopologicalSpace G]
  {J : ModelWithCorners 𝕜 F G} {N : Type _} [TopologicalSpace N] [ChartedSpace G N]
  [Js : SmoothManifoldWithCorners J N]
  -- declare a smooth manifold `N'` over the pair `(F', G')`.
  {F' : Type _}
  [NormedAddCommGroup F'] [NormedSpace 𝕜 F'] {G' : Type _} [TopologicalSpace G']
  {J' : ModelWithCorners 𝕜 F' G'} {N' : Type _} [TopologicalSpace N'] [ChartedSpace G' N']
  [J's : SmoothManifoldWithCorners J' N']
  -- F₁, F₂, F₃, F₄ are normed spaces
  {F₁ : Type _}
  [NormedAddCommGroup F₁] [NormedSpace 𝕜 F₁] {F₂ : Type _} [NormedAddCommGroup F₂]
  [NormedSpace 𝕜 F₂] {F₃ : Type _} [NormedAddCommGroup F₃] [NormedSpace 𝕜 F₃] {F₄ : Type _}
  [NormedAddCommGroup F₄] [NormedSpace 𝕜 F₄]
  -- declare functions, sets, points and smoothness indices
  {e : LocalHomeomorph M H}
  {e' : LocalHomeomorph M' H'} {f f₁ : M → M'} {s s₁ t : Set M} {x : M} {m n : ℕ∞}

#print ContDiffWithinAtProp /-
/-- Property in the model space of a model with corners of being `C^n` within at set at a point,
when read in the model vector space. This property will be lifted to manifolds to define smooth
functions between manifolds. -/
def ContDiffWithinAtProp (n : ℕ∞) (f : H → H') (s : Set H) (x : H) : Prop :=
  ContDiffWithinAt 𝕜 n (I' ∘ f ∘ I.symm) (I.symm ⁻¹' s ∩ range I) (I x)
#align cont_diff_within_at_prop ContDiffWithinAtProp
-/

#print contDiffWithinAtProp_self_source /-
theorem contDiffWithinAtProp_self_source {f : E → H'} {s : Set E} {x : E} :
    ContDiffWithinAtProp 𝓘(𝕜, E) I' n f s x ↔ ContDiffWithinAt 𝕜 n (I' ∘ f) s x :=
  by
  simp_rw [ContDiffWithinAtProp, modelWithCornersSelf_coe, range_id, inter_univ]
  rfl
#align cont_diff_within_at_prop_self_source contDiffWithinAtProp_self_source
-/

#print contDiffWithinAtProp_self /-
theorem contDiffWithinAtProp_self {f : E → E'} {s : Set E} {x : E} :
    ContDiffWithinAtProp 𝓘(𝕜, E) 𝓘(𝕜, E') n f s x ↔ ContDiffWithinAt 𝕜 n f s x :=
  contDiffWithinAtProp_self_source 𝓘(𝕜, E')
#align cont_diff_within_at_prop_self contDiffWithinAtProp_self
-/

#print contDiffWithinAtProp_self_target /-
theorem contDiffWithinAtProp_self_target {f : H → E'} {s : Set H} {x : H} :
    ContDiffWithinAtProp I 𝓘(𝕜, E') n f s x ↔
      ContDiffWithinAt 𝕜 n (f ∘ I.symm) (I.symm ⁻¹' s ∩ range I) (I x) :=
  Iff.rfl
#align cont_diff_within_at_prop_self_target contDiffWithinAtProp_self_target
-/

#print contDiffWithinAt_localInvariantProp /-
/-- Being `Cⁿ` in the model space is a local property, invariant under smooth maps. Therefore,
it will lift nicely to manifolds. -/
theorem contDiffWithinAt_localInvariantProp (n : ℕ∞) :
    (contDiffGroupoid ∞ I).LocalInvariantProp (contDiffGroupoid ∞ I')
      (ContDiffWithinAtProp I I' n) :=
  { is_local := by
      intro s x u f u_open xu
      have : I.symm ⁻¹' (s ∩ u) ∩ range I = I.symm ⁻¹' s ∩ range I ∩ I.symm ⁻¹' u := by
        simp only [inter_right_comm, preimage_inter]
      rw [ContDiffWithinAtProp, ContDiffWithinAtProp, this]
      symm
      apply contDiffWithinAt_inter
      have : u ∈ 𝓝 (I.symm (I x)) := by rw [ModelWithCorners.left_inv];
        exact IsOpen.mem_nhds u_open xu
      apply ContinuousAt.preimage_mem_nhds I.continuous_symm.continuous_at this
    right_invariance' := by
      intro s x f e he hx h
      rw [ContDiffWithinAtProp] at h ⊢
      have : I x = (I ∘ e.symm ∘ I.symm) (I (e x)) := by simp only [hx, mfld_simps]
      rw [this] at h 
      have : I (e x) ∈ I.symm ⁻¹' e.target ∩ range I := by simp only [hx, mfld_simps]
      have := ((mem_groupoid_of_pregroupoid.2 he).2.ContDiffWithinAt this).of_le le_top
      convert (h.comp' _ this).mono_of_mem _ using 1
      · ext y; simp only [mfld_simps]
      refine'
        mem_nhds_within.mpr
          ⟨I.symm ⁻¹' e.target, e.open_target.preimage I.continuous_symm, by
            simp_rw [mem_preimage, I.left_inv, e.maps_to hx], _⟩
      mfld_set_tac
    congr_of_forall := by
      intro s x f g h hx hf
      apply hf.congr
      · intro y hy
        simp only [mfld_simps] at hy 
        simp only [h, hy, mfld_simps]
      · simp only [hx, mfld_simps]
    left_invariance' := by
      intro s x f e' he' hs hx h
      rw [ContDiffWithinAtProp] at h ⊢
      have A : (I' ∘ f ∘ I.symm) (I x) ∈ I'.symm ⁻¹' e'.source ∩ range I' := by
        simp only [hx, mfld_simps]
      have := ((mem_groupoid_of_pregroupoid.2 he').1.ContDiffWithinAt A).of_le le_top
      convert this.comp _ h _
      · ext y; simp only [mfld_simps]
      · intro y hy; simp only [mfld_simps] at hy ; simpa only [hy, mfld_simps] using hs hy.1 }
#align cont_diff_within_at_local_invariant_prop contDiffWithinAt_localInvariantProp
-/

#print contDiffWithinAtProp_mono_of_mem /-
theorem contDiffWithinAtProp_mono_of_mem (n : ℕ∞) ⦃s x t⦄ ⦃f : H → H'⦄ (hts : s ∈ 𝓝[t] x)
    (h : ContDiffWithinAtProp I I' n f s x) : ContDiffWithinAtProp I I' n f t x :=
  by
  refine' h.mono_of_mem _
  refine' inter_mem _ (mem_of_superset self_mem_nhdsWithin <| inter_subset_right _ _)
  rwa [← Filter.mem_map, ← I.image_eq, I.symm_map_nhds_within_image]
#align cont_diff_within_at_prop_mono_of_mem contDiffWithinAtProp_mono_of_mem
-/

#print contDiffWithinAtProp_id /-
theorem contDiffWithinAtProp_id (x : H) : ContDiffWithinAtProp I I n id univ x :=
  by
  simp [ContDiffWithinAtProp]
  have : ContDiffWithinAt 𝕜 n id (range I) (I x) := cont_diff_id.cont_diff_at.cont_diff_within_at
  apply this.congr fun y hy => _
  · simp only [mfld_simps]
  · simp only [ModelWithCorners.right_inv I hy, mfld_simps]
#align cont_diff_within_at_prop_id contDiffWithinAtProp_id
-/

#print ContMDiffWithinAt /-
/-- A function is `n` times continuously differentiable within a set at a point in a manifold if
it is continuous and it is `n` times continuously differentiable in this set around this point, when
read in the preferred chart at this point. -/
def ContMDiffWithinAt (n : ℕ∞) (f : M → M') (s : Set M) (x : M) :=
  LiftPropWithinAt (ContDiffWithinAtProp I I' n) f s x
#align cont_mdiff_within_at ContMDiffWithinAt
-/

#print SmoothWithinAt /-
/-- Abbreviation for `cont_mdiff_within_at I I' ⊤ f s x`. See also documentation for `smooth`.
-/
@[reducible]
def SmoothWithinAt (f : M → M') (s : Set M) (x : M) :=
  ContMDiffWithinAt I I' ⊤ f s x
#align smooth_within_at SmoothWithinAt
-/

#print ContMDiffAt /-
/-- A function is `n` times continuously differentiable at a point in a manifold if
it is continuous and it is `n` times continuously differentiable around this point, when
read in the preferred chart at this point. -/
def ContMDiffAt (n : ℕ∞) (f : M → M') (x : M) :=
  ContMDiffWithinAt I I' n f univ x
#align cont_mdiff_at ContMDiffAt
-/

#print contMDiffAt_iff /-
theorem contMDiffAt_iff {n : ℕ∞} {f : M → M'} {x : M} :
    ContMDiffAt I I' n f x ↔
      ContinuousAt f x ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm) (range I)
          (extChartAt I x x) :=
  liftPropAt_iff.trans <| by rw [ContDiffWithinAtProp, preimage_univ, univ_inter]; rfl
#align cont_mdiff_at_iff contMDiffAt_iff
-/

#print SmoothAt /-
/-- Abbreviation for `cont_mdiff_at I I' ⊤ f x`. See also documentation for `smooth`. -/
@[reducible]
def SmoothAt (f : M → M') (x : M) :=
  ContMDiffAt I I' ⊤ f x
#align smooth_at SmoothAt
-/

#print ContMDiffOn /-
/-- A function is `n` times continuously differentiable in a set of a manifold if it is continuous
and, for any pair of points, it is `n` times continuously differentiable on this set in the charts
around these points. -/
def ContMDiffOn (n : ℕ∞) (f : M → M') (s : Set M) :=
  ∀ x ∈ s, ContMDiffWithinAt I I' n f s x
#align cont_mdiff_on ContMDiffOn
-/

#print SmoothOn /-
/-- Abbreviation for `cont_mdiff_on I I' ⊤ f s`. See also documentation for `smooth`. -/
@[reducible]
def SmoothOn (f : M → M') (s : Set M) :=
  ContMDiffOn I I' ⊤ f s
#align smooth_on SmoothOn
-/

#print ContMDiff /-
/-- A function is `n` times continuously differentiable in a manifold if it is continuous
and, for any pair of points, it is `n` times continuously differentiable in the charts
around these points. -/
def ContMDiff (n : ℕ∞) (f : M → M') :=
  ∀ x, ContMDiffAt I I' n f x
#align cont_mdiff ContMDiff
-/

#print Smooth /-
/-- Abbreviation for `cont_mdiff I I' ⊤ f`.
Short note to work with these abbreviations: a lemma of the form `cont_mdiff_foo.bar` will
apply fine to an assumption `smooth_foo` using dot notation or normal notation.
If the consequence `bar` of the lemma involves `cont_diff`, it is still better to restate
the lemma replacing `cont_diff` with `smooth` both in the assumption and in the conclusion,
to make it possible to use `smooth` consistently.
This also applies to `smooth_at`, `smooth_on` and `smooth_within_at`.-/
@[reducible]
def Smooth (f : M → M') :=
  ContMDiff I I' ⊤ f
#align smooth Smooth
-/

/-! ### Basic properties of smooth functions between manifolds -/


variable {I I'}

#print ContMDiff.smooth /-
theorem ContMDiff.smooth (h : ContMDiff I I' ⊤ f) : Smooth I I' f :=
  h
#align cont_mdiff.smooth ContMDiff.smooth
-/

#print Smooth.contMDiff /-
theorem Smooth.contMDiff (h : Smooth I I' f) : ContMDiff I I' ⊤ f :=
  h
#align smooth.cont_mdiff Smooth.contMDiff
-/

#print ContMDiffOn.smoothOn /-
theorem ContMDiffOn.smoothOn (h : ContMDiffOn I I' ⊤ f s) : SmoothOn I I' f s :=
  h
#align cont_mdiff_on.smooth_on ContMDiffOn.smoothOn
-/

#print SmoothOn.contMDiffOn /-
theorem SmoothOn.contMDiffOn (h : SmoothOn I I' f s) : ContMDiffOn I I' ⊤ f s :=
  h
#align smooth_on.cont_mdiff_on SmoothOn.contMDiffOn
-/

#print ContMDiffAt.smoothAt /-
theorem ContMDiffAt.smoothAt (h : ContMDiffAt I I' ⊤ f x) : SmoothAt I I' f x :=
  h
#align cont_mdiff_at.smooth_at ContMDiffAt.smoothAt
-/

#print SmoothAt.contMDiffAt /-
theorem SmoothAt.contMDiffAt (h : SmoothAt I I' f x) : ContMDiffAt I I' ⊤ f x :=
  h
#align smooth_at.cont_mdiff_at SmoothAt.contMDiffAt
-/

#print ContMDiffWithinAt.smoothWithinAt /-
theorem ContMDiffWithinAt.smoothWithinAt (h : ContMDiffWithinAt I I' ⊤ f s x) :
    SmoothWithinAt I I' f s x :=
  h
#align cont_mdiff_within_at.smooth_within_at ContMDiffWithinAt.smoothWithinAt
-/

#print SmoothWithinAt.contMDiffWithinAt /-
theorem SmoothWithinAt.contMDiffWithinAt (h : SmoothWithinAt I I' f s x) :
    ContMDiffWithinAt I I' ⊤ f s x :=
  h
#align smooth_within_at.cont_mdiff_within_at SmoothWithinAt.contMDiffWithinAt
-/

#print ContMDiff.contMDiffAt /-
theorem ContMDiff.contMDiffAt (h : ContMDiff I I' n f) : ContMDiffAt I I' n f x :=
  h x
#align cont_mdiff.cont_mdiff_at ContMDiff.contMDiffAt
-/

#print Smooth.smoothAt /-
theorem Smooth.smoothAt (h : Smooth I I' f) : SmoothAt I I' f x :=
  ContMDiff.contMDiffAt h
#align smooth.smooth_at Smooth.smoothAt
-/

#print contMDiffWithinAt_univ /-
theorem contMDiffWithinAt_univ : ContMDiffWithinAt I I' n f univ x ↔ ContMDiffAt I I' n f x :=
  Iff.rfl
#align cont_mdiff_within_at_univ contMDiffWithinAt_univ
-/

#print smoothWithinAt_univ /-
theorem smoothWithinAt_univ : SmoothWithinAt I I' f univ x ↔ SmoothAt I I' f x :=
  contMDiffWithinAt_univ
#align smooth_within_at_univ smoothWithinAt_univ
-/

#print contMDiffOn_univ /-
theorem contMDiffOn_univ : ContMDiffOn I I' n f univ ↔ ContMDiff I I' n f := by
  simp only [ContMDiffOn, ContMDiff, contMDiffWithinAt_univ, forall_prop_of_true, mem_univ]
#align cont_mdiff_on_univ contMDiffOn_univ
-/

#print smoothOn_univ /-
theorem smoothOn_univ : SmoothOn I I' f univ ↔ Smooth I I' f :=
  contMDiffOn_univ
#align smooth_on_univ smoothOn_univ
-/

#print contMDiffWithinAt_iff /-
/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart. -/
theorem contMDiffWithinAt_iff :
    ContMDiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).symm ⁻¹' s ∩ range I) (extChartAt I x x) :=
  Iff.rfl
#align cont_mdiff_within_at_iff contMDiffWithinAt_iff
-/

#print contMDiffWithinAt_iff' /-
/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart. This form states smoothness of `f`
written in such a way that the set is restricted to lie within the domain/codomain of the
corresponding charts.
Even though this expression is more complicated than the one in `cont_mdiff_within_at_iff`, it is
a smaller set, but their germs at `ext_chart_at I x x` are equal. It is sometimes useful to rewrite
using this in the goal.
-/
theorem contMDiffWithinAt_iff' :
    ContMDiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).target ∩
            (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' (f x)).source))
          (extChartAt I x x) :=
  by
  rw [contMDiffWithinAt_iff, and_congr_right_iff]
  set e := extChartAt I x; set e' := extChartAt I' (f x)
  refine' fun hc => contDiffWithinAt_congr_nhds _
  rw [← e.image_source_inter_eq', ← map_extChartAt_nhdsWithin_eq_image, ← map_extChartAt_nhdsWithin,
    inter_comm, nhdsWithin_inter_of_mem]
  exact hc (extChartAt_source_mem_nhds _ _)
#align cont_mdiff_within_at_iff' contMDiffWithinAt_iff'
-/

#print contMDiffWithinAt_iff_target /-
/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in the corresponding extended chart in the target. -/
theorem contMDiffWithinAt_iff_target :
    ContMDiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧ ContMDiffWithinAt I 𝓘(𝕜, E') n (extChartAt I' (f x) ∘ f) s x :=
  by
  simp_rw [ContMDiffWithinAt, lift_prop_within_at, ← and_assoc']
  have cont :
    ContinuousWithinAt f s x ∧ ContinuousWithinAt (extChartAt I' (f x) ∘ f) s x ↔
      ContinuousWithinAt f s x :=
    by
    refine' ⟨fun h => h.1, fun h => ⟨h, _⟩⟩
    have h₂ := (chart_at H' (f x)).continuous_toFun.ContinuousWithinAt (mem_chart_source _ _)
    refine' ((I'.continuous_at.comp_continuous_within_at h₂).comp' h).mono_of_mem _
    exact
      inter_mem self_mem_nhdsWithin
        (h.preimage_mem_nhds_within <| (chart_at _ _).open_source.mem_nhds <| mem_chart_source _ _)
  simp_rw [Cont, ContDiffWithinAtProp, extChartAt, LocalHomeomorph.extend, LocalEquiv.coe_trans,
    ModelWithCorners.toLocalEquiv_coe, LocalHomeomorph.coe_coe, modelWithCornersSelf_coe,
    chartAt_self_eq, LocalHomeomorph.refl_apply, comp.left_id]
#align cont_mdiff_within_at_iff_target contMDiffWithinAt_iff_target
-/

#print smoothWithinAt_iff /-
theorem smoothWithinAt_iff :
    SmoothWithinAt I I' f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 ∞ (extChartAt I' (f x) ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).symm ⁻¹' s ∩ range I) (extChartAt I x x) :=
  contMDiffWithinAt_iff
#align smooth_within_at_iff smoothWithinAt_iff
-/

#print smoothWithinAt_iff_target /-
theorem smoothWithinAt_iff_target :
    SmoothWithinAt I I' f s x ↔
      ContinuousWithinAt f s x ∧ SmoothWithinAt I 𝓘(𝕜, E') (extChartAt I' (f x) ∘ f) s x :=
  contMDiffWithinAt_iff_target
#align smooth_within_at_iff_target smoothWithinAt_iff_target
-/

#print contMDiffAt_iff_target /-
theorem contMDiffAt_iff_target {x : M} :
    ContMDiffAt I I' n f x ↔
      ContinuousAt f x ∧ ContMDiffAt I 𝓘(𝕜, E') n (extChartAt I' (f x) ∘ f) x :=
  by rw [ContMDiffAt, ContMDiffAt, contMDiffWithinAt_iff_target, continuousWithinAt_univ]
#align cont_mdiff_at_iff_target contMDiffAt_iff_target
-/

#print smoothAt_iff_target /-
theorem smoothAt_iff_target {x : M} :
    SmoothAt I I' f x ↔ ContinuousAt f x ∧ SmoothAt I 𝓘(𝕜, E') (extChartAt I' (f x) ∘ f) x :=
  contMDiffAt_iff_target
#align smooth_at_iff_target smoothAt_iff_target
-/

#print contMDiffWithinAt_iff_of_mem_maximalAtlas /-
theorem contMDiffWithinAt_iff_of_mem_maximalAtlas {x : M} (he : e ∈ maximalAtlas I M)
    (he' : e' ∈ maximalAtlas I' M') (hx : x ∈ e.source) (hy : f x ∈ e'.source) :
    ContMDiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 n (e'.extend I' ∘ f ∘ (e.extend I).symm)
          ((e.extend I).symm ⁻¹' s ∩ range I) (e.extend I x) :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_indep_chart he hx he' hy
#align cont_mdiff_within_at_iff_of_mem_maximal_atlas contMDiffWithinAt_iff_of_mem_maximalAtlas
-/

#print contMDiffWithinAt_iff_image /-
/-- An alternative formulation of `cont_mdiff_within_at_iff_of_mem_maximal_atlas`
  if the set if `s` lies in `e.source`. -/
theorem contMDiffWithinAt_iff_image {x : M} (he : e ∈ maximalAtlas I M)
    (he' : e' ∈ maximalAtlas I' M') (hs : s ⊆ e.source) (hx : x ∈ e.source) (hy : f x ∈ e'.source) :
    ContMDiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧
        ContDiffWithinAt 𝕜 n (e'.extend I' ∘ f ∘ (e.extend I).symm) (e.extend I '' s)
          (e.extend I x) :=
  by
  rw [contMDiffWithinAt_iff_of_mem_maximalAtlas he he' hx hy, and_congr_right_iff]
  refine' fun hf => contDiffWithinAt_congr_nhds _
  simp_rw [nhdsWithin_eq_iff_eventuallyEq, e.extend_symm_preimage_inter_range_eventually_eq I hs hx]
#align cont_mdiff_within_at_iff_image contMDiffWithinAt_iff_image
-/

#print contMDiffWithinAt_iff_of_mem_source /-
/-- One can reformulate smoothness within a set at a point as continuity within this set at this
point, and smoothness in any chart containing that point. -/
theorem contMDiffWithinAt_iff_of_mem_source {x' : M} {y : M'} (hx : x' ∈ (chartAt H x).source)
    (hy : f x' ∈ (chartAt H' y).source) :
    ContMDiffWithinAt I I' n f s x' ↔
      ContinuousWithinAt f s x' ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).symm ⁻¹' s ∩ range I) (extChartAt I x x') :=
  contMDiffWithinAt_iff_of_mem_maximalAtlas (chart_mem_maximalAtlas _ x)
    (chart_mem_maximalAtlas _ y) hx hy
#align cont_mdiff_within_at_iff_of_mem_source contMDiffWithinAt_iff_of_mem_source
-/

#print contMDiffWithinAt_iff_of_mem_source' /-
theorem contMDiffWithinAt_iff_of_mem_source' {x' : M} {y : M'} (hx : x' ∈ (chartAt H x).source)
    (hy : f x' ∈ (chartAt H' y).source) :
    ContMDiffWithinAt I I' n f s x' ↔
      ContinuousWithinAt f s x' ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
          ((extChartAt I x).target ∩ (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).source))
          (extChartAt I x x') :=
  by
  refine' (contMDiffWithinAt_iff_of_mem_source hx hy).trans _
  rw [← extChartAt_source I] at hx 
  rw [← extChartAt_source I'] at hy 
  rw [and_congr_right_iff]
  set e := extChartAt I x; set e' := extChartAt I' (f x)
  refine' fun hc => contDiffWithinAt_congr_nhds _
  rw [← e.image_source_inter_eq', ← map_extChartAt_nhdsWithin_eq_image' I x hx, ←
    map_extChartAt_nhdsWithin' I x hx, inter_comm, nhdsWithin_inter_of_mem]
  exact hc (extChartAt_source_mem_nhds' _ _ hy)
#align cont_mdiff_within_at_iff_of_mem_source' contMDiffWithinAt_iff_of_mem_source'
-/

#print contMDiffAt_iff_of_mem_source /-
theorem contMDiffAt_iff_of_mem_source {x' : M} {y : M'} (hx : x' ∈ (chartAt H x).source)
    (hy : f x' ∈ (chartAt H' y).source) :
    ContMDiffAt I I' n f x' ↔
      ContinuousAt f x' ∧
        ContDiffWithinAt 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm) (range I)
          (extChartAt I x x') :=
  (contMDiffWithinAt_iff_of_mem_source hx hy).trans <| by
    rw [continuousWithinAt_univ, preimage_univ, univ_inter]
#align cont_mdiff_at_iff_of_mem_source contMDiffAt_iff_of_mem_source
-/

#print contMDiffWithinAt_iff_target_of_mem_source /-
theorem contMDiffWithinAt_iff_target_of_mem_source {x : M} {y : M'}
    (hy : f x ∈ (chartAt H' y).source) :
    ContMDiffWithinAt I I' n f s x ↔
      ContinuousWithinAt f s x ∧ ContMDiffWithinAt I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) s x :=
  by
  simp_rw [ContMDiffWithinAt]
  rw [(contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_indep_chart_target
      (chart_mem_maximal_atlas I' y) hy,
    and_congr_right]
  intro hf
  simp_rw [StructureGroupoid.liftPropWithinAt_self_target]
  simp_rw [((chart_at H' y).ContinuousAt hy).comp_continuousWithinAt hf]
  rw [← extChartAt_source I'] at hy 
  simp_rw [(continuousAt_extChartAt' I' _ hy).comp_continuousWithinAt hf]
  rfl
#align cont_mdiff_within_at_iff_target_of_mem_source contMDiffWithinAt_iff_target_of_mem_source
-/

#print contMDiffAt_iff_target_of_mem_source /-
theorem contMDiffAt_iff_target_of_mem_source {x : M} {y : M'} (hy : f x ∈ (chartAt H' y).source) :
    ContMDiffAt I I' n f x ↔ ContinuousAt f x ∧ ContMDiffAt I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) x :=
  by
  rw [ContMDiffAt, contMDiffWithinAt_iff_target_of_mem_source hy, continuousWithinAt_univ,
    ContMDiffAt]
  infer_instance
#align cont_mdiff_at_iff_target_of_mem_source contMDiffAt_iff_target_of_mem_source
-/

#print contMDiffWithinAt_iff_source_of_mem_maximalAtlas /-
theorem contMDiffWithinAt_iff_source_of_mem_maximalAtlas (he : e ∈ maximalAtlas I M)
    (hx : x ∈ e.source) :
    ContMDiffWithinAt I I' n f s x ↔
      ContMDiffWithinAt 𝓘(𝕜, E) I' n (f ∘ (e.extend I).symm) ((e.extend I).symm ⁻¹' s ∩ range I)
        (e.extend I x) :=
  by
  have h2x := hx; rw [← e.extend_source I] at h2x 
  simp_rw [ContMDiffWithinAt,
    (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_indep_chart_source he hx,
    StructureGroupoid.liftPropWithinAt_self_source,
    e.extend_symm_continuous_within_at_comp_right_iff, contDiffWithinAtProp_self_source,
    ContDiffWithinAtProp, Function.comp, e.left_inv hx, (e.extend I).left_inv h2x]
  rfl
#align cont_mdiff_within_at_iff_source_of_mem_maximal_atlas contMDiffWithinAt_iff_source_of_mem_maximalAtlas
-/

#print contMDiffWithinAt_iff_source_of_mem_source /-
theorem contMDiffWithinAt_iff_source_of_mem_source {x' : M} (hx' : x' ∈ (chartAt H x).source) :
    ContMDiffWithinAt I I' n f s x' ↔
      ContMDiffWithinAt 𝓘(𝕜, E) I' n (f ∘ (extChartAt I x).symm)
        ((extChartAt I x).symm ⁻¹' s ∩ range I) (extChartAt I x x') :=
  contMDiffWithinAt_iff_source_of_mem_maximalAtlas (chart_mem_maximalAtlas I x) hx'
#align cont_mdiff_within_at_iff_source_of_mem_source contMDiffWithinAt_iff_source_of_mem_source
-/

#print contMDiffAt_iff_source_of_mem_source /-
theorem contMDiffAt_iff_source_of_mem_source {x' : M} (hx' : x' ∈ (chartAt H x).source) :
    ContMDiffAt I I' n f x' ↔
      ContMDiffWithinAt 𝓘(𝕜, E) I' n (f ∘ (extChartAt I x).symm) (range I) (extChartAt I x x') :=
  by
  simp_rw [ContMDiffAt, contMDiffWithinAt_iff_source_of_mem_source hx', preimage_univ, univ_inter]
#align cont_mdiff_at_iff_source_of_mem_source contMDiffAt_iff_source_of_mem_source
-/

#print contMDiffOn_iff_of_mem_maximalAtlas /-
theorem contMDiffOn_iff_of_mem_maximalAtlas (he : e ∈ maximalAtlas I M)
    (he' : e' ∈ maximalAtlas I' M') (hs : s ⊆ e.source) (h2s : MapsTo f s e'.source) :
    ContMDiffOn I I' n f s ↔
      ContinuousOn f s ∧ ContDiffOn 𝕜 n (e'.extend I' ∘ f ∘ (e.extend I).symm) (e.extend I '' s) :=
  by
  simp_rw [ContinuousOn, ContDiffOn, Set.ball_image_iff, ← forall_and, ContMDiffOn]
  exact forall₂_congr fun x hx => contMDiffWithinAt_iff_image he he' hs (hs hx) (h2s hx)
#align cont_mdiff_on_iff_of_mem_maximal_atlas contMDiffOn_iff_of_mem_maximalAtlas
-/

#print contMDiffOn_iff_of_subset_source /-
/-- If the set where you want `f` to be smooth lies entirely in a single chart, and `f` maps it
  into a single chart, the smoothness of `f` on that set can be expressed by purely looking in
  these charts.
  Note: this lemma uses `ext_chart_at I x '' s` instead of `(ext_chart_at I x).symm ⁻¹' s` to ensure
  that this set lies in `(ext_chart_at I x).target`. -/
theorem contMDiffOn_iff_of_subset_source {x : M} {y : M'} (hs : s ⊆ (chartAt H x).source)
    (h2s : MapsTo f s (chartAt H' y).source) :
    ContMDiffOn I I' n f s ↔
      ContinuousOn f s ∧
        ContDiffOn 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm) (extChartAt I x '' s) :=
  contMDiffOn_iff_of_mem_maximalAtlas (chart_mem_maximalAtlas I x) (chart_mem_maximalAtlas I' y) hs
    h2s
#align cont_mdiff_on_iff_of_subset_source contMDiffOn_iff_of_subset_source
-/

#print contMDiffOn_iff /-
/-- One can reformulate smoothness on a set as continuity on this set, and smoothness in any
extended chart. -/
theorem contMDiffOn_iff :
    ContMDiffOn I I' n f s ↔
      ContinuousOn f s ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).target ∩
              (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).source)) :=
  by
  constructor
  · intro h
    refine' ⟨fun x hx => (h x hx).1, fun x y z hz => _⟩
    simp only [mfld_simps] at hz 
    let w := (extChartAt I x).symm z
    have : w ∈ s := by simp only [w, hz, mfld_simps]
    specialize h w this
    have w1 : w ∈ (chart_at H x).source := by simp only [w, hz, mfld_simps]
    have w2 : f w ∈ (chart_at H' y).source := by simp only [w, hz, mfld_simps]
    convert ((contMDiffWithinAt_iff_of_mem_source w1 w2).mp h).2.mono _
    · simp only [w, hz, mfld_simps]
    · mfld_set_tac
  · rintro ⟨hcont, hdiff⟩ x hx
    refine' (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_iff.mpr _
    refine' ⟨hcont x hx, _⟩
    dsimp [ContDiffWithinAtProp]
    convert hdiff x (f x) (extChartAt I x x) (by simp only [hx, mfld_simps]) using 1
    mfld_set_tac
#align cont_mdiff_on_iff contMDiffOn_iff
-/

#print contMDiffOn_iff_target /-
/-- One can reformulate smoothness on a set as continuity on this set, and smoothness in any
extended chart in the target. -/
theorem contMDiffOn_iff_target :
    ContMDiffOn I I' n f s ↔
      ContinuousOn f s ∧
        ∀ y : M',
          ContMDiffOn I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) (s ∩ f ⁻¹' (extChartAt I' y).source) :=
  by
  inhabit E'
  simp only [contMDiffOn_iff, ModelWithCorners.source_eq, chartAt_self_eq,
    LocalHomeomorph.refl_localEquiv, LocalEquiv.refl_trans, extChartAt, LocalHomeomorph.extend,
    Set.preimage_univ, Set.inter_univ, and_congr_right_iff]
  intro h
  constructor
  · refine' fun h' y => ⟨_, fun x _ => h' x y⟩
    have h'' : ContinuousOn _ univ := (ModelWithCorners.continuous I').ContinuousOn
    convert (h''.comp' (chart_at H' y).continuous_toFun).comp' h
    simp
  · exact fun h' x y => (h' y).2 x default
#align cont_mdiff_on_iff_target contMDiffOn_iff_target
-/

#print smoothOn_iff /-
theorem smoothOn_iff :
    SmoothOn I I' f s ↔
      ContinuousOn f s ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 ⊤ (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).target ∩
              (extChartAt I x).symm ⁻¹' (s ∩ f ⁻¹' (extChartAt I' y).source)) :=
  contMDiffOn_iff
#align smooth_on_iff smoothOn_iff
-/

#print smoothOn_iff_target /-
theorem smoothOn_iff_target :
    SmoothOn I I' f s ↔
      ContinuousOn f s ∧
        ∀ y : M', SmoothOn I 𝓘(𝕜, E') (extChartAt I' y ∘ f) (s ∩ f ⁻¹' (extChartAt I' y).source) :=
  contMDiffOn_iff_target
#align smooth_on_iff_target smoothOn_iff_target
-/

#print contMDiff_iff /-
/-- One can reformulate smoothness as continuity and smoothness in any extended chart. -/
theorem contMDiff_iff :
    ContMDiff I I' n f ↔
      Continuous f ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 n (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).target ∩
              (extChartAt I x).symm ⁻¹' (f ⁻¹' (extChartAt I' y).source)) :=
  by simp [← contMDiffOn_univ, contMDiffOn_iff, continuous_iff_continuousOn_univ]
#align cont_mdiff_iff contMDiff_iff
-/

#print contMDiff_iff_target /-
/-- One can reformulate smoothness as continuity and smoothness in any extended chart in the
target. -/
theorem contMDiff_iff_target :
    ContMDiff I I' n f ↔
      Continuous f ∧
        ∀ y : M', ContMDiffOn I 𝓘(𝕜, E') n (extChartAt I' y ∘ f) (f ⁻¹' (extChartAt I' y).source) :=
  by
  rw [← contMDiffOn_univ, contMDiffOn_iff_target]
  simp [continuous_iff_continuousOn_univ]
#align cont_mdiff_iff_target contMDiff_iff_target
-/

#print smooth_iff /-
theorem smooth_iff :
    Smooth I I' f ↔
      Continuous f ∧
        ∀ (x : M) (y : M'),
          ContDiffOn 𝕜 ⊤ (extChartAt I' y ∘ f ∘ (extChartAt I x).symm)
            ((extChartAt I x).target ∩
              (extChartAt I x).symm ⁻¹' (f ⁻¹' (extChartAt I' y).source)) :=
  contMDiff_iff
#align smooth_iff smooth_iff
-/

#print smooth_iff_target /-
theorem smooth_iff_target :
    Smooth I I' f ↔
      Continuous f ∧
        ∀ y : M', SmoothOn I 𝓘(𝕜, E') (extChartAt I' y ∘ f) (f ⁻¹' (extChartAt I' y).source) :=
  contMDiff_iff_target
#align smooth_iff_target smooth_iff_target
-/

/-! ### Deducing smoothness from higher smoothness -/


#print ContMDiffWithinAt.of_le /-
theorem ContMDiffWithinAt.of_le (hf : ContMDiffWithinAt I I' n f s x) (le : m ≤ n) :
    ContMDiffWithinAt I I' m f s x :=
  ⟨hf.1, hf.2.of_le le⟩
#align cont_mdiff_within_at.of_le ContMDiffWithinAt.of_le
-/

#print ContMDiffAt.of_le /-
theorem ContMDiffAt.of_le (hf : ContMDiffAt I I' n f x) (le : m ≤ n) : ContMDiffAt I I' m f x :=
  ContMDiffWithinAt.of_le hf le
#align cont_mdiff_at.of_le ContMDiffAt.of_le
-/

#print ContMDiffOn.of_le /-
theorem ContMDiffOn.of_le (hf : ContMDiffOn I I' n f s) (le : m ≤ n) : ContMDiffOn I I' m f s :=
  fun x hx => (hf x hx).of_le le
#align cont_mdiff_on.of_le ContMDiffOn.of_le
-/

#print ContMDiff.of_le /-
theorem ContMDiff.of_le (hf : ContMDiff I I' n f) (le : m ≤ n) : ContMDiff I I' m f := fun x =>
  (hf x).of_le le
#align cont_mdiff.of_le ContMDiff.of_le
-/

/-! ### Deducing smoothness from smoothness one step beyond -/


#print ContMDiffWithinAt.of_succ /-
theorem ContMDiffWithinAt.of_succ {n : ℕ} (h : ContMDiffWithinAt I I' n.succ f s x) :
    ContMDiffWithinAt I I' n f s x :=
  h.of_le (WithTop.coe_le_coe.2 (Nat.le_succ n))
#align cont_mdiff_within_at.of_succ ContMDiffWithinAt.of_succ
-/

#print ContMDiffAt.of_succ /-
theorem ContMDiffAt.of_succ {n : ℕ} (h : ContMDiffAt I I' n.succ f x) : ContMDiffAt I I' n f x :=
  ContMDiffWithinAt.of_succ h
#align cont_mdiff_at.of_succ ContMDiffAt.of_succ
-/

#print ContMDiffOn.of_succ /-
theorem ContMDiffOn.of_succ {n : ℕ} (h : ContMDiffOn I I' n.succ f s) : ContMDiffOn I I' n f s :=
  fun x hx => (h x hx).of_succ
#align cont_mdiff_on.of_succ ContMDiffOn.of_succ
-/

#print ContMDiff.of_succ /-
theorem ContMDiff.of_succ {n : ℕ} (h : ContMDiff I I' n.succ f) : ContMDiff I I' n f := fun x =>
  (h x).of_succ
#align cont_mdiff.of_succ ContMDiff.of_succ
-/

/-! ### Deducing continuity from smoothness -/


#print ContMDiffWithinAt.continuousWithinAt /-
theorem ContMDiffWithinAt.continuousWithinAt (hf : ContMDiffWithinAt I I' n f s x) :
    ContinuousWithinAt f s x :=
  hf.1
#align cont_mdiff_within_at.continuous_within_at ContMDiffWithinAt.continuousWithinAt
-/

#print ContMDiffAt.continuousAt /-
theorem ContMDiffAt.continuousAt (hf : ContMDiffAt I I' n f x) : ContinuousAt f x :=
  (continuousWithinAt_univ _ _).1 <| ContMDiffWithinAt.continuousWithinAt hf
#align cont_mdiff_at.continuous_at ContMDiffAt.continuousAt
-/

#print ContMDiffOn.continuousOn /-
theorem ContMDiffOn.continuousOn (hf : ContMDiffOn I I' n f s) : ContinuousOn f s := fun x hx =>
  (hf x hx).ContinuousWithinAt
#align cont_mdiff_on.continuous_on ContMDiffOn.continuousOn
-/

#print ContMDiff.continuous /-
theorem ContMDiff.continuous (hf : ContMDiff I I' n f) : Continuous f :=
  continuous_iff_continuousAt.2 fun x => (hf x).ContinuousAt
#align cont_mdiff.continuous ContMDiff.continuous
-/

/-! ### `C^∞` smoothness -/


#print contMDiffWithinAt_top /-
theorem contMDiffWithinAt_top :
    SmoothWithinAt I I' f s x ↔ ∀ n : ℕ, ContMDiffWithinAt I I' n f s x :=
  ⟨fun h n => ⟨h.1, contDiffWithinAt_top.1 h.2 n⟩, fun H =>
    ⟨(H 0).1, contDiffWithinAt_top.2 fun n => (H n).2⟩⟩
#align cont_mdiff_within_at_top contMDiffWithinAt_top
-/

#print contMDiffAt_top /-
theorem contMDiffAt_top : SmoothAt I I' f x ↔ ∀ n : ℕ, ContMDiffAt I I' n f x :=
  contMDiffWithinAt_top
#align cont_mdiff_at_top contMDiffAt_top
-/

#print contMDiffOn_top /-
theorem contMDiffOn_top : SmoothOn I I' f s ↔ ∀ n : ℕ, ContMDiffOn I I' n f s :=
  ⟨fun h n => h.of_le le_top, fun h x hx => contMDiffWithinAt_top.2 fun n => h n x hx⟩
#align cont_mdiff_on_top contMDiffOn_top
-/

#print contMDiff_top /-
theorem contMDiff_top : Smooth I I' f ↔ ∀ n : ℕ, ContMDiff I I' n f :=
  ⟨fun h n => h.of_le le_top, fun h x => contMDiffWithinAt_top.2 fun n => h n x⟩
#align cont_mdiff_top contMDiff_top
-/

#print contMDiffWithinAt_iff_nat /-
theorem contMDiffWithinAt_iff_nat :
    ContMDiffWithinAt I I' n f s x ↔ ∀ m : ℕ, (m : ℕ∞) ≤ n → ContMDiffWithinAt I I' m f s x :=
  by
  refine' ⟨fun h m hm => h.of_le hm, fun h => _⟩
  cases n
  · exact contMDiffWithinAt_top.2 fun n => h n le_top
  · exact h n le_rfl
#align cont_mdiff_within_at_iff_nat contMDiffWithinAt_iff_nat
-/

/-! ### Restriction to a smaller set -/


#print ContMDiffWithinAt.mono_of_mem /-
theorem ContMDiffWithinAt.mono_of_mem (hf : ContMDiffWithinAt I I' n f s x) (hts : s ∈ 𝓝[t] x) :
    ContMDiffWithinAt I I' n f t x :=
  StructureGroupoid.LocalInvariantProp.liftPropWithinAt_mono_of_mem
    (contDiffWithinAtProp_mono_of_mem I I' n) hf hts
#align cont_mdiff_within_at.mono_of_mem ContMDiffWithinAt.mono_of_mem
-/

#print ContMDiffWithinAt.mono /-
theorem ContMDiffWithinAt.mono (hf : ContMDiffWithinAt I I' n f s x) (hts : t ⊆ s) :
    ContMDiffWithinAt I I' n f t x :=
  hf.mono_of_mem <| mem_of_superset self_mem_nhdsWithin hts
#align cont_mdiff_within_at.mono ContMDiffWithinAt.mono
-/

#print contMDiffWithinAt_congr_nhds /-
theorem contMDiffWithinAt_congr_nhds (hst : 𝓝[s] x = 𝓝[t] x) :
    ContMDiffWithinAt I I' n f s x ↔ ContMDiffWithinAt I I' n f t x :=
  ⟨fun h => h.mono_of_mem <| hst ▸ self_mem_nhdsWithin, fun h =>
    h.mono_of_mem <| hst.symm ▸ self_mem_nhdsWithin⟩
#align cont_mdiff_within_at_congr_nhds contMDiffWithinAt_congr_nhds
-/

#print ContMDiffAt.contMDiffWithinAt /-
theorem ContMDiffAt.contMDiffWithinAt (hf : ContMDiffAt I I' n f x) :
    ContMDiffWithinAt I I' n f s x :=
  ContMDiffWithinAt.mono hf (subset_univ _)
#align cont_mdiff_at.cont_mdiff_within_at ContMDiffAt.contMDiffWithinAt
-/

#print SmoothAt.smoothWithinAt /-
theorem SmoothAt.smoothWithinAt (hf : SmoothAt I I' f x) : SmoothWithinAt I I' f s x :=
  ContMDiffAt.contMDiffWithinAt hf
#align smooth_at.smooth_within_at SmoothAt.smoothWithinAt
-/

#print ContMDiffOn.mono /-
theorem ContMDiffOn.mono (hf : ContMDiffOn I I' n f s) (hts : t ⊆ s) : ContMDiffOn I I' n f t :=
  fun x hx => (hf x (hts hx)).mono hts
#align cont_mdiff_on.mono ContMDiffOn.mono
-/

#print ContMDiff.contMDiffOn /-
theorem ContMDiff.contMDiffOn (hf : ContMDiff I I' n f) : ContMDiffOn I I' n f s := fun x hx =>
  (hf x).ContMDiffWithinAt
#align cont_mdiff.cont_mdiff_on ContMDiff.contMDiffOn
-/

#print Smooth.smoothOn /-
theorem Smooth.smoothOn (hf : Smooth I I' f) : SmoothOn I I' f s :=
  ContMDiff.contMDiffOn hf
#align smooth.smooth_on Smooth.smoothOn
-/

#print contMDiffWithinAt_inter' /-
theorem contMDiffWithinAt_inter' (ht : t ∈ 𝓝[s] x) :
    ContMDiffWithinAt I I' n f (s ∩ t) x ↔ ContMDiffWithinAt I I' n f s x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_inter' ht
#align cont_mdiff_within_at_inter' contMDiffWithinAt_inter'
-/

#print contMDiffWithinAt_inter /-
theorem contMDiffWithinAt_inter (ht : t ∈ 𝓝 x) :
    ContMDiffWithinAt I I' n f (s ∩ t) x ↔ ContMDiffWithinAt I I' n f s x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_inter ht
#align cont_mdiff_within_at_inter contMDiffWithinAt_inter
-/

#print ContMDiffWithinAt.contMDiffAt /-
theorem ContMDiffWithinAt.contMDiffAt (h : ContMDiffWithinAt I I' n f s x) (ht : s ∈ 𝓝 x) :
    ContMDiffAt I I' n f x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropAt_of_liftPropWithinAt h ht
#align cont_mdiff_within_at.cont_mdiff_at ContMDiffWithinAt.contMDiffAt
-/

#print SmoothWithinAt.smoothAt /-
theorem SmoothWithinAt.smoothAt (h : SmoothWithinAt I I' f s x) (ht : s ∈ 𝓝 x) :
    SmoothAt I I' f x :=
  ContMDiffWithinAt.contMDiffAt h ht
#align smooth_within_at.smooth_at SmoothWithinAt.smoothAt
-/

#print ContMDiffOn.contMDiffAt /-
theorem ContMDiffOn.contMDiffAt (h : ContMDiffOn I I' n f s) (hx : s ∈ 𝓝 x) :
    ContMDiffAt I I' n f x :=
  (h x (mem_of_mem_nhds hx)).ContMDiffAt hx
#align cont_mdiff_on.cont_mdiff_at ContMDiffOn.contMDiffAt
-/

#print SmoothOn.smoothAt /-
theorem SmoothOn.smoothAt (h : SmoothOn I I' f s) (hx : s ∈ 𝓝 x) : SmoothAt I I' f x :=
  h.ContMDiffAt hx
#align smooth_on.smooth_at SmoothOn.smoothAt
-/

#print contMDiffOn_iff_source_of_mem_maximalAtlas /-
theorem contMDiffOn_iff_source_of_mem_maximalAtlas (he : e ∈ maximalAtlas I M) (hs : s ⊆ e.source) :
    ContMDiffOn I I' n f s ↔ ContMDiffOn 𝓘(𝕜, E) I' n (f ∘ (e.extend I).symm) (e.extend I '' s) :=
  by
  simp_rw [ContMDiffOn, Set.ball_image_iff]
  refine' forall₂_congr fun x hx => _
  rw [contMDiffWithinAt_iff_source_of_mem_maximalAtlas he (hs hx)]
  apply contMDiffWithinAt_congr_nhds
  simp_rw [nhdsWithin_eq_iff_eventuallyEq,
    e.extend_symm_preimage_inter_range_eventually_eq I hs (hs hx)]
#align cont_mdiff_on_iff_source_of_mem_maximal_atlas contMDiffOn_iff_source_of_mem_maximalAtlas
-/

#print contMDiffWithinAt_iff_contMDiffOn_nhds /-
/-- A function is `C^n` within a set at a point, for `n : ℕ`, if and only if it is `C^n` on
a neighborhood of this point. -/
theorem contMDiffWithinAt_iff_contMDiffOn_nhds {n : ℕ} :
    ContMDiffWithinAt I I' n f s x ↔ ∃ u ∈ 𝓝[insert x s] x, ContMDiffOn I I' n f u :=
  by
  constructor
  · intro h
    -- the property is true in charts. We will pull such a good neighborhood in the chart to the
    -- manifold. For this, we need to restrict to a small enough set where everything makes sense
    obtain ⟨o, o_open, xo, ho, h'o⟩ :
      ∃ o : Set M,
        IsOpen o ∧ x ∈ o ∧ o ⊆ (chart_at H x).source ∧ o ∩ s ⊆ f ⁻¹' (chart_at H' (f x)).source :=
      by
      have : (chart_at H' (f x)).source ∈ 𝓝 (f x) :=
        IsOpen.mem_nhds (LocalHomeomorph.open_source _) (mem_chart_source H' (f x))
      rcases mem_nhdsWithin.1 (h.1.preimage_mem_nhdsWithin this) with ⟨u, u_open, xu, hu⟩
      refine' ⟨u ∩ (chart_at H x).source, _, ⟨xu, mem_chart_source _ _⟩, _, _⟩
      · exact IsOpen.inter u_open (LocalHomeomorph.open_source _)
      · intro y hy; exact hy.2
      · intro y hy; exact hu ⟨hy.1.1, hy.2⟩
    have h' : ContMDiffWithinAt I I' n f (s ∩ o) x := h.mono (inter_subset_left _ _)
    simp only [ContMDiffWithinAt, lift_prop_within_at, ContDiffWithinAtProp] at h' 
    -- let `u` be a good neighborhood in the chart where the function is smooth
    rcases h.2.ContDiffOn le_rfl with ⟨u, u_nhds, u_subset, hu⟩
    -- pull it back to the manifold, and intersect with a suitable neighborhood of `x`, to get the
    -- desired good neighborhood `v`.
    let v := insert x s ∩ o ∩ extChartAt I x ⁻¹' u
    have v_incl : v ⊆ (chart_at H x).source := fun y hy => ho hy.1.2
    have v_incl' : ∀ y ∈ v, f y ∈ (chart_at H' (f x)).source :=
      by
      intro y hy
      rcases hy.1.1 with (rfl | h')
      · simp only [mfld_simps]
      · apply h'o ⟨hy.1.2, h'⟩
    refine' ⟨v, _, _⟩
    show v ∈ 𝓝[insert x s] x
    · rw [nhdsWithin_restrict _ xo o_open]
      refine' Filter.inter_mem self_mem_nhdsWithin _
      suffices : u ∈ 𝓝[extChartAt I x '' (insert x s ∩ o)] extChartAt I x x
      exact (continuousAt_extChartAt I x).ContinuousWithinAt.preimage_mem_nhdsWithin' this
      apply nhdsWithin_mono _ _ u_nhds
      rw [image_subset_iff]
      intro y hy
      rcases hy.1 with (rfl | h')
      · simp only [mem_insert_iff, mfld_simps]
      · simp only [mem_insert_iff, ho hy.2, h', h'o ⟨hy.2, h'⟩, mfld_simps]
    show ContMDiffOn I I' n f v
    · intro y hy
      have : ContinuousWithinAt f v y :=
        by
        apply
          (((continuousOn_extChartAt_symm I' (f x) _ _).comp' (hu _ hy.2).ContinuousWithinAt).comp'
              (continuousOn_extChartAt I x _ _)).congr_mono
        · intro z hz
          simp only [v_incl hz, v_incl' z hz, mfld_simps]
        · intro z hz
          simp only [v_incl hz, v_incl' z hz, mfld_simps]
          exact hz.2
        · simp only [v_incl hy, v_incl' y hy, mfld_simps]
        · simp only [v_incl hy, v_incl' y hy, mfld_simps]
        · simp only [v_incl hy, mfld_simps]
      refine' (contMDiffWithinAt_iff_of_mem_source' (v_incl hy) (v_incl' y hy)).mpr ⟨this, _⟩
      · apply hu.mono
        · intro z hz
          simp only [v, mfld_simps] at hz 
          have : I ((chart_at H x) ((chart_at H x).symm (I.symm z))) ∈ u := by simp only [hz]
          simpa only [hz, mfld_simps] using this
        · have exty : I (chart_at H x y) ∈ u := hy.2
          simp only [v_incl hy, v_incl' y hy, exty, hy.1.1, hy.1.2, mfld_simps]
  · rintro ⟨u, u_nhds, hu⟩
    have : ContMDiffWithinAt I I' (↑n) f (insert x s ∩ u) x :=
      haveI : x ∈ insert x s := mem_insert x s
      hu.mono (inter_subset_right _ _) _ ⟨this, mem_of_mem_nhdsWithin this u_nhds⟩
    rw [contMDiffWithinAt_inter' u_nhds] at this 
    exact this.mono (subset_insert x s)
#align cont_mdiff_within_at_iff_cont_mdiff_on_nhds contMDiffWithinAt_iff_contMDiffOn_nhds
-/

#print contMDiffAt_iff_contMDiffOn_nhds /-
/-- A function is `C^n` at a point, for `n : ℕ`, if and only if it is `C^n` on
a neighborhood of this point. -/
theorem contMDiffAt_iff_contMDiffOn_nhds {n : ℕ} :
    ContMDiffAt I I' n f x ↔ ∃ u ∈ 𝓝 x, ContMDiffOn I I' n f u := by
  simp [← contMDiffWithinAt_univ, contMDiffWithinAt_iff_contMDiffOn_nhds, nhdsWithin_univ]
#align cont_mdiff_at_iff_cont_mdiff_on_nhds contMDiffAt_iff_contMDiffOn_nhds
-/

#print contMDiffAt_iff_contMDiffAt_nhds /-
/-- Note: This does not hold for `n = ∞`. `f` being `C^∞` at `x` means that for every `n`, `f` is
`C^n` on some neighborhood of `x`, but this neighborhood can depend on `n`. -/
theorem contMDiffAt_iff_contMDiffAt_nhds {n : ℕ} :
    ContMDiffAt I I' n f x ↔ ∀ᶠ x' in 𝓝 x, ContMDiffAt I I' n f x' :=
  by
  refine' ⟨_, fun h => h.self_of_nhds⟩
  rw [contMDiffAt_iff_contMDiffOn_nhds]
  rintro ⟨u, hu, h⟩
  refine' (eventually_mem_nhds.mpr hu).mono fun x' hx' => _
  exact (h x' <| mem_of_mem_nhds hx').ContMDiffAt hx'
#align cont_mdiff_at_iff_cont_mdiff_at_nhds contMDiffAt_iff_contMDiffAt_nhds
-/

/-! ### Congruence lemmas -/


#print ContMDiffWithinAt.congr /-
theorem ContMDiffWithinAt.congr (h : ContMDiffWithinAt I I' n f s x) (h₁ : ∀ y ∈ s, f₁ y = f y)
    (hx : f₁ x = f x) : ContMDiffWithinAt I I' n f₁ s x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_congr h h₁ hx
#align cont_mdiff_within_at.congr ContMDiffWithinAt.congr
-/

#print contMDiffWithinAt_congr /-
theorem contMDiffWithinAt_congr (h₁ : ∀ y ∈ s, f₁ y = f y) (hx : f₁ x = f x) :
    ContMDiffWithinAt I I' n f₁ s x ↔ ContMDiffWithinAt I I' n f s x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_congr_iff h₁ hx
#align cont_mdiff_within_at_congr contMDiffWithinAt_congr
-/

#print ContMDiffWithinAt.congr_of_eventuallyEq /-
theorem ContMDiffWithinAt.congr_of_eventuallyEq (h : ContMDiffWithinAt I I' n f s x)
    (h₁ : f₁ =ᶠ[𝓝[s] x] f) (hx : f₁ x = f x) : ContMDiffWithinAt I I' n f₁ s x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_congr_of_eventuallyEq h h₁ hx
#align cont_mdiff_within_at.congr_of_eventually_eq ContMDiffWithinAt.congr_of_eventuallyEq
-/

#print Filter.EventuallyEq.contMDiffWithinAt_iff /-
theorem Filter.EventuallyEq.contMDiffWithinAt_iff (h₁ : f₁ =ᶠ[𝓝[s] x] f) (hx : f₁ x = f x) :
    ContMDiffWithinAt I I' n f₁ s x ↔ ContMDiffWithinAt I I' n f s x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropWithinAt_congr_iff_of_eventuallyEq h₁ hx
#align filter.eventually_eq.cont_mdiff_within_at_iff Filter.EventuallyEq.contMDiffWithinAt_iff
-/

#print ContMDiffAt.congr_of_eventuallyEq /-
theorem ContMDiffAt.congr_of_eventuallyEq (h : ContMDiffAt I I' n f x) (h₁ : f₁ =ᶠ[𝓝 x] f) :
    ContMDiffAt I I' n f₁ x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropAt_congr_of_eventuallyEq h h₁
#align cont_mdiff_at.congr_of_eventually_eq ContMDiffAt.congr_of_eventuallyEq
-/

#print Filter.EventuallyEq.contMDiffAt_iff /-
theorem Filter.EventuallyEq.contMDiffAt_iff (h₁ : f₁ =ᶠ[𝓝 x] f) :
    ContMDiffAt I I' n f₁ x ↔ ContMDiffAt I I' n f x :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropAt_congr_iff_of_eventuallyEq h₁
#align filter.eventually_eq.cont_mdiff_at_iff Filter.EventuallyEq.contMDiffAt_iff
-/

#print ContMDiffOn.congr /-
theorem ContMDiffOn.congr (h : ContMDiffOn I I' n f s) (h₁ : ∀ y ∈ s, f₁ y = f y) :
    ContMDiffOn I I' n f₁ s :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropOn_congr h h₁
#align cont_mdiff_on.congr ContMDiffOn.congr
-/

#print contMDiffOn_congr /-
theorem contMDiffOn_congr (h₁ : ∀ y ∈ s, f₁ y = f y) :
    ContMDiffOn I I' n f₁ s ↔ ContMDiffOn I I' n f s :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropOn_congr_iff h₁
#align cont_mdiff_on_congr contMDiffOn_congr
-/

/-! ### Locality -/


#print contMDiffOn_of_locally_contMDiffOn /-
/-- Being `C^n` is a local property. -/
theorem contMDiffOn_of_locally_contMDiffOn
    (h : ∀ x ∈ s, ∃ u, IsOpen u ∧ x ∈ u ∧ ContMDiffOn I I' n f (s ∩ u)) : ContMDiffOn I I' n f s :=
  (contDiffWithinAt_localInvariantProp I I' n).liftPropOn_of_locally_liftPropOn h
#align cont_mdiff_on_of_locally_cont_mdiff_on contMDiffOn_of_locally_contMDiffOn
-/

#print contMDiff_of_locally_contMDiffOn /-
theorem contMDiff_of_locally_contMDiffOn (h : ∀ x, ∃ u, IsOpen u ∧ x ∈ u ∧ ContMDiffOn I I' n f u) :
    ContMDiff I I' n f :=
  (contDiffWithinAt_localInvariantProp I I' n).liftProp_of_locally_liftPropOn h
#align cont_mdiff_of_locally_cont_mdiff_on contMDiff_of_locally_contMDiffOn
-/

/-! ### Smoothness of the composition of smooth functions between manifolds -/


section Composition

#print ContMDiffWithinAt.comp /-
/-- The composition of `C^n` functions within domains at points is `C^n`. -/
theorem ContMDiffWithinAt.comp {t : Set M'} {g : M' → M''} (x : M)
    (hg : ContMDiffWithinAt I' I'' n g t (f x)) (hf : ContMDiffWithinAt I I' n f s x)
    (st : MapsTo f s t) : ContMDiffWithinAt I I'' n (g ∘ f) s x :=
  by
  rw [contMDiffWithinAt_iff] at hg hf ⊢
  refine' ⟨hg.1.comp hf.1 st, _⟩
  set e := extChartAt I x
  set e' := extChartAt I' (f x)
  set e'' := extChartAt I'' (g (f x))
  have : e' (f x) = (writtenInExtChartAt I I' x f) (e x) := by simp only [e, e', mfld_simps]
  rw [this] at hg 
  have A :
    ∀ᶠ y in 𝓝[e.symm ⁻¹' s ∩ range I] e x,
      y ∈ e.target ∧ f (e.symm y) ∈ t ∧ f (e.symm y) ∈ e'.source ∧ g (f (e.symm y)) ∈ e''.source :=
    by
    simp only [← map_extChartAt_nhdsWithin, eventually_map]
    filter_upwards [hf.1.Tendsto (extChartAt_source_mem_nhds I' (f x)),
      (hg.1.comp hf.1 st).Tendsto (extChartAt_source_mem_nhds I'' (g (f x))),
      inter_mem_nhdsWithin s (extChartAt_source_mem_nhds I x)]
    rintro x' (hfx' : f x' ∈ _) (hgfx' : g (f x') ∈ _) ⟨hx's, hx'⟩
    simp only [e.map_source hx', true_and_iff, e.left_inv hx', st hx's, *]
  refine'
    ((hg.2.comp _ (hf.2.mono (inter_subset_right _ _)) (inter_subset_left _ _)).mono_of_mem
          (inter_mem _ self_mem_nhdsWithin)).congr_of_eventuallyEq
      _ _
  · filter_upwards [A]
    rintro x' ⟨hx', ht, hfx', hgfx'⟩
    simp only [*, mem_preimage, writtenInExtChartAt, (· ∘ ·), mem_inter_iff, e'.left_inv,
      true_and_iff]
    exact mem_range_self _
  · filter_upwards [A]
    rintro x' ⟨hx', ht, hfx', hgfx'⟩
    simp only [*, (· ∘ ·), writtenInExtChartAt, e'.left_inv]
  · simp only [writtenInExtChartAt, (· ∘ ·), mem_extChartAt_source, e.left_inv, e'.left_inv]
#align cont_mdiff_within_at.comp ContMDiffWithinAt.comp
-/

#print ContMDiffWithinAt.comp_of_eq /-
/-- See note [comp_of_eq lemmas] -/
theorem ContMDiffWithinAt.comp_of_eq {t : Set M'} {g : M' → M''} {x : M} {y : M'}
    (hg : ContMDiffWithinAt I' I'' n g t y) (hf : ContMDiffWithinAt I I' n f s x)
    (st : MapsTo f s t) (hx : f x = y) : ContMDiffWithinAt I I'' n (g ∘ f) s x := by subst hx;
  exact hg.comp x hf st
#align cont_mdiff_within_at.comp_of_eq ContMDiffWithinAt.comp_of_eq
-/

#print SmoothWithinAt.comp /-
/-- The composition of `C^∞` functions within domains at points is `C^∞`. -/
theorem SmoothWithinAt.comp {t : Set M'} {g : M' → M''} (x : M)
    (hg : SmoothWithinAt I' I'' g t (f x)) (hf : SmoothWithinAt I I' f s x) (st : MapsTo f s t) :
    SmoothWithinAt I I'' (g ∘ f) s x :=
  hg.comp x hf st
#align smooth_within_at.comp SmoothWithinAt.comp
-/

#print ContMDiffOn.comp /-
/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem ContMDiffOn.comp {t : Set M'} {g : M' → M''} (hg : ContMDiffOn I' I'' n g t)
    (hf : ContMDiffOn I I' n f s) (st : s ⊆ f ⁻¹' t) : ContMDiffOn I I'' n (g ∘ f) s := fun x hx =>
  (hg _ (st hx)).comp x (hf x hx) st
#align cont_mdiff_on.comp ContMDiffOn.comp
-/

#print SmoothOn.comp /-
/-- The composition of `C^∞` functions on domains is `C^∞`. -/
theorem SmoothOn.comp {t : Set M'} {g : M' → M''} (hg : SmoothOn I' I'' g t)
    (hf : SmoothOn I I' f s) (st : s ⊆ f ⁻¹' t) : SmoothOn I I'' (g ∘ f) s :=
  hg.comp hf st
#align smooth_on.comp SmoothOn.comp
-/

#print ContMDiffOn.comp' /-
/-- The composition of `C^n` functions on domains is `C^n`. -/
theorem ContMDiffOn.comp' {t : Set M'} {g : M' → M''} (hg : ContMDiffOn I' I'' n g t)
    (hf : ContMDiffOn I I' n f s) : ContMDiffOn I I'' n (g ∘ f) (s ∩ f ⁻¹' t) :=
  hg.comp (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align cont_mdiff_on.comp' ContMDiffOn.comp'
-/

#print SmoothOn.comp' /-
/-- The composition of `C^∞` functions is `C^∞`. -/
theorem SmoothOn.comp' {t : Set M'} {g : M' → M''} (hg : SmoothOn I' I'' g t)
    (hf : SmoothOn I I' f s) : SmoothOn I I'' (g ∘ f) (s ∩ f ⁻¹' t) :=
  hg.comp' hf
#align smooth_on.comp' SmoothOn.comp'
-/

#print ContMDiff.comp /-
/-- The composition of `C^n` functions is `C^n`. -/
theorem ContMDiff.comp {g : M' → M''} (hg : ContMDiff I' I'' n g) (hf : ContMDiff I I' n f) :
    ContMDiff I I'' n (g ∘ f) :=
  by
  rw [← contMDiffOn_univ] at hf hg ⊢
  exact hg.comp hf subset_preimage_univ
#align cont_mdiff.comp ContMDiff.comp
-/

#print Smooth.comp /-
/-- The composition of `C^∞` functions is `C^∞`. -/
theorem Smooth.comp {g : M' → M''} (hg : Smooth I' I'' g) (hf : Smooth I I' f) :
    Smooth I I'' (g ∘ f) :=
  hg.comp hf
#align smooth.comp Smooth.comp
-/

#print ContMDiffWithinAt.comp' /-
/-- The composition of `C^n` functions within domains at points is `C^n`. -/
theorem ContMDiffWithinAt.comp' {t : Set M'} {g : M' → M''} (x : M)
    (hg : ContMDiffWithinAt I' I'' n g t (f x)) (hf : ContMDiffWithinAt I I' n f s x) :
    ContMDiffWithinAt I I'' n (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp x (hf.mono (inter_subset_left _ _)) (inter_subset_right _ _)
#align cont_mdiff_within_at.comp' ContMDiffWithinAt.comp'
-/

#print SmoothWithinAt.comp' /-
/-- The composition of `C^∞` functions within domains at points is `C^∞`. -/
theorem SmoothWithinAt.comp' {t : Set M'} {g : M' → M''} (x : M)
    (hg : SmoothWithinAt I' I'' g t (f x)) (hf : SmoothWithinAt I I' f s x) :
    SmoothWithinAt I I'' (g ∘ f) (s ∩ f ⁻¹' t) x :=
  hg.comp' x hf
#align smooth_within_at.comp' SmoothWithinAt.comp'
-/

#print ContMDiffAt.comp_contMDiffWithinAt /-
/-- `g ∘ f` is `C^n` within `s` at `x` if `g` is `C^n` at `f x` and
`f` is `C^n` within `s` at `x`. -/
theorem ContMDiffAt.comp_contMDiffWithinAt {g : M' → M''} (x : M)
    (hg : ContMDiffAt I' I'' n g (f x)) (hf : ContMDiffWithinAt I I' n f s x) :
    ContMDiffWithinAt I I'' n (g ∘ f) s x :=
  hg.comp x hf (mapsTo_univ _ _)
#align cont_mdiff_at.comp_cont_mdiff_within_at ContMDiffAt.comp_contMDiffWithinAt
-/

#print SmoothAt.comp_smoothWithinAt /-
/-- `g ∘ f` is `C^∞` within `s` at `x` if `g` is `C^∞` at `f x` and
`f` is `C^∞` within `s` at `x`. -/
theorem SmoothAt.comp_smoothWithinAt {g : M' → M''} (x : M) (hg : SmoothAt I' I'' g (f x))
    (hf : SmoothWithinAt I I' f s x) : SmoothWithinAt I I'' (g ∘ f) s x :=
  hg.comp_contMDiffWithinAt x hf
#align smooth_at.comp_smooth_within_at SmoothAt.comp_smoothWithinAt
-/

#print ContMDiffAt.comp /-
/-- The composition of `C^n` functions at points is `C^n`. -/
theorem ContMDiffAt.comp {g : M' → M''} (x : M) (hg : ContMDiffAt I' I'' n g (f x))
    (hf : ContMDiffAt I I' n f x) : ContMDiffAt I I'' n (g ∘ f) x :=
  hg.comp x hf (mapsTo_univ _ _)
#align cont_mdiff_at.comp ContMDiffAt.comp
-/

#print ContMDiffAt.comp_of_eq /-
/-- See note [comp_of_eq lemmas] -/
theorem ContMDiffAt.comp_of_eq {g : M' → M''} {x : M} {y : M'} (hg : ContMDiffAt I' I'' n g y)
    (hf : ContMDiffAt I I' n f x) (hx : f x = y) : ContMDiffAt I I'' n (g ∘ f) x := by subst hx;
  exact hg.comp x hf
#align cont_mdiff_at.comp_of_eq ContMDiffAt.comp_of_eq
-/

#print SmoothAt.comp /-
/-- The composition of `C^∞` functions at points is `C^∞`. -/
theorem SmoothAt.comp {g : M' → M''} (x : M) (hg : SmoothAt I' I'' g (f x))
    (hf : SmoothAt I I' f x) : SmoothAt I I'' (g ∘ f) x :=
  hg.comp x hf
#align smooth_at.comp SmoothAt.comp
-/

#print ContMDiff.comp_contMDiffOn /-
theorem ContMDiff.comp_contMDiffOn {f : M → M'} {g : M' → M''} {s : Set M}
    (hg : ContMDiff I' I'' n g) (hf : ContMDiffOn I I' n f s) : ContMDiffOn I I'' n (g ∘ f) s :=
  hg.ContMDiffOn.comp hf Set.subset_preimage_univ
#align cont_mdiff.comp_cont_mdiff_on ContMDiff.comp_contMDiffOn
-/

#print Smooth.comp_smoothOn /-
theorem Smooth.comp_smoothOn {f : M → M'} {g : M' → M''} {s : Set M} (hg : Smooth I' I'' g)
    (hf : SmoothOn I I' f s) : SmoothOn I I'' (g ∘ f) s :=
  hg.SmoothOn.comp hf Set.subset_preimage_univ
#align smooth.comp_smooth_on Smooth.comp_smoothOn
-/

#print ContMDiffOn.comp_contMDiff /-
theorem ContMDiffOn.comp_contMDiff {t : Set M'} {g : M' → M''} (hg : ContMDiffOn I' I'' n g t)
    (hf : ContMDiff I I' n f) (ht : ∀ x, f x ∈ t) : ContMDiff I I'' n (g ∘ f) :=
  contMDiffOn_univ.mp <| hg.comp hf.ContMDiffOn fun x _ => ht x
#align cont_mdiff_on.comp_cont_mdiff ContMDiffOn.comp_contMDiff
-/

#print SmoothOn.comp_smooth /-
theorem SmoothOn.comp_smooth {t : Set M'} {g : M' → M''} (hg : SmoothOn I' I'' g t)
    (hf : Smooth I I' f) (ht : ∀ x, f x ∈ t) : Smooth I I'' (g ∘ f) :=
  hg.comp_contMDiff hf ht
#align smooth_on.comp_smooth SmoothOn.comp_smooth
-/

end Composition

/-! ### Atlas members are smooth -/


section Atlas

#print contMDiff_model /-
theorem contMDiff_model : ContMDiff I 𝓘(𝕜, E) n I :=
  by
  intro x
  refine' (contMDiffAt_iff _ _).mpr ⟨I.continuous_at, _⟩
  simp only [mfld_simps]
  refine' cont_diff_within_at_id.congr_of_eventually_eq _ _
  · exact eventually_eq_of_mem self_mem_nhdsWithin fun x₂ => I.right_inv
  simp_rw [Function.comp_apply, I.left_inv, id_def]
#align cont_mdiff_model contMDiff_model
-/

#print contMDiffOn_model_symm /-
theorem contMDiffOn_model_symm : ContMDiffOn 𝓘(𝕜, E) I n I.symm (range I) :=
  by
  rw [contMDiffOn_iff]
  refine' ⟨I.continuous_on_symm, fun x y => _⟩
  simp only [mfld_simps]
  exact cont_diff_on_id.congr fun x' => I.right_inv
#align cont_mdiff_on_model_symm contMDiffOn_model_symm
-/

#print contMDiffOn_of_mem_maximalAtlas /-
/-- An atlas member is `C^n` for any `n`. -/
theorem contMDiffOn_of_mem_maximalAtlas (h : e ∈ maximalAtlas I M) : ContMDiffOn I I n e e.source :=
  ContMDiffOn.of_le
    ((contDiffWithinAt_localInvariantProp I I ∞).liftPropOn_of_mem_maximalAtlas
      (contDiffWithinAtProp_id I) h)
    le_top
#align cont_mdiff_on_of_mem_maximal_atlas contMDiffOn_of_mem_maximalAtlas
-/

#print contMDiffOn_symm_of_mem_maximalAtlas /-
/-- The inverse of an atlas member is `C^n` for any `n`. -/
theorem contMDiffOn_symm_of_mem_maximalAtlas (h : e ∈ maximalAtlas I M) :
    ContMDiffOn I I n e.symm e.target :=
  ContMDiffOn.of_le
    ((contDiffWithinAt_localInvariantProp I I ∞).liftPropOn_symm_of_mem_maximalAtlas
      (contDiffWithinAtProp_id I) h)
    le_top
#align cont_mdiff_on_symm_of_mem_maximal_atlas contMDiffOn_symm_of_mem_maximalAtlas
-/

#print contMDiffAt_of_mem_maximalAtlas /-
theorem contMDiffAt_of_mem_maximalAtlas (h : e ∈ maximalAtlas I M) (hx : x ∈ e.source) :
    ContMDiffAt I I n e x :=
  (contMDiffOn_of_mem_maximalAtlas h).ContMDiffAt <| e.open_source.mem_nhds hx
#align cont_mdiff_at_of_mem_maximal_atlas contMDiffAt_of_mem_maximalAtlas
-/

#print contMDiffAt_symm_of_mem_maximalAtlas /-
theorem contMDiffAt_symm_of_mem_maximalAtlas {x : H} (h : e ∈ maximalAtlas I M)
    (hx : x ∈ e.target) : ContMDiffAt I I n e.symm x :=
  (contMDiffOn_symm_of_mem_maximalAtlas h).ContMDiffAt <| e.open_target.mem_nhds hx
#align cont_mdiff_at_symm_of_mem_maximal_atlas contMDiffAt_symm_of_mem_maximalAtlas
-/

#print contMDiffOn_chart /-
theorem contMDiffOn_chart : ContMDiffOn I I n (chartAt H x) (chartAt H x).source :=
  contMDiffOn_of_mem_maximalAtlas <| chart_mem_maximalAtlas I x
#align cont_mdiff_on_chart contMDiffOn_chart
-/

#print contMDiffOn_chart_symm /-
theorem contMDiffOn_chart_symm : ContMDiffOn I I n (chartAt H x).symm (chartAt H x).target :=
  contMDiffOn_symm_of_mem_maximalAtlas <| chart_mem_maximalAtlas I x
#align cont_mdiff_on_chart_symm contMDiffOn_chart_symm
-/

#print contMDiffAt_extend /-
theorem contMDiffAt_extend {x : M} (he : e ∈ maximalAtlas I M) (hx : x ∈ e.source) :
    ContMDiffAt I 𝓘(𝕜, E) n (e.extend I) x :=
  (contMDiff_model _).comp x <| contMDiffAt_of_mem_maximalAtlas he hx
#align cont_mdiff_at_extend contMDiffAt_extend
-/

#print contMDiffAt_extChartAt' /-
theorem contMDiffAt_extChartAt' {x' : M} (h : x' ∈ (chartAt H x).source) :
    ContMDiffAt I 𝓘(𝕜, E) n (extChartAt I x) x' :=
  contMDiffAt_extend (chart_mem_maximalAtlas I x) h
#align cont_mdiff_at_ext_chart_at' contMDiffAt_extChartAt'
-/

#print contMDiffAt_extChartAt /-
theorem contMDiffAt_extChartAt : ContMDiffAt I 𝓘(𝕜, E) n (extChartAt I x) x :=
  contMDiffAt_extChartAt' <| mem_chart_source H x
#align cont_mdiff_at_ext_chart_at contMDiffAt_extChartAt
-/

#print contMDiffOn_extChartAt /-
theorem contMDiffOn_extChartAt : ContMDiffOn I 𝓘(𝕜, E) n (extChartAt I x) (chartAt H x).source :=
  fun x' hx' => (contMDiffAt_extChartAt' hx').ContMDiffWithinAt
#align cont_mdiff_on_ext_chart_at contMDiffOn_extChartAt
-/

#print contMDiffOn_extend_symm /-
theorem contMDiffOn_extend_symm (he : e ∈ maximalAtlas I M) :
    ContMDiffOn 𝓘(𝕜, E) I n (e.extend I).symm (I '' e.target) :=
  by
  have h2 := contMDiffOn_symm_of_mem_maximalAtlas he
  refine' h2.comp (cont_mdiff_on_model_symm.mono <| image_subset_range _ _) _
  simp_rw [image_subset_iff, LocalEquiv.restr_coe_symm, I.to_local_equiv_coe_symm,
    preimage_preimage, I.left_inv, preimage_id']
#align cont_mdiff_on_extend_symm contMDiffOn_extend_symm
-/

#print contMDiffOn_extChartAt_symm /-
theorem contMDiffOn_extChartAt_symm (x : M) :
    ContMDiffOn 𝓘(𝕜, E) I n (extChartAt I x).symm (extChartAt I x).target :=
  by
  convert contMDiffOn_extend_symm (chart_mem_maximal_atlas I x)
  rw [extChartAt_target, I.image_eq]
#align cont_mdiff_on_ext_chart_at_symm contMDiffOn_extChartAt_symm
-/

#print contMDiffOn_of_mem_contDiffGroupoid /-
/-- An element of `cont_diff_groupoid ⊤ I` is `C^n` for any `n`. -/
theorem contMDiffOn_of_mem_contDiffGroupoid {e' : LocalHomeomorph H H}
    (h : e' ∈ contDiffGroupoid ⊤ I) : ContMDiffOn I I n e' e'.source :=
  (contDiffWithinAt_localInvariantProp I I n).liftPropOn_of_mem_groupoid (contDiffWithinAtProp_id I)
    h
#align cont_mdiff_on_of_mem_cont_diff_groupoid contMDiffOn_of_mem_contDiffGroupoid
-/

end Atlas

/-! ### The identity is smooth -/


section id

#print contMDiff_id /-
theorem contMDiff_id : ContMDiff I I n (id : M → M) :=
  ContMDiff.of_le
    ((contDiffWithinAt_localInvariantProp I I ∞).liftProp_id (contDiffWithinAtProp_id I)) le_top
#align cont_mdiff_id contMDiff_id
-/

#print smooth_id /-
theorem smooth_id : Smooth I I (id : M → M) :=
  contMDiff_id
#align smooth_id smooth_id
-/

#print contMDiffOn_id /-
theorem contMDiffOn_id : ContMDiffOn I I n (id : M → M) s :=
  contMDiff_id.ContMDiffOn
#align cont_mdiff_on_id contMDiffOn_id
-/

#print smoothOn_id /-
theorem smoothOn_id : SmoothOn I I (id : M → M) s :=
  contMDiffOn_id
#align smooth_on_id smoothOn_id
-/

#print contMDiffAt_id /-
theorem contMDiffAt_id : ContMDiffAt I I n (id : M → M) x :=
  contMDiff_id.ContMDiffAt
#align cont_mdiff_at_id contMDiffAt_id
-/

#print smoothAt_id /-
theorem smoothAt_id : SmoothAt I I (id : M → M) x :=
  contMDiffAt_id
#align smooth_at_id smoothAt_id
-/

#print contMDiffWithinAt_id /-
theorem contMDiffWithinAt_id : ContMDiffWithinAt I I n (id : M → M) s x :=
  contMDiffAt_id.ContMDiffWithinAt
#align cont_mdiff_within_at_id contMDiffWithinAt_id
-/

#print smoothWithinAt_id /-
theorem smoothWithinAt_id : SmoothWithinAt I I (id : M → M) s x :=
  contMDiffWithinAt_id
#align smooth_within_at_id smoothWithinAt_id
-/

end id

/-! ### Constants are smooth -/


section id

variable {c : M'}

#print contMDiff_const /-
theorem contMDiff_const : ContMDiff I I' n fun x : M => c :=
  by
  intro x
  refine' ⟨continuousWithinAt_const, _⟩
  simp only [ContDiffWithinAtProp, (· ∘ ·)]
  exact contDiffWithinAt_const
#align cont_mdiff_const contMDiff_const
-/

#print contMDiff_one /-
@[to_additive]
theorem contMDiff_one [One M'] : ContMDiff I I' n (1 : M → M') := by
  simp only [Pi.one_def, contMDiff_const]
#align cont_mdiff_one contMDiff_one
#align cont_mdiff_zero contMDiff_zero
-/

#print smooth_const /-
theorem smooth_const : Smooth I I' fun x : M => c :=
  contMDiff_const
#align smooth_const smooth_const
-/

#print smooth_one /-
@[to_additive]
theorem smooth_one [One M'] : Smooth I I' (1 : M → M') := by simp only [Pi.one_def, smooth_const]
#align smooth_one smooth_one
#align smooth_zero smooth_zero
-/

#print contMDiffOn_const /-
theorem contMDiffOn_const : ContMDiffOn I I' n (fun x : M => c) s :=
  contMDiff_const.ContMDiffOn
#align cont_mdiff_on_const contMDiffOn_const
-/

#print contMDiffOn_one /-
@[to_additive]
theorem contMDiffOn_one [One M'] : ContMDiffOn I I' n (1 : M → M') s :=
  contMDiff_one.ContMDiffOn
#align cont_mdiff_on_one contMDiffOn_one
#align cont_mdiff_on_zero contMDiffOn_zero
-/

#print smoothOn_const /-
theorem smoothOn_const : SmoothOn I I' (fun x : M => c) s :=
  contMDiffOn_const
#align smooth_on_const smoothOn_const
-/

#print smoothOn_one /-
@[to_additive]
theorem smoothOn_one [One M'] : SmoothOn I I' (1 : M → M') s :=
  contMDiffOn_one
#align smooth_on_one smoothOn_one
#align smooth_on_zero smoothOn_zero
-/

#print contMDiffAt_const /-
theorem contMDiffAt_const : ContMDiffAt I I' n (fun x : M => c) x :=
  contMDiff_const.ContMDiffAt
#align cont_mdiff_at_const contMDiffAt_const
-/

#print contMDiffAt_one /-
@[to_additive]
theorem contMDiffAt_one [One M'] : ContMDiffAt I I' n (1 : M → M') x :=
  contMDiff_one.ContMDiffAt
#align cont_mdiff_at_one contMDiffAt_one
#align cont_mdiff_at_zero contMDiffAt_zero
-/

#print smoothAt_const /-
theorem smoothAt_const : SmoothAt I I' (fun x : M => c) x :=
  contMDiffAt_const
#align smooth_at_const smoothAt_const
-/

#print smoothAt_one /-
@[to_additive]
theorem smoothAt_one [One M'] : SmoothAt I I' (1 : M → M') x :=
  contMDiffAt_one
#align smooth_at_one smoothAt_one
#align smooth_at_zero smoothAt_zero
-/

#print contMDiffWithinAt_const /-
theorem contMDiffWithinAt_const : ContMDiffWithinAt I I' n (fun x : M => c) s x :=
  contMDiffAt_const.ContMDiffWithinAt
#align cont_mdiff_within_at_const contMDiffWithinAt_const
-/

#print contMDiffWithinAt_one /-
@[to_additive]
theorem contMDiffWithinAt_one [One M'] : ContMDiffWithinAt I I' n (1 : M → M') s x :=
  contMDiffAt_const.ContMDiffWithinAt
#align cont_mdiff_within_at_one contMDiffWithinAt_one
#align cont_mdiff_within_at_zero contMDiffWithinAt_zero
-/

#print smoothWithinAt_const /-
theorem smoothWithinAt_const : SmoothWithinAt I I' (fun x : M => c) s x :=
  contMDiffWithinAt_const
#align smooth_within_at_const smoothWithinAt_const
-/

#print smoothWithinAt_one /-
@[to_additive]
theorem smoothWithinAt_one [One M'] : SmoothWithinAt I I' (1 : M → M') s x :=
  contMDiffWithinAt_one
#align smooth_within_at_one smoothWithinAt_one
#align smooth_within_at_zero smoothWithinAt_zero
-/

end id

#print contMDiff_of_support /-
theorem contMDiff_of_support {f : M → F} (hf : ∀ x ∈ tsupport f, ContMDiffAt I 𝓘(𝕜, F) n f x) :
    ContMDiff I 𝓘(𝕜, F) n f := by
  intro x
  by_cases hx : x ∈ tsupport f
  · exact hf x hx
  · refine' ContMDiffAt.congr_of_eventuallyEq _ (eventuallyEq_zero_nhds.2 hx)
    exact contMDiffAt_const
#align cont_mdiff_of_support contMDiff_of_support
-/

/-! ### The inclusion map from one open set to another is smooth -/


section

open TopologicalSpace

#print contMDiff_inclusion /-
theorem contMDiff_inclusion {n : ℕ∞} {U V : Opens M} (h : U ≤ V) :
    ContMDiff I I n (Set.inclusion h : U → V) :=
  by
  rintro ⟨x, hx : x ∈ U⟩
  apply (contDiffWithinAt_localInvariantProp I I n).liftProp_inclusion
  intro y
  dsimp [ContDiffWithinAtProp]
  rw [Set.univ_inter]
  refine' cont_diff_within_at_id.congr _ _
  · exact I.right_inv_on
  · exact congr_arg I (I.left_inv y)
#align cont_mdiff_inclusion contMDiff_inclusion
-/

#print smooth_inclusion /-
theorem smooth_inclusion {U V : Opens M} (h : U ≤ V) : Smooth I I (Set.inclusion h : U → V) :=
  contMDiff_inclusion h
#align smooth_inclusion smooth_inclusion
-/

end

/-! ### Equivalence with the basic definition for functions between vector spaces -/


section Module

#print contMDiffWithinAt_iff_contDiffWithinAt /-
theorem contMDiffWithinAt_iff_contDiffWithinAt {f : E → E'} {s : Set E} {x : E} :
    ContMDiffWithinAt 𝓘(𝕜, E) 𝓘(𝕜, E') n f s x ↔ ContDiffWithinAt 𝕜 n f s x :=
  by
  simp (config := { contextual := true }) only [ContMDiffWithinAt, lift_prop_within_at,
    ContDiffWithinAtProp, iff_def, mfld_simps]
  exact ContDiffWithinAt.continuousWithinAt
#align cont_mdiff_within_at_iff_cont_diff_within_at contMDiffWithinAt_iff_contDiffWithinAt
-/

alias contMDiffWithinAt_iff_contDiffWithinAt ↔ ContMDiffWithinAt.contDiffWithinAt
  ContDiffWithinAt.contMDiffWithinAt
#align cont_mdiff_within_at.cont_diff_within_at ContMDiffWithinAt.contDiffWithinAt
#align cont_diff_within_at.cont_mdiff_within_at ContDiffWithinAt.contMDiffWithinAt

#print contMDiffAt_iff_contDiffAt /-
theorem contMDiffAt_iff_contDiffAt {f : E → E'} {x : E} :
    ContMDiffAt 𝓘(𝕜, E) 𝓘(𝕜, E') n f x ↔ ContDiffAt 𝕜 n f x := by
  rw [← contMDiffWithinAt_univ, contMDiffWithinAt_iff_contDiffWithinAt, contDiffWithinAt_univ]
#align cont_mdiff_at_iff_cont_diff_at contMDiffAt_iff_contDiffAt
-/

alias contMDiffAt_iff_contDiffAt ↔ ContMDiffAt.contDiffAt ContDiffAt.contMDiffAt
#align cont_mdiff_at.cont_diff_at ContMDiffAt.contDiffAt
#align cont_diff_at.cont_mdiff_at ContDiffAt.contMDiffAt

#print contMDiffOn_iff_contDiffOn /-
theorem contMDiffOn_iff_contDiffOn {f : E → E'} {s : Set E} :
    ContMDiffOn 𝓘(𝕜, E) 𝓘(𝕜, E') n f s ↔ ContDiffOn 𝕜 n f s :=
  forall_congr' <| by simp [contMDiffWithinAt_iff_contDiffWithinAt]
#align cont_mdiff_on_iff_cont_diff_on contMDiffOn_iff_contDiffOn
-/

alias contMDiffOn_iff_contDiffOn ↔ ContMDiffOn.contDiffOn ContDiffOn.contMDiffOn
#align cont_mdiff_on.cont_diff_on ContMDiffOn.contDiffOn
#align cont_diff_on.cont_mdiff_on ContDiffOn.contMDiffOn

#print contMDiff_iff_contDiff /-
theorem contMDiff_iff_contDiff {f : E → E'} : ContMDiff 𝓘(𝕜, E) 𝓘(𝕜, E') n f ↔ ContDiff 𝕜 n f := by
  rw [← contDiffOn_univ, ← contMDiffOn_univ, contMDiffOn_iff_contDiffOn]
#align cont_mdiff_iff_cont_diff contMDiff_iff_contDiff
-/

alias contMDiff_iff_contDiff ↔ ContMDiff.contDiff ContDiff.contMDiff
#align cont_mdiff.cont_diff ContMDiff.contDiff
#align cont_diff.cont_mdiff ContDiff.contMDiff

#print ContDiffWithinAt.comp_contMDiffWithinAt /-
theorem ContDiffWithinAt.comp_contMDiffWithinAt {g : F → F'} {f : M → F} {s : Set M} {t : Set F}
    {x : M} (hg : ContDiffWithinAt 𝕜 n g t (f x)) (hf : ContMDiffWithinAt I 𝓘(𝕜, F) n f s x)
    (h : s ⊆ f ⁻¹' t) : ContMDiffWithinAt I 𝓘(𝕜, F') n (g ∘ f) s x :=
  by
  rw [contMDiffWithinAt_iff] at *
  refine' ⟨hg.continuous_within_at.comp hf.1 h, _⟩
  rw [← (extChartAt I x).left_inv (mem_extChartAt_source I x)] at hg 
  apply ContDiffWithinAt.comp _ hg hf.2 _
  exact (inter_subset_left _ _).trans (preimage_mono h)
#align cont_diff_within_at.comp_cont_mdiff_within_at ContDiffWithinAt.comp_contMDiffWithinAt
-/

#print ContDiffAt.comp_contMDiffAt /-
theorem ContDiffAt.comp_contMDiffAt {g : F → F'} {f : M → F} {x : M} (hg : ContDiffAt 𝕜 n g (f x))
    (hf : ContMDiffAt I 𝓘(𝕜, F) n f x) : ContMDiffAt I 𝓘(𝕜, F') n (g ∘ f) x :=
  hg.comp_contMDiffWithinAt hf Subset.rfl
#align cont_diff_at.comp_cont_mdiff_at ContDiffAt.comp_contMDiffAt
-/

#print ContDiff.comp_contMDiff /-
theorem ContDiff.comp_contMDiff {g : F → F'} {f : M → F} (hg : ContDiff 𝕜 n g)
    (hf : ContMDiff I 𝓘(𝕜, F) n f) : ContMDiff I 𝓘(𝕜, F') n (g ∘ f) := fun x =>
  hg.ContDiffAt.comp_contMDiffAt (hf x)
#align cont_diff.comp_cont_mdiff ContDiff.comp_contMDiff
-/

end Module

/-! ### Smoothness of standard maps associated to the product of manifolds -/


section ProdMk

#print ContMDiffWithinAt.prod_mk /-
theorem ContMDiffWithinAt.prod_mk {f : M → M'} {g : M → N'} (hf : ContMDiffWithinAt I I' n f s x)
    (hg : ContMDiffWithinAt I J' n g s x) :
    ContMDiffWithinAt I (I'.Prod J') n (fun x => (f x, g x)) s x :=
  by
  rw [contMDiffWithinAt_iff] at *
  exact ⟨hf.1.Prod hg.1, hf.2.Prod hg.2⟩
#align cont_mdiff_within_at.prod_mk ContMDiffWithinAt.prod_mk
-/

#print ContMDiffWithinAt.prod_mk_space /-
theorem ContMDiffWithinAt.prod_mk_space {f : M → E'} {g : M → F'}
    (hf : ContMDiffWithinAt I 𝓘(𝕜, E') n f s x) (hg : ContMDiffWithinAt I 𝓘(𝕜, F') n g s x) :
    ContMDiffWithinAt I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) s x :=
  by
  rw [contMDiffWithinAt_iff] at *
  exact ⟨hf.1.Prod hg.1, hf.2.Prod hg.2⟩
#align cont_mdiff_within_at.prod_mk_space ContMDiffWithinAt.prod_mk_space
-/

#print ContMDiffAt.prod_mk /-
theorem ContMDiffAt.prod_mk {f : M → M'} {g : M → N'} (hf : ContMDiffAt I I' n f x)
    (hg : ContMDiffAt I J' n g x) : ContMDiffAt I (I'.Prod J') n (fun x => (f x, g x)) x :=
  hf.prod_mk hg
#align cont_mdiff_at.prod_mk ContMDiffAt.prod_mk
-/

#print ContMDiffAt.prod_mk_space /-
theorem ContMDiffAt.prod_mk_space {f : M → E'} {g : M → F'} (hf : ContMDiffAt I 𝓘(𝕜, E') n f x)
    (hg : ContMDiffAt I 𝓘(𝕜, F') n g x) : ContMDiffAt I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) x :=
  hf.prod_mk_space hg
#align cont_mdiff_at.prod_mk_space ContMDiffAt.prod_mk_space
-/

#print ContMDiffOn.prod_mk /-
theorem ContMDiffOn.prod_mk {f : M → M'} {g : M → N'} (hf : ContMDiffOn I I' n f s)
    (hg : ContMDiffOn I J' n g s) : ContMDiffOn I (I'.Prod J') n (fun x => (f x, g x)) s :=
  fun x hx => (hf x hx).prod_mk (hg x hx)
#align cont_mdiff_on.prod_mk ContMDiffOn.prod_mk
-/

#print ContMDiffOn.prod_mk_space /-
theorem ContMDiffOn.prod_mk_space {f : M → E'} {g : M → F'} (hf : ContMDiffOn I 𝓘(𝕜, E') n f s)
    (hg : ContMDiffOn I 𝓘(𝕜, F') n g s) : ContMDiffOn I 𝓘(𝕜, E' × F') n (fun x => (f x, g x)) s :=
  fun x hx => (hf x hx).prod_mk_space (hg x hx)
#align cont_mdiff_on.prod_mk_space ContMDiffOn.prod_mk_space
-/

#print ContMDiff.prod_mk /-
theorem ContMDiff.prod_mk {f : M → M'} {g : M → N'} (hf : ContMDiff I I' n f)
    (hg : ContMDiff I J' n g) : ContMDiff I (I'.Prod J') n fun x => (f x, g x) := fun x =>
  (hf x).prod_mk (hg x)
#align cont_mdiff.prod_mk ContMDiff.prod_mk
-/

#print ContMDiff.prod_mk_space /-
theorem ContMDiff.prod_mk_space {f : M → E'} {g : M → F'} (hf : ContMDiff I 𝓘(𝕜, E') n f)
    (hg : ContMDiff I 𝓘(𝕜, F') n g) : ContMDiff I 𝓘(𝕜, E' × F') n fun x => (f x, g x) := fun x =>
  (hf x).prod_mk_space (hg x)
#align cont_mdiff.prod_mk_space ContMDiff.prod_mk_space
-/

#print SmoothWithinAt.prod_mk /-
theorem SmoothWithinAt.prod_mk {f : M → M'} {g : M → N'} (hf : SmoothWithinAt I I' f s x)
    (hg : SmoothWithinAt I J' g s x) : SmoothWithinAt I (I'.Prod J') (fun x => (f x, g x)) s x :=
  hf.prod_mk hg
#align smooth_within_at.prod_mk SmoothWithinAt.prod_mk
-/

#print SmoothWithinAt.prod_mk_space /-
theorem SmoothWithinAt.prod_mk_space {f : M → E'} {g : M → F'}
    (hf : SmoothWithinAt I 𝓘(𝕜, E') f s x) (hg : SmoothWithinAt I 𝓘(𝕜, F') g s x) :
    SmoothWithinAt I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) s x :=
  hf.prod_mk_space hg
#align smooth_within_at.prod_mk_space SmoothWithinAt.prod_mk_space
-/

#print SmoothAt.prod_mk /-
theorem SmoothAt.prod_mk {f : M → M'} {g : M → N'} (hf : SmoothAt I I' f x)
    (hg : SmoothAt I J' g x) : SmoothAt I (I'.Prod J') (fun x => (f x, g x)) x :=
  hf.prod_mk hg
#align smooth_at.prod_mk SmoothAt.prod_mk
-/

#print SmoothAt.prod_mk_space /-
theorem SmoothAt.prod_mk_space {f : M → E'} {g : M → F'} (hf : SmoothAt I 𝓘(𝕜, E') f x)
    (hg : SmoothAt I 𝓘(𝕜, F') g x) : SmoothAt I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) x :=
  hf.prod_mk_space hg
#align smooth_at.prod_mk_space SmoothAt.prod_mk_space
-/

#print SmoothOn.prod_mk /-
theorem SmoothOn.prod_mk {f : M → M'} {g : M → N'} (hf : SmoothOn I I' f s)
    (hg : SmoothOn I J' g s) : SmoothOn I (I'.Prod J') (fun x => (f x, g x)) s :=
  hf.prod_mk hg
#align smooth_on.prod_mk SmoothOn.prod_mk
-/

#print SmoothOn.prod_mk_space /-
theorem SmoothOn.prod_mk_space {f : M → E'} {g : M → F'} (hf : SmoothOn I 𝓘(𝕜, E') f s)
    (hg : SmoothOn I 𝓘(𝕜, F') g s) : SmoothOn I 𝓘(𝕜, E' × F') (fun x => (f x, g x)) s :=
  hf.prod_mk_space hg
#align smooth_on.prod_mk_space SmoothOn.prod_mk_space
-/

#print Smooth.prod_mk /-
theorem Smooth.prod_mk {f : M → M'} {g : M → N'} (hf : Smooth I I' f) (hg : Smooth I J' g) :
    Smooth I (I'.Prod J') fun x => (f x, g x) :=
  hf.prod_mk hg
#align smooth.prod_mk Smooth.prod_mk
-/

#print Smooth.prod_mk_space /-
theorem Smooth.prod_mk_space {f : M → E'} {g : M → F'} (hf : Smooth I 𝓘(𝕜, E') f)
    (hg : Smooth I 𝓘(𝕜, F') g) : Smooth I 𝓘(𝕜, E' × F') fun x => (f x, g x) :=
  hf.prod_mk_space hg
#align smooth.prod_mk_space Smooth.prod_mk_space
-/

end ProdMk

section Projections

#print contMDiffWithinAt_fst /-
theorem contMDiffWithinAt_fst {s : Set (M × N)} {p : M × N} :
    ContMDiffWithinAt (I.Prod J) I n Prod.fst s p :=
  by
  rw [contMDiffWithinAt_iff']
  refine' ⟨continuousWithinAt_fst, _⟩
  refine' cont_diff_within_at_fst.congr (fun y hy => _) _
  · simp only [mfld_simps] at hy 
    simp only [hy, mfld_simps]
  · simp only [mfld_simps]
#align cont_mdiff_within_at_fst contMDiffWithinAt_fst
-/

#print ContMDiffWithinAt.fst /-
theorem ContMDiffWithinAt.fst {f : N → M × M'} {s : Set N} {x : N}
    (hf : ContMDiffWithinAt J (I.Prod I') n f s x) :
    ContMDiffWithinAt J I n (fun x => (f x).1) s x :=
  contMDiffWithinAt_fst.comp x hf (mapsTo_image f s)
#align cont_mdiff_within_at.fst ContMDiffWithinAt.fst
-/

#print contMDiffAt_fst /-
theorem contMDiffAt_fst {p : M × N} : ContMDiffAt (I.Prod J) I n Prod.fst p :=
  contMDiffWithinAt_fst
#align cont_mdiff_at_fst contMDiffAt_fst
-/

#print contMDiffOn_fst /-
theorem contMDiffOn_fst {s : Set (M × N)} : ContMDiffOn (I.Prod J) I n Prod.fst s := fun x hx =>
  contMDiffWithinAt_fst
#align cont_mdiff_on_fst contMDiffOn_fst
-/

#print contMDiff_fst /-
theorem contMDiff_fst : ContMDiff (I.Prod J) I n (@Prod.fst M N) := fun x => contMDiffAt_fst
#align cont_mdiff_fst contMDiff_fst
-/

#print smoothWithinAt_fst /-
theorem smoothWithinAt_fst {s : Set (M × N)} {p : M × N} :
    SmoothWithinAt (I.Prod J) I Prod.fst s p :=
  contMDiffWithinAt_fst
#align smooth_within_at_fst smoothWithinAt_fst
-/

#print smoothAt_fst /-
theorem smoothAt_fst {p : M × N} : SmoothAt (I.Prod J) I Prod.fst p :=
  contMDiffAt_fst
#align smooth_at_fst smoothAt_fst
-/

#print smoothOn_fst /-
theorem smoothOn_fst {s : Set (M × N)} : SmoothOn (I.Prod J) I Prod.fst s :=
  contMDiffOn_fst
#align smooth_on_fst smoothOn_fst
-/

#print smooth_fst /-
theorem smooth_fst : Smooth (I.Prod J) I (@Prod.fst M N) :=
  contMDiff_fst
#align smooth_fst smooth_fst
-/

#print ContMDiffAt.fst /-
theorem ContMDiffAt.fst {f : N → M × M'} {x : N} (hf : ContMDiffAt J (I.Prod I') n f x) :
    ContMDiffAt J I n (fun x => (f x).1) x :=
  contMDiffAt_fst.comp x hf
#align cont_mdiff_at.fst ContMDiffAt.fst
-/

#print ContMDiff.fst /-
theorem ContMDiff.fst {f : N → M × M'} (hf : ContMDiff J (I.Prod I') n f) :
    ContMDiff J I n fun x => (f x).1 :=
  contMDiff_fst.comp hf
#align cont_mdiff.fst ContMDiff.fst
-/

#print SmoothAt.fst /-
theorem SmoothAt.fst {f : N → M × M'} {x : N} (hf : SmoothAt J (I.Prod I') f x) :
    SmoothAt J I (fun x => (f x).1) x :=
  smoothAt_fst.comp x hf
#align smooth_at.fst SmoothAt.fst
-/

#print Smooth.fst /-
theorem Smooth.fst {f : N → M × M'} (hf : Smooth J (I.Prod I') f) : Smooth J I fun x => (f x).1 :=
  smooth_fst.comp hf
#align smooth.fst Smooth.fst
-/

#print contMDiffWithinAt_snd /-
theorem contMDiffWithinAt_snd {s : Set (M × N)} {p : M × N} :
    ContMDiffWithinAt (I.Prod J) J n Prod.snd s p :=
  by
  rw [contMDiffWithinAt_iff']
  refine' ⟨continuousWithinAt_snd, _⟩
  refine' cont_diff_within_at_snd.congr (fun y hy => _) _
  · simp only [mfld_simps] at hy 
    simp only [hy, mfld_simps]
  · simp only [mfld_simps]
#align cont_mdiff_within_at_snd contMDiffWithinAt_snd
-/

#print ContMDiffWithinAt.snd /-
theorem ContMDiffWithinAt.snd {f : N → M × M'} {s : Set N} {x : N}
    (hf : ContMDiffWithinAt J (I.Prod I') n f s x) :
    ContMDiffWithinAt J I' n (fun x => (f x).2) s x :=
  contMDiffWithinAt_snd.comp x hf (mapsTo_image f s)
#align cont_mdiff_within_at.snd ContMDiffWithinAt.snd
-/

#print contMDiffAt_snd /-
theorem contMDiffAt_snd {p : M × N} : ContMDiffAt (I.Prod J) J n Prod.snd p :=
  contMDiffWithinAt_snd
#align cont_mdiff_at_snd contMDiffAt_snd
-/

#print contMDiffOn_snd /-
theorem contMDiffOn_snd {s : Set (M × N)} : ContMDiffOn (I.Prod J) J n Prod.snd s := fun x hx =>
  contMDiffWithinAt_snd
#align cont_mdiff_on_snd contMDiffOn_snd
-/

#print contMDiff_snd /-
theorem contMDiff_snd : ContMDiff (I.Prod J) J n (@Prod.snd M N) := fun x => contMDiffAt_snd
#align cont_mdiff_snd contMDiff_snd
-/

#print smoothWithinAt_snd /-
theorem smoothWithinAt_snd {s : Set (M × N)} {p : M × N} :
    SmoothWithinAt (I.Prod J) J Prod.snd s p :=
  contMDiffWithinAt_snd
#align smooth_within_at_snd smoothWithinAt_snd
-/

#print smoothAt_snd /-
theorem smoothAt_snd {p : M × N} : SmoothAt (I.Prod J) J Prod.snd p :=
  contMDiffAt_snd
#align smooth_at_snd smoothAt_snd
-/

#print smoothOn_snd /-
theorem smoothOn_snd {s : Set (M × N)} : SmoothOn (I.Prod J) J Prod.snd s :=
  contMDiffOn_snd
#align smooth_on_snd smoothOn_snd
-/

#print smooth_snd /-
theorem smooth_snd : Smooth (I.Prod J) J (@Prod.snd M N) :=
  contMDiff_snd
#align smooth_snd smooth_snd
-/

#print ContMDiffAt.snd /-
theorem ContMDiffAt.snd {f : N → M × M'} {x : N} (hf : ContMDiffAt J (I.Prod I') n f x) :
    ContMDiffAt J I' n (fun x => (f x).2) x :=
  contMDiffAt_snd.comp x hf
#align cont_mdiff_at.snd ContMDiffAt.snd
-/

#print ContMDiff.snd /-
theorem ContMDiff.snd {f : N → M × M'} (hf : ContMDiff J (I.Prod I') n f) :
    ContMDiff J I' n fun x => (f x).2 :=
  contMDiff_snd.comp hf
#align cont_mdiff.snd ContMDiff.snd
-/

#print SmoothAt.snd /-
theorem SmoothAt.snd {f : N → M × M'} {x : N} (hf : SmoothAt J (I.Prod I') f x) :
    SmoothAt J I' (fun x => (f x).2) x :=
  smoothAt_snd.comp x hf
#align smooth_at.snd SmoothAt.snd
-/

#print Smooth.snd /-
theorem Smooth.snd {f : N → M × M'} (hf : Smooth J (I.Prod I') f) : Smooth J I' fun x => (f x).2 :=
  smooth_snd.comp hf
#align smooth.snd Smooth.snd
-/

end Projections

#print contMDiffWithinAt_prod_iff /-
theorem contMDiffWithinAt_prod_iff (f : M → M' × N') {s : Set M} {x : M} :
    ContMDiffWithinAt I (I'.Prod J') n f s x ↔
      ContMDiffWithinAt I I' n (Prod.fst ∘ f) s x ∧ ContMDiffWithinAt I J' n (Prod.snd ∘ f) s x :=
  by refine' ⟨fun h => ⟨h.fst, h.snd⟩, fun h => _⟩; simpa only [Prod.mk.eta] using h.1.prod_mk h.2
#align cont_mdiff_within_at_prod_iff contMDiffWithinAt_prod_iff
-/

#print contMDiffAt_prod_iff /-
theorem contMDiffAt_prod_iff (f : M → M' × N') {x : M} :
    ContMDiffAt I (I'.Prod J') n f x ↔
      ContMDiffAt I I' n (Prod.fst ∘ f) x ∧ ContMDiffAt I J' n (Prod.snd ∘ f) x :=
  by simp_rw [← contMDiffWithinAt_univ, contMDiffWithinAt_prod_iff]
#align cont_mdiff_at_prod_iff contMDiffAt_prod_iff
-/

#print contMDiff_prod_iff /-
theorem contMDiff_prod_iff (f : M → M' × N') :
    ContMDiff I (I'.Prod J') n f ↔
      ContMDiff I I' n (Prod.fst ∘ f) ∧ ContMDiff I J' n (Prod.snd ∘ f) :=
  ⟨fun h => ⟨h.fst, h.snd⟩, fun h => by convert h.1.prod_mk h.2; ext <;> rfl⟩
#align cont_mdiff_prod_iff contMDiff_prod_iff
-/

#print smoothAt_prod_iff /-
theorem smoothAt_prod_iff (f : M → M' × N') {x : M} :
    SmoothAt I (I'.Prod J') f x ↔ SmoothAt I I' (Prod.fst ∘ f) x ∧ SmoothAt I J' (Prod.snd ∘ f) x :=
  contMDiffAt_prod_iff f
#align smooth_at_prod_iff smoothAt_prod_iff
-/

#print smooth_prod_iff /-
theorem smooth_prod_iff (f : M → M' × N') :
    Smooth I (I'.Prod J') f ↔ Smooth I I' (Prod.fst ∘ f) ∧ Smooth I J' (Prod.snd ∘ f) :=
  contMDiff_prod_iff f
#align smooth_prod_iff smooth_prod_iff
-/

#print smooth_prod_assoc /-
theorem smooth_prod_assoc :
    Smooth ((I.Prod I').Prod J) (I.Prod (I'.Prod J)) fun x : (M × M') × N => (x.1.1, x.1.2, x.2) :=
  smooth_fst.fst.prod_mk <| smooth_fst.snd.prod_mk smooth_snd
#align smooth_prod_assoc smooth_prod_assoc
-/

section Prod_map

variable {g : N → N'} {r : Set N} {y : N}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContMDiffWithinAt.prod_map' /-
/-- The product map of two `C^n` functions within a set at a point is `C^n`
within the product set at the product point. -/
theorem ContMDiffWithinAt.prod_map' {p : M × N} (hf : ContMDiffWithinAt I I' n f s p.1)
    (hg : ContMDiffWithinAt J J' n g r p.2) :
    ContMDiffWithinAt (I.Prod J) (I'.Prod J') n (Prod.map f g) (s ×ˢ r) p :=
  (hf.comp p contMDiffWithinAt_fst (prod_subset_preimage_fst _ _)).prod_mk <|
    hg.comp p contMDiffWithinAt_snd (prod_subset_preimage_snd _ _)
#align cont_mdiff_within_at.prod_map' ContMDiffWithinAt.prod_map'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContMDiffWithinAt.prod_map /-
theorem ContMDiffWithinAt.prod_map (hf : ContMDiffWithinAt I I' n f s x)
    (hg : ContMDiffWithinAt J J' n g r y) :
    ContMDiffWithinAt (I.Prod J) (I'.Prod J') n (Prod.map f g) (s ×ˢ r) (x, y) :=
  ContMDiffWithinAt.prod_map' hf hg
#align cont_mdiff_within_at.prod_map ContMDiffWithinAt.prod_map
-/

#print ContMDiffAt.prod_map /-
theorem ContMDiffAt.prod_map (hf : ContMDiffAt I I' n f x) (hg : ContMDiffAt J J' n g y) :
    ContMDiffAt (I.Prod J) (I'.Prod J') n (Prod.map f g) (x, y) :=
  by
  rw [← contMDiffWithinAt_univ] at *
  convert hf.prod_map hg
  exact univ_prod_univ.symm
#align cont_mdiff_at.prod_map ContMDiffAt.prod_map
-/

#print ContMDiffAt.prod_map' /-
theorem ContMDiffAt.prod_map' {p : M × N} (hf : ContMDiffAt I I' n f p.1)
    (hg : ContMDiffAt J J' n g p.2) : ContMDiffAt (I.Prod J) (I'.Prod J') n (Prod.map f g) p :=
  by
  rcases p with ⟨⟩
  exact hf.prod_map hg
#align cont_mdiff_at.prod_map' ContMDiffAt.prod_map'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ContMDiffOn.prod_map /-
theorem ContMDiffOn.prod_map (hf : ContMDiffOn I I' n f s) (hg : ContMDiffOn J J' n g r) :
    ContMDiffOn (I.Prod J) (I'.Prod J') n (Prod.map f g) (s ×ˢ r) :=
  (hf.comp contMDiffOn_fst (prod_subset_preimage_fst _ _)).prod_mk <|
    hg.comp contMDiffOn_snd (prod_subset_preimage_snd _ _)
#align cont_mdiff_on.prod_map ContMDiffOn.prod_map
-/

#print ContMDiff.prod_map /-
theorem ContMDiff.prod_map (hf : ContMDiff I I' n f) (hg : ContMDiff J J' n g) :
    ContMDiff (I.Prod J) (I'.Prod J') n (Prod.map f g) :=
  by
  intro p
  exact (hf p.1).prod_map' (hg p.2)
#align cont_mdiff.prod_map ContMDiff.prod_map
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SmoothWithinAt.prod_map /-
theorem SmoothWithinAt.prod_map (hf : SmoothWithinAt I I' f s x) (hg : SmoothWithinAt J J' g r y) :
    SmoothWithinAt (I.Prod J) (I'.Prod J') (Prod.map f g) (s ×ˢ r) (x, y) :=
  hf.Prod_map hg
#align smooth_within_at.prod_map SmoothWithinAt.prod_map
-/

#print SmoothAt.prod_map /-
theorem SmoothAt.prod_map (hf : SmoothAt I I' f x) (hg : SmoothAt J J' g y) :
    SmoothAt (I.Prod J) (I'.Prod J') (Prod.map f g) (x, y) :=
  hf.Prod_map hg
#align smooth_at.prod_map SmoothAt.prod_map
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print SmoothOn.prod_map /-
theorem SmoothOn.prod_map (hf : SmoothOn I I' f s) (hg : SmoothOn J J' g r) :
    SmoothOn (I.Prod J) (I'.Prod J') (Prod.map f g) (s ×ˢ r) :=
  hf.Prod_map hg
#align smooth_on.prod_map SmoothOn.prod_map
-/

#print Smooth.prod_map /-
theorem Smooth.prod_map (hf : Smooth I I' f) (hg : Smooth J J' g) :
    Smooth (I.Prod J) (I'.Prod J') (Prod.map f g) :=
  hf.Prod_map hg
#align smooth.prod_map Smooth.prod_map
-/

end Prod_map

section PiSpace

/-!
### Smoothness of functions with codomain `Π i, F i`

We have no `model_with_corners.pi` yet, so we prove lemmas about functions `f : M → Π i, F i` and
use `𝓘(𝕜, Π i, F i)` as the model space.
-/


variable {ι : Type _} [Fintype ι] {Fi : ι → Type _} [∀ i, NormedAddCommGroup (Fi i)]
  [∀ i, NormedSpace 𝕜 (Fi i)] {φ : M → ∀ i, Fi i}

#print contMDiffWithinAt_pi_space /-
theorem contMDiffWithinAt_pi_space :
    ContMDiffWithinAt I 𝓘(𝕜, ∀ i, Fi i) n φ s x ↔
      ∀ i, ContMDiffWithinAt I 𝓘(𝕜, Fi i) n (fun x => φ x i) s x :=
  by
  simp only [contMDiffWithinAt_iff, continuousWithinAt_pi, contDiffWithinAt_pi, forall_and,
    writtenInExtChartAt, extChartAt_model_space_eq_id, (· ∘ ·), LocalEquiv.refl_coe, id]
#align cont_mdiff_within_at_pi_space contMDiffWithinAt_pi_space
-/

#print contMDiffOn_pi_space /-
theorem contMDiffOn_pi_space :
    ContMDiffOn I 𝓘(𝕜, ∀ i, Fi i) n φ s ↔ ∀ i, ContMDiffOn I 𝓘(𝕜, Fi i) n (fun x => φ x i) s :=
  ⟨fun h i x hx => contMDiffWithinAt_pi_space.1 (h x hx) i, fun h x hx =>
    contMDiffWithinAt_pi_space.2 fun i => h i x hx⟩
#align cont_mdiff_on_pi_space contMDiffOn_pi_space
-/

#print contMDiffAt_pi_space /-
theorem contMDiffAt_pi_space :
    ContMDiffAt I 𝓘(𝕜, ∀ i, Fi i) n φ x ↔ ∀ i, ContMDiffAt I 𝓘(𝕜, Fi i) n (fun x => φ x i) x :=
  contMDiffWithinAt_pi_space
#align cont_mdiff_at_pi_space contMDiffAt_pi_space
-/

#print contMDiff_pi_space /-
theorem contMDiff_pi_space :
    ContMDiff I 𝓘(𝕜, ∀ i, Fi i) n φ ↔ ∀ i, ContMDiff I 𝓘(𝕜, Fi i) n fun x => φ x i :=
  ⟨fun h i x => contMDiffAt_pi_space.1 (h x) i, fun h x => contMDiffAt_pi_space.2 fun i => h i x⟩
#align cont_mdiff_pi_space contMDiff_pi_space
-/

#print smoothWithinAt_pi_space /-
theorem smoothWithinAt_pi_space :
    SmoothWithinAt I 𝓘(𝕜, ∀ i, Fi i) φ s x ↔
      ∀ i, SmoothWithinAt I 𝓘(𝕜, Fi i) (fun x => φ x i) s x :=
  contMDiffWithinAt_pi_space
#align smooth_within_at_pi_space smoothWithinAt_pi_space
-/

#print smoothOn_pi_space /-
theorem smoothOn_pi_space :
    SmoothOn I 𝓘(𝕜, ∀ i, Fi i) φ s ↔ ∀ i, SmoothOn I 𝓘(𝕜, Fi i) (fun x => φ x i) s :=
  contMDiffOn_pi_space
#align smooth_on_pi_space smoothOn_pi_space
-/

#print smoothAt_pi_space /-
theorem smoothAt_pi_space :
    SmoothAt I 𝓘(𝕜, ∀ i, Fi i) φ x ↔ ∀ i, SmoothAt I 𝓘(𝕜, Fi i) (fun x => φ x i) x :=
  contMDiffAt_pi_space
#align smooth_at_pi_space smoothAt_pi_space
-/

#print smooth_pi_space /-
theorem smooth_pi_space : Smooth I 𝓘(𝕜, ∀ i, Fi i) φ ↔ ∀ i, Smooth I 𝓘(𝕜, Fi i) fun x => φ x i :=
  contMDiff_pi_space
#align smooth_pi_space smooth_pi_space
-/

end PiSpace

/-! ### Linear maps between normed spaces are smooth -/


#print ContinuousLinearMap.contMDiff /-
theorem ContinuousLinearMap.contMDiff (L : E →L[𝕜] F) : ContMDiff 𝓘(𝕜, E) 𝓘(𝕜, F) n L :=
  L.ContDiff.ContMDiff
#align continuous_linear_map.cont_mdiff ContinuousLinearMap.contMDiff
-/

#print ContMDiffWithinAt.clm_comp /-
theorem ContMDiffWithinAt.clm_comp {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₁} {s : Set M} {x : M}
    (hg : ContMDiffWithinAt I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g s x)
    (hf : ContMDiffWithinAt I 𝓘(𝕜, F₂ →L[𝕜] F₁) n f s x) :
    ContMDiffWithinAt I 𝓘(𝕜, F₂ →L[𝕜] F₃) n (fun x => (g x).comp (f x)) s x :=
  @ContDiffWithinAt.comp_contMDiffWithinAt _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    (fun x : (F₁ →L[𝕜] F₃) × (F₂ →L[𝕜] F₁) => x.1.comp x.2) (fun x => (g x, f x)) s _ x
    (by apply ContDiff.contDiffAt; exact cont_diff_fst.clm_comp contDiff_snd) (hg.prod_mk_space hf)
    (by simp_rw [preimage_univ, subset_univ])
#align cont_mdiff_within_at.clm_comp ContMDiffWithinAt.clm_comp
-/

#print ContMDiffAt.clm_comp /-
theorem ContMDiffAt.clm_comp {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₁} {x : M}
    (hg : ContMDiffAt I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g x) (hf : ContMDiffAt I 𝓘(𝕜, F₂ →L[𝕜] F₁) n f x) :
    ContMDiffAt I 𝓘(𝕜, F₂ →L[𝕜] F₃) n (fun x => (g x).comp (f x)) x :=
  (hg.ContMDiffWithinAt.clm_comp hf.ContMDiffWithinAt).ContMDiffAt univ_mem
#align cont_mdiff_at.clm_comp ContMDiffAt.clm_comp
-/

#print ContMDiffOn.clm_comp /-
theorem ContMDiffOn.clm_comp {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₁} {s : Set M}
    (hg : ContMDiffOn I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g s) (hf : ContMDiffOn I 𝓘(𝕜, F₂ →L[𝕜] F₁) n f s) :
    ContMDiffOn I 𝓘(𝕜, F₂ →L[𝕜] F₃) n (fun x => (g x).comp (f x)) s := fun x hx =>
  (hg x hx).clm_comp (hf x hx)
#align cont_mdiff_on.clm_comp ContMDiffOn.clm_comp
-/

#print ContMDiff.clm_comp /-
theorem ContMDiff.clm_comp {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₁}
    (hg : ContMDiff I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g) (hf : ContMDiff I 𝓘(𝕜, F₂ →L[𝕜] F₁) n f) :
    ContMDiff I 𝓘(𝕜, F₂ →L[𝕜] F₃) n fun x => (g x).comp (f x) := fun x => (hg x).clm_comp (hf x)
#align cont_mdiff.clm_comp ContMDiff.clm_comp
-/

#print ContMDiffWithinAt.clm_apply /-
theorem ContMDiffWithinAt.clm_apply {g : M → F₁ →L[𝕜] F₂} {f : M → F₁} {s : Set M} {x : M}
    (hg : ContMDiffWithinAt I 𝓘(𝕜, F₁ →L[𝕜] F₂) n g s x)
    (hf : ContMDiffWithinAt I 𝓘(𝕜, F₁) n f s x) :
    ContMDiffWithinAt I 𝓘(𝕜, F₂) n (fun x => g x (f x)) s x :=
  @ContDiffWithinAt.comp_contMDiffWithinAt _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    (fun x : (F₁ →L[𝕜] F₂) × F₁ => x.1 x.2) (fun x => (g x, f x)) s _ x
    (by apply ContDiff.contDiffAt; exact cont_diff_fst.clm_apply contDiff_snd) (hg.prod_mk_space hf)
    (by simp_rw [preimage_univ, subset_univ])
#align cont_mdiff_within_at.clm_apply ContMDiffWithinAt.clm_apply
-/

#print ContMDiffAt.clm_apply /-
theorem ContMDiffAt.clm_apply {g : M → F₁ →L[𝕜] F₂} {f : M → F₁} {x : M}
    (hg : ContMDiffAt I 𝓘(𝕜, F₁ →L[𝕜] F₂) n g x) (hf : ContMDiffAt I 𝓘(𝕜, F₁) n f x) :
    ContMDiffAt I 𝓘(𝕜, F₂) n (fun x => g x (f x)) x :=
  (hg.ContMDiffWithinAt.clm_apply hf.ContMDiffWithinAt).ContMDiffAt univ_mem
#align cont_mdiff_at.clm_apply ContMDiffAt.clm_apply
-/

#print ContMDiffOn.clm_apply /-
theorem ContMDiffOn.clm_apply {g : M → F₁ →L[𝕜] F₂} {f : M → F₁} {s : Set M}
    (hg : ContMDiffOn I 𝓘(𝕜, F₁ →L[𝕜] F₂) n g s) (hf : ContMDiffOn I 𝓘(𝕜, F₁) n f s) :
    ContMDiffOn I 𝓘(𝕜, F₂) n (fun x => g x (f x)) s := fun x hx => (hg x hx).clm_apply (hf x hx)
#align cont_mdiff_on.clm_apply ContMDiffOn.clm_apply
-/

#print ContMDiff.clm_apply /-
theorem ContMDiff.clm_apply {g : M → F₁ →L[𝕜] F₂} {f : M → F₁}
    (hg : ContMDiff I 𝓘(𝕜, F₁ →L[𝕜] F₂) n g) (hf : ContMDiff I 𝓘(𝕜, F₁) n f) :
    ContMDiff I 𝓘(𝕜, F₂) n fun x => g x (f x) := fun x => (hg x).clm_apply (hf x)
#align cont_mdiff.clm_apply ContMDiff.clm_apply
-/

#print ContMDiffWithinAt.clm_prodMap /-
theorem ContMDiffWithinAt.clm_prodMap {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₄} {s : Set M}
    {x : M} (hg : ContMDiffWithinAt I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g s x)
    (hf : ContMDiffWithinAt I 𝓘(𝕜, F₂ →L[𝕜] F₄) n f s x) :
    ContMDiffWithinAt I 𝓘(𝕜, F₁ × F₂ →L[𝕜] F₃ × F₄) n (fun x => (g x).Prod_map (f x)) s x :=
  @ContDiffWithinAt.comp_contMDiffWithinAt _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    (fun x : (F₁ →L[𝕜] F₃) × (F₂ →L[𝕜] F₄) => x.1.Prod_map x.2) (fun x => (g x, f x)) s _ x
    (by
      apply ContDiff.contDiffAt
      exact (ContinuousLinearMap.prodMapL 𝕜 F₁ F₃ F₂ F₄).ContDiff)
    (hg.prod_mk_space hf) (by simp_rw [preimage_univ, subset_univ])
#align cont_mdiff_within_at.clm_prod_map ContMDiffWithinAt.clm_prodMap
-/

#print ContMDiffAt.clm_prodMap /-
theorem ContMDiffAt.clm_prodMap {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₄} {x : M}
    (hg : ContMDiffAt I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g x) (hf : ContMDiffAt I 𝓘(𝕜, F₂ →L[𝕜] F₄) n f x) :
    ContMDiffAt I 𝓘(𝕜, F₁ × F₂ →L[𝕜] F₃ × F₄) n (fun x => (g x).Prod_map (f x)) x :=
  (hg.ContMDiffWithinAt.clm_prodMap hf.ContMDiffWithinAt).ContMDiffAt univ_mem
#align cont_mdiff_at.clm_prod_map ContMDiffAt.clm_prodMap
-/

#print ContMDiffOn.clm_prodMap /-
theorem ContMDiffOn.clm_prodMap {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₄} {s : Set M}
    (hg : ContMDiffOn I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g s) (hf : ContMDiffOn I 𝓘(𝕜, F₂ →L[𝕜] F₄) n f s) :
    ContMDiffOn I 𝓘(𝕜, F₁ × F₂ →L[𝕜] F₃ × F₄) n (fun x => (g x).Prod_map (f x)) s := fun x hx =>
  (hg x hx).clm_prodMap (hf x hx)
#align cont_mdiff_on.clm_prod_map ContMDiffOn.clm_prodMap
-/

#print ContMDiff.clm_prodMap /-
theorem ContMDiff.clm_prodMap {g : M → F₁ →L[𝕜] F₃} {f : M → F₂ →L[𝕜] F₄}
    (hg : ContMDiff I 𝓘(𝕜, F₁ →L[𝕜] F₃) n g) (hf : ContMDiff I 𝓘(𝕜, F₂ →L[𝕜] F₄) n f) :
    ContMDiff I 𝓘(𝕜, F₁ × F₂ →L[𝕜] F₃ × F₄) n fun x => (g x).Prod_map (f x) := fun x =>
  (hg x).clm_prodMap (hf x)
#align cont_mdiff.clm_prod_map ContMDiff.clm_prodMap
-/

/-! ### Smoothness of standard operations -/


variable {V : Type _} [NormedAddCommGroup V] [NormedSpace 𝕜 V]

#print smooth_smul /-
/-- On any vector space, multiplication by a scalar is a smooth operation. -/
theorem smooth_smul : Smooth (𝓘(𝕜).Prod 𝓘(𝕜, V)) 𝓘(𝕜, V) fun p : 𝕜 × V => p.1 • p.2 :=
  smooth_iff.2 ⟨continuous_smul, fun x y => contDiff_smul.ContDiffOn⟩
#align smooth_smul smooth_smul
-/

#print ContMDiffWithinAt.smul /-
theorem ContMDiffWithinAt.smul {f : M → 𝕜} {g : M → V} (hf : ContMDiffWithinAt I 𝓘(𝕜) n f s x)
    (hg : ContMDiffWithinAt I 𝓘(𝕜, V) n g s x) :
    ContMDiffWithinAt I 𝓘(𝕜, V) n (fun p => f p • g p) s x :=
  (smooth_smul.of_le le_top).ContMDiffAt.comp_contMDiffWithinAt x (hf.prod_mk hg)
#align cont_mdiff_within_at.smul ContMDiffWithinAt.smul
-/

#print ContMDiffAt.smul /-
theorem ContMDiffAt.smul {f : M → 𝕜} {g : M → V} (hf : ContMDiffAt I 𝓘(𝕜) n f x)
    (hg : ContMDiffAt I 𝓘(𝕜, V) n g x) : ContMDiffAt I 𝓘(𝕜, V) n (fun p => f p • g p) x :=
  hf.smul hg
#align cont_mdiff_at.smul ContMDiffAt.smul
-/

#print ContMDiffOn.smul /-
theorem ContMDiffOn.smul {f : M → 𝕜} {g : M → V} (hf : ContMDiffOn I 𝓘(𝕜) n f s)
    (hg : ContMDiffOn I 𝓘(𝕜, V) n g s) : ContMDiffOn I 𝓘(𝕜, V) n (fun p => f p • g p) s :=
  fun x hx => (hf x hx).smul (hg x hx)
#align cont_mdiff_on.smul ContMDiffOn.smul
-/

#print ContMDiff.smul /-
theorem ContMDiff.smul {f : M → 𝕜} {g : M → V} (hf : ContMDiff I 𝓘(𝕜) n f)
    (hg : ContMDiff I 𝓘(𝕜, V) n g) : ContMDiff I 𝓘(𝕜, V) n fun p => f p • g p := fun x =>
  (hf x).smul (hg x)
#align cont_mdiff.smul ContMDiff.smul
-/

#print SmoothWithinAt.smul /-
theorem SmoothWithinAt.smul {f : M → 𝕜} {g : M → V} (hf : SmoothWithinAt I 𝓘(𝕜) f s x)
    (hg : SmoothWithinAt I 𝓘(𝕜, V) g s x) : SmoothWithinAt I 𝓘(𝕜, V) (fun p => f p • g p) s x :=
  hf.smul hg
#align smooth_within_at.smul SmoothWithinAt.smul
-/

#print SmoothAt.smul /-
theorem SmoothAt.smul {f : M → 𝕜} {g : M → V} (hf : SmoothAt I 𝓘(𝕜) f x)
    (hg : SmoothAt I 𝓘(𝕜, V) g x) : SmoothAt I 𝓘(𝕜, V) (fun p => f p • g p) x :=
  hf.smul hg
#align smooth_at.smul SmoothAt.smul
-/

#print SmoothOn.smul /-
theorem SmoothOn.smul {f : M → 𝕜} {g : M → V} (hf : SmoothOn I 𝓘(𝕜) f s)
    (hg : SmoothOn I 𝓘(𝕜, V) g s) : SmoothOn I 𝓘(𝕜, V) (fun p => f p • g p) s :=
  hf.smul hg
#align smooth_on.smul SmoothOn.smul
-/

#print Smooth.smul /-
theorem Smooth.smul {f : M → 𝕜} {g : M → V} (hf : Smooth I 𝓘(𝕜) f) (hg : Smooth I 𝓘(𝕜, V) g) :
    Smooth I 𝓘(𝕜, V) fun p => f p • g p :=
  hf.smul hg
#align smooth.smul Smooth.smul
-/

/-! ### Smoothness of (local) structomorphisms -/


section

variable [ChartedSpace H M'] [IsM' : SmoothManifoldWithCorners I M']

#print isLocalStructomorphOn_contDiffGroupoid_iff_aux /-
theorem isLocalStructomorphOn_contDiffGroupoid_iff_aux {f : LocalHomeomorph M M'}
    (hf : LiftPropOn (contDiffGroupoid ⊤ I).IsLocalStructomorphWithinAt f f.source) :
    SmoothOn I I f f.source :=
  by
  -- It suffices to show smoothness near each `x`
  apply contMDiffOn_of_locally_contMDiffOn
  intro x hx
  let c := chart_at H x
  let c' := chart_at H (f x)
  obtain ⟨-, hxf⟩ := hf x hx
  -- Since `f` is a local structomorph, it is locally equal to some transferred element `e` of
  -- the `cont_diff_groupoid`.
  obtain
    ⟨e, he, he' : eq_on (c' ∘ f ∘ c.symm) e (c.symm ⁻¹' f.source ∩ e.source), hex :
      c x ∈ e.source⟩ :=
    hxf (by simp only [hx, mfld_simps])
  -- We choose a convenient set `s` in `M`.
  let s : Set M := (f.trans c').source ∩ ((c.trans e).trans c'.symm).source
  refine' ⟨s, (f.trans c').open_source.inter ((c.trans e).trans c'.symm).open_source, _, _⟩
  · simp only [mfld_simps]
    rw [← he'] <;> simp only [hx, hex, mfld_simps]
  -- We need to show `f` is `cont_mdiff_on` the domain `s ∩ f.source`.  We show this in two
  -- steps: `f` is equal to `c'.symm ∘ e ∘ c` on that domain and that function is
  -- `cont_mdiff_on` it.
  have H₁ : ContMDiffOn I I ⊤ (c'.symm ∘ e ∘ c) s :=
    by
    have hc' : ContMDiffOn I I ⊤ c'.symm _ := contMDiffOn_chart_symm
    have he'' : ContMDiffOn I I ⊤ e _ := contMDiffOn_of_mem_contDiffGroupoid he
    have hc : ContMDiffOn I I ⊤ c _ := contMDiffOn_chart
    refine' (hc'.comp' (he''.comp' hc)).mono _
    mfld_set_tac
  have H₂ : eq_on f (c'.symm ∘ e ∘ c) s := by
    intro y hy
    simp only [mfld_simps] at hy 
    have hy₁ : f y ∈ c'.source := by simp only [hy, mfld_simps]
    have hy₂ : y ∈ c.source := by simp only [hy, mfld_simps]
    have hy₃ : c y ∈ c.symm ⁻¹' f.source ∩ e.source := by simp only [hy, mfld_simps]
    calc
      f y = c'.symm (c' (f y)) := by rw [c'.left_inv hy₁]
      _ = c'.symm (c' (f (c.symm (c y)))) := by rw [c.left_inv hy₂]
      _ = c'.symm (e (c y)) := by rw [← he' hy₃]
  refine' (H₁.congr H₂).mono _
  mfld_set_tac
#align is_local_structomorph_on_cont_diff_groupoid_iff_aux isLocalStructomorphOn_contDiffGroupoid_iff_aux
-/

#print isLocalStructomorphOn_contDiffGroupoid_iff /-
/-- Let `M` and `M'` be smooth manifolds with the same model-with-corners, `I`.  Then `f : M → M'`
is a local structomorphism for `I`, if and only if it is manifold-smooth on the domain of definition
in both directions. -/
theorem isLocalStructomorphOn_contDiffGroupoid_iff (f : LocalHomeomorph M M') :
    LiftPropOn (contDiffGroupoid ⊤ I).IsLocalStructomorphWithinAt f f.source ↔
      SmoothOn I I f f.source ∧ SmoothOn I I f.symm f.target :=
  by
  constructor
  · intro h
    refine'
      ⟨isLocalStructomorphOn_contDiffGroupoid_iff_aux h,
        isLocalStructomorphOn_contDiffGroupoid_iff_aux _⟩
    -- todo: we can generalize this part of the proof to a lemma
    intro X hX
    let x := f.symm X
    have hx : x ∈ f.source := f.symm.maps_to hX
    let c := chart_at H x
    let c' := chart_at H X
    obtain ⟨-, hxf⟩ := h x hx
    refine' ⟨(f.symm.continuous_at hX).ContinuousWithinAt, fun h2x => _⟩
    obtain ⟨e, he, h2e, hef, hex⟩ :
      ∃ e : LocalHomeomorph H H,
        e ∈ contDiffGroupoid ⊤ I ∧
          e.source ⊆ (c.symm ≫ₕ f ≫ₕ c').source ∧
            eq_on (c' ∘ f ∘ c.symm) e e.source ∧ c x ∈ e.source :=
      by
      have h1 : c' = chart_at H (f x) := by simp only [f.right_inv hX]
      have h2 : ⇑c' ∘ ⇑f ∘ ⇑c.symm = ⇑(c.symm ≫ₕ f ≫ₕ c') := rfl
      have hcx : c x ∈ c.symm ⁻¹' f.source := by simp only [hx, mfld_simps]
      rw [h2]
      rw [← h1, h2, LocalHomeomorph.isLocalStructomorphWithinAt_iff'] at hxf 
      · exact hxf hcx
      · mfld_set_tac
      · apply Or.inl
        simp only [hx, h1, mfld_simps]
    have h2X : c' X = e (c (f.symm X)) := by
      rw [← hef hex]
      dsimp only [Function.comp]
      have hfX : f.symm X ∈ c.source := by simp only [hX, mfld_simps]
      rw [c.left_inv hfX, f.right_inv hX]
    have h3e : eq_on (c ∘ f.symm ∘ c'.symm) e.symm (c'.symm ⁻¹' f.target ∩ e.target) :=
      by
      have h1 : eq_on (c.symm ≫ₕ f ≫ₕ c').symm e.symm (e.target ∩ e.target) :=
        by
        apply eq_on.symm
        refine' e.is_image_source_target.symm_eq_on_of_inter_eq_of_eq_on _ _
        · rw [inter_self, inter_eq_right_iff_subset.mpr h2e]
        rw [inter_self]; exact hef.symm
      have h2 : e.target ⊆ (c.symm ≫ₕ f ≫ₕ c').target :=
        by
        intro x hx; rw [← e.right_inv hx, ← hef (e.symm.maps_to hx)]
        exact LocalHomeomorph.mapsTo _ (h2e <| e.symm.maps_to hx)
      rw [inter_self] at h1 
      rwa [inter_eq_right_iff_subset.mpr]
      refine' h2.trans _
      mfld_set_tac
    refine' ⟨e.symm, StructureGroupoid.symm _ he, h3e, _⟩
    rw [h2X]; exact e.maps_to hex
  · -- We now show the converse: a local homeomorphism `f : M → M'` which is smooth in both
    -- directions is a local structomorphism.  We do this by proposing
    -- `((chart_at H x).symm.trans f).trans (chart_at H (f x))` as a candidate for a structomorphism
    -- of `H`.
    rintro ⟨h₁, h₂⟩ x hx
    refine' ⟨(h₁ x hx).ContinuousWithinAt, _⟩
    let c := chart_at H x
    let c' := chart_at H (f x)
    rintro (hx' : c x ∈ c.symm ⁻¹' f.source)
    -- propose `(c.symm.trans f).trans c'` as a candidate for a local structomorphism of `H`
    refine' ⟨(c.symm.trans f).trans c', ⟨_, _⟩, (_ : eq_on (c' ∘ f ∘ c.symm) _ _), _⟩
    · -- smoothness of the candidate local structomorphism in the forward direction
      intro y hy
      simp only [mfld_simps] at hy 
      have H : ContMDiffWithinAt I I ⊤ f (f ≫ₕ c').source ((extChartAt I x).symm y) :=
        by
        refine' (h₁ ((extChartAt I x).symm y) _).mono _
        · simp only [hy, mfld_simps]
        · mfld_set_tac
      have hy' : (extChartAt I x).symm y ∈ c.source := by simp only [hy, mfld_simps]
      have hy'' : f ((extChartAt I x).symm y) ∈ c'.source := by simp only [hy, mfld_simps]
      rw [contMDiffWithinAt_iff_of_mem_source hy' hy''] at H 
      · convert H.2.mono _
        · simp only [hy, mfld_simps]
        · mfld_set_tac
      · infer_instance
      · infer_instance
    · -- smoothness of the candidate local structomorphism in the reverse direction
      intro y hy
      simp only [mfld_simps] at hy 
      have H : ContMDiffWithinAt I I ⊤ f.symm (f.symm ≫ₕ c).source ((extChartAt I (f x)).symm y) :=
        by
        refine' (h₂ ((extChartAt I (f x)).symm y) _).mono _
        · simp only [hy, mfld_simps]
        · mfld_set_tac
      have hy' : (extChartAt I (f x)).symm y ∈ c'.source := by simp only [hy, mfld_simps]
      have hy'' : f.symm ((extChartAt I (f x)).symm y) ∈ c.source := by simp only [hy, mfld_simps]
      rw [contMDiffWithinAt_iff_of_mem_source hy' hy''] at H 
      · convert H.2.mono _
        · simp only [hy, mfld_simps]
        · mfld_set_tac
      · infer_instance
      · infer_instance
    -- now check the candidate local structomorphism agrees with `f` where it is supposed to
    · simp only [mfld_simps]
    · simp only [hx', mfld_simps]
#align is_local_structomorph_on_cont_diff_groupoid_iff isLocalStructomorphOn_contDiffGroupoid_iff
-/

end

