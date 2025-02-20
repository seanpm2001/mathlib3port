/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module group_theory.free_group
! leanprover-community/mathlib commit fac369018417f980cec5fcdafc766a69f88d8cfe
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fintype.Basic
import Mathbin.Data.List.Sublists
import Mathbin.GroupTheory.Subgroup.Basic

/-!
# Free groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines free groups over a type. Furthermore, it is shown that the free group construction
is an instance of a monad. For the result that `free_group` is the left adjoint to the forgetful
functor from groups to types, see `algebra/category/Group/adjunctions`.

## Main definitions

* `free_group`/`free_add_group`: the free group (resp. free additive group) associated to a type
  `α` defined as the words over `a : α × bool` modulo the relation `a * x * x⁻¹ * b = a * b`.
* `free_group.mk`/`free_add_group.mk`: the canonical quotient map `list (α × bool) → free_group α`.
* `free_group.of`/`free_add_group.of`: the canonical injection `α → free_group α`.
* `free_group.lift f`/`free_add_group.lift`: the canonical group homomorphism `free_group α →* G`
  given a group `G` and a function `f : α → G`.

## Main statements

* `free_group.church_rosser`/`free_add_group.church_rosser`: The Church-Rosser theorem for word
  reduction (also known as Newman's diamond lemma).
* `free_group.free_group_unit_equiv_int`: The free group over the one-point type
  is isomorphic to the integers.
* The free group construction is an instance of a monad.

## Implementation details

First we introduce the one step reduction relation `free_group.red.step`:
`w * x * x⁻¹ * v   ~>   w * v`, its reflexive transitive closure `free_group.red.trans`
and prove that its join is an equivalence relation. Then we introduce `free_group α` as a quotient
over `free_group.red.step`.

For the additive version we introduce the same relation under a different name so that we can
distinguish the quotient types more easily.


## Tags

free group, Newman's diamond lemma, Church-Rosser theorem
-/


open Relation

universe u v w

variable {α : Type u}

attribute [local simp] List.append_eq_has_append

run_cmd
  to_additive.map_namespace `free_group `free_add_group

#print FreeAddGroup.Red.Step /-
/-- Reduction step for the additive free group relation: `w + x + (-x) + v ~> w + v` -/
inductive FreeAddGroup.Red.Step : List (α × Bool) → List (α × Bool) → Prop
  | not {L₁ L₂ x b} : FreeAddGroup.Red.Step (L₁ ++ (x, b) :: (x, not b) :: L₂) (L₁ ++ L₂)
#align free_add_group.red.step FreeAddGroup.Red.Step
-/

attribute [simp] FreeAddGroup.Red.Step.not

#print FreeGroup.Red.Step /-
/-- Reduction step for the multiplicative free group relation: `w * x * x⁻¹ * v ~> w * v` -/
@[to_additive]
inductive FreeGroup.Red.Step : List (α × Bool) → List (α × Bool) → Prop
  | not {L₁ L₂ x b} : FreeGroup.Red.Step (L₁ ++ (x, b) :: (x, not b) :: L₂) (L₁ ++ L₂)
#align free_group.red.step FreeGroup.Red.Step
#align free_add_group.red.step FreeAddGroup.Red.Step
-/

attribute [simp] FreeGroup.Red.Step.not

namespace FreeGroup

variable {L L₁ L₂ L₃ L₄ : List (α × Bool)}

#print FreeGroup.Red /-
/-- Reflexive-transitive closure of red.step -/
@[to_additive "Reflexive-transitive closure of red.step"]
def Red : List (α × Bool) → List (α × Bool) → Prop :=
  ReflTransGen Red.Step
#align free_group.red FreeGroup.Red
#align free_add_group.red FreeAddGroup.Red
-/

#print FreeGroup.Red.refl /-
@[refl, to_additive]
theorem Red.refl : Red L L :=
  ReflTransGen.refl
#align free_group.red.refl FreeGroup.Red.refl
#align free_add_group.red.refl FreeAddGroup.Red.refl
-/

#print FreeGroup.Red.trans /-
@[trans, to_additive]
theorem Red.trans : Red L₁ L₂ → Red L₂ L₃ → Red L₁ L₃ :=
  ReflTransGen.trans
#align free_group.red.trans FreeGroup.Red.trans
#align free_add_group.red.trans FreeAddGroup.Red.trans
-/

namespace Red

#print FreeGroup.Red.Step.length /-
/-- Predicate asserting that the word `w₁` can be reduced to `w₂` in one step, i.e. there are words
`w₃ w₄` and letter `x` such that `w₁ = w₃xx⁻¹w₄` and `w₂ = w₃w₄`  -/
@[to_additive
      "Predicate asserting that the word `w₁` can be reduced to `w₂` in one step, i.e. there are words\n`w₃ w₄` and letter `x` such that `w₁ = w₃ + x + (-x) + w₄` and `w₂ = w₃w₄`"]
theorem Step.length : ∀ {L₁ L₂ : List (α × Bool)}, Step L₁ L₂ → L₂.length + 2 = L₁.length
  | _, _, @red.step.bnot _ L1 L2 x b => by rw [List.length_append, List.length_append] <;> rfl
#align free_group.red.step.length FreeGroup.Red.Step.length
#align free_add_group.red.step.length FreeAddGroup.Red.Step.length
-/

#print FreeGroup.Red.Step.not_rev /-
@[simp, to_additive]
theorem Step.not_rev {x b} : Step (L₁ ++ (x, not b) :: (x, b) :: L₂) (L₁ ++ L₂) := by
  cases b <;> exact step.bnot
#align free_group.red.step.bnot_rev FreeGroup.Red.Step.not_rev
#align free_add_group.red.step.bnot_rev FreeAddGroup.Red.Step.not_rev
-/

#print FreeGroup.Red.Step.cons_not /-
@[simp, to_additive]
theorem Step.cons_not {x b} : Red.Step ((x, b) :: (x, not b) :: L) L :=
  @Step.not _ [] _ _ _
#align free_group.red.step.cons_bnot FreeGroup.Red.Step.cons_not
#align free_add_group.red.step.cons_bnot FreeAddGroup.Red.Step.cons_not
-/

#print FreeGroup.Red.Step.cons_not_rev /-
@[simp, to_additive]
theorem Step.cons_not_rev {x b} : Red.Step ((x, not b) :: (x, b) :: L) L :=
  @Red.Step.not_rev _ [] _ _ _
#align free_group.red.step.cons_bnot_rev FreeGroup.Red.Step.cons_not_rev
#align free_add_group.red.step.cons_bnot_rev FreeAddGroup.Red.Step.cons_not_rev
-/

#print FreeGroup.Red.Step.append_left /-
@[to_additive]
theorem Step.append_left : ∀ {L₁ L₂ L₃ : List (α × Bool)}, Step L₂ L₃ → Step (L₁ ++ L₂) (L₁ ++ L₃)
  | _, _, _, red.step.bnot => by rw [← List.append_assoc, ← List.append_assoc] <;> constructor
#align free_group.red.step.append_left FreeGroup.Red.Step.append_left
#align free_add_group.red.step.append_left FreeAddGroup.Red.Step.append_left
-/

#print FreeGroup.Red.Step.cons /-
@[to_additive]
theorem Step.cons {x} (H : Red.Step L₁ L₂) : Red.Step (x :: L₁) (x :: L₂) :=
  @Step.append_left _ [x] _ _ H
#align free_group.red.step.cons FreeGroup.Red.Step.cons
#align free_add_group.red.step.cons FreeAddGroup.Red.Step.cons
-/

#print FreeGroup.Red.Step.append_right /-
@[to_additive]
theorem Step.append_right : ∀ {L₁ L₂ L₃ : List (α × Bool)}, Step L₁ L₂ → Step (L₁ ++ L₃) (L₂ ++ L₃)
  | _, _, _, red.step.bnot => by simp
#align free_group.red.step.append_right FreeGroup.Red.Step.append_right
#align free_add_group.red.step.append_right FreeAddGroup.Red.Step.append_right
-/

#print FreeGroup.Red.not_step_nil /-
@[to_additive]
theorem not_step_nil : ¬Step [] L := by
  generalize h' : [] = L'
  intro h
  cases' h with L₁ L₂
  simp [List.nil_eq_append] at h' 
  contradiction
#align free_group.red.not_step_nil FreeGroup.Red.not_step_nil
#align free_add_group.red.not_step_nil FreeAddGroup.Red.not_step_nil
-/

#print FreeGroup.Red.Step.cons_left_iff /-
@[to_additive]
theorem Step.cons_left_iff {a : α} {b : Bool} :
    Step ((a, b) :: L₁) L₂ ↔ (∃ L, Step L₁ L ∧ L₂ = (a, b) :: L) ∨ L₁ = (a, not b) :: L₂ :=
  by
  constructor
  · generalize hL : ((a, b) :: L₁ : List _) = L
    rintro @⟨_ | ⟨p, s'⟩, e, a', b'⟩
    · simp at hL ; simp [*]
    · simp at hL 
      rcases hL with ⟨rfl, rfl⟩
      refine' Or.inl ⟨s' ++ e, step.bnot, _⟩
      simp
  · rintro (⟨L, h, rfl⟩ | rfl)
    · exact step.cons h
    · exact step.cons_bnot
#align free_group.red.step.cons_left_iff FreeGroup.Red.Step.cons_left_iff
#align free_add_group.red.step.cons_left_iff FreeAddGroup.Red.Step.cons_left_iff
-/

#print FreeGroup.Red.not_step_singleton /-
@[to_additive]
theorem not_step_singleton : ∀ {p : α × Bool}, ¬Step [p] L
  | (a, b) => by simp [step.cons_left_iff, not_step_nil]
#align free_group.red.not_step_singleton FreeGroup.Red.not_step_singleton
#align free_add_group.red.not_step_singleton FreeAddGroup.Red.not_step_singleton
-/

#print FreeGroup.Red.Step.cons_cons_iff /-
@[to_additive]
theorem Step.cons_cons_iff : ∀ {p : α × Bool}, Step (p :: L₁) (p :: L₂) ↔ Step L₁ L₂ := by
  simp (config := { contextual := true }) [step.cons_left_iff, iff_def, or_imp]
#align free_group.red.step.cons_cons_iff FreeGroup.Red.Step.cons_cons_iff
#align free_add_group.red.step.cons_cons_iff FreeAddGroup.Red.Step.cons_cons_iff
-/

#print FreeGroup.Red.Step.append_left_iff /-
@[to_additive]
theorem Step.append_left_iff : ∀ L, Step (L ++ L₁) (L ++ L₂) ↔ Step L₁ L₂
  | [] => by simp
  | p :: l => by simp [step.append_left_iff l, step.cons_cons_iff]
#align free_group.red.step.append_left_iff FreeGroup.Red.Step.append_left_iff
#align free_add_group.red.step.append_left_iff FreeAddGroup.Red.Step.append_left_iff
-/

#print FreeGroup.Red.Step.diamond_aux /-
@[to_additive]
theorem Step.diamond_aux :
    ∀ {L₁ L₂ L₃ L₄ : List (α × Bool)} {x1 b1 x2 b2},
      L₁ ++ (x1, b1) :: (x1, not b1) :: L₂ = L₃ ++ (x2, b2) :: (x2, not b2) :: L₄ →
        L₁ ++ L₂ = L₃ ++ L₄ ∨ ∃ L₅, Red.Step (L₁ ++ L₂) L₅ ∧ Red.Step (L₃ ++ L₄) L₅
  | [], _, [], _, _, _, _, _, H => by injections <;> subst_vars <;> simp
  | [], _, [(x3, b3)], _, _, _, _, _, H => by injections <;> subst_vars <;> simp
  | [(x3, b3)], _, [], _, _, _, _, _, H => by injections <;> subst_vars <;> simp
  | [], _, (x3, b3) :: (x4, b4) :: tl, _, _, _, _, _, H => by
    injections <;> subst_vars <;> simp <;> right <;> exact ⟨_, red.step.bnot, red.step.cons_bnot⟩
  | (x3, b3) :: (x4, b4) :: tl, _, [], _, _, _, _, _, H => by
    injections <;> subst_vars <;> simp <;> right <;> exact ⟨_, red.step.cons_bnot, red.step.bnot⟩
  | (x3, b3) :: tl, _, (x4, b4) :: tl2, _, _, _, _, _, H =>
    let ⟨H1, H2⟩ := List.cons.inj H
    match step.diamond_aux H2 with
    | Or.inl H3 => Or.inl <| by simp [H1, H3]
    | Or.inr ⟨L₅, H3, H4⟩ => Or.inr ⟨_, Step.cons H3, by simpa [H1] using step.cons H4⟩
#align free_group.red.step.diamond_aux FreeGroup.Red.Step.diamond_aux
#align free_add_group.red.step.diamond_aux FreeAddGroup.Red.Step.diamond_aux
-/

#print FreeGroup.Red.Step.diamond /-
@[to_additive]
theorem Step.diamond :
    ∀ {L₁ L₂ L₃ L₄ : List (α × Bool)},
      Red.Step L₁ L₃ → Red.Step L₂ L₄ → L₁ = L₂ → L₃ = L₄ ∨ ∃ L₅, Red.Step L₃ L₅ ∧ Red.Step L₄ L₅
  | _, _, _, _, red.step.bnot, red.step.bnot, H => Step.diamond_aux H
#align free_group.red.step.diamond FreeGroup.Red.Step.diamond
#align free_add_group.red.step.diamond FreeAddGroup.Red.Step.diamond
-/

#print FreeGroup.Red.Step.to_red /-
@[to_additive]
theorem Step.to_red : Step L₁ L₂ → Red L₁ L₂ :=
  ReflTransGen.single
#align free_group.red.step.to_red FreeGroup.Red.Step.to_red
#align free_add_group.red.step.to_red FreeAddGroup.Red.Step.to_red
-/

#print FreeGroup.Red.church_rosser /-
/-- **Church-Rosser theorem** for word reduction: If `w1 w2 w3` are words such that `w1` reduces
to `w2` and `w3` respectively, then there is a word `w4` such that `w2` and `w3` reduce to `w4`
respectively. This is also known as Newman's diamond lemma. -/
@[to_additive
      "**Church-Rosser theorem** for word reduction: If `w1 w2 w3` are words such that `w1` reduces\nto `w2` and `w3` respectively, then there is a word `w4` such that `w2` and `w3` reduce to `w4`\nrespectively. This is also known as Newman's diamond lemma."]
theorem church_rosser : Red L₁ L₂ → Red L₁ L₃ → Join Red L₂ L₃ :=
  Relation.church_rosser fun a b c hab hac =>
    match b, c, Red.Step.diamond hab hac rfl with
    | b, _, Or.inl rfl => ⟨b, by rfl, by rfl⟩
    | b, c, Or.inr ⟨d, hbd, hcd⟩ => ⟨d, ReflGen.single hbd, hcd.to_red⟩
#align free_group.red.church_rosser FreeGroup.Red.church_rosser
#align free_add_group.red.church_rosser FreeAddGroup.Red.church_rosser
-/

#print FreeGroup.Red.cons_cons /-
@[to_additive]
theorem cons_cons {p} : Red L₁ L₂ → Red (p :: L₁) (p :: L₂) :=
  ReflTransGen.lift (List.cons p) fun a b => Step.cons
#align free_group.red.cons_cons FreeGroup.Red.cons_cons
#align free_add_group.red.cons_cons FreeAddGroup.Red.cons_cons
-/

#print FreeGroup.Red.cons_cons_iff /-
@[to_additive]
theorem cons_cons_iff (p) : Red (p :: L₁) (p :: L₂) ↔ Red L₁ L₂ :=
  Iff.intro
    (by
      generalize eq₁ : (p :: L₁ : List _) = LL₁
      generalize eq₂ : (p :: L₂ : List _) = LL₂
      intro h
      induction' h using Relation.ReflTransGen.head_induction_on with L₁ L₂ h₁₂ h ih generalizing L₁
        L₂
      · subst_vars; cases eq₂; constructor
      · subst_vars
        cases' p with a b
        rw [step.cons_left_iff] at h₁₂ 
        rcases h₁₂ with (⟨L, h₁₂, rfl⟩ | rfl)
        · exact (ih rfl rfl).headI h₁₂
        · exact (cons_cons h).tail step.cons_bnot_rev)
    cons_cons
#align free_group.red.cons_cons_iff FreeGroup.Red.cons_cons_iff
#align free_add_group.red.cons_cons_iff FreeAddGroup.Red.cons_cons_iff
-/

#print FreeGroup.Red.append_append_left_iff /-
@[to_additive]
theorem append_append_left_iff : ∀ L, Red (L ++ L₁) (L ++ L₂) ↔ Red L₁ L₂
  | [] => Iff.rfl
  | p :: L => by simp [append_append_left_iff L, cons_cons_iff]
#align free_group.red.append_append_left_iff FreeGroup.Red.append_append_left_iff
#align free_add_group.red.append_append_left_iff FreeAddGroup.Red.append_append_left_iff
-/

#print FreeGroup.Red.append_append /-
@[to_additive]
theorem append_append (h₁ : Red L₁ L₃) (h₂ : Red L₂ L₄) : Red (L₁ ++ L₂) (L₃ ++ L₄) :=
  (h₁.lift (fun L => L ++ L₂) fun a b => Step.append_right).trans ((append_append_left_iff _).2 h₂)
#align free_group.red.append_append FreeGroup.Red.append_append
#align free_add_group.red.append_append FreeAddGroup.Red.append_append
-/

#print FreeGroup.Red.to_append_iff /-
@[to_additive]
theorem to_append_iff : Red L (L₁ ++ L₂) ↔ ∃ L₃ L₄, L = L₃ ++ L₄ ∧ Red L₃ L₁ ∧ Red L₄ L₂ :=
  Iff.intro
    (by
      generalize eq : L₁ ++ L₂ = L₁₂
      intro h
      induction' h with L' L₁₂ hLL' h ih generalizing L₁ L₂
      · exact ⟨_, _, Eq.symm, by rfl, by rfl⟩
      · cases' h with s e a b
        rcases List.append_eq_append_iff.1 Eq with (⟨s', rfl, rfl⟩ | ⟨e', rfl, rfl⟩)
        · have : L₁ ++ (s' ++ (a, b) :: (a, not b) :: e) = L₁ ++ s' ++ (a, b) :: (a, not b) :: e :=
            by simp
          rcases ih this with ⟨w₁, w₂, rfl, h₁, h₂⟩
          exact ⟨w₁, w₂, rfl, h₁, h₂.tail step.bnot⟩
        · have : s ++ (a, b) :: (a, not b) :: e' ++ L₂ = s ++ (a, b) :: (a, not b) :: (e' ++ L₂) :=
            by simp
          rcases ih this with ⟨w₁, w₂, rfl, h₁, h₂⟩
          exact ⟨w₁, w₂, rfl, h₁.tail step.bnot, h₂⟩)
    fun ⟨L₃, L₄, Eq, h₃, h₄⟩ => Eq.symm ▸ append_append h₃ h₄
#align free_group.red.to_append_iff FreeGroup.Red.to_append_iff
#align free_add_group.red.to_append_iff FreeAddGroup.Red.to_append_iff
-/

#print FreeGroup.Red.nil_iff /-
/-- The empty word `[]` only reduces to itself. -/
@[to_additive "The empty word `[]` only reduces to itself."]
theorem nil_iff : Red [] L ↔ L = [] :=
  reflTransGen_iff_eq fun l => Red.not_step_nil
#align free_group.red.nil_iff FreeGroup.Red.nil_iff
#align free_add_group.red.nil_iff FreeAddGroup.Red.nil_iff
-/

#print FreeGroup.Red.singleton_iff /-
/-- A letter only reduces to itself. -/
@[to_additive "A letter only reduces to itself."]
theorem singleton_iff {x} : Red [x] L₁ ↔ L₁ = [x] :=
  reflTransGen_iff_eq fun l => not_step_singleton
#align free_group.red.singleton_iff FreeGroup.Red.singleton_iff
#align free_add_group.red.singleton_iff FreeAddGroup.Red.singleton_iff
-/

#print FreeGroup.Red.cons_nil_iff_singleton /-
/-- If `x` is a letter and `w` is a word such that `xw` reduces to the empty word, then `w` reduces
to `x⁻¹` -/
@[to_additive
      "If `x` is a letter and `w` is a word such that `x + w` reduces to the empty word,\nthen `w` reduces to `-x`."]
theorem cons_nil_iff_singleton {x b} : Red ((x, b) :: L) [] ↔ Red L [(x, not b)] :=
  Iff.intro
    (fun h => by
      have h₁ : Red ((x, not b) :: (x, b) :: L) [(x, not b)] := cons_cons h
      have h₂ : Red ((x, not b) :: (x, b) :: L) L := ReflTransGen.single Step.cons_not_rev
      let ⟨L', h₁, h₂⟩ := church_rosser h₁ h₂
      rw [singleton_iff] at h₁  <;> subst L' <;> assumption)
    fun h => (cons_cons h).tail Step.cons_not
#align free_group.red.cons_nil_iff_singleton FreeGroup.Red.cons_nil_iff_singleton
#align free_add_group.red.cons_nil_iff_singleton FreeAddGroup.Red.cons_nil_iff_singleton
-/

#print FreeGroup.Red.red_iff_irreducible /-
@[to_additive]
theorem red_iff_irreducible {x1 b1 x2 b2} (h : (x1, b1) ≠ (x2, b2)) :
    Red [(x1, not b1), (x2, b2)] L ↔ L = [(x1, not b1), (x2, b2)] :=
  by
  apply refl_trans_gen_iff_eq
  generalize eq : [(x1, not b1), (x2, b2)] = L'
  intro L h'
  cases h'
  simp [List.cons_eq_append_iff, List.nil_eq_append] at eq 
  rcases Eq with ⟨rfl, ⟨rfl, rfl⟩, ⟨rfl, rfl⟩, rfl⟩; subst_vars
  simp at h 
  contradiction
#align free_group.red.red_iff_irreducible FreeGroup.Red.red_iff_irreducible
#align free_add_group.red.red_iff_irreducible FreeAddGroup.Red.red_iff_irreducible
-/

#print FreeGroup.Red.inv_of_red_of_ne /-
/-- If `x` and `y` are distinct letters and `w₁ w₂` are words such that `xw₁` reduces to `yw₂`, then
`w₁` reduces to `x⁻¹yw₂`. -/
@[to_additive
      "If `x` and `y` are distinct letters and `w₁ w₂` are words such that `x + w₁` reduces to `y + w₂`,\nthen `w₁` reduces to `-x + y + w₂`."]
theorem inv_of_red_of_ne {x1 b1 x2 b2} (H1 : (x1, b1) ≠ (x2, b2))
    (H2 : Red ((x1, b1) :: L₁) ((x2, b2) :: L₂)) : Red L₁ ((x1, not b1) :: (x2, b2) :: L₂) :=
  by
  have : red ((x1, b1) :: L₁) ([(x2, b2)] ++ L₂) := H2
  rcases to_append_iff.1 this with ⟨_ | ⟨p, L₃⟩, L₄, eq, h₁, h₂⟩
  · simp [nil_iff] at h₁ ; contradiction
  · cases Eq
    show red (L₃ ++ L₄) ([(x1, not b1), (x2, b2)] ++ L₂)
    apply append_append _ h₂
    have h₁ : red ((x1, not b1) :: (x1, b1) :: L₃) [(x1, not b1), (x2, b2)] := cons_cons h₁
    have h₂ : red ((x1, not b1) :: (x1, b1) :: L₃) L₃ := step.cons_bnot_rev.to_red
    rcases church_rosser h₁ h₂ with ⟨L', h₁, h₂⟩
    rw [red_iff_irreducible H1] at h₁ 
    rwa [h₁] at h₂ 
#align free_group.red.inv_of_red_of_ne FreeGroup.Red.inv_of_red_of_ne
#align free_add_group.red.neg_of_red_of_ne FreeAddGroup.Red.neg_of_red_of_ne
-/

#print FreeGroup.Red.Step.sublist /-
@[to_additive]
theorem Step.sublist (H : Red.Step L₁ L₂) : L₂ <+ L₁ := by
  cases H <;> simp <;> constructor <;> constructor <;> rfl
#align free_group.red.step.sublist FreeGroup.Red.Step.sublist
#align free_add_group.red.step.sublist FreeAddGroup.Red.Step.sublist
-/

#print FreeGroup.Red.sublist /-
/-- If `w₁ w₂` are words such that `w₁` reduces to `w₂`, then `w₂` is a sublist of `w₁`. -/
@[to_additive
      "If `w₁ w₂` are words such that `w₁` reduces to `w₂`,\nthen `w₂` is a sublist of `w₁`."]
protected theorem sublist : Red L₁ L₂ → L₂ <+ L₁ :=
  reflTransGen_of_transitive_reflexive (fun l => List.Sublist.refl l)
    (fun a b c hab hbc => List.Sublist.trans hbc hab) fun a b => Red.Step.sublist
#align free_group.red.sublist FreeGroup.Red.sublist
#align free_add_group.red.sublist FreeAddGroup.Red.sublist
-/

#print FreeGroup.Red.length_le /-
@[to_additive]
theorem length_le (h : Red L₁ L₂) : L₂.length ≤ L₁.length :=
  h.Sublist.length_le
#align free_group.red.length_le FreeGroup.Red.length_le
#align free_add_group.red.length_le FreeAddGroup.Red.length_le
-/

#print FreeGroup.Red.sizeof_of_step /-
@[to_additive]
theorem sizeof_of_step : ∀ {L₁ L₂ : List (α × Bool)}, Step L₁ L₂ → L₂.sizeOf < L₁.sizeOf
  | _, _, @step.bnot _ L1 L2 x b => by
    induction' L1 with hd tl ih
    case nil =>
      dsimp [List.sizeof]
      have H :
        1 + SizeOf.sizeOf (x, b) + (1 + SizeOf.sizeOf (x, not b) + List.sizeof L2) =
          List.sizeof L2 + 1 + (SizeOf.sizeOf (x, b) + SizeOf.sizeOf (x, not b) + 1) :=
        by ac_rfl
      rw [H]
      exact Nat.le_add_right _ _
    case cons =>
      dsimp [List.sizeof]
      exact Nat.add_lt_add_left ih _
#align free_group.red.sizeof_of_step FreeGroup.Red.sizeof_of_step
#align free_add_group.red.sizeof_of_step FreeAddGroup.Red.sizeof_of_step
-/

#print FreeGroup.Red.length /-
@[to_additive]
theorem length (h : Red L₁ L₂) : ∃ n, L₁.length = L₂.length + 2 * n :=
  by
  induction' h with L₂ L₃ h₁₂ h₂₃ ih
  · exact ⟨0, rfl⟩
  · rcases ih with ⟨n, eq⟩
    exists 1 + n
    simp [mul_add, Eq, (step.length h₂₃).symm, add_assoc]
#align free_group.red.length FreeGroup.Red.length
#align free_add_group.red.length FreeAddGroup.Red.length
-/

#print FreeGroup.Red.antisymm /-
@[to_additive]
theorem antisymm (h₁₂ : Red L₁ L₂) (h₂₁ : Red L₂ L₁) : L₁ = L₂ :=
  h₂₁.Sublist.antisymm h₁₂.Sublist
#align free_group.red.antisymm FreeGroup.Red.antisymm
#align free_add_group.red.antisymm FreeAddGroup.Red.antisymm
-/

end Red

#print FreeGroup.equivalence_join_red /-
@[to_additive]
theorem equivalence_join_red : Equivalence (Join (@Red α)) :=
  equivalence_join_reflTransGen fun a b c hab hac =>
    match b, c, Red.Step.diamond hab hac rfl with
    | b, _, Or.inl rfl => ⟨b, by rfl, by rfl⟩
    | b, c, Or.inr ⟨d, hbd, hcd⟩ => ⟨d, ReflGen.single hbd, ReflTransGen.single hcd⟩
#align free_group.equivalence_join_red FreeGroup.equivalence_join_red
#align free_add_group.equivalence_join_red FreeAddGroup.equivalence_join_red
-/

#print FreeGroup.join_red_of_step /-
@[to_additive]
theorem join_red_of_step (h : Red.Step L₁ L₂) : Join Red L₁ L₂ :=
  join_of_single reflexive_reflTransGen h.to_red
#align free_group.join_red_of_step FreeGroup.join_red_of_step
#align free_add_group.join_red_of_step FreeAddGroup.join_red_of_step
-/

#print FreeGroup.eqvGen_step_iff_join_red /-
@[to_additive]
theorem eqvGen_step_iff_join_red : EqvGen Red.Step L₁ L₂ ↔ Join Red L₁ L₂ :=
  Iff.intro
    (fun h =>
      have : EqvGen (Join Red) L₁ L₂ := h.mono fun a b => join_red_of_step
      equivalence_join_red.eqvGen_iff.1 this)
    (join_of_equivalence (EqvGen.is_equivalence _) fun a b =>
      reflTransGen_of_equivalence (EqvGen.is_equivalence _) EqvGen.rel)
#align free_group.eqv_gen_step_iff_join_red FreeGroup.eqvGen_step_iff_join_red
#align free_add_group.eqv_gen_step_iff_join_red FreeAddGroup.eqvGen_step_iff_join_red
-/

end FreeGroup

#print FreeGroup /-
/-- The free group over a type, i.e. the words formed by the elements of the type and their formal
inverses, quotient by one step reduction. -/
@[to_additive
      "The free additive group over a type, i.e. the words formed by the elements of the\ntype and their formal inverses, quotient by one step reduction."]
def FreeGroup (α : Type u) : Type u :=
  Quot <| @FreeGroup.Red.Step α
#align free_group FreeGroup
#align free_add_group FreeAddGroup
-/

namespace FreeGroup

variable {α} {L L₁ L₂ L₃ L₄ : List (α × Bool)}

#print FreeGroup.mk /-
/-- The canonical map from `list (α × bool)` to the free group on `α`. -/
@[to_additive "The canonical map from `list (α × bool)` to the free additive group on `α`."]
def mk (L) : FreeGroup α :=
  Quot.mk Red.Step L
#align free_group.mk FreeGroup.mk
#align free_add_group.mk FreeAddGroup.mk
-/

#print FreeGroup.quot_mk_eq_mk /-
@[simp, to_additive]
theorem quot_mk_eq_mk : Quot.mk Red.Step L = mk L :=
  rfl
#align free_group.quot_mk_eq_mk FreeGroup.quot_mk_eq_mk
#align free_add_group.quot_mk_eq_mk FreeAddGroup.quot_mk_eq_mk
-/

#print FreeGroup.quot_lift_mk /-
@[simp, to_additive]
theorem quot_lift_mk (β : Type v) (f : List (α × Bool) → β)
    (H : ∀ L₁ L₂, Red.Step L₁ L₂ → f L₁ = f L₂) : Quot.lift f H (mk L) = f L :=
  rfl
#align free_group.quot_lift_mk FreeGroup.quot_lift_mk
#align free_add_group.quot_lift_mk FreeAddGroup.quot_lift_mk
-/

#print FreeGroup.quot_liftOn_mk /-
@[simp, to_additive]
theorem quot_liftOn_mk (β : Type v) (f : List (α × Bool) → β)
    (H : ∀ L₁ L₂, Red.Step L₁ L₂ → f L₁ = f L₂) : Quot.liftOn (mk L) f H = f L :=
  rfl
#align free_group.quot_lift_on_mk FreeGroup.quot_liftOn_mk
#align free_add_group.quot_lift_on_mk FreeAddGroup.quot_liftOn_mk
-/

#print FreeGroup.quot_map_mk /-
@[simp, to_additive]
theorem quot_map_mk (β : Type v) (f : List (α × Bool) → List (β × Bool))
    (H : (Red.Step ⇒ Red.Step) f f) : Quot.map f H (mk L) = mk (f L) :=
  rfl
#align free_group.quot_map_mk FreeGroup.quot_map_mk
#align free_add_group.quot_map_mk FreeAddGroup.quot_map_mk
-/

@[to_additive]
instance : One (FreeGroup α) :=
  ⟨mk []⟩

#print FreeGroup.one_eq_mk /-
@[to_additive]
theorem one_eq_mk : (1 : FreeGroup α) = mk [] :=
  rfl
#align free_group.one_eq_mk FreeGroup.one_eq_mk
#align free_add_group.zero_eq_mk FreeAddGroup.zero_eq_mk
-/

@[to_additive]
instance : Inhabited (FreeGroup α) :=
  ⟨1⟩

@[to_additive]
instance : Mul (FreeGroup α) :=
  ⟨fun x y =>
    Quot.liftOn x
      (fun L₁ =>
        Quot.liftOn y (fun L₂ => mk <| L₁ ++ L₂) fun L₂ L₃ H =>
          Quot.sound <| Red.Step.append_left H)
      fun L₁ L₂ H => Quot.inductionOn y fun L₃ => Quot.sound <| Red.Step.append_right H⟩

#print FreeGroup.mul_mk /-
@[simp, to_additive]
theorem mul_mk : mk L₁ * mk L₂ = mk (L₁ ++ L₂) :=
  rfl
#align free_group.mul_mk FreeGroup.mul_mk
#align free_add_group.add_mk FreeAddGroup.add_mk
-/

#print FreeGroup.invRev /-
/-- Transform a word representing a free group element into a word representing its inverse. -/
@[to_additive
      "Transform a word representing a free group element into a word representing its\nnegative."]
def invRev (w : List (α × Bool)) : List (α × Bool) :=
  (List.map (fun g : α × Bool => (g.1, not g.2)) w).reverse
#align free_group.inv_rev FreeGroup.invRev
#align free_add_group.neg_rev FreeAddGroup.negRev
-/

#print FreeGroup.invRev_length /-
@[simp, to_additive]
theorem invRev_length : (invRev L₁).length = L₁.length := by simp [inv_rev]
#align free_group.inv_rev_length FreeGroup.invRev_length
#align free_add_group.neg_rev_length FreeAddGroup.negRev_length
-/

#print FreeGroup.invRev_invRev /-
@[simp, to_additive]
theorem invRev_invRev : invRev (invRev L₁) = L₁ := by simp [inv_rev, (· ∘ ·)]
#align free_group.inv_rev_inv_rev FreeGroup.invRev_invRev
#align free_add_group.neg_rev_neg_rev FreeAddGroup.negRev_negRev
-/

#print FreeGroup.invRev_empty /-
@[simp, to_additive]
theorem invRev_empty : invRev ([] : List (α × Bool)) = [] :=
  rfl
#align free_group.inv_rev_empty FreeGroup.invRev_empty
#align free_add_group.neg_rev_empty FreeAddGroup.negRev_empty
-/

#print FreeGroup.invRev_involutive /-
@[to_additive]
theorem invRev_involutive : Function.Involutive (@invRev α) := fun _ => invRev_invRev
#align free_group.inv_rev_involutive FreeGroup.invRev_involutive
#align free_add_group.neg_rev_involutive FreeAddGroup.negRev_involutive
-/

#print FreeGroup.invRev_injective /-
@[to_additive]
theorem invRev_injective : Function.Injective (@invRev α) :=
  invRev_involutive.Injective
#align free_group.inv_rev_injective FreeGroup.invRev_injective
#align free_add_group.neg_rev_injective FreeAddGroup.negRev_injective
-/

#print FreeGroup.invRev_surjective /-
@[to_additive]
theorem invRev_surjective : Function.Surjective (@invRev α) :=
  invRev_involutive.Surjective
#align free_group.inv_rev_surjective FreeGroup.invRev_surjective
#align free_add_group.neg_rev_surjective FreeAddGroup.negRev_surjective
-/

#print FreeGroup.invRev_bijective /-
@[to_additive]
theorem invRev_bijective : Function.Bijective (@invRev α) :=
  invRev_involutive.Bijective
#align free_group.inv_rev_bijective FreeGroup.invRev_bijective
#align free_add_group.neg_rev_bijective FreeAddGroup.negRev_bijective
-/

@[to_additive]
instance : Inv (FreeGroup α) :=
  ⟨Quot.map invRev (by intro a b h; cases h; simp [inv_rev])⟩

#print FreeGroup.inv_mk /-
@[simp, to_additive]
theorem inv_mk : (mk L)⁻¹ = mk (invRev L) :=
  rfl
#align free_group.inv_mk FreeGroup.inv_mk
#align free_add_group.neg_mk FreeAddGroup.neg_mk
-/

#print FreeGroup.Red.Step.invRev /-
@[to_additive]
theorem Red.Step.invRev {L₁ L₂ : List (α × Bool)} (h : Red.Step L₁ L₂) :
    Red.Step (invRev L₁) (invRev L₂) :=
  by
  cases' h with a b x y
  simp [inv_rev]
#align free_group.red.step.inv_rev FreeGroup.Red.Step.invRev
#align free_add_group.red.step.neg_rev FreeAddGroup.Red.Step.negRev
-/

#print FreeGroup.Red.invRev /-
@[to_additive]
theorem Red.invRev {L₁ L₂ : List (α × Bool)} (h : Red L₁ L₂) : Red (invRev L₁) (invRev L₂) :=
  Relation.ReflTransGen.lift _ (fun a b => Red.Step.invRev) h
#align free_group.red.inv_rev FreeGroup.Red.invRev
#align free_add_group.red.neg_rev FreeAddGroup.Red.negRev
-/

#print FreeGroup.Red.step_invRev_iff /-
@[simp, to_additive]
theorem Red.step_invRev_iff : Red.Step (invRev L₁) (invRev L₂) ↔ Red.Step L₁ L₂ :=
  ⟨fun h => by simpa only [inv_rev_inv_rev] using h.inv_rev, fun h => h.invRev⟩
#align free_group.red.step_inv_rev_iff FreeGroup.Red.step_invRev_iff
#align free_add_group.red.step_neg_rev_iff FreeAddGroup.Red.step_negRev_iff
-/

#print FreeGroup.red_invRev_iff /-
@[simp, to_additive]
theorem red_invRev_iff : Red (invRev L₁) (invRev L₂) ↔ Red L₁ L₂ :=
  ⟨fun h => by simpa only [inv_rev_inv_rev] using h.inv_rev, fun h => h.invRev⟩
#align free_group.red_inv_rev_iff FreeGroup.red_invRev_iff
#align free_add_group.red_neg_rev_iff FreeAddGroup.red_negRev_iff
-/

@[to_additive]
instance : Group (FreeGroup α) where
  mul := (· * ·)
  one := 1
  inv := Inv.inv
  mul_assoc := by rintro ⟨L₁⟩ ⟨L₂⟩ ⟨L₃⟩ <;> simp
  one_mul := by rintro ⟨L⟩ <;> rfl
  mul_one := by rintro ⟨L⟩ <;> simp [one_eq_mk]
  mul_left_inv := by
    rintro ⟨L⟩ <;>
      exact
        List.recOn L rfl fun ⟨x, b⟩ tl ih =>
          Eq.trans (Quot.sound <| by simp [inv_rev, one_eq_mk]) ih

#print FreeGroup.of /-
/-- `of` is the canonical injection from the type to the free group over that type by sending each
element to the equivalence class of the letter that is the element. -/
@[to_additive
      "`of` is the canonical injection from the type to the free group over that type\nby sending each element to the equivalence class of the letter that is the element."]
def of (x : α) : FreeGroup α :=
  mk [(x, true)]
#align free_group.of FreeGroup.of
#align free_add_group.of FreeAddGroup.of
-/

#print FreeGroup.Red.exact /-
@[to_additive]
theorem Red.exact : mk L₁ = mk L₂ ↔ Join Red L₁ L₂ :=
  calc
    mk L₁ = mk L₂ ↔ EqvGen Red.Step L₁ L₂ := Iff.intro (Quot.exact _) Quot.EqvGen_sound
    _ ↔ Join Red L₁ L₂ := eqvGen_step_iff_join_red
#align free_group.red.exact FreeGroup.Red.exact
#align free_add_group.red.exact FreeAddGroup.Red.exact
-/

#print FreeGroup.of_injective /-
/-- The canonical map from the type to the free group is an injection. -/
@[to_additive "The canonical map from the type to the additive free group is an injection."]
theorem of_injective : Function.Injective (@of α) := fun _ _ H =>
  by
  let ⟨L₁, hx, hy⟩ := Red.exact.1 H
  simp [red.singleton_iff] at hx hy  <;> cc
#align free_group.of_injective FreeGroup.of_injective
#align free_add_group.of_injective FreeAddGroup.of_injective
-/

section lift

variable {β : Type v} [Group β] (f : α → β) {x y : FreeGroup α}

#print FreeGroup.Lift.aux /-
/-- Given `f : α → β` with `β` a group, the canonical map `list (α × bool) → β` -/
@[to_additive
      "Given `f : α → β` with `β` an additive group, the canonical map\n`list (α × bool) → β`"]
def Lift.aux : List (α × Bool) → β := fun L =>
  List.prod <| L.map fun x => cond x.2 (f x.1) (f x.1)⁻¹
#align free_group.lift.aux FreeGroup.Lift.aux
#align free_add_group.lift.aux FreeAddGroup.Lift.aux
-/

#print FreeGroup.Red.Step.lift /-
@[to_additive]
theorem Red.Step.lift {f : α → β} (H : Red.Step L₁ L₂) : Lift.aux f L₁ = Lift.aux f L₂ := by
  cases' H with _ _ _ b <;> cases b <;> simp [lift.aux]
#align free_group.red.step.lift FreeGroup.Red.Step.lift
#align free_add_group.red.step.lift FreeAddGroup.Red.Step.lift
-/

#print FreeGroup.lift /-
/-- If `β` is a group, then any function from `α` to `β`
extends uniquely to a group homomorphism from
the free group over `α` to `β` -/
@[to_additive
      "If `β` is an additive group, then any function from `α` to `β`\nextends uniquely to an additive group homomorphism from\nthe free additive group over `α` to `β`",
  simps symm_apply]
def lift : (α → β) ≃ (FreeGroup α →* β)
    where
  toFun f :=
    MonoidHom.mk' (Quot.lift (Lift.aux f) fun L₁ L₂ => Red.Step.lift) <| by rintro ⟨L₁⟩ ⟨L₂⟩;
      simp [lift.aux]
  invFun g := g ∘ of
  left_inv f := one_mul _
  right_inv g :=
    MonoidHom.ext <| by
      rintro ⟨L⟩
      apply List.recOn L
      · exact g.map_one.symm
      · rintro ⟨x, _ | _⟩ t (ih : _ = g (mk t))
        · show _ = g ((of x)⁻¹ * mk t)
          simpa [lift.aux] using ih
        · show _ = g (of x * mk t)
          simpa [lift.aux] using ih
#align free_group.lift FreeGroup.lift
#align free_add_group.lift FreeAddGroup.lift
-/

variable {f}

#print FreeGroup.lift.mk /-
@[simp, to_additive]
theorem lift.mk : lift f (mk L) = List.prod (L.map fun x => cond x.2 (f x.1) (f x.1)⁻¹) :=
  rfl
#align free_group.lift.mk FreeGroup.lift.mk
#align free_add_group.lift.mk FreeAddGroup.lift.mk
-/

#print FreeGroup.lift.of /-
@[simp, to_additive]
theorem lift.of {x} : lift f (of x) = f x :=
  one_mul _
#align free_group.lift.of FreeGroup.lift.of
#align free_add_group.lift.of FreeAddGroup.lift.of
-/

#print FreeGroup.lift.unique /-
@[to_additive]
theorem lift.unique (g : FreeGroup α →* β) (hg : ∀ x, g (of x) = f x) : ∀ {x}, g x = lift f x :=
  MonoidHom.congr_fun <| lift.symm_apply_eq.mp (funext hg : g ∘ of = f)
#align free_group.lift.unique FreeGroup.lift.unique
#align free_add_group.lift.unique FreeAddGroup.lift.unique
-/

#print FreeGroup.ext_hom /-
/-- Two homomorphisms out of a free group are equal if they are equal on generators.

See note [partially-applied ext lemmas]. -/
@[ext,
  to_additive
      "Two homomorphisms out of a free additive group are equal if they are equal on generators.\n\nSee note [partially-applied ext lemmas]."]
theorem ext_hom {G : Type _} [Group G] (f g : FreeGroup α →* G) (h : ∀ a, f (of a) = g (of a)) :
    f = g :=
  lift.symm.Injective <| funext h
#align free_group.ext_hom FreeGroup.ext_hom
#align free_add_group.ext_hom FreeAddGroup.ext_hom
-/

#print FreeGroup.lift.of_eq /-
@[to_additive]
theorem lift.of_eq (x : FreeGroup α) : lift of x = x :=
  MonoidHom.congr_fun (lift.apply_symm_apply (MonoidHom.id _)) x
#align free_group.lift.of_eq FreeGroup.lift.of_eq
#align free_add_group.lift.of_eq FreeAddGroup.lift.of_eq
-/

#print FreeGroup.lift.range_le /-
@[to_additive]
theorem lift.range_le {s : Subgroup β} (H : Set.range f ⊆ s) : (lift f).range ≤ s := by
  rintro _ ⟨⟨L⟩, rfl⟩ <;>
    exact
      List.recOn L s.one_mem fun ⟨x, b⟩ tl ih =>
        Bool.recOn b (by simp at ih ⊢ <;> exact s.mul_mem (s.inv_mem <| H ⟨x, rfl⟩) ih)
          (by simp at ih ⊢ <;> exact s.mul_mem (H ⟨x, rfl⟩) ih)
#align free_group.lift.range_le FreeGroup.lift.range_le
#align free_add_group.lift.range_le FreeAddGroup.lift.range_le
-/

#print FreeGroup.lift.range_eq_closure /-
@[to_additive]
theorem lift.range_eq_closure : (lift f).range = Subgroup.closure (Set.range f) :=
  by
  apply le_antisymm (lift.range_le Subgroup.subset_closure)
  rw [Subgroup.closure_le]
  rintro _ ⟨a, rfl⟩
  exact ⟨of a, by simp only [lift.of]⟩
#align free_group.lift.range_eq_closure FreeGroup.lift.range_eq_closure
#align free_add_group.lift.range_eq_closure FreeAddGroup.lift.range_eq_closure
-/

end lift

section Map

variable {β : Type v} (f : α → β) {x y : FreeGroup α}

#print FreeGroup.map /-
/-- Any function from `α` to `β` extends uniquely
to a group homomorphism from the free group
over `α` to the free group over `β`. -/
@[to_additive
      "Any function from `α` to `β` extends uniquely to an additive group homomorphism\nfrom the additive free group over `α` to the additive free group over `β`."]
def map : FreeGroup α →* FreeGroup β :=
  MonoidHom.mk' (Quot.map (List.map fun x => (f x.1, x.2)) fun L₁ L₂ H => by cases H <;> simp)
    (by rintro ⟨L₁⟩ ⟨L₂⟩; simp)
#align free_group.map FreeGroup.map
#align free_add_group.map FreeAddGroup.map
-/

variable {f}

#print FreeGroup.map.mk /-
@[simp, to_additive]
theorem map.mk : map f (mk L) = mk (L.map fun x => (f x.1, x.2)) :=
  rfl
#align free_group.map.mk FreeGroup.map.mk
#align free_add_group.map.mk FreeAddGroup.map.mk
-/

#print FreeGroup.map.id /-
@[simp, to_additive]
theorem map.id (x : FreeGroup α) : map id x = x := by rcases x with ⟨L⟩ <;> simp [List.map_id']
#align free_group.map.id FreeGroup.map.id
#align free_add_group.map.id FreeAddGroup.map.id
-/

#print FreeGroup.map.id' /-
@[simp, to_additive]
theorem map.id' (x : FreeGroup α) : map (fun z => z) x = x :=
  map.id x
#align free_group.map.id' FreeGroup.map.id'
#align free_add_group.map.id' FreeAddGroup.map.id'
-/

#print FreeGroup.map.comp /-
@[to_additive]
theorem map.comp {γ : Type w} (f : α → β) (g : β → γ) (x) : map g (map f x) = map (g ∘ f) x := by
  rcases x with ⟨L⟩ <;> simp
#align free_group.map.comp FreeGroup.map.comp
#align free_add_group.map.comp FreeAddGroup.map.comp
-/

#print FreeGroup.map.of /-
@[simp, to_additive]
theorem map.of {x} : map f (of x) = of (f x) :=
  rfl
#align free_group.map.of FreeGroup.map.of
#align free_add_group.map.of FreeAddGroup.map.of
-/

#print FreeGroup.map.unique /-
@[to_additive]
theorem map.unique (g : FreeGroup α →* FreeGroup β) (hg : ∀ x, g (of x) = of (f x)) :
    ∀ {x}, g x = map f x := by
  rintro ⟨L⟩ <;>
    exact
      List.recOn L g.map_one fun ⟨x, b⟩ t (ih : g (mk t) = map f (mk t)) =>
        Bool.recOn b
          (show g ((of x)⁻¹ * mk t) = map f ((of x)⁻¹ * mk t) by
            simp [g.map_mul, g.map_inv, hg, ih])
          (show g (of x * mk t) = map f (of x * mk t) by simp [g.map_mul, hg, ih])
#align free_group.map.unique FreeGroup.map.unique
#align free_add_group.map.unique FreeAddGroup.map.unique
-/

#print FreeGroup.map_eq_lift /-
@[to_additive]
theorem map_eq_lift : map f x = lift (of ∘ f) x :=
  Eq.symm <| map.unique _ fun x => by simp
#align free_group.map_eq_lift FreeGroup.map_eq_lift
#align free_add_group.map_eq_lift FreeAddGroup.map_eq_lift
-/

#print FreeGroup.freeGroupCongr /-
/-- Equivalent types give rise to multiplicatively equivalent free groups.

The converse can be found in `group_theory.free_abelian_group_finsupp`,
as `equiv.of_free_group_equiv`
 -/
@[to_additive "Equivalent types give rise to additively equivalent additive free groups.",
  simps apply]
def freeGroupCongr {α β} (e : α ≃ β) : FreeGroup α ≃* FreeGroup β
    where
  toFun := map e
  invFun := map e.symm
  left_inv x := by simp [Function.comp, map.comp]
  right_inv x := by simp [Function.comp, map.comp]
  map_mul' := MonoidHom.map_mul _
#align free_group.free_group_congr FreeGroup.freeGroupCongr
#align free_add_group.free_add_group_congr FreeAddGroup.freeAddGroupCongr
-/

#print FreeGroup.freeGroupCongr_refl /-
@[simp, to_additive]
theorem freeGroupCongr_refl : freeGroupCongr (Equiv.refl α) = MulEquiv.refl _ :=
  MulEquiv.ext map.id
#align free_group.free_group_congr_refl FreeGroup.freeGroupCongr_refl
#align free_add_group.free_add_group_congr_refl FreeAddGroup.freeAddGroupCongr_refl
-/

#print FreeGroup.freeGroupCongr_symm /-
@[simp, to_additive]
theorem freeGroupCongr_symm {α β} (e : α ≃ β) : (freeGroupCongr e).symm = freeGroupCongr e.symm :=
  rfl
#align free_group.free_group_congr_symm FreeGroup.freeGroupCongr_symm
#align free_add_group.free_add_group_congr_symm FreeAddGroup.freeAddGroupCongr_symm
-/

#print FreeGroup.freeGroupCongr_trans /-
@[to_additive]
theorem freeGroupCongr_trans {α β γ} (e : α ≃ β) (f : β ≃ γ) :
    (freeGroupCongr e).trans (freeGroupCongr f) = freeGroupCongr (e.trans f) :=
  MulEquiv.ext <| map.comp _ _
#align free_group.free_group_congr_trans FreeGroup.freeGroupCongr_trans
#align free_add_group.free_add_group_congr_trans FreeAddGroup.freeAddGroupCongr_trans
-/

end Map

section Prod

variable [Group α] (x y : FreeGroup α)

#print FreeGroup.prod /-
/-- If `α` is a group, then any function from `α` to `α`
extends uniquely to a homomorphism from the
free group over `α` to `α`. This is the multiplicative
version of `free_group.sum`. -/
@[to_additive
      "If `α` is an additive group, then any function from `α` to `α`\nextends uniquely to an additive homomorphism from the\nadditive free group over `α` to `α`."]
def prod : FreeGroup α →* α :=
  lift id
#align free_group.prod FreeGroup.prod
#align free_add_group.sum FreeAddGroup.sum
-/

variable {x y}

#print FreeGroup.prod_mk /-
@[simp, to_additive]
theorem prod_mk : prod (mk L) = List.prod (L.map fun x => cond x.2 x.1 x.1⁻¹) :=
  rfl
#align free_group.prod_mk FreeGroup.prod_mk
#align free_add_group.sum_mk FreeAddGroup.sum_mk
-/

#print FreeGroup.prod.of /-
@[simp, to_additive]
theorem prod.of {x : α} : prod (of x) = x :=
  lift.of
#align free_group.prod.of FreeGroup.prod.of
#align free_add_group.sum.of FreeAddGroup.sum.of
-/

#print FreeGroup.prod.unique /-
@[to_additive]
theorem prod.unique (g : FreeGroup α →* α) (hg : ∀ x, g (of x) = x) {x} : g x = prod x :=
  lift.unique g hg
#align free_group.prod.unique FreeGroup.prod.unique
#align free_add_group.sum.unique FreeAddGroup.sum.unique
-/

end Prod

#print FreeGroup.lift_eq_prod_map /-
@[to_additive]
theorem lift_eq_prod_map {β : Type v} [Group β] {f : α → β} {x} : lift f x = prod (map f x) :=
  by
  rw [← lift.unique (prod.comp (map f))]
  · rfl
  · simp
#align free_group.lift_eq_prod_map FreeGroup.lift_eq_prod_map
#align free_add_group.lift_eq_sum_map FreeAddGroup.lift_eq_sum_map
-/

section Sum

variable [AddGroup α] (x y : FreeGroup α)

#print FreeGroup.sum /-
/-- If `α` is a group, then any function from `α` to `α`
extends uniquely to a homomorphism from the
free group over `α` to `α`. This is the additive
version of `prod`. -/
def sum : α :=
  @prod (Multiplicative _) _ x
#align free_group.sum FreeGroup.sum
-/

variable {x y}

#print FreeGroup.sum_mk /-
@[simp]
theorem sum_mk : sum (mk L) = List.sum (L.map fun x => cond x.2 x.1 (-x.1)) :=
  rfl
#align free_group.sum_mk FreeGroup.sum_mk
-/

#print FreeGroup.sum.of /-
@[simp]
theorem sum.of {x : α} : sum (of x) = x :=
  prod.of
#align free_group.sum.of FreeGroup.sum.of
-/

#print FreeGroup.sum.map_mul /-
-- note: there are no bundled homs with different notation in the domain and codomain, so we copy
-- these manually
@[simp]
theorem sum.map_mul : sum (x * y) = sum x + sum y :=
  (@prod (Multiplicative _) _).map_mul _ _
#align free_group.sum.map_mul FreeGroup.sum.map_mul
-/

#print FreeGroup.sum.map_one /-
@[simp]
theorem sum.map_one : sum (1 : FreeGroup α) = 0 :=
  (@prod (Multiplicative _) _).map_one
#align free_group.sum.map_one FreeGroup.sum.map_one
-/

#print FreeGroup.sum.map_inv /-
@[simp]
theorem sum.map_inv : sum x⁻¹ = -sum x :=
  (prod : FreeGroup (Multiplicative α) →* Multiplicative α).map_inv _
#align free_group.sum.map_inv FreeGroup.sum.map_inv
-/

end Sum

#print FreeGroup.freeGroupEmptyEquivUnit /-
/-- The bijection between the free group on the empty type, and a type with one element. -/
@[to_additive
      "The bijection between the additive free group on the empty type, and a type with one element."]
def freeGroupEmptyEquivUnit : FreeGroup Empty ≃ Unit
    where
  toFun _ := ()
  invFun _ := 1
  left_inv := by rintro ⟨_ | ⟨⟨⟨⟩, _⟩, _⟩⟩ <;> rfl
  right_inv := fun ⟨⟩ => rfl
#align free_group.free_group_empty_equiv_unit FreeGroup.freeGroupEmptyEquivUnit
#align free_add_group.free_add_group_empty_equiv_add_unit FreeAddGroup.freeAddGroupEmptyEquivAddUnit
-/

#print FreeGroup.freeGroupUnitEquivInt /-
/-- The bijection between the free group on a singleton, and the integers. -/
def freeGroupUnitEquivInt : FreeGroup Unit ≃ ℤ
    where
  toFun x :=
    sum
      (by
        revert x; apply MonoidHom.toFun
        apply map fun _ => (1 : ℤ))
  invFun x := of () ^ x
  left_inv := by
    rintro ⟨L⟩
    refine' List.recOn L rfl _
    exact fun ⟨⟨⟩, b⟩ tl ih => by cases b <;> simp [zpow_add] at ih ⊢ <;> rw [ih] <;> rfl
  right_inv x :=
    Int.induction_on x (by simp) (fun i ih => by simp at ih  <;> simp [zpow_add, ih]) fun i ih => by
      simp at ih  <;> simp [zpow_add, ih, sub_eq_add_neg, -Int.add_neg_one]
#align free_group.free_group_unit_equiv_int FreeGroup.freeGroupUnitEquivInt
-/

section Category

variable {β : Type u}

@[to_additive]
instance : Monad FreeGroup.{u} where
  pure α := of
  map α β f := map f
  bind α β x f := lift f x

#print FreeGroup.induction_on /-
@[elab_as_elim, to_additive]
protected theorem induction_on {C : FreeGroup α → Prop} (z : FreeGroup α) (C1 : C 1)
    (Cp : ∀ x, C <| pure x) (Ci : ∀ x, C (pure x) → C (pure x)⁻¹)
    (Cm : ∀ x y, C x → C y → C (x * y)) : C z :=
  Quot.inductionOn z fun L =>
    List.recOn L C1 fun ⟨x, b⟩ tl ih => Bool.recOn b (Cm _ _ (Ci _ <| Cp x) ih) (Cm _ _ (Cp x) ih)
#align free_group.induction_on FreeGroup.induction_on
#align free_add_group.induction_on FreeAddGroup.induction_on
-/

#print FreeGroup.map_pure /-
@[simp, to_additive]
theorem map_pure (f : α → β) (x : α) : f <$> (pure x : FreeGroup α) = pure (f x) :=
  map.of
#align free_group.map_pure FreeGroup.map_pure
#align free_add_group.map_pure FreeAddGroup.map_pure
-/

#print FreeGroup.map_one /-
@[simp, to_additive]
theorem map_one (f : α → β) : f <$> (1 : FreeGroup α) = 1 :=
  (map f).map_one
#align free_group.map_one FreeGroup.map_one
#align free_add_group.map_zero FreeAddGroup.map_zero
-/

#print FreeGroup.map_mul /-
@[simp, to_additive]
theorem map_mul (f : α → β) (x y : FreeGroup α) : f <$> (x * y) = f <$> x * f <$> y :=
  (map f).map_mul x y
#align free_group.map_mul FreeGroup.map_mul
#align free_add_group.map_add FreeAddGroup.map_add
-/

#print FreeGroup.map_inv /-
@[simp, to_additive]
theorem map_inv (f : α → β) (x : FreeGroup α) : f <$> x⁻¹ = (f <$> x)⁻¹ :=
  (map f).map_inv x
#align free_group.map_inv FreeGroup.map_inv
#align free_add_group.map_neg FreeAddGroup.map_neg
-/

#print FreeGroup.pure_bind /-
@[simp, to_additive]
theorem pure_bind (f : α → FreeGroup β) (x) : pure x >>= f = f x :=
  lift.of
#align free_group.pure_bind FreeGroup.pure_bind
#align free_add_group.pure_bind FreeAddGroup.pure_bind
-/

#print FreeGroup.one_bind /-
@[simp, to_additive]
theorem one_bind (f : α → FreeGroup β) : 1 >>= f = 1 :=
  (lift f).map_one
#align free_group.one_bind FreeGroup.one_bind
#align free_add_group.zero_bind FreeAddGroup.zero_bind
-/

#print FreeGroup.mul_bind /-
@[simp, to_additive]
theorem mul_bind (f : α → FreeGroup β) (x y : FreeGroup α) : x * y >>= f = (x >>= f) * (y >>= f) :=
  (lift f).map_mul _ _
#align free_group.mul_bind FreeGroup.mul_bind
#align free_add_group.add_bind FreeAddGroup.add_bind
-/

#print FreeGroup.inv_bind /-
@[simp, to_additive]
theorem inv_bind (f : α → FreeGroup β) (x : FreeGroup α) : x⁻¹ >>= f = (x >>= f)⁻¹ :=
  (lift f).map_inv _
#align free_group.inv_bind FreeGroup.inv_bind
#align free_add_group.neg_bind FreeAddGroup.neg_bind
-/

@[to_additive]
instance : LawfulMonad FreeGroup.{u}
    where
  id_map α x :=
    FreeGroup.induction_on x (map_one id) (fun x => map_pure id x) (fun x ih => by rw [map_inv, ih])
      fun x y ihx ihy => by rw [map_mul, ihx, ihy]
  pure_bind α β x f := pure_bind f x
  bind_assoc α β γ x f g :=
    FreeGroup.induction_on x (by iterate 3 rw [one_bind]) (fun x => by iterate 2 rw [pure_bind])
      (fun x ih => by iterate 3 rw [inv_bind] <;> rw [ih]) fun x y ihx ihy => by
      iterate 3 rw [mul_bind] <;> rw [ihx, ihy]
  bind_pure_comp α β f x :=
    FreeGroup.induction_on x (by rw [one_bind, map_one]) (fun x => by rw [pure_bind, map_pure])
      (fun x ih => by rw [inv_bind, map_inv, ih]) fun x y ihx ihy => by
      rw [mul_bind, map_mul, ihx, ihy]

end Category

section Reduce

variable [DecidableEq α]

#print FreeGroup.reduce /-
/-- The maximal reduction of a word. It is computable
iff `α` has decidable equality. -/
@[to_additive "The maximal reduction of a word. It is computable\niff `α` has decidable equality."]
def reduce (L : List (α × Bool)) : List (α × Bool) :=
  List.recOn L [] fun hd1 tl1 ih =>
    List.casesOn ih [hd1] fun hd2 tl2 =>
      if hd1.1 = hd2.1 ∧ hd1.2 = not hd2.2 then tl2 else hd1 :: hd2 :: tl2
#align free_group.reduce FreeGroup.reduce
#align free_add_group.reduce FreeAddGroup.reduce
-/

#print FreeGroup.reduce.cons /-
@[simp, to_additive]
theorem reduce.cons (x) :
    reduce (x :: L) =
      List.casesOn (reduce L) [x] fun hd tl =>
        if x.1 = hd.1 ∧ x.2 = not hd.2 then tl else x :: hd :: tl :=
  rfl
#align free_group.reduce.cons FreeGroup.reduce.cons
#align free_add_group.reduce.cons FreeAddGroup.reduce.cons
-/

#print FreeGroup.reduce.red /-
/-- The first theorem that characterises the function
`reduce`: a word reduces to its maximal reduction. -/
@[to_additive
      "The first theorem that characterises the function\n`reduce`: a word reduces to its maximal reduction."]
theorem reduce.red : Red L (reduce L) :=
  by
  induction' L with hd1 tl1 ih
  case nil => constructor
  case cons =>
    dsimp
    revert ih
    generalize htl : reduce tl1 = TL
    intro ih
    cases' TL with hd2 tl2
    case nil => exact red.cons_cons ih
    case cons =>
      dsimp only
      split_ifs with h
      · trans
        · exact red.cons_cons ih
        · cases hd1; cases hd2; cases h
          dsimp at *; subst_vars
          exact red.step.cons_bnot_rev.to_red
      · exact red.cons_cons ih
#align free_group.reduce.red FreeGroup.reduce.red
#align free_add_group.reduce.red FreeAddGroup.reduce.red
-/

#print FreeGroup.reduce.not /-
@[to_additive]
theorem reduce.not {p : Prop} :
    ∀ {L₁ L₂ L₃ : List (α × Bool)} {x b}, reduce L₁ = L₂ ++ (x, b) :: (x, not b) :: L₃ → p
  | [], L2, L3, _, _ => fun h => by cases L2 <;> injections
  | (x, b) :: L1, L2, L3, x', b' => by
    dsimp
    cases r : reduce L1
    · dsimp; intro h
      have := congr_arg List.length h
      simp [-add_comm] at this 
      exact absurd this (by decide)
    cases' hd with y c
    dsimp only
    split_ifs with h <;> intro H
    · rw [H] at r 
      exact @reduce.not L1 ((y, c) :: L2) L3 x' b' r
    rcases L2 with (_ | ⟨a, L2⟩)
    · injections; subst_vars
      simp at h ; cc
    · refine' @reduce.not L1 L2 L3 x' b' _
      injection H with _ H
      rw [r, H]; rfl
#align free_group.reduce.not FreeGroup.reduce.not
#align free_add_group.reduce.not FreeAddGroup.reduce.not
-/

#print FreeGroup.reduce.min /-
/-- The second theorem that characterises the
function `reduce`: the maximal reduction of a word
only reduces to itself. -/
@[to_additive
      "The second theorem that characterises the\nfunction `reduce`: the maximal reduction of a word\nonly reduces to itself."]
theorem reduce.min (H : Red (reduce L₁) L₂) : reduce L₁ = L₂ :=
  by
  induction' H with L1 L' L2 H1 H2 ih
  · rfl
  · cases' H1 with L4 L5 x b
    exact reduce.not H2
#align free_group.reduce.min FreeGroup.reduce.min
#align free_add_group.reduce.min FreeAddGroup.reduce.min
-/

#print FreeGroup.reduce.idem /-
/-- `reduce` is idempotent, i.e. the maximal reduction
of the maximal reduction of a word is the maximal
reduction of the word. -/
@[simp,
  to_additive
      "`reduce` is idempotent, i.e. the maximal reduction\nof the maximal reduction of a word is the maximal\nreduction of the word."]
theorem reduce.idem : reduce (reduce L) = reduce L :=
  Eq.symm <| reduce.min reduce.red
#align free_group.reduce.idem FreeGroup.reduce.idem
#align free_add_group.reduce.idem FreeAddGroup.reduce.idem
-/

#print FreeGroup.reduce.Step.eq /-
@[to_additive]
theorem reduce.Step.eq (H : Red.Step L₁ L₂) : reduce L₁ = reduce L₂ :=
  let ⟨L₃, HR13, HR23⟩ := Red.church_rosser reduce.red (reduce.red.headI H)
  (reduce.min HR13).trans (reduce.min HR23).symm
#align free_group.reduce.step.eq FreeGroup.reduce.Step.eq
#align free_add_group.reduce.step.eq FreeAddGroup.reduce.Step.eq
-/

#print FreeGroup.reduce.eq_of_red /-
/-- If a word reduces to another word, then they have
a common maximal reduction. -/
@[to_additive "If a word reduces to another word, then they have\na common maximal reduction."]
theorem reduce.eq_of_red (H : Red L₁ L₂) : reduce L₁ = reduce L₂ :=
  let ⟨L₃, HR13, HR23⟩ := Red.church_rosser reduce.red (Red.trans H reduce.red)
  (reduce.min HR13).trans (reduce.min HR23).symm
#align free_group.reduce.eq_of_red FreeGroup.reduce.eq_of_red
#align free_add_group.reduce.eq_of_red FreeAddGroup.reduce.eq_of_red
-/

alias reduce.eq_of_red ← red.reduce_eq
#align free_group.red.reduce_eq FreeGroup.red.reduce_eq

alias FreeAddGroup.reduce.eq_of_red ← free_add_group.red.reduce_eq
#align free_group.free_add_group.red.reduce_eq FreeGroup.freeAddGroup.red.reduce_eq

#print FreeGroup.Red.reduce_right /-
@[to_additive]
theorem Red.reduce_right (h : Red L₁ L₂) : Red L₁ (reduce L₂) :=
  reduce.eq_of_red h ▸ reduce.red
#align free_group.red.reduce_right FreeGroup.Red.reduce_right
#align free_add_group.red.reduce_right FreeAddGroup.Red.reduce_right
-/

#print FreeGroup.Red.reduce_left /-
@[to_additive]
theorem Red.reduce_left (h : Red L₁ L₂) : Red L₂ (reduce L₁) :=
  (reduce.eq_of_red h).symm ▸ reduce.red
#align free_group.red.reduce_left FreeGroup.Red.reduce_left
#align free_add_group.red.reduce_left FreeAddGroup.Red.reduce_left
-/

#print FreeGroup.reduce.sound /-
/-- If two words correspond to the same element in
the free group, then they have a common maximal
reduction. This is the proof that the function that
sends an element of the free group to its maximal
reduction is well-defined. -/
@[to_additive
      "If two words correspond to the same element in\nthe additive free group, then they have a common maximal\nreduction. This is the proof that the function that\nsends an element of the free group to its maximal\nreduction is well-defined."]
theorem reduce.sound (H : mk L₁ = mk L₂) : reduce L₁ = reduce L₂ :=
  let ⟨L₃, H13, H23⟩ := Red.exact.1 H
  (reduce.eq_of_red H13).trans (reduce.eq_of_red H23).symm
#align free_group.reduce.sound FreeGroup.reduce.sound
#align free_add_group.reduce.sound FreeAddGroup.reduce.sound
-/

#print FreeGroup.reduce.exact /-
/-- If two words have a common maximal reduction,
then they correspond to the same element in the free group. -/
@[to_additive
      "If two words have a common maximal reduction,\nthen they correspond to the same element in the additive free group."]
theorem reduce.exact (H : reduce L₁ = reduce L₂) : mk L₁ = mk L₂ :=
  Red.exact.2 ⟨reduce L₂, H ▸ reduce.red, reduce.red⟩
#align free_group.reduce.exact FreeGroup.reduce.exact
#align free_add_group.reduce.exact FreeAddGroup.reduce.exact
-/

#print FreeGroup.reduce.self /-
/-- A word and its maximal reduction correspond to
the same element of the free group. -/
@[to_additive
      "A word and its maximal reduction correspond to\nthe same element of the additive free group."]
theorem reduce.self : mk (reduce L) = mk L :=
  reduce.exact reduce.idem
#align free_group.reduce.self FreeGroup.reduce.self
#align free_add_group.reduce.self FreeAddGroup.reduce.self
-/

#print FreeGroup.reduce.rev /-
/-- If words `w₁ w₂` are such that `w₁` reduces to `w₂`,
then `w₂` reduces to the maximal reduction of `w₁`. -/
@[to_additive
      "If words `w₁ w₂` are such that `w₁` reduces to `w₂`,\nthen `w₂` reduces to the maximal reduction of `w₁`."]
theorem reduce.rev (H : Red L₁ L₂) : Red L₂ (reduce L₁) :=
  (reduce.eq_of_red H).symm ▸ reduce.red
#align free_group.reduce.rev FreeGroup.reduce.rev
#align free_add_group.reduce.rev FreeAddGroup.reduce.rev
-/

#print FreeGroup.toWord /-
/-- The function that sends an element of the free
group to its maximal reduction. -/
@[to_additive
      "The function that sends an element of the additive free\ngroup to its maximal reduction."]
def toWord : FreeGroup α → List (α × Bool) :=
  Quot.lift reduce fun L₁ L₂ H => reduce.Step.eq H
#align free_group.to_word FreeGroup.toWord
#align free_add_group.to_word FreeAddGroup.toWord
-/

#print FreeGroup.mk_toWord /-
@[to_additive]
theorem mk_toWord : ∀ {x : FreeGroup α}, mk (toWord x) = x := by rintro ⟨L⟩ <;> exact reduce.self
#align free_group.mk_to_word FreeGroup.mk_toWord
#align free_add_group.mk_to_word FreeAddGroup.mk_toWord
-/

#print FreeGroup.toWord_injective /-
@[to_additive]
theorem toWord_injective : Function.Injective (toWord : FreeGroup α → List (α × Bool)) := by
  rintro ⟨L₁⟩ ⟨L₂⟩ <;> exact reduce.exact
#align free_group.to_word_injective FreeGroup.toWord_injective
#align free_add_group.to_word_injective FreeAddGroup.toWord_injective
-/

#print FreeGroup.toWord_inj /-
@[simp, to_additive]
theorem toWord_inj {x y : FreeGroup α} : toWord x = toWord y ↔ x = y :=
  toWord_injective.eq_iff
#align free_group.to_word_inj FreeGroup.toWord_inj
#align free_add_group.to_word_inj FreeAddGroup.toWord_inj
-/

#print FreeGroup.toWord_mk /-
@[simp, to_additive]
theorem toWord_mk : (mk L₁).toWord = reduce L₁ :=
  rfl
#align free_group.to_word_mk FreeGroup.toWord_mk
#align free_add_group.to_word_mk FreeAddGroup.toWord_mk
-/

#print FreeGroup.reduce_toWord /-
@[simp, to_additive]
theorem reduce_toWord : ∀ x : FreeGroup α, reduce (toWord x) = toWord x := by rintro ⟨L⟩;
  exact reduce.idem
#align free_group.reduce_to_word FreeGroup.reduce_toWord
#align free_add_group.reduce_to_word FreeAddGroup.reduce_toWord
-/

#print FreeGroup.toWord_one /-
@[simp, to_additive]
theorem toWord_one : (1 : FreeGroup α).toWord = [] :=
  rfl
#align free_group.to_word_one FreeGroup.toWord_one
#align free_add_group.to_word_zero FreeAddGroup.toWord_zero
-/

#print FreeGroup.toWord_eq_nil_iff /-
@[simp, to_additive]
theorem toWord_eq_nil_iff {x : FreeGroup α} : x.toWord = [] ↔ x = 1 :=
  toWord_injective.eq_iff' toWord_one
#align free_group.to_word_eq_nil_iff FreeGroup.toWord_eq_nil_iff
#align free_add_group.to_word_eq_nil_iff FreeAddGroup.toWord_eq_nil_iff
-/

#print FreeGroup.reduce_invRev /-
@[to_additive]
theorem reduce_invRev {w : List (α × Bool)} : reduce (invRev w) = invRev (reduce w) :=
  by
  apply reduce.min
  rw [← red_inv_rev_iff, inv_rev_inv_rev]
  apply red.reduce_left
  have : red (inv_rev (inv_rev w)) (inv_rev (reduce (inv_rev w))) := reduce.red.inv_rev
  rwa [inv_rev_inv_rev] at this 
#align free_group.reduce_inv_rev FreeGroup.reduce_invRev
#align free_add_group.reduce_neg_rev FreeAddGroup.reduce_negRev
-/

#print FreeGroup.toWord_inv /-
@[to_additive]
theorem toWord_inv {x : FreeGroup α} : x⁻¹.toWord = invRev x.toWord :=
  by
  rcases x with ⟨L⟩
  rw [quot_mk_eq_mk, inv_mk, to_word_mk, to_word_mk, reduce_inv_rev]
#align free_group.to_word_inv FreeGroup.toWord_inv
#align free_add_group.to_word_neg FreeAddGroup.toWord_neg
-/

#print FreeGroup.reduce.churchRosser /-
/-- Constructive Church-Rosser theorem (compare `church_rosser`). -/
@[to_additive "Constructive Church-Rosser theorem (compare `church_rosser`)."]
def reduce.churchRosser (H12 : Red L₁ L₂) (H13 : Red L₁ L₃) : { L₄ // Red L₂ L₄ ∧ Red L₃ L₄ } :=
  ⟨reduce L₁, reduce.rev H12, reduce.rev H13⟩
#align free_group.reduce.church_rosser FreeGroup.reduce.churchRosser
#align free_add_group.reduce.church_rosser FreeAddGroup.reduce.churchRosser
-/

@[to_additive]
instance : DecidableEq (FreeGroup α) :=
  toWord_injective.DecidableEq

#print FreeGroup.Red.decidableRel /-
-- TODO @[to_additive] doesn't succeed, possibly due to a bug
instance Red.decidableRel : DecidableRel (@Red α)
  | [], [] => isTrue Red.refl
  | [], hd2 :: tl2 => isFalse fun H => List.noConfusion (Red.nil_iff.1 H)
  | (x, b) :: tl, [] =>
    match red.decidable_rel tl [(x, not b)] with
    | is_true H => isTrue <| Red.trans (Red.cons_cons H) <| (@Red.Step.not _ [] [] _ _).to_red
    | is_false H => isFalse fun H2 => H <| Red.cons_nil_iff_singleton.1 H2
  | (x1, b1) :: tl1, (x2, b2) :: tl2 =>
    if h : (x1, b1) = (x2, b2) then
      match red.decidable_rel tl1 tl2 with
      | is_true H => isTrue <| h ▸ Red.cons_cons H
      | is_false H => isFalse fun H2 => H <| h ▸ (Red.cons_cons_iff _).1 <| H2
    else
      match red.decidable_rel tl1 ((x1, not b1) :: (x2, b2) :: tl2) with
      | is_true H => isTrue <| (Red.cons_cons H).tail Red.Step.cons_not
      | is_false H => isFalse fun H2 => H <| Red.inv_of_red_of_ne h H2
#align free_group.red.decidable_rel FreeGroup.Red.decidableRel
-/

#print FreeGroup.Red.enum /-
/-- A list containing every word that `w₁` reduces to. -/
def Red.enum (L₁ : List (α × Bool)) : List (List (α × Bool)) :=
  List.filter (fun L₂ => Red L₁ L₂) (List.sublists L₁)
#align free_group.red.enum FreeGroup.Red.enum
-/

#print FreeGroup.Red.enum.sound /-
theorem Red.enum.sound (H : L₂ ∈ Red.enum L₁) : Red L₁ L₂ :=
  List.of_mem_filter H
#align free_group.red.enum.sound FreeGroup.Red.enum.sound
-/

#print FreeGroup.Red.enum.complete /-
theorem Red.enum.complete (H : Red L₁ L₂) : L₂ ∈ Red.enum L₁ :=
  List.mem_filter_of_mem (List.mem_sublists.2 <| Red.sublist H) H
#align free_group.red.enum.complete FreeGroup.Red.enum.complete
-/

instance : Fintype { L₂ // Red L₁ L₂ } :=
  Fintype.subtype (List.toFinset <| Red.enum L₁) fun L₂ =>
    ⟨fun H => Red.enum.sound <| List.mem_toFinset.1 H, fun H =>
      List.mem_toFinset.2 <| Red.enum.complete H⟩

end Reduce

section Metric

variable [DecidableEq α]

#print FreeGroup.norm /-
/-- The length of reduced words provides a norm on a free group. -/
@[to_additive "The length of reduced words provides a norm on an additive free group."]
def norm (x : FreeGroup α) : ℕ :=
  x.toWord.length
#align free_group.norm FreeGroup.norm
#align free_add_group.norm FreeAddGroup.norm
-/

#print FreeGroup.norm_inv_eq /-
@[simp, to_additive]
theorem norm_inv_eq {x : FreeGroup α} : norm x⁻¹ = norm x := by
  simp only [norm, to_word_inv, inv_rev_length]
#align free_group.norm_inv_eq FreeGroup.norm_inv_eq
#align free_add_group.norm_neg_eq FreeAddGroup.norm_neg_eq
-/

#print FreeGroup.norm_eq_zero /-
@[simp, to_additive]
theorem norm_eq_zero {x : FreeGroup α} : norm x = 0 ↔ x = 1 := by
  simp only [norm, List.length_eq_zero, to_word_eq_nil_iff]
#align free_group.norm_eq_zero FreeGroup.norm_eq_zero
#align free_add_group.norm_eq_zero FreeAddGroup.norm_eq_zero
-/

#print FreeGroup.norm_one /-
@[simp, to_additive]
theorem norm_one : norm (1 : FreeGroup α) = 0 :=
  rfl
#align free_group.norm_one FreeGroup.norm_one
#align free_add_group.norm_zero FreeAddGroup.norm_zero
-/

#print FreeGroup.norm_mk_le /-
@[to_additive]
theorem norm_mk_le : norm (mk L₁) ≤ L₁.length :=
  reduce.red.length_le
#align free_group.norm_mk_le FreeGroup.norm_mk_le
#align free_add_group.norm_mk_le FreeAddGroup.norm_mk_le
-/

#print FreeGroup.norm_mul_le /-
@[to_additive]
theorem norm_mul_le (x y : FreeGroup α) : norm (x * y) ≤ norm x + norm y :=
  calc
    norm (x * y) = norm (mk (x.toWord ++ y.toWord)) := by rw [← mul_mk, mk_to_word, mk_to_word]
    _ ≤ (x.toWord ++ y.toWord).length := norm_mk_le
    _ = norm x + norm y := List.length_append _ _
#align free_group.norm_mul_le FreeGroup.norm_mul_le
#align free_add_group.norm_add_le FreeAddGroup.norm_add_le
-/

end Metric

end FreeGroup

