/-
Copyright (c) 2020 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Mario Carneiro, Yury G. Kudryashov

! This file was ported from Lean 3 source module order.rel_classes
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Basic
import Mathbin.Logic.IsEmpty

/-!
# Unbundled relation classes

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove some properties of `is_*` classes defined in `init.algebra.classes`. The main
difference between these classes and the usual order classes (`preorder` etc) is that usual classes
extend `has_le` and/or `has_lt` while these classes take a relation as an explicit argument.

-/


universe u v

variable {α : Type u} {β : Type v} {r : α → α → Prop} {s : β → β → Prop}

open Function

#print of_eq /-
theorem of_eq [IsRefl α r] : ∀ {a b}, a = b → r a b
  | _, _, ⟨h⟩ => refl _
#align of_eq of_eq
-/

#print comm /-
theorem comm [IsSymm α r] {a b : α} : r a b ↔ r b a :=
  ⟨symm, symm⟩
#align comm comm
-/

#print antisymm' /-
theorem antisymm' [IsAntisymm α r] {a b : α} : r a b → r b a → b = a := fun h h' => antisymm h' h
#align antisymm' antisymm'
-/

#print antisymm_iff /-
theorem antisymm_iff [IsRefl α r] [IsAntisymm α r] {a b : α} : r a b ∧ r b a ↔ a = b :=
  ⟨fun h => antisymm h.1 h.2, by
    rintro rfl
    exact ⟨refl _, refl _⟩⟩
#align antisymm_iff antisymm_iff
-/

#print antisymm_of /-
/-- A version of `antisymm` with `r` explicit.

This lemma matches the lemmas from lean core in `init.algebra.classes`, but is missing there.  -/
@[elab_without_expected_type]
theorem antisymm_of (r : α → α → Prop) [IsAntisymm α r] {a b : α} : r a b → r b a → a = b :=
  antisymm
#align antisymm_of antisymm_of
-/

#print antisymm_of' /-
/-- A version of `antisymm'` with `r` explicit.

This lemma matches the lemmas from lean core in `init.algebra.classes`, but is missing there.  -/
@[elab_without_expected_type]
theorem antisymm_of' (r : α → α → Prop) [IsAntisymm α r] {a b : α} : r a b → r b a → b = a :=
  antisymm'
#align antisymm_of' antisymm_of'
-/

#print comm_of /-
/-- A version of `comm` with `r` explicit.

This lemma matches the lemmas from lean core in `init.algebra.classes`, but is missing there.  -/
theorem comm_of (r : α → α → Prop) [IsSymm α r] {a b : α} : r a b ↔ r b a :=
  comm
#align comm_of comm_of
-/

#print IsRefl.swap /-
theorem IsRefl.swap (r) [IsRefl α r] : IsRefl α (swap r) :=
  ⟨refl_of r⟩
#align is_refl.swap IsRefl.swap
-/

#print IsIrrefl.swap /-
theorem IsIrrefl.swap (r) [IsIrrefl α r] : IsIrrefl α (swap r) :=
  ⟨irrefl_of r⟩
#align is_irrefl.swap IsIrrefl.swap
-/

#print IsTrans.swap /-
theorem IsTrans.swap (r) [IsTrans α r] : IsTrans α (swap r) :=
  ⟨fun a b c h₁ h₂ => trans_of r h₂ h₁⟩
#align is_trans.swap IsTrans.swap
-/

#print IsAntisymm.swap /-
theorem IsAntisymm.swap (r) [IsAntisymm α r] : IsAntisymm α (swap r) :=
  ⟨fun a b h₁ h₂ => antisymm h₂ h₁⟩
#align is_antisymm.swap IsAntisymm.swap
-/

#print IsAsymm.swap /-
theorem IsAsymm.swap (r) [IsAsymm α r] : IsAsymm α (swap r) :=
  ⟨fun a b h₁ h₂ => asymm_of r h₂ h₁⟩
#align is_asymm.swap IsAsymm.swap
-/

#print IsTotal.swap /-
theorem IsTotal.swap (r) [IsTotal α r] : IsTotal α (swap r) :=
  ⟨fun a b => (total_of r a b).swap⟩
#align is_total.swap IsTotal.swap
-/

#print IsTrichotomous.swap /-
theorem IsTrichotomous.swap (r) [IsTrichotomous α r] : IsTrichotomous α (swap r) :=
  ⟨fun a b => by simpa [swap, or_comm, or_left_comm] using trichotomous_of r a b⟩
#align is_trichotomous.swap IsTrichotomous.swap
-/

#print IsPreorder.swap /-
theorem IsPreorder.swap (r) [IsPreorder α r] : IsPreorder α (swap r) :=
  { @IsRefl.swap α r _, @IsTrans.swap α r _ with }
#align is_preorder.swap IsPreorder.swap
-/

#print IsStrictOrder.swap /-
theorem IsStrictOrder.swap (r) [IsStrictOrder α r] : IsStrictOrder α (swap r) :=
  { @IsIrrefl.swap α r _, @IsTrans.swap α r _ with }
#align is_strict_order.swap IsStrictOrder.swap
-/

#print IsPartialOrder.swap /-
theorem IsPartialOrder.swap (r) [IsPartialOrder α r] : IsPartialOrder α (swap r) :=
  { @IsPreorder.swap α r _, @IsAntisymm.swap α r _ with }
#align is_partial_order.swap IsPartialOrder.swap
-/

#print IsTotalPreorder.swap /-
theorem IsTotalPreorder.swap (r) [IsTotalPreorder α r] : IsTotalPreorder α (swap r) :=
  { @IsPreorder.swap α r _, @IsTotal.swap α r _ with }
#align is_total_preorder.swap IsTotalPreorder.swap
-/

#print IsLinearOrder.swap /-
theorem IsLinearOrder.swap (r) [IsLinearOrder α r] : IsLinearOrder α (swap r) :=
  { @IsPartialOrder.swap α r _, @IsTotal.swap α r _ with }
#align is_linear_order.swap IsLinearOrder.swap
-/

protected theorem IsAsymm.is_antisymm (r) [IsAsymm α r] : IsAntisymm α r :=
  ⟨fun x y h₁ h₂ => (asymm h₁ h₂).elim⟩
#align is_asymm.is_antisymm IsAsymm.is_antisymm

protected theorem IsAsymm.is_irrefl [IsAsymm α r] : IsIrrefl α r :=
  ⟨fun a h => asymm h h⟩
#align is_asymm.is_irrefl IsAsymm.is_irrefl

