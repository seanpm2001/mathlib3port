/-
Copyright (c) 2019 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module control.bitraversable.instances
! leanprover-community/mathlib commit 1b089e3bdc3ce6b39cd472543474a0a137128c6c
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Control.Bitraversable.Lemmas
import Mathbin.Control.Traversable.Lemmas

/-!
# Bitraversable instances

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

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

#print Prod.bitraverse /-
/-- The bitraverse function for `α × β`. -/
def Prod.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : α × β → F (α' × β')
  | (x, y) => Prod.mk <$> f x <*> f' y
#align prod.bitraverse Prod.bitraverse
-/

instance : Bitraversable Prod where bitraverse := @Prod.bitraverse

instance : LawfulBitraversable Prod := by
  constructor <;> intros <;> cases x <;> simp [bitraverse, Prod.bitraverse, functor_norm] <;> rfl

open Functor

#print Sum.bitraverse /-
/-- The bitraverse function for `α ⊕ β`. -/
def Sum.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : Sum α β → F (Sum α' β')
  | Sum.inl x => Sum.inl <$> f x
  | Sum.inr x => Sum.inr <$> f' x
#align sum.bitraverse Sum.bitraverse
-/

instance : Bitraversable Sum where bitraverse := @Sum.bitraverse

instance : LawfulBitraversable Sum := by
  constructor <;> intros <;> cases x <;> simp [bitraverse, Sum.bitraverse, functor_norm] <;> rfl

#print Const.bitraverse /-
/-- The bitraverse function for `const`. It throws away the second map. -/
@[nolint unused_arguments]
def Const.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : Const α β → F (Const α' β') :=
  f
#align const.bitraverse Const.bitraverse
-/

#print Bitraversable.const /-
instance Bitraversable.const : Bitraversable Const where bitraverse := @Const.bitraverse
#align bitraversable.const Bitraversable.const
-/

#print LawfulBitraversable.const /-
instance LawfulBitraversable.const : LawfulBitraversable Const := by
  constructor <;> intros <;> simp [bitraverse, Const.bitraverse, functor_norm] <;> rfl
#align is_lawful_bitraversable.const LawfulBitraversable.const
-/

#print flip.bitraverse /-
/-- The bitraverse function for `flip`. -/
def flip.bitraverse {α α' β β'} (f : α → F α') (f' : β → F β') : flip t α β → F (flip t α' β') :=
  (bitraverse f' f : t β α → F (t β' α'))
#align flip.bitraverse flip.bitraverse
-/

#print Bitraversable.flip /-
instance Bitraversable.flip : Bitraversable (flip t) where bitraverse := @flip.bitraverse t _
#align bitraversable.flip Bitraversable.flip
-/

open LawfulBitraversable

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic tactic.apply_assumption -/
#print LawfulBitraversable.flip /-
instance LawfulBitraversable.flip [LawfulBitraversable t] : LawfulBitraversable (flip t) := by
  constructor <;> intros <;> casesm LawfulBitraversable t <;>
    run_tac
      tactic.apply_assumption
#align is_lawful_bitraversable.flip LawfulBitraversable.flip
-/

open Bitraversable Functor

#print Bitraversable.traversable /-
instance (priority := 10) Bitraversable.traversable {α} : Traversable (t α)
    where traverse := @tsnd t _ _
#align bitraversable.traversable Bitraversable.traversable
-/

#print Bitraversable.isLawfulTraversable /-
instance (priority := 10) Bitraversable.isLawfulTraversable [LawfulBitraversable t] {α} :
    IsLawfulTraversable (t α) :=
  by
  constructor <;> intros <;> simp [traverse, comp_tsnd, functor_norm]
  · rfl
  · simp [tsnd_eq_snd_id]; rfl
  · simp [tsnd, binaturality, Function.comp, functor_norm]
#align bitraversable.is_lawful_traversable Bitraversable.isLawfulTraversable
-/

end

open Bifunctor Traversable IsLawfulTraversable LawfulBitraversable

open Function (bicompl bicompr)

section Bicompl

variable (F G : Type u → Type u) [Traversable F] [Traversable G]

#print Bicompl.bitraverse /-
/-- The bitraverse function for `bicompl`. -/
def Bicompl.bitraverse {m} [Applicative m] {α β α' β'} (f : α → m β) (f' : α' → m β') :
    bicompl t F G α α' → m (bicompl t F G β β') :=
  (bitraverse (traverse f) (traverse f') : t (F α) (G α') → m _)
#align bicompl.bitraverse Bicompl.bitraverse
-/

instance : Bitraversable (bicompl t F G) where bitraverse := @Bicompl.bitraverse t _ F G _ _

instance [IsLawfulTraversable F] [IsLawfulTraversable G] [LawfulBitraversable t] :
    LawfulBitraversable (bicompl t F G) :=
  by
  constructor <;> intros <;>
    simp [bitraverse, Bicompl.bitraverse, bimap, traverse_id, bitraverse_id_id, comp_bitraverse,
      functor_norm]
  · simp [traverse_eq_map_id', bitraverse_eq_bimap_id]
  · revert x; dsimp only [bicompl]
    simp [binaturality, naturality_pf]

end Bicompl

section Bicompr

variable (F : Type u → Type u) [Traversable F]

#print Bicompr.bitraverse /-
/-- The bitraverse function for `bicompr`. -/
def Bicompr.bitraverse {m} [Applicative m] {α β α' β'} (f : α → m β) (f' : α' → m β') :
    bicompr F t α α' → m (bicompr F t β β') :=
  (traverse (bitraverse f f') : F (t α α') → m _)
#align bicompr.bitraverse Bicompr.bitraverse
-/

instance : Bitraversable (bicompr F t) where bitraverse := @Bicompr.bitraverse t _ F _

instance [IsLawfulTraversable F] [LawfulBitraversable t] : LawfulBitraversable (bicompr F t) :=
  by
  constructor <;> intros <;> simp [bitraverse, Bicompr.bitraverse, bitraverse_id_id, functor_norm]
  · simp [bitraverse_eq_bimap_id', traverse_eq_map_id']; rfl
  · revert x; dsimp only [bicompr]; intro
    simp [naturality, binaturality']

end Bicompr

