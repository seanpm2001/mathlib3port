/-
Copyright (c) 2018 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module data.pfunctor.univariate.basic
! leanprover-community/mathlib commit a11f9106a169dd302a285019e5165f8ab32ff433
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.W.Basic

/-!
# Polynomial functors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines polynomial functors and the W-type construction as a
polynomial functor.  (For the M-type construction, see
pfunctor/M.lean.)
-/


universe u

#print PFunctor /-
/-- A polynomial functor `P` is given by a type `A` and a family `B` of types over `A`. `P` maps
any type `α` to a new type `P.obj α`, which is defined as the sigma type `Σ x, P.B x → α`.

An element of `P.obj α` is a pair `⟨a, f⟩`, where `a` is an element of a type `A` and
`f : B a → α`. Think of `a` as the shape of the object and `f` as an index to the relevant
elements of `α`.
-/
structure PFunctor where
  A : Type u
  B : A → Type u
#align pfunctor PFunctor
-/

namespace PFunctor

instance : Inhabited PFunctor :=
  ⟨⟨default, default⟩⟩

variable (P : PFunctor) {α β : Type u}

#print PFunctor.Obj /-
/-- Applying `P` to an object of `Type` -/
def Obj (α : Type _) :=
  Σ x : P.A, P.B x → α
#align pfunctor.obj PFunctor.Obj
-/

#print PFunctor.map /-
/-- Applying `P` to a morphism of `Type` -/
def map {α β : Type _} (f : α → β) : P.Obj α → P.Obj β := fun ⟨a, g⟩ => ⟨a, f ∘ g⟩
#align pfunctor.map PFunctor.map
-/

#print PFunctor.Obj.inhabited /-
instance Obj.inhabited [Inhabited P.A] [Inhabited α] : Inhabited (P.Obj α) :=
  ⟨⟨default, default⟩⟩
#align pfunctor.obj.inhabited PFunctor.Obj.inhabited
-/

instance : Functor P.Obj where map := @map P

#print PFunctor.map_eq /-
protected theorem map_eq {α β : Type _} (f : α → β) (a : P.A) (g : P.B a → α) :
    @Functor.map P.Obj _ _ _ f ⟨a, g⟩ = ⟨a, f ∘ g⟩ :=
  rfl
#align pfunctor.map_eq PFunctor.map_eq
-/

#print PFunctor.id_map /-
protected theorem id_map {α : Type _} : ∀ x : P.Obj α, id <$> x = id x := fun ⟨a, b⟩ => rfl
#align pfunctor.id_map PFunctor.id_map
-/

#print PFunctor.comp_map /-
protected theorem comp_map {α β γ : Type _} (f : α → β) (g : β → γ) :
    ∀ x : P.Obj α, (g ∘ f) <$> x = g <$> f <$> x := fun ⟨a, b⟩ => rfl
#align pfunctor.comp_map PFunctor.comp_map
-/

instance : LawfulFunctor P.Obj where
  id_map := @PFunctor.id_map P
  comp_map := @PFunctor.comp_map P

#print PFunctor.W /-
/-- re-export existing definition of W-types and
adapt it to a packaged definition of polynomial functor -/
def W :=
  WType P.B
#align pfunctor.W PFunctor.W
-/

/- inhabitants of W types is awkward to encode as an instance
assumption because there needs to be a value `a : P.A`
such that `P.B a` is empty to yield a finite tree -/
attribute [nolint has_nonempty_instance] W

variable {P}

#print PFunctor.W.head /-
/-- root element  of a W tree -/
def W.head : W P → P.A
  | ⟨a, f⟩ => a
#align pfunctor.W.head PFunctor.W.head
-/

#print PFunctor.W.children /-
/-- children of the root of a W tree -/
def W.children : ∀ x : W P, P.B (W.head x) → W P
  | ⟨a, f⟩ => f
#align pfunctor.W.children PFunctor.W.children
-/

#print PFunctor.W.dest /-
/-- destructor for W-types -/
def W.dest : W P → P.Obj (W P)
  | ⟨a, f⟩ => ⟨a, f⟩
#align pfunctor.W.dest PFunctor.W.dest
-/

#print PFunctor.W.mk /-
/-- constructor for W-types -/
def W.mk : P.Obj (W P) → W P
  | ⟨a, f⟩ => ⟨a, f⟩
#align pfunctor.W.mk PFunctor.W.mk
-/

#print PFunctor.W.dest_mk /-
@[simp]
theorem W.dest_mk (p : P.Obj (W P)) : W.dest (W.mk p) = p := by cases p <;> rfl
#align pfunctor.W.dest_mk PFunctor.W.dest_mk
-/

#print PFunctor.W.mk_dest /-
@[simp]
theorem W.mk_dest (p : W P) : W.mk (W.dest p) = p := by cases p <;> rfl
#align pfunctor.W.mk_dest PFunctor.W.mk_dest
-/

variable (P)

#print PFunctor.IdxCat /-
/-- `Idx` identifies a location inside the application of a pfunctor.
For `F : pfunctor`, `x : F.obj α` and `i : F.Idx`, `i` can designate
one part of `x` or is invalid, if `i.1 ≠ x.1` -/
def IdxCat :=
  Σ x : P.A, P.B x
#align pfunctor.Idx PFunctor.IdxCat
-/

#print PFunctor.IdxCat.inhabited /-
instance IdxCat.inhabited [Inhabited P.A] [Inhabited (P.B default)] : Inhabited P.IdxCat :=
  ⟨⟨default, default⟩⟩
#align pfunctor.Idx.inhabited PFunctor.IdxCat.inhabited
-/

variable {P}

