/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Simon Hudon, Mario Carneiro
-/
import Mathbin.Algebra.Group.Defs

/-!
# Basic lemmas about semigroups, monoids, and groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> https://github.com/leanprover-community/mathlib4/pull/457
> Any changes to this file require a corresponding PR to mathlib4.

This file lists various basic lemmas about semigroups, monoids, and groups. Most proofs are
one-liners from the corresponding axioms. For the definitions of semigroups, monoids and groups, see
`algebra/group/defs.lean`.
-/


open Function

universe u

variable {α β G : Type _}

section Associative

variable (f : α → α → α) [IsAssociative α f] (x y : α)

/-- Composing two associative operations of `f : α → α → α` on the left
is equal to an associative operation on the left.
-/
theorem comp_assoc_left : f x ∘ f y = f (f x y) := by
  ext z
  rw [Function.comp_apply, @IsAssociative.assoc _ f]
#align comp_assoc_left comp_assoc_left

/-- Composing two associative operations of `f : α → α → α` on the right
is equal to an associative operation on the right.
-/
theorem comp_assoc_right : ((fun z => f z x) ∘ fun z => f z y) = fun z => f z (f y x) := by
  ext z
  rw [Function.comp_apply, @IsAssociative.assoc _ f]
#align comp_assoc_right comp_assoc_right

end Associative

section Semigroup

/- warning: comp_mul_left -> comp_mul_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : Semigroup.{u_1} α] (x : α) (y : α), Eq.{succ u_1} (α -> α) (Function.comp.{succ u_1 succ u_1 succ u_1} α α α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) x) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) y)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) x y))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.17 : Semigroup.{u_1} α] (x : α) (y : α), Eq.{succ u_1} (α -> α) (Function.comp.{succ u_1 succ u_1 succ u_1} α α α (fun (x._@.Mathlib.Algebra.Group.Basic._hyg.32 : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.17)) x x._@.Mathlib.Algebra.Group.Basic._hyg.32) (fun (x._@.Mathlib.Algebra.Group.Basic._hyg.44 : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.17)) y x._@.Mathlib.Algebra.Group.Basic._hyg.44)) (fun (x._@.Mathlib.Algebra.Group.Basic._hyg.56 : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.17)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.17)) x y) x._@.Mathlib.Algebra.Group.Basic._hyg.56)
Case conversion may be inaccurate. Consider using '#align comp_mul_left comp_mul_leftₓ'. -/
/-- Composing two multiplications on the left by `y` then `x`
is equal to a multiplication on the left by `x * y`.
-/
@[simp,
  to_additive "Composing two additions on the left by `y` then `x`\nis equal to a addition on the left by `x + y`."]
theorem comp_mul_left [Semigroup α] (x y : α) : (· * ·) x ∘ (· * ·) y = (· * ·) (x * y) :=
  comp_assoc_left _ _ _
#align comp_mul_left comp_mul_left

/- warning: comp_mul_right -> comp_mul_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : Semigroup.{u_1} α] (x : α) (y : α), Eq.{succ u_1} (α -> α) (Function.comp.{succ u_1 succ u_1 succ u_1} α α α (fun (_x : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) _x x) (fun (_x : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) _x y)) (fun (_x : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) _x (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toHasMul.{u_1} α _inst_1)) y x))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.76 : Semigroup.{u_1} α] (x : α) (y : α), Eq.{succ u_1} (α -> α) (Function.comp.{succ u_1 succ u_1 succ u_1} α α α (fun (x._@.Mathlib.Algebra.Group.Basic._hyg.91 : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.76)) x._@.Mathlib.Algebra.Group.Basic._hyg.91 x) (fun (x._@.Mathlib.Algebra.Group.Basic._hyg.103 : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.76)) x._@.Mathlib.Algebra.Group.Basic._hyg.103 y)) (fun (x._@.Mathlib.Algebra.Group.Basic._hyg.115 : α) => HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.76)) x._@.Mathlib.Algebra.Group.Basic._hyg.115 (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (Semigroup.toMul.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.76)) y x))
Case conversion may be inaccurate. Consider using '#align comp_mul_right comp_mul_rightₓ'. -/
/-- Composing two multiplications on the right by `y` and `x`
is equal to a multiplication on the right by `y * x`.
-/
@[simp,
  to_additive "Composing two additions on the right by `y` and `x`\nis equal to a addition on the right by `y + x`."]
theorem comp_mul_right [Semigroup α] (x y : α) : (· * x) ∘ (· * y) = (· * (y * x)) :=
  comp_assoc_right _ _ _
#align comp_mul_right comp_mul_right

end Semigroup

section MulOneClass

variable {M : Type u} [MulOneClass M]

/- warning: ite_mul_one -> ite_mul_one is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : MulOneClass.{u} M] {P : Prop} [_inst_2 : Decidable P] {a : M} {b : M}, Eq.{succ u} M (ite.{succ u} M P _inst_2 (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M _inst_1)) a b) (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M _inst_1)) (ite.{succ u} M P _inst_2 a (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))) (ite.{succ u} M P _inst_2 b (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))))
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.148 : MulOneClass.{u} M] {P : Prop} [inst._@.Mathlib.Algebra.Group.Basic._hyg.152 : Decidable P] {a : M} {b : M}, Eq.{succ u} M (ite.{succ u} M P inst._@.Mathlib.Algebra.Group.Basic._hyg.152 (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.148)) a b) (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.148)))) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.148)) (ite.{succ u} M P inst._@.Mathlib.Algebra.Group.Basic._hyg.152 a (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.148)))) (ite.{succ u} M P inst._@.Mathlib.Algebra.Group.Basic._hyg.152 b (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.148)))))
Case conversion may be inaccurate. Consider using '#align ite_mul_one ite_mul_oneₓ'. -/
@[to_additive]
theorem ite_mul_one {P : Prop} [Decidable P] {a b : M} : ite P (a * b) 1 = ite P a 1 * ite P b 1 := by
  by_cases h : P <;> simp [h]
#align ite_mul_one ite_mul_one

/- warning: ite_one_mul -> ite_one_mul is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : MulOneClass.{u} M] {P : Prop} [_inst_2 : Decidable P] {a : M} {b : M}, Eq.{succ u} M (ite.{succ u} M P _inst_2 (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1)))) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M _inst_1)) a b)) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M _inst_1)) (ite.{succ u} M P _inst_2 (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1)))) a) (ite.{succ u} M P _inst_2 (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1)))) b))
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.224 : MulOneClass.{u} M] {P : Prop} [inst._@.Mathlib.Algebra.Group.Basic._hyg.228 : Decidable P] {a : M} {b : M}, Eq.{succ u} M (ite.{succ u} M P inst._@.Mathlib.Algebra.Group.Basic._hyg.228 (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.224))) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.224)) a b)) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.224)) (ite.{succ u} M P inst._@.Mathlib.Algebra.Group.Basic._hyg.228 (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.224))) a) (ite.{succ u} M P inst._@.Mathlib.Algebra.Group.Basic._hyg.228 (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.224))) b))
Case conversion may be inaccurate. Consider using '#align ite_one_mul ite_one_mulₓ'. -/
@[to_additive]
theorem ite_one_mul {P : Prop} [Decidable P] {a b : M} : ite P 1 (a * b) = ite P 1 a * ite P 1 b := by
  by_cases h : P <;> simp [h]
#align ite_one_mul ite_one_mul

/- warning: eq_one_iff_eq_one_of_mul_eq_one -> eq_one_iff_eq_one_of_mul_eq_one is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : MulOneClass.{u} M] {a : M} {b : M}, (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M _inst_1)) a b) (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))) -> (Iff (Eq.{succ u} M a (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))) (Eq.{succ u} M b (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))))
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.300 : MulOneClass.{u} M] {a : M} {b : M}, (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.300)) a b) (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.300)))) -> (Iff (Eq.{succ u} M a (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.300)))) (Eq.{succ u} M b (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.300)))))
Case conversion may be inaccurate. Consider using '#align eq_one_iff_eq_one_of_mul_eq_one eq_one_iff_eq_one_of_mul_eq_oneₓ'. -/
@[to_additive]
theorem eq_one_iff_eq_one_of_mul_eq_one {a b : M} (h : a * b = 1) : a = 1 ↔ b = 1 := by
  constructor <;>
    · rintro rfl
      simpa using h
      
#align eq_one_iff_eq_one_of_mul_eq_one eq_one_iff_eq_one_of_mul_eq_one

/- warning: one_mul_eq_id -> one_mul_eq_id is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : MulOneClass.{u} M], Eq.{succ u} (M -> M) (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M _inst_1)) (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))) (id.{succ u} M)
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.409 : MulOneClass.{u} M], Eq.{succ u} (M -> M) ((fun (x._@.Mathlib.Algebra.Group.Basic._hyg.419 : M) (x._@.Mathlib.Algebra.Group.Basic._hyg.421 : M) => HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.409)) x._@.Mathlib.Algebra.Group.Basic._hyg.419 x._@.Mathlib.Algebra.Group.Basic._hyg.421) (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.409)))) (id.{succ u} M)
Case conversion may be inaccurate. Consider using '#align one_mul_eq_id one_mul_eq_idₓ'. -/
@[to_additive]
theorem one_mul_eq_id : (· * ·) (1 : M) = id :=
  funext one_mul
#align one_mul_eq_id one_mul_eq_id

/- warning: mul_one_eq_id -> mul_one_eq_id is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : MulOneClass.{u} M], Eq.{succ u} (M -> M) (fun (_x : M) => HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M _inst_1)) _x (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M _inst_1))))) (id.{succ u} M)
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.443 : MulOneClass.{u} M], Eq.{succ u} (M -> M) (fun (x._@.Mathlib.Algebra.Group.Basic._hyg.452 : M) => HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.443)) x._@.Mathlib.Algebra.Group.Basic._hyg.452 (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (MulOneClass.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.443)))) (id.{succ u} M)
Case conversion may be inaccurate. Consider using '#align mul_one_eq_id mul_one_eq_idₓ'. -/
@[to_additive]
theorem mul_one_eq_id : (· * (1 : M)) = id :=
  funext mul_one
#align mul_one_eq_id mul_one_eq_id

end MulOneClass

section CommSemigroup

variable [CommSemigroup G]

/- warning: mul_left_comm -> mul_left_comm is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommSemigroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) b c)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) b (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.482 : CommSemigroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.482))) a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.482))) b c)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.482))) b (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.482))) a c))
Case conversion may be inaccurate. Consider using '#align mul_left_comm mul_left_commₓ'. -/
@[no_rsimp, to_additive]
theorem mul_left_comm : ∀ a b c : G, a * (b * c) = b * (a * c) :=
  left_comm Mul.mul mul_comm mul_assoc
#align mul_left_comm mul_left_comm

/- warning: mul_right_comm -> mul_right_comm is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommSemigroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a b) c) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a c) b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.513 : CommSemigroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.513))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.513))) a b) c) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.513))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.513))) a c) b)
Case conversion may be inaccurate. Consider using '#align mul_right_comm mul_right_commₓ'. -/
@[to_additive]
theorem mul_right_comm : ∀ a b c : G, a * b * c = a * c * b :=
  right_comm Mul.mul mul_comm mul_assoc
#align mul_right_comm mul_right_comm

/- warning: mul_mul_mul_comm -> mul_mul_mul_comm is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommSemigroup.{u_3} G] (a : G) (b : G) (c : G) (d : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a b) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) c d)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a c) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) b d))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.544 : CommSemigroup.{u_1} G] (a : G) (b : G) (c : G) (d : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.544))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.544))) a b) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.544))) c d)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.544))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.544))) a c) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.544))) b d))
Case conversion may be inaccurate. Consider using '#align mul_mul_mul_comm mul_mul_mul_commₓ'. -/
@[to_additive]
theorem mul_mul_mul_comm (a b c d : G) : a * b * (c * d) = a * c * (b * d) := by simp only [mul_left_comm, mul_assoc]
#align mul_mul_mul_comm mul_mul_mul_comm

/- warning: mul_rotate -> mul_rotate is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommSemigroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a b) c) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) b c) a)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.576 : CommSemigroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.576))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.576))) a b) c) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.576))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.576))) b c) a)
Case conversion may be inaccurate. Consider using '#align mul_rotate mul_rotateₓ'. -/
@[to_additive]
theorem mul_rotate (a b c : G) : a * b * c = b * c * a := by simp only [mul_left_comm, mul_comm]
#align mul_rotate mul_rotate

/- warning: mul_rotate' -> mul_rotate' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommSemigroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) b c)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) b (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (Semigroup.toHasMul.{u_3} G (CommSemigroup.toSemigroup.{u_3} G _inst_1))) c a))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.603 : CommSemigroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.603))) a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.603))) b c)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.603))) b (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (Semigroup.toMul.{u_1} G (CommSemigroup.toSemigroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.603))) c a))
Case conversion may be inaccurate. Consider using '#align mul_rotate' mul_rotate'ₓ'. -/
@[to_additive]
theorem mul_rotate' (a b c : G) : a * (b * c) = b * (c * a) := by simp only [mul_left_comm, mul_comm]
#align mul_rotate' mul_rotate'

