/-
Copyright (c) 2018 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Simon Hudon

! This file was ported from Lean 3 source module data.pfunctor.multivariate.basic
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Functor.Multivariate
import Mathbin.Data.Pfunctor.Univariate.Basic

/-!
# Multivariate polynomial functors.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Multivariate polynomial functors are used for defining M-types and W-types.
They map a type vector `α` to the type `Σ a : A, B a ⟹ α`, with `A : Type` and
`B : A → typevec n`. They interact well with Lean's inductive definitions because
they guarantee that occurrences of `α` are positive.
-/


universe u v

open scoped MvFunctor

#print MvPFunctor /-
/-- multivariate polynomial functors
-/
structure MvPFunctor (n : ℕ) where
  A : Type u
  B : A → TypeVec.{u} n
#align mvpfunctor MvPFunctor
-/

namespace MvPFunctor

open MvFunctor (Liftp Liftr)

variable {n m : ℕ} (P : MvPFunctor.{u} n)

#print MvPFunctor.Obj /-
/-- Applying `P` to an object of `Type` -/
def Obj (α : TypeVec.{u} n) : Type u :=
  Σ a : P.A, P.B a ⟹ α
#align mvpfunctor.obj MvPFunctor.Obj
-/

#print MvPFunctor.map /-
/-- Applying `P` to a morphism of `Type` -/
def map {α β : TypeVec n} (f : α ⟹ β) : P.Obj α → P.Obj β := fun ⟨a, g⟩ => ⟨a, TypeVec.comp f g⟩
#align mvpfunctor.map MvPFunctor.map
-/

instance : Inhabited (MvPFunctor n) :=
  ⟨⟨default, default⟩⟩

#print MvPFunctor.Obj.inhabited /-
instance Obj.inhabited {α : TypeVec n} [Inhabited P.A] [∀ i, Inhabited (α i)] :
    Inhabited (P.Obj α) :=
  ⟨⟨default, fun _ _ => default⟩⟩
#align mvpfunctor.obj.inhabited MvPFunctor.Obj.inhabited
-/

instance : MvFunctor P.Obj :=
  ⟨@MvPFunctor.map n P⟩

#print MvPFunctor.map_eq /-
theorem map_eq {α β : TypeVec n} (g : α ⟹ β) (a : P.A) (f : P.B a ⟹ α) :
    @MvFunctor.map _ P.Obj _ _ _ g ⟨a, f⟩ = ⟨a, g ⊚ f⟩ :=
  rfl
#align mvpfunctor.map_eq MvPFunctor.map_eq
-/

#print MvPFunctor.id_map /-
theorem id_map {α : TypeVec n} : ∀ x : P.Obj α, TypeVec.id <$$> x = x
  | ⟨a, g⟩ => rfl
#align mvpfunctor.id_map MvPFunctor.id_map
-/

#print MvPFunctor.comp_map /-
theorem comp_map {α β γ : TypeVec n} (f : α ⟹ β) (g : β ⟹ γ) :
    ∀ x : P.Obj α, (g ⊚ f) <$$> x = g <$$> f <$$> x
  | ⟨a, h⟩ => rfl
#align mvpfunctor.comp_map MvPFunctor.comp_map
-/

instance : LawfulMvFunctor P.Obj where
  id_map := @id_map _ P
  comp_map := @comp_map _ P

#print MvPFunctor.const /-
/-- Constant functor where the input object does not affect the output -/
def const (n : ℕ) (A : Type u) : MvPFunctor n :=
  { A
    B := fun a i => PEmpty }
#align mvpfunctor.const MvPFunctor.const
-/

section Const

variable (n) {A : Type u} {α β : TypeVec.{u} n}

#print MvPFunctor.const.mk /-
/-- Constructor for the constant functor -/
def const.mk (x : A) {α} : (const n A).Obj α :=
  ⟨x, fun i a => PEmpty.elim a⟩
#align mvpfunctor.const.mk MvPFunctor.const.mk
-/

variable {n A}

#print MvPFunctor.const.get /-
/-- Destructor for the constant functor -/
def const.get (x : (const n A).Obj α) : A :=
  x.1
