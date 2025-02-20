/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.list.lex
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.RelClasses

/-!
# Lexicographic ordering of lists.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The lexicographic order on `list α` is defined by `L < M` iff
* `[] < (a :: L)` for any `a` and `L`,
* `(a :: L) < (b :: M)` where `a < b`, or
* `(a :: L) < (a :: M)` where `L < M`.

## See also

Related files are:
* `data.finset.colex`: Colexicographic order on finite sets.
* `data.psigma.order`: Lexicographic order on `Σ' i, α i`.
* `data.pi.lex`: Lexicographic order on `Πₗ i, α i`.
* `data.sigma.order`: Lexicographic order on `Σ i, α i`.
* `data.prod.lex`: Lexicographic order on `α × β`.
-/


namespace List

open Nat

universe u

variable {α : Type u}

/-! ### lexicographic ordering -/


#print List.Lex /-
/-- Given a strict order `<` on `α`, the lexicographic strict order on `list α`, for which
`[a0, ..., an] < [b0, ..., b_k]` if `a0 < b0` or `a0 = b0` and `[a1, ..., an] < [b1, ..., bk]`.
The definition is given for any relation `r`, not only strict orders. -/
inductive Lex (r : α → α → Prop) : List α → List α → Prop
  | nil {a l} : Lex [] (a :: l)
  | cons {a l₁ l₂} (h : Lex l₁ l₂) : Lex (a :: l₁) (a :: l₂)
  | Rel {a₁ l₁ a₂ l₂} (h : r a₁ a₂) : Lex (a₁ :: l₁) (a₂ :: l₂)
#align list.lex List.Lex
-/

namespace Lex

#print List.Lex.cons_iff /-
theorem cons_iff {r : α → α → Prop} [IsIrrefl α r] {a l₁ l₂} :
    Lex r (a :: l₁) (a :: l₂) ↔ Lex r l₁ l₂ :=
  ⟨fun h => by cases' h with _ _ _ _ _ h _ _ _ _ h <;> [exact h; exact (irrefl_of r a h).elim],
    Lex.cons⟩
#align list.lex.cons_iff List.Lex.cons_iff
-/

#print List.Lex.not_nil_right /-
@[simp]
theorem not_nil_right (r : α → α → Prop) (l : List α) : ¬Lex r l [] :=
  fun.
#align list.lex.not_nil_right List.Lex.not_nil_right
-/

#print List.Lex.isOrderConnected /-
instance isOrderConnected (r : α → α → Prop) [IsOrderConnected α r] [IsTrichotomous α r] :
    IsOrderConnected (List α) (Lex r) :=
  ⟨fun l₁ =>
    match l₁ with
    | _, [], c :: l₃, nil => Or.inr nil
    | _, [], c :: l₃, Rel _ => Or.inr nil
    | _, [], c :: l₃, cons _ => Or.inr nil
    | _, b :: l₂, c :: l₃, nil => Or.inl nil
    | a :: l₁, b :: l₂, c :: l₃, Rel h => (IsOrderConnected.conn _ b _ h).imp rel rel
    | a :: l₁, b :: l₂, _ :: l₃, cons h =>
      by
      rcases trichotomous_of r a b with (ab | rfl | ab)
      · exact Or.inl (Rel ab)
      · exact (_match _ l₂ _ h).imp cons cons
      · exact Or.inr (Rel ab)⟩
#align list.lex.is_order_connected List.Lex.isOrderConnected
-/

#print List.Lex.isTrichotomous /-
instance isTrichotomous (r : α → α → Prop) [IsTrichotomous α r] : IsTrichotomous (List α) (Lex r) :=
  ⟨fun l₁ =>
    match l₁ with
    | [], [] => Or.inr (Or.inl rfl)
    | [], b :: l₂ => Or.inl nil
    | a :: l₁, [] => Or.inr (Or.inr nil)
    | a :: l₁, b :: l₂ => by
      rcases trichotomous_of r a b with (ab | rfl | ab)
      · exact Or.inl (Rel ab)
      · exact (_match l₁ l₂).imp cons (Or.imp (congr_arg _) cons)
      · exact Or.inr (Or.inr (Rel ab))⟩
#align list.lex.is_trichotomous List.Lex.isTrichotomous
-/

#print List.Lex.isAsymm /-
instance isAsymm (r : α → α → Prop) [IsAsymm α r] : IsAsymm (List α) (Lex r) :=
  ⟨fun l₁ =>
    match l₁ with
    | a :: l₁, b :: l₂, lex.rel h₁, lex.rel h₂ => asymm h₁ h₂
    | a :: l₁, b :: l₂, lex.rel h₁, lex.cons h₂ => asymm h₁ h₁
    | a :: l₁, b :: l₂, lex.cons h₁, lex.rel h₂ => asymm h₂ h₂
    | a :: l₁, b :: l₂, lex.cons h₁, lex.cons h₂ => _match _ _ h₁ h₂⟩
