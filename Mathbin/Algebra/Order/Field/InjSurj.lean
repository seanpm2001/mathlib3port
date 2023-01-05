/-
Copyright (c) 2014 Robert Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Lewis, Leonardo de Moura, Mario Carneiro, Floris van Doorn

! This file was ported from Lean 3 source module algebra.order.field.inj_surj
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Field.Defs
import Mathbin.Algebra.Field.Basic
import Mathbin.Algebra.Order.Ring.InjSurj

/-!
# Pulling back linearly ordered fields along injective maps.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

-/


open Function OrderDual

variable {ι α β : Type _}

namespace Function

/- warning: function.injective.linear_ordered_semifield -> Function.Injective.linearOrderedSemifield is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrderedSemifield.{u1} α] [_inst_2 : Zero.{u2} β] [_inst_3 : One.{u2} β] [_inst_4 : Add.{u2} β] [_inst_5 : Mul.{u2} β] [_inst_6 : Pow.{u2, 0} β Nat] [_inst_7 : HasSmul.{0, u2} Nat β] [_inst_8 : NatCast.{u2} β] [_inst_9 : Inv.{u2} β] [_inst_10 : Div.{u2} β] [_inst_11 : Pow.{u2, 0} β Int] [_inst_12 : HasSup.{u2} β] [_inst_13 : HasInf.{u2} β] (f : β -> α), (Function.Injective.{succ u2, succ u1} β α f) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 0 (OfNat.mk.{u2} β 0 (Zero.zero.{u2} β _inst_2)))) (OfNat.ofNat.{u1} α 0 (OfNat.mk.{u1} α 0 (Zero.zero.{u1} α (MulZeroClass.toHasZero.{u1} α (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} α (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))))))))))) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 1 (OfNat.mk.{u2} β 1 (One.one.{u2} β _inst_3)))) (OfNat.ofNat.{u1} α 1 (OfNat.mk.{u1} α 1 (One.one.{u1} α (AddMonoidWithOne.toOne.{u1} α (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} α (NonAssocSemiring.toAddCommMonoidWithOne.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))))))))))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HAdd.hAdd.{u2, u2, u2} β β β (instHAdd.{u2} β _inst_4) x y)) (HAdd.hAdd.{u1, u1, u1} α α α (instHAdd.{u1} α (Distrib.toHasAdd.{u1} α (NonUnitalNonAssocSemiring.toDistrib.{u1} α (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1))))))))) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HMul.hMul.{u2, u2, u2} β β β (instHMul.{u2} β _inst_5) x y)) (HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (Distrib.toHasMul.{u1} α (NonUnitalNonAssocSemiring.toDistrib.{u1} α (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1))))))))) (f x) (f y))) -> (forall (x : β), Eq.{succ u1} α (f (Inv.inv.{u2} β _inst_9 x)) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (GroupWithZero.toDivInvMonoid.{u1} α (DivisionSemiring.toGroupWithZero.{u1} α (Semifield.toDivisionSemiring.{u1} α (LinearOrderedSemifield.toSemifield.{u1} α _inst_1))))) (f x))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HDiv.hDiv.{u2, u2, u2} β β β (instHDiv.{u2} β _inst_10) x y)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (GroupWithZero.toDivInvMonoid.{u1} α (DivisionSemiring.toGroupWithZero.{u1} α (Semifield.toDivisionSemiring.{u1} α (LinearOrderedSemifield.toSemifield.{u1} α _inst_1)))))) (f x) (f y))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HasSmul.smul.{0, u2} Nat β _inst_7 n x)) (HasSmul.smul.{0, u1} Nat α (AddMonoid.SMul.{u1} α (AddMonoidWithOne.toAddMonoid.{u1} α (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} α (NonAssocSemiring.toAddCommMonoidWithOne.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1))))))))) n (f x))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Nat β (instHPow.{u2, 0} β Nat _inst_6) x n)) (HPow.hPow.{u1, 0, u1} α Nat α (instHPow.{u1, 0} α Nat (Monoid.Pow.{u1} α (MonoidWithZero.toMonoid.{u1} α (Semiring.toMonoidWithZero.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))))))) (f x) n)) -> (forall (x : β) (n : Int), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Int β (instHPow.{u2, 0} β Int _inst_11) x n)) (HPow.hPow.{u1, 0, u1} α Int α (instHPow.{u1, 0} α Int (DivInvMonoid.Pow.{u1} α (GroupWithZero.toDivInvMonoid.{u1} α (DivisionSemiring.toGroupWithZero.{u1} α (Semifield.toDivisionSemiring.{u1} α (LinearOrderedSemifield.toSemifield.{u1} α _inst_1)))))) (f x) n)) -> (forall (n : Nat), Eq.{succ u1} α (f ((fun (a : Type) (b : Type.{u2}) [self : HasLiftT.{1, succ u2} a b] => self.0) Nat β (HasLiftT.mk.{1, succ u2} Nat β (CoeTCₓ.coe.{1, succ u2} Nat β (Nat.castCoe.{u2} β _inst_8))) n)) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Nat α (HasLiftT.mk.{1, succ u1} Nat α (CoeTCₓ.coe.{1, succ u1} Nat α (Nat.castCoe.{u1} α (AddMonoidWithOne.toNatCast.{u1} α (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} α (NonAssocSemiring.toAddCommMonoidWithOne.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1))))))))))) n)) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasSup.sup.{u2} β _inst_12 x y)) (LinearOrder.max.{u1} α (LinearOrderedAddCommMonoid.toLinearOrder.{u1} α (LinearOrderedSemiring.toLinearOrderedAddCommMonoid.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasInf.inf.{u2} β _inst_13 x y)) (LinearOrder.min.{u1} α (LinearOrderedAddCommMonoid.toLinearOrder.{u1} α (LinearOrderedSemiring.toLinearOrderedAddCommMonoid.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))) (f x) (f y))) -> (LinearOrderedSemifield.{u2} β)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrderedSemifield.{u1} α] [_inst_2 : Zero.{u2} β] [_inst_3 : One.{u2} β] [_inst_4 : Add.{u2} β] [_inst_5 : Mul.{u2} β] [_inst_6 : Pow.{u2, 0} β Nat] [_inst_7 : SMul.{0, u2} Nat β] [_inst_8 : NatCast.{u2} β] [_inst_9 : Inv.{u2} β] [_inst_10 : Div.{u2} β] [_inst_11 : Pow.{u2, 0} β Int] [_inst_12 : HasSup.{u2} β] [_inst_13 : HasInf.{u2} β] (f : β -> α), (Function.Injective.{succ u2, succ u1} β α f) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 0 (Zero.toOfNat0.{u2} β _inst_2))) (OfNat.ofNat.{u1} α 0 (Zero.toOfNat0.{u1} α (CommMonoidWithZero.toZero.{u1} α (CommGroupWithZero.toCommMonoidWithZero.{u1} α (Semifield.toCommGroupWithZero.{u1} α (LinearOrderedSemifield.toSemifield.{u1} α _inst_1))))))) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 1 (One.toOfNat1.{u2} β _inst_3))) (OfNat.ofNat.{u1} α 1 (One.toOfNat1.{u1} α (Semiring.toOne.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))))))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HAdd.hAdd.{u2, u2, u2} β β β (instHAdd.{u2} β _inst_4) x y)) (HAdd.hAdd.{u1, u1, u1} α α α (instHAdd.{u1} α (Distrib.toAdd.{u1} α (NonUnitalNonAssocSemiring.toDistrib.{u1} α (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1))))))))) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HMul.hMul.{u2, u2, u2} β β β (instHMul.{u2} β _inst_5) x y)) (HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (NonUnitalNonAssocSemiring.toMul.{u1} α (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))))))) (f x) (f y))) -> (forall (x : β), Eq.{succ u1} α (f (Inv.inv.{u2} β _inst_9 x)) (Inv.inv.{u1} α (LinearOrderedSemifield.toInv.{u1} α _inst_1) (f x))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HDiv.hDiv.{u2, u2, u2} β β β (instHDiv.{u2} β _inst_10) x y)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (LinearOrderedSemifield.toDiv.{u1} α _inst_1)) (f x) (f y))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HSMul.hSMul.{0, u2, u2} Nat β β (instHSMul.{0, u2} Nat β _inst_7) n x)) (HSMul.hSMul.{0, u1, u1} Nat α α (instHSMul.{0, u1} Nat α (AddMonoid.SMul.{u1} α (AddMonoidWithOne.toAddMonoid.{u1} α (AddCommMonoidWithOne.toAddMonoidWithOne.{u1} α (NonAssocSemiring.toAddCommMonoidWithOne.{u1} α (Semiring.toNonAssocSemiring.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))))))))) n (f x))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Nat β (instHPow.{u2, 0} β Nat _inst_6) x n)) (HPow.hPow.{u1, 0, u1} α Nat α (instHPow.{u1, 0} α Nat (Monoid.Pow.{u1} α (MonoidWithZero.toMonoid.{u1} α (Semiring.toMonoidWithZero.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)))))))) (f x) n)) -> (forall (x : β) (n : Int), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Int β (instHPow.{u2, 0} β Int _inst_11) x n)) (HPow.hPow.{u1, 0, u1} α Int α (instHPow.{u1, 0} α Int (DivInvMonoid.Pow.{u1} α (GroupWithZero.toDivInvMonoid.{u1} α (DivisionSemiring.toGroupWithZero.{u1} α (Semifield.toDivisionSemiring.{u1} α (LinearOrderedSemifield.toSemifield.{u1} α _inst_1)))))) (f x) n)) -> (forall (n : Nat), Eq.{succ u1} α (f (Nat.cast.{u2} β _inst_8 n)) (Nat.cast.{u1} α (Semiring.toNatCast.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1))))) n)) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasSup.sup.{u2} β _inst_12 x y)) (Max.max.{u1} α (LinearOrderedCommSemiring.toMax.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasInf.inf.{u2} β _inst_13 x y)) (Min.min.{u1} α (LinearOrderedCommSemiring.toMin.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α _inst_1)) (f x) (f y))) -> (LinearOrderedSemifield.{u2} β)
Case conversion may be inaccurate. Consider using '#align function.injective.linear_ordered_semifield Function.Injective.linearOrderedSemifieldₓ'. -/
-- See note [reducible non-instances]
/-- Pullback a `linear_ordered_semifield` under an injective map. -/
@[reducible]
def Injective.linearOrderedSemifield [LinearOrderedSemifield α] [Zero β] [One β] [Add β] [Mul β]
    [Pow β ℕ] [HasSmul ℕ β] [NatCast β] [Inv β] [Div β] [Pow β ℤ] [HasSup β] [HasInf β] (f : β → α)
    (hf : Injective f) (zero : f 0 = 0) (one : f 1 = 1) (add : ∀ x y, f (x + y) = f x + f y)
    (mul : ∀ x y, f (x * y) = f x * f y) (inv : ∀ x, f x⁻¹ = (f x)⁻¹)
    (div : ∀ x y, f (x / y) = f x / f y) (nsmul : ∀ (x) (n : ℕ), f (n • x) = n • f x)
    (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n) (zpow : ∀ (x) (n : ℤ), f (x ^ n) = f x ^ n)
    (nat_cast : ∀ n : ℕ, f n = n) (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y))
    (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) : LinearOrderedSemifield β :=
  { hf.LinearOrderedSemiring f zero one add mul nsmul npow nat_cast hsup hinf,
    hf.Semifield f zero one add mul inv div nsmul npow zpow nat_cast with }
