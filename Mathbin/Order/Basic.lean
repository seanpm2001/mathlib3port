/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Mario Carneiro
-/
import Mathbin.Data.Prod.Basic
import Mathbin.Data.Subtype

/-!
# Basic definitions about `≤` and `<`

This file proves basic results about orders, provides extensive dot notation, defines useful order
classes and allows to transfer order instances.

## Type synonyms

* `order_dual α` : A type synonym reversing the meaning of all inequalities, with notation `αᵒᵈ`.
* `as_linear_order α`: A type synonym to promote `partial_order α` to `linear_order α` using
  `is_total α (≤)`.

### Transfering orders

- `order.preimage`, `preorder.lift`: Transfers a (pre)order on `β` to an order on `α`
  using a function `f : α → β`.
- `partial_order.lift`, `linear_order.lift`: Transfers a partial (resp., linear) order on `β` to a
  partial (resp., linear) order on `α` using an injective function `f`.

### Extra class

* `has_sup`: type class for the `⊔` notation
* `has_inf`: type class for the `⊓` notation
* `has_compl`: type class for the `ᶜ` notation
* `densely_ordered`: An order with no gap, i.e. for any two elements `a < b` there exists `c` such
  that `a < c < b`.

## Notes

`≤` and `<` are highly favored over `≥` and `>` in mathlib. The reason is that we can formulate all
lemmas using `≤`/`<`, and `rw` has trouble unifying `≤` and `≥`. Hence choosing one direction spares
us useless duplication. This is enforced by a linter. See Note [nolint_ge] for more infos.

Dot notation is particularly useful on `≤` (`has_le.le`) and `<` (`has_lt.lt`). To that end, we
provide many aliases to dot notation-less lemmas. For example, `le_trans` is aliased with
`has_le.le.trans` and can be used to construct `hab.trans hbc : a ≤ c` when `hab : a ≤ b`,
`hbc : b ≤ c`, `lt_of_le_of_lt` is aliased as `has_le.le.trans_lt` and can be used to construct
`hab.trans hbc : a < c` when `hab : a ≤ b`, `hbc : b < c`.

## TODO

- expand module docs
- automatic construction of dual definitions / theorems

## Tags

preorder, order, partial order, poset, linear order, chain
-/


open Function

universe u v w

variable {α : Type u} {β : Type v} {γ : Type w} {r : α → α → Prop}

section Preorder

variable [Preorder α] {a b c : α}

#print le_trans' /-
theorem le_trans' : b ≤ c → a ≤ b → a ≤ c :=
  flip le_trans
-/

#print lt_trans' /-
theorem lt_trans' : b < c → a < b → a < c :=
  flip lt_trans
-/

#print lt_of_le_of_lt' /-
theorem lt_of_le_of_lt' : b ≤ c → a < b → a < c :=
  flip lt_of_lt_of_le
-/

#print lt_of_lt_of_le' /-
theorem lt_of_lt_of_le' : b < c → a ≤ b → a < c :=
  flip lt_of_le_of_lt
-/

end Preorder

section PartialOrder

variable [PartialOrder α] {a b : α}

#print ge_antisymm /-
theorem ge_antisymm : a ≤ b → b ≤ a → b = a :=
  flip le_antisymm
-/

#print lt_of_le_of_ne' /-
theorem lt_of_le_of_ne' : a ≤ b → b ≠ a → a < b := fun h₁ h₂ => lt_of_le_of_ne h₁ h₂.symm
-/

theorem Ne.lt_of_le : a ≠ b → a ≤ b → a < b :=
  flip lt_of_le_of_ne

theorem Ne.lt_of_le' : b ≠ a → a ≤ b → a < b :=
  flip lt_of_le_of_ne'

end PartialOrder

attribute [simp] le_refl

attribute [ext] LE

alias le_trans ← LE.le.trans

alias le_trans' ← LE.le.trans'

alias lt_of_le_of_lt ← LE.le.trans_lt

alias lt_of_le_of_lt' ← LE.le.trans_lt'

alias le_antisymm ← LE.le.antisymm

alias ge_antisymm ← LE.le.antisymm'

alias lt_of_le_of_ne ← LE.le.lt_of_ne

alias lt_of_le_of_ne' ← LE.le.lt_of_ne'

alias lt_of_le_not_le ← LE.le.lt_of_not_le

alias lt_or_eq_of_le ← LE.le.lt_or_eq

alias Decidable.lt_or_eq_of_le ← LE.le.lt_or_eq_dec

alias le_of_lt ← LT.lt.le

alias lt_trans ← LT.lt.trans

alias lt_trans' ← LT.lt.trans'

alias lt_of_lt_of_le ← LT.lt.trans_le

alias lt_of_lt_of_le' ← LT.lt.trans_le'

alias ne_of_lt ← LT.lt.ne

alias lt_asymm ← LT.lt.asymm LT.lt.not_lt

alias le_of_eq ← Eq.le

attribute [nolint decidable_classical] LE.le.lt_or_eq_dec

section

variable [Preorder α] {a b c : α}

#print le_rfl /-
/-- A version of `le_refl` where the argument is implicit -/
theorem le_rfl : a ≤ a :=
  le_refl a
-/

#print lt_self_iff_false /-
@[simp]
theorem lt_self_iff_false (x : α) : x < x ↔ False :=
  ⟨lt_irrefl x, False.elim⟩
-/

#print le_of_le_of_eq /-
theorem le_of_le_of_eq (hab : a ≤ b) (hbc : b = c) : a ≤ c :=
  hab.trans hbc.le
-/

#print le_of_eq_of_le /-
theorem le_of_eq_of_le (hab : a = b) (hbc : b ≤ c) : a ≤ c :=
  hab.le.trans hbc
-/

#print lt_of_lt_of_eq /-
theorem lt_of_lt_of_eq (hab : a < b) (hbc : b = c) : a < c :=
  hab.trans_le hbc.le
-/

#print lt_of_eq_of_lt /-
theorem lt_of_eq_of_lt (hab : a = b) (hbc : b < c) : a < c :=
  hab.le.trans_lt hbc
-/

#print le_of_le_of_eq' /-
theorem le_of_le_of_eq' : b ≤ c → a = b → a ≤ c :=
  flip le_of_eq_of_le
-/

#print le_of_eq_of_le' /-
theorem le_of_eq_of_le' : b = c → a ≤ b → a ≤ c :=
  flip le_of_le_of_eq
-/

#print lt_of_lt_of_eq' /-
theorem lt_of_lt_of_eq' : b < c → a = b → a < c :=
  flip lt_of_eq_of_lt
-/

#print lt_of_eq_of_lt' /-
theorem lt_of_eq_of_lt' : b = c → a < b → a < c :=
  flip lt_of_lt_of_eq
-/

alias le_of_le_of_eq ← LE.le.trans_eq

alias le_of_le_of_eq' ← LE.le.trans_eq'

alias lt_of_lt_of_eq ← LT.lt.trans_eq

alias lt_of_lt_of_eq' ← LT.lt.trans_eq'

alias le_of_eq_of_le ← Eq.trans_le

alias le_of_eq_of_le' ← Eq.trans_ge

alias lt_of_eq_of_lt ← Eq.trans_lt

alias lt_of_eq_of_lt' ← Eq.trans_gt

end

namespace Eq

variable [Preorder α] {x y z : α}

#print Eq.ge /-
/-- If `x = y` then `y ≤ x`. Note: this lemma uses `y ≤ x` instead of `x ≥ y`, because `le` is used
almost exclusively in mathlib. -/
protected theorem ge (h : x = y) : y ≤ x :=
  h.symm.le
-/

#print Eq.not_lt /-
theorem not_lt (h : x = y) : ¬x < y := fun h' => h'.Ne h
-/

#print Eq.not_gt /-
theorem not_gt (h : x = y) : ¬y < x :=
  h.symm.not_lt
-/

end Eq

namespace LE.le

#print LE.le.ge /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem ge [LE α] {x y : α} (h : x ≤ y) : y ≥ x :=
  h
-/

#print LE.le.lt_iff_ne /-
theorem lt_iff_ne [PartialOrder α] {x y : α} (h : x ≤ y) : x < y ↔ x ≠ y :=
  ⟨fun h => h.Ne, h.lt_of_ne⟩
-/

#print LE.le.le_iff_eq /-
theorem le_iff_eq [PartialOrder α] {x y : α} (h : x ≤ y) : y ≤ x ↔ y = x :=
  ⟨fun h' => h'.antisymm h, Eq.le⟩
-/

#print LE.le.lt_or_le /-
theorem lt_or_le [LinearOrder α] {a b : α} (h : a ≤ b) (c : α) : a < c ∨ c ≤ b :=
  ((lt_or_ge a c).imp id) fun hc => le_trans hc h
-/

#print LE.le.le_or_lt /-
theorem le_or_lt [LinearOrder α] {a b : α} (h : a ≤ b) (c : α) : a ≤ c ∨ c < b :=
  ((le_or_gt a c).imp id) fun hc => lt_of_lt_of_le hc h
-/

#print LE.le.le_or_le /-
theorem le_or_le [LinearOrder α] {a b : α} (h : a ≤ b) (c : α) : a ≤ c ∨ c ≤ b :=
  (h.le_or_lt c).elim Or.inl fun h => Or.inr <| le_of_lt h
-/

end LE.le

namespace LT.lt

