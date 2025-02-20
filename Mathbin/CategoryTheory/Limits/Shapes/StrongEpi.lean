/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel

! This file was ported from Lean 3 source module category_theory.limits.shapes.strong_epi
! leanprover-community/mathlib commit 3dadefa3f544b1db6214777fe47910739b54c66a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Balanced
import Mathbin.CategoryTheory.LiftingProperties.Basic

/-!
# Strong epimorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we define strong epimorphisms. A strong epimorphism is an epimorphism `f`
which has the (unique) left lifting property with respect to monomorphisms. Similarly,
a strong monomorphisms in a monomorphism which has the (unique) right lifting property
with respect to epimorphisms.

## Main results

Besides the definition, we show that
* the composition of two strong epimorphisms is a strong epimorphism,
* if `f ≫ g` is a strong epimorphism, then so is `g`,
* if `f` is both a strong epimorphism and a monomorphism, then it is an isomorphism

We also define classes `strong_mono_category` and `strong_epi_category` for categories in which
every monomorphism or epimorphism is strong, and deduce that these categories are balanced.

## TODO

Show that the dual of a strong epimorphism is a strong monomorphism, and vice versa.

## References

* [F. Borceux, *Handbook of Categorical Algebra 1*][borceux-vol1]
-/


universe v u

namespace CategoryTheory

variable {C : Type u} [Category.{v} C]

variable {P Q : C}

#print CategoryTheory.StrongEpi /-
/-- A strong epimorphism `f` is an epimorphism which has the left lifting property
with respect to monomorphisms. -/
class StrongEpi (f : P ⟶ Q) : Prop where
  Epi : Epi f
  llp : ∀ ⦃X Y : C⦄ (z : X ⟶ Y) [Mono z], HasLiftingProperty f z
#align category_theory.strong_epi CategoryTheory.StrongEpi
-/

#print CategoryTheory.StrongEpi.mk' /-
theorem StrongEpi.mk' {f : P ⟶ Q} [Epi f]
    (hf :
      ∀ (X Y : C) (z : X ⟶ Y) (hz : Mono z) (u : P ⟶ X) (v : Q ⟶ Y) (sq : CommSq u f z v),
        sq.HasLift) :
    StrongEpi f :=
  { Epi := inferInstance
    llp := fun X Y z hz => ⟨fun u v sq => hf X Y z hz u v sq⟩ }
#align category_theory.strong_epi.mk' CategoryTheory.StrongEpi.mk'
-/

#print CategoryTheory.StrongMono /-
/-- A strong monomorphism `f` is a monomorphism which has the right lifting property
with respect to epimorphisms. -/
class StrongMono (f : P ⟶ Q) : Prop where
  Mono : Mono f
  rlp : ∀ ⦃X Y : C⦄ (z : X ⟶ Y) [Epi z], HasLiftingProperty z f
#align category_theory.strong_mono CategoryTheory.StrongMono
-/

#print CategoryTheory.StrongMono.mk' /-
theorem StrongMono.mk' {f : P ⟶ Q} [Mono f]
    (hf :
      ∀ (X Y : C) (z : X ⟶ Y) (hz : Epi z) (u : X ⟶ P) (v : Y ⟶ Q) (sq : CommSq u z f v),
        sq.HasLift) :
    StrongMono f :=
  { Mono := inferInstance
    rlp := fun X Y z hz => ⟨fun u v sq => hf X Y z hz u v sq⟩ }
#align category_theory.strong_mono.mk' CategoryTheory.StrongMono.mk'
-/

attribute [instance 100] strong_epi.llp

attribute [instance 100] strong_mono.rlp

#print CategoryTheory.epi_of_strongEpi /-
instance (priority := 100) epi_of_strongEpi (f : P ⟶ Q) [StrongEpi f] : Epi f :=
  StrongEpi.epi
#align category_theory.epi_of_strong_epi CategoryTheory.epi_of_strongEpi
-/

#print CategoryTheory.mono_of_strongMono /-
instance (priority := 100) mono_of_strongMono (f : P ⟶ Q) [StrongMono f] : Mono f :=
  StrongMono.mono
#align category_theory.mono_of_strong_mono CategoryTheory.mono_of_strongMono
-/

section

variable {R : C} (f : P ⟶ Q) (g : Q ⟶ R)

#print CategoryTheory.strongEpi_comp /-
/-- The composition of two strong epimorphisms is a strong epimorphism. -/
theorem strongEpi_comp [StrongEpi f] [StrongEpi g] : StrongEpi (f ≫ g) :=
  { Epi := epi_comp _ _
    llp := by intros; infer_instance }
