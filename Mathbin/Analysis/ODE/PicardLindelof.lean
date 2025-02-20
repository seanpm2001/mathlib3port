/-
Copyright (c) 2021 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov, Winston Yin

! This file was ported from Lean 3 source module analysis.ODE.picard_lindelof
! leanprover-community/mathlib commit fd4551cfe4b7484b81c2c9ba3405edae27659676
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.SpecialFunctions.Integrals
import Mathbin.Topology.MetricSpace.Contracting

/-!
# Picard-Lindelöf (Cauchy-Lipschitz) Theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that an ordinary differential equation $\dot x=v(t, x)$ such that $v$ is
Lipschitz continuous in $x$ and continuous in $t$ has a local solution, see
`exists_forall_deriv_within_Icc_eq_of_is_picard_lindelof`.

As a corollary, we prove that a time-independent locally continuously differentiable ODE has a
local solution.

## Implementation notes

In order to split the proof into small lemmas, we introduce a structure `picard_lindelof` that holds
all assumptions of the main theorem. This structure and lemmas in the `picard_lindelof` namespace
should be treated as private implementation details. This is not to be confused with the `Prop`-
valued structure `is_picard_lindelof`, which holds the long hypotheses of the Picard-Lindelöf
theorem for actual use as part of the public API.

We only prove existence of a solution in this file. For uniqueness see `ODE_solution_unique` and
related theorems in `analysis.ODE.gronwall`.

## Tags

differential equation
-/


open Filter Function Set Metric TopologicalSpace intervalIntegral MeasureTheory

open MeasureTheory.MeasureSpace (volume)

open scoped Filter Topology NNReal ENNReal Nat Interval

noncomputable section

variable {E : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E]

#print IsPicardLindelof /-
/-- `Prop` structure holding the hypotheses of the Picard-Lindelöf theorem.

The similarly named `picard_lindelof` structure is part of the internal API for convenience, so as
not to constantly invoke choice, but is not intended for public use. -/
structure IsPicardLindelof {E : Type _} [NormedAddCommGroup E] (v : ℝ → E → E) (t_min t₀ t_max : ℝ)
    (x₀ : E) (L : ℝ≥0) (R C : ℝ) : Prop where
  ht₀ : t₀ ∈ Icc t_min t_max
  hR : 0 ≤ R
  lipschitz : ∀ t ∈ Icc t_min t_max, LipschitzOnWith L (v t) (closedBall x₀ R)
  cont : ∀ x ∈ closedBall x₀ R, ContinuousOn (fun t : ℝ => v t x) (Icc t_min t_max)
  norm_le : ∀ t ∈ Icc t_min t_max, ∀ x ∈ closedBall x₀ R, ‖v t x‖ ≤ C
  C_mul_le_R : (C : ℝ) * LinearOrder.max (t_max - t₀) (t₀ - t_min) ≤ R
#align is_picard_lindelof IsPicardLindelof
-/

#print PicardLindelof /-
/-- This structure holds arguments of the Picard-Lipschitz (Cauchy-Lipschitz) theorem. It is part of
the internal API for convenience, so as not to constantly invoke choice. Unless you want to use one
of the auxiliary lemmas, use `exists_forall_deriv_within_Icc_eq_of_lipschitz_of_continuous` instead
of using this structure.

The similarly named `is_picard_lindelof` is a bundled `Prop` holding the long hypotheses of the
Picard-Lindelöf theorem as named arguments. It is used as part of the public API.
-/
structure PicardLindelof (E : Type _) [NormedAddCommGroup E] [NormedSpace ℝ E] where
  toFun : ℝ → E → E
  (tMin tMax : ℝ)
  t₀ : Icc t_min t_max
  x₀ : E
  (C r l : ℝ≥0)
  is_pl : IsPicardLindelof to_fun t_min t₀ t_max x₀ L R C
#align picard_lindelof PicardLindelof
-/

namespace PicardLindelof

variable (v : PicardLindelof E)

instance : CoeFun (PicardLindelof E) fun _ => ℝ → E → E :=
  ⟨toFun⟩

instance : Inhabited (PicardLindelof E) :=
  ⟨⟨0, 0, 0, ⟨0, le_rfl, le_rfl⟩, 0, 0, 0, 0,
      { ht₀ := by rw [Subtype.coe_mk, Icc_self]; exact mem_singleton _
        hR := by rfl
        lipschitz := fun t ht => (LipschitzWith.const 0).LipschitzOnWith _
        cont := fun _ _ => by simpa only [Pi.zero_apply] using continuousOn_const
        norm_le := fun t ht x hx => norm_zero.le
        C_mul_le_R := (MulZeroClass.zero_mul _).le }⟩⟩

