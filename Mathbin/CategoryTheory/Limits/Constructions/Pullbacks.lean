/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.limits.constructions.pullbacks
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathbin.CategoryTheory.Limits.Shapes.Equalizers
import Mathbin.CategoryTheory.Limits.Shapes.Pullbacks

/-!
# Constructing pullbacks from binary products and equalizers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If a category as binary products and equalizers, then it has pullbacks.
Also, if a category has binary coproducts and coequalizers, then it has pushouts
-/


universe v u

open CategoryTheory

namespace CategoryTheory.Limits

#print CategoryTheory.Limits.hasLimit_cospan_of_hasLimit_pair_of_hasLimit_parallelPair /-
/-- If the product `X ⨯ Y` and the equalizer of `π₁ ≫ f` and `π₂ ≫ g` exist, then the
    pullback of `f` and `g` exists: It is given by composing the equalizer with the projections. -/
theorem hasLimit_cospan_of_hasLimit_pair_of_hasLimit_parallelPair {C : Type u} [𝒞 : Category.{v} C]
    {X Y Z : C} (f : X ⟶ Z) (g : Y ⟶ Z) [HasLimit (pair X Y)]
    [HasLimit (parallelPair (prod.fst ≫ f) (prod.snd ≫ g))] : HasLimit (cospan f g) :=
  let π₁ : X ⨯ Y ⟶ X := prod.fst
  let π₂ : X ⨯ Y ⟶ Y := prod.snd
  let e := equalizer.ι (π₁ ≫ f) (π₂ ≫ g)
  HasLimit.mk
    { Cone :=
        PullbackCone.mk (e ≫ π₁) (e ≫ π₂) <| by simp only [category.assoc, equalizer.condition]
      IsLimit :=
        PullbackCone.IsLimit.mk _
          (fun s =>
            equalizer.lift (prod.lift (s.π.app WalkingCospan.left) (s.π.app WalkingCospan.right)) <|
              by
              rw [← category.assoc, limit.lift_π, ← category.assoc, limit.lift_π] <;>
                exact pullback_cone.condition _)
          (by simp) (by simp) fun s m h₁ h₂ => by
          ext
          · simpa using h₁
          · simpa using h₂ }
#align category_theory.limits.has_limit_cospan_of_has_limit_pair_of_has_limit_parallel_pair CategoryTheory.Limits.hasLimit_cospan_of_hasLimit_pair_of_hasLimit_parallelPair
-/

section

attribute [local instance] has_limit_cospan_of_has_limit_pair_of_has_limit_parallel_pair

#print CategoryTheory.Limits.hasPullbacks_of_hasBinaryProducts_of_hasEqualizers /-
/-- If a category has all binary products and all equalizers, then it also has all pullbacks.
    As usual, this is not an instance, since there may be a more direct way to construct
    pullbacks. -/
theorem hasPullbacks_of_hasBinaryProducts_of_hasEqualizers (C : Type u) [𝒞 : Category.{v} C]
    [HasBinaryProducts C] [HasEqualizers C] : HasPullbacks C :=
  { HasLimit := fun F => hasLimitOfIso (diagramIsoCospan F).symm }
#align category_theory.limits.has_pullbacks_of_has_binary_products_of_has_equalizers CategoryTheory.Limits.hasPullbacks_of_hasBinaryProducts_of_hasEqualizers
-/

end

#print CategoryTheory.Limits.hasColimit_span_of_hasColimit_pair_of_hasColimit_parallelPair /-
/-- If the coproduct `Y ⨿ Z` and the coequalizer of `f ≫ ι₁` and `g ≫ ι₂` exist, then the
    pushout of `f` and `g` exists: It is given by composing the inclusions with the coequalizer. -/
theorem hasColimit_span_of_hasColimit_pair_of_hasColimit_parallelPair {C : Type u}
    [𝒞 : Category.{v} C] {X Y Z : C} (f : X ⟶ Y) (g : X ⟶ Z) [HasColimit (pair Y Z)]
    [HasColimit (parallelPair (f ≫ coprod.inl) (g ≫ coprod.inr))] : HasColimit (span f g) :=
  let ι₁ : Y ⟶ Y ⨿ Z := coprod.inl
  let ι₂ : Z ⟶ Y ⨿ Z := coprod.inr
  let c := coequalizer.π (f ≫ ι₁) (g ≫ ι₂)
  HasColimit.mk
    { Cocone :=
        PushoutCocone.mk (ι₁ ≫ c) (ι₂ ≫ c) <| by
          rw [← category.assoc, ← category.assoc, coequalizer.condition]
      IsColimit :=
        PushoutCocone.IsColimit.mk _
          (fun s =>
            coequalizer.desc (coprod.desc (s.ι.app WalkingSpan.left) (s.ι.app WalkingSpan.right)) <|
              by
              rw [category.assoc, colimit.ι_desc, category.assoc, colimit.ι_desc] <;>
                exact pushout_cocone.condition _)
          (by simp) (by simp) fun s m h₁ h₂ => by
          ext
          · simpa using h₁
          · simpa using h₂ }
#align category_theory.limits.has_colimit_span_of_has_colimit_pair_of_has_colimit_parallel_pair CategoryTheory.Limits.hasColimit_span_of_hasColimit_pair_of_hasColimit_parallelPair
-/

section

attribute [local instance] has_colimit_span_of_has_colimit_pair_of_has_colimit_parallel_pair

#print CategoryTheory.Limits.hasPushouts_of_hasBinaryCoproducts_of_hasCoequalizers /-
/-- If a category has all binary coproducts and all coequalizers, then it also has all pushouts.
    As usual, this is not an instance, since there may be a more direct way to construct
    pushouts. -/
theorem hasPushouts_of_hasBinaryCoproducts_of_hasCoequalizers (C : Type u) [𝒞 : Category.{v} C]
    [HasBinaryCoproducts C] [HasCoequalizers C] : HasPushouts C :=
  hasPushouts_of_hasColimit_span C
#align category_theory.limits.has_pushouts_of_has_binary_coproducts_of_has_coequalizers CategoryTheory.Limits.hasPushouts_of_hasBinaryCoproducts_of_hasCoequalizers
-/

end

end CategoryTheory.Limits

