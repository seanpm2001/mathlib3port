/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module geometry.manifold.partition_of_unity
! leanprover-community/mathlib commit 9240e8be927a0955b9a82c6c85ef499ee3a626b8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Manifold.Algebra.Structures
import Mathbin.Geometry.Manifold.BumpFunction
import Mathbin.Topology.MetricSpace.PartitionOfUnity
import Mathbin.Topology.ShrinkingLemma

/-!
# Smooth partition of unity

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define two structures, `smooth_bump_covering` and `smooth_partition_of_unity`. Both
structures describe coverings of a set by a locally finite family of supports of smooth functions
with some additional properties. The former structure is mostly useful as an intermediate step in
the construction of a smooth partition of unity but some proofs that traditionally deal with a
partition of unity can use a `smooth_bump_covering` as well.

Given a real manifold `M` and its subset `s`, a `smooth_bump_covering ι I M s` is a collection of
`smooth_bump_function`s `f i` indexed by `i : ι` such that

* the center of each `f i` belongs to `s`;
* the family of sets `support (f i)` is locally finite;
* for each `x ∈ s`, there exists `i : ι` such that `f i =ᶠ[𝓝 x] 1`.
In the same settings, a `smooth_partition_of_unity ι I M s` is a collection of smooth nonnegative
functions `f i : C^∞⟮I, M; 𝓘(ℝ), ℝ⟯`, `i : ι`, such that

* the family of sets `support (f i)` is locally finite;
* for each `x ∈ s`, the sum `∑ᶠ i, f i x` equals one;
* for each `x`, the sum `∑ᶠ i, f i x` is less than or equal to one.

We say that `f : smooth_bump_covering ι I M s` is *subordinate* to a map `U : M → set M` if for each
index `i`, we have `tsupport (f i) ⊆ U (f i).c`. This notion is a bit more general than
being subordinate to an open covering of `M`, because we make no assumption about the way `U x`
depends on `x`.

We prove that on a smooth finitely dimensional real manifold with `σ`-compact Hausdorff topology,
for any `U : M → set M` such that `∀ x ∈ s, U x ∈ 𝓝 x` there exists a `smooth_bump_covering ι I M s`
subordinate to `U`. Then we use this fact to prove a similar statement about smooth partitions of
unity, see `smooth_partition_of_unity.exists_is_subordinate`.

Finally, we use existence of a partition of unity to prove lemma
`exists_smooth_forall_mem_convex_of_local` that allows us to construct a globally defined smooth
function from local functions.

## TODO

* Build a framework for to transfer local definitions to global using partition of unity and use it
  to define, e.g., the integral of a differential form over a manifold. Lemma
  `exists_smooth_forall_mem_convex_of_local` is a first step in this direction.

## Tags

smooth bump function, partition of unity
-/


universe uι uE uH uM uF

open Function Filter FiniteDimensional Set

open scoped Topology Manifold Classical Filter BigOperators

noncomputable section

variable {ι : Type uι} {E : Type uE} [NormedAddCommGroup E] [NormedSpace ℝ E]
  [FiniteDimensional ℝ E] {F : Type uF} [NormedAddCommGroup F] [NormedSpace ℝ F] {H : Type uH}
  [TopologicalSpace H] (I : ModelWithCorners ℝ E H) {M : Type uM} [TopologicalSpace M]
  [ChartedSpace H M] [SmoothManifoldWithCorners I M]

/-!
### Covering by supports of smooth bump functions

In this section we define `smooth_bump_covering ι I M s` to be a collection of
`smooth_bump_function`s such that their supports is a locally finite family of sets and for each `x
∈ s` some function `f i` from the collection is equal to `1` in a neighborhood of `x`. A covering of
this type is useful to construct a smooth partition of unity and can be used instead of a partition
of unity in some proofs.

We prove that on a smooth finite dimensional real manifold with `σ`-compact Hausdorff topology, for
any `U : M → set M` such that `∀ x ∈ s, U x ∈ 𝓝 x` there exists a `smooth_bump_covering ι I M s`
subordinate to `U`. Then we use this fact to prove a version of the Whitney embedding theorem: any
compact real manifold can be embedded into `ℝ^n` for large enough `n`.  -/


variable (ι M)

#print SmoothBumpCovering /-
/-- We say that a collection of `smooth_bump_function`s is a `smooth_bump_covering` of a set `s` if

* `(f i).c ∈ s` for all `i`;
* the family `λ i, support (f i)` is locally finite;
* for each point `x ∈ s` there exists `i` such that `f i =ᶠ[𝓝 x] 1`;
  in other words, `x` belongs to the interior of `{y | f i y = 1}`;

If `M` is a finite dimensional real manifold which is a `σ`-compact Hausdorff topological space,
then for every covering `U : M → set M`, `∀ x, U x ∈ 𝓝 x`, there exists a `smooth_bump_covering`
subordinate to `U`, see `smooth_bump_covering.exists_is_subordinate`.

This covering can be used, e.g., to construct a partition of unity and to prove the weak
Whitney embedding theorem. -/
@[nolint has_nonempty_instance]
structure SmoothBumpCovering (s : Set M := univ) where
  c : ι → M
  toFun : ∀ i, SmoothBumpFunction I (c i)
  c_mem' : ∀ i, c i ∈ s
  locally_finite' : LocallyFinite fun i => support (to_fun i)
  eventuallyEq_one' : ∀ x ∈ s, ∃ i, to_fun i =ᶠ[𝓝 x] 1
#align smooth_bump_covering SmoothBumpCovering
-/

#print SmoothPartitionOfUnity /-
/-- We say that that a collection of functions form a smooth partition of unity on a set `s` if

