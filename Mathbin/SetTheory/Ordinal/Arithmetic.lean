/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Floris van Doorn, Violeta Hernández Palacios

! This file was ported from Lean 3 source module set_theory.ordinal.arithmetic
! leanprover-community/mathlib commit 32253a1a1071173b33dc7d6a218cf722c6feb514
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.SetTheory.Ordinal.Basic
import Mathbin.Tactic.ByContra

/-!
# Ordinal arithmetic

Ordinals have an addition (corresponding to disjoint union) that turns them into an additive
monoid, and a multiplication (corresponding to the lexicographic order on the product) that turns
them into a monoid. One can also define correspondingly a subtraction, a division, a successor
function, a power function and a logarithm function.

We also define limit ordinals and prove the basic induction principle on ordinals separating
successor ordinals and limit ordinals, in `limit_rec_on`.

## Main definitions and results

* `o₁ + o₂` is the order on the disjoint union of `o₁` and `o₂` obtained by declaring that
  every element of `o₁` is smaller than every element of `o₂`.
* `o₁ - o₂` is the unique ordinal `o` such that `o₂ + o = o₁`, when `o₂ ≤ o₁`.
* `o₁ * o₂` is the lexicographic order on `o₂ × o₁`.
* `o₁ / o₂` is the ordinal `o` such that `o₁ = o₂ * o + o'` with `o' < o₂`. We also define the
  divisibility predicate, and a modulo operation.
* `order.succ o = o + 1` is the successor of `o`.
* `pred o` if the predecessor of `o`. If `o` is not a successor, we set `pred o = o`.

We discuss the properties of casts of natural numbers of and of `ω` with respect to these
operations.

Some properties of the operations are also used to discuss general tools on ordinals:

* `is_limit o`: an ordinal is a limit ordinal if it is neither `0` nor a successor.
* `limit_rec_on` is the main induction principle of ordinals: if one can prove a property by
  induction at successor ordinals and at limit ordinals, then it holds for all ordinals.
* `is_normal`: a function `f : ordinal → ordinal` satisfies `is_normal` if it is strictly increasing
  and order-continuous, i.e., the image `f o` of a limit ordinal `o` is the sup of `f a` for
  `a < o`.
* `enum_ord`: enumerates an unbounded set of ordinals by the ordinals themselves.
* `sup`, `lsub`: the supremum / least strict upper bound of an indexed family of ordinals in
  `Type u`, as an ordinal in `Type u`.
* `bsup`, `blsub`: the supremum / least strict upper bound of a set of ordinals indexed by ordinals
  less than a given ordinal `o`.

Various other basic arithmetic results are given in `principal.lean` instead.
-/


noncomputable section

open Function Cardinal Set Equiv Order

open Classical Cardinal Ordinal

universe u v w

namespace Ordinal

variable {α : Type _} {β : Type _} {γ : Type _} {r : α → α → Prop} {s : β → β → Prop}
  {t : γ → γ → Prop}

/-! ### Further properties of addition on ordinals -/


/- warning: ordinal.lift_add -> Ordinal.lift_add is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lift.{u2, u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b)) (HAdd.hAdd.{succ (max u1 u2), succ (max u1 u2), succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.{max u1 u2} Ordinal.{max u1 u2} (instHAdd.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasAdd.{max u1 u2}) (Ordinal.lift.{u2, u1} a) (Ordinal.lift.{u2, u1} b))
but is expected to have type
  forall (a : Ordinal.{u2}) (b : Ordinal.{u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lift.{u1, u2} (HAdd.hAdd.{succ u2, succ u2, succ u2} Ordinal.{u2} Ordinal.{u2} Ordinal.{u2} (instHAdd.{succ u2} Ordinal.{u2} Ordinal.instAddOrdinal.{u2}) a b)) (HAdd.hAdd.{max (succ u1) (succ u2), max (succ u1) (succ u2), max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.{max u2 u1} Ordinal.{max u2 u1} (instHAdd.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instAddOrdinal.{max u1 u2}) (Ordinal.lift.{u1, u2} a) (Ordinal.lift.{u1, u2} b))
Case conversion may be inaccurate. Consider using '#align ordinal.lift_add Ordinal.lift_addₓ'. -/
@[simp]
theorem lift_add (a b) : lift (a + b) = lift a + lift b :=
  Quotient.induction_on₂ a b fun ⟨α, r, _⟩ ⟨β, s, _⟩ =>
    Quotient.sound
      ⟨(RelIso.preimage Equiv.ulift _).trans
          (RelIso.sumLexCongr (RelIso.preimage Equiv.ulift _) (RelIso.preimage Equiv.ulift _)).symm⟩
#align ordinal.lift_add Ordinal.lift_add

/- warning: ordinal.lift_succ -> Ordinal.lift_succ is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lift.{u2, u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.lift.{u2, u1} a))
but is expected to have type
  forall (a : Ordinal.{u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lift.{u1, u2} (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} a)) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.lift.{u1, u2} a))
Case conversion may be inaccurate. Consider using '#align ordinal.lift_succ Ordinal.lift_succₓ'. -/
@[simp]
theorem lift_succ (a) : lift (succ a) = succ (lift a) :=
  by
  rw [← add_one_eq_succ, lift_add, lift_one]
  rfl
#align ordinal.lift_succ Ordinal.lift_succ

/- warning: ordinal.add_contravariant_class_le -> Ordinal.add_contravariantClass_le is a dubious translation:
lean 3 declaration is
  ContravariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1})) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})))
but is expected to have type
  ContravariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.245 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.247 : Ordinal.{u1}) => HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.245 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.247) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.260 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.262 : Ordinal.{u1}) => LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.260 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.262)
Case conversion may be inaccurate. Consider using '#align ordinal.add_contravariant_class_le Ordinal.add_contravariantClass_leₓ'. -/
instance add_contravariantClass_le : ContravariantClass Ordinal.{u} Ordinal.{u} (· + ·) (· ≤ ·) :=
  ⟨fun a b c =>
    inductionOn a fun α r hr =>
      inductionOn b fun β₁ s₁ hs₁ =>
        inductionOn c fun β₂ s₂ hs₂ ⟨f⟩ =>
          ⟨have fl : ∀ a, f (Sum.inl a) = Sum.inl a := fun a => by
              simpa only [InitialSeg.trans_apply, InitialSeg.leAdd_apply] using
                @InitialSeg.eq _ _ _ _ (@Sum.Lex.isWellOrder _ _ _ _ hr hs₂)
                  ((InitialSeg.leAdd r s₁).trans f) (InitialSeg.leAdd r s₂) a
            have : ∀ b, { b' // f (Sum.inr b) = Sum.inr b' } :=
              by
              intro b; cases e : f (Sum.inr b)
              · rw [← fl] at e
                have := f.inj' e
                contradiction
              · exact ⟨_, rfl⟩
            let g (b) := (this b).1
            have fr : ∀ b, f (Sum.inr b) = Sum.inr (g b) := fun b => (this b).2
            ⟨⟨⟨g, fun x y h => by
                  injection f.inj' (by rw [fr, fr, h] : f (Sum.inr x) = f (Sum.inr y))⟩,
                fun a b => by
                simpa only [Sum.lex_inr_inr, fr, RelEmbedding.coeFn_toEmbedding,
                  InitialSeg.coeFn_toRelEmbedding, embedding.coe_fn_mk] using
                  @RelEmbedding.map_rel_iff _ _ _ _ f.to_rel_embedding (Sum.inr a) (Sum.inr b)⟩,
              fun a b H =>
              by
              rcases f.init' (by rw [fr] <;> exact Sum.lex_inr_inr.2 H) with ⟨a' | a', h⟩
              · rw [fl] at h
                cases h
              · rw [fr] at h
                exact ⟨a', Sum.inr.inj h⟩⟩⟩⟩
#align ordinal.add_contravariant_class_le Ordinal.add_contravariantClass_le

#print Ordinal.add_left_cancel /-
theorem add_left_cancel (a) {b c : Ordinal} : a + b = a + c ↔ b = c := by
  simp only [le_antisymm_iff, add_le_add_iff_left]
#align ordinal.add_left_cancel Ordinal.add_left_cancel
-/

private theorem add_lt_add_iff_left' (a) {b c : Ordinal} : a + b < a + c ↔ b < c := by
  rw [← not_le, ← not_le, add_le_add_iff_left]
#align ordinal.add_lt_add_iff_left' ordinal.add_lt_add_iff_left'

/- warning: ordinal.add_covariant_class_lt -> Ordinal.add_covariantClass_lt is a dubious translation:
lean 3 declaration is
  CovariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1})) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})))
but is expected to have type
  CovariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.956 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.958 : Ordinal.{u1}) => HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.956 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.958) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.971 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.973 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.971 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.973)
Case conversion may be inaccurate. Consider using '#align ordinal.add_covariant_class_lt Ordinal.add_covariantClass_ltₓ'. -/
instance add_covariantClass_lt : CovariantClass Ordinal.{u} Ordinal.{u} (· + ·) (· < ·) :=
  ⟨fun a b c => (add_lt_add_iff_left' a).2⟩
#align ordinal.add_covariant_class_lt Ordinal.add_covariantClass_lt

/- warning: ordinal.add_contravariant_class_lt -> Ordinal.add_contravariantClass_lt is a dubious translation:
lean 3 declaration is
  ContravariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1})) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})))
but is expected to have type
  ContravariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1021 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1023 : Ordinal.{u1}) => HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1021 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1023) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1036 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1038 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1036 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1038)
Case conversion may be inaccurate. Consider using '#align ordinal.add_contravariant_class_lt Ordinal.add_contravariantClass_ltₓ'. -/
instance add_contravariantClass_lt : ContravariantClass Ordinal.{u} Ordinal.{u} (· + ·) (· < ·) :=
  ⟨fun a b c => (add_lt_add_iff_left' a).1⟩
#align ordinal.add_contravariant_class_lt Ordinal.add_contravariantClass_lt

/- warning: ordinal.add_swap_contravariant_class_lt -> Ordinal.add_swap_contravariantClass_lt is a dubious translation:
lean 3 declaration is
  ContravariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (Function.swap.{succ (succ u1), succ (succ u1), succ (succ u1)} Ordinal.{u1} Ordinal.{u1} (fun (ᾰ : Ordinal.{u1}) (ᾰ : Ordinal.{u1}) => Ordinal.{u1}) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}))) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})))
but is expected to have type
  ContravariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (Function.swap.{succ (succ u1), succ (succ u1), succ (succ u1)} Ordinal.{u1} Ordinal.{u1} (fun (ᾰ : Ordinal.{u1}) (ᾰ : Ordinal.{u1}) => Ordinal.{u1}) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1104 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1106 : Ordinal.{u1}) => HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1104 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1106)) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1119 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1121 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1119 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.1121)
Case conversion may be inaccurate. Consider using '#align ordinal.add_swap_contravariant_class_lt Ordinal.add_swap_contravariantClass_ltₓ'. -/
instance add_swap_contravariantClass_lt :
    ContravariantClass Ordinal.{u} Ordinal.{u} (swap (· + ·)) (· < ·) :=
  ⟨fun a b c => lt_imp_lt_of_le_imp_le fun h => add_le_add_right h _⟩
#align ordinal.add_swap_contravariant_class_lt Ordinal.add_swap_contravariantClass_lt

/- warning: ordinal.add_le_add_iff_right -> Ordinal.add_le_add_iff_right is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} (n : Nat), Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} (n : Nat), Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a b)
Case conversion may be inaccurate. Consider using '#align ordinal.add_le_add_iff_right Ordinal.add_le_add_iff_rightₓ'. -/
theorem add_le_add_iff_right {a b : Ordinal} : ∀ n : ℕ, a + n ≤ b + n ↔ a ≤ b
  | 0 => by simp
  | n + 1 => by rw [nat_cast_succ, add_succ, add_succ, succ_le_succ_iff, add_le_add_iff_right]
#align ordinal.add_le_add_iff_right Ordinal.add_le_add_iff_right

/- warning: ordinal.add_right_cancel -> Ordinal.add_right_cancel is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} (n : Nat), Iff (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))) (Eq.{succ (succ u1)} Ordinal.{u1} a b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} (n : Nat), Iff (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))) (Eq.{succ (succ u1)} Ordinal.{u1} a b)
Case conversion may be inaccurate. Consider using '#align ordinal.add_right_cancel Ordinal.add_right_cancelₓ'. -/
theorem add_right_cancel {a b : Ordinal} (n : ℕ) : a + n = b + n ↔ a = b := by
  simp only [le_antisymm_iff, add_le_add_iff_right]
#align ordinal.add_right_cancel Ordinal.add_right_cancel

#print Ordinal.add_eq_zero_iff /-
theorem add_eq_zero_iff {a b : Ordinal} : a + b = 0 ↔ a = 0 ∧ b = 0 :=
  inductionOn a fun α r _ =>
    inductionOn b fun β s _ =>
      by
      simp_rw [← type_sum_lex, type_eq_zero_iff_is_empty]
      exact isEmpty_sum
#align ordinal.add_eq_zero_iff Ordinal.add_eq_zero_iff
-/

#print Ordinal.left_eq_zero_of_add_eq_zero /-
theorem left_eq_zero_of_add_eq_zero {a b : Ordinal} (h : a + b = 0) : a = 0 :=
  (add_eq_zero_iff.1 h).1
#align ordinal.left_eq_zero_of_add_eq_zero Ordinal.left_eq_zero_of_add_eq_zero
-/

#print Ordinal.right_eq_zero_of_add_eq_zero /-
theorem right_eq_zero_of_add_eq_zero {a b : Ordinal} (h : a + b = 0) : b = 0 :=
  (add_eq_zero_iff.1 h).2
#align ordinal.right_eq_zero_of_add_eq_zero Ordinal.right_eq_zero_of_add_eq_zero
-/

/-! ### The predecessor of an ordinal -/


#print Ordinal.pred /-
/-- The ordinal predecessor of `o` is `o'` if `o = succ o'`,
  and `o` otherwise. -/
def pred (o : Ordinal) : Ordinal :=
  if h : ∃ a, o = succ a then Classical.choose h else o
#align ordinal.pred Ordinal.pred
-/

/- warning: ordinal.pred_succ -> Ordinal.pred_succ is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.pred.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) o
but is expected to have type
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.pred.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)) o
Case conversion may be inaccurate. Consider using '#align ordinal.pred_succ Ordinal.pred_succₓ'. -/
@[simp]
theorem pred_succ (o) : pred (succ o) = o := by
  have h : ∃ a, succ o = succ a := ⟨_, rfl⟩ <;>
    simpa only [pred, dif_pos h] using (succ_injective <| Classical.choose_spec h).symm
#align ordinal.pred_succ Ordinal.pred_succ

/- warning: ordinal.pred_le_self -> Ordinal.pred_le_self is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.pred.{u1} o) o
but is expected to have type
  forall (o : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.pred.{u1} o) o
Case conversion may be inaccurate. Consider using '#align ordinal.pred_le_self Ordinal.pred_le_selfₓ'. -/
theorem pred_le_self (o) : pred o ≤ o :=
  if h : ∃ a, o = succ a then by
    let ⟨a, e⟩ := h
    rw [e, pred_succ] <;> exact le_succ a
  else by rw [pred, dif_neg h]
#align ordinal.pred_le_self Ordinal.pred_le_self

/- warning: ordinal.pred_eq_iff_not_succ -> Ordinal.pred_eq_iff_not_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.pred.{u1} o) o) (Not (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a))))
but is expected to have type
  forall {o : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.pred.{u1} o) o) (Not (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a))))
Case conversion may be inaccurate. Consider using '#align ordinal.pred_eq_iff_not_succ Ordinal.pred_eq_iff_not_succₓ'. -/
theorem pred_eq_iff_not_succ {o} : pred o = o ↔ ¬∃ a, o = succ a :=
  ⟨fun e ⟨a, e'⟩ => by rw [e', pred_succ] at e <;> exact (lt_succ a).Ne e, fun h => dif_neg h⟩
#align ordinal.pred_eq_iff_not_succ Ordinal.pred_eq_iff_not_succ

/- warning: ordinal.pred_eq_iff_not_succ' -> Ordinal.pred_eq_iff_not_succ' is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.pred.{u1} o) o) (forall (a : Ordinal.{u1}), Ne.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a))
but is expected to have type
  forall {o : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.pred.{u1} o) o) (forall (a : Ordinal.{u1}), Ne.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a))
Case conversion may be inaccurate. Consider using '#align ordinal.pred_eq_iff_not_succ' Ordinal.pred_eq_iff_not_succ'ₓ'. -/
theorem pred_eq_iff_not_succ' {o} : pred o = o ↔ ∀ a, o ≠ succ a := by
  simpa using pred_eq_iff_not_succ
#align ordinal.pred_eq_iff_not_succ' Ordinal.pred_eq_iff_not_succ'

/- warning: ordinal.pred_lt_iff_is_succ -> Ordinal.pred_lt_iff_is_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.pred.{u1} o) o) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)))
but is expected to have type
  forall {o : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.pred.{u1} o) o) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a)))
Case conversion may be inaccurate. Consider using '#align ordinal.pred_lt_iff_is_succ Ordinal.pred_lt_iff_is_succₓ'. -/
theorem pred_lt_iff_is_succ {o} : pred o < o ↔ ∃ a, o = succ a :=
  Iff.trans (by simp only [le_antisymm_iff, pred_le_self, true_and_iff, not_le])
    (iff_not_comm.1 pred_eq_iff_not_succ).symm
#align ordinal.pred_lt_iff_is_succ Ordinal.pred_lt_iff_is_succ

#print Ordinal.pred_zero /-
@[simp]
theorem pred_zero : pred 0 = 0 :=
  pred_eq_iff_not_succ'.2 fun a => (succ_ne_zero a).symm
#align ordinal.pred_zero Ordinal.pred_zero
-/

/- warning: ordinal.succ_pred_iff_is_succ -> Ordinal.succ_pred_iff_is_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} (Ordinal.pred.{u1} o)) o) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)))
but is expected to have type
  forall {o : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} (Ordinal.pred.{u1} o)) o) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a)))
Case conversion may be inaccurate. Consider using '#align ordinal.succ_pred_iff_is_succ Ordinal.succ_pred_iff_is_succₓ'. -/
theorem succ_pred_iff_is_succ {o} : succ (pred o) = o ↔ ∃ a, o = succ a :=
  ⟨fun e => ⟨_, e.symm⟩, fun ⟨a, e⟩ => by simp only [e, pred_succ]⟩
#align ordinal.succ_pred_iff_is_succ Ordinal.succ_pred_iff_is_succ

/- warning: ordinal.succ_lt_of_not_succ -> Ordinal.succ_lt_of_not_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {b : Ordinal.{u1}}, (Not (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} b) o) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o))
but is expected to have type
  forall {o : Ordinal.{u1}} {b : Ordinal.{u1}}, (Not (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a)))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} b) o) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b o))
Case conversion may be inaccurate. Consider using '#align ordinal.succ_lt_of_not_succ Ordinal.succ_lt_of_not_succₓ'. -/
theorem succ_lt_of_not_succ {o b : Ordinal} (h : ¬∃ a, o = succ a) : succ b < o ↔ b < o :=
  ⟨(lt_succ b).trans, fun l => lt_of_le_of_ne (succ_le_of_lt l) fun e => h ⟨_, e.symm⟩⟩
#align ordinal.succ_lt_of_not_succ Ordinal.succ_lt_of_not_succ

/- warning: ordinal.lt_pred -> Ordinal.lt_pred is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Ordinal.pred.{u1} b)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Ordinal.pred.{u1} b)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) b)
Case conversion may be inaccurate. Consider using '#align ordinal.lt_pred Ordinal.lt_predₓ'. -/
theorem lt_pred {a b} : a < pred b ↔ succ a < b :=
  if h : ∃ a, b = succ a then by
    let ⟨c, e⟩ := h
    rw [e, pred_succ, succ_lt_succ_iff]
  else by simp only [pred, dif_neg h, succ_lt_of_not_succ h]
#align ordinal.lt_pred Ordinal.lt_pred

/- warning: ordinal.pred_le -> Ordinal.pred_le is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.pred.{u1} a) b) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.pred.{u1} a) b) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} b))
Case conversion may be inaccurate. Consider using '#align ordinal.pred_le Ordinal.pred_leₓ'. -/
theorem pred_le {a b} : pred a ≤ b ↔ a ≤ succ b :=
  le_iff_le_iff_lt_iff_lt.2 lt_pred
#align ordinal.pred_le Ordinal.pred_le

/- warning: ordinal.lift_is_succ -> Ordinal.lift_is_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Iff (Exists.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (fun (a : Ordinal.{max u1 u2}) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lift.{u2, u1} o) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} a))) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)))
but is expected to have type
  forall {o : Ordinal.{u2}}, Iff (Exists.{succ (max (succ u1) (succ u2))} Ordinal.{max u2 u1} (fun (a : Ordinal.{max u2 u1}) => Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lift.{u1, u2} o) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} a))) (Exists.{succ (succ u2)} Ordinal.{u2} (fun (a : Ordinal.{u2}) => Eq.{succ (succ u2)} Ordinal.{u2} o (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} a)))
Case conversion may be inaccurate. Consider using '#align ordinal.lift_is_succ Ordinal.lift_is_succₓ'. -/
@[simp]
theorem lift_is_succ {o} : (∃ a, lift o = succ a) ↔ ∃ a, o = succ a :=
  ⟨fun ⟨a, h⟩ =>
    let ⟨b, e⟩ := lift_down <| show a ≤ lift o from le_of_lt <| h.symm ▸ lt_succ a
    ⟨b, lift_inj.1 <| by rw [h, ← e, lift_succ]⟩,
    fun ⟨a, h⟩ => ⟨lift a, by simp only [h, lift_succ]⟩⟩
#align ordinal.lift_is_succ Ordinal.lift_is_succ

/- warning: ordinal.lift_pred -> Ordinal.lift_pred is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lift.{u2, u1} (Ordinal.pred.{u1} o)) (Ordinal.pred.{max u1 u2} (Ordinal.lift.{u2, u1} o))
but is expected to have type
  forall (o : Ordinal.{u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lift.{u1, u2} (Ordinal.pred.{u2} o)) (Ordinal.pred.{max u1 u2} (Ordinal.lift.{u1, u2} o))
Case conversion may be inaccurate. Consider using '#align ordinal.lift_pred Ordinal.lift_predₓ'. -/
@[simp]
theorem lift_pred (o) : lift (pred o) = pred (lift o) :=
  if h : ∃ a, o = succ a then by cases' h with a e <;> simp only [e, pred_succ, lift_succ]
  else by rw [pred_eq_iff_not_succ.2 h, pred_eq_iff_not_succ.2 (mt lift_is_succ.1 h)]
#align ordinal.lift_pred Ordinal.lift_pred

/-! ### Limit ordinals -/


#print Ordinal.IsLimit /-
/-- A limit ordinal is an ordinal which is not zero and not a successor. -/
def IsLimit (o : Ordinal) : Prop :=
  o ≠ 0 ∧ ∀ a < o, succ a < o
#align ordinal.is_limit Ordinal.IsLimit
-/

/- warning: ordinal.is_limit.succ_lt -> Ordinal.IsLimit.succ_lt is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {a : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) o)
but is expected to have type
  forall {o : Ordinal.{u1}} {a : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) o)
Case conversion may be inaccurate. Consider using '#align ordinal.is_limit.succ_lt Ordinal.IsLimit.succ_ltₓ'. -/
theorem IsLimit.succ_lt {o a : Ordinal} (h : IsLimit o) : a < o → succ a < o :=
  h.2 a
#align ordinal.is_limit.succ_lt Ordinal.IsLimit.succ_lt

#print Ordinal.not_zero_isLimit /-
theorem not_zero_isLimit : ¬IsLimit 0
  | ⟨h, _⟩ => h rfl
#align ordinal.not_zero_is_limit Ordinal.not_zero_isLimit
-/

/- warning: ordinal.not_succ_is_limit -> Ordinal.not_succ_isLimit is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Not (Ordinal.IsLimit.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))
but is expected to have type
  forall (o : Ordinal.{u1}), Not (Ordinal.IsLimit.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))
Case conversion may be inaccurate. Consider using '#align ordinal.not_succ_is_limit Ordinal.not_succ_isLimitₓ'. -/
theorem not_succ_isLimit (o) : ¬IsLimit (succ o)
  | ⟨_, h⟩ => lt_irrefl _ (h _ (lt_succ o))
#align ordinal.not_succ_is_limit Ordinal.not_succ_isLimit

/- warning: ordinal.not_succ_of_is_limit -> Ordinal.not_succ_of_isLimit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (Not (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a))))
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (Not (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a))))
Case conversion may be inaccurate. Consider using '#align ordinal.not_succ_of_is_limit Ordinal.not_succ_of_isLimitₓ'. -/
theorem not_succ_of_isLimit {o} (h : IsLimit o) : ¬∃ a, o = succ a
  | ⟨a, e⟩ => not_succ_isLimit a (e ▸ h)
#align ordinal.not_succ_of_is_limit Ordinal.not_succ_of_isLimit

/- warning: ordinal.succ_lt_of_is_limit -> Ordinal.succ_lt_of_isLimit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {a : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) o) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o))
but is expected to have type
  forall {o : Ordinal.{u1}} {a : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) o) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o))
Case conversion may be inaccurate. Consider using '#align ordinal.succ_lt_of_is_limit Ordinal.succ_lt_of_isLimitₓ'. -/
theorem succ_lt_of_isLimit {o a : Ordinal} (h : IsLimit o) : succ a < o ↔ a < o :=
  ⟨(lt_succ a).trans, h.2 _⟩
#align ordinal.succ_lt_of_is_limit Ordinal.succ_lt_of_isLimit

/- warning: ordinal.le_succ_of_is_limit -> Ordinal.le_succ_of_isLimit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o a))
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o a))
Case conversion may be inaccurate. Consider using '#align ordinal.le_succ_of_is_limit Ordinal.le_succ_of_isLimitₓ'. -/
theorem le_succ_of_isLimit {o} (h : IsLimit o) {a} : o ≤ succ a ↔ o ≤ a :=
  le_iff_le_iff_lt_iff_lt.2 <| succ_lt_of_isLimit h
#align ordinal.le_succ_of_is_limit Ordinal.le_succ_of_isLimit

/- warning: ordinal.limit_le -> Ordinal.limit_le is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o a) (forall (x : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x o) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x a)))
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o a) (forall (x : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x o) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x a)))
Case conversion may be inaccurate. Consider using '#align ordinal.limit_le Ordinal.limit_leₓ'. -/
theorem limit_le {o} (h : IsLimit o) {a} : o ≤ a ↔ ∀ x < o, x ≤ a :=
  ⟨fun h x l => l.le.trans h, fun H =>
    (le_succ_of_isLimit h).1 <| le_of_not_lt fun hn => not_lt_of_le (H _ hn) (lt_succ a)⟩
#align ordinal.limit_le Ordinal.limit_le

/- warning: ordinal.lt_limit -> Ordinal.lt_limit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (x : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x o) (fun (H : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x o) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a x))))
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (x : Ordinal.{u1}) => And (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x o) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a x))))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_limit Ordinal.lt_limitₓ'. -/
theorem lt_limit {o} (h : IsLimit o) {a} : a < o ↔ ∃ x < o, a < x := by
  simpa only [not_ball, not_le] using not_congr (@limit_le _ h a)
#align ordinal.lt_limit Ordinal.lt_limit

/- warning: ordinal.lift_is_limit -> Ordinal.lift_isLimit is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Iff (Ordinal.IsLimit.{max u1 u2} (Ordinal.lift.{u2, u1} o)) (Ordinal.IsLimit.{u1} o)
but is expected to have type
  forall (o : Ordinal.{u2}), Iff (Ordinal.IsLimit.{max u2 u1} (Ordinal.lift.{u1, u2} o)) (Ordinal.IsLimit.{u2} o)
Case conversion may be inaccurate. Consider using '#align ordinal.lift_is_limit Ordinal.lift_isLimitₓ'. -/
@[simp]
theorem lift_isLimit (o) : IsLimit (lift o) ↔ IsLimit o :=
  and_congr (not_congr <| by simpa only [lift_zero] using @lift_inj o 0)
    ⟨fun H a h => lift_lt.1 <| by simpa only [lift_succ] using H _ (lift_lt.2 h), fun H a h =>
      by
      obtain ⟨a', rfl⟩ := lift_down h.le
      rw [← lift_succ, lift_lt]
      exact H a' (lift_lt.1 h)⟩
#align ordinal.lift_is_limit Ordinal.lift_isLimit

/- warning: ordinal.is_limit.pos -> Ordinal.IsLimit.pos is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) o)
Case conversion may be inaccurate. Consider using '#align ordinal.is_limit.pos Ordinal.IsLimit.posₓ'. -/
theorem IsLimit.pos {o : Ordinal} (h : IsLimit o) : 0 < o :=
  lt_of_le_of_ne (Ordinal.zero_le _) h.1.symm
#align ordinal.is_limit.pos Ordinal.IsLimit.pos

/- warning: ordinal.is_limit.one_lt -> Ordinal.IsLimit.one_lt is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1})) o)
Case conversion may be inaccurate. Consider using '#align ordinal.is_limit.one_lt Ordinal.IsLimit.one_ltₓ'. -/
theorem IsLimit.one_lt {o : Ordinal} (h : IsLimit o) : 1 < o := by
  simpa only [succ_zero] using h.2 _ h.pos
#align ordinal.is_limit.one_lt Ordinal.IsLimit.one_lt

/- warning: ordinal.is_limit.nat_lt -> Ordinal.IsLimit.nat_lt is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall (n : Nat), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall (n : Nat), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n) o)
Case conversion may be inaccurate. Consider using '#align ordinal.is_limit.nat_lt Ordinal.IsLimit.nat_ltₓ'. -/
theorem IsLimit.nat_lt {o : Ordinal} (h : IsLimit o) : ∀ n : ℕ, (n : Ordinal) < o
  | 0 => h.Pos
  | n + 1 => h.2 _ (is_limit.nat_lt n)
#align ordinal.is_limit.nat_lt Ordinal.IsLimit.nat_lt

/- warning: ordinal.zero_or_succ_or_limit -> Ordinal.zero_or_succ_or_limit is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Or (Eq.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (Or (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a))) (Ordinal.IsLimit.{u1} o))
but is expected to have type
  forall (o : Ordinal.{u1}), Or (Eq.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (Or (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a))) (Ordinal.IsLimit.{u1} o))
Case conversion may be inaccurate. Consider using '#align ordinal.zero_or_succ_or_limit Ordinal.zero_or_succ_or_limitₓ'. -/
theorem zero_or_succ_or_limit (o : Ordinal) : o = 0 ∨ (∃ a, o = succ a) ∨ IsLimit o :=
  if o0 : o = 0 then Or.inl o0
  else
    if h : ∃ a, o = succ a then Or.inr (Or.inl h)
    else Or.inr <| Or.inr ⟨o0, fun a => (succ_lt_of_not_succ h).2⟩
#align ordinal.zero_or_succ_or_limit Ordinal.zero_or_succ_or_limit

/- warning: ordinal.limit_rec_on -> Ordinal.limitRecOn is a dubious translation:
lean 3 declaration is
  forall {C : Ordinal.{u1} -> Sort.{u2}} (o : Ordinal.{u1}), (C (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (forall (o : Ordinal.{u1}), (C o) -> (C (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) -> (forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (forall (o' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o) -> (C o')) -> (C o)) -> (C o)
but is expected to have type
  forall {C : Ordinal.{u1} -> Sort.{u2}} (o : Ordinal.{u1}), (C (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (forall (o : Ordinal.{u1}), (C o) -> (C (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) -> (forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (forall (o' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o' o) -> (C o')) -> (C o)) -> (C o)
Case conversion may be inaccurate. Consider using '#align ordinal.limit_rec_on Ordinal.limitRecOnₓ'. -/
/-- Main induction principle of ordinals: if one can prove a property by
  induction at successor ordinals and at limit ordinals, then it holds for all ordinals. -/
@[elab_as_elim]
def limitRecOn {C : Ordinal → Sort _} (o : Ordinal) (H₁ : C 0) (H₂ : ∀ o, C o → C (succ o))
    (H₃ : ∀ o, IsLimit o → (∀ o' < o, C o') → C o) : C o :=
  lt_wf.fix
    (fun o IH =>
      if o0 : o = 0 then by rw [o0] <;> exact H₁
      else
        if h : ∃ a, o = succ a then by
          rw [← succ_pred_iff_is_succ.2 h] <;> exact H₂ _ (IH _ <| pred_lt_iff_is_succ.2 h)
        else H₃ _ ⟨o0, fun a => (succ_lt_of_not_succ h).2⟩ IH)
    o
#align ordinal.limit_rec_on Ordinal.limitRecOn

/- warning: ordinal.limit_rec_on_zero -> Ordinal.limitRecOn_zero is a dubious translation:
lean 3 declaration is
  forall {C : Ordinal.{u1} -> Sort.{u2}} (H₁ : C (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (H₂ : forall (o : Ordinal.{u1}), (C o) -> (C (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (H₃ : forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (forall (o' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o) -> (C o')) -> (C o)), Eq.{u2} (C (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (Ordinal.limitRecOn.{u1, u2} C (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) H₁ H₂ H₃) H₁
but is expected to have type
  forall {C : Ordinal.{u2} -> Sort.{u1}} (H₁ : C (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2}))) (H₂ : forall (o : Ordinal.{u2}), (C o) -> (C (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o))) (H₃ : forall (o : Ordinal.{u2}), (Ordinal.IsLimit.{u2} o) -> (forall (o' : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) o' o) -> (C o')) -> (C o)), Eq.{u1} (C (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2}))) (Ordinal.limitRecOn.{u2, u1} C (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2})) H₁ H₂ H₃) H₁
Case conversion may be inaccurate. Consider using '#align ordinal.limit_rec_on_zero Ordinal.limitRecOn_zeroₓ'. -/
@[simp]
theorem limitRecOn_zero {C} (H₁ H₂ H₃) : @limitRecOn C 0 H₁ H₂ H₃ = H₁ := by
  rw [limit_rec_on, lt_wf.fix_eq, dif_pos rfl] <;> rfl
#align ordinal.limit_rec_on_zero Ordinal.limitRecOn_zero

/- warning: ordinal.limit_rec_on_succ -> Ordinal.limitRecOn_succ is a dubious translation:
lean 3 declaration is
  forall {C : Ordinal.{u1} -> Sort.{u2}} (o : Ordinal.{u1}) (H₁ : C (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (H₂ : forall (o : Ordinal.{u1}), (C o) -> (C (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (H₃ : forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (forall (o' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o) -> (C o')) -> (C o)), Eq.{u2} (C (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) (Ordinal.limitRecOn.{u1, u2} C (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o) H₁ H₂ H₃) (H₂ o (Ordinal.limitRecOn.{u1, u2} C o H₁ H₂ H₃))
but is expected to have type
  forall {C : Ordinal.{u2} -> Sort.{u1}} (o : Ordinal.{u2}) (H₁ : C (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2}))) (H₂ : forall (o : Ordinal.{u2}), (C o) -> (C (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o))) (H₃ : forall (o : Ordinal.{u2}), (Ordinal.IsLimit.{u2} o) -> (forall (o' : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) o' o) -> (C o')) -> (C o)), Eq.{u1} (C (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o)) (Ordinal.limitRecOn.{u2, u1} C (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o) H₁ H₂ H₃) (H₂ o (Ordinal.limitRecOn.{u2, u1} C o H₁ H₂ H₃))
Case conversion may be inaccurate. Consider using '#align ordinal.limit_rec_on_succ Ordinal.limitRecOn_succₓ'. -/
@[simp]
theorem limitRecOn_succ {C} (o H₁ H₂ H₃) :
    @limitRecOn C (succ o) H₁ H₂ H₃ = H₂ o (@limitRecOn C o H₁ H₂ H₃) :=
  by
  have h : ∃ a, succ o = succ a := ⟨_, rfl⟩
  rw [limit_rec_on, lt_wf.fix_eq, dif_neg (succ_ne_zero o), dif_pos h]
  generalize limit_rec_on._proof_2 (succ o) h = h₂
  generalize limit_rec_on._proof_3 (succ o) h = h₃
  revert h₂ h₃; generalize e : pred (succ o) = o'; intros
  rw [pred_succ] at e; subst o'; rfl
#align ordinal.limit_rec_on_succ Ordinal.limitRecOn_succ

/- warning: ordinal.limit_rec_on_limit -> Ordinal.limitRecOn_limit is a dubious translation:
lean 3 declaration is
  forall {C : Ordinal.{u1} -> Sort.{u2}} (o : Ordinal.{u1}) (H₁ : C (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (H₂ : forall (o : Ordinal.{u1}), (C o) -> (C (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (H₃ : forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (forall (o' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o) -> (C o')) -> (C o)) (h : Ordinal.IsLimit.{u1} o), Eq.{u2} (C o) (Ordinal.limitRecOn.{u1, u2} C o H₁ H₂ H₃) (H₃ o h (fun (x : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x o) => Ordinal.limitRecOn.{u1, u2} C x H₁ H₂ H₃))
but is expected to have type
  forall {C : Ordinal.{u2} -> Sort.{u1}} (o : Ordinal.{u2}) (H₁ : C (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2}))) (H₂ : forall (o : Ordinal.{u2}), (C o) -> (C (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o))) (H₃ : forall (o : Ordinal.{u2}), (Ordinal.IsLimit.{u2} o) -> (forall (o' : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) o' o) -> (C o')) -> (C o)) (h : Ordinal.IsLimit.{u2} o), Eq.{u1} (C o) (Ordinal.limitRecOn.{u2, u1} C o H₁ H₂ H₃) (H₃ o h (fun (x : Ordinal.{u2}) (h : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) x o) => Ordinal.limitRecOn.{u2, u1} C x H₁ H₂ H₃))
Case conversion may be inaccurate. Consider using '#align ordinal.limit_rec_on_limit Ordinal.limitRecOn_limitₓ'. -/
@[simp]
theorem limitRecOn_limit {C} (o H₁ H₂ H₃ h) :
    @limitRecOn C o H₁ H₂ H₃ = H₃ o h fun x h => @limitRecOn C x H₁ H₂ H₃ := by
  rw [limit_rec_on, lt_wf.fix_eq, dif_neg h.1, dif_neg (not_succ_of_is_limit h)] <;> rfl
#align ordinal.limit_rec_on_limit Ordinal.limitRecOn_limit

/- warning: ordinal.order_top_out_succ -> Ordinal.orderTopOutSucc is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), OrderTop.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLE.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))
but is expected to have type
  forall (o : Ordinal.{u1}), OrderTop.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLE.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))))))))
Case conversion may be inaccurate. Consider using '#align ordinal.order_top_out_succ Ordinal.orderTopOutSuccₓ'. -/
instance orderTopOutSucc (o : Ordinal) : OrderTop (succ o).out.α :=
  ⟨_, le_enum_succ⟩
#align ordinal.order_top_out_succ Ordinal.orderTopOutSucc

/- warning: ordinal.enum_succ_eq_top -> Ordinal.enum_succ_eq_top is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Eq.{succ u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Ordinal.enum.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) o (Eq.mpr.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) (id_tag Tactic.IdTag.rw (Eq.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Eq.ndrec.{0, succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (fun (_a : Ordinal.{u1}) => Eq.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o _a)) (rfl.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))))) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o) (Ordinal.type_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))) (Order.lt_succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} Ordinal.noMaxOrder.{u1} o))) (Top.top.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (OrderTop.toHasTop.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLE.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))))))) (Ordinal.orderTopOutSucc.{u1} o)))
but is expected to have type
  forall {o : Ordinal.{u1}}, Eq.{succ u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Ordinal.enum.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)) o (Eq.mpr.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)) (id.{0} (Eq.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Eq.ndrec.{0, succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.1292 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.1294 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.1292 x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.1294) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (_a : Ordinal.{u1}) => Eq.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o _a)) (Eq.refl.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o (Ordinal.type.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4191 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4193) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))))) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o) (Ordinal.type_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))) (Order.lt_succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} Ordinal.instNoMaxOrderOrdinalToLTToPreorderInstPartialOrderOrdinal.{u1} o))) (Top.top.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (OrderTop.toTop.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLE.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) (Ordinal.orderTopOutSucc.{u1} o)))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_succ_eq_top Ordinal.enum_succ_eq_topₓ'. -/
theorem enum_succ_eq_top {o : Ordinal} :
    enum (· < ·) o
        (by
          rw [type_lt]
          exact lt_succ o) =
      (⊤ : (succ o).out.α) :=
  rfl
#align ordinal.enum_succ_eq_top Ordinal.enum_succ_eq_top

/- warning: ordinal.has_succ_of_type_succ_lt -> Ordinal.has_succ_of_type_succ_lt is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {r : α -> α -> Prop} [wo : IsWellOrder.{u1} α r], (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Ordinal.type.{u1} α r wo)) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) (Ordinal.type.{u1} α r wo))) -> (forall (x : α), Exists.{succ u1} α (fun (y : α) => r x y))
but is expected to have type
  forall {α : Type.{u1}} {r : α -> α -> Prop} [wo : IsWellOrder.{u1} α r], (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Ordinal.type.{u1} α r wo)) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) (Ordinal.type.{u1} α r wo))) -> (forall (x : α), Exists.{succ u1} α (fun (y : α) => r x y))
Case conversion may be inaccurate. Consider using '#align ordinal.has_succ_of_type_succ_lt Ordinal.has_succ_of_type_succ_ltₓ'. -/
theorem has_succ_of_type_succ_lt {α} {r : α → α → Prop} [wo : IsWellOrder α r]
    (h : ∀ a < type r, succ a < type r) (x : α) : ∃ y, r x y :=
  by
  use enum r (succ (typein r x)) (h _ (typein_lt_type r x))
  convert (enum_lt_enum (typein_lt_type r x) _).mpr (lt_succ _); rw [enum_typein]
#align ordinal.has_succ_of_type_succ_lt Ordinal.has_succ_of_type_succ_lt

/- warning: ordinal.out_no_max_of_succ_lt -> Ordinal.out_no_max_of_succ_lt is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) o)) -> (NoMaxOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (linearOrderOut.{u1} o)))))))
but is expected to have type
  forall {o : Ordinal.{u1}}, (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) o)) -> (NoMaxOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (linearOrderOut.{u1} o))))))))
Case conversion may be inaccurate. Consider using '#align ordinal.out_no_max_of_succ_lt Ordinal.out_no_max_of_succ_ltₓ'. -/
theorem out_no_max_of_succ_lt {o : Ordinal} (ho : ∀ a < o, succ a < o) : NoMaxOrder o.out.α :=
  ⟨has_succ_of_type_succ_lt (by rwa [type_lt])⟩
#align ordinal.out_no_max_of_succ_lt Ordinal.out_no_max_of_succ_lt

#print Ordinal.bounded_singleton /-
theorem bounded_singleton {r : α → α → Prop} [IsWellOrder α r] (hr : (type r).IsLimit) (x) :
    Bounded r {x} :=
  by
  refine' ⟨enum r (succ (typein r x)) (hr.2 _ (typein_lt_type r x)), _⟩
  intro b hb
  rw [mem_singleton_iff.1 hb]
  nth_rw 1 [← enum_typein r x]
  rw [@enum_lt_enum _ r]
  apply lt_succ
#align ordinal.bounded_singleton Ordinal.bounded_singleton
-/

/- warning: ordinal.type_subrel_lt -> Ordinal.type_subrel_lt is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Eq.{succ (succ (succ u1))} Ordinal.{succ u1} (Ordinal.type.{succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o))) (Subrel.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o))) (Subrel.isWellOrder.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) Ordinal.HasLt.Lt.isWellOrder.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o)))) (Ordinal.lift.{succ u1, u1} o)
but is expected to have type
  forall (o : Ordinal.{u1}), Eq.{succ (succ (succ u1))} Ordinal.{succ u1} (Ordinal.type.{succ u1} (Set.Elem.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o' o))) (Subrel.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4707 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4709 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4707 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4709) (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o' o))) (Subrel.instIsWellOrderElemSubrel.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4707 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4709 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4707 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.4709) Ordinal.instIsWellOrderOrdinalLtToLTToPreorderInstPartialOrderOrdinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o' o)))) (Ordinal.lift.{succ u1, u1} o)
Case conversion may be inaccurate. Consider using '#align ordinal.type_subrel_lt Ordinal.type_subrel_ltₓ'. -/
theorem type_subrel_lt (o : Ordinal.{u}) :
    type (Subrel (· < ·) { o' : Ordinal | o' < o }) = Ordinal.lift.{u + 1} o :=
  by
  refine' Quotient.inductionOn o _
  rintro ⟨α, r, wo⟩; skip; apply Quotient.sound
  constructor; symm; refine' (RelIso.preimage Equiv.ulift r).trans (enum_iso r).symm
#align ordinal.type_subrel_lt Ordinal.type_subrel_lt

/- warning: ordinal.mk_initial_seg -> Ordinal.mk_initialSeg is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Eq.{succ (succ (succ u1))} Cardinal.{succ u1} (Cardinal.mk.{succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o' o)))) (Cardinal.lift.{succ u1, u1} (Ordinal.card.{u1} o))
but is expected to have type
  forall (o : Ordinal.{u1}), Eq.{succ (succ (succ u1))} Cardinal.{succ u1} (Cardinal.mk.{succ u1} (Set.Elem.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o' : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o' o)))) (Cardinal.lift.{succ u1, u1} (Ordinal.card.{u1} o))
Case conversion may be inaccurate. Consider using '#align ordinal.mk_initial_seg Ordinal.mk_initialSegₓ'. -/
theorem mk_initialSeg (o : Ordinal.{u}) :
    (#{ o' : Ordinal | o' < o }) = Cardinal.lift.{u + 1} o.card := by
  rw [lift_card, ← type_subrel_lt, card_type]
#align ordinal.mk_initial_seg Ordinal.mk_initialSeg

/-! ### Normal ordinal functions -/


#print Ordinal.IsNormal /-
/-- A normal ordinal function is a strictly increasing function which is
  order-continuous, i.e., the image `f o` of a limit ordinal `o` is the sup of `f a` for
  `a < o`.  -/
def IsNormal (f : Ordinal → Ordinal) : Prop :=
  (∀ o, f o < f (succ o)) ∧ ∀ o, IsLimit o → ∀ a, f o ≤ a ↔ ∀ b < o, f b ≤ a
#align ordinal.is_normal Ordinal.IsNormal
-/

/- warning: ordinal.is_normal.limit_le -> Ordinal.IsNormal.limit_le is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u2}}, Iff (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f o) a) (forall (b : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o) -> (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f b) a))))
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (forall {o : Ordinal.{u2}}, (Ordinal.IsLimit.{u2} o) -> (forall {a : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f o) a) (forall (b : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) b o) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f b) a))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.limit_le Ordinal.IsNormal.limit_leₓ'. -/
theorem IsNormal.limit_le {f} (H : IsNormal f) :
    ∀ {o}, IsLimit o → ∀ {a}, f o ≤ a ↔ ∀ b < o, f b ≤ a :=
  H.2
#align ordinal.is_normal.limit_le Ordinal.IsNormal.limit_le

/- warning: ordinal.is_normal.limit_lt -> Ordinal.IsNormal.limit_lt is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall {a : Ordinal.{u2}}, Iff (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a (f o)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (b : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o) (fun (H : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o) => LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a (f b))))))
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (forall {o : Ordinal.{u2}}, (Ordinal.IsLimit.{u2} o) -> (forall {a : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (f o)) (Exists.{succ (succ u2)} Ordinal.{u2} (fun (b : Ordinal.{u2}) => And (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) b o) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (f b))))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.limit_lt Ordinal.IsNormal.limit_ltₓ'. -/
theorem IsNormal.limit_lt {f} (H : IsNormal f) {o} (h : IsLimit o) {a} :
    a < f o ↔ ∃ b < o, a < f b :=
  not_iff_not.1 <| by simpa only [exists_prop, not_exists, not_and, not_lt] using H.2 _ h a
#align ordinal.is_normal.limit_lt Ordinal.IsNormal.limit_lt

/- warning: ordinal.is_normal.strict_mono -> Ordinal.IsNormal.strictMono is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (StrictMono.{succ u1, succ u2} Ordinal.{u1} Ordinal.{u2} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2}) f)
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (StrictMono.{succ u2, succ u1} Ordinal.{u2} Ordinal.{u1} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) f)
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.strict_mono Ordinal.IsNormal.strictMonoₓ'. -/
theorem IsNormal.strictMono {f} (H : IsNormal f) : StrictMono f := fun a b =>
  limitRecOn b (Not.elim (not_lt_of_le <| Ordinal.zero_le _))
    (fun b IH h =>
      (lt_or_eq_of_le (le_of_lt_succ h)).elim (fun h => (IH h).trans (H.1 _)) fun e => e ▸ H.1 _)
    fun b l IH h => lt_of_lt_of_le (H.1 a) ((H.2 _ l _).1 le_rfl _ (l.2 _ h))
#align ordinal.is_normal.strict_mono Ordinal.IsNormal.strictMono

/- warning: ordinal.is_normal.monotone -> Ordinal.IsNormal.monotone is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (Monotone.{succ u1, succ u2} Ordinal.{u1} Ordinal.{u2} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2}) f)
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (Monotone.{succ u2, succ u1} Ordinal.{u2} Ordinal.{u1} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) f)
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.monotone Ordinal.IsNormal.monotoneₓ'. -/
theorem IsNormal.monotone {f} (H : IsNormal f) : Monotone f :=
  H.StrictMono.Monotone
#align ordinal.is_normal.monotone Ordinal.IsNormal.monotone

/- warning: ordinal.is_normal_iff_strict_mono_limit -> Ordinal.isNormal_iff_strictMono_limit is a dubious translation:
lean 3 declaration is
  forall (f : Ordinal.{u1} -> Ordinal.{u2}), Iff (Ordinal.IsNormal.{u1, u2} f) (And (StrictMono.{succ u1, succ u2} Ordinal.{u1} Ordinal.{u2} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2}) f) (forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (forall (a : Ordinal.{u2}), (forall (b : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o) -> (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f b) a)) -> (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f o) a))))
but is expected to have type
  forall (f : Ordinal.{u2} -> Ordinal.{u1}), Iff (Ordinal.IsNormal.{u2, u1} f) (And (StrictMono.{succ u2, succ u1} Ordinal.{u2} Ordinal.{u1} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) f) (forall (o : Ordinal.{u2}), (Ordinal.IsLimit.{u2} o) -> (forall (a : Ordinal.{u1}), (forall (b : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) b o) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f b) a)) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f o) a))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal_iff_strict_mono_limit Ordinal.isNormal_iff_strictMono_limitₓ'. -/
theorem isNormal_iff_strictMono_limit (f : Ordinal → Ordinal) :
    IsNormal f ↔ StrictMono f ∧ ∀ o, IsLimit o → ∀ a, (∀ b < o, f b ≤ a) → f o ≤ a :=
  ⟨fun hf => ⟨hf.StrictMono, fun a ha c => (hf.2 a ha c).2⟩, fun ⟨hs, hl⟩ =>
    ⟨fun a => hs (lt_succ a), fun a ha c =>
      ⟨fun hac b hba => ((hs hba).trans_le hac).le, hl a ha c⟩⟩⟩
#align ordinal.is_normal_iff_strict_mono_limit Ordinal.isNormal_iff_strictMono_limit

/- warning: ordinal.is_normal.lt_iff -> Ordinal.IsNormal.lt_iff is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f a) (f b)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b))
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (forall {a : Ordinal.{u2}} {b : Ordinal.{u2}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f a) (f b)) (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.lt_iff Ordinal.IsNormal.lt_iffₓ'. -/
theorem IsNormal.lt_iff {f} (H : IsNormal f) {a b} : f a < f b ↔ a < b :=
  StrictMono.lt_iff_lt <| H.StrictMono
#align ordinal.is_normal.lt_iff Ordinal.IsNormal.lt_iff

/- warning: ordinal.is_normal.le_iff -> Ordinal.IsNormal.le_iff is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f a) (f b)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b))
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (forall {a : Ordinal.{u2}} {b : Ordinal.{u2}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f a) (f b)) (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.le_iff Ordinal.IsNormal.le_iffₓ'. -/
theorem IsNormal.le_iff {f} (H : IsNormal f) {a b} : f a ≤ f b ↔ a ≤ b :=
  le_iff_le_iff_lt_iff_lt.2 H.lt_iff
#align ordinal.is_normal.le_iff Ordinal.IsNormal.le_iff

/- warning: ordinal.is_normal.inj -> Ordinal.IsNormal.inj is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (Eq.{succ (succ u2)} Ordinal.{u2} (f a) (f b)) (Eq.{succ (succ u1)} Ordinal.{u1} a b))
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (forall {a : Ordinal.{u2}} {b : Ordinal.{u2}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (f a) (f b)) (Eq.{succ (succ u2)} Ordinal.{u2} a b))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.inj Ordinal.IsNormal.injₓ'. -/
theorem IsNormal.inj {f} (H : IsNormal f) {a b} : f a = f b ↔ a = b := by
  simp only [le_antisymm_iff, H.le_iff]
#align ordinal.is_normal.inj Ordinal.IsNormal.inj

/- warning: ordinal.is_normal.self_le -> Ordinal.IsNormal.self_le is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (forall (a : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (f a))
but is expected to have type
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (forall (a : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (f a))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.self_le Ordinal.IsNormal.self_leₓ'. -/
theorem IsNormal.self_le {f} (H : IsNormal f) (a) : a ≤ f a :=
  lt_wf.self_le_of_strictMono H.StrictMono a
#align ordinal.is_normal.self_le Ordinal.IsNormal.self_le

/- warning: ordinal.is_normal.le_set -> Ordinal.IsNormal.le_set is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}} {o : Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (forall (p : Set.{succ u1} Ordinal.{u1}), (Set.Nonempty.{succ u1} Ordinal.{u1} p) -> (forall (b : Ordinal.{u1}), (forall (o : Ordinal.{u1}), Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o) (forall (a : Ordinal.{u1}), (Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) a p) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o))) -> (Iff (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f b) o) (forall (a : Ordinal.{u1}), (Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) a p) -> (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (f a) o)))))
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}} {o : Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (forall (p : Set.{succ u2} Ordinal.{u2}), (Set.Nonempty.{succ u2} Ordinal.{u2} p) -> (forall (b : Ordinal.{u2}), (forall (o : Ordinal.{u2}), Iff (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) b o) (forall (a : Ordinal.{u2}), (Membership.mem.{succ u2, succ u2} Ordinal.{u2} (Set.{succ u2} Ordinal.{u2}) (Set.instMembershipSet.{succ u2} Ordinal.{u2}) a p) -> (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o))) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f b) o) (forall (a : Ordinal.{u2}), (Membership.mem.{succ u2, succ u2} Ordinal.{u2} (Set.{succ u2} Ordinal.{u2}) (Set.instMembershipSet.{succ u2} Ordinal.{u2}) a p) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f a) o)))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.le_set Ordinal.IsNormal.le_setₓ'. -/
theorem IsNormal.le_set {f o} (H : IsNormal f) (p : Set Ordinal) (p0 : p.Nonempty) (b)
    (H₂ : ∀ o, b ≤ o ↔ ∀ a ∈ p, a ≤ o) : f b ≤ o ↔ ∀ a ∈ p, f a ≤ o :=
  ⟨fun h a pa => (H.le_iff.2 ((H₂ _).1 le_rfl _ pa)).trans h, fun h =>
    by
    revert H₂;
    refine'
      limit_rec_on b (fun H₂ => _) (fun S _ H₂ => _) fun S L _ H₂ => (H.2 _ L _).2 fun a h' => _
    · cases' p0 with x px
      have := Ordinal.le_zero.1 ((H₂ _).1 (Ordinal.zero_le _) _ px)
      rw [this] at px
      exact h _ px
    · rcases not_ball.1 (mt (H₂ S).2 <| (lt_succ S).not_le) with ⟨a, h₁, h₂⟩
      exact (H.le_iff.2 <| succ_le_of_lt <| not_le.1 h₂).trans (h _ h₁)
    · rcases not_ball.1 (mt (H₂ a).2 h'.not_le) with ⟨b, h₁, h₂⟩
      exact (H.le_iff.2 <| (not_le.1 h₂).le).trans (h _ h₁)⟩
#align ordinal.is_normal.le_set Ordinal.IsNormal.le_set

/- warning: ordinal.is_normal.le_set' -> Ordinal.IsNormal.le_set' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {f : Ordinal.{u2} -> Ordinal.{u3}} {o : Ordinal.{u3}}, (Ordinal.IsNormal.{u2, u3} f) -> (forall (p : Set.{u1} α), (Set.Nonempty.{u1} α p) -> (forall (g : α -> Ordinal.{u2}) (b : Ordinal.{u2}), (forall (o : Ordinal.{u2}), Iff (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) b o) (forall (a : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) a p) -> (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) (g a) o))) -> (Iff (LE.le.{succ u3} Ordinal.{u3} (Preorder.toLE.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.partialOrder.{u3})) (f b) o) (forall (a : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) a p) -> (LE.le.{succ u3} Ordinal.{u3} (Preorder.toLE.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.partialOrder.{u3})) (f (g a)) o)))))
but is expected to have type
  forall {α : Type.{u1}} {f : Ordinal.{u3} -> Ordinal.{u2}} {o : Ordinal.{u2}}, (Ordinal.IsNormal.{u3, u2} f) -> (forall (p : Set.{u1} α), (Set.Nonempty.{u1} α p) -> (forall (g : α -> Ordinal.{u3}) (b : Ordinal.{u3}), (forall (o : Ordinal.{u3}), Iff (LE.le.{succ u3} Ordinal.{u3} (Preorder.toLE.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) b o) (forall (a : α), (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) a p) -> (LE.le.{succ u3} Ordinal.{u3} (Preorder.toLE.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) (g a) o))) -> (Iff (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) (f b) o) (forall (a : α), (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) a p) -> (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) (f (g a)) o)))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.le_set' Ordinal.IsNormal.le_set'ₓ'. -/
theorem IsNormal.le_set' {f o} (H : IsNormal f) (p : Set α) (p0 : p.Nonempty) (g : α → Ordinal) (b)
    (H₂ : ∀ o, b ≤ o ↔ ∀ a ∈ p, g a ≤ o) : f b ≤ o ↔ ∀ a ∈ p, f (g a) ≤ o := by
  simpa [H₂] using H.le_set (g '' p) (p0.image g) b
#align ordinal.is_normal.le_set' Ordinal.IsNormal.le_set'

#print Ordinal.IsNormal.refl /-
theorem IsNormal.refl : IsNormal id :=
  ⟨lt_succ, fun o l a => limit_le l⟩
#align ordinal.is_normal.refl Ordinal.IsNormal.refl
-/

/- warning: ordinal.is_normal.trans -> Ordinal.IsNormal.trans is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}} {g : Ordinal.{u3} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u2} f) -> (Ordinal.IsNormal.{u3, u1} g) -> (Ordinal.IsNormal.{u3, u2} (Function.comp.{succ (succ u3), succ (succ u1), succ (succ u2)} Ordinal.{u3} Ordinal.{u1} Ordinal.{u2} f g))
but is expected to have type
  forall {f : Ordinal.{u3} -> Ordinal.{u2}} {g : Ordinal.{u1} -> Ordinal.{u3}}, (Ordinal.IsNormal.{u3, u2} f) -> (Ordinal.IsNormal.{u1, u3} g) -> (Ordinal.IsNormal.{u1, u2} (Function.comp.{succ (succ u1), succ (succ u3), succ (succ u2)} Ordinal.{u1} Ordinal.{u3} Ordinal.{u2} f g))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.trans Ordinal.IsNormal.transₓ'. -/
theorem IsNormal.trans {f g} (H₁ : IsNormal f) (H₂ : IsNormal g) : IsNormal (f ∘ g) :=
  ⟨fun x => H₁.lt_iff.2 (H₂.1 _), fun o l a =>
    H₁.le_set' (· < o) ⟨_, l.Pos⟩ g _ fun c => H₂.2 _ l _⟩
#align ordinal.is_normal.trans Ordinal.IsNormal.trans

/- warning: ordinal.is_normal.is_limit -> Ordinal.IsNormal.isLimit is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u2}}, (Ordinal.IsNormal.{u1, u2} f) -> (forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (Ordinal.IsLimit.{u2} (f o)))
but is expected to have type
  forall {f : Ordinal.{u2} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u2, u1} f) -> (forall {o : Ordinal.{u2}}, (Ordinal.IsLimit.{u2} o) -> (Ordinal.IsLimit.{u1} (f o)))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.is_limit Ordinal.IsNormal.isLimitₓ'. -/
theorem IsNormal.isLimit {f} (H : IsNormal f) {o} (l : IsLimit o) : IsLimit (f o) :=
  ⟨ne_of_gt <| (Ordinal.zero_le _).trans_lt <| H.lt_iff.2 l.Pos, fun a h =>
    let ⟨b, h₁, h₂⟩ := (H.limit_lt l).1 h
    (succ_le_of_lt h₂).trans_lt (H.lt_iff.2 h₁)⟩
#align ordinal.is_normal.is_limit Ordinal.IsNormal.isLimit

/- warning: ordinal.is_normal.le_iff_eq -> Ordinal.IsNormal.le_iff_eq is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (forall {a : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (f a) a) (Eq.{succ (succ u1)} Ordinal.{u1} (f a) a))
but is expected to have type
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (forall {a : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (f a) a) (Eq.{succ (succ u1)} Ordinal.{u1} (f a) a))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.le_iff_eq Ordinal.IsNormal.le_iff_eqₓ'. -/
theorem IsNormal.le_iff_eq {f} (H : IsNormal f) {a} : f a ≤ a ↔ f a = a :=
  (H.self_le a).le_iff_eq
#align ordinal.is_normal.le_iff_eq Ordinal.IsNormal.le_iff_eq

/- warning: ordinal.add_le_of_limit -> Ordinal.add_le_of_limit is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} b) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) c) (forall (b' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b' b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b') c)))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} b) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) c) (forall (b' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b' b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b') c)))
Case conversion may be inaccurate. Consider using '#align ordinal.add_le_of_limit Ordinal.add_le_of_limitₓ'. -/
theorem add_le_of_limit {a b c : Ordinal} (h : IsLimit b) : a + b ≤ c ↔ ∀ b' < b, a + b' ≤ c :=
  ⟨fun h b' l => (add_le_add_left l.le _).trans h, fun H =>
    le_of_not_lt <|
      inductionOn a
        (fun α r _ =>
          inductionOn b fun β s _ h H l => by
            skip
            suffices ∀ x : β, Sum.Lex r s (Sum.inr x) (enum _ _ l)
              by
              cases' enum _ _ l with x x
              · cases this (enum s 0 h.pos)
              · exact irrefl _ (this _)
            intro x
            rw [← typein_lt_typein (Sum.Lex r s), typein_enum]
            have := H _ (h.2 _ (typein_lt_type s x))
            rw [add_succ, succ_le_iff] at this
            refine'
              (RelEmbedding.ofMonotone (fun a => _) fun a b => _).ordinal_type_le.trans_lt this
            · rcases a with ⟨a | b, h⟩
              · exact Sum.inl a
              · exact Sum.inr ⟨b, by cases h <;> assumption⟩
            ·
              rcases a with ⟨a | a, h₁⟩ <;> rcases b with ⟨b | b, h₂⟩ <;> cases h₁ <;> cases h₂ <;>
                    rintro ⟨⟩ <;>
                  constructor <;>
                assumption)
        h H⟩
#align ordinal.add_le_of_limit Ordinal.add_le_of_limit

#print Ordinal.add_isNormal /-
theorem add_isNormal (a : Ordinal) : IsNormal ((· + ·) a) :=
  ⟨fun b => (add_lt_add_iff_left a).2 (lt_succ b), fun b l c => add_le_of_limit l⟩
#align ordinal.add_is_normal Ordinal.add_isNormal
-/

#print Ordinal.add_isLimit /-
theorem add_isLimit (a) {b} : IsLimit b → IsLimit (a + b) :=
  (add_isNormal a).IsLimit
#align ordinal.add_is_limit Ordinal.add_isLimit
-/

alias add_is_limit ← is_limit.add
#align ordinal.is_limit.add Ordinal.IsLimit.add

/-! ### Subtraction on ordinals-/


/- warning: ordinal.sub_nonempty -> Ordinal.sub_nonempty is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Set.Nonempty.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o : Ordinal.{u1}) => LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b o)))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Set.Nonempty.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o : Ordinal.{u1}) => LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b o)))
Case conversion may be inaccurate. Consider using '#align ordinal.sub_nonempty Ordinal.sub_nonemptyₓ'. -/
/-- The set in the definition of subtraction is nonempty. -/
theorem sub_nonempty {a b : Ordinal} : { o | a ≤ b + o }.Nonempty :=
  ⟨a, le_add_left _ _⟩
#align ordinal.sub_nonempty Ordinal.sub_nonempty

/-- `a - b` is the unique ordinal satisfying `b + (a - b) = a` when `b ≤ a`. -/
instance : Sub Ordinal :=
  ⟨fun a b => infₛ { o | a ≤ b + o }⟩

/- warning: ordinal.le_add_sub -> Ordinal.le_add_sub is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b))
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.le_add_sub Ordinal.le_add_subₓ'. -/
theorem le_add_sub (a b : Ordinal) : a ≤ b + (a - b) :=
  cinfₛ_mem sub_nonempty
#align ordinal.le_add_sub Ordinal.le_add_sub

/- warning: ordinal.sub_le -> Ordinal.sub_le is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b) c) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b c))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b) c) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b c))
Case conversion may be inaccurate. Consider using '#align ordinal.sub_le Ordinal.sub_leₓ'. -/
theorem sub_le {a b c : Ordinal} : a - b ≤ c ↔ a ≤ b + c :=
  ⟨fun h => (le_add_sub a b).trans (add_le_add_left h _), fun h => cinfₛ_le' h⟩
#align ordinal.sub_le Ordinal.sub_le

/- warning: ordinal.lt_sub -> Ordinal.lt_sub is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) b c)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) c a) b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) b c)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) c a) b)
Case conversion may be inaccurate. Consider using '#align ordinal.lt_sub Ordinal.lt_subₓ'. -/
theorem lt_sub {a b c : Ordinal} : a < b - c ↔ c + a < b :=
  lt_iff_lt_of_le_iff_le sub_le
#align ordinal.lt_sub Ordinal.lt_sub

/- warning: ordinal.add_sub_cancel -> Ordinal.add_sub_cancel is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) a) b
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) a) b
Case conversion may be inaccurate. Consider using '#align ordinal.add_sub_cancel Ordinal.add_sub_cancelₓ'. -/
theorem add_sub_cancel (a b : Ordinal) : a + b - a = b :=
  le_antisymm (sub_le.2 <| le_rfl) ((add_le_add_iff_left a).1 <| le_add_sub _ _)
#align ordinal.add_sub_cancel Ordinal.add_sub_cancel

/- warning: ordinal.sub_eq_of_add_eq -> Ordinal.sub_eq_of_add_eq is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) c) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) c a) b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) c) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) c a) b)
Case conversion may be inaccurate. Consider using '#align ordinal.sub_eq_of_add_eq Ordinal.sub_eq_of_add_eqₓ'. -/
theorem sub_eq_of_add_eq {a b c : Ordinal} (h : a + b = c) : c - a = b :=
  h ▸ add_sub_cancel _ _
#align ordinal.sub_eq_of_add_eq Ordinal.sub_eq_of_add_eq

/- warning: ordinal.sub_le_self -> Ordinal.sub_le_self is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b) a
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b) a
Case conversion may be inaccurate. Consider using '#align ordinal.sub_le_self Ordinal.sub_le_selfₓ'. -/
theorem sub_le_self (a b : Ordinal) : a - b ≤ a :=
  sub_le.2 <| le_add_left _ _
#align ordinal.sub_le_self Ordinal.sub_le_self

/- warning: ordinal.add_sub_cancel_of_le -> Ordinal.add_sub_cancel_of_le is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b a) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b)) a)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b a) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b)) a)
Case conversion may be inaccurate. Consider using '#align ordinal.add_sub_cancel_of_le Ordinal.add_sub_cancel_of_leₓ'. -/
protected theorem add_sub_cancel_of_le {a b : Ordinal} (h : b ≤ a) : b + (a - b) = a :=
  (le_add_sub a b).antisymm'
    (by
      rcases zero_or_succ_or_limit (a - b) with (e | ⟨c, e⟩ | l)
      · simp only [e, add_zero, h]
      · rw [e, add_succ, succ_le_iff, ← lt_sub, e]
        exact lt_succ c
      · exact (add_le_of_limit l).2 fun c l => (lt_sub.1 l).le)
#align ordinal.add_sub_cancel_of_le Ordinal.add_sub_cancel_of_le

/- warning: ordinal.le_sub_of_le -> Ordinal.le_sub_of_le is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b a) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b c) a))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b a) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b c) a))
Case conversion may be inaccurate. Consider using '#align ordinal.le_sub_of_le Ordinal.le_sub_of_leₓ'. -/
theorem le_sub_of_le {a b c : Ordinal} (h : b ≤ a) : c ≤ a - b ↔ b + c ≤ a := by
  rw [← add_le_add_iff_left b, Ordinal.add_sub_cancel_of_le h]
#align ordinal.le_sub_of_le Ordinal.le_sub_of_le

/- warning: ordinal.sub_lt_of_le -> Ordinal.sub_lt_of_le is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b a) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b) c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b c)))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b a) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b) c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b c)))
Case conversion may be inaccurate. Consider using '#align ordinal.sub_lt_of_le Ordinal.sub_lt_of_leₓ'. -/
theorem sub_lt_of_le {a b c : Ordinal} (h : b ≤ a) : a - b < c ↔ a < b + c :=
  lt_iff_lt_of_le_iff_le (le_sub_of_le h)
#align ordinal.sub_lt_of_le Ordinal.sub_lt_of_le

instance : ExistsAddOfLE Ordinal :=
  ⟨fun a b h => ⟨_, (Ordinal.add_sub_cancel_of_le h).symm⟩⟩

/- warning: ordinal.sub_zero -> Ordinal.sub_zero is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) a
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) a
Case conversion may be inaccurate. Consider using '#align ordinal.sub_zero Ordinal.sub_zeroₓ'. -/
@[simp]
theorem sub_zero (a : Ordinal) : a - 0 = a := by simpa only [zero_add] using add_sub_cancel 0 a
#align ordinal.sub_zero Ordinal.sub_zero

/- warning: ordinal.zero_sub -> Ordinal.zero_sub is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.zero_sub Ordinal.zero_subₓ'. -/
@[simp]
theorem zero_sub (a : Ordinal) : 0 - a = 0 := by rw [← Ordinal.le_zero] <;> apply sub_le_self
#align ordinal.zero_sub Ordinal.zero_sub

/- warning: ordinal.sub_self -> Ordinal.sub_self is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.sub_self Ordinal.sub_selfₓ'. -/
@[simp]
theorem sub_self (a : Ordinal) : a - a = 0 := by simpa only [add_zero] using add_sub_cancel a 0
#align ordinal.sub_self Ordinal.sub_self

/- warning: ordinal.sub_eq_zero_iff_le -> Ordinal.sub_eq_zero_iff_le is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a b)
Case conversion may be inaccurate. Consider using '#align ordinal.sub_eq_zero_iff_le Ordinal.sub_eq_zero_iff_leₓ'. -/
protected theorem sub_eq_zero_iff_le {a b : Ordinal} : a - b = 0 ↔ a ≤ b :=
  ⟨fun h => by simpa only [h, add_zero] using le_add_sub a b, fun h => by
    rwa [← Ordinal.le_zero, sub_le, add_zero]⟩
#align ordinal.sub_eq_zero_iff_le Ordinal.sub_eq_zero_iff_le

/- warning: ordinal.sub_sub -> Ordinal.sub_sub is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}) (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b) c) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b c))
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}) (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b) c) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b c))
Case conversion may be inaccurate. Consider using '#align ordinal.sub_sub Ordinal.sub_subₓ'. -/
theorem sub_sub (a b c : Ordinal) : a - b - c = a - (b + c) :=
  eq_of_forall_ge_iff fun d => by rw [sub_le, sub_le, sub_le, add_assoc]
#align ordinal.sub_sub Ordinal.sub_sub

/- warning: ordinal.add_sub_add_cancel -> Ordinal.add_sub_add_cancel is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}) (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a c)) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) b c)
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}) (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a c)) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) b c)
Case conversion may be inaccurate. Consider using '#align ordinal.add_sub_add_cancel Ordinal.add_sub_add_cancelₓ'. -/
theorem add_sub_add_cancel (a b c : Ordinal) : a + b - (a + c) = b - c := by
  rw [← sub_sub, add_sub_cancel]
#align ordinal.add_sub_add_cancel Ordinal.add_sub_add_cancel

/- warning: ordinal.sub_is_limit -> Ordinal.sub_isLimit is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} a) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b a) -> (Ordinal.IsLimit.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} a) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b a) -> (Ordinal.IsLimit.{u1} (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.sub_is_limit Ordinal.sub_isLimitₓ'. -/
theorem sub_isLimit {a b} (l : IsLimit a) (h : b < a) : IsLimit (a - b) :=
  ⟨ne_of_gt <| lt_sub.2 <| by rwa [add_zero], fun c h => by
    rw [lt_sub, add_succ] <;> exact l.2 _ (lt_sub.1 h)⟩
#align ordinal.sub_is_limit Ordinal.sub_isLimit

/- warning: ordinal.one_add_omega -> Ordinal.one_add_omega is a dubious translation:
lean 3 declaration is
  Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))) Ordinal.omega.{u1}) Ordinal.omega.{u1}
but is expected to have type
  Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1})) Ordinal.omega.{u1}) Ordinal.omega.{u1}
Case conversion may be inaccurate. Consider using '#align ordinal.one_add_omega Ordinal.one_add_omegaₓ'. -/
@[simp]
theorem one_add_omega : 1 + ω = ω :=
  by
  refine' le_antisymm _ (le_add_left _ _)
  rw [omega, ← lift_one.{0}, ← lift_add, lift_le, ← type_unit, ← type_sum_lex]
  refine' ⟨RelEmbedding.collapse (RelEmbedding.ofMonotone _ _)⟩
  · apply Sum.rec
    exact fun _ => 0
    exact Nat.succ
  · intro a b
    cases a <;> cases b <;> intro H <;> cases' H with _ _ H _ _ H <;> [cases H,
      exact Nat.succ_pos _, exact Nat.succ_lt_succ H]
#align ordinal.one_add_omega Ordinal.one_add_omega

/- warning: ordinal.one_add_of_omega_le -> Ordinal.one_add_of_omega_le is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) Ordinal.omega.{u1} o) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))) o) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) Ordinal.omega.{u1} o) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1})) o) o)
Case conversion may be inaccurate. Consider using '#align ordinal.one_add_of_omega_le Ordinal.one_add_of_omega_leₓ'. -/
@[simp]
theorem one_add_of_omega_le {o} (h : ω ≤ o) : 1 + o = o := by
  rw [← Ordinal.add_sub_cancel_of_le h, ← add_assoc, one_add_omega]
#align ordinal.one_add_of_omega_le Ordinal.one_add_of_omega_le

/-! ### Multiplication of ordinals-/


/-- The multiplication of ordinals `o₁` and `o₂` is the (well founded) lexicographic order on
`o₂ × o₁`. -/
instance : Monoid Ordinal.{u}
    where
  mul a b :=
    Quotient.liftOn₂ a b
      (fun ⟨α, r, wo⟩ ⟨β, s, wo'⟩ => ⟦⟨β × α, Prod.Lex s r, Prod.Lex.isWellOrder⟩⟧ :
        WellOrder → WellOrder → Ordinal)
      fun ⟨α₁, r₁, o₁⟩ ⟨α₂, r₂, o₂⟩ ⟨β₁, s₁, p₁⟩ ⟨β₂, s₂, p₂⟩ ⟨f⟩ ⟨g⟩ =>
      Quot.sound ⟨RelIso.prodLexCongr g f⟩
  one := 1
  mul_assoc a b c :=
    Quotient.induction_on₃ a b c fun ⟨α, r, _⟩ ⟨β, s, _⟩ ⟨γ, t, _⟩ =>
      Eq.symm <|
        Quotient.sound
          ⟨⟨prodAssoc _ _ _, fun a b => by
              rcases a with ⟨⟨a₁, a₂⟩, a₃⟩
              rcases b with ⟨⟨b₁, b₂⟩, b₃⟩
              simp [Prod.lex_def, and_or_left, or_assoc', and_assoc']⟩⟩
  mul_one a :=
    inductionOn a fun α r _ =>
      Quotient.sound
        ⟨⟨punitProd _, fun a b => by
            rcases a with ⟨⟨⟨⟩⟩, a⟩ <;> rcases b with ⟨⟨⟨⟩⟩, b⟩ <;>
                  simp only [Prod.lex_def, EmptyRelation, false_or_iff] <;>
                simp only [eq_self_iff_true, true_and_iff] <;>
              rfl⟩⟩
  one_mul a :=
    inductionOn a fun α r _ =>
      Quotient.sound
        ⟨⟨prodPUnit _, fun a b => by
            rcases a with ⟨a, ⟨⟨⟩⟩⟩ <;> rcases b with ⟨b, ⟨⟨⟩⟩⟩ <;>
                simp only [Prod.lex_def, EmptyRelation, and_false_iff, or_false_iff] <;>
              rfl⟩⟩

/- warning: ordinal.type_prod_lex -> Ordinal.type_prod_lex is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u1}} (r : α -> α -> Prop) (s : β -> β -> Prop) [_inst_1 : IsWellOrder.{u1} α r] [_inst_2 : IsWellOrder.{u1} β s], Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} (Prod.{u1, u1} β α) (Prod.Lex.{u1, u1} β α s r) (Prod.Lex.isWellOrder.{u1, u1} β α s r _inst_2 _inst_1)) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulOneClass.toHasMul.{succ u1} Ordinal.{u1} (Monoid.toMulOneClass.{succ u1} Ordinal.{u1} Ordinal.monoid.{u1}))) (Ordinal.type.{u1} α r _inst_1) (Ordinal.type.{u1} β s _inst_2))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u1}} (r : α -> α -> Prop) (s : β -> β -> Prop) [_inst_1 : IsWellOrder.{u1} α r] [_inst_2 : IsWellOrder.{u1} β s], Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} (Prod.{u1, u1} β α) (Prod.Lex.{u1, u1} β α s r) (instIsWellOrderProdLex.{u1, u1} β α s r _inst_2 _inst_1)) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulOneClass.toMul.{succ u1} Ordinal.{u1} (Monoid.toMulOneClass.{succ u1} Ordinal.{u1} Ordinal.monoid.{u1}))) (Ordinal.type.{u1} α r _inst_1) (Ordinal.type.{u1} β s _inst_2))
Case conversion may be inaccurate. Consider using '#align ordinal.type_prod_lex Ordinal.type_prod_lexₓ'. -/
@[simp]
theorem type_prod_lex {α β : Type u} (r : α → α → Prop) (s : β → β → Prop) [IsWellOrder α r]
    [IsWellOrder β s] : type (Prod.Lex s r) = type r * type s :=
  rfl
#align ordinal.type_prod_lex Ordinal.type_prod_lex

private theorem mul_eq_zero' {a b : Ordinal} : a * b = 0 ↔ a = 0 ∨ b = 0 :=
  inductionOn a fun α _ _ =>
    inductionOn b fun β _ _ =>
      by
      simp_rw [← type_prod_lex, type_eq_zero_iff_is_empty]
      rw [or_comm']
      exact isEmpty_prod
#align ordinal.mul_eq_zero' ordinal.mul_eq_zero'

instance : MonoidWithZero Ordinal :=
  { Ordinal.monoid with
    zero := 0
    mul_zero := fun a => mul_eq_zero'.2 <| Or.inr rfl
    zero_mul := fun a => mul_eq_zero'.2 <| Or.inl rfl }

instance : NoZeroDivisors Ordinal :=
  ⟨fun a b => mul_eq_zero'.1⟩

/- warning: ordinal.lift_mul -> Ordinal.lift_mul is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lift.{u2, u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b)) (HMul.hMul.{succ (max u1 u2), succ (max u1 u2), succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.{max u1 u2} Ordinal.{max u1 u2} (instHMul.{succ (max u1 u2)} Ordinal.{max u1 u2} (MulZeroClass.toHasMul.{succ (max u1 u2)} Ordinal.{max u1 u2} (MulZeroOneClass.toMulZeroClass.{succ (max u1 u2)} Ordinal.{max u1 u2} (MonoidWithZero.toMulZeroOneClass.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.monoidWithZero.{max u1 u2})))) (Ordinal.lift.{u2, u1} a) (Ordinal.lift.{u2, u1} b))
but is expected to have type
  forall (a : Ordinal.{u2}) (b : Ordinal.{u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lift.{u1, u2} (HMul.hMul.{succ u2, succ u2, succ u2} Ordinal.{u2} Ordinal.{u2} Ordinal.{u2} (instHMul.{succ u2} Ordinal.{u2} (MulZeroClass.toMul.{succ u2} Ordinal.{u2} (MulZeroOneClass.toMulZeroClass.{succ u2} Ordinal.{u2} (MonoidWithZero.toMulZeroOneClass.{succ u2} Ordinal.{u2} Ordinal.instMonoidWithZeroOrdinal.{u2})))) a b)) (HMul.hMul.{max (succ u1) (succ u2), max (succ u1) (succ u2), max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.{max u2 u1} Ordinal.{max u2 u1} (instHMul.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (MulZeroClass.toMul.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (MulZeroOneClass.toMulZeroClass.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (MonoidWithZero.toMulZeroOneClass.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instMonoidWithZeroOrdinal.{max u1 u2})))) (Ordinal.lift.{u1, u2} a) (Ordinal.lift.{u1, u2} b))
Case conversion may be inaccurate. Consider using '#align ordinal.lift_mul Ordinal.lift_mulₓ'. -/
@[simp]
theorem lift_mul (a b) : lift (a * b) = lift a * lift b :=
  Quotient.induction_on₂ a b fun ⟨α, r, _⟩ ⟨β, s, _⟩ =>
    Quotient.sound
      ⟨(RelIso.preimage Equiv.ulift _).trans
          (RelIso.prodLexCongr (RelIso.preimage Equiv.ulift _)
              (RelIso.preimage Equiv.ulift _)).symm⟩
#align ordinal.lift_mul Ordinal.lift_mul

/- warning: ordinal.card_mul -> Ordinal.card_mul is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Cardinal.{u1} (Ordinal.card.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b)) (HMul.hMul.{succ u1, succ u1, succ u1} Cardinal.{u1} Cardinal.{u1} Cardinal.{u1} (instHMul.{succ u1} Cardinal.{u1} Cardinal.hasMul.{u1}) (Ordinal.card.{u1} a) (Ordinal.card.{u1} b))
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Cardinal.{u1} (Ordinal.card.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b)) (HMul.hMul.{succ u1, succ u1, succ u1} Cardinal.{u1} Cardinal.{u1} Cardinal.{u1} (instHMul.{succ u1} Cardinal.{u1} Cardinal.instMulCardinal.{u1}) (Ordinal.card.{u1} a) (Ordinal.card.{u1} b))
Case conversion may be inaccurate. Consider using '#align ordinal.card_mul Ordinal.card_mulₓ'. -/
@[simp]
theorem card_mul (a b) : card (a * b) = card a * card b :=
  Quotient.induction_on₂ a b fun ⟨α, r, _⟩ ⟨β, s, _⟩ => mul_comm (mk β) (mk α)
#align ordinal.card_mul Ordinal.card_mul

instance : LeftDistribClass Ordinal.{u} :=
  ⟨fun a b c =>
    Quotient.induction_on₃ a b c fun ⟨α, r, _⟩ ⟨β, s, _⟩ ⟨γ, t, _⟩ =>
      Quotient.sound
        ⟨⟨sumProdDistrib _ _ _, by
            rintro ⟨a₁ | a₁, a₂⟩ ⟨b₁ | b₁, b₂⟩ <;>
                simp only [Prod.lex_def, Sum.lex_inl_inl, Sum.Lex.sep, Sum.lex_inr_inl,
                  Sum.lex_inr_inr, sum_prod_distrib_apply_left, sum_prod_distrib_apply_right] <;>
              simp only [Sum.inl.inj_iff, true_or_iff, false_and_iff, false_or_iff]⟩⟩⟩

/- warning: ordinal.mul_succ -> Ordinal.mul_succ is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} b)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b) a)
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} b)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b) a)
Case conversion may be inaccurate. Consider using '#align ordinal.mul_succ Ordinal.mul_succₓ'. -/
theorem mul_succ (a b : Ordinal) : a * succ b = a * b + a :=
  mul_add_one a b
#align ordinal.mul_succ Ordinal.mul_succ

/- warning: ordinal.mul_covariant_class_le -> Ordinal.mul_covariantClass_le is a dubious translation:
lean 3 declaration is
  CovariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))))) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})))
but is expected to have type
  CovariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9742 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9744 : Ordinal.{u1}) => HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9742 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9744) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9757 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9759 : Ordinal.{u1}) => LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9757 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9759)
Case conversion may be inaccurate. Consider using '#align ordinal.mul_covariant_class_le Ordinal.mul_covariantClass_leₓ'. -/
instance mul_covariantClass_le : CovariantClass Ordinal.{u} Ordinal.{u} (· * ·) (· ≤ ·) :=
  ⟨fun c a b =>
    Quotient.induction_on₃ a b c fun ⟨α, r, _⟩ ⟨β, s, _⟩ ⟨γ, t, _⟩ ⟨f⟩ =>
      by
      skip
      refine'
        (RelEmbedding.ofMonotone (fun a : α × γ => (f a.1, a.2)) fun a b h => _).ordinal_type_le
      clear_
      cases' h with a₁ b₁ a₂ b₂ h' a b₁ b₂ h'
      · exact Prod.Lex.left _ _ (f.to_rel_embedding.map_rel_iff.2 h')
      · exact Prod.Lex.right _ h'⟩
#align ordinal.mul_covariant_class_le Ordinal.mul_covariantClass_le

/- warning: ordinal.mul_swap_covariant_class_le -> Ordinal.mul_swap_covariantClass_le is a dubious translation:
lean 3 declaration is
  CovariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (Function.swap.{succ (succ u1), succ (succ u1), succ (succ u1)} Ordinal.{u1} Ordinal.{u1} (fun (ᾰ : Ordinal.{u1}) (ᾰ : Ordinal.{u1}) => Ordinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))))) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})))
but is expected to have type
  CovariantClass.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (Function.swap.{succ (succ u1), succ (succ u1), succ (succ u1)} Ordinal.{u1} Ordinal.{u1} (fun (ᾰ : Ordinal.{u1}) (ᾰ : Ordinal.{u1}) => Ordinal.{u1}) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9979 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9981 : Ordinal.{u1}) => HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9979 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9981)) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9994 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9996 : Ordinal.{u1}) => LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9994 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.9996)
Case conversion may be inaccurate. Consider using '#align ordinal.mul_swap_covariant_class_le Ordinal.mul_swap_covariantClass_leₓ'. -/
instance mul_swap_covariantClass_le :
    CovariantClass Ordinal.{u} Ordinal.{u} (swap (· * ·)) (· ≤ ·) :=
  ⟨fun c a b =>
    Quotient.induction_on₃ a b c fun ⟨α, r, _⟩ ⟨β, s, _⟩ ⟨γ, t, _⟩ ⟨f⟩ =>
      by
      skip
      refine'
        (RelEmbedding.ofMonotone (fun a : γ × α => (a.1, f a.2)) fun a b h => _).ordinal_type_le
      cases' h with a₁ b₁ a₂ b₂ h' a b₁ b₂ h'
      · exact Prod.Lex.left _ _ h'
      · exact Prod.Lex.right _ (f.to_rel_embedding.map_rel_iff.2 h')⟩
#align ordinal.mul_swap_covariant_class_le Ordinal.mul_swap_covariantClass_le

/- warning: ordinal.le_mul_left -> Ordinal.le_mul_left is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b))
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.le_mul_left Ordinal.le_mul_leftₓ'. -/
theorem le_mul_left (a : Ordinal) {b : Ordinal} (hb : 0 < b) : a ≤ a * b :=
  by
  convert mul_le_mul_left' (one_le_iff_pos.2 hb) a
  rw [mul_one a]
#align ordinal.le_mul_left Ordinal.le_mul_left

/- warning: ordinal.le_mul_right -> Ordinal.le_mul_right is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b a))
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b a))
Case conversion may be inaccurate. Consider using '#align ordinal.le_mul_right Ordinal.le_mul_rightₓ'. -/
theorem le_mul_right (a : Ordinal) {b : Ordinal} (hb : 0 < b) : a ≤ b * a :=
  by
  convert mul_le_mul_right' (one_le_iff_pos.2 hb) a
  rw [one_mul a]
#align ordinal.le_mul_right Ordinal.le_mul_right

private theorem mul_le_of_limit_aux {α β r s} [IsWellOrder α r] [IsWellOrder β s] {c}
    (h : IsLimit (type s)) (H : ∀ b' < type s, type r * b' ≤ c) (l : c < type r * type s) : False :=
  by
  suffices ∀ a b, Prod.Lex s r (b, a) (enum _ _ l)
    by
    cases' enum _ _ l with b a
    exact irrefl _ (this _ _)
  intro a b
  rw [← typein_lt_typein (Prod.Lex s r), typein_enum]
  have := H _ (h.2 _ (typein_lt_type s b))
  rw [mul_succ] at this
  have := ((add_lt_add_iff_left _).2 (typein_lt_type _ a)).trans_le this
  refine' (RelEmbedding.ofMonotone (fun a => _) fun a b => _).ordinal_type_le.trans_lt this
  · rcases a with ⟨⟨b', a'⟩, h⟩
    by_cases e : b = b'
    · refine' Sum.inr ⟨a', _⟩
      subst e
      cases' h with _ _ _ _ h _ _ _ h
      · exact (irrefl _ h).elim
      · exact h
    · refine' Sum.inl (⟨b', _⟩, a')
      cases' h with _ _ _ _ h _ _ _ h
      · exact h
      · exact (e rfl).elim
  · rcases a with ⟨⟨b₁, a₁⟩, h₁⟩
    rcases b with ⟨⟨b₂, a₂⟩, h₂⟩
    intro h
    by_cases e₁ : b = b₁ <;> by_cases e₂ : b = b₂
    · substs b₁ b₂
      simpa only [subrel_val, Prod.lex_def, @irrefl _ s _ b, true_and_iff, false_or_iff,
        eq_self_iff_true, dif_pos, Sum.lex_inr_inr] using h
    · subst b₁
      simp only [subrel_val, Prod.lex_def, e₂, Prod.lex_def, dif_pos, subrel_val, eq_self_iff_true,
        or_false_iff, dif_neg, not_false_iff, Sum.lex_inr_inl, false_and_iff] at h⊢
      cases h₂ <;> [exact asymm h h₂_h, exact e₂ rfl]
    · simp [e₂, dif_neg e₁, show b₂ ≠ b₁ by cc]
    ·
      simpa only [dif_neg e₁, dif_neg e₂, Prod.lex_def, subrel_val, Subtype.mk_eq_mk,
        Sum.lex_inl_inl] using h
#align ordinal.mul_le_of_limit_aux ordinal.mul_le_of_limit_aux

/- warning: ordinal.mul_le_of_limit -> Ordinal.mul_le_of_limit is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} b) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b) c) (forall (b' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b' b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b') c)))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} b) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b) c) (forall (b' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b' b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b') c)))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_le_of_limit Ordinal.mul_le_of_limitₓ'. -/
theorem mul_le_of_limit {a b c : Ordinal} (h : IsLimit b) : a * b ≤ c ↔ ∀ b' < b, a * b' ≤ c :=
  ⟨fun h b' l => (mul_le_mul_left' l.le _).trans h, fun H =>
    le_of_not_lt <| inductionOn a (fun α r _ => inductionOn b fun β s _ => mul_le_of_limit_aux) h H⟩
#align ordinal.mul_le_of_limit Ordinal.mul_le_of_limit

/- warning: ordinal.mul_is_normal -> Ordinal.mul_isNormal is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) -> (Ordinal.IsNormal.{u1, u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a))
but is expected to have type
  forall {a : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) -> (Ordinal.IsNormal.{u1, u1} ((fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.11063 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.11065 : Ordinal.{u1}) => HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.11063 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.11065) a))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_is_normal Ordinal.mul_isNormalₓ'. -/
theorem mul_isNormal {a : Ordinal} (h : 0 < a) : IsNormal ((· * ·) a) :=
  ⟨fun b => by rw [mul_succ] <;> simpa only [add_zero] using (add_lt_add_iff_left (a * b)).2 h,
    fun b l c => mul_le_of_limit l⟩
#align ordinal.mul_is_normal Ordinal.mul_isNormal

/- warning: ordinal.lt_mul_of_limit -> Ordinal.lt_mul_of_limit is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} c) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b c)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (c' : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c' c) (fun (H : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c' c) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b c')))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} c) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b c)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (c' : Ordinal.{u1}) => And (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c' c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b c')))))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_mul_of_limit Ordinal.lt_mul_of_limitₓ'. -/
theorem lt_mul_of_limit {a b c : Ordinal} (h : IsLimit c) : a < b * c ↔ ∃ c' < c, a < b * c' := by
  simpa only [not_ball, not_le] using not_congr (@mul_le_of_limit b c a h)
#align ordinal.lt_mul_of_limit Ordinal.lt_mul_of_limit

/- warning: ordinal.mul_lt_mul_iff_left -> Ordinal.mul_lt_mul_iff_left is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a c)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b c))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a c)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b c))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_lt_mul_iff_left Ordinal.mul_lt_mul_iff_leftₓ'. -/
theorem mul_lt_mul_iff_left {a b c : Ordinal} (a0 : 0 < a) : a * b < a * c ↔ b < c :=
  (mul_isNormal a0).lt_iff
#align ordinal.mul_lt_mul_iff_left Ordinal.mul_lt_mul_iff_left

/- warning: ordinal.mul_le_mul_iff_left -> Ordinal.mul_le_mul_iff_left is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b c))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b c))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_le_mul_iff_left Ordinal.mul_le_mul_iff_leftₓ'. -/
theorem mul_le_mul_iff_left {a b c : Ordinal} (a0 : 0 < a) : a * b ≤ a * c ↔ b ≤ c :=
  (mul_isNormal a0).le_iff
#align ordinal.mul_le_mul_iff_left Ordinal.mul_le_mul_iff_left

/- warning: ordinal.mul_lt_mul_of_pos_left -> Ordinal.mul_lt_mul_of_pos_left is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) c) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) c a) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) c b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) c) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) c a) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) c b))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_lt_mul_of_pos_left Ordinal.mul_lt_mul_of_pos_leftₓ'. -/
theorem mul_lt_mul_of_pos_left {a b c : Ordinal} (h : a < b) (c0 : 0 < c) : c * a < c * b :=
  (mul_lt_mul_iff_left c0).2 h
#align ordinal.mul_lt_mul_of_pos_left Ordinal.mul_lt_mul_of_pos_left

/- warning: ordinal.mul_pos -> Ordinal.mul_pos is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_pos Ordinal.mul_posₓ'. -/
theorem mul_pos {a b : Ordinal} (h₁ : 0 < a) (h₂ : 0 < b) : 0 < a * b := by
  simpa only [mul_zero] using mul_lt_mul_of_pos_left h₂ h₁
#align ordinal.mul_pos Ordinal.mul_pos

/- warning: ordinal.mul_ne_zero -> Ordinal.mul_ne_zero is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Ne.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Ne.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_ne_zero Ordinal.mul_ne_zeroₓ'. -/
theorem mul_ne_zero {a b : Ordinal} : a ≠ 0 → b ≠ 0 → a * b ≠ 0 := by
  simpa only [Ordinal.pos_iff_ne_zero] using mul_pos
#align ordinal.mul_ne_zero Ordinal.mul_ne_zero

/- warning: ordinal.le_of_mul_le_mul_left -> Ordinal.le_of_mul_le_mul_left is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) c a) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) c b)) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) c) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) c a) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) c b)) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) c) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a b)
Case conversion may be inaccurate. Consider using '#align ordinal.le_of_mul_le_mul_left Ordinal.le_of_mul_le_mul_leftₓ'. -/
theorem le_of_mul_le_mul_left {a b c : Ordinal} (h : c * a ≤ c * b) (h0 : 0 < c) : a ≤ b :=
  le_imp_le_of_lt_imp_lt (fun h' => mul_lt_mul_of_pos_left h' h0) h
#align ordinal.le_of_mul_le_mul_left Ordinal.le_of_mul_le_mul_left

/- warning: ordinal.mul_right_inj -> Ordinal.mul_right_inj is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) -> (Iff (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a c)) (Eq.{succ (succ u1)} Ordinal.{u1} b c))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) -> (Iff (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a c)) (Eq.{succ (succ u1)} Ordinal.{u1} b c))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_right_inj Ordinal.mul_right_injₓ'. -/
theorem mul_right_inj {a b c : Ordinal} (a0 : 0 < a) : a * b = a * c ↔ b = c :=
  (mul_isNormal a0).inj
#align ordinal.mul_right_inj Ordinal.mul_right_inj

/- warning: ordinal.mul_is_limit -> Ordinal.mul_isLimit is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) -> (Ordinal.IsLimit.{u1} b) -> (Ordinal.IsLimit.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) -> (Ordinal.IsLimit.{u1} b) -> (Ordinal.IsLimit.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_is_limit Ordinal.mul_isLimitₓ'. -/
theorem mul_isLimit {a b : Ordinal} (a0 : 0 < a) : IsLimit b → IsLimit (a * b) :=
  (mul_isNormal a0).IsLimit
#align ordinal.mul_is_limit Ordinal.mul_isLimit

/- warning: ordinal.mul_is_limit_left -> Ordinal.mul_isLimit_left is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} a) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) b) -> (Ordinal.IsLimit.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} a) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) b) -> (Ordinal.IsLimit.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_is_limit_left Ordinal.mul_isLimit_leftₓ'. -/
theorem mul_isLimit_left {a b : Ordinal} (l : IsLimit a) (b0 : 0 < b) : IsLimit (a * b) :=
  by
  rcases zero_or_succ_or_limit b with (rfl | ⟨b, rfl⟩ | lb)
  · exact b0.false.elim
  · rw [mul_succ]
    exact add_is_limit _ l
  · exact mul_is_limit l.pos lb
#align ordinal.mul_is_limit_left Ordinal.mul_isLimit_left

/- warning: ordinal.smul_eq_mul -> Ordinal.smul_eq_mul is a dubious translation:
lean 3 declaration is
  forall (n : Nat) (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (SMul.smul.{0, succ u1} Nat Ordinal.{u1} (AddMonoid.SMul.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toAddMonoid.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})) n a) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))
but is expected to have type
  forall (n : Nat) (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HSMul.hSMul.{0, succ u1, succ u1} Nat Ordinal.{u1} Ordinal.{u1} (instHSMul.{0, succ u1} Nat Ordinal.{u1} (AddMonoid.SMul.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toAddMonoid.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}))) n a) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))
Case conversion may be inaccurate. Consider using '#align ordinal.smul_eq_mul Ordinal.smul_eq_mulₓ'. -/
theorem smul_eq_mul : ∀ (n : ℕ) (a : Ordinal), n • a = a * n
  | 0, a => by rw [zero_smul, Nat.cast_zero, mul_zero]
  | n + 1, a => by rw [succ_nsmul', Nat.cast_add, mul_add, Nat.cast_one, mul_one, smul_eq_mul]
#align ordinal.smul_eq_mul Ordinal.smul_eq_mul

/-! ### Division on ordinals -/


/- warning: ordinal.div_nonempty -> Ordinal.div_nonempty is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Set.Nonempty.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Set.Nonempty.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (o : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))
Case conversion may be inaccurate. Consider using '#align ordinal.div_nonempty Ordinal.div_nonemptyₓ'. -/
/-- The set in the definition of division is nonempty. -/
theorem div_nonempty {a b : Ordinal} (h : b ≠ 0) : { o | a < b * succ o }.Nonempty :=
  ⟨a,
    succ_le_iff.1 <| by
      simpa only [succ_zero, one_mul] using
        mul_le_mul_right' (succ_le_of_lt (Ordinal.pos_iff_ne_zero.2 h)) (succ a)⟩
#align ordinal.div_nonempty Ordinal.div_nonempty

/-- `a / b` is the unique ordinal `o` satisfying `a = b * o + o'` with `o' < b`. -/
instance : Div Ordinal :=
  ⟨fun a b => if h : b = 0 then 0 else infₛ { o | a < b * succ o }⟩

/- warning: ordinal.div_zero -> Ordinal.div_zero is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.div_zero Ordinal.div_zeroₓ'. -/
@[simp]
theorem div_zero (a : Ordinal) : a / 0 = 0 :=
  dif_pos rfl
#align ordinal.div_zero Ordinal.div_zero

/- warning: ordinal.div_def -> Ordinal.div_def is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toHasInf.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.conditionallyCompleteLinearOrderBot.{u1}))) (setOf.{succ u1} Ordinal.{u1} (fun (o : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))))))
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toInfSet.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{u1}))) (setOf.{succ u1} Ordinal.{u1} (fun (o : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))))))
Case conversion may be inaccurate. Consider using '#align ordinal.div_def Ordinal.div_defₓ'. -/
theorem div_def (a) {b : Ordinal} (h : b ≠ 0) : a / b = infₛ { o | a < b * succ o } :=
  dif_neg h
#align ordinal.div_def Ordinal.div_def

/- warning: ordinal.lt_mul_succ_div -> Ordinal.lt_mul_succ_div is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b))))
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b))))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_mul_succ_div Ordinal.lt_mul_succ_divₓ'. -/
theorem lt_mul_succ_div (a) {b : Ordinal} (h : b ≠ 0) : a < b * succ (a / b) := by
  rw [div_def a h] <;> exact cinfₛ_mem (div_nonempty h)
#align ordinal.lt_mul_succ_div Ordinal.lt_mul_succ_div

/- warning: ordinal.lt_mul_div_add -> Ordinal.lt_mul_div_add is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b)) b))
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b)) b))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_mul_div_add Ordinal.lt_mul_div_addₓ'. -/
theorem lt_mul_div_add (a) {b : Ordinal} (h : b ≠ 0) : a < b * (a / b) + b := by
  simpa only [mul_succ] using lt_mul_succ_div a h
#align ordinal.lt_mul_div_add Ordinal.lt_mul_div_add

/- warning: ordinal.div_le -> Ordinal.div_le is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b) c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} c))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b) c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} c))))
Case conversion may be inaccurate. Consider using '#align ordinal.div_le Ordinal.div_leₓ'. -/
theorem div_le {a b c : Ordinal} (b0 : b ≠ 0) : a / b ≤ c ↔ a < b * succ c :=
  ⟨fun h => (lt_mul_succ_div a b0).trans_le (mul_le_mul_left' (succ_le_succ_iff.2 h) _), fun h => by
    rw [div_def a b0] <;> exact cinfₛ_le' h⟩
#align ordinal.div_le Ordinal.div_le

/- warning: ordinal.lt_div -> Ordinal.lt_div is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} c (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) b c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) c (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)) b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} c (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) b c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) c (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a)) b))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_div Ordinal.lt_divₓ'. -/
theorem lt_div {a b c : Ordinal} (h : c ≠ 0) : a < b / c ↔ c * succ a ≤ b := by
  rw [← not_le, div_le h, not_lt]
#align ordinal.lt_div Ordinal.lt_div

/- warning: ordinal.div_pos -> Ordinal.div_pos is a dubious translation:
lean 3 declaration is
  forall {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} c (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) b c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c b))
but is expected to have type
  forall {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} c (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) b c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c b))
Case conversion may be inaccurate. Consider using '#align ordinal.div_pos Ordinal.div_posₓ'. -/
theorem div_pos {b c : Ordinal} (h : c ≠ 0) : 0 < b / c ↔ c ≤ b := by simp [lt_div h]
#align ordinal.div_pos Ordinal.div_pos

/- warning: ordinal.le_div -> Ordinal.le_div is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} c (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) b c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) c a) b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} c (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) b c)) (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) c a) b))
Case conversion may be inaccurate. Consider using '#align ordinal.le_div Ordinal.le_divₓ'. -/
theorem le_div {a b c : Ordinal} (c0 : c ≠ 0) : a ≤ b / c ↔ c * a ≤ b :=
  by
  apply limit_rec_on a
  · simp only [mul_zero, Ordinal.zero_le]
  · intros
    rw [succ_le_iff, lt_div c0]
  ·
    simp (config := { contextual := true }) only [mul_le_of_limit, limit_le, iff_self_iff,
      forall_true_iff]
#align ordinal.le_div Ordinal.le_div

/- warning: ordinal.div_lt -> Ordinal.div_lt is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b) c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b c)))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b) c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b c)))
Case conversion may be inaccurate. Consider using '#align ordinal.div_lt Ordinal.div_ltₓ'. -/
theorem div_lt {a b c : Ordinal} (b0 : b ≠ 0) : a / b < c ↔ a < b * c :=
  lt_iff_lt_of_le_iff_le <| le_div b0
#align ordinal.div_lt Ordinal.div_lt

/- warning: ordinal.div_le_of_le_mul -> Ordinal.div_le_of_le_mul is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b c)) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b) c)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b c)) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b) c)
Case conversion may be inaccurate. Consider using '#align ordinal.div_le_of_le_mul Ordinal.div_le_of_le_mulₓ'. -/
theorem div_le_of_le_mul {a b c : Ordinal} (h : a ≤ b * c) : a / b ≤ c :=
  if b0 : b = 0 then by simp only [b0, div_zero, Ordinal.zero_le]
  else
    (div_le b0).2 <| h.trans_lt <| mul_lt_mul_of_pos_left (lt_succ c) (Ordinal.pos_iff_ne_zero.2 b0)
#align ordinal.div_le_of_le_mul Ordinal.div_le_of_le_mul

/- warning: ordinal.mul_lt_of_lt_div -> Ordinal.mul_lt_of_lt_div is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) b c)) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) c a) b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) b c)) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) c a) b)
Case conversion may be inaccurate. Consider using '#align ordinal.mul_lt_of_lt_div Ordinal.mul_lt_of_lt_divₓ'. -/
theorem mul_lt_of_lt_div {a b c : Ordinal} : a < b / c → c * a < b :=
  lt_imp_lt_of_le_imp_le div_le_of_le_mul
#align ordinal.mul_lt_of_lt_div Ordinal.mul_lt_of_lt_div

/- warning: ordinal.zero_div -> Ordinal.zero_div is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.zero_div Ordinal.zero_divₓ'. -/
@[simp]
theorem zero_div (a : Ordinal) : 0 / a = 0 :=
  Ordinal.le_zero.1 <| div_le_of_le_mul <| Ordinal.zero_le _
#align ordinal.zero_div Ordinal.zero_div

/- warning: ordinal.mul_div_le -> Ordinal.mul_div_le is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b)) a
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b)) a
Case conversion may be inaccurate. Consider using '#align ordinal.mul_div_le Ordinal.mul_div_leₓ'. -/
theorem mul_div_le (a b : Ordinal) : b * (a / b) ≤ a :=
  if b0 : b = 0 then by simp only [b0, zero_mul, Ordinal.zero_le] else (le_div b0).1 le_rfl
#align ordinal.mul_div_le Ordinal.mul_div_le

/- warning: ordinal.mul_add_div -> Ordinal.mul_add_div is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (forall (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b a) c) b) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) c b)))
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (forall (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b a) c) b) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) c b)))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_add_div Ordinal.mul_add_divₓ'. -/
theorem mul_add_div (a) {b : Ordinal} (b0 : b ≠ 0) (c) : (b * a + c) / b = a + c / b :=
  by
  apply le_antisymm
  · apply (div_le b0).2
    rw [mul_succ, mul_add, add_assoc, add_lt_add_iff_left]
    apply lt_mul_div_add _ b0
  · rw [le_div b0, mul_add, add_le_add_iff_left]
    apply mul_div_le
#align ordinal.mul_add_div Ordinal.mul_add_div

/- warning: ordinal.div_eq_zero_of_lt -> Ordinal.div_eq_zero_of_lt is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a b) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})))
Case conversion may be inaccurate. Consider using '#align ordinal.div_eq_zero_of_lt Ordinal.div_eq_zero_of_ltₓ'. -/
theorem div_eq_zero_of_lt {a b : Ordinal} (h : a < b) : a / b = 0 :=
  by
  rw [← Ordinal.le_zero, div_le <| Ordinal.pos_iff_ne_zero.1 <| (Ordinal.zero_le _).trans_lt h]
  simpa only [succ_zero, mul_one] using h
#align ordinal.div_eq_zero_of_lt Ordinal.div_eq_zero_of_lt

/- warning: ordinal.mul_div_cancel -> Ordinal.mul_div_cancel is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b a) b) a)
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b a) b) a)
Case conversion may be inaccurate. Consider using '#align ordinal.mul_div_cancel Ordinal.mul_div_cancelₓ'. -/
@[simp]
theorem mul_div_cancel (a) {b : Ordinal} (b0 : b ≠ 0) : b * a / b = a := by
  simpa only [add_zero, zero_div] using mul_add_div a b0 0
#align ordinal.mul_div_cancel Ordinal.mul_div_cancel

/- warning: ordinal.div_one -> Ordinal.div_one is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1})))) a
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1}))) a
Case conversion may be inaccurate. Consider using '#align ordinal.div_one Ordinal.div_oneₓ'. -/
@[simp]
theorem div_one (a : Ordinal) : a / 1 = a := by
  simpa only [one_mul] using mul_div_cancel a Ordinal.one_ne_zero
#align ordinal.div_one Ordinal.div_one

/- warning: ordinal.div_self -> Ordinal.div_self is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))))
but is expected to have type
  forall {a : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1})))
Case conversion may be inaccurate. Consider using '#align ordinal.div_self Ordinal.div_selfₓ'. -/
@[simp]
theorem div_self {a : Ordinal} (h : a ≠ 0) : a / a = 1 := by
  simpa only [mul_one] using mul_div_cancel 1 h
#align ordinal.div_self Ordinal.div_self

/- warning: ordinal.mul_sub -> Ordinal.mul_sub is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}) (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) b c)) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a c))
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}) (c : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) b c)) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a b) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a c))
Case conversion may be inaccurate. Consider using '#align ordinal.mul_sub Ordinal.mul_subₓ'. -/
theorem mul_sub (a b c : Ordinal) : a * (b - c) = a * b - a * c :=
  if a0 : a = 0 then by simp only [a0, zero_mul, sub_self]
  else
    eq_of_forall_ge_iff fun d => by rw [sub_le, ← le_div a0, sub_le, ← le_div a0, mul_add_div _ a0]
#align ordinal.mul_sub Ordinal.mul_sub

#print Ordinal.isLimit_add_iff /-
theorem isLimit_add_iff {a b} : IsLimit (a + b) ↔ IsLimit b ∨ b = 0 ∧ IsLimit a :=
  by
  constructor <;> intro h
  · by_cases h' : b = 0
    · rw [h', add_zero] at h
      right
      exact ⟨h', h⟩
    left
    rw [← add_sub_cancel a b]
    apply sub_is_limit h
    suffices : a + 0 < a + b
    simpa only [add_zero]
    rwa [add_lt_add_iff_left, Ordinal.pos_iff_ne_zero]
  rcases h with (h | ⟨rfl, h⟩); exact add_is_limit a h; simpa only [add_zero]
#align ordinal.is_limit_add_iff Ordinal.isLimit_add_iff
-/

/- warning: ordinal.dvd_add_iff -> Ordinal.dvd_add_iff is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) a b) -> (Iff (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b c)) (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) a c))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) a b) -> (Iff (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b c)) (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) a c))
Case conversion may be inaccurate. Consider using '#align ordinal.dvd_add_iff Ordinal.dvd_add_iffₓ'. -/
theorem dvd_add_iff : ∀ {a b c : Ordinal}, a ∣ b → (a ∣ b + c ↔ a ∣ c)
  | a, _, c, ⟨b, rfl⟩ =>
    ⟨fun ⟨d, e⟩ => ⟨d - b, by rw [mul_sub, ← e, add_sub_cancel]⟩, fun ⟨d, e⟩ =>
      by
      rw [e, ← mul_add]
      apply dvd_mul_right⟩
#align ordinal.dvd_add_iff Ordinal.dvd_add_iff

/- warning: ordinal.div_mul_cancel -> Ordinal.div_mul_cancel is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) a b) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) b a)) b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) a b) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) b a)) b)
Case conversion may be inaccurate. Consider using '#align ordinal.div_mul_cancel Ordinal.div_mul_cancelₓ'. -/
theorem div_mul_cancel : ∀ {a b : Ordinal}, a ≠ 0 → a ∣ b → a * (b / a) = b
  | a, _, a0, ⟨b, rfl⟩ => by rw [mul_div_cancel _ a0]
#align ordinal.div_mul_cancel Ordinal.div_mul_cancel

/- warning: ordinal.le_of_dvd -> Ordinal.le_of_dvd is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) a b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) a b) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a b)
Case conversion may be inaccurate. Consider using '#align ordinal.le_of_dvd Ordinal.le_of_dvdₓ'. -/
theorem le_of_dvd : ∀ {a b : Ordinal}, b ≠ 0 → a ∣ b → a ≤ b
  | a, _, b0, ⟨b, rfl⟩ => by
    simpa only [mul_one] using
      mul_le_mul_left' (one_le_iff_ne_zero.2 fun h : b = 0 => by simpa only [h, mul_zero] using b0)
        a
#align ordinal.le_of_dvd Ordinal.le_of_dvd

/- warning: ordinal.dvd_antisymm -> Ordinal.dvd_antisymm is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) a b) -> (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) b a) -> (Eq.{succ (succ u1)} Ordinal.{u1} a b)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) a b) -> (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) b a) -> (Eq.{succ (succ u1)} Ordinal.{u1} a b)
Case conversion may be inaccurate. Consider using '#align ordinal.dvd_antisymm Ordinal.dvd_antisymmₓ'. -/
theorem dvd_antisymm {a b : Ordinal} (h₁ : a ∣ b) (h₂ : b ∣ a) : a = b :=
  if a0 : a = 0 then by subst a <;> exact (eq_zero_of_zero_dvd h₁).symm
  else
    if b0 : b = 0 then by subst b <;> exact eq_zero_of_zero_dvd h₂
    else (le_of_dvd b0 h₁).antisymm (le_of_dvd a0 h₂)
#align ordinal.dvd_antisymm Ordinal.dvd_antisymm

instance : IsAntisymm Ordinal (· ∣ ·) :=
  ⟨@dvd_antisymm⟩

/-- `a % b` is the unique ordinal `o'` satisfying
  `a = b * o + o'` with `o' < b`. -/
instance : Mod Ordinal :=
  ⟨fun a b => a - b * (a / b)⟩

/- warning: ordinal.mod_def -> Ordinal.mod_def is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a b) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b)))
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a b) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) a (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b)))
Case conversion may be inaccurate. Consider using '#align ordinal.mod_def Ordinal.mod_defₓ'. -/
theorem mod_def (a b : Ordinal) : a % b = a - b * (a / b) :=
  rfl
#align ordinal.mod_def Ordinal.mod_def

/- warning: ordinal.mod_zero -> Ordinal.mod_zero is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) a
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) a
Case conversion may be inaccurate. Consider using '#align ordinal.mod_zero Ordinal.mod_zeroₓ'. -/
@[simp]
theorem mod_zero (a : Ordinal) : a % 0 = a := by simp only [mod_def, div_zero, zero_mul, sub_zero]
#align ordinal.mod_zero Ordinal.mod_zero

/- warning: ordinal.mod_eq_of_lt -> Ordinal.mod_eq_of_lt is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a b) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a b) a)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a b) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a b) a)
Case conversion may be inaccurate. Consider using '#align ordinal.mod_eq_of_lt Ordinal.mod_eq_of_ltₓ'. -/
theorem mod_eq_of_lt {a b : Ordinal} (h : a < b) : a % b = a := by
  simp only [mod_def, div_eq_zero_of_lt h, mul_zero, sub_zero]
#align ordinal.mod_eq_of_lt Ordinal.mod_eq_of_lt

/- warning: ordinal.zero_mod -> Ordinal.zero_mod is a dubious translation:
lean 3 declaration is
  forall (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))
but is expected to have type
  forall (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.zero_mod Ordinal.zero_modₓ'. -/
@[simp]
theorem zero_mod (b : Ordinal) : 0 % b = 0 := by simp only [mod_def, zero_div, mul_zero, sub_self]
#align ordinal.zero_mod Ordinal.zero_mod

/- warning: ordinal.div_add_mod -> Ordinal.div_add_mod is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) a b)) (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a b)) a
but is expected to have type
  forall (a : Ordinal.{u1}) (b : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) b (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) a b)) (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a b)) a
Case conversion may be inaccurate. Consider using '#align ordinal.div_add_mod Ordinal.div_add_modₓ'. -/
theorem div_add_mod (a b : Ordinal) : b * (a / b) + a % b = a :=
  Ordinal.add_sub_cancel_of_le <| mul_div_le _ _
#align ordinal.div_add_mod Ordinal.div_add_mod

/- warning: ordinal.mod_lt -> Ordinal.mod_lt is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a b) b)
but is expected to have type
  forall (a : Ordinal.{u1}) {b : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} b (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a b) b)
Case conversion may be inaccurate. Consider using '#align ordinal.mod_lt Ordinal.mod_ltₓ'. -/
theorem mod_lt (a) {b : Ordinal} (h : b ≠ 0) : a % b < b :=
  (add_lt_add_iff_left (b * (a / b))).1 <| by rw [div_add_mod] <;> exact lt_mul_div_add a h
#align ordinal.mod_lt Ordinal.mod_lt

/- warning: ordinal.mod_self -> Ordinal.mod_self is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a a) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.mod_self Ordinal.mod_selfₓ'. -/
@[simp]
theorem mod_self (a : Ordinal) : a % a = 0 :=
  if a0 : a = 0 then by simp only [a0, zero_mod]
  else by simp only [mod_def, div_self a0, mul_one, sub_self]
#align ordinal.mod_self Ordinal.mod_self

/- warning: ordinal.mod_one -> Ordinal.mod_one is a dubious translation:
lean 3 declaration is
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1})))) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))
but is expected to have type
  forall (a : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1}))) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.mod_one Ordinal.mod_oneₓ'. -/
@[simp]
theorem mod_one (a : Ordinal) : a % 1 = 0 := by simp only [mod_def, div_one, one_mul, sub_self]
#align ordinal.mod_one Ordinal.mod_one

/- warning: ordinal.dvd_of_mod_eq_zero -> Ordinal.dvd_of_mod_eq_zero is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) b a)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) b a)
Case conversion may be inaccurate. Consider using '#align ordinal.dvd_of_mod_eq_zero Ordinal.dvd_of_mod_eq_zeroₓ'. -/
theorem dvd_of_mod_eq_zero {a b : Ordinal} (H : a % b = 0) : b ∣ a :=
  ⟨a / b, by simpa [H] using (div_add_mod a b).symm⟩
#align ordinal.dvd_of_mod_eq_zero Ordinal.dvd_of_mod_eq_zero

/- warning: ordinal.mod_eq_zero_of_dvd -> Ordinal.mod_eq_zero_of_dvd is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) b a) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) b a) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})))
Case conversion may be inaccurate. Consider using '#align ordinal.mod_eq_zero_of_dvd Ordinal.mod_eq_zero_of_dvdₓ'. -/
theorem mod_eq_zero_of_dvd {a b : Ordinal} (H : b ∣ a) : a % b = 0 :=
  by
  rcases H with ⟨c, rfl⟩
  rcases eq_or_ne b 0 with (rfl | hb)
  · simp
  · simp [mod_def, hb]
#align ordinal.mod_eq_zero_of_dvd Ordinal.mod_eq_zero_of_dvd

/- warning: ordinal.dvd_iff_mod_eq_zero -> Ordinal.dvd_iff_mod_eq_zero is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) b a) (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}}, Iff (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) b a) (Eq.{succ (succ u1)} Ordinal.{u1} (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) a b) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})))
Case conversion may be inaccurate. Consider using '#align ordinal.dvd_iff_mod_eq_zero Ordinal.dvd_iff_mod_eq_zeroₓ'. -/
theorem dvd_iff_mod_eq_zero {a b : Ordinal} : b ∣ a ↔ a % b = 0 :=
  ⟨mod_eq_zero_of_dvd, dvd_of_mod_eq_zero⟩
#align ordinal.dvd_iff_mod_eq_zero Ordinal.dvd_iff_mod_eq_zero

/-! ### Families of ordinals

There are two kinds of indexed families that naturally arise when dealing with ordinals: those
indexed by some type in the appropriate universe, and those indexed by ordinals less than another.
The following API allows one to convert from one kind of family to the other.

In many cases, this makes it easy to prove claims about one kind of family via the corresponding
claim on the other. -/


/- warning: ordinal.bfamily_of_family' -> Ordinal.bfamilyOfFamily' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r], (ι -> α) -> (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Ordinal.type.{u1} ι r _inst_1)) -> α)
but is expected to have type
  forall {α : Type.{u2}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r], (ι -> α) -> (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Ordinal.type.{u1} ι r _inst_1)) -> α)
Case conversion may be inaccurate. Consider using '#align ordinal.bfamily_of_family' Ordinal.bfamilyOfFamily'ₓ'. -/
/-- Converts a family indexed by a `Type u` to one indexed by an `ordinal.{u}` using a specified
well-ordering. -/
def bfamilyOfFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → α) :
    ∀ a < type r, α := fun a ha => f (enum r a ha)
#align ordinal.bfamily_of_family' Ordinal.bfamilyOfFamily'

/- warning: ordinal.bfamily_of_family -> Ordinal.bfamilyOfFamily is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {ι : Type.{u1}}, (ι -> α) -> (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Ordinal.type.{u1} ι (WellOrderingRel.{u1} ι) (WellOrderingRel.isWellOrder.{u1} ι))) -> α)
but is expected to have type
  forall {α : Type.{u2}} {ι : Type.{u1}}, (ι -> α) -> (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Ordinal.type.{u1} ι (WellOrderingRel.{u1} ι) (WellOrderingRel.isWellOrder.{u1} ι))) -> α)
Case conversion may be inaccurate. Consider using '#align ordinal.bfamily_of_family Ordinal.bfamilyOfFamilyₓ'. -/
/-- Converts a family indexed by a `Type u` to one indexed by an `ordinal.{u}` using a well-ordering
given by the axiom of choice. -/
def bfamilyOfFamily {ι : Type u} : (ι → α) → ∀ a < type (@WellOrderingRel ι), α :=
  bfamilyOfFamily' WellOrderingRel
#align ordinal.bfamily_of_family Ordinal.bfamilyOfFamily

/- warning: ordinal.family_of_bfamily' -> Ordinal.familyOfBFamily' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] {o : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) -> (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> α) -> ι -> α
but is expected to have type
  forall {α : Type.{u2}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] {o : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) -> (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> α) -> ι -> α
Case conversion may be inaccurate. Consider using '#align ordinal.family_of_bfamily' Ordinal.familyOfBFamily'ₓ'. -/
/-- Converts a family indexed by an `ordinal.{u}` to one indexed by an `Type u` using a specified
well-ordering. -/
def familyOfBFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] {o} (ho : type r = o)
    (f : ∀ a < o, α) : ι → α := fun i =>
  f (typein r i)
    (by
      rw [← ho]
      exact typein_lt_type r i)
#align ordinal.family_of_bfamily' Ordinal.familyOfBFamily'

/- warning: ordinal.family_of_bfamily -> Ordinal.familyOfBFamily is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (o : Ordinal.{u2}), (forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o) -> α) -> (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) -> α
but is expected to have type
  forall {α : Type.{u1}} (o : Ordinal.{u2}), (forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α) -> (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) -> α
Case conversion may be inaccurate. Consider using '#align ordinal.family_of_bfamily Ordinal.familyOfBFamilyₓ'. -/
/-- Converts a family indexed by an `ordinal.{u}` to one indexed by a `Type u` using a well-ordering
given by the axiom of choice. -/
def familyOfBFamily (o : Ordinal) (f : ∀ a < o, α) : o.out.α → α :=
  familyOfBFamily' (· < ·) (type_lt o) f
#align ordinal.family_of_bfamily Ordinal.familyOfBFamily

#print Ordinal.bfamilyOfFamily'_typein /-
@[simp]
theorem bfamilyOfFamily'_typein {ι} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → α) (i) :
    bfamilyOfFamily' r f (typein r i) (typein_lt_type r i) = f i := by
  simp only [bfamily_of_family', enum_typein]
#align ordinal.bfamily_of_family'_typein Ordinal.bfamilyOfFamily'_typein
-/

#print Ordinal.bfamilyOfFamily_typein /-
@[simp]
theorem bfamilyOfFamily_typein {ι} (f : ι → α) (i) :
    bfamilyOfFamily f (typein _ i) (typein_lt_type _ i) = f i :=
  bfamilyOfFamily'_typein _ f i
#align ordinal.bfamily_of_family_typein Ordinal.bfamilyOfFamily_typein
-/

/- warning: ordinal.family_of_bfamily'_enum -> Ordinal.familyOfBFamily'_enum is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> α) (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), Eq.{succ u2} α (Ordinal.familyOfBFamily'.{u1, u2} α ι r _inst_1 o ho f (Ordinal.enum.{u1} ι r _inst_1 i (Eq.mpr.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι r _inst_1)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (id_tag Tactic.IdTag.rw (Eq.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι r _inst_1)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o)) (Eq.ndrec.{0, succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) (fun (_a : Ordinal.{u1}) => Eq.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι r _inst_1)) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i _a)) (rfl.{1} Prop (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι r _inst_1))) o ho)) hi))) (f i hi)
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u2} ι r] {o : Ordinal.{u2}} (ho : Eq.{succ (succ u2)} Ordinal.{u2} (Ordinal.type.{u2} ι r _inst_1) o) (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α) (i : Ordinal.{u2}) (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), Eq.{succ u1} α (Ordinal.familyOfBFamily'.{u2, u1} α ι r _inst_1 o ho f (Ordinal.enum.{u2} ι r _inst_1 i (Eq.mpr.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i (Ordinal.type.{u2} ι r _inst_1)) (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o) (id.{0} (Eq.{1} Prop (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i (Ordinal.type.{u2} ι r _inst_1)) (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o)) (Eq.ndrec.{0, succ (succ u2)} Ordinal.{u2} (Ordinal.type.{u2} ι r _inst_1) (fun (_a : Ordinal.{u2}) => Eq.{1} Prop (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i (Ordinal.type.{u2} ι r _inst_1)) (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i _a)) (Eq.refl.{1} Prop (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i (Ordinal.type.{u2} ι r _inst_1))) o ho)) hi))) (f i hi)
Case conversion may be inaccurate. Consider using '#align ordinal.family_of_bfamily'_enum Ordinal.familyOfBFamily'_enumₓ'. -/
@[simp]
theorem familyOfBFamily'_enum {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] {o}
    (ho : type r = o) (f : ∀ a < o, α) (i hi) :
    familyOfBFamily' r ho f (enum r i (by rwa [ho])) = f i hi := by
  simp only [family_of_bfamily', typein_enum]
#align ordinal.family_of_bfamily'_enum Ordinal.familyOfBFamily'_enum

/- warning: ordinal.family_of_bfamily_enum -> Ordinal.familyOfBFamily_enum is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (o : Ordinal.{u2}) (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o) -> α) (i : Ordinal.{u2}) (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i o), Eq.{succ u1} α (Ordinal.familyOfBFamily.{u1, u2} α o f (Ordinal.enum.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (LT.lt.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Preorder.toLT.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (PartialOrder.toPreorder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (SemilatticeInf.toPartialOrder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Lattice.toSemilatticeInf.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (LinearOrder.toLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (linearOrderOut.{u2} o))))))) (isWellOrder_out_lt.{u2} o) i (Eq.mpr.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i (Ordinal.type.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (LT.lt.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Preorder.toLT.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (PartialOrder.toPreorder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (SemilatticeInf.toPartialOrder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Lattice.toSemilatticeInf.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (LinearOrder.toLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (linearOrderOut.{u2} o))))))) (isWellOrder_out_lt.{u2} o))) (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i o) ((fun [self : LT.{succ u2} Ordinal.{u2}] (ᾰ : Ordinal.{u2}) (ᾰ_1 : Ordinal.{u2}) (e_2 : Eq.{succ (succ u2)} Ordinal.{u2} ᾰ ᾰ_1) (ᾰ_2 : Ordinal.{u2}) (ᾰ_3 : Ordinal.{u2}) (e_3 : Eq.{succ (succ u2)} Ordinal.{u2} ᾰ_2 ᾰ_3) => congr.{succ (succ u2), 1} Ordinal.{u2} Prop (LT.lt.{succ u2} Ordinal.{u2} self ᾰ) (LT.lt.{succ u2} Ordinal.{u2} self ᾰ_1) ᾰ_2 ᾰ_3 (congr_arg.{succ (succ u2), succ (succ u2)} Ordinal.{u2} (Ordinal.{u2} -> Prop) ᾰ ᾰ_1 (LT.lt.{succ u2} Ordinal.{u2} self) e_2) e_3) (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i i (rfl.{succ (succ u2)} Ordinal.{u2} i) (Ordinal.type.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (LT.lt.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Preorder.toLT.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (PartialOrder.toPreorder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (SemilatticeInf.toPartialOrder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Lattice.toSemilatticeInf.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (LinearOrder.toLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (linearOrderOut.{u2} o))))))) (isWellOrder_out_lt.{u2} o)) o (Ordinal.type_lt.{u2} o)) hi))) (f i hi)
but is expected to have type
  forall {α : Type.{u1}} (o : Ordinal.{u2}) (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α) (i : Ordinal.{u2}) (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), Eq.{succ u1} α (Ordinal.familyOfBFamily.{u1, u2} α o f (Ordinal.enum.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15274 : WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15276 : WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) => LT.lt.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Preorder.toLT.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (PartialOrder.toPreorder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (SemilatticeInf.toPartialOrder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Lattice.toSemilatticeInf.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (DistribLattice.toLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (instDistribLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (linearOrderOut.{u2} o))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15274 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15276) (isWellOrder_out_lt.{u2} o) i (Eq.mpr.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i (Ordinal.type.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15274 : WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15276 : WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) => LT.lt.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Preorder.toLT.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (PartialOrder.toPreorder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (SemilatticeInf.toPartialOrder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Lattice.toSemilatticeInf.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (DistribLattice.toLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (instDistribLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (linearOrderOut.{u2} o))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15274 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15276) (isWellOrder_out_lt.{u2} o))) (Quot.lift.{succ (succ u2), 1} WellOrder.{u2} (fun (a : WellOrder.{u2}) (b : WellOrder.{u2}) => HasEquiv.Equiv.{succ (succ u2), 0} WellOrder.{u2} (instHasEquiv.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2}) a b) Prop (fun (a₁ : WellOrder.{u2}) => Quotient.lift.{succ (succ u2), 1} WellOrder.{u2} Prop Ordinal.isEquivalent.{u2} ((fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458 : WellOrder.{u2}) (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459 : WellOrder.{u2}) => Ordinal.isEquivalent.match_1.{u2, 1} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458.2525 : WellOrder.{u2}) => Prop) x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458 (fun (α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 : Type.{u2}) (r : α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 -> α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 -> Prop) (wo._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2538 : IsWellOrder.{u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 r) => Ordinal.isEquivalent.match_1.{u2, 1} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459.2543 : WellOrder.{u2}) => Prop) x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459 (fun (α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 : Type.{u2}) (s : α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 -> α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 -> Prop) (wo._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2556 : IsWellOrder.{u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 s) => Nonempty.{succ u2} (PrincipalSeg.{u2, u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 r s)))) a₁) (Quotient.lift₂.proof_1.{succ (succ u2), 1, succ (succ u2)} WellOrder.{u2} WellOrder.{u2} Prop Ordinal.isEquivalent.{u2} Ordinal.isEquivalent.{u2} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458 : WellOrder.{u2}) (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459 : WellOrder.{u2}) => Ordinal.isEquivalent.match_1.{u2, 1} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458.2525 : WellOrder.{u2}) => Prop) x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458 (fun (α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 : Type.{u2}) (r : α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 -> α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 -> Prop) (wo._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2538 : IsWellOrder.{u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 r) => Ordinal.isEquivalent.match_1.{u2, 1} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459.2543 : WellOrder.{u2}) => Prop) x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459 (fun (α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 : Type.{u2}) (s : α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 -> α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 -> Prop) (wo._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2556 : IsWellOrder.{u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 s) => Nonempty.{succ u2} (PrincipalSeg.{u2, u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 r s)))) Ordinal.instPartialOrderOrdinal.proof_2.{u2} a₁) o) (Quotient.lift₂.proof_2.{succ (succ u2), 1, succ (succ u2)} WellOrder.{u2} WellOrder.{u2} Prop Ordinal.isEquivalent.{u2} Ordinal.isEquivalent.{u2} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458 : WellOrder.{u2}) (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459 : WellOrder.{u2}) => Ordinal.isEquivalent.match_1.{u2, 1} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458.2525 : WellOrder.{u2}) => Prop) x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2458 (fun (α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 : Type.{u2}) (r : α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 -> α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 -> Prop) (wo._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2538 : IsWellOrder.{u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 r) => Ordinal.isEquivalent.match_1.{u2, 1} (fun (x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459.2543 : WellOrder.{u2}) => Prop) x._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2459 (fun (α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 : Type.{u2}) (s : α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 -> α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 -> Prop) (wo._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2556 : IsWellOrder.{u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 s) => Nonempty.{succ u2} (PrincipalSeg.{u2, u2} α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2537 α._@.Mathlib.SetTheory.Ordinal.Basic._hyg.2555 r s)))) Ordinal.instPartialOrderOrdinal.proof_2.{u2} o) i) ((fun {α : Type.{succ u2}} [self : LT.{succ u2} α] (a._@.Init.Prelude._hyg.2009 : α) (a_1._@.Init.Prelude._hyg.2009 : α) (e_a._@.Init.Prelude._hyg.2009 : Eq.{succ (succ u2)} α a._@.Init.Prelude._hyg.2009 a_1._@.Init.Prelude._hyg.2009) => Eq.rec.{0, succ (succ u2)} α a._@.Init.Prelude._hyg.2009 (fun (a_1._@.Init.Prelude._hyg.2009 : α) (e_a._@.Init.Prelude._hyg.2009 : Eq.{succ (succ u2)} α a._@.Init.Prelude._hyg.2009 a_1._@.Init.Prelude._hyg.2009) => forall (a._@.Init.Prelude._hyg.2011 : α) (a_1._@.Init.Prelude._hyg.2011 : α), (Eq.{succ (succ u2)} α a._@.Init.Prelude._hyg.2011 a_1._@.Init.Prelude._hyg.2011) -> (Eq.{1} Prop (LT.lt.{succ u2} α self a._@.Init.Prelude._hyg.2009 a._@.Init.Prelude._hyg.2011) (LT.lt.{succ u2} α self a_1._@.Init.Prelude._hyg.2009 a_1._@.Init.Prelude._hyg.2011))) (fun (a._@.Init.Prelude._hyg.2011 : α) (a_1._@.Init.Prelude._hyg.2011 : α) (e_a._@.Init.Prelude._hyg.2011 : Eq.{succ (succ u2)} α a._@.Init.Prelude._hyg.2011 a_1._@.Init.Prelude._hyg.2011) => Eq.rec.{0, succ (succ u2)} α a._@.Init.Prelude._hyg.2011 (fun (a_1._@.Init.Prelude._hyg.2011 : α) (e_a._@.Init.Prelude._hyg.2011 : Eq.{succ (succ u2)} α a._@.Init.Prelude._hyg.2011 a_1._@.Init.Prelude._hyg.2011) => Eq.{1} Prop (LT.lt.{succ u2} α self a._@.Init.Prelude._hyg.2009 a._@.Init.Prelude._hyg.2011) (LT.lt.{succ u2} α self a._@.Init.Prelude._hyg.2009 a_1._@.Init.Prelude._hyg.2011)) (Eq.refl.{1} Prop (LT.lt.{succ u2} α self a._@.Init.Prelude._hyg.2009 a._@.Init.Prelude._hyg.2011)) a_1._@.Init.Prelude._hyg.2011 e_a._@.Init.Prelude._hyg.2011) a_1._@.Init.Prelude._hyg.2009 e_a._@.Init.Prelude._hyg.2009) Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i i (Eq.refl.{succ (succ u2)} Ordinal.{u2} i) (Ordinal.type.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15274 : WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15276 : WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) => LT.lt.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Preorder.toLT.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (PartialOrder.toPreorder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (SemilatticeInf.toPartialOrder.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Lattice.toSemilatticeInf.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (DistribLattice.toLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (instDistribLattice.{u2} (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (linearOrderOut.{u2} o))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15274 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.15276) (isWellOrder_out_lt.{u2} o)) o (Ordinal.type_lt.{u2} o)) hi))) (f i hi)
Case conversion may be inaccurate. Consider using '#align ordinal.family_of_bfamily_enum Ordinal.familyOfBFamily_enumₓ'. -/
@[simp]
theorem familyOfBFamily_enum (o : Ordinal) (f : ∀ a < o, α) (i hi) :
    familyOfBFamily o f
        (enum (· < ·) i
          (by
            convert hi
            exact type_lt _)) =
      f i hi :=
  familyOfBFamily'_enum _ (type_lt o) f _ _
#align ordinal.family_of_bfamily_enum Ordinal.familyOfBFamily_enum

/- warning: ordinal.brange -> Ordinal.brange is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (o : Ordinal.{u2}), (forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o) -> α) -> (Set.{u1} α)
but is expected to have type
  forall {α : Type.{u1}} (o : Ordinal.{u2}), (forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α) -> (Set.{u1} α)
Case conversion may be inaccurate. Consider using '#align ordinal.brange Ordinal.brangeₓ'. -/
/-- The range of a family indexed by ordinals. -/
def brange (o : Ordinal) (f : ∀ a < o, α) : Set α :=
  { a | ∃ i hi, f i hi = a }
#align ordinal.brange Ordinal.brange

/- warning: ordinal.mem_brange -> Ordinal.mem_brange is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o) -> α} {a : α}, Iff (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) a (Ordinal.brange.{u1, u2} α o f)) (Exists.{succ (succ u2)} Ordinal.{u2} (fun (i : Ordinal.{u2}) => Exists.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i o) (fun (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i o) => Eq.{succ u1} α (f i hi) a)))
but is expected to have type
  forall {α : Type.{u1}} {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α} {a : α}, Iff (Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) a (Ordinal.brange.{u1, u2} α o f)) (Exists.{succ (succ u2)} Ordinal.{u2} (fun (i : Ordinal.{u2}) => Exists.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o) (fun (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o) => Eq.{succ u1} α (f i hi) a)))
Case conversion may be inaccurate. Consider using '#align ordinal.mem_brange Ordinal.mem_brangeₓ'. -/
theorem mem_brange {o : Ordinal} {f : ∀ a < o, α} {a} : a ∈ brange o f ↔ ∃ i hi, f i hi = a :=
  Iff.rfl
#align ordinal.mem_brange Ordinal.mem_brange

/- warning: ordinal.mem_brange_self -> Ordinal.mem_brange_self is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o) -> α) (i : Ordinal.{u2}) (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i o), Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) (f i hi) (Ordinal.brange.{u1, u2} α o f)
but is expected to have type
  forall {α : Type.{u1}} {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α) (i : Ordinal.{u2}) (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), Membership.mem.{u1, u1} α (Set.{u1} α) (Set.instMembershipSet.{u1} α) (f i hi) (Ordinal.brange.{u1, u2} α o f)
Case conversion may be inaccurate. Consider using '#align ordinal.mem_brange_self Ordinal.mem_brange_selfₓ'. -/
theorem mem_brange_self {o} (f : ∀ a < o, α) (i hi) : f i hi ∈ brange o f :=
  ⟨i, hi, rfl⟩
#align ordinal.mem_brange_self Ordinal.mem_brange_self

/- warning: ordinal.range_family_of_bfamily' -> Ordinal.range_familyOfBFamily' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> α), Eq.{succ u2} (Set.{u2} α) (Set.range.{u2, succ u1} α ι (Ordinal.familyOfBFamily'.{u1, u2} α ι r _inst_1 o ho f)) (Ordinal.brange.{u2, u1} α o f)
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u2} ι r] {o : Ordinal.{u2}} (ho : Eq.{succ (succ u2)} Ordinal.{u2} (Ordinal.type.{u2} ι r _inst_1) o) (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α), Eq.{succ u1} (Set.{u1} α) (Set.range.{u1, succ u2} α ι (Ordinal.familyOfBFamily'.{u2, u1} α ι r _inst_1 o ho f)) (Ordinal.brange.{u1, u2} α o f)
Case conversion may be inaccurate. Consider using '#align ordinal.range_family_of_bfamily' Ordinal.range_familyOfBFamily'ₓ'. -/
@[simp]
theorem range_familyOfBFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] {o}
    (ho : type r = o) (f : ∀ a < o, α) : range (familyOfBFamily' r ho f) = brange o f :=
  by
  refine' Set.ext fun a => ⟨_, _⟩
  · rintro ⟨b, rfl⟩
    apply mem_brange_self
  · rintro ⟨i, hi, rfl⟩
    exact ⟨_, family_of_bfamily'_enum _ _ _ _ _⟩
#align ordinal.range_family_of_bfamily' Ordinal.range_familyOfBFamily'

/- warning: ordinal.range_family_of_bfamily -> Ordinal.range_familyOfBFamily is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o) -> α), Eq.{succ u1} (Set.{u1} α) (Set.range.{u1, succ u2} α (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Ordinal.familyOfBFamily.{u1, u2} α o f)) (Ordinal.brange.{u1, u2} α o f)
but is expected to have type
  forall {α : Type.{u1}} {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> α), Eq.{succ u1} (Set.{u1} α) (Set.range.{u1, succ u2} α (WellOrder.α.{u2} (Quotient.out.{succ (succ u2)} WellOrder.{u2} Ordinal.isEquivalent.{u2} o)) (Ordinal.familyOfBFamily.{u1, u2} α o f)) (Ordinal.brange.{u1, u2} α o f)
Case conversion may be inaccurate. Consider using '#align ordinal.range_family_of_bfamily Ordinal.range_familyOfBFamilyₓ'. -/
@[simp]
theorem range_familyOfBFamily {o} (f : ∀ a < o, α) : range (familyOfBFamily o f) = brange o f :=
  range_familyOfBFamily' _ _ f
#align ordinal.range_family_of_bfamily Ordinal.range_familyOfBFamily

/- warning: ordinal.brange_bfamily_of_family' -> Ordinal.brange_bfamilyOfFamily' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] (f : ι -> α), Eq.{succ u2} (Set.{u2} α) (Ordinal.brange.{u2, u1} α (Ordinal.type.{u1} ι r _inst_1) (Ordinal.bfamilyOfFamily'.{u1, u2} α ι r _inst_1 f)) (Set.range.{u2, succ u1} α ι f)
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u2} ι r] (f : ι -> α), Eq.{succ u1} (Set.{u1} α) (Ordinal.brange.{u1, u2} α (Ordinal.type.{u2} ι r _inst_1) (Ordinal.bfamilyOfFamily'.{u2, u1} α ι r _inst_1 f)) (Set.range.{u1, succ u2} α ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.brange_bfamily_of_family' Ordinal.brange_bfamilyOfFamily'ₓ'. -/
@[simp]
theorem brange_bfamilyOfFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → α) :
    brange _ (bfamilyOfFamily' r f) = range f :=
  by
  refine' Set.ext fun a => ⟨_, _⟩
  · rintro ⟨i, hi, rfl⟩
    apply mem_range_self
  · rintro ⟨b, rfl⟩
    exact ⟨_, _, bfamily_of_family'_typein _ _ _⟩
#align ordinal.brange_bfamily_of_family' Ordinal.brange_bfamilyOfFamily'

/- warning: ordinal.brange_bfamily_of_family -> Ordinal.brange_bfamilyOfFamily is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {ι : Type.{u1}} (f : ι -> α), Eq.{succ u2} (Set.{u2} α) (Ordinal.brange.{u2, u1} α (Ordinal.type.{u1} ι (WellOrderingRel.{u1} ι) (WellOrderingRel.isWellOrder.{u1} ι)) (Ordinal.bfamilyOfFamily.{u1, u2} α ι f)) (Set.range.{u2, succ u1} α ι f)
but is expected to have type
  forall {α : Type.{u1}} {ι : Type.{u2}} (f : ι -> α), Eq.{succ u1} (Set.{u1} α) (Ordinal.brange.{u1, u2} α (Ordinal.type.{u2} ι (WellOrderingRel.{u2} ι) (WellOrderingRel.isWellOrder.{u2} ι)) (Ordinal.bfamilyOfFamily.{u2, u1} α ι f)) (Set.range.{u1, succ u2} α ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.brange_bfamily_of_family Ordinal.brange_bfamilyOfFamilyₓ'. -/
@[simp]
theorem brange_bfamilyOfFamily {ι : Type u} (f : ι → α) : brange _ (bfamilyOfFamily f) = range f :=
  brange_bfamilyOfFamily' _ _
#align ordinal.brange_bfamily_of_family Ordinal.brange_bfamilyOfFamily

#print Ordinal.brange_const /-
@[simp]
theorem brange_const {o : Ordinal} (ho : o ≠ 0) {c : α} : (brange o fun _ _ => c) = {c} :=
  by
  rw [← range_family_of_bfamily]
  exact @Set.range_const _ o.out.α (out_nonempty_iff_ne_zero.2 ho) c
#align ordinal.brange_const Ordinal.brange_const
-/

/- warning: ordinal.comp_bfamily_of_family' -> Ordinal.comp_bfamilyOfFamily' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {β : Type.{u3}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] (f : ι -> α) (g : α -> β), Eq.{max (succ (succ u1)) (succ u3)} (forall (i : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι r _inst_1)) -> β) (fun (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι r _inst_1)) => g (Ordinal.bfamilyOfFamily'.{u1, u2} α ι r _inst_1 f i hi)) (Ordinal.bfamilyOfFamily'.{u1, u3} β ι r _inst_1 (Function.comp.{succ u1, succ u2, succ u3} ι α β g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} {ι : Type.{u3}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u3} ι r] (f : ι -> α) (g : α -> β), Eq.{max (succ (succ u3)) (succ u2)} (forall (i : Ordinal.{u3}), (LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) i (Ordinal.type.{u3} ι r _inst_1)) -> β) (fun (i : Ordinal.{u3}) (hi : LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) i (Ordinal.type.{u3} ι r _inst_1)) => g (Ordinal.bfamilyOfFamily'.{u3, u1} α ι r _inst_1 f i hi)) (Ordinal.bfamilyOfFamily'.{u3, u2} β ι r _inst_1 (Function.comp.{succ u3, succ u1, succ u2} ι α β g f))
Case conversion may be inaccurate. Consider using '#align ordinal.comp_bfamily_of_family' Ordinal.comp_bfamilyOfFamily'ₓ'. -/
theorem comp_bfamilyOfFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → α)
    (g : α → β) : (fun i hi => g (bfamilyOfFamily' r f i hi)) = bfamilyOfFamily' r (g ∘ f) :=
  rfl
#align ordinal.comp_bfamily_of_family' Ordinal.comp_bfamilyOfFamily'

/- warning: ordinal.comp_bfamily_of_family -> Ordinal.comp_bfamilyOfFamily is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {β : Type.{u3}} {ι : Type.{u1}} (f : ι -> α) (g : α -> β), Eq.{max (succ (succ u1)) (succ u3)} (forall (i : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι (WellOrderingRel.{u1} ι) (WellOrderingRel.isWellOrder.{u1} ι))) -> β) (fun (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Ordinal.type.{u1} ι (WellOrderingRel.{u1} ι) (WellOrderingRel.isWellOrder.{u1} ι))) => g (Ordinal.bfamilyOfFamily.{u1, u2} α ι f i hi)) (Ordinal.bfamilyOfFamily.{u1, u3} β ι (Function.comp.{succ u1, succ u2, succ u3} ι α β g f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} {ι : Type.{u3}} (f : ι -> α) (g : α -> β), Eq.{max (succ (succ u3)) (succ u2)} (forall (i : Ordinal.{u3}), (LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) i (Ordinal.type.{u3} ι (WellOrderingRel.{u3} ι) (WellOrderingRel.isWellOrder.{u3} ι))) -> β) (fun (i : Ordinal.{u3}) (hi : LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) i (Ordinal.type.{u3} ι (WellOrderingRel.{u3} ι) (WellOrderingRel.isWellOrder.{u3} ι))) => g (Ordinal.bfamilyOfFamily.{u3, u1} α ι f i hi)) (Ordinal.bfamilyOfFamily.{u3, u2} β ι (Function.comp.{succ u3, succ u1, succ u2} ι α β g f))
Case conversion may be inaccurate. Consider using '#align ordinal.comp_bfamily_of_family Ordinal.comp_bfamilyOfFamilyₓ'. -/
theorem comp_bfamilyOfFamily {ι : Type u} (f : ι → α) (g : α → β) :
    (fun i hi => g (bfamilyOfFamily f i hi)) = bfamilyOfFamily (g ∘ f) :=
  rfl
#align ordinal.comp_bfamily_of_family Ordinal.comp_bfamilyOfFamily

/- warning: ordinal.comp_family_of_bfamily' -> Ordinal.comp_familyOfBFamily' is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u2}} {β : Type.{u3}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> α) (g : α -> β), Eq.{max (succ u1) (succ u3)} (ι -> β) (Function.comp.{succ u1, succ u2, succ u3} ι α β g (Ordinal.familyOfBFamily'.{u1, u2} α ι r _inst_1 o ho f)) (Ordinal.familyOfBFamily'.{u1, u3} β ι r _inst_1 o ho (fun (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => g (f i hi)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} {ι : Type.{u3}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u3} ι r] {o : Ordinal.{u3}} (ho : Eq.{succ (succ u3)} Ordinal.{u3} (Ordinal.type.{u3} ι r _inst_1) o) (f : forall (a : Ordinal.{u3}), (LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) a o) -> α) (g : α -> β), Eq.{max (succ u3) (succ u2)} (ι -> β) (Function.comp.{succ u3, succ u1, succ u2} ι α β g (Ordinal.familyOfBFamily'.{u3, u1} α ι r _inst_1 o ho f)) (Ordinal.familyOfBFamily'.{u3, u2} β ι r _inst_1 o ho (fun (i : Ordinal.{u3}) (hi : LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) i o) => g (f i hi)))
Case conversion may be inaccurate. Consider using '#align ordinal.comp_family_of_bfamily' Ordinal.comp_familyOfBFamily'ₓ'. -/
theorem comp_familyOfBFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] {o}
    (ho : type r = o) (f : ∀ a < o, α) (g : α → β) :
    g ∘ familyOfBFamily' r ho f = familyOfBFamily' r ho fun i hi => g (f i hi) :=
  rfl
#align ordinal.comp_family_of_bfamily' Ordinal.comp_familyOfBFamily'

/- warning: ordinal.comp_family_of_bfamily -> Ordinal.comp_familyOfBFamily is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} {o : Ordinal.{u3}} (f : forall (a : Ordinal.{u3}), (LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.partialOrder.{u3})) a o) -> α) (g : α -> β), Eq.{max (succ u3) (succ u2)} ((WellOrder.α.{u3} (Quotient.out.{succ (succ u3)} WellOrder.{u3} Ordinal.isEquivalent.{u3} o)) -> β) (Function.comp.{succ u3, succ u1, succ u2} (WellOrder.α.{u3} (Quotient.out.{succ (succ u3)} WellOrder.{u3} Ordinal.isEquivalent.{u3} o)) α β g (Ordinal.familyOfBFamily.{u1, u3} α o f)) (Ordinal.familyOfBFamily.{u2, u3} β o (fun (i : Ordinal.{u3}) (hi : LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.partialOrder.{u3})) i o) => g (f i hi)))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} {o : Ordinal.{u3}} (f : forall (a : Ordinal.{u3}), (LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) a o) -> α) (g : α -> β), Eq.{max (succ u2) (succ u3)} ((WellOrder.α.{u3} (Quotient.out.{succ (succ u3)} WellOrder.{u3} Ordinal.isEquivalent.{u3} o)) -> β) (Function.comp.{succ u3, succ u1, succ u2} (WellOrder.α.{u3} (Quotient.out.{succ (succ u3)} WellOrder.{u3} Ordinal.isEquivalent.{u3} o)) α β g (Ordinal.familyOfBFamily.{u1, u3} α o f)) (Ordinal.familyOfBFamily.{u2, u3} β o (fun (i : Ordinal.{u3}) (hi : LT.lt.{succ u3} Ordinal.{u3} (Preorder.toLT.{succ u3} Ordinal.{u3} (PartialOrder.toPreorder.{succ u3} Ordinal.{u3} Ordinal.instPartialOrderOrdinal.{u3})) i o) => g (f i hi)))
Case conversion may be inaccurate. Consider using '#align ordinal.comp_family_of_bfamily Ordinal.comp_familyOfBFamilyₓ'. -/
theorem comp_familyOfBFamily {o} (f : ∀ a < o, α) (g : α → β) :
    g ∘ familyOfBFamily o f = familyOfBFamily o fun i hi => g (f i hi) :=
  rfl
#align ordinal.comp_family_of_bfamily Ordinal.comp_familyOfBFamily

/-! ### Supremum of a family of ordinals -/


#print Ordinal.sup /-
/-- The supremum of a family of ordinals -/
def sup {ι : Type u} (f : ι → Ordinal.{max u v}) : Ordinal.{max u v} :=
  supᵢ f
#align ordinal.sup Ordinal.sup
-/

/- warning: ordinal.Sup_eq_sup -> Ordinal.supₛ_eq_sup is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (SupSet.supₛ.{succ (max u1 u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLattice.toHasSup.{succ (max u1 u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ (max u1 u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.conditionallyCompleteLinearOrderBot.{max u1 u2}))) (Set.range.{succ (max u1 u2), succ u1} Ordinal.{max u1 u2} ι f)) (Ordinal.sup.{u1, u2} ι f)
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (SupSet.supₛ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLattice.toSupSet.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{max u1 u2}))) (Set.range.{max (succ u1) (succ u2), succ u1} Ordinal.{max u1 u2} ι f)) (Ordinal.sup.{u1, u2} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.Sup_eq_sup Ordinal.supₛ_eq_supₓ'. -/
@[simp]
theorem supₛ_eq_sup {ι : Type u} (f : ι → Ordinal.{max u v}) : supₛ (Set.range f) = sup f :=
  rfl
#align ordinal.Sup_eq_sup Ordinal.supₛ_eq_sup

/- warning: ordinal.bdd_above_range -> Ordinal.bddAbove_range is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), BddAbove.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) (Set.range.{succ (max u1 u2), succ u1} Ordinal.{max u1 u2} ι f)
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), BddAbove.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) (Set.range.{max (succ u1) (succ u2), succ u1} Ordinal.{max u1 u2} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.bdd_above_range Ordinal.bddAbove_rangeₓ'. -/
/-- The range of an indexed ordinal function, whose outputs live in a higher universe than the
    inputs, is always bounded above. See `ordinal.lsub` for an explicit bound. -/
theorem bddAbove_range {ι : Type u} (f : ι → Ordinal.{max u v}) : BddAbove (Set.range f) :=
  ⟨(supᵢ (succ ∘ card ∘ f)).ord, by
    rintro a ⟨i, rfl⟩
    exact le_of_lt (Cardinal.lt_ord.2 ((lt_succ _).trans_le (le_csupᵢ (bdd_above_range _) _)))⟩
#align ordinal.bdd_above_range Ordinal.bddAbove_range

/- warning: ordinal.le_sup -> Ordinal.le_sup is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}) (i : ι), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) (Ordinal.sup.{u1, u2} ι f)
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}) (i : ι), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) (Ordinal.sup.{u1, u2} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.le_sup Ordinal.le_supₓ'. -/
theorem le_sup {ι} (f : ι → Ordinal) : ∀ i, f i ≤ sup f := fun i =>
  le_csupₛ (bddAbove_range f) (mem_range_self i)
#align ordinal.le_sup Ordinal.le_sup

/- warning: ordinal.sup_le_iff -> Ordinal.sup_le_iff is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.sup.{u1, u2} ι f) a) (forall (i : ι), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) a)
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.sup.{u1, u2} ι f) a) (forall (i : ι), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) a)
Case conversion may be inaccurate. Consider using '#align ordinal.sup_le_iff Ordinal.sup_le_iffₓ'. -/
theorem sup_le_iff {ι} {f : ι → Ordinal} {a} : sup f ≤ a ↔ ∀ i, f i ≤ a :=
  (csupₛ_le_iff' (bddAbove_range f)).trans (by simp)
#align ordinal.sup_le_iff Ordinal.sup_le_iff

/- warning: ordinal.sup_le -> Ordinal.sup_le is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : ι), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) a) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.sup.{u1, u2} ι f) a)
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : ι), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) a) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.sup.{u1, u2} ι f) a)
Case conversion may be inaccurate. Consider using '#align ordinal.sup_le Ordinal.sup_leₓ'. -/
theorem sup_le {ι} {f : ι → Ordinal} {a} : (∀ i, f i ≤ a) → sup f ≤ a :=
  sup_le_iff.2
#align ordinal.sup_le Ordinal.sup_le

/- warning: ordinal.lt_sup -> Ordinal.lt_sup is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.sup.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (f i)))
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.sup.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (f i)))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_sup Ordinal.lt_supₓ'. -/
theorem lt_sup {ι} {f : ι → Ordinal} {a} : a < sup f ↔ ∃ i, a < f i := by
  simpa only [not_forall, not_le] using not_congr (@sup_le_iff _ f a)
#align ordinal.lt_sup Ordinal.lt_sup

/- warning: ordinal.ne_sup_iff_lt_sup -> Ordinal.ne_sup_iff_lt_sup is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}}, Iff (forall (i : ι), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)) (forall (i : ι), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) (Ordinal.sup.{u1, u2} ι f))
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}}, Iff (forall (i : ι), Ne.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)) (forall (i : ι), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) (Ordinal.sup.{u1, u2} ι f))
Case conversion may be inaccurate. Consider using '#align ordinal.ne_sup_iff_lt_sup Ordinal.ne_sup_iff_lt_supₓ'. -/
theorem ne_sup_iff_lt_sup {ι} {f : ι → Ordinal} : (∀ i, f i ≠ sup f) ↔ ∀ i, f i < sup f :=
  ⟨fun hf _ => lt_of_le_of_ne (le_sup _ _) (hf _), fun hf _ => ne_of_lt (hf _)⟩
#align ordinal.ne_sup_iff_lt_sup Ordinal.ne_sup_iff_lt_sup

/- warning: ordinal.sup_not_succ_of_ne_sup -> Ordinal.sup_not_succ_of_ne_sup is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}}, (forall (i : ι), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)) -> (forall {a : Ordinal.{max u1 u2}}, (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.sup.{u1, u2} ι f)) -> (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} a) (Ordinal.sup.{u1, u2} ι f)))
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}}, (forall (i : ι), Ne.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)) -> (forall {a : Ordinal.{max u1 u2}}, (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.sup.{u1, u2} ι f)) -> (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} a) (Ordinal.sup.{u1, u2} ι f)))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_not_succ_of_ne_sup Ordinal.sup_not_succ_of_ne_supₓ'. -/
theorem sup_not_succ_of_ne_sup {ι} {f : ι → Ordinal} (hf : ∀ i, f i ≠ sup f) {a} (hao : a < sup f) :
    succ a < sup f := by
  by_contra' hoa
  exact
    hao.not_le (sup_le fun i => le_of_lt_succ <| (lt_of_le_of_ne (le_sup _ _) (hf i)).trans_le hoa)
#align ordinal.sup_not_succ_of_ne_sup Ordinal.sup_not_succ_of_ne_sup

#print Ordinal.sup_eq_zero_iff /-
@[simp]
theorem sup_eq_zero_iff {ι} {f : ι → Ordinal} : sup f = 0 ↔ ∀ i, f i = 0 :=
  by
  refine'
    ⟨fun h i => _, fun h =>
      le_antisymm (sup_le fun i => Ordinal.le_zero.2 (h i)) (Ordinal.zero_le _)⟩
  rw [← Ordinal.le_zero, ← h]
  exact le_sup f i
#align ordinal.sup_eq_zero_iff Ordinal.sup_eq_zero_iff
-/

#print Ordinal.IsNormal.sup /-
theorem IsNormal.sup {f} (H : IsNormal f) {ι} (g : ι → Ordinal) [Nonempty ι] :
    f (sup g) = sup (f ∘ g) :=
  eq_of_forall_ge_iff fun a => by
    rw [sup_le_iff, comp, H.le_set' Set.univ Set.univ_nonempty g] <;> simp [sup_le_iff]
#align ordinal.is_normal.sup Ordinal.IsNormal.sup
-/

/- warning: ordinal.sup_empty -> Ordinal.sup_empty is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : IsEmpty.{succ u1} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2})))
but is expected to have type
  forall {ι : Type.{u2}} [_inst_1 : IsEmpty.{succ u2} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.sup.{u2, u1} ι f) (OfNat.ofNat.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} 0 (Zero.toOfNat0.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instZeroOrdinal.{max u1 u2}))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_empty Ordinal.sup_emptyₓ'. -/
@[simp]
theorem sup_empty {ι} [IsEmpty ι] (f : ι → Ordinal) : sup f = 0 :=
  csupᵢ_of_empty f
#align ordinal.sup_empty Ordinal.sup_empty

/- warning: ordinal.sup_const -> Ordinal.sup_const is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [hι : Nonempty.{succ u1} ι] (o : Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι (fun (_x : ι) => o)) o
but is expected to have type
  forall {ι : Type.{u2}} [hι : Nonempty.{succ u2} ι] (o : Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.sup.{u2, u1} ι (fun (_x : ι) => o)) o
Case conversion may be inaccurate. Consider using '#align ordinal.sup_const Ordinal.sup_constₓ'. -/
@[simp]
theorem sup_const {ι} [hι : Nonempty ι] (o : Ordinal) : (sup fun _ : ι => o) = o :=
  csupᵢ_const
#align ordinal.sup_const Ordinal.sup_const

/- warning: ordinal.sup_unique -> Ordinal.sup_unique is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [_inst_1 : Unique.{succ u1} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (f (Inhabited.default.{succ u1} ι (Unique.inhabited.{succ u1} ι _inst_1)))
but is expected to have type
  forall {ι : Type.{u2}} [_inst_1 : Unique.{succ u2} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.sup.{u2, u1} ι f) (f (Inhabited.default.{succ u2} ι (Unique.instInhabited.{succ u2} ι _inst_1)))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_unique Ordinal.sup_uniqueₓ'. -/
@[simp]
theorem sup_unique {ι} [Unique ι] (f : ι → Ordinal) : sup f = f default :=
  csupᵢ_unique
#align ordinal.sup_unique Ordinal.sup_unique

/- warning: ordinal.sup_le_of_range_subset -> Ordinal.sup_le_of_range_subset is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {ι' : Type.{u2}} {f : ι -> Ordinal.{max u1 u2 u3}} {g : ι' -> Ordinal.{max u1 u2 u3}}, (HasSubset.Subset.{succ (max u1 u2 u3)} (Set.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Set.hasSubset.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Set.range.{succ (max u1 u2 u3), succ u1} Ordinal.{max u1 u2 u3} ι f) (Set.range.{succ (max u1 u2 u3), succ u2} Ordinal.{max u1 u2 u3} ι' g)) -> (LE.le.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} Ordinal.partialOrder.{max u1 u2 u3})) (Ordinal.sup.{u1, max u2 u3} ι f) (Ordinal.sup.{u2, max u1 u3} ι' g))
but is expected to have type
  forall {ι : Type.{u1}} {ι' : Type.{u2}} {f : ι -> Ordinal.{max (max u1 u2) u3}} {g : ι' -> Ordinal.{max (max u1 u2) u3}}, (HasSubset.Subset.{succ (max (max u1 u2) u3)} (Set.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Set.instHasSubsetSet.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Set.range.{succ (max (max u1 u2) u3), succ u1} Ordinal.{max (max u1 u2) u3} ι f) (Set.range.{succ (max (max u1 u2) u3), succ u2} Ordinal.{max (max u1 u2) u3} ι' g)) -> (LE.le.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} Ordinal.instPartialOrderOrdinal.{max (max u1 u2) u3})) (Ordinal.sup.{u1, max u2 u3} ι f) (Ordinal.sup.{u2, max u1 u3} ι' g))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_le_of_range_subset Ordinal.sup_le_of_range_subsetₓ'. -/
theorem sup_le_of_range_subset {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f ⊆ Set.range g) : sup.{u, max v w} f ≤ sup.{v, max u w} g :=
  sup_le fun i =>
    match h (mem_range_self i) with
    | ⟨j, hj⟩ => hj ▸ le_sup _ _
#align ordinal.sup_le_of_range_subset Ordinal.sup_le_of_range_subset

#print Ordinal.sup_eq_of_range_eq /-
theorem sup_eq_of_range_eq {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f = Set.range g) : sup.{u, max v w} f = sup.{v, max u w} g :=
  (sup_le_of_range_subset h.le).antisymm (sup_le_of_range_subset.{v, u, w} h.ge)
#align ordinal.sup_eq_of_range_eq Ordinal.sup_eq_of_range_eq
-/

/- warning: ordinal.sup_sum -> Ordinal.sup_sum is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (f : (Sum.{u1, u2} α β) -> Ordinal.{max (max u1 u2) u3}), Eq.{succ (succ (max (max u1 u2) u3))} Ordinal.{max (max u1 u2) u3} (Ordinal.sup.{max u1 u2, u3} (Sum.{u1, u2} α β) f) (LinearOrder.max.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} Ordinal.linearOrder.{max (max u1 u2) u3} (Ordinal.sup.{u1, max u2 u3} α (fun (a : α) => f (Sum.inl.{u1, u2} α β a))) (Ordinal.sup.{u2, max u1 u3} β (fun (b : β) => f (Sum.inr.{u1, u2} α β b))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} (f : (Sum.{u1, u2} α β) -> Ordinal.{max (max u1 u2) u3}), Eq.{max (max (succ (succ u1)) (succ (succ u2))) (succ (succ u3))} Ordinal.{max (max u1 u2) u3} (Ordinal.sup.{max u1 u2, u3} (Sum.{u1, u2} α β) f) (Max.max.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (LinearOrder.toMax.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} Ordinal.instLinearOrderOrdinal.{max (max u1 u2) u3}) (Ordinal.sup.{u1, max u2 u3} α (fun (a : α) => f (Sum.inl.{u1, u2} α β a))) (Ordinal.sup.{u2, max u1 u3} β (fun (b : β) => f (Sum.inr.{u1, u2} α β b))))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_sum Ordinal.sup_sumₓ'. -/
@[simp]
theorem sup_sum {α : Type u} {β : Type v} (f : Sum α β → Ordinal) :
    sup.{max u v, w} f =
      max (sup.{u, max v w} fun a => f (Sum.inl a)) (sup.{v, max u w} fun b => f (Sum.inr b)) :=
  by
  apply (sup_le_iff.2 _).antisymm (max_le_iff.2 ⟨_, _⟩)
  · rintro (i | i)
    · exact le_max_of_le_left (le_sup _ i)
    · exact le_max_of_le_right (le_sup _ i)
  all_goals
    apply sup_le_of_range_subset.{_, max u v, w}
    rintro i ⟨a, rfl⟩
    apply mem_range_self
#align ordinal.sup_sum Ordinal.sup_sum

/- warning: ordinal.unbounded_range_of_sup_ge -> Ordinal.unbounded_range_of_sup_ge is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u1}} (r : α -> α -> Prop) [_inst_1 : IsWellOrder.{u1} α r] (f : β -> α), (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.type.{u1} α r _inst_1) (Ordinal.sup.{u1, u1} β (Function.comp.{succ u1, succ u1, succ (succ u1)} β α Ordinal.{u1} (Ordinal.typein.{u1} α r _inst_1) f))) -> (Set.Unbounded.{u1} α r (Set.range.{u1, succ u1} α β f))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u1}} (r : α -> α -> Prop) [_inst_1 : IsWellOrder.{u1} α r] (f : β -> α), (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.type.{u1} α r _inst_1) (Ordinal.sup.{u1, u1} β (Function.comp.{succ u1, succ u1, succ (succ u1)} β α Ordinal.{u1} (Ordinal.typein.{u1} α r _inst_1) f))) -> (Set.Unbounded.{u1} α r (Set.range.{u1, succ u1} α β f))
Case conversion may be inaccurate. Consider using '#align ordinal.unbounded_range_of_sup_ge Ordinal.unbounded_range_of_sup_geₓ'. -/
theorem unbounded_range_of_sup_ge {α β : Type u} (r : α → α → Prop) [IsWellOrder α r] (f : β → α)
    (h : type r ≤ sup.{u, u} (typein r ∘ f)) : Unbounded r (range f) :=
  (not_bounded_iff _).1 fun ⟨x, hx⟩ =>
    not_lt_of_le h <|
      lt_of_le_of_lt
        (sup_le fun y => le_of_lt <| (typein_lt_typein r).2 <| hx _ <| mem_range_self y)
        (typein_lt_type r x)
#align ordinal.unbounded_range_of_sup_ge Ordinal.unbounded_range_of_sup_ge

/- warning: ordinal.le_sup_shrink_equiv -> Ordinal.le_sup_shrink_equiv is a dubious translation:
lean 3 declaration is
  forall {s : Set.{succ u1} Ordinal.{u1}} (hs : Small.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s)) (a : Ordinal.{u1}), (Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) a s) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Ordinal.sup.{u1, u1} (Shrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs) (fun (x : Shrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs) => Subtype.val.{succ (succ u1)} Ordinal.{u1} (fun (x : Ordinal.{u1}) => Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) x s) (coeFn.{succ (succ u1), succ (succ u1)} (Equiv.{succ u1, succ (succ u1)} (Shrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs) (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s)) (fun (_x : Equiv.{succ u1, succ (succ u1)} (Shrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs) (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s)) => (Shrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs) -> (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s)) (Equiv.hasCoeToFun.{succ u1, succ (succ u1)} (Shrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs) (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s)) (Equiv.symm.{succ (succ u1), succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) (Shrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs) (equivShrink.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s) hs)) x))))
but is expected to have type
  forall {s : Set.{succ u1} Ordinal.{u1}} (hs : Small.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s)) (a : Ordinal.{u1}), (Membership.mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.instMembershipSet.{succ u1} Ordinal.{u1}) a s) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Ordinal.sup.{u1, u1} (Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) (fun (x : Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) => Subtype.val.{succ (succ u1)} Ordinal.{u1} (fun (x : Ordinal.{u1}) => Membership.mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.instMembershipSet.{succ u1} Ordinal.{u1}) x s) (FunLike.coe.{succ (succ u1), succ u1, succ (succ u1)} (Equiv.{succ u1, succ (succ u1)} (Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) (Set.Elem.{succ u1} Ordinal.{u1} s)) (Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) (fun (_x : Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) => (fun (x._@.Mathlib.Logic.Equiv.Defs._hyg.805 : Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) => Set.Elem.{succ u1} Ordinal.{u1} s) _x) (Equiv.instFunLikeEquiv.{succ u1, succ (succ u1)} (Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) (Set.Elem.{succ u1} Ordinal.{u1} s)) (Equiv.symm.{succ (succ u1), succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) (Shrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs) (equivShrink.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s) hs)) x))))
Case conversion may be inaccurate. Consider using '#align ordinal.le_sup_shrink_equiv Ordinal.le_sup_shrink_equivₓ'. -/
theorem le_sup_shrink_equiv {s : Set Ordinal.{u}} (hs : Small.{u} s) (a) (ha : a ∈ s) :
    a ≤ sup.{u, u} fun x => ((@equivShrink s hs).symm x).val :=
  by
  convert le_sup.{u, u} _ ((@equivShrink s hs) ⟨a, ha⟩)
  rw [symm_apply_apply]
#align ordinal.le_sup_shrink_equiv Ordinal.le_sup_shrink_equiv

/- warning: ordinal.small_Iio -> Ordinal.small_Iio is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Small.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) (Set.Iio.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) o))
but is expected to have type
  forall (o : Ordinal.{u1}), Small.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} (Set.Iio.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) o))
Case conversion may be inaccurate. Consider using '#align ordinal.small_Iio Ordinal.small_Iioₓ'. -/
instance small_Iio (o : Ordinal.{u}) : Small.{u} (Set.Iio o) :=
  let f : o.out.α → Set.Iio o := fun x => ⟨typein (· < ·) x, typein_lt_self x⟩
  let hf : Surjective f := fun b =>
    ⟨enum (· < ·) b.val
        (by
          rw [type_lt]
          exact b.prop),
      Subtype.ext (typein_enum _ _)⟩
  small_of_surjective hf
#align ordinal.small_Iio Ordinal.small_Iio

/- warning: ordinal.small_Iic -> Ordinal.small_Iic is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Small.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) (Set.Iic.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) o))
but is expected to have type
  forall (o : Ordinal.{u1}), Small.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} (Set.Iic.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) o))
Case conversion may be inaccurate. Consider using '#align ordinal.small_Iic Ordinal.small_Iicₓ'. -/
instance small_Iic (o : Ordinal.{u}) : Small.{u} (Set.Iic o) :=
  by
  rw [← Iio_succ]
  infer_instance
#align ordinal.small_Iic Ordinal.small_Iic

/- warning: ordinal.bdd_above_iff_small -> Ordinal.bddAbove_iff_small is a dubious translation:
lean 3 declaration is
  forall {s : Set.{succ u1} Ordinal.{u1}}, Iff (BddAbove.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) s) (Small.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s))
but is expected to have type
  forall {s : Set.{succ u1} Ordinal.{u1}}, Iff (BddAbove.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) s) (Small.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s))
Case conversion may be inaccurate. Consider using '#align ordinal.bdd_above_iff_small Ordinal.bddAbove_iff_smallₓ'. -/
theorem bddAbove_iff_small {s : Set Ordinal.{u}} : BddAbove s ↔ Small.{u} s :=
  ⟨fun ⟨a, h⟩ => small_subset <| show s ⊆ Iic a from fun x hx => h hx, fun h =>
    ⟨sup.{u, u} fun x => ((@equivShrink s h).symm x).val, le_sup_shrink_equiv h⟩⟩
#align ordinal.bdd_above_iff_small Ordinal.bddAbove_iff_small

/- warning: ordinal.bdd_above_of_small -> Ordinal.bddAbove_of_small is a dubious translation:
lean 3 declaration is
  forall (s : Set.{succ u1} Ordinal.{u1}) [h : Small.{u1, succ u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) s)], BddAbove.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) s
but is expected to have type
  forall (s : Set.{succ u1} Ordinal.{u1}) [h : Small.{u1, succ u1} (Set.Elem.{succ u1} Ordinal.{u1} s)], BddAbove.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) s
Case conversion may be inaccurate. Consider using '#align ordinal.bdd_above_of_small Ordinal.bddAbove_of_smallₓ'. -/
theorem bddAbove_of_small (s : Set Ordinal.{u}) [h : Small.{u} s] : BddAbove s :=
  bddAbove_iff_small.2 h
#align ordinal.bdd_above_of_small Ordinal.bddAbove_of_small

#print Ordinal.sup_eq_supₛ /-
theorem sup_eq_supₛ {s : Set Ordinal.{u}} (hs : Small.{u} s) :
    (sup.{u, u} fun x => (@equivShrink s hs).symm x) = supₛ s :=
  let hs' := bddAbove_iff_small.2 hs
  ((csupₛ_le_iff' hs').2 (le_sup_shrink_equiv hs)).antisymm'
    (sup_le fun x => le_csupₛ hs' (Subtype.mem _))
#align ordinal.sup_eq_Sup Ordinal.sup_eq_supₛ
-/

/- warning: ordinal.Sup_ord -> Ordinal.supₛ_ord is a dubious translation:
lean 3 declaration is
  forall {s : Set.{succ u1} Cardinal.{u1}}, (BddAbove.{succ u1} Cardinal.{u1} (PartialOrder.toPreorder.{succ u1} Cardinal.{u1} Cardinal.partialOrder.{u1}) s) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Cardinal.ord.{u1} (SupSet.supₛ.{succ u1} Cardinal.{u1} (ConditionallyCompleteLattice.toHasSup.{succ u1} Cardinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Cardinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Cardinal.{u1} Cardinal.conditionallyCompleteLinearOrderBot.{u1}))) s)) (SupSet.supₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toHasSup.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.conditionallyCompleteLinearOrderBot.{u1}))) (Set.image.{succ u1, succ u1} Cardinal.{u1} Ordinal.{u1} Cardinal.ord.{u1} s)))
but is expected to have type
  forall {s : Set.{succ u1} Cardinal.{u1}}, (BddAbove.{succ u1} Cardinal.{u1} (PartialOrder.toPreorder.{succ u1} Cardinal.{u1} Cardinal.partialOrder.{u1}) s) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Cardinal.ord.{u1} (SupSet.supₛ.{succ u1} Cardinal.{u1} (ConditionallyCompleteLattice.toSupSet.{succ u1} Cardinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Cardinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Cardinal.{u1} Cardinal.instConditionallyCompleteLinearOrderBotCardinal.{u1}))) s)) (SupSet.supₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toSupSet.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{u1}))) (Set.image.{succ u1, succ u1} Cardinal.{u1} Ordinal.{u1} Cardinal.ord.{u1} s)))
Case conversion may be inaccurate. Consider using '#align ordinal.Sup_ord Ordinal.supₛ_ordₓ'. -/
theorem supₛ_ord {s : Set Cardinal.{u}} (hs : BddAbove s) : (supₛ s).ord = supₛ (ord '' s) :=
  eq_of_forall_ge_iff fun a =>
    by
    rw [csupₛ_le_iff'
        (bdd_above_iff_small.2 (@small_image _ _ _ s (Cardinal.bddAbove_iff_small.1 hs))),
      ord_le, csupₛ_le_iff' hs]
    simp [ord_le]
#align ordinal.Sup_ord Ordinal.supₛ_ord

/- warning: ordinal.supr_ord -> Ordinal.supᵢ_ord is a dubious translation:
lean 3 declaration is
  forall {ι : Sort.{u1}} {f : ι -> Cardinal.{u2}}, (BddAbove.{succ u2} Cardinal.{u2} (PartialOrder.toPreorder.{succ u2} Cardinal.{u2} Cardinal.partialOrder.{u2}) (Set.range.{succ u2, u1} Cardinal.{u2} ι f)) -> (Eq.{succ (succ u2)} Ordinal.{u2} (Cardinal.ord.{u2} (supᵢ.{succ u2, u1} Cardinal.{u2} (ConditionallyCompleteLattice.toHasSup.{succ u2} Cardinal.{u2} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u2} Cardinal.{u2} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u2} Cardinal.{u2} Cardinal.conditionallyCompleteLinearOrderBot.{u2}))) ι f)) (supᵢ.{succ u2, u1} Ordinal.{u2} (ConditionallyCompleteLattice.toHasSup.{succ u2} Ordinal.{u2} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u2} Ordinal.{u2} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u2} Ordinal.{u2} Ordinal.conditionallyCompleteLinearOrderBot.{u2}))) ι (fun (i : ι) => Cardinal.ord.{u2} (f i))))
but is expected to have type
  forall {ι : Sort.{u2}} {f : ι -> Cardinal.{u1}}, (BddAbove.{succ u1} Cardinal.{u1} (PartialOrder.toPreorder.{succ u1} Cardinal.{u1} Cardinal.partialOrder.{u1}) (Set.range.{succ u1, u2} Cardinal.{u1} ι f)) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Cardinal.ord.{u1} (supᵢ.{succ u1, u2} Cardinal.{u1} (ConditionallyCompleteLattice.toSupSet.{succ u1} Cardinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Cardinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Cardinal.{u1} Cardinal.instConditionallyCompleteLinearOrderBotCardinal.{u1}))) ι f)) (supᵢ.{succ u1, u2} Ordinal.{u1} (ConditionallyCompleteLattice.toSupSet.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{u1}))) ι (fun (i : ι) => Cardinal.ord.{u1} (f i))))
Case conversion may be inaccurate. Consider using '#align ordinal.supr_ord Ordinal.supᵢ_ordₓ'. -/
theorem supᵢ_ord {ι} {f : ι → Cardinal} (hf : BddAbove (range f)) : (supᵢ f).ord = ⨆ i, (f i).ord :=
  by
  unfold supᵢ
  convert Sup_ord hf
  rw [range_comp]
#align ordinal.supr_ord Ordinal.supᵢ_ord

private theorem sup_le_sup {ι ι' : Type u} (r : ι → ι → Prop) (r' : ι' → ι' → Prop)
    [IsWellOrder ι r] [IsWellOrder ι' r'] {o} (ho : type r = o) (ho' : type r' = o)
    (f : ∀ a < o, Ordinal) : sup (familyOfBFamily' r ho f) ≤ sup (familyOfBFamily' r' ho' f) :=
  sup_le fun i =>
    by
    cases'
      typein_surj r'
        (by
          rw [ho', ← ho]
          exact typein_lt_type r i) with
      j hj
    simp_rw [family_of_bfamily', ← hj]
    apply le_sup
#align ordinal.sup_le_sup ordinal.sup_le_sup

/- warning: ordinal.sup_eq_sup -> Ordinal.sup_eq_sup is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {ι' : Type.{u1}} (r : ι -> ι -> Prop) (r' : ι' -> ι' -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] [_inst_2 : IsWellOrder.{u1} ι' r'] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (ho' : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι' r' _inst_2) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, succ (max u1 u2)} Ordinal.{max u1 u2} ι r _inst_1 o ho f)) (Ordinal.sup.{u1, u2} ι' (Ordinal.familyOfBFamily'.{u1, succ (max u1 u2)} Ordinal.{max u1 u2} ι' r' _inst_2 o ho' f))
but is expected to have type
  forall {ι : Type.{u1}} {ι' : Type.{u1}} (r : ι -> ι -> Prop) (r' : ι' -> ι' -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] [_inst_2 : IsWellOrder.{u1} ι' r'] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (ho' : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι' r' _inst_2) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, max (succ u2) (succ u1)} Ordinal.{max u1 u2} ι r _inst_1 o ho f)) (Ordinal.sup.{u1, u2} ι' (Ordinal.familyOfBFamily'.{u1, max (succ u2) (succ u1)} Ordinal.{max u1 u2} ι' r' _inst_2 o ho' f))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_eq_sup Ordinal.sup_eq_supₓ'. -/
theorem sup_eq_sup {ι ι' : Type u} (r : ι → ι → Prop) (r' : ι' → ι' → Prop) [IsWellOrder ι r]
    [IsWellOrder ι' r'] {o : Ordinal.{u}} (ho : type r = o) (ho' : type r' = o)
    (f : ∀ a < o, Ordinal.{max u v}) :
    sup (familyOfBFamily' r ho f) = sup (familyOfBFamily' r' ho' f) :=
  sup_eq_of_range_eq.{u, u, v} (by simp)
#align ordinal.sup_eq_sup Ordinal.sup_eq_sup

/- warning: ordinal.bsup -> Ordinal.bsup is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) -> Ordinal.{max u1 u2}
but is expected to have type
  forall (o : Ordinal.{u1}), (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}) -> Ordinal.{max u1 u2}
Case conversion may be inaccurate. Consider using '#align ordinal.bsup Ordinal.bsupₓ'. -/
/-- The supremum of a family of ordinals indexed by the set of ordinals less than some
    `o : ordinal.{u}`. This is a special case of `sup` over the family provided by
    `family_of_bfamily`. -/
def bsup (o : Ordinal.{u}) (f : ∀ a < o, Ordinal.{max u v}) : Ordinal.{max u v} :=
  sup (familyOfBFamily o f)
#align ordinal.bsup Ordinal.bsup

/- warning: ordinal.sup_eq_bsup -> Ordinal.sup_eq_bsup is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Ordinal.familyOfBFamily.{succ (max u1 u2), u1} Ordinal.{max u1 u2} o f)) (Ordinal.bsup.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Ordinal.familyOfBFamily.{max (succ u1) (succ u2), u1} Ordinal.{max u1 u2} o f)) (Ordinal.bsup.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.sup_eq_bsup Ordinal.sup_eq_bsupₓ'. -/
@[simp]
theorem sup_eq_bsup {o} (f : ∀ a < o, Ordinal) : sup (familyOfBFamily o f) = bsup o f :=
  rfl
#align ordinal.sup_eq_bsup Ordinal.sup_eq_bsup

/- warning: ordinal.sup_eq_bsup' -> Ordinal.sup_eq_bsup' is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, succ (max u1 u2)} Ordinal.{max u1 u2} ι r _inst_1 o ho f)) (Ordinal.bsup.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u1}} {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, max (succ u2) (succ u1)} Ordinal.{max u1 u2} ι r _inst_1 o ho f)) (Ordinal.bsup.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.sup_eq_bsup' Ordinal.sup_eq_bsup'ₓ'. -/
@[simp]
theorem sup_eq_bsup' {o ι} (r : ι → ι → Prop) [IsWellOrder ι r] (ho : type r = o) (f) :
    sup (familyOfBFamily' r ho f) = bsup o f :=
  sup_eq_sup r _ ho _ f
#align ordinal.sup_eq_bsup' Ordinal.sup_eq_bsup'

/- warning: ordinal.Sup_eq_bsup -> Ordinal.supₛ_eq_bsup is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (SupSet.supₛ.{succ (max u1 u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLattice.toHasSup.{succ (max u1 u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ (max u1 u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.conditionallyCompleteLinearOrderBot.{max u1 u2}))) (Ordinal.brange.{succ (max u1 u2), u1} Ordinal.{max u1 u2} o f)) (Ordinal.bsup.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (SupSet.supₛ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLattice.toSupSet.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{max u1 u2}))) (Ordinal.brange.{max (succ u1) (succ u2), u1} Ordinal.{max u1 u2} o f)) (Ordinal.bsup.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.Sup_eq_bsup Ordinal.supₛ_eq_bsupₓ'. -/
@[simp]
theorem supₛ_eq_bsup {o} (f : ∀ a < o, Ordinal) : supₛ (brange o f) = bsup o f :=
  by
  congr
  rw [range_family_of_bfamily]
#align ordinal.Sup_eq_bsup Ordinal.supₛ_eq_bsup

#print Ordinal.bsup_eq_sup' /-
@[simp]
theorem bsup_eq_sup' {ι} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → Ordinal) :
    bsup _ (bfamilyOfFamily' r f) = sup f := by
  simp only [← sup_eq_bsup' r, enum_typein, family_of_bfamily', bfamily_of_family']
#align ordinal.bsup_eq_sup' Ordinal.bsup_eq_sup'
-/

#print Ordinal.bsup_eq_bsup /-
theorem bsup_eq_bsup {ι : Type u} (r r' : ι → ι → Prop) [IsWellOrder ι r] [IsWellOrder ι r']
    (f : ι → Ordinal) : bsup _ (bfamilyOfFamily' r f) = bsup _ (bfamilyOfFamily' r' f) := by
  rw [bsup_eq_sup', bsup_eq_sup']
#align ordinal.bsup_eq_bsup Ordinal.bsup_eq_bsup
-/

#print Ordinal.bsup_eq_sup /-
@[simp]
theorem bsup_eq_sup {ι} (f : ι → Ordinal) : bsup _ (bfamilyOfFamily f) = sup f :=
  bsup_eq_sup' _ f
#align ordinal.bsup_eq_sup Ordinal.bsup_eq_sup
-/

/- warning: ordinal.bsup_congr -> Ordinal.bsup_congr is a dubious translation:
lean 3 declaration is
  forall {o₁ : Ordinal.{u1}} {o₂ : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o₁) -> Ordinal.{max u1 u2}) (ho : Eq.{succ (succ u1)} Ordinal.{u1} o₁ o₂), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o₁ f) (Ordinal.bsup.{u1, u2} o₂ (fun (a : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o₂) => f a (LT.lt.trans_eq.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) a o₂ o₁ h (Eq.symm.{succ (succ u1)} Ordinal.{u1} o₁ o₂ ho))))
but is expected to have type
  forall {o₁ : Ordinal.{u1}} {o₂ : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o₁) -> Ordinal.{max u1 u2}) (ho : Eq.{succ (succ u1)} Ordinal.{u1} o₁ o₂), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o₁ f) (Ordinal.bsup.{u1, u2} o₂ (fun (a : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o₂) => f a (LT.lt.trans_eq.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) a o₂ o₁ h (Eq.symm.{succ (succ u1)} Ordinal.{u1} o₁ o₂ ho))))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_congr Ordinal.bsup_congrₓ'. -/
@[congr]
theorem bsup_congr {o₁ o₂ : Ordinal} (f : ∀ a < o₁, Ordinal) (ho : o₁ = o₂) :
    bsup o₁ f = bsup o₂ fun a h => f a (h.trans_eq ho.symm) := by subst ho
#align ordinal.bsup_congr Ordinal.bsup_congr

/- warning: ordinal.bsup_le_iff -> Ordinal.bsup_le_iff is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.bsup.{u1, u2} o f) a) (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) a)
but is expected to have type
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.bsup.{u1, u2} o f) a) (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i h) a)
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_le_iff Ordinal.bsup_le_iffₓ'. -/
theorem bsup_le_iff {o f a} : bsup.{u, v} o f ≤ a ↔ ∀ i h, f i h ≤ a :=
  sup_le_iff.trans
    ⟨fun h i hi => by
      rw [← family_of_bfamily_enum o f]
      exact h _, fun h i => h _ _⟩
#align ordinal.bsup_le_iff Ordinal.bsup_le_iff

/- warning: ordinal.bsup_le -> Ordinal.bsup_le is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (b : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) a) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.bsup.{u1, u2} o f) a)
but is expected to have type
  forall {o : Ordinal.{u1}} {f : forall (b : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) b o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i h) a) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.bsup.{u1, u2} o f) a)
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_le Ordinal.bsup_leₓ'. -/
theorem bsup_le {o : Ordinal} {f : ∀ b < o, Ordinal} {a} :
    (∀ i h, f i h ≤ a) → bsup.{u, v} o f ≤ a :=
  bsup_le_iff.2
#align ordinal.bsup_le Ordinal.bsup_le

/- warning: ordinal.le_bsup -> Ordinal.le_bsup is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) (Ordinal.bsup.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u1 u2}) (i : Ordinal.{u2}) (h : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i h) (Ordinal.bsup.{u2, u1} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.le_bsup Ordinal.le_bsupₓ'. -/
theorem le_bsup {o} (f : ∀ a < o, Ordinal) (i h) : f i h ≤ bsup o f :=
  bsup_le_iff.1 le_rfl _ _
#align ordinal.le_bsup Ordinal.le_bsup

/- warning: ordinal.lt_bsup -> Ordinal.lt_bsup is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) {a : Ordinal.{max u1 u2}}, Iff (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.bsup.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (f i hi))))
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}) {a : Ordinal.{max u1 u2}}, Iff (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.bsup.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) => LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (f i hi))))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_bsup Ordinal.lt_bsupₓ'. -/
theorem lt_bsup {o} (f : ∀ a < o, Ordinal) {a} : a < bsup o f ↔ ∃ i hi, a < f i hi := by
  simpa only [not_forall, not_le] using not_congr (@bsup_le_iff _ f a)
#align ordinal.lt_bsup Ordinal.lt_bsup

/- warning: ordinal.is_normal.bsup -> Ordinal.IsNormal.bsup is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{max u1 u2} -> Ordinal.{max u1 u3}}, (Ordinal.IsNormal.{max u1 u2, max u1 u3} f) -> (forall {o : Ordinal.{u1}} (g : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), (Ne.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (Eq.{succ (succ (max u1 u3))} Ordinal.{max u1 u3} (f (Ordinal.bsup.{u1, u2} o g)) (Ordinal.bsup.{u1, u3} o (fun (a : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) => f (g a h)))))
but is expected to have type
  forall {f : Ordinal.{max u1 u2} -> Ordinal.{max u1 u3}}, (Ordinal.IsNormal.{max u1 u2, max u1 u3} f) -> (forall {o : Ordinal.{u1}} (g : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), (Ne.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (Eq.{max (succ (succ u1)) (succ (succ u3))} Ordinal.{max u1 u3} (f (Ordinal.bsup.{u1, u2} o g)) (Ordinal.bsup.{u1, u3} o (fun (a : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) => f (g a h)))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.bsup Ordinal.IsNormal.bsupₓ'. -/
theorem IsNormal.bsup {f} (H : IsNormal f) {o} :
    ∀ (g : ∀ a < o, Ordinal) (h : o ≠ 0), f (bsup o g) = bsup o fun a h => f (g a h) :=
  inductionOn o fun α r _ g h => by
    skip
    haveI := type_ne_zero_iff_nonempty.1 h
    rw [← sup_eq_bsup' r, H.sup, ← sup_eq_bsup' r] <;> rfl
#align ordinal.is_normal.bsup Ordinal.IsNormal.bsup

/- warning: ordinal.lt_bsup_of_ne_bsup -> Ordinal.lt_bsup_of_ne_bsup is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}}, Iff (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i h) (Ordinal.bsup.{u1, u2} o f)) (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) (Ordinal.bsup.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}}, Iff (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), Ne.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i h) (Ordinal.bsup.{u1, u2} o f)) (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i h) (Ordinal.bsup.{u1, u2} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_bsup_of_ne_bsup Ordinal.lt_bsup_of_ne_bsupₓ'. -/
theorem lt_bsup_of_ne_bsup {o : Ordinal} {f : ∀ a < o, Ordinal} :
    (∀ i h, f i h ≠ o.bsup f) ↔ ∀ i h, f i h < o.bsup f :=
  ⟨fun hf _ _ => lt_of_le_of_ne (le_bsup _ _ _) (hf _ _), fun hf _ _ => ne_of_lt (hf _ _)⟩
#align ordinal.lt_bsup_of_ne_bsup Ordinal.lt_bsup_of_ne_bsup

/- warning: ordinal.bsup_not_succ_of_ne_bsup -> Ordinal.bsup_not_succ_of_ne_bsup is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}}, (forall {i : Ordinal.{u1}} (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i h) (Ordinal.bsup.{u1, u2} o f)) -> (forall (a : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.bsup.{u1, u2} o f)) -> (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} a) (Ordinal.bsup.{u1, u2} o f)))
but is expected to have type
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}}, (forall {i : Ordinal.{u1}} (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), Ne.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i h) (Ordinal.bsup.{u1, u2} o f)) -> (forall (a : Ordinal.{max u1 u2}), (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.bsup.{u1, u2} o f)) -> (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} a) (Ordinal.bsup.{u1, u2} o f)))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_not_succ_of_ne_bsup Ordinal.bsup_not_succ_of_ne_bsupₓ'. -/
theorem bsup_not_succ_of_ne_bsup {o} {f : ∀ a < o, Ordinal}
    (hf : ∀ {i : Ordinal} (h : i < o), f i h ≠ o.bsup f) (a) : a < bsup o f → succ a < bsup o f :=
  by
  rw [← sup_eq_bsup] at *
  exact sup_not_succ_of_ne_sup fun i => hf _
#align ordinal.bsup_not_succ_of_ne_bsup Ordinal.bsup_not_succ_of_ne_bsup

/- warning: ordinal.bsup_eq_zero_iff -> Ordinal.bsup_eq_zero_iff is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}}, Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2})))) (forall (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i hi) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2}))))
but is expected to have type
  forall {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u1 u2}}, Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.bsup.{u2, u1} o f) (OfNat.ofNat.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} 0 (Zero.toOfNat0.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instZeroOrdinal.{max u1 u2}))) (forall (i : Ordinal.{u2}) (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i hi) (OfNat.ofNat.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} 0 (Zero.toOfNat0.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instZeroOrdinal.{max u1 u2})))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_eq_zero_iff Ordinal.bsup_eq_zero_iffₓ'. -/
@[simp]
theorem bsup_eq_zero_iff {o} {f : ∀ a < o, Ordinal} : bsup o f = 0 ↔ ∀ i hi, f i hi = 0 :=
  by
  refine'
    ⟨fun h i hi => _, fun h =>
      le_antisymm (bsup_le fun i hi => Ordinal.le_zero.2 (h i hi)) (Ordinal.zero_le _)⟩
  rw [← Ordinal.le_zero, ← h]
  exact le_bsup f i hi
#align ordinal.bsup_eq_zero_iff Ordinal.bsup_eq_zero_iff

/- warning: ordinal.lt_bsup_of_limit -> Ordinal.lt_bsup_of_limit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}}, (forall {a : Ordinal.{u1}} {a' : Ordinal.{u1}} (ha : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) (ha' : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a' o), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a a') -> (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f a ha) (f a' ha'))) -> (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) o)) -> (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) (Ordinal.bsup.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u2 u1}}, (forall {a : Ordinal.{u2}} {a' : Ordinal.{u2}} (ha : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) (ha' : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a' o), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a a') -> (LT.lt.{succ (max u2 u1)} Ordinal.{max u2 u1} (Preorder.toLT.{succ (max u2 u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{succ (max u2 u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) (f a ha) (f a' ha'))) -> (forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} a) o)) -> (forall (i : Ordinal.{u2}) (h : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), LT.lt.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (Preorder.toLT.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) (f i h) (Ordinal.bsup.{u2, u1} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_bsup_of_limit Ordinal.lt_bsup_of_limitₓ'. -/
theorem lt_bsup_of_limit {o : Ordinal} {f : ∀ a < o, Ordinal}
    (hf : ∀ {a a'} (ha : a < o) (ha' : a' < o), a < a' → f a ha < f a' ha')
    (ho : ∀ a < o, succ a < o) (i h) : f i h < bsup o f :=
  (hf _ _ <| lt_succ i).trans_le (le_bsup f (succ i) <| ho _ h)
#align ordinal.lt_bsup_of_limit Ordinal.lt_bsup_of_limit

/- warning: ordinal.bsup_succ_of_mono -> Ordinal.bsup_succ_of_mono is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) -> Ordinal.{max u1 u2}}, (forall {i : Ordinal.{u1}} {j : Ordinal.{u1}} (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) (hj : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) j (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)), (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i j) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i hi) (f j hj))) -> (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o) f) (f o (Order.lt_succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} Ordinal.noMaxOrder.{u1} o)))
but is expected to have type
  forall {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o)) -> Ordinal.{max u2 u1}}, (forall {i : Ordinal.{u2}} {j : Ordinal.{u2}} (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o)) (hj : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) j (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o)), (LE.le.{succ u2} Ordinal.{u2} (Preorder.toLE.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i j) -> (LE.le.{succ (max u2 u1)} Ordinal.{max u2 u1} (Preorder.toLE.{succ (max u2 u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{succ (max u2 u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) (f i hi) (f j hj))) -> (Eq.{max (succ (succ u2)) (succ (succ u1))} Ordinal.{max u2 u1} (Ordinal.bsup.{u2, u1} (Order.succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} o) f) (f o (Order.lt_succ.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u2} Ordinal.instNoMaxOrderOrdinalToLTToPreorderInstPartialOrderOrdinal.{u2} o)))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_succ_of_mono Ordinal.bsup_succ_of_monoₓ'. -/
theorem bsup_succ_of_mono {o : Ordinal} {f : ∀ a < succ o, Ordinal}
    (hf : ∀ {i j} (hi hj), i ≤ j → f i hi ≤ f j hj) : bsup _ f = f o (lt_succ o) :=
  le_antisymm (bsup_le fun i hi => hf _ _ <| le_of_lt_succ hi) (le_bsup _ _ _)
#align ordinal.bsup_succ_of_mono Ordinal.bsup_succ_of_mono

/- warning: ordinal.bsup_zero -> Ordinal.bsup_zero is a dubious translation:
lean 3 declaration is
  forall (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) f) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2})))
but is expected to have type
  forall (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2}))) -> Ordinal.{max u2 u1}), Eq.{max (succ (succ u2)) (succ (succ u1))} Ordinal.{max u2 u1} (Ordinal.bsup.{u2, u1} (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2})) f) (OfNat.ofNat.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} 0 (Zero.toOfNat0.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instZeroOrdinal.{max u2 u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_zero Ordinal.bsup_zeroₓ'. -/
@[simp]
theorem bsup_zero (f : ∀ a < (0 : Ordinal), Ordinal) : bsup 0 f = 0 :=
  bsup_eq_zero_iff.2 fun i hi => (Ordinal.not_lt_zero i hi).elim
#align ordinal.bsup_zero Ordinal.bsup_zero

#print Ordinal.bsup_const /-
theorem bsup_const {o : Ordinal} (ho : o ≠ 0) (a : Ordinal) : (bsup o fun _ _ => a) = a :=
  le_antisymm (bsup_le fun _ _ => le_rfl) (le_bsup _ 0 (Ordinal.pos_iff_ne_zero.2 ho))
#align ordinal.bsup_const Ordinal.bsup_const
-/

/- warning: ordinal.bsup_one -> Ordinal.bsup_one is a dubious translation:
lean 3 declaration is
  forall (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1})))) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))) f) (f (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) (zero_lt_one.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1} Ordinal.hasOne.{u1} Ordinal.partialOrder.{u1} Ordinal.zeroLeOneClass.{u1} Ordinal.NeZero.one.{u1}))
but is expected to have type
  forall (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a (OfNat.ofNat.{succ u2} Ordinal.{u2} 1 (One.toOfNat1.{succ u2} Ordinal.{u2} Ordinal.instOneOrdinal.{u2}))) -> Ordinal.{max u2 u1}), Eq.{max (succ (succ u2)) (succ (succ u1))} Ordinal.{max u2 u1} (Ordinal.bsup.{u2, u1} (OfNat.ofNat.{succ u2} Ordinal.{u2} 1 (One.toOfNat1.{succ u2} Ordinal.{u2} Ordinal.instOneOrdinal.{u2})) f) (f (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2})) (zero_lt_one.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2} Ordinal.instOneOrdinal.{u2} Ordinal.instPartialOrderOrdinal.{u2} Ordinal.instZeroLEOneClassOrdinalInstZeroOrdinalInstOneOrdinalToLEToPreorderInstPartialOrderOrdinal.{u2} Ordinal.NeZero.one.{u2}))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_one Ordinal.bsup_oneₓ'. -/
@[simp]
theorem bsup_one (f : ∀ a < (1 : Ordinal), Ordinal) : bsup 1 f = f 0 zero_lt_one := by
  simp_rw [← sup_eq_bsup, sup_unique, family_of_bfamily, family_of_bfamily', typein_one_out]
#align ordinal.bsup_one Ordinal.bsup_one

/- warning: ordinal.bsup_le_of_brange_subset -> Ordinal.bsup_le_of_brange_subset is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2 u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o') -> Ordinal.{max u1 u2 u3}}, (HasSubset.Subset.{succ (max u1 u2 u3)} (Set.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Set.hasSubset.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Ordinal.brange.{succ (max u1 u2 u3), u1} Ordinal.{max u1 u2 u3} o f) (Ordinal.brange.{succ (max u1 u2 u3), u2} Ordinal.{max u1 u2 u3} o' g)) -> (LE.le.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} Ordinal.partialOrder.{max u1 u2 u3})) (Ordinal.bsup.{u1, max u2 u3} o f) (Ordinal.bsup.{u2, max u1 u3} o' g))
but is expected to have type
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max (max u1 u2) u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o') -> Ordinal.{max (max u1 u2) u3}}, (HasSubset.Subset.{succ (max (max u1 u2) u3)} (Set.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Set.instHasSubsetSet.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Ordinal.brange.{succ (max (max u1 u2) u3), u1} Ordinal.{max (max u1 u2) u3} o f) (Ordinal.brange.{succ (max (max u1 u2) u3), u2} Ordinal.{max (max u1 u2) u3} o' g)) -> (LE.le.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} Ordinal.instPartialOrderOrdinal.{max (max u1 u2) u3})) (Ordinal.bsup.{u1, max u2 u3} o f) (Ordinal.bsup.{u2, max u1 u3} o' g))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_le_of_brange_subset Ordinal.bsup_le_of_brange_subsetₓ'. -/
theorem bsup_le_of_brange_subset {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f ⊆ brange o' g) : bsup.{u, max v w} o f ≤ bsup.{v, max u w} o' g :=
  bsup_le fun i hi => by
    obtain ⟨j, hj, hj'⟩ := h ⟨i, hi, rfl⟩
    rw [← hj']
    apply le_bsup
#align ordinal.bsup_le_of_brange_subset Ordinal.bsup_le_of_brange_subset

/- warning: ordinal.bsup_eq_of_brange_eq -> Ordinal.bsup_eq_of_brange_eq is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2 u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o') -> Ordinal.{max u1 u2 u3}}, (Eq.{succ (succ (max u1 u2 u3))} (Set.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Ordinal.brange.{succ (max u1 u2 u3), u1} Ordinal.{max u1 u2 u3} o f) (Ordinal.brange.{succ (max u1 u2 u3), u2} Ordinal.{max u1 u2 u3} o' g)) -> (Eq.{succ (succ (max u1 u2 u3))} Ordinal.{max u1 u2 u3} (Ordinal.bsup.{u1, max u2 u3} o f) (Ordinal.bsup.{u2, max u1 u3} o' g))
but is expected to have type
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max (max u1 u2) u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o') -> Ordinal.{max (max u1 u2) u3}}, (Eq.{succ (succ (max (max u1 u2) u3))} (Set.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Ordinal.brange.{succ (max (max u1 u2) u3), u1} Ordinal.{max (max u1 u2) u3} o f) (Ordinal.brange.{succ (max (max u1 u2) u3), u2} Ordinal.{max (max u1 u2) u3} o' g)) -> (Eq.{max (max (succ (succ u1)) (succ (succ u2))) (succ (succ u3))} Ordinal.{max u1 u2 u3} (Ordinal.bsup.{u1, max u2 u3} o f) (Ordinal.bsup.{u2, max u1 u3} o' g))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_eq_of_brange_eq Ordinal.bsup_eq_of_brange_eqₓ'. -/
theorem bsup_eq_of_brange_eq {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f = brange o' g) : bsup.{u, max v w} o f = bsup.{v, max u w} o' g :=
  (bsup_le_of_brange_subset h.le).antisymm (bsup_le_of_brange_subset.{v, u, w} h.ge)
#align ordinal.bsup_eq_of_brange_eq Ordinal.bsup_eq_of_brange_eq

#print Ordinal.lsub /-
/-- The least strict upper bound of a family of ordinals. -/
def lsub {ι} (f : ι → Ordinal) : Ordinal :=
  sup (succ ∘ f)
#align ordinal.lsub Ordinal.lsub
-/

/- warning: ordinal.sup_eq_lsub -> Ordinal.sup_eq_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι (Function.comp.{succ u1, succ (succ (max u1 u2)), succ (succ (max u1 u2))} ι Ordinal.{max u1 u2} Ordinal.{max u1 u2} (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2}) f)) (Ordinal.lsub.{u1, u2} ι f)
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι (Function.comp.{succ u1, succ (max (succ u2) (succ u1)), max (succ (succ u2)) (succ (succ u1))} ι Ordinal.{max u1 u2} Ordinal.{max u1 u2} (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u2 u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u2 u1}) f)) (Ordinal.lsub.{u1, u2} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.sup_eq_lsub Ordinal.sup_eq_lsubₓ'. -/
@[simp]
theorem sup_eq_lsub {ι} (f : ι → Ordinal) : sup (succ ∘ f) = lsub f :=
  rfl
#align ordinal.sup_eq_lsub Ordinal.sup_eq_lsub

/- warning: ordinal.lsub_le_iff -> Ordinal.lsub_le_iff is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.lsub.{u1, u2} ι f) a) (forall (i : ι), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) a)
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u2 u1}}, Iff (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.lsub.{u1, u2} ι f) a) (forall (i : ι), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) a)
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_le_iff Ordinal.lsub_le_iffₓ'. -/
theorem lsub_le_iff {ι} {f : ι → Ordinal} {a} : lsub f ≤ a ↔ ∀ i, f i < a :=
  by
  convert sup_le_iff
  simp only [succ_le_iff]
#align ordinal.lsub_le_iff Ordinal.lsub_le_iff

/- warning: ordinal.lsub_le -> Ordinal.lsub_le is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : ι), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) a) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.lsub.{u1, u2} ι f) a)
but is expected to have type
  forall {ι : Type.{u2}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : ι), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) a) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.lsub.{u2, u1} ι f) a)
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_le Ordinal.lsub_leₓ'. -/
theorem lsub_le {ι} {f : ι → Ordinal} {a} : (∀ i, f i < a) → lsub f ≤ a :=
  lsub_le_iff.2
#align ordinal.lsub_le Ordinal.lsub_le

/- warning: ordinal.lt_lsub -> Ordinal.lt_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}) (i : ι), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) (Ordinal.lsub.{u1, u2} ι f)
but is expected to have type
  forall {ι : Type.{u2}} (f : ι -> Ordinal.{max u1 u2}) (i : ι), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) (Ordinal.lsub.{u2, u1} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.lt_lsub Ordinal.lt_lsubₓ'. -/
theorem lt_lsub {ι} (f : ι → Ordinal) (i) : f i < lsub f :=
  succ_le_iff.1 (le_sup _ i)
#align ordinal.lt_lsub Ordinal.lt_lsub

/- warning: ordinal.lt_lsub_iff -> Ordinal.lt_lsub_iff is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.lsub.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (f i)))
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u2 u1}}, Iff (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.lsub.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => LE.le.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (f i)))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_lsub_iff Ordinal.lt_lsub_iffₓ'. -/
theorem lt_lsub_iff {ι} {f : ι → Ordinal} {a} : a < lsub f ↔ ∃ i, a ≤ f i := by
  simpa only [not_forall, not_lt, not_le] using not_congr (@lsub_le_iff _ f a)
#align ordinal.lt_lsub_iff Ordinal.lt_lsub_iff

/- warning: ordinal.sup_le_lsub -> Ordinal.sup_le_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.sup_le_lsub Ordinal.sup_le_lsubₓ'. -/
theorem sup_le_lsub {ι} (f : ι → Ordinal) : sup f ≤ lsub f :=
  sup_le fun i => (lt_lsub f i).le
#align ordinal.sup_le_lsub Ordinal.sup_le_lsub

/- warning: ordinal.lsub_le_sup_succ -> Ordinal.lsub_le_sup_succ is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.lsub.{u1, u2} ι f) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.sup.{u1, u2} ι f))
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.lsub.{u1, u2} ι f) (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f))
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_le_sup_succ Ordinal.lsub_le_sup_succₓ'. -/
theorem lsub_le_sup_succ {ι} (f : ι → Ordinal) : lsub f ≤ succ (sup f) :=
  lsub_le fun i => lt_succ_iff.2 (le_sup f i)
#align ordinal.lsub_le_sup_succ Ordinal.lsub_le_sup_succ

/- warning: ordinal.sup_eq_lsub_or_sup_succ_eq_lsub -> Ordinal.sup_eq_lsub_or_sup_succ_eq_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Or (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)) (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.sup.{u1, u2} ι f)) (Ordinal.lsub.{u1, u2} ι f))
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Or (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)) (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f)) (Ordinal.lsub.{u1, u2} ι f))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_eq_lsub_or_sup_succ_eq_lsub Ordinal.sup_eq_lsub_or_sup_succ_eq_lsubₓ'. -/
theorem sup_eq_lsub_or_sup_succ_eq_lsub {ι} (f : ι → Ordinal) :
    sup f = lsub f ∨ succ (sup f) = lsub f :=
  by
  cases eq_or_lt_of_le (sup_le_lsub f)
  · exact Or.inl h
  · exact Or.inr ((succ_le_of_lt h).antisymm (lsub_le_sup_succ f))
#align ordinal.sup_eq_lsub_or_sup_succ_eq_lsub Ordinal.sup_eq_lsub_or_sup_succ_eq_lsub

/- warning: ordinal.sup_succ_le_lsub -> Ordinal.sup_succ_le_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.sup.{u1, u2} ι f)) (Ordinal.lsub.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)))
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f)) (Ordinal.lsub.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_succ_le_lsub Ordinal.sup_succ_le_lsubₓ'. -/
theorem sup_succ_le_lsub {ι} (f : ι → Ordinal) : succ (sup f) ≤ lsub f ↔ ∃ i, f i = sup f :=
  by
  refine' ⟨fun h => _, _⟩
  · by_contra' hf
    exact (succ_le_iff.1 h).Ne ((sup_le_lsub f).antisymm (lsub_le (ne_sup_iff_lt_sup.1 hf)))
  rintro ⟨_, hf⟩
  rw [succ_le_iff, ← hf]
  exact lt_lsub _ _
#align ordinal.sup_succ_le_lsub Ordinal.sup_succ_le_lsub

/- warning: ordinal.sup_succ_eq_lsub -> Ordinal.sup_succ_eq_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.sup.{u1, u2} ι f)) (Ordinal.lsub.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)))
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f)) (Ordinal.lsub.{u1, u2} ι f)) (Exists.{succ u1} ι (fun (i : ι) => Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i) (Ordinal.sup.{u1, u2} ι f)))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_succ_eq_lsub Ordinal.sup_succ_eq_lsubₓ'. -/
theorem sup_succ_eq_lsub {ι} (f : ι → Ordinal) : succ (sup f) = lsub f ↔ ∃ i, f i = sup f :=
  (lsub_le_sup_succ f).le_iff_eq.symm.trans (sup_succ_le_lsub f)
#align ordinal.sup_succ_eq_lsub Ordinal.sup_succ_eq_lsub

/- warning: ordinal.sup_eq_lsub_iff_succ -> Ordinal.sup_eq_lsub_iff_succ is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)) (forall (a : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.lsub.{u1, u2} ι f)) -> (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} a) (Ordinal.lsub.{u1, u2} ι f)))
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)) (forall (a : Ordinal.{max u2 u1}), (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.lsub.{u1, u2} ι f)) -> (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} a) (Ordinal.lsub.{u1, u2} ι f)))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_eq_lsub_iff_succ Ordinal.sup_eq_lsub_iff_succₓ'. -/
theorem sup_eq_lsub_iff_succ {ι} (f : ι → Ordinal) :
    sup f = lsub f ↔ ∀ a < lsub f, succ a < lsub f :=
  by
  refine' ⟨fun h => _, fun hf => le_antisymm (sup_le_lsub f) (lsub_le fun i => _)⟩
  · rw [← h]
    exact fun a => sup_not_succ_of_ne_sup fun i => (lsub_le_iff.1 (le_of_eq h.symm) i).Ne
  by_contra' hle
  have heq := (sup_succ_eq_lsub f).2 ⟨i, le_antisymm (le_sup _ _) hle⟩
  have :=
    hf _
      (by
        rw [← HEq]
        exact lt_succ (sup f))
  rw [HEq] at this
  exact this.false
#align ordinal.sup_eq_lsub_iff_succ Ordinal.sup_eq_lsub_iff_succ

/- warning: ordinal.sup_eq_lsub_iff_lt_sup -> Ordinal.sup_eq_lsub_iff_lt_sup is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)) (forall (i : ι), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i) (Ordinal.sup.{u1, u2} ι f))
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.sup.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)) (forall (i : ι), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i) (Ordinal.sup.{u1, u2} ι f))
Case conversion may be inaccurate. Consider using '#align ordinal.sup_eq_lsub_iff_lt_sup Ordinal.sup_eq_lsub_iff_lt_supₓ'. -/
theorem sup_eq_lsub_iff_lt_sup {ι} (f : ι → Ordinal) : sup f = lsub f ↔ ∀ i, f i < sup f :=
  ⟨fun h i => by
    rw [h]
    apply lt_lsub, fun h => le_antisymm (sup_le_lsub f) (lsub_le h)⟩
#align ordinal.sup_eq_lsub_iff_lt_sup Ordinal.sup_eq_lsub_iff_lt_sup

/- warning: ordinal.lsub_empty -> Ordinal.lsub_empty is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [h : IsEmpty.{succ u1} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u1, u2} ι f) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2})))
but is expected to have type
  forall {ι : Type.{u2}} [h : IsEmpty.{succ u2} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u2, u1} ι f) (OfNat.ofNat.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} 0 (Zero.toOfNat0.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instZeroOrdinal.{max u1 u2}))
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_empty Ordinal.lsub_emptyₓ'. -/
@[simp]
theorem lsub_empty {ι} [h : IsEmpty ι] (f : ι → Ordinal) : lsub f = 0 :=
  by
  rw [← Ordinal.le_zero, lsub_le_iff]
  exact h.elim
#align ordinal.lsub_empty Ordinal.lsub_empty

/- warning: ordinal.lsub_pos -> Ordinal.lsub_pos is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [h : Nonempty.{succ u1} ι] (f : ι -> Ordinal.{max u1 u2}), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2}))) (Ordinal.lsub.{u1, u2} ι f)
but is expected to have type
  forall {ι : Type.{u1}} [h : Nonempty.{succ u1} ι] (f : ι -> Ordinal.{max u1 u2}), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (OfNat.ofNat.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} 0 (Zero.toOfNat0.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instZeroOrdinal.{max u1 u2})) (Ordinal.lsub.{u1, u2} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_pos Ordinal.lsub_posₓ'. -/
theorem lsub_pos {ι} [h : Nonempty ι] (f : ι → Ordinal) : 0 < lsub f :=
  h.elim fun i => (Ordinal.zero_le _).trans_lt (lt_lsub f i)
#align ordinal.lsub_pos Ordinal.lsub_pos

#print Ordinal.lsub_eq_zero_iff /-
@[simp]
theorem lsub_eq_zero_iff {ι} {f : ι → Ordinal} : lsub f = 0 ↔ IsEmpty ι :=
  by
  refine' ⟨fun h => ⟨fun i => _⟩, fun h => @lsub_empty _ h _⟩
  have := @lsub_pos _ ⟨i⟩ f
  rw [h] at this
  exact this.false
#align ordinal.lsub_eq_zero_iff Ordinal.lsub_eq_zero_iff
-/

/- warning: ordinal.lsub_const -> Ordinal.lsub_const is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [hι : Nonempty.{succ u1} ι] (o : Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u1, u2} ι (fun (_x : ι) => o)) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} o)
but is expected to have type
  forall {ι : Type.{u2}} [hι : Nonempty.{succ u2} ι] (o : Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u2, u1} ι (fun (_x : ι) => o)) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} o)
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_const Ordinal.lsub_constₓ'. -/
@[simp]
theorem lsub_const {ι} [hι : Nonempty ι] (o : Ordinal) : (lsub fun _ : ι => o) = succ o :=
  sup_const (succ o)
#align ordinal.lsub_const Ordinal.lsub_const

/- warning: ordinal.lsub_unique -> Ordinal.lsub_unique is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} [hι : Unique.{succ u1} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u1, u2} ι f) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (f (Inhabited.default.{succ u1} ι (Unique.inhabited.{succ u1} ι hι))))
but is expected to have type
  forall {ι : Type.{u2}} [hι : Unique.{succ u2} ι] (f : ι -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u2, u1} ι f) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (f (Inhabited.default.{succ u2} ι (Unique.instInhabited.{succ u2} ι hι))))
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_unique Ordinal.lsub_uniqueₓ'. -/
@[simp]
theorem lsub_unique {ι} [hι : Unique ι] (f : ι → Ordinal) : lsub f = succ (f default) :=
  sup_unique _
#align ordinal.lsub_unique Ordinal.lsub_unique

/- warning: ordinal.lsub_le_of_range_subset -> Ordinal.lsub_le_of_range_subset is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {ι' : Type.{u2}} {f : ι -> Ordinal.{max u1 u2 u3}} {g : ι' -> Ordinal.{max u1 u2 u3}}, (HasSubset.Subset.{succ (max u1 u2 u3)} (Set.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Set.hasSubset.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Set.range.{succ (max u1 u2 u3), succ u1} Ordinal.{max u1 u2 u3} ι f) (Set.range.{succ (max u1 u2 u3), succ u2} Ordinal.{max u1 u2 u3} ι' g)) -> (LE.le.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} Ordinal.partialOrder.{max u1 u2 u3})) (Ordinal.lsub.{u1, max u2 u3} ι f) (Ordinal.lsub.{u2, max u1 u3} ι' g))
but is expected to have type
  forall {ι : Type.{u1}} {ι' : Type.{u2}} {f : ι -> Ordinal.{max (max u1 u2) u3}} {g : ι' -> Ordinal.{max (max u1 u2) u3}}, (HasSubset.Subset.{succ (max (max u1 u2) u3)} (Set.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Set.instHasSubsetSet.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Set.range.{succ (max (max u1 u2) u3), succ u1} Ordinal.{max (max u1 u2) u3} ι f) (Set.range.{succ (max (max u1 u2) u3), succ u2} Ordinal.{max (max u1 u2) u3} ι' g)) -> (LE.le.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max (max u2 u3) u1} (Preorder.toLE.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max (max u2 u3) u1} (PartialOrder.toPreorder.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max (max u2 u3) u1} Ordinal.instPartialOrderOrdinal.{max (max u1 u2) u3})) (Ordinal.lsub.{u1, max u2 u3} ι f) (Ordinal.lsub.{u2, max u1 u3} ι' g))
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_le_of_range_subset Ordinal.lsub_le_of_range_subsetₓ'. -/
theorem lsub_le_of_range_subset {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f ⊆ Set.range g) : lsub.{u, max v w} f ≤ lsub.{v, max u w} g :=
  sup_le_of_range_subset (by convert Set.image_subset _ h <;> apply Set.range_comp)
#align ordinal.lsub_le_of_range_subset Ordinal.lsub_le_of_range_subset

#print Ordinal.lsub_eq_of_range_eq /-
theorem lsub_eq_of_range_eq {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f = Set.range g) : lsub.{u, max v w} f = lsub.{v, max u w} g :=
  (lsub_le_of_range_subset h.le).antisymm (lsub_le_of_range_subset.{v, u, w} h.ge)
#align ordinal.lsub_eq_of_range_eq Ordinal.lsub_eq_of_range_eq
-/

/- warning: ordinal.lsub_sum -> Ordinal.lsub_sum is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} (f : (Sum.{u1, u2} α β) -> Ordinal.{max (max u1 u2) u3}), Eq.{succ (succ (max (max u1 u2) u3))} Ordinal.{max (max u1 u2) u3} (Ordinal.lsub.{max u1 u2, u3} (Sum.{u1, u2} α β) f) (LinearOrder.max.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} Ordinal.linearOrder.{max (max u1 u2) u3} (Ordinal.lsub.{u1, max u2 u3} α (fun (a : α) => f (Sum.inl.{u1, u2} α β a))) (Ordinal.lsub.{u2, max u1 u3} β (fun (b : β) => f (Sum.inr.{u1, u2} α β b))))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u2}} (f : (Sum.{u1, u2} α β) -> Ordinal.{max (max u1 u2) u3}), Eq.{max (max (succ (succ u1)) (succ (succ u2))) (succ (succ u3))} Ordinal.{max u3 u1 u2} (Ordinal.lsub.{max u1 u2, u3} (Sum.{u1, u2} α β) f) (Max.max.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max (max u2 u3) u1} (LinearOrder.toMax.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max (max u2 u3) u1} Ordinal.instLinearOrderOrdinal.{max (max u1 u2) u3}) (Ordinal.lsub.{u1, max u2 u3} α (fun (a : α) => f (Sum.inl.{u1, u2} α β a))) (Ordinal.lsub.{u2, max u1 u3} β (fun (b : β) => f (Sum.inr.{u1, u2} α β b))))
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_sum Ordinal.lsub_sumₓ'. -/
@[simp]
theorem lsub_sum {α : Type u} {β : Type v} (f : Sum α β → Ordinal) :
    lsub.{max u v, w} f =
      max (lsub.{u, max v w} fun a => f (Sum.inl a)) (lsub.{v, max u w} fun b => f (Sum.inr b)) :=
  sup_sum _
#align ordinal.lsub_sum Ordinal.lsub_sum

#print Ordinal.lsub_not_mem_range /-
theorem lsub_not_mem_range {ι} (f : ι → Ordinal) : lsub f ∉ Set.range f := fun ⟨i, h⟩ =>
  h.not_lt (lt_lsub f i)
#align ordinal.lsub_not_mem_range Ordinal.lsub_not_mem_range
-/

/- warning: ordinal.nonempty_compl_range -> Ordinal.nonempty_compl_range is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Set.Nonempty.{succ (max u1 u2)} Ordinal.{max u1 u2} (HasCompl.compl.{succ (max u1 u2)} (Set.{succ (max u1 u2)} Ordinal.{max u1 u2}) (BooleanAlgebra.toHasCompl.{succ (max u1 u2)} (Set.{succ (max u1 u2)} Ordinal.{max u1 u2}) (Set.booleanAlgebra.{succ (max u1 u2)} Ordinal.{max u1 u2})) (Set.range.{succ (max u1 u2), succ u1} Ordinal.{max u1 u2} ι f))
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), Set.Nonempty.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (HasCompl.compl.{max (succ u1) (succ u2)} (Set.{max (succ u1) (succ u2)} Ordinal.{max u1 u2}) (BooleanAlgebra.toHasCompl.{max (succ u1) (succ u2)} (Set.{max (succ u1) (succ u2)} Ordinal.{max u1 u2}) (Set.instBooleanAlgebraSet.{max (succ u1) (succ u2)} Ordinal.{max u1 u2})) (Set.range.{max (succ u1) (succ u2), succ u1} Ordinal.{max u1 u2} ι f))
Case conversion may be inaccurate. Consider using '#align ordinal.nonempty_compl_range Ordinal.nonempty_compl_rangeₓ'. -/
theorem nonempty_compl_range {ι : Type u} (f : ι → Ordinal.{max u v}) : Set.range fᶜ.Nonempty :=
  ⟨_, lsub_not_mem_range f⟩
#align ordinal.nonempty_compl_range Ordinal.nonempty_compl_range

#print Ordinal.lsub_typein /-
@[simp]
theorem lsub_typein (o : Ordinal) : lsub.{u, u} (typein ((· < ·) : o.out.α → o.out.α → Prop)) = o :=
  (lsub_le.{u, u} typein_lt_self).antisymm
    (by
      by_contra' h
      nth_rw 1 [← type_lt o] at h
      simpa [typein_enum] using lt_lsub.{u, u} (typein (· < ·)) (enum (· < ·) _ h))
#align ordinal.lsub_typein Ordinal.lsub_typein
-/

/- warning: ordinal.sup_typein_limit -> Ordinal.sup_typein_limit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) o)) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{u1, u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Ordinal.typein.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (linearOrderOut.{u1} o))))))) (isWellOrder_out_lt.{u1} o))) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) o)) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{u1, u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Ordinal.typein.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.21991 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.21993 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (linearOrderOut.{u1} o))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.21991 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.21993) (isWellOrder_out_lt.{u1} o))) o)
Case conversion may be inaccurate. Consider using '#align ordinal.sup_typein_limit Ordinal.sup_typein_limitₓ'. -/
theorem sup_typein_limit {o : Ordinal} (ho : ∀ a, a < o → succ a < o) :
    sup.{u, u} (typein ((· < ·) : o.out.α → o.out.α → Prop)) = o := by
  rw [(sup_eq_lsub_iff_succ.{u, u} (typein (· < ·))).2] <;> rwa [lsub_typein o]
#align ordinal.sup_typein_limit Ordinal.sup_typein_limit

/- warning: ordinal.sup_typein_succ -> Ordinal.sup_typein_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{u1, u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Ordinal.typein.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (LinearOrder.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))))))) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)))) o
but is expected to have type
  forall {o : Ordinal.{u1}}, Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{u1, u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Ordinal.typein.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.22172 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.22174 : WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) => LT.lt.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Preorder.toLT.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (PartialOrder.toPreorder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (SemilatticeInf.toPartialOrder.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (Lattice.toSemilatticeInf.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (DistribLattice.toLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (instDistribLattice.{u1} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o))) (linearOrderOut.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))))))) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.22172 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.22174) (isWellOrder_out_lt.{u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)))) o
Case conversion may be inaccurate. Consider using '#align ordinal.sup_typein_succ Ordinal.sup_typein_succₓ'. -/
@[simp]
theorem sup_typein_succ {o : Ordinal} :
    sup.{u, u} (typein ((· < ·) : (succ o).out.α → (succ o).out.α → Prop)) = o :=
  by
  cases'
    sup_eq_lsub_or_sup_succ_eq_lsub.{u, u}
      (typein ((· < ·) : (succ o).out.α → (succ o).out.α → Prop)) with
    h h
  · rw [sup_eq_lsub_iff_succ] at h
    simp only [lsub_typein] at h
    exact (h o (lt_succ o)).False.elim
  rw [← succ_eq_succ_iff, h]
  apply lsub_typein
#align ordinal.sup_typein_succ Ordinal.sup_typein_succ

/- warning: ordinal.blsub -> Ordinal.blsub is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) -> Ordinal.{max u1 u2}
but is expected to have type
  forall (o : Ordinal.{u1}), (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}) -> Ordinal.{max u1 u2}
Case conversion may be inaccurate. Consider using '#align ordinal.blsub Ordinal.blsubₓ'. -/
/-- The least strict upper bound of a family of ordinals indexed by the set of ordinals less than
    some `o : ordinal.{u}`.

    This is to `lsub` as `bsup` is to `sup`. -/
def blsub (o : Ordinal.{u}) (f : ∀ a < o, Ordinal.{max u v}) : Ordinal.{max u v} :=
  o.bsup fun a ha => succ (f a ha)
#align ordinal.blsub Ordinal.blsub

/- warning: ordinal.bsup_eq_blsub -> Ordinal.bsup_eq_blsub is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o (fun (a : Ordinal.{u1}) (ha : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) => Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (f a ha))) (Ordinal.blsub.{u1, u2} o f)
but is expected to have type
  forall (o : Ordinal.{u1}) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o (fun (a : Ordinal.{u1}) (ha : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) => Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (f a ha))) (Ordinal.blsub.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_eq_blsub Ordinal.bsup_eq_blsubₓ'. -/
@[simp]
theorem bsup_eq_blsub (o : Ordinal) (f : ∀ a < o, Ordinal) :
    (bsup o fun a ha => succ (f a ha)) = blsub o f :=
  rfl
#align ordinal.bsup_eq_blsub Ordinal.bsup_eq_blsub

/- warning: ordinal.lsub_eq_blsub' -> Ordinal.lsub_eq_blsub' is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, succ (max u1 u2)} Ordinal.{max u1 u2} ι r _inst_1 o ho f)) (Ordinal.blsub.{u1, u2} o f)
but is expected to have type
  forall {ι : Type.{u1}} (r : ι -> ι -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lsub.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, max (succ u2) (succ u1)} Ordinal.{max u2 u1} ι r _inst_1 o ho f)) (Ordinal.blsub.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_eq_blsub' Ordinal.lsub_eq_blsub'ₓ'. -/
theorem lsub_eq_blsub' {ι} (r : ι → ι → Prop) [IsWellOrder ι r] {o} (ho : type r = o) (f) :
    lsub (familyOfBFamily' r ho f) = blsub o f :=
  sup_eq_bsup' r ho fun a ha => succ (f a ha)
#align ordinal.lsub_eq_blsub' Ordinal.lsub_eq_blsub'

/- warning: ordinal.lsub_eq_lsub -> Ordinal.lsub_eq_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {ι' : Type.{u1}} (r : ι -> ι -> Prop) (r' : ι' -> ι' -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] [_inst_2 : IsWellOrder.{u1} ι' r'] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (ho' : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι' r' _inst_2) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, succ (max u1 u2)} Ordinal.{max u1 u2} ι r _inst_1 o ho f)) (Ordinal.lsub.{u1, u2} ι' (Ordinal.familyOfBFamily'.{u1, succ (max u1 u2)} Ordinal.{max u1 u2} ι' r' _inst_2 o ho' f))
but is expected to have type
  forall {ι : Type.{u1}} {ι' : Type.{u1}} (r : ι -> ι -> Prop) (r' : ι' -> ι' -> Prop) [_inst_1 : IsWellOrder.{u1} ι r] [_inst_2 : IsWellOrder.{u1} ι' r'] {o : Ordinal.{u1}} (ho : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι r _inst_1) o) (ho' : Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.type.{u1} ι' r' _inst_2) o) (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lsub.{u1, u2} ι (Ordinal.familyOfBFamily'.{u1, max (succ u2) (succ u1)} Ordinal.{max u2 u1} ι r _inst_1 o ho f)) (Ordinal.lsub.{u1, u2} ι' (Ordinal.familyOfBFamily'.{u1, max (succ u2) (succ u1)} Ordinal.{max u2 u1} ι' r' _inst_2 o ho' f))
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_eq_lsub Ordinal.lsub_eq_lsubₓ'. -/
theorem lsub_eq_lsub {ι ι' : Type u} (r : ι → ι → Prop) (r' : ι' → ι' → Prop) [IsWellOrder ι r]
    [IsWellOrder ι' r'] {o} (ho : type r = o) (ho' : type r' = o) (f : ∀ a < o, Ordinal) :
    lsub (familyOfBFamily' r ho f) = lsub (familyOfBFamily' r' ho' f) := by
  rw [lsub_eq_blsub', lsub_eq_blsub']
#align ordinal.lsub_eq_lsub Ordinal.lsub_eq_lsub

/- warning: ordinal.lsub_eq_blsub -> Ordinal.lsub_eq_blsub is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.lsub.{u1, u2} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Ordinal.familyOfBFamily.{succ (max u1 u2), u1} Ordinal.{max u1 u2} o f)) (Ordinal.blsub.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lsub.{u1, u2} (WellOrder.α.{u1} (Quotient.out.{succ (succ u1)} WellOrder.{u1} Ordinal.isEquivalent.{u1} o)) (Ordinal.familyOfBFamily.{max (succ u1) (succ u2), u1} Ordinal.{max u2 u1} o f)) (Ordinal.blsub.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.lsub_eq_blsub Ordinal.lsub_eq_blsubₓ'. -/
@[simp]
theorem lsub_eq_blsub {o} (f : ∀ a < o, Ordinal) : lsub (familyOfBFamily o f) = blsub o f :=
  lsub_eq_blsub' _ _ _
#align ordinal.lsub_eq_blsub Ordinal.lsub_eq_blsub

#print Ordinal.blsub_eq_lsub' /-
@[simp]
theorem blsub_eq_lsub' {ι} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → Ordinal) :
    blsub _ (bfamilyOfFamily' r f) = lsub f :=
  bsup_eq_sup' r (succ ∘ f)
#align ordinal.blsub_eq_lsub' Ordinal.blsub_eq_lsub'
-/

#print Ordinal.blsub_eq_blsub /-
theorem blsub_eq_blsub {ι : Type u} (r r' : ι → ι → Prop) [IsWellOrder ι r] [IsWellOrder ι r']
    (f : ι → Ordinal) : blsub _ (bfamilyOfFamily' r f) = blsub _ (bfamilyOfFamily' r' f) := by
  rw [blsub_eq_lsub', blsub_eq_lsub']
#align ordinal.blsub_eq_blsub Ordinal.blsub_eq_blsub
-/

#print Ordinal.blsub_eq_lsub /-
@[simp]
theorem blsub_eq_lsub {ι} (f : ι → Ordinal) : blsub _ (bfamilyOfFamily f) = lsub f :=
  blsub_eq_lsub' _ _
#align ordinal.blsub_eq_lsub Ordinal.blsub_eq_lsub
-/

/- warning: ordinal.blsub_congr -> Ordinal.blsub_congr is a dubious translation:
lean 3 declaration is
  forall {o₁ : Ordinal.{u1}} {o₂ : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o₁) -> Ordinal.{max u1 u2}) (ho : Eq.{succ (succ u1)} Ordinal.{u1} o₁ o₂), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} o₁ f) (Ordinal.blsub.{u1, u2} o₂ (fun (a : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o₂) => f a (LT.lt.trans_eq.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) a o₂ o₁ h (Eq.symm.{succ (succ u1)} Ordinal.{u1} o₁ o₂ ho))))
but is expected to have type
  forall {o₁ : Ordinal.{u1}} {o₂ : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o₁) -> Ordinal.{max u1 u2}) (ho : Eq.{succ (succ u1)} Ordinal.{u1} o₁ o₂), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} o₁ f) (Ordinal.blsub.{u1, u2} o₂ (fun (a : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o₂) => f a (LT.lt.trans_eq.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) a o₂ o₁ h (Eq.symm.{succ (succ u1)} Ordinal.{u1} o₁ o₂ ho))))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_congr Ordinal.blsub_congrₓ'. -/
@[congr]
theorem blsub_congr {o₁ o₂ : Ordinal} (f : ∀ a < o₁, Ordinal) (ho : o₁ = o₂) :
    blsub o₁ f = blsub o₂ fun a h => f a (h.trans_eq ho.symm) := by subst ho
#align ordinal.blsub_congr Ordinal.blsub_congr

/- warning: ordinal.blsub_le_iff -> Ordinal.blsub_le_iff is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.blsub.{u1, u2} o f) a) (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) a)
but is expected to have type
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.blsub.{u1, u2} o f) a) (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i h) a)
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_le_iff Ordinal.blsub_le_iffₓ'. -/
theorem blsub_le_iff {o f a} : blsub o f ≤ a ↔ ∀ i h, f i h < a :=
  by
  convert bsup_le_iff
  simp [succ_le_iff]
#align ordinal.blsub_le_iff Ordinal.blsub_le_iff

/- warning: ordinal.blsub_le -> Ordinal.blsub_le is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (b : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) b o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) a) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.blsub.{u1, u2} o f) a)
but is expected to have type
  forall {o : Ordinal.{u2}} {f : forall (b : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) b o) -> Ordinal.{max u2 u1}} {a : Ordinal.{max u2 u1}}, (forall (i : Ordinal.{u2}) (h : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), LT.lt.{succ (max u2 u1)} Ordinal.{max u2 u1} (Preorder.toLT.{succ (max u2 u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{succ (max u2 u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) (f i h) a) -> (LE.le.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) (Ordinal.blsub.{u2, u1} o f) a)
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_le Ordinal.blsub_leₓ'. -/
theorem blsub_le {o : Ordinal} {f : ∀ b < o, Ordinal} {a} : (∀ i h, f i h < a) → blsub o f ≤ a :=
  blsub_le_iff.2
#align ordinal.blsub_le Ordinal.blsub_le

/- warning: ordinal.lt_blsub -> Ordinal.lt_blsub is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) (i : Ordinal.{u1}) (h : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i h) (Ordinal.blsub.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u1 u2}) (i : Ordinal.{u2}) (h : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i h) (Ordinal.blsub.{u2, u1} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.lt_blsub Ordinal.lt_blsubₓ'. -/
theorem lt_blsub {o} (f : ∀ a < o, Ordinal) (i h) : f i h < blsub o f :=
  blsub_le_iff.1 le_rfl _ _
#align ordinal.lt_blsub Ordinal.lt_blsub

/- warning: ordinal.lt_blsub_iff -> Ordinal.lt_blsub_iff is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.blsub.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (f i hi))))
but is expected to have type
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, Iff (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.blsub.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) => LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (f i hi))))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_blsub_iff Ordinal.lt_blsub_iffₓ'. -/
theorem lt_blsub_iff {o f a} : a < blsub o f ↔ ∃ i hi, a ≤ f i hi := by
  simpa only [not_forall, not_lt, not_le] using not_congr (@blsub_le_iff _ f a)
#align ordinal.lt_blsub_iff Ordinal.lt_blsub_iff

/- warning: ordinal.bsup_le_blsub -> Ordinal.bsup_le_blsub is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_le_blsub Ordinal.bsup_le_blsubₓ'. -/
theorem bsup_le_blsub {o} (f : ∀ a < o, Ordinal) : bsup o f ≤ blsub o f :=
  bsup_le fun i h => (lt_blsub f i h).le
#align ordinal.bsup_le_blsub Ordinal.bsup_le_blsub

/- warning: ordinal.blsub_le_bsup_succ -> Ordinal.blsub_le_bsup_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.blsub.{u1, u2} o f) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.bsup.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.blsub.{u1, u2} o f) (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_le_bsup_succ Ordinal.blsub_le_bsup_succₓ'. -/
theorem blsub_le_bsup_succ {o} (f : ∀ a < o, Ordinal) : blsub o f ≤ succ (bsup o f) :=
  blsub_le fun i h => lt_succ_iff.2 (le_bsup f i h)
#align ordinal.blsub_le_bsup_succ Ordinal.blsub_le_bsup_succ

/- warning: ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub -> Ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Or (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)) (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.bsup.{u1, u2} o f)) (Ordinal.blsub.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Or (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)) (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f)) (Ordinal.blsub.{u1, u2} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub Ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsubₓ'. -/
theorem bsup_eq_blsub_or_succ_bsup_eq_blsub {o} (f : ∀ a < o, Ordinal) :
    bsup o f = blsub o f ∨ succ (bsup o f) = blsub o f :=
  by
  rw [← sup_eq_bsup, ← lsub_eq_blsub]
  exact sup_eq_lsub_or_sup_succ_eq_lsub _
#align ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub Ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub

/- warning: ordinal.bsup_succ_le_blsub -> Ordinal.bsup_succ_le_blsub is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.bsup.{u1, u2} o f)) (Ordinal.blsub.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i hi) (Ordinal.bsup.{u1, u2} o f))))
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f)) (Ordinal.blsub.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) => Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i hi) (Ordinal.bsup.{u1, u2} o f))))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_succ_le_blsub Ordinal.bsup_succ_le_blsubₓ'. -/
theorem bsup_succ_le_blsub {o} (f : ∀ a < o, Ordinal) :
    succ (bsup o f) ≤ blsub o f ↔ ∃ i hi, f i hi = bsup o f :=
  by
  refine' ⟨fun h => _, _⟩
  · by_contra' hf
    exact
      ne_of_lt (succ_le_iff.1 h)
        (le_antisymm (bsup_le_blsub f) (blsub_le (lt_bsup_of_ne_bsup.1 hf)))
  rintro ⟨_, _, hf⟩
  rw [succ_le_iff, ← hf]
  exact lt_blsub _ _ _
#align ordinal.bsup_succ_le_blsub Ordinal.bsup_succ_le_blsub

/- warning: ordinal.bsup_succ_eq_blsub -> Ordinal.bsup_succ_eq_blsub is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (Ordinal.bsup.{u1, u2} o f)) (Ordinal.blsub.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i hi) (Ordinal.bsup.{u1, u2} o f))))
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f)) (Ordinal.blsub.{u1, u2} o f)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) => Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i hi) (Ordinal.bsup.{u1, u2} o f))))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_succ_eq_blsub Ordinal.bsup_succ_eq_blsubₓ'. -/
theorem bsup_succ_eq_blsub {o} (f : ∀ a < o, Ordinal) :
    succ (bsup o f) = blsub o f ↔ ∃ i hi, f i hi = bsup o f :=
  (blsub_le_bsup_succ f).le_iff_eq.symm.trans (bsup_succ_le_blsub f)
#align ordinal.bsup_succ_eq_blsub Ordinal.bsup_succ_eq_blsub

/- warning: ordinal.bsup_eq_blsub_iff_succ -> Ordinal.bsup_eq_blsub_iff_succ is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)) (forall (a : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.blsub.{u1, u2} o f)) -> (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} a) (Ordinal.blsub.{u1, u2} o f)))
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)) (forall (a : Ordinal.{max u1 u2}), (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.blsub.{u1, u2} o f)) -> (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} a) (Ordinal.blsub.{u1, u2} o f)))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_eq_blsub_iff_succ Ordinal.bsup_eq_blsub_iff_succₓ'. -/
theorem bsup_eq_blsub_iff_succ {o} (f : ∀ a < o, Ordinal) :
    bsup o f = blsub o f ↔ ∀ a < blsub o f, succ a < blsub o f :=
  by
  rw [← sup_eq_bsup, ← lsub_eq_blsub]
  apply sup_eq_lsub_iff_succ
#align ordinal.bsup_eq_blsub_iff_succ Ordinal.bsup_eq_blsub_iff_succ

/- warning: ordinal.bsup_eq_blsub_iff_lt_bsup -> Ordinal.bsup_eq_blsub_iff_lt_bsup is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)) (forall (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i hi) (Ordinal.bsup.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)) (forall (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i hi) (Ordinal.bsup.{u1, u2} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_eq_blsub_iff_lt_bsup Ordinal.bsup_eq_blsub_iff_lt_bsupₓ'. -/
theorem bsup_eq_blsub_iff_lt_bsup {o} (f : ∀ a < o, Ordinal) :
    bsup o f = blsub o f ↔ ∀ i hi, f i hi < bsup o f :=
  ⟨fun h i => by
    rw [h]
    apply lt_blsub, fun h => le_antisymm (bsup_le_blsub f) (blsub_le h)⟩
#align ordinal.bsup_eq_blsub_iff_lt_bsup Ordinal.bsup_eq_blsub_iff_lt_bsup

/- warning: ordinal.bsup_eq_blsub_of_lt_succ_limit -> Ordinal.bsup_eq_blsub_of_lt_succ_limit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (ho : Ordinal.IsLimit.{u1} o) {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}}, (forall (a : Ordinal.{u1}) (ha : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f a ha) (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) (And.right (Ne.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) o)) ho a ha))) -> (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u1}} (ho : Ordinal.IsLimit.{u1} o) {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}}, (forall (a : Ordinal.{u1}) (ha : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f a ha) (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) (And.right (Ne.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) o)) ho a ha))) -> (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_eq_blsub_of_lt_succ_limit Ordinal.bsup_eq_blsub_of_lt_succ_limitₓ'. -/
theorem bsup_eq_blsub_of_lt_succ_limit {o} (ho : IsLimit o) {f : ∀ a < o, Ordinal}
    (hf : ∀ a ha, f a ha < f (succ a) (ho.2 a ha)) : bsup o f = blsub o f :=
  by
  rw [bsup_eq_blsub_iff_lt_bsup]
  exact fun i hi => (hf i hi).trans_le (le_bsup f _ _)
#align ordinal.bsup_eq_blsub_of_lt_succ_limit Ordinal.bsup_eq_blsub_of_lt_succ_limit

/- warning: ordinal.blsub_succ_of_mono -> Ordinal.blsub_succ_of_mono is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) -> Ordinal.{max u1 u2}}, (forall {i : Ordinal.{u1}} {j : Ordinal.{u1}} (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) (hj : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) j (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)), (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i j) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f i hi) (f j hj))) -> (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o) f) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (f o (Order.lt_succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} Ordinal.noMaxOrder.{u1} o))))
but is expected to have type
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)) -> Ordinal.{max u1 u2}}, (forall {i : Ordinal.{u1}} {j : Ordinal.{u1}} (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)) (hj : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) j (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)), (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i j) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f i hi) (f j hj))) -> (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o) f) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} (f o (Order.lt_succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} Ordinal.instNoMaxOrderOrdinalToLTToPreorderInstPartialOrderOrdinal.{u1} o))))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_succ_of_mono Ordinal.blsub_succ_of_monoₓ'. -/
theorem blsub_succ_of_mono {o : Ordinal} {f : ∀ a < succ o, Ordinal}
    (hf : ∀ {i j} (hi hj), i ≤ j → f i hi ≤ f j hj) : blsub _ f = succ (f o (lt_succ o)) :=
  bsup_succ_of_mono fun i j hi hj h => succ_le_succ (hf hi hj h)
#align ordinal.blsub_succ_of_mono Ordinal.blsub_succ_of_mono

/- warning: ordinal.blsub_eq_zero_iff -> Ordinal.blsub_eq_zero_iff is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}}, Iff (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} o f) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2})))) (Eq.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))))
but is expected to have type
  forall {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u1 u2}}, Iff (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.blsub.{u2, u1} o f) (OfNat.ofNat.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} 0 (Zero.toOfNat0.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instZeroOrdinal.{max u1 u2}))) (Eq.{succ (succ u2)} Ordinal.{u2} o (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2})))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_eq_zero_iff Ordinal.blsub_eq_zero_iffₓ'. -/
@[simp]
theorem blsub_eq_zero_iff {o} {f : ∀ a < o, Ordinal} : blsub o f = 0 ↔ o = 0 :=
  by
  rw [← lsub_eq_blsub, lsub_eq_zero_iff]
  exact out_empty_iff_eq_zero
#align ordinal.blsub_eq_zero_iff Ordinal.blsub_eq_zero_iff

/- warning: ordinal.blsub_zero -> Ordinal.blsub_zero is a dubious translation:
lean 3 declaration is
  forall (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) f) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2})))
but is expected to have type
  forall (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2}))) -> Ordinal.{max u2 u1}), Eq.{max (succ (succ u2)) (succ (succ u1))} Ordinal.{max u2 u1} (Ordinal.blsub.{u2, u1} (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2})) f) (OfNat.ofNat.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} 0 (Zero.toOfNat0.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instZeroOrdinal.{max u2 u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_zero Ordinal.blsub_zeroₓ'. -/
@[simp]
theorem blsub_zero (f : ∀ a < (0 : Ordinal), Ordinal) : blsub 0 f = 0 := by rwa [blsub_eq_zero_iff]
#align ordinal.blsub_zero Ordinal.blsub_zero

/- warning: ordinal.blsub_pos -> Ordinal.blsub_pos is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) o) -> (forall (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (OfNat.ofNat.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (OfNat.mk.{succ (max u1 u2)} Ordinal.{max u1 u2} 0 (Zero.zero.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.hasZero.{max u1 u2}))) (Ordinal.blsub.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u2}}, (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2})) o) -> (forall (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u2 u1}), LT.lt.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (Preorder.toLT.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) (OfNat.ofNat.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} 0 (Zero.toOfNat0.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instZeroOrdinal.{max u2 u1})) (Ordinal.blsub.{u2, u1} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_pos Ordinal.blsub_posₓ'. -/
theorem blsub_pos {o : Ordinal} (ho : 0 < o) (f : ∀ a < o, Ordinal) : 0 < blsub o f :=
  (Ordinal.zero_le _).trans_lt (lt_blsub f 0 ho)
#align ordinal.blsub_pos Ordinal.blsub_pos

/- warning: ordinal.blsub_type -> Ordinal.blsub_type is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (r : α -> α -> Prop) [_inst_1 : IsWellOrder.{u1} α r] (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (Ordinal.type.{u1} α r _inst_1)) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} (Ordinal.type.{u1} α r _inst_1) f) (Ordinal.lsub.{u1, u2} α (fun (a : α) => f (Ordinal.typein.{u1} α r _inst_1 a) (Ordinal.typein_lt_type.{u1} α r _inst_1 a)))
but is expected to have type
  forall {α : Type.{u1}} (r : α -> α -> Prop) [_inst_1 : IsWellOrder.{u1} α r] (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (Ordinal.type.{u1} α r _inst_1)) -> Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} (Ordinal.type.{u1} α r _inst_1) f) (Ordinal.lsub.{u1, u2} α (fun (a : α) => f (Ordinal.typein.{u1} α r _inst_1 a) (Ordinal.typein_lt_type.{u1} α r _inst_1 a)))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_type Ordinal.blsub_typeₓ'. -/
theorem blsub_type (r : α → α → Prop) [IsWellOrder α r] (f) :
    blsub (type r) f = lsub fun a => f (typein r a) (typein_lt_type _ _) :=
  eq_of_forall_ge_iff fun o => by
    rw [blsub_le_iff, lsub_le_iff] <;>
      exact ⟨fun H b => H _ _, fun H i h => by simpa only [typein_enum] using H (enum r i h)⟩
#align ordinal.blsub_type Ordinal.blsub_type

/- warning: ordinal.blsub_const -> Ordinal.blsub_const is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) -> (forall (a : Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} o (fun (_x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) _x o) => a)) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} a))
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ne.{succ (succ u1)} Ordinal.{u1} o (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) -> (forall (a : Ordinal.{max u1 u2}), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} o (fun (_x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) _x o) => a)) (Order.succ.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u1 u2} a))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_const Ordinal.blsub_constₓ'. -/
theorem blsub_const {o : Ordinal} (ho : o ≠ 0) (a : Ordinal) :
    (blsub.{u, v} o fun _ _ => a) = succ a :=
  bsup_const.{u, v} ho (succ a)
#align ordinal.blsub_const Ordinal.blsub_const

/- warning: ordinal.blsub_one -> Ordinal.blsub_one is a dubious translation:
lean 3 declaration is
  forall (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1})))) -> Ordinal.{max u1 u2}), Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))) f) (Order.succ.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2}) Ordinal.succOrder.{max u1 u2} (f (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) (zero_lt_one.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1} Ordinal.hasOne.{u1} Ordinal.partialOrder.{u1} Ordinal.zeroLeOneClass.{u1} Ordinal.NeZero.one.{u1})))
but is expected to have type
  forall (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a (OfNat.ofNat.{succ u2} Ordinal.{u2} 1 (One.toOfNat1.{succ u2} Ordinal.{u2} Ordinal.instOneOrdinal.{u2}))) -> Ordinal.{max u2 u1}), Eq.{max (succ (succ u2)) (succ (succ u1))} Ordinal.{max u2 u1} (Ordinal.blsub.{u2, u1} (OfNat.ofNat.{succ u2} Ordinal.{u2} 1 (One.toOfNat1.{succ u2} Ordinal.{u2} Ordinal.instOneOrdinal.{u2})) f) (Order.succ.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{max u2 u1} (f (OfNat.ofNat.{succ u2} Ordinal.{u2} 0 (Zero.toOfNat0.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2})) (zero_lt_one.{succ u2} Ordinal.{u2} Ordinal.instZeroOrdinal.{u2} Ordinal.instOneOrdinal.{u2} Ordinal.instPartialOrderOrdinal.{u2} Ordinal.instZeroLEOneClassOrdinalInstZeroOrdinalInstOneOrdinalToLEToPreorderInstPartialOrderOrdinal.{u2} Ordinal.NeZero.one.{u2})))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_one Ordinal.blsub_oneₓ'. -/
@[simp]
theorem blsub_one (f : ∀ a < (1 : Ordinal), Ordinal) : blsub 1 f = succ (f 0 zero_lt_one) :=
  bsup_one _
#align ordinal.blsub_one Ordinal.blsub_one

#print Ordinal.blsub_id /-
@[simp]
theorem blsub_id : ∀ o, (blsub.{u, u} o fun x _ => x) = o :=
  lsub_typein
#align ordinal.blsub_id Ordinal.blsub_id
-/

/- warning: ordinal.bsup_id_limit -> Ordinal.bsup_id_limit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a) o)) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.bsup.{u1, u1} o (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x o) => x)) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a) o)) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.bsup.{u1, u1} o (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x o) => x)) o)
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_id_limit Ordinal.bsup_id_limitₓ'. -/
theorem bsup_id_limit {o : Ordinal} : (∀ a < o, succ a < o) → (bsup.{u, u} o fun x _ => x) = o :=
  sup_typein_limit
#align ordinal.bsup_id_limit Ordinal.bsup_id_limit

/- warning: ordinal.bsup_id_succ -> Ordinal.bsup_id_succ is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.bsup.{u1, u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o) (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} o)) => x)) o
but is expected to have type
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.bsup.{u1, u1} (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o) (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} o)) => x)) o
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_id_succ Ordinal.bsup_id_succₓ'. -/
@[simp]
theorem bsup_id_succ (o) : (bsup.{u, u} (succ o) fun x _ => x) = o :=
  sup_typein_succ
#align ordinal.bsup_id_succ Ordinal.bsup_id_succ

/- warning: ordinal.blsub_le_of_brange_subset -> Ordinal.blsub_le_of_brange_subset is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2 u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o') -> Ordinal.{max u1 u2 u3}}, (HasSubset.Subset.{succ (max u1 u2 u3)} (Set.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Set.hasSubset.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (Ordinal.brange.{succ (max u1 u2 u3), u1} Ordinal.{max u1 u2 u3} o f) (Ordinal.brange.{succ (max u1 u2 u3), u2} Ordinal.{max u1 u2 u3} o' g)) -> (LE.le.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} Ordinal.partialOrder.{max u1 u2 u3})) (Ordinal.blsub.{u1, max u2 u3} o f) (Ordinal.blsub.{u2, max u1 u3} o' g))
but is expected to have type
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max (max u1 u2) u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o') -> Ordinal.{max (max u1 u2) u3}}, (HasSubset.Subset.{succ (max (max u1 u2) u3)} (Set.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Set.instHasSubsetSet.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (Ordinal.brange.{succ (max (max u1 u2) u3), u1} Ordinal.{max (max u1 u2) u3} o f) (Ordinal.brange.{succ (max (max u1 u2) u3), u2} Ordinal.{max (max u1 u2) u3} o' g)) -> (LE.le.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} Ordinal.instPartialOrderOrdinal.{max (max u1 u2) u3})) (Ordinal.blsub.{u1, max u2 u3} o f) (Ordinal.blsub.{u2, max u1 u3} o' g))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_le_of_brange_subset Ordinal.blsub_le_of_brange_subsetₓ'. -/
theorem blsub_le_of_brange_subset {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f ⊆ brange o' g) : blsub.{u, max v w} o f ≤ blsub.{v, max u w} o' g :=
  bsup_le_of_brange_subset fun a ⟨b, hb, hb'⟩ =>
    by
    obtain ⟨c, hc, hc'⟩ := h ⟨b, hb, rfl⟩
    simp_rw [← hc'] at hb'
    exact ⟨c, hc, hb'⟩
#align ordinal.blsub_le_of_brange_subset Ordinal.blsub_le_of_brange_subset

/- warning: ordinal.blsub_eq_of_brange_eq -> Ordinal.blsub_eq_of_brange_eq is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2 u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) a o') -> Ordinal.{max u1 u2 u3}}, (Eq.{succ (succ (max u1 u2 u3))} (Set.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3}) (setOf.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (fun (o_1 : Ordinal.{max u1 u2 u3}) => Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => Eq.{succ (succ (max u1 u2 u3))} Ordinal.{max u1 u2 u3} (f i hi) o_1)))) (setOf.{succ (max u1 u2 u3)} Ordinal.{max u1 u2 u3} (fun (o : Ordinal.{max u1 u2 u3}) => Exists.{succ (succ u2)} Ordinal.{u2} (fun (i : Ordinal.{u2}) => Exists.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i o') (fun (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.partialOrder.{u2})) i o') => Eq.{succ (succ (max u1 u2 u3))} Ordinal.{max u1 u2 u3} (g i hi) o))))) -> (Eq.{succ (succ (max u1 u2 u3))} Ordinal.{max u1 u2 u3} (Ordinal.blsub.{u1, max u2 u3} o f) (Ordinal.blsub.{u2, max u1 u3} o' g))
but is expected to have type
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u2}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max (max u1 u2) u3}} {g : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o') -> Ordinal.{max (max u1 u2) u3}}, (Eq.{succ (succ (max (max u1 u2) u3))} (Set.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3}) (setOf.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} (fun (o_1 : Ordinal.{max (max u1 u2) u3}) => Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o) => Eq.{succ (succ (max (max u1 u2) u3))} Ordinal.{max (max u1 u2) u3} (f i hi) o_1)))) (setOf.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} (fun (o : Ordinal.{max (max u1 u2) u3}) => Exists.{succ (succ u2)} Ordinal.{u2} (fun (i : Ordinal.{u2}) => Exists.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o') (fun (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o') => Eq.{succ (succ (max (max u1 u2) u3))} Ordinal.{max (max u1 u2) u3} (g i hi) o))))) -> (Eq.{max (max (succ (succ u1)) (succ (succ u2))) (succ (succ u3))} Ordinal.{max u1 u2 u3} (Ordinal.blsub.{u1, max u2 u3} o f) (Ordinal.blsub.{u2, max u1 u3} o' g))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_eq_of_brange_eq Ordinal.blsub_eq_of_brange_eqₓ'. -/
theorem blsub_eq_of_brange_eq {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : { o | ∃ i hi, f i hi = o } = { o | ∃ i hi, g i hi = o }) :
    blsub.{u, max v w} o f = blsub.{v, max u w} o' g :=
  (blsub_le_of_brange_subset h.le).antisymm (blsub_le_of_brange_subset.{v, u, w} h.ge)
#align ordinal.blsub_eq_of_brange_eq Ordinal.blsub_eq_of_brange_eq

/- warning: ordinal.bsup_comp -> Ordinal.bsup_comp is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{max u1 u2}} {o' : Ordinal.{max u1 u2}} {f : forall (a : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a o) -> Ordinal.{max (max u1 u2) u3}}, (forall {i : Ordinal.{max u1 u2}} {j : Ordinal.{max u1 u2}} (hi : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) i o) (hj : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) j o), (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) i j) -> (LE.le.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} (Preorder.toLE.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} (PartialOrder.toPreorder.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} Ordinal.partialOrder.{max (max u1 u2) u3})) (f i hi) (f j hj))) -> (forall {g : forall (a : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a o') -> Ordinal.{max u1 u2}} (hg : Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o), Eq.{succ (succ (max (max u1 u2) u3))} Ordinal.{max (max u1 u2) u3} (Ordinal.bsup.{max u1 u2, u3} o' (fun (a : Ordinal.{max u1 u2}) (ha : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a o') => f (g a ha) (Eq.mpr.{0} (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o) (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g)) (id_tag Tactic.IdTag.rw (Eq.{1} Prop (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o) (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g))) (Eq.ndrec.{0, succ (succ (max u1 u2))} Ordinal.{max u1 u2} o (fun (_a : Ordinal.{max u1 u2}) => Eq.{1} Prop (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o) (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) _a)) (rfl.{1} Prop (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o)) (Ordinal.blsub.{max u1 u2, u1} o' g) (Eq.symm.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o hg))) (Ordinal.lt_blsub.{max u1 u2, u1} o' g a ha)))) (Ordinal.bsup.{max u1 u2, u3} o f))
but is expected to have type
  forall {o : Ordinal.{max u1 u2}} {o' : Ordinal.{max u1 u2}} {f : forall (a : Ordinal.{max u1 u2}), (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a o) -> Ordinal.{max u1 u2 u3}}, (forall {i : Ordinal.{max u1 u2}} {j : Ordinal.{max u1 u2}} (hi : LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) i o) (hj : LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) j o), (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) i j) -> (LE.le.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} Ordinal.instPartialOrderOrdinal.{max (max u1 u2) u3})) (f i hi) (f j hj))) -> (forall {g : forall (a : Ordinal.{max u1 u2}), (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a o') -> Ordinal.{max u1 u2}} (hg : Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o), Eq.{max (max (succ (succ u1)) (succ (succ u2))) (succ (succ u3))} Ordinal.{max (max u1 u2) u3} (Ordinal.bsup.{max u1 u2, u3} o' (fun (a : Ordinal.{max u1 u2}) (ha : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a o') => f (g a ha) (Eq.mpr.{0} (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o) (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g)) (id.{0} (Eq.{1} Prop (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o) (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g))) (Eq.ndrec.{0, succ (succ (max u1 u2))} Ordinal.{max u1 u2} o (fun (_a : Ordinal.{max u1 u2}) => Eq.{1} Prop (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o) (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) _a)) (Eq.refl.{1} Prop (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o)) (Ordinal.blsub.{max u1 u2, u1} o' g) (Eq.symm.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o hg))) (Ordinal.lt_blsub.{u1, max u1 u2} o' (fun (a : Ordinal.{max u1 u2}) => g a) a ha)))) (Ordinal.bsup.{max u1 u2, u3} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.bsup_comp Ordinal.bsup_compₓ'. -/
theorem bsup_comp {o o' : Ordinal} {f : ∀ a < o, Ordinal}
    (hf : ∀ {i j} (hi) (hj), i ≤ j → f i hi ≤ f j hj) {g : ∀ a < o', Ordinal}
    (hg : blsub o' g = o) :
    (bsup o' fun a ha =>
        f (g a ha)
          (by
            rw [← hg]
            apply lt_blsub)) =
      bsup o f :=
  by
  apply le_antisymm <;> refine' bsup_le fun i hi => _
  · apply le_bsup
  · rw [← hg, lt_blsub_iff] at hi
    rcases hi with ⟨j, hj, hj'⟩
    exact (hf _ _ hj').trans (le_bsup _ _ _)
#align ordinal.bsup_comp Ordinal.bsup_comp

/- warning: ordinal.blsub_comp -> Ordinal.blsub_comp is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{max u1 u2}} {o' : Ordinal.{max u1 u2}} {f : forall (a : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a o) -> Ordinal.{max (max u1 u2) u3}}, (forall {i : Ordinal.{max u1 u2}} {j : Ordinal.{max u1 u2}} (hi : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) i o) (hj : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) j o), (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) i j) -> (LE.le.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} (Preorder.toLE.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} (PartialOrder.toPreorder.{succ (max (max u1 u2) u3)} Ordinal.{max (max u1 u2) u3} Ordinal.partialOrder.{max (max u1 u2) u3})) (f i hi) (f j hj))) -> (forall {g : forall (a : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a o') -> Ordinal.{max u1 u2}} (hg : Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o), Eq.{succ (succ (max (max u1 u2) u3))} Ordinal.{max (max u1 u2) u3} (Ordinal.blsub.{max u1 u2, u3} o' (fun (a : Ordinal.{max u1 u2}) (ha : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a o') => f (g a ha) (Eq.mpr.{0} (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o) (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g)) (id_tag Tactic.IdTag.rw (Eq.{1} Prop (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o) (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g))) (Eq.ndrec.{0, succ (succ (max u1 u2))} Ordinal.{max u1 u2} o (fun (_a : Ordinal.{max u1 u2}) => Eq.{1} Prop (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o) (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) _a)) (rfl.{1} Prop (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (g a ha) o)) (Ordinal.blsub.{max u1 u2, u1} o' g) (Eq.symm.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o hg))) (Ordinal.lt_blsub.{max u1 u2, u1} o' g a ha)))) (Ordinal.blsub.{max u1 u2, u3} o f))
but is expected to have type
  forall {o : Ordinal.{max u1 u2}} {o' : Ordinal.{max u1 u2}} {f : forall (a : Ordinal.{max u1 u2}), (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a o) -> Ordinal.{max u1 u2 u3}}, (forall {i : Ordinal.{max u1 u2}} {j : Ordinal.{max u1 u2}} (hi : LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) i o) (hj : LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) j o), (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) i j) -> (LE.le.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (Preorder.toLE.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} (PartialOrder.toPreorder.{max (max (succ u1) (succ u2)) (succ u3)} Ordinal.{max u1 u2 u3} Ordinal.instPartialOrderOrdinal.{max (max u1 u2) u3})) (f i hi) (f j hj))) -> (forall {g : forall (a : Ordinal.{max u1 u2}), (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a o') -> Ordinal.{max u1 u2}} (hg : Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o), Eq.{max (max (succ (succ u1)) (succ (succ u2))) (succ (succ u3))} Ordinal.{max (max u1 u2) u3} (Ordinal.blsub.{max u1 u2, u3} o' (fun (a : Ordinal.{max u1 u2}) (ha : LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a o') => f (g a ha) (Eq.mpr.{0} (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o) (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g)) (id.{0} (Eq.{1} Prop (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o) (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) (Ordinal.blsub.{max u1 u2, u1} o' g))) (Eq.ndrec.{0, succ (succ (max u1 u2))} Ordinal.{max u1 u2} o (fun (_a : Ordinal.{max u1 u2}) => Eq.{1} Prop (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o) (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) _a)) (Eq.refl.{1} Prop (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (g a ha) o)) (Ordinal.blsub.{max u1 u2, u1} o' g) (Eq.symm.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{max u1 u2, u1} o' g) o hg))) (Ordinal.lt_blsub.{u1, max u1 u2} o' (fun (a : Ordinal.{max u1 u2}) => g a) a ha)))) (Ordinal.blsub.{max u1 u2, u3} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_comp Ordinal.blsub_compₓ'. -/
theorem blsub_comp {o o' : Ordinal} {f : ∀ a < o, Ordinal}
    (hf : ∀ {i j} (hi) (hj), i ≤ j → f i hi ≤ f j hj) {g : ∀ a < o', Ordinal}
    (hg : blsub o' g = o) :
    (blsub o' fun a ha =>
        f (g a ha)
          (by
            rw [← hg]
            apply lt_blsub)) =
      blsub o f :=
  @bsup_comp o _ (fun a ha => succ (f a ha)) (fun i j _ _ h => succ_le_succ_iff.2 (hf _ _ h)) g hg
#align ordinal.blsub_comp Ordinal.blsub_comp

#print Ordinal.IsNormal.bsup_eq /-
theorem IsNormal.bsup_eq {f} (H : IsNormal f) {o : Ordinal} (h : IsLimit o) :
    (bsup.{u} o fun x _ => f x) = f o := by
  rw [← IsNormal.bsup.{u, u} H (fun x _ => x) h.1, bsup_id_limit h.2]
#align ordinal.is_normal.bsup_eq Ordinal.IsNormal.bsup_eq
-/

#print Ordinal.IsNormal.blsub_eq /-
theorem IsNormal.blsub_eq {f} (H : IsNormal f) {o : Ordinal} (h : IsLimit o) :
    (blsub.{u} o fun x _ => f x) = f o :=
  by
  rw [← H.bsup_eq h, bsup_eq_blsub_of_lt_succ_limit h]
  exact fun a _ => H.1 a
#align ordinal.is_normal.blsub_eq Ordinal.IsNormal.blsub_eq
-/

/- warning: ordinal.is_normal_iff_lt_succ_and_bsup_eq -> Ordinal.isNormal_iff_lt_succ_and_bsup_eq is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{max u1 u2}}, Iff (Ordinal.IsNormal.{u1, max u1 u2} f) (And (forall (a : Ordinal.{u1}), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f a) (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a))) (forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x o) => f x)) (f o))))
but is expected to have type
  forall {f : Ordinal.{u1} -> Ordinal.{max u1 u2}}, Iff (Ordinal.IsNormal.{u1, max u1 u2} f) (And (forall (a : Ordinal.{u1}), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f a) (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a))) (forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.bsup.{u1, u2} o (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x o) => f x)) (f o))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal_iff_lt_succ_and_bsup_eq Ordinal.isNormal_iff_lt_succ_and_bsup_eqₓ'. -/
theorem isNormal_iff_lt_succ_and_bsup_eq {f} :
    IsNormal f ↔ (∀ a, f a < f (succ a)) ∧ ∀ o, IsLimit o → (bsup o fun x _ => f x) = f o :=
  ⟨fun h => ⟨h.1, @IsNormal.bsup_eq f h⟩, fun ⟨h₁, h₂⟩ =>
    ⟨h₁, fun o ho a => by
      rw [← h₂ o ho]
      exact bsup_le_iff⟩⟩
#align ordinal.is_normal_iff_lt_succ_and_bsup_eq Ordinal.isNormal_iff_lt_succ_and_bsup_eq

/- warning: ordinal.is_normal_iff_lt_succ_and_blsub_eq -> Ordinal.isNormal_iff_lt_succ_and_blsub_eq is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{max u1 u2}}, Iff (Ordinal.IsNormal.{u1, max u1 u2} f) (And (forall (a : Ordinal.{u1}), LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (f a) (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a))) (forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} o (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) x o) => f x)) (f o))))
but is expected to have type
  forall {f : Ordinal.{u1} -> Ordinal.{max u1 u2}}, Iff (Ordinal.IsNormal.{u1, max u1 u2} f) (And (forall (a : Ordinal.{u1}), LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (f a) (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a))) (forall (o : Ordinal.{u1}), (Ordinal.IsLimit.{u1} o) -> (Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (Ordinal.blsub.{u1, u2} o (fun (x : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x o) => f x)) (f o))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal_iff_lt_succ_and_blsub_eq Ordinal.isNormal_iff_lt_succ_and_blsub_eqₓ'. -/
theorem isNormal_iff_lt_succ_and_blsub_eq {f} :
    IsNormal f ↔ (∀ a, f a < f (succ a)) ∧ ∀ o, IsLimit o → (blsub o fun x _ => f x) = f o :=
  by
  rw [is_normal_iff_lt_succ_and_bsup_eq, and_congr_right_iff]
  intro h
  constructor <;> intro H o ho <;> have := H o ho <;>
    rwa [← bsup_eq_blsub_of_lt_succ_limit ho fun a _ => h a] at *
#align ordinal.is_normal_iff_lt_succ_and_blsub_eq Ordinal.isNormal_iff_lt_succ_and_blsub_eq

/- warning: ordinal.is_normal.eq_iff_zero_and_succ -> Ordinal.IsNormal.eq_iff_zero_and_succ is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u1}} {g : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (Ordinal.IsNormal.{u1, u1} g) -> (Iff (Eq.{succ (succ u1)} (Ordinal.{u1} -> Ordinal.{u1}) f g) (And (Eq.{succ (succ u1)} Ordinal.{u1} (f (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (g (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))))) (forall (a : Ordinal.{u1}), (Eq.{succ (succ u1)} Ordinal.{u1} (f a) (g a)) -> (Eq.{succ (succ u1)} Ordinal.{u1} (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a)) (g (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} a))))))
but is expected to have type
  forall {f : Ordinal.{u1} -> Ordinal.{u1}} {g : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (Ordinal.IsNormal.{u1, u1} g) -> (Iff (Eq.{succ (succ u1)} (Ordinal.{u1} -> Ordinal.{u1}) f g) (And (Eq.{succ (succ u1)} Ordinal.{u1} (f (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (g (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})))) (forall (a : Ordinal.{u1}), (Eq.{succ (succ u1)} Ordinal.{u1} (f a) (g a)) -> (Eq.{succ (succ u1)} Ordinal.{u1} (f (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a)) (g (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} a))))))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.eq_iff_zero_and_succ Ordinal.IsNormal.eq_iff_zero_and_succₓ'. -/
theorem IsNormal.eq_iff_zero_and_succ {f g : Ordinal.{u} → Ordinal.{u}} (hf : IsNormal f)
    (hg : IsNormal g) : f = g ↔ f 0 = g 0 ∧ ∀ a, f a = g a → f (succ a) = g (succ a) :=
  ⟨fun h => by simp [h], fun ⟨h₁, h₂⟩ =>
    funext fun a => by
      apply a.limit_rec_on
      assumption'
      intro o ho H
      rw [← IsNormal.bsup_eq.{u, u} hf ho, ← IsNormal.bsup_eq.{u, u} hg ho]
      congr
      ext (b hb)
      exact H b hb⟩
#align ordinal.is_normal.eq_iff_zero_and_succ Ordinal.IsNormal.eq_iff_zero_and_succ

/-! ### Minimum excluded ordinals -/


#print Ordinal.mex /-
/-- The minimum excluded ordinal in a family of ordinals. -/
def mex {ι : Type u} (f : ι → Ordinal.{max u v}) : Ordinal :=
  infₛ (Set.range fᶜ)
#align ordinal.mex Ordinal.mex
-/

#print Ordinal.mex_not_mem_range /-
theorem mex_not_mem_range {ι : Type u} (f : ι → Ordinal.{max u v}) : mex f ∉ Set.range f :=
  cinfₛ_mem (nonempty_compl_range f)
#align ordinal.mex_not_mem_range Ordinal.mex_not_mem_range
-/

/- warning: ordinal.le_mex_of_forall -> Ordinal.le_mex_of_forall is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (b : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) b a) -> (Exists.{succ u1} ι (fun (i : ι) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) b))) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.mex.{u1, u2} ι f))
but is expected to have type
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (b : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) b a) -> (Exists.{succ u1} ι (fun (i : ι) => Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i) b))) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.mex.{u1, u2} ι f))
Case conversion may be inaccurate. Consider using '#align ordinal.le_mex_of_forall Ordinal.le_mex_of_forallₓ'. -/
theorem le_mex_of_forall {ι : Type u} {f : ι → Ordinal.{max u v}} {a : Ordinal}
    (H : ∀ b < a, ∃ i, f i = b) : a ≤ mex f :=
  by
  by_contra' h
  exact mex_not_mem_range f (H _ h)
#align ordinal.le_mex_of_forall Ordinal.le_mex_of_forall

#print Ordinal.ne_mex /-
theorem ne_mex {ι} (f : ι → Ordinal) : ∀ i, f i ≠ mex f := by simpa using mex_not_mem_range f
#align ordinal.ne_mex Ordinal.ne_mex
-/

/- warning: ordinal.mex_le_of_ne -> Ordinal.mex_le_of_ne is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : ι), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) a) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.mex.{u1, u2} ι f) a)
but is expected to have type
  forall {ι : Type.{u2}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : ι), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) a) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.mex.{u2, u1} ι f) a)
Case conversion may be inaccurate. Consider using '#align ordinal.mex_le_of_ne Ordinal.mex_le_of_neₓ'. -/
theorem mex_le_of_ne {ι} {f : ι → Ordinal} {a} (ha : ∀ i, f i ≠ a) : mex f ≤ a :=
  cinfₛ_le' (by simp [ha])
#align ordinal.mex_le_of_ne Ordinal.mex_le_of_ne

/- warning: ordinal.exists_of_lt_mex -> Ordinal.exists_of_lt_mex is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.mex.{u1, u2} ι f)) -> (Exists.{succ u1} ι (fun (i : ι) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i) a))
but is expected to have type
  forall {ι : Type.{u2}} {f : ι -> Ordinal.{max u1 u2}} {a : Ordinal.{max u2 u1}}, (LT.lt.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLT.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) a (Ordinal.mex.{u2, u1} ι f)) -> (Exists.{succ u2} ι (fun (i : ι) => Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i) a))
Case conversion may be inaccurate. Consider using '#align ordinal.exists_of_lt_mex Ordinal.exists_of_lt_mexₓ'. -/
theorem exists_of_lt_mex {ι} {f : ι → Ordinal} {a} (ha : a < mex f) : ∃ i, f i = a :=
  by
  by_contra' ha'
  exact ha.not_le (mex_le_of_ne ha')
#align ordinal.exists_of_lt_mex Ordinal.exists_of_lt_mex

/- warning: ordinal.mex_le_lsub -> Ordinal.mex_le_lsub is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.mex.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)
but is expected to have type
  forall {ι : Type.{u1}} (f : ι -> Ordinal.{max u1 u2}), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.mex.{u1, u2} ι f) (Ordinal.lsub.{u1, u2} ι f)
Case conversion may be inaccurate. Consider using '#align ordinal.mex_le_lsub Ordinal.mex_le_lsubₓ'. -/
theorem mex_le_lsub {ι} (f : ι → Ordinal) : mex f ≤ lsub f :=
  cinfₛ_le' (lsub_not_mem_range f)
#align ordinal.mex_le_lsub Ordinal.mex_le_lsub

/- warning: ordinal.mex_monotone -> Ordinal.mex_monotone is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u1}} {f : α -> Ordinal.{max u1 u2}} {g : β -> Ordinal.{max u1 u2}}, (HasSubset.Subset.{succ (max u1 u2)} (Set.{succ (max u1 u2)} Ordinal.{max u1 u2}) (Set.hasSubset.{succ (max u1 u2)} Ordinal.{max u1 u2}) (Set.range.{succ (max u1 u2), succ u1} Ordinal.{max u1 u2} α f) (Set.range.{succ (max u1 u2), succ u1} Ordinal.{max u1 u2} β g)) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.mex.{u1, u2} α f) (Ordinal.mex.{u1, u2} β g))
but is expected to have type
  forall {α : Type.{u1}} {β : Type.{u1}} {f : α -> Ordinal.{max u1 u2}} {g : β -> Ordinal.{max u1 u2}}, (HasSubset.Subset.{max (succ u1) (succ u2)} (Set.{max (succ u1) (succ u2)} Ordinal.{max u1 u2}) (Set.instHasSubsetSet.{max (succ u1) (succ u2)} Ordinal.{max u1 u2}) (Set.range.{max (succ u1) (succ u2), succ u1} Ordinal.{max u1 u2} α f) (Set.range.{max (succ u1) (succ u2), succ u1} Ordinal.{max u1 u2} β g)) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.mex.{u1, u2} α f) (Ordinal.mex.{u1, u2} β g))
Case conversion may be inaccurate. Consider using '#align ordinal.mex_monotone Ordinal.mex_monotoneₓ'. -/
theorem mex_monotone {α β} {f : α → Ordinal} {g : β → Ordinal} (h : Set.range f ⊆ Set.range g) :
    mex f ≤ mex g := by
  refine' mex_le_of_ne fun i hi => _
  cases' h ⟨i, rfl⟩ with j hj
  rw [← hj] at hi
  exact ne_mex g j hi
#align ordinal.mex_monotone Ordinal.mex_monotone

/- warning: ordinal.mex_lt_ord_succ_mk -> Ordinal.mex_lt_ord_succ_mk is a dubious translation:
lean 3 declaration is
  forall {ι : Type.{max u_1 u_2}} (f : ι -> Ordinal.{max u_1 u_2}), LT.lt.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} (Preorder.toLT.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} (PartialOrder.toPreorder.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} Ordinal.partialOrder.{max u_1 u_2})) (Ordinal.mex.{max u_1 u_2, u_1} ι f) (Cardinal.ord.{max u_1 u_2} (Order.succ.{succ (max u_1 u_2)} Cardinal.{max u_1 u_2} (PartialOrder.toPreorder.{succ (max u_1 u_2)} Cardinal.{max u_1 u_2} Cardinal.partialOrder.{max u_1 u_2}) Cardinal.succOrder.{max u_1 u_2} (Cardinal.mk.{max u_1 u_2} ι)))
but is expected to have type
  forall {ι : Type.{u}} (f : ι -> Ordinal.{u}), LT.lt.{succ u} Ordinal.{u} (Preorder.toLT.{succ u} Ordinal.{u} (PartialOrder.toPreorder.{succ u} Ordinal.{u} Ordinal.instPartialOrderOrdinal.{u})) (Ordinal.mex.{u, u} ι f) (Cardinal.ord.{u} (Order.succ.{succ u} Cardinal.{u} (PartialOrder.toPreorder.{succ u} Cardinal.{u} Cardinal.partialOrder.{u}) Cardinal.instSuccOrderCardinalToPreorderPartialOrder.{u} (Cardinal.mk.{u} ι)))
Case conversion may be inaccurate. Consider using '#align ordinal.mex_lt_ord_succ_mk Ordinal.mex_lt_ord_succ_mkₓ'. -/
theorem mex_lt_ord_succ_mk {ι} (f : ι → Ordinal) : mex f < (succ (#ι)).ord :=
  by
  by_contra' h
  apply (lt_succ (#ι)).not_le
  have H := fun a => exists_of_lt_mex ((typein_lt_self a).trans_le h)
  let g : (succ (#ι)).ord.out.α → ι := fun a => Classical.choose (H a)
  have hg : injective g := fun a b h' =>
    by
    have Hf : ∀ x, f (g x) = typein (· < ·) x := fun a => Classical.choose_spec (H a)
    apply_fun f  at h'
    rwa [Hf, Hf, typein_inj] at h'
  convert Cardinal.mk_le_of_injective hg
  rw [Cardinal.mk_ord_out]
#align ordinal.mex_lt_ord_succ_mk Ordinal.mex_lt_ord_succ_mk

/- warning: ordinal.bmex -> Ordinal.bmex is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) -> Ordinal.{max u1 u2}
but is expected to have type
  forall (o : Ordinal.{u1}), (forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}) -> Ordinal.{max u2 u1}
Case conversion may be inaccurate. Consider using '#align ordinal.bmex Ordinal.bmexₓ'. -/
/-- The minimum excluded ordinal of a family of ordinals indexed by the set of ordinals less than
    some `o : ordinal.{u}`. This is a special case of `mex` over the family provided by
    `family_of_bfamily`.

    This is to `mex` as `bsup` is to `sup`. -/
def bmex (o : Ordinal) (f : ∀ a < o, Ordinal) : Ordinal :=
  mex (familyOfBFamily o f)
#align ordinal.bmex Ordinal.bmex

/- warning: ordinal.bmex_not_mem_brange -> Ordinal.bmex_not_mem_brange is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), Not (Membership.Mem.{succ (max u1 u2), succ (max u1 u2)} Ordinal.{max u1 u2} (Set.{succ (max u1 u2)} Ordinal.{max u1 u2}) (Set.hasMem.{succ (max u1 u2)} Ordinal.{max u1 u2}) (Ordinal.bmex.{u1, u2} o f) (Ordinal.brange.{succ (max u1 u2), u1} Ordinal.{max u1 u2} o f))
but is expected to have type
  forall {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u2 u1}), Not (Membership.mem.{max (succ u1) (succ u2), max (succ u2) (succ u1)} Ordinal.{max u1 u2} (Set.{max (succ u2) (succ u1)} Ordinal.{max u2 u1}) (Set.instMembershipSet.{max (succ u2) (succ u1)} Ordinal.{max u2 u1}) (Ordinal.bmex.{u2, u1} o f) (Ordinal.brange.{max (succ u2) (succ u1), u2} Ordinal.{max u2 u1} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.bmex_not_mem_brange Ordinal.bmex_not_mem_brangeₓ'. -/
theorem bmex_not_mem_brange {o : Ordinal} (f : ∀ a < o, Ordinal) : bmex o f ∉ brange o f :=
  by
  rw [← range_family_of_bfamily]
  apply mex_not_mem_range
#align ordinal.bmex_not_mem_brange Ordinal.bmex_not_mem_brange

/- warning: ordinal.le_bmex_of_forall -> Ordinal.le_bmex_of_forall is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) {a : Ordinal.{max u1 u2}}, (forall (b : Ordinal.{max u1 u2}), (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) b a) -> (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i hi) b)))) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.bmex.{u1, u2} o f))
but is expected to have type
  forall {o : Ordinal.{u2}} (f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u2 u1}) {a : Ordinal.{max u2 u1}}, (forall (b : Ordinal.{max u2 u1}), (LT.lt.{succ (max u2 u1)} Ordinal.{max u2 u1} (Preorder.toLT.{succ (max u2 u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{succ (max u2 u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) b a) -> (Exists.{succ (succ u2)} Ordinal.{u2} (fun (i : Ordinal.{u2}) => Exists.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o) (fun (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o) => Eq.{succ (succ (max u2 u1))} Ordinal.{max u2 u1} (f i hi) b)))) -> (LE.le.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u2 u1})) a (Ordinal.bmex.{u2, u1} o f))
Case conversion may be inaccurate. Consider using '#align ordinal.le_bmex_of_forall Ordinal.le_bmex_of_forallₓ'. -/
theorem le_bmex_of_forall {o : Ordinal} (f : ∀ a < o, Ordinal) {a : Ordinal}
    (H : ∀ b < a, ∃ i hi, f i hi = b) : a ≤ bmex o f :=
  by
  by_contra' h
  exact bmex_not_mem_brange f (H _ h)
#align ordinal.le_bmex_of_forall Ordinal.le_bmex_of_forall

/- warning: ordinal.ne_bmex -> Ordinal.ne_bmex is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}) {i : Ordinal.{u1}} (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i hi) (Ordinal.bmex.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}) {i : Ordinal.{u1}} (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) i o), Ne.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u1 u2} (f i hi) (Ordinal.bmex.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.ne_bmex Ordinal.ne_bmexₓ'. -/
theorem ne_bmex {o : Ordinal} (f : ∀ a < o, Ordinal) {i} (hi) : f i hi ≠ bmex o f :=
  by
  convert ne_mex _ (enum (· < ·) i (by rwa [type_lt]))
  rw [family_of_bfamily_enum]
#align ordinal.ne_bmex Ordinal.ne_bmex

/- warning: ordinal.bmex_le_of_ne -> Ordinal.bmex_le_of_ne is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (forall (i : Ordinal.{u1}) (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o), Ne.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i hi) a) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.bmex.{u1, u2} o f) a)
but is expected to have type
  forall {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u2 u1}} {a : Ordinal.{max u2 u1}}, (forall (i : Ordinal.{u2}) (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o), Ne.{succ (succ (max u2 u1))} Ordinal.{max u2 u1} (f i hi) a) -> (LE.le.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (Preorder.toLE.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u2 u1})) (Ordinal.bmex.{u2, u1} o f) a)
Case conversion may be inaccurate. Consider using '#align ordinal.bmex_le_of_ne Ordinal.bmex_le_of_neₓ'. -/
theorem bmex_le_of_ne {o : Ordinal} {f : ∀ a < o, Ordinal} {a} (ha : ∀ i hi, f i hi ≠ a) :
    bmex o f ≤ a :=
  mex_le_of_ne fun i => ha _ _
#align ordinal.bmex_le_of_ne Ordinal.bmex_le_of_ne

/- warning: ordinal.exists_of_lt_bmex -> Ordinal.exists_of_lt_bmex is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}} {a : Ordinal.{max u1 u2}}, (LT.lt.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLT.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) a (Ordinal.bmex.{u1, u2} o f)) -> (Exists.{succ (succ u1)} Ordinal.{u1} (fun (i : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) (fun (hi : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) i o) => Eq.{succ (succ (max u1 u2))} Ordinal.{max u1 u2} (f i hi) a)))
but is expected to have type
  forall {o : Ordinal.{u2}} {f : forall (a : Ordinal.{u2}), (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) a o) -> Ordinal.{max u2 u1}} {a : Ordinal.{max u1 u2}}, (LT.lt.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (Preorder.toLT.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{max (succ u2) (succ u1)} Ordinal.{max u1 u2} Ordinal.instPartialOrderOrdinal.{max u2 u1})) a (Ordinal.bmex.{u2, u1} o f)) -> (Exists.{succ (succ u2)} Ordinal.{u2} (fun (i : Ordinal.{u2}) => Exists.{0} (LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o) (fun (hi : LT.lt.{succ u2} Ordinal.{u2} (Preorder.toLT.{succ u2} Ordinal.{u2} (PartialOrder.toPreorder.{succ u2} Ordinal.{u2} Ordinal.instPartialOrderOrdinal.{u2})) i o) => Eq.{max (succ (succ u2)) (succ (succ u1))} Ordinal.{max u2 u1} (f i hi) a)))
Case conversion may be inaccurate. Consider using '#align ordinal.exists_of_lt_bmex Ordinal.exists_of_lt_bmexₓ'. -/
theorem exists_of_lt_bmex {o : Ordinal} {f : ∀ a < o, Ordinal} {a} (ha : a < bmex o f) :
    ∃ i hi, f i hi = a := by
  cases' exists_of_lt_mex ha with i hi
  exact ⟨_, typein_lt_self i, hi⟩
#align ordinal.exists_of_lt_bmex Ordinal.exists_of_lt_bmex

/- warning: ordinal.bmex_le_blsub -> Ordinal.bmex_le_blsub is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}), LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.bmex.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)
but is expected to have type
  forall {o : Ordinal.{u1}} (f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}), LE.le.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.bmex.{u1, u2} o f) (Ordinal.blsub.{u1, u2} o f)
Case conversion may be inaccurate. Consider using '#align ordinal.bmex_le_blsub Ordinal.bmex_le_blsubₓ'. -/
theorem bmex_le_blsub {o : Ordinal} (f : ∀ a < o, Ordinal) : bmex o f ≤ blsub o f :=
  mex_le_lsub _
#align ordinal.bmex_le_blsub Ordinal.bmex_le_blsub

/- warning: ordinal.bmex_monotone -> Ordinal.bmex_monotone is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) -> Ordinal.{max u1 u2}} {g : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o') -> Ordinal.{max u1 u2}}, (HasSubset.Subset.{succ (max u1 u2)} (Set.{succ (max u1 u2)} Ordinal.{max u1 u2}) (Set.hasSubset.{succ (max u1 u2)} Ordinal.{max u1 u2}) (Ordinal.brange.{succ (max u1 u2), u1} Ordinal.{max u1 u2} o f) (Ordinal.brange.{succ (max u1 u2), u1} Ordinal.{max u1 u2} o' g)) -> (LE.le.{succ (max u1 u2)} Ordinal.{max u1 u2} (Preorder.toLE.{succ (max u1 u2)} Ordinal.{max u1 u2} (PartialOrder.toPreorder.{succ (max u1 u2)} Ordinal.{max u1 u2} Ordinal.partialOrder.{max u1 u2})) (Ordinal.bmex.{u1, u2} o f) (Ordinal.bmex.{u1, u2} o' g))
but is expected to have type
  forall {o : Ordinal.{u1}} {o' : Ordinal.{u1}} {f : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) -> Ordinal.{max u1 u2}} {g : forall (a : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o') -> Ordinal.{max u1 u2}}, (HasSubset.Subset.{max (succ u1) (succ u2)} (Set.{max (succ u1) (succ u2)} Ordinal.{max u1 u2}) (Set.instHasSubsetSet.{max (succ u1) (succ u2)} Ordinal.{max u1 u2}) (Ordinal.brange.{max (succ u1) (succ u2), u1} Ordinal.{max u1 u2} o f) (Ordinal.brange.{max (succ u1) (succ u2), u1} Ordinal.{max u1 u2} o' g)) -> (LE.le.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (Preorder.toLE.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (PartialOrder.toPreorder.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instPartialOrderOrdinal.{max u1 u2})) (Ordinal.bmex.{u1, u2} o f) (Ordinal.bmex.{u1, u2} o' g))
Case conversion may be inaccurate. Consider using '#align ordinal.bmex_monotone Ordinal.bmex_monotoneₓ'. -/
theorem bmex_monotone {o o' : Ordinal} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f ⊆ brange o' g) : bmex o f ≤ bmex o' g :=
  mex_monotone (by rwa [range_family_of_bfamily, range_family_of_bfamily])
#align ordinal.bmex_monotone Ordinal.bmex_monotone

/- warning: ordinal.bmex_lt_ord_succ_card -> Ordinal.bmex_lt_ord_succ_card is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{max u_1 u_2}} (f : forall (a : Ordinal.{max u_1 u_2}), (LT.lt.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} (Preorder.toLT.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} (PartialOrder.toPreorder.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} Ordinal.partialOrder.{max u_1 u_2})) a o) -> Ordinal.{max u_1 u_2}), LT.lt.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} (Preorder.toLT.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} (PartialOrder.toPreorder.{succ (max u_1 u_2)} Ordinal.{max u_1 u_2} Ordinal.partialOrder.{max u_1 u_2})) (Ordinal.bmex.{max u_1 u_2, u_1} o f) (Cardinal.ord.{max u_1 u_2} (Order.succ.{succ (max u_1 u_2)} Cardinal.{max u_1 u_2} (PartialOrder.toPreorder.{succ (max u_1 u_2)} Cardinal.{max u_1 u_2} Cardinal.partialOrder.{max u_1 u_2}) Cardinal.succOrder.{max u_1 u_2} (Ordinal.card.{max u_1 u_2} o)))
but is expected to have type
  forall {o : Ordinal.{u}} (f : forall (a : Ordinal.{u}), (LT.lt.{succ u} Ordinal.{u} (Preorder.toLT.{succ u} Ordinal.{u} (PartialOrder.toPreorder.{succ u} Ordinal.{u} Ordinal.instPartialOrderOrdinal.{u})) a o) -> Ordinal.{u}), LT.lt.{succ u} Ordinal.{u} (Preorder.toLT.{succ u} Ordinal.{u} (PartialOrder.toPreorder.{succ u} Ordinal.{u} Ordinal.instPartialOrderOrdinal.{u})) (Ordinal.bmex.{u, u} o f) (Cardinal.ord.{u} (Order.succ.{succ u} Cardinal.{u} (PartialOrder.toPreorder.{succ u} Cardinal.{u} Cardinal.partialOrder.{u}) Cardinal.instSuccOrderCardinalToPreorderPartialOrder.{u} (Ordinal.card.{u} o)))
Case conversion may be inaccurate. Consider using '#align ordinal.bmex_lt_ord_succ_card Ordinal.bmex_lt_ord_succ_cardₓ'. -/
theorem bmex_lt_ord_succ_card {o : Ordinal} (f : ∀ a < o, Ordinal) : bmex o f < (succ o.card).ord :=
  by
  rw [← mk_ordinal_out]
  exact mex_lt_ord_succ_mk (family_of_bfamily o f)
#align ordinal.bmex_lt_ord_succ_card Ordinal.bmex_lt_ord_succ_card

end Ordinal

/-! ### Results about injectivity and surjectivity -/


#print not_surjective_of_ordinal /-
theorem not_surjective_of_ordinal {α : Type u} (f : α → Ordinal.{u}) : ¬Surjective f := fun h =>
  Ordinal.lsub_not_mem_range.{u, u} f (h _)
#align not_surjective_of_ordinal not_surjective_of_ordinal
-/

#print not_injective_of_ordinal /-
theorem not_injective_of_ordinal {α : Type u} (f : Ordinal.{u} → α) : ¬Injective f := fun h =>
  not_surjective_of_ordinal _ (invFun_surjective h)
#align not_injective_of_ordinal not_injective_of_ordinal
-/

#print not_surjective_of_ordinal_of_small /-
theorem not_surjective_of_ordinal_of_small {α : Type v} [Small.{u} α] (f : α → Ordinal.{u}) :
    ¬Surjective f := fun h => not_surjective_of_ordinal _ (h.comp (equivShrink _).symm.Surjective)
#align not_surjective_of_ordinal_of_small not_surjective_of_ordinal_of_small
-/

#print not_injective_of_ordinal_of_small /-
theorem not_injective_of_ordinal_of_small {α : Type v} [Small.{u} α] (f : Ordinal.{u} → α) :
    ¬Injective f := fun h => not_injective_of_ordinal _ ((equivShrink _).Injective.comp h)
#align not_injective_of_ordinal_of_small not_injective_of_ordinal_of_small
-/

#print not_small_ordinal /-
/-- The type of ordinals in universe `u` is not `small.{u}`. This is the type-theoretic analog of
the Burali-Forti paradox. -/
theorem not_small_ordinal : ¬Small.{u} Ordinal.{max u v} := fun h =>
  @not_injective_of_ordinal_of_small _ h _ fun a b => Ordinal.lift_inj.1
#align not_small_ordinal not_small_ordinal
-/

/-! ### Enumerating unbounded sets of ordinals with ordinals -/


namespace Ordinal

section

#print Ordinal.enumOrd /-
/-- Enumerator function for an unbounded set of ordinals. -/
def enumOrd (S : Set Ordinal.{u}) : Ordinal → Ordinal :=
  lt_wf.fix fun o f => infₛ (S ∩ Set.Ici (blsub.{u, u} o f))
#align ordinal.enum_ord Ordinal.enumOrd
-/

variable {S : Set Ordinal.{u}}

/- warning: ordinal.enum_ord_def' -> Ordinal.enumOrd_def' is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}} (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S o) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toHasInf.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.conditionallyCompleteLinearOrderBot.{u1}))) (Inter.inter.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasInter.{succ u1} Ordinal.{u1}) S (Set.Ici.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (Ordinal.blsub.{u1, u1} o (fun (a : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a o) => Ordinal.enumOrd.{u1} S a)))))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}} (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S o) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toInfSet.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{u1}))) (Inter.inter.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.instInterSet.{succ u1} Ordinal.{u1}) S (Set.Ici.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) (Ordinal.blsub.{u1, u1} o (fun (a : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a o) => Ordinal.enumOrd.{u1} S a)))))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_def' Ordinal.enumOrd_def'ₓ'. -/
/-- The equation that characterizes `enum_ord` definitionally. This isn't the nicest expression to
    work with, so consider using `enum_ord_def` instead. -/
theorem enumOrd_def' (o) :
    enumOrd S o = infₛ (S ∩ Set.Ici (blsub.{u, u} o fun a _ => enumOrd S a)) :=
  lt_wf.fix_eq _ _
#align ordinal.enum_ord_def' Ordinal.enumOrd_def'

/- warning: ordinal.enum_ord_def'_nonempty -> Ordinal.enumOrd_def'_nonempty is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (forall (a : Ordinal.{u1}), Set.Nonempty.{succ u1} Ordinal.{u1} (Inter.inter.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasInter.{succ u1} Ordinal.{u1}) S (Set.Ici.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) a)))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28069 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28071 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28069 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28071) S) -> (forall (a : Ordinal.{u1}), Set.Nonempty.{succ u1} Ordinal.{u1} (Inter.inter.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.instInterSet.{succ u1} Ordinal.{u1}) S (Set.Ici.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) a)))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_def'_nonempty Ordinal.enumOrd_def'_nonemptyₓ'. -/
/-- The set in `enum_ord_def'` is nonempty. -/
theorem enumOrd_def'_nonempty (hS : Unbounded (· < ·) S) (a) : (S ∩ Set.Ici a).Nonempty :=
  let ⟨b, hb, hb'⟩ := hS a
  ⟨b, hb, le_of_not_gt hb'⟩
#align ordinal.enum_ord_def'_nonempty Ordinal.enumOrd_def'_nonempty

private theorem enum_ord_mem_aux (hS : Unbounded (· < ·) S) (o) :
    enumOrd S o ∈ S ∩ Set.Ici (blsub.{u, u} o fun c _ => enumOrd S c) :=
  by
  rw [enum_ord_def']
  exact cinfₛ_mem (enum_ord_def'_nonempty hS _)
#align ordinal.enum_ord_mem_aux ordinal.enum_ord_mem_aux

/- warning: ordinal.enum_ord_mem -> Ordinal.enumOrd_mem is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (forall (o : Ordinal.{u1}), Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) (Ordinal.enumOrd.{u1} S o) S)
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28218 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28220 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28218 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28220) S) -> (forall (o : Ordinal.{u1}), Membership.mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.instMembershipSet.{succ u1} Ordinal.{u1}) (Ordinal.enumOrd.{u1} S o) S)
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_mem Ordinal.enumOrd_memₓ'. -/
theorem enumOrd_mem (hS : Unbounded (· < ·) S) (o) : enumOrd S o ∈ S :=
  (enumOrd_mem_aux hS o).left
#align ordinal.enum_ord_mem Ordinal.enumOrd_mem

/- warning: ordinal.blsub_le_enum_ord -> Ordinal.blsub_le_enumOrd is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (forall (o : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.blsub.{u1, u1} o (fun (c : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c o) => Ordinal.enumOrd.{u1} S c)) (Ordinal.enumOrd.{u1} S o))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28253 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28255 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28253 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28255) S) -> (forall (o : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.blsub.{u1, u1} o (fun (c : Ordinal.{u1}) (_x : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c o) => Ordinal.enumOrd.{u1} S c)) (Ordinal.enumOrd.{u1} S o))
Case conversion may be inaccurate. Consider using '#align ordinal.blsub_le_enum_ord Ordinal.blsub_le_enumOrdₓ'. -/
theorem blsub_le_enumOrd (hS : Unbounded (· < ·) S) (o) :
    (blsub.{u, u} o fun c _ => enumOrd S c) ≤ enumOrd S o :=
  (enumOrd_mem_aux hS o).right
#align ordinal.blsub_le_enum_ord Ordinal.blsub_le_enumOrd

/- warning: ordinal.enum_ord_strict_mono -> Ordinal.enumOrd_strictMono is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (StrictMono.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (Ordinal.enumOrd.{u1} S))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28297 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28299 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28297 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28299) S) -> (StrictMono.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) (Ordinal.enumOrd.{u1} S))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_strict_mono Ordinal.enumOrd_strictMonoₓ'. -/
theorem enumOrd_strictMono (hS : Unbounded (· < ·) S) : StrictMono (enumOrd S) := fun _ _ h =>
  (lt_blsub.{u, u} _ _ h).trans_le (blsub_le_enumOrd hS _)
#align ordinal.enum_ord_strict_mono Ordinal.enumOrd_strictMono

/- warning: ordinal.enum_ord_def -> Ordinal.enumOrd_def is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}} (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S o) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toHasInf.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.conditionallyCompleteLinearOrderBot.{u1}))) (Inter.inter.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasInter.{succ u1} Ordinal.{u1}) S (setOf.{succ u1} Ordinal.{u1} (fun (b : Ordinal.{u1}) => forall (c : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.enumOrd.{u1} S c) b)))))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}} (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S o) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toInfSet.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{u1}))) (Inter.inter.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.instInterSet.{succ u1} Ordinal.{u1}) S (setOf.{succ u1} Ordinal.{u1} (fun (b : Ordinal.{u1}) => forall (c : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.enumOrd.{u1} S c) b)))))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_def Ordinal.enumOrd_defₓ'. -/
/-- A more workable definition for `enum_ord`. -/
theorem enumOrd_def (o) : enumOrd S o = infₛ (S ∩ { b | ∀ c, c < o → enumOrd S c < b }) :=
  by
  rw [enum_ord_def']
  congr ; ext
  exact ⟨fun h a hao => (lt_blsub.{u, u} _ _ hao).trans_le h, blsub_le⟩
#align ordinal.enum_ord_def Ordinal.enumOrd_def

/- warning: ordinal.enum_ord_def_nonempty -> Ordinal.enumOrd_def_nonempty is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (forall {o : Ordinal.{u1}}, Set.Nonempty.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (x : Ordinal.{u1}) => And (Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) x S) (forall (c : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.enumOrd.{u1} S c) x)))))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28438 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28440 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28438 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28440) S) -> (forall {o : Ordinal.{u1}}, Set.Nonempty.{succ u1} Ordinal.{u1} (setOf.{succ u1} Ordinal.{u1} (fun (x : Ordinal.{u1}) => And (Membership.mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.instMembershipSet.{succ u1} Ordinal.{u1}) x S) (forall (c : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c o) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.enumOrd.{u1} S c) x)))))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_def_nonempty Ordinal.enumOrd_def_nonemptyₓ'. -/
/-- The set in `enum_ord_def` is nonempty. -/
theorem enumOrd_def_nonempty (hS : Unbounded (· < ·) S) {o} :
    { x | x ∈ S ∧ ∀ c, c < o → enumOrd S c < x }.Nonempty :=
  ⟨_, enumOrd_mem hS o, fun _ b => enumOrd_strictMono hS b⟩
#align ordinal.enum_ord_def_nonempty Ordinal.enumOrd_def_nonempty

/- warning: ordinal.enum_ord_range -> Ordinal.enumOrd_range is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (StrictMono.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) f) -> (Eq.{succ (succ u1)} (Ordinal.{u1} -> Ordinal.{u1}) (Ordinal.enumOrd.{u1} (Set.range.{succ u1, succ (succ u1)} Ordinal.{u1} Ordinal.{u1} f)) f)
but is expected to have type
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (StrictMono.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) f) -> (Eq.{succ (succ u1)} (Ordinal.{u1} -> Ordinal.{u1}) (Ordinal.enumOrd.{u1} (Set.range.{succ u1, succ (succ u1)} Ordinal.{u1} Ordinal.{u1} f)) f)
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_range Ordinal.enumOrd_rangeₓ'. -/
@[simp]
theorem enumOrd_range {f : Ordinal → Ordinal} (hf : StrictMono f) : enumOrd (range f) = f :=
  funext fun o => by
    apply Ordinal.induction o
    intro a H
    rw [enum_ord_def a]
    have Hfa : f a ∈ range f ∩ { b | ∀ c, c < a → enum_ord (range f) c < b } :=
      ⟨mem_range_self a, fun b hb => by
        rw [H b hb]
        exact hf hb⟩
    refine' (cinfₛ_le' Hfa).antisymm ((le_cinfₛ_iff'' ⟨_, Hfa⟩).2 _)
    rintro _ ⟨⟨c, rfl⟩, hc : ∀ b < a, enum_ord (range f) b < f c⟩
    rw [hf.le_iff_le]
    contrapose! hc
    exact ⟨c, hc, (H c hc).ge⟩
#align ordinal.enum_ord_range Ordinal.enumOrd_range

#print Ordinal.enumOrd_univ /-
@[simp]
theorem enumOrd_univ : enumOrd Set.univ = id :=
  by
  rw [← range_id]
  exact enum_ord_range strictMono_id
#align ordinal.enum_ord_univ Ordinal.enumOrd_univ
-/

/- warning: ordinal.enum_ord_zero -> Ordinal.enumOrd_zero is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toHasInf.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.conditionallyCompleteLinearOrderBot.{u1}))) S)
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (InfSet.infₛ.{succ u1} Ordinal.{u1} (ConditionallyCompleteLattice.toInfSet.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrder.toConditionallyCompleteLattice.{succ u1} Ordinal.{u1} (ConditionallyCompleteLinearOrderBot.toConditionallyCompleteLinearOrder.{succ u1} Ordinal.{u1} Ordinal.instConditionallyCompleteLinearOrderBotOrdinal.{u1}))) S)
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_zero Ordinal.enumOrd_zeroₓ'. -/
@[simp]
theorem enumOrd_zero : enumOrd S 0 = infₛ S :=
  by
  rw [enum_ord_def]
  simp [Ordinal.not_lt_zero]
#align ordinal.enum_ord_zero Ordinal.enumOrd_zero

/- warning: ordinal.enum_ord_succ_le -> Ordinal.enumOrd_succ_le is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}} {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) a S) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.enumOrd.{u1} S b) a) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.enumOrd.{u1} S (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} b)) a)
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}} {a : Ordinal.{u1}} {b : Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28864 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28866 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28864 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28866) S) -> (Membership.mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.instMembershipSet.{succ u1} Ordinal.{u1}) a S) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.enumOrd.{u1} S b) a) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.enumOrd.{u1} S (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} b)) a)
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_succ_le Ordinal.enumOrd_succ_leₓ'. -/
theorem enumOrd_succ_le {a b} (hS : Unbounded (· < ·) S) (ha : a ∈ S) (hb : enumOrd S b < a) :
    enumOrd S (succ b) ≤ a := by
  rw [enum_ord_def]
  exact
    cinfₛ_le' ⟨ha, fun c hc => ((enum_ord_strict_mono hS).Monotone (le_of_lt_succ hc)).trans_lt hb⟩
#align ordinal.enum_ord_succ_le Ordinal.enumOrd_succ_le

/- warning: ordinal.enum_ord_le_of_subset -> Ordinal.enumOrd_le_of_subset is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}} {T : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (HasSubset.Subset.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasSubset.{succ u1} Ordinal.{u1}) S T) -> (forall (a : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Ordinal.enumOrd.{u1} T a) (Ordinal.enumOrd.{u1} S a))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}} {T : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28965 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28967 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28965 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.28967) S) -> (HasSubset.Subset.{succ u1} (Set.{succ u1} Ordinal.{u1}) (Set.instHasSubsetSet.{succ u1} Ordinal.{u1}) S T) -> (forall (a : Ordinal.{u1}), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Ordinal.enumOrd.{u1} T a) (Ordinal.enumOrd.{u1} S a))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_le_of_subset Ordinal.enumOrd_le_of_subsetₓ'. -/
theorem enumOrd_le_of_subset {S T : Set Ordinal} (hS : Unbounded (· < ·) S) (hST : S ⊆ T) (a) :
    enumOrd T a ≤ enumOrd S a := by
  apply Ordinal.induction a
  intro b H
  rw [enum_ord_def]
  exact cinfₛ_le' ⟨hST (enum_ord_mem hS b), fun c h => (H c h).trans_lt (enum_ord_strict_mono hS h)⟩
#align ordinal.enum_ord_le_of_subset Ordinal.enumOrd_le_of_subset

/- warning: ordinal.enum_ord_surjective -> Ordinal.enumOrd_surjective is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (forall (s : Ordinal.{u1}), (Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) s S) -> (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S a) s)))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29065 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29067 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29065 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29067) S) -> (forall (s : Ordinal.{u1}), (Membership.mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.instMembershipSet.{succ u1} Ordinal.{u1}) s S) -> (Exists.{succ (succ u1)} Ordinal.{u1} (fun (a : Ordinal.{u1}) => Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.enumOrd.{u1} S a) s)))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_surjective Ordinal.enumOrd_surjectiveₓ'. -/
theorem enumOrd_surjective (hS : Unbounded (· < ·) S) : ∀ s ∈ S, ∃ a, enumOrd S a = s := fun s hs =>
  ⟨supₛ { a | enumOrd S a ≤ s }, by
    apply le_antisymm
    · rw [enum_ord_def]
      refine' cinfₛ_le' ⟨hs, fun a ha => _⟩
      have : enum_ord S 0 ≤ s := by
        rw [enum_ord_zero]
        exact cinfₛ_le' hs
      rcases exists_lt_of_lt_csupₛ ⟨0, this⟩ ha with ⟨b, hb, hab⟩
      exact (enum_ord_strict_mono hS hab).trans_le hb
    · by_contra' h
      exact
        (le_csupₛ ⟨s, fun a => (lt_wf.self_le_of_strict_mono (enum_ord_strict_mono hS) a).trans⟩
              (enum_ord_succ_le hS hs h)).not_lt
          (lt_succ _)⟩
#align ordinal.enum_ord_surjective Ordinal.enumOrd_surjective

/- warning: ordinal.enum_ord_order_iso -> Ordinal.enumOrdOrderIso is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (OrderIso.{succ u1, succ u1} Ordinal.{u1} (coeSort.{succ (succ u1), succ (succ (succ u1))} (Set.{succ u1} Ordinal.{u1}) Type.{succ u1} (Set.hasCoeToSort.{succ u1} Ordinal.{u1}) S) (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Subtype.hasLe.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (fun (x : Ordinal.{u1}) => Membership.Mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.hasMem.{succ u1} Ordinal.{u1}) x S)))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29308 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29310 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29308 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29310) S) -> (OrderIso.{succ u1, succ u1} Ordinal.{u1} (Set.Elem.{succ u1} Ordinal.{u1} S) (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Subtype.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (fun (x : Ordinal.{u1}) => Membership.mem.{succ u1, succ u1} Ordinal.{u1} (Set.{succ u1} Ordinal.{u1}) (Set.instMembershipSet.{succ u1} Ordinal.{u1}) x S)))
Case conversion may be inaccurate. Consider using '#align ordinal.enum_ord_order_iso Ordinal.enumOrdOrderIsoₓ'. -/
/-- An order isomorphism between an unbounded set of ordinals and the ordinals. -/
def enumOrdOrderIso (hS : Unbounded (· < ·) S) : Ordinal ≃o S :=
  StrictMono.orderIsoOfSurjective (fun o => ⟨_, enumOrd_mem hS o⟩) (enumOrd_strictMono hS) fun s =>
    let ⟨a, ha⟩ := enumOrd_surjective hS s s.Prop
    ⟨a, Subtype.eq ha⟩
#align ordinal.enum_ord_order_iso Ordinal.enumOrdOrderIso

/- warning: ordinal.range_enum_ord -> Ordinal.range_enumOrd is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (Eq.{succ (succ u1)} (Set.{succ u1} Ordinal.{u1}) (Set.range.{succ u1, succ (succ u1)} Ordinal.{u1} Ordinal.{u1} (Ordinal.enumOrd.{u1} S)) S)
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}}, (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29395 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29397 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29395 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29397) S) -> (Eq.{succ (succ u1)} (Set.{succ u1} Ordinal.{u1}) (Set.range.{succ u1, succ (succ u1)} Ordinal.{u1} Ordinal.{u1} (Ordinal.enumOrd.{u1} S)) S)
Case conversion may be inaccurate. Consider using '#align ordinal.range_enum_ord Ordinal.range_enumOrdₓ'. -/
theorem range_enumOrd (hS : Unbounded (· < ·) S) : range (enumOrd S) = S :=
  by
  rw [range_eq_iff]
  exact ⟨enum_ord_mem hS, enum_ord_surjective hS⟩
#align ordinal.range_enum_ord Ordinal.range_enumOrd

/- warning: ordinal.eq_enum_ord -> Ordinal.eq_enumOrd is a dubious translation:
lean 3 declaration is
  forall {S : Set.{succ u1} Ordinal.{u1}} (f : Ordinal.{u1} -> Ordinal.{u1}), (Set.Unbounded.{succ u1} Ordinal.{u1} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}))) S) -> (Iff (And (StrictMono.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) f) (Eq.{succ (succ u1)} (Set.{succ u1} Ordinal.{u1}) (Set.range.{succ u1, succ (succ u1)} Ordinal.{u1} Ordinal.{u1} f) S)) (Eq.{succ (succ u1)} (Ordinal.{u1} -> Ordinal.{u1}) f (Ordinal.enumOrd.{u1} S)))
but is expected to have type
  forall {S : Set.{succ u1} Ordinal.{u1}} (f : Ordinal.{u1} -> Ordinal.{u1}), (Set.Unbounded.{succ u1} Ordinal.{u1} (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29467 : Ordinal.{u1}) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29469 : Ordinal.{u1}) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29467 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.29469) S) -> (Iff (And (StrictMono.{succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) f) (Eq.{succ (succ u1)} (Set.{succ u1} Ordinal.{u1}) (Set.range.{succ u1, succ (succ u1)} Ordinal.{u1} Ordinal.{u1} f) S)) (Eq.{succ (succ u1)} (Ordinal.{u1} -> Ordinal.{u1}) f (Ordinal.enumOrd.{u1} S)))
Case conversion may be inaccurate. Consider using '#align ordinal.eq_enum_ord Ordinal.eq_enumOrdₓ'. -/
/-- A characterization of `enum_ord`: it is the unique strict monotonic function with range `S`. -/
theorem eq_enumOrd (f : Ordinal → Ordinal) (hS : Unbounded (· < ·) S) :
    StrictMono f ∧ range f = S ↔ f = enumOrd S :=
  by
  constructor
  · rintro ⟨h₁, h₂⟩
    rwa [← lt_wf.eq_strict_mono_iff_eq_range h₁ (enum_ord_strict_mono hS), range_enum_ord hS]
  · rintro rfl
    exact ⟨enum_ord_strict_mono hS, range_enum_ord hS⟩
#align ordinal.eq_enum_ord Ordinal.eq_enumOrd

end

/-! ### Casting naturals into ordinals, compatibility with operations -/


/- warning: ordinal.one_add_nat_cast -> Ordinal.one_add_nat_cast is a dubious translation:
lean 3 declaration is
  forall (m : Nat), Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m)) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m))
but is expected to have type
  forall (m : Nat), Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m)) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) (Order.succ.{0} Nat (PartialOrder.toPreorder.{0} Nat (StrictOrderedSemiring.toPartialOrder.{0} Nat Nat.strictOrderedSemiring)) Nat.instSuccOrderNatToPreorderToPartialOrderStrictOrderedSemiring m))
Case conversion may be inaccurate. Consider using '#align ordinal.one_add_nat_cast Ordinal.one_add_nat_castₓ'. -/
@[simp]
theorem one_add_nat_cast (m : ℕ) : 1 + (m : Ordinal) = succ m :=
  by
  rw [← Nat.cast_one, ← Nat.cast_add, add_comm]
  rfl
#align ordinal.one_add_nat_cast Ordinal.one_add_nat_cast

/- warning: ordinal.nat_cast_mul -> Ordinal.nat_cast_mul is a dubious translation:
lean 3 declaration is
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) (HMul.hMul.{0, 0, 0} Nat Nat Nat (instHMul.{0} Nat Nat.hasMul) m n)) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))
but is expected to have type
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) (HMul.hMul.{0, 0, 0} Nat Nat Nat (instHMul.{0} Nat instMulNat) m n)) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_mul Ordinal.nat_cast_mulₓ'. -/
@[simp, norm_cast]
theorem nat_cast_mul (m : ℕ) : ∀ n : ℕ, ((m * n : ℕ) : Ordinal) = m * n
  | 0 => by simp
  | n + 1 => by rw [Nat.mul_succ, Nat.cast_add, nat_cast_mul, Nat.cast_succ, mul_add_one]
#align ordinal.nat_cast_mul Ordinal.nat_cast_mul

/- warning: ordinal.nat_cast_le -> Ordinal.nat_cast_le is a dubious translation:
lean 3 declaration is
  forall {m : Nat} {n : Nat}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n)) (LE.le.{0} Nat Nat.hasLe m n)
but is expected to have type
  forall {m : Nat} {n : Nat}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n)) (LE.le.{0} Nat instLENat m n)
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_le Ordinal.nat_cast_leₓ'. -/
@[simp, norm_cast]
theorem nat_cast_le {m n : ℕ} : (m : Ordinal) ≤ n ↔ m ≤ n := by
  rw [← Cardinal.ord_nat, ← Cardinal.ord_nat, Cardinal.ord_le_ord, Cardinal.natCast_le]
#align ordinal.nat_cast_le Ordinal.nat_cast_le

/- warning: ordinal.nat_cast_lt -> Ordinal.nat_cast_lt is a dubious translation:
lean 3 declaration is
  forall {m : Nat} {n : Nat}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n)) (LT.lt.{0} Nat Nat.hasLt m n)
but is expected to have type
  forall {m : Nat} {n : Nat}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n)) (LT.lt.{0} Nat instLTNat m n)
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_lt Ordinal.nat_cast_ltₓ'. -/
@[simp, norm_cast]
theorem nat_cast_lt {m n : ℕ} : (m : Ordinal) < n ↔ m < n := by
  simp only [lt_iff_le_not_le, nat_cast_le]
#align ordinal.nat_cast_lt Ordinal.nat_cast_lt

/- warning: ordinal.nat_cast_inj -> Ordinal.nat_cast_inj is a dubious translation:
lean 3 declaration is
  forall {m : Nat} {n : Nat}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n)) (Eq.{1} Nat m n)
but is expected to have type
  forall {m : Nat} {n : Nat}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n)) (Eq.{1} Nat m n)
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_inj Ordinal.nat_cast_injₓ'. -/
@[simp, norm_cast]
theorem nat_cast_inj {m n : ℕ} : (m : Ordinal) = n ↔ m = n := by
  simp only [le_antisymm_iff, nat_cast_le]
#align ordinal.nat_cast_inj Ordinal.nat_cast_inj

/- warning: ordinal.nat_cast_eq_zero -> Ordinal.nat_cast_eq_zero is a dubious translation:
lean 3 declaration is
  forall {n : Nat}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (Eq.{1} Nat n (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero))))
but is expected to have type
  forall {n : Nat}, Iff (Eq.{succ (succ u1)} Ordinal.{u1} (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (Eq.{1} Nat n (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_eq_zero Ordinal.nat_cast_eq_zeroₓ'. -/
@[simp, norm_cast]
theorem nat_cast_eq_zero {n : ℕ} : (n : Ordinal) = 0 ↔ n = 0 :=
  @nat_cast_inj n 0
#align ordinal.nat_cast_eq_zero Ordinal.nat_cast_eq_zero

/- warning: ordinal.nat_cast_ne_zero -> Ordinal.nat_cast_ne_zero is a dubious translation:
lean 3 declaration is
  forall {n : Nat}, Iff (Ne.{succ (succ u1)} Ordinal.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (Ne.{1} Nat n (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero))))
but is expected to have type
  forall {n : Nat}, Iff (Ne.{succ (succ u1)} Ordinal.{u1} (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (Ne.{1} Nat n (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)))
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_ne_zero Ordinal.nat_cast_ne_zeroₓ'. -/
theorem nat_cast_ne_zero {n : ℕ} : (n : Ordinal) ≠ 0 ↔ n ≠ 0 :=
  not_congr nat_cast_eq_zero
#align ordinal.nat_cast_ne_zero Ordinal.nat_cast_ne_zero

/- warning: ordinal.nat_cast_pos -> Ordinal.nat_cast_pos is a dubious translation:
lean 3 declaration is
  forall {n : Nat}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n)) (LT.lt.{0} Nat Nat.hasLt (OfNat.ofNat.{0} Nat 0 (OfNat.mk.{0} Nat 0 (Zero.zero.{0} Nat Nat.hasZero))) n)
but is expected to have type
  forall {n : Nat}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n)) (LT.lt.{0} Nat instLTNat (OfNat.ofNat.{0} Nat 0 (instOfNatNat 0)) n)
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_pos Ordinal.nat_cast_posₓ'. -/
@[simp, norm_cast]
theorem nat_cast_pos {n : ℕ} : (0 : Ordinal) < n ↔ 0 < n :=
  @nat_cast_lt 0 n
#align ordinal.nat_cast_pos Ordinal.nat_cast_pos

/- warning: ordinal.nat_cast_sub -> Ordinal.nat_cast_sub is a dubious translation:
lean 3 declaration is
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) (HSub.hSub.{0, 0, 0} Nat Nat Nat (instHSub.{0} Nat Nat.hasSub) m n)) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.hasSub.{u1}) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))
but is expected to have type
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) (HSub.hSub.{0, 0, 0} Nat Nat Nat (instHSub.{0} Nat instSubNat) m n)) (HSub.hSub.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHSub.{succ u1} Ordinal.{u1} Ordinal.instSubOrdinal.{u1}) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_sub Ordinal.nat_cast_subₓ'. -/
@[simp, norm_cast]
theorem nat_cast_sub (m n : ℕ) : ((m - n : ℕ) : Ordinal) = m - n :=
  by
  cases' le_total m n with h h
  · rw [tsub_eq_zero_iff_le.2 h, Ordinal.sub_eq_zero_iff_le.2 (nat_cast_le.2 h)]
    rfl
  · apply (add_left_cancel n).1
    rw [← Nat.cast_add, add_tsub_cancel_of_le h, Ordinal.add_sub_cancel_of_le (nat_cast_le.2 h)]
#align ordinal.nat_cast_sub Ordinal.nat_cast_sub

/- warning: ordinal.nat_cast_div -> Ordinal.nat_cast_div is a dubious translation:
lean 3 declaration is
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) (HDiv.hDiv.{0, 0, 0} Nat Nat Nat (instHDiv.{0} Nat Nat.hasDiv) m n)) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.hasDiv.{u1}) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))
but is expected to have type
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) (HDiv.hDiv.{0, 0, 0} Nat Nat Nat (instHDiv.{0} Nat Nat.instDivNat) m n)) (HDiv.hDiv.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHDiv.{succ u1} Ordinal.{u1} Ordinal.instDivOrdinal.{u1}) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_div Ordinal.nat_cast_divₓ'. -/
@[simp, norm_cast]
theorem nat_cast_div (m n : ℕ) : ((m / n : ℕ) : Ordinal) = m / n :=
  by
  rcases eq_or_ne n 0 with (rfl | hn)
  · simp
  · have hn' := nat_cast_ne_zero.2 hn
    apply le_antisymm
    · rw [le_div hn', ← nat_cast_mul, nat_cast_le, mul_comm]
      apply Nat.div_mul_le_self
    · rw [div_le hn', ← add_one_eq_succ, ← Nat.cast_succ, ← nat_cast_mul, nat_cast_lt, mul_comm, ←
        Nat.div_lt_iff_lt_mul (Nat.pos_of_ne_zero hn)]
      apply Nat.lt_succ_self
#align ordinal.nat_cast_div Ordinal.nat_cast_div

/- warning: ordinal.nat_cast_mod -> Ordinal.nat_cast_mod is a dubious translation:
lean 3 declaration is
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) (HMod.hMod.{0, 0, 0} Nat Nat Nat (instHMod.{0} Nat Nat.hasMod) m n)) (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.hasMod.{u1}) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) m) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))
but is expected to have type
  forall (m : Nat) (n : Nat), Eq.{succ (succ u1)} Ordinal.{u1} (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) (HMod.hMod.{0, 0, 0} Nat Nat Nat (instHMod.{0} Nat Nat.instModNat) m n)) (HMod.hMod.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMod.{succ u1} Ordinal.{u1} Ordinal.instModOrdinal.{u1}) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) m) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))
Case conversion may be inaccurate. Consider using '#align ordinal.nat_cast_mod Ordinal.nat_cast_modₓ'. -/
@[simp, norm_cast]
theorem nat_cast_mod (m n : ℕ) : ((m % n : ℕ) : Ordinal) = m % n := by
  rw [← add_left_cancel, div_add_mod, ← nat_cast_div, ← nat_cast_mul, ← Nat.cast_add,
    Nat.div_add_mod]
#align ordinal.nat_cast_mod Ordinal.nat_cast_mod

/- warning: ordinal.lift_nat_cast -> Ordinal.lift_nat_cast is a dubious translation:
lean 3 declaration is
  forall (n : Nat), Eq.{succ (succ (max u2 u1))} Ordinal.{max u2 u1} (Ordinal.lift.{u1, u2} ((fun (a : Type) (b : Type.{succ u2}) [self : HasLiftT.{1, succ (succ u2)} a b] => self.0) Nat Ordinal.{u2} (HasLiftT.mk.{1, succ (succ u2)} Nat Ordinal.{u2} (CoeTCₓ.coe.{1, succ (succ u2)} Nat Ordinal.{u2} (Nat.castCoe.{succ u2} Ordinal.{u2} (AddMonoidWithOne.toNatCast.{succ u2} Ordinal.{u2} Ordinal.addMonoidWithOne.{u2})))) n)) ((fun (a : Type) (b : Type.{succ (max u2 u1)}) [self : HasLiftT.{1, succ (succ (max u2 u1))} a b] => self.0) Nat Ordinal.{max u2 u1} (HasLiftT.mk.{1, succ (succ (max u2 u1))} Nat Ordinal.{max u2 u1} (CoeTCₓ.coe.{1, succ (succ (max u2 u1))} Nat Ordinal.{max u2 u1} (Nat.castCoe.{succ (max u2 u1)} Ordinal.{max u2 u1} (AddMonoidWithOne.toNatCast.{succ (max u2 u1)} Ordinal.{max u2 u1} Ordinal.addMonoidWithOne.{max u2 u1})))) n)
but is expected to have type
  forall (n : Nat), Eq.{max (succ (succ u1)) (succ (succ u2))} Ordinal.{max u2 u1} (Ordinal.lift.{u1, u2} (Nat.cast.{succ u2} Ordinal.{u2} (AddMonoidWithOne.toNatCast.{succ u2} Ordinal.{u2} Ordinal.instAddMonoidWithOneOrdinal.{u2}) n)) (Nat.cast.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} (AddMonoidWithOne.toNatCast.{max (succ u1) (succ u2)} Ordinal.{max u2 u1} Ordinal.instAddMonoidWithOneOrdinal.{max u1 u2}) n)
Case conversion may be inaccurate. Consider using '#align ordinal.lift_nat_cast Ordinal.lift_nat_castₓ'. -/
@[simp]
theorem lift_nat_cast : ∀ n : ℕ, lift.{u, v} n = n
  | 0 => by simp
  | n + 1 => by simp [lift_nat_cast n]
#align ordinal.lift_nat_cast Ordinal.lift_nat_cast

end Ordinal

/-! ### Properties of `omega` -/


namespace Cardinal

open Ordinal

#print Cardinal.ord_aleph0 /-
@[simp]
theorem ord_aleph0 : ord.{u} ℵ₀ = ω :=
  le_antisymm (ord_le.2 <| le_rfl) <|
    le_of_forall_lt fun o h =>
      by
      rcases Ordinal.lt_lift_iff.1 h with ⟨o, rfl, h'⟩
      rw [lt_ord, ← lift_card, ← lift_aleph0.{0, u}, lift_lt, ← typein_enum (· < ·) h']
      exact lt_aleph_0_iff_fintype.2 ⟨Set.fintypeLTNat _⟩
#align cardinal.ord_aleph_0 Cardinal.ord_aleph0
-/

/- warning: cardinal.add_one_of_aleph_0_le -> Cardinal.add_one_of_aleph0_le is a dubious translation:
lean 3 declaration is
  forall {c : Cardinal.{u1}}, (LE.le.{succ u1} Cardinal.{u1} Cardinal.hasLe.{u1} Cardinal.aleph0.{u1} c) -> (Eq.{succ (succ u1)} Cardinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Cardinal.{u1} Cardinal.{u1} Cardinal.{u1} (instHAdd.{succ u1} Cardinal.{u1} Cardinal.hasAdd.{u1}) c (OfNat.ofNat.{succ u1} Cardinal.{u1} 1 (OfNat.mk.{succ u1} Cardinal.{u1} 1 (One.one.{succ u1} Cardinal.{u1} Cardinal.hasOne.{u1})))) c)
but is expected to have type
  forall {c : Cardinal.{u1}}, (LE.le.{succ u1} Cardinal.{u1} Cardinal.instLECardinal.{u1} Cardinal.aleph0.{u1} c) -> (Eq.{succ (succ u1)} Cardinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Cardinal.{u1} Cardinal.{u1} Cardinal.{u1} (instHAdd.{succ u1} Cardinal.{u1} Cardinal.instAddCardinal.{u1}) c (OfNat.ofNat.{succ u1} Cardinal.{u1} 1 (One.toOfNat1.{succ u1} Cardinal.{u1} Cardinal.instOneCardinal.{u1}))) c)
Case conversion may be inaccurate. Consider using '#align cardinal.add_one_of_aleph_0_le Cardinal.add_one_of_aleph0_leₓ'. -/
@[simp]
theorem add_one_of_aleph0_le {c} (h : ℵ₀ ≤ c) : c + 1 = c :=
  by
  rw [add_comm, ← card_ord c, ← card_one, ← card_add, one_add_of_omega_le]
  rwa [← ord_aleph_0, ord_le_ord]
#align cardinal.add_one_of_aleph_0_le Cardinal.add_one_of_aleph0_le

end Cardinal

namespace Ordinal

/- warning: ordinal.lt_add_of_limit -> Ordinal.lt_add_of_limit is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} c) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b c)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (c' : Ordinal.{u1}) => Exists.{0} (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c' c) (fun (H : LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c' c) => LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b c')))))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} c) -> (Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b c)) (Exists.{succ (succ u1)} Ordinal.{u1} (fun (c' : Ordinal.{u1}) => And (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c' c) (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) a (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b c')))))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_add_of_limit Ordinal.lt_add_of_limitₓ'. -/
theorem lt_add_of_limit {a b c : Ordinal.{u}} (h : IsLimit c) : a < b + c ↔ ∃ c' < c, a < b + c' :=
  by rw [← IsNormal.bsup_eq.{u, u} (add_is_normal b) h, lt_bsup]
#align ordinal.lt_add_of_limit Ordinal.lt_add_of_limit

/- warning: ordinal.lt_omega -> Ordinal.lt_omega is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) o Ordinal.omega.{u1}) (Exists.{1} Nat (fun (n : Nat) => Eq.{succ (succ u1)} Ordinal.{u1} o ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n)))
but is expected to have type
  forall {o : Ordinal.{u1}}, Iff (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) o Ordinal.omega.{u1}) (Exists.{1} Nat (fun (n : Nat) => Eq.{succ (succ u1)} Ordinal.{u1} o (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n)))
Case conversion may be inaccurate. Consider using '#align ordinal.lt_omega Ordinal.lt_omegaₓ'. -/
theorem lt_omega {o : Ordinal} : o < ω ↔ ∃ n : ℕ, o = n := by
  simp_rw [← Cardinal.ord_aleph0, Cardinal.lt_ord, lt_aleph_0, card_eq_nat]
#align ordinal.lt_omega Ordinal.lt_omega

/- warning: ordinal.nat_lt_omega -> Ordinal.nat_lt_omega is a dubious translation:
lean 3 declaration is
  forall (n : Nat), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n) Ordinal.omega.{u1}
but is expected to have type
  forall (n : Nat), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n) Ordinal.omega.{u1}
Case conversion may be inaccurate. Consider using '#align ordinal.nat_lt_omega Ordinal.nat_lt_omegaₓ'. -/
theorem nat_lt_omega (n : ℕ) : ↑n < ω :=
  lt_omega.2 ⟨_, rfl⟩
#align ordinal.nat_lt_omega Ordinal.nat_lt_omega

/- warning: ordinal.omega_pos -> Ordinal.omega_pos is a dubious translation:
lean 3 declaration is
  LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) Ordinal.omega.{u1}
but is expected to have type
  LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) Ordinal.omega.{u1}
Case conversion may be inaccurate. Consider using '#align ordinal.omega_pos Ordinal.omega_posₓ'. -/
theorem omega_pos : 0 < ω :=
  nat_lt_omega 0
#align ordinal.omega_pos Ordinal.omega_pos

#print Ordinal.omega_ne_zero /-
theorem omega_ne_zero : ω ≠ 0 :=
  omega_pos.ne'
#align ordinal.omega_ne_zero Ordinal.omega_ne_zero
-/

/- warning: ordinal.one_lt_omega -> Ordinal.one_lt_omega is a dubious translation:
lean 3 declaration is
  LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (OfNat.mk.{succ u1} Ordinal.{u1} 1 (One.one.{succ u1} Ordinal.{u1} Ordinal.hasOne.{u1}))) Ordinal.omega.{u1}
but is expected to have type
  LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 1 (One.toOfNat1.{succ u1} Ordinal.{u1} Ordinal.instOneOrdinal.{u1})) Ordinal.omega.{u1}
Case conversion may be inaccurate. Consider using '#align ordinal.one_lt_omega Ordinal.one_lt_omegaₓ'. -/
theorem one_lt_omega : 1 < ω := by simpa only [Nat.cast_one] using nat_lt_omega 1
#align ordinal.one_lt_omega Ordinal.one_lt_omega

#print Ordinal.omega_isLimit /-
theorem omega_isLimit : IsLimit ω :=
  ⟨omega_ne_zero, fun o h => by
    let ⟨n, e⟩ := lt_omega.1 h
    rw [e] <;> exact nat_lt_omega (n + 1)⟩
#align ordinal.omega_is_limit Ordinal.omega_isLimit
-/

/- warning: ordinal.omega_le -> Ordinal.omega_le is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) Ordinal.omega.{u1} o) (forall (n : Nat), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, Iff (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) Ordinal.omega.{u1} o) (forall (n : Nat), LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n) o)
Case conversion may be inaccurate. Consider using '#align ordinal.omega_le Ordinal.omega_leₓ'. -/
theorem omega_le {o : Ordinal} : ω ≤ o ↔ ∀ n : ℕ, ↑n ≤ o :=
  ⟨fun h n => (nat_lt_omega _).le.trans h, fun H =>
    le_of_forall_lt fun a h => by
      let ⟨n, e⟩ := lt_omega.1 h
      rw [e, ← succ_le_iff] <;> exact H (n + 1)⟩
#align ordinal.omega_le Ordinal.omega_le

/- warning: ordinal.sup_nat_cast -> Ordinal.sup_nat_cast is a dubious translation:
lean 3 declaration is
  Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1}))) Ordinal.omega.{u1}
but is expected to have type
  Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}))) Ordinal.omega.{u1}
Case conversion may be inaccurate. Consider using '#align ordinal.sup_nat_cast Ordinal.sup_nat_castₓ'. -/
@[simp]
theorem sup_nat_cast : sup Nat.cast = ω :=
  (sup_le fun n => (nat_lt_omega n).le).antisymm <| omega_le.2 <| le_sup _
#align ordinal.sup_nat_cast Ordinal.sup_nat_cast

/- warning: ordinal.nat_lt_limit -> Ordinal.nat_lt_limit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall (n : Nat), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n) o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (forall (n : Nat), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n) o)
Case conversion may be inaccurate. Consider using '#align ordinal.nat_lt_limit Ordinal.nat_lt_limitₓ'. -/
theorem nat_lt_limit {o} (h : IsLimit o) : ∀ n : ℕ, ↑n < o
  | 0 => lt_of_le_of_ne (Ordinal.zero_le o) h.1.symm
  | n + 1 => h.2 _ (nat_lt_limit n)
#align ordinal.nat_lt_limit Ordinal.nat_lt_limit

/- warning: ordinal.omega_le_of_is_limit -> Ordinal.omega_le_of_isLimit is a dubious translation:
lean 3 declaration is
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) Ordinal.omega.{u1} o)
but is expected to have type
  forall {o : Ordinal.{u1}}, (Ordinal.IsLimit.{u1} o) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) Ordinal.omega.{u1} o)
Case conversion may be inaccurate. Consider using '#align ordinal.omega_le_of_is_limit Ordinal.omega_le_of_isLimitₓ'. -/
theorem omega_le_of_isLimit {o} (h : IsLimit o) : ω ≤ o :=
  omega_le.2 fun n => le_of_lt <| nat_lt_limit h n
#align ordinal.omega_le_of_is_limit Ordinal.omega_le_of_isLimit

/- warning: ordinal.is_limit_iff_omega_dvd -> Ordinal.isLimit_iff_omega_dvd is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}}, Iff (Ordinal.IsLimit.{u1} a) (And (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1})))) (Dvd.Dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1}))) Ordinal.omega.{u1} a))
but is expected to have type
  forall {a : Ordinal.{u1}}, Iff (Ordinal.IsLimit.{u1} a) (And (Ne.{succ (succ u1)} Ordinal.{u1} a (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1}))) (Dvd.dvd.{succ u1} Ordinal.{u1} (semigroupDvd.{succ u1} Ordinal.{u1} (SemigroupWithZero.toSemigroup.{succ u1} Ordinal.{u1} (MonoidWithZero.toSemigroupWithZero.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1}))) Ordinal.omega.{u1} a))
Case conversion may be inaccurate. Consider using '#align ordinal.is_limit_iff_omega_dvd Ordinal.isLimit_iff_omega_dvdₓ'. -/
theorem isLimit_iff_omega_dvd {a : Ordinal} : IsLimit a ↔ a ≠ 0 ∧ ω ∣ a :=
  by
  refine' ⟨fun l => ⟨l.1, ⟨a / ω, le_antisymm _ (mul_div_le _ _)⟩⟩, fun h => _⟩
  · refine' (limit_le l).2 fun x hx => le_of_lt _
    rw [← div_lt omega_ne_zero, ← succ_le_iff, le_div omega_ne_zero, mul_succ,
      add_le_of_limit omega_is_limit]
    intro b hb
    rcases lt_omega.1 hb with ⟨n, rfl⟩
    exact
      (add_le_add_right (mul_div_le _ _) _).trans
        (lt_sub.1 <| nat_lt_limit (sub_is_limit l hx) _).le
  · rcases h with ⟨a0, b, rfl⟩
    refine' mul_is_limit_left omega_is_limit (Ordinal.pos_iff_ne_zero.2 <| mt _ a0)
    intro e
    simp only [e, mul_zero]
#align ordinal.is_limit_iff_omega_dvd Ordinal.isLimit_iff_omega_dvd

/- warning: ordinal.add_mul_limit_aux -> Ordinal.add_mul_limit_aux is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b a) a) -> (Ordinal.IsLimit.{u1} c) -> (forall (c' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) c' c) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} c')) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} c')) b))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) c) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a c))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b a) a) -> (Ordinal.IsLimit.{u1} c) -> (forall (c' : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) c' c) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} c')) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} c')) b))) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) c) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a c))
Case conversion may be inaccurate. Consider using '#align ordinal.add_mul_limit_aux Ordinal.add_mul_limit_auxₓ'. -/
theorem add_mul_limit_aux {a b c : Ordinal} (ba : b + a = a) (l : IsLimit c)
    (IH : ∀ c' < c, (a + b) * succ c' = a * succ c' + b) : (a + b) * c = a * c :=
  le_antisymm
    ((mul_le_of_limit l).2 fun c' h =>
      by
      apply (mul_le_mul_left' (le_succ c') _).trans
      rw [IH _ h]
      apply (add_le_add_left _ _).trans
      · rw [← mul_succ]
        exact mul_le_mul_left' (succ_le_of_lt <| l.2 _ h) _
      · infer_instance
      · rw [← ba]
        exact le_add_right _ _)
    (mul_le_mul_right' (le_add_right _ _) _)
#align ordinal.add_mul_limit_aux Ordinal.add_mul_limit_aux

/- warning: ordinal.add_mul_succ -> Ordinal.add_mul_succ is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} (c : Ordinal.{u1}), (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b a) a) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} c)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} c)) b))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} (c : Ordinal.{u1}), (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b a) a) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} c)) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a (Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} c)) b))
Case conversion may be inaccurate. Consider using '#align ordinal.add_mul_succ Ordinal.add_mul_succₓ'. -/
theorem add_mul_succ {a b : Ordinal} (c) (ba : b + a = a) : (a + b) * succ c = a * succ c + b :=
  by
  apply limit_rec_on c
  · simp only [succ_zero, mul_one]
  · intro c IH
    rw [mul_succ, IH, ← add_assoc, add_assoc _ b, ba, ← mul_succ]
  · intro c l IH
    have := add_mul_limit_aux ba l IH
    rw [mul_succ, add_mul_limit_aux ba l IH, mul_succ, add_assoc]
#align ordinal.add_mul_succ Ordinal.add_mul_succ

/- warning: ordinal.add_mul_limit -> Ordinal.add_mul_limit is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) b a) a) -> (Ordinal.IsLimit.{u1} c) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) c) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) a c))
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (Eq.{succ (succ u1)} Ordinal.{u1} (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) b a) a) -> (Ordinal.IsLimit.{u1} c) -> (Eq.{succ (succ u1)} Ordinal.{u1} (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) c) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) a c))
Case conversion may be inaccurate. Consider using '#align ordinal.add_mul_limit Ordinal.add_mul_limitₓ'. -/
theorem add_mul_limit {a b c : Ordinal} (ba : b + a = a) (l : IsLimit c) : (a + b) * c = a * c :=
  add_mul_limit_aux ba l fun c' _ => add_mul_succ c' ba
#align ordinal.add_mul_limit Ordinal.add_mul_limit

/- warning: ordinal.add_le_of_forall_add_lt -> Ordinal.add_le_of_forall_add_lt is a dubious translation:
lean 3 declaration is
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (OfNat.mk.{succ u1} Ordinal.{u1} 0 (Zero.zero.{succ u1} Ordinal.{u1} Ordinal.hasZero.{u1}))) b) -> (forall (d : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) d b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a d) c)) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) a b) c)
but is expected to have type
  forall {a : Ordinal.{u1}} {b : Ordinal.{u1}} {c : Ordinal.{u1}}, (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (OfNat.ofNat.{succ u1} Ordinal.{u1} 0 (Zero.toOfNat0.{succ u1} Ordinal.{u1} Ordinal.instZeroOrdinal.{u1})) b) -> (forall (d : Ordinal.{u1}), (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) d b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a d) c)) -> (LE.le.{succ u1} Ordinal.{u1} (Preorder.toLE.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) a b) c)
Case conversion may be inaccurate. Consider using '#align ordinal.add_le_of_forall_add_lt Ordinal.add_le_of_forall_add_ltₓ'. -/
theorem add_le_of_forall_add_lt {a b c : Ordinal} (hb : 0 < b) (h : ∀ d < b, a + d < c) :
    a + b ≤ c :=
  by
  have H : a + (c - a) = c :=
    Ordinal.add_sub_cancel_of_le
      (by
        rw [← add_zero a]
        exact (h _ hb).le)
  rw [← H]
  apply add_le_add_left _ a
  by_contra' hb
  exact (h _ hb).Ne H
#align ordinal.add_le_of_forall_add_lt Ordinal.add_le_of_forall_add_lt

/- warning: ordinal.is_normal.apply_omega -> Ordinal.IsNormal.apply_omega is a dubious translation:
lean 3 declaration is
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (Function.comp.{1, succ (succ u1), succ (succ u1)} Nat Ordinal.{u1} Ordinal.{u1} f (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) (f Ordinal.omega.{u1}))
but is expected to have type
  forall {f : Ordinal.{u1} -> Ordinal.{u1}}, (Ordinal.IsNormal.{u1, u1} f) -> (Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (Function.comp.{1, succ (succ u1), succ (succ u1)} Nat Ordinal.{u1} Ordinal.{u1} f (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1})))) (f Ordinal.omega.{u1}))
Case conversion may be inaccurate. Consider using '#align ordinal.is_normal.apply_omega Ordinal.IsNormal.apply_omegaₓ'. -/
theorem IsNormal.apply_omega {f : Ordinal.{u} → Ordinal.{u}} (hf : IsNormal f) :
    sup.{0, u} (f ∘ Nat.cast) = f ω := by rw [← sup_nat_cast, IsNormal.sup.{0, u, u} hf]
#align ordinal.is_normal.apply_omega Ordinal.IsNormal.apply_omega

/- warning: ordinal.sup_add_nat -> Ordinal.sup_add_nat is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (fun (n : Nat) => HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) o ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.hasAdd.{u1}) o Ordinal.omega.{u1})
but is expected to have type
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (fun (n : Nat) => HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) o (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))) (HAdd.hAdd.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHAdd.{succ u1} Ordinal.{u1} Ordinal.instAddOrdinal.{u1}) o Ordinal.omega.{u1})
Case conversion may be inaccurate. Consider using '#align ordinal.sup_add_nat Ordinal.sup_add_natₓ'. -/
@[simp]
theorem sup_add_nat (o : Ordinal) : (sup fun n : ℕ => o + n) = o + ω :=
  (add_isNormal o).apply_omega
#align ordinal.sup_add_nat Ordinal.sup_add_nat

/- warning: ordinal.sup_mul_nat -> Ordinal.sup_mul_nat is a dubious translation:
lean 3 declaration is
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (fun (n : Nat) => HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) o ((fun (a : Type) (b : Type.{succ u1}) [self : HasLiftT.{1, succ (succ u1)} a b] => self.0) Nat Ordinal.{u1} (HasLiftT.mk.{1, succ (succ u1)} Nat Ordinal.{u1} (CoeTCₓ.coe.{1, succ (succ u1)} Nat Ordinal.{u1} (Nat.castCoe.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.addMonoidWithOne.{u1})))) n))) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toHasMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.monoidWithZero.{u1})))) o Ordinal.omega.{u1})
but is expected to have type
  forall (o : Ordinal.{u1}), Eq.{succ (succ u1)} Ordinal.{u1} (Ordinal.sup.{0, u1} Nat (fun (n : Nat) => HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) o (Nat.cast.{succ u1} Ordinal.{u1} (AddMonoidWithOne.toNatCast.{succ u1} Ordinal.{u1} Ordinal.instAddMonoidWithOneOrdinal.{u1}) n))) (HMul.hMul.{succ u1, succ u1, succ u1} Ordinal.{u1} Ordinal.{u1} Ordinal.{u1} (instHMul.{succ u1} Ordinal.{u1} (MulZeroClass.toMul.{succ u1} Ordinal.{u1} (MulZeroOneClass.toMulZeroClass.{succ u1} Ordinal.{u1} (MonoidWithZero.toMulZeroOneClass.{succ u1} Ordinal.{u1} Ordinal.instMonoidWithZeroOrdinal.{u1})))) o Ordinal.omega.{u1})
Case conversion may be inaccurate. Consider using '#align ordinal.sup_mul_nat Ordinal.sup_mul_natₓ'. -/
@[simp]
theorem sup_mul_nat (o : Ordinal) : (sup fun n : ℕ => o * n) = o * ω :=
  by
  rcases eq_zero_or_pos o with (rfl | ho)
  · rw [zero_mul]
    exact sup_eq_zero_iff.2 fun n => zero_mul n
  · exact (mul_is_normal ho).apply_omega
#align ordinal.sup_mul_nat Ordinal.sup_mul_nat

end Ordinal

variable {α : Type u} {r : α → α → Prop} {a b : α}

namespace Acc

#print Acc.rank /-
/-- The rank of an element `a` accessible under a relation `r` is defined inductively as the
smallest ordinal greater than the ranks of all elements below it (i.e. elements `b` such that
`r b a`). -/
noncomputable def rank (h : Acc r a) : Ordinal.{u} :=
  Acc.recOn h fun a h ih => Ordinal.sup.{u, u} fun b : { b // r b a } => Order.succ <| ih b b.2
#align acc.rank Acc.rank
-/

/- warning: acc.rank_eq -> Acc.rank_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} (h : Acc.{succ u1} α r a), Eq.{succ (succ u1)} Ordinal.{u1} (Acc.rank.{u1} α r a h) (Ordinal.sup.{u1, u1} (Subtype.{succ u1} α (fun (b : α) => r b a)) (fun (b : Subtype.{succ u1} α (fun (b : α) => r b a)) => Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} (Acc.rank.{u1} α r (Subtype.val.{succ u1} α (fun (b : α) => r b a) b) (Acc.inv.{succ u1} α r a (Subtype.val.{succ u1} α (fun (b : α) => r b a) b) h (Subtype.property.{succ u1} α (fun (b : α) => r b a) b)))))
but is expected to have type
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} (h : Acc.{succ u1} α r a), Eq.{succ (succ u1)} Ordinal.{u1} (Acc.rank.{u1} α r a h) (Ordinal.sup.{u1, u1} (Subtype.{succ u1} α (fun (b : α) => r b a)) (fun (b : Subtype.{succ u1} α (fun (b : α) => r b a)) => Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} (Acc.rank.{u1} α r (Subtype.val.{succ u1} α (fun (b : α) => r b a) b) (Acc.inv.{succ u1} α r a (Subtype.val.{succ u1} α (fun (b : α) => r b a) b) h (Subtype.property.{succ u1} α (fun (b : α) => r b a) b)))))
Case conversion may be inaccurate. Consider using '#align acc.rank_eq Acc.rank_eqₓ'. -/
theorem rank_eq (h : Acc r a) :
    h.rank = Ordinal.sup.{u, u} fun b : { b // r b a } => Order.succ (h.inv b.2).rank :=
  by
  change (Acc.intro a fun _ => h.inv).rank = _
  rfl
#align acc.rank_eq Acc.rank_eq

/- warning: acc.rank_lt_of_rel -> Acc.rank_lt_of_rel is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} {b : α} (hb : Acc.{succ u1} α r b) (h : r a b), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (Acc.rank.{u1} α r a (Acc.inv.{succ u1} α r b a hb h)) (Acc.rank.{u1} α r b hb)
but is expected to have type
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} {b : α} (hb : Acc.{succ u1} α r b) (h : r a b), LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (Acc.rank.{u1} α r a (Acc.inv.{succ u1} α r b a hb h)) (Acc.rank.{u1} α r b hb)
Case conversion may be inaccurate. Consider using '#align acc.rank_lt_of_rel Acc.rank_lt_of_relₓ'. -/
/-- if `r a b` then the rank of `a` is less than the rank of `b`. -/
theorem rank_lt_of_rel (hb : Acc r b) (h : r a b) : (hb.inv h).rank < hb.rank :=
  (Order.lt_succ _).trans_le <| by
    rw [hb.rank_eq]
    refine' le_trans _ (Ordinal.le_sup _ ⟨a, h⟩)
    rfl
#align acc.rank_lt_of_rel Acc.rank_lt_of_rel

end Acc

namespace WellFounded

variable (hwf : WellFounded r)

include hwf

#print WellFounded.rank /-
/-- The rank of an element `a` under a well-founded relation `r` is defined inductively as the
smallest ordinal greater than the ranks of all elements below it (i.e. elements `b` such that
`r b a`). -/
noncomputable def rank (a : α) : Ordinal.{u} :=
  (hwf.apply a).rank
#align well_founded.rank WellFounded.rank
-/

/- warning: well_founded.rank_eq -> WellFounded.rank_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} (hwf : WellFounded.{succ u1} α r), Eq.{succ (succ u1)} Ordinal.{u1} (WellFounded.rank.{u1} α r hwf a) (Ordinal.sup.{u1, u1} (Subtype.{succ u1} α (fun (b : α) => r b a)) (fun (b : Subtype.{succ u1} α (fun (b : α) => r b a)) => Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) Ordinal.succOrder.{u1} (WellFounded.rank.{u1} α r hwf ((fun (a : Type.{u1}) (b : Type.{u1}) [self : HasLiftT.{succ u1, succ u1} a b] => self.0) (Subtype.{succ u1} α (fun (b : α) => r b a)) α (HasLiftT.mk.{succ u1, succ u1} (Subtype.{succ u1} α (fun (b : α) => r b a)) α (CoeTCₓ.coe.{succ u1, succ u1} (Subtype.{succ u1} α (fun (b : α) => r b a)) α (coeBase.{succ u1, succ u1} (Subtype.{succ u1} α (fun (b : α) => r b a)) α (coeSubtype.{succ u1} α (fun (b : α) => r b a))))) b))))
but is expected to have type
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} (hwf : WellFounded.{succ u1} α r), Eq.{succ (succ u1)} Ordinal.{u1} (WellFounded.rank.{u1} α r hwf a) (Ordinal.sup.{u1, u1} (Subtype.{succ u1} α (fun (b : α) => r b a)) (fun (b : Subtype.{succ u1} α (fun (b : α) => r b a)) => Order.succ.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) Ordinal.instSuccOrderOrdinalToPreorderInstPartialOrderOrdinal.{u1} (WellFounded.rank.{u1} α r hwf (Subtype.val.{succ u1} α (fun (b : α) => r b a) b))))
Case conversion may be inaccurate. Consider using '#align well_founded.rank_eq WellFounded.rank_eqₓ'. -/
theorem rank_eq :
    hwf.rank a = Ordinal.sup.{u, u} fun b : { b // r b a } => Order.succ <| hwf.rank b :=
  by
  rw [rank, Acc.rank_eq]
  rfl
#align well_founded.rank_eq WellFounded.rank_eq

/- warning: well_founded.rank_lt_of_rel -> WellFounded.rank_lt_of_rel is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} {b : α} (hwf : WellFounded.{succ u1} α r), (r a b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1})) (WellFounded.rank.{u1} α r hwf a) (WellFounded.rank.{u1} α r hwf b))
but is expected to have type
  forall {α : Type.{u1}} {r : α -> α -> Prop} {a : α} {b : α} (hwf : WellFounded.{succ u1} α r), (r a b) -> (LT.lt.{succ u1} Ordinal.{u1} (Preorder.toLT.{succ u1} Ordinal.{u1} (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1})) (WellFounded.rank.{u1} α r hwf a) (WellFounded.rank.{u1} α r hwf b))
Case conversion may be inaccurate. Consider using '#align well_founded.rank_lt_of_rel WellFounded.rank_lt_of_relₓ'. -/
theorem rank_lt_of_rel (h : r a b) : hwf.rank a < hwf.rank b :=
  Acc.rank_lt_of_rel _ h
#align well_founded.rank_lt_of_rel WellFounded.rank_lt_of_rel

omit hwf

/- warning: well_founded.rank_strict_mono -> WellFounded.rank_strictMono is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Preorder.{u1} α] [_inst_2 : WellFoundedLT.{u1} α (Preorder.toLT.{u1} α _inst_1)], StrictMono.{u1, succ u1} α Ordinal.{u1} _inst_1 (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (WellFounded.rank.{u1} α (LT.lt.{u1} α (Preorder.toLT.{u1} α _inst_1)) (IsWellFounded.wf.{u1} α (LT.lt.{u1} α (Preorder.toLT.{u1} α _inst_1)) _inst_2))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Preorder.{u1} α] [_inst_2 : WellFoundedLT.{u1} α (Preorder.toLT.{u1} α _inst_1)], StrictMono.{u1, succ u1} α Ordinal.{u1} _inst_1 (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) (WellFounded.rank.{u1} α (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36892 : α) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36894 : α) => LT.lt.{u1} α (Preorder.toLT.{u1} α _inst_1) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36892 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36894) (IsWellFounded.wf.{u1} α (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36892 : α) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36894 : α) => LT.lt.{u1} α (Preorder.toLT.{u1} α _inst_1) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36892 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36894) _inst_2))
Case conversion may be inaccurate. Consider using '#align well_founded.rank_strict_mono WellFounded.rank_strictMonoₓ'. -/
theorem rank_strictMono [Preorder α] [WellFoundedLT α] :
    StrictMono (rank <| @IsWellFounded.wf α (· < ·) _) := fun _ _ => rank_lt_of_rel _
#align well_founded.rank_strict_mono WellFounded.rank_strictMono

/- warning: well_founded.rank_strict_anti -> WellFounded.rank_strictAnti is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : Preorder.{u1} α] [_inst_2 : WellFoundedGT.{u1} α (Preorder.toLT.{u1} α _inst_1)], StrictAnti.{u1, succ u1} α Ordinal.{u1} _inst_1 (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.partialOrder.{u1}) (WellFounded.rank.{u1} α (GT.gt.{u1} α (Preorder.toLT.{u1} α _inst_1)) (IsWellFounded.wf.{u1} α (GT.gt.{u1} α (Preorder.toLT.{u1} α _inst_1)) _inst_2))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : Preorder.{u1} α] [_inst_2 : WellFoundedGT.{u1} α (Preorder.toLT.{u1} α _inst_1)], StrictAnti.{u1, succ u1} α Ordinal.{u1} _inst_1 (PartialOrder.toPreorder.{succ u1} Ordinal.{u1} Ordinal.instPartialOrderOrdinal.{u1}) (WellFounded.rank.{u1} α (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36941 : α) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36943 : α) => GT.gt.{u1} α (Preorder.toLT.{u1} α _inst_1) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36941 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36943) (IsWellFounded.wf.{u1} α (fun (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36941 : α) (x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36943 : α) => GT.gt.{u1} α (Preorder.toLT.{u1} α _inst_1) x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36941 x._@.Mathlib.SetTheory.Ordinal.Arithmetic._hyg.36943) _inst_2))
Case conversion may be inaccurate. Consider using '#align well_founded.rank_strict_anti WellFounded.rank_strictAntiₓ'. -/
theorem rank_strictAnti [Preorder α] [WellFoundedGT α] :
    StrictAnti (rank <| @IsWellFounded.wf α (· > ·) _) := fun _ _ =>
  rank_lt_of_rel <| @IsWellFounded.wf α (· > ·) _
#align well_founded.rank_strict_anti WellFounded.rank_strictAnti

end WellFounded

