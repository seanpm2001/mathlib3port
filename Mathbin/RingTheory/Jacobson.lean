/-
Copyright (c) 2020 Devon Tuma. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Devon Tuma

! This file was ported from Lean 3 source module ring_theory.jacobson
! leanprover-community/mathlib commit a7c017d750512a352b623b1824d75da5998457d0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Localization.Away.Basic
import Mathbin.RingTheory.Ideal.Over
import Mathbin.RingTheory.JacobsonIdeal

/-!
# Jacobson Rings
The following conditions are equivalent for a ring `R`:
1. Every radical ideal `I` is equal to its Jacobson radical
2. Every radical ideal `I` can be written as an intersection of maximal ideals
3. Every prime ideal `I` is equal to its Jacobson radical
Any ring satisfying any of these equivalent conditions is said to be Jacobson.
Some particular examples of Jacobson rings are also proven.
`is_jacobson_quotient` says that the quotient of a Jacobson ring is Jacobson.
`is_jacobson_localization` says the localization of a Jacobson ring to a single element is Jacobson.
`is_jacobson_polynomial_iff_is_jacobson` says polynomials over a Jacobson ring form a Jacobson ring.
## Main definitions
Let `R` be a commutative ring. Jacobson Rings are defined using the first of the above conditions
* `is_jacobson R` is the proposition that `R` is a Jacobson ring. It is a class,
  implemented as the predicate that for any ideal, `I.is_radical` implies `I.jacobson = I`.

## Main statements
* `is_jacobson_iff_prime_eq` is the equivalence between conditions 1 and 3 above.
* `is_jacobson_iff_Inf_maximal` is the equivalence between conditions 1 and 2 above.
* `is_jacobson_of_surjective` says that if `R` is a Jacobson ring and `f : R →+* S` is surjective,
  then `S` is also a Jacobson ring
* `is_jacobson_mv_polynomial` says that multi-variate polynomials over a Jacobson ring are Jacobson.
## Tags
Jacobson, Jacobson Ring
-/


namespace Ideal

open Polynomial

open scoped Polynomial

section IsJacobson

variable {R S : Type _} [CommRing R] [CommRing S] {I : Ideal R}

/-- A ring is a Jacobson ring if for every radical ideal `I`,
 the Jacobson radical of `I` is equal to `I`.
 See `is_jacobson_iff_prime_eq` and `is_jacobson_iff_Inf_maximal` for equivalent definitions. -/
class IsJacobson (R : Type _) [CommRing R] : Prop where
  out' : ∀ I : Ideal R, I.IsRadical → I.jacobson = I
#align ideal.is_jacobson Ideal.IsJacobson

theorem isJacobson_iff {R} [CommRing R] :
    IsJacobson R ↔ ∀ I : Ideal R, I.IsRadical → I.jacobson = I :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩
#align ideal.is_jacobson_iff Ideal.isJacobson_iff

theorem IsJacobson.out {R} [CommRing R] :
    IsJacobson R → ∀ {I : Ideal R}, I.IsRadical → I.jacobson = I :=
  isJacobson_iff.1
#align ideal.is_jacobson.out Ideal.IsJacobson.out

/-- A ring is a Jacobson ring if and only if for all prime ideals `P`,
 the Jacobson radical of `P` is equal to `P`. -/
theorem isJacobson_iff_prime_eq : IsJacobson R ↔ ∀ P : Ideal R, IsPrime P → P.jacobson = P :=
  by
  refine' is_jacobson_iff.trans ⟨fun h I hI => h I hI.IsRadical, _⟩
  refine' fun h I hI => le_antisymm (fun x hx => _) fun x hx => mem_Inf.mpr fun _ hJ => hJ.left hx
  rw [← hI.radical, radical_eq_Inf I, mem_Inf]
  intro P hP
  rw [Set.mem_setOf_eq] at hP 
  erw [mem_Inf] at hx 
  erw [← h P hP.right, mem_Inf]
  exact fun J hJ => hx ⟨le_trans hP.left hJ.left, hJ.right⟩
#align ideal.is_jacobson_iff_prime_eq Ideal.isJacobson_iff_prime_eq

/-- A ring `R` is Jacobson if and only if for every prime ideal `I`,
 `I` can be written as the infimum of some collection of maximal ideals.
 Allowing ⊤ in the set `M` of maximal ideals is equivalent, but makes some proofs cleaner. -/
theorem isJacobson_iff_sInf_maximal :
    IsJacobson R ↔
      ∀ {I : Ideal R},
        I.IsPrime → ∃ M : Set (Ideal R), (∀ J ∈ M, IsMaximal J ∨ J = ⊤) ∧ I = sInf M :=
  ⟨fun H I h => eq_jacobson_iff_sInf_maximal.1 (H.out h.IsRadical), fun H =>
    isJacobson_iff_prime_eq.2 fun P hP => eq_jacobson_iff_sInf_maximal.2 (H hP)⟩
#align ideal.is_jacobson_iff_Inf_maximal Ideal.isJacobson_iff_sInf_maximal

theorem isJacobson_iff_sInf_maximal' :
    IsJacobson R ↔
      ∀ {I : Ideal R},
        I.IsPrime → ∃ M : Set (Ideal R), (∀ J ∈ M, ∀ (K : Ideal R), J < K → K = ⊤) ∧ I = sInf M :=
  ⟨fun H I h => eq_jacobson_iff_sInf_maximal'.1 (H.out h.IsRadical), fun H =>
    isJacobson_iff_prime_eq.2 fun P hP => eq_jacobson_iff_sInf_maximal'.2 (H hP)⟩
#align ideal.is_jacobson_iff_Inf_maximal' Ideal.isJacobson_iff_sInf_maximal'

theorem radical_eq_jacobson [H : IsJacobson R] (I : Ideal R) : I.radical = I.jacobson :=
  le_antisymm (le_sInf fun J ⟨hJ, hJ_max⟩ => (IsPrime.radical_le_iff hJ_max.IsPrime).mpr hJ)
    (H.out (radical_isRadical I) ▸ jacobson_mono le_radical)
#align ideal.radical_eq_jacobson Ideal.radical_eq_jacobson

