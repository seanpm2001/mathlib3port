/-
Copyright (c) 2021 Peter Nelson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Peter Nelson, Yaël Dillies

! This file was ported from Lean 3 source module data.fintype.order
! leanprover-community/mathlib commit 63f84d91dd847f50bae04a01071f3a5491934e36
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Lattice
import Mathbin.Data.Finset.Order

/-!
# Order structures on finite types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides order instances on fintypes.

## Computable instances

On a `fintype`, we can construct
* an `order_bot` from `semilattice_inf`.
* an `order_top` from `semilattice_sup`.
* a `bounded_order` from `lattice`.

Those are marked as `def` to avoid defeqness issues.

## Completion instances

Those instances are noncomputable because the definitions of `Sup` and `Inf` use `set.to_finset` and
set membership is undecidable in general.

On a `fintype`, we can promote:
* a `lattice` to a `complete_lattice`.
* a `distrib_lattice` to a `complete_distrib_lattice`.
* a `linear_order`  to a `complete_linear_order`.
* a `boolean_algebra` to a `complete_boolean_algebra`.

Those are marked as `def` to avoid typeclass loops.

## Concrete instances

We provide a few instances for concrete types:
* `fin.complete_linear_order`
* `bool.complete_linear_order`
* `bool.complete_boolean_algebra`
-/


open Finset

namespace Fintype

variable {ι α : Type _} [Fintype ι] [Fintype α]

section Nonempty

variable (α) [Nonempty α]

#print Fintype.toOrderBot /-
-- See note [reducible non-instances]
/-- Constructs the `⊥` of a finite nonempty `semilattice_inf`. -/
@[reducible]
def toOrderBot [SemilatticeInf α] : OrderBot α
    where
  bot := univ.inf' univ_nonempty id
  bot_le a := inf'_le _ <| mem_univ a
#align fintype.to_order_bot Fintype.toOrderBot
-/

#print Fintype.toOrderTop /-
-- See note [reducible non-instances]
/-- Constructs the `⊤` of a finite nonempty `semilattice_sup` -/
@[reducible]
def toOrderTop [SemilatticeSup α] : OrderTop α
    where
  top := univ.sup' univ_nonempty id
  le_top a := le_sup' _ <| mem_univ a
#align fintype.to_order_top Fintype.toOrderTop
-/

#print Fintype.toBoundedOrder /-
-- See note [reducible non-instances]
/-- Constructs the `⊤` and `⊥` of a finite nonempty `lattice`. -/
@[reducible]
def toBoundedOrder [Lattice α] : BoundedOrder α :=
  { toOrderBot α, toOrderTop α with }
#align fintype.to_bounded_order Fintype.toBoundedOrder
-/

end Nonempty

section BoundedOrder

variable (α)

open scoped Classical

#print Fintype.toCompleteLattice /-
-- See note [reducible non-instances]
/-- A finite bounded lattice is complete. -/
@[reducible]
noncomputable def toCompleteLattice [Lattice α] [BoundedOrder α] : CompleteLattice α :=
  { ‹Lattice α›,
    ‹BoundedOrder α› with
    sSup := fun s => s.toFinset.sup id
    sInf := fun s => s.toFinset.inf id
    le_sup := fun _ _ ha => Finset.le_sup (Set.mem_toFinset.mpr ha)
    sup_le := fun s _ ha => Finset.sup_le fun b hb => ha _ <| Set.mem_toFinset.mp hb
    inf_le := fun _ _ ha => Finset.inf_le (Set.mem_toFinset.mpr ha)
    le_inf := fun s _ ha => Finset.le_inf fun b hb => ha _ <| Set.mem_toFinset.mp hb }
#align fintype.to_complete_lattice Fintype.toCompleteLattice
-/

#print Fintype.toCompleteDistribLattice /-
-- See note [reducible non-instances]
/-- A finite bounded distributive lattice is completely distributive. -/
@[reducible]
noncomputable def toCompleteDistribLattice [DistribLattice α] [BoundedOrder α] :
    CompleteDistribLattice α :=
  {
    toCompleteLattice
      α with
    iInf_sup_le_sup_inf := fun a s =>
      by
      convert (Finset.inf_sup_distrib_left _ _ _).ge
      convert (Finset.inf_eq_iInf _ _).symm
      simp_rw [Set.mem_toFinset]
      rfl
    inf_sup_le_iSup_inf := fun a s =>
      by
      convert (Finset.sup_inf_distrib_left _ _ _).le
      convert (Finset.sup_eq_iSup _ _).symm
      simp_rw [Set.mem_toFinset]
      rfl }
