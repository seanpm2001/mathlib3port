/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module topology.sheaves.presheaf_of_functions
! leanprover-community/mathlib commit 13361559d66b84f80b6d5a1c4a26aa5054766725
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Yoneda
import Mathbin.Topology.Sheaves.Presheaf
import Mathbin.Topology.Category.TopCommRing
import Mathbin.Topology.ContinuousFunction.Algebra

/-!
# Presheaves of functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We construct some simple examples of presheaves of functions on a topological space.
* `presheaf_to_Types X T`, where `T : X → Type`,
  is the presheaf of dependently-typed (not-necessarily continuous) functions
* `presheaf_to_Type X T`, where `T : Type`,
  is the presheaf of (not-necessarily-continuous) functions to a fixed target type `T`
* `presheaf_to_Top X T`, where `T : Top`,
  is the presheaf of continuous functions into a topological space `T`
* `presheaf_To_TopCommRing X R`, where `R : TopCommRing`
  is the presheaf valued in `CommRing` of functions functions into a topological ring `R`
* as an example of the previous construction,
  `presheaf_to_TopCommRing X (TopCommRing.of ℂ)`
  is the presheaf of rings of continuous complex-valued functions on `X`.
-/


universe v u w

open CategoryTheory

open TopologicalSpace

open Opposite

namespace TopCat

variable (X : TopCat.{v})

#print TopCat.presheafToTypes /-
/-- The presheaf of dependently typed functions on `X`, with fibres given by a type family `T`.
There is no requirement that the functions are continuous, here.
-/
def presheafToTypes (T : X → Type w) : X.Presheaf (Type max v w)
    where
  obj U := ∀ x : unop U, T x
  map U V i g := fun x : unop V => g (i.unop x)
  map_id' U := by ext g ⟨x, hx⟩; rfl
  map_comp' U V W i j := rfl
#align Top.presheaf_to_Types TopCat.presheafToTypes
-/

#print TopCat.presheafToTypes_obj /-
@[simp]
theorem presheafToTypes_obj {T : X → Type v} {U : (Opens X)ᵒᵖ} :
    (presheafToTypes X T).obj U = ∀ x : unop U, T x :=
  rfl
#align Top.presheaf_to_Types_obj TopCat.presheafToTypes_obj
-/

#print TopCat.presheafToTypes_map /-
@[simp]
theorem presheafToTypes_map {T : X → Type v} {U V : (Opens X)ᵒᵖ} {i : U ⟶ V} {f} :
    (presheafToTypes X T).map i f = fun x => f (i.unop x) :=
  rfl
#align Top.presheaf_to_Types_map TopCat.presheafToTypes_map
-/

#print TopCat.presheafToType /-
-- We don't just define this in terms of `presheaf_to_Types`,
-- as it's helpful later to see (at a syntactic level) that `(presheaf_to_Type X T).obj U`
-- is a non-dependent function.
-- We don't use `@[simps]` to generate the projection lemmas here,
-- as it turns out to be useful to have `presheaf_to_Type_map`
-- written as an equality of functions (rather than being applied to some argument).
/-- The presheaf of functions on `X` with values in a type `T`.
There is no requirement that the functions are continuous, here.
-/
def presheafToType (T : Type w) : X.Presheaf (Type max v w)
    where
  obj U := unop U → T
  map U V i g := g ∘ i.unop
  map_id' U := by ext g ⟨x, hx⟩; rfl
  map_comp' U V W i j := rfl
#align Top.presheaf_to_Type TopCat.presheafToType
-/

#print TopCat.presheafToType_obj /-
@[simp]
theorem presheafToType_obj {T : Type v} {U : (Opens X)ᵒᵖ} :
    (presheafToType X T).obj U = (unop U → T) :=
  rfl
#align Top.presheaf_to_Type_obj TopCat.presheafToType_obj
-/

#print TopCat.presheafToType_map /-
@[simp]
theorem presheafToType_map {T : Type v} {U V : (Opens X)ᵒᵖ} {i : U ⟶ V} {f} :
    (presheafToType X T).map i f = f ∘ i.unop :=
  rfl
#align Top.presheaf_to_Type_map TopCat.presheafToType_map
-/

