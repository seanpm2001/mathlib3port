/-
Copyright (c) 2018 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.traversable.basic
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Functor
import Mathbin.Tactic.Ext

/-!
# Traversable type class

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Type classes for traversing collections. The concepts and laws are taken from
<http://hackage.haskell.org/package/base-4.11.1.0/docs/Data-Traversable.html>

Traversable collections are a generalization of functors. Whereas
functors (such as `list`) allow us to apply a function to every
element, it does not allow functions which external effects encoded in
a monad. Consider for instance a functor `invite : email → io response`
that takes an email address, sends an email and waits for a
response. If we have a list `guests : list email`, using calling
`invite` using `map` gives us the following: `map invite guests : list
(io response)`.  It is not what we need. We need something of type `io
(list response)`. Instead of using `map`, we can use `traverse` to
send all the invites: `traverse invite guests : io (list response)`.
`traverse` applies `invite` to every element of `guests` and combines
all the resulting effects. In the example, the effect is encoded in the
monad `io` but any applicative functor is accepted by `traverse`.

For more on how to use traversable, consider the Haskell tutorial:
<https://en.wikibooks.org/wiki/Haskell/Traversable>

## Main definitions
  * `traversable` type class - exposes the `traverse` function
  * `sequence` - based on `traverse`,
    turns a collection of effects into an effect returning a collection
  * `is_lawful_traversable` - laws for a traversable functor
  * `applicative_transformation` - the notion of a natural transformation for applicative functors

## Tags

traversable iterator functor applicative

## References

 * "Applicative Programming with Effects", by Conor McBride and Ross Paterson,
   Journal of Functional Programming 18:1 (2008) 1-13, online at
   <http://www.soi.city.ac.uk/~ross/papers/Applicative.html>
 * "The Essence of the Iterator Pattern", by Jeremy Gibbons and Bruno Oliveira,
   in Mathematically-Structured Functional Programming, 2006, online at
   <http://web.comlab.ox.ac.uk/oucl/work/jeremy.gibbons/publications/#iterator>
 * "An Investigation of the Laws of Traversals", by Mauro Jaskelioff and Ondrej Rypacek,
   in Mathematically-Structured Functional Programming, 2012,
   online at <http://arxiv.org/pdf/1202.2919>
-/


open Function hiding comp

universe u v w

section ApplicativeTransformation

variable (F : Type u → Type v) [Applicative F] [LawfulApplicative F]

variable (G : Type u → Type w) [Applicative G] [LawfulApplicative G]

#print ApplicativeTransformation /-
/-- A transformation between applicative functors.  It is a natural
transformation such that `app` preserves the `has_pure.pure` and
`functor.map` (`<*>`) operations. See
`applicative_transformation.preserves_map` for naturality. -/
structure ApplicativeTransformation : Type max (u + 1) v w where
  app : ∀ α : Type u, F α → G α
  preserves_pure' : ∀ {α : Type u} (x : α), app _ (pure x) = pure x
  preserves_seq' : ∀ {α β : Type u} (x : F (α → β)) (y : F α), app _ (x <*> y) = app _ x <*> app _ y
#align applicative_transformation ApplicativeTransformation
-/

end ApplicativeTransformation

namespace ApplicativeTransformation

variable (F : Type u → Type v) [Applicative F] [LawfulApplicative F]

variable (G : Type u → Type w) [Applicative G] [LawfulApplicative G]

instance : CoeFun (ApplicativeTransformation F G) fun _ => ∀ {α}, F α → G α :=
  ⟨ApplicativeTransformation.app⟩

variable {F G}

#print ApplicativeTransformation.app_eq_coe /-
@[simp]
theorem app_eq_coe (η : ApplicativeTransformation F G) : η.app = η :=
  rfl
#align applicative_transformation.app_eq_coe ApplicativeTransformation.app_eq_coe
-/

#print ApplicativeTransformation.coe_mk /-
@[simp]
theorem coe_mk (f : ∀ α : Type u, F α → G α) (pp ps) :
    ⇑(ApplicativeTransformation.mk f pp ps) = f :=
  rfl
#align applicative_transformation.coe_mk ApplicativeTransformation.coe_mk
-/

#print ApplicativeTransformation.congr_fun /-
protected theorem congr_fun (η η' : ApplicativeTransformation F G) (h : η = η') {α : Type u}
    (x : F α) : η x = η' x :=
  congr_arg (fun η'' : ApplicativeTransformation F G => η'' x) h
