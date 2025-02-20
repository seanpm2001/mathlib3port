/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Abhimanyu Pallavi Sudhir, Jean Lo, Calle Sönne, Benjamin Davidson

! This file was ported from Lean 3 source module analysis.special_functions.complex.log
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Complex.Arg
import Mathbin.Analysis.SpecialFunctions.Log.Basic

/-!
# The complex `log` function

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Basic properties, relationship with `exp`.
-/


noncomputable section

namespace Complex

open Set Filter

open scoped Real Topology ComplexConjugate

#print Complex.log /-
/-- Inverse of the `exp` function. Returns values such that `(log x).im > - π` and `(log x).im ≤ π`.
  `log 0 = 0`-/
@[pp_nodot]
noncomputable def log (x : ℂ) : ℂ :=
  x.abs.log + arg x * I
#align complex.log Complex.log
-/

#print Complex.log_re /-
theorem log_re (x : ℂ) : x.log.re = x.abs.log := by simp [log]
#align complex.log_re Complex.log_re
-/

#print Complex.log_im /-
theorem log_im (x : ℂ) : x.log.im = x.arg := by simp [log]
#align complex.log_im Complex.log_im
-/

#print Complex.neg_pi_lt_log_im /-
theorem neg_pi_lt_log_im (x : ℂ) : -π < (log x).im := by simp only [log_im, neg_pi_lt_arg]
#align complex.neg_pi_lt_log_im Complex.neg_pi_lt_log_im
-/

#print Complex.log_im_le_pi /-
theorem log_im_le_pi (x : ℂ) : (log x).im ≤ π := by simp only [log_im, arg_le_pi]
#align complex.log_im_le_pi Complex.log_im_le_pi
-/