end CommSemigroup

section AddCommSemigroup

variable {M : Type u} [AddCommSemigroup M]

theorem bit0_add (a b : M) : bit0 (a + b) = bit0 a + bit0 b :=
  add_add_add_comm _ _ _ _
#align bit0_add bit0_add

theorem bit1_add [One M] (a b : M) : bit1 (a + b) = bit0 a + bit1 b :=
  (congr_arg (· + (1 : M)) <| bit0_add a b : _).trans (add_assoc _ _ _)
#align bit1_add bit1_add

theorem bit1_add' [One M] (a b : M) : bit1 (a + b) = bit1 a + bit0 b := by rw [add_comm, bit1_add, add_comm]
#align bit1_add' bit1_add'

end AddCommSemigroup

attribute [local simp] mul_assoc sub_eq_add_neg

section AddMonoid

variable {M : Type u} [AddMonoid M] {a b c : M}

@[simp]
theorem bit0_zero : bit0 (0 : M) = 0 :=
  add_zero _
#align bit0_zero bit0_zero

@[simp]
theorem bit1_zero [One M] : bit1 (0 : M) = 1 := by rw [bit1, bit0_zero, zero_add]
#align bit1_zero bit1_zero

end AddMonoid

section CommMonoid

variable {M : Type u} [CommMonoid M] {x y z : M}

/- warning: inv_unique -> inv_unique is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : CommMonoid.{u} M] {x : M} {y : M} {z : M}, (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M _inst_1)))) x y) (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M _inst_1))))))) -> (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M _inst_1)))) x z) (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M _inst_1))))))) -> (Eq.{succ u} M y z)
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.650 : CommMonoid.{u} M] {x : M} {y : M} {z : M}, (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.650)))) x y) (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (Monoid.toOne.{u} M (CommMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.650))))) -> (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M (Monoid.toMulOneClass.{u} M (CommMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.650)))) x z) (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (Monoid.toOne.{u} M (CommMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.650))))) -> (Eq.{succ u} M y z)
Case conversion may be inaccurate. Consider using '#align inv_unique inv_uniqueₓ'. -/
@[to_additive]
theorem inv_unique (hy : x * y = 1) (hz : x * z = 1) : y = z :=
  left_inv_eq_right_inv (trans (mul_comm _ _) hy) hz
#align inv_unique inv_unique

end CommMonoid

section LeftCancelMonoid

variable {M : Type u} [LeftCancelMonoid M] {a b : M}

/- warning: mul_right_eq_self -> mul_right_eq_self is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : LeftCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (LeftCancelMonoid.toMonoid.{u} M _inst_1)))) a b) a) (Eq.{succ u} M b (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M (LeftCancelMonoid.toMonoid.{u} M _inst_1)))))))
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.707 : LeftCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M (Monoid.toMulOneClass.{u} M (LeftCancelMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.707)))) a b) a) (Eq.{succ u} M b (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (LeftCancelMonoid.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.707))))
Case conversion may be inaccurate. Consider using '#align mul_right_eq_self mul_right_eq_selfₓ'. -/
@[simp, to_additive]
theorem mul_right_eq_self : a * b = a ↔ b = 1 :=
  calc
    a * b = a ↔ a * b = a * 1 := by rw [mul_one]
    _ ↔ b = 1 := mul_left_cancel_iff
    
#align mul_right_eq_self mul_right_eq_self

/- warning: self_eq_mul_right -> self_eq_mul_right is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : LeftCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M a (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (LeftCancelMonoid.toMonoid.{u} M _inst_1)))) a b)) (Eq.{succ u} M b (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M (LeftCancelMonoid.toMonoid.{u} M _inst_1)))))))
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.792 : LeftCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M a (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M (Monoid.toMulOneClass.{u} M (LeftCancelMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.792)))) a b)) (Eq.{succ u} M b (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (LeftCancelMonoid.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.792))))
Case conversion may be inaccurate. Consider using '#align self_eq_mul_right self_eq_mul_rightₓ'. -/
@[simp, to_additive]
theorem self_eq_mul_right : a = a * b ↔ b = 1 :=
  eq_comm.trans mul_right_eq_self
#align self_eq_mul_right self_eq_mul_right

end LeftCancelMonoid

section RightCancelMonoid

variable {M : Type u} [RightCancelMonoid M] {a b : M}

/- warning: mul_left_eq_self -> mul_left_eq_self is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : RightCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (RightCancelMonoid.toMonoid.{u} M _inst_1)))) a b) b) (Eq.{succ u} M a (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M (RightCancelMonoid.toMonoid.{u} M _inst_1)))))))
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.835 : RightCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M (Monoid.toMulOneClass.{u} M (RightCancelMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.835)))) a b) b) (Eq.{succ u} M a (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (RightCancelMonoid.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.835))))
Case conversion may be inaccurate. Consider using '#align mul_left_eq_self mul_left_eq_selfₓ'. -/
@[simp, to_additive]
theorem mul_left_eq_self : a * b = b ↔ a = 1 :=
  calc
    a * b = b ↔ a * b = 1 * b := by rw [one_mul]
    _ ↔ a = 1 := mul_right_cancel_iff
    
#align mul_left_eq_self mul_left_eq_self

/- warning: self_eq_mul_left -> self_eq_mul_left is a dubious translation:
lean 3 declaration is
  forall {M : Type.{u}} [_inst_1 : RightCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M b (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toHasMul.{u} M (Monoid.toMulOneClass.{u} M (RightCancelMonoid.toMonoid.{u} M _inst_1)))) a b)) (Eq.{succ u} M a (OfNat.ofNat.{u} M 1 (OfNat.mk.{u} M 1 (One.one.{u} M (MulOneClass.toHasOne.{u} M (Monoid.toMulOneClass.{u} M (RightCancelMonoid.toMonoid.{u} M _inst_1)))))))
but is expected to have type
  forall {M : Type.{u}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.920 : RightCancelMonoid.{u} M] {a : M} {b : M}, Iff (Eq.{succ u} M b (HMul.hMul.{u u u} M M M (instHMul.{u} M (MulOneClass.toMul.{u} M (Monoid.toMulOneClass.{u} M (RightCancelMonoid.toMonoid.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.920)))) a b)) (Eq.{succ u} M a (OfNat.ofNat.{u} M 1 (One.toOfNat1.{u} M (RightCancelMonoid.toOne.{u} M inst._@.Mathlib.Algebra.Group.Basic._hyg.920))))
Case conversion may be inaccurate. Consider using '#align self_eq_mul_left self_eq_mul_leftₓ'. -/
@[simp, to_additive]
theorem self_eq_mul_left : b = a * b ↔ a = 1 :=
  eq_comm.trans mul_left_eq_self
#align self_eq_mul_left self_eq_mul_left

end RightCancelMonoid

section HasInvolutiveInv

variable [HasInvolutiveInv G] {a b : G}

/- warning: inv_involutive -> inv_involutive is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : HasInvolutiveInv.{u_3} G], Function.Involutive.{succ u_3} G (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.960 : HasInvolutiveInv.{u_1} G], Function.Involutive.{succ u_1} G (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.960))
Case conversion may be inaccurate. Consider using '#align inv_involutive inv_involutiveₓ'. -/
@[simp, to_additive]
theorem inv_involutive : Function.Involutive (Inv.inv : G → G) :=
  inv_inv
#align inv_involutive inv_involutive

/- warning: inv_surjective -> inv_surjective is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : HasInvolutiveInv.{u_3} G], Function.Surjective.{succ u_3 succ u_3} G G (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.977 : HasInvolutiveInv.{u_1} G], Function.Surjective.{succ u_1 succ u_1} G G (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.977))
Case conversion may be inaccurate. Consider using '#align inv_surjective inv_surjectiveₓ'. -/
@[simp, to_additive]
theorem inv_surjective : Function.Surjective (Inv.inv : G → G) :=
  inv_involutive.Surjective
#align inv_surjective inv_surjective

/- warning: inv_injective -> inv_injective is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : HasInvolutiveInv.{u_3} G], Function.Injective.{succ u_3 succ u_3} G G (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.994 : HasInvolutiveInv.{u_1} G], Function.Injective.{succ u_1 succ u_1} G G (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.994))
Case conversion may be inaccurate. Consider using '#align inv_injective inv_injectiveₓ'. -/
@[to_additive]
theorem inv_injective : Function.Injective (Inv.inv : G → G) :=
  inv_involutive.Injective
#align inv_injective inv_injective

/- warning: inv_inj -> inv_inj is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : HasInvolutiveInv.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a) (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) b)) (Eq.{succ u_3} G a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1011 : HasInvolutiveInv.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1011) a) (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1011) b)) (Eq.{succ u_1} G a b)
Case conversion may be inaccurate. Consider using '#align inv_inj inv_injₓ'. -/
@[simp, to_additive]
theorem inv_inj {a b : G} : a⁻¹ = b⁻¹ ↔ a = b :=
  inv_injective.eq_iff
#align inv_inj inv_inj

/- warning: eq_inv_of_eq_inv -> eq_inv_of_eq_inv is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : HasInvolutiveInv.{u_3} G] {a : G} {b : G}, (Eq.{succ u_3} G a (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) b)) -> (Eq.{succ u_3} G b (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1044 : HasInvolutiveInv.{u_1} G] {a : G} {b : G}, (Eq.{succ u_1} G a (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1044) b)) -> (Eq.{succ u_1} G b (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1044) a))
Case conversion may be inaccurate. Consider using '#align eq_inv_of_eq_inv eq_inv_of_eq_invₓ'. -/
@[to_additive]
theorem eq_inv_of_eq_inv (h : a = b⁻¹) : b = a⁻¹ := by simp [h]
#align eq_inv_of_eq_inv eq_inv_of_eq_inv

/- warning: eq_inv_iff_eq_inv -> eq_inv_iff_eq_inv is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : HasInvolutiveInv.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G a (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) b)) (Eq.{succ u_3} G b (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1075 : HasInvolutiveInv.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G a (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1075) b)) (Eq.{succ u_1} G b (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1075) a))
Case conversion may be inaccurate. Consider using '#align eq_inv_iff_eq_inv eq_inv_iff_eq_invₓ'. -/
@[to_additive]
theorem eq_inv_iff_eq_inv : a = b⁻¹ ↔ b = a⁻¹ :=
  ⟨eq_inv_of_eq_inv, eq_inv_of_eq_inv⟩
#align eq_inv_iff_eq_inv eq_inv_iff_eq_inv

/- warning: inv_eq_iff_inv_eq -> inv_eq_iff_inv_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : HasInvolutiveInv.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a) b) (Eq.{succ u_3} G (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) b) a)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1109 : HasInvolutiveInv.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1109) a) b) (Eq.{succ u_1} G (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1109) b) a)
Case conversion may be inaccurate. Consider using '#align inv_eq_iff_inv_eq inv_eq_iff_inv_eqₓ'. -/
@[to_additive]
theorem inv_eq_iff_inv_eq : a⁻¹ = b ↔ b⁻¹ = a :=
  eq_comm.trans <| eq_inv_iff_eq_inv.trans eq_comm
#align inv_eq_iff_inv_eq inv_eq_iff_inv_eq

variable (G)

/- warning: inv_comp_inv -> inv_comp_inv is a dubious translation:
lean 3 declaration is
  forall (G : Type.{u_3}) [_inst_1 : HasInvolutiveInv.{u_3} G], Eq.{succ u_3} (G -> G) (Function.comp.{succ u_3 succ u_3 succ u_3} G G G (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1)) (Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1))) (id.{succ u_3} G)
but is expected to have type
  forall (G : Type.{u_1}) [inst._@.Mathlib.Algebra.Group.Basic._hyg.1154 : HasInvolutiveInv.{u_1} G], Eq.{succ u_1} (G -> G) (Function.comp.{succ u_1 succ u_1 succ u_1} G G G (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1154)) (Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1154))) (id.{succ u_1} G)
Case conversion may be inaccurate. Consider using '#align inv_comp_inv inv_comp_invₓ'. -/
@[simp, to_additive]
theorem inv_comp_inv : Inv.inv ∘ Inv.inv = @id G :=
  inv_involutive.comp_self
#align inv_comp_inv inv_comp_inv

/- warning: left_inverse_inv -> leftInverse_inv is a dubious translation:
lean 3 declaration is
  forall (G : Type.{u_3}) [_inst_1 : HasInvolutiveInv.{u_3} G], Function.LeftInverse.{succ u_3 succ u_3} G G (fun (a : G) => Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a) (fun (a : G) => Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a)
but is expected to have type
  forall (G : Type.{u_1}) [inst._@.Mathlib.Algebra.Group.Basic._hyg.1175 : HasInvolutiveInv.{u_1} G], Function.LeftInverse.{succ u_1 succ u_1} G G (fun (a : G) => Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1175) a) (fun (a : G) => Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1175) a)