#print PicardLindelof.tMin_le_tMax /-
theorem tMin_le_tMax : v.tMin ≤ v.tMax :=
  v.t₀.2.1.trans v.t₀.2.2
#align picard_lindelof.t_min_le_t_max PicardLindelof.tMin_le_tMax
-/

#print PicardLindelof.nonempty_Icc /-
protected theorem nonempty_Icc : (Icc v.tMin v.tMax).Nonempty :=
  nonempty_Icc.2 v.tMin_le_tMax
#align picard_lindelof.nonempty_Icc PicardLindelof.nonempty_Icc
-/

#print PicardLindelof.lipschitzOnWith /-
protected theorem lipschitzOnWith {t} (ht : t ∈ Icc v.tMin v.tMax) :
    LipschitzOnWith v.l (v t) (closedBall v.x₀ v.r) :=
  v.is_pl.lipschitz t ht
#align picard_lindelof.lipschitz_on_with PicardLindelof.lipschitzOnWith
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print PicardLindelof.continuousOn /-
protected theorem continuousOn :
    ContinuousOn (uncurry v) (Icc v.tMin v.tMax ×ˢ closedBall v.x₀ v.r) :=
  have : ContinuousOn (uncurry (flip v)) (closedBall v.x₀ v.r ×ˢ Icc v.tMin v.tMax) :=
    continuousOn_prod_of_continuousOn_lipschitzOnWith _ v.l v.is_pl.cont v.is_pl.lipschitz
  this.comp continuous_swap.ContinuousOn (preimage_swap_prod _ _).symm.Subset
#align picard_lindelof.continuous_on PicardLindelof.continuousOn
-/

#print PicardLindelof.norm_le /-
theorem norm_le {t : ℝ} (ht : t ∈ Icc v.tMin v.tMax) {x : E} (hx : x ∈ closedBall v.x₀ v.r) :
    ‖v t x‖ ≤ v.C :=
  v.is_pl.norm_le _ ht _ hx
#align picard_lindelof.norm_le PicardLindelof.norm_le
-/

#print PicardLindelof.tDist /-
/-- The maximum of distances from `t₀` to the endpoints of `[t_min, t_max]`. -/
def tDist : ℝ :=
  max (v.tMax - v.t₀) (v.t₀ - v.tMin)
#align picard_lindelof.t_dist PicardLindelof.tDist
-/

#print PicardLindelof.tDist_nonneg /-
theorem tDist_nonneg : 0 ≤ v.tDist :=
  le_max_iff.2 <| Or.inl <| sub_nonneg.2 v.t₀.2.2
#align picard_lindelof.t_dist_nonneg PicardLindelof.tDist_nonneg
-/

#print PicardLindelof.dist_t₀_le /-
theorem dist_t₀_le (t : Icc v.tMin v.tMax) : dist t v.t₀ ≤ v.tDist :=
  by
  rw [Subtype.dist_eq, Real.dist_eq]
  cases' le_total t v.t₀ with ht ht
  · rw [abs_of_nonpos (sub_nonpos.2 <| Subtype.coe_le_coe.2 ht), neg_sub]
    exact (sub_le_sub_left t.2.1 _).trans (le_max_right _ _)
  · rw [abs_of_nonneg (sub_nonneg.2 <| Subtype.coe_le_coe.2 ht)]
    exact (sub_le_sub_right t.2.2 _).trans (le_max_left _ _)
#align picard_lindelof.dist_t₀_le PicardLindelof.dist_t₀_le
-/

#print PicardLindelof.proj /-
/-- Projection $ℝ → [t_{\min}, t_{\max}]$ sending $(-∞, t_{\min}]$ to $t_{\min}$ and $[t_{\max}, ∞)$
to $t_{\max}$. -/
def proj : ℝ → Icc v.tMin v.tMax :=
  projIcc v.tMin v.tMax v.tMin_le_tMax
#align picard_lindelof.proj PicardLindelof.proj
-/

#print PicardLindelof.proj_coe /-
theorem proj_coe (t : Icc v.tMin v.tMax) : v.proj t = t :=
  projIcc_val _ _
#align picard_lindelof.proj_coe PicardLindelof.proj_coe
-/

