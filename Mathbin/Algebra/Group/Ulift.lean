/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module algebra.group.ulift
! leanprover-community/mathlib commit 564bcc44d2b394a50c0cd6340c14a6b02a50a99a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Int.Cast.Defs
import Mathbin.Algebra.Hom.Equiv.Basic
import Mathbin.Algebra.GroupWithZero.InjSurj

/-!
# `ulift` instances for groups and monoids

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines instances for group, monoid, semigroup and related structures on `ulift` types.

(Recall `ulift α` is just a "copy" of a type `α` in a higher universe.)

We use `tactic.pi_instance_derive_field`, even though it wasn't intended for this purpose,
which seems to work fine.

We also provide `ulift.mul_equiv : ulift R ≃* R` (and its additive analogue).
-/


universe u v

variable {α : Type u} {β : Type _} {x y : ULift.{v} α}

namespace ULift

#print ULift.one /-
@[to_additive]
instance one [One α] : One (ULift α) :=
  ⟨⟨1⟩⟩
#align ulift.has_one ULift.one
#align ulift.has_zero ULift.zero
-/

#print ULift.one_down /-
@[simp, to_additive]
theorem one_down [One α] : (1 : ULift α).down = 1 :=
  rfl
#align ulift.one_down ULift.one_down
#align ulift.zero_down ULift.zero_down
-/

#print ULift.mul /-
@[to_additive]
instance mul [Mul α] : Mul (ULift α) :=
  ⟨fun f g => ⟨f.down * g.down⟩⟩
#align ulift.has_mul ULift.mul
#align ulift.has_add ULift.add
-/

#print ULift.mul_down /-
@[simp, to_additive]
theorem mul_down [Mul α] : (x * y).down = x.down * y.down :=
  rfl
#align ulift.mul_down ULift.mul_down
#align ulift.add_down ULift.add_down
-/

#print ULift.div /-
@[to_additive]
instance div [Div α] : Div (ULift α) :=
  ⟨fun f g => ⟨f.down / g.down⟩⟩
#align ulift.has_div ULift.div
#align ulift.has_sub ULift.sub
-/

#print ULift.div_down /-
@[simp, to_additive]
theorem div_down [Div α] : (x / y).down = x.down / y.down :=
  rfl
#align ulift.div_down ULift.div_down
#align ulift.sub_down ULift.sub_down
-/

#print ULift.inv /-
@[to_additive]
instance inv [Inv α] : Inv (ULift α) :=
  ⟨fun f => ⟨f.down⁻¹⟩⟩
#align ulift.has_inv ULift.inv
#align ulift.has_neg ULift.neg
-/

#print ULift.inv_down /-
@[simp, to_additive]
theorem inv_down [Inv α] : x⁻¹.down = x.down⁻¹ :=
  rfl
#align ulift.inv_down ULift.inv_down
#align ulift.neg_down ULift.neg_down
-/

#print ULift.smul /-
@[to_additive]
instance smul [SMul α β] : SMul α (ULift β) :=
  ⟨fun n x => up (n • x.down)⟩
#align ulift.has_smul ULift.smul
#align ulift.has_vadd ULift.vadd
-/

#print ULift.smul_down /-
@[simp, to_additive]
theorem smul_down [SMul α β] (a : α) (b : ULift.{v} β) : (a • b).down = a • b.down :=
  rfl
#align ulift.smul_down ULift.smul_down
#align ulift.vadd_down ULift.vadd_down
-/

#print ULift.pow /-
@[to_additive SMul, to_additive_reorder 1]
instance pow [Pow α β] : Pow (ULift α) β :=
  ⟨fun x n => up (x.down ^ n)⟩
#align ulift.has_pow ULift.pow
#align ulift.has_smul ULift.smul
-/

#print ULift.pow_down /-
@[simp, to_additive smul_down, to_additive_reorder 1]
theorem pow_down [Pow α β] (a : ULift.{v} α) (b : β) : (a ^ b).down = a.down ^ b :=
  rfl
#align ulift.pow_down ULift.pow_down
#align ulift.smul_down ULift.smul_down
-/

