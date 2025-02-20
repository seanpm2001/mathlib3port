/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module order.circular
! leanprover-community/mathlib commit 213b0cff7bc5ab6696ee07cceec80829ce42efec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Basic

/-!
# Circular order hierarchy

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines circular preorders, circular partial orders and circular orders.

## Hierarchy

* A ternary "betweenness" relation `btw : α → α → α → Prop` forms a `circular_order` if it is
  - reflexive: `btw a a a`
  - cyclic: `btw a b c → btw b c a`
  - antisymmetric: `btw a b c → btw c b a → a = b ∨ b = c ∨ c = a`
  - total: `btw a b c ∨ btw c b a`
  along with a strict betweenness relation `sbtw : α → α → α → Prop` which respects
  `sbtw a b c ↔ btw a b c ∧ ¬ btw c b a`, analogously to how `<` and `≤` are related, and is
  - transitive: `sbtw a b c → sbtw b d c → sbtw a d c`.
* A `circular_partial_order` drops totality.
* A `circular_preorder` further drops antisymmetry.

The intuition is that a circular order is a circle and `btw a b c` means that going around
clockwise from `a` you reach `b` before `c` (`b` is between `a` and `c` is meaningless on an
unoriented circle). A circular partial order is several, potentially intersecting, circles. A
circular preorder is like a circular partial order, but several points can coexist.

Note that the relations between `circular_preorder`, `circular_partial_order` and `circular_order`
are subtler than between `preorder`, `partial_order`, `linear_order`. In particular, one cannot
simply extend the `btw` of a `circular_partial_order` to make it a `circular_order`.

One can translate from usual orders to circular ones by "closing the necklace at infinity". See
`has_le.to_has_btw` and `has_lt.to_has_sbtw`. Going the other way involves "cutting the necklace" or
"rolling the necklace open".

## Examples

Some concrete circular orders one encounters in the wild are `zmod n` for `0 < n`, `circle`,
`real.angle`...

## Main definitions

* `set.cIcc`: Closed-closed circular interval.
* `set.cIoo`: Open-open circular interval.

## Notes

There's an unsolved diamond on `order_dual α` here. The instances `has_le α → has_btw αᵒᵈ` and
`has_lt α → has_sbtw αᵒᵈ` can each be inferred in two ways:
* `has_le α` → `has_btw α` → `has_btw αᵒᵈ` vs
  `has_le α` → `has_le αᵒᵈ` → `has_btw αᵒᵈ`
* `has_lt α` → `has_sbtw α` → `has_sbtw αᵒᵈ` vs
  `has_lt α` → `has_lt αᵒᵈ` → `has_sbtw αᵒᵈ`
The fields are propeq, but not defeq. It is temporarily fixed by turning the circularizing instances
into definitions.

## TODO

Antisymmetry is quite weak in the sense that there's no way to discriminate which two points are
equal. This prevents defining closed-open intervals `cIco` and `cIoc` in the neat `=`-less way. We
currently haven't defined them at all.

What is the correct generality of "rolling the necklace" open? At least, this works for `α × β` and
`β × α` where `α` is a circular order and `β` is a linear order.

What's next is to define circular groups and provide instances for `zmod n`, the usual circle group
`circle`, and `roots_of_unity M`. What conditions do we need on `M` for this last one
to work?

We should have circular order homomorphisms. The typical example is
`days_to_month : days_of_the_year →c months_of_the_year` which relates the circular order of days
and the circular order of months. Is `α →c β` a good notation?

## References

* https://en.wikipedia.org/wiki/Cyclic_order
* https://en.wikipedia.org/wiki/Partial_cyclic_order

## Tags

circular order, cyclic order, circularly ordered set, cyclically ordered set
-/


#print Btw /-
/-- Syntax typeclass for a betweenness relation. -/
class Btw (α : Type _) where
  Btw : α → α → α → Prop
#align has_btw Btw
-/

export Btw (Btw)

#print SBtw /-
/-- Syntax typeclass for a strict betweenness relation. -/
class SBtw (α : Type _) where
  Sbtw : α → α → α → Prop
#align has_sbtw SBtw
-/

export SBtw (Sbtw)