#print PicardLindelof.proj_of_mem /-
theorem proj_of_mem {t : ℝ} (ht : t ∈ Icc v.tMin v.tMax) : ↑(v.proj t) = t := by
  simp only [proj, proj_Icc_of_mem _ ht, Subtype.coe_mk]
#align picard_lindelof.proj_of_mem PicardLindelof.proj_of_mem
-/

#print PicardLindelof.continuous_proj /-
@[continuity]
theorem continuous_proj : Continuous v.proj :=
  continuous_projIcc
#align picard_lindelof.continuous_proj PicardLindelof.continuous_proj
-/

#print PicardLindelof.FunSpace /-
/-- The space of curves $γ \colon [t_{\min}, t_{\max}] \to E$ such that $γ(t₀) = x₀$ and $γ$ is
Lipschitz continuous with constant $C$. The map sending $γ$ to
$\mathbf Pγ(t)=x₀ + ∫_{t₀}^{t} v(τ, γ(τ))\,dτ$ is a contracting map on this space, and its fixed
point is a solution of the ODE $\dot x=v(t, x)$. -/
structure FunSpace where
  toFun : Icc v.tMin v.tMax → E
  map_t₀' : to_fun v.t₀ = v.x₀
  lipschitz' : LipschitzWith v.C to_fun
#align picard_lindelof.fun_space PicardLindelof.FunSpace
-/

namespace FunSpace

variable {v} (f : FunSpace v)

instance : CoeFun (FunSpace v) fun _ => Icc v.tMin v.tMax → E :=
  ⟨toFun⟩

instance : Inhabited v.FunSpace :=
  ⟨⟨fun _ => v.x₀, rfl, (LipschitzWith.const _).weaken (zero_le _)⟩⟩

#print PicardLindelof.FunSpace.lipschitz /-
protected theorem lipschitz : LipschitzWith v.C f :=
  f.lipschitz'
#align picard_lindelof.fun_space.lipschitz PicardLindelof.FunSpace.lipschitz
-/

#print PicardLindelof.FunSpace.continuous /-
protected theorem continuous : Continuous f :=
  f.lipschitz.Continuous
#align picard_lindelof.fun_space.continuous PicardLindelof.FunSpace.continuous
-/

#print PicardLindelof.FunSpace.toContinuousMap /-
/-- Each curve in `picard_lindelof.fun_space` is continuous. -/
def toContinuousMap : v.FunSpace ↪ C(Icc v.tMin v.tMax, E) :=
  ⟨fun f => ⟨f, f.Continuous⟩, fun f g h => by cases f; cases g; simpa using h⟩
#align picard_lindelof.fun_space.to_continuous_map PicardLindelof.FunSpace.toContinuousMap
-/

instance : MetricSpace v.FunSpace :=
  MetricSpace.induced toContinuousMap toContinuousMap.Injective inferInstance

#print PicardLindelof.FunSpace.uniformInducing_toContinuousMap /-
theorem uniformInducing_toContinuousMap : UniformInducing (@toContinuousMap _ _ _ v) :=
  ⟨rfl⟩
#align picard_lindelof.fun_space.uniform_inducing_to_continuous_map PicardLindelof.FunSpace.uniformInducing_toContinuousMap
-/

#print PicardLindelof.FunSpace.range_toContinuousMap /-
theorem range_toContinuousMap :
    range toContinuousMap = {f : C(Icc v.tMin v.tMax, E) | f v.t₀ = v.x₀ ∧ LipschitzWith v.C f} :=
  by
  ext f; constructor
  · rintro ⟨⟨f, hf₀, hf_lip⟩, rfl⟩; exact ⟨hf₀, hf_lip⟩
  · rcases f with ⟨f, hf⟩; rintro ⟨hf₀, hf_lip⟩; exact ⟨⟨f, hf₀, hf_lip⟩, rfl⟩
#align picard_lindelof.fun_space.range_to_continuous_map PicardLindelof.FunSpace.range_toContinuousMap
-/

#print PicardLindelof.FunSpace.map_t₀ /-
theorem map_t₀ : f v.t₀ = v.x₀ :=
  f.map_t₀'
#align picard_lindelof.fun_space.map_t₀ PicardLindelof.FunSpace.map_t₀
-/

