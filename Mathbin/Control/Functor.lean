/-
Copyright (c) 2017 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.functor
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Lint.Default
import Mathbin.Control.Basic

/-!
# Functors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This module provides additional lemmas, definitions, and instances for `functor`s.

## Main definitions

* `const α` is the functor that sends all types to `α`.
* `add_const α` is `const α` but for when `α` has an additive structure.
* `comp F G` for functors `F` and `G` is the functor composition of `F` and `G`.
* `liftp` and `liftr` respectively lift predicates and relations on a type `α`
  to `F α`.  Terms of `F α` are considered to, in some sense, contain values of type `α`.

## Tags

functor, applicative
-/


attribute [functor_norm] seq_assoc pure_seq_eq_map map_pure seq_map_assoc map_seq

universe u v w

section Functor

variable {F : Type u → Type v}

variable {α β γ : Type u}

variable [Functor F] [LawfulFunctor F]

#print Functor.map_id /-
theorem Functor.map_id : (· <$> ·) id = (id : F α → F α) := by apply funext <;> apply id_map
#align functor.map_id Functor.map_id
-/

#print Functor.map_comp_map /-
theorem Functor.map_comp_map (f : α → β) (g : β → γ) :
    ((· <$> ·) g ∘ (· <$> ·) f : F α → F γ) = (· <$> ·) (g ∘ f) := by
  apply funext <;> intro <;> rw [comp_map]
#align functor.map_comp_map Functor.map_comp_map
-/

#print Functor.ext /-
theorem Functor.ext {F} :
    ∀ {F1 : Functor F} {F2 : Functor F} [@LawfulFunctor F F1] [@LawfulFunctor F F2]
      (H : ∀ (α β) (f : α → β) (x : F α), @Functor.map _ F1 _ _ f x = @Functor.map _ F2 _ _ f x),
      F1 = F2
  | ⟨m, mc⟩, ⟨m', mc'⟩, H1, H2, H =>
    by
    cases show @m = @m' by funext α β f x <;> apply H
    congr; funext α β
    have E1 := @map_const_eq _ ⟨@m, @mc⟩ H1
    have E2 := @map_const_eq _ ⟨@m, @mc'⟩ H2
    exact E1.trans E2.symm
#align functor.ext Functor.ext
-/

end Functor

#print id.mk /-
/-- Introduce the `id` functor. Incidentally, this is `pure` for
`id` as a `monad` and as an `applicative` functor. -/
def id.mk {α : Sort u} : α → id α :=
  id
#align id.mk id.mk
-/

namespace Functor

#print Functor.Const /-
/-- `const α` is the constant functor, mapping every type to `α`. When
`α` has a monoid structure, `const α` has an `applicative` instance.
(If `α` has an additive monoid structure, see `functor.add_const`.) -/
@[nolint unused_arguments]
def Const (α : Type _) (β : Type _) :=
  α
#align functor.const Functor.Const
-/

#print Functor.Const.mk /-
/-- `const.mk` is the canonical map `α → const α β` (the identity), and
it can be used as a pattern to extract this value. -/
@[match_pattern]
def Const.mk {α β} (x : α) : Const α β :=
  x
#align functor.const.mk Functor.Const.mk
-/

#print Functor.Const.mk' /-
/-- `const.mk'` is `const.mk` but specialized to map `α` to
`const α punit`, where `punit` is the terminal object in `Type*`. -/
def Const.mk' {α} (x : α) : Const α PUnit :=
  x
#align functor.const.mk' Functor.Const.mk'
-/

#print Functor.Const.run /-
/-- Extract the element of `α` from the `const` functor. -/
def Const.run {α β} (x : Const α β) : α :=
  x
#align functor.const.run Functor.Const.run
-/

namespace Const

#print Functor.Const.ext /-
protected theorem ext {α β} {x y : Const α β} (h : x.run = y.run) : x = y :=
  h
#align functor.const.ext Functor.Const.ext
-/

#print Functor.Const.map /-
/-- The map operation of the `const γ` functor. -/
@[nolint unused_arguments]
protected def map {γ α β} (f : α → β) (x : Const γ β) : Const γ α :=
  x
#align functor.const.map Functor.Const.map
-/

instance {γ} : Functor (Const γ) where map := @Const.map γ

instance {γ} : LawfulFunctor (Const γ) := by constructor <;> intros <;> rfl

instance {α β} [Inhabited α] : Inhabited (Const α β) :=
  ⟨(default : α)⟩

end Const