#print Complex.exp_log /-
theorem exp_log {x : ℂ} (hx : x ≠ 0) : exp (log x) = x := by
  rw [log, exp_add_mul_I, ← of_real_sin, sin_arg, ← of_real_cos, cos_arg hx, ← of_real_exp,
    Real.exp_log (abs.pos hx), mul_add, of_real_div, of_real_div,
    mul_div_cancel' _ (of_real_ne_zero.2 <| abs.ne_zero hx), ← mul_assoc,
    mul_div_cancel' _ (of_real_ne_zero.2 <| abs.ne_zero hx), re_add_im]
#align complex.exp_log Complex.exp_log
-/

#print Complex.range_exp /-
@[simp]
theorem range_exp : range exp = {0}ᶜ :=
  Set.ext fun x => ⟨by rintro ⟨x, rfl⟩; exact exp_ne_zero x, fun hx => ⟨log x, exp_log hx⟩⟩
#align complex.range_exp Complex.range_exp
-/

#print Complex.log_exp /-
theorem log_exp {x : ℂ} (hx₁ : -π < x.im) (hx₂ : x.im ≤ π) : log (exp x) = x := by
  rw [log, abs_exp, Real.log_exp, exp_eq_exp_re_mul_sin_add_cos, ← of_real_exp,
    arg_mul_cos_add_sin_mul_I (Real.exp_pos _) ⟨hx₁, hx₂⟩, re_add_im]
#align complex.log_exp Complex.log_exp
-/

#print Complex.exp_inj_of_neg_pi_lt_of_le_pi /-
theorem exp_inj_of_neg_pi_lt_of_le_pi {x y : ℂ} (hx₁ : -π < x.im) (hx₂ : x.im ≤ π) (hy₁ : -π < y.im)
    (hy₂ : y.im ≤ π) (hxy : exp x = exp y) : x = y := by
  rw [← log_exp hx₁ hx₂, ← log_exp hy₁ hy₂, hxy]
#align complex.exp_inj_of_neg_pi_lt_of_le_pi Complex.exp_inj_of_neg_pi_lt_of_le_pi
-/

#print Complex.ofReal_log /-
theorem ofReal_log {x : ℝ} (hx : 0 ≤ x) : (x.log : ℂ) = log x :=
  Complex.ext (by rw [log_re, of_real_re, abs_of_nonneg hx])
    (by rw [of_real_im, log_im, arg_of_real_of_nonneg hx])
#align complex.of_real_log Complex.ofReal_log
-/

#print Complex.log_ofReal_re /-
theorem log_ofReal_re (x : ℝ) : (log (x : ℂ)).re = Real.log x := by simp [log_re]
#align complex.log_of_real_re Complex.log_ofReal_re
-/

#print Complex.log_ofReal_mul /-
theorem log_ofReal_mul {r : ℝ} (hr : 0 < r) {x : ℂ} (hx : x ≠ 0) :
    log (r * x) = Real.log r + log x :=
  by
  replace hx := complex.abs.ne_zero_iff.mpr hx
  simp_rw [log, map_mul, abs_of_real, arg_real_mul _ hr, abs_of_pos hr, Real.log_mul hr.ne' hx,
    of_real_add, add_assoc]
#align complex.log_of_real_mul Complex.log_ofReal_mul
-/

#print Complex.log_mul_ofReal /-
theorem log_mul_ofReal (r : ℝ) (hr : 0 < r) (x : ℂ) (hx : x ≠ 0) :
    log (x * r) = Real.log r + log x := by rw [mul_comm, log_of_real_mul hr hx, add_comm]
#align complex.log_mul_of_real Complex.log_mul_ofReal
-/

#print Complex.log_zero /-
@[simp]
theorem log_zero : log 0 = 0 := by simp [log]
#align complex.log_zero Complex.log_zero
-/

#print Complex.log_one /-
@[simp]
theorem log_one : log 1 = 0 := by simp [log]
#align complex.log_one Complex.log_one
-/

#print Complex.log_neg_one /-
theorem log_neg_one : log (-1) = π * I := by simp [log]
#align complex.log_neg_one Complex.log_neg_one
-/

#print Complex.log_I /-
theorem log_I : log I = π / 2 * I := by simp [log]
#align complex.log_I Complex.log_I
-/

#print Complex.log_neg_I /-
theorem log_neg_I : log (-I) = -(π / 2) * I := by simp [log]
#align complex.log_neg_I Complex.log_neg_I
-/

#print Complex.log_conj_eq_ite /-
theorem log_conj_eq_ite (x : ℂ) : log (conj x) = if x.arg = π then log x else conj (log x) :=
  by
  simp_rw [log, abs_conj, arg_conj, map_add, map_mul, conj_of_real]
  split_ifs with hx
  · rw [hx]
  simp_rw [of_real_neg, conj_I, mul_neg, neg_mul]
#align complex.log_conj_eq_ite Complex.log_conj_eq_ite
-/

#print Complex.log_conj /-
theorem log_conj (x : ℂ) (h : x.arg ≠ π) : log (conj x) = conj (log x) := by
  rw [log_conj_eq_ite, if_neg h]
#align complex.log_conj Complex.log_conj
-/

#print Complex.log_inv_eq_ite /-
theorem log_inv_eq_ite (x : ℂ) : log x⁻¹ = if x.arg = π then -conj (log x) else -log x :=
  by
  by_cases hx : x = 0
  · simp [hx]
  rw [inv_def, log_mul_of_real, Real.log_inv, of_real_neg, ← sub_eq_neg_add, log_conj_eq_ite]
  · simp_rw [log, map_add, map_mul, conj_of_real, conj_I, norm_sq_eq_abs, Real.log_pow,
      Nat.cast_two, of_real_mul, of_real_bit0, of_real_one, neg_add, mul_neg, two_mul, neg_neg]
    split_ifs
    · rw [add_sub_right_comm, sub_add_cancel']
    · rw [add_sub_right_comm, sub_add_cancel']
  · rwa [inv_pos, Complex.normSq_pos]
  · rwa [map_ne_zero]
#align complex.log_inv_eq_ite Complex.log_inv_eq_ite
-/

#print Complex.log_inv /-
theorem log_inv (x : ℂ) (hx : x.arg ≠ π) : log x⁻¹ = -log x := by rw [log_inv_eq_ite, if_neg hx]
#align complex.log_inv Complex.log_inv
-/

#print Complex.two_pi_I_ne_zero /-
theorem two_pi_I_ne_zero : (2 * π * I : ℂ) ≠ 0 := by norm_num [Real.pi_ne_zero, I_ne_zero]
#align complex.two_pi_I_ne_zero Complex.two_pi_I_ne_zero
-/

#print Complex.exp_eq_one_iff /-
theorem exp_eq_one_iff {x : ℂ} : exp x = 1 ↔ ∃ n : ℤ, x = n * (2 * π * I) :=
  by
  constructor
  · intro h
    rcases existsUnique_add_zsmul_mem_Ioc Real.two_pi_pos x.im (-π) with ⟨n, hn, -⟩
    use -n
    rw [Int.cast_neg, neg_mul, eq_neg_iff_add_eq_zero]
    have : (x + n * (2 * π * I)).im ∈ Ioc (-π) π := by simpa [two_mul, mul_add] using hn
    rw [← log_exp this.1 this.2, exp_periodic.int_mul n, h, log_one]
  · rintro ⟨n, rfl⟩; exact (exp_periodic.int_mul n).Eq.trans exp_zero
#align complex.exp_eq_one_iff Complex.exp_eq_one_iff
-/

#print Complex.exp_eq_exp_iff_exp_sub_eq_one /-
theorem exp_eq_exp_iff_exp_sub_eq_one {x y : ℂ} : exp x = exp y ↔ exp (x - y) = 1 := by
  rw [exp_sub, div_eq_one_iff_eq (exp_ne_zero _)]
#align complex.exp_eq_exp_iff_exp_sub_eq_one Complex.exp_eq_exp_iff_exp_sub_eq_one
-/

#print Complex.exp_eq_exp_iff_exists_int /-
theorem exp_eq_exp_iff_exists_int {x y : ℂ} : exp x = exp y ↔ ∃ n : ℤ, x = y + n * (2 * π * I) := by
  simp only [exp_eq_exp_iff_exp_sub_eq_one, exp_eq_one_iff, sub_eq_iff_eq_add']
#align complex.exp_eq_exp_iff_exists_int Complex.exp_eq_exp_iff_exists_int
-/

#print Complex.countable_preimage_exp /-
@[simp]
theorem countable_preimage_exp {s : Set ℂ} : (exp ⁻¹' s).Countable ↔ s.Countable :=
  by
  refine' ⟨fun hs => _, fun hs => _⟩
  · refine' ((hs.image exp).insert 0).mono _
    rw [image_preimage_eq_inter_range, range_exp, ← diff_eq, ← union_singleton, diff_union_self]
    exact subset_union_left _ _
  · rw [← bUnion_preimage_singleton]
    refine' hs.bUnion fun z hz => _
    rcases em (∃ w, exp w = z) with (⟨w, rfl⟩ | hne)
    · simp only [preimage, mem_singleton_iff, exp_eq_exp_iff_exists_int, set_of_exists]
      exact countable_Union fun m => countable_singleton _
    · push_neg at hne ; simp [preimage, hne]
#align complex.countable_preimage_exp Complex.countable_preimage_exp
-/

alias countable_preimage_exp ↔ _ _root_.set.countable.preimage_cexp
#align set.countable.preimage_cexp Set.Countable.preimage_cexp

#print Complex.tendsto_log_nhdsWithin_im_neg_of_re_neg_of_im_zero /-
theorem tendsto_log_nhdsWithin_im_neg_of_re_neg_of_im_zero {z : ℂ} (hre : z.re < 0)
    (him : z.im = 0) : Tendsto log (𝓝[{z : ℂ | z.im < 0}] z) (𝓝 <| Real.log (abs z) - π * I) :=
  by
  have :=
    (continuous_of_real.continuous_at.comp_continuous_within_at
            (continuous_abs.continuous_within_at.log _)).Tendsto.add
      (((continuous_of_real.tendsto _).comp <|
            tendsto_arg_nhds_within_im_neg_of_re_neg_of_im_zero hre him).mul
        tendsto_const_nhds)
  convert this
  · simp [sub_eq_add_neg]
  · lift z to ℝ using him; simpa using hre.ne
#align complex.tendsto_log_nhds_within_im_neg_of_re_neg_of_im_zero Complex.tendsto_log_nhdsWithin_im_neg_of_re_neg_of_im_zero
-/

#print Complex.continuousWithinAt_log_of_re_neg_of_im_zero /-
theorem continuousWithinAt_log_of_re_neg_of_im_zero {z : ℂ} (hre : z.re < 0) (him : z.im = 0) :
    ContinuousWithinAt log {z : ℂ | 0 ≤ z.im} z :=
  by
  have :=
    (continuous_of_real.continuous_at.comp_continuous_within_at
            (continuous_abs.continuous_within_at.log _)).Tendsto.add
      ((continuous_of_real.continuous_at.comp_continuous_within_at <|
            continuous_within_at_arg_of_re_neg_of_im_zero hre him).mul
        tendsto_const_nhds)
  convert this
  · lift z to ℝ using him; simpa using hre.ne
#align complex.continuous_within_at_log_of_re_neg_of_im_zero Complex.continuousWithinAt_log_of_re_neg_of_im_zero
-/

#print Complex.tendsto_log_nhdsWithin_im_nonneg_of_re_neg_of_im_zero /-
theorem tendsto_log_nhdsWithin_im_nonneg_of_re_neg_of_im_zero {z : ℂ} (hre : z.re < 0)
    (him : z.im = 0) : Tendsto log (𝓝[{z : ℂ | 0 ≤ z.im}] z) (𝓝 <| Real.log (abs z) + π * I) := by
  simpa only [log, arg_eq_pi_iff.2 ⟨hre, him⟩] using
    (continuous_within_at_log_of_re_neg_of_im_zero hre him).Tendsto
#align complex.tendsto_log_nhds_within_im_nonneg_of_re_neg_of_im_zero Complex.tendsto_log_nhdsWithin_im_nonneg_of_re_neg_of_im_zero
-/

#print Complex.map_exp_comap_re_atBot /-
@[simp]
theorem map_exp_comap_re_atBot : map exp (comap re atBot) = 𝓝[≠] 0 := by
  rw [← comap_exp_nhds_zero, map_comap, range_exp, nhdsWithin]
#align complex.map_exp_comap_re_at_bot Complex.map_exp_comap_re_atBot
-/

#print Complex.map_exp_comap_re_atTop /-
@[simp]
theorem map_exp_comap_re_atTop : map exp (comap re atTop) = comap abs atTop :=
  by
  rw [← comap_exp_comap_abs_at_top, map_comap, range_exp, inf_eq_left, le_principal_iff]
  exact eventually_ne_of_tendsto_norm_atTop tendsto_comap 0
#align complex.map_exp_comap_re_at_top Complex.map_exp_comap_re_atTop
-/

end Complex

section LogDeriv

open Complex Filter

open scoped Topology

variable {α : Type _}

#print continuousAt_clog /-
theorem continuousAt_clog {x : ℂ} (h : 0 < x.re ∨ x.im ≠ 0) : ContinuousAt log x :=
  by
  refine' ContinuousAt.add _ _
  · refine' continuous_of_real.continuous_at.comp _
    refine' (Real.continuousAt_log _).comp complex.continuous_abs.continuous_at
    rw [complex.abs.ne_zero_iff]
    rintro rfl
    simpa using h
  · have h_cont_mul : Continuous fun x : ℂ => x * I := continuous_id'.mul continuous_const
    refine' h_cont_mul.continuous_at.comp (continuous_of_real.continuous_at.comp _)
    exact continuous_at_arg h
#align continuous_at_clog continuousAt_clog
-/

#print Filter.Tendsto.clog /-
theorem Filter.Tendsto.clog {l : Filter α} {f : α → ℂ} {x : ℂ} (h : Tendsto f l (𝓝 x))
    (hx : 0 < x.re ∨ x.im ≠ 0) : Tendsto (fun t => log (f t)) l (𝓝 <| log x) :=
  (continuousAt_clog hx).Tendsto.comp h
#align filter.tendsto.clog Filter.Tendsto.clog
-/

variable [TopologicalSpace α]

#print ContinuousAt.clog /-
theorem ContinuousAt.clog {f : α → ℂ} {x : α} (h₁ : ContinuousAt f x)
    (h₂ : 0 < (f x).re ∨ (f x).im ≠ 0) : ContinuousAt (fun t => log (f t)) x :=
  h₁.clog h₂
#align continuous_at.clog ContinuousAt.clog
-/

#print ContinuousWithinAt.clog /-
theorem ContinuousWithinAt.clog {f : α → ℂ} {s : Set α} {x : α} (h₁ : ContinuousWithinAt f s x)
    (h₂ : 0 < (f x).re ∨ (f x).im ≠ 0) : ContinuousWithinAt (fun t => log (f t)) s x :=
  h₁.clog h₂
#align continuous_within_at.clog ContinuousWithinAt.clog
-/

#print ContinuousOn.clog /-
theorem ContinuousOn.clog {f : α → ℂ} {s : Set α} (h₁ : ContinuousOn f s)
    (h₂ : ∀ x ∈ s, 0 < (f x).re ∨ (f x).im ≠ 0) : ContinuousOn (fun t => log (f t)) s := fun x hx =>
  (h₁ x hx).clog (h₂ x hx)
#align continuous_on.clog ContinuousOn.clog
-/

#print Continuous.clog /-
theorem Continuous.clog {f : α → ℂ} (h₁ : Continuous f) (h₂ : ∀ x, 0 < (f x).re ∨ (f x).im ≠ 0) :
    Continuous fun t => log (f t) :=
  continuous_iff_continuousAt.2 fun x => h₁.ContinuousAt.clog (h₂ x)
#align continuous.clog Continuous.clog
-/

end LogDeriv

