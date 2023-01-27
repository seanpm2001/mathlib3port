/-
Copyright (c) 2022 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Patrick Massot

! This file was ported from Lean 3 source module topology.nhds_set
! leanprover-community/mathlib commit f7fc89d5d5ff1db2d1242c7bb0e9062ce47ef47c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Basic

/-!
# Neighborhoods of a set

In this file we define the filter `𝓝ˢ s` or `nhds_set s` consisting of all neighborhoods of a set
`s`.

## Main Properties

There are a couple different notions equivalent to `s ∈ 𝓝ˢ t`:
* `s ⊆ interior t` using `subset_interior_iff_mem_nhds_set`
* `∀ (x : α), x ∈ t → s ∈ 𝓝 x` using `mem_nhds_set_iff_forall`
* `∃ U : set α, is_open U ∧ t ⊆ U ∧ U ⊆ s` using `mem_nhds_set_iff_exists`

Furthermore, we have the following results:
* `monotone_nhds_set`: `𝓝ˢ` is monotone
* In T₁-spaces, `𝓝ˢ`is strictly monotone and hence injective:
  `strict_mono_nhds_set`/`injective_nhds_set`. These results are in `topology.separation`.
-/


open Set Filter

open TopologicalSpace Filter

variable {α β : Type _} [TopologicalSpace α] [TopologicalSpace β] {s t s₁ s₂ t₁ t₂ : Set α} {x : α}

#print nhdsSet /-
/-- The filter of neighborhoods of a set in a topological space. -/
def nhdsSet (s : Set α) : Filter α :=
  supₛ (nhds '' s)
#align nhds_set nhdsSet
-/

-- mathport name: nhds_set
scoped[TopologicalSpace] notation "𝓝ˢ" => nhdsSet

/- warning: nhds_set_diagonal -> nhdsSet_diagonal is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u1}) [_inst_3 : TopologicalSpace.{u1} (Prod.{u1, u1} α α)], Eq.{succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (nhdsSet.{u1} (Prod.{u1, u1} α α) _inst_3 (Set.diagonal.{u1} α)) (supᵢ.{u1, succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (ConditionallyCompleteLattice.toHasSup.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (Filter.completeLattice.{u1} (Prod.{u1, u1} α α)))) α (fun (x : α) => nhds.{u1} (Prod.{u1, u1} α α) _inst_3 (Prod.mk.{u1, u1} α α x x)))
but is expected to have type
  forall (α : Type.{u1}) [_inst_3 : TopologicalSpace.{u1} (Prod.{u1, u1} α α)], Eq.{succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (nhdsSet.{u1} (Prod.{u1, u1} α α) _inst_3 (Set.diagonal.{u1} α)) (supᵢ.{u1, succ u1} (Filter.{u1} (Prod.{u1, u1} α α)) (ConditionallyCompleteLattice.toSupSet.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} (Prod.{u1, u1} α α)) (Filter.instCompleteLatticeFilter.{u1} (Prod.{u1, u1} α α)))) α (fun (x : α) => nhds.{u1} (Prod.{u1, u1} α α) _inst_3 (Prod.mk.{u1, u1} α α x x)))
Case conversion may be inaccurate. Consider using '#align nhds_set_diagonal nhdsSet_diagonalₓ'. -/
theorem nhdsSet_diagonal (α) [TopologicalSpace (α × α)] : 𝓝ˢ (diagonal α) = ⨆ x, 𝓝 (x, x) :=
  by
  rw [nhdsSet, ← range_diag, ← range_comp]
  rfl
#align nhds_set_diagonal nhdsSet_diagonal

#print mem_nhdsSet_iff_forall /-
theorem mem_nhdsSet_iff_forall : s ∈ 𝓝ˢ t ↔ ∀ x : α, x ∈ t → s ∈ 𝓝 x := by
  simp_rw [nhdsSet, Filter.mem_supₛ, ball_image_iff]
#align mem_nhds_set_iff_forall mem_nhdsSet_iff_forall
-/

#print bUnion_mem_nhdsSet /-
theorem bUnion_mem_nhdsSet {t : α → Set α} (h : ∀ x ∈ s, t x ∈ 𝓝 x) : (⋃ x ∈ s, t x) ∈ 𝓝ˢ s :=
  mem_nhdsSet_iff_forall.2 fun x hx => mem_of_superset (h x hx) (subset_unionᵢ₂ x hx)
