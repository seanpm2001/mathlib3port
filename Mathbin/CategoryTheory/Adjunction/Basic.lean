/-
Copyright (c) 2019 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Reid Barton, Johan Commelin, Bhavik Mehta

! This file was ported from Lean 3 source module category_theory.adjunction.basic
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Equivalence

/-!
# Adjunctions between functors

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

`F ⊣ G` represents the data of an adjunction between two functors
`F : C ⥤ D` and `G : D ⥤ C`. `F` is the left adjoint and `G` is the right adjoint.

We provide various useful constructors:
* `mk_of_hom_equiv`
* `mk_of_unit_counit`
* `left_adjoint_of_equiv` / `right_adjoint_of equiv`
  construct a left/right adjoint of a given functor given the action on objects and
  the relevant equivalence of morphism spaces.
* `adjunction_of_equiv_left` / `adjunction_of_equiv_right` witness that these constructions
  give adjunctions.

There are also typeclasses `is_left_adjoint` / `is_right_adjoint`, carrying data witnessing
that a given functor is a left or right adjoint.
Given `[is_left_adjoint F]`, a right adjoint of `F` can be constructed as `right_adjoint F`.

`adjunction.comp` composes adjunctions.

`to_equivalence` upgrades an adjunction to an equivalence,
given witnesses that the unit and counit are pointwise isomorphisms.
Conversely `equivalence.to_adjunction` recovers the underlying adjunction from an equivalence.
-/


namespace CategoryTheory

open Category

-- declare the `v`'s first; see `category_theory.category` for an explanation
universe v₁ v₂ v₃ u₁ u₂ u₃

attribute [local elab_without_expected_type] whisker_left whisker_right

variable {C : Type u₁} [Category.{v₁} C] {D : Type u₂} [Category.{v₂} D]

#print CategoryTheory.Adjunction /-
/-- `F ⊣ G` represents the data of an adjunction between two functors
`F : C ⥤ D` and `G : D ⥤ C`. `F` is the left adjoint and `G` is the right adjoint.

To construct an `adjunction` between two functors, it's often easier to instead use the
constructors `mk_of_hom_equiv` or `mk_of_unit_counit`. To construct a left adjoint,
there are also constructors `left_adjoint_of_equiv` and `adjunction_of_equiv_left` (as
well as their duals) which can be simpler in practice.

Uniqueness of adjoints is shown in `category_theory.adjunction.opposites`.

See <https://stacks.math.columbia.edu/tag/0037>.
-/
structure Adjunction (F : C ⥤ D) (G : D ⥤ C) where
  homEquiv : ∀ X Y, (F.obj X ⟶ Y) ≃ (X ⟶ G.obj Y)
  Unit : 𝟭 C ⟶ F.comp G
  counit : G.comp F ⟶ 𝟭 D
  homEquiv_unit : ∀ {X Y f}, (hom_equiv X Y) f = (Unit : _ ⟶ _).app X ≫ G.map f := by obviously
  homEquiv_counit : ∀ {X Y g}, (hom_equiv X Y).symm g = F.map g ≫ counit.app Y := by obviously
#align category_theory.adjunction CategoryTheory.Adjunction
-/

infixl:15 " ⊣ " => Adjunction

#print CategoryTheory.IsLeftAdjoint /-
/-- A class giving a chosen right adjoint to the functor `left`. -/
class IsLeftAdjoint (left : C ⥤ D) where
  right : D ⥤ C
  adj : left ⊣ right
#align category_theory.is_left_adjoint CategoryTheory.IsLeftAdjoint
-/

#print CategoryTheory.IsRightAdjoint /-
/-- A class giving a chosen left adjoint to the functor `right`. -/
class IsRightAdjoint (right : D ⥤ C) where
  left : C ⥤ D
  adj : left ⊣ right
#align category_theory.is_right_adjoint CategoryTheory.IsRightAdjoint
-/

#print CategoryTheory.leftAdjoint /-
/-- Extract the left adjoint from the instance giving the chosen adjoint. -/
def leftAdjoint (R : D ⥤ C) [IsRightAdjoint R] : C ⥤ D :=
  IsRightAdjoint.left R
#align category_theory.left_adjoint CategoryTheory.leftAdjoint
-/

#print CategoryTheory.rightAdjoint /-
/-- Extract the right adjoint from the instance giving the chosen adjoint. -/
def rightAdjoint (L : C ⥤ D) [IsLeftAdjoint L] : D ⥤ C :=
  IsLeftAdjoint.right L
#align category_theory.right_adjoint CategoryTheory.rightAdjoint
-/

