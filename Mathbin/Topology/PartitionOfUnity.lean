/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module topology.partition_of_unity
! leanprover-community/mathlib commit a2706b55e8d7f7e9b1f93143f0b88f2e34a11eea
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Finprod
import Mathbin.SetTheory.Ordinal.Basic
import Mathbin.Topology.ContinuousFunction.Algebra
import Mathbin.Topology.Paracompact
import Mathbin.Topology.ShrinkingLemma
import Mathbin.Topology.UrysohnsLemma

/-!
# Continuous partition of unity

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `partition_of_unity (ι X : Type*) [topological_space X] (s : set X := univ)`
to be a continuous partition of unity on `s` indexed by `ι`. More precisely, `f : partition_of_unity
ι X s` is a collection of continuous functions `f i : C(X, ℝ)`, `i : ι`, such that

* the supports of `f i` form a locally finite family of sets;
* each `f i` is nonnegative;
* `∑ᶠ i, f i x = 1` for all `x ∈ s`;
* `∑ᶠ i, f i x ≤ 1` for all `x : X`.

In the case `s = univ` the last assumption follows from the previous one but it is convenient to
have this assumption in the case `s ≠ univ`.

We also define a bump function covering,
`bump_covering (ι X : Type*) [topological_space X] (s : set X := univ)`, to be a collection of
functions `f i : C(X, ℝ)`, `i : ι`, such that

* the supports of `f i` form a locally finite family of sets;
* each `f i` is nonnegative;
* for each `x ∈ s` there exists `i : ι` such that `f i y = 1` in a neighborhood of `x`.

The term is motivated by the smooth case.

If `f` is a bump function covering indexed by a linearly ordered type, then
`g i x = f i x * ∏ᶠ j < i, (1 - f j x)` is a partition of unity, see
`bump_covering.to_partition_of_unity`. Note that only finitely many terms `1 - f j x` are not equal
to one, so this product is well-defined.

Note that `g i x = ∏ᶠ j ≤ i, (1 - f j x) - ∏ᶠ j < i, (1 - f j x)`, so most terms in the sum
`∑ᶠ i, g i x` cancel, and we get `∑ᶠ i, g i x = 1 - ∏ᶠ i, (1 - f i x)`, and the latter product
equals zero because one of `f i x` is equal to one.

We say that a partition of unity or a bump function covering `f` is *subordinate* to a family of
sets `U i`, `i : ι`, if the closure of the support of each `f i` is included in `U i`. We use
Urysohn's Lemma to prove that a locally finite open covering of a normal topological space admits a
subordinate bump function covering (hence, a subordinate partition of unity), see
`bump_covering.exists_is_subordinate_of_locally_finite`. If `X` is a paracompact space, then any
open covering admits a locally finite refinement, hence it admits a subordinate bump function
covering and a subordinate partition of unity, see `bump_covering.exists_is_subordinate`.

We also provide two slightly more general versions of these lemmas,
`bump_covering.exists_is_subordinate_of_locally_finite_of_prop` and
`bump_covering.exists_is_subordinate_of_prop`, to be used later in the construction of a smooth
partition of unity.

## Implementation notes

Most (if not all) books only define a partition of unity of the whole space. However, quite a few
proofs only deal with `f i` such that `tsupport (f i)` meets a specific closed subset, and
it is easier to formalize these proofs if we don't have other functions right away.

We use `well_ordering_rel j i` instead of `j < i` in the definition of
`bump_covering.to_partition_of_unity` to avoid a `[linear_order ι]` assumption. While
`well_ordering_rel j i` is a well order, not only a strict linear order, we never use this property.

## Tags

partition of unity, bump function, Urysohn's lemma, normal space, paracompact space
-/


universe u v

open Function Set Filter

open scoped BigOperators Topology Classical

noncomputable section

#print PartitionOfUnity /-
/-- A continuous partition of unity on a set `s : set X` is a collection of continuous functions
`f i` such that

* the supports of `f i` form a locally finite family of sets, i.e., for every point `x : X` there
  exists a neighborhood `U ∋ x` such that all but finitely many functions `f i` are zero on `U`;
* the functions `f i` are nonnegative;
* the sum `∑ᶠ i, f i x` is equal to one for every `x ∈ s` and is less than or equal to one
  otherwise.

If `X` is a normal paracompact space, then `partition_of_unity.exists_is_subordinate` guarantees
that for every open covering `U : set (set X)` of `s` there exists a partition of unity that is
subordinate to `U`.
-/
structure PartitionOfUnity (ι X : Type _) [TopologicalSpace X] (s : Set X := univ) where
  toFun : ι → C(X, ℝ)
  locally_finite' : LocallyFinite fun i => support (to_fun i)
  nonneg' : 0 ≤ to_fun
  sum_eq_one' : ∀ x ∈ s, ∑ᶠ i, to_fun i x = 1
  sum_le_one' : ∀ x, ∑ᶠ i, to_fun i x ≤ 1
