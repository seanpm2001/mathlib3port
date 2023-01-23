/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module algebra.group.opposite
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.InjSurj
import Mathbin.Algebra.Group.Commute
import Mathbin.Algebra.Hom.Equiv.Basic
import Mathbin.Algebra.Opposites
import Mathbin.Data.Int.Cast.Defs

/-!
# Group structures on the multiplicative and additive opposites

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


universe u v

variable (α : Type u)

namespace MulOpposite

/-!
### Additive structures on `αᵐᵒᵖ`
-/


instance [AddSemigroup α] : AddSemigroup αᵐᵒᵖ :=
  unop_injective.AddSemigroup _ fun x y => rfl

instance [AddLeftCancelSemigroup α] : AddLeftCancelSemigroup αᵐᵒᵖ :=
  unop_injective.AddLeftCancelSemigroup _ fun x y => rfl

instance [AddRightCancelSemigroup α] : AddRightCancelSemigroup αᵐᵒᵖ :=
  unop_injective.AddRightCancelSemigroup _ fun x y => rfl

instance [AddCommSemigroup α] : AddCommSemigroup αᵐᵒᵖ :=
  unop_injective.AddCommSemigroup _ fun x y => rfl

instance [AddZeroClass α] : AddZeroClass αᵐᵒᵖ :=
  unop_injective.AddZeroClass _ rfl fun x y => rfl

instance [AddMonoid α] : AddMonoid αᵐᵒᵖ :=
  unop_injective.AddMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

instance [AddMonoidWithOne α] : AddMonoidWithOne αᵐᵒᵖ :=
  { MulOpposite.addMonoid α,
    MulOpposite.hasOne α with
    natCast := fun n => op n
    nat_cast_zero := show op ((0 : ℕ) : α) = 0 by simp
    nat_cast_succ := show ∀ n, op ((n + 1 : ℕ) : α) = op (n : ℕ) + 1 by simp }

instance [AddCommMonoid α] : AddCommMonoid αᵐᵒᵖ :=
  unop_injective.AddCommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

instance [SubNegMonoid α] : SubNegMonoid αᵐᵒᵖ :=
  unop_injective.SubNegMonoid _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl

instance [AddGroup α] : AddGroup αᵐᵒᵖ :=
  unop_injective.AddGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    fun _ _ => rfl

instance [AddGroupWithOne α] : AddGroupWithOne αᵐᵒᵖ :=
  { MulOpposite.addMonoidWithOne α,
    MulOpposite.addGroup α with
    intCast := fun n => op n
    int_cast_of_nat := fun n => show op ((n : ℤ) : α) = op n by rw [Int.cast_ofNat]
    int_cast_neg_succ_of_nat := fun n =>
      show op _ = op (-unop (op ((n + 1 : ℕ) : α))) by erw [unop_op, Int.cast_negSucc] <;> rfl }

instance [AddCommGroup α] : AddCommGroup αᵐᵒᵖ :=
  unop_injective.AddCommGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl

/-!
### Multiplicative structures on `αᵐᵒᵖ`

We also generate additive structures on `αᵃᵒᵖ` using `to_additive`
-/


@[to_additive]
instance [Semigroup α] : Semigroup αᵐᵒᵖ :=
  { MulOpposite.hasMul α with
    mul_assoc := fun x y z => unop_injective <| Eq.symm <| mul_assoc (unop z) (unop y) (unop x) }

@[to_additive]
instance [RightCancelSemigroup α] : LeftCancelSemigroup αᵐᵒᵖ :=
  { MulOpposite.semigroup α with
    mul_left_cancel := fun x y z H => unop_injective <| mul_right_cancel <| op_injective H }

@[to_additive]
instance [LeftCancelSemigroup α] : RightCancelSemigroup αᵐᵒᵖ :=
  { MulOpposite.semigroup α with
    mul_right_cancel := fun x y z H => unop_injective <| mul_left_cancel <| op_injective H }

@[to_additive]
instance [CommSemigroup α] : CommSemigroup αᵐᵒᵖ :=
  { MulOpposite.semigroup α with
    mul_comm := fun x y => unop_injective <| mul_comm (unop y) (unop x) }

@[to_additive]
instance [MulOneClass α] : MulOneClass αᵐᵒᵖ :=
  { MulOpposite.hasMul α,
    MulOpposite.hasOne
      α with
    one_mul := fun x => unop_injective <| mul_one <| unop x
    mul_one := fun x => unop_injective <| one_mul <| unop x }

@[to_additive]
instance [Monoid α] : Monoid αᵐᵒᵖ :=
  { MulOpposite.semigroup α,
    MulOpposite.mulOneClass α with
    npow := fun n x => op <| x.unop ^ n
    npow_zero' := fun x => unop_injective <| Monoid.npow_zero x.unop
    npow_succ' := fun n x => unop_injective <| pow_succ' x.unop n }

@[to_additive]
instance [RightCancelMonoid α] : LeftCancelMonoid αᵐᵒᵖ :=
  { MulOpposite.leftCancelSemigroup α, MulOpposite.monoid α with }

@[to_additive]
instance [LeftCancelMonoid α] : RightCancelMonoid αᵐᵒᵖ :=
  { MulOpposite.rightCancelSemigroup α, MulOpposite.monoid α with }

@[to_additive]
instance [CancelMonoid α] : CancelMonoid αᵐᵒᵖ :=
  { MulOpposite.rightCancelMonoid α, MulOpposite.leftCancelMonoid α with }

@[to_additive]
instance [CommMonoid α] : CommMonoid αᵐᵒᵖ :=
  { MulOpposite.monoid α, MulOpposite.commSemigroup α with }

@[to_additive]
instance [CancelCommMonoid α] : CancelCommMonoid αᵐᵒᵖ :=
  { MulOpposite.cancelMonoid α, MulOpposite.commMonoid α with }

