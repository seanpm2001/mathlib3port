/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Johan Commelin

! This file was ported from Lean 3 source module algebra.group.with_one.defs
! leanprover-community/mathlib commit 995b47e555f1b6297c7cf16855f1023e355219fb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.WithBot
import Mathbin.Algebra.Ring.Defs

/-!
# Adjoining a zero/one to semigroups and related algebraic structures

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains different results about adjoining an element to an algebraic structure which then
behaves like a zero or a one. An example is adjoining a one to a semigroup to obtain a monoid. That
this provides an example of an adjunction is proved in `algebra.category.Mon.adjunctions`.

Another result says that adjoining to a group an element `zero` gives a `group_with_zero`. For more
information about these structures (which are not that standard in informal mathematics, see
`algebra.group_with_zero.basic`)

## Implementation notes

At various points in this file, `id $` is used in at the start of a proof field in a structure. This
ensures that the generated `_proof_1` lemmas are stated in terms of the algebraic operations and
not `option.map`, as the latter does not typecheck once `with_zero`/`with_one` is irreducible.
-/


universe u v w

variable {α : Type u} {β : Type v} {γ : Type w}

#print WithOne /-
/-- Add an extra element `1` to a type -/
@[to_additive "Add an extra element `0` to a type"]
def WithOne (α) :=
  Option α
#align with_one WithOne
#align with_zero WithZero
-/

namespace WithOne

instance [Repr α] : Repr (WithZero α) :=
  ⟨fun o =>
    match o with
    | none => "0"
    | some a => "↑" ++ repr a⟩

@[to_additive]
instance [Repr α] : Repr (WithOne α) :=
  ⟨fun o =>
    match o with
    | none => "1"
    | some a => "↑" ++ repr a⟩

@[to_additive]
instance : Monad WithOne :=
  Option.monad

@[to_additive]
instance : One (WithOne α) :=
  ⟨none⟩

@[to_additive]
instance [Mul α] : Mul (WithOne α) :=
  ⟨Option.liftOrGet (· * ·)⟩

@[to_additive]
instance [Inv α] : Inv (WithOne α) :=
  ⟨fun a => Option.map Inv.inv a⟩

@[to_additive]
instance [InvolutiveInv α] : InvolutiveInv (WithOne α) :=
  { WithOne.inv with
    inv_inv :=
      id fun a => (Option.map_map _ _ _).trans <| by simp_rw [inv_comp_inv, Option.map_id, id] }

@[to_additive]
instance [Inv α] : InvOneClass (WithOne α) :=
  { WithOne.one, WithOne.inv with inv_one := rfl }

@[to_additive]
instance : Inhabited (WithOne α) :=
  ⟨1⟩

@[to_additive]
instance [Nonempty α] : Nontrivial (WithOne α) :=
  Option.nontrivial

@[to_additive]
instance : CoeTC α (WithOne α) :=
  ⟨some⟩

#print WithOne.recOneCoe /-
/-- Recursor for `with_one` using the preferred forms `1` and `↑a`. -/
@[elab_as_elim, to_additive "Recursor for `with_zero` using the preferred forms `0` and `↑a`."]
def recOneCoe {C : WithOne α → Sort _} (h₁ : C 1) (h₂ : ∀ a : α, C a) : ∀ n : WithOne α, C n :=
  Option.rec h₁ h₂
#align with_one.rec_one_coe WithOne.recOneCoe
#align with_zero.rec_zero_coe WithZero.recZeroCoe
-/

#print WithOne.unone /-
/-- Deconstruct a `x : with_one α` to the underlying value in `α`, given a proof that `x ≠ 1`. -/
@[to_additive unzero
      "Deconstruct a `x : with_zero α` to the underlying value in `α`, given a proof that `x ≠ 0`."]
def unone {x : WithOne α} (hx : x ≠ 1) : α :=
  WithBot.unbot x hx
#align with_one.unone WithOne.unone
#align with_zero.unzero WithZero.unzero
-/

#print WithOne.unone_coe /-
@[simp, to_additive unzero_coe]
theorem unone_coe {x : α} (hx : (x : WithOne α) ≠ 1) : unone hx = x :=
  rfl
#align with_one.unone_coe WithOne.unone_coe
#align with_zero.unzero_coe WithZero.unzero_coe
-/