* all functions are infinitely smooth and nonnegative;
* the family `λ i, support (f i)` is locally finite;
* for all `x ∈ s` the sum `∑ᶠ i, f i x` equals one;
* for all `x`, the sum `∑ᶠ i, f i x` is less than or equal to one. -/
structure SmoothPartitionOfUnity (s : Set M := univ) where
  toFun : ι → C^∞⟮I, M; 𝓘(ℝ), ℝ⟯
  locally_finite' : LocallyFinite fun i => support (to_fun i)
  nonneg' : ∀ i x, 0 ≤ to_fun i x
  sum_eq_one' : ∀ x ∈ s, ∑ᶠ i, to_fun i x = 1
  sum_le_one' : ∀ x, ∑ᶠ i, to_fun i x ≤ 1
#align smooth_partition_of_unity SmoothPartitionOfUnity
-/

variable {ι I M}

namespace SmoothPartitionOfUnity

variable {s : Set M} (f : SmoothPartitionOfUnity ι I M s) {n : ℕ∞}

instance {s : Set M} : CoeFun (SmoothPartitionOfUnity ι I M s) fun _ => ι → C^∞⟮I, M; 𝓘(ℝ), ℝ⟯ :=
  ⟨SmoothPartitionOfUnity.toFun⟩

#print SmoothPartitionOfUnity.locallyFinite /-
protected theorem locallyFinite : LocallyFinite fun i => support (f i) :=
  f.locally_finite'
#align smooth_partition_of_unity.locally_finite SmoothPartitionOfUnity.locallyFinite
-/

#print SmoothPartitionOfUnity.nonneg /-
theorem nonneg (i : ι) (x : M) : 0 ≤ f i x :=
  f.nonneg' i x
#align smooth_partition_of_unity.nonneg SmoothPartitionOfUnity.nonneg
-/

#print SmoothPartitionOfUnity.sum_eq_one /-
theorem sum_eq_one {x} (hx : x ∈ s) : ∑ᶠ i, f i x = 1 :=
  f.sum_eq_one' x hx
#align smooth_partition_of_unity.sum_eq_one SmoothPartitionOfUnity.sum_eq_one
-/

#print SmoothPartitionOfUnity.sum_le_one /-
theorem sum_le_one (x : M) : ∑ᶠ i, f i x ≤ 1 :=
  f.sum_le_one' x
#align smooth_partition_of_unity.sum_le_one SmoothPartitionOfUnity.sum_le_one
-/

#print SmoothPartitionOfUnity.toPartitionOfUnity /-
/-- Reinterpret a smooth partition of unity as a continuous partition of unity. -/
def toPartitionOfUnity : PartitionOfUnity ι M s :=
  { f with toFun := fun i => f i }
#align smooth_partition_of_unity.to_partition_of_unity SmoothPartitionOfUnity.toPartitionOfUnity
-/

#print SmoothPartitionOfUnity.smooth_sum /-
theorem smooth_sum : Smooth I 𝓘(ℝ) fun x => ∑ᶠ i, f i x :=
  smooth_finsum (fun i => (f i).Smooth) f.LocallyFinite
#align smooth_partition_of_unity.smooth_sum SmoothPartitionOfUnity.smooth_sum
-/

#print SmoothPartitionOfUnity.le_one /-
theorem le_one (i : ι) (x : M) : f i x ≤ 1 :=
  f.toPartitionOfUnity.le_one i x
#align smooth_partition_of_unity.le_one SmoothPartitionOfUnity.le_one
-/

#print SmoothPartitionOfUnity.sum_nonneg /-
theorem sum_nonneg (x : M) : 0 ≤ ∑ᶠ i, f i x :=
  f.toPartitionOfUnity.sum_nonneg x
#align smooth_partition_of_unity.sum_nonneg SmoothPartitionOfUnity.sum_nonneg
-/

#print SmoothPartitionOfUnity.contMDiff_smul /-
theorem contMDiff_smul {g : M → F} {i} (hg : ∀ x ∈ tsupport (f i), ContMDiffAt I 𝓘(ℝ, F) n g x) :
    ContMDiff I 𝓘(ℝ, F) n fun x => f i x • g x :=
  contMDiff_of_support fun x hx =>
    ((f i).ContMDiff.ContMDiffAt.of_le le_top).smul <| hg x <| tsupport_smul_subset_left _ _ hx
#align smooth_partition_of_unity.cont_mdiff_smul SmoothPartitionOfUnity.contMDiff_smul
-/

#print SmoothPartitionOfUnity.smooth_smul /-
theorem smooth_smul {g : M → F} {i} (hg : ∀ x ∈ tsupport (f i), SmoothAt I 𝓘(ℝ, F) g x) :
    Smooth I 𝓘(ℝ, F) fun x => f i x • g x :=
  f.contMDiff_smul hg
#align smooth_partition_of_unity.smooth_smul SmoothPartitionOfUnity.smooth_smul
-/

#print SmoothPartitionOfUnity.contMDiff_finsum_smul /-
/-- If `f` is a smooth partition of unity on a set `s : set M` and `g : ι → M → F` is a family of
functions such that `g i` is $C^n$ smooth at every point of the topological support of `f i`, then
the sum `λ x, ∑ᶠ i, f i x • g i x` is smooth on the whole manifold. -/
theorem contMDiff_finsum_smul {g : ι → M → F}
    (hg : ∀ (i), ∀ x ∈ tsupport (f i), ContMDiffAt I 𝓘(ℝ, F) n (g i) x) :
    ContMDiff I 𝓘(ℝ, F) n fun x => ∑ᶠ i, f i x • g i x :=
  (contMDiff_finsum fun i => f.contMDiff_smul (hg i)) <|
    f.LocallyFinite.Subset fun i => support_smul_subset_left _ _
#align smooth_partition_of_unity.cont_mdiff_finsum_smul SmoothPartitionOfUnity.contMDiff_finsum_smul
-/

