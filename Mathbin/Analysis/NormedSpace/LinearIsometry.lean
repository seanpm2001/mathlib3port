/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov, Frédéric Dupuis, Heather Macbeth

! This file was ported from Lean 3 source module analysis.normed_space.linear_isometry
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Group.Basic
import Mathbin.Topology.Algebra.Module.Basic
import Mathbin.LinearAlgebra.Basis

/-!
# (Semi-)linear isometries

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define `linear_isometry σ₁₂ E E₂` (notation: `E →ₛₗᵢ[σ₁₂] E₂`) to be a semilinear
isometric embedding of `E` into `E₂` and `linear_isometry_equiv` (notation: `E ≃ₛₗᵢ[σ₁₂] E₂`) to be
a semilinear isometric equivalence between `E` and `E₂`.  The notation for the associated purely
linear concepts is `E →ₗᵢ[R] E₂`, `E ≃ₗᵢ[R] E₂`, and `E →ₗᵢ⋆[R] E₂`, `E ≃ₗᵢ⋆[R] E₂` for
the star-linear versions.

We also prove some trivial lemmas and provide convenience constructors.

Since a lot of elementary properties don't require `‖x‖ = 0 → x = 0` we start setting up the
theory for `seminormed_add_comm_group` and we specialize to `normed_add_comm_group` when needed.
-/


open Function Set

variable {R R₂ R₃ R₄ E E₂ E₃ E₄ F 𝓕 : Type _} [Semiring R] [Semiring R₂] [Semiring R₃] [Semiring R₄]
  {σ₁₂ : R →+* R₂} {σ₂₁ : R₂ →+* R} {σ₁₃ : R →+* R₃} {σ₃₁ : R₃ →+* R} {σ₁₄ : R →+* R₄}
  {σ₄₁ : R₄ →+* R} {σ₂₃ : R₂ →+* R₃} {σ₃₂ : R₃ →+* R₂} {σ₂₄ : R₂ →+* R₄} {σ₄₂ : R₄ →+* R₂}
  {σ₃₄ : R₃ →+* R₄} {σ₄₃ : R₄ →+* R₃} [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂]
  [RingHomInvPair σ₁₃ σ₃₁] [RingHomInvPair σ₃₁ σ₁₃] [RingHomInvPair σ₂₃ σ₃₂]
  [RingHomInvPair σ₃₂ σ₂₃] [RingHomInvPair σ₁₄ σ₄₁] [RingHomInvPair σ₄₁ σ₁₄]
  [RingHomInvPair σ₂₄ σ₄₂] [RingHomInvPair σ₄₂ σ₂₄] [RingHomInvPair σ₃₄ σ₄₃]
  [RingHomInvPair σ₄₃ σ₃₄] [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃] [RingHomCompTriple σ₁₂ σ₂₄ σ₁₄]
  [RingHomCompTriple σ₂₃ σ₃₄ σ₂₄] [RingHomCompTriple σ₁₃ σ₃₄ σ₁₄] [RingHomCompTriple σ₃₂ σ₂₁ σ₃₁]
  [RingHomCompTriple σ₄₂ σ₂₁ σ₄₁] [RingHomCompTriple σ₄₃ σ₃₂ σ₄₂] [RingHomCompTriple σ₄₃ σ₃₁ σ₄₁]
  [SeminormedAddCommGroup E] [SeminormedAddCommGroup E₂] [SeminormedAddCommGroup E₃]
  [SeminormedAddCommGroup E₄] [Module R E] [Module R₂ E₂] [Module R₃ E₃] [Module R₄ E₄]
  [NormedAddCommGroup F] [Module R F]

#print LinearIsometry /-
/-- A `σ₁₂`-semilinear isometric embedding of a normed `R`-module into an `R₂`-module. -/
structure LinearIsometry (σ₁₂ : R →+* R₂) (E E₂ : Type _) [SeminormedAddCommGroup E]
    [SeminormedAddCommGroup E₂] [Module R E] [Module R₂ E₂] extends E →ₛₗ[σ₁₂] E₂ where
  norm_map' : ∀ x, ‖to_linear_map x‖ = ‖x‖
#align linear_isometry LinearIsometry
-/

notation:25 E " →ₛₗᵢ[" σ₁₂:25 "] " E₂:0 => LinearIsometry σ₁₂ E E₂

notation:25 E " →ₗᵢ[" R:25 "] " E₂:0 => LinearIsometry (RingHom.id R) E E₂

notation:25 E " →ₗᵢ⋆[" R:25 "] " E₂:0 => LinearIsometry (starRingEnd R) E E₂

#print SemilinearIsometryClass /-
/-- `semilinear_isometry_class F σ E E₂` asserts `F` is a type of bundled `σ`-semilinear isometries
`E → E₂`.

See also `linear_isometry_class F R E E₂` for the case where `σ` is the identity map on `R`.

A map `f` between an `R`-module and an `S`-module over a ring homomorphism `σ : R →+* S`
is semilinear if it satisfies the two properties `f (x + y) = f x + f y` and
`f (c • x) = (σ c) • f x`. -/
class SemilinearIsometryClass (𝓕 : Type _) {R R₂ : outParam (Type _)} [Semiring R] [Semiring R₂]
    (σ₁₂ : outParam <| R →+* R₂) (E E₂ : outParam (Type _)) [SeminormedAddCommGroup E]
    [SeminormedAddCommGroup E₂] [Module R E] [Module R₂ E₂] extends
    SemilinearMapClass 𝓕 σ₁₂ E E₂ where
  norm_map : ∀ (f : 𝓕) (x : E), ‖f x‖ = ‖x‖
#align semilinear_isometry_class SemilinearIsometryClass
-/

#print LinearIsometryClass /-
/-- `linear_isometry_class F R E E₂` asserts `F` is a type of bundled `R`-linear isometries
`M → M₂`.

This is an abbreviation for `semilinear_isometry_class F (ring_hom.id R) E E₂`.
-/
abbrev LinearIsometryClass (𝓕 : Type _) (R E E₂ : outParam (Type _)) [Semiring R]
    [SeminormedAddCommGroup E] [SeminormedAddCommGroup E₂] [Module R E] [Module R E₂] :=
  SemilinearIsometryClass 𝓕 (RingHom.id R) E E₂
#align linear_isometry_class LinearIsometryClass
-/

namespace SemilinearIsometryClass

#print SemilinearIsometryClass.isometry /-
protected theorem isometry [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) : Isometry f :=
  AddMonoidHomClass.isometry_of_norm _ (norm_map _)
#align semilinear_isometry_class.isometry SemilinearIsometryClass.isometry
-/

#print SemilinearIsometryClass.continuous /-
@[continuity]
protected theorem continuous [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) : Continuous f :=
  (SemilinearIsometryClass.isometry f).Continuous
#align semilinear_isometry_class.continuous SemilinearIsometryClass.continuous
-/

#print SemilinearIsometryClass.nnnorm_map /-
@[simp]
theorem nnnorm_map [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) (x : E) : ‖f x‖₊ = ‖x‖₊ :=
  NNReal.eq <| norm_map f x
#align semilinear_isometry_class.nnnorm_map SemilinearIsometryClass.nnnorm_map
-/

#print SemilinearIsometryClass.lipschitz /-
protected theorem lipschitz [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) : LipschitzWith 1 f :=
  (SemilinearIsometryClass.isometry f).lipschitz
#align semilinear_isometry_class.lipschitz SemilinearIsometryClass.lipschitz
-/

#print SemilinearIsometryClass.antilipschitz /-
protected theorem antilipschitz [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) :
    AntilipschitzWith 1 f :=
  (SemilinearIsometryClass.isometry f).antilipschitz
#align semilinear_isometry_class.antilipschitz SemilinearIsometryClass.antilipschitz
-/

#print SemilinearIsometryClass.ediam_image /-
theorem ediam_image [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) (s : Set E) :
    EMetric.diam (f '' s) = EMetric.diam s :=
  (SemilinearIsometryClass.isometry f).ediam_image s
#align semilinear_isometry_class.ediam_image SemilinearIsometryClass.ediam_image
-/

#print SemilinearIsometryClass.ediam_range /-
theorem ediam_range [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) :
    EMetric.diam (range f) = EMetric.diam (univ : Set E) :=
  (SemilinearIsometryClass.isometry f).ediam_range
#align semilinear_isometry_class.ediam_range SemilinearIsometryClass.ediam_range
-/

#print SemilinearIsometryClass.diam_image /-
theorem diam_image [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) (s : Set E) :
    Metric.diam (f '' s) = Metric.diam s :=
  (SemilinearIsometryClass.isometry f).diam_image s
#align semilinear_isometry_class.diam_image SemilinearIsometryClass.diam_image
-/

#print SemilinearIsometryClass.diam_range /-
theorem diam_range [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) :
    Metric.diam (range f) = Metric.diam (univ : Set E) :=
  (SemilinearIsometryClass.isometry f).diam_range
#align semilinear_isometry_class.diam_range SemilinearIsometryClass.diam_range
-/

instance (priority := 100) [s : SemilinearIsometryClass 𝓕 σ₁₂ E E₂] :
    ContinuousSemilinearMapClass 𝓕 σ₁₂ E E₂ :=
  { s with map_continuous := SemilinearIsometryClass.continuous }

end SemilinearIsometryClass

namespace LinearIsometry

variable (f : E →ₛₗᵢ[σ₁₂] E₂) (f₁ : F →ₛₗᵢ[σ₁₂] E₂)

#print LinearIsometry.toLinearMap_injective /-
theorem toLinearMap_injective : Injective (toLinearMap : (E →ₛₗᵢ[σ₁₂] E₂) → E →ₛₗ[σ₁₂] E₂)
  | ⟨f, _⟩, ⟨g, _⟩, rfl => rfl
#align linear_isometry.to_linear_map_injective LinearIsometry.toLinearMap_injective
-/

