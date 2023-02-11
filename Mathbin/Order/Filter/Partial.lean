/-
Copyright (c) 2019 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module order.filter.partial
! leanprover-community/mathlib commit dc6c365e751e34d100e80fe6e314c3c3e0fd2988
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Filter.Basic
import Mathbin.Data.Pfun

/-!
# `tendsto` for relations and partial functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file generalizes `filter` definitions from functions to partial functions and relations.

## Considering functions and partial functions as relations

A function `f : α → β` can be considered as the relation `rel α β` which relates `x` and `f x` for
all `x`, and nothing else. This relation is called `function.graph f`.

A partial function `f : α →. β` can be considered as the relation `rel α β` which relates `x` and
`f x` for all `x` for which `f x` exists, and nothing else. This relation is called
`pfun.graph' f`.

In this regard, a function is a relation for which every element in `α` is related to exactly one
element in `β` and a partial function is a relation for which every element in `α` is related to at
most one element in `β`.

This file leverages this analogy to generalize `filter` definitions from functions to partial
functions and relations.

## Notes

`set.preimage` can be generalized to relations in two ways:
* `rel.preimage` returns the image of the set under the inverse relation.
* `rel.core` returns the set of elements that are only related to those in the set.
Both generalizations are sensible in the context of filters, so `filter.comap` and `filter.tendsto`
get two generalizations each.

We first take care of relations. Then the definitions for partial functions are taken as special
cases of the definitions for relations.
-/


universe u v w

namespace Filter

variable {α : Type u} {β : Type v} {γ : Type w}

open Filter

/-! ### Relations -/


#print Filter.rmap /-
/-- The forward map of a filter under a relation. Generalization of `filter.map` to relations. Note
that `rel.core` generalizes `set.preimage`. -/
def rmap (r : Rel α β) (l : Filter α) : Filter β
    where
  sets := { s | r.core s ∈ l }
  univ_sets := by simp
  sets_of_superset s t hs st := mem_of_superset hs <| Rel.core_mono _ st
  inter_sets s t hs ht := by simp [Rel.core_inter, inter_mem hs ht]
#align filter.rmap Filter.rmap
-/

#print Filter.rmap_sets /-
theorem rmap_sets (r : Rel α β) (l : Filter α) : (l.rmap r).sets = r.core ⁻¹' l.sets :=
  rfl
#align filter.rmap_sets Filter.rmap_sets
-/

#print Filter.mem_rmap /-
@[simp]
theorem mem_rmap (r : Rel α β) (l : Filter α) (s : Set β) : s ∈ l.rmap r ↔ r.core s ∈ l :=
  Iff.rfl
#align filter.mem_rmap Filter.mem_rmap
-/

#print Filter.rmap_rmap /-
@[simp]
theorem rmap_rmap (r : Rel α β) (s : Rel β γ) (l : Filter α) :
    rmap s (rmap r l) = rmap (r.comp s) l :=
  filter_eq <| by simp [rmap_sets, Set.preimage, Rel.core_comp]
#align filter.rmap_rmap Filter.rmap_rmap
-/

#print Filter.rmap_compose /-
@[simp]
theorem rmap_compose (r : Rel α β) (s : Rel β γ) : rmap s ∘ rmap r = rmap (r.comp s) :=
  funext <| rmap_rmap _ _
#align filter.rmap_compose Filter.rmap_compose
-/

