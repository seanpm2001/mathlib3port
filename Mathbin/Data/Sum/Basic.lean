/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Yury G. Kudryashov

! This file was ported from Lean 3 source module data.sum.basic
! leanprover-community/mathlib commit bd9851ca476957ea4549eb19b40e7b5ade9428cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Function.Basic
import Mathbin.Tactic.Basic

/-!
# Disjoint union of types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves basic results about the sum type `α ⊕ β`.

`α ⊕ β` is the type made of a copy of `α` and a copy of `β`. It is also called *disjoint union*.

## Main declarations

* `sum.get_left`: Retrieves the left content of `x : α ⊕ β` or returns `none` if it's coming from
  the right.
* `sum.get_right`: Retrieves the right content of `x : α ⊕ β` or returns `none` if it's coming from
  the left.
* `sum.is_left`: Returns whether `x : α ⊕ β` comes from the left component or not.
* `sum.is_right`: Returns whether `x : α ⊕ β` comes from the right component or not.
* `sum.map`: Maps `α ⊕ β` to `γ ⊕ δ` component-wise.
* `sum.elim`: Nondependent eliminator/induction principle for `α ⊕ β`.
* `sum.swap`: Maps `α ⊕ β` to `β ⊕ α` by swapping components.
* `sum.lex`: Lexicographic order on `α ⊕ β` induced by a relation on `α` and a relation on `β`.

## Notes

The definition of `sum` takes values in `Type*`. This effectively forbids `Prop`- valued sum types.
To this effect, we have `psum`, which takes value in `Sort*` and carries a more complicated
universe signature in consequence. The `Prop` version is `or`.
-/


universe u v w x

variable {α : Type u} {α' : Type w} {β : Type v} {β' : Type x} {γ δ : Type _}

namespace Sum

deriving instance DecidableEq for Sum

#print Sum.forall /-
@[simp]
theorem forall {p : Sum α β → Prop} : (∀ x, p x) ↔ (∀ a, p (inl a)) ∧ ∀ b, p (inr b) :=
  ⟨fun h => ⟨fun a => h _, fun b => h _⟩, fun ⟨h₁, h₂⟩ => Sum.rec h₁ h₂⟩
#align sum.forall Sum.forall
-/

#print Sum.exists /-
@[simp]
theorem exists {p : Sum α β → Prop} : (∃ x, p x) ↔ (∃ a, p (inl a)) ∨ ∃ b, p (inr b) :=
  ⟨fun h =>
    match h with
    | ⟨inl a, h⟩ => Or.inl ⟨a, h⟩
    | ⟨inr b, h⟩ => Or.inr ⟨b, h⟩,
    fun h =>
    match h with
    | Or.inl ⟨a, h⟩ => ⟨inl a, h⟩
    | Or.inr ⟨b, h⟩ => ⟨inr b, h⟩⟩
#align sum.exists Sum.exists
-/

#print Sum.inl_injective /-
theorem inl_injective : Function.Injective (inl : α → Sum α β) := fun x y => inl.inj
#align sum.inl_injective Sum.inl_injective
-/

#print Sum.inr_injective /-
theorem inr_injective : Function.Injective (inr : β → Sum α β) := fun x y => inr.inj
#align sum.inr_injective Sum.inr_injective
-/

section get

#print Sum.getLeft /-
/-- Check if a sum is `inl` and if so, retrieve its contents. -/
@[simp]
def getLeft : Sum α β → Option α
  | inl a => some a
  | inr _ => none
#align sum.get_left Sum.getLeft
-/

#print Sum.getRight /-
/-- Check if a sum is `inr` and if so, retrieve its contents. -/
@[simp]
def getRight : Sum α β → Option β
  | inr b => some b
  | inl _ => none
#align sum.get_right Sum.getRight
-/

#print Sum.isLeft /-
/-- Check if a sum is `inl`. -/
@[simp]
def isLeft : Sum α β → Bool
  | inl _ => true
  | inr _ => false
#align sum.is_left Sum.isLeft
-/

#print Sum.isRight /-
/-- Check if a sum is `inr`. -/
@[simp]
def isRight : Sum α β → Bool
  | inl _ => false
  | inr _ => true
#align sum.is_right Sum.isRight
-/

variable {x y : Sum α β}

#print Sum.getLeft_eq_none_iff /-
@[simp]
theorem getLeft_eq_none_iff : x.getLeft = none ↔ x.isRight := by
  cases x <;>
    simp only [get_left, is_right, Bool.coe_sort_true, Bool.coe_sort_false, eq_self_iff_true]
#align sum.get_left_eq_none_iff Sum.getLeft_eq_none_iff
-/