#print CategoryTheory.Adjunction.ofLeftAdjoint /-
/-- The adjunction associated to a functor known to be a left adjoint. -/
def Adjunction.ofLeftAdjoint (left : C ⥤ D) [IsLeftAdjoint left] :
    Adjunction left (rightAdjoint left) :=
  IsLeftAdjoint.adj
#align category_theory.adjunction.of_left_adjoint CategoryTheory.Adjunction.ofLeftAdjoint
-/

#print CategoryTheory.Adjunction.ofRightAdjoint /-
/-- The adjunction associated to a functor known to be a right adjoint. -/
def Adjunction.ofRightAdjoint (right : C ⥤ D) [IsRightAdjoint right] :
    Adjunction (leftAdjoint right) right :=
  IsRightAdjoint.adj
#align category_theory.adjunction.of_right_adjoint CategoryTheory.Adjunction.ofRightAdjoint
-/

namespace Adjunction

restate_axiom hom_equiv_unit'

restate_axiom hom_equiv_counit'

attribute [simp] hom_equiv_unit hom_equiv_counit

section

variable {F : C ⥤ D} {G : D ⥤ C} (adj : F ⊣ G) {X' X : C} {Y Y' : D}

#print CategoryTheory.Adjunction.homEquiv_id /-
theorem homEquiv_id (X : C) : adj.homEquiv X _ (𝟙 _) = adj.Unit.app X := by simp
#align category_theory.adjunction.hom_equiv_id CategoryTheory.Adjunction.homEquiv_id
-/

#print CategoryTheory.Adjunction.homEquiv_symm_id /-
theorem homEquiv_symm_id (X : D) : (adj.homEquiv _ X).symm (𝟙 _) = adj.counit.app X := by simp
#align category_theory.adjunction.hom_equiv_symm_id CategoryTheory.Adjunction.homEquiv_symm_id
-/

