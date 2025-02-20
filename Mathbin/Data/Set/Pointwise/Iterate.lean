/-
Copyright (c) 2022 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module data.set.pointwise.iterate
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Pointwise.Smul
import Mathbin.Algebra.Hom.Iterate
import Mathbin.Dynamics.FixedPoints.Basic

/-!
# Results about pointwise operations on sets with iteration.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


open scoped Pointwise

open Set Function

#print smul_eq_self_of_preimage_zpow_eq_self /-
/-- Let `n : ℤ` and `s` a subset of a commutative group `G` that is invariant under preimage for
the map `x ↦ x^n`. Then `s` is invariant under the pointwise action of the subgroup of elements
`g : G` such that `g^(n^j) = 1` for some `j : ℕ`. (This subgroup is called the Prüfer subgroup when
 `G` is the `circle` and `n` is prime.) -/
@[to_additive
      "Let `n : ℤ` and `s` a subset of an additive commutative group `G` that is invariant\nunder preimage for the map `x ↦ n • x`. Then `s` is invariant under the pointwise action of the\nadditive subgroup of elements `g : G` such that `(n^j) • g = 0` for some `j : ℕ`. (This additive\nsubgroup is called the Prüfer subgroup when `G` is the `add_circle` and `n` is prime.)"]
theorem smul_eq_self_of_preimage_zpow_eq_self {G : Type _} [CommGroup G] {n : ℤ} {s : Set G}
    (hs : (fun x => x ^ n) ⁻¹' s = s) {g : G} {j : ℕ} (hg : g ^ n ^ j = 1) : g • s = s :=
  by
  suffices ∀ {g' : G} (hg' : g' ^ n ^ j = 1), g' • s ⊆ s
    by
    refine' le_antisymm (this hg) _
    conv_lhs => rw [← smul_inv_smul g s]
    replace hg : g⁻¹ ^ n ^ j = 1; · rw [inv_zpow, hg, inv_one]
    simpa only [le_eq_subset, set_smul_subset_set_smul_iff] using this hg
  rw [(is_fixed_pt.preimage_iterate hs j : zpowGroupHom n^[j] ⁻¹' s = s).symm]
  rintro g' hg' - ⟨y, hy, rfl⟩
  change (zpowGroupHom n^[j]) (g' * y) ∈ s
  replace hg' : (zpowGroupHom n^[j]) g' = 1; · simpa [zpowGroupHom]
  rwa [MonoidHom.iterate_map_mul, hg', one_mul]
#align smul_eq_self_of_preimage_zpow_eq_self smul_eq_self_of_preimage_zpow_eq_self
#align vadd_eq_self_of_preimage_zsmul_eq_self vadd_eq_self_of_preimage_zsmul_eq_self
-/