@[to_additive AddOpposite.subNegMonoid]
instance [DivInvMonoid α] : DivInvMonoid αᵐᵒᵖ :=
  { MulOpposite.monoid α,
    MulOpposite.hasInv α with
    zpow := fun n x => op <| x.unop ^ n
    zpow_zero' := fun x => unop_injective <| DivInvMonoid.zpow_zero' x.unop
    zpow_succ' := fun n x =>
      unop_injective <| by rw [unop_op, zpow_ofNat, zpow_ofNat, pow_succ', unop_mul, unop_op]
    zpow_neg' := fun z x => unop_injective <| DivInvMonoid.zpow_neg' z x.unop }

@[to_additive AddOpposite.subtractionMonoid]
instance [DivisionMonoid α] : DivisionMonoid αᵐᵒᵖ :=
  { MulOpposite.divInvMonoid α,
    MulOpposite.hasInvolutiveInv
      α with
    mul_inv_rev := fun a b => unop_injective <| mul_inv_rev _ _
    inv_eq_of_mul := fun a b h => unop_injective <| inv_eq_of_mul_eq_one_left <| congr_arg unop h }

@[to_additive AddOpposite.subtractionCommMonoid]
instance [DivisionCommMonoid α] : DivisionCommMonoid αᵐᵒᵖ :=
  { MulOpposite.divisionMonoid α, MulOpposite.commSemigroup α with }

@[to_additive]
instance [Group α] : Group αᵐᵒᵖ :=
  { MulOpposite.divInvMonoid α with
    mul_left_inv := fun x => unop_injective <| mul_inv_self <| unop x }

@[to_additive]
instance [CommGroup α] : CommGroup αᵐᵒᵖ :=
  { MulOpposite.group α, MulOpposite.commMonoid α with }

variable {α}

/- warning: mul_opposite.unop_div -> MulOpposite.unop_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : DivInvMonoid.{u1} α] (x : MulOpposite.{u1} α) (y : MulOpposite.{u1} α), Eq.{succ u1} α (MulOpposite.unop.{u1} α (HDiv.hDiv.{u1, u1, u1} (MulOpposite.{u1} α) (MulOpposite.{u1} α) (MulOpposite.{u1} α) (instHDiv.{u1} (MulOpposite.{u1} α) (DivInvMonoid.toHasDiv.{u1} (MulOpposite.{u1} α) (MulOpposite.divInvMonoid.{u1} α _inst_1))) x y)) (HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (MulOneClass.toHasMul.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α _inst_1)))) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α _inst_1) (MulOpposite.unop.{u1} α y)) (MulOpposite.unop.{u1} α x))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : DivInvMonoid.{u1} α] (x : MulOpposite.{u1} α) (y : MulOpposite.{u1} α), Eq.{succ u1} α (MulOpposite.unop.{u1} α (HDiv.hDiv.{u1, u1, u1} (MulOpposite.{u1} α) (MulOpposite.{u1} α) (MulOpposite.{u1} α) (instHDiv.{u1} (MulOpposite.{u1} α) (DivInvMonoid.toDiv.{u1} (MulOpposite.{u1} α) (MulOpposite.instDivInvMonoidMulOpposite.{u1} α _inst_1))) x y)) (HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (MulOneClass.toMul.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α _inst_1)))) (Inv.inv.{u1} α (DivInvMonoid.toInv.{u1} α _inst_1) (MulOpposite.unop.{u1} α y)) (MulOpposite.unop.{u1} α x))
Case conversion may be inaccurate. Consider using '#align mul_opposite.unop_div MulOpposite.unop_divₓ'. -/
@[simp, to_additive]
theorem unop_div [DivInvMonoid α] (x y : αᵐᵒᵖ) : unop (x / y) = (unop y)⁻¹ * unop x :=
  rfl
#align mul_opposite.unop_div MulOpposite.unop_div
#align add_opposite.unop_sub AddOpposite.unop_sub

/- warning: mul_opposite.op_div -> MulOpposite.op_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : DivInvMonoid.{u1} α] (x : α) (y : α), Eq.{succ u1} (MulOpposite.{u1} α) (MulOpposite.op.{u1} α (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α _inst_1)) x y)) (HMul.hMul.{u1, u1, u1} (MulOpposite.{u1} α) (MulOpposite.{u1} α) (MulOpposite.{u1} α) (instHMul.{u1} (MulOpposite.{u1} α) (MulOpposite.hasMul.{u1} α (MulOneClass.toHasMul.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α _inst_1))))) (Inv.inv.{u1} (MulOpposite.{u1} α) (MulOpposite.hasInv.{u1} α (DivInvMonoid.toHasInv.{u1} α _inst_1)) (MulOpposite.op.{u1} α y)) (MulOpposite.op.{u1} α x))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : DivInvMonoid.{u1} α] (x : α) (y : α), Eq.{succ u1} (MulOpposite.{u1} α) (MulOpposite.op.{u1} α (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toDiv.{u1} α _inst_1)) x y)) (HMul.hMul.{u1, u1, u1} (MulOpposite.{u1} α) (MulOpposite.{u1} α) (MulOpposite.{u1} α) (instHMul.{u1} (MulOpposite.{u1} α) (MulOpposite.instMulMulOpposite.{u1} α (MulOneClass.toMul.{u1} α (Monoid.toMulOneClass.{u1} α (DivInvMonoid.toMonoid.{u1} α _inst_1))))) (Inv.inv.{u1} (MulOpposite.{u1} α) (MulOpposite.instInvMulOpposite.{u1} α (DivInvMonoid.toInv.{u1} α _inst_1)) (MulOpposite.op.{u1} α y)) (MulOpposite.op.{u1} α x))
Case conversion may be inaccurate. Consider using '#align mul_opposite.op_div MulOpposite.op_divₓ'. -/
@[simp, to_additive]
theorem op_div [DivInvMonoid α] (x y : α) : op (x / y) = (op y)⁻¹ * op x := by simp [div_eq_mul_inv]
#align mul_opposite.op_div MulOpposite.op_div
#align add_opposite.op_sub AddOpposite.op_sub

#print MulOpposite.semiconjBy_op /-
@[simp, to_additive]
theorem semiconjBy_op [Mul α] {a x y : α} : SemiconjBy (op a) (op y) (op x) ↔ SemiconjBy a x y := by
  simp only [SemiconjBy, ← op_mul, op_inj, eq_comm]
#align mul_opposite.semiconj_by_op MulOpposite.semiconjBy_op
#align add_opposite.semiconj_by_op AddOpposite.semiconjBy_op
-/

#print MulOpposite.semiconjBy_unop /-
@[simp, to_additive]
theorem semiconjBy_unop [Mul α] {a x y : αᵐᵒᵖ} :
    SemiconjBy (unop a) (unop y) (unop x) ↔ SemiconjBy a x y := by
  conv_rhs => rw [← op_unop a, ← op_unop x, ← op_unop y, semiconj_by_op]
#align mul_opposite.semiconj_by_unop MulOpposite.semiconjBy_unop
#align add_opposite.semiconj_by_unop AddOpposite.semiconjBy_unop
-/

#print SemiconjBy.op /-
@[to_additive]
theorem SemiconjBy.op [Mul α] {a x y : α} (h : SemiconjBy a x y) :
    SemiconjBy (op a) (op y) (op x) :=
  semiconjBy_op.2 h
#align semiconj_by.op SemiconjBy.op
#align add_semiconj_by.op AddSemiconjBy.op
-/

#print SemiconjBy.unop /-
@[to_additive]
theorem SemiconjBy.unop [Mul α] {a x y : αᵐᵒᵖ} (h : SemiconjBy a x y) :
    SemiconjBy (unop a) (unop y) (unop x) :=
  semiconjBy_unop.2 h
#align semiconj_by.unop SemiconjBy.unop
#align add_semiconj_by.unop AddSemiconjBy.unop
-/

#print Commute.op /-
@[to_additive]
theorem Commute.op [Mul α] {x y : α} (h : Commute x y) : Commute (op x) (op y) :=
  h.op
#align commute.op Commute.op
#align add_commute.op AddCommute.op
-/

#print MulOpposite.Commute.unop /-
@[to_additive]
theorem Commute.unop [Mul α] {x y : αᵐᵒᵖ} (h : Commute x y) : Commute (unop x) (unop y) :=
  h.unop
#align mul_opposite.commute.unop MulOpposite.Commute.unop
#align add_opposite.commute.unop AddOpposite.Commute.unop
-/

#print MulOpposite.commute_op /-
@[simp, to_additive]
theorem commute_op [Mul α] {x y : α} : Commute (op x) (op y) ↔ Commute x y :=
  semiconj_by_op
#align mul_opposite.commute_op MulOpposite.commute_op
#align add_opposite.commute_op AddOpposite.commute_op
-/

#print MulOpposite.commute_unop /-
@[simp, to_additive]
theorem commute_unop [Mul α] {x y : αᵐᵒᵖ} : Commute (unop x) (unop y) ↔ Commute x y :=
  semiconj_by_unop
