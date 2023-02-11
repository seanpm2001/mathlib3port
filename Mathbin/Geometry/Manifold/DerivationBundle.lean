/-
Copyright © 2020 Nicolò Cavalleri. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Nicolò Cavalleri

! This file was ported from Lean 3 source module geometry.manifold.derivation_bundle
! leanprover-community/mathlib commit dc6c365e751e34d100e80fe6e314c3c3e0fd2988
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Geometry.Manifold.Algebra.SmoothFunctions
import Mathbin.RingTheory.Derivation

/-!

# Derivation bundle

In this file we define the derivations at a point of a manifold on the algebra of smooth fuctions.
Moreover, we define the differential of a function in terms of derivations.

The content of this file is not meant to be regarded as an alternative definition to the current
tangent bundle but rather as a purely algebraic theory that provides a purely algebraic definition
of the Lie algebra for a Lie group.

-/


variable (𝕜 : Type _) [NontriviallyNormedField 𝕜] {E : Type _} [NormedAddCommGroup E]
  [NormedSpace 𝕜 E] {H : Type _} [TopologicalSpace H] (I : ModelWithCorners 𝕜 E H) (M : Type _)
  [TopologicalSpace M] [ChartedSpace H M] (n : ℕ∞)

open Manifold

-- the following two instances prevent poorly understood type class inference timeout problems
instance smoothFunctionsAlgebra : Algebra 𝕜 C^∞⟮I, M; 𝕜⟯ := by infer_instance
#align smooth_functions_algebra smoothFunctionsAlgebra

instance smooth_functions_tower : IsScalarTower 𝕜 C^∞⟮I, M; 𝕜⟯ C^∞⟮I, M; 𝕜⟯ := by infer_instance
#align smooth_functions_tower smooth_functions_tower

/-- Type synonym, introduced to put a different `has_smul` action on `C^n⟮I, M; 𝕜⟯`
which is defined as `f • r = f(x) * r`. -/
@[nolint unused_arguments]
def PointedSmoothMap (x : M) :=
  C^n⟮I, M; 𝕜⟯
#align pointed_smooth_map PointedSmoothMap

-- mathport name: pointed_smooth_map
scoped[Derivation] notation "C^" n "⟮" I ", " M "; " 𝕜 "⟯⟨" x "⟩" => PointedSmoothMap 𝕜 I M n x

variable {𝕜 M}

namespace PointedSmoothMap

instance {x : M} : CoeFun C^∞⟮I, M; 𝕜⟯⟨x⟩ fun _ => M → 𝕜 :=
  ContMdiffMap.hasCoeToFun

instance {x : M} : CommRing C^∞⟮I, M; 𝕜⟯⟨x⟩ :=
  SmoothMap.commRing

instance {x : M} : Algebra 𝕜 C^∞⟮I, M; 𝕜⟯⟨x⟩ :=
  SmoothMap.algebra

instance {x : M} : Inhabited C^∞⟮I, M; 𝕜⟯⟨x⟩ :=
  ⟨0⟩

instance {x : M} : Algebra C^∞⟮I, M; 𝕜⟯⟨x⟩ C^∞⟮I, M; 𝕜⟯ :=
  Algebra.id C^∞⟮I, M; 𝕜⟯

instance {x : M} : IsScalarTower 𝕜 C^∞⟮I, M; 𝕜⟯⟨x⟩ C^∞⟮I, M; 𝕜⟯ :=
  IsScalarTower.right

variable {I}

/-- `smooth_map.eval_ring_hom` gives rise to an algebra structure of `C^∞⟮I, M; 𝕜⟯` on `𝕜`. -/
instance evalAlgebra {x : M} : Algebra C^∞⟮I, M; 𝕜⟯⟨x⟩ 𝕜 :=
  (SmoothMap.evalRingHom x : C^∞⟮I, M; 𝕜⟯⟨x⟩ →+* 𝕜).toAlgebra
#align pointed_smooth_map.eval_algebra PointedSmoothMap.evalAlgebra

/-- With the `eval_algebra` algebra structure evaluation is actually an algebra morphism. -/
def eval (x : M) : C^∞⟮I, M; 𝕜⟯ →ₐ[C^∞⟮I, M; 𝕜⟯⟨x⟩] 𝕜 :=
  Algebra.ofId C^∞⟮I, M; 𝕜⟯⟨x⟩ 𝕜
#align pointed_smooth_map.eval PointedSmoothMap.eval

theorem smul_def (x : M) (f : C^∞⟮I, M; 𝕜⟯⟨x⟩) (k : 𝕜) : f • k = f x * k :=
  rfl
#align pointed_smooth_map.smul_def PointedSmoothMap.smul_def

instance (x : M) : IsScalarTower 𝕜 C^∞⟮I, M; 𝕜⟯⟨x⟩ 𝕜
    where smul_assoc k f h := by
    simp only [smul_def, Algebra.id.smul_eq_mul, SmoothMap.coe_smul, Pi.smul_apply, mul_assoc]

end PointedSmoothMap

