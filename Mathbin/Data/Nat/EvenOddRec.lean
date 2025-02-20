/-
Copyright (c) 2022 Stuart Presnell. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Stuart Presnell

! This file was ported from Lean 3 source module data.nat.even_odd_rec
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Basic

/-! # A recursion principle based on even and odd numbers. 

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.-/


namespace Nat

#print Nat.evenOddRec /-
/-- Recursion principle on even and odd numbers: if we have `P 0`, and for all `i : ℕ` we can
extend from `P i` to both `P (2 * i)` and `P (2 * i + 1)`, then we have `P n` for all `n : ℕ`.
This is nothing more than a wrapper around `nat.binary_rec`, to avoid having to switch to
dealing with `bit0` and `bit1`. -/
@[elab_as_elim]
def evenOddRec {P : ℕ → Sort _} (h0 : P 0) (h_even : ∀ (n) (ih : P n), P (2 * n))
    (h_odd : ∀ (n) (ih : P n), P (2 * n + 1)) (n : ℕ) : P n :=
  by
  refine' @binary_rec P h0 (fun b i hi => _) n
  cases b
  · simpa [bit, bit0_val i] using h_even i hi
  · simpa [bit, bit1_val i] using h_odd i hi
#align nat.even_odd_rec Nat.evenOddRec
-/

#print Nat.evenOddRec_zero /-
@[simp]
theorem evenOddRec_zero (P : ℕ → Sort _) (h0 : P 0) (h_even : ∀ i, P i → P (2 * i))
    (h_odd : ∀ i, P i → P (2 * i + 1)) : @evenOddRec _ h0 h_even h_odd 0 = h0 :=
  binaryRec_zero _ _
#align nat.even_odd_rec_zero Nat.evenOddRec_zero
-/

#print Nat.evenOddRec_even /-
@[simp]
theorem evenOddRec_even (n : ℕ) (P : ℕ → Sort _) (h0 : P 0) (h_even : ∀ i, P i → P (2 * i))
    (h_odd : ∀ i, P i → P (2 * i + 1)) (H : h_even 0 h0 = h0) :
    @evenOddRec _ h0 h_even h_odd (2 * n) = h_even n (evenOddRec h0 h_even h_odd n) :=
  by
  convert binary_rec_eq _ ff n
  · exact (bit0_eq_two_mul _).symm
  · exact (bit0_eq_two_mul _).symm
  · apply heq_of_cast_eq; rfl
  · exact H
#align nat.even_odd_rec_even Nat.evenOddRec_even
-/

#print Nat.evenOddRec_odd /-
@[simp]
theorem evenOddRec_odd (n : ℕ) (P : ℕ → Sort _) (h0 : P 0) (h_even : ∀ i, P i → P (2 * i))
    (h_odd : ∀ i, P i → P (2 * i + 1)) (H : h_even 0 h0 = h0) :
    @evenOddRec _ h0 h_even h_odd (2 * n + 1) = h_odd n (evenOddRec h0 h_even h_odd n) :=
  by
  convert binary_rec_eq _ tt n
  · exact (bit0_eq_two_mul _).symm
  · exact (bit0_eq_two_mul _).symm
  · apply heq_of_cast_eq; rfl
  · exact H
#align nat.even_odd_rec_odd Nat.evenOddRec_odd
-/

end Nat