#align applicative_transformation.congr_fun ApplicativeTransformation.congr_fun
-/

#print ApplicativeTransformation.congr_arg /-
protected theorem congr_arg (η : ApplicativeTransformation F G) {α : Type u} {x y : F α}
    (h : x = y) : η x = η y :=
  congr_arg (fun z : F α => η z) h
#align applicative_transformation.congr_arg ApplicativeTransformation.congr_arg
-/

#print ApplicativeTransformation.coe_inj /-
theorem coe_inj ⦃η η' : ApplicativeTransformation F G⦄ (h : (η : ∀ α, F α → G α) = η') : η = η' :=
  by cases η; cases η'; congr; exact h
#align applicative_transformation.coe_inj ApplicativeTransformation.coe_inj
-/

#print ApplicativeTransformation.ext /-
@[ext]
theorem ext ⦃η η' : ApplicativeTransformation F G⦄ (h : ∀ (α : Type u) (x : F α), η x = η' x) :
    η = η' := by apply coe_inj; ext1 α; exact funext (h α)
#align applicative_transformation.ext ApplicativeTransformation.ext
-/

#print ApplicativeTransformation.ext_iff /-
theorem ext_iff {η η' : ApplicativeTransformation F G} :
    η = η' ↔ ∀ (α : Type u) (x : F α), η x = η' x :=
  ⟨fun h α x => h ▸ rfl, fun h => ext h⟩
#align applicative_transformation.ext_iff ApplicativeTransformation.ext_iff
-/

section Preserves

variable (η : ApplicativeTransformation F G)

#print ApplicativeTransformation.preserves_pure /-
@[functor_norm]
theorem preserves_pure {α} : ∀ x : α, η (pure x) = pure x :=
  η.preserves_pure'
#align applicative_transformation.preserves_pure ApplicativeTransformation.preserves_pure
-/

#print ApplicativeTransformation.preserves_seq /-
@[functor_norm]
theorem preserves_seq {α β : Type u} : ∀ (x : F (α → β)) (y : F α), η (x <*> y) = η x <*> η y :=
  η.preserves_seq'
#align applicative_transformation.preserves_seq ApplicativeTransformation.preserves_seq
-/

#print ApplicativeTransformation.preserves_map /-
@[functor_norm]
theorem preserves_map {α β} (x : α → β) (y : F α) : η (x <$> y) = x <$> η y := by
  rw [← pure_seq_eq_map, η.preserves_seq] <;> simp [functor_norm]
#align applicative_transformation.preserves_map ApplicativeTransformation.preserves_map
-/

#print ApplicativeTransformation.preserves_map' /-
theorem preserves_map' {α β} (x : α → β) : @η _ ∘ Functor.map x = Functor.map x ∘ @η _ := by ext y;
  exact preserves_map η x y
#align applicative_transformation.preserves_map' ApplicativeTransformation.preserves_map'
-/

end Preserves

#print ApplicativeTransformation.idTransformation /-
/-- The identity applicative transformation from an applicative functor to itself. -/
def idTransformation : ApplicativeTransformation F F
    where
  app α := id
  preserves_pure' := by simp
  preserves_seq' α β x y := by simp
#align applicative_transformation.id_transformation ApplicativeTransformation.idTransformation
-/

instance : Inhabited (ApplicativeTransformation F F) :=
  ⟨idTransformation⟩

universe s t

variable {H : Type u → Type s} [Applicative H] [LawfulApplicative H]

#print ApplicativeTransformation.comp /-
/-- The composition of applicative transformations. -/
def comp (η' : ApplicativeTransformation G H) (η : ApplicativeTransformation F G) :
    ApplicativeTransformation F H where
  app α x := η' (η x)
  preserves_pure' α x := by simp [functor_norm]
  preserves_seq' α β x y := by simp [functor_norm]
#align applicative_transformation.comp ApplicativeTransformation.comp
-/

#print ApplicativeTransformation.comp_apply /-
@[simp]
theorem comp_apply (η' : ApplicativeTransformation G H) (η : ApplicativeTransformation F G)
    {α : Type u} (x : F α) : η'.comp η x = η' (η x) :=
  rfl
#align applicative_transformation.comp_apply ApplicativeTransformation.comp_apply
-/

#print ApplicativeTransformation.comp_assoc /-
theorem comp_assoc {I : Type u → Type t} [Applicative I] [LawfulApplicative I]
    (η'' : ApplicativeTransformation H I) (η' : ApplicativeTransformation G H)
    (η : ApplicativeTransformation F G) : (η''.comp η').comp η = η''.comp (η'.comp η) :=
  rfl
#align applicative_transformation.comp_assoc ApplicativeTransformation.comp_assoc
-/

#print ApplicativeTransformation.comp_id /-
@[simp]
theorem comp_id (η : ApplicativeTransformation F G) : η.comp idTransformation = η :=
  ext fun α x => rfl
#align applicative_transformation.comp_id ApplicativeTransformation.comp_id
-/

#print ApplicativeTransformation.id_comp /-
@[simp]
theorem id_comp (η : ApplicativeTransformation F G) : idTransformation.comp η = η :=
  ext fun α x => rfl
#align applicative_transformation.id_comp ApplicativeTransformation.id_comp
-/

end ApplicativeTransformation

open ApplicativeTransformation

#print Traversable /-
/-- A traversable functor is a functor along with a way to commute
with all applicative functors (see `sequence`).  For example, if `t`
is the traversable functor `list` and `m` is the applicative functor
`io`, then given a function `f : α → io β`, the function `functor.map f` is
`list α → list (io β)`, but `traverse f` is `list α → io (list β)`. -/
class Traversable (t : Type u → Type u) extends Functor t where
  traverse : ∀ {m : Type u → Type u} [Applicative m] {α β}, (α → m β) → t α → m (t β)
#align traversable Traversable
-/

open Functor

export Traversable (traverse)

section Functions

variable {t : Type u → Type u}

variable {m : Type u → Type v} [Applicative m]

variable {α β : Type u}

variable {f : Type u → Type u} [Applicative f]

#print sequence /-
/-- A traversable functor commutes with all applicative functors. -/
def sequence [Traversable t] : t (f α) → f (t α) :=
  traverse id
#align sequence sequence
-/

end Functions

#print IsLawfulTraversable /-
/-- A traversable functor is lawful if its `traverse` satisfies a
number of additional properties.  It must send `id.mk` to `id.mk`,
send the composition of applicative functors to the composition of the
`traverse` of each, send each function `f` to `λ x, f <$> x`, and
satisfy a naturality condition with respect to applicative
transformations. -/
class IsLawfulTraversable (t : Type u → Type u) [Traversable t] extends LawfulFunctor t :
    Type (u + 1) where
  id_traverse : ∀ {α} (x : t α), traverse id.mk x = x
  comp_traverse :
    ∀ {F G} [Applicative F] [Applicative G] [LawfulApplicative F] [LawfulApplicative G] {α β γ}
      (f : β → F γ) (g : α → G β) (x : t α),
      traverse (Comp.mk ∘ map f ∘ g) x = Comp.mk (map (traverse f) (traverse g x))
  traverse_eq_map_id : ∀ {α β} (f : α → β) (x : t α), traverse (id.mk ∘ f) x = id.mk (f <$> x)
  naturality :
    ∀ {F G} [Applicative F] [Applicative G] [LawfulApplicative F] [LawfulApplicative G]
      (η : ApplicativeTransformation F G) {α β} (f : α → F β) (x : t α),
      η (traverse f x) = traverse (@η _ ∘ f) x
#align is_lawful_traversable IsLawfulTraversable
-/

instance : Traversable id :=
  ⟨fun _ _ _ _ => id⟩

instance : IsLawfulTraversable id := by refine' { .. } <;> intros <;> rfl

section

variable {F : Type u → Type v} [Applicative F]

instance : Traversable Option :=
  ⟨@Option.traverse⟩

instance : Traversable List :=
  ⟨@List.traverse⟩

end

namespace Sum

variable {σ : Type u}

variable {F : Type u → Type u}

variable [Applicative F]

#print Sum.traverse /-
/-- Defines a `traverse` function on the second component of a sum type.
This is used to give a `traversable` instance for the functor `σ ⊕ -`. -/
protected def traverse {α β} (f : α → F β) : Sum σ α → F (Sum σ β)
  | Sum.inl x => pure (Sum.inl x)
  | Sum.inr x => Sum.inr <$> f x
#align sum.traverse Sum.traverse
-/

end Sum

instance {σ : Type u} : Traversable.{u} (Sum σ) :=
  ⟨@Sum.traverse _⟩

