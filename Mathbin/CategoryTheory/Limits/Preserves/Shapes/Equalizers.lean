/-
Copyright (c) 2020 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta

! This file was ported from Lean 3 source module category_theory.limits.preserves.shapes.equalizers
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.SplitCoequalizer
import Mathbin.CategoryTheory.Limits.Preserves.Basic

/-!
# Preserving (co)equalizers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Constructions to relate the notions of preserving (co)equalizers and reflecting (co)equalizers
to concrete (co)forks.

In particular, we show that `equalizer_comparison f g G` is an isomorphism iff `G` preserves
the limit of the parallel pair `f,g`, as well as the dual result.
-/


noncomputable section

universe w v₁ v₂ u₁ u₂

open CategoryTheory CategoryTheory.Category CategoryTheory.Limits

variable {C : Type u₁} [Category.{v₁} C]

variable {D : Type u₂} [Category.{v₂} D]

variable (G : C ⥤ D)

namespace CategoryTheory.Limits

section Equalizers

variable {X Y Z : C} {f g : X ⟶ Y} {h : Z ⟶ X} (w : h ≫ f = h ≫ g)

#print CategoryTheory.Limits.isLimitMapConeForkEquiv /-
/-- The map of a fork is a limit iff the fork consisting of the mapped morphisms is a limit. This
essentially lets us commute `fork.of_ι` with `functor.map_cone`.
-/
def isLimitMapConeForkEquiv :
    IsLimit (G.mapCone (Fork.ofι h w)) ≃
      IsLimit (Fork.ofι (G.map h) (by simp only [← G.map_comp, w]) : Fork (G.map f) (G.map g)) :=
  (IsLimit.postcomposeHomEquiv (diagramIsoParallelPair _) _).symm.trans
    (IsLimit.equivIsoLimit (Fork.ext (Iso.refl _) (by simp [fork.ι])))
#align category_theory.limits.is_limit_map_cone_fork_equiv CategoryTheory.Limits.isLimitMapConeForkEquiv
-/

#print CategoryTheory.Limits.isLimitForkMapOfIsLimit /-
/-- The property of preserving equalizers expressed in terms of forks. -/
def isLimitForkMapOfIsLimit [PreservesLimit (parallelPair f g) G] (l : IsLimit (Fork.ofι h w)) :
    IsLimit (Fork.ofι (G.map h) (by simp only [← G.map_comp, w]) : Fork (G.map f) (G.map g)) :=
  isLimitMapConeForkEquiv G w (PreservesLimit.preserves l)
#align category_theory.limits.is_limit_fork_map_of_is_limit CategoryTheory.Limits.isLimitForkMapOfIsLimit
-/

#print CategoryTheory.Limits.isLimitOfIsLimitForkMap /-
/-- The property of reflecting equalizers expressed in terms of forks. -/
def isLimitOfIsLimitForkMap [ReflectsLimit (parallelPair f g) G]
    (l : IsLimit (Fork.ofι (G.map h) (by simp only [← G.map_comp, w]) : Fork (G.map f) (G.map g))) :
    IsLimit (Fork.ofι h w) :=
  ReflectsLimit.reflects ((isLimitMapConeForkEquiv G w).symm l)
#align category_theory.limits.is_limit_of_is_limit_fork_map CategoryTheory.Limits.isLimitOfIsLimitForkMap
-/

variable (f g) [HasEqualizer f g]

#print CategoryTheory.Limits.isLimitOfHasEqualizerOfPreservesLimit /-
/--
If `G` preserves equalizers and `C` has them, then the fork constructed of the mapped morphisms of
a fork is a limit.
-/
def isLimitOfHasEqualizerOfPreservesLimit [PreservesLimit (parallelPair f g) G] :
    IsLimit
      (Fork.ofι (G.map (equalizer.ι f g)) (by simp only [← G.map_comp, equalizer.condition])) :=
  isLimitForkMapOfIsLimit G _ (equalizerIsEqualizer f g)
#align category_theory.limits.is_limit_of_has_equalizer_of_preserves_limit CategoryTheory.Limits.isLimitOfHasEqualizerOfPreservesLimit
-/

