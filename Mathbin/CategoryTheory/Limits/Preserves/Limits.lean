/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison, Bhavik Mehta

! This file was ported from Lean 3 source module category_theory.limits.preserves.limits
! leanprover-community/mathlib commit 832f7b9162039c28b9361289c8681f155cae758f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Preserves.Basic

/-!
# Isomorphisms about functors which preserve (co)limits

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If `G` preserves limits, and `C` and `D` have limits, then for any diagram `F : J ⥤ C` we have a
canonical isomorphism `preserves_limit_iso : G.obj (limit F) ≅ limit (F ⋙ G)`.
We also show that we can commute `is_limit.lift` of a preserved limit with `functor.map_cone`:
`(preserves_limit.preserves t).lift (G.map_cone c₂) = G.map (t.lift c₂)`.

The duals of these are also given. For functors which preserve (co)limits of specific shapes, see
`preserves/shapes.lean`.
-/


universe w' w v₁ v₂ u₁ u₂

noncomputable section

namespace CategoryTheory

open Category Limits

variable {C : Type u₁} [Category.{v₁} C]

variable {D : Type u₂} [Category.{v₂} D]

variable (G : C ⥤ D)

variable {J : Type w} [Category.{w'} J]

variable (F : J ⥤ C)

section

variable [PreservesLimit F G]

#print CategoryTheory.preserves_lift_mapCone /-
@[simp]
theorem preserves_lift_mapCone (c₁ c₂ : Cone F) (t : IsLimit c₁) :
    (PreservesLimit.preserves t).lift (G.mapCone c₂) = G.map (t.lift c₂) :=
  ((PreservesLimit.preserves t).uniq (G.mapCone c₂) _ (by simp [← G.map_comp])).symm
#align category_theory.preserves_lift_map_cone CategoryTheory.preserves_lift_mapCone
-/

variable [HasLimit F] [HasLimit (F ⋙ G)]

#print CategoryTheory.preservesLimitIso /-
/-- If `G` preserves limits, we have an isomorphism from the image of the limit of a functor `F`
to the limit of the functor `F ⋙ G`.
-/
def preservesLimitIso : G.obj (limit F) ≅ limit (F ⋙ G) :=
  (PreservesLimit.preserves (limit.isLimit _)).conePointUniqueUpToIso (limit.isLimit _)
#align category_theory.preserves_limit_iso CategoryTheory.preservesLimitIso
-/

#print CategoryTheory.preservesLimitsIso_hom_π /-
@[simp, reassoc]
theorem preservesLimitsIso_hom_π (j) :
    (preservesLimitIso G F).Hom ≫ limit.π _ j = G.map (limit.π F j) :=
  IsLimit.conePointUniqueUpToIso_hom_comp _ _ j
#align category_theory.preserves_limits_iso_hom_π CategoryTheory.preservesLimitsIso_hom_π
-/

#print CategoryTheory.preservesLimitsIso_inv_π /-
@[simp, reassoc]
theorem preservesLimitsIso_inv_π (j) :
    (preservesLimitIso G F).inv ≫ G.map (limit.π F j) = limit.π _ j :=
  IsLimit.conePointUniqueUpToIso_inv_comp _ _ j
#align category_theory.preserves_limits_iso_inv_π CategoryTheory.preservesLimitsIso_inv_π
-/

#print CategoryTheory.lift_comp_preservesLimitsIso_hom /-
@[simp, reassoc]
theorem lift_comp_preservesLimitsIso_hom (t : Cone F) :
    G.map (limit.lift _ t) ≫ (preservesLimitIso G F).Hom = limit.lift (F ⋙ G) (G.mapCone _) := by
  ext; simp [← G.map_comp]
#align category_theory.lift_comp_preserves_limits_iso_hom CategoryTheory.lift_comp_preservesLimitsIso_hom
-/

variable [PreservesLimitsOfShape J G] [HasLimitsOfShape J D] [HasLimitsOfShape J C]

#print CategoryTheory.preservesLimitNatIso /-
/-- If `C, D` has all limits of shape `J`, and `G` preserves them, then `preserves_limit_iso` is
functorial wrt `F`. -/
@[simps]
def preservesLimitNatIso : lim ⋙ G ≅ (whiskeringRight J C D).obj G ⋙ lim :=
  NatIso.ofComponents (fun F => preservesLimitIso G F)
    (by
      intro _ _ f
      ext
      dsimp
      simp only [preserves_limits_iso_hom_π, whisker_right_app, lim_map_π, category.assoc,
        preserves_limits_iso_hom_π_assoc, ← G.map_comp])
#align category_theory.preserves_limit_nat_iso CategoryTheory.preservesLimitNatIso
-/

end

section

variable [PreservesColimit F G]

#print CategoryTheory.preserves_desc_mapCocone /-
@[simp]
theorem preserves_desc_mapCocone (c₁ c₂ : Cocone F) (t : IsColimit c₁) :
    (PreservesColimit.preserves t).desc (G.mapCocone _) = G.map (t.desc c₂) :=
  ((PreservesColimit.preserves t).uniq (G.mapCocone _) _ (by simp [← G.map_comp])).symm
#align category_theory.preserves_desc_map_cocone CategoryTheory.preserves_desc_mapCocone
-/

variable [HasColimit F] [HasColimit (F ⋙ G)]

#print CategoryTheory.preservesColimitIso /-
-- TODO: think about swapping the order here
/-- If `G` preserves colimits, we have an isomorphism from the image of the colimit of a functor `F`
to the colimit of the functor `F ⋙ G`.
-/
def preservesColimitIso : G.obj (colimit F) ≅ colimit (F ⋙ G) :=
  (PreservesColimit.preserves (colimit.isColimit _)).coconePointUniqueUpToIso (colimit.isColimit _)
#align category_theory.preserves_colimit_iso CategoryTheory.preservesColimitIso
-/

#print CategoryTheory.ι_preservesColimitsIso_inv /-
@[simp, reassoc]
theorem ι_preservesColimitsIso_inv (j : J) :
    colimit.ι _ j ≫ (preservesColimitIso G F).inv = G.map (colimit.ι F j) :=
  IsColimit.comp_coconePointUniqueUpToIso_inv _ (colimit.isColimit (F ⋙ G)) j
#align category_theory.ι_preserves_colimits_iso_inv CategoryTheory.ι_preservesColimitsIso_inv
-/

#print CategoryTheory.ι_preservesColimitsIso_hom /-
@[simp, reassoc]
theorem ι_preservesColimitsIso_hom (j : J) :
    G.map (colimit.ι F j) ≫ (preservesColimitIso G F).Hom = colimit.ι (F ⋙ G) j :=
  (PreservesColimit.preserves (colimit.isColimit _)).comp_coconePointUniqueUpToIso_hom _ j
#align category_theory.ι_preserves_colimits_iso_hom CategoryTheory.ι_preservesColimitsIso_hom
-/

#print CategoryTheory.preservesColimitsIso_inv_comp_desc /-
@[simp, reassoc]
theorem preservesColimitsIso_inv_comp_desc (t : Cocone F) :
    (preservesColimitIso G F).inv ≫ G.map (colimit.desc _ t) = colimit.desc _ (G.mapCocone t) := by
  ext; simp [← G.map_comp]
#align category_theory.preserves_colimits_iso_inv_comp_desc CategoryTheory.preservesColimitsIso_inv_comp_desc
-/

variable [PreservesColimitsOfShape J G] [HasColimitsOfShape J D] [HasColimitsOfShape J C]

#print CategoryTheory.preservesColimitNatIso /-
/-- If `C, D` has all colimits of shape `J`, and `G` preserves them, then `preserves_colimit_iso`
is functorial wrt `F`. -/
@[simps]
def preservesColimitNatIso : colim ⋙ G ≅ (whiskeringRight J C D).obj G ⋙ colim :=
  NatIso.ofComponents (fun F => preservesColimitIso G F)
    (by
      intro _ _ f
      rw [← iso.inv_comp_eq, ← category.assoc, ← iso.eq_comp_inv]
      ext
      dsimp
      erw [ι_colim_map_assoc]
      simp only [ι_preserves_colimits_iso_inv, whisker_right_app, category.assoc,
        ι_preserves_colimits_iso_inv_assoc, ← G.map_comp]
      erw [ι_colim_map])
#align category_theory.preserves_colimit_nat_iso CategoryTheory.preservesColimitNatIso
-/

end

end CategoryTheory