#align function.injective.linear_ordered_semifield Function.Injective.linearOrderedSemifield

/- warning: function.injective.linear_ordered_field -> Function.Injective.linearOrderedField is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrderedField.{u1} α] [_inst_2 : Zero.{u2} β] [_inst_3 : One.{u2} β] [_inst_4 : Add.{u2} β] [_inst_5 : Mul.{u2} β] [_inst_6 : Neg.{u2} β] [_inst_7 : Sub.{u2} β] [_inst_8 : Pow.{u2, 0} β Nat] [_inst_9 : HasSmul.{0, u2} Nat β] [_inst_10 : HasSmul.{0, u2} Int β] [_inst_11 : HasSmul.{0, u2} Rat β] [_inst_12 : NatCast.{u2} β] [_inst_13 : IntCast.{u2} β] [_inst_14 : RatCast.{u2} β] [_inst_15 : Inv.{u2} β] [_inst_16 : Div.{u2} β] [_inst_17 : Pow.{u2, 0} β Int] [_inst_18 : HasSup.{u2} β] [_inst_19 : HasInf.{u2} β] (f : β -> α), (Function.Injective.{succ u2, succ u1} β α f) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 0 (OfNat.mk.{u2} β 0 (Zero.zero.{u2} β _inst_2)))) (OfNat.ofNat.{u1} α 0 (OfNat.mk.{u1} α 0 (Zero.zero.{u1} α (MulZeroClass.toHasZero.{u1} α (NonUnitalNonAssocSemiring.toMulZeroClass.{u1} α (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} α (NonAssocRing.toNonUnitalNonAssocRing.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))))))) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 1 (OfNat.mk.{u2} β 1 (One.one.{u2} β _inst_3)))) (OfNat.ofNat.{u1} α 1 (OfNat.mk.{u1} α 1 (One.one.{u1} α (AddMonoidWithOne.toOne.{u1} α (AddGroupWithOne.toAddMonoidWithOne.{u1} α (NonAssocRing.toAddGroupWithOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1)))))))))))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HAdd.hAdd.{u2, u2, u2} β β β (instHAdd.{u2} β _inst_4) x y)) (HAdd.hAdd.{u1, u1, u1} α α α (instHAdd.{u1} α (Distrib.toHasAdd.{u1} α (Ring.toDistrib.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HMul.hMul.{u2, u2, u2} β β β (instHMul.{u2} β _inst_5) x y)) (HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (Distrib.toHasMul.{u1} α (Ring.toDistrib.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))) (f x) (f y))) -> (forall (x : β), Eq.{succ u1} α (f (Neg.neg.{u2} β _inst_6 x)) (Neg.neg.{u1} α (SubNegMonoid.toHasNeg.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddGroupWithOne.toAddGroup.{u1} α (NonAssocRing.toAddGroupWithOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))) (f x))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HSub.hSub.{u2, u2, u2} β β β (instHSub.{u2} β _inst_7) x y)) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (SubNegMonoid.toHasSub.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddGroupWithOne.toAddGroup.{u1} α (NonAssocRing.toAddGroupWithOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1)))))))))) (f x) (f y))) -> (forall (x : β), Eq.{succ u1} α (f (Inv.inv.{u2} β _inst_15 x)) (Inv.inv.{u1} α (DivInvMonoid.toHasInv.{u1} α (DivisionRing.toDivInvMonoid.{u1} α (Field.toDivisionRing.{u1} α (LinearOrderedField.toField.{u1} α _inst_1)))) (f x))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HDiv.hDiv.{u2, u2, u2} β β β (instHDiv.{u2} β _inst_16) x y)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (DivInvMonoid.toHasDiv.{u1} α (DivisionRing.toDivInvMonoid.{u1} α (Field.toDivisionRing.{u1} α (LinearOrderedField.toField.{u1} α _inst_1))))) (f x) (f y))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HasSmul.smul.{0, u2} Nat β _inst_9 n x)) (HasSmul.smul.{0, u1} Nat α (AddMonoid.SMul.{u1} α (AddMonoidWithOne.toAddMonoid.{u1} α (AddGroupWithOne.toAddMonoidWithOne.{u1} α (NonAssocRing.toAddGroupWithOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))) n (f x))) -> (forall (x : β) (n : Int), Eq.{succ u1} α (f (HasSmul.smul.{0, u2} Int β _inst_10 n x)) (HasSmul.smul.{0, u1} Int α (SubNegMonoid.hasSmulInt.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddGroupWithOne.toAddGroup.{u1} α (NonAssocRing.toAddGroupWithOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))) n (f x))) -> (forall (x : β) (n : Rat), Eq.{succ u1} α (f (HasSmul.smul.{0, u2} Rat β _inst_11 n x)) (HasSmul.smul.{0, u1} Rat α (Rat.smulDivisionRing.{u1} α (Field.toDivisionRing.{u1} α (LinearOrderedField.toField.{u1} α _inst_1))) n (f x))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Nat β (instHPow.{u2, 0} β Nat _inst_8) x n)) (HPow.hPow.{u1, 0, u1} α Nat α (instHPow.{u1, 0} α Nat (Monoid.Pow.{u1} α (Ring.toMonoid.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))) (f x) n)) -> (forall (x : β) (n : Int), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Int β (instHPow.{u2, 0} β Int _inst_17) x n)) (HPow.hPow.{u1, 0, u1} α Int α (instHPow.{u1, 0} α Int (DivInvMonoid.Pow.{u1} α (DivisionRing.toDivInvMonoid.{u1} α (Field.toDivisionRing.{u1} α (LinearOrderedField.toField.{u1} α _inst_1))))) (f x) n)) -> (forall (n : Nat), Eq.{succ u1} α (f ((fun (a : Type) (b : Type.{u2}) [self : HasLiftT.{1, succ u2} a b] => self.0) Nat β (HasLiftT.mk.{1, succ u2} Nat β (CoeTCₓ.coe.{1, succ u2} Nat β (Nat.castCoe.{u2} β _inst_12))) n)) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Nat α (HasLiftT.mk.{1, succ u1} Nat α (CoeTCₓ.coe.{1, succ u1} Nat α (Nat.castCoe.{u1} α (AddMonoidWithOne.toNatCast.{u1} α (AddGroupWithOne.toAddMonoidWithOne.{u1} α (NonAssocRing.toAddGroupWithOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))))) n)) -> (forall (n : Int), Eq.{succ u1} α (f ((fun (a : Type) (b : Type.{u2}) [self : HasLiftT.{1, succ u2} a b] => self.0) Int β (HasLiftT.mk.{1, succ u2} Int β (CoeTCₓ.coe.{1, succ u2} Int β (Int.castCoe.{u2} β _inst_13))) n)) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Int α (HasLiftT.mk.{1, succ u1} Int α (CoeTCₓ.coe.{1, succ u1} Int α (Int.castCoe.{u1} α (AddGroupWithOne.toHasIntCast.{u1} α (NonAssocRing.toAddGroupWithOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1)))))))))) n)) -> (forall (n : Rat), Eq.{succ u1} α (f ((fun (a : Type) (b : Type.{u2}) [self : HasLiftT.{1, succ u2} a b] => self.0) Rat β (HasLiftT.mk.{1, succ u2} Rat β (CoeTCₓ.coe.{1, succ u2} Rat β (Rat.castCoe.{u2} β _inst_14))) n)) ((fun (a : Type) (b : Type.{u1}) [self : HasLiftT.{1, succ u1} a b] => self.0) Rat α (HasLiftT.mk.{1, succ u1} Rat α (CoeTCₓ.coe.{1, succ u1} Rat α (Rat.castCoe.{u1} α (DivisionRing.toHasRatCast.{u1} α (Field.toDivisionRing.{u1} α (LinearOrderedField.toField.{u1} α _inst_1)))))) n)) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasSup.sup.{u2} β _inst_18 x y)) (LinearOrder.max.{u1} α (LinearOrderedRing.toLinearOrder.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasInf.inf.{u2} β _inst_19 x y)) (LinearOrder.min.{u1} α (LinearOrderedRing.toLinearOrder.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))) (f x) (f y))) -> (LinearOrderedField.{u2} β)
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrderedField.{u1} α] [_inst_2 : Zero.{u2} β] [_inst_3 : One.{u2} β] [_inst_4 : Add.{u2} β] [_inst_5 : Mul.{u2} β] [_inst_6 : Neg.{u2} β] [_inst_7 : Sub.{u2} β] [_inst_8 : Pow.{u2, 0} β Nat] [_inst_9 : SMul.{0, u2} Nat β] [_inst_10 : SMul.{0, u2} Int β] [_inst_11 : SMul.{0, u2} Rat β] [_inst_12 : NatCast.{u2} β] [_inst_13 : IntCast.{u2} β] [_inst_14 : RatCast.{u2} β] [_inst_15 : Inv.{u2} β] [_inst_16 : Div.{u2} β] [_inst_17 : Pow.{u2, 0} β Int] [_inst_18 : HasSup.{u2} β] [_inst_19 : HasInf.{u2} β] (f : β -> α), (Function.Injective.{succ u2, succ u1} β α f) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 0 (Zero.toOfNat0.{u2} β _inst_2))) (OfNat.ofNat.{u1} α 0 (Zero.toOfNat0.{u1} α (CommMonoidWithZero.toZero.{u1} α (CommGroupWithZero.toCommMonoidWithZero.{u1} α (Semifield.toCommGroupWithZero.{u1} α (LinearOrderedSemifield.toSemifield.{u1} α (LinearOrderedField.toLinearOrderedSemifield.{u1} α _inst_1)))))))) -> (Eq.{succ u1} α (f (OfNat.ofNat.{u2} β 1 (One.toOfNat1.{u2} β _inst_3))) (OfNat.ofNat.{u1} α 1 (One.toOfNat1.{u1} α (NonAssocRing.toOne.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HAdd.hAdd.{u2, u2, u2} β β β (instHAdd.{u2} β _inst_4) x y)) (HAdd.hAdd.{u1, u1, u1} α α α (instHAdd.{u1} α (Distrib.toAdd.{u1} α (NonUnitalNonAssocSemiring.toDistrib.{u1} α (NonUnitalNonAssocRing.toNonUnitalNonAssocSemiring.{u1} α (NonAssocRing.toNonUnitalNonAssocRing.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1)))))))))) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HMul.hMul.{u2, u2, u2} β β β (instHMul.{u2} β _inst_5) x y)) (HMul.hMul.{u1, u1, u1} α α α (instHMul.{u1} α (NonUnitalNonAssocRing.toMul.{u1} α (NonAssocRing.toNonUnitalNonAssocRing.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1)))))))) (f x) (f y))) -> (forall (x : β), Eq.{succ u1} α (f (Neg.neg.{u2} β _inst_6 x)) (Neg.neg.{u1} α (Ring.toNeg.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))) (f x))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HSub.hSub.{u2, u2, u2} β β β (instHSub.{u2} β _inst_7) x y)) (HSub.hSub.{u1, u1, u1} α α α (instHSub.{u1} α (Ring.toSub.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1)))))) (f x) (f y))) -> (forall (x : β), Eq.{succ u1} α (f (Inv.inv.{u2} β _inst_15 x)) (Inv.inv.{u1} α (LinearOrderedField.toInv.{u1} α _inst_1) (f x))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HDiv.hDiv.{u2, u2, u2} β β β (instHDiv.{u2} β _inst_16) x y)) (HDiv.hDiv.{u1, u1, u1} α α α (instHDiv.{u1} α (LinearOrderedField.toDiv.{u1} α _inst_1)) (f x) (f y))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HSMul.hSMul.{0, u2, u2} Nat β β (instHSMul.{0, u2} Nat β _inst_9) n x)) (HSMul.hSMul.{0, u1, u1} Nat α α (instHSMul.{0, u1} Nat α (AddMonoid.SMul.{u1} α (AddMonoidWithOne.toAddMonoid.{u1} α (AddGroupWithOne.toAddMonoidWithOne.{u1} α (Ring.toAddGroupWithOne.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))) n (f x))) -> (forall (x : β) (n : Int), Eq.{succ u1} α (f (HSMul.hSMul.{0, u2, u2} Int β β (instHSMul.{0, u2} Int β _inst_10) n x)) (HSMul.hSMul.{0, u1, u1} Int α α (instHSMul.{0, u1} Int α (SubNegMonoid.SMulInt.{u1} α (AddGroup.toSubNegMonoid.{u1} α (AddGroupWithOne.toAddGroup.{u1} α (Ring.toAddGroupWithOne.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))))))) n (f x))) -> (forall (x : β) (n : Rat), Eq.{succ u1} α (f (HSMul.hSMul.{0, u2, u2} Rat β β (instHSMul.{0, u2} Rat β _inst_11) n x)) (HSMul.hSMul.{0, u1, u1} Rat α α (instHSMul.{0, u1} Rat α (Rat.smulDivisionRing.{u1} α (Field.toDivisionRing.{u1} α (LinearOrderedField.toField.{u1} α _inst_1)))) n (f x))) -> (forall (x : β) (n : Nat), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Nat β (instHPow.{u2, 0} β Nat _inst_8) x n)) (HPow.hPow.{u1, 0, u1} α Nat α (instHPow.{u1, 0} α Nat (Monoid.Pow.{u1} α (MonoidWithZero.toMonoid.{u1} α (Semiring.toMonoidWithZero.{u1} α (StrictOrderedSemiring.toSemiring.{u1} α (LinearOrderedSemiring.toStrictOrderedSemiring.{u1} α (LinearOrderedCommSemiring.toLinearOrderedSemiring.{u1} α (LinearOrderedSemifield.toLinearOrderedCommSemiring.{u1} α (LinearOrderedField.toLinearOrderedSemifield.{u1} α _inst_1))))))))) (f x) n)) -> (forall (x : β) (n : Int), Eq.{succ u1} α (f (HPow.hPow.{u2, 0, u2} β Int β (instHPow.{u2, 0} β Int _inst_17) x n)) (HPow.hPow.{u1, 0, u1} α Int α (instHPow.{u1, 0} α Int (DivInvMonoid.Pow.{u1} α (DivisionRing.toDivInvMonoid.{u1} α (Field.toDivisionRing.{u1} α (LinearOrderedField.toField.{u1} α _inst_1))))) (f x) n)) -> (forall (n : Nat), Eq.{succ u1} α (f (Nat.cast.{u2} β _inst_12 n)) (Nat.cast.{u1} α (NonAssocRing.toNatCast.{u1} α (Ring.toNonAssocRing.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1)))))) n)) -> (forall (n : Int), Eq.{succ u1} α (f (Int.cast.{u2} β _inst_13 n)) (Int.cast.{u1} α (Ring.toIntCast.{u1} α (StrictOrderedRing.toRing.{u1} α (LinearOrderedRing.toStrictOrderedRing.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))))) n)) -> (forall (n : Rat), Eq.{succ u1} α (f (RatCast.ratCast.{u2} β _inst_14 n)) (RatCast.ratCast.{u1} α (LinearOrderedField.toRatCast.{u1} α _inst_1) n)) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasSup.sup.{u2} β _inst_18 x y)) (Max.max.{u1} α (LinearOrderedRing.toMax.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))) (f x) (f y))) -> (forall (x : β) (y : β), Eq.{succ u1} α (f (HasInf.inf.{u2} β _inst_19 x y)) (Min.min.{u1} α (LinearOrderedRing.toMin.{u1} α (LinearOrderedCommRing.toLinearOrderedRing.{u1} α (LinearOrderedField.toLinearOrderedCommRing.{u1} α _inst_1))) (f x) (f y))) -> (LinearOrderedField.{u2} β)
Case conversion may be inaccurate. Consider using '#align function.injective.linear_ordered_field Function.Injective.linearOrderedFieldₓ'. -/
-- See note [reducible non-instances]
/-- Pullback a `linear_ordered_field` under an injective map. -/
@[reducible]
def Injective.linearOrderedField [LinearOrderedField α] [Zero β] [One β] [Add β] [Mul β] [Neg β]
    [Sub β] [Pow β ℕ] [HasSmul ℕ β] [HasSmul ℤ β] [HasSmul ℚ β] [NatCast β] [IntCast β] [RatCast β]
    [Inv β] [Div β] [Pow β ℤ] [HasSup β] [HasInf β] (f : β → α) (hf : Injective f) (zero : f 0 = 0)
    (one : f 1 = 1) (add : ∀ x y, f (x + y) = f x + f y) (mul : ∀ x y, f (x * y) = f x * f y)
    (neg : ∀ x, f (-x) = -f x) (sub : ∀ x y, f (x - y) = f x - f y) (inv : ∀ x, f x⁻¹ = (f x)⁻¹)
    (div : ∀ x y, f (x / y) = f x / f y) (nsmul : ∀ (x) (n : ℕ), f (n • x) = n • f x)
    (zsmul : ∀ (x) (n : ℤ), f (n • x) = n • f x) (qsmul : ∀ (x) (n : ℚ), f (n • x) = n • f x)
    (npow : ∀ (x) (n : ℕ), f (x ^ n) = f x ^ n) (zpow : ∀ (x) (n : ℤ), f (x ^ n) = f x ^ n)
    (nat_cast : ∀ n : ℕ, f n = n) (int_cast : ∀ n : ℤ, f n = n) (rat_cast : ∀ n : ℚ, f n = n)
    (hsup : ∀ x y, f (x ⊔ y) = max (f x) (f y)) (hinf : ∀ x y, f (x ⊓ y) = min (f x) (f y)) :
    LinearOrderedField β :=
  { hf.LinearOrderedRing f zero one add mul neg sub nsmul zsmul npow nat_cast int_cast hsup hinf,
    hf.Field f zero one add mul neg sub inv div nsmul zsmul qsmul npow zpow nat_cast int_cast
      rat_cast with }
#align function.injective.linear_ordered_field Function.Injective.linearOrderedField

end Function

