/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Mario Carneiro, Johan Commelin, Amelia Livingston, Anne Baanen

! This file was ported from Lean 3 source module ring_theory.localization.at_prime
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Ideal.LocalRing
import Mathbin.RingTheory.Localization.Ideal

/-!
# Localizations of commutative rings at the complement of a prime ideal

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

 * `is_localization.at_prime (I : ideal R) [is_prime I] (S : Type*)` expresses that `S` is a
   localization at (the complement of) a prime ideal `I`, as an abbreviation of
   `is_localization I.prime_compl S`

## Main results

 * `is_localization.at_prime.local_ring`: a theorem (not an instance) stating a localization at the
   complement of a prime ideal is a local ring

## Implementation notes

See `src/ring_theory/localization/basic.lean` for a design overview.

## Tags
localization, ring localization, commutative ring localization, characteristic predicate,
commutative ring, field of fractions
-/


variable {R : Type _} [CommSemiring R] (M : Submonoid R) (S : Type _) [CommSemiring S]

variable [Algebra R S] {P : Type _} [CommSemiring P]

section AtPrime

variable (I : Ideal R) [hp : I.IsPrime]

namespace Ideal

#print Ideal.primeCompl /-
/-- The complement of a prime ideal `I ⊆ R` is a submonoid of `R`. -/
def primeCompl : Submonoid R where
  carrier := (Iᶜ : Set R)
  one_mem' := by convert I.ne_top_iff_one.1 hp.1 <;> rfl
  mul_mem' x y hnx hny hxy := Or.cases_on (hp.mem_or_mem hxy) hnx hny
#align ideal.prime_compl Ideal.primeCompl
-/

#print Ideal.primeCompl_le_nonZeroDivisors /-
theorem primeCompl_le_nonZeroDivisors [NoZeroDivisors R] : I.primeCompl ≤ nonZeroDivisors R :=
  le_nonZeroDivisors_of_noZeroDivisors <| not_not_intro I.zero_mem
#align ideal.prime_compl_le_non_zero_divisors Ideal.primeCompl_le_nonZeroDivisors
-/

end Ideal

variable (S)

#print IsLocalization.AtPrime /-
/-- Given a prime ideal `P`, the typeclass `is_localization.at_prime S P` states that `S` is
isomorphic to the localization of `R` at the complement of `P`. -/
protected abbrev IsLocalization.AtPrime :=
  IsLocalization I.primeCompl S
#align is_localization.at_prime IsLocalization.AtPrime
-/

#print Localization.AtPrime /-
/-- Given a prime ideal `P`, `localization.at_prime S P` is a localization of
`R` at the complement of `P`, as a quotient type. -/
protected abbrev Localization.AtPrime :=
  Localization I.primeCompl
#align localization.at_prime Localization.AtPrime
-/

namespace IsLocalization

#print IsLocalization.AtPrime.Nontrivial /-
theorem AtPrime.Nontrivial [IsLocalization.AtPrime S I] : Nontrivial S :=
  nontrivial_of_ne (0 : S) 1 fun hze =>
    by
    rw [← (algebraMap R S).map_one, ← (algebraMap R S).map_zero] at hze 
    obtain ⟨t, ht⟩ := (eq_iff_exists I.prime_compl S).1 hze
    have htz : (t : R) = 0 := by simpa using ht.symm
    exact t.2 (htz.symm ▸ I.zero_mem : ↑t ∈ I)
#align is_localization.at_prime.nontrivial IsLocalization.AtPrime.Nontrivial
-/

attribute [local instance] at_prime.nontrivial

