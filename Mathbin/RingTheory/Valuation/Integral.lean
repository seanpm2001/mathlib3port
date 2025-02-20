/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module ring_theory.valuation.integral
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.IntegrallyClosed
import Mathbin.RingTheory.Valuation.Integers

/-!
# Integral elements over the ring of integers of a valution

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The ring of integers is integrally closed inside the original ring.
-/


universe u v w

open scoped BigOperators

namespace Valuation

namespace Integers

section CommRing

variable {R : Type u} {Γ₀ : Type v} [CommRing R] [LinearOrderedCommGroupWithZero Γ₀]

variable {v : Valuation R Γ₀} {O : Type w} [CommRing O] [Algebra O R] (hv : Integers v O)

open Polynomial

#print Valuation.Integers.mem_of_integral /-
theorem mem_of_integral {x : R} (hx : IsIntegral O x) : x ∈ v.integer :=
  let ⟨p, hpm, hpx⟩ := hx
  le_of_not_lt fun hvx : 1 < v x =>
    by
    rw [hpm.as_sum, eval₂_add, eval₂_pow, eval₂_X, eval₂_finset_sum, add_eq_zero_iff_eq_neg] at hpx 
    replace hpx := congr_arg v hpx; refine' ne_of_gt _ hpx
    rw [v.map_neg, v.map_pow]
    refine' v.map_sum_lt' (zero_lt_one.trans_le (one_le_pow_of_one_le' hvx.le _)) fun i hi => _
    rw [eval₂_mul, eval₂_pow, eval₂_C, eval₂_X, v.map_mul, v.map_pow, ←
      one_mul (v x ^ p.nat_degree)]
    cases' (hv.2 <| p.coeff i).lt_or_eq with hvpi hvpi
    · exact mul_lt_mul₀ hvpi (pow_lt_pow₀ hvx <| Finset.mem_range.1 hi)
    · erw [hvpi]; rw [one_mul, one_mul]; exact pow_lt_pow₀ hvx (Finset.mem_range.1 hi)
#align valuation.integers.mem_of_integral Valuation.Integers.mem_of_integral
-/

#print Valuation.Integers.integralClosure /-
protected theorem integralClosure : integralClosure O R = ⊥ :=
  bot_unique fun r hr =>
    let ⟨x, hx⟩ := hv.3 (hv.mem_of_integral hr)
    Algebra.mem_bot.2 ⟨x, hx⟩
#align valuation.integers.integral_closure Valuation.Integers.integralClosure
-/

end CommRing

section FractionField

variable {K : Type u} {Γ₀ : Type v} [Field K] [LinearOrderedCommGroupWithZero Γ₀]

variable {v : Valuation K Γ₀} {O : Type w} [CommRing O] [IsDomain O]

variable [Algebra O K] [IsFractionRing O K]

variable (hv : Integers v O)

#print Valuation.Integers.integrallyClosed /-
theorem integrallyClosed : IsIntegrallyClosed O :=
  (IsIntegrallyClosed.integralClosure_eq_bot_iff K).mp (Valuation.Integers.integralClosure hv)
#align valuation.integers.integrally_closed Valuation.Integers.integrallyClosed
-/

end FractionField

end Integers

end Valuation