#print Sum.getRight_eq_none_iff /-
@[simp]
theorem getRight_eq_none_iff : x.getRight = none ↔ x.isLeft := by
  cases x <;>
    simp only [get_right, is_left, Bool.coe_sort_true, Bool.coe_sort_false, eq_self_iff_true]
#align sum.get_right_eq_none_iff Sum.getRight_eq_none_iff
-/

#print Sum.getLeft_eq_some_iff /-
@[simp]
theorem getLeft_eq_some_iff {a} : x.getLeft = some a ↔ x = inl a := by
  cases x <;> simp only [get_left]
#align sum.get_left_eq_some_iff Sum.getLeft_eq_some_iff
-/

#print Sum.getRight_eq_some_iff /-
@[simp]
theorem getRight_eq_some_iff {b} : x.getRight = some b ↔ x = inr b := by
  cases x <;> simp only [get_right]
#align sum.get_right_eq_some_iff Sum.getRight_eq_some_iff
-/

#print Sum.not_isLeft /-
@[simp]
theorem not_isLeft (x : Sum α β) : not x.isLeft = x.isRight := by cases x <;> rfl
#align sum.bnot_is_left Sum.not_isLeft
-/

#print Sum.isLeft_eq_false /-
@[simp]
theorem isLeft_eq_false : x.isLeft = false ↔ x.isRight := by cases x <;> simp
#align sum.is_left_eq_ff Sum.isLeft_eq_false
-/

#print Sum.Not_isLeft /-
theorem Not_isLeft : ¬x.isLeft ↔ x.isRight := by simp
#align sum.not_is_left Sum.Not_isLeft
-/

#print Sum.not_isRight /-
@[simp]
theorem not_isRight (x : Sum α β) : not x.isRight = x.isLeft := by cases x <;> rfl
#align sum.bnot_is_right Sum.not_isRight
-/

#print Sum.isRight_eq_false /-
@[simp]
theorem isRight_eq_false : x.isRight = false ↔ x.isLeft := by cases x <;> simp
#align sum.is_right_eq_ff Sum.isRight_eq_false
-/

#print Sum.Not_isRight /-
theorem Not_isRight : ¬x.isRight ↔ x.isLeft := by simp
#align sum.not_is_right Sum.Not_isRight
-/

#print Sum.isLeft_iff /-
theorem isLeft_iff : x.isLeft ↔ ∃ y, x = Sum.inl y := by cases x <;> simp
#align sum.is_left_iff Sum.isLeft_iff
-/

#print Sum.isRight_iff /-
theorem isRight_iff : x.isRight ↔ ∃ y, x = Sum.inr y := by cases x <;> simp
#align sum.is_right_iff Sum.isRight_iff
-/

end get

#print Sum.inl.inj_iff /-
theorem inl.inj_iff {a b} : (inl a : Sum α β) = inl b ↔ a = b :=
  ⟨inl.inj, congr_arg _⟩
#align sum.inl.inj_iff Sum.inl.inj_iff
-/

#print Sum.inr.inj_iff /-
theorem inr.inj_iff {a b} : (inr a : Sum α β) = inr b ↔ a = b :=
  ⟨inr.inj, congr_arg _⟩
#align sum.inr.inj_iff Sum.inr.inj_iff
-/

#print Sum.inl_ne_inr /-
theorem inl_ne_inr {a : α} {b : β} : inl a ≠ inr b :=
  fun.
#align sum.inl_ne_inr Sum.inl_ne_inr
-/

#print Sum.inr_ne_inl /-
theorem inr_ne_inl {a : α} {b : β} : inr b ≠ inl a :=
  fun.
#align sum.inr_ne_inl Sum.inr_ne_inl
-/

#print Sum.elim /-
/-- Define a function on `α ⊕ β` by giving separate definitions on `α` and `β`. -/
protected def elim {α β γ : Sort _} (f : α → γ) (g : β → γ) : Sum α β → γ := fun x =>
  Sum.recOn x f g
#align sum.elim Sum.elim
-/

#print Sum.elim_inl /-
@[simp]
theorem elim_inl {α β γ : Sort _} (f : α → γ) (g : β → γ) (x : α) : Sum.elim f g (inl x) = f x :=
  rfl
#align sum.elim_inl Sum.elim_inl
-/

#print Sum.elim_inr /-
@[simp]
theorem elim_inr {α β γ : Sort _} (f : α → γ) (g : β → γ) (x : β) : Sum.elim f g (inr x) = g x :=
  rfl
#align sum.elim_inr Sum.elim_inr
-/

