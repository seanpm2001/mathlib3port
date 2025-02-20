/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module analysis.normed_space.continuous_affine_map
! leanprover-community/mathlib commit fd4551cfe4b7484b81c2c9ba3405edae27659676
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.ContinuousAffineMap
import Mathbin.Analysis.NormedSpace.AffineIsometry
import Mathbin.Analysis.NormedSpace.OperatorNorm

/-!
# Continuous affine maps between normed spaces.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file develops the theory of continuous affine maps between affine spaces modelled on normed
spaces.

In the particular case that the affine spaces are just normed vector spaces `V`, `W`, we define a
norm on the space of continuous affine maps by defining the norm of `f : V →A[𝕜] W` to be
`‖f‖ = max ‖f 0‖ ‖f.cont_linear‖`. This is chosen so that we have a linear isometry:
`(V →A[𝕜] W) ≃ₗᵢ[𝕜] W × (V →L[𝕜] W)`.

The abstract picture is that for an affine space `P` modelled on a vector space `V`, together with
a vector space `W`, there is an exact sequence of `𝕜`-modules: `0 → C → A → L → 0` where `C`, `A`
are the spaces of constant and affine maps `P → W` and `L` is the space of linear maps `V → W`.

Any choice of a base point in `P` corresponds to a splitting of this sequence so in particular if we
take `P = V`, using `0 : V` as the base point provides a splitting, and we prove this is an
isometric decomposition.

On the other hand, choosing a base point breaks the affine invariance so the norm fails to be
submultiplicative: for a composition of maps, we have only `‖f.comp g‖ ≤ ‖f‖ * ‖g‖ + ‖f 0‖`.

## Main definitions:

 * `continuous_affine_map.cont_linear`
 * `continuous_affine_map.has_norm`
 * `continuous_affine_map.norm_comp_le`
 * `continuous_affine_map.to_const_prod_continuous_linear_map`

-/


namespace ContinuousAffineMap

variable {𝕜 R V W W₂ P Q Q₂ : Type _}

variable [NormedAddCommGroup V] [MetricSpace P] [NormedAddTorsor V P]

variable [NormedAddCommGroup W] [MetricSpace Q] [NormedAddTorsor W Q]

variable [NormedAddCommGroup W₂] [MetricSpace Q₂] [NormedAddTorsor W₂ Q₂]

variable [NormedField R] [NormedSpace R V] [NormedSpace R W] [NormedSpace R W₂]

variable [NontriviallyNormedField 𝕜] [NormedSpace 𝕜 V] [NormedSpace 𝕜 W] [NormedSpace 𝕜 W₂]

#print ContinuousAffineMap.contLinear /-
/-- The linear map underlying a continuous affine map is continuous. -/
def contLinear (f : P →A[R] Q) : V →L[R] W :=
  { f.linear with
    toFun := f.linear
    cont := by rw [AffineMap.continuous_linear_iff]; exact f.cont }
#align continuous_affine_map.cont_linear ContinuousAffineMap.contLinear
-/

#print ContinuousAffineMap.coe_contLinear /-
@[simp]
theorem coe_contLinear (f : P →A[R] Q) : (f.contLinear : V → W) = f.linear :=
  rfl
#align continuous_affine_map.coe_cont_linear ContinuousAffineMap.coe_contLinear
-/

#print ContinuousAffineMap.coe_contLinear_eq_linear /-
@[simp]
theorem coe_contLinear_eq_linear (f : P →A[R] Q) :
    (f.contLinear : V →ₗ[R] W) = (f : P →ᵃ[R] Q).linear := by ext; rfl
#align continuous_affine_map.coe_cont_linear_eq_linear ContinuousAffineMap.coe_contLinear_eq_linear
-/

#print ContinuousAffineMap.coe_mk_const_linear_eq_linear /-
@[simp]
theorem coe_mk_const_linear_eq_linear (f : P →ᵃ[R] Q) (h) :
    ((⟨f, h⟩ : P →A[R] Q).contLinear : V → W) = f.linear :=
  rfl
#align continuous_affine_map.coe_mk_const_linear_eq_linear ContinuousAffineMap.coe_mk_const_linear_eq_linear
-/

