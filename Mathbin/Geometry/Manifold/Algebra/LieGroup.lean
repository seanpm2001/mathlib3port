/-
Copyright © 2020 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri

! This file was ported from Lean 3 source module geometry.manifold.algebra.lie_group
! leanprover-community/mathlib commit 30faa0c3618ce1472bf6305ae0e3fa56affa3f95
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Manifold.Algebra.Monoid

/-!
# Lie groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A Lie group is a group that is also a smooth manifold, in which the group operations of
multiplication and inversion are smooth maps. Smoothness of the group multiplication means that
multiplication is a smooth mapping of the product manifold `G` × `G` into `G`.

Note that, since a manifold here is not second-countable and Hausdorff a Lie group here is not
guaranteed to be second-countable (even though it can be proved it is Hausdorff). Note also that Lie
groups here are not necessarily finite dimensional.

## Main definitions and statements

* `lie_add_group I G` : a Lie additive group where `G` is a manifold on the model with corners `I`.
* `lie_group I G`     : a Lie multiplicative group where `G` is a manifold on the model with
                        corners `I`.
* `normed_space_lie_add_group` : a normed vector space over a nontrivially normed field
                                 is an additive Lie group.

## Implementation notes

A priori, a Lie group here is a manifold with corners.

The definition of Lie group cannot require `I : model_with_corners 𝕜 E E` with the same space as the
model space and as the model vector space, as one might hope, beause in the product situation,
the model space is `model_prod E E'` and the model vector space is `E × E'`, which are not the same,
so the definition does not apply. Hence the definition should be more general, allowing
`I : model_with_corners 𝕜 E H`.
-/


noncomputable section

open scoped Manifold

#print LieAddGroup /-
-- See note [Design choices about smooth algebraic structures]
/-- A Lie (additive) group is a group and a smooth manifold at the same time in which
the addition and negation operations are smooth. -/
class LieAddGroup {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H]
    {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E] (I : ModelWithCorners 𝕜 E H) (G : Type _)
    [AddGroup G] [TopologicalSpace G] [ChartedSpace H G] extends SmoothAdd I G : Prop where
  smooth_neg : Smooth I I fun a : G => -a
#align lie_add_group LieAddGroup
-/

#print LieGroup /-
-- See note [Design choices about smooth algebraic structures]
/-- A Lie group is a group and a smooth manifold at the same time in which
the multiplication and inverse operations are smooth. -/
@[to_additive]
class LieGroup {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H]
    {E : Type _} [NormedAddCommGroup E] [NormedSpace 𝕜 E] (I : ModelWithCorners 𝕜 E H) (G : Type _)
    [Group G] [TopologicalSpace G] [ChartedSpace H G] extends SmoothMul I G : Prop where
  smooth_inv : Smooth I I fun a : G => a⁻¹
#align lie_group LieGroup
#align lie_add_group LieAddGroup
-/

section LieGroup

