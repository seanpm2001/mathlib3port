/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Mario Carneiro

! This file was ported from Lean 3 source module order.basic
! leanprover-community/mathlib commit 90df25ded755a2cf9651ea850d1abe429b1e4eb1
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Prod.Basic
import Mathbin.Data.Subtype

/-!
# Basic definitions about `≤` and `<`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

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

variable {ι : Type _} {α : Type u} {β : Type v} {γ : Type w} {π : ι → Type _} {r : α → α → Prop}

section Preorder

variable [Preorder α] {a b c : α}

#print le_trans' /-
theorem le_trans' : b ≤ c → a ≤ b → a ≤ c :=
  flip le_trans
#align le_trans' le_trans'
-/

#print lt_trans' /-
theorem lt_trans' : b < c → a < b → a < c :=
  flip lt_trans
#align lt_trans' lt_trans'
-/

#print lt_of_le_of_lt' /-
theorem lt_of_le_of_lt' : b ≤ c → a < b → a < c :=
  flip lt_of_lt_of_le
#align lt_of_le_of_lt' lt_of_le_of_lt'
-/

#print lt_of_lt_of_le' /-
theorem lt_of_lt_of_le' : b < c → a ≤ b → a < c :=
  flip lt_of_le_of_lt
#align lt_of_lt_of_le' lt_of_lt_of_le'
-/

end Preorder

section PartialOrder

variable [PartialOrder α] {a b : α}

#print ge_antisymm /-
theorem ge_antisymm : a ≤ b → b ≤ a → b = a :=
  flip le_antisymm
#align ge_antisymm ge_antisymm
-/

#print lt_of_le_of_ne' /-
theorem lt_of_le_of_ne' : a ≤ b → b ≠ a → a < b := fun h₁ h₂ => lt_of_le_of_ne h₁ h₂.symm
#align lt_of_le_of_ne' lt_of_le_of_ne'
-/

#print Ne.lt_of_le /-
theorem Ne.lt_of_le : a ≠ b → a ≤ b → a < b :=
  flip lt_of_le_of_ne
#align ne.lt_of_le Ne.lt_of_le
-/

#print Ne.lt_of_le' /-
theorem Ne.lt_of_le' : b ≠ a → a ≤ b → a < b :=
  flip lt_of_le_of_ne'
#align ne.lt_of_le' Ne.lt_of_le'
-/

end PartialOrder

attribute [simp] le_refl

attribute [ext] LE

alias le_trans ← LE.le.trans
#align has_le.le.trans LE.le.trans

alias le_trans' ← LE.le.trans'
#align has_le.le.trans' LE.le.trans'

alias lt_of_le_of_lt ← LE.le.trans_lt
#align has_le.le.trans_lt LE.le.trans_lt

alias lt_of_le_of_lt' ← LE.le.trans_lt'
#align has_le.le.trans_lt' LE.le.trans_lt'

alias le_antisymm ← LE.le.antisymm
#align has_le.le.antisymm LE.le.antisymm

alias ge_antisymm ← LE.le.antisymm'
#align has_le.le.antisymm' LE.le.antisymm'

alias lt_of_le_of_ne ← LE.le.lt_of_ne
#align has_le.le.lt_of_ne LE.le.lt_of_ne

alias lt_of_le_of_ne' ← LE.le.lt_of_ne'
#align has_le.le.lt_of_ne' LE.le.lt_of_ne'

alias lt_of_le_not_le ← LE.le.lt_of_not_le
#align has_le.le.lt_of_not_le LE.le.lt_of_not_le

alias lt_or_eq_of_le ← LE.le.lt_or_eq
#align has_le.le.lt_or_eq LE.le.lt_or_eq

alias Decidable.lt_or_eq_of_le ← LE.le.lt_or_eq_dec
#align has_le.le.lt_or_eq_dec LE.le.lt_or_eq_dec

alias le_of_lt ← LT.lt.le
#align has_lt.lt.le LT.lt.le

alias lt_trans ← LT.lt.trans
#align has_lt.lt.trans LT.lt.trans

alias lt_trans' ← LT.lt.trans'
#align has_lt.lt.trans' LT.lt.trans'

alias lt_of_lt_of_le ← LT.lt.trans_le
#align has_lt.lt.trans_le LT.lt.trans_le

alias lt_of_lt_of_le' ← LT.lt.trans_le'
#align has_lt.lt.trans_le' LT.lt.trans_le'

alias ne_of_lt ← LT.lt.ne
#align has_lt.lt.ne LT.lt.ne

alias lt_asymm ← LT.lt.asymm LT.lt.not_lt
#align has_lt.lt.asymm LT.lt.asymm
#align has_lt.lt.not_lt LT.lt.not_lt

alias le_of_eq ← Eq.le
#align eq.le Eq.le

attribute [nolint decidable_classical] LE.le.lt_or_eq_dec

section

variable [Preorder α] {a b c : α}

#print le_rfl /-
/-- A version of `le_refl` where the argument is implicit -/
theorem le_rfl : a ≤ a :=
  le_refl a
#align le_rfl le_rfl
-/

#print lt_self_iff_false /-
@[simp]
theorem lt_self_iff_false (x : α) : x < x ↔ False :=
  ⟨lt_irrefl x, False.elim⟩
#align lt_self_iff_false lt_self_iff_false
-/

#print le_of_le_of_eq /-
theorem le_of_le_of_eq (hab : a ≤ b) (hbc : b = c) : a ≤ c :=
  hab.trans hbc.le
#align le_of_le_of_eq le_of_le_of_eq
-/

#print le_of_eq_of_le /-
theorem le_of_eq_of_le (hab : a = b) (hbc : b ≤ c) : a ≤ c :=
  hab.le.trans hbc
#align le_of_eq_of_le le_of_eq_of_le
-/

#print lt_of_lt_of_eq /-
theorem lt_of_lt_of_eq (hab : a < b) (hbc : b = c) : a < c :=
  hab.trans_le hbc.le
#align lt_of_lt_of_eq lt_of_lt_of_eq
-/

#print lt_of_eq_of_lt /-
theorem lt_of_eq_of_lt (hab : a = b) (hbc : b < c) : a < c :=
  hab.le.trans_lt hbc
#align lt_of_eq_of_lt lt_of_eq_of_lt
-/

#print le_of_le_of_eq' /-
theorem le_of_le_of_eq' : b ≤ c → a = b → a ≤ c :=
  flip le_of_eq_of_le
#align le_of_le_of_eq' le_of_le_of_eq'
-/

#print le_of_eq_of_le' /-
theorem le_of_eq_of_le' : b = c → a ≤ b → a ≤ c :=
  flip le_of_le_of_eq
#align le_of_eq_of_le' le_of_eq_of_le'
-/

#print lt_of_lt_of_eq' /-
theorem lt_of_lt_of_eq' : b < c → a = b → a < c :=
  flip lt_of_eq_of_lt
#align lt_of_lt_of_eq' lt_of_lt_of_eq'
-/

#print lt_of_eq_of_lt' /-
theorem lt_of_eq_of_lt' : b = c → a < b → a < c :=
  flip lt_of_lt_of_eq
#align lt_of_eq_of_lt' lt_of_eq_of_lt'
-/

alias le_of_le_of_eq ← LE.le.trans_eq
#align has_le.le.trans_eq LE.le.trans_eq

alias le_of_le_of_eq' ← LE.le.trans_eq'
#align has_le.le.trans_eq' LE.le.trans_eq'

alias lt_of_lt_of_eq ← LT.lt.trans_eq
#align has_lt.lt.trans_eq LT.lt.trans_eq

alias lt_of_lt_of_eq' ← LT.lt.trans_eq'
#align has_lt.lt.trans_eq' LT.lt.trans_eq'

alias le_of_eq_of_le ← Eq.trans_le
#align eq.trans_le Eq.trans_le

alias le_of_eq_of_le' ← Eq.trans_ge
#align eq.trans_ge Eq.trans_ge

alias lt_of_eq_of_lt ← Eq.trans_lt
#align eq.trans_lt Eq.trans_lt

alias lt_of_eq_of_lt' ← Eq.trans_gt
#align eq.trans_gt Eq.trans_gt

end

namespace Eq

variable [Preorder α] {x y z : α}

#print Eq.ge /-
/-- If `x = y` then `y ≤ x`. Note: this lemma uses `y ≤ x` instead of `x ≥ y`, because `le` is used
almost exclusively in mathlib. -/
protected theorem ge (h : x = y) : y ≤ x :=
  h.symm.le
#align eq.ge Eq.ge
-/

#print Eq.not_lt /-
theorem not_lt (h : x = y) : ¬x < y := fun h' => h'.Ne h
#align eq.not_lt Eq.not_lt
-/

#print Eq.not_gt /-
theorem not_gt (h : x = y) : ¬y < x :=
  h.symm.not_lt
#align eq.not_gt Eq.not_gt
-/

end Eq

namespace LE.le

#print LE.le.ge /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem ge [LE α] {x y : α} (h : x ≤ y) : y ≥ x :=
  h
