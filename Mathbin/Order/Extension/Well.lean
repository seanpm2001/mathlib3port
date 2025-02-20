/-
Copyright (c) 2022 Yaël Dillies, Junyan Xu. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Junyan Xu

! This file was ported from Lean 3 source module order.extension.well
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Prod.Lex
import Mathbin.SetTheory.Ordinal.Arithmetic

/-!
# Extend a well-founded order to a well-order

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file constructs a well-order (linear well-founded order) which is an extension of a given
well-founded order.

## Proof idea

We can map our order into two well-orders:
* the first map respects the order but isn't necessarily injective. Namely, this is the *rank*
  function `rank : α → ordinal`.
* the second map is injective but doesn't necessarily respect the order. This is an arbitrary
  well-order on `α`.

Then their lexicographic product is a well-founded linear order which our original order injects in.
-/


universe u

variable {α : Type u} {r : α → α → Prop}

namespace WellFounded

variable (hwf : WellFounded r)

#print WellFounded.wellOrderExtension /-
/-- An arbitrary well order on `α` that extends `r`.

The construction maps `r` into two well-orders: the first map is `well_founded.rank`, which is not
necessarily injective but respects the order `r`; the other map is the identity (with an arbitrarily
chosen well-order on `α`), which is injective but doesn't respect `r`.

By taking the lexicographic product of the two, we get both properties, so we can pull it back and
get an well-order that extend our original order `r`. Another way to view this is that we choose an
arbitrary well-order to serve as a tiebreak between two elements of same rank.
-/
noncomputable def wellOrderExtension : LinearOrder α :=
  let l : LinearOrder α := IsWellOrder.linearOrder WellOrderingRel
  @LinearOrder.lift' α (Ordinal ×ₗ α) _ (fun a : α => (WellFounded.rank.{u} hwf a, a)) fun _ _ =>
    congr_arg Prod.snd
#align well_founded.well_order_extension WellFounded.wellOrderExtension
-/

#print WellFounded.wellOrderExtension.isWellFounded_lt /-
instance wellOrderExtension.isWellFounded_lt : IsWellFounded α hwf.wellOrderExtension.lt :=
  ⟨InvImage.wf _ <| WellFounded.prod_lex Ordinal.wellFoundedLT.wf WellOrderingRel.isWellOrder.wf⟩
#align well_founded.well_order_extension.is_well_founded_lt WellFounded.wellOrderExtension.isWellFounded_lt
-/

#print WellFounded.exists_well_order_ge /-
/-- Any well-founded relation can be extended to a well-ordering on that type. -/
theorem exists_well_order_ge : ∃ s, r ≤ s ∧ IsWellOrder α s :=
  ⟨hwf.wellOrderExtension.lt, fun a b h => Prod.Lex.left _ _ (hwf.rank_lt_of_rel h), by constructor⟩
#align well_founded.exists_well_order_ge WellFounded.exists_well_order_ge
-/

end WellFounded

#print WellOrderExtension /-
/-- A type alias for `α`, intended to extend a well-founded order on `α` to a well-order. -/
def WellOrderExtension (α) : Type _ :=
  α
#align well_order_extension WellOrderExtension
-/

instance [Inhabited α] : Inhabited (WellOrderExtension α) :=
  ‹Inhabited (WellOrderExtension α)›

#print toWellOrderExtension /-
/-- "Identity" equivalence between a well-founded order and its well-order extension. -/
def toWellOrderExtension : α ≃ WellOrderExtension α :=
  Equiv.refl _
#align to_well_order_extension toWellOrderExtension
-/

noncomputable instance [LT α] [WellFoundedLT α] : LinearOrder (WellOrderExtension α) :=
  (IsWellFounded.wf : @WellFounded α (· < ·)).wellOrderExtension

#print WellOrderExtension.wellFoundedLT /-
instance WellOrderExtension.wellFoundedLT [LT α] [WellFoundedLT α] :
    WellFoundedLT (WellOrderExtension α) :=
  WellFounded.wellOrderExtension.isWellFounded_lt _
#align well_order_extension.well_founded_lt WellOrderExtension.wellFoundedLT
-/

#print toWellOrderExtension_strictMono /-
theorem toWellOrderExtension_strictMono [Preorder α] [WellFoundedLT α] :
    StrictMono (toWellOrderExtension : α → WellOrderExtension α) := fun a b h =>
  Prod.Lex.left _ _ <| WellFounded.rank_lt_of_rel _ h
#align to_well_order_extension_strict_mono toWellOrderExtension_strictMono
-/