#print CircularPreorder /-
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic order_laws_tac -/
/-- A circular preorder is the analogue of a preorder where you can loop around. `≤` and `<` are
replaced by ternary relations `btw` and `sbtw`. `btw` is reflexive and cyclic. `sbtw` is transitive.
-/
class CircularPreorder (α : Type _) extends Btw α, SBtw α where
  btw_refl (a : α) : btw a a a
  btw_cyclic_left {a b c : α} : btw a b c → btw b c a
  Sbtw := fun a b c => btw a b c ∧ ¬btw c b a
  sbtw_iff_btw_not_btw {a b c : α} : Sbtw a b c ↔ btw a b c ∧ ¬btw c b a := by
    run_tac
      order_laws_tac
  sbtw_trans_left {a b c d : α} : Sbtw a b c → Sbtw b d c → Sbtw a d c
#align circular_preorder CircularPreorder
-/

export CircularPreorder (btw_refl btw_cyclic_left sbtw_trans_left)

#print CircularPartialOrder /-
/-- A circular partial order is the analogue of a partial order where you can loop around. `≤` and
`<` are replaced by ternary relations `btw` and `sbtw`. `btw` is reflexive, cyclic and
antisymmetric. `sbtw` is transitive. -/
class CircularPartialOrder (α : Type _) extends CircularPreorder α where
  btw_antisymm {a b c : α} : btw a b c → btw c b a → a = b ∨ b = c ∨ c = a
#align circular_partial_order CircularPartialOrder
-/

export CircularPartialOrder (btw_antisymm)

#print CircularOrder /-
/-- A circular order is the analogue of a linear order where you can loop around. `≤` and `<` are
replaced by ternary relations `btw` and `sbtw`. `btw` is reflexive, cyclic, antisymmetric and total.
`sbtw` is transitive. -/
class CircularOrder (α : Type _) extends CircularPartialOrder α where
  btw_total : ∀ a b c : α, btw a b c ∨ btw c b a
#align circular_order CircularOrder
-/

export CircularOrder (btw_total)

/-! ### Circular preorders -/


section CircularPreorder

variable {α : Type _} [CircularPreorder α]

#print btw_rfl /-
theorem btw_rfl {a : α} : Btw a a a :=
  btw_refl _
#align btw_rfl btw_rfl
-/

#print Btw.btw.cyclic_left /-
-- TODO: `alias` creates a def instead of a lemma.
-- alias btw_cyclic_left        ← has_btw.btw.cyclic_left
theorem Btw.btw.cyclic_left {a b c : α} (h : Btw a b c) : Btw b c a :=
  btw_cyclic_left h
#align has_btw.btw.cyclic_left Btw.btw.cyclic_left
-/

#print btw_cyclic_right /-
theorem btw_cyclic_right {a b c : α} (h : Btw a b c) : Btw c a b :=
  h.cyclic_left.cyclic_left
#align btw_cyclic_right btw_cyclic_right
-/

alias btw_cyclic_right ← Btw.btw.cyclic_right
#align has_btw.btw.cyclic_right Btw.btw.cyclic_right

#print btw_cyclic /-
/-- The order of the `↔` has been chosen so that `rw btw_cyclic` cycles to the right while
`rw ←btw_cyclic` cycles to the left (thus following the prepended arrow). -/
theorem btw_cyclic {a b c : α} : Btw a b c ↔ Btw c a b :=
  ⟨btw_cyclic_right, btw_cyclic_left⟩
#align btw_cyclic btw_cyclic
-/

#print sbtw_iff_btw_not_btw /-
theorem sbtw_iff_btw_not_btw {a b c : α} : Sbtw a b c ↔ Btw a b c ∧ ¬Btw c b a :=
  CircularPreorder.sbtw_iff_btw_not_btw
#align sbtw_iff_btw_not_btw sbtw_iff_btw_not_btw
-/

#print btw_of_sbtw /-
theorem btw_of_sbtw {a b c : α} (h : Sbtw a b c) : Btw a b c :=
  (sbtw_iff_btw_not_btw.1 h).1
#align btw_of_sbtw btw_of_sbtw
-/

alias btw_of_sbtw ← SBtw.sbtw.btw
#align has_sbtw.sbtw.btw SBtw.sbtw.btw

