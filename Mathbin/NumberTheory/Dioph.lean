/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module number_theory.dioph
! leanprover-community/mathlib commit 087c325ae0ab42dbdd5dee55bc37d3d5a0bf2197
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fin.Fin2
import Mathbin.Data.Pfun
import Mathbin.Data.Vector3
import Mathbin.NumberTheory.PellMatiyasevic

/-!
# Diophantine functions and Matiyasevic's theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Hilbert's tenth problem asked whether there exists an algorithm which for a given integer polynomial
determines whether this polynomial has integer solutions. It was answered in the negative in 1970,
the final step being completed by Matiyasevic who showed that the power function is Diophantine.

Here a function is called Diophantine if its graph is Diophantine as a set. A subset `S ⊆ ℕ ^ α` in
turn is called Diophantine if there exists an integer polynomial on `α ⊕ β` such that `v ∈ S` iff
there exists `t : ℕ^β` with `p (v, t) = 0`.

## Main definitions

* `is_poly`: a predicate stating that a function is a multivariate integer polynomial.
* `poly`: the type of multivariate integer polynomial functions.
* `dioph`: a predicate stating that a set is Diophantine, i.e. a set `S ⊆ ℕ^α` is
  Diophantine if there exists a polynomial on `α ⊕ β` such that `v ∈ S` iff there
  exists `t : ℕ^β` with `p (v, t) = 0`.
* `dioph_fn`: a predicate on a function stating that it is Diophantine in the sense that its graph
  is Diophantine as a set.

## Main statements

* `pell_dioph` states that solutions to Pell's equation form a Diophantine set.
* `pow_dioph` states that the power function is Diophantine, a version of Matiyasevic's theorem.

## References