#align bUnion_mem_nhds_set bUnion_mem_nhdsSet
-/

#print subset_interior_iff_mem_nhdsSet /-
theorem subset_interior_iff_mem_nhdsSet : s ⊆ interior t ↔ t ∈ 𝓝ˢ s := by
  simp_rw [mem_nhdsSet_iff_forall, subset_interior_iff_nhds]
#align subset_interior_iff_mem_nhds_set subset_interior_iff_mem_nhdsSet
-/

#print mem_nhdsSet_iff_exists /-
theorem mem_nhdsSet_iff_exists : s ∈ 𝓝ˢ t ↔ ∃ U : Set α, IsOpen U ∧ t ⊆ U ∧ U ⊆ s := by
  rw [← subset_interior_iff_mem_nhdsSet, subset_interior_iff]
#align mem_nhds_set_iff_exists mem_nhdsSet_iff_exists
-/

#print hasBasis_nhdsSet /-
theorem hasBasis_nhdsSet (s : Set α) : (𝓝ˢ s).HasBasis (fun U => IsOpen U ∧ s ⊆ U) fun U => U :=
  ⟨fun t => by simp [mem_nhdsSet_iff_exists, and_assoc']⟩
#align has_basis_nhds_set hasBasis_nhdsSet
-/

#print IsOpen.mem_nhdsSet /-
theorem IsOpen.mem_nhdsSet (hU : IsOpen s) : s ∈ 𝓝ˢ t ↔ t ⊆ s := by
  rw [← subset_interior_iff_mem_nhdsSet, interior_eq_iff_is_open.mpr hU]
#align is_open.mem_nhds_set IsOpen.mem_nhdsSet
-/

/- warning: principal_le_nhds_set -> principal_le_nhdsSet is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s : Set.{u1} α}, LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α))) (Filter.principal.{u1} α s) (nhdsSet.{u1} α _inst_1 s)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s : Set.{u1} α}, LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α))) (Filter.principal.{u1} α s) (nhdsSet.{u1} α _inst_1 s)
Case conversion may be inaccurate. Consider using '#align principal_le_nhds_set principal_le_nhdsSetₓ'. -/
theorem principal_le_nhdsSet : 𝓟 s ≤ 𝓝ˢ s := fun s hs =>
  (subset_interior_iff_mem_nhdsSet.mpr hs).trans interior_subset
#align principal_le_nhds_set principal_le_nhdsSet

#print nhdsSet_eq_principal_iff /-
@[simp]
theorem nhdsSet_eq_principal_iff : 𝓝ˢ s = 𝓟 s ↔ IsOpen s := by
  rw [← principal_le_nhds_set.le_iff_eq, le_principal_iff, mem_nhdsSet_iff_forall,
    isOpen_iff_mem_nhds]
#align nhds_set_eq_principal_iff nhdsSet_eq_principal_iff
-/

alias nhdsSet_eq_principal_iff ↔ _ IsOpen.nhdsSet_eq
#align is_open.nhds_set_eq IsOpen.nhdsSet_eq

#print nhdsSet_interior /-
@[simp]
theorem nhdsSet_interior : 𝓝ˢ (interior s) = 𝓟 (interior s) :=
  isOpen_interior.nhds_set_eq
#align nhds_set_interior nhdsSet_interior
-/

#print nhdsSet_singleton /-
@[simp]
theorem nhdsSet_singleton : 𝓝ˢ {x} = 𝓝 x := by
  ext
  rw [← subset_interior_iff_mem_nhdsSet, ← mem_interior_iff_mem_nhds, singleton_subset_iff]
#align nhds_set_singleton nhdsSet_singleton
-/

#print mem_nhdsSet_interior /-
theorem mem_nhdsSet_interior : s ∈ 𝓝ˢ (interior s) :=
  subset_interior_iff_mem_nhdsSet.mp Subset.rfl
#align mem_nhds_set_interior mem_nhdsSet_interior
-/