#align partition_of_unity PartitionOfUnity
-/

#print BumpCovering /-
/-- A `bump_covering ι X s` is an indexed family of functions `f i`, `i : ι`, such that

* the supports of `f i` form a locally finite family of sets, i.e., for every point `x : X` there
  exists a neighborhood `U ∋ x` such that all but finitely many functions `f i` are zero on `U`;
* for all `i`, `x` we have `0 ≤ f i x ≤ 1`;
* each point `x ∈ s` belongs to the interior of `{x | f i x = 1}` for some `i`.

One of the main use cases for a `bump_covering` is to define a `partition_of_unity`, see
`bump_covering.to_partition_of_unity`, but some proofs can directly use a `bump_covering` instead of
a `partition_of_unity`.

If `X` is a normal paracompact space, then `bump_covering.exists_is_subordinate` guarantees that for
every open covering `U : set (set X)` of `s` there exists a `bump_covering` of `s` that is
subordinate to `U`.
-/
structure BumpCovering (ι X : Type _) [TopologicalSpace X] (s : Set X := univ) where
  toFun : ι → C(X, ℝ)
  locally_finite' : LocallyFinite fun i => support (to_fun i)
  nonneg' : 0 ≤ to_fun
  le_one' : to_fun ≤ 1
  eventuallyEq_one' : ∀ x ∈ s, ∃ i, to_fun i =ᶠ[𝓝 x] 1
#align bump_covering BumpCovering
-/

variable {ι : Type u} {X : Type v} [TopologicalSpace X]

namespace PartitionOfUnity

variable {E : Type _} [AddCommMonoid E] [SMulWithZero ℝ E] [TopologicalSpace E] [ContinuousSMul ℝ E]
  {s : Set X} (f : PartitionOfUnity ι X s)

instance : CoeFun (PartitionOfUnity ι X s) fun _ => ι → C(X, ℝ) :=
  ⟨toFun⟩

#print PartitionOfUnity.locallyFinite /-
protected theorem locallyFinite : LocallyFinite fun i => support (f i) :=
  f.locally_finite'
#align partition_of_unity.locally_finite PartitionOfUnity.locallyFinite
-/

#print PartitionOfUnity.locallyFinite_tsupport /-
theorem locallyFinite_tsupport : LocallyFinite fun i => tsupport (f i) :=
  f.LocallyFinite.closure
#align partition_of_unity.locally_finite_tsupport PartitionOfUnity.locallyFinite_tsupport
-/

#print PartitionOfUnity.nonneg /-
theorem nonneg (i : ι) (x : X) : 0 ≤ f i x :=
  f.nonneg' i x
#align partition_of_unity.nonneg PartitionOfUnity.nonneg
-/

#print PartitionOfUnity.sum_eq_one /-
theorem sum_eq_one {x : X} (hx : x ∈ s) : ∑ᶠ i, f i x = 1 :=
  f.sum_eq_one' x hx
#align partition_of_unity.sum_eq_one PartitionOfUnity.sum_eq_one
-/

#print PartitionOfUnity.exists_pos /-
/-- If `f` is a partition of unity on `s`, then for every `x ∈ s` there exists an index `i` such
that `0 < f i x`. -/
theorem exists_pos {x : X} (hx : x ∈ s) : ∃ i, 0 < f i x :=
  by
  have H := f.sum_eq_one hx
  contrapose! H
  simpa only [fun i => (H i).antisymm (f.nonneg i x), finsum_zero] using zero_ne_one
#align partition_of_unity.exists_pos PartitionOfUnity.exists_pos
-/

#print PartitionOfUnity.sum_le_one /-
theorem sum_le_one (x : X) : ∑ᶠ i, f i x ≤ 1 :=
  f.sum_le_one' x
#align partition_of_unity.sum_le_one PartitionOfUnity.sum_le_one
-/

#print PartitionOfUnity.sum_nonneg /-
theorem sum_nonneg (x : X) : 0 ≤ ∑ᶠ i, f i x :=
  finsum_nonneg fun i => f.NonNeg i x
#align partition_of_unity.sum_nonneg PartitionOfUnity.sum_nonneg
-/

#print PartitionOfUnity.le_one /-
theorem le_one (i : ι) (x : X) : f i x ≤ 1 :=
  (single_le_finsum i (f.LocallyFinite.point_finite x) fun j => f.NonNeg j x).trans (f.sum_le_one x)