#print LinearIsometry.toLinearMap_inj /-
@[simp]
theorem toLinearMap_inj {f g : E →ₛₗᵢ[σ₁₂] E₂} : f.toLinearMap = g.toLinearMap ↔ f = g :=
  toLinearMap_injective.eq_iff
#align linear_isometry.to_linear_map_inj LinearIsometry.toLinearMap_inj
-/

instance : SemilinearIsometryClass (E →ₛₗᵢ[σ₁₂] E₂) σ₁₂ E E₂
    where
  coe f := f.toFun
  coe_injective' f g h := toLinearMap_injective (FunLike.coe_injective h)
  map_add f := map_add f.toLinearMap
  map_smulₛₗ f := map_smulₛₗ f.toLinearMap
  norm_map f := f.norm_map'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly.
-/
instance : CoeFun (E →ₛₗᵢ[σ₁₂] E₂) fun _ => E → E₂ :=
  ⟨fun f => f.toFun⟩

#print LinearIsometry.coe_toLinearMap /-
@[simp]
theorem coe_toLinearMap : ⇑f.toLinearMap = f :=
  rfl
#align linear_isometry.coe_to_linear_map LinearIsometry.coe_toLinearMap
-/

#print LinearIsometry.coe_mk /-
@[simp]
theorem coe_mk (f : E →ₛₗ[σ₁₂] E₂) (hf) : ⇑(mk f hf) = f :=
  rfl
#align linear_isometry.coe_mk LinearIsometry.coe_mk
-/

#print LinearIsometry.coe_injective /-
theorem coe_injective : @Injective (E →ₛₗᵢ[σ₁₂] E₂) (E → E₂) coeFn :=
  FunLike.coe_injective
#align linear_isometry.coe_injective LinearIsometry.coe_injective
-/

#print LinearIsometry.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (σ₁₂ : R →+* R₂) (E E₂ : Type _) [SeminormedAddCommGroup E]
    [SeminormedAddCommGroup E₂] [Module R E] [Module R₂ E₂] (h : E →ₛₗᵢ[σ₁₂] E₂) : E → E₂ :=
  h
#align linear_isometry.simps.apply LinearIsometry.Simps.apply
-/

initialize_simps_projections LinearIsometry (to_linear_map_to_fun → apply)

#print LinearIsometry.ext /-
@[ext]
theorem ext {f g : E →ₛₗᵢ[σ₁₂] E₂} (h : ∀ x, f x = g x) : f = g :=
  coe_injective <| funext h
#align linear_isometry.ext LinearIsometry.ext
-/

