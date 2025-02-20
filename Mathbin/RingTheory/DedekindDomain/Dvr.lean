/-
Copyright (c) 2020 Kenji Nakagawa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenji Nakagawa, Anne Baanen, Filippo A. E. Nuccio

! This file was ported from Lean 3 source module ring_theory.dedekind_domain.dvr
! leanprover-community/mathlib commit 6b31d1eebd64eab86d5bd9936bfaada6ca8b5842
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Localization.LocalizationLocalization
import Mathbin.RingTheory.Localization.Submodule
import Mathbin.RingTheory.DiscreteValuationRing.Tfae

/-!
# Dedekind domains

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines an equivalent notion of a Dedekind domain (or Dedekind ring),
namely a Noetherian integral domain where the localization at all nonzero prime ideals is a DVR
(TODO: and shows that implies the main definition).

## Main definitions

 - `is_dedekind_domain_dvr` alternatively defines a Dedekind domain as an integral domain that
   is Noetherian, and the localization at every nonzero prime ideal is a DVR.

## Main results
 - `is_localization.at_prime.discrete_valuation_ring_of_dedekind_domain` shows that
   `is_dedekind_domain` implies the localization at each nonzero prime ideal is a DVR.
 - `is_dedekind_domain.is_dedekind_domain_dvr` is one direction of the equivalence of definitions
   of a Dedekind domain

## Implementation notes

The definitions that involve a field of fractions choose a canonical field of fractions,
but are independent of that choice. The `..._iff` lemmas express this independence.

Often, definitions assume that Dedekind domains are not fields. We found it more practical
to add a `(h : ¬ is_field A)` assumption whenever this is explicitly needed.

## References

* [D. Marcus, *Number Fields*][marcus1977number]
* [J.W.S. Cassels, A. Frölich, *Algebraic Number Theory*][cassels1967algebraic]
* [J. Neukirch, *Algebraic Number Theory*][Neukirch1992]

## Tags

dedekind domain, dedekind ring
-/


variable (R A K : Type _) [CommRing R] [CommRing A] [IsDomain A] [Field K]

open scoped nonZeroDivisors Polynomial

#print IsDedekindDomainDvr /-
/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (P «expr ≠ » («expr⊥»() : ideal[ideal] A)) -/
/-- A Dedekind domain is an integral domain that is Noetherian, and the
localization at every nonzero prime is a discrete valuation ring.

This is equivalent to `is_dedekind_domain`.
TODO: prove the equivalence.
-/
structure IsDedekindDomainDvr : Prop where
  IsNoetherianRing : IsNoetherianRing A
  is_dvr_at_nonzero_prime :
    ∀ (P) (_ : P ≠ (⊥ : Ideal A)), P.IsPrime → DiscreteValuationRing (Localization.AtPrime P)
#align is_dedekind_domain_dvr IsDedekindDomainDvr
-/

#print Ring.DimensionLEOne.localization /-
/-- Localizing a domain of Krull dimension `≤ 1` gives another ring of Krull dimension `≤ 1`.

Note that the same proof can/should be generalized to preserving any Krull dimension,
once we have a suitable definition.
-/
theorem Ring.DimensionLEOne.localization {R : Type _} (Rₘ : Type _) [CommRing R] [IsDomain R]
    [CommRing Rₘ] [Algebra R Rₘ] {M : Submonoid R} [IsLocalization M Rₘ] (hM : M ≤ R⁰)
    (h : Ring.DimensionLEOne R) : Ring.DimensionLEOne Rₘ :=
  by
  intro p hp0 hpp
  refine' ideal.is_maximal_def.mpr ⟨hpp.ne_top, Ideal.maximal_of_no_maximal fun P hpP hPm => _⟩
  have hpP' : (⟨p, hpp⟩ : { p : Ideal Rₘ // p.IsPrime }) < ⟨P, hPm.is_prime⟩ := hpP
  rw [← (IsLocalization.orderIsoOfPrime M Rₘ).lt_iff_lt] at hpP' 
  haveI : Ideal.IsPrime (Ideal.comap (algebraMap R Rₘ) p) :=
    ((IsLocalization.orderIsoOfPrime M Rₘ) ⟨p, hpp⟩).2.1
  haveI : Ideal.IsPrime (Ideal.comap (algebraMap R Rₘ) P) :=
    ((IsLocalization.orderIsoOfPrime M Rₘ) ⟨P, hPm.is_prime⟩).2.1
  have hlt : Ideal.comap (algebraMap R Rₘ) p < Ideal.comap (algebraMap R Rₘ) P := hpP'
  refine' h.not_lt_lt ⊥ (Ideal.comap _ _) (Ideal.comap _ _) ⟨_, hpP'⟩
  exact IsLocalization.bot_lt_comap_prime _ _ hM _ hp0
#align ring.dimension_le_one.localization Ring.DimensionLEOne.localization
-/