#print SmoothPartitionOfUnity.smooth_finsum_smul /-
/-- If `f` is a smooth partition of unity on a set `s : set M` and `g : ι → M → F` is a family of
functions such that `g i` is smooth at every point of the topological support of `f i`, then the sum
`λ x, ∑ᶠ i, f i x • g i x` is smooth on the whole manifold. -/
theorem smooth_finsum_smul {g : ι → M → F}
    (hg : ∀ (i), ∀ x ∈ tsupport (f i), SmoothAt I 𝓘(ℝ, F) (g i) x) :
    Smooth I 𝓘(ℝ, F) fun x => ∑ᶠ i, f i x • g i x :=
  f.contMDiff_finsum_smul hg
#align smooth_partition_of_unity.smooth_finsum_smul SmoothPartitionOfUnity.smooth_finsum_smul
-/

#print SmoothPartitionOfUnity.finsum_smul_mem_convex /-
theorem finsum_smul_mem_convex {g : ι → M → F} {t : Set F} {x : M} (hx : x ∈ s)
    (hg : ∀ i, f i x ≠ 0 → g i x ∈ t) (ht : Convex ℝ t) : ∑ᶠ i, f i x • g i x ∈ t :=
  ht.finsum_mem (fun i => f.NonNeg _ _) (f.sum_eq_one hx) hg
#align smooth_partition_of_unity.finsum_smul_mem_convex SmoothPartitionOfUnity.finsum_smul_mem_convex
-/

#print SmoothPartitionOfUnity.IsSubordinate /-
/-- A smooth partition of unity `f i` is subordinate to a family of sets `U i` indexed by the same
type if for each `i` the closure of the support of `f i` is a subset of `U i`. -/
def IsSubordinate (f : SmoothPartitionOfUnity ι I M s) (U : ι → Set M) :=
  ∀ i, tsupport (f i) ⊆ U i
#align smooth_partition_of_unity.is_subordinate SmoothPartitionOfUnity.IsSubordinate
-/

variable {f} {U : ι → Set M}

#print SmoothPartitionOfUnity.isSubordinate_toPartitionOfUnity /-
@[simp]
theorem isSubordinate_toPartitionOfUnity :
    f.toPartitionOfUnity.IsSubordinate U ↔ f.IsSubordinate U :=
  Iff.rfl
#align smooth_partition_of_unity.is_subordinate_to_partition_of_unity SmoothPartitionOfUnity.isSubordinate_toPartitionOfUnity
-/

alias is_subordinate_to_partition_of_unity ↔ _ is_subordinate.to_partition_of_unity
#align smooth_partition_of_unity.is_subordinate.to_partition_of_unity SmoothPartitionOfUnity.IsSubordinate.toPartitionOfUnity

#print SmoothPartitionOfUnity.IsSubordinate.contMDiff_finsum_smul /-
/-- If `f` is a smooth partition of unity on a set `s : set M` subordinate to a family of open sets
`U : ι → set M` and `g : ι → M → F` is a family of functions such that `g i` is $C^n$ smooth on
`U i`, then the sum `λ x, ∑ᶠ i, f i x • g i x` is $C^n$ smooth on the whole manifold. -/
theorem IsSubordinate.contMDiff_finsum_smul {g : ι → M → F} (hf : f.IsSubordinate U)
    (ho : ∀ i, IsOpen (U i)) (hg : ∀ i, ContMDiffOn I 𝓘(ℝ, F) n (g i) (U i)) :
    ContMDiff I 𝓘(ℝ, F) n fun x => ∑ᶠ i, f i x • g i x :=
  f.contMDiff_finsum_smul fun i x hx => (hg i).ContMDiffAt <| (ho i).mem_nhds (hf i hx)
#align smooth_partition_of_unity.is_subordinate.cont_mdiff_finsum_smul SmoothPartitionOfUnity.IsSubordinate.contMDiff_finsum_smul
-/

#print SmoothPartitionOfUnity.IsSubordinate.smooth_finsum_smul /-
/-- If `f` is a smooth partition of unity on a set `s : set M` subordinate to a family of open sets
`U : ι → set M` and `g : ι → M → F` is a family of functions such that `g i` is smooth on `U i`,
then the sum `λ x, ∑ᶠ i, f i x • g i x` is smooth on the whole manifold. -/
theorem IsSubordinate.smooth_finsum_smul {g : ι → M → F} (hf : f.IsSubordinate U)
    (ho : ∀ i, IsOpen (U i)) (hg : ∀ i, SmoothOn I 𝓘(ℝ, F) (g i) (U i)) :
    Smooth I 𝓘(ℝ, F) fun x => ∑ᶠ i, f i x • g i x :=
  hf.contMDiff_finsum_smul ho hg
#align smooth_partition_of_unity.is_subordinate.smooth_finsum_smul SmoothPartitionOfUnity.IsSubordinate.smooth_finsum_smul
-/

end SmoothPartitionOfUnity

namespace BumpCovering

#print BumpCovering.smooth_toPartitionOfUnity /-
-- Repeat variables to drop [finite_dimensional ℝ E] and [smooth_manifold_with_corners I M]
theorem smooth_toPartitionOfUnity {E : Type uE} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {H : Type uH} [TopologicalSpace H] {I : ModelWithCorners ℝ E H} {M : Type uM}
    [TopologicalSpace M] [ChartedSpace H M] {s : Set M} (f : BumpCovering ι M s)
    (hf : ∀ i, Smooth I 𝓘(ℝ) (f i)) (i : ι) : Smooth I 𝓘(ℝ) (f.toPartitionOfUnity i) :=
  (hf i).mul <|
    (smooth_finprod_cond fun j _ => smooth_const.sub (hf j)) <| by simp only [mul_support_one_sub];
      exact f.locally_finite
#align bump_covering.smooth_to_partition_of_unity BumpCovering.smooth_toPartitionOfUnity
-/

variable {s : Set M}

#print BumpCovering.toSmoothPartitionOfUnity /-
/-- A `bump_covering` such that all functions in this covering are smooth generates a smooth
partition of unity.

