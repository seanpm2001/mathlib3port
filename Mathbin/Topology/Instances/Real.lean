/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro
-/
import Mathbin.Topology.MetricSpace.Basic
import Mathbin.Topology.Algebra.UniformGroup
import Mathbin.Topology.Algebra.UniformMulAction
import Mathbin.Topology.Algebra.Ring
import Mathbin.Topology.Algebra.Star
import Mathbin.RingTheory.Subring.Basic
import Mathbin.GroupTheory.Archimedean
import Mathbin.Algebra.Order.Group.Bounds
import Mathbin.Algebra.Periodic
import Mathbin.Order.Filter.Archimedean
import Mathbin.Topology.Instances.Int

/-!
# Topological properties of ℝ
-/


noncomputable section

open Classical Filter Int Metric Set TopologicalSpace

open Classical TopologicalSpace Filter uniformity Interval

universe u v w

variable {α : Type u} {β : Type v} {γ : Type w}

instance : NoncompactSpace ℝ :=
  Int.closedEmbeddingCoeReal.NoncompactSpace

theorem Real.uniform_continuous_add : UniformContinuous fun p : ℝ × ℝ => p.1 + p.2 :=
  Metric.uniform_continuous_iff.2 fun ε ε0 =>
    let ⟨δ, δ0, Hδ⟩ := rat_add_continuous_lemma abs ε0
    ⟨δ, δ0, fun a b h =>
      let ⟨h₁, h₂⟩ := max_lt_iff.1 h
      Hδ h₁ h₂⟩
#align real.uniform_continuous_add Real.uniform_continuous_add

theorem Real.uniform_continuous_neg : UniformContinuous (@Neg.neg ℝ _) :=
  Metric.uniform_continuous_iff.2 fun ε ε0 =>
    ⟨_, ε0, fun a b h => by rw [dist_comm] at h <;> simpa [Real.dist_eq] using h⟩
#align real.uniform_continuous_neg Real.uniform_continuous_neg

instance : HasContinuousStar ℝ :=
  ⟨continuous_id⟩

instance : UniformAddGroup ℝ :=
  UniformAddGroup.mk' Real.uniform_continuous_add Real.uniform_continuous_neg

-- short-circuit type class inference
instance : TopologicalAddGroup ℝ := by infer_instance

instance :
    ProperSpace ℝ where is_compact_closed_ball x r := by
    rw [Real.closed_ball_eq_Icc]
    apply is_compact_Icc

instance : SecondCountableTopology ℝ :=
  second_countable_of_proper

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
theorem Real.is_topological_basis_Ioo_rat : @IsTopologicalBasis ℝ _ (⋃ (a : ℚ) (b : ℚ) (h : a < b), {IooCat a b}) :=
  is_topological_basis_of_open_of_nhds (by simp (config := { contextual := true }) [is_open_Ioo]) fun a v hav hv =>
    let ⟨l, u, ⟨hl, hu⟩, h⟩ := mem_nhds_iff_exists_Ioo_subset.mp (IsOpen.mem_nhds hv hav)
    let ⟨q, hlq, hqa⟩ := exists_rat_btwn hl
    let ⟨p, hap, hpu⟩ := exists_rat_btwn hu
    ⟨IooCat q p, by
      simp only [mem_Union]
      exact ⟨q, p, Rat.cast_lt.1 <| hqa.trans hap, rfl⟩, ⟨hqa, hap⟩, fun a' ⟨hqa', ha'p⟩ =>
      h ⟨hlq.trans hqa', ha'p.trans hpu⟩⟩
#align real.is_topological_basis_Ioo_rat Real.is_topological_basis_Ioo_rat

@[simp]
theorem Real.cocompact_eq : cocompact ℝ = at_bot ⊔ at_top := by
  simp only [← comap_dist_right_at_top_eq_cocompact (0 : ℝ), Real.dist_eq, sub_zero, comap_abs_at_top]
#align real.cocompact_eq Real.cocompact_eq

/- TODO(Mario): Prove that these are uniform isomorphisms instead of uniform embeddings
lemma uniform_embedding_add_rat {r : ℚ} : uniform_embedding (λp:ℚ, p + r) :=
_

