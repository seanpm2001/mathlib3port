/-
Copyright (c) 2021 Patrick Stevens. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Stevens, Thomas Browning

! This file was ported from Lean 3 source module data.nat.choose.central
! leanprover-community/mathlib commit 3e32bc908f617039c74c06ea9a897e30c30803c2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Choose.Basic
import Mathbin.Tactic.Linarith.Default

/-!
# Central binomial coefficients

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves properties of the central binomial coefficients (that is, `nat.choose (2 * n) n`).

## Main definition and results

* `nat.central_binom`: the central binomial coefficient, `(2 * n).choose n`.
* `nat.succ_mul_central_binom_succ`: the inductive relationship between successive central binomial
  coefficients.
* `nat.four_pow_lt_mul_central_binom`: an exponential lower bound on the central binomial
  coefficient.
* `succ_dvd_central_binom`: The result that `n+1 ∣ n.central_binom`, ensuring that the explicit
  definition of the Catalan numbers is integer-valued.
-/


namespace Nat

#print Nat.centralBinom /-
/-- The central binomial coefficient, `nat.choose (2 * n) n`.
-/
def centralBinom (n : ℕ) :=
  (2 * n).choose n
#align nat.central_binom Nat.centralBinom
-/

#print Nat.centralBinom_eq_two_mul_choose /-
theorem centralBinom_eq_two_mul_choose (n : ℕ) : centralBinom n = (2 * n).choose n :=
  rfl
#align nat.central_binom_eq_two_mul_choose Nat.centralBinom_eq_two_mul_choose
-/

#print Nat.centralBinom_pos /-
theorem centralBinom_pos (n : ℕ) : 0 < centralBinom n :=
  choose_pos (Nat.le_mul_of_pos_left zero_lt_two)
#align nat.central_binom_pos Nat.centralBinom_pos
-/

#print Nat.centralBinom_ne_zero /-
theorem centralBinom_ne_zero (n : ℕ) : centralBinom n ≠ 0 :=
  (centralBinom_pos n).ne'
#align nat.central_binom_ne_zero Nat.centralBinom_ne_zero
-/

#print Nat.centralBinom_zero /-
@[simp]
theorem centralBinom_zero : centralBinom 0 = 1 :=
  choose_zero_right _
#align nat.central_binom_zero Nat.centralBinom_zero
-/

#print Nat.choose_le_centralBinom /-
/-- The central binomial coefficient is the largest binomial coefficient.
-/
theorem choose_le_centralBinom (r n : ℕ) : choose (2 * n) r ≤ centralBinom n :=
  calc
    (2 * n).choose r ≤ (2 * n).choose (2 * n / 2) := choose_le_middle r (2 * n)
    _ = (2 * n).choose n := by rw [Nat.mul_div_cancel_left n zero_lt_two]
#align nat.choose_le_central_binom Nat.choose_le_centralBinom
-/

#print Nat.two_le_centralBinom /-
theorem two_le_centralBinom (n : ℕ) (n_pos : 0 < n) : 2 ≤ centralBinom n :=
  calc
    2 ≤ 2 * n := le_mul_of_pos_right n_pos
    _ = (2 * n).choose 1 := (choose_one_right (2 * n)).symm
    _ ≤ centralBinom n := choose_le_centralBinom 1 n
#align nat.two_le_central_binom Nat.two_le_centralBinom
-/

#print Nat.succ_mul_centralBinom_succ /-
/-- An inductive property of the central binomial coefficient.
-/
theorem succ_mul_centralBinom_succ (n : ℕ) :
    (n + 1) * centralBinom (n + 1) = 2 * (2 * n + 1) * centralBinom n :=
  calc
    (n + 1) * (2 * (n + 1)).choose (n + 1) = (2 * n + 2).choose (n + 1) * (n + 1) := mul_comm _ _
    _ = (2 * n + 1).choose n * (2 * n + 2) := by rw [choose_succ_right_eq, choose_mul_succ_eq]
    _ = 2 * ((2 * n + 1).choose n * (n + 1)) := by ring
    _ = 2 * ((2 * n + 1).choose n * (2 * n + 1 - n)) := by
      rw [two_mul n, add_assoc, Nat.add_sub_cancel_left]
    _ = 2 * ((2 * n).choose n * (2 * n + 1)) := by rw [choose_mul_succ_eq]
    _ = 2 * (2 * n + 1) * (2 * n).choose n := by rw [mul_assoc, mul_comm (2 * n + 1)]
