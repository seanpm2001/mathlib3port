/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module data.int.order.basic
! leanprover-community/mathlib commit e8638a0fcaf73e4500469f368ef9494e495099b3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Basic
import Mathbin.Data.Int.Cast.Basic
import Mathbin.Algebra.Ring.Divisibility
import Mathbin.Algebra.Order.Group.Abs
import Mathbin.Algebra.Order.Ring.CharZero
import Mathbin.Tactic.AssertExists

/-!
# Order instances on the integers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains:
* instances on `ℤ`. The stronger one is `int.linear_ordered_comm_ring`.
* basic lemmas about integers that involve order properties.

## Recursors

* `int.rec`: Sign disjunction. Something is true/defined on `ℤ` if it's true/defined for nonnegative
  and for negative values. (Defined in core Lean 3)
* `int.induction_on`: Simple growing induction on positive numbers, plus simple decreasing induction
  on negative numbers. Note that this recursor is currently only `Prop`-valued.
* `int.induction_on'`: Simple growing induction for numbers greater than `b`, plus simple decreasing
  induction on numbers less than `b`.
-/


open Nat

namespace Int

instance : LinearOrderedCommRing ℤ :=
  { Int.commRing, Int.linearOrder,
    Int.nontrivial with
    add_le_add_left := @Int.add_le_add_left
    mul_pos := @Int.mul_pos
    zero_le_one := le_of_lt Int.zero_lt_one }

/-! ### Extra instances to short-circuit type class resolution
-/


instance : OrderedCommRing ℤ :=
  StrictOrderedCommRing.toOrderedCommRing'

instance : OrderedRing ℤ :=
  StrictOrderedRing.toOrderedRing'

instance : LinearOrderedAddCommGroup ℤ := by infer_instance

end Int

namespace Int

#print Int.abs_eq_natAbs /-
theorem abs_eq_natAbs : ∀ a : ℤ, |a| = natAbs a
  | (n : ℕ) => abs_of_nonneg <| ofNat_zero_le _
  | -[n+1] => abs_of_nonpos <| le_of_lt <| negSucc_lt_zero _
#align int.abs_eq_nat_abs Int.abs_eq_natAbs
-/

#print Int.coe_natAbs /-
@[simp, norm_cast]
theorem coe_natAbs (n : ℤ) : (n.natAbs : ℤ) = |n| :=
  n.abs_eq_natAbs.symm
#align int.coe_nat_abs Int.coe_natAbs
-/

#print Nat.cast_natAbs /-
theorem Nat.cast_natAbs {α : Type _} [AddGroupWithOne α] (n : ℤ) : (n.natAbs : α) = ↑(|n|) := by
  rw [← Int.coe_natAbs, Int.cast_ofNat]
#align nat.cast_nat_abs Nat.cast_natAbs
-/

#print Int.natAbs_abs /-
theorem natAbs_abs (a : ℤ) : natAbs (|a|) = natAbs a := by rw [abs_eq_nat_abs] <;> rfl
#align int.nat_abs_abs Int.natAbs_abs
-/

#print Int.sign_mul_abs /-
theorem sign_mul_abs (a : ℤ) : sign a * |a| = a := by rw [abs_eq_nat_abs, sign_mul_nat_abs]
#align int.sign_mul_abs Int.sign_mul_abs
-/

#print Int.coe_nat_eq_zero /-
theorem coe_nat_eq_zero {n : ℕ} : (n : ℤ) = 0 ↔ n = 0 :=
  Nat.cast_eq_zero
#align int.coe_nat_eq_zero Int.coe_nat_eq_zero
-/

#print Int.coe_nat_ne_zero /-
theorem coe_nat_ne_zero {n : ℕ} : (n : ℤ) ≠ 0 ↔ n ≠ 0 := by simp
#align int.coe_nat_ne_zero Int.coe_nat_ne_zero
-/

#print Int.coe_nat_ne_zero_iff_pos /-
theorem coe_nat_ne_zero_iff_pos {n : ℕ} : (n : ℤ) ≠ 0 ↔ 0 < n :=
  ⟨fun h => Nat.pos_of_ne_zero (coe_nat_ne_zero.1 h), fun h => (ne_of_lt (ofNat_lt.2 h)).symm⟩
#align int.coe_nat_ne_zero_iff_pos Int.coe_nat_ne_zero_iff_pos
-/

#print Int.abs_coe_nat /-
@[norm_cast]
theorem abs_coe_nat (n : ℕ) : |(n : ℤ)| = n :=
  abs_of_nonneg (coe_nat_nonneg n)
#align int.abs_coe_nat Int.abs_coe_nat
-/

#print Int.sign_add_eq_of_sign_eq /-
theorem sign_add_eq_of_sign_eq : ∀ {m n : ℤ}, m.sign = n.sign → (m + n).sign = n.sign :=
  by
  have : (1 : ℤ) ≠ -1 := by decide
  rintro ((_ | m) | m) ((_ | n) | n) <;> simp [this, this.symm]
  rw [Int.sign_eq_one_iff_pos]
  apply Int.add_pos <;> · exact zero_lt_one.trans_le (le_add_of_nonneg_left <| coe_zero_le _)
#align int.sign_add_eq_of_sign_eq Int.sign_add_eq_of_sign_eq
-/

/-! ### succ and pred -/


#print Int.lt_succ_self /-
theorem lt_succ_self (a : ℤ) : a < succ a :=
  lt_add_of_pos_right _ zero_lt_one
#align int.lt_succ_self Int.lt_succ_self
-/

#print Int.pred_self_lt /-
theorem pred_self_lt (a : ℤ) : pred a < a :=
  sub_lt_self _ zero_lt_one
#align int.pred_self_lt Int.pred_self_lt
-/

#print Int.lt_add_one_iff /-
theorem lt_add_one_iff {a b : ℤ} : a < b + 1 ↔ a ≤ b :=
  add_le_add_iff_right _
#align int.lt_add_one_iff Int.lt_add_one_iff
-/

#print Int.le_add_one /-
theorem le_add_one {a b : ℤ} (h : a ≤ b) : a ≤ b + 1 :=
  le_of_lt (Int.lt_add_one_iff.mpr h)
#align int.le_add_one Int.le_add_one
-/

#print Int.sub_one_lt_iff /-
theorem sub_one_lt_iff {a b : ℤ} : a - 1 < b ↔ a ≤ b :=
  sub_lt_iff_lt_add.trans lt_add_one_iff
#align int.sub_one_lt_iff Int.sub_one_lt_iff
-/

#print Int.le_sub_one_iff /-
theorem le_sub_one_iff {a b : ℤ} : a ≤ b - 1 ↔ a < b :=
  le_sub_iff_add_le
#align int.le_sub_one_iff Int.le_sub_one_iff
-/

