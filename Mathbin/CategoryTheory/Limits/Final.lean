/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.limits.final
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Punit
import Mathbin.CategoryTheory.StructuredArrow
import Mathbin.CategoryTheory.IsConnected
import Mathbin.CategoryTheory.Limits.Yoneda
import Mathbin.CategoryTheory.Limits.Types

/-!
# Final and initial functors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A functor `F : C ⥤ D` is final if for every `d : D`,
the comma category of morphisms `d ⟶ F.obj c` is connected.

Dually, a functor `F : C ⥤ D` is initial if for every `d : D`,
the comma category of morphisms `F.obj c ⟶ d` is connected.

We show that right adjoints are examples of final functors, while
left adjoints are examples of initial functors.

For final functors, we prove that the following three statements are equivalent:
1. `F : C ⥤ D` is final.
2. Every functor `G : D ⥤ E` has a colimit if and only if `F ⋙ G` does,
   and these colimits are isomorphic via `colimit.pre G F`.
3. `colimit (F ⋙ coyoneda.obj (op d)) ≅ punit`.

Starting at 1. we show (in `cocones_equiv`) that
the categories of cocones over `G : D ⥤ E` and over `F ⋙ G` are equivalent.
(In fact, via an equivalence which does not change the cocone point.)
This readily implies 2., as `comp_has_colimit`, `has_colimit_of_comp`, and `colimit_iso`.

From 2. we can specialize to `G = coyoneda.obj (op d)` to obtain 3., as `colimit_comp_coyoneda_iso`.

From 3., we prove 1. directly in `cofinal_of_colimit_comp_coyoneda_iso_punit`.

Dually, we prove that if a functor `F : C ⥤ D` is initial, then any functor `G : D ⥤ E` has a
limit if and only if `F ⋙ G` does, and these limits are isomorphic via `limit.pre G F`.


## Naming
There is some discrepancy in the literature about naming; some say 'cofinal' instead of 'final'.
The explanation for this is that the 'co' prefix here is *not* the usual category-theoretic one
indicating duality, but rather indicating the sense of "along with".

## Future work
Dualise condition 3 above and the implications 2 ⇒ 3 and 3 ⇒ 1 to initial functors.

## References
* https://stacks.math.columbia.edu/tag/09WN
* https://ncatlab.org/nlab/show/final+functor
* Borceux, Handbook of Categorical Algebra I, Section 2.11.
  (Note he reverses the roles of definition and main result relative to here!)
-/


noncomputable section

universe v v₁ v₂ v₃ u₁ u₂ u₃

namespace CategoryTheory

namespace Functor

open Opposite

open CategoryTheory.Limits

section ArbitraryUniverse

variable {C : Type u₁} [Category.{v₁} C]

variable {D : Type u₂} [Category.{v₂} D]

#print CategoryTheory.Functor.Final /-
/--
A functor `F : C ⥤ D` is final if for every `d : D`, the comma category of morphisms `d ⟶ F.obj c`
is connected.

See <https://stacks.math.columbia.edu/tag/04E6>
-/
class Final (F : C ⥤ D) : Prop where
  out (d : D) : IsConnected (StructuredArrow d F)
#align category_theory.functor.final CategoryTheory.Functor.Final
-/

attribute [instance] final.out

#print CategoryTheory.Functor.Initial /-
/-- A functor `F : C ⥤ D` is initial if for every `d : D`, the comma category of morphisms
`F.obj c ⟶ d` is connected.
-/
class Initial (F : C ⥤ D) : Prop where
  out (d : D) : IsConnected (CostructuredArrow F d)
#align category_theory.functor.initial CategoryTheory.Functor.Initial
-/

attribute [instance] initial.out

#print CategoryTheory.Functor.final_op_of_initial /-
instance final_op_of_initial (F : C ⥤ D) [Initial F] : Final F.op
    where out d := isConnected_of_equivalent (costructuredArrowOpEquivalence F (unop d))
#align category_theory.functor.final_op_of_initial CategoryTheory.Functor.final_op_of_initial
-/

#print CategoryTheory.Functor.initial_op_of_final /-
instance initial_op_of_final (F : C ⥤ D) [Final F] : Initial F.op
    where out d := isConnected_of_equivalent (structuredArrowOpEquivalence F (unop d))
#align category_theory.functor.initial_op_of_final CategoryTheory.Functor.initial_op_of_final
-/