#print Sum.elim_comp_inl /-
@[simp]
theorem elim_comp_inl {α β γ : Sort _} (f : α → γ) (g : β → γ) : Sum.elim f g ∘ inl = f :=
  rfl
#align sum.elim_comp_inl Sum.elim_comp_inl
-/

#print Sum.elim_comp_inr /-
@[simp]
theorem elim_comp_inr {α β γ : Sort _} (f : α → γ) (g : β → γ) : Sum.elim f g ∘ inr = g :=
  rfl
#align sum.elim_comp_inr Sum.elim_comp_inr
-/

#print Sum.elim_inl_inr /-
@[simp]
theorem elim_inl_inr {α β : Sort _} : @Sum.elim α β _ inl inr = id :=
  funext fun x => Sum.casesOn x (fun _ => rfl) fun _ => rfl
#align sum.elim_inl_inr Sum.elim_inl_inr
-/

#print Sum.comp_elim /-
theorem comp_elim {α β γ δ : Sort _} (f : γ → δ) (g : α → γ) (h : β → γ) :
    f ∘ Sum.elim g h = Sum.elim (f ∘ g) (f ∘ h) :=
  funext fun x => Sum.casesOn x (fun _ => rfl) fun _ => rfl
#align sum.comp_elim Sum.comp_elim
-/

#print Sum.elim_comp_inl_inr /-
@[simp]
theorem elim_comp_inl_inr {α β γ : Sort _} (f : Sum α β → γ) : Sum.elim (f ∘ inl) (f ∘ inr) = f :=
  funext fun x => Sum.casesOn x (fun _ => rfl) fun _ => rfl
#align sum.elim_comp_inl_inr Sum.elim_comp_inl_inr
-/

#print Sum.map /-
/-- Map `α ⊕ β` to `α' ⊕ β'` sending `α` to `α'` and `β` to `β'`. -/
protected def map (f : α → α') (g : β → β') : Sum α β → Sum α' β' :=
  Sum.elim (inl ∘ f) (inr ∘ g)
#align sum.map Sum.map
-/

#print Sum.map_inl /-
@[simp]
theorem map_inl (f : α → α') (g : β → β') (x : α) : (inl x).map f g = inl (f x) :=
  rfl
#align sum.map_inl Sum.map_inl
-/

#print Sum.map_inr /-
@[simp]
theorem map_inr (f : α → α') (g : β → β') (x : β) : (inr x).map f g = inr (g x) :=
  rfl
#align sum.map_inr Sum.map_inr
-/

#print Sum.map_map /-
@[simp]
theorem map_map {α'' β''} (f' : α' → α'') (g' : β' → β'') (f : α → α') (g : β → β') :
    ∀ x : Sum α β, (x.map f g).map f' g' = x.map (f' ∘ f) (g' ∘ g)
  | inl a => rfl
  | inr b => rfl
#align sum.map_map Sum.map_map
-/

#print Sum.map_comp_map /-
@[simp]
theorem map_comp_map {α'' β''} (f' : α' → α'') (g' : β' → β'') (f : α → α') (g : β → β') :
    Sum.map f' g' ∘ Sum.map f g = Sum.map (f' ∘ f) (g' ∘ g) :=
  funext <| map_map f' g' f g
#align sum.map_comp_map Sum.map_comp_map
-/

#print Sum.map_id_id /-
@[simp]
theorem map_id_id (α β) : Sum.map (@id α) (@id β) = id :=
  funext fun x => Sum.recOn x (fun _ => rfl) fun _ => rfl
#align sum.map_id_id Sum.map_id_id
-/

#print Sum.elim_map /-
theorem elim_map {α β γ δ ε : Sort _} {f₁ : α → β} {f₂ : β → ε} {g₁ : γ → δ} {g₂ : δ → ε} {x} :
    Sum.elim f₂ g₂ (Sum.map f₁ g₁ x) = Sum.elim (f₂ ∘ f₁) (g₂ ∘ g₁) x := by cases x <;> rfl
#align sum.elim_map Sum.elim_map
-/

#print Sum.elim_comp_map /-
theorem elim_comp_map {α β γ δ ε : Sort _} {f₁ : α → β} {f₂ : β → ε} {g₁ : γ → δ} {g₂ : δ → ε} :
    Sum.elim f₂ g₂ ∘ Sum.map f₁ g₁ = Sum.elim (f₂ ∘ f₁) (g₂ ∘ g₁) :=
  funext fun _ => elim_map
#align sum.elim_comp_map Sum.elim_comp_map
-/

#print Sum.isLeft_map /-
@[simp]
theorem isLeft_map (f : α → β) (g : γ → δ) (x : Sum α γ) : isLeft (x.map f g) = isLeft x := by
  cases x <;> rfl
