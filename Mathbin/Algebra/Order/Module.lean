/-
Copyright (c) 2020 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis, Yaël Dillies

! This file was ported from Lean 3 source module algebra.order.module
! leanprover-community/mathlib commit 34ee86e6a59d911a8e4f89b68793ee7577ae79c7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Smul

/-!
# Ordered module

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we provide lemmas about `ordered_smul` that hold once a module structure is present.

## References

* https://en.wikipedia.org/wiki/Ordered_module

## Tags

ordered module, ordered scalar, ordered smul, ordered action, ordered vector space
-/


open scoped Pointwise

variable {k M N : Type _}

instance [Semiring k] [OrderedAddCommMonoid M] [Module k M] : Module k Mᵒᵈ
    where
  add_smul r s x := OrderDual.rec (add_smul _ _) x
  zero_smul m := OrderDual.rec (zero_smul _) m

section Semiring

variable [OrderedSemiring k] [OrderedAddCommGroup M] [Module k M] [OrderedSMul k M] {a b : M}
  {c : k}

#print smul_neg_iff_of_pos /-
/- can be generalized from `module k M` to `distrib_mul_action_with_zero k M` once it exists.
where `distrib_mul_action_with_zero k M`is the conjunction of `distrib_mul_action k M` and
`smul_with_zero k M`.-/
theorem smul_neg_iff_of_pos (hc : 0 < c) : c • a < 0 ↔ a < 0 :=
  by
  rw [← neg_neg a, smul_neg, neg_neg_iff_pos, neg_neg_iff_pos]
  exact smul_pos_iff_of_pos hc
#align smul_neg_iff_of_pos smul_neg_iff_of_pos
-/

end Semiring

section Ring

variable [OrderedRing k] [OrderedAddCommGroup M] [Module k M] [OrderedSMul k M] {a b : M} {c : k}

#print smul_lt_smul_of_neg /-
theorem smul_lt_smul_of_neg (h : a < b) (hc : c < 0) : c • b < c • a :=
  by
  rw [← neg_neg c, neg_smul, neg_smul (-c), neg_lt_neg_iff]
  exact smul_lt_smul_of_pos h (neg_pos_of_neg hc)
#align smul_lt_smul_of_neg smul_lt_smul_of_neg
-/

#print smul_le_smul_of_nonpos /-
theorem smul_le_smul_of_nonpos (h : a ≤ b) (hc : c ≤ 0) : c • b ≤ c • a :=
  by
  rw [← neg_neg c, neg_smul, neg_smul (-c), neg_le_neg_iff]
  exact smul_le_smul_of_nonneg h (neg_nonneg_of_nonpos hc)
#align smul_le_smul_of_nonpos smul_le_smul_of_nonpos
-/

#print eq_of_smul_eq_smul_of_neg_of_le /-
theorem eq_of_smul_eq_smul_of_neg_of_le (hab : c • a = c • b) (hc : c < 0) (h : a ≤ b) : a = b :=
  by
  rw [← neg_neg c, neg_smul, neg_smul (-c), neg_inj] at hab 
  exact eq_of_smul_eq_smul_of_pos_of_le hab (neg_pos_of_neg hc) h
#align eq_of_smul_eq_smul_of_neg_of_le eq_of_smul_eq_smul_of_neg_of_le
-/

#print lt_of_smul_lt_smul_of_nonpos /-
theorem lt_of_smul_lt_smul_of_nonpos (h : c • a < c • b) (hc : c ≤ 0) : b < a :=
  by
  rw [← neg_neg c, neg_smul, neg_smul (-c), neg_lt_neg_iff] at h 
  exact lt_of_smul_lt_smul_of_nonneg h (neg_nonneg_of_nonpos hc)
#align lt_of_smul_lt_smul_of_nonpos lt_of_smul_lt_smul_of_nonpos
-/

#print smul_lt_smul_iff_of_neg /-
theorem smul_lt_smul_iff_of_neg (hc : c < 0) : c • a < c • b ↔ b < a :=
  by
  rw [← neg_neg c, neg_smul, neg_smul (-c), neg_lt_neg_iff]
  exact smul_lt_smul_iff_of_pos (neg_pos_of_neg hc)