#print not_btw_of_sbtw /-
theorem not_btw_of_sbtw {a b c : α} (h : Sbtw a b c) : ¬Btw c b a :=
  (sbtw_iff_btw_not_btw.1 h).2
#align not_btw_of_sbtw not_btw_of_sbtw
-/

alias not_btw_of_sbtw ← SBtw.sbtw.not_btw
#align has_sbtw.sbtw.not_btw SBtw.sbtw.not_btw

#print not_sbtw_of_btw /-
theorem not_sbtw_of_btw {a b c : α} (h : Btw a b c) : ¬Sbtw c b a := fun h' => h'.not_btw h
#align not_sbtw_of_btw not_sbtw_of_btw
-/

alias not_sbtw_of_btw ← Btw.btw.not_sbtw
#align has_btw.btw.not_sbtw Btw.btw.not_sbtw

#print sbtw_of_btw_not_btw /-
theorem sbtw_of_btw_not_btw {a b c : α} (habc : Btw a b c) (hcba : ¬Btw c b a) : Sbtw a b c :=
  sbtw_iff_btw_not_btw.2 ⟨habc, hcba⟩
#align sbtw_of_btw_not_btw sbtw_of_btw_not_btw
-/

alias sbtw_of_btw_not_btw ← Btw.btw.sbtw_of_not_btw
#align has_btw.btw.sbtw_of_not_btw Btw.btw.sbtw_of_not_btw

#print sbtw_cyclic_left /-
theorem sbtw_cyclic_left {a b c : α} (h : Sbtw a b c) : Sbtw b c a :=
  h.Btw.cyclic_left.sbtw_of_not_btw fun h' => h.not_btw h'.cyclic_left
#align sbtw_cyclic_left sbtw_cyclic_left
-/

alias sbtw_cyclic_left ← SBtw.sbtw.cyclic_left
#align has_sbtw.sbtw.cyclic_left SBtw.sbtw.cyclic_left

#print sbtw_cyclic_right /-
theorem sbtw_cyclic_right {a b c : α} (h : Sbtw a b c) : Sbtw c a b :=
  h.cyclic_left.cyclic_left
#align sbtw_cyclic_right sbtw_cyclic_right
-/

alias sbtw_cyclic_right ← SBtw.sbtw.cyclic_right
#align has_sbtw.sbtw.cyclic_right SBtw.sbtw.cyclic_right

#print sbtw_cyclic /-
/-- The order of the `↔` has been chosen so that `rw sbtw_cyclic` cycles to the right while
`rw ←sbtw_cyclic` cycles to the left (thus following the prepended arrow). -/
theorem sbtw_cyclic {a b c : α} : Sbtw a b c ↔ Sbtw c a b :=
  ⟨sbtw_cyclic_right, sbtw_cyclic_left⟩
#align sbtw_cyclic sbtw_cyclic
-/

#print SBtw.sbtw.trans_left /-
-- TODO: `alias` creates a def instead of a lemma.
-- alias btw_trans_left        ← has_btw.btw.trans_left
theorem SBtw.sbtw.trans_left {a b c d : α} (h : Sbtw a b c) : Sbtw b d c → Sbtw a d c :=
  sbtw_trans_left h
#align has_sbtw.sbtw.trans_left SBtw.sbtw.trans_left
-/

#print sbtw_trans_right /-
theorem sbtw_trans_right {a b c d : α} (hbc : Sbtw a b c) (hcd : Sbtw a c d) : Sbtw a b d :=
  (hbc.cyclic_left.trans_left hcd.cyclic_left).cyclic_right
#align sbtw_trans_right sbtw_trans_right
-/

alias sbtw_trans_right ← SBtw.sbtw.trans_right
#align has_sbtw.sbtw.trans_right SBtw.sbtw.trans_right

#print sbtw_asymm /-
theorem sbtw_asymm {a b c : α} (h : Sbtw a b c) : ¬Sbtw c b a :=
  h.Btw.not_sbtw
#align sbtw_asymm sbtw_asymm
-/

alias sbtw_asymm ← SBtw.sbtw.not_sbtw
#align has_sbtw.sbtw.not_sbtw SBtw.sbtw.not_sbtw

