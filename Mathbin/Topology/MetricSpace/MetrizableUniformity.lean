/-
Copyright (c) 2022 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module topology.metric_space.metrizable_uniformity
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.MetricSpace.Metrizable

/-!
# Metrizable uniform spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that a uniform space with countably generated uniformity filter is
pseudometrizable: there exists a `pseudo_metric_space` structure that generates the same uniformity.
The proof follows [Sergey Melikhov, Metrizable uniform spaces][melikhov2011].
## Main definitions

* `pseudo_metric_space.of_prenndist`: given a function `d : X → X → ℝ≥0` such that `d x x = 0` and
  `d x y = d y x` for all `x y : X`, constructs the maximal pseudo metric space structure such that
  `nndist x y ≤ d x y` for all `x y : X`.

* `uniform_space.pseudo_metric_space`: given a uniform space `X` with countably generated `𝓤 X`,
  constructs a `pseudo_metric_space X` instance that is compatible with the uniform space structure.

* `uniform_space.metric_space`: given a T₀ uniform space `X` with countably generated `𝓤 X`,
  constructs a `metric_space X` instance that is compatible with the uniform space structure.

## Main statements

* `uniform_space.metrizable_uniformity`: if `X` is a uniform space with countably generated `𝓤 X`,
  then there exists a `pseudo_metric_space` structure that is compatible with this `uniform_space`
  structure. Use `uniform_space.pseudo_metric_space` or `uniform_space.metric_space` instead.

* `uniform_space.pseudo_metrizable_space`: a uniform space with countably generated `𝓤 X` is pseudo
  metrizable.

* `uniform_space.metrizable_space`: a T₀ uniform space with countably generated `𝓤 X` is
  metrizable. This is not an instance to avoid loops.

## Tags

metrizable space, uniform space
-/


open Set Function Metric List Filter

open scoped NNReal Filter uniformity

variable {X : Type _}

namespace PseudoMetricSpace

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print PseudoMetricSpace.ofPreNNDist /-
/-- The maximal pseudo metric space structure on `X` such that `dist x y ≤ d x y` for all `x y`,
where `d : X → X → ℝ≥0` is a function such that `d x x = 0` and `d x y = d y x` for all `x`, `y`. -/
noncomputable def ofPreNNDist (d : X → X → ℝ≥0) (dist_self : ∀ x, d x x = 0)
    (dist_comm : ∀ x y, d x y = d y x) : PseudoMetricSpace X
    where
  dist x y := ↑(⨅ l : List X, ((x::l).zipWith d (l ++ [y])).Sum : ℝ≥0)
  dist_self x :=
    (NNReal.coe_eq_zero _).2 <|
      nonpos_iff_eq_zero.1 <| (ciInf_le (OrderBot.bddBelow _) []).trans_eq <| by simp [dist_self]
  dist_comm x y :=
    NNReal.coe_eq.2 <| by
      refine' reverse_surjective.infi_congr _ fun l => _
      rw [← sum_reverse, zip_with_distrib_reverse, reverse_append, reverse_reverse,
        reverse_singleton, singleton_append, reverse_cons, reverse_reverse,
        zip_with_comm_of_comm _ dist_comm]
      simp only [length, length_append]
  dist_triangle x y z := by
    rw [← NNReal.coe_add, NNReal.coe_le_coe]
    refine' NNReal.le_iInf_add_iInf fun lxy lyz => _
    calc
      (⨅ l, (zip_with d (x::l) (l ++ [z])).Sum) ≤
          (zip_with d (x::lxy ++ y::lyz) ((lxy ++ y::lyz) ++ [z])).Sum :=
        ciInf_le (OrderBot.bddBelow _) (lxy ++ y::lyz)
      _ = (zip_with d (x::lxy) (lxy ++ [y])).Sum + (zip_with d (y::lyz) (lyz ++ [z])).Sum := _
    rw [← sum_append, ← zip_with_append, cons_append, ← @singleton_append _ y, append_assoc,
      append_assoc, append_assoc]
    rw [length_cons, length_append, length_singleton]
