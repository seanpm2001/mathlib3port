/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module algebra.ring.add_aut
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.GroupAction.Group
import Mathbin.Algebra.Module.Basic

/-!
# Multiplication on the left/right as additive automorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `add_aut.mul_left` and `add_aut.mul_right`.

See also `add_monoid_hom.mul_left`, `add_monoid_hom.mul_right`, `add_monoid.End.mul_left`, and
`add_monoid.End.mul_right` for multiplication by `R` as an endomorphism instead of multiplication by
`Rˣ` as an automorphism.
-/


namespace AddAut

variable {R : Type _} [Semiring R]

#print AddAut.mulLeft /-
/-- Left multiplication by a unit of a semiring as an additive automorphism. -/
@[simps (config := { simpRhs := true })]
def mulLeft : Rˣ →* AddAut R :=
  DistribMulAction.toAddAut _ _
#align add_aut.mul_left AddAut.mulLeft
-/

#print AddAut.mulRight /-
/-- Right multiplication by a unit of a semiring as an additive automorphism. -/
def mulRight (u : Rˣ) : AddAut R :=
  DistribMulAction.toAddAut Rᵐᵒᵖˣ R (Units.opEquiv.symm <| MulOpposite.op u)
#align add_aut.mul_right AddAut.mulRight
-/

#print AddAut.mulRight_apply /-
@[simp]
theorem mulRight_apply (u : Rˣ) (x : R) : mulRight u x = x * u :=
  rfl
#align add_aut.mul_right_apply AddAut.mulRight_apply
-/

#print AddAut.mulRight_symm_apply /-
@[simp]
theorem mulRight_symm_apply (u : Rˣ) (x : R) : (mulRight u).symm x = x * ↑u⁻¹ :=
  rfl
#align add_aut.mul_right_symm_apply AddAut.mulRight_symm_apply
-/

end AddAut

