/-
Copyright (c) 2014 Floris van Doorn (c) 2016 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Leonardo de Moura, Jeremy Avigad, Mario Carneiro

! This file was ported from Lean 3 source module data.nat.units
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Basic
import Mathbin.Algebra.Group.Units

/-! # The units of the natural numbers as a `monoid` and `add_monoid`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


namespace Nat

#print Nat.units_eq_one /-
theorem units_eq_one (u : ℕˣ) : u = 1 :=
  Units.ext <| Nat.eq_one_of_dvd_one ⟨u.inv, u.val_inv.symm⟩
#align nat.units_eq_one Nat.units_eq_one
-/

#print Nat.addUnits_eq_zero /-
theorem addUnits_eq_zero (u : AddUnits ℕ) : u = 0 :=
  AddUnits.ext <| (Nat.eq_zero_of_add_eq_zero u.val_neg).1
#align nat.add_units_eq_zero Nat.addUnits_eq_zero
-/

#print Nat.isUnit_iff /-
@[simp]
protected theorem isUnit_iff {n : ℕ} : IsUnit n ↔ n = 1 :=
  Iff.intro
    (fun ⟨u, hu⟩ =>
      match n, u, hu, Nat.units_eq_one u with
      | _, _, rfl, rfl => rfl)
    fun h => h.symm ▸ ⟨1, rfl⟩
#align nat.is_unit_iff Nat.isUnit_iff
-/

#print Nat.unique_units /-
instance unique_units : Unique ℕˣ where
  default := 1
  uniq := Nat.units_eq_one
#align nat.unique_units Nat.unique_units
-/

#print Nat.unique_addUnits /-
instance unique_addUnits : Unique (AddUnits ℕ)
    where
  default := 0
  uniq := Nat.addUnits_eq_zero
#align nat.unique_add_units Nat.unique_addUnits
-/

end Nat