protected theorem IsTotal.is_trichotomous (r) [IsTotal α r] : IsTrichotomous α r :=
  ⟨fun a b => or_left_comm.1 (Or.inr <| total_of r a b)⟩
#align is_total.is_trichotomous IsTotal.is_trichotomous

-- see Note [lower instance priority]
instance (priority := 100) IsTotal.to_is_refl (r) [IsTotal α r] : IsRefl α r :=
  ⟨fun a => (or_self_iff _).1 <| total_of r a a⟩
#align is_total.to_is_refl IsTotal.to_is_refl

#print ne_of_irrefl /-
theorem ne_of_irrefl {r} [IsIrrefl α r] : ∀ {x y : α}, r x y → x ≠ y
  | _, _, h, rfl => irrefl _ h
#align ne_of_irrefl ne_of_irrefl
-/

#print ne_of_irrefl' /-
theorem ne_of_irrefl' {r} [IsIrrefl α r] : ∀ {x y : α}, r x y → y ≠ x
  | _, _, h, rfl => irrefl _ h
#align ne_of_irrefl' ne_of_irrefl'
-/

#print not_rel_of_subsingleton /-
theorem not_rel_of_subsingleton (r) [IsIrrefl α r] [Subsingleton α] (x y) : ¬r x y :=
  Subsingleton.elim x y ▸ irrefl x
#align not_rel_of_subsingleton not_rel_of_subsingleton
-/

#print rel_of_subsingleton /-
theorem rel_of_subsingleton (r) [IsRefl α r] [Subsingleton α] (x y) : r x y :=
  Subsingleton.elim x y ▸ refl x
#align rel_of_subsingleton rel_of_subsingleton
-/

#print empty_relation_apply /-
@[simp]
theorem empty_relation_apply (a b : α) : EmptyRelation a b ↔ False :=
  Iff.rfl
#align empty_relation_apply empty_relation_apply
-/

#print eq_empty_relation /-
theorem eq_empty_relation (r) [IsIrrefl α r] [Subsingleton α] : r = EmptyRelation :=
  funext₂ <| by simpa using not_rel_of_subsingleton r
#align eq_empty_relation eq_empty_relation
-/

instance : IsIrrefl α EmptyRelation :=
  ⟨fun a => id⟩

#print trans_trichotomous_left /-
theorem trans_trichotomous_left [IsTrans α r] [IsTrichotomous α r] {a b c : α} :
    ¬r b a → r b c → r a c := by
  intro h₁ h₂; rcases trichotomous_of r a b with (h₃ | h₃ | h₃)
  exact trans h₃ h₂; rw [h₃]; exact h₂; exfalso; exact h₁ h₃
#align trans_trichotomous_left trans_trichotomous_left
-/

#print trans_trichotomous_right /-
theorem trans_trichotomous_right [IsTrans α r] [IsTrichotomous α r] {a b c : α} :
    r a b → ¬r c b → r a c := by
  intro h₁ h₂; rcases trichotomous_of r b c with (h₃ | h₃ | h₃)
  exact trans h₁ h₃; rw [← h₃]; exact h₁; exfalso; exact h₂ h₃
#align trans_trichotomous_right trans_trichotomous_right
-/

#print transitive_of_trans /-
theorem transitive_of_trans (r : α → α → Prop) [IsTrans α r] : Transitive r := fun _ _ _ => trans
#align transitive_of_trans transitive_of_trans
-/

#print extensional_of_trichotomous_of_irrefl /-
/-- In a trichotomous irreflexive order, every element is determined by the set of predecessors. -/
theorem extensional_of_trichotomous_of_irrefl (r : α → α → Prop) [IsTrichotomous α r] [IsIrrefl α r]
    {a b : α} (H : ∀ x, r x a ↔ r x b) : a = b :=
  ((@trichotomous _ r _ a b).resolve_left <| mt (H _).2 <| irrefl a).resolve_right <|
    mt (H _).1 <| irrefl b
#align extensional_of_trichotomous_of_irrefl extensional_of_trichotomous_of_irrefl
-/

#print partialOrderOfSO /-
/-- Construct a partial order from a `is_strict_order` relation.

See note [reducible non-instances]. -/
@[reducible]
def partialOrderOfSO (r) [IsStrictOrder α r] : PartialOrder α
    where
  le x y := x = y ∨ r x y
  lt := r
  le_refl x := Or.inl rfl
  le_trans x y z h₁ h₂ :=
    match y, z, h₁, h₂ with
    | _, _, Or.inl rfl, h₂ => h₂
    | _, _, h₁, Or.inl rfl => h₁
    | _, _, Or.inr h₁, Or.inr h₂ => Or.inr (trans h₁ h₂)
  le_antisymm x y h₁ h₂ :=
    match y, h₁, h₂ with
    | _, Or.inl rfl, h₂ => rfl
    | _, h₁, Or.inl rfl => rfl
    | _, Or.inr h₁, Or.inr h₂ => (asymm h₁ h₂).elim
  lt_iff_le_not_le x y :=
    ⟨fun h => ⟨Or.inr h, not_or_of_not (fun e => by rw [e] at h <;> exact irrefl _ h) (asymm h)⟩,
      fun ⟨h₁, h₂⟩ => h₁.resolve_left fun e => h₂ <| e ▸ Or.inl rfl⟩
#align partial_order_of_SO partialOrderOfSO
-/

#print linearOrderOfSTO /-
/-- Construct a linear order from an `is_strict_total_order` relation.

See note [reducible non-instances]. -/
@[reducible]
def linearOrderOfSTO (r) [IsStrictTotalOrder α r] [∀ x y, Decidable ¬r x y] : LinearOrder α :=
  {
    partialOrderOfSO
      r with
    le_total := fun x y =>
      match y, trichotomous_of r x y with
      | y, Or.inl h => Or.inl (Or.inr h)
      | _, Or.inr (Or.inl rfl) => Or.inl (Or.inl rfl)
      | _, Or.inr (Or.inr h) => Or.inr (Or.inr h)
    decidableLe := fun x y =>
      decidable_of_iff (¬r y x)
        ⟨fun h => ((trichotomous_of r y x).resolve_left h).imp Eq.symm id, fun h =>
          h.elim (fun h => h ▸ irrefl_of _ _) (asymm_of r)⟩ }
#align linear_order_of_STO linearOrderOfSTO
-/

#print IsStrictTotalOrder.swap /-
theorem IsStrictTotalOrder.swap (r) [IsStrictTotalOrder α r] : IsStrictTotalOrder α (swap r) :=
  { IsTrichotomous.swap r, IsStrictOrder.swap r with }
