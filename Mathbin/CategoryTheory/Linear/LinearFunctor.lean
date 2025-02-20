/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.linear.linear_functor
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Preadditive.AdditiveFunctor
import Mathbin.CategoryTheory.Linear.Basic

/-!
# Linear Functors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

An additive functor between two `R`-linear categories is called *linear*
if the induced map on hom types is a morphism of `R`-modules.

# Implementation details

`functor.linear` is a `Prop`-valued class, defined by saying that
for every two objects `X` and `Y`, the map
`F.map : (X ⟶ Y) → (F.obj X ⟶ F.obj Y)` is a morphism of `R`-modules.

-/


namespace CategoryTheory

variable (R : Type _) [Semiring R]

#print CategoryTheory.Functor.Linear /-
/-- An additive functor `F` is `R`-linear provided `F.map` is an `R`-module morphism. -/
class Functor.Linear {C D : Type _} [Category C] [Category D] [Preadditive C] [Preadditive D]
    [Linear R C] [Linear R D] (F : C ⥤ D) [F.Additive] : Prop where
  map_smul' : ∀ {X Y : C} {f : X ⟶ Y} {r : R}, F.map (r • f) = r • F.map f := by obviously
#align category_theory.functor.linear CategoryTheory.Functor.Linear
-/

section Linear

namespace Functor

section

variable {R} {C D : Type _} [Category C] [Category D] [Preadditive C] [Preadditive D]
  [CategoryTheory.Linear R C] [CategoryTheory.Linear R D] (F : C ⥤ D) [Additive F] [Linear R F]

#print CategoryTheory.Functor.map_smul /-
@[simp]
theorem map_smul {X Y : C} (r : R) (f : X ⟶ Y) : F.map (r • f) = r • F.map f :=
  Functor.Linear.map_smul'
#align category_theory.functor.map_smul CategoryTheory.Functor.map_smul
-/

instance : Linear R (𝟭 C) where

instance {E : Type _} [Category E] [Preadditive E] [CategoryTheory.Linear R E] (G : D ⥤ E)
    [Additive G] [Linear R G] : Linear R (F ⋙ G) where

variable (R)

#print CategoryTheory.Functor.mapLinearMap /-
/-- `F.map_linear_map` is an `R`-linear map whose underlying function is `F.map`. -/
@[simps]
def mapLinearMap {X Y : C} : (X ⟶ Y) →ₗ[R] F.obj X ⟶ F.obj Y :=
  { F.mapAddHom with map_smul' := fun r f => F.map_smul r f }
#align category_theory.functor.map_linear_map CategoryTheory.Functor.mapLinearMap
-/

#print CategoryTheory.Functor.coe_mapLinearMap /-
theorem coe_mapLinearMap {X Y : C} : ⇑(F.mapLinearMap R : (X ⟶ Y) →ₗ[R] _) = @map C _ D _ F X Y :=
  rfl
#align category_theory.functor.coe_map_linear_map CategoryTheory.Functor.coe_mapLinearMap
-/

end

section InducedCategory

variable {C : Type _} {D : Type _} [Category D] [Preadditive D] [CategoryTheory.Linear R D]
  (F : C → D)

#print CategoryTheory.Functor.inducedFunctorLinear /-
instance inducedFunctorLinear : Functor.Linear R (inducedFunctor F) where
#align category_theory.functor.induced_functor_linear CategoryTheory.Functor.inducedFunctorLinear
-/

end InducedCategory

#print CategoryTheory.Functor.fullSubcategoryInclusionLinear /-
instance fullSubcategoryInclusionLinear {C : Type _} [Category C] [Preadditive C]
    [CategoryTheory.Linear R C] (Z : C → Prop) : (fullSubcategoryInclusion Z).Linear R where
#align category_theory.functor.full_subcategory_inclusion_linear CategoryTheory.Functor.fullSubcategoryInclusionLinear
-/

section

variable {R} {C D : Type _} [Category C] [Category D] [Preadditive C] [Preadditive D] (F : C ⥤ D)
  [Additive F]

#print CategoryTheory.Functor.natLinear /-
instance natLinear : F.Linear ℕ where map_smul' X Y f r := F.mapAddHom.map_nsmul f r
#align category_theory.functor.nat_linear CategoryTheory.Functor.natLinear
-/

#print CategoryTheory.Functor.intLinear /-
instance intLinear : F.Linear ℤ
    where map_smul' X Y f r := (F.mapAddHom : (X ⟶ Y) →+ (F.obj X ⟶ F.obj Y)).map_zsmul f r
#align category_theory.functor.int_linear CategoryTheory.Functor.intLinear
-/

variable [CategoryTheory.Linear ℚ C] [CategoryTheory.Linear ℚ D]

#print CategoryTheory.Functor.ratLinear /-
instance ratLinear : F.Linear ℚ where map_smul' X Y f r := F.mapAddHom.toRatLinearMap.map_smul r f
#align category_theory.functor.rat_linear CategoryTheory.Functor.ratLinear
-/

end

end Functor

namespace Equivalence

variable {C D : Type _} [Category C] [Category D] [Preadditive C] [Linear R C] [Preadditive D]
  [Linear R D]

#print CategoryTheory.Equivalence.inverseLinear /-
instance inverseLinear (e : C ≌ D) [e.Functor.Additive] [e.Functor.Linear R] : e.inverse.Linear R
    where map_smul' X Y r f := by apply e.functor.map_injective; simp
#align category_theory.equivalence.inverse_linear CategoryTheory.Equivalence.inverseLinear
-/

end Equivalence

end Linear

end CategoryTheory