#print sbtw_irrefl_left_right /-
theorem sbtw_irrefl_left_right {a b : α} : ¬Sbtw a b a := fun h => h.not_btw h.Btw
#align sbtw_irrefl_left_right sbtw_irrefl_left_right
-/

#print sbtw_irrefl_left /-
theorem sbtw_irrefl_left {a b : α} : ¬Sbtw a a b := fun h => sbtw_irrefl_left_right h.cyclic_left
#align sbtw_irrefl_left sbtw_irrefl_left
-/

#print sbtw_irrefl_right /-
theorem sbtw_irrefl_right {a b : α} : ¬Sbtw a b b := fun h => sbtw_irrefl_left_right h.cyclic_right
#align sbtw_irrefl_right sbtw_irrefl_right
-/

#print sbtw_irrefl /-
theorem sbtw_irrefl (a : α) : ¬Sbtw a a a :=
  sbtw_irrefl_left_right
#align sbtw_irrefl sbtw_irrefl
-/

end CircularPreorder

/-! ### Circular partial orders -/


section CircularPartialOrder

variable {α : Type _} [CircularPartialOrder α]

#print Btw.btw.antisymm /-
-- TODO: `alias` creates a def instead of a lemma.
-- alias btw_antisymm        ← has_btw.btw.antisymm
theorem Btw.btw.antisymm {a b c : α} (h : Btw a b c) : Btw c b a → a = b ∨ b = c ∨ c = a :=
  btw_antisymm h
#align has_btw.btw.antisymm Btw.btw.antisymm
-/

end CircularPartialOrder

/-! ### Circular orders -/


section CircularOrder

variable {α : Type _} [CircularOrder α]

#print btw_refl_left_right /-
theorem btw_refl_left_right (a b : α) : Btw a b a :=
  (or_self_iff _).1 (btw_total a b a)
#align btw_refl_left_right btw_refl_left_right
-/

#print btw_rfl_left_right /-
theorem btw_rfl_left_right {a b : α} : Btw a b a :=
  btw_refl_left_right _ _
#align btw_rfl_left_right btw_rfl_left_right
-/

#print btw_refl_left /-
theorem btw_refl_left (a b : α) : Btw a a b :=
  btw_rfl_left_right.cyclic_right
#align btw_refl_left btw_refl_left
-/

#print btw_rfl_left /-
theorem btw_rfl_left {a b : α} : Btw a a b :=
  btw_refl_left _ _
#align btw_rfl_left btw_rfl_left
-/

#print btw_refl_right /-
theorem btw_refl_right (a b : α) : Btw a b b :=
  btw_rfl_left_right.cyclic_left
#align btw_refl_right btw_refl_right
-/

#print btw_rfl_right /-
theorem btw_rfl_right {a b : α} : Btw a b b :=
  btw_refl_right _ _
#align btw_rfl_right btw_rfl_right
-/

#print sbtw_iff_not_btw /-
theorem sbtw_iff_not_btw {a b c : α} : Sbtw a b c ↔ ¬Btw c b a :=
  by
  rw [sbtw_iff_btw_not_btw]
  exact and_iff_right_of_imp (btw_total _ _ _).resolve_left
#align sbtw_iff_not_btw sbtw_iff_not_btw
-/

#print btw_iff_not_sbtw /-
theorem btw_iff_not_sbtw {a b c : α} : Btw a b c ↔ ¬Sbtw c b a :=
  iff_not_comm.1 sbtw_iff_not_btw
#align btw_iff_not_sbtw btw_iff_not_sbtw
-/

end CircularOrder

/-! ### Circular intervals -/


namespace Set

section CircularPreorder

variable {α : Type _} [CircularPreorder α]

#print Set.cIcc /-
/-- Closed-closed circular interval -/
def cIcc (a b : α) : Set α :=
  {x | Btw a x b}
#align set.cIcc Set.cIcc
-/

#print Set.cIoo /-
/-- Open-open circular interval -/
def cIoo (a b : α) : Set α :=
  {x | Sbtw a x b}
#align set.cIoo Set.cIoo
-/

#print Set.mem_cIcc /-
@[simp]
theorem mem_cIcc {a b x : α} : x ∈ cIcc a b ↔ Btw a x b :=
  Iff.rfl
