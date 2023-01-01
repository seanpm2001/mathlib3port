/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module topology.continuous_function.locally_constant
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.LocallyConstant.Algebra
import Mathbin.Topology.ContinuousFunction.Basic
import Mathbin.Topology.ContinuousFunction.Algebra

/-!
# The algebra morphism from locally constant functions to continuous functions.

-/


namespace LocallyConstant

variable {X Y : Type _} [TopologicalSpace X] [TopologicalSpace Y] (f : LocallyConstant X Y)

/-- The inclusion of locally-constant functions into continuous functions as a multiplicative
monoid hom. -/
@[to_additive
      "The inclusion of locally-constant functions into continuous functions as an\nadditive monoid hom.",
  simps]
def toContinuousMapMonoidHom [Monoid Y] [HasContinuousMul Y] : LocallyConstant X Y →* C(X, Y)
    where
  toFun := coe
  map_one' := by
    ext
    simp
  map_mul' x y := by
    ext
    simp
#align locally_constant.to_continuous_map_monoid_hom LocallyConstant.toContinuousMapMonoidHom

/-- The inclusion of locally-constant functions into continuous functions as a linear map. -/
@[simps]
def toContinuousMapLinearMap (R : Type _) [Semiring R] [AddCommMonoid Y] [Module R Y]
    [HasContinuousAdd Y] [HasContinuousConstSmul R Y] : LocallyConstant X Y →ₗ[R] C(X, Y)
    where
  toFun := coe
  map_add' x y := by
    ext
    simp
  map_smul' x y := by
    ext
    simp
#align locally_constant.to_continuous_map_linear_map LocallyConstant.toContinuousMapLinearMap

/-- The inclusion of locally-constant functions into continuous functions as an algebra map. -/
@[simps]
def toContinuousMapAlgHom (R : Type _) [CommSemiring R] [Semiring Y] [Algebra R Y]
    [TopologicalSemiring Y] : LocallyConstant X Y →ₐ[R] C(X, Y)
    where
  toFun := coe
  map_one' := by
    ext
    simp
  map_mul' x y := by
    ext
    simp
  map_zero' := by
    ext
    simp
  map_add' x y := by
    ext
    simp
  commutes' r := by
    ext x
    simp [Algebra.smul_def]
#align locally_constant.to_continuous_map_alg_hom LocallyConstant.toContinuousMapAlgHom

end LocallyConstant