#print CategoryTheory.Functor.final_of_initial_op /-
theorem final_of_initial_op (F : C ⥤ D) [Initial F.op] : Final F :=
  {
    out := fun d =>
      @isConnected_of_isConnected_op _ _
        (isConnected_of_equivalent (structuredArrowOpEquivalence F d).symm) }
#align category_theory.functor.final_of_initial_op CategoryTheory.Functor.final_of_initial_op
-/

#print CategoryTheory.Functor.initial_of_final_op /-
theorem initial_of_final_op (F : C ⥤ D) [Final F.op] : Initial F :=
  {
    out := fun d =>
      @isConnected_of_isConnected_op _ _
        (isConnected_of_equivalent (costructuredArrowOpEquivalence F d).symm) }
#align category_theory.functor.initial_of_final_op CategoryTheory.Functor.initial_of_final_op
-/

#print CategoryTheory.Functor.final_of_adjunction /-
/-- If a functor `R : D ⥤ C` is a right adjoint, it is final. -/
theorem final_of_adjunction {L : C ⥤ D} {R : D ⥤ C} (adj : L ⊣ R) : Final R :=
  {
    out := fun c =>
      let u : StructuredArrow c R := StructuredArrow.mk (adj.Unit.app c)
      @zigzag_isConnected _ _ ⟨u⟩ fun f g =>
        Relation.ReflTransGen.trans
          (Relation.ReflTransGen.single
            (show Zag f u from
              Or.inr ⟨StructuredArrow.homMk ((adj.homEquiv c f.right).symm f.Hom) (by simp)⟩))
          (Relation.ReflTransGen.single
            (show Zag u g from
              Or.inl ⟨StructuredArrow.homMk ((adj.homEquiv c g.right).symm g.Hom) (by simp)⟩)) }
#align category_theory.functor.final_of_adjunction CategoryTheory.Functor.final_of_adjunction
-/

#print CategoryTheory.Functor.initial_of_adjunction /-
/-- If a functor `L : C ⥤ D` is a left adjoint, it is initial. -/
theorem initial_of_adjunction {L : C ⥤ D} {R : D ⥤ C} (adj : L ⊣ R) : Initial L :=
  {
    out := fun d =>
      let u : CostructuredArrow L d := CostructuredArrow.mk (adj.counit.app d)
      @zigzag_isConnected _ _ ⟨u⟩ fun f g =>
        Relation.ReflTransGen.trans
          (Relation.ReflTransGen.single
            (show Zag f u from
              Or.inl ⟨CostructuredArrow.homMk (adj.homEquiv f.left d f.Hom) (by simp)⟩))
          (Relation.ReflTransGen.single
            (show Zag u g from
              Or.inr ⟨CostructuredArrow.homMk (adj.homEquiv g.left d g.Hom) (by simp)⟩)) }
#align category_theory.functor.initial_of_adjunction CategoryTheory.Functor.initial_of_adjunction
-/

#print CategoryTheory.Functor.final_of_isRightAdjoint /-
instance (priority := 100) final_of_isRightAdjoint (F : C ⥤ D) [h : IsRightAdjoint F] : Final F :=
  final_of_adjunction h.adj
#align category_theory.functor.final_of_is_right_adjoint CategoryTheory.Functor.final_of_isRightAdjoint
-/

#print CategoryTheory.Functor.initial_of_isLeftAdjoint /-
instance (priority := 100) initial_of_isLeftAdjoint (F : C ⥤ D) [h : IsLeftAdjoint F] : Initial F :=
  initial_of_adjunction h.adj
#align category_theory.functor.initial_of_is_left_adjoint CategoryTheory.Functor.initial_of_isLeftAdjoint
-/

namespace Final

variable (F : C ⥤ D) [Final F]

instance (d : D) : Nonempty (StructuredArrow d F) :=
  IsConnected.is_nonempty

variable {E : Type u₃} [Category.{v₃} E] (G : D ⥤ E)

#print CategoryTheory.Functor.Final.lift /-
/--
When `F : C ⥤ D` is cofinal, we denote by `lift F d` an arbitrary choice of object in `C` such that
there exists a morphism `d ⟶ F.obj (lift F d)`.
-/
def lift (d : D) : C :=
  (Classical.arbitrary (StructuredArrow d F)).right
#align category_theory.functor.final.lift CategoryTheory.Functor.Final.lift
-/

#print CategoryTheory.Functor.Final.homToLift /-
/-- When `F : C ⥤ D` is cofinal, we denote by `hom_to_lift` an arbitrary choice of morphism
`d ⟶ F.obj (lift F d)`.
-/
def homToLift (d : D) : d ⟶ F.obj (lift F d) :=
  (Classical.arbitrary (StructuredArrow d F)).Hom