#align is_strict_total_order.swap IsStrictTotalOrder.swap
-/

/-! ### Order connection -/


#print IsOrderConnected /-
/-- A connected order is one satisfying the condition `a < c → a < b ∨ b < c`.
  This is recognizable as an intuitionistic substitute for `a ≤ b ∨ b ≤ a` on
  the constructive reals, and is also known as negative transitivity,
  since the contrapositive asserts transitivity of the relation `¬ a < b`.  -/
class IsOrderConnected (α : Type u) (lt : α → α → Prop) : Prop where
  conn : ∀ a b c, lt a c → lt a b ∨ lt b c
#align is_order_connected IsOrderConnected
-/

#print IsOrderConnected.neg_trans /-
theorem IsOrderConnected.neg_trans {r : α → α → Prop} [IsOrderConnected α r] {a b c} (h₁ : ¬r a b)
    (h₂ : ¬r b c) : ¬r a c :=
  mt (IsOrderConnected.conn a b c) <| by simp [h₁, h₂]
#align is_order_connected.neg_trans IsOrderConnected.neg_trans
-/

#print isStrictWeakOrder_of_isOrderConnected /-
theorem isStrictWeakOrder_of_isOrderConnected [IsAsymm α r] [IsOrderConnected α r] :
    IsStrictWeakOrder α r :=
  {
    @IsAsymm.is_irrefl α r
      _ with
    trans := fun a b c h₁ h₂ => (IsOrderConnected.conn _ c _ h₁).resolve_right (asymm h₂)
    incomp_trans := fun a b c ⟨h₁, h₂⟩ ⟨h₃, h₄⟩ =>
      ⟨IsOrderConnected.neg_trans h₁ h₃, IsOrderConnected.neg_trans h₄ h₂⟩ }
#align is_strict_weak_order_of_is_order_connected isStrictWeakOrder_of_isOrderConnected
-/

#print isStrictOrderConnected_of_isStrictTotalOrder /-
-- see Note [lower instance priority]
instance (priority := 100) isStrictOrderConnected_of_isStrictTotalOrder [IsStrictTotalOrder α r] :
    IsOrderConnected α r :=
  ⟨fun a b c h =>
    (trichotomous _ _).imp_right fun o => o.elim (fun e => e ▸ h) fun h' => trans h' h⟩
#align is_order_connected_of_is_strict_total_order isStrictOrderConnected_of_isStrictTotalOrder
-/

#print isStrictTotalOrder_of_isStrictTotalOrder /-
-- see Note [lower instance priority]
instance (priority := 100) isStrictTotalOrder_of_isStrictTotalOrder [IsStrictTotalOrder α r] :
    IsStrictWeakOrder α r :=
  { isStrictWeakOrder_of_isOrderConnected with }
#align is_strict_weak_order_of_is_strict_total_order isStrictTotalOrder_of_isStrictTotalOrder
-/

/-! ### Well-order -/


#print IsWellFounded /-
/-- A well-founded relation. Not to be confused with `is_well_order`. -/
@[mk_iff]
class IsWellFounded (α : Type u) (r : α → α → Prop) : Prop where
  wf : WellFounded r
#align is_well_founded IsWellFounded
-/

instance WellFoundedRelation.is_well_founded [h : WellFoundedRelation α] :
    IsWellFounded α WellFoundedRelation.R :=
  { h with }
#align has_well_founded.is_well_founded WellFoundedRelation.is_well_founded

namespace IsWellFounded

variable (r) [IsWellFounded α r]

#print IsWellFounded.induction /-
/-- Induction on a well-founded relation. -/
theorem induction {C : α → Prop} : ∀ a, (∀ x, (∀ y, r y x → C y) → C x) → C a :=
  wf.induction
#align is_well_founded.induction IsWellFounded.induction
-/

#print IsWellFounded.apply /-
/-- All values are accessible under the well-founded relation. -/
theorem apply : ∀ a, Acc r a :=
  wf.apply
#align is_well_founded.apply IsWellFounded.apply
-/

#print IsWellFounded.fix /-
/-- Creates data, given a way to generate a value from all that compare as less under a well-founded
relation. See also `is_well_founded.fix_eq`. -/
def fix {C : α → Sort _} : (∀ x : α, (∀ y : α, r y x → C y) → C x) → ∀ x : α, C x :=
  wf.fix
#align is_well_founded.fix IsWellFounded.fix
-/

/- warning: is_well_founded.fix_eq -> IsWellFounded.fix_eq is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} (r : α -> α -> Prop) [_inst_1 : IsWellFounded.{u1} α r] {C : α -> Sort.{u2}} (F : forall (x : α), (forall (y : α), (r y x) -> (C y)) -> (C x)) (x : α), Eq.{u2} (C x) (IsWellFounded.fix.{u1, u2} α r _inst_1 (fun (y : α) => C y) F x) (F x (fun (y : α) (h : r y x) => IsWellFounded.fix.{u1, u2} α r _inst_1 C F y))
but is expected to have type
  forall {α : Type.{u2}} (r : α -> α -> Prop) [_inst_1 : IsWellFounded.{u2} α r] {C : α -> Sort.{u1}} (F : forall (x : α), (forall (y : α), (r y x) -> (C y)) -> (C x)) (x : α), Eq.{u1} (C x) (IsWellFounded.fix.{u2, u1} α r _inst_1 (fun (y : α) => C y) F x) (F x (fun (y : α) (h : r y x) => IsWellFounded.fix.{u2, u1} α r _inst_1 (fun (y : α) => C y) F y))
Case conversion may be inaccurate. Consider using '#align is_well_founded.fix_eq IsWellFounded.fix_eqₓ'. -/
/-- The value from `is_well_founded.fix` is built from the previous ones as specified. -/
theorem fix_eq {C : α → Sort _} (F : ∀ x : α, (∀ y : α, r y x → C y) → C x) :
    ∀ x, fix r F x = F x fun y h => fix r F y :=
  wf.fix_eq F
#align is_well_founded.fix_eq IsWellFounded.fix_eq

/-- Derive a `has_well_founded` instance from an `is_well_founded` instance. -/
def toHasWellFounded : WellFoundedRelation α :=
  ⟨r, IsWellFounded.wf⟩
#align is_well_founded.to_has_well_founded IsWellFounded.toHasWellFounded

end IsWellFounded

#print WellFounded.asymmetric /-
theorem WellFounded.asymmetric {α : Sort _} {r : α → α → Prop} (h : WellFounded r) :
    ∀ ⦃a b⦄, r a b → ¬r b a
  | a => fun b hab hba => WellFounded.asymmetric hba hab termination_by' ⟨_, h⟩
