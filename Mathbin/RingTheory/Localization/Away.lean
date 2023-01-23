/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Mario Carneiro, Johan Commelin, Amelia Livingston, Anne Baanen

! This file was ported from Lean 3 source module ring_theory.localization.away
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.AdjoinRoot
import Mathbin.RingTheory.Localization.Basic

/-!
# Localizations away from an element

## Main definitions

 * `is_localization.away (x : R) S` expresses that `S` is a localization away from `x`, as an
   abbreviation of `is_localization (submonoid.powers x) S`

## Implementation notes

See `src/ring_theory/localization/basic.lean` for a design overview.

## Tags
localization, ring localization, commutative ring localization, characteristic predicate,
commutative ring, field of fractions
-/


section CommSemiring

variable {R : Type _} [CommSemiring R] (M : Submonoid R) {S : Type _} [CommSemiring S]

variable [Algebra R S] {P : Type _} [CommSemiring P]

namespace IsLocalization

section Away

variable (x : R)

/-- Given `x : R`, the typeclass `is_localization.away x S` states that `S` is
isomorphic to the localization of `R` at the submonoid generated by `x`. -/
abbrev Away (S : Type _) [CommSemiring S] [Algebra R S] :=
  IsLocalization (Submonoid.powers x) S
#align is_localization.away IsLocalization.Away

namespace Away

variable [IsLocalization.Away x S]

/-- Given `x : R` and a localization map `F : R →+* S` away from `x`, `inv_self` is `(F x)⁻¹`. -/
noncomputable def invSelf : S :=
  mk' S (1 : R) ⟨x, Submonoid.mem_powers _⟩
#align is_localization.away.inv_self IsLocalization.Away.invSelf

@[simp]
theorem mul_invSelf : algebraMap R S x * invSelf x = 1 :=
  by
  convert IsLocalization.mk'_mul_mk'_eq_one _ 1
  symm
  apply IsLocalization.mk'_one
#align is_localization.away.mul_inv_self IsLocalization.Away.mul_invSelf

variable {g : R →+* P}

/-- Given `x : R`, a localization map `F : R →+* S` away from `x`, and a map of `comm_semiring`s
`g : R →+* P` such that `g x` is invertible, the homomorphism induced from `S` to `P` sending
`z : S` to `g y * (g x)⁻ⁿ`, where `y : R, n : ℕ` are such that `z = F y * (F x)⁻ⁿ`. -/
noncomputable def lift (hg : IsUnit (g x)) : S →+* P :=
  IsLocalization.lift fun y : Submonoid.powers x =>
    show IsUnit (g y.1) by
      obtain ⟨n, hn⟩ := y.2
      rw [← hn, g.map_pow]
      exact IsUnit.map (powMonoidHom n : P →* P) hg
#align is_localization.away.lift IsLocalization.Away.lift

@[simp]
theorem AwayMap.lift_eq (hg : IsUnit (g x)) (a : R) : lift x hg ((algebraMap R S) a) = g a :=
  lift_eq _ _
#align is_localization.away.away_map.lift_eq IsLocalization.Away.AwayMap.lift_eq

@[simp]
theorem AwayMap.lift_comp (hg : IsUnit (g x)) : (lift x hg).comp (algebraMap R S) = g :=
  lift_comp _
#align is_localization.away.away_map.lift_comp IsLocalization.Away.AwayMap.lift_comp

