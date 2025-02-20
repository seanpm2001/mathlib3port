/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.option.n_ary
! leanprover-community/mathlib commit 995b47e555f1b6297c7cf16855f1023e355219fb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Option.Basic

/-!
# Binary map of options

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the binary map of `option`. This is mostly useful to define pointwise operations
on intervals.

## Main declarations

* `option.map₂`: Binary map of options.

## Notes

This file is very similar to `data.set.n_ary`, `data.finset.n_ary` and `order.filter.n_ary`. Please
keep them in sync.

We do not define `option.map₃` as its only purpose so far would be to prove properties of
`option.map₂` and casing already fulfills this task.
-/


open Function

namespace Option

variable {α α' β β' γ γ' δ δ' ε ε' : Type _} {f : α → β → γ} {a : Option α} {b : Option β}
  {c : Option γ}

#print Option.map₂ /-
/-- The image of a binary function `f : α → β → γ` as a function `option α → option β → option γ`.
Mathematically this should be thought of as the image of the corresponding function `α × β → γ`. -/
def map₂ (f : α → β → γ) (a : Option α) (b : Option β) : Option γ :=
  a.bind fun a => b.map <| f a
#align option.map₂ Option.map₂
-/

#print Option.map₂_def /-
/-- `option.map₂` in terms of monadic operations. Note that this can't be taken as the definition
because of the lack of universe polymorphism. -/
theorem map₂_def {α β γ : Type _} (f : α → β → γ) (a : Option α) (b : Option β) :
    map₂ f a b = f <$> a <*> b := by cases a <;> rfl
#align option.map₂_def Option.map₂_def
-/

#print Option.map₂_some_some /-
@[simp]
theorem map₂_some_some (f : α → β → γ) (a : α) (b : β) : map₂ f (some a) (some b) = some (f a b) :=
  rfl
#align option.map₂_some_some Option.map₂_some_some
-/

#print Option.map₂_coe_coe /-
theorem map₂_coe_coe (f : α → β → γ) (a : α) (b : β) : map₂ f a b = f a b :=
  rfl
#align option.map₂_coe_coe Option.map₂_coe_coe
-/

#print Option.map₂_none_left /-
@[simp]
theorem map₂_none_left (f : α → β → γ) (b : Option β) : map₂ f none b = none :=
  rfl
#align option.map₂_none_left Option.map₂_none_left
-/

#print Option.map₂_none_right /-
@[simp]
theorem map₂_none_right (f : α → β → γ) (a : Option α) : map₂ f a none = none := by cases a <;> rfl
#align option.map₂_none_right Option.map₂_none_right
-/

#print Option.map₂_coe_left /-
@[simp]
theorem map₂_coe_left (f : α → β → γ) (a : α) (b : Option β) : map₂ f a b = b.map fun b => f a b :=
  rfl
#align option.map₂_coe_left Option.map₂_coe_left
-/

#print Option.map₂_coe_right /-
@[simp]
theorem map₂_coe_right (f : α → β → γ) (a : Option α) (b : β) : map₂ f a b = a.map fun a => f a b :=
  rfl
#align option.map₂_coe_right Option.map₂_coe_right
-/

#print Option.mem_map₂_iff /-
@[simp]
theorem mem_map₂_iff {c : γ} : c ∈ map₂ f a b ↔ ∃ a' b', a' ∈ a ∧ b' ∈ b ∧ f a' b' = c := by
  simp [map₂]
#align option.mem_map₂_iff Option.mem_map₂_iff
-/

#print Option.map₂_eq_none_iff /-
@[simp]
theorem map₂_eq_none_iff : map₂ f a b = none ↔ a = none ∨ b = none := by
  cases a <;> cases b <;> simp
#align option.map₂_eq_none_iff Option.map₂_eq_none_iff
-/

#print Option.map₂_swap /-
theorem map₂_swap (f : α → β → γ) (a : Option α) (b : Option β) :
    map₂ f a b = map₂ (fun a b => f b a) b a := by cases a <;> cases b <;> rfl
#align option.map₂_swap Option.map₂_swap
-/

#print Option.map_map₂ /-
theorem map_map₂ (f : α → β → γ) (g : γ → δ) :
    (map₂ f a b).map g = map₂ (fun a b => g (f a b)) a b := by cases a <;> cases b <;> rfl
#align option.map_map₂ Option.map_map₂
-/

#print Option.map₂_map_left /-
theorem map₂_map_left (f : γ → β → δ) (g : α → γ) :
    map₂ f (a.map g) b = map₂ (fun a b => f (g a) b) a b := by cases a <;> rfl
#align option.map₂_map_left Option.map₂_map_left
-/

#print Option.map₂_map_right /-
theorem map₂_map_right (f : α → γ → δ) (g : β → γ) :
    map₂ f a (b.map g) = map₂ (fun a b => f a (g b)) a b := by cases b <;> rfl
#align option.map₂_map_right Option.map₂_map_right
-/

#print Option.map₂_curry /-
@[simp]
theorem map₂_curry (f : α × β → γ) (a : Option α) (b : Option β) :
    map₂ (curry f) a b = Option.map f (map₂ Prod.mk a b) :=
  (map_map₂ _ _).symm
#align option.map₂_curry Option.map₂_curry
-/

#print Option.map_uncurry /-
@[simp]
theorem map_uncurry (f : α → β → γ) (x : Option (α × β)) :
    x.map (uncurry f) = map₂ f (x.map Prod.fst) (x.map Prod.snd) := by cases x <;> rfl
#align option.map_uncurry Option.map_uncurry
-/

/-!
### Algebraic replacement rules

A collection of lemmas to transfer associativity, commutativity, distributivity, ... of operations
to the associativity, commutativity, distributivity, ... of `option.map₂` of those operations.
The proof pattern is `map₂_lemma operation_lemma`. For example, `map₂_comm mul_comm` proves that
`map₂ (*) a b = map₂ (*) g f` in a `comm_semigroup`.
-/


#print Option.map₂_assoc /-
theorem map₂_assoc {f : δ → γ → ε} {g : α → β → δ} {f' : α → ε' → ε} {g' : β → γ → ε'}
    (h_assoc : ∀ a b c, f (g a b) c = f' a (g' b c)) :
    map₂ f (map₂ g a b) c = map₂ f' a (map₂ g' b c) := by
  cases a <;> cases b <;> cases c <;> simp [h_assoc]