#align set.mem_cIcc Set.mem_cIcc
-/

#print Set.mem_cIoo /-
@[simp]
theorem mem_cIoo {a b x : α} : x ∈ cIoo a b ↔ Sbtw a x b :=
  Iff.rfl
#align set.mem_cIoo Set.mem_cIoo
-/

end CircularPreorder

section CircularOrder

variable {α : Type _} [CircularOrder α]

#print Set.left_mem_cIcc /-
theorem left_mem_cIcc (a b : α) : a ∈ cIcc a b :=
  btw_rfl_left
#align set.left_mem_cIcc Set.left_mem_cIcc
-/

#print Set.right_mem_cIcc /-
theorem right_mem_cIcc (a b : α) : b ∈ cIcc a b :=
  btw_rfl_right
#align set.right_mem_cIcc Set.right_mem_cIcc
-/

#print Set.compl_cIcc /-
theorem compl_cIcc {a b : α} : cIcc a bᶜ = cIoo b a :=
  by
  ext
  rw [Set.mem_cIoo, sbtw_iff_not_btw]
  rfl
#align set.compl_cIcc Set.compl_cIcc
-/

#print Set.compl_cIoo /-
theorem compl_cIoo {a b : α} : cIoo a bᶜ = cIcc b a :=
  by
  ext
  rw [Set.mem_cIcc, btw_iff_not_sbtw]
  rfl
#align set.compl_cIoo Set.compl_cIoo
-/

end CircularOrder

end Set

/-! ### Circularizing instances -/


#print LE.toBtw /-
/-- The betweenness relation obtained from "looping around" `≤`.
See note [reducible non-instances]. -/
@[reducible]
def LE.toBtw (α : Type _) [LE α] : Btw α
    where Btw a b c := a ≤ b ∧ b ≤ c ∨ b ≤ c ∧ c ≤ a ∨ c ≤ a ∧ a ≤ b
#align has_le.to_has_btw LE.toBtw
-/

#print LT.toSBtw /-
/-- The strict betweenness relation obtained from "looping around" `<`.
See note [reducible non-instances]. -/
@[reducible]
def LT.toSBtw (α : Type _) [LT α] : SBtw α
    where Sbtw a b c := a < b ∧ b < c ∨ b < c ∧ c < a ∨ c < a ∧ a < b
#align has_lt.to_has_sbtw LT.toSBtw
-/

