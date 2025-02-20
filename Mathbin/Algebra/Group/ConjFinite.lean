/-
Copyright (c) 2022 Eric Rodriguez. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Rodriguez

! This file was ported from Lean 3 source module algebra.group.conj_finite
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Conj
import Mathbin.Data.Finite.Basic
import Mathbin.Data.Fintype.Units

/-!
# Conjugacy of elements of finite groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _} [Monoid α]

attribute [local instance 100] IsConj.setoid

instance [Fintype α] [DecidableRel (IsConj : α → α → Prop)] : Fintype (ConjClasses α) :=
  Quotient.fintype (IsConj.setoid α)

instance [Finite α] : Finite (ConjClasses α) :=
  Quotient.finite _

instance [DecidableEq α] [Fintype α] : DecidableRel (IsConj : α → α → Prop) := fun a b => by
  delta IsConj SemiconjBy; infer_instance

instance [Fintype α] [DecidableRel (IsConj : α → α → Prop)] {a : α} : Fintype (conjugatesOf a) :=
  @Subtype.fintype _ _ (‹DecidableRel IsConj› a) _

namespace ConjClasses

variable [Fintype α] [DecidableRel (IsConj : α → α → Prop)]

instance {x : ConjClasses α} : Fintype (carrier x) :=
  Quotient.recOnSubsingleton x fun a => conjugatesOf.fintype

end ConjClasses