/-- Fields have only two ideals, and the condition holds for both of them.  -/
instance (priority := 100) isJacobson_field {K : Type _} [Field K] : IsJacobson K :=
  ⟨fun I hI =>
    Or.rec_on (eq_bot_or_top I)
      (fun h => le_antisymm (sInf_le ⟨le_rfl, h.symm ▸ bot_isMaximal⟩) (h.symm ▸ bot_le)) fun h =>
      by rw [h, jacobson_eq_top_iff]⟩
#align ideal.is_jacobson_field Ideal.isJacobson_field

theorem isJacobson_of_surjective [H : IsJacobson R] :
    (∃ f : R →+* S, Function.Surjective f) → IsJacobson S :=
  by
  rintro ⟨f, hf⟩
  rw [is_jacobson_iff_Inf_maximal]
  intro p hp
  use map f '' {J : Ideal R | comap f p ≤ J ∧ J.IsMaximal}
  use fun j ⟨J, hJ, hmap⟩ => hmap ▸ (map_eq_top_or_is_maximal_of_surjective f hf hJ.right).symm
  have : p = map f (comap f p).jacobson :=
    (is_jacobson.out' _ <| hp.is_radical.comap f).symm ▸ (map_comap_of_surjective f hf p).symm
  exact this.trans (map_Inf hf fun J ⟨hJ, _⟩ => le_trans (Ideal.ker_le_comap f) hJ)
#align ideal.is_jacobson_of_surjective Ideal.isJacobson_of_surjective

instance (priority := 100) isJacobson_quotient [IsJacobson R] : IsJacobson (R ⧸ I) :=
  isJacobson_of_surjective ⟨Quotient.mk I, by rintro ⟨x⟩ <;> use x <;> rfl⟩
#align ideal.is_jacobson_quotient Ideal.isJacobson_quotient

theorem isJacobson_iso (e : R ≃+* S) : IsJacobson R ↔ IsJacobson S :=
  ⟨fun h => @isJacobson_of_surjective _ _ _ _ h ⟨(e : R →+* S), e.Surjective⟩, fun h =>
    @isJacobson_of_surjective _ _ _ _ h ⟨(e.symm : S →+* R), e.symm.Surjective⟩⟩
#align ideal.is_jacobson_iso Ideal.isJacobson_iso

theorem isJacobson_of_isIntegral [Algebra R S] (hRS : Algebra.IsIntegral R S) (hR : IsJacobson R) :
    IsJacobson S := by
  rw [is_jacobson_iff_prime_eq]
  intro P hP
  by_cases hP_top : comap (algebraMap R S) P = ⊤
  · simp [comap_eq_top_iff.1 hP_top]
  · haveI : Nontrivial (R ⧸ comap (algebraMap R S) P) := quotient.nontrivial hP_top
    rw [jacobson_eq_iff_jacobson_quotient_eq_bot]
    refine' eq_bot_of_comap_eq_bot (isIntegral_quotient_of_isIntegral hRS) _
    rw [eq_bot_iff, ←
      jacobson_eq_iff_jacobson_quotient_eq_bot.1
        ((is_jacobson_iff_prime_eq.1 hR) (comap (algebraMap R S) P) (comap_is_prime _ _)),
      comap_jacobson]
    refine' sInf_le_sInf fun J hJ => _
    simp only [true_and_iff, Set.mem_image, bot_le, Set.mem_setOf_eq]
    have : J.is_maximal := by simpa using hJ
    exact
      exists_ideal_over_maximal_of_is_integral (isIntegral_quotient_of_isIntegral hRS) J
        (comap_bot_le_of_injective _ algebra_map_quotient_injective)
#align ideal.is_jacobson_of_is_integral Ideal.isJacobson_of_isIntegral

theorem isJacobson_of_is_integral' (f : R →+* S) (hf : f.IsIntegral) (hR : IsJacobson R) :
    IsJacobson S :=
  @isJacobson_of_isIntegral _ _ _ _ f.toAlgebra hf hR
#align ideal.is_jacobson_of_is_integral' Ideal.isJacobson_of_is_integral'

end IsJacobson

section Localization

open IsLocalization Submonoid

variable {R S : Type _} [CommRing R] [CommRing S] {I : Ideal R}

variable (y : R) [Algebra R S] [IsLocalization.Away y S]

theorem disjoint_powers_iff_not_mem (hI : I.IsRadical) :
    Disjoint (Submonoid.powers y : Set R) ↑I ↔ y ∉ I.1 :=
  by
  refine'
    ⟨fun h => Set.disjoint_left.1 h (mem_powers _), fun h => disjoint_iff.mpr (eq_bot_iff.mpr _)⟩
  rintro x ⟨⟨n, rfl⟩, hx'⟩
  exact h (hI <| mem_radical_of_pow_mem <| le_radical hx')
#align ideal.disjoint_powers_iff_not_mem Ideal.disjoint_powers_iff_not_mem

variable (S)

/-- If `R` is a Jacobson ring, then maximal ideals in the localization at `y`
correspond to maximal ideals in the original ring `R` that don't contain `y`.
This lemma gives the correspondence in the particular case of an ideal and its comap.
See `le_rel_iso_of_maximal` for the more general relation isomorphism -/
theorem isMaximal_iff_isMaximal_disjoint [H : IsJacobson R] (J : Ideal S) :
    J.IsMaximal ↔ (comap (algebraMap R S) J).IsMaximal ∧ y ∉ Ideal.comap (algebraMap R S) J :=
  by
  constructor
  · refine' fun h =>
      ⟨_, fun hy =>
        h.ne_top (Ideal.eq_top_of_isUnit_mem _ hy (map_units _ ⟨y, Submonoid.mem_powers _⟩))⟩
    have hJ : J.is_prime := is_maximal.is_prime h
    rw [is_prime_iff_is_prime_disjoint (Submonoid.powers y)] at hJ 
    have : y ∉ (comap (algebraMap R S) J).1 := Set.disjoint_left.1 hJ.right (Submonoid.mem_powers _)
    erw [← H.out hJ.left.is_radical, mem_Inf] at this 
    push_neg at this 
    rcases this with ⟨I, hI, hI'⟩
    convert hI.right
    by_cases hJ : J = map (algebraMap R S) I
    · rw [hJ, comap_map_of_is_prime_disjoint (powers y) S I (is_maximal.is_prime hI.right)]
      rwa [disjoint_powers_iff_not_mem y hI.right.is_prime.is_radical]
    · have hI_p : (map (algebraMap R S) I).IsPrime :=
        by
        refine' is_prime_of_is_prime_disjoint (powers y) _ I hI.right.is_prime _
        rwa [disjoint_powers_iff_not_mem y hI.right.is_prime.is_radical]
      have : J ≤ map (algebraMap R S) I := map_comap (Submonoid.powers y) S J ▸ map_mono hI.left
      exact absurd (h.1.2 _ (lt_of_le_of_ne this hJ)) hI_p.1
  · refine' fun h => ⟨⟨fun hJ => h.1.ne_top (eq_top_iff.2 _), fun I hI => _⟩⟩
    · rwa [eq_top_iff, ← (IsLocalization.orderEmbedding (powers y) S).le_iff_le] at hJ 
    · have := congr_arg (map (algebraMap R S)) (h.1.1.2 _ ⟨comap_mono (le_of_lt hI), _⟩)
      rwa [map_comap (powers y) S I, map_top] at this 
      refine' fun hI' => hI.right _
      rw [← map_comap (powers y) S I, ← map_comap (powers y) S J]
      exact map_mono hI'
#align ideal.is_maximal_iff_is_maximal_disjoint Ideal.isMaximal_iff_isMaximal_disjoint

variable {S}

/-- If `R` is a Jacobson ring, then maximal ideals in the localization at `y`
correspond to maximal ideals in the original ring `R` that don't contain `y`.
This lemma gives the correspondence in the particular case of an ideal and its map.
See `le_rel_iso_of_maximal` for the more general statement, and the reverse of this implication -/
theorem isMaximal_of_isMaximal_disjoint [IsJacobson R] (I : Ideal R) (hI : I.IsMaximal)
    (hy : y ∉ I) : (map (algebraMap R S) I).IsMaximal :=
  by
  rw [is_maximal_iff_is_maximal_disjoint S y,
    comap_map_of_is_prime_disjoint (powers y) S I (is_maximal.is_prime hI)
      ((disjoint_powers_iff_not_mem y hI.is_prime.is_radical).2 hy)]
  exact ⟨hI, hy⟩
#align ideal.is_maximal_of_is_maximal_disjoint Ideal.isMaximal_of_isMaximal_disjoint

/-- If `R` is a Jacobson ring, then maximal ideals in the localization at `y`
correspond to maximal ideals in the original ring `R` that don't contain `y` -/
def orderIsoOfMaximal [IsJacobson R] :
    { p : Ideal S // p.IsMaximal } ≃o { p : Ideal R // p.IsMaximal ∧ y ∉ p }
    where
  toFun p := ⟨Ideal.comap (algebraMap R S) p.1, (isMaximal_iff_isMaximal_disjoint S y p.1).1 p.2⟩
  invFun p := ⟨Ideal.map (algebraMap R S) p.1, isMaximal_of_isMaximal_disjoint y p.1 p.2.1 p.2.2⟩
  left_inv J := Subtype.eq (map_comap (powers y) S J)
  right_inv I :=
    Subtype.eq
      (comap_map_of_isPrime_disjoint _ _ I.1 (IsMaximal.isPrime I.2.1)
        ((disjoint_powers_iff_not_mem y I.2.1.IsPrime.IsRadical).2 I.2.2))
  map_rel_iff' I I' :=
    ⟨fun h =>
      show I.val ≤ I'.val from
        map_comap (powers y) S I.val ▸ map_comap (powers y) S I'.val ▸ Ideal.map_mono h,
      fun h x hx => h hx⟩
#align ideal.order_iso_of_maximal Ideal.orderIsoOfMaximal

/-- If `S` is the localization of the Jacobson ring `R` at the submonoid generated by `y : R`, then
`S` is Jacobson. -/
theorem isJacobson_localization [H : IsJacobson R] : IsJacobson S :=
  by
  rw [is_jacobson_iff_prime_eq]
  refine' fun P' hP' => le_antisymm _ le_jacobson
  obtain ⟨hP', hPM⟩ := (IsLocalization.isPrime_iff_isPrime_disjoint (powers y) S P').mp hP'
  have hP := H.out hP'.is_radical
  refine'
    (IsLocalization.map_comap (powers y) S P'.jacobson).ge.trans
      ((map_mono _).trans (IsLocalization.map_comap (powers y) S P').le)
  have :
    Inf {I : Ideal R | comap (algebraMap R S) P' ≤ I ∧ I.IsMaximal ∧ y ∉ I} ≤
      comap (algebraMap R S) P' :=
    by
    intro x hx
    have hxy : x * y ∈ (comap (algebraMap R S) P').jacobson :=
      by
      rw [Ideal.jacobson, mem_Inf]
      intro J hJ
      by_cases y ∈ J
      · exact J.mul_mem_left x h
      · exact J.mul_mem_right y ((mem_Inf.1 hx) ⟨hJ.left, ⟨hJ.right, h⟩⟩)
    rw [hP] at hxy 
    cases' hP'.mem_or_mem hxy with hxy hxy
    · exact hxy
    · exact (hPM.le_bot ⟨Submonoid.mem_powers _, hxy⟩).elim
  refine' le_trans _ this
  rw [Ideal.jacobson, comap_Inf', sInf_eq_iInf]
  refine' iInf_le_iInf_of_subset fun I hI => ⟨map (algebraMap R S) I, ⟨_, _⟩⟩
  ·
    exact
      ⟨le_trans (le_of_eq (IsLocalization.map_comap (powers y) S P').symm) (map_mono hI.1),
        is_maximal_of_is_maximal_disjoint y _ hI.2.1 hI.2.2⟩
  ·
    exact
      IsLocalization.comap_map_of_isPrime_disjoint _ S I (is_maximal.is_prime hI.2.1)
        ((disjoint_powers_iff_not_mem y hI.2.1.IsPrime.IsRadical).2 hI.2.2)
#align ideal.is_jacobson_localization Ideal.isJacobson_localization

end Localization

namespace Polynomial

open Polynomial

section CommRing

variable {R S : Type _} [CommRing R] [CommRing S] [IsDomain S]

variable {Rₘ Sₘ : Type _} [CommRing Rₘ] [CommRing Sₘ]

/-- If `I` is a prime ideal of `R[X]` and `pX ∈ I` is a non-constant polynomial,
  then the map `R →+* R[x]/I` descends to an integral map when localizing at `pX.leading_coeff`.
  In particular `X` is integral because it satisfies `pX`, and constants are trivially integral,
  so integrality of the entire extension follows by closure under addition and multiplication. -/
theorem isIntegral_isLocalization_polynomial_quotient (P : Ideal R[X]) (pX : R[X]) (hpX : pX ∈ P)
    [Algebra (R ⧸ P.comap (C : R →+* _)) Rₘ]
    [IsLocalization.Away (pX.map (Quotient.mk (P.comap (C : R →+* R[X])))).leadingCoeff Rₘ]
    [Algebra (R[X] ⧸ P) Sₘ]
    [IsLocalization
        ((Submonoid.powers (pX.map (Quotient.mk (P.comap (C : R →+* R[X])))).leadingCoeff).map
            (quotientMap P C le_rfl) :
          Submonoid (R[X] ⧸ P))
        Sₘ] :
    (IsLocalization.map Sₘ (quotientMap P C le_rfl)
          (Submonoid.powers
              (pX.map (Quotient.mk (P.comap (C : R →+* R[X])))).leadingCoeff).le_comap_map :
        Rₘ →+* _).IsIntegral :=
  by
  let P' : Ideal R := P.comap C
  let M : Submonoid (R ⧸ P') :=
    Submonoid.powers (pX.map (Quotient.mk' (P.comap (C : R →+* R[X])))).leadingCoeff
  let M' : Submonoid (R[X] ⧸ P) :=
    (Submonoid.powers (pX.map (Quotient.mk' (P.comap (C : R →+* R[X])))).leadingCoeff).map
      (QuotientMap P C le_rfl)
  let φ : R ⧸ P' →+* R[X] ⧸ P := QuotientMap P C le_rfl
  let φ' : Rₘ →+* Sₘ := IsLocalization.map Sₘ φ M.le_comap_map
  have hφ' : φ.comp (Quotient.mk' P') = (Quotient.mk' P).comp C := rfl
  intro p
  obtain ⟨⟨p', ⟨q, hq⟩⟩, hp⟩ := IsLocalization.surj M' p
  suffices φ'.is_integral_elem (algebraMap _ _ p')
    by
    obtain ⟨q', hq', rfl⟩ := hq
    obtain ⟨q'', hq''⟩ := isUnit_iff_exists_inv'.1 (IsLocalization.map_units Rₘ (⟨q', hq'⟩ : M))
    refine' φ'.is_integral_of_is_integral_mul_unit p (algebraMap _ _ (φ q')) q'' _ (hp.symm ▸ this)
    convert trans (trans (φ'.map_mul _ _).symm (congr_arg φ' hq'')) φ'.map_one using 2
    rw [← φ'.comp_apply, IsLocalization.map_comp, RingHom.comp_apply, Subtype.coe_mk]
  refine'
    is_integral_of_mem_closure''
      ((algebraMap _ Sₘ).comp (Quotient.mk' P) '' insert X {p | p.degree ≤ 0}) _ _ _
  · rintro x ⟨p, hp, rfl⟩
    refine' hp.rec_on (fun hy => _) fun hy => _
    · refine'
        hy.symm ▸
          φ.is_integral_elem_localization_at_leading_coeff ((Quotient.mk' P) X)
            (pX.map (Quotient.mk' P')) _ M ⟨1, pow_one _⟩
      rwa [eval₂_map, hφ', ← hom_eval₂, quotient.eq_zero_iff_mem, eval₂_C_X]
    · rw [Set.mem_setOf_eq, degree_le_zero_iff] at hy 
      refine' hy.symm ▸ ⟨X - C (algebraMap _ _ ((Quotient.mk' P') (p.coeff 0))), monic_X_sub_C _, _⟩
      simp only [eval₂_sub, eval₂_C, eval₂_X]
      rw [sub_eq_zero, ← φ'.comp_apply, IsLocalization.map_comp]
      rfl
  · obtain ⟨p, rfl⟩ := quotient.mk_surjective p'
    refine'
      Polynomial.induction_on p
        (fun r => Subring.subset_closure <| Set.mem_image_of_mem _ (Or.inr degree_C_le))
        (fun _ _ h1 h2 => _) fun n _ hr => _
    · convert Subring.add_mem _ h1 h2
      rw [RingHom.map_add, RingHom.map_add]
    · rw [pow_succ X n, mul_comm X, ← mul_assoc, RingHom.map_mul, RingHom.map_mul]
      exact Subring.mul_mem _ hr (Subring.subset_closure (Set.mem_image_of_mem _ (Or.inl rfl)))
#align ideal.polynomial.is_integral_is_localization_polynomial_quotient Ideal.Polynomial.isIntegral_isLocalization_polynomial_quotient

/-- If `f : R → S` descends to an integral map in the localization at `x`,
  and `R` is a Jacobson ring, then the intersection of all maximal ideals in `S` is trivial -/
theorem jacobson_bot_of_integral_localization {R : Type _} [CommRing R] [IsDomain R] [IsJacobson R]
    (Rₘ Sₘ : Type _) [CommRing Rₘ] [CommRing Sₘ] (φ : R →+* S) (hφ : Function.Injective φ) (x : R)
    (hx : x ≠ 0) [Algebra R Rₘ] [IsLocalization.Away x Rₘ] [Algebra S Sₘ]
    [IsLocalization ((Submonoid.powers x).map φ : Submonoid S) Sₘ]
    (hφ' :
      RingHom.IsIntegral (IsLocalization.map Sₘ φ (Submonoid.powers x).le_comap_map : Rₘ →+* Sₘ)) :
    (⊥ : Ideal S).jacobson = (⊥ : Ideal S) :=
  by
  have hM : ((Submonoid.powers x).map φ : Submonoid S) ≤ nonZeroDivisors S :=
    map_le_nonZeroDivisors_of_injective φ hφ (powers_le_nonZeroDivisors_of_noZeroDivisors hx)
  letI : IsDomain Sₘ := IsLocalization.isDomain_of_le_nonZeroDivisors _ hM
  let φ' : Rₘ →+* Sₘ := IsLocalization.map _ φ (Submonoid.powers x).le_comap_map
  suffices ∀ I : Ideal Sₘ, I.IsMaximal → (I.comap (algebraMap S Sₘ)).IsMaximal
    by
    have hϕ' : comap (algebraMap S Sₘ) (⊥ : Ideal Sₘ) = (⊥ : Ideal S) :=
      by
      rw [← RingHom.ker_eq_comap_bot, ← RingHom.injective_iff_ker_eq_bot]
      exact IsLocalization.injective Sₘ hM
    have hSₘ : is_jacobson Sₘ := is_jacobson_of_is_integral' φ' hφ' (is_jacobson_localization x)
    refine' eq_bot_iff.mpr (le_trans _ (le_of_eq hϕ'))
    rw [← hSₘ.out is_radical_bot_of_no_zero_divisors, comap_jacobson]
    exact
      sInf_le_sInf fun j hj =>
        ⟨bot_le,
          let ⟨J, hJ⟩ := hj
          hJ.2 ▸ this J hJ.1.2⟩
  intro I hI
  -- Remainder of the proof is pulling and pushing ideals around the square and the quotient square
  haveI : (I.comap (algebraMap S Sₘ)).IsPrime := comap_is_prime _ I
  haveI : (I.comap φ').IsPrime := comap_is_prime φ' I
  haveI : (⊥ : Ideal (S ⧸ I.comap (algebraMap S Sₘ))).IsPrime := bot_prime
  have hcomm : φ'.comp (algebraMap R Rₘ) = (algebraMap S Sₘ).comp φ := IsLocalization.map_comp _
  let f := QuotientMap (I.comap (algebraMap S Sₘ)) φ le_rfl
  let g := QuotientMap I (algebraMap S Sₘ) le_rfl
  have := is_maximal_comap_of_is_integral_of_is_maximal' φ' hφ' I hI
  have := ((is_maximal_iff_is_maximal_disjoint Rₘ x _).1 this).left
  have : ((I.comap (algebraMap S Sₘ)).comap φ).IsMaximal := by
    rwa [comap_comap, hcomm, ← comap_comap] at this 
  rw [← bot_quotient_is_maximal_iff] at this ⊢
  refine'
    is_maximal_of_is_integral_of_is_maximal_comap' f _ ⊥
      ((eq_bot_iff.2 (comap_bot_le_of_injective f quotient_map_injective)).symm ▸ this)
  exact
    f.is_integral_tower_bot_of_is_integral g quotient_map_injective
      ((comp_quotient_map_eq_of_comp_eq hcomm I).symm ▸
        RingHom.isIntegral_trans _ _
          (RingHom.isIntegral_of_surjective _
            (IsLocalization.surjective_quotientMap_of_maximal_of_localization (Submonoid.powers x)
              Rₘ (by rwa [comap_comap, hcomm, ← bot_quotient_is_maximal_iff])))
          (RingHom.isIntegral_quotient_of_isIntegral _ hφ'))
#align ideal.polynomial.jacobson_bot_of_integral_localization Ideal.Polynomial.jacobson_bot_of_integral_localization

/-- Used to bootstrap the proof of `is_jacobson_polynomial_iff_is_jacobson`.
  That theorem is more general and should be used instead of this one. -/
private theorem is_jacobson_polynomial_of_domain (R : Type _) [CommRing R] [IsDomain R]
    [hR : IsJacobson R] (P : Ideal R[X]) [IsPrime P] (hP : ∀ x : R, C x ∈ P → x = 0) :
    P.jacobson = P := by
  by_cases Pb : P = ⊥
  ·
    exact
      Pb.symm ▸ jacobson_bot_polynomial_of_jacobson_bot (hR.out is_radical_bot_of_no_zero_divisors)
  · rw [jacobson_eq_iff_jacobson_quotient_eq_bot]
    haveI : (P.comap (C : R →+* R[X])).IsPrime := comap_is_prime C P
    obtain ⟨p, pP, p0⟩ := exists_nonzero_mem_of_ne_bot Pb hP
    let x := (Polynomial.map (Quotient.mk' (comap (C : R →+* _) P)) p).leadingCoeff
    have hx : x ≠ 0 := by rwa [Ne.def, leading_coeff_eq_zero]
    refine'
      jacobson_bot_of_integral_localization (Localization.Away x)
        (Localization ((Submonoid.powers x).map (P.quotient_map C le_rfl) : Submonoid (R[X] ⧸ P)))
        (QuotientMap P C le_rfl) quotient_map_injective x hx _
    -- `convert` is noticeably faster than `exact` here:
    convert is_integral_is_localization_polynomial_quotient P p pP

theorem isJacobson_polynomial_of_isJacobson (hR : IsJacobson R) : IsJacobson R[X] :=
  by
  refine' is_jacobson_iff_prime_eq.mpr fun I => _
  intro hI
  let R' : Subring (R[X] ⧸ I) := ((Quotient.mk' I).comp C).range
  let i : R →+* R' := ((Quotient.mk' I).comp C).range_restrict
  have hi : Function.Surjective (i : R → R') := ((Quotient.mk' I).comp C).rangeRestrict_surjective
  have hi' : (Polynomial.mapRingHom i : R[X] →+* R'[X]).ker ≤ I :=
    by
    refine' fun f hf => polynomial_mem_ideal_of_coeff_mem_ideal I f fun n => _
    replace hf := congr_arg (fun g : Polynomial ((Quotient.mk' I).comp C).range => g.Coeff n) hf
    change (Polynomial.map ((Quotient.mk' I).comp C).range_restrict f).Coeff n = 0 at hf 
    rw [coeff_map, Subtype.ext_iff] at hf 
    rwa [mem_comap, ← quotient.eq_zero_iff_mem, ← RingHom.comp_apply]
  haveI :=
    map_is_prime_of_surjective (show Function.Surjective (map_ring_hom i) from map_surjective i hi)
      hi'
  suffices (I.map (Polynomial.mapRingHom i)).jacobson = I.map (Polynomial.mapRingHom i)
    by
    replace this := congr_arg (comap (Polynomial.mapRingHom i)) this
    rw [← map_jacobson_of_surjective _ hi', comap_map_of_surjective _ _,
      comap_map_of_surjective _ _] at this 
    refine'
      le_antisymm
        (le_trans (le_sup_of_le_left le_rfl) (le_trans (le_of_eq this) (sup_le le_rfl hi')))
        le_jacobson
    all_goals exact Polynomial.map_surjective i hi
  exact
    @is_jacobson_polynomial_of_domain R' _ _ (is_jacobson_of_surjective ⟨i, hi⟩)
      (map (map_ring_hom i) I) _ (eq_zero_of_polynomial_mem_map_range I)
#align ideal.polynomial.is_jacobson_polynomial_of_is_jacobson Ideal.Polynomial.isJacobson_polynomial_of_isJacobson

theorem isJacobson_polynomial_iff_isJacobson : IsJacobson R[X] ↔ IsJacobson R :=
  by
  refine' ⟨_, is_jacobson_polynomial_of_is_jacobson⟩
  intro H
  exact
    is_jacobson_of_surjective
      ⟨eval₂_ring_hom (RingHom.id _) 1, fun x =>
        ⟨C x, by simp only [coe_eval₂_ring_hom, RingHom.id_apply, eval₂_C]⟩⟩
#align ideal.polynomial.is_jacobson_polynomial_iff_is_jacobson Ideal.Polynomial.isJacobson_polynomial_iff_isJacobson

instance [IsJacobson R] : IsJacobson R[X] :=
  isJacobson_polynomial_iff_isJacobson.mpr ‹IsJacobson R›

end CommRing

section

variable {R : Type _} [CommRing R] [IsJacobson R]

variable (P : Ideal R[X]) [hP : P.IsMaximal]

theorem isMaximal_comap_c_of_isMaximal [Nontrivial R] (hP' : ∀ x : R, C x ∈ P → x = 0) :
    IsMaximal (comap (C : R →+* R[X]) P : Ideal R) :=
  by
  haveI hp'_prime : (P.comap (C : R →+* R[X]) : Ideal R).IsPrime := comap_is_prime C P
  obtain ⟨m, hm⟩ := Submodule.nonzero_mem_of_bot_lt (bot_lt_of_maximal P polynomial_not_is_field)
  have : (m : R[X]) ≠ 0; rwa [Ne.def, Submodule.coe_eq_zero]
  let φ : R ⧸ P.comap (C : R →+* R[X]) →+* R[X] ⧸ P := QuotientMap P (C : R →+* R[X]) le_rfl
  let M : Submonoid (R ⧸ P.comap C) :=
    Submonoid.powers
      ((m : R[X]).map (Quotient.mk' (P.comap (C : R →+* R[X]) : Ideal R))).leadingCoeff
  rw [← bot_quotient_is_maximal_iff]
  have hp0 :
    ((m : R[X]).map (Quotient.mk' (P.comap (C : R →+* R[X]) : Ideal R))).leadingCoeff ≠ 0 :=
    fun hp0' =>
    this <|
      map_injective (Quotient.mk' (P.comap (C : R →+* R[X]) : Ideal R))
        ((injective_iff_map_eq_zero (Quotient.mk' (P.comap (C : R →+* R[X]) : Ideal R))).2
          fun x hx => by
          rwa [quotient.eq_zero_iff_mem, (by rwa [eq_bot_iff] : (P.comap C : Ideal R) = ⊥)] at hx )
        (by simpa only [leading_coeff_eq_zero, Polynomial.map_zero] using hp0')
  have hM : (0 : R ⧸ P.comap C) ∉ M := fun ⟨n, hn⟩ => hp0 (pow_eq_zero hn)
  suffices (⊥ : Ideal (Localization M)).IsMaximal
    by
    rw [←
      IsLocalization.comap_map_of_isPrime_disjoint M (Localization M) ⊥ bot_prime
        (disjoint_iff_inf_le.mpr fun x hx => hM (hx.2 ▸ hx.1))]
    refine' ((is_maximal_iff_is_maximal_disjoint (Localization M) _ _).mp (by rwa [map_bot])).1
    swap; exact Localization.isLocalization
  let M' : Submonoid (R[X] ⧸ P) := M.map φ
  have hM' : (0 : R[X] ⧸ P) ∉ M' := fun ⟨z, hz⟩ =>
    hM (quotient_map_injective (trans hz.2 φ.map_zero.symm) ▸ hz.1)
  haveI : IsDomain (Localization M') :=
    IsLocalization.isDomain_localization (le_nonZeroDivisors_of_noZeroDivisors hM')
  suffices (⊥ : Ideal (Localization M')).IsMaximal
    by
    rw [le_antisymm bot_le
        (comap_bot_le_of_injective _
          (IsLocalization.map_injective_of_injective M (Localization M) (Localization M')
            quotient_map_injective))]
    refine' is_maximal_comap_of_is_integral_of_is_maximal' _ _ ⊥ this
    apply is_integral_is_localization_polynomial_quotient P _ (Submodule.coe_mem m)
  rw [(map_bot.symm :
      (⊥ : Ideal (Localization M')) = map (algebraMap (R[X] ⧸ P) (Localization M')) ⊥)]
  let bot_maximal := (bot_quotient_is_maximal_iff _).mpr hP
  refine' map.is_maximal (algebraMap _ _) (IsField.localization_map_bijective hM' _) bot_maximal
  rwa [← quotient.maximal_ideal_iff_is_field_quotient, ← bot_quotient_is_maximal_iff]
#align ideal.polynomial.is_maximal_comap_C_of_is_maximal Ideal.Polynomial.isMaximal_comap_c_of_isMaximal

/-- Used to bootstrap the more general `quotient_mk_comp_C_is_integral_of_jacobson` -/
private theorem quotient_mk_comp_C_is_integral_of_jacobson' [Nontrivial R] (hR : IsJacobson R)
    (hP' : ∀ x : R, C x ∈ P → x = 0) : ((Quotient.mk P).comp C : R →+* R[X] ⧸ P).IsIntegral :=
  by
  refine' (isIntegral_quotientMap_iff _).mp _
  let P' : Ideal R := P.comap C
  obtain ⟨pX, hpX, hp0⟩ :=
    exists_nonzero_mem_of_ne_bot (ne_of_lt (bot_lt_of_maximal P polynomial_not_is_field)).symm hP'
  let M : Submonoid (R ⧸ P') := Submonoid.powers (pX.map (Quotient.mk' P')).leadingCoeff
  let φ : R ⧸ P' →+* R[X] ⧸ P := QuotientMap P C le_rfl
  haveI hp'_prime : P'.is_prime := comap_is_prime C P
  have hM : (0 : R ⧸ P') ∉ M := fun ⟨n, hn⟩ => hp0 <| leading_coeff_eq_zero.mp (pow_eq_zero hn)
  let M' : Submonoid (R[X] ⧸ P) := M.map (QuotientMap P C le_rfl)
  refine'
    (QuotientMap P C le_rfl).isIntegral_tower_bot_of_isIntegral (algebraMap _ (Localization M')) _ _
  · refine'
      IsLocalization.injective (Localization M')
        (show M' ≤ _ from le_nonZeroDivisors_of_noZeroDivisors fun hM' => hM _)
    exact
      let ⟨z, zM, z0⟩ := hM'
      quotient_map_injective (trans z0 φ.map_zero.symm) ▸ zM
  · rw [← IsLocalization.map_comp M.le_comap_map]
    refine'
      RingHom.isIntegral_trans (algebraMap (R ⧸ P') (Localization M))
        (IsLocalization.map (Localization M') _ M.le_comap_map) _ _
    ·
      exact
        (algebraMap (R ⧸ P') (Localization M)).isIntegral_of_surjective
          (IsField.localization_map_bijective hM
              ((quotient.maximal_ideal_iff_is_field_quotient _).mp
                (is_maximal_comap_C_of_is_maximal P hP'))).2
    ·-- `convert` here is faster than `exact`, and this proof is near the time limit.
      convert is_integral_is_localization_polynomial_quotient P pX hpX

/-- If `R` is a Jacobson ring, and `P` is a maximal ideal of `R[X]`,
  then `R → R[X]/P` is an integral map. -/
theorem quotient_mk_comp_c_isIntegral_of_jacobson :
    ((Quotient.mk P).comp C : R →+* R[X] ⧸ P).IsIntegral :=
  by
  let P' : Ideal R := P.comap C
  haveI : P'.is_prime := comap_is_prime C P
  let f : R[X] →+* Polynomial (R ⧸ P') := Polynomial.mapRingHom (Quotient.mk' P')
  have hf : Function.Surjective f := map_surjective (Quotient.mk' P') quotient.mk_surjective
  have hPJ : P = (P.map f).comap f :=
    by
    rw [comap_map_of_surjective _ hf]
    refine' le_antisymm (le_sup_of_le_left le_rfl) (sup_le le_rfl _)
    refine' fun p hp =>
      polynomial_mem_ideal_of_coeff_mem_ideal P p fun n => quotient.eq_zero_iff_mem.mp _
    simpa only [coeff_map, coe_map_ring_hom] using (polynomial.ext_iff.mp hp) n
  refine' RingHom.isIntegral_tower_bot_of_isIntegral _ _ (injective_quotient_le_comap_map P) _
  rw [← quotient_mk_maps_eq]
  refine'
    RingHom.isIntegral_trans _ _ ((Quotient.mk' P').isIntegral_of_surjective quotient.mk_surjective)
      _
  apply quotient_mk_comp_C_is_integral_of_jacobson' _ _ fun x hx => _
  any_goals exact Ideal.isJacobson_quotient
  ·
    exact
      Or.rec_on (map_eq_top_or_is_maximal_of_surjective f hf hP)
        (fun h => absurd (trans (h ▸ hPJ : P = comap f ⊤) comap_top : P = ⊤) hP.ne_top) id
  · infer_instance
  · obtain ⟨z, rfl⟩ := quotient.mk_surjective x
    rwa [quotient.eq_zero_iff_mem, mem_comap, hPJ, mem_comap, coe_map_ring_hom, map_C]
#align ideal.polynomial.quotient_mk_comp_C_is_integral_of_jacobson Ideal.Polynomial.quotient_mk_comp_c_isIntegral_of_jacobson

theorem isMaximal_comap_c_of_isJacobson : (P.comap (C : R →+* R[X])).IsMaximal :=
  by
  rw [← @mk_ker _ _ P, RingHom.ker_eq_comap_bot, comap_comap]
  exact
    is_maximal_comap_of_is_integral_of_is_maximal' _ (quotient_mk_comp_C_is_integral_of_jacobson P)
      ⊥ ((bot_quotient_is_maximal_iff _).mpr hP)
#align ideal.polynomial.is_maximal_comap_C_of_is_jacobson Ideal.Polynomial.isMaximal_comap_c_of_isJacobson

theorem comp_c_integral_of_surjective_of_jacobson {S : Type _} [Field S] (f : R[X] →+* S)
    (hf : Function.Surjective f) : (f.comp C).IsIntegral :=
  by
  haveI : f.ker.IsMaximal := RingHom.ker_isMaximal_of_surjective f hf
  let g : R[X] ⧸ f.ker →+* S := Ideal.Quotient.lift f.ker f fun _ h => h
  have hfg : g.comp (Quotient.mk' f.ker) = f := ring_hom_ext' rfl rfl
  rw [← hfg, RingHom.comp_assoc]
  refine'
    RingHom.isIntegral_trans _ g (quotient_mk_comp_C_is_integral_of_jacobson f.ker)
      (g.is_integral_of_surjective _)
  --(quotient.lift_surjective f.ker f _ hf)),
  rw [← hfg] at hf 
  exact Function.Surjective.of_comp hf
#align ideal.polynomial.comp_C_integral_of_surjective_of_jacobson Ideal.Polynomial.comp_c_integral_of_surjective_of_jacobson

end

end Polynomial

open MvPolynomial RingHom

namespace MvPolynomial

theorem isJacobson_mvPolynomial_fin {R : Type _} [CommRing R] [H : IsJacobson R] :
    ∀ n : ℕ, IsJacobson (MvPolynomial (Fin n) R)
  | 0 =>
    (isJacobson_iso
          ((renameEquiv R (Equiv.equivPEmpty (Fin 0))).toRingEquiv.trans
            (isEmptyRingEquiv R PEmpty))).mpr
      H
  | n + 1 =>
    (isJacobson_iso (finSuccEquiv R n).toRingEquiv).2
      (Polynomial.isJacobson_polynomial_iff_isJacobson.2 (is_jacobson_mv_polynomial_fin n))
#align ideal.mv_polynomial.is_jacobson_mv_polynomial_fin Ideal.MvPolynomial.isJacobson_mvPolynomial_fin

/-- General form of the nullstellensatz for Jacobson rings, since in a Jacobson ring we have
  `Inf {P maximal | P ≥ I} = Inf {P prime | P ≥ I} = I.radical`. Fields are always Jacobson,
  and in that special case this is (most of) the classical Nullstellensatz,
  since `I(V(I))` is the intersection of maximal ideals containing `I`, which is then `I.radical` -/
instance isJacobson {R : Type _} [CommRing R] {ι : Type _} [Finite ι] [IsJacobson R] :
    IsJacobson (MvPolynomial ι R) := by
  cases nonempty_fintype ι
  haveI := Classical.decEq ι
  let e := Fintype.equivFin ι
  rw [is_jacobson_iso (rename_equiv R e).toRingEquiv]
  exact is_jacobson_mv_polynomial_fin _
#align ideal.mv_polynomial.is_jacobson Ideal.MvPolynomial.isJacobson

variable {n : ℕ}

theorem quotient_mk_comp_c_isIntegral_of_jacobson {R : Type _} [CommRing R] [IsJacobson R]
    (P : Ideal (MvPolynomial (Fin n) R)) [P.IsMaximal] :
    ((Quotient.mk P).comp MvPolynomial.C : R →+* MvPolynomial _ R ⧸ P).IsIntegral :=
  by
  induction' n with n IH
  · refine' RingHom.isIntegral_of_surjective _ (Function.Surjective.comp quotient.mk_surjective _)
    exact C_surjective (Fin 0)
  · rw [← fin_succ_equiv_comp_C_eq_C, ← RingHom.comp_assoc, ← RingHom.comp_assoc, ←
      quotient_map_comp_mk le_rfl, RingHom.comp_assoc Polynomial.C, ← quotient_map_comp_mk le_rfl,
      RingHom.comp_assoc, RingHom.comp_assoc, ← quotient_map_comp_mk le_rfl, ←
      RingHom.comp_assoc (Quotient.mk' _)]
    refine' RingHom.isIntegral_trans _ _ _ _
    · refine' RingHom.isIntegral_trans _ _ (isIntegral_of_surjective _ quotient.mk_surjective) _
      refine' RingHom.isIntegral_trans _ _ _ _
      · apply (isIntegral_quotientMap_iff _).mpr (IH _)
        apply polynomial.is_maximal_comap_C_of_is_jacobson _
        · exact mv_polynomial.is_jacobson_mv_polynomial_fin n
        · apply comap_is_maximal_of_surjective
          exact (finSuccEquiv R n).symm.Surjective
      · refine' (isIntegral_quotientMap_iff _).mpr _
        rw [← quotient_map_comp_mk le_rfl]
        refine' RingHom.isIntegral_trans _ _ _ ((isIntegral_quotientMap_iff _).mpr _)
        · exact RingHom.isIntegral_of_surjective _ quotient.mk_surjective
        · apply polynomial.quotient_mk_comp_C_is_integral_of_jacobson _
          · exact mv_polynomial.is_jacobson_mv_polynomial_fin n
          · exact comap_is_maximal_of_surjective _ (finSuccEquiv R n).symm.Surjective
    · refine' (isIntegral_quotientMap_iff _).mpr _
      refine' RingHom.isIntegral_trans _ _ _ (isIntegral_of_surjective _ quotient.mk_surjective)
      exact RingHom.isIntegral_of_surjective _ (finSuccEquiv R n).symm.Surjective
#align ideal.mv_polynomial.quotient_mk_comp_C_is_integral_of_jacobson Ideal.MvPolynomial.quotient_mk_comp_c_isIntegral_of_jacobson

theorem comp_c_integral_of_surjective_of_jacobson {R : Type _} [CommRing R] [IsJacobson R]
    {σ : Type _} [Finite σ] {S : Type _} [Field S] (f : MvPolynomial σ R →+* S)
    (hf : Function.Surjective f) : (f.comp C).IsIntegral :=
  by
  cases nonempty_fintype σ
  have e := (Fintype.equivFin σ).symm
  let f' : MvPolynomial (Fin _) R →+* S := f.comp (rename_equiv R e).toRingEquiv.toRingHom
  have hf' : Function.Surjective f' := Function.Surjective.comp hf (rename_equiv R e).Surjective
  have : (f'.comp C).IsIntegral :=
    by
    haveI : f'.ker.IsMaximal := ker_is_maximal_of_surjective f' hf'
    let g : MvPolynomial _ R ⧸ f'.ker →+* S := Ideal.Quotient.lift f'.ker f' fun _ h => h
    have hfg : g.comp (Quotient.mk' f'.ker) = f' := ring_hom_ext (fun r => rfl) fun i => rfl
    rw [← hfg, RingHom.comp_assoc]
    refine'
      RingHom.isIntegral_trans _ g (quotient_mk_comp_C_is_integral_of_jacobson f'.ker)
        (g.is_integral_of_surjective _)
    rw [← hfg] at hf' 
    exact Function.Surjective.of_comp hf'
  rw [RingHom.comp_assoc] at this 
  convert this
  refine' RingHom.ext fun x => _
  exact ((rename_equiv R e).commutes' x).symm
#align ideal.mv_polynomial.comp_C_integral_of_surjective_of_jacobson Ideal.MvPolynomial.comp_c_integral_of_surjective_of_jacobson

end MvPolynomial

end Ideal

