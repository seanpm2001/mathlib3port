/-
Copyright (c) 2018 Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Y. Lewis

! This file was ported from Lean 3 source module topology.algebra.polynomial
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.AlgebraMap
import Mathbin.Data.Polynomial.Inductions
import Mathbin.Data.Polynomial.Splits
import Mathbin.RingTheory.Polynomial.Vieta
import Mathbin.Analysis.Normed.Field.Basic

/-!
# Polynomials and limits

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove the following lemmas.

* `polynomial.continuous_eval₂: `polynomial.eval₂` defines a continuous function.
* `polynomial.continuous_aeval: `polynomial.aeval` defines a continuous function;
  we also prove convenience lemmas `polynomial.continuous_at_aeval`,
  `polynomial.continuous_within_at_aeval`, `polynomial.continuous_on_aeval`.
* `polynomial.continuous`:  `polynomial.eval` defines a continuous functions;
  we also prove convenience lemmas `polynomial.continuous_at`, `polynomial.continuous_within_at`,
  `polynomial.continuous_on`.
* `polynomial.tendsto_norm_at_top`: `λ x, ‖polynomial.eval (z x) p‖` tends to infinity provided that
  `λ x, ‖z x‖` tends to infinity and `0 < degree p`;
* `polynomial.tendsto_abv_eval₂_at_top`, `polynomial.tendsto_abv_at_top`,
  `polynomial.tendsto_abv_aeval_at_top`: a few versions of the previous statement for
  `is_absolute_value abv` instead of norm.

## Tags

polynomial, continuity
-/


open IsAbsoluteValue Filter

namespace Polynomial

open scoped Polynomial

section TopologicalSemiring

variable {R S : Type _} [Semiring R] [TopologicalSpace R] [TopologicalSemiring R] (p : R[X])

#print Polynomial.continuous_eval₂ /-
@[continuity]
protected theorem continuous_eval₂ [Semiring S] (p : S[X]) (f : S →+* R) :
    Continuous fun x => p.eval₂ f x :=
  by
  simp only [eval₂_eq_sum, Finsupp.sum]
  exact continuous_finset_sum _ fun c hc => continuous_const.mul (continuous_pow _)
#align polynomial.continuous_eval₂ Polynomial.continuous_eval₂
-/

#print Polynomial.continuous /-
@[continuity]
protected theorem continuous : Continuous fun x => p.eval x :=
  p.continuous_eval₂ _
#align polynomial.continuous Polynomial.continuous
-/

#print Polynomial.continuousAt /-
protected theorem continuousAt {a : R} : ContinuousAt (fun x => p.eval x) a :=
  p.Continuous.ContinuousAt
#align polynomial.continuous_at Polynomial.continuousAt
-/

#print Polynomial.continuousWithinAt /-
protected theorem continuousWithinAt {s a} : ContinuousWithinAt (fun x => p.eval x) s a :=
  p.Continuous.ContinuousWithinAt
#align polynomial.continuous_within_at Polynomial.continuousWithinAt
-/

#print Polynomial.continuousOn /-
protected theorem continuousOn {s} : ContinuousOn (fun x => p.eval x) s :=
  p.Continuous.ContinuousOn
#align polynomial.continuous_on Polynomial.continuousOn
-/

end TopologicalSemiring

section TopologicalAlgebra

variable {R A : Type _} [CommSemiring R] [Semiring A] [Algebra R A] [TopologicalSpace A]
  [TopologicalSemiring A] (p : R[X])

#print Polynomial.continuous_aeval /-
@[continuity]
protected theorem continuous_aeval : Continuous fun x : A => aeval x p :=
  p.continuous_eval₂ _
#align polynomial.continuous_aeval Polynomial.continuous_aeval
-/

#print Polynomial.continuousAt_aeval /-
protected theorem continuousAt_aeval {a : A} : ContinuousAt (fun x : A => aeval x p) a :=
  p.continuous_aeval.ContinuousAt
#align polynomial.continuous_at_aeval Polynomial.continuousAt_aeval
-/

#print Polynomial.continuousWithinAt_aeval /-
protected theorem continuousWithinAt_aeval {s a} :
    ContinuousWithinAt (fun x : A => aeval x p) s a :=
  p.continuous_aeval.ContinuousWithinAt
#align polynomial.continuous_within_at_aeval Polynomial.continuousWithinAt_aeval
-/

#print Polynomial.continuousOn_aeval /-
protected theorem continuousOn_aeval {s} : ContinuousOn (fun x : A => aeval x p) s :=
  p.continuous_aeval.ContinuousOn
#align polynomial.continuous_on_aeval Polynomial.continuousOn_aeval
-/

end TopologicalAlgebra