#print LT.lt.gt /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem gt [LT α] {x y : α} (h : x < y) : y > x :=
  h
-/

#print LT.lt.false /-
protected theorem false [Preorder α] {x : α} : x < x → False :=
  lt_irrefl x
-/

#print LT.lt.ne' /-
theorem ne' [Preorder α] {x y : α} (h : x < y) : y ≠ x :=
  h.Ne.symm
-/

#print LT.lt.lt_or_lt /-
theorem lt_or_lt [LinearOrder α] {x y : α} (h : x < y) (z : α) : x < z ∨ z < y :=
  (lt_or_ge z y).elim Or.inr fun hz => Or.inl <| h.trans_le hz
-/

end LT.lt

-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem GE.ge.le [LE α] {x y : α} (h : x ≥ y) : y ≤ x :=
  h

-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem GT.gt.lt [LT α] {x y : α} (h : x > y) : y < x :=
  h

#print ge_of_eq /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
theorem ge_of_eq [Preorder α] {a b : α} (h : a = b) : a ≥ b :=
  h.ge
-/

/- warning: ge_iff_le -> ge_iff_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : LE.{u} α] {a : α} {b : α}, Iff (GE.ge.{u} α _inst_1 a b) (LE.le.{u} α _inst_1 b a)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Basic._hyg.1350 : Preorder.{u} α] {a : α} {b : α}, Iff (GE.ge.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Basic._hyg.1350) a b) (LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Basic._hyg.1350) b a)
Case conversion may be inaccurate. Consider using '#align ge_iff_le ge_iff_leₓ'. -/
-- see Note [nolint_ge]
@[simp, nolint ge_or_gt]
theorem ge_iff_le [LE α] {a b : α} : a ≥ b ↔ b ≤ a :=
  Iff.rfl

/- warning: gt_iff_lt -> gt_iff_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : LT.{u} α] {a : α} {b : α}, Iff (GT.gt.{u} α _inst_1 a b) (LT.lt.{u} α _inst_1 b a)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Basic._hyg.1380 : Preorder.{u} α] {a : α} {b : α}, Iff (GT.gt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Basic._hyg.1380) a b) (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Basic._hyg.1380) b a)
Case conversion may be inaccurate. Consider using '#align gt_iff_lt gt_iff_ltₓ'. -/
-- see Note [nolint_ge]
@[simp, nolint ge_or_gt]
theorem gt_iff_lt [LT α] {a b : α} : a > b ↔ b < a :=
  Iff.rfl

#print not_le_of_lt /-
theorem not_le_of_lt [Preorder α] {a b : α} (h : a < b) : ¬b ≤ a :=
  (le_not_le_of_lt h).right
-/

alias not_le_of_lt ← LT.lt.not_le

#print not_lt_of_le /-
theorem not_lt_of_le [Preorder α] {a b : α} (h : a ≤ b) : ¬b < a := fun hba => hba.not_le h
-/

alias not_lt_of_le ← LE.le.not_lt

theorem ne_of_not_le [Preorder α] {a b : α} (h : ¬a ≤ b) : a ≠ b := fun hab => h (le_of_eq hab)

#print Decidable.le_iff_eq_or_lt /-
-- See Note [decidable namespace]
protected theorem Decidable.le_iff_eq_or_lt [PartialOrder α] [@DecidableRel α (· ≤ ·)] {a b : α} :
    a ≤ b ↔ a = b ∨ a < b :=
  Decidable.le_iff_lt_or_eq.trans or_comm
-/

#print le_iff_eq_or_lt /-
theorem le_iff_eq_or_lt [PartialOrder α] {a b : α} : a ≤ b ↔ a = b ∨ a < b :=
  le_iff_lt_or_eq.trans or_comm
-/

#print lt_iff_le_and_ne /-
theorem lt_iff_le_and_ne [PartialOrder α] {a b : α} : a < b ↔ a ≤ b ∧ a ≠ b :=
  ⟨fun h => ⟨le_of_lt h, ne_of_lt h⟩, fun ⟨h1, h2⟩ => h1.lt_of_ne h2⟩
-/

#print Decidable.eq_iff_le_not_lt /-
-- See Note [decidable namespace]
protected theorem Decidable.eq_iff_le_not_lt [PartialOrder α] [@DecidableRel α (· ≤ ·)] {a b : α} :
    a = b ↔ a ≤ b ∧ ¬a < b :=
  ⟨fun h => ⟨h.le, h ▸ lt_irrefl _⟩, fun ⟨h₁, h₂⟩ =>
    h₁.antisymm <| Decidable.by_contradiction fun h₃ => h₂ (h₁.lt_of_not_le h₃)⟩
-/

#print eq_iff_le_not_lt /-
theorem eq_iff_le_not_lt [PartialOrder α] {a b : α} : a = b ↔ a ≤ b ∧ ¬a < b :=
  haveI := Classical.dec
  Decidable.eq_iff_le_not_lt
-/

#print eq_or_lt_of_le /-
theorem eq_or_lt_of_le [PartialOrder α] {a b : α} (h : a ≤ b) : a = b ∨ a < b :=
  h.lt_or_eq.symm
-/

theorem eq_or_gt_of_le [PartialOrder α] {a b : α} (h : a ≤ b) : b = a ∨ a < b :=
  h.lt_or_eq.symm.imp Eq.symm id

alias Decidable.eq_or_lt_of_le ← LE.le.eq_or_lt_dec

alias eq_or_lt_of_le ← LE.le.eq_or_lt

alias eq_or_gt_of_le ← LE.le.eq_or_gt

attribute [nolint decidable_classical] LE.le.eq_or_lt_dec

theorem eq_of_le_of_not_lt [PartialOrder α] {a b : α} (hab : a ≤ b) (hba : ¬a < b) : a = b :=
  hab.eq_or_lt.resolve_right hba

theorem eq_of_ge_of_not_gt [PartialOrder α] {a b : α} (hab : a ≤ b) (hba : ¬a < b) : b = a :=
  (hab.eq_or_lt.resolve_right hba).symm

alias eq_of_le_of_not_lt ← LE.le.eq_of_not_lt

alias eq_of_ge_of_not_gt ← LE.le.eq_of_not_gt

theorem Ne.le_iff_lt [PartialOrder α] {a b : α} (h : a ≠ b) : a ≤ b ↔ a < b :=
  ⟨fun h' => lt_of_le_of_ne h' h, fun h => h.le⟩

theorem Ne.not_le_or_not_le [PartialOrder α] {a b : α} (h : a ≠ b) : ¬a ≤ b ∨ ¬b ≤ a :=
  not_and_or.1 <| le_antisymm_iff.Not.1 h

/- warning: decidable.ne_iff_lt_iff_le -> Decidable.ne_iff_lt_iff_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} [_inst_1 : PartialOrder.{u} α] [_inst_2 : DecidableEq.{succ u} α] {a : α} {b : α}, Iff (Iff (Ne.{succ u} α a b) (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α _inst_1)) a b)) (LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α _inst_1)) a b)
but is expected to have type
  forall {α : Type.{u}} [inst._@.Mathlib.Order.Basic._hyg.1901 : PartialOrder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.1904 : DecidableRel.{succ u} α (fun (x._@.Mathlib.Order.Basic._hyg.1910 : α) (x._@.Mathlib.Order.Basic._hyg.1912 : α) => LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α inst._@.Mathlib.Order.Basic._hyg.1901)) x._@.Mathlib.Order.Basic._hyg.1910 x._@.Mathlib.Order.Basic._hyg.1912)] {a : α} {b : α}, Iff (Iff (Ne.{succ u} α a b) (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α inst._@.Mathlib.Order.Basic._hyg.1901)) a b)) (LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α inst._@.Mathlib.Order.Basic._hyg.1901)) a b)
Case conversion may be inaccurate. Consider using '#align decidable.ne_iff_lt_iff_le Decidable.ne_iff_lt_iff_leₓ'. -/
-- See Note [decidable namespace]
protected theorem Decidable.ne_iff_lt_iff_le [PartialOrder α] [DecidableEq α] {a b : α} : (a ≠ b ↔ a < b) ↔ a ≤ b :=
  ⟨fun h => Decidable.byCases le_of_eq (le_of_lt ∘ h.mp), fun h => ⟨lt_of_le_of_ne h, ne_of_lt⟩⟩

#print ne_iff_lt_iff_le /-
@[simp]
theorem ne_iff_lt_iff_le [PartialOrder α] {a b : α} : (a ≠ b ↔ a < b) ↔ a ≤ b :=
  haveI := Classical.dec
  Decidable.ne_iff_lt_iff_le
-/

theorem lt_of_not_le [LinearOrder α] {a b : α} (h : ¬b ≤ a) : a < b :=
  ((le_total _ _).resolve_right h).lt_of_not_le h

theorem lt_iff_not_le [LinearOrder α] {x y : α} : x < y ↔ ¬y ≤ x :=
  ⟨not_le_of_lt, lt_of_not_le⟩

theorem Ne.lt_or_lt [LinearOrder α] {x y : α} (h : x ≠ y) : x < y ∨ y < x :=
  lt_or_gt_of_ne h

/-- A version of `ne_iff_lt_or_gt` with LHS and RHS reversed. -/
@[simp]
theorem lt_or_lt_iff_ne [LinearOrder α] {x y : α} : x < y ∨ y < x ↔ x ≠ y :=
  ne_iff_lt_or_gt.symm

