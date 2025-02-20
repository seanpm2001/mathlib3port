/-
Copyright (c) 2014 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Floris van Doorn, Yury Kudryashov, Neil Strickland

! This file was ported from Lean 3 source module algebra.ring.defs
! leanprover-community/mathlib commit 76de8ae01554c3b37d66544866659ff174e66e1f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Basic
import Mathbin.Algebra.GroupWithZero.Defs
import Mathbin.Data.Int.Cast.Defs

/-!
# Semirings and rings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines semirings, rings and domains. This is analogous to `algebra.group.defs` and
`algebra.group.basic`, the difference being that the former is about `+` and `*` separately, while
the present file is about their interaction.

## Main definitions

* `distrib`: Typeclass for distributivity of multiplication over addition.
* `has_distrib_neg`: Typeclass for commutativity of negation and multiplication. This is useful when
  dealing with multiplicative submonoids which are closed under negation without being closed under
  addition, for example `units`.
* `(non_unital_)(non_assoc_)(semi)ring`: Typeclasses for possibly non-unital or non-associative
  rings and semirings. Some combinations are not defined yet because they haven't found use.

## Tags

`semiring`, `comm_semiring`, `ring`, `comm_ring`, `domain`, `is_domain`, `nonzero`, `units`
-/


universe u v w x

variable {α : Type u} {β : Type v} {γ : Type w} {R : Type x}

open Function

/-!
### `distrib` class
-/


#print Distrib /-
/-- A typeclass stating that multiplication is left and right distributive
over addition. -/
@[protect_proj]
class Distrib (R : Type _) extends Mul R, Add R where
  left_distrib : ∀ a b c : R, a * (b + c) = a * b + a * c
  right_distrib : ∀ a b c : R, (a + b) * c = a * c + b * c
#align distrib Distrib
-/

#print LeftDistribClass /-
/-- A typeclass stating that multiplication is left distributive over addition. -/
@[protect_proj]
class LeftDistribClass (R : Type _) [Mul R] [Add R] where
  left_distrib : ∀ a b c : R, a * (b + c) = a * b + a * c
#align left_distrib_class LeftDistribClass
-/

#print RightDistribClass /-
/-- A typeclass stating that multiplication is right distributive over addition. -/
@[protect_proj]
class RightDistribClass (R : Type _) [Mul R] [Add R] where
  right_distrib : ∀ a b c : R, (a + b) * c = a * c + b * c
#align right_distrib_class RightDistribClass
-/

#print Distrib.leftDistribClass /-
-- see Note [lower instance priority]
instance (priority := 100) Distrib.leftDistribClass (R : Type _) [Distrib R] : LeftDistribClass R :=
  ⟨Distrib.left_distrib⟩
#align distrib.left_distrib_class Distrib.leftDistribClass
-/

#print Distrib.rightDistribClass /-
-- see Note [lower instance priority]
instance (priority := 100) Distrib.rightDistribClass (R : Type _) [Distrib R] :
    RightDistribClass R :=
  ⟨Distrib.right_distrib⟩
#align distrib.right_distrib_class Distrib.rightDistribClass
-/

#print left_distrib /-
theorem left_distrib [Mul R] [Add R] [LeftDistribClass R] (a b c : R) :
    a * (b + c) = a * b + a * c :=
  LeftDistribClass.left_distrib a b c
#align left_distrib left_distrib
-/

alias left_distrib ← mul_add
#align mul_add mul_add

#print right_distrib /-
theorem right_distrib [Mul R] [Add R] [RightDistribClass R] (a b c : R) :
    (a + b) * c = a * c + b * c :=
  RightDistribClass.right_distrib a b c
#align right_distrib right_distrib
-/

alias right_distrib ← add_mul
#align add_mul add_mul

#print distrib_three_right /-
theorem distrib_three_right [Mul R] [Add R] [RightDistribClass R] (a b c d : R) :
    (a + b + c) * d = a * d + b * d + c * d := by simp [right_distrib]
#align distrib_three_right distrib_three_right
-/

/-!
### Semirings
-/


#print NonUnitalNonAssocSemiring /-
/-- A not-necessarily-unital, not-necessarily-associative semiring. -/
@[protect_proj]
class NonUnitalNonAssocSemiring (α : Type u) extends AddCommMonoid α, Distrib α, MulZeroClass α
#align non_unital_non_assoc_semiring NonUnitalNonAssocSemiring
-/

