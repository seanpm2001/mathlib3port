/-
Copyright (c) 2018 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad

! This file was ported from Lean 3 source module data.qpf.univariate.basic
! leanprover-community/mathlib commit 8eb9c42d4d34c77f6ee84ea766ae4070233a973c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Pfunctor.Univariate.M

/-!

# Quotients of Polynomial Functors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We assume the following:

`P`   : a polynomial functor
`W`   : its W-type
`M`   : its M-type
`F`   : a functor

We define:

`q`   : `qpf` data, representing `F` as a quotient of `P`

The main goal is to construct:

`fix`   : the initial algebra with structure map `F fix → fix`.
`cofix` : the final coalgebra with structure map `cofix → F cofix`

We also show that the composition of qpfs is a qpf, and that the quotient of a qpf
is a qpf.

The present theory focuses on the univariate case for qpfs

## References

* [Jeremy Avigad, Mario M. Carneiro and Simon Hudon, *Data Types as Quotients of Polynomial Functors*][avigad-carneiro-hudon2019]

-/


universe u

#print Qpf /-
/-- Quotients of polynomial functors.

Roughly speaking, saying that `F` is a quotient of a polynomial functor means that for each `α`,
elements of `F α` are represented by pairs `⟨a, f⟩`, where `a` is the shape of the object and
`f` indexes the relevant elements of `α`, in a suitably natural manner.
-/
class Qpf (F : Type u → Type u) [Functor F] where
  p : PFunctor.{u}
  abs : ∀ {α}, P.Obj α → F α
  repr : ∀ {α}, F α → P.Obj α
  abs_repr : ∀ {α} (x : F α), abs (repr x) = x
  abs_map : ∀ {α β} (f : α → β) (p : P.Obj α), abs (f <$> p) = f <$> abs p
#align qpf Qpf
-/

namespace Qpf

variable {F : Type u → Type u} [Functor F] [q : Qpf F]

open Functor (Liftp Liftr)

#print Qpf.id_map /-
/-
Show that every qpf is a lawful functor.

Note: every functor has a field, `map_const`, and is_lawful_functor has the defining
characterization. We can only propagate the assumption.
-/
theorem id_map {α : Type _} (x : F α) : id <$> x = x := by rw [← abs_repr x];
  cases' repr x with a f; rw [← abs_map]; rfl
#align qpf.id_map Qpf.id_map
-/

#print Qpf.comp_map /-
theorem comp_map {α β γ : Type _} (f : α → β) (g : β → γ) (x : F α) :
    (g ∘ f) <$> x = g <$> f <$> x := by rw [← abs_repr x]; cases' repr x with a f;
  rw [← abs_map, ← abs_map, ← abs_map]; rfl
#align qpf.comp_map Qpf.comp_map
-/

#print Qpf.lawfulFunctor /-
theorem lawfulFunctor
    (h : ∀ α β : Type u, @Functor.mapConst F _ α _ = Functor.map ∘ Function.const β) :
    LawfulFunctor F :=
  { map_const := h
    id_map := @id_map F _ _
    comp_map := @comp_map F _ _ }
#align qpf.is_lawful_functor Qpf.lawfulFunctor
-/

/-
Lifting predicates and relations
-/
section

open Functor

#print Qpf.liftp_iff /-
theorem liftp_iff {α : Type u} (p : α → Prop) (x : F α) :
    Liftp p x ↔ ∃ a f, x = abs ⟨a, f⟩ ∧ ∀ i, p (f i) :=
  by
  constructor
  · rintro ⟨y, hy⟩; cases' h : repr y with a f
    use a, fun i => (f i).val; constructor
    · rw [← hy, ← abs_repr y, h, ← abs_map]; rfl
    intro i; apply (f i).property
  rintro ⟨a, f, h₀, h₁⟩; dsimp at *
  use abs ⟨a, fun i => ⟨f i, h₁ i⟩⟩
  rw [← abs_map, h₀]; rfl
#align qpf.liftp_iff Qpf.liftp_iff
-/

#print Qpf.liftp_iff' /-
theorem liftp_iff' {α : Type u} (p : α → Prop) (x : F α) :
    Liftp p x ↔ ∃ u : q.p.Obj α, abs u = x ∧ ∀ i, p (u.snd i) :=
  by
  constructor
  · rintro ⟨y, hy⟩; cases' h : repr y with a f
    use ⟨a, fun i => (f i).val⟩; dsimp; constructor
    · rw [← hy, ← abs_repr y, h, ← abs_map]; rfl
    intro i; apply (f i).property
  rintro ⟨⟨a, f⟩, h₀, h₁⟩; dsimp at *
  use abs ⟨a, fun i => ⟨f i, h₁ i⟩⟩
  rw [← abs_map, ← h₀]; rfl
