/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.monoidal.internal.limits
! leanprover-community/mathlib commit e160cefedc932ce41c7049bf0c4b0f061d06216e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Monoidal.Internal.FunctorCategory
import Mathbin.CategoryTheory.Monoidal.Limits
import Mathbin.CategoryTheory.Limits.Preserves.Basic

/-!
# Limits of monoid objects.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If `C` has limits, so does `Mon_ C`, and the forgetful functor preserves these limits.

(This could potentially replace many individual constructions for concrete categories,
in particular `Mon`, `SemiRing`, `Ring`, and `Algebra R`.)
-/


open CategoryTheory

open CategoryTheory.Limits

open CategoryTheory.Monoidal

universe v u

noncomputable section

namespace Mon_

variable {J : Type v} [SmallCategory J]

variable {C : Type u} [Category.{v} C] [HasLimits C] [MonoidalCategory.{v} C]

#print Mon_.limit /-
/-- We construct the (candidate) limit of a functor `F : J ⥤ Mon_ C`
by interpreting it as a functor `Mon_ (J ⥤ C)`,
and noting that taking limits is a lax monoidal functor,
and hence sends monoid objects to monoid objects.
-/
@[simps]
def limit (F : J ⥤ Mon_ C) : Mon_ C :=
  limLax.mapMon.obj (MonFunctorCategoryEquivalence.inverse.obj F)
#align Mon_.limit Mon_.limit
-/

#print Mon_.limitCone /-
/-- Implementation of `Mon_.has_limits`: a limiting cone over a functor `F : J ⥤ Mon_ C`.
-/
@[simps]
def limitCone (F : J ⥤ Mon_ C) : Cone F where
  pt := limit F
  π :=
    { app := fun j => { Hom := limit.π (F ⋙ Mon_.forget C) j }
      naturality' := fun j j' f => by ext; exact (limit.cone (F ⋙ Mon_.forget C)).π.naturality f }
#align Mon_.limit_cone Mon_.limitCone
-/

#print Mon_.forgetMapConeLimitConeIso /-
/-- The image of the proposed limit cone for `F : J ⥤ Mon_ C` under the forgetful functor
`forget C : Mon_ C ⥤ C` is isomorphic to the limit cone of `F ⋙ forget C`.
-/
def forgetMapConeLimitConeIso (F : J ⥤ Mon_ C) :
    (forget C).mapCone (limitCone F) ≅ limit.cone (F ⋙ forget C) :=
  Cones.ext (Iso.refl _) fun j => by tidy
#align Mon_.forget_map_cone_limit_cone_iso Mon_.forgetMapConeLimitConeIso
-/

#print Mon_.limitConeIsLimit /-
/-- Implementation of `Mon_.has_limits`:
the proposed cone over a functor `F : J ⥤ Mon_ C` is a limit cone.
-/
@[simps]
def limitConeIsLimit (F : J ⥤ Mon_ C) : IsLimit (limitCone F)
    where
  lift s :=
    { Hom := limit.lift (F ⋙ Mon_.forget C) ((Mon_.forget C).mapCone s)
      mul_hom' := by
        ext; dsimp; simp; dsimp
        slice_rhs 1 2 =>
          rw [← monoidal_category.tensor_comp, limit.lift_π]
          dsimp }
  fac s h := by ext; simp
  uniq s m w := by
    ext
    dsimp; simp only [Mon_.forget_map, limit.lift_π, functor.map_cone_π_app]
    exact congr_arg Mon_.Hom.hom (w j)
#align Mon_.limit_cone_is_limit Mon_.limitConeIsLimit
-/

#print Mon_.hasLimits /-
instance hasLimits : HasLimits (Mon_ C)
    where HasLimitsOfShape J 𝒥 :=
    {
      HasLimit := fun F =>
        has_limit.mk
          { Cone := limit_cone F
            IsLimit := limit_cone_is_limit F } }
#align Mon_.has_limits Mon_.hasLimits
-/

#print Mon_.forgetPreservesLimits /-
instance forgetPreservesLimits : PreservesLimits (Mon_.forget C)
    where PreservesLimitsOfShape J 𝒥 :=
    {
      PreservesLimit := fun F : J ⥤ Mon_ C =>
        preserves_limit_of_preserves_limit_cone (limit_cone_is_limit F)
          (is_limit.of_iso_limit (limit.is_limit (F ⋙ Mon_.forget C))
            (forget_map_cone_limit_cone_iso F).symm) }
#align Mon_.forget_preserves_limits Mon_.forgetPreservesLimits
-/

end Mon_