#align pseudo_metric_space.of_prenndist PseudoMetricSpace.ofPreNNDist
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print PseudoMetricSpace.dist_ofPreNNDist /-
theorem dist_ofPreNNDist (d : X → X → ℝ≥0) (dist_self : ∀ x, d x x = 0)
    (dist_comm : ∀ x y, d x y = d y x) (x y : X) :
    @dist X (@PseudoMetricSpace.toHasDist X (PseudoMetricSpace.ofPreNNDist d dist_self dist_comm)) x
        y =
      ↑(⨅ l : List X, ((x::l).zipWith d (l ++ [y])).Sum : ℝ≥0) :=
  rfl
#align pseudo_metric_space.dist_of_prenndist PseudoMetricSpace.dist_ofPreNNDist
-/

#print PseudoMetricSpace.dist_ofPreNNDist_le /-
theorem dist_ofPreNNDist_le (d : X → X → ℝ≥0) (dist_self : ∀ x, d x x = 0)
    (dist_comm : ∀ x y, d x y = d y x) (x y : X) :
    @dist X (@PseudoMetricSpace.toHasDist X (PseudoMetricSpace.ofPreNNDist d dist_self dist_comm)) x
        y ≤
      d x y :=
  NNReal.coe_le_coe.2 <| (ciInf_le (OrderBot.bddBelow _) []).trans_eq <| by simp
