/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module topology.algebra.order.t5
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Order.Basic
import Mathbin.Data.Set.Intervals.OrdConnectedComponent

/-!
# Linear order is a completely normal Hausdorff topological space

In this file we prove that a linear order with order topology is a completely normal Hausdorff
topological space.
-/


open Filter Set Function OrderDual

open TopologicalSpace Filter Interval

variable {X : Type _} [LinearOrder X] [TopologicalSpace X] [OrderTopology X] {a b c : X}
  {s t : Set X}

namespace Set

@[simp]
theorem ordConnectedComponent_mem_nhds : ordConnectedComponent s a ∈ 𝓝 a ↔ s ∈ 𝓝 a :=
  by
  refine' ⟨fun h => mem_of_superset h ord_connected_component_subset, fun h => _⟩
  rcases exists_icc_mem_subset_of_mem_nhds h with ⟨b, c, ha, ha', hs⟩
  exact mem_of_superset ha' (subset_ord_connected_component ha hs)
#align set.ord_connected_component_mem_nhds Set.ordConnectedComponent_mem_nhds

theorem compl_section_ordSeparatingSet_mem_nhdsWithin_ici (hd : Disjoint s (closure t))
    (ha : a ∈ s) : (ord_connected_section <| ordSeparatingSet s t)ᶜ ∈ 𝓝[≥] a :=
  by
  have hmem : tᶜ ∈ 𝓝[≥] a := by
    refine' mem_nhdsWithin_of_mem_nhds _
    rw [← mem_interior_iff_mem_nhds, interior_compl]
    exact disjoint_left.1 hd ha
  rcases exists_icc_mem_subset_of_mem_nhdsWithin_ici hmem with ⟨b, hab, hmem', hsub⟩
  by_cases H : Disjoint (Icc a b) (ord_connected_section <| ord_separating_set s t)
  · exact mem_of_superset hmem' (disjoint_left.1 H)
  · simp only [Set.disjoint_left, not_forall, not_not] at H
    rcases H with ⟨c, ⟨hac, hcb⟩, hc⟩
    have hsub' : Icc a b ⊆ ord_connected_component (tᶜ) a :=
      subset_ord_connected_component (left_mem_Icc.2 hab) hsub
    replace hac : a < c :=
      hac.lt_of_ne
        (Ne.symm <|
          ne_of_mem_of_not_mem hc <|
            disjoint_left.1
              (disjoint_left_ord_separating_set.mono_right ord_connected_section_subset) ha)
    refine' mem_of_superset (ico_mem_nhdsWithin_ici (left_mem_Ico.2 hac)) fun x hx hx' => _
    refine' hx.2.Ne (eq_of_mem_ord_connected_section_of_uIcc_subset hx' hc _)
    refine' subset_inter (subset_Union₂_of_subset a ha _) _
    ·
      exact
        ord_connected.uIcc_subset inferInstance (hsub' ⟨hx.1, hx.2.le.trans hcb⟩)
          (hsub' ⟨hac.le, hcb⟩)
    · rcases mem_Union₂.1 (ord_connected_section_subset hx').2 with ⟨y, hyt, hxy⟩
      refine' subset_Union₂_of_subset y hyt (ord_connected.uIcc_subset inferInstance hxy _)
      refine' subset_ord_connected_component left_mem_uIcc hxy _
      suffices c < y by
        rw [uIcc_of_ge (hx.2.trans this).le]
        exact ⟨hx.2.le, this.le⟩
      refine' lt_of_not_le fun hyc => _
      have hya : y < a := not_le.1 fun hay => hsub ⟨hay, hyc.trans hcb⟩ hyt
      exact hxy (Icc_subset_uIcc ⟨hya.le, hx.1⟩) ha
#align set.compl_section_ord_separating_set_mem_nhds_within_Ici Set.compl_section_ordSeparatingSet_mem_nhdsWithin_ici

theorem compl_section_ordSeparatingSet_mem_nhdsWithin_iic (hd : Disjoint s (closure t))
    (ha : a ∈ s) : (ord_connected_section <| ordSeparatingSet s t)ᶜ ∈ 𝓝[≤] a :=
  by
  have hd' : Disjoint (of_dual ⁻¹' s) (closure <| of_dual ⁻¹' t) := hd
  have ha' : toDual a ∈ of_dual ⁻¹' s := ha
  simpa only [dual_ord_separating_set, dual_ord_connected_section] using
    compl_section_ord_separating_set_mem_nhds_within_Ici hd' ha'
#align set.compl_section_ord_separating_set_mem_nhds_within_Iic Set.compl_section_ordSeparatingSet_mem_nhdsWithin_iic

theorem compl_section_ordSeparatingSet_mem_nhds (hd : Disjoint s (closure t)) (ha : a ∈ s) :
    (ord_connected_section <| ordSeparatingSet s t)ᶜ ∈ 𝓝 a :=
  by
  rw [← nhds_left_sup_nhds_right, mem_sup]
  exact
    ⟨compl_section_ord_separating_set_mem_nhds_within_Iic hd ha,
      compl_section_ord_separating_set_mem_nhds_within_Ici hd ha⟩
#align set.compl_section_ord_separating_set_mem_nhds Set.compl_section_ordSeparatingSet_mem_nhds

theorem ordT5Nhd_mem_nhdsSet (hd : Disjoint s (closure t)) : ordT5Nhd s t ∈ 𝓝ˢ s :=
  bUnion_mem_nhdsSet fun x hx =>
    ordConnectedComponent_mem_nhds.2 <|
      inter_mem
        (by
          rw [← mem_interior_iff_mem_nhds, interior_compl]
          exact disjoint_left.1 hd hx)
        (compl_section_ordSeparatingSet_mem_nhds hd hx)
#align set.ord_t5_nhd_mem_nhds_set Set.ordT5Nhd_mem_nhdsSet

end Set

open Set

/-- A linear order with order topology is a completely normal Hausdorff topological space. -/
instance (priority := 100) OrderTopology.t5Space : T5Space X :=
  ⟨fun s t h₁ h₂ =>
    Filter.disjoint_iff.2
      ⟨ordT5Nhd s t, ordT5Nhd_mem_nhdsSet h₂, ordT5Nhd t s, ordT5Nhd_mem_nhdsSet h₁.symm,
        disjoint_ordT5Nhd⟩⟩
#align order_topology.t5_space OrderTopology.t5Space