#align qpf.liftp_iff' Qpf.liftp_iff'
-/

#print Qpf.liftr_iff /-
theorem liftr_iff {α : Type u} (r : α → α → Prop) (x y : F α) :
    Liftr r x y ↔ ∃ a f₀ f₁, x = abs ⟨a, f₀⟩ ∧ y = abs ⟨a, f₁⟩ ∧ ∀ i, r (f₀ i) (f₁ i) :=
  by
  constructor
  · rintro ⟨u, xeq, yeq⟩; cases' h : repr u with a f
    use a, fun i => (f i).val.fst, fun i => (f i).val.snd
    constructor; · rw [← xeq, ← abs_repr u, h, ← abs_map]; rfl
    constructor; · rw [← yeq, ← abs_repr u, h, ← abs_map]; rfl
    intro i; exact (f i).property
  rintro ⟨a, f₀, f₁, xeq, yeq, h⟩
  use abs ⟨a, fun i => ⟨(f₀ i, f₁ i), h i⟩⟩
  dsimp; constructor
  · rw [xeq, ← abs_map]; rfl
  rw [yeq, ← abs_map]; rfl
#align qpf.liftr_iff Qpf.liftr_iff
-/

end

#print Qpf.recF /-
/-
Think of trees in the `W` type corresponding to `P` as representatives of elements of the
least fixed point of `F`, and assign a canonical representative to each equivalence class
of trees.
-/
/-- does recursion on `q.P.W` using `g : F α → α` rather than `g : P α → α` -/
def recF {α : Type _} (g : F α → α) : q.p.W → α
  | ⟨a, f⟩ => g (abs ⟨a, fun x => recF (f x)⟩)
#align qpf.recF Qpf.recF
-/

#print Qpf.recF_eq /-
theorem recF_eq {α : Type _} (g : F α → α) (x : q.p.W) : recF g x = g (abs (recF g <$> x.dest)) :=
  by cases x <;> rfl
#align qpf.recF_eq Qpf.recF_eq
-/

#print Qpf.recF_eq' /-
theorem recF_eq' {α : Type _} (g : F α → α) (a : q.p.A) (f : q.p.B a → q.p.W) :
    recF g ⟨a, f⟩ = g (abs (recF g <$> ⟨a, f⟩)) :=
  rfl
#align qpf.recF_eq' Qpf.recF_eq'
-/

