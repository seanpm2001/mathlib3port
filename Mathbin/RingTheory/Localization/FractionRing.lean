/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Mario Carneiro, Johan Commelin, Amelia Livingston, Anne Baanen

! This file was ported from Lean 3 source module ring_theory.localization.fraction_ring
! leanprover-community/mathlib commit 8ef6f08ff8c781c5c07a8b12843710e1a0d8a688
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Tower
import Mathbin.RingTheory.Localization.Basic

/-!
# Fraction ring / fraction field Frac(R) as localization

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

 * `is_fraction_ring R K` expresses that `K` is a field of fractions of `R`, as an abbreviation of
   `is_localization (non_zero_divisors R) K`

## Main results

 * `is_fraction_ring.field`: a definition (not an instance) stating the localization of an integral
   domain `R` at `R \ {0}` is a field
 * `rat.is_fraction_ring` is an instance stating `ℚ` is the field of fractions of `ℤ`

## Implementation notes

See `src/ring_theory/localization/basic.lean` for a design overview.

## Tags
localization, ring localization, commutative ring localization, characteristic predicate,
commutative ring, field of fractions
-/


variable (R : Type _) [CommRing R] {M : Submonoid R} (S : Type _) [CommRing S]

variable [Algebra R S] {P : Type _} [CommRing P]

variable {A : Type _} [CommRing A] [IsDomain A] (K : Type _)

#print IsFractionRing /-
-- TODO: should this extend `algebra` instead of assuming it?
/-- `is_fraction_ring R K` states `K` is the field of fractions of an integral domain `R`. -/
abbrev IsFractionRing [CommRing K] [Algebra R K] :=
  IsLocalization (nonZeroDivisors R) K
#align is_fraction_ring IsFractionRing
-/

#print Rat.isFractionRing /-
/-- The cast from `int` to `rat` as a `fraction_ring`. -/
instance Rat.isFractionRing : IsFractionRing ℤ ℚ
    where
  map_units := by
    rintro ⟨x, hx⟩
    rw [mem_nonZeroDivisors_iff_ne_zero] at hx 
    simpa only [eq_intCast, isUnit_iff_ne_zero, Int.cast_eq_zero, Ne.def, Subtype.coe_mk] using hx
  surj := by
    rintro ⟨n, d, hd, h⟩
    refine' ⟨⟨n, ⟨d, _⟩⟩, Rat.mul_den_eq_num⟩
    rwa [mem_nonZeroDivisors_iff_ne_zero, Int.coe_nat_ne_zero_iff_pos]
  eq_iff_exists := by
    intro x y
    rw [eq_intCast, eq_intCast, Int.cast_inj]
    refine' ⟨by rintro rfl; use 1, _⟩
    rintro ⟨⟨c, hc⟩, h⟩
    apply mul_left_cancel₀ _ h
    rwa [mem_nonZeroDivisors_iff_ne_zero] at hc 
#align rat.is_fraction_ring Rat.isFractionRing
-/

namespace IsFractionRing

open IsLocalization

variable {R K}

section CommRing

variable [CommRing K] [Algebra R K] [IsFractionRing R K] [Algebra A K] [IsFractionRing A K]

#print IsFractionRing.to_map_eq_zero_iff /-
theorem to_map_eq_zero_iff {x : R} : algebraMap R K x = 0 ↔ x = 0 :=
  to_map_eq_zero_iff _ (le_of_eq rfl)
#align is_fraction_ring.to_map_eq_zero_iff IsFractionRing.to_map_eq_zero_iff
-/

variable (R K)

#print IsFractionRing.injective /-
protected theorem injective : Function.Injective (algebraMap R K) :=
  IsLocalization.injective _ (le_of_eq rfl)
#align is_fraction_ring.injective IsFractionRing.injective
-/

variable {R K}

#print IsFractionRing.coe_inj /-
@[norm_cast, simp]
theorem coe_inj {a b : R} : (↑a : K) = ↑b ↔ a = b :=
  (IsFractionRing.injective R K).eq_iff
