/-
Copyright (c) 2022 Riccardo Brasca. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Riccardo Brasca
-/
import Mathbin.RingTheory.EisensteinCriterion
import Mathbin.RingTheory.IntegrallyClosed
import Mathbin.RingTheory.Norm
import Mathbin.RingTheory.Polynomial.Cyclotomic.Basic

/-!
# Eisenstein polynomials
Given an ideal `𝓟` of a commutative semiring `R`, we say that a polynomial `f : R[X]` is
*Eisenstein at `𝓟`* if `f.leading_coeff ∉ 𝓟`, `∀ n, n < f.nat_degree → f.coeff n ∈ 𝓟` and
`f.coeff 0 ∉ 𝓟 ^ 2`. In this file we gather miscellaneous results about Eisenstein polynomials.

## Main definitions
* `polynomial.is_eisenstein_at f 𝓟`: the property of being Eisenstein at `𝓟`.

## Main results
* `polynomial.is_eisenstein_at.irreducible`: if a primitive `f` satisfies `f.is_eisenstein_at 𝓟`,
  where `𝓟.is_prime`, then `f` is irreducible.
* `mem_adjoin_of_smul_prime_pow_smul_of_minpoly_is_eiseinstein_at`: let `K` be the field of fraction
  of an integrally closed domain `R` and let `L` be a separable extension of `K`, generated by an
  integral power basis `B` such that the minimal polynomial of `B.gen` is Eisenstein at `p`. Given
  `z : L` integral over `R`, if `p ^ n • z ∈ adjoin R {B.gen}`, then `z ∈ adjoin R {B.gen}`.
  Together with `algebra.discr_mul_is_integral_mem_adjoin` this result often allows to compute the
  ring of integers of `L`.

## Implementation details
We also define a notion `is_weakly_eisenstein_at` requiring only that
`∀ n < f.nat_degree → f.coeff n ∈ 𝓟`. This makes certain results slightly more general and it is
useful since it is sometimes better behaved (for example it is stable under `polynomial.map`).

-/


universe u v w z

variable {R : Type u}

open Ideal Algebra Finset

open BigOperators Polynomial

namespace Polynomial

/-- Given an ideal `𝓟` of a commutative semiring `R`, we say that a polynomial `f : R[X]`
is *weakly Eisenstein at `𝓟`* if `∀ n, n < f.nat_degree → f.coeff n ∈ 𝓟`. -/
@[mk_iff]
structure IsWeaklyEisensteinAt [CommSemiring R] (f : R[X]) (𝓟 : Ideal R) : Prop where
  Mem : ∀ {n}, n < f.natDegree → f.coeff n ∈ 𝓟
#align polynomial.is_weakly_eisenstein_at Polynomial.IsWeaklyEisensteinAt

/-- Given an ideal `𝓟` of a commutative semiring `R`, we say that a polynomial `f : R[X]`
is *Eisenstein at `𝓟`* if `f.leading_coeff ∉ 𝓟`, `∀ n, n < f.nat_degree → f.coeff n ∈ 𝓟` and
`f.coeff 0 ∉ 𝓟 ^ 2`. -/
@[mk_iff]
structure IsEisensteinAt [CommSemiring R] (f : R[X]) (𝓟 : Ideal R) : Prop where
  leading : f.leadingCoeff ∉ 𝓟
  Mem : ∀ {n}, n < f.natDegree → f.coeff n ∈ 𝓟
  not_mem : f.coeff 0 ∉ 𝓟 ^ 2
#align polynomial.is_eisenstein_at Polynomial.IsEisensteinAt

namespace IsWeaklyEisensteinAt

section CommSemiring

variable [CommSemiring R] {𝓟 : Ideal R} {f : R[X]} (hf : f.IsWeaklyEisensteinAt 𝓟)

include hf

theorem map {A : Type v} [CommRing A] (φ : R →+* A) : (f.map φ).IsWeaklyEisensteinAt (𝓟.map φ) := by
  refine' (is_weakly_eisenstein_at_iff _ _).2 fun n hn => _
  rw [coeff_map]
  exact mem_map_of_mem _ (hf.mem (lt_of_lt_of_le hn (nat_degree_map_le _ _)))
#align polynomial.is_weakly_eisenstein_at.map Polynomial.IsWeaklyEisensteinAt.map

end CommSemiring

section CommRing

variable [CommRing R] {𝓟 : Ideal R} {f : R[X]} (hf : f.IsWeaklyEisensteinAt 𝓟)

variable {S : Type v} [CommRing S] [Algebra R S]

section Principal

variable {p : R}

-- mathport name: exprP
local notation "P" => Submodule.span R {p}

