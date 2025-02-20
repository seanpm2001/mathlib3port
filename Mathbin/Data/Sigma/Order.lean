/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.sigma.order
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Sigma.Lex
import Mathbin.Order.BoundedOrder

/-!
# Orders on a sigma type

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines two orders on a sigma type:
* The disjoint sum of orders. `a` is less `b` iff `a` and `b` are in the same summand and `a` is
  less than `b` there.
* The lexicographical order. `a` is less than `b` if its summand is strictly less than the summand
  of `b` or they are in the same summand and `a` is less than `b` there.

We make the disjoint sum of orders the default set of instances. The lexicographic order goes on a
type synonym.

## Notation

* `Σₗ i, α i`: Sigma type equipped with the lexicographic order. Type synonym of `Σ i, α i`.

## See also

Related files are:
* `data.finset.colex`: Colexicographic order on finite sets.
* `data.list.lex`: Lexicographic order on lists.
* `data.pi.lex`: Lexicographic order on `Πₗ i, α i`.
* `data.psigma.order`: Lexicographic order on `Σₗ' i, α i`. Basically a twin of this file.
* `data.prod.lex`: Lexicographic order on `α × β`.

## TODO

Upgrade `equiv.sigma_congr_left`, `equiv.sigma_congr`, `equiv.sigma_assoc`,
`equiv.sigma_prod_of_equiv`, `equiv.sigma_equiv_prod`, ... to order isomorphisms.
-/


namespace Sigma

variable {ι : Type _} {α : ι → Type _}

/-! ### Disjoint sum of orders on `sigma` -/


#print Sigma.le /-
/-- Disjoint sum of orders. `⟨i, a⟩ ≤ ⟨j, b⟩` iff `i = j` and `a ≤ b`. -/
inductive le [∀ i, LE (α i)] : ∀ a b : Σ i, α i, Prop
  | fiber (i : ι) (a b : α i) : a ≤ b → le ⟨i, a⟩ ⟨i, b⟩
#align sigma.le Sigma.le
-/

#print Sigma.lt /-
/-- Disjoint sum of orders. `⟨i, a⟩ < ⟨j, b⟩` iff `i = j` and `a < b`. -/
inductive lt [∀ i, LT (α i)] : ∀ a b : Σ i, α i, Prop
  | fiber (i : ι) (a b : α i) : a < b → lt ⟨i, a⟩ ⟨i, b⟩
#align sigma.lt Sigma.lt
-/

instance [∀ i, LE (α i)] : LE (Σ i, α i) :=
  ⟨le⟩

instance [∀ i, LT (α i)] : LT (Σ i, α i) :=
  ⟨lt⟩

#print Sigma.mk_le_mk_iff /-
@[simp]
theorem mk_le_mk_iff [∀ i, LE (α i)] {i : ι} {a b : α i} : (⟨i, a⟩ : Sigma α) ≤ ⟨i, b⟩ ↔ a ≤ b :=
  ⟨fun ⟨_, _, _, h⟩ => h, le.fiber _ _ _⟩
#align sigma.mk_le_mk_iff Sigma.mk_le_mk_iff
-/

#print Sigma.mk_lt_mk_iff /-
@[simp]
theorem mk_lt_mk_iff [∀ i, LT (α i)] {i : ι} {a b : α i} : (⟨i, a⟩ : Sigma α) < ⟨i, b⟩ ↔ a < b :=
  ⟨fun ⟨_, _, _, h⟩ => h, lt.fiber _ _ _⟩
#align sigma.mk_lt_mk_iff Sigma.mk_lt_mk_iff
-/

#print Sigma.le_def /-
theorem le_def [∀ i, LE (α i)] {a b : Σ i, α i} : a ≤ b ↔ ∃ h : a.1 = b.1, h.rec a.2 ≤ b.2 :=
  by
  constructor
  · rintro ⟨i, a, b, h⟩
    exact ⟨rfl, h⟩
  · obtain ⟨i, a⟩ := a
    obtain ⟨j, b⟩ := b
    rintro ⟨rfl : i = j, h⟩
    exact le.fiber _ _ _ h
#align sigma.le_def Sigma.le_def
-/

