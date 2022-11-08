/-
Copyright (c) 2021 Eric Rodriguez. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Rodriguez
-/
import Mathbin.Logic.Basic

/-!
# `ne_zero` typeclass

We create a typeclass `ne_zero n` which carries around the fact that `(n : R) ≠ 0`.

## Main declarations

* `ne_zero`: `n ≠ 0` as a typeclass.

-/


/-- A type-class version of `n ≠ 0`.  -/
class NeZero {R} [Zero R] (n : R) : Prop where
  out : n ≠ 0

theorem NeZero.ne {R} [Zero R] (n : R) [h : NeZero n] : n ≠ 0 :=
  h.out

theorem ne_zero_iff {R : Type _} [Zero R] {n : R} : NeZero n ↔ n ≠ 0 :=
  ⟨fun h => h.out, NeZero.mk⟩

theorem not_ne_zero {R : Type _} [Zero R] {n : R} : ¬NeZero n ↔ n = 0 := by simp [ne_zero_iff]

theorem eq_zero_or_ne_zero {α} [Zero α] (a : α) : a = 0 ∨ NeZero a :=
  (eq_or_ne a 0).imp_right NeZero.mk

namespace NeZero

variable {R S M F : Type _} {r : R} {x y : M} {n p : ℕ}

--{a : ℕ+}
instance succ : NeZero (n + 1) :=
  ⟨n.succ_ne_zero⟩

theorem of_pos [Preorder M] [Zero M] (h : 0 < x) : NeZero x :=
  ⟨ne_of_gt h⟩

instance coe_trans [Zero M] [Coe R S] [CoeTC S M] [h : NeZero (r : M)] : NeZero ((r : S) : M) :=
  ⟨h.out⟩

theorem trans [Zero M] [Coe R S] [CoeTC S M] (h : NeZero ((r : S) : M)) : NeZero (r : M) :=
  ⟨h.out⟩

end NeZero