#align mvpfunctor.const.get MvPFunctor.const.get
-/

#print MvPFunctor.const.get_map /-
@[simp]
theorem const.get_map (f : α ⟹ β) (x : (const n A).Obj α) : const.get (f <$$> x) = const.get x := by
  cases x; rfl
#align mvpfunctor.const.get_map MvPFunctor.const.get_map
-/

#print MvPFunctor.const.get_mk /-
@[simp]
theorem const.get_mk (x : A) : const.get (const.mk n x : (const n A).Obj α) = x := by rfl
#align mvpfunctor.const.get_mk MvPFunctor.const.get_mk
-/

#print MvPFunctor.const.mk_get /-
@[simp]
theorem const.mk_get (x : (const n A).Obj α) : const.mk n (const.get x) = x := by cases x;
  dsimp [const.get, const.mk]; congr with (_⟨⟩)
#align mvpfunctor.const.mk_get MvPFunctor.const.mk_get
-/

end Const

#print MvPFunctor.comp /-
/-- Functor composition on polynomial functors -/
def comp (P : MvPFunctor.{u} n) (Q : Fin2 n → MvPFunctor.{u} m) : MvPFunctor m
    where
  A := Σ a₂ : P.1, ∀ i, P.2 a₂ i → (Q i).1
  B a i := Σ (j : _) (b : P.2 a.1 j), (Q j).2 (a.snd j b) i
#align mvpfunctor.comp MvPFunctor.comp
-/

variable {P} {Q : Fin2 n → MvPFunctor.{u} m} {α β : TypeVec.{u} m}

#print MvPFunctor.comp.mk /-
/-- Constructor for functor composition -/
def comp.mk (x : P.Obj fun i => (Q i).Obj α) : (comp P Q).Obj α :=
  ⟨⟨x.1, fun i a => (x.2 _ a).1⟩, fun i a => (x.snd a.fst a.snd.fst).snd i a.snd.snd⟩
#align mvpfunctor.comp.mk MvPFunctor.comp.mk
-/

#print MvPFunctor.comp.get /-
/-- Destructor for functor composition -/
def comp.get (x : (comp P Q).Obj α) : P.Obj fun i => (Q i).Obj α :=
  ⟨x.1.1, fun i a => ⟨x.fst.snd i a, fun (j : Fin2 m) (b : (Q i).B _ j) => x.snd j ⟨i, ⟨a, b⟩⟩⟩⟩
#align mvpfunctor.comp.get MvPFunctor.comp.get
-/

#print MvPFunctor.comp.get_map /-
theorem comp.get_map (f : α ⟹ β) (x : (comp P Q).Obj α) :
    comp.get (f <$$> x) = (fun i (x : (Q i).Obj α) => f <$$> x) <$$> comp.get x := by cases x; rfl
#align mvpfunctor.comp.get_map MvPFunctor.comp.get_map
-/

#print MvPFunctor.comp.get_mk /-
@[simp]
theorem comp.get_mk (x : P.Obj fun i => (Q i).Obj α) : comp.get (comp.mk x) = x :=
  by
  cases x
  simp! [comp.get, comp.mk]
#align mvpfunctor.comp.get_mk MvPFunctor.comp.get_mk
-/

#print MvPFunctor.comp.mk_get /-
@[simp]
theorem comp.mk_get (x : (comp P Q).Obj α) : comp.mk (comp.get x) = x :=
  by
  cases x
  dsimp [comp.get, comp.mk]
  ext : 2 <;> intros; rfl; rfl
  congr; ext1 <;> intros <;> rfl
  ext : 2; congr; rcases x_1 with ⟨a, b, c⟩ <;> rfl
#align mvpfunctor.comp.mk_get MvPFunctor.comp.mk_get
-/

#print MvPFunctor.liftP_iff /-
/-
lifting predicates and relations
-/
theorem liftP_iff {α : TypeVec n} (p : ∀ ⦃i⦄, α i → Prop) (x : P.Obj α) :
    LiftP p x ↔ ∃ a f, x = ⟨a, f⟩ ∧ ∀ i j, p (f i j) :=
  by
  constructor
  · rintro ⟨y, hy⟩; cases' h : y with a f
    refine' ⟨a, fun i j => (f i j).val, _, fun i j => (f i j).property⟩
    rw [← hy, h, map_eq]; rfl
  rintro ⟨a, f, xeq, pf⟩
  use ⟨a, fun i j => ⟨f i j, pf i j⟩⟩
  rw [xeq]; rfl