#align smul_lt_smul_iff_of_neg smul_lt_smul_iff_of_neg
-/

#print smul_neg_iff_of_neg /-
theorem smul_neg_iff_of_neg (hc : c < 0) : c • a < 0 ↔ 0 < a :=
  by
  rw [← neg_neg c, neg_smul, neg_neg_iff_pos]
  exact smul_pos_iff_of_pos (neg_pos_of_neg hc)
#align smul_neg_iff_of_neg smul_neg_iff_of_neg
-/

#print smul_pos_iff_of_neg /-
theorem smul_pos_iff_of_neg (hc : c < 0) : 0 < c • a ↔ a < 0 :=
  by
  rw [← neg_neg c, neg_smul, neg_pos]
  exact smul_neg_iff_of_pos (neg_pos_of_neg hc)
#align smul_pos_iff_of_neg smul_pos_iff_of_neg
-/

#print smul_nonpos_of_nonpos_of_nonneg /-
theorem smul_nonpos_of_nonpos_of_nonneg (hc : c ≤ 0) (ha : 0 ≤ a) : c • a ≤ 0 :=
  calc
    c • a ≤ c • 0 := smul_le_smul_of_nonpos ha hc
    _ = 0 := smul_zero c
#align smul_nonpos_of_nonpos_of_nonneg smul_nonpos_of_nonpos_of_nonneg
-/

#print smul_nonneg_of_nonpos_of_nonpos /-
theorem smul_nonneg_of_nonpos_of_nonpos (hc : c ≤ 0) (ha : a ≤ 0) : 0 ≤ c • a :=
  @smul_nonpos_of_nonpos_of_nonneg k Mᵒᵈ _ _ _ _ _ _ hc ha
#align smul_nonneg_of_nonpos_of_nonpos smul_nonneg_of_nonpos_of_nonpos
-/

alias smul_pos_iff_of_neg ↔ _ smul_pos_of_neg_of_neg
#align smul_pos_of_neg_of_neg smul_pos_of_neg_of_neg

alias smul_neg_iff_of_pos ↔ _ smul_neg_of_pos_of_neg
#align smul_neg_of_pos_of_neg smul_neg_of_pos_of_neg

alias smul_neg_iff_of_neg ↔ _ smul_neg_of_neg_of_pos
#align smul_neg_of_neg_of_pos smul_neg_of_neg_of_pos

#print antitone_smul_left /-
theorem antitone_smul_left (hc : c ≤ 0) : Antitone (SMul.smul c : M → M) := fun a b h =>
  smul_le_smul_of_nonpos h hc
#align antitone_smul_left antitone_smul_left
-/

#print strict_anti_smul_left /-
theorem strict_anti_smul_left (hc : c < 0) : StrictAnti (SMul.smul c : M → M) := fun a b h =>
  smul_lt_smul_of_neg h hc
#align strict_anti_smul_left strict_anti_smul_left
-/

#print smul_add_smul_le_smul_add_smul /-
/-- Binary **rearrangement inequality**. -/
theorem smul_add_smul_le_smul_add_smul [ContravariantClass M M (· + ·) (· ≤ ·)] {a b : k} {c d : M}
    (hab : a ≤ b) (hcd : c ≤ d) : a • d + b • c ≤ a • c + b • d :=
  by
  obtain ⟨b, rfl⟩ := exists_add_of_le hab
  obtain ⟨d, rfl⟩ := exists_add_of_le hcd
  rw [smul_add, add_right_comm, smul_add, ← add_assoc, add_smul _ _ d]
  rw [le_add_iff_nonneg_right] at hab hcd 
  exact add_le_add_left (le_add_of_nonneg_right <| smul_nonneg hab hcd) _
#align smul_add_smul_le_smul_add_smul smul_add_smul_le_smul_add_smul
-/