#align has_le.le.ge LE.le.ge
-/

section PartialOrder

variable [PartialOrder α] {a b : α}

#print LE.le.lt_iff_ne /-
theorem lt_iff_ne (h : a ≤ b) : a < b ↔ a ≠ b :=
  ⟨fun h => h.Ne, h.lt_of_ne⟩
#align has_le.le.lt_iff_ne LE.le.lt_iff_ne
-/

#print LE.le.gt_iff_ne /-
theorem gt_iff_ne (h : a ≤ b) : a < b ↔ b ≠ a :=
  ⟨fun h => h.Ne.symm, h.lt_of_ne'⟩
#align has_le.le.gt_iff_ne LE.le.gt_iff_ne
-/

#print LE.le.not_lt_iff_eq /-
theorem not_lt_iff_eq (h : a ≤ b) : ¬a < b ↔ a = b :=
  h.lt_iff_ne.not_left
#align has_le.le.not_lt_iff_eq LE.le.not_lt_iff_eq
-/

#print LE.le.not_gt_iff_eq /-
theorem not_gt_iff_eq (h : a ≤ b) : ¬a < b ↔ b = a :=
  h.gt_iff_ne.not_left
#align has_le.le.not_gt_iff_eq LE.le.not_gt_iff_eq
-/

#print LE.le.le_iff_eq /-
theorem le_iff_eq (h : a ≤ b) : b ≤ a ↔ b = a :=
  ⟨fun h' => h'.antisymm h, Eq.le⟩
#align has_le.le.le_iff_eq LE.le.le_iff_eq
-/

#print LE.le.ge_iff_eq /-
theorem ge_iff_eq (h : a ≤ b) : b ≤ a ↔ a = b :=
  ⟨h.antisymm, Eq.ge⟩
#align has_le.le.ge_iff_eq LE.le.ge_iff_eq
-/

end PartialOrder

#print LE.le.lt_or_le /-
theorem lt_or_le [LinearOrder α] {a b : α} (h : a ≤ b) (c : α) : a < c ∨ c ≤ b :=
  (lt_or_ge a c).imp id fun hc => le_trans hc h
#align has_le.le.lt_or_le LE.le.lt_or_le
-/

#print LE.le.le_or_lt /-
theorem le_or_lt [LinearOrder α] {a b : α} (h : a ≤ b) (c : α) : a ≤ c ∨ c < b :=
  (le_or_gt a c).imp id fun hc => lt_of_lt_of_le hc h
#align has_le.le.le_or_lt LE.le.le_or_lt
-/

#print LE.le.le_or_le /-
theorem le_or_le [LinearOrder α] {a b : α} (h : a ≤ b) (c : α) : a ≤ c ∨ c ≤ b :=
  (h.le_or_lt c).elim Or.inl fun h => Or.inr <| le_of_lt h
#align has_le.le.le_or_le LE.le.le_or_le
-/

end LE.le

namespace LT.lt

#print LT.lt.gt /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem gt [LT α] {x y : α} (h : x < y) : y > x :=
  h
#align has_lt.lt.gt LT.lt.gt
-/

#print LT.lt.false /-
protected theorem false [Preorder α] {x : α} : x < x → False :=
  lt_irrefl x
#align has_lt.lt.false LT.lt.false
-/

#print LT.lt.ne' /-
theorem ne' [Preorder α] {x y : α} (h : x < y) : y ≠ x :=
  h.Ne.symm
#align has_lt.lt.ne' LT.lt.ne'
-/

#print LT.lt.lt_or_lt /-
theorem lt_or_lt [LinearOrder α] {x y : α} (h : x < y) (z : α) : x < z ∨ z < y :=
  (lt_or_ge z y).elim Or.inr fun hz => Or.inl <| h.trans_le hz
#align has_lt.lt.lt_or_lt LT.lt.lt_or_lt
-/

end LT.lt

#print GE.ge.le /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem GE.ge.le [LE α] {x y : α} (h : x ≥ y) : y ≤ x :=
  h
#align ge.le GE.ge.le
-/

#print GT.gt.lt /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
protected theorem GT.gt.lt [LT α] {x y : α} (h : x > y) : y < x :=
  h
#align gt.lt GT.gt.lt
-/

#print ge_of_eq /-
-- see Note [nolint_ge]
@[nolint ge_or_gt]
theorem ge_of_eq [Preorder α] {a b : α} (h : a = b) : a ≥ b :=
  h.ge
#align ge_of_eq ge_of_eq
-/

#print ge_iff_le /-
-- see Note [nolint_ge]
@[simp, nolint ge_or_gt]
theorem ge_iff_le [LE α] {a b : α} : a ≥ b ↔ b ≤ a :=
  Iff.rfl
#align ge_iff_le ge_iff_le
-/

#print gt_iff_lt /-
-- see Note [nolint_ge]
@[simp, nolint ge_or_gt]
theorem gt_iff_lt [LT α] {a b : α} : a > b ↔ b < a :=
  Iff.rfl
#align gt_iff_lt gt_iff_lt
-/

#print not_le_of_lt /-
theorem not_le_of_lt [Preorder α] {a b : α} (h : a < b) : ¬b ≤ a :=
  (le_not_le_of_lt h).right
#align not_le_of_lt not_le_of_lt
-/

alias not_le_of_lt ← LT.lt.not_le
#align has_lt.lt.not_le LT.lt.not_le

#print not_lt_of_le /-
theorem not_lt_of_le [Preorder α] {a b : α} (h : a ≤ b) : ¬b < a := fun hba => hba.not_le h
#align not_lt_of_le not_lt_of_le
-/

alias not_lt_of_le ← LE.le.not_lt
#align has_le.le.not_lt LE.le.not_lt

#print ne_of_not_le /-
theorem ne_of_not_le [Preorder α] {a b : α} (h : ¬a ≤ b) : a ≠ b := fun hab => h (le_of_eq hab)
#align ne_of_not_le ne_of_not_le
-/

#print Decidable.le_iff_eq_or_lt /-
-- See Note [decidable namespace]
protected theorem Decidable.le_iff_eq_or_lt [PartialOrder α] [@DecidableRel α (· ≤ ·)] {a b : α} :
    a ≤ b ↔ a = b ∨ a < b :=
  Decidable.le_iff_lt_or_eq.trans or_comm
#align decidable.le_iff_eq_or_lt Decidable.le_iff_eq_or_lt
-/

#print le_iff_eq_or_lt /-
theorem le_iff_eq_or_lt [PartialOrder α] {a b : α} : a ≤ b ↔ a = b ∨ a < b :=
  le_iff_lt_or_eq.trans or_comm
#align le_iff_eq_or_lt le_iff_eq_or_lt
-/

#print lt_iff_le_and_ne /-
theorem lt_iff_le_and_ne [PartialOrder α] {a b : α} : a < b ↔ a ≤ b ∧ a ≠ b :=
  ⟨fun h => ⟨le_of_lt h, ne_of_lt h⟩, fun ⟨h1, h2⟩ => h1.lt_of_ne h2⟩
#align lt_iff_le_and_ne lt_iff_le_and_ne
-/

#print eq_iff_not_lt_of_le /-
theorem eq_iff_not_lt_of_le {α} [PartialOrder α] {x y : α} : x ≤ y → y = x ↔ ¬x < y := by
  rw [lt_iff_le_and_ne, not_and, Classical.not_not, eq_comm]
#align eq_iff_not_lt_of_le eq_iff_not_lt_of_le
-/

#print Decidable.eq_iff_le_not_lt /-
-- See Note [decidable namespace]
protected theorem Decidable.eq_iff_le_not_lt [PartialOrder α] [@DecidableRel α (· ≤ ·)] {a b : α} :
    a = b ↔ a ≤ b ∧ ¬a < b :=
  ⟨fun h => ⟨h.le, h ▸ lt_irrefl _⟩, fun ⟨h₁, h₂⟩ =>
    h₁.antisymm <| Decidable.by_contradiction fun h₃ => h₂ (h₁.lt_of_not_le h₃)⟩
#align decidable.eq_iff_le_not_lt Decidable.eq_iff_le_not_lt
-/

#print eq_iff_le_not_lt /-
theorem eq_iff_le_not_lt [PartialOrder α] {a b : α} : a = b ↔ a ≤ b ∧ ¬a < b :=
  haveI := Classical.dec
  Decidable.eq_iff_le_not_lt
#align eq_iff_le_not_lt eq_iff_le_not_lt
-/

#print eq_or_lt_of_le /-
theorem eq_or_lt_of_le [PartialOrder α] {a b : α} (h : a ≤ b) : a = b ∨ a < b :=
  h.lt_or_eq.symm
#align eq_or_lt_of_le eq_or_lt_of_le
-/

#print eq_or_gt_of_le /-
theorem eq_or_gt_of_le [PartialOrder α] {a b : α} (h : a ≤ b) : b = a ∨ a < b :=
  h.lt_or_eq.symm.imp Eq.symm id
#align eq_or_gt_of_le eq_or_gt_of_le
-/