#align sum.is_left_map Sum.isLeft_map
-/

#print Sum.isRight_map /-
@[simp]
theorem isRight_map (f : α → β) (g : γ → δ) (x : Sum α γ) : isRight (x.map f g) = isRight x := by
  cases x <;> rfl
#align sum.is_right_map Sum.isRight_map
-/

#print Sum.getLeft_map /-
@[simp]
theorem getLeft_map (f : α → β) (g : γ → δ) (x : Sum α γ) : (x.map f g).getLeft = x.getLeft.map f :=
  by cases x <;> rfl
#align sum.get_left_map Sum.getLeft_map
-/

#print Sum.getRight_map /-
@[simp]
theorem getRight_map (f : α → β) (g : γ → δ) (x : Sum α γ) :
    (x.map f g).getRight = x.getRight.map g := by cases x <;> rfl
#align sum.get_right_map Sum.getRight_map
-/

open Function (update update_eq_iff update_comp_eq_of_injective update_comp_eq_of_forall_ne)

#print Sum.update_elim_inl /-
@[simp]
theorem update_elim_inl [DecidableEq α] [DecidableEq (Sum α β)] {f : α → γ} {g : β → γ} {i : α}
    {x : γ} : update (Sum.elim f g) (inl i) x = Sum.elim (update f i x) g :=
  update_eq_iff.2 ⟨by simp, by simp (config := { contextual := true })⟩
#align sum.update_elim_inl Sum.update_elim_inl
-/

#print Sum.update_elim_inr /-
@[simp]
theorem update_elim_inr [DecidableEq β] [DecidableEq (Sum α β)] {f : α → γ} {g : β → γ} {i : β}
    {x : γ} : update (Sum.elim f g) (inr i) x = Sum.elim f (update g i x) :=
  update_eq_iff.2 ⟨by simp, by simp (config := { contextual := true })⟩
#align sum.update_elim_inr Sum.update_elim_inr
-/

#print Sum.update_inl_comp_inl /-
@[simp]
theorem update_inl_comp_inl [DecidableEq α] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α}
    {x : γ} : update f (inl i) x ∘ inl = update (f ∘ inl) i x :=
  update_comp_eq_of_injective _ inl_injective _ _
#align sum.update_inl_comp_inl Sum.update_inl_comp_inl
-/

#print Sum.update_inl_apply_inl /-
@[simp]
theorem update_inl_apply_inl [DecidableEq α] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i j : α}
    {x : γ} : update f (inl i) x (inl j) = update (f ∘ inl) i x j := by rw [← update_inl_comp_inl]
#align sum.update_inl_apply_inl Sum.update_inl_apply_inl
-/

#print Sum.update_inl_comp_inr /-
@[simp]
theorem update_inl_comp_inr [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α} {x : γ} :
    update f (inl i) x ∘ inr = f ∘ inr :=
  update_comp_eq_of_forall_ne _ _ fun _ => inr_ne_inl
#align sum.update_inl_comp_inr Sum.update_inl_comp_inr
-/

#print Sum.update_inl_apply_inr /-
@[simp]
theorem update_inl_apply_inr [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α} {j : β} {x : γ} :
    update f (inl i) x (inr j) = f (inr j) :=
  Function.update_noteq inr_ne_inl _ _
#align sum.update_inl_apply_inr Sum.update_inl_apply_inr
-/

#print Sum.update_inr_comp_inl /-
@[simp]
theorem update_inr_comp_inl [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : β} {x : γ} :
    update f (inr i) x ∘ inl = f ∘ inl :=
  update_comp_eq_of_forall_ne _ _ fun _ => inl_ne_inr
#align sum.update_inr_comp_inl Sum.update_inr_comp_inl
-/

#print Sum.update_inr_apply_inl /-
@[simp]
theorem update_inr_apply_inl [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : α} {j : β} {x : γ} :
    update f (inr j) x (inl i) = f (inl i) :=
  Function.update_noteq inl_ne_inr _ _
#align sum.update_inr_apply_inl Sum.update_inr_apply_inl
-/

#print Sum.update_inr_comp_inr /-
@[simp]
theorem update_inr_comp_inr [DecidableEq β] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i : β}
    {x : γ} : update f (inr i) x ∘ inr = update (f ∘ inr) i x :=
  update_comp_eq_of_injective _ inr_injective _ _
#align sum.update_inr_comp_inr Sum.update_inr_comp_inr
-/