#align category_theory.strong_epi_comp CategoryTheory.strongEpi_comp
-/

#print CategoryTheory.strongMono_comp /-
/-- The composition of two strong monomorphisms is a strong monomorphism. -/
theorem strongMono_comp [StrongMono f] [StrongMono g] : StrongMono (f ≫ g) :=
  { Mono := mono_comp _ _
    rlp := by intros; infer_instance }
#align category_theory.strong_mono_comp CategoryTheory.strongMono_comp
-/

#print CategoryTheory.strongEpi_of_strongEpi /-
/-- If `f ≫ g` is a strong epimorphism, then so is `g`. -/
theorem strongEpi_of_strongEpi [StrongEpi (f ≫ g)] : StrongEpi g :=
  { Epi := epi_of_epi f g
    llp := by
      intros
      constructor
      intro u v sq
      have h₀ : (f ≫ u) ≫ z = (f ≫ g) ≫ v := by simp only [category.assoc, sq.w]
      exact
        comm_sq.has_lift.mk'
          ⟨(comm_sq.mk h₀).lift, by
            simp only [← cancel_mono z, category.assoc, comm_sq.fac_right, sq.w], by simp⟩ }
#align category_theory.strong_epi_of_strong_epi CategoryTheory.strongEpi_of_strongEpi
-/