#align category_theory.functor.final.hom_to_lift CategoryTheory.Functor.Final.homToLift
-/

#print CategoryTheory.Functor.Final.induction /-
/-- We provide an induction principle for reasoning about `lift` and `hom_to_lift`.
We want to perform some construction (usually just a proof) about
the particular choices `lift F d` and `hom_to_lift F d`,
it suffices to perform that construction for some other pair of choices
(denoted `X₀ : C` and `k₀ : d ⟶ F.obj X₀` below),
and to show how to transport such a construction
*both* directions along a morphism between such choices.
-/
def induction {d : D} (Z : ∀ (X : C) (k : d ⟶ F.obj X), Sort _)
    (h₁ :
      ∀ (X₁ X₂) (k₁ : d ⟶ F.obj X₁) (k₂ : d ⟶ F.obj X₂) (f : X₁ ⟶ X₂),
        k₁ ≫ F.map f = k₂ → Z X₁ k₁ → Z X₂ k₂)
    (h₂ :
      ∀ (X₁ X₂) (k₁ : d ⟶ F.obj X₁) (k₂ : d ⟶ F.obj X₂) (f : X₁ ⟶ X₂),
        k₁ ≫ F.map f = k₂ → Z X₂ k₂ → Z X₁ k₁)
    {X₀ : C} {k₀ : d ⟶ F.obj X₀} (z : Z X₀ k₀) : Z (lift F d) (homToLift F d) :=
  by
  apply Nonempty.some
  apply
    @is_preconnected_induction _ _ _ (fun Y : structured_arrow d F => Z Y.right Y.Hom) _ _
      (structured_arrow.mk k₀) z
  · intro j₁ j₂ f a; fapply h₁ _ _ _ _ f.right _ a; convert f.w.symm; dsimp; simp
  · intro j₁ j₂ f a; fapply h₂ _ _ _ _ f.right _ a; convert f.w.symm; dsimp; simp
#align category_theory.functor.final.induction CategoryTheory.Functor.Final.induction
-/

variable {F G}

#print CategoryTheory.Functor.Final.extendCocone /-
/-- Given a cocone over `F ⋙ G`, we can construct a `cocone G` with the same cocone point.
-/
@[simps]
def extendCocone : Cocone (F ⋙ G) ⥤ Cocone G
    where
  obj c :=
    { pt := c.pt
      ι :=
        { app := fun X => G.map (homToLift F X) ≫ c.ι.app (lift F X)
          naturality' := fun X Y f => by
            dsimp; simp
            -- This would be true if we'd chosen `lift F X` to be `lift F Y`
            -- and `hom_to_lift F X` to be `f ≫ hom_to_lift F Y`.
            apply
              induction F fun Z k =>
                G.map f ≫ G.map (hom_to_lift F Y) ≫ c.ι.app (lift F Y) = G.map k ≫ c.ι.app Z
            · intro Z₁ Z₂ k₁ k₂ g a z
              rw [← a, functor.map_comp, category.assoc, ← functor.comp_map, c.w, z]
            · intro Z₁ Z₂ k₁ k₂ g a z
              rw [← a, functor.map_comp, category.assoc, ← functor.comp_map, c.w] at z 
              rw [z]
            · rw [← functor.map_comp_assoc] } }
  map X Y f := { Hom := f.Hom }
#align category_theory.functor.final.extend_cocone CategoryTheory.Functor.Final.extendCocone
-/

#print CategoryTheory.Functor.Final.colimit_cocone_comp_aux /-
@[simp]
theorem colimit_cocone_comp_aux (s : Cocone (F ⋙ G)) (j : C) :
    G.map (homToLift F (F.obj j)) ≫ s.ι.app (lift F (F.obj j)) = s.ι.app j :=
  by
  -- This point is that this would be true if we took `lift (F.obj j)` to just be `j`
  -- and `hom_to_lift (F.obj j)` to be `𝟙 (F.obj j)`.
  apply induction F fun X k => G.map k ≫ s.ι.app X = (s.ι.app j : _)
  · intro j₁ j₂ k₁ k₂ f w h; rw [← w]; rw [← s.w f] at h ; simpa using h
  · intro j₁ j₂ k₁ k₂ f w h; rw [← w] at h ; rw [← s.w f]; simpa using h
  · exact s.w (𝟙 _)
