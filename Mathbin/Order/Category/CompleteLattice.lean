/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module order.category.CompleteLattice
! leanprover-community/mathlib commit 740acc0e6f9adf4423f92a485d0456fc271482da
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Category.BoundedLattice
import Mathbin.Order.Hom.CompleteLattice

/-!
# The category of complete lattices

This file defines `CompleteLattice`, the category of complete lattices.
-/


universe u

open CategoryTheory

/-- The category of complete lattices. -/
def CompleteLatticeCat :=
  Bundled CompleteLattice
#align CompleteLattice CompleteLatticeCat

namespace CompleteLatticeCat

instance : CoeSort CompleteLatticeCat (Type _) :=
  Bundled.hasCoeToSort

instance (X : CompleteLatticeCat) : CompleteLattice X :=
  X.str

/-- Construct a bundled `CompleteLattice` from a `complete_lattice`. -/
def of (α : Type _) [CompleteLattice α] : CompleteLatticeCat :=
  Bundled.of α
#align CompleteLattice.of CompleteLatticeCat.of

@[simp]
theorem coe_of (α : Type _) [CompleteLattice α] : ↥(of α) = α :=
  rfl
#align CompleteLattice.coe_of CompleteLatticeCat.coe_of

instance : Inhabited CompleteLatticeCat :=
  ⟨of PUnit⟩

instance : BundledHom @CompleteLatticeHom
    where
  toFun _ _ _ _ := coeFn
  id := @CompleteLatticeHom.id
  comp := @CompleteLatticeHom.comp
  hom_ext X Y _ _ := FunLike.coe_injective

instance : LargeCategory.{u} CompleteLatticeCat :=
  BundledHom.category CompleteLatticeHom

instance : ConcreteCategory CompleteLatticeCat :=
  BundledHom.concreteCategory CompleteLatticeHom

instance hasForgetToBoundedLattice : HasForget₂ CompleteLatticeCat BoundedLattice
    where
  forget₂ :=
    { obj := fun X => BoundedLattice.of X
      map := fun X Y => CompleteLatticeHom.toBoundedLatticeHom }
  forget_comp := rfl
#align CompleteLattice.has_forget_to_BoundedLattice CompleteLatticeCat.hasForgetToBoundedLattice

/-- Constructs an isomorphism of complete lattices from an order isomorphism between them. -/
@[simps]
def Iso.mk {α β : CompleteLatticeCat.{u}} (e : α ≃o β) : α ≅ β
    where
  Hom := e
  inv := e.symm
  hom_inv_id' := by
    ext
    exact e.symm_apply_apply _
  inv_hom_id' := by
    ext
    exact e.apply_symm_apply _
#align CompleteLattice.iso.mk CompleteLatticeCat.Iso.mk

/-- `order_dual` as a functor. -/
@[simps]
def dual : CompleteLatticeCat ⥤ CompleteLatticeCat
    where
  obj X := of Xᵒᵈ
  map X Y := CompleteLatticeHom.dual
#align CompleteLattice.dual CompleteLatticeCat.dual

/-- The equivalence between `CompleteLattice` and itself induced by `order_dual` both ways. -/
@[simps Functor inverse]
def dualEquiv : CompleteLatticeCat ≌ CompleteLatticeCat :=
  Equivalence.mk dual dual
    (NatIso.ofComponents (fun X => Iso.mk <| OrderIso.dualDual X) fun X Y f => rfl)
    (NatIso.ofComponents (fun X => Iso.mk <| OrderIso.dualDual X) fun X Y f => rfl)
#align CompleteLattice.dual_equiv CompleteLatticeCat.dualEquiv

end CompleteLatticeCat

theorem completeLatticeCat_dual_comp_forget_to_boundedLattice :
    CompleteLatticeCat.dual ⋙ forget₂ CompleteLatticeCat BoundedLattice =
      forget₂ CompleteLatticeCat BoundedLattice ⋙ BoundedLattice.dual :=
  rfl
#align CompleteLattice_dual_comp_forget_to_BoundedLattice completeLatticeCat_dual_comp_forget_to_boundedLattice