In our formalization, not every `f : bump_covering ι M s` with smooth functions `f i` is a
`smooth_bump_covering`; instead, a `smooth_bump_covering` is a covering by supports of
`smooth_bump_function`s. So, we define `bump_covering.to_smooth_partition_of_unity`, then reuse it
in `smooth_bump_covering.to_smooth_partition_of_unity`. -/
def toSmoothPartitionOfUnity (f : BumpCovering ι M s) (hf : ∀ i, Smooth I 𝓘(ℝ) (f i)) :
    SmoothPartitionOfUnity ι I M s :=
  { f.toPartitionOfUnity with
    toFun := fun i => ⟨f.toPartitionOfUnity i, f.smooth_toPartitionOfUnity hf i⟩ }
#align bump_covering.to_smooth_partition_of_unity BumpCovering.toSmoothPartitionOfUnity
-/

#print BumpCovering.toSmoothPartitionOfUnity_toPartitionOfUnity /-
@[simp]
theorem toSmoothPartitionOfUnity_toPartitionOfUnity (f : BumpCovering ι M s)
    (hf : ∀ i, Smooth I 𝓘(ℝ) (f i)) :
    (f.toSmoothPartitionOfUnity hf).toPartitionOfUnity = f.toPartitionOfUnity :=
  rfl
#align bump_covering.to_smooth_partition_of_unity_to_partition_of_unity BumpCovering.toSmoothPartitionOfUnity_toPartitionOfUnity
-/

#print BumpCovering.coe_toSmoothPartitionOfUnity /-
@[simp]
theorem coe_toSmoothPartitionOfUnity (f : BumpCovering ι M s) (hf : ∀ i, Smooth I 𝓘(ℝ) (f i))
    (i : ι) : ⇑(f.toSmoothPartitionOfUnity hf i) = f.toPartitionOfUnity i :=
  rfl
#align bump_covering.coe_to_smooth_partition_of_unity BumpCovering.coe_toSmoothPartitionOfUnity
-/

#print BumpCovering.IsSubordinate.toSmoothPartitionOfUnity /-
theorem IsSubordinate.toSmoothPartitionOfUnity {f : BumpCovering ι M s} {U : ι → Set M}
    (h : f.IsSubordinate U) (hf : ∀ i, Smooth I 𝓘(ℝ) (f i)) :
    (f.toSmoothPartitionOfUnity hf).IsSubordinate U :=
  h.toPartitionOfUnity
#align bump_covering.is_subordinate.to_smooth_partition_of_unity BumpCovering.IsSubordinate.toSmoothPartitionOfUnity
-/

end BumpCovering

namespace SmoothBumpCovering

variable {s : Set M} {U : M → Set M} (fs : SmoothBumpCovering ι I M s) {I}

instance : CoeFun (SmoothBumpCovering ι I M s) fun x => ∀ i : ι, SmoothBumpFunction I (x.c i) :=
  ⟨toFun⟩

@[simp]
theorem coe_mk (c : ι → M) (to_fun : ∀ i, SmoothBumpFunction I (c i)) (h₁ h₂ h₃) :
    ⇑(mk c to_fun h₁ h₂ h₃ : SmoothBumpCovering ι I M s) = to_fun :=
  rfl
#align smooth_bump_covering.coe_mk SmoothBumpCovering.coe_mk

#print SmoothBumpCovering.IsSubordinate /-
/--
We say that `f : smooth_bump_covering ι I M s` is *subordinate* to a map `U : M → set M` if for each
index `i`, we have `tsupport (f i) ⊆ U (f i).c`. This notion is a bit more general than
being subordinate to an open covering of `M`, because we make no assumption about the way `U x`
depends on `x`.
-/
def IsSubordinate {s : Set M} (f : SmoothBumpCovering ι I M s) (U : M → Set M) :=
  ∀ i, tsupport (f i) ⊆ U (f.c i)
#align smooth_bump_covering.is_subordinate SmoothBumpCovering.IsSubordinate
-/

#print SmoothBumpCovering.IsSubordinate.support_subset /-
theorem IsSubordinate.support_subset {fs : SmoothBumpCovering ι I M s} {U : M → Set M}
    (h : fs.IsSubordinate U) (i : ι) : support (fs i) ⊆ U (fs.c i) :=
  Subset.trans subset_closure (h i)
#align smooth_bump_covering.is_subordinate.support_subset SmoothBumpCovering.IsSubordinate.support_subset
-/

variable (I)

#print SmoothBumpCovering.exists_isSubordinate /-
/-- Let `M` be a smooth manifold with corners modelled on a finite dimensional real vector space.
Suppose also that `M` is a Hausdorff `σ`-compact topological space. Let `s` be a closed set
in `M` and `U : M → set M` be a collection of sets such that `U x ∈ 𝓝 x` for every `x ∈ s`.
Then there exists a smooth bump covering of `s` that is subordinate to `U`. -/
theorem exists_isSubordinate [T2Space M] [SigmaCompactSpace M] (hs : IsClosed s)
    (hU : ∀ x ∈ s, U x ∈ 𝓝 x) :
    ∃ (ι : Type uM) (f : SmoothBumpCovering ι I M s), f.IsSubordinate U :=
  by
  -- First we deduce some missing instances
  haveI : LocallyCompactSpace H := I.locally_compact
  haveI : LocallyCompactSpace M := ChartedSpace.locallyCompact H M
  haveI : NormalSpace M := normal_of_paracompact_t2
  -- Next we choose a covering by supports of smooth bump functions
  have hB := fun x hx => SmoothBumpFunction.nhds_basis_support I (hU x hx)
  rcases refinement_of_locallyCompact_sigmaCompact_of_nhds_basis_set hs hB with
    ⟨ι, c, f, hf, hsub', hfin⟩
  choose hcs hfU using hf
  -- Then we use the shrinking lemma to get a covering by smaller open
  rcases exists_subset_iUnion_closed_subset hs (fun i => (f i).isOpen_support)
      (fun x hx => hfin.point_finite x) hsub' with
    ⟨V, hsV, hVc, hVf⟩
  choose r hrR hr using fun i => (f i).exists_r_pos_lt_subset_ball (hVc i) (hVf i)
  refine' ⟨ι, ⟨c, fun i => (f i).updateRIn (r i) (hrR i), hcs, _, fun x hx => _⟩, fun i => _⟩
  · simpa only [SmoothBumpFunction.support_updateRIn]
  · refine' (mem_Union.1 <| hsV hx).imp fun i hi => _
    exact
      ((f i).updateRIn _ _).eventuallyEq_one_of_dist_lt ((f i).support_subset_source <| hVf _ hi)
        (hr i hi).2
  · simpa only [coe_mk, SmoothBumpFunction.support_updateRIn, tsupport] using hfU i