#print IsLocalization.AtPrime.localRing /-
theorem AtPrime.localRing [IsLocalization.AtPrime S I] : LocalRing S :=
  LocalRing.of_nonunits_add
    (by
      intro x y hx hy hu
      cases' isUnit_iff_exists_inv.1 hu with z hxyz
      have : ∀ {r : R} {s : I.prime_compl}, mk' S r s ∈ nonunits S → r ∈ I :=
        fun (r : R) (s : I.prime_compl) =>
        not_imp_comm.1 fun nr =>
          isUnit_iff_exists_inv.2 ⟨mk' S ↑s (⟨r, nr⟩ : I.prime_compl), mk'_mul_mk'_eq_one' _ _ nr⟩
      rcases mk'_surjective I.prime_compl x with ⟨rx, sx, hrx⟩
      rcases mk'_surjective I.prime_compl y with ⟨ry, sy, hry⟩
      rcases mk'_surjective I.prime_compl z with ⟨rz, sz, hrz⟩
      rw [← hrx, ← hry, ← hrz, ← mk'_add, ← mk'_mul, ← mk'_self S I.prime_compl.one_mem] at hxyz 
      rw [← hrx] at hx ; rw [← hry] at hy 
      obtain ⟨t, ht⟩ := IsLocalization.eq.1 hxyz
      simp only [mul_one, one_mul, Submonoid.coe_mul, Subtype.coe_mk] at ht 
      suffices : ↑t * (↑sx * ↑sy * ↑sz) ∈ I;
      exact
        not_or_of_not (mt hp.mem_or_mem <| not_or_of_not sx.2 sy.2) sz.2
          (hp.mem_or_mem <| (hp.mem_or_mem this).resolve_left t.2)
      rw [← ht]
      exact
        I.mul_mem_left _
          (I.mul_mem_right _
            (I.add_mem (I.mul_mem_right _ <| this hx) (I.mul_mem_right _ <| this hy))))
#align is_localization.at_prime.local_ring IsLocalization.AtPrime.localRing
-/

end IsLocalization

namespace Localization

#print Localization.AtPrime.localRing /-
/-- The localization of `R` at the complement of a prime ideal is a local ring. -/
instance AtPrime.localRing : LocalRing (Localization I.primeCompl) :=
  IsLocalization.AtPrime.localRing (Localization I.primeCompl) I
#align localization.at_prime.local_ring Localization.AtPrime.localRing
-/

end Localization

end AtPrime

namespace IsLocalization

variable {A : Type _} [CommRing A] [IsDomain A]

#print IsLocalization.isDomain_of_local_atPrime /-
/-- The localization of an integral domain at the complement of a prime ideal is an integral domain.
-/
instance isDomain_of_local_atPrime {P : Ideal A} (hp : P.IsPrime) :
    IsDomain (Localization.AtPrime P) :=
  isDomain_localization P.primeCompl_le_nonZeroDivisors
#align is_localization.is_domain_of_local_at_prime IsLocalization.isDomain_of_local_atPrime
-/

namespace AtPrime

variable (I : Ideal R) [hI : I.IsPrime] [IsLocalization.AtPrime S I]

#print IsLocalization.AtPrime.isUnit_to_map_iff /-
theorem isUnit_to_map_iff (x : R) : IsUnit ((algebraMap R S) x) ↔ x ∈ I.primeCompl :=
  ⟨fun h hx =>
    (isPrime_of_isPrime_disjoint I.primeCompl S I hI disjoint_compl_left).ne_top <|
      (Ideal.map (algebraMap R S) I).eq_top_of_isUnit_mem (Ideal.mem_map_of_mem _ hx) h,
    fun h => map_units S ⟨x, h⟩⟩
#align is_localization.at_prime.is_unit_to_map_iff IsLocalization.AtPrime.isUnit_to_map_iff
-/

#print IsLocalization.AtPrime.to_map_mem_maximal_iff /-
-- Can't use typeclasses to infer the `local_ring` instance, so use an `opt_param` instead
-- (since `local_ring` is a `Prop`, there should be no unification issues.)
theorem to_map_mem_maximal_iff (x : R) (h : LocalRing S := localRing S I) :
    algebraMap R S x ∈ LocalRing.maximalIdeal S ↔ x ∈ I :=
  not_iff_not.mp <| by
    simpa only [LocalRing.mem_maximalIdeal, mem_nonunits_iff, Classical.not_not] using
      is_unit_to_map_iff S I x
#align is_localization.at_prime.to_map_mem_maximal_iff IsLocalization.AtPrime.to_map_mem_maximal_iff
-/

#print IsLocalization.AtPrime.comap_maximalIdeal /-
theorem comap_maximalIdeal (h : LocalRing S := localRing S I) :
    (LocalRing.maximalIdeal S).comap (algebraMap R S) = I :=
  Ideal.ext fun x => by simpa only [Ideal.mem_comap] using to_map_mem_maximal_iff _ I x
#align is_localization.at_prime.comap_maximal_ideal IsLocalization.AtPrime.comap_maximalIdeal
-/

#print IsLocalization.AtPrime.isUnit_mk'_iff /-
theorem isUnit_mk'_iff (x : R) (y : I.primeCompl) : IsUnit (mk' S x y) ↔ x ∈ I.primeCompl :=
  ⟨fun h hx => mk'_mem_iff.mpr ((to_map_mem_maximal_iff S I x).mpr hx) h, fun h =>
    isUnit_iff_exists_inv.mpr ⟨mk' S ↑y ⟨x, h⟩, mk'_mul_mk'_eq_one ⟨x, h⟩ y⟩⟩