#print not_lt_iff_eq_or_lt /-
theorem not_lt_iff_eq_or_lt [LinearOrder α] {a b : α} : ¬a < b ↔ a = b ∨ b < a :=
  not_lt.trans <| Decidable.le_iff_eq_or_lt.trans <| or_congr eq_comm Iff.rfl
-/

#print exists_ge_of_linear /-
theorem exists_ge_of_linear [LinearOrder α] (a b : α) : ∃ c, a ≤ c ∧ b ≤ c :=
  match le_total a b with
  | Or.inl h => ⟨_, h, le_rfl⟩
  | Or.inr h => ⟨_, le_rfl, h⟩
-/

/- warning: lt_imp_lt_of_le_imp_le -> lt_imp_lt_of_le_imp_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{u_1}} [_inst_1 : LinearOrder.{u} α] [_inst_2 : Preorder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, ((LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) a b) -> (LE.le.{u_1} β (Preorder.toLE.{u_1} β _inst_2) c d)) -> (LT.lt.{u_1} β (Preorder.toLT.{u_1} β _inst_2) d c) -> (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) b a)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{u_1}} [inst._@.Mathlib.Order.Basic._hyg.2267 : LinearOrder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.2270 : Preorder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, ((LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2267))) a b) -> (LE.le.{u_1} β (Preorder.toLE.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2270) c d)) -> (LT.lt.{u_1} β (Preorder.toLT.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2270) d c) -> (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2267))) b a)
Case conversion may be inaccurate. Consider using '#align lt_imp_lt_of_le_imp_le lt_imp_lt_of_le_imp_leₓ'. -/
theorem lt_imp_lt_of_le_imp_le {β} [LinearOrder α] [Preorder β] {a b : α} {c d : β} (H : a ≤ b → c ≤ d) (h : d < c) :
    b < a :=
  lt_of_not_le fun h' => (H h').not_lt h

/- warning: le_imp_le_iff_lt_imp_lt -> le_imp_le_iff_lt_imp_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{u_1}} [_inst_1 : LinearOrder.{u} α] [_inst_2 : LinearOrder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, Iff ((LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) a b) -> (LE.le.{u_1} β (Preorder.toLE.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β _inst_2))) c d)) ((LT.lt.{u_1} β (Preorder.toLT.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β _inst_2))) d c) -> (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) b a))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{u_1}} [inst._@.Mathlib.Order.Basic._hyg.2322 : LinearOrder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.2325 : LinearOrder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, Iff ((LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2322))) a b) -> (LE.le.{u_1} β (Preorder.toLE.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2325))) c d)) ((LT.lt.{u_1} β (Preorder.toLT.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2325))) d c) -> (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2322))) b a))
Case conversion may be inaccurate. Consider using '#align le_imp_le_iff_lt_imp_lt le_imp_le_iff_lt_imp_ltₓ'. -/
theorem le_imp_le_iff_lt_imp_lt {β} [LinearOrder α] [LinearOrder β] {a b : α} {c d : β} :
    a ≤ b → c ≤ d ↔ d < c → b < a :=
  ⟨lt_imp_lt_of_le_imp_le, le_imp_le_of_lt_imp_lt⟩

/- warning: lt_iff_lt_of_le_iff_le' -> lt_iff_lt_of_le_iff_le' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{u_1}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, (Iff (LE.le.{u} α (Preorder.toLE.{u} α _inst_1) a b) (LE.le.{u_1} β (Preorder.toLE.{u_1} β _inst_2) c d)) -> (Iff (LE.le.{u} α (Preorder.toLE.{u} α _inst_1) b a) (LE.le.{u_1} β (Preorder.toLE.{u_1} β _inst_2) d c)) -> (Iff (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) b a) (LT.lt.{u_1} β (Preorder.toLT.{u_1} β _inst_2) d c))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{u_1}} [inst._@.Mathlib.Order.Basic._hyg.2377 : Preorder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.2380 : Preorder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, (Iff (LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Basic._hyg.2377) a b) (LE.le.{u_1} β (Preorder.toLE.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2380) c d)) -> (Iff (LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Basic._hyg.2377) b a) (LE.le.{u_1} β (Preorder.toLE.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2380) d c)) -> (Iff (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Basic._hyg.2377) b a) (LT.lt.{u_1} β (Preorder.toLT.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2380) d c))
Case conversion may be inaccurate. Consider using '#align lt_iff_lt_of_le_iff_le' lt_iff_lt_of_le_iff_le'ₓ'. -/
theorem lt_iff_lt_of_le_iff_le' {β} [Preorder α] [Preorder β] {a b : α} {c d : β} (H : a ≤ b ↔ c ≤ d)
    (H' : b ≤ a ↔ d ≤ c) : b < a ↔ d < c :=
  lt_iff_le_not_le.trans <| (and_congr H' (not_congr H)).trans lt_iff_le_not_le.symm

/- warning: lt_iff_lt_of_le_iff_le -> lt_iff_lt_of_le_iff_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{u_1}} [_inst_1 : LinearOrder.{u} α] [_inst_2 : LinearOrder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, (Iff (LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) a b) (LE.le.{u_1} β (Preorder.toLE.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β _inst_2))) c d)) -> (Iff (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) b a) (LT.lt.{u_1} β (Preorder.toLT.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β _inst_2))) d c))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{u_1}} [inst._@.Mathlib.Order.Basic._hyg.2451 : LinearOrder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.2454 : LinearOrder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, (Iff (LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2451))) a b) (LE.le.{u_1} β (Preorder.toLE.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2454))) c d)) -> (Iff (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2451))) b a) (LT.lt.{u_1} β (Preorder.toLT.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2454))) d c))
Case conversion may be inaccurate. Consider using '#align lt_iff_lt_of_le_iff_le lt_iff_lt_of_le_iff_leₓ'. -/
theorem lt_iff_lt_of_le_iff_le {β} [LinearOrder α] [LinearOrder β] {a b : α} {c d : β} (H : a ≤ b ↔ c ≤ d) :
    b < a ↔ d < c :=
  not_le.symm.trans <| (not_congr H).trans <| not_le

/- warning: le_iff_le_iff_lt_iff_lt -> le_iff_le_iff_lt_iff_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{u_1}} [_inst_1 : LinearOrder.{u} α] [_inst_2 : LinearOrder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, Iff (Iff (LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) a b) (LE.le.{u_1} β (Preorder.toLE.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β _inst_2))) c d)) (Iff (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α _inst_1))) b a) (LT.lt.{u_1} β (Preorder.toLT.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β _inst_2))) d c))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{u_1}} [inst._@.Mathlib.Order.Basic._hyg.2510 : LinearOrder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.2513 : LinearOrder.{u_1} β] {a : α} {b : α} {c : β} {d : β}, Iff (Iff (LE.le.{u} α (Preorder.toLE.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2510))) a b) (LE.le.{u_1} β (Preorder.toLE.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2513))) c d)) (Iff (LT.lt.{u} α (Preorder.toLT.{u} α (PartialOrder.toPreorder.{u} α (LinearOrder.toPartialOrder.{u} α inst._@.Mathlib.Order.Basic._hyg.2510))) b a) (LT.lt.{u_1} β (Preorder.toLT.{u_1} β (PartialOrder.toPreorder.{u_1} β (LinearOrder.toPartialOrder.{u_1} β inst._@.Mathlib.Order.Basic._hyg.2513))) d c))
Case conversion may be inaccurate. Consider using '#align le_iff_le_iff_lt_iff_lt le_iff_le_iff_lt_iff_ltₓ'. -/
theorem le_iff_le_iff_lt_iff_lt {β} [LinearOrder α] [LinearOrder β] {a b : α} {c d : β} :
    (a ≤ b ↔ c ≤ d) ↔ (b < a ↔ d < c) :=
  ⟨lt_iff_lt_of_le_iff_le, fun H => not_lt.symm.trans <| (not_congr H).trans <| not_lt⟩

#print eq_of_forall_le_iff /-
theorem eq_of_forall_le_iff [PartialOrder α] {a b : α} (H : ∀ c, c ≤ a ↔ c ≤ b) : a = b :=
  ((H _).1 le_rfl).antisymm ((H _).2 le_rfl)
-/

#print le_of_forall_le /-
theorem le_of_forall_le [Preorder α] {a b : α} (H : ∀ c, c ≤ a → c ≤ b) : a ≤ b :=
  H _ le_rfl
-/

#print le_of_forall_le' /-
theorem le_of_forall_le' [Preorder α] {a b : α} (H : ∀ c, a ≤ c → b ≤ c) : b ≤ a :=
  H _ le_rfl
-/

#print le_of_forall_lt /-
theorem le_of_forall_lt [LinearOrder α] {a b : α} (H : ∀ c, c < a → c < b) : a ≤ b :=
  le_of_not_lt fun h => lt_irrefl _ (H _ h)
-/

#print forall_lt_iff_le /-
theorem forall_lt_iff_le [LinearOrder α] {a b : α} : (∀ ⦃c⦄, c < a → c < b) ↔ a ≤ b :=
  ⟨le_of_forall_lt, fun h c hca => lt_of_lt_of_le hca h⟩
-/

#print le_of_forall_lt' /-
theorem le_of_forall_lt' [LinearOrder α] {a b : α} (H : ∀ c, a < c → b < c) : b ≤ a :=
  le_of_not_lt fun h => lt_irrefl _ (H _ h)
