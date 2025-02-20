/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module category_theory.limits.pi
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Pi.Basic
import Mathbin.CategoryTheory.Limits.HasLimits

/-!
# Limits in the category of indexed families of objects.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a functor `F : J ⥤ Π i, C i` into a category of indexed families,
1. we can assemble a collection of cones over `F ⋙ pi.eval C i` into a cone over `F`
2. if all those cones are limit cones, the assembled cone is a limit cone, and
3. if we have limits for each of `F ⋙ pi.eval C i`, we can produce a
   `has_limit F` instance
-/


open CategoryTheory

open CategoryTheory.Limits

namespace CategoryTheory.pi

universe v₁ v₂ u₁ u₂

variable {I : Type v₁} {C : I → Type u₁} [∀ i, Category.{v₁} (C i)]

variable {J : Type v₁} [SmallCategory J]

variable {F : J ⥤ ∀ i, C i}

#print CategoryTheory.pi.coneCompEval /-
/-- A cone over `F : J ⥤ Π i, C i` has as its components cones over each of the `F ⋙ pi.eval C i`.
-/
def coneCompEval (c : Cone F) (i : I) : Cone (F ⋙ Pi.eval C i)
    where
  pt := c.pt i
  π :=
    { app := fun j => c.π.app j i
      naturality' := fun j j' f => congr_fun (c.π.naturality f) i }
#align category_theory.pi.cone_comp_eval CategoryTheory.pi.coneCompEval
-/

#print CategoryTheory.pi.coconeCompEval /-
/--
A cocone over `F : J ⥤ Π i, C i` has as its components cocones over each of the `F ⋙ pi.eval C i`.
-/
def coconeCompEval (c : Cocone F) (i : I) : Cocone (F ⋙ Pi.eval C i)
    where
  pt := c.pt i
  ι :=
    { app := fun j => c.ι.app j i
      naturality' := fun j j' f => congr_fun (c.ι.naturality f) i }
#align category_theory.pi.cocone_comp_eval CategoryTheory.pi.coconeCompEval
-/

#print CategoryTheory.pi.coneOfConeCompEval /-
/--
Given a family of cones over the `F ⋙ pi.eval C i`, we can assemble these together as a `cone F`.
-/
def coneOfConeCompEval (c : ∀ i, Cone (F ⋙ Pi.eval C i)) : Cone F
    where
  pt i := (c i).pt
  π :=
    { app := fun j i => (c i).π.app j
      naturality' := fun j j' f => by ext i; exact (c i).π.naturality f }
#align category_theory.pi.cone_of_cone_comp_eval CategoryTheory.pi.coneOfConeCompEval
-/

#print CategoryTheory.pi.coconeOfCoconeCompEval /-
/-- Given a family of cocones over the `F ⋙ pi.eval C i`,
we can assemble these together as a `cocone F`.
-/
def coconeOfCoconeCompEval (c : ∀ i, Cocone (F ⋙ Pi.eval C i)) : Cocone F
    where
  pt i := (c i).pt
  ι :=
    { app := fun j i => (c i).ι.app j
      naturality' := fun j j' f => by ext i; exact (c i).ι.naturality f }
#align category_theory.pi.cocone_of_cocone_comp_eval CategoryTheory.pi.coconeOfCoconeCompEval
-/

#print CategoryTheory.pi.coneOfConeEvalIsLimit /-
/-- Given a family of limit cones over the `F ⋙ pi.eval C i`,
assembling them together as a `cone F` produces a limit cone.
-/
def coneOfConeEvalIsLimit {c : ∀ i, Cone (F ⋙ Pi.eval C i)} (P : ∀ i, IsLimit (c i)) :
    IsLimit (coneOfConeCompEval c)
    where
  lift s i := (P i).lift (coneCompEval s i)
  fac s j := by
    ext i
    exact (P i).fac (cone_comp_eval s i) j
  uniq s m w := by
    ext i
    exact (P i).uniq (cone_comp_eval s i) (m i) fun j => congr_fun (w j) i
#align category_theory.pi.cone_of_cone_eval_is_limit CategoryTheory.pi.coneOfConeEvalIsLimit
-/

#print CategoryTheory.pi.coconeOfCoconeEvalIsColimit /-
/-- Given a family of colimit cocones over the `F ⋙ pi.eval C i`,
assembling them together as a `cocone F` produces a colimit cocone.
-/
def coconeOfCoconeEvalIsColimit {c : ∀ i, Cocone (F ⋙ Pi.eval C i)} (P : ∀ i, IsColimit (c i)) :
    IsColimit (coconeOfCoconeCompEval c)
    where
  desc s i := (P i).desc (coconeCompEval s i)
  fac s j := by
    ext i
    exact (P i).fac (cocone_comp_eval s i) j
  uniq s m w := by
    ext i
    exact (P i).uniq (cocone_comp_eval s i) (m i) fun j => congr_fun (w j) i
#align category_theory.pi.cocone_of_cocone_eval_is_colimit CategoryTheory.pi.coconeOfCoconeEvalIsColimit
-/

section

variable [∀ i, HasLimit (F ⋙ Pi.eval C i)]

#print CategoryTheory.pi.hasLimit_of_hasLimit_comp_eval /-
/-- If we have a functor `F : J ⥤ Π i, C i` into a category of indexed families,
and we have limits for each of the `F ⋙ pi.eval C i`,
then `F` has a limit.
-/
theorem hasLimit_of_hasLimit_comp_eval : HasLimit F :=
  HasLimit.mk
    { Cone := coneOfConeCompEval fun i => limit.cone _
      IsLimit := coneOfConeEvalIsLimit fun i => limit.isLimit _ }
#align category_theory.pi.has_limit_of_has_limit_comp_eval CategoryTheory.pi.hasLimit_of_hasLimit_comp_eval
-/

end

section

variable [∀ i, HasColimit (F ⋙ Pi.eval C i)]

#print CategoryTheory.pi.hasColimit_of_hasColimit_comp_eval /-
/-- If we have a functor `F : J ⥤ Π i, C i` into a category of indexed families,
and colimits exist for each of the `F ⋙ pi.eval C i`,
there is a colimit for `F`.
-/
theorem hasColimit_of_hasColimit_comp_eval : HasColimit F :=
  HasColimit.mk
    { Cocone := coconeOfCoconeCompEval fun i => colimit.cocone _
      IsColimit := coconeOfCoconeEvalIsColimit fun i => colimit.isColimit _ }
#align category_theory.pi.has_colimit_of_has_colimit_comp_eval CategoryTheory.pi.hasColimit_of_hasColimit_comp_eval
-/

end

/-!
As an example, we can use this to construct particular shapes of limits
in a category of indexed families.

With the addition of
`import category_theory.limits.shapes.types`
we can use:
```
local attribute [instance] has_limit_of_has_limit_comp_eval
example : has_binary_products (I → Type v₁) := ⟨by apply_instance⟩
```
-/


end CategoryTheory.pi

