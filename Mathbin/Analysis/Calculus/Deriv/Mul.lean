/-
Copyright (c) 2019 Gabriel Ebner. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Anatole Dedecker, Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.deriv.mul
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Deriv.Basic
import Mathbin.Analysis.Calculus.Fderiv.Mul
import Mathbin.Analysis.Calculus.Fderiv.Add

/-!
# Derivative of `f x * g x`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove formulas for `(f x * g x)'` and `(f x • g x)'`.

For a more detailed overview of one-dimensional derivatives in mathlib, see the module docstring of
`analysis/calculus/deriv/basic`.

## Keywords

derivative, multiplication
-/


universe u v w

noncomputable section

open scoped Classical Topology BigOperators Filter ENNReal

open Filter Asymptotics Set

open ContinuousLinearMap (smul_right smulRight_one_eq_iff)

variable {𝕜 : Type u} [NontriviallyNormedField 𝕜]

variable {F : Type v} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable {E : Type w} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {f f₀ f₁ g : 𝕜 → F}

variable {f' f₀' f₁' g' : F}

variable {x : 𝕜}

variable {s t : Set 𝕜}

variable {L L₁ L₂ : Filter 𝕜}

section Smul

/-! ### Derivative of the multiplication of a scalar function and a vector function -/


variable {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] [NormedSpace 𝕜' F]
  [IsScalarTower 𝕜 𝕜' F] {c : 𝕜 → 𝕜'} {c' : 𝕜'}

#print HasDerivWithinAt.smul /-
theorem HasDerivWithinAt.smul (hc : HasDerivWithinAt c c' s x) (hf : HasDerivWithinAt f f' s x) :
    HasDerivWithinAt (fun y => c y • f y) (c x • f' + c' • f x) s x := by
  simpa using (HasFDerivWithinAt.smul hc hf).HasDerivWithinAt
#align has_deriv_within_at.smul HasDerivWithinAt.smul
-/

#print HasDerivAt.smul /-
theorem HasDerivAt.smul (hc : HasDerivAt c c' x) (hf : HasDerivAt f f' x) :
    HasDerivAt (fun y => c y • f y) (c x • f' + c' • f x) x :=
  by
  rw [← hasDerivWithinAt_univ] at *
  exact hc.smul hf
#align has_deriv_at.smul HasDerivAt.smul
-/

#print HasStrictDerivAt.smul /-
theorem HasStrictDerivAt.smul (hc : HasStrictDerivAt c c' x) (hf : HasStrictDerivAt f f' x) :
    HasStrictDerivAt (fun y => c y • f y) (c x • f' + c' • f x) x := by
  simpa using (hc.smul hf).HasStrictDerivAt
#align has_strict_deriv_at.smul HasStrictDerivAt.smul
-/

#print derivWithin_smul /-
theorem derivWithin_smul (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
    (hf : DifferentiableWithinAt 𝕜 f s x) :
    derivWithin (fun y => c y • f y) s x = c x • derivWithin f s x + derivWithin c s x • f x :=
  (hc.HasDerivWithinAt.smul hf.HasDerivWithinAt).derivWithin hxs
#align deriv_within_smul derivWithin_smul
-/

#print deriv_smul /-
theorem deriv_smul (hc : DifferentiableAt 𝕜 c x) (hf : DifferentiableAt 𝕜 f x) :
    deriv (fun y => c y • f y) x = c x • deriv f x + deriv c x • f x :=
  (hc.HasDerivAt.smul hf.HasDerivAt).deriv
#align deriv_smul deriv_smul
-/

#print HasStrictDerivAt.smul_const /-
theorem HasStrictDerivAt.smul_const (hc : HasStrictDerivAt c c' x) (f : F) :
    HasStrictDerivAt (fun y => c y • f) (c' • f) x :=
  by
  have := hc.smul (hasStrictDerivAt_const x f)
  rwa [smul_zero, zero_add] at this 
#align has_strict_deriv_at.smul_const HasStrictDerivAt.smul_const
-/

#print HasDerivWithinAt.smul_const /-
theorem HasDerivWithinAt.smul_const (hc : HasDerivWithinAt c c' s x) (f : F) :
    HasDerivWithinAt (fun y => c y • f) (c' • f) s x :=
  by
  have := hc.smul (hasDerivWithinAt_const x s f)
  rwa [smul_zero, zero_add] at this 
#align has_deriv_within_at.smul_const HasDerivWithinAt.smul_const
-/

#print HasDerivAt.smul_const /-
theorem HasDerivAt.smul_const (hc : HasDerivAt c c' x) (f : F) :
    HasDerivAt (fun y => c y • f) (c' • f) x :=
  by
  rw [← hasDerivWithinAt_univ] at *
  exact hc.smul_const f
#align has_deriv_at.smul_const HasDerivAt.smul_const
-/

#print derivWithin_smul_const /-
theorem derivWithin_smul_const (hxs : UniqueDiffWithinAt 𝕜 s x)
    (hc : DifferentiableWithinAt 𝕜 c s x) (f : F) :
    derivWithin (fun y => c y • f) s x = derivWithin c s x • f :=
  (hc.HasDerivWithinAt.smul_const f).derivWithin hxs
#align deriv_within_smul_const derivWithin_smul_const
-/

#print deriv_smul_const /-
theorem deriv_smul_const (hc : DifferentiableAt 𝕜 c x) (f : F) :
    deriv (fun y => c y • f) x = deriv c x • f :=
  (hc.HasDerivAt.smul_const f).deriv
#align deriv_smul_const deriv_smul_const
-/

end Smul

section ConstSmul

variable {R : Type _} [Semiring R] [Module R F] [SMulCommClass 𝕜 R F] [ContinuousConstSMul R F]

#print HasStrictDerivAt.const_smul /-
theorem HasStrictDerivAt.const_smul (c : R) (hf : HasStrictDerivAt f f' x) :
    HasStrictDerivAt (fun y => c • f y) (c • f') x := by
  simpa using (hf.const_smul c).HasStrictDerivAt
#align has_strict_deriv_at.const_smul HasStrictDerivAt.const_smul
-/

#print HasDerivAtFilter.const_smul /-
theorem HasDerivAtFilter.const_smul (c : R) (hf : HasDerivAtFilter f f' x L) :
    HasDerivAtFilter (fun y => c • f y) (c • f') x L := by
  simpa using (hf.const_smul c).HasDerivAtFilter
#align has_deriv_at_filter.const_smul HasDerivAtFilter.const_smul
-/

#print HasDerivWithinAt.const_smul /-
theorem HasDerivWithinAt.const_smul (c : R) (hf : HasDerivWithinAt f f' s x) :
    HasDerivWithinAt (fun y => c • f y) (c • f') s x :=
  hf.const_smul c
#align has_deriv_within_at.const_smul HasDerivWithinAt.const_smul
-/

#print HasDerivAt.const_smul /-
theorem HasDerivAt.const_smul (c : R) (hf : HasDerivAt f f' x) :
    HasDerivAt (fun y => c • f y) (c • f') x :=
  hf.const_smul c
#align has_deriv_at.const_smul HasDerivAt.const_smul
-/

#print derivWithin_const_smul /-
theorem derivWithin_const_smul (hxs : UniqueDiffWithinAt 𝕜 s x) (c : R)
    (hf : DifferentiableWithinAt 𝕜 f s x) :
    derivWithin (fun y => c • f y) s x = c • derivWithin f s x :=
  (hf.HasDerivWithinAt.const_smul c).derivWithin hxs
#align deriv_within_const_smul derivWithin_const_smul
-/

#print deriv_const_smul /-
theorem deriv_const_smul (c : R) (hf : DifferentiableAt 𝕜 f x) :
    deriv (fun y => c • f y) x = c • deriv f x :=
  (hf.HasDerivAt.const_smul c).deriv
#align deriv_const_smul deriv_const_smul
-/

end ConstSmul

section Mul

/-! ### Derivative of the multiplication of two functions -/


variable {𝕜' 𝔸 : Type _} [NormedField 𝕜'] [NormedRing 𝔸] [NormedAlgebra 𝕜 𝕜'] [NormedAlgebra 𝕜 𝔸]
  {c d : 𝕜 → 𝔸} {c' d' : 𝔸} {u v : 𝕜 → 𝕜'}

#print HasDerivWithinAt.mul /-
theorem HasDerivWithinAt.mul (hc : HasDerivWithinAt c c' s x) (hd : HasDerivWithinAt d d' s x) :
    HasDerivWithinAt (fun y => c y * d y) (c' * d x + c x * d') s x :=
  by
  have := (HasFDerivWithinAt.mul' hc hd).HasDerivWithinAt
  rwa [ContinuousLinearMap.add_apply, ContinuousLinearMap.smul_apply,
    ContinuousLinearMap.smulRight_apply, ContinuousLinearMap.smulRight_apply,
    ContinuousLinearMap.smulRight_apply, ContinuousLinearMap.one_apply, one_smul, one_smul,
    add_comm] at this 
#align has_deriv_within_at.mul HasDerivWithinAt.mul
-/

#print HasDerivAt.mul /-
theorem HasDerivAt.mul (hc : HasDerivAt c c' x) (hd : HasDerivAt d d' x) :
    HasDerivAt (fun y => c y * d y) (c' * d x + c x * d') x :=
  by
  rw [← hasDerivWithinAt_univ] at *
  exact hc.mul hd
#align has_deriv_at.mul HasDerivAt.mul
-/

#print HasStrictDerivAt.mul /-
theorem HasStrictDerivAt.mul (hc : HasStrictDerivAt c c' x) (hd : HasStrictDerivAt d d' x) :
    HasStrictDerivAt (fun y => c y * d y) (c' * d x + c x * d') x :=
  by
  have := (HasStrictFDerivAt.mul' hc hd).HasStrictDerivAt
  rwa [ContinuousLinearMap.add_apply, ContinuousLinearMap.smul_apply,
    ContinuousLinearMap.smulRight_apply, ContinuousLinearMap.smulRight_apply,
    ContinuousLinearMap.smulRight_apply, ContinuousLinearMap.one_apply, one_smul, one_smul,
    add_comm] at this 
#align has_strict_deriv_at.mul HasStrictDerivAt.mul
-/

#print derivWithin_mul /-
theorem derivWithin_mul (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
    (hd : DifferentiableWithinAt 𝕜 d s x) :
    derivWithin (fun y => c y * d y) s x = derivWithin c s x * d x + c x * derivWithin d s x :=
  (hc.HasDerivWithinAt.mul hd.HasDerivWithinAt).derivWithin hxs
#align deriv_within_mul derivWithin_mul
-/

#print deriv_mul /-
@[simp]
theorem deriv_mul (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) :
    deriv (fun y => c y * d y) x = deriv c x * d x + c x * deriv d x :=
  (hc.HasDerivAt.mul hd.HasDerivAt).deriv
#align deriv_mul deriv_mul
-/

#print HasDerivWithinAt.mul_const /-
theorem HasDerivWithinAt.mul_const (hc : HasDerivWithinAt c c' s x) (d : 𝔸) :
    HasDerivWithinAt (fun y => c y * d) (c' * d) s x :=
  by
  convert hc.mul (hasDerivWithinAt_const x s d)
  rw [MulZeroClass.mul_zero, add_zero]
#align has_deriv_within_at.mul_const HasDerivWithinAt.mul_const
-/

#print HasDerivAt.mul_const /-
theorem HasDerivAt.mul_const (hc : HasDerivAt c c' x) (d : 𝔸) :
    HasDerivAt (fun y => c y * d) (c' * d) x :=
  by
  rw [← hasDerivWithinAt_univ] at *
  exact hc.mul_const d
#align has_deriv_at.mul_const HasDerivAt.mul_const
-/

#print hasDerivAt_mul_const /-
theorem hasDerivAt_mul_const (c : 𝕜) : HasDerivAt (fun x => x * c) c x := by
  simpa only [one_mul] using (hasDerivAt_id' x).mul_const c
#align has_deriv_at_mul_const hasDerivAt_mul_const
-/

#print HasStrictDerivAt.mul_const /-
theorem HasStrictDerivAt.mul_const (hc : HasStrictDerivAt c c' x) (d : 𝔸) :
    HasStrictDerivAt (fun y => c y * d) (c' * d) x :=
  by
  convert hc.mul (hasStrictDerivAt_const x d)
  rw [MulZeroClass.mul_zero, add_zero]
#align has_strict_deriv_at.mul_const HasStrictDerivAt.mul_const
-/

#print derivWithin_mul_const /-
theorem derivWithin_mul_const (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
    (d : 𝔸) : derivWithin (fun y => c y * d) s x = derivWithin c s x * d :=
  (hc.HasDerivWithinAt.mul_const d).derivWithin hxs
#align deriv_within_mul_const derivWithin_mul_const
-/

#print deriv_mul_const /-
theorem deriv_mul_const (hc : DifferentiableAt 𝕜 c x) (d : 𝔸) :
    deriv (fun y => c y * d) x = deriv c x * d :=
  (hc.HasDerivAt.mul_const d).deriv
#align deriv_mul_const deriv_mul_const
-/

#print deriv_mul_const_field /-
theorem deriv_mul_const_field (v : 𝕜') : deriv (fun y => u y * v) x = deriv u x * v :=
  by
  by_cases hu : DifferentiableAt 𝕜 u x
  · exact deriv_mul_const hu v
  · rw [deriv_zero_of_not_differentiableAt hu, MulZeroClass.zero_mul]
    rcases eq_or_ne v 0 with (rfl | hd)
    · simp only [MulZeroClass.mul_zero, deriv_const]
    · refine' deriv_zero_of_not_differentiableAt (mt (fun H => _) hu)
      simpa only [mul_inv_cancel_right₀ hd] using H.mul_const v⁻¹
#align deriv_mul_const_field deriv_mul_const_field
-/

#print deriv_mul_const_field' /-
@[simp]
theorem deriv_mul_const_field' (v : 𝕜') : (deriv fun x => u x * v) = fun x => deriv u x * v :=
  funext fun _ => deriv_mul_const_field v
#align deriv_mul_const_field' deriv_mul_const_field'
-/

#print HasDerivWithinAt.const_mul /-
theorem HasDerivWithinAt.const_mul (c : 𝔸) (hd : HasDerivWithinAt d d' s x) :
    HasDerivWithinAt (fun y => c * d y) (c * d') s x :=
  by
  convert (hasDerivWithinAt_const x s c).mul hd
  rw [MulZeroClass.zero_mul, zero_add]
#align has_deriv_within_at.const_mul HasDerivWithinAt.const_mul
-/

#print HasDerivAt.const_mul /-
theorem HasDerivAt.const_mul (c : 𝔸) (hd : HasDerivAt d d' x) :
    HasDerivAt (fun y => c * d y) (c * d') x :=
  by
  rw [← hasDerivWithinAt_univ] at *
  exact hd.const_mul c
#align has_deriv_at.const_mul HasDerivAt.const_mul
-/

#print HasStrictDerivAt.const_mul /-
theorem HasStrictDerivAt.const_mul (c : 𝔸) (hd : HasStrictDerivAt d d' x) :
    HasStrictDerivAt (fun y => c * d y) (c * d') x :=
  by
  convert (hasStrictDerivAt_const _ _).mul hd
  rw [MulZeroClass.zero_mul, zero_add]
#align has_strict_deriv_at.const_mul HasStrictDerivAt.const_mul
-/

#print derivWithin_const_mul /-
theorem derivWithin_const_mul (hxs : UniqueDiffWithinAt 𝕜 s x) (c : 𝔸)
    (hd : DifferentiableWithinAt 𝕜 d s x) :
    derivWithin (fun y => c * d y) s x = c * derivWithin d s x :=
  (hd.HasDerivWithinAt.const_mul c).derivWithin hxs
#align deriv_within_const_mul derivWithin_const_mul
-/

#print deriv_const_mul /-
theorem deriv_const_mul (c : 𝔸) (hd : DifferentiableAt 𝕜 d x) :
    deriv (fun y => c * d y) x = c * deriv d x :=
  (hd.HasDerivAt.const_mul c).deriv
#align deriv_const_mul deriv_const_mul
-/

#print deriv_const_mul_field /-
theorem deriv_const_mul_field (u : 𝕜') : deriv (fun y => u * v y) x = u * deriv v x := by
  simp only [mul_comm u, deriv_mul_const_field]
#align deriv_const_mul_field deriv_const_mul_field
-/

#print deriv_const_mul_field' /-
@[simp]
theorem deriv_const_mul_field' (u : 𝕜') : (deriv fun x => u * v x) = fun x => u * deriv v x :=
  funext fun x => deriv_const_mul_field u
#align deriv_const_mul_field' deriv_const_mul_field'
-/

end Mul

section Div

variable {𝕜' : Type _} [NontriviallyNormedField 𝕜'] [NormedAlgebra 𝕜 𝕜'] {c d : 𝕜 → 𝕜'} {c' d' : 𝕜'}

#print HasDerivAt.div_const /-
theorem HasDerivAt.div_const (hc : HasDerivAt c c' x) (d : 𝕜') :
    HasDerivAt (fun x => c x / d) (c' / d) x := by
  simpa only [div_eq_mul_inv] using hc.mul_const d⁻¹
#align has_deriv_at.div_const HasDerivAt.div_const
-/

#print HasDerivWithinAt.div_const /-
theorem HasDerivWithinAt.div_const (hc : HasDerivWithinAt c c' s x) (d : 𝕜') :
    HasDerivWithinAt (fun x => c x / d) (c' / d) s x := by
  simpa only [div_eq_mul_inv] using hc.mul_const d⁻¹
#align has_deriv_within_at.div_const HasDerivWithinAt.div_const
-/

#print HasStrictDerivAt.div_const /-
theorem HasStrictDerivAt.div_const (hc : HasStrictDerivAt c c' x) (d : 𝕜') :
    HasStrictDerivAt (fun x => c x / d) (c' / d) x := by
  simpa only [div_eq_mul_inv] using hc.mul_const d⁻¹
#align has_strict_deriv_at.div_const HasStrictDerivAt.div_const
-/

#print DifferentiableWithinAt.div_const /-
theorem DifferentiableWithinAt.div_const (hc : DifferentiableWithinAt 𝕜 c s x) (d : 𝕜') :
    DifferentiableWithinAt 𝕜 (fun x => c x / d) s x :=
  (hc.HasDerivWithinAt.div_const _).DifferentiableWithinAt
#align differentiable_within_at.div_const DifferentiableWithinAt.div_const
-/

#print DifferentiableAt.div_const /-
@[simp]
theorem DifferentiableAt.div_const (hc : DifferentiableAt 𝕜 c x) (d : 𝕜') :
    DifferentiableAt 𝕜 (fun x => c x / d) x :=
  (hc.HasDerivAt.div_const _).DifferentiableAt
#align differentiable_at.div_const DifferentiableAt.div_const
-/

#print DifferentiableOn.div_const /-
theorem DifferentiableOn.div_const (hc : DifferentiableOn 𝕜 c s) (d : 𝕜') :
    DifferentiableOn 𝕜 (fun x => c x / d) s := fun x hx => (hc x hx).div_const d
#align differentiable_on.div_const DifferentiableOn.div_const
-/

#print Differentiable.div_const /-
@[simp]
theorem Differentiable.div_const (hc : Differentiable 𝕜 c) (d : 𝕜') :
    Differentiable 𝕜 fun x => c x / d := fun x => (hc x).div_const d
#align differentiable.div_const Differentiable.div_const
-/

#print derivWithin_div_const /-
theorem derivWithin_div_const (hc : DifferentiableWithinAt 𝕜 c s x) (d : 𝕜')
    (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin (fun x => c x / d) s x = derivWithin c s x / d :=
  by simp [div_eq_inv_mul, derivWithin_const_mul, hc, hxs]
#align deriv_within_div_const derivWithin_div_const
-/

#print deriv_div_const /-
@[simp]
theorem deriv_div_const (d : 𝕜') : deriv (fun x => c x / d) x = deriv c x / d := by
  simp only [div_eq_mul_inv, deriv_mul_const_field]
#align deriv_div_const deriv_div_const
-/

end Div

section ClmCompApply

/-! ### Derivative of the pointwise composition/application of continuous linear maps -/


open ContinuousLinearMap

variable {G : Type _} [NormedAddCommGroup G] [NormedSpace 𝕜 G] {c : 𝕜 → F →L[𝕜] G} {c' : F →L[𝕜] G}
  {d : 𝕜 → E →L[𝕜] F} {d' : E →L[𝕜] F} {u : 𝕜 → F} {u' : F}

#print HasStrictDerivAt.clm_comp /-
theorem HasStrictDerivAt.clm_comp (hc : HasStrictDerivAt c c' x) (hd : HasStrictDerivAt d d' x) :
    HasStrictDerivAt (fun y => (c y).comp (d y)) (c'.comp (d x) + (c x).comp d') x :=
  by
  have := (hc.has_strict_fderiv_at.clm_comp hd.has_strict_fderiv_at).HasStrictDerivAt
  rwa [add_apply, comp_apply, comp_apply, smul_right_apply, smul_right_apply, one_apply, one_smul,
    one_smul, add_comm] at this 
#align has_strict_deriv_at.clm_comp HasStrictDerivAt.clm_comp
-/

#print HasDerivWithinAt.clm_comp /-
theorem HasDerivWithinAt.clm_comp (hc : HasDerivWithinAt c c' s x)
    (hd : HasDerivWithinAt d d' s x) :
    HasDerivWithinAt (fun y => (c y).comp (d y)) (c'.comp (d x) + (c x).comp d') s x :=
  by
  have := (hc.has_fderiv_within_at.clm_comp hd.has_fderiv_within_at).HasDerivWithinAt
  rwa [add_apply, comp_apply, comp_apply, smul_right_apply, smul_right_apply, one_apply, one_smul,
    one_smul, add_comm] at this 
#align has_deriv_within_at.clm_comp HasDerivWithinAt.clm_comp
-/

#print HasDerivAt.clm_comp /-
theorem HasDerivAt.clm_comp (hc : HasDerivAt c c' x) (hd : HasDerivAt d d' x) :
    HasDerivAt (fun y => (c y).comp (d y)) (c'.comp (d x) + (c x).comp d') x :=
  by
  rw [← hasDerivWithinAt_univ] at *
  exact hc.clm_comp hd
#align has_deriv_at.clm_comp HasDerivAt.clm_comp
-/

#print derivWithin_clm_comp /-
theorem derivWithin_clm_comp (hc : DifferentiableWithinAt 𝕜 c s x)
    (hd : DifferentiableWithinAt 𝕜 d s x) (hxs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin (fun y => (c y).comp (d y)) s x =
      (derivWithin c s x).comp (d x) + (c x).comp (derivWithin d s x) :=
  (hc.HasDerivWithinAt.clm_comp hd.HasDerivWithinAt).derivWithin hxs
#align deriv_within_clm_comp derivWithin_clm_comp
-/

#print deriv_clm_comp /-
theorem deriv_clm_comp (hc : DifferentiableAt 𝕜 c x) (hd : DifferentiableAt 𝕜 d x) :
    deriv (fun y => (c y).comp (d y)) x = (deriv c x).comp (d x) + (c x).comp (deriv d x) :=
  (hc.HasDerivAt.clm_comp hd.HasDerivAt).deriv
#align deriv_clm_comp deriv_clm_comp
-/

#print HasStrictDerivAt.clm_apply /-
theorem HasStrictDerivAt.clm_apply (hc : HasStrictDerivAt c c' x) (hu : HasStrictDerivAt u u' x) :
    HasStrictDerivAt (fun y => (c y) (u y)) (c' (u x) + c x u') x :=
  by
  have := (hc.has_strict_fderiv_at.clm_apply hu.has_strict_fderiv_at).HasStrictDerivAt
  rwa [add_apply, comp_apply, flip_apply, smul_right_apply, smul_right_apply, one_apply, one_smul,
    one_smul, add_comm] at this 
#align has_strict_deriv_at.clm_apply HasStrictDerivAt.clm_apply
-/

#print HasDerivWithinAt.clm_apply /-
theorem HasDerivWithinAt.clm_apply (hc : HasDerivWithinAt c c' s x)
    (hu : HasDerivWithinAt u u' s x) :
    HasDerivWithinAt (fun y => (c y) (u y)) (c' (u x) + c x u') s x :=
  by
  have := (hc.has_fderiv_within_at.clm_apply hu.has_fderiv_within_at).HasDerivWithinAt
  rwa [add_apply, comp_apply, flip_apply, smul_right_apply, smul_right_apply, one_apply, one_smul,
    one_smul, add_comm] at this 
#align has_deriv_within_at.clm_apply HasDerivWithinAt.clm_apply
-/

#print HasDerivAt.clm_apply /-
theorem HasDerivAt.clm_apply (hc : HasDerivAt c c' x) (hu : HasDerivAt u u' x) :
    HasDerivAt (fun y => (c y) (u y)) (c' (u x) + c x u') x :=
  by
  have := (hc.has_fderiv_at.clm_apply hu.has_fderiv_at).HasDerivAt
  rwa [add_apply, comp_apply, flip_apply, smul_right_apply, smul_right_apply, one_apply, one_smul,
    one_smul, add_comm] at this 
#align has_deriv_at.clm_apply HasDerivAt.clm_apply
-/

#print derivWithin_clm_apply /-
theorem derivWithin_clm_apply (hxs : UniqueDiffWithinAt 𝕜 s x) (hc : DifferentiableWithinAt 𝕜 c s x)
    (hu : DifferentiableWithinAt 𝕜 u s x) :
    derivWithin (fun y => (c y) (u y)) s x = derivWithin c s x (u x) + c x (derivWithin u s x) :=
  (hc.HasDerivWithinAt.clm_apply hu.HasDerivWithinAt).derivWithin hxs
#align deriv_within_clm_apply derivWithin_clm_apply
-/

#print deriv_clm_apply /-
theorem deriv_clm_apply (hc : DifferentiableAt 𝕜 c x) (hu : DifferentiableAt 𝕜 u x) :
    deriv (fun y => (c y) (u y)) x = deriv c x (u x) + c x (deriv u x) :=
  (hc.HasDerivAt.clm_apply hu.HasDerivAt).deriv
#align deriv_clm_apply deriv_clm_apply
-/

end ClmCompApply