#align option.map₂_assoc Option.map₂_assoc
-/

#print Option.map₂_comm /-
theorem map₂_comm {g : β → α → γ} (h_comm : ∀ a b, f a b = g b a) : map₂ f a b = map₂ g b a := by
  cases a <;> cases b <;> simp [h_comm]
#align option.map₂_comm Option.map₂_comm
-/

#print Option.map₂_left_comm /-
theorem map₂_left_comm {f : α → δ → ε} {g : β → γ → δ} {f' : α → γ → δ'} {g' : β → δ' → ε}
    (h_left_comm : ∀ a b c, f a (g b c) = g' b (f' a c)) :
    map₂ f a (map₂ g b c) = map₂ g' b (map₂ f' a c) := by
  cases a <;> cases b <;> cases c <;> simp [h_left_comm]
#align option.map₂_left_comm Option.map₂_left_comm
-/

#print Option.map₂_right_comm /-
theorem map₂_right_comm {f : δ → γ → ε} {g : α → β → δ} {f' : α → γ → δ'} {g' : δ' → β → ε}
    (h_right_comm : ∀ a b c, f (g a b) c = g' (f' a c) b) :
    map₂ f (map₂ g a b) c = map₂ g' (map₂ f' a c) b := by
  cases a <;> cases b <;> cases c <;> simp [h_right_comm]
#align option.map₂_right_comm Option.map₂_right_comm
-/

#print Option.map_map₂_distrib /-
theorem map_map₂_distrib {g : γ → δ} {f' : α' → β' → δ} {g₁ : α → α'} {g₂ : β → β'}
    (h_distrib : ∀ a b, g (f a b) = f' (g₁ a) (g₂ b)) :
    (map₂ f a b).map g = map₂ f' (a.map g₁) (b.map g₂) := by
  cases a <;> cases b <;> simp [h_distrib]
#align option.map_map₂_distrib Option.map_map₂_distrib
-/

/-!
The following symmetric restatement are needed because unification has a hard time figuring all the
functions if you symmetrize on the spot. This is also how the other n-ary APIs do it.
-/


#print Option.map_map₂_distrib_left /-
/-- Symmetric statement to `option.map₂_map_left_comm`. -/
theorem map_map₂_distrib_left {g : γ → δ} {f' : α' → β → δ} {g' : α → α'}
    (h_distrib : ∀ a b, g (f a b) = f' (g' a) b) : (map₂ f a b).map g = map₂ f' (a.map g') b := by
  cases a <;> cases b <;> simp [h_distrib]
#align option.map_map₂_distrib_left Option.map_map₂_distrib_left
-/

#print Option.map_map₂_distrib_right /-
/-- Symmetric statement to `option.map_map₂_right_comm`. -/
theorem map_map₂_distrib_right {g : γ → δ} {f' : α → β' → δ} {g' : β → β'}
    (h_distrib : ∀ a b, g (f a b) = f' a (g' b)) : (map₂ f a b).map g = map₂ f' a (b.map g') := by
  cases a <;> cases b <;> simp [h_distrib]
#align option.map_map₂_distrib_right Option.map_map₂_distrib_right
-/

