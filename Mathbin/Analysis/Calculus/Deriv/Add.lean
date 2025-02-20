/-
Copyright (c) 2019 Gabriel Ebner All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Gabriel Ebner, Sébastien Gouëzel, Yury Kudryashov, Anatole Dedecker

! This file was ported from Lean 3 source module analysis.calculus.deriv.add
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Deriv.Basic
import Mathbin.Analysis.Calculus.Fderiv.Add

/-!
# One-dimensional derivatives of sums etc

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove formulas about derivatives of `f + g`, `-f`, `f - g`, and `∑ i, f i x` for
functions from the base field to a normed space over this field.

For a more detailed overview of one-dimensional derivatives in mathlib, see the module docstring of
`analysis/calculus/deriv/basic`.

## Keywords

derivative
-/


universe u v w

open scoped Classical Topology BigOperators Filter ENNReal

open Filter Asymptotics Set

variable {𝕜 : Type u} [NontriviallyNormedField 𝕜]

variable {F : Type v} [NormedAddCommGroup F] [NormedSpace 𝕜 F]

variable {E : Type w} [NormedAddCommGroup E] [NormedSpace 𝕜 E]

variable {f f₀ f₁ g : 𝕜 → F}

variable {f' f₀' f₁' g' : F}

variable {x : 𝕜}

variable {s t : Set 𝕜}

variable {L : Filter 𝕜}

section Add

/-! ### Derivative of the sum of two functions -/


#print HasDerivAtFilter.add /-
theorem HasDerivAtFilter.add (hf : HasDerivAtFilter f f' x L) (hg : HasDerivAtFilter g g' x L) :
    HasDerivAtFilter (fun y => f y + g y) (f' + g') x L := by
  simpa using (hf.add hg).HasDerivAtFilter
#align has_deriv_at_filter.add HasDerivAtFilter.add
-/

#print HasStrictDerivAt.add /-
theorem HasStrictDerivAt.add (hf : HasStrictDerivAt f f' x) (hg : HasStrictDerivAt g g' x) :
    HasStrictDerivAt (fun y => f y + g y) (f' + g') x := by simpa using (hf.add hg).HasStrictDerivAt
#align has_strict_deriv_at.add HasStrictDerivAt.add
-/

#print HasDerivWithinAt.add /-
theorem HasDerivWithinAt.add (hf : HasDerivWithinAt f f' s x) (hg : HasDerivWithinAt g g' s x) :
    HasDerivWithinAt (fun y => f y + g y) (f' + g') s x :=
  hf.add hg
#align has_deriv_within_at.add HasDerivWithinAt.add
-/

#print HasDerivAt.add /-
theorem HasDerivAt.add (hf : HasDerivAt f f' x) (hg : HasDerivAt g g' x) :
    HasDerivAt (fun x => f x + g x) (f' + g') x :=
  hf.add hg
#align has_deriv_at.add HasDerivAt.add
-/

#print derivWithin_add /-
theorem derivWithin_add (hxs : UniqueDiffWithinAt 𝕜 s x) (hf : DifferentiableWithinAt 𝕜 f s x)
    (hg : DifferentiableWithinAt 𝕜 g s x) :
    derivWithin (fun y => f y + g y) s x = derivWithin f s x + derivWithin g s x :=
  (hf.HasDerivWithinAt.add hg.HasDerivWithinAt).derivWithin hxs
#align deriv_within_add derivWithin_add
-/

#print deriv_add /-
@[simp]
theorem deriv_add (hf : DifferentiableAt 𝕜 f x) (hg : DifferentiableAt 𝕜 g x) :
    deriv (fun y => f y + g y) x = deriv f x + deriv g x :=
  (hf.HasDerivAt.add hg.HasDerivAt).deriv
#align deriv_add deriv_add
-/