#print Polynomial.tendsto_abv_eval₂_atTop /-
theorem tendsto_abv_eval₂_atTop {R S k α : Type _} [Semiring R] [Ring S] [LinearOrderedField k]
    (f : R →+* S) (abv : S → k) [IsAbsoluteValue abv] (p : R[X]) (hd : 0 < degree p)
    (hf : f p.leadingCoeff ≠ 0) {l : Filter α} {z : α → S} (hz : Tendsto (abv ∘ z) l atTop) :
    Tendsto (fun x => abv (p.eval₂ f (z x))) l atTop :=
  by
  revert hf; refine' degree_pos_induction_on p hd _ _ _ <;> clear hd p
  · rintro c - hc
    rw [leading_coeff_mul_X, leading_coeff_C] at hc 
    simpa [abv_mul abv] using hz.const_mul_at_top ((abv_pos abv).2 hc)
  · intro p hpd ihp hf
    rw [leading_coeff_mul_X] at hf 
    simpa [abv_mul abv] using (ihp hf).atTop_mul_atTop hz
  · intro p a hd ihp hf
    rw [add_comm, leading_coeff_add_of_degree_lt (degree_C_le.trans_lt hd)] at hf 
    refine' tendsto_at_top_of_add_const_right (abv (-f a)) _
    refine' tendsto_at_top_mono (fun _ => abv_add abv _ _) _
    simpa using ihp hf
#align polynomial.tendsto_abv_eval₂_at_top Polynomial.tendsto_abv_eval₂_atTop
-/

#print Polynomial.tendsto_abv_atTop /-
theorem tendsto_abv_atTop {R k α : Type _} [Ring R] [LinearOrderedField k] (abv : R → k)
    [IsAbsoluteValue abv] (p : R[X]) (h : 0 < degree p) {l : Filter α} {z : α → R}
    (hz : Tendsto (abv ∘ z) l atTop) : Tendsto (fun x => abv (p.eval (z x))) l atTop :=
  tendsto_abv_eval₂_atTop _ _ _ h (mt leadingCoeff_eq_zero.1 <| ne_zero_of_degree_gt h) hz
#align polynomial.tendsto_abv_at_top Polynomial.tendsto_abv_atTop
-/

#print Polynomial.tendsto_abv_aeval_atTop /-
theorem tendsto_abv_aeval_atTop {R A k α : Type _} [CommSemiring R] [Ring A] [Algebra R A]
    [LinearOrderedField k] (abv : A → k) [IsAbsoluteValue abv] (p : R[X]) (hd : 0 < degree p)
    (h₀ : algebraMap R A p.leadingCoeff ≠ 0) {l : Filter α} {z : α → A}
    (hz : Tendsto (abv ∘ z) l atTop) : Tendsto (fun x => abv (aeval (z x) p)) l atTop :=
  tendsto_abv_eval₂_atTop _ abv p hd h₀ hz
#align polynomial.tendsto_abv_aeval_at_top Polynomial.tendsto_abv_aeval_atTop
-/

variable {α R : Type _} [NormedRing R] [IsAbsoluteValue (norm : R → ℝ)]

#print Polynomial.tendsto_norm_atTop /-
theorem tendsto_norm_atTop (p : R[X]) (h : 0 < degree p) {l : Filter α} {z : α → R}
    (hz : Tendsto (fun x => ‖z x‖) l atTop) : Tendsto (fun x => ‖p.eval (z x)‖) l atTop :=
  p.tendsto_abv_atTop norm h hz
#align polynomial.tendsto_norm_at_top Polynomial.tendsto_norm_atTop
-/

#print Polynomial.exists_forall_norm_le /-
theorem exists_forall_norm_le [ProperSpace R] (p : R[X]) : ∃ x, ∀ y, ‖p.eval x‖ ≤ ‖p.eval y‖ :=
  if hp0 : 0 < degree p then
    p.Continuous.norm.exists_forall_le <| p.tendsto_norm_atTop hp0 tendsto_norm_cocompact_atTop
  else ⟨p.coeff 0, by rw [eq_C_of_degree_le_zero (le_of_not_gt hp0)] <;> simp⟩
#align polynomial.exists_forall_norm_le Polynomial.exists_forall_norm_le
-/

section Roots

open scoped Polynomial NNReal

variable {F K : Type _} [CommRing F] [NormedField K]

open Multiset

