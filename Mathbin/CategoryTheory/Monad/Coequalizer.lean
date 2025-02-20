/-
Copyright (c) 2020 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta

! This file was ported from Lean 3 source module category_theory.monad.coequalizer
! leanprover-community/mathlib commit ef55335933293309ff8c0b1d20ffffeecbe5c39f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.Reflexive
import Mathbin.CategoryTheory.Limits.Shapes.SplitCoequalizer
import Mathbin.CategoryTheory.Monad.Algebra

/-!
# Special coequalizers associated to a monad

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Associated to a monad `T : C ⥤ C` we have important coequalizer constructions:
Any algebra is a coequalizer (in the category of algebras) of free algebras. Furthermore, this
coequalizer is reflexive.
In `C`, this cofork diagram is a split coequalizer (in particular, it is still a coequalizer).
This split coequalizer is known as the Beck coequalizer (as it features heavily in Beck's
monadicity theorem).
-/


universe v₁ u₁

namespace CategoryTheory

namespace Monad

open Limits

variable {C : Type u₁}

variable [Category.{v₁} C]

variable {T : Monad C} (X : Algebra T)

/-!
Show that any algebra is a coequalizer of free algebras.
-/


#print CategoryTheory.Monad.FreeCoequalizer.topMap /-
/-- The top map in the coequalizer diagram we will construct. -/
@[simps]
def FreeCoequalizer.topMap : (Monad.free T).obj (T.obj X.A) ⟶ (Monad.free T).obj X.A :=
  (Monad.free T).map X.a
#align category_theory.monad.free_coequalizer.top_map CategoryTheory.Monad.FreeCoequalizer.topMap
-/

#print CategoryTheory.Monad.FreeCoequalizer.bottomMap /-
/-- The bottom map in the coequalizer diagram we will construct. -/
@[simps]
def FreeCoequalizer.bottomMap : (Monad.free T).obj (T.obj X.A) ⟶ (Monad.free T).obj X.A
    where
  f := T.μ.app X.A
  h' := T.and_assoc X.A
#align category_theory.monad.free_coequalizer.bottom_map CategoryTheory.Monad.FreeCoequalizer.bottomMap
-/

#print CategoryTheory.Monad.FreeCoequalizer.π /-
/-- The cofork map in the coequalizer diagram we will construct. -/
@[simps]
def FreeCoequalizer.π : (Monad.free T).obj X.A ⟶ X
    where
  f := X.a
  h' := X.and_assoc.symm
#align category_theory.monad.free_coequalizer.π CategoryTheory.Monad.FreeCoequalizer.π
-/

#print CategoryTheory.Monad.FreeCoequalizer.condition /-
theorem FreeCoequalizer.condition :
    FreeCoequalizer.topMap X ≫ FreeCoequalizer.π X =
      FreeCoequalizer.bottomMap X ≫ FreeCoequalizer.π X :=
  Algebra.Hom.ext _ _ X.and_assoc.symm
#align category_theory.monad.free_coequalizer.condition CategoryTheory.Monad.FreeCoequalizer.condition
-/

instance : IsReflexivePair (FreeCoequalizer.topMap X) (FreeCoequalizer.bottomMap X) :=
  by
  apply is_reflexive_pair.mk' _ _ _
  apply (free T).map (T.η.app X.A)
  · ext
    dsimp
    rw [← functor.map_comp, X.unit, Functor.map_id]
  · ext
    apply monad.right_unit

#print CategoryTheory.Monad.beckAlgebraCofork /-
/-- Construct the Beck cofork in the category of algebras. This cofork is reflexive as well as a
coequalizer.
-/
@[simps]
def beckAlgebraCofork : Cofork (FreeCoequalizer.topMap X) (FreeCoequalizer.bottomMap X) :=
  Cofork.ofπ _ (FreeCoequalizer.condition X)
#align category_theory.monad.beck_algebra_cofork CategoryTheory.Monad.beckAlgebraCofork
-/

#print CategoryTheory.Monad.beckAlgebraCoequalizer /-
/-- The cofork constructed is a colimit. This shows that any algebra is a (reflexive) coequalizer of
free algebras.
-/
def beckAlgebraCoequalizer : IsColimit (beckAlgebraCofork X) :=
  Cofork.IsColimit.mk' _ fun s =>
    by
    have h₁ : (T : C ⥤ C).map X.a ≫ s.π.f = T.μ.app X.A ≫ s.π.f :=
      congr_arg monad.algebra.hom.f s.condition
    have h₂ : (T : C ⥤ C).map s.π.f ≫ s.X.a = T.μ.app X.A ≫ s.π.f := s.π.h
    refine' ⟨⟨T.η.app _ ≫ s.π.f, _⟩, _, _⟩
    · dsimp
      rw [functor.map_comp, category.assoc, h₂, monad.right_unit_assoc,
        show X.a ≫ _ ≫ _ = _ from T.η.naturality_assoc _ _, h₁, monad.left_unit_assoc]
    · ext
      simpa [← T.η.naturality_assoc, T.left_unit_assoc] using T.η.app ((T : C ⥤ C).obj X.A) ≫= h₁
    · intro m hm
      ext
      dsimp only
      rw [← hm]
      apply (X.unit_assoc _).symm
#align category_theory.monad.beck_algebra_coequalizer CategoryTheory.Monad.beckAlgebraCoequalizer
-/

#print CategoryTheory.Monad.beckSplitCoequalizer /-
/-- The Beck cofork is a split coequalizer. -/
def beckSplitCoequalizer : IsSplitCoequalizer (T.map X.a) (T.μ.app _) X.a :=
  ⟨T.η.app _, T.η.app _, X.and_assoc.symm, X.Unit, T.left_unit _, (T.η.naturality _).symm⟩
#align category_theory.monad.beck_split_coequalizer CategoryTheory.Monad.beckSplitCoequalizer
-/

#print CategoryTheory.Monad.beckCofork /-
/-- This is the Beck cofork. It is a split coequalizer, in particular a coequalizer. -/
@[simps pt]
def beckCofork : Cofork (T.map X.a) (T.μ.app _) :=
  (beckSplitCoequalizer X).asCofork
#align category_theory.monad.beck_cofork CategoryTheory.Monad.beckCofork
-/

#print CategoryTheory.Monad.beckCofork_π /-
@[simp]
theorem beckCofork_π : (beckCofork X).π = X.a :=
  rfl
#align category_theory.monad.beck_cofork_π CategoryTheory.Monad.beckCofork_π
-/

#print CategoryTheory.Monad.beckCoequalizer /-
/-- The Beck cofork is a coequalizer. -/
def beckCoequalizer : IsColimit (beckCofork X) :=
  (beckSplitCoequalizer X).isCoequalizer
#align category_theory.monad.beck_coequalizer CategoryTheory.Monad.beckCoequalizer
-/

#print CategoryTheory.Monad.beckCoequalizer_desc /-
@[simp]
theorem beckCoequalizer_desc (s : Cofork (T.toFunctor.map X.a) (T.μ.app X.A)) :
    (beckCoequalizer X).desc s = T.η.app _ ≫ s.π :=
  rfl
#align category_theory.monad.beck_coequalizer_desc CategoryTheory.Monad.beckCoequalizer_desc
-/

end Monad

end CategoryTheory

