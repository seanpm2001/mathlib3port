/-
Copyright (c) 2021 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module measure_theory.covering.differentiation
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Covering.VitaliFamily
import Mathbin.MeasureTheory.Measure.Regular
import Mathbin.MeasureTheory.Function.AeMeasurableOrder
import Mathbin.MeasureTheory.Integral.Lebesgue
import Mathbin.MeasureTheory.Integral.Average
import Mathbin.MeasureTheory.Decomposition.Lebesgue

/-!
# Differentiation of measures

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

On a second countable metric space with a measure `μ`, consider a Vitali family (i.e., for each `x`
one has a family of sets shrinking to `x`, with a good behavior with respect to covering theorems).
Consider also another measure `ρ`. Then, for almost every `x`, the ratio `ρ a / μ a` converges when
`a` shrinks to `x` along the Vitali family, towards the Radon-Nikodym derivative of `ρ` with
respect to `μ`. This is the main theorem on differentiation of measures.

This theorem is proved in this file, under the name `vitali_family.ae_tendsto_rn_deriv`. Note that,
almost surely, `μ a` is eventually positive and finite (see
`vitali_family.ae_eventually_measure_pos` and `vitali_family.eventually_measure_lt_top`), so the
ratio really makes sense.

For concrete applications, one needs concrete instances of Vitali families, as provided for instance
by `besicovitch.vitali_family` (for balls) or by `vitali.vitali_family` (for doubling measures).

Specific applications to Lebesgue density points and the Lebesgue differentiation theorem are also
derived:
* `vitali_family.ae_tendsto_measure_inter_div` states that, for almost every point `x ∈ s`,
  then `μ (s ∩ a) / μ a` tends to `1` as `a` shrinks to `x` along a Vitali family.
* `vitali_family.ae_tendsto_average_norm_sub` states that, for almost every point `x`, then the
  average of `y ↦ ‖f y - f x‖` on `a` tends to `0` as `a` shrinks to `x` along a Vitali family.

## Sketch of proof

Let `v` be a Vitali family for `μ`. Assume for simplicity that `ρ` is absolutely continuous with
respect to `μ`, as the case of a singular measure is easier.

It is easy to see that a set `s` on which `liminf ρ a / μ a < q` satisfies `ρ s ≤ q * μ s`, by using
a disjoint subcovering provided by the definition of Vitali families. Similarly for the limsup.
It follows that a set on which `ρ a / μ a` oscillates has measure `0`, and therefore that
`ρ a / μ a` converges almost surely (`vitali_family.ae_tendsto_div`). Moreover, on a set where the
limit is close to a constant `c`, one gets `ρ s ∼ c μ s`, using again a covering lemma as above.
It follows that `ρ` is equal to `μ.with_density (v.lim_ratio ρ x)`, where `v.lim_ratio ρ x` is the
limit of `ρ a / μ a` at `x` (which is well defined almost everywhere). By uniqueness of the
Radon-Nikodym derivative, one gets `v.lim_ratio ρ x = ρ.rn_deriv μ x` almost everywhere, completing
the proof.

There is a difficulty in this sketch: this argument works well when `v.lim_ratio ρ` is measurable,
but there is no guarantee that this is the case, especially if one doesn't make further assumptions
on the Vitali family. We use an indirect argument to show that `v.lim_ratio ρ` is always
almost everywhere measurable, again based on the disjoint subcovering argument
(see `vitali_family.exists_measurable_supersets_lim_ratio`), and then proceed as sketched above
but replacing `v.lim_ratio ρ` by a measurable version called `v.lim_ratio_meas ρ`.

## Counterexample

The standing assumption in this file is that spaces are second countable. Without this assumption,
measures may be zero locally but nonzero globally, which is not compatible with differentiation
theory (which deduces global information from local one). Here is an example displaying this
behavior.

Define a measure `μ` by `μ s = 0` if `s` is covered by countably many balls of radius `1`,
and `μ s = ∞` otherwise. This is indeed a countably additive measure, which is moreover
locally finite and doubling at small scales. It vanishes on every ball of radius `1`, so all the
quantities in differentiation theory (defined as ratios of measures as the radius tends to zero)
make no sense. However, the measure is not globally zero if the space is big enough.

## References

* [Herbert Federer, Geometric Measure Theory, Chapter 2.9][Federer1996]
-/


open MeasureTheory Metric Set Filter TopologicalSpace MeasureTheory.Measure

open scoped Filter ENNReal MeasureTheory NNReal Topology

variable {α : Type _} [MetricSpace α] {m0 : MeasurableSpace α} {μ : Measure α} (v : VitaliFamily μ)
  {E : Type _} [NormedAddCommGroup E]

namespace VitaliFamily

#print VitaliFamily.limRatio /-
/-- The limit along a Vitali family of `ρ a / μ a` where it makes sense, and garbage otherwise.
Do *not* use this definition: it is only a temporary device to show that this ratio tends almost
everywhere to the Radon-Nikodym derivative. -/
noncomputable def limRatio (ρ : Measure α) (x : α) : ℝ≥0∞ :=
  limUnder (v.filterAt x) fun a => ρ a / μ a
#align vitali_family.lim_ratio VitaliFamily.limRatio
-/

#print VitaliFamily.ae_eventually_measure_pos /-
/-- For almost every point `x`, sufficiently small sets in a Vitali family around `x` have positive
measure. (This is a nontrivial result, following from the covering property of Vitali families). -/
theorem ae_eventually_measure_pos [SecondCountableTopology α] :
    ∀ᵐ x ∂μ, ∀ᶠ a in v.filterAt x, 0 < μ a :=
  by
  set s := {x | ¬∀ᶠ a in v.filter_at x, 0 < μ a} with hs
  simp only [not_lt, not_eventually, nonpos_iff_eq_zero] at hs 
  change μ s = 0
  let f : α → Set (Set α) := fun x => {a | μ a = 0}
  have h : v.fine_subfamily_on f s := by
    intro x hx ε εpos
    rw [hs] at hx 
    simp only [frequently_filter_at_iff, exists_prop, gt_iff_lt, mem_set_of_eq] at hx 
    rcases hx ε εpos with ⟨a, a_sets, ax, μa⟩
    exact ⟨a, ⟨a_sets, μa⟩, ax⟩
  refine' le_antisymm _ bot_le
  calc
    μ s ≤ ∑' x : h.index, μ (h.covering x) := h.measure_le_tsum
    _ = ∑' x : h.index, 0 := by congr; ext1 x; exact h.covering_mem x.2
    _ = 0 := by simp only [tsum_zero, add_zero]
#align vitali_family.ae_eventually_measure_pos VitaliFamily.ae_eventually_measure_pos
-/

#print VitaliFamily.eventually_measure_lt_top /-
/-- For every point `x`, sufficiently small sets in a Vitali family around `x` have finite measure.
(This is a trivial result, following from the fact that the measure is locally finite). -/
theorem eventually_measure_lt_top [IsLocallyFiniteMeasure μ] (x : α) :
    ∀ᶠ a in v.filterAt x, μ a < ∞ :=
  by
  obtain ⟨ε, εpos, με⟩ : ∃ (ε : ℝ) (hi : 0 < ε), μ (closed_ball x ε) < ∞ :=
    (μ.finite_at_nhds x).exists_mem_basis nhds_basis_closed_ball
  exact v.eventually_filter_at_iff.2 ⟨ε, εpos, fun a ha haε => (measure_mono haε).trans_lt με⟩
#align vitali_family.eventually_measure_lt_top VitaliFamily.eventually_measure_lt_top
-/

#print VitaliFamily.measure_le_of_frequently_le /-
/-- If two measures `ρ` and `ν` have, at every point of a set `s`, arbitrarily small sets in a
Vitali family satisfying `ρ a ≤ ν a`, then `ρ s ≤ ν s` if `ρ ≪ μ`.-/
theorem measure_le_of_frequently_le [SecondCountableTopology α] [BorelSpace α] {ρ : Measure α}
    (ν : Measure α) [IsLocallyFiniteMeasure ν] (hρ : ρ ≪ μ) (s : Set α)
    (hs : ∀ x ∈ s, ∃ᶠ a in v.filterAt x, ρ a ≤ ν a) : ρ s ≤ ν s :=
  by
  -- this follows from a covering argument using the sets satisfying `ρ a ≤ ν a`.
  apply ENNReal.le_of_forall_pos_le_add fun ε εpos hc => _
  obtain ⟨U, sU, U_open, νU⟩ : ∃ (U : Set α) (H : s ⊆ U), IsOpen U ∧ ν U ≤ ν s + ε :=
    exists_is_open_le_add s ν (ENNReal.coe_pos.2 εpos).ne'
  let f : α → Set (Set α) := fun x => {a | ρ a ≤ ν a ∧ a ⊆ U}
  have h : v.fine_subfamily_on f s :=
    by
    apply v.fine_subfamily_on_of_frequently f s fun x hx => _
    have :=
      (hs x hx).and_eventually
        ((v.eventually_filter_at_mem_sets x).And
          (v.eventually_filter_at_subset_of_nhds (U_open.mem_nhds (sU hx))))
    apply frequently.mono this
    rintro a ⟨ρa, av, aU⟩
    exact ⟨ρa, aU⟩
  haveI : Encodable h.index := h.index_countable.to_encodable
  calc
    ρ s ≤ ∑' x : h.index, ρ (h.covering x) := h.measure_le_tsum_of_absolutely_continuous hρ
    _ ≤ ∑' x : h.index, ν (h.covering x) := (ENNReal.tsum_le_tsum fun x => (h.covering_mem x.2).1)
    _ = ν (⋃ x : h.index, h.covering x) := by
      rw [measure_Union h.covering_disjoint_subtype fun i => h.measurable_set_u i.2]
    _ ≤ ν U := (measure_mono (Union_subset fun i => (h.covering_mem i.2).2))
    _ ≤ ν s + ε := νU
