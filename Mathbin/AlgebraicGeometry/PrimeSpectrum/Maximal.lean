/-
Copyright (c) 2022 David Kurniadi Angdinata. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: David Kurniadi Angdinata

! This file was ported from Lean 3 source module algebraic_geometry.prime_spectrum.maximal
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.AlgebraicGeometry.PrimeSpectrum.Basic
import Mathbin.RingTheory.Localization.AsSubring

/-!
# Maximal spectrum of a commutative ring

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The maximal spectrum of a commutative ring is the type of all maximal ideals.
It is naturally a subset of the prime spectrum endowed with the subspace topology.

## Main definitions

* `maximal_spectrum R`: The maximal spectrum of a commutative ring `R`,
  i.e., the set of all maximal ideals of `R`.

## Implementation notes

The Zariski topology on the maximal spectrum is defined as the subspace topology induced by the
natural inclusion into the prime spectrum to avoid API duplication for zero loci.
-/


noncomputable section

open scoped Classical

universe u v

variable (R : Type u) [CommRing R]

#print MaximalSpectrum /-
/-- The maximal spectrum of a commutative ring `R` is the type of all maximal ideals of `R`. -/
@[ext]
structure MaximalSpectrum where
  asIdeal : Ideal R
  IsMaximal : as_ideal.IsMaximal
#align maximal_spectrum MaximalSpectrum
-/

attribute [instance] MaximalSpectrum.isMaximal

variable {R}

namespace MaximalSpectrum

instance [Nontrivial R] : Nonempty <| MaximalSpectrum R :=
  let ⟨I, hI⟩ := Ideal.exists_maximal R
  ⟨⟨I, hI⟩⟩

#print MaximalSpectrum.toPrimeSpectrum /-
/-- The natural inclusion from the maximal spectrum to the prime spectrum. -/
def toPrimeSpectrum (x : MaximalSpectrum R) : PrimeSpectrum R :=
  ⟨x.asIdeal, x.IsMaximal.IsPrime⟩
#align maximal_spectrum.to_prime_spectrum MaximalSpectrum.toPrimeSpectrum
-/

#print MaximalSpectrum.toPrimeSpectrum_injective /-
theorem toPrimeSpectrum_injective : (@toPrimeSpectrum R _).Injective := fun ⟨_, _⟩ ⟨_, _⟩ h => by
  simpa only [mk.inj_eq] using (PrimeSpectrum.ext_iff _ _).mp h
#align maximal_spectrum.to_prime_spectrum_injective MaximalSpectrum.toPrimeSpectrum_injective
-/

open PrimeSpectrum Set

#print MaximalSpectrum.toPrimeSpectrum_range /-
theorem toPrimeSpectrum_range :
    Set.range (@toPrimeSpectrum R _) = {x | IsClosed ({x} : Set <| PrimeSpectrum R)} :=
  by
  simp only [is_closed_singleton_iff_is_maximal]
  ext ⟨x, _⟩
  exact ⟨fun ⟨y, hy⟩ => hy ▸ y.IsMaximal, fun hx => ⟨⟨x, hx⟩, rfl⟩⟩
#align maximal_spectrum.to_prime_spectrum_range MaximalSpectrum.toPrimeSpectrum_range
-/

#print MaximalSpectrum.zariskiTopology /-
/-- The Zariski topology on the maximal spectrum of a commutative ring is defined as the subspace
topology induced by the natural inclusion into the prime spectrum. -/
instance zariskiTopology : TopologicalSpace <| MaximalSpectrum R :=
  PrimeSpectrum.zariskiTopology.induced toPrimeSpectrum
#align maximal_spectrum.zariski_topology MaximalSpectrum.zariskiTopology
-/

instance : T1Space <| MaximalSpectrum R :=
  ⟨fun x =>
    isClosed_induced_iff.mpr
      ⟨{toPrimeSpectrum x}, (isClosed_singleton_iff_isMaximal _).mpr x.IsMaximal, by
        simpa only [← image_singleton] using preimage_image_eq {x} to_prime_spectrum_injective⟩⟩

