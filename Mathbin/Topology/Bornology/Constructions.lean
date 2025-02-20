/-
Copyright (c) 2022 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module topology.bornology.constructions
! leanprover-community/mathlib commit a11f9106a169dd302a285019e5165f8ab32ff433
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Bornology.Basic

/-!
# Bornology structure on products and subtypes

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `bornology` and `bounded_space` instances on `α × β`, `Π i, π i`, and
`{x // p x}`. We also prove basic lemmas about `bornology.cobounded` and `bornology.is_bounded`
on these types.
-/


open Set Filter Bornology Function

open scoped Filter

variable {α β ι : Type _} {π : ι → Type _} [Fintype ι] [Bornology α] [Bornology β]
  [∀ i, Bornology (π i)]

instance : Bornology (α × β)
    where
  cobounded := (cobounded α).coprod (cobounded β)
  le_cofinite :=
    @coprod_cofinite α β ▸ coprod_mono ‹Bornology α›.le_cofinite ‹Bornology β›.le_cofinite

instance : Bornology (∀ i, π i)
    where
  cobounded := Filter.coprodᵢ fun i => cobounded (π i)
  le_cofinite := @coprodᵢ_cofinite ι π _ ▸ Filter.coprodᵢ_mono fun i => Bornology.le_cofinite _

#print Bornology.induced /-
/-- Inverse image of a bornology. -/
@[reducible]
def Bornology.induced {α β : Type _} [Bornology β] (f : α → β) : Bornology α
    where
  cobounded := comap f (cobounded β)
  le_cofinite := (comap_mono (Bornology.le_cofinite β)).trans (comap_cofinite_le _)
#align bornology.induced Bornology.induced
-/

instance {p : α → Prop} : Bornology (Subtype p) :=
  Bornology.induced (coe : Subtype p → α)

namespace Bornology

/-!
### Bounded sets in `α × β`
-/


#print Bornology.cobounded_prod /-
theorem cobounded_prod : cobounded (α × β) = (cobounded α).coprod (cobounded β) :=
  rfl
#align bornology.cobounded_prod Bornology.cobounded_prod
-/

#print Bornology.isBounded_image_fst_and_snd /-
theorem isBounded_image_fst_and_snd {s : Set (α × β)} :
    IsBounded (Prod.fst '' s) ∧ IsBounded (Prod.snd '' s) ↔ IsBounded s :=
  compl_mem_coprod.symm
#align bornology.is_bounded_image_fst_and_snd Bornology.isBounded_image_fst_and_snd
-/

variable {s : Set α} {t : Set β} {S : ∀ i, Set (π i)}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.IsBounded.fst_of_prod /-
theorem IsBounded.fst_of_prod (h : IsBounded (s ×ˢ t)) (ht : t.Nonempty) : IsBounded s :=
  fst_image_prod s ht ▸ (isBounded_image_fst_and_snd.2 h).1
#align bornology.is_bounded.fst_of_prod Bornology.IsBounded.fst_of_prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.IsBounded.snd_of_prod /-
theorem IsBounded.snd_of_prod (h : IsBounded (s ×ˢ t)) (hs : s.Nonempty) : IsBounded t :=
  snd_image_prod hs t ▸ (isBounded_image_fst_and_snd.2 h).2
#align bornology.is_bounded.snd_of_prod Bornology.IsBounded.snd_of_prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.IsBounded.prod /-
theorem IsBounded.prod (hs : IsBounded s) (ht : IsBounded t) : IsBounded (s ×ˢ t) :=
  isBounded_image_fst_and_snd.1
    ⟨hs.Subset <| fst_image_prod_subset _ _, ht.Subset <| snd_image_prod_subset _ _⟩
#align bornology.is_bounded.prod Bornology.IsBounded.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.isBounded_prod_of_nonempty /-
theorem isBounded_prod_of_nonempty (hne : Set.Nonempty (s ×ˢ t)) :
    IsBounded (s ×ˢ t) ↔ IsBounded s ∧ IsBounded t :=
  ⟨fun h => ⟨h.fst_of_prod hne.snd, h.snd_of_prod hne.fst⟩, fun h => h.1.Prod h.2⟩
#align bornology.is_bounded_prod_of_nonempty Bornology.isBounded_prod_of_nonempty
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.isBounded_prod /-
theorem isBounded_prod : IsBounded (s ×ˢ t) ↔ s = ∅ ∨ t = ∅ ∨ IsBounded s ∧ IsBounded t :=
  by
  rcases s.eq_empty_or_nonempty with (rfl | hs); · simp
  rcases t.eq_empty_or_nonempty with (rfl | ht); · simp
  simp only [hs.ne_empty, ht.ne_empty, is_bounded_prod_of_nonempty (hs.prod ht), false_or_iff]
#align bornology.is_bounded_prod Bornology.isBounded_prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Bornology.isBounded_prod_self /-
theorem isBounded_prod_self : IsBounded (s ×ˢ s) ↔ IsBounded s :=
  by
  rcases s.eq_empty_or_nonempty with (rfl | hs); · simp
  exact (is_bounded_prod_of_nonempty (hs.prod hs)).trans (and_self_iff _)
#align bornology.is_bounded_prod_self Bornology.isBounded_prod_self
-/

/-!
### Bounded sets in `Π i, π i`
-/


#print Bornology.cobounded_pi /-
theorem cobounded_pi : cobounded (∀ i, π i) = Filter.coprodᵢ fun i => cobounded (π i) :=
  rfl
