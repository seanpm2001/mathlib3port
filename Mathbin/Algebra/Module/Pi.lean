/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Patrick Massot

! This file was ported from Lean 3 source module algebra.module.pi
! leanprover-community/mathlib commit be24ec5de6701447e5df5ca75400ffee19d65659
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Basic
import Mathbin.Algebra.Regular.Smul
import Mathbin.Algebra.Ring.Pi
import Mathbin.GroupTheory.GroupAction.Pi

/-!
# Pi instances for modules

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines instances for module and related structures on Pi Types
-/


universe u v w

variable {I : Type u}

-- The indexing type
variable {f : I → Type v}

-- The family of types already equipped with instances
variable (x y : ∀ i, f i) (i : I)

namespace Pi

#print IsSMulRegular.pi /-
theorem IsSMulRegular.pi {α : Type _} [∀ i, SMul α <| f i] {k : α}
    (hk : ∀ i, IsSMulRegular (f i) k) : IsSMulRegular (∀ i, f i) k := fun _ _ h =>
  funext fun i => hk i (congr_fun h i : _)
#align is_smul_regular.pi IsSMulRegular.pi
-/

#print Pi.smulWithZero /-
instance smulWithZero (α) [Zero α] [∀ i, Zero (f i)] [∀ i, SMulWithZero α (f i)] :
    SMulWithZero α (∀ i, f i) :=
  { Pi.instSMul with
    smul_zero := fun _ => funext fun _ => smul_zero _
    zero_smul := fun _ => funext fun _ => zero_smul _ _ }
#align pi.smul_with_zero Pi.smulWithZero
-/

#print Pi.smulWithZero' /-
instance smulWithZero' {g : I → Type _} [∀ i, Zero (g i)] [∀ i, Zero (f i)]
    [∀ i, SMulWithZero (g i) (f i)] : SMulWithZero (∀ i, g i) (∀ i, f i) :=
  { Pi.smul' with
    smul_zero := fun _ => funext fun _ => smul_zero _
    zero_smul := fun _ => funext fun _ => zero_smul _ _ }
#align pi.smul_with_zero' Pi.smulWithZero'
-/

#print Pi.mulActionWithZero /-
instance mulActionWithZero (α) [MonoidWithZero α] [∀ i, Zero (f i)]
    [∀ i, MulActionWithZero α (f i)] : MulActionWithZero α (∀ i, f i) :=
  { Pi.mulAction _, Pi.smulWithZero _ with }
#align pi.mul_action_with_zero Pi.mulActionWithZero
-/

#print Pi.mulActionWithZero' /-
instance mulActionWithZero' {g : I → Type _} [∀ i, MonoidWithZero (g i)] [∀ i, Zero (f i)]
    [∀ i, MulActionWithZero (g i) (f i)] : MulActionWithZero (∀ i, g i) (∀ i, f i) :=
  { Pi.mulAction', Pi.smulWithZero' with }
#align pi.mul_action_with_zero' Pi.mulActionWithZero'
-/

variable (I f)

#print Pi.module /-
instance module (α) {r : Semiring α} {m : ∀ i, AddCommMonoid <| f i} [∀ i, Module α <| f i] :
    @Module α (∀ i : I, f i) r (@Pi.addCommMonoid I f m) :=
  {
    Pi.distribMulAction
      _ with
    add_smul := fun c f g => funext fun i => add_smul _ _ _
    zero_smul := fun f => funext fun i => zero_smul α _ }
#align pi.module Pi.module
-/

#print Pi.Function.module /-
/- Extra instance to short-circuit type class resolution.
For unknown reasons, this is necessary for certain inference problems. E.g., for this to succeed:
```lean
example (β X : Type*) [normed_add_comm_group β] [normed_space ℝ β] : module ℝ (X → β) :=
infer_instance
```
See: https://leanprover.zulipchat.com/#narrow/stream/113488-general/topic/Typeclass.20resolution.20under.20binders/near/281296989
-/
/-- A special case of `pi.module` for non-dependent types. Lean struggles to elaborate
definitions elsewhere in the library without this. -/
instance Pi.Function.module (α β : Type _) [Semiring α] [AddCommMonoid β] [Module α β] :
    Module α (I → β) :=
  Pi.module _ _ _
#align function.module Pi.Function.module
-/

variable {I f}

#print Pi.module' /-
instance module' {g : I → Type _} {r : ∀ i, Semiring (f i)} {m : ∀ i, AddCommMonoid (g i)}
    [∀ i, Module (f i) (g i)] : Module (∀ i, f i) (∀ i, g i)
    where
  add_smul := by intros; ext1; apply add_smul
  zero_smul := by intros; ext1; apply zero_smul
#align pi.module' Pi.module'
-/

instance (α) {r : Semiring α} {m : ∀ i, AddCommMonoid <| f i} [∀ i, Module α <| f i]
    [∀ i, NoZeroSMulDivisors α <| f i] : NoZeroSMulDivisors α (∀ i : I, f i) :=
  ⟨fun c x h =>
    or_iff_not_imp_left.mpr fun hc =>
      funext fun i => (smul_eq_zero.mp (congr_fun h i)).resolve_left hc⟩

#print Function.noZeroSMulDivisors /-
/-- A special case of `pi.no_zero_smul_divisors` for non-dependent types. Lean struggles to
synthesize this instance by itself elsewhere in the library. -/
instance Function.noZeroSMulDivisors {ι α β : Type _} {r : Semiring α} {m : AddCommMonoid β}
    [Module α β] [NoZeroSMulDivisors α β] : NoZeroSMulDivisors α (ι → β) :=
  Pi.noZeroSMulDivisors _
#align function.no_zero_smul_divisors Function.noZeroSMulDivisors
-/

end Pi

