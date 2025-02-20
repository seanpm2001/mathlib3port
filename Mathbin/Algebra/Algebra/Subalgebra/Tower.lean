/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Anne Baanen

! This file was ported from Lean 3 source module algebra.algebra.subalgebra.tower
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Subalgebra.Basic
import Mathbin.Algebra.Algebra.Tower

/-!
# Subalgebras in towers of algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove facts about subalgebras in towers of algebra.

An algebra tower A/S/R is expressed by having instances of `algebra A S`,
`algebra R S`, `algebra R A` and `is_scalar_tower R S A`, the later asserting the
compatibility condition `(r • s) • a = r • (s • a)`.

## Main results

 * `is_scalar_tower.subalgebra`: if `A/S/R` is a tower and `S₀` is a subalgebra
   between `S` and `R`, then `A/S/S₀` is a tower
 * `is_scalar_tower.subalgebra'`: if `A/S/R` is a tower and `S₀` is a subalgebra
   between `S` and `R`, then `A/S₀/R` is a tower
 * `subalgebra.restrict_scalars`: turn an `S`-subalgebra of `A` into an `R`-subalgebra of `A`,
   given that `A/S/R` is a tower

-/


open scoped Pointwise

universe u v w u₁ v₁

variable (R : Type u) (S : Type v) (A : Type w) (B : Type u₁) (M : Type v₁)

namespace Algebra

variable [CommSemiring R] [Semiring A] [Algebra R A]

variable [AddCommMonoid M] [Module R M] [Module A M] [IsScalarTower R A M]

variable {A}

#print Algebra.lmul_algebraMap /-
theorem lmul_algebraMap (x : R) : Algebra.lmul R A (algebraMap R A x) = Algebra.lsmul R A x :=
  Eq.symm <| LinearMap.ext <| smul_def x
#align algebra.lmul_algebra_map Algebra.lmul_algebraMap
-/

end Algebra

namespace IsScalarTower

section Semiring

variable [CommSemiring R] [CommSemiring S] [Semiring A]

variable [Algebra R S] [Algebra S A]

variable (R S A)

#print IsScalarTower.subalgebra /-
instance subalgebra (S₀ : Subalgebra R S) : IsScalarTower S₀ S A :=
  of_algebraMap_eq fun x => rfl
#align is_scalar_tower.subalgebra IsScalarTower.subalgebra
-/

variable [Algebra R A] [IsScalarTower R S A]

#print IsScalarTower.subalgebra' /-
instance subalgebra' (S₀ : Subalgebra R S) : IsScalarTower R S₀ A :=
  @IsScalarTower.of_algebraMap_eq R S₀ A _ _ _ _ _ _ fun _ =>
    (IsScalarTower.algebraMap_apply R S A _ : _)
#align is_scalar_tower.subalgebra' IsScalarTower.subalgebra'
-/

end Semiring

end IsScalarTower

namespace Subalgebra

open IsScalarTower

section Semiring

variable (R) {S A B} [CommSemiring R] [CommSemiring S] [Semiring A] [Semiring B]

variable [Algebra R S] [Algebra S A] [Algebra R A] [Algebra S B] [Algebra R B]

variable [IsScalarTower R S A] [IsScalarTower R S B]

#print Subalgebra.restrictScalars /-
/-- Given a tower `A / ↥U / S / R` of algebras, where `U` is an `S`-subalgebra of `A`, reinterpret
`U` as an `R`-subalgebra of `A`. -/
def restrictScalars (U : Subalgebra S A) : Subalgebra R A :=
  { U with algebraMap_mem' := fun x => by rw [algebraMap_apply R S A]; exact U.algebra_map_mem _ }
#align subalgebra.restrict_scalars Subalgebra.restrictScalars
-/

#print Subalgebra.coe_restrictScalars /-
@[simp]
theorem coe_restrictScalars {U : Subalgebra S A} : (restrictScalars R U : Set A) = (U : Set A) :=
  rfl
#align subalgebra.coe_restrict_scalars Subalgebra.coe_restrictScalars
-/

#print Subalgebra.restrictScalars_top /-
@[simp]
theorem restrictScalars_top : restrictScalars R (⊤ : Subalgebra S A) = ⊤ :=
  SetLike.coe_injective rfl
#align subalgebra.restrict_scalars_top Subalgebra.restrictScalars_top
-/

#print Subalgebra.restrictScalars_toSubmodule /-
@[simp]
theorem restrictScalars_toSubmodule {U : Subalgebra S A} :
    (U.restrictScalars R).toSubmodule = U.toSubmodule.restrictScalars R :=
  SetLike.coe_injective rfl
#align subalgebra.restrict_scalars_to_submodule Subalgebra.restrictScalars_toSubmodule
-/

#print Subalgebra.mem_restrictScalars /-
@[simp]
theorem mem_restrictScalars {U : Subalgebra S A} {x : A} : x ∈ restrictScalars R U ↔ x ∈ U :=
  Iff.rfl
#align subalgebra.mem_restrict_scalars Subalgebra.mem_restrictScalars
-/

#print Subalgebra.restrictScalars_injective /-
theorem restrictScalars_injective :
    Function.Injective (restrictScalars R : Subalgebra S A → Subalgebra R A) := fun U V H =>
  ext fun x => by rw [← mem_restrict_scalars R, H, mem_restrict_scalars]
#align subalgebra.restrict_scalars_injective Subalgebra.restrictScalars_injective
-/

#print Subalgebra.ofRestrictScalars /-
/-- Produces an `R`-algebra map from `U.restrict_scalars R` given an `S`-algebra map from `U`.

This is a special case of `alg_hom.restrict_scalars` that can be helpful in elaboration. -/
@[simp]
def ofRestrictScalars (U : Subalgebra S A) (f : U →ₐ[S] B) : U.restrictScalars R →ₐ[R] B :=
  f.restrictScalars R
#align subalgebra.of_restrict_scalars Subalgebra.ofRestrictScalars
-/

end Semiring

end Subalgebra

namespace IsScalarTower

open Subalgebra

variable [CommSemiring R] [CommSemiring S] [CommSemiring A]

variable [Algebra R S] [Algebra S A] [Algebra R A] [IsScalarTower R S A]

#print IsScalarTower.adjoin_range_toAlgHom /-
theorem adjoin_range_toAlgHom (t : Set A) :
    (Algebra.adjoin (toAlgHom R S A).range t).restrictScalars R =
      (Algebra.adjoin S t).restrictScalars R :=
  Subalgebra.ext fun z =>
    show
      z ∈ Subsemiring.closure (Set.range (algebraMap (toAlgHom R S A).range A) ∪ t : Set A) ↔
        z ∈ Subsemiring.closure (Set.range (algebraMap S A) ∪ t : Set A)
      by
      suffices Set.range (algebraMap (toAlgHom R S A).range A) = Set.range (algebraMap S A) by
        rw [this]
      ext z; exact ⟨fun ⟨⟨x, y, h1⟩, h2⟩ => ⟨y, h2 ▸ h1⟩, fun ⟨y, hy⟩ => ⟨⟨z, y, hy⟩, rfl⟩⟩
#align is_scalar_tower.adjoin_range_to_alg_hom IsScalarTower.adjoin_range_toAlgHom
-/

end IsScalarTower