#print CategoryTheory.strongMono_of_strongMono /-
/-- If `f ≫ g` is a strong monomorphism, then so is `f`. -/
theorem strongMono_of_strongMono [StrongMono (f ≫ g)] : StrongMono f :=
  { Mono := mono_of_mono f g
    rlp := by
      intros
      constructor
      intro u v sq
      have h₀ : u ≫ f ≫ g = z ≫ v ≫ g := by rw [reassoc_of sq.w]
      exact comm_sq.has_lift.mk' ⟨(comm_sq.mk h₀).lift, by simp, by simp [← cancel_epi z, sq.w]⟩ }
#align category_theory.strong_mono_of_strong_mono CategoryTheory.strongMono_of_strongMono
-/

#print CategoryTheory.strongEpi_of_isIso /-
/-- An isomorphism is in particular a strong epimorphism. -/
instance (priority := 100) strongEpi_of_isIso [IsIso f] : StrongEpi f
    where
  Epi := by infer_instance
  llp X Y z hz := HasLiftingProperty.of_left_iso _ _
#align category_theory.strong_epi_of_is_iso CategoryTheory.strongEpi_of_isIso
-/

#print CategoryTheory.strongMono_of_isIso /-
/-- An isomorphism is in particular a strong monomorphism. -/
instance (priority := 100) strongMono_of_isIso [IsIso f] : StrongMono f
    where
  Mono := by infer_instance
  rlp X Y z hz := HasLiftingProperty.of_right_iso _ _
#align category_theory.strong_mono_of_is_iso CategoryTheory.strongMono_of_isIso
-/

#print CategoryTheory.StrongEpi.of_arrow_iso /-
theorem StrongEpi.of_arrow_iso {A B A' B' : C} {f : A ⟶ B} {g : A' ⟶ B'}
    (e : Arrow.mk f ≅ Arrow.mk g) [h : StrongEpi f] : StrongEpi g :=
  { Epi := by
      rw [arrow.iso_w' e]
      haveI := epi_comp f e.hom.right
      apply epi_comp
    llp := fun X Y z => by intro; apply has_lifting_property.of_arrow_iso_left e z }
#align category_theory.strong_epi.of_arrow_iso CategoryTheory.StrongEpi.of_arrow_iso
-/

#print CategoryTheory.StrongMono.of_arrow_iso /-
theorem StrongMono.of_arrow_iso {A B A' B' : C} {f : A ⟶ B} {g : A' ⟶ B'}
    (e : Arrow.mk f ≅ Arrow.mk g) [h : StrongMono f] : StrongMono g :=
  { Mono := by
      rw [arrow.iso_w' e]
      haveI := mono_comp f e.hom.right
      apply mono_comp
    rlp := fun X Y z => by intro; apply has_lifting_property.of_arrow_iso_right z e }
#align category_theory.strong_mono.of_arrow_iso CategoryTheory.StrongMono.of_arrow_iso
-/

#print CategoryTheory.StrongEpi.iff_of_arrow_iso /-
theorem StrongEpi.iff_of_arrow_iso {A B A' B' : C} {f : A ⟶ B} {g : A' ⟶ B'}
    (e : Arrow.mk f ≅ Arrow.mk g) : StrongEpi f ↔ StrongEpi g := by constructor <;> intro;
  exacts [strong_epi.of_arrow_iso e, strong_epi.of_arrow_iso e.symm]
#align category_theory.strong_epi.iff_of_arrow_iso CategoryTheory.StrongEpi.iff_of_arrow_iso
-/

#print CategoryTheory.StrongMono.iff_of_arrow_iso /-
theorem StrongMono.iff_of_arrow_iso {A B A' B' : C} {f : A ⟶ B} {g : A' ⟶ B'}
    (e : Arrow.mk f ≅ Arrow.mk g) : StrongMono f ↔ StrongMono g := by constructor <;> intro;
  exacts [strong_mono.of_arrow_iso e, strong_mono.of_arrow_iso e.symm]
#align category_theory.strong_mono.iff_of_arrow_iso CategoryTheory.StrongMono.iff_of_arrow_iso
-/

end

#print CategoryTheory.isIso_of_mono_of_strongEpi /-
/-- A strong epimorphism that is a monomorphism is an isomorphism. -/
theorem isIso_of_mono_of_strongEpi (f : P ⟶ Q) [Mono f] [StrongEpi f] : IsIso f :=
  ⟨⟨(CommSq.mk (show 𝟙 P ≫ f = f ≫ 𝟙 Q by simp)).lift, by tidy⟩⟩
#align category_theory.is_iso_of_mono_of_strong_epi CategoryTheory.isIso_of_mono_of_strongEpi
-/

#print CategoryTheory.isIso_of_epi_of_strongMono /-
/-- A strong monomorphism that is an epimorphism is an isomorphism. -/
theorem isIso_of_epi_of_strongMono (f : P ⟶ Q) [Epi f] [StrongMono f] : IsIso f :=
  ⟨⟨(CommSq.mk (show 𝟙 P ≫ f = f ≫ 𝟙 Q by simp)).lift, by tidy⟩⟩
#align category_theory.is_iso_of_epi_of_strong_mono CategoryTheory.isIso_of_epi_of_strongMono
-/

section

variable (C)

#print CategoryTheory.StrongEpiCategory /-
/-- A strong epi category is a category in which every epimorphism is strong. -/
class StrongEpiCategory : Prop where
  strongEpi_of_epi : ∀ {X Y : C} (f : X ⟶ Y) [Epi f], StrongEpi f
#align category_theory.strong_epi_category CategoryTheory.StrongEpiCategory
-/

#print CategoryTheory.StrongMonoCategory /-
/-- A strong mono category is a category in which every monomorphism is strong. -/
class StrongMonoCategory : Prop where
  strongMono_of_mono : ∀ {X Y : C} (f : X ⟶ Y) [Mono f], StrongMono f
#align category_theory.strong_mono_category CategoryTheory.StrongMonoCategory
-/

end

#print CategoryTheory.strongEpi_of_epi /-
theorem strongEpi_of_epi [StrongEpiCategory C] (f : P ⟶ Q) [Epi f] : StrongEpi f :=
  StrongEpiCategory.strongEpi_of_epi _
#align category_theory.strong_epi_of_epi CategoryTheory.strongEpi_of_epi
-/

#print CategoryTheory.strongMono_of_mono /-
theorem strongMono_of_mono [StrongMonoCategory C] (f : P ⟶ Q) [Mono f] : StrongMono f :=
  StrongMonoCategory.strongMono_of_mono _
#align category_theory.strong_mono_of_mono CategoryTheory.strongMono_of_mono
-/

section

attribute [local instance] strong_epi_of_epi

#print CategoryTheory.balanced_of_strongEpiCategory /-
instance (priority := 100) balanced_of_strongEpiCategory [StrongEpiCategory C] : Balanced C
    where isIso_of_mono_of_epi _ _ _ _ _ := is_iso_of_mono_of_strong_epi _
#align category_theory.balanced_of_strong_epi_category CategoryTheory.balanced_of_strongEpiCategory
-/

end

section

attribute [local instance] strong_mono_of_mono

#print CategoryTheory.balanced_of_strongMonoCategory /-
instance (priority := 100) balanced_of_strongMonoCategory [StrongMonoCategory C] : Balanced C
    where isIso_of_mono_of_epi _ _ _ _ _ := is_iso_of_epi_of_strong_mono _
#align category_theory.balanced_of_strong_mono_category CategoryTheory.balanced_of_strongMonoCategory
-/

end

end CategoryTheory