#print PFunctor.Obj.iget /-
/-- `x.iget i` takes the component of `x` designated by `i` if any is or returns
a default value -/
def Obj.iget [DecidableEq P.A] {α} [Inhabited α] (x : P.Obj α) (i : P.IdxCat) : α :=
  if h : i.1 = x.1 then x.2 (cast (congr_arg _ h) i.2) else default
#align pfunctor.obj.iget PFunctor.Obj.iget
-/

#print PFunctor.fst_map /-
@[simp]
theorem fst_map {α β : Type u} (x : P.Obj α) (f : α → β) : (f <$> x).1 = x.1 := by cases x <;> rfl
#align pfunctor.fst_map PFunctor.fst_map
-/

#print PFunctor.iget_map /-
@[simp]
theorem iget_map [DecidableEq P.A] {α β : Type u} [Inhabited α] [Inhabited β] (x : P.Obj α)
    (f : α → β) (i : P.IdxCat) (h : i.1 = x.1) : (f <$> x).iget i = f (x.iget i) :=
  by
  simp only [obj.iget, fst_map, *, dif_pos, eq_self_iff_true]
  cases x; rfl
#align pfunctor.iget_map PFunctor.iget_map
-/

end PFunctor

/-
Composition of polynomial functors.
-/
namespace PFunctor

#print PFunctor.comp /-
/-- functor composition for polynomial functors -/
def comp (P₂ P₁ : PFunctor.{u}) : PFunctor.{u} :=
  ⟨Σ a₂ : P₂.1, P₂.2 a₂ → P₁.1, fun a₂a₁ => Σ u : P₂.2 a₂a₁.1, P₁.2 (a₂a₁.2 u)⟩
#align pfunctor.comp PFunctor.comp
-/

#print PFunctor.comp.mk /-
/-- constructor for composition -/
def comp.mk (P₂ P₁ : PFunctor.{u}) {α : Type} (x : P₂.Obj (P₁.Obj α)) : (comp P₂ P₁).Obj α :=
  ⟨⟨x.1, Sigma.fst ∘ x.2⟩, fun a₂a₁ => (x.2 a₂a₁.1).2 a₂a₁.2⟩
#align pfunctor.comp.mk PFunctor.comp.mk
-/

#print PFunctor.comp.get /-
/-- destructor for composition -/
def comp.get (P₂ P₁ : PFunctor.{u}) {α : Type} (x : (comp P₂ P₁).Obj α) : P₂.Obj (P₁.Obj α) :=
  ⟨x.1.1, fun a₂ => ⟨x.1.2 a₂, fun a₁ => x.2 ⟨a₂, a₁⟩⟩⟩
#align pfunctor.comp.get PFunctor.comp.get
-/

end PFunctor

/-
Lifting predicates and relations.
-/
namespace PFunctor

variable {P : PFunctor.{u}}

open Functor

#print PFunctor.liftp_iff /-
theorem liftp_iff {α : Type u} (p : α → Prop) (x : P.Obj α) :
    Liftp p x ↔ ∃ a f, x = ⟨a, f⟩ ∧ ∀ i, p (f i) :=
  by
  constructor
  · rintro ⟨y, hy⟩; cases' h : y with a f
    refine' ⟨a, fun i => (f i).val, _, fun i => (f i).property⟩
    rw [← hy, h, PFunctor.map_eq]
  rintro ⟨a, f, xeq, pf⟩
  use ⟨a, fun i => ⟨f i, pf i⟩⟩
  rw [xeq]; rfl
#align pfunctor.liftp_iff PFunctor.liftp_iff
-/

#print PFunctor.liftp_iff' /-
theorem liftp_iff' {α : Type u} (p : α → Prop) (a : P.A) (f : P.B a → α) :
    @Liftp.{u} P.Obj _ α p ⟨a, f⟩ ↔ ∀ i, p (f i) :=
  by
  simp only [liftp_iff, Sigma.mk.inj_iff] <;> constructor <;> intro
  · casesm*Exists _, _ ∧ _; subst_vars; assumption
  repeat'
    first
    | constructor
    | assumption
#align pfunctor.liftp_iff' PFunctor.liftp_iff'
-/

#print PFunctor.liftr_iff /-
theorem liftr_iff {α : Type u} (r : α → α → Prop) (x y : P.Obj α) :
    Liftr r x y ↔ ∃ a f₀ f₁, x = ⟨a, f₀⟩ ∧ y = ⟨a, f₁⟩ ∧ ∀ i, r (f₀ i) (f₁ i) :=
  by
  constructor
  · rintro ⟨u, xeq, yeq⟩; cases' h : u with a f
    use a, fun i => (f i).val.fst, fun i => (f i).val.snd
    constructor; · rw [← xeq, h]; rfl
    constructor; · rw [← yeq, h]; rfl
    intro i; exact (f i).property
  rintro ⟨a, f₀, f₁, xeq, yeq, h⟩
  use ⟨a, fun i => ⟨(f₀ i, f₁ i), h i⟩⟩
  constructor
  · rw [xeq]; rfl
  rw [yeq]; rfl
#align pfunctor.liftr_iff PFunctor.liftr_iff
-/

open Set

#print PFunctor.supp_eq /-
theorem supp_eq {α : Type u} (a : P.A) (f : P.B a → α) :
    @supp.{u} P.Obj _ α (⟨a, f⟩ : P.Obj α) = f '' univ :=
  by
  ext; simp only [supp, image_univ, mem_range, mem_set_of_eq]
  constructor <;> intro h
  · apply @h fun x => ∃ y : P.B a, f y = x
    rw [liftp_iff']; intro; refine' ⟨_, rfl⟩
  · simp only [liftp_iff']; cases h; subst x
    tauto
#align pfunctor.supp_eq PFunctor.supp_eq
-/

end PFunctor