#print gt_or_eq_of_le /-
theorem gt_or_eq_of_le [PartialOrder α] {a b : α} (hab : a ≤ b) : a < b ∨ b = a :=
  (eq_or_gt_of_le hab).symm
#align gt_or_eq_of_le gt_or_eq_of_le
-/

alias Decidable.eq_or_lt_of_le ← LE.le.eq_or_lt_dec
#align has_le.le.eq_or_lt_dec LE.le.eq_or_lt_dec

alias eq_or_lt_of_le ← LE.le.eq_or_lt
#align has_le.le.eq_or_lt LE.le.eq_or_lt

alias eq_or_gt_of_le ← LE.le.eq_or_gt
#align has_le.le.eq_or_gt LE.le.eq_or_gt

alias gt_or_eq_of_le ← LE.le.gt_or_eq
#align has_le.le.gt_or_eq LE.le.gt_or_eq

attribute [nolint decidable_classical] LE.le.eq_or_lt_dec

#print eq_of_le_of_not_lt /-
theorem eq_of_le_of_not_lt [PartialOrder α] {a b : α} (hab : a ≤ b) (hba : ¬a < b) : a = b :=
  hab.eq_or_lt.resolve_right hba
#align eq_of_le_of_not_lt eq_of_le_of_not_lt
-/

#print eq_of_ge_of_not_gt /-
theorem eq_of_ge_of_not_gt [PartialOrder α] {a b : α} (hab : a ≤ b) (hba : ¬a < b) : b = a :=
  (hab.eq_or_lt.resolve_right hba).symm
#align eq_of_ge_of_not_gt eq_of_ge_of_not_gt
-/

alias eq_of_le_of_not_lt ← LE.le.eq_of_not_lt
#align has_le.le.eq_of_not_lt LE.le.eq_of_not_lt

alias eq_of_ge_of_not_gt ← LE.le.eq_of_not_gt
#align has_le.le.eq_of_not_gt LE.le.eq_of_not_gt

#print Ne.le_iff_lt /-
theorem Ne.le_iff_lt [PartialOrder α] {a b : α} (h : a ≠ b) : a ≤ b ↔ a < b :=
  ⟨fun h' => lt_of_le_of_ne h' h, fun h => h.le⟩
#align ne.le_iff_lt Ne.le_iff_lt
-/

#print Ne.not_le_or_not_le /-
theorem Ne.not_le_or_not_le [PartialOrder α] {a b : α} (h : a ≠ b) : ¬a ≤ b ∨ ¬b ≤ a :=
  not_and_or.1 <| le_antisymm_iff.Not.1 h
#align ne.not_le_or_not_le Ne.not_le_or_not_le
-/

#print Decidable.ne_iff_lt_iff_le /-
-- See Note [decidable namespace]
protected theorem Decidable.ne_iff_lt_iff_le [PartialOrder α] [DecidableEq α] {a b : α} :
    (a ≠ b ↔ a < b) ↔ a ≤ b :=
  ⟨fun h => Decidable.byCases le_of_eq (le_of_lt ∘ h.mp), fun h => ⟨lt_of_le_of_ne h, ne_of_lt⟩⟩
#align decidable.ne_iff_lt_iff_le Decidable.ne_iff_lt_iff_le
-/

#print ne_iff_lt_iff_le /-
@[simp]
theorem ne_iff_lt_iff_le [PartialOrder α] {a b : α} : (a ≠ b ↔ a < b) ↔ a ≤ b :=
  haveI := Classical.dec
  Decidable.ne_iff_lt_iff_le
#align ne_iff_lt_iff_le ne_iff_lt_iff_le
-/

#print min_def' /-
-- Variant of `min_def` with the branches reversed.
theorem min_def' [LinearOrder α] (a b : α) : min a b = if b ≤ a then b else a :=
  by
  rw [min_def]
  rcases lt_trichotomy a b with (lt | eq | gt)
  · rw [if_pos lt.le, if_neg (not_le.mpr lt)]
  · rw [if_pos Eq.le, if_pos Eq.ge, Eq]
  · rw [if_neg (not_le.mpr GT.gt), if_pos gt.le]
#align min_def' min_def'
-/

#print max_def' /-
-- Variant of `min_def` with the branches reversed.
-- This is sometimes useful as it used to be the default.
theorem max_def' [LinearOrder α] (a b : α) : max a b = if b ≤ a then a else b :=
  by
  rw [max_def]
  rcases lt_trichotomy a b with (lt | eq | gt)
  · rw [if_pos lt.le, if_neg (not_le.mpr lt)]
  · rw [if_pos Eq.le, if_pos Eq.ge, Eq]
  · rw [if_neg (not_le.mpr GT.gt), if_pos gt.le]
#align max_def' max_def'
-/

#print lt_of_not_le /-
theorem lt_of_not_le [LinearOrder α] {a b : α} (h : ¬b ≤ a) : a < b :=
  ((le_total _ _).resolve_right h).lt_of_not_le h
#align lt_of_not_le lt_of_not_le
-/

#print lt_iff_not_le /-
theorem lt_iff_not_le [LinearOrder α] {x y : α} : x < y ↔ ¬y ≤ x :=
  ⟨not_le_of_lt, lt_of_not_le⟩
#align lt_iff_not_le lt_iff_not_le
-/

#print Ne.lt_or_lt /-
theorem Ne.lt_or_lt [LinearOrder α] {x y : α} (h : x ≠ y) : x < y ∨ y < x :=
  lt_or_gt_of_ne h
#align ne.lt_or_lt Ne.lt_or_lt
-/

#print lt_or_lt_iff_ne /-
/-- A version of `ne_iff_lt_or_gt` with LHS and RHS reversed. -/
@[simp]
theorem lt_or_lt_iff_ne [LinearOrder α] {x y : α} : x < y ∨ y < x ↔ x ≠ y :=
  ne_iff_lt_or_gt.symm
#align lt_or_lt_iff_ne lt_or_lt_iff_ne
-/

#print not_lt_iff_eq_or_lt /-
theorem not_lt_iff_eq_or_lt [LinearOrder α] {a b : α} : ¬a < b ↔ a = b ∨ b < a :=
  not_lt.trans <| Decidable.le_iff_eq_or_lt.trans <| or_congr eq_comm Iff.rfl
#align not_lt_iff_eq_or_lt not_lt_iff_eq_or_lt
-/

#print exists_ge_of_linear /-
theorem exists_ge_of_linear [LinearOrder α] (a b : α) : ∃ c, a ≤ c ∧ b ≤ c :=
  match le_total a b with
  | Or.inl h => ⟨_, h, le_rfl⟩
  | Or.inr h => ⟨_, le_rfl, h⟩
#align exists_ge_of_linear exists_ge_of_linear
-/

#print lt_imp_lt_of_le_imp_le /-
theorem lt_imp_lt_of_le_imp_le {β} [LinearOrder α] [Preorder β] {a b : α} {c d : β}
    (H : a ≤ b → c ≤ d) (h : d < c) : b < a :=
  lt_of_not_le fun h' => (H h').not_lt h
#align lt_imp_lt_of_le_imp_le lt_imp_lt_of_le_imp_le
-/

#print le_imp_le_iff_lt_imp_lt /-
theorem le_imp_le_iff_lt_imp_lt {β} [LinearOrder α] [LinearOrder β] {a b : α} {c d : β} :
    a ≤ b → c ≤ d ↔ d < c → b < a :=
  ⟨lt_imp_lt_of_le_imp_le, le_imp_le_of_lt_imp_lt⟩
#align le_imp_le_iff_lt_imp_lt le_imp_le_iff_lt_imp_lt
-/