#print Sigma.lt_def /-
theorem lt_def [∀ i, LT (α i)] {a b : Σ i, α i} : a < b ↔ ∃ h : a.1 = b.1, h.rec a.2 < b.2 :=
  by
  constructor
  · rintro ⟨i, a, b, h⟩
    exact ⟨rfl, h⟩
  · obtain ⟨i, a⟩ := a
    obtain ⟨j, b⟩ := b
    rintro ⟨rfl : i = j, h⟩
    exact lt.fiber _ _ _ h
#align sigma.lt_def Sigma.lt_def
-/

instance [∀ i, Preorder (α i)] : Preorder (Σ i, α i) :=
  { Sigma.hasLe,
    Sigma.hasLt with
    le_refl := fun ⟨i, a⟩ => le.fiber i a a le_rfl
    le_trans := by
      rintro _ _ _ ⟨i, a, b, hab⟩ ⟨_, _, c, hbc⟩
      exact le.fiber i a c (hab.trans hbc)
    lt_iff_le_not_le := fun _ _ => by
      constructor
      · rintro ⟨i, a, b, hab⟩
        rwa [mk_le_mk_iff, mk_le_mk_iff, ← lt_iff_le_not_le]
      · rintro ⟨⟨i, a, b, hab⟩, h⟩
        rw [mk_le_mk_iff] at h 
        exact mk_lt_mk_iff.2 (hab.lt_of_not_le h) }

instance [∀ i, PartialOrder (α i)] : PartialOrder (Σ i, α i) :=
  { Sigma.preorder with
    le_antisymm := by
      rintro _ _ ⟨i, a, b, hab⟩ ⟨_, _, _, hba⟩
      exact ext rfl (hEq_of_eq <| hab.antisymm hba) }

instance [∀ i, Preorder (α i)] [∀ i, DenselyOrdered (α i)] : DenselyOrdered (Σ i, α i) :=
  ⟨by
    rintro ⟨i, a⟩ ⟨_, _⟩ ⟨_, _, b, h⟩
    obtain ⟨c, ha, hb⟩ := exists_between h
    exact ⟨⟨i, c⟩, lt.fiber i a c ha, lt.fiber i c b hb⟩⟩

/-! ### Lexicographical order on `sigma` -/


namespace Lex

notation3"Σₗ "(...)", "r:(scoped p => Lex Sigma p) => r

#print Sigma.Lex.LE /-
/-- The lexicographical `≤` on a sigma type. -/
instance LE [LT ι] [∀ i, LE (α i)] : LE (Σₗ i, α i) :=
  ⟨Lex (· < ·) fun i => (· ≤ ·)⟩
#align sigma.lex.has_le Sigma.Lex.LE
-/

#print Sigma.Lex.LT /-
/-- The lexicographical `<` on a sigma type. -/
instance LT [LT ι] [∀ i, LT (α i)] : LT (Σₗ i, α i) :=
  ⟨Lex (· < ·) fun i => (· < ·)⟩
#align sigma.lex.has_lt Sigma.Lex.LT
-/

#print Sigma.Lex.le_def /-
theorem le_def [LT ι] [∀ i, LE (α i)] {a b : Σₗ i, α i} :
    a ≤ b ↔ a.1 < b.1 ∨ ∃ h : a.1 = b.1, h.rec a.2 ≤ b.2 :=
  Sigma.lex_iff
#align sigma.lex.le_def Sigma.Lex.le_def
-/

#print Sigma.Lex.lt_def /-
theorem lt_def [LT ι] [∀ i, LT (α i)] {a b : Σₗ i, α i} :
    a < b ↔ a.1 < b.1 ∨ ∃ h : a.1 = b.1, h.rec a.2 < b.2 :=
  Sigma.lex_iff
#align sigma.lex.lt_def Sigma.Lex.lt_def
-/