#print ContinuousAffineMap.coe_linear_eq_coe_contLinear /-
theorem coe_linear_eq_coe_contLinear (f : P →A[R] Q) :
    ((f : P →ᵃ[R] Q).linear : V → W) = (⇑f.contLinear : V → W) :=
  rfl
#align continuous_affine_map.coe_linear_eq_coe_cont_linear ContinuousAffineMap.coe_linear_eq_coe_contLinear
-/

#print ContinuousAffineMap.comp_contLinear /-
@[simp]
theorem comp_contLinear (f : P →A[R] Q) (g : Q →A[R] Q₂) :
    (g.comp f).contLinear = g.contLinear.comp f.contLinear :=
  rfl
#align continuous_affine_map.comp_cont_linear ContinuousAffineMap.comp_contLinear
-/

#print ContinuousAffineMap.map_vadd /-
@[simp]
theorem map_vadd (f : P →A[R] Q) (p : P) (v : V) : f (v +ᵥ p) = f.contLinear v +ᵥ f p :=
  f.map_vadd' p v
#align continuous_affine_map.map_vadd ContinuousAffineMap.map_vadd
-/

#print ContinuousAffineMap.contLinear_map_vsub /-
@[simp]
theorem contLinear_map_vsub (f : P →A[R] Q) (p₁ p₂ : P) : f.contLinear (p₁ -ᵥ p₂) = f p₁ -ᵥ f p₂ :=
  f.toAffineMap.linearMap_vsub p₁ p₂
#align continuous_affine_map.cont_linear_map_vsub ContinuousAffineMap.contLinear_map_vsub
-/

#print ContinuousAffineMap.const_contLinear /-
@[simp]
theorem const_contLinear (q : Q) : (const R P q).contLinear = 0 :=
  rfl
#align continuous_affine_map.const_cont_linear ContinuousAffineMap.const_contLinear
-/

#print ContinuousAffineMap.contLinear_eq_zero_iff_exists_const /-
theorem contLinear_eq_zero_iff_exists_const (f : P →A[R] Q) :
    f.contLinear = 0 ↔ ∃ q, f = const R P q :=
  by
  have h₁ : f.cont_linear = 0 ↔ (f : P →ᵃ[R] Q).linear = 0 :=
    by
    refine' ⟨fun h => _, fun h => _⟩ <;> ext
    · rw [← coe_cont_linear_eq_linear, h]; rfl
    · rw [← coe_linear_eq_coe_cont_linear, h]; rfl
  have h₂ : ∀ q : Q, f = const R P q ↔ (f : P →ᵃ[R] Q) = AffineMap.const R P q :=
    by
    intro q
    refine' ⟨fun h => _, fun h => _⟩ <;> ext
    · rw [h]; rfl
    · rw [← coe_to_affine_map, h]; rfl
  simp_rw [h₁, h₂]
  exact (f : P →ᵃ[R] Q).linear_eq_zero_iff_exists_const
#align continuous_affine_map.cont_linear_eq_zero_iff_exists_const ContinuousAffineMap.contLinear_eq_zero_iff_exists_const
-/

#print ContinuousAffineMap.to_affine_map_contLinear /-
@[simp]
theorem to_affine_map_contLinear (f : V →L[R] W) : f.toContinuousAffineMap.contLinear = f := by ext;
  rfl
#align continuous_affine_map.to_affine_map_cont_linear ContinuousAffineMap.to_affine_map_contLinear
-/

#print ContinuousAffineMap.zero_contLinear /-
@[simp]
theorem zero_contLinear : (0 : P →A[R] W).contLinear = 0 :=
  rfl
#align continuous_affine_map.zero_cont_linear ContinuousAffineMap.zero_contLinear
-/

#print ContinuousAffineMap.add_contLinear /-
@[simp]
theorem add_contLinear (f g : P →A[R] W) : (f + g).contLinear = f.contLinear + g.contLinear :=
  rfl
#align continuous_affine_map.add_cont_linear ContinuousAffineMap.add_contLinear
-/

#print ContinuousAffineMap.sub_contLinear /-
@[simp]
theorem sub_contLinear (f g : P →A[R] W) : (f - g).contLinear = f.contLinear - g.contLinear :=
  rfl