#print Preorder.toCircularPreorder /-
/-- The circular preorder obtained from "looping around" a preorder.
See note [reducible non-instances]. -/
@[reducible]
def Preorder.toCircularPreorder (α : Type _) [Preorder α] : CircularPreorder α
    where
  Btw a b c := a ≤ b ∧ b ≤ c ∨ b ≤ c ∧ c ≤ a ∨ c ≤ a ∧ a ≤ b
  Sbtw a b c := a < b ∧ b < c ∨ b < c ∧ c < a ∨ c < a ∧ a < b
  btw_refl a := Or.inl ⟨le_rfl, le_rfl⟩
  btw_cyclic_left a b c h := by
    unfold btw at h ⊢
    rwa [← or_assoc, or_comm']
  sbtw_trans_left a b c d :=
    by
    rintro (⟨hab, hbc⟩ | ⟨hbc, hca⟩ | ⟨hca, hab⟩) (⟨hbd, hdc⟩ | ⟨hdc, hcb⟩ | ⟨hcb, hbd⟩)
    · exact Or.inl ⟨hab.trans hbd, hdc⟩
    · exact (hbc.not_lt hcb).elim
    · exact (hbc.not_lt hcb).elim
    · exact Or.inr (Or.inl ⟨hdc, hca⟩)
    · exact Or.inr (Or.inl ⟨hdc, hca⟩)
    · exact (hbc.not_lt hcb).elim
    · exact Or.inr (Or.inl ⟨hdc, hca⟩)
    · exact Or.inr (Or.inl ⟨hdc, hca⟩)
    · exact Or.inr (Or.inr ⟨hca, hab.trans hbd⟩)
  sbtw_iff_btw_not_btw a b c := by
    simp_rw [lt_iff_le_not_le]
    set x₀ := a ≤ b
    set x₁ := b ≤ c
    set x₂ := c ≤ a
    have : x₀ → x₁ → a ≤ c := le_trans
    have : x₁ → x₂ → b ≤ a := le_trans
    have : x₂ → x₀ → c ≤ b := le_trans
    clear_value x₀ x₁ x₂
    tauto
#align preorder.to_circular_preorder Preorder.toCircularPreorder
-/

#print PartialOrder.toCircularPartialOrder /-
/-- The circular partial order obtained from "looping around" a partial order.
See note [reducible non-instances]. -/
@[reducible]
def PartialOrder.toCircularPartialOrder (α : Type _) [PartialOrder α] : CircularPartialOrder α :=
  { Preorder.toCircularPreorder α with
    btw_antisymm := fun a b c =>
      by
      rintro (⟨hab, hbc⟩ | ⟨hbc, hca⟩ | ⟨hca, hab⟩) (⟨hcb, hba⟩ | ⟨hba, hac⟩ | ⟨hac, hcb⟩)
      · exact Or.inl (hab.antisymm hba)
      · exact Or.inl (hab.antisymm hba)
      · exact Or.inr (Or.inl <| hbc.antisymm hcb)
      · exact Or.inr (Or.inl <| hbc.antisymm hcb)
      · exact Or.inr (Or.inr <| hca.antisymm hac)
      · exact Or.inr (Or.inl <| hbc.antisymm hcb)
      · exact Or.inl (hab.antisymm hba)
      · exact Or.inl (hab.antisymm hba)
      · exact Or.inr (Or.inr <| hca.antisymm hac) }
#align partial_order.to_circular_partial_order PartialOrder.toCircularPartialOrder
-/

#print LinearOrder.toCircularOrder /-
/-- The circular order obtained from "looping around" a linear order.
See note [reducible non-instances]. -/
@[reducible]
def LinearOrder.toCircularOrder (α : Type _) [LinearOrder α] : CircularOrder α :=
  { PartialOrder.toCircularPartialOrder α with
    btw_total := fun a b c =>
      by
      cases' le_total a b with hab hba <;> cases' le_total b c with hbc hcb <;>
        cases' le_total c a with hca hac
      · exact Or.inl (Or.inl ⟨hab, hbc⟩)
      · exact Or.inl (Or.inl ⟨hab, hbc⟩)
      · exact Or.inl (Or.inr <| Or.inr ⟨hca, hab⟩)
      · exact Or.inr (Or.inr <| Or.inr ⟨hac, hcb⟩)
      · exact Or.inl (Or.inr <| Or.inl ⟨hbc, hca⟩)
      · exact Or.inr (Or.inr <| Or.inl ⟨hba, hac⟩)
      · exact Or.inr (Or.inl ⟨hcb, hba⟩)
      · exact Or.inr (Or.inr <| Or.inl ⟨hba, hac⟩) }
#align linear_order.to_circular_order LinearOrder.toCircularOrder
-/

/-! ### Dual constructions -/


section OrderDual

instance (α : Type _) [Btw α] : Btw αᵒᵈ :=
  ⟨fun a b c : α => Btw c b a⟩

instance (α : Type _) [SBtw α] : SBtw αᵒᵈ :=
  ⟨fun a b c : α => Sbtw c b a⟩

instance (α : Type _) [h : CircularPreorder α] : CircularPreorder αᵒᵈ :=
  { OrderDual.hasBtw α,
    OrderDual.hasSbtw α with
    btw_refl := btw_refl
    btw_cyclic_left := fun a b c => btw_cyclic_right
    sbtw_trans_left := fun a b c d habc hbdc => hbdc.trans_right habc
    sbtw_iff_btw_not_btw := fun a b c => @sbtw_iff_btw_not_btw α _ c b a }

instance (α : Type _) [CircularPartialOrder α] : CircularPartialOrder αᵒᵈ :=
  { OrderDual.circularPreorder α with
    btw_antisymm := fun a b c habc hcba => @btw_antisymm α _ _ _ _ hcba habc }

instance (α : Type _) [CircularOrder α] : CircularOrder αᵒᵈ :=
  { OrderDual.circularPartialOrder α with btw_total := fun a b c => btw_total c b a }

end OrderDual