#print Functor.AddConst /-
/-- `add_const α` is a synonym for constant functor `const α`, mapping
every type to `α`. When `α` has a additive monoid structure,
`add_const α` has an `applicative` instance. (If `α` has a
multiplicative monoid structure, see `functor.const`.) -/
def AddConst (α : Type _) :=
  Const α
#align functor.add_const Functor.AddConst
-/

#print Functor.AddConst.mk /-
/-- `add_const.mk` is the canonical map `α → add_const α β`, which is the identity,
where `add_const α β = const α β`. It can be used as a pattern to extract this value. -/
@[match_pattern]
def AddConst.mk {α β} (x : α) : AddConst α β :=
  x
#align functor.add_const.mk Functor.AddConst.mk
-/

#print Functor.AddConst.run /-
/-- Extract the element of `α` from the constant functor. -/
def AddConst.run {α β} : AddConst α β → α :=
  id
#align functor.add_const.run Functor.AddConst.run
-/

#print Functor.AddConst.functor /-
instance AddConst.functor {γ} : Functor (AddConst γ) :=
  @Const.functor γ
#align functor.add_const.functor Functor.AddConst.functor
-/

#print Functor.AddConst.lawfulFunctor /-
instance AddConst.lawfulFunctor {γ} : LawfulFunctor (AddConst γ) :=
  @Const.lawfulFunctor γ
#align functor.add_const.is_lawful_functor Functor.AddConst.lawfulFunctor
-/

instance {α β} [Inhabited α] : Inhabited (AddConst α β) :=
  ⟨(default : α)⟩

#print Functor.Comp /-
/-- `functor.comp` is a wrapper around `function.comp` for types.
    It prevents Lean's type class resolution mechanism from trying
    a `functor (comp F id)` when `functor F` would do. -/
def Comp (F : Type u → Type w) (G : Type v → Type u) (α : Type v) : Type w :=
  F <| G α
#align functor.comp Functor.Comp
-/

#print Functor.Comp.mk /-
/-- Construct a term of `comp F G α` from a term of `F (G α)`, which is the same type.
Can be used as a pattern to extract a term of `F (G α)`. -/
@[match_pattern]
def Comp.mk {F : Type u → Type w} {G : Type v → Type u} {α : Type v} (x : F (G α)) : Comp F G α :=
  x
#align functor.comp.mk Functor.Comp.mk
-/

#print Functor.Comp.run /-
/-- Extract a term of `F (G α)` from a term of `comp F G α`, which is the same type. -/
def Comp.run {F : Type u → Type w} {G : Type v → Type u} {α : Type v} (x : Comp F G α) : F (G α) :=
  x
#align functor.comp.run Functor.Comp.run
-/

namespace Comp

variable {F : Type u → Type w} {G : Type v → Type u}

#print Functor.Comp.ext /-
protected theorem ext {α} {x y : Comp F G α} : x.run = y.run → x = y :=
  id
#align functor.comp.ext Functor.Comp.ext
-/

instance {α} [Inhabited (F (G α))] : Inhabited (Comp F G α) :=
  ⟨(default : F (G α))⟩

variable [Functor F] [Functor G]

#print Functor.Comp.map /-
/-- The map operation for the composition `comp F G` of functors `F` and `G`. -/
protected def map {α β : Type v} (h : α → β) : Comp F G α → Comp F G β
  | comp.mk x => Comp.mk ((· <$> ·) h <$> x)
#align functor.comp.map Functor.Comp.map
-/

instance : Functor (Comp F G) where map := @Comp.map F G _ _

#print Functor.Comp.map_mk /-
@[functor_norm]
theorem map_mk {α β} (h : α → β) (x : F (G α)) : h <$> Comp.mk x = Comp.mk ((· <$> ·) h <$> x) :=
  rfl
#align functor.comp.map_mk Functor.Comp.map_mk
-/

#print Functor.Comp.run_map /-
@[simp]
protected theorem run_map {α β} (h : α → β) (x : Comp F G α) :
    (h <$> x).run = (· <$> ·) h <$> x.run :=
  rfl
#align functor.comp.run_map Functor.Comp.run_map
-/

variable [LawfulFunctor F] [LawfulFunctor G]

variable {α β γ : Type v}

#print Functor.Comp.id_map /-
protected theorem id_map : ∀ x : Comp F G α, Comp.map id x = x
  | comp.mk x => by simp [comp.map, Functor.map_id]
#align functor.comp.id_map Functor.Comp.id_map
-/