#align vitali_family.measure_le_of_frequently_le VitaliFamily.measure_le_of_frequently_le
-/

section

variable [SecondCountableTopology α] [BorelSpace α] [IsLocallyFiniteMeasure μ] {ρ : Measure α}
  [IsLocallyFiniteMeasure ρ]

#print VitaliFamily.ae_eventually_measure_zero_of_singular /-
/-- If a measure `ρ` is singular with respect to `μ`, then for `μ` almost every `x`, the ratio
`ρ a / μ a` tends to zero when `a` shrinks to `x` along the Vitali family. This makes sense
as `μ a` is eventually positive by `ae_eventually_measure_pos`. -/
theorem ae_eventually_measure_zero_of_singular (hρ : ρ ⟂ₘ μ) :
    ∀ᵐ x ∂μ, Tendsto (fun a => ρ a / μ a) (v.filterAt x) (𝓝 0) :=
  by
  have A : ∀ ε > (0 : ℝ≥0), ∀ᵐ x ∂μ, ∀ᶠ a in v.filter_at x, ρ a < ε * μ a :=
    by
    intro ε εpos
    set s := {x | ¬∀ᶠ a in v.filter_at x, ρ a < ε * μ a} with hs
    change μ s = 0
    obtain ⟨o, o_meas, ρo, μo⟩ : ∃ o : Set α, MeasurableSet o ∧ ρ o = 0 ∧ μ (oᶜ) = 0 := hρ
    apply le_antisymm _ bot_le
    calc
      μ s ≤ μ (s ∩ o ∪ oᶜ) := by
        conv_lhs => rw [← inter_union_compl s o]
        exact measure_mono (union_subset_union_right _ (inter_subset_right _ _))
      _ ≤ μ (s ∩ o) + μ (oᶜ) := (measure_union_le _ _)
      _ = μ (s ∩ o) := by rw [μo, add_zero]
      _ = ε⁻¹ * (ε • μ) (s ∩ o) :=
        by
        simp only [coe_nnreal_smul_apply, ← mul_assoc, mul_comm _ (ε : ℝ≥0∞)]
        rw [ENNReal.mul_inv_cancel (ENNReal.coe_pos.2 εpos).ne' ENNReal.coe_ne_top, one_mul]
      _ ≤ ε⁻¹ * ρ (s ∩ o) := by
        refine' mul_le_mul_left' _ _
        refine' v.measure_le_of_frequently_le ρ ((measure.absolutely_continuous.refl μ).smul ε) _ _
        intro x hx
        rw [hs] at hx 
        simp only [mem_inter_iff, not_lt, not_eventually, mem_set_of_eq] at hx 
        exact hx.1
      _ ≤ ε⁻¹ * ρ o := (mul_le_mul_left' (measure_mono (inter_subset_right _ _)) _)
      _ = 0 := by rw [ρo, MulZeroClass.mul_zero]
  obtain ⟨u, u_anti, u_pos, u_lim⟩ :
    ∃ u : ℕ → ℝ≥0, StrictAnti u ∧ (∀ n : ℕ, 0 < u n) ∧ tendsto u at_top (𝓝 0) :=
    exists_seq_strictAnti_tendsto (0 : ℝ≥0)
  have B : ∀ᵐ x ∂μ, ∀ n, ∀ᶠ a in v.filter_at x, ρ a < u n * μ a :=
    ae_all_iff.2 fun n => A (u n) (u_pos n)
  filter_upwards [B, v.ae_eventually_measure_pos]
  intro x hx h'x
  refine' tendsto_order.2 ⟨fun z hz => (ENNReal.not_lt_zero hz).elim, fun z hz => _⟩
  obtain ⟨w, w_pos, w_lt⟩ : ∃ w : ℝ≥0, (0 : ℝ≥0∞) < w ∧ (w : ℝ≥0∞) < z :=
    ENNReal.lt_iff_exists_nnreal_btwn.1 hz
  obtain ⟨n, hn⟩ : ∃ n, u n < w := ((tendsto_order.1 u_lim).2 w (ENNReal.coe_pos.1 w_pos)).exists
  filter_upwards [hx n, h'x, v.eventually_measure_lt_top x]
  intro a ha μa_pos μa_lt_top
  rw [ENNReal.div_lt_iff (Or.inl μa_pos.ne') (Or.inl μa_lt_top.ne)]
  exact ha.trans_le (mul_le_mul_right' ((ENNReal.coe_le_coe.2 hn.le).trans w_lt.le) _)
#align vitali_family.ae_eventually_measure_zero_of_singular VitaliFamily.ae_eventually_measure_zero_of_singular
-/

section AbsolutelyContinuous

variable (hρ : ρ ≪ μ)

#print VitaliFamily.null_of_frequently_le_of_frequently_ge /-
/-- A set of points `s` satisfying both `ρ a ≤ c * μ a` and `ρ a ≥ d * μ a` at arbitrarily small
sets in a Vitali family has measure `0` if `c < d`. Indeed, the first inequality should imply
that `ρ s ≤ c * μ s`, and the second one that `ρ s ≥ d * μ s`, a contradiction if `0 < μ s`. -/
theorem null_of_frequently_le_of_frequently_ge {c d : ℝ≥0} (hcd : c < d) (s : Set α)
    (hc : ∀ x ∈ s, ∃ᶠ a in v.filterAt x, ρ a ≤ c * μ a)
    (hd : ∀ x ∈ s, ∃ᶠ a in v.filterAt x, (d : ℝ≥0∞) * μ a ≤ ρ a) : μ s = 0 :=
  by
  apply null_of_locally_null s fun x hx => _
  obtain ⟨o, xo, o_open, μo⟩ : ∃ o : Set α, x ∈ o ∧ IsOpen o ∧ μ o < ∞ :=
    measure.exists_is_open_measure_lt_top μ x
  refine' ⟨s ∩ o, inter_mem_nhdsWithin _ (o_open.mem_nhds xo), _⟩
  let s' := s ∩ o
  by_contra
  apply lt_irrefl (ρ s')
  calc
    ρ s' ≤ c * μ s' := v.measure_le_of_frequently_le (c • μ) hρ s' fun x hx => hc x hx.1
    _ < d * μ s' :=
      by
      apply (ENNReal.mul_lt_mul_right h _).2 (ENNReal.coe_lt_coe.2 hcd)
      exact (lt_of_le_of_lt (measure_mono (inter_subset_right _ _)) μo).Ne
    _ ≤ ρ s' :=
      v.measure_le_of_frequently_le ρ ((measure.absolutely_continuous.refl μ).smul d) s' fun x hx =>
        hd x hx.1
#align vitali_family.null_of_frequently_le_of_frequently_ge VitaliFamily.null_of_frequently_le_of_frequently_ge
-/

#print VitaliFamily.ae_tendsto_div /-
/-- If `ρ` is absolutely continuous with respect to `μ`, then for almost every `x`,
the ratio `ρ a / μ a` converges as `a` shrinks to `x` along a Vitali family for `μ`. -/
theorem ae_tendsto_div : ∀ᵐ x ∂μ, ∃ c, Tendsto (fun a => ρ a / μ a) (v.filterAt x) (𝓝 c) :=
  by
  obtain ⟨w, w_count, w_dense, w_zero, w_top⟩ :
    ∃ w : Set ℝ≥0∞, w.Countable ∧ Dense w ∧ 0 ∉ w ∧ ∞ ∉ w :=
    ENNReal.exists_countable_dense_no_zero_top
  have I : ∀ x ∈ w, x ≠ ∞ := fun x xs hx => w_top (hx ▸ xs)
  have A :
    ∀ c ∈ w,
      ∀ d ∈ w,
        c < d →
          ∀ᵐ x ∂μ,
            ¬((∃ᶠ a in v.filter_at x, ρ a / μ a < c) ∧ ∃ᶠ a in v.filter_at x, d < ρ a / μ a) :=
    by
    intro c hc d hd hcd
    lift c to ℝ≥0 using I c hc
    lift d to ℝ≥0 using I d hd
    apply v.null_of_frequently_le_of_frequently_ge hρ (ENNReal.coe_lt_coe.1 hcd)
    · simp only [and_imp, exists_prop, not_frequently, not_and, not_lt, not_le, not_eventually,
        mem_set_of_eq, mem_compl_iff, not_forall]
      intro x h1x h2x
      apply h1x.mono fun a ha => _
      refine' (ENNReal.div_le_iff_le_mul _ (Or.inr (bot_le.trans_lt ha).ne')).1 ha.le
      simp only [ENNReal.coe_ne_top, Ne.def, or_true_iff, not_false_iff]
    · simp only [and_imp, exists_prop, not_frequently, not_and, not_lt, not_le, not_eventually,
        mem_set_of_eq, mem_compl_iff, not_forall]
      intro x h1x h2x
      apply h2x.mono fun a ha => _
      exact ENNReal.mul_le_of_le_div ha.le
  have B :
    ∀ᵐ x ∂μ,
      ∀ c ∈ w,
        ∀ d ∈ w,
          c < d →
            ¬((∃ᶠ a in v.filter_at x, ρ a / μ a < c) ∧ ∃ᶠ a in v.filter_at x, d < ρ a / μ a) :=
    by simpa only [ae_ball_iff w_count, ae_all_iff]
  filter_upwards [B]
  intro x hx
  exact tendsto_of_no_upcrossings w_dense hx
#align vitali_family.ae_tendsto_div VitaliFamily.ae_tendsto_div
-/

#print VitaliFamily.ae_tendsto_limRatio /-
theorem ae_tendsto_limRatio :
    ∀ᵐ x ∂μ, Tendsto (fun a => ρ a / μ a) (v.filterAt x) (𝓝 (v.limRatio ρ x)) :=
  by
  filter_upwards [v.ae_tendsto_div hρ]
  intro x hx
  exact tendsto_nhds_limUnder hx
#align vitali_family.ae_tendsto_lim_ratio VitaliFamily.ae_tendsto_limRatio
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (m n) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (m n) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (m n) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (m n) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (m n) -/
#print VitaliFamily.exists_measurable_supersets_limRatio /-
/-- Given two thresholds `p < q`, the sets `{x | v.lim_ratio ρ x < p}`
and `{x | q < v.lim_ratio ρ x}` are obviously disjoint. The key to proving that `v.lim_ratio ρ` is
almost everywhere measurable is to show that these sets have measurable supersets which are also
disjoint, up to zero measure. This is the content of this lemma. -/
theorem exists_measurable_supersets_limRatio {p q : ℝ≥0} (hpq : p < q) :
    ∃ a b,
      MeasurableSet a ∧
        MeasurableSet b ∧
          {x | v.limRatio ρ x < p} ⊆ a ∧ {x | (q : ℝ≥0∞) < v.limRatio ρ x} ⊆ b ∧ μ (a ∩ b) = 0 :=
  by
  /- Here is a rough sketch, assuming that the measure is finite and the limit is well defined
    everywhere. Let `u := {x | v.lim_ratio ρ x < p}` and `w := {x | q < v.lim_ratio ρ x}`. They
    have measurable supersets `u'` and `w'` of the same measure. We will show that these satisfy
    the conclusion of the theorem, i.e., `μ (u' ∩ w') = 0`. For this, note that
    `ρ (u' ∩ w') = ρ (u ∩ w')` (as `w'` is measurable, see `measure_to_measurable_add_inter_left`).
    The latter set is included in the set where the limit of the ratios is `< p`, and therefore
    its measure is `≤ p * μ (u ∩ w')`. Using the same trick in the other direction gives that this is
    `p * μ (u' ∩ w')`. We have shown that `ρ (u' ∩ w') ≤ p * μ (u' ∩ w')`. Arguing in the same way but
    using the `w` part gives `q * μ (u' ∩ w') ≤ ρ (u' ∩ w')`. If `μ (u' ∩ w')` were nonzero, this
    would be a contradiction as `p < q`.
  
    For the rigorous proof, we need to work on a part of the space where the measure is finite
    (provided by `spanning_sets (ρ + μ)`) and to restrict to the set where the limit is well defined
    (called `s` below, of full measure). Otherwise, the argument goes through.
    -/
  let s := {x | ∃ c, tendsto (fun a => ρ a / μ a) (v.filter_at x) (𝓝 c)}
  let o : ℕ → Set α := spanning_sets (ρ + μ)
  let u n := s ∩ {x | v.lim_ratio ρ x < p} ∩ o n
  let w n := s ∩ {x | (q : ℝ≥0∞) < v.lim_ratio ρ x} ∩ o n
  -- the supersets are obtained by restricting to the set `s` where the limit is well defined, to
  -- a finite measure part `o n`, taking a measurable superset here, and then taking the union over
  -- `n`.
  refine'
    ⟨to_measurable μ (sᶜ) ∪ ⋃ n, to_measurable (ρ + μ) (u n),
      to_measurable μ (sᶜ) ∪ ⋃ n, to_measurable (ρ + μ) (w n), _, _, _, _, _⟩
  -- check that these sets are measurable supersets as required
  ·
    exact
      (measurable_set_to_measurable _ _).union
        (MeasurableSet.iUnion fun n => measurable_set_to_measurable _ _)
  ·
    exact
      (measurable_set_to_measurable _ _).union
        (MeasurableSet.iUnion fun n => measurable_set_to_measurable _ _)
  · intro x hx
    by_cases h : x ∈ s
    · refine' Or.inr (mem_Union.2 ⟨spanning_sets_index (ρ + μ) x, _⟩)
      exact subset_to_measurable _ _ ⟨⟨h, hx⟩, mem_spanning_sets_index _ _⟩
    · exact Or.inl (subset_to_measurable μ (sᶜ) h)
  · intro x hx
    by_cases h : x ∈ s
    · refine' Or.inr (mem_Union.2 ⟨spanning_sets_index (ρ + μ) x, _⟩)
      exact subset_to_measurable _ _ ⟨⟨h, hx⟩, mem_spanning_sets_index _ _⟩
    · exact Or.inl (subset_to_measurable μ (sᶜ) h)
  -- it remains to check the nontrivial part that these sets have zero measure intersection.
  -- it suffices to do it for fixed `m` and `n`, as one is taking countable unions.
  suffices H : ∀ m n : ℕ, μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) = 0
  · have A :
      (to_measurable μ (sᶜ) ∪ ⋃ n, to_measurable (ρ + μ) (u n)) ∩
          (to_measurable μ (sᶜ) ∪ ⋃ n, to_measurable (ρ + μ) (w n)) ⊆
        to_measurable μ (sᶜ) ∪
          ⋃ (m) (n), to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n) :=
      by
      simp only [inter_distrib_left, inter_distrib_right, true_and_iff, subset_union_left,
        union_subset_iff, inter_self]
      refine' ⟨_, _, _⟩
      · exact (inter_subset_left _ _).trans (subset_union_left _ _)
      · exact (inter_subset_right _ _).trans (subset_union_left _ _)
      · simp_rw [Union_inter, inter_Union]; exact subset_union_right _ _
    refine' le_antisymm ((measure_mono A).trans _) bot_le
    calc
      μ
            (to_measurable μ (sᶜ) ∪
              ⋃ (m) (n), to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) ≤
          μ (to_measurable μ (sᶜ)) +
            μ (⋃ (m) (n), to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) :=
        measure_union_le _ _
      _ = μ (⋃ (m) (n), to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) := by
        have : μ (sᶜ) = 0 := v.ae_tendsto_div hρ; rw [measure_to_measurable, this, zero_add]
      _ ≤ ∑' (m) (n), μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) :=
        ((measure_Union_le _).trans (ENNReal.tsum_le_tsum fun m => measure_Union_le _))
      _ = 0 := by simp only [H, tsum_zero]
  -- now starts the nontrivial part of the argument. We fix `m` and `n`, and show that the
  -- measurable supersets of `u m` and `w n` have zero measure intersection by using the lemmas
  -- `measure_to_measurable_add_inter_left` (to reduce to `u m` or `w n` instead of the measurable
  -- superset) and `measure_le_of_frequently_le` to compare their measures for `ρ` and `μ`.
  intro m n
  have I : (ρ + μ) (u m) ≠ ∞ :=
    by
    apply (lt_of_le_of_lt (measure_mono _) (measure_spanning_sets_lt_top (ρ + μ) m)).Ne
    exact inter_subset_right _ _
  have J : (ρ + μ) (w n) ≠ ∞ :=
    by
    apply (lt_of_le_of_lt (measure_mono _) (measure_spanning_sets_lt_top (ρ + μ) n)).Ne
    exact inter_subset_right _ _
  have A :
    ρ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) ≤
      p * μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) :=
    calc
      ρ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) =
          ρ (u m ∩ to_measurable (ρ + μ) (w n)) :=
        measure_to_measurable_add_inter_left (measurable_set_to_measurable _ _) I
      _ ≤ (p • μ) (u m ∩ to_measurable (ρ + μ) (w n)) :=
        by
        refine' v.measure_le_of_frequently_le _ hρ _ fun x hx => _
        have L : tendsto (fun a : Set α => ρ a / μ a) (v.filter_at x) (𝓝 (v.lim_ratio ρ x)) :=
          tendsto_nhds_limUnder hx.1.1.1
        have I : ∀ᶠ b : Set α in v.filter_at x, ρ b / μ b < p := (tendsto_order.1 L).2 _ hx.1.1.2
        apply I.frequently.mono fun a ha => _
        rw [coe_nnreal_smul_apply]
        refine' (ENNReal.div_le_iff_le_mul _ (Or.inr (bot_le.trans_lt ha).ne')).1 ha.le
        simp only [ENNReal.coe_ne_top, Ne.def, or_true_iff, not_false_iff]
      _ = p * μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) := by
        simp only [coe_nnreal_smul_apply,
          measure_to_measurable_add_inter_right (measurable_set_to_measurable _ _) I]
  have B :
    (q : ℝ≥0∞) * μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) ≤
      ρ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) :=
    calc
      (q : ℝ≥0∞) * μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) =
          (q : ℝ≥0∞) * μ (to_measurable (ρ + μ) (u m) ∩ w n) :=
        by
        conv_rhs => rw [inter_comm]
        rw [inter_comm, measure_to_measurable_add_inter_right (measurable_set_to_measurable _ _) J]
      _ ≤ ρ (to_measurable (ρ + μ) (u m) ∩ w n) :=
        by
        rw [← coe_nnreal_smul_apply]
        refine' v.measure_le_of_frequently_le _ (absolutely_continuous.rfl.smul _) _ _
        intro x hx
        have L : tendsto (fun a : Set α => ρ a / μ a) (v.filter_at x) (𝓝 (v.lim_ratio ρ x)) :=
          tendsto_nhds_limUnder hx.2.1.1
        have I : ∀ᶠ b : Set α in v.filter_at x, (q : ℝ≥0∞) < ρ b / μ b :=
          (tendsto_order.1 L).1 _ hx.2.1.2
        apply I.frequently.mono fun a ha => _
        rw [coe_nnreal_smul_apply]
        exact ENNReal.mul_le_of_le_div ha.le
      _ = ρ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) :=
        by
        conv_rhs => rw [inter_comm]
        rw [inter_comm]
        exact (measure_to_measurable_add_inter_left (measurable_set_to_measurable _ _) J).symm
  by_contra
  apply lt_irrefl (ρ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)))
  calc
    ρ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) ≤
        p * μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) :=
      A
    _ < q * μ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) :=
      by
      apply (ENNReal.mul_lt_mul_right h _).2 (ENNReal.coe_lt_coe.2 hpq)
      suffices H : (ρ + μ) (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) ≠ ∞
      · simp only [not_or, ENNReal.add_eq_top, Pi.add_apply, Ne.def, coe_add] at H 
        exact H.2
      apply (lt_of_le_of_lt (measure_mono (inter_subset_left _ _)) _).Ne
      rw [measure_to_measurable]
      apply lt_of_le_of_lt (measure_mono _) (measure_spanning_sets_lt_top (ρ + μ) m)
      exact inter_subset_right _ _
    _ ≤ ρ (to_measurable (ρ + μ) (u m) ∩ to_measurable (ρ + μ) (w n)) := B