#print WithOne.coe_unone /-
@[simp, to_additive coe_unzero]
theorem coe_unone {x : WithOne α} (hx : x ≠ 1) : ↑(unone hx) = x :=
  WithBot.coe_unbot x hx
#align with_one.coe_unone WithOne.coe_unone
#align with_zero.coe_unzero WithZero.coe_unzero
-/

@[to_additive]
theorem some_eq_coe {a : α} : (some a : WithOne α) = ↑a :=
  rfl
#align with_one.some_eq_coe WithOne.some_eq_coe
#align with_zero.some_eq_coe WithZero.some_eq_coe

#print WithOne.coe_ne_one /-
@[simp, to_additive]
theorem coe_ne_one {a : α} : (a : WithOne α) ≠ (1 : WithOne α) :=
  Option.some_ne_none a
#align with_one.coe_ne_one WithOne.coe_ne_one
#align with_zero.coe_ne_zero WithZero.coe_ne_zero
-/

#print WithOne.one_ne_coe /-
@[simp, to_additive]
theorem one_ne_coe {a : α} : (1 : WithOne α) ≠ a :=
  coe_ne_one.symm
#align with_one.one_ne_coe WithOne.one_ne_coe
#align with_zero.zero_ne_coe WithZero.zero_ne_coe
-/

#print WithOne.ne_one_iff_exists /-
@[to_additive]
theorem ne_one_iff_exists {x : WithOne α} : x ≠ 1 ↔ ∃ a : α, ↑a = x :=
  Option.ne_none_iff_exists
#align with_one.ne_one_iff_exists WithOne.ne_one_iff_exists
#align with_zero.ne_zero_iff_exists WithZero.ne_zero_iff_exists
-/

#print WithOne.canLift /-
@[to_additive]
instance canLift : CanLift (WithOne α) α coe fun a => a ≠ 1 where prf a := ne_one_iff_exists.1
#align with_one.can_lift WithOne.canLift
#align with_zero.can_lift WithZero.canLift
-/

#print WithOne.coe_inj /-
@[simp, norm_cast, to_additive]
theorem coe_inj {a b : α} : (a : WithOne α) = b ↔ a = b :=
  Option.some_inj
#align with_one.coe_inj WithOne.coe_inj
#align with_zero.coe_inj WithZero.coe_inj
-/

#print WithOne.cases_on /-
@[elab_as_elim, to_additive]
protected theorem cases_on {P : WithOne α → Prop} : ∀ x : WithOne α, P 1 → (∀ a : α, P a) → P x :=
  Option.casesOn
#align with_one.cases_on WithOne.cases_on
#align with_zero.cases_on WithZero.cases_on
-/

@[to_additive]
instance [Mul α] : MulOneClass (WithOne α)
    where
  mul := (· * ·)
  one := 1
  one_mul := id <| (Option.liftOrGet_isLeftId _).1
  mul_one := id <| (Option.liftOrGet_isRightId _).1

@[to_additive]
instance [Semigroup α] : Monoid (WithOne α) :=
  { WithOne.mulOneClass with mul_assoc := (Option.liftOrGet_isAssociative _).1 }

example [Semigroup α] : @Monoid.toMulOneClass _ (@WithOne.monoid α _) = @WithOne.mulOneClass α _ :=
  rfl

@[to_additive]
instance [CommSemigroup α] : CommMonoid (WithOne α) :=
  { WithOne.monoid with mul_comm := (Option.liftOrGet_isCommutative _).1 }

#print WithOne.coe_mul /-
@[simp, norm_cast, to_additive]
theorem coe_mul [Mul α] (a b : α) : ((a * b : α) : WithOne α) = a * b :=
  rfl
#align with_one.coe_mul WithOne.coe_mul
#align with_zero.coe_add WithZero.coe_add
-/

#print WithOne.coe_inv /-
@[simp, norm_cast, to_additive]
theorem coe_inv [Inv α] (a : α) : ((a⁻¹ : α) : WithOne α) = a⁻¹ :=
  rfl
#align with_one.coe_inv WithOne.coe_inv
#align with_zero.coe_neg WithZero.coe_neg
-/

end WithOne

namespace WithZero

instance [one : One α] : One (WithZero α) :=
  { one with }