#align nat.succ_mul_central_binom_succ Nat.succ_mul_centralBinom_succ
-/

#print Nat.four_pow_lt_mul_centralBinom /-
/-- An exponential lower bound on the central binomial coefficient.
This bound is of interest because it appears in
[Tochiori's refinement of Erdős's proof of Bertrand's postulate](tochiori_bertrand).
-/
theorem four_pow_lt_mul_centralBinom (n : ℕ) (n_big : 4 ≤ n) : 4 ^ n < n * centralBinom n :=
  by
  induction' n using Nat.strong_induction_on with n IH
  rcases lt_trichotomy n 4 with (hn | rfl | hn)
  · clear IH; decide!
  · norm_num [central_binom, choose]
  obtain ⟨n, rfl⟩ : ∃ m, n = m + 1 := Nat.exists_eq_succ_of_ne_zero (zero_lt_four.trans hn).ne'
  calc
    4 ^ (n + 1) < 4 * (n * central_binom n) :=
      (mul_lt_mul_left <| zero_lt_four' ℕ).mpr (IH n n.lt_succ_self (Nat.le_of_lt_succ hn))
    _ ≤ 2 * (2 * n + 1) * central_binom n := by rw [← mul_assoc]; linarith
    _ = (n + 1) * central_binom (n + 1) := (succ_mul_central_binom_succ n).symm
#align nat.four_pow_lt_mul_central_binom Nat.four_pow_lt_mul_centralBinom
-/

#print Nat.four_pow_le_two_mul_self_mul_centralBinom /-
/-- An exponential lower bound on the central binomial coefficient.
This bound is weaker than `nat.four_pow_lt_mul_central_binom`, but it is of historical interest
because it appears in Erdős's proof of Bertrand's postulate.
-/
theorem four_pow_le_two_mul_self_mul_centralBinom :
    ∀ (n : ℕ) (n_pos : 0 < n), 4 ^ n ≤ 2 * n * centralBinom n
  | 0, pr => (Nat.not_lt_zero _ pr).elim
  | 1, pr => by norm_num [central_binom, choose]
  | 2, pr => by norm_num [central_binom, choose]
  | 3, pr => by norm_num [central_binom, choose]
  | n@(m + 4), _ =>
    calc
      4 ^ n ≤ n * centralBinom n := (four_pow_lt_mul_centralBinom _ le_add_self).le
      _ ≤ 2 * n * centralBinom n := by rw [mul_assoc]; refine' le_mul_of_pos_left zero_lt_two
#align nat.four_pow_le_two_mul_self_mul_central_binom Nat.four_pow_le_two_mul_self_mul_centralBinom
-/

#print Nat.two_dvd_centralBinom_succ /-
theorem two_dvd_centralBinom_succ (n : ℕ) : 2 ∣ centralBinom (n + 1) :=
  by
  use (n + 1 + n).choose n
  rw [central_binom_eq_two_mul_choose, two_mul, ← add_assoc, choose_succ_succ, choose_symm_add, ←
    two_mul]
#align nat.two_dvd_central_binom_succ Nat.two_dvd_centralBinom_succ
-/

#print Nat.two_dvd_centralBinom_of_one_le /-
theorem two_dvd_centralBinom_of_one_le {n : ℕ} (h : 0 < n) : 2 ∣ centralBinom n :=
  by
  rw [← Nat.succ_pred_eq_of_pos h]
  exact two_dvd_central_binom_succ n.pred
#align nat.two_dvd_central_binom_of_one_le Nat.two_dvd_centralBinom_of_one_le
-/

#print Nat.succ_dvd_centralBinom /-
/-- A crucial lemma to ensure that Catalan numbers can be defined via their explicit formula
  `catalan n = n.central_binom / (n + 1)`. -/
theorem succ_dvd_centralBinom (n : ℕ) : n + 1 ∣ n.centralBinom :=
  by
  have h_s : (n + 1).coprime (2 * n + 1) :=
    by
    rw [two_mul, add_assoc, coprime_add_self_right, coprime_self_add_left]
    exact coprime_one_left n
  apply h_s.dvd_of_dvd_mul_left
  apply dvd_of_mul_dvd_mul_left zero_lt_two
  rw [← mul_assoc, ← succ_mul_central_binom_succ, mul_comm]
  exact mul_dvd_mul_left _ (two_dvd_central_binom_succ n)
#align nat.succ_dvd_central_binom Nat.succ_dvd_centralBinom
-/

end Nat