#align well_founded.asymmetric WellFounded.asymmetric
-/

-- see Note [lower instance priority]
instance (priority := 100) IsWellFounded.is_asymm (r : α → α → Prop) [IsWellFounded α r] :
    IsAsymm α r :=
  ⟨IsWellFounded.wf.asymmetric⟩
#align is_well_founded.is_asymm IsWellFounded.is_asymm

-- see Note [lower instance priority]
instance (priority := 100) IsWellFounded.is_irrefl (r : α → α → Prop) [IsWellFounded α r] :
    IsIrrefl α r :=
  IsAsymm.is_irrefl
#align is_well_founded.is_irrefl IsWellFounded.is_irrefl

/-- A class for a well founded relation `<`. -/
@[reducible]
def WellFoundedLt (α : Type _) [LT α] : Prop :=
  IsWellFounded α (· < ·)
#align well_founded_lt WellFoundedLt

/-- A class for a well founded relation `>`. -/
@[reducible]
def WellFoundedGt (α : Type _) [LT α] : Prop :=
  IsWellFounded α (· > ·)
#align well_founded_gt WellFoundedGt

-- See note [lower instance priority]
instance (priority := 100) (α : Type _) [LT α] [h : WellFoundedLt α] : WellFoundedGt αᵒᵈ :=
  h

-- See note [lower instance priority]
instance (priority := 100) (α : Type _) [LT α] [h : WellFoundedGt α] : WellFoundedLt αᵒᵈ :=
  h

theorem well_founded_gt_dual_iff (α : Type _) [LT α] : WellFoundedGt αᵒᵈ ↔ WellFoundedLt α :=
  ⟨fun h => ⟨h.wf⟩, fun h => ⟨h.wf⟩⟩
#align well_founded_gt_dual_iff well_founded_gt_dual_iff

theorem well_founded_lt_dual_iff (α : Type _) [LT α] : WellFoundedLt αᵒᵈ ↔ WellFoundedGt α :=
  ⟨fun h => ⟨h.wf⟩, fun h => ⟨h.wf⟩⟩
#align well_founded_lt_dual_iff well_founded_lt_dual_iff

#print IsWellOrder /-
/-- A well order is a well-founded linear order. -/
class IsWellOrder (α : Type u) (r : α → α → Prop) extends IsTrichotomous α r, IsTrans α r,
  IsWellFounded α r : Prop
#align is_well_order IsWellOrder
-/

-- see Note [lower instance priority]
instance (priority := 100) IsWellOrder.is_strict_total_order {α} (r : α → α → Prop)
    [IsWellOrder α r] : IsStrictTotalOrder α r where
#align is_well_order.is_strict_total_order IsWellOrder.is_strict_total_order

-- see Note [lower instance priority]
instance (priority := 100) IsWellOrder.is_trichotomous {α} (r : α → α → Prop) [IsWellOrder α r] :
    IsTrichotomous α r := by infer_instance
#align is_well_order.is_trichotomous IsWellOrder.is_trichotomous

-- see Note [lower instance priority]
instance (priority := 100) IsWellOrder.is_trans {α} (r : α → α → Prop) [IsWellOrder α r] :
    IsTrans α r := by infer_instance
#align is_well_order.is_trans IsWellOrder.is_trans

-- see Note [lower instance priority]
instance (priority := 100) IsWellOrder.is_irrefl {α} (r : α → α → Prop) [IsWellOrder α r] :
    IsIrrefl α r := by infer_instance
#align is_well_order.is_irrefl IsWellOrder.is_irrefl

-- see Note [lower instance priority]
instance (priority := 100) IsWellOrder.is_asymm {α} (r : α → α → Prop) [IsWellOrder α r] :
    IsAsymm α r := by infer_instance
#align is_well_order.is_asymm IsWellOrder.is_asymm

namespace WellFoundedLt

variable [LT α] [WellFoundedLt α]

/-- Inducts on a well-founded `<` relation. -/
theorem induction {C : α → Prop} : ∀ a, (∀ x, (∀ y, y < x → C y) → C x) → C a :=
  IsWellFounded.induction _
#align well_founded_lt.induction WellFoundedLt.induction

/-- All values are accessible under the well-founded `<`. -/
theorem apply : ∀ a : α, Acc (· < ·) a :=
  IsWellFounded.apply _
#align well_founded_lt.apply WellFoundedLt.apply

/-- Creates data, given a way to generate a value from all that compare as lesser. See also
`well_founded_lt.fix_eq`. -/
def fix {C : α → Sort _} : (∀ x : α, (∀ y : α, y < x → C y) → C x) → ∀ x : α, C x :=
  IsWellFounded.fix (· < ·)
#align well_founded_lt.fix WellFoundedLt.fix

/-- The value from `well_founded_lt.fix` is built from the previous ones as specified. -/
theorem fix_eq {C : α → Sort _} (F : ∀ x : α, (∀ y : α, y < x → C y) → C x) :
    ∀ x, fix F x = F x fun y h => fix F y :=
  IsWellFounded.fix_eq _ F
#align well_founded_lt.fix_eq WellFoundedLt.fix_eq

/-- Derive a `has_well_founded` instance from a `well_founded_lt` instance. -/
def toHasWellFounded : WellFoundedRelation α :=
  IsWellFounded.toHasWellFounded (· < ·)
#align well_founded_lt.to_has_well_founded WellFoundedLt.toHasWellFounded

end WellFoundedLt

namespace WellFoundedGt

variable [LT α] [WellFoundedGt α]

/-- Inducts on a well-founded `>` relation. -/
theorem induction {C : α → Prop} : ∀ a, (∀ x, (∀ y, x < y → C y) → C x) → C a :=
  IsWellFounded.induction _
#align well_founded_gt.induction WellFoundedGt.induction

/-- All values are accessible under the well-founded `>`. -/
theorem apply : ∀ a : α, Acc (· > ·) a :=
  IsWellFounded.apply _
#align well_founded_gt.apply WellFoundedGt.apply

/-- Creates data, given a way to generate a value from all that compare as greater. See also
`well_founded_gt.fix_eq`. -/
def fix {C : α → Sort _} : (∀ x : α, (∀ y : α, x < y → C y) → C x) → ∀ x : α, C x :=
  IsWellFounded.fix (· > ·)
#align well_founded_gt.fix WellFoundedGt.fix

/-- The value from `well_founded_gt.fix` is built from the successive ones as specified. -/
theorem fix_eq {C : α → Sort _} (F : ∀ x : α, (∀ y : α, x < y → C y) → C x) :
    ∀ x, fix F x = F x fun y h => fix F y :=
  IsWellFounded.fix_eq _ F
