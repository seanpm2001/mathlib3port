/-
Copyright (c) 2019 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca, Paul Lezeau, Junyan Xu

! This file was ported from Lean 3 source module field_theory.minpoly.is_integrally_closed
! leanprover-community/mathlib commit 2a0ce625dbb0ffbc7d1316597de0b25c1ec75303
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.AdjoinRoot
import Mathbin.FieldTheory.Minpoly.Field
import Mathbin.RingTheory.Polynomial.GaussLemma

/-!
# Minimal polynomials over a GCD monoid

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file specializes the theory of minpoly to the case of an algebra over a GCD monoid.

## Main results

 * `is_integrally_closed_eq_field_fractions`: For integrally closed domains, the minimal polynomial
    over the ring is the same as the minimal polynomial over the fraction field.

 * `is_integrally_closed_dvd` : For integrally closed domains, the minimal polynomial divides any
    primitive polynomial that has the integral element as root.

 * `is_integrally_closed_unique` : The minimal polynomial of an element `x` is uniquely
    characterized by its defining property: if there is another monic polynomial of minimal degree
    that has `x` as a root, then this polynomial is equal to the minimal polynomial of `x`.

-/


open scoped Classical Polynomial

open Polynomial Set Function minpoly

namespace minpoly

variable {R S : Type _} [CommRing R] [CommRing S] [IsDomain R] [Algebra R S]

section

variable (K L : Type _) [Field K] [Algebra R K] [IsFractionRing R K] [Field L] [Algebra R L]
  [Algebra S L] [Algebra K L] [IsScalarTower R K L] [IsScalarTower R S L]

variable [IsIntegrallyClosed R]

#print minpoly.isIntegrallyClosed_eq_field_fractions /-
/-- For integrally closed domains, the minimal polynomial over the ring is the same as the minimal
polynomial over the fraction field. See `minpoly.is_integrally_closed_eq_field_fractions'` if
`S` is already a `K`-algebra. -/
theorem isIntegrallyClosed_eq_field_fractions [IsDomain S] {s : S} (hs : IsIntegral R s) :
    minpoly K (algebraMap S L s) = (minpoly R s).map (algebraMap R K) :=
  by
  refine' (eq_of_irreducible_of_monic _ _ _).symm
  ·
    exact
      (Polynomial.Monic.irreducible_iff_irreducible_map_fraction_map (monic hs)).1 (Irreducible hs)
  · rw [aeval_map_algebra_map, aeval_algebra_map_apply, aeval, map_zero]
  · exact (monic hs).map _
#align minpoly.is_integrally_closed_eq_field_fractions minpoly.isIntegrallyClosed_eq_field_fractions
-/

#print minpoly.isIntegrallyClosed_eq_field_fractions' /-
/-- For integrally closed domains, the minimal polynomial over the ring is the same as the minimal
polynomial over the fraction field. Compared to `minpoly.is_integrally_closed_eq_field_fractions`,
this version is useful if the element is in a ring that is already a `K`-algebra. -/
theorem isIntegrallyClosed_eq_field_fractions' [IsDomain S] [Algebra K S] [IsScalarTower R K S]
    {s : S} (hs : IsIntegral R s) : minpoly K s = (minpoly R s).map (algebraMap R K) :=
  by
  let L := FractionRing S
  rw [← is_integrally_closed_eq_field_fractions K L hs]
  refine'
    minpoly.eq_of_algebraMap_eq (IsFractionRing.injective S L) (isIntegral_of_isScalarTower hs) rfl
#align minpoly.is_integrally_closed_eq_field_fractions' minpoly.isIntegrallyClosed_eq_field_fractions'
-/

end

variable [IsDomain S] [NoZeroSMulDivisors R S]

variable [IsIntegrallyClosed R]

#print minpoly.isIntegrallyClosed_dvd /-
/-- For integrally closed rings, the minimal polynomial divides any polynomial that has the
  integral element as root. See also `minpoly.dvd` which relaxes the assumptions on `S`
  in exchange for stronger assumptions on `R`. -/
