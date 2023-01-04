/-
Copyright (c) 2021 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Calle Sönne, Adam Topaz

! This file was ported from Lean 3 source module topology.category.Profinite.as_limit
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Category.ProfiniteCat.Basic
import Mathbin.Topology.DiscreteQuotient

/-!
# Profinite sets as limits of finite sets.

We show that any profinite set is isomorphic to the limit of its
discrete (hence finite) quotients.

## Definitions

There are a handful of definitions in this file, given `X : Profinite`:
1. `X.fintype_diagram` is the functor `discrete_quotient X ⥤ Fintype` whose limit
  is isomorphic to `X` (the limit taking place in `Profinite` via `Fintype_to_Profinite`, see 2).
2. `X.diagram` is an abbreviation for `X.fintype_diagram ⋙ Fintype_to_Profinite`.
3. `X.as_limit_cone` is the cone over `X.diagram` whose cone point is `X`.
4. `X.iso_as_limit_cone_lift` is the isomorphism `X ≅ (Profinite.limit_cone X.diagram).X` induced
  by lifting `X.as_limit_cone`.
5. `X.as_limit_cone_iso` is the isomorphism `X.as_limit_cone ≅ (Profinite.limit_cone X.diagram)`
  induced by `X.iso_as_limit_cone_lift`.
6. `X.as_limit` is a term of type `is_limit X.as_limit_cone`.
7. `X.lim : category_theory.limits.limit_cone X.as_limit_cone` is a bundled combination of 3 and 6.

-/


noncomputable section

open CategoryTheory

namespace ProfiniteCat

universe u

variable (X : ProfiniteCat.{u})

/-- The functor `discrete_quotient X ⥤ Fintype` whose limit is isomorphic to `X`. -/
def fintypeDiagram : DiscreteQuotient X ⥤ FintypeCat
    where
  obj S := FintypeCat.of S
  map S T f := DiscreteQuotient.ofLe f.le
#align Profinite.fintype_diagram ProfiniteCat.fintypeDiagram

/-- An abbreviation for `X.fintype_diagram ⋙ Fintype_to_Profinite`. -/
abbrev diagram : DiscreteQuotient X ⥤ ProfiniteCat :=
  X.fintypeDiagram ⋙ FintypeCat.toProfinite
#align Profinite.diagram ProfiniteCat.diagram

/-- A cone over `X.diagram` whose cone point is `X`. -/
def asLimitCone : CategoryTheory.Limits.Cone X.diagram :=
  { x
    π := { app := fun S => ⟨S.proj, S.proj_is_locally_constant.Continuous⟩ } }
#align Profinite.as_limit_cone ProfiniteCat.asLimitCone

instance is_iso_as_limit_cone_lift : IsIso ((limitConeIsLimit X.diagram).lift X.asLimitCone) :=
  is_iso_of_bijective _
    (by
      refine' ⟨fun a b => _, fun a => _⟩
      · intro h
        refine' DiscreteQuotient.eq_of_proj_eq fun S => _
        apply_fun fun f : (limit_cone X.diagram).x => f.val S  at h
        exact h
      · obtain ⟨b, hb⟩ :=
          DiscreteQuotient.exists_of_compat (fun S => a.val S) fun _ _ h => a.prop (hom_of_le h)
        refine' ⟨b, _⟩
        ext S : 3
        apply hb)
#align Profinite.is_iso_as_limit_cone_lift ProfiniteCat.is_iso_as_limit_cone_lift

/-- The isomorphism between `X` and the explicit limit of `X.diagram`,
induced by lifting `X.as_limit_cone`.
-/
def isoAsLimitConeLift : X ≅ (limitCone X.diagram).x :=
  as_iso <| (limitConeIsLimit _).lift X.asLimitCone
#align Profinite.iso_as_limit_cone_lift ProfiniteCat.isoAsLimitConeLift

/-- The isomorphism of cones `X.as_limit_cone` and `Profinite.limit_cone X.diagram`.
The underlying isomorphism is defeq to `X.iso_as_limit_cone_lift`.
-/
def asLimitConeIso : X.asLimitCone ≅ limitCone _ :=
  Limits.Cones.ext (isoAsLimitConeLift _) fun _ => rfl
#align Profinite.as_limit_cone_iso ProfiniteCat.asLimitConeIso

/-- `X.as_limit_cone` is indeed a limit cone. -/
def asLimit : CategoryTheory.Limits.IsLimit X.asLimitCone :=
  Limits.IsLimit.ofIsoLimit (limitConeIsLimit _) X.asLimitConeIso.symm
#align Profinite.as_limit ProfiniteCat.asLimit

/-- A bundled version of `X.as_limit_cone` and `X.as_limit`. -/
def lim : Limits.LimitCone X.diagram :=
  ⟨X.asLimitCone, X.asLimit⟩
#align Profinite.lim ProfiniteCat.lim

end ProfiniteCat

