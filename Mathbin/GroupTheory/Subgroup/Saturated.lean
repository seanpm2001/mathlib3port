/-
Copyright (c) 2021 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module group_theory.subgroup.saturated
! leanprover-community/mathlib commit fac369018417f980cec5fcdafc766a69f88d8cfe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subgroup.Basic

/-!
# Saturated subgroups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Tags
subgroup, subgroups

-/


namespace Subgroup

variable {G : Type _} [Group G]

#print Subgroup.Saturated /-
/-- A subgroup `H` of `G` is *saturated* if for all `n : ℕ` and `g : G` with `g^n ∈ H`
we have `n = 0` or `g ∈ H`. -/
@[to_additive
      "An additive subgroup `H` of `G` is *saturated* if\nfor all `n : ℕ` and `g : G` with `n•g ∈ H` we have `n = 0` or `g ∈ H`."]
def Saturated (H : Subgroup G) : Prop :=
  ∀ ⦃n g⦄, g ^ n ∈ H → n = 0 ∨ g ∈ H
#align subgroup.saturated Subgroup.Saturated
#align add_subgroup.saturated AddSubgroup.Saturated
-/

#print Subgroup.saturated_iff_npow /-
@[to_additive]
theorem saturated_iff_npow {H : Subgroup G} :
    Saturated H ↔ ∀ (n : ℕ) (g : G), g ^ n ∈ H → n = 0 ∨ g ∈ H :=
  Iff.rfl
#align subgroup.saturated_iff_npow Subgroup.saturated_iff_npow
#align add_subgroup.saturated_iff_nsmul AddSubgroup.saturated_iff_nsmul
-/

#print Subgroup.saturated_iff_zpow /-
@[to_additive]
theorem saturated_iff_zpow {H : Subgroup G} :
    Saturated H ↔ ∀ (n : ℤ) (g : G), g ^ n ∈ H → n = 0 ∨ g ∈ H :=
  by
  constructor
  · rintro hH ⟨n⟩ g hgn
    · simp only [Int.coe_nat_eq_zero, Int.ofNat_eq_coe, zpow_ofNat] at hgn ⊢
      exact hH hgn
    · suffices g ^ (n + 1) ∈ H by refine' (hH this).imp _ id;
        simp only [IsEmpty.forall_iff, Nat.succ_ne_zero]
      simpa only [inv_mem_iff, zpow_negSucc] using hgn
  · intro h n g hgn
    specialize h n g
    simp only [Int.coe_nat_eq_zero, zpow_ofNat] at h 
    apply h hgn
#align subgroup.saturated_iff_zpow Subgroup.saturated_iff_zpow
#align add_subgroup.saturated_iff_zsmul AddSubgroup.saturated_iff_zsmul
-/

end Subgroup

namespace AddSubgroup

#print AddSubgroup.ker_saturated /-
theorem ker_saturated {A₁ A₂ : Type _} [AddCommGroup A₁] [AddCommGroup A₂] [NoZeroSMulDivisors ℕ A₂]
    (f : A₁ →+ A₂) : f.ker.Saturated := by
  intro n g hg
  simpa only [f.mem_ker, nsmul_eq_smul, f.map_nsmul, smul_eq_zero] using hg
#align add_subgroup.ker_saturated AddSubgroup.ker_saturated
-/

end AddSubgroup

