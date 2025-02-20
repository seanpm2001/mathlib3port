/-
Copyright (c) 2022 Anatole Dedecker. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anatole Dedecker

! This file was ported from Lean 3 source module analysis.locally_convex.strong_topology
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Algebra.Module.StrongTopology
import Mathbin.Topology.Algebra.Module.LocallyConvex

/-!
# Local convexity of the strong topology

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that the strong topology on `E →L[ℝ] F` is locally convex provided that `F` is
locally convex.

## References

* [N. Bourbaki, *Topological Vector Spaces*][bourbaki1987]

## Todo

* Characterization in terms of seminorms

## Tags

locally convex, bounded convergence
-/


open scoped Topology UniformConvergence

variable {R 𝕜₁ 𝕜₂ E F : Type _}

namespace ContinuousLinearMap

variable [AddCommGroup E] [TopologicalSpace E] [AddCommGroup F] [TopologicalSpace F]
  [TopologicalAddGroup F]

section General

variable (R)

variable [OrderedSemiring R]

variable [NormedField 𝕜₁] [NormedField 𝕜₂] [Module 𝕜₁ E] [Module 𝕜₂ F] {σ : 𝕜₁ →+* 𝕜₂}

variable [Module R F] [ContinuousConstSMul R F] [LocallyConvexSpace R F] [SMulCommClass 𝕜₂ R F]

#print ContinuousLinearMap.strongTopology.locallyConvexSpace /-
theorem strongTopology.locallyConvexSpace (𝔖 : Set (Set E)) (h𝔖₁ : 𝔖.Nonempty)
    (h𝔖₂ : DirectedOn (· ⊆ ·) 𝔖) :
    @LocallyConvexSpace R (E →SL[σ] F) _ _ _ (strongTopology σ F 𝔖) :=
  by
  letI : TopologicalSpace (E →SL[σ] F) := strong_topology σ F 𝔖
  haveI : TopologicalAddGroup (E →SL[σ] F) := strong_topology.topological_add_group _ _ _
  refine'
    LocallyConvexSpace.ofBasisZero _ _ _ _
      (strong_topology.has_basis_nhds_zero_of_basis _ _ _ h𝔖₁ h𝔖₂
        (LocallyConvexSpace.convex_basis_zero R F))
      _
  rintro ⟨S, V⟩ ⟨hS, hVmem, hVconvex⟩ f hf g hg a b ha hb hab x hx
  exact hVconvex (hf x hx) (hg x hx) ha hb hab
#align continuous_linear_map.strong_topology.locally_convex_space ContinuousLinearMap.strongTopology.locallyConvexSpace
-/

end General

section BoundedSets

variable [OrderedSemiring R]

variable [NormedField 𝕜₁] [NormedField 𝕜₂] [Module 𝕜₁ E] [Module 𝕜₂ F] {σ : 𝕜₁ →+* 𝕜₂}

variable [Module R F] [ContinuousConstSMul R F] [LocallyConvexSpace R F] [SMulCommClass 𝕜₂ R F]

instance : LocallyConvexSpace R (E →SL[σ] F) :=
  strongTopology.locallyConvexSpace R _ ⟨∅, Bornology.isVonNBounded_empty 𝕜₁ E⟩
    (directedOn_of_sup_mem fun _ _ => Bornology.IsVonNBounded.union)

end BoundedSets

end ContinuousLinearMap

