/-
Copyright (c) 2019 Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zhouhang Zhou, Yury Kudryashov, Sébastien Gouëzel, Rémy Degenne

! This file was ported from Lean 3 source module measure_theory.integral.bochner
! leanprover-community/mathlib commit 36938f775671ff28bea1c0310f1608e4afbb22e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Integral.SetToL1

/-!
# Bochner integral

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The Bochner integral extends the definition of the Lebesgue integral to functions that map from a
measure space into a Banach space (complete normed vector space). It is constructed here by
extending the integral on simple functions.

## Main definitions

The Bochner integral is defined through the extension process described in the file `set_to_L1`,
which follows these steps:

1. Define the integral of the indicator of a set. This is `weighted_smul μ s x = (μ s).to_real * x`.
  `weighted_smul μ` is shown to be linear in the value `x` and `dominated_fin_meas_additive`
  (defined in the file `set_to_L1`) with respect to the set `s`.

2. Define the integral on simple functions of the type `simple_func α E` (notation : `α →ₛ E`)
  where `E` is a real normed space. (See `simple_func.integral` for details.)

3. Transfer this definition to define the integral on `L1.simple_func α E` (notation :
  `α →₁ₛ[μ] E`), see `L1.simple_func.integral`. Show that this integral is a continuous linear
  map from `α →₁ₛ[μ] E` to `E`.

4. Define the Bochner integral on L1 functions by extending the integral on integrable simple
  functions `α →₁ₛ[μ] E` using `continuous_linear_map.extend` and the fact that the embedding of
  `α →₁ₛ[μ] E` into `α →₁[μ] E` is dense.

5. Define the Bochner integral on functions as the Bochner integral of its equivalence class in L1
  space, if it is in L1, and 0 otherwise.

The result of that construction is `∫ a, f a ∂μ`, which is definitionally equal to
`set_to_fun (dominated_fin_meas_additive_weighted_smul μ) f`. Some basic properties of the integral
(like linearity) are particular cases of the properties of `set_to_fun` (which are described in the
file `set_to_L1`).

## Main statements

1. Basic properties of the Bochner integral on functions of type `α → E`, where `α` is a measure
   space and `E` is a real normed space.

  * `integral_zero`                  : `∫ 0 ∂μ = 0`
  * `integral_add`                   : `∫ x, f x + g x ∂μ = ∫ x, f ∂μ + ∫ x, g x ∂μ`
  * `integral_neg`                   : `∫ x, - f x ∂μ = - ∫ x, f x ∂μ`
  * `integral_sub`                   : `∫ x, f x - g x ∂μ = ∫ x, f x ∂μ - ∫ x, g x ∂μ`
  * `integral_smul`                  : `∫ x, r • f x ∂μ = r • ∫ x, f x ∂μ`
  * `integral_congr_ae`              : `f =ᵐ[μ] g → ∫ x, f x ∂μ = ∫ x, g x ∂μ`
  * `norm_integral_le_integral_norm` : `‖∫ x, f x ∂μ‖ ≤ ∫ x, ‖f x‖ ∂μ`

2. Basic properties of the Bochner integral on functions of type `α → ℝ`, where `α` is a measure
  space.

  * `integral_nonneg_of_ae` : `0 ≤ᵐ[μ] f → 0 ≤ ∫ x, f x ∂μ`
  * `integral_nonpos_of_ae` : `f ≤ᵐ[μ] 0 → ∫ x, f x ∂μ ≤ 0`
  * `integral_mono_ae`      : `f ≤ᵐ[μ] g → ∫ x, f x ∂μ ≤ ∫ x, g x ∂μ`
  * `integral_nonneg`       : `0 ≤ f → 0 ≤ ∫ x, f x ∂μ`
  * `integral_nonpos`       : `f ≤ 0 → ∫ x, f x ∂μ ≤ 0`
  * `integral_mono`         : `f ≤ᵐ[μ] g → ∫ x, f x ∂μ ≤ ∫ x, g x ∂μ`

3. Propositions connecting the Bochner integral with the integral on `ℝ≥0∞`-valued functions,
   which is called `lintegral` and has the notation `∫⁻`.

  * `integral_eq_lintegral_max_sub_lintegral_min` : `∫ x, f x ∂μ = ∫⁻ x, f⁺ x ∂μ - ∫⁻ x, f⁻ x ∂μ`,
    where `f⁺` is the positive part of `f` and `f⁻` is the negative part of `f`.
  * `integral_eq_lintegral_of_nonneg_ae`          : `0 ≤ᵐ[μ] f → ∫ x, f x ∂μ = ∫⁻ x, f x ∂μ`

4. `tendsto_integral_of_dominated_convergence` : the Lebesgue dominated convergence theorem

5. (In the file `set_integral`) integration commutes with continuous linear maps.

  * `continuous_linear_map.integral_comp_comm`
  * `linear_isometry.integral_comp_comm`


## Notes

Some tips on how to prove a proposition if the API for the Bochner integral is not enough so that
you need to unfold the definition of the Bochner integral and go back to simple functions.

One method is to use the theorem `integrable.induction` in the file `simple_func_dense_lp` (or one
of the related results, like `Lp.induction` for functions in `Lp`), which allows you to prove
something for an arbitrary integrable function.

Another method is using the following steps.
See `integral_eq_lintegral_max_sub_lintegral_min` for a complicated example, which proves that
`∫ f = ∫⁻ f⁺ - ∫⁻ f⁻`, with the first integral sign being the Bochner integral of a real-valued
function `f : α → ℝ`, and second and third integral sign being the integral on `ℝ≥0∞`-valued
functions (called `lintegral`). The proof of `integral_eq_lintegral_max_sub_lintegral_min` is
scattered in sections with the name `pos_part`.

Here are the usual steps of proving that a property `p`, say `∫ f = ∫⁻ f⁺ - ∫⁻ f⁻`, holds for all
functions :

1. First go to the `L¹` space.

   For example, if you see `ennreal.to_real (∫⁻ a, ennreal.of_real $ ‖f a‖)`, that is the norm of
   `f` in `L¹` space. Rewrite using `L1.norm_of_fun_eq_lintegral_norm`.

2. Show that the set `{f ∈ L¹ | ∫ f = ∫⁻ f⁺ - ∫⁻ f⁻}` is closed in `L¹` using `is_closed_eq`.

3. Show that the property holds for all simple functions `s` in `L¹` space.

   Typically, you need to convert various notions to their `simple_func` counterpart, using lemmas
   like `L1.integral_coe_eq_integral`.

4. Since simple functions are dense in `L¹`,
```
univ = closure {s simple}
     = closure {s simple | ∫ s = ∫⁻ s⁺ - ∫⁻ s⁻} : the property holds for all simple functions
     ⊆ closure {f | ∫ f = ∫⁻ f⁺ - ∫⁻ f⁻}
     = {f | ∫ f = ∫⁻ f⁺ - ∫⁻ f⁻} : closure of a closed set is itself
```
Use `is_closed_property` or `dense_range.induction_on` for this argument.

## Notations

* `α →ₛ E`  : simple functions (defined in `measure_theory/integration`)
* `α →₁[μ] E` : functions in L1 space, i.e., equivalence classes of integrable functions (defined in
                `measure_theory/lp_space`)
* `α →₁ₛ[μ] E` : simple functions in L1 space, i.e., equivalence classes of integrable simple
                 functions (defined in `measure_theory/simple_func_dense`)
* `∫ a, f a ∂μ` : integral of `f` with respect to a measure `μ`
* `∫ a, f a` : integral of `f` with respect to `volume`, the default measure on the ambient type

We also define notations for integral on a set, which are described in the file
`measure_theory/set_integral`.

Note : `ₛ` is typed using `\_s`. Sometimes it shows as a box if the font is missing.

## Tags

Bochner integral, simple function, function space, Lebesgue dominated convergence theorem

-/


assert_not_exists Differentiable

noncomputable section

open scoped Topology BigOperators NNReal ENNReal MeasureTheory

open Set Filter TopologicalSpace ENNReal Emetric

namespace MeasureTheory

variable {α E F 𝕜 : Type _}

section WeightedSmul

open ContinuousLinearMap

variable [NormedAddCommGroup F] [NormedSpace ℝ F] {m : MeasurableSpace α} {μ : Measure α}

#print MeasureTheory.weightedSMul /-
/-- Given a set `s`, return the continuous linear map `λ x, (μ s).to_real • x`. The extension of
that set function through `set_to_L1` gives the Bochner integral of L1 functions. -/
def weightedSMul {m : MeasurableSpace α} (μ : Measure α) (s : Set α) : F →L[ℝ] F :=
  (μ s).toReal • ContinuousLinearMap.id ℝ F
#align measure_theory.weighted_smul MeasureTheory.weightedSMul
-/

#print MeasureTheory.weightedSMul_apply /-
theorem weightedSMul_apply {m : MeasurableSpace α} (μ : Measure α) (s : Set α) (x : F) :
    weightedSMul μ s x = (μ s).toReal • x := by simp [weighted_smul]
#align measure_theory.weighted_smul_apply MeasureTheory.weightedSMul_apply
-/

#print MeasureTheory.weightedSMul_zero_measure /-
@[simp]
theorem weightedSMul_zero_measure {m : MeasurableSpace α} :
    weightedSMul (0 : Measure α) = (0 : Set α → F →L[ℝ] F) := by ext1; simp [weighted_smul]
#align measure_theory.weighted_smul_zero_measure MeasureTheory.weightedSMul_zero_measure
-/

#print MeasureTheory.weightedSMul_empty /-
@[simp]
theorem weightedSMul_empty {m : MeasurableSpace α} (μ : Measure α) :
    weightedSMul μ ∅ = (0 : F →L[ℝ] F) := by ext1 x; rw [weighted_smul_apply]; simp
#align measure_theory.weighted_smul_empty MeasureTheory.weightedSMul_empty
-/

#print MeasureTheory.weightedSMul_add_measure /-
theorem weightedSMul_add_measure {m : MeasurableSpace α} (μ ν : Measure α) {s : Set α}
    (hμs : μ s ≠ ∞) (hνs : ν s ≠ ∞) :
    (weightedSMul (μ + ν) s : F →L[ℝ] F) = weightedSMul μ s + weightedSMul ν s :=
  by
  ext1 x
  push_cast
  simp_rw [Pi.add_apply, weighted_smul_apply]
  push_cast
  rw [Pi.add_apply, ENNReal.toReal_add hμs hνs, add_smul]
#align measure_theory.weighted_smul_add_measure MeasureTheory.weightedSMul_add_measure
-/

#print MeasureTheory.weightedSMul_smul_measure /-
theorem weightedSMul_smul_measure {m : MeasurableSpace α} (μ : Measure α) (c : ℝ≥0∞) {s : Set α} :
    (weightedSMul (c • μ) s : F →L[ℝ] F) = c.toReal • weightedSMul μ s :=
  by
  ext1 x
  push_cast
  simp_rw [Pi.smul_apply, weighted_smul_apply]
  push_cast
  simp_rw [Pi.smul_apply, smul_eq_mul, to_real_mul, smul_smul]
#align measure_theory.weighted_smul_smul_measure MeasureTheory.weightedSMul_smul_measure
-/

#print MeasureTheory.weightedSMul_congr /-
theorem weightedSMul_congr (s t : Set α) (hst : μ s = μ t) :
    (weightedSMul μ s : F →L[ℝ] F) = weightedSMul μ t := by ext1 x; simp_rw [weighted_smul_apply];
  congr 2
#align measure_theory.weighted_smul_congr MeasureTheory.weightedSMul_congr
-/

#print MeasureTheory.weightedSMul_null /-
theorem weightedSMul_null {s : Set α} (h_zero : μ s = 0) : (weightedSMul μ s : F →L[ℝ] F) = 0 := by
  ext1 x; rw [weighted_smul_apply, h_zero]; simp
#align measure_theory.weighted_smul_null MeasureTheory.weightedSMul_null
-/

#print MeasureTheory.weightedSMul_union' /-
theorem weightedSMul_union' (s t : Set α) (ht : MeasurableSet t) (hs_finite : μ s ≠ ∞)
    (ht_finite : μ t ≠ ∞) (h_inter : s ∩ t = ∅) :
    (weightedSMul μ (s ∪ t) : F →L[ℝ] F) = weightedSMul μ s + weightedSMul μ t :=
  by
  ext1 x
  simp_rw [add_apply, weighted_smul_apply,
    measure_union (set.disjoint_iff_inter_eq_empty.mpr h_inter) ht,
    ENNReal.toReal_add hs_finite ht_finite, add_smul]
#align measure_theory.weighted_smul_union' MeasureTheory.weightedSMul_union'
-/

#print MeasureTheory.weightedSMul_union /-
@[nolint unused_arguments]
theorem weightedSMul_union (s t : Set α) (hs : MeasurableSet s) (ht : MeasurableSet t)
    (hs_finite : μ s ≠ ∞) (ht_finite : μ t ≠ ∞) (h_inter : s ∩ t = ∅) :
    (weightedSMul μ (s ∪ t) : F →L[ℝ] F) = weightedSMul μ s + weightedSMul μ t :=
  weightedSMul_union' s t ht hs_finite ht_finite h_inter
#align measure_theory.weighted_smul_union MeasureTheory.weightedSMul_union
-/

#print MeasureTheory.weightedSMul_smul /-
theorem weightedSMul_smul [NormedField 𝕜] [NormedSpace 𝕜 F] [SMulCommClass ℝ 𝕜 F] (c : 𝕜)
    (s : Set α) (x : F) : weightedSMul μ s (c • x) = c • weightedSMul μ s x := by
  simp_rw [weighted_smul_apply, smul_comm]
#align measure_theory.weighted_smul_smul MeasureTheory.weightedSMul_smul
-/

#print MeasureTheory.norm_weightedSMul_le /-
theorem norm_weightedSMul_le (s : Set α) : ‖(weightedSMul μ s : F →L[ℝ] F)‖ ≤ (μ s).toReal :=
  calc
    ‖(weightedSMul μ s : F →L[ℝ] F)‖ = ‖(μ s).toReal‖ * ‖ContinuousLinearMap.id ℝ F‖ :=
      norm_smul _ _
    _ ≤ ‖(μ s).toReal‖ :=
      ((mul_le_mul_of_nonneg_left norm_id_le (norm_nonneg _)).trans (mul_one _).le)
    _ = abs (μ s).toReal := (Real.norm_eq_abs _)
    _ = (μ s).toReal := abs_eq_self.mpr ENNReal.toReal_nonneg
#align measure_theory.norm_weighted_smul_le MeasureTheory.norm_weightedSMul_le
-/

#print MeasureTheory.dominatedFinMeasAdditive_weightedSMul /-
theorem dominatedFinMeasAdditive_weightedSMul {m : MeasurableSpace α} (μ : Measure α) :
    DominatedFinMeasAdditive μ (weightedSMul μ : Set α → F →L[ℝ] F) 1 :=
  ⟨weightedSMul_union, fun s _ _ => (norm_weightedSMul_le s).trans (one_mul _).symm.le⟩
#align measure_theory.dominated_fin_meas_additive_weighted_smul MeasureTheory.dominatedFinMeasAdditive_weightedSMul
-/

#print MeasureTheory.weightedSMul_nonneg /-
theorem weightedSMul_nonneg (s : Set α) (x : ℝ) (hx : 0 ≤ x) : 0 ≤ weightedSMul μ s x :=
  by
  simp only [weighted_smul, Algebra.id.smul_eq_mul, coe_smul', id.def, coe_id', Pi.smul_apply]
  exact mul_nonneg to_real_nonneg hx
#align measure_theory.weighted_smul_nonneg MeasureTheory.weightedSMul_nonneg
-/

end WeightedSmul

local infixr:25 " →ₛ " => SimpleFunc

namespace SimpleFunc

section PosPart

variable [LinearOrder E] [Zero E] [MeasurableSpace α]

#print MeasureTheory.SimpleFunc.posPart /-
/-- Positive part of a simple function. -/
def posPart (f : α →ₛ E) : α →ₛ E :=
  f.map fun b => max b 0
#align measure_theory.simple_func.pos_part MeasureTheory.SimpleFunc.posPart
-/

#print MeasureTheory.SimpleFunc.negPart /-
/-- Negative part of a simple function. -/
def negPart [Neg E] (f : α →ₛ E) : α →ₛ E :=
  posPart (-f)
#align measure_theory.simple_func.neg_part MeasureTheory.SimpleFunc.negPart
-/

#print MeasureTheory.SimpleFunc.posPart_map_norm /-
theorem posPart_map_norm (f : α →ₛ ℝ) : (posPart f).map norm = posPart f := by ext;
  rw [map_apply, Real.norm_eq_abs, abs_of_nonneg]; exact le_max_right _ _
#align measure_theory.simple_func.pos_part_map_norm MeasureTheory.SimpleFunc.posPart_map_norm
-/

#print MeasureTheory.SimpleFunc.negPart_map_norm /-
theorem negPart_map_norm (f : α →ₛ ℝ) : (negPart f).map norm = negPart f := by rw [neg_part];
  exact pos_part_map_norm _
#align measure_theory.simple_func.neg_part_map_norm MeasureTheory.SimpleFunc.negPart_map_norm
-/

#print MeasureTheory.SimpleFunc.posPart_sub_negPart /-
theorem posPart_sub_negPart (f : α →ₛ ℝ) : f.posPart - f.neg_part = f :=
  by
  simp only [pos_part, neg_part]
  ext a
  rw [coe_sub]
  exact max_zero_sub_eq_self (f a)
#align measure_theory.simple_func.pos_part_sub_neg_part MeasureTheory.SimpleFunc.posPart_sub_negPart
-/

end PosPart

section Integral

/-!
### The Bochner integral of simple functions

