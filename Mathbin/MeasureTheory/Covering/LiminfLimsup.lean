/-
Copyright (c) 2022 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module measure_theory.covering.liminf_limsup
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Covering.DensityTheorem

/-!
# Liminf, limsup, and uniformly locally doubling measures.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file is a place to collect lemmas about liminf and limsup for subsets of a metric space
carrying a uniformly locally doubling measure.

## Main results:

 * `blimsup_cthickening_mul_ae_eq`: the limsup of the closed thickening of a sequence of subsets
   of a metric space is unchanged almost everywhere for a uniformly locally doubling measure if the
   sequence of distances is multiplied by a positive scale factor. This is a generalisation of a
   result of Cassels, appearing as Lemma 9 on page 217 of
   [J.W.S. Cassels, *Some metrical theorems in Diophantine approximation. I*](cassels1950).
 * `blimsup_thickening_mul_ae_eq`: a variant of `blimsup_cthickening_mul_ae_eq` for thickenings
   rather than closed thickenings.

-/


open Set Filter Metric MeasureTheory TopologicalSpace

open scoped NNReal ENNReal Topology

variable {α : Type _} [MetricSpace α] [SecondCountableTopology α] [MeasurableSpace α] [BorelSpace α]

variable (μ : Measure α) [IsLocallyFiniteMeasure μ] [IsUnifLocDoublingMeasure μ]

#print blimsup_cthickening_ae_le_of_eventually_mul_le_aux /-
/-- This is really an auxiliary result en route to `blimsup_cthickening_ae_le_of_eventually_mul_le`
(which is itself an auxiliary result en route to `blimsup_cthickening_mul_ae_eq`).