-/

#print forall_lt_iff_le' /-
theorem forall_lt_iff_le' [LinearOrder α] {a b : α} : (∀ ⦃c⦄, a < c → b < c) ↔ b ≤ a :=
  ⟨le_of_forall_lt', fun h c hac => lt_of_le_of_lt h hac⟩
-/

#print eq_of_forall_ge_iff /-
theorem eq_of_forall_ge_iff [PartialOrder α] {a b : α} (H : ∀ c, a ≤ c ↔ b ≤ c) : a = b :=
  ((H _).2 le_rfl).antisymm ((H _).1 le_rfl)
-/

theorem eq_of_forall_lt_iff [LinearOrder α] {a b : α} (h : ∀ c, c < a ↔ c < b) : a = b :=
  (le_of_forall_lt fun _ => (h _).1).antisymm <| le_of_forall_lt fun _ => (h _).2

theorem eq_of_forall_gt_iff [LinearOrder α] {a b : α} (h : ∀ c, a < c ↔ b < c) : a = b :=
  (le_of_forall_lt' fun _ => (h _).2).antisymm <| le_of_forall_lt' fun _ => (h _).1

/-- A symmetric relation implies two values are equal, when it implies they're less-equal.  -/
theorem rel_imp_eq_of_rel_imp_le [PartialOrder β] (r : α → α → Prop) [IsSymm α r] {f : α → β}
    (h : ∀ a b, r a b → f a ≤ f b) {a b : α} : r a b → f a = f b := fun hab =>
  le_antisymm (h a b hab) (h b a <| symm hab)

#print le_implies_le_of_le_of_le /-
/-- monotonicity of `≤` with respect to `→` -/
theorem le_implies_le_of_le_of_le {a b c d : α} [Preorder α] (hca : c ≤ a) (hbd : b ≤ d) : a ≤ b → c ≤ d := fun hab =>
  (hca.trans hab).trans hbd
-/

@[ext]
theorem Preorder.to_has_le_injective {α : Type _} : Function.Injective (@Preorder.toLE α) := fun A B h => by
  cases A
  cases B
  injection h with h_le
  have : A_lt = B_lt := by
    funext a b
    dsimp [(· ≤ ·)] at A_lt_iff_le_not_le B_lt_iff_le_not_le h_le
    simp [A_lt_iff_le_not_le, B_lt_iff_le_not_le, h_le]
  congr

#print PartialOrder.to_preorder_injective /-
@[ext]
theorem PartialOrder.to_preorder_injective {α : Type _} : Function.Injective (@PartialOrder.toPreorder α) :=
  fun A B h => by
  cases A
  cases B
  injection h
  congr
-/

#print LinearOrder.to_partial_order_injective /-
@[ext]
theorem LinearOrder.to_partial_order_injective {α : Type _} : Function.Injective (@LinearOrder.toPartialOrder α) := by
  intro A B h
  cases A
  cases B
  injection h
  obtain rfl : A_le = B_le := ‹_›
  obtain rfl : A_lt = B_lt := ‹_›
  obtain rfl : A_decidable_le = B_decidable_le := Subsingleton.elim _ _
  obtain rfl : A_max = B_max := A_max_def.trans B_max_def.symm
  obtain rfl : A_min = B_min := A_min_def.trans B_min_def.symm
  congr
-/

#print Preorder.ext /-
theorem Preorder.ext {α} {A B : Preorder α}
    (H :
      ∀ x y : α,
        (haveI := A
          x ≤ y) ↔
          x ≤ y) :
    A = B := by
  ext (x y)
  exact H x y
-/

#print PartialOrder.ext /-
theorem PartialOrder.ext {α} {A B : PartialOrder α}
    (H :
      ∀ x y : α,
        (haveI := A
          x ≤ y) ↔
          x ≤ y) :
    A = B := by
  ext (x y)
  exact H x y
-/

#print LinearOrder.ext /-
theorem LinearOrder.ext {α} {A B : LinearOrder α}
    (H :
      ∀ x y : α,
        (haveI := A
          x ≤ y) ↔
          x ≤ y) :
    A = B := by
  ext (x y)
  exact H x y
-/

/-- Given a relation `R` on `β` and a function `f : α → β`, the preimage relation on `α` is defined
by `x ≤ y ↔ f x ≤ f y`. It is the unique relation on `α` making `f` a `rel_embedding` (assuming `f`
is injective). -/
@[simp]
def Order.Preimage {α β} (f : α → β) (s : β → β → Prop) (x y : α) : Prop :=
  s (f x) (f y)

-- mathport name: «expr ⁻¹'o »
infixl:80 " ⁻¹'o " => Order.Preimage

/-- The preimage of a decidable order is decidable. -/
instance Order.Preimage.decidable {α β} (f : α → β) (s : β → β → Prop) [H : DecidableRel s] : DecidableRel (f ⁻¹'o s) :=
  fun x y => H _ _

/-! ### Order dual -/


/-- Type synonym to equip a type with the dual order: `≤` means `≥` and `<` means `>`. `αᵒᵈ` is
notation for `order_dual α`. -/
def OrderDual (α : Type _) : Type _ :=
  α

-- mathport name: «expr ᵒᵈ»
notation:max α "ᵒᵈ" => OrderDual α

namespace OrderDual

instance (α : Type _) [h : Nonempty α] : Nonempty αᵒᵈ :=
  h

instance (α : Type _) [h : Subsingleton α] : Subsingleton αᵒᵈ :=
  h

instance (α : Type _) [LE α] : LE αᵒᵈ :=
  ⟨fun x y : α => y ≤ x⟩

instance (α : Type _) [LT α] : LT αᵒᵈ :=
  ⟨fun x y : α => y < x⟩

instance (α : Type _) [Preorder α] : Preorder αᵒᵈ :=
  { OrderDual.hasLe α, OrderDual.hasLt α with le_refl := le_refl, le_trans := fun a b c hab hbc => hbc.trans hab,
    lt_iff_le_not_le := fun _ _ => lt_iff_le_not_le }

instance (α : Type _) [PartialOrder α] : PartialOrder αᵒᵈ :=
  { OrderDual.preorder α with le_antisymm := fun a b hab hba => @le_antisymm α _ a b hba hab }

instance (α : Type _) [LinearOrder α] : LinearOrder αᵒᵈ :=
  { OrderDual.partialOrder α with le_total := fun a b : α => le_total b a,
    decidableLe := (inferInstance : DecidableRel fun a b : α => b ≤ a),
    decidableLt := (inferInstance : DecidableRel fun a b : α => b < a), min := @max α _, max := @min α _,
    min_def := @LinearOrder.max_def α _, max_def := @LinearOrder.min_def α _ }

instance : ∀ [Inhabited α], Inhabited αᵒᵈ :=
  id

theorem preorder.dual_dual (α : Type _) [H : Preorder α] : OrderDual.preorder αᵒᵈ = H :=
  Preorder.ext fun _ _ => Iff.rfl

theorem partialOrder.dual_dual (α : Type _) [H : PartialOrder α] : OrderDual.partialOrder αᵒᵈ = H :=
  PartialOrder.ext fun _ _ => Iff.rfl

theorem linearOrder.dual_dual (α : Type _) [H : LinearOrder α] : OrderDual.linearOrder αᵒᵈ = H :=
  LinearOrder.ext fun _ _ => Iff.rfl

end OrderDual

/-! ### `has_compl` -/


/-- Set / lattice complement -/
@[notation_class]
class HasCompl (α : Type _) where
  compl : α → α

export HasCompl (compl)

/- ./././Mathport/Syntax/Translate/Command.lean:435:9: unsupported: advanced prec syntax «expr + »(max[], 1) -/
-- mathport name: «expr ᶜ»
postfix:999 "ᶜ" => compl

instance PropCat.hasCompl : HasCompl Prop :=
  ⟨Not⟩

instance Pi.hasCompl {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] : HasCompl (∀ i, α i) :=
  ⟨fun x i => x iᶜ⟩

/- warning: pi.compl_def -> Pi.compl_def is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u}} {α : ι -> Type.{v}} [_inst_1 : forall (i : ι), HasCompl.{v} (α i)] (x : forall (i : ι), α i), Eq.{succ (max u v)} (forall (i : ι), α i) (HasCompl.compl.{(max u v)} (forall (i : ι), α i) (Pi.hasCompl.{u v} ι (fun (i : ι) => α i) (fun (i : ι) => _inst_1 i)) x) (fun (i : ι) => HasCompl.compl.{v} (α i) (_inst_1 i) (x i))
but is expected to have type
  forall {ι : Type.{u}} {α : ι -> Type.{v}} [inst._@.Mathlib.Order.Basic._hyg.6364 : forall (i : ι), Complement.{v} (α i)] (x : forall (i : ι), α i), Eq.{(max (succ u) (succ v))} (forall (i : ι), α i) (Complement.complement.{(max u v)} (forall (i : ι), α i) (Pi.complement.{u v} ι (fun (i : ι) => α i) (fun (i : ι) => inst._@.Mathlib.Order.Basic._hyg.6364 i)) x) (fun (i : ι) => Complement.complement.{v} (α i) (inst._@.Mathlib.Order.Basic._hyg.6364 i) (x i))
Case conversion may be inaccurate. Consider using '#align pi.compl_def Pi.compl_defₓ'. -/
theorem Pi.compl_def {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] (x : ∀ i, α i) : xᶜ = fun i => x iᶜ :=
  rfl

