/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module linear_algebra.affine_space.midpoint_zero
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.CharP.Invertible
import Mathbin.LinearAlgebra.AffineSpace.Midpoint

/-!
# Midpoint of a segment for characteristic zero

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We collect lemmas that require that the underlying ring has characteristic zero.

## Tags

midpoint
-/


open AffineMap AffineEquiv

#print lineMap_inv_two /-
theorem lineMap_inv_two {R : Type _} {V P : Type _} [DivisionRing R] [CharZero R] [AddCommGroup V]
    [Module R V] [AddTorsor V P] (a b : P) : lineMap a b (2⁻¹ : R) = midpoint R a b :=
  rfl
#align line_map_inv_two lineMap_inv_two
-/

#print lineMap_one_half /-
theorem lineMap_one_half {R : Type _} {V P : Type _} [DivisionRing R] [CharZero R] [AddCommGroup V]
    [Module R V] [AddTorsor V P] (a b : P) : lineMap a b (1 / 2 : R) = midpoint R a b := by
  rw [one_div, lineMap_inv_two]
#align line_map_one_half lineMap_one_half
-/

#print homothety_invOf_two /-
theorem homothety_invOf_two {R : Type _} {V P : Type _} [CommRing R] [Invertible (2 : R)]
    [AddCommGroup V] [Module R V] [AddTorsor V P] (a b : P) :
    homothety a (⅟ 2 : R) b = midpoint R a b :=
  rfl
#align homothety_inv_of_two homothety_invOf_two
-/

#print homothety_inv_two /-
theorem homothety_inv_two {k : Type _} {V P : Type _} [Field k] [CharZero k] [AddCommGroup V]
    [Module k V] [AddTorsor V P] (a b : P) : homothety a (2⁻¹ : k) b = midpoint k a b :=
  rfl
#align homothety_inv_two homothety_inv_two
-/

#print homothety_one_half /-
theorem homothety_one_half {k : Type _} {V P : Type _} [Field k] [CharZero k] [AddCommGroup V]
    [Module k V] [AddTorsor V P] (a b : P) : homothety a (1 / 2 : k) b = midpoint k a b := by
  rw [one_div, homothety_inv_two]
#align homothety_one_half homothety_one_half
-/

#print pi_midpoint_apply /-
@[simp]
theorem pi_midpoint_apply {k ι : Type _} {V : ∀ i : ι, Type _} {P : ∀ i : ι, Type _} [Field k]
    [Invertible (2 : k)] [∀ i, AddCommGroup (V i)] [∀ i, Module k (V i)]
    [∀ i, AddTorsor (V i) (P i)] (f g : ∀ i, P i) (i : ι) :
    midpoint k f g i = midpoint k (f i) (g i) :=
  rfl
#align pi_midpoint_apply pi_midpoint_apply
-/

