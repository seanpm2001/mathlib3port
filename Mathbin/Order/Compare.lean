/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module order.compare
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Synonym

/-!
# Comparison

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides basic results about orderings and comparison in linear orders.


## Definitions

* `cmp_le`: An `ordering` from `≤`.
* `ordering.compares`: Turns an `ordering` into `<` and `=` propositions.
* `linear_order_of_compares`: Constructs a `linear_order` instance from the fact that any two
  elements that are not one strictly less than the other either way are equal.
-/


variable {α : Type _}

#print cmpLE /-
/-- Like `cmp`, but uses a `≤` on the type instead of `<`. Given two elements `x` and `y`, returns a
three-way comparison result `ordering`. -/
def cmpLE {α} [LE α] [@DecidableRel α (· ≤ ·)] (x y : α) : Ordering :=
  if x ≤ y then if y ≤ x then Ordering.eq else Ordering.lt else Ordering.gt
#align cmp_le cmpLE
-/

#print cmpLE_swap /-
theorem cmpLE_swap {α} [LE α] [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (x y : α) :
    (cmpLE x y).symm = cmpLE y x :=
  by
  by_cases xy : x ≤ y <;> by_cases yx : y ≤ x <;> simp [cmpLE, *, Ordering.swap]
  cases not_or_of_not xy yx (total_of _ _ _)
#align cmp_le_swap cmpLE_swap
-/

#print cmpLE_eq_cmp /-
theorem cmpLE_eq_cmp {α} [Preorder α] [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)]
    [@DecidableRel α (· < ·)] (x y : α) : cmpLE x y = cmp x y :=
  by
  by_cases xy : x ≤ y <;> by_cases yx : y ≤ x <;> simp [cmpLE, lt_iff_le_not_le, *, cmp, cmpUsing]
  cases not_or_of_not xy yx (total_of _ _ _)
#align cmp_le_eq_cmp cmpLE_eq_cmp
-/

namespace Ordering

#print Ordering.Compares /-
/-- `compares o a b` means that `a` and `b` have the ordering relation `o` between them, assuming
that the relation `a < b` is defined. -/
@[simp]
def Compares [LT α] : Ordering → α → α → Prop
  | lt, a, b => a < b
  | Eq, a, b => a = b
  | GT.gt, a, b => a > b
#align ordering.compares Ordering.Compares
-/

#print Ordering.compares_swap /-
theorem compares_swap [LT α] {a b : α} {o : Ordering} : o.symm.Compares a b ↔ o.Compares b a := by
  cases o; exacts [Iff.rfl, eq_comm, Iff.rfl]
#align ordering.compares_swap Ordering.compares_swap
-/

alias compares_swap ↔ compares.of_swap compares.swap
#align ordering.compares.of_swap Ordering.Compares.of_swap
#align ordering.compares.swap Ordering.Compares.swap

#print Ordering.swap_inj /-
@[simp]
theorem swap_inj (o₁ o₂ : Ordering) : o₁.symm = o₂.symm ↔ o₁ = o₂ := by
  cases o₁ <;> cases o₂ <;> decide
#align ordering.swap_inj Ordering.swap_inj
-/

#print Ordering.swap_eq_iff_eq_swap /-
theorem swap_eq_iff_eq_swap {o o' : Ordering} : o.symm = o' ↔ o = o'.symm := by
  rw [← swap_inj, swap_swap]
#align ordering.swap_eq_iff_eq_swap Ordering.swap_eq_iff_eq_swap
-/

#print Ordering.Compares.eq_lt /-
theorem Compares.eq_lt [Preorder α] : ∀ {o} {a b : α}, Compares o a b → (o = lt ↔ a < b)
  | lt, a, b, h => ⟨fun _ => h, fun _ => rfl⟩
  | Eq, a, b, h => ⟨fun h => by injection h, fun h' => (ne_of_lt h' h).elim⟩
  | GT.gt, a, b, h => ⟨fun h => by injection h, fun h' => (lt_asymm h h').elim⟩
#align ordering.compares.eq_lt Ordering.Compares.eq_lt
-/

#print Ordering.Compares.ne_lt /-
theorem Compares.ne_lt [Preorder α] : ∀ {o} {a b : α}, Compares o a b → (o ≠ lt ↔ b ≤ a)
  | lt, a, b, h => ⟨absurd rfl, fun h' => (not_le_of_lt h h').elim⟩
  | Eq, a, b, h => ⟨fun _ => ge_of_eq h, fun _ h => by injection h⟩
  | GT.gt, a, b, h => ⟨fun _ => le_of_lt h, fun _ h => by injection h⟩