#align mul_opposite.commute_unop MulOpposite.commute_unop
#align add_opposite.commute_unop AddOpposite.commute_unop
-/

#print MulOpposite.opAddEquiv /-
/-- The function `mul_opposite.op` is an additive equivalence. -/
@[simps (config :=
      { fullyApplied := false
        simpRhs := true })]
def opAddEquiv [Add α] : α ≃+ αᵐᵒᵖ :=
  { opEquiv with map_add' := fun a b => rfl }
#align mul_opposite.op_add_equiv MulOpposite.opAddEquiv
-/

#print MulOpposite.opAddEquiv_toEquiv /-
@[simp]
theorem opAddEquiv_toEquiv [Add α] : (opAddEquiv : α ≃+ αᵐᵒᵖ).toEquiv = op_equiv :=
  rfl
#align mul_opposite.op_add_equiv_to_equiv MulOpposite.opAddEquiv_toEquiv
-/

end MulOpposite

/-!
### Multiplicative structures on `αᵃᵒᵖ`
-/


namespace AddOpposite

instance [Semigroup α] : Semigroup αᵃᵒᵖ :=
  unop_injective.Semigroup _ fun x y => rfl

instance [LeftCancelSemigroup α] : LeftCancelSemigroup αᵃᵒᵖ :=
  unop_injective.LeftCancelSemigroup _ fun x y => rfl

instance [RightCancelSemigroup α] : RightCancelSemigroup αᵃᵒᵖ :=
  unop_injective.RightCancelSemigroup _ fun x y => rfl

instance [CommSemigroup α] : CommSemigroup αᵃᵒᵖ :=
  unop_injective.CommSemigroup _ fun x y => rfl

instance [MulOneClass α] : MulOneClass αᵃᵒᵖ :=
  unop_injective.MulOneClass _ rfl fun x y => rfl

instance {β} [Pow α β] : Pow αᵃᵒᵖ β where pow a b := op (unop a ^ b)

/- warning: add_opposite.op_pow -> AddOpposite.op_pow is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u1}) {β : Type.{u2}} [_inst_1 : Pow.{u1, u2} α β] (a : α) (b : β), Eq.{succ u1} (AddOpposite.{u1} α) (AddOpposite.op.{u1} α (HPow.hPow.{u1, u2, u1} α β α (instHPow.{u1, u2} α β _inst_1) a b)) (HPow.hPow.{u1, u2, u1} (AddOpposite.{u1} α) β (AddOpposite.{u1} α) (instHPow.{u1, u2} (AddOpposite.{u1} α) β (AddOpposite.hasPow.{u1, u2} α β _inst_1)) (AddOpposite.op.{u1} α a) b)
but is expected to have type
  forall (α : Type.{u2}) {β : Type.{u1}} [_inst_1 : Pow.{u2, u1} α β] (a : α) (b : β), Eq.{succ u2} (AddOpposite.{u2} α) (AddOpposite.op.{u2} α (HPow.hPow.{u2, u1, u2} α β α (instHPow.{u2, u1} α β _inst_1) a b)) (HPow.hPow.{u2, u1, u2} (AddOpposite.{u2} α) β (AddOpposite.{u2} α) (instHPow.{u2, u1} (AddOpposite.{u2} α) β (AddOpposite.instPowAddOpposite.{u2, u1} α β _inst_1)) (AddOpposite.op.{u2} α a) b)
Case conversion may be inaccurate. Consider using '#align add_opposite.op_pow AddOpposite.op_powₓ'. -/
@[simp]
theorem op_pow {β} [Pow α β] (a : α) (b : β) : op (a ^ b) = op a ^ b :=
  rfl
#align add_opposite.op_pow AddOpposite.op_pow

/- warning: add_opposite.unop_pow -> AddOpposite.unop_pow is a dubious translation:
lean 3 declaration is
  forall (α : Type.{u1}) {β : Type.{u2}} [_inst_1 : Pow.{u1, u2} α β] (a : AddOpposite.{u1} α) (b : β), Eq.{succ u1} α (AddOpposite.unop.{u1} α (HPow.hPow.{u1, u2, u1} (AddOpposite.{u1} α) β (AddOpposite.{u1} α) (instHPow.{u1, u2} (AddOpposite.{u1} α) β (AddOpposite.hasPow.{u1, u2} α β _inst_1)) a b)) (HPow.hPow.{u1, u2, u1} α β α (instHPow.{u1, u2} α β _inst_1) (AddOpposite.unop.{u1} α a) b)
but is expected to have type
  forall (α : Type.{u2}) {β : Type.{u1}} [_inst_1 : Pow.{u2, u1} α β] (a : AddOpposite.{u2} α) (b : β), Eq.{succ u2} α (AddOpposite.unop.{u2} α (HPow.hPow.{u2, u1, u2} (AddOpposite.{u2} α) β (AddOpposite.{u2} α) (instHPow.{u2, u1} (AddOpposite.{u2} α) β (AddOpposite.instPowAddOpposite.{u2, u1} α β _inst_1)) a b)) (HPow.hPow.{u2, u1, u2} α β α (instHPow.{u2, u1} α β _inst_1) (AddOpposite.unop.{u2} α a) b)
Case conversion may be inaccurate. Consider using '#align add_opposite.unop_pow AddOpposite.unop_powₓ'. -/
@[simp]
theorem unop_pow {β} [Pow α β] (a : αᵃᵒᵖ) (b : β) : unop (a ^ b) = unop a ^ b :=
  rfl
#align add_opposite.unop_pow AddOpposite.unop_pow

instance [Monoid α] : Monoid αᵃᵒᵖ :=
  unop_injective.Monoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

instance [CommMonoid α] : CommMonoid αᵃᵒᵖ :=
  unop_injective.CommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl

instance [DivInvMonoid α] : DivInvMonoid αᵃᵒᵖ :=
  unop_injective.DivInvMonoid _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl

instance [Group α] : Group αᵃᵒᵖ :=
  unop_injective.Group _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    fun _ _ => rfl

instance [CommGroup α] : CommGroup αᵃᵒᵖ :=
  unop_injective.CommGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    fun _ _ => rfl

variable {α}

#print AddOpposite.opMulEquiv /-
/-- The function `add_opposite.op` is a multiplicative equivalence. -/
@[simps (config :=
      { fullyApplied := false
        simpRhs := true })]
def opMulEquiv [Mul α] : α ≃* αᵃᵒᵖ :=
  { opEquiv with map_mul' := fun a b => rfl }
#align add_opposite.op_mul_equiv AddOpposite.opMulEquiv
-/

#print AddOpposite.opMulEquiv_toEquiv /-
@[simp]
theorem opMulEquiv_toEquiv [Mul α] : (opMulEquiv : α ≃* αᵃᵒᵖ).toEquiv = op_equiv :=
  rfl
#align add_opposite.op_mul_equiv_to_equiv AddOpposite.opMulEquiv_toEquiv
-/

end AddOpposite

open MulOpposite

/- warning: mul_equiv.inv' -> MulEquiv.inv' is a dubious translation:
lean 3 declaration is
  forall (G : Type.{u1}) [_inst_1 : DivisionMonoid.{u1} G], MulEquiv.{u1, u1} G (MulOpposite.{u1} G) (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (DivisionMonoid.toDivInvMonoid.{u1} G _inst_1)))) (MulOpposite.hasMul.{u1} G (MulOneClass.toHasMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (DivisionMonoid.toDivInvMonoid.{u1} G _inst_1)))))