theorem isIntegrallyClosed_dvd [Nontrivial R] {s : S} (hs : IsIntegral R s) {p : R[X]}
    (hp : Polynomial.aeval s p = 0) : minpoly R s ∣ p :=
  by
  let K := FractionRing R
  let L := FractionRing S
  have : minpoly K (algebraMap S L s) ∣ map (algebraMap R K) (p %ₘ minpoly R s) :=
    by
    rw [map_mod_by_monic _ (minpoly.monic hs), mod_by_monic_eq_sub_mul_div]
    refine' dvd_sub (minpoly.dvd K (algebraMap S L s) _) _
    rw [← map_aeval_eq_aeval_map, hp, map_zero]
    rw [← IsScalarTower.algebraMap_eq, ← IsScalarTower.algebraMap_eq]
    apply dvd_mul_of_dvd_left
    rw [is_integrally_closed_eq_field_fractions K L hs]
    exact monic.map _ (minpoly.monic hs)
  rw [is_integrally_closed_eq_field_fractions _ _ hs,
    map_dvd_map (algebraMap R K) (IsFractionRing.injective R K) (minpoly.monic hs)] at this 
  rw [← dvd_iff_mod_by_monic_eq_zero (minpoly.monic hs)]
  refine' Polynomial.eq_zero_of_dvd_of_degree_lt this (degree_mod_by_monic_lt p <| minpoly.monic hs)
  all_goals infer_instance
#align minpoly.is_integrally_closed_dvd minpoly.isIntegrallyClosed_dvd
-/

#print minpoly.isIntegrallyClosed_dvd_iff /-
theorem isIntegrallyClosed_dvd_iff [Nontrivial R] {s : S} (hs : IsIntegral R s) (p : R[X]) :
    Polynomial.aeval s p = 0 ↔ minpoly R s ∣ p :=
  ⟨fun hp => isIntegrallyClosed_dvd hs hp, fun hp => by
    simpa only [RingHom.mem_ker, RingHom.coe_comp, coe_eval_ring_hom, coe_map_ring_hom,
      Function.comp_apply, eval_map, ← aeval_def] using
      aeval_eq_zero_of_dvd_aeval_eq_zero hp (minpoly.aeval R s)⟩
#align minpoly.is_integrally_closed_dvd_iff minpoly.isIntegrallyClosed_dvd_iff
-/

#print minpoly.ker_eval /-
theorem ker_eval {s : S} (hs : IsIntegral R s) :
    ((Polynomial.aeval s).toRingHom : R[X] →+* S).ker = Ideal.span ({minpoly R s} : Set R[X]) := by
  ext p <;>
    simp_rw [RingHom.mem_ker, AlgHom.toRingHom_eq_coe, AlgHom.coe_toRingHom,
      is_integrally_closed_dvd_iff hs, ← Ideal.mem_span_singleton]
#align minpoly.ker_eval minpoly.ker_eval
-/

#print minpoly.IsIntegrallyClosed.degree_le_of_ne_zero /-
/-- If an element `x` is a root of a nonzero polynomial `p`, then the degree of `p` is at least the
degree of the minimal polynomial of `x`. See also `minpoly.degree_le_of_ne_zero` which relaxes the
assumptions on `S` in exchange for stronger assumptions on `R`. -/
theorem IsIntegrallyClosed.degree_le_of_ne_zero {s : S} (hs : IsIntegral R s) {p : R[X]}
    (hp0 : p ≠ 0) (hp : Polynomial.aeval s p = 0) : degree (minpoly R s) ≤ degree p :=
  by
  rw [degree_eq_nat_degree (minpoly.ne_zero hs), degree_eq_nat_degree hp0]
  norm_cast
  exact nat_degree_le_of_dvd ((is_integrally_closed_dvd_iff hs _).mp hp) hp0
#align minpoly.is_integrally_closed.degree_le_of_ne_zero minpoly.IsIntegrallyClosed.degree_le_of_ne_zero
-/

#print IsIntegrallyClosed.minpoly.unique /-
/-- The minimal polynomial of an element `x` is uniquely characterized by its defining property:
if there is another monic polynomial of minimal degree that has `x` as a root, then this polynomial
is equal to the minimal polynomial of `x`. See also `minpoly.unique` which relaxes the
assumptions on `S` in exchange for stronger assumptions on `R`. -/
theorem IsIntegrallyClosed.minpoly.unique {s : S} {P : R[X]} (hmo : P.Monic)
    (hP : Polynomial.aeval s P = 0)
    (Pmin : ∀ Q : R[X], Q.Monic → Polynomial.aeval s Q = 0 → degree P ≤ degree Q) :
    P = minpoly R s := by
  have hs : IsIntegral R s := ⟨P, hmo, hP⟩
  symm; apply eq_of_sub_eq_zero
  by_contra hnz
  have := is_integrally_closed.degree_le_of_ne_zero hs hnz (by simp [hP])
  contrapose! this
  refine' degree_sub_lt _ (NeZero hs) _
  · exact le_antisymm (min R s hmo hP) (Pmin (minpoly R s) (monic hs) (aeval R s))
  · rw [(monic hs).leadingCoeff, hmo.leading_coeff]