#align continuous_affine_map.sub_cont_linear ContinuousAffineMap.sub_contLinear
-/

#print ContinuousAffineMap.neg_contLinear /-
@[simp]
theorem neg_contLinear (f : P →A[R] W) : (-f).contLinear = -f.contLinear :=
  rfl
#align continuous_affine_map.neg_cont_linear ContinuousAffineMap.neg_contLinear
-/

#print ContinuousAffineMap.smul_contLinear /-
@[simp]
theorem smul_contLinear (t : R) (f : P →A[R] W) : (t • f).contLinear = t • f.contLinear :=
  rfl
#align continuous_affine_map.smul_cont_linear ContinuousAffineMap.smul_contLinear
-/

#print ContinuousAffineMap.decomp /-
theorem decomp (f : V →A[R] W) : (f : V → W) = f.contLinear + Function.const V (f 0) :=
  by
  rcases f with ⟨f, h⟩
  rw [coe_mk_const_linear_eq_linear, coe_mk, f.decomp, Pi.add_apply, LinearMap.map_zero, zero_add]
#align continuous_affine_map.decomp ContinuousAffineMap.decomp
-/

section NormedSpaceStructure

variable (f : V →A[𝕜] W)

#print ContinuousAffineMap.hasNorm /-
/-- Note that unlike the operator norm for linear maps, this norm is _not_ submultiplicative:
we do _not_ necessarily have `‖f.comp g‖ ≤ ‖f‖ * ‖g‖`. See `norm_comp_le` for what we can say. -/
noncomputable instance hasNorm : Norm (V →A[𝕜] W) :=
  ⟨fun f => max ‖f 0‖ ‖f.contLinear‖⟩
#align continuous_affine_map.has_norm ContinuousAffineMap.hasNorm
-/

#print ContinuousAffineMap.norm_def /-
theorem norm_def : ‖f‖ = max ‖f 0‖ ‖f.contLinear‖ :=
  rfl
#align continuous_affine_map.norm_def ContinuousAffineMap.norm_def
-/

#print ContinuousAffineMap.norm_contLinear_le /-
theorem norm_contLinear_le : ‖f.contLinear‖ ≤ ‖f‖ :=
  le_max_right _ _
#align continuous_affine_map.norm_cont_linear_le ContinuousAffineMap.norm_contLinear_le
-/

#print ContinuousAffineMap.norm_image_zero_le /-
theorem norm_image_zero_le : ‖f 0‖ ≤ ‖f‖ :=
  le_max_left _ _
#align continuous_affine_map.norm_image_zero_le ContinuousAffineMap.norm_image_zero_le
-/

#print ContinuousAffineMap.norm_eq /-
@[simp]
theorem norm_eq (h : f 0 = 0) : ‖f‖ = ‖f.contLinear‖ :=
  calc
    ‖f‖ = max ‖f 0‖ ‖f.contLinear‖ := by rw [norm_def]
    _ = max 0 ‖f.contLinear‖ := by rw [h, norm_zero]
    _ = ‖f.contLinear‖ := max_eq_right (norm_nonneg _)
#align continuous_affine_map.norm_eq ContinuousAffineMap.norm_eq
-/