lemma uniform_embedding_mul_rat {q : ℚ} (hq : q ≠ 0) : uniform_embedding ((*) q) :=
_ -/
theorem Real.mem_closure_iff {s : Set ℝ} {x : ℝ} : x ∈ Closure s ↔ ∀ ε > 0, ∃ y ∈ s, |y - x| < ε := by
  simp [mem_closure_iff_nhds_basis nhds_basis_ball, Real.dist_eq]
#align real.mem_closure_iff Real.mem_closure_iff

theorem Real.uniform_continuous_inv (s : Set ℝ) {r : ℝ} (r0 : 0 < r) (H : ∀ x ∈ s, r ≤ |x|) :
    UniformContinuous fun p : s => p.1⁻¹ :=
  Metric.uniform_continuous_iff.2 fun ε ε0 =>
    let ⟨δ, δ0, Hδ⟩ := rat_inv_continuous_lemma abs ε0 r0
    ⟨δ, δ0, fun a b h => Hδ (H _ a.2) (H _ b.2) h⟩
#align real.uniform_continuous_inv Real.uniform_continuous_inv

theorem Real.uniform_continuous_abs : UniformContinuous (abs : ℝ → ℝ) :=
  Metric.uniform_continuous_iff.2 fun ε ε0 => ⟨ε, ε0, fun a b => lt_of_le_of_lt (abs_abs_sub_abs_le_abs_sub _ _)⟩
#align real.uniform_continuous_abs Real.uniform_continuous_abs