theorem exists_mem_adjoin_mul_eq_pow_nat_degree {x : S} (hx : aeval x f = 0) (hmo : f.Monic)
    (hf : f.IsWeaklyEisensteinAt P) :
    ∃ y ∈ adjoin R ({x} : Set S), (algebraMap R S) p * y = x ^ (f.map (algebraMap R S)).natDegree := by
  rw [aeval_def, Polynomial.eval₂_eq_eval_map, eval_eq_sum_range, range_add_one, sum_insert not_mem_range_self,
    sum_range, (hmo.map (algebraMap R S)).coeff_nat_degree, one_mul] at hx
  replace hx := eq_neg_of_add_eq_zero_left hx
  have : ∀ n < f.nat_degree, p ∣ f.coeff n := by
    intro n hn
    refine' mem_span_singleton.1 (by simpa using hf.mem hn)
  choose! φ hφ using this
  conv_rhs at hx =>
  congr
  congr
  skip
  ext
  rw [Fin.coe_eq_val, coeff_map, hφ i.1 (lt_of_lt_of_le i.2 (nat_degree_map_le _ _)), RingHom.map_mul, mul_assoc]
  rw [hx, ← mul_sum, neg_eq_neg_one_mul, ← mul_assoc (-1 : S), mul_comm (-1 : S), mul_assoc]
  refine' ⟨-1 * ∑ i : Fin (f.map (algebraMap R S)).natDegree, (algebraMap R S) (φ i.1) * x ^ i.1, _, rfl⟩
  exact
    Subalgebra.mul_mem _ (Subalgebra.neg_mem _ (Subalgebra.one_mem _))
      (Subalgebra.sum_mem _ fun i hi =>
        Subalgebra.mul_mem _ (Subalgebra.algebra_map_mem _ _)
          (Subalgebra.pow_mem _ (subset_adjoin (Set.mem_singleton x)) _))
#align
  polynomial.is_weakly_eisenstein_at.exists_mem_adjoin_mul_eq_pow_nat_degree Polynomial.IsWeaklyEisensteinAt.exists_mem_adjoin_mul_eq_pow_nat_degree

theorem exists_mem_adjoin_mul_eq_pow_nat_degree_le {x : S} (hx : aeval x f = 0) (hmo : f.Monic)
    (hf : f.IsWeaklyEisensteinAt P) :
    ∀ i, (f.map (algebraMap R S)).natDegree ≤ i → ∃ y ∈ adjoin R ({x} : Set S), (algebraMap R S) p * y = x ^ i := by
  intro i hi
  obtain ⟨k, hk⟩ := exists_add_of_le hi
  rw [hk, pow_add]
  obtain ⟨y, hy, H⟩ := exists_mem_adjoin_mul_eq_pow_nat_degree hx hmo hf
  refine' ⟨y * x ^ k, _, _⟩
  · exact Subalgebra.mul_mem _ hy (Subalgebra.pow_mem _ (subset_adjoin (Set.mem_singleton x)) _)
    
  · rw [← mul_assoc _ y, H]
    
#align
  polynomial.is_weakly_eisenstein_at.exists_mem_adjoin_mul_eq_pow_nat_degree_le Polynomial.IsWeaklyEisensteinAt.exists_mem_adjoin_mul_eq_pow_nat_degree_le

end Principal

include hf

theorem pow_nat_degree_le_of_root_of_monic_mem {x : R} (hroot : IsRoot f x) (hmo : f.Monic) :
    ∀ i, f.natDegree ≤ i → x ^ i ∈ 𝓟 := by
  intro i hi
  obtain ⟨k, hk⟩ := exists_add_of_le hi
  rw [hk, pow_add]
  suffices x ^ f.nat_degree ∈ 𝓟 by exact mul_mem_right (x ^ k) 𝓟 this
  rw [is_root.def, eval_eq_sum_range, Finset.range_add_one, Finset.sum_insert Finset.not_mem_range_self,
    Finset.sum_range, hmo.coeff_nat_degree, one_mul] at hroot
  rw [eq_neg_of_add_eq_zero_left hroot, neg_mem_iff]
  refine' Submodule.sum_mem _ fun i hi => mul_mem_right _ _ (hf.mem (Fin.is_lt i))
#align
  polynomial.is_weakly_eisenstein_at.pow_nat_degree_le_of_root_of_monic_mem Polynomial.IsWeaklyEisensteinAt.pow_nat_degree_le_of_root_of_monic_mem

theorem pow_nat_degree_le_of_aeval_zero_of_monic_mem_map {x : S} (hx : aeval x f = 0) (hmo : f.Monic) :
    ∀ i, (f.map (algebraMap R S)).natDegree ≤ i → x ^ i ∈ 𝓟.map (algebraMap R S) := by
  suffices x ^ (f.map (algebraMap R S)).natDegree ∈ 𝓟.map (algebraMap R S) by
    intro i hi
    obtain ⟨k, hk⟩ := exists_add_of_le hi
    rw [hk, pow_add]
    refine' mul_mem_right _ _ this
  rw [aeval_def, eval₂_eq_eval_map, ← is_root.def] at hx
  refine' pow_nat_degree_le_of_root_of_monic_mem (hf.map _) hx (hmo.map _) _ rfl.le
#align
  polynomial.is_weakly_eisenstein_at.pow_nat_degree_le_of_aeval_zero_of_monic_mem_map Polynomial.IsWeaklyEisensteinAt.pow_nat_degree_le_of_aeval_zero_of_monic_mem_map

end CommRing

end IsWeaklyEisensteinAt

section ScaleRoots

variable {A : Type _} [CommRing R] [CommRing A]

theorem scaleRoots.is_weakly_eisenstein_at (p : R[X]) {x : R} {P : Ideal R} (hP : x ∈ P) :
    (scaleRoots p x).IsWeaklyEisensteinAt P := by
  refine' ⟨fun i hi => _⟩
  rw [coeff_scale_roots]
  rw [nat_degree_scale_roots, ← tsub_pos_iff_lt] at hi
  exact Ideal.mul_mem_left _ _ (Ideal.pow_mem_of_mem P hP _ hi)
#align polynomial.scale_roots.is_weakly_eisenstein_at Polynomial.scaleRoots.is_weakly_eisenstein_at

