/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module data.nat.upto
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Nat.Order.Basic

/-!
# `nat.upto`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

`nat.upto p`, with `p` a predicate on `ℕ`, is a subtype of elements `n : ℕ` such that no value
(strictly) below `n` satisfies `p`.

This type has the property that `>` is well-founded when `∃ i, p i`, which allows us to implement
searches on `ℕ`, starting at `0` and with an unknown upper-bound.

It is similar to the well founded relation constructed to define `nat.find` with
the difference that, in `nat.upto p`, `p` does not need to be decidable. In fact,
`nat.find` could be slightly altered to factor decidability out of its
well founded relation and would then fulfill the same purpose as this file.
-/


namespace Nat

#print Nat.Upto /-
/-- The subtype of natural numbers `i` which have the property that
no `j` less than `i` satisfies `p`. This is an initial segment of the
natural numbers, up to and including the first value satisfying `p`.

We will be particularly interested in the case where there exists a value
satisfying `p`, because in this case the `>` relation is well-founded.  -/
@[reducible]
def Upto (p : ℕ → Prop) : Type :=
  { i : ℕ // ∀ j < i, ¬p j }
#align nat.upto Nat.Upto
-/

namespace Upto

variable {p : ℕ → Prop}

#print Nat.Upto.GT /-
/-- Lift the "greater than" relation on natural numbers to `nat.upto`. -/
protected def GT (p) (x y : Upto p) : Prop :=
  x.1 > y.1
#align nat.upto.gt Nat.Upto.GT
-/

instance : LT (Upto p) :=
  ⟨fun x y => x.1 < y.1⟩

#print Nat.Upto.wf /-
/-- The "greater than" relation on `upto p` is well founded if (and only if) there exists a value
satisfying `p`. -/
protected theorem wf : (∃ x, p x) → WellFounded (Upto.GT p)
  | ⟨x, h⟩ =>
    by
    suffices upto.gt p = Measure fun y : Nat.Upto p => x - y.val by rw [this]; apply measure_wf
    ext ⟨a, ha⟩ ⟨b, _⟩
    dsimp [Measure, InvImage, upto.gt]
    rw [tsub_lt_tsub_iff_left_of_le]
    exact le_of_not_lt fun h' => ha _ h' h
#align nat.upto.wf Nat.Upto.wf
-/

#print Nat.Upto.zero /-
/-- Zero is always a member of `nat.upto p` because it has no predecessors. -/
def zero : Nat.Upto p :=
  ⟨0, fun j h => False.elim (Nat.not_lt_zero _ h)⟩
#align nat.upto.zero Nat.Upto.zero
-/

#print Nat.Upto.succ /-
/-- The successor of `n` is in `nat.upto p` provided that `n` doesn't satisfy `p`. -/
def succ (x : Nat.Upto p) (h : ¬p x.val) : Nat.Upto p :=
  ⟨x.val.succ, fun j h' => by
    rcases Nat.lt_succ_iff_lt_or_eq.1 h' with (h' | rfl) <;> [exact x.2 _ h'; exact h]⟩
#align nat.upto.succ Nat.Upto.succ
-/

end Upto

end Nat