NB: The `set : α` type ascription is present because of issue #16932 on GitHub. -/
theorem blimsup_cthickening_ae_le_of_eventually_mul_le_aux (p : ℕ → Prop) {s : ℕ → Set α}
    (hs : ∀ i, IsClosed (s i)) {r₁ r₂ : ℕ → ℝ} (hr : Tendsto r₁ atTop (𝓝[>] 0)) (hrp : 0 ≤ r₁)
    {M : ℝ} (hM : 0 < M) (hM' : M < 1) (hMr : ∀ᶠ i in atTop, M * r₁ i ≤ r₂ i) :
    (blimsup (fun i => cthickening (r₁ i) (s i)) atTop p : Set α) ≤ᵐ[μ]
      (blimsup (fun i => cthickening (r₂ i) (s i)) atTop p : Set α) :=
  by
  /- Sketch of proof:
  
    Assume that `p` is identically true for simplicity. Let `Y₁ i = cthickening (r₁ i) (s i)`, define
    `Y₂` similarly except using `r₂`, and let `(Z i) = ⋃_{j ≥ i} (Y₂ j)`. Our goal is equivalent to
    showing that `μ ((limsup Y₁) \ (Z i)) = 0` for all `i`.
  
    Assume for contradiction that `μ ((limsup Y₁) \ (Z i)) ≠ 0` for some `i` and let
    `W = (limsup Y₁) \ (Z i)`. Apply Lebesgue's density theorem to obtain a point `d` in `W` of
    density `1`. Since `d ∈ limsup Y₁`, there is a subsequence of `j ↦ Y₁ j`, indexed by
    `f 0 < f 1 < ...`, such that `d ∈ Y₁ (f j)` for all `j`. For each `j`, we may thus choose
    `w j ∈ s (f j)` such that `d ∈ B j`, where `B j = closed_ball (w j) (r₁ (f j))`. Note that
    since `d` has density one, `μ (W ∩ (B j)) / μ (B j) → 1`.
  
    We obtain our contradiction by showing that there exists `η < 1` such that
    `μ (W ∩ (B j)) / μ (B j) ≤ η` for sufficiently large `j`. In fact we claim that `η = 1 - C⁻¹`
    is such a value where `C` is the scaling constant of `M⁻¹` for the uniformly locally doubling
    measure `μ`.
  
    To prove the claim, let `b j = closed_ball (w j) (M * r₁ (f j))` and for given `j` consider the
    sets `b j` and `W ∩ (B j)`. These are both subsets of `B j` and are disjoint for large enough `j`
    since `M * r₁ j ≤ r₂ j` and thus `b j ⊆ Z i ⊆ Wᶜ`. We thus have:
    `μ (b j) + μ (W ∩ (B j)) ≤ μ (B j)`. Combining this with `μ (B j) ≤ C * μ (b j)` we obtain
    the required inequality. -/
  set Y₁ : ℕ → Set α := fun i => cthickening (r₁ i) (s i)
  set Y₂ : ℕ → Set α := fun i => cthickening (r₂ i) (s i)
  let Z : ℕ → Set α := fun i => ⋃ (j) (h : p j ∧ i ≤ j), Y₂ j
  suffices ∀ i, μ (at_top.blimsup Y₁ p \ Z i) = 0 by
    rwa [ae_le_set, @blimsup_eq_infi_bsupr_of_nat _ _ _ Y₂, infi_eq_Inter, diff_Inter,
      measure_Union_null_iff]
  intros
  set W := at_top.blimsup Y₁ p \ Z i
  by_contra contra
  obtain ⟨d, hd, hd'⟩ :
    ∃ d,
      d ∈ W ∧
        ∀ {ι : Type _} {l : Filter ι} (w : ι → α) (δ : ι → ℝ),
          tendsto δ l (𝓝[>] 0) →
            (∀ᶠ j in l, d ∈ closed_ball (w j) (2 * δ j)) →
              tendsto (fun j => μ (W ∩ closed_ball (w j) (δ j)) / μ (closed_ball (w j) (δ j))) l
                (𝓝 1) :=
    measure.exists_mem_of_measure_ne_zero_of_ae contra
      (IsUnifLocDoublingMeasure.ae_tendsto_measure_inter_div μ W 2)
  replace hd : d ∈ blimsup Y₁ at_top p := ((mem_diff _).mp hd).1
  obtain ⟨f : ℕ → ℕ, hf⟩ := exists_forall_mem_of_has_basis_mem_blimsup' at_top_basis hd
  simp only [forall_and] at hf 
  obtain ⟨hf₀ : ∀ j, d ∈ cthickening (r₁ (f j)) (s (f j)), hf₁, hf₂ : ∀ j, j ≤ f j⟩ := hf
  have hf₃ : tendsto f at_top at_top :=
    tendsto_at_top_at_top.mpr fun j => ⟨f j, fun i hi => (hf₂ j).trans (hi.trans <| hf₂ i)⟩
  replace hr : tendsto (r₁ ∘ f) at_top (𝓝[>] 0) := hr.comp hf₃
  replace hMr : ∀ᶠ j in at_top, M * r₁ (f j) ≤ r₂ (f j) := hf₃.eventually hMr
  replace hf₀ : ∀ j, ∃ w ∈ s (f j), d ∈ closed_ball w (2 * r₁ (f j))
  · intro j
    specialize hrp (f j)
    rw [Pi.zero_apply] at hrp 
    rcases eq_or_lt_of_le hrp with (hr0 | hrp')
    · specialize hf₀ j
      rw [← hr0, cthickening_zero, (hs (f j)).closure_eq] at hf₀ 
      exact ⟨d, hf₀, by simp [← hr0]⟩
    ·
      exact
        mem_Union₂.mp
          (cthickening_subset_Union_closed_ball_of_lt (s (f j)) (by positivity)
            (lt_two_mul_self hrp') (hf₀ j))
  choose w hw hw' using hf₀
  let C := IsUnifLocDoublingMeasure.scalingConstantOf μ M⁻¹
  have hC : 0 < C :=
    lt_of_lt_of_le zero_lt_one (IsUnifLocDoublingMeasure.one_le_scalingConstantOf μ M⁻¹)
  suffices
    ∃ η < (1 : ℝ≥0),
      ∀ᶠ j in at_top, μ (W ∩ closed_ball (w j) (r₁ (f j))) / μ (closed_ball (w j) (r₁ (f j))) ≤ η
    by
    obtain ⟨η, hη, hη'⟩ := this
    replace hη' : 1 ≤ η := by
      simpa only [ENNReal.one_le_coe_iff] using
        le_of_tendsto (hd' w (fun j => r₁ (f j)) hr <| eventually_of_forall hw') hη'
    exact (lt_self_iff_false _).mp (lt_of_lt_of_le hη hη')
  refine' ⟨1 - C⁻¹, tsub_lt_self zero_lt_one (inv_pos.mpr hC), _⟩
  replace hC : C ≠ 0 := ne_of_gt hC
  let b : ℕ → Set α := fun j => closed_ball (w j) (M * r₁ (f j))
  let B : ℕ → Set α := fun j => closed_ball (w j) (r₁ (f j))
  have h₁ : ∀ j, b j ⊆ B j := fun j =>
    closed_ball_subset_closed_ball (mul_le_of_le_one_left (hrp (f j)) hM'.le)
  have h₂ : ∀ j, W ∩ B j ⊆ B j := fun j => inter_subset_right W (B j)
  have h₃ : ∀ᶠ j in at_top, Disjoint (b j) (W ∩ B j) :=
    by
    apply hMr.mp
    rw [eventually_at_top]
    refine'
      ⟨i, fun j hj hj' => Disjoint.inf_right (B j) <| Disjoint.inf_right' (blimsup Y₁ at_top p) _⟩
    change Disjoint (b j) (Z iᶜ)
    rw [disjoint_compl_right_iff_subset]
    refine'
      (closed_ball_subset_cthickening (hw j) (M * r₁ (f j))).trans
        ((cthickening_mono hj' _).trans fun a ha => _)
    simp only [mem_Union, exists_prop]
    exact ⟨f j, ⟨hf₁ j, hj.le.trans (hf₂ j)⟩, ha⟩
  have h₄ : ∀ᶠ j in at_top, μ (B j) ≤ C * μ (b j) :=
    (hr.eventually
          (IsUnifLocDoublingMeasure.eventually_measure_le_scaling_constant_mul' μ M hM)).mono
      fun j hj => hj (w j)
  refine' (h₃.and h₄).mono fun j hj₀ => _
  change μ (W ∩ B j) / μ (B j) ≤ ↑(1 - C⁻¹)
  rcases eq_or_ne (μ (B j)) ∞ with (hB | hB); · simp [hB]
  apply ENNReal.div_le_of_le_mul
  rw [WithTop.coe_sub, ENNReal.coe_one, ENNReal.sub_mul fun _ _ => hB, one_mul]
  replace hB : ↑C⁻¹ * μ (B j) ≠ ∞
  · refine' ENNReal.mul_ne_top _ hB
    rwa [ENNReal.coe_inv hC, Ne.def, ENNReal.inv_eq_top, ENNReal.coe_eq_zero]
  obtain ⟨hj₁ : Disjoint (b j) (W ∩ B j), hj₂ : μ (B j) ≤ C * μ (b j)⟩ := hj₀
  replace hj₂ : ↑C⁻¹ * μ (B j) ≤ μ (b j)
  · rw [ENNReal.coe_inv hC, ← ENNReal.div_eq_inv_mul]
    exact ENNReal.div_le_of_le_mul' hj₂
  have hj₃ : ↑C⁻¹ * μ (B j) + μ (W ∩ B j) ≤ μ (B j) :=
    by
    refine' le_trans (add_le_add_right hj₂ _) _
    rw [← measure_union' hj₁ measurableSet_closedBall]
    exact measure_mono (union_subset (h₁ j) (h₂ j))
  replace hj₃ := tsub_le_tsub_right hj₃ (↑C⁻¹ * μ (B j))
  rwa [ENNReal.add_sub_cancel_left hB] at hj₃ 
#align blimsup_cthickening_ae_le_of_eventually_mul_le_aux blimsup_cthickening_ae_le_of_eventually_mul_le_aux
-/

#print blimsup_cthickening_ae_le_of_eventually_mul_le /-
/-- This is really an auxiliary result en route to `blimsup_cthickening_mul_ae_eq`.

NB: The `set : α` type ascription is present because of issue #16932 on GitHub. -/
theorem blimsup_cthickening_ae_le_of_eventually_mul_le (p : ℕ → Prop) {s : ℕ → Set α} {M : ℝ}
    (hM : 0 < M) {r₁ r₂ : ℕ → ℝ} (hr : Tendsto r₁ atTop (𝓝[>] 0))
    (hMr : ∀ᶠ i in atTop, M * r₁ i ≤ r₂ i) :
    (blimsup (fun i => cthickening (r₁ i) (s i)) atTop p : Set α) ≤ᵐ[μ]
      (blimsup (fun i => cthickening (r₂ i) (s i)) atTop p : Set α) :=
  by
  let R₁ i := max 0 (r₁ i)
  let R₂ i := max 0 (r₂ i)
  have hRp : 0 ≤ R₁ := fun i => le_max_left 0 (r₁ i)
  replace hMr : ∀ᶠ i in at_top, M * R₁ i ≤ R₂ i
  · refine' hMr.mono fun i hi => _
    rw [mul_max_of_nonneg _ _ hM.le, MulZeroClass.mul_zero]
    exact max_le_max (le_refl 0) hi
  simp_rw [← cthickening_max_zero (r₁ _), ← cthickening_max_zero (r₂ _)]
  cases' le_or_lt 1 M with hM' hM'
  · apply HasSubset.Subset.eventuallyLE
    change _ ≤ _
    refine' mono_blimsup' (hMr.mono fun i hi hp => cthickening_mono _ (s i))
    exact (le_mul_of_one_le_left (hRp i) hM').trans hi
  · simp only [← @cthickening_closure _ _ _ (s _)]
    have hs : ∀ i, IsClosed (closure (s i)) := fun i => isClosed_closure
    exact
      blimsup_cthickening_ae_le_of_eventually_mul_le_aux μ p hs (tendsto_nhds_max_right hr) hRp hM
        hM' hMr
#align blimsup_cthickening_ae_le_of_eventually_mul_le blimsup_cthickening_ae_le_of_eventually_mul_le
-/

#print blimsup_cthickening_mul_ae_eq /-
/-- Given a sequence of subsets `sᵢ` of a metric space, together with a sequence of radii `rᵢ`
such that `rᵢ → 0`, the set of points which belong to infinitely many of the closed
`rᵢ`-thickenings of `sᵢ` is unchanged almost everywhere for a uniformly locally doubling measure if
the `rᵢ` are all scaled by a positive constant.

This lemma is a generalisation of Lemma 9 appearing on page 217 of
[J.W.S. Cassels, *Some metrical theorems in Diophantine approximation. I*](cassels1950).

See also `blimsup_thickening_mul_ae_eq`.

NB: The `set : α` type ascription is present because of issue #16932 on GitHub. -/
theorem blimsup_cthickening_mul_ae_eq (p : ℕ → Prop) (s : ℕ → Set α) {M : ℝ} (hM : 0 < M)
    (r : ℕ → ℝ) (hr : Tendsto r atTop (𝓝 0)) :
    (blimsup (fun i => cthickening (M * r i) (s i)) atTop p : Set α) =ᵐ[μ]
      (blimsup (fun i => cthickening (r i) (s i)) atTop p : Set α) :=
  by
  have :
    ∀ (p : ℕ → Prop) {r : ℕ → ℝ} (hr : tendsto r at_top (𝓝[>] 0)),
      (blimsup (fun i => cthickening (M * r i) (s i)) at_top p : Set α) =ᵐ[μ]
        (blimsup (fun i => cthickening (r i) (s i)) at_top p : Set α) :=
    by
    clear p hr r; intro p r hr
    have hr' : tendsto (fun i => M * r i) at_top (𝓝[>] 0) := by
      convert tendsto_nhds_within_Ioi.const_mul hM hr <;> simp only [MulZeroClass.mul_zero]
    refine' eventually_le_antisymm_iff.mpr ⟨_, _⟩
    ·
      exact
        blimsup_cthickening_ae_le_of_eventually_mul_le μ p (inv_pos.mpr hM) hr'
          (eventually_of_forall fun i => by rw [inv_mul_cancel_left₀ hM.ne' (r i)])
    ·
      exact
        blimsup_cthickening_ae_le_of_eventually_mul_le μ p hM hr
          (eventually_of_forall fun i => le_refl _)
  let r' : ℕ → ℝ := fun i => if 0 < r i then r i else 1 / ((i : ℝ) + 1)
  have hr' : tendsto r' at_top (𝓝[>] 0) :=
    by
    refine'
      tendsto_nhds_within_iff.mpr
        ⟨tendsto.if' hr tendsto_one_div_add_atTop_nhds_0_nat, eventually_of_forall fun i => _⟩
    by_cases hi : 0 < r i
    · simp [hi, r']
    · simp only [hi, r', one_div, mem_Ioi, if_false, inv_pos]; positivity
  have h₀ : ∀ i, p i ∧ 0 < r i → cthickening (r i) (s i) = cthickening (r' i) (s i) := by
    rintro i ⟨-, hi⟩; congr; change r i = ite (0 < r i) (r i) _; simp [hi]
  have h₁ : ∀ i, p i ∧ 0 < r i → cthickening (M * r i) (s i) = cthickening (M * r' i) (s i) := by
    rintro i ⟨-, hi⟩; simp only [hi, mul_ite, if_true]
  have h₂ : ∀ i, p i ∧ r i ≤ 0 → cthickening (M * r i) (s i) = cthickening (r i) (s i) :=
    by
    rintro i ⟨-, hi⟩
    have hi' : M * r i ≤ 0 := mul_nonpos_of_nonneg_of_nonpos hM.le hi
    rw [cthickening_of_nonpos hi, cthickening_of_nonpos hi']
  have hp : p = fun i => p i ∧ 0 < r i ∨ p i ∧ r i ≤ 0 := by ext i;
    simp [← and_or_left, lt_or_le 0 (r i)]
  rw [hp, blimsup_or_eq_sup, blimsup_or_eq_sup, sup_eq_union,
    blimsup_congr (eventually_of_forall h₀), blimsup_congr (eventually_of_forall h₁),
    blimsup_congr (eventually_of_forall h₂)]
  exact ae_eq_set_union (this (fun i => p i ∧ 0 < r i) hr') (ae_eq_refl _)
#align blimsup_cthickening_mul_ae_eq blimsup_cthickening_mul_ae_eq
-/

#print blimsup_cthickening_ae_eq_blimsup_thickening /-
theorem blimsup_cthickening_ae_eq_blimsup_thickening {p : ℕ → Prop} {s : ℕ → Set α} {r : ℕ → ℝ}
    (hr : Tendsto r atTop (𝓝 0)) (hr' : ∀ᶠ i in atTop, p i → 0 < r i) :
    (blimsup (fun i => cthickening (r i) (s i)) atTop p : Set α) =ᵐ[μ]
      (blimsup (fun i => thickening (r i) (s i)) atTop p : Set α) :=
  by
  refine' eventually_le_antisymm_iff.mpr ⟨_, HasSubset.Subset.eventuallyLE (_ : _ ≤ _)⟩
  · rw [eventually_le_congr (blimsup_cthickening_mul_ae_eq μ p s (@one_half_pos ℝ _) r hr).symm
        eventually_eq.rfl]
    apply HasSubset.Subset.eventuallyLE
    change _ ≤ _
    refine' mono_blimsup' (hr'.mono fun i hi pi => cthickening_subset_thickening' (hi pi) _ (s i))
    nlinarith [hi pi]
  · exact mono_blimsup fun i pi => thickening_subset_cthickening _ _
#align blimsup_cthickening_ae_eq_blimsup_thickening blimsup_cthickening_ae_eq_blimsup_thickening
-/

#print blimsup_thickening_mul_ae_eq_aux /-
/-- An auxiliary result en route to `blimsup_thickening_mul_ae_eq`. -/
theorem blimsup_thickening_mul_ae_eq_aux (p : ℕ → Prop) (s : ℕ → Set α) {M : ℝ} (hM : 0 < M)
    (r : ℕ → ℝ) (hr : Tendsto r atTop (𝓝 0)) (hr' : ∀ᶠ i in atTop, p i → 0 < r i) :
    (blimsup (fun i => thickening (M * r i) (s i)) atTop p : Set α) =ᵐ[μ]
      (blimsup (fun i => thickening (r i) (s i)) atTop p : Set α) :=
  by
  have h₁ := blimsup_cthickening_ae_eq_blimsup_thickening μ hr hr'
  have h₂ := blimsup_cthickening_mul_ae_eq μ p s hM r hr
  replace hr : tendsto (fun i => M * r i) at_top (𝓝 0); · convert hr.const_mul M; simp
  replace hr' : ∀ᶠ i in at_top, p i → 0 < M * r i := hr'.mono fun i hi hip => mul_pos hM (hi hip)
  have h₃ := blimsup_cthickening_ae_eq_blimsup_thickening μ hr hr'
  exact h₃.symm.trans (h₂.trans h₁)
#align blimsup_thickening_mul_ae_eq_aux blimsup_thickening_mul_ae_eq_aux
-/

#print blimsup_thickening_mul_ae_eq /-
/-- Given a sequence of subsets `sᵢ` of a metric space, together with a sequence of radii `rᵢ`
such that `rᵢ → 0`, the set of points which belong to infinitely many of the
`rᵢ`-thickenings of `sᵢ` is unchanged almost everywhere for a uniformly locally doubling measure if
the `rᵢ` are all scaled by a positive constant.

This lemma is a generalisation of Lemma 9 appearing on page 217 of
[J.W.S. Cassels, *Some metrical theorems in Diophantine approximation. I*](cassels1950).

See also `blimsup_cthickening_mul_ae_eq`.

NB: The `set : α` type ascription is present because of issue #16932 on GitHub. -/
theorem blimsup_thickening_mul_ae_eq (p : ℕ → Prop) (s : ℕ → Set α) {M : ℝ} (hM : 0 < M) (r : ℕ → ℝ)
    (hr : Tendsto r atTop (𝓝 0)) :
    (blimsup (fun i => thickening (M * r i) (s i)) atTop p : Set α) =ᵐ[μ]
      (blimsup (fun i => thickening (r i) (s i)) atTop p : Set α) :=
  by
  let q : ℕ → Prop := fun i => p i ∧ 0 < r i
  have h₁ :
    blimsup (fun i => thickening (r i) (s i)) at_top p =
      blimsup (fun i => thickening (r i) (s i)) at_top q :=
    by
    refine' blimsup_congr' (eventually_of_forall fun i h => _)
    replace hi : 0 < r i; · contrapose! h; apply thickening_of_nonpos h
    simp only [hi, iff_self_and, imp_true_iff]
  have h₂ :
    blimsup (fun i => thickening (M * r i) (s i)) at_top p =
      blimsup (fun i => thickening (M * r i) (s i)) at_top q :=
    by
    refine' blimsup_congr' (eventually_of_forall fun i h => _)
    replace h : 0 < r i; · rw [← zero_lt_mul_left hM]; contrapose! h; apply thickening_of_nonpos h
    simp only [h, iff_self_and, imp_true_iff]
  rw [h₁, h₂]
  exact blimsup_thickening_mul_ae_eq_aux μ q s hM r hr (eventually_of_forall fun i hi => hi.2)
#align blimsup_thickening_mul_ae_eq blimsup_thickening_mul_ae_eq
-/

