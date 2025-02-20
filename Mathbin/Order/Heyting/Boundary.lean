/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module order.heyting.boundary
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.BooleanAlgebra

/-!
# Co-Heyting boundary

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The boundary of an element of a co-Heyting algebra is the intersection of its Heyting negation with
itself. The boundary in the co-Heyting algebra of closed sets coincides with the topological
boundary.

## Main declarations

* `coheyting.boundary`: Co-Heyting boundary. `coheyting.boundary a = a ⊓ ￢a`

## Notation

`∂ a` is notation for `coheyting.boundary a` in locale `heyting`.
-/


variable {α : Type _}

namespace Coheyting

variable [CoheytingAlgebra α] {a b : α}

#print Coheyting.boundary /-
/-- The boundary of an element of a co-Heyting algebra is the intersection of its Heyting negation
with itself. Note that this is always `⊥` for a boolean algebra. -/
def boundary (a : α) : α :=
  a ⊓ ￢a
#align coheyting.boundary Coheyting.boundary
-/

scoped[Heyting] prefix:120 "∂ " => Coheyting.boundary

#print Coheyting.inf_hnot_self /-
theorem inf_hnot_self (a : α) : a ⊓ ￢a = ∂ a :=
  rfl
#align coheyting.inf_hnot_self Coheyting.inf_hnot_self
-/

#print Coheyting.boundary_le /-
theorem boundary_le : ∂ a ≤ a :=
  inf_le_left
#align coheyting.boundary_le Coheyting.boundary_le
-/

#print Coheyting.boundary_le_hnot /-
theorem boundary_le_hnot : ∂ a ≤ ￢a :=
  inf_le_right
#align coheyting.boundary_le_hnot Coheyting.boundary_le_hnot
-/

#print Coheyting.boundary_bot /-
@[simp]
theorem boundary_bot : ∂ (⊥ : α) = ⊥ :=
  bot_inf_eq
#align coheyting.boundary_bot Coheyting.boundary_bot
-/

#print Coheyting.boundary_top /-
@[simp]
theorem boundary_top : ∂ (⊤ : α) = ⊥ := by rw [boundary, hnot_top, inf_bot_eq]
#align coheyting.boundary_top Coheyting.boundary_top
-/

#print Coheyting.boundary_hnot_le /-
theorem boundary_hnot_le (a : α) : ∂ (￢a) ≤ ∂ a :=
  inf_comm.trans_le <| inf_le_inf_right _ hnot_hnot_le
#align coheyting.boundary_hnot_le Coheyting.boundary_hnot_le
-/

#print Coheyting.boundary_hnot_hnot /-
@[simp]
theorem boundary_hnot_hnot (a : α) : ∂ (￢￢a) = ∂ (￢a) := by
  simp_rw [boundary, hnot_hnot_hnot, inf_comm]
#align coheyting.boundary_hnot_hnot Coheyting.boundary_hnot_hnot
-/

#print Coheyting.hnot_boundary /-
@[simp]
theorem hnot_boundary (a : α) : ￢∂ a = ⊤ := by rw [boundary, hnot_inf_distrib, sup_hnot_self]
#align coheyting.hnot_boundary Coheyting.hnot_boundary
-/

#print Coheyting.boundary_inf /-
/-- **Leibniz rule** for the co-Heyting boundary. -/
theorem boundary_inf (a b : α) : ∂ (a ⊓ b) = ∂ a ⊓ b ⊔ a ⊓ ∂ b := by unfold boundary;
  rw [hnot_inf_distrib, inf_sup_left, inf_right_comm, ← inf_assoc]
#align coheyting.boundary_inf Coheyting.boundary_inf
-/

#print Coheyting.boundary_inf_le /-
theorem boundary_inf_le : ∂ (a ⊓ b) ≤ ∂ a ⊔ ∂ b :=
  (boundary_inf _ _).trans_le <| sup_le_sup inf_le_left inf_le_right
#align coheyting.boundary_inf_le Coheyting.boundary_inf_le
-/

#print Coheyting.boundary_sup_le /-
theorem boundary_sup_le : ∂ (a ⊔ b) ≤ ∂ a ⊔ ∂ b :=
  by
  rw [boundary, inf_sup_right]
  exact
    sup_le_sup (inf_le_inf_left _ <| hnot_anti le_sup_left)
      (inf_le_inf_left _ <| hnot_anti le_sup_right)
#align coheyting.boundary_sup_le Coheyting.boundary_sup_le
-/

