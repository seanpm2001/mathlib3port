/-
Copyright (c) 2022 Kyle Miller. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kyle Miller

! This file was ported from Lean 3 source module data.finite.set
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Card

/-!
# Lemmas about `finite` and `set`s

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove two lemmas about `finite` and `set`s.

## Tags

finiteness, finite sets
-/


open Set

universe u v w x

variable {α : Type u} {β : Type v} {ι : Sort w}

#print Finite.Set.finite_of_finite_image /-
theorem Finite.Set.finite_of_finite_image (s : Set α) {f : α → β} (h : s.InjOn f)
    [Finite (f '' s)] : Finite s :=
  Finite.of_equiv _ (Equiv.ofBijective _ h.bijOn_image.Bijective).symm
#align finite.set.finite_of_finite_image Finite.Set.finite_of_finite_image
-/

#print Finite.of_injective_finite_range /-
theorem Finite.of_injective_finite_range {f : ι → α} (hf : Function.Injective f)
    [Finite (range f)] : Finite ι :=
  Finite.of_injective (Set.rangeFactorization f) (hf.codRestrict _)
#align finite.of_injective_finite_range Finite.of_injective_finite_range
-/