/- warning: nhds_set_empty -> nhdsSet_empty is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α], Eq.{succ u1} (Filter.{u1} α) (nhdsSet.{u1} α _inst_1 (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.hasEmptyc.{u1} α))) (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toHasBot.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α], Eq.{succ u1} (Filter.{u1} α) (nhdsSet.{u1} α _inst_1 (EmptyCollection.emptyCollection.{u1} (Set.{u1} α) (Set.instEmptyCollectionSet.{u1} α))) (Bot.bot.{u1} (Filter.{u1} α) (CompleteLattice.toBot.{u1} (Filter.{u1} α) (Filter.instCompleteLatticeFilter.{u1} α)))
Case conversion may be inaccurate. Consider using '#align nhds_set_empty nhdsSet_emptyₓ'. -/
@[simp]
theorem nhdsSet_empty : 𝓝ˢ (∅ : Set α) = ⊥ := by rw [is_open_empty.nhds_set_eq, principal_empty]
#align nhds_set_empty nhdsSet_empty

#print mem_nhdsSet_empty /-
theorem mem_nhdsSet_empty : s ∈ 𝓝ˢ (∅ : Set α) := by simp
#align mem_nhds_set_empty mem_nhdsSet_empty
-/

/- warning: nhds_set_univ -> nhdsSet_univ is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α], Eq.{succ u1} (Filter.{u1} α) (nhdsSet.{u1} α _inst_1 (Set.univ.{u1} α)) (Top.top.{u1} (Filter.{u1} α) (Filter.hasTop.{u1} α))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α], Eq.{succ u1} (Filter.{u1} α) (nhdsSet.{u1} α _inst_1 (Set.univ.{u1} α)) (Top.top.{u1} (Filter.{u1} α) (Filter.instTopFilter.{u1} α))
Case conversion may be inaccurate. Consider using '#align nhds_set_univ nhdsSet_univₓ'. -/
@[simp]
theorem nhdsSet_univ : 𝓝ˢ (univ : Set α) = ⊤ := by rw [is_open_univ.nhds_set_eq, principal_univ]
#align nhds_set_univ nhdsSet_univ

/- warning: nhds_set_mono -> nhdsSet_mono is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s : Set.{u1} α} {t : Set.{u1} α}, (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) s t) -> (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α))) (nhdsSet.{u1} α _inst_1 s) (nhdsSet.{u1} α _inst_1 t))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s : Set.{u1} α} {t : Set.{u1} α}, (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) s t) -> (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α))) (nhdsSet.{u1} α _inst_1 s) (nhdsSet.{u1} α _inst_1 t))
Case conversion may be inaccurate. Consider using '#align nhds_set_mono nhdsSet_monoₓ'. -/
@[mono]
theorem nhdsSet_mono (h : s ⊆ t) : 𝓝ˢ s ≤ 𝓝ˢ t :=
  supₛ_le_supₛ <| image_subset _ h
#align nhds_set_mono nhdsSet_mono

/- warning: monotone_nhds_set -> monotone_nhdsSet is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α], Monotone.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Set.{u1} α) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} α) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.completeBooleanAlgebra.{u1} α))))))) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α)) (nhdsSet.{u1} α _inst_1)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α], Monotone.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Set.{u1} α) (CompleteSemilatticeInf.toPartialOrder.{u1} (Set.{u1} α) (CompleteLattice.toCompleteSemilatticeInf.{u1} (Set.{u1} α) (Order.Coframe.toCompleteLattice.{u1} (Set.{u1} α) (CompleteDistribLattice.toCoframe.{u1} (Set.{u1} α) (CompleteBooleanAlgebra.toCompleteDistribLattice.{u1} (Set.{u1} α) (Set.instCompleteBooleanAlgebraSet.{u1} α))))))) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α)) (nhdsSet.{u1} α _inst_1)
Case conversion may be inaccurate. Consider using '#align monotone_nhds_set monotone_nhdsSetₓ'. -/
theorem monotone_nhdsSet : Monotone (𝓝ˢ : Set α → Filter α) := fun s t => nhdsSet_mono
#align monotone_nhds_set monotone_nhdsSet

/- warning: nhds_le_nhds_set -> nhds_le_nhdsSet is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s : Set.{u1} α} {x : α}, (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) x s) -> (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α))) (nhds.{u1} α _inst_1 x) (nhdsSet.{u1} α _inst_1 s))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s : Set.{u1} α} {x : α}, (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) x s) -> (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α))) (nhds.{u1} α _inst_1 x) (nhdsSet.{u1} α _inst_1 s))
Case conversion may be inaccurate. Consider using '#align nhds_le_nhds_set nhds_le_nhdsSetₓ'. -/
theorem nhds_le_nhdsSet (h : x ∈ s) : 𝓝 x ≤ 𝓝ˢ s :=
  le_supₛ <| mem_image_of_mem _ h
