/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.finset.fold
! leanprover-community/mathlib commit e04043d6bf7264a3c84bc69711dc354958ca4516
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Monoid.WithTop
import Mathbin.Data.Finset.Image
import Mathbin.Data.Multiset.Fold

/-!
# The fold operation for a commutative associative operation over a finset.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


namespace Finset

open Multiset

variable {α β γ : Type _}

/-! ### fold -/


section Fold

variable (op : β → β → β) [hc : IsCommutative β op] [ha : IsAssociative β op]

local notation a " * " b => op a b

#print Finset.fold /-
/-- `fold op b f s` folds the commutative associative operation `op` over the
  `f`-image of `s`, i.e. `fold (+) b f {1,2,3} = f 1 + f 2 + f 3 + b`. -/
def fold (b : β) (f : α → β) (s : Finset α) : β :=
  (s.1.map f).fold op b
#align finset.fold Finset.fold
-/

variable {op} {f : α → β} {b : β} {s : Finset α} {a : α}

#print Finset.fold_empty /-
@[simp]
theorem fold_empty : (∅ : Finset α).fold op b f = b :=
  rfl
#align finset.fold_empty Finset.fold_empty
-/

#print Finset.fold_cons /-
@[simp]
theorem fold_cons (h : a ∉ s) : (cons a s h).fold op b f = f a * s.fold op b f := by
  dsimp only [fold]; rw [cons_val, Multiset.map_cons, fold_cons_left]
#align finset.fold_cons Finset.fold_cons
-/

#print Finset.fold_insert /-
@[simp]
theorem fold_insert [DecidableEq α] (h : a ∉ s) : (insert a s).fold op b f = f a * s.fold op b f :=
  by unfold fold <;> rw [insert_val, ndinsert_of_not_mem h, Multiset.map_cons, fold_cons_left]
#align finset.fold_insert Finset.fold_insert
-/

#print Finset.fold_singleton /-
@[simp]
theorem fold_singleton : ({a} : Finset α).fold op b f = f a * b :=
  rfl
#align finset.fold_singleton Finset.fold_singleton
-/

#print Finset.fold_map /-
@[simp]
theorem fold_map {g : γ ↪ α} {s : Finset γ} : (s.map g).fold op b f = s.fold op b (f ∘ g) := by
  simp only [fold, map, Multiset.map_map]
#align finset.fold_map Finset.fold_map
-/

#print Finset.fold_image /-
@[simp]
theorem fold_image [DecidableEq α] {g : γ → α} {s : Finset γ}
    (H : ∀ x ∈ s, ∀ y ∈ s, g x = g y → x = y) : (s.image g).fold op b f = s.fold op b (f ∘ g) := by
  simp only [fold, image_val_of_inj_on H, Multiset.map_map]
#align finset.fold_image Finset.fold_image
-/

#print Finset.fold_congr /-
@[congr]
theorem fold_congr {g : α → β} (H : ∀ x ∈ s, f x = g x) : s.fold op b f = s.fold op b g := by
  rw [fold, fold, map_congr rfl H]
#align finset.fold_congr Finset.fold_congr
-/

#print Finset.fold_op_distrib /-
theorem fold_op_distrib {f g : α → β} {b₁ b₂ : β} :
    (s.fold op (b₁ * b₂) fun x => f x * g x) = s.fold op b₁ f * s.fold op b₂ g := by
  simp only [fold, fold_distrib]
#align finset.fold_op_distrib Finset.fold_op_distrib
-/

#print Finset.fold_const /-
theorem fold_const [Decidable (s = ∅)] (c : β) (h : op c (op b c) = op b c) :
    Finset.fold op b (fun _ => c) s = if s = ∅ then b else op b c := by
  classical
  induction' s using Finset.induction_on with x s hx IH
  · simp
  · simp only [Finset.fold_insert hx, IH, if_false, Finset.insert_ne_empty]
    split_ifs
    · rw [hc.comm]
    · exact h
#align finset.fold_const Finset.fold_const
-/