#align partition_of_unity.le_one PartitionOfUnity.le_one
-/

#print PartitionOfUnity.continuous_smul /-
/-- If `f` is a partition of unity on `s : set X` and `g : X → E` is continuous at every point of
the topological support of some `f i`, then `λ x, f i x • g x` is continuous on the whole space. -/
theorem continuous_smul {g : X → E} {i : ι} (hg : ∀ x ∈ tsupport (f i), ContinuousAt g x) :
    Continuous fun x => f i x • g x :=
  continuous_of_tsupport fun x hx =>
    ((f i).ContinuousAt x).smul <| hg x <| tsupport_smul_subset_left _ _ hx
#align partition_of_unity.continuous_smul PartitionOfUnity.continuous_smul
-/

#print PartitionOfUnity.continuous_finsum_smul /-
/-- If `f` is a partition of unity on a set `s : set X` and `g : ι → X → E` is a family of functions
such that each `g i` is continuous at every point of the topological support of `f i`, then the sum
`λ x, ∑ᶠ i, f i x • g i x` is continuous on the whole space. -/
theorem continuous_finsum_smul [ContinuousAdd E] {g : ι → X → E}
    (hg : ∀ (i), ∀ x ∈ tsupport (f i), ContinuousAt (g i) x) :
    Continuous fun x => ∑ᶠ i, f i x • g i x :=
  (continuous_finsum fun i => f.continuous_smul (hg i)) <|
    f.LocallyFinite.Subset fun i => support_smul_subset_left _ _
#align partition_of_unity.continuous_finsum_smul PartitionOfUnity.continuous_finsum_smul
-/

#print PartitionOfUnity.IsSubordinate /-
/-- A partition of unity `f i` is subordinate to a family of sets `U i` indexed by the same type if
for each `i` the closure of the support of `f i` is a subset of `U i`. -/
def IsSubordinate (U : ι → Set X) : Prop :=
  ∀ i, tsupport (f i) ⊆ U i
#align partition_of_unity.is_subordinate PartitionOfUnity.IsSubordinate
-/

variable {f}

#print PartitionOfUnity.exists_finset_nhd_support_subset /-
theorem exists_finset_nhd_support_subset {U : ι → Set X} (hso : f.IsSubordinate U)
    (ho : ∀ i, IsOpen (U i)) (x : X) :
    ∃ (is : Finset ι) (n : Set X) (hn₁ : n ∈ 𝓝 x) (hn₂ : n ⊆ ⋂ i ∈ is, U i),
      ∀ z ∈ n, (support fun i => f i z) ⊆ is :=
  f.LocallyFinite.exists_finset_nhd_support_subset hso ho x
#align partition_of_unity.exists_finset_nhd_support_subset PartitionOfUnity.exists_finset_nhd_support_subset
-/

#print PartitionOfUnity.IsSubordinate.continuous_finsum_smul /-
/-- If `f` is a partition of unity that is subordinate to a family of open sets `U i` and
`g : ι → X → E` is a family of functions such that each `g i` is continuous on `U i`, then the sum
`λ x, ∑ᶠ i, f i x • g i x` is a continuous function. -/
theorem IsSubordinate.continuous_finsum_smul [ContinuousAdd E] {U : ι → Set X}
    (ho : ∀ i, IsOpen (U i)) (hf : f.IsSubordinate U) {g : ι → X → E}
    (hg : ∀ i, ContinuousOn (g i) (U i)) : Continuous fun x => ∑ᶠ i, f i x • g i x :=
  f.continuous_finsum_smul fun i x hx => (hg i).ContinuousAt <| (ho i).mem_nhds <| hf i hx
#align partition_of_unity.is_subordinate.continuous_finsum_smul PartitionOfUnity.IsSubordinate.continuous_finsum_smul
-/

end PartitionOfUnity

namespace BumpCovering

variable {s : Set X} (f : BumpCovering ι X s)

instance : CoeFun (BumpCovering ι X s) fun _ => ι → C(X, ℝ) :=
  ⟨toFun⟩

#print BumpCovering.locallyFinite /-
protected theorem locallyFinite : LocallyFinite fun i => support (f i) :=
  f.locally_finite'
#align bump_covering.locally_finite BumpCovering.locallyFinite
-/

#print BumpCovering.locallyFinite_tsupport /-
theorem locallyFinite_tsupport : LocallyFinite fun i => tsupport (f i) :=
  f.LocallyFinite.closure
#align bump_covering.locally_finite_tsupport BumpCovering.locallyFinite_tsupport
-/

