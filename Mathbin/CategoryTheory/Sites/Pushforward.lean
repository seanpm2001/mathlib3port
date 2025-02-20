/-
Copyright (c) 2021 Andrew Yang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andrew Yang

! This file was ported from Lean 3 source module category_theory.sites.pushforward
! leanprover-community/mathlib commit bd15ff41b70f5e2cc210f26f25a8d5c53b20d3de
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.CategoryTheory.Sites.CoverPreserving
import Mathbin.CategoryTheory.Sites.LeftExact

/-!
# Pushforward of sheaves

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `category_theory.sites.pushforward`: the induced functor `Sheaf J A ⥤ Sheaf K A` for a
cover-preserving and compatible-preserving functor `G : (C, J) ⥤ (D, K)`.

-/


universe v₁ u₁

noncomputable section

open CategoryTheory.Limits

namespace CategoryTheory

variable {C : Type v₁} [SmallCategory C] {D : Type v₁} [SmallCategory D]

variable (A : Type u₁) [Category.{v₁} A]

variable (J : GrothendieckTopology C) (K : GrothendieckTopology D)

instance [HasLimits A] : CreatesLimits (sheafToPresheaf J A) :=
  CategoryTheory.Sheaf.CategoryTheory.SheafToPresheaf.CategoryTheory.createsLimits.{u₁, v₁, v₁}

-- The assumptions so that we have sheafification
variable [ConcreteCategory.{v₁} A] [PreservesLimits (forget A)] [HasColimits A] [HasLimits A]

variable [PreservesFilteredColimits (forget A)] [ReflectsIsomorphisms (forget A)]

attribute [local instance] reflects_limits_of_reflects_isomorphisms

instance {X : C} : IsCofiltered (J.cover X) :=
  inferInstance

#print CategoryTheory.Sites.pushforward /-
/-- The pushforward functor `Sheaf J A ⥤ Sheaf K A` associated to a functor `G : C ⥤ D` in the
same direction as `G`. -/
@[simps]
def Sites.pushforward (G : C ⥤ D) : Sheaf J A ⥤ Sheaf K A :=
  sheafToPresheaf J A ⋙ lan G.op ⋙ presheafToSheaf K A
#align category_theory.sites.pushforward CategoryTheory.Sites.pushforward
-/

instance (G : C ⥤ D) [RepresentablyFlat G] : PreservesFiniteLimits (Sites.pushforward A J K G) :=
  by
  apply (config := { instances := false }) comp_preserves_finite_limits
  · infer_instance
  apply (config := { instances := false }) comp_preserves_finite_limits
  · apply CategoryTheory.lanPreservesFiniteLimitsOfFlat
  · apply CategoryTheory.presheafToSheaf.Limits.preservesFiniteLimits.{u₁, v₁, v₁}
    infer_instance

#print CategoryTheory.Sites.pullbackPushforwardAdjunction /-
/-- The pushforward functor is left adjoint to the pullback functor. -/
def Sites.pullbackPushforwardAdjunction {G : C ⥤ D} (hG₁ : CompatiblePreserving K G)
    (hG₂ : CoverPreserving J K G) : Sites.pushforward A J K G ⊣ Sites.pullback A hG₁ hG₂ :=
  ((Lan.adjunction A G.op).comp (sheafificationAdjunction K A)).restrictFullyFaithful
    (sheafToPresheaf J A) (𝟭 _)
    (NatIso.ofComponents (fun _ => Iso.refl _) fun _ _ _ =>
      (Category.comp_id _).trans (Category.id_comp _).symm)
    (NatIso.ofComponents (fun _ => Iso.refl _) fun _ _ _ =>
      (Category.comp_id _).trans (Category.id_comp _).symm)
#align category_theory.sites.pullback_pushforward_adjunction CategoryTheory.Sites.pullbackPushforwardAdjunction
-/

end CategoryTheory

