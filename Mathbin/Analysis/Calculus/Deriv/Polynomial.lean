/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel, Eric Wieser

! This file was ported from Lean 3 source module analysis.calculus.deriv.polynomial
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Deriv.Pow
import Mathbin.Analysis.Calculus.Deriv.Add
import Mathbin.Data.Polynomial.AlgebraMap
import Mathbin.Data.Polynomial.Derivative

/-!
# Derivatives of polynomials

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that derivatives of polynomials in the analysis sense agree with their
derivatives in the algebraic sense.

For a more detailed overview of one-dimensional derivatives in mathlib, see the module docstring of
`analysis/calculus/deriv/basic`.

## TODO

* Add results about multivariable polynomials.
* Generalize some (most?) results to an algebra over the base field.

## Keywords

derivative, polynomial
-/


universe u v w

open scoped Classical Topology BigOperators Filter ENNReal Polynomial

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

namespace Polynomial

/-! ### Derivative of a polynomial -/


variable {R : Type _} [CommSemiring R] [Algebra R 𝕜]

variable (p : 𝕜[X]) (q : R[X])

#print Polynomial.hasStrictDerivAt /-
/-- The derivative (in the analysis sense) of a polynomial `p` is given by `p.derivative`. -/
protected theorem hasStrictDerivAt (x : 𝕜) :
    HasStrictDerivAt (fun x => p.eval x) (p.derivative.eval x) x :=
  by
  induction p using Polynomial.induction_on'
  case h_add p q hp hq => simpa using hp.add hq
  case h_monomial n a => simpa [mul_assoc] using (hasStrictDerivAt_pow n x).const_mul a
#align polynomial.has_strict_deriv_at Polynomial.hasStrictDerivAt
-/

#print Polynomial.hasStrictDerivAt_aeval /-
protected theorem hasStrictDerivAt_aeval (x : 𝕜) :
    HasStrictDerivAt (fun x => aeval x q) (aeval x q.derivative) x := by
  simpa only [aeval_def, eval₂_eq_eval_map, derivative_map] using
    (q.map (algebraMap R 𝕜)).HasStrictDerivAt x
#align polynomial.has_strict_deriv_at_aeval Polynomial.hasStrictDerivAt_aeval
-/

#print Polynomial.hasDerivAt /-
/-- The derivative (in the analysis sense) of a polynomial `p` is given by `p.derivative`. -/
protected theorem hasDerivAt (x : 𝕜) : HasDerivAt (fun x => p.eval x) (p.derivative.eval x) x :=
  (p.HasStrictDerivAt x).HasDerivAt
#align polynomial.has_deriv_at Polynomial.hasDerivAt
-/

#print Polynomial.hasDerivAt_aeval /-
protected theorem hasDerivAt_aeval (x : 𝕜) :
    HasDerivAt (fun x => aeval x q) (aeval x q.derivative) x :=
  (q.hasStrictDerivAt_aeval x).HasDerivAt
#align polynomial.has_deriv_at_aeval Polynomial.hasDerivAt_aeval
-/

#print Polynomial.hasDerivWithinAt /-
protected theorem hasDerivWithinAt (x : 𝕜) (s : Set 𝕜) :
    HasDerivWithinAt (fun x => p.eval x) (p.derivative.eval x) s x :=
  (p.HasDerivAt x).HasDerivWithinAt
#align polynomial.has_deriv_within_at Polynomial.hasDerivWithinAt
-/

#print Polynomial.hasDerivWithinAt_aeval /-
protected theorem hasDerivWithinAt_aeval (x : 𝕜) (s : Set 𝕜) :
    HasDerivWithinAt (fun x => aeval x q) (aeval x q.derivative) s x :=
  (q.hasDerivAt_aeval x).HasDerivWithinAt
#align polynomial.has_deriv_within_at_aeval Polynomial.hasDerivWithinAt_aeval
-/

#print Polynomial.differentiableAt /-
protected theorem differentiableAt : DifferentiableAt 𝕜 (fun x => p.eval x) x :=
  (p.HasDerivAt x).DifferentiableAt
#align polynomial.differentiable_at Polynomial.differentiableAt
-/

#print Polynomial.differentiableAt_aeval /-
protected theorem differentiableAt_aeval : DifferentiableAt 𝕜 (fun x => aeval x q) x :=
  (q.hasDerivAt_aeval x).DifferentiableAt
#align polynomial.differentiable_at_aeval Polynomial.differentiableAt_aeval
-/

#print Polynomial.differentiableWithinAt /-
protected theorem differentiableWithinAt : DifferentiableWithinAt 𝕜 (fun x => p.eval x) s x :=
  p.DifferentiableAt.DifferentiableWithinAt
#align polynomial.differentiable_within_at Polynomial.differentiableWithinAt
-/

#print Polynomial.differentiableWithinAt_aeval /-
protected theorem differentiableWithinAt_aeval :
    DifferentiableWithinAt 𝕜 (fun x => aeval x q) s x :=
  q.differentiableAt_aeval.DifferentiableWithinAt
#align polynomial.differentiable_within_at_aeval Polynomial.differentiableWithinAt_aeval
-/

#print Polynomial.differentiable /-
protected theorem differentiable : Differentiable 𝕜 fun x => p.eval x := fun x => p.DifferentiableAt
#align polynomial.differentiable Polynomial.differentiable
-/