#print Int.abs_lt_one_iff /-
@[simp]
theorem abs_lt_one_iff {a : ℤ} : |a| < 1 ↔ a = 0 :=
  ⟨fun a0 =>
    let ⟨hn, hp⟩ := abs_lt.mp a0
    (le_of_lt_add_one hp).antisymm hn,
    fun a0 => (abs_eq_zero.mpr a0).le.trans_lt zero_lt_one⟩
#align int.abs_lt_one_iff Int.abs_lt_one_iff
-/

#print Int.abs_le_one_iff /-
theorem abs_le_one_iff {a : ℤ} : |a| ≤ 1 ↔ a = 0 ∨ a = 1 ∨ a = -1 := by
  rw [le_iff_lt_or_eq, abs_lt_one_iff, abs_eq (zero_le_one' ℤ)]
#align int.abs_le_one_iff Int.abs_le_one_iff
-/

#print Int.one_le_abs /-
theorem one_le_abs {z : ℤ} (h₀ : z ≠ 0) : 1 ≤ |z| :=
  add_one_le_iff.mpr (abs_pos.mpr h₀)
#align int.one_le_abs Int.one_le_abs
-/

#print Int.inductionOn' /-
/-- Inductively define a function on `ℤ` by defining it at `b`, for the `succ` of a number greater
than `b`, and the `pred` of a number less than `b`. -/
@[elab_as_elim]
protected def inductionOn' {C : ℤ → Sort _} (z : ℤ) (b : ℤ) (H0 : C b)
    (Hs : ∀ k, b ≤ k → C k → C (k + 1)) (Hp : ∀ k ≤ b, C k → C (k - 1)) : C z :=
  by
  -- Note that we use `convert` here where possible as we are constructing data, and this reduces
  -- the number of times `eq.mpr` appears in the term.
  rw [← sub_add_cancel z b]
  induction' z - b with n n
  · induction' n with n ih
    · convert H0 using 1
      rw [of_nat_zero, zero_add]
    convert Hs _ (le_add_of_nonneg_left (of_nat_nonneg _)) ih using 1
    rw [of_nat_succ, add_assoc, add_comm 1 b, ← add_assoc]
  · induction' n with n ih
    · convert Hp _ le_rfl H0 using 1
      rw [neg_succ_of_nat_eq, ← of_nat_eq_coe, of_nat_zero, zero_add, neg_add_eq_sub]
    · convert Hp _ (le_of_lt (add_lt_of_neg_of_le (neg_succ_lt_zero _) le_rfl)) ih using 1
      rw [neg_succ_of_nat_coe', Nat.succ_eq_add_one, ← neg_succ_of_nat_coe, sub_add_eq_add_sub]
#align int.induction_on' Int.inductionOn'
-/

#print Int.le_induction /-
/-- See `int.induction_on'` for an induction in both directions. -/
protected theorem le_induction {P : ℤ → Prop} {m : ℤ} (h0 : P m)
    (h1 : ∀ n : ℤ, m ≤ n → P n → P (n + 1)) (n : ℤ) : m ≤ n → P n :=
  by
  apply Int.inductionOn' n m
  · intro; exact h0
  · intro k hle hi _; exact h1 k hle (hi hle)
  · intro _ hle _ hle'
    exfalso
    exact lt_irrefl k (le_sub_one_iff.mp (hle.trans hle'))
#align int.le_induction Int.le_induction
-/

#print Int.le_induction_down /-
/-- See `int.induction_on'` for an induction in both directions. -/
protected theorem le_induction_down {P : ℤ → Prop} {m : ℤ} (h0 : P m)
    (h1 : ∀ n : ℤ, n ≤ m → P n → P (n - 1)) (n : ℤ) : n ≤ m → P n :=
  by
  apply Int.inductionOn' n m
  · intro; exact h0
  · intro _ hle _ hle'
    exfalso
    exact lt_irrefl k (add_one_le_iff.mp (hle'.trans hle))
  · intro k hle hi _
    exact h1 k hle (hi hle)
#align int.le_induction_down Int.le_induction_down
-/

/-! ### nat abs -/


variable {a b : ℤ} {n : ℕ}

attribute [simp] nat_abs nat_abs_of_nat nat_abs_zero nat_abs_one

#print Int.natAbs_dvd_natAbs /-
@[simp]
theorem natAbs_dvd_natAbs {a b : ℤ} : a.natAbs ∣ b.natAbs ↔ a ∣ b :=
  by
  refine' ⟨_, fun ⟨k, hk⟩ => ⟨k.natAbs, hk.symm ▸ nat_abs_mul a k⟩⟩
  rintro ⟨k, hk⟩
  rw [← nat_abs_of_nat k, ← nat_abs_mul, nat_abs_eq_nat_abs_iff, neg_mul_eq_mul_neg] at hk 
  cases hk <;> exact ⟨_, hk⟩
#align int.nat_abs_dvd_iff_dvd Int.natAbs_dvd_natAbs
-/

/-! ### `/`  -/


#print Int.ediv_nonpos /-
protected theorem ediv_nonpos {a b : ℤ} (Ha : 0 ≤ a) (Hb : b ≤ 0) : a / b ≤ 0 :=
  nonpos_of_neg_nonneg <| by
    rw [← Int.div_neg] <;> exact Int.div_nonneg Ha (neg_nonneg_of_nonpos Hb)
#align int.div_nonpos Int.ediv_nonpos
-/

#print Int.ediv_eq_zero_of_lt_abs /-
theorem ediv_eq_zero_of_lt_abs {a b : ℤ} (H1 : 0 ≤ a) (H2 : a < |b|) : a / b = 0 :=
  match b, |b|, abs_eq_natAbs b, H2 with
  | (n : ℕ), _, rfl, H2 => div_eq_zero_of_lt H1 H2
  | -[n+1], _, rfl, H2 => neg_injective <| by rw [← Int.div_neg] <;> exact div_eq_zero_of_lt H1 H2
#align int.div_eq_zero_of_lt_abs Int.ediv_eq_zero_of_lt_abs
-/

#print Int.add_mul_ediv_right /-
protected theorem add_mul_ediv_right (a b : ℤ) {c : ℤ} (H : c ≠ 0) : (a + b * c) / c = a / c + b :=
  have : ∀ {k n : ℕ} {a : ℤ}, (a + n * k.succ) / k.succ = a / k.succ + n := fun k n a =>
    match a with
    | (m : ℕ) => congr_arg ofNat <| Nat.add_mul_div_right _ _ k.succ_pos
    | -[m+1] =>
      show ((n * k.succ : ℕ) - m.succ : ℤ) / k.succ = n - (m / k.succ + 1 : ℕ)
        by
        cases' lt_or_ge m (n * k.succ) with h h
        · rw [← Int.ofNat_sub h, ← Int.ofNat_sub ((Nat.div_lt_iff_lt_mul k.succ_pos).2 h)]
          apply congr_arg of_nat
          rw [mul_comm, Nat.mul_sub_div]; rwa [mul_comm]
        · change (↑(n * Nat.succ k) - (m + 1) : ℤ) / ↑(Nat.succ k) = ↑n - ((m / Nat.succ k : ℕ) + 1)
          rw [← sub_sub, ← sub_sub, ← neg_sub (m : ℤ), ← neg_sub _ (n : ℤ), ← Int.ofNat_sub h, ←
            Int.ofNat_sub ((Nat.le_div_iff_mul_le k.succ_pos).2 h), ← neg_succ_of_nat_coe', ←
            neg_succ_of_nat_coe']
          · apply congr_arg neg_succ_of_nat
            rw [mul_comm, Nat.sub_mul_div]; rwa [mul_comm]
  have : ∀ {a b c : ℤ}, 0 < c → (a + b * c) / c = a / c + b := fun a b c H =>
    match c, eq_succ_of_zero_lt H, b with
    | _, ⟨k, rfl⟩, (n : ℕ) => this
    | _, ⟨k, rfl⟩, -[n+1] =>
      show (a - n.succ * k.succ) / k.succ = a / k.succ - n.succ from
        eq_sub_of_add_eq <| by rw [← this, sub_add_cancel]
  match lt_trichotomy c 0 with
  | Or.inl hlt =>
    neg_inj.1 <| by
      rw [← Int.div_neg, neg_add, ← Int.div_neg, ← neg_mul_neg] <;> apply this (neg_pos_of_neg hlt)
  | Or.inr (Or.inl HEq) => absurd HEq H
  | Or.inr (Or.inr hgt) => this hgt
#align int.add_mul_div_right Int.add_mul_ediv_right
-/

#print Int.add_mul_ediv_left /-
protected theorem add_mul_ediv_left (a : ℤ) {b : ℤ} (c : ℤ) (H : b ≠ 0) :
    (a + b * c) / b = a / b + c := by rw [mul_comm, Int.add_mul_ediv_right _ _ H]
#align int.add_mul_div_left Int.add_mul_ediv_left
-/

#print Int.mul_ediv_cancel /-
@[simp]
protected theorem mul_ediv_cancel (a : ℤ) {b : ℤ} (H : b ≠ 0) : a * b / b = a := by
  have := Int.add_mul_ediv_right 0 a H <;> rwa [zero_add, Int.zero_div, zero_add] at this 
#align int.mul_div_cancel Int.mul_ediv_cancel
-/

#print Int.mul_ediv_cancel_left /-
@[simp]
protected theorem mul_ediv_cancel_left {a : ℤ} (b : ℤ) (H : a ≠ 0) : a * b / a = b := by
  rw [mul_comm, Int.mul_ediv_cancel _ H]
#align int.mul_div_cancel_left Int.mul_ediv_cancel_left
-/

#print Int.ediv_self /-
@[simp]
protected theorem ediv_self {a : ℤ} (H : a ≠ 0) : a / a = 1 := by
  have := Int.mul_ediv_cancel 1 H <;> rwa [one_mul] at this 
#align int.div_self Int.ediv_self
-/

attribute [local simp] Int.zero_div Int.div_zero

#print Int.add_ediv_of_dvd_right /-
protected theorem add_ediv_of_dvd_right {a b c : ℤ} (H : c ∣ b) : (a + b) / c = a / c + b / c :=
  by
  by_cases h1 : c = 0
  · simp [h1]
  cases' H with k hk
  rw [hk]
  change c ≠ 0 at h1 
  rw [mul_comm c k, Int.add_mul_ediv_right _ _ h1, ← zero_add (k * c),
    Int.add_mul_ediv_right _ _ h1, Int.zero_div, zero_add]
#align int.add_div_of_dvd_right Int.add_ediv_of_dvd_right
-/

#print Int.add_ediv_of_dvd_left /-
protected theorem add_ediv_of_dvd_left {a b c : ℤ} (H : c ∣ a) : (a + b) / c = a / c + b / c := by
  rw [add_comm, Int.add_ediv_of_dvd_right H, add_comm]
#align int.add_div_of_dvd_left Int.add_ediv_of_dvd_left
-/

/-! ### mod -/


#print Int.emod_abs /-
@[simp]
theorem emod_abs (a b : ℤ) : a % |b| = a % b :=
  abs_by_cases (fun i => a % i = a % b) rfl (mod_neg _ _)
#align int.mod_abs Int.emod_abs
-/

#print Int.emod_nonneg /-
theorem emod_nonneg : ∀ (a : ℤ) {b : ℤ}, b ≠ 0 → 0 ≤ a % b
  | (m : ℕ), n, H => ofNat_zero_le _
  | -[m+1], n, H =>
    sub_nonneg_of_le <| ofNat_le_ofNat_of_le <| Nat.mod_lt _ (natAbs_pos_of_ne_zero H)
#align int.mod_nonneg Int.emod_nonneg
-/

#print Int.emod_lt_of_pos /-
theorem emod_lt_of_pos (a : ℤ) {b : ℤ} (H : 0 < b) : a % b < b :=
  match a, b, eq_succ_of_zero_lt H with
  | (m : ℕ), _, ⟨n, rfl⟩ => ofNat_lt_ofNat_of_lt (Nat.mod_lt _ (Nat.succ_pos _))
  | -[m+1], _, ⟨n, rfl⟩ => sub_lt_self _ (ofNat_lt_ofNat_of_lt <| Nat.succ_pos _)
#align int.mod_lt_of_pos Int.emod_lt_of_pos
-/

#print Int.emod_lt /-
theorem emod_lt (a : ℤ) {b : ℤ} (H : b ≠ 0) : a % b < |b| := by
  rw [← mod_abs] <;> exact mod_lt_of_pos _ (abs_pos.2 H)
#align int.mod_lt Int.emod_lt
-/

#print Int.add_mul_emod_self /-
@[simp]
theorem add_mul_emod_self {a b c : ℤ} : (a + b * c) % c = a % c :=
  if cz : c = 0 then by rw [cz, MulZeroClass.mul_zero, add_zero]
  else by
    rw [mod_def, mod_def, Int.add_mul_ediv_right _ _ cz, mul_add, mul_comm,
      add_sub_add_right_eq_sub]
#align int.add_mul_mod_self Int.add_mul_emod_self
-/

#print Int.add_mul_emod_self_left /-
@[simp]
theorem add_mul_emod_self_left (a b c : ℤ) : (a + b * c) % b = a % b := by
  rw [mul_comm, add_mul_mod_self]
#align int.add_mul_mod_self_left Int.add_mul_emod_self_left
-/

#print Int.add_emod_self /-
@[simp]
theorem add_emod_self {a b : ℤ} : (a + b) % b = a % b := by
  have := add_mul_mod_self_left a b 1 <;> rwa [mul_one] at this 
#align int.add_mod_self Int.add_emod_self
-/

#print Int.add_emod_self_left /-
@[simp]
theorem add_emod_self_left {a b : ℤ} : (a + b) % a = b % a := by rw [add_comm, add_mod_self]
#align int.add_mod_self_left Int.add_emod_self_left
-/

#print Int.emod_add_emod /-
@[simp]
theorem emod_add_emod (m n k : ℤ) : (m % n + k) % n = (m + k) % n := by
  have := (add_mul_mod_self_left (m % n + k) n (m / n)).symm <;>
    rwa [add_right_comm, mod_add_div] at this 
#align int.mod_add_mod Int.emod_add_emod
-/

#print Int.add_emod_emod /-
@[simp]
theorem add_emod_emod (m n k : ℤ) : (m + n % k) % k = (m + n) % k := by
  rw [add_comm, mod_add_mod, add_comm]
#align int.add_mod_mod Int.add_emod_emod
-/

#print Int.add_emod /-
theorem add_emod (a b n : ℤ) : (a + b) % n = (a % n + b % n) % n := by rw [add_mod_mod, mod_add_mod]
#align int.add_mod Int.add_emod
-/

#print Int.add_emod_eq_add_emod_right /-
theorem add_emod_eq_add_emod_right {m n k : ℤ} (i : ℤ) (H : m % n = k % n) :
    (m + i) % n = (k + i) % n := by rw [← mod_add_mod, ← mod_add_mod k, H]
#align int.add_mod_eq_add_mod_right Int.add_emod_eq_add_emod_right
-/

#print Int.add_emod_eq_add_emod_left /-
theorem add_emod_eq_add_emod_left {m n k : ℤ} (i : ℤ) (H : m % n = k % n) :
    (i + m) % n = (i + k) % n := by rw [add_comm, add_mod_eq_add_mod_right _ H, add_comm]
#align int.add_mod_eq_add_mod_left Int.add_emod_eq_add_emod_left
-/

#print Int.emod_add_cancel_right /-
theorem emod_add_cancel_right {m n k : ℤ} (i) : (m + i) % n = (k + i) % n ↔ m % n = k % n :=
  ⟨fun H => by
    have := add_mod_eq_add_mod_right (-i) H <;>
      rwa [add_neg_cancel_right, add_neg_cancel_right] at this ,
    add_emod_eq_add_emod_right _⟩
#align int.mod_add_cancel_right Int.emod_add_cancel_right
-/

#print Int.emod_add_cancel_left /-
theorem emod_add_cancel_left {m n k i : ℤ} : (i + m) % n = (i + k) % n ↔ m % n = k % n := by
  rw [add_comm, add_comm i, mod_add_cancel_right]
#align int.mod_add_cancel_left Int.emod_add_cancel_left
-/

#print Int.emod_sub_cancel_right /-
theorem emod_sub_cancel_right {m n k : ℤ} (i) : (m - i) % n = (k - i) % n ↔ m % n = k % n :=
  emod_add_cancel_right _
#align int.mod_sub_cancel_right Int.emod_sub_cancel_right
-/

#print Int.mul_emod_left /-
@[simp]
theorem mul_emod_left (a b : ℤ) : a * b % b = 0 := by
  rw [← zero_add (a * b), add_mul_mod_self, zero_mod]
#align int.mul_mod_left Int.mul_emod_left
-/

#print Int.mul_emod_right /-
@[simp]
theorem mul_emod_right (a b : ℤ) : a * b % a = 0 := by rw [mul_comm, mul_mod_left]
#align int.mul_mod_right Int.mul_emod_right
-/

#print Int.mul_emod /-
theorem mul_emod (a b n : ℤ) : a * b % n = a % n * (b % n) % n := by
  conv_lhs =>
    rw [← mod_add_div a n, ← mod_add_div' b n, right_distrib, left_distrib, left_distrib, mul_assoc,
      mul_assoc, ← left_distrib n _ _, add_mul_mod_self_left, ← mul_assoc, add_mul_mod_self]
#align int.mul_mod Int.mul_emod
-/

#print Int.emod_self /-
-- Will be generalized to Euclidean domains.
@[local simp]
theorem emod_self {a : ℤ} : a % a = 0 := by have := mul_mod_left 1 a <;> rwa [one_mul] at this 
#align int.mod_self Int.emod_self
-/

#print Int.emod_emod_of_dvd /-
@[simp]
theorem emod_emod_of_dvd (n : ℤ) {m k : ℤ} (h : m ∣ k) : n % k % m = n % m :=
  by
  conv =>
    rhs
    rw [← mod_add_div n k]
  rcases h with ⟨t, rfl⟩; rw [mul_assoc, add_mul_mod_self_left]
#align int.mod_mod_of_dvd Int.emod_emod_of_dvd
-/

#print Int.emod_emod /-
@[simp]
theorem emod_emod (a b : ℤ) : a % b % b = a % b := by
  conv =>
    rhs
    rw [← mod_add_div a b, add_mul_mod_self_left]
#align int.mod_mod Int.emod_emod
-/

#print Int.sub_emod /-
theorem sub_emod (a b n : ℤ) : (a - b) % n = (a % n - b % n) % n :=
  by
  apply (mod_add_cancel_right b).mp
  rw [sub_add_cancel, ← add_mod_mod, sub_add_cancel, mod_mod]
#align int.sub_mod Int.sub_emod
-/

#print Int.ediv_emod_unique /-
/-- See also `int.div_mod_equiv` for a similar statement as an `equiv`. -/
protected theorem ediv_emod_unique {a b r q : ℤ} (h : 0 < b) :
    a / b = q ∧ a % b = r ↔ r + b * q = a ∧ 0 ≤ r ∧ r < b :=
  by
  constructor
  · rintro ⟨rfl, rfl⟩
    exact ⟨mod_add_div a b, mod_nonneg _ h.ne.symm, mod_lt_of_pos _ h⟩
  · rintro ⟨rfl, hz, hb⟩
    constructor
    · rw [Int.add_mul_ediv_left r q (ne_of_gt h), div_eq_zero_of_lt hz hb]
      simp
    · rw [add_mul_mod_self_left, mod_eq_of_lt hz hb]
#align int.div_mod_unique Int.ediv_emod_unique
-/

attribute [local simp] Int.zero_mod

#print Int.emod_eq_emod_iff_emod_sub_eq_zero /-
theorem emod_eq_emod_iff_emod_sub_eq_zero {m n k : ℤ} : m % n = k % n ↔ (m - k) % n = 0 :=
  (emod_sub_cancel_right k).symm.trans <| by simp
#align int.mod_eq_mod_iff_mod_sub_eq_zero Int.emod_eq_emod_iff_emod_sub_eq_zero
-/

#print Int.neg_emod_two /-
@[simp]
theorem neg_emod_two (i : ℤ) : -i % 2 = i % 2 :=
  by
  apply int.mod_eq_mod_iff_mod_sub_eq_zero.mpr
  convert Int.mul_emod_right 2 (-i)
  simp only [two_mul, sub_eq_add_neg]
#align int.neg_mod_two Int.neg_emod_two
-/

/-! ### properties of `/` and `%` -/


#print Int.lt_ediv_add_one_mul_self /-
theorem lt_ediv_add_one_mul_self (a : ℤ) {b : ℤ} (H : 0 < b) : a < (a / b + 1) * b :=
  by
  rw [add_mul, one_mul, mul_comm, ← sub_lt_iff_lt_add', ← mod_def]
  exact mod_lt_of_pos _ H
#align int.lt_div_add_one_mul_self Int.lt_ediv_add_one_mul_self
-/

#print Int.abs_ediv_le_abs /-
theorem abs_ediv_le_abs : ∀ a b : ℤ, |a / b| ≤ |a| :=
  suffices ∀ (a : ℤ) (n : ℕ), |a / n| ≤ |a| from fun a b =>
    match b, eq_nat_or_neg b with
    | _, ⟨n, Or.inl rfl⟩ => this _ _
    | _, ⟨n, Or.inr rfl⟩ => by rw [Int.div_neg, abs_neg] <;> apply this
  fun a n => by
  rw [abs_eq_nat_abs, abs_eq_nat_abs] <;>
    exact
      coe_nat_le_coe_nat_of_le
        (match a, n with
        | (m : ℕ), n => Nat.div_le_self _ _
        | -[m+1], 0 => Nat.zero_le _
        | -[m+1], n + 1 => Nat.succ_le_succ (Nat.div_le_self _ _))
#align int.abs_div_le_abs Int.abs_ediv_le_abs
-/

#print Int.ediv_le_self /-
theorem ediv_le_self {a : ℤ} (b : ℤ) (Ha : 0 ≤ a) : a / b ≤ a := by
  have := le_trans (le_abs_self _) (abs_div_le_abs a b) <;> rwa [abs_of_nonneg Ha] at this 
#align int.div_le_self Int.ediv_le_self
-/

#print Int.emod_two_eq_zero_or_one /-
theorem emod_two_eq_zero_or_one (n : ℤ) : n % 2 = 0 ∨ n % 2 = 1 :=
  have h : n % 2 < 2 := abs_of_nonneg (show 0 ≤ (2 : ℤ) by decide) ▸ Int.emod_lt _ (by decide)
  have h₁ : 0 ≤ n % 2 := Int.emod_nonneg _ (by decide)
  match n % 2, h, h₁ with
  | (0 : ℕ) => fun _ _ => Or.inl rfl
  | (1 : ℕ) => fun _ _ => Or.inr rfl
  | (k + 2 : ℕ) => fun h _ => absurd h (by decide)
  | -[a+1] => fun _ h₁ => absurd h₁ (by decide)
#align int.mod_two_eq_zero_or_one Int.emod_two_eq_zero_or_one
-/

/-! ### dvd -/


#print Int.dvd_of_emod_eq_zero /-
theorem dvd_of_emod_eq_zero {a b : ℤ} (H : b % a = 0) : a ∣ b :=
  ⟨b / a, (mul_div_cancel_of_mod_eq_zero H).symm⟩
#align int.dvd_of_mod_eq_zero Int.dvd_of_emod_eq_zero
-/

#print Int.emod_eq_zero_of_dvd /-
theorem emod_eq_zero_of_dvd : ∀ {a b : ℤ}, a ∣ b → b % a = 0
  | a, _, ⟨c, rfl⟩ => mul_emod_right _ _
#align int.mod_eq_zero_of_dvd Int.emod_eq_zero_of_dvd
-/

#print Int.dvd_iff_emod_eq_zero /-
theorem dvd_iff_emod_eq_zero (a b : ℤ) : a ∣ b ↔ b % a = 0 :=
  ⟨emod_eq_zero_of_dvd, dvd_of_emod_eq_zero⟩
#align int.dvd_iff_mod_eq_zero Int.dvd_iff_emod_eq_zero
-/

#print Int.dvd_sub_of_emod_eq /-
/-- If `a % b = c` then `b` divides `a - c`. -/
theorem dvd_sub_of_emod_eq {a b c : ℤ} (h : a % b = c) : b ∣ a - c :=
  by
  have hx : a % b % b = c % b := by rw [h]
  rw [mod_mod, ← mod_sub_cancel_right c, sub_self, zero_mod] at hx 
  exact dvd_of_mod_eq_zero hx
#align int.dvd_sub_of_mod_eq Int.dvd_sub_of_emod_eq
-/

#print Int.natAbs_dvd /-
theorem natAbs_dvd {a b : ℤ} : (a.natAbs : ℤ) ∣ b ↔ a ∣ b :=
  (natAbs_eq a).elim (fun e => by rw [← e]) fun e => by rw [← neg_dvd, ← e]
#align int.nat_abs_dvd Int.natAbs_dvd
-/

#print Int.dvd_natAbs /-
theorem dvd_natAbs {a b : ℤ} : a ∣ b.natAbs ↔ a ∣ b :=
  (natAbs_eq b).elim (fun e => by rw [← e]) fun e => by rw [← dvd_neg, ← e]
#align int.dvd_nat_abs Int.dvd_natAbs
-/

#print Int.decidableDvd /-
instance decidableDvd : @DecidableRel ℤ (· ∣ ·) := fun a n =>
  decidable_of_decidable_of_iff (by infer_instance) (dvd_iff_emod_eq_zero _ _).symm
#align int.decidable_dvd Int.decidableDvd
-/

#print Int.ediv_mul_cancel /-
protected theorem ediv_mul_cancel {a b : ℤ} (H : b ∣ a) : a / b * b = a :=
  div_mul_cancel_of_mod_eq_zero (emod_eq_zero_of_dvd H)
#align int.div_mul_cancel Int.ediv_mul_cancel
-/

#print Int.mul_ediv_cancel' /-
protected theorem mul_ediv_cancel' {a b : ℤ} (H : a ∣ b) : a * (b / a) = b := by
  rw [mul_comm, Int.ediv_mul_cancel H]
#align int.mul_div_cancel' Int.mul_ediv_cancel'
-/

#print Int.ediv_dvd_ediv /-
theorem ediv_dvd_ediv : ∀ {a b c : ℤ} (H1 : a ∣ b) (H2 : b ∣ c), b / a ∣ c / a
  | a, _, _, ⟨b, rfl⟩, ⟨c, rfl⟩ =>
    if az : a = 0 then by simp [az]
    else by
      rw [Int.mul_ediv_cancel_left _ az, mul_assoc, Int.mul_ediv_cancel_left _ az] <;>
        apply dvd_mul_right
#align int.div_dvd_div Int.ediv_dvd_ediv
-/

#print Int.eq_mul_of_ediv_eq_right /-
protected theorem eq_mul_of_ediv_eq_right {a b c : ℤ} (H1 : b ∣ a) (H2 : a / b = c) : a = b * c :=
  by rw [← H2, Int.mul_ediv_cancel' H1]
#align int.eq_mul_of_div_eq_right Int.eq_mul_of_ediv_eq_right
-/

#print Int.ediv_eq_of_eq_mul_right /-
protected theorem ediv_eq_of_eq_mul_right {a b c : ℤ} (H1 : b ≠ 0) (H2 : a = b * c) : a / b = c :=
  by rw [H2, Int.mul_ediv_cancel_left _ H1]
#align int.div_eq_of_eq_mul_right Int.ediv_eq_of_eq_mul_right
-/

#print Int.eq_ediv_of_mul_eq_right /-
protected theorem eq_ediv_of_mul_eq_right {a b c : ℤ} (H1 : a ≠ 0) (H2 : a * b = c) : b = c / a :=
  Eq.symm <| Int.ediv_eq_of_eq_mul_right H1 H2.symm
#align int.eq_div_of_mul_eq_right Int.eq_ediv_of_mul_eq_right
-/

#print Int.ediv_eq_iff_eq_mul_right /-
protected theorem ediv_eq_iff_eq_mul_right {a b c : ℤ} (H : b ≠ 0) (H' : b ∣ a) :
    a / b = c ↔ a = b * c :=
  ⟨Int.eq_mul_of_ediv_eq_right H', Int.ediv_eq_of_eq_mul_right H⟩
#align int.div_eq_iff_eq_mul_right Int.ediv_eq_iff_eq_mul_right
-/

#print Int.ediv_eq_iff_eq_mul_left /-
protected theorem ediv_eq_iff_eq_mul_left {a b c : ℤ} (H : b ≠ 0) (H' : b ∣ a) :
    a / b = c ↔ a = c * b := by rw [mul_comm] <;> exact Int.ediv_eq_iff_eq_mul_right H H'
#align int.div_eq_iff_eq_mul_left Int.ediv_eq_iff_eq_mul_left
-/

#print Int.eq_mul_of_ediv_eq_left /-
protected theorem eq_mul_of_ediv_eq_left {a b c : ℤ} (H1 : b ∣ a) (H2 : a / b = c) : a = c * b := by
  rw [mul_comm, Int.eq_mul_of_ediv_eq_right H1 H2]
#align int.eq_mul_of_div_eq_left Int.eq_mul_of_ediv_eq_left
-/

#print Int.ediv_eq_of_eq_mul_left /-
protected theorem ediv_eq_of_eq_mul_left {a b c : ℤ} (H1 : b ≠ 0) (H2 : a = c * b) : a / b = c :=
  Int.ediv_eq_of_eq_mul_right H1 (by rw [mul_comm, H2])
#align int.div_eq_of_eq_mul_left Int.ediv_eq_of_eq_mul_left
-/

#print Int.eq_zero_of_ediv_eq_zero /-
protected theorem eq_zero_of_ediv_eq_zero {d n : ℤ} (h : d ∣ n) (H : n / d = 0) : n = 0 := by
  rw [← Int.mul_ediv_cancel' h, H, MulZeroClass.mul_zero]
#align int.eq_zero_of_div_eq_zero Int.eq_zero_of_ediv_eq_zero
-/

#print Int.ediv_left_inj /-
@[simp]
protected theorem ediv_left_inj {a b d : ℤ} (hda : d ∣ a) (hdb : d ∣ b) : a / d = b / d ↔ a = b :=
  by
  refine' ⟨fun h => _, congr_arg _⟩
  rw [← Int.mul_ediv_cancel' hda, ← Int.mul_ediv_cancel' hdb, h]
#align int.div_left_inj Int.ediv_left_inj
-/

#print Int.abs_sign_of_nonzero /-
theorem abs_sign_of_nonzero {z : ℤ} (hz : z ≠ 0) : |z.sign| = 1 := by
  rw [abs_eq_nat_abs, nat_abs_sign_of_nonzero hz, Int.ofNat_one]
#align int.abs_sign_of_nonzero Int.abs_sign_of_nonzero
-/

#print Int.exists_lt_and_lt_iff_not_dvd /-
/-- If `n > 0` then `m` is not divisible by `n` iff it is between `n * k` and `n * (k + 1)`
  for some `k`. -/
theorem exists_lt_and_lt_iff_not_dvd (m : ℤ) {n : ℤ} (hn : 0 < n) :
    (∃ k, n * k < m ∧ m < n * (k + 1)) ↔ ¬n ∣ m :=
  by
  constructor
  · rintro ⟨k, h1k, h2k⟩ ⟨l, rfl⟩; rw [mul_lt_mul_left hn] at h1k h2k 
    rw [lt_add_one_iff, ← not_lt] at h2k ; exact h2k h1k
  · intro h; rw [dvd_iff_mod_eq_zero, ← Ne.def] at h 
    have := (mod_nonneg m hn.ne.symm).lt_of_ne h.symm
    simp (config := { singlePass := true }) only [← mod_add_div m n]
    refine' ⟨m / n, lt_add_of_pos_left _ this, _⟩
    rw [add_comm _ (1 : ℤ), left_distrib, mul_one]; exact add_lt_add_right (mod_lt_of_pos _ hn) _
#align int.exists_lt_and_lt_iff_not_dvd Int.exists_lt_and_lt_iff_not_dvd
-/

attribute [local simp] Int.div_zero

#print Int.mul_ediv_assoc /-
protected theorem mul_ediv_assoc (a : ℤ) : ∀ {b c : ℤ}, c ∣ b → a * b / c = a * (b / c)
  | _, c, ⟨d, rfl⟩ =>
    if cz : c = 0 then by simp [cz]
    else by rw [mul_left_comm, Int.mul_ediv_cancel_left _ cz, Int.mul_ediv_cancel_left _ cz]
#align int.mul_div_assoc Int.mul_ediv_assoc
-/

#print Int.mul_ediv_assoc' /-
protected theorem mul_ediv_assoc' (b : ℤ) {a c : ℤ} (h : c ∣ a) : a * b / c = a / c * b := by
  rw [mul_comm, Int.mul_ediv_assoc _ h, mul_comm]
#align int.mul_div_assoc' Int.mul_ediv_assoc'
-/

#print Int.neg_ediv_of_dvd /-
theorem neg_ediv_of_dvd : ∀ {a b : ℤ} (H : b ∣ a), -a / b = -(a / b)
  | _, b, ⟨c, rfl⟩ =>
    if bz : b = 0 then by simp [bz]
    else by rw [neg_mul_eq_mul_neg, Int.mul_ediv_cancel_left _ bz, Int.mul_ediv_cancel_left _ bz]
#align int.neg_div_of_dvd Int.neg_ediv_of_dvd
-/

#print Int.sub_ediv_of_dvd /-
theorem sub_ediv_of_dvd (a : ℤ) {b c : ℤ} (hcb : c ∣ b) : (a - b) / c = a / c - b / c :=
  by
  rw [sub_eq_add_neg, sub_eq_add_neg, Int.add_ediv_of_dvd_right hcb.neg_right]
  congr
  exact neg_div_of_dvd hcb
#align int.sub_div_of_dvd Int.sub_ediv_of_dvd
-/

#print Int.sub_ediv_of_dvd_sub /-
theorem sub_ediv_of_dvd_sub {a b c : ℤ} (hcab : c ∣ a - b) : (a - b) / c = a / c - b / c := by
  rw [eq_sub_iff_add_eq, ← Int.add_ediv_of_dvd_left hcab, sub_add_cancel]
#align int.sub_div_of_dvd_sub Int.sub_ediv_of_dvd_sub
-/

#print Int.sign_eq_ediv_abs /-
protected theorem sign_eq_ediv_abs (a : ℤ) : sign a = a / |a| :=
  if az : a = 0 then by simp [az]
  else (Int.ediv_eq_of_eq_mul_left (mt abs_eq_zero.1 az) (sign_mul_abs _).symm).symm
#align int.sign_eq_div_abs Int.sign_eq_ediv_abs
-/

/-! ### `/` and ordering -/


#print Int.ediv_mul_le /-
protected theorem ediv_mul_le (a : ℤ) {b : ℤ} (H : b ≠ 0) : a / b * b ≤ a :=
  le_of_sub_nonneg <| by rw [mul_comm, ← mod_def] <;> apply mod_nonneg _ H
#align int.div_mul_le Int.ediv_mul_le
-/

#print Int.ediv_le_of_le_mul /-
protected theorem ediv_le_of_le_mul {a b c : ℤ} (H : 0 < c) (H' : a ≤ b * c) : a / c ≤ b :=
  le_of_mul_le_mul_right (le_trans (Int.ediv_mul_le _ (ne_of_gt H)) H') H
#align int.div_le_of_le_mul Int.ediv_le_of_le_mul
-/

#print Int.mul_lt_of_lt_ediv /-
protected theorem mul_lt_of_lt_ediv {a b c : ℤ} (H : 0 < c) (H3 : a < b / c) : a * c < b :=
  lt_of_not_ge <| mt (Int.ediv_le_of_le_mul H) (not_le_of_gt H3)
#align int.mul_lt_of_lt_div Int.mul_lt_of_lt_ediv
-/

#print Int.mul_le_of_le_ediv /-
protected theorem mul_le_of_le_ediv {a b c : ℤ} (H1 : 0 < c) (H2 : a ≤ b / c) : a * c ≤ b :=
  le_trans (mul_le_mul_of_nonneg_right H2 (le_of_lt H1)) (Int.ediv_mul_le _ (ne_of_gt H1))
#align int.mul_le_of_le_div Int.mul_le_of_le_ediv
-/

#print Int.le_ediv_of_mul_le /-
protected theorem le_ediv_of_mul_le {a b c : ℤ} (H1 : 0 < c) (H2 : a * c ≤ b) : a ≤ b / c :=
  le_of_lt_add_one <|
    lt_of_mul_lt_mul_right (lt_of_le_of_lt H2 (lt_ediv_add_one_mul_self _ H1)) (le_of_lt H1)
#align int.le_div_of_mul_le Int.le_ediv_of_mul_le
-/

#print Int.le_ediv_iff_mul_le /-
protected theorem le_ediv_iff_mul_le {a b c : ℤ} (H : 0 < c) : a ≤ b / c ↔ a * c ≤ b :=
  ⟨Int.mul_le_of_le_ediv H, Int.le_ediv_of_mul_le H⟩
#align int.le_div_iff_mul_le Int.le_ediv_iff_mul_le
-/

#print Int.ediv_le_ediv /-
protected theorem ediv_le_ediv {a b c : ℤ} (H : 0 < c) (H' : a ≤ b) : a / c ≤ b / c :=
  Int.le_ediv_of_mul_le H (le_trans (Int.ediv_mul_le _ (ne_of_gt H)) H')
#align int.div_le_div Int.ediv_le_ediv
-/

#print Int.ediv_lt_of_lt_mul /-
protected theorem ediv_lt_of_lt_mul {a b c : ℤ} (H : 0 < c) (H' : a < b * c) : a / c < b :=
  lt_of_not_ge <| mt (Int.mul_le_of_le_ediv H) (not_le_of_gt H')
#align int.div_lt_of_lt_mul Int.ediv_lt_of_lt_mul
-/

#print Int.lt_mul_of_ediv_lt /-
protected theorem lt_mul_of_ediv_lt {a b c : ℤ} (H1 : 0 < c) (H2 : a / c < b) : a < b * c :=
  lt_of_not_ge <| mt (Int.le_ediv_of_mul_le H1) (not_le_of_gt H2)
#align int.lt_mul_of_div_lt Int.lt_mul_of_ediv_lt
-/

#print Int.ediv_lt_iff_lt_mul /-
protected theorem ediv_lt_iff_lt_mul {a b c : ℤ} (H : 0 < c) : a / c < b ↔ a < b * c :=
  ⟨Int.lt_mul_of_ediv_lt H, Int.ediv_lt_of_lt_mul H⟩
#align int.div_lt_iff_lt_mul Int.ediv_lt_iff_lt_mul
-/

#print Int.le_mul_of_ediv_le /-
protected theorem le_mul_of_ediv_le {a b c : ℤ} (H1 : 0 ≤ b) (H2 : b ∣ a) (H3 : a / b ≤ c) :
    a ≤ c * b := by rw [← Int.ediv_mul_cancel H2] <;> exact mul_le_mul_of_nonneg_right H3 H1
#align int.le_mul_of_div_le Int.le_mul_of_ediv_le
-/

#print Int.lt_ediv_of_mul_lt /-
protected theorem lt_ediv_of_mul_lt {a b c : ℤ} (H1 : 0 ≤ b) (H2 : b ∣ c) (H3 : a * b < c) :
    a < c / b :=
  lt_of_not_ge <| mt (Int.le_mul_of_ediv_le H1 H2) (not_le_of_gt H3)
#align int.lt_div_of_mul_lt Int.lt_ediv_of_mul_lt
-/

#print Int.lt_ediv_iff_mul_lt /-
protected theorem lt_ediv_iff_mul_lt {a b : ℤ} (c : ℤ) (H : 0 < c) (H' : c ∣ b) :
    a < b / c ↔ a * c < b :=
  ⟨Int.mul_lt_of_lt_ediv H, Int.lt_ediv_of_mul_lt (le_of_lt H) H'⟩
#align int.lt_div_iff_mul_lt Int.lt_ediv_iff_mul_lt
-/

#print Int.ediv_pos_of_pos_of_dvd /-
theorem ediv_pos_of_pos_of_dvd {a b : ℤ} (H1 : 0 < a) (H2 : 0 ≤ b) (H3 : b ∣ a) : 0 < a / b :=
  Int.lt_ediv_of_mul_lt H2 H3 (by rwa [MulZeroClass.zero_mul])
#align int.div_pos_of_pos_of_dvd Int.ediv_pos_of_pos_of_dvd
-/

#print Int.natAbs_eq_of_dvd_dvd /-
theorem natAbs_eq_of_dvd_dvd {s t : ℤ} (hst : s ∣ t) (hts : t ∣ s) : natAbs s = natAbs t :=
  Nat.dvd_antisymm (natAbs_dvd_natAbs.mpr hst) (natAbs_dvd_natAbs.mpr hts)
#align int.nat_abs_eq_of_dvd_dvd Int.natAbs_eq_of_dvd_dvd
-/

#print Int.ediv_eq_ediv_of_mul_eq_mul /-
theorem ediv_eq_ediv_of_mul_eq_mul {a b c d : ℤ} (H2 : d ∣ c) (H3 : b ≠ 0) (H4 : d ≠ 0)
    (H5 : a * d = b * c) : a / b = c / d :=
  Int.ediv_eq_of_eq_mul_right H3 <| by
    rw [← Int.mul_ediv_assoc _ H2] <;> exact (Int.ediv_eq_of_eq_mul_left H4 H5.symm).symm
#align int.div_eq_div_of_mul_eq_mul Int.ediv_eq_ediv_of_mul_eq_mul
-/

#print Int.ediv_dvd_of_dvd /-
theorem ediv_dvd_of_dvd {s t : ℤ} (hst : s ∣ t) : t / s ∣ t :=
  by
  rcases eq_or_ne s 0 with (rfl | hs)
  · simpa using hst
  rcases hst with ⟨c, hc⟩
  simp [hc, Int.mul_ediv_cancel_left _ hs]
#align int.div_dvd_of_dvd Int.ediv_dvd_of_dvd
-/

/-! ### to_nat -/


#print Int.toNat_le /-
@[simp]
theorem toNat_le {a : ℤ} {n : ℕ} : toNat a ≤ n ↔ a ≤ n := by
  rw [(coe_nat_le_coe_nat_iff _ _).symm, to_nat_eq_max, max_le_iff] <;>
    exact and_iff_left (coe_zero_le _)
#align int.to_nat_le Int.toNat_le
-/

#print Int.lt_toNat /-
@[simp]
theorem lt_toNat {n : ℕ} {a : ℤ} : n < toNat a ↔ (n : ℤ) < a :=
  le_iff_le_iff_lt_iff_lt.1 toNat_le
#align int.lt_to_nat Int.lt_toNat
-/

#print Int.coe_nat_nonpos_iff /-
@[simp]
theorem coe_nat_nonpos_iff {n : ℕ} : (n : ℤ) ≤ 0 ↔ n = 0 :=
  ⟨fun h => le_antisymm (Int.ofNat_le.mp (h.trans Int.ofNat_zero.le)) n.zero_le, fun h =>
    (coe_nat_eq_zero.mpr h).le⟩
#align int.coe_nat_nonpos_iff Int.coe_nat_nonpos_iff
-/

#print Int.toNat_le_toNat /-
theorem toNat_le_toNat {a b : ℤ} (h : a ≤ b) : toNat a ≤ toNat b := by
  rw [to_nat_le] <;> exact le_trans h (le_to_nat b)
#align int.to_nat_le_to_nat Int.toNat_le_toNat
-/

#print Int.toNat_lt_toNat /-
theorem toNat_lt_toNat {a b : ℤ} (hb : 0 < b) : toNat a < toNat b ↔ a < b :=
  ⟨fun h => by cases a; exact lt_to_nat.1 h; exact lt_trans (neg_succ_of_nat_lt_zero a) hb, fun h =>
    by rw [lt_to_nat]; cases a; exact h; exact hb⟩
#align int.to_nat_lt_to_nat Int.toNat_lt_toNat
-/

#print Int.lt_of_toNat_lt /-
theorem lt_of_toNat_lt {a b : ℤ} (h : toNat a < toNat b) : a < b :=
  (toNat_lt_toNat <| lt_toNat.1 <| lt_of_le_of_lt (Nat.zero_le _) h).1 h
#align int.lt_of_to_nat_lt Int.lt_of_toNat_lt
-/

#print Int.toNat_pred_coe_of_pos /-
@[simp]
theorem toNat_pred_coe_of_pos {i : ℤ} (h : 0 < i) : ((i.toNat - 1 : ℕ) : ℤ) = i - 1 := by
  simp [h, le_of_lt h, push_cast]
#align int.to_nat_pred_coe_of_pos Int.toNat_pred_coe_of_pos
-/

#print Int.toNat_eq_zero /-
@[simp]
theorem toNat_eq_zero : ∀ {n : ℤ}, n.toNat = 0 ↔ n ≤ 0
  | (n : ℕ) =>
    calc
      _ ↔ n = 0 := ⟨(toNat_coe_nat n).symm.trans, (toNat_coe_nat n).trans⟩
      _ ↔ _ := coe_nat_nonpos_iff.symm
  | -[n+1] =>
    show (-((n : ℤ) + 1)).toNat = 0 ↔ (-(n + 1) : ℤ) ≤ 0 from
      calc
        _ ↔ True := ⟨fun _ => trivial, fun h => toNat_neg_nat _⟩
        _ ↔ _ := ⟨fun h => neg_nonpos_of_nonneg (ofNat_zero_le _), fun _ => trivial⟩
#align int.to_nat_eq_zero Int.toNat_eq_zero
-/

#print Int.toNat_sub_of_le /-
@[simp]
theorem toNat_sub_of_le {a b : ℤ} (h : b ≤ a) : (toNat (a - b) : ℤ) = a - b :=
  Int.toNat_of_nonneg (sub_nonneg_of_le h)
#align int.to_nat_sub_of_le Int.toNat_sub_of_le
-/

end Int

-- We should need only a minimal development of sets in order to get here.
assert_not_exists Set.range

