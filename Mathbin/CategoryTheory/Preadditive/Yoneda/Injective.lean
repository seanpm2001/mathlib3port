/-
Copyright (c) 2020 Markus Himmel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel, Scott Morrison

! This file was ported from Lean 3 source module category_theory.preadditive.yoneda.injective
! leanprover-community/mathlib commit bd15ff41b70f5e2cc210f26f25a8d5c53b20d3de
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Preadditive.Yoneda.Basic
import Mathbin.CategoryTheory.Preadditive.Injective
import Mathbin.Algebra.Category.Group.EpiMono
import Mathbin.Algebra.Category.Module.EpiMono

/-!
> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

An object is injective iff the preadditive yoneda functor on it preserves epimorphisms.
-/


universe v u

open Opposite

namespace CategoryTheory

variable {C : Type u} [Category.{v} C]

section Preadditive

variable [Preadditive C]

namespace Injective

#print CategoryTheory.Injective.injective_iff_preservesEpimorphisms_preadditiveYoneda_obj /-
theorem injective_iff_preservesEpimorphisms_preadditiveYoneda_obj (J : C) :
    Injective J ↔ (preadditiveYoneda.obj J).PreservesEpimorphisms :=
  by
  rw [injective_iff_preserves_epimorphisms_yoneda_obj]
  refine' ⟨fun h : (preadditive_yoneda.obj J ⋙ forget _).PreservesEpimorphisms => _, _⟩
  ·
    exact
      functor.preserves_epimorphisms_of_preserves_of_reflects (preadditive_yoneda.obj J) (forget _)
  · intro
    exact (inferInstance : (preadditive_yoneda.obj J ⋙ forget _).PreservesEpimorphisms)
#align category_theory.injective.injective_iff_preserves_epimorphisms_preadditive_yoneda_obj CategoryTheory.Injective.injective_iff_preservesEpimorphisms_preadditiveYoneda_obj
-/

#print CategoryTheory.Injective.injective_iff_preservesEpimorphisms_preadditive_yoneda_obj' /-
theorem injective_iff_preservesEpimorphisms_preadditive_yoneda_obj' (J : C) :
    Injective J ↔ (preadditiveYonedaObj J).PreservesEpimorphisms :=
  by
  rw [injective_iff_preserves_epimorphisms_yoneda_obj]
  refine' ⟨fun h : (preadditive_yoneda_obj J ⋙ forget _).PreservesEpimorphisms => _, _⟩
  ·
    exact
      functor.preserves_epimorphisms_of_preserves_of_reflects (preadditive_yoneda_obj J) (forget _)
  · intro
    exact (inferInstance : (preadditive_yoneda_obj J ⋙ forget _).PreservesEpimorphisms)
#align category_theory.injective.injective_iff_preserves_epimorphisms_preadditive_yoneda_obj' CategoryTheory.Injective.injective_iff_preservesEpimorphisms_preadditive_yoneda_obj'
-/

end Injective

end Preadditive

end CategoryTheory