#print Polynomial.differentiable_aeval /-
protected theorem differentiable_aeval : Differentiable 𝕜 fun x : 𝕜 => aeval x q := fun x =>
  q.differentiableAt_aeval
#align polynomial.differentiable_aeval Polynomial.differentiable_aeval
-/

#print Polynomial.differentiableOn /-
protected theorem differentiableOn : DifferentiableOn 𝕜 (fun x => p.eval x) s :=
  p.Differentiable.DifferentiableOn
#align polynomial.differentiable_on Polynomial.differentiableOn
-/

#print Polynomial.differentiableOn_aeval /-
protected theorem differentiableOn_aeval : DifferentiableOn 𝕜 (fun x => aeval x q) s :=
  q.differentiable_aeval.DifferentiableOn
#align polynomial.differentiable_on_aeval Polynomial.differentiableOn_aeval
-/

#print Polynomial.deriv /-
@[simp]
protected theorem deriv : deriv (fun x => p.eval x) x = p.derivative.eval x :=
  (p.HasDerivAt x).deriv
#align polynomial.deriv Polynomial.deriv
-/

#print Polynomial.deriv_aeval /-
@[simp]
protected theorem deriv_aeval : deriv (fun x => aeval x q) x = aeval x q.derivative :=
  (q.hasDerivAt_aeval x).deriv
#align polynomial.deriv_aeval Polynomial.deriv_aeval
-/

#print Polynomial.derivWithin /-
protected theorem derivWithin (hxs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin (fun x => p.eval x) s x = p.derivative.eval x :=
  by
  rw [DifferentiableAt.derivWithin p.differentiable_at hxs]
  exact p.deriv
#align polynomial.deriv_within Polynomial.derivWithin
-/

#print Polynomial.derivWithin_aeval /-
protected theorem derivWithin_aeval (hxs : UniqueDiffWithinAt 𝕜 s x) :
    derivWithin (fun x => aeval x q) s x = aeval x q.derivative := by
  simpa only [aeval_def, eval₂_eq_eval_map, derivative_map] using
    (q.map (algebraMap R 𝕜)).derivWithin hxs
#align polynomial.deriv_within_aeval Polynomial.derivWithin_aeval
-/

#print Polynomial.hasFDerivAt /-
protected theorem hasFDerivAt (x : 𝕜) :
    HasFDerivAt (fun x => p.eval x) (smulRight (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x)) x :=
  p.HasDerivAt x
#align polynomial.has_fderiv_at Polynomial.hasFDerivAt
-/

#print Polynomial.hasFDerivAt_aeval /-
protected theorem hasFDerivAt_aeval (x : 𝕜) :
    HasFDerivAt (fun x => aeval x q) (smulRight (1 : 𝕜 →L[𝕜] 𝕜) (aeval x q.derivative)) x :=
  q.hasDerivAt_aeval x
#align polynomial.has_fderiv_at_aeval Polynomial.hasFDerivAt_aeval
-/

#print Polynomial.hasFDerivWithinAt /-
protected theorem hasFDerivWithinAt (x : 𝕜) :
    HasFDerivWithinAt (fun x => p.eval x) (smulRight (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x)) s x :=
  (p.HasFDerivAt x).HasFDerivWithinAt
#align polynomial.has_fderiv_within_at Polynomial.hasFDerivWithinAt
-/

#print Polynomial.hasFDerivWithinAt_aeval /-
protected theorem hasFDerivWithinAt_aeval (x : 𝕜) :
    HasFDerivWithinAt (fun x => aeval x q) (smulRight (1 : 𝕜 →L[𝕜] 𝕜) (aeval x q.derivative)) s x :=
  (q.hasFDerivAt_aeval x).HasFDerivWithinAt
#align polynomial.has_fderiv_within_at_aeval Polynomial.hasFDerivWithinAt_aeval
-/

#print Polynomial.fderiv /-
@[simp]
protected theorem fderiv :
    fderiv 𝕜 (fun x => p.eval x) x = smulRight (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x) :=
  (p.HasFDerivAt x).fderiv
#align polynomial.fderiv Polynomial.fderiv
-/

#print Polynomial.fderiv_aeval /-
@[simp]
protected theorem fderiv_aeval :
    fderiv 𝕜 (fun x => aeval x q) x = smulRight (1 : 𝕜 →L[𝕜] 𝕜) (aeval x q.derivative) :=
  (q.hasFDerivAt_aeval x).fderiv
#align polynomial.fderiv_aeval Polynomial.fderiv_aeval
-/

#print Polynomial.fderivWithin /-
protected theorem fderivWithin (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (fun x => p.eval x) s x = smulRight (1 : 𝕜 →L[𝕜] 𝕜) (p.derivative.eval x) :=
  (p.HasFDerivWithinAt x).fderivWithin hxs
#align polynomial.fderiv_within Polynomial.fderivWithin
-/

#print Polynomial.fderivWithin_aeval /-
protected theorem fderivWithin_aeval (hxs : UniqueDiffWithinAt 𝕜 s x) :
    fderivWithin 𝕜 (fun x => aeval x q) s x = smulRight (1 : 𝕜 →L[𝕜] 𝕜) (aeval x q.derivative) :=
  (q.hasFDerivWithinAt_aeval x).fderivWithin hxs
#align polynomial.fderiv_within_aeval Polynomial.fderivWithin_aeval
-/

end Polynomial