theorem Real.tendsto_inv {r : ℝ} (r0 : r ≠ 0) : Tendsto (fun q => q⁻¹) (𝓝 r) (𝓝 r⁻¹) := by
  rw [← abs_pos] at r0 <;>
    exact
      tendsto_of_uniform_continuous_subtype
        (Real.uniform_continuous_inv { x | |r| / 2 < |x| } (half_pos r0) fun x h => le_of_lt h)
        (IsOpen.mem_nhds ((is_open_lt' (|r| / 2)).Preimage continuous_abs) (half_lt_self r0))
#align real.tendsto_inv Real.tendsto_inv

theorem Real.continuous_inv : Continuous fun a : { r : ℝ // r ≠ 0 } => a.val⁻¹ :=
  continuous_iff_continuous_at.mpr fun ⟨r, hr⟩ =>
    Tendsto.comp (Real.tendsto_inv hr) (continuous_iff_continuous_at.mp continuous_subtype_val _)
#align real.continuous_inv Real.continuous_inv

theorem Real.Continuous.inv [TopologicalSpace α] {f : α → ℝ} (h : ∀ a, f a ≠ 0) (hf : Continuous f) :
    Continuous fun a => (f a)⁻¹ :=
  show Continuous ((Inv.inv ∘ @Subtype.val ℝ fun r => r ≠ 0) ∘ fun a => ⟨f a, h a⟩) from
    Real.continuous_inv.comp (hf.subtype_mk _)
#align real.continuous.inv Real.Continuous.inv

theorem Real.uniform_continuous_const_mul {x : ℝ} : UniformContinuous ((· * ·) x) :=
  uniform_continuous_const_smul x
#align real.uniform_continuous_const_mul Real.uniform_continuous_const_mul

theorem Real.uniform_continuous_mul (s : Set (ℝ × ℝ)) {r₁ r₂ : ℝ} (H : ∀ x ∈ s, |(x : ℝ × ℝ).1| < r₁ ∧ |x.2| < r₂) :
    UniformContinuous fun p : s => p.1.1 * p.1.2 :=
  Metric.uniform_continuous_iff.2 fun ε ε0 =>
    let ⟨δ, δ0, Hδ⟩ := rat_mul_continuous_lemma abs ε0
    ⟨δ, δ0, fun a b h =>
      let ⟨h₁, h₂⟩ := max_lt_iff.1 h
      Hδ (H _ a.2).1 (H _ b.2).2 h₁ h₂⟩
#align real.uniform_continuous_mul Real.uniform_continuous_mul

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
protected theorem Real.continuous_mul : Continuous fun p : ℝ × ℝ => p.1 * p.2 :=
  continuous_iff_continuous_at.2 fun ⟨a₁, a₂⟩ =>
    tendsto_of_uniform_continuous_subtype
      (Real.uniform_continuous_mul ({ x | |x| < |a₁| + 1 } ×ˢ { x | |x| < |a₂| + 1 }) fun x => id)
      (IsOpen.mem_nhds
        (((is_open_gt' (|a₁| + 1)).Preimage continuous_abs).Prod ((is_open_gt' (|a₂| + 1)).Preimage continuous_abs))
        ⟨lt_add_one (|a₁|), lt_add_one (|a₂|)⟩)
#align real.continuous_mul Real.continuous_mul

instance : TopologicalRing ℝ :=
  { Real.topological_add_group with continuous_mul := Real.continuous_mul }

instance : CompleteSpace ℝ := by
  apply complete_of_cauchy_seq_tendsto
  intro u hu
  let c : CauSeq ℝ abs := ⟨u, Metric.cauchy_seq_iff'.1 hu⟩
  refine' ⟨c.lim, fun s h => _⟩
  rcases Metric.mem_nhds_iff.1 h with ⟨ε, ε0, hε⟩
  have := c.equiv_lim ε ε0
  simp only [mem_map, mem_at_top_sets, mem_set_of_eq]
  refine' this.imp fun N hN n hn => hε (hN n hn)

theorem Real.totally_bounded_ball (x ε : ℝ) : TotallyBounded (Ball x ε) := by
  rw [Real.ball_eq_Ioo] <;> apply totally_bounded_Ioo
#align real.totally_bounded_ball Real.totally_bounded_ball

section

theorem closure_of_rat_image_lt {q : ℚ} : Closure ((coe : ℚ → ℝ) '' { x | q < x }) = { r | ↑q ≤ r } :=
  (Subset.antisymm
      ((isClosedGe' _).closure_subset_iff.2 (image_subset_iff.2 fun p h => le_of_lt <| (@Rat.cast_lt ℝ _ _ _).2 h)))
    fun x hx =>
    mem_closure_iff_nhds.2 fun t ht =>
      let ⟨ε, ε0, hε⟩ := Metric.mem_nhds_iff.1 ht
      let ⟨p, h₁, h₂⟩ := exists_rat_btwn ((lt_add_iff_pos_right x).2 ε0)
      ⟨_, hε (show abs _ < _ by rwa [abs_of_nonneg (le_of_lt <| sub_pos.2 h₁), sub_lt_iff_lt_add']), p,
        Rat.cast_lt.1 (@lt_of_le_of_lt ℝ _ _ _ _ hx h₁), rfl⟩
#align closure_of_rat_image_lt closure_of_rat_image_lt

/- TODO(Mario): Put these back only if needed later
lemma closure_of_rat_image_le_eq {q : ℚ} : closure ((coe:ℚ → ℝ) '' {x | q ≤ x}) = {r | ↑q ≤ r} :=
_

lemma closure_of_rat_image_le_le_eq {a b : ℚ} (hab : a ≤ b) :
  closure (of_rat '' {q:ℚ | a ≤ q ∧ q ≤ b}) = {r:ℝ | of_rat a ≤ r ∧ r ≤ of_rat b} :=
_-/
theorem Real.bounded_iff_bdd_below_bdd_above {s : Set ℝ} : Bounded s ↔ BddBelow s ∧ BddAbove s :=
  ⟨by
    intro bdd
    rcases(bounded_iff_subset_ball 0).1 bdd with ⟨r, hr⟩
    -- hr : s ⊆ closed_ball 0 r
    rw [Real.closed_ball_eq_Icc] at hr
    -- hr : s ⊆ Icc (0 - r) (0 + r)
    exact ⟨bdd_below_Icc.mono hr, bdd_above_Icc.mono hr⟩,
    fun h => boundedOfBddAboveOfBddBelow h.2 h.1⟩
#align real.bounded_iff_bdd_below_bdd_above Real.bounded_iff_bdd_below_bdd_above

theorem Real.subset_Icc_Inf_Sup_of_bounded {s : Set ℝ} (h : Bounded s) : s ⊆ IccCat (inf s) (sup s) :=
  subset_Icc_cInf_cSup (Real.bounded_iff_bdd_below_bdd_above.1 h).1 (Real.bounded_iff_bdd_below_bdd_above.1 h).2
#align real.subset_Icc_Inf_Sup_of_bounded Real.subset_Icc_Inf_Sup_of_bounded

end

section Periodic

namespace Function

theorem Periodic.compact_of_continuous' [TopologicalSpace α] {f : ℝ → α} {c : ℝ} (hp : Periodic f c) (hc : 0 < c)
    (hf : Continuous f) : IsCompact (Range f) := by
  convert is_compact_Icc.image hf
  ext x
  refine' ⟨_, mem_range_of_mem_image f (Icc 0 c)⟩
  rintro ⟨y, h1⟩
  obtain ⟨z, hz, h2⟩ := hp.exists_mem_Ico₀ hc y
  exact ⟨z, mem_Icc_of_Ico hz, h2.symm.trans h1⟩
#align function.periodic.compact_of_continuous' Function.Periodic.compact_of_continuous'

/-- A continuous, periodic function has compact range. -/
theorem Periodic.compact_of_continuous [TopologicalSpace α] {f : ℝ → α} {c : ℝ} (hp : Periodic f c) (hc : c ≠ 0)
    (hf : Continuous f) : IsCompact (Range f) := by
  cases' lt_or_gt_of_ne hc with hneg hpos
  exacts[hp.neg.compact_of_continuous' (neg_pos.mpr hneg) hf, hp.compact_of_continuous' hpos hf]
#align function.periodic.compact_of_continuous Function.Periodic.compact_of_continuous

/-- A continuous, periodic function is bounded. -/
theorem Periodic.boundedOfContinuous [PseudoMetricSpace α] {f : ℝ → α} {c : ℝ} (hp : Periodic f c) (hc : c ≠ 0)
    (hf : Continuous f) : Bounded (Range f) :=
  (hp.compact_of_continuous hc hf).Bounded
#align function.periodic.bounded_of_continuous Function.Periodic.boundedOfContinuous

end Function

end Periodic

section Subgroups

namespace Int

open Metric

/-- Under the coercion from `ℤ` to `ℝ`, inverse images of compact sets are finite. -/
theorem tendsto_coe_cofinite : Tendsto (coe : ℤ → ℝ) cofinite (cocompact ℝ) := by
  refine' tendsto_cocompact_of_tendsto_dist_comp_at_top (0 : ℝ) _
  simp only [Filter.tendsto_at_top, eventually_cofinite, not_le, ← mem_ball]
  change ∀ r : ℝ, (coe ⁻¹' ball (0 : ℝ) r).Finite
  simp [Real.ball_eq_Ioo, Set.finite_Ioo]
#align int.tendsto_coe_cofinite Int.tendsto_coe_cofinite

/-- For nonzero `a`, the "multiples of `a`" map `zmultiples_hom` from `ℤ` to `ℝ` is discrete, i.e.
inverse images of compact sets are finite. -/
theorem tendsto_zmultiples_hom_cofinite {a : ℝ} (ha : a ≠ 0) : Tendsto (zmultiplesHom ℝ a) cofinite (cocompact ℝ) := by
  convert (tendsto_cocompact_mul_right₀ ha).comp Int.tendsto_coe_cofinite
  ext n
  simp
#align int.tendsto_zmultiples_hom_cofinite Int.tendsto_zmultiples_hom_cofinite

end Int

namespace AddSubgroup

/-- The subgroup "multiples of `a`" (`zmultiples a`) is a discrete subgroup of `ℝ`, i.e. its
intersection with compact sets is finite. -/
theorem tendsto_zmultiples_subtype_cofinite (a : ℝ) : Tendsto (zmultiples a).Subtype cofinite (cocompact ℝ) := by
  rcases eq_or_ne a 0 with (rfl | ha)
  · rw [AddSubgroup.zmultiples_zero_eq_bot]
    intro K hK
    rw [Filter.mem_map, mem_cofinite]
    apply Set.to_finite
    
  intro K hK
  have H := Int.tendsto_zmultiples_hom_cofinite ha hK
  simp only [Filter.mem_map, mem_cofinite, ← preimage_compl] at H⊢
  rw [← (zmultiplesHom ℝ a).range_restrict_surjective.image_preimage ((zmultiples a).Subtype ⁻¹' Kᶜ), ← preimage_comp, ←
    AddMonoidHom.coe_comp_range_restrict]
  exact finite.image _ H
#align add_subgroup.tendsto_zmultiples_subtype_cofinite AddSubgroup.tendsto_zmultiples_subtype_cofinite

end AddSubgroup

/-- Given a nontrivial subgroup `G ⊆ ℝ`, if `G ∩ ℝ_{>0}` has no minimum then `G` is dense. -/
theorem Real.subgroup_dense_of_no_min {G : AddSubgroup ℝ} {g₀ : ℝ} (g₀_in : g₀ ∈ G) (g₀_ne : g₀ ≠ 0)
    (H' : ¬∃ a : ℝ, IsLeast { g : ℝ | g ∈ G ∧ 0 < g } a) : Dense (G : Set ℝ) := by
  let G_pos := { g : ℝ | g ∈ G ∧ 0 < g }
  push_neg  at H'
  intro x
  suffices ∀ ε > (0 : ℝ), ∃ g ∈ G, |x - g| < ε by simpa only [Real.mem_closure_iff, abs_sub_comm]
  intro ε ε_pos
  obtain ⟨g₁, g₁_in, g₁_pos⟩ : ∃ g₁ : ℝ, g₁ ∈ G ∧ 0 < g₁ := by
    cases' lt_or_gt_of_ne g₀_ne with Hg₀ Hg₀
    · exact ⟨-g₀, G.neg_mem g₀_in, neg_pos.mpr Hg₀⟩
      
    · exact ⟨g₀, g₀_in, Hg₀⟩
      
  obtain ⟨a, ha⟩ : ∃ a, IsGlb G_pos a := ⟨Inf G_pos, is_glb_cInf ⟨g₁, g₁_in, g₁_pos⟩ ⟨0, fun _ hx => le_of_lt hx.2⟩⟩
  have a_notin : a ∉ G_pos := by
    intro H
    exact H' a ⟨H, ha.1⟩
  obtain ⟨g₂, g₂_in, g₂_pos, g₂_lt⟩ : ∃ g₂ : ℝ, g₂ ∈ G ∧ 0 < g₂ ∧ g₂ < ε := by
    obtain ⟨b, hb, hb', hb''⟩ := ha.exists_between_self_add' a_notin ε_pos
    obtain ⟨c, hc, hc', hc''⟩ := ha.exists_between_self_add' a_notin (sub_pos.2 hb')
    refine' ⟨b - c, G.sub_mem hb.1 hc.1, _, _⟩ <;> linarith
  refine' ⟨floor (x / g₂) * g₂, _, _⟩
  · exact AddSubgroup.int_mul_mem _ g₂_in
    
  · rw [abs_of_nonneg (sub_floor_div_mul_nonneg x g₂_pos)]
    linarith [sub_floor_div_mul_lt x g₂_pos]
    
#align real.subgroup_dense_of_no_min Real.subgroup_dense_of_no_min

/-- Subgroups of `ℝ` are either dense or cyclic. See `real.subgroup_dense_of_no_min` and
`subgroup_cyclic_of_min` for more precise statements. -/
theorem Real.subgroup_dense_or_cyclic (G : AddSubgroup ℝ) : Dense (G : Set ℝ) ∨ ∃ a : ℝ, G = AddSubgroup.closure {a} :=
  by
  cases' AddSubgroup.bot_or_exists_ne_zero G with H H
  · right
    use 0
    rw [H, AddSubgroup.closure_singleton_zero]
    
  · let G_pos := { g : ℝ | g ∈ G ∧ 0 < g }
    by_cases H':∃ a, IsLeast G_pos a
    · right
      rcases H' with ⟨a, ha⟩
      exact ⟨a, AddSubgroup.cyclic_of_min ha⟩
      
    · left
      rcases H with ⟨g₀, g₀_in, g₀_ne⟩
      exact Real.subgroup_dense_of_no_min g₀_in g₀_ne H'
      
    
#align real.subgroup_dense_or_cyclic Real.subgroup_dense_or_cyclic

end Subgroups