Case conversion may be inaccurate. Consider using '#align left_inverse_inv leftInverse_invₓ'. -/
@[to_additive]
theorem leftInverse_inv : LeftInverse (fun a : G => a⁻¹) fun a => a⁻¹ :=
  inv_inv
#align left_inverse_inv leftInverse_inv

/- warning: right_inverse_inv -> rightInverse_inv is a dubious translation:
lean 3 declaration is
  forall (G : Type.{u_3}) [_inst_1 : HasInvolutiveInv.{u_3} G], Function.LeftInverse.{succ u_3 succ u_3} G G (fun (a : G) => Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a) (fun (a : G) => Inv.inv.{u_3} G (HasInvolutiveInv.toHasInv.{u_3} G _inst_1) a)
but is expected to have type
  forall (G : Type.{u_1}) [inst._@.Mathlib.Algebra.Group.Basic._hyg.1206 : HasInvolutiveInv.{u_1} G], Function.LeftInverse.{succ u_1 succ u_1} G G (fun (a : G) => Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1206) a) (fun (a : G) => Inv.inv.{u_1} G (HasInvolutiveInv.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1206) a)
Case conversion may be inaccurate. Consider using '#align right_inverse_inv rightInverse_invₓ'. -/
@[to_additive]
theorem rightInverse_inv : LeftInverse (fun a : G => a⁻¹) fun a => a⁻¹ :=
  inv_inv
#align right_inverse_inv rightInverse_inv

end HasInvolutiveInv

section DivInvMonoid

variable [DivInvMonoid G] {a b c : G}

/- warning: inv_eq_one_div -> inv_eq_one_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvMonoid.{u_3} G] (x : G), Eq.{succ u_3} G (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G _inst_1) x) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))))) x)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1253 : DivInvMonoid.{u_1} G] (x : G), Eq.{succ u_1} G (Inv.inv.{u_1} G (DivInvMonoid.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1253) x) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1253)) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (Monoid.toOne.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1253)))) x)
Case conversion may be inaccurate. Consider using '#align inv_eq_one_div inv_eq_one_divₓ'. -/
-- The attributes are out of order on purpose
@[to_additive, field_simps]
theorem inv_eq_one_div (x : G) : x⁻¹ = 1 / x := by rw [div_eq_mul_inv, one_mul]
#align inv_eq_one_div inv_eq_one_div

/- warning: mul_one_div -> mul_one_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvMonoid.{u_3} G] (x : G) (y : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) x (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))))) y)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) x y)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1305 : DivInvMonoid.{u_1} G] (x : G) (y : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1305)))) x (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1305)) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (Monoid.toOne.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1305)))) y)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1305)) x y)
Case conversion may be inaccurate. Consider using '#align mul_one_div mul_one_divₓ'. -/
@[to_additive]
theorem mul_one_div (x y : G) : x * (1 / y) = x / y := by rw [div_eq_mul_inv, one_mul, div_eq_mul_inv]
#align mul_one_div mul_one_div

/- warning: mul_div_assoc -> mul_div_assoc is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvMonoid.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) a b) c) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1359 : DivInvMonoid.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1359)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1359)))) a b) c) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1359)))) a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1359)) b c))
Case conversion may be inaccurate. Consider using '#align mul_div_assoc mul_div_assocₓ'. -/
@[to_additive]
theorem mul_div_assoc (a b c : G) : a * b / c = a * (b / c) := by rw [div_eq_mul_inv, div_eq_mul_inv, mul_assoc _ _ _]
#align mul_div_assoc mul_div_assoc

/- warning: mul_div_assoc' -> mul_div_assoc' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvMonoid.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) b c)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1419 : DivInvMonoid.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1419)))) a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1419)) b c)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1419)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1419)))) a b) c)
Case conversion may be inaccurate. Consider using '#align mul_div_assoc' mul_div_assoc'ₓ'. -/
-- The attributes are out of order on purpose
@[to_additive, field_simps]
theorem mul_div_assoc' (a b c : G) : a * (b / c) = a * b / c :=
  (mul_div_assoc _ _ _).symm
#align mul_div_assoc' mul_div_assoc'

/- warning: one_div -> one_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvMonoid.{u_3} G] (a : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))))) a) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G _inst_1) a)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1452 : DivInvMonoid.{u_1} G] (a : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1452)) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (Monoid.toOne.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1452)))) a) (Inv.inv.{u_1} G (DivInvMonoid.toInv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1452) a)
Case conversion may be inaccurate. Consider using '#align one_div one_divₓ'. -/
@[simp, to_additive]
theorem one_div (a : G) : 1 / a = a⁻¹ :=
  (inv_eq_one_div a).symm
#align one_div one_div

/- warning: mul_div -> mul_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvMonoid.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) b c)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1479 : DivInvMonoid.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1479)))) a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1479)) b c)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1479)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1479)))) a b) c)
Case conversion may be inaccurate. Consider using '#align mul_div mul_divₓ'. -/
@[to_additive]
theorem mul_div (a b c : G) : a * (b / c) = a * b / c := by simp only [mul_assoc, div_eq_mul_inv]
#align mul_div mul_div

/- warning: div_eq_mul_one_div -> div_eq_mul_one_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvMonoid.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) a b) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))) a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G _inst_1)) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G _inst_1)))))) b))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1509 : DivInvMonoid.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1509)) a b) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1509)))) a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1509)) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (Monoid.toOne.{u_1} G (DivInvMonoid.toMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1509)))) b))
Case conversion may be inaccurate. Consider using '#align div_eq_mul_one_div div_eq_mul_one_divₓ'. -/
@[to_additive]
theorem div_eq_mul_one_div (a b : G) : a / b = a * (1 / b) := by rw [div_eq_mul_inv, one_div]
#align div_eq_mul_one_div div_eq_mul_one_div

end DivInvMonoid

section DivInvOneMonoid

variable [DivInvOneMonoid G]

/- warning: div_one -> div_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvOneMonoid.{u_3} G] (a : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (DivInvOneMonoid.toDivInvMonoid.{u_3} G _inst_1))) a (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (DivInvOneMonoid.toDivInvMonoid.{u_3} G _inst_1)))))))) a
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1572 : DivInvOneMonoid.{u_1} G] (a : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (DivInvOneMonoid.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1572))) a (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1572))))) a
Case conversion may be inaccurate. Consider using '#align div_one div_oneₓ'. -/
@[simp, to_additive]
theorem div_one (a : G) : a / 1 = a := by simp [div_eq_mul_inv]
#align div_one div_one

/- warning: one_div_one -> one_div_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : DivInvOneMonoid.{u_3} G], Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (DivInvOneMonoid.toDivInvMonoid.{u_3} G _inst_1))) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (DivInvOneMonoid.toDivInvMonoid.{u_3} G _inst_1))))))) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (DivInvOneMonoid.toDivInvMonoid.{u_3} G _inst_1)))))))) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (DivInvOneMonoid.toDivInvMonoid.{u_3} G _inst_1)))))))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1591 : DivInvOneMonoid.{u_1} G], Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (DivInvOneMonoid.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1591))) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1591)))) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1591))))) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.1591))))
Case conversion may be inaccurate. Consider using '#align one_div_one one_div_oneₓ'. -/
@[to_additive]
theorem one_div_one : (1 : G) / 1 = 1 :=
  div_one _
#align one_div_one one_div_one

end DivInvOneMonoid

section DivisionMonoid

variable [DivisionMonoid α] {a b c : α}

attribute [local simp] mul_assoc div_eq_mul_inv

/- warning: inv_eq_of_mul_eq_one_left -> inv_eq_of_mul_eq_one_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) a b) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) -> (Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) b) a)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1628 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1628))))) a b) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1628)))))) -> (Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1628)) b) a)
Case conversion may be inaccurate. Consider using '#align inv_eq_of_mul_eq_one_left inv_eq_of_mul_eq_one_leftₓ'. -/
@[to_additive]
theorem inv_eq_of_mul_eq_one_left (h : a * b = 1) : b⁻¹ = a := by rw [← inv_eq_of_mul_eq_one_right h, inv_inv]
#align inv_eq_of_mul_eq_one_left inv_eq_of_mul_eq_one_left

/- warning: eq_inv_of_mul_eq_one_left -> eq_inv_of_mul_eq_one_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) a b) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) -> (Eq.{succ u_1} α a (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) b))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1685 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1685))))) a b) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1685)))))) -> (Eq.{succ u_1} α a (Inv.inv.{u_1} α (DivInvMonoid.toInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1685)) b))
Case conversion may be inaccurate. Consider using '#align eq_inv_of_mul_eq_one_left eq_inv_of_mul_eq_one_leftₓ'. -/
@[to_additive]
theorem eq_inv_of_mul_eq_one_left (h : a * b = 1) : a = b⁻¹ :=
  (inv_eq_of_mul_eq_one_left h).symm
#align eq_inv_of_mul_eq_one_left eq_inv_of_mul_eq_one_left

/- warning: eq_inv_of_mul_eq_one_right -> eq_inv_of_mul_eq_one_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) a b) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) -> (Eq.{succ u_1} α b (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) a))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1716 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1716))))) a b) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1716)))))) -> (Eq.{succ u_1} α b (Inv.inv.{u_1} α (DivInvMonoid.toInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1716)) a))
Case conversion may be inaccurate. Consider using '#align eq_inv_of_mul_eq_one_right eq_inv_of_mul_eq_one_rightₓ'. -/
@[to_additive]
theorem eq_inv_of_mul_eq_one_right (h : a * b = 1) : b = a⁻¹ :=
  (inv_eq_of_mul_eq_one_right h).symm
#align eq_inv_of_mul_eq_one_right eq_inv_of_mul_eq_one_right

/- warning: eq_one_div_of_mul_eq_one_left -> eq_one_div_of_mul_eq_one_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) b a) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) -> (Eq.{succ u_1} α b (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) a))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1747 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1747))))) b a) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1747)))))) -> (Eq.{succ u_1} α b (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1747))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1747))))) a))
Case conversion may be inaccurate. Consider using '#align eq_one_div_of_mul_eq_one_left eq_one_div_of_mul_eq_one_leftₓ'. -/
@[to_additive]
theorem eq_one_div_of_mul_eq_one_left (h : b * a = 1) : b = 1 / a := by rw [eq_inv_of_mul_eq_one_left h, one_div]
#align eq_one_div_of_mul_eq_one_left eq_one_div_of_mul_eq_one_left

/- warning: eq_one_div_of_mul_eq_one_right -> eq_one_div_of_mul_eq_one_right is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) a b) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) -> (Eq.{succ u_1} α b (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) a))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1802 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1802))))) a b) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1802)))))) -> (Eq.{succ u_1} α b (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1802))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1802))))) a))
Case conversion may be inaccurate. Consider using '#align eq_one_div_of_mul_eq_one_right eq_one_div_of_mul_eq_one_rightₓ'. -/
@[to_additive]
theorem eq_one_div_of_mul_eq_one_right (h : a * b = 1) : b = 1 / a := by rw [eq_inv_of_mul_eq_one_right h, one_div]
#align eq_one_div_of_mul_eq_one_right eq_one_div_of_mul_eq_one_right

/- warning: eq_of_div_eq_one -> eq_of_div_eq_one is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a b) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) -> (Eq.{succ u_1} α a b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1857 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1857))) a b) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1857)))))) -> (Eq.{succ u_1} α a b)
Case conversion may be inaccurate. Consider using '#align eq_of_div_eq_one eq_of_div_eq_oneₓ'. -/
@[to_additive]
theorem eq_of_div_eq_one (h : a / b = 1) : a = b :=
  inv_injective <| inv_eq_of_mul_eq_one_right <| by rwa [← div_eq_mul_inv]
#align eq_of_div_eq_one eq_of_div_eq_one

/- warning: div_ne_one_of_ne -> div_ne_one_of_ne is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Ne.{succ u_1} α a b) -> (Ne.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a b) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1922 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Ne.{succ u_1} α a b) -> (Ne.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1922))) a b) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1922))))))
Case conversion may be inaccurate. Consider using '#align div_ne_one_of_ne div_ne_one_of_neₓ'. -/
@[to_additive]
theorem div_ne_one_of_ne : a ≠ b → a / b ≠ 1 :=
  mt eq_of_div_eq_one
#align div_ne_one_of_ne div_ne_one_of_ne

variable (a b c)

/- warning: one_div_mul_one_div_rev -> one_div_mul_one_div_rev is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) a) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) b a))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1962 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))))) a) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))))) b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1962))))) b a))
Case conversion may be inaccurate. Consider using '#align one_div_mul_one_div_rev one_div_mul_one_div_revₓ'. -/
@[to_additive]
theorem one_div_mul_one_div_rev : 1 / a * (1 / b) = 1 / (b * a) := by simp
#align one_div_mul_one_div_rev one_div_mul_one_div_rev