#print NonUnitalSemiring /-
/-- An associative but not-necessarily unital semiring. -/
@[protect_proj]
class NonUnitalSemiring (α : Type u) extends NonUnitalNonAssocSemiring α, SemigroupWithZero α
#align non_unital_semiring NonUnitalSemiring
-/

#print NonAssocSemiring /-
/-- A unital but not-necessarily-associative semiring. -/
@[protect_proj]
class NonAssocSemiring (α : Type u) extends NonUnitalNonAssocSemiring α, MulZeroOneClass α,
    AddCommMonoidWithOne α
#align non_assoc_semiring NonAssocSemiring
-/

#print Semiring /-
/-- A semiring is a type with the following structures: additive commutative monoid
(`add_comm_monoid`), multiplicative monoid (`monoid`), distributive laws (`distrib`), and
multiplication by zero law (`mul_zero_class`). The actual definition extends `monoid_with_zero`
instead of `monoid` and `mul_zero_class`. -/
@[protect_proj]
class Semiring (α : Type u) extends NonUnitalSemiring α, NonAssocSemiring α, MonoidWithZero α
#align semiring Semiring
-/

section HasOneHasAdd

variable [One α] [Add α]

#print one_add_one_eq_two /-
theorem one_add_one_eq_two : 1 + 1 = (2 : α) :=
  rfl
#align one_add_one_eq_two one_add_one_eq_two
-/

end HasOneHasAdd

section DistribMulOneClass

variable [Add α] [MulOneClass α]

#print add_one_mul /-
theorem add_one_mul [RightDistribClass α] (a b : α) : (a + 1) * b = a * b + b := by
  rw [add_mul, one_mul]
#align add_one_mul add_one_mul
-/

#print mul_add_one /-
theorem mul_add_one [LeftDistribClass α] (a b : α) : a * (b + 1) = a * b + a := by
  rw [mul_add, mul_one]
#align mul_add_one mul_add_one
-/

#print one_add_mul /-
theorem one_add_mul [RightDistribClass α] (a b : α) : (1 + a) * b = b + a * b := by
  rw [add_mul, one_mul]
#align one_add_mul one_add_mul
-/

#print mul_one_add /-
theorem mul_one_add [LeftDistribClass α] (a b : α) : a * (1 + b) = a + a * b := by
  rw [mul_add, mul_one]
#align mul_one_add mul_one_add
-/

#print two_mul /-
theorem two_mul [RightDistribClass α] (n : α) : 2 * n = n + n :=
  Eq.trans (right_distrib 1 1 n) (by simp)
#align two_mul two_mul
-/

#print bit0_eq_two_mul /-
theorem bit0_eq_two_mul [RightDistribClass α] (n : α) : bit0 n = 2 * n :=
  (two_mul _).symm
#align bit0_eq_two_mul bit0_eq_two_mul
-/

#print mul_two /-
theorem mul_two [LeftDistribClass α] (n : α) : n * 2 = n + n :=
  (left_distrib n 1 1).trans (by simp)
#align mul_two mul_two
-/

end DistribMulOneClass

section Semiring

variable [Semiring α]

#print mul_ite /-
@[to_additive]
theorem mul_ite {α} [Mul α] (P : Prop) [Decidable P] (a b c : α) :
    (a * if P then b else c) = if P then a * b else a * c := by split_ifs <;> rfl
#align mul_ite mul_ite
#align add_ite add_ite
-/

#print ite_mul /-
@[to_additive]
theorem ite_mul {α} [Mul α] (P : Prop) [Decidable P] (a b c : α) :
    (if P then a else b) * c = if P then a * c else b * c := by split_ifs <;> rfl
#align ite_mul ite_mul
#align ite_add ite_add
-/

-- We make `mul_ite` and `ite_mul` simp lemmas,
-- but not `add_ite` or `ite_add`.
-- The problem we're trying to avoid is dealing with
-- summations of the form `∑ x in s, (f x + ite P 1 0)`,
-- in which `add_ite` followed by `sum_ite` would needlessly slice up
-- the `f x` terms according to whether `P` holds at `x`.
-- There doesn't appear to be a corresponding difficulty so far with
-- `mul_ite` and `ite_mul`.
attribute [simp] mul_ite ite_mul