#align ordering.compares.ne_lt Ordering.Compares.ne_lt
-/

#print Ordering.Compares.eq_eq /-
theorem Compares.eq_eq [Preorder α] : ∀ {o} {a b : α}, Compares o a b → (o = eq ↔ a = b)
  | lt, a, b, h => ⟨fun h => by injection h, fun h' => (ne_of_lt h h').elim⟩
  | Eq, a, b, h => ⟨fun _ => h, fun _ => rfl⟩
  | GT.gt, a, b, h => ⟨fun h => by injection h, fun h' => (ne_of_gt h h').elim⟩
#align ordering.compares.eq_eq Ordering.Compares.eq_eq
-/

#print Ordering.Compares.eq_gt /-
theorem Compares.eq_gt [Preorder α] {o} {a b : α} (h : Compares o a b) : o = gt ↔ b < a :=
  swap_eq_iff_eq_swap.symm.trans h.symm.eq_lt
#align ordering.compares.eq_gt Ordering.Compares.eq_gt
-/

#print Ordering.Compares.ne_gt /-
theorem Compares.ne_gt [Preorder α] {o} {a b : α} (h : Compares o a b) : o ≠ gt ↔ a ≤ b :=
  (not_congr swap_eq_iff_eq_swap.symm).trans h.symm.ne_lt
#align ordering.compares.ne_gt Ordering.Compares.ne_gt
-/

#print Ordering.Compares.le_total /-
theorem Compares.le_total [Preorder α] {a b : α} : ∀ {o}, Compares o a b → a ≤ b ∨ b ≤ a
  | lt, h => Or.inl (le_of_lt h)
  | Eq, h => Or.inl (le_of_eq h)
  | GT.gt, h => Or.inr (le_of_lt h)
#align ordering.compares.le_total Ordering.Compares.le_total
-/

#print Ordering.Compares.le_antisymm /-
theorem Compares.le_antisymm [Preorder α] {a b : α} : ∀ {o}, Compares o a b → a ≤ b → b ≤ a → a = b
  | lt, h, _, hba => (not_le_of_lt h hba).elim
  | Eq, h, _, _ => h
  | GT.gt, h, hab, _ => (not_le_of_lt h hab).elim
#align ordering.compares.le_antisymm Ordering.Compares.le_antisymm
-/

#print Ordering.Compares.inj /-
theorem Compares.inj [Preorder α] {o₁} :
    ∀ {o₂} {a b : α}, Compares o₁ a b → Compares o₂ a b → o₁ = o₂
  | lt, a, b, h₁, h₂ => h₁.eq_lt.2 h₂
  | Eq, a, b, h₁, h₂ => h₁.eq_eq.2 h₂
  | GT.gt, a, b, h₁, h₂ => h₁.eq_gt.2 h₂
#align ordering.compares.inj Ordering.Compares.inj
-/

#print Ordering.compares_iff_of_compares_impl /-
theorem compares_iff_of_compares_impl {β : Type _} [LinearOrder α] [Preorder β] {a b : α}
    {a' b' : β} (h : ∀ {o}, Compares o a b → Compares o a' b') (o) :
    Compares o a b ↔ Compares o a' b' :=
  by
  refine' ⟨h, fun ho => _⟩
  cases' lt_trichotomy a b with hab hab
  · change compares Ordering.lt a b at hab 
    rwa [ho.inj (h hab)]
  · cases' hab with hab hab
    · change compares Ordering.eq a b at hab 
      rwa [ho.inj (h hab)]
    · change compares Ordering.gt a b at hab 
      rwa [ho.inj (h hab)]
#align ordering.compares_iff_of_compares_impl Ordering.compares_iff_of_compares_impl
-/

#print Ordering.swap_orElse /-
theorem swap_orElse (o₁ o₂) : (orElse o₁ o₂).symm = orElse o₁.symm o₂.symm := by
  cases o₁ <;> try rfl <;> cases o₂ <;> rfl
#align ordering.swap_or_else Ordering.swap_orElse
-/