variable {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H] {E : Type _}
  [NormedAddCommGroup E] [NormedSpace 𝕜 E] {I : ModelWithCorners 𝕜 E H} {F : Type _}
  [NormedAddCommGroup F] [NormedSpace 𝕜 F] {J : ModelWithCorners 𝕜 F F} {G : Type _}
  [TopologicalSpace G] [ChartedSpace H G] [Group G] [LieGroup I G] {E' : Type _}
  [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H' : Type _} [TopologicalSpace H']
  {I' : ModelWithCorners 𝕜 E' H'} {M : Type _} [TopologicalSpace M] [ChartedSpace H' M]
  {E'' : Type _} [NormedAddCommGroup E''] [NormedSpace 𝕜 E''] {H'' : Type _} [TopologicalSpace H'']
  {I'' : ModelWithCorners 𝕜 E'' H''} {M' : Type _} [TopologicalSpace M'] [ChartedSpace H'' M']
  {n : ℕ∞}

section

variable (I)

#print smooth_inv /-
@[to_additive]
theorem smooth_inv : Smooth I I fun x : G => x⁻¹ :=
  LieGroup.smooth_inv
#align smooth_inv smooth_inv
#align smooth_neg smooth_neg
-/

#print topologicalGroup_of_lieGroup /-
/-- A Lie group is a topological group. This is not an instance for technical reasons,
see note [Design choices about smooth algebraic structures]. -/
@[to_additive
      "An additive Lie group is an additive topological group. This is not an instance for technical\nreasons, see note [Design choices about smooth algebraic structures]."]
theorem topologicalGroup_of_lieGroup : TopologicalGroup G :=
  { continuousMul_of_smooth I with continuous_inv := (smooth_inv I).Continuous }
#align topological_group_of_lie_group topologicalGroup_of_lieGroup
#align topological_add_group_of_lie_add_group topologicalAddGroup_of_lieAddGroup
-/

end

#print ContMDiffWithinAt.inv /-
@[to_additive]
theorem ContMDiffWithinAt.inv {f : M → G} {s : Set M} {x₀ : M}
    (hf : ContMDiffWithinAt I' I n f s x₀) : ContMDiffWithinAt I' I n (fun x => (f x)⁻¹) s x₀ :=
  ((smooth_inv I).of_le le_top).ContMDiffAt.ContMDiffWithinAt.comp x₀ hf <| Set.mapsTo_univ _ _
#align cont_mdiff_within_at.inv ContMDiffWithinAt.inv
#align cont_mdiff_within_at.neg ContMDiffWithinAt.neg
-/

#print ContMDiffAt.inv /-
@[to_additive]
theorem ContMDiffAt.inv {f : M → G} {x₀ : M} (hf : ContMDiffAt I' I n f x₀) :
    ContMDiffAt I' I n (fun x => (f x)⁻¹) x₀ :=
  ((smooth_inv I).of_le le_top).ContMDiffAt.comp x₀ hf
#align cont_mdiff_at.inv ContMDiffAt.inv
#align cont_mdiff_at.neg ContMDiffAt.neg
-/

#print ContMDiffOn.inv /-
@[to_additive]
theorem ContMDiffOn.inv {f : M → G} {s : Set M} (hf : ContMDiffOn I' I n f s) :
    ContMDiffOn I' I n (fun x => (f x)⁻¹) s := fun x hx => (hf x hx).inv
#align cont_mdiff_on.inv ContMDiffOn.inv
#align cont_mdiff_on.neg ContMDiffOn.neg
-/

#print ContMDiff.inv /-
@[to_additive]
theorem ContMDiff.inv {f : M → G} (hf : ContMDiff I' I n f) : ContMDiff I' I n fun x => (f x)⁻¹ :=
  fun x => (hf x).inv
#align cont_mdiff.inv ContMDiff.inv
#align cont_mdiff.neg ContMDiff.neg
-/

#print SmoothWithinAt.inv /-
@[to_additive]
theorem SmoothWithinAt.inv {f : M → G} {s : Set M} {x₀ : M} (hf : SmoothWithinAt I' I f s x₀) :
    SmoothWithinAt I' I (fun x => (f x)⁻¹) s x₀ :=
  hf.inv
#align smooth_within_at.inv SmoothWithinAt.inv
#align smooth_within_at.neg SmoothWithinAt.neg
-/

#print SmoothAt.inv /-
@[to_additive]
theorem SmoothAt.inv {f : M → G} {x₀ : M} (hf : SmoothAt I' I f x₀) :
    SmoothAt I' I (fun x => (f x)⁻¹) x₀ :=
  hf.inv
#align smooth_at.inv SmoothAt.inv
#align smooth_at.neg SmoothAt.neg
-/

#print SmoothOn.inv /-
@[to_additive]
theorem SmoothOn.inv {f : M → G} {s : Set M} (hf : SmoothOn I' I f s) :
    SmoothOn I' I (fun x => (f x)⁻¹) s :=
  hf.inv
#align smooth_on.inv SmoothOn.inv
#align smooth_on.neg SmoothOn.neg
-/

#print Smooth.inv /-
@[to_additive]
theorem Smooth.inv {f : M → G} (hf : Smooth I' I f) : Smooth I' I fun x => (f x)⁻¹ :=
  hf.inv
#align smooth.inv Smooth.inv
#align smooth.neg Smooth.neg
-/

#print ContMDiffWithinAt.div /-
@[to_additive]
theorem ContMDiffWithinAt.div {f g : M → G} {s : Set M} {x₀ : M}
    (hf : ContMDiffWithinAt I' I n f s x₀) (hg : ContMDiffWithinAt I' I n g s x₀) :
    ContMDiffWithinAt I' I n (fun x => f x / g x) s x₀ := by simp_rw [div_eq_mul_inv];
  exact hf.mul hg.inv
#align cont_mdiff_within_at.div ContMDiffWithinAt.div
#align cont_mdiff_within_at.sub ContMDiffWithinAt.sub
-/

#print ContMDiffAt.div /-
@[to_additive]
theorem ContMDiffAt.div {f g : M → G} {x₀ : M} (hf : ContMDiffAt I' I n f x₀)
    (hg : ContMDiffAt I' I n g x₀) : ContMDiffAt I' I n (fun x => f x / g x) x₀ := by
  simp_rw [div_eq_mul_inv]; exact hf.mul hg.inv
#align cont_mdiff_at.div ContMDiffAt.div
#align cont_mdiff_at.sub ContMDiffAt.sub
-/

#print ContMDiffOn.div /-
@[to_additive]
theorem ContMDiffOn.div {f g : M → G} {s : Set M} (hf : ContMDiffOn I' I n f s)
    (hg : ContMDiffOn I' I n g s) : ContMDiffOn I' I n (fun x => f x / g x) s := by
  simp_rw [div_eq_mul_inv]; exact hf.mul hg.inv
#align cont_mdiff_on.div ContMDiffOn.div
#align cont_mdiff_on.sub ContMDiffOn.sub
-/

#print ContMDiff.div /-
@[to_additive]
theorem ContMDiff.div {f g : M → G} (hf : ContMDiff I' I n f) (hg : ContMDiff I' I n g) :
    ContMDiff I' I n fun x => f x / g x := by simp_rw [div_eq_mul_inv]; exact hf.mul hg.inv
#align cont_mdiff.div ContMDiff.div
#align cont_mdiff.sub ContMDiff.sub
-/

#print SmoothWithinAt.div /-
@[to_additive]
theorem SmoothWithinAt.div {f g : M → G} {s : Set M} {x₀ : M} (hf : SmoothWithinAt I' I f s x₀)
    (hg : SmoothWithinAt I' I g s x₀) : SmoothWithinAt I' I (fun x => f x / g x) s x₀ :=
  hf.div hg
#align smooth_within_at.div SmoothWithinAt.div
#align smooth_within_at.sub SmoothWithinAt.sub
-/

#print SmoothAt.div /-
@[to_additive]
theorem SmoothAt.div {f g : M → G} {x₀ : M} (hf : SmoothAt I' I f x₀) (hg : SmoothAt I' I g x₀) :
    SmoothAt I' I (fun x => f x / g x) x₀ :=
  hf.div hg
#align smooth_at.div SmoothAt.div
#align smooth_at.sub SmoothAt.sub
-/

#print SmoothOn.div /-
@[to_additive]
theorem SmoothOn.div {f g : M → G} {s : Set M} (hf : SmoothOn I' I f s) (hg : SmoothOn I' I g s) :
    SmoothOn I' I (f / g) s :=
  hf.div hg
#align smooth_on.div SmoothOn.div
#align smooth_on.sub SmoothOn.sub
-/

#print Smooth.div /-
@[to_additive]
theorem Smooth.div {f g : M → G} (hf : Smooth I' I f) (hg : Smooth I' I g) : Smooth I' I (f / g) :=
  hf.div hg
#align smooth.div Smooth.div
#align smooth.sub Smooth.sub
-/

end LieGroup

section ProdLieGroup

-- Instance of product group
@[to_additive]
instance {𝕜 : Type _} [NontriviallyNormedField 𝕜] {H : Type _} [TopologicalSpace H] {E : Type _}
    [NormedAddCommGroup E] [NormedSpace 𝕜 E] {I : ModelWithCorners 𝕜 E H} {G : Type _}
    [TopologicalSpace G] [ChartedSpace H G] [Group G] [LieGroup I G] {E' : Type _}
    [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H' : Type _} [TopologicalSpace H']
    {I' : ModelWithCorners 𝕜 E' H'} {G' : Type _} [TopologicalSpace G'] [ChartedSpace H' G']
    [Group G'] [LieGroup I' G'] : LieGroup (I.Prod I') (G × G') :=
  { SmoothMul.prod _ _ _ _ with smooth_inv := smooth_fst.inv.prod_mk smooth_snd.inv }

end ProdLieGroup

/-! ### Normed spaces are Lie groups -/


#print normedSpaceLieAddGroup /-
instance normedSpaceLieAddGroup {𝕜 : Type _} [NontriviallyNormedField 𝕜] {E : Type _}
    [NormedAddCommGroup E] [NormedSpace 𝕜 E] : LieAddGroup 𝓘(𝕜, E) E :=
  {
    model_space_smooth with
    smooth_add := smooth_iff.2 ⟨continuous_add, fun x y => contDiff_add.ContDiffOn⟩
    smooth_neg := smooth_iff.2 ⟨continuous_neg, fun x y => contDiff_neg.ContDiffOn⟩ }
#align normed_space_lie_add_group normedSpaceLieAddGroup
-/