/- warning: inv_div_left -> inv_div_left is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) a) b) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) b a))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.1991 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1991))) (Inv.inv.{u_1} α (DivInvMonoid.toInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1991)) a) b) (Inv.inv.{u_1} α (DivInvMonoid.toInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1991)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.1991))))) b a))
Case conversion may be inaccurate. Consider using '#align inv_div_left inv_div_leftₓ'. -/
@[to_additive]
theorem inv_div_left : a⁻¹ / b = (b * a)⁻¹ := by simp
#align inv_div_left inv_div_left

/- warning: inv_div -> inv_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) b a)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2026 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2026)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2026))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2026))) b a)
Case conversion may be inaccurate. Consider using '#align inv_div inv_divₓ'. -/
@[simp, to_additive]
theorem inv_div : (a / b)⁻¹ = b / a := by simp
#align inv_div inv_div

/- warning: one_div_div -> one_div_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) b a)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2057 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2057))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2057))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2057))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2057))) b a)
Case conversion may be inaccurate. Consider using '#align one_div_div one_div_divₓ'. -/
@[simp, to_additive]
theorem one_div_div : 1 / (a / b) = b / a := by simp
#align one_div_div one_div_div

/- warning: one_div_one_div -> one_div_one_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) a)) a
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2082 : DivisionMonoid.{u_1} α] (a : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2082))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2082))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2082))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (Monoid.toOne.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2082))))) a)) a
Case conversion may be inaccurate. Consider using '#align one_div_one_div one_div_one_divₓ'. -/
@[to_additive]
theorem one_div_one_div : 1 / (1 / a) = a := by simp
#align one_div_one_div one_div_one_div

#print DivisionMonoid.toDivInvOneMonoid /-
@[to_additive SubtractionMonoid.toSubNegZeroMonoid]
instance (priority := 100) DivisionMonoid.toDivInvOneMonoid : DivInvOneMonoid α :=
  { DivisionMonoid.toDivInvMonoid α with inv_one := by simpa only [one_div, inv_inv] using (inv_div (1 : α) 1).symm }
#align division_monoid.to_div_inv_one_monoid DivisionMonoid.toDivInvOneMonoid
-/

variable {a b c}

/- warning: inv_eq_one -> inv_eq_one is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α}, Iff (Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) a) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) (Eq.{succ u_1} α a (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2193 : DivisionMonoid.{u_1} α] {a : α}, Iff (Eq.{succ u_1} α (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2193))) a) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2193)))))) (Eq.{succ u_1} α a (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2193))))))
Case conversion may be inaccurate. Consider using '#align inv_eq_one inv_eq_oneₓ'. -/
@[simp, to_additive]
theorem inv_eq_one : a⁻¹ = 1 ↔ a = 1 :=
  inv_injective.eq_iff' inv_one
#align inv_eq_one inv_eq_one

/- warning: one_eq_inv -> one_eq_inv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α}, Iff (Eq.{succ u_1} α (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) a)) (Eq.{succ u_1} α a (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2222 : DivisionMonoid.{u_1} α] {a : α}, Iff (Eq.{succ u_1} α (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2222))))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2222))) a)) (Eq.{succ u_1} α a (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2222))))))
Case conversion may be inaccurate. Consider using '#align one_eq_inv one_eq_invₓ'. -/
@[simp, to_additive]
theorem one_eq_inv : 1 = a⁻¹ ↔ a = 1 :=
  eq_comm.trans inv_eq_one
#align one_eq_inv one_eq_inv

/- warning: inv_ne_one -> inv_ne_one is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α}, Iff (Ne.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) a) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)))))))) (Ne.{succ u_1} α a (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2251 : DivisionMonoid.{u_1} α] {a : α}, Iff (Ne.{succ u_1} α (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2251))) a) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2251)))))) (Ne.{succ u_1} α a (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2251))))))
Case conversion may be inaccurate. Consider using '#align inv_ne_one inv_ne_oneₓ'. -/
@[to_additive]
theorem inv_ne_one : a⁻¹ ≠ 1 ↔ a ≠ 1 :=
  inv_eq_one.Not
#align inv_ne_one inv_ne_one

/- warning: eq_of_one_div_eq_one_div -> eq_of_one_div_eq_one_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) a) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))))) b)) -> (Eq.{succ u_1} α a b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2278 : DivisionMonoid.{u_1} α] {a : α} {b : α}, (Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2278))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2278))))) a) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2278))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2278))))) b)) -> (Eq.{succ u_1} α a b)
Case conversion may be inaccurate. Consider using '#align eq_of_one_div_eq_one_div eq_of_one_div_eq_one_divₓ'. -/
@[to_additive]
theorem eq_of_one_div_eq_one_div (h : 1 / a = 1 / b) : a = b := by rw [← one_div_one_div a, h, one_div_one_div]
#align eq_of_one_div_eq_one_div eq_of_one_div_eq_one_div

variable (a b c)

/- warning: div_div_eq_mul_div -> div_div_eq_mul_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) a c) b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2347 : DivisionMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2347))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2347))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2347))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2347))))) a c) b)
Case conversion may be inaccurate. Consider using '#align div_div_eq_mul_div div_div_eq_mul_divₓ'. -/
-- The attributes are out of order on purpose
@[to_additive, field_simps]
theorem div_div_eq_mul_div : a / (b / c) = a * c / b := by simp
#align div_div_eq_mul_div div_div_eq_mul_div

/- warning: div_inv_eq_mul -> div_inv_eq_mul is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1)) b)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) a b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2374 : DivisionMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2374))) a (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2374))) b)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2374))))) a b)
Case conversion may be inaccurate. Consider using '#align div_inv_eq_mul div_inv_eq_mulₓ'. -/
@[simp, to_additive]
theorem div_inv_eq_mul : a / b⁻¹ = a * b := by simp
#align div_inv_eq_mul div_inv_eq_mul

/- warning: div_mul_eq_div_div_swap -> div_mul_eq_div_div_swap is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α _inst_1))) a c) b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2401 : DivisionMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2401))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2401))))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2401))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2401))) a c) b)
Case conversion may be inaccurate. Consider using '#align div_mul_eq_div_div_swap div_mul_eq_div_div_swapₓ'. -/
@[to_additive]
theorem div_mul_eq_div_div_swap : a / (b * c) = a / c / b := by simp only [mul_assoc, mul_inv_rev, div_eq_mul_inv]
#align div_mul_eq_div_div_swap div_mul_eq_div_div_swap

end DivisionMonoid

theorem bit0_neg [SubtractionMonoid α] (a : α) : bit0 (-a) = -bit0 a :=
  (neg_add_rev _ _).symm
#align bit0_neg bit0_neg

section DivisionCommMonoid

variable [DivisionCommMonoid α] (a b c d : α)

attribute [local simp] mul_assoc mul_comm mul_left_comm div_eq_mul_inv

/- warning: mul_inv -> mul_inv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a b)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) a) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) b))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2447 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2447)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2447)))))) a b)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2447)))))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2447)))) a) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2447)))) b))
Case conversion may be inaccurate. Consider using '#align mul_inv mul_invₓ'. -/
@[to_additive neg_add]
theorem mul_inv : (a * b)⁻¹ = a⁻¹ * b⁻¹ := by simp
#align mul_inv mul_inv

/- warning: inv_div' -> inv_div' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) a) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) b))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2487 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2487)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2487)))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2487)))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2487)))) a) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2487)))) b))
Case conversion may be inaccurate. Consider using '#align inv_div' inv_div'ₓ'. -/
@[to_additive]
theorem inv_div' : (a / b)⁻¹ = a⁻¹ / b⁻¹ := by simp
#align inv_div' inv_div'

/- warning: div_eq_inv_mul -> div_eq_inv_mul is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) b) a)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2527 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2527)))) a b) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2527)))))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2527)))) b) a)
Case conversion may be inaccurate. Consider using '#align div_eq_inv_mul div_eq_inv_mulₓ'. -/
@[to_additive]
theorem div_eq_inv_mul : a / b = b⁻¹ * a := by simp
#align div_eq_inv_mul div_eq_inv_mul

/- warning: inv_mul_eq_div -> inv_mul_eq_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) a) b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) b a)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2555 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2555)))))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2555)))) a) b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2555)))) b a)
Case conversion may be inaccurate. Consider using '#align inv_mul_eq_div inv_mul_eq_divₓ'. -/
@[to_additive]
theorem inv_mul_eq_div : a⁻¹ * b = b / a := by simp
#align inv_mul_eq_div inv_mul_eq_div

/- warning: inv_mul' -> inv_mul' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) a) b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2583 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2583)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2583)))))) a b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2583)))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2583)))) a) b)
Case conversion may be inaccurate. Consider using '#align inv_mul' inv_mul'ₓ'. -/
@[to_additive]
theorem inv_mul' : (a * b)⁻¹ = a⁻¹ / b := by simp
#align inv_mul' inv_mul'

/- warning: inv_div_inv -> inv_div_inv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) a) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) b a)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2619 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2619)))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2619)))) a) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2619)))) b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2619)))) b a)
Case conversion may be inaccurate. Consider using '#align inv_div_inv inv_div_invₓ'. -/
@[simp, to_additive]
theorem inv_div_inv : a⁻¹ / b⁻¹ = b / a := by simp
#align inv_div_inv inv_div_inv

/- warning: inv_inv_div_inv -> inv_inv_div_inv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) a) (Inv.inv.{u_1} α (DivInvMonoid.toHasInv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1))) b))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2651 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2651)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2651)))) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2651)))) a) (Inv.inv.{u_1} α (InvOneClass.toInv.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2651)))) b))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2651)))) a b)
Case conversion may be inaccurate. Consider using '#align inv_inv_div_inv inv_inv_div_invₓ'. -/
@[to_additive]
theorem inv_inv_div_inv : (a⁻¹ / b⁻¹)⁻¹ = a / b := by simp
#align inv_inv_div_inv inv_inv_div_inv

/- warning: one_div_mul_one_div -> one_div_mul_one_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))))) a) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))))) b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a b))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2691 : DivisionCommMonoid.{u_1} α] (a : α) (b : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))))) a) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))))) b)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2691)))))) a b))
Case conversion may be inaccurate. Consider using '#align one_div_mul_one_div one_div_mul_one_divₓ'. -/
@[to_additive]
theorem one_div_mul_one_div : 1 / a * (1 / b) = 1 / (a * b) := by simp
#align one_div_mul_one_div one_div_mul_one_div

/- warning: div_right_comm -> div_right_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a c) b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2721 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2721)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2721)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2721)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2721)))) a c) b)
Case conversion may be inaccurate. Consider using '#align div_right_comm div_right_commₓ'. -/
@[to_additive]
theorem div_right_comm : a / b / c = a / c / b := by simp
#align div_right_comm div_right_comm

/- warning: div_div -> div_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) b c))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2749 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2749)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2749)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2749)))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2749)))))) b c))
Case conversion may be inaccurate. Consider using '#align div_div div_divₓ'. -/
@[to_additive, field_simps]
theorem div_div : a / b / c = a / (b * c) := by simp
#align div_div div_div

/- warning: div_mul -> div_mul is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) b c))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2777 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2777)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2777)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2777)))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2777)))) b c))
Case conversion may be inaccurate. Consider using '#align div_mul div_mulₓ'. -/
@[to_additive]
theorem div_mul : a / b * c = a / (b / c) := by simp
#align div_mul div_mul

/- warning: mul_div_left_comm -> mul_div_left_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) b c)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) b (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a c))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2805 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2805)))))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2805)))) b c)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2805)))))) b (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2805)))) a c))
Case conversion may be inaccurate. Consider using '#align mul_div_left_comm mul_div_left_commₓ'. -/
@[to_additive]
theorem mul_div_left_comm : a * (b / c) = b * (a / c) := by simp
#align mul_div_left_comm mul_div_left_comm

/- warning: mul_div_right_comm -> mul_div_right_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a b) c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a c) b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2833 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2833)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2833)))))) a b) c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2833)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2833)))) a c) b)
Case conversion may be inaccurate. Consider using '#align mul_div_right_comm mul_div_right_commₓ'. -/
@[to_additive]
theorem mul_div_right_comm : a * b / c = a / c * b := by simp
#align mul_div_right_comm mul_div_right_comm

/- warning: div_mul_eq_div_div -> div_mul_eq_div_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) c)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2861 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2861)))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2861)))))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2861)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2861)))) a b) c)
Case conversion may be inaccurate. Consider using '#align div_mul_eq_div_div div_mul_eq_div_divₓ'. -/
@[to_additive]
theorem div_mul_eq_div_div : a / (b * c) = a / b / c := by simp
#align div_mul_eq_div_div div_mul_eq_div_div

/- warning: div_mul_eq_mul_div -> div_mul_eq_mul_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a c) b)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2889 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2889)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2889)))) a b) c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2889)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2889)))))) a c) b)
Case conversion may be inaccurate. Consider using '#align div_mul_eq_mul_div div_mul_eq_mul_divₓ'. -/
@[to_additive, field_simps]
theorem div_mul_eq_mul_div : a / b * c = a * c / b := by simp
#align div_mul_eq_mul_div div_mul_eq_mul_div