#align is_localization.at_prime.is_unit_mk'_iff IsLocalization.AtPrime.isUnit_mk'_iff
-/

#print IsLocalization.AtPrime.mk'_mem_maximal_iff /-
theorem mk'_mem_maximal_iff (x : R) (y : I.primeCompl) (h : LocalRing S := localRing S I) :
    mk' S x y ∈ LocalRing.maximalIdeal S ↔ x ∈ I :=
  not_iff_not.mp <| by
    simpa only [LocalRing.mem_maximalIdeal, mem_nonunits_iff, Classical.not_not] using
      is_unit_mk'_iff S I x y
#align is_localization.at_prime.mk'_mem_maximal_iff IsLocalization.AtPrime.mk'_mem_maximal_iff
-/

end AtPrime

end IsLocalization

namespace Localization

open IsLocalization

attribute [local instance] Classical.propDecidable

variable (I : Ideal R) [hI : I.IsPrime]

variable {I}

#print Localization.AtPrime.comap_maximalIdeal /-
/-- The unique maximal ideal of the localization at `I.prime_compl` lies over the ideal `I`. -/
theorem AtPrime.comap_maximalIdeal :
    Ideal.comap (algebraMap R (Localization.AtPrime I))
        (LocalRing.maximalIdeal (Localization I.primeCompl)) =
      I :=
  AtPrime.comap_maximalIdeal _ _
#align localization.at_prime.comap_maximal_ideal Localization.AtPrime.comap_maximalIdeal
-/

#print Localization.AtPrime.map_eq_maximalIdeal /-
/-- The image of `I` in the localization at `I.prime_compl` is a maximal ideal, and in particular
it is the unique maximal ideal given by the local ring structure `at_prime.local_ring` -/
theorem AtPrime.map_eq_maximalIdeal :
    Ideal.map (algebraMap R (Localization.AtPrime I)) I =
      LocalRing.maximalIdeal (Localization I.primeCompl) :=
  by
  convert congr_arg (Ideal.map _) at_prime.comap_maximal_ideal.symm
  rw [map_comap I.prime_compl]
#align localization.at_prime.map_eq_maximal_ideal Localization.AtPrime.map_eq_maximalIdeal
-/

#print Localization.le_comap_primeCompl_iff /-
theorem le_comap_primeCompl_iff {J : Ideal P} [hJ : J.IsPrime] {f : R →+* P} :
    I.primeCompl ≤ J.primeCompl.comap f ↔ J.comap f ≤ I :=
  ⟨fun h x hx => by contrapose! hx; exact h hx, fun h x hx hfxJ => hx (h hfxJ)⟩
#align localization.le_comap_prime_compl_iff Localization.le_comap_primeCompl_iff
-/

variable (I)

#print Localization.localRingHom /-
/-- For a ring hom `f : R →+* S` and a prime ideal `J` in `S`, the induced ring hom from the
localization of `R` at `J.comap f` to the localization of `S` at `J`.