#print Finset.fold_hom /-
theorem fold_hom {op' : γ → γ → γ} [IsCommutative γ op'] [IsAssociative γ op'] {m : β → γ}
    (hm : ∀ x y, m (op x y) = op' (m x) (m y)) :
    (s.fold op' (m b) fun x => m (f x)) = m (s.fold op b f) := by
  rw [fold, fold, ← fold_hom op hm, Multiset.map_map]
#align finset.fold_hom Finset.fold_hom
-/

#print Finset.fold_disjUnion /-
theorem fold_disjUnion {s₁ s₂ : Finset α} {b₁ b₂ : β} (h) :
    (s₁.disjUnion s₂ h).fold op (b₁ * b₂) f = s₁.fold op b₁ f * s₂.fold op b₂ f :=
  (congr_arg _ <| Multiset.map_add _ _ _).trans (Multiset.fold_add _ _ _ _ _)
#align finset.fold_disj_union Finset.fold_disjUnion
-/

#print Finset.fold_disjiUnion /-
theorem fold_disjiUnion {ι : Type _} {s : Finset ι} {t : ι → Finset α} {b : ι → β} {b₀ : β} (h) :
    (s.disjUnionₓ t h).fold op (s.fold op b₀ b) f = s.fold op b₀ fun i => (t i).fold op (b i) f :=
  (congr_arg _ <| Multiset.map_bind _ _ _).trans (Multiset.fold_bind _ _ _ _ _)
#align finset.fold_disj_Union Finset.fold_disjiUnion
-/

#print Finset.fold_union_inter /-
theorem fold_union_inter [DecidableEq α] {s₁ s₂ : Finset α} {b₁ b₂ : β} :
    ((s₁ ∪ s₂).fold op b₁ f * (s₁ ∩ s₂).fold op b₂ f) = s₁.fold op b₂ f * s₂.fold op b₁ f := by
  unfold fold <;>
    rw [← fold_add op, ← Multiset.map_add, union_val, inter_val, union_add_inter, Multiset.map_add,
      hc.comm, fold_add]
#align finset.fold_union_inter Finset.fold_union_inter
-/

#print Finset.fold_insert_idem /-
@[simp]
theorem fold_insert_idem [DecidableEq α] [hi : IsIdempotent β op] :
    (insert a s).fold op b f = f a * s.fold op b f :=
  by
  by_cases a ∈ s
  · rw [← insert_erase h]; simp [← ha.assoc, hi.idempotent]
  · apply fold_insert h
#align finset.fold_insert_idem Finset.fold_insert_idem
-/

#print Finset.fold_image_idem /-
theorem fold_image_idem [DecidableEq α] {g : γ → α} {s : Finset γ} [hi : IsIdempotent β op] :
    (image g s).fold op b f = s.fold op b (f ∘ g) :=
  by
  induction' s using Finset.cons_induction with x xs hx ih
  · rw [fold_empty, image_empty, fold_empty]
  · haveI := Classical.decEq γ
    rw [fold_cons, cons_eq_insert, image_insert, fold_insert_idem, ih]
#align finset.fold_image_idem Finset.fold_image_idem
-/

#print Finset.fold_ite' /-
/-- A stronger version of `finset.fold_ite`, but relies on
an explicit proof of idempotency on the seed element, rather
than relying on typeclass idempotency over the whole type. -/
theorem fold_ite' {g : α → β} (hb : op b b = b) (p : α → Prop) [DecidablePred p] :
    Finset.fold op b (fun i => ite (p i) (f i) (g i)) s =
      op (Finset.fold op b f (s.filterₓ p)) (Finset.fold op b g (s.filterₓ fun i => ¬p i)) :=
  by
  classical
  induction' s using Finset.induction_on with x s hx IH
  · simp [hb]
  · simp only [Finset.filter_congr_decidable, Finset.fold_insert hx]
    split_ifs with h h
    · have : x ∉ Finset.filter p s := by simp [hx]
      simp [Finset.filter_insert, h, Finset.fold_insert this, ha.assoc, IH]
    · have : x ∉ Finset.filter (fun i => ¬p i) s := by simp [hx]
      simp [Finset.filter_insert, h, Finset.fold_insert this, IH, ← ha.assoc, hc.comm]
#align finset.fold_ite' Finset.fold_ite'
-/

#print Finset.fold_ite /-
/-- A weaker version of `finset.fold_ite'`,
relying on typeclass idempotency over the whole type,
instead of solely on the seed element.
However, this is easier to use because it does not generate side goals. -/
theorem fold_ite [IsIdempotent β op] {g : α → β} (p : α → Prop) [DecidablePred p] :
    Finset.fold op b (fun i => ite (p i) (f i) (g i)) s =
      op (Finset.fold op b f (s.filterₓ p)) (Finset.fold op b g (s.filterₓ fun i => ¬p i)) :=
  fold_ite' (IsIdempotent.idempotent _) _
#align finset.fold_ite Finset.fold_ite
-/

#print Finset.fold_op_rel_iff_and /-
theorem fold_op_rel_iff_and {r : β → β → Prop} (hr : ∀ {x y z}, r x (op y z) ↔ r x y ∧ r x z)
    {c : β} : r c (s.fold op b f) ↔ r c b ∧ ∀ x ∈ s, r c (f x) := by
  classical
  apply Finset.induction_on s
  · simp
  clear s
  intro a s ha IH
  rw [Finset.fold_insert ha, hr, IH, ← and_assoc', and_comm' (r c (f a)), and_assoc']
  apply and_congr Iff.rfl
  constructor
  · rintro ⟨h₁, h₂⟩; intro b hb; rw [Finset.mem_insert] at hb 
    rcases hb with (rfl | hb) <;> solve_by_elim
  · intro h; constructor
    · exact h a (Finset.mem_insert_self _ _)
    · intro b hb; apply h b; rw [Finset.mem_insert]; right; exact hb
#align finset.fold_op_rel_iff_and Finset.fold_op_rel_iff_and
-/

#print Finset.fold_op_rel_iff_or /-
theorem fold_op_rel_iff_or {r : β → β → Prop} (hr : ∀ {x y z}, r x (op y z) ↔ r x y ∨ r x z)
    {c : β} : r c (s.fold op b f) ↔ r c b ∨ ∃ x ∈ s, r c (f x) := by
  classical
  apply Finset.induction_on s
  · simp
  clear s
  intro a s ha IH
  rw [Finset.fold_insert ha, hr, IH, ← or_assoc', or_comm' (r c (f a)), or_assoc']
  apply or_congr Iff.rfl
  constructor
  · rintro (h₁ | ⟨x, hx, h₂⟩)
    · use a; simp [h₁]
    · refine' ⟨x, by simp [hx], h₂⟩
  · rintro ⟨x, hx, h⟩
    rw [mem_insert] at hx ; cases hx
    · left; rwa [hx] at h 
    · right; exact ⟨x, hx, h⟩
#align finset.fold_op_rel_iff_or Finset.fold_op_rel_iff_or
-/

#print Finset.fold_union_empty_singleton /-
@[simp]
theorem fold_union_empty_singleton [DecidableEq α] (s : Finset α) :
    Finset.fold (· ∪ ·) ∅ singleton s = s :=
  by
  apply Finset.induction_on s
  · simp only [fold_empty]
  · intro a s has ih; rw [fold_insert has, ih, insert_eq]
#align finset.fold_union_empty_singleton Finset.fold_union_empty_singleton
-/

#print Finset.fold_sup_bot_singleton /-
theorem fold_sup_bot_singleton [DecidableEq α] (s : Finset α) :
    Finset.fold (· ⊔ ·) ⊥ singleton s = s :=
  fold_union_empty_singleton s
#align finset.fold_sup_bot_singleton Finset.fold_sup_bot_singleton
-/

section Order

variable [LinearOrder β] (c : β)

#print Finset.le_fold_min /-
theorem le_fold_min : c ≤ s.fold min b f ↔ c ≤ b ∧ ∀ x ∈ s, c ≤ f x :=
  fold_op_rel_iff_and fun x y z => le_min_iff
#align finset.le_fold_min Finset.le_fold_min
-/

#print Finset.fold_min_le /-
theorem fold_min_le : s.fold min b f ≤ c ↔ b ≤ c ∨ ∃ x ∈ s, f x ≤ c :=
  by
  show _ ≥ _ ↔ _
  apply fold_op_rel_iff_or
  intro x y z
  show _ ≤ _ ↔ _
  exact min_le_iff
#align finset.fold_min_le Finset.fold_min_le
-/

#print Finset.lt_fold_min /-
theorem lt_fold_min : c < s.fold min b f ↔ c < b ∧ ∀ x ∈ s, c < f x :=
  fold_op_rel_iff_and fun x y z => lt_min_iff
#align finset.lt_fold_min Finset.lt_fold_min
-/

#print Finset.fold_min_lt /-
theorem fold_min_lt : s.fold min b f < c ↔ b < c ∨ ∃ x ∈ s, f x < c :=
  by
  show _ > _ ↔ _
  apply fold_op_rel_iff_or
  intro x y z
  show _ < _ ↔ _
  exact min_lt_iff
#align finset.fold_min_lt Finset.fold_min_lt
-/

#print Finset.fold_max_le /-
theorem fold_max_le : s.fold max b f ≤ c ↔ b ≤ c ∧ ∀ x ∈ s, f x ≤ c :=
  by
  show _ ≥ _ ↔ _
  apply fold_op_rel_iff_and
  intro x y z
  show _ ≤ _ ↔ _
  exact max_le_iff
#align finset.fold_max_le Finset.fold_max_le
-/

#print Finset.le_fold_max /-
theorem le_fold_max : c ≤ s.fold max b f ↔ c ≤ b ∨ ∃ x ∈ s, c ≤ f x :=
  fold_op_rel_iff_or fun x y z => le_max_iff
#align finset.le_fold_max Finset.le_fold_max
-/

#print Finset.fold_max_lt /-
theorem fold_max_lt : s.fold max b f < c ↔ b < c ∧ ∀ x ∈ s, f x < c :=
  by
  show _ > _ ↔ _
  apply fold_op_rel_iff_and
  intro x y z
  show _ < _ ↔ _
  exact max_lt_iff
#align finset.fold_max_lt Finset.fold_max_lt
-/

#print Finset.lt_fold_max /-
theorem lt_fold_max : c < s.fold max b f ↔ c < b ∨ ∃ x ∈ s, c < f x :=
  fold_op_rel_iff_or fun x y z => lt_max_iff
#align finset.lt_fold_max Finset.lt_fold_max
-/

#print Finset.fold_max_add /-
theorem fold_max_add [Add β] [CovariantClass β β (Function.swap (· + ·)) (· ≤ ·)] (n : WithBot β)
    (s : Finset α) : (s.fold max ⊥ fun x : α => ↑(f x) + n) = s.fold max ⊥ (coe ∘ f) + n := by
  classical apply s.induction_on <;> simp (config := { contextual := true }) [max_add_add_right]
#align finset.fold_max_add Finset.fold_max_add
-/

end Order

end Fold

end Finset