/- warning: pi.compl_apply -> Pi.compl_apply is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u}} {α : ι -> Type.{v}} [_inst_1 : forall (i : ι), HasCompl.{v} (α i)] (x : forall (i : ι), α i) (i : ι), Eq.{succ v} (α i) (HasCompl.compl.{(max u v)} (forall (i : ι), α i) (Pi.hasCompl.{u v} ι (fun (i : ι) => α i) (fun (i : ι) => _inst_1 i)) x i) (HasCompl.compl.{v} (α i) (_inst_1 i) (x i))
but is expected to have type
  forall {ι : Type.{u}} {α : ι -> Type.{v}} [inst._@.Mathlib.Order.Basic._hyg.6417 : forall (i : ι), Complement.{v} (α i)] (x : forall (i : ι), α i) (i : ι), Eq.{succ v} (α i) (Complement.complement.{(max u v)} (forall (i : ι), α i) (Pi.complement.{u v} ι (fun (i : ι) => α i) (fun (i : ι) => inst._@.Mathlib.Order.Basic._hyg.6417 i)) x i) (Complement.complement.{v} (α i) (inst._@.Mathlib.Order.Basic._hyg.6417 i) (x i))
Case conversion may be inaccurate. Consider using '#align pi.compl_apply Pi.compl_applyₓ'. -/
@[simp]
theorem Pi.compl_apply {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] (x : ∀ i, α i) (i : ι) : (xᶜ) i = x iᶜ :=
  rfl

instance IsIrrefl.compl (r) [IsIrrefl α r] : IsRefl α (rᶜ) :=
  ⟨@irrefl α r _⟩

instance IsRefl.compl (r) [IsRefl α r] : IsIrrefl α (rᶜ) :=
  ⟨fun a => not_not_intro (refl a)⟩

/-! ### Order instances on the function space -/


#print Pi.hasLe /-
instance Pi.hasLe {ι : Type u} {α : ι → Type v} [∀ i, LE (α i)] : LE (∀ i, α i) where le x y := ∀ i, x i ≤ y i
-/

#print Pi.le_def /-
theorem Pi.le_def {ι : Type u} {α : ι → Type v} [∀ i, LE (α i)] {x y : ∀ i, α i} : x ≤ y ↔ ∀ i, x i ≤ y i :=
  Iff.rfl
-/

#print Pi.preorder /-
instance Pi.preorder {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] : Preorder (∀ i, α i) :=
  { Pi.hasLe with le_refl := fun a i => le_refl (a i), le_trans := fun a b c h₁ h₂ i => le_trans (h₁ i) (h₂ i) }
-/

#print Pi.lt_def /-
theorem Pi.lt_def {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] {x y : ∀ i, α i} :
    x < y ↔ x ≤ y ∧ ∃ i, x i < y i := by simp (config := { contextual := true }) [lt_iff_le_not_le, Pi.le_def]
-/

section Pi

variable {ι : Type _} {π : ι → Type _}

/-- A function `a` is strongly less than a function `b`  if `a i < b i` for all `i`. -/
def StrongLt [∀ i, LT (π i)] (a b : ∀ i, π i) : Prop :=
  ∀ i, a i < b i

-- mathport name: «expr ≺ »
local infixl:50 " ≺ " => StrongLt

variable [∀ i, Preorder (π i)] {a b c : ∀ i, π i}

theorem le_of_strong_lt (h : a ≺ b) : a ≤ b := fun i => (h _).le

theorem lt_of_strong_lt [Nonempty ι] (h : a ≺ b) : a < b := by
  inhabit ι
  exact Pi.lt_def.2 ⟨le_of_strong_lt h, default, h _⟩

theorem strong_lt_of_strong_lt_of_le (hab : a ≺ b) (hbc : b ≤ c) : a ≺ c := fun i => (hab _).trans_le <| hbc _

theorem strong_lt_of_le_of_strong_lt (hab : a ≤ b) (hbc : b ≺ c) : a ≺ c := fun i => (hab _).trans_lt <| hbc _

alias le_of_strong_lt ← StrongLt.le

alias lt_of_strong_lt ← StrongLt.lt

alias strong_lt_of_strong_lt_of_le ← StrongLt.trans_le

alias strong_lt_of_le_of_strong_lt ← LE.le.trans_strong_lt

end Pi

/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print le_update_iff /-
theorem le_update_iff {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] [DecidableEq ι] {x y : ∀ i, α i} {i : ι}
    {a : α i} : x ≤ Function.update y i a ↔ x i ≤ a ∧ ∀ (j) (_ : j ≠ i), x j ≤ y j :=
  Function.forall_update_iff _ fun j z => x j ≤ z
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print update_le_iff /-
theorem update_le_iff {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] [DecidableEq ι] {x y : ∀ i, α i} {i : ι}
    {a : α i} : Function.update x i a ≤ y ↔ a ≤ y i ∧ ∀ (j) (_ : j ≠ i), x j ≤ y j :=
  Function.forall_update_iff _ fun j z => z ≤ y j
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print update_le_update_iff /-
theorem update_le_update_iff {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] [DecidableEq ι] {x y : ∀ i, α i}
    {i : ι} {a b : α i} : Function.update x i a ≤ Function.update y i b ↔ a ≤ b ∧ ∀ (j) (_ : j ≠ i), x j ≤ y j := by
  simp (config := { contextual := true }) [update_le_iff]
-/

instance Pi.partialOrder {ι : Type u} {α : ι → Type v} [∀ i, PartialOrder (α i)] : PartialOrder (∀ i, α i) :=
  { Pi.preorder with le_antisymm := fun f g h1 h2 => funext fun b => (h1 b).antisymm (h2 b) }

instance Pi.hasSdiff {ι : Type u} {α : ι → Type v} [∀ i, Sdiff (α i)] : Sdiff (∀ i, α i) :=
  ⟨fun x y i => x i \ y i⟩

theorem Pi.sdiff_def {ι : Type u} {α : ι → Type v} [∀ i, Sdiff (α i)] (x y : ∀ i, α i) : x \ y = fun i => x i \ y i :=
  rfl

@[simp]
theorem Pi.sdiff_apply {ι : Type u} {α : ι → Type v} [∀ i, Sdiff (α i)] (x y : ∀ i, α i) (i : ι) :
    (x \ y) i = x i \ y i :=
  rfl

namespace Function

variable [Preorder α] [Nonempty β] {a b : α}

@[simp]
theorem const_le_const : const β a ≤ const β b ↔ a ≤ b := by simp [Pi.le_def]

@[simp]
theorem const_lt_const : const β a < const β b ↔ a < b := by simpa [Pi.lt_def] using le_of_lt

end Function

/-! ### `min`/`max` recursors -/


section MinMaxRec

variable [LinearOrder α] {p : α → Prop} {x y : α}

theorem min_rec (hx : x ≤ y → p x) (hy : y ≤ x → p y) : p (min x y) :=
  (le_total x y).rec (fun h => (min_eq_left h).symm.subst (hx h)) fun h => (min_eq_right h).symm.subst (hy h)

theorem max_rec (hx : y ≤ x → p x) (hy : x ≤ y → p y) : p (max x y) :=
  @min_rec αᵒᵈ _ _ _ _ hx hy

theorem min_rec' (p : α → Prop) (hx : p x) (hy : p y) : p (min x y) :=
  min_rec (fun _ => hx) fun _ => hy

theorem max_rec' (p : α → Prop) (hx : p x) (hy : p y) : p (max x y) :=
  max_rec (fun _ => hx) fun _ => hy

theorem min_def' (x y : α) : min x y = if x < y then x else y := by
  rw [min_comm, min_def, ← ite_not]
  simp only [not_le]

theorem max_def' (x y : α) : max x y = if y < x then x else y := by
  rw [max_comm, max_def, ← ite_not]
  simp only [not_le]

end MinMaxRec

/-! ### `has_sup` and `has_inf` -/


/-- Typeclass for the `⊔` (`\lub`) notation -/
@[notation_class]
class HasSup (α : Type u) where
  sup : α → α → α

/-- Typeclass for the `⊓` (`\glb`) notation -/
@[notation_class]
class HasInf (α : Type u) where
  inf : α → α → α

-- mathport name: «expr ⊔ »
infixl:68 " ⊔ " => HasSup.sup

-- mathport name: «expr ⊓ »
infixl:69 " ⊓ " => HasInf.inf

/-! ### Lifts of order instances -/


#print Preorder.lift /-
/-- Transfer a `preorder` on `β` to a `preorder` on `α` using a function `f : α → β`.
See note [reducible non-instances]. -/
@[reducible]
def Preorder.lift {α β} [Preorder β] (f : α → β) : Preorder α where
  le x y := f x ≤ f y
  le_refl a := le_rfl
  le_trans a b c := le_trans
  lt x y := f x < f y
  lt_iff_le_not_le a b := lt_iff_le_not_le
-/

#print PartialOrder.lift /-
/-- Transfer a `partial_order` on `β` to a `partial_order` on `α` using an injective
function `f : α → β`. See note [reducible non-instances]. -/
@[reducible]
def PartialOrder.lift {α β} [PartialOrder β] (f : α → β) (inj : Injective f) : PartialOrder α :=
  { Preorder.lift f with le_antisymm := fun a b h₁ h₂ => inj (h₁.antisymm h₂) }
