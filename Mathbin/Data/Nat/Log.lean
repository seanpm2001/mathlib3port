/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Yaël Dillies

! This file was ported from Lean 3 source module data.nat.log
! leanprover-community/mathlib commit 55d224c38461be1e8e4363247dd110137c24a4ff
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Pow
import Mathbin.Tactic.ByContra

/-!
# Natural number logarithms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines two `ℕ`-valued analogs of the logarithm of `n` with base `b`:
* `log b n`: Lower logarithm, or floor **log**. Greatest `k` such that `b^k ≤ n`.
* `clog b n`: Upper logarithm, or **c**eil **log**. Least `k` such that `n ≤ b^k`.

These are interesting because, for `1 < b`, `nat.log b` and `nat.clog b` are respectively right and
left adjoints of `nat.pow b`. See `pow_le_iff_le_log` and `le_pow_iff_clog_le`.
-/


namespace Nat

/-! ### Floor logarithm -/


#print Nat.log /-
/-- `log b n`, is the logarithm of natural number `n` in base `b`. It returns the largest `k : ℕ`
such that `b^k ≤ n`, so if `b^k = n`, it returns exactly `k`. -/
@[pp_nodot]
def log (b : ℕ) : ℕ → ℕ
  | n =>
    if h : b ≤ n ∧ 1 < b then
      have : n / b < n := div_lt_self ((zero_lt_one.trans h.2).trans_le h.1) h.2
      log (n / b) + 1
    else 0
#align nat.log Nat.log
-/

#print Nat.log_eq_zero_iff /-
@[simp]
theorem log_eq_zero_iff {b n : ℕ} : log b n = 0 ↔ n < b ∨ b ≤ 1 :=
  by
  rw [log, ite_eq_right_iff]
  simp only [Nat.succ_ne_zero, imp_false, Decidable.not_and, not_le, not_lt]
#align nat.log_eq_zero_iff Nat.log_eq_zero_iff
-/

#print Nat.log_of_lt /-
theorem log_of_lt {b n : ℕ} (hb : n < b) : log b n = 0 :=
  log_eq_zero_iff.2 (Or.inl hb)
#align nat.log_of_lt Nat.log_of_lt
-/

#print Nat.log_of_left_le_one /-
theorem log_of_left_le_one {b : ℕ} (hb : b ≤ 1) (n) : log b n = 0 :=
  log_eq_zero_iff.2 (Or.inr hb)
#align nat.log_of_left_le_one Nat.log_of_left_le_one
-/

#print Nat.log_pos_iff /-
@[simp]
theorem log_pos_iff {b n : ℕ} : 0 < log b n ↔ b ≤ n ∧ 1 < b := by
  rw [pos_iff_ne_zero, Ne.def, log_eq_zero_iff, not_or, not_lt, not_le]
#align nat.log_pos_iff Nat.log_pos_iff
-/

#print Nat.log_pos /-
theorem log_pos {b n : ℕ} (hb : 1 < b) (hbn : b ≤ n) : 0 < log b n :=
  log_pos_iff.2 ⟨hbn, hb⟩
#align nat.log_pos Nat.log_pos
-/

#print Nat.log_of_one_lt_of_le /-
theorem log_of_one_lt_of_le {b n : ℕ} (h : 1 < b) (hn : b ≤ n) : log b n = log b (n / b) + 1 := by
  rw [log]; exact if_pos ⟨hn, h⟩
#align nat.log_of_one_lt_of_le Nat.log_of_one_lt_of_le
-/

#print Nat.log_zero_left /-
@[simp]
theorem log_zero_left : ∀ n, log 0 n = 0 :=
  log_of_left_le_one zero_le_one
#align nat.log_zero_left Nat.log_zero_left
-/

#print Nat.log_zero_right /-
@[simp]
theorem log_zero_right (b : ℕ) : log b 0 = 0 :=
  log_eq_zero_iff.2 (le_total 1 b)
#align nat.log_zero_right Nat.log_zero_right
-/

#print Nat.log_one_left /-
@[simp]
theorem log_one_left : ∀ n, log 1 n = 0 :=
  log_of_left_le_one le_rfl