#print Sigma.Lex.preorder /-
/-- The lexicographical preorder on a sigma type. -/
instance preorder [Preorder ι] [∀ i, Preorder (α i)] : Preorder (Σₗ i, α i) :=
  { Lex.LE, Lex.LT with
    le_refl := fun ⟨i, a⟩ => Lex.right a a le_rfl
    le_trans := fun _ _ _ => trans_of (Lex (· < ·) fun _ => (· ≤ ·))
    lt_iff_le_not_le :=
      by
      refine' fun a b => ⟨fun hab => ⟨hab.mono_right fun i a b => le_of_lt, _⟩, _⟩
      · rintro (⟨b, a, hji⟩ | ⟨b, a, hba⟩) <;> obtain ⟨_, _, hij⟩ | ⟨_, _, hab⟩ := hab
        · exact hij.not_lt hji
        · exact lt_irrefl _ hji
        · exact lt_irrefl _ hij
        · exact hab.not_le hba
      · rintro ⟨⟨a, b, hij⟩ | ⟨a, b, hab⟩, hba⟩
        · exact lex.left _ _ hij
        · exact lex.right _ _ (hab.lt_of_not_le fun h => hba <| lex.right _ _ h) }
#align sigma.lex.preorder Sigma.Lex.preorder
-/

#print Sigma.Lex.partialOrder /-
/-- The lexicographical partial order on a sigma type. -/
instance partialOrder [Preorder ι] [∀ i, PartialOrder (α i)] : PartialOrder (Σₗ i, α i) :=
  { Lex.preorder with le_antisymm := fun _ _ => antisymm_of (Lex (· < ·) fun _ => (· ≤ ·)) }
#align sigma.lex.partial_order Sigma.Lex.partialOrder
-/

#print Sigma.Lex.linearOrder /-
/-- The lexicographical linear order on a sigma type. -/
instance linearOrder [LinearOrder ι] [∀ i, LinearOrder (α i)] : LinearOrder (Σₗ i, α i) :=
  { Lex.partialOrder with
    le_total := total_of (Lex (· < ·) fun _ => (· ≤ ·))
    DecidableEq := Sigma.decidableEq
    decidableLe := Lex.decidable _ _ }
#align sigma.lex.linear_order Sigma.Lex.linearOrder
-/

#print Sigma.Lex.orderBot /-
/-- The lexicographical linear order on a sigma type. -/
instance orderBot [PartialOrder ι] [OrderBot ι] [∀ i, Preorder (α i)] [OrderBot (α ⊥)] :
    OrderBot (Σₗ i, α i) where
  bot := ⟨⊥, ⊥⟩
  bot_le := fun ⟨a, b⟩ => by
    obtain rfl | ha := eq_bot_or_bot_lt a
    · exact lex.right _ _ bot_le
    · exact lex.left _ _ ha
#align sigma.lex.order_bot Sigma.Lex.orderBot
-/

#print Sigma.Lex.orderTop /-
/-- The lexicographical linear order on a sigma type. -/
instance orderTop [PartialOrder ι] [OrderTop ι] [∀ i, Preorder (α i)] [OrderTop (α ⊤)] :
    OrderTop (Σₗ i, α i) where
  top := ⟨⊤, ⊤⟩
  le_top := fun ⟨a, b⟩ => by
    obtain rfl | ha := eq_top_or_lt_top a
    · exact lex.right _ _ le_top
    · exact lex.left _ _ ha
#align sigma.lex.order_top Sigma.Lex.orderTop
-/

#print Sigma.Lex.boundedOrder /-
/-- The lexicographical linear order on a sigma type. -/
instance boundedOrder [PartialOrder ι] [BoundedOrder ι] [∀ i, Preorder (α i)] [OrderBot (α ⊥)]
    [OrderTop (α ⊤)] : BoundedOrder (Σₗ i, α i) :=
  { Lex.orderBot, Lex.orderTop with }
#align sigma.lex.bounded_order Sigma.Lex.boundedOrder
-/

#print Sigma.Lex.denselyOrdered /-
instance denselyOrdered [Preorder ι] [DenselyOrdered ι] [∀ i, Nonempty (α i)] [∀ i, Preorder (α i)]
    [∀ i, DenselyOrdered (α i)] : DenselyOrdered (Σₗ i, α i) :=
  ⟨by
    rintro ⟨i, a⟩ ⟨j, b⟩ (⟨_, _, h⟩ | ⟨_, b, h⟩)
    · obtain ⟨k, hi, hj⟩ := exists_between h
      obtain ⟨c⟩ : Nonempty (α k) := inferInstance
      exact ⟨⟨k, c⟩, left _ _ hi, left _ _ hj⟩
    · obtain ⟨c, ha, hb⟩ := exists_between h
      exact ⟨⟨i, c⟩, right _ _ ha, right _ _ hb⟩⟩