noncomputable instance : NormedAddCommGroup (V →A[𝕜] W) :=
  AddGroupNorm.toNormedAddCommGroup
    { toFun := fun f => max ‖f 0‖ ‖f.contLinear‖
      map_zero' := by simp
      neg' := fun f => by simp
      add_le' := fun f g =>
        by
        simp only [Pi.add_apply, add_cont_linear, coe_add, max_le_iff]
        exact
          ⟨(norm_add_le _ _).trans (add_le_add (le_max_left _ _) (le_max_left _ _)),
            (norm_add_le _ _).trans (add_le_add (le_max_right _ _) (le_max_right _ _))⟩
      eq_zero_of_map_eq_zero' := fun f h₀ =>
        by
        rcases max_eq_iff.mp h₀ with (⟨h₁, h₂⟩ | ⟨h₁, h₂⟩) <;> rw [h₁] at h₂ 
        · rw [norm_le_zero_iff, cont_linear_eq_zero_iff_exists_const] at h₂ 
          obtain ⟨q, rfl⟩ := h₂
          simp only [Function.const_apply, coe_const, norm_eq_zero] at h₁ 
          rw [h₁]
          rfl
        · rw [norm_eq_zero', cont_linear_eq_zero_iff_exists_const] at h₁ 
          obtain ⟨q, rfl⟩ := h₁
          simp only [Function.const_apply, coe_const, norm_le_zero_iff] at h₂ 
          rw [h₂]
          rfl }

instance : NormedSpace 𝕜 (V →A[𝕜] W)
    where norm_smul_le t f := by
    simp only [norm_def, smul_cont_linear, coe_smul, Pi.smul_apply, norm_smul, ←
      mul_max_of_nonneg _ _ (norm_nonneg t)]

#print ContinuousAffineMap.norm_comp_le /-
theorem norm_comp_le (g : W₂ →A[𝕜] V) : ‖f.comp g‖ ≤ ‖f‖ * ‖g‖ + ‖f 0‖ :=
  by
  rw [norm_def, max_le_iff]
  constructor
  ·
    calc
      ‖f.comp g 0‖ = ‖f (g 0)‖ := by simp
      _ = ‖f.cont_linear (g 0) + f 0‖ := by rw [f.decomp]; simp
      _ ≤ ‖f.cont_linear‖ * ‖g 0‖ + ‖f 0‖ :=
        ((norm_add_le _ _).trans (add_le_add_right (f.cont_linear.le_op_norm _) _))
      _ ≤ ‖f‖ * ‖g‖ + ‖f 0‖ :=
        add_le_add_right
          (mul_le_mul f.norm_cont_linear_le g.norm_image_zero_le (norm_nonneg _) (norm_nonneg _)) _
  ·
    calc
      ‖(f.comp g).contLinear‖ ≤ ‖f.cont_linear‖ * ‖g.cont_linear‖ :=
        (g.comp_cont_linear f).symm ▸ f.cont_linear.op_norm_comp_le _
      _ ≤ ‖f‖ * ‖g‖ :=
        (mul_le_mul f.norm_cont_linear_le g.norm_cont_linear_le (norm_nonneg _) (norm_nonneg _))
      _ ≤ ‖f‖ * ‖g‖ + ‖f 0‖ := by rw [le_add_iff_nonneg_right]; apply norm_nonneg
#align continuous_affine_map.norm_comp_le ContinuousAffineMap.norm_comp_le
-/

variable (𝕜 V W)

#print ContinuousAffineMap.toConstProdContinuousLinearMap /-
/-- The space of affine maps between two normed spaces is linearly isometric to the product of the
codomain with the space of linear maps, by taking the value of the affine map at `(0 : V)` and the
linear part. -/
def toConstProdContinuousLinearMap : (V →A[𝕜] W) ≃ₗᵢ[𝕜] W × (V →L[𝕜] W)
    where
  toFun f := ⟨f 0, f.contLinear⟩
  invFun p := p.2.toContinuousAffineMap + const 𝕜 V p.1
  left_inv f := by ext; rw [f.decomp]; simp
  right_inv := by rintro ⟨v, f⟩; ext <;> simp
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
  norm_map' f := rfl
#align continuous_affine_map.to_const_prod_continuous_linear_map ContinuousAffineMap.toConstProdContinuousLinearMap
-/

#print ContinuousAffineMap.toConstProdContinuousLinearMap_fst /-
@[simp]
theorem toConstProdContinuousLinearMap_fst (f : V →A[𝕜] W) :
    (toConstProdContinuousLinearMap 𝕜 V W f).fst = f 0 :=
  rfl
#align continuous_affine_map.to_const_prod_continuous_linear_map_fst ContinuousAffineMap.toConstProdContinuousLinearMap_fst
-/

#print ContinuousAffineMap.toConstProdContinuousLinearMap_snd /-
@[simp]
theorem toConstProdContinuousLinearMap_snd (f : V →A[𝕜] W) :
    (toConstProdContinuousLinearMap 𝕜 V W f).snd = f.contLinear :=
  rfl
#align continuous_affine_map.to_const_prod_continuous_linear_map_snd ContinuousAffineMap.toConstProdContinuousLinearMap_snd
-/

end NormedSpaceStructure

end ContinuousAffineMap