variable [HasEqualizer (G.map f) (G.map g)]

#print CategoryTheory.Limits.PreservesEqualizer.ofIsoComparison /-
/-- If the equalizer comparison map for `G` at `(f,g)` is an isomorphism, then `G` preserves the
equalizer of `(f,g)`.
-/
def PreservesEqualizer.ofIsoComparison [i : IsIso (equalizerComparison f g G)] :
    PreservesLimit (parallelPair f g) G :=
  by
  apply preserves_limit_of_preserves_limit_cone (equalizer_is_equalizer f g)
  apply (is_limit_map_cone_fork_equiv _ _).symm _
  apply is_limit.of_point_iso (limit.is_limit (parallel_pair (G.map f) (G.map g)))
  apply i
#align category_theory.limits.preserves_equalizer.of_iso_comparison CategoryTheory.Limits.PreservesEqualizer.ofIsoComparison
-/

variable [PreservesLimit (parallelPair f g) G]

#print CategoryTheory.Limits.PreservesEqualizer.iso /-
/--
If `G` preserves the equalizer of `(f,g)`, then the equalizer comparison map for `G` at `(f,g)` is
an isomorphism.
-/
def PreservesEqualizer.iso : G.obj (equalizer f g) ≅ equalizer (G.map f) (G.map g) :=
  IsLimit.conePointUniqueUpToIso (isLimitOfHasEqualizerOfPreservesLimit G f g) (limit.isLimit _)
#align category_theory.limits.preserves_equalizer.iso CategoryTheory.Limits.PreservesEqualizer.iso
-/

#print CategoryTheory.Limits.PreservesEqualizer.iso_hom /-
@[simp]
theorem PreservesEqualizer.iso_hom :
    (PreservesEqualizer.iso G f g).Hom = equalizerComparison f g G :=
  rfl
#align category_theory.limits.preserves_equalizer.iso_hom CategoryTheory.Limits.PreservesEqualizer.iso_hom
-/

instance : IsIso (equalizerComparison f g G) :=
  by
  rw [← preserves_equalizer.iso_hom]
  infer_instance

end Equalizers

section Coequalizers

variable {X Y Z : C} {f g : X ⟶ Y} {h : Y ⟶ Z} (w : f ≫ h = g ≫ h)

#print CategoryTheory.Limits.isColimitMapCoconeCoforkEquiv /-
/-- The map of a cofork is a colimit iff the cofork consisting of the mapped morphisms is a colimit.
This essentially lets us commute `cofork.of_π` with `functor.map_cocone`.
-/
def isColimitMapCoconeCoforkEquiv :
    IsColimit (G.mapCocone (Cofork.ofπ h w)) ≃
      IsColimit
        (Cofork.ofπ (G.map h) (by simp only [← G.map_comp, w]) : Cofork (G.map f) (G.map g)) :=
  (IsColimit.precomposeInvEquiv (diagramIsoParallelPair _) _).symm.trans <|
    IsColimit.equivIsoColimit <|
      Cofork.ext (Iso.refl _) <|
        by
        dsimp only [cofork.π, cofork.of_π_ι_app]
        dsimp; rw [category.comp_id, category.id_comp]
#align category_theory.limits.is_colimit_map_cocone_cofork_equiv CategoryTheory.Limits.isColimitMapCoconeCoforkEquiv
-/

#print CategoryTheory.Limits.isColimitCoforkMapOfIsColimit /-
/-- The property of preserving coequalizers expressed in terms of coforks. -/
def isColimitCoforkMapOfIsColimit [PreservesColimit (parallelPair f g) G]
    (l : IsColimit (Cofork.ofπ h w)) :
    IsColimit
      (Cofork.ofπ (G.map h) (by simp only [← G.map_comp, w]) : Cofork (G.map f) (G.map g)) :=
  isColimitMapCoconeCoforkEquiv G w (PreservesColimit.preserves l)
#align category_theory.limits.is_colimit_cofork_map_of_is_colimit CategoryTheory.Limits.isColimitCoforkMapOfIsColimit
-/

