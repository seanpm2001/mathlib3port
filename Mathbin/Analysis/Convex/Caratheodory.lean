/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Scott Morrison

! This file was ported from Lean 3 source module analysis.convex.caratheodory
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Convex.Combination
import Mathbin.LinearAlgebra.AffineSpace.Independent
import Mathbin.Tactic.FieldSimp

/-!
# Carathéodory's convexity theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Convex hull can be regarded as a refinement of affine span. Both are closure operators but whereas
convex hull takes values in the lattice of convex subsets, affine span takes values in the much
coarser sublattice of affine subspaces.

The cost of this refinement is that one no longer has bases. However Carathéodory's convexity
theorem offers some compensation. Given a set `s` together with a point `x` in its convex hull,
Carathéodory says that one may find an affine-independent family of elements `s` whose convex hull
contains `x`. Thus the difference from the case of affine span is that the affine-independent family
depends on `x`.

In particular, in finite dimensions Carathéodory's theorem implies that the convex hull of a set `s`
in `𝕜ᵈ` is the union of the convex hulls of the `(d + 1)`-tuples in `s`.

## Main results

* `convex_hull_eq_union`: Carathéodory's convexity theorem

## Implementation details

This theorem was formalized as part of the Sphere Eversion project.

## Tags
convex hull, caratheodory

-/


open Set Finset

open scoped BigOperators

universe u

variable {𝕜 : Type _} {E : Type u} [LinearOrderedField 𝕜] [AddCommGroup E] [Module 𝕜 E]

namespace Caratheodory

#print Caratheodory.mem_convexHull_erase /-
/-- If `x` is in the convex hull of some finset `t` whose elements are not affine-independent,
then it is in the convex hull of a strict subset of `t`. -/
theorem mem_convexHull_erase [DecidableEq E] {t : Finset E} (h : ¬AffineIndependent 𝕜 (coe : t → E))
    {x : E} (m : x ∈ convexHull 𝕜 (↑t : Set E)) :
    ∃ y : (↑t : Set E), x ∈ convexHull 𝕜 (↑(t.eraseₓ y) : Set E) :=
  by
  simp only [Finset.convexHull_eq, mem_set_of_eq] at m ⊢
  obtain ⟨f, fpos, fsum, rfl⟩ := m
  obtain ⟨g, gcombo, gsum, gpos⟩ := exists_nontrivial_relation_sum_zero_of_not_affine_ind h
  replace gpos := exists_pos_of_sum_zero_of_exists_nonzero g gsum gpos
  clear h
  let s := @Finset.filter _ (fun z => 0 < g z) (fun _ => LinearOrder.decidableLt _ _) t
  obtain ⟨i₀, mem, w⟩ : ∃ i₀ ∈ s, ∀ i ∈ s, f i₀ / g i₀ ≤ f i / g i :=
    by
    apply s.exists_min_image fun z => f z / g z
    obtain ⟨x, hx, hgx⟩ : ∃ x ∈ t, 0 < g x := gpos
    exact ⟨x, mem_filter.mpr ⟨hx, hgx⟩⟩
  have hg : 0 < g i₀ := by rw [mem_filter] at mem ; exact mem.2
  have hi₀ : i₀ ∈ t := filter_subset _ _ mem
  let k : E → 𝕜 := fun z => f z - f i₀ / g i₀ * g z
  have hk : k i₀ = 0 := by field_simp [k, ne_of_gt hg]
  have ksum : ∑ e in t.erase i₀, k e = 1 := by
    calc
      ∑ e in t.erase i₀, k e = ∑ e in t, k e := by
        conv_rhs => rw [← insert_erase hi₀, sum_insert (not_mem_erase i₀ t), hk, zero_add]
      _ = ∑ e in t, (f e - f i₀ / g i₀ * g e) := rfl
      _ = 1 := by rw [sum_sub_distrib, fsum, ← mul_sum, gsum, MulZeroClass.mul_zero, sub_zero]
  refine' ⟨⟨i₀, hi₀⟩, k, _, by convert ksum, _⟩
  · simp only [and_imp, sub_nonneg, mem_erase, Ne.def, Subtype.coe_mk]
    intro e hei₀ het
    by_cases hes : e ∈ s
    · have hge : 0 < g e := by rw [mem_filter] at hes ; exact hes.2
      rw [← le_div_iff hge]
      exact w _ hes
    · calc
        _ ≤ 0 := mul_nonpos_of_nonneg_of_nonpos _ _
        -- prove two goals below
            _ ≤
            f e :=
          fpos e het
      · apply div_nonneg (fpos i₀ (mem_of_subset (filter_subset _ t) mem)) (le_of_lt hg)
      · simpa only [mem_filter, het, true_and_iff, not_lt] using hes
  · simp only [Subtype.coe_mk, center_mass_eq_of_sum_1 _ id ksum, id]
    calc
      ∑ e in t.erase i₀, k e • e = ∑ e in t, k e • e := sum_erase _ (by rw [hk, zero_smul])
      _ = ∑ e in t, (f e - f i₀ / g i₀ * g e) • e := rfl
      _ = t.center_mass f id := _
    simp only [sub_smul, mul_smul, sum_sub_distrib, ← smul_sum, gcombo, smul_zero, sub_zero,
      center_mass, fsum, inv_one, one_smul, id.def]