#align fintype.to_complete_distrib_lattice Fintype.toCompleteDistribLattice
-/

#print Fintype.toCompleteLinearOrder /-
-- See note [reducible non-instances]
/-- A finite bounded linear order is complete. -/
@[reducible]
noncomputable def toCompleteLinearOrder [LinearOrder α] [BoundedOrder α] : CompleteLinearOrder α :=
  { toCompleteLattice α, ‹LinearOrder α› with }
#align fintype.to_complete_linear_order Fintype.toCompleteLinearOrder
-/

#print Fintype.toCompleteBooleanAlgebra /-
-- See note [reducible non-instances]
/-- A finite boolean algebra is complete. -/
@[reducible]
noncomputable def toCompleteBooleanAlgebra [BooleanAlgebra α] : CompleteBooleanAlgebra α :=
  { Fintype.toCompleteDistribLattice α, ‹BooleanAlgebra α› with }
#align fintype.to_complete_boolean_algebra Fintype.toCompleteBooleanAlgebra
-/

end BoundedOrder

section Nonempty

variable (α) [Nonempty α]

#print Fintype.toCompleteLatticeOfNonempty /-
-- See note [reducible non-instances]
/-- A nonempty finite lattice is complete. If the lattice is already a `bounded_order`, then use
`fintype.to_complete_lattice` instead, as this gives definitional equality for `⊥` and `⊤`. -/
@[reducible]
noncomputable def toCompleteLatticeOfNonempty [Lattice α] : CompleteLattice α :=
  @toCompleteLattice _ _ _ <| @toBoundedOrder α _ ⟨Classical.arbitrary α⟩ _
#align fintype.to_complete_lattice_of_nonempty Fintype.toCompleteLatticeOfNonempty
-/

#print Fintype.toCompleteLinearOrderOfNonempty /-
-- See note [reducible non-instances]
/-- A nonempty finite linear order is complete. If the linear order is already a `bounded_order`,
then use `fintype.to_complete_linear_order` instead, as this gives definitional equality for `⊥` and
`⊤`. -/
@[reducible]
noncomputable def toCompleteLinearOrderOfNonempty [LinearOrder α] : CompleteLinearOrder α :=
  { toCompleteLatticeOfNonempty α, ‹LinearOrder α› with }
#align fintype.to_complete_linear_order_of_nonempty Fintype.toCompleteLinearOrderOfNonempty
-/

end Nonempty

end Fintype

/-! ### Concrete instances -/


noncomputable instance {n : ℕ} : CompleteLinearOrder (Fin (n + 1)) :=
  Fintype.toCompleteLinearOrder _

noncomputable instance : CompleteLinearOrder Bool :=
  Fintype.toCompleteLinearOrder _

noncomputable instance : CompleteBooleanAlgebra Bool :=
  Fintype.toCompleteBooleanAlgebra _

/-! ### Directed Orders -/


variable {α : Type _}

#print Directed.fintype_le /-
theorem Directed.fintype_le {r : α → α → Prop} [IsTrans α r] {β γ : Type _} [Nonempty γ] {f : γ → α}
    [Fintype β] (D : Directed r f) (g : β → γ) : ∃ z, ∀ i, r (f (g i)) (f z) := by
  classical
  obtain ⟨z, hz⟩ := D.finset_le (Finset.image g Finset.univ)
  exact ⟨z, fun i => hz (g i) (Finset.mem_image_of_mem g (Finset.mem_univ i))⟩
#align directed.fintype_le Directed.fintype_le
-/

#print Fintype.exists_le /-
theorem Fintype.exists_le [Nonempty α] [Preorder α] [IsDirected α (· ≤ ·)] {β : Type _} [Fintype β]
    (f : β → α) : ∃ M, ∀ i, f i ≤ M :=
  directed_id.fintype_le _
#align fintype.exists_le Fintype.exists_le
-/

#print Fintype.bddAbove_range /-
theorem Fintype.bddAbove_range [Nonempty α] [Preorder α] [IsDirected α (· ≤ ·)] {β : Type _}
    [Fintype β] (f : β → α) : BddAbove (Set.range f) :=
  by
  obtain ⟨M, hM⟩ := Fintype.exists_le f
  refine' ⟨M, fun a ha => _⟩
  obtain ⟨b, rfl⟩ := ha
  exact hM b
#align fintype.bdd_above_range Fintype.bddAbove_range
-/

