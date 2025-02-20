/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module data.ulift
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Equiv.Basic

/-!
# Extra lemmas about `ulift` and `plift`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we provide `subsingleton`, `unique`, `decidable_eq`, and `is_empty` instances for
`ulift α` and `plift α`. We also prove `ulift.forall`, `ulift.exists`, `plift.forall`, and
`plift.exists`.
-/


universe u v

open Function

namespace PLift

variable {α : Sort u} {β : Sort v}

instance [Subsingleton α] : Subsingleton (PLift α) :=
  Equiv.plift.Subsingleton

instance [Nonempty α] : Nonempty (PLift α) :=
  Equiv.plift.Nonempty

instance [Unique α] : Unique (PLift α) :=
  Equiv.plift.unique

instance [DecidableEq α] : DecidableEq (PLift α) :=
  Equiv.plift.DecidableEq

instance [IsEmpty α] : IsEmpty (PLift α) :=
  Equiv.plift.isEmpty

#print PLift.up_injective /-
theorem up_injective : Injective (@up α) :=
  Equiv.plift.symm.Injective
#align plift.up_injective PLift.up_injective
-/

#print PLift.up_surjective /-
theorem up_surjective : Surjective (@up α) :=
  Equiv.plift.symm.Surjective
#align plift.up_surjective PLift.up_surjective
-/

#print PLift.up_bijective /-
theorem up_bijective : Bijective (@up α) :=
  Equiv.plift.symm.Bijective
#align plift.up_bijective PLift.up_bijective
-/

#print PLift.up_inj /-
@[simp]
theorem up_inj {x y : α} : up x = up y ↔ x = y :=
  up_injective.eq_iff
#align plift.up_inj PLift.up_inj
-/

#print PLift.down_surjective /-
theorem down_surjective : Surjective (@down α) :=
  Equiv.plift.Surjective
#align plift.down_surjective PLift.down_surjective
-/

#print PLift.down_bijective /-
theorem down_bijective : Bijective (@down α) :=
  Equiv.plift.Bijective
#align plift.down_bijective PLift.down_bijective
-/

#print PLift.forall /-
@[simp]
theorem forall {p : PLift α → Prop} : (∀ x, p x) ↔ ∀ x : α, p (PLift.up x) :=
  up_surjective.forall
#align plift.forall PLift.forall
-/

#print PLift.exists /-
@[simp]
theorem exists {p : PLift α → Prop} : (∃ x, p x) ↔ ∃ x : α, p (PLift.up x) :=
  up_surjective.exists
#align plift.exists PLift.exists
-/

end PLift

namespace ULift

variable {α : Type u} {β : Type v}

instance [Subsingleton α] : Subsingleton (ULift α) :=
  Equiv.ulift.Subsingleton

instance [Nonempty α] : Nonempty (ULift α) :=
  Equiv.ulift.Nonempty

instance [Unique α] : Unique (ULift α) :=
  Equiv.ulift.unique

instance [DecidableEq α] : DecidableEq (ULift α) :=
  Equiv.ulift.DecidableEq

instance [IsEmpty α] : IsEmpty (ULift α) :=
  Equiv.ulift.isEmpty

#print ULift.up_injective /-
theorem up_injective : Injective (@up α) :=
  Equiv.ulift.symm.Injective
#align ulift.up_injective ULift.up_injective
-/

#print ULift.up_surjective /-
theorem up_surjective : Surjective (@up α) :=
  Equiv.ulift.symm.Surjective
#align ulift.up_surjective ULift.up_surjective
-/

#print ULift.up_bijective /-
theorem up_bijective : Bijective (@up α) :=
  Equiv.ulift.symm.Bijective
#align ulift.up_bijective ULift.up_bijective
-/

#print ULift.up_inj /-
@[simp]
theorem up_inj {x y : α} : up x = up y ↔ x = y :=
  up_injective.eq_iff
#align ulift.up_inj ULift.up_inj
-/

#print ULift.down_surjective /-
theorem down_surjective : Surjective (@down α) :=
  Equiv.ulift.Surjective
#align ulift.down_surjective ULift.down_surjective
-/

#print ULift.down_bijective /-
theorem down_bijective : Bijective (@down α) :=
  Equiv.ulift.Bijective
#align ulift.down_bijective ULift.down_bijective
-/

#print ULift.forall /-
@[simp]
theorem forall {p : ULift α → Prop} : (∀ x, p x) ↔ ∀ x : α, p (ULift.up x) :=
  up_surjective.forall
#align ulift.forall ULift.forall
-/

#print ULift.exists /-
@[simp]
theorem exists {p : ULift α → Prop} : (∃ x, p x) ↔ ∃ x : α, p (ULift.up x) :=
  up_surjective.exists
#align ulift.exists ULift.exists
-/

end ULift

