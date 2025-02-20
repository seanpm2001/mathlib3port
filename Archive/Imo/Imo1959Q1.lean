/-
Copyright (c) 2020 Kevin Lacker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Lacker

! This file was ported from Lean 3 source module imo.imo1959_q1
! leanprover-community/mathlib commit 5f25c089cb34db4db112556f23c50d12da81b297
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Ring
import Mathbin.Data.Nat.Prime

/-!
# IMO 1959 Q1

Prove that the fraction `(21n+4)/(14n+3)` is irreducible for every natural number `n`.

Since Lean doesn't have a concept of "irreducible fractions" per se, we just formalize this
as saying the numerator and denominator are relatively prime.
-/


open Nat

namespace imo1959_q1

theorem calculation (n k : ℕ) (h1 : k ∣ 21 * n + 4) (h2 : k ∣ 14 * n + 3) : k ∣ 1 :=
  have h3 : k ∣ 2 * (21 * n + 4) := h1.mul_left 2
  have h4 : k ∣ 3 * (14 * n + 3) := h2.mul_left 3
  have h5 : 3 * (14 * n + 3) = 2 * (21 * n + 4) + 1 := by ring
  (Nat.dvd_add_right h3).mp (h5 ▸ h4)
#align imo1959_q1.calculation Imo1959Q1.calculation

end imo1959_q1

open imo1959_q1

theorem imo1959_q1 : ∀ n : ℕ, coprime (21 * n + 4) (14 * n + 3) := fun n =>
  coprime_of_dvd' fun k hp h1 h2 => calculation n k h1 h2
#align imo1959_q1 imo1959_q1

