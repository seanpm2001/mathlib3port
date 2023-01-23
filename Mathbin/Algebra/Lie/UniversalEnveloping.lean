/-
Copyright (c) 2020 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.universal_enveloping
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.OfAssociative
import Mathbin.Algebra.RingQuot
import Mathbin.LinearAlgebra.TensorAlgebra.Basic

/-!
# Universal enveloping algebra

Given a commutative ring `R` and a Lie algebra `L` over `R`, we construct the universal
enveloping algebra of `L`, together with its universal property.

## Main definitions

  * `universal_enveloping_algebra`: the universal enveloping algebra, endowed with an
    `R`-algebra structure.
  * `universal_enveloping_algebra.ι`: the Lie algebra morphism from `L` to its universal
    enveloping algebra.
  * `universal_enveloping_algebra.lift`: given an associative algebra `A`, together with a Lie
    algebra morphism `f : L →ₗ⁅R⁆ A`, `lift R L f : universal_enveloping_algebra R L →ₐ[R] A` is the
    unique morphism of algebras through which `f` factors.
  * `universal_enveloping_algebra.ι_comp_lift`: states that the lift of a morphism is indeed part
    of a factorisation.
  * `universal_enveloping_algebra.lift_unique`: states that lifts of morphisms are indeed unique.
  * `universal_enveloping_algebra.hom_ext`: a restatement of `lift_unique` as an extensionality
    lemma.

## Tags

lie algebra, universal enveloping algebra, tensor algebra
-/


universe u₁ u₂ u₃

variable (R : Type u₁) (L : Type u₂)

variable [CommRing R] [LieRing L] [LieAlgebra R L]

-- mathport name: exprιₜ
local notation "ιₜ" => TensorAlgebra.ι R

namespace UniversalEnvelopingAlgebra

/-- The quotient by the ideal generated by this relation is the universal enveloping algebra.

Note that we have avoided using the more natural expression:
| lie_compat (x y : L) : rel (ιₜ ⁅x, y⁆) ⁅ιₜ x, ιₜ y⁆
so that our construction needs only the semiring structure of the tensor algebra. -/
inductive Rel : TensorAlgebra R L → TensorAlgebra R L → Prop
  | lie_compat (x y : L) : Rel (ιₜ ⁅x, y⁆ + ιₜ y * ιₜ x) (ιₜ x * ιₜ y)
#align universal_enveloping_algebra.rel UniversalEnvelopingAlgebra.Rel

end UniversalEnvelopingAlgebra

/- ./././Mathport/Syntax/Translate/Command.lean:42:9: unsupported derive handler algebra[algebra] R -/
/-- The universal enveloping algebra of a Lie algebra. -/
def UniversalEnvelopingAlgebra :=
  RingQuot (UniversalEnvelopingAlgebra.Rel R L)deriving Inhabited, Ring,
  «./././Mathport/Syntax/Translate/Command.lean:42:9: unsupported derive handler algebra[algebra] R»
#align universal_enveloping_algebra UniversalEnvelopingAlgebra

namespace UniversalEnvelopingAlgebra

/-- The quotient map from the tensor algebra to the universal enveloping algebra as a morphism of
associative algebras. -/
def mkAlgHom : TensorAlgebra R L →ₐ[R] UniversalEnvelopingAlgebra R L :=
  RingQuot.mkAlgHom R (Rel R L)
#align universal_enveloping_algebra.mk_alg_hom UniversalEnvelopingAlgebra.mkAlgHom

variable {L}

/-- The natural Lie algebra morphism from a Lie algebra to its universal enveloping algebra. -/
def ι : L →ₗ⁅R⁆ UniversalEnvelopingAlgebra R L :=
  { (mkAlgHom R L).toLinearMap.comp ιₜ with
    map_lie' := fun x y =>
      by
      suffices mk_alg_hom R L (ιₜ ⁅x, y⁆ + ιₜ y * ιₜ x) = mk_alg_hom R L (ιₜ x * ιₜ y)
        by
        rw [AlgHom.map_mul] at this
        simp [LieRing.of_associative_ring_bracket, ← this]
      exact RingQuot.mkAlgHom_rel _ (rel.lie_compat x y) }
