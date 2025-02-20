/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module data.int.div
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Dvd.Basic
import Mathbin.Data.Nat.Order.Lemmas
import Mathbin.Algebra.Ring.Regular

/-!
# Lemmas relating `/` in `ℤ` with the ordering.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


open Nat

namespace Int

#print Int.eq_mul_div_of_mul_eq_mul_of_dvd_left /-
theorem eq_mul_div_of_mul_eq_mul_of_dvd_left {a b c d : ℤ} (hb : b ≠ 0) (hbc : b ∣ c)
    (h : b * a = c * d) : a = c / b * d :=
  by
  cases' hbc with k hk
  subst hk
  rw [Int.mul_ediv_cancel_left _ hb]
  rw [mul_assoc] at h 
  apply mul_left_cancel₀ hb h
#align int.eq_mul_div_of_mul_eq_mul_of_dvd_left Int.eq_mul_div_of_mul_eq_mul_of_dvd_left
-/

#print Int.eq_zero_of_dvd_of_natAbs_lt_natAbs /-
/-- If an integer with larger absolute value divides an integer, it is
zero. -/
theorem eq_zero_of_dvd_of_natAbs_lt_natAbs {a b : ℤ} (w : a ∣ b) (h : natAbs b < natAbs a) :
    b = 0 := by
  rw [← nat_abs_dvd, ← dvd_nat_abs, coe_nat_dvd] at w 
  rw [← nat_abs_eq_zero]
  exact eq_zero_of_dvd_of_lt w h
#align int.eq_zero_of_dvd_of_nat_abs_lt_nat_abs Int.eq_zero_of_dvd_of_natAbs_lt_natAbs
-/

#print Int.eq_zero_of_dvd_of_nonneg_of_lt /-
theorem eq_zero_of_dvd_of_nonneg_of_lt {a b : ℤ} (w₁ : 0 ≤ a) (w₂ : a < b) (h : b ∣ a) : a = 0 :=
  eq_zero_of_dvd_of_natAbs_lt_natAbs h (natAbs_lt_natAbs_of_nonneg_of_lt w₁ w₂)
#align int.eq_zero_of_dvd_of_nonneg_of_lt Int.eq_zero_of_dvd_of_nonneg_of_lt
-/

#print Int.eq_of_mod_eq_of_natAbs_sub_lt_natAbs /-
/-- If two integers are congruent to a sufficiently large modulus,
they are equal. -/
theorem eq_of_mod_eq_of_natAbs_sub_lt_natAbs {a b c : ℤ} (h1 : a % b = c)
    (h2 : natAbs (a - c) < natAbs b) : a = c :=
  eq_of_sub_eq_zero (eq_zero_of_dvd_of_natAbs_lt_natAbs (dvd_sub_of_emod_eq h1) h2)
#align int.eq_of_mod_eq_of_nat_abs_sub_lt_nat_abs Int.eq_of_mod_eq_of_natAbs_sub_lt_natAbs
-/

#print Int.ofNat_add_negSucc_of_ge /-
theorem ofNat_add_negSucc_of_ge {m n : ℕ} (h : n.succ ≤ m) :
    ofNat m + -[n+1] = ofNat (m - n.succ) :=
  by
  change sub_nat_nat _ _ = _
  have h' : n.succ - m = 0
  apply tsub_eq_zero_iff_le.mpr h
  simp [*, sub_nat_nat]
#align int.of_nat_add_neg_succ_of_nat_of_ge Int.ofNat_add_negSucc_of_ge
-/

#print Int.natAbs_le_of_dvd_ne_zero /-
theorem natAbs_le_of_dvd_ne_zero {s t : ℤ} (hst : s ∣ t) (ht : t ≠ 0) : natAbs s ≤ natAbs t :=
  not_lt.mp (mt (eq_zero_of_dvd_of_natAbs_lt_natAbs hst) ht)
#align int.nat_abs_le_of_dvd_ne_zero Int.natAbs_le_of_dvd_ne_zero
-/

end Int