#print Sum.update_inr_apply_inr /-
@[simp]
theorem update_inr_apply_inr [DecidableEq β] [DecidableEq (Sum α β)] {f : Sum α β → γ} {i j : β}
    {x : γ} : update f (inr i) x (inr j) = update (f ∘ inr) i x j := by rw [← update_inr_comp_inr]
#align sum.update_inr_apply_inr Sum.update_inr_apply_inr
-/

#print Sum.swap /-
/-- Swap the factors of a sum type -/
def swap : Sum α β → Sum β α :=
  Sum.elim inr inl
#align sum.swap Sum.swap
-/

#print Sum.swap_inl /-
@[simp]
theorem swap_inl (x : α) : swap (inl x : Sum α β) = inr x :=
  rfl
#align sum.swap_inl Sum.swap_inl
-/

#print Sum.swap_inr /-
@[simp]
theorem swap_inr (x : β) : swap (inr x : Sum α β) = inl x :=
  rfl
#align sum.swap_inr Sum.swap_inr
-/

#print Sum.swap_swap /-
@[simp]
theorem swap_swap (x : Sum α β) : swap (swap x) = x := by cases x <;> rfl
#align sum.swap_swap Sum.swap_swap
-/

#print Sum.swap_swap_eq /-
@[simp]
theorem swap_swap_eq : swap ∘ swap = @id (Sum α β) :=
  funext <| swap_swap
#align sum.swap_swap_eq Sum.swap_swap_eq
-/

#print Sum.swap_leftInverse /-
@[simp]
theorem swap_leftInverse : Function.LeftInverse (@swap α β) swap :=
  swap_swap
#align sum.swap_left_inverse Sum.swap_leftInverse
-/

#print Sum.swap_rightInverse /-
@[simp]
theorem swap_rightInverse : Function.RightInverse (@swap α β) swap :=
  swap_swap
#align sum.swap_right_inverse Sum.swap_rightInverse
-/

#print Sum.isLeft_swap /-
@[simp]
theorem isLeft_swap (x : Sum α β) : x.symm.isLeft = x.isRight := by cases x <;> rfl
#align sum.is_left_swap Sum.isLeft_swap
-/

#print Sum.isRight_swap /-
@[simp]
theorem isRight_swap (x : Sum α β) : x.symm.isRight = x.isLeft := by cases x <;> rfl
#align sum.is_right_swap Sum.isRight_swap
-/

#print Sum.getLeft_swap /-
@[simp]
theorem getLeft_swap (x : Sum α β) : x.symm.getLeft = x.getRight := by cases x <;> rfl
#align sum.get_left_swap Sum.getLeft_swap
-/

#print Sum.getRight_swap /-
@[simp]
theorem getRight_swap (x : Sum α β) : x.symm.getRight = x.getLeft := by cases x <;> rfl
#align sum.get_right_swap Sum.getRight_swap
-/

section LiftRel

#print Sum.LiftRel /-
/-- Lifts pointwise two relations between `α` and `γ` and between `β` and `δ` to a relation between
`α ⊕ β` and `γ ⊕ δ`. -/
inductive LiftRel (r : α → γ → Prop) (s : β → δ → Prop) : Sum α β → Sum γ δ → Prop
  | inl {a c} : r a c → lift_rel (inl a) (inl c)
  | inr {b d} : s b d → lift_rel (inr b) (inr d)
#align sum.lift_rel Sum.LiftRel
-/

attribute [protected] lift_rel.inl lift_rel.inr

variable {r r₁ r₂ : α → γ → Prop} {s s₁ s₂ : β → δ → Prop} {a : α} {b : β} {c : γ} {d : δ}
  {x : Sum α β} {y : Sum γ δ}

#print Sum.liftRel_inl_inl /-
@[simp]
theorem liftRel_inl_inl : LiftRel r s (inl a) (inl c) ↔ r a c :=
  ⟨fun h => by cases h; assumption, LiftRel.inl⟩
#align sum.lift_rel_inl_inl Sum.liftRel_inl_inl
-/

#print Sum.not_liftRel_inl_inr /-
@[simp]
theorem not_liftRel_inl_inr : ¬LiftRel r s (inl a) (inr d) :=
  fun.
#align sum.not_lift_rel_inl_inr Sum.not_liftRel_inl_inr
-/

#print Sum.not_liftRel_inr_inl /-
@[simp]
theorem not_liftRel_inr_inl : ¬LiftRel r s (inr b) (inl c) :=
  fun.
#align sum.not_lift_rel_inr_inl Sum.not_liftRel_inr_inl
-/

#print Sum.liftRel_inr_inr /-
@[simp]
theorem liftRel_inr_inr : LiftRel r s (inr b) (inr d) ↔ s b d :=
  ⟨fun h => by cases h; assumption, LiftRel.inr⟩