#print CategoryTheory.Limits.isColimitOfIsColimitCoforkMap /-
/-- The property of reflecting coequalizers expressed in terms of coforks. -/
def isColimitOfIsColimitCoforkMap [ReflectsColimit (parallelPair f g) G]
    (l :
      IsColimit
        (Cofork.ofπ (G.map h) (by simp only [← G.map_comp, w]) : Cofork (G.map f) (G.map g))) :
    IsColimit (Cofork.ofπ h w) :=
  ReflectsColimit.reflects ((isColimitMapCoconeCoforkEquiv G w).symm l)
#align category_theory.limits.is_colimit_of_is_colimit_cofork_map CategoryTheory.Limits.isColimitOfIsColimitCoforkMap
-/

variable (f g) [HasCoequalizer f g]

#print CategoryTheory.Limits.isColimitOfHasCoequalizerOfPreservesColimit /-
/--
If `G` preserves coequalizers and `C` has them, then the cofork constructed of the mapped morphisms
of a cofork is a colimit.
-/
def isColimitOfHasCoequalizerOfPreservesColimit [PreservesColimit (parallelPair f g) G] :
    IsColimit (Cofork.ofπ (G.map (coequalizer.π f g)) _) :=
  isColimitCoforkMapOfIsColimit G _ (coequalizerIsCoequalizer f g)
#align category_theory.limits.is_colimit_of_has_coequalizer_of_preserves_colimit CategoryTheory.Limits.isColimitOfHasCoequalizerOfPreservesColimit
-/

variable [HasCoequalizer (G.map f) (G.map g)]

#print CategoryTheory.Limits.ofIsoComparison /-
/-- If the coequalizer comparison map for `G` at `(f,g)` is an isomorphism, then `G` preserves the
coequalizer of `(f,g)`.
-/
def ofIsoComparison [i : IsIso (coequalizerComparison f g G)] :
    PreservesColimit (parallelPair f g) G :=
  by
  apply preserves_colimit_of_preserves_colimit_cocone (coequalizer_is_coequalizer f g)
  apply (is_colimit_map_cocone_cofork_equiv _ _).symm _
  apply is_colimit.of_point_iso (colimit.is_colimit (parallel_pair (G.map f) (G.map g)))
  apply i
#align category_theory.limits.of_iso_comparison CategoryTheory.Limits.ofIsoComparison
-/

variable [PreservesColimit (parallelPair f g) G]

#print CategoryTheory.Limits.PreservesCoequalizer.iso /-
/--
If `G` preserves the coequalizer of `(f,g)`, then the coequalizer comparison map for `G` at `(f,g)`
is an isomorphism.
-/
def PreservesCoequalizer.iso : coequalizer (G.map f) (G.map g) ≅ G.obj (coequalizer f g) :=
  IsColimit.coconePointUniqueUpToIso (colimit.isColimit _)
    (isColimitOfHasCoequalizerOfPreservesColimit G f g)
#align category_theory.limits.preserves_coequalizer.iso CategoryTheory.Limits.PreservesCoequalizer.iso
-/

#print CategoryTheory.Limits.PreservesCoequalizer.iso_hom /-
@[simp]
theorem PreservesCoequalizer.iso_hom :
    (PreservesCoequalizer.iso G f g).Hom = coequalizerComparison f g G :=
  rfl
#align category_theory.limits.preserves_coequalizer.iso_hom CategoryTheory.Limits.PreservesCoequalizer.iso_hom
-/

instance : IsIso (coequalizerComparison f g G) :=
  by
  rw [← preserves_coequalizer.iso_hom]
  infer_instance

#print CategoryTheory.Limits.map_π_epi /-
instance map_π_epi : Epi (G.map (coequalizer.π f g)) :=
  ⟨fun W h k => by rw [← ι_comp_coequalizer_comparison]; apply (cancel_epi _).1; apply epi_comp⟩
#align category_theory.limits.map_π_epi CategoryTheory.Limits.map_π_epi
-/

#print CategoryTheory.Limits.map_π_preserves_coequalizer_inv /-
@[reassoc]
theorem map_π_preserves_coequalizer_inv :
    G.map (coequalizer.π f g) ≫ (PreservesCoequalizer.iso G f g).inv =
      coequalizer.π (G.map f) (G.map g) :=
  by
  rw [← ι_comp_coequalizer_comparison_assoc, ← preserves_coequalizer.iso_hom, iso.hom_inv_id,
    comp_id]