#align sigma.lex.densely_ordered Sigma.Lex.denselyOrdered
-/

#print Sigma.Lex.denselyOrdered_of_noMaxOrder /-
instance denselyOrdered_of_noMaxOrder [Preorder ι] [∀ i, Preorder (α i)] [∀ i, DenselyOrdered (α i)]
    [∀ i, NoMaxOrder (α i)] : DenselyOrdered (Σₗ i, α i) :=
  ⟨by
    rintro ⟨i, a⟩ ⟨j, b⟩ (⟨_, _, h⟩ | ⟨_, b, h⟩)
    · obtain ⟨c, ha⟩ := exists_gt a
      exact ⟨⟨i, c⟩, right _ _ ha, left _ _ h⟩
    · obtain ⟨c, ha, hb⟩ := exists_between h
      exact ⟨⟨i, c⟩, right _ _ ha, right _ _ hb⟩⟩
#align sigma.lex.densely_ordered_of_no_max_order Sigma.Lex.denselyOrdered_of_noMaxOrder
-/

#print Sigma.Lex.denselyOrdered_of_noMinOrder /-
instance denselyOrdered_of_noMinOrder [Preorder ι] [∀ i, Preorder (α i)] [∀ i, DenselyOrdered (α i)]
    [∀ i, NoMinOrder (α i)] : DenselyOrdered (Σₗ i, α i) :=
  ⟨by
    rintro ⟨i, a⟩ ⟨j, b⟩ (⟨_, _, h⟩ | ⟨_, b, h⟩)
    · obtain ⟨c, hb⟩ := exists_lt b
      exact ⟨⟨j, c⟩, left _ _ h, right _ _ hb⟩
    · obtain ⟨c, ha, hb⟩ := exists_between h
      exact ⟨⟨i, c⟩, right _ _ ha, right _ _ hb⟩⟩
#align sigma.lex.densely_ordered_of_no_min_order Sigma.Lex.denselyOrdered_of_noMinOrder
-/

#print Sigma.Lex.noMaxOrder_of_nonempty /-
instance noMaxOrder_of_nonempty [Preorder ι] [∀ i, Preorder (α i)] [NoMaxOrder ι]
    [∀ i, Nonempty (α i)] : NoMaxOrder (Σₗ i, α i) :=
  ⟨by
    rintro ⟨i, a⟩
    obtain ⟨j, h⟩ := exists_gt i
    obtain ⟨b⟩ : Nonempty (α j) := inferInstance
    exact ⟨⟨j, b⟩, left _ _ h⟩⟩
#align sigma.lex.no_max_order_of_nonempty Sigma.Lex.noMaxOrder_of_nonempty
-/

instance no_min_order_of_nonempty [Preorder ι] [∀ i, Preorder (α i)] [NoMaxOrder ι]
    [∀ i, Nonempty (α i)] : NoMaxOrder (Σₗ i, α i) :=
  ⟨by
    rintro ⟨i, a⟩
    obtain ⟨j, h⟩ := exists_gt i
    obtain ⟨b⟩ : Nonempty (α j) := inferInstance
    exact ⟨⟨j, b⟩, left _ _ h⟩⟩
#align sigma.lex.no_min_order_of_nonempty Sigma.Lex.no_min_order_of_nonempty

#print Sigma.Lex.noMaxOrder /-
instance noMaxOrder [Preorder ι] [∀ i, Preorder (α i)] [∀ i, NoMaxOrder (α i)] :
    NoMaxOrder (Σₗ i, α i) :=
  ⟨by rintro ⟨i, a⟩; obtain ⟨b, h⟩ := exists_gt a; exact ⟨⟨i, b⟩, right _ _ h⟩⟩
#align sigma.lex.no_max_order Sigma.Lex.noMaxOrder
-/

#print Sigma.Lex.noMinOrder /-
instance noMinOrder [Preorder ι] [∀ i, Preorder (α i)] [∀ i, NoMinOrder (α i)] :
    NoMinOrder (Σₗ i, α i) :=
  ⟨by rintro ⟨i, a⟩; obtain ⟨b, h⟩ := exists_lt a; exact ⟨⟨i, b⟩, right _ _ h⟩⟩
#align sigma.lex.no_min_order Sigma.Lex.noMinOrder
-/

end Lex

end Sigma

