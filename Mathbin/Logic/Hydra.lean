/-
Copyright (c) 2022 Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Junyan Xu

! This file was ported from Lean 3 source module logic.hydra
! leanprover-community/mathlib commit d64d67d000b974f0d86a2be7918cf800be6271c8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finsupp.Lex
import Mathbin.Data.Finsupp.Multiset
import Mathbin.Order.GameAdd

/-!
# Termination of a hydra game

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file deals with the following version of the hydra game: each head of the hydra is
labelled by an element in a type `α`, and when you cut off one head with label `a`, it
grows back an arbitrary but finite number of heads, all labelled by elements smaller than
`a` with respect to a well-founded relation `r` on `α`. We show that no matter how (in
what order) you choose cut off the heads, the game always terminates, i.e. all heads will
eventually be cut off (but of course it can last arbitrarily long, i.e. takes an
arbitrary finite number of steps).

This result is stated as the well-foundedness of the `cut_expand` relation defined in
this file: we model the heads of the hydra as a multiset of elements of `α`, and the
valid "moves" of the game are modelled by the relation `cut_expand r` on `multiset α`:
`cut_expand r s' s` is true iff `s'` is obtained by removing one head `a ∈ s` and
adding back an arbitrary multiset `t` of heads such that all `a' ∈ t` satisfy `r a' a`.

We follow the proof by Peter LeFanu Lumsdaine at https://mathoverflow.net/a/229084/3332.

TODO: formalize the relations corresponding to more powerful (e.g. Kirby–Paris and Buchholz)
hydras, and prove their well-foundedness.
-/


namespace Relation

open Multiset Prod

variable {α : Type _}