#print Filter.Rtendsto /-
/-- Generic "limit of a relation" predicate. `rtendsto r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `r`-core of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to relations. -/
def Rtendsto (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁.rmap r ≤ l₂
#align filter.rtendsto Filter.Rtendsto
-/

#print Filter.rtendsto_def /-
theorem rtendsto_def (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :
    Rtendsto r l₁ l₂ ↔ ∀ s ∈ l₂, r.core s ∈ l₁ :=
  Iff.rfl
#align filter.rtendsto_def Filter.rtendsto_def
-/

#print Filter.rcomap /-
/-- One way of taking the inverse map of a filter under a relation. One generalization of
`filter.comap` to relations. Note that `rel.core` generalizes `set.preimage`. -/
def rcomap (r : Rel α β) (f : Filter β) : Filter α
    where
  sets := Rel.image (fun s t => r.core s ⊆ t) f.sets
  univ_sets := ⟨Set.univ, univ_mem, Set.subset_univ _⟩
  sets_of_superset := fun a b ⟨a', ha', ma'a⟩ ab => ⟨a', ha', ma'a.trans ab⟩
  inter_sets := fun a b ⟨a', ha₁, ha₂⟩ ⟨b', hb₁, hb₂⟩ =>
    ⟨a' ∩ b', inter_mem ha₁ hb₁, (r.core_inter a' b').Subset.trans (Set.inter_subset_inter ha₂ hb₂)⟩
#align filter.rcomap Filter.rcomap
-/

#print Filter.rcomap_sets /-
theorem rcomap_sets (r : Rel α β) (f : Filter β) :
    (rcomap r f).sets = Rel.image (fun s t => r.core s ⊆ t) f.sets :=
  rfl
#align filter.rcomap_sets Filter.rcomap_sets
-/

#print Filter.rcomap_rcomap /-
theorem rcomap_rcomap (r : Rel α β) (s : Rel β γ) (l : Filter γ) :
    rcomap r (rcomap s l) = rcomap (r.comp s) l :=
  filter_eq <| by
    ext t; simp [rcomap_sets, Rel.image, Rel.core_comp]; constructor
    · rintro ⟨u, ⟨v, vsets, hv⟩, h⟩
      exact ⟨v, vsets, Set.Subset.trans (Rel.core_mono _ hv) h⟩
    rintro ⟨t, tsets, ht⟩
    exact ⟨Rel.core s t, ⟨t, tsets, Set.Subset.rfl⟩, ht⟩
#align filter.rcomap_rcomap Filter.rcomap_rcomap
-/

#print Filter.rcomap_compose /-
@[simp]
theorem rcomap_compose (r : Rel α β) (s : Rel β γ) : rcomap r ∘ rcomap s = rcomap (r.comp s) :=
  funext <| rcomap_rcomap _ _
#align filter.rcomap_compose Filter.rcomap_compose
-/

/- warning: filter.rtendsto_iff_le_rcomap -> Filter.rtendsto_iff_le_rcomap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (r : Rel.{u1, u2} α β) (l₁ : Filter.{u1} α) (l₂ : Filter.{u2} β), Iff (Filter.Rtendsto.{u1, u2} α β r l₁ l₂) (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.partialOrder.{u1} α))) l₁ (Filter.rcomap.{u1, u2} α β r l₂))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} (r : Rel.{u1, u2} α β) (l₁ : Filter.{u1} α) (l₂ : Filter.{u2} β), Iff (Filter.Rtendsto.{u1, u2} α β r l₁ l₂) (LE.le.{u1} (Filter.{u1} α) (Preorder.toLE.{u1} (Filter.{u1} α) (PartialOrder.toPreorder.{u1} (Filter.{u1} α) (Filter.instPartialOrderFilter.{u1} α))) l₁ (Filter.rcomap.{u1, u2} α β r l₂))
Case conversion may be inaccurate. Consider using '#align filter.rtendsto_iff_le_rcomap Filter.rtendsto_iff_le_rcomapₓ'. -/
theorem rtendsto_iff_le_rcomap (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :
    Rtendsto r l₁ l₂ ↔ l₁ ≤ l₂.rcomap r :=
  by
  rw [rtendsto_def]
  change (∀ s : Set β, s ∈ l₂.sets → r.core s ∈ l₁) ↔ l₁ ≤ rcomap r l₂
  simp [Filter.le_def, rcomap, Rel.mem_image]; constructor
  · exact fun h s t tl₂ => mem_of_superset (h t tl₂)
  · exact fun h t tl₂ => h _ t tl₂ Set.Subset.rfl
#align filter.rtendsto_iff_le_rcomap Filter.rtendsto_iff_le_rcomap

#print Filter.rcomap' /-
-- Interestingly, there does not seem to be a way to express this relation using a forward map.
-- Given a filter `f` on `α`, we want a filter `f'` on `β` such that `r.preimage s ∈ f` if
-- and only if `s ∈ f'`. But the intersection of two sets satisfying the lhs may be empty.
/-- One way of taking the inverse map of a filter under a relation. Generalization of `filter.comap`
to relations. -/
def rcomap' (r : Rel α β) (f : Filter β) : Filter α
    where
  sets := Rel.image (fun s t => r.Preimage s ⊆ t) f.sets
  univ_sets := ⟨Set.univ, univ_mem, Set.subset_univ _⟩
  sets_of_superset := fun a b ⟨a', ha', ma'a⟩ ab => ⟨a', ha', ma'a.trans ab⟩
  inter_sets := fun a b ⟨a', ha₁, ha₂⟩ ⟨b', hb₁, hb₂⟩ =>
    ⟨a' ∩ b', inter_mem ha₁ hb₁,
      (@Rel.preimage_inter _ _ r _ _).trans (Set.inter_subset_inter ha₂ hb₂)⟩