/- warning: mul_comm_div -> mul_comm_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) c b))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2917 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2917)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2917)))) a b) c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2917)))))) a (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2917)))) c b))
Case conversion may be inaccurate. Consider using '#align mul_comm_div mul_comm_divₓ'. -/
@[to_additive]
theorem mul_comm_div : a / b * c = a * (c / b) := by simp
#align mul_comm_div mul_comm_div

/- warning: div_mul_comm -> div_mul_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) c b) a)
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2945 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2945)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2945)))) a b) c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2945)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2945)))) c b) a)
Case conversion may be inaccurate. Consider using '#align div_mul_comm div_mul_commₓ'. -/
@[to_additive]
theorem div_mul_comm : a / b * c = c / b * a := by simp
#align div_mul_comm div_mul_comm

/- warning: div_mul_eq_div_mul_one_div -> div_mul_eq_div_mul_one_div is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) b c)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (OfNat.ofNat.{u_1} α 1 (OfNat.mk.{u_1} α 1 (One.one.{u_1} α (MulOneClass.toHasOne.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))))) c))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.2973 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2973)))) a (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2973)))))) b c)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2973)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2973)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2973)))) (OfNat.ofNat.{u_1} α 1 (One.toOfNat1.{u_1} α (InvOneClass.toOne.{u_1} α (DivInvOneMonoid.toInvOneClass.{u_1} α (DivisionMonoid.toDivInvOneMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.2973)))))) c))
Case conversion may be inaccurate. Consider using '#align div_mul_eq_div_mul_one_div div_mul_eq_div_mul_one_divₓ'. -/
@[to_additive]
theorem div_mul_eq_div_mul_one_div : a / (b * c) = a / b * (1 / c) := by simp
#align div_mul_eq_div_mul_one_div div_mul_eq_div_mul_one_div

/- warning: div_div_div_eq -> div_div_div_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) c d)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a d) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) b c))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3003 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3003)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3003)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3003)))) c d)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3003)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3003)))))) a d) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3003)))))) b c))
Case conversion may be inaccurate. Consider using '#align div_div_div_eq div_div_div_eqₓ'. -/
@[to_additive]
theorem div_div_div_eq : a / b / (c / d) = a * d / (b * c) := by simp
#align div_div_div_eq div_div_div_eq

/- warning: div_div_div_comm -> div_div_div_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) c d)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) b d))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3035 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3035)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3035)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3035)))) c d)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3035)))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3035)))) a c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3035)))) b d))
Case conversion may be inaccurate. Consider using '#align div_div_div_comm div_div_div_commₓ'. -/
@[to_additive]
theorem div_div_div_comm : a / b / (c / d) = a / c / (b / d) := by simp
#align div_div_div_comm div_div_div_comm

/- warning: div_mul_div_comm -> div_mul_div_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) c d)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) b d))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3067 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3067)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3067)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3067)))) c d)) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3067)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3067)))))) a c) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3067)))))) b d))
Case conversion may be inaccurate. Consider using '#align div_mul_div_comm div_mul_div_commₓ'. -/
@[to_additive]
theorem div_mul_div_comm : a / b * (c / d) = a * c / (b * d) := by simp
#align div_mul_div_comm div_mul_div_comm

/- warning: mul_div_mul_comm -> mul_div_mul_comm is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u_1}} [_inst_1 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) a b) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) c d)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toHasMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) a c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toHasDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α _inst_1)))) b d))
but is expected to have type
  forall {α : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3099 : DivisionCommMonoid.{u_1} α] (a : α) (b : α) (c : α) (d : α), Eq.{succ u_1} α (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3099)))) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3099)))))) a b) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3099)))))) c d)) (HMul.hMul.{u_1 u_1 u_1} α α α (instHMul.{u_1} α (MulOneClass.toMul.{u_1} α (Monoid.toMulOneClass.{u_1} α (DivInvMonoid.toMonoid.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3099)))))) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3099)))) a c) (HDiv.hDiv.{u_1 u_1 u_1} α α α (instHDiv.{u_1} α (DivInvMonoid.toDiv.{u_1} α (DivisionMonoid.toDivInvMonoid.{u_1} α (DivisionCommMonoid.toDivisionMonoid.{u_1} α inst._@.Mathlib.Algebra.Group.Basic._hyg.3099)))) b d))
Case conversion may be inaccurate. Consider using '#align mul_div_mul_comm mul_div_mul_commₓ'. -/
@[to_additive]
theorem mul_div_mul_comm : a * b / (c * d) = a / c * (b / d) := by simp
#align mul_div_mul_comm mul_div_mul_comm

end DivisionCommMonoid

section Group

variable [Group G] {a b c d : G}

/- warning: div_eq_inv_self -> div_eq_inv_self is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b)) (Eq.{succ u_3} G a (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))))))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3149 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3149))) a b) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3149)))) b)) (Eq.{succ u_1} G a (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3149)))))))
Case conversion may be inaccurate. Consider using '#align div_eq_inv_self div_eq_inv_selfₓ'. -/
@[simp, to_additive]
theorem div_eq_inv_self : a / b = b⁻¹ ↔ a = 1 := by rw [div_eq_mul_inv, mul_left_eq_self]
#align div_eq_inv_self div_eq_inv_self

/- warning: mul_left_surjective -> mul_left_surjective is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G), Function.Surjective.{succ u_3 succ u_3} G G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3208 : Group.{u_1} G] (a : G), Function.Surjective.{succ u_1 succ u_1} G G ((fun (x._@.Mathlib.Algebra.Group.Basic._hyg.3223 : G) (x._@.Mathlib.Algebra.Group.Basic._hyg.3225 : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3208))))) x._@.Mathlib.Algebra.Group.Basic._hyg.3223 x._@.Mathlib.Algebra.Group.Basic._hyg.3225) a)
Case conversion may be inaccurate. Consider using '#align mul_left_surjective mul_left_surjectiveₓ'. -/
@[to_additive]
theorem mul_left_surjective (a : G) : Function.Surjective ((· * ·) a) := fun x => ⟨a⁻¹ * x, mul_inv_cancel_left a x⟩
#align mul_left_surjective mul_left_surjective

/- warning: mul_right_surjective -> mul_right_surjective is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G), Function.Surjective.{succ u_3 succ u_3} G G (fun (x : G) => HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) x a)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3257 : Group.{u_1} G] (a : G), Function.Surjective.{succ u_1 succ u_1} G G (fun (x : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3257))))) x a)
Case conversion may be inaccurate. Consider using '#align mul_right_surjective mul_right_surjectiveₓ'. -/
@[to_additive]
theorem mul_right_surjective (a : G) : Function.Surjective fun x => x * a := fun x =>
  ⟨x * a⁻¹, inv_mul_cancel_right x a⟩
#align mul_right_surjective mul_right_surjective

/- warning: eq_mul_inv_of_mul_eq -> eq_mul_inv_of_mul_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a c) b) -> (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) c)))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3295 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3295))))) a c) b) -> (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3295))))) b (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3295)))) c)))
Case conversion may be inaccurate. Consider using '#align eq_mul_inv_of_mul_eq eq_mul_inv_of_mul_eqₓ'. -/
@[to_additive]
theorem eq_mul_inv_of_mul_eq (h : a * c = b) : a = b * c⁻¹ := by simp [h.symm]
#align eq_mul_inv_of_mul_eq eq_mul_inv_of_mul_eq

/- warning: eq_inv_mul_of_mul_eq -> eq_inv_mul_of_mul_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b a) c) -> (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b) c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3329 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3329))))) b a) c) -> (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3329))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3329)))) b) c))
Case conversion may be inaccurate. Consider using '#align eq_inv_mul_of_mul_eq eq_inv_mul_of_mul_eqₓ'. -/
@[to_additive]
theorem eq_inv_mul_of_mul_eq (h : b * a = c) : a = b⁻¹ * c := by simp [h.symm]
#align eq_inv_mul_of_mul_eq eq_inv_mul_of_mul_eq

/- warning: inv_mul_eq_of_eq_mul -> inv_mul_eq_of_eq_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G b (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a c)) -> (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) a) b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3363 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G b (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3363))))) a c)) -> (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3363))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3363)))) a) b) c)
Case conversion may be inaccurate. Consider using '#align inv_mul_eq_of_eq_mul inv_mul_eq_of_eq_mulₓ'. -/
@[to_additive]
theorem inv_mul_eq_of_eq_mul (h : b = a * c) : a⁻¹ * b = c := by simp [h]
#align inv_mul_eq_of_eq_mul inv_mul_eq_of_eq_mul

/- warning: mul_inv_eq_of_eq_mul -> mul_inv_eq_of_eq_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) c b)) -> (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b)) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3396 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3396))))) c b)) -> (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3396))))) a (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3396)))) b)) c)
Case conversion may be inaccurate. Consider using '#align mul_inv_eq_of_eq_mul mul_inv_eq_of_eq_mulₓ'. -/
@[to_additive]
theorem mul_inv_eq_of_eq_mul (h : a = c * b) : a * b⁻¹ = c := by simp [h]
#align mul_inv_eq_of_eq_mul mul_inv_eq_of_eq_mul

/- warning: eq_mul_of_mul_inv_eq -> eq_mul_of_mul_inv_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) c)) b) -> (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3429 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3429))))) a (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3429)))) c)) b) -> (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3429))))) b c))
Case conversion may be inaccurate. Consider using '#align eq_mul_of_mul_inv_eq eq_mul_of_mul_inv_eqₓ'. -/
@[to_additive]
theorem eq_mul_of_mul_inv_eq (h : a * c⁻¹ = b) : a = b * c := by simp [h.symm]
#align eq_mul_of_mul_inv_eq eq_mul_of_mul_inv_eq

/- warning: eq_mul_of_inv_mul_eq -> eq_mul_of_inv_mul_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b) a) c) -> (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3463 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3463))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3463)))) b) a) c) -> (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3463))))) b c))
Case conversion may be inaccurate. Consider using '#align eq_mul_of_inv_mul_eq eq_mul_of_inv_mul_eqₓ'. -/
@[to_additive]
theorem eq_mul_of_inv_mul_eq (h : b⁻¹ * a = c) : a = b * c := by simp [h.symm, mul_inv_cancel_left]
#align eq_mul_of_inv_mul_eq eq_mul_of_inv_mul_eq

/- warning: mul_eq_of_eq_inv_mul -> mul_eq_of_eq_inv_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G b (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) a) c)) -> (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3497 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G b (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3497))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3497)))) a) c)) -> (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3497))))) a b) c)
Case conversion may be inaccurate. Consider using '#align mul_eq_of_eq_inv_mul mul_eq_of_eq_inv_mulₓ'. -/
@[to_additive]
theorem mul_eq_of_eq_inv_mul (h : b = a⁻¹ * c) : a * b = c := by rw [h, mul_inv_cancel_left]
#align mul_eq_of_eq_inv_mul mul_eq_of_eq_inv_mul

/- warning: mul_eq_of_eq_mul_inv -> mul_eq_of_eq_mul_inv is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) c (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b))) -> (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3556 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3556))))) c (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3556)))) b))) -> (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3556))))) a b) c)
Case conversion may be inaccurate. Consider using '#align mul_eq_of_eq_mul_inv mul_eq_of_eq_mul_invₓ'. -/
@[to_additive]
theorem mul_eq_of_eq_mul_inv (h : a = c * b⁻¹) : a * b = c := by simp [h]
#align mul_eq_of_eq_mul_inv mul_eq_of_eq_mul_inv

/- warning: mul_eq_one_iff_eq_inv -> mul_eq_one_iff_eq_inv is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))) (Eq.{succ u_3} G a (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3589 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3589))))) a b) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3589))))))) (Eq.{succ u_1} G a (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3589)))) b))
Case conversion may be inaccurate. Consider using '#align mul_eq_one_iff_eq_inv mul_eq_one_iff_eq_invₓ'. -/
@[to_additive]
theorem mul_eq_one_iff_eq_inv : a * b = 1 ↔ a = b⁻¹ :=
  ⟨eq_inv_of_mul_eq_one_left, fun h => by rw [h, mul_left_inv]⟩
#align mul_eq_one_iff_eq_inv mul_eq_one_iff_eq_inv

/- warning: mul_eq_one_iff_inv_eq -> mul_eq_one_iff_inv_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))) (Eq.{succ u_3} G (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) a) b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3655 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3655))))) a b) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3655))))))) (Eq.{succ u_1} G (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3655)))) a) b)
Case conversion may be inaccurate. Consider using '#align mul_eq_one_iff_inv_eq mul_eq_one_iff_inv_eqₓ'. -/
@[to_additive]
theorem mul_eq_one_iff_inv_eq : a * b = 1 ↔ a⁻¹ = b := by rw [mul_eq_one_iff_eq_inv, eq_inv_iff_eq_inv, eq_comm]
#align mul_eq_one_iff_inv_eq mul_eq_one_iff_inv_eq