#align vitali_family.exists_measurable_supersets_lim_ratio VitaliFamily.exists_measurable_supersets_limRatio
-/

#print VitaliFamily.aemeasurable_limRatio /-
theorem aemeasurable_limRatio : AEMeasurable (v.limRatio ρ) μ :=
  by
  apply ENNReal.aemeasurable_of_exist_almost_disjoint_supersets _ _ fun p q hpq => _
  exact v.exists_measurable_supersets_lim_ratio hρ hpq
#align vitali_family.ae_measurable_lim_ratio VitaliFamily.aemeasurable_limRatio
-/

#print VitaliFamily.limRatioMeas /-
/-- A measurable version of `v.lim_ratio ρ`. Do *not* use this definition: it is only a temporary
device to show that `v.lim_ratio` is almost everywhere equal to the Radon-Nikodym derivative. -/
noncomputable def limRatioMeas : α → ℝ≥0∞ :=
  (v.aemeasurable_limRatio hρ).mk _
#align vitali_family.lim_ratio_meas VitaliFamily.limRatioMeas
-/

#print VitaliFamily.limRatioMeas_measurable /-
theorem limRatioMeas_measurable : Measurable (v.limRatioMeas hρ) :=
  AEMeasurable.measurable_mk _
#align vitali_family.lim_ratio_meas_measurable VitaliFamily.limRatioMeas_measurable
-/