#print Qpf.Wequiv /-
/-- two trees are equivalent if their F-abstractions are -/
inductive Wequiv : q.p.W → q.p.W → Prop
  | ind (a : q.p.A) (f f' : q.p.B a → q.p.W) : (∀ x, Wequiv (f x) (f' x)) → Wequiv ⟨a, f⟩ ⟨a, f'⟩
  |
  abs (a : q.p.A) (f : q.p.B a → q.p.W) (a' : q.p.A) (f' : q.p.B a' → q.p.W) :
    abs ⟨a, f⟩ = abs ⟨a', f'⟩ → Wequiv ⟨a, f⟩ ⟨a', f'⟩
  | trans (u v w : q.p.W) : Wequiv u v → Wequiv v w → Wequiv u w
#align qpf.Wequiv Qpf.Wequiv
-/

#print Qpf.recF_eq_of_Wequiv /-
/-- recF is insensitive to the representation -/
theorem recF_eq_of_Wequiv {α : Type u} (u : F α → α) (x y : q.p.W) :
    Wequiv x y → recF u x = recF u y := by
  cases' x with a f; cases' y with b g
  intro h; induction h
  case ind a f f' h ih => simp only [recF_eq', PFunctor.map_eq, Function.comp, ih]
  case abs a f a' f' h => simp only [recF_eq', abs_map, h]
  case trans x y z e₁ e₂ ih₁ ih₂ => exact Eq.trans ih₁ ih₂
#align qpf.recF_eq_of_Wequiv Qpf.recF_eq_of_Wequiv
-/

#print Qpf.Wequiv.abs' /-
theorem Wequiv.abs' (x y : q.p.W) (h : abs x.dest = abs y.dest) : Wequiv x y := by cases x; cases y;
  apply Wequiv.abs; apply h
#align qpf.Wequiv.abs' Qpf.Wequiv.abs'
-/

#print Qpf.Wequiv.refl /-
theorem Wequiv.refl (x : q.p.W) : Wequiv x x := by
  cases' x with a f <;> exact Wequiv.abs a f a f rfl
#align qpf.Wequiv.refl Qpf.Wequiv.refl
-/

#print Qpf.Wequiv.symm /-
theorem Wequiv.symm (x y : q.p.W) : Wequiv x y → Wequiv y x :=
  by
  cases' x with a f; cases' y with b g
  intro h; induction h
  case ind a f f' h ih => exact Wequiv.ind _ _ _ ih
  case abs a f a' f' h => exact Wequiv.abs _ _ _ _ h.symm
  case trans x y z e₁ e₂ ih₁ ih₂ => exact Qpf.Wequiv.trans _ _ _ ih₂ ih₁
#align qpf.Wequiv.symm Qpf.Wequiv.symm
-/

#print Qpf.Wrepr /-
/-- maps every element of the W type to a canonical representative -/
def Wrepr : q.p.W → q.p.W :=
  recF (PFunctor.W.mk ∘ repr)
#align qpf.Wrepr Qpf.Wrepr
-/

#print Qpf.Wrepr_equiv /-
theorem Wrepr_equiv (x : q.p.W) : Wequiv (Wrepr x) x :=
  by
  induction' x with a f ih
  apply Wequiv.trans
  · change Wequiv (Wrepr ⟨a, f⟩) (PFunctor.W.mk (Wrepr <$> ⟨a, f⟩))
    apply Wequiv.abs'
    have : Wrepr ⟨a, f⟩ = PFunctor.W.mk (repr (abs (Wrepr <$> ⟨a, f⟩))) := rfl
    rw [this, PFunctor.W.dest_mk, abs_repr]
    rfl
  apply Wequiv.ind; exact ih
#align qpf.Wrepr_equiv Qpf.Wrepr_equiv
-/

#print Qpf.Wsetoid /-
/-- Define the fixed point as the quotient of trees under the equivalence relation `Wequiv`.
-/
def Wsetoid : Setoid q.p.W :=
  ⟨Wequiv, @Wequiv.refl _ _ _, @Wequiv.symm _ _ _, @Wequiv.trans _ _ _⟩
#align qpf.W_setoid Qpf.Wsetoid
-/

attribute [local instance] W_setoid

#print Qpf.Fix /-
/-- inductive type defined as initial algebra of a Quotient of Polynomial Functor -/
@[nolint has_nonempty_instance]
def Fix (F : Type u → Type u) [Functor F] [q : Qpf F] :=
  Quotient (Wsetoid : Setoid q.p.W)
#align qpf.fix Qpf.Fix
-/

#print Qpf.Fix.rec /-
/-- recursor of a type defined by a qpf -/
def Fix.rec {α : Type _} (g : F α → α) : Fix F → α :=
  Quot.lift (recF g) (recF_eq_of_Wequiv g)
#align qpf.fix.rec Qpf.Fix.rec
-/

#print Qpf.fixToW /-
/-- access the underlying W-type of a fixpoint data type -/
def fixToW : Fix F → q.p.W :=
  Quotient.lift Wrepr (recF_eq_of_Wequiv fun x => @PFunctor.W.mk q.p (repr x))
#align qpf.fix_to_W Qpf.fixToW
-/

#print Qpf.Fix.mk /-
/-- constructor of a type defined by a qpf -/
def Fix.mk (x : F (Fix F)) : Fix F :=
  Quot.mk _ (PFunctor.W.mk (fixToW <$> repr x))
#align qpf.fix.mk Qpf.Fix.mk
-/

#print Qpf.Fix.dest /-
/-- destructor of a type defined by a qpf -/
def Fix.dest : Fix F → F (Fix F) :=
  Fix.rec (Functor.map Fix.mk)
#align qpf.fix.dest Qpf.Fix.dest
-/

#print Qpf.Fix.rec_eq /-
theorem Fix.rec_eq {α : Type _} (g : F α → α) (x : F (Fix F)) :
    Fix.rec g (Fix.mk x) = g (Fix.rec g <$> x) :=
  by
  have : recF g ∘ fixToW = Fix.rec g := by
    apply funext; apply Quotient.ind; intro x; apply recF_eq_of_Wequiv
    rw [fix_to_W]; apply Wrepr_equiv
  conv =>
    lhs
    rw [fix.rec, fix.mk]
    dsimp
  cases' h : repr x with a f
  rw [PFunctor.map_eq, recF_eq, ← PFunctor.map_eq, PFunctor.W.dest_mk, ← PFunctor.comp_map, abs_map,
    ← h, abs_repr, this]
#align qpf.fix.rec_eq Qpf.Fix.rec_eq
-/

#print Qpf.Fix.ind_aux /-
theorem Fix.ind_aux (a : q.p.A) (f : q.p.B a → q.p.W) :
    Fix.mk (abs ⟨a, fun x => ⟦f x⟧⟩) = ⟦⟨a, f⟩⟧ :=
  by
  have : Fix.mk (abs ⟨a, fun x => ⟦f x⟧⟩) = ⟦Wrepr ⟨a, f⟩⟧ :=
    by
    apply Quot.sound; apply Wequiv.abs'
    rw [PFunctor.W.dest_mk, abs_map, abs_repr, ← abs_map, PFunctor.map_eq]
    conv =>
      rhs
      simp only [Wrepr, recF_eq, PFunctor.W.dest_mk, abs_repr]
    rfl
  rw [this]
  apply Quot.sound
  apply Wrepr_equiv
#align qpf.fix.ind_aux Qpf.Fix.ind_aux
-/

#print Qpf.Fix.ind_rec /-
theorem Fix.ind_rec {α : Type u} (g₁ g₂ : Fix F → α)
    (h : ∀ x : F (Fix F), g₁ <$> x = g₂ <$> x → g₁ (Fix.mk x) = g₂ (Fix.mk x)) : ∀ x, g₁ x = g₂ x :=
  by
  apply Quot.ind
  intro x
  induction' x with a f ih
  change g₁ ⟦⟨a, f⟩⟧ = g₂ ⟦⟨a, f⟩⟧
  rw [← fix.ind_aux a f]; apply h
  rw [← abs_map, ← abs_map, PFunctor.map_eq, PFunctor.map_eq]
  dsimp [Function.comp]
  congr with x; apply ih
#align qpf.fix.ind_rec Qpf.Fix.ind_rec
-/

#print Qpf.Fix.rec_unique /-
theorem Fix.rec_unique {α : Type u} (g : F α → α) (h : Fix F → α)
    (hyp : ∀ x, h (Fix.mk x) = g (h <$> x)) : Fix.rec g = h :=
  by
  ext x
  apply fix.ind_rec
  intro x hyp'
  rw [hyp, ← hyp', fix.rec_eq]
#align qpf.fix.rec_unique Qpf.Fix.rec_unique
-/

#print Qpf.Fix.mk_dest /-
theorem Fix.mk_dest (x : Fix F) : Fix.mk (Fix.dest x) = x :=
  by
  change (fix.mk ∘ fix.dest) x = id x
  apply fix.ind_rec
  intro x; dsimp
  rw [fix.dest, fix.rec_eq, id_map, comp_map]
  intro h; rw [h]
#align qpf.fix.mk_dest Qpf.Fix.mk_dest
-/

#print Qpf.Fix.dest_mk /-
theorem Fix.dest_mk (x : F (Fix F)) : Fix.dest (Fix.mk x) = x :=
  by
  unfold fix.dest; rw [fix.rec_eq, ← fix.dest, ← comp_map]
  conv =>
    rhs
    rw [← id_map x]
  congr with x; apply fix.mk_dest
#align qpf.fix.dest_mk Qpf.Fix.dest_mk
-/

#print Qpf.Fix.ind /-
theorem Fix.ind (p : Fix F → Prop) (h : ∀ x : F (Fix F), Liftp p x → p (Fix.mk x)) : ∀ x, p x :=
  by
  apply Quot.ind
  intro x
  induction' x with a f ih
  change p ⟦⟨a, f⟩⟧
  rw [← fix.ind_aux a f]
  apply h
  rw [liftp_iff]
  refine' ⟨_, _, rfl, _⟩
  apply ih
#align qpf.fix.ind Qpf.Fix.ind
-/

end Qpf

/-
Construct the final coalgebra to a qpf.
-/
namespace Qpf

variable {F : Type u → Type u} [Functor F] [q : Qpf F]

open Functor (Liftp Liftr)

#print Qpf.corecF /-
/-- does recursion on `q.P.M` using `g : α → F α` rather than `g : α → P α` -/
def corecF {α : Type _} (g : α → F α) : α → q.p.M :=
  PFunctor.M.corec fun x => repr (g x)
#align qpf.corecF Qpf.corecF
-/

#print Qpf.corecF_eq /-
theorem corecF_eq {α : Type _} (g : α → F α) (x : α) :
    PFunctor.M.dest (corecF g x) = corecF g <$> repr (g x) := by rw [corecF, PFunctor.M.dest_corec]
#align qpf.corecF_eq Qpf.corecF_eq
-/

#print Qpf.IsPrecongr /-
-- Equivalence
/-- A pre-congruence on q.P.M *viewed as an F-coalgebra*. Not necessarily symmetric. -/
def IsPrecongr (r : q.p.M → q.p.M → Prop) : Prop :=
  ∀ ⦃x y⦄, r x y → abs (Quot.mk r <$> PFunctor.M.dest x) = abs (Quot.mk r <$> PFunctor.M.dest y)
#align qpf.is_precongr Qpf.IsPrecongr
-/

#print Qpf.Mcongr /-
/-- The maximal congruence on q.P.M -/
def Mcongr : q.p.M → q.p.M → Prop := fun x y => ∃ r, IsPrecongr r ∧ r x y
#align qpf.Mcongr Qpf.Mcongr
-/

#print Qpf.Cofix /-
/-- coinductive type defined as the final coalgebra of a qpf -/
def Cofix (F : Type u → Type u) [Functor F] [q : Qpf F] :=
  Quot (@Mcongr F _ q)
#align qpf.cofix Qpf.Cofix
-/

instance [Inhabited q.p.A] : Inhabited (Cofix F) :=
  ⟨Quot.mk _ default⟩

#print Qpf.Cofix.corec /-
/-- corecursor for type defined by `cofix` -/
def Cofix.corec {α : Type _} (g : α → F α) (x : α) : Cofix F :=
  Quot.mk _ (corecF g x)
#align qpf.cofix.corec Qpf.Cofix.corec
-/

#print Qpf.Cofix.dest /-
/-- destructor for type defined by `cofix` -/
def Cofix.dest : Cofix F → F (Cofix F) :=
  Quot.lift (fun x => Quot.mk Mcongr <$> abs (PFunctor.M.dest x))
    (by
      rintro x y ⟨r, pr, rxy⟩; dsimp
      have : ∀ x y, r x y → Mcongr x y := by intro x y h; exact ⟨r, pr, h⟩
      rw [← Quot.factor_mk_eq _ _ this]; dsimp
      conv =>
        lhs
        rw [comp_map, ← abs_map, pr rxy, abs_map, ← comp_map])
#align qpf.cofix.dest Qpf.Cofix.dest
-/

#print Qpf.Cofix.dest_corec /-
theorem Cofix.dest_corec {α : Type u} (g : α → F α) (x : α) :
    Cofix.dest (Cofix.corec g x) = Cofix.corec g <$> g x :=
  by
  conv =>
    lhs
    rw [cofix.dest, cofix.corec];
  dsimp
  rw [corecF_eq, abs_map, abs_repr, ← comp_map]; rfl
#align qpf.cofix.dest_corec Qpf.Cofix.dest_corec
-/

private theorem cofix.bisim_aux (r : Cofix F → Cofix F → Prop) (h' : ∀ x, r x x)
    (h : ∀ x y, r x y → Quot.mk r <$> Cofix.dest x = Quot.mk r <$> Cofix.dest y) :
    ∀ x y, r x y → x = y := by
  intro x; apply Quot.inductionOn x; clear x
  intro x y; apply Quot.inductionOn y; clear y
  intro y rxy
  apply Quot.sound
  let r' x y := r (Quot.mk _ x) (Quot.mk _ y)
  have : is_precongr r' := by
    intro a b r'ab
    have h₀ :
      Quot.mk r <$> Quot.mk Mcongr <$> abs (PFunctor.M.dest a) =
        Quot.mk r <$> Quot.mk Mcongr <$> abs (PFunctor.M.dest b) :=
      h _ _ r'ab
    have h₁ : ∀ u v : q.P.M, Mcongr u v → Quot.mk r' u = Quot.mk r' v := by intro u v cuv;
      apply Quot.sound; dsimp [r']; rw [Quot.sound cuv]; apply h'
    let f : Quot r → Quot r' :=
      Quot.lift (Quot.lift (Quot.mk r') h₁)
        (by
          intro c; apply Quot.inductionOn c; clear c
          intro c d; apply Quot.inductionOn d; clear d
          intro d rcd; apply Quot.sound; apply rcd)
    have : f ∘ Quot.mk r ∘ Quot.mk Mcongr = Quot.mk r' := rfl
    rw [← this, PFunctor.comp_map _ _ f, PFunctor.comp_map _ _ (Quot.mk r), abs_map, abs_map,
      abs_map, h₀]
    rw [PFunctor.comp_map _ _ f, PFunctor.comp_map _ _ (Quot.mk r), abs_map, abs_map, abs_map]
  refine' ⟨r', this, rxy⟩

#print Qpf.Cofix.bisim_rel /-
theorem Cofix.bisim_rel (r : Cofix F → Cofix F → Prop)
    (h : ∀ x y, r x y → Quot.mk r <$> Cofix.dest x = Quot.mk r <$> Cofix.dest y) :
    ∀ x y, r x y → x = y := by
  let r' (x y) := x = y ∨ r x y
  intro x y rxy
  apply cofix.bisim_aux r'
  · intro x; left; rfl
  · intro x y r'xy
    cases r'xy; · rw [r'xy]
    have : ∀ x y, r x y → r' x y := fun x y h => Or.inr h
    rw [← Quot.factor_mk_eq _ _ this]; dsimp
    rw [@comp_map _ _ q _ _ _ (Quot.mk r), @comp_map _ _ q _ _ _ (Quot.mk r)]
    rw [h _ _ r'xy]
  right; exact rxy
#align qpf.cofix.bisim_rel Qpf.Cofix.bisim_rel
-/

#print Qpf.Cofix.bisim /-
theorem Cofix.bisim (r : Cofix F → Cofix F → Prop)
    (h : ∀ x y, r x y → Liftr r (Cofix.dest x) (Cofix.dest y)) : ∀ x y, r x y → x = y :=
  by
  apply cofix.bisim_rel
  intro x y rxy
  rcases(liftr_iff r _ _).mp (h x y rxy) with ⟨a, f₀, f₁, dxeq, dyeq, h'⟩
  rw [dxeq, dyeq, ← abs_map, ← abs_map, PFunctor.map_eq, PFunctor.map_eq]
  congr 2 with i
  apply Quot.sound
  apply h'
#align qpf.cofix.bisim Qpf.Cofix.bisim
-/

#print Qpf.Cofix.bisim' /-
theorem Cofix.bisim' {α : Type _} (Q : α → Prop) (u v : α → Cofix F)
    (h :
      ∀ x,
        Q x →
          ∃ a f f',
            Cofix.dest (u x) = abs ⟨a, f⟩ ∧
              Cofix.dest (v x) = abs ⟨a, f'⟩ ∧ ∀ i, ∃ x', Q x' ∧ f i = u x' ∧ f' i = v x') :
    ∀ x, Q x → u x = v x := fun x Qx =>
  let R := fun w z : Cofix F => ∃ x', Q x' ∧ w = u x' ∧ z = v x'
  Cofix.bisim R
    (fun x y ⟨x', Qx', xeq, yeq⟩ =>
      by
      rcases h x' Qx' with ⟨a, f, f', ux'eq, vx'eq, h'⟩
      rw [liftr_iff]
      refine' ⟨a, f, f', xeq.symm ▸ ux'eq, yeq.symm ▸ vx'eq, h'⟩)
    _ _ ⟨x, Qx, rfl, rfl⟩
#align qpf.cofix.bisim' Qpf.Cofix.bisim'
-/

end Qpf

/-
Composition of qpfs.
-/
namespace Qpf

variable {F₂ : Type u → Type u} [Functor F₂] [q₂ : Qpf F₂]

variable {F₁ : Type u → Type u} [Functor F₁] [q₁ : Qpf F₁]

#print Qpf.comp /-
/-- composition of qpfs gives another qpf  -/
def comp : Qpf (Functor.Comp F₂ F₁)
    where
  p := PFunctor.comp q₂.p q₁.p
  abs α := by
    dsimp [Functor.Comp]
    intro p
    exact abs ⟨p.1.1, fun x => abs ⟨p.1.2 x, fun y => p.2 ⟨x, y⟩⟩⟩
  repr α := by
    dsimp [Functor.Comp]
    intro y
    refine' ⟨⟨(repr y).1, fun u => (repr ((repr y).2 u)).1⟩, _⟩
    dsimp [PFunctor.comp]
    intro x
    exact (repr ((repr y).2 x.1)).snd x.2
  abs_repr α := by
    abstract 
      dsimp [Functor.Comp]
      intro x
      conv =>
        rhs
        rw [← abs_repr x]
      cases' h : repr x with a f
      dsimp
      congr with x
      cases' h' : repr (f x) with b g
      dsimp; rw [← h', abs_repr]
  abs_map α β f := by
    abstract 
      dsimp [Functor.Comp, PFunctor.comp]
      intro p
      cases' p with a g; dsimp
      cases' a with b h; dsimp
      symm
      trans
      symm
      apply abs_map
      congr
      rw [PFunctor.map_eq]
      dsimp [Function.comp]
      simp [abs_map]
      constructor
      rfl
      ext x
      rw [← abs_map]
      rfl
#align qpf.comp Qpf.comp
-/

end Qpf

/-
Quotients.

We show that if `F` is a qpf and `G` is a suitable quotient of `F`, then `G` is a qpf.
-/
namespace Qpf

variable {F : Type u → Type u} [Functor F] [q : Qpf F]

variable {G : Type u → Type u} [Functor G]

variable {FG_abs : ∀ {α}, F α → G α}

variable {FG_repr : ∀ {α}, G α → F α}

#print Qpf.quotientQpf /-
/-- Given a qpf `F` and a well-behaved surjection `FG_abs` from F α to
functor G α, `G` is a qpf. We can consider `G` a quotient on `F` where
elements `x y : F α` are in the same equivalence class if
`FG_abs x = FG_abs y`  -/
def quotientQpf (FG_abs_repr : ∀ {α} (x : G α), FG_abs (FG_repr x) = x)
    (FG_abs_map : ∀ {α β} (f : α → β) (x : F α), FG_abs (f <$> x) = f <$> FG_abs x) : Qpf G
    where
  p := q.p
  abs {α} p := FG_abs (abs p)
  repr {α} x := repr (FG_repr x)
  abs_repr {α} x := by rw [abs_repr, FG_abs_repr]
  abs_map {α β} f x := by rw [abs_map, FG_abs_map]
#align qpf.quotient_qpf Qpf.quotientQpf
-/

end Qpf

/-
Support.
-/
namespace Qpf

variable {F : Type u → Type u} [Functor F] [q : Qpf F]

open Functor (Liftp Liftr supp)

open Set

#print Qpf.mem_supp /-
theorem mem_supp {α : Type u} (x : F α) (u : α) :
    u ∈ supp x ↔ ∀ a f, abs ⟨a, f⟩ = x → u ∈ f '' univ :=
  by
  rw [supp]; dsimp; constructor
  · intro h a f haf
    have : liftp (fun u => u ∈ f '' univ) x := by rw [liftp_iff];
      refine' ⟨a, f, haf.symm, fun i => mem_image_of_mem _ (mem_univ _)⟩
    exact h this
  intro h p; rw [liftp_iff]
  rintro ⟨a, f, xeq, h'⟩
  rcases h a f xeq.symm with ⟨i, _, hi⟩
  rw [← hi]; apply h'
#align qpf.mem_supp Qpf.mem_supp
-/

#print Qpf.supp_eq /-
theorem supp_eq {α : Type u} (x : F α) : supp x = {u | ∀ a f, abs ⟨a, f⟩ = x → u ∈ f '' univ} := by
  ext <;> apply mem_supp
#align qpf.supp_eq Qpf.supp_eq
-/

#print Qpf.has_good_supp_iff /-
theorem has_good_supp_iff {α : Type u} (x : F α) :
    (∀ p, Liftp p x ↔ ∀ u ∈ supp x, p u) ↔
      ∃ a f, abs ⟨a, f⟩ = x ∧ ∀ a' f', abs ⟨a', f'⟩ = x → f '' univ ⊆ f' '' univ :=
  by
  constructor
  · intro h
    have : liftp (supp x) x := by rw [h] <;> intro u <;> exact id
    rw [liftp_iff] at this ; rcases this with ⟨a, f, xeq, h'⟩
    refine' ⟨a, f, xeq.symm, _⟩
    intro a' f' h''
    rintro u ⟨i, _, hfi⟩
    have : u ∈ supp x := by rw [← hfi] <;> apply h'
    exact (mem_supp x u).mp this _ _ h''
  rintro ⟨a, f, xeq, h⟩ p; rw [liftp_iff]; constructor
  · rintro ⟨a', f', xeq', h'⟩ u usuppx
    rcases(mem_supp x u).mp usuppx a' f' xeq'.symm with ⟨i, _, f'ieq⟩
    rw [← f'ieq]; apply h'
  intro h'
  refine' ⟨a, f, xeq.symm, _⟩; intro i
  apply h'; rw [mem_supp]
  intro a' f' xeq'
  apply h a' f' xeq'
  apply mem_image_of_mem _ (mem_univ _)
#align qpf.has_good_supp_iff Qpf.has_good_supp_iff
-/

variable (q)

#print Qpf.IsUniform /-
/-- A qpf is said to be uniform if every polynomial functor
representing a single value all have the same range. -/
def IsUniform : Prop :=
  ∀ ⦃α : Type u⦄ (a a' : q.p.A) (f : q.p.B a → α) (f' : q.p.B a' → α),
    abs ⟨a, f⟩ = abs ⟨a', f'⟩ → f '' univ = f' '' univ
#align qpf.is_uniform Qpf.IsUniform
-/

#print Qpf.LiftpPreservation /-
/-- does `abs` preserve `liftp`? -/
def LiftpPreservation : Prop :=
  ∀ ⦃α⦄ (p : α → Prop) (x : q.p.Obj α), Liftp p (abs x) ↔ Liftp p x
#align qpf.liftp_preservation Qpf.LiftpPreservation
-/

#print Qpf.SuppPreservation /-
/-- does `abs` preserve `supp`? -/
def SuppPreservation : Prop :=
  ∀ ⦃α⦄ (x : q.p.Obj α), supp (abs x) = supp x
#align qpf.supp_preservation Qpf.SuppPreservation
-/

variable (q)

#print Qpf.supp_eq_of_isUniform /-
theorem supp_eq_of_isUniform (h : q.IsUniform) {α : Type u} (a : q.p.A) (f : q.p.B a → α) :
    supp (abs ⟨a, f⟩) = f '' univ := by
  ext u; rw [mem_supp]; constructor
  · intro h'; apply h' _ _ rfl
  intro h' a' f' e
  rw [← h _ _ _ _ e.symm]; apply h'
#align qpf.supp_eq_of_is_uniform Qpf.supp_eq_of_isUniform
-/

#print Qpf.liftp_iff_of_isUniform /-
theorem liftp_iff_of_isUniform (h : q.IsUniform) {α : Type u} (x : F α) (p : α → Prop) :
    Liftp p x ↔ ∀ u ∈ supp x, p u :=
  by
  rw [liftp_iff, ← abs_repr x]
  cases' repr x with a f; constructor
  · rintro ⟨a', f', abseq, hf⟩ u
    rw [supp_eq_of_is_uniform h, h _ _ _ _ abseq]
    rintro ⟨i, _, hi⟩; rw [← hi]; apply hf
  intro h'
  refine' ⟨a, f, rfl, fun i => h' _ _⟩
  rw [supp_eq_of_is_uniform h]
  exact ⟨i, mem_univ i, rfl⟩
#align qpf.liftp_iff_of_is_uniform Qpf.liftp_iff_of_isUniform
-/

#print Qpf.supp_map /-
theorem supp_map (h : q.IsUniform) {α β : Type u} (g : α → β) (x : F α) :
    supp (g <$> x) = g '' supp x := by
  rw [← abs_repr x]; cases' repr x with a f; rw [← abs_map, PFunctor.map_eq]
  rw [supp_eq_of_is_uniform h, supp_eq_of_is_uniform h, image_comp]
#align qpf.supp_map Qpf.supp_map
-/

#print Qpf.suppPreservation_iff_uniform /-
theorem suppPreservation_iff_uniform : q.SuppPreservation ↔ q.IsUniform :=
  by
  constructor
  · intro h α a a' f f' h'
    rw [← PFunctor.supp_eq, ← PFunctor.supp_eq, ← h, h', h]
  · rintro h α ⟨a, f⟩; rwa [supp_eq_of_is_uniform, PFunctor.supp_eq]
#align qpf.supp_preservation_iff_uniform Qpf.suppPreservation_iff_uniform
-/

#print Qpf.suppPreservation_iff_liftpPreservation /-
theorem suppPreservation_iff_liftpPreservation : q.SuppPreservation ↔ q.LiftpPreservation :=
  by
  constructor <;> intro h
  · rintro α p ⟨a, f⟩
    have h' := h; rw [supp_preservation_iff_uniform] at h' 
    dsimp only [supp_preservation, supp] at h 
    rwa [liftp_iff_of_is_uniform, supp_eq_of_is_uniform, PFunctor.liftp_iff'] <;> try assumption
    · simp only [image_univ, mem_range, exists_imp]
      constructor <;> intros <;> subst_vars <;> solve_by_elim
  · rintro α ⟨a, f⟩
    simp only [liftp_preservation] at h 
    simp only [supp, h]
#align qpf.supp_preservation_iff_liftp_preservation Qpf.suppPreservation_iff_liftpPreservation
-/

#print Qpf.liftpPreservation_iff_uniform /-
theorem liftpPreservation_iff_uniform : q.LiftpPreservation ↔ q.IsUniform := by
  rw [← supp_preservation_iff_liftp_preservation, supp_preservation_iff_uniform]
#align qpf.liftp_preservation_iff_uniform Qpf.liftpPreservation_iff_uniform
-/

end Qpf