#print HasDerivAtFilter.add_const /-
theorem HasDerivAtFilter.add_const (hf : HasDerivAtFilter f f' x L) (c : F) :
    HasDerivAtFilter (fun y => f y + c) f' x L :=
  add_zero f' ▸ hf.add (hasDerivAtFilter_const x L c)
#align has_deriv_at_filter.add_const HasDerivAtFilter.add_const
-/

#print HasDerivWithinAt.add_const /-
theorem HasDerivWithinAt.add_const (hf : HasDerivWithinAt f f' s x) (c : F) :
    HasDerivWithinAt (fun y => f y + c) f' s x :=
  hf.AddConst c
#align has_deriv_within_at.add_const HasDerivWithinAt.add_const
-/

#print HasDerivAt.add_const /-
theorem HasDerivAt.add_const (hf : HasDerivAt f f' x) (c : F) :
    HasDerivAt (fun x => f x + c) f' x :=
  hf.AddConst c
#align has_deriv_at.add_const HasDerivAt.add_const
-/

#print derivWithin_add_const /-
theorem derivWithin_add_const (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
    derivWithin (fun y => f y + c) s x = derivWithin f s x := by
  simp only [derivWithin, fderivWithin_add_const hxs]
#align deriv_within_add_const derivWithin_add_const
-/

#print deriv_add_const /-
theorem deriv_add_const (c : F) : deriv (fun y => f y + c) x = deriv f x := by
  simp only [deriv, fderiv_add_const]
#align deriv_add_const deriv_add_const
-/

#print deriv_add_const' /-
@[simp]
theorem deriv_add_const' (c : F) : (deriv fun y => f y + c) = deriv f :=
  funext fun x => deriv_add_const c
#align deriv_add_const' deriv_add_const'
-/

#print HasDerivAtFilter.const_add /-
theorem HasDerivAtFilter.const_add (c : F) (hf : HasDerivAtFilter f f' x L) :
    HasDerivAtFilter (fun y => c + f y) f' x L :=
  zero_add f' ▸ (hasDerivAtFilter_const x L c).add hf
#align has_deriv_at_filter.const_add HasDerivAtFilter.const_add
-/

#print HasDerivWithinAt.const_add /-
theorem HasDerivWithinAt.const_add (c : F) (hf : HasDerivWithinAt f f' s x) :
    HasDerivWithinAt (fun y => c + f y) f' s x :=
  hf.const_add c
#align has_deriv_within_at.const_add HasDerivWithinAt.const_add
-/

#print HasDerivAt.const_add /-
theorem HasDerivAt.const_add (c : F) (hf : HasDerivAt f f' x) :
    HasDerivAt (fun x => c + f x) f' x :=
  hf.const_add c
#align has_deriv_at.const_add HasDerivAt.const_add
-/

#print derivWithin_const_add /-
theorem derivWithin_const_add (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
    derivWithin (fun y => c + f y) s x = derivWithin f s x := by
  simp only [derivWithin, fderivWithin_const_add hxs]
#align deriv_within_const_add derivWithin_const_add
-/

#print deriv_const_add /-
theorem deriv_const_add (c : F) : deriv (fun y => c + f y) x = deriv f x := by
  simp only [deriv, fderiv_const_add]
#align deriv_const_add deriv_const_add
-/

#print deriv_const_add' /-
@[simp]
theorem deriv_const_add' (c : F) : (deriv fun y => c + f y) = deriv f :=
  funext fun x => deriv_const_add c
#align deriv_const_add' deriv_const_add'
-/

end Add

section Sum

/-! ### Derivative of a finite sum of functions -/


open scoped BigOperators

variable {ι : Type _} {u : Finset ι} {A : ι → 𝕜 → F} {A' : ι → F}

#print HasDerivAtFilter.sum /-
theorem HasDerivAtFilter.sum (h : ∀ i ∈ u, HasDerivAtFilter (A i) (A' i) x L) :
    HasDerivAtFilter (fun y => ∑ i in u, A i y) (∑ i in u, A' i) x L := by
  simpa [ContinuousLinearMap.sum_apply] using (HasFDerivAtFilter.sum h).HasDerivAtFilter
#align has_deriv_at_filter.sum HasDerivAtFilter.sum
-/

#print HasStrictDerivAt.sum /-
theorem HasStrictDerivAt.sum (h : ∀ i ∈ u, HasStrictDerivAt (A i) (A' i) x) :
    HasStrictDerivAt (fun y => ∑ i in u, A i y) (∑ i in u, A' i) x := by
  simpa [ContinuousLinearMap.sum_apply] using (HasStrictFDerivAt.sum h).HasStrictDerivAt
#align has_strict_deriv_at.sum HasStrictDerivAt.sum
-/

#print HasDerivWithinAt.sum /-
theorem HasDerivWithinAt.sum (h : ∀ i ∈ u, HasDerivWithinAt (A i) (A' i) s x) :
    HasDerivWithinAt (fun y => ∑ i in u, A i y) (∑ i in u, A' i) s x :=
  HasDerivAtFilter.sum h
#align has_deriv_within_at.sum HasDerivWithinAt.sum
-/

#print HasDerivAt.sum /-
theorem HasDerivAt.sum (h : ∀ i ∈ u, HasDerivAt (A i) (A' i) x) :
    HasDerivAt (fun y => ∑ i in u, A i y) (∑ i in u, A' i) x :=
  HasDerivAtFilter.sum h
#align has_deriv_at.sum HasDerivAt.sum
-/

#print derivWithin_sum /-
theorem derivWithin_sum (hxs : UniqueDiffWithinAt 𝕜 s x)
    (h : ∀ i ∈ u, DifferentiableWithinAt 𝕜 (A i) s x) :
    derivWithin (fun y => ∑ i in u, A i y) s x = ∑ i in u, derivWithin (A i) s x :=
  (HasDerivWithinAt.sum fun i hi => (h i hi).HasDerivWithinAt).derivWithin hxs
#align deriv_within_sum derivWithin_sum
-/

#print deriv_sum /-
@[simp]
theorem deriv_sum (h : ∀ i ∈ u, DifferentiableAt 𝕜 (A i) x) :
    deriv (fun y => ∑ i in u, A i y) x = ∑ i in u, deriv (A i) x :=
  (HasDerivAt.sum fun i hi => (h i hi).HasDerivAt).deriv
#align deriv_sum deriv_sum
-/

end Sum

section Neg

/-! ### Derivative of the negative of a function -/


#print HasDerivAtFilter.neg /-
theorem HasDerivAtFilter.neg (h : HasDerivAtFilter f f' x L) :
    HasDerivAtFilter (fun x => -f x) (-f') x L := by simpa using h.neg.has_deriv_at_filter
#align has_deriv_at_filter.neg HasDerivAtFilter.neg
-/

#print HasDerivWithinAt.neg /-
theorem HasDerivWithinAt.neg (h : HasDerivWithinAt f f' s x) :
    HasDerivWithinAt (fun x => -f x) (-f') s x :=
  h.neg
#align has_deriv_within_at.neg HasDerivWithinAt.neg
-/

#print HasDerivAt.neg /-
theorem HasDerivAt.neg (h : HasDerivAt f f' x) : HasDerivAt (fun x => -f x) (-f') x :=
  h.neg
#align has_deriv_at.neg HasDerivAt.neg
-/

#print HasStrictDerivAt.neg /-
theorem HasStrictDerivAt.neg (h : HasStrictDerivAt f f' x) :
    HasStrictDerivAt (fun x => -f x) (-f') x := by simpa using h.neg.has_strict_deriv_at
#align has_strict_deriv_at.neg HasStrictDerivAt.neg
-/

#print derivWithin.neg /-
theorem derivWithin.neg (hxs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin (fun y => -f y) s x = -derivWithin f s x := by
  simp only [derivWithin, fderivWithin_neg hxs, ContinuousLinearMap.neg_apply]
#align deriv_within.neg derivWithin.neg
-/

#print deriv.neg /-
theorem deriv.neg : deriv (fun y => -f y) x = -deriv f x := by
  simp only [deriv, fderiv_neg, ContinuousLinearMap.neg_apply]
#align deriv.neg deriv.neg
-/

#print deriv.neg' /-
@[simp]
theorem deriv.neg' : (deriv fun y => -f y) = fun x => -deriv f x :=
  funext fun x => deriv.neg
#align deriv.neg' deriv.neg'
-/

end Neg

section Neg2

/-! ### Derivative of the negation function (i.e `has_neg.neg`) -/


variable (s x L)

#print hasDerivAtFilter_neg /-
theorem hasDerivAtFilter_neg : HasDerivAtFilter Neg.neg (-1) x L :=
  HasDerivAtFilter.neg <| hasDerivAtFilter_id _ _
#align has_deriv_at_filter_neg hasDerivAtFilter_neg
-/

#print hasDerivWithinAt_neg /-
theorem hasDerivWithinAt_neg : HasDerivWithinAt Neg.neg (-1) s x :=
  hasDerivAtFilter_neg _ _
#align has_deriv_within_at_neg hasDerivWithinAt_neg
-/

#print hasDerivAt_neg /-
theorem hasDerivAt_neg : HasDerivAt Neg.neg (-1) x :=
  hasDerivAtFilter_neg _ _
#align has_deriv_at_neg hasDerivAt_neg
-/

#print hasDerivAt_neg' /-
theorem hasDerivAt_neg' : HasDerivAt (fun x => -x) (-1) x :=
  hasDerivAtFilter_neg _ _
#align has_deriv_at_neg' hasDerivAt_neg'
-/

#print hasStrictDerivAt_neg /-
theorem hasStrictDerivAt_neg : HasStrictDerivAt Neg.neg (-1) x :=
  HasStrictDerivAt.neg <| hasStrictDerivAt_id _
#align has_strict_deriv_at_neg hasStrictDerivAt_neg
-/

#print deriv_neg /-
theorem deriv_neg : deriv Neg.neg x = -1 :=
  HasDerivAt.deriv (hasDerivAt_neg x)
#align deriv_neg deriv_neg
-/

#print deriv_neg' /-
@[simp]
theorem deriv_neg' : deriv (Neg.neg : 𝕜 → 𝕜) = fun _ => -1 :=
  funext deriv_neg
#align deriv_neg' deriv_neg'
-/

#print deriv_neg'' /-
@[simp]
theorem deriv_neg'' : deriv (fun x : 𝕜 => -x) x = -1 :=
  deriv_neg x
#align deriv_neg'' deriv_neg''
-/

#print derivWithin_neg /-
theorem derivWithin_neg (hxs : UniqueDiffWithinAt 𝕜 s x) : derivWithin Neg.neg s x = -1 :=
  (hasDerivWithinAt_neg x s).derivWithin hxs
#align deriv_within_neg derivWithin_neg
-/

#print differentiable_neg /-
theorem differentiable_neg : Differentiable 𝕜 (Neg.neg : 𝕜 → 𝕜) :=
  Differentiable.neg differentiable_id
#align differentiable_neg differentiable_neg
-/

#print differentiableOn_neg /-
theorem differentiableOn_neg : DifferentiableOn 𝕜 (Neg.neg : 𝕜 → 𝕜) s :=
  DifferentiableOn.neg differentiableOn_id
#align differentiable_on_neg differentiableOn_neg
-/

end Neg2

section Sub

/-! ### Derivative of the difference of two functions -/


#print HasDerivAtFilter.sub /-
theorem HasDerivAtFilter.sub (hf : HasDerivAtFilter f f' x L) (hg : HasDerivAtFilter g g' x L) :
    HasDerivAtFilter (fun x => f x - g x) (f' - g') x L := by
  simpa only [sub_eq_add_neg] using hf.add hg.neg
#align has_deriv_at_filter.sub HasDerivAtFilter.sub
-/

#print HasDerivWithinAt.sub /-
theorem HasDerivWithinAt.sub (hf : HasDerivWithinAt f f' s x) (hg : HasDerivWithinAt g g' s x) :
    HasDerivWithinAt (fun x => f x - g x) (f' - g') s x :=
  hf.sub hg
#align has_deriv_within_at.sub HasDerivWithinAt.sub
-/

#print HasDerivAt.sub /-
theorem HasDerivAt.sub (hf : HasDerivAt f f' x) (hg : HasDerivAt g g' x) :
    HasDerivAt (fun x => f x - g x) (f' - g') x :=
  hf.sub hg
#align has_deriv_at.sub HasDerivAt.sub
-/

#print HasStrictDerivAt.sub /-
theorem HasStrictDerivAt.sub (hf : HasStrictDerivAt f f' x) (hg : HasStrictDerivAt g g' x) :
    HasStrictDerivAt (fun x => f x - g x) (f' - g') x := by
  simpa only [sub_eq_add_neg] using hf.add hg.neg
#align has_strict_deriv_at.sub HasStrictDerivAt.sub
-/

#print derivWithin_sub /-
theorem derivWithin_sub (hxs : UniqueDiffWithinAt 𝕜 s x) (hf : DifferentiableWithinAt 𝕜 f s x)
    (hg : DifferentiableWithinAt 𝕜 g s x) :
    derivWithin (fun y => f y - g y) s x = derivWithin f s x - derivWithin g s x :=
  (hf.HasDerivWithinAt.sub hg.HasDerivWithinAt).derivWithin hxs
#align deriv_within_sub derivWithin_sub
-/

#print deriv_sub /-
@[simp]
theorem deriv_sub (hf : DifferentiableAt 𝕜 f x) (hg : DifferentiableAt 𝕜 g x) :
    deriv (fun y => f y - g y) x = deriv f x - deriv g x :=
  (hf.HasDerivAt.sub hg.HasDerivAt).deriv
#align deriv_sub deriv_sub
-/

#print HasDerivAtFilter.sub_const /-
theorem HasDerivAtFilter.sub_const (hf : HasDerivAtFilter f f' x L) (c : F) :
    HasDerivAtFilter (fun x => f x - c) f' x L := by
  simpa only [sub_eq_add_neg] using hf.add_const (-c)
#align has_deriv_at_filter.sub_const HasDerivAtFilter.sub_const
-/

#print HasDerivWithinAt.sub_const /-
theorem HasDerivWithinAt.sub_const (hf : HasDerivWithinAt f f' s x) (c : F) :
    HasDerivWithinAt (fun x => f x - c) f' s x :=
  hf.sub_const c
#align has_deriv_within_at.sub_const HasDerivWithinAt.sub_const
-/

#print HasDerivAt.sub_const /-
theorem HasDerivAt.sub_const (hf : HasDerivAt f f' x) (c : F) :
    HasDerivAt (fun x => f x - c) f' x :=
  hf.sub_const c
#align has_deriv_at.sub_const HasDerivAt.sub_const
-/

#print derivWithin_sub_const /-
theorem derivWithin_sub_const (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
    derivWithin (fun y => f y - c) s x = derivWithin f s x := by
  simp only [derivWithin, fderivWithin_sub_const hxs]
#align deriv_within_sub_const derivWithin_sub_const
-/

#print deriv_sub_const /-
theorem deriv_sub_const (c : F) : deriv (fun y => f y - c) x = deriv f x := by
  simp only [deriv, fderiv_sub_const]
#align deriv_sub_const deriv_sub_const
-/

#print HasDerivAtFilter.const_sub /-
theorem HasDerivAtFilter.const_sub (c : F) (hf : HasDerivAtFilter f f' x L) :
    HasDerivAtFilter (fun x => c - f x) (-f') x L := by
  simpa only [sub_eq_add_neg] using hf.neg.const_add c
#align has_deriv_at_filter.const_sub HasDerivAtFilter.const_sub
-/

#print HasDerivWithinAt.const_sub /-
theorem HasDerivWithinAt.const_sub (c : F) (hf : HasDerivWithinAt f f' s x) :
    HasDerivWithinAt (fun x => c - f x) (-f') s x :=
  hf.const_sub c
#align has_deriv_within_at.const_sub HasDerivWithinAt.const_sub
-/

#print HasStrictDerivAt.const_sub /-
theorem HasStrictDerivAt.const_sub (c : F) (hf : HasStrictDerivAt f f' x) :
    HasStrictDerivAt (fun x => c - f x) (-f') x := by
  simpa only [sub_eq_add_neg] using hf.neg.const_add c
#align has_strict_deriv_at.const_sub HasStrictDerivAt.const_sub
-/

#print HasDerivAt.const_sub /-
theorem HasDerivAt.const_sub (c : F) (hf : HasDerivAt f f' x) :
    HasDerivAt (fun x => c - f x) (-f') x :=
  hf.const_sub c
#align has_deriv_at.const_sub HasDerivAt.const_sub
-/

#print derivWithin_const_sub /-
theorem derivWithin_const_sub (hxs : UniqueDiffWithinAt 𝕜 s x) (c : F) :
    derivWithin (fun y => c - f y) s x = -derivWithin f s x := by
  simp [derivWithin, fderivWithin_const_sub hxs]
#align deriv_within_const_sub derivWithin_const_sub
-/

#print deriv_const_sub /-
theorem deriv_const_sub (c : F) : deriv (fun y => c - f y) x = -deriv f x := by
  simp only [← derivWithin_univ,
    derivWithin_const_sub (uniqueDiffWithinAt_univ : UniqueDiffWithinAt 𝕜 _ _)]
#align deriv_const_sub deriv_const_sub
-/

end Sub

