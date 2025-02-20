/-
Copyright (c) 2019 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module linear_algebra.general_linear_group
! leanprover-community/mathlib commit 4c19a16e4b705bf135cf9a80ac18fcc99c438514
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Equiv

/-!
# The general linear group of linear maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The general linear group is defined to be the group of invertible linear maps from `M` to itself.

See also `matrix.general_linear_group`

## Main definitions

* `linear_map.general_linear_group`

-/


variable (R M : Type _)

namespace LinearMap

variable [Semiring R] [AddCommMonoid M] [Module R M]

variable (R M)

#print LinearMap.GeneralLinearGroup /-
/-- The group of invertible linear maps from `M` to itself -/
@[reducible]
def GeneralLinearGroup :=
  (M →ₗ[R] M)ˣ
#align linear_map.general_linear_group LinearMap.GeneralLinearGroup
-/

namespace GeneralLinearGroup

variable {R M}

instance : CoeFun (GeneralLinearGroup R M) fun _ => M → M := by infer_instance

#print LinearMap.GeneralLinearGroup.toLinearEquiv /-
/-- An invertible linear map `f` determines an equivalence from `M` to itself. -/
def toLinearEquiv (f : GeneralLinearGroup R M) : M ≃ₗ[R] M :=
  { f.val with
    invFun := f.inv.toFun
    left_inv := fun m => show (f.inv * f.val) m = m by erw [f.inv_val] <;> simp
    right_inv := fun m => show (f.val * f.inv) m = m by erw [f.val_inv] <;> simp }
#align linear_map.general_linear_group.to_linear_equiv LinearMap.GeneralLinearGroup.toLinearEquiv
-/

#print LinearMap.GeneralLinearGroup.ofLinearEquiv /-
/-- An equivalence from `M` to itself determines an invertible linear map. -/
def ofLinearEquiv (f : M ≃ₗ[R] M) : GeneralLinearGroup R M
    where
  val := f
  inv := (f.symm : M →ₗ[R] M)
  val_inv := LinearMap.ext fun _ => f.apply_symm_apply _
  inv_val := LinearMap.ext fun _ => f.symm_apply_apply _
#align linear_map.general_linear_group.of_linear_equiv LinearMap.GeneralLinearGroup.ofLinearEquiv
-/

variable (R M)

#print LinearMap.GeneralLinearGroup.generalLinearEquiv /-
/-- The general linear group on `R` and `M` is multiplicatively equivalent to the type of linear
equivalences between `M` and itself. -/
def generalLinearEquiv : GeneralLinearGroup R M ≃* M ≃ₗ[R] M
    where
  toFun := toLinearEquiv
  invFun := ofLinearEquiv
  left_inv f := by ext; rfl
  right_inv f := by ext; rfl
  map_mul' x y := by ext; rfl
#align linear_map.general_linear_group.general_linear_equiv LinearMap.GeneralLinearGroup.generalLinearEquiv
-/

#print LinearMap.GeneralLinearGroup.generalLinearEquiv_to_linearMap /-
@[simp]
theorem generalLinearEquiv_to_linearMap (f : GeneralLinearGroup R M) :
    (generalLinearEquiv R M f : M →ₗ[R] M) = f := by ext; rfl
#align linear_map.general_linear_group.general_linear_equiv_to_linear_map LinearMap.GeneralLinearGroup.generalLinearEquiv_to_linearMap
-/

#print LinearMap.GeneralLinearGroup.coeFn_generalLinearEquiv /-
@[simp]
theorem coeFn_generalLinearEquiv (f : GeneralLinearGroup R M) :
    ⇑(generalLinearEquiv R M f) = (f : M → M) :=
  rfl
#align linear_map.general_linear_group.coe_fn_general_linear_equiv LinearMap.GeneralLinearGroup.coeFn_generalLinearEquiv
-/

end GeneralLinearGroup

end LinearMap

