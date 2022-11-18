/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Yury Kudryashov, Neil Strickland
-/
import Mathbin.Algebra.Ring.InjSurj
import Mathbin.Algebra.Group.Units

/-!
# Units in semirings and rings

-/


universe u v w x

variable {α : Type u} {β : Type v} {γ : Type w} {R : Type x}

open Function

namespace Units

section HasDistribNeg

variable [Monoid α] [HasDistribNeg α] {a b : α}

/-- Each element of the group of units of a ring has an additive inverse. -/
instance : Neg αˣ :=
  ⟨fun u => ⟨-↑u, -↑u⁻¹, by simp, by simp⟩⟩

/-- Representing an element of a ring's unit group as an element of the ring commutes with
    mapping this element to its additive inverse. -/
@[simp, norm_cast]
protected theorem coe_neg (u : αˣ) : (↑(-u) : α) = -u :=
  rfl
#align units.coe_neg Units.coe_neg

@[simp, norm_cast]
protected theorem coe_neg_one : ((-1 : αˣ) : α) = -1 :=
  rfl
#align units.coe_neg_one Units.coe_neg_one

instance : HasDistribNeg αˣ :=
  Units.ext.HasDistribNeg _ Units.coe_neg Units.coe_mul

@[field_simps]
theorem neg_divp (a : α) (u : αˣ) : -(a /ₚ u) = -a /ₚ u := by simp only [divp, neg_mul]
#align units.neg_divp Units.neg_divp

end HasDistribNeg

section Ring

variable [Ring α] {a b : α}

@[field_simps]
theorem divp_add_divp_same (a b : α) (u : αˣ) : a /ₚ u + b /ₚ u = (a + b) /ₚ u := by simp only [divp, add_mul]
#align units.divp_add_divp_same Units.divp_add_divp_same

@[field_simps]
theorem divp_sub_divp_same (a b : α) (u : αˣ) : a /ₚ u - b /ₚ u = (a - b) /ₚ u := by
  rw [sub_eq_add_neg, sub_eq_add_neg, neg_divp, divp_add_divp_same]
#align units.divp_sub_divp_same Units.divp_sub_divp_same

@[field_simps]
theorem add_divp (a b : α) (u : αˣ) : a + b /ₚ u = (a * u + b) /ₚ u := by
  simp only [divp, add_mul, Units.mul_inv_cancel_right]
#align units.add_divp Units.add_divp

@[field_simps]
theorem sub_divp (a b : α) (u : αˣ) : a - b /ₚ u = (a * u - b) /ₚ u := by
  simp only [divp, sub_mul, Units.mul_inv_cancel_right]
#align units.sub_divp Units.sub_divp

@[field_simps]
theorem divp_add (a b : α) (u : αˣ) : a /ₚ u + b = (a + b * u) /ₚ u := by
  simp only [divp, add_mul, Units.mul_inv_cancel_right]
#align units.divp_add Units.divp_add

@[field_simps]
theorem divp_sub (a b : α) (u : αˣ) : a /ₚ u - b = (a - b * u) /ₚ u := by
  simp only [divp, sub_mul, sub_right_inj]
  assoc_rw [Units.mul_inv, mul_one]
#align units.divp_sub Units.divp_sub

end Ring

end Units

theorem IsUnit.neg [Monoid α] [HasDistribNeg α] {a : α} : IsUnit a → IsUnit (-a)
  | ⟨x, hx⟩ => hx ▸ (-x).IsUnit
#align is_unit.neg IsUnit.neg

@[simp]
theorem IsUnit.neg_iff [Monoid α] [HasDistribNeg α] (a : α) : IsUnit (-a) ↔ IsUnit a :=
  ⟨fun h => neg_neg a ▸ h.neg, IsUnit.neg⟩
#align is_unit.neg_iff IsUnit.neg_iff

theorem IsUnit.sub_iff [Ring α] {x y : α} : IsUnit (x - y) ↔ IsUnit (y - x) :=
  (IsUnit.neg_iff _).symm.trans <| neg_sub x y ▸ Iff.rfl
#align is_unit.sub_iff IsUnit.sub_iff

namespace Units

@[field_simps]
theorem divp_add_divp [CommRing α] (a b : α) (u₁ u₂ : αˣ) : a /ₚ u₁ + b /ₚ u₂ = (a * u₂ + u₁ * b) /ₚ (u₁ * u₂) := by
  simp only [divp, add_mul, mul_inv_rev, coe_mul]
  rw [mul_comm (↑u₁ * b), mul_comm b]
  assoc_rw [mul_inv, mul_inv, mul_one, mul_one]
#align units.divp_add_divp Units.divp_add_divp

@[field_simps]
theorem divp_sub_divp [CommRing α] (a b : α) (u₁ u₂ : αˣ) : a /ₚ u₁ - b /ₚ u₂ = (a * u₂ - u₁ * b) /ₚ (u₁ * u₂) := by
  simp_rw [sub_eq_add_neg, neg_divp, divp_add_divp, mul_neg]
#align units.divp_sub_divp Units.divp_sub_divp

end Units