#align category_theory.functor.final.colimit_cocone_comp_aux CategoryTheory.Functor.Final.colimit_cocone_comp_aux
-/

variable (F G)

#print CategoryTheory.Functor.Final.coconesEquiv /-
/-- If `F` is cofinal,
the category of cocones on `F ⋙ G` is equivalent to the category of cocones on `G`,
for any `G : D ⥤ E`.
-/
@[simps]
def coconesEquiv : Cocone (F ⋙ G) ≌ Cocone G
    where
  Functor := extendCocone
  inverse := Cocones.whiskering F
  unitIso := NatIso.ofComponents (fun c => Cocones.ext (Iso.refl _) (by tidy)) (by tidy)
  counitIso := NatIso.ofComponents (fun c => Cocones.ext (Iso.refl _) (by tidy)) (by tidy)
#align category_theory.functor.final.cocones_equiv CategoryTheory.Functor.Final.coconesEquiv
-/

variable {G}

#print CategoryTheory.Functor.Final.isColimitWhiskerEquiv /-
/-- When `F : C ⥤ D` is cofinal, and `t : cocone G` for some `G : D ⥤ E`,
`t.whisker F` is a colimit cocone exactly when `t` is.
-/
def isColimitWhiskerEquiv (t : Cocone G) : IsColimit (t.whisker F) ≃ IsColimit t :=
  IsColimit.ofCoconeEquiv (coconesEquiv F G).symm
#align category_theory.functor.final.is_colimit_whisker_equiv CategoryTheory.Functor.Final.isColimitWhiskerEquiv
-/

#print CategoryTheory.Functor.Final.isColimitExtendCoconeEquiv /-
/-- When `F` is cofinal, and `t : cocone (F ⋙ G)`,
`extend_cocone.obj t` is a colimit coconne exactly when `t` is.
-/
def isColimitExtendCoconeEquiv (t : Cocone (F ⋙ G)) :
    IsColimit (extendCocone.obj t) ≃ IsColimit t :=
  IsColimit.ofCoconeEquiv (coconesEquiv F G)
#align category_theory.functor.final.is_colimit_extend_cocone_equiv CategoryTheory.Functor.Final.isColimitExtendCoconeEquiv
-/

#print CategoryTheory.Functor.Final.colimitCoconeComp /-
/-- Given a colimit cocone over `G : D ⥤ E` we can construct a colimit cocone over `F ⋙ G`. -/
@[simps]
def colimitCoconeComp (t : ColimitCocone G) : ColimitCocone (F ⋙ G)
    where
  Cocone := _
  IsColimit := (isColimitWhiskerEquiv F _).symm t.IsColimit
#align category_theory.functor.final.colimit_cocone_comp CategoryTheory.Functor.Final.colimitCoconeComp
-/

#print CategoryTheory.Functor.Final.comp_hasColimit /-
instance (priority := 100) comp_hasColimit [HasColimit G] : HasColimit (F ⋙ G) :=
  HasColimit.mk (colimitCoconeComp F (getColimitCocone G))
#align category_theory.functor.final.comp_has_colimit CategoryTheory.Functor.Final.comp_hasColimit
-/

#print CategoryTheory.Functor.Final.colimit_pre_is_iso_aux /-
theorem colimit_pre_is_iso_aux {t : Cocone G} (P : IsColimit t) :
    ((isColimitWhiskerEquiv F _).symm P).desc (t.whisker F) = 𝟙 t.pt :=
  by
  dsimp [is_colimit_whisker_equiv]
  apply P.hom_ext
  intro j
  dsimp; simp
#align category_theory.functor.final.colimit_pre_is_iso_aux CategoryTheory.Functor.Final.colimit_pre_is_iso_aux
-/

#print CategoryTheory.Functor.Final.colimit_pre_isIso /-
instance colimit_pre_isIso [HasColimit G] : IsIso (colimit.pre G F) :=
  by
  rw [colimit.pre_eq (colimit_cocone_comp F (get_colimit_cocone G)) (get_colimit_cocone G)]
  erw [colimit_pre_is_iso_aux]
  dsimp
  infer_instance
#align category_theory.functor.final.colimit_pre_is_iso CategoryTheory.Functor.Final.colimit_pre_isIso
-/

section

variable (G)

#print CategoryTheory.Functor.Final.colimitIso /-
/-- When `F : C ⥤ D` is cofinal, and `G : D ⥤ E` has a colimit, then `F ⋙ G` has a colimit also and
`colimit (F ⋙ G) ≅ colimit G`