#print lt_iff_lt_of_le_iff_le' /-
theorem lt_iff_lt_of_le_iff_le' {β} [Preorder α] [Preorder β] {a b : α} {c d : β}
    (H : a ≤ b ↔ c ≤ d) (H' : b ≤ a ↔ d ≤ c) : b < a ↔ d < c :=
  lt_iff_le_not_le.trans <| (and_congr H' (not_congr H)).trans lt_iff_le_not_le.symm
#align lt_iff_lt_of_le_iff_le' lt_iff_lt_of_le_iff_le'
-/

#print lt_iff_lt_of_le_iff_le /-
theorem lt_iff_lt_of_le_iff_le {β} [LinearOrder α] [LinearOrder β] {a b : α} {c d : β}
    (H : a ≤ b ↔ c ≤ d) : b < a ↔ d < c :=
  not_le.symm.trans <| (not_congr H).trans <| not_le
#align lt_iff_lt_of_le_iff_le lt_iff_lt_of_le_iff_le
-/

#print le_iff_le_iff_lt_iff_lt /-
theorem le_iff_le_iff_lt_iff_lt {β} [LinearOrder α] [LinearOrder β] {a b : α} {c d : β} :
    (a ≤ b ↔ c ≤ d) ↔ (b < a ↔ d < c) :=
  ⟨lt_iff_lt_of_le_iff_le, fun H => not_lt.symm.trans <| (not_congr H).trans <| not_lt⟩
#align le_iff_le_iff_lt_iff_lt le_iff_le_iff_lt_iff_lt
-/

#print eq_of_forall_le_iff /-
theorem eq_of_forall_le_iff [PartialOrder α] {a b : α} (H : ∀ c, c ≤ a ↔ c ≤ b) : a = b :=
  ((H _).1 le_rfl).antisymm ((H _).2 le_rfl)
#align eq_of_forall_le_iff eq_of_forall_le_iff
-/

#print le_of_forall_le /-
theorem le_of_forall_le [Preorder α] {a b : α} (H : ∀ c, c ≤ a → c ≤ b) : a ≤ b :=
  H _ le_rfl
#align le_of_forall_le le_of_forall_le
-/

#print le_of_forall_le' /-
theorem le_of_forall_le' [Preorder α] {a b : α} (H : ∀ c, a ≤ c → b ≤ c) : b ≤ a :=
  H _ le_rfl
#align le_of_forall_le' le_of_forall_le'
-/

#print le_of_forall_lt /-
theorem le_of_forall_lt [LinearOrder α] {a b : α} (H : ∀ c, c < a → c < b) : a ≤ b :=
  le_of_not_lt fun h => lt_irrefl _ (H _ h)
#align le_of_forall_lt le_of_forall_lt
-/

#print forall_lt_iff_le /-
theorem forall_lt_iff_le [LinearOrder α] {a b : α} : (∀ ⦃c⦄, c < a → c < b) ↔ a ≤ b :=
  ⟨le_of_forall_lt, fun h c hca => lt_of_lt_of_le hca h⟩
#align forall_lt_iff_le forall_lt_iff_le
-/

#print le_of_forall_lt' /-
theorem le_of_forall_lt' [LinearOrder α] {a b : α} (H : ∀ c, a < c → b < c) : b ≤ a :=
  le_of_not_lt fun h => lt_irrefl _ (H _ h)
#align le_of_forall_lt' le_of_forall_lt'
-/

#print forall_lt_iff_le' /-
theorem forall_lt_iff_le' [LinearOrder α] {a b : α} : (∀ ⦃c⦄, a < c → b < c) ↔ b ≤ a :=
  ⟨le_of_forall_lt', fun h c hac => lt_of_le_of_lt h hac⟩
#align forall_lt_iff_le' forall_lt_iff_le'
-/

#print eq_of_forall_ge_iff /-
theorem eq_of_forall_ge_iff [PartialOrder α] {a b : α} (H : ∀ c, a ≤ c ↔ b ≤ c) : a = b :=
  ((H _).2 le_rfl).antisymm ((H _).1 le_rfl)
#align eq_of_forall_ge_iff eq_of_forall_ge_iff
-/

#print eq_of_forall_lt_iff /-
theorem eq_of_forall_lt_iff [LinearOrder α] {a b : α} (h : ∀ c, c < a ↔ c < b) : a = b :=
  (le_of_forall_lt fun _ => (h _).1).antisymm <| le_of_forall_lt fun _ => (h _).2
#align eq_of_forall_lt_iff eq_of_forall_lt_iff
-/

#print eq_of_forall_gt_iff /-
theorem eq_of_forall_gt_iff [LinearOrder α] {a b : α} (h : ∀ c, a < c ↔ b < c) : a = b :=
  (le_of_forall_lt' fun _ => (h _).2).antisymm <| le_of_forall_lt' fun _ => (h _).1
#align eq_of_forall_gt_iff eq_of_forall_gt_iff
-/

#print rel_imp_eq_of_rel_imp_le /-
/-- A symmetric relation implies two values are equal, when it implies they're less-equal.  -/
theorem rel_imp_eq_of_rel_imp_le [PartialOrder β] (r : α → α → Prop) [IsSymm α r] {f : α → β}
    (h : ∀ a b, r a b → f a ≤ f b) {a b : α} : r a b → f a = f b := fun hab =>
  le_antisymm (h a b hab) (h b a <| symm hab)
#align rel_imp_eq_of_rel_imp_le rel_imp_eq_of_rel_imp_le
-/

#print le_implies_le_of_le_of_le /-
/-- monotonicity of `≤` with respect to `→` -/
theorem le_implies_le_of_le_of_le {a b c d : α} [Preorder α] (hca : c ≤ a) (hbd : b ≤ d) :
    a ≤ b → c ≤ d := fun hab => (hca.trans hab).trans hbd
#align le_implies_le_of_le_of_le le_implies_le_of_le_of_le
-/

section PartialOrder

variable [PartialOrder α]

#print commutative_of_le /-
/-- To prove commutativity of a binary operation `○`, we only to check `a ○ b ≤ b ○ a` for all `a`,
`b`. -/
theorem commutative_of_le {f : β → β → α} (comm : ∀ a b, f a b ≤ f b a) : ∀ a b, f a b = f b a :=
  fun a b => (comm _ _).antisymm <| comm _ _
#align commutative_of_le commutative_of_le
-/

#print associative_of_commutative_of_le /-
/-- To prove associativity of a commutative binary operation `○`, we only to check
`(a ○ b) ○ c ≤ a ○ (b ○ c)` for all `a`, `b`, `c`. -/
theorem associative_of_commutative_of_le {f : α → α → α} (comm : Commutative f)
    (assoc : ∀ a b c, f (f a b) c ≤ f a (f b c)) : Associative f := fun a b c =>
  le_antisymm (assoc _ _ _) <| by rw [comm, comm b, comm _ c, comm a]; exact assoc _ _ _
#align associative_of_commutative_of_le associative_of_commutative_of_le
-/

end PartialOrder

#print Preorder.toLE_injective /-
@[ext]
theorem Preorder.toLE_injective {α : Type _} : Function.Injective (@Preorder.toLE α) := fun A B h =>
  by
  cases A; cases B
  injection h with h_le
  have : A_lt = B_lt := by
    funext a b
    dsimp [(· ≤ ·)] at A_lt_iff_le_not_le B_lt_iff_le_not_le h_le 
    simp [A_lt_iff_le_not_le, B_lt_iff_le_not_le, h_le]
  congr
#align preorder.to_has_le_injective Preorder.toLE_injective
-/

#print PartialOrder.toPreorder_injective /-
@[ext]
theorem PartialOrder.toPreorder_injective {α : Type _} :
    Function.Injective (@PartialOrder.toPreorder α) := fun A B h => by cases A; cases B;
  injection h; congr
#align partial_order.to_preorder_injective PartialOrder.toPreorder_injective
-/

#print LinearOrder.toPartialOrder_injective /-
@[ext]
theorem LinearOrder.toPartialOrder_injective {α : Type _} :
    Function.Injective (@LinearOrder.toPartialOrder α) :=
  by
  intro A B h
  cases A; cases B; injection h
  obtain rfl : A_le = B_le := ‹_›; obtain rfl : A_lt = B_lt := ‹_›
  obtain rfl : A_decidable_le = B_decidable_le := Subsingleton.elim _ _
  obtain rfl : A_max = B_max := A_max_def.trans B_max_def.symm
  obtain rfl : A_min = B_min := A_min_def.trans B_min_def.symm
  congr
#align linear_order.to_partial_order_injective LinearOrder.toPartialOrder_injective
-/

#print Preorder.ext /-
theorem Preorder.ext {α} {A B : Preorder α}
    (H :
      ∀ x y : α,
        (haveI := A
          x ≤ y) ↔
          x ≤ y) :
    A = B := by ext x y; exact H x y
#align preorder.ext Preorder.ext
-/

#print PartialOrder.ext /-
theorem PartialOrder.ext {α} {A B : PartialOrder α}
    (H :
      ∀ x y : α,
        (haveI := A
          x ≤ y) ↔
          x ≤ y) :
    A = B := by ext x y; exact H x y
#align partial_order.ext PartialOrder.ext
-/

#print LinearOrder.ext /-
theorem LinearOrder.ext {α} {A B : LinearOrder α}
    (H :
      ∀ x y : α,
        (haveI := A
          x ≤ y) ↔
          x ≤ y) :
    A = B := by ext x y; exact H x y
#align linear_order.ext LinearOrder.ext
-/

#print Order.Preimage /-
/-- Given a relation `R` on `β` and a function `f : α → β`, the preimage relation on `α` is defined
by `x ≤ y ↔ f x ≤ f y`. It is the unique relation on `α` making `f` a `rel_embedding` (assuming `f`
is injective). -/
@[simp]
def Order.Preimage {α β} (f : α → β) (s : β → β → Prop) (x y : α) : Prop :=
  s (f x) (f y)
#align order.preimage Order.Preimage
-/

infixl:80 " ⁻¹'o " => Order.Preimage

#print Order.Preimage.decidable /-
/-- The preimage of a decidable order is decidable. -/
instance Order.Preimage.decidable {α β} (f : α → β) (s : β → β → Prop) [H : DecidableRel s] :
    DecidableRel (f ⁻¹'o s) := fun x y => H _ _
#align order.preimage.decidable Order.Preimage.decidable
-/

/-! ### Order dual -/


#print OrderDual /-
/-- Type synonym to equip a type with the dual order: `≤` means `≥` and `<` means `>`. `αᵒᵈ` is
notation for `order_dual α`. -/
def OrderDual (α : Type _) : Type _ :=
  α
#align order_dual OrderDual
-/

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
  { OrderDual.hasLe α,
    OrderDual.hasLt α with
    le_refl := le_refl
    le_trans := fun a b c hab hbc => hbc.trans hab
    lt_iff_le_not_le := fun _ _ => lt_iff_le_not_le }

instance (α : Type _) [PartialOrder α] : PartialOrder αᵒᵈ :=
  { OrderDual.preorder α with le_antisymm := fun a b hab hba => @le_antisymm α _ a b hba hab }

instance (α : Type _) [LinearOrder α] : LinearOrder αᵒᵈ :=
  { OrderDual.partialOrder α with
    le_total := fun a b : α => le_total b a
    decidableLe := (inferInstance : DecidableRel fun a b : α => b ≤ a)
    decidableLt := (inferInstance : DecidableRel fun a b : α => b < a)
    min := @max α _
    max := @min α _
    min_def := funext₂ <| @max_def' α _
    max_def := funext₂ <| @min_def' α _ }

instance : ∀ [Inhabited α], Inhabited αᵒᵈ :=
  id

#print OrderDual.Preorder.dual_dual /-
theorem Preorder.dual_dual (α : Type _) [H : Preorder α] : OrderDual.preorder αᵒᵈ = H :=
  Preorder.ext fun _ _ => Iff.rfl
#align order_dual.preorder.dual_dual OrderDual.Preorder.dual_dual
-/

#print OrderDual.partialOrder.dual_dual /-
theorem partialOrder.dual_dual (α : Type _) [H : PartialOrder α] : OrderDual.partialOrder αᵒᵈ = H :=
  PartialOrder.ext fun _ _ => Iff.rfl
#align order_dual.partial_order.dual_dual OrderDual.partialOrder.dual_dual
-/

#print OrderDual.linearOrder.dual_dual /-
theorem linearOrder.dual_dual (α : Type _) [H : LinearOrder α] : OrderDual.linearOrder αᵒᵈ = H :=
  LinearOrder.ext fun _ _ => Iff.rfl
#align order_dual.linear_order.dual_dual OrderDual.linearOrder.dual_dual
-/

end OrderDual

/-! ### `has_compl` -/


#print HasCompl /-
/-- Set / lattice complement -/
@[notation_class]
class HasCompl (α : Type _) where
  compl : α → α
#align has_compl HasCompl
-/

export HasCompl (compl)

/- ./././Mathport/Syntax/Translate/Command.lean:476:9: unsupported: advanced prec syntax «expr + »(max[std.prec.max], 1) -/
postfix:999 "ᶜ" => compl

#print Prop.hasCompl /-
instance Prop.hasCompl : HasCompl Prop :=
  ⟨Not⟩
#align Prop.has_compl Prop.hasCompl
-/

#print Pi.hasCompl /-
instance Pi.hasCompl {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] : HasCompl (∀ i, α i) :=
  ⟨fun x i => x iᶜ⟩
#align pi.has_compl Pi.hasCompl
-/

#print Pi.compl_def /-
theorem Pi.compl_def {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] (x : ∀ i, α i) :
    xᶜ = fun i => x iᶜ :=
  rfl
#align pi.compl_def Pi.compl_def
-/

#print Pi.compl_apply /-
@[simp]
theorem Pi.compl_apply {ι : Type u} {α : ι → Type v} [∀ i, HasCompl (α i)] (x : ∀ i, α i) (i : ι) :
    (xᶜ) i = x iᶜ :=
  rfl
#align pi.compl_apply Pi.compl_apply
-/

#print IsIrrefl.compl /-
instance IsIrrefl.compl (r) [IsIrrefl α r] : IsRefl α (rᶜ) :=
  ⟨@irrefl α r _⟩
#align is_irrefl.compl IsIrrefl.compl
-/

#print IsRefl.compl /-
instance IsRefl.compl (r) [IsRefl α r] : IsIrrefl α (rᶜ) :=
  ⟨fun a => not_not_intro (refl a)⟩
#align is_refl.compl IsRefl.compl
-/

/-! ### Order instances on the function space -/


#print Pi.hasLe /-
instance Pi.hasLe {ι : Type u} {α : ι → Type v} [∀ i, LE (α i)] : LE (∀ i, α i)
    where le x y := ∀ i, x i ≤ y i
#align pi.has_le Pi.hasLe
-/

#print Pi.le_def /-
theorem Pi.le_def {ι : Type u} {α : ι → Type v} [∀ i, LE (α i)] {x y : ∀ i, α i} :
    x ≤ y ↔ ∀ i, x i ≤ y i :=
  Iff.rfl
#align pi.le_def Pi.le_def
-/

#print Pi.preorder /-
instance Pi.preorder {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] : Preorder (∀ i, α i) :=
  { Pi.hasLe with
    le_refl := fun a i => le_refl (a i)
    le_trans := fun a b c h₁ h₂ i => le_trans (h₁ i) (h₂ i) }
#align pi.preorder Pi.preorder
-/

#print Pi.lt_def /-
theorem Pi.lt_def {ι : Type u} {α : ι → Type v} [∀ i, Preorder (α i)] {x y : ∀ i, α i} :
    x < y ↔ x ≤ y ∧ ∃ i, x i < y i := by
  simp (config := { contextual := true }) [lt_iff_le_not_le, Pi.le_def]
#align pi.lt_def Pi.lt_def
-/

#print Pi.partialOrder /-
instance Pi.partialOrder [∀ i, PartialOrder (π i)] : PartialOrder (∀ i, π i) :=
  { Pi.preorder with le_antisymm := fun f g h1 h2 => funext fun b => (h1 b).antisymm (h2 b) }
#align pi.partial_order Pi.partialOrder
-/

section Pi

#print StrongLT /-
/-- A function `a` is strongly less than a function `b`  if `a i < b i` for all `i`. -/
def StrongLT [∀ i, LT (π i)] (a b : ∀ i, π i) : Prop :=
  ∀ i, a i < b i
#align strong_lt StrongLT
-/

local infixl:50 " ≺ " => StrongLT

variable [∀ i, Preorder (π i)] {a b c : ∀ i, π i}

#print le_of_strongLT /-
theorem le_of_strongLT (h : a ≺ b) : a ≤ b := fun i => (h _).le
#align le_of_strong_lt le_of_strongLT
-/

#print lt_of_strongLT /-
theorem lt_of_strongLT [Nonempty ι] (h : a ≺ b) : a < b := by inhabit ι;
  exact Pi.lt_def.2 ⟨le_of_strongLT h, default, h _⟩
#align lt_of_strong_lt lt_of_strongLT
-/

#print strongLT_of_strongLT_of_le /-
theorem strongLT_of_strongLT_of_le (hab : a ≺ b) (hbc : b ≤ c) : a ≺ c := fun i =>
  (hab _).trans_le <| hbc _
#align strong_lt_of_strong_lt_of_le strongLT_of_strongLT_of_le
-/

#print strongLT_of_le_of_strongLT /-
theorem strongLT_of_le_of_strongLT (hab : a ≤ b) (hbc : b ≺ c) : a ≺ c := fun i =>
  (hab _).trans_lt <| hbc _
#align strong_lt_of_le_of_strong_lt strongLT_of_le_of_strongLT
-/

alias le_of_strongLT ← StrongLT.le
#align strong_lt.le StrongLT.le

alias lt_of_strongLT ← StrongLT.lt
#align strong_lt.lt StrongLT.lt

alias strongLT_of_strongLT_of_le ← StrongLT.trans_le
#align strong_lt.trans_le StrongLT.trans_le

alias strongLT_of_le_of_strongLT ← LE.le.trans_strongLT
#align has_le.le.trans_strong_lt LE.le.trans_strongLT

end Pi

section Function

variable [DecidableEq ι] [∀ i, Preorder (π i)] {x y : ∀ i, π i} {i : ι} {a b : π i}

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print le_update_iff /-
theorem le_update_iff : x ≤ Function.update y i a ↔ x i ≤ a ∧ ∀ (j) (_ : j ≠ i), x j ≤ y j :=
  Function.forall_update_iff _ fun j z => x j ≤ z
#align le_update_iff le_update_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print update_le_iff /-
theorem update_le_iff : Function.update x i a ≤ y ↔ a ≤ y i ∧ ∀ (j) (_ : j ≠ i), x j ≤ y j :=
  Function.forall_update_iff _ fun j z => z ≤ y j
#align update_le_iff update_le_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print update_le_update_iff /-
theorem update_le_update_iff :
    Function.update x i a ≤ Function.update y i b ↔ a ≤ b ∧ ∀ (j) (_ : j ≠ i), x j ≤ y j := by
  simp (config := { contextual := true }) [update_le_iff]
#align update_le_update_iff update_le_update_iff
-/

#print update_le_update_iff' /-
@[simp]
theorem update_le_update_iff' : update x i a ≤ update x i b ↔ a ≤ b := by
  simp [update_le_update_iff]
#align update_le_update_iff' update_le_update_iff'
-/

#print update_lt_update_iff /-
@[simp]
theorem update_lt_update_iff : update x i a < update x i b ↔ a < b :=
  lt_iff_lt_of_le_iff_le' update_le_update_iff' update_le_update_iff'
#align update_lt_update_iff update_lt_update_iff
-/

#print le_update_self_iff /-
@[simp]
theorem le_update_self_iff : x ≤ update x i a ↔ x i ≤ a := by simp [le_update_iff]
#align le_update_self_iff le_update_self_iff
-/

#print update_le_self_iff /-
@[simp]
theorem update_le_self_iff : update x i a ≤ x ↔ a ≤ x i := by simp [update_le_iff]
#align update_le_self_iff update_le_self_iff
-/

#print lt_update_self_iff /-
@[simp]
theorem lt_update_self_iff : x < update x i a ↔ x i < a := by simp [lt_iff_le_not_le]
#align lt_update_self_iff lt_update_self_iff
-/

#print update_lt_self_iff /-
@[simp]
theorem update_lt_self_iff : update x i a < x ↔ a < x i := by simp [lt_iff_le_not_le]
#align update_lt_self_iff update_lt_self_iff
-/

end Function

#print Pi.sdiff /-
instance Pi.sdiff {ι : Type u} {α : ι → Type v} [∀ i, SDiff (α i)] : SDiff (∀ i, α i) :=
  ⟨fun x y i => x i \ y i⟩
#align pi.has_sdiff Pi.sdiff
-/

#print Pi.sdiff_def /-
theorem Pi.sdiff_def {ι : Type u} {α : ι → Type v} [∀ i, SDiff (α i)] (x y : ∀ i, α i) :
    x \ y = fun i => x i \ y i :=
  rfl
#align pi.sdiff_def Pi.sdiff_def
-/

#print Pi.sdiff_apply /-
@[simp]
theorem Pi.sdiff_apply {ι : Type u} {α : ι → Type v} [∀ i, SDiff (α i)] (x y : ∀ i, α i) (i : ι) :
    (x \ y) i = x i \ y i :=
  rfl
#align pi.sdiff_apply Pi.sdiff_apply
-/

namespace Function

variable [Preorder α] [Nonempty β] {a b : α}

#print Function.const_le_const /-
@[simp]
theorem const_le_const : const β a ≤ const β b ↔ a ≤ b := by simp [Pi.le_def]
#align function.const_le_const Function.const_le_const
-/

#print Function.const_lt_const /-
@[simp]
theorem const_lt_const : const β a < const β b ↔ a < b := by simpa [Pi.lt_def] using le_of_lt
#align function.const_lt_const Function.const_lt_const
-/

end Function

/-! ### `min`/`max` recursors -/


section MinMaxRec

variable [LinearOrder α] {p : α → Prop} {x y : α}

#print min_rec /-
theorem min_rec (hx : x ≤ y → p x) (hy : y ≤ x → p y) : p (min x y) :=
  (le_total x y).rec (fun h => (min_eq_left h).symm.subst (hx h)) fun h =>
    (min_eq_right h).symm.subst (hy h)
#align min_rec min_rec
-/

#print max_rec /-
theorem max_rec (hx : y ≤ x → p x) (hy : x ≤ y → p y) : p (max x y) :=
  @min_rec αᵒᵈ _ _ _ _ hx hy
#align max_rec max_rec
-/

#print min_rec' /-
theorem min_rec' (p : α → Prop) (hx : p x) (hy : p y) : p (min x y) :=
  min_rec (fun _ => hx) fun _ => hy
#align min_rec' min_rec'
-/

#print max_rec' /-
theorem max_rec' (p : α → Prop) (hx : p x) (hy : p y) : p (max x y) :=
  max_rec (fun _ => hx) fun _ => hy
#align max_rec' max_rec'
-/

#print min_def_lt /-
theorem min_def_lt (x y : α) : min x y = if x < y then x else y :=
  by
  rw [min_comm, min_def, ← ite_not]
  simp only [not_le]
#align min_def_lt min_def_lt
-/

#print max_def_lt /-
theorem max_def_lt (x y : α) : max x y = if x < y then y else x :=
  by
  rw [max_comm, max_def, ← ite_not]
  simp only [not_le]
#align max_def_lt max_def_lt
-/

end MinMaxRec

/-! ### `has_sup` and `has_inf` -/


#print Sup /-
/-- Typeclass for the `⊔` (`\lub`) notation -/
@[notation_class]
class Sup (α : Type u) where
  sup : α → α → α
#align has_sup Sup
-/

#print Inf /-
/-- Typeclass for the `⊓` (`\glb`) notation -/
@[notation_class]
class Inf (α : Type u) where
  inf : α → α → α
#align has_inf Inf
-/

infixl:68 " ⊔ " => Sup.sup

infixl:69 " ⊓ " => Inf.inf

/-! ### Lifts of order instances -/


#print Preorder.lift /-
/-- Transfer a `preorder` on `β` to a `preorder` on `α` using a function `f : α → β`.
See note [reducible non-instances]. -/
@[reducible]
def Preorder.lift {α β} [Preorder β] (f : α → β) : Preorder α
    where
  le x y := f x ≤ f y
  le_refl a := le_rfl
  le_trans a b c := le_trans
  lt x y := f x < f y
  lt_iff_le_not_le a b := lt_iff_le_not_le
#align preorder.lift Preorder.lift
-/

#print PartialOrder.lift /-
/-- Transfer a `partial_order` on `β` to a `partial_order` on `α` using an injective
function `f : α → β`. See note [reducible non-instances]. -/
@[reducible]
def PartialOrder.lift {α β} [PartialOrder β] (f : α → β) (inj : Injective f) : PartialOrder α :=
  { Preorder.lift f with le_antisymm := fun a b h₁ h₂ => inj (h₁.antisymm h₂) }
#align partial_order.lift PartialOrder.lift
-/

#print LinearOrder.lift /-
/-- Transfer a `linear_order` on `β` to a `linear_order` on `α` using an injective
function `f : α → β`. This version takes `[has_sup α]` and `[has_inf α]` as arguments, then uses
them for `max` and `min` fields. See `linear_order.lift'` for a version that autogenerates `min` and
`max` fields. See note [reducible non-instances]. -/
@[reducible]
def LinearOrder.lift {α β} [LinearOrder β] [Sup α] [Inf α] (f : α → β) (inj : Injective f)
    (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y)) (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) :
    LinearOrder α :=
  {
    PartialOrder.lift f inj with
    le_total := fun x y => le_total (f x) (f y)
    decidableLe := fun x y => (inferInstance : Decidable (f x ≤ f y))
    decidableLt := fun x y => (inferInstance : Decidable (f x < f y))
    DecidableEq := fun x y => decidable_of_iff (f x = f y) inj.eq_iff
    min := (· ⊓ ·)
    max := (· ⊔ ·)
    min_def := by ext x y; apply inj; rw [hinf, min_def, minDefault, apply_ite f]; rfl
    max_def := by ext x y; apply inj; rw [hsup, max_def, maxDefault, apply_ite f]; rfl }
#align linear_order.lift LinearOrder.lift
-/

#print LinearOrder.lift' /-
/-- Transfer a `linear_order` on `β` to a `linear_order` on `α` using an injective
function `f : α → β`. This version autogenerates `min` and `max` fields. See `linear_order.lift`
for a version that takes `[has_sup α]` and `[has_inf α]`, then uses them as `max` and `min`.
See note [reducible non-instances]. -/
@[reducible]
def LinearOrder.lift' {α β} [LinearOrder β] (f : α → β) (inj : Injective f) : LinearOrder α :=
  @LinearOrder.lift α β _ ⟨fun x y => if f x ≤ f y then y else x⟩
    ⟨fun x y => if f x ≤ f y then x else y⟩ f inj
    (fun x y => (apply_ite f _ _ _).trans (max_def _ _).symm) fun x y =>
    (apply_ite f _ _ _).trans (min_def _ _).symm
#align linear_order.lift' LinearOrder.lift'
-/

/-! ### Subtype of an order -/


namespace Subtype

instance [LE α] {p : α → Prop} : LE (Subtype p) :=
  ⟨fun x y => (x : α) ≤ y⟩

instance [LT α] {p : α → Prop} : LT (Subtype p) :=
  ⟨fun x y => (x : α) < y⟩

#print Subtype.mk_le_mk /-
@[simp]
theorem mk_le_mk [LE α] {p : α → Prop} {x y : α} {hx : p x} {hy : p y} :
    (⟨x, hx⟩ : Subtype p) ≤ ⟨y, hy⟩ ↔ x ≤ y :=
  Iff.rfl
#align subtype.mk_le_mk Subtype.mk_le_mk
-/

#print Subtype.mk_lt_mk /-
@[simp]
theorem mk_lt_mk [LT α] {p : α → Prop} {x y : α} {hx : p x} {hy : p y} :
    (⟨x, hx⟩ : Subtype p) < ⟨y, hy⟩ ↔ x < y :=
  Iff.rfl
#align subtype.mk_lt_mk Subtype.mk_lt_mk
-/

#print Subtype.coe_le_coe /-
@[simp, norm_cast]
theorem coe_le_coe [LE α] {p : α → Prop} {x y : Subtype p} : (x : α) ≤ y ↔ x ≤ y :=
  Iff.rfl
#align subtype.coe_le_coe Subtype.coe_le_coe
-/

#print Subtype.coe_lt_coe /-
@[simp, norm_cast]
theorem coe_lt_coe [LT α] {p : α → Prop} {x y : Subtype p} : (x : α) < y ↔ x < y :=
  Iff.rfl
#align subtype.coe_lt_coe Subtype.coe_lt_coe
-/

instance [Preorder α] (p : α → Prop) : Preorder (Subtype p) :=
  Preorder.lift (coe : Subtype p → α)

#print Subtype.partialOrder /-
instance partialOrder [PartialOrder α] (p : α → Prop) : PartialOrder (Subtype p) :=
  PartialOrder.lift coe Subtype.coe_injective
#align subtype.partial_order Subtype.partialOrder
-/

#print Subtype.decidableLE /-
instance decidableLE [Preorder α] [h : @DecidableRel α (· ≤ ·)] {p : α → Prop} :
    @DecidableRel (Subtype p) (· ≤ ·) := fun a b => h a b
#align subtype.decidable_le Subtype.decidableLE
-/

#print Subtype.decidableLT /-
instance decidableLT [Preorder α] [h : @DecidableRel α (· < ·)] {p : α → Prop} :
    @DecidableRel (Subtype p) (· < ·) := fun a b => h a b
#align subtype.decidable_lt Subtype.decidableLT
-/

/-- A subtype of a linear order is a linear order. We explicitly give the proofs of decidable
equality and decidable order in order to ensure the decidability instances are all definitionally
equal. -/
instance [LinearOrder α] (p : α → Prop) : LinearOrder (Subtype p) :=
  @LinearOrder.lift (Subtype p) _ _ ⟨fun x y => ⟨max x y, max_rec' _ x.2 y.2⟩⟩
    ⟨fun x y => ⟨min x y, min_rec' _ x.2 y.2⟩⟩ coe Subtype.coe_injective (fun _ _ => rfl) fun _ _ =>
    rfl

end Subtype

/-!
### Pointwise order on `α × β`

The lexicographic order is defined in `data.prod.lex`, and the instances are available via the
type synonym `α ×ₗ β = α × β`.
-/


namespace Prod

instance (α : Type u) (β : Type v) [LE α] [LE β] : LE (α × β) :=
  ⟨fun p q => p.1 ≤ q.1 ∧ p.2 ≤ q.2⟩

#print Prod.le_def /-
theorem le_def [LE α] [LE β] {x y : α × β} : x ≤ y ↔ x.1 ≤ y.1 ∧ x.2 ≤ y.2 :=
  Iff.rfl
#align prod.le_def Prod.le_def
-/

#print Prod.mk_le_mk /-
@[simp]
theorem mk_le_mk [LE α] [LE β] {x₁ x₂ : α} {y₁ y₂ : β} : (x₁, y₁) ≤ (x₂, y₂) ↔ x₁ ≤ x₂ ∧ y₁ ≤ y₂ :=
  Iff.rfl
#align prod.mk_le_mk Prod.mk_le_mk
-/

#print Prod.swap_le_swap /-
@[simp]
theorem swap_le_swap [LE α] [LE β] {x y : α × β} : x.symm ≤ y.symm ↔ x ≤ y :=
  and_comm' _ _
#align prod.swap_le_swap Prod.swap_le_swap
-/

section Preorder

variable [Preorder α] [Preorder β] {a a₁ a₂ : α} {b b₁ b₂ : β} {x y : α × β}

instance (α : Type u) (β : Type v) [Preorder α] [Preorder β] : Preorder (α × β) :=
  { Prod.hasLe α β with
    le_refl := fun ⟨a, b⟩ => ⟨le_refl a, le_refl b⟩
    le_trans := fun ⟨a, b⟩ ⟨c, d⟩ ⟨e, f⟩ ⟨hac, hbd⟩ ⟨hce, hdf⟩ =>
      ⟨le_trans hac hce, le_trans hbd hdf⟩ }

#print Prod.swap_lt_swap /-
@[simp]
theorem swap_lt_swap : x.symm < y.symm ↔ x < y :=
  and_congr swap_le_swap (not_congr swap_le_swap)
#align prod.swap_lt_swap Prod.swap_lt_swap
-/

#print Prod.mk_le_mk_iff_left /-
theorem mk_le_mk_iff_left : (a₁, b) ≤ (a₂, b) ↔ a₁ ≤ a₂ :=
  and_iff_left le_rfl
#align prod.mk_le_mk_iff_left Prod.mk_le_mk_iff_left
-/

#print Prod.mk_le_mk_iff_right /-
theorem mk_le_mk_iff_right : (a, b₁) ≤ (a, b₂) ↔ b₁ ≤ b₂ :=
  and_iff_right le_rfl
#align prod.mk_le_mk_iff_right Prod.mk_le_mk_iff_right
-/

#print Prod.mk_lt_mk_iff_left /-
theorem mk_lt_mk_iff_left : (a₁, b) < (a₂, b) ↔ a₁ < a₂ :=
  lt_iff_lt_of_le_iff_le' mk_le_mk_iff_left mk_le_mk_iff_left
#align prod.mk_lt_mk_iff_left Prod.mk_lt_mk_iff_left
-/

#print Prod.mk_lt_mk_iff_right /-
theorem mk_lt_mk_iff_right : (a, b₁) < (a, b₂) ↔ b₁ < b₂ :=
  lt_iff_lt_of_le_iff_le' mk_le_mk_iff_right mk_le_mk_iff_right
#align prod.mk_lt_mk_iff_right Prod.mk_lt_mk_iff_right
-/

#print Prod.lt_iff /-
theorem lt_iff : x < y ↔ x.1 < y.1 ∧ x.2 ≤ y.2 ∨ x.1 ≤ y.1 ∧ x.2 < y.2 :=
  by
  refine' ⟨fun h => _, _⟩
  · by_cases h₁ : y.1 ≤ x.1
    · exact Or.inr ⟨h.1.1, h.1.2.lt_of_not_le fun h₂ => h.2 ⟨h₁, h₂⟩⟩
    · exact Or.inl ⟨h.1.1.lt_of_not_le h₁, h.1.2⟩
  · rintro (⟨h₁, h₂⟩ | ⟨h₁, h₂⟩)
    · exact ⟨⟨h₁.le, h₂⟩, fun h => h₁.not_le h.1⟩
    · exact ⟨⟨h₁, h₂.le⟩, fun h => h₂.not_le h.2⟩
#align prod.lt_iff Prod.lt_iff
-/

#print Prod.mk_lt_mk /-
@[simp]
theorem mk_lt_mk : (a₁, b₁) < (a₂, b₂) ↔ a₁ < a₂ ∧ b₁ ≤ b₂ ∨ a₁ ≤ a₂ ∧ b₁ < b₂ :=
  lt_iff
#align prod.mk_lt_mk Prod.mk_lt_mk
-/

end Preorder

/-- The pointwise partial order on a product.
    (The lexicographic ordering is defined in order/lexicographic.lean, and the instances are
    available via the type synonym `α ×ₗ β = α × β`.) -/
instance (α : Type u) (β : Type v) [PartialOrder α] [PartialOrder β] : PartialOrder (α × β) :=
  { Prod.preorder α β with
    le_antisymm := fun ⟨a, b⟩ ⟨c, d⟩ ⟨hac, hbd⟩ ⟨hca, hdb⟩ =>
      Prod.ext (hac.antisymm hca) (hbd.antisymm hdb) }

end Prod

/-! ### Additional order classes -/


#print DenselyOrdered /-
/-- An order is dense if there is an element between any pair of distinct comparable elements. -/
class DenselyOrdered (α : Type u) [LT α] : Prop where
  dense : ∀ a₁ a₂ : α, a₁ < a₂ → ∃ a, a₁ < a ∧ a < a₂
#align densely_ordered DenselyOrdered
-/

#print exists_between /-
theorem exists_between [LT α] [DenselyOrdered α] : ∀ {a₁ a₂ : α}, a₁ < a₂ → ∃ a, a₁ < a ∧ a < a₂ :=
  DenselyOrdered.dense
#align exists_between exists_between
-/

#print OrderDual.denselyOrdered /-
instance OrderDual.denselyOrdered (α : Type u) [LT α] [DenselyOrdered α] : DenselyOrdered αᵒᵈ :=
  ⟨fun a₁ a₂ ha => (@exists_between α _ _ _ _ ha).imp fun a => And.symm⟩
#align order_dual.densely_ordered OrderDual.denselyOrdered
-/

#print denselyOrdered_orderDual /-
@[simp]
theorem denselyOrdered_orderDual [LT α] : DenselyOrdered αᵒᵈ ↔ DenselyOrdered α :=
  ⟨by convert @OrderDual.denselyOrdered αᵒᵈ _; cases ‹LT α›; rfl, @OrderDual.denselyOrdered α _⟩
#align densely_ordered_order_dual denselyOrdered_orderDual
-/

instance [Preorder α] [Preorder β] [DenselyOrdered α] [DenselyOrdered β] : DenselyOrdered (α × β) :=
  ⟨fun a b => by
    simp_rw [Prod.lt_iff]
    rintro (⟨h₁, h₂⟩ | ⟨h₁, h₂⟩)
    · obtain ⟨c, ha, hb⟩ := exists_between h₁
      exact ⟨(c, _), Or.inl ⟨ha, h₂⟩, Or.inl ⟨hb, le_rfl⟩⟩
    · obtain ⟨c, ha, hb⟩ := exists_between h₂
      exact ⟨(_, c), Or.inr ⟨h₁, ha⟩, Or.inr ⟨le_rfl, hb⟩⟩⟩

instance {α : ι → Type _} [∀ i, Preorder (α i)] [∀ i, DenselyOrdered (α i)] :
    DenselyOrdered (∀ i, α i) :=
  ⟨fun a b => by
    classical
    simp_rw [Pi.lt_def]
    rintro ⟨hab, i, hi⟩
    obtain ⟨c, ha, hb⟩ := exists_between hi
    exact
      ⟨a.update i c, ⟨le_update_iff.2 ⟨ha.le, fun _ _ => le_rfl⟩, i, by rwa [update_same]⟩,
        update_le_iff.2 ⟨hb.le, fun _ _ => hab _⟩, i, by rwa [update_same]⟩⟩

#print le_of_forall_le_of_dense /-
theorem le_of_forall_le_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α}
    (h : ∀ a, a₂ < a → a₁ ≤ a) : a₁ ≤ a₂ :=
  le_of_not_gt fun ha =>
    let ⟨a, ha₁, ha₂⟩ := exists_between ha
    lt_irrefl a <| lt_of_lt_of_le ‹a < a₁› (h _ ‹a₂ < a›)
#align le_of_forall_le_of_dense le_of_forall_le_of_dense
-/

#print eq_of_le_of_forall_le_of_dense /-
theorem eq_of_le_of_forall_le_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α} (h₁ : a₂ ≤ a₁)
    (h₂ : ∀ a, a₂ < a → a₁ ≤ a) : a₁ = a₂ :=
  le_antisymm (le_of_forall_le_of_dense h₂) h₁
#align eq_of_le_of_forall_le_of_dense eq_of_le_of_forall_le_of_dense
-/

#print le_of_forall_ge_of_dense /-
theorem le_of_forall_ge_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α}
    (h : ∀ a₃ < a₁, a₃ ≤ a₂) : a₁ ≤ a₂ :=
  le_of_not_gt fun ha =>
    let ⟨a, ha₁, ha₂⟩ := exists_between ha
    lt_irrefl a <| lt_of_le_of_lt (h _ ‹a < a₁›) ‹a₂ < a›
#align le_of_forall_ge_of_dense le_of_forall_ge_of_dense
-/

#print eq_of_le_of_forall_ge_of_dense /-
theorem eq_of_le_of_forall_ge_of_dense [LinearOrder α] [DenselyOrdered α] {a₁ a₂ : α} (h₁ : a₂ ≤ a₁)
    (h₂ : ∀ a₃ < a₁, a₃ ≤ a₂) : a₁ = a₂ :=
  (le_of_forall_ge_of_dense h₂).antisymm h₁
#align eq_of_le_of_forall_ge_of_dense eq_of_le_of_forall_ge_of_dense
-/

#print dense_or_discrete /-
theorem dense_or_discrete [LinearOrder α] (a₁ a₂ : α) :
    (∃ a, a₁ < a ∧ a < a₂) ∨ (∀ a, a₁ < a → a₂ ≤ a) ∧ ∀ a < a₂, a ≤ a₁ :=
  or_iff_not_imp_left.2 fun h =>
    ⟨fun a ha₁ => le_of_not_gt fun ha₂ => h ⟨a, ha₁, ha₂⟩, fun a ha₂ =>
      le_of_not_gt fun ha₁ => h ⟨a, ha₁, ha₂⟩⟩
#align dense_or_discrete dense_or_discrete
-/

#print eq_or_eq_or_eq_of_forall_not_lt_lt /-
/-- If a linear order has no elements `x < y < z`, then it has at most two elements. -/
theorem eq_or_eq_or_eq_of_forall_not_lt_lt {α : Type _} [LinearOrder α]
    (h : ∀ ⦃x y z : α⦄, x < y → y < z → False) (x y z : α) : x = y ∨ y = z ∨ x = z :=
  by
  by_contra hne; push_neg at hne 
  cases' hne.1.lt_or_lt with h₁ h₁ <;> cases' hne.2.1.lt_or_lt with h₂ h₂ <;>
    cases' hne.2.2.lt_or_lt with h₃ h₃
  exacts [h h₁ h₂, h h₂ h₃, h h₃ h₂, h h₃ h₁, h h₁ h₃, h h₂ h₃, h h₁ h₃, h h₂ h₁]
#align eq_or_eq_or_eq_of_forall_not_lt_lt eq_or_eq_or_eq_of_forall_not_lt_lt
-/

namespace PUnit

variable (a b : PUnit.{u + 1})

instance : LinearOrder PUnit := by
  refine_struct
        { le := fun _ _ => True
          lt := fun _ _ => False
          max := fun _ _ => star
          min := fun _ _ => star
          DecidableEq := PUnit.decidableEq
          decidableLe := fun _ _ => decidableTrue
          decidableLt := fun _ _ => decidableFalse } <;>
      intros <;>
    first
    | trivial
    | simp only [eq_iff_true_of_subsingleton, not_true, and_false_iff]
    | exact Or.inl trivial

#print PUnit.max_eq /-
theorem max_eq : max a b = unit :=
  rfl
#align punit.max_eq PUnit.max_eq
-/

#print PUnit.min_eq /-
theorem min_eq : min a b = unit :=
  rfl
#align punit.min_eq PUnit.min_eq
-/

#print PUnit.le /-
@[simp]
protected theorem le : a ≤ b :=
  trivial
#align punit.le PUnit.le
-/

#print PUnit.not_lt /-
@[simp]
theorem not_lt : ¬a < b :=
  not_false
#align punit.not_lt PUnit.not_lt
-/

instance : DenselyOrdered PUnit :=
  ⟨fun _ _ => False.elim⟩

end PUnit

section Prop

/- ./././Mathport/Syntax/Translate/Expr.lean:219:4: warning: unsupported binary notation `«->» -/
#print Prop.le /-
/-- Propositions form a complete boolean algebra, where the `≤` relation is given by implication. -/
instance Prop.le : LE Prop :=
  ⟨(«->» · ·)⟩
#align Prop.has_le Prop.le
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:219:4: warning: unsupported binary notation `«->» -/
#print le_Prop_eq /-
@[simp]
theorem le_Prop_eq : ((· ≤ ·) : Prop → Prop → Prop) = («->» · ·) :=
  rfl
#align le_Prop_eq le_Prop_eq
-/

#print subrelation_iff_le /-
theorem subrelation_iff_le {r s : α → α → Prop} : Subrelation r s ↔ r ≤ s :=
  Iff.rfl
#align subrelation_iff_le subrelation_iff_le
-/

#print Prop.partialOrder /-
instance Prop.partialOrder : PartialOrder Prop :=
  { Prop.le with
    le_refl := fun _ => id
    le_trans := fun a b c f g => g ∘ f
    le_antisymm := fun a b Hab Hba => propext ⟨Hab, Hba⟩ }
#align Prop.partial_order Prop.partialOrder
-/

end Prop

variable {s : β → β → Prop} {t : γ → γ → Prop}

/-! ### Linear order from a total partial order -/


#print AsLinearOrder /-
/-- Type synonym to create an instance of `linear_order` from a `partial_order` and
`is_total α (≤)` -/
def AsLinearOrder (α : Type u) :=
  α
#align as_linear_order AsLinearOrder
-/

instance {α} [Inhabited α] : Inhabited (AsLinearOrder α) :=
  ⟨(default : α)⟩

#print AsLinearOrder.linearOrder /-
noncomputable instance AsLinearOrder.linearOrder {α} [PartialOrder α] [IsTotal α (· ≤ ·)] :
    LinearOrder (AsLinearOrder α) :=
  { (_ : PartialOrder α) with
    le_total := @total_of α (· ≤ ·) _
    decidableLe := Classical.decRel _ }
#align as_linear_order.linear_order AsLinearOrder.linearOrder
-/

