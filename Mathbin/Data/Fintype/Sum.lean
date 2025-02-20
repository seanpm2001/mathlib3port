/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.fintype.sum
! leanprover-community/mathlib commit 6623e6af705e97002a9054c1c05a980180276fc1
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Card
import Mathbin.Data.Finset.Sum
import Mathbin.Logic.Embedding.Set

/-!
## Instances

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We provide the `fintype` instance for the sum of two fintypes.
-/


universe u v

variable {α β : Type _}

open Finset

instance (α : Type u) (β : Type v) [Fintype α] [Fintype β] : Fintype (Sum α β)
    where
  elems := univ.disjSum univ
  complete := by rintro (_ | _) <;> simp

#print Finset.univ_disjSum_univ /-
@[simp]
theorem Finset.univ_disjSum_univ {α β : Type _} [Fintype α] [Fintype β] :
    univ.disjSum univ = (univ : Finset (Sum α β)) :=
  rfl
#align finset.univ_disj_sum_univ Finset.univ_disjSum_univ
-/

#print Fintype.card_sum /-
@[simp]
theorem Fintype.card_sum [Fintype α] [Fintype β] :
    Fintype.card (Sum α β) = Fintype.card α + Fintype.card β :=
  card_disjSum _ _
#align fintype.card_sum Fintype.card_sum
-/