#print Ordering.orElse_eq_lt /-
theorem orElse_eq_lt (o₁ o₂) : orElse o₁ o₂ = lt ↔ o₁ = lt ∨ o₁ = eq ∧ o₂ = lt := by
  cases o₁ <;> cases o₂ <;> exact by decide
#align ordering.or_else_eq_lt Ordering.orElse_eq_lt
-/

end Ordering

open Ordering OrderDual

#print toDual_compares_toDual /-
@[simp]
theorem toDual_compares_toDual [LT α] {a b : α} {o : Ordering} :
    Compares o (toDual a) (toDual b) ↔ Compares o b a := by cases o;
  exacts [Iff.rfl, eq_comm, Iff.rfl]
#align to_dual_compares_to_dual toDual_compares_toDual
-/

#print ofDual_compares_ofDual /-
@[simp]
theorem ofDual_compares_ofDual [LT α] {a b : αᵒᵈ} {o : Ordering} :
    Compares o (ofDual a) (ofDual b) ↔ Compares o b a := by cases o;
  exacts [Iff.rfl, eq_comm, Iff.rfl]
#align of_dual_compares_of_dual ofDual_compares_ofDual
-/

#print cmp_compares /-
theorem cmp_compares [LinearOrder α] (a b : α) : (cmp a b).Compares a b := by
  obtain h | h | h := lt_trichotomy a b <;> simp [cmp, cmpUsing, h, h.not_lt]
#align cmp_compares cmp_compares
-/

#print Ordering.Compares.cmp_eq /-
theorem Ordering.Compares.cmp_eq [LinearOrder α] {a b : α} {o : Ordering} (h : o.Compares a b) :
    cmp a b = o :=
  (cmp_compares a b).inj h
#align ordering.compares.cmp_eq Ordering.Compares.cmp_eq
-/

#print cmp_swap /-
@[simp]
theorem cmp_swap [Preorder α] [@DecidableRel α (· < ·)] (a b : α) : (cmp a b).symm = cmp b a :=
  by
  unfold cmp cmpUsing
  by_cases a < b <;> by_cases h₂ : b < a <;> simp [h, h₂, Ordering.swap]
  exact lt_asymm h h₂
#align cmp_swap cmp_swap
-/

#print cmpLE_toDual /-
@[simp]
theorem cmpLE_toDual [LE α] [@DecidableRel α (· ≤ ·)] (x y : α) :
    cmpLE (toDual x) (toDual y) = cmpLE y x :=
  rfl
#align cmp_le_to_dual cmpLE_toDual
-/

#print cmpLE_ofDual /-
@[simp]
theorem cmpLE_ofDual [LE α] [@DecidableRel α (· ≤ ·)] (x y : αᵒᵈ) :
    cmpLE (ofDual x) (ofDual y) = cmpLE y x :=
  rfl
#align cmp_le_of_dual cmpLE_ofDual
-/

/- warning: cmp_to_dual clashes with cmp_le_to_dual -> cmpLE_toDual
Case conversion may be inaccurate. Consider using '#align cmp_to_dual cmpLE_toDualₓ'. -/
#print cmpLE_toDual /-
@[simp]
theorem cmpLE_toDual [LT α] [@DecidableRel α (· < ·)] (x y : α) :
    cmp (toDual x) (toDual y) = cmp y x :=
  rfl
#align cmp_to_dual cmpLE_toDual
-/

/- warning: cmp_of_dual clashes with cmp_le_of_dual -> cmpLE_ofDual
Case conversion may be inaccurate. Consider using '#align cmp_of_dual cmpLE_ofDualₓ'. -/
#print cmpLE_ofDual /-
@[simp]
theorem cmpLE_ofDual [LT α] [@DecidableRel α (· < ·)] (x y : αᵒᵈ) :
    cmp (ofDual x) (ofDual y) = cmp y x :=
  rfl
#align cmp_of_dual cmpLE_ofDual
-/

#print linearOrderOfCompares /-
/-- Generate a linear order structure from a preorder and `cmp` function. -/
def linearOrderOfCompares [Preorder α] (cmp : α → α → Ordering)
    (h : ∀ a b, (cmp a b).Compares a b) : LinearOrder α :=
  { ‹Preorder α› with
    le_antisymm := fun a b => (h a b).le_antisymm
    le_total := fun a b => (h a b).le_total
    decidableLe := fun a b => decidable_of_iff _ (h a b).ne_gt
    decidableLt := fun a b => decidable_of_iff _ (h a b).eq_lt
    DecidableEq := fun a b => decidable_of_iff _ (h a b).eq_eq }