#print LinearIsometry.congr_arg /-
protected theorem congr_arg [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] {f : 𝓕} :
    ∀ {x x' : E}, x = x' → f x = f x'
  | _, _, rfl => rfl
#align linear_isometry.congr_arg LinearIsometry.congr_arg
-/

#print LinearIsometry.congr_fun /-
protected theorem congr_fun [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] {f g : 𝓕} (h : f = g) (x : E) :
    f x = g x :=
  h ▸ rfl
#align linear_isometry.congr_fun LinearIsometry.congr_fun
-/

#print LinearIsometry.map_zero /-
@[simp]
protected theorem map_zero : f 0 = 0 :=
  f.toLinearMap.map_zero
#align linear_isometry.map_zero LinearIsometry.map_zero
-/

#print LinearIsometry.map_add /-
@[simp]
protected theorem map_add (x y : E) : f (x + y) = f x + f y :=
  f.toLinearMap.map_add x y
#align linear_isometry.map_add LinearIsometry.map_add
-/

#print LinearIsometry.map_neg /-
@[simp]
protected theorem map_neg (x : E) : f (-x) = -f x :=
  f.toLinearMap.map_neg x
#align linear_isometry.map_neg LinearIsometry.map_neg
-/

#print LinearIsometry.map_sub /-
@[simp]
protected theorem map_sub (x y : E) : f (x - y) = f x - f y :=
  f.toLinearMap.map_sub x y
#align linear_isometry.map_sub LinearIsometry.map_sub
-/

#print LinearIsometry.map_smulₛₗ /-
@[simp]
protected theorem map_smulₛₗ (c : R) (x : E) : f (c • x) = σ₁₂ c • f x :=
  f.toLinearMap.map_smulₛₗ c x
#align linear_isometry.map_smulₛₗ LinearIsometry.map_smulₛₗ
-/

#print LinearIsometry.map_smul /-
@[simp]
protected theorem map_smul [Module R E₂] (f : E →ₗᵢ[R] E₂) (c : R) (x : E) : f (c • x) = c • f x :=
  f.toLinearMap.map_smul c x
#align linear_isometry.map_smul LinearIsometry.map_smul
-/

#print LinearIsometry.norm_map /-
@[simp]
theorem norm_map (x : E) : ‖f x‖ = ‖x‖ :=
  SemilinearIsometryClass.norm_map f x
#align linear_isometry.norm_map LinearIsometry.norm_map
-/

#print LinearIsometry.nnnorm_map /-
@[simp]
theorem nnnorm_map (x : E) : ‖f x‖₊ = ‖x‖₊ :=
  NNReal.eq <| norm_map f x
#align linear_isometry.nnnorm_map LinearIsometry.nnnorm_map
-/

#print LinearIsometry.isometry /-
protected theorem isometry : Isometry f :=
  AddMonoidHomClass.isometry_of_norm _ (norm_map _)
#align linear_isometry.isometry LinearIsometry.isometry
-/

#print LinearIsometry.isComplete_image_iff /-
@[simp]
theorem isComplete_image_iff [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) {s : Set E} :
    IsComplete (f '' s) ↔ IsComplete s :=
  isComplete_image_iff (SemilinearIsometryClass.isometry f).UniformInducing
#align linear_isometry.is_complete_image_iff LinearIsometry.isComplete_image_iff
-/

#print LinearIsometry.isComplete_map_iff /-
theorem isComplete_map_iff [RingHomSurjective σ₁₂] {p : Submodule R E} :
    IsComplete (p.map f.toLinearMap : Set E₂) ↔ IsComplete (p : Set E) :=
  f.isComplete_image_iff
#align linear_isometry.is_complete_map_iff LinearIsometry.isComplete_map_iff
-/

#print LinearIsometry.isComplete_map_iff' /-
theorem isComplete_map_iff' [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) [RingHomSurjective σ₁₂]
    {p : Submodule R E} : IsComplete (p.map f : Set E₂) ↔ IsComplete (p : Set E) :=
  isComplete_image_iff f
#align linear_isometry.is_complete_map_iff' LinearIsometry.isComplete_map_iff'
-/

#print LinearIsometry.completeSpace_map /-
instance completeSpace_map [SemilinearIsometryClass 𝓕 σ₁₂ E E₂] (f : 𝓕) [RingHomSurjective σ₁₂]
    (p : Submodule R E) [CompleteSpace p] : CompleteSpace (p.map f) :=
  ((isComplete_map_iff' f).2 <| completeSpace_coe_iff_isComplete.1 ‹_›).completeSpace_coe
#align linear_isometry.complete_space_map LinearIsometry.completeSpace_map
-/

#print LinearIsometry.completeSpace_map' /-
instance completeSpace_map' [RingHomSurjective σ₁₂] (p : Submodule R E) [CompleteSpace p] :
    CompleteSpace (p.map f.toLinearMap) :=
  (f.isComplete_map_iff.2 <| completeSpace_coe_iff_isComplete.1 ‹_›).completeSpace_coe
#align linear_isometry.complete_space_map' LinearIsometry.completeSpace_map'
-/

#print LinearIsometry.dist_map /-
@[simp]
theorem dist_map (x y : E) : dist (f x) (f y) = dist x y :=
  f.Isometry.dist_eq x y
#align linear_isometry.dist_map LinearIsometry.dist_map
-/

#print LinearIsometry.edist_map /-
@[simp]
theorem edist_map (x y : E) : edist (f x) (f y) = edist x y :=
  f.Isometry.edist_eq x y
#align linear_isometry.edist_map LinearIsometry.edist_map
-/

#print LinearIsometry.injective /-
protected theorem injective : Injective f₁ :=
  Isometry.injective (LinearIsometry.isometry f₁)
#align linear_isometry.injective LinearIsometry.injective
-/

#print LinearIsometry.map_eq_iff /-
@[simp]
theorem map_eq_iff {x y : F} : f₁ x = f₁ y ↔ x = y :=
  f₁.Injective.eq_iff
#align linear_isometry.map_eq_iff LinearIsometry.map_eq_iff
-/

#print LinearIsometry.map_ne /-
theorem map_ne {x y : F} (h : x ≠ y) : f₁ x ≠ f₁ y :=
  f₁.Injective.Ne h
#align linear_isometry.map_ne LinearIsometry.map_ne
-/

#print LinearIsometry.lipschitz /-
protected theorem lipschitz : LipschitzWith 1 f :=
  f.Isometry.lipschitz
#align linear_isometry.lipschitz LinearIsometry.lipschitz
-/

#print LinearIsometry.antilipschitz /-
protected theorem antilipschitz : AntilipschitzWith 1 f :=
  f.Isometry.antilipschitz
#align linear_isometry.antilipschitz LinearIsometry.antilipschitz
-/

#print LinearIsometry.continuous /-
@[continuity]
protected theorem continuous : Continuous f :=
  f.Isometry.Continuous
#align linear_isometry.continuous LinearIsometry.continuous
-/

#print LinearIsometry.preimage_ball /-
@[simp]
theorem preimage_ball (x : E) (r : ℝ) : f ⁻¹' Metric.ball (f x) r = Metric.ball x r :=
  f.Isometry.preimage_ball x r
#align linear_isometry.preimage_ball LinearIsometry.preimage_ball
-/

#print LinearIsometry.preimage_sphere /-
@[simp]
theorem preimage_sphere (x : E) (r : ℝ) : f ⁻¹' Metric.sphere (f x) r = Metric.sphere x r :=
  f.Isometry.preimage_sphere x r
#align linear_isometry.preimage_sphere LinearIsometry.preimage_sphere
-/

#print LinearIsometry.preimage_closedBall /-
@[simp]
theorem preimage_closedBall (x : E) (r : ℝ) :
    f ⁻¹' Metric.closedBall (f x) r = Metric.closedBall x r :=
  f.Isometry.preimage_closedBall x r
#align linear_isometry.preimage_closed_ball LinearIsometry.preimage_closedBall
-/

#print LinearIsometry.ediam_image /-
theorem ediam_image (s : Set E) : EMetric.diam (f '' s) = EMetric.diam s :=
  f.Isometry.ediam_image s
#align linear_isometry.ediam_image LinearIsometry.ediam_image
-/

#print LinearIsometry.ediam_range /-
theorem ediam_range : EMetric.diam (range f) = EMetric.diam (univ : Set E) :=
  f.Isometry.ediam_range
#align linear_isometry.ediam_range LinearIsometry.ediam_range
-/

#print LinearIsometry.diam_image /-
theorem diam_image (s : Set E) : Metric.diam (f '' s) = Metric.diam s :=
  Isometry.diam_image (LinearIsometry.isometry f) s
#align linear_isometry.diam_image LinearIsometry.diam_image
-/

#print LinearIsometry.diam_range /-
theorem diam_range : Metric.diam (range f) = Metric.diam (univ : Set E) :=
  Isometry.diam_range (LinearIsometry.isometry f)
#align linear_isometry.diam_range LinearIsometry.diam_range
-/

#print LinearIsometry.toContinuousLinearMap /-
/-- Interpret a linear isometry as a continuous linear map. -/
def toContinuousLinearMap : E →SL[σ₁₂] E₂ :=
  ⟨f.toLinearMap, f.Continuous⟩
#align linear_isometry.to_continuous_linear_map LinearIsometry.toContinuousLinearMap
-/

#print LinearIsometry.toContinuousLinearMap_injective /-
theorem toContinuousLinearMap_injective :
    Function.Injective (toContinuousLinearMap : _ → E →SL[σ₁₂] E₂) := fun x y h =>
  coe_injective (congr_arg _ h : ⇑x.toContinuousLinearMap = _)
#align linear_isometry.to_continuous_linear_map_injective LinearIsometry.toContinuousLinearMap_injective
-/

#print LinearIsometry.toContinuousLinearMap_inj /-
@[simp]
theorem toContinuousLinearMap_inj {f g : E →ₛₗᵢ[σ₁₂] E₂} :
    f.toContinuousLinearMap = g.toContinuousLinearMap ↔ f = g :=
  toContinuousLinearMap_injective.eq_iff
#align linear_isometry.to_continuous_linear_map_inj LinearIsometry.toContinuousLinearMap_inj
-/

#print LinearIsometry.coe_toContinuousLinearMap /-
@[simp]
theorem coe_toContinuousLinearMap : ⇑f.toContinuousLinearMap = f :=
  rfl
#align linear_isometry.coe_to_continuous_linear_map LinearIsometry.coe_toContinuousLinearMap
-/

#print LinearIsometry.comp_continuous_iff /-
@[simp]
theorem comp_continuous_iff {α : Type _} [TopologicalSpace α] {g : α → E} :
    Continuous (f ∘ g) ↔ Continuous g :=
  f.Isometry.comp_continuous_iff
#align linear_isometry.comp_continuous_iff LinearIsometry.comp_continuous_iff
-/

#print LinearIsometry.id /-
/-- The identity linear isometry. -/
def id : E →ₗᵢ[R] E :=
  ⟨LinearMap.id, fun x => rfl⟩
#align linear_isometry.id LinearIsometry.id
-/

#print LinearIsometry.coe_id /-
@[simp]
theorem coe_id : ((id : E →ₗᵢ[R] E) : E → E) = id :=
  rfl
#align linear_isometry.coe_id LinearIsometry.coe_id
-/

#print LinearIsometry.id_apply /-
@[simp]
theorem id_apply (x : E) : (id : E →ₗᵢ[R] E) x = x :=
  rfl
#align linear_isometry.id_apply LinearIsometry.id_apply
-/

#print LinearIsometry.id_toLinearMap /-
@[simp]
theorem id_toLinearMap : (id.toLinearMap : E →ₗ[R] E) = LinearMap.id :=
  rfl
#align linear_isometry.id_to_linear_map LinearIsometry.id_toLinearMap
-/

#print LinearIsometry.id_toContinuousLinearMap /-
@[simp]
theorem id_toContinuousLinearMap : id.toContinuousLinearMap = ContinuousLinearMap.id R E :=
  rfl
#align linear_isometry.id_to_continuous_linear_map LinearIsometry.id_toContinuousLinearMap
-/

instance : Inhabited (E →ₗᵢ[R] E) :=
  ⟨id⟩

#print LinearIsometry.comp /-
/-- Composition of linear isometries. -/
def comp (g : E₂ →ₛₗᵢ[σ₂₃] E₃) (f : E →ₛₗᵢ[σ₁₂] E₂) : E →ₛₗᵢ[σ₁₃] E₃ :=
  ⟨g.toLinearMap.comp f.toLinearMap, fun x => (norm_map g _).trans (norm_map f _)⟩
#align linear_isometry.comp LinearIsometry.comp
-/

#print LinearIsometry.coe_comp /-
@[simp]
theorem coe_comp (g : E₂ →ₛₗᵢ[σ₂₃] E₃) (f : E →ₛₗᵢ[σ₁₂] E₂) : ⇑(g.comp f) = g ∘ f :=
  rfl
#align linear_isometry.coe_comp LinearIsometry.coe_comp
-/

#print LinearIsometry.id_comp /-
@[simp]
theorem id_comp : (id : E₂ →ₗᵢ[R₂] E₂).comp f = f :=
  ext fun x => rfl
#align linear_isometry.id_comp LinearIsometry.id_comp
-/

#print LinearIsometry.comp_id /-
@[simp]
theorem comp_id : f.comp id = f :=
  ext fun x => rfl
#align linear_isometry.comp_id LinearIsometry.comp_id
-/

#print LinearIsometry.comp_assoc /-
theorem comp_assoc (f : E₃ →ₛₗᵢ[σ₃₄] E₄) (g : E₂ →ₛₗᵢ[σ₂₃] E₃) (h : E →ₛₗᵢ[σ₁₂] E₂) :
    (f.comp g).comp h = f.comp (g.comp h) :=
  rfl
#align linear_isometry.comp_assoc LinearIsometry.comp_assoc
-/

instance : Monoid (E →ₗᵢ[R] E) where
  one := id
  mul := comp
  mul_assoc := comp_assoc
  one_mul := id_comp
  mul_one := comp_id

#print LinearIsometry.coe_one /-
@[simp]
theorem coe_one : ((1 : E →ₗᵢ[R] E) : E → E) = id :=
  rfl
#align linear_isometry.coe_one LinearIsometry.coe_one
-/

#print LinearIsometry.coe_mul /-
@[simp]
theorem coe_mul (f g : E →ₗᵢ[R] E) : ⇑(f * g) = f ∘ g :=
  rfl
#align linear_isometry.coe_mul LinearIsometry.coe_mul
-/

#print LinearIsometry.one_def /-
theorem one_def : (1 : E →ₗᵢ[R] E) = id :=
  rfl
#align linear_isometry.one_def LinearIsometry.one_def
-/

#print LinearIsometry.mul_def /-
theorem mul_def (f g : E →ₗᵢ[R] E) : (f * g : E →ₗᵢ[R] E) = f.comp g :=
  rfl
#align linear_isometry.mul_def LinearIsometry.mul_def
-/

end LinearIsometry

#print LinearMap.toLinearIsometry /-
/-- Construct a `linear_isometry` from a `linear_map` satisfying `isometry`. -/
def LinearMap.toLinearIsometry (f : E →ₛₗ[σ₁₂] E₂) (hf : Isometry f) : E →ₛₗᵢ[σ₁₂] E₂ :=
  { f with
    norm_map' := by simp_rw [← dist_zero_right, ← f.map_zero]; exact fun x => hf.dist_eq x _ }
#align linear_map.to_linear_isometry LinearMap.toLinearIsometry
-/

namespace Submodule

variable {R' : Type _} [Ring R'] [Module R' E] (p : Submodule R' E)

#print Submodule.subtypeₗᵢ /-
/-- `submodule.subtype` as a `linear_isometry`. -/
def subtypeₗᵢ : p →ₗᵢ[R'] E :=
  ⟨p.Subtype, fun x => rfl⟩
#align submodule.subtypeₗᵢ Submodule.subtypeₗᵢ
-/

#print Submodule.coe_subtypeₗᵢ /-
@[simp]
theorem coe_subtypeₗᵢ : ⇑p.subtypeₗᵢ = p.Subtype :=
  rfl
#align submodule.coe_subtypeₗᵢ Submodule.coe_subtypeₗᵢ
-/

#print Submodule.subtypeₗᵢ_toLinearMap /-
@[simp]
theorem subtypeₗᵢ_toLinearMap : p.subtypeₗᵢ.toLinearMap = p.Subtype :=
  rfl
#align submodule.subtypeₗᵢ_to_linear_map Submodule.subtypeₗᵢ_toLinearMap
-/

#print Submodule.subtypeₗᵢ_toContinuousLinearMap /-
@[simp]
theorem subtypeₗᵢ_toContinuousLinearMap : p.subtypeₗᵢ.toContinuousLinearMap = p.subtypeL :=
  rfl
#align submodule.subtypeₗᵢ_to_continuous_linear_map Submodule.subtypeₗᵢ_toContinuousLinearMap
-/

end Submodule

#print LinearIsometryEquiv /-
/-- A semilinear isometric equivalence between two normed vector spaces. -/
structure LinearIsometryEquiv (σ₁₂ : R →+* R₂) {σ₂₁ : R₂ →+* R} [RingHomInvPair σ₁₂ σ₂₁]
    [RingHomInvPair σ₂₁ σ₁₂] (E E₂ : Type _) [SeminormedAddCommGroup E] [SeminormedAddCommGroup E₂]
    [Module R E] [Module R₂ E₂] extends E ≃ₛₗ[σ₁₂] E₂ where
  norm_map' : ∀ x, ‖to_linear_equiv x‖ = ‖x‖
#align linear_isometry_equiv LinearIsometryEquiv
-/

notation:25 E " ≃ₛₗᵢ[" σ₁₂:25 "] " E₂:0 => LinearIsometryEquiv σ₁₂ E E₂

notation:25 E " ≃ₗᵢ[" R:25 "] " E₂:0 => LinearIsometryEquiv (RingHom.id R) E E₂

notation:25 E " ≃ₗᵢ⋆[" R:25 "] " E₂:0 => LinearIsometryEquiv (starRingEnd R) E E₂

#print SemilinearIsometryEquivClass /-
/-- `semilinear_isometry_equiv_class F σ E E₂` asserts `F` is a type of bundled `σ`-semilinear
isometric equivs `E → E₂`.

See also `linear_isometry_equiv_class F R E E₂` for the case where `σ` is the identity map on `R`.

A map `f` between an `R`-module and an `S`-module over a ring homomorphism `σ : R →+* S`
is semilinear if it satisfies the two properties `f (x + y) = f x + f y` and
`f (c • x) = (σ c) • f x`. -/
class SemilinearIsometryEquivClass (𝓕 : Type _) {R R₂ : outParam (Type _)} [Semiring R]
    [Semiring R₂] (σ₁₂ : outParam <| R →+* R₂) {σ₂₁ : outParam <| R₂ →+* R} [RingHomInvPair σ₁₂ σ₂₁]
    [RingHomInvPair σ₂₁ σ₁₂] (E E₂ : outParam (Type _)) [SeminormedAddCommGroup E]
    [SeminormedAddCommGroup E₂] [Module R E] [Module R₂ E₂] extends
    SemilinearEquivClass 𝓕 σ₁₂ E E₂ where
  norm_map : ∀ (f : 𝓕) (x : E), ‖f x‖ = ‖x‖
#align semilinear_isometry_equiv_class SemilinearIsometryEquivClass
-/

#print LinearIsometryEquivClass /-
/-- `linear_isometry_equiv_class F R E E₂` asserts `F` is a type of bundled `R`-linear isometries
`M → M₂`.

This is an abbreviation for `semilinear_isometry_equiv_class F (ring_hom.id R) E E₂`.
-/
abbrev LinearIsometryEquivClass (𝓕 : Type _) (R E E₂ : outParam (Type _)) [Semiring R]
    [SeminormedAddCommGroup E] [SeminormedAddCommGroup E₂] [Module R E] [Module R E₂] :=
  SemilinearIsometryEquivClass 𝓕 (RingHom.id R) E E₂
#align linear_isometry_equiv_class LinearIsometryEquivClass
-/

namespace SemilinearIsometryEquivClass

variable (𝓕)

-- `σ₂₁` becomes a metavariable, but it's OK since it's an outparam
@[nolint dangerous_instance]
instance (priority := 100) [s : SemilinearIsometryEquivClass 𝓕 σ₁₂ E E₂] :
    SemilinearIsometryClass 𝓕 σ₁₂ E E₂ :=
  { s with
    coe := (coe : 𝓕 → E → E₂)
    coe_injective' := @FunLike.coe_injective 𝓕 _ _ _ }

end SemilinearIsometryEquivClass

namespace LinearIsometryEquiv

variable (e : E ≃ₛₗᵢ[σ₁₂] E₂)

#print LinearIsometryEquiv.toLinearEquiv_injective /-
theorem toLinearEquiv_injective : Injective (toLinearEquiv : (E ≃ₛₗᵢ[σ₁₂] E₂) → E ≃ₛₗ[σ₁₂] E₂)
  | ⟨e, _⟩, ⟨_, _⟩, rfl => rfl
#align linear_isometry_equiv.to_linear_equiv_injective LinearIsometryEquiv.toLinearEquiv_injective
-/

#print LinearIsometryEquiv.toLinearEquiv_inj /-
@[simp]
theorem toLinearEquiv_inj {f g : E ≃ₛₗᵢ[σ₁₂] E₂} : f.toLinearEquiv = g.toLinearEquiv ↔ f = g :=
  toLinearEquiv_injective.eq_iff
#align linear_isometry_equiv.to_linear_equiv_inj LinearIsometryEquiv.toLinearEquiv_inj
-/

instance : SemilinearIsometryEquivClass (E ≃ₛₗᵢ[σ₁₂] E₂) σ₁₂ E E₂
    where
  coe e := e.toFun
  inv e := e.invFun
  coe_injective' f g h₁ h₂ := by cases' f with f' _; cases' g with g' _; cases f'; cases g'; congr
  left_inv e := e.left_inv
  right_inv e := e.right_inv
  map_add f := map_add f.toLinearEquiv
  map_smulₛₗ e := map_smulₛₗ e.toLinearEquiv
  norm_map e := e.norm_map'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly.
-/
instance : CoeFun (E ≃ₛₗᵢ[σ₁₂] E₂) fun _ => E → E₂ :=
  ⟨fun f => f.toFun⟩

#print LinearIsometryEquiv.coe_injective /-
theorem coe_injective : @Function.Injective (E ≃ₛₗᵢ[σ₁₂] E₂) (E → E₂) coeFn :=
  FunLike.coe_injective
#align linear_isometry_equiv.coe_injective LinearIsometryEquiv.coe_injective
-/

#print LinearIsometryEquiv.coe_mk /-
@[simp]
theorem coe_mk (e : E ≃ₛₗ[σ₁₂] E₂) (he : ∀ x, ‖e x‖ = ‖x‖) : ⇑(mk e he) = e :=
  rfl
#align linear_isometry_equiv.coe_mk LinearIsometryEquiv.coe_mk
-/

#print LinearIsometryEquiv.coe_toLinearEquiv /-
@[simp]
theorem coe_toLinearEquiv (e : E ≃ₛₗᵢ[σ₁₂] E₂) : ⇑e.toLinearEquiv = e :=
  rfl
#align linear_isometry_equiv.coe_to_linear_equiv LinearIsometryEquiv.coe_toLinearEquiv
-/

#print LinearIsometryEquiv.ext /-
@[ext]
theorem ext {e e' : E ≃ₛₗᵢ[σ₁₂] E₂} (h : ∀ x, e x = e' x) : e = e' :=
  toLinearEquiv_injective <| LinearEquiv.ext h
#align linear_isometry_equiv.ext LinearIsometryEquiv.ext
-/

#print LinearIsometryEquiv.congr_arg /-
protected theorem congr_arg {f : E ≃ₛₗᵢ[σ₁₂] E₂} : ∀ {x x' : E}, x = x' → f x = f x'
  | _, _, rfl => rfl
#align linear_isometry_equiv.congr_arg LinearIsometryEquiv.congr_arg
-/

#print LinearIsometryEquiv.congr_fun /-
protected theorem congr_fun {f g : E ≃ₛₗᵢ[σ₁₂] E₂} (h : f = g) (x : E) : f x = g x :=
  h ▸ rfl
#align linear_isometry_equiv.congr_fun LinearIsometryEquiv.congr_fun
-/

#print LinearIsometryEquiv.ofBounds /-
/-- Construct a `linear_isometry_equiv` from a `linear_equiv` and two inequalities:
`∀ x, ‖e x‖ ≤ ‖x‖` and `∀ y, ‖e.symm y‖ ≤ ‖y‖`. -/
def ofBounds (e : E ≃ₛₗ[σ₁₂] E₂) (h₁ : ∀ x, ‖e x‖ ≤ ‖x‖) (h₂ : ∀ y, ‖e.symm y‖ ≤ ‖y‖) :
    E ≃ₛₗᵢ[σ₁₂] E₂ :=
  ⟨e, fun x => le_antisymm (h₁ x) <| by simpa only [e.symm_apply_apply] using h₂ (e x)⟩
#align linear_isometry_equiv.of_bounds LinearIsometryEquiv.ofBounds
-/

#print LinearIsometryEquiv.norm_map /-
@[simp]
theorem norm_map (x : E) : ‖e x‖ = ‖x‖ :=
  e.norm_map' x
#align linear_isometry_equiv.norm_map LinearIsometryEquiv.norm_map
-/

#print LinearIsometryEquiv.toLinearIsometry /-
/-- Reinterpret a `linear_isometry_equiv` as a `linear_isometry`. -/
def toLinearIsometry : E →ₛₗᵢ[σ₁₂] E₂ :=
  ⟨e.1, e.2⟩
#align linear_isometry_equiv.to_linear_isometry LinearIsometryEquiv.toLinearIsometry
-/

#print LinearIsometryEquiv.toLinearIsometry_injective /-
theorem toLinearIsometry_injective : Function.Injective (toLinearIsometry : _ → E →ₛₗᵢ[σ₁₂] E₂) :=
  fun x y h => coe_injective (congr_arg _ h : ⇑x.toLinearIsometry = _)
#align linear_isometry_equiv.to_linear_isometry_injective LinearIsometryEquiv.toLinearIsometry_injective
-/

#print LinearIsometryEquiv.toLinearIsometry_inj /-
@[simp]
theorem toLinearIsometry_inj {f g : E ≃ₛₗᵢ[σ₁₂] E₂} :
    f.toLinearIsometry = g.toLinearIsometry ↔ f = g :=
  toLinearIsometry_injective.eq_iff
#align linear_isometry_equiv.to_linear_isometry_inj LinearIsometryEquiv.toLinearIsometry_inj
-/

#print LinearIsometryEquiv.coe_toLinearIsometry /-
@[simp]
theorem coe_toLinearIsometry : ⇑e.toLinearIsometry = e :=
  rfl
#align linear_isometry_equiv.coe_to_linear_isometry LinearIsometryEquiv.coe_toLinearIsometry
-/

#print LinearIsometryEquiv.isometry /-
protected theorem isometry : Isometry e :=
  e.toLinearIsometry.Isometry
#align linear_isometry_equiv.isometry LinearIsometryEquiv.isometry
-/

#print LinearIsometryEquiv.toIsometryEquiv /-
/-- Reinterpret a `linear_isometry_equiv` as an `isometry_equiv`. -/
def toIsometryEquiv : E ≃ᵢ E₂ :=
  ⟨e.toLinearEquiv.toEquiv, e.Isometry⟩
#align linear_isometry_equiv.to_isometry_equiv LinearIsometryEquiv.toIsometryEquiv
-/

#print LinearIsometryEquiv.toIsometryEquiv_injective /-
theorem toIsometryEquiv_injective :
    Function.Injective (toIsometryEquiv : (E ≃ₛₗᵢ[σ₁₂] E₂) → E ≃ᵢ E₂) := fun x y h =>
  coe_injective (congr_arg _ h : ⇑x.toIsometryEquiv = _)
#align linear_isometry_equiv.to_isometry_equiv_injective LinearIsometryEquiv.toIsometryEquiv_injective
-/

#print LinearIsometryEquiv.toIsometryEquiv_inj /-
@[simp]
theorem toIsometryEquiv_inj {f g : E ≃ₛₗᵢ[σ₁₂] E₂} :
    f.toIsometryEquiv = g.toIsometryEquiv ↔ f = g :=
  toIsometryEquiv_injective.eq_iff
#align linear_isometry_equiv.to_isometry_equiv_inj LinearIsometryEquiv.toIsometryEquiv_inj
-/

#print LinearIsometryEquiv.coe_toIsometryEquiv /-
@[simp]
theorem coe_toIsometryEquiv : ⇑e.toIsometryEquiv = e :=
  rfl
#align linear_isometry_equiv.coe_to_isometry_equiv LinearIsometryEquiv.coe_toIsometryEquiv
-/

#print LinearIsometryEquiv.range_eq_univ /-
theorem range_eq_univ (e : E ≃ₛₗᵢ[σ₁₂] E₂) : Set.range e = Set.univ := by
  rw [← coe_to_isometry_equiv]; exact IsometryEquiv.range_eq_univ _
#align linear_isometry_equiv.range_eq_univ LinearIsometryEquiv.range_eq_univ
-/

#print LinearIsometryEquiv.toHomeomorph /-
/-- Reinterpret a `linear_isometry_equiv` as an `homeomorph`. -/
def toHomeomorph : E ≃ₜ E₂ :=
  e.toIsometryEquiv.toHomeomorph
#align linear_isometry_equiv.to_homeomorph LinearIsometryEquiv.toHomeomorph
-/

#print LinearIsometryEquiv.toHomeomorph_injective /-
theorem toHomeomorph_injective : Function.Injective (toHomeomorph : (E ≃ₛₗᵢ[σ₁₂] E₂) → E ≃ₜ E₂) :=
  fun x y h => coe_injective (congr_arg _ h : ⇑x.toHomeomorph = _)
#align linear_isometry_equiv.to_homeomorph_injective LinearIsometryEquiv.toHomeomorph_injective
-/

#print LinearIsometryEquiv.toHomeomorph_inj /-
@[simp]
theorem toHomeomorph_inj {f g : E ≃ₛₗᵢ[σ₁₂] E₂} : f.toHomeomorph = g.toHomeomorph ↔ f = g :=
  toHomeomorph_injective.eq_iff
#align linear_isometry_equiv.to_homeomorph_inj LinearIsometryEquiv.toHomeomorph_inj
-/

#print LinearIsometryEquiv.coe_toHomeomorph /-
@[simp]
theorem coe_toHomeomorph : ⇑e.toHomeomorph = e :=
  rfl
#align linear_isometry_equiv.coe_to_homeomorph LinearIsometryEquiv.coe_toHomeomorph
-/

#print LinearIsometryEquiv.continuous /-
protected theorem continuous : Continuous e :=
  e.Isometry.Continuous
#align linear_isometry_equiv.continuous LinearIsometryEquiv.continuous
-/

#print LinearIsometryEquiv.continuousAt /-
protected theorem continuousAt {x} : ContinuousAt e x :=
  e.Continuous.ContinuousAt
#align linear_isometry_equiv.continuous_at LinearIsometryEquiv.continuousAt
-/

#print LinearIsometryEquiv.continuousOn /-
protected theorem continuousOn {s} : ContinuousOn e s :=
  e.Continuous.ContinuousOn
#align linear_isometry_equiv.continuous_on LinearIsometryEquiv.continuousOn
-/

#print LinearIsometryEquiv.continuousWithinAt /-
protected theorem continuousWithinAt {s x} : ContinuousWithinAt e s x :=
  e.Continuous.ContinuousWithinAt
#align linear_isometry_equiv.continuous_within_at LinearIsometryEquiv.continuousWithinAt
-/

#print LinearIsometryEquiv.toContinuousLinearEquiv /-
/-- Interpret a `linear_isometry_equiv` as a continuous linear equiv. -/
def toContinuousLinearEquiv : E ≃SL[σ₁₂] E₂ :=
  { e.toLinearIsometry.toContinuousLinearMap, e.toHomeomorph with }
#align linear_isometry_equiv.to_continuous_linear_equiv LinearIsometryEquiv.toContinuousLinearEquiv
-/

#print LinearIsometryEquiv.toContinuousLinearEquiv_injective /-
theorem toContinuousLinearEquiv_injective :
    Function.Injective (toContinuousLinearEquiv : _ → E ≃SL[σ₁₂] E₂) := fun x y h =>
  coe_injective (congr_arg _ h : ⇑x.toContinuousLinearEquiv = _)
#align linear_isometry_equiv.to_continuous_linear_equiv_injective LinearIsometryEquiv.toContinuousLinearEquiv_injective
-/

#print LinearIsometryEquiv.toContinuousLinearEquiv_inj /-
@[simp]
theorem toContinuousLinearEquiv_inj {f g : E ≃ₛₗᵢ[σ₁₂] E₂} :
    f.toContinuousLinearEquiv = g.toContinuousLinearEquiv ↔ f = g :=
  toContinuousLinearEquiv_injective.eq_iff
#align linear_isometry_equiv.to_continuous_linear_equiv_inj LinearIsometryEquiv.toContinuousLinearEquiv_inj
-/

#print LinearIsometryEquiv.coe_toContinuousLinearEquiv /-
@[simp]
theorem coe_toContinuousLinearEquiv : ⇑e.toContinuousLinearEquiv = e :=
  rfl
#align linear_isometry_equiv.coe_to_continuous_linear_equiv LinearIsometryEquiv.coe_toContinuousLinearEquiv
-/

variable (R E)

#print LinearIsometryEquiv.refl /-
/-- Identity map as a `linear_isometry_equiv`. -/
def refl : E ≃ₗᵢ[R] E :=
  ⟨LinearEquiv.refl R E, fun x => rfl⟩
#align linear_isometry_equiv.refl LinearIsometryEquiv.refl
-/

#print LinearIsometryEquiv.ulift /-
/-- Linear isometry equiv between a space and its lift to another universe. -/
def ulift : ULift E ≃ₗᵢ[R] E :=
  { ContinuousLinearEquiv.ulift with norm_map' := fun x => rfl }
#align linear_isometry_equiv.ulift LinearIsometryEquiv.ulift
-/

variable {R E}

instance : Inhabited (E ≃ₗᵢ[R] E) :=
  ⟨refl R E⟩

#print LinearIsometryEquiv.coe_refl /-
@[simp]
theorem coe_refl : ⇑(refl R E) = id :=
  rfl
#align linear_isometry_equiv.coe_refl LinearIsometryEquiv.coe_refl
-/

#print LinearIsometryEquiv.symm /-
/-- The inverse `linear_isometry_equiv`. -/
def symm : E₂ ≃ₛₗᵢ[σ₂₁] E :=
  ⟨e.toLinearEquiv.symm, fun x =>
    (e.norm_map _).symm.trans <| congr_arg norm <| e.toLinearEquiv.apply_symm_apply x⟩
#align linear_isometry_equiv.symm LinearIsometryEquiv.symm
-/

#print LinearIsometryEquiv.apply_symm_apply /-
@[simp]
theorem apply_symm_apply (x : E₂) : e (e.symm x) = x :=
  e.toLinearEquiv.apply_symm_apply x
#align linear_isometry_equiv.apply_symm_apply LinearIsometryEquiv.apply_symm_apply
-/

#print LinearIsometryEquiv.symm_apply_apply /-
@[simp]
theorem symm_apply_apply (x : E) : e.symm (e x) = x :=
  e.toLinearEquiv.symm_apply_apply x
#align linear_isometry_equiv.symm_apply_apply LinearIsometryEquiv.symm_apply_apply
-/

#print LinearIsometryEquiv.map_eq_zero_iff /-
@[simp]
theorem map_eq_zero_iff {x : E} : e x = 0 ↔ x = 0 :=
  e.toLinearEquiv.map_eq_zero_iff
#align linear_isometry_equiv.map_eq_zero_iff LinearIsometryEquiv.map_eq_zero_iff
-/

#print LinearIsometryEquiv.symm_symm /-
@[simp]
theorem symm_symm : e.symm.symm = e :=
  ext fun x => rfl
#align linear_isometry_equiv.symm_symm LinearIsometryEquiv.symm_symm
-/

#print LinearIsometryEquiv.toLinearEquiv_symm /-
@[simp]
theorem toLinearEquiv_symm : e.toLinearEquiv.symm = e.symm.toLinearEquiv :=
  rfl
#align linear_isometry_equiv.to_linear_equiv_symm LinearIsometryEquiv.toLinearEquiv_symm
-/

#print LinearIsometryEquiv.toIsometryEquiv_symm /-
@[simp]
theorem toIsometryEquiv_symm : e.toIsometryEquiv.symm = e.symm.toIsometryEquiv :=
  rfl
#align linear_isometry_equiv.to_isometry_equiv_symm LinearIsometryEquiv.toIsometryEquiv_symm
-/

#print LinearIsometryEquiv.toHomeomorph_symm /-
@[simp]
theorem toHomeomorph_symm : e.toHomeomorph.symm = e.symm.toHomeomorph :=
  rfl
#align linear_isometry_equiv.to_homeomorph_symm LinearIsometryEquiv.toHomeomorph_symm
-/

#print LinearIsometryEquiv.Simps.apply /-
/-- See Note [custom simps projection]. We need to specify this projection explicitly in this case,
  because it is a composition of multiple projections. -/
def Simps.apply (σ₁₂ : R →+* R₂) {σ₂₁ : R₂ →+* R} [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂]
    (E E₂ : Type _) [SeminormedAddCommGroup E] [SeminormedAddCommGroup E₂] [Module R E]
    [Module R₂ E₂] (h : E ≃ₛₗᵢ[σ₁₂] E₂) : E → E₂ :=
  h
#align linear_isometry_equiv.simps.apply LinearIsometryEquiv.Simps.apply
-/

#print LinearIsometryEquiv.Simps.symm_apply /-
/-- See Note [custom simps projection] -/
def Simps.symm_apply (σ₁₂ : R →+* R₂) {σ₂₁ : R₂ →+* R} [RingHomInvPair σ₁₂ σ₂₁]
    [RingHomInvPair σ₂₁ σ₁₂] (E E₂ : Type _) [SeminormedAddCommGroup E] [SeminormedAddCommGroup E₂]
    [Module R E] [Module R₂ E₂] (h : E ≃ₛₗᵢ[σ₁₂] E₂) : E₂ → E :=
  h.symm
#align linear_isometry_equiv.simps.symm_apply LinearIsometryEquiv.Simps.symm_apply
-/

initialize_simps_projections LinearIsometryEquiv (to_linear_equiv_to_fun → apply,
  to_linear_equiv_inv_fun → symm_apply)

#print LinearIsometryEquiv.trans /-
/-- Composition of `linear_isometry_equiv`s as a `linear_isometry_equiv`. -/
def trans (e' : E₂ ≃ₛₗᵢ[σ₂₃] E₃) : E ≃ₛₗᵢ[σ₁₃] E₃ :=
  ⟨e.toLinearEquiv.trans e'.toLinearEquiv, fun x => (e'.norm_map _).trans (e.norm_map _)⟩
#align linear_isometry_equiv.trans LinearIsometryEquiv.trans
-/

#print LinearIsometryEquiv.coe_trans /-
@[simp]
theorem coe_trans (e₁ : E ≃ₛₗᵢ[σ₁₂] E₂) (e₂ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) : ⇑(e₁.trans e₂) = e₂ ∘ e₁ :=
  rfl
#align linear_isometry_equiv.coe_trans LinearIsometryEquiv.coe_trans
-/

#print LinearIsometryEquiv.trans_apply /-
@[simp]
theorem trans_apply (e₁ : E ≃ₛₗᵢ[σ₁₂] E₂) (e₂ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) (c : E) :
    (e₁.trans e₂ : E ≃ₛₗᵢ[σ₁₃] E₃) c = e₂ (e₁ c) :=
  rfl
#align linear_isometry_equiv.trans_apply LinearIsometryEquiv.trans_apply
-/

#print LinearIsometryEquiv.toLinearEquiv_trans /-
@[simp]
theorem toLinearEquiv_trans (e' : E₂ ≃ₛₗᵢ[σ₂₃] E₃) :
    (e.trans e').toLinearEquiv = e.toLinearEquiv.trans e'.toLinearEquiv :=
  rfl
#align linear_isometry_equiv.to_linear_equiv_trans LinearIsometryEquiv.toLinearEquiv_trans
-/

#print LinearIsometryEquiv.trans_refl /-
@[simp]
theorem trans_refl : e.trans (refl R₂ E₂) = e :=
  ext fun x => rfl
#align linear_isometry_equiv.trans_refl LinearIsometryEquiv.trans_refl
-/

#print LinearIsometryEquiv.refl_trans /-
@[simp]
theorem refl_trans : (refl R E).trans e = e :=
  ext fun x => rfl
#align linear_isometry_equiv.refl_trans LinearIsometryEquiv.refl_trans
-/

#print LinearIsometryEquiv.self_trans_symm /-
@[simp]
theorem self_trans_symm : e.trans e.symm = refl R E :=
  ext e.symm_apply_apply
#align linear_isometry_equiv.self_trans_symm LinearIsometryEquiv.self_trans_symm
-/

#print LinearIsometryEquiv.symm_trans_self /-
@[simp]
theorem symm_trans_self : e.symm.trans e = refl R₂ E₂ :=
  ext e.apply_symm_apply
#align linear_isometry_equiv.symm_trans_self LinearIsometryEquiv.symm_trans_self
-/

#print LinearIsometryEquiv.symm_comp_self /-
@[simp]
theorem symm_comp_self : e.symm ∘ e = id :=
  funext e.symm_apply_apply
#align linear_isometry_equiv.symm_comp_self LinearIsometryEquiv.symm_comp_self
-/

#print LinearIsometryEquiv.self_comp_symm /-
@[simp]
theorem self_comp_symm : e ∘ e.symm = id :=
  e.symm.symm_comp_self
#align linear_isometry_equiv.self_comp_symm LinearIsometryEquiv.self_comp_symm
-/

#print LinearIsometryEquiv.symm_trans /-
@[simp]
theorem symm_trans (e₁ : E ≃ₛₗᵢ[σ₁₂] E₂) (e₂ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) :
    (e₁.trans e₂).symm = e₂.symm.trans e₁.symm :=
  rfl
#align linear_isometry_equiv.symm_trans LinearIsometryEquiv.symm_trans
-/

#print LinearIsometryEquiv.coe_symm_trans /-
theorem coe_symm_trans (e₁ : E ≃ₛₗᵢ[σ₁₂] E₂) (e₂ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) :
    ⇑(e₁.trans e₂).symm = e₁.symm ∘ e₂.symm :=
  rfl
#align linear_isometry_equiv.coe_symm_trans LinearIsometryEquiv.coe_symm_trans
-/

#print LinearIsometryEquiv.trans_assoc /-
theorem trans_assoc (eEE₂ : E ≃ₛₗᵢ[σ₁₂] E₂) (eE₂E₃ : E₂ ≃ₛₗᵢ[σ₂₃] E₃) (eE₃E₄ : E₃ ≃ₛₗᵢ[σ₃₄] E₄) :
    eEE₂.trans (eE₂E₃.trans eE₃E₄) = (eEE₂.trans eE₂E₃).trans eE₃E₄ :=
  rfl
#align linear_isometry_equiv.trans_assoc LinearIsometryEquiv.trans_assoc
-/

instance : Group (E ≃ₗᵢ[R] E) where
  mul e₁ e₂ := e₂.trans e₁
  one := refl _ _
  inv := symm
  one_mul := trans_refl
  mul_one := refl_trans
  mul_assoc _ _ _ := trans_assoc _ _ _
  mul_left_inv := self_trans_symm

#print LinearIsometryEquiv.coe_one /-
@[simp]
theorem coe_one : ⇑(1 : E ≃ₗᵢ[R] E) = id :=
  rfl
#align linear_isometry_equiv.coe_one LinearIsometryEquiv.coe_one
-/

#print LinearIsometryEquiv.coe_mul /-
@[simp]
theorem coe_mul (e e' : E ≃ₗᵢ[R] E) : ⇑(e * e') = e ∘ e' :=
  rfl
#align linear_isometry_equiv.coe_mul LinearIsometryEquiv.coe_mul
-/

#print LinearIsometryEquiv.coe_inv /-
@[simp]
theorem coe_inv (e : E ≃ₗᵢ[R] E) : ⇑e⁻¹ = e.symm :=
  rfl
#align linear_isometry_equiv.coe_inv LinearIsometryEquiv.coe_inv
-/

#print LinearIsometryEquiv.one_def /-
theorem one_def : (1 : E ≃ₗᵢ[R] E) = refl _ _ :=
  rfl
#align linear_isometry_equiv.one_def LinearIsometryEquiv.one_def
-/

#print LinearIsometryEquiv.mul_def /-
theorem mul_def (e e' : E ≃ₗᵢ[R] E) : (e * e' : E ≃ₗᵢ[R] E) = e'.trans e :=
  rfl
#align linear_isometry_equiv.mul_def LinearIsometryEquiv.mul_def
-/

#print LinearIsometryEquiv.inv_def /-
theorem inv_def (e : E ≃ₗᵢ[R] E) : (e⁻¹ : E ≃ₗᵢ[R] E) = e.symm :=
  rfl
#align linear_isometry_equiv.inv_def LinearIsometryEquiv.inv_def
-/

/-! Lemmas about mixing the group structure with definitions. Because we have multiple ways to
express `linear_isometry_equiv.refl`, `linear_isometry_equiv.symm`, and
`linear_isometry_equiv.trans`, we want simp lemmas for every combination.
The assumption made here is that if you're using the group structure, you want to preserve it
after simp.

This copies the approach used by the lemmas near `equiv.perm.trans_one`. -/


#print LinearIsometryEquiv.trans_one /-
@[simp]
theorem trans_one : e.trans (1 : E₂ ≃ₗᵢ[R₂] E₂) = e :=
  trans_refl _
#align linear_isometry_equiv.trans_one LinearIsometryEquiv.trans_one
-/

#print LinearIsometryEquiv.one_trans /-
@[simp]
theorem one_trans : (1 : E ≃ₗᵢ[R] E).trans e = e :=
  refl_trans _
#align linear_isometry_equiv.one_trans LinearIsometryEquiv.one_trans
-/

#print LinearIsometryEquiv.refl_mul /-
@[simp]
theorem refl_mul (e : E ≃ₗᵢ[R] E) : refl _ _ * e = e :=
  trans_refl _
#align linear_isometry_equiv.refl_mul LinearIsometryEquiv.refl_mul
-/

#print LinearIsometryEquiv.mul_refl /-
@[simp]
theorem mul_refl (e : E ≃ₗᵢ[R] E) : e * refl _ _ = e :=
  refl_trans _
#align linear_isometry_equiv.mul_refl LinearIsometryEquiv.mul_refl
-/

/-- Reinterpret a `linear_isometry_equiv` as a `continuous_linear_equiv`. -/
instance : CoeTC (E ≃ₛₗᵢ[σ₁₂] E₂) (E ≃SL[σ₁₂] E₂) :=
  ⟨fun e => ⟨e.toLinearEquiv, e.Continuous, e.toIsometryEquiv.symm.Continuous⟩⟩

instance : CoeTC (E ≃ₛₗᵢ[σ₁₂] E₂) (E →SL[σ₁₂] E₂) :=
  ⟨fun e => ↑(e : E ≃SL[σ₁₂] E₂)⟩

#print LinearIsometryEquiv.coe_coe /-
@[simp]
theorem coe_coe : ⇑(e : E ≃SL[σ₁₂] E₂) = e :=
  rfl
#align linear_isometry_equiv.coe_coe LinearIsometryEquiv.coe_coe
-/

@[simp]
theorem coe_coe' : ((e : E ≃SL[σ₁₂] E₂) : E →SL[σ₁₂] E₂) = e :=
  rfl
#align linear_isometry_equiv.coe_coe' LinearIsometryEquiv.coe_coe'

#print LinearIsometryEquiv.coe_coe'' /-
@[simp]
theorem coe_coe'' : ⇑(e : E →SL[σ₁₂] E₂) = e :=
  rfl
#align linear_isometry_equiv.coe_coe'' LinearIsometryEquiv.coe_coe''
-/

#print LinearIsometryEquiv.map_zero /-
@[simp]
theorem map_zero : e 0 = 0 :=
  e.1.map_zero
#align linear_isometry_equiv.map_zero LinearIsometryEquiv.map_zero
-/

#print LinearIsometryEquiv.map_add /-
@[simp]
theorem map_add (x y : E) : e (x + y) = e x + e y :=
  e.1.map_add x y
#align linear_isometry_equiv.map_add LinearIsometryEquiv.map_add
-/

#print LinearIsometryEquiv.map_sub /-
@[simp]
theorem map_sub (x y : E) : e (x - y) = e x - e y :=
  e.1.map_sub x y
#align linear_isometry_equiv.map_sub LinearIsometryEquiv.map_sub
-/

#print LinearIsometryEquiv.map_smulₛₗ /-
@[simp]
theorem map_smulₛₗ (c : R) (x : E) : e (c • x) = σ₁₂ c • e x :=
  e.1.map_smulₛₗ c x
#align linear_isometry_equiv.map_smulₛₗ LinearIsometryEquiv.map_smulₛₗ
-/

#print LinearIsometryEquiv.map_smul /-
@[simp]
theorem map_smul [Module R E₂] {e : E ≃ₗᵢ[R] E₂} (c : R) (x : E) : e (c • x) = c • e x :=
  e.1.map_smul c x
#align linear_isometry_equiv.map_smul LinearIsometryEquiv.map_smul
-/

#print LinearIsometryEquiv.nnnorm_map /-
@[simp]
theorem nnnorm_map (x : E) : ‖e x‖₊ = ‖x‖₊ :=
  SemilinearIsometryClass.nnnorm_map e x
#align linear_isometry_equiv.nnnorm_map LinearIsometryEquiv.nnnorm_map
-/

#print LinearIsometryEquiv.dist_map /-
@[simp]
theorem dist_map (x y : E) : dist (e x) (e y) = dist x y :=
  e.toLinearIsometry.dist_map x y
#align linear_isometry_equiv.dist_map LinearIsometryEquiv.dist_map
-/

#print LinearIsometryEquiv.edist_map /-
@[simp]
theorem edist_map (x y : E) : edist (e x) (e y) = edist x y :=
  e.toLinearIsometry.edist_map x y
#align linear_isometry_equiv.edist_map LinearIsometryEquiv.edist_map
-/

#print LinearIsometryEquiv.bijective /-
protected theorem bijective : Bijective e :=
  e.1.Bijective
#align linear_isometry_equiv.bijective LinearIsometryEquiv.bijective
-/

#print LinearIsometryEquiv.injective /-
protected theorem injective : Injective e :=
  e.1.Injective
#align linear_isometry_equiv.injective LinearIsometryEquiv.injective
-/

#print LinearIsometryEquiv.surjective /-
protected theorem surjective : Surjective e :=
  e.1.Surjective
#align linear_isometry_equiv.surjective LinearIsometryEquiv.surjective
-/

#print LinearIsometryEquiv.map_eq_iff /-
@[simp]
theorem map_eq_iff {x y : E} : e x = e y ↔ x = y :=
  e.Injective.eq_iff
#align linear_isometry_equiv.map_eq_iff LinearIsometryEquiv.map_eq_iff
-/

#print LinearIsometryEquiv.map_ne /-
theorem map_ne {x y : E} (h : x ≠ y) : e x ≠ e y :=
  e.Injective.Ne h
#align linear_isometry_equiv.map_ne LinearIsometryEquiv.map_ne
-/

#print LinearIsometryEquiv.lipschitz /-
protected theorem lipschitz : LipschitzWith 1 e :=
  e.Isometry.lipschitz
#align linear_isometry_equiv.lipschitz LinearIsometryEquiv.lipschitz
-/

#print LinearIsometryEquiv.antilipschitz /-
protected theorem antilipschitz : AntilipschitzWith 1 e :=
  e.Isometry.antilipschitz
#align linear_isometry_equiv.antilipschitz LinearIsometryEquiv.antilipschitz
-/

#print LinearIsometryEquiv.image_eq_preimage /-
theorem image_eq_preimage (s : Set E) : e '' s = e.symm ⁻¹' s :=
  e.toLinearEquiv.image_eq_preimage s
#align linear_isometry_equiv.image_eq_preimage LinearIsometryEquiv.image_eq_preimage
-/

#print LinearIsometryEquiv.ediam_image /-
@[simp]
theorem ediam_image (s : Set E) : EMetric.diam (e '' s) = EMetric.diam s :=
  e.Isometry.ediam_image s
#align linear_isometry_equiv.ediam_image LinearIsometryEquiv.ediam_image
-/

#print LinearIsometryEquiv.diam_image /-
@[simp]
theorem diam_image (s : Set E) : Metric.diam (e '' s) = Metric.diam s :=
  e.Isometry.diam_image s
#align linear_isometry_equiv.diam_image LinearIsometryEquiv.diam_image
-/

#print LinearIsometryEquiv.preimage_ball /-
@[simp]
theorem preimage_ball (x : E₂) (r : ℝ) : e ⁻¹' Metric.ball x r = Metric.ball (e.symm x) r :=
  e.toIsometryEquiv.preimage_ball x r
#align linear_isometry_equiv.preimage_ball LinearIsometryEquiv.preimage_ball
-/

#print LinearIsometryEquiv.preimage_sphere /-
@[simp]
theorem preimage_sphere (x : E₂) (r : ℝ) : e ⁻¹' Metric.sphere x r = Metric.sphere (e.symm x) r :=
  e.toIsometryEquiv.preimage_sphere x r
#align linear_isometry_equiv.preimage_sphere LinearIsometryEquiv.preimage_sphere
-/

#print LinearIsometryEquiv.preimage_closedBall /-
@[simp]
theorem preimage_closedBall (x : E₂) (r : ℝ) :
    e ⁻¹' Metric.closedBall x r = Metric.closedBall (e.symm x) r :=
  e.toIsometryEquiv.preimage_closedBall x r
#align linear_isometry_equiv.preimage_closed_ball LinearIsometryEquiv.preimage_closedBall
-/

#print LinearIsometryEquiv.image_ball /-
@[simp]
theorem image_ball (x : E) (r : ℝ) : e '' Metric.ball x r = Metric.ball (e x) r :=
  e.toIsometryEquiv.image_ball x r
#align linear_isometry_equiv.image_ball LinearIsometryEquiv.image_ball
-/

#print LinearIsometryEquiv.image_sphere /-
@[simp]
theorem image_sphere (x : E) (r : ℝ) : e '' Metric.sphere x r = Metric.sphere (e x) r :=
  e.toIsometryEquiv.image_sphere x r
#align linear_isometry_equiv.image_sphere LinearIsometryEquiv.image_sphere
-/

#print LinearIsometryEquiv.image_closedBall /-
@[simp]
theorem image_closedBall (x : E) (r : ℝ) : e '' Metric.closedBall x r = Metric.closedBall (e x) r :=
  e.toIsometryEquiv.image_closedBall x r
#align linear_isometry_equiv.image_closed_ball LinearIsometryEquiv.image_closedBall
-/

variable {α : Type _} [TopologicalSpace α]

#print LinearIsometryEquiv.comp_continuousOn_iff /-
@[simp]
theorem comp_continuousOn_iff {f : α → E} {s : Set α} : ContinuousOn (e ∘ f) s ↔ ContinuousOn f s :=
  e.Isometry.comp_continuousOn_iff
#align linear_isometry_equiv.comp_continuous_on_iff LinearIsometryEquiv.comp_continuousOn_iff
-/

#print LinearIsometryEquiv.comp_continuous_iff /-
@[simp]
theorem comp_continuous_iff {f : α → E} : Continuous (e ∘ f) ↔ Continuous f :=
  e.Isometry.comp_continuous_iff
#align linear_isometry_equiv.comp_continuous_iff LinearIsometryEquiv.comp_continuous_iff
-/

#print LinearIsometryEquiv.completeSpace_map /-
instance completeSpace_map (p : Submodule R E) [CompleteSpace p] :
    CompleteSpace (p.map (e.toLinearEquiv : E →ₛₗ[σ₁₂] E₂)) :=
  e.toLinearIsometry.completeSpace_map' p
#align linear_isometry_equiv.complete_space_map LinearIsometryEquiv.completeSpace_map
-/

#print LinearIsometryEquiv.ofSurjective /-
/-- Construct a linear isometry equiv from a surjective linear isometry. -/
noncomputable def ofSurjective (f : F →ₛₗᵢ[σ₁₂] E₂) (hfr : Function.Surjective f) :
    F ≃ₛₗᵢ[σ₁₂] E₂ :=
  { LinearEquiv.ofBijective f.toLinearMap ⟨f.Injective, hfr⟩ with norm_map' := f.norm_map }
#align linear_isometry_equiv.of_surjective LinearIsometryEquiv.ofSurjective
-/

#print LinearIsometryEquiv.coe_ofSurjective /-
@[simp]
theorem coe_ofSurjective (f : F →ₛₗᵢ[σ₁₂] E₂) (hfr : Function.Surjective f) :
    ⇑(LinearIsometryEquiv.ofSurjective f hfr) = f := by ext; rfl
#align linear_isometry_equiv.coe_of_surjective LinearIsometryEquiv.coe_ofSurjective
-/

#print LinearIsometryEquiv.ofLinearIsometry /-
/-- If a linear isometry has an inverse, it is a linear isometric equivalence. -/
def ofLinearIsometry (f : E →ₛₗᵢ[σ₁₂] E₂) (g : E₂ →ₛₗ[σ₂₁] E)
    (h₁ : f.toLinearMap.comp g = LinearMap.id) (h₂ : g.comp f.toLinearMap = LinearMap.id) :
    E ≃ₛₗᵢ[σ₁₂] E₂ :=
  { LinearEquiv.ofLinear f.toLinearMap g h₁ h₂ with norm_map' := fun x => f.norm_map x }
#align linear_isometry_equiv.of_linear_isometry LinearIsometryEquiv.ofLinearIsometry
-/

#print LinearIsometryEquiv.coe_ofLinearIsometry /-
@[simp]
theorem coe_ofLinearIsometry (f : E →ₛₗᵢ[σ₁₂] E₂) (g : E₂ →ₛₗ[σ₂₁] E)
    (h₁ : f.toLinearMap.comp g = LinearMap.id) (h₂ : g.comp f.toLinearMap = LinearMap.id) :
    (ofLinearIsometry f g h₁ h₂ : E → E₂) = (f : E → E₂) :=
  rfl
#align linear_isometry_equiv.coe_of_linear_isometry LinearIsometryEquiv.coe_ofLinearIsometry
-/

#print LinearIsometryEquiv.coe_ofLinearIsometry_symm /-
@[simp]
theorem coe_ofLinearIsometry_symm (f : E →ₛₗᵢ[σ₁₂] E₂) (g : E₂ →ₛₗ[σ₂₁] E)
    (h₁ : f.toLinearMap.comp g = LinearMap.id) (h₂ : g.comp f.toLinearMap = LinearMap.id) :
    ((ofLinearIsometry f g h₁ h₂).symm : E₂ → E) = (g : E₂ → E) :=
  rfl
#align linear_isometry_equiv.coe_of_linear_isometry_symm LinearIsometryEquiv.coe_ofLinearIsometry_symm
-/

variable (R)

#print LinearIsometryEquiv.neg /-
/-- The negation operation on a normed space `E`, considered as a linear isometry equivalence. -/
def neg : E ≃ₗᵢ[R] E :=
  { LinearEquiv.neg R with norm_map' := norm_neg }
#align linear_isometry_equiv.neg LinearIsometryEquiv.neg
-/

variable {R}

#print LinearIsometryEquiv.coe_neg /-
@[simp]
theorem coe_neg : (neg R : E → E) = fun x => -x :=
  rfl
#align linear_isometry_equiv.coe_neg LinearIsometryEquiv.coe_neg
-/

#print LinearIsometryEquiv.symm_neg /-
@[simp]
theorem symm_neg : (neg R : E ≃ₗᵢ[R] E).symm = neg R :=
  rfl
#align linear_isometry_equiv.symm_neg LinearIsometryEquiv.symm_neg
-/

variable (R E E₂ E₃)

#print LinearIsometryEquiv.prodAssoc /-
/-- The natural equivalence `(E × E₂) × E₃ ≃ E × (E₂ × E₃)` is a linear isometry. -/
def prodAssoc [Module R E₂] [Module R E₃] : (E × E₂) × E₃ ≃ₗᵢ[R] E × E₂ × E₃ :=
  { Equiv.prodAssoc E E₂ E₃ with
    toFun := Equiv.prodAssoc E E₂ E₃
    invFun := (Equiv.prodAssoc E E₂ E₃).symm
    map_add' := by simp
    map_smul' := by simp
    norm_map' := by
      rintro ⟨⟨e, f⟩, g⟩
      simp only [LinearEquiv.coe_mk, Equiv.prodAssoc_apply, Prod.norm_def, max_assoc] }
#align linear_isometry_equiv.prod_assoc LinearIsometryEquiv.prodAssoc
-/

#print LinearIsometryEquiv.coe_prodAssoc /-
@[simp]
theorem coe_prodAssoc [Module R E₂] [Module R E₃] :
    (prodAssoc R E E₂ E₃ : (E × E₂) × E₃ → E × E₂ × E₃) = Equiv.prodAssoc E E₂ E₃ :=
  rfl
#align linear_isometry_equiv.coe_prod_assoc LinearIsometryEquiv.coe_prodAssoc
-/

#print LinearIsometryEquiv.coe_prodAssoc_symm /-
@[simp]
theorem coe_prodAssoc_symm [Module R E₂] [Module R E₃] :
    ((prodAssoc R E E₂ E₃).symm : E × E₂ × E₃ → (E × E₂) × E₃) = (Equiv.prodAssoc E E₂ E₃).symm :=
  rfl
#align linear_isometry_equiv.coe_prod_assoc_symm LinearIsometryEquiv.coe_prodAssoc_symm
-/

#print LinearIsometryEquiv.ofTop /-
/-- If `p` is a submodule that is equal to `⊤`, then `linear_isometry_equiv.of_top p hp` is the
"identity" equivalence between `p` and `E`. -/
@[simps toLinearEquiv apply symm_apply_coe]
def ofTop {R : Type _} [Ring R] [Module R E] (p : Submodule R E) (hp : p = ⊤) : p ≃ₗᵢ[R] E :=
  { p.subtypeₗᵢ with toLinearEquiv := LinearEquiv.ofTop p hp }
#align linear_isometry_equiv.of_top LinearIsometryEquiv.ofTop
-/

variable {R E E₂ E₃} {R' : Type _} [Ring R'] [Module R' E] (p q : Submodule R' E)

#print LinearIsometryEquiv.ofEq /-
/-- `linear_equiv.of_eq` as a `linear_isometry_equiv`. -/
def ofEq (hpq : p = q) : p ≃ₗᵢ[R'] q :=
  { LinearEquiv.ofEq p q hpq with norm_map' := fun x => rfl }
#align linear_isometry_equiv.of_eq LinearIsometryEquiv.ofEq
-/

variable {p q}

#print LinearIsometryEquiv.coe_ofEq_apply /-
@[simp]
theorem coe_ofEq_apply (h : p = q) (x : p) : (ofEq p q h x : E) = x :=
  rfl
#align linear_isometry_equiv.coe_of_eq_apply LinearIsometryEquiv.coe_ofEq_apply
-/

#print LinearIsometryEquiv.ofEq_symm /-
@[simp]
theorem ofEq_symm (h : p = q) : (ofEq p q h).symm = ofEq q p h.symm :=
  rfl
#align linear_isometry_equiv.of_eq_symm LinearIsometryEquiv.ofEq_symm
-/

#print LinearIsometryEquiv.ofEq_rfl /-
@[simp]
theorem ofEq_rfl : ofEq p p rfl = LinearIsometryEquiv.refl R' p := by ext <;> rfl
#align linear_isometry_equiv.of_eq_rfl LinearIsometryEquiv.ofEq_rfl
-/

end LinearIsometryEquiv

#print Basis.ext_linearIsometry /-
/-- Two linear isometries are equal if they are equal on basis vectors. -/
theorem Basis.ext_linearIsometry {ι : Type _} (b : Basis ι R E) {f₁ f₂ : E →ₛₗᵢ[σ₁₂] E₂}
    (h : ∀ i, f₁ (b i) = f₂ (b i)) : f₁ = f₂ :=
  LinearIsometry.toLinearMap_injective <| b.ext h
#align basis.ext_linear_isometry Basis.ext_linearIsometry
-/

#print Basis.ext_linearIsometryEquiv /-
/-- Two linear isometric equivalences are equal if they are equal on basis vectors. -/
theorem Basis.ext_linearIsometryEquiv {ι : Type _} (b : Basis ι R E) {f₁ f₂ : E ≃ₛₗᵢ[σ₁₂] E₂}
    (h : ∀ i, f₁ (b i) = f₂ (b i)) : f₁ = f₂ :=
  LinearIsometryEquiv.toLinearEquiv_injective <| b.ext' h
#align basis.ext_linear_isometry_equiv Basis.ext_linearIsometryEquiv
-/

#print LinearIsometry.equivRange /-
/-- Reinterpret a `linear_isometry` as a `linear_isometry_equiv` to the range. -/
@[simps toLinearEquiv apply_coe]
noncomputable def LinearIsometry.equivRange {R S : Type _} [Semiring R] [Ring S] [Module S E]
    [Module R F] {σ₁₂ : R →+* S} {σ₂₁ : S →+* R} [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂]
    (f : F →ₛₗᵢ[σ₁₂] E) : F ≃ₛₗᵢ[σ₁₂] f.toLinearMap.range :=
  { f with toLinearEquiv := LinearEquiv.ofInjective f.toLinearMap f.Injective }
#align linear_isometry.equiv_range LinearIsometry.equivRange
-/

