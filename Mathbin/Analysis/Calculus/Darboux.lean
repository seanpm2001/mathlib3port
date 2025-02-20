/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.calculus.darboux
! leanprover-community/mathlib commit 61b5e2755ccb464b68d05a9acf891ae04992d09d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.LocalExtr

/-!
# Darboux's theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that the derivative of a differentiable function on an interval takes all
intermediate values. The proof is based on the
[Wikipedia](https://en.wikipedia.org/wiki/Darboux%27s_theorem_(analysis)) page about this theorem.
-/


open Filter Set

open scoped Topology Classical

variable {a b : ℝ} {f f' : ℝ → ℝ}

#print exists_hasDerivWithinAt_eq_of_gt_of_lt /-
/-- **Darboux's theorem**: if `a ≤ b` and `f' a < m < f' b`, then `f' c = m` for some
`c ∈ (a, b)`. -/
theorem exists_hasDerivWithinAt_eq_of_gt_of_lt (hab : a ≤ b)
    (hf : ∀ x ∈ Icc a b, HasDerivWithinAt f (f' x) (Icc a b) x) {m : ℝ} (hma : f' a < m)
    (hmb : m < f' b) : m ∈ f' '' Ioo a b :=
  by
  rcases hab.eq_or_lt with (rfl | hab')
  · exact (lt_asymm hma hmb).elim
  set g : ℝ → ℝ := fun x => f x - m * x
  have hg : ∀ x ∈ Icc a b, HasDerivWithinAt g (f' x - m) (Icc a b) x :=
    by
    intro x hx
    simpa using (hf x hx).sub ((hasDerivWithinAt_id x _).const_mul m)
  obtain ⟨c, cmem, hc⟩ : ∃ c ∈ Icc a b, IsMinOn g (Icc a b) c
  exact
    is_compact_Icc.exists_forall_le (nonempty_Icc.2 <| hab) fun x hx => (hg x hx).ContinuousWithinAt
  have cmem' : c ∈ Ioo a b := by
    rcases cmem.1.eq_or_lt with (rfl | hac)
    -- Show that `c` can't be equal to `a`
    · refine'
        absurd (sub_nonneg.1 <| nonneg_of_mul_nonneg_right _ (sub_pos.2 hab')) (not_le_of_lt hma)
      have : b - a ∈ posTangentConeAt (Icc a b) a :=
        mem_posTangentConeAt_of_segment_subset (segment_eq_Icc hab ▸ subset.refl _)
      simpa [-sub_nonneg, -ContinuousLinearMap.map_sub] using
        hc.localize.has_fderiv_within_at_nonneg (hg a (left_mem_Icc.2 hab)) this
    rcases cmem.2.eq_or_gt with (rfl | hcb)
    -- Show that `c` can't be equal to `b`
    · refine'
        absurd (sub_nonpos.1 <| nonpos_of_mul_nonneg_right _ (sub_lt_zero.2 hab'))
          (not_le_of_lt hmb)
      have : a - b ∈ posTangentConeAt (Icc a b) b :=
        mem_posTangentConeAt_of_segment_subset (by rw [segment_symm, segment_eq_Icc hab])
      simpa [-sub_nonneg, -ContinuousLinearMap.map_sub] using
        hc.localize.has_fderiv_within_at_nonneg (hg b (right_mem_Icc.2 hab)) this
    exact ⟨hac, hcb⟩
  use c, cmem'
  rw [← sub_eq_zero]
  have : Icc a b ∈ 𝓝 c := by rwa [← mem_interior_iff_mem_nhds, interior_Icc]
  exact (hc.is_local_min this).hasDerivAt_eq_zero ((hg c cmem).HasDerivAt this)
#align exists_has_deriv_within_at_eq_of_gt_of_lt exists_hasDerivWithinAt_eq_of_gt_of_lt
-/

#print exists_hasDerivWithinAt_eq_of_lt_of_gt /-
/-- **Darboux's theorem**: if `a ≤ b` and `f' b < m < f' a`, then `f' c = m` for some `c ∈ (a, b)`.
-/
theorem exists_hasDerivWithinAt_eq_of_lt_of_gt (hab : a ≤ b)
    (hf : ∀ x ∈ Icc a b, HasDerivWithinAt f (f' x) (Icc a b) x) {m : ℝ} (hma : m < f' a)
    (hmb : f' b < m) : m ∈ f' '' Ioo a b :=
  let ⟨c, cmem, hc⟩ :=
    exists_hasDerivWithinAt_eq_of_gt_of_lt hab (fun x hx => (hf x hx).neg) (neg_lt_neg hma)
      (neg_lt_neg hmb)
  ⟨c, cmem, neg_injective hc⟩
#align exists_has_deriv_within_at_eq_of_lt_of_gt exists_hasDerivWithinAt_eq_of_lt_of_gt
-/

#print Set.OrdConnected.image_hasDerivWithinAt /-
/-- **Darboux's theorem**: the image of an `ord_connected` set under `f'` is an `ord_connected`
set, `has_deriv_within_at` version. -/
theorem Set.OrdConnected.image_hasDerivWithinAt {s : Set ℝ} (hs : OrdConnected s)
    (hf : ∀ x ∈ s, HasDerivWithinAt f (f' x) s x) : OrdConnected (f' '' s) :=
  by
  apply ord_connected_of_Ioo
  rintro _ ⟨a, ha, rfl⟩ _ ⟨b, hb, rfl⟩ - m ⟨hma, hmb⟩
  cases' le_total a b with hab hab
  · have : Icc a b ⊆ s := hs.out ha hb
    rcases exists_hasDerivWithinAt_eq_of_gt_of_lt hab (fun x hx => (hf x <| this hx).mono this) hma
        hmb with
      ⟨c, cmem, hc⟩
    exact ⟨c, this <| Ioo_subset_Icc_self cmem, hc⟩
  · have : Icc b a ⊆ s := hs.out hb ha
    rcases exists_hasDerivWithinAt_eq_of_lt_of_gt hab (fun x hx => (hf x <| this hx).mono this) hmb
        hma with
      ⟨c, cmem, hc⟩
    exact ⟨c, this <| Ioo_subset_Icc_self cmem, hc⟩
#align set.ord_connected.image_has_deriv_within_at Set.OrdConnected.image_hasDerivWithinAt
-/

#print Set.OrdConnected.image_derivWithin /-
/-- **Darboux's theorem**: the image of an `ord_connected` set under `f'` is an `ord_connected`
set, `deriv_within` version. -/
theorem Set.OrdConnected.image_derivWithin {s : Set ℝ} (hs : OrdConnected s)
    (hf : DifferentiableOn ℝ f s) : OrdConnected (derivWithin f s '' s) :=
  hs.image_hasDerivWithinAt fun x hx => (hf x hx).HasDerivWithinAt
#align set.ord_connected.image_deriv_within Set.OrdConnected.image_derivWithin
-/

#print Set.OrdConnected.image_deriv /-
/-- **Darboux's theorem**: the image of an `ord_connected` set under `f'` is an `ord_connected`
set, `deriv` version. -/
theorem Set.OrdConnected.image_deriv {s : Set ℝ} (hs : OrdConnected s)
    (hf : ∀ x ∈ s, DifferentiableAt ℝ f x) : OrdConnected (deriv f '' s) :=
  hs.image_hasDerivWithinAt fun x hx => (hf x hx).HasDerivAt.HasDerivWithinAt
#align set.ord_connected.image_deriv Set.OrdConnected.image_deriv
-/

#print Convex.image_hasDerivWithinAt /-
/-- **Darboux's theorem**: the image of a convex set under `f'` is a convex set,
`has_deriv_within_at` version. -/
theorem Convex.image_hasDerivWithinAt {s : Set ℝ} (hs : Convex ℝ s)
    (hf : ∀ x ∈ s, HasDerivWithinAt f (f' x) s x) : Convex ℝ (f' '' s) :=
  (hs.OrdConnected.image_hasDerivWithinAt hf).Convex
#align convex.image_has_deriv_within_at Convex.image_hasDerivWithinAt
-/

#print Convex.image_derivWithin /-
/-- **Darboux's theorem**: the image of a convex set under `f'` is a convex set,
`deriv_within` version. -/
theorem Convex.image_derivWithin {s : Set ℝ} (hs : Convex ℝ s) (hf : DifferentiableOn ℝ f s) :
    Convex ℝ (derivWithin f s '' s) :=
  (hs.OrdConnected.image_derivWithin hf).Convex
#align convex.image_deriv_within Convex.image_derivWithin
-/

#print Convex.image_deriv /-
/-- **Darboux's theorem**: the image of a convex set under `f'` is a convex set,
`deriv` version. -/
theorem Convex.image_deriv {s : Set ℝ} (hs : Convex ℝ s) (hf : ∀ x ∈ s, DifferentiableAt ℝ f x) :
    Convex ℝ (deriv f '' s) :=
  (hs.OrdConnected.image_deriv hf).Convex
#align convex.image_deriv Convex.image_deriv
-/

#print exists_hasDerivWithinAt_eq_of_ge_of_le /-
/-- **Darboux's theorem**: if `a ≤ b` and `f' a ≤ m ≤ f' b`, then `f' c = m` for some
`c ∈ [a, b]`. -/
theorem exists_hasDerivWithinAt_eq_of_ge_of_le (hab : a ≤ b)
    (hf : ∀ x ∈ Icc a b, HasDerivWithinAt f (f' x) (Icc a b) x) {m : ℝ} (hma : f' a ≤ m)
    (hmb : m ≤ f' b) : m ∈ f' '' Icc a b :=
  (ordConnected_Icc.image_hasDerivWithinAt hf).out (mem_image_of_mem _ (left_mem_Icc.2 hab))
    (mem_image_of_mem _ (right_mem_Icc.2 hab)) ⟨hma, hmb⟩
#align exists_has_deriv_within_at_eq_of_ge_of_le exists_hasDerivWithinAt_eq_of_ge_of_le
-/

#print exists_hasDerivWithinAt_eq_of_le_of_ge /-
/-- **Darboux's theorem**: if `a ≤ b` and `f' b ≤ m ≤ f' a`, then `f' c = m` for some
`c ∈ [a, b]`. -/
theorem exists_hasDerivWithinAt_eq_of_le_of_ge (hab : a ≤ b)
    (hf : ∀ x ∈ Icc a b, HasDerivWithinAt f (f' x) (Icc a b) x) {m : ℝ} (hma : f' a ≤ m)
    (hmb : m ≤ f' b) : m ∈ f' '' Icc a b :=
  (ordConnected_Icc.image_hasDerivWithinAt hf).out (mem_image_of_mem _ (left_mem_Icc.2 hab))
    (mem_image_of_mem _ (right_mem_Icc.2 hab)) ⟨hma, hmb⟩
#align exists_has_deriv_within_at_eq_of_le_of_ge exists_hasDerivWithinAt_eq_of_le_of_ge
-/

#print hasDerivWithinAt_forall_lt_or_forall_gt_of_forall_ne /-
/-- If the derivative of a function is never equal to `m`, then either
it is always greater than `m`, or it is always less than `m`. -/
theorem hasDerivWithinAt_forall_lt_or_forall_gt_of_forall_ne {s : Set ℝ} (hs : Convex ℝ s)
    (hf : ∀ x ∈ s, HasDerivWithinAt f (f' x) s x) {m : ℝ} (hf' : ∀ x ∈ s, f' x ≠ m) :
    (∀ x ∈ s, f' x < m) ∨ ∀ x ∈ s, m < f' x :=
  by
  contrapose! hf'
  rcases hf' with ⟨⟨b, hb, hmb⟩, ⟨a, ha, hma⟩⟩
  exact
    (hs.ord_connected.image_has_deriv_within_at hf).out (mem_image_of_mem f' ha)
      (mem_image_of_mem f' hb) ⟨hma, hmb⟩
#align has_deriv_within_at_forall_lt_or_forall_gt_of_forall_ne hasDerivWithinAt_forall_lt_or_forall_gt_of_forall_ne
-/