#print WithZero.coe_one /-
@[simp, norm_cast]
theorem coe_one [One α] : ((1 : α) : WithZero α) = 1 :=
  rfl
#align with_zero.coe_one WithZero.coe_one
-/

instance [Mul α] : MulZeroClass (WithZero α) :=
  { WithZero.zero with
    mul := Option.map₂ (· * ·)
    zero_mul := id <| Option.map₂_none_left (· * ·)
    mul_zero := id <| Option.map₂_none_right (· * ·) }

#print WithZero.coe_mul /-
@[simp, norm_cast]
theorem coe_mul {α : Type u} [Mul α] {a b : α} : ((a * b : α) : WithZero α) = a * b :=
  rfl
#align with_zero.coe_mul WithZero.coe_mul
-/

instance [Mul α] : NoZeroDivisors (WithZero α) :=
  ⟨fun a b => id <| Option.map₂_eq_none_iff.1⟩

instance [Semigroup α] : SemigroupWithZero (WithZero α) :=
  { WithZero.mulZeroClass with mul_assoc := id fun _ _ _ => Option.map₂_assoc mul_assoc }

instance [CommSemigroup α] : CommSemigroup (WithZero α) :=
  { WithZero.semigroupWithZero with mul_comm := id fun _ _ => Option.map₂_comm mul_comm }

instance [MulOneClass α] : MulZeroOneClass (WithZero α) :=
  { WithZero.mulZeroClass,
    WithZero.hasOne with
    one_mul := id <| Option.map₂_left_identity one_mul
    mul_one := id <| Option.map₂_right_identity mul_one }

instance [One α] [Pow α ℕ] : Pow (WithZero α) ℕ :=
  ⟨fun x n =>
    match x, n with
    | none, 0 => 1
    | none, n + 1 => 0
    | some x, n => ↑(x ^ n)⟩

#print WithZero.coe_pow /-
@[simp, norm_cast]
theorem coe_pow [One α] [Pow α ℕ] {a : α} (n : ℕ) : ↑(a ^ n : α) = (↑a ^ n : WithZero α) :=
  rfl
#align with_zero.coe_pow WithZero.coe_pow
-/

instance [Monoid α] : MonoidWithZero (WithZero α) :=
  { WithZero.mulZeroOneClass,
    WithZero.semigroupWithZero with
    npow := fun n x => x ^ n
    npow_zero := fun x =>
      match x with
      | none => rfl
      | some x => congr_arg some <| pow_zero _
    npow_succ := fun n x =>
      match x with
      | none => rfl
      | some x => congr_arg some <| pow_succ _ _ }

instance [CommMonoid α] : CommMonoidWithZero (WithZero α) :=
  { WithZero.monoidWithZero, WithZero.commSemigroup with }

/-- Given an inverse operation on `α` there is an inverse operation
  on `with_zero α` sending `0` to `0`-/
instance [Inv α] : Inv (WithZero α) :=
  ⟨fun a => Option.map Inv.inv a⟩

#print WithZero.coe_inv /-
@[simp, norm_cast]
theorem coe_inv [Inv α] (a : α) : ((a⁻¹ : α) : WithZero α) = a⁻¹ :=
  rfl
#align with_zero.coe_inv WithZero.coe_inv
-/

#print WithZero.inv_zero /-
@[simp]
theorem inv_zero [Inv α] : (0 : WithZero α)⁻¹ = 0 :=
  rfl
#align with_zero.inv_zero WithZero.inv_zero
-/

instance [InvolutiveInv α] : InvolutiveInv (WithZero α) :=
  { WithZero.hasInv with
    inv_inv :=
      id fun a => (Option.map_map _ _ _).trans <| by simp_rw [inv_comp_inv, Option.map_id, id] }

instance [InvOneClass α] : InvOneClass (WithZero α) :=
  { WithZero.hasOne, WithZero.hasInv with inv_one := show ((1⁻¹ : α) : WithZero α) = 1 by simp }

instance [Div α] : Div (WithZero α) :=
  ⟨Option.map₂ (· / ·)⟩

#print WithZero.coe_div /-
@[norm_cast]
theorem coe_div [Div α] (a b : α) : ↑(a / b : α) = (a / b : WithZero α) :=
  rfl
#align with_zero.coe_div WithZero.coe_div
-/

