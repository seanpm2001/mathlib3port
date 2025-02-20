/-
Copyright (c) 2022 Jakob von Raumer. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jakob von Raumer

! This file was ported from Lean 3 source module category_theory.abelian.injective
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Abelian.Exact
import Mathbin.CategoryTheory.Preadditive.Injective
import Mathbin.CategoryTheory.Preadditive.Yoneda.Limits
import Mathbin.CategoryTheory.Preadditive.Yoneda.Injective

/-!
# Injective objects in abelian categories

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

* Objects in an abelian categories are injective if and only if the preadditive Yoneda functor
  on them preserves finite colimits.
-/


noncomputable section

open CategoryTheory

open CategoryTheory.Limits

open CategoryTheory.Injective

open Opposite

universe v u

namespace CategoryTheory

variable {C : Type u} [Category.{v} C] [Abelian C]

#print CategoryTheory.preservesFiniteColimitsPreadditiveYonedaObjOfInjective /-
/-- The preadditive Yoneda functor on `J` preserves colimits if `J` is injective. -/
def preservesFiniteColimitsPreadditiveYonedaObjOfInjective (J : C) [hP : Injective J] :
    PreservesFiniteColimits (preadditiveYonedaObj J) :=
  by
  letI := (injective_iff_preserves_epimorphisms_preadditive_yoneda_obj' J).mp hP
  apply functor.preserves_finite_colimits_of_preserves_epis_and_kernels
#align category_theory.preserves_finite_colimits_preadditive_yoneda_obj_of_injective CategoryTheory.preservesFiniteColimitsPreadditiveYonedaObjOfInjective
-/

#print CategoryTheory.injective_of_preservesFiniteColimits_preadditiveYonedaObj /-
/-- An object is injective if its preadditive Yoneda functor preserves finite colimits. -/
theorem injective_of_preservesFiniteColimits_preadditiveYonedaObj (J : C)
    [hP : PreservesFiniteColimits (preadditiveYonedaObj J)] : Injective J :=
  by
  rw [injective_iff_preserves_epimorphisms_preadditive_yoneda_obj']
  infer_instance
#align category_theory.injective_of_preserves_finite_colimits_preadditive_yoneda_obj CategoryTheory.injective_of_preservesFiniteColimits_preadditiveYonedaObj
-/

end CategoryTheory

