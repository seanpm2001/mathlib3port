/-
Copyright (c) 2020 Eric Weiser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Weiser

! This file was ported from Lean 3 source module algebra.star.free
! leanprover-community/mathlib commit cb3ceec8485239a61ed51d944cb9a95b68c6bafc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Star.Basic
import Mathbin.Algebra.FreeAlgebra

/-!
# A *-algebra structure on the free algebra.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Reversing words gives a *-structure on the free monoid or on the free algebra on a type.

## Implementation note
We have this in a separate file, rather than in `algebra.free_monoid` and `algebra.free_algebra`,
to avoid importing `algebra.star.basic` into the entire hierarchy.
-/


namespace FreeMonoid

variable {α : Type _}

instance : StarSemigroup (FreeMonoid α)
    where
  unit := List.reverse
  star_involutive := List.reverse_reverse
  star_mul := List.reverse_append

#print FreeMonoid.star_of /-
@[simp]
theorem star_of (x : α) : star (of x) = of x :=
  rfl
#align free_monoid.star_of FreeMonoid.star_of
-/

#print FreeMonoid.star_one /-
/-- Note that `star_one` is already a global simp lemma, but this one works with dsimp too -/
@[simp]
theorem star_one : star (1 : FreeMonoid α) = 1 :=
  rfl
#align free_monoid.star_one FreeMonoid.star_one
-/

end FreeMonoid

namespace FreeAlgebra

variable {R : Type _} [CommSemiring R] {X : Type _}

/-- The star ring formed by reversing the elements of products -/
instance : StarRing (FreeAlgebra R X)
    where
  unit := MulOpposite.unop ∘ lift R (MulOpposite.op ∘ ι R)
  star_involutive x := by
    unfold Star.star
    simp only [Function.comp_apply]
    refine' FreeAlgebra.induction R X _ _ _ _ x
    · intros; simp only [AlgHom.commutes, MulOpposite.algebraMap_apply, MulOpposite.unop_op]
    · intros; simp only [lift_ι_apply, MulOpposite.unop_op]
    · intros; simp only [*, map_mul, MulOpposite.unop_mul]
    · intros; simp only [*, map_add, MulOpposite.unop_add]
  star_mul a b := by simp only [Function.comp_apply, map_mul, MulOpposite.unop_mul]
  star_add a b := by simp only [Function.comp_apply, map_add, MulOpposite.unop_add]

#print FreeAlgebra.star_ι /-
@[simp]
theorem star_ι (x : X) : star (ι R x) = ι R x := by simp [star, Star.star]
#align free_algebra.star_ι FreeAlgebra.star_ι
-/

#print FreeAlgebra.star_algebraMap /-
@[simp]
theorem star_algebraMap (r : R) : star (algebraMap R (FreeAlgebra R X) r) = algebraMap R _ r := by
  simp [star, Star.star]
#align free_algebra.star_algebra_map FreeAlgebra.star_algebraMap
-/

#print FreeAlgebra.starHom /-
/-- `star` as an `alg_equiv` -/
def starHom : FreeAlgebra R X ≃ₐ[R] (FreeAlgebra R X)ᵐᵒᵖ :=
  { starRingEquiv with commutes' := fun r => by simp [star_algebra_map] }
#align free_algebra.star_hom FreeAlgebra.starHom
-/

end FreeAlgebra

