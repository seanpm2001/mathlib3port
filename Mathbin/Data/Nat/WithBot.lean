/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module data.nat.with_bot
! leanprover-community/mathlib commit 12665d3612d46b1838ec1273d291c21a61fc1707
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Order.Basic
import Mathbin.Algebra.Order.Monoid.WithTop

/-!
# `with_bot ℕ`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Lemmas about the type of natural numbers with a bottom element adjoined.
-/


namespace Nat

namespace WithBot

#print Nat.WithBot.add_eq_zero_iff /-
theorem add_eq_zero_iff {n m : WithBot ℕ} : n + m = 0 ↔ n = 0 ∧ m = 0 :=
  by
  rcases n, m with ⟨_ | _, _ | _⟩
  any_goals tauto
  repeat' erw [WithBot.coe_eq_coe]
  exact add_eq_zero_iff
#align nat.with_bot.add_eq_zero_iff Nat.WithBot.add_eq_zero_iff
-/

#print Nat.WithBot.add_eq_one_iff /-
theorem add_eq_one_iff {n m : WithBot ℕ} : n + m = 1 ↔ n = 0 ∧ m = 1 ∨ n = 1 ∧ m = 0 :=
  by
  rcases n, m with ⟨_ | _, _ | _⟩
  any_goals tauto
  repeat' erw [WithBot.coe_eq_coe]
  exact add_eq_one_iff
#align nat.with_bot.add_eq_one_iff Nat.WithBot.add_eq_one_iff
-/

#print Nat.WithBot.add_eq_two_iff /-
theorem add_eq_two_iff {n m : WithBot ℕ} :
    n + m = 2 ↔ n = 0 ∧ m = 2 ∨ n = 1 ∧ m = 1 ∨ n = 2 ∧ m = 0 :=
  by
  rcases n, m with ⟨_ | _, _ | _⟩
  any_goals tauto
  repeat' erw [WithBot.coe_eq_coe]
  exact add_eq_two_iff
#align nat.with_bot.add_eq_two_iff Nat.WithBot.add_eq_two_iff
-/

#print Nat.WithBot.add_eq_three_iff /-
theorem add_eq_three_iff {n m : WithBot ℕ} :
    n + m = 3 ↔ n = 0 ∧ m = 3 ∨ n = 1 ∧ m = 2 ∨ n = 2 ∧ m = 1 ∨ n = 3 ∧ m = 0 :=
  by
  rcases n, m with ⟨_ | _, _ | _⟩
  any_goals tauto
  repeat' erw [WithBot.coe_eq_coe]
  exact add_eq_three_iff
#align nat.with_bot.add_eq_three_iff Nat.WithBot.add_eq_three_iff
-/

#print Nat.WithBot.coe_nonneg /-
theorem coe_nonneg {n : ℕ} : 0 ≤ (n : WithBot ℕ) := by rw [← WithBot.coe_zero, WithBot.coe_le_coe];
  exact Nat.zero_le _
#align nat.with_bot.coe_nonneg Nat.WithBot.coe_nonneg
-/

#print Nat.WithBot.lt_zero_iff /-
@[simp]
theorem lt_zero_iff (n : WithBot ℕ) : n < 0 ↔ n = ⊥ :=
  Option.casesOn n (by decide) fun n =>
    iff_of_false (by simp [WithBot.some_eq_coe, coe_nonneg]) fun h => Option.noConfusion h
#align nat.with_bot.lt_zero_iff Nat.WithBot.lt_zero_iff
-/

#print Nat.WithBot.one_le_iff_zero_lt /-
theorem one_le_iff_zero_lt {x : WithBot ℕ} : 1 ≤ x ↔ 0 < x :=
  by
  refine' ⟨fun h => lt_of_lt_of_le (with_bot.coe_lt_coe.mpr zero_lt_one) h, fun h => _⟩
  induction x using WithBot.recBotCoe
  · exact (not_lt_bot h).elim
  · exact with_bot.coe_le_coe.mpr (nat.succ_le_iff.mpr (with_bot.coe_lt_coe.mp h))
#align nat.with_bot.one_le_iff_zero_lt Nat.WithBot.one_le_iff_zero_lt
-/

#print Nat.WithBot.lt_one_iff_le_zero /-
theorem lt_one_iff_le_zero {x : WithBot ℕ} : x < 1 ↔ x ≤ 0 :=
  not_iff_not.mp (by simpa using one_le_iff_zero_lt)
#align nat.with_bot.lt_one_iff_le_zero Nat.WithBot.lt_one_iff_le_zero
-/

#print Nat.WithBot.add_one_le_of_lt /-
theorem add_one_le_of_lt {n m : WithBot ℕ} (h : n < m) : n + 1 ≤ m :=
  by
  cases n; · exact bot_le
  cases m; exacts [(not_lt_bot h).elim, WithBot.some_le_some.2 (WithBot.some_lt_some.1 h)]
#align nat.with_bot.add_one_le_of_lt Nat.WithBot.add_one_le_of_lt
-/

end WithBot

end Nat

