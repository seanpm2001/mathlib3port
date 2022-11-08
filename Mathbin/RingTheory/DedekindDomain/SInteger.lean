/-
Copyright (c) 2022 David Kurniadi Angdinata. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: David Kurniadi Angdinata
-/
import Mathbin.RingTheory.DedekindDomain.AdicValuation

/-!
# `S`-integers and `S`-units of fraction fields of Dedekind domains

Let `K` be the field of fractions of a Dedekind domain `R`, and let `S` be a set of prime ideals in
the height one spectrum of `R`. An `S`-integer of `K` is defined to have `v`-adic valuation at most
one for all primes ideals `v` away from `S`, whereas an `S`-unit of `Kˣ` is defined to have `v`-adic
valuation exactly one for all prime ideals `v` away from `S`.

This file defines the subalgebra of `S`-integers of `K` and the subgroup of `S`-units of `Kˣ`, where
`K` can be specialised to the case of a number field or a function field separately.

## Main definitions

 * `set.integer`: `S`-integers.
 * `set.unit`: `S`-units.
 * TODO: localised notation for `S`-integers.

## Main statements

 * `set.unit_equiv_units_integer`: `S`-units are units of `S`-integers.
 * TODO: proof that `S`-units is the kernel of a map to a product.
 * TODO: proof that `∅`-integers is the usual ring of integers.
 * TODO: finite generation of `S`-units and Dirichlet's `S`-unit theorem.

## References

 * [D Marcus, *Number Fields*][marcus1977number]
 * [J W S Cassels, A Frölich, *Algebraic Number Theory*][cassels1967algebraic]
 * [J Neukirch, *Algebraic Number Theory*][Neukirch1992]

## Tags

S integer, S-integer, S unit, S-unit
-/


namespace Set

noncomputable section

open IsDedekindDomain

open nonZeroDivisors

universe u v

variable {R : Type u} [CommRing R] [IsDomain R] [IsDedekindDomain R] (S : Set <| HeightOneSpectrum R) (K : Type v)
  [Field K] [Algebra R K] [IsFractionRing R K]

/-! ## `S`-integers -/


/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (v «expr ∉ » S) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (v «expr ∉ » S) -/
/-- The `R`-subalgebra of `S`-integers of `K`. -/
@[simps]
def integer : Subalgebra R K :=
  { (⨅ (v) (_ : v ∉ S), (v : HeightOneSpectrum R).Valuation.ValuationSubring.toSubring).copy
        { x : K | ∀ (v) (_ : v ∉ S), (v : HeightOneSpectrum R).Valuation x ≤ 1 } <|
      Set.ext fun _ => by simpa only [SetLike.mem_coe, Subring.mem_infi] with
    algebra_map_mem' := fun x v _ => v.valuation_le_one x }

/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (v «expr ∉ » S) -/
theorem integer_eq :
    (S.integer K).toSubring = ⨅ (v) (_ : v ∉ S), (v : HeightOneSpectrum R).Valuation.ValuationSubring.toSubring :=
  SetLike.ext' <| by simpa only [integer, Subring.copy_eq]

theorem integer_valuation_le_one (x : S.integer K) {v : HeightOneSpectrum R} (hv : v ∉ S) : v.Valuation (x : K) ≤ 1 :=
  x.property v hv

/-! ## `S`-units -/


/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (v «expr ∉ » S) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (v «expr ∉ » S) -/
/-- The subgroup of `S`-units of `Kˣ`. -/
@[simps]
def unit : Subgroup Kˣ :=
  (⨅ (v) (_ : v ∉ S), (v : HeightOneSpectrum R).Valuation.ValuationSubring.unitGroup).copy
      { x : Kˣ | ∀ (v) (_ : v ∉ S), (v : HeightOneSpectrum R).Valuation (x : K) = 1 } <|
    Set.ext fun _ => by simpa only [SetLike.mem_coe, Subgroup.mem_infi, Valuation.mem_unit_group_iff]

/- ./././Mathport/Syntax/Translate/Basic.lean:572:2: warning: expanding binder collection (v «expr ∉ » S) -/
theorem unit_eq : S.Unit K = ⨅ (v) (_ : v ∉ S), (v : HeightOneSpectrum R).Valuation.ValuationSubring.unitGroup :=
  Subgroup.copy_eq _ _ _

theorem unit_valuation_eq_one (x : S.Unit K) {v : HeightOneSpectrum R} (hv : v ∉ S) : v.Valuation (x : K) = 1 :=
  x.property v hv

/-- The group of `S`-units is the group of units of the ring of `S`-integers. -/
@[simps]
def unitEquivUnitsInteger : S.Unit K ≃* (S.integer K)ˣ where
  toFun x :=
    ⟨⟨x, fun v hv => (x.property v hv).le⟩, ⟨↑x⁻¹, fun v hv => (x⁻¹.property v hv).le⟩, Subtype.ext x.val.val_inv,
      Subtype.ext x.val.inv_val⟩
  invFun x :=
    ⟨(Units.mk0 x) fun hx => x.NeZero ((Subring.coe_eq_zero_iff _).mp hx), fun v hv =>
      eq_one_of_one_le_mul_left (x.val.property v hv) (x.inv.property v hv) <|
        Eq.ge <| by
          rw [← map_mul]
          convert v.valuation.map_one
          exact subtype.mk_eq_mk.mp x.val_inv⟩
  left_inv _ := by
    ext
    rfl
  right_inv _ := by
    ext
    rfl
  map_mul' _ _ := by
    ext
    rfl

end Set

