/-
Copyright (c) 2022 Joël Riou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joël Riou

! This file was ported from Lean 3 source module category_theory.localization.construction
! leanprover-community/mathlib commit 9aba7801eeecebb61f58a5763c2b6dd1b47dc6ef
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.MorphismProperty
import Mathbin.CategoryTheory.Category.QuivCat

/-!

# Construction of the localized category

This file constructs the localized category, obtained by formally inverting
a class of maps `W : morphism_property C` in a category `C`.

We first construct a quiver `loc_quiver W` whose objects are the same as those
of `C` and whose maps are the maps in `C` and placeholders for the formal
inverses of the maps in `W`.

The localized category `W.localization` is obtained by taking the quotient
of the path category of `loc_quiver W` by the congruence generated by four
types of relations.

The obvious functor `Q W : C ⥤ W.localization` satisfies the universal property
of the localization. Indeed, if `G : C ⥤ D` sends morphisms in `W` to isomorphisms
in `D` (i.e. we have `hG : W.is_inverted_by G`), then there exists a unique functor
`G' : W.localization ⥤ D` such that `Q W ≫ G' = G`. This `G'` is `lift G hG`.
The expected property of `lift G hG` if expressed by the lemma `fac` and the
uniqueness is expressed by `uniq`.

## References

* [P. Gabriel, M. Zisman, *Calculus of fractions and homotopy theory*][gabriel-zisman-1967]

-/


noncomputable section

open CategoryTheory.Category

namespace CategoryTheory

variable {C : Type _} [Category C] (W : MorphismProperty C) {D : Type _} [Category D]

namespace Localization

namespace Construction

/-- If `W : morphism_property C`, `loc_quiver W` is a quiver with the same objects
as `C`, and whose morphisms are those in `C` and placeholders for formal
inverses of the morphisms in `W`. -/
@[nolint has_nonempty_instance]
structure LocQuiver (W : MorphismProperty C) where
  obj : C
#align
  category_theory.localization.construction.loc_quiver CategoryTheory.Localization.Construction.LocQuiver