* [M. Carneiro, _A Lean formalization of Matiyasevic's theorem_][carneiro2018matiyasevic]
* [M. Davis, _Hilbert's tenth problem is unsolvable_][MR317916]

## Tags

Matiyasevic's theorem, Hilbert's tenth problem

## TODO

* Finish the solution of Hilbert's tenth problem.
* Connect `poly` to `mv_polynomial`
-/


open Fin2 Function Nat Sum

local infixr:67 " ::ₒ " => Option.elim'

local infixr:65 " ⊗ " => Sum.elim

universe u

/-!
### Multivariate integer polynomials

Note that this duplicates `mv_polynomial`.
-/


section Polynomials

variable {α β γ : Type _}

#print IsPoly /-
/-- A predicate asserting that a function is a multivariate integer polynomial.
  (We are being a bit lazy here by allowing many representations for multiplication,
  rather than only allowing monomials and addition, but the definition is equivalent
  and this is easier to use.) -/
inductive IsPoly : ((α → ℕ) → ℤ) → Prop
  | proj : ∀ i, IsPoly fun x : α → ℕ => x i
  | const : ∀ n : ℤ, IsPoly fun x : α → ℕ => n
  | sub : ∀ {f g : (α → ℕ) → ℤ}, IsPoly f → IsPoly g → IsPoly fun x => f x - g x
  | mul : ∀ {f g : (α → ℕ) → ℤ}, IsPoly f → IsPoly g → IsPoly fun x => f x * g x
#align is_poly IsPoly
-/

#print IsPoly.neg /-
theorem IsPoly.neg {f : (α → ℕ) → ℤ} : IsPoly f → IsPoly (-f) := by rw [← zero_sub];
  exact (IsPoly.const 0).sub
#align is_poly.neg IsPoly.neg
-/

#print IsPoly.add /-
theorem IsPoly.add {f g : (α → ℕ) → ℤ} (hf : IsPoly f) (hg : IsPoly g) : IsPoly (f + g) := by
  rw [← sub_neg_eq_add]; exact hf.sub hg.neg
#align is_poly.add IsPoly.add
-/

#print Poly /-
/-- The type of multivariate integer polynomials -/
def Poly (α : Type u) :=
  { f : (α → ℕ) → ℤ // IsPoly f }
#align poly Poly
-/

namespace Poly

section

#print Poly.funLike /-
instance funLike : FunLike (Poly α) (α → ℕ) fun _ => ℤ :=
  ⟨Subtype.val, Subtype.val_injective⟩
#align poly.fun_like Poly.funLike
-/

/-- Helper instance for when there are too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (Poly α) fun _ => (α → ℕ) → ℤ :=
  FunLike.hasCoeToFun

#print Poly.isPoly /-
/-- The underlying function of a `poly` is a polynomial -/
protected theorem isPoly (f : Poly α) : IsPoly f :=
  f.2
#align poly.is_poly Poly.isPoly
-/

#print Poly.ext /-
/-- Extensionality for `poly α` -/
@[ext]
theorem ext {f g : Poly α} : (∀ x, f x = g x) → f = g :=
  FunLike.ext _ _
#align poly.ext Poly.ext
-/

#print Poly.proj /-
/-- The `i`th projection function, `x_i`. -/
def proj (i) : Poly α :=
  ⟨_, IsPoly.proj i⟩
#align poly.proj Poly.proj
-/

#print Poly.proj_apply /-
@[simp]
theorem proj_apply (i : α) (x) : proj i x = x i :=
  rfl
#align poly.proj_apply Poly.proj_apply
-/

#print Poly.const /-
/-- The constant function with value `n : ℤ`. -/
def const (n) : Poly α :=
  ⟨_, IsPoly.const n⟩
#align poly.const Poly.const
-/

#print Poly.const_apply /-
@[simp]
theorem const_apply (n) (x : α → ℕ) : const n x = n :=
  rfl
#align poly.const_apply Poly.const_apply
-/

instance : Zero (Poly α) :=
  ⟨const 0⟩

instance : One (Poly α) :=
  ⟨const 1⟩

instance : Neg (Poly α) :=
  ⟨fun f => ⟨-f, f.2.neg⟩⟩

instance : Add (Poly α) :=
  ⟨fun f g => ⟨f + g, f.2.add g.2⟩⟩

instance : Sub (Poly α) :=
  ⟨fun f g => ⟨f - g, f.2.sub g.2⟩⟩

instance : Mul (Poly α) :=
  ⟨fun f g => ⟨f * g, f.2.mul g.2⟩⟩

#print Poly.coe_zero /-
@[simp]
theorem coe_zero : ⇑(0 : Poly α) = const 0 :=
  rfl
#align poly.coe_zero Poly.coe_zero
-/

#print Poly.coe_one /-
@[simp]
theorem coe_one : ⇑(1 : Poly α) = const 1 :=
  rfl
#align poly.coe_one Poly.coe_one
-/

#print Poly.coe_neg /-
@[simp]
theorem coe_neg (f : Poly α) : ⇑(-f) = -f :=
  rfl
#align poly.coe_neg Poly.coe_neg
-/

#print Poly.coe_add /-
@[simp]
theorem coe_add (f g : Poly α) : ⇑(f + g) = f + g :=
  rfl
#align poly.coe_add Poly.coe_add
-/

#print Poly.coe_sub /-
@[simp]
theorem coe_sub (f g : Poly α) : ⇑(f - g) = f - g :=
  rfl
#align poly.coe_sub Poly.coe_sub
-/

#print Poly.coe_mul /-
@[simp]
theorem coe_mul (f g : Poly α) : ⇑(f * g) = f * g :=
  rfl
#align poly.coe_mul Poly.coe_mul
-/

#print Poly.zero_apply /-
@[simp]
theorem zero_apply (x) : (0 : Poly α) x = 0 :=
  rfl
#align poly.zero_apply Poly.zero_apply
-/

#print Poly.one_apply /-
@[simp]
theorem one_apply (x) : (1 : Poly α) x = 1 :=
  rfl
#align poly.one_apply Poly.one_apply
-/

#print Poly.neg_apply /-
@[simp]
theorem neg_apply (f : Poly α) (x) : (-f) x = -f x :=
  rfl
#align poly.neg_apply Poly.neg_apply
-/

#print Poly.add_apply /-
@[simp]
theorem add_apply (f g : Poly α) (x : α → ℕ) : (f + g) x = f x + g x :=
  rfl
#align poly.add_apply Poly.add_apply
-/

#print Poly.sub_apply /-
@[simp]
theorem sub_apply (f g : Poly α) (x : α → ℕ) : (f - g) x = f x - g x :=
  rfl
#align poly.sub_apply Poly.sub_apply
-/

#print Poly.mul_apply /-
@[simp]
theorem mul_apply (f g : Poly α) (x : α → ℕ) : (f * g) x = f x * g x :=
  rfl
#align poly.mul_apply Poly.mul_apply
-/

instance (α : Type _) : Inhabited (Poly α) :=
  ⟨0⟩

instance : AddCommGroup (Poly α) := by
  refine_struct
            { add := ((· + ·) : Poly α → Poly α → Poly α)
              neg := (Neg.neg : Poly α → Poly α)
              sub := Sub.sub
              zero := 0
              zsmul := @zsmulRec _ ⟨(0 : Poly α)⟩ ⟨(· + ·)⟩ ⟨Neg.neg⟩
              nsmul := @nsmulRec _ ⟨(0 : Poly α)⟩ ⟨(· + ·)⟩ } <;>
          intros <;>
        try rfl <;>
      refine' ext fun _ => _ <;>
    simp [sub_eq_add_neg, add_comm, add_assoc]

instance : AddGroupWithOne (Poly α) :=
  { Poly.addCommGroup with
    one := 1
    natCast := fun n => Poly.const n
    intCast := Poly.const }

instance : CommRing (Poly α) := by
  refine_struct
            { Poly.addGroupWithOne,
              Poly.addCommGroup with
              add := ((· + ·) : Poly α → Poly α → Poly α)
              zero := 0
              mul := (· * ·)
              one := 1
              npow := @npowRec _ ⟨(1 : Poly α)⟩ ⟨(· * ·)⟩ } <;>
          intros <;>
        try rfl <;>
      refine' ext fun _ => _ <;>
    simp [sub_eq_add_neg, mul_add, mul_left_comm, mul_comm, add_comm, add_assoc]

#print Poly.induction /-
theorem induction {C : Poly α → Prop} (H1 : ∀ i, C (proj i)) (H2 : ∀ n, C (const n))
    (H3 : ∀ f g, C f → C g → C (f - g)) (H4 : ∀ f g, C f → C g → C (f * g)) (f : Poly α) : C f :=
  by
  cases' f with f pf
  induction' pf with i n f g pf pg ihf ihg f g pf pg ihf ihg
  apply H1; apply H2; apply H3 _ _ ihf ihg; apply H4 _ _ ihf ihg
#align poly.induction Poly.induction
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Poly.sumsq /-
/-- The sum of squares of a list of polynomials. This is relevant for
  Diophantine equations, because it means that a list of equations
  can be encoded as a single equation: `x = 0 ∧ y = 0 ∧ z = 0` is
  equivalent to `x^2 + y^2 + z^2 = 0`. -/
def sumsq : List (Poly α) → Poly α
  | [] => 0
  | p::ps => p * p + sumsq ps
#align poly.sumsq Poly.sumsq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Poly.sumsq_nonneg /-
theorem sumsq_nonneg (x : α → ℕ) : ∀ l, 0 ≤ sumsq l x
  | [] => le_refl 0
  | p::ps => by
    rw [sumsq] <;> simp [-add_comm] <;> exact add_nonneg (mul_self_nonneg _) (sumsq_nonneg ps)
#align poly.sumsq_nonneg Poly.sumsq_nonneg
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Poly.sumsq_eq_zero /-
theorem sumsq_eq_zero (x) : ∀ l, sumsq l x = 0 ↔ l.All₂ fun a : Poly α => a x = 0
  | [] => eq_self_iff_true _
  | p::ps => by
    rw [List.all₂_cons, ← sumsq_eq_zero ps] <;> rw [sumsq] <;> simp [-add_comm] <;>
      exact
        ⟨fun h : p x * p x + sumsq ps x = 0 =>
          have : p x = 0 :=
            eq_zero_of_mul_self_eq_zero <|
              le_antisymm
                (by
                  rw [← h] <;> have t := add_le_add_left (sumsq_nonneg x ps) (p x * p x) <;>
                    rwa [add_zero] at t )
                (mul_self_nonneg _)
          ⟨this, by simp [this] at h  <;> exact h⟩,
          fun ⟨h1, h2⟩ => by rw [h1, h2] <;> rfl⟩
#align poly.sumsq_eq_zero Poly.sumsq_eq_zero
-/

end

#print Poly.map /-
/-- Map the index set of variables, replacing `x_i` with `x_(f i)`. -/
def map {α β} (f : α → β) (g : Poly α) : Poly β :=
  ⟨fun v => g <| v ∘ f,
    g.induction (fun i => by simp <;> apply IsPoly.proj) (fun n => by simp <;> apply IsPoly.const)
      (fun f g pf pg => by simp <;> apply IsPoly.sub pf pg) fun f g pf pg => by
      simp <;> apply IsPoly.mul pf pg⟩
#align poly.map Poly.map
-/

#print Poly.map_apply /-
@[simp]
theorem map_apply {α β} (f : α → β) (g : Poly α) (v) : map f g v = g (v ∘ f) :=
  rfl
#align poly.map_apply Poly.map_apply
-/

end Poly

end Polynomials

/-! ### Diophantine sets -/


#print Dioph /-
/-- A set `S ⊆ ℕ^α` is Diophantine if there exists a polynomial on
  `α ⊕ β` such that `v ∈ S` iff there exists `t : ℕ^β` with `p (v, t) = 0`. -/
def Dioph {α : Type u} (S : Set (α → ℕ)) : Prop :=
  ∃ (β : Type u) (p : Poly (Sum α β)), ∀ v, S v ↔ ∃ t, p (v ⊗ t) = 0
#align dioph Dioph
-/

namespace Dioph

section

variable {α β γ : Type u} {S S' : Set (α → ℕ)}

#print Dioph.ext /-
theorem ext (d : Dioph S) (H : ∀ v, v ∈ S ↔ v ∈ S') : Dioph S' := by rwa [← Set.ext H]
#align dioph.ext Dioph.ext
-/

#print Dioph.of_no_dummies /-
theorem of_no_dummies (S : Set (α → ℕ)) (p : Poly α) (h : ∀ v, S v ↔ p v = 0) : Dioph S :=
  ⟨PEmpty, p.map inl, fun v => (h v).trans ⟨fun h => ⟨PEmpty.rec _, h⟩, fun ⟨t, ht⟩ => ht⟩⟩
#align dioph.of_no_dummies Dioph.of_no_dummies
-/

#print Dioph.inject_dummies_lem /-
theorem inject_dummies_lem (f : β → γ) (g : γ → Option β) (inv : ∀ x, g (f x) = some x)
    (p : Poly (Sum α β)) (v : α → ℕ) :
    (∃ t, p (v ⊗ t) = 0) ↔ ∃ t, p.map (inl ⊗ inr ∘ f) (v ⊗ t) = 0 :=
  by
  dsimp; refine' ⟨fun t => _, fun t => _⟩ <;> cases' t with t ht
  · have : (v ⊗ (0 ::ₒ t) ∘ g) ∘ (inl ⊗ inr ∘ f) = v ⊗ t :=
      funext fun s => by cases' s with a b <;> dsimp [(· ∘ ·)] <;> try rw [inv] <;> rfl
    exact ⟨(0 ::ₒ t) ∘ g, by rwa [this]⟩
  · have : v ⊗ t ∘ f = (v ⊗ t) ∘ (inl ⊗ inr ∘ f) := funext fun s => by cases' s with a b <;> rfl
    exact ⟨t ∘ f, by rwa [this]⟩
#align dioph.inject_dummies_lem Dioph.inject_dummies_lem
-/

#print Dioph.inject_dummies /-
theorem inject_dummies (f : β → γ) (g : γ → Option β) (inv : ∀ x, g (f x) = some x)
    (p : Poly (Sum α β)) (h : ∀ v, S v ↔ ∃ t, p (v ⊗ t) = 0) :
    ∃ q : Poly (Sum α γ), ∀ v, S v ↔ ∃ t, q (v ⊗ t) = 0 :=
  ⟨p.map (inl ⊗ inr ∘ f), fun v => (h v).trans <| inject_dummies_lem f g inv _ _⟩
#align dioph.inject_dummies Dioph.inject_dummies
-/

variable (β)

#print Dioph.reindex_dioph /-
theorem reindex_dioph (f : α → β) : ∀ d : Dioph S, Dioph {v | v ∘ f ∈ S}
  | ⟨γ, p, pe⟩ =>
    ⟨γ, p.map (inl ∘ f ⊗ inr), fun v =>
      (pe _).trans <|
        exists_congr fun t =>
          suffices v ∘ f ⊗ t = (v ⊗ t) ∘ (inl ∘ f ⊗ inr) by simp [this]
          funext fun s => by cases' s with a b <;> rfl⟩
#align dioph.reindex_dioph Dioph.reindex_dioph
-/

variable {β}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Dioph.DiophList.all₂ /-
theorem DiophList.all₂ (l : List (Set <| α → ℕ)) (d : l.All₂ Dioph) :
    Dioph {v | l.All₂ fun S : Set (α → ℕ) => v ∈ S} :=
  by
  suffices
    ∃ (β : _) (pl : List (Poly (Sum α β))),
      ∀ v,
        List.All₂ (fun S : Set _ => S v) l ↔
          ∃ t, List.All₂ (fun p : Poly (Sum α β) => p (v ⊗ t) = 0) pl
    from
    let ⟨β, pl, h⟩ := this
    ⟨β, Poly.sumsq pl, fun v => (h v).trans <| exists_congr fun t => (Poly.sumsq_eq_zero _ _).symm⟩
  induction' l with S l IH
  exact ⟨ULift Empty, [], fun v => by simp <;> exact ⟨fun ⟨t⟩ => Empty.rec _ t, trivial⟩⟩
  simp at d 
  exact
    let ⟨⟨β, p, pe⟩, dl⟩ := d
    let ⟨γ, pl, ple⟩ := IH dl
    ⟨Sum β γ, p.map (inl ⊗ inr ∘ inl)::pl.map fun q => q.map (inl ⊗ inr ∘ inr), fun v => by
      simp <;>
        exact
          Iff.trans (and_congr (pe v) (ple v))
            ⟨fun ⟨⟨m, hm⟩, ⟨n, hn⟩⟩ =>
              ⟨m ⊗ n, by
                rw [show (v ⊗ m ⊗ n) ∘ (inl ⊗ inr ∘ inl) = v ⊗ m from
                      funext fun s => by cases' s with a b <;> rfl] <;>
                  exact hm,
                by
                refine' List.All₂.imp (fun q hq => _) hn; dsimp [(· ∘ ·)]
                rw [show
                      (fun x : Sum α γ => (v ⊗ m ⊗ n) ((inl ⊗ fun x : γ => inr (inr x)) x)) = v ⊗ n
                      from funext fun s => by cases' s with a b <;> rfl] <;>
                  exact hq⟩,
              fun ⟨t, hl, hr⟩ =>
              ⟨⟨t ∘ inl, by
                  rwa [show (v ⊗ t) ∘ (inl ⊗ inr ∘ inl) = v ⊗ t ∘ inl from
                      funext fun s => by cases' s with a b <;> rfl] at
                    hl ⟩,
                ⟨t ∘ inr, by
                  refine' List.All₂.imp (fun q hq => _) hr; dsimp [(· ∘ ·)] at hq 
                  rwa [show
                      (fun x : Sum α γ => (v ⊗ t) ((inl ⊗ fun x : γ => inr (inr x)) x)) =
                        v ⊗ t ∘ inr
                      from funext fun s => by cases' s with a b <;> rfl] at
                    hq ⟩⟩⟩⟩
#align dioph.dioph_list.all₂ Dioph.DiophList.all₂
-/

#print Dioph.inter /-
theorem inter (d : Dioph S) (d' : Dioph S') : Dioph (S ∩ S') :=
  DiophList.all₂ [S, S'] ⟨d, d'⟩
#align dioph.inter Dioph.inter
-/

#print Dioph.union /-
theorem union : ∀ (d : Dioph S) (d' : Dioph S'), Dioph (S ∪ S')
  | ⟨β, p, pe⟩, ⟨γ, q, qe⟩ =>
    ⟨Sum β γ, p.map (inl ⊗ inr ∘ inl) * q.map (inl ⊗ inr ∘ inr), fun v =>
      by
      refine'
        Iff.trans (or_congr ((pe v).trans _) ((qe v).trans _))
          (exists_or_distrib.symm.trans
            (exists_congr fun t =>
              (@mul_eq_zero _ _ _ (p ((v ⊗ t) ∘ (inl ⊗ inr ∘ inl)))
                  (q ((v ⊗ t) ∘ (inl ⊗ inr ∘ inr)))).symm))
      exact inject_dummies_lem _ (some ⊗ fun _ => none) (fun x => rfl) _ _
      exact inject_dummies_lem _ ((fun _ => none) ⊗ some) (fun x => rfl) _ _⟩
#align dioph.union Dioph.union
-/

#print Dioph.DiophPfun /-
/-- A partial function is Diophantine if its graph is Diophantine. -/
def DiophPfun (f : (α → ℕ) →. ℕ) : Prop :=
  Dioph {v : Option α → ℕ | f.graph (v ∘ some, v none)}
#align dioph.dioph_pfun Dioph.DiophPfun
-/

#print Dioph.DiophFn /-
/-- A function is Diophantine if its graph is Diophantine. -/
def DiophFn (f : (α → ℕ) → ℕ) : Prop :=
  Dioph {v : Option α → ℕ | f (v ∘ some) = v none}
#align dioph.dioph_fn Dioph.DiophFn
-/

#print Dioph.reindex_diophFn /-
theorem reindex_diophFn {f : (α → ℕ) → ℕ} (g : α → β) (d : DiophFn f) :
    DiophFn fun v => f (v ∘ g) := by convert reindex_dioph (Option β) (Option.map g) d
#align dioph.reindex_dioph_fn Dioph.reindex_diophFn
-/

#print Dioph.ex_dioph /-
theorem ex_dioph {S : Set (Sum α β → ℕ)} : Dioph S → Dioph {v | ∃ x, v ⊗ x ∈ S}
  | ⟨γ, p, pe⟩ =>
    ⟨Sum β γ, p.map ((inl ⊗ inr ∘ inl) ⊗ inr ∘ inr), fun v =>
      ⟨fun ⟨x, hx⟩ =>
        let ⟨t, ht⟩ := (pe _).1 hx
        ⟨x ⊗ t, by
          simp <;>
              rw [show (v ⊗ x ⊗ t) ∘ ((inl ⊗ inr ∘ inl) ⊗ inr ∘ inr) = (v ⊗ x) ⊗ t from
                  funext fun s => by cases' s with a b <;> try cases a <;> rfl] <;>
            exact ht⟩,
        fun ⟨t, ht⟩ =>
        ⟨t ∘ inl,
          (pe _).2
            ⟨t ∘ inr, by
              simp at ht  <;>
                rwa [show (v ⊗ t) ∘ ((inl ⊗ inr ∘ inl) ⊗ inr ∘ inr) = (v ⊗ t ∘ inl) ⊗ t ∘ inr from
                    funext fun s => by cases' s with a b <;> try cases a <;> rfl] at
                  ht ⟩⟩⟩⟩
#align dioph.ex_dioph Dioph.ex_dioph
-/

#print Dioph.ex1_dioph /-
theorem ex1_dioph {S : Set (Option α → ℕ)} : Dioph S → Dioph {v | ∃ x, x ::ₒ v ∈ S}
  | ⟨β, p, pe⟩ =>
    ⟨Option β, p.map (inr none ::ₒ inl ⊗ inr ∘ some), fun v =>
      ⟨fun ⟨x, hx⟩ =>
        let ⟨t, ht⟩ := (pe _).1 hx
        ⟨x ::ₒ t, by
          simp <;>
              rw [show (v ⊗ x ::ₒ t) ∘ (inr none ::ₒ inl ⊗ inr ∘ some) = x ::ₒ v ⊗ t from
                  funext fun s => by cases' s with a b <;> try cases a <;> rfl] <;>
            exact ht⟩,
        fun ⟨t, ht⟩ =>
        ⟨t none,
          (pe _).2
            ⟨t ∘ some, by
              simp at ht  <;>
                rwa [show (v ⊗ t) ∘ (inr none ::ₒ inl ⊗ inr ∘ some) = t none ::ₒ v ⊗ t ∘ some from
                    funext fun s => by cases' s with a b <;> try cases a <;> rfl] at
                  ht ⟩⟩⟩⟩
#align dioph.ex1_dioph Dioph.ex1_dioph
-/

#print Dioph.dom_dioph /-
theorem dom_dioph {f : (α → ℕ) →. ℕ} (d : DiophPfun f) : Dioph f.Dom :=
  cast (congr_arg Dioph <| Set.ext fun v => (PFun.dom_iff_graph _ _).symm) (ex1_dioph d)
#align dioph.dom_dioph Dioph.dom_dioph
-/

#print Dioph.diophFn_iff_pFun /-
theorem diophFn_iff_pFun (f : (α → ℕ) → ℕ) : DiophFn f = @DiophPfun α f := by
  refine' congr_arg Dioph (Set.ext fun v => _) <;> exact pfun.lift_graph.symm
#align dioph.dioph_fn_iff_pfun Dioph.diophFn_iff_pFun
-/

#print Dioph.abs_poly_dioph /-
theorem abs_poly_dioph (p : Poly α) : DiophFn fun v => (p v).natAbs :=
  of_no_dummies _ ((p.map some - Poly.proj none) * (p.map some + Poly.proj none)) fun v => by dsimp;
    exact Int.eq_natAbs_iff_mul_eq_zero
#align dioph.abs_poly_dioph Dioph.abs_poly_dioph
-/

#print Dioph.proj_dioph /-
theorem proj_dioph (i : α) : DiophFn fun v => v i :=
  abs_poly_dioph (Poly.proj i)
#align dioph.proj_dioph Dioph.proj_dioph
-/

#print Dioph.diophPfun_comp1 /-
theorem diophPfun_comp1 {S : Set (Option α → ℕ)} (d : Dioph S) {f} (df : DiophPfun f) :
    Dioph {v : α → ℕ | ∃ h : f.Dom v, f.fn v h ::ₒ v ∈ S} :=
  ext (ex1_dioph (d.inter df)) fun v =>
    ⟨fun ⟨x, hS, (h : Exists _)⟩ => by
      rw [show (x ::ₒ v) ∘ some = v from funext fun s => rfl] at h  <;> cases' h with hf h <;>
            refine' ⟨hf, _⟩ <;>
          rw [PFun.fn, h] <;>
        exact hS,
      fun ⟨x, hS⟩ =>
      ⟨f.fn v x, hS,
        show Exists _ by
          rw [show (f.fn v x ::ₒ v) ∘ some = v from funext fun s => rfl] <;> exact ⟨x, rfl⟩⟩⟩
#align dioph.dioph_pfun_comp1 Dioph.diophPfun_comp1
-/

#print Dioph.diophFn_comp1 /-
theorem diophFn_comp1 {S : Set (Option α → ℕ)} (d : Dioph S) {f : (α → ℕ) → ℕ} (df : DiophFn f) :
    Dioph {v | f v ::ₒ v ∈ S} :=
  ext (diophPfun_comp1 d <| cast (diophFn_iff_pFun f) df) fun v =>
    ⟨fun ⟨_, h⟩ => h, fun h => ⟨trivial, h⟩⟩
#align dioph.dioph_fn_comp1 Dioph.diophFn_comp1
-/

end

section

variable {α β : Type} {n : ℕ}

open Vector3

open scoped Vector3

attribute [local reducible] Vector3

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Dioph.diophFn_vec_comp1 /-
theorem diophFn_vec_comp1 {S : Set (Vector3 ℕ (succ n))} (d : Dioph S) {f : Vector3 ℕ n → ℕ}
    (df : DiophFn f) : Dioph {v : Vector3 ℕ n | (f v::v) ∈ S} :=
  ext (diophFn_comp1 (reindex_dioph _ (none::some) d) df) fun v => by dsimp; congr; ext x;
    cases x <;> rfl
#align dioph.dioph_fn_vec_comp1 Dioph.diophFn_vec_comp1
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Dioph.vec_ex1_dioph /-
theorem vec_ex1_dioph (n) {S : Set (Vector3 ℕ (succ n))} (d : Dioph S) :
    Dioph {v : Fin2 n → ℕ | ∃ x, (x::v) ∈ S} :=
  ext (ex1_dioph <| reindex_dioph _ (none::some) d) fun v =>
    exists_congr fun x => by
      dsimp
      rw [show Option.elim' x v ∘ cons none some = x::v from
          funext fun s => by cases' s with a b <;> rfl]
#align dioph.vec_ex1_dioph Dioph.vec_ex1_dioph
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Dioph.diophFn_vec /-
theorem diophFn_vec (f : Vector3 ℕ n → ℕ) : DiophFn f ↔ Dioph {v | f (v ∘ fs) = v fz} :=
  ⟨reindex_dioph _ (fz ::ₒ fs), reindex_dioph _ (none::some)⟩
#align dioph.dioph_fn_vec Dioph.diophFn_vec
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Dioph.diophPfun_vec /-
theorem diophPfun_vec (f : Vector3 ℕ n →. ℕ) : DiophPfun f ↔ Dioph {v | f.graph (v ∘ fs, v fz)} :=
  ⟨reindex_dioph _ (fz ::ₒ fs), reindex_dioph _ (none::some)⟩
#align dioph.dioph_pfun_vec Dioph.diophPfun_vec
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Dioph.diophFn_compn /-
theorem diophFn_compn :
    ∀ {n} {S : Set (Sum α (Fin2 n) → ℕ)} (d : Dioph S) {f : Vector3 ((α → ℕ) → ℕ) n}
      (df : VectorAllP DiophFn f), Dioph {v : α → ℕ | (v ⊗ fun i => f i v) ∈ S}
  | 0, S, d, f => fun df =>
    ext (reindex_dioph _ (id ⊗ Fin2.elim0) d) fun v => by dsimp; congr; ext x;
      obtain _ | _ | _ := x; rfl
  | succ n, S, d, f =>
    f.consElim fun f fl => by
      simp <;>
        exact fun df dfl =>
          have : Dioph {v | (v ∘ inl ⊗ f (v ∘ inl)::v ∘ inr) ∈ S} :=
            ext
              (dioph_fn_comp1 (reindex_dioph _ (some ∘ inl ⊗ none::some ∘ inr) d) <|
                reindex_dioph_fn inl df)
              fun v => by dsimp; congr; ext x; obtain _ | _ | _ := x <;> rfl
          have : Dioph {v | (v ⊗ f v::fun i : Fin2 n => fl i v) ∈ S} :=
            @dioph_fn_compn n (fun v => S (v ∘ inl ⊗ f (v ∘ inl)::v ∘ inr)) this _ dfl
          ext this fun v => by dsimp; congr; ext x; obtain _ | _ | _ := x <;> rfl
#align dioph.dioph_fn_compn Dioph.diophFn_compn
-/

#print Dioph.dioph_comp /-
theorem dioph_comp {S : Set (Vector3 ℕ n)} (d : Dioph S) (f : Vector3 ((α → ℕ) → ℕ) n)
    (df : VectorAllP DiophFn f) : Dioph {v | (fun i => f i v) ∈ S} :=
  diophFn_compn (reindex_dioph _ inr d) df
#align dioph.dioph_comp Dioph.dioph_comp
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Dioph.diophFn_comp /-
theorem diophFn_comp {f : Vector3 ℕ n → ℕ} (df : DiophFn f) (g : Vector3 ((α → ℕ) → ℕ) n)
    (dg : VectorAllP DiophFn g) : DiophFn fun v => f fun i => g i v :=
  dioph_comp ((diophFn_vec _).1 df) ((fun v => v none)::fun i v => g i (v ∘ some)) <| by
    simp <;>
      exact
        ⟨proj_dioph none,
          (vectorAllP_iff_forall _ _).2 fun i =>
            reindex_dioph_fn _ <| (vectorAllP_iff_forall _ _).1 dg _⟩
#align dioph.dioph_fn_comp Dioph.diophFn_comp
-/

scoped notation:35 x " D∧ " y => Dioph.inter x y

scoped notation:35 x " D∨ " y => Dioph.union x y

scoped notation:30 "D∃" => Dioph.vec_ex1_dioph

scoped prefix:arg "&" => Fin2.ofNat'

#print Dioph.proj_dioph_of_nat /-
theorem proj_dioph_of_nat {n : ℕ} (m : ℕ) [IsLT m n] : DiophFn fun v : Vector3 ℕ n => v &m :=
  proj_dioph &m
#align dioph.proj_dioph_of_nat Dioph.proj_dioph_of_nat
-/

scoped prefix:100 "D&" => Dioph.proj_dioph_of_nat

#print Dioph.const_dioph /-
theorem const_dioph (n : ℕ) : DiophFn (const (α → ℕ) n) :=
  abs_poly_dioph (Poly.const n)
#align dioph.const_dioph Dioph.const_dioph
-/

scoped prefix:100 "D." => Dioph.const_dioph

variable {f g : (α → ℕ) → ℕ} (df : DiophFn f) (dg : DiophFn g)

#print Dioph.dioph_comp2 /-
theorem dioph_comp2 {S : ℕ → ℕ → Prop} (d : Dioph fun v : Vector3 ℕ 2 => S (v &0) (v &1)) :
    Dioph fun v => S (f v) (g v) :=
  dioph_comp d [f, g] ⟨df, dg⟩
#align dioph.dioph_comp2 Dioph.dioph_comp2
-/

#print Dioph.diophFn_comp2 /-
theorem diophFn_comp2 {h : ℕ → ℕ → ℕ} (d : DiophFn fun v : Vector3 ℕ 2 => h (v &0) (v &1)) :
    DiophFn fun v => h (f v) (g v) :=
  diophFn_comp d [f, g] ⟨df, dg⟩
#align dioph.dioph_fn_comp2 Dioph.diophFn_comp2
-/

#print Dioph.eq_dioph /-
theorem eq_dioph : Dioph fun v => f v = g v :=
  dioph_comp2 df dg <|
    of_no_dummies _ (Poly.proj &0 - Poly.proj &1) fun v =>
      (Int.ofNat_inj _ _).symm.trans ⟨@sub_eq_zero_of_eq ℤ _ (v &0) (v &1), eq_of_sub_eq_zero⟩
#align dioph.eq_dioph Dioph.eq_dioph
-/

scoped infixl:50 " D= " => Dioph.eq_dioph

#print Dioph.add_dioph /-
theorem add_dioph : DiophFn fun v => f v + g v :=
  diophFn_comp2 df dg <| abs_poly_dioph (Poly.proj &0 + Poly.proj &1)
#align dioph.add_dioph Dioph.add_dioph
-/

scoped infixl:80 " D+ " => Dioph.add_dioph

#print Dioph.mul_dioph /-
theorem mul_dioph : DiophFn fun v => f v * g v :=
  diophFn_comp2 df dg <| abs_poly_dioph (Poly.proj &0 * Poly.proj &1)
#align dioph.mul_dioph Dioph.mul_dioph
-/

scoped infixl:90 " D* " => Dioph.mul_dioph

#print Dioph.le_dioph /-
theorem le_dioph : Dioph {v | f v ≤ g v} :=
  dioph_comp2 df dg <|
    ext ((D∃) 2 <| D&1 D+ D&0 D= D&2) fun v => ⟨fun ⟨x, hx⟩ => le.intro hx, le.dest⟩
#align dioph.le_dioph Dioph.le_dioph
-/

scoped infixl:50 " D≤ " => Dioph.le_dioph

#print Dioph.lt_dioph /-
theorem lt_dioph : Dioph {v | f v < g v} :=
  df D+ D.1 D≤ dg
#align dioph.lt_dioph Dioph.lt_dioph
-/

scoped infixl:50 " D< " => Dioph.lt_dioph

#print Dioph.ne_dioph /-
theorem ne_dioph : Dioph {v | f v ≠ g v} :=
  ext (df D< dg D∨ dg D< df) fun v => by dsimp; exact lt_or_lt_iff_ne
#align dioph.ne_dioph Dioph.ne_dioph
-/

scoped infixl:50 " D≠ " => Dioph.ne_dioph

#print Dioph.sub_dioph /-
theorem sub_dioph : DiophFn fun v => f v - g v :=
  diophFn_comp2 df dg <|
    (diophFn_vec _).2 <|
      ext (D&1 D= D&0 D+ D&2 D∨ D&1 D≤ D&2 D∧ D&0 D= D.0) <|
        (vectorAll_iff_forall _).1 fun x y z =>
          show y = x + z ∨ y ≤ z ∧ x = 0 ↔ y - z = x from
            ⟨fun o => by
              rcases o with (ae | ⟨yz, x0⟩)
              · rw [ae, add_tsub_cancel_right]
              · rw [x0, tsub_eq_zero_iff_le.mpr yz],
              by
              rintro rfl
              cases' le_total y z with yz zy
              · exact Or.inr ⟨yz, tsub_eq_zero_iff_le.mpr yz⟩
              · exact Or.inl (tsub_add_cancel_of_le zy).symm⟩
#align dioph.sub_dioph Dioph.sub_dioph
-/

scoped infixl:80 " D- " => Dioph.sub_dioph

#print Dioph.dvd_dioph /-
theorem dvd_dioph : Dioph fun v => f v ∣ g v :=
  dioph_comp ((D∃) 2 <| D&2 D= D&1 D* D&0) [f, g] ⟨df, dg⟩
#align dioph.dvd_dioph Dioph.dvd_dioph
-/

scoped infixl:50 " D∣ " => Dioph.dvd_dioph

#print Dioph.mod_dioph /-
theorem mod_dioph : DiophFn fun v => f v % g v :=
  have : Dioph fun v : Vector3 ℕ 3 => (v &2 = 0 ∨ v &0 < v &2) ∧ ∃ x : ℕ, v &0 + v &2 * x = v &1 :=
    (D&2 D= D.0 D∨ D&0 D< D&2) D∧ (D∃) 3 <| D&1 D+ D&3 D* D&0 D= D&2
  diophFn_comp2 df dg <|
    (diophFn_vec _).2 <|
      ext this <|
        (vectorAll_iff_forall _).1 fun z x y =>
          show ((y = 0 ∨ z < y) ∧ ∃ c, z + y * c = x) ↔ x % y = z from
            ⟨fun ⟨h, c, hc⟩ => by
              rw [← hc] <;> simp <;> cases' h with x0 hl; rw [x0, mod_zero]
              exact mod_eq_of_lt hl, fun e => by
              rw [← e] <;>
                exact
                  ⟨or_iff_not_imp_left.2 fun h => mod_lt _ (Nat.pos_of_ne_zero h), x / y,
                    mod_add_div _ _⟩⟩
#align dioph.mod_dioph Dioph.mod_dioph
-/

scoped infixl:80 " D% " => Dioph.mod_dioph

#print Dioph.modEq_dioph /-
theorem modEq_dioph {h : (α → ℕ) → ℕ} (dh : DiophFn h) : Dioph fun v => f v ≡ g v [MOD h v] :=
  df D% dh D= dg D% dh
#align dioph.modeq_dioph Dioph.modEq_dioph
-/

scoped notation " D≡ " => Dioph.modEq_dioph

#print Dioph.div_dioph /-
theorem div_dioph : DiophFn fun v => f v / g v :=
  have :
    Dioph fun v : Vector3 ℕ 3 =>
      v &2 = 0 ∧ v &0 = 0 ∨ v &0 * v &2 ≤ v &1 ∧ v &1 < (v &0 + 1) * v &2 :=
    (D&2 D= D.0 D∧ D&0 D= D.0) D∨ D&0 D* D&2 D≤ D&1 D∧ D&1 D< (D&0 D+ D.1) D* D&2
  diophFn_comp2 df dg <|
    (diophFn_vec _).2 <|
      ext this <|
        (vectorAll_iff_forall _).1 fun z x y =>
          show y = 0 ∧ z = 0 ∨ z * y ≤ x ∧ x < (z + 1) * y ↔ x / y = z by
            refine' Iff.trans _ eq_comm <;>
              exact
                y.eq_zero_or_pos.elim
                  (fun y0 => by
                    rw [y0, Nat.div_zero] <;>
                      exact
                        ⟨fun o => (o.resolve_right fun ⟨_, h2⟩ => Nat.not_lt_zero _ h2).right,
                          fun z0 => Or.inl ⟨rfl, z0⟩⟩)
                  fun ypos =>
                  Iff.trans ⟨fun o => o.resolve_left fun ⟨h1, _⟩ => ne_of_gt ypos h1, Or.inr⟩
                    (le_antisymm_iff.trans <|
                        and_congr (Nat.le_div_iff_mul_le ypos) <|
                          Iff.trans ⟨lt_succ_of_le, le_of_lt_succ⟩ (div_lt_iff_lt_mul ypos)).symm
#align dioph.div_dioph Dioph.div_dioph
-/

scoped infixl:80 " D/ " => Dioph.div_dioph

open Pell

#print Dioph.pell_dioph /-
theorem pell_dioph :
    Dioph fun v : Vector3 ℕ 4 => ∃ h : 1 < v &0, xn h (v &1) = v &2 ∧ yn h (v &1) = v &3 :=
  have :
    Dioph
      {v : Vector3 ℕ 4 |
        1 < v &0 ∧
          v &1 ≤ v &3 ∧
            (v &2 = 1 ∧ v &3 = 0 ∨
              ∃ u w s t b : ℕ,
                v &2 * v &2 - (v &0 * v &0 - 1) * v &3 * v &3 = 1 ∧
                  u * u - (v &0 * v &0 - 1) * w * w = 1 ∧
                    s * s - (b * b - 1) * t * t = 1 ∧
                      1 < b ∧
                        b ≡ 1 [MOD 4 * v &3] ∧
                          b ≡ v &0 [MOD u] ∧
                            0 < w ∧
                              v &3 * v &3 ∣ w ∧ s ≡ v &2 [MOD u] ∧ t ≡ v &1 [MOD 4 * v &3])} :=
    D.1 D< D&0 D∧
      D&1 D≤ D&3 D∧
        (D&2 D= D.1 D∧ D&3 D= D.0) D∨
          (D∃) 4 <|
            (D∃) 5 <|
              (D∃) 6 <|
                (D∃) 7 <|
                  (D∃) 8 <|
                    D&7 D* D&7 D- (D&5 D* D&5 D- D.1) D* D&8 D* D&8 D= D.1 D∧
                      D&4 D* D&4 D- (D&5 D* D&5 D- D.1) D* D&3 D* D&3 D= D.1 D∧
                        D&2 D* D&2 D- (D&0 D* D&0 D- D.1) D* D&1 D* D&1 D= D.1 D∧
                          D.1 D<
                              D&0 D∧ D≡ (D&0) (D.1)
                                (D.4 D*
                                  D&8) D∧ D≡ (D&0) (D&5) (D&4) D∧
                                D.0 D< D&3 D∧
                                  D&8 D* D&8 D∣
                                      D&3 D∧ D≡ (D&2) (D&7) (D&4) D∧ D≡ (D&1) (D&6) (D.4 D* D&8)
  Dioph.ext this fun v => matiyasevic.symm
#align dioph.pell_dioph Dioph.pell_dioph
-/

#print Dioph.xn_dioph /-
theorem xn_dioph : DiophPfun fun v : Vector3 ℕ 2 => ⟨1 < v &0, fun h => xn h (v &1)⟩ :=
  have : Dioph fun v : Vector3 ℕ 3 => ∃ y, ∃ h : 1 < v &1, xn h (v &2) = v &0 ∧ yn h (v &2) = y :=
    let D_pell := pell_dioph.reindex_dioph (Fin2 4) [&2, &3, &1, &0]
    (D∃) 3 D_pell
  (diophPfun_vec _).2 <|
    Dioph.ext this fun v => ⟨fun ⟨y, h, xe, ye⟩ => ⟨h, xe⟩, fun ⟨h, xe⟩ => ⟨_, h, xe, rfl⟩⟩
#align dioph.xn_dioph Dioph.xn_dioph
-/

#print Dioph.pow_dioph /-
/-- A version of **Matiyasevic's theorem** -/
theorem pow_dioph : DiophFn fun v => f v ^ g v :=
  have :
    Dioph
      {v : Vector3 ℕ 3 |
        v &2 = 0 ∧ v &0 = 1 ∨
          0 < v &2 ∧
            (v &1 = 0 ∧ v &0 = 0 ∨
              0 < v &1 ∧
                ∃ w a t z x y : ℕ,
                  (∃ a1 : 1 < a, xn a1 (v &2) = x ∧ yn a1 (v &2) = y) ∧
                    x ≡ y * (a - v &1) + v &0 [MOD t] ∧
                      2 * a * v &1 = t + (v &1 * v &1 + 1) ∧
                        v &0 < t ∧
                          v &1 ≤ w ∧
                            v &2 ≤ w ∧ a * a - ((w + 1) * (w + 1) - 1) * (w * z) * (w * z) = 1)} :=
    let D_pell := pell_dioph.reindex_dioph (Fin2 9) [&4, &8, &1, &0]
    (D&2 D= D.0 D∧ D&0 D= D.1) D∨
      D.0 D< D&2 D∧
        (D&1 D= D.0 D∧ D&0 D= D.0) D∨
          D.0 D< D&1 D∧
            (D∃) 3 <|
              (D∃) 4 <|
                (D∃) 5 <|
                  (D∃) 6 <|
                    (D∃) 7 <|
                      (D∃) 8 <|
                        D_pell D∧ D≡ (D&1) (D&0 D* (D&4 D- D&7) D+ D&6) (D&3) D∧
                            D.2 D* D&4 D* D&7 D= D&3 D+ (D&7 D* D&7 D+ D.1) D∧
                              D&6 D< D&3 D∧
                                D&7 D≤ D&5 D∧
                                  D&8 D≤ D&5 D∧
                                    D&4 D* D&4 D-
                                        ((D&5 D+ D.1) D* (D&5 D+ D.1) D- D.1) D* (D&5 D* D&2) D*
                                          (D&5 D* D&2) D=
                                      D.1
  diophFn_comp2 df dg <|
    (diophFn_vec _).2 <|
      Dioph.ext this fun v =>
        Iff.symm <|
          eq_pow_of_pell.trans <|
            or_congr Iff.rfl <|
              and_congr Iff.rfl <|
                or_congr Iff.rfl <|
                  and_congr Iff.rfl <|
                    ⟨fun ⟨w, a, t, z, a1, h⟩ => ⟨w, a, t, z, _, _, ⟨a1, rfl, rfl⟩, h⟩,
                      fun ⟨w, a, t, z, _, _, ⟨a1, rfl, rfl⟩, h⟩ => ⟨w, a, t, z, a1, h⟩⟩
#align dioph.pow_dioph Dioph.pow_dioph
-/

end

end Dioph