#print VitaliFamily.ae_tendsto_limRatioMeas /-
theorem ae_tendsto_limRatioMeas :
    ∀ᵐ x ∂μ, Tendsto (fun a => ρ a / μ a) (v.filterAt x) (𝓝 (v.limRatioMeas hρ x)) :=
  by
  filter_upwards [v.ae_tendsto_lim_ratio hρ, AEMeasurable.ae_eq_mk (v.ae_measurable_lim_ratio hρ)]
  intro x hx h'x
  rwa [h'x] at hx 
#align vitali_family.ae_tendsto_lim_ratio_meas VitaliFamily.ae_tendsto_limRatioMeas
-/

#print VitaliFamily.measure_le_mul_of_subset_limRatioMeas_lt /-
/-- If, for all `x` in a set `s`, one has frequently `ρ a / μ a < p`, then `ρ s ≤ p * μ s`, as
proved in `measure_le_of_frequently_le`. Since `ρ a / μ a` tends almost everywhere to
`v.lim_ratio_meas hρ x`, the same property holds for sets `s` on which `v.lim_ratio_meas hρ < p`. -/
theorem measure_le_mul_of_subset_limRatioMeas_lt {p : ℝ≥0} {s : Set α}
    (h : s ⊆ {x | v.limRatioMeas hρ x < p}) : ρ s ≤ p * μ s :=
  by
  let t := {x : α | tendsto (fun a => ρ a / μ a) (v.filter_at x) (𝓝 (v.lim_ratio_meas hρ x))}
  have A : μ (tᶜ) = 0 := v.ae_tendsto_lim_ratio_meas hρ
  suffices H : ρ (s ∩ t) ≤ (p • μ) (s ∩ t);
  exact
    calc
      ρ s = ρ (s ∩ t ∪ s ∩ tᶜ) := by rw [inter_union_compl]
      _ ≤ ρ (s ∩ t) + ρ (s ∩ tᶜ) := (measure_union_le _ _)
      _ ≤ p * μ (s ∩ t) + 0 :=
        (add_le_add H ((measure_mono (inter_subset_right _ _)).trans (hρ A).le))
      _ ≤ p * μ s := by rw [add_zero];
        exact mul_le_mul_left' (measure_mono (inter_subset_left _ _)) _
  refine' v.measure_le_of_frequently_le _ hρ _ fun x hx => _
  have I : ∀ᶠ b : Set α in v.filter_at x, ρ b / μ b < p := (tendsto_order.1 hx.2).2 _ (h hx.1)
  apply I.frequently.mono fun a ha => _
  rw [coe_nnreal_smul_apply]
  refine' (ENNReal.div_le_iff_le_mul _ (Or.inr (bot_le.trans_lt ha).ne')).1 ha.le
  simp only [ENNReal.coe_ne_top, Ne.def, or_true_iff, not_false_iff]
#align vitali_family.measure_le_mul_of_subset_lim_ratio_meas_lt VitaliFamily.measure_le_mul_of_subset_limRatioMeas_lt
-/

#print VitaliFamily.mul_measure_le_of_subset_lt_limRatioMeas /-
/-- If, for all `x` in a set `s`, one has frequently `q < ρ a / μ a`, then `q * μ s ≤ ρ s`, as
proved in `measure_le_of_frequently_le`. Since `ρ a / μ a` tends almost everywhere to
`v.lim_ratio_meas hρ x`, the same property holds for sets `s` on which `q < v.lim_ratio_meas hρ`. -/
theorem mul_measure_le_of_subset_lt_limRatioMeas {q : ℝ≥0} {s : Set α}
    (h : s ⊆ {x | (q : ℝ≥0∞) < v.limRatioMeas hρ x}) : (q : ℝ≥0∞) * μ s ≤ ρ s :=
  by
  let t := {x : α | tendsto (fun a => ρ a / μ a) (v.filter_at x) (𝓝 (v.lim_ratio_meas hρ x))}
  have A : μ (tᶜ) = 0 := v.ae_tendsto_lim_ratio_meas hρ
  suffices H : (q • μ) (s ∩ t) ≤ ρ (s ∩ t);
  exact
    calc
      (q • μ) s = (q • μ) (s ∩ t ∪ s ∩ tᶜ) := by rw [inter_union_compl]
      _ ≤ (q • μ) (s ∩ t) + (q • μ) (s ∩ tᶜ) := (measure_union_le _ _)
      _ ≤ ρ (s ∩ t) + q * μ (tᶜ) := by
        apply add_le_add H
        rw [coe_nnreal_smul_apply]
        exact mul_le_mul_left' (measure_mono (inter_subset_right _ _)) _
      _ ≤ ρ s := by rw [A, MulZeroClass.mul_zero, add_zero];
        exact measure_mono (inter_subset_left _ _)
  refine' v.measure_le_of_frequently_le _ (absolutely_continuous.rfl.smul _) _ _
  intro x hx
  have I : ∀ᶠ a in v.filter_at x, (q : ℝ≥0∞) < ρ a / μ a := (tendsto_order.1 hx.2).1 _ (h hx.1)
  apply I.frequently.mono fun a ha => _
  rw [coe_nnreal_smul_apply]
  exact ENNReal.mul_le_of_le_div ha.le
