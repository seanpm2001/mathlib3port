/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Floris van Doorn, Violeta Hernández Palacios

! This file was ported from Lean 3 source module set_theory.ordinal.arithmetic
! leanprover-community/mathlib commit e08a42b2dd544cf11eba72e5fc7bf199d4349925
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.SetTheory.Ordinal.Basic
import Mathbin.Tactic.ByContra

/-!
# Ordinal arithmetic

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

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

open scoped Classical Cardinal Ordinal

universe u v w

namespace Ordinal

variable {α : Type _} {β : Type _} {γ : Type _} {r : α → α → Prop} {s : β → β → Prop}
  {t : γ → γ → Prop}

/-! ### Further properties of addition on ordinals -/


#print Ordinal.lift_add /-
@[simp]
theorem lift_add (a b) : lift (a + b) = lift a + lift b :=
  Quotient.induction_on₂ a b fun ⟨α, r, _⟩ ⟨β, s, _⟩ =>
    Quotient.sound
      ⟨(RelIso.preimage Equiv.ulift _).trans
          (RelIso.sumLexCongr (RelIso.preimage Equiv.ulift _) (RelIso.preimage Equiv.ulift _)).symm⟩
#align ordinal.lift_add Ordinal.lift_add
-/

#print Ordinal.lift_succ /-
@[simp]
theorem lift_succ (a) : lift (succ a) = succ (lift a) := by
  rw [← add_one_eq_succ, lift_add, lift_one]; rfl
#align ordinal.lift_succ Ordinal.lift_succ
-/

#print Ordinal.add_contravariantClass_le /-
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
              · rw [← fl] at e ; have := f.inj' e; contradiction
              · exact ⟨_, rfl⟩
            let g (b) := (this b).1
            have fr : ∀ b, f (Sum.inr b) = Sum.inr (g b) := fun b => (this b).2
            ⟨⟨⟨g, fun x y h => by
                  injection f.inj' (by rw [fr, fr, h] : f (Sum.inr x) = f (Sum.inr y))⟩,
                fun a b => by
                simpa only [Sum.lex_inr_inr, fr, RelEmbedding.coe_toEmbedding,
                  InitialSeg.coeFn_toRelEmbedding, embedding.coe_fn_mk] using
                  @RelEmbedding.map_rel_iff _ _ _ _ f.to_rel_embedding (Sum.inr a) (Sum.inr b)⟩,
              fun a b H =>
              by
              rcases f.init (by rw [fr] <;> exact Sum.lex_inr_inr.2 H) with ⟨a' | a', h⟩
              · rw [fl] at h ; cases h
              · rw [fr] at h ; exact ⟨a', Sum.inr.inj h⟩⟩⟩⟩
#align ordinal.add_contravariant_class_le Ordinal.add_contravariantClass_le
-/

#print Ordinal.add_left_cancel /-
theorem add_left_cancel (a) {b c : Ordinal} : a + b = a + c ↔ b = c := by
  simp only [le_antisymm_iff, add_le_add_iff_left]
#align ordinal.add_left_cancel Ordinal.add_left_cancel
-/

private theorem add_lt_add_iff_left' (a) {b c : Ordinal} : a + b < a + c ↔ b < c := by
  rw [← not_le, ← not_le, add_le_add_iff_left]

