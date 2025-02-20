/-
Copyright (c) 2022 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module data.fun_like.fintype
! leanprover-community/mathlib commit 13a5329a8625701af92e9a96ffc90fa787fff24d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finite.Basic
import Mathbin.Data.Fintype.Basic
import Mathbin.Data.FunLike.Basic

/-!
# Finiteness of `fun_like` types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We show a type `F` with a `fun_like F α β` is finite if both `α` and `β` are finite.
This corresponds to the following two pairs of declarations:

 * `fun_like.fintype` is a definition stating all `fun_like`s are finite if their domain and
   codomain are.
 * `fun_like.finite` is a lemma stating all `fun_like`s are finite if their domain and
   codomain are.
 * `fun_like.fintype'` is a non-dependent version of `fun_like.fintype` and
 * `fun_like.finite` is a non-dependent version of `fun_like.finite`, because dependent instances
   are harder to infer.

You can use these to produce instances for specific `fun_like` types.
(Although there might be options for `fintype` instances with better definitional behaviour.)
They can't be instances themselves since they can cause loops.
-/


section Type

variable (F G : Type _) {α γ : Type _} {β : α → Type _} [FunLike F α β] [FunLike G α fun _ => γ]

#print FunLike.fintype /-
/-- All `fun_like`s are finite if their domain and codomain are.

This is not an instance because specific `fun_like` types might have a better-suited definition.

See also `fun_like.finite`.
-/
noncomputable def FunLike.fintype [DecidableEq α] [Fintype α] [∀ i, Fintype (β i)] : Fintype F :=
  Fintype.ofInjective _ FunLike.coe_injective
#align fun_like.fintype FunLike.fintype
-/

#print FunLike.fintype' /-
/-- All `fun_like`s are finite if their domain and codomain are.

Non-dependent version of `fun_like.fintype` that might be easier to infer.
This is not an instance because specific `fun_like` types might have a better-suited definition.
-/
noncomputable def FunLike.fintype' [DecidableEq α] [Fintype α] [Fintype γ] : Fintype G :=
  FunLike.fintype G
#align fun_like.fintype' FunLike.fintype'
-/

end Type

section Sort

variable (F G : Sort _) {α γ : Sort _} {β : α → Sort _} [FunLike F α β] [FunLike G α fun _ => γ]

#print FunLike.finite /-
/-- All `fun_like`s are finite if their domain and codomain are.

Can't be an instance because it can cause infinite loops.
-/
theorem FunLike.finite [Finite α] [∀ i, Finite (β i)] : Finite F :=
  Finite.of_injective _ FunLike.coe_injective
#align fun_like.finite FunLike.finite
-/

#print FunLike.finite' /-
/-- All `fun_like`s are finite if their domain and codomain are.

Non-dependent version of `fun_like.finite` that might be easier to infer.
Can't be an instance because it can cause infinite loops.
-/
theorem FunLike.finite' [Finite α] [Finite γ] : Finite G :=
  FunLike.finite G
#align fun_like.finite' FunLike.finite'
-/

end Sort

