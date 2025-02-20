/-
Copyright (c) 2021 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning

! This file was ported from Lean 3 source module group_theory.submonoid.centralizer
! leanprover-community/mathlib commit cc67cd75b4e54191e13c2e8d722289a89e67e4fa
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subsemigroup.Centralizer
import Mathbin.GroupTheory.Submonoid.Center

/-!
# Centralizers of magmas and monoids

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `submonoid.centralizer`: the centralizer of a subset of a monoid
* `add_submonoid.centralizer`: the centralizer of a subset of an additive monoid

We provide `subgroup.centralizer`, `add_subgroup.centralizer` in other files.
-/


variable {M : Type _} {S T : Set M}

namespace Submonoid

section

variable [Monoid M] (S)

#print Submonoid.centralizer /-
/-- The centralizer of a subset of a monoid `M`. -/
@[to_additive "The centralizer of a subset of an additive monoid."]
def centralizer : Submonoid M where
  carrier := S.centralizer
  one_mem' := S.one_mem_centralizer
  mul_mem' a b := Set.mul_mem_centralizer
#align submonoid.centralizer Submonoid.centralizer
#align add_submonoid.centralizer AddSubmonoid.centralizer
-/

#print Submonoid.coe_centralizer /-
@[simp, norm_cast, to_additive]
theorem coe_centralizer : ↑(centralizer S) = S.centralizer :=
  rfl
#align submonoid.coe_centralizer Submonoid.coe_centralizer
#align add_submonoid.coe_centralizer AddSubmonoid.coe_centralizer
-/

#print Submonoid.centralizer_toSubsemigroup /-
theorem centralizer_toSubsemigroup : (centralizer S).toSubsemigroup = Subsemigroup.centralizer S :=
  rfl
#align submonoid.centralizer_to_subsemigroup Submonoid.centralizer_toSubsemigroup
-/

#print AddSubmonoid.centralizer_toAddSubsemigroup /-
theorem AddSubmonoid.centralizer_toAddSubsemigroup {M} [AddMonoid M] (S : Set M) :
    (AddSubmonoid.centralizer S).toAddSubsemigroup = AddSubsemigroup.centralizer S :=
  rfl
#align add_submonoid.centralizer_to_add_subsemigroup AddSubmonoid.centralizer_toAddSubsemigroup
-/

attribute [to_additive AddSubmonoid.centralizer_toAddSubsemigroup]
  Submonoid.centralizer_toSubsemigroup

variable {S}

#print Submonoid.mem_centralizer_iff /-
@[to_additive]
theorem mem_centralizer_iff {z : M} : z ∈ centralizer S ↔ ∀ g ∈ S, g * z = z * g :=
  Iff.rfl
#align submonoid.mem_centralizer_iff Submonoid.mem_centralizer_iff
#align add_submonoid.mem_centralizer_iff AddSubmonoid.mem_centralizer_iff
-/

#print Submonoid.center_le_centralizer /-
@[to_additive]
theorem center_le_centralizer (s) : center M ≤ centralizer s :=
  s.center_subset_centralizer
#align submonoid.center_le_centralizer Submonoid.center_le_centralizer
#align add_submonoid.center_le_centralizer AddSubmonoid.center_le_centralizer
-/

#print Submonoid.decidableMemCentralizer /-
@[to_additive]
instance decidableMemCentralizer (a) [Decidable <| ∀ b ∈ S, b * a = a * b] :
    Decidable (a ∈ centralizer S) :=
  decidable_of_iff' _ mem_centralizer_iff
#align submonoid.decidable_mem_centralizer Submonoid.decidableMemCentralizer
#align add_submonoid.decidable_mem_centralizer AddSubmonoid.decidableMemCentralizer
-/

#print Submonoid.centralizer_le /-
@[to_additive]
theorem centralizer_le (h : S ⊆ T) : centralizer T ≤ centralizer S :=
  Set.centralizer_subset h
#align submonoid.centralizer_le Submonoid.centralizer_le
#align add_submonoid.centralizer_le AddSubmonoid.centralizer_le
-/

#print Submonoid.centralizer_eq_top_iff_subset /-
@[simp, to_additive]
theorem centralizer_eq_top_iff_subset {s : Set M} : centralizer s = ⊤ ↔ s ⊆ center M :=
  SetLike.ext'_iff.trans Set.centralizer_eq_top_iff_subset
#align submonoid.centralizer_eq_top_iff_subset Submonoid.centralizer_eq_top_iff_subset
#align add_submonoid.centralizer_eq_top_iff_subset AddSubmonoid.centralizer_eq_top_iff_subset
-/

variable (M)

#print Submonoid.centralizer_univ /-
@[simp, to_additive]
theorem centralizer_univ : centralizer Set.univ = center M :=
  SetLike.ext' (Set.centralizer_univ M)
#align submonoid.centralizer_univ Submonoid.centralizer_univ
#align add_submonoid.centralizer_univ AddSubmonoid.centralizer_univ
-/

end

end Submonoid

-- Guard against import creep
assert_not_exists Finset