instance [One α] [Pow α ℤ] : Pow (WithZero α) ℤ :=
  ⟨fun x n =>
    match x, n with
    | none, Int.ofNat 0 => 1
    | none, Int.ofNat (Nat.succ n) => 0
    | none, Int.negSucc n => 0
    | some x, n => ↑(x ^ n)⟩

#print WithZero.coe_zpow /-
@[simp, norm_cast]
theorem coe_zpow [DivInvMonoid α] {a : α} (n : ℤ) : ↑(a ^ n : α) = (↑a ^ n : WithZero α) :=
  rfl
#align with_zero.coe_zpow WithZero.coe_zpow
-/

instance [DivInvMonoid α] : DivInvMonoid (WithZero α) :=
  { WithZero.hasDiv, WithZero.hasInv,
    WithZero.monoidWithZero with
    div_eq_mul_inv := fun a b =>
      match a, b with
      | none, _ => rfl
      | some a, none => rfl
      | some a, some b => congr_arg some (div_eq_mul_inv _ _)
    zpow := fun n x => x ^ n
    zpow_zero' := fun x =>
      match x with
      | none => rfl
      | some x => congr_arg some <| zpow_zero _
    zpow_succ' := fun n x =>
      match x with
      | none => rfl
      | some x => congr_arg some <| DivInvMonoid.zpow_succ' _ _
    zpow_neg' := fun n x =>
      match x with
      | none => rfl
      | some x => congr_arg some <| DivInvMonoid.zpow_neg' _ _ }

instance [DivInvOneMonoid α] : DivInvOneMonoid (WithZero α) :=
  { WithZero.divInvMonoid, WithZero.invOneClass with }

instance [DivisionMonoid α] : DivisionMonoid (WithZero α) :=
  { WithZero.divInvMonoid,
    WithZero.hasInvolutiveInv with
    mul_inv_rev := fun a b =>
      match a, b with
      | none, none => rfl
      | none, some b => rfl
      | some a, none => rfl
      | some a, some b => congr_arg some <| mul_inv_rev _ _
    inv_eq_of_mul := fun a b =>
      match a, b with
      | none, none => fun _ => rfl
      | none, some b => by contradiction
      | some a, none => by contradiction
      | some a, some b => fun h =>
        congr_arg some <| inv_eq_of_mul_eq_one_right <| Option.some_injective _ h }

instance [DivisionCommMonoid α] : DivisionCommMonoid (WithZero α) :=
  { WithZero.divisionMonoid, WithZero.commSemigroup with }

section Group

variable [Group α]

/-- if `G` is a group then `with_zero G` is a group with zero. -/
instance : GroupWithZero (WithZero α) :=
  { WithZero.monoidWithZero, WithZero.divInvMonoid,
    WithZero.nontrivial with
    inv_zero := inv_zero
    mul_inv_cancel := fun a ha => by lift a to α using ha; norm_cast; apply mul_right_inv }

end Group

instance [CommGroup α] : CommGroupWithZero (WithZero α) :=
  { WithZero.groupWithZero, WithZero.commMonoidWithZero with }

instance [AddMonoidWithOne α] : AddMonoidWithOne (WithZero α) :=
  { WithZero.addMonoid,
    WithZero.hasOne with
    natCast := fun n => if n = 0 then 0 else (n.cast : α)
    natCast_zero := rfl
    natCast_succ := fun n => by
      cases n
      show (((1 : ℕ) : α) : WithZero α) = 0 + 1; · rw [Nat.cast_one, coe_one, zero_add]
      show (((n + 2 : ℕ) : α) : WithZero α) = ((n + 1 : ℕ) : α) + 1
      · rw [Nat.cast_succ, coe_add, coe_one] }

instance [Semiring α] : Semiring (WithZero α) :=
  { WithZero.addMonoidWithOne, WithZero.addCommMonoid, WithZero.mulZeroClass,
    WithZero.monoidWithZero with
    left_distrib := fun a b c => by
      cases' a with a; · rfl
      cases' b with b <;> cases' c with c <;> try rfl
      exact congr_arg some (left_distrib _ _ _)
    right_distrib := fun a b c => by
      cases' c with c
      · change (a + b) * 0 = a * 0 + b * 0; simp
      cases' a with a <;> cases' b with b <;> try rfl
      exact congr_arg some (right_distrib _ _ _) }

end WithZero