but is expected to have type
  forall (G : Type.{u1}) [_inst_1 : DivisionMonoid.{u1} G], MulEquiv.{u1, u1} G (MulOpposite.{u1} G) (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (DivisionMonoid.toDivInvMonoid.{u1} G _inst_1)))) (MulOpposite.instMulMulOpposite.{u1} G (MulOneClass.toMul.{u1} G (Monoid.toMulOneClass.{u1} G (DivInvMonoid.toMonoid.{u1} G (DivisionMonoid.toDivInvMonoid.{u1} G _inst_1)))))
Case conversion may be inaccurate. Consider using '#align mul_equiv.inv' MulEquiv.inv'ₓ'. -/
/-- Inversion on a group is a `mul_equiv` to the opposite group. When `G` is commutative, there is
`mul_equiv.inv`. -/
@[to_additive
      "Negation on an additive group is an `add_equiv` to the opposite group. When `G`\nis commutative, there is `add_equiv.inv`.",
  simps (config :=
      { fullyApplied := false
        simpRhs := true })]
def MulEquiv.inv' (G : Type _) [DivisionMonoid G] : G ≃* Gᵐᵒᵖ :=
  { (Equiv.inv G).trans opEquiv with map_mul' := fun x y => unop_injective <| mul_inv_rev x y }
#align mul_equiv.inv' MulEquiv.inv'
#align add_equiv.neg' AddEquiv.neg'

#print MulHom.toOpposite /-
/-- A semigroup homomorphism `f : M →ₙ* N` such that `f x` commutes with `f y` for all `x, y`
defines a semigroup homomorphism to `Nᵐᵒᵖ`. -/
@[to_additive
      "An additive semigroup homomorphism `f : add_hom M N` such that `f x` additively\ncommutes with `f y` for all `x, y` defines an additive semigroup homomorphism to `Sᵃᵒᵖ`.",
  simps (config := { fullyApplied := false })]
def MulHom.toOpposite {M N : Type _} [Mul M] [Mul N] (f : M →ₙ* N)
    (hf : ∀ x y, Commute (f x) (f y)) : M →ₙ* Nᵐᵒᵖ
    where
  toFun := MulOpposite.op ∘ f
  map_mul' x y := by simp [(hf x y).Eq]
#align mul_hom.to_opposite MulHom.toOpposite
#align add_hom.to_opposite AddHom.toOpposite
-/

#print MulHom.fromOpposite /-
/-- A semigroup homomorphism `f : M →ₙ* N` such that `f x` commutes with `f y` for all `x, y`
defines a semigroup homomorphism from `Mᵐᵒᵖ`. -/
@[to_additive
      "An additive semigroup homomorphism `f : add_hom M N` such that `f x` additively\ncommutes with `f y` for all `x`, `y` defines an additive semigroup homomorphism from `Mᵃᵒᵖ`.",
  simps (config := { fullyApplied := false })]
def MulHom.fromOpposite {M N : Type _} [Mul M] [Mul N] (f : M →ₙ* N)
    (hf : ∀ x y, Commute (f x) (f y)) : Mᵐᵒᵖ →ₙ* N
    where
  toFun := f ∘ MulOpposite.unop
  map_mul' x y := (f.map_mul _ _).trans (hf _ _).Eq
#align mul_hom.from_opposite MulHom.fromOpposite
#align add_hom.from_opposite AddHom.fromOpposite
-/

/- warning: monoid_hom.to_opposite -> MonoidHom.toOpposite is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N] (f : MonoidHom.{u1, u2} M N _inst_1 _inst_2), (forall (x : M) (y : M), Commute.{u2} N (MulOneClass.toHasMul.{u2} N _inst_2) (coeFn.{max (succ u2) (succ u1), max (succ u1) (succ u2)} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) (fun (_x : MonoidHom.{u1, u2} M N _inst_1 _inst_2) => M -> N) (MonoidHom.hasCoeToFun.{u1, u2} M N _inst_1 _inst_2) f x) (coeFn.{max (succ u2) (succ u1), max (succ u1) (succ u2)} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) (fun (_x : MonoidHom.{u1, u2} M N _inst_1 _inst_2) => M -> N) (MonoidHom.hasCoeToFun.{u1, u2} M N _inst_1 _inst_2) f y)) -> (MonoidHom.{u1, u2} M (MulOpposite.{u2} N) _inst_1 (MulOpposite.mulOneClass.{u2} N _inst_2))
but is expected to have type
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N] (f : MonoidHom.{u1, u2} M N _inst_1 _inst_2), (forall (x : M) (y : M), Commute.{u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) x) (MulOneClass.toMul.{u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) x) _inst_2) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M (fun (_x : M) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N (MulOneClass.toMul.{u1} M _inst_1) (MulOneClass.toMul.{u2} N _inst_2) (MonoidHomClass.toMulHomClass.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N _inst_1 _inst_2 (MonoidHom.monoidHomClass.{u1, u2} M N _inst_1 _inst_2))) f x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M (fun (_x : M) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N (MulOneClass.toMul.{u1} M _inst_1) (MulOneClass.toMul.{u2} N _inst_2) (MonoidHomClass.toMulHomClass.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N _inst_1 _inst_2 (MonoidHom.monoidHomClass.{u1, u2} M N _inst_1 _inst_2))) f y)) -> (MonoidHom.{u1, u2} M (MulOpposite.{u2} N) _inst_1 (MulOpposite.instMulOneClassMulOpposite.{u2} N _inst_2))
Case conversion may be inaccurate. Consider using '#align monoid_hom.to_opposite MonoidHom.toOppositeₓ'. -/
/-- A monoid homomorphism `f : M →* N` such that `f x` commutes with `f y` for all `x, y` defines
a monoid homomorphism to `Nᵐᵒᵖ`. -/
@[to_additive
      "An additive monoid homomorphism `f : M →+ N` such that `f x` additively commutes\nwith `f y` for all `x, y` defines an additive monoid homomorphism to `Sᵃᵒᵖ`.",
  simps (config := { fullyApplied := false })]
def MonoidHom.toOpposite {M N : Type _} [MulOneClass M] [MulOneClass N] (f : M →* N)
    (hf : ∀ x y, Commute (f x) (f y)) : M →* Nᵐᵒᵖ
    where
  toFun := MulOpposite.op ∘ f
  map_one' := congr_arg op f.map_one
  map_mul' x y := by simp [(hf x y).Eq]
#align monoid_hom.to_opposite MonoidHom.toOpposite
#align add_monoid_hom.to_opposite AddMonoidHom.toOpposite

