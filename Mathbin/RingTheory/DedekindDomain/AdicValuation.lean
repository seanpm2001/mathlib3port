/-
Copyright (c) 2022 María Inés de Frutos-Fernández. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: María Inés de Frutos-Fernández

! This file was ported from Lean 3 source module ring_theory.dedekind_domain.adic_valuation
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.DedekindDomain.Ideal
import Mathbin.RingTheory.Valuation.ExtendToLocalization
import Mathbin.RingTheory.Valuation.ValuationSubring
import Mathbin.Topology.Algebra.ValuedField
import Mathbin.Algebra.Order.Group.TypeTags

/-!
# Adic valuations on Dedekind domains

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
Given a Dedekind domain `R` of Krull dimension 1 and a maximal ideal `v` of `R`, we define the
`v`-adic valuation on `R` and its extension to the field of fractions `K` of `R`.
We prove several properties of this valuation, including the existence of uniformizers.

We define the completion of `K` with respect to the `v`-adic valuation, denoted
`v.adic_completion`,and its ring of integers, denoted `v.adic_completion_integers`.

## Main definitions
 - `is_dedekind_domain.height_one_spectrum.int_valuation v` is the `v`-adic valuation on `R`.
 - `is_dedekind_domain.height_one_spectrum.valuation v` is the `v`-adic valuation on `K`.
 - `is_dedekind_domain.height_one_spectrum.adic_completion v` is the completion of `K` with respect
    to its `v`-adic valuation.
 - `is_dedekind_domain.height_one_spectrum.adic_completion_integers v` is the ring of integers of
    `v.adic_completion`.

## Main results
- `is_dedekind_domain.height_one_spectrum.int_valuation_le_one` : The `v`-adic valuation on `R` is
  bounded above by 1.
- `is_dedekind_domain.height_one_spectrum.int_valuation_lt_one_iff_dvd` : The `v`-adic valuation of
  `r ∈ R` is less than 1 if and only if `v` divides the ideal `(r)`.
- `is_dedekind_domain.height_one_spectrum.int_valuation_le_pow_iff_dvd` : The `v`-adic valuation of
  `r ∈ R` is less than or equal to `multiplicative.of_add (-n)` if and only if `vⁿ` divides the
  ideal `(r)`.
- `is_dedekind_domain.height_one_spectrum.int_valuation_exists_uniformizer` : There exists `π ∈ R`
  with `v`-adic valuation `multiplicative.of_add (-1)`.
- `is_dedekind_domain.height_one_spectrum.valuation_of_mk'` : The `v`-adic valuation of `r/s ∈ K`
  is the valuation of `r` divided by the valuation of `s`.
- `is_dedekind_domain.height_one_spectrum.valuation_of_algebra_map` : The `v`-adic valuation on `K`
  extends the `v`-adic valuation on `R`.
- `is_dedekind_domain.height_one_spectrum.valuation_exists_uniformizer` : There exists `π ∈ K` with
  `v`-adic valuation `multiplicative.of_add (-1)`.

## Implementation notes
We are only interested in Dedekind domains with Krull dimension 1.

## References
* [G. J. Janusz, *Algebraic Number Fields*][janusz1996]
* [J.W.S. Cassels, A. Frölich, *Algebraic Number Theory*][cassels1967algebraic]
* [J. Neukirch, *Algebraic Number Theory*][Neukirch1992]

## Tags
dedekind domain, dedekind ring, adic valuation
-/


noncomputable section

open scoped Classical DiscreteValuation

open Multiplicative IsDedekindDomain

variable {R : Type _} [CommRing R] [IsDomain R] [IsDedekindDomain R] {K : Type _} [Field K]
  [Algebra R K] [IsFractionRing R K] (v : HeightOneSpectrum R)

namespace IsDedekindDomain.HeightOneSpectrum

/-! ### Adic valuations on the Dedekind domain R -/


#print IsDedekindDomain.HeightOneSpectrum.intValuationDef /-
/-- The additive `v`-adic valuation of `r ∈ R` is the exponent of `v` in the factorization of the
ideal `(r)`, if `r` is nonzero, or infinity, if `r = 0`. `int_valuation_def` is the corresponding
multiplicative valuation. -/
def intValuationDef (r : R) : ℤₘ₀ :=
  if r = 0 then 0
  else
    Multiplicative.ofAdd
      (-(Associates.mk v.asIdeal).count (Associates.mk (Ideal.span {r} : Ideal R)).factors : ℤ)
