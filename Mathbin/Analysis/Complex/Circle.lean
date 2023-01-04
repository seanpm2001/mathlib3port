/-
Copyright (c) 2021 Heather Macbeth. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Heather Macbeth

! This file was ported from Lean 3 source module analysis.complex.circle
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Exp
import Mathbin.Topology.ContinuousFunction.Basic
import Mathbin.Analysis.Normed.Field.UnitBall

/-!
# The circle

This file defines `circle` to be the metric sphere (`metric.sphere`) in `ℂ` centred at `0` of
radius `1`.  We equip it with the following structure:

* a submonoid of `ℂ`
* a group
* a topological group

We furthermore define `exp_map_circle` to be the natural map `λ t, exp (t * I)` from `ℝ` to
`circle`, and show that this map is a group homomorphism.

## Implementation notes

Because later (in `geometry.manifold.instances.sphere`) one wants to equip the circle with a smooth
manifold structure borrowed from `metric.sphere`, the underlying set is
`{z : ℂ | abs (z - 0) = 1}`.  This prevents certain algebraic facts from working definitionally --
for example, the circle is not defeq to `{z : ℂ | abs z = 1}`, which is the kernel of `complex.abs`
considered as a homomorphism from `ℂ` to `ℝ`, nor is it defeq to `{z : ℂ | norm_sq z = 1}`, which
is the kernel of the homomorphism `complex.norm_sq` from `ℂ` to `ℝ`.

-/


noncomputable section

open Complex Metric

open ComplexConjugate

/-- The unit circle in `ℂ`, here given the structure of a submonoid of `ℂ`. -/
def circle : Submonoid ℂ :=
  Submonoid.unitSphere ℂ
#align circle circle

@[simp]
theorem mem_circle_iff_abs {z : ℂ} : z ∈ circle ↔ abs z = 1 :=
  mem_sphere_zero_iff_norm
#align mem_circle_iff_abs mem_circle_iff_abs

theorem circle_def : ↑circle = { z : ℂ | abs z = 1 } :=
  Set.ext fun z => mem_circle_iff_abs
#align circle_def circle_def

@[simp]
theorem abs_coe_circle (z : circle) : abs z = 1 :=
  mem_circle_iff_abs.mp z.2
#align abs_coe_circle abs_coe_circle

theorem mem_circle_iff_norm_sq {z : ℂ} : z ∈ circle ↔ normSq z = 1 := by simp [Complex.abs]
#align mem_circle_iff_norm_sq mem_circle_iff_norm_sq

@[simp]
theorem norm_sq_eq_of_mem_circle (z : circle) : normSq z = 1 := by simp [norm_sq_eq_abs]
#align norm_sq_eq_of_mem_circle norm_sq_eq_of_mem_circle

theorem ne_zero_of_mem_circle (z : circle) : (z : ℂ) ≠ 0 :=
  ne_zero_of_mem_unit_sphere z
#align ne_zero_of_mem_circle ne_zero_of_mem_circle

instance : CommGroup circle :=
  Metric.sphere.commGroup

@[simp]
theorem coe_inv_circle (z : circle) : ↑z⁻¹ = (z : ℂ)⁻¹ :=
  rfl
#align coe_inv_circle coe_inv_circle

theorem coe_inv_circle_eq_conj (z : circle) : ↑z⁻¹ = conj (z : ℂ) := by
  rw [coe_inv_circle, inv_def, norm_sq_eq_of_mem_circle, inv_one, of_real_one, mul_one]
#align coe_inv_circle_eq_conj coe_inv_circle_eq_conj

@[simp]
theorem coe_div_circle (z w : circle) : ↑(z / w) = (z : ℂ) / w :=
  circle.Subtype.map_div z w
#align coe_div_circle coe_div_circle

/-- The elements of the circle embed into the units. -/
def circle.toUnits : circle →* Units ℂ :=
  unitSphereToUnits ℂ
#align circle.to_units circle.toUnits

-- written manually because `@[simps]` was slow and generated the wrong lemma
@[simp]
theorem circle.to_units_apply (z : circle) :
    circle.toUnits z = Units.mk0 z (ne_zero_of_mem_circle z) :=
  rfl
#align circle.to_units_apply circle.to_units_apply

instance : CompactSpace circle :=
  Metric.sphere.compact_space _ _

instance : TopologicalGroup circle :=
  Metric.sphere.topological_group

/-- If `z` is a nonzero complex number, then `conj z / z` belongs to the unit circle. -/
@[simps]
def circle.ofConjDivSelf (z : ℂ) (hz : z ≠ 0) : circle :=
  ⟨conj z / z,
    mem_circle_iff_abs.2 <| by rw [map_div₀, abs_conj, div_self (complex.abs.ne_zero hz)]⟩
#align circle.of_conj_div_self circle.ofConjDivSelf

/-- The map `λ t, exp (t * I)` from `ℝ` to the unit circle in `ℂ`. -/
def expMapCircle : C(ℝ, circle)
    where toFun t := ⟨exp (t * I), by simp [exp_mul_I, abs_cos_add_sin_mul_I]⟩
#align exp_map_circle expMapCircle

@[simp]
theorem exp_map_circle_apply (t : ℝ) : ↑(expMapCircle t) = Complex.exp (t * Complex.i) :=
  rfl
#align exp_map_circle_apply exp_map_circle_apply

@[simp]
theorem exp_map_circle_zero : expMapCircle 0 = 1 :=
  Subtype.ext <| by rw [exp_map_circle_apply, of_real_zero, zero_mul, exp_zero, Submonoid.coe_one]
#align exp_map_circle_zero exp_map_circle_zero

@[simp]
theorem exp_map_circle_add (x y : ℝ) : expMapCircle (x + y) = expMapCircle x * expMapCircle y :=
  Subtype.ext <| by
    simp only [exp_map_circle_apply, Submonoid.coe_mul, of_real_add, add_mul, Complex.exp_add]
#align exp_map_circle_add exp_map_circle_add

/-- The map `λ t, exp (t * I)` from `ℝ` to the unit circle in `ℂ`, considered as a homomorphism of
groups. -/
@[simps]
def expMapCircleHom : ℝ →+ Additive circle
    where
  toFun := Additive.ofMul ∘ expMapCircle
  map_zero' := exp_map_circle_zero
  map_add' := exp_map_circle_add
#align exp_map_circle_hom expMapCircleHom

@[simp]
theorem exp_map_circle_sub (x y : ℝ) : expMapCircle (x - y) = expMapCircle x / expMapCircle y :=
  expMapCircleHom.map_sub x y
#align exp_map_circle_sub exp_map_circle_sub

@[simp]
theorem exp_map_circle_neg (x : ℝ) : expMapCircle (-x) = (expMapCircle x)⁻¹ :=
  expMapCircleHom.map_neg x
#align exp_map_circle_neg exp_map_circle_neg