-/

/- warning: linear_order.lift -> LinearOrder.lift is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} {β : Type.{u_2}} [_inst_1 : LinearOrder.{u_2} β] [_inst_2 : HasSup.{u_1} α] [_inst_3 : HasInf.{u_1} α] (f : α -> β), (Function.Injective.{succ u_1 succ u_2} α β f) -> (forall (x : α) (y : α), Eq.{succ u_2} β (f (HasSup.sup.{u_1} α _inst_2 x y)) (LinearOrder.max.{u_2} β _inst_1 (f x) (f y))) -> (forall (x : α) (y : α), Eq.{succ u_2} β (f (HasInf.inf.{u_1} α _inst_3 x y)) (LinearOrder.min.{u_2} β _inst_1 (f x) (f y))) -> (LinearOrder.{u_1} α)
but is expected to have type
  forall {α : Type.{u_1}} {β : Type.{u_2}} [inst._@.Mathlib.Order.Basic._hyg.8527 : LinearOrder.{u_2} β] (f : α -> β), (Function.Injective.{succ u_1 succ u_2} α β f) -> (LinearOrder.{u_1} α)
Case conversion may be inaccurate. Consider using '#align linear_order.lift LinearOrder.liftₓ'. -/
/-- Transfer a `linear_order` on `β` to a `linear_order` on `α` using an injective
function `f : α → β`. This version takes `[has_sup α]` and `[has_inf α]` as arguments, then uses
them for `max` and `min` fields. See `linear_order.lift'` for a version that autogenerates `min` and
`max` fields. See note [reducible non-instances]. -/
@[reducible]
def LinearOrder.lift {α β} [LinearOrder β] [HasSup α] [HasInf α] (f : α → β) (inj : Injective f)
    (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y)) (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) : LinearOrder α :=
  { PartialOrder.lift f inj with le_total := fun x y => le_total (f x) (f y),
    decidableLe := fun x y => (inferInstance : Decidable (f x ≤ f y)),
    decidableLt := fun x y => (inferInstance : Decidable (f x < f y)),
    DecidableEq := fun x y => decidable_of_iff (f x = f y) inj.eq_iff, min := (· ⊓ ·), max := (· ⊔ ·),
    min_def := by
      ext (x y)
      apply inj
      rw [hinf, min_def, minDefault, apply_ite f]
      rfl,
    max_def := by
      ext (x y)
      apply inj
      rw [hsup, max_def, maxDefault, apply_ite f]
      rfl }

/-- Transfer a `linear_order` on `β` to a `linear_order` on `α` using an injective
function `f : α → β`. This version autogenerates `min` and `max` fields. See `linear_order.lift`
for a version that takes `[has_sup α]` and `[has_inf α]`, then uses them as `max` and `min`.
See note [reducible non-instances]. -/
@[reducible]
def LinearOrder.lift' {α β} [LinearOrder β] (f : α → β) (inj : Injective f) : LinearOrder α :=
  @LinearOrder.lift α β _ ⟨fun x y => if f y ≤ f x then x else y⟩ ⟨fun x y => if f x ≤ f y then x else y⟩ f inj
    (fun x y => (apply_ite f _ _ _).trans (max_def _ _).symm) fun x y => (apply_ite f _ _ _).trans (min_def _ _).symm

/-! ### Subtype of an order -/


namespace Subtype

instance [LE α] {p : α → Prop} : LE (Subtype p) :=
  ⟨fun x y => (x : α) ≤ y⟩

instance [LT α] {p : α → Prop} : LT (Subtype p) :=
  ⟨fun x y => (x : α) < y⟩

#print Subtype.mk_le_mk /-
@[simp]
theorem mk_le_mk [LE α] {p : α → Prop} {x y : α} {hx : p x} {hy : p y} : (⟨x, hx⟩ : Subtype p) ≤ ⟨y, hy⟩ ↔ x ≤ y :=
  Iff.rfl
-/

#print Subtype.mk_lt_mk /-
@[simp]
theorem mk_lt_mk [LT α] {p : α → Prop} {x y : α} {hx : p x} {hy : p y} : (⟨x, hx⟩ : Subtype p) < ⟨y, hy⟩ ↔ x < y :=
  Iff.rfl
-/

#print Subtype.coe_le_coe /-
@[simp, norm_cast]
theorem coe_le_coe [LE α] {p : α → Prop} {x y : Subtype p} : (x : α) ≤ y ↔ x ≤ y :=
  Iff.rfl
-/

#print Subtype.coe_lt_coe /-
@[simp, norm_cast]
theorem coe_lt_coe [LT α] {p : α → Prop} {x y : Subtype p} : (x : α) < y ↔ x < y :=
  Iff.rfl
-/

instance [Preorder α] (p : α → Prop) : Preorder (Subtype p) :=
  Preorder.lift (coe : Subtype p → α)

instance partialOrder [PartialOrder α] (p : α → Prop) : PartialOrder (Subtype p) :=
  PartialOrder.lift coe Subtype.coe_injective

instance decidableLe [Preorder α] [h : @DecidableRel α (· ≤ ·)] {p : α → Prop} : @DecidableRel (Subtype p) (· ≤ ·) :=
  fun a b => h a b

instance decidableLt [Preorder α] [h : @DecidableRel α (· < ·)] {p : α → Prop} : @DecidableRel (Subtype p) (· < ·) :=
  fun a b => h a b

/-- A subtype of a linear order is a linear order. We explicitly give the proofs of decidable
equality and decidable order in order to ensure the decidability instances are all definitionally
equal. -/
instance [LinearOrder α] (p : α → Prop) : LinearOrder (Subtype p) :=
  @LinearOrder.lift (Subtype p) _ _ ⟨fun x y => ⟨max x y, max_rec' _ x.2 y.2⟩⟩
    ⟨fun x y => ⟨min x y, min_rec' _ x.2 y.2⟩⟩ coe Subtype.coe_injective (fun _ _ => rfl) fun _ _ => rfl

end Subtype

/-!
### Pointwise order on `α × β`

The lexicographic order is defined in `data.prod.lex`, and the instances are available via the
type synonym `α ×ₗ β = α × β`.
-/


namespace Prod

instance (α : Type u) (β : Type v) [LE α] [LE β] : LE (α × β) :=
  ⟨fun p q => p.1 ≤ q.1 ∧ p.2 ≤ q.2⟩

/- warning: prod.le_def -> Prod.le_def is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : LE.{u} α] [_inst_2 : LE.{v} β] {x : Prod.{u v} α β} {y : Prod.{u v} α β}, Iff (LE.le.{(max u v)} (Prod.{u v} α β) (Prod.hasLe.{u v} α β _inst_1 _inst_2) x y) (And (LE.le.{u} α _inst_1 (Prod.fst.{u v} α β x) (Prod.fst.{u v} α β y)) (LE.le.{v} β _inst_2 (Prod.snd.{u v} α β x) (Prod.snd.{u v} α β y)))
but is expected to have type
  forall {α : Type.{u_1}} {β : Type.{u_2}} [inst._@.Mathlib.Order.Basic._hyg.9135 : LE.{u_1} α] [inst._@.Mathlib.Order.Basic._hyg.9138 : LE.{u_2} β] {x : Prod.{u_1 u_2} α β} {y : Prod.{u_1 u_2} α β}, Iff (LE.le.{(max u_1 u_2)} (Prod.{u_1 u_2} α β) (Prod.has_le.{u_1 u_2} α β inst._@.Mathlib.Order.Basic._hyg.9135 inst._@.Mathlib.Order.Basic._hyg.9138) x y) (And (LE.le.{u_1} α inst._@.Mathlib.Order.Basic._hyg.9135 (Prod.fst.{u_1 u_2} α β x) (Prod.fst.{u_1 u_2} α β y)) (LE.le.{u_2} β inst._@.Mathlib.Order.Basic._hyg.9138 (Prod.snd.{u_1 u_2} α β x) (Prod.snd.{u_1 u_2} α β y)))
Case conversion may be inaccurate. Consider using '#align prod.le_def Prod.le_defₓ'. -/
theorem le_def [LE α] [LE β] {x y : α × β} : x ≤ y ↔ x.1 ≤ y.1 ∧ x.2 ≤ y.2 :=
  Iff.rfl

/- warning: prod.mk_le_mk -> Prod.mk_le_mk is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : LE.{u} α] [_inst_2 : LE.{v} β] {x₁ : α} {x₂ : α} {y₁ : β} {y₂ : β}, Iff (LE.le.{(max u v)} (Prod.{u v} α β) (Prod.hasLe.{u v} α β _inst_1 _inst_2) (Prod.mk.{u v} α β x₁ y₁) (Prod.mk.{u v} α β x₂ y₂)) (And (LE.le.{u} α _inst_1 x₁ x₂) (LE.le.{v} β _inst_2 y₁ y₂))
but is expected to have type
  forall {α : Type.{u_1}} {β : Type.{u_2}} [inst._@.Mathlib.Order.Basic._hyg.9186 : LE.{u_1} α] [inst._@.Mathlib.Order.Basic._hyg.9189 : LE.{u_2} β] {x₁ : α} {x₂ : α} {y₁ : β} {y₂ : β}, Iff (LE.le.{(max u_1 u_2)} (Prod.{u_1 u_2} α β) (Prod.has_le.{u_1 u_2} α β inst._@.Mathlib.Order.Basic._hyg.9186 inst._@.Mathlib.Order.Basic._hyg.9189) (Prod.mk.{u_1 u_2} α β x₁ y₁) (Prod.mk.{u_1 u_2} α β x₂ y₂)) (And (LE.le.{u_1} α inst._@.Mathlib.Order.Basic._hyg.9186 x₁ x₂) (LE.le.{u_2} β inst._@.Mathlib.Order.Basic._hyg.9189 y₁ y₂))