/- warning: monoid_hom.from_opposite -> MonoidHom.fromOpposite is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N] (f : MonoidHom.{u1, u2} M N _inst_1 _inst_2), (forall (x : M) (y : M), Commute.{u2} N (MulOneClass.toHasMul.{u2} N _inst_2) (coeFn.{max (succ u2) (succ u1), max (succ u1) (succ u2)} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) (fun (_x : MonoidHom.{u1, u2} M N _inst_1 _inst_2) => M -> N) (MonoidHom.hasCoeToFun.{u1, u2} M N _inst_1 _inst_2) f x) (coeFn.{max (succ u2) (succ u1), max (succ u1) (succ u2)} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) (fun (_x : MonoidHom.{u1, u2} M N _inst_1 _inst_2) => M -> N) (MonoidHom.hasCoeToFun.{u1, u2} M N _inst_1 _inst_2) f y)) -> (MonoidHom.{u1, u2} (MulOpposite.{u1} M) N (MulOpposite.mulOneClass.{u1} M _inst_1) _inst_2)
but is expected to have type
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N] (f : MonoidHom.{u1, u2} M N _inst_1 _inst_2), (forall (x : M) (y : M), Commute.{u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) x) (MulOneClass.toMul.{u2} ((fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) x) _inst_2) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M (fun (_x : M) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N (MulOneClass.toMul.{u1} M _inst_1) (MulOneClass.toMul.{u2} N _inst_2) (MonoidHomClass.toMulHomClass.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N _inst_1 _inst_2 (MonoidHom.monoidHomClass.{u1, u2} M N _inst_1 _inst_2))) f x) (FunLike.coe.{max (succ u1) (succ u2), succ u1, succ u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M (fun (_x : M) => (fun (x._@.Mathlib.Algebra.Hom.Group._hyg.2528 : M) => N) _x) (MulHomClass.toFunLike.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N (MulOneClass.toMul.{u1} M _inst_1) (MulOneClass.toMul.{u2} N _inst_2) (MonoidHomClass.toMulHomClass.{max u1 u2, u1, u2} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) M N _inst_1 _inst_2 (MonoidHom.monoidHomClass.{u1, u2} M N _inst_1 _inst_2))) f y)) -> (MonoidHom.{u1, u2} (MulOpposite.{u1} M) N (MulOpposite.instMulOneClassMulOpposite.{u1} M _inst_1) _inst_2)
Case conversion may be inaccurate. Consider using '#align monoid_hom.from_opposite MonoidHom.fromOppositeₓ'. -/
/-- A monoid homomorphism `f : M →* N` such that `f x` commutes with `f y` for all `x, y` defines
a monoid homomorphism from `Mᵐᵒᵖ`. -/
@[to_additive
      "An additive monoid homomorphism `f : M →+ N` such that `f x` additively commutes\nwith `f y` for all `x`, `y` defines an additive monoid homomorphism from `Mᵃᵒᵖ`.",
  simps (config := { fullyApplied := false })]
def MonoidHom.fromOpposite {M N : Type _} [MulOneClass M] [MulOneClass N] (f : M →* N)
    (hf : ∀ x y, Commute (f x) (f y)) : Mᵐᵒᵖ →* N
    where
  toFun := f ∘ MulOpposite.unop
  map_one' := f.map_one
  map_mul' x y := (f.map_mul _ _).trans (hf _ _).Eq
#align monoid_hom.from_opposite MonoidHom.fromOpposite
#align add_monoid_hom.from_opposite AddMonoidHom.fromOpposite

/- warning: units.op_equiv -> Units.opEquiv is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Monoid.{u1} M], MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1)))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Monoid.{u1} M], MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1)))
Case conversion may be inaccurate. Consider using '#align units.op_equiv Units.opEquivₓ'. -/
/-- The units of the opposites are equivalent to the opposites of the units. -/
@[to_additive
      "The additive units of the additive opposites are equivalent to the additive opposites\nof the additive units."]
def Units.opEquiv {M} [Monoid M] : Mᵐᵒᵖˣ ≃* Mˣᵐᵒᵖ
    where
  toFun u := op ⟨unop u, unop ↑u⁻¹, op_injective u.4, op_injective u.3⟩
  invFun := MulOpposite.rec' fun u => ⟨op ↑u, op ↑u⁻¹, unop_injective <| u.4, unop_injective u.3⟩
  map_mul' x y := unop_injective <| Units.ext <| rfl
  left_inv x := Units.ext <| by simp
  right_inv x := unop_injective <| Units.ext <| rfl
#align units.op_equiv Units.opEquiv
#align add_units.op_equiv AddUnits.opEquiv

/- warning: units.coe_unop_op_equiv -> Units.coe_unop_opEquiv is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Monoid.{u1} M] (u : Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)), Eq.{succ u1} M ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Units.{u1} M _inst_1) M (HasLiftT.mk.{succ u1, succ u1} (Units.{u1} M _inst_1) M (CoeTCₓ.coe.{succ u1, succ u1} (Units.{u1} M _inst_1) M (coeBase.{succ u1, succ u1} (Units.{u1} M _inst_1) M (Units.hasCoe.{u1} M _inst_1)))) (MulOpposite.unop.{u1} (Units.{u1} M _inst_1) (coeFn.{succ u1, succ u1} (MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1)))) (fun (_x : MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1)))) => (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) -> (MulOpposite.{u1} (Units.{u1} M _inst_1))) (MulEquiv.hasCoeToFun.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1)))) (Units.opEquiv.{u1} M _inst_1) u))) (MulOpposite.unop.{u1} M ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (HasLiftT.mk.{succ u1, succ u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (CoeTCₓ.coe.{succ u1, succ u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (coeBase.{succ u1, succ u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (Units.hasCoe.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))))) u))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Monoid.{u1} M] (u : Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)), Eq.{succ u1} M (Units.val.{u1} M _inst_1 (MulOpposite.unop.{u1} (Units.{u1} M _inst_1) (FunLike.coe.{succ u1, succ u1, succ u1} (MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1)))) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (fun (_x : Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) => MulOpposite.{u1} (Units.{u1} M _inst_1)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1)))) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1)))) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulEquivClass.toEquivLike.{u1, u1, u1} (MulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1)))) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (MulEquiv.instMulEquivClassMulEquiv.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))))))) (Units.opEquiv.{u1} M _inst_1) u))) (MulOpposite.unop.{u1} M (Units.val.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1) u))
Case conversion may be inaccurate. Consider using '#align units.coe_unop_op_equiv Units.coe_unop_opEquivₓ'. -/
@[simp, to_additive]
theorem Units.coe_unop_opEquiv {M} [Monoid M] (u : Mᵐᵒᵖˣ) :
    ((Units.opEquiv u).unop : M) = unop (u : Mᵐᵒᵖ) :=
  rfl
#align units.coe_unop_op_equiv Units.coe_unop_opEquiv
#align add_units.coe_unop_op_equiv AddUnits.coe_unop_opEquiv