#print MaximalSpectrum.toPrimeSpectrum_continuous /-
theorem toPrimeSpectrum_continuous : Continuous <| @toPrimeSpectrum R _ :=
  continuous_induced_dom
#align maximal_spectrum.to_prime_spectrum_continuous MaximalSpectrum.toPrimeSpectrum_continuous
-/

variable (R) [IsDomain R] (K : Type v) [Field K] [Algebra R K] [IsFractionRing R K]

#print MaximalSpectrum.iInf_localization_eq_bot /-
/-- An integral domain is equal to the intersection of its localizations at all its maximal ideals
viewed as subalgebras of its field of fractions. -/
theorem iInf_localization_eq_bot :
    (⨅ v : MaximalSpectrum R,
        Localization.subalgebra.ofField K _ v.asIdeal.primeCompl_le_nonZeroDivisors) =
      ⊥ :=
  by
  ext x
  rw [Algebra.mem_bot, Algebra.mem_iInf]
  constructor
  · apply imp_of_not_imp_not
    intro hrange hlocal
    let denom : Ideal R := (Submodule.span R {1} : Submodule R K).colon (Submodule.span R {x})
    have hdenom : (1 : R) ∉ denom := by
      intro hdenom
      rcases submodule.mem_span_singleton.mp
          (submodule.mem_colon.mp hdenom x <| Submodule.mem_span_singleton_self x) with
        ⟨y, hy⟩
      exact hrange ⟨y, by rw [← mul_one <| algebraMap R K y, ← Algebra.smul_def, hy, one_smul]⟩
    rcases denom.exists_le_maximal fun h => (h ▸ hdenom) Submodule.mem_top with ⟨max, hmax, hle⟩
    rcases hlocal ⟨max, hmax⟩ with ⟨n, d, hd, rfl⟩
    apply hd (hle <| submodule.mem_colon.mpr fun _ hy => _)
    rcases submodule.mem_span_singleton.mp hy with ⟨y, rfl⟩
    exact
      submodule.mem_span_singleton.mpr
        ⟨y * n, by
          rw [Algebra.smul_def, mul_one, map_mul, smul_comm, Algebra.smul_def, Algebra.smul_def,
            mul_comm <| algebraMap R K d,
            inv_mul_cancel_right₀ <|
              (map_ne_zero_iff _ <| NoZeroSMulDivisors.algebraMap_injective R K).mpr fun h =>
                (h ▸ hd) max.zero_mem]⟩
  · rintro ⟨y, rfl⟩ ⟨v, hv⟩
    exact ⟨y, 1, v.ne_top_iff_one.mp hv.ne_top, by rw [map_one, inv_one, mul_one]⟩
#align maximal_spectrum.infi_localization_eq_bot MaximalSpectrum.iInf_localization_eq_bot
-/

end MaximalSpectrum

namespace PrimeSpectrum

variable (R) [IsDomain R] (K : Type v) [Field K] [Algebra R K] [IsFractionRing R K]

#print PrimeSpectrum.iInf_localization_eq_bot /-
/-- An integral domain is equal to the intersection of its localizations at all its prime ideals
viewed as subalgebras of its field of fractions. -/
theorem iInf_localization_eq_bot :
    (⨅ v : PrimeSpectrum R,
        Localization.subalgebra.ofField K _ <| v.asIdeal.primeCompl_le_nonZeroDivisors) =
      ⊥ :=
  by
  ext x
  rw [Algebra.mem_iInf]
  constructor
  · rw [← MaximalSpectrum.iInf_localization_eq_bot, Algebra.mem_iInf]
    exact fun hx ⟨v, hv⟩ => hx ⟨v, hv.IsPrime⟩
  · rw [Algebra.mem_bot]
    rintro ⟨y, rfl⟩ ⟨v, hv⟩
    exact ⟨y, 1, v.ne_top_iff_one.mp hv.ne_top, by rw [map_one, inv_one, mul_one]⟩
#align prime_spectrum.infi_localization_eq_bot PrimeSpectrum.iInf_localization_eq_bot
-/

end PrimeSpectrum

