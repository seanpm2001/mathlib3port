/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module analysis.calculus.bump_function_findim
! leanprover-community/mathlib commit fdc286cc6967a012f41b87f76dcd2797b53152af
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Calculus.Series
import Mathbin.Analysis.Convolution
import Mathbin.Analysis.InnerProductSpace.EuclideanDist
import Mathbin.MeasureTheory.Measure.Haar.NormedSpace
import Mathbin.Data.Set.Pointwise.Support

/-!
# Bump functions in finite-dimensional vector spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Let `E` be a finite-dimensional real normed vector space. We show that any open set `s` in `E` is
exactly the support of a smooth function taking values in `[0, 1]`,
in `is_open.exists_smooth_support_eq`.

Then we use this construction to construct bump functions with nice behavior, by convolving
the indicator function of `closed_ball 0 1` with a function as above with `s = ball 0 D`.
-/


noncomputable section

open Set Metric TopologicalSpace Function Asymptotics MeasureTheory FiniteDimensional
  ContinuousLinearMap Filter MeasureTheory.Measure

open scoped Pointwise Topology NNReal BigOperators convolution

variable {E : Type _} [NormedAddCommGroup E]

section

variable [NormedSpace ℝ E] [FiniteDimensional ℝ E]

#print exists_smooth_tsupport_subset /-
/-- If a set `s` is a neighborhood of `x`, then there exists a smooth function `f` taking
values in `[0, 1]`, supported in `s` and with `f x = 1`. -/
theorem exists_smooth_tsupport_subset {s : Set E} {x : E} (hs : s ∈ 𝓝 x) :
    ∃ f : E → ℝ,
      tsupport f ⊆ s ∧ HasCompactSupport f ∧ ContDiff ℝ ⊤ f ∧ range f ⊆ Icc 0 1 ∧ f x = 1 :=
  by
  obtain ⟨d, d_pos, hd⟩ : ∃ (d : ℝ) (hr : 0 < d), Euclidean.closedBall x d ⊆ s
  exact euclidean.nhds_basis_closed_ball.mem_iff.1 hs
  let c : ContDiffBump (toEuclidean x) :=
    { R := d / 2
      rOut := d
      rIn_pos := half_pos d_pos
      rIn_lt_rOut := half_lt_self d_pos }
  let f : E → ℝ := c ∘ toEuclidean
  have f_supp : f.support ⊆ Euclidean.ball x d :=
    by
    intro y hy
    have : toEuclidean y ∈ Function.support c := by
      simpa only [f, Function.mem_support, Function.comp_apply, Ne.def] using hy
    rwa [c.support_eq] at this 
  have f_tsupp : tsupport f ⊆ Euclidean.closedBall x d :=
    by
    rw [tsupport, ← Euclidean.closure_ball _ d_pos.ne']
    exact closure_mono f_supp
  refine' ⟨f, f_tsupp.trans hd, _, _, _, _⟩
  · refine' is_compact_of_is_closed_bounded isClosed_closure _
    have : bounded (Euclidean.closedBall x d) := euclidean.is_compact_closed_ball.bounded
    apply this.mono _
    refine' (IsClosed.closure_subset_iff Euclidean.isClosed_closedBall).2 _
    exact f_supp.trans Euclidean.ball_subset_closedBall
  · apply c.cont_diff.comp
    exact ContinuousLinearEquiv.contDiff _
  · rintro t ⟨y, rfl⟩
    exact ⟨c.nonneg, c.le_one⟩
  · apply c.one_of_mem_closed_ball
    apply mem_closed_ball_self
    exact (half_pos d_pos).le
#align exists_smooth_tsupport_subset exists_smooth_tsupport_subset
-/

#print IsOpen.exists_smooth_support_eq /-
/-- Given an open set `s` in a finite-dimensional real normed vector space, there exists a smooth
function with values in `[0, 1]` whose support is exactly `s`. -/
theorem IsOpen.exists_smooth_support_eq {s : Set E} (hs : IsOpen s) :
    ∃ f : E → ℝ, f.support = s ∧ ContDiff ℝ ⊤ f ∧ Set.range f ⊆ Set.Icc 0 1 :=
  by
  /- For any given point `x` in `s`, one can construct a smooth function with support in `s` and
    nonzero at `x`. By second-countability, it follows that we may cover `s` with the supports of
    countably many such functions, say `g i`.
    Then `∑ i, r i • g i` will be the desired function if `r i` is a sequence of positive numbers
    tending quickly enough to zero. Indeed, this ensures that, for any `k ≤ i`, the `k`-th derivative
    of `r i • g i` is bounded by a prescribed (summable) sequence `u i`. From this, the summability
    of the series and of its successive derivatives follows. -/
  rcases eq_empty_or_nonempty s with (rfl | h's)
  ·
    exact
      ⟨fun x => 0, Function.support_zero, contDiff_const, by
        simp only [range_const, singleton_subset_iff, left_mem_Icc, zero_le_one]⟩
  let ι := { f : E → ℝ // f.support ⊆ s ∧ HasCompactSupport f ∧ ContDiff ℝ ⊤ f ∧ range f ⊆ Icc 0 1 }
  obtain ⟨T, T_count, hT⟩ : ∃ T : Set ι, T.Countable ∧ (⋃ f ∈ T, support (f : E → ℝ)) = s :=
    by
    have : (⋃ f : ι, (f : E → ℝ).support) = s :=
      by
      refine' subset.antisymm (Union_subset fun f => f.2.1) _
      intro x hx
      rcases exists_smooth_tsupport_subset (hs.mem_nhds hx) with ⟨f, hf⟩
      let g : ι := ⟨f, (subset_tsupport f).trans hf.1, hf.2.1, hf.2.2.1, hf.2.2.2.1⟩
      have : x ∈ support (g : E → ℝ) := by
        simp only [hf.2.2.2.2, Subtype.coe_mk, mem_support, Ne.def, one_ne_zero, not_false_iff]
      exact mem_Union_of_mem _ this
    simp_rw [← this]
    apply is_open_Union_countable
    rintro ⟨f, hf⟩
    exact hf.2.2.1.Continuous.isOpen_support
  obtain ⟨g0, hg⟩ : ∃ g0 : ℕ → ι, T = range g0 :=
    by
    apply countable.exists_eq_range T_count
    rcases eq_empty_or_nonempty T with (rfl | hT)
    · simp only [Union_false, Union_empty] at hT 
      simp only [← hT, not_nonempty_empty] at h's 
      exact h's.elim
    · exact hT
  let g : ℕ → E → ℝ := fun n => (g0 n).1
  have g_s : ∀ n, support (g n) ⊆ s := fun n => (g0 n).2.1
  have s_g : ∀ x ∈ s, ∃ n, x ∈ support (g n) :=
    by
    intro x hx
    rw [← hT] at hx 
    obtain ⟨i, iT, hi⟩ : ∃ (i : ι) (hi : i ∈ T), x ∈ support (i : E → ℝ) := by
      simpa only [mem_Union] using hx
    rw [hg, mem_range] at iT 
    rcases iT with ⟨n, hn⟩
    rw [← hn] at hi 
    exact ⟨n, hi⟩
  have g_smooth : ∀ n, ContDiff ℝ ⊤ (g n) := fun n => (g0 n).2.2.2.1
  have g_comp_supp : ∀ n, HasCompactSupport (g n) := fun n => (g0 n).2.2.1
  have g_nonneg : ∀ n x, 0 ≤ g n x := fun n x => ((g0 n).2.2.2.2 (mem_range_self x)).1
  obtain ⟨δ, δpos, c, δc, c_lt⟩ :
    ∃ δ : ℕ → ℝ≥0, (∀ i : ℕ, 0 < δ i) ∧ ∃ c : NNReal, HasSum δ c ∧ c < 1
  exact NNReal.exists_pos_sum_of_countable one_ne_zero ℕ
  have : ∀ n : ℕ, ∃ r : ℝ, 0 < r ∧ ∀ i ≤ n, ∀ x, ‖iteratedFDeriv ℝ i (r • g n) x‖ ≤ δ n :=
    by
    intro n
    have : ∀ i, ∃ R, ∀ x, ‖iteratedFDeriv ℝ i (fun x => g n x) x‖ ≤ R :=
      by
      intro i
      have : BddAbove (range fun x => ‖iteratedFDeriv ℝ i (fun x : E => g n x) x‖) :=
        by
        apply
          ((g_smooth n).continuous_iteratedFDeriv le_top).norm.bddAbove_range_of_hasCompactSupport
        apply HasCompactSupport.comp_left _ norm_zero
        apply (g_comp_supp n).iteratedFDeriv
      rcases this with ⟨R, hR⟩
      exact ⟨R, fun x => hR (mem_range_self _)⟩
    choose R hR using this
    let M := max (((Finset.range (n + 1)).image R).max' (by simp)) 1
    have M_pos : 0 < M := zero_lt_one.trans_le (le_max_right _ _)
    have δnpos : 0 < δ n := δpos n
    have IR : ∀ i ≤ n, R i ≤ M := by
      intro i hi
      refine' le_trans _ (le_max_left _ _)
      apply Finset.le_max'
      apply Finset.mem_image_of_mem
      simp only [Finset.mem_range]
      linarith
    refine' ⟨M⁻¹ * δ n, by positivity, fun i hi x => _⟩
    calc
      ‖iteratedFDeriv ℝ i ((M⁻¹ * δ n) • g n) x‖ = ‖(M⁻¹ * δ n) • iteratedFDeriv ℝ i (g n) x‖ := by
        rw [iteratedFDeriv_const_smul_apply]; exact (g_smooth n).of_le le_top
      _ = M⁻¹ * δ n * ‖iteratedFDeriv ℝ i (g n) x‖ := by rw [norm_smul, Real.norm_of_nonneg];
        positivity
      _ ≤ M⁻¹ * δ n * M := (mul_le_mul_of_nonneg_left ((hR i x).trans (IR i hi)) (by positivity))
      _ = δ n := by field_simp [M_pos.ne']
  choose r rpos hr using this
  have S : ∀ x, Summable fun n => (r n • g n) x :=
    by
    intro x
    refine' summable_of_nnnorm_bounded _ δc.summable fun n => _
    rw [← NNReal.coe_le_coe, coe_nnnorm]
    simpa only [norm_iteratedFDeriv_zero] using hr n 0 (zero_le n) x
  refine' ⟨fun x => ∑' n, (r n • g n) x, _, _, _⟩
  · apply subset.antisymm
    · intro x hx
      simp only [Pi.smul_apply, Algebra.id.smul_eq_mul, mem_support, Ne.def] at hx 
      contrapose! hx
      have : ∀ n, g n x = 0 := by
        intro n
        contrapose! hx
        exact g_s n hx
      simp only [this, MulZeroClass.mul_zero, tsum_zero]
    · intro x hx
      obtain ⟨n, hn⟩ : ∃ n, x ∈ support (g n); exact s_g x hx
      have I : 0 < r n * g n x := mul_pos (rpos n) (lt_of_le_of_ne (g_nonneg n x) (Ne.symm hn))
      exact ne_of_gt (tsum_pos (S x) (fun i => mul_nonneg (rpos i).le (g_nonneg i x)) n I)
  · refine'
      contDiff_tsum_of_eventually (fun n => (g_smooth n).const_smul _)
        (fun k hk => (NNReal.hasSum_coe.2 δc).Summable) _
    intro i hi
    simp only [Nat.cofinite_eq_atTop, Pi.smul_apply, Algebra.id.smul_eq_mul,
      Filter.eventually_atTop, ge_iff_le]
    exact ⟨i, fun n hn x => hr _ _ hn _⟩
  · rintro - ⟨y, rfl⟩
    refine' ⟨tsum_nonneg fun n => mul_nonneg (rpos n).le (g_nonneg n y), le_trans _ c_lt.le⟩
    have A : HasSum (fun n => (δ n : ℝ)) c := NNReal.hasSum_coe.2 δc
    rw [← A.tsum_eq]
    apply tsum_le_tsum _ (S y) A.summable
    intro n
    apply (le_abs_self _).trans
    simpa only [norm_iteratedFDeriv_zero] using hr n 0 (zero_le n) y
#align is_open.exists_smooth_support_eq IsOpen.exists_smooth_support_eq
-/

end

section

namespace ExistsContDiffBumpBase

#print ExistsContDiffBumpBase.φ /-
/-- An auxiliary function to construct partitions of unity on finite-dimensional real vector spaces.
It is the characteristic function of the closed unit ball. -/
def φ : E → ℝ :=
  (closedBall (0 : E) 1).indicator fun y => (1 : ℝ)
#align exists_cont_diff_bump_base.φ ExistsContDiffBumpBase.φ
-/

variable [NormedSpace ℝ E] [FiniteDimensional ℝ E]

section HelperDefinitions

variable (E)

#print ExistsContDiffBumpBase.u_exists /-
theorem u_exists :
    ∃ u : E → ℝ,
      ContDiff ℝ ⊤ u ∧ (∀ x, u x ∈ Icc (0 : ℝ) 1) ∧ support u = ball 0 1 ∧ ∀ x, u (-x) = u x :=
  by
  have A : IsOpen (ball (0 : E) 1) := is_open_ball
  obtain ⟨f, f_support, f_smooth, f_range⟩ :
    ∃ f : E → ℝ, f.support = ball (0 : E) 1 ∧ ContDiff ℝ ⊤ f ∧ Set.range f ⊆ Set.Icc 0 1
  exact A.exists_smooth_support_eq
  have B : ∀ x, f x ∈ Icc (0 : ℝ) 1 := fun x => f_range (mem_range_self x)
  refine' ⟨fun x => (f x + f (-x)) / 2, _, _, _, _⟩
  · exact (f_smooth.add (f_smooth.comp contDiff_neg)).div_const _
  · intro x
    constructor
    · linarith [(B x).1, (B (-x)).1]
    · linarith [(B x).2, (B (-x)).2]
  · refine' support_eq_iff.2 ⟨fun x hx => _, fun x hx => _⟩
    · apply ne_of_gt
      have : 0 < f x := by
        apply lt_of_le_of_ne (B x).1 (Ne.symm _)
        rwa [← f_support] at hx 
      linarith [(B (-x)).1]
    · have I1 : x ∉ support f := by rwa [f_support]
      have I2 : -x ∉ support f := by
        rw [f_support]
        simp only at hx 
        simpa using hx
      simp only [mem_support, Classical.not_not] at I1 I2 
      simp only [I1, I2, add_zero, zero_div]
  · intro x; simp only [add_comm, neg_neg]
#align exists_cont_diff_bump_base.u_exists ExistsContDiffBumpBase.u_exists
-/

variable {E}

#print ExistsContDiffBumpBase.u /-
/-- An auxiliary function to construct partitions of unity on finite-dimensional real vector spaces,
which is smooth, symmetric, and with support equal to the unit ball. -/
def u (x : E) : ℝ :=
  Classical.choose (u_exists E) x
#align exists_cont_diff_bump_base.u ExistsContDiffBumpBase.u
-/

variable (E)

#print ExistsContDiffBumpBase.u_smooth /-
theorem u_smooth : ContDiff ℝ ⊤ (u : E → ℝ) :=
  (Classical.choose_spec (u_exists E)).1
#align exists_cont_diff_bump_base.u_smooth ExistsContDiffBumpBase.u_smooth
-/

#print ExistsContDiffBumpBase.u_continuous /-
theorem u_continuous : Continuous (u : E → ℝ) :=
  (u_smooth E).Continuous
#align exists_cont_diff_bump_base.u_continuous ExistsContDiffBumpBase.u_continuous
-/

#print ExistsContDiffBumpBase.u_support /-
theorem u_support : support (u : E → ℝ) = ball 0 1 :=
  (Classical.choose_spec (u_exists E)).2.2.1
#align exists_cont_diff_bump_base.u_support ExistsContDiffBumpBase.u_support
-/

#print ExistsContDiffBumpBase.u_compact_support /-
theorem u_compact_support : HasCompactSupport (u : E → ℝ) :=
  by
  rw [hasCompactSupport_def, u_support, closure_ball (0 : E) one_ne_zero]
  exact is_compact_closed_ball _ _
#align exists_cont_diff_bump_base.u_compact_support ExistsContDiffBumpBase.u_compact_support
-/

variable {E}

#print ExistsContDiffBumpBase.u_nonneg /-
theorem u_nonneg (x : E) : 0 ≤ u x :=
  ((Classical.choose_spec (u_exists E)).2.1 x).1
#align exists_cont_diff_bump_base.u_nonneg ExistsContDiffBumpBase.u_nonneg
-/

#print ExistsContDiffBumpBase.u_le_one /-
theorem u_le_one (x : E) : u x ≤ 1 :=
  ((Classical.choose_spec (u_exists E)).2.1 x).2
#align exists_cont_diff_bump_base.u_le_one ExistsContDiffBumpBase.u_le_one
-/

#print ExistsContDiffBumpBase.u_neg /-
theorem u_neg (x : E) : u (-x) = u x :=
  (Classical.choose_spec (u_exists E)).2.2.2 x
#align exists_cont_diff_bump_base.u_neg ExistsContDiffBumpBase.u_neg
-/

variable [MeasurableSpace E] [BorelSpace E]

local notation "μ" => MeasureTheory.Measure.addHaar

variable (E)

#print ExistsContDiffBumpBase.u_int_pos /-
theorem u_int_pos : 0 < ∫ x : E, u x ∂μ :=
  by
  refine' (integral_pos_iff_support_of_nonneg u_nonneg _).mpr _
  · exact (u_continuous E).integrable_of_hasCompactSupport (u_compact_support E)
  · rw [u_support]; exact measure_ball_pos _ _ zero_lt_one
#align exists_cont_diff_bump_base.u_int_pos ExistsContDiffBumpBase.u_int_pos
-/

variable {E}

#print ExistsContDiffBumpBase.w /-
/-- An auxiliary function to construct partitions of unity on finite-dimensional real vector spaces,
which is smooth, symmetric, with support equal to the ball of radius `D` and integral `1`. -/
def w (D : ℝ) (x : E) : ℝ :=
  ((∫ x : E, u x ∂μ) * |D| ^ finrank ℝ E)⁻¹ • u (D⁻¹ • x)
#align exists_cont_diff_bump_base.W ExistsContDiffBumpBase.w
-/

#print ExistsContDiffBumpBase.w_def /-
theorem w_def (D : ℝ) :
    (w D : E → ℝ) = fun x => ((∫ x : E, u x ∂μ) * |D| ^ finrank ℝ E)⁻¹ • u (D⁻¹ • x) := by ext1 x;
  rfl
#align exists_cont_diff_bump_base.W_def ExistsContDiffBumpBase.w_def
-/

#print ExistsContDiffBumpBase.w_nonneg /-
theorem w_nonneg (D : ℝ) (x : E) : 0 ≤ w D x :=
  by
  apply mul_nonneg _ (u_nonneg _)
  apply inv_nonneg.2
  apply mul_nonneg (u_int_pos E).le
  apply pow_nonneg (abs_nonneg D)
#align exists_cont_diff_bump_base.W_nonneg ExistsContDiffBumpBase.w_nonneg
-/

#print ExistsContDiffBumpBase.w_mul_φ_nonneg /-
theorem w_mul_φ_nonneg (D : ℝ) (x y : E) : 0 ≤ w D y * φ (x - y) :=
  mul_nonneg (w_nonneg D y) (indicator_nonneg (by simp only [zero_le_one, imp_true_iff]) _)
#align exists_cont_diff_bump_base.W_mul_φ_nonneg ExistsContDiffBumpBase.w_mul_φ_nonneg
-/

variable (E)

#print ExistsContDiffBumpBase.w_integral /-
theorem w_integral {D : ℝ} (Dpos : 0 < D) : ∫ x : E, w D x ∂μ = 1 :=
  by
  simp_rw [W, integral_smul]
  rw [integral_comp_inv_smul_of_nonneg μ (u : E → ℝ) Dpos.le, abs_of_nonneg Dpos.le, mul_comm]
  field_simp [Dpos.ne', (u_int_pos E).ne']
#align exists_cont_diff_bump_base.W_integral ExistsContDiffBumpBase.w_integral
-/

#print ExistsContDiffBumpBase.w_support /-
theorem w_support {D : ℝ} (Dpos : 0 < D) : support (w D : E → ℝ) = ball 0 D :=
  by
  have B : D • ball (0 : E) 1 = ball 0 D := by
    rw [smul_unitBall Dpos.ne', Real.norm_of_nonneg Dpos.le]
  have C : D ^ finrank ℝ E ≠ 0 := pow_ne_zero _ Dpos.ne'
  simp only [W_def, Algebra.id.smul_eq_mul, support_mul, support_inv, univ_inter,
    support_comp_inv_smul₀ Dpos.ne', u_support, B, support_const (u_int_pos E).ne', support_const C,
    abs_of_nonneg Dpos.le]
#align exists_cont_diff_bump_base.W_support ExistsContDiffBumpBase.w_support
-/

#print ExistsContDiffBumpBase.w_compact_support /-
theorem w_compact_support {D : ℝ} (Dpos : 0 < D) : HasCompactSupport (w D : E → ℝ) :=
  by
  rw [hasCompactSupport_def, W_support E Dpos, closure_ball (0 : E) Dpos.ne']
  exact is_compact_closed_ball _ _
#align exists_cont_diff_bump_base.W_compact_support ExistsContDiffBumpBase.w_compact_support
-/

variable {E}

#print ExistsContDiffBumpBase.y /-
/-- An auxiliary function to construct partitions of unity on finite-dimensional real vector spaces.
It is the convolution between a smooth function of integral `1` supported in the ball of radius `D`,
with the indicator function of the closed unit ball. Therefore, it is smooth, equal to `1` on the
ball of radius `1 - D`, with support equal to the ball of radius `1 + D`. -/
def y (D : ℝ) : E → ℝ :=
  w D ⋆[lsmul ℝ ℝ, μ] φ
#align exists_cont_diff_bump_base.Y ExistsContDiffBumpBase.y
-/

#print ExistsContDiffBumpBase.y_neg /-
theorem y_neg (D : ℝ) (x : E) : y D (-x) = y D x :=
  by
  apply convolution_neg_of_neg_eq
  · apply eventually_of_forall fun x => _
    simp only [W_def, u_neg, smul_neg, Algebra.id.smul_eq_mul, mul_eq_mul_left_iff,
      eq_self_iff_true, true_or_iff]
  · apply eventually_of_forall fun x => _
    simp only [φ, indicator, mem_closedBall_zero_iff, norm_neg]
#align exists_cont_diff_bump_base.Y_neg ExistsContDiffBumpBase.y_neg
-/

#print ExistsContDiffBumpBase.y_eq_one_of_mem_closedBall /-
theorem y_eq_one_of_mem_closedBall {D : ℝ} {x : E} (Dpos : 0 < D)
    (hx : x ∈ closedBall (0 : E) (1 - D)) : y D x = 1 :=
  by
  change (W D ⋆[lsmul ℝ ℝ, μ] φ) x = 1
  have B : ∀ y : E, y ∈ ball x D → φ y = 1 :=
    by
    have C : ball x D ⊆ ball 0 1 := by
      apply ball_subset_ball'
      simp only [mem_closed_ball] at hx 
      linarith only [hx]
    intro y hy
    simp only [φ, indicator, mem_closed_ball, ite_eq_left_iff, not_le, zero_ne_one]
    intro h'y
    linarith only [mem_ball.1 (C hy), h'y]
  have Bx : φ x = 1 := B _ (mem_ball_self Dpos)
  have B' : ∀ y, y ∈ ball x D → φ y = φ x := by rw [Bx]; exact B
  rw [convolution_eq_right' _ (le_of_eq (W_support E Dpos)) B']
  simp only [lsmul_apply, Algebra.id.smul_eq_mul, integral_mul_right, W_integral E Dpos, Bx,
    one_mul]
#align exists_cont_diff_bump_base.Y_eq_one_of_mem_closed_ball ExistsContDiffBumpBase.y_eq_one_of_mem_closedBall
-/

#print ExistsContDiffBumpBase.y_eq_zero_of_not_mem_ball /-
theorem y_eq_zero_of_not_mem_ball {D : ℝ} {x : E} (Dpos : 0 < D) (hx : x ∉ ball (0 : E) (1 + D)) :
    y D x = 0 := by
  change (W D ⋆[lsmul ℝ ℝ, μ] φ) x = 0
  have B : ∀ y, y ∈ ball x D → φ y = 0 := by
    intro y hy
    simp only [φ, indicator, mem_closedBall_zero_iff, ite_eq_right_iff, one_ne_zero]
    intro h'y
    have C : ball y D ⊆ ball 0 (1 + D) :=
      by
      apply ball_subset_ball'
      rw [← dist_zero_right] at h'y 
      linarith only [h'y]
    exact hx (C (mem_ball_comm.1 hy))
  have Bx : φ x = 0 := B _ (mem_ball_self Dpos)
  have B' : ∀ y, y ∈ ball x D → φ y = φ x := by rw [Bx]; exact B
  rw [convolution_eq_right' _ (le_of_eq (W_support E Dpos)) B']
  simp only [lsmul_apply, Algebra.id.smul_eq_mul, Bx, MulZeroClass.mul_zero, integral_const]
#align exists_cont_diff_bump_base.Y_eq_zero_of_not_mem_ball ExistsContDiffBumpBase.y_eq_zero_of_not_mem_ball
-/

#print ExistsContDiffBumpBase.y_nonneg /-
theorem y_nonneg (D : ℝ) (x : E) : 0 ≤ y D x :=
  integral_nonneg (w_mul_φ_nonneg D x)
#align exists_cont_diff_bump_base.Y_nonneg ExistsContDiffBumpBase.y_nonneg
-/

#print ExistsContDiffBumpBase.y_le_one /-
theorem y_le_one {D : ℝ} (x : E) (Dpos : 0 < D) : y D x ≤ 1 :=
  by
  have A : (W D ⋆[lsmul ℝ ℝ, μ] φ) x ≤ (W D ⋆[lsmul ℝ ℝ, μ] 1) x :=
    by
    apply
      convolution_mono_right_of_nonneg _ (W_nonneg D) (indicator_le_self' fun x hx => zero_le_one)
        fun x => zero_le_one
    refine'
      (HasCompactSupport.convolutionExistsLeft _ (W_compact_support E Dpos) _
          (locally_integrable_const (1 : ℝ)) x).Integrable
    exact continuous_const.mul ((u_continuous E).comp (continuous_id.const_smul _))
  have B : (W D ⋆[lsmul ℝ ℝ, μ] fun y => (1 : ℝ)) x = 1 := by
    simp only [convolution, ContinuousLinearMap.map_smul, mul_inv_rev, coe_smul', mul_one,
      lsmul_apply, Algebra.id.smul_eq_mul, integral_mul_left, W_integral E Dpos, Pi.smul_apply]
  exact A.trans (le_of_eq B)
#align exists_cont_diff_bump_base.Y_le_one ExistsContDiffBumpBase.y_le_one
-/

#print ExistsContDiffBumpBase.y_pos_of_mem_ball /-
theorem y_pos_of_mem_ball {D : ℝ} {x : E} (Dpos : 0 < D) (D_lt_one : D < 1)
    (hx : x ∈ ball (0 : E) (1 + D)) : 0 < y D x :=
  by
  simp only [mem_ball_zero_iff] at hx 
  refine' (integral_pos_iff_support_of_nonneg (W_mul_φ_nonneg D x) _).2 _
  · have F_comp : HasCompactSupport (W D) := W_compact_support E Dpos
    have B : locally_integrable (φ : E → ℝ) μ :=
      (locally_integrable_const _).indicator measurableSet_closedBall
    have C : Continuous (W D : E → ℝ) :=
      continuous_const.mul ((u_continuous E).comp (continuous_id.const_smul _))
    exact
      (HasCompactSupport.convolutionExistsLeft (lsmul ℝ ℝ : ℝ →L[ℝ] ℝ →L[ℝ] ℝ) F_comp C B
          x).Integrable
  · set z := (D / (1 + D)) • x with hz
    have B : 0 < 1 + D := by linarith
    have C : ball z (D * (1 + D - ‖x‖) / (1 + D)) ⊆ support fun y : E => W D y * φ (x - y) :=
      by
      intro y hy
      simp only [support_mul, W_support E Dpos]
      simp only [φ, mem_inter_iff, mem_support, Ne.def, indicator_apply_eq_zero,
        mem_closedBall_zero_iff, one_ne_zero, not_forall, not_false_iff, exists_prop, and_true_iff]
      constructor
      · apply ball_subset_ball' _ hy
        simp only [z, norm_smul, abs_of_nonneg Dpos.le, abs_of_nonneg B.le, dist_zero_right,
          Real.norm_eq_abs, abs_div]
        simp only [div_le_iff B, field_simps]
        ring_nf
      · have ID : ‖D / (1 + D) - 1‖ = 1 / (1 + D) :=
          by
          rw [Real.norm_of_nonpos]
          ·
            simp only [B.ne', Ne.def, not_false_iff, mul_one, neg_sub, add_tsub_cancel_right,
              field_simps]
          · simp only [B.ne', Ne.def, not_false_iff, mul_one, field_simps]
            apply div_nonpos_of_nonpos_of_nonneg _ B.le
            linarith only
        rw [← mem_closedBall_iff_norm']
        apply closed_ball_subset_closed_ball' _ (ball_subset_closed_ball hy)
        rw [← one_smul ℝ x, dist_eq_norm, hz, ← sub_smul, one_smul, norm_smul, ID]
        simp only [-one_div, -mul_eq_zero, B.ne', div_le_iff B, field_simps]
        simp only [mem_ball_zero_iff] at hx 
        nlinarith only [hx, D_lt_one]
    apply lt_of_lt_of_le _ (measure_mono C)
    apply measure_ball_pos
    exact div_pos (mul_pos Dpos (by linarith only [hx])) B
#align exists_cont_diff_bump_base.Y_pos_of_mem_ball ExistsContDiffBumpBase.y_pos_of_mem_ball
-/

variable (E)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print ExistsContDiffBumpBase.y_smooth /-
theorem y_smooth : ContDiffOn ℝ ⊤ (uncurry y) (Ioo (0 : ℝ) 1 ×ˢ (univ : Set E)) :=
  by
  have hs : IsOpen (Ioo (0 : ℝ) (1 : ℝ)) := isOpen_Ioo
  have hk : IsCompact (closed_ball (0 : E) 1) := ProperSpace.isCompact_closedBall _ _
  refine' contDiffOn_convolution_left_with_param (lsmul ℝ ℝ) hs hk _ _ _
  · rintro p x hp hx
    simp only [W, mul_inv_rev, Algebra.id.smul_eq_mul, mul_eq_zero, inv_eq_zero]
    right
    contrapose! hx
    have : p⁻¹ • x ∈ support u := mem_support.2 hx
    simp only [u_support, norm_smul, mem_ball_zero_iff, Real.norm_eq_abs, abs_inv,
      abs_of_nonneg hp.1.le, ← div_eq_inv_mul, div_lt_one hp.1] at this 
    rw [mem_closedBall_zero_iff]
    exact this.le.trans hp.2.le
  · exact (locally_integrable_const _).indicator measurableSet_closedBall
  · apply ContDiffOn.mul
    · refine'
        (cont_diff_on_const.mul _).inv fun x hx =>
          ne_of_gt (mul_pos (u_int_pos E) (pow_pos (abs_pos_of_pos hx.1.1) _))
      apply ContDiffOn.pow
      simp_rw [← Real.norm_eq_abs]
      apply @ContDiffOn.norm ℝ
      · exact contDiffOn_fst
      · intro x hx; exact ne_of_gt hx.1.1
    · apply (u_smooth E).comp_contDiffOn
      exact ContDiffOn.smul (cont_diff_on_fst.inv fun x hx => ne_of_gt hx.1.1) contDiffOn_snd
#align exists_cont_diff_bump_base.Y_smooth ExistsContDiffBumpBase.y_smooth
-/

#print ExistsContDiffBumpBase.y_support /-
theorem y_support {D : ℝ} (Dpos : 0 < D) (D_lt_one : D < 1) :
    support (y D : E → ℝ) = ball (0 : E) (1 + D) :=
  support_eq_iff.2
    ⟨fun x hx => (y_pos_of_mem_ball Dpos D_lt_one hx).ne', fun x hx =>
      y_eq_zero_of_not_mem_ball Dpos hx⟩
#align exists_cont_diff_bump_base.Y_support ExistsContDiffBumpBase.y_support
-/

variable {E}

end HelperDefinitions

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance (priority := 100) {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] : HasContDiffBump E :=
  by
  refine' ⟨⟨_⟩⟩
  borelize E
  have IR : ∀ R : ℝ, 1 < R → 0 < (R - 1) / (R + 1) := by intro R hR; apply div_pos <;> linarith
  exact
    { toFun := fun R x => if 1 < R then Y ((R - 1) / (R + 1)) (((R + 1) / 2)⁻¹ • x) else 0
      mem_Icc := fun R x => by
        split_ifs
        · refine' ⟨Y_nonneg _ _, Y_le_one _ (IR R h)⟩
        · simp only [Pi.zero_apply, left_mem_Icc, zero_le_one]
      Symmetric := fun R x => by
        split_ifs
        · simp only [Y_neg, smul_neg]
        · rfl
      smooth :=
        by
        suffices
          ContDiffOn ℝ ⊤
            (uncurry Y ∘ fun p : ℝ × E => ((p.1 - 1) / (p.1 + 1), ((p.1 + 1) / 2)⁻¹ • p.2))
            (Ioi 1 ×ˢ univ)
          by
          apply this.congr
          rintro ⟨R, x⟩ ⟨hR : 1 < R, hx⟩
          simp only [hR, uncurry_apply_pair, if_true, comp_app]
        apply (Y_smooth E).comp
        · apply ContDiffOn.prod
          · refine'
              (cont_diff_on_fst.sub contDiffOn_const).div (cont_diff_on_fst.add contDiffOn_const) _
            rintro ⟨R, x⟩ ⟨hR : 1 < R, hx⟩
            apply ne_of_gt
            dsimp only
            linarith
          · apply ContDiffOn.smul _ contDiffOn_snd
            refine' ((cont_diff_on_fst.add contDiffOn_const).div_const _).inv _
            rintro ⟨R, x⟩ ⟨hR : 1 < R, hx⟩
            apply ne_of_gt
            dsimp only
            linarith
        · rintro ⟨R, x⟩ ⟨hR : 1 < R, hx⟩
          have A : 0 < (R - 1) / (R + 1) := by apply div_pos <;> linarith
          have B : (R - 1) / (R + 1) < 1 := by apply (div_lt_one _).2 <;> linarith
          simp only [mem_preimage, prod_mk_mem_set_prod_eq, mem_Ioo, mem_univ, and_true_iff, A, B]
      eq_one := fun R hR x hx => by
        have A : 0 < R + 1 := by linarith
        simp only [hR, if_true]
        apply Y_eq_one_of_mem_closed_ball (IR R hR)
        simp only [norm_smul, inv_div, mem_closedBall_zero_iff, Real.norm_eq_abs, abs_div, abs_two,
          abs_of_nonneg A.le]
        calc
          2 / (R + 1) * ‖x‖ ≤ 2 / (R + 1) * 1 :=
            mul_le_mul_of_nonneg_left hx (div_nonneg zero_le_two A.le)
          _ = 1 - (R - 1) / (R + 1) := by field_simp [A.ne']; ring
      support := fun R hR => by
        have A : 0 < (R + 1) / 2 := by linarith
        have A' : 0 < R + 1 := by linarith
        have C : (R - 1) / (R + 1) < 1 := by apply (div_lt_one _).2 <;> linarith
        simp only [hR, if_true, support_comp_inv_smul₀ A.ne', Y_support _ (IR R hR) C,
          smul_ball A.ne', Real.norm_of_nonneg A.le, smul_zero]
        congr 1
        field_simp [A'.ne']
        ring }

end ExistsContDiffBumpBase

end

