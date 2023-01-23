/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module analysis.calculus.affine_map
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.NormedSpace.ContinuousAffineMap
import Mathbin.Analysis.Calculus.ContDiff

/-!
# Smooth affine maps

This file contains results about smoothness of affine maps.

## Main definitions:

 * `continuous_affine_map.cont_diff`: a continuous affine map is smooth

-/


namespace ContinuousAffineMap

variable {𝕜 V W : Type _} [NontriviallyNormedField 𝕜]

variable [NormedAddCommGroup V] [NormedSpace 𝕜 V]

variable [NormedAddCommGroup W] [NormedSpace 𝕜 W]

/-- A continuous affine map between normed vector spaces is smooth. -/
theorem contDiff {n : ℕ∞} (f : V →A[𝕜] W) : ContDiff 𝕜 n f :=
  by
  rw [f.decomp]
  apply f.cont_linear.cont_diff.add
  simp only
  exact contDiff_const
#align continuous_affine_map.cont_diff ContinuousAffineMap.contDiff

end ContinuousAffineMap