theorem dvd_pow_nat_degree_of_eval₂_eq_zero {f : R →+* A} (hf : Function.Injective f) {p : R[X]} (hp : p.Monic)
    (x y : R) (z : A) (h : p.eval₂ f z = 0) (hz : f x * z = f y) : x ∣ y ^ p.natDegree := by
  rw [← nat_degree_scale_roots p x, ← Ideal.mem_span_singleton]
  refine'
    (scale_roots.is_weakly_eisenstein_at _
          (ideal.mem_span_singleton.mpr <| dvd_refl x)).pow_nat_degree_le_of_root_of_monic_mem
      _ ((monic_scale_roots_iff x).mpr hp) _ le_rfl
  rw [injective_iff_map_eq_zero'] at hf
  have := scale_roots_eval₂_eq_zero f h
  rwa [hz, Polynomial.eval₂_at_apply, hf] at this
#align polynomial.dvd_pow_nat_degree_of_eval₂_eq_zero Polynomial.dvd_pow_nat_degree_of_eval₂_eq_zero

theorem dvd_pow_nat_degree_of_aeval_eq_zero [Algebra R A] [Nontrivial A] [NoZeroSmulDivisors R A] {p : R[X]}
    (hp : p.Monic) (x y : R) (z : A) (h : Polynomial.aeval z p = 0) (hz : z * algebraMap R A x = algebraMap R A y) :
    x ∣ y ^ p.natDegree :=
  dvd_pow_nat_degree_of_eval₂_eq_zero (NoZeroSmulDivisors.algebra_map_injective R A) hp x y z h
    ((mul_comm _ _).trans hz)
#align polynomial.dvd_pow_nat_degree_of_aeval_eq_zero Polynomial.dvd_pow_nat_degree_of_aeval_eq_zero

end ScaleRoots

namespace IsEisensteinAt

section CommSemiring

variable [CommSemiring R] {𝓟 : Ideal R} {f : R[X]} (hf : f.IsEisensteinAt 𝓟)

theorem _root_.polynomial.monic.leading_coeff_not_mem (hf : f.Monic) (h : 𝓟 ≠ ⊤) : ¬f.leadingCoeff ∈ 𝓟 :=
  hf.leadingCoeff.symm ▸ (Ideal.ne_top_iff_one _).1 h
#align
  polynomial.is_eisenstein_at._root_.polynomial.monic.leading_coeff_not_mem polynomial.is_eisenstein_at._root_.polynomial.monic.leading_coeff_not_mem

theorem _root_.polynomial.monic.is_eisenstein_at_of_mem_of_not_mem (hf : f.Monic) (h : 𝓟 ≠ ⊤)
    (hmem : ∀ {n}, n < f.natDegree → f.coeff n ∈ 𝓟) (hnot_mem : f.coeff 0 ∉ 𝓟 ^ 2) : f.IsEisensteinAt 𝓟 :=
  { leading := hf.leading_coeff_not_mem h, Mem := fun n hn => hmem hn, not_mem := hnot_mem }
#align
  polynomial.is_eisenstein_at._root_.polynomial.monic.is_eisenstein_at_of_mem_of_not_mem polynomial.is_eisenstein_at._root_.polynomial.monic.is_eisenstein_at_of_mem_of_not_mem

include hf

theorem is_weakly_eisenstein_at : IsWeaklyEisensteinAt f 𝓟 :=
  ⟨fun _ => hf.Mem⟩
#align polynomial.is_eisenstein_at.is_weakly_eisenstein_at Polynomial.IsEisensteinAt.is_weakly_eisenstein_at

theorem coeff_mem {n : ℕ} (hn : n ≠ f.natDegree) : f.coeff n ∈ 𝓟 := by
  cases ne_iff_lt_or_gt.1 hn
  · exact hf.mem h
    
  · rw [coeff_eq_zero_of_nat_degree_lt h]
    exact Ideal.zero_mem _
    
#align polynomial.is_eisenstein_at.coeff_mem Polynomial.IsEisensteinAt.coeff_mem

end CommSemiring

section IsDomain

variable [CommRing R] [IsDomain R] {𝓟 : Ideal R} {f : R[X]} (hf : f.IsEisensteinAt 𝓟)

/-- If a primitive `f` satisfies `f.is_eisenstein_at 𝓟`, where `𝓟.is_prime`, then `f` is
irreducible. -/
theorem irreducible (hprime : 𝓟.IsPrime) (hu : f.IsPrimitive) (hfd0 : 0 < f.natDegree) : Irreducible f :=
  irreducible_of_eisenstein_criterion hprime hf.leading (fun n hn => hf.Mem (coe_lt_degree.1 hn))
    (nat_degree_pos_iff_degree_pos.1 hfd0) hf.not_mem hu
#align polynomial.is_eisenstein_at.irreducible Polynomial.IsEisensteinAt.irreducible

end IsDomain

end IsEisensteinAt

end Polynomial

section Cyclotomic

variable (p : ℕ)

-- mathport name: expr𝓟
local notation "𝓟" => Submodule.span ℤ {p}

open Polynomial

theorem cyclotomicCompXAddOneIsEisensteinAt [hp : Fact p.Prime] : ((cyclotomic p ℤ).comp (X + 1)).IsEisensteinAt 𝓟 := by
  refine'
    monic.is_eisenstein_at_of_mem_of_not_mem _
      (Ideal.IsPrime.ne_top <|
        (Ideal.span_singleton_prime (by exact_mod_cast hp.out.ne_zero)).2 <| Nat.prime_iff_prime_int.1 hp.out)
      (fun i hi => _) _
  · rw [show (X + 1 : ℤ[X]) = X + C 1 by simp]
    refine' (cyclotomic.monic p ℤ).comp (monic_X_add_C 1) fun h => _
    rw [nat_degree_X_add_C] at h
    exact zero_ne_one h.symm
    
  · rw [cyclotomic_eq_geom_sum hp.out, geom_sum_X_comp_X_add_one_eq_sum, ← lcoeff_apply, LinearMap.map_sum]
    conv =>
    congr
    congr
    skip
    ext
    rw [lcoeff_apply, ← C_eq_nat_cast, ← monomial_eq_C_mul_X, coeff_monomial]
    rw [nat_degree_comp, show (X + 1 : ℤ[X]) = X + C 1 by simp, nat_degree_X_add_C, mul_one, nat_degree_cyclotomic,
      Nat.totient_prime hp.out] at hi
    simp only [lt_of_lt_of_le hi (Nat.sub_le _ _), sum_ite_eq', mem_range, if_true, Ideal.submodule_span_eq,
      Ideal.mem_span_singleton]
    exact Int.coe_nat_dvd.2 (Nat.Prime.dvd_choose_self (Nat.succ_pos i) (lt_tsub_iff_right.1 hi) hp.out)
    
  · rw [coeff_zero_eq_eval_zero, eval_comp, cyclotomic_eq_geom_sum hp.out, eval_add, eval_X, eval_one, zero_add,
      eval_geom_sum, one_geom_sum, Ideal.submodule_span_eq, Ideal.span_singleton_pow, Ideal.mem_span_singleton]
    intro h
    obtain ⟨k, hk⟩ := Int.coe_nat_dvd.1 h
    rw [← mul_assoc, mul_one, mul_assoc] at hk
    nth_rw 0 [← Nat.mul_one p]  at hk
    rw [mul_right_inj' hp.out.ne_zero] at hk
    exact Nat.Prime.not_dvd_one hp.out (Dvd.intro k hk.symm)
    
#align cyclotomic_comp_X_add_one_is_eisenstein_at cyclotomicCompXAddOneIsEisensteinAt

theorem cyclotomicPrimePowCompXAddOneIsEisensteinAt [hp : Fact p.Prime] (n : ℕ) :
    ((cyclotomic (p ^ (n + 1)) ℤ).comp (X + 1)).IsEisensteinAt 𝓟 := by
  refine'
    monic.is_eisenstein_at_of_mem_of_not_mem _
      (Ideal.IsPrime.ne_top <|
        (Ideal.span_singleton_prime (by exact_mod_cast hp.out.ne_zero)).2 <| Nat.prime_iff_prime_int.1 hp.out)
      _ _
  · rw [show (X + 1 : ℤ[X]) = X + C 1 by simp]
    refine' (cyclotomic.monic _ ℤ).comp (monic_X_add_C 1) fun h => _
    rw [nat_degree_X_add_C] at h
    exact zero_ne_one h.symm
    
  · induction' n with n hn
    · intro i hi
      rw [zero_add, pow_one] at hi⊢
      exact (cyclotomicCompXAddOneIsEisensteinAt p).Mem hi
      
    · intro i hi
      rw [Ideal.submodule_span_eq, Ideal.mem_span_singleton, ← Zmod.int_coe_zmod_eq_zero_iff_dvd, ←
        Int.coe_cast_ring_hom, ← coeff_map, map_comp, map_cyclotomic, Polynomial.map_add, map_X, Polynomial.map_one,
        pow_add, pow_one, cyclotomic_mul_prime_dvd_eq_pow, pow_comp, ← Zmod.expand_card, coeff_expand hp.out.pos]
      · simp only [ite_eq_right_iff]
        rintro ⟨k, hk⟩
        rw [nat_degree_comp, show (X + 1 : ℤ[X]) = X + C 1 by simp, nat_degree_X_add_C, mul_one, nat_degree_cyclotomic,
          Nat.totient_prime_pow hp.out (Nat.succ_pos _), Nat.succ_sub_one] at hn hi
        rw [hk, pow_succ, mul_assoc] at hi
        rw [hk, mul_comm, Nat.mul_div_cancel _ hp.out.pos]
        replace hn := hn (lt_of_mul_lt_mul_left' hi)
        rw [Ideal.submodule_span_eq, Ideal.mem_span_singleton, ← Zmod.int_coe_zmod_eq_zero_iff_dvd, ←
          Int.coe_cast_ring_hom, ← coeff_map] at hn
        simpa [map_comp] using hn
        
      · exact ⟨p ^ n, by rw [pow_succ]⟩
        
      
    
  · rw [coeff_zero_eq_eval_zero, eval_comp, cyclotomic_prime_pow_eq_geom_sum hp.out, eval_add, eval_X, eval_one,
      zero_add, eval_finset_sum]
    simp only [eval_pow, eval_X, one_pow, sum_const, card_range, Nat.smul_one_eq_coe, submodule_span_eq,
      Ideal.submodule_span_eq, Ideal.span_singleton_pow, Ideal.mem_span_singleton]
    intro h
    obtain ⟨k, hk⟩ := Int.coe_nat_dvd.1 h
    rw [← mul_assoc, mul_one, mul_assoc] at hk
    nth_rw 0 [← Nat.mul_one p]  at hk
    rw [mul_right_inj' hp.out.ne_zero] at hk
    exact Nat.Prime.not_dvd_one hp.out (Dvd.intro k hk.symm)
    
#align cyclotomic_prime_pow_comp_X_add_one_is_eisenstein_at cyclotomicPrimePowCompXAddOneIsEisensteinAt

end Cyclotomic

section IsIntegral

variable {K : Type v} {L : Type z} {p : R} [CommRing R] [Field K] [Field L]

variable [Algebra K L] [Algebra R L] [Algebra R K] [IsScalarTower R K L] [IsSeparable K L]

variable [IsDomain R] [NormalizedGcdMonoid R] [IsFractionRing R K] [IsIntegrallyClosed R]

-- mathport name: expr𝓟
local notation "𝓟" => Submodule.span R {p}

open IsIntegrallyClosed PowerBasis Nat Polynomial IsScalarTower

/-- Let `K` be the field of fraction of an integrally closed domain `R` and let `L` be a separable
extension of `K`, generated by an integral power basis `B` such that the minimal polynomial of
`B.gen` is Eisenstein at `p`. Given `z : L` integral over `R`, if `Q : R[X]` is such that
`aeval B.gen Q = p • z`, then `p ∣ Q.coeff 0`. -/
theorem dvd_coeff_zero_of_aeval_eq_prime_smul_of_minpoly_is_eiseinstein_at {B : PowerBasis K L} (hp : Prime p)
    (hBint : IsIntegral R B.gen) {z : L} {Q : R[X]} (hQ : aeval B.gen Q = p • z) (hzint : IsIntegral R z)
    (hei : (minpoly R B.gen).IsEisensteinAt 𝓟) : p ∣ Q.coeff 0 := by
  -- First define some abbreviations.
  letI := B.finite_dimensional
  let P := minpoly R B.gen
  obtain ⟨n, hn⟩ := Nat.exists_eq_succ_of_ne_zero B.dim_pos.ne'
  have finrank_K_L : FiniteDimensional.finrank K L = B.dim := B.finrank
  have deg_K_P : (minpoly K B.gen).natDegree = B.dim := B.nat_degree_minpoly
  have deg_R_P : P.nat_degree = B.dim := by
    rw [← deg_K_P, minpoly.gcd_domain_eq_field_fractions' K hBint,
      (minpoly.monic hBint).nat_degree_map (algebraMap R K)]
  choose! f hf using
    hei.is_weakly_eisenstein_at.exists_mem_adjoin_mul_eq_pow_nat_degree_le (minpoly.aeval R B.gen) (minpoly.monic hBint)
  simp only [(minpoly.monic hBint).nat_degree_map, deg_R_P] at hf
  -- The Eisenstein condition shows that `p` divides `Q.coeff 0`
  -- if `p^n.succ` divides the following multiple of `Q.coeff 0^n.succ`:
  suffices p ^ n.succ ∣ Q.coeff 0 ^ n.succ * ((-1) ^ (n.succ * n) * (minpoly R B.gen).coeff 0 ^ n) by
    have hndiv : ¬p ^ 2 ∣ (minpoly R B.gen).coeff 0 := fun h =>
      hei.not_mem ((span_singleton_pow p 2).symm ▸ Ideal.mem_span_singleton.2 h)
    refine' Prime.dvd_of_pow_dvd_pow_mul_pow_of_square_not_dvd hp (_ : _ ^ n.succ ∣ _) hndiv
    convert (IsUnit.dvd_mul_right ⟨(-1) ^ (n.succ * n), rfl⟩).mpr this using 1
    push_cast
    ring_nf
    simp [pow_right_comm _ _ 2]
  -- We claim the quotient of `Q^n * _` by `p^n` is the following `r`:
  have aux : ∀ i ∈ (range (Q.nat_degree + 1)).erase 0, B.dim ≤ i + n := by
    intro i hi
    simp only [mem_range, mem_erase] at hi
    rw [hn]
    exact le_add_pred_of_pos _ hi.1
  have hintsum : IsIntegral R (z * B.gen ^ n - ∑ x : ℕ in (range (Q.nat_degree + 1)).erase 0, Q.coeff x • f (x + n)) :=
    by
    refine'
      isIntegralSub (isIntegralMul hzint (IsIntegral.pow hBint _)) (IsIntegral.sum _ fun i hi => isIntegralSmul _ _)
    exact adjoin_le_integral_closure hBint (hf _ (aux i hi)).1
  obtain ⟨r, hr⟩ := is_integral_iff.1 (is_integral_norm K hintsum)
  use r
  -- Do the computation in `K` so we can work in terms of `z` instead of `r`.
  apply IsFractionRing.injective R K
  simp only [_root_.map_mul, _root_.map_pow, _root_.map_neg, _root_.map_one]
  -- Both sides are actually norms:
  calc
    _ = norm K (Q.coeff 0 • B.gen ^ n) := _
    _ = norm K (p • (z * B.gen ^ n) - ∑ x : ℕ in (range (Q.nat_degree + 1)).erase 0, p • Q.coeff x • f (x + n)) :=
      congr_arg (norm K) (eq_sub_of_add_eq _)
    _ = _ := _
    
  · simp only [Algebra.smul_def, algebra_map_apply R K L, Algebra.norm_algebra_map, _root_.map_mul, _root_.map_pow,
      finrank_K_L, power_basis.norm_gen_eq_coeff_zero_minpoly, minpoly.gcd_domain_eq_field_fractions' K hBint,
      coeff_map, ← hn]
    ring
    
  swap
  · simp_rw [← smul_sum, ← smul_sub, Algebra.smul_def p, algebra_map_apply R K L, _root_.map_mul,
      Algebra.norm_algebra_map, finrank_K_L, hr, ← hn]
    
  calc
    _ = (Q.coeff 0 • 1 + ∑ x : ℕ in (range (Q.nat_degree + 1)).erase 0, Q.coeff x • B.gen ^ x) * B.gen ^ n := _
    _ = (Q.coeff 0 • B.gen ^ 0 + ∑ x : ℕ in (range (Q.nat_degree + 1)).erase 0, Q.coeff x • B.gen ^ x) * B.gen ^ n := by
      rw [pow_zero]
    _ = aeval B.gen Q * B.gen ^ n := _
    _ = _ := by rw [hQ, Algebra.smul_mul_assoc]
    
  · have : ∀ i ∈ (range (Q.nat_degree + 1)).erase 0, Q.coeff i • (B.gen ^ i * B.gen ^ n) = p • Q.coeff i • f (i + n) :=
      by
      intro i hi
      rw [← pow_add, ← (hf _ (aux i hi)).2, ← Algebra.smul_def, smul_smul, mul_comm _ p, smul_smul]
    simp only [add_mul, smul_mul_assoc, one_mul, sum_mul, sum_congr rfl this]
    
  · rw [aeval_eq_sum_range, Finset.add_sum_erase (range (Q.nat_degree + 1)) fun i => Q.coeff i • B.gen ^ i]
    simp
    
#align
  dvd_coeff_zero_of_aeval_eq_prime_smul_of_minpoly_is_eiseinstein_at dvd_coeff_zero_of_aeval_eq_prime_smul_of_minpoly_is_eiseinstein_at

theorem mem_adjoin_of_dvd_coeff_of_dvd_aeval {A B : Type _} [CommSemiring A] [CommRing B] [Algebra A B]
    [NoZeroSmulDivisors A B] {Q : A[X]} {p : A} {x z : B} (hp : p ≠ 0)
    (hQ : ∀ i ∈ range (Q.natDegree + 1), p ∣ Q.coeff i) (hz : aeval x Q = p • z) : z ∈ adjoin A ({x} : Set B) := by
  choose! f hf using hQ
  rw [aeval_eq_sum_range, sum_range] at hz
  conv_lhs at hz =>
  congr
  skip
  ext
  rw [hf i (mem_range.2 (Fin.is_lt i)), ← smul_smul]
  rw [← smul_sum] at hz
  rw [← smul_right_injective _ hp hz]
  exact
    Subalgebra.sum_mem _ fun _ _ =>
      Subalgebra.smul_mem _ (Subalgebra.pow_mem _ (subset_adjoin (Set.mem_singleton _)) _) _
#align mem_adjoin_of_dvd_coeff_of_dvd_aeval mem_adjoin_of_dvd_coeff_of_dvd_aeval

/-- Let `K` be the field of fraction of an integrally closed domain `R` and let `L` be a separable
extension of `K`, generated by an integral power basis `B` such that the minimal polynomial of
`B.gen` is Eisenstein at `p`. Given `z : L` integral over `R`, if `p • z ∈ adjoin R {B.gen}`, then
`z ∈ adjoin R {B.gen}`. -/
theorem mem_adjoin_of_smul_prime_smul_of_minpoly_is_eiseinstein_at {B : PowerBasis K L} (hp : Prime p)
    (hBint : IsIntegral R B.gen) {z : L} (hzint : IsIntegral R z) (hz : p • z ∈ adjoin R ({B.gen} : Set L))
    (hei : (minpoly R B.gen).IsEisensteinAt 𝓟) : z ∈ adjoin R ({B.gen} : Set L) := by
  -- First define some abbreviations.
  have hndiv : ¬p ^ 2 ∣ (minpoly R B.gen).coeff 0 := fun h =>
    hei.not_mem ((span_singleton_pow p 2).symm ▸ Ideal.mem_span_singleton.2 h)
  letI := FiniteDimensional B
  set P := minpoly R B.gen with hP
  obtain ⟨n, hn⟩ := Nat.exists_eq_succ_of_ne_zero B.dim_pos.ne'
  haveI : NoZeroSmulDivisors R L := NoZeroSmulDivisors.trans R K L
  let P₁ := P.map (algebraMap R L)
  -- There is a polynomial `Q` such that `p • z = aeval B.gen Q`. We can assume that
  -- `Q.degree < P.degree` and `Q ≠ 0`.
  rw [adjoin_singleton_eq_range_aeval] at hz
  obtain ⟨Q₁, hQ⟩ := hz
  set Q := Q₁ %ₘ P with hQ₁
  replace hQ : aeval B.gen Q = p • z
  · rw [← mod_by_monic_add_div Q₁ (minpoly.monic hBint)] at hQ
    simpa using hQ
    
  by_cases hQzero:Q = 0
  · simp only [hQzero, Algebra.smul_def, zero_eq_mul, aeval_zero] at hQ
    cases' hQ with H H₁
    · have : Function.Injective (algebraMap R L) := by
        rw [algebra_map_eq R K L]
        exact (algebraMap K L).Injective.comp (IsFractionRing.injective R K)
      exfalso
      exact hp.ne_zero ((injective_iff_map_eq_zero _).1 this _ H)
      
    · rw [H₁]
      exact Subalgebra.zero_mem _
      
    
  -- It is enough to prove that all coefficients of `Q` are divisible by `p`, by induction.
  -- The base case is `dvd_coeff_zero_of_aeval_eq_prime_smul_of_minpoly_is_eiseinstein_at`.
  refine' mem_adjoin_of_dvd_coeff_of_dvd_aeval hp.ne_zero (fun i => _) hQ
  refine' Nat.case_strong_induction_on i _ fun j hind => _
  · intro H
    exact dvd_coeff_zero_of_aeval_eq_prime_smul_of_minpoly_is_eiseinstein_at hp hBint hQ hzint hei
    
  · intro hj
    refine' hp.dvd_of_pow_dvd_pow_mul_pow_of_square_not_dvd _ hndiv
    exact n
    -- Two technical results we will need about `P.nat_degree` and `Q.nat_degree`.
    have H := degree_mod_by_monic_lt Q₁ (minpoly.monic hBint)
    rw [← hQ₁, ← hP] at H
    replace H :=
      Nat.lt_iff_add_one_le.1
        (lt_of_lt_of_le
          (lt_of_le_of_lt (Nat.lt_iff_add_one_le.1 (Nat.lt_of_succ_lt_succ (mem_range.1 hj))) (lt_succ_self _))
          (Nat.lt_iff_add_one_le.1 ((nat_degree_lt_nat_degree_iff hQzero).2 H)))
    rw [add_assoc] at H
    have Hj : Q.nat_degree + 1 = j + 1 + (Q.nat_degree - j) := by
      rw [← add_comm 1, ← add_comm 1, add_assoc, add_right_inj, ←
        Nat.add_sub_assoc (Nat.lt_of_succ_lt_succ (mem_range.1 hj)).le, add_comm, Nat.add_sub_cancel]
    -- By induction hypothesis we can find `g : ℕ → R` such that
    -- `k ∈ range (j + 1) → Q.coeff k • B.gen ^ k = (algebra_map R L) p * g k • B.gen ^ k`-
    choose! g hg using hind
    replace hg : ∀ k ∈ range (j + 1), Q.coeff k • B.gen ^ k = algebraMap R L p * g k • B.gen ^ k
    · intro k hk
      rw [hg k (mem_range_succ_iff.1 hk)
          (mem_range_succ_iff.2 (le_trans (mem_range_succ_iff.1 hk) (succ_le_iff.1 (mem_range_succ_iff.1 hj)).le)),
        Algebra.smul_def, Algebra.smul_def, RingHom.map_mul, mul_assoc]
      
    -- Since `minpoly R B.gen` is Eiseinstein, we can find `f : ℕ → L` such that
    -- `(map (algebra_map R L) (minpoly R B.gen)).nat_degree ≤ i` implies `f i ∈ adjoin R {B.gen}`
    -- and `(algebra_map R L) p * f i = B.gen ^ i`. We will also need `hf₁`, a reformulation of this
    -- property.
    choose! f hf using
      is_weakly_eisenstein_at.exists_mem_adjoin_mul_eq_pow_nat_degree_le (minpoly.aeval R B.gen) (minpoly.monic hBint)
        hei.is_weakly_eisenstein_at
    have hf₁ :
      ∀ k ∈ (range (Q.nat_degree - j)).erase 0,
        Q.coeff (j + 1 + k) • B.gen ^ (j + 1 + k) * B.gen ^ (P.nat_degree - (j + 2)) =
          (algebraMap R L) p * Q.coeff (j + 1 + k) • f (k + P.nat_degree - 1) :=
      by
      intro k hk
      rw [smul_mul_assoc, ← pow_add, ← Nat.add_sub_assoc H, ← add_assoc j 1 1, add_comm (j + 1) 1, add_assoc (j + 1),
        add_comm _ (k + P.nat_degree), Nat.add_sub_add_right, ← (hf (k + P.nat_degree - 1) _).2, mul_smul_comm]
      rw [(minpoly.monic hBint).nat_degree_map, add_comm, Nat.add_sub_assoc, le_add_iff_nonneg_right]
      · exact Nat.zero_le _
        
      · refine' one_le_iff_ne_zero.2 fun h => _
        rw [h] at hk
        simpa using hk
        
      · infer_instance
        
    -- The Eisenstein condition shows that `p` divides `Q.coeff j`
    -- if `p^n.succ` divides the following multiple of `Q.coeff (succ j)^n.succ`:
    suffices p ^ n.succ ∣ Q.coeff (succ j) ^ n.succ * (minpoly R B.gen).coeff 0 ^ (succ j + (P.nat_degree - (j + 2))) by
      convert this
      rw [Nat.succ_eq_add_one, add_assoc, ← Nat.add_sub_assoc H, ← add_assoc, add_comm (j + 1), Nat.add_sub_add_left, ←
        Nat.add_sub_assoc, Nat.add_sub_add_left, hP, ← (minpoly.monic hBint).nat_degree_map (algebraMap R K), ←
        minpoly.gcd_domain_eq_field_fractions' K hBint, nat_degree_minpoly, hn, Nat.sub_one, Nat.pred_succ]
      linarith
    -- Using `hQ : aeval B.gen Q = p • z`, we write `p • z` as a sum of terms of degree less than
    -- `j+1`, that are multiples of `p` by induction, and terms of degree at least `j+1`.
    rw [aeval_eq_sum_range, Hj, range_add, sum_union (disjoint_range_add_left_embedding _ _), sum_congr rfl hg,
      add_comm] at hQ
    -- We multiply this equality by `B.gen ^ (P.nat_degree-(j+2))`, so we can use `hf₁` on the terms
    -- we didn't know were multiples of `p`, and we take the norm on both sides.
    replace hQ := congr_arg (fun x => x * B.gen ^ (P.nat_degree - (j + 2))) hQ
    simp_rw [sum_map, add_left_embedding_apply, add_mul, sum_mul, mul_assoc] at hQ
    rw [← insert_erase (mem_range.2 (tsub_pos_iff_lt.2 <| Nat.lt_of_succ_lt_succ <| mem_range.1 hj)),
      sum_insert (not_mem_erase 0 _), add_zero, sum_congr rfl hf₁, ← mul_sum, ← mul_sum, add_assoc, ← mul_add,
      smul_mul_assoc, ← pow_add, Algebra.smul_def] at hQ
    replace hQ := congr_arg (norm K) (eq_sub_of_add_eq hQ)
    -- We obtain an equality of elements of `K`, but everything is integral, so we can move to `R`
    -- and simplify `hQ`.
    have hintsum :
      IsIntegral R
        (z * B.gen ^ (P.nat_degree - (j + 2)) -
          ((∑ x : ℕ in (range (Q.nat_degree - j)).erase 0, Q.coeff (j + 1 + x) • f (x + P.nat_degree - 1)) +
            ∑ x : ℕ in range (j + 1), g x • B.gen ^ x * B.gen ^ (P.nat_degree - (j + 2)))) :=
      by
      refine'
        isIntegralSub (isIntegralMul hzint (IsIntegral.pow hBint _))
          (isIntegralAdd (IsIntegral.sum _ fun k hk => isIntegralSmul _ _)
            (IsIntegral.sum _ fun k hk =>
              isIntegralMul (isIntegralSmul _ (IsIntegral.pow hBint _)) (IsIntegral.pow hBint _)))
      refine' adjoin_le_integral_closure hBint (hf _ _).1
      rw [(minpoly.monic hBint).nat_degree_map (algebraMap R L)]
      rw [add_comm, Nat.add_sub_assoc, le_add_iff_nonneg_right]
      · exact zero_le _
        
      · refine' one_le_iff_ne_zero.2 fun h => _
        rw [h] at hk
        simpa using hk
        
    obtain ⟨r, hr⟩ := is_integral_iff.1 (is_integral_norm K hintsum)
    rw [Algebra.smul_def, mul_assoc, ← mul_sub, _root_.map_mul, algebra_map_apply R K L, map_pow,
      Algebra.norm_algebra_map, _root_.map_mul, algebra_map_apply R K L, Algebra.norm_algebra_map, finrank B, ← hr,
      power_basis.norm_gen_eq_coeff_zero_minpoly, minpoly.gcd_domain_eq_field_fractions' K hBint, coeff_map,
      show (-1 : K) = algebraMap R K (-1) by simp, ← map_pow, ← map_pow, ← _root_.map_mul, ← map_pow, ← _root_.map_mul,
      ← map_pow, ← _root_.map_mul] at hQ
    -- We can now finish the proof.
    have hppdiv : p ^ B.dim ∣ p ^ B.dim * r := dvd_mul_of_dvd_left dvd_rfl _
    rwa [← IsFractionRing.injective R K hQ, mul_comm, ← Units.coe_neg_one, mul_pow, ← Units.coe_pow, ← Units.coe_pow,
      mul_assoc, IsUnit.dvd_mul_left _ _ _ ⟨_, rfl⟩, mul_comm, ← Nat.succ_eq_add_one, hn] at hppdiv
    
#align
  mem_adjoin_of_smul_prime_smul_of_minpoly_is_eiseinstein_at mem_adjoin_of_smul_prime_smul_of_minpoly_is_eiseinstein_at

/-- Let `K` be the field of fraction of an integrally closed domain `R` and let `L` be a separable
extension of `K`, generated by an integral power basis `B` such that the minimal polynomial of
`B.gen` is Eisenstein at `p`. Given `z : L` integral over `R`, if `p ^ n • z ∈ adjoin R {B.gen}`,
then `z ∈ adjoin R {B.gen}`. Together with `algebra.discr_mul_is_integral_mem_adjoin` this result
often allows to compute the ring of integers of `L`. -/
theorem mem_adjoin_of_smul_prime_pow_smul_of_minpoly_is_eiseinstein_at {B : PowerBasis K L} (hp : Prime p)
    (hBint : IsIntegral R B.gen) {n : ℕ} {z : L} (hzint : IsIntegral R z) (hz : p ^ n • z ∈ adjoin R ({B.gen} : Set L))
    (hei : (minpoly R B.gen).IsEisensteinAt 𝓟) : z ∈ adjoin R ({B.gen} : Set L) := by
  induction' n with n hn
  · simpa using hz
    
  · rw [pow_succ, mul_smul] at hz
    exact hn (mem_adjoin_of_smul_prime_smul_of_minpoly_is_eiseinstein_at hp hBint (isIntegralSmul _ hzint) hz hei)
    
#align
  mem_adjoin_of_smul_prime_pow_smul_of_minpoly_is_eiseinstein_at mem_adjoin_of_smul_prime_pow_smul_of_minpoly_is_eiseinstein_at

end IsIntegral