Define the Bochner integral of simple functions of the type `α →ₛ β` where `β` is a normed group,
and prove basic property of this integral.
-/


open Finset

variable [NormedAddCommGroup E] [NormedAddCommGroup F] [NormedSpace ℝ F] {p : ℝ≥0∞} {G F' : Type _}
  [NormedAddCommGroup G] [NormedAddCommGroup F'] [NormedSpace ℝ F'] {m : MeasurableSpace α}
  {μ : Measure α}

#print MeasureTheory.SimpleFunc.integral /-
/-- Bochner integral of simple functions whose codomain is a real `normed_space`.
This is equal to `∑ x in f.range, (μ (f ⁻¹' {x})).to_real • x` (see `integral_eq`). -/
def integral {m : MeasurableSpace α} (μ : Measure α) (f : α →ₛ F) : F :=
  f.setToSimpleFunc (weightedSMul μ)
#align measure_theory.simple_func.integral MeasureTheory.SimpleFunc.integral
-/

#print MeasureTheory.SimpleFunc.integral_def /-
theorem integral_def {m : MeasurableSpace α} (μ : Measure α) (f : α →ₛ F) :
    f.integral μ = f.setToSimpleFunc (weightedSMul μ) :=
  rfl
#align measure_theory.simple_func.integral_def MeasureTheory.SimpleFunc.integral_def
-/

#print MeasureTheory.SimpleFunc.integral_eq /-
theorem integral_eq {m : MeasurableSpace α} (μ : Measure α) (f : α →ₛ F) :
    f.integral μ = ∑ x in f.range, (μ (f ⁻¹' {x})).toReal • x := by
  simp [integral, set_to_simple_func, weighted_smul_apply]
#align measure_theory.simple_func.integral_eq MeasureTheory.SimpleFunc.integral_eq
-/

#print MeasureTheory.SimpleFunc.integral_eq_sum_filter /-
theorem integral_eq_sum_filter [DecidablePred fun x : F => x ≠ 0] {m : MeasurableSpace α}
    (f : α →ₛ F) (μ : Measure α) :
    f.integral μ = ∑ x in f.range.filterₓ fun x => x ≠ 0, (μ (f ⁻¹' {x})).toReal • x := by
  rw [integral_def, set_to_simple_func_eq_sum_filter]; simp_rw [weighted_smul_apply]; congr
#align measure_theory.simple_func.integral_eq_sum_filter MeasureTheory.SimpleFunc.integral_eq_sum_filter
-/

#print MeasureTheory.SimpleFunc.integral_eq_sum_of_subset /-
/-- The Bochner integral is equal to a sum over any set that includes `f.range` (except `0`). -/
theorem integral_eq_sum_of_subset [DecidablePred fun x : F => x ≠ 0] {f : α →ₛ F} {s : Finset F}
    (hs : (f.range.filterₓ fun x => x ≠ 0) ⊆ s) :
    f.integral μ = ∑ x in s, (μ (f ⁻¹' {x})).toReal • x :=
  by
  rw [simple_func.integral_eq_sum_filter, Finset.sum_subset hs]
  rintro x - hx; rw [Finset.mem_filter, not_and_or, Ne.def, Classical.not_not] at hx 
  rcases hx with (hx | rfl) <;> [skip; simp]
  rw [simple_func.mem_range] at hx ;
  rw [preimage_eq_empty] <;> simp [Set.disjoint_singleton_left, hx]
#align measure_theory.simple_func.integral_eq_sum_of_subset MeasureTheory.SimpleFunc.integral_eq_sum_of_subset
-/

#print MeasureTheory.SimpleFunc.integral_const /-
@[simp]
theorem integral_const {m : MeasurableSpace α} (μ : Measure α) (y : F) :
    (const α y).integral μ = (μ univ).toReal • y := by
  classical calc
    (const α y).integral μ = ∑ z in {y}, (μ (const α y ⁻¹' {z})).toReal • z :=
      integral_eq_sum_of_subset <| (filter_subset _ _).trans (range_const_subset _ _)
    _ = (μ univ).toReal • y := by simp
#align measure_theory.simple_func.integral_const MeasureTheory.SimpleFunc.integral_const
-/

#print MeasureTheory.SimpleFunc.integral_piecewise_zero /-
@[simp]
theorem integral_piecewise_zero {m : MeasurableSpace α} (f : α →ₛ F) (μ : Measure α) {s : Set α}
    (hs : MeasurableSet s) : (piecewise s hs f 0).integral μ = f.integral (μ.restrict s) := by
  classical
  refine'
    (integral_eq_sum_of_subset _).trans
      ((sum_congr rfl fun y hy => _).trans (integral_eq_sum_filter _ _).symm)
  · intro y hy
    simp only [mem_filter, mem_range, coe_piecewise, coe_zero, piecewise_eq_indicator,
      mem_range_indicator] at *
    rcases hy with ⟨⟨rfl, -⟩ | ⟨x, hxs, rfl⟩, h₀⟩
    exacts [(h₀ rfl).elim, ⟨Set.mem_range_self _, h₀⟩]
  · dsimp
    rw [Set.piecewise_eq_indicator, indicator_preimage_of_not_mem,
      measure.restrict_apply (f.measurable_set_preimage _)]
    exact fun h₀ => (mem_filter.1 hy).2 (Eq.symm h₀)
#align measure_theory.simple_func.integral_piecewise_zero MeasureTheory.SimpleFunc.integral_piecewise_zero
-/

#print MeasureTheory.SimpleFunc.map_integral /-
/-- Calculate the integral of `g ∘ f : α →ₛ F`, where `f` is an integrable function from `α` to `E`
    and `g` is a function from `E` to `F`. We require `g 0 = 0` so that `g ∘ f` is integrable. -/
theorem map_integral (f : α →ₛ E) (g : E → F) (hf : Integrable f μ) (hg : g 0 = 0) :
    (f.map g).integral μ = ∑ x in f.range, ENNReal.toReal (μ (f ⁻¹' {x})) • g x :=
  map_setToSimpleFunc _ weightedSMul_union hf hg
#align measure_theory.simple_func.map_integral MeasureTheory.SimpleFunc.map_integral
-/

#print MeasureTheory.SimpleFunc.integral_eq_lintegral' /-
/-- `simple_func.integral` and `simple_func.lintegral` agree when the integrand has type
    `α →ₛ ℝ≥0∞`. But since `ℝ≥0∞` is not a `normed_space`, we need some form of coercion.
    See `integral_eq_lintegral` for a simpler version. -/
theorem integral_eq_lintegral' {f : α →ₛ E} {g : E → ℝ≥0∞} (hf : Integrable f μ) (hg0 : g 0 = 0)
    (ht : ∀ b, g b ≠ ∞) :
    (f.map (ENNReal.toReal ∘ g)).integral μ = ENNReal.toReal (∫⁻ a, g (f a) ∂μ) :=
  by
  have hf' : f.fin_meas_supp μ := integrable_iff_fin_meas_supp.1 hf
  simp only [← map_apply g f, lintegral_eq_lintegral]
  rw [map_integral f _ hf, map_lintegral, ENNReal.toReal_sum]
  · refine' Finset.sum_congr rfl fun b hb => _
    rw [smul_eq_mul, to_real_mul, mul_comm]
  · intro a ha
    by_cases a0 : a = 0
    · rw [a0, hg0, MulZeroClass.zero_mul]; exact WithTop.zero_ne_top
    · apply mul_ne_top (ht a) (hf'.meas_preimage_singleton_ne_zero a0).Ne
  · simp [hg0]
#align measure_theory.simple_func.integral_eq_lintegral' MeasureTheory.SimpleFunc.integral_eq_lintegral'
-/

variable [NormedField 𝕜] [NormedSpace 𝕜 E] [NormedSpace ℝ E] [SMulCommClass ℝ 𝕜 E]

#print MeasureTheory.SimpleFunc.integral_congr /-
theorem integral_congr {f g : α →ₛ E} (hf : Integrable f μ) (h : f =ᵐ[μ] g) :
    f.integral μ = g.integral μ :=
  setToSimpleFunc_congr (weightedSMul μ) (fun s hs => weightedSMul_null) weightedSMul_union hf h
#align measure_theory.simple_func.integral_congr MeasureTheory.SimpleFunc.integral_congr
-/

#print MeasureTheory.SimpleFunc.integral_eq_lintegral /-
/-- `simple_func.bintegral` and `simple_func.integral` agree when the integrand has type
    `α →ₛ ℝ≥0∞`. But since `ℝ≥0∞` is not a `normed_space`, we need some form of coercion. -/
theorem integral_eq_lintegral {f : α →ₛ ℝ} (hf : Integrable f μ) (h_pos : 0 ≤ᵐ[μ] f) :
    f.integral μ = ENNReal.toReal (∫⁻ a, ENNReal.ofReal (f a) ∂μ) :=
  by
  have : f =ᵐ[μ] f.map (ENNReal.toReal ∘ ENNReal.ofReal) :=
    h_pos.mono fun a h => (ENNReal.toReal_ofReal h).symm
  rw [← integral_eq_lintegral' hf]
  exacts [integral_congr hf this, ENNReal.ofReal_zero, fun b => ENNReal.ofReal_ne_top]
#align measure_theory.simple_func.integral_eq_lintegral MeasureTheory.SimpleFunc.integral_eq_lintegral
-/

#print MeasureTheory.SimpleFunc.integral_add /-
theorem integral_add {f g : α →ₛ E} (hf : Integrable f μ) (hg : Integrable g μ) :
    integral μ (f + g) = integral μ f + integral μ g :=
  setToSimpleFunc_add _ weightedSMul_union hf hg
#align measure_theory.simple_func.integral_add MeasureTheory.SimpleFunc.integral_add
-/

#print MeasureTheory.SimpleFunc.integral_neg /-
theorem integral_neg {f : α →ₛ E} (hf : Integrable f μ) : integral μ (-f) = -integral μ f :=
  setToSimpleFunc_neg _ weightedSMul_union hf
#align measure_theory.simple_func.integral_neg MeasureTheory.SimpleFunc.integral_neg
-/

#print MeasureTheory.SimpleFunc.integral_sub /-
theorem integral_sub {f g : α →ₛ E} (hf : Integrable f μ) (hg : Integrable g μ) :
    integral μ (f - g) = integral μ f - integral μ g :=
  setToSimpleFunc_sub _ weightedSMul_union hf hg
#align measure_theory.simple_func.integral_sub MeasureTheory.SimpleFunc.integral_sub
-/

#print MeasureTheory.SimpleFunc.integral_smul /-
theorem integral_smul (c : 𝕜) {f : α →ₛ E} (hf : Integrable f μ) :
    integral μ (c • f) = c • integral μ f :=
  setToSimpleFunc_smul _ weightedSMul_union weightedSMul_smul c hf
#align measure_theory.simple_func.integral_smul MeasureTheory.SimpleFunc.integral_smul
-/

#print MeasureTheory.SimpleFunc.norm_setToSimpleFunc_le_integral_norm /-
theorem norm_setToSimpleFunc_le_integral_norm (T : Set α → E →L[ℝ] F) {C : ℝ}
    (hT_norm : ∀ s, MeasurableSet s → μ s < ∞ → ‖T s‖ ≤ C * (μ s).toReal) {f : α →ₛ E}
    (hf : Integrable f μ) : ‖f.setToSimpleFunc T‖ ≤ C * (f.map norm).integral μ :=
  calc
    ‖f.setToSimpleFunc T‖ ≤ C * ∑ x in f.range, ENNReal.toReal (μ (f ⁻¹' {x})) * ‖x‖ :=
      norm_setToSimpleFunc_le_sum_mul_norm_of_integrable T hT_norm f hf
    _ = C * (f.map norm).integral μ := by rw [map_integral f norm hf norm_zero];
      simp_rw [smul_eq_mul]
#align measure_theory.simple_func.norm_set_to_simple_func_le_integral_norm MeasureTheory.SimpleFunc.norm_setToSimpleFunc_le_integral_norm
-/

#print MeasureTheory.SimpleFunc.norm_integral_le_integral_norm /-
theorem norm_integral_le_integral_norm (f : α →ₛ E) (hf : Integrable f μ) :
    ‖f.integral μ‖ ≤ (f.map norm).integral μ :=
  by
  refine' (norm_set_to_simple_func_le_integral_norm _ (fun s _ _ => _) hf).trans (one_mul _).le
  exact (norm_weighted_smul_le s).trans (one_mul _).symm.le
#align measure_theory.simple_func.norm_integral_le_integral_norm MeasureTheory.SimpleFunc.norm_integral_le_integral_norm
-/

#print MeasureTheory.SimpleFunc.integral_add_measure /-
theorem integral_add_measure {ν} (f : α →ₛ E) (hf : Integrable f (μ + ν)) :
    f.integral (μ + ν) = f.integral μ + f.integral ν :=
  by
  simp_rw [integral_def]
  refine'
    set_to_simple_func_add_left' (weighted_smul μ) (weighted_smul ν) (weighted_smul (μ + ν))
      (fun s hs hμνs => _) hf
  rw [lt_top_iff_ne_top, measure.coe_add, Pi.add_apply, ENNReal.add_ne_top] at hμνs 
  rw [weighted_smul_add_measure _ _ hμνs.1 hμνs.2]
#align measure_theory.simple_func.integral_add_measure MeasureTheory.SimpleFunc.integral_add_measure
-/

end Integral

end SimpleFunc

namespace L1

open AeEqFun Lp.SimpleFunc Lp

variable [NormedAddCommGroup E] [NormedAddCommGroup F] {m : MeasurableSpace α} {μ : Measure α}

variable {α E μ}

namespace SimpleFunc

#print MeasureTheory.L1.SimpleFunc.norm_eq_integral /-
theorem norm_eq_integral (f : α →₁ₛ[μ] E) : ‖f‖ = ((toSimpleFunc f).map norm).integral μ :=
  by
  rw [norm_eq_sum_mul f, (to_simple_func f).map_integral norm (simple_func.integrable f) norm_zero]
  simp_rw [smul_eq_mul]
#align measure_theory.L1.simple_func.norm_eq_integral MeasureTheory.L1.SimpleFunc.norm_eq_integral
-/

section PosPart

#print MeasureTheory.L1.SimpleFunc.posPart /-
/-- Positive part of a simple function in L1 space.  -/
def posPart (f : α →₁ₛ[μ] ℝ) : α →₁ₛ[μ] ℝ :=
  ⟨Lp.posPart (f : α →₁[μ] ℝ), by
    rcases f with ⟨f, s, hsf⟩
    use s.pos_part
    simp only [Subtype.coe_mk, Lp.coe_pos_part, ← hsf, ae_eq_fun.pos_part_mk, simple_func.pos_part,
      simple_func.coe_map, mk_eq_mk]⟩
#align measure_theory.L1.simple_func.pos_part MeasureTheory.L1.SimpleFunc.posPart
-/

#print MeasureTheory.L1.SimpleFunc.negPart /-
/-- Negative part of a simple function in L1 space. -/
def negPart (f : α →₁ₛ[μ] ℝ) : α →₁ₛ[μ] ℝ :=
  posPart (-f)
#align measure_theory.L1.simple_func.neg_part MeasureTheory.L1.SimpleFunc.negPart
-/

#print MeasureTheory.L1.SimpleFunc.coe_posPart /-
@[norm_cast]
theorem coe_posPart (f : α →₁ₛ[μ] ℝ) : (posPart f : α →₁[μ] ℝ) = Lp.posPart (f : α →₁[μ] ℝ) :=
  rfl
#align measure_theory.L1.simple_func.coe_pos_part MeasureTheory.L1.SimpleFunc.coe_posPart
-/

#print MeasureTheory.L1.SimpleFunc.coe_negPart /-
@[norm_cast]
theorem coe_negPart (f : α →₁ₛ[μ] ℝ) : (negPart f : α →₁[μ] ℝ) = Lp.negPart (f : α →₁[μ] ℝ) :=
  rfl
#align measure_theory.L1.simple_func.coe_neg_part MeasureTheory.L1.SimpleFunc.coe_negPart
-/

end PosPart

section SimpleFuncIntegral

/-!
### The Bochner integral of `L1`

Define the Bochner integral on `α →₁ₛ[μ] E` by extension from the simple functions `α →₁ₛ[μ] E`,
and prove basic properties of this integral. -/


variable [NormedField 𝕜] [NormedSpace 𝕜 E] [NormedSpace ℝ E] [SMulCommClass ℝ 𝕜 E] {F' : Type _}
  [NormedAddCommGroup F'] [NormedSpace ℝ F']

attribute [local instance] simple_func.normed_space

#print MeasureTheory.L1.SimpleFunc.integral /-
/-- The Bochner integral over simple functions in L1 space. -/
def integral (f : α →₁ₛ[μ] E) : E :=
  (toSimpleFunc f).integral μ
#align measure_theory.L1.simple_func.integral MeasureTheory.L1.SimpleFunc.integral
-/

#print MeasureTheory.L1.SimpleFunc.integral_eq_integral /-
theorem integral_eq_integral (f : α →₁ₛ[μ] E) : integral f = (toSimpleFunc f).integral μ :=
  rfl
#align measure_theory.L1.simple_func.integral_eq_integral MeasureTheory.L1.SimpleFunc.integral_eq_integral
-/

#print MeasureTheory.L1.SimpleFunc.integral_eq_lintegral /-
theorem integral_eq_lintegral {f : α →₁ₛ[μ] ℝ} (h_pos : 0 ≤ᵐ[μ] toSimpleFunc f) :
    integral f = ENNReal.toReal (∫⁻ a, ENNReal.ofReal ((toSimpleFunc f) a) ∂μ) := by
  rw [integral, simple_func.integral_eq_lintegral (simple_func.integrable f) h_pos]
#align measure_theory.L1.simple_func.integral_eq_lintegral MeasureTheory.L1.SimpleFunc.integral_eq_lintegral
-/

#print MeasureTheory.L1.SimpleFunc.integral_eq_setToL1S /-
theorem integral_eq_setToL1S (f : α →₁ₛ[μ] E) : integral f = setToL1S (weightedSMul μ) f :=
  rfl
#align measure_theory.L1.simple_func.integral_eq_set_to_L1s MeasureTheory.L1.SimpleFunc.integral_eq_setToL1S
-/

#print MeasureTheory.L1.SimpleFunc.integral_congr /-
theorem integral_congr {f g : α →₁ₛ[μ] E} (h : toSimpleFunc f =ᵐ[μ] toSimpleFunc g) :
    integral f = integral g :=
  SimpleFunc.integral_congr (SimpleFunc.integrable f) h
#align measure_theory.L1.simple_func.integral_congr MeasureTheory.L1.SimpleFunc.integral_congr
-/

#print MeasureTheory.L1.SimpleFunc.integral_add /-
theorem integral_add (f g : α →₁ₛ[μ] E) : integral (f + g) = integral f + integral g :=
  setToL1S_add _ (fun _ _ => weightedSMul_null) weightedSMul_union _ _
#align measure_theory.L1.simple_func.integral_add MeasureTheory.L1.SimpleFunc.integral_add
-/

#print MeasureTheory.L1.SimpleFunc.integral_smul /-
theorem integral_smul (c : 𝕜) (f : α →₁ₛ[μ] E) : integral (c • f) = c • integral f :=
  setToL1S_smul _ (fun _ _ => weightedSMul_null) weightedSMul_union weightedSMul_smul c f
#align measure_theory.L1.simple_func.integral_smul MeasureTheory.L1.SimpleFunc.integral_smul
-/

#print MeasureTheory.L1.SimpleFunc.norm_integral_le_norm /-
theorem norm_integral_le_norm (f : α →₁ₛ[μ] E) : ‖integral f‖ ≤ ‖f‖ :=
  by
  rw [integral, norm_eq_integral]
  exact (to_simple_func f).norm_integral_le_integral_norm (simple_func.integrable f)
#align measure_theory.L1.simple_func.norm_integral_le_norm MeasureTheory.L1.SimpleFunc.norm_integral_le_norm
-/

variable {E' : Type _} [NormedAddCommGroup E'] [NormedSpace ℝ E'] [NormedSpace 𝕜 E']

variable (α E μ 𝕜)

#print MeasureTheory.L1.SimpleFunc.integralCLM' /-
/-- The Bochner integral over simple functions in L1 space as a continuous linear map. -/
def integralCLM' : (α →₁ₛ[μ] E) →L[𝕜] E :=
  LinearMap.mkContinuous ⟨integral, integral_add, integral_smul⟩ 1 fun f =>
    le_trans (norm_integral_le_norm _) <| by rw [one_mul]
#align measure_theory.L1.simple_func.integral_clm' MeasureTheory.L1.SimpleFunc.integralCLM'
-/

#print MeasureTheory.L1.SimpleFunc.integralCLM /-
/-- The Bochner integral over simple functions in L1 space as a continuous linear map over ℝ. -/
def integralCLM : (α →₁ₛ[μ] E) →L[ℝ] E :=
  integralCLM' α E ℝ μ
#align measure_theory.L1.simple_func.integral_clm MeasureTheory.L1.SimpleFunc.integralCLM
-/

variable {α E μ 𝕜}

local notation "Integral" => integralCLM α E μ

open ContinuousLinearMap

#print MeasureTheory.L1.SimpleFunc.norm_Integral_le_one /-
theorem norm_Integral_le_one : ‖Integral‖ ≤ 1 :=
  LinearMap.mkContinuous_norm_le _ zero_le_one _
#align measure_theory.L1.simple_func.norm_Integral_le_one MeasureTheory.L1.SimpleFunc.norm_Integral_le_one
-/

section PosPart

#print MeasureTheory.L1.SimpleFunc.posPart_toSimpleFunc /-
theorem posPart_toSimpleFunc (f : α →₁ₛ[μ] ℝ) :
    toSimpleFunc (posPart f) =ᵐ[μ] (toSimpleFunc f).posPart :=
  by
  have eq : ∀ a, (to_simple_func f).posPart a = max ((to_simple_func f) a) 0 := fun a => rfl
  have ae_eq : ∀ᵐ a ∂μ, to_simple_func (pos_part f) a = max ((to_simple_func f) a) 0 :=
    by
    filter_upwards [to_simple_func_eq_to_fun (pos_part f), Lp.coe_fn_pos_part (f : α →₁[μ] ℝ),
      to_simple_func_eq_to_fun f] with _ _ h₂ _
    convert h₂
  refine' ae_eq.mono fun a h => _
  rw [h, Eq]
#align measure_theory.L1.simple_func.pos_part_to_simple_func MeasureTheory.L1.SimpleFunc.posPart_toSimpleFunc
-/

#print MeasureTheory.L1.SimpleFunc.negPart_toSimpleFunc /-
theorem negPart_toSimpleFunc (f : α →₁ₛ[μ] ℝ) :
    toSimpleFunc (negPart f) =ᵐ[μ] (toSimpleFunc f).neg_part :=
  by
  rw [simple_func.neg_part, MeasureTheory.SimpleFunc.negPart]
  filter_upwards [pos_part_to_simple_func (-f), neg_to_simple_func f]
  intro a h₁ h₂
  rw [h₁]
  show max _ _ = max _ _
  rw [h₂]
  rfl
#align measure_theory.L1.simple_func.neg_part_to_simple_func MeasureTheory.L1.SimpleFunc.negPart_toSimpleFunc
-/

#print MeasureTheory.L1.SimpleFunc.integral_eq_norm_posPart_sub /-
theorem integral_eq_norm_posPart_sub (f : α →₁ₛ[μ] ℝ) : integral f = ‖posPart f‖ - ‖negPart f‖ :=
  by
  -- Convert things in `L¹` to their `simple_func` counterpart
  have ae_eq₁ : (to_simple_func f).posPart =ᵐ[μ] (to_simple_func (pos_part f)).map norm :=
    by
    filter_upwards [pos_part_to_simple_func f] with _ h
    rw [simple_func.map_apply, h]
    conv_lhs => rw [← simple_func.pos_part_map_norm, simple_func.map_apply]
  -- Convert things in `L¹` to their `simple_func` counterpart
  have ae_eq₂ : (to_simple_func f).neg_part =ᵐ[μ] (to_simple_func (neg_part f)).map norm :=
    by
    filter_upwards [neg_part_to_simple_func f] with _ h
    rw [simple_func.map_apply, h]
    conv_lhs => rw [← simple_func.neg_part_map_norm, simple_func.map_apply]
  -- Convert things in `L¹` to their `simple_func` counterpart
  have ae_eq :
    ∀ᵐ a ∂μ,
      (to_simple_func f).posPart a - (to_simple_func f).neg_part a =
        (to_simple_func (pos_part f)).map norm a - (to_simple_func (neg_part f)).map norm a :=
    by
    filter_upwards [ae_eq₁, ae_eq₂] with _ h₁ h₂
    rw [h₁, h₂]
  rw [integral, norm_eq_integral, norm_eq_integral, ← simple_func.integral_sub]
  · show
      (to_simple_func f).integral μ =
        ((to_simple_func (pos_part f)).map norm - (to_simple_func (neg_part f)).map norm).integral μ
    apply MeasureTheory.SimpleFunc.integral_congr (simple_func.integrable f)
    filter_upwards [ae_eq₁, ae_eq₂] with _ h₁ h₂
    show _ = _ - _
    rw [← h₁, ← h₂]
    have := (to_simple_func f).posPart_sub_negPart
    conv_lhs => rw [← this]
    rfl
  · exact (simple_func.integrable f).posPart.congr ae_eq₁
  · exact (simple_func.integrable f).neg_part.congr ae_eq₂
#align measure_theory.L1.simple_func.integral_eq_norm_pos_part_sub MeasureTheory.L1.SimpleFunc.integral_eq_norm_posPart_sub
-/

end PosPart

end SimpleFuncIntegral

end SimpleFunc

open SimpleFunc

local notation "Integral" => @integralCLM α E _ _ _ _ _ μ _

variable [NormedSpace ℝ E] [NontriviallyNormedField 𝕜] [NormedSpace 𝕜 E] [SMulCommClass ℝ 𝕜 E]
  [NormedSpace ℝ F] [CompleteSpace E]

section IntegrationInL1

attribute [local instance] simple_func.normed_space

open ContinuousLinearMap

variable (𝕜)

#print MeasureTheory.L1.integralCLM' /-
/-- The Bochner integral in L1 space as a continuous linear map. -/
def integralCLM' : (α →₁[μ] E) →L[𝕜] E :=
  (integralCLM' α E 𝕜 μ).extend (coeToLp α E 𝕜) (simpleFunc.denseRange one_ne_top)
    simpleFunc.uniformInducing
#align measure_theory.L1.integral_clm' MeasureTheory.L1.integralCLM'
-/

variable {𝕜}

#print MeasureTheory.L1.integralCLM /-
/-- The Bochner integral in L1 space as a continuous linear map over ℝ. -/
def integralCLM : (α →₁[μ] E) →L[ℝ] E :=
  integralCLM' ℝ
#align measure_theory.L1.integral_clm MeasureTheory.L1.integralCLM
-/

#print MeasureTheory.L1.integral /-
/-- The Bochner integral in L1 space -/
irreducible_def integral (f : α →₁[μ] E) : E :=
  integralCLM f
#align measure_theory.L1.integral MeasureTheory.L1.integral
-/

#print MeasureTheory.L1.integral_eq /-
theorem integral_eq (f : α →₁[μ] E) : integral f = integralCLM f := by simp only [integral]
#align measure_theory.L1.integral_eq MeasureTheory.L1.integral_eq
-/

#print MeasureTheory.L1.integral_eq_setToL1 /-
theorem integral_eq_setToL1 (f : α →₁[μ] E) :
    integral f = setToL1 (dominatedFinMeasAdditive_weightedSMul μ) f := by simp only [integral]; rfl
#align measure_theory.L1.integral_eq_set_to_L1 MeasureTheory.L1.integral_eq_setToL1
-/

#print MeasureTheory.L1.SimpleFunc.integral_L1_eq_integral /-
@[norm_cast]
theorem SimpleFunc.integral_L1_eq_integral (f : α →₁ₛ[μ] E) :
    integral (f : α →₁[μ] E) = SimpleFunc.integral f :=
  by
  simp only [integral]
  exact set_to_L1_eq_set_to_L1s_clm (dominated_fin_meas_additive_weighted_smul μ) f
#align measure_theory.L1.simple_func.integral_L1_eq_integral MeasureTheory.L1.SimpleFunc.integral_L1_eq_integral
-/

variable (α E)

#print MeasureTheory.L1.integral_zero /-
@[simp]
theorem integral_zero : integral (0 : α →₁[μ] E) = 0 :=
  by
  simp only [integral]
  exact map_zero integral_clm
#align measure_theory.L1.integral_zero MeasureTheory.L1.integral_zero
-/

variable {α E}

#print MeasureTheory.L1.integral_add /-
theorem integral_add (f g : α →₁[μ] E) : integral (f + g) = integral f + integral g :=
  by
  simp only [integral]
  exact map_add integral_clm f g
#align measure_theory.L1.integral_add MeasureTheory.L1.integral_add
-/

#print MeasureTheory.L1.integral_neg /-
theorem integral_neg (f : α →₁[μ] E) : integral (-f) = -integral f :=
  by
  simp only [integral]
  exact map_neg integral_clm f
#align measure_theory.L1.integral_neg MeasureTheory.L1.integral_neg
-/

#print MeasureTheory.L1.integral_sub /-
theorem integral_sub (f g : α →₁[μ] E) : integral (f - g) = integral f - integral g :=
  by
  simp only [integral]
  exact map_sub integral_clm f g
#align measure_theory.L1.integral_sub MeasureTheory.L1.integral_sub
-/

#print MeasureTheory.L1.integral_smul /-
theorem integral_smul (c : 𝕜) (f : α →₁[μ] E) : integral (c • f) = c • integral f :=
  by
  simp only [integral]
  show (integral_clm' 𝕜) (c • f) = c • (integral_clm' 𝕜) f; exact map_smul (integral_clm' 𝕜) c f
#align measure_theory.L1.integral_smul MeasureTheory.L1.integral_smul
-/

local notation "Integral" => @integralCLM α E _ _ μ _ _

local notation "sIntegral" => @SimpleFunc.integralCLM α E _ _ μ _

#print MeasureTheory.L1.norm_Integral_le_one /-
theorem norm_Integral_le_one : ‖Integral‖ ≤ 1 :=
  norm_setToL1_le (dominatedFinMeasAdditive_weightedSMul μ) zero_le_one
#align measure_theory.L1.norm_Integral_le_one MeasureTheory.L1.norm_Integral_le_one
-/

#print MeasureTheory.L1.norm_integral_le /-
theorem norm_integral_le (f : α →₁[μ] E) : ‖integral f‖ ≤ ‖f‖ :=
  calc
    ‖integral f‖ = ‖Integral f‖ := by simp only [integral]
    _ ≤ ‖Integral‖ * ‖f‖ := (le_op_norm _ _)
    _ ≤ 1 * ‖f‖ := (mul_le_mul_of_nonneg_right norm_Integral_le_one <| norm_nonneg _)
    _ = ‖f‖ := one_mul _
#align measure_theory.L1.norm_integral_le MeasureTheory.L1.norm_integral_le
-/

#print MeasureTheory.L1.continuous_integral /-
@[continuity]
theorem continuous_integral : Continuous fun f : α →₁[μ] E => integral f :=
  by
  simp only [integral]
  exact L1.integral_clm.continuous
#align measure_theory.L1.continuous_integral MeasureTheory.L1.continuous_integral
-/

section PosPart

#print MeasureTheory.L1.integral_eq_norm_posPart_sub /-
theorem integral_eq_norm_posPart_sub (f : α →₁[μ] ℝ) :
    integral f = ‖Lp.posPart f‖ - ‖Lp.negPart f‖ :=
  by
  -- Use `is_closed_property` and `is_closed_eq`
  refine'
    @isClosed_property _ _ _ (coe : (α →₁ₛ[μ] ℝ) → α →₁[μ] ℝ)
      (fun f : α →₁[μ] ℝ => integral f = ‖Lp.pos_part f‖ - ‖Lp.neg_part f‖)
      (simple_func.dense_range one_ne_top) (isClosed_eq _ _) _ f
  · simp only [integral]
    exact Cont _
  ·
    refine'
      Continuous.sub (continuous_norm.comp Lp.continuous_pos_part)
        (continuous_norm.comp Lp.continuous_neg_part)
  -- Show that the property holds for all simple functions in the `L¹` space.
  · intro s
    norm_cast
    exact simple_func.integral_eq_norm_pos_part_sub _
#align measure_theory.L1.integral_eq_norm_pos_part_sub MeasureTheory.L1.integral_eq_norm_posPart_sub
-/

end PosPart

end IntegrationInL1

end L1

/-!
## The Bochner integral on functions

Define the Bochner integral on functions generally to be the `L1` Bochner integral, for integrable
functions, and 0 otherwise; prove its basic properties.

-/


variable [NormedAddCommGroup E] [NormedSpace ℝ E] [CompleteSpace E] [NontriviallyNormedField 𝕜]
  [NormedSpace 𝕜 E] [SMulCommClass ℝ 𝕜 E] [NormedAddCommGroup F] [NormedSpace ℝ F] [CompleteSpace F]

section

open scoped Classical

#print MeasureTheory.integral /-
/-- The Bochner integral -/
irreducible_def integral {m : MeasurableSpace α} (μ : Measure α) (f : α → E) : E :=
  if hf : Integrable f μ then L1.integral (hf.toL1 f) else 0
#align measure_theory.integral MeasureTheory.integral
-/

end

/-! In the notation for integrals, an expression like `∫ x, g ‖x‖ ∂μ` will not be parsed correctly,
  and needs parentheses. We do not set the binding power of `r` to `0`, because then
  `∫ x, f x = 0` will be parsed incorrectly. -/


notation3"∫ "(...)", "r:60:(scoped f => f)" ∂"μ:70 => integral μ r

notation3"∫ "(...)", "r:60:(scoped f => integral volume f) => r

notation3"∫ "(...)" in "s", "r:60:(scoped f => f)" ∂"μ:70 => integral (Measure.restrict μ s) r

notation3"∫ "(...)" in "s", "r:60:(scoped f => integral Measure.restrict volume s f) => r

section Properties

open ContinuousLinearMap MeasureTheory.SimpleFunc

variable {f g : α → E} {m : MeasurableSpace α} {μ : Measure α}

#print MeasureTheory.integral_eq /-
theorem integral_eq (f : α → E) (hf : Integrable f μ) : ∫ a, f a ∂μ = L1.integral (hf.toL1 f) := by
  rw [integral]; exact @dif_pos _ (id _) hf _ _ _
#align measure_theory.integral_eq MeasureTheory.integral_eq
-/

#print MeasureTheory.integral_eq_setToFun /-
theorem integral_eq_setToFun (f : α → E) :
    ∫ a, f a ∂μ = setToFun μ (weightedSMul μ) (dominatedFinMeasAdditive_weightedSMul μ) f := by
  simp only [integral, L1.integral]; rfl
#align measure_theory.integral_eq_set_to_fun MeasureTheory.integral_eq_setToFun
-/

#print MeasureTheory.L1.integral_eq_integral /-
theorem L1.integral_eq_integral (f : α →₁[μ] E) : L1.integral f = ∫ a, f a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact (L1.set_to_fun_eq_set_to_L1 (dominated_fin_meas_additive_weighted_smul μ) f).symm
#align measure_theory.L1.integral_eq_integral MeasureTheory.L1.integral_eq_integral
-/

#print MeasureTheory.integral_undef /-
theorem integral_undef (h : ¬Integrable f μ) : ∫ a, f a ∂μ = 0 := by rw [integral];
  exact @dif_neg _ (id _) h _ _ _
#align measure_theory.integral_undef MeasureTheory.integral_undef
-/

#print MeasureTheory.integral_non_aestronglyMeasurable /-
theorem integral_non_aestronglyMeasurable (h : ¬AEStronglyMeasurable f μ) : ∫ a, f a ∂μ = 0 :=
  integral_undef <| not_and_of_not_left _ h
#align measure_theory.integral_non_ae_strongly_measurable MeasureTheory.integral_non_aestronglyMeasurable
-/

variable (α E)

#print MeasureTheory.integral_zero /-
theorem integral_zero : ∫ a : α, (0 : E) ∂μ = 0 :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_zero (dominated_fin_meas_additive_weighted_smul μ)
#align measure_theory.integral_zero MeasureTheory.integral_zero
-/

#print MeasureTheory.integral_zero' /-
@[simp]
theorem integral_zero' : integral μ (0 : α → E) = 0 :=
  integral_zero α E
#align measure_theory.integral_zero' MeasureTheory.integral_zero'
-/

variable {α E}

#print MeasureTheory.integrable_of_integral_eq_one /-
theorem integrable_of_integral_eq_one {f : α → ℝ} (h : ∫ x, f x ∂μ = 1) : Integrable f μ := by
  contrapose h; rw [integral_undef h]; exact zero_ne_one
#align measure_theory.integrable_of_integral_eq_one MeasureTheory.integrable_of_integral_eq_one
-/

#print MeasureTheory.integral_add /-
theorem integral_add (hf : Integrable f μ) (hg : Integrable g μ) :
    ∫ a, f a + g a ∂μ = ∫ a, f a ∂μ + ∫ a, g a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_add (dominated_fin_meas_additive_weighted_smul μ) hf hg
#align measure_theory.integral_add MeasureTheory.integral_add
-/

#print MeasureTheory.integral_add' /-
theorem integral_add' (hf : Integrable f μ) (hg : Integrable g μ) :
    ∫ a, (f + g) a ∂μ = ∫ a, f a ∂μ + ∫ a, g a ∂μ :=
  integral_add hf hg
#align measure_theory.integral_add' MeasureTheory.integral_add'
-/

#print MeasureTheory.integral_finset_sum /-
theorem integral_finset_sum {ι} (s : Finset ι) {f : ι → α → E} (hf : ∀ i ∈ s, Integrable (f i) μ) :
    ∫ a, ∑ i in s, f i a ∂μ = ∑ i in s, ∫ a, f i a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_finset_sum (dominated_fin_meas_additive_weighted_smul _) s hf
#align measure_theory.integral_finset_sum MeasureTheory.integral_finset_sum
-/

#print MeasureTheory.integral_neg /-
theorem integral_neg (f : α → E) : ∫ a, -f a ∂μ = -∫ a, f a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_neg (dominated_fin_meas_additive_weighted_smul μ) f
#align measure_theory.integral_neg MeasureTheory.integral_neg
-/

#print MeasureTheory.integral_neg' /-
theorem integral_neg' (f : α → E) : ∫ a, (-f) a ∂μ = -∫ a, f a ∂μ :=
  integral_neg f
#align measure_theory.integral_neg' MeasureTheory.integral_neg'
-/

#print MeasureTheory.integral_sub /-
theorem integral_sub (hf : Integrable f μ) (hg : Integrable g μ) :
    ∫ a, f a - g a ∂μ = ∫ a, f a ∂μ - ∫ a, g a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_sub (dominated_fin_meas_additive_weighted_smul μ) hf hg
#align measure_theory.integral_sub MeasureTheory.integral_sub
-/

#print MeasureTheory.integral_sub' /-
theorem integral_sub' (hf : Integrable f μ) (hg : Integrable g μ) :
    ∫ a, (f - g) a ∂μ = ∫ a, f a ∂μ - ∫ a, g a ∂μ :=
  integral_sub hf hg
#align measure_theory.integral_sub' MeasureTheory.integral_sub'
-/

#print MeasureTheory.integral_smul /-
theorem integral_smul (c : 𝕜) (f : α → E) : ∫ a, c • f a ∂μ = c • ∫ a, f a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_smul (dominated_fin_meas_additive_weighted_smul μ) weighted_smul_smul c f
#align measure_theory.integral_smul MeasureTheory.integral_smul
-/

#print MeasureTheory.integral_mul_left /-
theorem integral_mul_left {L : Type _} [IsROrC L] (r : L) (f : α → L) :
    ∫ a, r * f a ∂μ = r * ∫ a, f a ∂μ :=
  integral_smul r f
#align measure_theory.integral_mul_left MeasureTheory.integral_mul_left
-/

#print MeasureTheory.integral_mul_right /-
theorem integral_mul_right {L : Type _} [IsROrC L] (r : L) (f : α → L) :
    ∫ a, f a * r ∂μ = (∫ a, f a ∂μ) * r := by simp only [mul_comm]; exact integral_mul_left r f
#align measure_theory.integral_mul_right MeasureTheory.integral_mul_right
-/

#print MeasureTheory.integral_div /-
theorem integral_div {L : Type _} [IsROrC L] (r : L) (f : α → L) :
    ∫ a, f a / r ∂μ = (∫ a, f a ∂μ) / r := by
  simpa only [← div_eq_mul_inv] using integral_mul_right r⁻¹ f
#align measure_theory.integral_div MeasureTheory.integral_div
-/

#print MeasureTheory.integral_congr_ae /-
theorem integral_congr_ae (h : f =ᵐ[μ] g) : ∫ a, f a ∂μ = ∫ a, g a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_congr_ae (dominated_fin_meas_additive_weighted_smul μ) h
#align measure_theory.integral_congr_ae MeasureTheory.integral_congr_ae
-/

#print MeasureTheory.L1.integral_of_fun_eq_integral /-
@[simp]
theorem L1.integral_of_fun_eq_integral {f : α → E} (hf : Integrable f μ) :
    ∫ a, (hf.toL1 f) a ∂μ = ∫ a, f a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_to_L1 (dominated_fin_meas_additive_weighted_smul μ) hf
#align measure_theory.L1.integral_of_fun_eq_integral MeasureTheory.L1.integral_of_fun_eq_integral
-/

#print MeasureTheory.continuous_integral /-
@[continuity]
theorem continuous_integral : Continuous fun f : α →₁[μ] E => ∫ a, f a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact continuous_set_to_fun (dominated_fin_meas_additive_weighted_smul μ)
#align measure_theory.continuous_integral MeasureTheory.continuous_integral
-/

#print MeasureTheory.norm_integral_le_lintegral_norm /-
theorem norm_integral_le_lintegral_norm (f : α → E) :
    ‖∫ a, f a ∂μ‖ ≤ ENNReal.toReal (∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ) :=
  by
  by_cases hf : integrable f μ
  · rw [integral_eq f hf, ← integrable.norm_to_L1_eq_lintegral_norm f hf]
    exact L1.norm_integral_le _
  · rw [integral_undef hf, norm_zero]; exact to_real_nonneg
#align measure_theory.norm_integral_le_lintegral_norm MeasureTheory.norm_integral_le_lintegral_norm
-/

#print MeasureTheory.ennnorm_integral_le_lintegral_ennnorm /-
theorem ennnorm_integral_le_lintegral_ennnorm (f : α → E) :
    (‖∫ a, f a ∂μ‖₊ : ℝ≥0∞) ≤ ∫⁻ a, ‖f a‖₊ ∂μ :=
  by
  simp_rw [← ofReal_norm_eq_coe_nnnorm]; apply ENNReal.ofReal_le_of_le_toReal
  exact norm_integral_le_lintegral_norm f
#align measure_theory.ennnorm_integral_le_lintegral_ennnorm MeasureTheory.ennnorm_integral_le_lintegral_ennnorm
-/

#print MeasureTheory.integral_eq_zero_of_ae /-
theorem integral_eq_zero_of_ae {f : α → E} (hf : f =ᵐ[μ] 0) : ∫ a, f a ∂μ = 0 := by
  simp [integral_congr_ae hf, integral_zero]
#align measure_theory.integral_eq_zero_of_ae MeasureTheory.integral_eq_zero_of_ae
-/

#print MeasureTheory.HasFiniteIntegral.tendsto_set_integral_nhds_zero /-
/-- If `f` has finite integral, then `∫ x in s, f x ∂μ` is absolutely continuous in `s`: it tends
to zero as `μ s` tends to zero. -/
theorem HasFiniteIntegral.tendsto_set_integral_nhds_zero {ι} {f : α → E}
    (hf : HasFiniteIntegral f μ) {l : Filter ι} {s : ι → Set α} (hs : Tendsto (μ ∘ s) l (𝓝 0)) :
    Tendsto (fun i => ∫ x in s i, f x ∂μ) l (𝓝 0) :=
  by
  rw [tendsto_zero_iff_norm_tendsto_zero]
  simp_rw [← coe_nnnorm, ← NNReal.coe_zero, NNReal.tendsto_coe, ← ENNReal.tendsto_coe,
    ENNReal.coe_zero]
  exact
    tendsto_of_tendsto_of_tendsto_of_le_of_le tendsto_const_nhds
      (tendsto_set_lintegral_zero (ne_of_lt hf) hs) (fun i => zero_le _) fun i =>
      ennnorm_integral_le_lintegral_ennnorm _
#align measure_theory.has_finite_integral.tendsto_set_integral_nhds_zero MeasureTheory.HasFiniteIntegral.tendsto_set_integral_nhds_zero
-/

#print MeasureTheory.Integrable.tendsto_set_integral_nhds_zero /-
/-- If `f` is integrable, then `∫ x in s, f x ∂μ` is absolutely continuous in `s`: it tends
to zero as `μ s` tends to zero. -/
theorem Integrable.tendsto_set_integral_nhds_zero {ι} {f : α → E} (hf : Integrable f μ)
    {l : Filter ι} {s : ι → Set α} (hs : Tendsto (μ ∘ s) l (𝓝 0)) :
    Tendsto (fun i => ∫ x in s i, f x ∂μ) l (𝓝 0) :=
  hf.2.tendsto_set_integral_nhds_zero hs
#align measure_theory.integrable.tendsto_set_integral_nhds_zero MeasureTheory.Integrable.tendsto_set_integral_nhds_zero
-/

#print MeasureTheory.tendsto_integral_of_L1 /-
/-- If `F i → f` in `L1`, then `∫ x, F i x ∂μ → ∫ x, f x ∂μ`. -/
theorem tendsto_integral_of_L1 {ι} (f : α → E) (hfi : Integrable f μ) {F : ι → α → E} {l : Filter ι}
    (hFi : ∀ᶠ i in l, Integrable (F i) μ)
    (hF : Tendsto (fun i => ∫⁻ x, ‖F i x - f x‖₊ ∂μ) l (𝓝 0)) :
    Tendsto (fun i => ∫ x, F i x ∂μ) l (𝓝 <| ∫ x, f x ∂μ) :=
  by
  simp only [integral, L1.integral]
  exact tendsto_set_to_fun_of_L1 (dominated_fin_meas_additive_weighted_smul μ) f hfi hFi hF
#align measure_theory.tendsto_integral_of_L1 MeasureTheory.tendsto_integral_of_L1
-/

#print MeasureTheory.tendsto_integral_of_dominated_convergence /-
/-- Lebesgue dominated convergence theorem provides sufficient conditions under which almost
  everywhere convergence of a sequence of functions implies the convergence of their integrals.
  We could weaken the condition `bound_integrable` to require `has_finite_integral bound μ` instead
  (i.e. not requiring that `bound` is measurable), but in all applications proving integrability
  is easier. -/
theorem tendsto_integral_of_dominated_convergence {F : ℕ → α → E} {f : α → E} (bound : α → ℝ)
    (F_measurable : ∀ n, AEStronglyMeasurable (F n) μ) (bound_integrable : Integrable bound μ)
    (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) atTop (𝓝 (f a))) :
    Tendsto (fun n => ∫ a, F n a ∂μ) atTop (𝓝 <| ∫ a, f a ∂μ) :=
  by
  simp only [integral, L1.integral]
  exact
    tendsto_set_to_fun_of_dominated_convergence (dominated_fin_meas_additive_weighted_smul μ) bound
      F_measurable bound_integrable h_bound h_lim
#align measure_theory.tendsto_integral_of_dominated_convergence MeasureTheory.tendsto_integral_of_dominated_convergence
-/

#print MeasureTheory.tendsto_integral_filter_of_dominated_convergence /-
/-- Lebesgue dominated convergence theorem for filters with a countable basis -/
theorem tendsto_integral_filter_of_dominated_convergence {ι} {l : Filter ι} [l.IsCountablyGenerated]
    {F : ι → α → E} {f : α → E} (bound : α → ℝ) (hF_meas : ∀ᶠ n in l, AEStronglyMeasurable (F n) μ)
    (h_bound : ∀ᶠ n in l, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound a) (bound_integrable : Integrable bound μ)
    (h_lim : ∀ᵐ a ∂μ, Tendsto (fun n => F n a) l (𝓝 (f a))) :
    Tendsto (fun n => ∫ a, F n a ∂μ) l (𝓝 <| ∫ a, f a ∂μ) :=
  by
  simp only [integral, L1.integral]
  exact
    tendsto_set_to_fun_filter_of_dominated_convergence (dominated_fin_meas_additive_weighted_smul μ)
      bound hF_meas h_bound bound_integrable h_lim
#align measure_theory.tendsto_integral_filter_of_dominated_convergence MeasureTheory.tendsto_integral_filter_of_dominated_convergence
-/

#print MeasureTheory.hasSum_integral_of_dominated_convergence /-
/-- Lebesgue dominated convergence theorem for series. -/
theorem hasSum_integral_of_dominated_convergence {ι} [Countable ι] {F : ι → α → E} {f : α → E}
    (bound : ι → α → ℝ) (hF_meas : ∀ n, AEStronglyMeasurable (F n) μ)
    (h_bound : ∀ n, ∀ᵐ a ∂μ, ‖F n a‖ ≤ bound n a)
    (bound_summable : ∀ᵐ a ∂μ, Summable fun n => bound n a)
    (bound_integrable : Integrable (fun a => ∑' n, bound n a) μ)
    (h_lim : ∀ᵐ a ∂μ, HasSum (fun n => F n a) (f a)) :
    HasSum (fun n => ∫ a, F n a ∂μ) (∫ a, f a ∂μ) :=
  by
  have hb_nonneg : ∀ᵐ a ∂μ, ∀ n, 0 ≤ bound n a :=
    eventually_countable_forall.2 fun n => (h_bound n).mono fun a => (norm_nonneg _).trans
  have hb_le_tsum : ∀ n, bound n ≤ᵐ[μ] fun a => ∑' n, bound n a :=
    by
    intro n
    filter_upwards [hb_nonneg, bound_summable] with _ ha0 ha_sum using
      le_tsum ha_sum _ fun i _ => ha0 i
  have hF_integrable : ∀ n, integrable (F n) μ :=
    by
    refine' fun n => bound_integrable.mono' (hF_meas n) _
    exact eventually_le.trans (h_bound n) (hb_le_tsum n)
  simp only [HasSum, ← integral_finset_sum _ fun n _ => hF_integrable n]
  refine'
    tendsto_integral_filter_of_dominated_convergence (fun a => ∑' n, bound n a) _ _ bound_integrable
      h_lim
  · exact eventually_of_forall fun s => s.aestronglyMeasurable_sum fun n hn => hF_meas n
  · refine' eventually_of_forall fun s => _
    filter_upwards [eventually_countable_forall.2 h_bound, hb_nonneg, bound_summable] with a hFa ha0
      has
    calc
      ‖∑ n in s, F n a‖ ≤ ∑ n in s, bound n a := norm_sum_le_of_le _ fun n hn => hFa n
      _ ≤ ∑' n, bound n a := sum_le_tsum _ (fun n hn => ha0 n) has
#align measure_theory.has_sum_integral_of_dominated_convergence MeasureTheory.hasSum_integral_of_dominated_convergence
-/

variable {X : Type _} [TopologicalSpace X] [FirstCountableTopology X]

#print MeasureTheory.continuousWithinAt_of_dominated /-
theorem continuousWithinAt_of_dominated {F : X → α → E} {x₀ : X} {bound : α → ℝ} {s : Set X}
    (hF_meas : ∀ᶠ x in 𝓝[s] x₀, AEStronglyMeasurable (F x) μ)
    (h_bound : ∀ᶠ x in 𝓝[s] x₀, ∀ᵐ a ∂μ, ‖F x a‖ ≤ bound a) (bound_integrable : Integrable bound μ)
    (h_cont : ∀ᵐ a ∂μ, ContinuousWithinAt (fun x => F x a) s x₀) :
    ContinuousWithinAt (fun x => ∫ a, F x a ∂μ) s x₀ :=
  by
  simp only [integral, L1.integral]
  exact
    continuous_within_at_set_to_fun_of_dominated (dominated_fin_meas_additive_weighted_smul μ)
      hF_meas h_bound bound_integrable h_cont
#align measure_theory.continuous_within_at_of_dominated MeasureTheory.continuousWithinAt_of_dominated
-/

#print MeasureTheory.continuousAt_of_dominated /-
theorem continuousAt_of_dominated {F : X → α → E} {x₀ : X} {bound : α → ℝ}
    (hF_meas : ∀ᶠ x in 𝓝 x₀, AEStronglyMeasurable (F x) μ)
    (h_bound : ∀ᶠ x in 𝓝 x₀, ∀ᵐ a ∂μ, ‖F x a‖ ≤ bound a) (bound_integrable : Integrable bound μ)
    (h_cont : ∀ᵐ a ∂μ, ContinuousAt (fun x => F x a) x₀) :
    ContinuousAt (fun x => ∫ a, F x a ∂μ) x₀ :=
  by
  simp only [integral, L1.integral]
  exact
    continuous_at_set_to_fun_of_dominated (dominated_fin_meas_additive_weighted_smul μ) hF_meas
      h_bound bound_integrable h_cont
#align measure_theory.continuous_at_of_dominated MeasureTheory.continuousAt_of_dominated
-/

#print MeasureTheory.continuousOn_of_dominated /-
theorem continuousOn_of_dominated {F : X → α → E} {bound : α → ℝ} {s : Set X}
    (hF_meas : ∀ x ∈ s, AEStronglyMeasurable (F x) μ)
    (h_bound : ∀ x ∈ s, ∀ᵐ a ∂μ, ‖F x a‖ ≤ bound a) (bound_integrable : Integrable bound μ)
    (h_cont : ∀ᵐ a ∂μ, ContinuousOn (fun x => F x a) s) : ContinuousOn (fun x => ∫ a, F x a ∂μ) s :=
  by
  simp only [integral, L1.integral]
  exact
    continuous_on_set_to_fun_of_dominated (dominated_fin_meas_additive_weighted_smul μ) hF_meas
      h_bound bound_integrable h_cont
#align measure_theory.continuous_on_of_dominated MeasureTheory.continuousOn_of_dominated
-/

#print MeasureTheory.continuous_of_dominated /-
theorem continuous_of_dominated {F : X → α → E} {bound : α → ℝ}
    (hF_meas : ∀ x, AEStronglyMeasurable (F x) μ) (h_bound : ∀ x, ∀ᵐ a ∂μ, ‖F x a‖ ≤ bound a)
    (bound_integrable : Integrable bound μ) (h_cont : ∀ᵐ a ∂μ, Continuous fun x => F x a) :
    Continuous fun x => ∫ a, F x a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact
    continuous_set_to_fun_of_dominated (dominated_fin_meas_additive_weighted_smul μ) hF_meas h_bound
      bound_integrable h_cont
#align measure_theory.continuous_of_dominated MeasureTheory.continuous_of_dominated
-/

#print MeasureTheory.integral_eq_lintegral_pos_part_sub_lintegral_neg_part /-
/-- The Bochner integral of a real-valued function `f : α → ℝ` is the difference between the
  integral of the positive part of `f` and the integral of the negative part of `f`.  -/
theorem integral_eq_lintegral_pos_part_sub_lintegral_neg_part {f : α → ℝ} (hf : Integrable f μ) :
    ∫ a, f a ∂μ =
      ENNReal.toReal (∫⁻ a, (ENNReal.ofReal <| f a) ∂μ) -
        ENNReal.toReal (∫⁻ a, (ENNReal.ofReal <| -f a) ∂μ) :=
  by
  let f₁ := hf.toL1 f
  -- Go to the `L¹` space
  have eq₁ : ENNReal.toReal (∫⁻ a, (ENNReal.ofReal <| f a) ∂μ) = ‖Lp.posPart f₁‖ :=
    by
    rw [L1.norm_def]
    congr 1
    apply lintegral_congr_ae
    filter_upwards [Lp.coe_fn_pos_part f₁, hf.coe_fn_to_L1] with _ h₁ h₂
    rw [h₁, h₂, ENNReal.ofReal]
    congr 1
    apply NNReal.eq
    rw [Real.nnnorm_of_nonneg (le_max_right _ _)]
    simp only [Real.coe_toNNReal', Subtype.coe_mk]
  -- Go to the `L¹` space
  have eq₂ : ENNReal.toReal (∫⁻ a, (ENNReal.ofReal <| -f a) ∂μ) = ‖Lp.negPart f₁‖ :=
    by
    rw [L1.norm_def]
    congr 1
    apply lintegral_congr_ae
    filter_upwards [Lp.coe_fn_neg_part f₁, hf.coe_fn_to_L1] with _ h₁ h₂
    rw [h₁, h₂, ENNReal.ofReal]
    congr 1
    apply NNReal.eq
    simp only [Real.coe_toNNReal', coe_nnnorm, nnnorm_neg]
    rw [Real.norm_of_nonpos (min_le_right _ _), ← max_neg_neg, neg_zero]
  rw [eq₁, eq₂, integral, dif_pos]
  exact L1.integral_eq_norm_pos_part_sub _
#align measure_theory.integral_eq_lintegral_pos_part_sub_lintegral_neg_part MeasureTheory.integral_eq_lintegral_pos_part_sub_lintegral_neg_part
-/

#print MeasureTheory.integral_eq_lintegral_of_nonneg_ae /-
theorem integral_eq_lintegral_of_nonneg_ae {f : α → ℝ} (hf : 0 ≤ᵐ[μ] f)
    (hfm : AEStronglyMeasurable f μ) :
    ∫ a, f a ∂μ = ENNReal.toReal (∫⁻ a, (ENNReal.ofReal <| f a) ∂μ) :=
  by
  by_cases hfi : integrable f μ
  · rw [integral_eq_lintegral_pos_part_sub_lintegral_neg_part hfi]
    have h_min : ∫⁻ a, ENNReal.ofReal (-f a) ∂μ = 0 :=
      by
      rw [lintegral_eq_zero_iff']
      · refine' hf.mono _
        simp only [Pi.zero_apply]
        intro a h
        simp only [h, neg_nonpos, of_real_eq_zero]
      · exact measurable_of_real.comp_ae_measurable hfm.ae_measurable.neg
    rw [h_min, zero_to_real, _root_.sub_zero]
  · rw [integral_undef hfi]
    simp_rw [integrable, hfm, has_finite_integral_iff_norm, lt_top_iff_ne_top, Ne.def, true_and_iff,
      Classical.not_not] at hfi 
    have : ∫⁻ a : α, ENNReal.ofReal (f a) ∂μ = ∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ :=
      by
      refine' lintegral_congr_ae (hf.mono fun a h => _)
      rw [Real.norm_eq_abs, abs_of_nonneg h]
    rw [this, hfi]; rfl
#align measure_theory.integral_eq_lintegral_of_nonneg_ae MeasureTheory.integral_eq_lintegral_of_nonneg_ae
-/

#print MeasureTheory.integral_norm_eq_lintegral_nnnorm /-
theorem integral_norm_eq_lintegral_nnnorm {G} [NormedAddCommGroup G] {f : α → G}
    (hf : AEStronglyMeasurable f μ) : ∫ x, ‖f x‖ ∂μ = ENNReal.toReal (∫⁻ x, ‖f x‖₊ ∂μ) :=
  by
  rw [integral_eq_lintegral_of_nonneg_ae _ hf.norm]
  · simp_rw [ofReal_norm_eq_coe_nnnorm]
  · refine' ae_of_all _ _; simp_rw [Pi.zero_apply, norm_nonneg, imp_true_iff]
#align measure_theory.integral_norm_eq_lintegral_nnnorm MeasureTheory.integral_norm_eq_lintegral_nnnorm
-/

#print MeasureTheory.ofReal_integral_norm_eq_lintegral_nnnorm /-
theorem ofReal_integral_norm_eq_lintegral_nnnorm {G} [NormedAddCommGroup G] {f : α → G}
    (hf : Integrable f μ) : ENNReal.ofReal (∫ x, ‖f x‖ ∂μ) = ∫⁻ x, ‖f x‖₊ ∂μ := by
  rw [integral_norm_eq_lintegral_nnnorm hf.ae_strongly_measurable,
    ENNReal.ofReal_toReal (lt_top_iff_ne_top.mp hf.2)]
#align measure_theory.of_real_integral_norm_eq_lintegral_nnnorm MeasureTheory.ofReal_integral_norm_eq_lintegral_nnnorm
-/

#print MeasureTheory.integral_eq_integral_pos_part_sub_integral_neg_part /-
theorem integral_eq_integral_pos_part_sub_integral_neg_part {f : α → ℝ} (hf : Integrable f μ) :
    ∫ a, f a ∂μ = ∫ a, Real.toNNReal (f a) ∂μ - ∫ a, Real.toNNReal (-f a) ∂μ :=
  by
  rw [← integral_sub hf.real_to_nnreal]
  · simp
  · exact hf.neg.real_to_nnreal
#align measure_theory.integral_eq_integral_pos_part_sub_integral_neg_part MeasureTheory.integral_eq_integral_pos_part_sub_integral_neg_part
-/

#print MeasureTheory.integral_nonneg_of_ae /-
theorem integral_nonneg_of_ae {f : α → ℝ} (hf : 0 ≤ᵐ[μ] f) : 0 ≤ ∫ a, f a ∂μ :=
  by
  simp only [integral, L1.integral]
  exact
    set_to_fun_nonneg (dominated_fin_meas_additive_weighted_smul μ)
      (fun s _ _ => weighted_smul_nonneg s) hf
#align measure_theory.integral_nonneg_of_ae MeasureTheory.integral_nonneg_of_ae
-/

#print MeasureTheory.lintegral_coe_eq_integral /-
theorem lintegral_coe_eq_integral (f : α → ℝ≥0) (hfi : Integrable (fun x => (f x : ℝ)) μ) :
    ∫⁻ a, f a ∂μ = ENNReal.ofReal (∫ a, f a ∂μ) :=
  by
  simp_rw [integral_eq_lintegral_of_nonneg_ae (eventually_of_forall fun x => (f x).coe_nonneg)
      hfi.ae_strongly_measurable,
    ← ENNReal.coe_nnreal_eq]
  rw [ENNReal.ofReal_toReal]
  rw [← lt_top_iff_ne_top]; convert hfi.has_finite_integral; ext1 x; rw [NNReal.nnnorm_eq]
#align measure_theory.lintegral_coe_eq_integral MeasureTheory.lintegral_coe_eq_integral
-/

#print MeasureTheory.ofReal_integral_eq_lintegral_ofReal /-
theorem ofReal_integral_eq_lintegral_ofReal {f : α → ℝ} (hfi : Integrable f μ) (f_nn : 0 ≤ᵐ[μ] f) :
    ENNReal.ofReal (∫ x, f x ∂μ) = ∫⁻ x, ENNReal.ofReal (f x) ∂μ :=
  by
  simp_rw [integral_congr_ae
      (show f =ᵐ[μ] fun x => ‖f x‖ by
        filter_upwards [f_nn] with x hx
        rw [Real.norm_eq_abs, abs_eq_self.mpr hx]),
    of_real_integral_norm_eq_lintegral_nnnorm hfi, ← ofReal_norm_eq_coe_nnnorm]
  apply lintegral_congr_ae
  filter_upwards [f_nn] with x hx
  exact congr_arg ENNReal.ofReal (by rw [Real.norm_eq_abs, abs_eq_self.mpr hx])
#align measure_theory.of_real_integral_eq_lintegral_of_real MeasureTheory.ofReal_integral_eq_lintegral_ofReal
-/

#print MeasureTheory.integral_toReal /-
theorem integral_toReal {f : α → ℝ≥0∞} (hfm : AEMeasurable f μ) (hf : ∀ᵐ x ∂μ, f x < ∞) :
    ∫ a, (f a).toReal ∂μ = (∫⁻ a, f a ∂μ).toReal :=
  by
  rw [integral_eq_lintegral_of_nonneg_ae _ hfm.ennreal_to_real.ae_strongly_measurable]
  · rw [lintegral_congr_ae]; refine' hf.mp (eventually_of_forall _)
    intro x hx; rw [lt_top_iff_ne_top] at hx ; simp [hx]
  · exact eventually_of_forall fun x => ENNReal.toReal_nonneg
#align measure_theory.integral_to_real MeasureTheory.integral_toReal
-/

#print MeasureTheory.lintegral_coe_le_coe_iff_integral_le /-
theorem lintegral_coe_le_coe_iff_integral_le {f : α → ℝ≥0} (hfi : Integrable (fun x => (f x : ℝ)) μ)
    {b : ℝ≥0} : ∫⁻ a, f a ∂μ ≤ b ↔ ∫ a, (f a : ℝ) ∂μ ≤ b := by
  rw [lintegral_coe_eq_integral f hfi, ENNReal.ofReal, ENNReal.coe_le_coe,
    Real.toNNReal_le_iff_le_coe]
#align measure_theory.lintegral_coe_le_coe_iff_integral_le MeasureTheory.lintegral_coe_le_coe_iff_integral_le
-/

#print MeasureTheory.integral_coe_le_of_lintegral_coe_le /-
theorem integral_coe_le_of_lintegral_coe_le {f : α → ℝ≥0} {b : ℝ≥0} (h : ∫⁻ a, f a ∂μ ≤ b) :
    ∫ a, (f a : ℝ) ∂μ ≤ b :=
  by
  by_cases hf : integrable (fun a => (f a : ℝ)) μ
  · exact (lintegral_coe_le_coe_iff_integral_le hf).1 h
  · rw [integral_undef hf]; exact b.2
#align measure_theory.integral_coe_le_of_lintegral_coe_le MeasureTheory.integral_coe_le_of_lintegral_coe_le
-/

#print MeasureTheory.integral_nonneg /-
theorem integral_nonneg {f : α → ℝ} (hf : 0 ≤ f) : 0 ≤ ∫ a, f a ∂μ :=
  integral_nonneg_of_ae <| eventually_of_forall hf
#align measure_theory.integral_nonneg MeasureTheory.integral_nonneg
-/

#print MeasureTheory.integral_nonpos_of_ae /-
theorem integral_nonpos_of_ae {f : α → ℝ} (hf : f ≤ᵐ[μ] 0) : ∫ a, f a ∂μ ≤ 0 :=
  by
  have hf : 0 ≤ᵐ[μ] -f := hf.mono fun a h => by rwa [Pi.neg_apply, Pi.zero_apply, neg_nonneg]
  have : 0 ≤ ∫ a, -f a ∂μ := integral_nonneg_of_ae hf
  rwa [integral_neg, neg_nonneg] at this 
#align measure_theory.integral_nonpos_of_ae MeasureTheory.integral_nonpos_of_ae
-/

#print MeasureTheory.integral_nonpos /-
theorem integral_nonpos {f : α → ℝ} (hf : f ≤ 0) : ∫ a, f a ∂μ ≤ 0 :=
  integral_nonpos_of_ae <| eventually_of_forall hf
#align measure_theory.integral_nonpos MeasureTheory.integral_nonpos
-/

#print MeasureTheory.integral_eq_zero_iff_of_nonneg_ae /-
theorem integral_eq_zero_iff_of_nonneg_ae {f : α → ℝ} (hf : 0 ≤ᵐ[μ] f) (hfi : Integrable f μ) :
    ∫ x, f x ∂μ = 0 ↔ f =ᵐ[μ] 0 := by
  simp_rw [integral_eq_lintegral_of_nonneg_ae hf hfi.1, ENNReal.toReal_eq_zero_iff,
    lintegral_eq_zero_iff' (ennreal.measurable_of_real.comp_ae_measurable hfi.1.AEMeasurable), ←
    ENNReal.not_lt_top, ← has_finite_integral_iff_of_real hf, hfi.2, not_true, or_false_iff, ←
    hf.le_iff_eq, Filter.EventuallyEq, Filter.EventuallyLE, (· ∘ ·), Pi.zero_apply,
    ENNReal.ofReal_eq_zero]
#align measure_theory.integral_eq_zero_iff_of_nonneg_ae MeasureTheory.integral_eq_zero_iff_of_nonneg_ae
-/

#print MeasureTheory.integral_eq_zero_iff_of_nonneg /-
theorem integral_eq_zero_iff_of_nonneg {f : α → ℝ} (hf : 0 ≤ f) (hfi : Integrable f μ) :
    ∫ x, f x ∂μ = 0 ↔ f =ᵐ[μ] 0 :=
  integral_eq_zero_iff_of_nonneg_ae (eventually_of_forall hf) hfi
#align measure_theory.integral_eq_zero_iff_of_nonneg MeasureTheory.integral_eq_zero_iff_of_nonneg
-/

#print MeasureTheory.integral_pos_iff_support_of_nonneg_ae /-
theorem integral_pos_iff_support_of_nonneg_ae {f : α → ℝ} (hf : 0 ≤ᵐ[μ] f) (hfi : Integrable f μ) :
    0 < ∫ x, f x ∂μ ↔ 0 < μ (Function.support f) := by
  simp_rw [(integral_nonneg_of_ae hf).lt_iff_ne, pos_iff_ne_zero, Ne.def, @eq_comm ℝ 0,
    integral_eq_zero_iff_of_nonneg_ae hf hfi, Filter.EventuallyEq, ae_iff, Pi.zero_apply,
    Function.support]
#align measure_theory.integral_pos_iff_support_of_nonneg_ae MeasureTheory.integral_pos_iff_support_of_nonneg_ae
-/

#print MeasureTheory.integral_pos_iff_support_of_nonneg /-
theorem integral_pos_iff_support_of_nonneg {f : α → ℝ} (hf : 0 ≤ f) (hfi : Integrable f μ) :
    0 < ∫ x, f x ∂μ ↔ 0 < μ (Function.support f) :=
  integral_pos_iff_support_of_nonneg_ae (eventually_of_forall hf) hfi
#align measure_theory.integral_pos_iff_support_of_nonneg MeasureTheory.integral_pos_iff_support_of_nonneg
-/

section NormedAddCommGroup

variable {H : Type _} [NormedAddCommGroup H]

#print MeasureTheory.L1.norm_eq_integral_norm /-
theorem L1.norm_eq_integral_norm (f : α →₁[μ] H) : ‖f‖ = ∫ a, ‖f a‖ ∂μ :=
  by
  simp only [snorm, snorm', ENNReal.one_toReal, ENNReal.rpow_one, Lp.norm_def, if_false,
    ENNReal.one_ne_top, one_ne_zero, _root_.div_one]
  rw [integral_eq_lintegral_of_nonneg_ae (eventually_of_forall (by simp [norm_nonneg]))
      (Lp.ae_strongly_measurable f).norm]
  simp [ofReal_norm_eq_coe_nnnorm]
#align measure_theory.L1.norm_eq_integral_norm MeasureTheory.L1.norm_eq_integral_norm
-/

#print MeasureTheory.L1.norm_of_fun_eq_integral_norm /-
theorem L1.norm_of_fun_eq_integral_norm {f : α → H} (hf : Integrable f μ) :
    ‖hf.toL1 f‖ = ∫ a, ‖f a‖ ∂μ := by
  rw [L1.norm_eq_integral_norm]
  refine' integral_congr_ae _
  apply hf.coe_fn_to_L1.mono
  intro a ha
  simp [ha]
#align measure_theory.L1.norm_of_fun_eq_integral_norm MeasureTheory.L1.norm_of_fun_eq_integral_norm
-/

#print MeasureTheory.Memℒp.snorm_eq_integral_rpow_norm /-
theorem Memℒp.snorm_eq_integral_rpow_norm {f : α → H} {p : ℝ≥0∞} (hp1 : p ≠ 0) (hp2 : p ≠ ∞)
    (hf : Memℒp f p μ) : snorm f p μ = ENNReal.ofReal ((∫ a, ‖f a‖ ^ p.toReal ∂μ) ^ p.toReal⁻¹) :=
  by
  have A : ∫⁻ a : α, ENNReal.ofReal (‖f a‖ ^ p.to_real) ∂μ = ∫⁻ a : α, ‖f a‖₊ ^ p.to_real ∂μ :=
    by
    apply lintegral_congr fun x => _
    rw [← of_real_rpow_of_nonneg (norm_nonneg _) to_real_nonneg, ofReal_norm_eq_coe_nnnorm]
  simp only [snorm_eq_lintegral_rpow_nnnorm hp1 hp2, one_div]
  rw [integral_eq_lintegral_of_nonneg_ae]; rotate_left
  · exact eventually_of_forall fun x => Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
  · exact (hf.ae_strongly_measurable.norm.ae_measurable.pow_const _).AEStronglyMeasurable
  rw [A, ← of_real_rpow_of_nonneg to_real_nonneg (inv_nonneg.2 to_real_nonneg), of_real_to_real]
  exact (lintegral_rpow_nnnorm_lt_top_of_snorm_lt_top hp1 hp2 hf.2).Ne
#align measure_theory.mem_ℒp.snorm_eq_integral_rpow_norm MeasureTheory.Memℒp.snorm_eq_integral_rpow_norm
-/

end NormedAddCommGroup

#print MeasureTheory.integral_mono_ae /-
theorem integral_mono_ae {f g : α → ℝ} (hf : Integrable f μ) (hg : Integrable g μ) (h : f ≤ᵐ[μ] g) :
    ∫ a, f a ∂μ ≤ ∫ a, g a ∂μ := by
  simp only [integral, L1.integral]
  exact
    set_to_fun_mono (dominated_fin_meas_additive_weighted_smul μ)
      (fun s _ _ => weighted_smul_nonneg s) hf hg h
#align measure_theory.integral_mono_ae MeasureTheory.integral_mono_ae
-/

#print MeasureTheory.integral_mono /-
@[mono]
theorem integral_mono {f g : α → ℝ} (hf : Integrable f μ) (hg : Integrable g μ) (h : f ≤ g) :
    ∫ a, f a ∂μ ≤ ∫ a, g a ∂μ :=
  integral_mono_ae hf hg <| eventually_of_forall h
#align measure_theory.integral_mono MeasureTheory.integral_mono
-/

#print MeasureTheory.integral_mono_of_nonneg /-
theorem integral_mono_of_nonneg {f g : α → ℝ} (hf : 0 ≤ᵐ[μ] f) (hgi : Integrable g μ)
    (h : f ≤ᵐ[μ] g) : ∫ a, f a ∂μ ≤ ∫ a, g a ∂μ :=
  by
  by_cases hfm : ae_strongly_measurable f μ
  · refine' integral_mono_ae ⟨hfm, _⟩ hgi h
    refine' hgi.has_finite_integral.mono <| h.mp <| hf.mono fun x hf hfg => _
    simpa [abs_of_nonneg hf, abs_of_nonneg (le_trans hf hfg)]
  · rw [integral_non_ae_strongly_measurable hfm]
    exact integral_nonneg_of_ae (hf.trans h)
#align measure_theory.integral_mono_of_nonneg MeasureTheory.integral_mono_of_nonneg
-/

#print MeasureTheory.integral_mono_measure /-
theorem integral_mono_measure {f : α → ℝ} {ν} (hle : μ ≤ ν) (hf : 0 ≤ᵐ[ν] f)
    (hfi : Integrable f ν) : ∫ a, f a ∂μ ≤ ∫ a, f a ∂ν :=
  by
  have hfi' : integrable f μ := hfi.mono_measure hle
  have hf' : 0 ≤ᵐ[μ] f := hle.absolutely_continuous hf
  rw [integral_eq_lintegral_of_nonneg_ae hf' hfi'.1, integral_eq_lintegral_of_nonneg_ae hf hfi.1,
    ENNReal.toReal_le_toReal]
  exacts [lintegral_mono' hle le_rfl, ((has_finite_integral_iff_of_real hf').1 hfi'.2).Ne,
    ((has_finite_integral_iff_of_real hf).1 hfi.2).Ne]
#align measure_theory.integral_mono_measure MeasureTheory.integral_mono_measure
-/

#print MeasureTheory.norm_integral_le_integral_norm /-
theorem norm_integral_le_integral_norm (f : α → E) : ‖∫ a, f a ∂μ‖ ≤ ∫ a, ‖f a‖ ∂μ :=
  have le_ae : ∀ᵐ a ∂μ, 0 ≤ ‖f a‖ := eventually_of_forall fun a => norm_nonneg _
  by_cases
    (fun h : AEStronglyMeasurable f μ =>
      calc
        ‖∫ a, f a ∂μ‖ ≤ ENNReal.toReal (∫⁻ a, ENNReal.ofReal ‖f a‖ ∂μ) :=
          norm_integral_le_lintegral_norm _
        _ = ∫ a, ‖f a‖ ∂μ := (integral_eq_lintegral_of_nonneg_ae le_ae <| h.norm).symm)
    fun h : ¬AEStronglyMeasurable f μ =>
    by
    rw [integral_non_ae_strongly_measurable h, norm_zero]
    exact integral_nonneg_of_ae le_ae
#align measure_theory.norm_integral_le_integral_norm MeasureTheory.norm_integral_le_integral_norm
-/

#print MeasureTheory.norm_integral_le_of_norm_le /-
theorem norm_integral_le_of_norm_le {f : α → E} {g : α → ℝ} (hg : Integrable g μ)
    (h : ∀ᵐ x ∂μ, ‖f x‖ ≤ g x) : ‖∫ x, f x ∂μ‖ ≤ ∫ x, g x ∂μ :=
  calc
    ‖∫ x, f x ∂μ‖ ≤ ∫ x, ‖f x‖ ∂μ := norm_integral_le_integral_norm f
    _ ≤ ∫ x, g x ∂μ := integral_mono_of_nonneg (eventually_of_forall fun x => norm_nonneg _) hg h
#align measure_theory.norm_integral_le_of_norm_le MeasureTheory.norm_integral_le_of_norm_le
-/

#print MeasureTheory.SimpleFunc.integral_eq_integral /-
theorem SimpleFunc.integral_eq_integral (f : α →ₛ E) (hfi : Integrable f μ) :
    f.integral μ = ∫ x, f x ∂μ :=
  by
  rw [integral_eq f hfi, ← L1.simple_func.to_Lp_one_eq_to_L1,
    L1.simple_func.integral_L1_eq_integral, L1.simple_func.integral_eq_integral]
  exact simple_func.integral_congr hfi (Lp.simple_func.to_simple_func_to_Lp _ _).symm
#align measure_theory.simple_func.integral_eq_integral MeasureTheory.SimpleFunc.integral_eq_integral
-/

#print MeasureTheory.SimpleFunc.integral_eq_sum /-
theorem SimpleFunc.integral_eq_sum (f : α →ₛ E) (hfi : Integrable f μ) :
    ∫ x, f x ∂μ = ∑ x in f.range, ENNReal.toReal (μ (f ⁻¹' {x})) • x := by
  rw [← f.integral_eq_integral hfi, simple_func.integral, ← simple_func.integral_eq]; rfl
#align measure_theory.simple_func.integral_eq_sum MeasureTheory.SimpleFunc.integral_eq_sum
-/

#print MeasureTheory.integral_const /-
@[simp]
theorem integral_const (c : E) : ∫ x : α, c ∂μ = (μ univ).toReal • c :=
  by
  cases' (@le_top _ _ _ (μ univ)).lt_or_eq with hμ hμ
  · haveI : is_finite_measure μ := ⟨hμ⟩
    simp only [integral, L1.integral]
    exact set_to_fun_const (dominated_fin_meas_additive_weighted_smul _) _
  · by_cases hc : c = 0
    · simp [hc, integral_zero]
    · have : ¬integrable (fun x : α => c) μ :=
        by
        simp only [integrable_const_iff, not_or]
        exact ⟨hc, hμ.not_lt⟩
      simp [integral_undef, *]
#align measure_theory.integral_const MeasureTheory.integral_const
-/

#print MeasureTheory.norm_integral_le_of_norm_le_const /-
theorem norm_integral_le_of_norm_le_const [IsFiniteMeasure μ] {f : α → E} {C : ℝ}
    (h : ∀ᵐ x ∂μ, ‖f x‖ ≤ C) : ‖∫ x, f x ∂μ‖ ≤ C * (μ univ).toReal :=
  calc
    ‖∫ x, f x ∂μ‖ ≤ ∫ x, C ∂μ := norm_integral_le_of_norm_le (integrable_const C) h
    _ = C * (μ univ).toReal := by rw [integral_const, smul_eq_mul, mul_comm]
#align measure_theory.norm_integral_le_of_norm_le_const MeasureTheory.norm_integral_le_of_norm_le_const
-/

#print MeasureTheory.tendsto_integral_approxOn_of_measurable /-
theorem tendsto_integral_approxOn_of_measurable [MeasurableSpace E] [BorelSpace E] {f : α → E}
    {s : Set E} [SeparableSpace s] (hfi : Integrable f μ) (hfm : Measurable f)
    (hs : ∀ᵐ x ∂μ, f x ∈ closure s) {y₀ : E} (h₀ : y₀ ∈ s) (h₀i : Integrable (fun x => y₀) μ) :
    Tendsto (fun n => (SimpleFunc.approxOn f hfm s y₀ h₀ n).integral μ) atTop (𝓝 <| ∫ x, f x ∂μ) :=
  by
  have hfi' := simple_func.integrable_approx_on hfm hfi h₀ h₀i
  simp only [simple_func.integral_eq_integral _ (hfi' _), integral, L1.integral]
  exact
    tendsto_set_to_fun_approx_on_of_measurable (dominated_fin_meas_additive_weighted_smul μ) hfi hfm
      hs h₀ h₀i
#align measure_theory.tendsto_integral_approx_on_of_measurable MeasureTheory.tendsto_integral_approxOn_of_measurable
-/

#print MeasureTheory.tendsto_integral_approxOn_of_measurable_of_range_subset /-
theorem tendsto_integral_approxOn_of_measurable_of_range_subset [MeasurableSpace E] [BorelSpace E]
    {f : α → E} (fmeas : Measurable f) (hf : Integrable f μ) (s : Set E) [SeparableSpace s]
    (hs : range f ∪ {0} ⊆ s) :
    Tendsto (fun n => (SimpleFunc.approxOn f fmeas s 0 (hs <| by simp) n).integral μ) atTop
      (𝓝 <| ∫ x, f x ∂μ) :=
  by
  apply tendsto_integral_approx_on_of_measurable hf fmeas _ _ (integrable_zero _ _ _)
  exact eventually_of_forall fun x => subset_closure (hs (Set.mem_union_left _ (mem_range_self _)))
#align measure_theory.tendsto_integral_approx_on_of_measurable_of_range_subset MeasureTheory.tendsto_integral_approxOn_of_measurable_of_range_subset
-/

variable {ν : Measure α}

#print MeasureTheory.integral_add_measure /-
theorem integral_add_measure {f : α → E} (hμ : Integrable f μ) (hν : Integrable f ν) :
    ∫ x, f x ∂(μ + ν) = ∫ x, f x ∂μ + ∫ x, f x ∂ν :=
  by
  have hfi := hμ.add_measure hν
  simp_rw [integral_eq_set_to_fun]
  have hμ_dfma : dominated_fin_meas_additive (μ + ν) (weighted_smul μ : Set α → E →L[ℝ] E) 1 :=
    dominated_fin_meas_additive.add_measure_right μ ν (dominated_fin_meas_additive_weighted_smul μ)
      zero_le_one
  have hν_dfma : dominated_fin_meas_additive (μ + ν) (weighted_smul ν : Set α → E →L[ℝ] E) 1 :=
    dominated_fin_meas_additive.add_measure_left μ ν (dominated_fin_meas_additive_weighted_smul ν)
      zero_le_one
  rw [←
    set_to_fun_congr_measure_of_add_right hμ_dfma (dominated_fin_meas_additive_weighted_smul μ) f
      hfi,
    ←
    set_to_fun_congr_measure_of_add_left hν_dfma (dominated_fin_meas_additive_weighted_smul ν) f
      hfi]
  refine' set_to_fun_add_left' _ _ _ (fun s hs hμνs => _) f
  rw [measure.coe_add, Pi.add_apply, add_lt_top] at hμνs 
  rw [weighted_smul, weighted_smul, weighted_smul, ← add_smul, measure.coe_add, Pi.add_apply,
    to_real_add hμνs.1.Ne hμνs.2.Ne]
#align measure_theory.integral_add_measure MeasureTheory.integral_add_measure
-/

#print MeasureTheory.integral_zero_measure /-
@[simp]
theorem integral_zero_measure {m : MeasurableSpace α} (f : α → E) : ∫ x, f x ∂(0 : Measure α) = 0 :=
  by
  simp only [integral, L1.integral]
  exact set_to_fun_measure_zero (dominated_fin_meas_additive_weighted_smul _) rfl
#align measure_theory.integral_zero_measure MeasureTheory.integral_zero_measure
-/

#print MeasureTheory.integral_finset_sum_measure /-
theorem integral_finset_sum_measure {ι} {m : MeasurableSpace α} {f : α → E} {μ : ι → Measure α}
    {s : Finset ι} (hf : ∀ i ∈ s, Integrable f (μ i)) :
    ∫ a, f a ∂∑ i in s, μ i = ∑ i in s, ∫ a, f a ∂μ i := by
  classical
  refine' Finset.induction_on' s _ _
  -- `induction s using finset.induction_on'` fails
  · simp
  · intro i t hi ht hit iht
    simp only [Finset.sum_insert hit, ← iht]
    exact integral_add_measure (hf _ hi) (integrable_finset_sum_measure.2 fun j hj => hf j (ht hj))
#align measure_theory.integral_finset_sum_measure MeasureTheory.integral_finset_sum_measure
-/

#print MeasureTheory.nndist_integral_add_measure_le_lintegral /-
theorem nndist_integral_add_measure_le_lintegral (h₁ : Integrable f μ) (h₂ : Integrable f ν) :
    (nndist (∫ x, f x ∂μ) (∫ x, f x ∂(μ + ν)) : ℝ≥0∞) ≤ ∫⁻ x, ‖f x‖₊ ∂ν :=
  by
  rw [integral_add_measure h₁ h₂, nndist_comm, nndist_eq_nnnorm, add_sub_cancel']
  exact ennnorm_integral_le_lintegral_ennnorm _
#align measure_theory.nndist_integral_add_measure_le_lintegral MeasureTheory.nndist_integral_add_measure_le_lintegral
-/

#print MeasureTheory.hasSum_integral_measure /-
theorem hasSum_integral_measure {ι} {m : MeasurableSpace α} {f : α → E} {μ : ι → Measure α}
    (hf : Integrable f (Measure.sum μ)) :
    HasSum (fun i => ∫ a, f a ∂μ i) (∫ a, f a ∂Measure.sum μ) :=
  by
  have hfi : ∀ i, integrable f (μ i) := fun i => hf.mono_measure (measure.le_sum _ _)
  simp only [HasSum, ← integral_finset_sum_measure fun i _ => hfi i]
  refine' metric.nhds_basis_ball.tendsto_right_iff.mpr fun ε ε0 => _
  lift ε to ℝ≥0 using ε0.le
  have hf_lt : ∫⁻ x, ‖f x‖₊ ∂measure.sum μ < ∞ := hf.2
  have hmem : ∀ᶠ y in 𝓝 (∫⁻ x, ‖f x‖₊ ∂measure.sum μ), ∫⁻ x, ‖f x‖₊ ∂measure.sum μ < y + ε :=
    by
    refine' tendsto_id.add tendsto_const_nhds (lt_mem_nhds <| ENNReal.lt_add_right _ _)
    exacts [hf_lt.ne, ENNReal.coe_ne_zero.2 (NNReal.coe_ne_zero.1 ε0.ne')]
  refine' ((has_sum_lintegral_measure (fun x => ‖f x‖₊) μ).Eventually hmem).mono fun s hs => _
  obtain ⟨ν, hν⟩ : ∃ ν, ∑ i in s, μ i + ν = measure.sum μ :=
    by
    refine' ⟨measure.sum fun i : ↥(sᶜ : Set ι) => μ i, _⟩
    simpa only [← measure.sum_coe_finset] using measure.sum_add_sum_compl (s : Set ι) μ
  rw [Metric.mem_ball, ← coe_nndist, NNReal.coe_lt_coe, ← ENNReal.coe_lt_coe, ← hν]
  rw [← hν, integrable_add_measure] at hf 
  refine' (nndist_integral_add_measure_le_lintegral hf.1 hf.2).trans_lt _
  rw [← hν, lintegral_add_measure, lintegral_finset_sum_measure] at hs 
  exact lt_of_add_lt_add_left hs
#align measure_theory.has_sum_integral_measure MeasureTheory.hasSum_integral_measure
-/

#print MeasureTheory.integral_sum_measure /-
theorem integral_sum_measure {ι} {m : MeasurableSpace α} {f : α → E} {μ : ι → Measure α}
    (hf : Integrable f (Measure.sum μ)) : ∫ a, f a ∂Measure.sum μ = ∑' i, ∫ a, f a ∂μ i :=
  (hasSum_integral_measure hf).tsum_eq.symm
#align measure_theory.integral_sum_measure MeasureTheory.integral_sum_measure
-/

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:38: in filter_upwards #[[], ["with", ident x], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error @ arg 0: next failed, no more args -/
#print MeasureTheory.integral_tsum /-
theorem integral_tsum {ι} [Countable ι] {f : ι → α → E} (hf : ∀ i, AEStronglyMeasurable (f i) μ)
    (hf' : ∑' i, ∫⁻ a : α, ‖f i a‖₊ ∂μ ≠ ∞) : ∫ a : α, ∑' i, f i a ∂μ = ∑' i, ∫ a : α, f i a ∂μ :=
  by
  have hf'' : ∀ i, AEMeasurable (fun x => (‖f i x‖₊ : ℝ≥0∞)) μ := fun i => (hf i).ennnorm
  have hhh : ∀ᵐ a : α ∂μ, Summable fun n => (‖f n a‖₊ : ℝ) :=
    by
    rw [← lintegral_tsum hf''] at hf' 
    refine' (ae_lt_top' (AEMeasurable.ennreal_tsum hf'') hf').mono _
    intro x hx
    rw [← ENNReal.tsum_coe_ne_top_iff_summable_coe]
    exact hx.ne
  convert
    (MeasureTheory.hasSum_integral_of_dominated_convergence (fun i a => ‖f i a‖₊) hf _ hhh ⟨_, _⟩
          _).tsum_eq.symm
  · intro n
    trace
      "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:72:38: in filter_upwards #[[], [\"with\", ident x], []]: ./././Mathport/Syntax/Translate/Basic.lean:349:22: unsupported: parse error @ arg 0: next failed, no more args"
    rfl
  · simp_rw [← coe_nnnorm, ← NNReal.coe_tsum]
    rw [aestronglyMeasurable_iff_aemeasurable]
    apply AEMeasurable.coe_nnreal_real
    apply AEMeasurable.nnreal_tsum
    exact fun i => (hf i).nnnorm.AEMeasurable
  · dsimp [has_finite_integral]
    have : ∫⁻ a, ∑' n, ‖f n a‖₊ ∂μ < ⊤ := by rwa [lintegral_tsum hf'', lt_top_iff_ne_top]
    convert this using 1
    apply lintegral_congr_ae
    simp_rw [← coe_nnnorm, ← NNReal.coe_tsum, NNReal.nnnorm_eq]
    filter_upwards [hhh] with a ha
    exact ENNReal.coe_tsum (nnreal.summable_coe.mp ha)
  · filter_upwards [hhh] with x hx
    exact (summable_of_summable_norm hx).HasSum
#align measure_theory.integral_tsum MeasureTheory.integral_tsum
-/

#print MeasureTheory.integral_smul_measure /-
@[simp]
theorem integral_smul_measure (f : α → E) (c : ℝ≥0∞) : ∫ x, f x ∂c • μ = c.toReal • ∫ x, f x ∂μ :=
  by
  -- First we consider the “degenerate” case `c = ∞`
  rcases eq_or_ne c ∞ with (rfl | hc)
  · rw [ENNReal.top_toReal, zero_smul, integral_eq_set_to_fun, set_to_fun_top_smul_measure]
  -- Main case: `c ≠ ∞`
  simp_rw [integral_eq_set_to_fun, ← set_to_fun_smul_left]
  have hdfma :
    dominated_fin_meas_additive μ (weighted_smul (c • μ) : Set α → E →L[ℝ] E) c.to_real :=
    mul_one c.to_real ▸ (dominated_fin_meas_additive_weighted_smul (c • μ)).of_smul_measure c hc
  have hdfma_smul := dominated_fin_meas_additive_weighted_smul (c • μ)
  rw [← set_to_fun_congr_smul_measure c hc hdfma hdfma_smul f]
  exact set_to_fun_congr_left' _ _ (fun s hs hμs => weighted_smul_smul_measure μ c) f
#align measure_theory.integral_smul_measure MeasureTheory.integral_smul_measure
-/

#print MeasureTheory.integral_map_of_stronglyMeasurable /-
theorem integral_map_of_stronglyMeasurable {β} [MeasurableSpace β] {φ : α → β} (hφ : Measurable φ)
    {f : β → E} (hfm : StronglyMeasurable f) : ∫ y, f y ∂Measure.map φ μ = ∫ x, f (φ x) ∂μ :=
  by
  by_cases hfi : integrable f (measure.map φ μ); swap
  · rw [integral_undef hfi, integral_undef]
    rwa [← integrable_map_measure hfm.ae_strongly_measurable hφ.ae_measurable]
  borelize E
  haveI : separable_space (range f ∪ {0} : Set E) := hfm.separable_space_range_union_singleton
  refine'
    tendsto_nhds_unique
      (tendsto_integral_approx_on_of_measurable_of_range_subset hfm.measurable hfi _ subset.rfl) _
  convert
    tendsto_integral_approx_on_of_measurable_of_range_subset (hfm.measurable.comp hφ)
      ((integrable_map_measure hfm.ae_strongly_measurable hφ.ae_measurable).1 hfi) (range f ∪ {0})
      (by simp [insert_subset_insert, Set.range_comp_subset_range]) using
    1
  ext1 i
  simp only [simple_func.approx_on_comp, simple_func.integral_eq, measure.map_apply, hφ,
    simple_func.measurable_set_preimage, ← preimage_comp, simple_func.coe_comp]
  refine' (Finset.sum_subset (simple_func.range_comp_subset_range _ hφ) fun y _ hy => _).symm
  rw [simple_func.mem_range, ← Set.preimage_singleton_eq_empty, simple_func.coe_comp] at hy 
  rw [hy]
  simp
#align measure_theory.integral_map_of_strongly_measurable MeasureTheory.integral_map_of_stronglyMeasurable
-/

#print MeasureTheory.integral_map /-
theorem integral_map {β} [MeasurableSpace β] {φ : α → β} (hφ : AEMeasurable φ μ) {f : β → E}
    (hfm : AEStronglyMeasurable f (Measure.map φ μ)) :
    ∫ y, f y ∂Measure.map φ μ = ∫ x, f (φ x) ∂μ :=
  let g := hfm.mk f
  calc
    ∫ y, f y ∂Measure.map φ μ = ∫ y, g y ∂Measure.map φ μ := integral_congr_ae hfm.ae_eq_mk
    _ = ∫ y, g y ∂Measure.map (hφ.mk φ) μ := by congr 1; exact measure.map_congr hφ.ae_eq_mk
    _ = ∫ x, g (hφ.mk φ x) ∂μ :=
      (integral_map_of_stronglyMeasurable hφ.measurable_mk hfm.stronglyMeasurable_mk)
    _ = ∫ x, g (φ x) ∂μ := (integral_congr_ae (hφ.ae_eq_mk.symm.fun_comp _))
    _ = ∫ x, f (φ x) ∂μ := integral_congr_ae <| ae_eq_comp hφ hfm.ae_eq_mk.symm
#align measure_theory.integral_map MeasureTheory.integral_map
-/

#print MeasurableEmbedding.integral_map /-
theorem MeasurableEmbedding.integral_map {β} {_ : MeasurableSpace β} {f : α → β}
    (hf : MeasurableEmbedding f) (g : β → E) : ∫ y, g y ∂Measure.map f μ = ∫ x, g (f x) ∂μ :=
  by
  by_cases hgm : ae_strongly_measurable g (measure.map f μ)
  · exact integral_map hf.measurable.ae_measurable hgm
  · rw [integral_non_ae_strongly_measurable hgm, integral_non_ae_strongly_measurable]
    rwa [← hf.ae_strongly_measurable_map_iff]
#align measurable_embedding.integral_map MeasurableEmbedding.integral_map
-/

#print ClosedEmbedding.integral_map /-
theorem ClosedEmbedding.integral_map {β} [TopologicalSpace α] [BorelSpace α] [TopologicalSpace β]
    [MeasurableSpace β] [BorelSpace β] {φ : α → β} (hφ : ClosedEmbedding φ) (f : β → E) :
    ∫ y, f y ∂Measure.map φ μ = ∫ x, f (φ x) ∂μ :=
  hφ.MeasurableEmbedding.integral_map _
#align closed_embedding.integral_map ClosedEmbedding.integral_map
-/

#print MeasureTheory.integral_map_equiv /-
theorem integral_map_equiv {β} [MeasurableSpace β] (e : α ≃ᵐ β) (f : β → E) :
    ∫ y, f y ∂Measure.map e μ = ∫ x, f (e x) ∂μ :=
  e.MeasurableEmbedding.integral_map f
#align measure_theory.integral_map_equiv MeasureTheory.integral_map_equiv
-/

#print MeasureTheory.MeasurePreserving.integral_comp /-
theorem MeasurePreserving.integral_comp {β} {_ : MeasurableSpace β} {f : α → β} {ν}
    (h₁ : MeasurePreserving f μ ν) (h₂ : MeasurableEmbedding f) (g : β → E) :
    ∫ x, g (f x) ∂μ = ∫ y, g y ∂ν :=
  h₁.map_eq ▸ (h₂.integral_map g).symm
#align measure_theory.measure_preserving.integral_comp MeasureTheory.MeasurePreserving.integral_comp
-/

#print MeasureTheory.set_integral_eq_subtype /-
theorem set_integral_eq_subtype {α} [MeasureSpace α] {s : Set α} (hs : MeasurableSet s)
    (f : α → E) : ∫ x in s, f x = ∫ x : s, f x := by rw [← map_comap_subtype_coe hs];
  exact (MeasurableEmbedding.subtype_coe hs).integral_map _
#align measure_theory.set_integral_eq_subtype MeasureTheory.set_integral_eq_subtype
-/

#print MeasureTheory.integral_dirac' /-
@[simp]
theorem integral_dirac' [MeasurableSpace α] (f : α → E) (a : α) (hfm : StronglyMeasurable f) :
    ∫ x, f x ∂Measure.dirac a = f a := by
  borelize E
  calc
    ∫ x, f x ∂measure.dirac a = ∫ x, f a ∂measure.dirac a :=
      integral_congr_ae <| ae_eq_dirac' hfm.measurable
    _ = f a := by simp [measure.dirac_apply_of_mem]
#align measure_theory.integral_dirac' MeasureTheory.integral_dirac'
-/

#print MeasureTheory.integral_dirac /-
@[simp]
theorem integral_dirac [MeasurableSpace α] [MeasurableSingletonClass α] (f : α → E) (a : α) :
    ∫ x, f x ∂Measure.dirac a = f a :=
  calc
    ∫ x, f x ∂Measure.dirac a = ∫ x, f a ∂Measure.dirac a := integral_congr_ae <| ae_eq_dirac f
    _ = f a := by simp [measure.dirac_apply_of_mem]
#align measure_theory.integral_dirac MeasureTheory.integral_dirac
-/

#print MeasureTheory.set_integral_dirac' /-
theorem set_integral_dirac' {mα : MeasurableSpace α} {f : α → E} (hf : StronglyMeasurable f) (a : α)
    {s : Set α} (hs : MeasurableSet s) [Decidable (a ∈ s)] :
    ∫ x in s, f x ∂Measure.dirac a = if a ∈ s then f a else 0 :=
  by
  rw [restrict_dirac' hs]
  swap; · infer_instance
  split_ifs
  · exact integral_dirac' _ _ hf
  · exact integral_zero_measure _
#align measure_theory.set_integral_dirac' MeasureTheory.set_integral_dirac'
-/

#print MeasureTheory.set_integral_dirac /-
theorem set_integral_dirac [MeasurableSpace α] [MeasurableSingletonClass α] (f : α → E) (a : α)
    (s : Set α) [Decidable (a ∈ s)] : ∫ x in s, f x ∂Measure.dirac a = if a ∈ s then f a else 0 :=
  by
  rw [restrict_dirac]
  split_ifs
  · exact integral_dirac _ _
  · exact integral_zero_measure _
#align measure_theory.set_integral_dirac MeasureTheory.set_integral_dirac
-/

#print MeasureTheory.mul_meas_ge_le_integral_of_nonneg /-
theorem mul_meas_ge_le_integral_of_nonneg [IsFiniteMeasure μ] {f : α → ℝ} (hf_nonneg : 0 ≤ f)
    (hf_int : Integrable f μ) (ε : ℝ) : ε * (μ {x | ε ≤ f x}).toReal ≤ ∫ x, f x ∂μ :=
  by
  cases' lt_or_le ε 0 with hε hε
  ·
    exact
      (mul_nonpos_of_nonpos_of_nonneg hε.le ENNReal.toReal_nonneg).trans (integral_nonneg hf_nonneg)
  rw [integral_eq_lintegral_of_nonneg_ae (eventually_of_forall fun x => hf_nonneg x)
      hf_int.ae_strongly_measurable,
    ← ENNReal.toReal_ofReal hε, ← ENNReal.toReal_mul]
  have :
    {x : α | (ENNReal.ofReal ε).toReal ≤ f x} =
      {x : α | ENNReal.ofReal ε ≤ (fun x => ENNReal.ofReal (f x)) x} :=
    by
    ext1 x
    rw [Set.mem_setOf_eq, Set.mem_setOf_eq, ← ENNReal.toReal_ofReal (hf_nonneg x)]
    exact ENNReal.toReal_le_toReal ENNReal.ofReal_ne_top ENNReal.ofReal_ne_top
  rw [this]
  have h_meas : AEMeasurable (fun x => ENNReal.ofReal (f x)) μ :=
    measurable_id'.ennreal_of_real.comp_ae_measurable hf_int.ae_measurable
  have h_mul_meas_le := @mul_meas_ge_le_lintegral₀ _ _ μ _ h_meas (ENNReal.ofReal ε)
  rw [ENNReal.toReal_le_toReal _ _]
  · exact h_mul_meas_le
  · simp only [Ne.def, WithTop.mul_eq_top_iff, ENNReal.ofReal_eq_zero, not_le,
      ENNReal.ofReal_ne_top, false_and_iff, or_false_iff, not_and]
    exact fun _ => measure_ne_top _ _
  · have h_lt_top : ∫⁻ a, ‖f a‖₊ ∂μ < ∞ := hf_int.has_finite_integral
    simp_rw [← ofReal_norm_eq_coe_nnnorm, Real.norm_eq_abs] at h_lt_top 
    convert h_lt_top.ne
    ext1 x
    rw [abs_of_nonneg (hf_nonneg x)]
#align measure_theory.mul_meas_ge_le_integral_of_nonneg MeasureTheory.mul_meas_ge_le_integral_of_nonneg
-/

#print MeasureTheory.integral_mul_norm_le_Lp_mul_Lq /-
/-- Hölder's inequality for the integral of a product of norms. The integral of the product of two
norms of functions is bounded by the product of their `ℒp` and `ℒq` seminorms when `p` and `q` are
conjugate exponents. -/
theorem integral_mul_norm_le_Lp_mul_Lq {E} [NormedAddCommGroup E] {f g : α → E} {p q : ℝ}
    (hpq : p.IsConjugateExponent q) (hf : Memℒp f (ENNReal.ofReal p) μ)
    (hg : Memℒp g (ENNReal.ofReal q) μ) :
    ∫ a, ‖f a‖ * ‖g a‖ ∂μ ≤ (∫ a, ‖f a‖ ^ p ∂μ) ^ (1 / p) * (∫ a, ‖g a‖ ^ q ∂μ) ^ (1 / q) :=
  by
  -- translate the Bochner integrals into Lebesgue integrals.
  rw [integral_eq_lintegral_of_nonneg_ae, integral_eq_lintegral_of_nonneg_ae,
    integral_eq_lintegral_of_nonneg_ae]
  rotate_left
  · exact eventually_of_forall fun x => Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
  · exact (hg.1.norm.AEMeasurable.pow aemeasurable_const).AEStronglyMeasurable
  · exact eventually_of_forall fun x => Real.rpow_nonneg_of_nonneg (norm_nonneg _) _
  · exact (hf.1.norm.AEMeasurable.pow aemeasurable_const).AEStronglyMeasurable
  · exact eventually_of_forall fun x => mul_nonneg (norm_nonneg _) (norm_nonneg _)
  · exact hf.1.norm.mul hg.1.norm
  rw [ENNReal.toReal_rpow, ENNReal.toReal_rpow, ← ENNReal.toReal_mul]
  -- replace norms by nnnorm
  have h_left :
    ∫⁻ a, ENNReal.ofReal (‖f a‖ * ‖g a‖) ∂μ =
      ∫⁻ a, ((fun x => (‖f x‖₊ : ℝ≥0∞)) * fun x => ‖g x‖₊) a ∂μ :=
    by simp_rw [Pi.mul_apply, ← ofReal_norm_eq_coe_nnnorm, ENNReal.ofReal_mul (norm_nonneg _)]
  have h_right_f : ∫⁻ a, ENNReal.ofReal (‖f a‖ ^ p) ∂μ = ∫⁻ a, ‖f a‖₊ ^ p ∂μ :=
    by
    refine' lintegral_congr fun x => _
    rw [← ofReal_norm_eq_coe_nnnorm, ENNReal.ofReal_rpow_of_nonneg (norm_nonneg _) hpq.nonneg]
  have h_right_g : ∫⁻ a, ENNReal.ofReal (‖g a‖ ^ q) ∂μ = ∫⁻ a, ‖g a‖₊ ^ q ∂μ :=
    by
    refine' lintegral_congr fun x => _
    rw [← ofReal_norm_eq_coe_nnnorm, ENNReal.ofReal_rpow_of_nonneg (norm_nonneg _) hpq.symm.nonneg]
  rw [h_left, h_right_f, h_right_g]
  -- we can now apply `ennreal.lintegral_mul_le_Lp_mul_Lq` (up to the `to_real` application)
  refine' ENNReal.toReal_mono _ _
  · refine' ENNReal.mul_ne_top _ _
    · convert hf.snorm_ne_top
      rw [snorm_eq_lintegral_rpow_nnnorm]
      · rw [ENNReal.toReal_ofReal hpq.nonneg]
      · rw [Ne.def, ENNReal.ofReal_eq_zero, not_le]
        exact hpq.pos
      · exact ENNReal.coe_ne_top
    · convert hg.snorm_ne_top
      rw [snorm_eq_lintegral_rpow_nnnorm]
      · rw [ENNReal.toReal_ofReal hpq.symm.nonneg]
      · rw [Ne.def, ENNReal.ofReal_eq_zero, not_le]
        exact hpq.symm.pos
      · exact ENNReal.coe_ne_top
  ·
    exact
      ENNReal.lintegral_mul_le_Lp_mul_Lq μ hpq hf.1.nnnorm.AEMeasurable.coe_nnreal_ennreal
        hg.1.nnnorm.AEMeasurable.coe_nnreal_ennreal
#align measure_theory.integral_mul_norm_le_Lp_mul_Lq MeasureTheory.integral_mul_norm_le_Lp_mul_Lq
-/

#print MeasureTheory.integral_mul_le_Lp_mul_Lq_of_nonneg /-
/-- Hölder's inequality for functions `α → ℝ`. The integral of the product of two nonnegative
functions is bounded by the product of their `ℒp` and `ℒq` seminorms when `p` and `q` are conjugate
exponents. -/
theorem integral_mul_le_Lp_mul_Lq_of_nonneg {p q : ℝ} (hpq : p.IsConjugateExponent q) {f g : α → ℝ}
    (hf_nonneg : 0 ≤ᵐ[μ] f) (hg_nonneg : 0 ≤ᵐ[μ] g) (hf : Memℒp f (ENNReal.ofReal p) μ)
    (hg : Memℒp g (ENNReal.ofReal q) μ) :
    ∫ a, f a * g a ∂μ ≤ (∫ a, f a ^ p ∂μ) ^ (1 / p) * (∫ a, g a ^ q ∂μ) ^ (1 / q) :=
  by
  have h_left : ∫ a, f a * g a ∂μ = ∫ a, ‖f a‖ * ‖g a‖ ∂μ :=
    by
    refine' integral_congr_ae _
    filter_upwards [hf_nonneg, hg_nonneg] with x hxf hxg
    rw [Real.norm_of_nonneg hxf, Real.norm_of_nonneg hxg]
  have h_right_f : ∫ a, f a ^ p ∂μ = ∫ a, ‖f a‖ ^ p ∂μ :=
    by
    refine' integral_congr_ae _
    filter_upwards [hf_nonneg] with x hxf
    rw [Real.norm_of_nonneg hxf]
  have h_right_g : ∫ a, g a ^ q ∂μ = ∫ a, ‖g a‖ ^ q ∂μ :=
    by
    refine' integral_congr_ae _
    filter_upwards [hg_nonneg] with x hxg
    rw [Real.norm_of_nonneg hxg]
  rw [h_left, h_right_f, h_right_g]
  exact integral_mul_norm_le_Lp_mul_Lq hpq hf hg
#align measure_theory.integral_mul_le_Lp_mul_Lq_of_nonneg MeasureTheory.integral_mul_le_Lp_mul_Lq_of_nonneg
-/

end Properties

-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
/-- Simp set for integral rules. -/ register_simp_attr integral_simps

attribute [integral_simps] integral_neg integral_smul L1.integral_add L1.integral_sub
  L1.integral_smul L1.integral_neg

section IntegralTrim

variable {H β γ : Type _} [NormedAddCommGroup H] {m m0 : MeasurableSpace β} {μ : Measure β}

#print MeasureTheory.SimpleFunc.toLargerSpace /-
/-- Simple function seen as simple function of a larger `measurable_space`. -/
def SimpleFunc.toLargerSpace (hm : m ≤ m0) (f : @SimpleFunc β m γ) : SimpleFunc β γ :=
  ⟨@SimpleFunc.toFun β m γ f, fun x => hm _ (@SimpleFunc.measurableSet_fiber β γ m f x),
    @SimpleFunc.finite_range β γ m f⟩
#align measure_theory.simple_func.to_larger_space MeasureTheory.SimpleFunc.toLargerSpace
-/

#print MeasureTheory.SimpleFunc.coe_toLargerSpace_eq /-
theorem SimpleFunc.coe_toLargerSpace_eq (hm : m ≤ m0) (f : @SimpleFunc β m γ) :
    ⇑(f.toLargerSpace hm) = f :=
  rfl
#align measure_theory.simple_func.coe_to_larger_space_eq MeasureTheory.SimpleFunc.coe_toLargerSpace_eq
-/

#print MeasureTheory.integral_simpleFunc_larger_space /-
theorem integral_simpleFunc_larger_space (hm : m ≤ m0) (f : @SimpleFunc β m F)
    (hf_int : Integrable f μ) :
    ∫ x, f x ∂μ = ∑ x in @SimpleFunc.range β F m f, ENNReal.toReal (μ (f ⁻¹' {x})) • x :=
  by
  simp_rw [← f.coe_to_larger_space_eq hm]
  have hf_int : integrable (f.to_larger_space hm) μ := by rwa [simple_func.coe_to_larger_space_eq]
  rw [simple_func.integral_eq_sum _ hf_int]
  congr
#align measure_theory.integral_simple_func_larger_space MeasureTheory.integral_simpleFunc_larger_space
-/

#print MeasureTheory.integral_trim_simpleFunc /-
theorem integral_trim_simpleFunc (hm : m ≤ m0) (f : @SimpleFunc β m F) (hf_int : Integrable f μ) :
    ∫ x, f x ∂μ = ∫ x, f x ∂μ.trim hm :=
  by
  have hf : strongly_measurable[m] f := @simple_func.strongly_measurable β F m _ f
  have hf_int_m := hf_int.trim hm hf
  rw [integral_simple_func_larger_space (le_refl m) f hf_int_m,
    integral_simple_func_larger_space hm f hf_int]
  congr with x
  congr
  exact (trim_measurable_set_eq hm (@simple_func.measurable_set_fiber β F m f x)).symm
#align measure_theory.integral_trim_simple_func MeasureTheory.integral_trim_simpleFunc
-/

#print MeasureTheory.integral_trim /-
theorem integral_trim (hm : m ≤ m0) {f : β → F} (hf : strongly_measurable[m] f) :
    ∫ x, f x ∂μ = ∫ x, f x ∂μ.trim hm := by
  borelize F
  by_cases hf_int : integrable f μ
  swap
  · have hf_int_m : ¬integrable f (μ.trim hm) := fun hf_int_m =>
      hf_int (integrable_of_integrable_trim hm hf_int_m)
    rw [integral_undef hf_int, integral_undef hf_int_m]
  haveI : separable_space (range f ∪ {0} : Set F) := hf.separable_space_range_union_singleton
  let f_seq := @simple_func.approx_on F β _ _ _ m _ hf.measurable (range f ∪ {0}) 0 (by simp) _
  have hf_seq_meas : ∀ n, strongly_measurable[m] (f_seq n) := fun n =>
    @simple_func.strongly_measurable β F m _ (f_seq n)
  have hf_seq_int : ∀ n, integrable (f_seq n) μ :=
    simple_func.integrable_approx_on_range (hf.mono hm).Measurable hf_int
  have hf_seq_int_m : ∀ n, integrable (f_seq n) (μ.trim hm) := fun n =>
    (hf_seq_int n).trim hm (hf_seq_meas n)
  have hf_seq_eq : ∀ n, ∫ x, f_seq n x ∂μ = ∫ x, f_seq n x ∂μ.trim hm := fun n =>
    integral_trim_simple_func hm (f_seq n) (hf_seq_int n)
  have h_lim_1 : at_top.tendsto (fun n => ∫ x, f_seq n x ∂μ) (𝓝 (∫ x, f x ∂μ)) :=
    by
    refine' tendsto_integral_of_L1 f hf_int (eventually_of_forall hf_seq_int) _
    exact simple_func.tendsto_approx_on_range_L1_nnnorm (hf.mono hm).Measurable hf_int
  have h_lim_2 : at_top.tendsto (fun n => ∫ x, f_seq n x ∂μ) (𝓝 (∫ x, f x ∂μ.trim hm)) :=
    by
    simp_rw [hf_seq_eq]
    refine'
      @tendsto_integral_of_L1 β F _ _ _ m (μ.trim hm) _ f (hf_int.trim hm hf) _ _
        (eventually_of_forall hf_seq_int_m) _
    exact
      @simple_func.tendsto_approx_on_range_L1_nnnorm β F m _ _ _ f _ _ hf.measurable
        (hf_int.trim hm hf)
  exact tendsto_nhds_unique h_lim_1 h_lim_2
#align measure_theory.integral_trim MeasureTheory.integral_trim
-/

#print MeasureTheory.integral_trim_ae /-
theorem integral_trim_ae (hm : m ≤ m0) {f : β → F} (hf : AEStronglyMeasurable f (μ.trim hm)) :
    ∫ x, f x ∂μ = ∫ x, f x ∂μ.trim hm :=
  by
  rw [integral_congr_ae (ae_eq_of_ae_eq_trim hf.ae_eq_mk), integral_congr_ae hf.ae_eq_mk]
  exact integral_trim hm hf.strongly_measurable_mk
#align measure_theory.integral_trim_ae MeasureTheory.integral_trim_ae
-/

#print MeasureTheory.ae_eq_trim_of_stronglyMeasurable /-
theorem ae_eq_trim_of_stronglyMeasurable [TopologicalSpace γ] [MetrizableSpace γ] (hm : m ≤ m0)
    {f g : β → γ} (hf : strongly_measurable[m] f) (hg : strongly_measurable[m] g)
    (hfg : f =ᵐ[μ] g) : f =ᵐ[μ.trim hm] g :=
  by
  rwa [eventually_eq, ae_iff, trim_measurable_set_eq hm _]
  exact (hf.measurable_set_eq_fun hg).compl
#align measure_theory.ae_eq_trim_of_strongly_measurable MeasureTheory.ae_eq_trim_of_stronglyMeasurable
-/

#print MeasureTheory.ae_eq_trim_iff /-
theorem ae_eq_trim_iff [TopologicalSpace γ] [MetrizableSpace γ] (hm : m ≤ m0) {f g : β → γ}
    (hf : strongly_measurable[m] f) (hg : strongly_measurable[m] g) :
    f =ᵐ[μ.trim hm] g ↔ f =ᵐ[μ] g :=
  ⟨ae_eq_of_ae_eq_trim, ae_eq_trim_of_stronglyMeasurable hm hf hg⟩
#align measure_theory.ae_eq_trim_iff MeasureTheory.ae_eq_trim_iff
-/

#print MeasureTheory.ae_le_trim_of_stronglyMeasurable /-
theorem ae_le_trim_of_stronglyMeasurable [LinearOrder γ] [TopologicalSpace γ]
    [OrderClosedTopology γ] [PseudoMetrizableSpace γ] (hm : m ≤ m0) {f g : β → γ}
    (hf : strongly_measurable[m] f) (hg : strongly_measurable[m] g) (hfg : f ≤ᵐ[μ] g) :
    f ≤ᵐ[μ.trim hm] g :=
  by
  rwa [eventually_le, ae_iff, trim_measurable_set_eq hm _]
  exact (hf.measurable_set_le hg).compl
#align measure_theory.ae_le_trim_of_strongly_measurable MeasureTheory.ae_le_trim_of_stronglyMeasurable
-/

#print MeasureTheory.ae_le_trim_iff /-
theorem ae_le_trim_iff [LinearOrder γ] [TopologicalSpace γ] [OrderClosedTopology γ]
    [PseudoMetrizableSpace γ] (hm : m ≤ m0) {f g : β → γ} (hf : strongly_measurable[m] f)
    (hg : strongly_measurable[m] g) : f ≤ᵐ[μ.trim hm] g ↔ f ≤ᵐ[μ] g :=
  ⟨ae_le_of_ae_le_trim, ae_le_trim_of_stronglyMeasurable hm hf hg⟩
#align measure_theory.ae_le_trim_iff MeasureTheory.ae_le_trim_iff
-/

end IntegralTrim

section SnormBound

variable {m0 : MeasurableSpace α} {μ : Measure α}

#print MeasureTheory.snorm_one_le_of_le /-
theorem snorm_one_le_of_le {r : ℝ≥0} {f : α → ℝ} (hfint : Integrable f μ) (hfint' : 0 ≤ ∫ x, f x ∂μ)
    (hf : ∀ᵐ ω ∂μ, f ω ≤ r) : snorm f 1 μ ≤ 2 * μ Set.univ * r :=
  by
  by_cases hr : r = 0
  · suffices f =ᵐ[μ] 0
      by
      rw [snorm_congr_ae this, snorm_zero, hr, ENNReal.coe_zero, MulZeroClass.mul_zero]
      exact le_rfl
    rw [hr, Nonneg.coe_zero] at hf 
    have hnegf : ∫ x, -f x ∂μ = 0 :=
      by
      rw [integral_neg, neg_eq_zero]
      exact le_antisymm (integral_nonpos_of_ae hf) hfint'
    have := (integral_eq_zero_iff_of_nonneg_ae _ hfint.neg).1 hnegf
    · filter_upwards [this] with ω hω
      rwa [Pi.neg_apply, Pi.zero_apply, neg_eq_zero] at hω 
    · filter_upwards [hf] with ω hω
      rwa [Pi.zero_apply, Pi.neg_apply, Right.nonneg_neg_iff]
  by_cases hμ : is_finite_measure μ
  swap
  · have : μ Set.univ = ∞ := by
      by_contra hμ'
      exact hμ (is_finite_measure.mk <| lt_top_iff_ne_top.2 hμ')
    rw [this, ENNReal.mul_top', if_neg, ENNReal.top_mul', if_neg]
    · exact le_top
    · simp [hr]
    · norm_num
  haveI := hμ
  rw [integral_eq_integral_pos_part_sub_integral_neg_part hfint, sub_nonneg] at hfint' 
  have hposbdd : ∫ ω, max (f ω) 0 ∂μ ≤ (μ Set.univ).toReal • r :=
    by
    rw [← integral_const]
    refine' integral_mono_ae hfint.real_to_nnreal (integrable_const r) _
    filter_upwards [hf] with ω hω using Real.toNNReal_le_iff_le_coe.2 hω
  rw [mem_ℒp.snorm_eq_integral_rpow_norm one_ne_zero ENNReal.one_ne_top
      (mem_ℒp_one_iff_integrable.2 hfint),
    ENNReal.ofReal_le_iff_le_toReal
      (ENNReal.mul_ne_top (ENNReal.mul_ne_top ENNReal.two_ne_top <| @measure_ne_top _ _ _ hμ _)
        ENNReal.coe_ne_top)]
  simp_rw [ENNReal.one_toReal, _root_.inv_one, Real.rpow_one, Real.norm_eq_abs, ←
    max_zero_add_max_neg_zero_eq_abs_self, ← Real.coe_toNNReal']
  rw [integral_add hfint.real_to_nnreal]
  · simp only [Real.coe_toNNReal', ENNReal.toReal_mul, ENNReal.toReal_bit0, ENNReal.one_toReal,
      ENNReal.coe_toReal] at hfint' ⊢
    refine' (add_le_add_left hfint' _).trans _
    rwa [← two_mul, mul_assoc, mul_le_mul_left (two_pos : (0 : ℝ) < 2)]
  · exact hfint.neg.sup (integrable_zero _ _ μ)
#align measure_theory.snorm_one_le_of_le MeasureTheory.snorm_one_le_of_le
-/

#print MeasureTheory.snorm_one_le_of_le' /-
theorem snorm_one_le_of_le' {r : ℝ} {f : α → ℝ} (hfint : Integrable f μ) (hfint' : 0 ≤ ∫ x, f x ∂μ)
    (hf : ∀ᵐ ω ∂μ, f ω ≤ r) : snorm f 1 μ ≤ 2 * μ Set.univ * ENNReal.ofReal r :=
  by
  refine' snorm_one_le_of_le hfint hfint' _
  simp only [Real.coe_toNNReal', le_max_iff]
  filter_upwards [hf] with ω hω using Or.inl hω
#align measure_theory.snorm_one_le_of_le' MeasureTheory.snorm_one_le_of_le'
-/

end SnormBound

end MeasureTheory

