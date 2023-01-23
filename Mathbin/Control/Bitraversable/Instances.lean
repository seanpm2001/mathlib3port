/-
Copyright (c) 2019 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.bitraversable.instances
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Bitraversable.Lemmas
import Mathbin.Control.Traversable.Lemmas

/-!
# Bitraversable instances

This file provides `bitraversable` instances for concrete bifunctors:
* `prod`
* `sum`
* `functor.const`
* `flip`
* `function.bicompl`
* `function.bicompr`

## References

* Hackage: <https://hackage.haskell.org/package/base-4.12.0.0/docs/Data-Bitraversable.html>

## Tags

traversable bitraversable functor bifunctor applicative
-/


universe u v w

variable {t : Type u → Type u → Type u} [Bitraversable t]

section

variable {F : Type u → Type u} [Applicative F]

/- warning: prod.bitraverse -> Prod.bitraverse is a dubious translation:
lean 3 declaration is
  forall {F : Type.{u1} -> Type.{u1}} [_inst_2 : Applicative.{u1, u1} F] {α : Type.{u2}} {α' : Type.{u1}} {β : Type.{u3}} {β' : Type.{u1}}, (α -> (F α')) -> (β -> (F β')) -> (Prod.{u2, u3} α β) -> (F (Prod.{u1, u1} α' β'))
but is expected to have type
  forall {F : Type.{u3} -> Type.{u3}} [_inst_2 : Applicative.{u3, u3} F] {α : Type.{u1}} {α' : Type.{u3}} {β : Type.{u2}} {β' : Type.{u3}}, (α -> (F α')) -> (β -> (F β')) -> (Prod.{u1, u2} α β) -> (F (Prod.{u3, u3} α' β'))
Case conversion may be inaccurate. Consider using '#align prod.bitraverse Prod.bitraverseₓ'. -/
/-- The bitraverse function for `α × β`. -/
def Prod.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : α × β → F (α' × β')
  | (x, y) => Prod.mk <$> f x <*> f' y
#align prod.bitraverse Prod.bitraverse

instance : Bitraversable Prod where bitraverse := @Prod.bitraverse

instance : IsLawfulBitraversable Prod := by
  constructor <;> intros <;> cases x <;> simp [bitraverse, Prod.bitraverse, functor_norm] <;> rfl

open Functor

/- warning: sum.bitraverse -> Sum.bitraverse is a dubious translation:
lean 3 declaration is
  forall {F : Type.{u1} -> Type.{u1}} [_inst_2 : Applicative.{u1, u1} F] {α : Type.{u2}} {α' : Type.{u1}} {β : Type.{u3}} {β' : Type.{u1}}, (α -> (F α')) -> (β -> (F β')) -> (Sum.{u2, u3} α β) -> (F (Sum.{u1, u1} α' β'))
but is expected to have type
  forall {F : Type.{u3} -> Type.{u3}} [_inst_2 : Applicative.{u3, u3} F] {α : Type.{u1}} {α' : Type.{u3}} {β : Type.{u2}} {β' : Type.{u3}}, (α -> (F α')) -> (β -> (F β')) -> (Sum.{u1, u2} α β) -> (F (Sum.{u3, u3} α' β'))
Case conversion may be inaccurate. Consider using '#align sum.bitraverse Sum.bitraverseₓ'. -/
/-- The bitraverse function for `α ⊕ β`. -/
def Sum.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : Sum α β → F (Sum α' β')
  | Sum.inl x => Sum.inl <$> f x
  | Sum.inr x => Sum.inr <$> f' x
#align sum.bitraverse Sum.bitraverse

instance : Bitraversable Sum where bitraverse := @Sum.bitraverse

instance : IsLawfulBitraversable Sum := by
  constructor <;> intros <;> cases x <;> simp [bitraverse, Sum.bitraverse, functor_norm] <;> rfl

/-- The bitraverse function for `const`. It throws away the second map. -/
@[nolint unused_arguments]
def Const.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : Const α β → F (Const α' β') :=
  f
#align const.bitraverse Const.bitraverse

