/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module group_theory.group_action.support
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Pointwise.Smul

/-!
# Support of an element under an action action

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given an action of a group `G` on a type `α`, we say that a set `s : set α` supports an element
`a : α` if, for all `g` that fix `s` pointwise, `g` fixes `a`.

This is crucial in Fourier-Motzkin constructions.
-/


open scoped Pointwise

variable {G H α β : Type _}

namespace MulAction

section SMul

variable (G) [SMul G α] [SMul G β]

#print MulAction.Supports /-
/-- A set `s` supports `b` if `g • b = b` whenever `g • a = a` for all `a ∈ s`. -/
@[to_additive "A set `s` supports `b` if `g +ᵥ b = b` whenever `g +ᵥ a = a` for all `a ∈ s`."]
def Supports (s : Set α) (b : β) :=
  ∀ g : G, (∀ ⦃a⦄, a ∈ s → g • a = a) → g • b = b
#align mul_action.supports MulAction.Supports
#align add_action.supports AddAction.Supports
-/

variable {s t : Set α} {a : α} {b : β}

#print MulAction.supports_of_mem /-
@[to_additive]
theorem supports_of_mem (ha : a ∈ s) : Supports G s a := fun g h => h ha
#align mul_action.supports_of_mem MulAction.supports_of_mem
#align add_action.supports_of_mem AddAction.supports_of_mem
-/

variable {G}

#print MulAction.Supports.mono /-
@[to_additive]
theorem Supports.mono (h : s ⊆ t) (hs : Supports G s b) : Supports G t b := fun g hg =>
  hs _ fun a ha => hg <| h ha
#align mul_action.supports.mono MulAction.Supports.mono
#align add_action.supports.mono AddAction.Supports.mono
-/

end SMul

variable [Group H] [SMul G α] [SMul G β] [MulAction H α] [SMul H β] [SMulCommClass G H β]
  [SMulCommClass G H α] {s t : Set α} {b : β}

#print MulAction.Supports.smul /-
-- TODO: This should work without `smul_comm_class`
@[to_additive]
theorem Supports.smul (g : H) (h : Supports G s b) : Supports G (g • s) (g • b) :=
  by
  rintro g' hg'
  rw [smul_comm, h]
  rintro a ha
  have := Set.ball_image_iff.1 hg' a ha
  rwa [smul_comm, smul_left_cancel_iff] at this 
#align mul_action.supports.smul MulAction.Supports.smul
#align add_action.supports.vadd AddAction.Supports.vadd
-/

end MulAction

