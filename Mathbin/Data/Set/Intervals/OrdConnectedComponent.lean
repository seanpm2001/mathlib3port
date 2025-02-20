/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module data.set.intervals.ord_connected_component
! leanprover-community/mathlib commit 92ca63f0fb391a9ca5f22d2409a6080e786d99f7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.OrdConnected
import Mathbin.Tactic.Wlog

/-!
# Order connected components of a set

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `set.ord_connected_component s x` to be the set of `y` such that
`set.uIcc x y ⊆ s` and prove some basic facts about this definition. At the moment of writing,
this construction is used only to prove that any linear order with order topology is a T₅ space,
so we only add API needed for this lemma.
-/


open Function OrderDual

open scoped Interval

namespace Set

variable {α : Type _} [LinearOrder α] {s t : Set α} {x y z : α}

#print Set.ordConnectedComponent /-
/-- Order-connected component of a point `x` in a set `s`. It is defined as the set of `y` such that
`set.uIcc x y ⊆ s`. Note that it is empty if and only if `x ∉ s`. -/
def ordConnectedComponent (s : Set α) (x : α) : Set α :=
  {y | [x, y] ⊆ s}
#align set.ord_connected_component Set.ordConnectedComponent
-/

#print Set.mem_ordConnectedComponent /-
theorem mem_ordConnectedComponent : y ∈ ordConnectedComponent s x ↔ [x, y] ⊆ s :=
  Iff.rfl
#align set.mem_ord_connected_component Set.mem_ordConnectedComponent
-/