#print mul_boole /-
@[simp]
theorem mul_boole {α} [MulZeroOneClass α] (P : Prop) [Decidable P] (a : α) :
    (a * if P then 1 else 0) = if P then a else 0 := by simp
#align mul_boole mul_boole
-/

#print boole_mul /-
@[simp]
theorem boole_mul {α} [MulZeroOneClass α] (P : Prop) [Decidable P] (a : α) :
    (if P then 1 else 0) * a = if P then a else 0 := by simp
#align boole_mul boole_mul
-/

#print ite_mul_zero_left /-
theorem ite_mul_zero_left {α : Type _} [MulZeroClass α] (P : Prop) [Decidable P] (a b : α) :
    ite P (a * b) 0 = ite P a 0 * b := by by_cases h : P <;> simp [h]
#align ite_mul_zero_left ite_mul_zero_left
-/

#print ite_mul_zero_right /-
theorem ite_mul_zero_right {α : Type _} [MulZeroClass α] (P : Prop) [Decidable P] (a b : α) :
    ite P (a * b) 0 = a * ite P b 0 := by by_cases h : P <;> simp [h]
#align ite_mul_zero_right ite_mul_zero_right
-/

#print ite_and_mul_zero /-
theorem ite_and_mul_zero {α : Type _} [MulZeroClass α] (P Q : Prop) [Decidable P] [Decidable Q]
    (a b : α) : ite (P ∧ Q) (a * b) 0 = ite P a 0 * ite Q b 0 := by
  simp only [← ite_and, ite_mul, mul_ite, MulZeroClass.mul_zero, MulZeroClass.zero_mul, and_comm']
#align ite_and_mul_zero ite_and_mul_zero
-/

end Semiring

#print NonUnitalCommSemiring /-
/-- A non-unital commutative semiring is a `non_unital_semiring` with commutative multiplication.
In other words, it is a type with the following structures: additive commutative monoid
(`add_comm_monoid`), commutative semigroup (`comm_semigroup`), distributive laws (`distrib`), and
multiplication by zero law (`mul_zero_class`). -/
@[protect_proj]
class NonUnitalCommSemiring (α : Type u) extends NonUnitalSemiring α, CommSemigroup α
#align non_unital_comm_semiring NonUnitalCommSemiring
-/

#print CommSemiring /-
/-- A commutative semiring is a `semiring` with commutative multiplication. In other words, it is a
type with the following structures: additive commutative monoid (`add_comm_monoid`), multiplicative
commutative monoid (`comm_monoid`), distributive laws (`distrib`), and multiplication by zero law
(`mul_zero_class`). -/
@[protect_proj]
class CommSemiring (α : Type u) extends Semiring α, CommMonoid α
#align comm_semiring CommSemiring
-/

#print CommSemiring.toNonUnitalCommSemiring /-
-- see Note [lower instance priority]
instance (priority := 100) CommSemiring.toNonUnitalCommSemiring [CommSemiring α] :
    NonUnitalCommSemiring α :=
  { CommSemiring.toCommMonoid α, CommSemiring.toSemiring α with }
#align comm_semiring.to_non_unital_comm_semiring CommSemiring.toNonUnitalCommSemiring
-/

#print CommSemiring.toCommMonoidWithZero /-
-- see Note [lower instance priority]
instance (priority := 100) CommSemiring.toCommMonoidWithZero [CommSemiring α] :
    CommMonoidWithZero α :=
  { CommSemiring.toCommMonoid α, CommSemiring.toSemiring α with }
#align comm_semiring.to_comm_monoid_with_zero CommSemiring.toCommMonoidWithZero
-/

section CommSemiring

variable [CommSemiring α] {a b c : α}

#print add_mul_self_eq /-
theorem add_mul_self_eq (a b : α) : (a + b) * (a + b) = a * a + 2 * a * b + b * b := by
  simp only [two_mul, add_mul, mul_add, add_assoc, mul_comm b]
#align add_mul_self_eq add_mul_self_eq
-/

end CommSemiring

section HasDistribNeg

#print HasDistribNeg /-
/-- Typeclass for a negation operator that distributes across multiplication.

This is useful for dealing with submonoids of a ring that contain `-1` without having to duplicate
lemmas. -/
class HasDistribNeg (α : Type _) [Mul α] extends InvolutiveNeg α where
  neg_mul : ∀ x y : α, -x * y = -(x * y)
  mul_neg : ∀ x y : α, x * -y = -(x * y)
#align has_distrib_neg HasDistribNeg
-/

section Mul

variable [Mul α] [HasDistribNeg α]

#print neg_mul /-
@[simp]
theorem neg_mul (a b : α) : -a * b = -(a * b) :=
  HasDistribNeg.neg_mul _ _
#align neg_mul neg_mul
-/

#print mul_neg /-
@[simp]
theorem mul_neg (a b : α) : a * -b = -(a * b) :=
  HasDistribNeg.mul_neg _ _
#align mul_neg mul_neg
-/

#print neg_mul_neg /-
theorem neg_mul_neg (a b : α) : -a * -b = a * b := by simp
#align neg_mul_neg neg_mul_neg
-/

#print neg_mul_eq_neg_mul /-
theorem neg_mul_eq_neg_mul (a b : α) : -(a * b) = -a * b :=
  (neg_mul _ _).symm
#align neg_mul_eq_neg_mul neg_mul_eq_neg_mul
-/

#print neg_mul_eq_mul_neg /-
theorem neg_mul_eq_mul_neg (a b : α) : -(a * b) = a * -b :=
  (mul_neg _ _).symm
#align neg_mul_eq_mul_neg neg_mul_eq_mul_neg
-/

#print neg_mul_comm /-
theorem neg_mul_comm (a b : α) : -a * b = a * -b := by simp
#align neg_mul_comm neg_mul_comm
-/

end Mul

section MulOneClass

variable [MulOneClass α] [HasDistribNeg α]

#print neg_eq_neg_one_mul /-
theorem neg_eq_neg_one_mul (a : α) : -a = -1 * a := by simp
#align neg_eq_neg_one_mul neg_eq_neg_one_mul
-/

#print mul_neg_one /-
/-- An element of a ring multiplied by the additive inverse of one is the element's additive
  inverse. -/
theorem mul_neg_one (a : α) : a * -1 = -a := by simp
#align mul_neg_one mul_neg_one
-/

#print neg_one_mul /-
/-- The additive inverse of one multiplied by an element of a ring is the element's additive
  inverse. -/
theorem neg_one_mul (a : α) : -1 * a = -a := by simp
#align neg_one_mul neg_one_mul
-/

end MulOneClass

section MulZeroClass

variable [MulZeroClass α] [HasDistribNeg α]

#print MulZeroClass.negZeroClass /-
instance (priority := 100) MulZeroClass.negZeroClass : NegZeroClass α :=
  { MulZeroClass.toHasZero α, HasDistribNeg.toHasInvolutiveNeg α with
    neg_zero := by
      rw [← MulZeroClass.zero_mul (0 : α), ← neg_mul, MulZeroClass.mul_zero,
        MulZeroClass.mul_zero] }
#align mul_zero_class.neg_zero_class MulZeroClass.negZeroClass
-/

end MulZeroClass

end HasDistribNeg

/-!
### Rings
-/


#print NonUnitalNonAssocRing /-
/-- A not-necessarily-unital, not-necessarily-associative ring. -/
@[protect_proj]
class NonUnitalNonAssocRing (α : Type u) extends AddCommGroup α, NonUnitalNonAssocSemiring α
#align non_unital_non_assoc_ring NonUnitalNonAssocRing
-/

#print NonUnitalRing /-
-- We defer the instance `non_unital_non_assoc_ring.to_has_distrib_neg` to `algebra.ring.basic`
-- as it relies on the lemma `eq_neg_of_add_eq_zero_left`.
/-- An associative but not-necessarily unital ring. -/
@[protect_proj]
class NonUnitalRing (α : Type _) extends NonUnitalNonAssocRing α, NonUnitalSemiring α
#align non_unital_ring NonUnitalRing
-/

#print NonAssocRing /-
/-- A unital but not-necessarily-associative ring. -/
@[protect_proj]
class NonAssocRing (α : Type _) extends NonUnitalNonAssocRing α, NonAssocSemiring α,
    AddCommGroupWithOne α
#align non_assoc_ring NonAssocRing
-/

#print Ring /-
/-- A ring is a type with the following structures: additive commutative group (`add_comm_group`),
multiplicative monoid (`monoid`), and distributive laws (`distrib`).  Equivalently, a ring is a
`semiring` with a negation operation making it an additive group.  -/
@[protect_proj]
class Ring (α : Type u) extends AddCommGroupWithOne α, Monoid α, Distrib α
#align ring Ring
-/

section NonUnitalNonAssocRing

variable [NonUnitalNonAssocRing α]

#print NonUnitalNonAssocRing.toHasDistribNeg /-
instance (priority := 100) NonUnitalNonAssocRing.toHasDistribNeg : HasDistribNeg α
    where
  neg := Neg.neg
  neg_neg := neg_neg
  neg_mul a b :=
    eq_neg_of_add_eq_zero_left <| by rw [← right_distrib, add_left_neg, MulZeroClass.zero_mul]
  mul_neg a b :=
    eq_neg_of_add_eq_zero_left <| by rw [← left_distrib, add_left_neg, MulZeroClass.mul_zero]
#align non_unital_non_assoc_ring.to_has_distrib_neg NonUnitalNonAssocRing.toHasDistribNeg
-/

#print mul_sub_left_distrib /-
theorem mul_sub_left_distrib (a b c : α) : a * (b - c) = a * b - a * c := by
  simpa only [sub_eq_add_neg, neg_mul_eq_mul_neg] using mul_add a b (-c)
#align mul_sub_left_distrib mul_sub_left_distrib
-/

alias mul_sub_left_distrib ← mul_sub
#align mul_sub mul_sub

#print mul_sub_right_distrib /-
theorem mul_sub_right_distrib (a b c : α) : (a - b) * c = a * c - b * c := by
  simpa only [sub_eq_add_neg, neg_mul_eq_neg_mul] using add_mul a (-b) c
#align mul_sub_right_distrib mul_sub_right_distrib
-/

alias mul_sub_right_distrib ← sub_mul
#align sub_mul sub_mul

variable {a b c d e : α}

#print mul_add_eq_mul_add_iff_sub_mul_add_eq /-
/-- An iff statement following from right distributivity in rings and the definition
  of subtraction. -/
theorem mul_add_eq_mul_add_iff_sub_mul_add_eq : a * e + c = b * e + d ↔ (a - b) * e + c = d :=
  calc
    a * e + c = b * e + d ↔ a * e + c = d + b * e := by simp [add_comm]
    _ ↔ a * e + c - b * e = d := (Iff.intro (fun h => by rw [h]; simp) fun h => by rw [← h]; simp)
    _ ↔ (a - b) * e + c = d := by simp [sub_mul, sub_add_eq_add_sub]
#align mul_add_eq_mul_add_iff_sub_mul_add_eq mul_add_eq_mul_add_iff_sub_mul_add_eq
-/

#print sub_mul_add_eq_of_mul_add_eq_mul_add /-
/-- A simplification of one side of an equation exploiting right distributivity in rings
  and the definition of subtraction. -/
theorem sub_mul_add_eq_of_mul_add_eq_mul_add : a * e + c = b * e + d → (a - b) * e + c = d :=
  fun h =>
  calc
    (a - b) * e + c = a * e + c - b * e := by simp [sub_mul, sub_add_eq_add_sub]
    _ = d := by rw [h]; simp [@add_sub_cancel α]
#align sub_mul_add_eq_of_mul_add_eq_mul_add sub_mul_add_eq_of_mul_add_eq_mul_add
-/

end NonUnitalNonAssocRing

section NonAssocRing

variable [NonAssocRing α]

#print sub_one_mul /-
theorem sub_one_mul (a b : α) : (a - 1) * b = a * b - b := by rw [sub_mul, one_mul]
#align sub_one_mul sub_one_mul
-/

#print mul_sub_one /-
theorem mul_sub_one (a b : α) : a * (b - 1) = a * b - a := by rw [mul_sub, mul_one]
#align mul_sub_one mul_sub_one
-/

#print one_sub_mul /-
theorem one_sub_mul (a b : α) : (1 - a) * b = b - a * b := by rw [sub_mul, one_mul]
#align one_sub_mul one_sub_mul
-/

#print mul_one_sub /-
theorem mul_one_sub (a b : α) : a * (1 - b) = a - a * b := by rw [mul_sub, mul_one]
#align mul_one_sub mul_one_sub
-/

end NonAssocRing

section Ring

variable [Ring α] {a b c d e : α}

#print Ring.toNonUnitalRing /-
-- A (unital, associative) ring is a not-necessarily-unital ring 
-- see Note [lower instance priority]
instance (priority := 100) Ring.toNonUnitalRing : NonUnitalRing α :=
  {
    ‹Ring
        α› with
    zero_mul := fun a =>
      add_left_cancel <| show 0 * a + 0 * a = 0 * a + 0 by rw [← add_mul, zero_add, add_zero]
    mul_zero := fun a =>
      add_left_cancel <| show a * 0 + a * 0 = a * 0 + 0 by rw [← mul_add, add_zero, add_zero] }
#align ring.to_non_unital_ring Ring.toNonUnitalRing
-/

#print Ring.toNonAssocRing /-
-- A (unital, associative) ring is a not-necessarily-associative ring 
-- see Note [lower instance priority]
instance (priority := 100) Ring.toNonAssocRing : NonAssocRing α :=
  {
    ‹Ring
        α› with
    zero_mul := fun a =>
      add_left_cancel <| show 0 * a + 0 * a = 0 * a + 0 by rw [← add_mul, zero_add, add_zero]
    mul_zero := fun a =>
      add_left_cancel <| show a * 0 + a * 0 = a * 0 + 0 by rw [← mul_add, add_zero, add_zero] }
#align ring.to_non_assoc_ring Ring.toNonAssocRing
-/

#print Ring.toSemiring /-
/- The instance from `ring` to `semiring` happens often in linear algebra, for which all the basic
definitions are given in terms of semirings, but many applications use rings or fields. We increase
a little bit its priority above 100 to try it quickly, but remaining below the default 1000 so that
more specific instances are tried first. -/
instance (priority := 200) Ring.toSemiring : Semiring α :=
  { ‹Ring α›, Ring.toNonUnitalRing with }
#align ring.to_semiring Ring.toSemiring
-/

end Ring

#print NonUnitalCommRing /-
/-- A non-unital commutative ring is a `non_unital_ring` with commutative multiplication. -/
@[protect_proj]
class NonUnitalCommRing (α : Type u) extends NonUnitalRing α, CommSemigroup α
#align non_unital_comm_ring NonUnitalCommRing
-/

#print NonUnitalCommRing.toNonUnitalCommSemiring /-
-- see Note [lower instance priority]
instance (priority := 100) NonUnitalCommRing.toNonUnitalCommSemiring [s : NonUnitalCommRing α] :
    NonUnitalCommSemiring α :=
  { s with }
#align non_unital_comm_ring.to_non_unital_comm_semiring NonUnitalCommRing.toNonUnitalCommSemiring
-/

#print CommRing /-
/-- A commutative ring is a `ring` with commutative multiplication. -/
@[protect_proj]
class CommRing (α : Type u) extends Ring α, CommMonoid α
#align comm_ring CommRing
-/

#print CommRing.toCommSemiring /-
-- see Note [lower instance priority]
instance (priority := 100) CommRing.toCommSemiring [s : CommRing α] : CommSemiring α :=
  { s with
    mul_zero := MulZeroClass.mul_zero
    zero_mul := MulZeroClass.zero_mul }
#align comm_ring.to_comm_semiring CommRing.toCommSemiring
-/

#print CommRing.toNonUnitalCommRing /-
-- see Note [lower instance priority]
instance (priority := 100) CommRing.toNonUnitalCommRing [s : CommRing α] : NonUnitalCommRing α :=
  { s with
    mul_zero := MulZeroClass.mul_zero
    zero_mul := MulZeroClass.zero_mul }
#align comm_ring.to_non_unital_comm_ring CommRing.toNonUnitalCommRing
-/

#print IsDomain /-
/-- A domain is a nontrivial semiring such multiplication by a non zero element is cancellative,
  on both sides. In other words, a nontrivial semiring `R` satisfying
  `∀ {a b c : R}, a ≠ 0 → a * b = a * c → b = c` and
  `∀ {a b c : R}, b ≠ 0 → a * b = c * b → a = c`.

  This is implemented as a mixin for `semiring α`.
  To obtain an integral domain use `[comm_ring α] [is_domain α]`. -/
@[protect_proj]
class IsDomain (α : Type u) [Semiring α] extends IsCancelMulZero α, Nontrivial α : Prop
#align is_domain IsDomain
-/