#align pseudo_metric_space.dist_of_prenndist_le PseudoMetricSpace.dist_ofPreNNDist_le
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print PseudoMetricSpace.le_two_mul_dist_ofPreNNDist /-
/-- Consider a function `d : X → X → ℝ≥0` such that `d x x = 0` and `d x y = d y x` for all `x`,
`y`. Let `dist` be the largest pseudometric distance such that `dist x y ≤ d x y`, see
`pseudo_metric_space.of_prenndist`. Suppose that `d` satisfies the following triangle-like
inequality: `d x₁ x₄ ≤ 2 * max (d x₁ x₂, d x₂ x₃, d x₃ x₄)`. Then `d x y ≤ 2 * dist x y` for all
`x`, `y`. -/
theorem le_two_mul_dist_ofPreNNDist (d : X → X → ℝ≥0) (dist_self : ∀ x, d x x = 0)
    (dist_comm : ∀ x y, d x y = d y x)
    (hd : ∀ x₁ x₂ x₃ x₄, d x₁ x₄ ≤ 2 * max (d x₁ x₂) (max (d x₂ x₃) (d x₃ x₄))) (x y : X) :
    ↑(d x y) ≤
      2 *
        @dist X
          (@PseudoMetricSpace.toHasDist X (PseudoMetricSpace.ofPreNNDist d dist_self dist_comm)) x
          y :=
  by
  /- We need to show that `d x y` is at most twice the sum `L` of `d xᵢ xᵢ₊₁` over a path
    `x₀=x, ..., xₙ=y`. We prove it by induction on the length `n` of the sequence. Find an edge that
    splits the path into two parts of almost equal length: both `d x₀ x₁ + ... + d xₖ₋₁ xₖ` and
    `d xₖ₊₁ xₖ₊₂ + ... + d xₙ₋₁ xₙ` are less than or equal to `L / 2`.
    Then `d x₀ xₖ ≤ L`, `d xₖ xₖ₊₁ ≤ L`, and `d xₖ₊₁ xₙ ≤ L`, thus `d x₀ xₙ ≤ 2 * L`. -/
  rw [dist_of_prenndist, ← NNReal.coe_two, ← NNReal.coe_mul, NNReal.mul_iInf, NNReal.coe_le_coe]
  refine' le_ciInf fun l => _
  have hd₀_trans : Transitive fun x y => d x y = 0 :=
    by
    intro a b c hab hbc
    rw [← nonpos_iff_eq_zero]
    simpa only [*, max_eq_right, MulZeroClass.mul_zero] using hd a b c c
  haveI : IsTrans X fun x y => d x y = 0 := ⟨hd₀_trans⟩
  induction' hn : length l using Nat.strong_induction_on with n ihn generalizing x y l
  simp only at ihn ; subst n
  set L := zip_with d (x::l) (l ++ [y])
  have hL_len : length L = length l + 1 := by simp
  cases' eq_or_ne (d x y) 0 with hd₀ hd₀; · simp only [hd₀, zero_le]
  rsuffices ⟨z, z', hxz, hzz', hz'y⟩ : ∃ z z' : X, d x z ≤ L.sum ∧ d z z' ≤ L.sum ∧ d z' y ≤ L.sum
  · exact (hd x z z' y).trans (mul_le_mul_left' (max_le hxz (max_le hzz' hz'y)) _)
  set s : Set ℕ := {m : ℕ | 2 * (take m L).Sum ≤ L.sum}
  have hs₀ : 0 ∈ s := by simp [s]
  have hsne : s.nonempty := ⟨0, hs₀⟩
  obtain ⟨M, hMl, hMs⟩ : ∃ M ≤ length l, IsGreatest s M :=
    by
    have hs_ub : length l ∈ upperBounds s := by
      intro m hm
      rw [← not_lt, Nat.lt_iff_add_one_le, ← hL_len]
      intro hLm
      rw [mem_set_of_eq, take_all_of_le hLm, two_mul, add_le_iff_nonpos_left, nonpos_iff_eq_zero,
          sum_eq_zero_iff, ← all₂_iff_forall, all₂_zip_with, ←
          chain_append_singleton_iff_forall₂] at hm  <;>
        [skip; · simp]
      exact hd₀ (hm.rel (mem_append.2 <| Or.inr <| mem_singleton_self _))
    have hs_bdd : BddAbove s := ⟨length l, hs_ub⟩
    exact ⟨Sup s, csSup_le hsne hs_ub, ⟨Nat.sSup_mem hsne hs_bdd, fun k => le_csSup hs_bdd⟩⟩
  have hM_lt : M < length L := by rwa [hL_len, Nat.lt_succ_iff]
  have hM_ltx : M < length (x::l) := lt_length_left_of_zip_with hM_lt
  have hM_lty : M < length (l ++ [y]) := lt_length_right_of_zip_with hM_lt
  refine' ⟨(x::l).nthLe M hM_ltx, (l ++ [y]).nthLe M hM_lty, _, _, _⟩
  · cases M; · simp [dist_self]
    rw [Nat.succ_le_iff] at hMl 
    have hMl' : length (take M l) = M := (length_take _ _).trans (min_eq_left hMl.le)
    simp only [nth_le]
    refine' (ihn _ hMl _ _ _ hMl').trans _
    convert hMs.1.out
    rw [zip_with_distrib_take, take, take_succ, nth_append hMl, nth_le_nth hMl, ← Option.coe_def,
      Option.to_list_some, take_append_of_le_length hMl.le]
    rfl
  · refine' single_le_sum (fun x hx => zero_le x) _ (mem_iff_nth_le.2 ⟨M, hM_lt, _⟩)
    apply nth_le_zip_with
  · rcases hMl.eq_or_lt with (rfl | hMl)
    · simp only [nth_le_append_right le_rfl, sub_self, nth_le_singleton, dist_self, zero_le]
    rw [nth_le_append _ hMl]
    have hlen : length (drop (M + 1) l) = length l - (M + 1) := length_drop _ _
    have hlen_lt : length l - (M + 1) < length l := Nat.sub_lt_of_pos_le _ _ M.succ_pos hMl
    refine' (ihn _ hlen_lt _ y _ hlen).trans _
    rw [cons_nth_le_drop_succ]
    have hMs' : L.sum ≤ 2 * (L.take (M + 1)).Sum :=
      not_lt.1 fun h => (hMs.2 h.le).not_lt M.lt_succ_self
    rw [← sum_take_add_sum_drop L (M + 1), two_mul, add_le_add_iff_left, ← add_le_add_iff_right,
      sum_take_add_sum_drop, ← two_mul] at hMs' 
    convert hMs'
    rwa [zip_with_distrib_drop, drop, drop_append_of_le_length]
#align pseudo_metric_space.le_two_mul_dist_of_prenndist PseudoMetricSpace.le_two_mul_dist_ofPreNNDist
-/

end PseudoMetricSpace