#print fintypeOfFintypeNe /-
/-- If the subtype of all-but-one elements is a `fintype` then the type itself is a `fintype`. -/
def fintypeOfFintypeNe (a : α) (h : Fintype { b // b ≠ a }) : Fintype α :=
  Fintype.ofBijective (Sum.elim (coe : { b // b = a } → α) (coe : { b // b ≠ a } → α)) <| by
    classical exact (Equiv.sumCompl (· = a)).Bijective
#align fintype_of_fintype_ne fintypeOfFintypeNe
-/

#print image_subtype_ne_univ_eq_image_erase /-
theorem image_subtype_ne_univ_eq_image_erase [Fintype α] [DecidableEq β] (k : β) (b : α → β) :
    image (fun i : { a // b a ≠ k } => b ↑i) univ = (image b univ).eraseₓ k :=
  by
  apply subset_antisymm
  · rw [image_subset_iff]
    intro i _
    apply mem_erase_of_ne_of_mem i.2 (mem_image_of_mem _ (mem_univ _))
  · intro i hi
    rw [mem_image]
    rcases mem_image.1 (erase_subset _ _ hi) with ⟨a, _, ha⟩
    subst ha
    exact ⟨⟨a, ne_of_mem_erase hi⟩, mem_univ _, rfl⟩
#align image_subtype_ne_univ_eq_image_erase image_subtype_ne_univ_eq_image_erase
-/

#print image_subtype_univ_ssubset_image_univ /-
theorem image_subtype_univ_ssubset_image_univ [Fintype α] [DecidableEq β] (k : β) (b : α → β)
    (hk : k ∈ image b univ) (p : β → Prop) [DecidablePred p] (hp : ¬p k) :
    image (fun i : { a // p (b a) } => b ↑i) univ ⊂ image b univ :=
  by
  constructor
  · intro x hx
    rcases mem_image.1 hx with ⟨y, _, hy⟩
    exact hy ▸ mem_image_of_mem b (mem_univ y)
  · intro h
    rw [mem_image] at hk 
    rcases hk with ⟨k', _, hk'⟩; subst hk'
    have := h (mem_image_of_mem b (mem_univ k'))
    rw [mem_image] at this 
    rcases this with ⟨j, hj, hj'⟩
    exact hp (hj' ▸ j.2)
#align image_subtype_univ_ssubset_image_univ image_subtype_univ_ssubset_image_univ
-/

#print Finset.exists_equiv_extend_of_card_eq /-
/-- Any injection from a finset `s` in a fintype `α` to a finset `t` of the same cardinality as `α`
can be extended to a bijection between `α` and `t`. -/
theorem Finset.exists_equiv_extend_of_card_eq [Fintype α] [DecidableEq β] {t : Finset β}
    (hαt : Fintype.card α = t.card) {s : Finset α} {f : α → β} (hfst : s.image f ⊆ t)
    (hfs : Set.InjOn f s) : ∃ g : α ≃ t, ∀ i ∈ s, (g i : β) = f i := by
  classical
  induction' s using Finset.induction with a s has H generalizing f
  · obtain ⟨e⟩ : Nonempty (α ≃ ↥t) := by rwa [← Fintype.card_eq, Fintype.card_coe]
    use e
    simp
  have hfst' : Finset.image f s ⊆ t := (Finset.image_mono _ (s.subset_insert a)).trans hfst
  have hfs' : Set.InjOn f s := hfs.mono (s.subset_insert a)
  obtain ⟨g', hg'⟩ := H hfst' hfs'
  have hfat : f a ∈ t := hfst (mem_image_of_mem _ (s.mem_insert_self a))
  use g'.trans (Equiv.swap (⟨f a, hfat⟩ : t) (g' a))
  simp_rw [mem_insert]
  rintro i (rfl | hi)
  · simp
  rw [Equiv.trans_apply, Equiv.swap_apply_of_ne_of_ne, hg' _ hi]
  ·
    exact
      ne_of_apply_ne Subtype.val
        (ne_of_eq_of_ne (hg' _ hi) <|
          hfs.ne (subset_insert _ _ hi) (mem_insert_self _ _) <| ne_of_mem_of_not_mem hi has)
  · exact g'.injective.ne (ne_of_mem_of_not_mem hi has)
#align finset.exists_equiv_extend_of_card_eq Finset.exists_equiv_extend_of_card_eq
-/

#print Set.MapsTo.exists_equiv_extend_of_card_eq /-
/-- Any injection from a set `s` in a fintype `α` to a finset `t` of the same cardinality as `α`
can be extended to a bijection between `α` and `t`. -/
theorem Set.MapsTo.exists_equiv_extend_of_card_eq [Fintype α] {t : Finset β}
    (hαt : Fintype.card α = t.card) {s : Set α} {f : α → β} (hfst : s.MapsTo f t)
    (hfs : Set.InjOn f s) : ∃ g : α ≃ t, ∀ i ∈ s, (g i : β) = f i := by
  classical
  let s' : Finset α := s.to_finset
  have hfst' : s'.image f ⊆ t := by simpa [← Finset.coe_subset] using hfst
  have hfs' : Set.InjOn f s' := by simpa using hfs
  obtain ⟨g, hg⟩ := Finset.exists_equiv_extend_of_card_eq hαt hfst' hfs'
  refine' ⟨g, fun i hi => _⟩
  apply hg
  simpa using hi
#align set.maps_to.exists_equiv_extend_of_card_eq Set.MapsTo.exists_equiv_extend_of_card_eq
-/

#print Fintype.card_subtype_or /-
theorem Fintype.card_subtype_or (p q : α → Prop) [Fintype { x // p x }] [Fintype { x // q x }]
    [Fintype { x // p x ∨ q x }] :
    Fintype.card { x // p x ∨ q x } ≤ Fintype.card { x // p x } + Fintype.card { x // q x } := by
  classical
  convert Fintype.card_le_of_embedding (subtypeOrLeftEmbedding p q)
  rw [Fintype.card_sum]
#align fintype.card_subtype_or Fintype.card_subtype_or
-/

#print Fintype.card_subtype_or_disjoint /-
theorem Fintype.card_subtype_or_disjoint (p q : α → Prop) (h : Disjoint p q) [Fintype { x // p x }]
    [Fintype { x // q x }] [Fintype { x // p x ∨ q x }] :
    Fintype.card { x // p x ∨ q x } = Fintype.card { x // p x } + Fintype.card { x // q x } := by
  classical
  convert Fintype.card_congr (subtypeOrEquiv p q h)
  simp
#align fintype.card_subtype_or_disjoint Fintype.card_subtype_or_disjoint
-/

section

open scoped Classical

#print infinite_sum /-
@[simp]
theorem infinite_sum : Infinite (Sum α β) ↔ Infinite α ∨ Infinite β :=
  by
  refine' ⟨fun H => _, fun H => H.elim (@Sum.infinite_of_left α β) (@Sum.infinite_of_right α β)⟩
  contrapose! H; haveI := fintypeOfNotInfinite H.1; haveI := fintypeOfNotInfinite H.2
  exact Infinite.false
#align infinite_sum infinite_sum
-/

end