/-- Given `x y : R` and localizations `S`, `P` away from `x` and `x * y`
respectively, the homomorphism induced from `S` to `P`. -/
noncomputable def awayToAwayRight (y : R) [Algebra R P] [IsLocalization.Away (x * y) P] : S →+* P :=
  lift x <|
    show IsUnit ((algebraMap R P) x) from
      isUnit_of_mul_eq_one ((algebraMap R P) x) (mk' P y ⟨x * y, Submonoid.mem_powers _⟩) <| by
        rw [mul_mk'_eq_mk'_of_mul, mk'_self]
#align is_localization.away.away_to_away_right IsLocalization.Away.awayToAwayRight

variable (S) (Q : Type _) [CommSemiring Q] [Algebra P Q]

/-- Given a map `f : R →+* S` and an element `r : R`, we may construct a map `Rᵣ →+* Sᵣ`. -/
noncomputable def map (f : R →+* P) (r : R) [IsLocalization.Away r S]
    [IsLocalization.Away (f r) Q] : S →+* Q :=
  IsLocalization.map Q f
    (show Submonoid.powers r ≤ (Submonoid.powers (f r)).comap f
      by
      rintro x ⟨n, rfl⟩
      use n
      simp)
#align is_localization.away.map IsLocalization.Away.map

end Away

end Away

variable [IsLocalization M S]

section AtUnits

variable (R) (S) (M)

/-- The localization at a module of units is isomorphic to the ring -/
noncomputable def atUnits (H : ∀ x : M, IsUnit (x : R)) : R ≃ₐ[R] S :=
  by
  refine' AlgEquiv.ofBijective (Algebra.ofId R S) ⟨_, _⟩
  · intro x y hxy
    obtain ⟨c, eq⟩ := (IsLocalization.eq_iff_exists M S).mp hxy
    obtain ⟨u, hu⟩ := H c
    rwa [← hu, Units.mul_right_inj] at eq
  · intro y
    obtain ⟨⟨x, s⟩, eq⟩ := IsLocalization.surj M y
    obtain ⟨u, hu⟩ := H s
    use x * u.inv
    dsimp only [Algebra.ofId, RingHom.toFun_eq_coe, AlgHom.coe_mk]
    rw [RingHom.map_mul, ← Eq, ← hu, mul_assoc, ← RingHom.map_mul]
    simp
#align is_localization.at_units IsLocalization.atUnits

/-- The localization away from a unit is isomorphic to the ring -/
noncomputable def atUnit (x : R) (e : IsUnit x) [IsLocalization.Away x S] : R ≃ₐ[R] S :=
  by
  apply at_units R (Submonoid.powers x)
  rintro ⟨xn, n, hxn⟩
  obtain ⟨u, hu⟩ := e
  rw [isUnit_iff_exists_inv]
  use u.inv ^ n
  simp [← hxn, ← hu, ← mul_pow]
#align is_localization.at_unit IsLocalization.atUnit

/-- The localization at one is isomorphic to the ring. -/
noncomputable def atOne [IsLocalization.Away (1 : R) S] : R ≃ₐ[R] S :=
  @atUnit R _ S _ _ (1 : R) isUnit_one _
#align is_localization.at_one IsLocalization.atOne

theorem away_of_isUnit_of_bijective {R : Type _} (S : Type _) [CommRing R] [CommRing S]
    [Algebra R S] {r : R} (hr : IsUnit r) (H : Function.Bijective (algebraMap R S)) :
    IsLocalization.Away r S :=
  { map_units := by
      rintro ⟨_, n, rfl⟩
      exact (algebraMap R S).is_unit_map (hr.pow _)
    surj := fun z => by
      obtain ⟨z', rfl⟩ := H.2 z
      exact ⟨⟨z', 1⟩, by simp⟩
    eq_iff_exists := fun x y => by
      erw [H.1.eq_iff]
      constructor
      · rintro rfl
        exact ⟨1, rfl⟩
      · rintro ⟨⟨_, n, rfl⟩, e⟩
        exact (hr.pow _).mul_right_inj.mp e }
#align is_localization.away_of_is_unit_of_bijective IsLocalization.away_of_isUnit_of_bijective

end AtUnits

end IsLocalization

namespace Localization

open IsLocalization

variable {M}

/-- Given a map `f : R →+* S` and an element `r : R`, such that `f r` is invertible,
  we may construct a map `Rᵣ →+* S`. -/
noncomputable abbrev awayLift (f : R →+* P) (r : R) (hr : IsUnit (f r)) :
    Localization.Away r →+* P :=
  IsLocalization.Away.lift r hr
#align localization.away_lift Localization.awayLift

/-- Given a map `f : R →+* S` and an element `r : R`, we may construct a map `Rᵣ →+* Sᵣ`. -/
noncomputable abbrev awayMap (f : R →+* P) (r : R) :
    Localization.Away r →+* Localization.Away (f r) :=
  IsLocalization.Away.map _ _ f r
#align localization.away_map Localization.awayMap

end Localization

end CommSemiring

open Polynomial AdjoinRoot Localization

variable {R : Type _} [CommRing R]

attribute [local instance] IsLocalization.algHom_subsingleton AdjoinRoot.algHom_subsingleton

/-- The `R`-`alg_equiv` between the localization of `R` away from `r` and
    `R` with an inverse of `r` adjoined. -/
noncomputable def Localization.awayEquivAdjoin (r : R) : Away r ≃ₐ[R] AdjoinRoot (c r * X - 1) :=
  AlgEquiv.ofAlgHom
    { awayLift _ r _ with
      commutes' :=
        IsLocalization.Away.AwayMap.lift_eq r (isUnit_of_mul_eq_one _ _ <| root_is_inv r) }
    (liftHom _ (IsLocalization.Away.invSelf r) <| by
      simp only [map_sub, map_mul, aeval_C, aeval_X, IsLocalization.Away.mul_invSelf, aeval_one,
        sub_self])
    (Subsingleton.elim _ _) (Subsingleton.elim _ _)
#align localization.away_equiv_adjoin Localization.awayEquivAdjoin

theorem IsLocalization.adjoin_inv (r : R) : IsLocalization.Away r (AdjoinRoot <| c r * X - 1) :=
  IsLocalization.isLocalization_of_algEquiv _ (Localization.awayEquivAdjoin r)
#align is_localization.adjoin_inv IsLocalization.adjoin_inv

theorem IsLocalization.Away.finitePresentation (r : R) {S} [CommRing S] [Algebra R S]
    [IsLocalization.Away r S] : Algebra.FinitePresentation R S :=
  (AdjoinRoot.finitePresentation _).Equiv <|
    (Localization.awayEquivAdjoin r).symm.trans <| IsLocalization.algEquiv (Submonoid.powers r) _ _
#align is_localization.away.finite_presentation IsLocalization.Away.finitePresentation