#align category_theory.limits.map_π_preserves_coequalizer_inv CategoryTheory.Limits.map_π_preserves_coequalizer_inv
-/

#print CategoryTheory.Limits.map_π_preserves_coequalizer_inv_desc /-
@[reassoc]
theorem map_π_preserves_coequalizer_inv_desc {W : D} (k : G.obj Y ⟶ W)
    (wk : G.map f ≫ k = G.map g ≫ k) :
    G.map (coequalizer.π f g) ≫ (PreservesCoequalizer.iso G f g).inv ≫ coequalizer.desc k wk = k :=
  by rw [← category.assoc, map_π_preserves_coequalizer_inv, coequalizer.π_desc]
#align category_theory.limits.map_π_preserves_coequalizer_inv_desc CategoryTheory.Limits.map_π_preserves_coequalizer_inv_desc
-/

#print CategoryTheory.Limits.map_π_preserves_coequalizer_inv_colimMap /-
@[reassoc]
theorem map_π_preserves_coequalizer_inv_colimMap {X' Y' : D} (f' g' : X' ⟶ Y')
    [HasCoequalizer f' g'] (p : G.obj X ⟶ X') (q : G.obj Y ⟶ Y') (wf : G.map f ≫ q = p ≫ f')
    (wg : G.map g ≫ q = p ≫ g') :
    G.map (coequalizer.π f g) ≫
        (PreservesCoequalizer.iso G f g).inv ≫
          colimMap (parallelPairHom (G.map f) (G.map g) f' g' p q wf wg) =
      q ≫ coequalizer.π f' g' :=
  by rw [← category.assoc, map_π_preserves_coequalizer_inv, ι_colim_map, parallel_pair_hom_app_one]
#align category_theory.limits.map_π_preserves_coequalizer_inv_colim_map CategoryTheory.Limits.map_π_preserves_coequalizer_inv_colimMap
-/

#print CategoryTheory.Limits.map_π_preserves_coequalizer_inv_colimMap_desc /-
@[reassoc]
theorem map_π_preserves_coequalizer_inv_colimMap_desc {X' Y' : D} (f' g' : X' ⟶ Y')
    [HasCoequalizer f' g'] (p : G.obj X ⟶ X') (q : G.obj Y ⟶ Y') (wf : G.map f ≫ q = p ≫ f')
    (wg : G.map g ≫ q = p ≫ g') {Z' : D} (h : Y' ⟶ Z') (wh : f' ≫ h = g' ≫ h) :
    G.map (coequalizer.π f g) ≫
        (PreservesCoequalizer.iso G f g).inv ≫
          colimMap (parallelPairHom (G.map f) (G.map g) f' g' p q wf wg) ≫ coequalizer.desc h wh =
      q ≫ h :=
  by
  slice_lhs 1 3 => rw [map_π_preserves_coequalizer_inv_colim_map]
  slice_lhs 2 3 => rw [coequalizer.π_desc]
#align category_theory.limits.map_π_preserves_coequalizer_inv_colim_map_desc CategoryTheory.Limits.map_π_preserves_coequalizer_inv_colimMap_desc
-/

#print CategoryTheory.Limits.preservesSplitCoequalizers /-
/-- Any functor preserves coequalizers of split pairs. -/
instance (priority := 1) preservesSplitCoequalizers (f g : X ⟶ Y) [HasSplitCoequalizer f g] :
    PreservesColimit (parallelPair f g) G :=
  by
  apply
    preserves_colimit_of_preserves_colimit_cocone
      (has_split_coequalizer.is_split_coequalizer f g).isCoequalizer
  apply
    (is_colimit_map_cocone_cofork_equiv G _).symm
      ((has_split_coequalizer.is_split_coequalizer f g).map G).isCoequalizer
#align category_theory.limits.preserves_split_coequalizers CategoryTheory.Limits.preservesSplitCoequalizers
-/

end Coequalizers

end CategoryTheory.Limits

