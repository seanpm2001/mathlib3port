/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module topology.algebra.order.filter
! leanprover-community/mathlib commit ad0089aca372256fe53dde13ca0dfea569bf5ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Order.Basic
import Mathbin.Topology.Filter

/-!
# Topology on filters of a space with order topology

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that `𝓝 (f x)` tends to `𝓝 filter.at_top` provided that `f` tends to
`filter.at_top`, and similarly for `filter.at_bot`.
-/


open scoped Topology

namespace Filter

variable {α X : Type _} [TopologicalSpace X] [PartialOrder X] [OrderTopology X]

#print Filter.tendsto_nhds_atTop /-
protected theorem tendsto_nhds_atTop [NoMaxOrder X] : Tendsto 𝓝 (atTop : Filter X) (𝓝 atTop) :=
  Filter.tendsto_nhds_atTop_iff.2 fun x => (eventually_gt_atTop x).mono fun y => le_mem_nhds
#align filter.tendsto_nhds_at_top Filter.tendsto_nhds_atTop
-/

#print Filter.tendsto_nhds_atBot /-
protected theorem tendsto_nhds_atBot [NoMinOrder X] : Tendsto 𝓝 (atBot : Filter X) (𝓝 atBot) :=
  @Filter.tendsto_nhds_atTop Xᵒᵈ _ _ _ _
#align filter.tendsto_nhds_at_bot Filter.tendsto_nhds_atBot
-/

#print Filter.Tendsto.nhds_atTop /-
theorem Tendsto.nhds_atTop [NoMaxOrder X] {f : α → X} {l : Filter α} (h : Tendsto f l atTop) :
    Tendsto (𝓝 ∘ f) l (𝓝 atTop) :=
  Filter.tendsto_nhds_atTop.comp h
#align filter.tendsto.nhds_at_top Filter.Tendsto.nhds_atTop
-/

#print Filter.Tendsto.nhds_atBot /-
theorem Tendsto.nhds_atBot [NoMinOrder X] {f : α → X} {l : Filter α} (h : Tendsto f l atBot) :
    Tendsto (𝓝 ∘ f) l (𝓝 atBot) :=
  @Tendsto.nhds_atTop α Xᵒᵈ _ _ _ _ _ _ h
#align filter.tendsto.nhds_at_bot Filter.Tendsto.nhds_atBot
-/

end Filter