#align smooth_bump_covering.exists_is_subordinate SmoothBumpCovering.exists_isSubordinate
-/

variable {I M}

#print SmoothBumpCovering.locallyFinite /-
protected theorem locallyFinite : LocallyFinite fun i => support (fs i) :=
  fs.locally_finite'
#align smooth_bump_covering.locally_finite SmoothBumpCovering.locallyFinite
-/

#print SmoothBumpCovering.point_finite /-
protected theorem point_finite (x : M) : {i | fs i x ≠ 0}.Finite :=
  fs.LocallyFinite.point_finite x
#align smooth_bump_covering.point_finite SmoothBumpCovering.point_finite
-/

#print SmoothBumpCovering.mem_chartAt_source_of_eq_one /-
theorem mem_chartAt_source_of_eq_one {i : ι} {x : M} (h : fs i x = 1) :
    x ∈ (chartAt H (fs.c i)).source :=
  (fs i).support_subset_source <| by simp [h]
#align smooth_bump_covering.mem_chart_at_source_of_eq_one SmoothBumpCovering.mem_chartAt_source_of_eq_one
-/

#print SmoothBumpCovering.mem_extChartAt_source_of_eq_one /-
theorem mem_extChartAt_source_of_eq_one {i : ι} {x : M} (h : fs i x = 1) :
    x ∈ (extChartAt I (fs.c i)).source := by rw [extChartAt_source];
  exact fs.mem_chart_at_source_of_eq_one h
#align smooth_bump_covering.mem_ext_chart_at_source_of_eq_one SmoothBumpCovering.mem_extChartAt_source_of_eq_one
-/