Case conversion may be inaccurate. Consider using '#align prod.mk_le_mk Prod.mk_le_mkₓ'. -/
@[simp]
theorem mk_le_mk [LE α] [LE β] {x₁ x₂ : α} {y₁ y₂ : β} : (x₁, y₁) ≤ (x₂, y₂) ↔ x₁ ≤ x₂ ∧ y₁ ≤ y₂ :=
  Iff.rfl

#print Prod.swap_le_swap /-
@[simp]
theorem swap_le_swap [LE α] [LE β] {x y : α × β} : x.swap ≤ y.swap ↔ x ≤ y :=
  and_comm' _ _
-/

section Preorder

variable [Preorder α] [Preorder β] {a a₁ a₂ : α} {b b₁ b₂ : β} {x y : α × β}

instance (α : Type u) (β : Type v) [Preorder α] [Preorder β] : Preorder (α × β) :=
  { Prod.hasLe α β with le_refl := fun ⟨a, b⟩ => ⟨le_refl a, le_refl b⟩,
    le_trans := fun ⟨a, b⟩ ⟨c, d⟩ ⟨e, f⟩ ⟨hac, hbd⟩ ⟨hce, hdf⟩ => ⟨le_trans hac hce, le_trans hbd hdf⟩ }

/- warning: prod.swap_lt_swap -> Prod.swap_lt_swap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β] {x : Prod.{u v} α β} {y : Prod.{u v} α β}, Iff (LT.lt.{(max v u)} (Prod.{v u} β α) (Preorder.toLT.{(max v u)} (Prod.{v u} β α) (Prod.preorder.{v u} β α _inst_2 _inst_1)) (Prod.swap.{u v} α β x) (Prod.swap.{u v} α β y)) (LT.lt.{(max u v)} (Prod.{u v} α β) (Preorder.toLT.{(max u v)} (Prod.{u v} α β) (Prod.preorder.{u v} α β _inst_1 _inst_2)) x y)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Basic._hyg.9547 : Preorder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.9550 : Preorder.{v} β] {x : Prod.{u v} α β} {y : Prod.{u v} α β}, Iff (LT.lt.{(max u v)} (Prod.{v u} β α) (Preorder.toLT.{(max u v)} (Prod.{v u} β α) (Prod.instPreorderProd.{v u} β α inst._@.Mathlib.Order.Basic._hyg.9550 inst._@.Mathlib.Order.Basic._hyg.9547)) (Prod.swap.{u v} α β x) (Prod.swap.{u v} α β y)) (LT.lt.{(max v u)} (Prod.{u v} α β) (Preorder.toLT.{(max v u)} (Prod.{u v} α β) (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Basic._hyg.9547 inst._@.Mathlib.Order.Basic._hyg.9550)) x y)
Case conversion may be inaccurate. Consider using '#align prod.swap_lt_swap Prod.swap_lt_swapₓ'. -/
@[simp]
theorem swap_lt_swap : x.swap < y.swap ↔ x < y :=
  and_congr swap_le_swap (not_congr swap_le_swap)

#print Prod.mk_le_mk_iff_left /-
theorem mk_le_mk_iff_left : (a₁, b) ≤ (a₂, b) ↔ a₁ ≤ a₂ :=
  and_iff_left le_rfl
-/

#print Prod.mk_le_mk_iff_right /-
theorem mk_le_mk_iff_right : (a, b₁) ≤ (a, b₂) ↔ b₁ ≤ b₂ :=
  and_iff_right le_rfl
-/

/- warning: prod.mk_lt_mk_iff_left -> Prod.mk_lt_mk_iff_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β] {a₁ : α} {a₂ : α} {b : β}, Iff (LT.lt.{(max u v)} (Prod.{u v} α β) (Preorder.toLT.{(max u v)} (Prod.{u v} α β) (Prod.preorder.{u v} α β _inst_1 _inst_2)) (Prod.mk.{u v} α β a₁ b) (Prod.mk.{u v} α β a₂ b)) (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) a₁ a₂)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Basic._hyg.9721 : Preorder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.9724 : Preorder.{v} β] {a₁ : α} {a₂ : α} {b : β}, Iff (LT.lt.{(max v u)} (Prod.{u v} α β) (Preorder.toLT.{(max v u)} (Prod.{u v} α β) (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Basic._hyg.9721 inst._@.Mathlib.Order.Basic._hyg.9724)) (Prod.mk.{u v} α β a₁ b) (Prod.mk.{u v} α β a₂ b)) (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Basic._hyg.9721) a₁ a₂)
Case conversion may be inaccurate. Consider using '#align prod.mk_lt_mk_iff_left Prod.mk_lt_mk_iff_leftₓ'. -/
theorem mk_lt_mk_iff_left : (a₁, b) < (a₂, b) ↔ a₁ < a₂ :=
  lt_iff_lt_of_le_iff_le' mk_le_mk_iff_left mk_le_mk_iff_left

/- warning: prod.mk_lt_mk_iff_right -> Prod.mk_lt_mk_iff_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β] {a : α} {b₁ : β} {b₂ : β}, Iff (LT.lt.{(max u v)} (Prod.{u v} α β) (Preorder.toLT.{(max u v)} (Prod.{u v} α β) (Prod.preorder.{u v} α β _inst_1 _inst_2)) (Prod.mk.{u v} α β a b₁) (Prod.mk.{u v} α β a b₂)) (LT.lt.{v} β (Preorder.toLT.{v} β _inst_2) b₁ b₂)
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Basic._hyg.9781 : Preorder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.9784 : Preorder.{v} β] {a : α} {b₁ : β} {b₂ : β}, Iff (LT.lt.{(max v u)} (Prod.{u v} α β) (Preorder.toLT.{(max v u)} (Prod.{u v} α β) (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Basic._hyg.9781 inst._@.Mathlib.Order.Basic._hyg.9784)) (Prod.mk.{u v} α β a b₁) (Prod.mk.{u v} α β a b₂)) (LT.lt.{v} β (Preorder.toLT.{v} β inst._@.Mathlib.Order.Basic._hyg.9784) b₁ b₂)
Case conversion may be inaccurate. Consider using '#align prod.mk_lt_mk_iff_right Prod.mk_lt_mk_iff_rightₓ'. -/
theorem mk_lt_mk_iff_right : (a, b₁) < (a, b₂) ↔ b₁ < b₂ :=
  lt_iff_lt_of_le_iff_le' mk_le_mk_iff_right mk_le_mk_iff_right

/- warning: prod.lt_iff -> Prod.lt_iff is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β] {x : Prod.{u v} α β} {y : Prod.{u v} α β}, Iff (LT.lt.{(max u v)} (Prod.{u v} α β) (Preorder.toLT.{(max u v)} (Prod.{u v} α β) (Prod.preorder.{u v} α β _inst_1 _inst_2)) x y) (Or (And (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) (Prod.fst.{u v} α β x) (Prod.fst.{u v} α β y)) (LE.le.{v} β (Preorder.toLE.{v} β _inst_2) (Prod.snd.{u v} α β x) (Prod.snd.{u v} α β y))) (And (LE.le.{u} α (Preorder.toLE.{u} α _inst_1) (Prod.fst.{u v} α β x) (Prod.fst.{u v} α β y)) (LT.lt.{v} β (Preorder.toLT.{v} β _inst_2) (Prod.snd.{u v} α β x) (Prod.snd.{u v} α β y))))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Basic._hyg.9841 : Preorder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.9844 : Preorder.{v} β] {x : Prod.{u v} α β} {y : Prod.{u v} α β}, Iff (LT.lt.{(max v u)} (Prod.{u v} α β) (Preorder.toLT.{(max v u)} (Prod.{u v} α β) (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Basic._hyg.9841 inst._@.Mathlib.Order.Basic._hyg.9844)) x y) (Or (And (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Basic._hyg.9841) (Prod.fst.{u v} α β x) (Prod.fst.{u v} α β y)) (LE.le.{v} β (Preorder.toLE.{v} β inst._@.Mathlib.Order.Basic._hyg.9844) (Prod.snd.{u v} α β x) (Prod.snd.{u v} α β y))) (And (LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Basic._hyg.9841) (Prod.fst.{u v} α β x) (Prod.fst.{u v} α β y)) (LT.lt.{v} β (Preorder.toLT.{v} β inst._@.Mathlib.Order.Basic._hyg.9844) (Prod.snd.{u v} α β x) (Prod.snd.{u v} α β y))))
Case conversion may be inaccurate. Consider using '#align prod.lt_iff Prod.lt_iffₓ'. -/
theorem lt_iff : x < y ↔ x.1 < y.1 ∧ x.2 ≤ y.2 ∨ x.1 ≤ y.1 ∧ x.2 < y.2 := by
  refine' ⟨fun h => _, _⟩
  · by_cases h₁:y.1 ≤ x.1
    · exact Or.inr ⟨h.1.1, h.1.2.lt_of_not_le fun h₂ => h.2 ⟨h₁, h₂⟩⟩
      
    · exact Or.inl ⟨h.1.1.lt_of_not_le h₁, h.1.2⟩
      
    
  · rintro (⟨h₁, h₂⟩ | ⟨h₁, h₂⟩)
    · exact ⟨⟨h₁.le, h₂⟩, fun h => h₁.not_le h.1⟩
      
    · exact ⟨⟨h₁, h₂.le⟩, fun h => h₂.not_le h.2⟩
      
    