#align sum.lift_rel_inr_inr Sum.liftRel_inr_inr
-/

instance [∀ a c, Decidable (r a c)] [∀ b d, Decidable (s b d)] :
    ∀ (ab : Sum α β) (cd : Sum γ δ), Decidable (LiftRel r s ab cd)
  | inl a, inl c => decidable_of_iff' _ liftRel_inl_inl
  | inl a, inr d => Decidable.isFalse not_liftRel_inl_inr
  | inr b, inl c => Decidable.isFalse not_liftRel_inr_inl
  | inr b, inr d => decidable_of_iff' _ liftRel_inr_inr

#print Sum.LiftRel.mono /-
theorem LiftRel.mono (hr : ∀ a b, r₁ a b → r₂ a b) (hs : ∀ a b, s₁ a b → s₂ a b)
    (h : LiftRel r₁ s₁ x y) : LiftRel r₂ s₂ x y := by cases h;
  exacts [lift_rel.inl (hr _ _ ‹_›), lift_rel.inr (hs _ _ ‹_›)]
#align sum.lift_rel.mono Sum.LiftRel.mono
-/

#print Sum.LiftRel.mono_left /-
theorem LiftRel.mono_left (hr : ∀ a b, r₁ a b → r₂ a b) (h : LiftRel r₁ s x y) : LiftRel r₂ s x y :=
  h.mono hr fun _ _ => id
#align sum.lift_rel.mono_left Sum.LiftRel.mono_left
-/

#print Sum.LiftRel.mono_right /-
theorem LiftRel.mono_right (hs : ∀ a b, s₁ a b → s₂ a b) (h : LiftRel r s₁ x y) :
    LiftRel r s₂ x y :=
  h.mono (fun _ _ => id) hs
#align sum.lift_rel.mono_right Sum.LiftRel.mono_right
-/

#print Sum.LiftRel.swap /-
protected theorem LiftRel.swap (h : LiftRel r s x y) : LiftRel s r x.symm y.symm := by cases h;
  exacts [lift_rel.inr ‹_›, lift_rel.inl ‹_›]
#align sum.lift_rel.swap Sum.LiftRel.swap
-/

#print Sum.liftRel_swap_iff /-
@[simp]
theorem liftRel_swap_iff : LiftRel s r x.symm y.symm ↔ LiftRel r s x y :=
  ⟨fun h => by rw [← swap_swap x, ← swap_swap y]; exact h.swap, LiftRel.swap⟩
#align sum.lift_rel_swap_iff Sum.liftRel_swap_iff
-/

end LiftRel

section Lex

#print Sum.Lex /-
/-- Lexicographic order for sum. Sort all the `inl a` before the `inr b`, otherwise use the
respective order on `α` or `β`. -/
inductive Lex (r : α → α → Prop) (s : β → β → Prop) : Sum α β → Sum α β → Prop
  | inl {a₁ a₂} (h : r a₁ a₂) : Lex (inl a₁) (inl a₂)
  | inr {b₁ b₂} (h : s b₁ b₂) : Lex (inr b₁) (inr b₂)
  | sep (a b) : Lex (inl a) (inr b)
#align sum.lex Sum.Lex
-/

attribute [protected] Sum.Lex.inl Sum.Lex.inr

attribute [simp] lex.sep

variable {r r₁ r₂ : α → α → Prop} {s s₁ s₂ : β → β → Prop} {a a₁ a₂ : α} {b b₁ b₂ : β}
  {x y : Sum α β}

#print Sum.lex_inl_inl /-
@[simp]
theorem lex_inl_inl : Lex r s (inl a₁) (inl a₂) ↔ r a₁ a₂ :=
  ⟨fun h => by cases h; assumption, Lex.inl⟩
#align sum.lex_inl_inl Sum.lex_inl_inl
-/

#print Sum.lex_inr_inr /-
@[simp]
theorem lex_inr_inr : Lex r s (inr b₁) (inr b₂) ↔ s b₁ b₂ :=
  ⟨fun h => by cases h; assumption, Lex.inr⟩
#align sum.lex_inr_inr Sum.lex_inr_inr
-/

#print Sum.lex_inr_inl /-
@[simp]
theorem lex_inr_inl : ¬Lex r s (inr b) (inl a) :=
  fun.
#align sum.lex_inr_inl Sum.lex_inr_inl
-/

instance [DecidableRel r] [DecidableRel s] : DecidableRel (Lex r s)
  | inl a, inl c => decidable_of_iff' _ lex_inl_inl
  | inl a, inr d => Decidable.isTrue (Lex.sep _ _)
  | inr b, inl c => Decidable.isFalse lex_inr_inl
  | inr b, inr d => decidable_of_iff' _ lex_inr_inr