#print PicardLindelof.FunSpace.mem_closedBall /-
protected theorem mem_closedBall (t : Icc v.tMin v.tMax) : f t ∈ closedBall v.x₀ v.r :=
  calc
    dist (f t) v.x₀ = dist (f t) (f.toFun v.t₀) := by rw [f.map_t₀']
    _ ≤ v.C * dist t v.t₀ := (f.lipschitz.dist_le_mul _ _)
    _ ≤ v.C * v.tDist := (mul_le_mul_of_nonneg_left (v.dist_t₀_le _) v.C.2)
    _ ≤ v.r := v.is_pl.C_mul_le_R
#align picard_lindelof.fun_space.mem_closed_ball PicardLindelof.FunSpace.mem_closedBall
-/

#print PicardLindelof.FunSpace.vComp /-
/-- Given a curve $γ \colon [t_{\min}, t_{\max}] → E$, `v_comp` is the function
$F(t)=v(π t, γ(π t))$, where `π` is the projection $ℝ → [t_{\min}, t_{\max}]$. The integral of this
function is the image of `γ` under the contracting map we are going to define below. -/
def vComp (t : ℝ) : E :=
  v (v.proj t) (f (v.proj t))
#align picard_lindelof.fun_space.v_comp PicardLindelof.FunSpace.vComp
-/

#print PicardLindelof.FunSpace.vComp_apply_coe /-
theorem vComp_apply_coe (t : Icc v.tMin v.tMax) : f.vComp t = v t (f t) := by
  simp only [v_comp, proj_coe]
#align picard_lindelof.fun_space.v_comp_apply_coe PicardLindelof.FunSpace.vComp_apply_coe
-/

#print PicardLindelof.FunSpace.continuous_vComp /-
theorem continuous_vComp : Continuous f.vComp :=
  by
  have := (continuous_subtype_coe.prod_mk f.continuous).comp v.continuous_proj
  refine' ContinuousOn.comp_continuous v.continuous_on this fun x => _
  exact ⟨(v.proj x).2, f.mem_closed_ball _⟩
#align picard_lindelof.fun_space.continuous_v_comp PicardLindelof.FunSpace.continuous_vComp
-/

#print PicardLindelof.FunSpace.norm_vComp_le /-
theorem norm_vComp_le (t : ℝ) : ‖f.vComp t‖ ≤ v.C :=
  v.norm_le (v.proj t).2 <| f.mem_closedBall _
#align picard_lindelof.fun_space.norm_v_comp_le PicardLindelof.FunSpace.norm_vComp_le
-/

#print PicardLindelof.FunSpace.dist_apply_le_dist /-
theorem dist_apply_le_dist (f₁ f₂ : FunSpace v) (t : Icc v.tMin v.tMax) :
    dist (f₁ t) (f₂ t) ≤ dist f₁ f₂ :=
  @ContinuousMap.dist_apply_le_dist _ _ _ _ _ f₁.toContinuousMap f₂.toContinuousMap _
#align picard_lindelof.fun_space.dist_apply_le_dist PicardLindelof.FunSpace.dist_apply_le_dist
-/

#print PicardLindelof.FunSpace.dist_le_of_forall /-
theorem dist_le_of_forall {f₁ f₂ : FunSpace v} {d : ℝ} (h : ∀ t, dist (f₁ t) (f₂ t) ≤ d) :
    dist f₁ f₂ ≤ d :=
  (@ContinuousMap.dist_le_iff_of_nonempty _ _ _ _ _ f₁.toContinuousMap f₂.toContinuousMap _
        v.nonempty_Icc.to_subtype).2
    h
#align picard_lindelof.fun_space.dist_le_of_forall PicardLindelof.FunSpace.dist_le_of_forall
-/

instance [CompleteSpace E] : CompleteSpace v.FunSpace :=
  by
  refine'
    (completeSpace_iff_isComplete_range uniform_inducing_to_continuous_map).2
      (IsClosed.isComplete _)
  rw [range_to_continuous_map, set_of_and]
  refine' (isClosed_eq (ContinuousMap.continuous_eval_const _) continuous_const).inter _
  have : IsClosed {f : Icc v.t_min v.t_max → E | LipschitzWith v.C f} :=
    isClosed_setOf_lipschitzWith v.C
  exact this.preimage ContinuousMap.continuous_coe

#print PicardLindelof.FunSpace.intervalIntegrable_vComp /-
theorem intervalIntegrable_vComp (t₁ t₂ : ℝ) : IntervalIntegrable f.vComp volume t₁ t₂ :=
  f.continuous_vComp.IntervalIntegrable _ _
#align picard_lindelof.fun_space.interval_integrable_v_comp PicardLindelof.FunSpace.intervalIntegrable_vComp
-/

variable [CompleteSpace E]

#print PicardLindelof.FunSpace.next /-
/-- The Picard-Lindelöf operator. This is a contracting map on `picard_lindelof.fun_space v` such
that the fixed point of this map is the solution of the corresponding ODE.

More precisely, some iteration of this map is a contracting map. -/
def next (f : FunSpace v) : FunSpace v
    where
  toFun t := v.x₀ + ∫ τ : ℝ in v.t₀..t, f.vComp τ
  map_t₀' := by rw [integral_same, add_zero]
  lipschitz' :=
    LipschitzWith.of_dist_le_mul fun t₁ t₂ =>
      by
      rw [dist_add_left, dist_eq_norm,
        integral_interval_sub_left (f.interval_integrable_v_comp _ _)
          (f.interval_integrable_v_comp _ _)]
      exact norm_integral_le_of_norm_le_const fun t ht => f.norm_v_comp_le _
#align picard_lindelof.fun_space.next PicardLindelof.FunSpace.next
-/

#print PicardLindelof.FunSpace.next_apply /-
theorem next_apply (t : Icc v.tMin v.tMax) : f.next t = v.x₀ + ∫ τ : ℝ in v.t₀..t, f.vComp τ :=
  rfl
#align picard_lindelof.fun_space.next_apply PicardLindelof.FunSpace.next_apply
-/

#print PicardLindelof.FunSpace.hasDerivWithinAt_next /-
theorem hasDerivWithinAt_next (t : Icc v.tMin v.tMax) :
    HasDerivWithinAt (f.next ∘ v.proj) (v t (f t)) (Icc v.tMin v.tMax) t :=
  by
  haveI : Fact ((t : ℝ) ∈ Icc v.t_min v.t_max) := ⟨t.2⟩
  simp only [(· ∘ ·), next_apply]
  refine' HasDerivWithinAt.const_add _ _
  have :
    HasDerivWithinAt (fun t : ℝ => ∫ τ in v.t₀..t, f.v_comp τ) (f.v_comp t) (Icc v.t_min v.t_max)
      t :=
    integral_has_deriv_within_at_right (f.interval_integrable_v_comp _ _)
      (f.continuous_v_comp.strongly_measurable_at_filter _ _)
      f.continuous_v_comp.continuous_within_at
  rw [v_comp_apply_coe] at this 
  refine' this.congr_of_eventually_eq_of_mem _ t.coe_prop
  filter_upwards [self_mem_nhdsWithin] with _ ht'
  rw [v.proj_of_mem ht']
#align picard_lindelof.fun_space.has_deriv_within_at_next PicardLindelof.FunSpace.hasDerivWithinAt_next
-/

#print PicardLindelof.FunSpace.dist_next_apply_le_of_le /-
theorem dist_next_apply_le_of_le {f₁ f₂ : FunSpace v} {n : ℕ} {d : ℝ}
    (h : ∀ t, dist (f₁ t) (f₂ t) ≤ (v.l * |t - v.t₀|) ^ n / n ! * d) (t : Icc v.tMin v.tMax) :
    dist (next f₁ t) (next f₂ t) ≤ (v.l * |t - v.t₀|) ^ (n + 1) / (n + 1)! * d :=
  by
  simp only [dist_eq_norm, next_apply, add_sub_add_left_eq_sub, ←
    intervalIntegral.integral_sub (interval_integrable_v_comp _ _ _)
      (interval_integrable_v_comp _ _ _),
    norm_integral_eq_norm_integral_Ioc] at *
  calc
    ‖∫ τ in Ι (v.t₀ : ℝ) t, f₁.v_comp τ - f₂.v_comp τ‖ ≤
        ∫ τ in Ι (v.t₀ : ℝ) t, v.L * ((v.L * |τ - v.t₀|) ^ n / n ! * d) :=
      by
      refine' norm_integral_le_of_norm_le (Continuous.integrableOn_uIoc _) _
      · continuity
      · refine' (ae_restrict_mem measurableSet_Ioc).mono fun τ hτ => _
        refine'
          (v.lipschitz_on_with (v.proj τ).2).norm_sub_le_of_le (f₁.mem_closed_ball _)
            (f₂.mem_closed_ball _) ((h _).trans_eq _)
        rw [v.proj_of_mem]
        exact uIcc_subset_Icc v.t₀.2 t.2 <| Ioc_subset_Icc_self hτ
    _ = (v.L * |t - v.t₀|) ^ (n + 1) / (n + 1)! * d := _
  simp_rw [mul_pow, div_eq_mul_inv, mul_assoc, MeasureTheory.integral_mul_left,
    MeasureTheory.integral_mul_right, integral_pow_abs_sub_uIoc, div_eq_mul_inv, pow_succ (v.L : ℝ),
    Nat.factorial_succ, Nat.cast_mul, Nat.cast_succ, mul_inv, mul_assoc]
#align picard_lindelof.fun_space.dist_next_apply_le_of_le PicardLindelof.FunSpace.dist_next_apply_le_of_le
-/

#print PicardLindelof.FunSpace.dist_iterate_next_apply_le /-
theorem dist_iterate_next_apply_le (f₁ f₂ : FunSpace v) (n : ℕ) (t : Icc v.tMin v.tMax) :
    dist ((next^[n]) f₁ t) ((next^[n]) f₂ t) ≤ (v.l * |t - v.t₀|) ^ n / n ! * dist f₁ f₂ :=
  by
  induction' n with n ihn generalizing t
  · rw [pow_zero, Nat.factorial_zero, Nat.cast_one, div_one, one_mul]
    exact dist_apply_le_dist f₁ f₂ t
  · rw [iterate_succ_apply', iterate_succ_apply']
    exact dist_next_apply_le_of_le ihn _
#align picard_lindelof.fun_space.dist_iterate_next_apply_le PicardLindelof.FunSpace.dist_iterate_next_apply_le
-/

#print PicardLindelof.FunSpace.dist_iterate_next_le /-
theorem dist_iterate_next_le (f₁ f₂ : FunSpace v) (n : ℕ) :
    dist ((next^[n]) f₁) ((next^[n]) f₂) ≤ (v.l * v.tDist) ^ n / n ! * dist f₁ f₂ :=
  by
  refine' dist_le_of_forall fun t => (dist_iterate_next_apply_le _ _ _ _).trans _
  have : 0 ≤ dist f₁ f₂ := dist_nonneg
  have : |(t - v.t₀ : ℝ)| ≤ v.t_dist := v.dist_t₀_le t
  mono* <;> simp only [Nat.cast_nonneg, mul_nonneg, NNReal.coe_nonneg, abs_nonneg, *]
#align picard_lindelof.fun_space.dist_iterate_next_le PicardLindelof.FunSpace.dist_iterate_next_le
-/

end FunSpace

variable [CompleteSpace E]

section

#print PicardLindelof.exists_contracting_iterate /-
theorem exists_contracting_iterate :
    ∃ (N : ℕ) (K : _), ContractingWith K ((FunSpace.next : v.FunSpace → v.FunSpace)^[N]) :=
  by
  rcases((Real.tendsto_pow_div_factorial_atTop (v.L * v.t_dist)).Eventually
        (gt_mem_nhds zero_lt_one)).exists with
    ⟨N, hN⟩
  have : (0 : ℝ) ≤ (v.L * v.t_dist) ^ N / N ! :=
    div_nonneg (pow_nonneg (mul_nonneg v.L.2 v.t_dist_nonneg) _) (Nat.cast_nonneg _)
  exact
    ⟨N, ⟨_, this⟩, hN, LipschitzWith.of_dist_le_mul fun f g => fun_space.dist_iterate_next_le f g N⟩
#align picard_lindelof.exists_contracting_iterate PicardLindelof.exists_contracting_iterate
-/

#print PicardLindelof.exists_fixed /-
theorem exists_fixed : ∃ f : v.FunSpace, f.next = f :=
  let ⟨N, K, hK⟩ := exists_contracting_iterate v
  ⟨_, hK.isFixedPt_fixedPoint_iterate⟩
#align picard_lindelof.exists_fixed PicardLindelof.exists_fixed
-/

end

#print PicardLindelof.exists_solution /-
/-- Picard-Lindelöf (Cauchy-Lipschitz) theorem. Use
`exists_forall_deriv_within_Icc_eq_of_is_picard_lindelof` instead for the public API. -/
theorem exists_solution :
    ∃ f : ℝ → E,
      f v.t₀ = v.x₀ ∧
        ∀ t ∈ Icc v.tMin v.tMax, HasDerivWithinAt f (v t (f t)) (Icc v.tMin v.tMax) t :=
  by
  rcases v.exists_fixed with ⟨f, hf⟩
  refine' ⟨f ∘ v.proj, _, fun t ht => _⟩
  · simp only [(· ∘ ·), proj_coe, f.map_t₀]
  · simp only [(· ∘ ·), v.proj_of_mem ht]
    lift t to Icc v.t_min v.t_max using ht
    simpa only [hf, v.proj_coe] using f.has_deriv_within_at_next t
#align picard_lindelof.exists_solution PicardLindelof.exists_solution
-/

end PicardLindelof

#print IsPicardLindelof.norm_le₀ /-
theorem IsPicardLindelof.norm_le₀ {E : Type _} [NormedAddCommGroup E] {v : ℝ → E → E}
    {t_min t₀ t_max : ℝ} {x₀ : E} {C R : ℝ} {L : ℝ≥0}
    (hpl : IsPicardLindelof v t_min t₀ t_max x₀ L R C) : ‖v t₀ x₀‖ ≤ C :=
  hpl.norm_le t₀ hpl.ht₀ x₀ <| mem_closedBall_self hpl.hR
#align is_picard_lindelof.norm_le₀ IsPicardLindelof.norm_le₀
-/

#print IsPicardLindelof.exists_forall_hasDerivWithinAt_Icc_eq /-
/-- Picard-Lindelöf (Cauchy-Lipschitz) theorem. -/
theorem IsPicardLindelof.exists_forall_hasDerivWithinAt_Icc_eq [CompleteSpace E] {v : ℝ → E → E}
    {t_min t₀ t_max : ℝ} (x₀ : E) {C R : ℝ} {L : ℝ≥0}
    (hpl : IsPicardLindelof v t_min t₀ t_max x₀ L R C) :
    ∃ f : ℝ → E,
      f t₀ = x₀ ∧ ∀ t ∈ Icc t_min t_max, HasDerivWithinAt f (v t (f t)) (Icc t_min t_max) t :=
  by
  lift C to ℝ≥0 using (norm_nonneg _).trans hpl.norm_le₀
  lift t₀ to Icc t_min t_max using hpl.ht₀
  exact
    PicardLindelof.exists_solution
      ⟨v, t_min, t_max, t₀, x₀, C, ⟨R, hpl.hR⟩, L, { hpl with ht₀ := t₀.property }⟩
#align exists_forall_deriv_within_Icc_eq_of_is_picard_lindelof IsPicardLindelof.exists_forall_hasDerivWithinAt_Icc_eq
-/

variable [ProperSpace E] {v : E → E} (t₀ : ℝ) (x₀ : E)

#print exists_isPicardLindelof_const_of_contDiffOn_nhds /-
/-- A time-independent, locally continuously differentiable ODE satisfies the hypotheses of the
  Picard-Lindelöf theorem. -/
theorem exists_isPicardLindelof_const_of_contDiffOn_nhds {s : Set E} (hv : ContDiffOn ℝ 1 v s)
    (hs : s ∈ 𝓝 x₀) :
    ∃ ε > (0 : ℝ), ∃ L R C, IsPicardLindelof (fun t => v) (t₀ - ε) t₀ (t₀ + ε) x₀ L R C :=
  by
  -- extract Lipschitz constant
  obtain ⟨L, s', hs', hlip⟩ :=
    ContDiffAt.exists_lipschitzOnWith ((hv.cont_diff_within_at (mem_of_mem_nhds hs)).ContDiffAt hs)
  -- radius of closed ball in which v is bounded
  obtain ⟨r, hr : 0 < r, hball⟩ := metric.mem_nhds_iff.mp (inter_sets (𝓝 x₀) hs hs')
  have hr' := (half_pos hr).le
  obtain ⟨C, hC⟩ :=
    (is_compact_closed_ball x₀ (r / 2)).bddAbove_image
      (-- uses proper_space E
        hv.continuous_on.norm.mono
        (subset_inter_iff.mp ((closed_ball_subset_ball (half_lt_self hr)).trans hball)).left)
  have hC' : 0 ≤ C := by
    apply (norm_nonneg (v x₀)).trans
    apply hC
    exact ⟨x₀, ⟨mem_closed_ball_self hr', rfl⟩⟩
  set ε := if C = 0 then 1 else r / 2 / C with hε
  have hε0 : 0 < ε := by
    rw [hε]
    split_ifs
    · exact zero_lt_one
    · exact div_pos (half_pos hr) (lt_of_le_of_ne hC' (Ne.symm h))
  refine' ⟨ε, hε0, L, r / 2, C, _⟩
  exact
    { ht₀ := by rw [← Real.closedBall_eq_Icc]; exact mem_closed_ball_self hε0.le
      hR := (half_pos hr).le
      lipschitz := fun t ht =>
        hlip.mono
          (subset_inter_iff.mp (subset_trans (closed_ball_subset_ball (half_lt_self hr)) hball)).2
      cont := fun x hx => continuousOn_const
      norm_le := fun t ht x hx => hC ⟨x, hx, rfl⟩
      C_mul_le_R := by
        rw [add_sub_cancel', sub_sub_cancel, max_self, mul_ite, mul_one]
        split_ifs
        · rwa [← h] at hr' 
        · exact (mul_div_cancel' (r / 2) h).le }
#align exists_is_picard_lindelof_const_of_cont_diff_on_nhds exists_isPicardLindelof_const_of_contDiffOn_nhds
-/

#print exists_forall_deriv_at_Ioo_eq_of_contDiffOn_nhds /-
/-- A time-independent, locally continuously differentiable ODE admits a solution in some open
interval. -/
theorem exists_forall_deriv_at_Ioo_eq_of_contDiffOn_nhds {s : Set E} (hv : ContDiffOn ℝ 1 v s)
    (hs : s ∈ 𝓝 x₀) :
    ∃ ε > (0 : ℝ),
      ∃ f : ℝ → E, f t₀ = x₀ ∧ ∀ t ∈ Ioo (t₀ - ε) (t₀ + ε), f t ∈ s ∧ HasDerivAt f (v (f t)) t :=
  by
  obtain ⟨ε, hε, L, R, C, hpl⟩ := exists_isPicardLindelof_const_of_contDiffOn_nhds t₀ x₀ hv hs
  obtain ⟨f, hf1, hf2⟩ := IsPicardLindelof.exists_forall_hasDerivWithinAt_Icc_eq x₀ hpl
  have hf2' : ∀ t ∈ Ioo (t₀ - ε) (t₀ + ε), HasDerivAt f (v (f t)) t := fun t ht =>
    (hf2 t (Ioo_subset_Icc_self ht)).HasDerivAt (Icc_mem_nhds ht.1 ht.2)
  have h : f ⁻¹' s ∈ 𝓝 t₀ :=
    by
    have := hf2' t₀ (mem_Ioo.mpr ⟨sub_lt_self _ hε, lt_add_of_pos_right _ hε⟩)
    apply ContinuousAt.preimage_mem_nhds this.continuous_at
    rw [hf1]
    exact hs
  rw [Metric.mem_nhds_iff] at h 
  obtain ⟨r, hr1, hr2⟩ := h
  refine'
    ⟨min r ε, lt_min hr1 hε, f, hf1, fun t ht =>
      ⟨_,
        hf2' t
          (mem_of_mem_of_subset ht
            (Ioo_subset_Ioo (sub_le_sub_left (min_le_right _ _) _)
              (add_le_add_left (min_le_right _ _) _)))⟩⟩
  rw [← Set.mem_preimage]
  apply Set.mem_of_mem_of_subset _ hr2
  apply Set.mem_of_mem_of_subset ht
  rw [← Real.ball_eq_Ioo]
  exact Metric.ball_subset_ball (min_le_left _ _)
#align exists_forall_deriv_at_Ioo_eq_of_cont_diff_on_nhds exists_forall_deriv_at_Ioo_eq_of_contDiffOn_nhds
-/

#print exists_forall_hasDerivAt_Ioo_eq_of_contDiff /-
/-- A time-independent, continuously differentiable ODE admits a solution in some open interval. -/
theorem exists_forall_hasDerivAt_Ioo_eq_of_contDiff (hv : ContDiff ℝ 1 v) :
    ∃ ε > (0 : ℝ), ∃ f : ℝ → E, f t₀ = x₀ ∧ ∀ t ∈ Ioo (t₀ - ε) (t₀ + ε), HasDerivAt f (v (f t)) t :=
  let ⟨ε, hε, f, hf1, hf2⟩ :=
    exists_forall_deriv_at_Ioo_eq_of_contDiffOn_nhds t₀ x₀ hv.ContDiffOn
      (IsOpen.mem_nhds isOpen_univ (mem_univ _))
  ⟨ε, hε, f, hf1, fun t ht => (hf2 t ht).2⟩
#align exists_forall_deriv_at_Ioo_eq_of_cont_diff exists_forall_hasDerivAt_Ioo_eq_of_contDiff
-/