#print Set.dual_ordConnectedComponent /-
theorem dual_ordConnectedComponent :
    ordConnectedComponent (ofDual ⁻¹' s) (toDual x) = ofDual ⁻¹' ordConnectedComponent s x :=
  ext <| toDual.Surjective.forall.2 fun x => by rw [mem_ord_connected_component, dual_uIcc]; rfl
#align set.dual_ord_connected_component Set.dual_ordConnectedComponent
-/

#print Set.ordConnectedComponent_subset /-
theorem ordConnectedComponent_subset : ordConnectedComponent s x ⊆ s := fun y hy =>
  hy right_mem_uIcc
#align set.ord_connected_component_subset Set.ordConnectedComponent_subset
-/

#print Set.subset_ordConnectedComponent /-
theorem subset_ordConnectedComponent {t} [h : OrdConnected s] (hs : x ∈ s) (ht : s ⊆ t) :
    s ⊆ ordConnectedComponent t x := fun y hy => (h.uIcc_subset hs hy).trans ht
#align set.subset_ord_connected_component Set.subset_ordConnectedComponent
-/

#print Set.self_mem_ordConnectedComponent /-
@[simp]
theorem self_mem_ordConnectedComponent : x ∈ ordConnectedComponent s x ↔ x ∈ s := by
  rw [mem_ord_connected_component, uIcc_self, singleton_subset_iff]
#align set.self_mem_ord_connected_component Set.self_mem_ordConnectedComponent
-/

#print Set.nonempty_ordConnectedComponent /-
@[simp]
theorem nonempty_ordConnectedComponent : (ordConnectedComponent s x).Nonempty ↔ x ∈ s :=
  ⟨fun ⟨y, hy⟩ => hy <| left_mem_uIcc, fun h => ⟨x, self_mem_ordConnectedComponent.2 h⟩⟩
#align set.nonempty_ord_connected_component Set.nonempty_ordConnectedComponent
-/

#print Set.ordConnectedComponent_eq_empty /-
@[simp]
theorem ordConnectedComponent_eq_empty : ordConnectedComponent s x = ∅ ↔ x ∉ s := by
  rw [← not_nonempty_iff_eq_empty, nonempty_ord_connected_component]
#align set.ord_connected_component_eq_empty Set.ordConnectedComponent_eq_empty
-/

#print Set.ordConnectedComponent_empty /-
@[simp]
theorem ordConnectedComponent_empty : ordConnectedComponent ∅ x = ∅ :=
  ordConnectedComponent_eq_empty.2 (not_mem_empty x)
#align set.ord_connected_component_empty Set.ordConnectedComponent_empty
-/

#print Set.ordConnectedComponent_univ /-
@[simp]
theorem ordConnectedComponent_univ : ordConnectedComponent univ x = univ := by
  simp [ord_connected_component]
#align set.ord_connected_component_univ Set.ordConnectedComponent_univ
-/

#print Set.ordConnectedComponent_inter /-
theorem ordConnectedComponent_inter (s t : Set α) (x : α) :
    ordConnectedComponent (s ∩ t) x = ordConnectedComponent s x ∩ ordConnectedComponent t x := by
  simp [ord_connected_component, set_of_and]
#align set.ord_connected_component_inter Set.ordConnectedComponent_inter
-/

#print Set.mem_ordConnectedComponent_comm /-
theorem mem_ordConnectedComponent_comm :
    y ∈ ordConnectedComponent s x ↔ x ∈ ordConnectedComponent s y := by
  rw [mem_ord_connected_component, mem_ord_connected_component, uIcc_comm]
#align set.mem_ord_connected_component_comm Set.mem_ordConnectedComponent_comm
-/

#print Set.mem_ordConnectedComponent_trans /-
theorem mem_ordConnectedComponent_trans (hxy : y ∈ ordConnectedComponent s x)
    (hyz : z ∈ ordConnectedComponent s y) : z ∈ ordConnectedComponent s x :=
  calc
    [x, z] ⊆ [x, y] ∪ [y, z] := uIcc_subset_uIcc_union_uIcc
    _ ⊆ s := union_subset hxy hyz
#align set.mem_ord_connected_component_trans Set.mem_ordConnectedComponent_trans
-/

#print Set.ordConnectedComponent_eq /-
theorem ordConnectedComponent_eq (h : [x, y] ⊆ s) :
    ordConnectedComponent s x = ordConnectedComponent s y :=
  ext fun z =>
    ⟨mem_ordConnectedComponent_trans (mem_ordConnectedComponent_comm.2 h),
      mem_ordConnectedComponent_trans h⟩
#align set.ord_connected_component_eq Set.ordConnectedComponent_eq
-/

instance : OrdConnected (ordConnectedComponent s x) :=
  ordConnected_of_uIcc_subset_left fun y hy z hz => (uIcc_subset_uIcc_left hz).trans hy

#print Set.ordConnectedProj /-
/-- Projection from `s : set α` to `α` sending each order connected component of `s` to a single
point of this component. -/
noncomputable def ordConnectedProj (s : Set α) : s → α := fun x : s =>
  (nonempty_ordConnectedComponent.2 x.Prop).some
#align set.ord_connected_proj Set.ordConnectedProj
-/

#print Set.ordConnectedProj_mem_ordConnectedComponent /-
theorem ordConnectedProj_mem_ordConnectedComponent (s : Set α) (x : s) :
    ordConnectedProj s x ∈ ordConnectedComponent s x :=
  Nonempty.some_mem _
#align set.ord_connected_proj_mem_ord_connected_component Set.ordConnectedProj_mem_ordConnectedComponent
-/

#print Set.mem_ordConnectedComponent_ordConnectedProj /-
theorem mem_ordConnectedComponent_ordConnectedProj (s : Set α) (x : s) :
    ↑x ∈ ordConnectedComponent s (ordConnectedProj s x) :=
  mem_ordConnectedComponent_comm.2 <| ordConnectedProj_mem_ordConnectedComponent s x
#align set.mem_ord_connected_component_ord_connected_proj Set.mem_ordConnectedComponent_ordConnectedProj
-/

#print Set.ordConnectedComponent_ordConnectedProj /-
@[simp]
theorem ordConnectedComponent_ordConnectedProj (s : Set α) (x : s) :
    ordConnectedComponent s (ordConnectedProj s x) = ordConnectedComponent s x :=
  ordConnectedComponent_eq <| mem_ordConnectedComponent_ordConnectedProj _ _
#align set.ord_connected_component_ord_connected_proj Set.ordConnectedComponent_ordConnectedProj
-/

#print Set.ordConnectedProj_eq /-
@[simp]
theorem ordConnectedProj_eq {x y : s} :
    ordConnectedProj s x = ordConnectedProj s y ↔ [(x : α), y] ⊆ s :=
  by
  constructor <;> intro h
  · rw [← mem_ord_connected_component, ← ord_connected_component_ord_connected_proj, h,
      ord_connected_component_ord_connected_proj, self_mem_ord_connected_component]
    exact y.2
  · simp only [ord_connected_proj]
    congr 1
    exact ord_connected_component_eq h
#align set.ord_connected_proj_eq Set.ordConnectedProj_eq
-/

#print Set.ordConnectedSection /-
/-- A set that intersects each order connected component of a set by a single point. Defined as the
range of `set.ord_connected_proj s`. -/
def ordConnectedSection (s : Set α) : Set α :=
  range <| ordConnectedProj s
#align set.ord_connected_section Set.ordConnectedSection
-/

#print Set.dual_ordConnectedSection /-
theorem dual_ordConnectedSection (s : Set α) :
    ordConnectedSection (ofDual ⁻¹' s) = ofDual ⁻¹' ordConnectedSection s :=
  by
  simp only [ord_connected_section, ord_connected_proj]
  congr 1 with x; simp only; congr 1
  exact dual_ord_connected_component
#align set.dual_ord_connected_section Set.dual_ordConnectedSection
-/

#print Set.ordConnectedSection_subset /-
theorem ordConnectedSection_subset : ordConnectedSection s ⊆ s :=
  range_subset_iff.2 fun x => ordConnectedComponent_subset <| Nonempty.some_mem _
#align set.ord_connected_section_subset Set.ordConnectedSection_subset
-/

#print Set.eq_of_mem_ordConnectedSection_of_uIcc_subset /-
theorem eq_of_mem_ordConnectedSection_of_uIcc_subset (hx : x ∈ ordConnectedSection s)
    (hy : y ∈ ordConnectedSection s) (h : [x, y] ⊆ s) : x = y :=
  by
  rcases hx with ⟨x, rfl⟩; rcases hy with ⟨y, rfl⟩
  exact
    ord_connected_proj_eq.2
      (mem_ord_connected_component_trans
        (mem_ord_connected_component_trans (ord_connected_proj_mem_ord_connected_component _ _) h)
        (mem_ord_connected_component_ord_connected_proj _ _))
#align set.eq_of_mem_ord_connected_section_of_uIcc_subset Set.eq_of_mem_ordConnectedSection_of_uIcc_subset
-/

#print Set.ordSeparatingSet /-
/-- Given two sets `s t : set α`, the set `set.order_separating_set s t` is the set of points that
belong both to some `set.ord_connected_component tᶜ x`, `x ∈ s`, and to some
`set.ord_connected_component sᶜ x`, `x ∈ t`. In the case of two disjoint closed sets, this is the
union of all open intervals $(a, b)$ such that their endpoints belong to different sets. -/
def ordSeparatingSet (s t : Set α) : Set α :=
  (⋃ x ∈ s, ordConnectedComponent (tᶜ) x) ∩ ⋃ x ∈ t, ordConnectedComponent (sᶜ) x
#align set.ord_separating_set Set.ordSeparatingSet
-/

#print Set.ordSeparatingSet_comm /-
theorem ordSeparatingSet_comm (s t : Set α) : ordSeparatingSet s t = ordSeparatingSet t s :=
  inter_comm _ _
#align set.ord_separating_set_comm Set.ordSeparatingSet_comm
-/

#print Set.disjoint_left_ordSeparatingSet /-
theorem disjoint_left_ordSeparatingSet : Disjoint s (ordSeparatingSet s t) :=
  Disjoint.inter_right' _ <|
    disjoint_iUnion₂_right.2 fun x hx =>
      disjoint_compl_right.mono_right <| ordConnectedComponent_subset
#align set.disjoint_left_ord_separating_set Set.disjoint_left_ordSeparatingSet
-/

#print Set.disjoint_right_ordSeparatingSet /-
theorem disjoint_right_ordSeparatingSet : Disjoint t (ordSeparatingSet s t) :=
  ordSeparatingSet_comm t s ▸ disjoint_left_ordSeparatingSet
#align set.disjoint_right_ord_separating_set Set.disjoint_right_ordSeparatingSet
-/

#print Set.dual_ordSeparatingSet /-
theorem dual_ordSeparatingSet :
    ordSeparatingSet (ofDual ⁻¹' s) (ofDual ⁻¹' t) = ofDual ⁻¹' ordSeparatingSet s t := by
  simp only [ord_separating_set, mem_preimage, ← to_dual.surjective.Union_comp, of_dual_to_dual,
    dual_ord_connected_component, ← preimage_compl, preimage_inter, preimage_Union]
#align set.dual_ord_separating_set Set.dual_ordSeparatingSet
-/

#print Set.ordT5Nhd /-
/-- An auxiliary neighborhood that will be used in the proof of `order_topology.t5_space`. -/
def ordT5Nhd (s t : Set α) : Set α :=
  ⋃ x ∈ s, ordConnectedComponent (tᶜ ∩ (ordConnectedSection <| ordSeparatingSet s t)ᶜ) x
#align set.ord_t5_nhd Set.ordT5Nhd
-/

#print Set.disjoint_ordT5Nhd /-
theorem disjoint_ordT5Nhd : Disjoint (ordT5Nhd s t) (ordT5Nhd t s) :=
  by
  rw [disjoint_iff_inf_le]
  rintro x ⟨hx₁, hx₂⟩
  rcases mem_Union₂.1 hx₁ with ⟨a, has, ha⟩; clear hx₁
  rcases mem_Union₂.1 hx₂ with ⟨b, hbt, hb⟩; clear hx₂
  rw [mem_ord_connected_component, subset_inter_iff] at ha hb 
  wlog hab : a ≤ b
  · exact this b hbt a has ha hb (le_of_not_le hab)
  cases' ha with ha ha'; cases' hb with hb hb'
  have hsub : [a, b] ⊆ (ord_separating_set s t).ordConnectedSectionᶜ :=
    by
    rw [ord_separating_set_comm, uIcc_comm] at hb' 
    calc
      [a, b] ⊆ [a, x] ∪ [x, b] := uIcc_subset_uIcc_union_uIcc
      _ ⊆ (ord_separating_set s t).ordConnectedSectionᶜ := union_subset ha' hb'
  clear ha' hb'
  cases' le_total x a with hxa hax
  · exact hb (Icc_subset_uIcc' ⟨hxa, hab⟩) has
  cases' le_total b x with hbx hxb
  · exact ha (Icc_subset_uIcc ⟨hab, hbx⟩) hbt
  have : x ∈ ord_separating_set s t := ⟨mem_Union₂.2 ⟨a, has, ha⟩, mem_Union₂.2 ⟨b, hbt, hb⟩⟩
  lift x to ord_separating_set s t using this
  suffices : ord_connected_component (ord_separating_set s t) x ⊆ [a, b]
  exact hsub (this <| ord_connected_proj_mem_ord_connected_component _ _) (mem_range_self _)
  rintro y (hy : [↑x, y] ⊆ ord_separating_set s t)
  rw [uIcc_of_le hab, mem_Icc, ← not_lt, ← not_lt]
  exact
    ⟨fun hya =>
      disjoint_left.1 disjoint_left_ord_separating_set has (hy <| Icc_subset_uIcc' ⟨hya.le, hax⟩),
      fun hyb =>
      disjoint_left.1 disjoint_right_ord_separating_set hbt (hy <| Icc_subset_uIcc ⟨hxb, hyb.le⟩)⟩
#align set.disjoint_ord_t5_nhd Set.disjoint_ordT5Nhd
-/

end Set