#print smul_add_smul_le_smul_add_smul' /-
/-- Binary **rearrangement inequality**. -/
theorem smul_add_smul_le_smul_add_smul' [ContravariantClass M M (· + ·) (· ≤ ·)] {a b : k} {c d : M}
    (hba : b ≤ a) (hdc : d ≤ c) : a • d + b • c ≤ a • c + b • d := by
  rw [add_comm (a • d), add_comm (a • c)]; exact smul_add_smul_le_smul_add_smul hba hdc
#align smul_add_smul_le_smul_add_smul' smul_add_smul_le_smul_add_smul'
-/

#print smul_add_smul_lt_smul_add_smul /-
/-- Binary strict **rearrangement inequality**. -/
theorem smul_add_smul_lt_smul_add_smul [CovariantClass M M (· + ·) (· < ·)]
    [ContravariantClass M M (· + ·) (· < ·)] {a b : k} {c d : M} (hab : a < b) (hcd : c < d) :
    a • d + b • c < a • c + b • d :=
  by
  obtain ⟨b, rfl⟩ := exists_add_of_le hab.le
  obtain ⟨d, rfl⟩ := exists_add_of_le hcd.le
  rw [smul_add, add_right_comm, smul_add, ← add_assoc, add_smul _ _ d]
  rw [lt_add_iff_pos_right] at hab hcd 
  exact add_lt_add_left (lt_add_of_pos_right _ <| smul_pos hab hcd) _
#align smul_add_smul_lt_smul_add_smul smul_add_smul_lt_smul_add_smul
-/

#print smul_add_smul_lt_smul_add_smul' /-
/-- Binary strict **rearrangement inequality**. -/
theorem smul_add_smul_lt_smul_add_smul' [CovariantClass M M (· + ·) (· < ·)]
    [ContravariantClass M M (· + ·) (· < ·)] {a b : k} {c d : M} (hba : b < a) (hdc : d < c) :
    a • d + b • c < a • c + b • d := by rw [add_comm (a • d), add_comm (a • c)];
  exact smul_add_smul_lt_smul_add_smul hba hdc
#align smul_add_smul_lt_smul_add_smul' smul_add_smul_lt_smul_add_smul'
-/

end Ring

section Field

variable [LinearOrderedField k] [OrderedAddCommGroup M] [Module k M] [OrderedSMul k M] {a b : M}
  {c : k}

#print smul_le_smul_iff_of_neg /-
theorem smul_le_smul_iff_of_neg (hc : c < 0) : c • a ≤ c • b ↔ b ≤ a :=
  by
  rw [← neg_neg c, neg_smul, neg_smul (-c), neg_le_neg_iff]
  exact smul_le_smul_iff_of_pos (neg_pos_of_neg hc)
#align smul_le_smul_iff_of_neg smul_le_smul_iff_of_neg
-/

#print inv_smul_le_iff_of_neg /-
theorem inv_smul_le_iff_of_neg (h : c < 0) : c⁻¹ • a ≤ b ↔ c • b ≤ a := by
  rw [← smul_le_smul_iff_of_neg h, smul_inv_smul₀ h.ne]; infer_instance
#align inv_smul_le_iff_of_neg inv_smul_le_iff_of_neg
-/

#print inv_smul_lt_iff_of_neg /-
theorem inv_smul_lt_iff_of_neg (h : c < 0) : c⁻¹ • a < b ↔ c • b < a := by
  rw [← smul_lt_smul_iff_of_neg h, smul_inv_smul₀ h.ne]; infer_instance
#align inv_smul_lt_iff_of_neg inv_smul_lt_iff_of_neg
-/

#print smul_inv_le_iff_of_neg /-
theorem smul_inv_le_iff_of_neg (h : c < 0) : a ≤ c⁻¹ • b ↔ b ≤ c • a := by
  rw [← smul_le_smul_iff_of_neg h, smul_inv_smul₀ h.ne]; infer_instance
#align smul_inv_le_iff_of_neg smul_inv_le_iff_of_neg
-/

#print smul_inv_lt_iff_of_neg /-
theorem smul_inv_lt_iff_of_neg (h : c < 0) : a < c⁻¹ • b ↔ b < c • a := by
  rw [← smul_lt_smul_iff_of_neg h, smul_inv_smul₀ h.ne]; infer_instance
