/-
Copyright (c) 2020 Paul van Wamelen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Paul van Wamelen

! This file was ported from Lean 3 source module number_theory.pythagorean_triples
! leanprover-community/mathlib commit e8638a0fcaf73e4500469f368ef9494e495099b3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Field.Basic
import Mathbin.RingTheory.Int.Basic
import Mathbin.Tactic.Ring
import Mathbin.Tactic.RingExp
import Mathbin.Tactic.FieldSimp
import Mathbin.Data.Int.NatPrime
import Mathbin.Data.Zmod.Basic

/-!
# Pythagorean Triples

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The main result is the classification of Pythagorean triples. The final result is for general
Pythagorean triples. It follows from the more interesting relatively prime case. We use the
"rational parametrization of the circle" method for the proof. The parametrization maps the point
`(x / z, y / z)` to the slope of the line through `(-1 , 0)` and `(x / z, y / z)`. This quickly
shows that `(x / z, y / z) = (2 * m * n / (m ^ 2 + n ^ 2), (m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2))` where
`m / n` is the slope. In order to identify numerators and denominators we now need results showing
that these are coprime. This is easy except for the prime 2. In order to deal with that we have to
analyze the parity of `x`, `y`, `m` and `n` and eliminate all the impossible cases. This takes up
the bulk of the proof below.
-/


#print sq_ne_two_fin_zmod_four /-
theorem sq_ne_two_fin_zmod_four (z : ZMod 4) : z * z ≠ 2 :=
  by
  change Fin 4 at z 
  fin_cases z <;> norm_num [Fin.ext_iff, Fin.val_bit0, Fin.val_bit1]
#align sq_ne_two_fin_zmod_four sq_ne_two_fin_zmod_four
-/

