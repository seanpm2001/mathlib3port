/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module ring_theory.integrally_closed
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.IntegralClosure
import Mathbin.RingTheory.Localization.Integral

/-!
# Integrally closed rings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

An integrally closed domain `R` contains all the elements of `Frac(R)` that are
integral over `R`. A special case of integrally closed domains are the Dedekind domains.

## Main definitions

* `is_integrally_closed R` states `R` contains all integral elements of `Frac(R)`

## Main results

* `is_integrally_closed_iff K`, where `K` is a fraction field of `R`, states `R`
  is integrally closed iff it is the integral closure of `R` in `K`
-/


open scoped nonZeroDivisors Polynomial

open Polynomial

#print IsIntegrallyClosed /-
/-- `R` is integrally closed if all integral elements of `Frac(R)` are also elements of `R`.

This definition uses `fraction_ring R` to denote `Frac(R)`. See `is_integrally_closed_iff`
if you want to choose another field of fractions for `R`.
-/
class IsIntegrallyClosed (R : Type _) [CommRing R] [IsDomain R] : Prop where
  algebraMap_eq_of_integral :
    ∀ {x : FractionRing R}, IsIntegral R x → ∃ y, algebraMap R (FractionRing R) y = x
#align is_integrally_closed IsIntegrallyClosed
-/

section Iff

variable {R : Type _} [CommRing R] [IsDomain R]

variable (K : Type _) [Field K] [Algebra R K] [IsFractionRing R K]

#print isIntegrallyClosed_iff /-
/-- `R` is integrally closed iff all integral elements of its fraction field `K`
are also elements of `R`. -/
theorem isIntegrallyClosed_iff :
    IsIntegrallyClosed R ↔ ∀ {x : K}, IsIntegral R x → ∃ y, algebraMap R K y = x :=
  by
  let e : K ≃ₐ[R] FractionRing R := IsLocalization.algEquiv R⁰ _ _
  constructor
  · rintro ⟨cl⟩
    refine' fun x hx => _
    obtain ⟨y, hy⟩ := cl ((isIntegral_algEquiv e).mpr hx)
    exact ⟨y, e.algebra_map_eq_apply.mp hy⟩
  · rintro cl
    refine' ⟨fun x hx => _⟩
    obtain ⟨y, hy⟩ := cl ((isIntegral_algEquiv e.symm).mpr hx)
    exact ⟨y, e.symm.algebra_map_eq_apply.mp hy⟩
#align is_integrally_closed_iff isIntegrallyClosed_iff
-/

#print isIntegrallyClosed_iff_isIntegralClosure /-
/-- `R` is integrally closed iff it is the integral closure of itself in its field of fractions. -/
theorem isIntegrallyClosed_iff_isIntegralClosure : IsIntegrallyClosed R ↔ IsIntegralClosure R R K :=
  (isIntegrallyClosed_iff K).trans <|
    by
    let e : K ≃ₐ[R] FractionRing R := IsLocalization.algEquiv R⁰ _ _
    constructor
    · intro cl
      refine' ⟨IsFractionRing.injective _ _, fun x => ⟨cl, _⟩⟩
      rintro ⟨y, y_eq⟩
      rw [← y_eq]
      exact isIntegral_algebraMap
    · rintro ⟨-, cl⟩ x hx
      exact cl.mp hx
#align is_integrally_closed_iff_is_integral_closure isIntegrallyClosed_iff_isIntegralClosure
-/

end Iff

namespace IsIntegrallyClosed

variable {R : Type _} [CommRing R] [id : IsDomain R] [iic : IsIntegrallyClosed R]

variable {K : Type _} [Field K] [Algebra R K] [ifr : IsFractionRing R K]

instance : IsIntegralClosure R R K :=
  (isIntegrallyClosed_iff_isIntegralClosure K).mp iic

#print IsIntegrallyClosed.isIntegral_iff /-
theorem isIntegral_iff {x : K} : IsIntegral R x ↔ ∃ y : R, algebraMap R K y = x :=
  IsIntegralClosure.isIntegral_iff
#align is_integrally_closed.is_integral_iff IsIntegrallyClosed.isIntegral_iff
-/

#print IsIntegrallyClosed.exists_algebraMap_eq_of_isIntegral_pow /-
theorem exists_algebraMap_eq_of_isIntegral_pow {x : K} {n : ℕ} (hn : 0 < n)
    (hx : IsIntegral R <| x ^ n) : ∃ y : R, algebraMap R K y = x :=
  isIntegral_iff.mp <| isIntegral_of_pow hn hx
#align is_integrally_closed.exists_algebra_map_eq_of_is_integral_pow IsIntegrallyClosed.exists_algebraMap_eq_of_isIntegral_pow
-/

#print IsIntegrallyClosed.exists_algebraMap_eq_of_pow_mem_subalgebra /-
theorem exists_algebraMap_eq_of_pow_mem_subalgebra {K : Type _} [Field K] [Algebra R K]
    {S : Subalgebra R K} [IsIntegrallyClosed S] [IsFractionRing S K] {x : K} {n : ℕ} (hn : 0 < n)
    (hx : x ^ n ∈ S) : ∃ y : S, algebraMap S K y = x :=
  exists_algebraMap_eq_of_isIntegral_pow hn <| isIntegral_iff.mpr ⟨⟨x ^ n, hx⟩, rfl⟩
#align is_integrally_closed.exists_algebra_map_eq_of_pow_mem_subalgebra IsIntegrallyClosed.exists_algebraMap_eq_of_pow_mem_subalgebra
-/

variable {R} (K)

#print IsIntegrallyClosed.integralClosure_eq_bot_iff /-
theorem integralClosure_eq_bot_iff : integralClosure R K = ⊥ ↔ IsIntegrallyClosed R :=
  by
  refine' eq_bot_iff.trans _
  constructor
  · rw [isIntegrallyClosed_iff K]
    intro h x hx
    exact set.mem_range.mp (algebra.mem_bot.mp (h hx))
    assumption
  · intro h x hx
    rw [Algebra.mem_bot, Set.mem_range]
    exact is_integral_iff.mp hx
#align is_integrally_closed.integral_closure_eq_bot_iff IsIntegrallyClosed.integralClosure_eq_bot_iff
-/

variable (R K)

#print IsIntegrallyClosed.integralClosure_eq_bot /-
@[simp]
theorem integralClosure_eq_bot : integralClosure R K = ⊥ :=
  (integralClosure_eq_bot_iff K).mpr ‹_›
#align is_integrally_closed.integral_closure_eq_bot IsIntegrallyClosed.integralClosure_eq_bot
-/

end IsIntegrallyClosed

namespace integralClosure

open IsIntegrallyClosed

variable {R : Type _} [CommRing R]

variable (K : Type _) [Field K] [Algebra R K]

variable [IsDomain R] [IsFractionRing R K]

variable {L : Type _} [Field L] [Algebra K L] [Algebra R L] [IsScalarTower R K L]

#print integralClosure.isIntegrallyClosedOfFiniteExtension /-
-- Can't be an instance because you need to supply `K`.
theorem isIntegrallyClosedOfFiniteExtension [FiniteDimensional K L] :
    IsIntegrallyClosed (integralClosure R L) :=
  letI : IsFractionRing (integralClosure R L) L := is_fraction_ring_of_finite_extension K L
  (integral_closure_eq_bot_iff L).mp integralClosure_idem
#align integral_closure.is_integrally_closed_of_finite_extension integralClosure.isIntegrallyClosedOfFiniteExtension
-/

end integralClosure