#align filter.rcomap' Filter.rcomap'
-/

/- warning: filter.mem_rcomap' -> Filter.mem_rcomap' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (r : Rel.{u1, u2} α β) (l : Filter.{u2} β) (s : Set.{u1} α), Iff (Membership.Mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (Filter.hasMem.{u1} α) s (Filter.rcomap'.{u1, u2} α β r l)) (Exists.{succ u2} (Set.{u2} β) (fun (t : Set.{u2} β) => Exists.{0} (Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) t l) (fun (H : Membership.Mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (Filter.hasMem.{u2} β) t l) => HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Rel.preimage.{u1, u2} α β r t) s)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} (r : Rel.{u1, u2} α β) (l : Filter.{u2} β) (s : Set.{u1} α), Iff (Membership.mem.{u1, u1} (Set.{u1} α) (Filter.{u1} α) (instMembershipSetFilter.{u1} α) s (Filter.rcomap'.{u1, u2} α β r l)) (Exists.{succ u2} (Set.{u2} β) (fun (t : Set.{u2} β) => And (Membership.mem.{u2, u2} (Set.{u2} β) (Filter.{u2} β) (instMembershipSetFilter.{u2} β) t l) (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet.{u1} α) (Rel.preimage.{u1, u2} α β r t) s)))
Case conversion may be inaccurate. Consider using '#align filter.mem_rcomap' Filter.mem_rcomap'ₓ'. -/
@[simp]
theorem mem_rcomap' (r : Rel α β) (l : Filter β) (s : Set α) :
    s ∈ l.rcomap' r ↔ ∃ t ∈ l, r.Preimage t ⊆ s :=
  Iff.rfl
#align filter.mem_rcomap' Filter.mem_rcomap'

