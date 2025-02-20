/-
Copyright (c) 2022 Pierre-Alexandre Bazin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Pierre-Alexandre Bazin

! This file was ported from Lean 3 source module algebra.module.dedekind_domain
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Torsion
import Mathbin.RingTheory.DedekindDomain.Ideal

/-!
# Modules over a Dedekind domain

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Over a Dedekind domain, a `I`-torsion module is the internal direct sum of its `p i ^ e i`-torsion
submodules, where `I = ∏ i, p i ^ e i` is its unique decomposition in prime ideals.
Therefore, as any finitely generated torsion module is `I`-torsion for some `I`, it is an internal
direct sum of its `p i ^ e i`-torsion submodules for some prime ideals `p i` and numbers `e i`.
-/


universe u v

open scoped BigOperators

variable {R : Type u} [CommRing R] [IsDomain R] {M : Type v} [AddCommGroup M] [Module R M]

open scoped DirectSum

namespace Submodule

variable [IsDedekindDomain R]

open UniqueFactorizationMonoid

open scoped Classical

#print Submodule.isInternal_prime_power_torsion_of_is_torsion_by_ideal /-
/-- Over a Dedekind domain, a `I`-torsion module is the internal direct sum of its `p i ^ e i`-
torsion submodules, where `I = ∏ i, p i ^ e i` is its unique decomposition in prime ideals.-/
theorem isInternal_prime_power_torsion_of_is_torsion_by_ideal {I : Ideal R} (hI : I ≠ ⊥)
    (hM : Module.IsTorsionBySet R M I) :
    DirectSum.IsInternal fun p : (factors I).toFinset =>
      torsionBySet R M (p ^ (factors I).count p : Ideal R) :=
  by
  let P := factors I
  have prime_of_mem := fun p (hp : p ∈ P.to_finset) =>
    prime_of_factor p (multiset.mem_to_finset.mp hp)
  apply @torsion_by_set_is_internal _ _ _ _ _ _ _ _ (fun p => p ^ P.count p) _
  · convert hM
    rw [← Finset.inf_eq_iInf, IsDedekindDomain.inf_prime_pow_eq_prod, ← Finset.prod_multiset_count,
      ← associated_iff_eq]
    · exact factors_prod hI
    · exact prime_of_mem; · exact fun _ _ _ _ ij => ij
  · intro p hp q hq pq; dsimp
    rw [irreducible_pow_sup]
    · suffices (normalized_factors _).count p = 0 by rw [this, zero_min, pow_zero, Ideal.one_eq_top]
      · rw [Multiset.count_eq_zero,
          normalized_factors_of_irreducible_pow (prime_of_mem q hq).Irreducible,
          Multiset.mem_replicate]
        exact fun H => pq <| H.2.trans <| normalize_eq q
    · rw [← Ideal.zero_eq_bot]; apply pow_ne_zero; exact (prime_of_mem q hq).NeZero
    · exact (prime_of_mem p hp).Irreducible
#align submodule.is_internal_prime_power_torsion_of_is_torsion_by_ideal Submodule.isInternal_prime_power_torsion_of_is_torsion_by_ideal
-/

#print Submodule.isInternal_prime_power_torsion /-
/-- A finitely generated torsion module over a Dedekind domain is an internal direct sum of its
`p i ^ e i`-torsion submodules where `p i` are factors of `(⊤ : submodule R M).annihilator` and
`e i` are their multiplicities. -/
theorem isInternal_prime_power_torsion [Module.Finite R M] (hM : Module.IsTorsion R M) :
    DirectSum.IsInternal fun p : (factors (⊤ : Submodule R M).annihilator).toFinset =>
      torsionBySet R M (p ^ (factors (⊤ : Submodule R M).annihilator).count p : Ideal R) :=
  by
  have hM' := Module.isTorsionBySet_annihilator_top R M
  have hI := Submodule.annihilator_top_inter_nonZeroDivisors hM
  refine' is_internal_prime_power_torsion_of_is_torsion_by_ideal _ hM'
  rw [← Set.nonempty_iff_ne_empty] at hI ; rw [Submodule.ne_bot_iff]
  obtain ⟨x, H, hx⟩ := hI; exact ⟨x, H, nonZeroDivisors.ne_zero hx⟩
#align submodule.is_internal_prime_power_torsion Submodule.isInternal_prime_power_torsion
-/

#print Submodule.exists_isInternal_prime_power_torsion /-
/-- A finitely generated torsion module over a Dedekind domain is an internal direct sum of its
`p i ^ e i`-torsion submodules for some prime ideals `p i` and numbers `e i`.-/
theorem exists_isInternal_prime_power_torsion [Module.Finite R M] (hM : Module.IsTorsion R M) :
    ∃ (P : Finset <| Ideal R) (_ : DecidableEq P) (_ : ∀ p ∈ P, Prime p) (e : P → ℕ),
      DirectSum.IsInternal fun p : P => torsion_by_set R M (p ^ e p : Ideal R) :=
  ⟨_, _, fun p hp => prime_of_factor p (Multiset.mem_toFinset.mp hp), _,
    isInternal_prime_power_torsion hM⟩
#align submodule.exists_is_internal_prime_power_torsion Submodule.exists_isInternal_prime_power_torsion
-/

end Submodule