#align vitali_family.mul_measure_le_of_subset_lt_lim_ratio_meas VitaliFamily.mul_measure_le_of_subset_lt_limRatioMeas
-/

#print VitaliFamily.measure_limRatioMeas_top /-
/-- The points with `v.lim_ratio_meas hρ x = ∞` have measure `0` for `μ`. -/
theorem measure_limRatioMeas_top : μ {x | v.limRatioMeas hρ x = ∞} = 0 :=
  by
  refine' null_of_locally_null _ fun x hx => _
  obtain ⟨o, xo, o_open, μo⟩ : ∃ o : Set α, x ∈ o ∧ IsOpen o ∧ ρ o < ∞ :=
    measure.exists_is_open_measure_lt_top ρ x
  let s := {x : α | v.lim_ratio_meas hρ x = ∞} ∩ o
  refine' ⟨s, inter_mem_nhdsWithin _ (o_open.mem_nhds xo), le_antisymm _ bot_le⟩
  have ρs : ρ s ≠ ∞ := ((measure_mono (inter_subset_right _ _)).trans_lt μo).Ne
  have A : ∀ q : ℝ≥0, 1 ≤ q → μ s ≤ q⁻¹ * ρ s :=
    by
    intro q hq
    rw [mul_comm, ← div_eq_mul_inv, ENNReal.le_div_iff_mul_le _ (Or.inr ρs), mul_comm]
    · apply v.mul_measure_le_of_subset_lt_lim_ratio_meas hρ
      intro y hy
      have : v.lim_ratio_meas hρ y = ∞ := hy.1
      simp only [this, ENNReal.coe_lt_top, mem_set_of_eq]
    ·
      simp only [(zero_lt_one.trans_le hq).ne', true_or_iff, ENNReal.coe_eq_zero, Ne.def,
        not_false_iff]
  have B : tendsto (fun q : ℝ≥0 => (q : ℝ≥0∞)⁻¹ * ρ s) at_top (𝓝 (∞⁻¹ * ρ s)) :=
    by
    apply ENNReal.Tendsto.mul_const _ (Or.inr ρs)
    exact ENNReal.tendsto_inv_iff.2 (ENNReal.tendsto_coe_nhds_top.2 tendsto_id)
  simp only [MulZeroClass.zero_mul, ENNReal.inv_top] at B 
  apply ge_of_tendsto B
  exact eventually_at_top.2 ⟨1, A⟩
#align vitali_family.measure_lim_ratio_meas_top VitaliFamily.measure_limRatioMeas_top
-/

#print VitaliFamily.measure_limRatioMeas_zero /-
/-- The points with `v.lim_ratio_meas hρ x = 0` have measure `0` for `ρ`. -/
theorem measure_limRatioMeas_zero : ρ {x | v.limRatioMeas hρ x = 0} = 0 :=
  by
  refine' null_of_locally_null _ fun x hx => _
  obtain ⟨o, xo, o_open, μo⟩ : ∃ o : Set α, x ∈ o ∧ IsOpen o ∧ μ o < ∞ :=
    measure.exists_is_open_measure_lt_top μ x
  let s := {x : α | v.lim_ratio_meas hρ x = 0} ∩ o
  refine' ⟨s, inter_mem_nhdsWithin _ (o_open.mem_nhds xo), le_antisymm _ bot_le⟩
  have μs : μ s ≠ ∞ := ((measure_mono (inter_subset_right _ _)).trans_lt μo).Ne
  have A : ∀ q : ℝ≥0, 0 < q → ρ s ≤ q * μ s :=
    by
    intro q hq
    apply v.measure_le_mul_of_subset_lim_ratio_meas_lt hρ
    intro y hy
    have : v.lim_ratio_meas hρ y = 0 := hy.1
    simp only [this, mem_set_of_eq, hq, ENNReal.coe_pos]
  have B : tendsto (fun q : ℝ≥0 => (q : ℝ≥0∞) * μ s) (𝓝[>] (0 : ℝ≥0)) (𝓝 ((0 : ℝ≥0) * μ s)) :=
    by
    apply ENNReal.Tendsto.mul_const _ (Or.inr μs)
    rw [ENNReal.tendsto_coe]
    exact nhdsWithin_le_nhds
  simp only [MulZeroClass.zero_mul, ENNReal.coe_zero] at B 
  apply ge_of_tendsto B
  filter_upwards [self_mem_nhdsWithin] using A
#align vitali_family.measure_lim_ratio_meas_zero VitaliFamily.measure_limRatioMeas_zero
-/