#print Ordinal.add_covariantClass_lt /-
instance add_covariantClass_lt : CovariantClass Ordinal.{u} Ordinal.{u} (· + ·) (· < ·) :=
  ⟨fun a b c => (add_lt_add_iff_left' a).2⟩
#align ordinal.add_covariant_class_lt Ordinal.add_covariantClass_lt
-/

#print Ordinal.add_contravariantClass_lt /-
instance add_contravariantClass_lt : ContravariantClass Ordinal.{u} Ordinal.{u} (· + ·) (· < ·) :=
  ⟨fun a b c => (add_lt_add_iff_left' a).1⟩
#align ordinal.add_contravariant_class_lt Ordinal.add_contravariantClass_lt
-/

#print Ordinal.add_swap_contravariantClass_lt /-
instance add_swap_contravariantClass_lt :
    ContravariantClass Ordinal.{u} Ordinal.{u} (swap (· + ·)) (· < ·) :=
  ⟨fun a b c => lt_imp_lt_of_le_imp_le fun h => add_le_add_right h _⟩
#align ordinal.add_swap_contravariant_class_lt Ordinal.add_swap_contravariantClass_lt
-/

#print Ordinal.add_le_add_iff_right /-
theorem add_le_add_iff_right {a b : Ordinal} : ∀ n : ℕ, a + n ≤ b + n ↔ a ≤ b
  | 0 => by simp
  | n + 1 => by rw [nat_cast_succ, add_succ, add_succ, succ_le_succ_iff, add_le_add_iff_right]
#align ordinal.add_le_add_iff_right Ordinal.add_le_add_iff_right
-/

#print Ordinal.add_right_cancel /-
theorem add_right_cancel {a b : Ordinal} (n : ℕ) : a + n = b + n ↔ a = b := by
  simp only [le_antisymm_iff, add_le_add_iff_right]
#align ordinal.add_right_cancel Ordinal.add_right_cancel
-/

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

#print Ordinal.pred_succ /-
@[simp]
theorem pred_succ (o) : pred (succ o) = o := by
  have h : ∃ a, succ o = succ a := ⟨_, rfl⟩ <;>
    simpa only [pred, dif_pos h] using (succ_injective <| Classical.choose_spec h).symm
#align ordinal.pred_succ Ordinal.pred_succ
-/

#print Ordinal.pred_le_self /-
theorem pred_le_self (o) : pred o ≤ o :=
  if h : ∃ a, o = succ a then by
    let ⟨a, e⟩ := h
    rw [e, pred_succ] <;> exact le_succ a
  else by rw [pred, dif_neg h]
#align ordinal.pred_le_self Ordinal.pred_le_self
-/

#print Ordinal.pred_eq_iff_not_succ /-
theorem pred_eq_iff_not_succ {o} : pred o = o ↔ ¬∃ a, o = succ a :=
  ⟨fun e ⟨a, e'⟩ => by rw [e', pred_succ] at e  <;> exact (lt_succ a).Ne e, fun h => dif_neg h⟩
#align ordinal.pred_eq_iff_not_succ Ordinal.pred_eq_iff_not_succ
-/

#print Ordinal.pred_eq_iff_not_succ' /-
theorem pred_eq_iff_not_succ' {o} : pred o = o ↔ ∀ a, o ≠ succ a := by
  simpa using pred_eq_iff_not_succ
#align ordinal.pred_eq_iff_not_succ' Ordinal.pred_eq_iff_not_succ'
-/

#print Ordinal.pred_lt_iff_is_succ /-
theorem pred_lt_iff_is_succ {o} : pred o < o ↔ ∃ a, o = succ a :=
  Iff.trans (by simp only [le_antisymm_iff, pred_le_self, true_and_iff, not_le])
    (iff_not_comm.1 pred_eq_iff_not_succ).symm
#align ordinal.pred_lt_iff_is_succ Ordinal.pred_lt_iff_is_succ
-/

#print Ordinal.pred_zero /-
@[simp]
theorem pred_zero : pred 0 = 0 :=
  pred_eq_iff_not_succ'.2 fun a => (succ_ne_zero a).symm
#align ordinal.pred_zero Ordinal.pred_zero
-/

#print Ordinal.succ_pred_iff_is_succ /-
theorem succ_pred_iff_is_succ {o} : succ (pred o) = o ↔ ∃ a, o = succ a :=
  ⟨fun e => ⟨_, e.symm⟩, fun ⟨a, e⟩ => by simp only [e, pred_succ]⟩
#align ordinal.succ_pred_iff_is_succ Ordinal.succ_pred_iff_is_succ
-/

#print Ordinal.succ_lt_of_not_succ /-
theorem succ_lt_of_not_succ {o b : Ordinal} (h : ¬∃ a, o = succ a) : succ b < o ↔ b < o :=
  ⟨(lt_succ b).trans, fun l => lt_of_le_of_ne (succ_le_of_lt l) fun e => h ⟨_, e.symm⟩⟩
#align ordinal.succ_lt_of_not_succ Ordinal.succ_lt_of_not_succ
-/

#print Ordinal.lt_pred /-
theorem lt_pred {a b} : a < pred b ↔ succ a < b :=
  if h : ∃ a, b = succ a then by
    let ⟨c, e⟩ := h
    rw [e, pred_succ, succ_lt_succ_iff]
  else by simp only [pred, dif_neg h, succ_lt_of_not_succ h]
#align ordinal.lt_pred Ordinal.lt_pred
-/

#print Ordinal.pred_le /-
theorem pred_le {a b} : pred a ≤ b ↔ a ≤ succ b :=
  le_iff_le_iff_lt_iff_lt.2 lt_pred
#align ordinal.pred_le Ordinal.pred_le
-/

#print Ordinal.lift_is_succ /-
@[simp]
theorem lift_is_succ {o} : (∃ a, lift o = succ a) ↔ ∃ a, o = succ a :=
  ⟨fun ⟨a, h⟩ =>
    let ⟨b, e⟩ := lift_down <| show a ≤ lift o from le_of_lt <| h.symm ▸ lt_succ a
    ⟨b, lift_inj.1 <| by rw [h, ← e, lift_succ]⟩,
    fun ⟨a, h⟩ => ⟨lift a, by simp only [h, lift_succ]⟩⟩
#align ordinal.lift_is_succ Ordinal.lift_is_succ
-/

#print Ordinal.lift_pred /-
@[simp]
theorem lift_pred (o) : lift (pred o) = pred (lift o) :=
  if h : ∃ a, o = succ a then by cases' h with a e <;> simp only [e, pred_succ, lift_succ]
  else by rw [pred_eq_iff_not_succ.2 h, pred_eq_iff_not_succ.2 (mt lift_is_succ.1 h)]
#align ordinal.lift_pred Ordinal.lift_pred
-/

/-! ### Limit ordinals -/


#print Ordinal.IsLimit /-
/-- A limit ordinal is an ordinal which is not zero and not a successor. -/
def IsLimit (o : Ordinal) : Prop :=
  o ≠ 0 ∧ ∀ a < o, succ a < o
#align ordinal.is_limit Ordinal.IsLimit
-/

#print Ordinal.IsLimit.succ_lt /-
theorem IsLimit.succ_lt {o a : Ordinal} (h : IsLimit o) : a < o → succ a < o :=
  h.2 a
#align ordinal.is_limit.succ_lt Ordinal.IsLimit.succ_lt
-/

#print Ordinal.not_zero_isLimit /-
theorem not_zero_isLimit : ¬IsLimit 0
  | ⟨h, _⟩ => h rfl
#align ordinal.not_zero_is_limit Ordinal.not_zero_isLimit
-/

#print Ordinal.not_succ_isLimit /-
theorem not_succ_isLimit (o) : ¬IsLimit (succ o)
  | ⟨_, h⟩ => lt_irrefl _ (h _ (lt_succ o))
#align ordinal.not_succ_is_limit Ordinal.not_succ_isLimit
-/

#print Ordinal.not_succ_of_isLimit /-
theorem not_succ_of_isLimit {o} (h : IsLimit o) : ¬∃ a, o = succ a
  | ⟨a, e⟩ => not_succ_isLimit a (e ▸ h)
#align ordinal.not_succ_of_is_limit Ordinal.not_succ_of_isLimit
-/

#print Ordinal.succ_lt_of_isLimit /-
theorem succ_lt_of_isLimit {o a : Ordinal} (h : IsLimit o) : succ a < o ↔ a < o :=
  ⟨(lt_succ a).trans, h.2 _⟩
#align ordinal.succ_lt_of_is_limit Ordinal.succ_lt_of_isLimit
-/

#print Ordinal.le_succ_of_isLimit /-
theorem le_succ_of_isLimit {o} (h : IsLimit o) {a} : o ≤ succ a ↔ o ≤ a :=
  le_iff_le_iff_lt_iff_lt.2 <| succ_lt_of_isLimit h
#align ordinal.le_succ_of_is_limit Ordinal.le_succ_of_isLimit
-/

#print Ordinal.limit_le /-
theorem limit_le {o} (h : IsLimit o) {a} : o ≤ a ↔ ∀ x < o, x ≤ a :=
  ⟨fun h x l => l.le.trans h, fun H =>
    (le_succ_of_isLimit h).1 <| le_of_not_lt fun hn => not_lt_of_le (H _ hn) (lt_succ a)⟩
#align ordinal.limit_le Ordinal.limit_le
-/

#print Ordinal.lt_limit /-
theorem lt_limit {o} (h : IsLimit o) {a} : a < o ↔ ∃ x < o, a < x := by
  simpa only [not_ball, not_le] using not_congr (@limit_le _ h a)
#align ordinal.lt_limit Ordinal.lt_limit
-/

#print Ordinal.lift_isLimit /-
@[simp]
theorem lift_isLimit (o) : IsLimit (lift o) ↔ IsLimit o :=
  and_congr (not_congr <| by simpa only [lift_zero] using @lift_inj o 0)
    ⟨fun H a h => lift_lt.1 <| by simpa only [lift_succ] using H _ (lift_lt.2 h), fun H a h =>
      by
      obtain ⟨a', rfl⟩ := lift_down h.le
      rw [← lift_succ, lift_lt]
      exact H a' (lift_lt.1 h)⟩
#align ordinal.lift_is_limit Ordinal.lift_isLimit
-/

#print Ordinal.IsLimit.pos /-
theorem IsLimit.pos {o : Ordinal} (h : IsLimit o) : 0 < o :=
  lt_of_le_of_ne (Ordinal.zero_le _) h.1.symm
#align ordinal.is_limit.pos Ordinal.IsLimit.pos
-/

#print Ordinal.IsLimit.one_lt /-
theorem IsLimit.one_lt {o : Ordinal} (h : IsLimit o) : 1 < o := by
  simpa only [succ_zero] using h.2 _ h.pos
#align ordinal.is_limit.one_lt Ordinal.IsLimit.one_lt
-/

#print Ordinal.IsLimit.nat_lt /-
theorem IsLimit.nat_lt {o : Ordinal} (h : IsLimit o) : ∀ n : ℕ, (n : Ordinal) < o
  | 0 => h.Pos
  | n + 1 => h.2 _ (is_limit.nat_lt n)
#align ordinal.is_limit.nat_lt Ordinal.IsLimit.nat_lt
-/

#print Ordinal.zero_or_succ_or_limit /-
theorem zero_or_succ_or_limit (o : Ordinal) : o = 0 ∨ (∃ a, o = succ a) ∨ IsLimit o :=
  if o0 : o = 0 then Or.inl o0
  else
    if h : ∃ a, o = succ a then Or.inr (Or.inl h)
    else Or.inr <| Or.inr ⟨o0, fun a => (succ_lt_of_not_succ h).2⟩
#align ordinal.zero_or_succ_or_limit Ordinal.zero_or_succ_or_limit
-/

#print Ordinal.limitRecOn /-
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
-/

#print Ordinal.limitRecOn_zero /-
@[simp]
theorem limitRecOn_zero {C} (H₁ H₂ H₃) : @limitRecOn C 0 H₁ H₂ H₃ = H₁ := by
  rw [limit_rec_on, lt_wf.fix_eq, dif_pos rfl] <;> rfl
#align ordinal.limit_rec_on_zero Ordinal.limitRecOn_zero
-/

#print Ordinal.limitRecOn_succ /-
@[simp]
theorem limitRecOn_succ {C} (o H₁ H₂ H₃) :
    @limitRecOn C (succ o) H₁ H₂ H₃ = H₂ o (@limitRecOn C o H₁ H₂ H₃) :=
  by
  have h : ∃ a, succ o = succ a := ⟨_, rfl⟩
  rw [limit_rec_on, lt_wf.fix_eq, dif_neg (succ_ne_zero o), dif_pos h]
  generalize limit_rec_on._proof_2 (succ o) h = h₂
  generalize limit_rec_on._proof_3 (succ o) h = h₃
  revert h₂ h₃; generalize e : pred (succ o) = o'; intros
  rw [pred_succ] at e ; subst o'; rfl
#align ordinal.limit_rec_on_succ Ordinal.limitRecOn_succ
-/

#print Ordinal.limitRecOn_limit /-
@[simp]
theorem limitRecOn_limit {C} (o H₁ H₂ H₃ h) :
    @limitRecOn C o H₁ H₂ H₃ = H₃ o h fun x h => @limitRecOn C x H₁ H₂ H₃ := by
  rw [limit_rec_on, lt_wf.fix_eq, dif_neg h.1, dif_neg (not_succ_of_is_limit h)] <;> rfl
#align ordinal.limit_rec_on_limit Ordinal.limitRecOn_limit
-/

#print Ordinal.orderTopOutSucc /-
instance orderTopOutSucc (o : Ordinal) : OrderTop (succ o).out.α :=
  ⟨_, le_enum_succ⟩
#align ordinal.order_top_out_succ Ordinal.orderTopOutSucc
-/

#print Ordinal.enum_succ_eq_top /-
theorem enum_succ_eq_top {o : Ordinal} :
    enum (· < ·) o (by rw [type_lt]; exact lt_succ o) = (⊤ : (succ o).out.α) :=
  rfl
#align ordinal.enum_succ_eq_top Ordinal.enum_succ_eq_top
-/

#print Ordinal.has_succ_of_type_succ_lt /-
theorem has_succ_of_type_succ_lt {α} {r : α → α → Prop} [wo : IsWellOrder α r]
    (h : ∀ a < type r, succ a < type r) (x : α) : ∃ y, r x y :=
  by
  use enum r (succ (typein r x)) (h _ (typein_lt_type r x))
  convert (enum_lt_enum (typein_lt_type r x) _).mpr (lt_succ _); rw [enum_typein]
#align ordinal.has_succ_of_type_succ_lt Ordinal.has_succ_of_type_succ_lt
-/

#print Ordinal.out_no_max_of_succ_lt /-
theorem out_no_max_of_succ_lt {o : Ordinal} (ho : ∀ a < o, succ a < o) : NoMaxOrder o.out.α :=
  ⟨has_succ_of_type_succ_lt (by rwa [type_lt])⟩
#align ordinal.out_no_max_of_succ_lt Ordinal.out_no_max_of_succ_lt
-/

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

#print Ordinal.type_subrel_lt /-
theorem type_subrel_lt (o : Ordinal.{u}) :
    type (Subrel (· < ·) {o' : Ordinal | o' < o}) = Ordinal.lift.{u + 1} o :=
  by
  refine' Quotient.inductionOn o _
  rintro ⟨α, r, wo⟩; skip; apply Quotient.sound
  constructor; symm; refine' (RelIso.preimage Equiv.ulift r).trans (enum_iso r).symm
#align ordinal.type_subrel_lt Ordinal.type_subrel_lt
-/

#print Ordinal.mk_initialSeg /-
theorem mk_initialSeg (o : Ordinal.{u}) :
    (#{o' : Ordinal | o' < o}) = Cardinal.lift.{u + 1} o.card := by
  rw [lift_card, ← type_subrel_lt, card_type]
#align ordinal.mk_initial_seg Ordinal.mk_initialSeg
-/

/-! ### Normal ordinal functions -/


#print Ordinal.IsNormal /-
/-- A normal ordinal function is a strictly increasing function which is
  order-continuous, i.e., the image `f o` of a limit ordinal `o` is the sup of `f a` for
  `a < o`.  -/
def IsNormal (f : Ordinal → Ordinal) : Prop :=
  (∀ o, f o < f (succ o)) ∧ ∀ o, IsLimit o → ∀ a, f o ≤ a ↔ ∀ b < o, f b ≤ a
#align ordinal.is_normal Ordinal.IsNormal
-/

#print Ordinal.IsNormal.limit_le /-
theorem IsNormal.limit_le {f} (H : IsNormal f) :
    ∀ {o}, IsLimit o → ∀ {a}, f o ≤ a ↔ ∀ b < o, f b ≤ a :=
  H.2
#align ordinal.is_normal.limit_le Ordinal.IsNormal.limit_le
-/

#print Ordinal.IsNormal.limit_lt /-
theorem IsNormal.limit_lt {f} (H : IsNormal f) {o} (h : IsLimit o) {a} :
    a < f o ↔ ∃ b < o, a < f b :=
  not_iff_not.1 <| by simpa only [exists_prop, not_exists, not_and, not_lt] using H.2 _ h a
#align ordinal.is_normal.limit_lt Ordinal.IsNormal.limit_lt
-/

#print Ordinal.IsNormal.strictMono /-
theorem IsNormal.strictMono {f} (H : IsNormal f) : StrictMono f := fun a b =>
  limitRecOn b (Not.elim (not_lt_of_le <| Ordinal.zero_le _))
    (fun b IH h =>
      (lt_or_eq_of_le (le_of_lt_succ h)).elim (fun h => (IH h).trans (H.1 _)) fun e => e ▸ H.1 _)
    fun b l IH h => lt_of_lt_of_le (H.1 a) ((H.2 _ l _).1 le_rfl _ (l.2 _ h))
#align ordinal.is_normal.strict_mono Ordinal.IsNormal.strictMono
-/

#print Ordinal.IsNormal.monotone /-
theorem IsNormal.monotone {f} (H : IsNormal f) : Monotone f :=
  H.StrictMono.Monotone
#align ordinal.is_normal.monotone Ordinal.IsNormal.monotone
-/

#print Ordinal.isNormal_iff_strictMono_limit /-
theorem isNormal_iff_strictMono_limit (f : Ordinal → Ordinal) :
    IsNormal f ↔ StrictMono f ∧ ∀ o, IsLimit o → ∀ a, (∀ b < o, f b ≤ a) → f o ≤ a :=
  ⟨fun hf => ⟨hf.StrictMono, fun a ha c => (hf.2 a ha c).2⟩, fun ⟨hs, hl⟩ =>
    ⟨fun a => hs (lt_succ a), fun a ha c =>
      ⟨fun hac b hba => ((hs hba).trans_le hac).le, hl a ha c⟩⟩⟩
#align ordinal.is_normal_iff_strict_mono_limit Ordinal.isNormal_iff_strictMono_limit
-/

#print Ordinal.IsNormal.lt_iff /-
theorem IsNormal.lt_iff {f} (H : IsNormal f) {a b} : f a < f b ↔ a < b :=
  StrictMono.lt_iff_lt <| H.StrictMono
#align ordinal.is_normal.lt_iff Ordinal.IsNormal.lt_iff
-/

#print Ordinal.IsNormal.le_iff /-
theorem IsNormal.le_iff {f} (H : IsNormal f) {a b} : f a ≤ f b ↔ a ≤ b :=
  le_iff_le_iff_lt_iff_lt.2 H.lt_iff
#align ordinal.is_normal.le_iff Ordinal.IsNormal.le_iff
-/

#print Ordinal.IsNormal.inj /-
theorem IsNormal.inj {f} (H : IsNormal f) {a b} : f a = f b ↔ a = b := by
  simp only [le_antisymm_iff, H.le_iff]
#align ordinal.is_normal.inj Ordinal.IsNormal.inj
-/

#print Ordinal.IsNormal.self_le /-
theorem IsNormal.self_le {f} (H : IsNormal f) (a) : a ≤ f a :=
  lt_wf.self_le_of_strictMono H.StrictMono a
#align ordinal.is_normal.self_le Ordinal.IsNormal.self_le
-/

#print Ordinal.IsNormal.le_set /-
theorem IsNormal.le_set {f o} (H : IsNormal f) (p : Set Ordinal) (p0 : p.Nonempty) (b)
    (H₂ : ∀ o, b ≤ o ↔ ∀ a ∈ p, a ≤ o) : f b ≤ o ↔ ∀ a ∈ p, f a ≤ o :=
  ⟨fun h a pa => (H.le_iff.2 ((H₂ _).1 le_rfl _ pa)).trans h, fun h =>
    by
    revert H₂;
    refine'
      limit_rec_on b (fun H₂ => _) (fun S _ H₂ => _) fun S L _ H₂ => (H.2 _ L _).2 fun a h' => _
    · cases' p0 with x px
      have := Ordinal.le_zero.1 ((H₂ _).1 (Ordinal.zero_le _) _ px)
      rw [this] at px ; exact h _ px
    · rcases not_ball.1 (mt (H₂ S).2 <| (lt_succ S).not_le) with ⟨a, h₁, h₂⟩
      exact (H.le_iff.2 <| succ_le_of_lt <| not_le.1 h₂).trans (h _ h₁)
    · rcases not_ball.1 (mt (H₂ a).2 h'.not_le) with ⟨b, h₁, h₂⟩
      exact (H.le_iff.2 <| (not_le.1 h₂).le).trans (h _ h₁)⟩
#align ordinal.is_normal.le_set Ordinal.IsNormal.le_set
-/

#print Ordinal.IsNormal.le_set' /-
theorem IsNormal.le_set' {f o} (H : IsNormal f) (p : Set α) (p0 : p.Nonempty) (g : α → Ordinal) (b)
    (H₂ : ∀ o, b ≤ o ↔ ∀ a ∈ p, g a ≤ o) : f b ≤ o ↔ ∀ a ∈ p, f (g a) ≤ o := by
  simpa [H₂] using H.le_set (g '' p) (p0.image g) b
#align ordinal.is_normal.le_set' Ordinal.IsNormal.le_set'
-/

#print Ordinal.IsNormal.refl /-
theorem IsNormal.refl : IsNormal id :=
  ⟨lt_succ, fun o l a => limit_le l⟩
#align ordinal.is_normal.refl Ordinal.IsNormal.refl
-/

#print Ordinal.IsNormal.trans /-
theorem IsNormal.trans {f g} (H₁ : IsNormal f) (H₂ : IsNormal g) : IsNormal (f ∘ g) :=
  ⟨fun x => H₁.lt_iff.2 (H₂.1 _), fun o l a =>
    H₁.le_set' (· < o) ⟨_, l.Pos⟩ g _ fun c => H₂.2 _ l _⟩
#align ordinal.is_normal.trans Ordinal.IsNormal.trans
-/

#print Ordinal.IsNormal.isLimit /-
theorem IsNormal.isLimit {f} (H : IsNormal f) {o} (l : IsLimit o) : IsLimit (f o) :=
  ⟨ne_of_gt <| (Ordinal.zero_le _).trans_lt <| H.lt_iff.2 l.Pos, fun a h =>
    let ⟨b, h₁, h₂⟩ := (H.limit_lt l).1 h
    (succ_le_of_lt h₂).trans_lt (H.lt_iff.2 h₁)⟩
#align ordinal.is_normal.is_limit Ordinal.IsNormal.isLimit
-/

#print Ordinal.IsNormal.le_iff_eq /-
theorem IsNormal.le_iff_eq {f} (H : IsNormal f) {a} : f a ≤ a ↔ f a = a :=
  (H.self_le a).le_iff_eq
#align ordinal.is_normal.le_iff_eq Ordinal.IsNormal.le_iff_eq
-/

#print Ordinal.add_le_of_limit /-
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
-/

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


#print Ordinal.sub_nonempty /-
/-- The set in the definition of subtraction is nonempty. -/
theorem sub_nonempty {a b : Ordinal} : {o | a ≤ b + o}.Nonempty :=
  ⟨a, le_add_left _ _⟩
#align ordinal.sub_nonempty Ordinal.sub_nonempty
-/

/-- `a - b` is the unique ordinal satisfying `b + (a - b) = a` when `b ≤ a`. -/
instance : Sub Ordinal :=
  ⟨fun a b => sInf {o | a ≤ b + o}⟩

#print Ordinal.le_add_sub /-
theorem le_add_sub (a b : Ordinal) : a ≤ b + (a - b) :=
  csInf_mem sub_nonempty
#align ordinal.le_add_sub Ordinal.le_add_sub
-/

#print Ordinal.sub_le /-
theorem sub_le {a b c : Ordinal} : a - b ≤ c ↔ a ≤ b + c :=
  ⟨fun h => (le_add_sub a b).trans (add_le_add_left h _), fun h => csInf_le' h⟩
#align ordinal.sub_le Ordinal.sub_le
-/

#print Ordinal.lt_sub /-
theorem lt_sub {a b c : Ordinal} : a < b - c ↔ c + a < b :=
  lt_iff_lt_of_le_iff_le sub_le
#align ordinal.lt_sub Ordinal.lt_sub
-/

#print Ordinal.add_sub_cancel /-
theorem add_sub_cancel (a b : Ordinal) : a + b - a = b :=
  le_antisymm (sub_le.2 <| le_rfl) ((add_le_add_iff_left a).1 <| le_add_sub _ _)
#align ordinal.add_sub_cancel Ordinal.add_sub_cancel
-/

#print Ordinal.sub_eq_of_add_eq /-
theorem sub_eq_of_add_eq {a b c : Ordinal} (h : a + b = c) : c - a = b :=
  h ▸ add_sub_cancel _ _
#align ordinal.sub_eq_of_add_eq Ordinal.sub_eq_of_add_eq
-/

#print Ordinal.sub_le_self /-
theorem sub_le_self (a b : Ordinal) : a - b ≤ a :=
  sub_le.2 <| le_add_left _ _
#align ordinal.sub_le_self Ordinal.sub_le_self
-/

#print Ordinal.add_sub_cancel_of_le /-
protected theorem add_sub_cancel_of_le {a b : Ordinal} (h : b ≤ a) : b + (a - b) = a :=
  (le_add_sub a b).antisymm'
    (by
      rcases zero_or_succ_or_limit (a - b) with (e | ⟨c, e⟩ | l)
      · simp only [e, add_zero, h]
      · rw [e, add_succ, succ_le_iff, ← lt_sub, e]; exact lt_succ c
      · exact (add_le_of_limit l).2 fun c l => (lt_sub.1 l).le)
#align ordinal.add_sub_cancel_of_le Ordinal.add_sub_cancel_of_le
-/

#print Ordinal.le_sub_of_le /-
theorem le_sub_of_le {a b c : Ordinal} (h : b ≤ a) : c ≤ a - b ↔ b + c ≤ a := by
  rw [← add_le_add_iff_left b, Ordinal.add_sub_cancel_of_le h]
#align ordinal.le_sub_of_le Ordinal.le_sub_of_le
-/

#print Ordinal.sub_lt_of_le /-
theorem sub_lt_of_le {a b c : Ordinal} (h : b ≤ a) : a - b < c ↔ a < b + c :=
  lt_iff_lt_of_le_iff_le (le_sub_of_le h)
#align ordinal.sub_lt_of_le Ordinal.sub_lt_of_le
-/

instance : ExistsAddOfLE Ordinal :=
  ⟨fun a b h => ⟨_, (Ordinal.add_sub_cancel_of_le h).symm⟩⟩

#print Ordinal.sub_zero /-
@[simp]
theorem sub_zero (a : Ordinal) : a - 0 = a := by simpa only [zero_add] using add_sub_cancel 0 a
#align ordinal.sub_zero Ordinal.sub_zero
-/

#print Ordinal.zero_sub /-
@[simp]
theorem zero_sub (a : Ordinal) : 0 - a = 0 := by rw [← Ordinal.le_zero] <;> apply sub_le_self
#align ordinal.zero_sub Ordinal.zero_sub
-/

#print Ordinal.sub_self /-
@[simp]
theorem sub_self (a : Ordinal) : a - a = 0 := by simpa only [add_zero] using add_sub_cancel a 0
#align ordinal.sub_self Ordinal.sub_self
-/

#print Ordinal.sub_eq_zero_iff_le /-
protected theorem sub_eq_zero_iff_le {a b : Ordinal} : a - b = 0 ↔ a ≤ b :=
  ⟨fun h => by simpa only [h, add_zero] using le_add_sub a b, fun h => by
    rwa [← Ordinal.le_zero, sub_le, add_zero]⟩
#align ordinal.sub_eq_zero_iff_le Ordinal.sub_eq_zero_iff_le
-/

#print Ordinal.sub_sub /-
theorem sub_sub (a b c : Ordinal) : a - b - c = a - (b + c) :=
  eq_of_forall_ge_iff fun d => by rw [sub_le, sub_le, sub_le, add_assoc]
#align ordinal.sub_sub Ordinal.sub_sub
-/

#print Ordinal.add_sub_add_cancel /-
@[simp]
theorem add_sub_add_cancel (a b c : Ordinal) : a + b - (a + c) = b - c := by
  rw [← sub_sub, add_sub_cancel]
#align ordinal.add_sub_add_cancel Ordinal.add_sub_add_cancel
-/

#print Ordinal.sub_isLimit /-
theorem sub_isLimit {a b} (l : IsLimit a) (h : b < a) : IsLimit (a - b) :=
  ⟨ne_of_gt <| lt_sub.2 <| by rwa [add_zero], fun c h => by
    rw [lt_sub, add_succ] <;> exact l.2 _ (lt_sub.1 h)⟩
#align ordinal.sub_is_limit Ordinal.sub_isLimit
-/

#print Ordinal.one_add_omega /-
@[simp]
theorem one_add_omega : 1 + ω = ω :=
  by
  refine' le_antisymm _ (le_add_left _ _)
  rw [omega, ← lift_one.{0}, ← lift_add, lift_le, ← type_unit, ← type_sum_lex]
  refine' ⟨RelEmbedding.collapse (RelEmbedding.ofMonotone _ _)⟩
  · apply Sum.rec; exact fun _ => 0; exact Nat.succ
  · intro a b;
    cases a <;> cases b <;> intro H <;> cases' H with _ _ H _ _ H <;> [cases H;
      exact Nat.succ_pos _; exact Nat.succ_lt_succ H]
#align ordinal.one_add_omega Ordinal.one_add_omega
-/

#print Ordinal.one_add_of_omega_le /-
@[simp]
theorem one_add_of_omega_le {o} (h : ω ≤ o) : 1 + o = o := by
  rw [← Ordinal.add_sub_cancel_of_le h, ← add_assoc, one_add_omega]
#align ordinal.one_add_of_omega_le Ordinal.one_add_of_omega_le
-/

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

#print Ordinal.type_prod_lex /-
@[simp]
theorem type_prod_lex {α β : Type u} (r : α → α → Prop) (s : β → β → Prop) [IsWellOrder α r]
    [IsWellOrder β s] : type (Prod.Lex s r) = type r * type s :=
  rfl
#align ordinal.type_prod_lex Ordinal.type_prod_lex
-/

private theorem mul_eq_zero' {a b : Ordinal} : a * b = 0 ↔ a = 0 ∨ b = 0 :=
  inductionOn a fun α _ _ =>
    inductionOn b fun β _ _ =>
      by
      simp_rw [← type_prod_lex, type_eq_zero_iff_is_empty]
      rw [or_comm']
      exact isEmpty_prod

instance : MonoidWithZero Ordinal :=
  { Ordinal.monoid with
    zero := 0
    mul_zero := fun a => mul_eq_zero'.2 <| Or.inr rfl
    zero_mul := fun a => mul_eq_zero'.2 <| Or.inl rfl }

instance : NoZeroDivisors Ordinal :=
  ⟨fun a b => mul_eq_zero'.1⟩

#print Ordinal.lift_mul /-
@[simp]
theorem lift_mul (a b) : lift (a * b) = lift a * lift b :=
  Quotient.induction_on₂ a b fun ⟨α, r, _⟩ ⟨β, s, _⟩ =>
    Quotient.sound
      ⟨(RelIso.preimage Equiv.ulift _).trans
          (RelIso.prodLexCongr (RelIso.preimage Equiv.ulift _)
              (RelIso.preimage Equiv.ulift _)).symm⟩
#align ordinal.lift_mul Ordinal.lift_mul
-/

#print Ordinal.card_mul /-
@[simp]
theorem card_mul (a b) : card (a * b) = card a * card b :=
  Quotient.induction_on₂ a b fun ⟨α, r, _⟩ ⟨β, s, _⟩ => mul_comm (mk β) (mk α)
#align ordinal.card_mul Ordinal.card_mul
-/

instance : LeftDistribClass Ordinal.{u} :=
  ⟨fun a b c =>
    Quotient.induction_on₃ a b c fun ⟨α, r, _⟩ ⟨β, s, _⟩ ⟨γ, t, _⟩ =>
      Quotient.sound
        ⟨⟨sumProdDistrib _ _ _, by
            rintro ⟨a₁ | a₁, a₂⟩ ⟨b₁ | b₁, b₂⟩ <;>
                simp only [Prod.lex_def, Sum.lex_inl_inl, Sum.Lex.sep, Sum.lex_inr_inl,
                  Sum.lex_inr_inr, sum_prod_distrib_apply_left, sum_prod_distrib_apply_right] <;>
              simp only [Sum.inl.inj_iff, true_or_iff, false_and_iff, false_or_iff]⟩⟩⟩

#print Ordinal.mul_succ /-
theorem mul_succ (a b : Ordinal) : a * succ b = a * b + a :=
  mul_add_one a b
#align ordinal.mul_succ Ordinal.mul_succ
-/

#print Ordinal.mul_covariantClass_le /-
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
-/

#print Ordinal.mul_swap_covariantClass_le /-
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
-/

#print Ordinal.le_mul_left /-
theorem le_mul_left (a : Ordinal) {b : Ordinal} (hb : 0 < b) : a ≤ a * b := by
  convert mul_le_mul_left' (one_le_iff_pos.2 hb) a; rw [mul_one a]
#align ordinal.le_mul_left Ordinal.le_mul_left
-/

#print Ordinal.le_mul_right /-
theorem le_mul_right (a : Ordinal) {b : Ordinal} (hb : 0 < b) : a ≤ b * a := by
  convert mul_le_mul_right' (one_le_iff_pos.2 hb) a; rw [one_mul a]
#align ordinal.le_mul_right Ordinal.le_mul_right
-/

private theorem mul_le_of_limit_aux {α β r s} [IsWellOrder α r] [IsWellOrder β s] {c}
    (h : IsLimit (type s)) (H : ∀ b' < type s, type r * b' ≤ c) (l : c < type r * type s) : False :=
  by
  suffices ∀ a b, Prod.Lex s r (b, a) (enum _ _ l) by cases' enum _ _ l with b a;
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
      subst e; cases' h with _ _ _ _ h _ _ _ h
      · exact (irrefl _ h).elim
      · exact h
    · refine' Sum.inl (⟨b', _⟩, a')
      cases' h with _ _ _ _ h _ _ _ h
      · exact h; · exact (e rfl).elim
  · rcases a with ⟨⟨b₁, a₁⟩, h₁⟩
    rcases b with ⟨⟨b₂, a₂⟩, h₂⟩
    intro h; by_cases e₁ : b = b₁ <;> by_cases e₂ : b = b₂
    · substs b₁ b₂
      simpa only [subrel_val, Prod.lex_def, @irrefl _ s _ b, true_and_iff, false_or_iff,
        eq_self_iff_true, dif_pos, Sum.lex_inr_inr] using h
    · subst b₁
      simp only [subrel_val, Prod.lex_def, e₂, Prod.lex_def, dif_pos, subrel_val, eq_self_iff_true,
        or_false_iff, dif_neg, not_false_iff, Sum.lex_inr_inl, false_and_iff] at h ⊢
      cases h₂ <;> [exact asymm h h₂_h; exact e₂ rfl]
    · simp [e₂, dif_neg e₁, show b₂ ≠ b₁ by cc]
    ·
      simpa only [dif_neg e₁, dif_neg e₂, Prod.lex_def, subrel_val, Subtype.mk_eq_mk,
        Sum.lex_inl_inl] using h

#print Ordinal.mul_le_of_limit /-
theorem mul_le_of_limit {a b c : Ordinal} (h : IsLimit b) : a * b ≤ c ↔ ∀ b' < b, a * b' ≤ c :=
  ⟨fun h b' l => (mul_le_mul_left' l.le _).trans h, fun H =>
    le_of_not_lt <| inductionOn a (fun α r _ => inductionOn b fun β s _ => mul_le_of_limit_aux) h H⟩
#align ordinal.mul_le_of_limit Ordinal.mul_le_of_limit
-/

#print Ordinal.mul_isNormal /-
theorem mul_isNormal {a : Ordinal} (h : 0 < a) : IsNormal ((· * ·) a) :=
  ⟨fun b => by rw [mul_succ] <;> simpa only [add_zero] using (add_lt_add_iff_left (a * b)).2 h,
    fun b l c => mul_le_of_limit l⟩
#align ordinal.mul_is_normal Ordinal.mul_isNormal
-/

#print Ordinal.lt_mul_of_limit /-
theorem lt_mul_of_limit {a b c : Ordinal} (h : IsLimit c) : a < b * c ↔ ∃ c' < c, a < b * c' := by
  simpa only [not_ball, not_le] using not_congr (@mul_le_of_limit b c a h)
#align ordinal.lt_mul_of_limit Ordinal.lt_mul_of_limit
-/

#print Ordinal.mul_lt_mul_iff_left /-
theorem mul_lt_mul_iff_left {a b c : Ordinal} (a0 : 0 < a) : a * b < a * c ↔ b < c :=
  (mul_isNormal a0).lt_iff
#align ordinal.mul_lt_mul_iff_left Ordinal.mul_lt_mul_iff_left
-/

#print Ordinal.mul_le_mul_iff_left /-
theorem mul_le_mul_iff_left {a b c : Ordinal} (a0 : 0 < a) : a * b ≤ a * c ↔ b ≤ c :=
  (mul_isNormal a0).le_iff
#align ordinal.mul_le_mul_iff_left Ordinal.mul_le_mul_iff_left
-/

#print Ordinal.mul_lt_mul_of_pos_left /-
theorem mul_lt_mul_of_pos_left {a b c : Ordinal} (h : a < b) (c0 : 0 < c) : c * a < c * b :=
  (mul_lt_mul_iff_left c0).2 h
#align ordinal.mul_lt_mul_of_pos_left Ordinal.mul_lt_mul_of_pos_left
-/

#print Ordinal.mul_pos /-
theorem mul_pos {a b : Ordinal} (h₁ : 0 < a) (h₂ : 0 < b) : 0 < a * b := by
  simpa only [MulZeroClass.mul_zero] using mul_lt_mul_of_pos_left h₂ h₁
#align ordinal.mul_pos Ordinal.mul_pos
-/

#print Ordinal.mul_ne_zero /-
theorem mul_ne_zero {a b : Ordinal} : a ≠ 0 → b ≠ 0 → a * b ≠ 0 := by
  simpa only [Ordinal.pos_iff_ne_zero] using mul_pos
#align ordinal.mul_ne_zero Ordinal.mul_ne_zero
-/

#print Ordinal.le_of_mul_le_mul_left /-
theorem le_of_mul_le_mul_left {a b c : Ordinal} (h : c * a ≤ c * b) (h0 : 0 < c) : a ≤ b :=
  le_imp_le_of_lt_imp_lt (fun h' => mul_lt_mul_of_pos_left h' h0) h
#align ordinal.le_of_mul_le_mul_left Ordinal.le_of_mul_le_mul_left
-/

#print Ordinal.mul_right_inj /-
theorem mul_right_inj {a b c : Ordinal} (a0 : 0 < a) : a * b = a * c ↔ b = c :=
  (mul_isNormal a0).inj
#align ordinal.mul_right_inj Ordinal.mul_right_inj
-/

#print Ordinal.mul_isLimit /-
theorem mul_isLimit {a b : Ordinal} (a0 : 0 < a) : IsLimit b → IsLimit (a * b) :=
  (mul_isNormal a0).IsLimit
#align ordinal.mul_is_limit Ordinal.mul_isLimit
-/

#print Ordinal.mul_isLimit_left /-
theorem mul_isLimit_left {a b : Ordinal} (l : IsLimit a) (b0 : 0 < b) : IsLimit (a * b) :=
  by
  rcases zero_or_succ_or_limit b with (rfl | ⟨b, rfl⟩ | lb)
  · exact b0.false.elim
  · rw [mul_succ]; exact add_is_limit _ l
  · exact mul_is_limit l.pos lb
#align ordinal.mul_is_limit_left Ordinal.mul_isLimit_left
-/

#print Ordinal.smul_eq_mul /-
theorem smul_eq_mul : ∀ (n : ℕ) (a : Ordinal), n • a = a * n
  | 0, a => by rw [zero_smul, Nat.cast_zero, MulZeroClass.mul_zero]
  | n + 1, a => by rw [succ_nsmul', Nat.cast_add, mul_add, Nat.cast_one, mul_one, smul_eq_mul]
#align ordinal.smul_eq_mul Ordinal.smul_eq_mul
-/

/-! ### Division on ordinals -/


#print Ordinal.div_nonempty /-
/-- The set in the definition of division is nonempty. -/
theorem div_nonempty {a b : Ordinal} (h : b ≠ 0) : {o | a < b * succ o}.Nonempty :=
  ⟨a,
    succ_le_iff.1 <| by
      simpa only [succ_zero, one_mul] using
        mul_le_mul_right' (succ_le_of_lt (Ordinal.pos_iff_ne_zero.2 h)) (succ a)⟩
#align ordinal.div_nonempty Ordinal.div_nonempty
-/

/-- `a / b` is the unique ordinal `o` satisfying `a = b * o + o'` with `o' < b`. -/
instance : Div Ordinal :=
  ⟨fun a b => if h : b = 0 then 0 else sInf {o | a < b * succ o}⟩

#print Ordinal.div_zero /-
@[simp]
theorem div_zero (a : Ordinal) : a / 0 = 0 :=
  dif_pos rfl
#align ordinal.div_zero Ordinal.div_zero
-/

#print Ordinal.div_def /-
theorem div_def (a) {b : Ordinal} (h : b ≠ 0) : a / b = sInf {o | a < b * succ o} :=
  dif_neg h
#align ordinal.div_def Ordinal.div_def
-/

#print Ordinal.lt_mul_succ_div /-
theorem lt_mul_succ_div (a) {b : Ordinal} (h : b ≠ 0) : a < b * succ (a / b) := by
  rw [div_def a h] <;> exact csInf_mem (div_nonempty h)
#align ordinal.lt_mul_succ_div Ordinal.lt_mul_succ_div
-/

#print Ordinal.lt_mul_div_add /-
theorem lt_mul_div_add (a) {b : Ordinal} (h : b ≠ 0) : a < b * (a / b) + b := by
  simpa only [mul_succ] using lt_mul_succ_div a h
#align ordinal.lt_mul_div_add Ordinal.lt_mul_div_add
-/

#print Ordinal.div_le /-
theorem div_le {a b c : Ordinal} (b0 : b ≠ 0) : a / b ≤ c ↔ a < b * succ c :=
  ⟨fun h => (lt_mul_succ_div a b0).trans_le (mul_le_mul_left' (succ_le_succ_iff.2 h) _), fun h => by
    rw [div_def a b0] <;> exact csInf_le' h⟩
#align ordinal.div_le Ordinal.div_le
-/

#print Ordinal.lt_div /-
theorem lt_div {a b c : Ordinal} (h : c ≠ 0) : a < b / c ↔ c * succ a ≤ b := by
  rw [← not_le, div_le h, not_lt]
#align ordinal.lt_div Ordinal.lt_div
-/

#print Ordinal.div_pos /-
theorem div_pos {b c : Ordinal} (h : c ≠ 0) : 0 < b / c ↔ c ≤ b := by simp [lt_div h]
#align ordinal.div_pos Ordinal.div_pos
-/

#print Ordinal.le_div /-
theorem le_div {a b c : Ordinal} (c0 : c ≠ 0) : a ≤ b / c ↔ c * a ≤ b :=
  by
  apply limit_rec_on a
  · simp only [MulZeroClass.mul_zero, Ordinal.zero_le]
  · intros; rw [succ_le_iff, lt_div c0]
  ·
    simp (config := { contextual := true }) only [mul_le_of_limit, limit_le, iff_self_iff,
      forall_true_iff]
#align ordinal.le_div Ordinal.le_div
-/

#print Ordinal.div_lt /-
theorem div_lt {a b c : Ordinal} (b0 : b ≠ 0) : a / b < c ↔ a < b * c :=
  lt_iff_lt_of_le_iff_le <| le_div b0
#align ordinal.div_lt Ordinal.div_lt
-/

#print Ordinal.div_le_of_le_mul /-
theorem div_le_of_le_mul {a b c : Ordinal} (h : a ≤ b * c) : a / b ≤ c :=
  if b0 : b = 0 then by simp only [b0, div_zero, Ordinal.zero_le]
  else
    (div_le b0).2 <| h.trans_lt <| mul_lt_mul_of_pos_left (lt_succ c) (Ordinal.pos_iff_ne_zero.2 b0)
#align ordinal.div_le_of_le_mul Ordinal.div_le_of_le_mul
-/

#print Ordinal.mul_lt_of_lt_div /-
theorem mul_lt_of_lt_div {a b c : Ordinal} : a < b / c → c * a < b :=
  lt_imp_lt_of_le_imp_le div_le_of_le_mul
#align ordinal.mul_lt_of_lt_div Ordinal.mul_lt_of_lt_div
-/

#print Ordinal.zero_div /-
@[simp]
theorem zero_div (a : Ordinal) : 0 / a = 0 :=
  Ordinal.le_zero.1 <| div_le_of_le_mul <| Ordinal.zero_le _
#align ordinal.zero_div Ordinal.zero_div
-/

#print Ordinal.mul_div_le /-
theorem mul_div_le (a b : Ordinal) : b * (a / b) ≤ a :=
  if b0 : b = 0 then by simp only [b0, MulZeroClass.zero_mul, Ordinal.zero_le]
  else (le_div b0).1 le_rfl
#align ordinal.mul_div_le Ordinal.mul_div_le
-/

#print Ordinal.mul_add_div /-
theorem mul_add_div (a) {b : Ordinal} (b0 : b ≠ 0) (c) : (b * a + c) / b = a + c / b :=
  by
  apply le_antisymm
  · apply (div_le b0).2
    rw [mul_succ, mul_add, add_assoc, add_lt_add_iff_left]
    apply lt_mul_div_add _ b0
  · rw [le_div b0, mul_add, add_le_add_iff_left]
    apply mul_div_le
#align ordinal.mul_add_div Ordinal.mul_add_div
-/

#print Ordinal.div_eq_zero_of_lt /-
theorem div_eq_zero_of_lt {a b : Ordinal} (h : a < b) : a / b = 0 :=
  by
  rw [← Ordinal.le_zero, div_le <| Ordinal.pos_iff_ne_zero.1 <| (Ordinal.zero_le _).trans_lt h]
  simpa only [succ_zero, mul_one] using h
#align ordinal.div_eq_zero_of_lt Ordinal.div_eq_zero_of_lt
-/

#print Ordinal.mul_div_cancel /-
@[simp]
theorem mul_div_cancel (a) {b : Ordinal} (b0 : b ≠ 0) : b * a / b = a := by
  simpa only [add_zero, zero_div] using mul_add_div a b0 0
#align ordinal.mul_div_cancel Ordinal.mul_div_cancel
-/

#print Ordinal.div_one /-
@[simp]
theorem div_one (a : Ordinal) : a / 1 = a := by
  simpa only [one_mul] using mul_div_cancel a Ordinal.one_ne_zero
#align ordinal.div_one Ordinal.div_one
-/

#print Ordinal.div_self /-
@[simp]
theorem div_self {a : Ordinal} (h : a ≠ 0) : a / a = 1 := by
  simpa only [mul_one] using mul_div_cancel 1 h
#align ordinal.div_self Ordinal.div_self
-/

#print Ordinal.mul_sub /-
theorem mul_sub (a b c : Ordinal) : a * (b - c) = a * b - a * c :=
  if a0 : a = 0 then by simp only [a0, MulZeroClass.zero_mul, sub_self]
  else
    eq_of_forall_ge_iff fun d => by rw [sub_le, ← le_div a0, sub_le, ← le_div a0, mul_add_div _ a0]
#align ordinal.mul_sub Ordinal.mul_sub
-/

#print Ordinal.isLimit_add_iff /-
theorem isLimit_add_iff {a b} : IsLimit (a + b) ↔ IsLimit b ∨ b = 0 ∧ IsLimit a :=
  by
  constructor <;> intro h
  · by_cases h' : b = 0
    · rw [h', add_zero] at h ; right; exact ⟨h', h⟩
    left; rw [← add_sub_cancel a b]; apply sub_is_limit h
    suffices : a + 0 < a + b; simpa only [add_zero]
    rwa [add_lt_add_iff_left, Ordinal.pos_iff_ne_zero]
  rcases h with (h | ⟨rfl, h⟩); exact add_is_limit a h; simpa only [add_zero]
#align ordinal.is_limit_add_iff Ordinal.isLimit_add_iff
-/

#print Ordinal.dvd_add_iff /-
theorem dvd_add_iff : ∀ {a b c : Ordinal}, a ∣ b → (a ∣ b + c ↔ a ∣ c)
  | a, _, c, ⟨b, rfl⟩ =>
    ⟨fun ⟨d, e⟩ => ⟨d - b, by rw [mul_sub, ← e, add_sub_cancel]⟩, fun ⟨d, e⟩ => by
      rw [e, ← mul_add]; apply dvd_mul_right⟩
#align ordinal.dvd_add_iff Ordinal.dvd_add_iff
-/

#print Ordinal.div_mul_cancel /-
theorem div_mul_cancel : ∀ {a b : Ordinal}, a ≠ 0 → a ∣ b → a * (b / a) = b
  | a, _, a0, ⟨b, rfl⟩ => by rw [mul_div_cancel _ a0]
#align ordinal.div_mul_cancel Ordinal.div_mul_cancel
-/

#print Ordinal.le_of_dvd /-
theorem le_of_dvd : ∀ {a b : Ordinal}, b ≠ 0 → a ∣ b → a ≤ b
  | a, _, b0, ⟨b, rfl⟩ => by
    simpa only [mul_one] using
      mul_le_mul_left'
        (one_le_iff_ne_zero.2 fun h : b = 0 => by simpa only [h, MulZeroClass.mul_zero] using b0) a
#align ordinal.le_of_dvd Ordinal.le_of_dvd
-/

#print Ordinal.dvd_antisymm /-
theorem dvd_antisymm {a b : Ordinal} (h₁ : a ∣ b) (h₂ : b ∣ a) : a = b :=
  if a0 : a = 0 then by subst a <;> exact (eq_zero_of_zero_dvd h₁).symm
  else
    if b0 : b = 0 then by subst b <;> exact eq_zero_of_zero_dvd h₂
    else (le_of_dvd b0 h₁).antisymm (le_of_dvd a0 h₂)
#align ordinal.dvd_antisymm Ordinal.dvd_antisymm
-/

instance : IsAntisymm Ordinal (· ∣ ·) :=
  ⟨@dvd_antisymm⟩

/-- `a % b` is the unique ordinal `o'` satisfying
  `a = b * o + o'` with `o' < b`. -/
instance : Mod Ordinal :=
  ⟨fun a b => a - b * (a / b)⟩

#print Ordinal.mod_def /-
theorem mod_def (a b : Ordinal) : a % b = a - b * (a / b) :=
  rfl
#align ordinal.mod_def Ordinal.mod_def
-/

#print Ordinal.mod_le /-
theorem mod_le (a b : Ordinal) : a % b ≤ a :=
  sub_le_self a _
#align ordinal.mod_le Ordinal.mod_le
-/

#print Ordinal.mod_zero /-
@[simp]
theorem mod_zero (a : Ordinal) : a % 0 = a := by
  simp only [mod_def, div_zero, MulZeroClass.zero_mul, sub_zero]
#align ordinal.mod_zero Ordinal.mod_zero
-/

#print Ordinal.mod_eq_of_lt /-
theorem mod_eq_of_lt {a b : Ordinal} (h : a < b) : a % b = a := by
  simp only [mod_def, div_eq_zero_of_lt h, MulZeroClass.mul_zero, sub_zero]
#align ordinal.mod_eq_of_lt Ordinal.mod_eq_of_lt
-/

#print Ordinal.zero_mod /-
@[simp]
theorem zero_mod (b : Ordinal) : 0 % b = 0 := by
  simp only [mod_def, zero_div, MulZeroClass.mul_zero, sub_self]
#align ordinal.zero_mod Ordinal.zero_mod
-/

#print Ordinal.div_add_mod /-
theorem div_add_mod (a b : Ordinal) : b * (a / b) + a % b = a :=
  Ordinal.add_sub_cancel_of_le <| mul_div_le _ _
#align ordinal.div_add_mod Ordinal.div_add_mod
-/

#print Ordinal.mod_lt /-
theorem mod_lt (a) {b : Ordinal} (h : b ≠ 0) : a % b < b :=
  (add_lt_add_iff_left (b * (a / b))).1 <| by rw [div_add_mod] <;> exact lt_mul_div_add a h
#align ordinal.mod_lt Ordinal.mod_lt
-/

#print Ordinal.mod_self /-
@[simp]
theorem mod_self (a : Ordinal) : a % a = 0 :=
  if a0 : a = 0 then by simp only [a0, zero_mod]
  else by simp only [mod_def, div_self a0, mul_one, sub_self]
#align ordinal.mod_self Ordinal.mod_self
-/

#print Ordinal.mod_one /-
@[simp]
theorem mod_one (a : Ordinal) : a % 1 = 0 := by simp only [mod_def, div_one, one_mul, sub_self]
#align ordinal.mod_one Ordinal.mod_one
-/

#print Ordinal.dvd_of_mod_eq_zero /-
theorem dvd_of_mod_eq_zero {a b : Ordinal} (H : a % b = 0) : b ∣ a :=
  ⟨a / b, by simpa [H] using (div_add_mod a b).symm⟩
#align ordinal.dvd_of_mod_eq_zero Ordinal.dvd_of_mod_eq_zero
-/

#print Ordinal.mod_eq_zero_of_dvd /-
theorem mod_eq_zero_of_dvd {a b : Ordinal} (H : b ∣ a) : a % b = 0 :=
  by
  rcases H with ⟨c, rfl⟩
  rcases eq_or_ne b 0 with (rfl | hb)
  · simp
  · simp [mod_def, hb]
#align ordinal.mod_eq_zero_of_dvd Ordinal.mod_eq_zero_of_dvd
-/

#print Ordinal.dvd_iff_mod_eq_zero /-
theorem dvd_iff_mod_eq_zero {a b : Ordinal} : b ∣ a ↔ a % b = 0 :=
  ⟨mod_eq_zero_of_dvd, dvd_of_mod_eq_zero⟩
#align ordinal.dvd_iff_mod_eq_zero Ordinal.dvd_iff_mod_eq_zero
-/

#print Ordinal.mul_add_mod_self /-
@[simp]
theorem mul_add_mod_self (x y z : Ordinal) : (x * y + z) % x = z % x :=
  by
  rcases eq_or_ne x 0 with (rfl | hx)
  · simp
  · rwa [mod_def, mul_add_div, mul_add, ← sub_sub, add_sub_cancel, mod_def]
#align ordinal.mul_add_mod_self Ordinal.mul_add_mod_self
-/

#print Ordinal.mul_mod /-
@[simp]
theorem mul_mod (x y : Ordinal) : x * y % x = 0 := by simpa using mul_add_mod_self x y 0
#align ordinal.mul_mod Ordinal.mul_mod
-/

#print Ordinal.mod_mod_of_dvd /-
theorem mod_mod_of_dvd (a : Ordinal) {b c : Ordinal} (h : c ∣ b) : a % b % c = a % c :=
  by
  nth_rw_rhs 1 [← div_add_mod a b]
  rcases h with ⟨d, rfl⟩
  rw [mul_assoc, mul_add_mod_self]
#align ordinal.mod_mod_of_dvd Ordinal.mod_mod_of_dvd
-/

#print Ordinal.mod_mod /-
@[simp]
theorem mod_mod (a b : Ordinal) : a % b % b = a % b :=
  mod_mod_of_dvd a dvd_rfl
#align ordinal.mod_mod Ordinal.mod_mod
-/

/-! ### Families of ordinals

There are two kinds of indexed families that naturally arise when dealing with ordinals: those
indexed by some type in the appropriate universe, and those indexed by ordinals less than another.
The following API allows one to convert from one kind of family to the other.

In many cases, this makes it easy to prove claims about one kind of family via the corresponding
claim on the other. -/


#print Ordinal.bfamilyOfFamily' /-
/-- Converts a family indexed by a `Type u` to one indexed by an `ordinal.{u}` using a specified
well-ordering. -/
def bfamilyOfFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → α) :
    ∀ a < type r, α := fun a ha => f (enum r a ha)
#align ordinal.bfamily_of_family' Ordinal.bfamilyOfFamily'
-/

#print Ordinal.bfamilyOfFamily /-
/-- Converts a family indexed by a `Type u` to one indexed by an `ordinal.{u}` using a well-ordering
given by the axiom of choice. -/
def bfamilyOfFamily {ι : Type u} : (ι → α) → ∀ a < type (@WellOrderingRel ι), α :=
  bfamilyOfFamily' WellOrderingRel
#align ordinal.bfamily_of_family Ordinal.bfamilyOfFamily
-/

#print Ordinal.familyOfBFamily' /-
/-- Converts a family indexed by an `ordinal.{u}` to one indexed by an `Type u` using a specified
well-ordering. -/
def familyOfBFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] {o} (ho : type r = o)
    (f : ∀ a < o, α) : ι → α := fun i => f (typein r i) (by rw [← ho]; exact typein_lt_type r i)
#align ordinal.family_of_bfamily' Ordinal.familyOfBFamily'
-/

#print Ordinal.familyOfBFamily /-
/-- Converts a family indexed by an `ordinal.{u}` to one indexed by a `Type u` using a well-ordering
given by the axiom of choice. -/
def familyOfBFamily (o : Ordinal) (f : ∀ a < o, α) : o.out.α → α :=
  familyOfBFamily' (· < ·) (type_lt o) f
#align ordinal.family_of_bfamily Ordinal.familyOfBFamily
-/

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

#print Ordinal.familyOfBFamily'_enum /-
@[simp]
theorem familyOfBFamily'_enum {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] {o}
    (ho : type r = o) (f : ∀ a < o, α) (i hi) :
    familyOfBFamily' r ho f (enum r i (by rwa [ho])) = f i hi := by
  simp only [family_of_bfamily', typein_enum]
#align ordinal.family_of_bfamily'_enum Ordinal.familyOfBFamily'_enum
-/

#print Ordinal.familyOfBFamily_enum /-
@[simp]
theorem familyOfBFamily_enum (o : Ordinal) (f : ∀ a < o, α) (i hi) :
    familyOfBFamily o f (enum (· < ·) i (by convert hi; exact type_lt _)) = f i hi :=
  familyOfBFamily'_enum _ (type_lt o) f _ _
#align ordinal.family_of_bfamily_enum Ordinal.familyOfBFamily_enum
-/

#print Ordinal.brange /-
/-- The range of a family indexed by ordinals. -/
def brange (o : Ordinal) (f : ∀ a < o, α) : Set α :=
  {a | ∃ i hi, f i hi = a}
#align ordinal.brange Ordinal.brange
-/

#print Ordinal.mem_brange /-
theorem mem_brange {o : Ordinal} {f : ∀ a < o, α} {a} : a ∈ brange o f ↔ ∃ i hi, f i hi = a :=
  Iff.rfl
#align ordinal.mem_brange Ordinal.mem_brange
-/

#print Ordinal.mem_brange_self /-
theorem mem_brange_self {o} (f : ∀ a < o, α) (i hi) : f i hi ∈ brange o f :=
  ⟨i, hi, rfl⟩
#align ordinal.mem_brange_self Ordinal.mem_brange_self
-/

#print Ordinal.range_familyOfBFamily' /-
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
-/

#print Ordinal.range_familyOfBFamily /-
@[simp]
theorem range_familyOfBFamily {o} (f : ∀ a < o, α) : range (familyOfBFamily o f) = brange o f :=
  range_familyOfBFamily' _ _ f
#align ordinal.range_family_of_bfamily Ordinal.range_familyOfBFamily
-/

#print Ordinal.brange_bfamilyOfFamily' /-
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
-/

#print Ordinal.brange_bfamilyOfFamily /-
@[simp]
theorem brange_bfamilyOfFamily {ι : Type u} (f : ι → α) : brange _ (bfamilyOfFamily f) = range f :=
  brange_bfamilyOfFamily' _ _
#align ordinal.brange_bfamily_of_family Ordinal.brange_bfamilyOfFamily
-/

#print Ordinal.brange_const /-
@[simp]
theorem brange_const {o : Ordinal} (ho : o ≠ 0) {c : α} : (brange o fun _ _ => c) = {c} :=
  by
  rw [← range_family_of_bfamily]
  exact @Set.range_const _ o.out.α (out_nonempty_iff_ne_zero.2 ho) c
#align ordinal.brange_const Ordinal.brange_const
-/

#print Ordinal.comp_bfamilyOfFamily' /-
theorem comp_bfamilyOfFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] (f : ι → α)
    (g : α → β) : (fun i hi => g (bfamilyOfFamily' r f i hi)) = bfamilyOfFamily' r (g ∘ f) :=
  rfl
#align ordinal.comp_bfamily_of_family' Ordinal.comp_bfamilyOfFamily'
-/

#print Ordinal.comp_bfamilyOfFamily /-
theorem comp_bfamilyOfFamily {ι : Type u} (f : ι → α) (g : α → β) :
    (fun i hi => g (bfamilyOfFamily f i hi)) = bfamilyOfFamily (g ∘ f) :=
  rfl
#align ordinal.comp_bfamily_of_family Ordinal.comp_bfamilyOfFamily
-/

#print Ordinal.comp_familyOfBFamily' /-
theorem comp_familyOfBFamily' {ι : Type u} (r : ι → ι → Prop) [IsWellOrder ι r] {o}
    (ho : type r = o) (f : ∀ a < o, α) (g : α → β) :
    g ∘ familyOfBFamily' r ho f = familyOfBFamily' r ho fun i hi => g (f i hi) :=
  rfl
#align ordinal.comp_family_of_bfamily' Ordinal.comp_familyOfBFamily'
-/

#print Ordinal.comp_familyOfBFamily /-
theorem comp_familyOfBFamily {o} (f : ∀ a < o, α) (g : α → β) :
    g ∘ familyOfBFamily o f = familyOfBFamily o fun i hi => g (f i hi) :=
  rfl
#align ordinal.comp_family_of_bfamily Ordinal.comp_familyOfBFamily
-/

/-! ### Supremum of a family of ordinals -/


#print Ordinal.sup /-
/-- The supremum of a family of ordinals -/
def sup {ι : Type u} (f : ι → Ordinal.{max u v}) : Ordinal.{max u v} :=
  iSup f
#align ordinal.sup Ordinal.sup
-/

#print Ordinal.sSup_eq_sup /-
@[simp]
theorem sSup_eq_sup {ι : Type u} (f : ι → Ordinal.{max u v}) : sSup (Set.range f) = sup f :=
  rfl
#align ordinal.Sup_eq_sup Ordinal.sSup_eq_sup
-/

#print Ordinal.bddAbove_range /-
/-- The range of an indexed ordinal function, whose outputs live in a higher universe than the
    inputs, is always bounded above. See `ordinal.lsub` for an explicit bound. -/
theorem bddAbove_range {ι : Type u} (f : ι → Ordinal.{max u v}) : BddAbove (Set.range f) :=
  ⟨(iSup (succ ∘ card ∘ f)).ord, by
    rintro a ⟨i, rfl⟩
    exact le_of_lt (Cardinal.lt_ord.2 ((lt_succ _).trans_le (le_ciSup (bdd_above_range _) _)))⟩
#align ordinal.bdd_above_range Ordinal.bddAbove_range
-/

#print Ordinal.le_sup /-
theorem le_sup {ι} (f : ι → Ordinal) : ∀ i, f i ≤ sup f := fun i =>
  le_csSup (bddAbove_range f) (mem_range_self i)
#align ordinal.le_sup Ordinal.le_sup
-/

#print Ordinal.sup_le_iff /-
theorem sup_le_iff {ι} {f : ι → Ordinal} {a} : sup f ≤ a ↔ ∀ i, f i ≤ a :=
  (csSup_le_iff' (bddAbove_range f)).trans (by simp)
#align ordinal.sup_le_iff Ordinal.sup_le_iff
-/

#print Ordinal.sup_le /-
theorem sup_le {ι} {f : ι → Ordinal} {a} : (∀ i, f i ≤ a) → sup f ≤ a :=
  sup_le_iff.2
#align ordinal.sup_le Ordinal.sup_le
-/

#print Ordinal.lt_sup /-
theorem lt_sup {ι} {f : ι → Ordinal} {a} : a < sup f ↔ ∃ i, a < f i := by
  simpa only [not_forall, not_le] using not_congr (@sup_le_iff _ f a)
#align ordinal.lt_sup Ordinal.lt_sup
-/

#print Ordinal.ne_sup_iff_lt_sup /-
theorem ne_sup_iff_lt_sup {ι} {f : ι → Ordinal} : (∀ i, f i ≠ sup f) ↔ ∀ i, f i < sup f :=
  ⟨fun hf _ => lt_of_le_of_ne (le_sup _ _) (hf _), fun hf _ => ne_of_lt (hf _)⟩
#align ordinal.ne_sup_iff_lt_sup Ordinal.ne_sup_iff_lt_sup
-/

#print Ordinal.sup_not_succ_of_ne_sup /-
theorem sup_not_succ_of_ne_sup {ι} {f : ι → Ordinal} (hf : ∀ i, f i ≠ sup f) {a} (hao : a < sup f) :
    succ a < sup f := by
  by_contra' hoa
  exact
    hao.not_le (sup_le fun i => le_of_lt_succ <| (lt_of_le_of_ne (le_sup _ _) (hf i)).trans_le hoa)
#align ordinal.sup_not_succ_of_ne_sup Ordinal.sup_not_succ_of_ne_sup
-/

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

#print Ordinal.sup_empty /-
@[simp]
theorem sup_empty {ι} [IsEmpty ι] (f : ι → Ordinal) : sup f = 0 :=
  ciSup_of_empty f
#align ordinal.sup_empty Ordinal.sup_empty
-/

#print Ordinal.sup_const /-
@[simp]
theorem sup_const {ι} [hι : Nonempty ι] (o : Ordinal) : (sup fun _ : ι => o) = o :=
  ciSup_const
#align ordinal.sup_const Ordinal.sup_const
-/

#print Ordinal.sup_unique /-
@[simp]
theorem sup_unique {ι} [Unique ι] (f : ι → Ordinal) : sup f = f default :=
  ciSup_unique
#align ordinal.sup_unique Ordinal.sup_unique
-/

#print Ordinal.sup_le_of_range_subset /-
theorem sup_le_of_range_subset {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f ⊆ Set.range g) : sup.{u, max v w} f ≤ sup.{v, max u w} g :=
  sup_le fun i =>
    match h (mem_range_self i) with
    | ⟨j, hj⟩ => hj ▸ le_sup _ _
#align ordinal.sup_le_of_range_subset Ordinal.sup_le_of_range_subset
-/

#print Ordinal.sup_eq_of_range_eq /-
theorem sup_eq_of_range_eq {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f = Set.range g) : sup.{u, max v w} f = sup.{v, max u w} g :=
  (sup_le_of_range_subset h.le).antisymm (sup_le_of_range_subset.{v, u, w} h.ge)
#align ordinal.sup_eq_of_range_eq Ordinal.sup_eq_of_range_eq
-/

#print Ordinal.sup_sum /-
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
-/

#print Ordinal.unbounded_range_of_sup_ge /-
theorem unbounded_range_of_sup_ge {α β : Type u} (r : α → α → Prop) [IsWellOrder α r] (f : β → α)
    (h : type r ≤ sup.{u, u} (typein r ∘ f)) : Unbounded r (range f) :=
  (not_bounded_iff _).1 fun ⟨x, hx⟩ =>
    not_lt_of_le h <|
      lt_of_le_of_lt
        (sup_le fun y => le_of_lt <| (typein_lt_typein r).2 <| hx _ <| mem_range_self y)
        (typein_lt_type r x)
#align ordinal.unbounded_range_of_sup_ge Ordinal.unbounded_range_of_sup_ge
-/

#print Ordinal.le_sup_shrink_equiv /-
theorem le_sup_shrink_equiv {s : Set Ordinal.{u}} (hs : Small.{u} s) (a) (ha : a ∈ s) :
    a ≤ sup.{u, u} fun x => ((@equivShrink s hs).symm x).val := by
  convert le_sup.{u, u} _ ((@equivShrink s hs) ⟨a, ha⟩); rw [symm_apply_apply]
#align ordinal.le_sup_shrink_equiv Ordinal.le_sup_shrink_equiv
-/

#print Ordinal.small_Iio /-
instance small_Iio (o : Ordinal.{u}) : Small.{u} (Set.Iio o) :=
  let f : o.out.α → Set.Iio o := fun x => ⟨typein (· < ·) x, typein_lt_self x⟩
  let hf : Surjective f := fun b =>
    ⟨enum (· < ·) b.val (by rw [type_lt]; exact b.prop), Subtype.ext (typein_enum _ _)⟩
  small_of_surjective hf
#align ordinal.small_Iio Ordinal.small_Iio
-/

#print Ordinal.small_Iic /-
instance small_Iic (o : Ordinal.{u}) : Small.{u} (Set.Iic o) := by rw [← Iio_succ]; infer_instance
#align ordinal.small_Iic Ordinal.small_Iic
-/

#print Ordinal.bddAbove_iff_small /-
theorem bddAbove_iff_small {s : Set Ordinal.{u}} : BddAbove s ↔ Small.{u} s :=
  ⟨fun ⟨a, h⟩ => small_subset <| show s ⊆ Iic a from fun x hx => h hx, fun h =>
    ⟨sup.{u, u} fun x => ((@equivShrink s h).symm x).val, le_sup_shrink_equiv h⟩⟩
#align ordinal.bdd_above_iff_small Ordinal.bddAbove_iff_small
-/

#print Ordinal.bddAbove_of_small /-
theorem bddAbove_of_small (s : Set Ordinal.{u}) [h : Small.{u} s] : BddAbove s :=
  bddAbove_iff_small.2 h
#align ordinal.bdd_above_of_small Ordinal.bddAbove_of_small
-/

#print Ordinal.sup_eq_sSup /-
theorem sup_eq_sSup {s : Set Ordinal.{u}} (hs : Small.{u} s) :
    (sup.{u, u} fun x => (@equivShrink s hs).symm x) = sSup s :=
  let hs' := bddAbove_iff_small.2 hs
  ((csSup_le_iff' hs').2 (le_sup_shrink_equiv hs)).antisymm'
    (sup_le fun x => le_csSup hs' (Subtype.mem _))
#align ordinal.sup_eq_Sup Ordinal.sup_eq_sSup
-/

#print Ordinal.sSup_ord /-
theorem sSup_ord {s : Set Cardinal.{u}} (hs : BddAbove s) : (sSup s).ord = sSup (ord '' s) :=
  eq_of_forall_ge_iff fun a =>
    by
    rw [csSup_le_iff'
        (bdd_above_iff_small.2 (@small_image _ _ _ s (Cardinal.bddAbove_iff_small.1 hs))),
      ord_le, csSup_le_iff' hs]
    simp [ord_le]
#align ordinal.Sup_ord Ordinal.sSup_ord
-/

#print Ordinal.iSup_ord /-
theorem iSup_ord {ι} {f : ι → Cardinal} (hf : BddAbove (range f)) : (iSup f).ord = ⨆ i, (f i).ord :=
  by unfold iSup; convert Sup_ord hf; rw [range_comp]
#align ordinal.supr_ord Ordinal.iSup_ord
-/

private theorem sup_le_sup {ι ι' : Type u} (r : ι → ι → Prop) (r' : ι' → ι' → Prop)
    [IsWellOrder ι r] [IsWellOrder ι' r'] {o} (ho : type r = o) (ho' : type r' = o)
    (f : ∀ a < o, Ordinal) : sup (familyOfBFamily' r ho f) ≤ sup (familyOfBFamily' r' ho' f) :=
  sup_le fun i =>
    by
    cases' typein_surj r' (by rw [ho', ← ho]; exact typein_lt_type r i) with j hj
    simp_rw [family_of_bfamily', ← hj]
    apply le_sup

#print Ordinal.sup_eq_sup /-
theorem sup_eq_sup {ι ι' : Type u} (r : ι → ι → Prop) (r' : ι' → ι' → Prop) [IsWellOrder ι r]
    [IsWellOrder ι' r'] {o : Ordinal.{u}} (ho : type r = o) (ho' : type r' = o)
    (f : ∀ a < o, Ordinal.{max u v}) :
    sup (familyOfBFamily' r ho f) = sup (familyOfBFamily' r' ho' f) :=
  sup_eq_of_range_eq.{u, u, v} (by simp)
#align ordinal.sup_eq_sup Ordinal.sup_eq_sup
-/

#print Ordinal.bsup /-
/-- The supremum of a family of ordinals indexed by the set of ordinals less than some
    `o : ordinal.{u}`. This is a special case of `sup` over the family provided by
    `family_of_bfamily`. -/
def bsup (o : Ordinal.{u}) (f : ∀ a < o, Ordinal.{max u v}) : Ordinal.{max u v} :=
  sup (familyOfBFamily o f)
#align ordinal.bsup Ordinal.bsup
-/

#print Ordinal.sup_eq_bsup /-
@[simp]
theorem sup_eq_bsup {o} (f : ∀ a < o, Ordinal) : sup (familyOfBFamily o f) = bsup o f :=
  rfl
#align ordinal.sup_eq_bsup Ordinal.sup_eq_bsup
-/

#print Ordinal.sup_eq_bsup' /-
@[simp]
theorem sup_eq_bsup' {o ι} (r : ι → ι → Prop) [IsWellOrder ι r] (ho : type r = o) (f) :
    sup (familyOfBFamily' r ho f) = bsup o f :=
  sup_eq_sup r _ ho _ f
#align ordinal.sup_eq_bsup' Ordinal.sup_eq_bsup'
-/

#print Ordinal.sSup_eq_bsup /-
@[simp]
theorem sSup_eq_bsup {o} (f : ∀ a < o, Ordinal) : sSup (brange o f) = bsup o f := by congr;
  rw [range_family_of_bfamily]
#align ordinal.Sup_eq_bsup Ordinal.sSup_eq_bsup
-/

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

#print Ordinal.bsup_congr /-
@[congr]
theorem bsup_congr {o₁ o₂ : Ordinal} (f : ∀ a < o₁, Ordinal) (ho : o₁ = o₂) :
    bsup o₁ f = bsup o₂ fun a h => f a (h.trans_eq ho.symm) := by subst ho
#align ordinal.bsup_congr Ordinal.bsup_congr
-/

#print Ordinal.bsup_le_iff /-
theorem bsup_le_iff {o f a} : bsup.{u, v} o f ≤ a ↔ ∀ i h, f i h ≤ a :=
  sup_le_iff.trans ⟨fun h i hi => by rw [← family_of_bfamily_enum o f]; exact h _, fun h i => h _ _⟩
#align ordinal.bsup_le_iff Ordinal.bsup_le_iff
-/

#print Ordinal.bsup_le /-
theorem bsup_le {o : Ordinal} {f : ∀ b < o, Ordinal} {a} :
    (∀ i h, f i h ≤ a) → bsup.{u, v} o f ≤ a :=
  bsup_le_iff.2
#align ordinal.bsup_le Ordinal.bsup_le
-/

#print Ordinal.le_bsup /-
theorem le_bsup {o} (f : ∀ a < o, Ordinal) (i h) : f i h ≤ bsup o f :=
  bsup_le_iff.1 le_rfl _ _
#align ordinal.le_bsup Ordinal.le_bsup
-/

#print Ordinal.lt_bsup /-
theorem lt_bsup {o} (f : ∀ a < o, Ordinal) {a} : a < bsup o f ↔ ∃ i hi, a < f i hi := by
  simpa only [not_forall, not_le] using not_congr (@bsup_le_iff _ f a)
#align ordinal.lt_bsup Ordinal.lt_bsup
-/

#print Ordinal.IsNormal.bsup /-
theorem IsNormal.bsup {f} (H : IsNormal f) {o} :
    ∀ (g : ∀ a < o, Ordinal) (h : o ≠ 0), f (bsup o g) = bsup o fun a h => f (g a h) :=
  inductionOn o fun α r _ g h => by
    skip
    haveI := type_ne_zero_iff_nonempty.1 h
    rw [← sup_eq_bsup' r, H.sup, ← sup_eq_bsup' r] <;> rfl
#align ordinal.is_normal.bsup Ordinal.IsNormal.bsup
-/

#print Ordinal.lt_bsup_of_ne_bsup /-
theorem lt_bsup_of_ne_bsup {o : Ordinal} {f : ∀ a < o, Ordinal} :
    (∀ i h, f i h ≠ o.bsup f) ↔ ∀ i h, f i h < o.bsup f :=
  ⟨fun hf _ _ => lt_of_le_of_ne (le_bsup _ _ _) (hf _ _), fun hf _ _ => ne_of_lt (hf _ _)⟩
#align ordinal.lt_bsup_of_ne_bsup Ordinal.lt_bsup_of_ne_bsup
-/

#print Ordinal.bsup_not_succ_of_ne_bsup /-
theorem bsup_not_succ_of_ne_bsup {o} {f : ∀ a < o, Ordinal}
    (hf : ∀ {i : Ordinal} (h : i < o), f i h ≠ o.bsup f) (a) : a < bsup o f → succ a < bsup o f :=
  by rw [← sup_eq_bsup] at *; exact sup_not_succ_of_ne_sup fun i => hf _
#align ordinal.bsup_not_succ_of_ne_bsup Ordinal.bsup_not_succ_of_ne_bsup
-/

#print Ordinal.bsup_eq_zero_iff /-
@[simp]
theorem bsup_eq_zero_iff {o} {f : ∀ a < o, Ordinal} : bsup o f = 0 ↔ ∀ i hi, f i hi = 0 :=
  by
  refine'
    ⟨fun h i hi => _, fun h =>
      le_antisymm (bsup_le fun i hi => Ordinal.le_zero.2 (h i hi)) (Ordinal.zero_le _)⟩
  rw [← Ordinal.le_zero, ← h]
  exact le_bsup f i hi
#align ordinal.bsup_eq_zero_iff Ordinal.bsup_eq_zero_iff
-/

#print Ordinal.lt_bsup_of_limit /-
theorem lt_bsup_of_limit {o : Ordinal} {f : ∀ a < o, Ordinal}
    (hf : ∀ {a a'} (ha : a < o) (ha' : a' < o), a < a' → f a ha < f a' ha')
    (ho : ∀ a < o, succ a < o) (i h) : f i h < bsup o f :=
  (hf _ _ <| lt_succ i).trans_le (le_bsup f (succ i) <| ho _ h)
#align ordinal.lt_bsup_of_limit Ordinal.lt_bsup_of_limit
-/

#print Ordinal.bsup_succ_of_mono /-
theorem bsup_succ_of_mono {o : Ordinal} {f : ∀ a < succ o, Ordinal}
    (hf : ∀ {i j} (hi hj), i ≤ j → f i hi ≤ f j hj) : bsup _ f = f o (lt_succ o) :=
  le_antisymm (bsup_le fun i hi => hf _ _ <| le_of_lt_succ hi) (le_bsup _ _ _)
#align ordinal.bsup_succ_of_mono Ordinal.bsup_succ_of_mono
-/

#print Ordinal.bsup_zero /-
@[simp]
theorem bsup_zero (f : ∀ a < (0 : Ordinal), Ordinal) : bsup 0 f = 0 :=
  bsup_eq_zero_iff.2 fun i hi => (Ordinal.not_lt_zero i hi).elim
#align ordinal.bsup_zero Ordinal.bsup_zero
-/

#print Ordinal.bsup_const /-
theorem bsup_const {o : Ordinal} (ho : o ≠ 0) (a : Ordinal) : (bsup o fun _ _ => a) = a :=
  le_antisymm (bsup_le fun _ _ => le_rfl) (le_bsup _ 0 (Ordinal.pos_iff_ne_zero.2 ho))
#align ordinal.bsup_const Ordinal.bsup_const
-/

#print Ordinal.bsup_one /-
@[simp]
theorem bsup_one (f : ∀ a < (1 : Ordinal), Ordinal) : bsup 1 f = f 0 zero_lt_one := by
  simp_rw [← sup_eq_bsup, sup_unique, family_of_bfamily, family_of_bfamily', typein_one_out]
#align ordinal.bsup_one Ordinal.bsup_one
-/

#print Ordinal.bsup_le_of_brange_subset /-
theorem bsup_le_of_brange_subset {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f ⊆ brange o' g) : bsup.{u, max v w} o f ≤ bsup.{v, max u w} o' g :=
  bsup_le fun i hi => by
    obtain ⟨j, hj, hj'⟩ := h ⟨i, hi, rfl⟩
    rw [← hj']
    apply le_bsup
#align ordinal.bsup_le_of_brange_subset Ordinal.bsup_le_of_brange_subset
-/

#print Ordinal.bsup_eq_of_brange_eq /-
theorem bsup_eq_of_brange_eq {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f = brange o' g) : bsup.{u, max v w} o f = bsup.{v, max u w} o' g :=
  (bsup_le_of_brange_subset h.le).antisymm (bsup_le_of_brange_subset.{v, u, w} h.ge)
#align ordinal.bsup_eq_of_brange_eq Ordinal.bsup_eq_of_brange_eq
-/

#print Ordinal.lsub /-
/-- The least strict upper bound of a family of ordinals. -/
def lsub {ι} (f : ι → Ordinal) : Ordinal :=
  sup (succ ∘ f)
#align ordinal.lsub Ordinal.lsub
-/

#print Ordinal.sup_eq_lsub /-
@[simp]
theorem sup_eq_lsub {ι} (f : ι → Ordinal) : sup (succ ∘ f) = lsub f :=
  rfl
#align ordinal.sup_eq_lsub Ordinal.sup_eq_lsub
-/

#print Ordinal.lsub_le_iff /-
theorem lsub_le_iff {ι} {f : ι → Ordinal} {a} : lsub f ≤ a ↔ ∀ i, f i < a := by convert sup_le_iff;
  simp only [succ_le_iff]
#align ordinal.lsub_le_iff Ordinal.lsub_le_iff
-/

#print Ordinal.lsub_le /-
theorem lsub_le {ι} {f : ι → Ordinal} {a} : (∀ i, f i < a) → lsub f ≤ a :=
  lsub_le_iff.2
#align ordinal.lsub_le Ordinal.lsub_le
-/

#print Ordinal.lt_lsub /-
theorem lt_lsub {ι} (f : ι → Ordinal) (i) : f i < lsub f :=
  succ_le_iff.1 (le_sup _ i)
#align ordinal.lt_lsub Ordinal.lt_lsub
-/

#print Ordinal.lt_lsub_iff /-
theorem lt_lsub_iff {ι} {f : ι → Ordinal} {a} : a < lsub f ↔ ∃ i, a ≤ f i := by
  simpa only [not_forall, not_lt, not_le] using not_congr (@lsub_le_iff _ f a)
#align ordinal.lt_lsub_iff Ordinal.lt_lsub_iff
-/

#print Ordinal.sup_le_lsub /-
theorem sup_le_lsub {ι} (f : ι → Ordinal) : sup f ≤ lsub f :=
  sup_le fun i => (lt_lsub f i).le
#align ordinal.sup_le_lsub Ordinal.sup_le_lsub
-/

#print Ordinal.lsub_le_sup_succ /-
theorem lsub_le_sup_succ {ι} (f : ι → Ordinal) : lsub f ≤ succ (sup f) :=
  lsub_le fun i => lt_succ_iff.2 (le_sup f i)
#align ordinal.lsub_le_sup_succ Ordinal.lsub_le_sup_succ
-/

#print Ordinal.sup_eq_lsub_or_sup_succ_eq_lsub /-
theorem sup_eq_lsub_or_sup_succ_eq_lsub {ι} (f : ι → Ordinal) :
    sup f = lsub f ∨ succ (sup f) = lsub f :=
  by
  cases eq_or_lt_of_le (sup_le_lsub f)
  · exact Or.inl h
  · exact Or.inr ((succ_le_of_lt h).antisymm (lsub_le_sup_succ f))
#align ordinal.sup_eq_lsub_or_sup_succ_eq_lsub Ordinal.sup_eq_lsub_or_sup_succ_eq_lsub
-/

#print Ordinal.sup_succ_le_lsub /-
theorem sup_succ_le_lsub {ι} (f : ι → Ordinal) : succ (sup f) ≤ lsub f ↔ ∃ i, f i = sup f :=
  by
  refine' ⟨fun h => _, _⟩
  · by_contra' hf
    exact (succ_le_iff.1 h).Ne ((sup_le_lsub f).antisymm (lsub_le (ne_sup_iff_lt_sup.1 hf)))
  rintro ⟨_, hf⟩
  rw [succ_le_iff, ← hf]
  exact lt_lsub _ _
#align ordinal.sup_succ_le_lsub Ordinal.sup_succ_le_lsub
-/

#print Ordinal.sup_succ_eq_lsub /-
theorem sup_succ_eq_lsub {ι} (f : ι → Ordinal) : succ (sup f) = lsub f ↔ ∃ i, f i = sup f :=
  (lsub_le_sup_succ f).le_iff_eq.symm.trans (sup_succ_le_lsub f)
#align ordinal.sup_succ_eq_lsub Ordinal.sup_succ_eq_lsub
-/

#print Ordinal.sup_eq_lsub_iff_succ /-
theorem sup_eq_lsub_iff_succ {ι} (f : ι → Ordinal) :
    sup f = lsub f ↔ ∀ a < lsub f, succ a < lsub f :=
  by
  refine' ⟨fun h => _, fun hf => le_antisymm (sup_le_lsub f) (lsub_le fun i => _)⟩
  · rw [← h]
    exact fun a => sup_not_succ_of_ne_sup fun i => (lsub_le_iff.1 (le_of_eq h.symm) i).Ne
  by_contra' hle
  have heq := (sup_succ_eq_lsub f).2 ⟨i, le_antisymm (le_sup _ _) hle⟩
  have := hf _ (by rw [← HEq]; exact lt_succ (sup f))
  rw [HEq] at this 
  exact this.false
#align ordinal.sup_eq_lsub_iff_succ Ordinal.sup_eq_lsub_iff_succ
-/

#print Ordinal.sup_eq_lsub_iff_lt_sup /-
theorem sup_eq_lsub_iff_lt_sup {ι} (f : ι → Ordinal) : sup f = lsub f ↔ ∀ i, f i < sup f :=
  ⟨fun h i => by rw [h]; apply lt_lsub, fun h => le_antisymm (sup_le_lsub f) (lsub_le h)⟩
#align ordinal.sup_eq_lsub_iff_lt_sup Ordinal.sup_eq_lsub_iff_lt_sup
-/

#print Ordinal.lsub_empty /-
@[simp]
theorem lsub_empty {ι} [h : IsEmpty ι] (f : ι → Ordinal) : lsub f = 0 := by
  rw [← Ordinal.le_zero, lsub_le_iff]; exact h.elim
#align ordinal.lsub_empty Ordinal.lsub_empty
-/

#print Ordinal.lsub_pos /-
theorem lsub_pos {ι} [h : Nonempty ι] (f : ι → Ordinal) : 0 < lsub f :=
  h.elim fun i => (Ordinal.zero_le _).trans_lt (lt_lsub f i)
#align ordinal.lsub_pos Ordinal.lsub_pos
-/

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

#print Ordinal.lsub_const /-
@[simp]
theorem lsub_const {ι} [hι : Nonempty ι] (o : Ordinal) : (lsub fun _ : ι => o) = succ o :=
  sup_const (succ o)
#align ordinal.lsub_const Ordinal.lsub_const
-/

#print Ordinal.lsub_unique /-
@[simp]
theorem lsub_unique {ι} [hι : Unique ι] (f : ι → Ordinal) : lsub f = succ (f default) :=
  sup_unique _
#align ordinal.lsub_unique Ordinal.lsub_unique
-/

#print Ordinal.lsub_le_of_range_subset /-
theorem lsub_le_of_range_subset {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f ⊆ Set.range g) : lsub.{u, max v w} f ≤ lsub.{v, max u w} g :=
  sup_le_of_range_subset (by convert Set.image_subset _ h <;> apply Set.range_comp)
#align ordinal.lsub_le_of_range_subset Ordinal.lsub_le_of_range_subset
-/

#print Ordinal.lsub_eq_of_range_eq /-
theorem lsub_eq_of_range_eq {ι ι'} {f : ι → Ordinal} {g : ι' → Ordinal}
    (h : Set.range f = Set.range g) : lsub.{u, max v w} f = lsub.{v, max u w} g :=
  (lsub_le_of_range_subset h.le).antisymm (lsub_le_of_range_subset.{v, u, w} h.ge)
#align ordinal.lsub_eq_of_range_eq Ordinal.lsub_eq_of_range_eq
-/

#print Ordinal.lsub_sum /-
@[simp]
theorem lsub_sum {α : Type u} {β : Type v} (f : Sum α β → Ordinal) :
    lsub.{max u v, w} f =
      max (lsub.{u, max v w} fun a => f (Sum.inl a)) (lsub.{v, max u w} fun b => f (Sum.inr b)) :=
  sup_sum _
#align ordinal.lsub_sum Ordinal.lsub_sum
-/

#print Ordinal.lsub_not_mem_range /-
theorem lsub_not_mem_range {ι} (f : ι → Ordinal) : lsub f ∉ Set.range f := fun ⟨i, h⟩ =>
  h.not_lt (lt_lsub f i)
#align ordinal.lsub_not_mem_range Ordinal.lsub_not_mem_range
-/

#print Ordinal.nonempty_compl_range /-
theorem nonempty_compl_range {ι : Type u} (f : ι → Ordinal.{max u v}) : Set.range fᶜ.Nonempty :=
  ⟨_, lsub_not_mem_range f⟩
#align ordinal.nonempty_compl_range Ordinal.nonempty_compl_range
-/

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

#print Ordinal.sup_typein_limit /-
theorem sup_typein_limit {o : Ordinal} (ho : ∀ a, a < o → succ a < o) :
    sup.{u, u} (typein ((· < ·) : o.out.α → o.out.α → Prop)) = o := by
  rw [(sup_eq_lsub_iff_succ.{u, u} (typein (· < ·))).2] <;> rwa [lsub_typein o]
#align ordinal.sup_typein_limit Ordinal.sup_typein_limit
-/

#print Ordinal.sup_typein_succ /-
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
-/

#print Ordinal.blsub /-
/-- The least strict upper bound of a family of ordinals indexed by the set of ordinals less than
    some `o : ordinal.{u}`.

    This is to `lsub` as `bsup` is to `sup`. -/
def blsub (o : Ordinal.{u}) (f : ∀ a < o, Ordinal.{max u v}) : Ordinal.{max u v} :=
  o.bsup fun a ha => succ (f a ha)
#align ordinal.blsub Ordinal.blsub
-/

#print Ordinal.bsup_eq_blsub /-
@[simp]
theorem bsup_eq_blsub (o : Ordinal) (f : ∀ a < o, Ordinal) :
    (bsup o fun a ha => succ (f a ha)) = blsub o f :=
  rfl
#align ordinal.bsup_eq_blsub Ordinal.bsup_eq_blsub
-/

#print Ordinal.lsub_eq_blsub' /-
theorem lsub_eq_blsub' {ι} (r : ι → ι → Prop) [IsWellOrder ι r] {o} (ho : type r = o) (f) :
    lsub (familyOfBFamily' r ho f) = blsub o f :=
  sup_eq_bsup' r ho fun a ha => succ (f a ha)
#align ordinal.lsub_eq_blsub' Ordinal.lsub_eq_blsub'
-/

#print Ordinal.lsub_eq_lsub /-
theorem lsub_eq_lsub {ι ι' : Type u} (r : ι → ι → Prop) (r' : ι' → ι' → Prop) [IsWellOrder ι r]
    [IsWellOrder ι' r'] {o} (ho : type r = o) (ho' : type r' = o) (f : ∀ a < o, Ordinal) :
    lsub (familyOfBFamily' r ho f) = lsub (familyOfBFamily' r' ho' f) := by
  rw [lsub_eq_blsub', lsub_eq_blsub']
#align ordinal.lsub_eq_lsub Ordinal.lsub_eq_lsub
-/

#print Ordinal.lsub_eq_blsub /-
@[simp]
theorem lsub_eq_blsub {o} (f : ∀ a < o, Ordinal) : lsub (familyOfBFamily o f) = blsub o f :=
  lsub_eq_blsub' _ _ _
#align ordinal.lsub_eq_blsub Ordinal.lsub_eq_blsub
-/

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

#print Ordinal.blsub_congr /-
@[congr]
theorem blsub_congr {o₁ o₂ : Ordinal} (f : ∀ a < o₁, Ordinal) (ho : o₁ = o₂) :
    blsub o₁ f = blsub o₂ fun a h => f a (h.trans_eq ho.symm) := by subst ho
#align ordinal.blsub_congr Ordinal.blsub_congr
-/

#print Ordinal.blsub_le_iff /-
theorem blsub_le_iff {o f a} : blsub o f ≤ a ↔ ∀ i h, f i h < a := by convert bsup_le_iff;
  simp [succ_le_iff]
#align ordinal.blsub_le_iff Ordinal.blsub_le_iff
-/

#print Ordinal.blsub_le /-
theorem blsub_le {o : Ordinal} {f : ∀ b < o, Ordinal} {a} : (∀ i h, f i h < a) → blsub o f ≤ a :=
  blsub_le_iff.2
#align ordinal.blsub_le Ordinal.blsub_le
-/

#print Ordinal.lt_blsub /-
theorem lt_blsub {o} (f : ∀ a < o, Ordinal) (i h) : f i h < blsub o f :=
  blsub_le_iff.1 le_rfl _ _
#align ordinal.lt_blsub Ordinal.lt_blsub
-/

#print Ordinal.lt_blsub_iff /-
theorem lt_blsub_iff {o f a} : a < blsub o f ↔ ∃ i hi, a ≤ f i hi := by
  simpa only [not_forall, not_lt, not_le] using not_congr (@blsub_le_iff _ f a)
#align ordinal.lt_blsub_iff Ordinal.lt_blsub_iff
-/

#print Ordinal.bsup_le_blsub /-
theorem bsup_le_blsub {o} (f : ∀ a < o, Ordinal) : bsup o f ≤ blsub o f :=
  bsup_le fun i h => (lt_blsub f i h).le
#align ordinal.bsup_le_blsub Ordinal.bsup_le_blsub
-/

#print Ordinal.blsub_le_bsup_succ /-
theorem blsub_le_bsup_succ {o} (f : ∀ a < o, Ordinal) : blsub o f ≤ succ (bsup o f) :=
  blsub_le fun i h => lt_succ_iff.2 (le_bsup f i h)
#align ordinal.blsub_le_bsup_succ Ordinal.blsub_le_bsup_succ
-/

#print Ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub /-
theorem bsup_eq_blsub_or_succ_bsup_eq_blsub {o} (f : ∀ a < o, Ordinal) :
    bsup o f = blsub o f ∨ succ (bsup o f) = blsub o f := by rw [← sup_eq_bsup, ← lsub_eq_blsub];
  exact sup_eq_lsub_or_sup_succ_eq_lsub _
#align ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub Ordinal.bsup_eq_blsub_or_succ_bsup_eq_blsub
-/

#print Ordinal.bsup_succ_le_blsub /-
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
-/

#print Ordinal.bsup_succ_eq_blsub /-
theorem bsup_succ_eq_blsub {o} (f : ∀ a < o, Ordinal) :
    succ (bsup o f) = blsub o f ↔ ∃ i hi, f i hi = bsup o f :=
  (blsub_le_bsup_succ f).le_iff_eq.symm.trans (bsup_succ_le_blsub f)
#align ordinal.bsup_succ_eq_blsub Ordinal.bsup_succ_eq_blsub
-/

#print Ordinal.bsup_eq_blsub_iff_succ /-
theorem bsup_eq_blsub_iff_succ {o} (f : ∀ a < o, Ordinal) :
    bsup o f = blsub o f ↔ ∀ a < blsub o f, succ a < blsub o f := by
  rw [← sup_eq_bsup, ← lsub_eq_blsub]; apply sup_eq_lsub_iff_succ
#align ordinal.bsup_eq_blsub_iff_succ Ordinal.bsup_eq_blsub_iff_succ
-/

#print Ordinal.bsup_eq_blsub_iff_lt_bsup /-
theorem bsup_eq_blsub_iff_lt_bsup {o} (f : ∀ a < o, Ordinal) :
    bsup o f = blsub o f ↔ ∀ i hi, f i hi < bsup o f :=
  ⟨fun h i => by rw [h]; apply lt_blsub, fun h => le_antisymm (bsup_le_blsub f) (blsub_le h)⟩
#align ordinal.bsup_eq_blsub_iff_lt_bsup Ordinal.bsup_eq_blsub_iff_lt_bsup
-/

#print Ordinal.bsup_eq_blsub_of_lt_succ_limit /-
theorem bsup_eq_blsub_of_lt_succ_limit {o} (ho : IsLimit o) {f : ∀ a < o, Ordinal}
    (hf : ∀ a ha, f a ha < f (succ a) (ho.2 a ha)) : bsup o f = blsub o f :=
  by
  rw [bsup_eq_blsub_iff_lt_bsup]
  exact fun i hi => (hf i hi).trans_le (le_bsup f _ _)
#align ordinal.bsup_eq_blsub_of_lt_succ_limit Ordinal.bsup_eq_blsub_of_lt_succ_limit
-/

#print Ordinal.blsub_succ_of_mono /-
theorem blsub_succ_of_mono {o : Ordinal} {f : ∀ a < succ o, Ordinal}
    (hf : ∀ {i j} (hi hj), i ≤ j → f i hi ≤ f j hj) : blsub _ f = succ (f o (lt_succ o)) :=
  bsup_succ_of_mono fun i j hi hj h => succ_le_succ (hf hi hj h)
#align ordinal.blsub_succ_of_mono Ordinal.blsub_succ_of_mono
-/

#print Ordinal.blsub_eq_zero_iff /-
@[simp]
theorem blsub_eq_zero_iff {o} {f : ∀ a < o, Ordinal} : blsub o f = 0 ↔ o = 0 := by
  rw [← lsub_eq_blsub, lsub_eq_zero_iff]; exact out_empty_iff_eq_zero
#align ordinal.blsub_eq_zero_iff Ordinal.blsub_eq_zero_iff
-/

#print Ordinal.blsub_zero /-
@[simp]
theorem blsub_zero (f : ∀ a < (0 : Ordinal), Ordinal) : blsub 0 f = 0 := by rwa [blsub_eq_zero_iff]
#align ordinal.blsub_zero Ordinal.blsub_zero
-/

#print Ordinal.blsub_pos /-
theorem blsub_pos {o : Ordinal} (ho : 0 < o) (f : ∀ a < o, Ordinal) : 0 < blsub o f :=
  (Ordinal.zero_le _).trans_lt (lt_blsub f 0 ho)
#align ordinal.blsub_pos Ordinal.blsub_pos
-/

#print Ordinal.blsub_type /-
theorem blsub_type (r : α → α → Prop) [IsWellOrder α r] (f) :
    blsub (type r) f = lsub fun a => f (typein r a) (typein_lt_type _ _) :=
  eq_of_forall_ge_iff fun o => by
    rw [blsub_le_iff, lsub_le_iff] <;>
      exact ⟨fun H b => H _ _, fun H i h => by simpa only [typein_enum] using H (enum r i h)⟩
#align ordinal.blsub_type Ordinal.blsub_type
-/

#print Ordinal.blsub_const /-
theorem blsub_const {o : Ordinal} (ho : o ≠ 0) (a : Ordinal) :
    (blsub.{u, v} o fun _ _ => a) = succ a :=
  bsup_const.{u, v} ho (succ a)
#align ordinal.blsub_const Ordinal.blsub_const
-/

#print Ordinal.blsub_one /-
@[simp]
theorem blsub_one (f : ∀ a < (1 : Ordinal), Ordinal) : blsub 1 f = succ (f 0 zero_lt_one) :=
  bsup_one _
#align ordinal.blsub_one Ordinal.blsub_one
-/

#print Ordinal.blsub_id /-
@[simp]
theorem blsub_id : ∀ o, (blsub.{u, u} o fun x _ => x) = o :=
  lsub_typein
#align ordinal.blsub_id Ordinal.blsub_id
-/

#print Ordinal.bsup_id_limit /-
theorem bsup_id_limit {o : Ordinal} : (∀ a < o, succ a < o) → (bsup.{u, u} o fun x _ => x) = o :=
  sup_typein_limit
#align ordinal.bsup_id_limit Ordinal.bsup_id_limit
-/

#print Ordinal.bsup_id_succ /-
@[simp]
theorem bsup_id_succ (o) : (bsup.{u, u} (succ o) fun x _ => x) = o :=
  sup_typein_succ
#align ordinal.bsup_id_succ Ordinal.bsup_id_succ
-/

#print Ordinal.blsub_le_of_brange_subset /-
theorem blsub_le_of_brange_subset {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f ⊆ brange o' g) : blsub.{u, max v w} o f ≤ blsub.{v, max u w} o' g :=
  bsup_le_of_brange_subset fun a ⟨b, hb, hb'⟩ =>
    by
    obtain ⟨c, hc, hc'⟩ := h ⟨b, hb, rfl⟩
    simp_rw [← hc'] at hb' 
    exact ⟨c, hc, hb'⟩
#align ordinal.blsub_le_of_brange_subset Ordinal.blsub_le_of_brange_subset
-/

#print Ordinal.blsub_eq_of_brange_eq /-
theorem blsub_eq_of_brange_eq {o o'} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : {o | ∃ i hi, f i hi = o} = {o | ∃ i hi, g i hi = o}) :
    blsub.{u, max v w} o f = blsub.{v, max u w} o' g :=
  (blsub_le_of_brange_subset h.le).antisymm (blsub_le_of_brange_subset.{v, u, w} h.ge)
#align ordinal.blsub_eq_of_brange_eq Ordinal.blsub_eq_of_brange_eq
-/

#print Ordinal.bsup_comp /-
theorem bsup_comp {o o' : Ordinal} {f : ∀ a < o, Ordinal}
    (hf : ∀ {i j} (hi) (hj), i ≤ j → f i hi ≤ f j hj) {g : ∀ a < o', Ordinal}
    (hg : blsub o' g = o) :
    (bsup o' fun a ha => f (g a ha) (by rw [← hg]; apply lt_blsub)) = bsup o f :=
  by
  apply le_antisymm <;> refine' bsup_le fun i hi => _
  · apply le_bsup
  · rw [← hg, lt_blsub_iff] at hi 
    rcases hi with ⟨j, hj, hj'⟩
    exact (hf _ _ hj').trans (le_bsup _ _ _)
#align ordinal.bsup_comp Ordinal.bsup_comp
-/

#print Ordinal.blsub_comp /-
theorem blsub_comp {o o' : Ordinal} {f : ∀ a < o, Ordinal}
    (hf : ∀ {i j} (hi) (hj), i ≤ j → f i hi ≤ f j hj) {g : ∀ a < o', Ordinal}
    (hg : blsub o' g = o) :
    (blsub o' fun a ha => f (g a ha) (by rw [← hg]; apply lt_blsub)) = blsub o f :=
  @bsup_comp o _ (fun a ha => succ (f a ha)) (fun i j _ _ h => succ_le_succ_iff.2 (hf _ _ h)) g hg
#align ordinal.blsub_comp Ordinal.blsub_comp
-/

#print Ordinal.IsNormal.bsup_eq /-
theorem IsNormal.bsup_eq {f} (H : IsNormal f) {o : Ordinal} (h : IsLimit o) :
    (bsup.{u} o fun x _ => f x) = f o := by
  rw [← IsNormal.bsup.{u, u} H (fun x _ => x) h.1, bsup_id_limit h.2]
#align ordinal.is_normal.bsup_eq Ordinal.IsNormal.bsup_eq
-/

#print Ordinal.IsNormal.blsub_eq /-
theorem IsNormal.blsub_eq {f} (H : IsNormal f) {o : Ordinal} (h : IsLimit o) :
    (blsub.{u} o fun x _ => f x) = f o := by rw [← H.bsup_eq h, bsup_eq_blsub_of_lt_succ_limit h];
  exact fun a _ => H.1 a
#align ordinal.is_normal.blsub_eq Ordinal.IsNormal.blsub_eq
-/

#print Ordinal.isNormal_iff_lt_succ_and_bsup_eq /-
theorem isNormal_iff_lt_succ_and_bsup_eq {f} :
    IsNormal f ↔ (∀ a, f a < f (succ a)) ∧ ∀ o, IsLimit o → (bsup o fun x _ => f x) = f o :=
  ⟨fun h => ⟨h.1, @IsNormal.bsup_eq f h⟩, fun ⟨h₁, h₂⟩ =>
    ⟨h₁, fun o ho a => by rw [← h₂ o ho]; exact bsup_le_iff⟩⟩
#align ordinal.is_normal_iff_lt_succ_and_bsup_eq Ordinal.isNormal_iff_lt_succ_and_bsup_eq
-/

#print Ordinal.isNormal_iff_lt_succ_and_blsub_eq /-
theorem isNormal_iff_lt_succ_and_blsub_eq {f} :
    IsNormal f ↔ (∀ a, f a < f (succ a)) ∧ ∀ o, IsLimit o → (blsub o fun x _ => f x) = f o :=
  by
  rw [is_normal_iff_lt_succ_and_bsup_eq, and_congr_right_iff]
  intro h
  constructor <;> intro H o ho <;> have := H o ho <;>
    rwa [← bsup_eq_blsub_of_lt_succ_limit ho fun a _ => h a] at *
#align ordinal.is_normal_iff_lt_succ_and_blsub_eq Ordinal.isNormal_iff_lt_succ_and_blsub_eq
-/

#print Ordinal.IsNormal.eq_iff_zero_and_succ /-
theorem IsNormal.eq_iff_zero_and_succ {f g : Ordinal.{u} → Ordinal.{u}} (hf : IsNormal f)
    (hg : IsNormal g) : f = g ↔ f 0 = g 0 ∧ ∀ a, f a = g a → f (succ a) = g (succ a) :=
  ⟨fun h => by simp [h], fun ⟨h₁, h₂⟩ =>
    funext fun a => by
      apply a.limit_rec_on
      assumption'
      intro o ho H
      rw [← IsNormal.bsup_eq.{u, u} hf ho, ← IsNormal.bsup_eq.{u, u} hg ho]
      congr
      ext b hb
      exact H b hb⟩
#align ordinal.is_normal.eq_iff_zero_and_succ Ordinal.IsNormal.eq_iff_zero_and_succ
-/

/-! ### Minimum excluded ordinals -/


#print Ordinal.mex /-
/-- The minimum excluded ordinal in a family of ordinals. -/
def mex {ι : Type u} (f : ι → Ordinal.{max u v}) : Ordinal :=
  sInf (Set.range fᶜ)
#align ordinal.mex Ordinal.mex
-/

#print Ordinal.mex_not_mem_range /-
theorem mex_not_mem_range {ι : Type u} (f : ι → Ordinal.{max u v}) : mex f ∉ Set.range f :=
  csInf_mem (nonempty_compl_range f)
#align ordinal.mex_not_mem_range Ordinal.mex_not_mem_range
-/

#print Ordinal.le_mex_of_forall /-
theorem le_mex_of_forall {ι : Type u} {f : ι → Ordinal.{max u v}} {a : Ordinal}
    (H : ∀ b < a, ∃ i, f i = b) : a ≤ mex f := by by_contra' h; exact mex_not_mem_range f (H _ h)
#align ordinal.le_mex_of_forall Ordinal.le_mex_of_forall
-/

#print Ordinal.ne_mex /-
theorem ne_mex {ι} (f : ι → Ordinal) : ∀ i, f i ≠ mex f := by simpa using mex_not_mem_range f
#align ordinal.ne_mex Ordinal.ne_mex
-/

#print Ordinal.mex_le_of_ne /-
theorem mex_le_of_ne {ι} {f : ι → Ordinal} {a} (ha : ∀ i, f i ≠ a) : mex f ≤ a :=
  csInf_le' (by simp [ha])
#align ordinal.mex_le_of_ne Ordinal.mex_le_of_ne
-/

#print Ordinal.exists_of_lt_mex /-
theorem exists_of_lt_mex {ι} {f : ι → Ordinal} {a} (ha : a < mex f) : ∃ i, f i = a := by
  by_contra' ha'; exact ha.not_le (mex_le_of_ne ha')
#align ordinal.exists_of_lt_mex Ordinal.exists_of_lt_mex
-/

#print Ordinal.mex_le_lsub /-
theorem mex_le_lsub {ι} (f : ι → Ordinal) : mex f ≤ lsub f :=
  csInf_le' (lsub_not_mem_range f)
#align ordinal.mex_le_lsub Ordinal.mex_le_lsub
-/

#print Ordinal.mex_monotone /-
theorem mex_monotone {α β} {f : α → Ordinal} {g : β → Ordinal} (h : Set.range f ⊆ Set.range g) :
    mex f ≤ mex g := by
  refine' mex_le_of_ne fun i hi => _
  cases' h ⟨i, rfl⟩ with j hj
  rw [← hj] at hi 
  exact ne_mex g j hi
#align ordinal.mex_monotone Ordinal.mex_monotone
-/

#print Ordinal.mex_lt_ord_succ_mk /-
theorem mex_lt_ord_succ_mk {ι} (f : ι → Ordinal) : mex f < (succ (#ι)).ord :=
  by
  by_contra' h
  apply (lt_succ (#ι)).not_le
  have H := fun a => exists_of_lt_mex ((typein_lt_self a).trans_le h)
  let g : (succ (#ι)).ord.out.α → ι := fun a => Classical.choose (H a)
  have hg : injective g := fun a b h' =>
    by
    have Hf : ∀ x, f (g x) = typein (· < ·) x := fun a => Classical.choose_spec (H a)
    apply_fun f at h' 
    rwa [Hf, Hf, typein_inj] at h' 
  convert Cardinal.mk_le_of_injective hg
  rw [Cardinal.mk_ord_out]
#align ordinal.mex_lt_ord_succ_mk Ordinal.mex_lt_ord_succ_mk
-/

#print Ordinal.bmex /-
/-- The minimum excluded ordinal of a family of ordinals indexed by the set of ordinals less than
    some `o : ordinal.{u}`. This is a special case of `mex` over the family provided by
    `family_of_bfamily`.

    This is to `mex` as `bsup` is to `sup`. -/
def bmex (o : Ordinal) (f : ∀ a < o, Ordinal) : Ordinal :=
  mex (familyOfBFamily o f)
#align ordinal.bmex Ordinal.bmex
-/

#print Ordinal.bmex_not_mem_brange /-
theorem bmex_not_mem_brange {o : Ordinal} (f : ∀ a < o, Ordinal) : bmex o f ∉ brange o f := by
  rw [← range_family_of_bfamily]; apply mex_not_mem_range
#align ordinal.bmex_not_mem_brange Ordinal.bmex_not_mem_brange
-/

#print Ordinal.le_bmex_of_forall /-
theorem le_bmex_of_forall {o : Ordinal} (f : ∀ a < o, Ordinal) {a : Ordinal}
    (H : ∀ b < a, ∃ i hi, f i hi = b) : a ≤ bmex o f := by by_contra' h;
  exact bmex_not_mem_brange f (H _ h)
#align ordinal.le_bmex_of_forall Ordinal.le_bmex_of_forall
-/

#print Ordinal.ne_bmex /-
theorem ne_bmex {o : Ordinal} (f : ∀ a < o, Ordinal) {i} (hi) : f i hi ≠ bmex o f :=
  by
  convert ne_mex _ (enum (· < ·) i (by rwa [type_lt]))
  rw [family_of_bfamily_enum]
#align ordinal.ne_bmex Ordinal.ne_bmex
-/

#print Ordinal.bmex_le_of_ne /-
theorem bmex_le_of_ne {o : Ordinal} {f : ∀ a < o, Ordinal} {a} (ha : ∀ i hi, f i hi ≠ a) :
    bmex o f ≤ a :=
  mex_le_of_ne fun i => ha _ _
#align ordinal.bmex_le_of_ne Ordinal.bmex_le_of_ne
-/

#print Ordinal.exists_of_lt_bmex /-
theorem exists_of_lt_bmex {o : Ordinal} {f : ∀ a < o, Ordinal} {a} (ha : a < bmex o f) :
    ∃ i hi, f i hi = a := by
  cases' exists_of_lt_mex ha with i hi
  exact ⟨_, typein_lt_self i, hi⟩
#align ordinal.exists_of_lt_bmex Ordinal.exists_of_lt_bmex
-/

#print Ordinal.bmex_le_blsub /-
theorem bmex_le_blsub {o : Ordinal} (f : ∀ a < o, Ordinal) : bmex o f ≤ blsub o f :=
  mex_le_lsub _
#align ordinal.bmex_le_blsub Ordinal.bmex_le_blsub
-/

#print Ordinal.bmex_monotone /-
theorem bmex_monotone {o o' : Ordinal} {f : ∀ a < o, Ordinal} {g : ∀ a < o', Ordinal}
    (h : brange o f ⊆ brange o' g) : bmex o f ≤ bmex o' g :=
  mex_monotone (by rwa [range_family_of_bfamily, range_family_of_bfamily])
#align ordinal.bmex_monotone Ordinal.bmex_monotone
-/

#print Ordinal.bmex_lt_ord_succ_card /-
theorem bmex_lt_ord_succ_card {o : Ordinal} (f : ∀ a < o, Ordinal) : bmex o f < (succ o.card).ord :=
  by rw [← mk_ordinal_out]; exact mex_lt_ord_succ_mk (family_of_bfamily o f)
#align ordinal.bmex_lt_ord_succ_card Ordinal.bmex_lt_ord_succ_card
-/

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
  lt_wf.fix fun o f => sInf (S ∩ Set.Ici (blsub.{u, u} o f))
#align ordinal.enum_ord Ordinal.enumOrd
-/

variable {S : Set Ordinal.{u}}

#print Ordinal.enumOrd_def' /-
/-- The equation that characterizes `enum_ord` definitionally. This isn't the nicest expression to
    work with, so consider using `enum_ord_def` instead. -/
theorem enumOrd_def' (o) :
    enumOrd S o = sInf (S ∩ Set.Ici (blsub.{u, u} o fun a _ => enumOrd S a)) :=
  lt_wf.fix_eq _ _
#align ordinal.enum_ord_def' Ordinal.enumOrd_def'
-/

#print Ordinal.enumOrd_def'_nonempty /-
/-- The set in `enum_ord_def'` is nonempty. -/
theorem enumOrd_def'_nonempty (hS : Unbounded (· < ·) S) (a) : (S ∩ Set.Ici a).Nonempty :=
  let ⟨b, hb, hb'⟩ := hS a
  ⟨b, hb, le_of_not_gt hb'⟩
#align ordinal.enum_ord_def'_nonempty Ordinal.enumOrd_def'_nonempty
-/

private theorem enum_ord_mem_aux (hS : Unbounded (· < ·) S) (o) :
    enumOrd S o ∈ S ∩ Set.Ici (blsub.{u, u} o fun c _ => enumOrd S c) := by rw [enum_ord_def'];
  exact csInf_mem (enum_ord_def'_nonempty hS _)

#print Ordinal.enumOrd_mem /-
theorem enumOrd_mem (hS : Unbounded (· < ·) S) (o) : enumOrd S o ∈ S :=
  (enumOrd_mem_aux hS o).left
#align ordinal.enum_ord_mem Ordinal.enumOrd_mem
-/

#print Ordinal.blsub_le_enumOrd /-
theorem blsub_le_enumOrd (hS : Unbounded (· < ·) S) (o) :
    (blsub.{u, u} o fun c _ => enumOrd S c) ≤ enumOrd S o :=
  (enumOrd_mem_aux hS o).right
#align ordinal.blsub_le_enum_ord Ordinal.blsub_le_enumOrd
-/

#print Ordinal.enumOrd_strictMono /-
theorem enumOrd_strictMono (hS : Unbounded (· < ·) S) : StrictMono (enumOrd S) := fun _ _ h =>
  (lt_blsub.{u, u} _ _ h).trans_le (blsub_le_enumOrd hS _)
#align ordinal.enum_ord_strict_mono Ordinal.enumOrd_strictMono
-/

#print Ordinal.enumOrd_def /-
/-- A more workable definition for `enum_ord`. -/
theorem enumOrd_def (o) : enumOrd S o = sInf (S ∩ {b | ∀ c, c < o → enumOrd S c < b}) :=
  by
  rw [enum_ord_def']
  congr; ext
  exact ⟨fun h a hao => (lt_blsub.{u, u} _ _ hao).trans_le h, blsub_le⟩
#align ordinal.enum_ord_def Ordinal.enumOrd_def
-/

#print Ordinal.enumOrd_def_nonempty /-
/-- The set in `enum_ord_def` is nonempty. -/
theorem enumOrd_def_nonempty (hS : Unbounded (· < ·) S) {o} :
    {x | x ∈ S ∧ ∀ c, c < o → enumOrd S c < x}.Nonempty :=
  ⟨_, enumOrd_mem hS o, fun _ b => enumOrd_strictMono hS b⟩
#align ordinal.enum_ord_def_nonempty Ordinal.enumOrd_def_nonempty
-/

#print Ordinal.enumOrd_range /-
@[simp]
theorem enumOrd_range {f : Ordinal → Ordinal} (hf : StrictMono f) : enumOrd (range f) = f :=
  funext fun o => by
    apply Ordinal.induction o
    intro a H
    rw [enum_ord_def a]
    have Hfa : f a ∈ range f ∩ {b | ∀ c, c < a → enum_ord (range f) c < b} :=
      ⟨mem_range_self a, fun b hb => by rw [H b hb]; exact hf hb⟩
    refine' (csInf_le' Hfa).antisymm ((le_csInf_iff'' ⟨_, Hfa⟩).2 _)
    rintro _ ⟨⟨c, rfl⟩, hc : ∀ b < a, enum_ord (range f) b < f c⟩
    rw [hf.le_iff_le]
    contrapose! hc
    exact ⟨c, hc, (H c hc).ge⟩
#align ordinal.enum_ord_range Ordinal.enumOrd_range
-/

#print Ordinal.enumOrd_univ /-
@[simp]
theorem enumOrd_univ : enumOrd Set.univ = id := by rw [← range_id];
  exact enum_ord_range strictMono_id
#align ordinal.enum_ord_univ Ordinal.enumOrd_univ
-/

#print Ordinal.enumOrd_zero /-
@[simp]
theorem enumOrd_zero : enumOrd S 0 = sInf S := by rw [enum_ord_def]; simp [Ordinal.not_lt_zero]
#align ordinal.enum_ord_zero Ordinal.enumOrd_zero
-/

#print Ordinal.enumOrd_succ_le /-
theorem enumOrd_succ_le {a b} (hS : Unbounded (· < ·) S) (ha : a ∈ S) (hb : enumOrd S b < a) :
    enumOrd S (succ b) ≤ a := by
  rw [enum_ord_def]
  exact
    csInf_le' ⟨ha, fun c hc => ((enum_ord_strict_mono hS).Monotone (le_of_lt_succ hc)).trans_lt hb⟩
#align ordinal.enum_ord_succ_le Ordinal.enumOrd_succ_le
-/

#print Ordinal.enumOrd_le_of_subset /-
theorem enumOrd_le_of_subset {S T : Set Ordinal} (hS : Unbounded (· < ·) S) (hST : S ⊆ T) (a) :
    enumOrd T a ≤ enumOrd S a := by
  apply Ordinal.induction a
  intro b H
  rw [enum_ord_def]
  exact csInf_le' ⟨hST (enum_ord_mem hS b), fun c h => (H c h).trans_lt (enum_ord_strict_mono hS h)⟩
#align ordinal.enum_ord_le_of_subset Ordinal.enumOrd_le_of_subset
-/

#print Ordinal.enumOrd_surjective /-
theorem enumOrd_surjective (hS : Unbounded (· < ·) S) : ∀ s ∈ S, ∃ a, enumOrd S a = s := fun s hs =>
  ⟨sSup {a | enumOrd S a ≤ s}, by
    apply le_antisymm
    · rw [enum_ord_def]
      refine' csInf_le' ⟨hs, fun a ha => _⟩
      have : enum_ord S 0 ≤ s := by rw [enum_ord_zero]; exact csInf_le' hs
      rcases exists_lt_of_lt_csSup ⟨0, this⟩ ha with ⟨b, hb, hab⟩
      exact (enum_ord_strict_mono hS hab).trans_le hb
    · by_contra' h
      exact
        (le_csSup ⟨s, fun a => (lt_wf.self_le_of_strict_mono (enum_ord_strict_mono hS) a).trans⟩
              (enum_ord_succ_le hS hs h)).not_lt
          (lt_succ _)⟩
#align ordinal.enum_ord_surjective Ordinal.enumOrd_surjective
-/

#print Ordinal.enumOrdOrderIso /-
/-- An order isomorphism between an unbounded set of ordinals and the ordinals. -/
def enumOrdOrderIso (hS : Unbounded (· < ·) S) : Ordinal ≃o S :=
  StrictMono.orderIsoOfSurjective (fun o => ⟨_, enumOrd_mem hS o⟩) (enumOrd_strictMono hS) fun s =>
    let ⟨a, ha⟩ := enumOrd_surjective hS s s.Prop
    ⟨a, Subtype.eq ha⟩
#align ordinal.enum_ord_order_iso Ordinal.enumOrdOrderIso
-/

#print Ordinal.range_enumOrd /-
theorem range_enumOrd (hS : Unbounded (· < ·) S) : range (enumOrd S) = S := by rw [range_eq_iff];
  exact ⟨enum_ord_mem hS, enum_ord_surjective hS⟩
#align ordinal.range_enum_ord Ordinal.range_enumOrd
-/

#print Ordinal.eq_enumOrd /-
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
-/

end

/-! ### Casting naturals into ordinals, compatibility with operations -/


#print Ordinal.one_add_nat_cast /-
@[simp]
theorem one_add_nat_cast (m : ℕ) : 1 + (m : Ordinal) = succ m := by
  rw [← Nat.cast_one, ← Nat.cast_add, add_comm]; rfl
#align ordinal.one_add_nat_cast Ordinal.one_add_nat_cast
-/

#print Ordinal.nat_cast_mul /-
@[simp, norm_cast]
theorem nat_cast_mul (m : ℕ) : ∀ n : ℕ, ((m * n : ℕ) : Ordinal) = m * n
  | 0 => by simp
  | n + 1 => by rw [Nat.mul_succ, Nat.cast_add, nat_cast_mul, Nat.cast_succ, mul_add_one]
#align ordinal.nat_cast_mul Ordinal.nat_cast_mul
-/

#print Ordinal.nat_cast_le /-
@[simp, norm_cast]
theorem nat_cast_le {m n : ℕ} : (m : Ordinal) ≤ n ↔ m ≤ n := by
  rw [← Cardinal.ord_nat, ← Cardinal.ord_nat, Cardinal.ord_le_ord, Cardinal.natCast_le]
#align ordinal.nat_cast_le Ordinal.nat_cast_le
-/

#print Ordinal.nat_cast_lt /-
@[simp, norm_cast]
theorem nat_cast_lt {m n : ℕ} : (m : Ordinal) < n ↔ m < n := by
  simp only [lt_iff_le_not_le, nat_cast_le]
#align ordinal.nat_cast_lt Ordinal.nat_cast_lt
-/

#print Ordinal.nat_cast_inj /-
@[simp, norm_cast]
theorem nat_cast_inj {m n : ℕ} : (m : Ordinal) = n ↔ m = n := by
  simp only [le_antisymm_iff, nat_cast_le]
#align ordinal.nat_cast_inj Ordinal.nat_cast_inj
-/

#print Ordinal.nat_cast_eq_zero /-
@[simp, norm_cast]
theorem nat_cast_eq_zero {n : ℕ} : (n : Ordinal) = 0 ↔ n = 0 :=
  @nat_cast_inj n 0
#align ordinal.nat_cast_eq_zero Ordinal.nat_cast_eq_zero
-/

#print Ordinal.nat_cast_ne_zero /-
theorem nat_cast_ne_zero {n : ℕ} : (n : Ordinal) ≠ 0 ↔ n ≠ 0 :=
  not_congr nat_cast_eq_zero
#align ordinal.nat_cast_ne_zero Ordinal.nat_cast_ne_zero
-/

#print Ordinal.nat_cast_pos /-
@[simp, norm_cast]
theorem nat_cast_pos {n : ℕ} : (0 : Ordinal) < n ↔ 0 < n :=
  @nat_cast_lt 0 n
#align ordinal.nat_cast_pos Ordinal.nat_cast_pos
-/

#print Ordinal.nat_cast_sub /-
@[simp, norm_cast]
theorem nat_cast_sub (m n : ℕ) : ((m - n : ℕ) : Ordinal) = m - n :=
  by
  cases' le_total m n with h h
  · rw [tsub_eq_zero_iff_le.2 h, Ordinal.sub_eq_zero_iff_le.2 (nat_cast_le.2 h)]
    rfl
  · apply (add_left_cancel n).1
    rw [← Nat.cast_add, add_tsub_cancel_of_le h, Ordinal.add_sub_cancel_of_le (nat_cast_le.2 h)]
#align ordinal.nat_cast_sub Ordinal.nat_cast_sub
-/

#print Ordinal.nat_cast_div /-
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
-/

#print Ordinal.nat_cast_mod /-
@[simp, norm_cast]
theorem nat_cast_mod (m n : ℕ) : ((m % n : ℕ) : Ordinal) = m % n := by
  rw [← add_left_cancel, div_add_mod, ← nat_cast_div, ← nat_cast_mul, ← Nat.cast_add,
    Nat.div_add_mod]
#align ordinal.nat_cast_mod Ordinal.nat_cast_mod
-/

#print Ordinal.lift_nat_cast /-
@[simp]
theorem lift_nat_cast : ∀ n : ℕ, lift.{u, v} n = n
  | 0 => by simp
  | n + 1 => by simp [lift_nat_cast n]
#align ordinal.lift_nat_cast Ordinal.lift_nat_cast
-/

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
      rw [lt_ord, ← lift_card, lift_lt_aleph_0, ← typein_enum (· < ·) h']
      exact lt_aleph_0_iff_fintype.2 ⟨Set.fintypeLTNat _⟩
#align cardinal.ord_aleph_0 Cardinal.ord_aleph0
-/

#print Cardinal.add_one_of_aleph0_le /-
@[simp]
theorem add_one_of_aleph0_le {c} (h : ℵ₀ ≤ c) : c + 1 = c :=
  by
  rw [add_comm, ← card_ord c, ← card_one, ← card_add, one_add_of_omega_le]
  rwa [← ord_aleph_0, ord_le_ord]
#align cardinal.add_one_of_aleph_0_le Cardinal.add_one_of_aleph0_le
-/

end Cardinal

namespace Ordinal

#print Ordinal.lt_add_of_limit /-
theorem lt_add_of_limit {a b c : Ordinal.{u}} (h : IsLimit c) : a < b + c ↔ ∃ c' < c, a < b + c' :=
  by rw [← IsNormal.bsup_eq.{u, u} (add_is_normal b) h, lt_bsup]
#align ordinal.lt_add_of_limit Ordinal.lt_add_of_limit
-/

#print Ordinal.lt_omega /-
theorem lt_omega {o : Ordinal} : o < ω ↔ ∃ n : ℕ, o = n := by
  simp_rw [← Cardinal.ord_aleph0, Cardinal.lt_ord, lt_aleph_0, card_eq_nat]
#align ordinal.lt_omega Ordinal.lt_omega
-/

#print Ordinal.nat_lt_omega /-
theorem nat_lt_omega (n : ℕ) : ↑n < ω :=
  lt_omega.2 ⟨_, rfl⟩
#align ordinal.nat_lt_omega Ordinal.nat_lt_omega
-/

#print Ordinal.omega_pos /-
theorem omega_pos : 0 < ω :=
  nat_lt_omega 0
#align ordinal.omega_pos Ordinal.omega_pos
-/

#print Ordinal.omega_ne_zero /-
theorem omega_ne_zero : ω ≠ 0 :=
  omega_pos.ne'
#align ordinal.omega_ne_zero Ordinal.omega_ne_zero
-/

#print Ordinal.one_lt_omega /-
theorem one_lt_omega : 1 < ω := by simpa only [Nat.cast_one] using nat_lt_omega 1
#align ordinal.one_lt_omega Ordinal.one_lt_omega
-/

#print Ordinal.omega_isLimit /-
theorem omega_isLimit : IsLimit ω :=
  ⟨omega_ne_zero, fun o h => by
    let ⟨n, e⟩ := lt_omega.1 h
    rw [e] <;> exact nat_lt_omega (n + 1)⟩
#align ordinal.omega_is_limit Ordinal.omega_isLimit
-/

#print Ordinal.omega_le /-
theorem omega_le {o : Ordinal} : ω ≤ o ↔ ∀ n : ℕ, ↑n ≤ o :=
  ⟨fun h n => (nat_lt_omega _).le.trans h, fun H =>
    le_of_forall_lt fun a h => by
      let ⟨n, e⟩ := lt_omega.1 h
      rw [e, ← succ_le_iff] <;> exact H (n + 1)⟩
#align ordinal.omega_le Ordinal.omega_le
-/

#print Ordinal.sup_nat_cast /-
@[simp]
theorem sup_nat_cast : sup Nat.cast = ω :=
  (sup_le fun n => (nat_lt_omega n).le).antisymm <| omega_le.2 <| le_sup _
#align ordinal.sup_nat_cast Ordinal.sup_nat_cast
-/

#print Ordinal.nat_lt_limit /-
theorem nat_lt_limit {o} (h : IsLimit o) : ∀ n : ℕ, ↑n < o
  | 0 => lt_of_le_of_ne (Ordinal.zero_le o) h.1.symm
  | n + 1 => h.2 _ (nat_lt_limit n)
#align ordinal.nat_lt_limit Ordinal.nat_lt_limit
-/

#print Ordinal.omega_le_of_isLimit /-
theorem omega_le_of_isLimit {o} (h : IsLimit o) : ω ≤ o :=
  omega_le.2 fun n => le_of_lt <| nat_lt_limit h n
#align ordinal.omega_le_of_is_limit Ordinal.omega_le_of_isLimit
-/

#print Ordinal.isLimit_iff_omega_dvd /-
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
    intro e; simp only [e, MulZeroClass.mul_zero]
#align ordinal.is_limit_iff_omega_dvd Ordinal.isLimit_iff_omega_dvd
-/

#print Ordinal.add_mul_limit_aux /-
theorem add_mul_limit_aux {a b c : Ordinal} (ba : b + a = a) (l : IsLimit c)
    (IH : ∀ c' < c, (a + b) * succ c' = a * succ c' + b) : (a + b) * c = a * c :=
  le_antisymm
    ((mul_le_of_limit l).2 fun c' h =>
      by
      apply (mul_le_mul_left' (le_succ c') _).trans
      rw [IH _ h]
      apply (add_le_add_left _ _).trans
      · rw [← mul_succ]; exact mul_le_mul_left' (succ_le_of_lt <| l.2 _ h) _
      · infer_instance
      · rw [← ba]; exact le_add_right _ _)
    (mul_le_mul_right' (le_add_right _ _) _)
#align ordinal.add_mul_limit_aux Ordinal.add_mul_limit_aux
-/

#print Ordinal.add_mul_succ /-
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
-/

#print Ordinal.add_mul_limit /-
theorem add_mul_limit {a b c : Ordinal} (ba : b + a = a) (l : IsLimit c) : (a + b) * c = a * c :=
  add_mul_limit_aux ba l fun c' _ => add_mul_succ c' ba
#align ordinal.add_mul_limit Ordinal.add_mul_limit
-/

#print Ordinal.add_le_of_forall_add_lt /-
theorem add_le_of_forall_add_lt {a b c : Ordinal} (hb : 0 < b) (h : ∀ d < b, a + d < c) :
    a + b ≤ c :=
  by
  have H : a + (c - a) = c := Ordinal.add_sub_cancel_of_le (by rw [← add_zero a]; exact (h _ hb).le)
  rw [← H]
  apply add_le_add_left _ a
  by_contra' hb
  exact (h _ hb).Ne H
#align ordinal.add_le_of_forall_add_lt Ordinal.add_le_of_forall_add_lt
-/

#print Ordinal.IsNormal.apply_omega /-
theorem IsNormal.apply_omega {f : Ordinal.{u} → Ordinal.{u}} (hf : IsNormal f) :
    sup.{0, u} (f ∘ Nat.cast) = f ω := by rw [← sup_nat_cast, IsNormal.sup.{0, u, u} hf]
#align ordinal.is_normal.apply_omega Ordinal.IsNormal.apply_omega
-/

#print Ordinal.sup_add_nat /-
@[simp]
theorem sup_add_nat (o : Ordinal) : (sup fun n : ℕ => o + n) = o + ω :=
  (add_isNormal o).apply_omega
#align ordinal.sup_add_nat Ordinal.sup_add_nat
-/

#print Ordinal.sup_mul_nat /-
@[simp]
theorem sup_mul_nat (o : Ordinal) : (sup fun n : ℕ => o * n) = o * ω :=
  by
  rcases eq_zero_or_pos o with (rfl | ho)
  · rw [MulZeroClass.zero_mul]; exact sup_eq_zero_iff.2 fun n => MulZeroClass.zero_mul n
  · exact (mul_is_normal ho).apply_omega
#align ordinal.sup_mul_nat Ordinal.sup_mul_nat
-/

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

#print Acc.rank_eq /-
theorem rank_eq (h : Acc r a) :
    h.rank = Ordinal.sup.{u, u} fun b : { b // r b a } => Order.succ (h.inv b.2).rank := by
  change (Acc.intro a fun _ => h.inv).rank = _; rfl
#align acc.rank_eq Acc.rank_eq
-/

#print Acc.rank_lt_of_rel /-
/-- if `r a b` then the rank of `a` is less than the rank of `b`. -/
theorem rank_lt_of_rel (hb : Acc r b) (h : r a b) : (hb.inv h).rank < hb.rank :=
  (Order.lt_succ _).trans_le <| by rw [hb.rank_eq]; refine' le_trans _ (Ordinal.le_sup _ ⟨a, h⟩);
    rfl
#align acc.rank_lt_of_rel Acc.rank_lt_of_rel
-/

end Acc

namespace WellFounded

variable (hwf : WellFounded r)

#print WellFounded.rank /-
/-- The rank of an element `a` under a well-founded relation `r` is defined inductively as the
smallest ordinal greater than the ranks of all elements below it (i.e. elements `b` such that
`r b a`). -/
noncomputable def rank (a : α) : Ordinal.{u} :=
  (hwf.apply a).rank
#align well_founded.rank WellFounded.rank
-/

#print WellFounded.rank_eq /-
theorem rank_eq :
    hwf.rank a = Ordinal.sup.{u, u} fun b : { b // r b a } => Order.succ <| hwf.rank b := by
  rw [rank, Acc.rank_eq]; rfl
#align well_founded.rank_eq WellFounded.rank_eq
-/

#print WellFounded.rank_lt_of_rel /-
theorem rank_lt_of_rel (h : r a b) : hwf.rank a < hwf.rank b :=
  Acc.rank_lt_of_rel _ h
#align well_founded.rank_lt_of_rel WellFounded.rank_lt_of_rel
-/

#print WellFounded.rank_strictMono /-
theorem rank_strictMono [Preorder α] [WellFoundedLT α] :
    StrictMono (rank <| @IsWellFounded.wf α (· < ·) _) := fun _ _ => rank_lt_of_rel _
#align well_founded.rank_strict_mono WellFounded.rank_strictMono
-/

#print WellFounded.rank_strictAnti /-
theorem rank_strictAnti [Preorder α] [WellFoundedGT α] :
    StrictAnti (rank <| @IsWellFounded.wf α (· > ·) _) := fun _ _ =>
  rank_lt_of_rel <| @IsWellFounded.wf α (· > ·) _
#align well_founded.rank_strict_anti WellFounded.rank_strictAnti
-/

end WellFounded