#print TopCat.presheafToTop /-
-- TODO it may prove useful to generalize the universes here,
-- but the definition would need to change.
/-- The presheaf of continuous functions on `X` with values in fixed target topological space
`T`. -/
def presheafToTop (T : TopCat.{v}) : X.Presheaf (Type v) :=
  (Opens.toTopCat X).op ⋙ yoneda.obj T
#align Top.presheaf_to_Top TopCat.presheafToTop
-/

#print TopCat.presheafToTop_obj /-
@[simp]
theorem presheafToTop_obj (T : TopCat.{v}) (U : (Opens X)ᵒᵖ) :
    (presheafToTop X T).obj U = ((Opens.toTopCat X).obj (unop U) ⟶ T) :=
  rfl
#align Top.presheaf_to_Top_obj TopCat.presheafToTop_obj
-/

#print TopCat.continuousFunctions /-
-- TODO upgrade the result to TopCommRing?
/-- The (bundled) commutative ring of continuous functions from a topological space
to a topological commutative ring, with pointwise multiplication. -/
def continuousFunctions (X : TopCat.{v}ᵒᵖ) (R : TopCommRingCat.{v}) : CommRingCat.{v} :=
  CommRingCat.of (unop X ⟶ (forget₂ TopCommRingCat TopCat).obj R)
#align Top.continuous_functions TopCat.continuousFunctions
-/

namespace ContinuousFunctions

#print TopCat.continuousFunctions.pullback /-
/-- Pulling back functions into a topological ring along a continuous map is a ring homomorphism. -/
def pullback {X Y : TopCatᵒᵖ} (f : X ⟶ Y) (R : TopCommRingCat) :
    continuousFunctions X R ⟶ continuousFunctions Y R
    where
  toFun g := f.unop ≫ g
  map_one' := rfl
  map_zero' := rfl
  map_add' := by tidy
  map_mul' := by tidy
#align Top.continuous_functions.pullback TopCat.continuousFunctions.pullback
-/

#print TopCat.continuousFunctions.map /-
/-- A homomorphism of topological rings can be postcomposed with functions from a source space `X`;
this is a ring homomorphism (with respect to the pointwise ring operations on functions). -/
def map (X : TopCat.{u}ᵒᵖ) {R S : TopCommRingCat.{u}} (φ : R ⟶ S) :
    continuousFunctions X R ⟶ continuousFunctions X S
    where
  toFun g := g ≫ (forget₂ TopCommRingCat TopCat).map φ
  map_one' := by ext <;> exact φ.1.map_one
  map_zero' := by ext <;> exact φ.1.map_zero
  map_add' := by intros <;> ext <;> apply φ.1.map_add
  map_mul' := by intros <;> ext <;> apply φ.1.map_mul
#align Top.continuous_functions.map TopCat.continuousFunctions.map
-/

end ContinuousFunctions

#print TopCat.commRingYoneda /-
/-- An upgraded version of the Yoneda embedding, observing that the continuous maps
from `X : Top` to `R : TopCommRing` form a commutative ring, functorial in both `X` and `R`. -/
def commRingYoneda : TopCommRingCat.{u} ⥤ TopCat.{u}ᵒᵖ ⥤ CommRingCat.{u}
    where
  obj R :=
    { obj := fun X => continuousFunctions X R
      map := fun X Y f => continuousFunctions.pullback f R
      map_id' := fun X => by ext; rfl
      map_comp' := fun X Y Z f g => rfl }
  map R S φ :=
    { app := fun X => continuousFunctions.map X φ
      naturality' := fun X Y f => rfl }
  map_id' X := by ext; rfl
  map_comp' X Y Z f g := rfl
#align Top.CommRing_yoneda TopCat.commRingYoneda
-/

#print TopCat.presheafToTopCommRing /-
/-- The presheaf (of commutative rings), consisting of functions on an open set `U ⊆ X` with
values in some topological commutative ring `T`.

For example, we could construct the presheaf of continuous complex valued functions of `X` as
```
presheaf_to_TopCommRing X (TopCommRing.of ℂ)
```
(this requires `import topology.instances.complex`).
-/
def presheafToTopCommRing (T : TopCommRingCat.{v}) : X.Presheaf CommRingCat.{v} :=
  (Opens.toTopCat X).op ⋙ commRingYoneda.obj T
#align Top.presheaf_to_TopCommRing TopCat.presheafToTopCommRing
-/

end TopCat

