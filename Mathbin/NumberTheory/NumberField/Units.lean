/-
Copyright (c) 2023 Xavier Roblot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Xavier Roblot

! This file was ported from Lean 3 source module number_theory.number_field.units
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.NumberField.Norm

/-!
# Units of a number field

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
We prove results about the group `(𝓞 K)ˣ` of units of the ring of integers `𝓞 K` of a number
field `K`.

## Main results
* `number_field.is_unit_iff_norm`: an algebraic integer `x : 𝓞 K` is a unit if and only if
`|norm ℚ x| = 1`

## Tags
number field, units
 -/


open scoped NumberField

noncomputable section

open NumberField Units

section Rat

#print Rat.RingOfIntegers.isUnit_iff /-
theorem Rat.RingOfIntegers.isUnit_iff {x : 𝓞 ℚ} : IsUnit x ↔ (x : ℚ) = 1 ∨ (x : ℚ) = -1 := by
  simp_rw [(isUnit_map_iff (Rat.ringOfIntegersEquiv : 𝓞 ℚ →+* ℤ) x).symm, Int.isUnit_iff,
    RingEquiv.coe_toRingHom, RingEquiv.map_eq_one_iff, RingEquiv.map_eq_neg_one_iff, ←
    subtype.coe_injective.eq_iff, AddSubgroupClass.coe_neg, algebraMap.coe_one]
#align rat.ring_of_integers.is_unit_iff Rat.RingOfIntegers.isUnit_iff
-/

end Rat

variable (K : Type _) [Field K]

section IsUnit

attribute [local instance] NumberField.ringOfIntegersAlgebra

variable {K}

#print isUnit_iff_norm /-
theorem isUnit_iff_norm [NumberField K] (x : 𝓞 K) :
    IsUnit x ↔ |(RingOfIntegers.norm ℚ x : ℚ)| = 1 :=
  by
  convert (RingOfIntegers.isUnit_norm ℚ).symm
  rw [← abs_one, abs_eq_abs, ← Rat.RingOfIntegers.isUnit_iff]
#align is_unit_iff_norm isUnit_iff_norm
-/

end IsUnit

