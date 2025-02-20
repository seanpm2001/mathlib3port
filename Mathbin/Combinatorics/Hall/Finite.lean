/-
Copyright (c) 2021 Alena Gusakov, Bhavik Mehta, Kyle Miller. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alena Gusakov, Bhavik Mehta, Kyle Miller

! This file was ported from Lean 3 source module combinatorics.hall.finite
! leanprover-community/mathlib commit 63f84d91dd847f50bae04a01071f3a5491934e36
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Basic
import Mathbin.Data.Set.Finite

/-!
# Hall's Marriage Theorem for finite index types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This module proves the basic form of Hall's theorem.
In constrast to the theorem described in `combinatorics.hall.basic`, this
version requires that the indexed family `t : ι → finset α` have `ι` be finite.
The `combinatorics.hall.basic` module applies a compactness argument to this version
to remove the `finite` constraint on `ι`.

The modules are split like this since the generalized statement
depends on the topology and category theory libraries, but the finite
case in this module has few dependencies.

A description of this formalization is in [Gusakov2021].

## Main statements

* `finset.all_card_le_bUnion_card_iff_exists_injective'` is Hall's theorem with
  a finite index set.  This is elsewhere generalized to
  `finset.all_card_le_bUnion_card_iff_exists_injective`.

## Tags

Hall's Marriage Theorem, indexed families
-/


open Finset

universe u v

namespace HallMarriageTheorem

variable {ι : Type u} {α : Type v} [DecidableEq α] {t : ι → Finset α}

section Fintype

variable [Fintype ι]

