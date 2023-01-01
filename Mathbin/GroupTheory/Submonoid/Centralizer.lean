/-
Copyright (c) 2021 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning

! This file was ported from Lean 3 source module group_theory.submonoid.centralizer
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subsemigroup.Centralizer
import Mathbin.GroupTheory.Submonoid.Center

/-!
# Centralizers of magmas and monoids

## Main definitions

* `submonoid.centralizer`: the centralizer of a subset of a monoid
* `add_submonoid.centralizer`: the centralizer of a subset of an additive monoid

We provide `subgroup.centralizer`, `add_subgroup.centralizer` in other files.
-/


variable {M : Type _} {S T : Set M}

namespace Submonoid

section

variable [Monoid M] (S)

/-- The centralizer of a subset of a monoid `M`. -/
@[to_additive "The centralizer of a subset of an additive monoid."]
def centralizer : Submonoid M where
  carrier := S.centralizer
  one_mem' := S.one_mem_centralizer
  mul_mem' a b := Set.mul_mem_centralizer
#align submonoid.centralizer Submonoid.centralizer

@[simp, norm_cast, to_additive]
theorem coe_centralizer : ↑(centralizer S) = S.centralizer :=
  rfl
#align submonoid.coe_centralizer Submonoid.coe_centralizer

theorem centralizer_to_subsemigroup : (centralizer S).toSubsemigroup = Subsemigroup.centralizer S :=
  rfl
#align submonoid.centralizer_to_subsemigroup Submonoid.centralizer_to_subsemigroup

theorem AddSubmonoid.centralizer_to_add_subsemigroup {M} [AddMonoid M] (S : Set M) :
    (AddSubmonoid.centralizer S).toAddSubsemigroup = AddSubsemigroup.centralizer S :=
  rfl
#align add_submonoid.centralizer_to_add_subsemigroup AddSubmonoid.centralizer_to_add_subsemigroup

attribute [to_additive AddSubmonoid.centralizer_to_add_subsemigroup]
  Submonoid.centralizer_to_subsemigroup

variable {S}

@[to_additive]
theorem mem_centralizer_iff {z : M} : z ∈ centralizer S ↔ ∀ g ∈ S, g * z = z * g :=
  Iff.rfl
#align submonoid.mem_centralizer_iff Submonoid.mem_centralizer_iff

@[to_additive]
instance decidableMemCentralizer (a) [Decidable <| ∀ b ∈ S, b * a = a * b] :
    Decidable (a ∈ centralizer S) :=
  decidable_of_iff' _ mem_centralizer_iff
#align submonoid.decidable_mem_centralizer Submonoid.decidableMemCentralizer

@[to_additive]
theorem centralizer_le (h : S ⊆ T) : centralizer T ≤ centralizer S :=
  Set.centralizer_subset h
#align submonoid.centralizer_le Submonoid.centralizer_le

variable (M)

@[simp, to_additive]
theorem centralizer_univ : centralizer Set.univ = center M :=
  SetLike.ext' (Set.centralizer_univ M)
#align submonoid.centralizer_univ Submonoid.centralizer_univ

end

end Submonoid

-- Guard against import creep
assert_not_exists finset

