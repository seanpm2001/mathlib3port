/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.cartan_subalgebra
! leanprover-community/mathlib commit fd4551cfe4b7484b81c2c9ba3405edae27659676
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.Nilpotent
import Mathbin.Algebra.Lie.Normalizer

/-!
# Cartan subalgebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Cartan subalgebras are one of the most important concepts in Lie theory. We define them here.
The standard example is the set of diagonal matrices in the Lie algebra of matrices.

## Main definitions

  * `lie_submodule.is_ucs_limit`
  * `lie_subalgebra.is_cartan_subalgebra`
  * `lie_subalgebra.is_cartan_subalgebra_iff_is_ucs_limit`

## Tags

lie subalgebra, normalizer, idealizer, cartan subalgebra
-/


universe u v w w₁ w₂

variable {R : Type u} {L : Type v}

variable [CommRing R] [LieRing L] [LieAlgebra R L] (H : LieSubalgebra R L)

#print LieSubmodule.IsUcsLimit /-
/-- Given a Lie module `M` of a Lie algebra `L`, `lie_submodule.is_ucs_limit` is the proposition
that a Lie submodule `N ⊆ M` is the limiting value for the upper central series.

This is a characteristic property of Cartan subalgebras with the roles of `L`, `M`, `N` played by
`H`, `L`, `H`, respectively. See `lie_subalgebra.is_cartan_subalgebra_iff_is_ucs_limit`. -/
def LieSubmodule.IsUcsLimit {M : Type _} [AddCommGroup M] [Module R M] [LieRingModule L M]
    [LieModule R L M] (N : LieSubmodule R L M) : Prop :=
  ∃ k, ∀ l, k ≤ l → (⊥ : LieSubmodule R L M).ucs l = N
#align lie_submodule.is_ucs_limit LieSubmodule.IsUcsLimit
-/

namespace LieSubalgebra

#print LieSubalgebra.IsCartanSubalgebra /-
/-- A Cartan subalgebra is a nilpotent, self-normalizing subalgebra. -/
class IsCartanSubalgebra : Prop where
  nilpotent : LieAlgebra.IsNilpotent R H
  self_normalizing : H.normalizer = H
#align lie_subalgebra.is_cartan_subalgebra LieSubalgebra.IsCartanSubalgebra
-/

instance [H.IsCartanSubalgebra] : LieAlgebra.IsNilpotent R H :=
  IsCartanSubalgebra.nilpotent

#print LieSubalgebra.normalizer_eq_self_of_isCartanSubalgebra /-
@[simp]
theorem normalizer_eq_self_of_isCartanSubalgebra (H : LieSubalgebra R L) [H.IsCartanSubalgebra] :
    H.toLieSubmodule.normalizer = H.toLieSubmodule := by
  rw [← LieSubmodule.coe_toSubmodule_eq_iff, coe_normalizer_eq_normalizer,
    is_cartan_subalgebra.self_normalizing, coe_to_lie_submodule]
#align lie_subalgebra.normalizer_eq_self_of_is_cartan_subalgebra LieSubalgebra.normalizer_eq_self_of_isCartanSubalgebra
-/

#print LieSubalgebra.ucs_eq_self_of_isCartanSubalgebra /-
@[simp]
theorem ucs_eq_self_of_isCartanSubalgebra (H : LieSubalgebra R L) [H.IsCartanSubalgebra] (k : ℕ) :
    H.toLieSubmodule.ucs k = H.toLieSubmodule :=
  by
  induction' k with k ih
  · simp
  · simp [ih]
#align lie_subalgebra.ucs_eq_self_of_is_cartan_subalgebra LieSubalgebra.ucs_eq_self_of_isCartanSubalgebra
-/

#print LieSubalgebra.isCartanSubalgebra_iff_isUcsLimit /-
theorem isCartanSubalgebra_iff_isUcsLimit : H.IsCartanSubalgebra ↔ H.toLieSubmodule.IsUcsLimit :=
  by
  constructor
  · intro h
    have h₁ : _root_.lie_algebra.is_nilpotent R H := by infer_instance
    obtain ⟨k, hk⟩ := H.to_lie_submodule.is_nilpotent_iff_exists_self_le_ucs.mp h₁
    replace hk : H.to_lie_submodule = LieSubmodule.ucs k ⊥ :=
      le_antisymm hk
        (LieSubmodule.ucs_le_of_normalizer_eq_self H.normalizer_eq_self_of_is_cartan_subalgebra k)
    refine' ⟨k, fun l hl => _⟩
    rw [← Nat.sub_add_cancel hl, LieSubmodule.ucs_add, ← hk,
      LieSubalgebra.ucs_eq_self_of_isCartanSubalgebra]
  · rintro ⟨k, hk⟩
    exact
      { nilpotent := by
          dsimp only [LieAlgebra.IsNilpotent]
          erw [H.to_lie_submodule.is_nilpotent_iff_exists_lcs_eq_bot]
          use k
          rw [_root_.eq_bot_iff, LieSubmodule.lcs_le_iff, hk k (le_refl k)]
          exact le_refl _
        self_normalizing := by
          have hk' := hk (k + 1) k.le_succ
          rw [LieSubmodule.ucs_succ, hk k (le_refl k)] at hk' 
          rw [← LieSubalgebra.coe_to_submodule_eq_iff, ← LieSubalgebra.coe_normalizer_eq_normalizer,
            hk', LieSubalgebra.coe_toLieSubmodule] }
#align lie_subalgebra.is_cartan_subalgebra_iff_is_ucs_limit LieSubalgebra.isCartanSubalgebra_iff_isUcsLimit
-/

end LieSubalgebra

#print LieIdeal.normalizer_eq_top /-
@[simp]
theorem LieIdeal.normalizer_eq_top {R : Type u} {L : Type v} [CommRing R] [LieRing L]
    [LieAlgebra R L] (I : LieIdeal R L) : (I : LieSubalgebra R L).normalizer = ⊤ :=
  by
  ext x
  simpa only [LieSubalgebra.mem_normalizer_iff, LieSubalgebra.mem_top, iff_true_iff] using
    fun y hy => I.lie_mem hy
#align lie_ideal.normalizer_eq_top LieIdeal.normalizer_eq_top
-/

open LieIdeal

#print LieAlgebra.top_isCartanSubalgebra_of_nilpotent /-
/-- A nilpotent Lie algebra is its own Cartan subalgebra. -/
instance LieAlgebra.top_isCartanSubalgebra_of_nilpotent [LieAlgebra.IsNilpotent R L] :
    LieSubalgebra.IsCartanSubalgebra (⊤ : LieSubalgebra R L)
    where
  nilpotent := inferInstance
  self_normalizing := by rw [← top_coe_lie_subalgebra, normalizer_eq_top, top_coe_lie_subalgebra]
#align lie_algebra.top_is_cartan_subalgebra_of_nilpotent LieAlgebra.top_isCartanSubalgebra_of_nilpotent
-/