#print CategoryTheory.Adjunction.homEquiv_naturality_left_symm /-
@[simp]
theorem homEquiv_naturality_left_symm (f : X' ⟶ X) (g : X ⟶ G.obj Y) :
    (adj.homEquiv X' Y).symm (f ≫ g) = F.map f ≫ (adj.homEquiv X Y).symm g := by
  rw [hom_equiv_counit, F.map_comp, assoc, adj.hom_equiv_counit.symm]
#align category_theory.adjunction.hom_equiv_naturality_left_symm CategoryTheory.Adjunction.homEquiv_naturality_left_symm
-/

#print CategoryTheory.Adjunction.homEquiv_naturality_left /-
@[simp]
theorem homEquiv_naturality_left (f : X' ⟶ X) (g : F.obj X ⟶ Y) :
    (adj.homEquiv X' Y) (F.map f ≫ g) = f ≫ (adj.homEquiv X Y) g := by
  rw [← Equiv.eq_symm_apply] <;> simp [-hom_equiv_unit]
#align category_theory.adjunction.hom_equiv_naturality_left CategoryTheory.Adjunction.homEquiv_naturality_left
-/

#print CategoryTheory.Adjunction.homEquiv_naturality_right /-
@[simp]
theorem homEquiv_naturality_right (f : F.obj X ⟶ Y) (g : Y ⟶ Y') :
    (adj.homEquiv X Y') (f ≫ g) = (adj.homEquiv X Y) f ≫ G.map g := by
  rw [hom_equiv_unit, G.map_comp, ← assoc, ← hom_equiv_unit]
#align category_theory.adjunction.hom_equiv_naturality_right CategoryTheory.Adjunction.homEquiv_naturality_right
-/

#print CategoryTheory.Adjunction.homEquiv_naturality_right_symm /-
@[simp]
theorem homEquiv_naturality_right_symm (f : X ⟶ G.obj Y) (g : Y ⟶ Y') :
    (adj.homEquiv X Y').symm (f ≫ G.map g) = (adj.homEquiv X Y).symm f ≫ g := by
  rw [Equiv.symm_apply_eq] <;> simp [-hom_equiv_counit]
#align category_theory.adjunction.hom_equiv_naturality_right_symm CategoryTheory.Adjunction.homEquiv_naturality_right_symm
-/

#print CategoryTheory.Adjunction.left_triangle /-
@[simp]
theorem left_triangle : whiskerRight adj.Unit F ≫ whiskerLeft F adj.counit = NatTrans.id _ :=
  by
  ext; dsimp
  erw [← adj.hom_equiv_counit, Equiv.symm_apply_eq, adj.hom_equiv_unit]
  simp
#align category_theory.adjunction.left_triangle CategoryTheory.Adjunction.left_triangle
-/

#print CategoryTheory.Adjunction.right_triangle /-
@[simp]
theorem right_triangle : whiskerLeft G adj.Unit ≫ whiskerRight adj.counit G = NatTrans.id _ :=
  by
  ext; dsimp
  erw [← adj.hom_equiv_unit, ← Equiv.eq_symm_apply, adj.hom_equiv_counit]
  simp
#align category_theory.adjunction.right_triangle CategoryTheory.Adjunction.right_triangle
-/

#print CategoryTheory.Adjunction.left_triangle_components /-
@[simp, reassoc]
theorem left_triangle_components :
    F.map (adj.Unit.app X) ≫ adj.counit.app (F.obj X) = 𝟙 (F.obj X) :=
  congr_arg (fun t : NatTrans _ (𝟭 C ⋙ F) => t.app X) adj.left_triangle
#align category_theory.adjunction.left_triangle_components CategoryTheory.Adjunction.left_triangle_components
-/

#print CategoryTheory.Adjunction.right_triangle_components /-
@[simp, reassoc]
theorem right_triangle_components {Y : D} :
    adj.Unit.app (G.obj Y) ≫ G.map (adj.counit.app Y) = 𝟙 (G.obj Y) :=
  congr_arg (fun t : NatTrans _ (G ⋙ 𝟭 C) => t.app Y) adj.right_triangle
#align category_theory.adjunction.right_triangle_components CategoryTheory.Adjunction.right_triangle_components
-/

#print CategoryTheory.Adjunction.counit_naturality /-
@[simp, reassoc]
theorem counit_naturality {X Y : D} (f : X ⟶ Y) :
    F.map (G.map f) ≫ adj.counit.app Y = adj.counit.app X ≫ f :=
  adj.counit.naturality f
#align category_theory.adjunction.counit_naturality CategoryTheory.Adjunction.counit_naturality
-/

#print CategoryTheory.Adjunction.unit_naturality /-
@[simp, reassoc]
theorem unit_naturality {X Y : C} (f : X ⟶ Y) :
    adj.Unit.app X ≫ G.map (F.map f) = f ≫ adj.Unit.app Y :=
  (adj.Unit.naturality f).symm
#align category_theory.adjunction.unit_naturality CategoryTheory.Adjunction.unit_naturality
-/

#print CategoryTheory.Adjunction.homEquiv_apply_eq /-
theorem homEquiv_apply_eq {A : C} {B : D} (f : F.obj A ⟶ B) (g : A ⟶ G.obj B) :
    adj.homEquiv A B f = g ↔ f = (adj.homEquiv A B).symm g :=
  ⟨fun h => by cases h; simp, fun h => by cases h; simp⟩
#align category_theory.adjunction.hom_equiv_apply_eq CategoryTheory.Adjunction.homEquiv_apply_eq
-/

#print CategoryTheory.Adjunction.eq_homEquiv_apply /-
theorem eq_homEquiv_apply {A : C} {B : D} (f : F.obj A ⟶ B) (g : A ⟶ G.obj B) :
    g = adj.homEquiv A B f ↔ (adj.homEquiv A B).symm g = f :=
  ⟨fun h => by cases h; simp, fun h => by cases h; simp⟩
#align category_theory.adjunction.eq_hom_equiv_apply CategoryTheory.Adjunction.eq_homEquiv_apply
-/

end

end Adjunction

namespace Adjunction

#print CategoryTheory.Adjunction.CoreHomEquiv /-
/-- This is an auxiliary data structure useful for constructing adjunctions.
See `adjunction.mk_of_hom_equiv`.
This structure won't typically be used anywhere else.
-/
@[nolint has_nonempty_instance]
structure CoreHomEquiv (F : C ⥤ D) (G : D ⥤ C) where
  homEquiv : ∀ X Y, (F.obj X ⟶ Y) ≃ (X ⟶ G.obj Y)
  homEquiv_naturality_left_symm :
    ∀ {X' X Y} (f : X' ⟶ X) (g : X ⟶ G.obj Y),
      (hom_equiv X' Y).symm (f ≫ g) = F.map f ≫ (hom_equiv X Y).symm g := by
    obviously
  homEquiv_naturality_right :
    ∀ {X Y Y'} (f : F.obj X ⟶ Y) (g : Y ⟶ Y'),
      (hom_equiv X Y') (f ≫ g) = (hom_equiv X Y) f ≫ G.map g := by
    obviously
#align category_theory.adjunction.core_hom_equiv CategoryTheory.Adjunction.CoreHomEquiv
-/

namespace CoreHomEquiv

restate_axiom hom_equiv_naturality_left_symm'

restate_axiom hom_equiv_naturality_right'

attribute [simp] hom_equiv_naturality_left_symm hom_equiv_naturality_right

variable {F : C ⥤ D} {G : D ⥤ C} (adj : CoreHomEquiv F G) {X' X : C} {Y Y' : D}

#print CategoryTheory.Adjunction.CoreHomEquiv.homEquiv_naturality_left /-
@[simp]
theorem homEquiv_naturality_left (f : X' ⟶ X) (g : F.obj X ⟶ Y) :
    (adj.homEquiv X' Y) (F.map f ≫ g) = f ≫ (adj.homEquiv X Y) g := by
  rw [← Equiv.eq_symm_apply] <;> simp
#align category_theory.adjunction.core_hom_equiv.hom_equiv_naturality_left CategoryTheory.Adjunction.CoreHomEquiv.homEquiv_naturality_left
-/

#print CategoryTheory.Adjunction.CoreHomEquiv.homEquiv_naturality_right_symm /-
@[simp]
theorem homEquiv_naturality_right_symm (f : X ⟶ G.obj Y) (g : Y ⟶ Y') :
    (adj.homEquiv X Y').symm (f ≫ G.map g) = (adj.homEquiv X Y).symm f ≫ g := by
  rw [Equiv.symm_apply_eq] <;> simp
#align category_theory.adjunction.core_hom_equiv.hom_equiv_naturality_right_symm CategoryTheory.Adjunction.CoreHomEquiv.homEquiv_naturality_right_symm
-/

end CoreHomEquiv

#print CategoryTheory.Adjunction.CoreUnitCounit /-
/-- This is an auxiliary data structure useful for constructing adjunctions.
See `adjunction.mk_of_unit_counit`.
This structure won't typically be used anywhere else.
-/
@[nolint has_nonempty_instance]
structure CoreUnitCounit (F : C ⥤ D) (G : D ⥤ C) where
  Unit : 𝟭 C ⟶ F.comp G
  counit : G.comp F ⟶ 𝟭 D
  left_triangle :
    whiskerRight Unit F ≫ (Functor.associator F G F).Hom ≫ whiskerLeft F counit =
      NatTrans.id (𝟭 C ⋙ F) := by
    obviously
  right_triangle :
    whiskerLeft G Unit ≫ (Functor.associator G F G).inv ≫ whiskerRight counit G =
      NatTrans.id (G ⋙ 𝟭 C) := by
    obviously
#align category_theory.adjunction.core_unit_counit CategoryTheory.Adjunction.CoreUnitCounit
-/

namespace CoreUnitCounit

restate_axiom left_triangle'

restate_axiom right_triangle'

attribute [simp] left_triangle right_triangle

end CoreUnitCounit

variable {F : C ⥤ D} {G : D ⥤ C}

#print CategoryTheory.Adjunction.mkOfHomEquiv /-
/-- Construct an adjunction between `F` and `G` out of a natural bijection between each
`F.obj X ⟶ Y` and `X ⟶ G.obj Y`. -/
@[simps]
def mkOfHomEquiv (adj : CoreHomEquiv F G) : F ⊣ G :=
  {-- See note [dsimp, simp].
    adj with
    Unit :=
      { app := fun X => (adj.homEquiv X (F.obj X)) (𝟙 (F.obj X))
        naturality' := by
          intros
          erw [← adj.hom_equiv_naturality_left, ← adj.hom_equiv_naturality_right]
          dsimp; simp }
    counit :=
      { app := fun Y => (adj.homEquiv _ _).invFun (𝟙 (G.obj Y))
        naturality' := by
          intros
          erw [← adj.hom_equiv_naturality_left_symm, ← adj.hom_equiv_naturality_right_symm]
          dsimp; simp }
    homEquiv_unit := fun X Y f => by erw [← adj.hom_equiv_naturality_right] <;> simp
    homEquiv_counit := fun X Y f => by erw [← adj.hom_equiv_naturality_left_symm] <;> simp }
#align category_theory.adjunction.mk_of_hom_equiv CategoryTheory.Adjunction.mkOfHomEquiv
-/

#print CategoryTheory.Adjunction.mkOfUnitCounit /-
/-- Construct an adjunction between functors `F` and `G` given a unit and counit for the adjunction
satisfying the triangle identities. -/
@[simps]
def mkOfUnitCounit (adj : CoreUnitCounit F G) : F ⊣ G :=
  { adj with
    homEquiv := fun X Y =>
      { toFun := fun f => adj.Unit.app X ≫ G.map f
        invFun := fun g => F.map g ≫ adj.counit.app Y
        left_inv := fun f => by
          change F.map (_ ≫ _) ≫ _ = _
          rw [F.map_comp, assoc, ← functor.comp_map, adj.counit.naturality, ← assoc]
          convert id_comp f
          have t := congr_arg (fun t : nat_trans _ _ => t.app _) adj.left_triangle
          dsimp at t 
          simp only [id_comp] at t 
          exact t
        right_inv := fun g => by
          change _ ≫ G.map (_ ≫ _) = _
          rw [G.map_comp, ← assoc, ← functor.comp_map, ← adj.unit.naturality, assoc]
          convert comp_id g
          have t := congr_arg (fun t : nat_trans _ _ => t.app _) adj.right_triangle
          dsimp at t 
          simp only [id_comp] at t 
          exact t } }
#align category_theory.adjunction.mk_of_unit_counit CategoryTheory.Adjunction.mkOfUnitCounit
-/

#print CategoryTheory.Adjunction.id /-
/-- The adjunction between the identity functor on a category and itself. -/
def id : 𝟭 C ⊣ 𝟭 C where
  homEquiv X Y := Equiv.refl _
  Unit := 𝟙 _
  counit := 𝟙 _
#align category_theory.adjunction.id CategoryTheory.Adjunction.id
-/

-- Satisfy the inhabited linter.
instance : Inhabited (Adjunction (𝟭 C) (𝟭 C)) :=
  ⟨id⟩

#print CategoryTheory.Adjunction.equivHomsetLeftOfNatIso /-
/-- If F and G are naturally isomorphic functors, establish an equivalence of hom-sets. -/
@[simps]
def equivHomsetLeftOfNatIso {F F' : C ⥤ D} (iso : F ≅ F') {X : C} {Y : D} :
    (F.obj X ⟶ Y) ≃ (F'.obj X ⟶ Y)
    where
  toFun f := iso.inv.app _ ≫ f
  invFun g := iso.Hom.app _ ≫ g
  left_inv f := by simp
  right_inv g := by simp
#align category_theory.adjunction.equiv_homset_left_of_nat_iso CategoryTheory.Adjunction.equivHomsetLeftOfNatIso
-/

#print CategoryTheory.Adjunction.equivHomsetRightOfNatIso /-
/-- If G and H are naturally isomorphic functors, establish an equivalence of hom-sets. -/
@[simps]
def equivHomsetRightOfNatIso {G G' : D ⥤ C} (iso : G ≅ G') {X : C} {Y : D} :
    (X ⟶ G.obj Y) ≃ (X ⟶ G'.obj Y)
    where
  toFun f := f ≫ iso.Hom.app _
  invFun g := g ≫ iso.inv.app _
  left_inv f := by simp
  right_inv g := by simp
#align category_theory.adjunction.equiv_homset_right_of_nat_iso CategoryTheory.Adjunction.equivHomsetRightOfNatIso
-/

#print CategoryTheory.Adjunction.ofNatIsoLeft /-
/-- Transport an adjunction along an natural isomorphism on the left. -/
def ofNatIsoLeft {F G : C ⥤ D} {H : D ⥤ C} (adj : F ⊣ H) (iso : F ≅ G) : G ⊣ H :=
  Adjunction.mkOfHomEquiv
    { homEquiv := fun X Y => (equivHomsetLeftOfNatIso iso.symm).trans (adj.homEquiv X Y) }
#align category_theory.adjunction.of_nat_iso_left CategoryTheory.Adjunction.ofNatIsoLeft
-/

#print CategoryTheory.Adjunction.ofNatIsoRight /-
/-- Transport an adjunction along an natural isomorphism on the right. -/
def ofNatIsoRight {F : C ⥤ D} {G H : D ⥤ C} (adj : F ⊣ G) (iso : G ≅ H) : F ⊣ H :=
  Adjunction.mkOfHomEquiv
    { homEquiv := fun X Y => (adj.homEquiv X Y).trans (equivHomsetRightOfNatIso iso) }
#align category_theory.adjunction.of_nat_iso_right CategoryTheory.Adjunction.ofNatIsoRight
-/

#print CategoryTheory.Adjunction.rightAdjointOfNatIso /-
/-- Transport being a right adjoint along a natural isomorphism. -/
def rightAdjointOfNatIso {F G : C ⥤ D} (h : F ≅ G) [r : IsRightAdjoint F] : IsRightAdjoint G
    where
  left := r.left
  adj := ofNatIsoRight r.adj h
#align category_theory.adjunction.right_adjoint_of_nat_iso CategoryTheory.Adjunction.rightAdjointOfNatIso
-/

#print CategoryTheory.Adjunction.leftAdjointOfNatIso /-
/-- Transport being a left adjoint along a natural isomorphism. -/
def leftAdjointOfNatIso {F G : C ⥤ D} (h : F ≅ G) [r : IsLeftAdjoint F] : IsLeftAdjoint G
    where
  right := r.right
  adj := ofNatIsoLeft r.adj h
#align category_theory.adjunction.left_adjoint_of_nat_iso CategoryTheory.Adjunction.leftAdjointOfNatIso
-/

section

variable {E : Type u₃} [ℰ : Category.{v₃} E] {H : D ⥤ E} {I : E ⥤ D}

#print CategoryTheory.Adjunction.comp /-
/-- Composition of adjunctions.

See <https://stacks.math.columbia.edu/tag/0DV0>.
-/
def comp (adj₁ : F ⊣ G) (adj₂ : H ⊣ I) : F ⋙ H ⊣ I ⋙ G
    where
  homEquiv X Z := Equiv.trans (adj₂.homEquiv _ _) (adj₁.homEquiv _ _)
  Unit := adj₁.Unit ≫ (whiskerLeft F <| whiskerRight adj₂.Unit G) ≫ (Functor.associator _ _ _).inv
  counit :=
    (Functor.associator _ _ _).Hom ≫ (whiskerLeft I <| whiskerRight adj₁.counit H) ≫ adj₂.counit
#align category_theory.adjunction.comp CategoryTheory.Adjunction.comp
-/

#print CategoryTheory.Adjunction.leftAdjointOfComp /-
/-- If `F` and `G` are left adjoints then `F ⋙ G` is a left adjoint too. -/
instance leftAdjointOfComp {E : Type u₃} [ℰ : Category.{v₃} E] (F : C ⥤ D) (G : D ⥤ E)
    [Fl : IsLeftAdjoint F] [Gl : IsLeftAdjoint G] : IsLeftAdjoint (F ⋙ G)
    where
  right := Gl.right ⋙ Fl.right
  adj := Fl.adj.comp Gl.adj
#align category_theory.adjunction.left_adjoint_of_comp CategoryTheory.Adjunction.leftAdjointOfComp
-/

#print CategoryTheory.Adjunction.rightAdjointOfComp /-
/-- If `F` and `G` are right adjoints then `F ⋙ G` is a right adjoint too. -/
instance rightAdjointOfComp {E : Type u₃} [ℰ : Category.{v₃} E] {F : C ⥤ D} {G : D ⥤ E}
    [Fr : IsRightAdjoint F] [Gr : IsRightAdjoint G] : IsRightAdjoint (F ⋙ G)
    where
  left := Gr.left ⋙ Fr.left
  adj := Gr.adj.comp Fr.adj
#align category_theory.adjunction.right_adjoint_of_comp CategoryTheory.Adjunction.rightAdjointOfComp
-/

end

section ConstructLeft

-- Construction of a left adjoint. In order to construct a left
-- adjoint to a functor G : D → C, it suffices to give the object part
-- of a functor F : C → D together with isomorphisms Hom(FX, Y) ≃
-- Hom(X, GY) natural in Y. The action of F on morphisms can be
-- constructed from this data.
variable {F_obj : C → D} {G}

variable (e : ∀ X Y, (F_obj X ⟶ Y) ≃ (X ⟶ G.obj Y))

variable (he : ∀ X Y Y' g h, e X Y' (h ≫ g) = e X Y h ≫ G.map g)

private theorem he' {X Y Y'} (f g) : (e X Y').symm (f ≫ G.map g) = (e X Y).symm f ≫ g := by
  intros <;> rw [Equiv.symm_apply_eq, he] <;> simp

#print CategoryTheory.Adjunction.leftAdjointOfEquiv /-
/-- Construct a left adjoint functor to `G`, given the functor's value on objects `F_obj` and
a bijection `e` between `F_obj X ⟶ Y` and `X ⟶ G.obj Y` satisfying a naturality law
`he : ∀ X Y Y' g h, e X Y' (h ≫ g) = e X Y h ≫ G.map g`.
Dual to `right_adjoint_of_equiv`. -/
@[simps]
def leftAdjointOfEquiv : C ⥤ D where
  obj := F_obj
  map X X' f := (e X (F_obj X')).symm (f ≫ e X' (F_obj X') (𝟙 _))
  map_comp' X X' X'' f f' :=
    by
    rw [Equiv.symm_apply_eq, he, Equiv.apply_symm_apply]
    conv =>
      rhs
      rw [assoc, ← he, id_comp, Equiv.apply_symm_apply]
    simp
#align category_theory.adjunction.left_adjoint_of_equiv CategoryTheory.Adjunction.leftAdjointOfEquiv
-/

#print CategoryTheory.Adjunction.adjunctionOfEquivLeft /-
/-- Show that the functor given by `left_adjoint_of_equiv` is indeed left adjoint to `G`. Dual
to `adjunction_of_equiv_right`. -/
@[simps]
def adjunctionOfEquivLeft : leftAdjointOfEquiv e he ⊣ G :=
  mkOfHomEquiv
    { homEquiv := e
      homEquiv_naturality_left_symm := by
        intros
        erw [← he' e he, ← Equiv.apply_eq_iff_eq]
        simp [(he _ _ _ _ _).symm] }
#align category_theory.adjunction.adjunction_of_equiv_left CategoryTheory.Adjunction.adjunctionOfEquivLeft
-/

end ConstructLeft

section ConstructRight

-- Construction of a right adjoint, analogous to the above.
variable {F} {G_obj : D → C}

variable (e : ∀ X Y, (F.obj X ⟶ Y) ≃ (X ⟶ G_obj Y))

variable (he : ∀ X' X Y f g, e X' Y (F.map f ≫ g) = f ≫ e X Y g)

private theorem he' {X' X Y} (f g) : F.map f ≫ (e X Y).symm g = (e X' Y).symm (f ≫ g) := by
  intros <;> rw [Equiv.eq_symm_apply, he] <;> simp

#print CategoryTheory.Adjunction.rightAdjointOfEquiv /-
/-- Construct a right adjoint functor to `F`, given the functor's value on objects `G_obj` and
a bijection `e` between `F.obj X ⟶ Y` and `X ⟶ G_obj Y` satisfying a naturality law
`he : ∀ X Y Y' g h, e X' Y (F.map f ≫ g) = f ≫ e X Y g`.
Dual to `left_adjoint_of_equiv`. -/
@[simps]
def rightAdjointOfEquiv : D ⥤ C where
  obj := G_obj
  map Y Y' g := (e (G_obj Y) Y') ((e (G_obj Y) Y).symm (𝟙 _) ≫ g)
  map_comp' Y Y' Y'' g g' :=
    by
    rw [← Equiv.eq_symm_apply, ← he' e he, Equiv.symm_apply_apply]
    conv =>
      rhs
      rw [← assoc, he' e he, comp_id, Equiv.symm_apply_apply]
    simp
#align category_theory.adjunction.right_adjoint_of_equiv CategoryTheory.Adjunction.rightAdjointOfEquiv
-/

#print CategoryTheory.Adjunction.adjunctionOfEquivRight /-
/-- Show that the functor given by `right_adjoint_of_equiv` is indeed right adjoint to `F`. Dual
to `adjunction_of_equiv_left`. -/
@[simps]
def adjunctionOfEquivRight : F ⊣ rightAdjointOfEquiv e he :=
  mkOfHomEquiv
    { homEquiv := e
      homEquiv_naturality_left_symm := by intros <;> rw [Equiv.symm_apply_eq, he] <;> simp
      homEquiv_naturality_right := by
        intro X Y Y' g h
        erw [← he, Equiv.apply_eq_iff_eq, ← assoc, he' e he, comp_id, Equiv.symm_apply_apply] }
#align category_theory.adjunction.adjunction_of_equiv_right CategoryTheory.Adjunction.adjunctionOfEquivRight
-/

end ConstructRight

#print CategoryTheory.Adjunction.toEquivalence /-
/--
If the unit and counit of a given adjunction are (pointwise) isomorphisms, then we can upgrade the
adjunction to an equivalence.
-/
@[simps]
noncomputable def toEquivalence (adj : F ⊣ G) [∀ X, IsIso (adj.Unit.app X)]
    [∀ Y, IsIso (adj.counit.app Y)] : C ≌ D
    where
  Functor := F
  inverse := G
  unitIso := NatIso.ofComponents (fun X => asIso (adj.Unit.app X)) (by simp)
  counitIso := NatIso.ofComponents (fun Y => asIso (adj.counit.app Y)) (by simp)
#align category_theory.adjunction.to_equivalence CategoryTheory.Adjunction.toEquivalence
-/

#print CategoryTheory.Adjunction.isRightAdjointToIsEquivalence /-
/--
If the unit and counit for the adjunction corresponding to a right adjoint functor are (pointwise)
isomorphisms, then the functor is an equivalence of categories.
-/
@[simps]
noncomputable def isRightAdjointToIsEquivalence [IsRightAdjoint G]
    [∀ X, IsIso ((Adjunction.ofRightAdjoint G).Unit.app X)]
    [∀ Y, IsIso ((Adjunction.ofRightAdjoint G).counit.app Y)] : IsEquivalence G :=
  IsEquivalence.ofEquivalenceInverse (Adjunction.ofRightAdjoint G).toEquivalence
#align category_theory.adjunction.is_right_adjoint_to_is_equivalence CategoryTheory.Adjunction.isRightAdjointToIsEquivalence
-/

end Adjunction

open Adjunction

namespace Equivalence

#print CategoryTheory.Equivalence.toAdjunction /-
/-- The adjunction given by an equivalence of categories. (To obtain the opposite adjunction,
simply use `e.symm.to_adjunction`. -/
def toAdjunction (e : C ≌ D) : e.Functor ⊣ e.inverse :=
  mkOfUnitCounit
    ⟨e.Unit, e.counit, by ext; dsimp; simp only [id_comp]; exact e.functor_unit_comp _, by ext;
      dsimp; simp only [id_comp]; exact e.unit_inverse_comp _⟩
#align category_theory.equivalence.to_adjunction CategoryTheory.Equivalence.toAdjunction
-/

#print CategoryTheory.Equivalence.asEquivalence_toAdjunction_unit /-
@[simp]
theorem asEquivalence_toAdjunction_unit {e : C ≌ D} :
    e.Functor.asEquivalence.toAdjunction.Unit = e.Unit :=
  rfl
#align category_theory.equivalence.as_equivalence_to_adjunction_unit CategoryTheory.Equivalence.asEquivalence_toAdjunction_unit
-/

#print CategoryTheory.Equivalence.asEquivalence_toAdjunction_counit /-
@[simp]
theorem asEquivalence_toAdjunction_counit {e : C ≌ D} :
    e.Functor.asEquivalence.toAdjunction.counit = e.counit :=
  rfl
#align category_theory.equivalence.as_equivalence_to_adjunction_counit CategoryTheory.Equivalence.asEquivalence_toAdjunction_counit
-/

end Equivalence

namespace Functor

#print CategoryTheory.Functor.adjunction /-
/-- An equivalence `E` is left adjoint to its inverse. -/
def adjunction (E : C ⥤ D) [IsEquivalence E] : E ⊣ E.inv :=
  E.asEquivalence.toAdjunction
#align category_theory.functor.adjunction CategoryTheory.Functor.adjunction
-/

#print CategoryTheory.Functor.leftAdjointOfEquivalence /-
/-- If `F` is an equivalence, it's a left adjoint. -/
instance (priority := 10) leftAdjointOfEquivalence {F : C ⥤ D} [IsEquivalence F] : IsLeftAdjoint F
    where
  right := _
  adj := Functor.adjunction F
#align category_theory.functor.left_adjoint_of_equivalence CategoryTheory.Functor.leftAdjointOfEquivalence
-/

#print CategoryTheory.Functor.rightAdjoint_of_isEquivalence /-
@[simp]
theorem rightAdjoint_of_isEquivalence {F : C ⥤ D} [IsEquivalence F] : rightAdjoint F = inv F :=
  rfl
#align category_theory.functor.right_adjoint_of_is_equivalence CategoryTheory.Functor.rightAdjoint_of_isEquivalence
-/

#print CategoryTheory.Functor.rightAdjointOfEquivalence /-
/-- If `F` is an equivalence, it's a right adjoint. -/
instance (priority := 10) rightAdjointOfEquivalence {F : C ⥤ D} [IsEquivalence F] : IsRightAdjoint F
    where
  left := _
  adj := Functor.adjunction F.inv
#align category_theory.functor.right_adjoint_of_equivalence CategoryTheory.Functor.rightAdjointOfEquivalence
-/

#print CategoryTheory.Functor.leftAdjoint_of_isEquivalence /-
@[simp]
theorem leftAdjoint_of_isEquivalence {F : C ⥤ D} [IsEquivalence F] : leftAdjoint F = inv F :=
  rfl
#align category_theory.functor.left_adjoint_of_is_equivalence CategoryTheory.Functor.leftAdjoint_of_isEquivalence
-/

end Functor

end CategoryTheory

