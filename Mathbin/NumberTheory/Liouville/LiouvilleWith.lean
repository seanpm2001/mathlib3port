/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module number_theory.liouville.liouville_with
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Pow.Asymptotics
import Mathbin.NumberTheory.Liouville.Basic
import Mathbin.Topology.Instances.Irrational

/-!
# Liouville numbers with a given exponent

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We say that a real number `x` is a Liouville number with exponent `p : ℝ` if there exists a real
number `C` such that for infinitely many denominators `n` there exists a numerator `m` such that
`x ≠ m / n` and `|x - m / n| < C / n ^ p`. A number is a Liouville number in the sense of
`liouville` if it is `liouville_with` any real exponent, see `forall_liouville_with_iff`.

* If `p ≤ 1`, then this condition is trivial.

* If `1 < p ≤ 2`, then this condition is equivalent to `irrational x`. The forward implication
  does not require `p ≤ 2` and is formalized as `liouville_with.irrational`; the other implication
  follows from approximations by continued fractions and is not formalized yet.

* If `p > 2`, then this is a non-trivial condition on irrational numbers. In particular,
  [Thue–Siegel–Roth theorem](https://en.wikipedia.org/wiki/Roth's_theorem) states that such numbers
  must be transcendental.

In this file we define the predicate `liouville_with` and prove some basic facts about this
predicate.

## Tags

Liouville number, irrational, irrationality exponent
-/


open Filter Metric Real Set

open scoped Filter Topology

#print LiouvilleWith /-
/-- We say that a real number `x` is a Liouville number with exponent `p : ℝ` if there exists a real
number `C` such that for infinitely many denominators `n` there exists a numerator `m` such that
`x ≠ m / n` and `|x - m / n| < C / n ^ p`.

A number is a Liouville number in the sense of `liouville` if it is `liouville_with` any real
exponent. -/
def LiouvilleWith (p x : ℝ) : Prop :=
  ∃ C, ∃ᶠ n : ℕ in atTop, ∃ m : ℤ, x ≠ m / n ∧ |x - m / n| < C / n ^ p
#align liouville_with LiouvilleWith
-/

#print liouvilleWith_one /-
/-- For `p = 1` (hence, for any `p ≤ 1`), the condition `liouville_with p x` is trivial. -/
theorem liouvilleWith_one (x : ℝ) : LiouvilleWith 1 x :=
  by
  use 2
  refine' ((eventually_gt_at_top 0).mono fun n hn => _).Frequently
  have hn' : (0 : ℝ) < n := by simpa
  have : x < ↑(⌊x * ↑n⌋ + 1) / ↑n := by rw [lt_div_iff hn', Int.cast_add, Int.cast_one];
    exact Int.lt_floor_add_one _
  refine' ⟨⌊x * n⌋ + 1, this.ne, _⟩
  rw [abs_sub_comm, abs_of_pos (sub_pos.2 this), rpow_one, sub_lt_iff_lt_add',
    add_div_eq_mul_add_div _ _ hn'.ne', div_lt_div_right hn']
  simpa [bit0, ← add_assoc] using (Int.floor_le (x * n)).trans_lt (lt_add_one _)
#align liouville_with_one liouvilleWith_one
-/

namespace LiouvilleWith

variable {p q x y : ℝ} {r : ℚ} {m : ℤ} {n : ℕ}

#print LiouvilleWith.exists_pos /-
/-- The constant `C` provided by the definition of `liouville_with` can be made positive.
We also add `1 ≤ n` to the list of assumptions about the denominator. While it is equivalent to
the original statement, the case `n = 0` breaks many arguments. -/
theorem exists_pos (h : LiouvilleWith p x) :
    ∃ (C : ℝ) (h₀ : 0 < C),
      ∃ᶠ n : ℕ in atTop, 1 ≤ n ∧ ∃ m : ℤ, x ≠ m / n ∧ |x - m / n| < C / n ^ p :=
  by
  rcases h with ⟨C, hC⟩
  refine' ⟨max C 1, zero_lt_one.trans_le <| le_max_right _ _, _⟩
  refine' ((eventually_ge_at_top 1).and_frequently hC).mono _
  rintro n ⟨hle, m, hne, hlt⟩
  refine' ⟨hle, m, hne, hlt.trans_le _⟩
  exact div_le_div_of_le (rpow_nonneg_of_nonneg n.cast_nonneg _) (le_max_left _ _)
#align liouville_with.exists_pos LiouvilleWith.exists_pos
-/

#print LiouvilleWith.mono /-
/-- If a number is Liouville with exponent `p`, then it is Liouville with any smaller exponent. -/
theorem mono (h : LiouvilleWith p x) (hle : q ≤ p) : LiouvilleWith q x :=
  by
  rcases h.exists_pos with ⟨C, hC₀, hC⟩
  refine' ⟨C, hC.mono _⟩; rintro n ⟨hn, m, hne, hlt⟩
  refine' ⟨m, hne, hlt.trans_le <| div_le_div_of_le_left hC₀.le _ _⟩
  exacts [rpow_pos_of_pos (Nat.cast_pos.2 hn) _,
    rpow_le_rpow_of_exponent_le (Nat.one_le_cast.2 hn) hle]
#align liouville_with.mono LiouvilleWith.mono
-/

#print LiouvilleWith.frequently_lt_rpow_neg /-
/-- If `x` satisfies Liouville condition with exponent `p` and `q < p`, then `x`
satisfies Liouville condition with exponent `q` and constant `1`. -/
theorem frequently_lt_rpow_neg (h : LiouvilleWith p x) (hlt : q < p) :
    ∃ᶠ n : ℕ in atTop, ∃ m : ℤ, x ≠ m / n ∧ |x - m / n| < n ^ (-q) :=
  by
  rcases h.exists_pos with ⟨C, hC₀, hC⟩
  have : ∀ᶠ n : ℕ in at_top, C < n ^ (p - q) := by
    simpa only [(· ∘ ·), neg_sub, one_div] using
      ((tendsto_rpow_atTop (sub_pos.2 hlt)).comp tendsto_nat_cast_atTop_atTop).Eventually
        (eventually_gt_at_top C)
  refine' (this.and_frequently hC).mono _
  rintro n ⟨hnC, hn, m, hne, hlt⟩
  replace hn : (0 : ℝ) < n := Nat.cast_pos.2 hn
  refine' ⟨m, hne, hlt.trans <| (div_lt_iff <| rpow_pos_of_pos hn _).2 _⟩
  rwa [mul_comm, ← rpow_add hn, ← sub_eq_add_neg]
#align liouville_with.frequently_lt_rpow_neg LiouvilleWith.frequently_lt_rpow_neg
-/

#print LiouvilleWith.mul_rat /-
/-- The product of a Liouville number and a nonzero rational number is again a Liouville number.  -/
theorem mul_rat (h : LiouvilleWith p x) (hr : r ≠ 0) : LiouvilleWith p (x * r) :=
  by
  rcases h.exists_pos with ⟨C, hC₀, hC⟩
  refine' ⟨r.denom ^ p * (|r| * C), (tendsto_id.nsmul_at_top r.pos).Frequently (hC.mono _)⟩
  rintro n ⟨hn, m, hne, hlt⟩
  have A : (↑(r.num * m) : ℝ) / ↑(r.denom • id n) = m / n * r := by
    simp [← div_mul_div_comm, ← r.cast_def, mul_comm]
  refine' ⟨r.num * m, _, _⟩
  · rw [A]; simp [hne, hr]
  · rw [A, ← sub_mul, abs_mul]
    simp only [smul_eq_mul, id.def, Nat.cast_mul]
    refine' (mul_lt_mul_of_pos_right hlt <| abs_pos.2 <| Rat.cast_ne_zero.2 hr).trans_le _
    rw [mul_rpow, mul_div_mul_left, mul_comm, mul_div_assoc]
    exacts [(rpow_pos_of_pos (Nat.cast_pos.2 r.pos) _).ne', Nat.cast_nonneg _, Nat.cast_nonneg _]
#align liouville_with.mul_rat LiouvilleWith.mul_rat
-/

#print LiouvilleWith.mul_rat_iff /-
/-- The product `x * r`, `r : ℚ`, `r ≠ 0`, is a Liouville number with exponent `p` if and only if
`x` satisfies the same condition. -/
theorem mul_rat_iff (hr : r ≠ 0) : LiouvilleWith p (x * r) ↔ LiouvilleWith p x :=
  ⟨fun h => by
    simpa only [mul_assoc, ← Rat.cast_mul, mul_inv_cancel hr, Rat.cast_one, mul_one] using
      h.mul_rat (inv_ne_zero hr),
    fun h => h.mul_rat hr⟩
#align liouville_with.mul_rat_iff LiouvilleWith.mul_rat_iff
-/

#print LiouvilleWith.rat_mul_iff /-
/-- The product `r * x`, `r : ℚ`, `r ≠ 0`, is a Liouville number with exponent `p` if and only if
`x` satisfies the same condition. -/
theorem rat_mul_iff (hr : r ≠ 0) : LiouvilleWith p (r * x) ↔ LiouvilleWith p x := by
  rw [mul_comm, mul_rat_iff hr]
#align liouville_with.rat_mul_iff LiouvilleWith.rat_mul_iff
-/

#print LiouvilleWith.rat_mul /-
theorem rat_mul (h : LiouvilleWith p x) (hr : r ≠ 0) : LiouvilleWith p (r * x) :=
  (rat_mul_iff hr).2 h
#align liouville_with.rat_mul LiouvilleWith.rat_mul
-/

#print LiouvilleWith.mul_int_iff /-
theorem mul_int_iff (hm : m ≠ 0) : LiouvilleWith p (x * m) ↔ LiouvilleWith p x := by
  rw [← Rat.cast_coe_int, mul_rat_iff (Int.cast_ne_zero.2 hm)]
#align liouville_with.mul_int_iff LiouvilleWith.mul_int_iff
-/

#print LiouvilleWith.mul_int /-
theorem mul_int (h : LiouvilleWith p x) (hm : m ≠ 0) : LiouvilleWith p (x * m) :=
  (mul_int_iff hm).2 h
#align liouville_with.mul_int LiouvilleWith.mul_int
-/

#print LiouvilleWith.int_mul_iff /-
theorem int_mul_iff (hm : m ≠ 0) : LiouvilleWith p (m * x) ↔ LiouvilleWith p x := by
  rw [mul_comm, mul_int_iff hm]
#align liouville_with.int_mul_iff LiouvilleWith.int_mul_iff
-/

#print LiouvilleWith.int_mul /-
theorem int_mul (h : LiouvilleWith p x) (hm : m ≠ 0) : LiouvilleWith p (m * x) :=
  (int_mul_iff hm).2 h
#align liouville_with.int_mul LiouvilleWith.int_mul
-/

#print LiouvilleWith.mul_nat_iff /-
theorem mul_nat_iff (hn : n ≠ 0) : LiouvilleWith p (x * n) ↔ LiouvilleWith p x := by
  rw [← Rat.cast_coe_nat, mul_rat_iff (Nat.cast_ne_zero.2 hn)]
#align liouville_with.mul_nat_iff LiouvilleWith.mul_nat_iff
-/

#print LiouvilleWith.mul_nat /-
theorem mul_nat (h : LiouvilleWith p x) (hn : n ≠ 0) : LiouvilleWith p (x * n) :=
  (mul_nat_iff hn).2 h
#align liouville_with.mul_nat LiouvilleWith.mul_nat
-/

#print LiouvilleWith.nat_mul_iff /-
theorem nat_mul_iff (hn : n ≠ 0) : LiouvilleWith p (n * x) ↔ LiouvilleWith p x := by
  rw [mul_comm, mul_nat_iff hn]
#align liouville_with.nat_mul_iff LiouvilleWith.nat_mul_iff
-/

#print LiouvilleWith.nat_mul /-
theorem nat_mul (h : LiouvilleWith p x) (hn : n ≠ 0) : LiouvilleWith p (n * x) := by rw [mul_comm];
  exact h.mul_nat hn
#align liouville_with.nat_mul LiouvilleWith.nat_mul
-/

#print LiouvilleWith.add_rat /-
theorem add_rat (h : LiouvilleWith p x) (r : ℚ) : LiouvilleWith p (x + r) :=
  by
  rcases h.exists_pos with ⟨C, hC₀, hC⟩
  refine' ⟨r.denom ^ p * C, (tendsto_id.nsmul_at_top r.pos).Frequently (hC.mono _)⟩
  rintro n ⟨hn, m, hne, hlt⟩
  have hr : (0 : ℝ) < r.denom := Nat.cast_pos.2 r.pos
  have hn' : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.2 (zero_lt_one.trans_le hn).ne'
  have : (↑(r.denom * m + r.num * n : ℤ) / ↑(r.denom • id n) : ℝ) = m / n + r := by
    simp [add_div, hr.ne', mul_div_mul_left, mul_div_mul_right, hn', ← Rat.cast_def]
  refine' ⟨r.denom * m + r.num * n, _⟩; rw [this, add_sub_add_right_eq_sub]
  refine' ⟨by simpa, hlt.trans_le (le_of_eq _)⟩
  have : (r.denom ^ p : ℝ) ≠ 0 := (rpow_pos_of_pos hr _).ne'
  simp [mul_rpow, Nat.cast_nonneg, mul_div_mul_left, this]
#align liouville_with.add_rat LiouvilleWith.add_rat
-/

#print LiouvilleWith.add_rat_iff /-
@[simp]
theorem add_rat_iff : LiouvilleWith p (x + r) ↔ LiouvilleWith p x :=
  ⟨fun h => by simpa using h.add_rat (-r), fun h => h.add_rat r⟩
#align liouville_with.add_rat_iff LiouvilleWith.add_rat_iff
-/

#print LiouvilleWith.rat_add_iff /-
@[simp]
theorem rat_add_iff : LiouvilleWith p (r + x) ↔ LiouvilleWith p x := by rw [add_comm, add_rat_iff]
#align liouville_with.rat_add_iff LiouvilleWith.rat_add_iff
-/

#print LiouvilleWith.rat_add /-
theorem rat_add (h : LiouvilleWith p x) (r : ℚ) : LiouvilleWith p (r + x) :=
  add_comm x r ▸ h.add_rat r
#align liouville_with.rat_add LiouvilleWith.rat_add
-/

#print LiouvilleWith.add_int_iff /-
@[simp]
theorem add_int_iff : LiouvilleWith p (x + m) ↔ LiouvilleWith p x := by
  rw [← Rat.cast_coe_int m, add_rat_iff]
#align liouville_with.add_int_iff LiouvilleWith.add_int_iff
-/

#print LiouvilleWith.int_add_iff /-
@[simp]
theorem int_add_iff : LiouvilleWith p (m + x) ↔ LiouvilleWith p x := by rw [add_comm, add_int_iff]
#align liouville_with.int_add_iff LiouvilleWith.int_add_iff
-/

#print LiouvilleWith.add_nat_iff /-
@[simp]
theorem add_nat_iff : LiouvilleWith p (x + n) ↔ LiouvilleWith p x := by
  rw [← Rat.cast_coe_nat n, add_rat_iff]
#align liouville_with.add_nat_iff LiouvilleWith.add_nat_iff
-/

#print LiouvilleWith.nat_add_iff /-
@[simp]
theorem nat_add_iff : LiouvilleWith p (n + x) ↔ LiouvilleWith p x := by rw [add_comm, add_nat_iff]
#align liouville_with.nat_add_iff LiouvilleWith.nat_add_iff
-/

#print LiouvilleWith.add_int /-
theorem add_int (h : LiouvilleWith p x) (m : ℤ) : LiouvilleWith p (x + m) :=
  add_int_iff.2 h
#align liouville_with.add_int LiouvilleWith.add_int
-/

#print LiouvilleWith.int_add /-
theorem int_add (h : LiouvilleWith p x) (m : ℤ) : LiouvilleWith p (m + x) :=
  int_add_iff.2 h
#align liouville_with.int_add LiouvilleWith.int_add
-/

#print LiouvilleWith.add_nat /-
theorem add_nat (h : LiouvilleWith p x) (n : ℕ) : LiouvilleWith p (x + n) :=
  h.add_int n
#align liouville_with.add_nat LiouvilleWith.add_nat
-/

#print LiouvilleWith.nat_add /-
theorem nat_add (h : LiouvilleWith p x) (n : ℕ) : LiouvilleWith p (n + x) :=
  h.int_add n
#align liouville_with.nat_add LiouvilleWith.nat_add
-/

#print LiouvilleWith.neg /-
protected theorem neg (h : LiouvilleWith p x) : LiouvilleWith p (-x) :=
  by
  rcases h with ⟨C, hC⟩
  refine' ⟨C, hC.mono _⟩
  rintro n ⟨m, hne, hlt⟩
  use -m; simp [neg_div, abs_sub_comm _ x, *]
#align liouville_with.neg LiouvilleWith.neg
-/

#print LiouvilleWith.neg_iff /-
@[simp]
theorem neg_iff : LiouvilleWith p (-x) ↔ LiouvilleWith p x :=
  ⟨fun h => neg_neg x ▸ h.neg, LiouvilleWith.neg⟩
#align liouville_with.neg_iff LiouvilleWith.neg_iff
-/

#print LiouvilleWith.sub_rat_iff /-
@[simp]
theorem sub_rat_iff : LiouvilleWith p (x - r) ↔ LiouvilleWith p x := by
  rw [sub_eq_add_neg, ← Rat.cast_neg, add_rat_iff]
#align liouville_with.sub_rat_iff LiouvilleWith.sub_rat_iff
-/

#print LiouvilleWith.sub_rat /-
theorem sub_rat (h : LiouvilleWith p x) (r : ℚ) : LiouvilleWith p (x - r) :=
  sub_rat_iff.2 h
#align liouville_with.sub_rat LiouvilleWith.sub_rat
-/

#print LiouvilleWith.sub_int_iff /-
@[simp]
theorem sub_int_iff : LiouvilleWith p (x - m) ↔ LiouvilleWith p x := by
  rw [← Rat.cast_coe_int, sub_rat_iff]
#align liouville_with.sub_int_iff LiouvilleWith.sub_int_iff
-/

#print LiouvilleWith.sub_int /-
theorem sub_int (h : LiouvilleWith p x) (m : ℤ) : LiouvilleWith p (x - m) :=
  sub_int_iff.2 h
#align liouville_with.sub_int LiouvilleWith.sub_int
-/

#print LiouvilleWith.sub_nat_iff /-
@[simp]
theorem sub_nat_iff : LiouvilleWith p (x - n) ↔ LiouvilleWith p x := by
  rw [← Rat.cast_coe_nat, sub_rat_iff]
#align liouville_with.sub_nat_iff LiouvilleWith.sub_nat_iff
-/

#print LiouvilleWith.sub_nat /-
theorem sub_nat (h : LiouvilleWith p x) (n : ℕ) : LiouvilleWith p (x - n) :=
  sub_nat_iff.2 h
#align liouville_with.sub_nat LiouvilleWith.sub_nat
-/

#print LiouvilleWith.rat_sub_iff /-
@[simp]
theorem rat_sub_iff : LiouvilleWith p (r - x) ↔ LiouvilleWith p x := by simp [sub_eq_add_neg]
#align liouville_with.rat_sub_iff LiouvilleWith.rat_sub_iff
-/

#print LiouvilleWith.rat_sub /-
theorem rat_sub (h : LiouvilleWith p x) (r : ℚ) : LiouvilleWith p (r - x) :=
  rat_sub_iff.2 h
#align liouville_with.rat_sub LiouvilleWith.rat_sub
-/

#print LiouvilleWith.int_sub_iff /-
@[simp]
theorem int_sub_iff : LiouvilleWith p (m - x) ↔ LiouvilleWith p x := by simp [sub_eq_add_neg]
#align liouville_with.int_sub_iff LiouvilleWith.int_sub_iff
-/

#print LiouvilleWith.int_sub /-
theorem int_sub (h : LiouvilleWith p x) (m : ℤ) : LiouvilleWith p (m - x) :=
  int_sub_iff.2 h
#align liouville_with.int_sub LiouvilleWith.int_sub
-/

#print LiouvilleWith.nat_sub_iff /-
@[simp]
theorem nat_sub_iff : LiouvilleWith p (n - x) ↔ LiouvilleWith p x := by simp [sub_eq_add_neg]
#align liouville_with.nat_sub_iff LiouvilleWith.nat_sub_iff
-/

#print LiouvilleWith.nat_sub /-
theorem nat_sub (h : LiouvilleWith p x) (n : ℕ) : LiouvilleWith p (n - x) :=
  nat_sub_iff.2 h
#align liouville_with.nat_sub LiouvilleWith.nat_sub
-/

#print LiouvilleWith.ne_cast_int /-
theorem ne_cast_int (h : LiouvilleWith p x) (hp : 1 < p) (m : ℤ) : x ≠ m :=
  by
  rintro rfl; rename' m => M
  rcases((eventually_gt_at_top 0).and_frequently (h.frequently_lt_rpow_neg hp)).exists with
    ⟨n : ℕ, hn : 0 < n, m : ℤ, hne : (M : ℝ) ≠ m / n, hlt : |(M - m / n : ℝ)| < n ^ (-1 : ℝ)⟩
  refine' hlt.not_le _
  have hn' : (0 : ℝ) < n := by simpa
  rw [rpow_neg_one, ← one_div, sub_div' _ _ _ hn'.ne', abs_div, Nat.abs_cast, div_le_div_right hn']
  norm_cast
  rw [← zero_add (1 : ℤ), Int.add_one_le_iff, abs_pos, sub_ne_zero]
  rw [Ne.def, eq_div_iff hn'.ne'] at hne 
  exact_mod_cast hne
#align liouville_with.ne_cast_int LiouvilleWith.ne_cast_int
-/

#print LiouvilleWith.irrational /-
/-- A number satisfying the Liouville condition with exponent `p > 1` is an irrational number. -/
protected theorem irrational (h : LiouvilleWith p x) (hp : 1 < p) : Irrational x :=
  by
  rintro ⟨r, rfl⟩
  rcases eq_or_ne r 0 with (rfl | h0)
  · refine' h.ne_cast_int hp 0 _; rw [Rat.cast_zero, Int.cast_zero]
  · refine' (h.mul_rat (inv_ne_zero h0)).ne_cast_int hp 1 _
    simp [Rat.cast_ne_zero.2 h0]
#align liouville_with.irrational LiouvilleWith.irrational
-/

end LiouvilleWith

namespace Liouville

variable {x : ℝ}

#print Liouville.frequently_exists_num /-
/-- If `x` is a Liouville number, then for any `n`, for infinitely many denominators `b` there
exists a numerator `a` such that `x ≠ a / b` and `|x - a / b| < 1 / b ^ n`. -/
theorem frequently_exists_num (hx : Liouville x) (n : ℕ) :
    ∃ᶠ b : ℕ in atTop, ∃ a : ℤ, x ≠ a / b ∧ |x - a / b| < 1 / b ^ n :=
  by
  refine' Classical.not_not.1 fun H => _
  simp only [Liouville, not_forall, not_exists, not_frequently, not_and, not_lt,
    eventually_at_top] at H 
  rcases H with ⟨N, hN⟩
  have : ∀ b > (1 : ℕ), ∀ᶠ m : ℕ in at_top, ∀ a : ℤ, (1 / b ^ m : ℝ) ≤ |x - a / b| :=
    by
    intro b hb
    replace hb : (1 : ℝ) < b := Nat.one_lt_cast.2 hb
    have H : tendsto (fun m => 1 / b ^ m : ℕ → ℝ) at_top (𝓝 0) :=
      by
      simp only [one_div]
      exact tendsto_inv_at_top_zero.comp (tendsto_pow_atTop_atTop_of_one_lt hb)
    refine' (H.eventually (hx.irrational.eventually_forall_le_dist_cast_div b)).mono _
    exact fun m hm a => hm a
  have : ∀ᶠ m : ℕ in at_top, ∀ b < N, 1 < b → ∀ a : ℤ, (1 / b ^ m : ℝ) ≤ |x - a / b| :=
    (finite_lt_nat N).eventually_all.2 fun b hb => eventually_imp_distrib_left.2 (this b)
  rcases(this.and (eventually_ge_at_top n)).exists with ⟨m, hm, hnm⟩
  rcases hx m with ⟨a, b, hb, hne, hlt⟩
  lift b to ℕ using zero_le_one.trans hb.le; norm_cast at hb ; push_cast at hne hlt 
  cases le_or_lt N b
  · refine' (hN b h a hne).not_lt (hlt.trans_le _)
    replace hb : (1 : ℝ) < b := Nat.one_lt_cast.2 hb
    have hb0 : (0 : ℝ) < b := zero_lt_one.trans hb
    exact one_div_le_one_div_of_le (pow_pos hb0 _) (pow_le_pow hb.le hnm)
  · exact (hm b h hb _).not_lt hlt
#align liouville.frequently_exists_num Liouville.frequently_exists_num
-/

#print Liouville.liouvilleWith /-
/-- A Liouville number is a Liouville number with any real exponent. -/
protected theorem liouvilleWith (hx : Liouville x) (p : ℝ) : LiouvilleWith p x :=
  by
  suffices : LiouvilleWith ⌈p⌉₊ x; exact this.mono (Nat.le_ceil p)
  refine' ⟨1, ((eventually_gt_at_top 1).and_frequently (hx.frequently_exists_num ⌈p⌉₊)).mono _⟩
  rintro b ⟨hb, a, hne, hlt⟩
  refine' ⟨a, hne, _⟩
  rwa [rpow_nat_cast]
#align liouville.liouville_with Liouville.liouvilleWith
-/

end Liouville

#print forall_liouvilleWith_iff /-
/-- A number satisfies the Liouville condition with any exponent if and only if it is a Liouville
number. -/
theorem forall_liouvilleWith_iff {x : ℝ} : (∀ p, LiouvilleWith p x) ↔ Liouville x :=
  by
  refine' ⟨fun H n => _, Liouville.liouvilleWith⟩
  rcases((eventually_gt_at_top 1).and_frequently
        ((H (n + 1)).frequently_lt_rpow_neg (lt_add_one n))).exists with
    ⟨b, hb, a, hne, hlt⟩
  exact ⟨a, b, by exact_mod_cast hb, hne, by simpa [rpow_neg] using hlt⟩
#align forall_liouville_with_iff forall_liouvilleWith_iff
-/