#print MulEquiv.ulift /-
/-- The multiplicative equivalence between `ulift α` and `α`.
-/
@[to_additive "The additive equivalence between `ulift α` and `α`."]
def MulEquiv.ulift [Mul α] : ULift α ≃* α :=
  { Equiv.ulift with map_mul' := fun x y => rfl }
#align mul_equiv.ulift MulEquiv.ulift
#align add_equiv.ulift AddEquiv.ulift
-/

#print ULift.semigroup /-
@[to_additive]
instance semigroup [Semigroup α] : Semigroup (ULift α) :=
  MulEquiv.ulift.Injective.Semigroup _ fun x y => rfl
#align ulift.semigroup ULift.semigroup
#align ulift.add_semigroup ULift.addSemigroup
-/

#print ULift.commSemigroup /-
@[to_additive]
instance commSemigroup [CommSemigroup α] : CommSemigroup (ULift α) :=
  Equiv.ulift.Injective.CommSemigroup _ fun x y => rfl
#align ulift.comm_semigroup ULift.commSemigroup
#align ulift.add_comm_semigroup ULift.addCommSemigroup
-/

#print ULift.mulOneClass /-
@[to_additive]
instance mulOneClass [MulOneClass α] : MulOneClass (ULift α) :=
  Equiv.ulift.Injective.MulOneClass _ rfl fun x y => rfl
#align ulift.mul_one_class ULift.mulOneClass
#align ulift.add_zero_class ULift.addZeroClass
-/

#print ULift.mulZeroOneClass /-
instance mulZeroOneClass [MulZeroOneClass α] : MulZeroOneClass (ULift α) :=
  Equiv.ulift.Injective.MulZeroOneClass _ rfl rfl fun x y => rfl
#align ulift.mul_zero_one_class ULift.mulZeroOneClass
-/

#print ULift.monoid /-
@[to_additive]
instance monoid [Monoid α] : Monoid (ULift α) :=
  Equiv.ulift.Injective.Monoid _ rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.monoid ULift.monoid
#align ulift.add_monoid ULift.addMonoid
-/

#print ULift.commMonoid /-
@[to_additive]
instance commMonoid [CommMonoid α] : CommMonoid (ULift α) :=
  Equiv.ulift.Injective.CommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.comm_monoid ULift.commMonoid
#align ulift.add_comm_monoid ULift.addCommMonoid
-/

instance [NatCast α] : NatCast (ULift α) :=
  ⟨fun n => up n⟩

instance [IntCast α] : IntCast (ULift α) :=
  ⟨fun n => up n⟩

#print ULift.up_natCast /-
@[simp, norm_cast]
theorem up_natCast [NatCast α] (n : ℕ) : up (n : α) = n :=
  rfl
#align ulift.up_nat_cast ULift.up_natCast
-/

#print ULift.up_intCast /-
@[simp, norm_cast]
theorem up_intCast [IntCast α] (n : ℤ) : up (n : α) = n :=
  rfl
#align ulift.up_int_cast ULift.up_intCast
-/

#print ULift.down_natCast /-
@[simp, norm_cast]
theorem down_natCast [NatCast α] (n : ℕ) : down (n : ULift α) = n :=
  rfl
#align ulift.down_nat_cast ULift.down_natCast
-/

#print ULift.down_intCast /-
@[simp, norm_cast]
theorem down_intCast [IntCast α] (n : ℤ) : down (n : ULift α) = n :=
  rfl
#align ulift.down_int_cast ULift.down_intCast
-/

#print ULift.addMonoidWithOne /-
instance addMonoidWithOne [AddMonoidWithOne α] : AddMonoidWithOne (ULift α) :=
  { ULift.one, ULift.addMonoid,
    ULift.natCast with
    natCast_zero := congr_arg ULift.up Nat.cast_zero
    natCast_succ := fun n => congr_arg ULift.up (Nat.cast_succ _) }
#align ulift.add_monoid_with_one ULift.addMonoidWithOne
-/

#print ULift.addCommMonoidWithOne /-
instance addCommMonoidWithOne [AddCommMonoidWithOne α] : AddCommMonoidWithOne (ULift α) :=
  { ULift.addMonoidWithOne, ULift.addCommMonoid with }
#align ulift.add_comm_monoid_with_one ULift.addCommMonoidWithOne
-/

#print ULift.monoidWithZero /-
instance monoidWithZero [MonoidWithZero α] : MonoidWithZero (ULift α) :=
  Equiv.ulift.Injective.MonoidWithZero _ rfl rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.monoid_with_zero ULift.monoidWithZero
-/

#print ULift.commMonoidWithZero /-
instance commMonoidWithZero [CommMonoidWithZero α] : CommMonoidWithZero (ULift α) :=
  Equiv.ulift.Injective.CommMonoidWithZero _ rfl rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.comm_monoid_with_zero ULift.commMonoidWithZero
-/

#print ULift.divInvMonoid /-
@[to_additive]
instance divInvMonoid [DivInvMonoid α] : DivInvMonoid (ULift α) :=
  Equiv.ulift.Injective.DivInvMonoid _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl
#align ulift.div_inv_monoid ULift.divInvMonoid
#align ulift.sub_neg_add_monoid ULift.subNegAddMonoid
-/

#print ULift.group /-
@[to_additive]
instance group [Group α] : Group (ULift α) :=
  Equiv.ulift.Injective.Group _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl
#align ulift.group ULift.group
#align ulift.add_group ULift.addGroup
-/

#print ULift.commGroup /-
@[to_additive]
instance commGroup [CommGroup α] : CommGroup (ULift α) :=
  Equiv.ulift.Injective.CommGroup _ rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl
#align ulift.comm_group ULift.commGroup
#align ulift.add_comm_group ULift.addCommGroup
-/

#print ULift.addGroupWithOne /-
instance addGroupWithOne [AddGroupWithOne α] : AddGroupWithOne (ULift α) :=
  { ULift.addMonoidWithOne,
    ULift.addGroup with
    intCast := fun n => ⟨n⟩
    intCast_ofNat := fun n => congr_arg ULift.up (Int.cast_ofNat _)
    intCast_negSucc := fun n => congr_arg ULift.up (Int.cast_negSucc _) }
#align ulift.add_group_with_one ULift.addGroupWithOne
-/

#print ULift.addCommGroupWithOne /-
instance addCommGroupWithOne [AddCommGroupWithOne α] : AddCommGroupWithOne (ULift α) :=
  { ULift.addGroupWithOne, ULift.addCommGroup with }
#align ulift.add_comm_group_with_one ULift.addCommGroupWithOne
-/

#print ULift.groupWithZero /-
instance groupWithZero [GroupWithZero α] : GroupWithZero (ULift α) :=
  Equiv.ulift.Injective.GroupWithZero _ rfl rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl
#align ulift.group_with_zero ULift.groupWithZero
-/

#print ULift.commGroupWithZero /-
instance commGroupWithZero [CommGroupWithZero α] : CommGroupWithZero (ULift α) :=
  Equiv.ulift.Injective.CommGroupWithZero _ rfl rfl (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ _ => rfl
#align ulift.comm_group_with_zero ULift.commGroupWithZero
-/

#print ULift.leftCancelSemigroup /-
@[to_additive AddLeftCancelSemigroup]
instance leftCancelSemigroup [LeftCancelSemigroup α] : LeftCancelSemigroup (ULift α) :=
  Equiv.ulift.Injective.LeftCancelSemigroup _ fun _ _ => rfl
#align ulift.left_cancel_semigroup ULift.leftCancelSemigroup
#align ulift.add_left_cancel_semigroup ULift.addLeftCancelSemigroup
-/

#print ULift.rightCancelSemigroup /-
@[to_additive AddRightCancelSemigroup]
instance rightCancelSemigroup [RightCancelSemigroup α] : RightCancelSemigroup (ULift α) :=
  Equiv.ulift.Injective.RightCancelSemigroup _ fun _ _ => rfl
#align ulift.right_cancel_semigroup ULift.rightCancelSemigroup
#align ulift.add_right_cancel_semigroup ULift.addRightCancelSemigroup
-/

#print ULift.leftCancelMonoid /-
@[to_additive AddLeftCancelMonoid]
instance leftCancelMonoid [LeftCancelMonoid α] : LeftCancelMonoid (ULift α) :=
  Equiv.ulift.Injective.LeftCancelMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.left_cancel_monoid ULift.leftCancelMonoid
#align ulift.add_left_cancel_monoid ULift.addLeftCancelMonoid
-/

#print ULift.rightCancelMonoid /-
@[to_additive AddRightCancelMonoid]
instance rightCancelMonoid [RightCancelMonoid α] : RightCancelMonoid (ULift α) :=
  Equiv.ulift.Injective.RightCancelMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.right_cancel_monoid ULift.rightCancelMonoid
#align ulift.add_right_cancel_monoid ULift.addRightCancelMonoid
-/

#print ULift.cancelMonoid /-
@[to_additive AddCancelMonoid]
instance cancelMonoid [CancelMonoid α] : CancelMonoid (ULift α) :=
  Equiv.ulift.Injective.CancelMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.cancel_monoid ULift.cancelMonoid
#align ulift.add_cancel_monoid ULift.addCancelMonoid
-/

#print ULift.cancelCommMonoid /-
@[to_additive AddCancelCommMonoid]
instance cancelCommMonoid [CancelCommMonoid α] : CancelCommMonoid (ULift α) :=
  Equiv.ulift.Injective.CancelCommMonoid _ rfl (fun _ _ => rfl) fun _ _ => rfl
#align ulift.cancel_comm_monoid ULift.cancelCommMonoid
#align ulift.add_cancel_comm_monoid ULift.addCancelCommMonoid
-/

#print ULift.nontrivial /-
instance nontrivial [Nontrivial α] : Nontrivial (ULift α) :=
  Equiv.ulift.symm.Injective.Nontrivial
#align ulift.nontrivial ULift.nontrivial
-/

-- TODO we don't do `ordered_cancel_comm_monoid` or `ordered_comm_group`
-- We'd need to add instances for `ulift` in `order.basic`.
end ULift