/- warning: prod.mk_lt_mk -> Prod.mk_lt_mk is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u}} {β : Type.{v}} [_inst_1 : Preorder.{u} α] [_inst_2 : Preorder.{v} β] {a₁ : α} {a₂ : α} {b₁ : β} {b₂ : β}, Iff (LT.lt.{(max u v)} (Prod.{u v} α β) (Preorder.toLT.{(max u v)} (Prod.{u v} α β) (Prod.preorder.{u v} α β _inst_1 _inst_2)) (Prod.mk.{u v} α β a₁ b₁) (Prod.mk.{u v} α β a₂ b₂)) (Or (And (LT.lt.{u} α (Preorder.toLT.{u} α _inst_1) a₁ a₂) (LE.le.{v} β (Preorder.toLE.{v} β _inst_2) b₁ b₂)) (And (LE.le.{u} α (Preorder.toLE.{u} α _inst_1) a₁ a₂) (LT.lt.{v} β (Preorder.toLT.{v} β _inst_2) b₁ b₂)))
but is expected to have type
  forall {α : Type.{u}} {β : Type.{v}} [inst._@.Mathlib.Order.Basic._hyg.10004 : Preorder.{u} α] [inst._@.Mathlib.Order.Basic._hyg.10007 : Preorder.{v} β] {a₁ : α} {a₂ : α} {b₁ : β} {b₂ : β}, Iff (LT.lt.{(max v u)} (Prod.{u v} α β) (Preorder.toLT.{(max v u)} (Prod.{u v} α β) (Prod.instPreorderProd.{u v} α β inst._@.Mathlib.Order.Basic._hyg.10004 inst._@.Mathlib.Order.Basic._hyg.10007)) (Prod.mk.{u v} α β a₁ b₁) (Prod.mk.{u v} α β a₂ b₂)) (Or (And (LT.lt.{u} α (Preorder.toLT.{u} α inst._@.Mathlib.Order.Basic._hyg.10004) a₁ a₂) (LE.le.{v} β (Preorder.toLE.{v} β inst._@.Mathlib.Order.Basic._hyg.10007) b₁ b₂)) (And (LE.le.{u} α (Preorder.toLE.{u} α inst._@.Mathlib.Order.Basic._hyg.10004) a₁ a₂) (LT.lt.{v} β (Preorder.toLT.{v} β inst._@.Mathlib.Order.Basic._hyg.10007) b₁ b₂)))
Case conversion may be inaccurate. Consider using '#align prod.mk_lt_mk Prod.mk_lt_mkₓ'. -/
@[simp]
theorem mk_lt_mk : (a₁, b₁) < (a₂, b₂) ↔ a₁ < a₂ ∧ b₁ ≤ b₂ ∨ a₁ ≤ a₂ ∧ b₁ < b₂ :=
  lt_iff

end Preorder

/-- The pointwise partial order on a product.
    (The lexicographic ordering is defined in order/lexicographic.lean, and the instances are
    available via the type synonym `α ×ₗ β = α × β`.) -/
instance (α : Type u) (β : Type v) [PartialOrder α] [PartialOrder β] : PartialOrder (α × β) :=
  { Prod.preorder α β with
    le_antisymm := fun ⟨a, b⟩ ⟨c, d⟩ ⟨hac, hbd⟩ ⟨hca, hdb⟩ => Prod.ext (hac.antisymm hca) (hbd.antisymm hdb) }

end Prod

/-! ### Additional order classes -/


#print DenselyOrdered /-
/-- An order is dense if there is an element between any pair of distinct comparable elements. -/
class DenselyOrdered (α : Type u) [LT α] : Prop where
  dense : ∀ a₁ a₂ : α, a₁ < a₂ → ∃ a, a₁ < a ∧ a < a₂
-/

#print exists_between /-
theorem exists_between [LT α] [DenselyOrdered α] : ∀ {a₁ a₂ : α}, a₁ < a₂ → ∃ a, a₁ < a ∧ a < a₂ :=
  DenselyOrdered.dense
-/

instance OrderDual.densely_ordered (α : Type u) [LT α] [DenselyOrdered α] : DenselyOrdered αᵒᵈ :=
  ⟨fun a₁ a₂ ha => (@exists_between α _ _ _ _ ha).imp fun a => And.symm⟩

#print le_of_forall_le_of_dense /-
theorem le_of_forall_le_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α} (h : ∀ a, a₂ < a → a₁ ≤ a) : a₁ ≤ a₂ :=
  le_of_not_gt fun ha =>
    let ⟨a, ha₁, ha₂⟩ := exists_between ha
    lt_irrefl a <| lt_of_lt_of_le ‹a < a₁› (h _ ‹a₂ < a›)
-/

#print eq_of_le_of_forall_le_of_dense /-
theorem eq_of_le_of_forall_le_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α} (h₁ : a₂ ≤ a₁)
    (h₂ : ∀ a, a₂ < a → a₁ ≤ a) : a₁ = a₂ :=
  le_antisymm (le_of_forall_le_of_dense h₂) h₁
-/

#print le_of_forall_ge_of_dense /-
theorem le_of_forall_ge_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α} (h : ∀ a₃ < a₁, a₃ ≤ a₂) : a₁ ≤ a₂ :=
  le_of_not_gt fun ha =>
    let ⟨a, ha₁, ha₂⟩ := exists_between ha
    lt_irrefl a <| lt_of_le_of_lt (h _ ‹a < a₁›) ‹a₂ < a›
-/

#print eq_of_le_of_forall_ge_of_dense /-
theorem eq_of_le_of_forall_ge_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α} (h₁ : a₂ ≤ a₁)
    (h₂ : ∀ a₃ < a₁, a₃ ≤ a₂) : a₁ = a₂ :=
  (le_of_forall_ge_of_dense h₂).antisymm h₁
-/

#print dense_or_discrete /-
theorem dense_or_discrete [LinearOrder α] (a₁ a₂ : α) :
    (∃ a, a₁ < a ∧ a < a₂) ∨ (∀ a, a₁ < a → a₂ ≤ a) ∧ ∀ a < a₂, a ≤ a₁ :=
  or_iff_not_imp_left.2 fun h =>
    ⟨fun a ha₁ => le_of_not_gt fun ha₂ => h ⟨a, ha₁, ha₂⟩, fun a ha₂ => le_of_not_gt fun ha₁ => h ⟨a, ha₁, ha₂⟩⟩
-/

namespace PUnit

variable (a b : PUnit.{u + 1})

instance : LinearOrder PUnit := by
  refine_struct
      { le := fun _ _ => True, lt := fun _ _ => False, max := fun _ _ => star, min := fun _ _ => star,
        DecidableEq := PUnit.decidableEq, decidableLe := fun _ _ => Decidable.true,
        decidableLt := fun _ _ => Decidable.false } <;>
    intros <;> first |trivial|simp only [eq_iff_true_of_subsingleton, not_true, and_false_iff]|exact Or.inl trivial

theorem max_eq : max a b = star :=
  rfl

theorem min_eq : min a b = star :=
  rfl

@[simp]
protected theorem le : a ≤ b :=
  trivial

@[simp]
theorem not_lt : ¬a < b :=
  not_false

instance : DenselyOrdered PUnit :=
  ⟨fun _ _ => False.elim⟩

end PUnit

section Prop

/- ./././Mathport/Syntax/Translate/Expr.lean:219:4: warning: unsupported binary notation `«->» -/
/-- Propositions form a complete boolean algebra, where the `≤` relation is given by implication. -/
instance PropCat.hasLe : LE Prop :=
  ⟨(«->» · ·)⟩

/- ./././Mathport/Syntax/Translate/Expr.lean:219:4: warning: unsupported binary notation `«->» -/
@[simp]
theorem le_Prop_eq : ((· ≤ ·) : Prop → Prop → Prop) = («->» · ·) :=
  rfl

theorem subrelation_iff_le {r s : α → α → Prop} : Subrelation r s ↔ r ≤ s :=
  Iff.rfl

instance PropCat.partialOrder : PartialOrder Prop :=
  { PropCat.hasLe with le_refl := fun _ => id, le_trans := fun a b c f g => g ∘ f,
    le_antisymm := fun a b Hab Hba => propext ⟨Hab, Hba⟩ }

end Prop

variable {s : β → β → Prop} {t : γ → γ → Prop}

/-! ### Linear order from a total partial order -/


/-- Type synonym to create an instance of `linear_order` from a `partial_order` and
`is_total α (≤)` -/
def AsLinearOrder (α : Type u) :=
  α

instance {α} [Inhabited α] : Inhabited (AsLinearOrder α) :=
  ⟨(default : α)⟩

noncomputable instance AsLinearOrder.linearOrder {α} [PartialOrder α] [IsTotal α (· ≤ ·)] :
    LinearOrder (AsLinearOrder α) :=
  { (_ : PartialOrder α) with le_total := @total_of α (· ≤ ·) _, decidableLe := Classical.decRel _ }