instance Bitraversable.const : Bitraversable Const where bitraverse := @Const.bitraverse
#align bitraversable.const Bitraversable.const

instance IsLawfulBitraversable.const : IsLawfulBitraversable Const := by
  constructor <;> intros <;> simp [bitraverse, Const.bitraverse, functor_norm] <;> rfl
#align is_lawful_bitraversable.const IsLawfulBitraversable.const

/-- The bitraverse function for `flip`. -/
def flip.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : flip t α β → F (flip t α' β') :=
  (bitraverse f' f : t β α → F (t β' α'))
#align flip.bitraverse flip.bitraverse

instance Bitraversable.flip : Bitraversable (flip t) where bitraverse := @flip.bitraverse t _
#align bitraversable.flip Bitraversable.flip

open IsLawfulBitraversable

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:18: unsupported non-interactive tactic tactic.apply_assumption -/
instance IsLawfulBitraversable.flip [IsLawfulBitraversable t] : IsLawfulBitraversable (flip t) := by
  constructor <;> intros <;> casesm IsLawfulBitraversable t <;>
    run_tac
      tactic.apply_assumption
#align is_lawful_bitraversable.flip IsLawfulBitraversable.flip

open Bitraversable Functor

instance (priority := 10) Bitraversable.traversable {α} : Traversable (t α)
    where traverse := @tsnd t _ _
#align bitraversable.traversable Bitraversable.traversable

instance (priority := 10) Bitraversable.isLawfulTraversable [IsLawfulBitraversable t] {α} :
    IsLawfulTraversable (t α) :=
  by
  constructor <;> intros <;> simp [traverse, comp_tsnd, functor_norm]
  · rfl
  · simp [tsnd_eq_snd_id]
    rfl
  · simp [tsnd, binaturality, Function.comp, functor_norm]
#align bitraversable.is_lawful_traversable Bitraversable.isLawfulTraversable

end

open Bifunctor Traversable IsLawfulTraversable IsLawfulBitraversable

open Function (bicompl bicompr)

section Bicompl

variable (F G : Type u → Type u) [Traversable F] [Traversable G]

/-- The bitraverse function for `bicompl`. -/
def Bicompl.bitraverse {m} [Applicative m] {α β α' β'} (f : α → m β) (f' : α' → m β') :
    bicompl t F G α α' → m (bicompl t F G β β') :=
  (bitraverse (traverse f) (traverse f') : t (F α) (G α') → m _)
#align bicompl.bitraverse Bicompl.bitraverse

instance : Bitraversable (bicompl t F G) where bitraverse := @Bicompl.bitraverse t _ F G _ _

instance [IsLawfulTraversable F] [IsLawfulTraversable G] [IsLawfulBitraversable t] :
    IsLawfulBitraversable (bicompl t F G) :=
  by
  constructor <;> intros <;>
    simp [bitraverse, Bicompl.bitraverse, bimap, traverse_id, bitraverse_id_id, comp_bitraverse,
      functor_norm]
  · simp [traverse_eq_map_id', bitraverse_eq_bimap_id]
  · revert x
    dsimp only [bicompl]
    simp [binaturality, naturality_pf]

end Bicompl

section Bicompr

variable (F : Type u → Type u) [Traversable F]

/-- The bitraverse function for `bicompr`. -/
def Bicompr.bitraverse {m} [Applicative m] {α β α' β'} (f : α → m β) (f' : α' → m β') :
    bicompr F t α α' → m (bicompr F t β β') :=
  (traverse (bitraverse f f') : F (t α α') → m _)
#align bicompr.bitraverse Bicompr.bitraverse

instance : Bitraversable (bicompr F t) where bitraverse := @Bicompr.bitraverse t _ F _

instance [IsLawfulTraversable F] [IsLawfulBitraversable t] : IsLawfulBitraversable (bicompr F t) :=
  by
  constructor <;> intros <;> simp [bitraverse, Bicompr.bitraverse, bitraverse_id_id, functor_norm]
  · simp [bitraverse_eq_bimap_id', traverse_eq_map_id']
    rfl
  · revert x
    dsimp only [bicompr]
    intro
    simp [naturality, binaturality']

end Bicompr