#align universal_enveloping_algebra.ι UniversalEnvelopingAlgebra.ι

variable {A : Type u₃} [Ring A] [Algebra R A] (f : L →ₗ⁅R⁆ A)

/-- The universal property of the universal enveloping algebra: Lie algebra morphisms into
associative algebras lift to associative algebra morphisms from the universal enveloping algebra. -/
def lift : (L →ₗ⁅R⁆ A) ≃ (UniversalEnvelopingAlgebra R L →ₐ[R] A)
    where
  toFun f :=
    RingQuot.liftAlgHom R
      ⟨TensorAlgebra.lift R (f : L →ₗ[R] A), by
        intro a b h; induction' h with x y
        simp only [LieRing.of_associative_ring_bracket, map_add, TensorAlgebra.lift_ι_apply,
          LieHom.coe_to_linearMap, LieHom.map_lie, map_mul, sub_add_cancel]⟩
  invFun F := (F : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R)
  left_inv f := by
    ext
    simp only [ι, mk_alg_hom, TensorAlgebra.lift_ι_apply, LieHom.coe_to_linearMap,
      LinearMap.to_fun_eq_coe, LinearMap.coe_comp, LieHom.coe_comp, AlgHom.coe_to_lieHom,
      LieHom.coe_mk, Function.comp_apply, AlgHom.toLinearMap_apply,
      RingQuot.liftAlgHom_mkAlgHom_apply]
  right_inv F := by
    ext
    simp only [ι, mk_alg_hom, TensorAlgebra.lift_ι_apply, LieHom.coe_to_linearMap,
      LinearMap.to_fun_eq_coe, LinearMap.coe_comp, LieHom.coe_linearMap_comp,
      AlgHom.comp_toLinearMap, Function.comp_apply, AlgHom.toLinearMap_apply,
      RingQuot.liftAlgHom_mkAlgHom_apply, AlgHom.coe_to_lieHom, LieHom.coe_mk]
#align universal_enveloping_algebra.lift UniversalEnvelopingAlgebra.lift

@[simp]
theorem lift_symm_apply (F : UniversalEnvelopingAlgebra R L →ₐ[R] A) :
    (lift R).symm F = (F : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R) :=
  rfl
#align universal_enveloping_algebra.lift_symm_apply UniversalEnvelopingAlgebra.lift_symm_apply

@[simp]
theorem ι_comp_lift : lift R f ∘ ι R = f :=
  funext <| LieHom.ext_iff.mp <| (lift R).symm_apply_apply f
#align universal_enveloping_algebra.ι_comp_lift UniversalEnvelopingAlgebra.ι_comp_lift

@[simp]
theorem lift_ι_apply (x : L) : lift R f (ι R x) = f x := by
  rw [← Function.comp_apply (lift R f) (ι R) x, ι_comp_lift]
#align universal_enveloping_algebra.lift_ι_apply UniversalEnvelopingAlgebra.lift_ι_apply

theorem lift_unique (g : UniversalEnvelopingAlgebra R L →ₐ[R] A) : g ∘ ι R = f ↔ g = lift R f :=
  by
  refine' Iff.trans _ (lift R).symm_apply_eq
  constructor <;>
    · intro h
      ext
      simp [← h]
#align universal_enveloping_algebra.lift_unique UniversalEnvelopingAlgebra.lift_unique

/-- See note [partially-applied ext lemmas]. -/
@[ext]
theorem hom_ext {g₁ g₂ : UniversalEnvelopingAlgebra R L →ₐ[R] A}
    (h :
      (g₁ : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R) =
        (g₂ : UniversalEnvelopingAlgebra R L →ₗ⁅R⁆ A).comp (ι R)) :
    g₁ = g₂ :=
  have h' : (lift R).symm g₁ = (lift R).symm g₂ := by ext; simp [h]
  (lift R).symm.Injective h'
#align universal_enveloping_algebra.hom_ext UniversalEnvelopingAlgebra.hom_ext

end UniversalEnvelopingAlgebra