#align well_founded_gt.fix_eq WellFoundedGt.fix_eq

/-- Derive a `has_well_founded` instance from a `well_founded_gt` instance. -/
def toHasWellFounded : WellFoundedRelation α :=
  IsWellFounded.toHasWellFounded (· > ·)
#align well_founded_gt.to_has_well_founded WellFoundedGt.toHasWellFounded

end WellFoundedGt

#print IsWellOrder.linearOrder /-
/-- Construct a decidable linear order from a well-founded linear order. -/
noncomputable def IsWellOrder.linearOrder (r : α → α → Prop) [IsWellOrder α r] : LinearOrder α :=
  letI := fun x y => Classical.dec ¬r x y
  linearOrderOfSTO r
#align is_well_order.linear_order IsWellOrder.linearOrder
-/

#print IsWellOrder.toHasWellFounded /-
/-- Derive a `has_well_founded` instance from a `is_well_order` instance. -/
def IsWellOrder.toHasWellFounded [LT α] [hwo : IsWellOrder α (· < ·)] : WellFoundedRelation α
    where
  R := (· < ·)
  wf := hwo.wf
#align is_well_order.to_has_well_founded IsWellOrder.toHasWellFounded
-/

-- This isn't made into an instance as it loops with `is_irrefl α r`.
theorem Subsingleton.is_well_order [Subsingleton α] (r : α → α → Prop) [hr : IsIrrefl α r] :
    IsWellOrder α r :=
  { hr with
    trichotomous := fun a b => Or.inr <| Or.inl <| Subsingleton.elim a b
    trans := fun a b c h => (not_rel_of_subsingleton r a b h).elim
    wf := ⟨fun a => ⟨_, fun y h => (not_rel_of_subsingleton r y a h).elim⟩⟩ }
#align subsingleton.is_well_order Subsingleton.is_well_order

instance EmptyRelation.is_well_order [Subsingleton α] : IsWellOrder α EmptyRelation :=
  Subsingleton.is_well_order _
#align empty_relation.is_well_order EmptyRelation.is_well_order

instance (priority := 100) IsEmpty.is_well_order [IsEmpty α] (r : α → α → Prop) : IsWellOrder α r
    where
  trichotomous := isEmptyElim
  trans := isEmptyElim
  wf := wellFounded_of_isEmpty r
#align is_empty.is_well_order IsEmpty.is_well_order

instance Prod.Lex.is_well_founded [IsWellFounded α r] [IsWellFounded β s] :
    IsWellFounded (α × β) (Prod.Lex r s) :=
  ⟨Prod.lex_wf IsWellFounded.wf IsWellFounded.wf⟩
#align prod.lex.is_well_founded Prod.Lex.is_well_founded

instance Prod.Lex.is_well_order [IsWellOrder α r] [IsWellOrder β s] :
    IsWellOrder (α × β) (Prod.Lex r s)
    where
  trichotomous := fun ⟨a₁, a₂⟩ ⟨b₁, b₂⟩ =>
    match @trichotomous _ r _ a₁ b₁ with
    | Or.inl h₁ => Or.inl <| Prod.Lex.left _ _ h₁
    | Or.inr (Or.inr h₁) => Or.inr <| Or.inr <| Prod.Lex.left _ _ h₁
    | Or.inr (Or.inl e) =>
      e ▸
        match @trichotomous _ s _ a₂ b₂ with
        | Or.inl h => Or.inl <| Prod.Lex.right _ h
        | Or.inr (Or.inr h) => Or.inr <| Or.inr <| Prod.Lex.right _ h
        | Or.inr (Or.inl e) => e ▸ Or.inr <| Or.inl rfl
  trans a b c h₁ h₂ :=
    by
    cases' h₁ with a₁ a₂ b₁ b₂ ab a₁ b₁ b₂ ab <;> cases' h₂ with _ _ c₁ c₂ bc _ _ c₂ bc
    · exact Prod.Lex.left _ _ (trans ab bc)
    · exact Prod.Lex.left _ _ ab
    · exact Prod.Lex.left _ _ bc
    · exact Prod.Lex.right _ (trans ab bc)
  wf := Prod.lex_wf IsWellFounded.wf IsWellFounded.wf
#align prod.lex.is_well_order Prod.Lex.is_well_order

instance InvImage.is_well_founded (r : α → α → Prop) [IsWellFounded α r] (f : β → α) :
    IsWellFounded _ (InvImage r f) :=
  ⟨InvImage.wf f IsWellFounded.wf⟩
#align inv_image.is_well_founded InvImage.is_well_founded

instance Measure.is_well_founded (f : α → ℕ) : IsWellFounded _ (Measure f) :=
  ⟨measure_wf f⟩
#align measure.is_well_founded Measure.is_well_founded

theorem Subrelation.is_well_founded (r : α → α → Prop) [IsWellFounded α r] {s : α → α → Prop}
    (h : Subrelation s r) : IsWellFounded α s :=
  ⟨h.wf IsWellFounded.wf⟩
#align subrelation.is_well_founded Subrelation.is_well_founded

namespace Set

#print Set.Unbounded /-
/-- An unbounded or cofinal set. -/
def Unbounded (r : α → α → Prop) (s : Set α) : Prop :=
  ∀ a, ∃ b ∈ s, ¬r b a
#align set.unbounded Set.Unbounded
-/

#print Set.Bounded /-
/-- A bounded or final set. Not to be confused with `metric.bounded`. -/
def Bounded (r : α → α → Prop) (s : Set α) : Prop :=
  ∃ a, ∀ b ∈ s, r b a
#align set.bounded Set.Bounded
-/

#print Set.not_bounded_iff /-
@[simp]
theorem not_bounded_iff {r : α → α → Prop} (s : Set α) : ¬Bounded r s ↔ Unbounded r s := by
  simp only [bounded, unbounded, not_forall, not_exists, exists_prop, not_and, not_not]
#align set.not_bounded_iff Set.not_bounded_iff
-/

#print Set.not_unbounded_iff /-
@[simp]
theorem not_unbounded_iff {r : α → α → Prop} (s : Set α) : ¬Unbounded r s ↔ Bounded r s := by
  rw [not_iff_comm, not_bounded_iff]
#align set.not_unbounded_iff Set.not_unbounded_iff
-/

theorem unbounded_of_is_empty [IsEmpty α] {r : α → α → Prop} (s : Set α) : Unbounded r s :=
  isEmptyElim