#print UniformSpace.metrizable_uniformity /-
/-- If `X` is a uniform space with countably generated uniformity filter, there exists a
`pseudo_metric_space` structure compatible with the `uniform_space` structure. Use
`uniform_space.pseudo_metric_space` or `uniform_space.metric_space` instead. -/
protected theorem UniformSpace.metrizable_uniformity (X : Type _) [UniformSpace X]
    [IsCountablyGenerated (𝓤 X)] : ∃ I : PseudoMetricSpace X, I.toUniformSpace = ‹_› := by
  classical
  /- Choose a fast decreasing antitone basis `U : ℕ → set (X × X)` of the uniformity filter `𝓤 X`.
    Define `d x y : ℝ≥0` to be `(1 / 2) ^ n`, where `n` is the minimal index of `U n` that separates
    `x` and `y`: `(x, y) ∉ U n`, or `0` if `x` is not separated from `y`. This function satisfies the
    assumptions of `pseudo_metric_space.of_prenndist` and
    `pseudo_metric_space.le_two_mul_dist_of_prenndist`, hence the distance given by the former pseudo
    metric space structure is Lipschitz equivalent to the `d`. Thus the uniformities generated by
    `d` and `dist` are equal. Since the former uniformity is equal to `𝓤 X`, the latter is equal to
    `𝓤 X` as well. -/
  obtain ⟨U, hU_symm, hU_comp, hB⟩ :
    ∃ U : ℕ → Set (X × X),
      (∀ n, SymmetricRel (U n)) ∧
        (∀ ⦃m n⦄, m < n → U n ○ (U n ○ U n) ⊆ U m) ∧ (𝓤 X).HasAntitoneBasis U :=
    by
    rcases UniformSpace.has_seq_basis X with ⟨V, hB, hV_symm⟩
    rcases hB.subbasis_with_rel fun m =>
        hB.tendsto_small_sets.eventually
          (eventually_uniformity_iterate_comp_subset (hB.mem m) 2) with
      ⟨φ, hφ_mono, hφ_comp, hφB⟩
    exact ⟨V ∘ φ, fun n => hV_symm _, hφ_comp, hφB⟩
  letI := UniformSpace.separationSetoid X
  set d : X → X → ℝ≥0 := fun x y => if h : ∃ n, (x, y) ∉ U n then (1 / 2) ^ Nat.find h else 0
  have hd₀ : ∀ {x y}, d x y = 0 ↔ x ≈ y := by
    intro x y; dsimp only [d]
    refine' Iff.trans _ hB.to_has_basis.mem_separation_rel.symm
    simp only [true_imp_iff]
    split_ifs with h
    · rw [← not_forall] at h ; simp [h, pow_eq_zero_iff']
    · simpa only [not_exists, Classical.not_not, eq_self_iff_true, true_iff_iff] using h
  have hd_symm : ∀ x y, d x y = d y x := by
    intro x y; dsimp only [d]
    simp only [@SymmetricRel.mk_mem_comm _ _ (hU_symm _) x y]
  have hr : (1 / 2 : ℝ≥0) ∈ Ioo (0 : ℝ≥0) 1 := ⟨half_pos one_pos, NNReal.half_lt_self one_ne_zero⟩
  letI I := PseudoMetricSpace.ofPreNNDist d (fun x => hd₀.2 (Setoid.refl _)) hd_symm
  have hdist_le : ∀ x y, dist x y ≤ d x y := PseudoMetricSpace.dist_ofPreNNDist_le _ _ _
  have hle_d : ∀ {x y : X} {n : ℕ}, (1 / 2) ^ n ≤ d x y ↔ (x, y) ∉ U n :=
    by
    intro x y n
    simp only [d]; split_ifs with h
    · rw [(strictAnti_pow hr.1 hr.2).le_iff_le, Nat.find_le_iff]
      exact ⟨fun ⟨m, hmn, hm⟩ hn => hm (hB.antitone hmn hn), fun h => ⟨n, le_rfl, h⟩⟩
    · push_neg at h 
      simp only [h, not_true, (pow_pos hr.1 _).not_le]
  have hd_le : ∀ x y, ↑(d x y) ≤ 2 * dist x y :=
    by
    refine' PseudoMetricSpace.le_two_mul_dist_ofPreNNDist _ _ _ fun x₁ x₂ x₃ x₄ => _
    by_cases H : ∃ n, (x₁, x₄) ∉ U n
    · refine' (dif_pos H).trans_le _
      rw [← NNReal.div_le_iff' two_ne_zero, ← mul_one_div (_ ^ _), ← pow_succ']
      simp only [le_max_iff, hle_d, ← not_and_or]
      rintro ⟨h₁₂, h₂₃, h₃₄⟩
      refine' Nat.find_spec H (hU_comp (lt_add_one <| Nat.find H) _)
      exact ⟨x₂, h₁₂, x₃, h₂₃, h₃₄⟩
    · exact (dif_neg H).trans_le (zero_le _)
  refine' ⟨I, uniformSpace_eq <| (uniformity_basis_dist_pow hr.1 hr.2).ext hB.to_has_basis _ _⟩
  · refine' fun n hn => ⟨n, hn, fun x hx => (hdist_le _ _).trans_lt _⟩
    rwa [← NNReal.coe_pow, NNReal.coe_lt_coe, ← not_le, hle_d, Classical.not_not, Prod.mk.eta]
  · refine' fun n hn => ⟨n + 1, trivial, fun x hx => _⟩
    rw [mem_set_of_eq] at hx 
    contrapose! hx
    refine' le_trans _ ((div_le_iff' (zero_lt_two' ℝ)).2 (hd_le x.1 x.2))
    rwa [← NNReal.coe_two, ← NNReal.coe_div, ← NNReal.coe_pow, NNReal.coe_le_coe, pow_succ',
      mul_one_div, NNReal.div_le_iff two_ne_zero, div_mul_cancel _ (two_ne_zero' ℝ≥0), hle_d,
      Prod.mk.eta]
#align uniform_space.metrizable_uniformity UniformSpace.metrizable_uniformity
-/

#print UniformSpace.pseudoMetricSpace /-
/-- A `pseudo_metric_space` instance compatible with a given `uniform_space` structure. -/
protected noncomputable def UniformSpace.pseudoMetricSpace (X : Type _) [UniformSpace X]
    [IsCountablyGenerated (𝓤 X)] : PseudoMetricSpace X :=
  (UniformSpace.metrizable_uniformity X).some.replaceUniformity <|
    congr_arg _ (UniformSpace.metrizable_uniformity X).choose_spec.symm
#align uniform_space.pseudo_metric_space UniformSpace.pseudoMetricSpace
-/

#print UniformSpace.metricSpace /-
/-- A `metric_space` instance compatible with a given `uniform_space` structure. -/
protected noncomputable def UniformSpace.metricSpace (X : Type _) [UniformSpace X]
    [IsCountablyGenerated (𝓤 X)] [T0Space X] : MetricSpace X :=
  @MetricSpace.ofT0PseudoMetricSpace X (UniformSpace.pseudoMetricSpace X) _
#align uniform_space.metric_space UniformSpace.metricSpace
-/

#print UniformSpace.pseudoMetrizableSpace /-
/-- A uniform space with countably generated `𝓤 X` is pseudo metrizable. -/
instance (priority := 100) UniformSpace.pseudoMetrizableSpace [UniformSpace X]
    [IsCountablyGenerated (𝓤 X)] : TopologicalSpace.PseudoMetrizableSpace X := by
  letI := UniformSpace.pseudoMetricSpace X; infer_instance
#align uniform_space.pseudo_metrizable_space UniformSpace.pseudoMetrizableSpace
-/

#print UniformSpace.metrizableSpace /-
/-- A T₀ uniform space with countably generated `𝓤 X` is metrizable. This is not an instance to
avoid loops. -/
theorem UniformSpace.metrizableSpace [UniformSpace X] [IsCountablyGenerated (𝓤 X)] [T0Space X] :
    TopologicalSpace.MetrizableSpace X := by letI := UniformSpace.metricSpace X; infer_instance
#align uniform_space.metrizable_space UniformSpace.metrizableSpace
-/

