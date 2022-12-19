/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta

! This file was ported from Lean 3 source module data.int.cast.field
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Cast.Lemmas
import Mathbin.Algebra.Field.Defs
import Mathbin.Algebra.GroupWithZero.Units.Lemmas

/-!
# Cast of integers into fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/1016
> Any changes to this file require a corresponding PR to mathlib4.

This file concerns the canonical homomorphism `ℤ → F`, where `F` is a field.

## Main results

 * `int.cast_div`: if `n` divides `m`, then `↑(m / n) = ↑m / ↑n`
-/


namespace Int

open Nat

variable {α : Type _}

/-- Auxiliary lemma for norm_cast to move the cast `-↑n` upwards to `↑-↑n`.

(The restriction to `field` is necessary, otherwise this would also apply in the case where
`R = ℤ` and cause nontermination.)
-/
@[norm_cast]
theorem cast_neg_nat_cast {R} [Field R] (n : ℕ) : ((-n : ℤ) : R) = -n := by simp
#align int.cast_neg_nat_cast Int.cast_neg_nat_cast

@[simp]
theorem cast_div [Field α] {m n : ℤ} (n_dvd : n ∣ m) (n_nonzero : (n : α) ≠ 0) :
    ((m / n : ℤ) : α) = m / n := by 
  rcases n_dvd with ⟨k, rfl⟩
  have : n ≠ 0 := by 
    rintro rfl
    simpa using n_nonzero
  rw [Int.mul_ediv_cancel_left _ this, Int.cast_mul, mul_div_cancel_left _ n_nonzero]
#align int.cast_div Int.cast_div

end Int