#print Sum.LiftRel.lex /-
protected theorem LiftRel.lex {a b : Sum α β} (h : LiftRel r s a b) : Lex r s a b := by cases h;
  exacts [lex.inl ‹_›, lex.inr ‹_›]
#align sum.lift_rel.lex Sum.LiftRel.lex
-/

#print Sum.liftRel_subrelation_lex /-
theorem liftRel_subrelation_lex : Subrelation (LiftRel r s) (Lex r s) := fun a b => LiftRel.lex
#align sum.lift_rel_subrelation_lex Sum.liftRel_subrelation_lex
-/

#print Sum.Lex.mono /-
theorem Lex.mono (hr : ∀ a b, r₁ a b → r₂ a b) (hs : ∀ a b, s₁ a b → s₂ a b) (h : Lex r₁ s₁ x y) :
    Lex r₂ s₂ x y := by cases h; exacts [lex.inl (hr _ _ ‹_›), lex.inr (hs _ _ ‹_›), lex.sep _ _]
#align sum.lex.mono Sum.Lex.mono
-/

#print Sum.Lex.mono_left /-
theorem Lex.mono_left (hr : ∀ a b, r₁ a b → r₂ a b) (h : Lex r₁ s x y) : Lex r₂ s x y :=
  h.mono hr fun _ _ => id
#align sum.lex.mono_left Sum.Lex.mono_left
-/

#print Sum.Lex.mono_right /-
theorem Lex.mono_right (hs : ∀ a b, s₁ a b → s₂ a b) (h : Lex r s₁ x y) : Lex r s₂ x y :=
  h.mono (fun _ _ => id) hs
#align sum.lex.mono_right Sum.Lex.mono_right
-/

#print Sum.lex_acc_inl /-
theorem lex_acc_inl {a} (aca : Acc r a) : Acc (Lex r s) (inl a) :=
  by
  induction' aca with a H IH
  constructor; intro y h
  cases' h with a' _ h'
  exact IH _ h'
#align sum.lex_acc_inl Sum.lex_acc_inl
-/

#print Sum.lex_acc_inr /-
theorem lex_acc_inr (aca : ∀ a, Acc (Lex r s) (inl a)) {b} (acb : Acc s b) :
    Acc (Lex r s) (inr b) := by
  induction' acb with b H IH
  constructor; intro y h
  cases' h with _ _ _ b' _ h' a
  · exact IH _ h'
  · exact aca _
#align sum.lex_acc_inr Sum.lex_acc_inr
-/

#print Sum.lex_wf /-
theorem lex_wf (ha : WellFounded r) (hb : WellFounded s) : WellFounded (Lex r s) :=
  have aca : ∀ a, Acc (Lex r s) (inl a) := fun a => lex_acc_inl (ha.apply a)
  ⟨fun x => Sum.recOn x aca fun b => lex_acc_inr aca (hb.apply b)⟩
#align sum.lex_wf Sum.lex_wf
-/

end Lex

end Sum

open Sum

namespace Function

#print Function.Injective.sum_elim /-
theorem Injective.sum_elim {f : α → γ} {g : β → γ} (hf : Injective f) (hg : Injective g)
    (hfg : ∀ a b, f a ≠ g b) : Injective (Sum.elim f g)
  | inl x, inl y, h => congr_arg inl <| hf h
  | inl x, inr y, h => (hfg x y h).elim
  | inr x, inl y, h => (hfg y x h.symm).elim
  | inr x, inr y, h => congr_arg inr <| hg h
#align function.injective.sum_elim Function.Injective.sum_elim
-/

#print Function.Injective.sum_map /-
theorem Injective.sum_map {f : α → β} {g : α' → β'} (hf : Injective f) (hg : Injective g) :
    Injective (Sum.map f g)
  | inl x, inl y, h => congr_arg inl <| hf <| inl.inj h
  | inr x, inr y, h => congr_arg inr <| hg <| inr.inj h
#align function.injective.sum_map Function.Injective.sum_map
-/

#print Function.Surjective.sum_map /-
theorem Surjective.sum_map {f : α → β} {g : α' → β'} (hf : Surjective f) (hg : Surjective g) :
    Surjective (Sum.map f g)
  | inl y =>
    let ⟨x, hx⟩ := hf y
    ⟨inl x, congr_arg inl hx⟩
  | inr y =>
    let ⟨x, hx⟩ := hg y
    ⟨inr x, congr_arg inr hx⟩