#align bornology.cobounded_pi Bornology.cobounded_pi
-/

#print Bornology.forall_isBounded_image_eval_iff /-
theorem forall_isBounded_image_eval_iff {s : Set (∀ i, π i)} :
    (∀ i, IsBounded (eval i '' s)) ↔ IsBounded s :=
  compl_mem_coprodᵢ.symm
#align bornology.forall_is_bounded_image_eval_iff Bornology.forall_isBounded_image_eval_iff
-/

#print Bornology.IsBounded.pi /-
theorem IsBounded.pi (h : ∀ i, IsBounded (S i)) : IsBounded (pi univ S) :=
  forall_isBounded_image_eval_iff.1 fun i => (h i).Subset eval_image_univ_pi_subset
#align bornology.is_bounded.pi Bornology.IsBounded.pi
-/

#print Bornology.isBounded_pi_of_nonempty /-
theorem isBounded_pi_of_nonempty (hne : (pi univ S).Nonempty) :
    IsBounded (pi univ S) ↔ ∀ i, IsBounded (S i) :=
  ⟨fun H i => @eval_image_univ_pi _ _ _ i hne ▸ forall_isBounded_image_eval_iff.2 H i, IsBounded.pi⟩
#align bornology.is_bounded_pi_of_nonempty Bornology.isBounded_pi_of_nonempty
-/

#print Bornology.isBounded_pi /-
theorem isBounded_pi : IsBounded (pi univ S) ↔ (∃ i, S i = ∅) ∨ ∀ i, IsBounded (S i) :=
  by
  by_cases hne : ∃ i, S i = ∅
  · simp [hne, univ_pi_eq_empty_iff.2 hne]
  · simp only [hne, false_or_iff]
    simp only [not_exists, ← Ne.def, ← nonempty_iff_ne_empty, ← univ_pi_nonempty_iff] at hne 
    exact is_bounded_pi_of_nonempty hne
#align bornology.is_bounded_pi Bornology.isBounded_pi
-/

/-!
### Bounded sets in `{x // p x}`
-/


#print Bornology.isBounded_induced /-
theorem isBounded_induced {α β : Type _} [Bornology β] {f : α → β} {s : Set α} :
    @IsBounded α (Bornology.induced f) s ↔ IsBounded (f '' s) :=
  compl_mem_comap
#align bornology.is_bounded_induced Bornology.isBounded_induced
-/

#print Bornology.isBounded_image_subtype_val /-
theorem isBounded_image_subtype_val {p : α → Prop} {s : Set { x // p x }} :
    IsBounded (coe '' s : Set α) ↔ IsBounded s :=
  isBounded_induced.symm
#align bornology.is_bounded_image_subtype_coe Bornology.isBounded_image_subtype_val
-/

end Bornology

/-!
### Bounded spaces
-/


open Bornology

instance [BoundedSpace α] [BoundedSpace β] : BoundedSpace (α × β) := by
  simp [← cobounded_eq_bot_iff, cobounded_prod]

instance [∀ i, BoundedSpace (π i)] : BoundedSpace (∀ i, π i) := by
  simp [← cobounded_eq_bot_iff, cobounded_pi]

#print boundedSpace_induced_iff /-
theorem boundedSpace_induced_iff {α β : Type _} [Bornology β] {f : α → β} :
    @BoundedSpace α (Bornology.induced f) ↔ IsBounded (range f) := by
  rw [← is_bounded_univ, is_bounded_induced, image_univ]
#align bounded_space_induced_iff boundedSpace_induced_iff
-/

#print boundedSpace_subtype_iff /-
theorem boundedSpace_subtype_iff {p : α → Prop} : BoundedSpace (Subtype p) ↔ IsBounded {x | p x} :=
  by rw [boundedSpace_induced_iff, Subtype.range_coe_subtype]
#align bounded_space_subtype_iff boundedSpace_subtype_iff
-/

#print boundedSpace_val_set_iff /-
theorem boundedSpace_val_set_iff {s : Set α} : BoundedSpace s ↔ IsBounded s :=
  boundedSpace_subtype_iff
#align bounded_space_coe_set_iff boundedSpace_val_set_iff
-/

alias boundedSpace_subtype_iff ↔ _ Bornology.IsBounded.boundedSpace_subtype
#align bornology.is_bounded.bounded_space_subtype Bornology.IsBounded.boundedSpace_subtype

alias boundedSpace_val_set_iff ↔ _ Bornology.IsBounded.boundedSpace_val
#align bornology.is_bounded.bounded_space_coe Bornology.IsBounded.boundedSpace_val

instance [BoundedSpace α] {p : α → Prop} : BoundedSpace (Subtype p) :=
  (IsBounded.all {x | p x}).boundedSpace_subtype

/-!
### `additive`, `multiplicative`

The bornology on those type synonyms is inherited without change.
-/


instance : Bornology (Additive α) :=
  ‹Bornology α›

instance : Bornology (Multiplicative α) :=
  ‹Bornology α›

instance [BoundedSpace α] : BoundedSpace (Additive α) :=
  ‹BoundedSpace α›

instance [BoundedSpace α] : BoundedSpace (Multiplicative α) :=
  ‹BoundedSpace α›

/-!
### Order dual

The bornology on this type synonym is inherited without change.
-/


instance : Bornology αᵒᵈ :=
  ‹Bornology α›

instance [BoundedSpace α] : BoundedSpace αᵒᵈ :=
  ‹BoundedSpace α›

