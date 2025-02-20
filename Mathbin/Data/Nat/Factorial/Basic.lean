/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Chris Hughes, Floris van Doorn, Yaël Dillies

! This file was ported from Lean 3 source module data.nat.factorial.basic
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Basic
import Mathbin.Data.Nat.Pow

/-!
# Factorial and variants

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the factorial, along with the ascending and descending variants.

## Main declarations

* `nat.factorial`: The factorial.
* `nat.asc_factorial`: The ascending factorial. Note that it runs from `n + 1` to `n + k`
  and *not* from `n` to `n + k - 1`. We might want to change that in the future.
* `nat.desc_factorial`: The descending factorial. It runs from `n - k` to `n`.
-/


namespace Nat

#print Nat.factorial /-
/-- `nat.factorial n` is the factorial of `n`. -/
@[simp]
def factorial : ℕ → ℕ
  | 0 => 1
  | succ n => succ n * factorial n
#align nat.factorial Nat.factorial
-/

scoped notation:10000 n "!" => Nat.factorial n

section Factorial

variable {m n : ℕ}

#print Nat.factorial_zero /-
@[simp]
theorem factorial_zero : 0! = 1 :=
  rfl
#align nat.factorial_zero Nat.factorial_zero
-/

#print Nat.factorial_succ /-
@[simp]
theorem factorial_succ (n : ℕ) : n.succ ! = (n + 1) * n ! :=
  rfl
#align nat.factorial_succ Nat.factorial_succ
-/

#print Nat.factorial_one /-
@[simp]
theorem factorial_one : 1! = 1 :=
  rfl
#align nat.factorial_one Nat.factorial_one
-/

#print Nat.factorial_two /-
@[simp]
theorem factorial_two : 2! = 2 :=
  rfl
#align nat.factorial_two Nat.factorial_two
-/

#print Nat.mul_factorial_pred /-
theorem mul_factorial_pred (hn : 0 < n) : n * (n - 1)! = n ! :=
  tsub_add_cancel_of_le (Nat.succ_le_of_lt hn) ▸ rfl
#align nat.mul_factorial_pred Nat.mul_factorial_pred
-/

#print Nat.factorial_pos /-
theorem factorial_pos : ∀ n, 0 < n !
  | 0 => zero_lt_one
  | succ n => mul_pos (succ_pos _) (factorial_pos n)
#align nat.factorial_pos Nat.factorial_pos
-/

#print Nat.factorial_ne_zero /-
theorem factorial_ne_zero (n : ℕ) : n ! ≠ 0 :=
  ne_of_gt (factorial_pos _)
#align nat.factorial_ne_zero Nat.factorial_ne_zero
-/

#print Nat.factorial_dvd_factorial /-
theorem factorial_dvd_factorial {m n} (h : m ≤ n) : m ! ∣ n ! :=
  by
  induction' n with n IH
  · simp [Nat.eq_zero_of_le_zero h]
  obtain rfl | hl := h.eq_or_lt
  · simp
  exact (IH (le_of_lt_succ hl)).mul_left _
#align nat.factorial_dvd_factorial Nat.factorial_dvd_factorial
-/

#print Nat.dvd_factorial /-
theorem dvd_factorial : ∀ {m n}, 0 < m → m ≤ n → m ∣ n !
  | succ m, n, _, h => dvd_of_mul_right_dvd (factorial_dvd_factorial h)
#align nat.dvd_factorial Nat.dvd_factorial
-/

#print Nat.factorial_le /-
@[mono]
theorem factorial_le {m n} (h : m ≤ n) : m ! ≤ n ! :=
  le_of_dvd (factorial_pos _) (factorial_dvd_factorial h)
#align nat.factorial_le Nat.factorial_le
-/