#print Int.sq_ne_two_mod_four /-
theorem Int.sq_ne_two_mod_four (z : ℤ) : z * z % 4 ≠ 2 :=
  by
  suffices ¬z * z % (4 : ℕ) = 2 % (4 : ℕ) by norm_num at this 
  rw [← ZMod.int_cast_eq_int_cast_iff']
  simpa using sq_ne_two_fin_zmod_four _
#align int.sq_ne_two_mod_four Int.sq_ne_two_mod_four
-/

noncomputable section

open scoped Classical

#print PythagoreanTriple /-
/-- Three integers `x`, `y`, and `z` form a Pythagorean triple if `x * x + y * y = z * z`. -/
def PythagoreanTriple (x y z : ℤ) : Prop :=
  x * x + y * y = z * z
#align pythagorean_triple PythagoreanTriple
-/

#print pythagoreanTriple_comm /-
/-- Pythagorean triples are interchangable, i.e `x * x + y * y = y * y + x * x = z * z`.
This comes from additive commutativity. -/
theorem pythagoreanTriple_comm {x y z : ℤ} : PythagoreanTriple x y z ↔ PythagoreanTriple y x z := by
  delta PythagoreanTriple; rw [add_comm]
#align pythagorean_triple_comm pythagoreanTriple_comm
-/

#print PythagoreanTriple.zero /-
/-- The zeroth Pythagorean triple is all zeros. -/
theorem PythagoreanTriple.zero : PythagoreanTriple 0 0 0 := by
  simp only [PythagoreanTriple, MulZeroClass.zero_mul, zero_add]
#align pythagorean_triple.zero PythagoreanTriple.zero
-/

namespace PythagoreanTriple

variable {x y z : ℤ} (h : PythagoreanTriple x y z)

#print PythagoreanTriple.eq /-
theorem eq : x * x + y * y = z * z :=
  h
#align pythagorean_triple.eq PythagoreanTriple.eq
-/

#print PythagoreanTriple.symm /-
@[symm]
theorem symm : PythagoreanTriple y x z := by rwa [pythagoreanTriple_comm]
#align pythagorean_triple.symm PythagoreanTriple.symm
-/

#print PythagoreanTriple.mul /-
/-- A triple is still a triple if you multiply `x`, `y` and `z`
by a constant `k`. -/
theorem mul (k : ℤ) : PythagoreanTriple (k * x) (k * y) (k * z) :=
  calc
    k * x * (k * x) + k * y * (k * y) = k ^ 2 * (x * x + y * y) := by ring
    _ = k ^ 2 * (z * z) := by rw [h.eq]
    _ = k * z * (k * z) := by ring
#align pythagorean_triple.mul PythagoreanTriple.mul
-/

#print PythagoreanTriple.mul_iff /-
/-- `(k*x, k*y, k*z)` is a Pythagorean triple if and only if
`(x, y, z)` is also a triple. -/
theorem mul_iff (k : ℤ) (hk : k ≠ 0) :
    PythagoreanTriple (k * x) (k * y) (k * z) ↔ PythagoreanTriple x y z :=
  by
  refine' ⟨_, fun h => h.mul k⟩
  simp only [PythagoreanTriple]
  intro h
  rw [← mul_left_inj' (mul_ne_zero hk hk)]
  convert h using 1 <;> ring
#align pythagorean_triple.mul_iff PythagoreanTriple.mul_iff
-/

#print PythagoreanTriple.IsClassified /-
/-- A Pythagorean triple `x, y, z` is “classified” if there exist integers `k, m, n` such that
either
 * `x = k * (m ^ 2 - n ^ 2)` and `y = k * (2 * m * n)`, or
 * `x = k * (2 * m * n)` and `y = k * (m ^ 2 - n ^ 2)`. -/
@[nolint unused_arguments]
def IsClassified :=
  ∃ k m n : ℤ,
    (x = k * (m ^ 2 - n ^ 2) ∧ y = k * (2 * m * n) ∨
        x = k * (2 * m * n) ∧ y = k * (m ^ 2 - n ^ 2)) ∧
      Int.gcd m n = 1
#align pythagorean_triple.is_classified PythagoreanTriple.IsClassified
-/

#print PythagoreanTriple.IsPrimitiveClassified /-
/-- A primitive pythogorean triple `x, y, z` is a pythagorean triple with `x` and `y` coprime.
 Such a triple is “primitively classified” if there exist coprime integers `m, n` such that either
 * `x = m ^ 2 - n ^ 2` and `y = 2 * m * n`, or
 * `x = 2 * m * n` and `y = m ^ 2 - n ^ 2`.
-/
@[nolint unused_arguments]
def IsPrimitiveClassified :=
  ∃ m n : ℤ,
    (x = m ^ 2 - n ^ 2 ∧ y = 2 * m * n ∨ x = 2 * m * n ∧ y = m ^ 2 - n ^ 2) ∧
      Int.gcd m n = 1 ∧ (m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0)
#align pythagorean_triple.is_primitive_classified PythagoreanTriple.IsPrimitiveClassified
-/

#print PythagoreanTriple.mul_isClassified /-
theorem mul_isClassified (k : ℤ) (hc : h.IsClassified) : (h.mul k).IsClassified :=
  by
  obtain ⟨l, m, n, ⟨⟨rfl, rfl⟩ | ⟨rfl, rfl⟩, co⟩⟩ := hc
  · use k * l, m, n; apply And.intro _ co; left; constructor <;> ring
  · use k * l, m, n; apply And.intro _ co; right; constructor <;> ring
#align pythagorean_triple.mul_is_classified PythagoreanTriple.mul_isClassified
-/

#print PythagoreanTriple.even_odd_of_coprime /-
theorem even_odd_of_coprime (hc : Int.gcd x y = 1) :
    x % 2 = 0 ∧ y % 2 = 1 ∨ x % 2 = 1 ∧ y % 2 = 0 :=
  by
  cases' Int.emod_two_eq_zero_or_one x with hx hx <;>
    cases' Int.emod_two_eq_zero_or_one y with hy hy
  · -- x even, y even
    exfalso
    apply Nat.not_coprime_of_dvd_of_dvd (by decide : 1 < 2) _ _ hc
    · apply Int.coe_nat_dvd_left.1; apply Int.dvd_of_emod_eq_zero hx
    · apply Int.coe_nat_dvd_left.1; apply Int.dvd_of_emod_eq_zero hy
  · left; exact ⟨hx, hy⟩
  -- x even, y odd
  · right; exact ⟨hx, hy⟩
  -- x odd, y even
  · -- x odd, y odd
    exfalso
    obtain ⟨x0, y0, rfl, rfl⟩ : ∃ x0 y0, x = x0 * 2 + 1 ∧ y = y0 * 2 + 1 :=
      by
      cases' exists_eq_mul_left_of_dvd (Int.dvd_sub_of_emod_eq hx) with x0 hx2
      cases' exists_eq_mul_left_of_dvd (Int.dvd_sub_of_emod_eq hy) with y0 hy2
      rw [sub_eq_iff_eq_add] at hx2 hy2 ; exact ⟨x0, y0, hx2, hy2⟩
    apply Int.sq_ne_two_mod_four z
    rw [show z * z = 4 * (x0 * x0 + x0 + y0 * y0 + y0) + 2 by rw [← h.eq]; ring]
    norm_num [Int.add_emod]
#align pythagorean_triple.even_odd_of_coprime PythagoreanTriple.even_odd_of_coprime
-/

#print PythagoreanTriple.gcd_dvd /-
theorem gcd_dvd : (Int.gcd x y : ℤ) ∣ z :=
  by
  by_cases h0 : Int.gcd x y = 0
  · have hx : x = 0 := by apply int.nat_abs_eq_zero.mp; apply Nat.eq_zero_of_gcd_eq_zero_left h0
    have hy : y = 0 := by apply int.nat_abs_eq_zero.mp; apply Nat.eq_zero_of_gcd_eq_zero_right h0
    have hz : z = 0 := by
      simpa only [PythagoreanTriple, hx, hy, add_zero, zero_eq_mul, MulZeroClass.mul_zero,
        or_self_iff] using h
    simp only [hz, dvd_zero]
  obtain ⟨k, x0, y0, k0, h2, rfl, rfl⟩ :
    ∃ (k : ℕ) (x0 y0 : _), 0 < k ∧ Int.gcd x0 y0 = 1 ∧ x = x0 * k ∧ y = y0 * k :=
    Int.exists_gcd_one' (Nat.pos_of_ne_zero h0)
  rw [Int.gcd_mul_right, h2, Int.natAbs_ofNat, one_mul]
  rw [← Int.pow_dvd_pow_iff zero_lt_two, sq z, ← h.eq]
  rw [(by ring : x0 * k * (x0 * k) + y0 * k * (y0 * k) = k ^ 2 * (x0 * x0 + y0 * y0))]
  exact dvd_mul_right _ _
#align pythagorean_triple.gcd_dvd PythagoreanTriple.gcd_dvd
-/

#print PythagoreanTriple.normalize /-
theorem normalize : PythagoreanTriple (x / Int.gcd x y) (y / Int.gcd x y) (z / Int.gcd x y) :=
  by
  by_cases h0 : Int.gcd x y = 0
  · have hx : x = 0 := by apply int.nat_abs_eq_zero.mp; apply Nat.eq_zero_of_gcd_eq_zero_left h0
    have hy : y = 0 := by apply int.nat_abs_eq_zero.mp; apply Nat.eq_zero_of_gcd_eq_zero_right h0
    have hz : z = 0 := by
      simpa only [PythagoreanTriple, hx, hy, add_zero, zero_eq_mul, MulZeroClass.mul_zero,
        or_self_iff] using h
    simp only [hx, hy, hz, Int.zero_div]; exact zero
  rcases h.gcd_dvd with ⟨z0, rfl⟩
  obtain ⟨k, x0, y0, k0, h2, rfl, rfl⟩ :
    ∃ (k : ℕ) (x0 y0 : _), 0 < k ∧ Int.gcd x0 y0 = 1 ∧ x = x0 * k ∧ y = y0 * k :=
    Int.exists_gcd_one' (Nat.pos_of_ne_zero h0)
  have hk : (k : ℤ) ≠ 0 := by norm_cast; rwa [pos_iff_ne_zero] at k0 
  rw [Int.gcd_mul_right, h2, Int.natAbs_ofNat, one_mul] at h ⊢
  rw [mul_comm x0, mul_comm y0, mul_iff k hk] at h 
  rwa [Int.mul_ediv_cancel _ hk, Int.mul_ediv_cancel _ hk, Int.mul_ediv_cancel_left _ hk]
#align pythagorean_triple.normalize PythagoreanTriple.normalize
-/

#print PythagoreanTriple.isClassified_of_isPrimitiveClassified /-
theorem isClassified_of_isPrimitiveClassified (hp : h.IsPrimitiveClassified) : h.IsClassified :=
  by
  obtain ⟨m, n, H⟩ := hp
  use 1, m, n
  rcases H with ⟨t, co, pp⟩
  rw [one_mul, one_mul]
  exact ⟨t, co⟩
#align pythagorean_triple.is_classified_of_is_primitive_classified PythagoreanTriple.isClassified_of_isPrimitiveClassified
-/

#print PythagoreanTriple.isClassified_of_normalize_isPrimitiveClassified /-
theorem isClassified_of_normalize_isPrimitiveClassified (hc : h.normalize.IsPrimitiveClassified) :
    h.IsClassified :=
  by
  convert
      h.normalize.mul_is_classified (Int.gcd x y)
        (is_classified_of_is_primitive_classified h.normalize hc) <;>
    rw [Int.mul_ediv_cancel']
  · exact Int.gcd_dvd_left x y
  · exact Int.gcd_dvd_right x y
  · exact h.gcd_dvd
#align pythagorean_triple.is_classified_of_normalize_is_primitive_classified PythagoreanTriple.isClassified_of_normalize_isPrimitiveClassified
-/

#print PythagoreanTriple.ne_zero_of_coprime /-
theorem ne_zero_of_coprime (hc : Int.gcd x y = 1) : z ≠ 0 :=
  by
  suffices 0 < z * z by rintro rfl; norm_num at this 
  rw [← h.eq, ← sq, ← sq]
  have hc' : Int.gcd x y ≠ 0 := by rw [hc]; exact one_ne_zero
  cases' Int.ne_zero_of_gcd hc' with hxz hyz
  · apply lt_add_of_pos_of_le (sq_pos_of_ne_zero x hxz) (sq_nonneg y)
  · apply lt_add_of_le_of_pos (sq_nonneg x) (sq_pos_of_ne_zero y hyz)
#align pythagorean_triple.ne_zero_of_coprime PythagoreanTriple.ne_zero_of_coprime
-/

#print PythagoreanTriple.isPrimitiveClassified_of_coprime_of_zero_left /-
theorem isPrimitiveClassified_of_coprime_of_zero_left (hc : Int.gcd x y = 1) (hx : x = 0) :
    h.IsPrimitiveClassified := by
  subst x
  change Nat.gcd 0 (Int.natAbs y) = 1 at hc 
  rw [Nat.gcd_zero_left (Int.natAbs y)] at hc 
  cases' Int.natAbs_eq y with hy hy
  · use 1, 0; rw [hy, hc, Int.gcd_zero_right]; norm_num
  · use 0, 1; rw [hy, hc, Int.gcd_zero_left]; norm_num
#align pythagorean_triple.is_primitive_classified_of_coprime_of_zero_left PythagoreanTriple.isPrimitiveClassified_of_coprime_of_zero_left
-/

#print PythagoreanTriple.coprime_of_coprime /-
theorem coprime_of_coprime (hc : Int.gcd x y = 1) : Int.gcd y z = 1 :=
  by
  by_contra H
  obtain ⟨p, hp, hpy, hpz⟩ := nat.prime.not_coprime_iff_dvd.mp H
  apply hp.not_dvd_one
  rw [← hc]
  apply Nat.dvd_gcd (Int.Prime.dvd_natAbs_of_coe_dvd_sq hp _ _) hpy
  rw [sq, eq_sub_of_add_eq h]
  rw [← Int.coe_nat_dvd_left] at hpy hpz 
  exact dvd_sub (hpz.mul_right _) (hpy.mul_right _)
#align pythagorean_triple.coprime_of_coprime PythagoreanTriple.coprime_of_coprime
-/

end PythagoreanTriple

section circleEquivGen

/-!
### A parametrization of the unit circle

For the classification of pythogorean triples, we will use a parametrization of the unit circle.
-/


variable {K : Type _} [Field K]

#print circleEquivGen /-
/-- A parameterization of the unit circle that is useful for classifying Pythagorean triples.
 (To be applied in the case where `K = ℚ`.) -/
def circleEquivGen (hk : ∀ x : K, 1 + x ^ 2 ≠ 0) :
    K ≃ { p : K × K // p.1 ^ 2 + p.2 ^ 2 = 1 ∧ p.2 ≠ -1 }
    where
  toFun x :=
    ⟨⟨2 * x / (1 + x ^ 2), (1 - x ^ 2) / (1 + x ^ 2)⟩, by field_simp [hk x, div_pow]; ring,
      by
      simp only [Ne.def, div_eq_iff (hk x), neg_mul, one_mul, neg_add, sub_eq_add_neg, add_left_inj]
      simpa only [eq_neg_iff_add_eq_zero, one_pow] using hk 1⟩
  invFun p := (p : K × K).1 / ((p : K × K).2 + 1)
  left_inv x := by
    have h2 : (1 + 1 : K) = 2 := rfl
    have h3 : (2 : K) ≠ 0 := by convert hk 1; rw [one_pow 2, h2]
    field_simp [hk x, h2, add_assoc, add_comm, add_sub_cancel'_right, mul_comm]
  right_inv := fun ⟨⟨x, y⟩, hxy, hy⟩ =>
    by
    change x ^ 2 + y ^ 2 = 1 at hxy 
    have h2 : y + 1 ≠ 0 := mt eq_neg_of_add_eq_zero_left hy
    have h3 : (y + 1) ^ 2 + x ^ 2 = 2 * (y + 1) := by
      rw [(add_neg_eq_iff_eq_add.mpr hxy.symm).symm]; ring
    have h4 : (2 : K) ≠ 0 := by convert hk 1; rw [one_pow 2]; rfl
    simp only [Prod.mk.inj_iff, Subtype.mk_eq_mk]
    constructor
    · field_simp [h3]; ring
    · field_simp [h3]; rw [← add_neg_eq_iff_eq_add.mpr hxy.symm]; ring
#align circle_equiv_gen circleEquivGen
-/

#print circleEquivGen_apply /-
@[simp]
theorem circleEquivGen_apply (hk : ∀ x : K, 1 + x ^ 2 ≠ 0) (x : K) :
    (circleEquivGen hk x : K × K) = ⟨2 * x / (1 + x ^ 2), (1 - x ^ 2) / (1 + x ^ 2)⟩ :=
  rfl
#align circle_equiv_apply circleEquivGen_apply
-/

#print circleEquivGen_symm_apply /-
@[simp]
theorem circleEquivGen_symm_apply (hk : ∀ x : K, 1 + x ^ 2 ≠ 0)
    (v : { p : K × K // p.1 ^ 2 + p.2 ^ 2 = 1 ∧ p.2 ≠ -1 }) :
    (circleEquivGen hk).symm v = (v : K × K).1 / ((v : K × K).2 + 1) :=
  rfl
#align circle_equiv_symm_apply circleEquivGen_symm_apply
-/

end circleEquivGen

private theorem coprime_sq_sub_sq_add_of_even_odd {m n : ℤ} (h : Int.gcd m n = 1) (hm : m % 2 = 0)
    (hn : n % 2 = 1) : Int.gcd (m ^ 2 - n ^ 2) (m ^ 2 + n ^ 2) = 1 :=
  by
  by_contra H
  obtain ⟨p, hp, hp1, hp2⟩ := nat.prime.not_coprime_iff_dvd.mp H
  rw [← Int.coe_nat_dvd_left] at hp1 hp2 
  have h2m : (p : ℤ) ∣ 2 * m ^ 2 := by convert dvd_add hp2 hp1; ring
  have h2n : (p : ℤ) ∣ 2 * n ^ 2 := by convert dvd_sub hp2 hp1; ring
  have hmc : p = 2 ∨ p ∣ Int.natAbs m := prime_two_or_dvd_of_dvd_two_mul_pow_self_two hp h2m
  have hnc : p = 2 ∨ p ∣ Int.natAbs n := prime_two_or_dvd_of_dvd_two_mul_pow_self_two hp h2n
  by_cases h2 : p = 2
  · have h3 : (m ^ 2 + n ^ 2) % 2 = 1 := by norm_num [sq, Int.add_emod, Int.mul_emod, hm, hn]
    have h4 : (m ^ 2 + n ^ 2) % 2 = 0 := by apply Int.emod_eq_zero_of_dvd; rwa [h2] at hp2 
    rw [h4] at h3 ; exact zero_ne_one h3
  · apply hp.not_dvd_one
    rw [← h]
    exact Nat.dvd_gcd (Or.resolve_left hmc h2) (Or.resolve_left hnc h2)

private theorem coprime_sq_sub_sq_add_of_odd_even {m n : ℤ} (h : Int.gcd m n = 1) (hm : m % 2 = 1)
    (hn : n % 2 = 0) : Int.gcd (m ^ 2 - n ^ 2) (m ^ 2 + n ^ 2) = 1 :=
  by
  rw [Int.gcd, ← Int.natAbs_neg (m ^ 2 - n ^ 2)]
  rw [(by ring : -(m ^ 2 - n ^ 2) = n ^ 2 - m ^ 2), add_comm]
  apply coprime_sq_sub_sq_add_of_even_odd _ hn hm; rwa [Int.gcd_comm]

private theorem coprime_sq_sub_mul_of_even_odd {m n : ℤ} (h : Int.gcd m n = 1) (hm : m % 2 = 0)
    (hn : n % 2 = 1) : Int.gcd (m ^ 2 - n ^ 2) (2 * m * n) = 1 :=
  by
  by_contra H
  obtain ⟨p, hp, hp1, hp2⟩ := nat.prime.not_coprime_iff_dvd.mp H
  rw [← Int.coe_nat_dvd_left] at hp1 hp2 
  have hnp : ¬(p : ℤ) ∣ Int.gcd m n := by rw [h]; norm_cast;
    exact mt nat.dvd_one.mp (Nat.Prime.ne_one hp)
  cases' Int.Prime.dvd_mul hp hp2 with hp2m hpn
  · rw [Int.natAbs_mul] at hp2m 
    cases' (Nat.Prime.dvd_mul hp).mp hp2m with hp2 hpm
    · have hp2' : p = 2 := (Nat.le_of_dvd zero_lt_two hp2).antisymm hp.two_le
      revert hp1; rw [hp2']
      apply mt Int.emod_eq_zero_of_dvd
      norm_num [sq, Int.sub_emod, Int.mul_emod, hm, hn]
    apply mt (Int.dvd_gcd (int.coe_nat_dvd_left.mpr hpm)) hnp
    apply (or_self_iff _).mp; apply Int.Prime.dvd_mul' hp
    rw [(by ring : n * n = -(m ^ 2 - n ^ 2) + m * m)]
    exact hp1.neg_right.add ((Int.coe_nat_dvd_left.2 hpm).mul_right _)
  rw [Int.gcd_comm] at hnp 
  apply mt (Int.dvd_gcd (int.coe_nat_dvd_left.mpr hpn)) hnp
  apply (or_self_iff _).mp; apply Int.Prime.dvd_mul' hp
  rw [(by ring : m * m = m ^ 2 - n ^ 2 + n * n)]
  apply dvd_add hp1
  exact (int.coe_nat_dvd_left.mpr hpn).mul_right n

private theorem coprime_sq_sub_mul_of_odd_even {m n : ℤ} (h : Int.gcd m n = 1) (hm : m % 2 = 1)
    (hn : n % 2 = 0) : Int.gcd (m ^ 2 - n ^ 2) (2 * m * n) = 1 :=
  by
  rw [Int.gcd, ← Int.natAbs_neg (m ^ 2 - n ^ 2)]
  rw [(by ring : 2 * m * n = 2 * n * m), (by ring : -(m ^ 2 - n ^ 2) = n ^ 2 - m ^ 2)]
  apply coprime_sq_sub_mul_of_even_odd _ hn hm; rwa [Int.gcd_comm]

private theorem coprime_sq_sub_mul {m n : ℤ} (h : Int.gcd m n = 1)
    (hmn : m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0) :
    Int.gcd (m ^ 2 - n ^ 2) (2 * m * n) = 1 :=
  by
  cases' hmn with h1 h2
  · exact coprime_sq_sub_mul_of_even_odd h h1.left h1.right
  · exact coprime_sq_sub_mul_of_odd_even h h2.left h2.right

private theorem coprime_sq_sub_sq_sum_of_odd_odd {m n : ℤ} (h : Int.gcd m n = 1) (hm : m % 2 = 1)
    (hn : n % 2 = 1) :
    2 ∣ m ^ 2 + n ^ 2 ∧
      2 ∣ m ^ 2 - n ^ 2 ∧
        (m ^ 2 - n ^ 2) / 2 % 2 = 0 ∧ Int.gcd ((m ^ 2 - n ^ 2) / 2) ((m ^ 2 + n ^ 2) / 2) = 1 :=
  by
  cases' exists_eq_mul_left_of_dvd (Int.dvd_sub_of_emod_eq hm) with m0 hm2
  cases' exists_eq_mul_left_of_dvd (Int.dvd_sub_of_emod_eq hn) with n0 hn2
  rw [sub_eq_iff_eq_add] at hm2 hn2 ; subst m; subst n
  have h1 : (m0 * 2 + 1) ^ 2 + (n0 * 2 + 1) ^ 2 = 2 * (2 * (m0 ^ 2 + n0 ^ 2 + m0 + n0) + 1) := by
    ring
  have h2 : (m0 * 2 + 1) ^ 2 - (n0 * 2 + 1) ^ 2 = 2 * (2 * (m0 ^ 2 - n0 ^ 2 + m0 - n0)) := by ring
  have h3 : ((m0 * 2 + 1) ^ 2 - (n0 * 2 + 1) ^ 2) / 2 % 2 = 0 := by
    rw [h2, Int.mul_ediv_cancel_left, Int.mul_emod_right]; exact by decide
  refine' ⟨⟨_, h1⟩, ⟨_, h2⟩, h3, _⟩
  have h20 : (2 : ℤ) ≠ 0 := by decide
  rw [h1, h2, Int.mul_ediv_cancel_left _ h20, Int.mul_ediv_cancel_left _ h20]
  by_contra h4
  obtain ⟨p, hp, hp1, hp2⟩ := nat.prime.not_coprime_iff_dvd.mp h4
  apply hp.not_dvd_one
  rw [← h]
  rw [← Int.coe_nat_dvd_left] at hp1 hp2 
  apply Nat.dvd_gcd
  · apply Int.Prime.dvd_natAbs_of_coe_dvd_sq hp
    convert dvd_add hp1 hp2; ring
  · apply Int.Prime.dvd_natAbs_of_coe_dvd_sq hp
    convert dvd_sub hp2 hp1; ring

namespace PythagoreanTriple

variable {x y z : ℤ} (h : PythagoreanTriple x y z)

#print PythagoreanTriple.isPrimitiveClassified_aux /-
theorem isPrimitiveClassified_aux (hc : x.gcd y = 1) (hzpos : 0 < z) {m n : ℤ}
    (hm2n2 : 0 < m ^ 2 + n ^ 2) (hv2 : (x : ℚ) / z = 2 * m * n / (m ^ 2 + n ^ 2))
    (hw2 : (y : ℚ) / z = (m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2))
    (H : Int.gcd (m ^ 2 - n ^ 2) (m ^ 2 + n ^ 2) = 1) (co : Int.gcd m n = 1)
    (pp : m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0) : h.IsPrimitiveClassified :=
  by
  have hz : z ≠ 0; apply ne_of_gt hzpos
  have h2 : y = m ^ 2 - n ^ 2 ∧ z = m ^ 2 + n ^ 2 := by
    apply Rat.div_int_inj hzpos hm2n2 (h.coprime_of_coprime hc) H; rw [hw2]; norm_cast
  use m, n; apply And.intro _ (And.intro co pp); right
  refine' ⟨_, h2.left⟩
  rw [← Rat.coe_int_inj _ _, ← div_left_inj' ((mt (Rat.coe_int_inj z 0).mp) hz), hv2, h2.right]
  norm_cast
#align pythagorean_triple.is_primitive_classified_aux PythagoreanTriple.isPrimitiveClassified_aux
-/

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:132:4: warning: unsupported: rw with cfg: { occs := occurrences.pos[occurrences.pos] «expr[ ,]»([2, 3]) } -/
#print PythagoreanTriple.isPrimitiveClassified_of_coprime_of_odd_of_pos /-
theorem isPrimitiveClassified_of_coprime_of_odd_of_pos (hc : Int.gcd x y = 1) (hyo : y % 2 = 1)
    (hzpos : 0 < z) : h.IsPrimitiveClassified :=
  by
  by_cases h0 : x = 0; · exact h.is_primitive_classified_of_coprime_of_zero_left hc h0
  let v := (x : ℚ) / z
  let w := (y : ℚ) / z
  have hz : z ≠ 0; apply ne_of_gt hzpos
  have hq : v ^ 2 + w ^ 2 = 1 := by field_simp [hz, sq]; norm_cast; exact h
  have hvz : v ≠ 0 := by field_simp [hz]; exact h0
  have hw1 : w ≠ -1 := by
    contrapose! hvz with hw1
    rw [hw1, neg_sq, one_pow, add_left_eq_self] at hq 
    exact pow_eq_zero hq
  have hQ : ∀ x : ℚ, 1 + x ^ 2 ≠ 0 := by intro q; apply ne_of_gt;
    exact lt_add_of_pos_of_le zero_lt_one (sq_nonneg q)
  have hp : (⟨v, w⟩ : ℚ × ℚ) ∈ {p : ℚ × ℚ | p.1 ^ 2 + p.2 ^ 2 = 1 ∧ p.2 ≠ -1} := ⟨hq, hw1⟩
  let q := (circleEquivGen hQ).symm ⟨⟨v, w⟩, hp⟩
  have ht4 : v = 2 * q / (1 + q ^ 2) ∧ w = (1 - q ^ 2) / (1 + q ^ 2) :=
    by
    apply Prod.mk.inj
    have := ((circleEquivGen hQ).apply_symm_apply ⟨⟨v, w⟩, hp⟩).symm
    exact congr_arg Subtype.val this
  let m := (q.denom : ℤ)
  let n := q.num
  have hm0 : m ≠ 0 := by norm_cast; apply Rat.den_nz q
  have hq2 : q = n / m := (Rat.num_div_den q).symm
  have hm2n2 : 0 < m ^ 2 + n ^ 2 :=
    by
    apply lt_add_of_pos_of_le _ (sq_nonneg n)
    exact lt_of_le_of_ne (sq_nonneg m) (Ne.symm (pow_ne_zero 2 hm0))
  have hw2 : w = (m ^ 2 - n ^ 2) / (m ^ 2 + n ^ 2) := by rw [ht4.2, hq2];
    field_simp [hm2n2, Rat.den_nz q, -Rat.num_div_den]
  have hm2n20 : (m : ℚ) ^ 2 + (n : ℚ) ^ 2 ≠ 0 := by norm_cast;
    simpa only [Int.coe_nat_pow] using ne_of_gt hm2n2
  have hv2 : v = 2 * m * n / (m ^ 2 + n ^ 2) :=
    by
    apply Eq.symm; apply (div_eq_iff hm2n20).mpr; rw [ht4.1]; field_simp [hQ q]
    rw [hq2]
    field_simp [Rat.den_nz q, -Rat.num_div_den]
    ring
  have hnmcp : Int.gcd n m = 1 := q.cop
  have hmncp : Int.gcd m n = 1 := by rw [Int.gcd_comm]; exact hnmcp
  cases' Int.emod_two_eq_zero_or_one m with hm2 hm2 <;>
    cases' Int.emod_two_eq_zero_or_one n with hn2 hn2
  · -- m even, n even
    exfalso
    have h1 : 2 ∣ (Int.gcd n m : ℤ) :=
      Int.dvd_gcd (Int.dvd_of_emod_eq_zero hn2) (Int.dvd_of_emod_eq_zero hm2)
    rw [hnmcp] at h1 ; revert h1; norm_num
  · -- m even, n odd
    apply h.is_primitive_classified_aux hc hzpos hm2n2 hv2 hw2 _ hmncp
    · apply Or.intro_left; exact And.intro hm2 hn2
    · apply coprime_sq_sub_sq_add_of_even_odd hmncp hm2 hn2
  · -- m odd, n even
    apply h.is_primitive_classified_aux hc hzpos hm2n2 hv2 hw2 _ hmncp
    · apply Or.intro_right; exact And.intro hm2 hn2
    apply coprime_sq_sub_sq_add_of_odd_even hmncp hm2 hn2
  · -- m odd, n odd
    exfalso
    have h1 :
      2 ∣ m ^ 2 + n ^ 2 ∧
        2 ∣ m ^ 2 - n ^ 2 ∧
          (m ^ 2 - n ^ 2) / 2 % 2 = 0 ∧ Int.gcd ((m ^ 2 - n ^ 2) / 2) ((m ^ 2 + n ^ 2) / 2) = 1 :=
      coprime_sq_sub_sq_sum_of_odd_odd hmncp hm2 hn2
    have h2 : y = (m ^ 2 - n ^ 2) / 2 ∧ z = (m ^ 2 + n ^ 2) / 2 :=
      by
      apply Rat.div_int_inj hzpos _ (h.coprime_of_coprime hc) h1.2.2.2
      · show w = _; rw [← Rat.divInt_eq_div, ← Rat.divInt_mul_right (by norm_num : (2 : ℤ) ≠ 0)]
        rw [Int.ediv_mul_cancel h1.1, Int.ediv_mul_cancel h1.2.1, hw2]; norm_cast
      · apply (mul_lt_mul_right (by norm_num : 0 < (2 : ℤ))).mp
        rw [Int.ediv_mul_cancel h1.1, MulZeroClass.zero_mul]; exact hm2n2
    rw [h2.1, h1.2.2.1] at hyo 
    revert hyo
    norm_num
#align pythagorean_triple.is_primitive_classified_of_coprime_of_odd_of_pos PythagoreanTriple.isPrimitiveClassified_of_coprime_of_odd_of_pos
-/

#print PythagoreanTriple.isPrimitiveClassified_of_coprime_of_pos /-
theorem isPrimitiveClassified_of_coprime_of_pos (hc : Int.gcd x y = 1) (hzpos : 0 < z) :
    h.IsPrimitiveClassified :=
  by
  cases' h.even_odd_of_coprime hc with h1 h2
  · exact h.is_primitive_classified_of_coprime_of_odd_of_pos hc h1.right hzpos
  rw [Int.gcd_comm] at hc 
  obtain ⟨m, n, H⟩ := h.symm.is_primitive_classified_of_coprime_of_odd_of_pos hc h2.left hzpos
  use m, n; tauto
#align pythagorean_triple.is_primitive_classified_of_coprime_of_pos PythagoreanTriple.isPrimitiveClassified_of_coprime_of_pos
-/

#print PythagoreanTriple.isPrimitiveClassified_of_coprime /-
theorem isPrimitiveClassified_of_coprime (hc : Int.gcd x y = 1) : h.IsPrimitiveClassified :=
  by
  by_cases hz : 0 < z
  · exact h.is_primitive_classified_of_coprime_of_pos hc hz
  have h' : PythagoreanTriple x y (-z) := by simpa [PythagoreanTriple, neg_mul_neg] using h.eq
  apply h'.is_primitive_classified_of_coprime_of_pos hc
  apply lt_of_le_of_ne _ (h'.ne_zero_of_coprime hc).symm
  exact le_neg.mp (not_lt.mp hz)
#align pythagorean_triple.is_primitive_classified_of_coprime PythagoreanTriple.isPrimitiveClassified_of_coprime
-/

#print PythagoreanTriple.classified /-
theorem classified : h.IsClassified :=
  by
  by_cases h0 : Int.gcd x y = 0
  · have hx : x = 0 := by apply int.nat_abs_eq_zero.mp; apply Nat.eq_zero_of_gcd_eq_zero_left h0
    have hy : y = 0 := by apply int.nat_abs_eq_zero.mp; apply Nat.eq_zero_of_gcd_eq_zero_right h0
    use 0, 1, 0; norm_num [hx, hy]
  apply h.is_classified_of_normalize_is_primitive_classified
  apply h.normalize.is_primitive_classified_of_coprime
  apply Int.gcd_div_gcd_div_gcd (Nat.pos_of_ne_zero h0)
#align pythagorean_triple.classified PythagoreanTriple.classified
-/

#print PythagoreanTriple.coprime_classification /-
theorem coprime_classification :
    PythagoreanTriple x y z ∧ Int.gcd x y = 1 ↔
      ∃ m n,
        (x = m ^ 2 - n ^ 2 ∧ y = 2 * m * n ∨ x = 2 * m * n ∧ y = m ^ 2 - n ^ 2) ∧
          (z = m ^ 2 + n ^ 2 ∨ z = -(m ^ 2 + n ^ 2)) ∧
            Int.gcd m n = 1 ∧ (m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0) :=
  by
  constructor
  · intro h
    obtain ⟨m, n, H⟩ := h.left.is_primitive_classified_of_coprime h.right
    use m, n
    rcases H with ⟨⟨rfl, rfl⟩ | ⟨rfl, rfl⟩, co, pp⟩
    · refine' ⟨Or.inl ⟨rfl, rfl⟩, _, co, pp⟩
      have : z ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by rw [sq, ← h.left.eq]; ring
      simpa using eq_or_eq_neg_of_sq_eq_sq _ _ this
    · refine' ⟨Or.inr ⟨rfl, rfl⟩, _, co, pp⟩
      have : z ^ 2 = (m ^ 2 + n ^ 2) ^ 2 := by rw [sq, ← h.left.eq]; ring
      simpa using eq_or_eq_neg_of_sq_eq_sq _ _ this
  · delta PythagoreanTriple
    rintro ⟨m, n, ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩, rfl | rfl, co, pp⟩ <;>
      first
      | · constructor; · ring; exact coprime_sq_sub_mul co pp
      | · constructor; · ring; rw [Int.gcd_comm]; exact coprime_sq_sub_mul co pp
#align pythagorean_triple.coprime_classification PythagoreanTriple.coprime_classification
-/

#print PythagoreanTriple.coprime_classification' /-
/-- by assuming `x` is odd and `z` is positive we get a slightly more precise classification of
the pythagorean triple `x ^ 2 + y ^ 2 = z ^ 2`-/
theorem coprime_classification' {x y z : ℤ} (h : PythagoreanTriple x y z)
    (h_coprime : Int.gcd x y = 1) (h_parity : x % 2 = 1) (h_pos : 0 < z) :
    ∃ m n,
      x = m ^ 2 - n ^ 2 ∧
        y = 2 * m * n ∧
          z = m ^ 2 + n ^ 2 ∧
            Int.gcd m n = 1 ∧ (m % 2 = 0 ∧ n % 2 = 1 ∨ m % 2 = 1 ∧ n % 2 = 0) ∧ 0 ≤ m :=
  by
  obtain ⟨m, n, ht1, ht2, ht3, ht4⟩ :=
    pythagorean_triple.coprime_classification.mp (And.intro h h_coprime)
  cases' le_or_lt 0 m with hm hm
  · use m, n
    cases' ht1 with h_odd h_even
    · apply And.intro h_odd.1
      apply And.intro h_odd.2
      cases' ht2 with h_pos h_neg
      · apply And.intro h_pos (And.intro ht3 (And.intro ht4 hm))
      · exfalso; revert h_pos; rw [h_neg]
        exact imp_false.mpr (not_lt.mpr (neg_nonpos.mpr (add_nonneg (sq_nonneg m) (sq_nonneg n))))
    exfalso
    rcases h_even with ⟨rfl, -⟩
    rw [mul_assoc, Int.mul_emod_right] at h_parity 
    exact zero_ne_one h_parity
  · use -m, -n
    cases' ht1 with h_odd h_even
    · rw [neg_sq m]
      rw [neg_sq n]
      apply And.intro h_odd.1
      constructor; · rw [h_odd.2]; ring
      cases' ht2 with h_pos h_neg
      · apply And.intro h_pos
        constructor
        · delta Int.gcd; rw [Int.natAbs_neg, Int.natAbs_neg]; exact ht3
        · rw [Int.neg_emod_two, Int.neg_emod_two]
          apply And.intro ht4; linarith
      · exfalso; revert h_pos; rw [h_neg]
        exact imp_false.mpr (not_lt.mpr (neg_nonpos.mpr (add_nonneg (sq_nonneg m) (sq_nonneg n))))
    exfalso
    rcases h_even with ⟨rfl, -⟩
    rw [mul_assoc, Int.mul_emod_right] at h_parity 
    exact zero_ne_one h_parity
#align pythagorean_triple.coprime_classification' PythagoreanTriple.coprime_classification'
-/

#print PythagoreanTriple.classification /-
/-- **Formula for Pythagorean Triples** -/
theorem classification :
    PythagoreanTriple x y z ↔
      ∃ k m n,
        (x = k * (m ^ 2 - n ^ 2) ∧ y = k * (2 * m * n) ∨
            x = k * (2 * m * n) ∧ y = k * (m ^ 2 - n ^ 2)) ∧
          (z = k * (m ^ 2 + n ^ 2) ∨ z = -k * (m ^ 2 + n ^ 2)) :=
  by
  constructor
  · intro h
    obtain ⟨k, m, n, H⟩ := h.classified
    use k, m, n
    rcases H with (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩)
    · refine' ⟨Or.inl ⟨rfl, rfl⟩, _⟩
      have : z ^ 2 = (k * (m ^ 2 + n ^ 2)) ^ 2 := by rw [sq, ← h.eq]; ring
      simpa using eq_or_eq_neg_of_sq_eq_sq _ _ this
    · refine' ⟨Or.inr ⟨rfl, rfl⟩, _⟩
      have : z ^ 2 = (k * (m ^ 2 + n ^ 2)) ^ 2 := by rw [sq, ← h.eq]; ring
      simpa using eq_or_eq_neg_of_sq_eq_sq _ _ this
  · rintro ⟨k, m, n, ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩, rfl | rfl⟩ <;> delta PythagoreanTriple <;> ring
#align pythagorean_triple.classification PythagoreanTriple.classification
-/

end PythagoreanTriple