#align is_dedekind_domain.height_one_spectrum.int_valuation_def IsDedekindDomain.HeightOneSpectrum.intValuationDef
-/

#print IsDedekindDomain.HeightOneSpectrum.intValuationDef_if_pos /-
theorem intValuationDef_if_pos {r : R} (hr : r = 0) : v.intValuationDef r = 0 :=
  if_pos hr
#align is_dedekind_domain.height_one_spectrum.int_valuation_def_if_pos IsDedekindDomain.HeightOneSpectrum.intValuationDef_if_pos
-/

#print IsDedekindDomain.HeightOneSpectrum.intValuationDef_if_neg /-
theorem intValuationDef_if_neg {r : R} (hr : r ≠ 0) :
    v.intValuationDef r =
      Multiplicative.ofAdd
        (-(Associates.mk v.asIdeal).count (Associates.mk (Ideal.span {r} : Ideal R)).factors : ℤ) :=
  if_neg hr
#align is_dedekind_domain.height_one_spectrum.int_valuation_def_if_neg IsDedekindDomain.HeightOneSpectrum.intValuationDef_if_neg
-/

#print IsDedekindDomain.HeightOneSpectrum.int_valuation_ne_zero /-
/-- Nonzero elements have nonzero adic valuation. -/
theorem int_valuation_ne_zero (x : R) (hx : x ≠ 0) : v.intValuationDef x ≠ 0 :=
  by
  rw [int_valuation_def, if_neg hx]
  exact WithZero.coe_ne_zero
#align is_dedekind_domain.height_one_spectrum.int_valuation_ne_zero IsDedekindDomain.HeightOneSpectrum.int_valuation_ne_zero
-/

#print IsDedekindDomain.HeightOneSpectrum.int_valuation_ne_zero' /-
/-- Nonzero divisors have nonzero valuation. -/
theorem int_valuation_ne_zero' (x : nonZeroDivisors R) : v.intValuationDef x ≠ 0 :=
  v.int_valuation_ne_zero x (nonZeroDivisors.coe_ne_zero x)
#align is_dedekind_domain.height_one_spectrum.int_valuation_ne_zero' IsDedekindDomain.HeightOneSpectrum.int_valuation_ne_zero'
-/

#print IsDedekindDomain.HeightOneSpectrum.int_valuation_zero_le /-
/-- Nonzero divisors have valuation greater than zero. -/
theorem int_valuation_zero_le (x : nonZeroDivisors R) : 0 < v.intValuationDef x :=
  by
  rw [v.int_valuation_def_if_neg (nonZeroDivisors.coe_ne_zero x)]
  exact WithZero.zero_lt_coe _
#align is_dedekind_domain.height_one_spectrum.int_valuation_zero_le IsDedekindDomain.HeightOneSpectrum.int_valuation_zero_le
-/

#print IsDedekindDomain.HeightOneSpectrum.int_valuation_le_one /-
/-- The `v`-adic valuation on `R` is bounded above by 1. -/
theorem int_valuation_le_one (x : R) : v.intValuationDef x ≤ 1 :=
  by
  rw [int_valuation_def]
  by_cases hx : x = 0
  · rw [if_pos hx]; exact WithZero.zero_le 1
  · rw [if_neg hx, ← WithZero.coe_one, ← ofAdd_zero, WithZero.coe_le_coe, of_add_le,
      Right.neg_nonpos_iff]
    exact Int.coe_nat_nonneg _
#align is_dedekind_domain.height_one_spectrum.int_valuation_le_one IsDedekindDomain.HeightOneSpectrum.int_valuation_le_one
-/

#print IsDedekindDomain.HeightOneSpectrum.int_valuation_lt_one_iff_dvd /-
/-- The `v`-adic valuation of `r ∈ R` is less than 1 if and only if `v` divides the ideal `(r)`. -/
theorem int_valuation_lt_one_iff_dvd (r : R) :
    v.intValuationDef r < 1 ↔ v.asIdeal ∣ Ideal.span {r} :=
  by
  rw [int_valuation_def]
  split_ifs with hr
  · simpa [hr] using WithZero.zero_lt_coe _
  · rw [← WithZero.coe_one, ← ofAdd_zero, WithZero.coe_lt_coe, of_add_lt, neg_lt_zero, ←
      Int.ofNat_zero, Int.ofNat_lt, zero_lt_iff]
    have h : (Ideal.span {r} : Ideal R) ≠ 0 :=
      by
      rw [Ne.def, Ideal.zero_eq_bot, Ideal.span_singleton_eq_bot]
      exact hr
    apply Associates.count_ne_zero_iff_dvd h (by apply v.irreducible)