#print SmoothBumpCovering.ind /-
/-- Index of a bump function such that `fs i =ᶠ[𝓝 x] 1`. -/
def ind (x : M) (hx : x ∈ s) : ι :=
  (fs.eventuallyEq_one' x hx).some
#align smooth_bump_covering.ind SmoothBumpCovering.ind
-/

#print SmoothBumpCovering.eventuallyEq_one /-
theorem eventuallyEq_one (x : M) (hx : x ∈ s) : fs (fs.ind x hx) =ᶠ[𝓝 x] 1 :=
  (fs.eventuallyEq_one' x hx).choose_spec
#align smooth_bump_covering.eventually_eq_one SmoothBumpCovering.eventuallyEq_one
-/

#print SmoothBumpCovering.apply_ind /-
theorem apply_ind (x : M) (hx : x ∈ s) : fs (fs.ind x hx) x = 1 :=
  (fs.eventuallyEq_one x hx).eq_of_nhds
#align smooth_bump_covering.apply_ind SmoothBumpCovering.apply_ind
-/

#print SmoothBumpCovering.mem_support_ind /-
theorem mem_support_ind (x : M) (hx : x ∈ s) : x ∈ support (fs <| fs.ind x hx) := by
  simp [fs.apply_ind x hx]
#align smooth_bump_covering.mem_support_ind SmoothBumpCovering.mem_support_ind
-/

#print SmoothBumpCovering.mem_chartAt_ind_source /-
theorem mem_chartAt_ind_source (x : M) (hx : x ∈ s) : x ∈ (chartAt H (fs.c (fs.ind x hx))).source :=
  fs.mem_chartAt_source_of_eq_one (fs.apply_ind x hx)
#align smooth_bump_covering.mem_chart_at_ind_source SmoothBumpCovering.mem_chartAt_ind_source
-/

#print SmoothBumpCovering.mem_extChartAt_ind_source /-
theorem mem_extChartAt_ind_source (x : M) (hx : x ∈ s) :
    x ∈ (extChartAt I (fs.c (fs.ind x hx))).source :=
  fs.mem_extChartAt_source_of_eq_one (fs.apply_ind x hx)
#align smooth_bump_covering.mem_ext_chart_at_ind_source SmoothBumpCovering.mem_extChartAt_ind_source
-/

#print SmoothBumpCovering.fintype /-
/-- The index type of a `smooth_bump_covering` of a compact manifold is finite. -/
protected def fintype [CompactSpace M] : Fintype ι :=
  fs.LocallyFinite.fintypeOfCompact fun i => (fs i).nonempty_support
#align smooth_bump_covering.fintype SmoothBumpCovering.fintype
-/

variable [T2Space M]

#print SmoothBumpCovering.toBumpCovering /-
/-- Reinterpret a `smooth_bump_covering` as a continuous `bump_covering`. Note that not every
`f : bump_covering ι M s` with smooth functions `f i` is a `smooth_bump_covering`. -/
def toBumpCovering : BumpCovering ι M s
    where
  toFun i := ⟨fs i, (fs i).Continuous⟩
  locally_finite' := fs.LocallyFinite
  nonneg' i x := (fs i).NonNeg
  le_one' i x := (fs i).le_one
  eventuallyEq_one' := fs.eventuallyEq_one'
#align smooth_bump_covering.to_bump_covering SmoothBumpCovering.toBumpCovering
-/

#print SmoothBumpCovering.isSubordinate_toBumpCovering /-
@[simp]
theorem isSubordinate_toBumpCovering {f : SmoothBumpCovering ι I M s} {U : M → Set M} :
    (f.toBumpCovering.IsSubordinate fun i => U (f.c i)) ↔ f.IsSubordinate U :=
  Iff.rfl
#align smooth_bump_covering.is_subordinate_to_bump_covering SmoothBumpCovering.isSubordinate_toBumpCovering
-/

alias is_subordinate_to_bump_covering ↔ _ is_subordinate.to_bump_covering
#align smooth_bump_covering.is_subordinate.to_bump_covering SmoothBumpCovering.IsSubordinate.toBumpCovering

#print SmoothBumpCovering.toSmoothPartitionOfUnity /-
/-- Every `smooth_bump_covering` defines a smooth partition of unity. -/
def toSmoothPartitionOfUnity : SmoothPartitionOfUnity ι I M s :=
  fs.toBumpCovering.toSmoothPartitionOfUnity fun i => (fs i).Smooth
#align smooth_bump_covering.to_smooth_partition_of_unity SmoothBumpCovering.toSmoothPartitionOfUnity
-/

#print SmoothBumpCovering.toSmoothPartitionOfUnity_apply /-
theorem toSmoothPartitionOfUnity_apply (i : ι) (x : M) :
    fs.toSmoothPartitionOfUnity i x = fs i x * ∏ᶠ (j) (hj : WellOrderingRel j i), (1 - fs j x) :=
  rfl
#align smooth_bump_covering.to_smooth_partition_of_unity_apply SmoothBumpCovering.toSmoothPartitionOfUnity_apply
-/

#print SmoothBumpCovering.toSmoothPartitionOfUnity_eq_mul_prod /-
theorem toSmoothPartitionOfUnity_eq_mul_prod (i : ι) (x : M) (t : Finset ι)
    (ht : ∀ j, WellOrderingRel j i → fs j x ≠ 0 → j ∈ t) :
    fs.toSmoothPartitionOfUnity i x =
      fs i x * ∏ j in t.filterₓ fun j => WellOrderingRel j i, (1 - fs j x) :=
  fs.toBumpCovering.toPartitionOfUnity_eq_mul_prod i x t ht
#align smooth_bump_covering.to_smooth_partition_of_unity_eq_mul_prod SmoothBumpCovering.toSmoothPartitionOfUnity_eq_mul_prod
-/

#print SmoothBumpCovering.exists_finset_toSmoothPartitionOfUnity_eventuallyEq /-
theorem exists_finset_toSmoothPartitionOfUnity_eventuallyEq (i : ι) (x : M) :
    ∃ t : Finset ι,
      fs.toSmoothPartitionOfUnity i =ᶠ[𝓝 x]
        fs i * ∏ j in t.filterₓ fun j => WellOrderingRel j i, (1 - fs j) :=
  fs.toBumpCovering.exists_finset_toPartitionOfUnity_eventuallyEq i x
#align smooth_bump_covering.exists_finset_to_smooth_partition_of_unity_eventually_eq SmoothBumpCovering.exists_finset_toSmoothPartitionOfUnity_eventuallyEq
-/

#print SmoothBumpCovering.toSmoothPartitionOfUnity_zero_of_zero /-
theorem toSmoothPartitionOfUnity_zero_of_zero {i : ι} {x : M} (h : fs i x = 0) :
    fs.toSmoothPartitionOfUnity i x = 0 :=
  fs.toBumpCovering.toPartitionOfUnity_zero_of_zero h
#align smooth_bump_covering.to_smooth_partition_of_unity_zero_of_zero SmoothBumpCovering.toSmoothPartitionOfUnity_zero_of_zero
-/

#print SmoothBumpCovering.support_toSmoothPartitionOfUnity_subset /-
theorem support_toSmoothPartitionOfUnity_subset (i : ι) :
    support (fs.toSmoothPartitionOfUnity i) ⊆ support (fs i) :=
  fs.toBumpCovering.support_toPartitionOfUnity_subset i
#align smooth_bump_covering.support_to_smooth_partition_of_unity_subset SmoothBumpCovering.support_toSmoothPartitionOfUnity_subset
-/

#print SmoothBumpCovering.IsSubordinate.toSmoothPartitionOfUnity /-
theorem IsSubordinate.toSmoothPartitionOfUnity {f : SmoothBumpCovering ι I M s} {U : M → Set M}
    (h : f.IsSubordinate U) : f.toSmoothPartitionOfUnity.IsSubordinate fun i => U (f.c i) :=
  h.toBumpCovering.toPartitionOfUnity
#align smooth_bump_covering.is_subordinate.to_smooth_partition_of_unity SmoothBumpCovering.IsSubordinate.toSmoothPartitionOfUnity
-/

#print SmoothBumpCovering.sum_toSmoothPartitionOfUnity_eq /-
theorem sum_toSmoothPartitionOfUnity_eq (x : M) :
    ∑ᶠ i, fs.toSmoothPartitionOfUnity i x = 1 - ∏ᶠ i, (1 - fs i x) :=
  fs.toBumpCovering.sum_toPartitionOfUnity_eq x
#align smooth_bump_covering.sum_to_smooth_partition_of_unity_eq SmoothBumpCovering.sum_toSmoothPartitionOfUnity_eq
-/

end SmoothBumpCovering

variable (I)

#print exists_smooth_zero_one_of_closed /-
/-- Given two disjoint closed sets in a Hausdorff σ-compact finite dimensional manifold, there
exists an infinitely smooth function that is equal to `0` on one of them and is equal to one on the
other. -/
theorem exists_smooth_zero_one_of_closed [T2Space M] [SigmaCompactSpace M] {s t : Set M}
    (hs : IsClosed s) (ht : IsClosed t) (hd : Disjoint s t) :
    ∃ f : C^∞⟮I, M; 𝓘(ℝ), ℝ⟯, EqOn f 0 s ∧ EqOn f 1 t ∧ ∀ x, f x ∈ Icc (0 : ℝ) 1 :=
  by
  have : ∀ x ∈ t, sᶜ ∈ 𝓝 x := fun x hx => hs.is_open_compl.mem_nhds (disjoint_right.1 hd hx)
  rcases SmoothBumpCovering.exists_isSubordinate I ht this with ⟨ι, f, hf⟩
  set g := f.to_smooth_partition_of_unity
  refine'
    ⟨⟨_, g.smooth_sum⟩, fun x hx => _, fun x => g.sum_eq_one, fun x =>
      ⟨g.sum_nonneg x, g.sum_le_one x⟩⟩
  suffices ∀ i, g i x = 0 by simp only [this, ContMDiffMap.coeFn_mk, finsum_zero, Pi.zero_apply]
  refine' fun i => f.to_smooth_partition_of_unity_zero_of_zero _
  exact nmem_support.1 (subset_compl_comm.1 (hf.support_subset i) hx)
#align exists_smooth_zero_one_of_closed exists_smooth_zero_one_of_closed
-/

namespace SmoothPartitionOfUnity

#print SmoothPartitionOfUnity.single /-
/-- A `smooth_partition_of_unity` that consists of a single function, uniformly equal to one,
defined as an example for `inhabited` instance. -/
def single (i : ι) (s : Set M) : SmoothPartitionOfUnity ι I M s :=
  (BumpCovering.single i s).toSmoothPartitionOfUnity fun j =>
    by
    rcases eq_or_ne j i with (rfl | h)
    · simp only [smooth_one, ContinuousMap.coe_one, BumpCovering.coe_single, Pi.single_eq_same]
    · simp only [smooth_zero, BumpCovering.coe_single, Pi.single_eq_of_ne h, ContinuousMap.coe_zero]
#align smooth_partition_of_unity.single SmoothPartitionOfUnity.single
-/

instance [Inhabited ι] (s : Set M) : Inhabited (SmoothPartitionOfUnity ι I M s) :=
  ⟨single I default s⟩

variable [T2Space M] [SigmaCompactSpace M]

#print SmoothPartitionOfUnity.exists_isSubordinate /-
/-- If `X` is a paracompact normal topological space and `U` is an open covering of a closed set
`s`, then there exists a `bump_covering ι X s` that is subordinate to `U`. -/
theorem exists_isSubordinate {s : Set M} (hs : IsClosed s) (U : ι → Set M) (ho : ∀ i, IsOpen (U i))
    (hU : s ⊆ ⋃ i, U i) : ∃ f : SmoothPartitionOfUnity ι I M s, f.IsSubordinate U :=
  by
  haveI : LocallyCompactSpace H := I.locally_compact
  haveI : LocallyCompactSpace M := ChartedSpace.locallyCompact H M
  haveI : NormalSpace M := normal_of_paracompact_t2
  rcases BumpCovering.exists_isSubordinate_of_prop (Smooth I 𝓘(ℝ)) _ hs U ho hU with ⟨f, hf, hfU⟩
  · exact ⟨f.to_smooth_partition_of_unity hf, hfU.to_smooth_partition_of_unity hf⟩
  · intro s t hs ht hd
    rcases exists_smooth_zero_one_of_closed I hs ht hd with ⟨f, hf⟩
    exact ⟨f, f.smooth, hf⟩
#align smooth_partition_of_unity.exists_is_subordinate SmoothPartitionOfUnity.exists_isSubordinate
-/

end SmoothPartitionOfUnity

variable [SigmaCompactSpace M] [T2Space M] {t : M → Set F} {n : ℕ∞}

#print exists_cont_mdiff_forall_mem_convex_of_local /-
/-- Let `M` be a σ-compact Hausdorff finite dimensional topological manifold. Let `t : M → set F`
be a family of convex sets. Suppose that for each point `x : M` there exists a neighborhood
`U ∈ 𝓝 x` and a function `g : M → F` such that `g` is $C^n$ smooth on `U` and `g y ∈ t y` for all
`y ∈ U`. Then there exists a $C^n$ smooth function `g : C^∞⟮I, M; 𝓘(ℝ, F), F⟯` such that `g x ∈ t x`
for all `x`. See also `exists_smooth_forall_mem_convex_of_local` and
`exists_smooth_forall_mem_convex_of_local_const`. -/
theorem exists_cont_mdiff_forall_mem_convex_of_local (ht : ∀ x, Convex ℝ (t x))
    (Hloc : ∀ x : M, ∃ U ∈ 𝓝 x, ∃ g : M → F, ContMDiffOn I 𝓘(ℝ, F) n g U ∧ ∀ y ∈ U, g y ∈ t y) :
    ∃ g : C^n⟮I, M; 𝓘(ℝ, F), F⟯, ∀ x, g x ∈ t x :=
  by
  choose U hU g hgs hgt using Hloc
  obtain ⟨f, hf⟩ :=
    SmoothPartitionOfUnity.exists_isSubordinate I isClosed_univ (fun x => interior (U x))
      (fun x => isOpen_interior) fun x hx => mem_Union.2 ⟨x, mem_interior_iff_mem_nhds.2 (hU x)⟩
  refine'
    ⟨⟨fun x => ∑ᶠ i, f i x • g i x,
        hf.cont_mdiff_finsum_smul (fun i => isOpen_interior) fun i => (hgs i).mono interior_subset⟩,
      fun x => f.finsum_smul_mem_convex (mem_univ x) (fun i hi => hgt _ _ _) (ht _)⟩
  exact interior_subset (hf _ <| subset_closure hi)
#align exists_cont_mdiff_forall_mem_convex_of_local exists_cont_mdiff_forall_mem_convex_of_local
-/

#print exists_smooth_forall_mem_convex_of_local /-
/-- Let `M` be a σ-compact Hausdorff finite dimensional topological manifold. Let `t : M → set F`
be a family of convex sets. Suppose that for each point `x : M` there exists a neighborhood
`U ∈ 𝓝 x` and a function `g : M → F` such that `g` is smooth on `U` and `g y ∈ t y` for all `y ∈ U`.
Then there exists a smooth function `g : C^∞⟮I, M; 𝓘(ℝ, F), F⟯` such that `g x ∈ t x` for all `x`.
See also `exists_cont_mdiff_forall_mem_convex_of_local` and
`exists_smooth_forall_mem_convex_of_local_const`. -/
theorem exists_smooth_forall_mem_convex_of_local (ht : ∀ x, Convex ℝ (t x))
    (Hloc : ∀ x : M, ∃ U ∈ 𝓝 x, ∃ g : M → F, SmoothOn I 𝓘(ℝ, F) g U ∧ ∀ y ∈ U, g y ∈ t y) :
    ∃ g : C^∞⟮I, M; 𝓘(ℝ, F), F⟯, ∀ x, g x ∈ t x :=
  exists_cont_mdiff_forall_mem_convex_of_local I ht Hloc
#align exists_smooth_forall_mem_convex_of_local exists_smooth_forall_mem_convex_of_local
-/

#print exists_smooth_forall_mem_convex_of_local_const /-
/-- Let `M` be a σ-compact Hausdorff finite dimensional topological manifold. Let `t : M → set F` be
a family of convex sets. Suppose that for each point `x : M` there exists a vector `c : F` such that
for all `y` in a neighborhood of `x` we have `c ∈ t y`. Then there exists a smooth function
`g : C^∞⟮I, M; 𝓘(ℝ, F), F⟯` such that `g x ∈ t x` for all `x`.  See also
`exists_cont_mdiff_forall_mem_convex_of_local` and `exists_smooth_forall_mem_convex_of_local`. -/
theorem exists_smooth_forall_mem_convex_of_local_const (ht : ∀ x, Convex ℝ (t x))
    (Hloc : ∀ x : M, ∃ c : F, ∀ᶠ y in 𝓝 x, c ∈ t y) : ∃ g : C^∞⟮I, M; 𝓘(ℝ, F), F⟯, ∀ x, g x ∈ t x :=
  exists_smooth_forall_mem_convex_of_local I ht fun x =>
    let ⟨c, hc⟩ := Hloc x
    ⟨_, hc, fun _ => c, smoothOn_const, fun y => id⟩
#align exists_smooth_forall_mem_convex_of_local_const exists_smooth_forall_mem_convex_of_local_const
-/

#print Emetric.exists_smooth_forall_closedBall_subset /-
/-- Let `M` be a smooth σ-compact manifold with extended distance. Let `K : ι → set M` be a locally
finite family of closed sets, let `U : ι → set M` be a family of open sets such that `K i ⊆ U i` for
all `i`. Then there exists a positive smooth function `δ : M → ℝ≥0` such that for any `i` and
`x ∈ K i`, we have `emetric.closed_ball x (δ x) ⊆ U i`. -/
theorem Emetric.exists_smooth_forall_closedBall_subset {M} [EMetricSpace M] [ChartedSpace H M]
    [SmoothManifoldWithCorners I M] [SigmaCompactSpace M] {K : ι → Set M} {U : ι → Set M}
    (hK : ∀ i, IsClosed (K i)) (hU : ∀ i, IsOpen (U i)) (hKU : ∀ i, K i ⊆ U i)
    (hfin : LocallyFinite K) :
    ∃ δ : C^∞⟮I, M; 𝓘(ℝ, ℝ), ℝ⟯,
      (∀ x, 0 < δ x) ∧ ∀ (i), ∀ x ∈ K i, EMetric.closedBall x (ENNReal.ofReal (δ x)) ⊆ U i :=
  by
  simpa only [mem_inter_iff, forall_and, mem_preimage, mem_Inter, @forall_swap ι M] using
    exists_smooth_forall_mem_convex_of_local_const I EMetric.exists_forall_closedBall_subset_aux₂
      (EMetric.exists_forall_closedBall_subset_aux₁ hK hU hKU hfin)
#align emetric.exists_smooth_forall_closed_ball_subset Emetric.exists_smooth_forall_closedBall_subset
-/

#print Metric.exists_smooth_forall_closedBall_subset /-
/-- Let `M` be a smooth σ-compact manifold with a metric. Let `K : ι → set M` be a locally finite
family of closed sets, let `U : ι → set M` be a family of open sets such that `K i ⊆ U i` for all
`i`. Then there exists a positive smooth function `δ : M → ℝ≥0` such that for any `i` and `x ∈ K i`,
we have `metric.closed_ball x (δ x) ⊆ U i`. -/
theorem Metric.exists_smooth_forall_closedBall_subset {M} [MetricSpace M] [ChartedSpace H M]
    [SmoothManifoldWithCorners I M] [SigmaCompactSpace M] {K : ι → Set M} {U : ι → Set M}
    (hK : ∀ i, IsClosed (K i)) (hU : ∀ i, IsOpen (U i)) (hKU : ∀ i, K i ⊆ U i)
    (hfin : LocallyFinite K) :
    ∃ δ : C^∞⟮I, M; 𝓘(ℝ, ℝ), ℝ⟯,
      (∀ x, 0 < δ x) ∧ ∀ (i), ∀ x ∈ K i, Metric.closedBall x (δ x) ⊆ U i :=
  by
  rcases Emetric.exists_smooth_forall_closedBall_subset I hK hU hKU hfin with ⟨δ, hδ0, hδ⟩
  refine' ⟨δ, hδ0, fun i x hx => _⟩
  rw [← Metric.emetric_closedBall (hδ0 _).le]
  exact hδ i x hx
#align metric.exists_smooth_forall_closed_ball_subset Metric.exists_smooth_forall_closedBall_subset
-/