#align nhds_le_nhds_set nhds_le_nhdsSet

/- warning: nhds_set_union -> nhdsSet_union is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] (s : Set.{u1} α) (t : Set.{u1} α), Eq.{succ u1} (Filter.{u1} α) (nhdsSet.{u1} α _inst_1 (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s t)) (HasSup.sup.{u1} (Filter.{u1} α) (SemilatticeSup.toHasSup.{u1} (Filter.{u1} α) (Lattice.toSemilatticeSup.{u1} (Filter.{u1} α) (ConditionallyCompleteLattice.toLattice.{u1} (Filter.{u1} α) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} α) (Filter.completeLattice.{u1} α))))) (nhdsSet.{u1} α _inst_1 s) (nhdsSet.{u1} α _inst_1 t))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] (s : Set.{u1} α) (t : Set.{u1} α), Eq.{succ u1} (Filter.{u1} α) (nhdsSet.{u1} α _inst_1 (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s t)) (HasSup.sup.{u1} (Filter.{u1} α) (SemilatticeSup.toHasSup.{u1} (Filter.{u1} α) (Lattice.toSemilatticeSup.{u1} (Filter.{u1} α) (ConditionallyCompleteLattice.toLattice.{u1} (Filter.{u1} α) (CompleteLattice.toConditionallyCompleteLattice.{u1} (Filter.{u1} α) (Filter.instCompleteLatticeFilter.{u1} α))))) (nhdsSet.{u1} α _inst_1 s) (nhdsSet.{u1} α _inst_1 t))
Case conversion may be inaccurate. Consider using '#align nhds_set_union nhdsSet_unionₓ'. -/
@[simp]
theorem nhdsSet_union (s t : Set α) : 𝓝ˢ (s ∪ t) = 𝓝ˢ s ⊔ 𝓝ˢ t := by
  simp only [nhdsSet, image_union, supₛ_union]
#align nhds_set_union nhdsSet_union

/- warning: union_mem_nhds_set -> union_mem_nhdsSet is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s₁ : Set.{u1} α} {s₂ : Set.{u1} α} {t₁ : Set.{u1} α} {t₂ : Set.{u1} α}, (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s₁ (nhdsSet.{u1} α _inst_1 t₁)) -> (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s₂ (nhdsSet.{u1} α _inst_1 t₂)) -> (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) s₁ s₂) (nhdsSet.{u1} α _inst_1 (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) t₁ t₂)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : TopologicalSpace.{u1} α] {s₁ : Set.{u1} α} {s₂ : Set.{u1} α} {t₁ : Set.{u1} α} {t₂ : Set.{u1} α}, (Membership.mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (instMembershipSetFilter.{u1} α) s₁ (nhdsSet.{u1} α _inst_1 t₁)) -> (Membership.mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (instMembershipSetFilter.{u1} α) s₂ (nhdsSet.{u1} α _inst_1 t₂)) -> (Membership.mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (instMembershipSetFilter.{u1} α) (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) s₁ s₂) (nhdsSet.{u1} α _inst_1 (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet.{u1} α) t₁ t₂)))
Case conversion may be inaccurate. Consider using '#align union_mem_nhds_set union_mem_nhdsSetₓ'. -/
theorem union_mem_nhdsSet (h₁ : s₁ ∈ 𝓝ˢ t₁) (h₂ : s₂ ∈ 𝓝ˢ t₂) : s₁ ∪ s₂ ∈ 𝓝ˢ (t₁ ∪ t₂) :=
  by
  rw [nhdsSet_union]
  exact union_mem_sup h₁ h₂
#align union_mem_nhds_set union_mem_nhdsSet

#print Continuous.tendsto_nhdsSet /-
/-- Preimage of a set neighborhood of `t` under a continuous map `f` is a set neighborhood of `s`
provided that `f` maps `s` to `t`.  -/
theorem Continuous.tendsto_nhdsSet {f : α → β} {t : Set β} (hf : Continuous f)
    (hst : MapsTo f s t) : Tendsto f (𝓝ˢ s) (𝓝ˢ t) :=
  ((hasBasis_nhdsSet s).tendsto_iff (hasBasis_nhdsSet t)).mpr fun U hU =>
    ⟨f ⁻¹' U, ⟨hU.1.Preimage hf, hst.mono Subset.rfl hU.2⟩, fun x => id⟩
#align continuous.tendsto_nhds_set Continuous.tendsto_nhdsSet
-/