#print Relation.CutExpand /-
/-- The relation that specifies valid moves in our hydra game. `cut_expand r s' s`
  means that `s'` is obtained by removing one head `a ∈ s` and adding back an arbitrary
  multiset `t` of heads such that all `a' ∈ t` satisfy `r a' a`.

  This is most directly translated into `s' = s.erase a + t`, but `multiset.erase` requires
  `decidable_eq α`, so we use the equivalent condition `s' + {a} = s + t` instead, which
  is also easier to verify for explicit multisets `s'`, `s` and `t`.

  We also don't include the condition `a ∈ s` because `s' + {a} = s + t` already
  guarantees `a ∈ s + t`, and if `r` is irreflexive then `a ∉ t`, which is the
  case when `r` is well-founded, the case we are primarily interested in.

  The lemma `relation.cut_expand_iff` below converts between this convenient definition
  and the direct translation when `r` is irreflexive. -/
def CutExpand (r : α → α → Prop) (s' s : Multiset α) : Prop :=
  ∃ (t : Multiset α) (a : α), (∀ a' ∈ t, r a' a) ∧ s' + {a} = s + t
#align relation.cut_expand Relation.CutExpand
-/

variable {r : α → α → Prop}

#print Relation.cutExpand_le_invImage_lex /-
theorem cutExpand_le_invImage_lex [hi : IsIrrefl α r] :
    CutExpand r ≤ InvImage (Finsupp.Lex (rᶜ ⊓ (· ≠ ·)) (· < ·)) toFinsupp :=
  fun s t ⟨u, a, hr, he⟩ => by
  classical
  refine' ⟨a, fun b h => _, _⟩ <;> simp_rw [to_finsupp_apply]
  · apply_fun count b at he ; simp_rw [count_add] at he 
    convert he <;> convert (add_zero _).symm <;> rw [count_eq_zero] <;> intro hb
    exacts [h.2 (mem_singleton.1 hb), h.1 (hr b hb)]
  · apply_fun count a at he ; simp_rw [count_add, count_singleton_self] at he 
    apply Nat.lt_of_succ_le; convert he.le; convert (add_zero _).symm
    exact count_eq_zero.2 fun ha => hi.irrefl a <| hr a ha
#align relation.cut_expand_le_inv_image_lex Relation.cutExpand_le_invImage_lex
-/

#print Relation.cutExpand_singleton /-
theorem cutExpand_singleton {s x} (h : ∀ x' ∈ s, r x' x) : CutExpand r s {x} :=
  ⟨s, x, h, add_comm s _⟩
#align relation.cut_expand_singleton Relation.cutExpand_singleton
-/

#print Relation.cutExpand_singleton_singleton /-
theorem cutExpand_singleton_singleton {x' x} (h : r x' x) : CutExpand r {x'} {x} :=
  cutExpand_singleton fun a h => by rwa [mem_singleton.1 h]
#align relation.cut_expand_singleton_singleton Relation.cutExpand_singleton_singleton
-/

#print Relation.cutExpand_add_left /-
theorem cutExpand_add_left {t u} (s) : CutExpand r (s + t) (s + u) ↔ CutExpand r t u :=
  exists₂_congr fun _ _ => and_congr Iff.rfl <| by rw [add_assoc, add_assoc, add_left_cancel_iff]
#align relation.cut_expand_add_left Relation.cutExpand_add_left
-/

#print Relation.cutExpand_iff /-
theorem cutExpand_iff [DecidableEq α] [IsIrrefl α r] {s' s : Multiset α} :
    CutExpand r s' s ↔
      ∃ (t : Multiset α) (a : _), (∀ a' ∈ t, r a' a) ∧ a ∈ s ∧ s' = s.eraseₓ a + t :=
  by
  simp_rw [cut_expand, add_singleton_eq_iff]
  refine' exists₂_congr fun t a => ⟨_, _⟩
  · rintro ⟨ht, ha, rfl⟩
    obtain h | h := mem_add.1 ha
    exacts [⟨ht, h, t.erase_add_left_pos h⟩, (@irrefl α r _ a (ht a h)).elim]
  · rintro ⟨ht, h, rfl⟩
    exact ⟨ht, mem_add.2 (Or.inl h), (t.erase_add_left_pos h).symm⟩
#align relation.cut_expand_iff Relation.cutExpand_iff
-/

#print Relation.not_cutExpand_zero /-
theorem not_cutExpand_zero [IsIrrefl α r] (s) : ¬CutExpand r s 0 := by
  classical
  rw [cut_expand_iff]
  rintro ⟨_, _, _, ⟨⟩, _⟩
#align relation.not_cut_expand_zero Relation.not_cutExpand_zero
-/

#print Relation.cutExpand_fibration /-
/-- For any relation `r` on `α`, multiset addition `multiset α × multiset α → multiset α` is a
  fibration between the game sum of `cut_expand r` with itself and `cut_expand r` itself. -/
theorem cutExpand_fibration (r : α → α → Prop) :
    Fibration (GameAdd (CutExpand r) (CutExpand r)) (CutExpand r) fun s => s.1 + s.2 :=
  by
  rintro ⟨s₁, s₂⟩ s ⟨t, a, hr, he⟩; dsimp at he ⊢
  classical
  obtain ⟨ha, rfl⟩ := add_singleton_eq_iff.1 he
  rw [add_assoc, mem_add] at ha 
  obtain h | h := ha
  · refine' ⟨(s₁.erase a + t, s₂), game_add.fst ⟨t, a, hr, _⟩, _⟩
    · rw [add_comm, ← add_assoc, singleton_add, cons_erase h]
    · rw [add_assoc s₁, erase_add_left_pos _ h, add_right_comm, add_assoc]
  · refine' ⟨(s₁, (s₂ + t).eraseₓ a), game_add.snd ⟨t, a, hr, _⟩, _⟩
    · rw [add_comm, singleton_add, cons_erase h]
    · rw [add_assoc, erase_add_right_pos _ h]
#align relation.cut_expand_fibration Relation.cutExpand_fibration
-/

#print Relation.acc_of_singleton /-
/-- A multiset is accessible under `cut_expand` if all its singleton subsets are,
  assuming `r` is irreflexive. -/
theorem acc_of_singleton [IsIrrefl α r] {s : Multiset α} :
    (∀ a ∈ s, Acc (CutExpand r) {a}) → Acc (CutExpand r) s :=
  by
  refine' Multiset.induction _ _ s
  · exact fun _ => Acc.intro 0 fun s h => (not_cut_expand_zero s h).elim
  · intro a s ih hacc; rw [← s.singleton_add a]
    exact
      ((hacc a <| s.mem_cons_self a).prod_gameAdd <|
            ih fun a ha => hacc a <| mem_cons_of_mem ha).of_fibration
        _ (cut_expand_fibration r)
#align relation.acc_of_singleton Relation.acc_of_singleton
-/

#print Acc.cutExpand /-
/-- A singleton `{a}` is accessible under `cut_expand r` if `a` is accessible under `r`,
  assuming `r` is irreflexive. -/
theorem Acc.cutExpand [IsIrrefl α r] {a : α} (hacc : Acc r a) : Acc (CutExpand r) {a} :=
  by
  induction' hacc with a h ih
  refine' Acc.intro _ fun s => _
  classical
  rw [cut_expand_iff]
  rintro ⟨t, a, hr, rfl | ⟨⟨⟩⟩, rfl⟩
  refine' acc_of_singleton fun a' => _
  rw [erase_singleton, zero_add]
  exact ih a' ∘ hr a'
#align acc.cut_expand Acc.cutExpand
-/

#print WellFounded.cutExpand /-
/-- `cut_expand r` is well-founded when `r` is. -/
theorem WellFounded.cutExpand (hr : WellFounded r) : WellFounded (CutExpand r) :=
  ⟨letI h := hr.is_irrefl
    fun s => acc_of_singleton fun a _ => (hr.apply a).CutExpand⟩
#align well_founded.cut_expand WellFounded.cutExpand
-/

end Relation