/- warning: units.coe_op_equiv_symm -> Units.coe_opEquiv_symm is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} [_inst_1 : Monoid.{u1} M] (u : MulOpposite.{u1} (Units.{u1} M _inst_1)), Eq.{succ u1} (MulOpposite.{u1} M) ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (HasLiftT.mk.{succ u1, succ u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (CoeTCₓ.coe.{succ u1, succ u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (coeBase.{succ u1, succ u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} M) (Units.hasCoe.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))))) (coeFn.{succ u1, succ u1} (MulEquiv.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1))) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)))) (fun (_x : MulEquiv.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1))) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)))) => (MulOpposite.{u1} (Units.{u1} M _inst_1)) -> (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))) (MulEquiv.hasCoeToFun.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1))) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)))) (MulEquiv.symm.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toHasMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1)) (Units.mulOneClass.{u1} (MulOpposite.{u1} M) (MulOpposite.monoid.{u1} M _inst_1))) (MulOpposite.hasMul.{u1} (Units.{u1} M _inst_1) (MulOneClass.toHasMul.{u1} (Units.{u1} M _inst_1) (Units.mulOneClass.{u1} M _inst_1))) (Units.opEquiv.{u1} M _inst_1)) u)) (MulOpposite.op.{u1} M ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Units.{u1} M _inst_1) M (HasLiftT.mk.{succ u1, succ u1} (Units.{u1} M _inst_1) M (CoeTCₓ.coe.{succ u1, succ u1} (Units.{u1} M _inst_1) M (coeBase.{succ u1, succ u1} (Units.{u1} M _inst_1) M (Units.hasCoe.{u1} M _inst_1)))) (MulOpposite.unop.{u1} (Units.{u1} M _inst_1) u)))
but is expected to have type
  forall {M : Type.{u1}} [_inst_1 : Monoid.{u1} M] (u : MulOpposite.{u1} (Units.{u1} M _inst_1)), Eq.{succ u1} (MulOpposite.{u1} M) (Units.val.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1) (FunLike.coe.{succ u1, succ u1, succ u1} (MulEquiv.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)))) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (fun (_x : MulOpposite.{u1} (Units.{u1} M _inst_1)) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : MulOpposite.{u1} (Units.{u1} M _inst_1)) => Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) _x) (EmbeddingLike.toFunLike.{succ u1, succ u1, succ u1} (MulEquiv.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)))) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (EquivLike.toEmbeddingLike.{succ u1, succ u1, succ u1} (MulEquiv.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)))) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulEquivClass.toEquivLike.{u1, u1, u1} (MulEquiv.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)))) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulEquiv.instMulEquivClassMulEquiv.{u1, u1} (MulOpposite.{u1} (Units.{u1} M _inst_1)) (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))))))) (MulEquiv.symm.{u1, u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (MulOpposite.{u1} (Units.{u1} M _inst_1)) (MulOneClass.toMul.{u1} (Units.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1)) (Units.instMulOneClassUnits.{u1} (MulOpposite.{u1} M) (MulOpposite.instMonoidMulOpposite.{u1} M _inst_1))) (MulOpposite.instMulMulOpposite.{u1} (Units.{u1} M _inst_1) (MulOneClass.toMul.{u1} (Units.{u1} M _inst_1) (Units.instMulOneClassUnits.{u1} M _inst_1))) (Units.opEquiv.{u1} M _inst_1)) u)) (MulOpposite.op.{u1} M (Units.val.{u1} M _inst_1 (MulOpposite.unop.{u1} (Units.{u1} M _inst_1) u)))
Case conversion may be inaccurate. Consider using '#align units.coe_op_equiv_symm Units.coe_opEquiv_symmₓ'. -/
@[simp, to_additive]
theorem Units.coe_opEquiv_symm {M} [Monoid M] (u : Mˣᵐᵒᵖ) :
    (Units.opEquiv.symm u : Mᵐᵒᵖ) = op (u.unop : M) :=
  rfl
#align units.coe_op_equiv_symm Units.coe_opEquiv_symm
#align add_units.coe_op_equiv_symm AddUnits.coe_opEquiv_symm

#print MulHom.op /-
/-- A semigroup homomorphism `M →ₙ* N` can equivalently be viewed as a semigroup homomorphism
`Mᵐᵒᵖ →ₙ* Nᵐᵒᵖ`. This is the action of the (fully faithful) `ᵐᵒᵖ`-functor on morphisms. -/
@[to_additive
      "An additive semigroup homomorphism `add_hom M N` can equivalently be viewed as an\nadditive semigroup homomorphism `add_hom Mᵃᵒᵖ Nᵃᵒᵖ`. This is the action of the (fully faithful)\n`ᵃᵒᵖ`-functor on morphisms.",
  simps]
