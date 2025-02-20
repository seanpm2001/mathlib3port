/-
Copyright (c) 2021 Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Bhavik Mehta

! This file was ported from Lean 3 source module category_theory.adjunction.over
! leanprover-community/mathlib commit 4f81bc21e32048db7344b7867946e992cf5f68cc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Limits.Shapes.BinaryProducts
import Mathbin.CategoryTheory.Monad.Products
import Mathbin.CategoryTheory.Over

/-!
# Adjunctions related to the over category

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Construct the left adjoint `star X` to `over.forget X : over X ⥤ C`.

## TODO
Show `star X` itself has a left adjoint provided `C` is locally cartesian closed.
-/


noncomputable section

universe v u

-- declare the `v`'s first; see `category_theory.category` for an explanation
namespace CategoryTheory

open Category Limits Comonad

variable {C : Type u} [Category.{v} C] (X : C)

#print CategoryTheory.star /-
/--
The functor from `C` to `over X` which sends `Y : C` to `π₁ : X ⨯ Y ⟶ X`, sometimes denoted `X*`.
-/
@[simps obj_left obj_hom mapLeft]
def star [HasBinaryProducts C] : C ⥤ Over X :=
  cofree _ ⋙ coalgebraToOver X
#align category_theory.star CategoryTheory.star
-/

#print CategoryTheory.forgetAdjStar /-
/-- The functor `over.forget X : over X ⥤ C` has a right adjoint given by `star X`.

Note that the binary products assumption is necessary: the existence of a right adjoint to
`over.forget X` is equivalent to the existence of each binary product `X ⨯ -`.
-/
def forgetAdjStar [HasBinaryProducts C] : Over.forget X ⊣ star X :=
  (coalgebraEquivOver X).symm.toAdjunction.comp (adj _)
#align category_theory.forget_adj_star CategoryTheory.forgetAdjStar
-/

/-- Note that the binary products assumption is necessary: the existence of a right adjoint to
`over.forget X` is equivalent to the existence of each binary product `X ⨯ -`.
-/
instance [HasBinaryProducts C] : IsLeftAdjoint (Over.forget X) :=
  ⟨_, forgetAdjStar X⟩

end CategoryTheory