#align smul_inv_lt_iff_of_neg smul_inv_lt_iff_of_neg
-/

variable (M)

#print OrderIso.smulLeftDual /-
/-- Left scalar multiplication as an order isomorphism. -/
@[simps]
def OrderIso.smulLeftDual {c : k} (hc : c < 0) : M ≃o Mᵒᵈ
    where
  toFun b := OrderDual.toDual (c • b)
  invFun b := c⁻¹ • OrderDual.ofDual b
  left_inv := inv_smul_smul₀ hc.Ne
  right_inv := smul_inv_smul₀ hc.Ne
  map_rel_iff' b₁ b₂ := smul_le_smul_iff_of_neg hc
#align order_iso.smul_left_dual OrderIso.smulLeftDual
-/

end Field

/-! ### Upper/lower bounds -/


section OrderedRing

variable [OrderedRing k] [OrderedAddCommGroup M] [Module k M] [OrderedSMul k M] {s : Set M} {c : k}

#print smul_lowerBounds_subset_upperBounds_smul /-
theorem smul_lowerBounds_subset_upperBounds_smul (hc : c ≤ 0) :
    c • lowerBounds s ⊆ upperBounds (c • s) :=
  (antitone_smul_left hc).image_lowerBounds_subset_upperBounds_image
#align smul_lower_bounds_subset_upper_bounds_smul smul_lowerBounds_subset_upperBounds_smul
-/

#print smul_upperBounds_subset_lowerBounds_smul /-
theorem smul_upperBounds_subset_lowerBounds_smul (hc : c ≤ 0) :
    c • upperBounds s ⊆ lowerBounds (c • s) :=
  (antitone_smul_left hc).image_upperBounds_subset_lowerBounds_image
#align smul_upper_bounds_subset_lower_bounds_smul smul_upperBounds_subset_lowerBounds_smul
-/

#print BddBelow.smul_of_nonpos /-
theorem BddBelow.smul_of_nonpos (hc : c ≤ 0) (hs : BddBelow s) : BddAbove (c • s) :=
  (antitone_smul_left hc).map_bddBelow hs
#align bdd_below.smul_of_nonpos BddBelow.smul_of_nonpos
-/

#print BddAbove.smul_of_nonpos /-
theorem BddAbove.smul_of_nonpos (hc : c ≤ 0) (hs : BddAbove s) : BddBelow (c • s) :=
  (antitone_smul_left hc).map_bddAbove hs
#align bdd_above.smul_of_nonpos BddAbove.smul_of_nonpos
-/

end OrderedRing

section LinearOrderedField

variable [LinearOrderedField k] [OrderedAddCommGroup M] [Module k M] [OrderedSMul k M] {s : Set M}
  {c : k}

#print lowerBounds_smul_of_neg /-
@[simp]
theorem lowerBounds_smul_of_neg (hc : c < 0) : lowerBounds (c • s) = c • upperBounds s :=
  (OrderIso.smulLeftDual M hc).upperBounds_image
#align lower_bounds_smul_of_neg lowerBounds_smul_of_neg
-/

#print upperBounds_smul_of_neg /-
@[simp]
theorem upperBounds_smul_of_neg (hc : c < 0) : upperBounds (c • s) = c • lowerBounds s :=
  (OrderIso.smulLeftDual M hc).lowerBounds_image
#align upper_bounds_smul_of_neg upperBounds_smul_of_neg
-/

#print bddBelow_smul_iff_of_neg /-
@[simp]
theorem bddBelow_smul_iff_of_neg (hc : c < 0) : BddBelow (c • s) ↔ BddAbove s :=
  (OrderIso.smulLeftDual M hc).bddAbove_image
#align bdd_below_smul_iff_of_neg bddBelow_smul_iff_of_neg
-/

#print bddAbove_smul_iff_of_neg /-
@[simp]
theorem bddAbove_smul_iff_of_neg (hc : c < 0) : BddAbove (c • s) ↔ BddBelow s :=
  (OrderIso.smulLeftDual M hc).bddBelow_image
#align bdd_above_smul_iff_of_neg bddAbove_smul_iff_of_neg
-/

end LinearOrderedField

