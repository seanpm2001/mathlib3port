/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module topology.order.priestley
! leanprover-community/mathlib commit 50832daea47b195a48b5b33b1c8b2162c48c3afc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.UpperLower.Basic
import Mathbin.Topology.Separation

/-!
# Priestley spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines Priestley spaces. A Priestley space is an ordered compact topological space such
that any two distinct points can be separated by a clopen upper set.

## Main declarations

* `priestley_space`: Prop-valued mixin stating the Priestley separation axiom: Any two distinct
  points can be separated by a clopen upper set.

## Implementation notes

We do not include compactness in the definition, so a Priestley space is to be declared as follows:
`[preorder α] [topological_space α] [compact_space α] [priestley_space α]`

## References

* [Wikipedia, *Priestley space*](https://en.wikipedia.org/wiki/Priestley_space)
* [Davey, Priestley *Introduction to Lattices and Order*][davey_priestley]
-/


open Set

variable {α : Type _}

#print PriestleySpace /-
/-- A Priestley space is an ordered topological space such that any two distinct points can be
separated by a clopen upper set. Compactness is often assumed, but we do not include it here. -/
class PriestleySpace (α : Type _) [Preorder α] [TopologicalSpace α] where
  priestley {x y : α} : ¬x ≤ y → ∃ U : Set α, IsClopen U ∧ IsUpperSet U ∧ x ∈ U ∧ y ∉ U
#align priestley_space PriestleySpace
-/

variable [TopologicalSpace α]

section Preorder

variable [Preorder α] [PriestleySpace α] {x y : α}

#print exists_clopen_upper_of_not_le /-
theorem exists_clopen_upper_of_not_le :
    ¬x ≤ y → ∃ U : Set α, IsClopen U ∧ IsUpperSet U ∧ x ∈ U ∧ y ∉ U :=
  PriestleySpace.priestley
#align exists_clopen_upper_of_not_le exists_clopen_upper_of_not_le
-/

#print exists_clopen_lower_of_not_le /-
theorem exists_clopen_lower_of_not_le (h : ¬x ≤ y) :
    ∃ U : Set α, IsClopen U ∧ IsLowerSet U ∧ x ∉ U ∧ y ∈ U :=
  let ⟨U, hU, hU', hx, hy⟩ := exists_clopen_upper_of_not_le h
  ⟨Uᶜ, hU.compl, hU'.compl, Classical.not_not.2 hx, hy⟩
#align exists_clopen_lower_of_not_le exists_clopen_lower_of_not_le
-/

end Preorder

section PartialOrder

variable [PartialOrder α] [PriestleySpace α] {x y : α}

#print exists_clopen_upper_or_lower_of_ne /-
theorem exists_clopen_upper_or_lower_of_ne (h : x ≠ y) :
    ∃ U : Set α, IsClopen U ∧ (IsUpperSet U ∨ IsLowerSet U) ∧ x ∈ U ∧ y ∉ U :=
  by
  obtain h | h := h.not_le_or_not_le
  · exact (exists_clopen_upper_of_not_le h).imp fun U => And.imp_right <| And.imp_left Or.inl
  · obtain ⟨U, hU, hU', hy, hx⟩ := exists_clopen_lower_of_not_le h
    exact ⟨U, hU, Or.inr hU', hx, hy⟩
#align exists_clopen_upper_or_lower_of_ne exists_clopen_upper_or_lower_of_ne
-/

#print PriestleySpace.toT2Space /-
-- See note [lower instance priority]
instance (priority := 100) PriestleySpace.toT2Space : T2Space α :=
  ⟨fun x y h =>
    let ⟨U, hU, _, hx, hy⟩ := exists_clopen_upper_or_lower_of_ne h
    ⟨U, Uᶜ, hU.IsOpen, hU.compl.IsOpen, hx, hy, disjoint_compl_right⟩⟩
#align priestley_space.to_t2_space PriestleySpace.toT2Space
-/

end PartialOrder