#print HallMarriageTheorem.hall_cond_of_erase /-
theorem hall_cond_of_erase {x : ι} (a : α)
    (ha : ∀ s : Finset ι, s.Nonempty → s ≠ univ → s.card < (s.biUnion t).card)
    (s' : Finset {x' : ι | x' ≠ x}) : s'.card ≤ (s'.biUnion fun x' => (t x').eraseₓ a).card :=
  by
  haveI := Classical.decEq ι
  specialize ha (s'.image coe)
  rw [nonempty.image_iff, Finset.card_image_of_injective s' Subtype.coe_injective] at ha 
  by_cases he : s'.nonempty
  · have ha' : s'.card < (s'.bUnion fun x => t x).card :=
      by
      convert ha he fun h => by simpa [← h] using mem_univ x using 2
      ext x
      simp only [mem_image, mem_bUnion, exists_prop, SetCoe.exists, exists_and_right,
        exists_eq_right, Subtype.coe_mk]
    rw [← erase_bUnion]
    by_cases hb : a ∈ s'.bUnion fun x => t x
    · rw [card_erase_of_mem hb]
      exact Nat.le_pred_of_lt ha'
    · rw [erase_eq_of_not_mem hb]
      exact Nat.le_of_lt ha'
  · rw [nonempty_iff_ne_empty, Classical.not_not] at he 
    subst s'
    simp
#align hall_marriage_theorem.hall_cond_of_erase HallMarriageTheorem.hall_cond_of_erase
-/

#print HallMarriageTheorem.hall_hard_inductive_step_A /-
/-- First case of the inductive step: assuming that
`∀ (s : finset ι), s.nonempty → s ≠ univ → s.card < (s.bUnion t).card`
and that the statement of **Hall's Marriage Theorem** is true for all
`ι'` of cardinality ≤ `n`, then it is true for `ι` of cardinality `n + 1`.
-/
theorem hall_hard_inductive_step_A {n : ℕ} (hn : Fintype.card ι = n + 1)
    (ht : ∀ s : Finset ι, s.card ≤ (s.biUnion t).card)
    (ih :
      ∀ {ι' : Type u} [Fintype ι'] (t' : ι' → Finset α),
        Fintype.card ι' ≤ n →
          (∀ s' : Finset ι', s'.card ≤ (s'.biUnion t').card) →
            ∃ f : ι' → α, Function.Injective f ∧ ∀ x, f x ∈ t' x)
    (ha : ∀ s : Finset ι, s.Nonempty → s ≠ univ → s.card < (s.biUnion t).card) :
    ∃ f : ι → α, Function.Injective f ∧ ∀ x, f x ∈ t x :=
  by
  haveI : Nonempty ι := fintype.card_pos_iff.mp (hn.symm ▸ Nat.succ_pos _)
  haveI := Classical.decEq ι
  -- Choose an arbitrary element `x : ι` and `y : t x`.
  let x := Classical.arbitrary ι
  have tx_ne : (t x).Nonempty := by
    rw [← Finset.card_pos]
    calc
      0 < 1 := Nat.one_pos
      _ ≤ (Finset.biUnion {x} t).card := (ht {x})
      _ = (t x).card := by rw [Finset.singleton_biUnion]
  choose y hy using tx_ne
  -- Restrict to everything except `x` and `y`.
  let ι' := {x' : ι | x' ≠ x}
  let t' : ι' → Finset α := fun x' => (t x').eraseₓ y
  have card_ι' : Fintype.card ι' = n :=
    calc
      Fintype.card ι' = Fintype.card ι - 1 := Set.card_ne_eq _
      _ = n := by rw [hn, Nat.add_succ_sub_one, add_zero]
  rcases ih t' card_ι'.le (hall_cond_of_erase y ha) with ⟨f', hfinj, hfr⟩
  -- Extend the resulting function.
  refine' ⟨fun z => if h : z = x then y else f' ⟨z, h⟩, _, _⟩
  · rintro z₁ z₂
    have key : ∀ {x}, y ≠ f' x := by
      intro x h
      simpa [← h] using hfr x
    by_cases h₁ : z₁ = x <;> by_cases h₂ : z₂ = x <;> simp [h₁, h₂, hfinj.eq_iff, key, key.symm]
  · intro z
    split_ifs with hz
    · rwa [hz]
    · specialize hfr ⟨z, hz⟩
      rw [mem_erase] at hfr 
      exact hfr.2
#align hall_marriage_theorem.hall_hard_inductive_step_A HallMarriageTheorem.hall_hard_inductive_step_A
-/

#print HallMarriageTheorem.hall_cond_of_restrict /-
theorem hall_cond_of_restrict {ι : Type u} {t : ι → Finset α} {s : Finset ι}
    (ht : ∀ s : Finset ι, s.card ≤ (s.biUnion t).card) (s' : Finset (s : Set ι)) :
    s'.card ≤ (s'.biUnion fun a' => t a').card := by
  classical
  rw [← card_image_of_injective s' Subtype.coe_injective]
  convert ht (s'.image coe) using 1
  apply congr_arg
  ext y
  simp
#align hall_marriage_theorem.hall_cond_of_restrict HallMarriageTheorem.hall_cond_of_restrict
-/

#print HallMarriageTheorem.hall_cond_of_compl /-
theorem hall_cond_of_compl {ι : Type u} {t : ι → Finset α} {s : Finset ι}
    (hus : s.card = (s.biUnion t).card) (ht : ∀ s : Finset ι, s.card ≤ (s.biUnion t).card)
    (s' : Finset (sᶜ : Set ι)) : s'.card ≤ (s'.biUnion fun x' => t x' \ s.biUnion t).card :=
  by
  haveI := Classical.decEq ι
  have disj : Disjoint s (s'.image coe) :=
    by
    simp only [disjoint_left, not_exists, mem_image, exists_prop, SetCoe.exists, exists_and_right,
      exists_eq_right, Subtype.coe_mk]
    intro x hx hc h
    exact absurd hx hc
  have : s'.card = (s ∪ s'.image coe).card - s.card := by
    simp [disj, card_image_of_injective _ Subtype.coe_injective]
  rw [this, hus]
  refine' (tsub_le_tsub_right (ht _) _).trans _
  rw [← card_sdiff]
  · refine' (card_le_of_subset _).trans le_rfl
    intro t
    simp only [mem_bUnion, mem_sdiff, not_exists, mem_image, and_imp, mem_union, exists_and_right,
      exists_imp]
    rintro x (hx | ⟨x', hx', rfl⟩) rat hs
    · exact (hs x hx Rat).elim
    · exact ⟨⟨x', hx', Rat⟩, hs⟩
  · apply bUnion_subset_bUnion_of_subset_left
    apply subset_union_left
#align hall_marriage_theorem.hall_cond_of_compl HallMarriageTheorem.hall_cond_of_compl
-/

#print HallMarriageTheorem.hall_hard_inductive_step_B /-
/-- Second case of the inductive step: assuming that
`∃ (s : finset ι), s ≠ univ → s.card = (s.bUnion t).card`
and that the statement of **Hall's Marriage Theorem** is true for all
`ι'` of cardinality ≤ `n`, then it is true for `ι` of cardinality `n + 1`.
-/
theorem hall_hard_inductive_step_B {n : ℕ} (hn : Fintype.card ι = n + 1)
    (ht : ∀ s : Finset ι, s.card ≤ (s.biUnion t).card)
    (ih :
      ∀ {ι' : Type u} [Fintype ι'] (t' : ι' → Finset α),
        Fintype.card ι' ≤ n →
          (∀ s' : Finset ι', s'.card ≤ (s'.biUnion t').card) →
            ∃ f : ι' → α, Function.Injective f ∧ ∀ x, f x ∈ t' x)
    (s : Finset ι) (hs : s.Nonempty) (hns : s ≠ univ) (hus : s.card = (s.biUnion t).card) :
    ∃ f : ι → α, Function.Injective f ∧ ∀ x, f x ∈ t x :=
  by
  haveI := Classical.decEq ι
  -- Restrict to `s`
  let t' : s → Finset α := fun x' => t x'
  rw [Nat.add_one] at hn 
  have card_ι'_le : Fintype.card s ≤ n :=
    by
    apply Nat.le_of_lt_succ
    calc
      Fintype.card s = s.card := Fintype.card_coe _
      _ < Fintype.card ι := ((card_lt_iff_ne_univ _).mpr hns)
      _ = n.succ := hn
  rcases ih t' card_ι'_le (hall_cond_of_restrict ht) with ⟨f', hf', hsf'⟩
  -- Restrict to `sᶜ` in the domain and `(s.bUnion t)ᶜ` in the codomain.
  set ι'' := (s : Set ι)ᶜ with ι''_def
  let t'' : ι'' → Finset α := fun a'' => t a'' \ s.bUnion t
  have card_ι''_le : Fintype.card ι'' ≤ n :=
    by
    simp_rw [← Nat.lt_succ_iff, ← hn, ι'', ← Finset.coe_compl, coe_sort_coe]
    rwa [Fintype.card_coe, card_compl_lt_iff_nonempty]
  rcases ih t'' card_ι''_le (hall_cond_of_compl hus ht) with ⟨f'', hf'', hsf''⟩
  -- Put them together
  have f'_mem_bUnion : ∀ {x'} (hx' : x' ∈ s), f' ⟨x', hx'⟩ ∈ s.bUnion t :=
    by
    intro x' hx'
    rw [mem_bUnion]
    exact ⟨x', hx', hsf' _⟩
  have f''_not_mem_bUnion : ∀ {x''} (hx'' : ¬x'' ∈ s), ¬f'' ⟨x'', hx''⟩ ∈ s.bUnion t :=
    by
    intro x'' hx''
    have h := hsf'' ⟨x'', hx''⟩
    rw [mem_sdiff] at h 
    exact h.2
  have im_disj : ∀ (x' x'' : ι) (hx' : x' ∈ s) (hx'' : ¬x'' ∈ s), f' ⟨x', hx'⟩ ≠ f'' ⟨x'', hx''⟩ :=
    by
    intro _ _ hx' hx'' h
    apply f''_not_mem_bUnion hx''
    rw [← h]
    apply f'_mem_bUnion
  refine' ⟨fun x => if h : x ∈ s then f' ⟨x, h⟩ else f'' ⟨x, h⟩, _, _⟩
  · exact hf'.dite _ hf'' im_disj
  · intro x
    split_ifs with h
    · exact hsf' ⟨x, h⟩
    · exact sdiff_subset _ _ (hsf'' ⟨x, h⟩)
#align hall_marriage_theorem.hall_hard_inductive_step_B HallMarriageTheorem.hall_hard_inductive_step_B
-/

end Fintype

variable [Finite ι]

#print HallMarriageTheorem.hall_hard_inductive /-
/-- Here we combine the two inductive steps into a full strong induction proof,
completing the proof the harder direction of **Hall's Marriage Theorem**.
-/
theorem hall_hard_inductive (ht : ∀ s : Finset ι, s.card ≤ (s.biUnion t).card) :
    ∃ f : ι → α, Function.Injective f ∧ ∀ x, f x ∈ t x :=
  by
  cases nonempty_fintype ι
  induction' hn : Fintype.card ι using Nat.strong_induction_on with n ih generalizing ι
  rcases n with (_ | _)
  · rw [Fintype.card_eq_zero_iff] at hn 
    exact ⟨isEmptyElim, isEmptyElim, isEmptyElim⟩
  · have ih' :
      ∀ (ι' : Type u) [Fintype ι'] (t' : ι' → Finset α),
        Fintype.card ι' ≤ n →
          (∀ s' : Finset ι', s'.card ≤ (s'.biUnion t').card) →
            ∃ f : ι' → α, Function.Injective f ∧ ∀ x, f x ∈ t' x :=
      by
      intro ι' _ _ hι' ht'
      exact ih _ (Nat.lt_succ_of_le hι') ht' _ rfl
    by_cases h : ∀ s : Finset ι, s.Nonempty → s ≠ univ → s.card < (s.biUnion t).card
    · exact hall_hard_inductive_step_A hn ht ih' h
    · push_neg at h 
      rcases h with ⟨s, sne, snu, sle⟩
      exact hall_hard_inductive_step_B hn ht ih' s sne snu (Nat.le_antisymm (ht _) sle)
#align hall_marriage_theorem.hall_hard_inductive HallMarriageTheorem.hall_hard_inductive
-/

end HallMarriageTheorem

#print Finset.all_card_le_biUnion_card_iff_existsInjective' /-
/-- This is the version of **Hall's Marriage Theorem** in terms of indexed
families of finite sets `t : ι → finset α` with `ι` finite.
It states that there is a set of distinct representatives if and only
if every union of `k` of the sets has at least `k` elements.

See `finset.all_card_le_bUnion_card_iff_exists_injective` for a version
where the `finite ι` constraint is removed.
-/
theorem Finset.all_card_le_biUnion_card_iff_existsInjective' {ι α : Type _} [Finite ι]
    [DecidableEq α] (t : ι → Finset α) :
    (∀ s : Finset ι, s.card ≤ (s.biUnion t).card) ↔
      ∃ f : ι → α, Function.Injective f ∧ ∀ x, f x ∈ t x :=
  by
  constructor
  · exact HallMarriageTheorem.hall_hard_inductive
  · rintro ⟨f, hf₁, hf₂⟩ s
    rw [← card_image_of_injective s hf₁]
    apply card_le_of_subset
    intro
    rw [mem_image, mem_bUnion]
    rintro ⟨x, hx, rfl⟩
    exact ⟨x, hx, hf₂ x⟩
#align finset.all_card_le_bUnion_card_iff_exists_injective' Finset.all_card_le_biUnion_card_iff_existsInjective'
-/