#print Polynomial.eq_one_of_roots_le /-
theorem eq_one_of_roots_le {p : F[X]} {f : F →+* K} {B : ℝ} (hB : B < 0) (h1 : p.Monic)
    (h2 : Splits f p) (h3 : ∀ z ∈ (map f p).roots, ‖z‖ ≤ B) : p = 1 :=
  h1.natDegree_eq_zero_iff_eq_one.mp
    (by
      contrapose! hB
      rw [← h1.nat_degree_map f, nat_degree_eq_card_roots' h2] at hB 
      obtain ⟨z, hz⟩ := card_pos_iff_exists_mem.mp (zero_lt_iff.mpr hB)
      exact le_trans (norm_nonneg _) (h3 z hz))
#align polynomial.eq_one_of_roots_le Polynomial.eq_one_of_roots_le
-/

#print Polynomial.coeff_le_of_roots_le /-
theorem coeff_le_of_roots_le {p : F[X]} {f : F →+* K} {B : ℝ} (i : ℕ) (h1 : p.Monic)
    (h2 : Splits f p) (h3 : ∀ z ∈ (map f p).roots, ‖z‖ ≤ B) :
    ‖(map f p).coeff i‖ ≤ B ^ (p.natDegree - i) * p.natDegree.choose i :=
  by
  obtain hB | hB := lt_or_le B 0
  · rw [eq_one_of_roots_le hB h1 h2 h3, Polynomial.map_one, nat_degree_one, zero_tsub, pow_zero,
      one_mul, coeff_one]
    split_ifs <;> norm_num [h]
  rw [← h1.nat_degree_map f]
  obtain hi | hi := lt_or_le (map f p).natDegree i
  · rw [coeff_eq_zero_of_nat_degree_lt hi, norm_zero]; positivity
  rw [coeff_eq_esymm_roots_of_splits ((splits_id_iff_splits f).2 h2) hi, (h1.map _).leadingCoeff,
    one_mul, norm_mul, norm_pow, norm_neg, norm_one, one_pow, one_mul]
  apply ((norm_multiset_sum_le _).trans <| sum_le_card_nsmul _ _ fun r hr => _).trans
  ·
    rw [Multiset.map_map, card_map, card_powerset_len, ← nat_degree_eq_card_roots' h2,
      Nat.choose_symm hi, mul_comm, nsmul_eq_mul]
  simp_rw [Multiset.mem_map] at hr 
  obtain ⟨_, ⟨s, hs, rfl⟩, rfl⟩ := hr
  rw [mem_powerset_len] at hs 
  lift B to ℝ≥0 using hB
  rw [← coe_nnnorm, ← NNReal.coe_pow, NNReal.coe_le_coe, ← nnnormHom_apply, ← MonoidHom.coe_coe,
    MonoidHom.map_multiset_prod]
  refine' (prod_le_pow_card _ B fun x hx => _).trans_eq (by rw [card_map, hs.2])
  obtain ⟨z, hz, rfl⟩ := Multiset.mem_map.1 hx
  exact h3 z (mem_of_le hs.1 hz)
#align polynomial.coeff_le_of_roots_le Polynomial.coeff_le_of_roots_le
-/

#print Polynomial.coeff_bdd_of_roots_le /-
/-- The coefficients of the monic polynomials of bounded degree with bounded roots are
uniformely bounded. -/
theorem coeff_bdd_of_roots_le {B : ℝ} {d : ℕ} (f : F →+* K) {p : F[X]} (h1 : p.Monic)
    (h2 : Splits f p) (h3 : p.natDegree ≤ d) (h4 : ∀ z ∈ (map f p).roots, ‖z‖ ≤ B) (i : ℕ) :
    ‖(map f p).coeff i‖ ≤ max B 1 ^ d * d.choose (d / 2) :=
  by
  obtain hB | hB := le_or_lt 0 B
  · apply (coeff_le_of_roots_le i h1 h2 h4).trans
    calc
      _ ≤ max B 1 ^ (p.nat_degree - i) * p.nat_degree.choose i :=
        mul_le_mul_of_nonneg_right (pow_le_pow_of_le_left hB (le_max_left _ _) _) _
      _ ≤ max B 1 ^ d * p.nat_degree.choose i :=
        (mul_le_mul_of_nonneg_right ((pow_mono (le_max_right _ _)) (le_trans (Nat.sub_le _ _) h3))
          _)
      _ ≤ max B 1 ^ d * d.choose (d / 2) :=
        mul_le_mul_of_nonneg_left
          (nat.cast_le.mpr ((i.choose_mono h3).trans (i.choose_le_middle d))) _
    all_goals positivity
  · rw [eq_one_of_roots_le hB h1 h2 h4, Polynomial.map_one, coeff_one]
    refine' trans _ (one_le_mul_of_one_le_of_one_le (one_le_pow_of_one_le (le_max_right B 1) d) _)
    · split_ifs <;> norm_num
    · exact_mod_cast nat.succ_le_iff.mpr (Nat.choose_pos (d.div_le_self 2))
#align polynomial.coeff_bdd_of_roots_le Polynomial.coeff_bdd_of_roots_le
-/

end Roots

end Polynomial