open Derivation

/-- The derivations at a point of a manifold. Some regard this as a possible definition of the
tangent space -/
@[reducible]
def PointDerivation (x : M) :=
  Derivation 𝕜 C^∞⟮I, M; 𝕜⟯⟨x⟩ 𝕜
#align point_derivation PointDerivation

section

variable (I) {M} (X Y : Derivation 𝕜 C^∞⟮I, M; 𝕜⟯ C^∞⟮I, M; 𝕜⟯) (f g : C^∞⟮I, M; 𝕜⟯) (r : 𝕜)

/-- Evaluation at a point gives rise to a `C^∞⟮I, M; 𝕜⟯`-linear map between `C^∞⟮I, M; 𝕜⟯` and `𝕜`.
 -/
def SmoothFunction.evalAt (x : M) : C^∞⟮I, M; 𝕜⟯ →ₗ[C^∞⟮I, M; 𝕜⟯⟨x⟩] 𝕜 :=
  (PointedSmoothMap.eval x).toLinearMap
#align smooth_function.eval_at SmoothFunction.evalAt

namespace Derivation

variable {I}

/-- The evaluation at a point as a linear map. -/
def evalAt (x : M) : Derivation 𝕜 C^∞⟮I, M; 𝕜⟯ C^∞⟮I, M; 𝕜⟯ →ₗ[𝕜] PointDerivation I x :=
  (SmoothFunction.evalAt I x).compDer
#align derivation.eval_at Derivation.evalAt

theorem evalAt_apply (x : M) : evalAt x X f = (X f) x :=
  rfl
#align derivation.eval_at_apply Derivation.evalAt_apply

end Derivation

variable {I} {E' : Type _} [NormedAddCommGroup E'] [NormedSpace 𝕜 E'] {H' : Type _}
  [TopologicalSpace H'] {I' : ModelWithCorners 𝕜 E' H'} {M' : Type _} [TopologicalSpace M']
  [ChartedSpace H' M']

/-- The heterogeneous differential as a linear map. Instead of taking a function as an argument this
differential takes `h : f x = y`. It is particularly handy to deal with situations where the points
on where it has to be evaluated are equal but not definitionally equal. -/
def hfdifferential {f : C^∞⟮I, M; I', M'⟯} {x : M} {y : M'} (h : f x = y) :
    PointDerivation I x →ₗ[𝕜] PointDerivation I' y
    where
  toFun v :=
    Derivation.mk'
      { toFun := fun g => v (g.comp f)
        map_add' := fun g g' => by rw [SmoothMap.add_comp, Derivation.map_add]
        map_smul' := fun k g => by
          simp only [SmoothMap.smul_comp, Derivation.map_smul, RingHom.id_apply] }
      fun g g' => by
      simp only [Derivation.leibniz, SmoothMap.mul_comp, LinearMap.coe_mk,
        PointedSmoothMap.smul_def, ContMdiffMap.comp_apply, h]
  map_smul' k v := rfl
  map_add' v w := rfl
#align hfdifferential hfdifferential

/-- The homogeneous differential as a linear map. -/
def fdifferential (f : C^∞⟮I, M; I', M'⟯) (x : M) :
    PointDerivation I x →ₗ[𝕜] PointDerivation I' (f x) :=
  hfdifferential (rfl : f x = f x)
#align fdifferential fdifferential

-- mathport name: fdifferential
-- Standard notation for the differential. The abbreviation is `MId`.
scoped[Manifold] notation "𝒅" => fdifferential

-- mathport name: hfdifferential
-- Standard notation for the differential. The abbreviation is `MId`.
scoped[Manifold] notation "𝒅ₕ" => hfdifferential

@[simp]
theorem apply_fdifferential (f : C^∞⟮I, M; I', M'⟯) {x : M} (v : PointDerivation I x)
    (g : C^∞⟮I', M'; 𝕜⟯) : 𝒅 f x v g = v (g.comp f) :=
  rfl
#align apply_fdifferential apply_fdifferential

@[simp]
theorem apply_hfdifferential {f : C^∞⟮I, M; I', M'⟯} {x : M} {y : M'} (h : f x = y)
    (v : PointDerivation I x) (g : C^∞⟮I', M'; 𝕜⟯) : 𝒅ₕ h v g = 𝒅 f x v g :=
  rfl
#align apply_hfdifferential apply_hfdifferential

variable {E'' : Type _} [NormedAddCommGroup E''] [NormedSpace 𝕜 E''] {H'' : Type _}
  [TopologicalSpace H''] {I'' : ModelWithCorners 𝕜 E'' H''} {M'' : Type _} [TopologicalSpace M'']
  [ChartedSpace H'' M'']

@[simp]
theorem fdifferential_comp (g : C^∞⟮I', M'; I'', M''⟯) (f : C^∞⟮I, M; I', M'⟯) (x : M) :
    𝒅 (g.comp f) x = (𝒅 g (f x)).comp (𝒅 f x) :=
  rfl
#align fdifferential_comp fdifferential_comp

end