To make this definition more flexible, we allow any ideal `I` of `R` as input, together with a proof
that `I = J.comap f`. This can be useful when `I` is not definitionally equal to `J.comap f`.
 -/
noncomputable def localRingHom (J : Ideal P) [hJ : J.IsPrime] (f : R →+* P) (hIJ : I = J.comap f) :
    Localization.AtPrime I →+* Localization.AtPrime J :=
  IsLocalization.map (Localization.AtPrime J) f (le_comap_primeCompl_iff.mpr (ge_of_eq hIJ))
#align localization.local_ring_hom Localization.localRingHom
-/

#print Localization.localRingHom_to_map /-
theorem localRingHom_to_map (J : Ideal P) [hJ : J.IsPrime] (f : R →+* P) (hIJ : I = J.comap f)
    (x : R) : localRingHom I J f hIJ (algebraMap _ _ x) = algebraMap _ _ (f x) :=
  map_eq _ _
#align localization.local_ring_hom_to_map Localization.localRingHom_to_map
-/

#print Localization.localRingHom_mk' /-
theorem localRingHom_mk' (J : Ideal P) [hJ : J.IsPrime] (f : R →+* P) (hIJ : I = J.comap f) (x : R)
    (y : I.primeCompl) :
    localRingHom I J f hIJ (IsLocalization.mk' _ x y) =
      IsLocalization.mk' (Localization.AtPrime J) (f x)
        (⟨f y, le_comap_primeCompl_iff.mpr (ge_of_eq hIJ) y.2⟩ : J.primeCompl) :=
  map_mk' _ _ _
#align localization.local_ring_hom_mk' Localization.localRingHom_mk'
-/

#print Localization.isLocalRingHom_localRingHom /-
instance isLocalRingHom_localRingHom (J : Ideal P) [hJ : J.IsPrime] (f : R →+* P)
    (hIJ : I = J.comap f) : IsLocalRingHom (localRingHom I J f hIJ) :=
  IsLocalRingHom.mk fun x hx =>
    by
    rcases IsLocalization.mk'_surjective I.prime_compl x with ⟨r, s, rfl⟩
    rw [local_ring_hom_mk'] at hx 
    rw [at_prime.is_unit_mk'_iff] at hx ⊢
    exact fun hr => hx ((set_like.ext_iff.mp hIJ r).mp hr)
#align localization.is_local_ring_hom_local_ring_hom Localization.isLocalRingHom_localRingHom
-/

#print Localization.localRingHom_unique /-
theorem localRingHom_unique (J : Ideal P) [hJ : J.IsPrime] (f : R →+* P) (hIJ : I = J.comap f)
    {j : Localization.AtPrime I →+* Localization.AtPrime J}
    (hj : ∀ x : R, j (algebraMap _ _ x) = algebraMap _ _ (f x)) : localRingHom I J f hIJ = j :=
  map_unique _ _ hj
#align localization.local_ring_hom_unique Localization.localRingHom_unique
-/

#print Localization.localRingHom_id /-
@[simp]
theorem localRingHom_id : localRingHom I I (RingHom.id R) (Ideal.comap_id I).symm = RingHom.id _ :=
  localRingHom_unique _ _ _ _ fun x => rfl
#align localization.local_ring_hom_id Localization.localRingHom_id
-/

#print Localization.localRingHom_comp /-
@[simp]
theorem localRingHom_comp {S : Type _} [CommSemiring S] (J : Ideal S) [hJ : J.IsPrime] (K : Ideal P)
    [hK : K.IsPrime] (f : R →+* S) (hIJ : I = J.comap f) (g : S →+* P) (hJK : J = K.comap g) :
    localRingHom I K (g.comp f) (by rw [hIJ, hJK, Ideal.comap_comap f g]) =
      (localRingHom J K g hJK).comp (localRingHom I J f hIJ) :=
  localRingHom_unique _ _ _ _ fun r => by
    simp only [Function.comp_apply, RingHom.coe_comp, local_ring_hom_to_map]
#align localization.local_ring_hom_comp Localization.localRingHom_comp
-/

end Localization