#align mvpfunctor.liftp_iff MvPFunctor.liftP_iff
-/

#print MvPFunctor.liftP_iff' /-
theorem liftP_iff' {α : TypeVec n} (p : ∀ ⦃i⦄, α i → Prop) (a : P.A) (f : P.B a ⟹ α) :
    @LiftP.{u} _ P.Obj _ α p ⟨a, f⟩ ↔ ∀ i x, p (f i x) :=
  by
  simp only [liftp_iff, Sigma.mk.inj_iff] <;> constructor <;> intro
  · casesm*Exists _, _ ∧ _; subst_vars; assumption
  repeat'
    first
    | constructor
    | assumption
#align mvpfunctor.liftp_iff' MvPFunctor.liftP_iff'
-/

#print MvPFunctor.liftR_iff /-
theorem liftR_iff {α : TypeVec n} (r : ∀ ⦃i⦄, α i → α i → Prop) (x y : P.Obj α) :
    LiftR r x y ↔ ∃ a f₀ f₁, x = ⟨a, f₀⟩ ∧ y = ⟨a, f₁⟩ ∧ ∀ i j, r (f₀ i j) (f₁ i j) :=
  by
  constructor
  · rintro ⟨u, xeq, yeq⟩; cases' h : u with a f
    use a, fun i j => (f i j).val.fst, fun i j => (f i j).val.snd
    constructor; · rw [← xeq, h]; rfl
    constructor; · rw [← yeq, h]; rfl
    intro i j; exact (f i j).property
  rintro ⟨a, f₀, f₁, xeq, yeq, h⟩
  use ⟨a, fun i j => ⟨(f₀ i j, f₁ i j), h i j⟩⟩
  dsimp; constructor
  · rw [xeq]; rfl
  rw [yeq]; rfl
#align mvpfunctor.liftr_iff MvPFunctor.liftR_iff
-/

open Set MvFunctor

#print MvPFunctor.supp_eq /-
theorem supp_eq {α : TypeVec n} (a : P.A) (f : P.B a ⟹ α) (i) :
    @supp.{u} _ P.Obj _ α (⟨a, f⟩ : P.Obj α) i = f i '' univ :=
  by
  ext; simp only [supp, image_univ, mem_range, mem_set_of_eq]
  constructor <;> intro h
  · apply @h fun i x => ∃ y : P.B a i, f i y = x
    rw [liftp_iff']; intros; refine' ⟨_, rfl⟩
  · simp only [liftp_iff']; cases h; subst x
    tauto
#align mvpfunctor.supp_eq MvPFunctor.supp_eq
-/

end MvPFunctor

/-
Decomposing an n+1-ary pfunctor.
-/
namespace MvPFunctor

open TypeVec

variable {n : ℕ} (P : MvPFunctor.{u} (n + 1))

#print MvPFunctor.drop /-
/-- Split polynomial functor, get a n-ary functor
from a `n+1`-ary functor -/
def drop : MvPFunctor n where
  A := P.A
  B a := (P.B a).drop
#align mvpfunctor.drop MvPFunctor.drop
-/

#print MvPFunctor.last /-
/-- Split polynomial functor, get a univariate functor
from a `n+1`-ary functor -/
def last : PFunctor where
  A := P.A
  B a := (P.B a).getLast
#align mvpfunctor.last MvPFunctor.last
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print MvPFunctor.appendContents /-
/-- append arrows of a polynomial functor application -/
@[reducible]
def appendContents {α : TypeVec n} {β : Type _} {a : P.A} (f' : P.drop.B a ⟹ α)
    (f : P.getLast.B a → β) : P.B a ⟹ (α ::: β) :=
  splitFun f' f
#align mvpfunctor.append_contents MvPFunctor.appendContents
-/

end MvPFunctor