/- warning: eq_inv_iff_mul_eq_one -> eq_inv_iff_mul_eq_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G a (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b)) (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))))))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3715 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G a (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3715)))) b)) (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3715))))) a b) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3715)))))))
Case conversion may be inaccurate. Consider using '#align eq_inv_iff_mul_eq_one eq_inv_iff_mul_eq_oneₓ'. -/
@[to_additive]
theorem eq_inv_iff_mul_eq_one : a = b⁻¹ ↔ a * b = 1 :=
  mul_eq_one_iff_eq_inv.symm
#align eq_inv_iff_mul_eq_one eq_inv_iff_mul_eq_one

/- warning: inv_eq_iff_mul_eq_one -> inv_eq_iff_mul_eq_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) a) b) (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))))))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3746 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3746)))) a) b) (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3746))))) a b) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3746)))))))
Case conversion may be inaccurate. Consider using '#align inv_eq_iff_mul_eq_one inv_eq_iff_mul_eq_oneₓ'. -/
@[to_additive]
theorem inv_eq_iff_mul_eq_one : a⁻¹ = b ↔ a * b = 1 :=
  mul_eq_one_iff_inv_eq.symm
#align inv_eq_iff_mul_eq_one inv_eq_iff_mul_eq_one

/- warning: eq_mul_inv_iff_mul_eq -> eq_mul_inv_iff_mul_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) c))) (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a c) b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3777 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3777))))) b (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3777)))) c))) (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3777))))) a c) b)
Case conversion may be inaccurate. Consider using '#align eq_mul_inv_iff_mul_eq eq_mul_inv_iff_mul_eqₓ'. -/
@[to_additive]
theorem eq_mul_inv_iff_mul_eq : a = b * c⁻¹ ↔ a * c = b :=
  ⟨fun h => by rw [h, inv_mul_cancel_right], fun h => by rw [← h, mul_inv_cancel_right]⟩
#align eq_mul_inv_iff_mul_eq eq_mul_inv_iff_mul_eq

/- warning: eq_inv_mul_iff_mul_eq -> eq_inv_mul_iff_mul_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b) c)) (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b a) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3877 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3877))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3877)))) b) c)) (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3877))))) b a) c)
Case conversion may be inaccurate. Consider using '#align eq_inv_mul_iff_mul_eq eq_inv_mul_iff_mul_eqₓ'. -/
@[to_additive]
theorem eq_inv_mul_iff_mul_eq : a = b⁻¹ * c ↔ b * a = c :=
  ⟨fun h => by rw [h, mul_inv_cancel_left], fun h => by rw [← h, inv_mul_cancel_left]⟩
#align eq_inv_mul_iff_mul_eq eq_inv_mul_iff_mul_eq

/- warning: inv_mul_eq_iff_eq_mul -> inv_mul_eq_iff_eq_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) a) b) c) (Eq.{succ u_3} G b (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.3977 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3977))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3977)))) a) b) c) (Eq.{succ u_1} G b (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.3977))))) a c))
Case conversion may be inaccurate. Consider using '#align inv_mul_eq_iff_eq_mul inv_mul_eq_iff_eq_mulₓ'. -/
@[to_additive]
theorem inv_mul_eq_iff_eq_mul : a⁻¹ * b = c ↔ b = a * c :=
  ⟨fun h => by rw [← h, mul_inv_cancel_left], fun h => by rw [h, inv_mul_cancel_left]⟩
#align inv_mul_eq_iff_eq_mul inv_mul_eq_iff_eq_mul

/- warning: mul_inv_eq_iff_eq_mul -> mul_inv_eq_iff_eq_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b)) c) (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) c b))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4077 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4077))))) a (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4077)))) b)) c) (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4077))))) c b))
Case conversion may be inaccurate. Consider using '#align mul_inv_eq_iff_eq_mul mul_inv_eq_iff_eq_mulₓ'. -/
@[to_additive]
theorem mul_inv_eq_iff_eq_mul : a * b⁻¹ = c ↔ a = c * b :=
  ⟨fun h => by rw [← h, inv_mul_cancel_right], fun h => by rw [h, mul_inv_cancel_right]⟩
#align mul_inv_eq_iff_eq_mul mul_inv_eq_iff_eq_mul

/- warning: mul_inv_eq_one -> mul_inv_eq_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) b)) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))) (Eq.{succ u_3} G a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4177 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4177))))) a (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4177)))) b)) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4177))))))) (Eq.{succ u_1} G a b)
Case conversion may be inaccurate. Consider using '#align mul_inv_eq_one mul_inv_eq_oneₓ'. -/
@[to_additive]
theorem mul_inv_eq_one : a * b⁻¹ = 1 ↔ a = b := by rw [mul_eq_one_iff_eq_inv, inv_inv]
#align mul_inv_eq_one mul_inv_eq_one

/- warning: inv_mul_eq_one -> inv_mul_eq_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) a) b) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))) (Eq.{succ u_3} G a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4236 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4236))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4236)))) a) b) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4236))))))) (Eq.{succ u_1} G a b)
Case conversion may be inaccurate. Consider using '#align inv_mul_eq_one inv_mul_eq_oneₓ'. -/
@[to_additive]
theorem inv_mul_eq_one : a⁻¹ * b = 1 ↔ a = b := by rw [mul_eq_one_iff_eq_inv, inv_inj]
#align inv_mul_eq_one inv_mul_eq_one

/- warning: div_left_injective -> div_left_injective is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {b : G}, Function.Injective.{succ u_3 succ u_3} G G (fun (a : G) => HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4295 : Group.{u_1} G] {b : G}, Function.Injective.{succ u_1 succ u_1} G G (fun (a : G) => HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4295))) a b)
Case conversion may be inaccurate. Consider using '#align div_left_injective div_left_injectiveₓ'. -/
@[to_additive]
theorem div_left_injective : Function.Injective fun a => a / b := by
  simpa only [div_eq_mul_inv] using fun a a' h => mul_left_injective b⁻¹ h
#align div_left_injective div_left_injective

/- warning: div_right_injective -> div_right_injective is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {b : G}, Function.Injective.{succ u_3 succ u_3} G G (fun (a : G) => HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) b a)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4331 : Group.{u_1} G] {b : G}, Function.Injective.{succ u_1 succ u_1} G G (fun (a : G) => HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4331))) b a)
Case conversion may be inaccurate. Consider using '#align div_right_injective div_right_injectiveₓ'. -/
@[to_additive]
theorem div_right_injective : Function.Injective fun a => b / a := by
  simpa only [div_eq_mul_inv] using fun a a' h => inv_injective (mul_right_injective b h)
#align div_right_injective div_right_injective

/- warning: div_mul_cancel' -> div_mul_cancel' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) b) a
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4367 : Group.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4367))))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4367))) a b) b) a
Case conversion may be inaccurate. Consider using '#align div_mul_cancel' div_mul_cancel'ₓ'. -/
@[simp, to_additive sub_add_cancel]
theorem div_mul_cancel' (a b : G) : a / b * b = a := by rw [div_eq_mul_inv, inv_mul_cancel_right a b]
#align div_mul_cancel' div_mul_cancel'

/- warning: div_self' -> div_self' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a a) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4421 : Group.{u_1} G] (a : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4421))) a a) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4421))))))
Case conversion may be inaccurate. Consider using '#align div_self' div_self'ₓ'. -/
@[simp, to_additive sub_self]
theorem div_self' (a : G) : a / a = 1 := by rw [div_eq_mul_inv, mul_right_inv a]
#align div_self' div_self'

/- warning: mul_div_cancel'' -> mul_div_cancel'' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) b) a
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4471 : Group.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4471))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4471))))) a b) b) a
Case conversion may be inaccurate. Consider using '#align mul_div_cancel'' mul_div_cancel''ₓ'. -/
@[simp, to_additive add_sub_cancel]
theorem mul_div_cancel'' (a b : G) : a * b / b = a := by rw [div_eq_mul_inv, mul_inv_cancel_right a b]
#align mul_div_cancel'' mul_div_cancel''

/- warning: mul_div_mul_right_eq_div -> mul_div_mul_right_eq_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a c) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b c)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4525 : Group.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4525))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4525))))) a c) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4525))))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4525))) a b)
Case conversion may be inaccurate. Consider using '#align mul_div_mul_right_eq_div mul_div_mul_right_eq_divₓ'. -/
@[simp, to_additive]
theorem mul_div_mul_right_eq_div (a b c : G) : a * c / (b * c) = a / b := by
  rw [div_mul_eq_div_div_swap] <;> simp only [mul_left_inj, eq_self_iff_true, mul_div_cancel'']
#align mul_div_mul_right_eq_div mul_div_mul_right_eq_div

/- warning: eq_div_of_mul_eq' -> eq_div_of_mul_eq' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a c) b) -> (Eq.{succ u_3} G a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4585 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4585))))) a c) b) -> (Eq.{succ u_1} G a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4585))) b c))
Case conversion may be inaccurate. Consider using '#align eq_div_of_mul_eq' eq_div_of_mul_eq'ₓ'. -/
@[to_additive eq_sub_of_add_eq]
theorem eq_div_of_mul_eq' (h : a * c = b) : a = b / c := by simp [← h]
#align eq_div_of_mul_eq' eq_div_of_mul_eq'

/- warning: div_eq_of_eq_mul'' -> div_eq_of_eq_mul'' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) c b)) -> (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4614 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4614))))) c b)) -> (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4614))) a b) c)
Case conversion may be inaccurate. Consider using '#align div_eq_of_eq_mul'' div_eq_of_eq_mul''ₓ'. -/
@[to_additive sub_eq_of_eq_add]
theorem div_eq_of_eq_mul'' (h : a = c * b) : a / b = c := by simp [h]
#align div_eq_of_eq_mul'' div_eq_of_eq_mul''

/- warning: eq_mul_of_div_eq -> eq_mul_of_div_eq is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a c) b) -> (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4643 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4643))) a c) b) -> (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4643))))) b c))
Case conversion may be inaccurate. Consider using '#align eq_mul_of_div_eq eq_mul_of_div_eqₓ'. -/
@[to_additive]
theorem eq_mul_of_div_eq (h : a / c = b) : a = b * c := by simp [← h]
#align eq_mul_of_div_eq eq_mul_of_div_eq

/- warning: mul_eq_of_eq_div -> mul_eq_of_eq_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) c b)) -> (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4672 : Group.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4672))) c b)) -> (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4672))))) a b) c)
Case conversion may be inaccurate. Consider using '#align mul_eq_of_eq_div mul_eq_of_eq_divₓ'. -/
@[to_additive]
theorem mul_eq_of_eq_div (h : a = c / b) : a * b = c := by simp [h]
#align mul_eq_of_eq_div mul_eq_of_eq_div

/- warning: div_right_inj -> div_right_inj is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a c)) (Eq.{succ u_3} G b c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4701 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4701))) a b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4701))) a c)) (Eq.{succ u_1} G b c)
Case conversion may be inaccurate. Consider using '#align div_right_inj div_right_injₓ'. -/
@[simp, to_additive]
theorem div_right_inj : a / b = a / c ↔ b = c :=
  div_right_injective.eq_iff
#align div_right_inj div_right_inj

/- warning: div_left_inj -> div_left_inj is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) b a) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) c a)) (Eq.{succ u_3} G b c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4730 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4730))) b a) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4730))) c a)) (Eq.{succ u_1} G b c)
Case conversion may be inaccurate. Consider using '#align div_left_inj div_left_injₓ'. -/
@[simp, to_additive]
theorem div_left_inj : b / a = c / a ↔ b = c := by
  rw [div_eq_mul_inv, div_eq_mul_inv]
  exact mul_left_inj _
#align div_left_inj div_left_inj

/- warning: div_mul_div_cancel' -> div_mul_div_cancel' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) b c)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4794 : Group.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4794))))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4794))) a b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4794))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4794))) a c)
Case conversion may be inaccurate. Consider using '#align div_mul_div_cancel' div_mul_div_cancel'ₓ'. -/
@[simp, to_additive sub_add_sub_cancel]
theorem div_mul_div_cancel' (a b c : G) : a / b * (b / c) = a / c := by rw [← mul_div_assoc, div_mul_cancel']
#align div_mul_div_cancel' div_mul_div_cancel'