#align is_fraction_ring.coe_inj IsFractionRing.coe_inj
-/

instance (priority := 100) [NoZeroDivisors K] : NoZeroSMulDivisors R K :=
  NoZeroSMulDivisors.of_algebraMap_injective <| IsFractionRing.injective R K

variable {R K}

#print IsFractionRing.to_map_ne_zero_of_mem_nonZeroDivisors /-
protected theorem to_map_ne_zero_of_mem_nonZeroDivisors [Nontrivial R] {x : R}
    (hx : x ∈ nonZeroDivisors R) : algebraMap R K x ≠ 0 :=
  IsLocalization.to_map_ne_zero_of_mem_nonZeroDivisors _ le_rfl hx
#align is_fraction_ring.to_map_ne_zero_of_mem_non_zero_divisors IsFractionRing.to_map_ne_zero_of_mem_nonZeroDivisors
-/

variable (A)

#print IsFractionRing.isDomain /-
/-- A `comm_ring` `K` which is the localization of an integral domain `R` at `R - {0}` is an
integral domain. -/
protected theorem isDomain : IsDomain K :=
  isDomain_of_le_nonZeroDivisors _ (le_refl (nonZeroDivisors A))
#align is_fraction_ring.is_domain IsFractionRing.isDomain
-/

attribute [local instance] Classical.decEq

#print IsFractionRing.inv /-
/-- The inverse of an element in the field of fractions of an integral domain. -/
protected noncomputable irreducible_def inv (z : K) : K :=
  if h : z = 0 then 0
  else
    mk' K ↑(sec (nonZeroDivisors A) z).2
      ⟨(sec _ z).1,
        mem_nonZeroDivisors_iff_ne_zero.2 fun h0 =>
          h <| eq_zero_of_fst_eq_zero (sec_spec (nonZeroDivisors A) z) h0⟩
#align is_fraction_ring.inv IsFractionRing.inv
-/

