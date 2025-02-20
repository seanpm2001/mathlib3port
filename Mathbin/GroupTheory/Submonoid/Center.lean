/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module group_theory.submonoid.center
! leanprover-community/mathlib commit baba818b9acea366489e8ba32d2cc0fcaf50a1f7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Submonoid.Operations
import Mathbin.GroupTheory.Subsemigroup.Center

/-!
# Centers of monoids

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `submonoid.center`: the center of a monoid
* `add_submonoid.center`: the center of an additive monoid

We provide `subgroup.center`, `add_subgroup.center`, `subsemiring.center`, and `subring.center` in
other files.
-/


namespace Submonoid

section

variable (M : Type _) [Monoid M]

#print Submonoid.center /-
/-- The center of a monoid `M` is the set of elements that commute with everything in `M` -/
@[to_additive
      "The center of a monoid `M` is the set of elements that commute with everything in\n`M`"]
def center : Submonoid M where
  carrier := Set.center M
  one_mem' := Set.one_mem_center M
  mul_mem' a b := Set.mul_mem_center
#align submonoid.center Submonoid.center
#align add_submonoid.center AddSubmonoid.center
-/

#print Submonoid.coe_center /-
@[to_additive]
theorem coe_center : ↑(center M) = Set.center M :=
  rfl
#align submonoid.coe_center Submonoid.coe_center
#align add_submonoid.coe_center AddSubmonoid.coe_center
-/

#print Submonoid.center_toSubsemigroup /-
@[simp]
theorem center_toSubsemigroup : (center M).toSubsemigroup = Subsemigroup.center M :=
  rfl
#align submonoid.center_to_subsemigroup Submonoid.center_toSubsemigroup
-/

#print AddSubmonoid.center_toAddSubsemigroup /-
theorem AddSubmonoid.center_toAddSubsemigroup (M) [AddMonoid M] :
    (AddSubmonoid.center M).toAddSubsemigroup = AddSubsemigroup.center M :=
  rfl
#align add_submonoid.center_to_add_subsemigroup AddSubmonoid.center_toAddSubsemigroup
-/

attribute [to_additive AddSubmonoid.center_toAddSubsemigroup] Submonoid.center_toSubsemigroup

variable {M}

#print Submonoid.mem_center_iff /-
@[to_additive]
theorem mem_center_iff {z : M} : z ∈ center M ↔ ∀ g, g * z = z * g :=
  Iff.rfl
#align submonoid.mem_center_iff Submonoid.mem_center_iff
#align add_submonoid.mem_center_iff AddSubmonoid.mem_center_iff
-/

#print Submonoid.decidableMemCenter /-
@[to_additive]
instance decidableMemCenter (a) [Decidable <| ∀ b : M, b * a = a * b] : Decidable (a ∈ center M) :=
  decidable_of_iff' _ mem_center_iff
#align submonoid.decidable_mem_center Submonoid.decidableMemCenter
#align add_submonoid.decidable_mem_center AddSubmonoid.decidableMemCenter
-/

/-- The center of a monoid is commutative. -/
instance : CommMonoid (center M) :=
  { (center M).toMonoid with mul_comm := fun a b => Subtype.ext <| b.Prop _ }

#print Submonoid.center.smulCommClass_left /-
/-- The center of a monoid acts commutatively on that monoid. -/
instance center.smulCommClass_left : SMulCommClass (center M) M M
    where smul_comm m x y := (Commute.left_comm (m.Prop x) y).symm
#align submonoid.center.smul_comm_class_left Submonoid.center.smulCommClass_left
-/

#print Submonoid.center.smulCommClass_right /-
/-- The center of a monoid acts commutatively on that monoid. -/
instance center.smulCommClass_right : SMulCommClass M (center M) M :=
  SMulCommClass.symm _ _ _
#align submonoid.center.smul_comm_class_right Submonoid.center.smulCommClass_right
-/

/-! Note that `smul_comm_class (center M) (center M) M` is already implied by
`submonoid.smul_comm_class_right` -/


example : SMulCommClass (center M) (center M) M := by infer_instance

end

section

variable (M : Type _) [CommMonoid M]

#print Submonoid.center_eq_top /-
@[simp]
theorem center_eq_top : center M = ⊤ :=
  SetLike.coe_injective (Set.center_eq_univ M)
#align submonoid.center_eq_top Submonoid.center_eq_top
-/

end

end Submonoid

-- Guard against import creep
assert_not_exists Finset