#align linear_order_of_compares linearOrderOfCompares
-/

variable [LinearOrder α] (x y : α)

#print cmp_eq_lt_iff /-
@[simp]
theorem cmp_eq_lt_iff : cmp x y = Ordering.lt ↔ x < y :=
  Ordering.Compares.eq_lt (cmp_compares x y)
#align cmp_eq_lt_iff cmp_eq_lt_iff
-/

#print cmp_eq_eq_iff /-
@[simp]
theorem cmp_eq_eq_iff : cmp x y = Ordering.eq ↔ x = y :=
  Ordering.Compares.eq_eq (cmp_compares x y)
#align cmp_eq_eq_iff cmp_eq_eq_iff
-/

#print cmp_eq_gt_iff /-
@[simp]
theorem cmp_eq_gt_iff : cmp x y = Ordering.gt ↔ y < x :=
  Ordering.Compares.eq_gt (cmp_compares x y)
#align cmp_eq_gt_iff cmp_eq_gt_iff
-/

#print cmp_self_eq_eq /-
@[simp]
theorem cmp_self_eq_eq : cmp x x = Ordering.eq := by rw [cmp_eq_eq_iff]
#align cmp_self_eq_eq cmp_self_eq_eq
-/

variable {x y} {β : Type _} [LinearOrder β] {x' y' : β}

#print cmp_eq_cmp_symm /-
theorem cmp_eq_cmp_symm : cmp x y = cmp x' y' ↔ cmp y x = cmp y' x' := by
  rw [← cmp_swap x', ← cmp_swap x, swap_inj]
#align cmp_eq_cmp_symm cmp_eq_cmp_symm
-/

#print lt_iff_lt_of_cmp_eq_cmp /-
theorem lt_iff_lt_of_cmp_eq_cmp (h : cmp x y = cmp x' y') : x < y ↔ x' < y' := by
  rw [← cmp_eq_lt_iff, ← cmp_eq_lt_iff, h]
#align lt_iff_lt_of_cmp_eq_cmp lt_iff_lt_of_cmp_eq_cmp
-/

#print le_iff_le_of_cmp_eq_cmp /-
theorem le_iff_le_of_cmp_eq_cmp (h : cmp x y = cmp x' y') : x ≤ y ↔ x' ≤ y' :=
  by
  rw [← not_lt, ← not_lt]; apply not_congr
  apply lt_iff_lt_of_cmp_eq_cmp; rwa [cmp_eq_cmp_symm]
#align le_iff_le_of_cmp_eq_cmp le_iff_le_of_cmp_eq_cmp
-/

#print eq_iff_eq_of_cmp_eq_cmp /-
theorem eq_iff_eq_of_cmp_eq_cmp (h : cmp x y = cmp x' y') : x = y ↔ x' = y' := by
  rw [le_antisymm_iff, le_antisymm_iff, le_iff_le_of_cmp_eq_cmp h,
    le_iff_le_of_cmp_eq_cmp (cmp_eq_cmp_symm.1 h)]
#align eq_iff_eq_of_cmp_eq_cmp eq_iff_eq_of_cmp_eq_cmp
-/

#print LT.lt.cmp_eq_lt /-
theorem LT.lt.cmp_eq_lt (h : x < y) : cmp x y = Ordering.lt :=
  (cmp_eq_lt_iff _ _).2 h
#align has_lt.lt.cmp_eq_lt LT.lt.cmp_eq_lt
-/

#print LT.lt.cmp_eq_gt /-
theorem LT.lt.cmp_eq_gt (h : x < y) : cmp y x = Ordering.gt :=
  (cmp_eq_gt_iff _ _).2 h
#align has_lt.lt.cmp_eq_gt LT.lt.cmp_eq_gt
-/

#print Eq.cmp_eq_eq /-
theorem Eq.cmp_eq_eq (h : x = y) : cmp x y = Ordering.eq :=
  (cmp_eq_eq_iff _ _).2 h
#align eq.cmp_eq_eq Eq.cmp_eq_eq
-/

#print Eq.cmp_eq_eq' /-
theorem Eq.cmp_eq_eq' (h : x = y) : cmp y x = Ordering.eq :=
  h.symm.cmp_eq_eq
#align eq.cmp_eq_eq' Eq.cmp_eq_eq'
-/