https://stacks.math.columbia.edu/tag/04E7
-/
def colimitIso [HasColimit G] : colimit (F ⋙ G) ≅ colimit G :=
  asIso (colimit.pre G F)
#align category_theory.functor.final.colimit_iso CategoryTheory.Functor.Final.colimitIso
-/

end

#print CategoryTheory.Functor.Final.colimitCoconeOfComp /-
/-- Given a colimit cocone over `F ⋙ G` we can construct a colimit cocone over `G`. -/
@[simps]
def colimitCoconeOfComp (t : ColimitCocone (F ⋙ G)) : ColimitCocone G
    where
  Cocone := extendCocone.obj t.Cocone
  IsColimit := (isColimitExtendCoconeEquiv F _).symm t.IsColimit
#align category_theory.functor.final.colimit_cocone_of_comp CategoryTheory.Functor.Final.colimitCoconeOfComp
-/

#print CategoryTheory.Functor.Final.hasColimit_of_comp /-
/-- When `F` is cofinal, and `F ⋙ G` has a colimit, then `G` has a colimit also.

We can't make this an instance, because `F` is not determined by the goal.
(Even if this weren't a problem, it would cause a loop with `comp_has_colimit`.)
-/
theorem hasColimit_of_comp [HasColimit (F ⋙ G)] : HasColimit G :=
  HasColimit.mk (colimitCoconeOfComp F (getColimitCocone (F ⋙ G)))
#align category_theory.functor.final.has_colimit_of_comp CategoryTheory.Functor.Final.hasColimit_of_comp
-/

section

attribute [local instance] has_colimit_of_comp

#print CategoryTheory.Functor.Final.colimitIso' /-
/-- When `F` is cofinal, and `F ⋙ G` has a colimit, then `G` has a colimit also and
`colimit (F ⋙ G) ≅ colimit G`

https://stacks.math.columbia.edu/tag/04E7
-/
def colimitIso' [HasColimit (F ⋙ G)] : colimit (F ⋙ G) ≅ colimit G :=
  asIso (colimit.pre G F)
#align category_theory.functor.final.colimit_iso' CategoryTheory.Functor.Final.colimitIso'
-/

end

end Final

end ArbitraryUniverse

namespace Final

variable {C : Type v} [Category.{v} C] {D : Type v} [Category.{v} D] (F : C ⥤ D) [Final F]

#print CategoryTheory.Functor.Final.colimitCompCoyonedaIso /-
/-- If the universal morphism `colimit (F ⋙ coyoneda.obj (op d)) ⟶ colimit (coyoneda.obj (op d))`
is an isomorphism (as it always is when `F` is cofinal),
then `colimit (F ⋙ coyoneda.obj (op d)) ≅ punit`
(simply because `colimit (coyoneda.obj (op d)) ≅ punit`).
-/
def colimitCompCoyonedaIso (d : D) [IsIso (colimit.pre (coyoneda.obj (op d)) F)] :
    colimit (F ⋙ coyoneda.obj (op d)) ≅ PUnit :=
  asIso (colimit.pre (coyoneda.obj (op d)) F) ≪≫ Coyoneda.colimitCoyonedaIso (op d)
#align category_theory.functor.final.colimit_comp_coyoneda_iso CategoryTheory.Functor.Final.colimitCompCoyonedaIso
-/

#print CategoryTheory.Functor.Final.zigzag_of_eqvGen_quot_rel /-
theorem zigzag_of_eqvGen_quot_rel {F : C ⥤ D} {d : D} {f₁ f₂ : Σ X, d ⟶ F.obj X}
    (t : EqvGen (Types.Quot.Rel.{v, v} (F ⋙ coyoneda.obj (op d))) f₁ f₂) :
    Zigzag (StructuredArrow.mk f₁.2) (StructuredArrow.mk f₂.2) :=
  by
  induction t
  case rel x y r =>
    obtain ⟨f, w⟩ := r
    fconstructor
    swap; fconstructor
    left; fconstructor
    exact structured_arrow.hom_mk f (by tidy)
  case refl => fconstructor
  case symm x y h ih =>
    apply zigzag_symmetric
    exact ih
  case trans x y z h₁ h₂ ih₁ ih₂ =>
    apply Relation.ReflTransGen.trans
    exact ih₁; exact ih₂
#align category_theory.functor.final.zigzag_of_eqv_gen_quot_rel CategoryTheory.Functor.Final.zigzag_of_eqvGen_quot_rel
-/

#print CategoryTheory.Functor.Final.cofinal_of_colimit_comp_coyoneda_iso_pUnit /-
/-- If `colimit (F ⋙ coyoneda.obj (op d)) ≅ punit` for all `d : D`, then `F` is cofinal.
-/
theorem cofinal_of_colimit_comp_coyoneda_iso_pUnit
    (I : ∀ d, colimit (F ⋙ coyoneda.obj (op d)) ≅ PUnit) : Final F :=
  ⟨fun d =>
    by
    have : Nonempty (structured_arrow d F) :=
      by
      have := (I d).inv PUnit.unit
      obtain ⟨j, y, rfl⟩ := Limits.Types.jointly_surjective'.{v, v} this
      exact ⟨structured_arrow.mk y⟩
    apply zigzag_is_connected
    rintro ⟨⟨⟨⟩⟩, X₁, f₁⟩ ⟨⟨⟨⟩⟩, X₂, f₂⟩
    dsimp at *
    let y₁ := colimit.ι (F ⋙ coyoneda.obj (op d)) X₁ f₁
    let y₂ := colimit.ι (F ⋙ coyoneda.obj (op d)) X₂ f₂
    have e : y₁ = y₂ := by apply (I d).toEquiv.Injective; ext
    have t := Types.colimit_eq.{v, v} e
    clear e y₁ y₂
    exact zigzag_of_eqv_gen_quot_rel t⟩
#align category_theory.functor.final.cofinal_of_colimit_comp_coyoneda_iso_punit CategoryTheory.Functor.Final.cofinal_of_colimit_comp_coyoneda_iso_pUnit
-/

end Final

namespace Initial

variable {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D] (F : C ⥤ D) [Initial F]

instance (d : D) : Nonempty (CostructuredArrow F d) :=
  IsConnected.is_nonempty

variable {E : Type u₃} [Category.{v₃} E] (G : D ⥤ E)

#print CategoryTheory.Functor.Initial.lift /-
/--
When `F : C ⥤ D` is initial, we denote by `lift F d` an arbitrary choice of object in `C` such that
there exists a morphism `F.obj (lift F d) ⟶ d`.
-/
def lift (d : D) : C :=
  (Classical.arbitrary (CostructuredArrow F d)).left
#align category_theory.functor.initial.lift CategoryTheory.Functor.Initial.lift
-/

#print CategoryTheory.Functor.Initial.homToLift /-
/-- When `F : C ⥤ D` is initial, we denote by `hom_to_lift` an arbitrary choice of morphism
`F.obj (lift F d) ⟶ d`.
-/
def homToLift (d : D) : F.obj (lift F d) ⟶ d :=
  (Classical.arbitrary (CostructuredArrow F d)).Hom
#align category_theory.functor.initial.hom_to_lift CategoryTheory.Functor.Initial.homToLift
-/

#print CategoryTheory.Functor.Initial.induction /-
/-- We provide an induction principle for reasoning about `lift` and `hom_to_lift`.
We want to perform some construction (usually just a proof) about
the particular choices `lift F d` and `hom_to_lift F d`,
it suffices to perform that construction for some other pair of choices
(denoted `X₀ : C` and `k₀ : F.obj X₀ ⟶ d` below),
and to show how to transport such a construction
*both* directions along a morphism between such choices.
-/
def induction {d : D} (Z : ∀ (X : C) (k : F.obj X ⟶ d), Sort _)
    (h₁ :
      ∀ (X₁ X₂) (k₁ : F.obj X₁ ⟶ d) (k₂ : F.obj X₂ ⟶ d) (f : X₁ ⟶ X₂),
        F.map f ≫ k₂ = k₁ → Z X₁ k₁ → Z X₂ k₂)
    (h₂ :
      ∀ (X₁ X₂) (k₁ : F.obj X₁ ⟶ d) (k₂ : F.obj X₂ ⟶ d) (f : X₁ ⟶ X₂),
        F.map f ≫ k₂ = k₁ → Z X₂ k₂ → Z X₁ k₁)
    {X₀ : C} {k₀ : F.obj X₀ ⟶ d} (z : Z X₀ k₀) : Z (lift F d) (homToLift F d) :=
  by
  apply Nonempty.some
  apply
    @is_preconnected_induction _ _ _ (fun Y : costructured_arrow F d => Z Y.left Y.Hom) _ _
      (costructured_arrow.mk k₀) z
  · intro j₁ j₂ f a; fapply h₁ _ _ _ _ f.left _ a; convert f.w; dsimp; simp
  · intro j₁ j₂ f a; fapply h₂ _ _ _ _ f.left _ a; convert f.w; dsimp; simp
#align category_theory.functor.initial.induction CategoryTheory.Functor.Initial.induction
-/

variable {F G}

#print CategoryTheory.Functor.Initial.extendCone /-
/-- Given a cone over `F ⋙ G`, we can construct a `cone G` with the same cocone point.
-/
@[simps]
def extendCone : Cone (F ⋙ G) ⥤ Cone G
    where
  obj c :=
    { pt := c.pt
      π :=
        { app := fun d => c.π.app (lift F d) ≫ G.map (homToLift F d)
          naturality' := fun X Y f => by
            dsimp; simp
            -- This would be true if we'd chosen `lift F Y` to be `lift F X`
            -- and `hom_to_lift F Y` to be `hom_to_lift F X ≫ f`.
            apply
              induction F fun Z k =>
                (c.π.app Z ≫ G.map k : c.X ⟶ _) =
                  c.π.app (lift F X) ≫ G.map (hom_to_lift F X) ≫ G.map f
            · intro Z₁ Z₂ k₁ k₂ g a z
              rw [← a, functor.map_comp, ← functor.comp_map, ← category.assoc, ← category.assoc,
                c.w] at z 
              rw [z, category.assoc]
            · intro Z₁ Z₂ k₁ k₂ g a z
              rw [← a, functor.map_comp, ← functor.comp_map, ← category.assoc, ← category.assoc,
                c.w, z, category.assoc]
            · rw [← functor.map_comp] } }
  map X Y f := { Hom := f.Hom }
#align category_theory.functor.initial.extend_cone CategoryTheory.Functor.Initial.extendCone
-/

#print CategoryTheory.Functor.Initial.limit_cone_comp_aux /-
@[simp]
theorem limit_cone_comp_aux (s : Cone (F ⋙ G)) (j : C) :
    s.π.app (lift F (F.obj j)) ≫ G.map (homToLift F (F.obj j)) = s.π.app j :=
  by
  -- This point is that this would be true if we took `lift (F.obj j)` to just be `j`
  -- and `hom_to_lift (F.obj j)` to be `𝟙 (F.obj j)`.
  apply induction F fun X k => s.π.app X ≫ G.map k = (s.π.app j : _)
  · intro j₁ j₂ k₁ k₂ f w h; rw [← s.w f]; rw [← w] at h ; simpa using h
  · intro j₁ j₂ k₁ k₂ f w h; rw [← s.w f] at h ; rw [← w]; simpa using h
  · exact s.w (𝟙 _)
#align category_theory.functor.initial.limit_cone_comp_aux CategoryTheory.Functor.Initial.limit_cone_comp_aux
-/

variable (F G)

#print CategoryTheory.Functor.Initial.conesEquiv /-
/-- If `F` is initial,
the category of cones on `F ⋙ G` is equivalent to the category of cones on `G`,
for any `G : D ⥤ E`.
-/
@[simps]
def conesEquiv : Cone (F ⋙ G) ≌ Cone G
    where
  Functor := extendCone
  inverse := Cones.whiskering F
  unitIso := NatIso.ofComponents (fun c => Cones.ext (Iso.refl _) (by tidy)) (by tidy)
  counitIso := NatIso.ofComponents (fun c => Cones.ext (Iso.refl _) (by tidy)) (by tidy)
#align category_theory.functor.initial.cones_equiv CategoryTheory.Functor.Initial.conesEquiv
-/

variable {G}

#print CategoryTheory.Functor.Initial.isLimitWhiskerEquiv /-
/-- When `F : C ⥤ D` is initial, and `t : cone G` for some `G : D ⥤ E`,
`t.whisker F` is a limit cone exactly when `t` is.
-/
def isLimitWhiskerEquiv (t : Cone G) : IsLimit (t.whisker F) ≃ IsLimit t :=
  IsLimit.ofConeEquiv (conesEquiv F G).symm
#align category_theory.functor.initial.is_limit_whisker_equiv CategoryTheory.Functor.Initial.isLimitWhiskerEquiv
-/

#print CategoryTheory.Functor.Initial.isLimitExtendConeEquiv /-
/-- When `F` is initial, and `t : cone (F ⋙ G)`,
`extend_cone.obj t` is a limit cone exactly when `t` is.
-/
def isLimitExtendConeEquiv (t : Cone (F ⋙ G)) : IsLimit (extendCone.obj t) ≃ IsLimit t :=
  IsLimit.ofConeEquiv (conesEquiv F G)
#align category_theory.functor.initial.is_limit_extend_cone_equiv CategoryTheory.Functor.Initial.isLimitExtendConeEquiv
-/

#print CategoryTheory.Functor.Initial.limitConeComp /-
/-- Given a limit cone over `G : D ⥤ E` we can construct a limit cone over `F ⋙ G`. -/
@[simps]
def limitConeComp (t : LimitCone G) : LimitCone (F ⋙ G)
    where
  Cone := _
  IsLimit := (isLimitWhiskerEquiv F _).symm t.IsLimit
#align category_theory.functor.initial.limit_cone_comp CategoryTheory.Functor.Initial.limitConeComp
-/

#print CategoryTheory.Functor.Initial.comp_hasLimit /-
instance (priority := 100) comp_hasLimit [HasLimit G] : HasLimit (F ⋙ G) :=
  HasLimit.mk (limitConeComp F (getLimitCone G))
#align category_theory.functor.initial.comp_has_limit CategoryTheory.Functor.Initial.comp_hasLimit
-/

#print CategoryTheory.Functor.Initial.limit_pre_is_iso_aux /-
theorem limit_pre_is_iso_aux {t : Cone G} (P : IsLimit t) :
    ((isLimitWhiskerEquiv F _).symm P).lift (t.whisker F) = 𝟙 t.pt :=
  by
  dsimp [is_limit_whisker_equiv]
  apply P.hom_ext
  intro j
  simp
#align category_theory.functor.initial.limit_pre_is_iso_aux CategoryTheory.Functor.Initial.limit_pre_is_iso_aux
-/

#print CategoryTheory.Functor.Initial.limit_pre_isIso /-
instance limit_pre_isIso [HasLimit G] : IsIso (limit.pre G F) :=
  by
  rw [limit.pre_eq (limit_cone_comp F (get_limit_cone G)) (get_limit_cone G)]
  erw [limit_pre_is_iso_aux]
  dsimp
  infer_instance
#align category_theory.functor.initial.limit_pre_is_iso CategoryTheory.Functor.Initial.limit_pre_isIso
-/

section

variable (G)

#print CategoryTheory.Functor.Initial.limitIso /-
/-- When `F : C ⥤ D` is initial, and `G : D ⥤ E` has a limit, then `F ⋙ G` has a limit also and
`limit (F ⋙ G) ≅ limit G`

https://stacks.math.columbia.edu/tag/04E7
-/
def limitIso [HasLimit G] : limit (F ⋙ G) ≅ limit G :=
  (asIso (limit.pre G F)).symm
#align category_theory.functor.initial.limit_iso CategoryTheory.Functor.Initial.limitIso
-/

end

#print CategoryTheory.Functor.Initial.limitConeOfComp /-
/-- Given a limit cone over `F ⋙ G` we can construct a limit cone over `G`. -/
@[simps]
def limitConeOfComp (t : LimitCone (F ⋙ G)) : LimitCone G
    where
  Cone := extendCone.obj t.Cone
  IsLimit := (isLimitExtendConeEquiv F _).symm t.IsLimit
#align category_theory.functor.initial.limit_cone_of_comp CategoryTheory.Functor.Initial.limitConeOfComp
-/

#print CategoryTheory.Functor.Initial.hasLimit_of_comp /-
/-- When `F` is initial, and `F ⋙ G` has a limit, then `G` has a limit also.

We can't make this an instance, because `F` is not determined by the goal.
(Even if this weren't a problem, it would cause a loop with `comp_has_limit`.)
-/
theorem hasLimit_of_comp [HasLimit (F ⋙ G)] : HasLimit G :=
  HasLimit.mk (limitConeOfComp F (getLimitCone (F ⋙ G)))
#align category_theory.functor.initial.has_limit_of_comp CategoryTheory.Functor.Initial.hasLimit_of_comp
-/

section

attribute [local instance] has_limit_of_comp

#print CategoryTheory.Functor.Initial.limitIso' /-
/-- When `F` is initial, and `F ⋙ G` has a limit, then `G` has a limit also and
`limit (F ⋙ G) ≅ limit G`

https://stacks.math.columbia.edu/tag/04E7
-/
def limitIso' [HasLimit (F ⋙ G)] : limit (F ⋙ G) ≅ limit G :=
  (asIso (limit.pre G F)).symm
#align category_theory.functor.initial.limit_iso' CategoryTheory.Functor.Initial.limitIso'
-/

end

end Initial

end Functor

end CategoryTheory

