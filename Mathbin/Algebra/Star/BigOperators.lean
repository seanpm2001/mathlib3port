/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.star.big_operators
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Basic
import Mathbin.Algebra.Star.Basic

/-! # Big-operators lemmas about `star` algebraic operations

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

These results are kept separate from `algebra.star.basic` to avoid it needing to import `finset`.
-/


variable {R : Type _}

open scoped BigOperators

#print star_prod /-
@[simp]
theorem star_prod [CommMonoid R] [StarSemigroup R] {α : Type _} (s : Finset α) (f : α → R) :
    star (∏ x in s, f x) = ∏ x in s, star (f x) :=
  map_prod (starMulAut : R ≃* R) _ _
#align star_prod star_prod
-/

#print star_sum /-
@[simp]
theorem star_sum [AddCommMonoid R] [StarAddMonoid R] {α : Type _} (s : Finset α) (f : α → R) :
    star (∑ x in s, f x) = ∑ x in s, star (f x) :=
  (starAddEquiv : R ≃+ R).map_sum _ _
#align star_sum star_sum
-/