/- warning: div_div_div_cancel_right' -> div_div_div_cancel_right' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a c) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) b c)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4851 : Group.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4851))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4851))) a c) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4851))) b c)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4851))) a b)
Case conversion may be inaccurate. Consider using '#align div_div_div_cancel_right' div_div_div_cancel_right'ₓ'. -/
@[simp, to_additive sub_sub_sub_cancel_right]
theorem div_div_div_cancel_right' (a b c : G) : a / c / (b / c) = a / b := by
  rw [← inv_div c b, div_inv_eq_mul, div_mul_div_cancel']
#align div_div_div_cancel_right' div_div_div_cancel_right'

/- warning: div_eq_one -> div_eq_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))) (Eq.{succ u_3} G a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4911 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4911))) a b) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4911))))))) (Eq.{succ u_1} G a b)
Case conversion may be inaccurate. Consider using '#align div_eq_one div_eq_oneₓ'. -/
@[to_additive]
theorem div_eq_one : a / b = 1 ↔ a = b :=
  ⟨eq_of_div_eq_one, fun h => by rw [h, div_self']⟩
#align div_eq_one div_eq_one

alias div_eq_one ↔ _ div_eq_one_of_eq

alias sub_eq_zero ↔ _ sub_eq_zero_of_eq

/- warning: div_ne_one -> div_ne_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Ne.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))) (Ne.{succ u_3} G a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.4975 : Group.{u_1} G] {a : G} {b : G}, Iff (Ne.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4975))) a b) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.4975))))))) (Ne.{succ u_1} G a b)
Case conversion may be inaccurate. Consider using '#align div_ne_one div_ne_oneₓ'. -/
@[to_additive]
theorem div_ne_one : a / b ≠ 1 ↔ a ≠ b :=
  not_congr div_eq_one
#align div_ne_one div_ne_one

/- warning: div_eq_self -> div_eq_self is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) a) (Eq.{succ u_3} G b (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))))))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5005 : Group.{u_1} G] {a : G} {b : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5005))) a b) a) (Eq.{succ u_1} G b (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5005)))))))
Case conversion may be inaccurate. Consider using '#align div_eq_self div_eq_selfₓ'. -/
@[simp, to_additive]
theorem div_eq_self : a / b = a ↔ b = 1 := by rw [div_eq_mul_inv, mul_right_eq_self, inv_eq_one]
#align div_eq_self div_eq_self

/- warning: eq_div_iff_mul_eq' -> eq_div_iff_mul_eq' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) b c)) (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) a c) b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5061 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5061))) b c)) (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5061))))) a c) b)
Case conversion may be inaccurate. Consider using '#align eq_div_iff_mul_eq' eq_div_iff_mul_eq'ₓ'. -/
@[to_additive eq_sub_iff_add_eq]
theorem eq_div_iff_mul_eq' : a = b / c ↔ a * c = b := by rw [div_eq_mul_inv, eq_mul_inv_iff_mul_eq]
#align eq_div_iff_mul_eq' eq_div_iff_mul_eq'

/- warning: div_eq_iff_eq_mul -> div_eq_iff_eq_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) c) (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) c b))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5118 : Group.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5118))) a b) c) (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5118))))) c b))
Case conversion may be inaccurate. Consider using '#align div_eq_iff_eq_mul div_eq_iff_eq_mulₓ'. -/
@[to_additive]
theorem div_eq_iff_eq_mul : a / b = c ↔ a = c * b := by rw [div_eq_mul_inv, mul_inv_eq_iff_eq_mul]
#align div_eq_iff_eq_mul div_eq_iff_eq_mul

/- warning: eq_iff_eq_of_div_eq_div -> eq_iff_eq_of_div_eq_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {a : G} {b : G} {c : G} {d : G}, (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) a b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) c d)) -> (Iff (Eq.{succ u_3} G a b) (Eq.{succ u_3} G c d))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5175 : Group.{u_1} G] {a : G} {b : G} {c : G} {d : G}, (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5175))) a b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5175))) c d)) -> (Iff (Eq.{succ u_1} G a b) (Eq.{succ u_1} G c d))
Case conversion may be inaccurate. Consider using '#align eq_iff_eq_of_div_eq_div eq_iff_eq_of_div_eq_divₓ'. -/
@[to_additive]
theorem eq_iff_eq_of_div_eq_div (H : a / b = c / d) : a = b ↔ c = d := by rw [← div_eq_one, H, div_eq_one]
#align eq_iff_eq_of_div_eq_div eq_iff_eq_of_div_eq_div

/- warning: left_inverse_div_mul_left -> leftInverse_div_mul_left is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (c : G), Function.LeftInverse.{succ u_3 succ u_3} G G (fun (x : G) => HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) x c) (fun (x : G) => HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) x c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5238 : Group.{u_1} G] (c : G), Function.LeftInverse.{succ u_1 succ u_1} G G (fun (x : G) => HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5238))) x c) (fun (x : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5238))))) x c)
Case conversion may be inaccurate. Consider using '#align left_inverse_div_mul_left leftInverse_div_mul_leftₓ'. -/
@[to_additive]
theorem leftInverse_div_mul_left (c : G) : Function.LeftInverse (fun x => x / c) fun x => x * c := fun x =>
  mul_div_cancel'' x c
#align left_inverse_div_mul_left leftInverse_div_mul_left

/- warning: left_inverse_mul_left_div -> leftInverse_mul_left_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (c : G), Function.LeftInverse.{succ u_3 succ u_3} G G (fun (x : G) => HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) x c) (fun (x : G) => HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) x c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5277 : Group.{u_1} G] (c : G), Function.LeftInverse.{succ u_1 succ u_1} G G (fun (x : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5277))))) x c) (fun (x : G) => HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5277))) x c)
Case conversion may be inaccurate. Consider using '#align left_inverse_mul_left_div leftInverse_mul_left_divₓ'. -/
@[to_additive]
theorem leftInverse_mul_left_div (c : G) : Function.LeftInverse (fun x => x * c) fun x => x / c := fun x =>
  div_mul_cancel' x c
#align left_inverse_mul_left_div leftInverse_mul_left_div

/- warning: left_inverse_mul_right_inv_mul -> leftInverse_mul_right_inv_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (c : G), Function.LeftInverse.{succ u_3 succ u_3} G G (fun (x : G) => HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) c x) (fun (x : G) => HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) c) x)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5316 : Group.{u_1} G] (c : G), Function.LeftInverse.{succ u_1 succ u_1} G G (fun (x : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5316))))) c x) (fun (x : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5316))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5316)))) c) x)
Case conversion may be inaccurate. Consider using '#align left_inverse_mul_right_inv_mul leftInverse_mul_right_inv_mulₓ'. -/
@[to_additive]
theorem leftInverse_mul_right_inv_mul (c : G) : Function.LeftInverse (fun x => c * x) fun x => c⁻¹ * x := fun x =>
  mul_inv_cancel_left c x
#align left_inverse_mul_right_inv_mul leftInverse_mul_right_inv_mul

/- warning: left_inverse_inv_mul_mul_right -> leftInverse_inv_mul_mul_right is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] (c : G), Function.LeftInverse.{succ u_3 succ u_3} G G (fun (x : G) => HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)) c) x) (fun (x : G) => HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))))) c x)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5359 : Group.{u_1} G] (c : G), Function.LeftInverse.{succ u_1 succ u_1} G G (fun (x : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5359))))) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5359)))) c) x) (fun (x : G) => HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5359))))) c x)
Case conversion may be inaccurate. Consider using '#align left_inverse_inv_mul_mul_right leftInverse_inv_mul_mul_rightₓ'. -/
@[to_additive]
theorem leftInverse_inv_mul_mul_right (c : G) : Function.LeftInverse (fun x => c⁻¹ * x) fun x => c * x := fun x =>
  inv_mul_cancel_left c x
#align left_inverse_inv_mul_mul_right leftInverse_inv_mul_mul_right

/- warning: exists_npow_eq_one_of_zpow_eq_one -> exists_npow_eq_one_of_zpow_eq_one is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : Group.{u_3} G] {n : Int}, (Ne.{1} Int n (OfNat.ofNat.{0} Int 0 (OfNat.mk.{0} Int 0 (Zero.zero.{0} Int Int.hasZero)))) -> (forall {x : G}, (Eq.{succ u_3} G (HPow.hPow.{u_3 0 u_3} G Int G (instHPow.{u_3 0} G Int (DivInvMonoid.hasPow.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1))) x n) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))) -> (Exists.{1} Nat (fun (n : Nat) => And (LT.lt.{0} Nat Nat.hasLt (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero))) n) (Eq.{succ u_3} G (HPow.hPow.{u_3 0 u_3} G Nat G (instHPow.{u_3 0} G Nat (Monoid.hasPow.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))) x n) (OfNat.ofNat.{u_3} G 1 (OfNat.mk.{u_3} G 1 (One.one.{u_3} G (MulOneClass.toHasOne.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G _inst_1)))))))))))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5402 : Group.{u_1} G] {n : Int}, (Ne.{1} Int n (OfNat.ofNat.{0} Int 0 (instOfNatInt 0))) -> (forall {x : G}, (Eq.{succ u_1} G (HPow.hPow.{u_1 0 u_1} G Int G (instHPow.{u_1 0} G Int (DivInvMonoid.hasPow.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5402))) x n) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5402))))))) -> (Exists.{1} Nat (fun (n : Nat) => And (LT.lt.{0} Nat instLTNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)) n) (Eq.{succ u_1} G (HPow.hPow.{u_1 0 u_1} G Nat G (instHPow.{u_1 0} G Nat (Monoid.Pow.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5402)))) x n) (OfNat.ofNat.{u_1} G 1 (One.toOfNat1.{u_1} G (InvOneClass.toOne.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (Group.toDivisionMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5402))))))))))
Case conversion may be inaccurate. Consider using '#align exists_npow_eq_one_of_zpow_eq_one exists_npow_eq_one_of_zpow_eq_oneₓ'. -/
@[to_additive]
theorem exists_npow_eq_one_of_zpow_eq_one {n : ℤ} (hn : n ≠ 0) {x : G} (h : x ^ n = 1) : ∃ n : ℕ, 0 < n ∧ x ^ n = 1 :=
  by
  cases' n with n n
  · rw [zpow_of_nat] at h
    refine' ⟨n, Nat.pos_of_ne_zero fun n0 => hn _, h⟩
    rw [n0]
    rfl
    
  · rw [zpow_neg_succ_of_nat, inv_eq_one] at h
    refine' ⟨n + 1, n.succ_pos, h⟩
    
#align exists_npow_eq_one_of_zpow_eq_one exists_npow_eq_one_of_zpow_eq_one

end Group

section CommGroup

variable [CommGroup G] {a b c d : G}

attribute [local simp] mul_assoc mul_comm mul_left_comm div_eq_mul_inv

/- warning: div_eq_of_eq_mul' -> div_eq_of_eq_mul' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) b c)) -> (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5608 : CommGroup.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5608)))))) b c)) -> (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5608)))) a b) c)
Case conversion may be inaccurate. Consider using '#align div_eq_of_eq_mul' div_eq_of_eq_mul'ₓ'. -/
@[to_additive]
theorem div_eq_of_eq_mul' {a b c : G} (h : a = b * c) : a / b = c := by
  rw [h, div_eq_mul_inv, mul_comm, inv_mul_cancel_left]
#align div_eq_of_eq_mul' div_eq_of_eq_mul'

/- warning: mul_div_mul_left_eq_div -> mul_div_mul_left_eq_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) c a) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) c b)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5668 : CommGroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5668)))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5668)))))) c a) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5668)))))) c b)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5668)))) a b)
Case conversion may be inaccurate. Consider using '#align mul_div_mul_left_eq_div mul_div_mul_left_eq_divₓ'. -/
@[simp, to_additive]
theorem mul_div_mul_left_eq_div (a b c : G) : c * a / (c * b) = a / b := by simp
#align mul_div_mul_left_eq_div mul_div_mul_left_eq_div

/- warning: eq_div_of_mul_eq'' -> eq_div_of_mul_eq'' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) c a) b) -> (Eq.{succ u_3} G a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5743 : CommGroup.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5743)))))) c a) b) -> (Eq.{succ u_1} G a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5743)))) b c))
Case conversion may be inaccurate. Consider using '#align eq_div_of_mul_eq'' eq_div_of_mul_eq''ₓ'. -/
@[to_additive eq_sub_of_add_eq']
theorem eq_div_of_mul_eq'' (h : c * a = b) : a = b / c := by simp [h.symm]
#align eq_div_of_mul_eq'' eq_div_of_mul_eq''

/- warning: eq_mul_of_div_eq' -> eq_mul_of_div_eq' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) c) -> (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5773 : CommGroup.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5773)))) a b) c) -> (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5773)))))) b c))
Case conversion may be inaccurate. Consider using '#align eq_mul_of_div_eq' eq_mul_of_div_eq'ₓ'. -/
@[to_additive]
theorem eq_mul_of_div_eq' (h : a / b = c) : a = b * c := by simp [h.symm]
#align eq_mul_of_div_eq' eq_mul_of_div_eq'

/- warning: mul_eq_of_eq_div' -> mul_eq_of_eq_div' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G}, (Eq.{succ u_3} G b (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c a)) -> (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a b) c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5803 : CommGroup.{u_1} G] {a : G} {b : G} {c : G}, (Eq.{succ u_1} G b (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5803)))) c a)) -> (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5803)))))) a b) c)
Case conversion may be inaccurate. Consider using '#align mul_eq_of_eq_div' mul_eq_of_eq_div'ₓ'. -/
@[to_additive]
theorem mul_eq_of_eq_div' (h : b = c / a) : a * b = c := by
  simp [h]
  rw [mul_comm c, mul_inv_cancel_left]
#align mul_eq_of_eq_div' mul_eq_of_eq_div'