def MulHom.op {M N} [Mul M] [Mul N] : (M →ₙ* N) ≃ (Mᵐᵒᵖ →ₙ* Nᵐᵒᵖ)
    where
  toFun f :=
    { toFun := op ∘ f ∘ unop
      map_mul' := fun x y => unop_injective (f.map_mul y.unop x.unop) }
  invFun f :=
    { toFun := unop ∘ f ∘ op
      map_mul' := fun x y => congr_arg unop (f.map_mul (op y) (op x)) }
  left_inv f := by
    ext
    rfl
  right_inv f := by
    ext x
    simp
#align mul_hom.op MulHom.op
#align add_hom.op AddHom.op
-/

#print MulHom.unop /-
/-- The 'unopposite' of a semigroup homomorphism `Mᵐᵒᵖ →ₙ* Nᵐᵒᵖ`. Inverse to `mul_hom.op`. -/
@[simp,
  to_additive
      "The 'unopposite' of an additive semigroup homomorphism `Mᵃᵒᵖ →ₙ+ Nᵃᵒᵖ`. Inverse\nto `add_hom.op`."]
def MulHom.unop {M N} [Mul M] [Mul N] : (Mᵐᵒᵖ →ₙ* Nᵐᵒᵖ) ≃ (M →ₙ* N) :=
  MulHom.op.symm
#align mul_hom.unop MulHom.unop
#align add_hom.unop AddHom.unop
-/

#print AddHom.mulOp /-
/-- An additive semigroup homomorphism `add_hom M N` can equivalently be viewed as an additive
homomorphism `add_hom Mᵐᵒᵖ Nᵐᵒᵖ`. This is the action of the (fully faithful) `ᵐᵒᵖ`-functor on
morphisms. -/
@[simps]
def AddHom.mulOp {M N} [Add M] [Add N] : AddHom M N ≃ AddHom Mᵐᵒᵖ Nᵐᵒᵖ
    where
  toFun f :=
    { toFun := op ∘ f ∘ unop
      map_add' := fun x y => unop_injective (f.map_add x.unop y.unop) }
  invFun f :=
    { toFun := unop ∘ f ∘ op
      map_add' := fun x y => congr_arg unop (f.map_add (op x) (op y)) }
  left_inv f := by
    ext
    rfl
  right_inv f := by
    ext
    simp
#align add_hom.mul_op AddHom.mulOp
-/

#print AddHom.mulUnop /-
/-- The 'unopposite' of an additive semigroup hom `αᵐᵒᵖ →+ βᵐᵒᵖ`. Inverse to
`add_hom.mul_op`. -/
@[simp]
def AddHom.mulUnop {α β} [Add α] [Add β] : AddHom αᵐᵒᵖ βᵐᵒᵖ ≃ AddHom α β :=
  AddHom.mulOp.symm
#align add_hom.mul_unop AddHom.mulUnop
-/

/- warning: monoid_hom.op -> MonoidHom.op is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) (MonoidHom.{u1, u2} (MulOpposite.{u1} M) (MulOpposite.{u2} N) (MulOpposite.mulOneClass.{u1} M _inst_1) (MulOpposite.mulOneClass.{u2} N _inst_2))
but is expected to have type
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (MonoidHom.{u1, u2} M N _inst_1 _inst_2) (MonoidHom.{u1, u2} (MulOpposite.{u1} M) (MulOpposite.{u2} N) (MulOpposite.instMulOneClassMulOpposite.{u1} M _inst_1) (MulOpposite.instMulOneClassMulOpposite.{u2} N _inst_2))
Case conversion may be inaccurate. Consider using '#align monoid_hom.op MonoidHom.opₓ'. -/
/-- A monoid homomorphism `M →* N` can equivalently be viewed as a monoid homomorphism
`Mᵐᵒᵖ →* Nᵐᵒᵖ`. This is the action of the (fully faithful) `ᵐᵒᵖ`-functor on morphisms. -/
@[to_additive
      "An additive monoid homomorphism `M →+ N` can equivalently be viewed as an\nadditive monoid homomorphism `Mᵃᵒᵖ →+ Nᵃᵒᵖ`. This is the action of the (fully faithful)\n`ᵃᵒᵖ`-functor on morphisms.",
  simps]
def MonoidHom.op {M N} [MulOneClass M] [MulOneClass N] : (M →* N) ≃ (Mᵐᵒᵖ →* Nᵐᵒᵖ)
    where
  toFun f :=
    { toFun := op ∘ f ∘ unop
      map_one' := congr_arg op f.map_one
      map_mul' := fun x y => unop_injective (f.map_mul y.unop x.unop) }
  invFun f :=
    { toFun := unop ∘ f ∘ op
      map_one' := congr_arg unop f.map_one
      map_mul' := fun x y => congr_arg unop (f.map_mul (op y) (op x)) }
  left_inv f := by
    ext
    rfl
  right_inv f := by
    ext x
    simp
#align monoid_hom.op MonoidHom.op
#align add_monoid_hom.op AddMonoidHom.op

/- warning: monoid_hom.unop -> MonoidHom.unop is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (MonoidHom.{u1, u2} (MulOpposite.{u1} M) (MulOpposite.{u2} N) (MulOpposite.mulOneClass.{u1} M _inst_1) (MulOpposite.mulOneClass.{u2} N _inst_2)) (MonoidHom.{u1, u2} M N _inst_1 _inst_2)
but is expected to have type
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : MulOneClass.{u1} M] [_inst_2 : MulOneClass.{u2} N], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (MonoidHom.{u1, u2} (MulOpposite.{u1} M) (MulOpposite.{u2} N) (MulOpposite.instMulOneClassMulOpposite.{u1} M _inst_1) (MulOpposite.instMulOneClassMulOpposite.{u2} N _inst_2)) (MonoidHom.{u1, u2} M N _inst_1 _inst_2)
Case conversion may be inaccurate. Consider using '#align monoid_hom.unop MonoidHom.unopₓ'. -/
/-- The 'unopposite' of a monoid homomorphism `Mᵐᵒᵖ →* Nᵐᵒᵖ`. Inverse to `monoid_hom.op`. -/
@[simp,
  to_additive
      "The 'unopposite' of an additive monoid homomorphism `Mᵃᵒᵖ →+ Nᵃᵒᵖ`. Inverse to\n`add_monoid_hom.op`."]
def MonoidHom.unop {M N} [MulOneClass M] [MulOneClass N] : (Mᵐᵒᵖ →* Nᵐᵒᵖ) ≃ (M →* N) :=
  MonoidHom.op.symm
#align monoid_hom.unop MonoidHom.unop
#align add_monoid_hom.unop AddMonoidHom.unop

/- warning: add_monoid_hom.mul_op -> AddMonoidHom.mulOp is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : AddZeroClass.{u1} M] [_inst_2 : AddZeroClass.{u2} N], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (AddMonoidHom.{u1, u2} M N _inst_1 _inst_2) (AddMonoidHom.{u1, u2} (MulOpposite.{u1} M) (MulOpposite.{u2} N) (MulOpposite.addZeroClass.{u1} M _inst_1) (MulOpposite.addZeroClass.{u2} N _inst_2))
but is expected to have type
  forall {M : Type.{u1}} {N : Type.{u2}} [_inst_1 : AddZeroClass.{u1} M] [_inst_2 : AddZeroClass.{u2} N], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (AddMonoidHom.{u1, u2} M N _inst_1 _inst_2) (AddMonoidHom.{u1, u2} (MulOpposite.{u1} M) (MulOpposite.{u2} N) (MulOpposite.instAddZeroClassMulOpposite.{u1} M _inst_1) (MulOpposite.instAddZeroClassMulOpposite.{u2} N _inst_2))
Case conversion may be inaccurate. Consider using '#align add_monoid_hom.mul_op AddMonoidHom.mulOpₓ'. -/
/-- An additive homomorphism `M →+ N` can equivalently be viewed as an additive homomorphism
`Mᵐᵒᵖ →+ Nᵐᵒᵖ`. This is the action of the (fully faithful) `ᵐᵒᵖ`-functor on morphisms. -/
@[simps]
def AddMonoidHom.mulOp {M N} [AddZeroClass M] [AddZeroClass N] : (M →+ N) ≃ (Mᵐᵒᵖ →+ Nᵐᵒᵖ)
    where
  toFun f :=
    { toFun := op ∘ f ∘ unop
      map_zero' := unop_injective f.map_zero
      map_add' := fun x y => unop_injective (f.map_add x.unop y.unop) }
  invFun f :=
    { toFun := unop ∘ f ∘ op
      map_zero' := congr_arg unop f.map_zero
      map_add' := fun x y => congr_arg unop (f.map_add (op x) (op y)) }
  left_inv f := by
    ext
    rfl
  right_inv f := by
    ext
    simp
#align add_monoid_hom.mul_op AddMonoidHom.mulOp

/- warning: add_monoid_hom.mul_unop -> AddMonoidHom.mulUnop is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : AddZeroClass.{u1} α] [_inst_2 : AddZeroClass.{u2} β], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (AddMonoidHom.{u1, u2} (MulOpposite.{u1} α) (MulOpposite.{u2} β) (MulOpposite.addZeroClass.{u1} α _inst_1) (MulOpposite.addZeroClass.{u2} β _inst_2)) (AddMonoidHom.{u1, u2} α β _inst_1 _inst_2)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : AddZeroClass.{u1} α] [_inst_2 : AddZeroClass.{u2} β], Equiv.{max (succ u2) (succ u1), max (succ u2) (succ u1)} (AddMonoidHom.{u1, u2} (MulOpposite.{u1} α) (MulOpposite.{u2} β) (MulOpposite.instAddZeroClassMulOpposite.{u1} α _inst_1) (MulOpposite.instAddZeroClassMulOpposite.{u2} β _inst_2)) (AddMonoidHom.{u1, u2} α β _inst_1 _inst_2)
Case conversion may be inaccurate. Consider using '#align add_monoid_hom.mul_unop AddMonoidHom.mulUnopₓ'. -/
/-- The 'unopposite' of an additive monoid hom `αᵐᵒᵖ →+ βᵐᵒᵖ`. Inverse to
`add_monoid_hom.mul_op`. -/
@[simp]
def AddMonoidHom.mulUnop {α β} [AddZeroClass α] [AddZeroClass β] : (αᵐᵒᵖ →+ βᵐᵒᵖ) ≃ (α →+ β) :=
  AddMonoidHom.mulOp.symm
#align add_monoid_hom.mul_unop AddMonoidHom.mulUnop

#print AddEquiv.mulOp /-
/-- A iso `α ≃+ β` can equivalently be viewed as an iso `αᵐᵒᵖ ≃+ βᵐᵒᵖ`. -/
@[simps]
def AddEquiv.mulOp {α β} [Add α] [Add β] : α ≃+ β ≃ (αᵐᵒᵖ ≃+ βᵐᵒᵖ)
    where
  toFun f := opAddEquiv.symm.trans (f.trans opAddEquiv)
  invFun f := opAddEquiv.trans (f.trans opAddEquiv.symm)
  left_inv f := by
    ext
    rfl
  right_inv f := by
    ext
    simp
#align add_equiv.mul_op AddEquiv.mulOp
-/

#print AddEquiv.mulUnop /-
/-- The 'unopposite' of an iso `αᵐᵒᵖ ≃+ βᵐᵒᵖ`. Inverse to `add_equiv.mul_op`. -/
@[simp]
def AddEquiv.mulUnop {α β} [Add α] [Add β] : αᵐᵒᵖ ≃+ βᵐᵒᵖ ≃ (α ≃+ β) :=
  AddEquiv.mulOp.symm
#align add_equiv.mul_unop AddEquiv.mulUnop
-/

#print MulEquiv.op /-
/-- A iso `α ≃* β` can equivalently be viewed as an iso `αᵐᵒᵖ ≃* βᵐᵒᵖ`. -/
@[to_additive "A iso `α ≃+ β` can equivalently be viewed as an iso `αᵃᵒᵖ ≃+ βᵃᵒᵖ`.", simps]
def MulEquiv.op {α β} [Mul α] [Mul β] : α ≃* β ≃ (αᵐᵒᵖ ≃* βᵐᵒᵖ)
    where
  toFun f :=
    { toFun := op ∘ f ∘ unop
      invFun := op ∘ f.symm ∘ unop
      left_inv := fun x => unop_injective (f.symm_apply_apply x.unop)
      right_inv := fun x => unop_injective (f.apply_symm_apply x.unop)
      map_mul' := fun x y => unop_injective (f.map_mul y.unop x.unop) }
  invFun f :=
    { toFun := unop ∘ f ∘ op
      invFun := unop ∘ f.symm ∘ op
      left_inv := fun x => by simp
      right_inv := fun x => by simp
      map_mul' := fun x y => congr_arg unop (f.map_mul (op y) (op x)) }
  left_inv f := by
    ext
    rfl
  right_inv f := by
    ext
    simp
#align mul_equiv.op MulEquiv.op
#align add_equiv.op AddEquiv.op
-/

#print MulEquiv.unop /-
/-- The 'unopposite' of an iso `αᵐᵒᵖ ≃* βᵐᵒᵖ`. Inverse to `mul_equiv.op`. -/
@[simp, to_additive "The 'unopposite' of an iso `αᵃᵒᵖ ≃+ βᵃᵒᵖ`. Inverse to `add_equiv.op`."]
def MulEquiv.unop {α β} [Mul α] [Mul β] : αᵐᵒᵖ ≃* βᵐᵒᵖ ≃ (α ≃* β) :=
  MulEquiv.op.symm
#align mul_equiv.unop MulEquiv.unop
#align add_equiv.unop AddEquiv.unop
-/

section Ext

/- warning: add_monoid_hom.mul_op_ext -> AddMonoidHom.mul_op_ext is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : AddZeroClass.{u1} α] [_inst_2 : AddZeroClass.{u2} β] (f : AddMonoidHom.{u1, u2} (MulOpposite.{u1} α) β (MulOpposite.addZeroClass.{u1} α _inst_1) _inst_2) (g : AddMonoidHom.{u1, u2} (MulOpposite.{u1} α) β (MulOpposite.addZeroClass.{u1} α _inst_1) _inst_2), (Eq.{max (succ u2) (succ u1)} (AddMonoidHom.{u1, u2} α β _inst_1 _inst_2) (AddMonoidHom.comp.{u1, u1, u2} α (MulOpposite.{u1} α) β _inst_1 (MulOpposite.addZeroClass.{u1} α _inst_1) _inst_2 f (AddEquiv.toAddMonoidHom.{u1, u1} α (MulOpposite.{u1} α) _inst_1 (MulOpposite.addZeroClass.{u1} α _inst_1) (MulOpposite.opAddEquiv.{u1} α (AddZeroClass.toHasAdd.{u1} α _inst_1)))) (AddMonoidHom.comp.{u1, u1, u2} α (MulOpposite.{u1} α) β _inst_1 (MulOpposite.addZeroClass.{u1} α _inst_1) _inst_2 g (AddEquiv.toAddMonoidHom.{u1, u1} α (MulOpposite.{u1} α) _inst_1 (MulOpposite.addZeroClass.{u1} α _inst_1) (MulOpposite.opAddEquiv.{u1} α (AddZeroClass.toHasAdd.{u1} α _inst_1))))) -> (Eq.{max (succ u2) (succ u1)} (AddMonoidHom.{u1, u2} (MulOpposite.{u1} α) β (MulOpposite.addZeroClass.{u1} α _inst_1) _inst_2) f g)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : AddZeroClass.{u2} α] [_inst_2 : AddZeroClass.{u1} β] (f : AddMonoidHom.{u2, u1} (MulOpposite.{u2} α) β (MulOpposite.instAddZeroClassMulOpposite.{u2} α _inst_1) _inst_2) (g : AddMonoidHom.{u2, u1} (MulOpposite.{u2} α) β (MulOpposite.instAddZeroClassMulOpposite.{u2} α _inst_1) _inst_2), (Eq.{max (succ u2) (succ u1)} (AddMonoidHom.{u2, u1} α β _inst_1 _inst_2) (AddMonoidHom.comp.{u2, u2, u1} α (MulOpposite.{u2} α) β _inst_1 (MulOpposite.instAddZeroClassMulOpposite.{u2} α _inst_1) _inst_2 f (AddEquiv.toAddMonoidHom.{u2, u2} α (MulOpposite.{u2} α) _inst_1 (MulOpposite.instAddZeroClassMulOpposite.{u2} α _inst_1) (MulOpposite.opAddEquiv.{u2} α (AddZeroClass.toAdd.{u2} α _inst_1)))) (AddMonoidHom.comp.{u2, u2, u1} α (MulOpposite.{u2} α) β _inst_1 (MulOpposite.instAddZeroClassMulOpposite.{u2} α _inst_1) _inst_2 g (AddEquiv.toAddMonoidHom.{u2, u2} α (MulOpposite.{u2} α) _inst_1 (MulOpposite.instAddZeroClassMulOpposite.{u2} α _inst_1) (MulOpposite.opAddEquiv.{u2} α (AddZeroClass.toAdd.{u2} α _inst_1))))) -> (Eq.{max (succ u2) (succ u1)} (AddMonoidHom.{u2, u1} (MulOpposite.{u2} α) β (MulOpposite.instAddZeroClassMulOpposite.{u2} α _inst_1) _inst_2) f g)
Case conversion may be inaccurate. Consider using '#align add_monoid_hom.mul_op_ext AddMonoidHom.mul_op_extₓ'. -/
/-- This ext lemma change equalities on `αᵐᵒᵖ →+ β` to equalities on `α →+ β`.
This is useful because there are often ext lemmas for specific `α`s that will apply
to an equality of `α →+ β` such as `finsupp.add_hom_ext'`. -/
@[ext]
theorem AddMonoidHom.mul_op_ext {α β} [AddZeroClass α] [AddZeroClass β] (f g : αᵐᵒᵖ →+ β)
    (h :
      f.comp (opAddEquiv : α ≃+ αᵐᵒᵖ).toAddMonoidHom =
        g.comp (opAddEquiv : α ≃+ αᵐᵒᵖ).toAddMonoidHom) :
    f = g :=
  AddMonoidHom.ext <| MulOpposite.rec' fun x => (AddMonoidHom.congr_fun h : _) x
#align add_monoid_hom.mul_op_ext AddMonoidHom.mul_op_ext

end Ext