#align function.surjective.sum_map Function.Surjective.sum_map
-/

#print Function.Bijective.sum_map /-
theorem Bijective.sum_map {f : α → β} {g : α' → β'} (hf : Bijective f) (hg : Bijective g) :
    Bijective (Sum.map f g) :=
  ⟨hf.Injective.sum_map hg.Injective, hf.Surjective.sum_map hg.Surjective⟩
#align function.bijective.sum_map Function.Bijective.sum_map
-/

end Function

namespace Sum

open Function

#print Sum.map_injective /-
@[simp]
theorem map_injective {f : α → γ} {g : β → δ} :
    Injective (Sum.map f g) ↔ Injective f ∧ Injective g :=
  ⟨fun h =>
    ⟨fun a₁ a₂ ha => inl_injective <| @h (inl a₁) (inl a₂) (congr_arg inl ha : _), fun b₁ b₂ hb =>
      inr_injective <| @h (inr b₁) (inr b₂) (congr_arg inr hb : _)⟩,
    fun h => h.1.sum_map h.2⟩
#align sum.map_injective Sum.map_injective
-/

#print Sum.map_surjective /-
@[simp]
theorem map_surjective {f : α → γ} {g : β → δ} :
    Surjective (Sum.map f g) ↔ Surjective f ∧ Surjective g :=
  ⟨fun h =>
    ⟨fun c => by
      obtain ⟨a | b, h⟩ := h (inl c)
      · exact ⟨a, inl_injective h⟩
      · cases h, fun d => by
      obtain ⟨a | b, h⟩ := h (inr d)
      · cases h
      · exact ⟨b, inr_injective h⟩⟩,
    fun h => h.1.sum_map h.2⟩
#align sum.map_surjective Sum.map_surjective
-/

#print Sum.map_bijective /-
@[simp]
theorem map_bijective {f : α → γ} {g : β → δ} :
    Bijective (Sum.map f g) ↔ Bijective f ∧ Bijective g :=
  (map_injective.And map_surjective).trans <| and_and_and_comm _ _ _ _
#align sum.map_bijective Sum.map_bijective
-/

#print Sum.elim_const_const /-
theorem elim_const_const (c : γ) : Sum.elim (const _ c : α → γ) (const _ c : β → γ) = const _ c :=
  by ext x; cases x <;> rfl
#align sum.elim_const_const Sum.elim_const_const
-/

#print Sum.elim_lam_const_lam_const /-
@[simp]
theorem elim_lam_const_lam_const (c : γ) :
    (Sum.elim (fun _ : α => c) fun _ : β => c) = fun _ => c :=
  Sum.elim_const_const c
#align sum.elim_lam_const_lam_const Sum.elim_lam_const_lam_const
-/

#print Sum.elim_update_left /-
theorem elim_update_left [DecidableEq α] [DecidableEq β] (f : α → γ) (g : β → γ) (i : α) (c : γ) :
    Sum.elim (Function.update f i c) g = Function.update (Sum.elim f g) (inl i) c :=
  by
  ext x; cases x
  · by_cases h : x = i
    · subst h; simp
    · simp [h]
  · simp
#align sum.elim_update_left Sum.elim_update_left
-/

#print Sum.elim_update_right /-
theorem elim_update_right [DecidableEq α] [DecidableEq β] (f : α → γ) (g : β → γ) (i : β) (c : γ) :
    Sum.elim f (Function.update g i c) = Function.update (Sum.elim f g) (inr i) c :=
  by
  ext x; cases x
  · simp
  · by_cases h : x = i
    · subst h; simp
    · simp [h]
#align sum.elim_update_right Sum.elim_update_right
-/

end Sum

/-!
### Ternary sum

Abbreviations for the maps from the summands to `α ⊕ β ⊕ γ`. This is useful for pattern-matching.
-/


namespace Sum3

#print Sum3.in₀ /-
/-- The map from the first summand into a ternary sum. -/
@[match_pattern, simp, reducible]
def in₀ (a) : Sum α (Sum β γ) :=
  inl a
#align sum3.in₀ Sum3.in₀
-/

#print Sum3.in₁ /-
/-- The map from the second summand into a ternary sum. -/
@[match_pattern, simp, reducible]
def in₁ (b) : Sum α (Sum β γ) :=
  inr <| inl b
#align sum3.in₁ Sum3.in₁
-/

#print Sum3.in₂ /-
/-- The map from the third summand into a ternary sum. -/
@[match_pattern, simp, reducible]
def in₂ (c) : Sum α (Sum β γ) :=
  inr <| inr c
#align sum3.in₂ Sum3.in₂
-/

end Sum3