/- warning: div_div_self' -> div_div_self' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b)) b
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5860 : CommGroup.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5860)))) a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5860)))) a b)) b
Case conversion may be inaccurate. Consider using '#align div_div_self' div_div_self'ₓ'. -/
@[to_additive sub_sub_self]
theorem div_div_self' (a b : G) : a / (a / b) = b := by simpa using mul_inv_cancel_left a b
#align div_div_self' div_div_self'

/- warning: div_eq_div_mul_div -> div_eq_div_mul_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5914 : CommGroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5914)))) a b) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5914)))))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5914)))) c b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5914)))) a c))
Case conversion may be inaccurate. Consider using '#align div_eq_div_mul_div div_eq_div_mul_divₓ'. -/
@[to_additive]
theorem div_eq_div_mul_div (a b c : G) : a / b = c / b * (a / c) := by simp [mul_left_comm c]
#align div_eq_div_mul_div div_eq_div_mul_div

/- warning: div_div_cancel -> div_div_cancel is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b)) b
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5947 : CommGroup.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5947)))) a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5947)))) a b)) b
Case conversion may be inaccurate. Consider using '#align div_div_cancel div_div_cancelₓ'. -/
@[simp, to_additive]
theorem div_div_cancel (a b : G) : a / (a / b) = b :=
  div_div_self' a b
#align div_div_cancel div_div_cancel

/- warning: div_div_cancel_left -> div_div_cancel_left is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) a) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1))) b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.5972 : CommGroup.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5972)))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5972)))) a b) a) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (DivisionCommMonoid.toDivisionMonoid.{u_1} G (CommGroup.toDivisionCommMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.5972))))) b)
Case conversion may be inaccurate. Consider using '#align div_div_cancel_left div_div_cancel_leftₓ'. -/
@[simp, to_additive]
theorem div_div_cancel_left (a b : G) : a / b / a = b⁻¹ := by simp
#align div_div_cancel_left div_div_cancel_left

/- warning: eq_div_iff_mul_eq'' -> eq_div_iff_mul_eq'' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) b c)) (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) c a) b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6002 : CommGroup.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6002)))) b c)) (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6002)))))) c a) b)
Case conversion may be inaccurate. Consider using '#align eq_div_iff_mul_eq'' eq_div_iff_mul_eq''ₓ'. -/
@[to_additive eq_sub_iff_add_eq']
theorem eq_div_iff_mul_eq'' : a = b / c ↔ c * a = b := by rw [eq_div_iff_mul_eq', mul_comm]
#align eq_div_iff_mul_eq'' eq_div_iff_mul_eq''

/- warning: div_eq_iff_eq_mul' -> div_eq_iff_eq_mul' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) c) (Eq.{succ u_3} G a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) b c))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6059 : CommGroup.{u_1} G] {a : G} {b : G} {c : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6059)))) a b) c) (Eq.{succ u_1} G a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6059)))))) b c))
Case conversion may be inaccurate. Consider using '#align div_eq_iff_eq_mul' div_eq_iff_eq_mul'ₓ'. -/
@[to_additive]
theorem div_eq_iff_eq_mul' : a / b = c ↔ a = b * c := by rw [div_eq_iff_eq_mul, mul_comm]
#align div_eq_iff_eq_mul' div_eq_iff_eq_mul'

/- warning: mul_div_cancel''' -> mul_div_cancel''' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a b) a) b
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6116 : CommGroup.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6116)))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6116)))))) a b) a) b
Case conversion may be inaccurate. Consider using '#align mul_div_cancel''' mul_div_cancel'''ₓ'. -/
@[simp, to_additive add_sub_cancel']
theorem mul_div_cancel''' (a b : G) : a * b / a = b := by rw [div_eq_inv_mul, inv_mul_cancel_left]
#align mul_div_cancel''' mul_div_cancel'''

/- warning: mul_div_cancel'_right -> mul_div_cancel'_right is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) b a)) b
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6168 : CommGroup.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6168)))))) a (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6168)))) b a)) b
Case conversion may be inaccurate. Consider using '#align mul_div_cancel'_right mul_div_cancel'_rightₓ'. -/
@[simp, to_additive]
theorem mul_div_cancel'_right (a b : G) : a * (b / a) = b := by rw [← mul_div_assoc, mul_div_cancel''']
#align mul_div_cancel'_right mul_div_cancel'_right

/- warning: div_mul_cancel'' -> div_mul_cancel'' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a b)) (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1))) b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6220 : CommGroup.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6220)))) a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6220)))))) a b)) (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (DivisionCommMonoid.toDivisionMonoid.{u_1} G (CommGroup.toDivisionCommMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6220))))) b)
Case conversion may be inaccurate. Consider using '#align div_mul_cancel'' div_mul_cancel''ₓ'. -/
@[simp, to_additive sub_add_cancel']
theorem div_mul_cancel'' (a b : G) : a / (a * b) = b⁻¹ := by rw [← inv_div, mul_div_cancel''']
#align div_mul_cancel'' div_mul_cancel''

/- warning: mul_mul_inv_cancel'_right -> mul_mul_inv_cancel'_right is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) b (Inv.inv.{u_3} G (DivInvMonoid.toHasInv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1))) a))) b
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6276 : CommGroup.{u_1} G] (a : G) (b : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6276)))))) a (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6276)))))) b (Inv.inv.{u_1} G (InvOneClass.toInv.{u_1} G (DivInvOneMonoid.toInvOneClass.{u_1} G (DivisionMonoid.toDivInvOneMonoid.{u_1} G (DivisionCommMonoid.toDivisionMonoid.{u_1} G (CommGroup.toDivisionCommMonoid.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6276))))) a))) b
Case conversion may be inaccurate. Consider using '#align mul_mul_inv_cancel'_right mul_mul_inv_cancel'_rightₓ'. -/
-- This lemma is in the `simp` set under the name `mul_inv_cancel_comm_assoc`,
-- along with the additive version `add_neg_cancel_comm_assoc`,
-- defined  in `algebra/group/commute`
@[to_additive]
theorem mul_mul_inv_cancel'_right (a b : G) : a * (b * a⁻¹) = b := by rw [← div_eq_mul_inv, mul_div_cancel'_right a b]
#align mul_mul_inv_cancel'_right mul_mul_inv_cancel'_right

/- warning: mul_mul_div_cancel -> mul_mul_div_cancel is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a c) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) b c)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6334 : CommGroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6334)))))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6334)))))) a c) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6334)))) b c)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6334)))))) a b)
Case conversion may be inaccurate. Consider using '#align mul_mul_div_cancel mul_mul_div_cancelₓ'. -/
@[simp, to_additive]
theorem mul_mul_div_cancel (a b c : G) : a * c * (b / c) = a * b := by rw [mul_assoc, mul_div_cancel'_right]
#align mul_mul_div_cancel mul_mul_div_cancel

/- warning: div_mul_mul_cancel -> div_mul_mul_cancel is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a c) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) b c)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6391 : CommGroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6391)))))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6391)))) a c) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6391)))))) b c)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6391)))))) a b)
Case conversion may be inaccurate. Consider using '#align div_mul_mul_cancel div_mul_mul_cancelₓ'. -/
@[simp, to_additive]
theorem div_mul_mul_cancel (a b c : G) : a / c * (b * c) = a * b := by rw [mul_left_comm, div_mul_cancel', mul_comm]
#align div_mul_mul_cancel div_mul_mul_cancel

/- warning: div_mul_div_cancel'' -> div_mul_div_cancel'' is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c a)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c b)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6449 : CommGroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6449)))))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6449)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6449)))) c a)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6449)))) c b)
Case conversion may be inaccurate. Consider using '#align div_mul_div_cancel'' div_mul_div_cancel''ₓ'. -/
@[simp, to_additive sub_add_sub_cancel']
theorem div_mul_div_cancel'' (a b c : G) : a / b * (c / a) = c / b := by rw [mul_comm] <;> apply div_mul_div_cancel'
#align div_mul_div_cancel'' div_mul_div_cancel''

/- warning: mul_div_div_cancel -> mul_div_div_cancel is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a c)) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) b c)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6509 : CommGroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6509)))) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6509)))))) a b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6509)))) a c)) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6509)))))) b c)
Case conversion may be inaccurate. Consider using '#align mul_div_div_cancel mul_div_div_cancelₓ'. -/
@[simp, to_additive]
theorem mul_div_div_cancel (a b c : G) : a * b / (a / c) = b * c := by rw [← div_mul, mul_div_cancel''']
#align mul_div_div_cancel mul_div_div_cancel

/- warning: div_div_div_cancel_left -> div_div_div_cancel_left is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] (a : G) (b : G) (c : G), Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c a) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c b)) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) b a)
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6566 : CommGroup.{u_1} G] (a : G) (b : G) (c : G), Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6566)))) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6566)))) c a) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6566)))) c b)) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6566)))) b a)
Case conversion may be inaccurate. Consider using '#align div_div_div_cancel_left div_div_div_cancel_leftₓ'. -/
@[simp, to_additive]
theorem div_div_div_cancel_left (a b c : G) : c / a / (c / b) = b / a := by
  rw [← inv_div b c, div_inv_eq_mul, mul_comm, div_mul_div_cancel']
#align div_div_div_cancel_left div_div_div_cancel_left

/- warning: div_eq_div_iff_mul_eq_mul -> div_eq_div_iff_mul_eq_mul is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G} {d : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c d)) (Eq.{succ u_3} G (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) a d) (HMul.hMul.{u_3 u_3 u_3} G G G (instHMul.{u_3} G (MulOneClass.toHasMul.{u_3} G (Monoid.toMulOneClass.{u_3} G (DivInvMonoid.toMonoid.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))))) c b))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6627 : CommGroup.{u_1} G] {a : G} {b : G} {c : G} {d : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6627)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6627)))) c d)) (Eq.{succ u_1} G (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6627)))))) a d) (HMul.hMul.{u_1 u_1 u_1} G G G (instHMul.{u_1} G (MulOneClass.toMul.{u_1} G (Monoid.toMulOneClass.{u_1} G (DivInvMonoid.toMonoid.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6627)))))) c b))
Case conversion may be inaccurate. Consider using '#align div_eq_div_iff_mul_eq_mul div_eq_div_iff_mul_eq_mulₓ'. -/
@[to_additive]
theorem div_eq_div_iff_mul_eq_mul : a / b = c / d ↔ a * d = c * b := by
  rw [div_eq_iff_eq_mul, div_mul_eq_mul_div, eq_comm, div_eq_iff_eq_mul']
  simp only [mul_comm, eq_comm]
#align div_eq_div_iff_mul_eq_mul div_eq_div_iff_mul_eq_mul

/- warning: div_eq_div_iff_div_eq_div -> div_eq_div_iff_div_eq_div is a dubious translation:
lean 3 declaration is
  forall {G : Type.{u_3}} [_inst_1 : CommGroup.{u_3} G] {a : G} {b : G} {c : G} {d : G}, Iff (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a b) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) c d)) (Eq.{succ u_3} G (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) a c) (HDiv.hDiv.{u_3 u_3 u_3} G G G (instHDiv.{u_3} G (DivInvMonoid.toHasDiv.{u_3} G (Group.toDivInvMonoid.{u_3} G (CommGroup.toGroup.{u_3} G _inst_1)))) b d))
but is expected to have type
  forall {G : Type.{u_1}} [inst._@.Mathlib.Algebra.Group.Basic._hyg.6700 : CommGroup.{u_1} G] {a : G} {b : G} {c : G} {d : G}, Iff (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6700)))) a b) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6700)))) c d)) (Eq.{succ u_1} G (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6700)))) a c) (HDiv.hDiv.{u_1 u_1 u_1} G G G (instHDiv.{u_1} G (DivInvMonoid.toDiv.{u_1} G (Group.toDivInvMonoid.{u_1} G (CommGroup.toGroup.{u_1} G inst._@.Mathlib.Algebra.Group.Basic._hyg.6700)))) b d))
Case conversion may be inaccurate. Consider using '#align div_eq_div_iff_div_eq_div div_eq_div_iff_div_eq_divₓ'. -/
@[to_additive]
theorem div_eq_div_iff_div_eq_div : a / b = c / d ↔ a / c = b / d := by
  rw [div_eq_iff_eq_mul, div_mul_eq_mul_div, div_eq_iff_eq_mul', mul_div_assoc]
#align div_eq_div_iff_div_eq_div div_eq_div_iff_div_eq_div

end CommGroup

section SubtractionCommMonoid

variable {M : Type u} [SubtractionCommMonoid M]

theorem bit0_sub (a b : M) : bit0 (a - b) = bit0 a - bit0 b :=
  sub_add_sub_comm _ _ _ _
#align bit0_sub bit0_sub

theorem bit1_sub [One M] (a b : M) : bit1 (a - b) = bit1 a - bit0 b :=
  (congr_arg (· + (1 : M)) <| bit0_sub a b : _).trans <| sub_add_eq_add_sub _ _ _
#align bit1_sub bit1_sub

end SubtractionCommMonoid

