/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module order.rel_iso.group
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Defs
import Mathbin.Order.RelIso.Basic

/-!
# Relation isomorphisms form a group

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _} {r : α → α → Prop}

namespace RelIso

instance : Group (r ≃r r) where
  one := RelIso.refl r
  mul f₁ f₂ := f₂.trans f₁
  inv := RelIso.symm
  mul_assoc f₁ f₂ f₃ := rfl
  one_mul f := ext fun _ => rfl
  mul_one f := ext fun _ => rfl
  mul_left_inv f := ext f.symm_apply_apply

#print RelIso.coe_one /-
@[simp]
theorem coe_one : ⇑(1 : r ≃r r) = id :=
  rfl
#align rel_iso.coe_one RelIso.coe_one
-/

#print RelIso.coe_mul /-
@[simp]
theorem coe_mul (e₁ e₂ : r ≃r r) : ⇑(e₁ * e₂) = e₁ ∘ e₂ :=
  rfl
#align rel_iso.coe_mul RelIso.coe_mul
-/

#print RelIso.mul_apply /-
theorem mul_apply (e₁ e₂ : r ≃r r) (x : α) : (e₁ * e₂) x = e₁ (e₂ x) :=
  rfl
#align rel_iso.mul_apply RelIso.mul_apply
-/

#print RelIso.inv_apply_self /-
@[simp]
theorem inv_apply_self (e : r ≃r r) (x) : e⁻¹ (e x) = x :=
  e.symm_apply_apply x
#align rel_iso.inv_apply_self RelIso.inv_apply_self
-/

#print RelIso.apply_inv_self /-
@[simp]
theorem apply_inv_self (e : r ≃r r) (x) : e (e⁻¹ x) = x :=
  e.apply_symm_apply x
#align rel_iso.apply_inv_self RelIso.apply_inv_self
-/

end RelIso