#print VitaliFamily.withDensity_le_mul /-
/-- As an intermediate step to show that `μ.with_density (v.lim_ratio_meas hρ) = ρ`, we show here
that `μ.with_density (v.lim_ratio_meas hρ) ≤ t^2 ρ` for any `t > 1`. -/
theorem withDensity_le_mul {s : Set α} (hs : MeasurableSet s) {t : ℝ≥0} (ht : 1 < t) :
    μ.withDensity (v.limRatioMeas hρ) s ≤ t ^ 2 * ρ s :=
  by
  /- We cut `s` into the sets where `v.lim_ratio_meas hρ = 0`, where `v.lim_ratio_meas hρ = ∞`, and
    where `v.lim_ratio_meas hρ ∈ [t^n, t^(n+1))` for `n : ℤ`. The first and second have measure `0`.
    For the latter, since `v.lim_ratio_meas hρ` fluctuates by at most `t` on this slice, we can use
    `measure_le_mul_of_subset_lim_ratio_meas_lt` and `mul_measure_le_of_subset_lt_lim_ratio_meas` to
    show that the two measures are comparable up to `t` (in fact `t^2` for technical reasons of
    strict inequalities). -/
  have t_ne_zero' : t ≠ 0 := (zero_lt_one.trans ht).ne'
  have t_ne_zero : (t : ℝ≥0∞) ≠ 0 := by simpa only [ENNReal.coe_eq_zero, Ne.def] using t_ne_zero'
  let ν := μ.with_density (v.lim_ratio_meas hρ)
  let f := v.lim_ratio_meas hρ
  have f_meas : Measurable f := v.lim_ratio_meas_measurable hρ
  have A : ν (s ∩ f ⁻¹' {0}) ≤ ((t : ℝ≥0∞) ^ 2 • ρ) (s ∩ f ⁻¹' {0}) :=
    by
    apply le_trans _ (zero_le _)
    have M : MeasurableSet (s ∩ f ⁻¹' {0}) := hs.inter (f_meas (measurable_set_singleton _))
    simp only [ν, f, nonpos_iff_eq_zero, M, with_density_apply, lintegral_eq_zero_iff f_meas]
    apply (ae_restrict_iff' M).2
    exact eventually_of_forall fun x hx => hx.2
  have B : ν (s ∩ f ⁻¹' {∞}) ≤ ((t : ℝ≥0∞) ^ 2 • ρ) (s ∩ f ⁻¹' {∞}) :=
    by
    apply le_trans (le_of_eq _) (zero_le _)
    apply with_density_absolutely_continuous μ _
    rw [← nonpos_iff_eq_zero]
    exact (measure_mono (inter_subset_right _ _)).trans (v.measure_lim_ratio_meas_top hρ).le
  have C :
    ∀ n : ℤ,
      ν (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) ≤
        ((t : ℝ≥0∞) ^ 2 • ρ) (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) :=
    by
    intro n
    let I := Ico ((t : ℝ≥0∞) ^ n) (t ^ (n + 1))
    have M : MeasurableSet (s ∩ f ⁻¹' I) := hs.inter (f_meas measurableSet_Ico)
    simp only [f, M, with_density_apply, coe_nnreal_smul_apply]
    calc
      ∫⁻ x in s ∩ f ⁻¹' I, f x ∂μ ≤ ∫⁻ x in s ∩ f ⁻¹' I, t ^ (n + 1) ∂μ :=
        lintegral_mono_ae ((ae_restrict_iff' M).2 (eventually_of_forall fun x hx => hx.2.2.le))
      _ = t ^ (n + 1) * μ (s ∩ f ⁻¹' I) := by
        simp only [lintegral_const, MeasurableSet.univ, measure.restrict_apply, univ_inter]
      _ = t ^ (2 : ℤ) * (t ^ (n - 1) * μ (s ∩ f ⁻¹' I)) :=
        by
        rw [← mul_assoc, ← ENNReal.zpow_add t_ne_zero ENNReal.coe_ne_top]
        congr 2
        abel
      _ ≤ t ^ 2 * ρ (s ∩ f ⁻¹' I) := by
        refine' mul_le_mul_left' _ _
        rw [← ENNReal.coe_zpow (zero_lt_one.trans ht).ne']
        apply v.mul_measure_le_of_subset_lt_lim_ratio_meas hρ
        intro x hx
        apply lt_of_lt_of_le _ hx.2.1
        rw [← ENNReal.coe_zpow (zero_lt_one.trans ht).ne', ENNReal.coe_lt_coe, sub_eq_add_neg,
          zpow_add₀ t_ne_zero']
        conv_rhs => rw [← mul_one (t ^ n)]
        refine' mul_lt_mul' le_rfl _ (zero_le _) (NNReal.zpow_pos t_ne_zero' _)
        rw [zpow_neg_one]
        exact inv_lt_one ht
  calc
    ν s =
        ν (s ∩ f ⁻¹' {0}) + ν (s ∩ f ⁻¹' {∞}) + ∑' n : ℤ, ν (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) :=
      measure_eq_measure_preimage_add_measure_tsum_Ico_zpow ν f_meas hs ht
    _ ≤
        ((t : ℝ≥0∞) ^ 2 • ρ) (s ∩ f ⁻¹' {0}) + ((t : ℝ≥0∞) ^ 2 • ρ) (s ∩ f ⁻¹' {∞}) +
          ∑' n : ℤ, ((t : ℝ≥0∞) ^ 2 • ρ) (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) :=
      (add_le_add (add_le_add A B) (ENNReal.tsum_le_tsum C))
    _ = ((t : ℝ≥0∞) ^ 2 • ρ) s :=
      (measure_eq_measure_preimage_add_measure_tsum_Ico_zpow ((t : ℝ≥0∞) ^ 2 • ρ) f_meas hs ht).symm
#align vitali_family.with_density_le_mul VitaliFamily.withDensity_le_mul
-/

#print VitaliFamily.le_mul_withDensity /-
/-- As an intermediate step to show that `μ.with_density (v.lim_ratio_meas hρ) = ρ`, we show here
that `ρ ≤ t μ.with_density (v.lim_ratio_meas hρ)` for any `t > 1`. -/
theorem le_mul_withDensity {s : Set α} (hs : MeasurableSet s) {t : ℝ≥0} (ht : 1 < t) :
    ρ s ≤ t * μ.withDensity (v.limRatioMeas hρ) s :=
  by
  /- We cut `s` into the sets where `v.lim_ratio_meas hρ = 0`, where `v.lim_ratio_meas hρ = ∞`, and
    where `v.lim_ratio_meas hρ ∈ [t^n, t^(n+1))` for `n : ℤ`. The first and second have measure `0`.
    For the latter, since `v.lim_ratio_meas hρ` fluctuates by at most `t` on this slice, we can use
    `measure_le_mul_of_subset_lim_ratio_meas_lt` and `mul_measure_le_of_subset_lt_lim_ratio_meas` to
    show that the two measures are comparable up to `t`. -/
  have t_ne_zero' : t ≠ 0 := (zero_lt_one.trans ht).ne'
  have t_ne_zero : (t : ℝ≥0∞) ≠ 0 := by simpa only [ENNReal.coe_eq_zero, Ne.def] using t_ne_zero'
  let ν := μ.with_density (v.lim_ratio_meas hρ)
  let f := v.lim_ratio_meas hρ
  have f_meas : Measurable f := v.lim_ratio_meas_measurable hρ
  have A : ρ (s ∩ f ⁻¹' {0}) ≤ (t • ν) (s ∩ f ⁻¹' {0}) :=
    by
    refine' le_trans (measure_mono (inter_subset_right _ _)) (le_trans (le_of_eq _) (zero_le _))
    exact v.measure_lim_ratio_meas_zero hρ
  have B : ρ (s ∩ f ⁻¹' {∞}) ≤ (t • ν) (s ∩ f ⁻¹' {∞}) :=
    by
    apply le_trans (le_of_eq _) (zero_le _)
    apply hρ
    rw [← nonpos_iff_eq_zero]
    exact (measure_mono (inter_subset_right _ _)).trans (v.measure_lim_ratio_meas_top hρ).le
  have C :
    ∀ n : ℤ,
      ρ (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) ≤ (t • ν) (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) :=
    by
    intro n
    let I := Ico ((t : ℝ≥0∞) ^ n) (t ^ (n + 1))
    have M : MeasurableSet (s ∩ f ⁻¹' I) := hs.inter (f_meas measurableSet_Ico)
    simp only [f, M, with_density_apply, coe_nnreal_smul_apply]
    calc
      ρ (s ∩ f ⁻¹' I) ≤ t ^ (n + 1) * μ (s ∩ f ⁻¹' I) :=
        by
        rw [← ENNReal.coe_zpow t_ne_zero']
        apply v.measure_le_mul_of_subset_lim_ratio_meas_lt hρ
        intro x hx
        apply hx.2.2.trans_le (le_of_eq _)
        rw [ENNReal.coe_zpow t_ne_zero']
      _ = ∫⁻ x in s ∩ f ⁻¹' I, t ^ (n + 1) ∂μ := by
        simp only [lintegral_const, MeasurableSet.univ, measure.restrict_apply, univ_inter]
      _ ≤ ∫⁻ x in s ∩ f ⁻¹' I, t * f x ∂μ :=
        by
        apply lintegral_mono_ae ((ae_restrict_iff' M).2 (eventually_of_forall fun x hx => _))
        rw [add_comm, ENNReal.zpow_add t_ne_zero ENNReal.coe_ne_top, zpow_one]
        exact mul_le_mul_left' hx.2.1 _
      _ = t * ∫⁻ x in s ∩ f ⁻¹' I, f x ∂μ := lintegral_const_mul _ f_meas
  calc
    ρ s =
        ρ (s ∩ f ⁻¹' {0}) + ρ (s ∩ f ⁻¹' {∞}) + ∑' n : ℤ, ρ (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) :=
      measure_eq_measure_preimage_add_measure_tsum_Ico_zpow ρ f_meas hs ht
    _ ≤
        (t • ν) (s ∩ f ⁻¹' {0}) + (t • ν) (s ∩ f ⁻¹' {∞}) +
          ∑' n : ℤ, (t • ν) (s ∩ f ⁻¹' Ico (t ^ n) (t ^ (n + 1))) :=
      (add_le_add (add_le_add A B) (ENNReal.tsum_le_tsum C))
    _ = (t • ν) s :=
      (measure_eq_measure_preimage_add_measure_tsum_Ico_zpow (t • ν) f_meas hs ht).symm
#align vitali_family.le_mul_with_density VitaliFamily.le_mul_withDensity
-/

#print VitaliFamily.withDensity_limRatioMeas_eq /-
theorem withDensity_limRatioMeas_eq : μ.withDensity (v.limRatioMeas hρ) = ρ :=
  by
  ext1 s hs
  refine' le_antisymm _ _
  · have : tendsto (fun t : ℝ≥0 => (t ^ 2 * ρ s : ℝ≥0∞)) (𝓝[>] 1) (𝓝 ((1 : ℝ≥0) ^ 2 * ρ s)) :=
      by
      refine' ENNReal.Tendsto.mul _ _ tendsto_const_nhds _
      · exact ENNReal.Tendsto.pow (ENNReal.tendsto_coe.2 nhdsWithin_le_nhds)
      · simp only [one_pow, ENNReal.coe_one, true_or_iff, Ne.def, not_false_iff, one_ne_zero]
      · simp only [one_pow, ENNReal.coe_one, Ne.def, or_true_iff, ENNReal.one_ne_top, not_false_iff]
    simp only [one_pow, one_mul, ENNReal.coe_one] at this 
    refine' ge_of_tendsto this _
    filter_upwards [self_mem_nhdsWithin] with _ ht
    exact v.with_density_le_mul hρ hs ht
  · have :
      tendsto (fun t : ℝ≥0 => (t : ℝ≥0∞) * μ.with_density (v.lim_ratio_meas hρ) s) (𝓝[>] 1)
        (𝓝 ((1 : ℝ≥0) * μ.with_density (v.lim_ratio_meas hρ) s)) :=
      by
      refine' ENNReal.Tendsto.mul_const (ENNReal.tendsto_coe.2 nhdsWithin_le_nhds) _
      simp only [ENNReal.coe_one, true_or_iff, Ne.def, not_false_iff, one_ne_zero]
    simp only [one_mul, ENNReal.coe_one] at this 
    refine' ge_of_tendsto this _
    filter_upwards [self_mem_nhdsWithin] with _ ht
    exact v.le_mul_with_density hρ hs ht
#align vitali_family.with_density_lim_ratio_meas_eq VitaliFamily.withDensity_limRatioMeas_eq
-/

#print VitaliFamily.ae_tendsto_rnDeriv_of_absolutelyContinuous /-
/-- Weak version of the main theorem on differentiation of measures: given a Vitali family `v`
for a locally finite measure `μ`, and another locally finite measure `ρ`, then for `μ`-almost
every `x` the ratio `ρ a / μ a` converges, when `a` shrinks to `x` along the Vitali family,
towards the Radon-Nikodym derivative of `ρ` with respect to `μ`.

This version assumes that `ρ` is absolutely continuous with respect to `μ`. The general version
without this superfluous assumption is `vitali_family.ae_tendsto_rn_deriv`.
-/
theorem ae_tendsto_rnDeriv_of_absolutelyContinuous :
    ∀ᵐ x ∂μ, Tendsto (fun a => ρ a / μ a) (v.filterAt x) (𝓝 (ρ.rnDeriv μ x)) :=
  by
  have A : (μ.with_density (v.lim_ratio_meas hρ)).rnDeriv μ =ᵐ[μ] v.lim_ratio_meas hρ :=
    rn_deriv_with_density μ (v.lim_ratio_meas_measurable hρ)
  rw [v.with_density_lim_ratio_meas_eq hρ] at A 
  filter_upwards [v.ae_tendsto_lim_ratio_meas hρ, A] with _ _ h'x
  rwa [h'x]
#align vitali_family.ae_tendsto_rn_deriv_of_absolutely_continuous VitaliFamily.ae_tendsto_rnDeriv_of_absolutelyContinuous
-/

end AbsolutelyContinuous

variable (ρ)

#print VitaliFamily.ae_tendsto_rnDeriv /-
/-- Main theorem on differentiation of measures: given a Vitali family `v` for a locally finite
measure `μ`, and another locally finite measure `ρ`, then for `μ`-almost every `x` the
ratio `ρ a / μ a` converges, when `a` shrinks to `x` along the Vitali family, towards the
Radon-Nikodym derivative of `ρ` with respect to `μ`. -/
theorem ae_tendsto_rnDeriv :
    ∀ᵐ x ∂μ, Tendsto (fun a => ρ a / μ a) (v.filterAt x) (𝓝 (ρ.rnDeriv μ x)) :=
  by
  let t := μ.with_density (ρ.rn_deriv μ)
  have eq_add : ρ = ρ.singular_part μ + t := have_lebesgue_decomposition_add _ _
  have A : ∀ᵐ x ∂μ, tendsto (fun a => ρ.singular_part μ a / μ a) (v.filter_at x) (𝓝 0) :=
    v.ae_eventually_measure_zero_of_singular (mutually_singular_singular_part ρ μ)
  have B : ∀ᵐ x ∂μ, t.rn_deriv μ x = ρ.rn_deriv μ x :=
    rn_deriv_with_density μ (measurable_rn_deriv ρ μ)
  have C : ∀ᵐ x ∂μ, tendsto (fun a => t a / μ a) (v.filter_at x) (𝓝 (t.rn_deriv μ x)) :=
    v.ae_tendsto_rn_deriv_of_absolutely_continuous (with_density_absolutely_continuous _ _)
  filter_upwards [A, B, C] with _ Ax Bx Cx
  convert Ax.add Cx
  · ext1 a
    conv_lhs => rw [eq_add]
    simp only [Pi.add_apply, coe_add, ENNReal.add_div]
  · simp only [Bx, zero_add]
#align vitali_family.ae_tendsto_rn_deriv VitaliFamily.ae_tendsto_rnDeriv
-/

/-! ### Lebesgue density points -/


#print VitaliFamily.ae_tendsto_measure_inter_div_of_measurableSet /-
/-- Given a measurable set `s`, then `μ (s ∩ a) / μ a` converges when `a` shrinks to a typical
point `x` along a Vitali family. The limit is `1` for `x ∈ s` and `0` for `x ∉ s`. This shows that
almost every point of `s` is a Lebesgue density point for `s`. A version for non-measurable sets
holds, but it only gives the first conclusion, see `ae_tendsto_measure_inter_div`. -/
theorem ae_tendsto_measure_inter_div_of_measurableSet {s : Set α} (hs : MeasurableSet s) :
    ∀ᵐ x ∂μ, Tendsto (fun a => μ (s ∩ a) / μ a) (v.filterAt x) (𝓝 (s.indicator 1 x)) :=
  by
  haveI : is_locally_finite_measure (μ.restrict s) :=
    is_locally_finite_measure_of_le restrict_le_self
  filter_upwards [ae_tendsto_rn_deriv v (μ.restrict s), rn_deriv_restrict μ hs]
  intro x hx h'x
  simpa only [h'x, restrict_apply' hs, inter_comm] using hx
#align vitali_family.ae_tendsto_measure_inter_div_of_measurable_set VitaliFamily.ae_tendsto_measure_inter_div_of_measurableSet
-/

#print VitaliFamily.ae_tendsto_measure_inter_div /-
/-- Given an arbitrary set `s`, then `μ (s ∩ a) / μ a` converges to `1` when `a` shrinks to a
typical point of `s` along a Vitali family. This shows that almost every point of `s` is a
Lebesgue density point for `s`. A stronger version for measurable sets is given
in `ae_tendsto_measure_inter_div_of_measurable_set`. -/
theorem ae_tendsto_measure_inter_div (s : Set α) :
    ∀ᵐ x ∂μ.restrict s, Tendsto (fun a => μ (s ∩ a) / μ a) (v.filterAt x) (𝓝 1) :=
  by
  let t := to_measurable μ s
  have A :
    ∀ᵐ x ∂μ.restrict s, tendsto (fun a => μ (t ∩ a) / μ a) (v.filter_at x) (𝓝 (t.indicator 1 x)) :=
    by
    apply ae_mono restrict_le_self
    apply ae_tendsto_measure_inter_div_of_measurable_set
    exact measurable_set_to_measurable _ _
  have B : ∀ᵐ x ∂μ.restrict s, t.indicator 1 x = (1 : ℝ≥0∞) :=
    by
    refine' ae_restrict_of_ae_restrict_of_subset (subset_to_measurable μ s) _
    filter_upwards [ae_restrict_mem (measurable_set_to_measurable μ s)] with _ hx
    simp only [hx, Pi.one_apply, indicator_of_mem]
  filter_upwards [A, B] with x hx h'x
  rw [h'x] at hx 
  apply hx.congr' _
  filter_upwards [v.eventually_filter_at_measurable_set x] with _ ha
  congr 1
  exact measure_to_measurable_inter_of_sigma_finite ha _
#align vitali_family.ae_tendsto_measure_inter_div VitaliFamily.ae_tendsto_measure_inter_div
-/

/-! ### Lebesgue differentiation theorem -/


#print VitaliFamily.ae_tendsto_lintegral_div' /-
theorem ae_tendsto_lintegral_div' {f : α → ℝ≥0∞} (hf : Measurable f) (h'f : ∫⁻ y, f y ∂μ ≠ ∞) :
    ∀ᵐ x ∂μ, Tendsto (fun a => (∫⁻ y in a, f y ∂μ) / μ a) (v.filterAt x) (𝓝 (f x)) :=
  by
  let ρ := μ.with_density f
  have : is_finite_measure ρ := is_finite_measure_with_density h'f
  filter_upwards [ae_tendsto_rn_deriv v ρ, rn_deriv_with_density μ hf] with x hx h'x
  rw [← h'x]
  apply hx.congr' _
  filter_upwards [v.eventually_filter_at_measurable_set] with a ha
  rw [← with_density_apply f ha]
#align vitali_family.ae_tendsto_lintegral_div' VitaliFamily.ae_tendsto_lintegral_div'
-/

#print VitaliFamily.ae_tendsto_lintegral_div /-
theorem ae_tendsto_lintegral_div {f : α → ℝ≥0∞} (hf : AEMeasurable f μ) (h'f : ∫⁻ y, f y ∂μ ≠ ∞) :
    ∀ᵐ x ∂μ, Tendsto (fun a => (∫⁻ y in a, f y ∂μ) / μ a) (v.filterAt x) (𝓝 (f x)) :=
  by
  have A : ∫⁻ y, hf.mk f y ∂μ ≠ ∞ := by
    convert h'f using 1
    apply lintegral_congr_ae
    exact hf.ae_eq_mk.symm
  filter_upwards [v.ae_tendsto_lintegral_div' hf.measurable_mk A, hf.ae_eq_mk] with x hx h'x
  rw [h'x]
  convert hx
  ext1 a
  congr 1
  apply lintegral_congr_ae
  exact ae_restrict_of_ae hf.ae_eq_mk
#align vitali_family.ae_tendsto_lintegral_div VitaliFamily.ae_tendsto_lintegral_div
-/

#print VitaliFamily.ae_tendsto_lintegral_nnnorm_sub_div' /-
theorem ae_tendsto_lintegral_nnnorm_sub_div' {f : α → E} (hf : Integrable f μ)
    (h'f : StronglyMeasurable f) :
    ∀ᵐ x ∂μ, Tendsto (fun a => (∫⁻ y in a, ‖f y - f x‖₊ ∂μ) / μ a) (v.filterAt x) (𝓝 0) :=
  by
  /- For every `c`, then `(∫⁻ y in a, ‖f y - c‖₊ ∂μ) / μ a` tends almost everywhere to `‖f x - c‖`.
    We apply this to a countable set of `c` which is dense in the range of `f`, to deduce the desired
    convergence.
    A minor technical inconvenience is that constants are not integrable, so to apply previous lemmas
    we need to replace `c` with the restriction of `c` to a finite measure set `A n` in the
    above sketch. -/
  let A := MeasureTheory.Measure.finiteSpanningSetsInOpen' μ
  rcases h'f.is_separable_range with ⟨t, t_count, ht⟩
  have main :
    ∀ᵐ x ∂μ,
      ∀ (n : ℕ) (c : E) (hc : c ∈ t),
        tendsto (fun a => (∫⁻ y in a, ‖f y - (A.set n).indicator (fun y => c) y‖₊ ∂μ) / μ a)
          (v.filter_at x) (𝓝 ‖f x - (A.set n).indicator (fun y => c) x‖₊) :=
    by
    simp_rw [ae_all_iff, ae_ball_iff t_count]
    intro n c hc
    apply ae_tendsto_lintegral_div'
    · refine' (h'f.sub _).ennnorm
      exact strongly_measurable_const.indicator (IsOpen.measurableSet (A.set_mem n))
    · apply ne_of_lt
      calc
        ∫⁻ y, ↑‖f y - (A.set n).indicator (fun y : α => c) y‖₊ ∂μ ≤
            ∫⁻ y, ‖f y‖₊ + ‖(A.set n).indicator (fun y : α => c) y‖₊ ∂μ :=
          by
          apply lintegral_mono
          intro x
          dsimp
          rw [← ENNReal.coe_add]
          exact ENNReal.coe_le_coe.2 (nnnorm_sub_le _ _)
        _ = ∫⁻ y, ‖f y‖₊ ∂μ + ∫⁻ y, ‖(A.set n).indicator (fun y : α => c) y‖₊ ∂μ :=
          (lintegral_add_left h'f.ennnorm _)
        _ < ∞ + ∞ :=
          haveI I : integrable ((A.set n).indicator fun y : α => c) μ := by
            simp only [integrable_indicator_iff (IsOpen.measurableSet (A.set_mem n)),
              integrable_on_const, A.finite n, or_true_iff]
          ENNReal.add_lt_add hf.2 I.2
  filter_upwards [main, v.ae_eventually_measure_pos] with x hx h'x
  have M :
    ∀ c ∈ t, tendsto (fun a => (∫⁻ y in a, ‖f y - c‖₊ ∂μ) / μ a) (v.filter_at x) (𝓝 ‖f x - c‖₊) :=
    by
    intro c hc
    obtain ⟨n, xn⟩ : ∃ n, x ∈ A.set n := by simpa [← A.spanning] using mem_univ x
    specialize hx n c hc
    simp only [xn, indicator_of_mem] at hx 
    apply hx.congr' _
    filter_upwards [v.eventually_filter_at_subset_of_nhds (IsOpen.mem_nhds (A.set_mem n) xn),
      v.eventually_filter_at_measurable_set] with a ha h'a
    congr 1
    apply set_lintegral_congr_fun h'a
    apply eventually_of_forall fun y => _
    intro hy
    simp only [ha hy, indicator_of_mem]
  apply ENNReal.tendsto_nhds_zero.2 fun ε εpos => _
  obtain ⟨c, ct, xc⟩ : ∃ c ∈ t, (‖f x - c‖₊ : ℝ≥0∞) < ε / 2 :=
    by
    simp_rw [← edist_eq_coe_nnnorm_sub]
    have : f x ∈ closure t := ht (mem_range_self _)
    exact EMetric.mem_closure_iff.1 this (ε / 2) (ENNReal.half_pos (ne_of_gt εpos))
  filter_upwards [(tendsto_order.1 (M c ct)).2 (ε / 2) xc, h'x, v.eventually_measure_lt_top x] with
    a ha h'a h''a
  apply ENNReal.div_le_of_le_mul
  calc
    ∫⁻ y in a, ‖f y - f x‖₊ ∂μ ≤ ∫⁻ y in a, ‖f y - c‖₊ + ‖f x - c‖₊ ∂μ :=
      by
      apply lintegral_mono fun x => _
      simpa only [← edist_eq_coe_nnnorm_sub] using edist_triangle_right _ _ _
    _ = ∫⁻ y in a, ‖f y - c‖₊ ∂μ + ∫⁻ y in a, ‖f x - c‖₊ ∂μ :=
      (lintegral_add_right _ measurable_const)
    _ ≤ ε / 2 * μ a + ε / 2 * μ a := by
      refine' add_le_add _ _
      · rw [ENNReal.div_lt_iff (Or.inl h'a.ne') (Or.inl h''a.ne)] at ha 
        exact ha.le
      · simp only [lintegral_const, measure.restrict_apply, MeasurableSet.univ, univ_inter]
        exact mul_le_mul_right' xc.le _
    _ = ε * μ a := by rw [← add_mul, ENNReal.add_halves]
#align vitali_family.ae_tendsto_lintegral_nnnorm_sub_div' VitaliFamily.ae_tendsto_lintegral_nnnorm_sub_div'
-/

#print VitaliFamily.ae_tendsto_lintegral_nnnorm_sub_div /-
theorem ae_tendsto_lintegral_nnnorm_sub_div {f : α → E} (hf : Integrable f μ) :
    ∀ᵐ x ∂μ, Tendsto (fun a => (∫⁻ y in a, ‖f y - f x‖₊ ∂μ) / μ a) (v.filterAt x) (𝓝 0) :=
  by
  have I : integrable (hf.1.mk f) μ := hf.congr hf.1.ae_eq_mk
  filter_upwards [v.ae_tendsto_lintegral_nnnorm_sub_div' I hf.1.stronglyMeasurable_mk,
    hf.1.ae_eq_mk] with x hx h'x
  apply hx.congr _
  intro a
  congr 1
  apply lintegral_congr_ae
  apply ae_restrict_of_ae
  filter_upwards [hf.1.ae_eq_mk] with y hy
  rw [hy, h'x]
#align vitali_family.ae_tendsto_lintegral_nnnorm_sub_div VitaliFamily.ae_tendsto_lintegral_nnnorm_sub_div
-/

#print VitaliFamily.ae_tendsto_average_norm_sub /-
/-- *Lebesgue differentiation theorem*: for almost every point `x`, the
average of `‖f y - f x‖` on `a` tends to `0` as `a` shrinks to `x` along a Vitali family.-/
theorem ae_tendsto_average_norm_sub {f : α → E} (hf : Integrable f μ) :
    ∀ᵐ x ∂μ, Tendsto (fun a => ⨍ y in a, ‖f y - f x‖ ∂μ) (v.filterAt x) (𝓝 0) :=
  by
  filter_upwards [v.ae_tendsto_lintegral_nnnorm_sub_div hf, v.ae_eventually_measure_pos] with x hx
    h'x
  have := (ENNReal.tendsto_toReal ENNReal.zero_ne_top).comp hx
  simp only [ENNReal.zero_toReal] at this 
  apply tendsto.congr' _ this
  filter_upwards [h'x, v.eventually_measure_lt_top x] with a ha h'a
  simp only [Function.comp_apply, ENNReal.toReal_div, set_average_eq, div_eq_inv_mul]
  have A : integrable_on (fun y => (‖f y - f x‖₊ : ℝ)) a μ :=
    by
    simp_rw [coe_nnnorm]
    exact (hf.integrable_on.sub (integrable_on_const.2 (Or.inr h'a))).norm
  rw [lintegral_coe_eq_integral _ A, ENNReal.toReal_ofReal]
  · simp_rw [coe_nnnorm]
    rfl
  · apply integral_nonneg
    intro x
    exact NNReal.coe_nonneg _
#align vitali_family.ae_tendsto_average_norm_sub VitaliFamily.ae_tendsto_average_norm_sub
-/

#print VitaliFamily.ae_tendsto_average /-
/-- *Lebesgue differentiation theorem*: for almost every point `x`, the
average of `f` on `a` tends to `f x` as `a` shrinks to `x` along a Vitali family.-/
theorem ae_tendsto_average [NormedSpace ℝ E] [CompleteSpace E] {f : α → E} (hf : Integrable f μ) :
    ∀ᵐ x ∂μ, Tendsto (fun a => ⨍ y in a, f y ∂μ) (v.filterAt x) (𝓝 (f x)) :=
  by
  filter_upwards [v.ae_tendsto_average_norm_sub hf, v.ae_eventually_measure_pos] with x hx h'x
  rw [tendsto_iff_norm_tendsto_zero]
  refine' squeeze_zero' (eventually_of_forall fun a => norm_nonneg _) _ hx
  filter_upwards [h'x, v.eventually_measure_lt_top x] with a ha h'a
  nth_rw 1 [← set_average_const ha.ne' h'a.ne (f x)]
  simp_rw [set_average_eq']
  rw [← integral_sub]
  · exact norm_integral_le_integral_norm _
  · exact (integrable_inv_smul_measure ha.ne' h'a.ne).2 hf.integrable_on
  · exact (integrable_inv_smul_measure ha.ne' h'a.ne).2 (integrable_on_const.2 (Or.inr h'a))
#align vitali_family.ae_tendsto_average VitaliFamily.ae_tendsto_average
-/

end

end VitaliFamily

