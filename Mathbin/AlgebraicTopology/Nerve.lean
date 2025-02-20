/-
Copyright (c) 2022 Joël Riou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joël Riou

! This file was ported from Lean 3 source module algebraic_topology.nerve
! leanprover-community/mathlib commit f2b757fc5c341d88741b9c4630b1e8ba973c5726
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.AlgebraicTopology.SimplicialSet

/-!

# The nerve of a category

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides the definition of the nerve of a category `C`,
which is a simplicial set `nerve C` (see [goerss-jardine-2009], Example I.1.4).

## References
* [Paul G. Goerss, John F. Jardine, *Simplical Homotopy Theory*][goerss-jardine-2009]

-/


open CategoryTheory.Category

universe v u

namespace CategoryTheory

#print CategoryTheory.nerve /-
/-- The nerve of a category -/
@[simps]
def nerve (C : Type u) [Category.{v} C] : SSet.{max u v}
    where
  obj Δ := SimplexCategory.toCat.obj Δ.unop ⥤ C
  map Δ₁ Δ₂ f x := SimplexCategory.toCat.map f.unop ⋙ x
  map_id' Δ := by
    rw [unop_id, Functor.map_id]
    ext x
    apply functor.id_comp
#align category_theory.nerve CategoryTheory.nerve
-/

instance {C : Type _} [Category C] {Δ : SimplexCategoryᵒᵖ} : Category ((nerve C).obj Δ) :=
  (inferInstance : Category (SimplexCategory.toCat.obj Δ.unop ⥤ C))

#print CategoryTheory.nerveFunctor /-
/-- The nerve of a category, as a functor `Cat ⥤ sSet` -/
@[simps]
def nerveFunctor : Cat ⥤ SSet where
  obj C := nerve C
  map C C' F := { app := fun Δ x => x ⋙ F }
  map_id' C := by
    ext Δ x
    apply functor.comp_id
#align category_theory.nerve_functor CategoryTheory.nerveFunctor
-/

end CategoryTheory