#print Functor.Comp.comp_map /-
protected theorem comp_map (g' : α → β) (h : β → γ) :
    ∀ x : Comp F G α, Comp.map (h ∘ g') x = Comp.map h (Comp.map g' x)
  | comp.mk x => by simp [comp.map, Functor.map_comp_map g' h, functor_norm]
#align functor.comp.comp_map Functor.Comp.comp_map
-/

instance : LawfulFunctor (Comp F G)
    where
  id_map := @Comp.id_map F G _ _ _ _
  comp_map := @Comp.comp_map F G _ _ _ _

#print Functor.Comp.functor_comp_id /-
theorem functor_comp_id {F} [AF : Functor F] [LawfulFunctor F] : @Comp.functor F id _ _ = AF :=
  @Functor.ext F _ AF (@Comp.lawfulFunctor F id _ _ _ _) _ fun α β f x => rfl
#align functor.comp.functor_comp_id Functor.Comp.functor_comp_id
-/

#print Functor.Comp.functor_id_comp /-
theorem functor_id_comp {F} [AF : Functor F] [LawfulFunctor F] : @Comp.functor id F _ _ = AF :=
  @Functor.ext F _ AF (@Comp.lawfulFunctor id F _ _ _ _) _ fun α β f x => rfl
#align functor.comp.functor_id_comp Functor.Comp.functor_id_comp
-/

end Comp

namespace Comp

open Function hiding comp

open Functor

variable {F : Type u → Type w} {G : Type v → Type u}

variable [Applicative F] [Applicative G]

/-- The `<*>` operation for the composition of applicative functors. -/
protected def seq {α β : Type v} : Comp F G (α → β) → Comp F G α → Comp F G β
  | comp.mk f, comp.mk x => Comp.mk <| (· <*> ·) <$> f <*> x
#align functor.comp.seq Functor.Comp.seqₓ

instance : Pure (Comp F G) :=
  ⟨fun _ x => Comp.mk <| pure <| pure x⟩

instance : Seq (Comp F G) :=
  ⟨fun _ _ f x => Comp.seq f x⟩

#print Functor.Comp.run_pure /-
@[simp]
protected theorem run_pure {α : Type v} : ∀ x : α, (pure x : Comp F G α).run = pure (pure x)
  | _ => rfl
#align functor.comp.run_pure Functor.Comp.run_pure
-/

#print Functor.Comp.run_seq /-
@[simp]
protected theorem run_seq {α β : Type v} (f : Comp F G (α → β)) (x : Comp F G α) :
    (f <*> x).run = (· <*> ·) <$> f.run <*> x.run :=
  rfl
#align functor.comp.run_seq Functor.Comp.run_seq
-/

instance : Applicative (Comp F G) :=
  { Comp.hasPure with
    map := @Comp.map F G _ _
    seq := @Comp.seq F G _ _ }

end Comp

variable {F : Type u → Type u} [Functor F]

#print Functor.Liftp /-
/-- If we consider `x : F α` to, in some sense, contain values of type `α`,
predicate `liftp p x` holds iff every value contained by `x` satisfies `p`. -/
def Liftp {α : Type u} (p : α → Prop) (x : F α) : Prop :=
  ∃ u : F (Subtype p), Subtype.val <$> u = x
#align functor.liftp Functor.Liftp
-/

#print Functor.Liftr /-
/-- If we consider `x : F α` to, in some sense, contain values of type `α`, then
`liftr r x y` relates `x` and `y` iff (1) `x` and `y` have the same shape and
(2) we can pair values `a` from `x` and `b` from `y` so that `r a b` holds. -/
def Liftr {α : Type u} (r : α → α → Prop) (x y : F α) : Prop :=
  ∃ u : F { p : α × α // r p.fst p.snd },
    (fun t : { p : α × α // r p.fst p.snd } => t.val.fst) <$> u = x ∧
      (fun t : { p : α × α // r p.fst p.snd } => t.val.snd) <$> u = y
#align functor.liftr Functor.Liftr
-/

#print Functor.supp /-
/-- If we consider `x : F α` to, in some sense, contain values of type `α`, then
`supp x` is the set of values of type `α` that `x` contains. -/
def supp {α : Type u} (x : F α) : Set α :=
  {y : α | ∀ ⦃p⦄, Liftp p x → p y}
#align functor.supp Functor.supp
-/

#print Functor.of_mem_supp /-
theorem of_mem_supp {α : Type u} {x : F α} {p : α → Prop} (h : Liftp p x) : ∀ y ∈ supp x, p y :=
  fun y hy => hy h
#align functor.of_mem_supp Functor.of_mem_supp
-/

end Functor

