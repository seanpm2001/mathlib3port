/-
Copyright (c) 2020 Patrick Stevens. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Stevens, Yury Kudryashov

! This file was ported from Lean 3 source module number_theory.primorial
! leanprover-community/mathlib commit 3e32bc908f617039c74c06ea9a897e30c30803c2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Associated
import Mathbin.Data.Nat.Choose.Sum
import Mathbin.Data.Nat.Choose.Dvd
import Mathbin.Data.Nat.Parity
import Mathbin.Data.Nat.Prime

/-!
# Primorial

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the primorial function (the product of primes less than or equal to some bound),
and proves that `primorial n ≤ 4 ^ n`.

## Notations

We use the local notation `n#` for the primorial of `n`: that is, the product of the primes less
than or equal to `n`.
-/


open Finset

open Nat

open scoped BigOperators Nat

#print primorial /-
/-- The primorial `n#` of `n` is the product of the primes less than or equal to `n`.
-/
def primorial (n : ℕ) : ℕ :=
  ∏ p in filter Nat.Prime (range (n + 1)), p
#align primorial primorial
-/

local notation x "#" => primorial x

#print primorial_pos /-
theorem primorial_pos (n : ℕ) : 0 < n# :=
  prod_pos fun p hp => (mem_filter.1 hp).2.Pos
#align primorial_pos primorial_pos
-/

#print primorial_succ /-
theorem primorial_succ {n : ℕ} (hn1 : n ≠ 1) (hn : Odd n) : (n + 1)# = n# :=
  by
  refine' prod_congr _ fun _ _ => rfl
  rw [range_succ, filter_insert, if_neg fun h => odd_iff_not_even.mp hn _]
  exact h.even_sub_one <| mt succ.inj hn1
#align primorial_succ primorial_succ
-/

#print primorial_add /-
theorem primorial_add (m n : ℕ) :
    (m + n)# = m# * ∏ p in filter Nat.Prime (Ico (m + 1) (m + n + 1)), p :=
  by
  rw [primorial, primorial, ← Ico_zero_eq_range, ← prod_union, ← filter_union, Ico_union_Ico_eq_Ico]
  exacts [zero_le _, add_le_add_right (Nat.le_add_right _ _) _,
    disjoint_filter_filter <| Ico_disjoint_Ico_consecutive _ _ _]
#align primorial_add primorial_add
-/

#print primorial_add_dvd /-
theorem primorial_add_dvd {m n : ℕ} (h : n ≤ m) : (m + n)# ∣ m# * choose (m + n) m :=
  calc
    (m + n)# = m# * ∏ p in filter Nat.Prime (Ico (m + 1) (m + n + 1)), p := primorial_add _ _
    _ ∣ m# * choose (m + n) m :=
      mul_dvd_mul_left _ <|
        prod_primes_dvd _ (fun k hk => (mem_filter.1 hk).2.Prime) fun p hp =>
          by
          rw [mem_filter, mem_Ico] at hp 
          exact
            hp.2.dvd_choose_add hp.1.1 (h.trans_lt (m.lt_succ_self.trans_le hp.1.1))
              (Nat.lt_succ_iff.1 hp.1.2)
#align primorial_add_dvd primorial_add_dvd
-/

#print primorial_add_le /-
theorem primorial_add_le {m n : ℕ} (h : n ≤ m) : (m + n)# ≤ m# * choose (m + n) m :=
  le_of_dvd (mul_pos (primorial_pos _) (choose_pos <| Nat.le_add_right _ _)) (primorial_add_dvd h)
#align primorial_add_le primorial_add_le
-/

#print primorial_le_4_pow /-
theorem primorial_le_4_pow (n : ℕ) : n# ≤ 4 ^ n :=
  by
  induction' n using Nat.strong_induction_on with n ihn
  cases n; · rfl
  rcases n.even_or_odd with (⟨m, rfl⟩ | ho)
  · rcases m.eq_zero_or_pos with (rfl | hm); · decide
    calc
      (m + m + 1)# = (m + 1 + m)# := by rw [add_right_comm]
      _ ≤ (m + 1)# * choose (m + 1 + m) (m + 1) := (primorial_add_le m.le_succ)
      _ = (m + 1)# * choose (2 * m + 1) m := by rw [choose_symm_add, two_mul, add_right_comm]
      _ ≤ 4 ^ (m + 1) * 4 ^ m :=
        (mul_le_mul' (ihn _ <| succ_lt_succ <| (lt_add_iff_pos_left _).2 hm)
          (choose_middle_le_pow _))
      _ ≤ 4 ^ (m + m + 1) := by rw [← pow_add, add_right_comm]
  · rcases Decidable.eq_or_ne n 1 with (rfl | hn)
    · decide
    ·
      calc
        (n + 1)# = n# := primorial_succ hn ho
        _ ≤ 4 ^ n := (ihn n n.lt_succ_self)
        _ ≤ 4 ^ (n + 1) := pow_le_pow_of_le_right four_pos n.le_succ
#align primorial_le_4_pow primorial_le_4_pow
-/