#align set.unbounded_of_is_empty Set.unbounded_of_is_empty

end Set

namespace Prod

instance is_refl_preimage_fst {r : α → α → Prop} [h : IsRefl α r] :
    IsRefl (α × α) (Prod.fst ⁻¹'o r) :=
  ⟨fun a => refl_of r a.1⟩
#align prod.is_refl_preimage_fst Prod.is_refl_preimage_fst

instance is_refl_preimage_snd {r : α → α → Prop} [h : IsRefl α r] :
    IsRefl (α × α) (Prod.snd ⁻¹'o r) :=
  ⟨fun a => refl_of r a.2⟩
#align prod.is_refl_preimage_snd Prod.is_refl_preimage_snd

instance is_trans_preimage_fst {r : α → α → Prop} [h : IsTrans α r] :
    IsTrans (α × α) (Prod.fst ⁻¹'o r) :=
  ⟨fun _ _ _ => trans_of r⟩
#align prod.is_trans_preimage_fst Prod.is_trans_preimage_fst

instance is_trans_preimage_snd {r : α → α → Prop} [h : IsTrans α r] :
    IsTrans (α × α) (Prod.snd ⁻¹'o r) :=
  ⟨fun _ _ _ => trans_of r⟩
#align prod.is_trans_preimage_snd Prod.is_trans_preimage_snd

end Prod

/-! ### Strict-non strict relations -/


#print IsNonstrictStrictOrder /-
/-- An unbundled relation class stating that `r` is the nonstrict relation corresponding to the
strict relation `s`. Compare `preorder.lt_iff_le_not_le`. This is mostly meant to provide dot
notation on `(⊆)` and `(⊂)`. -/
class IsNonstrictStrictOrder (α : Type _) (r s : α → α → Prop) where
  right_iff_left_not_left (a b : α) : s a b ↔ r a b ∧ ¬r b a
#align is_nonstrict_strict_order IsNonstrictStrictOrder
-/

#print right_iff_left_not_left /-
theorem right_iff_left_not_left {r s : α → α → Prop} [IsNonstrictStrictOrder α r s] {a b : α} :
    s a b ↔ r a b ∧ ¬r b a :=
  IsNonstrictStrictOrder.right_iff_left_not_left _ _
#align right_iff_left_not_left right_iff_left_not_left
-/

#print right_iff_left_not_left_of /-
/-- A version of `right_iff_left_not_left` with explicit `r` and `s`. -/
theorem right_iff_left_not_left_of (r s : α → α → Prop) [IsNonstrictStrictOrder α r s] {a b : α} :
    s a b ↔ r a b ∧ ¬r b a :=
  right_iff_left_not_left
#align right_iff_left_not_left_of right_iff_left_not_left_of
-/

-- The free parameter `r` is strictly speaking not uniquely determined by `s`, but in practice it
-- always has a unique instance, so this is not dangerous.
-- see Note [lower instance priority]
@[nolint dangerous_instance]
instance (priority := 100) IsNonstrictStrictOrder.to_is_irrefl {r : α → α → Prop} {s : α → α → Prop}
    [IsNonstrictStrictOrder α r s] : IsIrrefl α s :=
  ⟨fun a h => ((right_iff_left_not_left_of r s).1 h).2 ((right_iff_left_not_left_of r s).1 h).1⟩
#align is_nonstrict_strict_order.to_is_irrefl IsNonstrictStrictOrder.to_is_irrefl

/-! #### `⊆` and `⊂` -/


section Subset

variable [HasSubset α] {a b c : α}

#print subset_refl /-
@[refl]
theorem subset_refl [IsRefl α (· ⊆ ·)] (a : α) : a ⊆ a :=
  refl _
#align subset_refl subset_refl
-/

#print subset_rfl /-
theorem subset_rfl [IsRefl α (· ⊆ ·)] : a ⊆ a :=
  refl _
#align subset_rfl subset_rfl
-/

#print subset_of_eq /-
theorem subset_of_eq [IsRefl α (· ⊆ ·)] : a = b → a ⊆ b := fun h => h ▸ subset_rfl
#align subset_of_eq subset_of_eq
-/

#print superset_of_eq /-
theorem superset_of_eq [IsRefl α (· ⊆ ·)] : a = b → b ⊆ a := fun h => h ▸ subset_rfl
#align superset_of_eq superset_of_eq
-/

#print ne_of_not_subset /-
theorem ne_of_not_subset [IsRefl α (· ⊆ ·)] : ¬a ⊆ b → a ≠ b :=
  mt subset_of_eq
#align ne_of_not_subset ne_of_not_subset
-/

#print ne_of_not_superset /-
theorem ne_of_not_superset [IsRefl α (· ⊆ ·)] : ¬a ⊆ b → b ≠ a :=
  mt superset_of_eq
#align ne_of_not_superset ne_of_not_superset
-/

#print subset_trans /-
@[trans]
theorem subset_trans [IsTrans α (· ⊆ ·)] {a b c : α} : a ⊆ b → b ⊆ c → a ⊆ c :=
  trans
#align subset_trans subset_trans
-/

#print subset_antisymm /-
theorem subset_antisymm [IsAntisymm α (· ⊆ ·)] (h : a ⊆ b) (h' : b ⊆ a) : a = b :=
  antisymm h h'
#align subset_antisymm subset_antisymm
-/

#print superset_antisymm /-
theorem superset_antisymm [IsAntisymm α (· ⊆ ·)] (h : a ⊆ b) (h' : b ⊆ a) : b = a :=
  antisymm' h h'
#align superset_antisymm superset_antisymm
-/

alias subset_of_eq ← Eq.subset'

--TODO: Fix it and kill `eq.subset`
alias superset_of_eq ← Eq.superset

alias subset_trans ← HasSubset.Subset.trans

alias subset_antisymm ← HasSubset.Subset.antisymm

alias superset_antisymm ← HasSubset.Subset.antisymm'

#print subset_antisymm_iff /-
theorem subset_antisymm_iff [IsRefl α (· ⊆ ·)] [IsAntisymm α (· ⊆ ·)] : a = b ↔ a ⊆ b ∧ b ⊆ a :=
  ⟨fun h => ⟨h.subset', h.Superset⟩, fun h => h.1.antisymm h.2⟩
#align subset_antisymm_iff subset_antisymm_iff
-/

#print superset_antisymm_iff /-
theorem superset_antisymm_iff [IsRefl α (· ⊆ ·)] [IsAntisymm α (· ⊆ ·)] : a = b ↔ b ⊆ a ∧ a ⊆ b :=
  ⟨fun h => ⟨h.Superset, h.subset'⟩, fun h => h.1.antisymm' h.2⟩
#align superset_antisymm_iff superset_antisymm_iff
-/

end Subset

section Ssubset

variable [HasSSubset α]

#print ssubset_irrefl /-
theorem ssubset_irrefl [IsIrrefl α (· ⊂ ·)] (a : α) : ¬a ⊂ a :=
  irrefl _
#align ssubset_irrefl ssubset_irrefl
-/

#print ssubset_irrfl /-
theorem ssubset_irrfl [IsIrrefl α (· ⊂ ·)] {a : α} : ¬a ⊂ a :=
  irrefl _
#align ssubset_irrfl ssubset_irrfl
-/

#print ne_of_ssubset /-
theorem ne_of_ssubset [IsIrrefl α (· ⊂ ·)] {a b : α} : a ⊂ b → a ≠ b :=
  ne_of_irrefl
#align ne_of_ssubset ne_of_ssubset
-/

#print ne_of_ssuperset /-
theorem ne_of_ssuperset [IsIrrefl α (· ⊂ ·)] {a b : α} : a ⊂ b → b ≠ a :=
  ne_of_irrefl'
#align ne_of_ssuperset ne_of_ssuperset
-/

#print ssubset_trans /-
@[trans]
theorem ssubset_trans [IsTrans α (· ⊂ ·)] {a b c : α} : a ⊂ b → b ⊂ c → a ⊂ c :=
  trans
#align ssubset_trans ssubset_trans
-/

#print ssubset_asymm /-
theorem ssubset_asymm [IsAsymm α (· ⊂ ·)] {a b : α} (h : a ⊂ b) : ¬b ⊂ a :=
  asymm h
#align ssubset_asymm ssubset_asymm
-/

alias ssubset_irrfl ← HasSSubset.SSubset.false

alias ne_of_ssubset ← HasSSubset.SSubset.ne

alias ne_of_ssuperset ← HasSSubset.SSubset.ne'

alias ssubset_trans ← HasSSubset.SSubset.trans

alias ssubset_asymm ← HasSSubset.SSubset.asymm

end Ssubset

section SubsetSsubset

variable [HasSubset α] [HasSSubset α] [IsNonstrictStrictOrder α (· ⊆ ·) (· ⊂ ·)] {a b c : α}

#print ssubset_iff_subset_not_subset /-
theorem ssubset_iff_subset_not_subset : a ⊂ b ↔ a ⊆ b ∧ ¬b ⊆ a :=
  right_iff_left_not_left
#align ssubset_iff_subset_not_subset ssubset_iff_subset_not_subset
-/

#print subset_of_ssubset /-
theorem subset_of_ssubset (h : a ⊂ b) : a ⊆ b :=
  (ssubset_iff_subset_not_subset.1 h).1
#align subset_of_ssubset subset_of_ssubset
-/

#print not_subset_of_ssubset /-
theorem not_subset_of_ssubset (h : a ⊂ b) : ¬b ⊆ a :=
  (ssubset_iff_subset_not_subset.1 h).2
#align not_subset_of_ssubset not_subset_of_ssubset
-/

#print not_ssubset_of_subset /-
theorem not_ssubset_of_subset (h : a ⊆ b) : ¬b ⊂ a := fun h' => not_subset_of_ssubset h' h
#align not_ssubset_of_subset not_ssubset_of_subset
-/

#print ssubset_of_subset_not_subset /-
theorem ssubset_of_subset_not_subset (h₁ : a ⊆ b) (h₂ : ¬b ⊆ a) : a ⊂ b :=
  ssubset_iff_subset_not_subset.2 ⟨h₁, h₂⟩
#align ssubset_of_subset_not_subset ssubset_of_subset_not_subset
-/

alias subset_of_ssubset ← HasSSubset.SSubset.subset

alias not_subset_of_ssubset ← HasSSubset.SSubset.not_subset

alias not_ssubset_of_subset ← HasSubset.Subset.not_ssubset

alias ssubset_of_subset_not_subset ← HasSubset.Subset.ssubset_of_not_subset

#print ssubset_of_subset_of_ssubset /-
theorem ssubset_of_subset_of_ssubset [IsTrans α (· ⊆ ·)] (h₁ : a ⊆ b) (h₂ : b ⊂ c) : a ⊂ c :=
  (h₁.trans h₂.Subset).ssubset_of_not_subset fun h => h₂.not_subset <| h.trans h₁
#align ssubset_of_subset_of_ssubset ssubset_of_subset_of_ssubset
-/

#print ssubset_of_ssubset_of_subset /-
theorem ssubset_of_ssubset_of_subset [IsTrans α (· ⊆ ·)] (h₁ : a ⊂ b) (h₂ : b ⊆ c) : a ⊂ c :=
  (h₁.Subset.trans h₂).ssubset_of_not_subset fun h => h₁.not_subset <| h₂.trans h
#align ssubset_of_ssubset_of_subset ssubset_of_ssubset_of_subset
-/

#print ssubset_of_subset_of_ne /-
theorem ssubset_of_subset_of_ne [IsAntisymm α (· ⊆ ·)] (h₁ : a ⊆ b) (h₂ : a ≠ b) : a ⊂ b :=
  h₁.ssubset_of_not_subset <| mt h₁.antisymm h₂
#align ssubset_of_subset_of_ne ssubset_of_subset_of_ne
-/

#print ssubset_of_ne_of_subset /-
theorem ssubset_of_ne_of_subset [IsAntisymm α (· ⊆ ·)] (h₁ : a ≠ b) (h₂ : a ⊆ b) : a ⊂ b :=
  ssubset_of_subset_of_ne h₂ h₁
#align ssubset_of_ne_of_subset ssubset_of_ne_of_subset
-/

#print eq_or_ssubset_of_subset /-
theorem eq_or_ssubset_of_subset [IsAntisymm α (· ⊆ ·)] (h : a ⊆ b) : a = b ∨ a ⊂ b :=
  (em (b ⊆ a)).imp h.antisymm h.ssubset_of_not_subset
#align eq_or_ssubset_of_subset eq_or_ssubset_of_subset
-/

#print ssubset_or_eq_of_subset /-
theorem ssubset_or_eq_of_subset [IsAntisymm α (· ⊆ ·)] (h : a ⊆ b) : a ⊂ b ∨ a = b :=
  (eq_or_ssubset_of_subset h).swap
#align ssubset_or_eq_of_subset ssubset_or_eq_of_subset
-/

alias ssubset_of_subset_of_ssubset ← HasSubset.Subset.trans_ssubset

alias ssubset_of_ssubset_of_subset ← HasSSubset.SSubset.trans_subset

alias ssubset_of_subset_of_ne ← HasSubset.Subset.ssubset_of_ne

alias ssubset_of_ne_of_subset ← Ne.ssubset_of_subset

alias eq_or_ssubset_of_subset ← HasSubset.Subset.eq_or_ssubset

alias ssubset_or_eq_of_subset ← HasSubset.Subset.ssubset_or_eq

#print ssubset_iff_subset_ne /-
theorem ssubset_iff_subset_ne [IsAntisymm α (· ⊆ ·)] : a ⊂ b ↔ a ⊆ b ∧ a ≠ b :=
  ⟨fun h => ⟨h.Subset, h.Ne⟩, fun h => h.1.ssubset_of_ne h.2⟩
#align ssubset_iff_subset_ne ssubset_iff_subset_ne
-/

#print subset_iff_ssubset_or_eq /-
theorem subset_iff_ssubset_or_eq [IsRefl α (· ⊆ ·)] [IsAntisymm α (· ⊆ ·)] :
    a ⊆ b ↔ a ⊂ b ∨ a = b :=
  ⟨fun h => h.ssubset_or_eq, fun h => h.elim subset_of_ssubset subset_of_eq⟩
#align subset_iff_ssubset_or_eq subset_iff_ssubset_or_eq
-/

end SubsetSsubset

/-! ### Conversion of bundled order typeclasses to unbundled relation typeclasses -/


instance [Preorder α] : IsRefl α (· ≤ ·) :=
  ⟨le_refl⟩

instance [Preorder α] : IsRefl α (· ≥ ·) :=
  IsRefl.swap _

instance [Preorder α] : IsTrans α (· ≤ ·) :=
  ⟨@le_trans _ _⟩

instance [Preorder α] : IsTrans α (· ≥ ·) :=
  IsTrans.swap _

instance [Preorder α] : IsPreorder α (· ≤ ·) where

instance [Preorder α] : IsPreorder α (· ≥ ·) where

instance [Preorder α] : IsIrrefl α (· < ·) :=
  ⟨lt_irrefl⟩

instance [Preorder α] : IsIrrefl α (· > ·) :=
  IsIrrefl.swap _

instance [Preorder α] : IsTrans α (· < ·) :=
  ⟨@lt_trans _ _⟩

instance [Preorder α] : IsTrans α (· > ·) :=
  IsTrans.swap _

instance [Preorder α] : IsAsymm α (· < ·) :=
  ⟨@lt_asymm _ _⟩

instance [Preorder α] : IsAsymm α (· > ·) :=
  IsAsymm.swap _

instance [Preorder α] : IsAntisymm α (· < ·) :=
  IsAsymm.is_antisymm _

instance [Preorder α] : IsAntisymm α (· > ·) :=
  IsAsymm.is_antisymm _

instance [Preorder α] : IsStrictOrder α (· < ·) where

instance [Preorder α] : IsStrictOrder α (· > ·) where

instance [Preorder α] : IsNonstrictStrictOrder α (· ≤ ·) (· < ·) :=
  ⟨@lt_iff_le_not_le _ _⟩

instance [PartialOrder α] : IsAntisymm α (· ≤ ·) :=
  ⟨@le_antisymm _ _⟩

instance [PartialOrder α] : IsAntisymm α (· ≥ ·) :=
  IsAntisymm.swap _

instance [PartialOrder α] : IsPartialOrder α (· ≤ ·) where

instance [PartialOrder α] : IsPartialOrder α (· ≥ ·) where

instance [LinearOrder α] : IsTotal α (· ≤ ·) :=
  ⟨le_total⟩

instance [LinearOrder α] : IsTotal α (· ≥ ·) :=
  IsTotal.swap _

instance LinearOrder.is_total_preorder [LinearOrder α] : IsTotalPreorder α (· ≤ ·) := by
  infer_instance
#align linear_order.is_total_preorder LinearOrder.is_total_preorder

instance [LinearOrder α] : IsTotalPreorder α (· ≥ ·) where

instance [LinearOrder α] : IsLinearOrder α (· ≤ ·) where

instance [LinearOrder α] : IsLinearOrder α (· ≥ ·) where

instance [LinearOrder α] : IsTrichotomous α (· < ·) :=
  ⟨lt_trichotomy⟩

instance [LinearOrder α] : IsTrichotomous α (· > ·) :=
  IsTrichotomous.swap _

instance [LinearOrder α] : IsTrichotomous α (· ≤ ·) :=
  IsTotal.is_trichotomous _

instance [LinearOrder α] : IsTrichotomous α (· ≥ ·) :=
  IsTotal.is_trichotomous _

instance [LinearOrder α] : IsStrictTotalOrder α (· < ·) where

instance [LinearOrder α] : IsOrderConnected α (· < ·) := by infer_instance

instance [LinearOrder α] : IsIncompTrans α (· < ·) := by infer_instance

instance [LinearOrder α] : IsStrictWeakOrder α (· < ·) := by infer_instance

#print transitive_le /-
theorem transitive_le [Preorder α] : Transitive (@LE.le α _) :=
  transitive_of_trans _
#align transitive_le transitive_le
-/

#print transitive_lt /-
theorem transitive_lt [Preorder α] : Transitive (@LT.lt α _) :=
  transitive_of_trans _
#align transitive_lt transitive_lt
-/

#print transitive_ge /-
theorem transitive_ge [Preorder α] : Transitive (@GE.ge α _) :=
  transitive_of_trans _
#align transitive_ge transitive_ge
-/

#print transitive_gt /-
theorem transitive_gt [Preorder α] : Transitive (@GT.gt α _) :=
  transitive_of_trans _
#align transitive_gt transitive_gt
-/

instance OrderDual.is_total_le [LE α] [IsTotal α (· ≤ ·)] : IsTotal αᵒᵈ (· ≤ ·) :=
  @IsTotal.swap α _ _
#align order_dual.is_total_le OrderDual.is_total_le

instance : WellFoundedLt ℕ :=
  ⟨Nat.lt_wfRel⟩

#print Nat.lt.isWellOrder /-
instance Nat.lt.isWellOrder : IsWellOrder ℕ (· < ·) where
#align nat.lt.is_well_order Nat.lt.isWellOrder
-/

instance [LinearOrder α] [h : IsWellOrder α (· < ·)] : IsWellOrder αᵒᵈ (· > ·) :=
  h

instance [LinearOrder α] [h : IsWellOrder α (· > ·)] : IsWellOrder αᵒᵈ (· < ·) :=
  h