/- The intuitionistic version of `coheyting.boundary_le_boundary_sup_sup_boundary_inf_left`. Either
proof can be obtained from the other using the equivalence of Heyting algebras and intuitionistic
logic and duality between Heyting and co-Heyting algebras. It is crucial that the following proof be
intuitionistic. -/
example (a b : Prop) : (a ∧ b ∨ ¬(a ∧ b)) ∧ ((a ∨ b) ∨ ¬(a ∨ b)) → a ∨ ¬a :=
  by
  rintro ⟨⟨ha, hb⟩ | hnab, (ha | hb) | hnab⟩ <;> try exact Or.inl ha
  · exact Or.inr fun ha => hnab ⟨ha, hb⟩
  · exact Or.inr fun ha => hnab <| Or.inl ha

#print Coheyting.boundary_le_boundary_sup_sup_boundary_inf_left /-
theorem boundary_le_boundary_sup_sup_boundary_inf_left : ∂ a ≤ ∂ (a ⊔ b) ⊔ ∂ (a ⊓ b) :=
  by
  simp only [boundary, sup_inf_left, sup_inf_right, sup_right_idem, le_inf_iff, sup_assoc,
    @sup_comm _ _ _ a]
  refine' ⟨⟨⟨_, _⟩, _⟩, ⟨_, _⟩, _⟩ <;> try exact le_sup_of_le_left inf_le_left <;>
    refine' inf_le_of_right_le _
  · rw [hnot_le_iff_codisjoint_right, codisjoint_left_comm]
    exact codisjoint_hnot_left
  · refine' le_sup_of_le_right _
    rw [hnot_le_iff_codisjoint_right]
    exact codisjoint_hnot_right.mono_right (hnot_anti inf_le_left)
#align coheyting.boundary_le_boundary_sup_sup_boundary_inf_left Coheyting.boundary_le_boundary_sup_sup_boundary_inf_left
-/

#print Coheyting.boundary_le_boundary_sup_sup_boundary_inf_right /-
theorem boundary_le_boundary_sup_sup_boundary_inf_right : ∂ b ≤ ∂ (a ⊔ b) ⊔ ∂ (a ⊓ b) := by
  rw [@sup_comm _ _ a, inf_comm]; exact boundary_le_boundary_sup_sup_boundary_inf_left
#align coheyting.boundary_le_boundary_sup_sup_boundary_inf_right Coheyting.boundary_le_boundary_sup_sup_boundary_inf_right
-/

#print Coheyting.boundary_sup_sup_boundary_inf /-
theorem boundary_sup_sup_boundary_inf (a b : α) : ∂ (a ⊔ b) ⊔ ∂ (a ⊓ b) = ∂ a ⊔ ∂ b :=
  le_antisymm (sup_le boundary_sup_le boundary_inf_le) <|
    sup_le boundary_le_boundary_sup_sup_boundary_inf_left
      boundary_le_boundary_sup_sup_boundary_inf_right
#align coheyting.boundary_sup_sup_boundary_inf Coheyting.boundary_sup_sup_boundary_inf
-/

#print Coheyting.boundary_idem /-
@[simp]
theorem boundary_idem (a : α) : ∂ ∂ a = ∂ a := by rw [boundary, hnot_boundary, inf_top_eq]
#align coheyting.boundary_idem Coheyting.boundary_idem
-/

#print Coheyting.hnot_hnot_sup_boundary /-
theorem hnot_hnot_sup_boundary (a : α) : ￢￢a ⊔ ∂ a = a := by
  rw [boundary, sup_inf_left, hnot_sup_self, inf_top_eq, sup_eq_right]; exact hnot_hnot_le
#align coheyting.hnot_hnot_sup_boundary Coheyting.hnot_hnot_sup_boundary
-/

#print Coheyting.hnot_eq_top_iff_exists_boundary /-
theorem hnot_eq_top_iff_exists_boundary : ￢a = ⊤ ↔ ∃ b, ∂ b = a :=
  ⟨fun h => ⟨a, by rw [boundary, h, inf_top_eq]⟩, by rintro ⟨b, rfl⟩; exact hnot_boundary _⟩
#align coheyting.hnot_eq_top_iff_exists_boundary Coheyting.hnot_eq_top_iff_exists_boundary
-/

end Coheyting

open scoped Heyting

section BooleanAlgebra

variable [BooleanAlgebra α]

#print Coheyting.boundary_eq_bot /-
@[simp]
theorem Coheyting.boundary_eq_bot (a : α) : ∂ a = ⊥ :=
  inf_compl_eq_bot
#align coheyting.boundary_eq_bot Coheyting.boundary_eq_bot
-/

end BooleanAlgebra