#print IsLocalization.isDedekindDomain /-
/-- The localization of a Dedekind domain is a Dedekind domain. -/
theorem IsLocalization.isDedekindDomain [IsDedekindDomain A] {M : Submonoid A} (hM : M ≤ A⁰)
    (Aₘ : Type _) [CommRing Aₘ] [IsDomain Aₘ] [Algebra A Aₘ] [IsLocalization M Aₘ] :
    IsDedekindDomain Aₘ :=
  by
  have : ∀ y : M, IsUnit (algebraMap A (FractionRing A) y) :=
    by
    rintro ⟨y, hy⟩
    exact IsUnit.mk0 _ (mt is_fraction_ring.to_map_eq_zero_iff.mp (nonZeroDivisors.ne_zero (hM hy)))
  letI : Algebra Aₘ (FractionRing A) := RingHom.toAlgebra (IsLocalization.lift this)
  haveI : IsScalarTower A Aₘ (FractionRing A) :=
    IsScalarTower.of_algebraMap_eq fun x => (IsLocalization.lift_eq this x).symm
  haveI : IsFractionRing Aₘ (FractionRing A) :=
    IsFractionRing.isFractionRing_of_isDomain_of_isLocalization M _ _
  refine' (isDedekindDomain_iff _ (FractionRing A)).mpr ⟨_, _, _⟩
  · exact IsLocalization.isNoetherianRing M _ (by infer_instance)
  · exact is_dedekind_domain.dimension_le_one.localization Aₘ hM
  · intro x hx
    obtain ⟨⟨y, y_mem⟩, hy⟩ := hx.exists_multiple_integral_of_is_localization M _
    obtain ⟨z, hz⟩ := (isIntegrallyClosed_iff _).mp IsDedekindDomain.isIntegrallyClosed hy
    refine' ⟨IsLocalization.mk' Aₘ z ⟨y, y_mem⟩, (IsLocalization.lift_mk'_spec _ _ _ _).mpr _⟩
    rw [hz, SetLike.coe_mk, ← Algebra.smul_def]
    rfl
#align is_localization.is_dedekind_domain IsLocalization.isDedekindDomain
-/

#print IsLocalization.AtPrime.isDedekindDomain /-
/-- The localization of a Dedekind domain at every nonzero prime ideal is a Dedekind domain. -/
theorem IsLocalization.AtPrime.isDedekindDomain [IsDedekindDomain A] (P : Ideal A) [P.IsPrime]
    (Aₘ : Type _) [CommRing Aₘ] [IsDomain Aₘ] [Algebra A Aₘ] [IsLocalization.AtPrime Aₘ P] :
    IsDedekindDomain Aₘ :=
  IsLocalization.isDedekindDomain A P.primeCompl_le_nonZeroDivisors Aₘ
#align is_localization.at_prime.is_dedekind_domain IsLocalization.AtPrime.isDedekindDomain
-/

#print IsLocalization.AtPrime.not_isField /-
theorem IsLocalization.AtPrime.not_isField {P : Ideal A} (hP : P ≠ ⊥) [pP : P.IsPrime] (Aₘ : Type _)
    [CommRing Aₘ] [Algebra A Aₘ] [IsLocalization.AtPrime Aₘ P] : ¬IsField Aₘ :=
  by
  intro h
  letI := h.to_field
  obtain ⟨x, x_mem, x_ne⟩ := P.ne_bot_iff.mp hP
  exact
    (LocalRing.maximalIdeal.isMaximal _).ne_top
      (Ideal.eq_top_of_isUnit_mem _
        ((IsLocalization.AtPrime.to_map_mem_maximal_iff Aₘ P _).mpr x_mem)
        (is_unit_iff_ne_zero.mpr
          ((map_ne_zero_iff (algebraMap A Aₘ)
                (IsLocalization.injective Aₘ P.prime_compl_le_non_zero_divisors)).mpr
            x_ne)))
#align is_localization.at_prime.not_is_field IsLocalization.AtPrime.not_isField
-/

#print IsLocalization.AtPrime.discreteValuationRing_of_dedekind_domain /-
/-- In a Dedekind domain, the localization at every nonzero prime ideal is a DVR. -/
theorem IsLocalization.AtPrime.discreteValuationRing_of_dedekind_domain [IsDedekindDomain A]
    {P : Ideal A} (hP : P ≠ ⊥) [pP : P.IsPrime] (Aₘ : Type _) [CommRing Aₘ] [IsDomain Aₘ]
    [Algebra A Aₘ] [IsLocalization.AtPrime Aₘ P] : DiscreteValuationRing Aₘ := by
  classical
  letI : IsNoetherianRing Aₘ :=
    IsLocalization.isNoetherianRing P.prime_compl _ IsDedekindDomain.isNoetherianRing
  letI : LocalRing Aₘ := IsLocalization.AtPrime.localRing Aₘ P
  have hnf := IsLocalization.AtPrime.not_isField A hP Aₘ
  exact
    ((DiscreteValuationRing.TFAE Aₘ hnf).out 0 2).mpr
      (IsLocalization.AtPrime.isDedekindDomain A P _)
#align is_localization.at_prime.discrete_valuation_ring_of_dedekind_domain IsLocalization.AtPrime.discreteValuationRing_of_dedekind_domain
-/

#print IsDedekindDomain.isDedekindDomainDvr /-
/-- Dedekind domains, in the sense of Noetherian integrally closed domains of Krull dimension ≤ 1,
are also Dedekind domains in the sense of Noetherian domains where the localization at every
nonzero prime ideal is a DVR. -/
theorem IsDedekindDomain.isDedekindDomainDvr [IsDedekindDomain A] : IsDedekindDomainDvr A :=
  { IsNoetherianRing := IsDedekindDomain.isNoetherianRing
    is_dvr_at_nonzero_prime := fun P hP pP =>
      IsLocalization.AtPrime.discreteValuationRing_of_dedekind_domain A hP _ }
#align is_dedekind_domain.is_dedekind_domain_dvr IsDedekindDomain.isDedekindDomainDvr
-/