#align nat.log_one_left Nat.log_one_left
-/

#print Nat.log_one_right /-
@[simp]
theorem log_one_right (b : ℕ) : log b 1 = 0 :=
  log_eq_zero_iff.2 (lt_or_le _ _)
#align nat.log_one_right Nat.log_one_right
-/

#print Nat.pow_le_iff_le_log /-
/-- `pow b` and `log b` (almost) form a Galois connection. See also `nat.pow_le_of_le_log` and
`nat.le_log_of_pow_le` for individual implications under weaker assumptions. -/
theorem pow_le_iff_le_log {b : ℕ} (hb : 1 < b) {x y : ℕ} (hy : y ≠ 0) : b ^ x ≤ y ↔ x ≤ log b y :=
  by
  induction' y using Nat.strong_induction_on with y ih generalizing x
  cases x
  · exact iff_of_true hy.bot_lt (zero_le _)
  rw [log]; split_ifs
  · have b_pos : 0 < b := zero_le_one.trans_lt hb
    rw [succ_eq_add_one, add_le_add_iff_right, ←
      ih (y / b) (div_lt_self hy.bot_lt hb) (Nat.div_pos h.1 b_pos).ne', le_div_iff_mul_le b_pos,
      pow_succ']
  ·
    exact
      iff_of_false (fun hby => h ⟨(le_self_pow x.succ_ne_zero _).trans hby, hb⟩)
        (not_succ_le_zero _)
#align nat.pow_le_iff_le_log Nat.pow_le_iff_le_log
-/

#print Nat.lt_pow_iff_log_lt /-
theorem lt_pow_iff_log_lt {b : ℕ} (hb : 1 < b) {x y : ℕ} (hy : y ≠ 0) : y < b ^ x ↔ log b y < x :=
  lt_iff_lt_of_le_iff_le (pow_le_iff_le_log hb hy)
#align nat.lt_pow_iff_log_lt Nat.lt_pow_iff_log_lt
-/

#print Nat.pow_le_of_le_log /-
theorem pow_le_of_le_log {b x y : ℕ} (hy : y ≠ 0) (h : x ≤ log b y) : b ^ x ≤ y :=
  by
  refine' (le_or_lt b 1).elim (fun hb => _) fun hb => (pow_le_iff_le_log hb hy).2 h
  rw [log_of_left_le_one hb, nonpos_iff_eq_zero] at h 
  rwa [h, pow_zero, one_le_iff_ne_zero]
#align nat.pow_le_of_le_log Nat.pow_le_of_le_log
-/

#print Nat.le_log_of_pow_le /-
theorem le_log_of_pow_le {b x y : ℕ} (hb : 1 < b) (h : b ^ x ≤ y) : x ≤ log b y :=
  by
  rcases ne_or_eq y 0 with (hy | rfl)
  exacts [(pow_le_iff_le_log hb hy).1 h, (h.not_lt (pow_pos (zero_lt_one.trans hb) _)).elim]
#align nat.le_log_of_pow_le Nat.le_log_of_pow_le
-/

#print Nat.pow_log_le_self /-
theorem pow_log_le_self (b : ℕ) {x : ℕ} (hx : x ≠ 0) : b ^ log b x ≤ x :=
  pow_le_of_le_log hx le_rfl
#align nat.pow_log_le_self Nat.pow_log_le_self
-/

#print Nat.log_lt_of_lt_pow /-
theorem log_lt_of_lt_pow {b x y : ℕ} (hy : y ≠ 0) : y < b ^ x → log b y < x :=
  lt_imp_lt_of_le_imp_le (pow_le_of_le_log hy)
#align nat.log_lt_of_lt_pow Nat.log_lt_of_lt_pow
-/

#print Nat.lt_pow_of_log_lt /-
theorem lt_pow_of_log_lt {b x y : ℕ} (hb : 1 < b) : log b y < x → y < b ^ x :=
  lt_imp_lt_of_le_imp_le (le_log_of_pow_le hb)
#align nat.lt_pow_of_log_lt Nat.lt_pow_of_log_lt
-/

#print Nat.lt_pow_succ_log_self /-
theorem lt_pow_succ_log_self {b : ℕ} (hb : 1 < b) (x : ℕ) : x < b ^ (log b x).succ :=
  lt_pow_of_log_lt hb (lt_succ_self _)
#align nat.lt_pow_succ_log_self Nat.lt_pow_succ_log_self
-/

#print Nat.log_eq_iff /-
theorem log_eq_iff {b m n : ℕ} (h : m ≠ 0 ∨ 1 < b ∧ n ≠ 0) :
    log b n = m ↔ b ^ m ≤ n ∧ n < b ^ (m + 1) :=
  by
  rcases em (1 < b ∧ n ≠ 0) with (⟨hb, hn⟩ | hbn)
  ·
    rw [le_antisymm_iff, ← lt_succ_iff, ← pow_le_iff_le_log, ← lt_pow_iff_log_lt, and_comm] <;>
      assumption
  · have hm : m ≠ 0 := h.resolve_right hbn
    rw [not_and_or, not_lt, Ne.def, Classical.not_not] at hbn 
    rcases hbn with (hb | rfl)
    ·
      simpa only [log_of_left_le_one hb, hm.symm, false_iff_iff, not_and, not_lt] using
        le_trans (pow_le_pow_of_le_one' hb m.le_succ)
    ·
      simpa only [log_zero_right, hm.symm, false_iff_iff, not_and, not_lt, le_zero_iff,
        pow_succ] using mul_eq_zero_of_right _
#align nat.log_eq_iff Nat.log_eq_iff
-/

#print Nat.log_eq_of_pow_le_of_lt_pow /-
theorem log_eq_of_pow_le_of_lt_pow {b m n : ℕ} (h₁ : b ^ m ≤ n) (h₂ : n < b ^ (m + 1)) :
    log b n = m := by
  rcases eq_or_ne m 0 with (rfl | hm)
  · rw [pow_one] at h₂ ; exact log_of_lt h₂
  · exact (log_eq_iff (Or.inl hm)).2 ⟨h₁, h₂⟩
#align nat.log_eq_of_pow_le_of_lt_pow Nat.log_eq_of_pow_le_of_lt_pow
-/

#print Nat.log_pow /-
theorem log_pow {b : ℕ} (hb : 1 < b) (x : ℕ) : log b (b ^ x) = x :=
  log_eq_of_pow_le_of_lt_pow le_rfl (pow_lt_pow hb x.lt_succ_self)
#align nat.log_pow Nat.log_pow
-/

#print Nat.log_eq_one_iff' /-
theorem log_eq_one_iff' {b n : ℕ} : log b n = 1 ↔ b ≤ n ∧ n < b * b := by
  rw [log_eq_iff (Or.inl one_ne_zero), pow_add, pow_one]
#align nat.log_eq_one_iff' Nat.log_eq_one_iff'
-/

#print Nat.log_eq_one_iff /-
theorem log_eq_one_iff {b n : ℕ} : log b n = 1 ↔ n < b * b ∧ 1 < b ∧ b ≤ n :=
  log_eq_one_iff'.trans
    ⟨fun h => ⟨h.2, lt_mul_self_iff.1 (h.1.trans_lt h.2), h.1⟩, fun h => ⟨h.2.2, h.1⟩⟩
#align nat.log_eq_one_iff Nat.log_eq_one_iff
-/

#print Nat.log_mul_base /-
theorem log_mul_base {b n : ℕ} (hb : 1 < b) (hn : n ≠ 0) : log b (n * b) = log b n + 1 :=
  by
  apply log_eq_of_pow_le_of_lt_pow <;> rw [pow_succ']
  exacts [mul_le_mul_right' (pow_log_le_self _ hn) _,
    (mul_lt_mul_right (zero_lt_one.trans hb)).2 (lt_pow_succ_log_self hb _)]
#align nat.log_mul_base Nat.log_mul_base
-/

#print Nat.pow_log_le_add_one /-
theorem pow_log_le_add_one (b : ℕ) : ∀ x, b ^ log b x ≤ x + 1
  | 0 => by rw [log_zero_right, pow_zero]
  | x + 1 => (pow_log_le_self b x.succ_ne_zero).trans (x + 1).le_succ
#align nat.pow_log_le_add_one Nat.pow_log_le_add_one
-/

#print Nat.log_monotone /-
theorem log_monotone {b : ℕ} : Monotone (log b) :=
  by
  refine' monotone_nat_of_le_succ fun n => _
  cases' le_or_lt b 1 with hb hb
  · rw [log_of_left_le_one hb]; exact zero_le _
  · exact le_log_of_pow_le hb (pow_log_le_add_one _ _)
#align nat.log_monotone Nat.log_monotone
-/

#print Nat.log_mono_right /-
@[mono]
theorem log_mono_right {b n m : ℕ} (h : n ≤ m) : log b n ≤ log b m :=
  log_monotone h
#align nat.log_mono_right Nat.log_mono_right
-/

#print Nat.log_anti_left /-
@[mono]
theorem log_anti_left {b c n : ℕ} (hc : 1 < c) (hb : c ≤ b) : log b n ≤ log c n :=
  by
  rcases eq_or_ne n 0 with (rfl | hn); · rw [log_zero_right, log_zero_right]
  apply le_log_of_pow_le hc
  calc
    c ^ log b n ≤ b ^ log b n := pow_le_pow_of_le_left' hb _
    _ ≤ n := pow_log_le_self _ hn
#align nat.log_anti_left Nat.log_anti_left
-/

#print Nat.log_antitone_left /-
theorem log_antitone_left {n : ℕ} : AntitoneOn (fun b => log b n) (Set.Ioi 1) := fun _ hc _ _ hb =>
  log_anti_left (Set.mem_Iio.1 hc) hb
#align nat.log_antitone_left Nat.log_antitone_left
-/

#print Nat.log_div_base /-
@[simp]
theorem log_div_base (b n : ℕ) : log b (n / b) = log b n - 1 :=
  by
  cases' le_or_lt b 1 with hb hb
  · rw [log_of_left_le_one hb, log_of_left_le_one hb, Nat.zero_sub]
  cases' lt_or_le n b with h h
  · rw [div_eq_of_lt h, log_of_lt h, log_zero_right]
  rw [log_of_one_lt_of_le hb h, add_tsub_cancel_right]
#align nat.log_div_base Nat.log_div_base
-/

#print Nat.log_div_mul_self /-
@[simp]
theorem log_div_mul_self (b n : ℕ) : log b (n / b * b) = log b n :=
  by
  cases' le_or_lt b 1 with hb hb
  · rw [log_of_left_le_one hb, log_of_left_le_one hb]
  cases' lt_or_le n b with h h
  · rw [div_eq_of_lt h, MulZeroClass.zero_mul, log_zero_right, log_of_lt h]
  rw [log_mul_base hb (Nat.div_pos h (zero_le_one.trans_lt hb)).ne', log_div_base,
    tsub_add_cancel_of_le (succ_le_iff.2 <| log_pos hb h)]
#align nat.log_div_mul_self Nat.log_div_mul_self
-/

private theorem add_pred_div_lt {b n : ℕ} (hb : 1 < b) (hn : 2 ≤ n) : (n + b - 1) / b < n :=
  by
  rw [div_lt_iff_lt_mul (zero_lt_one.trans hb), ← succ_le_iff, ← pred_eq_sub_one,
    succ_pred_eq_of_pos (add_pos (zero_lt_one.trans hn) (zero_lt_one.trans hb))]
  exact add_le_mul hn hb

/-! ### Ceil logarithm -/


#print Nat.clog /-
/-- `clog b n`, is the upper logarithm of natural number `n` in base `b`. It returns the smallest
`k : ℕ` such that `n ≤ b^k`, so if `b^k = n`, it returns exactly `k`. -/
@[pp_nodot]
def clog (b : ℕ) : ℕ → ℕ
  | n =>
    if h : 1 < b ∧ 1 < n then
      have : (n + b - 1) / b < n := add_pred_div_lt h.1 h.2
      clog ((n + b - 1) / b) + 1
    else 0
#align nat.clog Nat.clog
-/

#print Nat.clog_of_left_le_one /-
theorem clog_of_left_le_one {b : ℕ} (hb : b ≤ 1) (n : ℕ) : clog b n = 0 := by
  rw [clog, if_neg fun h : 1 < b ∧ 1 < n => h.1.not_le hb]
#align nat.clog_of_left_le_one Nat.clog_of_left_le_one
-/

#print Nat.clog_of_right_le_one /-
theorem clog_of_right_le_one {n : ℕ} (hn : n ≤ 1) (b : ℕ) : clog b n = 0 := by
  rw [clog, if_neg fun h : 1 < b ∧ 1 < n => h.2.not_le hn]
#align nat.clog_of_right_le_one Nat.clog_of_right_le_one
-/

#print Nat.clog_zero_left /-
@[simp]
theorem clog_zero_left (n : ℕ) : clog 0 n = 0 :=
  clog_of_left_le_one zero_le_one _
#align nat.clog_zero_left Nat.clog_zero_left
-/

#print Nat.clog_zero_right /-
@[simp]
theorem clog_zero_right (b : ℕ) : clog b 0 = 0 :=
  clog_of_right_le_one zero_le_one _
#align nat.clog_zero_right Nat.clog_zero_right
-/

#print Nat.clog_one_left /-
@[simp]
theorem clog_one_left (n : ℕ) : clog 1 n = 0 :=
  clog_of_left_le_one le_rfl _
#align nat.clog_one_left Nat.clog_one_left
-/

#print Nat.clog_one_right /-
@[simp]
theorem clog_one_right (b : ℕ) : clog b 1 = 0 :=
  clog_of_right_le_one le_rfl _
#align nat.clog_one_right Nat.clog_one_right
-/

#print Nat.clog_of_two_le /-
theorem clog_of_two_le {b n : ℕ} (hb : 1 < b) (hn : 2 ≤ n) :
    clog b n = clog b ((n + b - 1) / b) + 1 := by rw [clog, if_pos (⟨hb, hn⟩ : 1 < b ∧ 1 < n)]
#align nat.clog_of_two_le Nat.clog_of_two_le
-/

#print Nat.clog_pos /-
theorem clog_pos {b n : ℕ} (hb : 1 < b) (hn : 2 ≤ n) : 0 < clog b n := by rw [clog_of_two_le hb hn];
  exact zero_lt_succ _
#align nat.clog_pos Nat.clog_pos
-/

#print Nat.clog_eq_one /-
theorem clog_eq_one {b n : ℕ} (hn : 2 ≤ n) (h : n ≤ b) : clog b n = 1 :=
  by
  rw [clog_of_two_le (hn.trans h) hn, clog_of_right_le_one]
  have n_pos : 0 < n := zero_lt_two.trans_le hn
  rw [← lt_succ_iff, Nat.div_lt_iff_lt_mul (n_pos.trans_le h), ← succ_le_iff, ← pred_eq_sub_one,
    succ_pred_eq_of_pos (add_pos n_pos (n_pos.trans_le h)), succ_mul, one_mul]
  exact add_le_add_right h _
#align nat.clog_eq_one Nat.clog_eq_one
-/

#print Nat.le_pow_iff_clog_le /-
/-- `clog b` and `pow b` form a Galois connection. -/
theorem le_pow_iff_clog_le {b : ℕ} (hb : 1 < b) {x y : ℕ} : x ≤ b ^ y ↔ clog b x ≤ y :=
  by
  induction' x using Nat.strong_induction_on with x ih generalizing y
  cases y
  · rw [pow_zero]
    refine' ⟨fun h => (clog_of_right_le_one h b).le, _⟩
    simp_rw [← not_lt]
    contrapose!
    exact clog_pos hb
  have b_pos : 0 < b := zero_lt_two.trans_le hb
  rw [clog]; split_ifs
  ·
    rw [succ_eq_add_one, add_le_add_iff_right, ← ih ((x + b - 1) / b) (add_pred_div_lt hb h.2),
      Nat.div_le_iff_le_mul_add_pred b_pos, ← pow_succ,
      add_tsub_assoc_of_le (Nat.succ_le_of_lt b_pos), add_le_add_iff_right]
  ·
    exact
      iff_of_true ((not_lt.1 (not_and.1 h hb)).trans <| succ_le_of_lt <| pow_pos b_pos _)
        (zero_le _)
#align nat.le_pow_iff_clog_le Nat.le_pow_iff_clog_le
-/

#print Nat.pow_lt_iff_lt_clog /-
theorem pow_lt_iff_lt_clog {b : ℕ} (hb : 1 < b) {x y : ℕ} : b ^ y < x ↔ y < clog b x :=
  lt_iff_lt_of_le_iff_le (le_pow_iff_clog_le hb)
#align nat.pow_lt_iff_lt_clog Nat.pow_lt_iff_lt_clog
-/

#print Nat.clog_pow /-
theorem clog_pow (b x : ℕ) (hb : 1 < b) : clog b (b ^ x) = x :=
  eq_of_forall_ge_iff fun z => by rw [← le_pow_iff_clog_le hb];
    exact (pow_right_strict_mono hb).le_iff_le
#align nat.clog_pow Nat.clog_pow
-/

#print Nat.pow_pred_clog_lt_self /-
theorem pow_pred_clog_lt_self {b : ℕ} (hb : 1 < b) {x : ℕ} (hx : 1 < x) : b ^ (clog b x).pred < x :=
  by
  rw [← not_le, le_pow_iff_clog_le hb, not_le]
  exact pred_lt (clog_pos hb hx).ne'
#align nat.pow_pred_clog_lt_self Nat.pow_pred_clog_lt_self
-/

#print Nat.le_pow_clog /-
theorem le_pow_clog {b : ℕ} (hb : 1 < b) (x : ℕ) : x ≤ b ^ clog b x :=
  (le_pow_iff_clog_le hb).2 le_rfl
#align nat.le_pow_clog Nat.le_pow_clog
-/

#print Nat.clog_mono_right /-
@[mono]
theorem clog_mono_right (b : ℕ) {n m : ℕ} (h : n ≤ m) : clog b n ≤ clog b m :=
  by
  cases' le_or_lt b 1 with hb hb
  · rw [clog_of_left_le_one hb]; exact zero_le _
  · rw [← le_pow_iff_clog_le hb]
    exact h.trans (le_pow_clog hb _)
#align nat.clog_mono_right Nat.clog_mono_right
-/

#print Nat.clog_anti_left /-
@[mono]
theorem clog_anti_left {b c n : ℕ} (hc : 1 < c) (hb : c ≤ b) : clog b n ≤ clog c n :=
  by
  rw [← le_pow_iff_clog_le (lt_of_lt_of_le hc hb)]
  calc
    n ≤ c ^ clog c n := le_pow_clog hc _
    _ ≤ b ^ clog c n := pow_le_pow_of_le_left (zero_lt_one.trans hc).le hb _
#align nat.clog_anti_left Nat.clog_anti_left
-/

#print Nat.clog_monotone /-
theorem clog_monotone (b : ℕ) : Monotone (clog b) := fun x y => clog_mono_right _
#align nat.clog_monotone Nat.clog_monotone
-/

#print Nat.clog_antitone_left /-
theorem clog_antitone_left {n : ℕ} : AntitoneOn (fun b : ℕ => clog b n) (Set.Ioi 1) :=
  fun _ hc _ _ hb => clog_anti_left (Set.mem_Iio.1 hc) hb
#align nat.clog_antitone_left Nat.clog_antitone_left
-/

#print Nat.log_le_clog /-
theorem log_le_clog (b n : ℕ) : log b n ≤ clog b n :=
  by
  obtain hb | hb := le_or_lt b 1
  · rw [log_of_left_le_one hb]
    exact zero_le _
  cases n
  · rw [log_zero_right]
    exact zero_le _
  exact
    (pow_right_strict_mono hb).le_iff_le.1
      ((pow_log_le_self b n.succ_ne_zero).trans <| le_pow_clog hb _)
#align nat.log_le_clog Nat.log_le_clog
-/

end Nat