#align list.lex.is_asymm List.Lex.isAsymm
-/

#print List.Lex.isStrictTotalOrder /-
instance isStrictTotalOrder (r : α → α → Prop) [IsStrictTotalOrder α r] :
    IsStrictTotalOrder (List α) (Lex r) :=
  { isStrictWeakOrder_of_isOrderConnected with }
#align list.lex.is_strict_total_order List.Lex.isStrictTotalOrder
-/

#print List.Lex.decidableRel /-
instance decidableRel [DecidableEq α] (r : α → α → Prop) [DecidableRel r] : DecidableRel (Lex r)
  | l₁, [] => isFalse fun h => by cases h
  | [], b :: l₂ => isTrue Lex.nil
  | a :: l₁, b :: l₂ => by
    haveI := DecidableRel l₁ l₂
    refine' decidable_of_iff (r a b ∨ a = b ∧ Lex r l₁ l₂) ⟨fun h => _, fun h => _⟩
    · rcases h with (h | ⟨rfl, h⟩)
      · exact lex.rel h
      · exact lex.cons h
    · rcases h with (_ | h | h)
      · exact Or.inr ⟨rfl, h⟩
      · exact Or.inl h
#align list.lex.decidable_rel List.Lex.decidableRel
-/

#print List.Lex.append_right /-
theorem append_right (r : α → α → Prop) : ∀ {s₁ s₂} (t), Lex r s₁ s₂ → Lex r s₁ (s₂ ++ t)
  | _, _, t, nil => nil
  | _, _, t, cons h => cons (append_right _ h)
  | _, _, t, Rel r => rel r
#align list.lex.append_right List.Lex.append_right
-/

#print List.Lex.append_left /-
theorem append_left (R : α → α → Prop) {t₁ t₂} (h : Lex R t₁ t₂) : ∀ s, Lex R (s ++ t₁) (s ++ t₂)
  | [] => h
  | a :: l => cons (append_left l)
#align list.lex.append_left List.Lex.append_left
-/

#print List.Lex.imp /-
theorem imp {r s : α → α → Prop} (H : ∀ a b, r a b → s a b) : ∀ l₁ l₂, Lex r l₁ l₂ → Lex s l₁ l₂
  | _, _, nil => nil
  | _, _, cons h => cons (imp _ _ h)
  | _, _, Rel r => rel (H _ _ r)
#align list.lex.imp List.Lex.imp
-/

#print List.Lex.to_ne /-
theorem to_ne : ∀ {l₁ l₂ : List α}, Lex (· ≠ ·) l₁ l₂ → l₁ ≠ l₂
  | _, _, cons h, e => to_ne h (List.cons.inj e).2
  | _, _, Rel r, e => r (List.cons.inj e).1
#align list.lex.to_ne List.Lex.to_ne
-/

#print Decidable.List.Lex.ne_iff /-
theorem Decidable.List.Lex.ne_iff [DecidableEq α] {l₁ l₂ : List α} (H : length l₁ ≤ length l₂) :
    Lex (· ≠ ·) l₁ l₂ ↔ l₁ ≠ l₂ :=
  ⟨to_ne, fun h =>
    by
    induction' l₁ with a l₁ IH generalizing l₂ <;> cases' l₂ with b l₂
    · contradiction
    · apply nil
    · exact (not_lt_of_ge H).elim (succ_pos _)
    · by_cases ab : a = b
      · subst b; apply cons
        exact IH (le_of_succ_le_succ H) (mt (congr_arg _) h)
      · exact Rel ab⟩
#align decidable.list.lex.ne_iff Decidable.List.Lex.ne_iff
-/

#print List.Lex.ne_iff /-
theorem ne_iff {l₁ l₂ : List α} (H : length l₁ ≤ length l₂) : Lex (· ≠ ·) l₁ l₂ ↔ l₁ ≠ l₂ := by
  classical exact Decidable.List.Lex.ne_iff H
#align list.lex.ne_iff List.Lex.ne_iff
-/

end Lex

#print List.LT' /-
--Note: this overrides an instance in core lean
instance LT' [LT α] : LT (List α) :=
  ⟨Lex (· < ·)⟩
#align list.has_lt' List.LT'
-/

#print List.nil_lt_cons /-
theorem nil_lt_cons [LT α] (a : α) (l : List α) : [] < a :: l :=
  Lex.nil
#align list.nil_lt_cons List.nil_lt_cons
-/

instance [LinearOrder α] : LinearOrder (List α) :=
  linearOrderOfSTO (Lex (· < ·))

#print List.LE' /-
--Note: this overrides an instance in core lean
instance LE' [LinearOrder α] : LE (List α) :=
  Preorder.toLE _
#align list.has_le' List.LE'
-/

end List