#print Filter.rcomap'_sets /-
theorem rcomap'_sets (r : Rel α β) (f : Filter β) :
    (rcomap' r f).sets = Rel.image (fun s t => r.Preimage s ⊆ t) f.sets :=
  rfl
#align filter.rcomap'_sets Filter.rcomap'_sets
-/

#print Filter.rcomap'_rcomap' /-
@[simp]
theorem rcomap'_rcomap' (r : Rel α β) (s : Rel β γ) (l : Filter γ) :
    rcomap' r (rcomap' s l) = rcomap' (r.comp s) l :=
  Filter.ext fun t => by
    simp [rcomap'_sets, Rel.image, Rel.preimage_comp]; constructor
    · rintro ⟨u, ⟨v, vsets, hv⟩, h⟩
      exact ⟨v, vsets, (Rel.preimage_mono _ hv).trans h⟩
    rintro ⟨t, tsets, ht⟩
    exact ⟨s.preimage t, ⟨t, tsets, Set.Subset.rfl⟩, ht⟩
#align filter.rcomap'_rcomap' Filter.rcomap'_rcomap'
-/

#print Filter.rcomap'_compose /-
@[simp]
theorem rcomap'_compose (r : Rel α β) (s : Rel β γ) : rcomap' r ∘ rcomap' s = rcomap' (r.comp s) :=
  funext <| rcomap'_rcomap' _ _
#align filter.rcomap'_compose Filter.rcomap'_compose
-/

#print Filter.Rtendsto' /-
/-- Generic "limit of a relation" predicate. `rtendsto' r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `r`-preimage of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to relations. -/
def Rtendsto' (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁ ≤ l₂.rcomap' r
#align filter.rtendsto' Filter.Rtendsto'
-/

#print Filter.rtendsto'_def /-
theorem rtendsto'_def (r : Rel α β) (l₁ : Filter α) (l₂ : Filter β) :
    Rtendsto' r l₁ l₂ ↔ ∀ s ∈ l₂, r.Preimage s ∈ l₁ :=
  by
  unfold rtendsto' rcomap'; simp [le_def, Rel.mem_image]; constructor
  · exact fun h s hs => h _ _ hs Set.Subset.rfl
  · exact fun h s t ht => mem_of_superset (h t ht)
#align filter.rtendsto'_def Filter.rtendsto'_def
-/

#print Filter.tendsto_iff_rtendsto /-
theorem tendsto_iff_rtendsto (l₁ : Filter α) (l₂ : Filter β) (f : α → β) :
    Tendsto f l₁ l₂ ↔ Rtendsto (Function.graph f) l₁ l₂ := by
  simp [tendsto_def, Function.graph, rtendsto_def, Rel.core, Set.preimage]
#align filter.tendsto_iff_rtendsto Filter.tendsto_iff_rtendsto
-/

#print Filter.tendsto_iff_rtendsto' /-
theorem tendsto_iff_rtendsto' (l₁ : Filter α) (l₂ : Filter β) (f : α → β) :
    Tendsto f l₁ l₂ ↔ Rtendsto' (Function.graph f) l₁ l₂ := by
  simp [tendsto_def, Function.graph, rtendsto'_def, Rel.preimage_def, Set.preimage]
#align filter.tendsto_iff_rtendsto' Filter.tendsto_iff_rtendsto'
-/

/-! ### Partial functions -/


#print Filter.pmap /-
/-- The forward map of a filter under a partial function. Generalization of `filter.map` to partial
functions. -/
def pmap (f : α →. β) (l : Filter α) : Filter β :=
  Filter.rmap f.graph' l
#align filter.pmap Filter.pmap
-/

#print Filter.mem_pmap /-
@[simp]
theorem mem_pmap (f : α →. β) (l : Filter α) (s : Set β) : s ∈ l.pmap f ↔ f.core s ∈ l :=
  Iff.rfl
#align filter.mem_pmap Filter.mem_pmap
-/

#print Filter.Ptendsto /-
/-- Generic "limit of a partial function" predicate. `ptendsto r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `p`-core of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to partial function. -/
def Ptendsto (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁.pmap f ≤ l₂
#align filter.ptendsto Filter.Ptendsto
-/

#print Filter.ptendsto_def /-
theorem ptendsto_def (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :
    Ptendsto f l₁ l₂ ↔ ∀ s ∈ l₂, f.core s ∈ l₁ :=
  Iff.rfl
#align filter.ptendsto_def Filter.ptendsto_def
-/

#print Filter.ptendsto_iff_rtendsto /-
theorem ptendsto_iff_rtendsto (l₁ : Filter α) (l₂ : Filter β) (f : α →. β) :
    Ptendsto f l₁ l₂ ↔ Rtendsto f.graph' l₁ l₂ :=
  Iff.rfl
#align filter.ptendsto_iff_rtendsto Filter.ptendsto_iff_rtendsto
-/

/- warning: filter.pmap_res -> Filter.pmap_res is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (l : Filter.{u1} α) (s : Set.{u1} α) (f : α -> β), Eq.{succ u2} (Filter.{u2} β) (Filter.pmap.{u1, u2} α β (PFun.res.{u1, u2} α β f s) l) (Filter.map.{u1, u2} α β f (HasInf.inf.{u1} (Filter.{u1} α) (Filter.hasInf.{u1} α) l (Filter.principal.{u1} α s)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} (l : Filter.{u1} α) (s : Set.{u1} α) (f : α -> β), Eq.{succ u2} (Filter.{u2} β) (Filter.pmap.{u1, u2} α β (PFun.res.{u1, u2} α β f s) l) (Filter.map.{u1, u2} α β f (HasInf.inf.{u1} (Filter.{u1} α) (Filter.instHasInfFilter.{u1} α) l (Filter.principal.{u1} α s)))
Case conversion may be inaccurate. Consider using '#align filter.pmap_res Filter.pmap_resₓ'. -/
theorem pmap_res (l : Filter α) (s : Set α) (f : α → β) : pmap (PFun.res f s) l = map f (l ⊓ 𝓟 s) :=
  by
  ext t
  simp only [PFun.core_res, mem_pmap, mem_map, mem_inf_principal, imp_iff_not_or]
  rfl
#align filter.pmap_res Filter.pmap_res

/- warning: filter.tendsto_iff_ptendsto -> Filter.tendsto_iff_ptendsto is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (l₁ : Filter.{u1} α) (l₂ : Filter.{u2} β) (s : Set.{u1} α) (f : α -> β), Iff (Filter.Tendsto.{u1, u2} α β f (HasInf.inf.{u1} (Filter.{u1} α) (Filter.hasInf.{u1} α) l₁ (Filter.principal.{u1} α s)) l₂) (Filter.Ptendsto.{u1, u2} α β (PFun.res.{u1, u2} α β f s) l₁ l₂)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} (l₁ : Filter.{u1} α) (l₂ : Filter.{u2} β) (s : Set.{u1} α) (f : α -> β), Iff (Filter.Tendsto.{u1, u2} α β f (HasInf.inf.{u1} (Filter.{u1} α) (Filter.instHasInfFilter.{u1} α) l₁ (Filter.principal.{u1} α s)) l₂) (Filter.Ptendsto.{u1, u2} α β (PFun.res.{u1, u2} α β f s) l₁ l₂)
Case conversion may be inaccurate. Consider using '#align filter.tendsto_iff_ptendsto Filter.tendsto_iff_ptendstoₓ'. -/
theorem tendsto_iff_ptendsto (l₁ : Filter α) (l₂ : Filter β) (s : Set α) (f : α → β) :
    Tendsto f (l₁ ⊓ 𝓟 s) l₂ ↔ Ptendsto (PFun.res f s) l₁ l₂ := by
  simp only [tendsto, ptendsto, pmap_res]
#align filter.tendsto_iff_ptendsto Filter.tendsto_iff_ptendsto

#print Filter.tendsto_iff_ptendsto_univ /-
theorem tendsto_iff_ptendsto_univ (l₁ : Filter α) (l₂ : Filter β) (f : α → β) :
    Tendsto f l₁ l₂ ↔ Ptendsto (PFun.res f Set.univ) l₁ l₂ :=
  by
  rw [← tendsto_iff_ptendsto]
  simp [principal_univ]
#align filter.tendsto_iff_ptendsto_univ Filter.tendsto_iff_ptendsto_univ
-/

#print Filter.pcomap' /-
/-- Inverse map of a filter under a partial function. One generalization of `filter.comap` to
partial functions. -/
def pcomap' (f : α →. β) (l : Filter β) : Filter α :=
  Filter.rcomap' f.graph' l
#align filter.pcomap' Filter.pcomap'
-/

#print Filter.Ptendsto' /-
/-- Generic "limit of a partial function" predicate. `ptendsto' r l₁ l₂` asserts that for every
`l₂`-neighborhood `a`, the `p`-preimage of `a` is an `l₁`-neighborhood. One generalization of
`filter.tendsto` to partial functions. -/
def Ptendsto' (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :=
  l₁ ≤ l₂.rcomap' f.graph'
#align filter.ptendsto' Filter.Ptendsto'
-/

#print Filter.ptendsto'_def /-
theorem ptendsto'_def (f : α →. β) (l₁ : Filter α) (l₂ : Filter β) :
    Ptendsto' f l₁ l₂ ↔ ∀ s ∈ l₂, f.Preimage s ∈ l₁ :=
  rtendsto'_def _ _ _
#align filter.ptendsto'_def Filter.ptendsto'_def
-/

#print Filter.ptendsto_of_ptendsto' /-
theorem ptendsto_of_ptendsto' {f : α →. β} {l₁ : Filter α} {l₂ : Filter β} :
    Ptendsto' f l₁ l₂ → Ptendsto f l₁ l₂ :=
  by
  rw [ptendsto_def, ptendsto'_def]
  exact fun h s sl₂ => mem_of_superset (h s sl₂) (PFun.preimage_subset_core _ _)
#align filter.ptendsto_of_ptendsto' Filter.ptendsto_of_ptendsto'
-/

#print Filter.ptendsto'_of_ptendsto /-
theorem ptendsto'_of_ptendsto {f : α →. β} {l₁ : Filter α} {l₂ : Filter β} (h : f.Dom ∈ l₁) :
    Ptendsto f l₁ l₂ → Ptendsto' f l₁ l₂ :=
  by
  rw [ptendsto_def, ptendsto'_def]
  intro h' s sl₂
  rw [PFun.preimage_eq]
  exact inter_mem (h' s sl₂) h
#align filter.ptendsto'_of_ptendsto Filter.ptendsto'_of_ptendsto
-/

end Filter

