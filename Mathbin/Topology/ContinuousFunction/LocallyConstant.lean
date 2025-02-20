/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module topology.continuous_function.locally_constant
! leanprover-community/mathlib commit 781cb2eed038c4caf53bdbd8d20a95e5822d77df
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.LocallyConstant.Algebra
import Mathbin.Topology.ContinuousFunction.Basic
import Mathbin.Topology.ContinuousFunction.Algebra

/-!
# The algebra morphism from locally constant functions to continuous functions.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


namespace LocallyConstant

variable {X Y : Type _} [TopologicalSpace X] [TopologicalSpace Y] (f : LocallyConstant X Y)

#print LocallyConstant.toContinuousMapMonoidHom /-
/-- The inclusion of locally-constant functions into continuous functions as a multiplicative
monoid hom. -/
@[to_additive
      "The inclusion of locally-constant functions into continuous functions as an\nadditive monoid hom.",
  simps]
def toContinuousMapMonoidHom [Monoid Y] [ContinuousMul Y] : LocallyConstant X Y →* C(X, Y)
    where
  toFun := coe
  map_one' := by ext; simp
  map_mul' x y := by ext; simp
#align locally_constant.to_continuous_map_monoid_hom LocallyConstant.toContinuousMapMonoidHom
#align locally_constant.to_continuous_map_add_monoid_hom LocallyConstant.toContinuousMapAddMonoidHom
-/

#print LocallyConstant.toContinuousMapLinearMap /-
/-- The inclusion of locally-constant functions into continuous functions as a linear map. -/
@[simps]
def toContinuousMapLinearMap (R : Type _) [Semiring R] [AddCommMonoid Y] [Module R Y]
    [ContinuousAdd Y] [ContinuousConstSMul R Y] : LocallyConstant X Y →ₗ[R] C(X, Y)
    where
  toFun := coe
  map_add' x y := by ext; simp
  map_smul' x y := by ext; simp
#align locally_constant.to_continuous_map_linear_map LocallyConstant.toContinuousMapLinearMap
-/

#print LocallyConstant.toContinuousMapAlgHom /-
/-- The inclusion of locally-constant functions into continuous functions as an algebra map. -/
@[simps]
def toContinuousMapAlgHom (R : Type _) [CommSemiring R] [Semiring Y] [Algebra R Y]
    [TopologicalSemiring Y] : LocallyConstant X Y →ₐ[R] C(X, Y)
    where
  toFun := coe
  map_one' := by ext; simp
  map_mul' x y := by ext; simp
  map_zero' := by ext; simp
  map_add' x y := by ext; simp
  commutes' r := by ext x; simp [Algebra.smul_def]
#align locally_constant.to_continuous_map_alg_hom LocallyConstant.toContinuousMapAlgHom
-/

end LocallyConstant