#print IsFractionRing.mul_inv_cancel /-
protected theorem mul_inv_cancel (x : K) (hx : x ≠ 0) : x * IsFractionRing.inv A x = 1 :=
  by
  rw [IsFractionRing.inv, dif_neg hx, ←
    IsUnit.mul_left_inj
      (map_units K
        ⟨(sec _ x).1,
          mem_nonZeroDivisors_iff_ne_zero.2 fun h0 =>
            hx <| eq_zero_of_fst_eq_zero (sec_spec (nonZeroDivisors A) x) h0⟩),
    one_mul, mul_assoc]
  rw [mk'_spec, ← eq_mk'_iff_mul_eq]
  exact (mk'_sec _ x).symm
#align is_fraction_ring.mul_inv_cancel IsFractionRing.mul_inv_cancel
-/

#print IsFractionRing.toField /-
/-- A `comm_ring` `K` which is the localization of an integral domain `R` at `R - {0}` is a field.
See note [reducible non-instances]. -/
@[reducible]
noncomputable def toField : Field K :=
  { IsFractionRing.isDomain A,
    show CommRing K by infer_instance with
    inv := IsFractionRing.inv A
    mul_inv_cancel := IsFractionRing.mul_inv_cancel A
    inv_zero := by
      change IsFractionRing.inv A (0 : K) = 0
      rw [IsFractionRing.inv]
      exact dif_pos rfl }
#align is_fraction_ring.to_field IsFractionRing.toField
-/

end CommRing

variable {B : Type _} [CommRing B] [IsDomain B] [Field K] {L : Type _} [Field L] [Algebra A K]
  [IsFractionRing A K] {g : A →+* L}

#print IsFractionRing.mk'_mk_eq_div /-
theorem mk'_mk_eq_div {r s} (hs : s ∈ nonZeroDivisors A) :
    mk' K r ⟨s, hs⟩ = algebraMap A K r / algebraMap A K s :=
  mk'_eq_iff_eq_mul.2 <|
    (div_mul_cancel (algebraMap A K r)
        (IsFractionRing.to_map_ne_zero_of_mem_nonZeroDivisors hs)).symm
#align is_fraction_ring.mk'_mk_eq_div IsFractionRing.mk'_mk_eq_div
-/

#print IsFractionRing.mk'_eq_div /-
@[simp]
theorem mk'_eq_div {r} (s : nonZeroDivisors A) : mk' K r s = algebraMap A K r / algebraMap A K s :=
  mk'_mk_eq_div s.2
#align is_fraction_ring.mk'_eq_div IsFractionRing.mk'_eq_div
-/

#print IsFractionRing.div_surjective /-
theorem div_surjective (z : K) :
    ∃ (x y : A) (hy : y ∈ nonZeroDivisors A), algebraMap _ _ x / algebraMap _ _ y = z :=
  let ⟨x, ⟨y, hy⟩, h⟩ := mk'_surjective (nonZeroDivisors A) z
  ⟨x, y, hy, by rwa [mk'_eq_div] at h ⟩
#align is_fraction_ring.div_surjective IsFractionRing.div_surjective
-/

#print IsFractionRing.isUnit_map_of_injective /-
theorem isUnit_map_of_injective (hg : Function.Injective g) (y : nonZeroDivisors A) :
    IsUnit (g y) :=
  IsUnit.mk0 (g y) <|
    show g.toMonoidWithZeroHom y ≠ 0 from map_ne_zero_of_mem_nonZeroDivisors g hg y.2
#align is_fraction_ring.is_unit_map_of_injective IsFractionRing.isUnit_map_of_injective
-/

#print IsFractionRing.mk'_eq_zero_iff_eq_zero /-
@[simp]
theorem mk'_eq_zero_iff_eq_zero [Algebra R K] [IsFractionRing R K] {x : R} {y : nonZeroDivisors R} :
    mk' K x y = 0 ↔ x = 0 :=
  by
  refine' ⟨fun hxy => _, fun h => by rw [h, mk'_zero]⟩
  · simp_rw [mk'_eq_zero_iff, mul_left_coe_nonZeroDivisors_eq_zero_iff] at hxy 
    exact (exists_const _).mp hxy
#align is_fraction_ring.mk'_eq_zero_iff_eq_zero IsFractionRing.mk'_eq_zero_iff_eq_zero
-/

#print IsFractionRing.mk'_eq_one_iff_eq /-
theorem mk'_eq_one_iff_eq {x : A} {y : nonZeroDivisors A} : mk' K x y = 1 ↔ x = y :=
  by
  refine' ⟨_, fun hxy => by rw [hxy, mk'_self']⟩
  · intro hxy;
    have hy : (algebraMap A K) ↑y ≠ (0 : K) :=
      IsFractionRing.to_map_ne_zero_of_mem_nonZeroDivisors y.property
    rw [IsFractionRing.mk'_eq_div, div_eq_one_iff_eq hy] at hxy 
    exact IsFractionRing.injective A K hxy
#align is_fraction_ring.mk'_eq_one_iff_eq IsFractionRing.mk'_eq_one_iff_eq
-/

open Function

#print IsFractionRing.lift /-
/-- Given an integral domain `A` with field of fractions `K`,
and an injective ring hom `g : A →+* L` where `L` is a field, we get a
field hom sending `z : K` to `g x * (g y)⁻¹`, where `(x, y) : A × (non_zero_divisors A)` are
such that `z = f x * (f y)⁻¹`. -/
noncomputable def lift (hg : Injective g) : K →+* L :=
  lift fun y : nonZeroDivisors A => isUnit_map_of_injective hg y
#align is_fraction_ring.lift IsFractionRing.lift
-/

#print IsFractionRing.lift_algebraMap /-
/-- Given an integral domain `A` with field of fractions `K`,
and an injective ring hom `g : A →+* L` where `L` is a field,
the field hom induced from `K` to `L` maps `x` to `g x` for all
`x : A`. -/
@[simp]
theorem lift_algebraMap (hg : Injective g) (x) : lift hg (algebraMap A K x) = g x :=
  lift_eq _ _
#align is_fraction_ring.lift_algebra_map IsFractionRing.lift_algebraMap
-/

#print IsFractionRing.lift_mk' /-
/-- Given an integral domain `A` with field of fractions `K`,
and an injective ring hom `g : A →+* L` where `L` is a field,
field hom induced from `K` to `L` maps `f x / f y` to `g x / g y` for all
`x : A, y ∈ non_zero_divisors A`. -/
theorem lift_mk' (hg : Injective g) (x) (y : nonZeroDivisors A) : lift hg (mk' K x y) = g x / g y :=
  by simp only [mk'_eq_div, map_div₀, lift_algebra_map]
#align is_fraction_ring.lift_mk' IsFractionRing.lift_mk'
-/

#print IsFractionRing.map /-
/-- Given integral domains `A, B` with fields of fractions `K`, `L`
and an injective ring hom `j : A →+* B`, we get a field hom
sending `z : K` to `g (j x) * (g (j y))⁻¹`, where `(x, y) : A × (non_zero_divisors A)` are
such that `z = f x * (f y)⁻¹`. -/
noncomputable def map {A B K L : Type _} [CommRing A] [CommRing B] [IsDomain B] [CommRing K]
    [Algebra A K] [IsFractionRing A K] [CommRing L] [Algebra B L] [IsFractionRing B L] {j : A →+* B}
    (hj : Injective j) : K →+* L :=
  map L j
    (show nonZeroDivisors A ≤ (nonZeroDivisors B).comap j from
      nonZeroDivisors_le_comap_nonZeroDivisors_of_injective j hj)
#align is_fraction_ring.map IsFractionRing.map
-/

#print IsFractionRing.fieldEquivOfRingEquiv /-
/-- Given integral domains `A, B` and localization maps to their fields of fractions
`f : A →+* K, g : B →+* L`, an isomorphism `j : A ≃+* B` induces an isomorphism of
fields of fractions `K ≃+* L`. -/
noncomputable def fieldEquivOfRingEquiv [Algebra B L] [IsFractionRing B L] (h : A ≃+* B) :
    K ≃+* L :=
  ringEquivOfRingEquiv K L h
    (by
      ext b
      show b ∈ h.to_equiv '' _ ↔ _
      erw [h.to_equiv.image_eq_preimage, Set.preimage, Set.mem_setOf_eq,
        mem_nonZeroDivisors_iff_ne_zero, mem_nonZeroDivisors_iff_ne_zero]
      exact h.symm.map_ne_zero_iff)
#align is_fraction_ring.field_equiv_of_ring_equiv IsFractionRing.fieldEquivOfRingEquiv
-/

variable (S)

#print IsFractionRing.isFractionRing_iff_of_base_ringEquiv /-
theorem isFractionRing_iff_of_base_ringEquiv (h : R ≃+* P) :
    IsFractionRing R S ↔
      @IsFractionRing P _ S _ ((algebraMap R S).comp h.symm.toRingHom).toAlgebra :=
  by
  delta IsFractionRing
  convert is_localization_iff_of_base_ring_equiv _ _ h
  ext x
  erw [Submonoid.map_equiv_eq_comap_symm]
  simp only [MulEquiv.coe_toMonoidHom, RingEquiv.toMulEquiv_eq_coe, Submonoid.mem_comap]
  constructor
  · rintro hx z (hz : z * h.symm x = 0)
    rw [← h.map_eq_zero_iff]
    apply hx
    simpa only [h.map_zero, h.apply_symm_apply, h.map_mul] using congr_arg h hz
  · rintro (hx : h.symm x ∈ _) z hz
    rw [← h.symm.map_eq_zero_iff]
    apply hx
    rw [← h.symm.map_mul, hz, h.symm.map_zero]
#align is_fraction_ring.is_fraction_ring_iff_of_base_ring_equiv IsFractionRing.isFractionRing_iff_of_base_ringEquiv
-/

#print IsFractionRing.nontrivial /-
protected theorem nontrivial (R S : Type _) [CommRing R] [Nontrivial R] [CommRing S] [Algebra R S]
    [IsFractionRing R S] : Nontrivial S :=
  by
  apply nontrivial_of_ne
  intro h
  apply @zero_ne_one R
  exact
    IsLocalization.injective S (le_of_eq rfl)
      (((algebraMap R S).map_zero.trans h).trans (algebraMap R S).map_one.symm)
#align is_fraction_ring.nontrivial IsFractionRing.nontrivial
-/

end IsFractionRing

variable (R A)

#print FractionRing /-
/-- The fraction ring of a commutative ring `R` as a quotient type.

We instantiate this definition as generally as possible, and assume that the
commutative ring `R` is an integral domain only when this is needed for proving.
-/
@[reducible]
def FractionRing :=
  Localization (nonZeroDivisors R)
#align fraction_ring FractionRing
-/

namespace FractionRing

#print FractionRing.unique /-
instance unique [Subsingleton R] : Unique (FractionRing R) :=
  Localization.unique
#align fraction_ring.unique FractionRing.unique
-/

instance [Nontrivial R] : Nontrivial (FractionRing R) :=
  ⟨⟨(algebraMap R _) 0, (algebraMap _ _) 1, fun H =>
      zero_ne_one (IsLocalization.injective _ le_rfl H)⟩⟩

variable {A}

noncomputable instance : Field (FractionRing A) :=
  { Localization.commRing,
    IsFractionRing.toField A with
    add := (· + ·)
    mul := (· * ·)
    neg := Neg.neg
    sub := Sub.sub
    one := 1
    zero := 0
    nsmul := AddMonoid.nsmul
    zsmul := SubNegMonoid.zsmul
    npow := Localization.npow _ }

#print FractionRing.mk_eq_div /-
@[simp]
theorem mk_eq_div {r s} :
    (Localization.mk r s : FractionRing A) =
      (algebraMap _ _ r / algebraMap A _ s : FractionRing A) :=
  by rw [Localization.mk_eq_mk', IsFractionRing.mk'_eq_div]
#align fraction_ring.mk_eq_div FractionRing.mk_eq_div
-/

noncomputable instance [IsDomain R] [Field K] [Algebra R K] [NoZeroSMulDivisors R K] :
    Algebra (FractionRing R) K :=
  RingHom.toAlgebra (IsFractionRing.lift (NoZeroSMulDivisors.algebraMap_injective R _))

instance [IsDomain R] [Field K] [Algebra R K] [NoZeroSMulDivisors R K] :
    IsScalarTower R (FractionRing R) K :=
  IsScalarTower.of_algebraMap_eq fun x => (IsFractionRing.lift_algebraMap _ x).symm

variable (A)

#print FractionRing.algEquiv /-
/-- Given an integral domain `A` and a localization map to a field of fractions
`f : A →+* K`, we get an `A`-isomorphism between the field of fractions of `A` as a quotient
type and `K`. -/
noncomputable def algEquiv (K : Type _) [Field K] [Algebra A K] [IsFractionRing A K] :
    FractionRing A ≃ₐ[A] K :=
  Localization.algEquiv (nonZeroDivisors A) K
#align fraction_ring.alg_equiv FractionRing.algEquiv
-/

instance [Algebra R A] [NoZeroSMulDivisors R A] : NoZeroSMulDivisors R (FractionRing A) :=
  NoZeroSMulDivisors.of_algebraMap_injective
    (by
      rw [IsScalarTower.algebraMap_eq R A]
      exact
        Function.Injective.comp (NoZeroSMulDivisors.algebraMap_injective _ _)
          (NoZeroSMulDivisors.algebraMap_injective _ _))

end FractionRing

