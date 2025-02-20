/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module data.fintype.small
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Card
import Mathbin.Logic.Small.Basic

/-!
# All finite types are small.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

That is, any `α` with `[fintype α]` is equivalent to a type in any universe.

-/


universe w v

#print small_of_fintype /-
instance (priority := 100) small_of_fintype (α : Type v) [Fintype α] : Small.{w} α :=
  by
  rw [small_congr (Fintype.equivFin α)]
  infer_instance
#align small_of_fintype small_of_fintype
-/