#print Nat.factorial_mul_pow_le_factorial /-
theorem factorial_mul_pow_le_factorial : ∀ {m n : ℕ}, m ! * m.succ ^ n ≤ (m + n)!
  | m, 0 => by simp
  | m, n + 1 => by
    rw [← add_assoc, Nat.factorial_succ, mul_comm (Nat.succ _), pow_succ', ← mul_assoc] <;>
      exact
        mul_le_mul factorial_mul_pow_le_factorial (Nat.succ_le_succ (Nat.le_add_right _ _))
          (Nat.zero_le _) (Nat.zero_le _)
#align nat.factorial_mul_pow_le_factorial Nat.factorial_mul_pow_le_factorial
-/

#print Nat.monotone_factorial /-
theorem monotone_factorial : Monotone factorial := fun n m => factorial_le
#align nat.monotone_factorial Nat.monotone_factorial
-/

#print Nat.factorial_lt /-
theorem factorial_lt (hn : 0 < n) : n ! < m ! ↔ n < m :=
  by
  refine' ⟨fun h => not_le.mp fun hmn => not_le_of_lt h (factorial_le hmn), fun h => _⟩
  have : ∀ {n}, 0 < n → n ! < n.succ ! := by
    intro k hk
    rw [factorial_succ, succ_mul, lt_add_iff_pos_left]
    exact mul_pos hk k.factorial_pos
  induction' h with k hnk ih generalizing hn
  · exact this hn
  · exact (ih hn).trans (this <| hn.trans <| lt_of_succ_le hnk)
#align nat.factorial_lt Nat.factorial_lt
-/

#print Nat.one_lt_factorial /-
theorem one_lt_factorial : 1 < n ! ↔ 1 < n :=
  factorial_lt one_pos
#align nat.one_lt_factorial Nat.one_lt_factorial
-/

#print Nat.factorial_eq_one /-
theorem factorial_eq_one : n ! = 1 ↔ n ≤ 1 :=
  by
  refine' ⟨fun h => _, by rintro (_ | _ | _) <;> rfl⟩
  rw [← not_lt, ← one_lt_factorial, h]
  apply lt_irrefl
#align nat.factorial_eq_one Nat.factorial_eq_one
-/

#print Nat.factorial_inj /-
theorem factorial_inj (hn : 1 < n !) : n ! = m ! ↔ n = m :=
  by
  refine' ⟨fun h => _, congr_arg _⟩
  obtain hnm | rfl | hnm := lt_trichotomy n m
  · rw [← factorial_lt <| pos_of_gt <| one_lt_factorial.mp hn, h] at hnm 
    cases lt_irrefl _ hnm
  · rfl
  rw [h, one_lt_factorial] at hn 
  rw [← factorial_lt (lt_trans one_pos hn), h] at hnm 
  cases lt_irrefl _ hnm
#align nat.factorial_inj Nat.factorial_inj
-/

#print Nat.self_le_factorial /-
theorem self_le_factorial : ∀ n : ℕ, n ≤ n !
  | 0 => zero_le_one
  | k + 1 => le_mul_of_one_le_right k.zero_lt_succ.le (Nat.one_le_of_lt <| Nat.factorial_pos _)
#align nat.self_le_factorial Nat.self_le_factorial
-/

#print Nat.lt_factorial_self /-
theorem lt_factorial_self {n : ℕ} (hi : 3 ≤ n) : n < n ! :=
  by
  rw [← succ_pred_eq_of_pos ((zero_lt_two.trans (lt.base 2)).trans_le hi), factorial_succ]
  exact
    lt_mul_of_one_lt_right (pred n).succ_pos
      ((one_lt_two.trans_le (le_pred_of_lt (succ_le_iff.mp hi))).trans_le (self_le_factorial _))
#align nat.lt_factorial_self Nat.lt_factorial_self
-/

#print Nat.add_factorial_succ_lt_factorial_add_succ /-
theorem add_factorial_succ_lt_factorial_add_succ {i : ℕ} (n : ℕ) (hi : 2 ≤ i) :
    i + (n + 1)! < (i + n + 1)! :=
  by
  rw [factorial_succ (i + _), add_mul, one_mul]
  have : i ≤ i + n := le.intro rfl
  exact
    add_lt_add_of_lt_of_le
      (this.trans_lt
        ((lt_mul_iff_one_lt_right (zero_lt_two.trans_le (hi.trans this))).mpr
          (lt_iff_le_and_ne.mpr
            ⟨(i + n).factorial_pos, fun g =>
              Nat.not_succ_le_self 1 ((hi.trans this).trans (factorial_eq_one.mp g.symm))⟩)))
      (factorial_le
        ((le_of_eq (add_comm n 1)).trans ((add_le_add_iff_right n).mpr (one_le_two.trans hi))))
#align nat.add_factorial_succ_lt_factorial_add_succ Nat.add_factorial_succ_lt_factorial_add_succ
-/

#print Nat.add_factorial_lt_factorial_add /-
theorem add_factorial_lt_factorial_add {i n : ℕ} (hi : 2 ≤ i) (hn : 1 ≤ n) : i + n ! < (i + n)! :=
  by
  cases hn
  · rw [factorial_one]
    exact lt_factorial_self (succ_le_succ hi)
  exact add_factorial_succ_lt_factorial_add_succ _ hi
#align nat.add_factorial_lt_factorial_add Nat.add_factorial_lt_factorial_add
-/

#print Nat.add_factorial_succ_le_factorial_add_succ /-
theorem add_factorial_succ_le_factorial_add_succ (i : ℕ) (n : ℕ) : i + (n + 1)! ≤ (i + (n + 1))! :=
  by
  obtain i2 | _ | i0 := le_or_lt 2 i
  · exact (n.add_factorial_succ_lt_factorial_add_succ i2).le
  · rw [← add_assoc, factorial_succ (1 + n), add_mul, one_mul, add_comm 1 n]
    exact (add_le_add_iff_right _).mpr (one_le_mul (Nat.le_add_left 1 n) (n + 1).factorial_pos)
  rw [le_zero_iff.mp (nat.succ_le_succ_iff.mp i0), zero_add, zero_add]
#align nat.add_factorial_succ_le_factorial_add_succ Nat.add_factorial_succ_le_factorial_add_succ
-/

#print Nat.add_factorial_le_factorial_add /-
theorem add_factorial_le_factorial_add (i : ℕ) {n : ℕ} (n1 : 1 ≤ n) : i + n ! ≤ (i + n)! :=
  by
  cases' n1 with h
  · exact self_le_factorial _
  exact add_factorial_succ_le_factorial_add_succ i h
#align nat.add_factorial_le_factorial_add Nat.add_factorial_le_factorial_add
-/

#print Nat.factorial_mul_pow_sub_le_factorial /-
theorem factorial_mul_pow_sub_le_factorial {n m : ℕ} (hnm : n ≤ m) : n ! * n ^ (m - n) ≤ m ! :=
  by
  suffices n ! * (n + 1) ^ (m - n) ≤ m ! by
    apply trans _ this
    rw [mul_le_mul_left]
    apply pow_le_pow_of_le_left (zero_le n) (le_succ n)
    exact factorial_pos n
  convert Nat.factorial_mul_pow_le_factorial
  exact (add_tsub_cancel_of_le hnm).symm
#align nat.factorial_mul_pow_sub_le_factorial Nat.factorial_mul_pow_sub_le_factorial
-/

end Factorial

/-! ### Ascending and descending factorials -/


section AscFactorial

#print Nat.ascFactorial /-
/-- `n.asc_factorial k = (n + k)! / n!` (as seen in `nat.asc_factorial_eq_div`), but implemented
recursively to allow for "quick" computation when using `norm_num`. This is closely related to
`pochhammer`, but much less general. -/
def ascFactorial (n : ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => (n + k + 1) * asc_factorial k
#align nat.asc_factorial Nat.ascFactorial
-/

#print Nat.ascFactorial_zero /-
@[simp]
theorem ascFactorial_zero (n : ℕ) : n.ascFactorial 0 = 1 :=
  rfl
#align nat.asc_factorial_zero Nat.ascFactorial_zero
-/

#print Nat.zero_ascFactorial /-
@[simp]
theorem zero_ascFactorial (k : ℕ) : (0 : ℕ).ascFactorial k = k ! :=
  by
  induction' k with t ht
  · rfl
  rw [asc_factorial, ht, zero_add, Nat.factorial_succ]
#align nat.zero_asc_factorial Nat.zero_ascFactorial
-/

#print Nat.ascFactorial_succ /-
theorem ascFactorial_succ {n k : ℕ} : n.ascFactorial k.succ = (n + k + 1) * n.ascFactorial k :=
  rfl
#align nat.asc_factorial_succ Nat.ascFactorial_succ
-/

#print Nat.succ_ascFactorial /-
theorem succ_ascFactorial (n : ℕ) :
    ∀ k, (n + 1) * n.succ.ascFactorial k = (n + k + 1) * n.ascFactorial k
  | 0 => by rw [add_zero, asc_factorial_zero, asc_factorial_zero]
  | k + 1 => by
    rw [asc_factorial, mul_left_comm, succ_asc_factorial, asc_factorial, succ_add, ← add_assoc]
#align nat.succ_asc_factorial Nat.succ_ascFactorial
-/

#print Nat.factorial_mul_ascFactorial /-
/-- `n.asc_factorial k = (n + k)! / n!` but without ℕ-division. See `nat.asc_factorial_eq_div` for
the version with ℕ-division. -/
theorem factorial_mul_ascFactorial (n : ℕ) : ∀ k, n ! * n.ascFactorial k = (n + k)!
  | 0 => by rw [asc_factorial, add_zero, mul_one]
  | k + 1 => by
    rw [asc_factorial_succ, mul_left_comm, factorial_mul_asc_factorial, ← add_assoc, factorial]
#align nat.factorial_mul_asc_factorial Nat.factorial_mul_ascFactorial
-/

#print Nat.ascFactorial_eq_div /-
/-- Avoid in favor of `nat.factorial_mul_asc_factorial` if you can. ℕ-division isn't worth it. -/
theorem ascFactorial_eq_div (n k : ℕ) : n.ascFactorial k = (n + k)! / n ! :=
  by
  apply mul_left_cancel₀ n.factorial_ne_zero
  rw [factorial_mul_asc_factorial]
  exact (Nat.mul_div_cancel' <| factorial_dvd_factorial <| le.intro rfl).symm
#align nat.asc_factorial_eq_div Nat.ascFactorial_eq_div
-/

#print Nat.ascFactorial_of_sub /-
theorem ascFactorial_of_sub {n k : ℕ} (h : k < n) :
    (n - k) * (n - k).ascFactorial k = (n - (k + 1)).ascFactorial (k + 1) :=
  by
  set t := n - k.succ with ht
  suffices h' : n - k = t.succ; · rw [← ht, h', succ_asc_factorial, asc_factorial_succ]
  rw [ht, succ_eq_add_one, ← tsub_tsub_assoc (succ_le_of_lt h) (succ_pos _), succ_sub_one]
#align nat.asc_factorial_of_sub Nat.ascFactorial_of_sub
-/

#print Nat.pow_succ_le_ascFactorial /-
theorem pow_succ_le_ascFactorial (n : ℕ) : ∀ k : ℕ, (n + 1) ^ k ≤ n.ascFactorial k
  | 0 => by rw [asc_factorial_zero, pow_zero]
  | k + 1 => by
    rw [pow_succ]
    exact Nat.mul_le_mul (Nat.add_le_add_right le_self_add _) (pow_succ_le_asc_factorial k)
#align nat.pow_succ_le_asc_factorial Nat.pow_succ_le_ascFactorial
-/

#print Nat.pow_lt_ascFactorial' /-
theorem pow_lt_ascFactorial' (n k : ℕ) : (n + 1) ^ (k + 2) < n.ascFactorial (k + 2) :=
  by
  rw [pow_succ]
  exact
    Nat.mul_lt_mul (Nat.add_lt_add_right (Nat.lt_add_of_pos_right succ_pos') 1)
      (pow_succ_le_asc_factorial n _) (pow_pos succ_pos' _)
#align nat.pow_lt_asc_factorial' Nat.pow_lt_ascFactorial'
-/

#print Nat.pow_lt_ascFactorial /-
theorem pow_lt_ascFactorial (n : ℕ) : ∀ {k : ℕ}, 2 ≤ k → (n + 1) ^ k < n.ascFactorial k
  | 0 => by rintro ⟨⟩
  | 1 => by rintro (_ | ⟨⟨⟩⟩)
  | k + 2 => fun _ => pow_lt_ascFactorial' n k
#align nat.pow_lt_asc_factorial Nat.pow_lt_ascFactorial
-/

#print Nat.ascFactorial_le_pow_add /-
theorem ascFactorial_le_pow_add (n : ℕ) : ∀ k : ℕ, n.ascFactorial k ≤ (n + k) ^ k
  | 0 => by rw [asc_factorial_zero, pow_zero]
  | k + 1 => by
    rw [asc_factorial_succ, pow_succ]
    exact
      Nat.mul_le_mul_of_nonneg_left
        ((asc_factorial_le_pow_add k).trans (Nat.pow_le_pow_of_le_left (le_succ _) _))
#align nat.asc_factorial_le_pow_add Nat.ascFactorial_le_pow_add
-/

#print Nat.ascFactorial_lt_pow_add /-
theorem ascFactorial_lt_pow_add (n : ℕ) : ∀ {k : ℕ}, 2 ≤ k → n.ascFactorial k < (n + k) ^ k
  | 0 => by rintro ⟨⟩
  | 1 => by rintro (_ | ⟨⟨⟩⟩)
  | k + 2 => fun _ => by
    rw [asc_factorial_succ, pow_succ]
    refine'
      Nat.mul_lt_mul' le_rfl
        ((asc_factorial_le_pow_add n _).trans_lt
          (pow_lt_pow_of_lt_left (lt_add_one _) (succ_pos _)))
        (succ_pos _)
#align nat.asc_factorial_lt_pow_add Nat.ascFactorial_lt_pow_add
-/

#print Nat.ascFactorial_pos /-
theorem ascFactorial_pos (n k : ℕ) : 0 < n.ascFactorial k :=
  (pow_pos (succ_pos n) k).trans_le (pow_succ_le_ascFactorial n k)
#align nat.asc_factorial_pos Nat.ascFactorial_pos
-/

end AscFactorial

section DescFactorial

#print Nat.descFactorial /-
/-- `n.desc_factorial k = n! / (n - k)!` (as seen in `nat.desc_factorial_eq_div`), but
implemented recursively to allow for "quick" computation when using `norm_num`. This is closely
related to `pochhammer`, but much less general. -/
def descFactorial (n : ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => (n - k) * desc_factorial k
#align nat.desc_factorial Nat.descFactorial
-/

#print Nat.descFactorial_zero /-
@[simp]
theorem descFactorial_zero (n : ℕ) : n.descFactorial 0 = 1 :=
  rfl
#align nat.desc_factorial_zero Nat.descFactorial_zero
-/

#print Nat.descFactorial_succ /-
@[simp]
theorem descFactorial_succ (n k : ℕ) : n.descFactorial k.succ = (n - k) * n.descFactorial k :=
  rfl
#align nat.desc_factorial_succ Nat.descFactorial_succ
-/

#print Nat.zero_descFactorial_succ /-
theorem zero_descFactorial_succ (k : ℕ) : (0 : ℕ).descFactorial k.succ = 0 := by
  rw [desc_factorial_succ, zero_tsub, MulZeroClass.zero_mul]
#align nat.zero_desc_factorial_succ Nat.zero_descFactorial_succ
-/

#print Nat.descFactorial_one /-
@[simp]
theorem descFactorial_one (n : ℕ) : n.descFactorial 1 = n := by
  rw [desc_factorial_succ, desc_factorial_zero, mul_one, tsub_zero]
#align nat.desc_factorial_one Nat.descFactorial_one
-/

#print Nat.succ_descFactorial_succ /-
@[simp]
theorem succ_descFactorial_succ (n : ℕ) :
    ∀ k : ℕ, (n + 1).descFactorial (k + 1) = (n + 1) * n.descFactorial k
  | 0 => by rw [desc_factorial_zero, desc_factorial_one, mul_one]
  | succ k => by
    rw [desc_factorial_succ, succ_desc_factorial_succ, desc_factorial_succ, succ_sub_succ,
      mul_left_comm]
#align nat.succ_desc_factorial_succ Nat.succ_descFactorial_succ
-/

#print Nat.succ_descFactorial /-
theorem succ_descFactorial (n : ℕ) :
    ∀ k, (n + 1 - k) * (n + 1).descFactorial k = (n + 1) * n.descFactorial k
  | 0 => by rw [tsub_zero, desc_factorial_zero, desc_factorial_zero]
  | k + 1 => by
    rw [desc_factorial, succ_desc_factorial, desc_factorial_succ, succ_sub_succ, mul_left_comm]
#align nat.succ_desc_factorial Nat.succ_descFactorial
-/

#print Nat.descFactorial_self /-
theorem descFactorial_self : ∀ n : ℕ, n.descFactorial n = n !
  | 0 => by rw [desc_factorial_zero, factorial_zero]
  | succ n => by rw [succ_desc_factorial_succ, desc_factorial_self, factorial_succ]
#align nat.desc_factorial_self Nat.descFactorial_self
-/

#print Nat.descFactorial_eq_zero_iff_lt /-
@[simp]
theorem descFactorial_eq_zero_iff_lt {n : ℕ} : ∀ {k : ℕ}, n.descFactorial k = 0 ↔ n < k
  | 0 => by simp only [desc_factorial_zero, Nat.one_ne_zero, Nat.not_lt_zero]
  | succ k =>
    by
    rw [desc_factorial_succ, mul_eq_zero, desc_factorial_eq_zero_iff_lt, lt_succ_iff,
      tsub_eq_zero_iff_le, lt_iff_le_and_ne, or_iff_left_iff_imp, and_imp]
    exact fun h _ => h
#align nat.desc_factorial_eq_zero_iff_lt Nat.descFactorial_eq_zero_iff_lt
-/

alias desc_factorial_eq_zero_iff_lt ↔ _ desc_factorial_of_lt
#align nat.desc_factorial_of_lt Nat.descFactorial_of_lt

#print Nat.add_descFactorial_eq_ascFactorial /-
theorem add_descFactorial_eq_ascFactorial (n : ℕ) :
    ∀ k : ℕ, (n + k).descFactorial k = n.ascFactorial k
  | 0 => by rw [asc_factorial_zero, desc_factorial_zero]
  | succ k => by
    rw [Nat.add_succ, succ_desc_factorial_succ, asc_factorial_succ,
      add_desc_factorial_eq_asc_factorial]
#align nat.add_desc_factorial_eq_asc_factorial Nat.add_descFactorial_eq_ascFactorial
-/

#print Nat.factorial_mul_descFactorial /-
/-- `n.desc_factorial k = n! / (n - k)!` but without ℕ-division. See `nat.desc_factorial_eq_div`
for the version using ℕ-division. -/
theorem factorial_mul_descFactorial : ∀ {n k : ℕ}, k ≤ n → (n - k)! * n.descFactorial k = n !
  | n, 0 => fun _ => by rw [desc_factorial_zero, mul_one, tsub_zero]
  | 0, succ k => fun h => by exfalso; exact not_succ_le_zero k h
  | succ n, succ k => fun h => by
    rw [succ_desc_factorial_succ, succ_sub_succ, ← mul_assoc, mul_comm (n - k)!, mul_assoc,
      factorial_mul_desc_factorial (Nat.succ_le_succ_iff.1 h), factorial_succ]
#align nat.factorial_mul_desc_factorial Nat.factorial_mul_descFactorial
-/

#print Nat.descFactorial_eq_div /-
/-- Avoid in favor of `nat.factorial_mul_desc_factorial` if you can. ℕ-division isn't worth it. -/
theorem descFactorial_eq_div {n k : ℕ} (h : k ≤ n) : n.descFactorial k = n ! / (n - k)! :=
  by
  apply mul_left_cancel₀ (factorial_ne_zero (n - k))
  rw [factorial_mul_desc_factorial h]
  exact (Nat.mul_div_cancel' <| factorial_dvd_factorial <| Nat.sub_le n k).symm
#align nat.desc_factorial_eq_div Nat.descFactorial_eq_div
-/

#print Nat.pow_sub_le_descFactorial /-
theorem pow_sub_le_descFactorial (n : ℕ) : ∀ k : ℕ, (n + 1 - k) ^ k ≤ n.descFactorial k
  | 0 => by rw [desc_factorial_zero, pow_zero]
  | k + 1 => by
    rw [desc_factorial_succ, pow_succ, succ_sub_succ]
    exact
      Nat.mul_le_mul_of_nonneg_left
        (le_trans (Nat.pow_le_pow_of_le_left (tsub_le_tsub_right (le_succ _) _) k)
          (pow_sub_le_desc_factorial k))
#align nat.pow_sub_le_desc_factorial Nat.pow_sub_le_descFactorial
-/

#print Nat.pow_sub_lt_descFactorial' /-
theorem pow_sub_lt_descFactorial' {n : ℕ} :
    ∀ {k : ℕ}, k + 2 ≤ n → (n - (k + 1)) ^ (k + 2) < n.descFactorial (k + 2)
  | 0 => fun h => by
    rw [desc_factorial_succ, pow_succ, pow_one, desc_factorial_one]
    exact
      Nat.mul_lt_mul_of_pos_left (tsub_lt_self (lt_of_lt_of_le zero_lt_two h) zero_lt_one)
        (tsub_pos_of_lt h)
  | k + 1 => fun h => by
    rw [desc_factorial_succ, pow_succ]
    refine'
      Nat.mul_lt_mul_of_pos_left
        ((Nat.pow_le_pow_of_le_left (tsub_le_tsub_right (le_succ n) _) _).trans_lt _)
        (tsub_pos_of_lt h)
    rw [succ_sub_succ]
    exact pow_sub_lt_desc_factorial' ((le_succ _).trans h)
#align nat.pow_sub_lt_desc_factorial' Nat.pow_sub_lt_descFactorial'
-/

#print Nat.pow_sub_lt_descFactorial /-
theorem pow_sub_lt_descFactorial {n : ℕ} :
    ∀ {k : ℕ}, 2 ≤ k → k ≤ n → (n + 1 - k) ^ k < n.descFactorial k
  | 0 => by rintro ⟨⟩
  | 1 => by rintro (_ | ⟨⟨⟩⟩)
  | k + 2 => fun _ h => by rw [succ_sub_succ]; exact pow_sub_lt_desc_factorial' h
#align nat.pow_sub_lt_desc_factorial Nat.pow_sub_lt_descFactorial
-/

#print Nat.descFactorial_le_pow /-
theorem descFactorial_le_pow (n : ℕ) : ∀ k : ℕ, n.descFactorial k ≤ n ^ k
  | 0 => by rw [desc_factorial_zero, pow_zero]
  | k + 1 => by
    rw [desc_factorial_succ, pow_succ]
    exact Nat.mul_le_mul (Nat.sub_le _ _) (desc_factorial_le_pow k)
#align nat.desc_factorial_le_pow Nat.descFactorial_le_pow
-/

#print Nat.descFactorial_lt_pow /-
theorem descFactorial_lt_pow {n : ℕ} (hn : 1 ≤ n) : ∀ {k : ℕ}, 2 ≤ k → n.descFactorial k < n ^ k
  | 0 => by rintro ⟨⟩
  | 1 => by rintro (_ | ⟨⟨⟩⟩)
  | k + 2 => fun _ => by
    rw [desc_factorial_succ, pow_succ', mul_comm]
    exact
      Nat.mul_lt_mul' (desc_factorial_le_pow _ _) (tsub_lt_self hn k.zero_lt_succ) (pow_pos hn _)
#align nat.desc_factorial_lt_pow Nat.descFactorial_lt_pow
-/

end DescFactorial

end Nat

