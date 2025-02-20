/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov, Johannes Hölzl

! This file was ported from Lean 3 source module dynamics.fixed_points.topology
! leanprover-community/mathlib commit 4c19a16e4b705bf135cf9a80ac18fcc99c438514
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Dynamics.FixedPoints.Basic
import Mathbin.Topology.Separation

/-!
# Topological properties of fixed points

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Currently this file contains two lemmas:

- `is_fixed_pt_of_tendsto_iterate`: if `f^n(x) → y` and `f` is continuous at `y`, then `f y = y`;
- `is_closed_fixed_points`: the set of fixed points of a continuous map is a closed set.

## TODO

fixed points, iterates
-/


variable {α : Type _} [TopologicalSpace α] [T2Space α] {f : α → α}

open Function Filter

open scoped Topology

#print isFixedPt_of_tendsto_iterate /-
/-- If the iterates `f^[n] x` converge to `y` and `f` is continuous at `y`,
then `y` is a fixed point for `f`. -/
theorem isFixedPt_of_tendsto_iterate {x y : α} (hy : Tendsto (fun n => (f^[n]) x) atTop (𝓝 y))
    (hf : ContinuousAt f y) : IsFixedPt f y :=
  by
  refine' tendsto_nhds_unique ((tendsto_add_at_top_iff_nat 1).1 _) hy
  simp only [iterate_succ' f]
  exact hf.tendsto.comp hy
#align is_fixed_pt_of_tendsto_iterate isFixedPt_of_tendsto_iterate
-/

#print isClosed_fixedPoints /-
/-- The set of fixed points of a continuous map is a closed set. -/
theorem isClosed_fixedPoints (hf : Continuous f) : IsClosed (fixedPoints f) :=
  isClosed_eq hf continuous_id
#align is_closed_fixed_points isClosed_fixedPoints
-/

