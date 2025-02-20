/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

! This file was ported from Lean 3 source module data.stream.init
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Stream.Defs
import Mathbin.Tactic.Ext
import Mathbin.Logic.Function.Basic

/-!
# Streams a.k.a. infinite lists a.k.a. infinite sequences

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file used to be in the core library. It was moved to `mathlib` and renamed to `init` to avoid
name clashes.  -/


open Nat Function Option

universe u v w

namespace Stream'

variable {α : Type u} {β : Type v} {δ : Type w}

instance {α} [Inhabited α] : Inhabited (Stream' α) :=
  ⟨Stream'.const default⟩

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.eta /-
protected theorem eta (s : Stream' α) : (head s::tail s) = s :=
  funext fun i => by cases i <;> rfl
#align stream.eta Stream'.eta
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.nth_zero_cons /-
@[simp]
theorem nth_zero_cons (a : α) (s : Stream' α) : nth (a::s) 0 = a :=
  rfl
#align stream.nth_zero_cons Stream'.nth_zero_cons
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.head_cons /-
theorem head_cons (a : α) (s : Stream' α) : head (a::s) = a :=
  rfl
#align stream.head_cons Stream'.head_cons
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.tail_cons /-
theorem tail_cons (a : α) (s : Stream' α) : tail (a::s) = s :=
  rfl
#align stream.tail_cons Stream'.tail_cons
-/

#print Stream'.tail_drop /-
theorem tail_drop (n : Nat) (s : Stream' α) : tail (drop n s) = drop n (tail s) :=
  funext fun i => by unfold tail drop; simp [nth, Nat.add_comm, Nat.add_left_comm]
#align stream.tail_drop Stream'.tail_drop
-/

#print Stream'.nth_drop /-
theorem nth_drop (n m : Nat) (s : Stream' α) : nth (drop m s) n = nth s (n + m) :=
  rfl
#align stream.nth_drop Stream'.nth_drop
-/

#print Stream'.tail_eq_drop /-
theorem tail_eq_drop (s : Stream' α) : tail s = drop 1 s :=
  rfl
#align stream.tail_eq_drop Stream'.tail_eq_drop
-/

#print Stream'.drop_drop /-
theorem drop_drop (n m : Nat) (s : Stream' α) : drop n (drop m s) = drop (n + m) s :=
  funext fun i => by unfold drop; rw [Nat.add_assoc]
#align stream.drop_drop Stream'.drop_drop
-/

#print Stream'.nth_succ /-
theorem nth_succ (n : Nat) (s : Stream' α) : nth s (succ n) = nth (tail s) n :=
  rfl
#align stream.nth_succ Stream'.nth_succ
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.nth_succ_cons /-
@[simp]
theorem nth_succ_cons (n : Nat) (s : Stream' α) (x : α) : nth (x::s) n.succ = nth s n :=
  rfl
#align stream.nth_succ_cons Stream'.nth_succ_cons
-/

#print Stream'.drop_succ /-
theorem drop_succ (n : Nat) (s : Stream' α) : drop (succ n) s = drop n (tail s) :=
  rfl
#align stream.drop_succ Stream'.drop_succ
-/

#print Stream'.head_drop /-
@[simp]
theorem head_drop {α} (a : Stream' α) (n : ℕ) : (a.drop n).headI = a.get? n := by
  simp only [drop, head, Nat.zero_add, Stream'.nth]
#align stream.head_drop Stream'.head_drop
-/

#print Stream'.ext /-
@[ext]
protected theorem ext {s₁ s₂ : Stream' α} : (∀ n, nth s₁ n = nth s₂ n) → s₁ = s₂ := fun h =>
  funext h
#align stream.ext Stream'.ext
-/

#print Stream'.cons_injective2 /-
theorem cons_injective2 : Function.Injective2 (cons : α → Stream' α → Stream' α) := fun x y s t h =>
  ⟨by rw [← nth_zero_cons x s, h, nth_zero_cons],
    Stream'.ext fun n => by rw [← nth_succ_cons n _ x, h, nth_succ_cons]⟩
#align stream.cons_injective2 Stream'.cons_injective2
-/

#print Stream'.cons_injective_left /-
theorem cons_injective_left (s : Stream' α) : Function.Injective fun x => cons x s :=
  cons_injective2.left _
#align stream.cons_injective_left Stream'.cons_injective_left
-/

#print Stream'.cons_injective_right /-
theorem cons_injective_right (x : α) : Function.Injective (cons x) :=
  cons_injective2.right _
#align stream.cons_injective_right Stream'.cons_injective_right
-/

#print Stream'.all_def /-
theorem all_def (p : α → Prop) (s : Stream' α) : All p s = ∀ n, p (nth s n) :=
  rfl
#align stream.all_def Stream'.all_def
-/

#print Stream'.any_def /-
theorem any_def (p : α → Prop) (s : Stream' α) : Any p s = ∃ n, p (nth s n) :=
  rfl
#align stream.any_def Stream'.any_def
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.mem_cons /-
theorem mem_cons (a : α) (s : Stream' α) : a ∈ a::s :=
  Exists.intro 0 rfl
#align stream.mem_cons Stream'.mem_cons
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.mem_cons_of_mem /-
theorem mem_cons_of_mem {a : α} {s : Stream' α} (b : α) : a ∈ s → a ∈ b::s := fun ⟨n, h⟩ =>
  Exists.intro (succ n) (by rw [nth_succ, tail_cons, h])
#align stream.mem_cons_of_mem Stream'.mem_cons_of_mem
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.eq_or_mem_of_mem_cons /-
theorem eq_or_mem_of_mem_cons {a b : α} {s : Stream' α} : (a ∈ b::s) → a = b ∨ a ∈ s :=
  fun ⟨n, h⟩ => by
  cases' n with n'
  · left; exact h
  · right; rw [nth_succ, tail_cons] at h ; exact ⟨n', h⟩
#align stream.eq_or_mem_of_mem_cons Stream'.eq_or_mem_of_mem_cons
-/

#print Stream'.mem_of_nth_eq /-
theorem mem_of_nth_eq {n : Nat} {s : Stream' α} {a : α} : a = nth s n → a ∈ s := fun h =>
  Exists.intro n h
#align stream.mem_of_nth_eq Stream'.mem_of_nth_eq
-/

section Map

variable (f : α → β)

#print Stream'.drop_map /-
theorem drop_map (n : Nat) (s : Stream' α) : drop n (map f s) = map f (drop n s) :=
  Stream'.ext fun i => rfl
#align stream.drop_map Stream'.drop_map
-/

#print Stream'.nth_map /-
theorem nth_map (n : Nat) (s : Stream' α) : nth (map f s) n = f (nth s n) :=
  rfl
#align stream.nth_map Stream'.nth_map
-/

#print Stream'.tail_map /-
theorem tail_map (s : Stream' α) : tail (map f s) = map f (tail s) := by rw [tail_eq_drop]; rfl
#align stream.tail_map Stream'.tail_map
-/

#print Stream'.head_map /-
theorem head_map (s : Stream' α) : head (map f s) = f (head s) :=
  rfl
#align stream.head_map Stream'.head_map
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.map_eq /-
theorem map_eq (s : Stream' α) : map f s = f (head s)::map f (tail s) := by
  rw [← Stream'.eta (map f s), tail_map, head_map]
#align stream.map_eq Stream'.map_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.map_cons /-
theorem map_cons (a : α) (s : Stream' α) : map f (a::s) = f a::map f s := by
  rw [← Stream'.eta (map f (a::s)), map_eq]; rfl
#align stream.map_cons Stream'.map_cons
-/

#print Stream'.map_id /-
theorem map_id (s : Stream' α) : map id s = s :=
  rfl
#align stream.map_id Stream'.map_id
-/

#print Stream'.map_map /-
theorem map_map (g : β → δ) (f : α → β) (s : Stream' α) : map g (map f s) = map (g ∘ f) s :=
  rfl
#align stream.map_map Stream'.map_map
-/

#print Stream'.map_tail /-
theorem map_tail (s : Stream' α) : map f (tail s) = tail (map f s) :=
  rfl
#align stream.map_tail Stream'.map_tail
-/

#print Stream'.mem_map /-
theorem mem_map {a : α} {s : Stream' α} : a ∈ s → f a ∈ map f s := fun ⟨n, h⟩ =>
  Exists.intro n (by rw [nth_map, h])
#align stream.mem_map Stream'.mem_map
-/

#print Stream'.exists_of_mem_map /-
theorem exists_of_mem_map {f} {b : β} {s : Stream' α} : b ∈ map f s → ∃ a, a ∈ s ∧ f a = b :=
  fun ⟨n, h⟩ => ⟨nth s n, ⟨n, rfl⟩, h.symm⟩
#align stream.exists_of_mem_map Stream'.exists_of_mem_map
-/

end Map

section Zip

variable (f : α → β → δ)

#print Stream'.drop_zip /-
theorem drop_zip (n : Nat) (s₁ : Stream' α) (s₂ : Stream' β) :
    drop n (zip f s₁ s₂) = zip f (drop n s₁) (drop n s₂) :=
  Stream'.ext fun i => rfl
#align stream.drop_zip Stream'.drop_zip
-/

#print Stream'.nth_zip /-
theorem nth_zip (n : Nat) (s₁ : Stream' α) (s₂ : Stream' β) :
    nth (zip f s₁ s₂) n = f (nth s₁ n) (nth s₂ n) :=
  rfl
#align stream.nth_zip Stream'.nth_zip
-/

#print Stream'.head_zip /-
theorem head_zip (s₁ : Stream' α) (s₂ : Stream' β) : head (zip f s₁ s₂) = f (head s₁) (head s₂) :=
  rfl
#align stream.head_zip Stream'.head_zip
-/

#print Stream'.tail_zip /-
theorem tail_zip (s₁ : Stream' α) (s₂ : Stream' β) :
    tail (zip f s₁ s₂) = zip f (tail s₁) (tail s₂) :=
  rfl
#align stream.tail_zip Stream'.tail_zip
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.zip_eq /-
theorem zip_eq (s₁ : Stream' α) (s₂ : Stream' β) :
    zip f s₁ s₂ = f (head s₁) (head s₂)::zip f (tail s₁) (tail s₂) := by
  rw [← Stream'.eta (zip f s₁ s₂)]; rfl
#align stream.zip_eq Stream'.zip_eq
-/

#print Stream'.nth_enum /-
@[simp]
theorem nth_enum (s : Stream' α) (n : ℕ) : nth (enum s) n = (n, s.get? n) :=
  rfl
#align stream.nth_enum Stream'.nth_enum
-/

#print Stream'.enum_eq_zip /-
theorem enum_eq_zip (s : Stream' α) : enum s = zip Prod.mk nats s :=
  rfl
#align stream.enum_eq_zip Stream'.enum_eq_zip
-/

end Zip

#print Stream'.mem_const /-
theorem mem_const (a : α) : a ∈ const a :=
  Exists.intro 0 rfl
#align stream.mem_const Stream'.mem_const
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.const_eq /-
theorem const_eq (a : α) : const a = a::const a :=
  by
  apply Stream'.ext; intro n
  cases n <;> rfl
#align stream.const_eq Stream'.const_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.tail_const /-
theorem tail_const (a : α) : tail (const a) = const a :=
  suffices tail (a::const a) = const a by rwa [← const_eq] at this 
  rfl
#align stream.tail_const Stream'.tail_const
-/

#print Stream'.map_const /-
theorem map_const (f : α → β) (a : α) : map f (const a) = const (f a) :=
  rfl
#align stream.map_const Stream'.map_const
-/

#print Stream'.nth_const /-
theorem nth_const (n : Nat) (a : α) : nth (const a) n = a :=
  rfl
#align stream.nth_const Stream'.nth_const
-/

#print Stream'.drop_const /-
theorem drop_const (n : Nat) (a : α) : drop n (const a) = const a :=
  Stream'.ext fun i => rfl
#align stream.drop_const Stream'.drop_const
-/

#print Stream'.head_iterate /-
theorem head_iterate (f : α → α) (a : α) : head (iterate f a) = a :=
  rfl
#align stream.head_iterate Stream'.head_iterate
-/

#print Stream'.tail_iterate /-
theorem tail_iterate (f : α → α) (a : α) : tail (iterate f a) = iterate f (f a) :=
  by
  funext n
  induction' n with n' ih
  · rfl
  · unfold tail iterate
    unfold tail iterate at ih 
    rw [add_one] at ih ; dsimp at ih 
    rw [add_one]; dsimp; rw [ih]
#align stream.tail_iterate Stream'.tail_iterate
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.iterate_eq /-
theorem iterate_eq (f : α → α) (a : α) : iterate f a = a::iterate f (f a) :=
  by
  rw [← Stream'.eta (iterate f a)]
  rw [tail_iterate]; rfl
#align stream.iterate_eq Stream'.iterate_eq
-/

#print Stream'.nth_zero_iterate /-
theorem nth_zero_iterate (f : α → α) (a : α) : nth (iterate f a) 0 = a :=
  rfl
#align stream.nth_zero_iterate Stream'.nth_zero_iterate
-/

#print Stream'.nth_succ_iterate /-
theorem nth_succ_iterate (n : Nat) (f : α → α) (a : α) :
    nth (iterate f a) (succ n) = nth (iterate f (f a)) n := by rw [nth_succ, tail_iterate]
#align stream.nth_succ_iterate Stream'.nth_succ_iterate
-/

section Bisim

variable (R : Stream' α → Stream' α → Prop)

local infixl:50 " ~ " => R

#print Stream'.IsBisimulation /-
def IsBisimulation :=
  ∀ ⦃s₁ s₂⦄, s₁ ~ s₂ → head s₁ = head s₂ ∧ tail s₁ ~ tail s₂
#align stream.is_bisimulation Stream'.IsBisimulation
-/

#print Stream'.nth_of_bisim /-
theorem nth_of_bisim (bisim : IsBisimulation R) :
    ∀ {s₁ s₂} (n), s₁ ~ s₂ → nth s₁ n = nth s₂ n ∧ drop (n + 1) s₁ ~ drop (n + 1) s₂
  | s₁, s₂, 0, h => bisim h
  | s₁, s₂, n + 1, h =>
    match bisim h with
    | ⟨h₁, trel⟩ => nth_of_bisim n trel
#align stream.nth_of_bisim Stream'.nth_of_bisim
-/

#print Stream'.eq_of_bisim /-
-- If two streams are bisimilar, then they are equal
theorem eq_of_bisim (bisim : IsBisimulation R) : ∀ {s₁ s₂}, s₁ ~ s₂ → s₁ = s₂ := fun s₁ s₂ r =>
  Stream'.ext fun n => And.left (nth_of_bisim R bisim n r)
#align stream.eq_of_bisim Stream'.eq_of_bisim
-/

end Bisim

#print Stream'.bisim_simple /-
theorem bisim_simple (s₁ s₂ : Stream' α) :
    head s₁ = head s₂ → s₁ = tail s₁ → s₂ = tail s₂ → s₁ = s₂ := fun hh ht₁ ht₂ =>
  eq_of_bisim (fun s₁ s₂ => head s₁ = head s₂ ∧ s₁ = tail s₁ ∧ s₂ = tail s₂)
    (fun s₁ s₂ ⟨h₁, h₂, h₃⟩ => by constructor; exact h₁; rw [← h₂, ← h₃];
      repeat' constructor <;> assumption)
    (And.intro hh (And.intro ht₁ ht₂))
#align stream.bisim_simple Stream'.bisim_simple
-/

#print Stream'.coinduction /-
theorem coinduction {s₁ s₂ : Stream' α} :
    head s₁ = head s₂ →
      (∀ (β : Type u) (fr : Stream' α → β), fr s₁ = fr s₂ → fr (tail s₁) = fr (tail s₂)) →
        s₁ = s₂ :=
  fun hh ht =>
  eq_of_bisim
    (fun s₁ s₂ =>
      head s₁ = head s₂ ∧
        ∀ (β : Type u) (fr : Stream' α → β), fr s₁ = fr s₂ → fr (tail s₁) = fr (tail s₂))
    (fun s₁ s₂ h =>
      have h₁ : head s₁ = head s₂ := And.left h
      have h₂ : head (tail s₁) = head (tail s₂) := And.right h α (@head α) h₁
      have h₃ :
        ∀ (β : Type u) (fr : Stream' α → β),
          fr (tail s₁) = fr (tail s₂) → fr (tail (tail s₁)) = fr (tail (tail s₂)) :=
        fun β fr => And.right h β fun s => fr (tail s)
      And.intro h₁ (And.intro h₂ h₃))
    (And.intro hh ht)
#align stream.coinduction Stream'.coinduction
-/

#print Stream'.iterate_id /-
theorem iterate_id (a : α) : iterate id a = const a :=
  coinduction rfl fun β fr ch => by rw [tail_iterate, tail_const]; exact ch
#align stream.iterate_id Stream'.iterate_id
-/

attribute [local reducible] Stream'

#print Stream'.map_iterate /-
theorem map_iterate (f : α → α) (a : α) : iterate f (f a) = map f (iterate f a) :=
  by
  funext n
  induction' n with n' ih
  · rfl
  · unfold map iterate nth; dsimp
    unfold map iterate nth at ih ; dsimp at ih 
    rw [ih]
#align stream.map_iterate Stream'.map_iterate
-/

section Corec

#print Stream'.corec_def /-
theorem corec_def (f : α → β) (g : α → α) (a : α) : corec f g a = map f (iterate g a) :=
  rfl
#align stream.corec_def Stream'.corec_def
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.corec_eq /-
theorem corec_eq (f : α → β) (g : α → α) (a : α) : corec f g a = f a::corec f g (g a) := by
  rw [corec_def, map_eq, head_iterate, tail_iterate]; rfl
#align stream.corec_eq Stream'.corec_eq
-/

#print Stream'.corec_id_id_eq_const /-
theorem corec_id_id_eq_const (a : α) : corec id id a = const a := by
  rw [corec_def, map_id, iterate_id]
#align stream.corec_id_id_eq_const Stream'.corec_id_id_eq_const
-/

#print Stream'.corec_id_f_eq_iterate /-
theorem corec_id_f_eq_iterate (f : α → α) (a : α) : corec id f a = iterate f a :=
  rfl
#align stream.corec_id_f_eq_iterate Stream'.corec_id_f_eq_iterate
-/

end Corec

section Corec'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.corec'_eq /-
theorem corec'_eq (f : α → β × α) (a : α) : corec' f a = (f a).1::corec' f (f a).2 :=
  corec_eq _ _ _
#align stream.corec'_eq Stream'.corec'_eq
-/

end Corec'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.unfolds_eq /-
theorem unfolds_eq (g : α → β) (f : α → α) (a : α) : unfolds g f a = g a::unfolds g f (f a) := by
  unfold unfolds; rw [corec_eq]
#align stream.unfolds_eq Stream'.unfolds_eq
-/

#print Stream'.nth_unfolds_head_tail /-
theorem nth_unfolds_head_tail :
    ∀ (n : Nat) (s : Stream' α), nth (unfolds head tail s) n = nth s n :=
  by
  intro n; induction' n with n' ih
  · intro s; rfl
  · intro s; rw [nth_succ, nth_succ, unfolds_eq, tail_cons, ih]
#align stream.nth_unfolds_head_tail Stream'.nth_unfolds_head_tail
-/

#print Stream'.unfolds_head_eq /-
theorem unfolds_head_eq : ∀ s : Stream' α, unfolds head tail s = s := fun s =>
  Stream'.ext fun n => nth_unfolds_head_tail n s
#align stream.unfolds_head_eq Stream'.unfolds_head_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.interleave_eq /-
theorem interleave_eq (s₁ s₂ : Stream' α) : s₁ ⋈ s₂ = head s₁::head s₂::tail s₁ ⋈ tail s₂ := by
  unfold interleave corec_on; rw [corec_eq]; dsimp; rw [corec_eq]; rfl
#align stream.interleave_eq Stream'.interleave_eq
-/

#print Stream'.tail_interleave /-
theorem tail_interleave (s₁ s₂ : Stream' α) : tail (s₁ ⋈ s₂) = s₂ ⋈ tail s₁ := by
  unfold interleave corec_on; rw [corec_eq]; rfl
#align stream.tail_interleave Stream'.tail_interleave
-/

#print Stream'.interleave_tail_tail /-
theorem interleave_tail_tail (s₁ s₂ : Stream' α) : tail s₁ ⋈ tail s₂ = tail (tail (s₁ ⋈ s₂)) := by
  rw [interleave_eq s₁ s₂]; rfl
#align stream.interleave_tail_tail Stream'.interleave_tail_tail
-/

#print Stream'.nth_interleave_left /-
theorem nth_interleave_left : ∀ (n : Nat) (s₁ s₂ : Stream' α), nth (s₁ ⋈ s₂) (2 * n) = nth s₁ n
  | 0, s₁, s₂ => rfl
  | succ n, s₁, s₂ =>
    by
    change nth (s₁ ⋈ s₂) (succ (succ (2 * n))) = nth s₁ (succ n)
    rw [nth_succ, nth_succ, interleave_eq, tail_cons, tail_cons, nth_interleave_left]
    rfl
#align stream.nth_interleave_left Stream'.nth_interleave_left
-/

#print Stream'.nth_interleave_right /-
theorem nth_interleave_right : ∀ (n : Nat) (s₁ s₂ : Stream' α), nth (s₁ ⋈ s₂) (2 * n + 1) = nth s₂ n
  | 0, s₁, s₂ => rfl
  | succ n, s₁, s₂ =>
    by
    change nth (s₁ ⋈ s₂) (succ (succ (2 * n + 1))) = nth s₂ (succ n)
    rw [nth_succ, nth_succ, interleave_eq, tail_cons, tail_cons, nth_interleave_right]
    rfl
#align stream.nth_interleave_right Stream'.nth_interleave_right
-/

#print Stream'.mem_interleave_left /-
theorem mem_interleave_left {a : α} {s₁ : Stream' α} (s₂ : Stream' α) : a ∈ s₁ → a ∈ s₁ ⋈ s₂ :=
  fun ⟨n, h⟩ => Exists.intro (2 * n) (by rw [h, nth_interleave_left])
#align stream.mem_interleave_left Stream'.mem_interleave_left
-/

#print Stream'.mem_interleave_right /-
theorem mem_interleave_right {a : α} {s₁ : Stream' α} (s₂ : Stream' α) : a ∈ s₂ → a ∈ s₁ ⋈ s₂ :=
  fun ⟨n, h⟩ => Exists.intro (2 * n + 1) (by rw [h, nth_interleave_right])
#align stream.mem_interleave_right Stream'.mem_interleave_right
-/

#print Stream'.odd_eq /-
theorem odd_eq (s : Stream' α) : odd s = even (tail s) :=
  rfl
#align stream.odd_eq Stream'.odd_eq
-/

#print Stream'.head_even /-
theorem head_even (s : Stream' α) : head (even s) = head s :=
  rfl
#align stream.head_even Stream'.head_even
-/

#print Stream'.tail_even /-
theorem tail_even (s : Stream' α) : tail (even s) = even (tail (tail s)) := by unfold Even;
  rw [corec_eq]; rfl
#align stream.tail_even Stream'.tail_even
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.even_cons_cons /-
theorem even_cons_cons (a₁ a₂ : α) (s : Stream' α) : even (a₁::a₂::s) = a₁::even s := by
  unfold Even; rw [corec_eq]; rfl
#align stream.even_cons_cons Stream'.even_cons_cons
-/

#print Stream'.even_tail /-
theorem even_tail (s : Stream' α) : even (tail s) = odd s :=
  rfl
#align stream.even_tail Stream'.even_tail
-/

#print Stream'.even_interleave /-
theorem even_interleave (s₁ s₂ : Stream' α) : even (s₁ ⋈ s₂) = s₁ :=
  eq_of_bisim (fun s₁' s₁ => ∃ s₂, s₁' = even (s₁ ⋈ s₂))
    (fun s₁' s₁ ⟨s₂, h₁⟩ => by
      rw [h₁]
      constructor
      · rfl
      · exact ⟨tail s₂, by rw [interleave_eq, even_cons_cons, tail_cons]⟩)
    (Exists.intro s₂ rfl)
#align stream.even_interleave Stream'.even_interleave
-/

#print Stream'.interleave_even_odd /-
theorem interleave_even_odd (s₁ : Stream' α) : even s₁ ⋈ odd s₁ = s₁ :=
  eq_of_bisim (fun s' s => s' = even s ⋈ odd s)
    (fun s' s (h : s' = even s ⋈ odd s) => by
      rw [h]; constructor
      · rfl
      · simp [odd_eq, odd_eq, tail_interleave, tail_even])
    rfl
#align stream.interleave_even_odd Stream'.interleave_even_odd
-/

#print Stream'.nth_even /-
theorem nth_even : ∀ (n : Nat) (s : Stream' α), nth (even s) n = nth s (2 * n)
  | 0, s => rfl
  | succ n, s => by
    change nth (Even s) (succ n) = nth s (succ (succ (2 * n)))
    rw [nth_succ, nth_succ, tail_even, nth_even]; rfl
#align stream.nth_even Stream'.nth_even
-/

#print Stream'.nth_odd /-
theorem nth_odd : ∀ (n : Nat) (s : Stream' α), nth (odd s) n = nth s (2 * n + 1) := fun n s => by
  rw [odd_eq, nth_even]; rfl
#align stream.nth_odd Stream'.nth_odd
-/

#print Stream'.mem_of_mem_even /-
theorem mem_of_mem_even (a : α) (s : Stream' α) : a ∈ even s → a ∈ s := fun ⟨n, h⟩ =>
  Exists.intro (2 * n) (by rw [h, nth_even])
#align stream.mem_of_mem_even Stream'.mem_of_mem_even
-/

#print Stream'.mem_of_mem_odd /-
theorem mem_of_mem_odd (a : α) (s : Stream' α) : a ∈ odd s → a ∈ s := fun ⟨n, h⟩ =>
  Exists.intro (2 * n + 1) (by rw [h, nth_odd])
#align stream.mem_of_mem_odd Stream'.mem_of_mem_odd
-/

#print Stream'.nil_append_stream /-
theorem nil_append_stream (s : Stream' α) : appendStream' [] s = s :=
  rfl
#align stream.nil_append_stream Stream'.nil_append_stream
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.cons_append_stream /-
theorem cons_append_stream (a : α) (l : List α) (s : Stream' α) :
    appendStream' (a::l) s = a::appendStream' l s :=
  rfl
#align stream.cons_append_stream Stream'.cons_append_stream
-/

#print Stream'.append_append_stream /-
theorem append_append_stream :
    ∀ (l₁ l₂ : List α) (s : Stream' α), l₁ ++ l₂ ++ₛ s = l₁ ++ₛ (l₂ ++ₛ s)
  | [], l₂, s => rfl
  | List.cons a l₁, l₂, s => by
    rw [List.cons_append, cons_append_stream, cons_append_stream, append_append_stream]
#align stream.append_append_stream Stream'.append_append_stream
-/

#print Stream'.map_append_stream /-
theorem map_append_stream (f : α → β) :
    ∀ (l : List α) (s : Stream' α), map f (l ++ₛ s) = List.map f l ++ₛ map f s
  | [], s => rfl
  | List.cons a l, s => by
    rw [cons_append_stream, List.map_cons, map_cons, cons_append_stream, map_append_stream]
#align stream.map_append_stream Stream'.map_append_stream
-/

#print Stream'.drop_append_stream /-
theorem drop_append_stream : ∀ (l : List α) (s : Stream' α), drop l.length (l ++ₛ s) = s
  | [], s => by rfl
  | List.cons a l, s => by
    rw [List.length_cons, add_one, drop_succ, cons_append_stream, tail_cons, drop_append_stream]
#align stream.drop_append_stream Stream'.drop_append_stream
-/

#print Stream'.append_stream_head_tail /-
theorem append_stream_head_tail (s : Stream' α) : [head s] ++ₛ tail s = s := by
  rw [cons_append_stream, nil_append_stream, Stream'.eta]
#align stream.append_stream_head_tail Stream'.append_stream_head_tail
-/

#print Stream'.mem_append_stream_right /-
theorem mem_append_stream_right : ∀ {a : α} (l : List α) {s : Stream' α}, a ∈ s → a ∈ l ++ₛ s
  | a, [], s, h => h
  | a, List.cons b l, s, h =>
    have ih : a ∈ l ++ₛ s := mem_append_stream_right l h
    mem_cons_of_mem _ ih
#align stream.mem_append_stream_right Stream'.mem_append_stream_right
-/

#print Stream'.mem_append_stream_left /-
theorem mem_append_stream_left : ∀ {a : α} {l : List α} (s : Stream' α), a ∈ l → a ∈ l ++ₛ s
  | a, [], s, h => absurd h (List.not_mem_nil _)
  | a, List.cons b l, s, h =>
    Or.elim (List.eq_or_mem_of_mem_cons h) (fun aeqb : a = b => Exists.intro 0 aeqb)
      fun ainl : a ∈ l => mem_cons_of_mem b (mem_append_stream_left s ainl)
#align stream.mem_append_stream_left Stream'.mem_append_stream_left
-/

#print Stream'.take_zero /-
@[simp]
theorem take_zero (s : Stream' α) : take 0 s = [] :=
  rfl
#align stream.take_zero Stream'.take_zero
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.take_succ /-
@[simp]
theorem take_succ (n : Nat) (s : Stream' α) : take (succ n) s = head s::take n (tail s) :=
  rfl
#align stream.take_succ Stream'.take_succ
-/

#print Stream'.length_take /-
@[simp]
theorem length_take (n : ℕ) (s : Stream' α) : (take n s).length = n := by
  induction n generalizing s <;> simp [*]
#align stream.length_take Stream'.length_take
-/

#print Stream'.get?_take_succ /-
theorem get?_take_succ : ∀ (n : Nat) (s : Stream' α), List.get? (take (succ n) s) n = some (nth s n)
  | 0, s => rfl
  | n + 1, s => by rw [take_succ, add_one, List.get?, nth_take_succ]; rfl
#align stream.nth_take_succ Stream'.get?_take_succ
-/

#print Stream'.append_take_drop /-
theorem append_take_drop : ∀ (n : Nat) (s : Stream' α), appendStream' (take n s) (drop n s) = s :=
  by
  intro n
  induction' n with n' ih
  · intro s; rfl
  · intro s; rw [take_succ, drop_succ, cons_append_stream, ih (tail s), Stream'.eta]
#align stream.append_take_drop Stream'.append_take_drop
-/

#print Stream'.take_theorem /-
-- Take theorem reduces a proof of equality of infinite streams to an
-- induction over all their finite approximations.
theorem take_theorem (s₁ s₂ : Stream' α) : (∀ n : Nat, take n s₁ = take n s₂) → s₁ = s₂ :=
  by
  intro h; apply Stream'.ext; intro n
  induction' n with n ih
  · have aux := h 1; simp [take] at aux ; exact aux
  · have h₁ : some (nth s₁ (succ n)) = some (nth s₂ (succ n)) := by
      rw [← nth_take_succ, ← nth_take_succ, h (succ (succ n))]
    injection h₁
#align stream.take_theorem Stream'.take_theorem
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.cycle_g_cons /-
protected theorem cycle_g_cons (a : α) (a₁ : α) (l₁ : List α) (a₀ : α) (l₀ : List α) :
    Stream'.cycleG (a, a₁::l₁, a₀, l₀) = (a₁, l₁, a₀, l₀) :=
  rfl
#align stream.cycle_g_cons Stream'.cycle_g_cons
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.cycle_eq /-
theorem cycle_eq : ∀ (l : List α) (h : l ≠ []), cycle l h = l ++ₛ cycle l h
  | [], h => absurd rfl h
  | List.cons a l, h =>
    have gen :
      ∀ l' a',
        corec Stream'.cycleF Stream'.cycleG (a', l', a, l) =
          (a'::l') ++ₛ corec Stream'.cycleF Stream'.cycleG (a, l, a, l) :=
      by
      intro l'
      induction' l' with a₁ l₁ ih
      · intros; rw [corec_eq]; rfl
      · intros; rw [corec_eq, Stream'.cycle_g_cons, ih a₁]; rfl
    gen l a
#align stream.cycle_eq Stream'.cycle_eq
-/

#print Stream'.mem_cycle /-
theorem mem_cycle {a : α} {l : List α} : ∀ h : l ≠ [], a ∈ l → a ∈ cycle l h := fun h ainl => by
  rw [cycle_eq]; exact mem_append_stream_left _ ainl
#align stream.mem_cycle Stream'.mem_cycle
-/

#print Stream'.cycle_singleton /-
theorem cycle_singleton (a : α) (h : [a] ≠ []) : cycle [a] h = const a :=
  coinduction rfl fun β fr ch => by rwa [cycle_eq, const_eq]
#align stream.cycle_singleton Stream'.cycle_singleton
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.tails_eq /-
theorem tails_eq (s : Stream' α) : tails s = tail s::tails (tail s) := by
  unfold tails <;> rw [corec_eq] <;> rfl
#align stream.tails_eq Stream'.tails_eq
-/

#print Stream'.nth_tails /-
theorem nth_tails : ∀ (n : Nat) (s : Stream' α), nth (tails s) n = drop n (tail s) :=
  by
  intro n; induction' n with n' ih
  · intros; rfl
  · intro s; rw [nth_succ, drop_succ, tails_eq, tail_cons, ih]
#align stream.nth_tails Stream'.nth_tails
-/

#print Stream'.tails_eq_iterate /-
theorem tails_eq_iterate (s : Stream' α) : tails s = iterate tail (tail s) :=
  rfl
#align stream.tails_eq_iterate Stream'.tails_eq_iterate
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.inits_core_eq /-
theorem inits_core_eq (l : List α) (s : Stream' α) :
    initsCore l s = l::initsCore (l ++ [head s]) (tail s) := by unfold inits_core corec_on;
  rw [corec_eq]; rfl
#align stream.inits_core_eq Stream'.inits_core_eq
-/

#print Stream'.tail_inits /-
theorem tail_inits (s : Stream' α) :
    tail (inits s) = initsCore [head s, head (tail s)] (tail (tail s)) := by unfold inits;
  rw [inits_core_eq]; rfl
#align stream.tail_inits Stream'.tail_inits
-/

#print Stream'.inits_tail /-
theorem inits_tail (s : Stream' α) : inits (tail s) = initsCore [head (tail s)] (tail (tail s)) :=
  rfl
#align stream.inits_tail Stream'.inits_tail
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.cons_nth_inits_core /-
theorem cons_nth_inits_core :
    ∀ (a : α) (n : Nat) (l : List α) (s : Stream' α),
      (a::nth (initsCore l s) n) = nth (initsCore (a::l) s) n :=
  by
  intro a n
  induction' n with n' ih
  · intros; rfl
  · intro l s; rw [nth_succ, inits_core_eq, tail_cons, ih, inits_core_eq (a::l) s]; rfl
#align stream.cons_nth_inits_core Stream'.cons_nth_inits_core
-/

#print Stream'.nth_inits /-
theorem nth_inits : ∀ (n : Nat) (s : Stream' α), nth (inits s) n = take (succ n) s :=
  by
  intro n; induction' n with n' ih
  · intros; rfl
  · intros; rw [nth_succ, take_succ, ← ih, tail_inits, inits_tail, cons_nth_inits_core]
#align stream.nth_inits Stream'.nth_inits
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.inits_eq /-
theorem inits_eq (s : Stream' α) : inits s = [head s]::map (List.cons (head s)) (inits (tail s)) :=
  by
  apply Stream'.ext; intro n
  cases n
  · rfl
  · rw [nth_inits, nth_succ, tail_cons, nth_map, nth_inits]; rfl
#align stream.inits_eq Stream'.inits_eq
-/

#print Stream'.zip_inits_tails /-
theorem zip_inits_tails (s : Stream' α) : zip appendStream' (inits s) (tails s) = const s :=
  by
  apply Stream'.ext; intro n
  rw [nth_zip, nth_inits, nth_tails, nth_const, take_succ, cons_append_stream, append_take_drop,
    Stream'.eta]
#align stream.zip_inits_tails Stream'.zip_inits_tails
-/

#print Stream'.identity /-
theorem identity (s : Stream' α) : pure id ⊛ s = s :=
  rfl
#align stream.identity Stream'.identity
-/

#print Stream'.composition /-
theorem composition (g : Stream' (β → δ)) (f : Stream' (α → β)) (s : Stream' α) :
    pure comp ⊛ g ⊛ f ⊛ s = g ⊛ (f ⊛ s) :=
  rfl
#align stream.composition Stream'.composition
-/

#print Stream'.homomorphism /-
theorem homomorphism (f : α → β) (a : α) : pure f ⊛ pure a = pure (f a) :=
  rfl
#align stream.homomorphism Stream'.homomorphism
-/

#print Stream'.interchange /-
theorem interchange (fs : Stream' (α → β)) (a : α) :
    fs ⊛ pure a = (pure fun f : α → β => f a) ⊛ fs :=
  rfl
#align stream.interchange Stream'.interchange
-/

#print Stream'.map_eq_apply /-
theorem map_eq_apply (f : α → β) (s : Stream' α) : map f s = pure f ⊛ s :=
  rfl
#align stream.map_eq_apply Stream'.map_eq_apply
-/

#print Stream'.nth_nats /-
theorem nth_nats (n : Nat) : nth nats n = n :=
  rfl
#align stream.nth_nats Stream'.nth_nats
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Stream'.nats_eq /-
theorem nats_eq : nats = 0::map succ nats :=
  by
  apply Stream'.ext; intro n
  cases n; rfl; rw [nth_succ]; rfl
#align stream.nats_eq Stream'.nats_eq
-/

end Stream'