#align caratheodory.mem_convex_hull_erase Caratheodory.mem_convexHull_erase
-/

variable {s : Set E} {x : E} (hx : x ∈ convexHull 𝕜 s)

#print Caratheodory.minCardFinsetOfMemConvexHull /-
/-- Given a point `x` in the convex hull of a set `s`, this is a finite subset of `s` of minimum
cardinality, whose convex hull contains `x`. -/
noncomputable def minCardFinsetOfMemConvexHull : Finset E :=
  Function.argminOn Finset.card Nat.lt_wfRel {t | ↑t ⊆ s ∧ x ∈ convexHull 𝕜 (t : Set E)}
    (by
      simpa only [convexHull_eq_union_convexHull_finite_subsets s, exists_prop, mem_Union] using hx)
#align caratheodory.min_card_finset_of_mem_convex_hull Caratheodory.minCardFinsetOfMemConvexHull
-/

#print Caratheodory.minCardFinsetOfMemConvexHull_subseteq /-
theorem minCardFinsetOfMemConvexHull_subseteq : ↑(minCardFinsetOfMemConvexHull hx) ⊆ s :=
  (Function.argminOn_mem _ _ {t : Finset E | ↑t ⊆ s ∧ x ∈ convexHull 𝕜 (t : Set E)} _).1
#align caratheodory.min_card_finset_of_mem_convex_hull_subseteq Caratheodory.minCardFinsetOfMemConvexHull_subseteq
-/

#print Caratheodory.mem_minCardFinsetOfMemConvexHull /-
theorem mem_minCardFinsetOfMemConvexHull :
    x ∈ convexHull 𝕜 (minCardFinsetOfMemConvexHull hx : Set E) :=
  (Function.argminOn_mem _ _ {t : Finset E | ↑t ⊆ s ∧ x ∈ convexHull 𝕜 (t : Set E)} _).2
#align caratheodory.mem_min_card_finset_of_mem_convex_hull Caratheodory.mem_minCardFinsetOfMemConvexHull
-/

#print Caratheodory.minCardFinsetOfMemConvexHull_nonempty /-
theorem minCardFinsetOfMemConvexHull_nonempty : (minCardFinsetOfMemConvexHull hx).Nonempty :=
  by
  rw [← Finset.coe_nonempty, ← @convexHull_nonempty_iff 𝕜]
  exact ⟨x, mem_min_card_finset_of_mem_convex_hull hx⟩
#align caratheodory.min_card_finset_of_mem_convex_hull_nonempty Caratheodory.minCardFinsetOfMemConvexHull_nonempty
-/

#print Caratheodory.minCardFinsetOfMemConvexHull_card_le_card /-
theorem minCardFinsetOfMemConvexHull_card_le_card {t : Finset E} (ht₁ : ↑t ⊆ s)
    (ht₂ : x ∈ convexHull 𝕜 (t : Set E)) : (minCardFinsetOfMemConvexHull hx).card ≤ t.card :=
  Function.argminOn_le _ _ _ ⟨ht₁, ht₂⟩
#align caratheodory.min_card_finset_of_mem_convex_hull_card_le_card Caratheodory.minCardFinsetOfMemConvexHull_card_le_card
-/