#align is_dedekind_domain.height_one_spectrum.int_valuation_lt_one_iff_dvd IsDedekindDomain.HeightOneSpectrum.int_valuation_lt_one_iff_dvd
-/

#print IsDedekindDomain.HeightOneSpectrum.int_valuation_le_pow_iff_dvd /-
/-- The `v`-adic valuation of `r ∈ R` is less than `multiplicative.of_add (-n)` if and only if
`vⁿ` divides the ideal `(r)`. -/
theorem int_valuation_le_pow_iff_dvd (r : R) (n : ℕ) :
    v.intValuationDef r ≤ Multiplicative.ofAdd (-(n : ℤ)) ↔ v.asIdeal ^ n ∣ Ideal.span {r} :=
  by
  rw [int_valuation_def]
  split_ifs with hr
  · simp_rw [hr, Ideal.dvd_span_singleton, zero_le', Submodule.zero_mem]
  ·
    rw [WithZero.coe_le_coe, of_add_le, neg_le_neg_iff, Int.ofNat_le, Ideal.dvd_span_singleton, ←
      Associates.le_singleton_iff,
      Associates.prime_pow_dvd_iff_le (associates.mk_ne_zero'.mpr hr)
        (by apply v.associates_irreducible)]
#align is_dedekind_domain.height_one_spectrum.int_valuation_le_pow_iff_dvd IsDedekindDomain.HeightOneSpectrum.int_valuation_le_pow_iff_dvd
-/

#print IsDedekindDomain.HeightOneSpectrum.IntValuation.map_zero' /-
/-- The `v`-adic valuation of `0 : R` equals 0. -/
theorem IntValuation.map_zero' : v.intValuationDef 0 = 0 :=
  v.intValuationDef_if_pos (Eq.refl 0)
#align is_dedekind_domain.height_one_spectrum.int_valuation.map_zero' IsDedekindDomain.HeightOneSpectrum.IntValuation.map_zero'
-/

#print IsDedekindDomain.HeightOneSpectrum.IntValuation.map_one' /-
/-- The `v`-adic valuation of `1 : R` equals 1. -/
theorem IntValuation.map_one' : v.intValuationDef 1 = 1 := by
  rw [v.int_valuation_def_if_neg (zero_ne_one.symm : (1 : R) ≠ 0), Ideal.span_singleton_one, ←
    Ideal.one_eq_top, Associates.mk_one, Associates.factors_one,
    Associates.count_zero (by apply v.associates_irreducible), Int.ofNat_zero, neg_zero, ofAdd_zero,
    WithZero.coe_one]
#align is_dedekind_domain.height_one_spectrum.int_valuation.map_one' IsDedekindDomain.HeightOneSpectrum.IntValuation.map_one'
-/

#print IsDedekindDomain.HeightOneSpectrum.IntValuation.map_mul' /-
/-- The `v`-adic valuation of a product equals the product of the valuations. -/
theorem IntValuation.map_mul' (x y : R) :
    v.intValuationDef (x * y) = v.intValuationDef x * v.intValuationDef y :=
  by
  simp only [int_valuation_def]
  by_cases hx : x = 0
  · rw [hx, MulZeroClass.zero_mul, if_pos (Eq.refl _), MulZeroClass.zero_mul]
  · by_cases hy : y = 0
    · rw [hy, MulZeroClass.mul_zero, if_pos (Eq.refl _), MulZeroClass.mul_zero]
    · rw [if_neg hx, if_neg hy, if_neg (mul_ne_zero hx hy), ← WithZero.coe_mul, WithZero.coe_inj, ←
        ofAdd_add, ← Ideal.span_singleton_mul_span_singleton, ← Associates.mk_mul_mk, ← neg_add,
        Associates.count_mul (by apply associates.mk_ne_zero'.mpr hx)
          (by apply associates.mk_ne_zero'.mpr hy) (by apply v.associates_irreducible)]
      rfl
#align is_dedekind_domain.height_one_spectrum.int_valuation.map_mul' IsDedekindDomain.HeightOneSpectrum.IntValuation.map_mul'
-/

#print IsDedekindDomain.HeightOneSpectrum.IntValuation.le_max_iff_min_le /-
theorem IntValuation.le_max_iff_min_le {a b c : ℕ} :
    Multiplicative.ofAdd (-c : ℤ) ≤
        max (Multiplicative.ofAdd (-a : ℤ)) (Multiplicative.ofAdd (-b : ℤ)) ↔
      min a b ≤ c :=
  by
  rw [le_max_iff, of_add_le, of_add_le, neg_le_neg_iff, neg_le_neg_iff, Int.ofNat_le, Int.ofNat_le,
    ← min_le_iff]
#align is_dedekind_domain.height_one_spectrum.int_valuation.le_max_iff_min_le IsDedekindDomain.HeightOneSpectrum.IntValuation.le_max_iff_min_le
-/

#print IsDedekindDomain.HeightOneSpectrum.IntValuation.map_add_le_max' /-
/-- The `v`-adic valuation of a sum is bounded above by the maximum of the valuations. -/
theorem IntValuation.map_add_le_max' (x y : R) :
    v.intValuationDef (x + y) ≤ max (v.intValuationDef x) (v.intValuationDef y) :=
  by
  by_cases hx : x = 0
  · rw [hx, zero_add]
    conv_rhs => rw [int_valuation_def, if_pos (Eq.refl _)]
    rw [max_eq_right (WithZero.zero_le (v.int_valuation_def y))]
    exact le_refl _
  · by_cases hy : y = 0
    · rw [hy, add_zero]
      conv_rhs => rw [max_comm, int_valuation_def, if_pos (Eq.refl _)]
      rw [max_eq_right (WithZero.zero_le (v.int_valuation_def x))]
      exact le_refl _
    · by_cases hxy : x + y = 0
      · rw [int_valuation_def, if_pos hxy]; exact zero_le'
      · rw [v.int_valuation_def_if_neg hxy, v.int_valuation_def_if_neg hx,
          v.int_valuation_def_if_neg hy, WithZero.le_max_iff, int_valuation.le_max_iff_min_le]
        set nmin :=
          min ((Associates.mk v.as_ideal).count (Associates.mk (Ideal.span {x})).factors)
            ((Associates.mk v.as_ideal).count (Associates.mk (Ideal.span {y})).factors)
        have h_dvd_x : x ∈ v.as_ideal ^ nmin :=
          by
          rw [← Associates.le_singleton_iff x nmin _,
            Associates.prime_pow_dvd_iff_le (associates.mk_ne_zero'.mpr hx) _]
          exact min_le_left _ _
          apply v.associates_irreducible
        have h_dvd_y : y ∈ v.as_ideal ^ nmin :=
          by
          rw [← Associates.le_singleton_iff y nmin _,
            Associates.prime_pow_dvd_iff_le (associates.mk_ne_zero'.mpr hy) _]
          exact min_le_right _ _
          apply v.associates_irreducible
        have h_dvd_xy : Associates.mk v.as_ideal ^ nmin ≤ Associates.mk (Ideal.span {x + y}) :=
          by
          rw [Associates.le_singleton_iff]
          exact Ideal.add_mem (v.as_ideal ^ nmin) h_dvd_x h_dvd_y
        rw [Associates.prime_pow_dvd_iff_le (associates.mk_ne_zero'.mpr hxy) _] at h_dvd_xy 
        exact h_dvd_xy
        apply v.associates_irreducible
#align is_dedekind_domain.height_one_spectrum.int_valuation.map_add_le_max' IsDedekindDomain.HeightOneSpectrum.IntValuation.map_add_le_max'
-/

#print IsDedekindDomain.HeightOneSpectrum.intValuation /-
/-- The `v`-adic valuation on `R`. -/
def intValuation : Valuation R ℤₘ₀
    where
  toFun := v.intValuationDef
  map_zero' := IntValuation.map_zero' v
  map_one' := IntValuation.map_one' v
  map_mul' := IntValuation.map_mul' v
  map_add_le_max' := IntValuation.map_add_le_max' v
#align is_dedekind_domain.height_one_spectrum.int_valuation IsDedekindDomain.HeightOneSpectrum.intValuation
-/

#print IsDedekindDomain.HeightOneSpectrum.int_valuation_exists_uniformizer /-
/-- There exists `π ∈ R` with `v`-adic valuation `multiplicative.of_add (-1)`. -/
theorem int_valuation_exists_uniformizer :
    ∃ π : R, v.intValuationDef π = Multiplicative.ofAdd (-1 : ℤ) :=
  by
  have hv : _root_.irreducible (Associates.mk v.as_ideal) := v.associates_irreducible
  have hlt : v.as_ideal ^ 2 < v.as_ideal :=
    by
    rw [← Ideal.dvdNotUnit_iff_lt]
    exact
      ⟨v.ne_bot, v.as_ideal, (not_congr Ideal.isUnit_iff).mpr (Ideal.IsPrime.ne_top v.is_prime),
        sq v.as_ideal⟩
  obtain ⟨π, mem, nmem⟩ := SetLike.exists_of_lt hlt
  have hπ : Associates.mk (Ideal.span {π}) ≠ 0 :=
    by
    rw [Associates.mk_ne_zero']
    intro h
    rw [h] at nmem 
    exact nmem (Submodule.zero_mem (v.as_ideal ^ 2))
  use π
  rw [int_valuation_def, if_neg (associates.mk_ne_zero'.mp hπ), WithZero.coe_inj]
  apply congr_arg
  rw [neg_inj, ← Int.ofNat_one, Int.coe_nat_inj']
  rw [← Ideal.dvd_span_singleton, ← Associates.mk_le_mk_iff_dvd_iff] at mem nmem 
  rw [← pow_one (Associates.mk v.as_ideal), Associates.prime_pow_dvd_iff_le hπ hv] at mem 
  rw [Associates.mk_pow, Associates.prime_pow_dvd_iff_le hπ hv, not_le] at nmem 
  exact Nat.eq_of_le_of_lt_succ mem nmem
#align is_dedekind_domain.height_one_spectrum.int_valuation_exists_uniformizer IsDedekindDomain.HeightOneSpectrum.int_valuation_exists_uniformizer
-/

/-! ### Adic valuations on the field of fractions `K` -/


#print IsDedekindDomain.HeightOneSpectrum.valuation /-
/-- The `v`-adic valuation of `x ∈ K` is the valuation of `r` divided by the valuation of `s`,
where `r` and `s` are chosen so that `x = r/s`. -/
def valuation (v : HeightOneSpectrum R) : Valuation K ℤₘ₀ :=
  v.intValuation.extendToLocalization
    (fun r hr => Set.mem_compl <| v.int_valuation_ne_zero' ⟨r, hr⟩) K
#align is_dedekind_domain.height_one_spectrum.valuation IsDedekindDomain.HeightOneSpectrum.valuation
-/

#print IsDedekindDomain.HeightOneSpectrum.valuation_def /-
theorem valuation_def (x : K) :
    v.Valuation x =
      v.intValuation.extendToLocalization
        (fun r hr => Set.mem_compl (v.int_valuation_ne_zero' ⟨r, hr⟩)) K x :=
  rfl
#align is_dedekind_domain.height_one_spectrum.valuation_def IsDedekindDomain.HeightOneSpectrum.valuation_def
-/

#print IsDedekindDomain.HeightOneSpectrum.valuation_of_mk' /-
/-- The `v`-adic valuation of `r/s ∈ K` is the valuation of `r` divided by the valuation of `s`. -/
theorem valuation_of_mk' {r : R} {s : nonZeroDivisors R} :
    v.Valuation (IsLocalization.mk' K r s) = v.intValuation r / v.intValuation s :=
  by
  erw [valuation_def, (IsLocalization.toLocalizationMap (nonZeroDivisors R) K).lift_mk',
    div_eq_mul_inv, mul_eq_mul_left_iff]
  left
  rw [Units.val_inv_eq_inv_val, inv_inj]
  rfl
#align is_dedekind_domain.height_one_spectrum.valuation_of_mk' IsDedekindDomain.HeightOneSpectrum.valuation_of_mk'
-/

#print IsDedekindDomain.HeightOneSpectrum.valuation_of_algebraMap /-
/-- The `v`-adic valuation on `K` extends the `v`-adic valuation on `R`. -/
theorem valuation_of_algebraMap (r : R) : v.Valuation (algebraMap R K r) = v.intValuation r := by
  rw [valuation_def, Valuation.extendToLocalization_apply_map_apply]
#align is_dedekind_domain.height_one_spectrum.valuation_of_algebra_map IsDedekindDomain.HeightOneSpectrum.valuation_of_algebraMap
-/

#print IsDedekindDomain.HeightOneSpectrum.valuation_le_one /-
/-- The `v`-adic valuation on `R` is bounded above by 1. -/
theorem valuation_le_one (r : R) : v.Valuation (algebraMap R K r) ≤ 1 := by
  rw [valuation_of_algebra_map]; exact v.int_valuation_le_one r
#align is_dedekind_domain.height_one_spectrum.valuation_le_one IsDedekindDomain.HeightOneSpectrum.valuation_le_one
-/

#print IsDedekindDomain.HeightOneSpectrum.valuation_lt_one_iff_dvd /-
/-- The `v`-adic valuation of `r ∈ R` is less than 1 if and only if `v` divides the ideal `(r)`. -/
theorem valuation_lt_one_iff_dvd (r : R) :
    v.Valuation (algebraMap R K r) < 1 ↔ v.asIdeal ∣ Ideal.span {r} := by
  rw [valuation_of_algebra_map]; exact v.int_valuation_lt_one_iff_dvd r
#align is_dedekind_domain.height_one_spectrum.valuation_lt_one_iff_dvd IsDedekindDomain.HeightOneSpectrum.valuation_lt_one_iff_dvd
-/

variable (K)

#print IsDedekindDomain.HeightOneSpectrum.valuation_exists_uniformizer /-
/-- There exists `π ∈ K` with `v`-adic valuation `multiplicative.of_add (-1)`. -/
theorem valuation_exists_uniformizer : ∃ π : K, v.Valuation π = Multiplicative.ofAdd (-1 : ℤ) :=
  by
  obtain ⟨r, hr⟩ := v.int_valuation_exists_uniformizer
  use algebraMap R K r
  rw [valuation_def, Valuation.extendToLocalization_apply_map_apply]
  exact hr
#align is_dedekind_domain.height_one_spectrum.valuation_exists_uniformizer IsDedekindDomain.HeightOneSpectrum.valuation_exists_uniformizer
-/

#print IsDedekindDomain.HeightOneSpectrum.valuation_uniformizer_ne_zero /-
/-- Uniformizers are nonzero. -/
theorem valuation_uniformizer_ne_zero : Classical.choose (v.valuation_exists_uniformizer K) ≠ 0 :=
  haveI hu := Classical.choose_spec (v.valuation_exists_uniformizer K)
  (Valuation.ne_zero_iff _).mp (ne_of_eq_of_ne hu WithZero.coe_ne_zero)
#align is_dedekind_domain.height_one_spectrum.valuation_uniformizer_ne_zero IsDedekindDomain.HeightOneSpectrum.valuation_uniformizer_ne_zero
-/

/-! ### Completions with respect to adic valuations

Given a Dedekind domain `R` with field of fractions `K` and a maximal ideal `v` of `R`, we define
the completion of `K` with respect to its `v`-adic valuation, denoted `v.adic_completion`, and its
ring of integers, denoted `v.adic_completion_integers`. -/


variable {K}

#print IsDedekindDomain.HeightOneSpectrum.adicValued /-
/-- `K` as a valued field with the `v`-adic valuation. -/
def adicValued : Valued K ℤₘ₀ :=
  Valued.mk' v.Valuation
#align is_dedekind_domain.height_one_spectrum.adic_valued IsDedekindDomain.HeightOneSpectrum.adicValued
-/

#print IsDedekindDomain.HeightOneSpectrum.adicValued_apply /-
theorem adicValued_apply {x : K} : (v.adicValued.V : _) x = v.Valuation x :=
  rfl
#align is_dedekind_domain.height_one_spectrum.adic_valued_apply IsDedekindDomain.HeightOneSpectrum.adicValued_apply
-/

variable (K)

#print IsDedekindDomain.HeightOneSpectrum.adicCompletion /-
/-- The completion of `K` with respect to its `v`-adic valuation. -/
def adicCompletion :=
  @UniformSpace.Completion K v.adicValued.toUniformSpace
#align is_dedekind_domain.height_one_spectrum.adic_completion IsDedekindDomain.HeightOneSpectrum.adicCompletion
-/

instance : Field (v.adicCompletion K) :=
  @UniformSpace.Completion.instField K _ v.adicValued.toUniformSpace _ _
    v.adicValued.to_uniformAddGroup

instance : Inhabited (v.adicCompletion K) :=
  ⟨0⟩

#print IsDedekindDomain.HeightOneSpectrum.valuedAdicCompletion /-
instance valuedAdicCompletion : Valued (v.adicCompletion K) ℤₘ₀ :=
  @Valued.valuedCompletion _ _ _ _ v.adicValued
#align is_dedekind_domain.height_one_spectrum.valued_adic_completion IsDedekindDomain.HeightOneSpectrum.valuedAdicCompletion
-/

#print IsDedekindDomain.HeightOneSpectrum.valuedAdicCompletion_def /-
theorem valuedAdicCompletion_def {x : v.adicCompletion K} :
    Valued.v x = @Valued.extension K _ _ _ (adicValued v) x :=
  rfl
#align is_dedekind_domain.height_one_spectrum.valued_adic_completion_def IsDedekindDomain.HeightOneSpectrum.valuedAdicCompletion_def
-/

#print IsDedekindDomain.HeightOneSpectrum.adicCompletion_completeSpace /-
instance adicCompletion_completeSpace : CompleteSpace (v.adicCompletion K) :=
  @UniformSpace.Completion.completeSpace K v.adicValued.toUniformSpace
#align is_dedekind_domain.height_one_spectrum.adic_completion_complete_space IsDedekindDomain.HeightOneSpectrum.adicCompletion_completeSpace
-/

instance adicCompletion.hasLiftT : HasLiftT K (v.adicCompletion K) :=
  (inferInstance : HasLiftT K (@UniformSpace.Completion K v.adicValued.toUniformSpace))
#align is_dedekind_domain.height_one_spectrum.adic_completion.has_lift_t IsDedekindDomain.HeightOneSpectrum.adicCompletion.hasLiftT

#print IsDedekindDomain.HeightOneSpectrum.adicCompletionIntegers /-
/-- The ring of integers of `adic_completion`. -/
def adicCompletionIntegers : ValuationSubring (v.adicCompletion K) :=
  Valued.v.ValuationSubring
#align is_dedekind_domain.height_one_spectrum.adic_completion_integers IsDedekindDomain.HeightOneSpectrum.adicCompletionIntegers
-/

instance : Inhabited (adicCompletionIntegers K v) :=
  ⟨0⟩

variable (R K)

#print IsDedekindDomain.HeightOneSpectrum.mem_adicCompletionIntegers /-
theorem mem_adicCompletionIntegers {x : v.adicCompletion K} :
    x ∈ v.adicCompletionIntegers K ↔ (Valued.v x : ℤₘ₀) ≤ 1 :=
  Iff.rfl
#align is_dedekind_domain.height_one_spectrum.mem_adic_completion_integers IsDedekindDomain.HeightOneSpectrum.mem_adicCompletionIntegers
-/

section AlgebraInstances

#print IsDedekindDomain.HeightOneSpectrum.adicValued.has_uniform_continuous_const_smul' /-
instance (priority := 100) adicValued.has_uniform_continuous_const_smul' :
    @UniformContinuousConstSMul R K v.adicValued.toUniformSpace _ :=
  @uniformContinuousConstSMul_of_continuousConstSMul R K _ _ _ v.adicValued.toUniformSpace _ _
#align is_dedekind_domain.height_one_spectrum.adic_valued.has_uniform_continuous_const_smul' IsDedekindDomain.HeightOneSpectrum.adicValued.has_uniform_continuous_const_smul'
-/

#print IsDedekindDomain.HeightOneSpectrum.adicValued.uniformContinuousConstSMul /-
instance adicValued.uniformContinuousConstSMul :
    @UniformContinuousConstSMul K K v.adicValued.toUniformSpace _ :=
  @Ring.uniformContinuousConstSMul K _ v.adicValued.toUniformSpace _ _
#align is_dedekind_domain.height_one_spectrum.adic_valued.has_uniform_continuous_const_smul IsDedekindDomain.HeightOneSpectrum.adicValued.uniformContinuousConstSMul
-/

#print IsDedekindDomain.HeightOneSpectrum.AdicCompletion.algebra' /-
instance AdicCompletion.algebra' : Algebra R (v.adicCompletion K) :=
  @UniformSpace.Completion.algebra K _ v.adicValued.toUniformSpace _ _ R _ _
    (adicValued.has_uniform_continuous_const_smul' R K v)
#align is_dedekind_domain.height_one_spectrum.adic_completion.algebra' IsDedekindDomain.HeightOneSpectrum.AdicCompletion.algebra'
-/

#print IsDedekindDomain.HeightOneSpectrum.coe_smul_adicCompletion /-
@[simp]
theorem coe_smul_adicCompletion (r : R) (x : K) :
    (↑(r • x) : v.adicCompletion K) = r • (↑x : v.adicCompletion K) :=
  @UniformSpace.Completion.coe_smul R K v.adicValued.toUniformSpace _ _ r x
#align is_dedekind_domain.height_one_spectrum.coe_smul_adic_completion IsDedekindDomain.HeightOneSpectrum.coe_smul_adicCompletion
-/

instance : Algebra K (v.adicCompletion K) :=
  @UniformSpace.Completion.algebra' K _ v.adicValued.toUniformSpace _ _

#print IsDedekindDomain.HeightOneSpectrum.algebraMap_adicCompletion' /-
theorem algebraMap_adicCompletion' : ⇑(algebraMap R <| v.adicCompletion K) = coe ∘ algebraMap R K :=
  rfl
#align is_dedekind_domain.height_one_spectrum.algebra_map_adic_completion' IsDedekindDomain.HeightOneSpectrum.algebraMap_adicCompletion'
-/

#print IsDedekindDomain.HeightOneSpectrum.algebraMap_adicCompletion /-
theorem algebraMap_adicCompletion : ⇑(algebraMap K <| v.adicCompletion K) = coe :=
  rfl
#align is_dedekind_domain.height_one_spectrum.algebra_map_adic_completion IsDedekindDomain.HeightOneSpectrum.algebraMap_adicCompletion
-/

instance : IsScalarTower R K (v.adicCompletion K) :=
  @UniformSpace.Completion.instIsScalarTower R K K v.adicValued.toUniformSpace _ _ _
    (adicValued.has_uniform_continuous_const_smul' R K v) _ _

instance : Algebra R (v.adicCompletionIntegers K)
    where
  smul r x :=
    ⟨r • (x : v.adicCompletion K),
      by
      have h : (algebraMap R (adicCompletion K v)) r = (coe <| algebraMap R K r) := rfl
      rw [Algebra.smul_def]
      refine' ValuationSubring.mul_mem _ _ _ _ x.2
      rw [mem_adic_completion_integers, h, Valued.valuedCompletion_apply]
      exact v.valuation_le_one _⟩
  toFun r :=
    ⟨coe <| algebraMap R K r, by
      simpa only [mem_adic_completion_integers, Valued.valuedCompletion_apply] using
        v.valuation_le_one _⟩
  map_one' := by simp only [map_one] <;> rfl
  map_mul' x y := by
    ext
    simp_rw [RingHom.map_mul, Subring.coe_mul, Subtype.coe_mk, UniformSpace.Completion.coe_mul]
  map_zero' := by simp only [map_zero] <;> rfl
  map_add' x y := by
    ext
    simp_rw [RingHom.map_add, Subring.coe_add, Subtype.coe_mk, UniformSpace.Completion.coe_add]
  commutes' r x := by rw [mul_comm]
  smul_def' r x := by
    ext
    simp only [Subring.coe_mul, SetLike.coe_mk, Algebra.smul_def]
    rfl

#print IsDedekindDomain.HeightOneSpectrum.coe_smul_adicCompletionIntegers /-
@[simp]
theorem coe_smul_adicCompletionIntegers (r : R) (x : v.adicCompletionIntegers K) :
    (↑(r • x) : v.adicCompletion K) = r • (x : v.adicCompletion K) :=
  rfl
#align is_dedekind_domain.height_one_spectrum.coe_smul_adic_completion_integers IsDedekindDomain.HeightOneSpectrum.coe_smul_adicCompletionIntegers
-/

instance : NoZeroSMulDivisors R (v.adicCompletionIntegers K)
    where eq_zero_or_eq_zero_of_smul_eq_zero c x hcx :=
    by
    rw [Algebra.smul_def, mul_eq_zero] at hcx 
    refine' hcx.imp_left fun hc => _
    letI : UniformSpace K := v.adic_valued.to_uniform_space
    rw [← map_zero (algebraMap R (v.adic_completion_integers K))] at hc 
    exact
      IsFractionRing.injective R K (UniformSpace.Completion.coe_injective K (subtype.ext_iff.mp hc))

#print IsDedekindDomain.HeightOneSpectrum.AdicCompletion.instIsScalarTower' /-
instance AdicCompletion.instIsScalarTower' :
    IsScalarTower R (v.adicCompletionIntegers K) (v.adicCompletion K)
    where smul_assoc x y z := by simp only [Algebra.smul_def]; apply mul_assoc
#align is_dedekind_domain.height_one_spectrum.adic_completion.is_scalar_tower' IsDedekindDomain.HeightOneSpectrum.AdicCompletion.instIsScalarTower'
-/

end AlgebraInstances

end IsDedekindDomain.HeightOneSpectrum

