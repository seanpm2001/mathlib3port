/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon, Patrick Massot, Eric Wieser

! This file was ported from Lean 3 source module group_theory.group_action.prod
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Prod
import Mathbin.GroupTheory.GroupAction.Defs

/-!
# Prod instances for additive and multiplicative actions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines instances for binary product of additive and multiplicative actions and provides
scalar multiplication as a homomorphism from `α × β` to `β`.

## Main declarations

* `smul_mul_hom`/`smul_monoid_hom`: Scalar multiplication bundled as a multiplicative/monoid
  homomorphism.

## See also

* `group_theory.group_action.option`
* `group_theory.group_action.pi`
* `group_theory.group_action.sigma`
* `group_theory.group_action.sum`
-/


variable {M N P E α β : Type _}

namespace Prod

section

variable [SMul M α] [SMul M β] [SMul N α] [SMul N β] (a : M) (x : α × β)

@[to_additive Prod.hasVadd]
instance : SMul M (α × β) :=
  ⟨fun a p => (a • p.1, a • p.2)⟩

#print Prod.smul_fst /-
@[simp, to_additive]
theorem smul_fst : (a • x).1 = a • x.1 :=
  rfl
#align prod.smul_fst Prod.smul_fst
#align prod.vadd_fst Prod.vadd_fst
-/

#print Prod.smul_snd /-
@[simp, to_additive]
theorem smul_snd : (a • x).2 = a • x.2 :=
  rfl
#align prod.smul_snd Prod.smul_snd
#align prod.vadd_snd Prod.vadd_snd
-/

#print Prod.smul_mk /-
@[simp, to_additive]
theorem smul_mk (a : M) (b : α) (c : β) : a • (b, c) = (a • b, a • c) :=
  rfl
#align prod.smul_mk Prod.smul_mk
#align prod.vadd_mk Prod.vadd_mk
-/

#print Prod.smul_def /-
@[to_additive]
theorem smul_def (a : M) (x : α × β) : a • x = (a • x.1, a • x.2) :=
  rfl
#align prod.smul_def Prod.smul_def
#align prod.vadd_def Prod.vadd_def
-/

#print Prod.smul_swap /-
@[simp, to_additive]
theorem smul_swap : (a • x).symm = a • x.symm :=
  rfl
#align prod.smul_swap Prod.smul_swap
#align prod.vadd_swap Prod.vadd_swap
-/

#print Prod.smul_zero_mk /-
theorem smul_zero_mk {α : Type _} [Monoid M] [AddMonoid α] [DistribMulAction M α] (a : M) (c : β) :
    a • ((0 : α), c) = (0, a • c) := by rw [Prod.smul_mk, smul_zero]
#align prod.smul_zero_mk Prod.smul_zero_mk
-/

#print Prod.smul_mk_zero /-
theorem smul_mk_zero {β : Type _} [Monoid M] [AddMonoid β] [DistribMulAction M β] (a : M) (b : α) :
    a • (b, (0 : β)) = (a • b, 0) := by rw [Prod.smul_mk, smul_zero]
#align prod.smul_mk_zero Prod.smul_mk_zero
-/

variable [Pow α E] [Pow β E]

#print Prod.pow /-
@[to_additive SMul]
instance pow : Pow (α × β) E where pow p c := (p.1 ^ c, p.2 ^ c)
#align prod.has_pow Prod.pow
#align prod.has_smul Prod.smul
-/

#print Prod.pow_fst /-
@[simp, to_additive smul_fst, to_additive_reorder 6]
theorem pow_fst (p : α × β) (c : E) : (p ^ c).fst = p.fst ^ c :=
  rfl
#align prod.pow_fst Prod.pow_fst
#align prod.smul_fst Prod.smul_fst
-/

#print Prod.pow_snd /-
@[simp, to_additive smul_snd, to_additive_reorder 6]
theorem pow_snd (p : α × β) (c : E) : (p ^ c).snd = p.snd ^ c :=
  rfl
#align prod.pow_snd Prod.pow_snd
#align prod.smul_snd Prod.smul_snd
-/

#print Prod.pow_mk /-
/- Note that the `c` arguments to this lemmas cannot be in the more natural right-most positions due
to limitations in `to_additive` and `to_additive_reorder`, which will silently fail to reorder more
than two adjacent arguments -/
@[simp, to_additive smul_mk, to_additive_reorder 6]
theorem pow_mk (c : E) (a : α) (b : β) : Prod.mk a b ^ c = Prod.mk (a ^ c) (b ^ c) :=
  rfl
#align prod.pow_mk Prod.pow_mk
#align prod.smul_mk Prod.smul_mk
-/

#print Prod.pow_def /-
@[to_additive smul_def, to_additive_reorder 6]
theorem pow_def (p : α × β) (c : E) : p ^ c = (p.1 ^ c, p.2 ^ c) :=
  rfl
#align prod.pow_def Prod.pow_def
#align prod.smul_def Prod.smul_def
-/

#print Prod.pow_swap /-
@[simp, to_additive smul_swap, to_additive_reorder 6]
theorem pow_swap (p : α × β) (c : E) : (p ^ c).symm = p.symm ^ c :=
  rfl
#align prod.pow_swap Prod.pow_swap
#align prod.smul_swap Prod.smul_swap
-/