#align minpoly.is_integrally_closed.minpoly.unique IsIntegrallyClosed.minpoly.unique
-/

#print minpoly.prime_of_isIntegrallyClosed /-
theorem prime_of_isIntegrallyClosed {x : S} (hx : IsIntegral R x) : Prime (minpoly R x) :=
  by
  refine'
    ⟨(minpoly.monic hx).NeZero,
      ⟨by
        by_contra h_contra <;>
          exact (ne_of_lt (minpoly.degree_pos hx)) (degree_eq_zero_of_is_unit h_contra).symm,
        fun a b h => or_iff_not_imp_left.mpr fun h' => _⟩⟩
  rw [← minpoly.isIntegrallyClosed_dvd_iff hx] at h' h ⊢
  rw [aeval_mul] at h 
  exact eq_zero_of_ne_zero_of_mul_left_eq_zero h' h
#align minpoly.prime_of_is_integrally_closed minpoly.prime_of_isIntegrallyClosed
-/

section AdjoinRoot

noncomputable section

open Algebra Polynomial AdjoinRoot

variable {R} {x : S}

#print minpoly.ToAdjoin.injective /-
theorem ToAdjoin.injective (hx : IsIntegral R x) : Function.Injective (Minpoly.toAdjoin R x) :=
  by
  refine' (injective_iff_map_eq_zero _).2 fun P₁ hP₁ => _
  obtain ⟨P, hP⟩ := mk_surjective (minpoly.monic hx) P₁
  by_cases hPzero : P = 0
  · simpa [hPzero] using hP.symm
  rw [← hP, minpoly.to_adjoin_apply', lift_hom_mk, ← Subalgebra.coe_eq_zero, aeval_subalgebra_coe,
    SetLike.coe_mk, is_integrally_closed_dvd_iff hx] at hP₁ 
  obtain ⟨Q, hQ⟩ := hP₁
  rw [← hP, hQ, RingHom.map_mul, mk_self, MulZeroClass.zero_mul]
#align minpoly.to_adjoin.injective minpoly.ToAdjoin.injective
-/

#print minpoly.equivAdjoin /-
/-- The algebra isomorphism `adjoin_root (minpoly R x) ≃ₐ[R] adjoin R x` -/
@[simps]
def equivAdjoin (hx : IsIntegral R x) : AdjoinRoot (minpoly R x) ≃ₐ[R] adjoin R ({x} : Set S) :=
  AlgEquiv.ofBijective (Minpoly.toAdjoin R x)
    ⟨minpoly.ToAdjoin.injective hx, Minpoly.toAdjoin.surjective R x⟩
#align minpoly.equiv_adjoin minpoly.equivAdjoin
-/

#print Algebra.adjoin.powerBasis' /-
/-- The `power_basis` of `adjoin R {x}` given by `x`. See `algebra.adjoin.power_basis` for a version
over a field. -/
@[simps]
def Algebra.adjoin.powerBasis' (hx : IsIntegral R x) :
    PowerBasis R (Algebra.adjoin R ({x} : Set S)) :=
  PowerBasis.map (AdjoinRoot.powerBasis' (minpoly.monic hx)) (minpoly.equivAdjoin hx)
#align algebra.adjoin.power_basis' Algebra.adjoin.powerBasis'
-/

#print PowerBasis.ofGenMemAdjoin' /-
/-- The power basis given by `x` if `B.gen ∈ adjoin R {x}`. -/
@[simps]
noncomputable def PowerBasis.ofGenMemAdjoin' (B : PowerBasis R S) (hint : IsIntegral R x)
    (hx : B.gen ∈ adjoin R ({x} : Set S)) : PowerBasis R S :=
  (Algebra.adjoin.powerBasis' hint).map <|
    (Subalgebra.equivOfEq _ _ <| PowerBasis.adjoin_eq_top_of_gen_mem_adjoin hx).trans
      Subalgebra.topEquiv
#align power_basis.of_gen_mem_adjoin' PowerBasis.ofGenMemAdjoin'
-/

end AdjoinRoot

end minpoly