#print BumpCovering.point_finite /-
protected theorem point_finite (x : X) : {i | f i x ≠ 0}.Finite :=
  f.LocallyFinite.point_finite x
#align bump_covering.point_finite BumpCovering.point_finite
-/

#print BumpCovering.nonneg /-
theorem nonneg (i : ι) (x : X) : 0 ≤ f i x :=
  f.nonneg' i x
#align bump_covering.nonneg BumpCovering.nonneg
-/

#print BumpCovering.le_one /-
theorem le_one (i : ι) (x : X) : f i x ≤ 1 :=
  f.le_one' i x
#align bump_covering.le_one BumpCovering.le_one
-/

#print BumpCovering.single /-
/-- A `bump_covering` that consists of a single function, uniformly equal to one, defined as an
example for `inhabited` instance. -/
protected def single (i : ι) (s : Set X) : BumpCovering ι X s
    where
  toFun := Pi.single i 1
  locally_finite' x := by
    refine' ⟨univ, univ_mem, (finite_singleton i).Subset _⟩
    rintro j ⟨x, hx, -⟩
    contrapose! hx
    rw [mem_singleton_iff] at hx 
    simp [hx]
  nonneg' := le_update_iff.2 ⟨fun x => zero_le_one, fun _ _ => le_rfl⟩
  le_one' := update_le_iff.2 ⟨le_rfl, fun _ _ _ => zero_le_one⟩
  eventuallyEq_one' x _ := ⟨i, by simp⟩
#align bump_covering.single BumpCovering.single
-/

#print BumpCovering.coe_single /-
@[simp]
theorem coe_single (i : ι) (s : Set X) : ⇑(BumpCovering.single i s) = Pi.single i 1 :=
  rfl
#align bump_covering.coe_single BumpCovering.coe_single
-/

instance [Inhabited ι] : Inhabited (BumpCovering ι X s) :=
  ⟨BumpCovering.single default s⟩

#print BumpCovering.IsSubordinate /-
/-- A collection of bump functions `f i` is subordinate to a family of sets `U i` indexed by the
same type if for each `i` the closure of the support of `f i` is a subset of `U i`. -/
def IsSubordinate (f : BumpCovering ι X s) (U : ι → Set X) : Prop :=
  ∀ i, tsupport (f i) ⊆ U i
#align bump_covering.is_subordinate BumpCovering.IsSubordinate
-/

#print BumpCovering.IsSubordinate.mono /-
theorem IsSubordinate.mono {f : BumpCovering ι X s} {U V : ι → Set X} (hU : f.IsSubordinate U)
    (hV : ∀ i, U i ⊆ V i) : f.IsSubordinate V := fun i => Subset.trans (hU i) (hV i)
#align bump_covering.is_subordinate.mono BumpCovering.IsSubordinate.mono
-/