#print Option.map₂_map_left_comm /-
/-- Symmetric statement to `option.map_map₂_distrib_left`. -/
theorem map₂_map_left_comm {f : α' → β → γ} {g : α → α'} {f' : α → β → δ} {g' : δ → γ}
    (h_left_comm : ∀ a b, f (g a) b = g' (f' a b)) : map₂ f (a.map g) b = (map₂ f' a b).map g' := by
  cases a <;> cases b <;> simp [h_left_comm]
#align option.map₂_map_left_comm Option.map₂_map_left_comm
-/

#print Option.map_map₂_right_comm /-
/-- Symmetric statement to `option.map_map₂_distrib_right`. -/
theorem map_map₂_right_comm {f : α → β' → γ} {g : β → β'} {f' : α → β → δ} {g' : δ → γ}
    (h_right_comm : ∀ a b, f a (g b) = g' (f' a b)) : map₂ f a (b.map g) = (map₂ f' a b).map g' :=
  by cases a <;> cases b <;> simp [h_right_comm]
#align option.map_map₂_right_comm Option.map_map₂_right_comm
-/

#print Option.map_map₂_antidistrib /-
theorem map_map₂_antidistrib {g : γ → δ} {f' : β' → α' → δ} {g₁ : β → β'} {g₂ : α → α'}
    (h_antidistrib : ∀ a b, g (f a b) = f' (g₁ b) (g₂ a)) :
    (map₂ f a b).map g = map₂ f' (b.map g₁) (a.map g₂) := by
  cases a <;> cases b <;> simp [h_antidistrib]
#align option.map_map₂_antidistrib Option.map_map₂_antidistrib
-/

#print Option.map_map₂_antidistrib_left /-
/-- Symmetric statement to `option.map₂_map_left_anticomm`. -/
theorem map_map₂_antidistrib_left {g : γ → δ} {f' : β' → α → δ} {g' : β → β'}
    (h_antidistrib : ∀ a b, g (f a b) = f' (g' b) a) : (map₂ f a b).map g = map₂ f' (b.map g') a :=
  by cases a <;> cases b <;> simp [h_antidistrib]
#align option.map_map₂_antidistrib_left Option.map_map₂_antidistrib_left
-/

#print Option.map_map₂_antidistrib_right /-
/-- Symmetric statement to `option.map_map₂_right_anticomm`. -/
theorem map_map₂_antidistrib_right {g : γ → δ} {f' : β → α' → δ} {g' : α → α'}
    (h_antidistrib : ∀ a b, g (f a b) = f' b (g' a)) : (map₂ f a b).map g = map₂ f' b (a.map g') :=
  by cases a <;> cases b <;> simp [h_antidistrib]
#align option.map_map₂_antidistrib_right Option.map_map₂_antidistrib_right
-/

#print Option.map₂_map_left_anticomm /-
/-- Symmetric statement to `option.map_map₂_antidistrib_left`. -/
theorem map₂_map_left_anticomm {f : α' → β → γ} {g : α → α'} {f' : β → α → δ} {g' : δ → γ}
    (h_left_anticomm : ∀ a b, f (g a) b = g' (f' b a)) :
    map₂ f (a.map g) b = (map₂ f' b a).map g' := by cases a <;> cases b <;> simp [h_left_anticomm]
#align option.map₂_map_left_anticomm Option.map₂_map_left_anticomm
-/

#print Option.map_map₂_right_anticomm /-
/-- Symmetric statement to `option.map_map₂_antidistrib_right`. -/
theorem map_map₂_right_anticomm {f : α → β' → γ} {g : β → β'} {f' : β → α → δ} {g' : δ → γ}
    (h_right_anticomm : ∀ a b, f a (g b) = g' (f' b a)) :
    map₂ f a (b.map g) = (map₂ f' b a).map g' := by cases a <;> cases b <;> simp [h_right_anticomm]
#align option.map_map₂_right_anticomm Option.map_map₂_right_anticomm
-/

#print Option.map₂_left_identity /-
/-- If `a` is a left identity for a binary operation `f`, then `some a` is a left identity for
`option.map₂ f`. -/
theorem map₂_left_identity {f : α → β → β} {a : α} (h : ∀ b, f a b = b) (o : Option β) :
    map₂ f (some a) o = o := by cases o; exacts [rfl, congr_arg some (h _)]
#align option.map₂_left_identity Option.map₂_left_identity
-/

#print Option.map₂_right_identity /-
/-- If `b` is a right identity for a binary operation `f`, then `some b` is a right identity for
`option.map₂ f`. -/
theorem map₂_right_identity {f : α → β → α} {b : β} (h : ∀ a, f a b = a) (o : Option α) :
    map₂ f o (some b) = o := by simp [h, map₂]
#align option.map₂_right_identity Option.map₂_right_identity
-/

end Option