instance : Quiver (LocQuiver W) where Hom A B := Sum (A.obj ⟶ B.obj) { f : B.obj ⟶ A.obj // W f }

/-- The object in the path category of `loc_quiver W` attached to an object in
the category `C` -/
def ιPaths (X : C) : Paths (LocQuiver W) :=
  ⟨X⟩
#align
  category_theory.localization.construction.ι_paths CategoryTheory.Localization.Construction.ιPaths

/-- The morphism in the path category associated to a morphism in the original category. -/
@[simp]
def ψ₁ {X Y : C} (f : X ⟶ Y) : ιPaths W X ⟶ ιPaths W Y :=
  Paths.of.map (Sum.inl f)
#align category_theory.localization.construction.ψ₁ CategoryTheory.Localization.Construction.ψ₁

/-- The morphism in the path category corresponding to a formal inverse. -/
@[simp]
def ψ₂ {X Y : C} (w : X ⟶ Y) (hw : W w) : ιPaths W Y ⟶ ιPaths W X :=
  Paths.of.map (Sum.inr ⟨w, hw⟩)
#align category_theory.localization.construction.ψ₂ CategoryTheory.Localization.Construction.ψ₂

/-- The relations by which we take the quotient in order to get the localized category. -/
inductive relations : HomRel (Paths (LocQuiver W))
  | id (X : C) : relations (ψ₁ W (𝟙 X)) (𝟙 _)
  | comp {X Y Z : C} (f : X ⟶ Y) (g : Y ⟶ Z) : relations (ψ₁ W (f ≫ g)) (ψ₁ W f ≫ ψ₁ W g)
  | Winv₁ {X Y : C} (w : X ⟶ Y) (hw : W w) : relations (ψ₁ W w ≫ ψ₂ W w hw) (𝟙 _)
  | Winv₂ {X Y : C} (w : X ⟶ Y) (hw : W w) : relations (ψ₂ W w hw ≫ ψ₁ W w) (𝟙 _)
#align
  category_theory.localization.construction.relations CategoryTheory.Localization.Construction.relations

end Construction

end Localization

namespace MorphismProperty

open Localization.Construction

/-- The localized category obtained by formally inverting the morphisms
in `W : morphism_property C` -/
@[nolint has_nonempty_instance]
def Localization :=
  CategoryTheory.Quotient (Localization.Construction.relations W)deriving Category
#align category_theory.morphism_property.localization CategoryTheory.MorphismProperty.Localization

/-- The obvious functor `C ⥤ W.localization` -/
def q : C ⥤ W.Localization
    where
  obj X := (Quotient.functor _).obj (Paths.of.obj ⟨X⟩)
  map X Y f := (Quotient.functor _).map (ψ₁ W f)
  map_id' X := Quotient.sound _ (relations.id X)
  map_comp' X Z Y f g := Quotient.sound _ (relations.comp f g)
#align category_theory.morphism_property.Q CategoryTheory.MorphismProperty.q

end MorphismProperty

namespace Localization

namespace Construction

variable {W}

/-- The isomorphism in `W.localization` associated to a morphism `w` in W -/
def wiso {X Y : C} (w : X ⟶ Y) (hw : W w) : Iso (W.q.obj X) (W.q.obj Y)
    where
  Hom := W.q.map w
  inv := (Quotient.functor _).map (Paths.of.map (Sum.inr ⟨w, hw⟩))
  hom_inv_id' := Quotient.sound _ (relations.Winv₁ w hw)
  inv_hom_id' := Quotient.sound _ (relations.Winv₂ w hw)
#align category_theory.localization.construction.Wiso CategoryTheory.Localization.Construction.wiso

/-- The formal inverse in `W.localization` of a morphism `w` in `W`. -/
abbrev winv {X Y : C} (w : X ⟶ Y) (hw : W w) :=
  (wiso w hw).inv
#align category_theory.localization.construction.Winv CategoryTheory.Localization.Construction.winv

variable (W)

theorem CategoryTheory.MorphismProperty.Q_inverts : W.IsInvertedBy W.q := fun X Y w hw =>
  IsIso.of_iso (Localization.Construction.wiso w hw)
#align category_theory.morphism_property.Q_inverts CategoryTheory.MorphismProperty.Q_inverts

variable {W} (G : C ⥤ D) (hG : W.IsInvertedBy G)

include G hG

/-- The lifting of a functor to the path category of `loc_quiver W` -/
@[simps]
def liftToPathCategory : Paths (LocQuiver W) ⥤ D :=
  QuivCat.lift
    { obj := fun X => G.obj X.obj
      map := fun X Y => by
        rintro (f | ⟨g, hg⟩)
        · exact G.map f
        · haveI := hG g hg
          exact inv (G.map g) }
#align
  category_theory.localization.construction.lift_to_path_category CategoryTheory.Localization.Construction.liftToPathCategory

/-- The lifting of a functor `C ⥤ D` inverting `W` as a functor `W.localization ⥤ D` -/
@[simps]
def lift : W.Localization ⥤ D :=
  Quotient.lift (relations W) (liftToPathCategory G hG)
    (by
      rintro ⟨X⟩ ⟨Y⟩ f₁ f₂ r
      rcases r with ⟨⟩
      tidy)
#align category_theory.localization.construction.lift CategoryTheory.Localization.Construction.lift

@[simp]
theorem fac : W.q ⋙ lift G hG = G :=
  Functor.ext (fun X => rfl)
    (by
      intro X Y f
      simp only [functor.comp_map, eq_to_hom_refl, comp_id, id_comp]
      dsimp [lift, lift_to_path_category, morphism_property.Q]
      rw [compose_path_to_path])
#align category_theory.localization.construction.fac CategoryTheory.Localization.Construction.fac

omit G hG

theorem uniq (G₁ G₂ : W.Localization ⥤ D) (h : W.q ⋙ G₁ = W.q ⋙ G₂) : G₁ = G₂ :=
  by
  suffices h' : quotient.functor _ ⋙ G₁ = quotient.functor _ ⋙ G₂
  · refine' Functor.ext _ _
    · rintro ⟨⟨X⟩⟩
      apply functor.congr_obj h
    · rintro ⟨⟨X⟩⟩ ⟨⟨Y⟩⟩ ⟨f⟩
      apply functor.congr_hom h'
  · refine' paths.ext_functor _ _
    · ext X
      cases X
      apply functor.congr_obj h
    · rintro ⟨X⟩ ⟨Y⟩ (f | ⟨w, hw⟩)
      · simpa only using functor.congr_hom h f
      · have hw : W.Q.map w = (Wiso w hw).Hom := rfl
        have hw' := functor.congr_hom h w
        simp only [functor.comp_map, hw] at hw'
        refine' functor.congr_inv_of_congr_hom _ _ _ _ _ hw'
        all_goals apply functor.congr_obj h
#align category_theory.localization.construction.uniq CategoryTheory.Localization.Construction.uniq

variable (W)

/-- The canonical bijection between objects in a category and its
localization with respect to a morphism_property `W` -/
@[simps]
def objEquiv : C ≃ W.Localization where
  toFun := W.q.obj
  invFun X := X.as.obj
  left_inv X := rfl
  right_inv := by
    rintro ⟨⟨X⟩⟩
    rfl
#align
  category_theory.localization.construction.obj_equiv CategoryTheory.Localization.Construction.objEquiv

variable {W}

/-- A `morphism_property` in `W.localization` is satisfied by all
morphisms in the localized category if it contains the image of the
morphisms in the original category, the inverses of the morphisms
in `W` and if it is stable under composition -/
theorem morphism_property_is_top (P : MorphismProperty W.Localization)
    (hP₁ : ∀ ⦃X Y : C⦄ (f : X ⟶ Y), P (W.q.map f))
    (hP₂ : ∀ ⦃X Y : C⦄ (w : X ⟶ Y) (hw : W w), P (winv w hw)) (hP₃ : P.StableUnderComposition) :
    P = ⊤ := by
  ext (X Y f)
  constructor
  · intro hf
    simp only [Pi.top_apply]
  · intro hf
    clear hf
    let G : _ ⥤ W.localization := quotient.functor _
    suffices
      ∀ (X₁ X₂ : C)
        (p : localization.construction.ι_paths W X₁ ⟶ localization.construction.ι_paths W X₂),
        P (G.map p)
      by
      rcases X with ⟨⟨X⟩⟩
      rcases Y with ⟨⟨Y⟩⟩
      simpa only [functor.image_preimage] using this _ _ (G.preimage f)
    intro X₁ X₂ p
    induction' p with X₂ X₃ p g hp
    · simpa only [Functor.map_id] using hP₁ (𝟙 X₁)
    · cases X₂
      cases X₃
      let p' : ι_paths W X₁ ⟶ ι_paths W X₂ := p
      rw [show p.cons g = p' ≫ Quiver.Hom.toPath g by rfl, G.map_comp]
      refine' hP₃ _ _ hp _
      rcases g with (g | ⟨g, hg⟩)
      · apply hP₁
      · apply hP₂
#align
  category_theory.localization.construction.morphism_property_is_top CategoryTheory.Localization.Construction.morphism_property_is_top

/-- A `morphism_property` in `W.localization` is satisfied by all
morphisms in the localized category if it contains the image of the
morphisms in the original category, if is stable under composition
and if the property is stable by passing to inverses. -/
theorem morphism_property_is_top' (P : MorphismProperty W.Localization)
    (hP₁ : ∀ ⦃X Y : C⦄ (f : X ⟶ Y), P (W.q.map f))
    (hP₂ : ∀ ⦃X Y : W.Localization⦄ (e : X ≅ Y) (he : P e.Hom), P e.inv)
    (hP₃ : P.StableUnderComposition) : P = ⊤ :=
  morphism_property_is_top P hP₁ (fun X Y w hw => hP₂ _ (hP₁ w)) hP₃
#align
  category_theory.localization.construction.morphism_property_is_top' CategoryTheory.Localization.Construction.morphism_property_is_top'

namespace NatTransExtension

variable {F₁ F₂ : W.Localization ⥤ D} (τ : W.q ⋙ F₁ ⟶ W.q ⋙ F₂)

include τ

/-- If `F₁` and `F₂` are functors `W.localization ⥤ D` and if we have
`τ : W.Q ⋙ F₁ ⟶ W.Q ⋙ F₂`, we shall define a natural transformation `F₁ ⟶ F₂`.
This is the `app` field of this natural transformation. -/
def app (X : W.Localization) : F₁.obj X ⟶ F₂.obj X :=
  eqToHom (congr_arg F₁.obj ((objEquiv W).right_inv X).symm) ≫
    τ.app ((objEquiv W).invFun X) ≫ eqToHom (congr_arg F₂.obj ((objEquiv W).right_inv X))
#align
  category_theory.localization.construction.nat_trans_extension.app CategoryTheory.Localization.Construction.NatTransExtension.app

@[simp]
theorem app_eq (X : C) : (app τ) (W.q.obj X) = τ.app X := by
  simpa only [app, eq_to_hom_refl, comp_id, id_comp]
#align
  category_theory.localization.construction.nat_trans_extension.app_eq CategoryTheory.Localization.Construction.NatTransExtension.app_eq

end NatTransExtension

/-- If `F₁` and `F₂` are functors `W.localization ⥤ D`, a natural transformation `F₁ ⟶ F₂`
can be obtained from a natural transformation `W.Q ⋙ F₁ ⟶ W.Q ⋙ F₂`. -/
@[simps]
def natTransExtension {F₁ F₂ : W.Localization ⥤ D} (τ : W.q ⋙ F₁ ⟶ W.q ⋙ F₂) : F₁ ⟶ F₂
    where
  app := NatTransExtension.app τ
  naturality' X Y f :=
    by
    have h :=
      morphism_property_is_top' (morphism_property.naturality_property (nat_trans_extension.app τ))
        _ (morphism_property.naturality_property.is_stable_under_inverse _)
        (morphism_property.naturality_property.is_stable_under_composition _)
    swap
    · intro X Y f
      simpa only [morphism_property.naturality_property, nat_trans_extension.app_eq] using
        τ.naturality f
    have hf : (⊤ : morphism_property _) f := by simp only [Pi.top_apply]
    simpa only [← h] using hf
#align
  category_theory.localization.construction.nat_trans_extension CategoryTheory.Localization.Construction.natTransExtension

@[simp]
theorem nat_trans_extension_hcomp {F G : W.Localization ⥤ D} (τ : W.q ⋙ F ⟶ W.q ⋙ G) :
    𝟙 W.q ◫ natTransExtension τ = τ := by
  ext X
  simp only [nat_trans.hcomp_app, nat_trans.id_app, G.map_id, comp_id, nat_trans_extension_app,
    nat_trans_extension.app_eq]
#align
  category_theory.localization.construction.nat_trans_extension_hcomp CategoryTheory.Localization.Construction.nat_trans_extension_hcomp

theorem nat_trans_hcomp_injective {F G : W.Localization ⥤ D} {τ₁ τ₂ : F ⟶ G}
    (h : 𝟙 W.q ◫ τ₁ = 𝟙 W.q ◫ τ₂) : τ₁ = τ₂ := by
  ext X
  have eq := (obj_equiv W).right_inv X
  simp only [obj_equiv] at eq
  rw [← Eq, ← nat_trans.id_hcomp_app, ← nat_trans.id_hcomp_app, h]
#align
  category_theory.localization.construction.nat_trans_hcomp_injective CategoryTheory.Localization.Construction.nat_trans_hcomp_injective

variable (W D)

namespace WhiskeringLeftEquivalence

/-- The functor `(W.localization ⥤ D) ⥤ (W.functors_inverting D)` induced by the
composition with `W.Q : C ⥤ W.localization`. -/
@[simps]
def functor : (W.Localization ⥤ D) ⥤ W.FunctorsInverting D :=
  FullSubcategory.lift _ ((whiskeringLeft _ _ D).obj W.q) fun F =>
    MorphismProperty.IsInvertedBy.of_comp W W.q W.Q_inverts _
#align
  category_theory.localization.construction.whiskering_left_equivalence.functor CategoryTheory.Localization.Construction.WhiskeringLeftEquivalence.functor

/-- The function `(W.functors_inverting D) ⥤ (W.localization ⥤ D)` induced by
`construction.lift`. -/
@[simps]
def inverse : W.FunctorsInverting D ⥤ W.Localization ⥤ D
    where
  obj G := lift G.obj G.property
  map G₁ G₂ τ := natTransExtension (eqToHom (by rw [fac]) ≫ τ ≫ eqToHom (by rw [fac]))
  map_id' G :=
    nat_trans_hcomp_injective
      (by
        rw [nat_trans_extension_hcomp]
        ext X
        simpa only [nat_trans.comp_app, eq_to_hom_app, eq_to_hom_refl, comp_id, id_comp,
          nat_trans.hcomp_id_app, nat_trans.id_app, Functor.map_id] )
  map_comp' G₁ G₂ G₃ τ₁ τ₂ :=
    nat_trans_hcomp_injective
      (by
        ext X
        simpa only [nat_trans_extension_hcomp, nat_trans.comp_app, eq_to_hom_app, eq_to_hom_refl,
          id_comp, comp_id, nat_trans.hcomp_app, nat_trans.id_app, Functor.map_id,
          nat_trans_extension_app, nat_trans_extension.app_eq] )
#align
  category_theory.localization.construction.whiskering_left_equivalence.inverse CategoryTheory.Localization.Construction.WhiskeringLeftEquivalence.inverse

/-- The unit isomorphism of the equivalence of categories `whiskering_left_equivalence W D`. -/
@[simps]
def unitIso : 𝟭 (W.Localization ⥤ D) ≅ functor W D ⋙ inverse W D :=
  eqToIso
    (by
      refine' Functor.ext (fun G => _) fun G₁ G₂ τ => _
      · apply uniq
        dsimp [Functor]
        rw [fac]
      · apply nat_trans_hcomp_injective
        ext X
        simp only [functor.id_map, nat_trans.hcomp_app, comp_id, functor.comp_map, inverse_map,
          nat_trans.comp_app, eq_to_hom_app, eq_to_hom_refl, nat_trans_extension_app,
          nat_trans_extension.app_eq, functor_map_app, id_comp])
#align
  category_theory.localization.construction.whiskering_left_equivalence.unit_iso CategoryTheory.Localization.Construction.WhiskeringLeftEquivalence.unitIso

/-- The counit isomorphism of the equivalence of categories `whiskering_left_equivalence W D`. -/
@[simps]
def counitIso : inverse W D ⋙ functor W D ≅ 𝟭 (W.FunctorsInverting D) :=
  eqToIso
    (by
      refine' Functor.ext _ _
      · rintro ⟨G, hG⟩
        ext1
        apply fac
      · rintro ⟨G₁, hG₁⟩ ⟨G₂, hG₂⟩ f
        ext X
        apply nat_trans_extension.app_eq)
#align
  category_theory.localization.construction.whiskering_left_equivalence.counit_iso CategoryTheory.Localization.Construction.WhiskeringLeftEquivalence.counitIso

end WhiskeringLeftEquivalence

/-- The equivalence of categories `(W.localization ⥤ D) ≌ (W.functors_inverting D)`
induced by the composition with `W.Q : C ⥤ W.localization`. -/
def whiskeringLeftEquivalence : W.Localization ⥤ D ≌ W.FunctorsInverting D
    where
  Functor := WhiskeringLeftEquivalence.functor W D
  inverse := WhiskeringLeftEquivalence.inverse W D
  unitIso := WhiskeringLeftEquivalence.unitIso W D
  counitIso := WhiskeringLeftEquivalence.counitIso W D
  functor_unit_iso_comp' F := by
    ext X
    simpa only [eq_to_hom_app, whiskering_left_equivalence.unit_iso_hom,
      whiskering_left_equivalence.counit_iso_hom, eq_to_hom_map, eq_to_hom_trans, eq_to_hom_refl]
#align
  category_theory.localization.construction.whiskering_left_equivalence CategoryTheory.Localization.Construction.whiskeringLeftEquivalence

end Construction

end Localization

end CategoryTheory

