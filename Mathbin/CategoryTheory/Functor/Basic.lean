/-
Copyright (c) 2017 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tim Baumann, Stephen Morgan, Scott Morrison

! This file was ported from Lean 3 source module category_theory.functor.basic
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.ReassocAxiom
import Mathbin.CategoryTheory.Category.Basic

/-!
# Functors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Defines a functor between categories, extending a `prefunctor` between quivers.

Introduces notation `C ⥤ D` for the type of all functors from `C` to `D`.
(Unfortunately the `⇒` arrow (`\functor`) is taken by core,
but in mathlib4 we should switch to this.)
-/


namespace CategoryTheory

-- declare the `v`'s first; see `category_theory.category` for an explanation
universe v v₁ v₂ v₃ u u₁ u₂ u₃

section

#print CategoryTheory.Functor /-
/-- `functor C D` represents a functor between categories `C` and `D`.

To apply a functor `F` to an object use `F.obj X`, and to a morphism use `F.map f`.

The axiom `map_id` expresses preservation of identities, and
`map_comp` expresses functoriality.

See <https://stacks.math.columbia.edu/tag/001B>.
-/
structure Functor (C : Type u₁) [Category.{v₁} C] (D : Type u₂) [Category.{v₂} D] extends
    Prefunctor C D : Type max v₁ v₂ u₁ u₂ where
  map_id' : ∀ X : C, map (𝟙 X) = 𝟙 (obj X) := by obviously
  map_comp' : ∀ {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z), map (f ≫ g) = map f ≫ map g := by obviously
#align category_theory.functor CategoryTheory.Functor
-/

/-- The prefunctor between the underlying quivers. -/
add_decl_doc functor.to_prefunctor

end

infixr:26
  " ⥤ " =>-- A functor is basically a function, so give ⥤ a similar precedence to → (25).
  -- For example, `C × D ⥤ E` should parse as `(C × D) ⥤ E` not `C × (D ⥤ E)`.
  Functor

-- type as \func --
restate_axiom functor.map_id'

attribute [simp] Functor.map_id

restate_axiom functor.map_comp'

attribute [reassoc, simp] functor.map_comp

namespace Functor

section

variable (C : Type u₁) [Category.{v₁} C]

#print CategoryTheory.Functor.id /-
-- We don't use `@[simps]` here because we want `C` implicit for the simp lemmas.
/-- `𝟭 C` is the identity functor on a category `C`. -/
protected def id : C ⥤ C where
  obj X := X
  map _ _ f := f
#align category_theory.functor.id CategoryTheory.Functor.id
-/

notation "𝟭" => Functor.id

-- Type this as `\sb1`
instance : Inhabited (C ⥤ C) :=
  ⟨Functor.id C⟩

variable {C}

#print CategoryTheory.Functor.id_obj /-
@[simp]
theorem id_obj (X : C) : (𝟭 C).obj X = X :=
  rfl
#align category_theory.functor.id_obj CategoryTheory.Functor.id_obj
-/

#print CategoryTheory.Functor.id_map /-
@[simp]
theorem id_map {X Y : C} (f : X ⟶ Y) : (𝟭 C).map f = f :=
  rfl
#align category_theory.functor.id_map CategoryTheory.Functor.id_map
-/

end

section

variable {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D] {E : Type u₃}
  [Category.{v₃} E]

#print CategoryTheory.Functor.comp /-
/-- `F ⋙ G` is the composition of a functor `F` and a functor `G` (`F` first, then `G`).
-/
@[simps obj]
def comp (F : C ⥤ D) (G : D ⥤ E) : C ⥤ E
    where
  obj X := G.obj (F.obj X)
  map _ _ f := G.map (F.map f)
#align category_theory.functor.comp CategoryTheory.Functor.comp
-/

infixr:80 " ⋙ " => comp

#print CategoryTheory.Functor.comp_map /-
@[simp]
theorem comp_map (F : C ⥤ D) (G : D ⥤ E) {X Y : C} (f : X ⟶ Y) : (F ⋙ G).map f = G.map (F.map f) :=
  rfl
#align category_theory.functor.comp_map CategoryTheory.Functor.comp_map
-/

#print CategoryTheory.Functor.comp_id /-
-- These are not simp lemmas because rewriting along equalities between functors
-- is not necessarily a good idea.
-- Natural isomorphisms are also provided in `whiskering.lean`.
protected theorem comp_id (F : C ⥤ D) : F ⋙ 𝟭 D = F := by cases F <;> rfl
#align category_theory.functor.comp_id CategoryTheory.Functor.comp_id
-/

#print CategoryTheory.Functor.id_comp /-
protected theorem id_comp (F : C ⥤ D) : 𝟭 C ⋙ F = F := by cases F <;> rfl
#align category_theory.functor.id_comp CategoryTheory.Functor.id_comp
-/

#print CategoryTheory.Functor.map_dite /-
@[simp]
theorem map_dite (F : C ⥤ D) {X Y : C} {P : Prop} [Decidable P] (f : P → (X ⟶ Y))
    (g : ¬P → (X ⟶ Y)) :
    F.map (if h : P then f h else g h) = if h : P then F.map (f h) else F.map (g h) := by
  split_ifs <;> rfl
#align category_theory.functor.map_dite CategoryTheory.Functor.map_dite
-/

@[simp]
theorem toPrefunctor_obj (F : C ⥤ D) (X : C) : F.toPrefunctor.obj X = F.obj X :=
  rfl
#align category_theory.functor.to_prefunctor_obj CategoryTheory.Functor.toPrefunctor_obj

@[simp]
theorem toPrefunctor_map (F : C ⥤ D) {X Y : C} (f : X ⟶ Y) : F.toPrefunctor.map f = F.map f :=
  rfl
#align category_theory.functor.to_prefunctor_map CategoryTheory.Functor.toPrefunctor_map

#print CategoryTheory.Functor.toPrefunctor_comp /-
@[simp]
theorem toPrefunctor_comp (F : C ⥤ D) (G : D ⥤ E) :
    F.toPrefunctor.comp G.toPrefunctor = (F ⋙ G).toPrefunctor :=
  rfl
#align category_theory.functor.to_prefunctor_comp CategoryTheory.Functor.toPrefunctor_comp
-/

end

end Functor

end CategoryTheory

