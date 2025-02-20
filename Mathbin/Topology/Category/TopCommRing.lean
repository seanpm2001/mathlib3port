/-
Copyright (c) 2019 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module topology.category.TopCommRing
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Category.Ring.Basic
import Mathbin.Topology.Category.Top.Basic
import Mathbin.Topology.Algebra.Ring.Basic

/-!
# Category of topological commutative rings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We introduce the category `TopCommRing` of topological commutative rings together with the relevant
forgetful functors to topological spaces and commutative rings.
-/


universe u

open CategoryTheory

#print TopCommRingCat /-
/-- A bundled topological commutative ring. -/
structure TopCommRingCat where
  α : Type u
  [isCommRing : CommRing α]
  [isTopologicalSpace : TopologicalSpace α]
  [is_topologicalRing : TopologicalRing α]
#align TopCommRing TopCommRingCat
-/

namespace TopCommRingCat

instance : Inhabited TopCommRingCat :=
  ⟨⟨PUnit⟩⟩

instance : CoeSort TopCommRingCat (Type u) :=
  ⟨TopCommRingCat.α⟩

attribute [instance] is_comm_ring is_topological_space is_topological_ring

instance : Category TopCommRingCat.{u}
    where
  Hom R S := { f : R →+* S // Continuous f }
  id R := ⟨RingHom.id R, by obviously⟩
  -- TODO remove obviously?
  comp R S T f g :=
    ⟨g.val.comp f.val,
      by
      -- TODO automate
      cases f;
      cases g
      dsimp; apply Continuous.comp <;> assumption⟩

instance : ConcreteCategory TopCommRingCat.{u}
    where
  forget :=
    { obj := fun R => R
      map := fun R S f => f.val }
  forget_faithful := { }

#print TopCommRingCat.of /-
/-- Construct a bundled `TopCommRing` from the underlying type and the appropriate typeclasses. -/
def of (X : Type u) [CommRing X] [TopologicalSpace X] [TopologicalRing X] : TopCommRingCat :=
  ⟨X⟩
#align TopCommRing.of TopCommRingCat.of
-/

#print TopCommRingCat.coe_of /-
@[simp]
theorem coe_of (X : Type u) [CommRing X] [TopologicalSpace X] [TopologicalRing X] :
    (of X : Type u) = X :=
  rfl
#align TopCommRing.coe_of TopCommRingCat.coe_of
-/

#print TopCommRingCat.forgetTopologicalSpace /-
instance forgetTopologicalSpace (R : TopCommRingCat) :
    TopologicalSpace ((forget TopCommRingCat).obj R) :=
  R.isTopologicalSpace
#align TopCommRing.forget_topological_space TopCommRingCat.forgetTopologicalSpace
-/

#print TopCommRingCat.forgetCommRing /-
instance forgetCommRing (R : TopCommRingCat) : CommRing ((forget TopCommRingCat).obj R) :=
  R.isCommRing
#align TopCommRing.forget_comm_ring TopCommRingCat.forgetCommRing
-/

#print TopCommRingCat.forgetTopologicalRing /-
instance forgetTopologicalRing (R : TopCommRingCat) :
    TopologicalRing ((forget TopCommRingCat).obj R) :=
  R.is_topologicalRing
#align TopCommRing.forget_topological_ring TopCommRingCat.forgetTopologicalRing
-/

#print TopCommRingCat.hasForgetToCommRingCat /-
instance hasForgetToCommRingCat : HasForget₂ TopCommRingCat CommRingCat :=
  HasForget₂.mk' (fun R => CommRingCat.of R) (fun x => rfl) (fun R S f => f.val) fun R S f =>
    HEq.rfl
#align TopCommRing.has_forget_to_CommRing TopCommRingCat.hasForgetToCommRingCat
-/

#print TopCommRingCat.forgetToCommRingCatTopologicalSpace /-
instance forgetToCommRingCatTopologicalSpace (R : TopCommRingCat) :
    TopologicalSpace ((forget₂ TopCommRingCat CommRingCat).obj R) :=
  R.isTopologicalSpace
#align TopCommRing.forget_to_CommRing_topological_space TopCommRingCat.forgetToCommRingCatTopologicalSpace
-/

#print TopCommRingCat.hasForgetToTopCat /-
/-- The forgetful functor to Top. -/
instance hasForgetToTopCat : HasForget₂ TopCommRingCat TopCat :=
  HasForget₂.mk' (fun R => TopCat.of R) (fun x => rfl) (fun R S f => ⟨⇑f.1, f.2⟩) fun R S f =>
    HEq.rfl
#align TopCommRing.has_forget_to_Top TopCommRingCat.hasForgetToTopCat
-/

#print TopCommRingCat.forgetToTopCatCommRing /-
instance forgetToTopCatCommRing (R : TopCommRingCat) :
    CommRing ((forget₂ TopCommRingCat TopCat).obj R) :=
  R.isCommRing
#align TopCommRing.forget_to_Top_comm_ring TopCommRingCat.forgetToTopCatCommRing
-/

#print TopCommRingCat.forgetToTopCatTopologicalRing /-
instance forgetToTopCatTopologicalRing (R : TopCommRingCat) :
    TopologicalRing ((forget₂ TopCommRingCat TopCat).obj R) :=
  R.is_topologicalRing
#align TopCommRing.forget_to_Top_topological_ring TopCommRingCat.forgetToTopCatTopologicalRing
-/

/-- The forgetful functors to `Type` do not reflect isomorphisms,
but the forgetful functor from `TopCommRing` to `Top` does.
-/
instance : ReflectsIsomorphisms (forget₂ TopCommRingCat.{u} TopCat.{u})
    where reflects X Y f _ := by
    skip
    -- We have an isomorphism in `Top`,
    let i_Top := as_iso ((forget₂ TopCommRingCat TopCat).map f)
    -- and a `ring_equiv`.
    let e_Ring : X ≃+* Y := { f.1, ((forget TopCat).mapIso i_Top).toEquiv with }
    -- Putting these together we obtain the isomorphism we're after:
    exact
      ⟨⟨⟨e_Ring.symm, i_Top.inv.2⟩,
          ⟨by ext x; exact e_Ring.left_inv x, by ext x; exact e_Ring.right_inv x⟩⟩⟩

end TopCommRingCat