#print BumpCovering.exists_isSubordinate_of_locallyFinite_of_prop /-
/-- If `X` is a normal topological space and `U i`, `i : ι`, is a locally finite open covering of a
closed set `s`, then there exists a `bump_covering ι X s` that is subordinate to `U`. If `X` is a
paracompact space, then the assumption `hf : locally_finite U` can be omitted, see
`bump_covering.exists_is_subordinate`. This version assumes that `p : (X → ℝ) → Prop` is a predicate
that satisfies Urysohn's lemma, and provides a `bump_covering` such that each function of the
covering satisfies `p`. -/
theorem exists_isSubordinate_of_locallyFinite_of_prop [NormalSpace X] (p : (X → ℝ) → Prop)
    (h01 :
      ∀ s t,
        IsClosed s →
          IsClosed t →
            Disjoint s t → ∃ f : C(X, ℝ), p f ∧ EqOn f 0 s ∧ EqOn f 1 t ∧ ∀ x, f x ∈ Icc (0 : ℝ) 1)
    (hs : IsClosed s) (U : ι → Set X) (ho : ∀ i, IsOpen (U i)) (hf : LocallyFinite U)
    (hU : s ⊆ ⋃ i, U i) : ∃ f : BumpCovering ι X s, (∀ i, p (f i)) ∧ f.IsSubordinate U :=
  by
  rcases exists_subset_iUnion_closure_subset hs ho (fun x _ => hf.point_finite x) hU with
    ⟨V, hsV, hVo, hVU⟩
  have hVU' : ∀ i, V i ⊆ U i := fun i => subset.trans subset_closure (hVU i)
  rcases exists_subset_iUnion_closure_subset hs hVo (fun x _ => (hf.subset hVU').point_finite x)
      hsV with
    ⟨W, hsW, hWo, hWV⟩
  choose f hfp hf0 hf1 hf01 using fun i =>
    h01 _ _ (isClosed_compl_iff.2 <| hVo i) isClosed_closure
      (disjoint_right.2 fun x hx => Classical.not_not.2 (hWV i hx))
  have hsupp : ∀ i, support (f i) ⊆ V i := fun i => support_subset_iff'.2 (hf0 i)
  refine'
    ⟨⟨f, hf.subset fun i => subset.trans (hsupp i) (hVU' i), fun i x => (hf01 i x).1, fun i x =>
        (hf01 i x).2, fun x hx => _⟩,
      hfp, fun i => subset.trans (closure_mono (hsupp i)) (hVU i)⟩
  rcases mem_Union.1 (hsW hx) with ⟨i, hi⟩
  exact ⟨i, ((hf1 i).mono subset_closure).eventuallyEq_of_mem ((hWo i).mem_nhds hi)⟩
#align bump_covering.exists_is_subordinate_of_locally_finite_of_prop BumpCovering.exists_isSubordinate_of_locallyFinite_of_prop
-/

#print BumpCovering.exists_isSubordinate_of_locallyFinite /-
/-- If `X` is a normal topological space and `U i`, `i : ι`, is a locally finite open covering of a
closed set `s`, then there exists a `bump_covering ι X s` that is subordinate to `U`. If `X` is a
paracompact space, then the assumption `hf : locally_finite U` can be omitted, see
`bump_covering.exists_is_subordinate`. -/
theorem exists_isSubordinate_of_locallyFinite [NormalSpace X] (hs : IsClosed s) (U : ι → Set X)
    (ho : ∀ i, IsOpen (U i)) (hf : LocallyFinite U) (hU : s ⊆ ⋃ i, U i) :
    ∃ f : BumpCovering ι X s, f.IsSubordinate U :=
  let ⟨f, _, hfU⟩ :=
    exists_isSubordinate_of_locallyFinite_of_prop (fun _ => True)
      (fun s t hs ht hd =>
        (exists_continuous_zero_one_of_closed hs ht hd).imp fun f hf => ⟨trivial, hf⟩)
      hs U ho hf hU
  ⟨f, hfU⟩
#align bump_covering.exists_is_subordinate_of_locally_finite BumpCovering.exists_isSubordinate_of_locallyFinite
-/

#print BumpCovering.exists_isSubordinate_of_prop /-
/-- If `X` is a paracompact normal topological space and `U` is an open covering of a closed set
`s`, then there exists a `bump_covering ι X s` that is subordinate to `U`. This version assumes that
`p : (X → ℝ) → Prop` is a predicate that satisfies Urysohn's lemma, and provides a
`bump_covering` such that each function of the covering satisfies `p`. -/
theorem exists_isSubordinate_of_prop [NormalSpace X] [ParacompactSpace X] (p : (X → ℝ) → Prop)
    (h01 :
      ∀ s t,
        IsClosed s →
          IsClosed t →
            Disjoint s t → ∃ f : C(X, ℝ), p f ∧ EqOn f 0 s ∧ EqOn f 1 t ∧ ∀ x, f x ∈ Icc (0 : ℝ) 1)
    (hs : IsClosed s) (U : ι → Set X) (ho : ∀ i, IsOpen (U i)) (hU : s ⊆ ⋃ i, U i) :
    ∃ f : BumpCovering ι X s, (∀ i, p (f i)) ∧ f.IsSubordinate U :=
  by
  rcases precise_refinement_set hs _ ho hU with ⟨V, hVo, hsV, hVf, hVU⟩
  rcases exists_is_subordinate_of_locally_finite_of_prop p h01 hs V hVo hVf hsV with ⟨f, hfp, hf⟩
  exact ⟨f, hfp, hf.mono hVU⟩
#align bump_covering.exists_is_subordinate_of_prop BumpCovering.exists_isSubordinate_of_prop
-/

#print BumpCovering.exists_isSubordinate /-
/-- If `X` is a paracompact normal topological space and `U` is an open covering of a closed set
`s`, then there exists a `bump_covering ι X s` that is subordinate to `U`. -/
theorem exists_isSubordinate [NormalSpace X] [ParacompactSpace X] (hs : IsClosed s) (U : ι → Set X)
    (ho : ∀ i, IsOpen (U i)) (hU : s ⊆ ⋃ i, U i) : ∃ f : BumpCovering ι X s, f.IsSubordinate U :=
  by
  rcases precise_refinement_set hs _ ho hU with ⟨V, hVo, hsV, hVf, hVU⟩
  rcases exists_is_subordinate_of_locally_finite hs V hVo hVf hsV with ⟨f, hf⟩
  exact ⟨f, hf.mono hVU⟩
#align bump_covering.exists_is_subordinate BumpCovering.exists_isSubordinate
-/

#print BumpCovering.ind /-
/-- Index of a bump function such that `fs i =ᶠ[𝓝 x] 1`. -/
def ind (x : X) (hx : x ∈ s) : ι :=
  (f.eventuallyEq_one' x hx).some
#align bump_covering.ind BumpCovering.ind
-/

#print BumpCovering.eventuallyEq_one /-
theorem eventuallyEq_one (x : X) (hx : x ∈ s) : f (f.ind x hx) =ᶠ[𝓝 x] 1 :=
  (f.eventuallyEq_one' x hx).choose_spec
#align bump_covering.eventually_eq_one BumpCovering.eventuallyEq_one
-/

#print BumpCovering.ind_apply /-
theorem ind_apply (x : X) (hx : x ∈ s) : f (f.ind x hx) x = 1 :=
  (f.eventuallyEq_one x hx).eq_of_nhds
#align bump_covering.ind_apply BumpCovering.ind_apply
-/

#print BumpCovering.toPOUFun /-
/-- Partition of unity defined by a `bump_covering`. We use this auxiliary definition to prove some
properties of the new family of functions before bundling it into a `partition_of_unity`. Do not use
this definition, use `bump_function.to_partition_of_unity` instead.

The partition of unity is given by the formula `g i x = f i x * ∏ᶠ j < i, (1 - f j x)`. In other
words, `g i x = ∏ᶠ j < i, (1 - f j x) - ∏ᶠ j ≤ i, (1 - f j x)`, so
`∑ᶠ i, g i x = 1 - ∏ᶠ j, (1 - f j x)`. If `x ∈ s`, then one of `f j x` equals one, hence the product
of `1 - f j x` vanishes, and `∑ᶠ i, g i x = 1`.

In order to avoid an assumption `linear_order ι`, we use `well_ordering_rel` instead of `(<)`. -/
def toPOUFun (i : ι) (x : X) : ℝ :=
  f i x * ∏ᶠ (j) (hj : WellOrderingRel j i), (1 - f j x)
#align bump_covering.to_pou_fun BumpCovering.toPOUFun
-/

#print BumpCovering.toPOUFun_zero_of_zero /-
theorem toPOUFun_zero_of_zero {i : ι} {x : X} (h : f i x = 0) : f.toPOUFun i x = 0 := by
  rw [to_pou_fun, h, MulZeroClass.zero_mul]
#align bump_covering.to_pou_fun_zero_of_zero BumpCovering.toPOUFun_zero_of_zero
-/

#print BumpCovering.support_toPOUFun_subset /-
theorem support_toPOUFun_subset (i : ι) : support (f.toPOUFun i) ⊆ support (f i) := fun x =>
  mt <| f.toPOUFun_zero_of_zero
#align bump_covering.support_to_pou_fun_subset BumpCovering.support_toPOUFun_subset
-/

#print BumpCovering.toPOUFun_eq_mul_prod /-
theorem toPOUFun_eq_mul_prod (i : ι) (x : X) (t : Finset ι)
    (ht : ∀ j, WellOrderingRel j i → f j x ≠ 0 → j ∈ t) :
    f.toPOUFun i x = f i x * ∏ j in t.filterₓ fun j => WellOrderingRel j i, (1 - f j x) :=
  by
  refine' congr_arg _ (finprod_cond_eq_prod_of_cond_iff _ fun j hj => _)
  rw [Ne.def, sub_eq_self] at hj 
  rw [Finset.mem_filter, Iff.comm, and_iff_right_iff_imp]
  exact flip (ht j) hj
#align bump_covering.to_pou_fun_eq_mul_prod BumpCovering.toPOUFun_eq_mul_prod
-/

#print BumpCovering.sum_toPOUFun_eq /-
theorem sum_toPOUFun_eq (x : X) : ∑ᶠ i, f.toPOUFun i x = 1 - ∏ᶠ i, (1 - f i x) :=
  by
  set s := (f.point_finite x).toFinset
  have hs : (s : Set ι) = {i | f i x ≠ 0} := finite.coe_to_finset _
  have A : (support fun i => to_pou_fun f i x) ⊆ s :=
    by
    rw [hs]
    exact fun i hi => f.support_to_pou_fun_subset i hi
  have B : (mul_support fun i => 1 - f i x) ⊆ s := by rw [hs, mul_support_one_sub];
    exact fun i => id
  letI : LinearOrder ι := linearOrderOfSTO WellOrderingRel
  rw [finsum_eq_sum_of_support_subset _ A, finprod_eq_prod_of_mulSupport_subset _ B,
    Finset.prod_one_sub_ordered, sub_sub_cancel]
  refine' Finset.sum_congr rfl fun i hi => _
  convert f.to_pou_fun_eq_mul_prod _ _ _ fun j hji hj => _
  rwa [finite.mem_to_finset]
#align bump_covering.sum_to_pou_fun_eq BumpCovering.sum_toPOUFun_eq
-/

#print BumpCovering.exists_finset_toPOUFun_eventuallyEq /-
theorem exists_finset_toPOUFun_eventuallyEq (i : ι) (x : X) :
    ∃ t : Finset ι,
      f.toPOUFun i =ᶠ[𝓝 x] f i * ∏ j in t.filterₓ fun j => WellOrderingRel j i, (1 - f j) :=
  by
  rcases f.locally_finite x with ⟨U, hU, hf⟩
  use hf.to_finset
  filter_upwards [hU] with y hyU
  simp only [Pi.mul_apply, Finset.prod_apply]
  apply to_pou_fun_eq_mul_prod
  intro j hji hj
  exact hf.mem_to_finset.2 ⟨y, ⟨hj, hyU⟩⟩
#align bump_covering.exists_finset_to_pou_fun_eventually_eq BumpCovering.exists_finset_toPOUFun_eventuallyEq
-/

#print BumpCovering.continuous_toPOUFun /-
theorem continuous_toPOUFun (i : ι) : Continuous (f.toPOUFun i) :=
  by
  refine'
    (f i).Continuous.mul <|
      continuous_finprod_cond (fun j _ => continuous_const.sub (f j).Continuous) _
  simp only [mul_support_one_sub]
  exact f.locally_finite
#align bump_covering.continuous_to_pou_fun BumpCovering.continuous_toPOUFun
-/

#print BumpCovering.toPartitionOfUnity /-
/-- The partition of unity defined by a `bump_covering`.

The partition of unity is given by the formula `g i x = f i x * ∏ᶠ j < i, (1 - f j x)`. In other
words, `g i x = ∏ᶠ j < i, (1 - f j x) - ∏ᶠ j ≤ i, (1 - f j x)`, so
`∑ᶠ i, g i x = 1 - ∏ᶠ j, (1 - f j x)`. If `x ∈ s`, then one of `f j x` equals one, hence the product
of `1 - f j x` vanishes, and `∑ᶠ i, g i x = 1`.

In order to avoid an assumption `linear_order ι`, we use `well_ordering_rel` instead of `(<)`. -/
def toPartitionOfUnity : PartitionOfUnity ι X s
    where
  toFun i := ⟨f.toPOUFun i, f.continuous_toPOUFun i⟩
  locally_finite' := f.LocallyFinite.Subset f.support_toPOUFun_subset
  nonneg' i x :=
    mul_nonneg (f.NonNeg i x) (finprod_cond_nonneg fun j hj => sub_nonneg.2 <| f.le_one j x)
  sum_eq_one' x hx :=
    by
    simp only [ContinuousMap.coe_mk, sum_to_pou_fun_eq, sub_eq_self]
    apply finprod_eq_zero (fun i => 1 - f i x) (f.ind x hx)
    · simp only [f.ind_apply x hx, sub_self]
    · rw [mul_support_one_sub]; exact f.point_finite x
  sum_le_one' x :=
    by
    simp only [ContinuousMap.coe_mk, sum_to_pou_fun_eq, sub_le_self_iff]
    exact finprod_nonneg fun i => sub_nonneg.2 <| f.le_one i x
#align bump_covering.to_partition_of_unity BumpCovering.toPartitionOfUnity
-/

#print BumpCovering.toPartitionOfUnity_apply /-
theorem toPartitionOfUnity_apply (i : ι) (x : X) :
    f.toPartitionOfUnity i x = f i x * ∏ᶠ (j) (hj : WellOrderingRel j i), (1 - f j x) :=
  rfl
#align bump_covering.to_partition_of_unity_apply BumpCovering.toPartitionOfUnity_apply
-/

#print BumpCovering.toPartitionOfUnity_eq_mul_prod /-
theorem toPartitionOfUnity_eq_mul_prod (i : ι) (x : X) (t : Finset ι)
    (ht : ∀ j, WellOrderingRel j i → f j x ≠ 0 → j ∈ t) :
    f.toPartitionOfUnity i x = f i x * ∏ j in t.filterₓ fun j => WellOrderingRel j i, (1 - f j x) :=
  f.toPOUFun_eq_mul_prod i x t ht
#align bump_covering.to_partition_of_unity_eq_mul_prod BumpCovering.toPartitionOfUnity_eq_mul_prod
-/

#print BumpCovering.exists_finset_toPartitionOfUnity_eventuallyEq /-
theorem exists_finset_toPartitionOfUnity_eventuallyEq (i : ι) (x : X) :
    ∃ t : Finset ι,
      f.toPartitionOfUnity i =ᶠ[𝓝 x]
        f i * ∏ j in t.filterₓ fun j => WellOrderingRel j i, (1 - f j) :=
  f.exists_finset_toPOUFun_eventuallyEq i x
#align bump_covering.exists_finset_to_partition_of_unity_eventually_eq BumpCovering.exists_finset_toPartitionOfUnity_eventuallyEq
-/

#print BumpCovering.toPartitionOfUnity_zero_of_zero /-
theorem toPartitionOfUnity_zero_of_zero {i : ι} {x : X} (h : f i x = 0) :
    f.toPartitionOfUnity i x = 0 :=
  f.toPOUFun_zero_of_zero h
#align bump_covering.to_partition_of_unity_zero_of_zero BumpCovering.toPartitionOfUnity_zero_of_zero
-/

#print BumpCovering.support_toPartitionOfUnity_subset /-
theorem support_toPartitionOfUnity_subset (i : ι) :
    support (f.toPartitionOfUnity i) ⊆ support (f i) :=
  f.support_toPOUFun_subset i
#align bump_covering.support_to_partition_of_unity_subset BumpCovering.support_toPartitionOfUnity_subset
-/

#print BumpCovering.sum_toPartitionOfUnity_eq /-
theorem sum_toPartitionOfUnity_eq (x : X) :
    ∑ᶠ i, f.toPartitionOfUnity i x = 1 - ∏ᶠ i, (1 - f i x) :=
  f.sum_toPOUFun_eq x
#align bump_covering.sum_to_partition_of_unity_eq BumpCovering.sum_toPartitionOfUnity_eq
-/

#print BumpCovering.IsSubordinate.toPartitionOfUnity /-
theorem IsSubordinate.toPartitionOfUnity {f : BumpCovering ι X s} {U : ι → Set X}
    (h : f.IsSubordinate U) : f.toPartitionOfUnity.IsSubordinate U := fun i =>
  Subset.trans (closure_mono <| f.support_toPartitionOfUnity_subset i) (h i)
#align bump_covering.is_subordinate.to_partition_of_unity BumpCovering.IsSubordinate.toPartitionOfUnity
-/

end BumpCovering

namespace PartitionOfUnity

variable {s : Set X}

instance [Inhabited ι] : Inhabited (PartitionOfUnity ι X s) :=
  ⟨BumpCovering.toPartitionOfUnity default⟩

#print PartitionOfUnity.exists_isSubordinate_of_locallyFinite /-
/-- If `X` is a normal topological space and `U` is a locally finite open covering of a closed set
`s`, then there exists a `partition_of_unity ι X s` that is subordinate to `U`. If `X` is a
paracompact space, then the assumption `hf : locally_finite U` can be omitted, see
`bump_covering.exists_is_subordinate`. -/
theorem exists_isSubordinate_of_locallyFinite [NormalSpace X] (hs : IsClosed s) (U : ι → Set X)
    (ho : ∀ i, IsOpen (U i)) (hf : LocallyFinite U) (hU : s ⊆ ⋃ i, U i) :
    ∃ f : PartitionOfUnity ι X s, f.IsSubordinate U :=
  let ⟨f, hf⟩ := BumpCovering.exists_isSubordinate_of_locallyFinite hs U ho hf hU
  ⟨f.toPartitionOfUnity, hf.toPartitionOfUnity⟩
#align partition_of_unity.exists_is_subordinate_of_locally_finite PartitionOfUnity.exists_isSubordinate_of_locallyFinite
-/

#print PartitionOfUnity.exists_isSubordinate /-
/-- If `X` is a paracompact normal topological space and `U` is an open covering of a closed set
`s`, then there exists a `partition_of_unity ι X s` that is subordinate to `U`. -/
theorem exists_isSubordinate [NormalSpace X] [ParacompactSpace X] (hs : IsClosed s) (U : ι → Set X)
    (ho : ∀ i, IsOpen (U i)) (hU : s ⊆ ⋃ i, U i) :
    ∃ f : PartitionOfUnity ι X s, f.IsSubordinate U :=
  let ⟨f, hf⟩ := BumpCovering.exists_isSubordinate hs U ho hU
  ⟨f.toPartitionOfUnity, hf.toPartitionOfUnity⟩
#align partition_of_unity.exists_is_subordinate PartitionOfUnity.exists_isSubordinate
-/

end PartitionOfUnity