@[to_additive]
instance [SMul M N] [IsScalarTower M N α] [IsScalarTower M N β] : IsScalarTower M N (α × β) :=
  ⟨fun x y z => mk.inj_iff.mpr ⟨smul_assoc _ _ _, smul_assoc _ _ _⟩⟩

@[to_additive]
instance [SMulCommClass M N α] [SMulCommClass M N β] : SMulCommClass M N (α × β)
    where smul_comm r s x := mk.inj_iff.mpr ⟨smul_comm _ _ _, smul_comm _ _ _⟩

@[to_additive]
instance [SMul Mᵐᵒᵖ α] [SMul Mᵐᵒᵖ β] [IsCentralScalar M α] [IsCentralScalar M β] :
    IsCentralScalar M (α × β) :=
  ⟨fun r m => Prod.ext (op_smul_eq_smul _ _) (op_smul_eq_smul _ _)⟩

#print Prod.faithfulSMulLeft /-
@[to_additive]
instance faithfulSMulLeft [FaithfulSMul M α] [Nonempty β] : FaithfulSMul M (α × β) :=
  ⟨fun x y h =>
    let ⟨b⟩ := ‹Nonempty β›
    eq_of_smul_eq_smul fun a : α => by injection h (a, b)⟩
#align prod.has_faithful_smul_left Prod.faithfulSMulLeft
#align prod.has_faithful_vadd_left Prod.faithfulVAddLeft
-/

#print Prod.faithfulSMulRight /-
@[to_additive]
instance faithfulSMulRight [Nonempty α] [FaithfulSMul M β] : FaithfulSMul M (α × β) :=
  ⟨fun x y h =>
    let ⟨a⟩ := ‹Nonempty α›
    eq_of_smul_eq_smul fun b : β => by injection h (a, b)⟩
#align prod.has_faithful_smul_right Prod.faithfulSMulRight
#align prod.has_faithful_vadd_right Prod.faithfulVAddRight
-/

end

#print Prod.smulCommClassBoth /-
@[to_additive]
instance smulCommClassBoth [Mul N] [Mul P] [SMul M N] [SMul M P] [SMulCommClass M N N]
    [SMulCommClass M P P] : SMulCommClass M (N × P) (N × P) :=
  ⟨fun c x y => by simp [smul_def, mul_def, mul_smul_comm]⟩
#align prod.smul_comm_class_both Prod.smulCommClassBoth
#align prod.vadd_comm_class_both Prod.vaddCommClassBoth
-/

#print Prod.isScalarTowerBoth /-
instance isScalarTowerBoth [Mul N] [Mul P] [SMul M N] [SMul M P] [IsScalarTower M N N]
    [IsScalarTower M P P] : IsScalarTower M (N × P) (N × P) :=
  ⟨fun c x y => by simp [smul_def, mul_def, smul_mul_assoc]⟩
#align prod.is_scalar_tower_both Prod.isScalarTowerBoth
-/

@[to_additive]
instance {m : Monoid M} [MulAction M α] [MulAction M β] : MulAction M (α × β)
    where
  mul_smul a₁ a₂ p := mk.inj_iff.mpr ⟨mul_smul _ _ _, mul_smul _ _ _⟩
  one_smul := fun ⟨b, c⟩ => mk.inj_iff.mpr ⟨one_smul _ _, one_smul _ _⟩

instance {R M N : Type _} [Zero M] [Zero N] [SMulZeroClass R M] [SMulZeroClass R N] :
    SMulZeroClass R (M × N) where smul_zero a := mk.inj_iff.mpr ⟨smul_zero _, smul_zero _⟩

instance {R M N : Type _} [AddZeroClass M] [AddZeroClass N] [DistribSMul R M] [DistribSMul R N] :
    DistribSMul R (M × N) where smul_add a p₁ p₂ := mk.inj_iff.mpr ⟨smul_add _ _ _, smul_add _ _ _⟩

instance {R M N : Type _} {r : Monoid R} [AddMonoid M] [AddMonoid N] [DistribMulAction R M]
    [DistribMulAction R N] : DistribMulAction R (M × N) :=
  { Prod.distribSmul with }

instance {R M N : Type _} {r : Monoid R} [Monoid M] [Monoid N] [MulDistribMulAction R M]
    [MulDistribMulAction R N] : MulDistribMulAction R (M × N)
    where
  smul_mul a p₁ p₂ := mk.inj_iff.mpr ⟨smul_mul' _ _ _, smul_mul' _ _ _⟩
  smul_one a := mk.inj_iff.mpr ⟨smul_one _, smul_one _⟩

end Prod

/-! ### Scalar multiplication as a homomorphism -/


section BundledSmul

#print smulMulHom /-
/-- Scalar multiplication as a multiplicative homomorphism. -/
@[simps]
def smulMulHom [Monoid α] [Mul β] [MulAction α β] [IsScalarTower α β β] [SMulCommClass α β β] :
    α × β →ₙ* β where
  toFun a := a.1 • a.2
  map_mul' a b := (smul_mul_smul _ _ _ _).symm
#align smul_mul_hom smulMulHom
-/

#print smulMonoidHom /-
/-- Scalar multiplication as a monoid homomorphism. -/
@[simps]
def smulMonoidHom [Monoid α] [MulOneClass β] [MulAction α β] [IsScalarTower α β β]
    [SMulCommClass α β β] : α × β →* β :=
  { smulMulHom with map_one' := one_smul _ _ }
#align smul_monoid_hom smulMonoidHom
-/

end BundledSmul

