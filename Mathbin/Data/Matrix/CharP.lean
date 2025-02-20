/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module data.matrix.char_p
! leanprover-community/mathlib commit d64d67d000b974f0d86a2be7918cf800be6271c8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Matrix.Basic
import Mathbin.Algebra.CharP.Basic

/-!
# Matrices in prime characteristic

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


open Matrix

variable {n : Type _} [Fintype n] {R : Type _} [Ring R]

#print Matrix.charP /-
instance Matrix.charP [DecidableEq n] [Nonempty n] (p : ℕ) [CharP R p] : CharP (Matrix n n R) p :=
  ⟨by
    intro k
    rw [← CharP.cast_eq_zero_iff R p k, ← Nat.cast_zero, ← map_natCast <| scalar n]
    convert scalar_inj; · simp; · assumption⟩
#align matrix.char_p Matrix.charP
-/