#print Caratheodory.affineIndependent_minCardFinsetOfMemConvexHull /-
theorem affineIndependent_minCardFinsetOfMemConvexHull :
    AffineIndependent 𝕜 (coe : minCardFinsetOfMemConvexHull hx → E) :=
  by
  let k := (min_card_finset_of_mem_convex_hull hx).card - 1
  have hk : (min_card_finset_of_mem_convex_hull hx).card = k + 1 :=
    (Nat.succ_pred_eq_of_pos
        (finset.card_pos.mpr (min_card_finset_of_mem_convex_hull_nonempty hx))).symm
  classical
  by_contra
  obtain ⟨p, hp⟩ := mem_convex_hull_erase h (mem_min_card_finset_of_mem_convex_hull hx)
  have contra :=
    min_card_finset_of_mem_convex_hull_card_le_card hx
      (Set.Subset.trans (Finset.erase_subset (↑p) (min_card_finset_of_mem_convex_hull hx))
        (min_card_finset_of_mem_convex_hull_subseteq hx))
      hp
  rw [← not_lt] at contra 
  apply contra
  erw [card_erase_of_mem p.2, hk]
  exact lt_add_one _
#align caratheodory.affine_independent_min_card_finset_of_mem_convex_hull Caratheodory.affineIndependent_minCardFinsetOfMemConvexHull
-/

end Caratheodory

variable {s : Set E}

#print convexHull_eq_union /-
/-- **Carathéodory's convexity theorem** -/
theorem convexHull_eq_union :
    convexHull 𝕜 s =
      ⋃ (t : Finset E) (hss : ↑t ⊆ s) (hai : AffineIndependent 𝕜 (coe : t → E)), convexHull 𝕜 ↑t :=
  by
  apply Set.Subset.antisymm
  · intro x hx
    simp only [exists_prop, Set.mem_iUnion]
    exact
      ⟨Caratheodory.minCardFinsetOfMemConvexHull hx,
        Caratheodory.minCardFinsetOfMemConvexHull_subseteq hx,
        Caratheodory.affineIndependent_minCardFinsetOfMemConvexHull hx,
        Caratheodory.mem_minCardFinsetOfMemConvexHull hx⟩
  · iterate 3 convert Set.iUnion_subset _; intro
    exact convexHull_mono ‹_›
#align convex_hull_eq_union convexHull_eq_union
-/

#print eq_pos_convex_span_of_mem_convexHull /-
/-- A more explicit version of `convex_hull_eq_union`. -/
theorem eq_pos_convex_span_of_mem_convexHull {x : E} (hx : x ∈ convexHull 𝕜 s) :
    ∃ (ι : Sort (u + 1)) (_ : Fintype ι),
      ∃ (z : ι → E) (w : ι → 𝕜) (hss : Set.range z ⊆ s) (hai : AffineIndependent 𝕜 z) (hw :
        ∀ i, 0 < w i), ∑ i, w i = 1 ∧ ∑ i, w i • z i = x :=
  by
  rw [convexHull_eq_union] at hx 
  simp only [exists_prop, Set.mem_iUnion] at hx 
  obtain ⟨t, ht₁, ht₂, ht₃⟩ := hx
  simp only [t.convex_hull_eq, exists_prop, Set.mem_setOf_eq] at ht₃ 
  obtain ⟨w, hw₁, hw₂, hw₃⟩ := ht₃
  let t' := t.filter fun i => w i ≠ 0
  refine' ⟨t', t'.fintype_coe_sort, (coe : t' → E), w ∘ (coe : t' → E), _, _, _, _, _⟩
  · rw [Subtype.range_coe_subtype]; exact subset.trans (Finset.filter_subset _ t) ht₁
  · exact ht₂.comp_embedding ⟨_, inclusion_injective (Finset.filter_subset (fun i => w i ≠ 0) t)⟩
  ·
    exact fun i =>
      (hw₁ _ (finset.mem_filter.mp i.2).1).lt_of_ne (finset.mem_filter.mp i.property).2.symm
  · erw [Finset.sum_attach, Finset.sum_filter_ne_zero, hw₂]
  · change ∑ i : t' in t'.attach, (fun e => w e • e) ↑i = x
    erw [Finset.sum_attach, Finset.sum_filter_of_ne]
    · rw [t.center_mass_eq_of_sum_1 id hw₂] at hw₃ ; exact hw₃
    · intro e he hwe contra; apply hwe; rw [contra, zero_smul]
#align eq_pos_convex_span_of_mem_convex_hull eq_pos_convex_span_of_mem_convexHull
-/

