/-
Copyright (c) 2022 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying

! This file was ported from Lean 3 source module probability.martingale.upcrossing
! leanprover-community/mathlib commit e8e130de9dba4ed6897183c3193c752ffadbcc77
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.Monotone
import Mathbin.Probability.Process.HittingTime
import Mathbin.Probability.Martingale.Basic

/-!

# Doob's upcrossing estimate

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a discrete real-valued submartingale $(f_n)_{n \in \mathbb{N}}$, denoting $U_N(a, b)$ the
number of times $f_n$ crossed from below $a$ to above $b$ before time $N$, Doob's upcrossing
estimate (also known as Doob's inequality) states that
$$(b - a) \mathbb{E}[U_N(a, b)] \le \mathbb{E}[(f_N - a)^+].$$
Doob's upcrossing estimate is an important inequality and is central in proving the martingale
convergence theorems.

## Main definitions

* `measure_theory.upper_crossing_time a b f N n`: is the stopping time corresponding to `f`
  crossing above `b` the `n`-th time before time `N` (if this does not occur then the value is
  taken to be `N`).
* `measure_theory.lower_crossing_time a b f N n`: is the stopping time corresponding to `f`
  crossing below `a` the `n`-th time before time `N` (if this does not occur then the value is
  taken to be `N`).
* `measure_theory.upcrossing_strat a b f N`: is the predictable process which is 1 if `n` is
  between a consecutive pair of lower and upper crossing and is 0 otherwise. Intuitively
  one might think of the `upcrossing_strat` as the strategy of buying 1 share whenever the process
  crosses below `a` for the first time after selling and selling 1 share whenever the process
  crosses above `b` for the first time after buying.
* `measure_theory.upcrossings_before a b f N`: is the number of times `f` crosses from below `a` to
  above `b` before time `N`.
* `measure_theory.upcrossings a b f`: is the number of times `f` crosses from below `a` to above
  `b`. This takes value in `ℝ≥0∞` and so is allowed to be `∞`.

## Main results

* `measure_theory.adapted.is_stopping_time_upper_crossing_time`: `upper_crossing_time` is a
  stopping time whenever the process it is associated to is adapted.
* `measure_theory.adapted.is_stopping_time_lower_crossing_time`: `lower_crossing_time` is a
  stopping time whenever the process it is associated to is adapted.
* `measure_theory.submartingale.mul_integral_upcrossings_before_le_integral_pos_part`: Doob's
  upcrossing estimate.
* `measure_theory.submartingale.mul_lintegral_upcrossings_le_lintegral_pos_part`: the inequality
  obtained by taking the supremum on both sides of Doob's upcrossing estimate.

### References

We mostly follow the proof from [Kallenberg, *Foundations of modern probability*][kallenberg2021]

-/


open TopologicalSpace Filter

open scoped NNReal ENNReal MeasureTheory ProbabilityTheory BigOperators Topology

namespace MeasureTheory

variable {Ω ι : Type _} {m0 : MeasurableSpace Ω} {μ : Measure Ω}

/-!

## Proof outline

In this section, we will denote $U_N(a, b)$ the number of upcrossings of $(f_n)$ from below $a$ to
above $b$ before time $N$.

To define $U_N(a, b)$, we will construct two stopping times corresponding to when $(f_n)$ crosses
below $a$ and above $b$. Namely, we define
$$
  \sigma_n := \inf \{n \ge \tau_n \mid f_n \le a\} \wedge N;
$$
$$
  \tau_{n + 1} := \inf \{n \ge \sigma_n \mid f_n \ge b\} \wedge N.
$$
These are `lower_crossing_time` and `upper_crossing_time` in our formalization which are defined
using `measure_theory.hitting` allowing us to specify a starting and ending time.
Then, we may simply define $U_N(a, b) := \sup \{n \mid \tau_n < N\}$.

Fixing $a < b \in \mathbb{R}$, we will first prove the theorem in the special case that
$0 \le f_0$ and $a \le f_N$. In particular, we will show
$$
  (b - a) \mathbb{E}[U_N(a, b)] \le \mathbb{E}[f_N].
$$
This is `measure_theory.integral_mul_upcrossings_before_le_integral` in our formalization.

To prove this, we use the fact that given a non-negative, bounded, predictable process $(C_n)$
(i.e. $(C_{n + 1})$ is adapted), $(C \bullet f)_n := \sum_{k \le n} C_{k + 1}(f_{k + 1} - f_k)$ is
a submartingale if $(f_n)$ is.

Define $C_n := \sum_{k \le n} \mathbf{1}_{[\sigma_k, \tau_{k + 1})}(n)$. It is easy to see that
$(1 - C_n)$ is non-negative, bounded and predictable, and hence, given a submartingale $(f_n)$,
$(1 - C) \bullet f$ is also a submartingale. Thus, by the submartingale property,
$0 \le \mathbb{E}[((1 - C) \bullet f)_0] \le \mathbb{E}[((1 - C) \bullet f)_N]$ implying
$$
  \mathbb{E}[(C \bullet f)_N] \le \mathbb{E}[(1 \bullet f)_N] = \mathbb{E}[f_N] - \mathbb{E}[f_0].
$$

Furthermore,
\begin{align}
    (C \bullet f)_N & =
      \sum_{n \le N} \sum_{k \le N} \mathbf{1}_{[\sigma_k, \tau_{k + 1})}(n)(f_{n + 1} - f_n)\\
    & = \sum_{k \le N} \sum_{n \le N} \mathbf{1}_{[\sigma_k, \tau_{k + 1})}(n)(f_{n + 1} - f_n)\\
    & = \sum_{k \le N} (f_{\sigma_k + 1} - f_{\sigma_k} + f_{\sigma_k + 2} - f_{\sigma_k + 1}
      + \cdots + f_{\tau_{k + 1}} - f_{\tau_{k + 1} - 1})\\
    & = \sum_{k \le N} (f_{\tau_{k + 1}} - f_{\sigma_k})
      \ge \sum_{k < U_N(a, b)} (b - a) = (b - a) U_N(a, b)
\end{align}
where the inequality follows since for all $k < U_N(a, b)$,
$f_{\tau_{k + 1}} - f_{\sigma_k} \ge b - a$ while for all $k > U_N(a, b)$,
$f_{\tau_{k + 1}} = f_{\sigma_k} = f_N$ and
$f_{\tau_{U_N(a, b) + 1}} - f_{\sigma_{U_N(a, b)}} = f_N - a \ge 0$. Hence, we have
$$
  (b - a) \mathbb{E}[U_N(a, b)] \le \mathbb{E}[(C \bullet f)_N]
  \le \mathbb{E}[f_N] - \mathbb{E}[f_0] \le \mathbb{E}[f_N],
$$
as required.

To obtain the general case, we simply apply the above to $((f_n - a)^+)_n$.

-/


#print MeasureTheory.lowerCrossingTimeAux /-
/-- `lower_crossing_time_aux a f c N` is the first time `f` reached below `a` after time `c` before
time `N`. -/
noncomputable def lowerCrossingTimeAux [Preorder ι] [InfSet ι] (a : ℝ) (f : ι → Ω → ℝ) (c N : ι) :
    Ω → ι :=
  hitting f (Set.Iic a) c N
#align measure_theory.lower_crossing_time_aux MeasureTheory.lowerCrossingTimeAux
-/

#print MeasureTheory.upperCrossingTime /-
/-- `upper_crossing_time a b f N n` is the first time before time `N`, `f` reaches
above `b` after `f` reached below `a` for the `n - 1`-th time. -/
noncomputable def upperCrossingTime [Preorder ι] [OrderBot ι] [InfSet ι] (a b : ℝ) (f : ι → Ω → ℝ)
    (N : ι) : ℕ → Ω → ι
  | 0 => ⊥
  | n + 1 => fun ω =>
    hitting f (Set.Ici b) (lowerCrossingTimeAux a f (upper_crossing_time n ω) N ω) N ω
#align measure_theory.upper_crossing_time MeasureTheory.upperCrossingTime
-/

#print MeasureTheory.lowerCrossingTime /-
/-- `lower_crossing_time a b f N n` is the first time before time `N`, `f` reaches
below `a` after `f` reached above `b` for the `n`-th time. -/
noncomputable def lowerCrossingTime [Preorder ι] [OrderBot ι] [InfSet ι] (a b : ℝ) (f : ι → Ω → ℝ)
    (N : ι) (n : ℕ) : Ω → ι := fun ω => hitting f (Set.Iic a) (upperCrossingTime a b f N n ω) N ω
#align measure_theory.lower_crossing_time MeasureTheory.lowerCrossingTime
-/

section

variable [Preorder ι] [OrderBot ι] [InfSet ι]

variable {a b : ℝ} {f : ι → Ω → ℝ} {N : ι} {n m : ℕ} {ω : Ω}

#print MeasureTheory.upperCrossingTime_zero /-
@[simp]
theorem upperCrossingTime_zero : upperCrossingTime a b f N 0 = ⊥ :=
  rfl
#align measure_theory.upper_crossing_time_zero MeasureTheory.upperCrossingTime_zero
-/

#print MeasureTheory.lowerCrossingTime_zero /-
@[simp]
theorem lowerCrossingTime_zero : lowerCrossingTime a b f N 0 = hitting f (Set.Iic a) ⊥ N :=
  rfl
#align measure_theory.lower_crossing_time_zero MeasureTheory.lowerCrossingTime_zero
-/

#print MeasureTheory.upperCrossingTime_succ /-
theorem upperCrossingTime_succ :
    upperCrossingTime a b f N (n + 1) ω =
      hitting f (Set.Ici b) (lowerCrossingTimeAux a f (upperCrossingTime a b f N n ω) N ω) N ω :=
  by rw [upper_crossing_time]
#align measure_theory.upper_crossing_time_succ MeasureTheory.upperCrossingTime_succ
-/

#print MeasureTheory.upperCrossingTime_succ_eq /-
theorem upperCrossingTime_succ_eq (ω : Ω) :
    upperCrossingTime a b f N (n + 1) ω =
      hitting f (Set.Ici b) (lowerCrossingTime a b f N n ω) N ω :=
  by
  simp only [upper_crossing_time_succ]
  rfl
#align measure_theory.upper_crossing_time_succ_eq MeasureTheory.upperCrossingTime_succ_eq
-/

end

section ConditionallyCompleteLinearOrderBot

variable [ConditionallyCompleteLinearOrderBot ι]

variable {a b : ℝ} {f : ι → Ω → ℝ} {N : ι} {n m : ℕ} {ω : Ω}

#print MeasureTheory.upperCrossingTime_le /-
theorem upperCrossingTime_le : upperCrossingTime a b f N n ω ≤ N :=
  by
  cases n
  · simp only [upper_crossing_time_zero, Pi.bot_apply, bot_le]
  · simp only [upper_crossing_time_succ, hitting_le]
#align measure_theory.upper_crossing_time_le MeasureTheory.upperCrossingTime_le
-/

#print MeasureTheory.upperCrossingTime_zero' /-
@[simp]
theorem upperCrossingTime_zero' : upperCrossingTime a b f ⊥ n ω = ⊥ :=
  eq_bot_iff.2 upperCrossingTime_le
#align measure_theory.upper_crossing_time_zero' MeasureTheory.upperCrossingTime_zero'
-/

#print MeasureTheory.lowerCrossingTime_le /-
theorem lowerCrossingTime_le : lowerCrossingTime a b f N n ω ≤ N := by
  simp only [lower_crossing_time, hitting_le ω]
#align measure_theory.lower_crossing_time_le MeasureTheory.lowerCrossingTime_le
-/

#print MeasureTheory.upperCrossingTime_le_lowerCrossingTime /-
theorem upperCrossingTime_le_lowerCrossingTime :
    upperCrossingTime a b f N n ω ≤ lowerCrossingTime a b f N n ω := by
  simp only [lower_crossing_time, le_hitting upper_crossing_time_le ω]
#align measure_theory.upper_crossing_time_le_lower_crossing_time MeasureTheory.upperCrossingTime_le_lowerCrossingTime
-/

#print MeasureTheory.lowerCrossingTime_le_upperCrossingTime_succ /-
theorem lowerCrossingTime_le_upperCrossingTime_succ :
    lowerCrossingTime a b f N n ω ≤ upperCrossingTime a b f N (n + 1) ω :=
  by
  rw [upper_crossing_time_succ]
  exact le_hitting lower_crossing_time_le ω
#align measure_theory.lower_crossing_time_le_upper_crossing_time_succ MeasureTheory.lowerCrossingTime_le_upperCrossingTime_succ
-/

#print MeasureTheory.lowerCrossingTime_mono /-
theorem lowerCrossingTime_mono (hnm : n ≤ m) :
    lowerCrossingTime a b f N n ω ≤ lowerCrossingTime a b f N m ω :=
  by
  suffices Monotone fun n => lower_crossing_time a b f N n ω by exact this hnm
  exact
    monotone_nat_of_le_succ fun n =>
      le_trans lower_crossing_time_le_upper_crossing_time_succ
        upper_crossing_time_le_lower_crossing_time
#align measure_theory.lower_crossing_time_mono MeasureTheory.lowerCrossingTime_mono
-/

#print MeasureTheory.upperCrossingTime_mono /-
theorem upperCrossingTime_mono (hnm : n ≤ m) :
    upperCrossingTime a b f N n ω ≤ upperCrossingTime a b f N m ω :=
  by
  suffices Monotone fun n => upper_crossing_time a b f N n ω by exact this hnm
  exact
    monotone_nat_of_le_succ fun n =>
      le_trans upper_crossing_time_le_lower_crossing_time
        lower_crossing_time_le_upper_crossing_time_succ
#align measure_theory.upper_crossing_time_mono MeasureTheory.upperCrossingTime_mono
-/

end ConditionallyCompleteLinearOrderBot

variable {a b : ℝ} {f : ℕ → Ω → ℝ} {N : ℕ} {n m : ℕ} {ω : Ω}

#print MeasureTheory.stoppedValue_lowerCrossingTime /-
theorem stoppedValue_lowerCrossingTime (h : lowerCrossingTime a b f N n ω ≠ N) :
    stoppedValue f (lowerCrossingTime a b f N n) ω ≤ a :=
  by
  obtain ⟨j, hj₁, hj₂⟩ :=
    (hitting_le_iff_of_lt _ (lt_of_le_of_ne lower_crossing_time_le h)).1 le_rfl
  exact stopped_value_hitting_mem ⟨j, ⟨hj₁.1, le_trans hj₁.2 lower_crossing_time_le⟩, hj₂⟩
#align measure_theory.stopped_value_lower_crossing_time MeasureTheory.stoppedValue_lowerCrossingTime
-/

#print MeasureTheory.stoppedValue_upperCrossingTime /-
theorem stoppedValue_upperCrossingTime (h : upperCrossingTime a b f N (n + 1) ω ≠ N) :
    b ≤ stoppedValue f (upperCrossingTime a b f N (n + 1)) ω :=
  by
  obtain ⟨j, hj₁, hj₂⟩ :=
    (hitting_le_iff_of_lt _ (lt_of_le_of_ne upper_crossing_time_le h)).1 le_rfl
  exact stopped_value_hitting_mem ⟨j, ⟨hj₁.1, le_trans hj₁.2 (hitting_le _)⟩, hj₂⟩
#align measure_theory.stopped_value_upper_crossing_time MeasureTheory.stoppedValue_upperCrossingTime
-/

#print MeasureTheory.upperCrossingTime_lt_lowerCrossingTime /-
theorem upperCrossingTime_lt_lowerCrossingTime (hab : a < b)
    (hn : lowerCrossingTime a b f N (n + 1) ω ≠ N) :
    upperCrossingTime a b f N (n + 1) ω < lowerCrossingTime a b f N (n + 1) ω :=
  by
  refine'
    lt_of_le_of_ne upper_crossing_time_le_lower_crossing_time fun h =>
      not_le.2 hab <| le_trans _ (stopped_value_lower_crossing_time hn)
  simp only [stopped_value]
  rw [← h]
  exact stopped_value_upper_crossing_time (h.symm ▸ hn)
#align measure_theory.upper_crossing_time_lt_lower_crossing_time MeasureTheory.upperCrossingTime_lt_lowerCrossingTime
-/

#print MeasureTheory.lowerCrossingTime_lt_upperCrossingTime /-
theorem lowerCrossingTime_lt_upperCrossingTime (hab : a < b)
    (hn : upperCrossingTime a b f N (n + 1) ω ≠ N) :
    lowerCrossingTime a b f N n ω < upperCrossingTime a b f N (n + 1) ω :=
  by
  refine'
    lt_of_le_of_ne lower_crossing_time_le_upper_crossing_time_succ fun h =>
      not_le.2 hab <| le_trans (stopped_value_upper_crossing_time hn) _
  simp only [stopped_value]
  rw [← h]
  exact stopped_value_lower_crossing_time (h.symm ▸ hn)
#align measure_theory.lower_crossing_time_lt_upper_crossing_time MeasureTheory.lowerCrossingTime_lt_upperCrossingTime
-/

#print MeasureTheory.upperCrossingTime_lt_succ /-
theorem upperCrossingTime_lt_succ (hab : a < b) (hn : upperCrossingTime a b f N (n + 1) ω ≠ N) :
    upperCrossingTime a b f N n ω < upperCrossingTime a b f N (n + 1) ω :=
  lt_of_le_of_lt upperCrossingTime_le_lowerCrossingTime
    (lowerCrossingTime_lt_upperCrossingTime hab hn)
#align measure_theory.upper_crossing_time_lt_succ MeasureTheory.upperCrossingTime_lt_succ
-/

#print MeasureTheory.lowerCrossingTime_stabilize /-
theorem lowerCrossingTime_stabilize (hnm : n ≤ m) (hn : lowerCrossingTime a b f N n ω = N) :
    lowerCrossingTime a b f N m ω = N :=
  le_antisymm lowerCrossingTime_le (le_trans (le_of_eq hn.symm) (lowerCrossingTime_mono hnm))
#align measure_theory.lower_crossing_time_stabilize MeasureTheory.lowerCrossingTime_stabilize
-/

#print MeasureTheory.upperCrossingTime_stabilize /-
theorem upperCrossingTime_stabilize (hnm : n ≤ m) (hn : upperCrossingTime a b f N n ω = N) :
    upperCrossingTime a b f N m ω = N :=
  le_antisymm upperCrossingTime_le (le_trans (le_of_eq hn.symm) (upperCrossingTime_mono hnm))
#align measure_theory.upper_crossing_time_stabilize MeasureTheory.upperCrossingTime_stabilize
-/

#print MeasureTheory.lowerCrossingTime_stabilize' /-
theorem lowerCrossingTime_stabilize' (hnm : n ≤ m) (hn : N ≤ lowerCrossingTime a b f N n ω) :
    lowerCrossingTime a b f N m ω = N :=
  lowerCrossingTime_stabilize hnm (le_antisymm lowerCrossingTime_le hn)
#align measure_theory.lower_crossing_time_stabilize' MeasureTheory.lowerCrossingTime_stabilize'
-/

#print MeasureTheory.upperCrossingTime_stabilize' /-
theorem upperCrossingTime_stabilize' (hnm : n ≤ m) (hn : N ≤ upperCrossingTime a b f N n ω) :
    upperCrossingTime a b f N m ω = N :=
  upperCrossingTime_stabilize hnm (le_antisymm upperCrossingTime_le hn)
#align measure_theory.upper_crossing_time_stabilize' MeasureTheory.upperCrossingTime_stabilize'
-/

#print MeasureTheory.exists_upperCrossingTime_eq /-
-- `upper_crossing_time_bound_eq` provides an explicit bound
theorem exists_upperCrossingTime_eq (f : ℕ → Ω → ℝ) (N : ℕ) (ω : Ω) (hab : a < b) :
    ∃ n, upperCrossingTime a b f N n ω = N :=
  by
  by_contra h; push_neg at h 
  have : StrictMono fun n => upper_crossing_time a b f N n ω :=
    strictMono_nat_of_lt_succ fun n => upper_crossing_time_lt_succ hab (h _)
  obtain ⟨_, ⟨k, rfl⟩, hk⟩ :
    ∃ (m : _) (hm : m ∈ Set.range fun n => upper_crossing_time a b f N n ω), N < m :=
    ⟨upper_crossing_time a b f N (N + 1) ω, ⟨N + 1, rfl⟩,
      lt_of_lt_of_le N.lt_succ_self (StrictMono.id_le this (N + 1))⟩
  exact not_le.2 hk upper_crossing_time_le
#align measure_theory.exists_upper_crossing_time_eq MeasureTheory.exists_upperCrossingTime_eq
-/

#print MeasureTheory.upperCrossingTime_lt_bddAbove /-
theorem upperCrossingTime_lt_bddAbove (hab : a < b) :
    BddAbove {n | upperCrossingTime a b f N n ω < N} :=
  by
  obtain ⟨k, hk⟩ := exists_upper_crossing_time_eq f N ω hab
  refine' ⟨k, fun n (hn : upper_crossing_time a b f N n ω < N) => _⟩
  by_contra hn'
  exact hn.ne (upper_crossing_time_stabilize (not_le.1 hn').le hk)
#align measure_theory.upper_crossing_time_lt_bdd_above MeasureTheory.upperCrossingTime_lt_bddAbove
-/

#print MeasureTheory.upperCrossingTime_lt_nonempty /-
theorem upperCrossingTime_lt_nonempty (hN : 0 < N) :
    {n | upperCrossingTime a b f N n ω < N}.Nonempty :=
  ⟨0, hN⟩
#align measure_theory.upper_crossing_time_lt_nonempty MeasureTheory.upperCrossingTime_lt_nonempty
-/

#print MeasureTheory.upperCrossingTime_bound_eq /-
theorem upperCrossingTime_bound_eq (f : ℕ → Ω → ℝ) (N : ℕ) (ω : Ω) (hab : a < b) :
    upperCrossingTime a b f N N ω = N :=
  by
  by_cases hN' : N < Nat.find (exists_upper_crossing_time_eq f N ω hab)
  · refine' le_antisymm upper_crossing_time_le _
    have hmono :
      StrictMonoOn (fun n => upper_crossing_time a b f N n ω)
        (Set.Iic (Nat.find (exists_upper_crossing_time_eq f N ω hab)).pred) :=
      by
      refine' strictMonoOn_Iic_of_lt_succ fun m hm => upper_crossing_time_lt_succ hab _
      rw [Nat.lt_pred_iff] at hm 
      convert Nat.find_min _ hm
    convert StrictMonoOn.Iic_id_le hmono N (Nat.le_pred_of_lt hN')
  · rw [not_lt] at hN' 
    exact
      upper_crossing_time_stabilize hN' (Nat.find_spec (exists_upper_crossing_time_eq f N ω hab))
#align measure_theory.upper_crossing_time_bound_eq MeasureTheory.upperCrossingTime_bound_eq
-/

#print MeasureTheory.upperCrossingTime_eq_of_bound_le /-
theorem upperCrossingTime_eq_of_bound_le (hab : a < b) (hn : N ≤ n) :
    upperCrossingTime a b f N n ω = N :=
  le_antisymm upperCrossingTime_le
    (le_trans (upperCrossingTime_bound_eq f N ω hab).symm.le (upperCrossingTime_mono hn))
#align measure_theory.upper_crossing_time_eq_of_bound_le MeasureTheory.upperCrossingTime_eq_of_bound_le
-/

variable {ℱ : Filtration ℕ m0}

#print MeasureTheory.Adapted.isStoppingTime_crossing /-
theorem Adapted.isStoppingTime_crossing (hf : Adapted ℱ f) :
    IsStoppingTime ℱ (upperCrossingTime a b f N n) ∧
      IsStoppingTime ℱ (lowerCrossingTime a b f N n) :=
  by
  induction' n with k ih
  · refine' ⟨is_stopping_time_const _ 0, _⟩
    simp [hitting_is_stopping_time hf measurableSet_Iic]
  · obtain ⟨ih₁, ih₂⟩ := ih
    have : is_stopping_time ℱ (upper_crossing_time a b f N (k + 1)) :=
      by
      intro n
      simp_rw [upper_crossing_time_succ_eq]
      exact
        is_stopping_time_hitting_is_stopping_time ih₂ (fun _ => lower_crossing_time_le)
          measurableSet_Ici hf _
    refine' ⟨this, _⟩
    · intro n
      exact
        is_stopping_time_hitting_is_stopping_time this (fun _ => upper_crossing_time_le)
          measurableSet_Iic hf _
#align measure_theory.adapted.is_stopping_time_crossing MeasureTheory.Adapted.isStoppingTime_crossing
-/

#print MeasureTheory.Adapted.isStoppingTime_upperCrossingTime /-
theorem Adapted.isStoppingTime_upperCrossingTime (hf : Adapted ℱ f) :
    IsStoppingTime ℱ (upperCrossingTime a b f N n) :=
  hf.isStoppingTime_crossing.1
#align measure_theory.adapted.is_stopping_time_upper_crossing_time MeasureTheory.Adapted.isStoppingTime_upperCrossingTime
-/

#print MeasureTheory.Adapted.isStoppingTime_lowerCrossingTime /-
theorem Adapted.isStoppingTime_lowerCrossingTime (hf : Adapted ℱ f) :
    IsStoppingTime ℱ (lowerCrossingTime a b f N n) :=
  hf.isStoppingTime_crossing.2
#align measure_theory.adapted.is_stopping_time_lower_crossing_time MeasureTheory.Adapted.isStoppingTime_lowerCrossingTime
-/

#print MeasureTheory.upcrossingStrat /-
/-- `upcrossing_strat a b f N n` is 1 if `n` is between a consecutive pair of lower and upper
crossings and is 0 otherwise. `upcrossing_strat` is shifted by one index so that it is adapted
rather than predictable. -/
noncomputable def upcrossingStrat (a b : ℝ) (f : ℕ → Ω → ℝ) (N n : ℕ) (ω : Ω) : ℝ :=
  ∑ k in Finset.range N,
    (Set.Ico (lowerCrossingTime a b f N k ω) (upperCrossingTime a b f N (k + 1) ω)).indicator 1 n
#align measure_theory.upcrossing_strat MeasureTheory.upcrossingStrat
-/

#print MeasureTheory.upcrossingStrat_nonneg /-
theorem upcrossingStrat_nonneg : 0 ≤ upcrossingStrat a b f N n ω :=
  Finset.sum_nonneg fun i hi => Set.indicator_nonneg (fun ω hω => zero_le_one) _
#align measure_theory.upcrossing_strat_nonneg MeasureTheory.upcrossingStrat_nonneg
-/

#print MeasureTheory.upcrossingStrat_le_one /-
theorem upcrossingStrat_le_one : upcrossingStrat a b f N n ω ≤ 1 :=
  by
  rw [upcrossing_strat, ← Set.indicator_finset_biUnion_apply]
  · exact Set.indicator_le_self' (fun _ _ => zero_le_one) _
  · intro i hi j hj hij
    rw [Set.Ico_disjoint_Ico]
    obtain hij' | hij' := lt_or_gt_of_ne hij
    · rw [min_eq_left
          (upper_crossing_time_mono (Nat.succ_le_succ hij'.le) :
            upper_crossing_time a b f N _ ω ≤ upper_crossing_time a b f N _ ω),
        max_eq_right
          (lower_crossing_time_mono hij'.le :
            lower_crossing_time a b f N _ _ ≤ lower_crossing_time _ _ _ _ _ _)]
      refine'
        le_trans upper_crossing_time_le_lower_crossing_time
          (lower_crossing_time_mono (Nat.succ_le_of_lt hij'))
    · rw [gt_iff_lt] at hij' 
      rw [min_eq_right
          (upper_crossing_time_mono (Nat.succ_le_succ hij'.le) :
            upper_crossing_time a b f N _ ω ≤ upper_crossing_time a b f N _ ω),
        max_eq_left
          (lower_crossing_time_mono hij'.le :
            lower_crossing_time a b f N _ _ ≤ lower_crossing_time _ _ _ _ _ _)]
      refine'
        le_trans upper_crossing_time_le_lower_crossing_time
          (lower_crossing_time_mono (Nat.succ_le_of_lt hij'))
#align measure_theory.upcrossing_strat_le_one MeasureTheory.upcrossingStrat_le_one
-/

#print MeasureTheory.Adapted.upcrossingStrat_adapted /-
theorem Adapted.upcrossingStrat_adapted (hf : Adapted ℱ f) : Adapted ℱ (upcrossingStrat a b f N) :=
  by
  intro n
  change
    strongly_measurable[ℱ n] fun ω =>
      ∑ k in Finset.range N,
        ({n | lower_crossing_time a b f N k ω ≤ n} ∩
              {n | n < upper_crossing_time a b f N (k + 1) ω}).indicator
          1 n
  refine'
    Finset.stronglyMeasurable_sum _ fun i hi =>
      strongly_measurable_const.indicator ((hf.is_stopping_time_lower_crossing_time n).inter _)
  simp_rw [← not_le]
  exact (hf.is_stopping_time_upper_crossing_time n).compl
#align measure_theory.adapted.upcrossing_strat_adapted MeasureTheory.Adapted.upcrossingStrat_adapted
-/

#print MeasureTheory.Submartingale.sum_upcrossingStrat_mul /-
theorem Submartingale.sum_upcrossingStrat_mul [IsFiniteMeasure μ] (hf : Submartingale f ℱ μ)
    (a b : ℝ) (N : ℕ) :
    Submartingale
      (fun n : ℕ => ∑ k in Finset.range n, upcrossingStrat a b f N k * (f (k + 1) - f k)) ℱ μ :=
  hf.sum_mul_sub hf.Adapted.upcrossingStrat_adapted (fun _ _ => upcrossingStrat_le_one) fun _ _ =>
    upcrossingStrat_nonneg
#align measure_theory.submartingale.sum_upcrossing_strat_mul MeasureTheory.Submartingale.sum_upcrossingStrat_mul
-/

#print MeasureTheory.Submartingale.sum_sub_upcrossingStrat_mul /-
theorem Submartingale.sum_sub_upcrossingStrat_mul [IsFiniteMeasure μ] (hf : Submartingale f ℱ μ)
    (a b : ℝ) (N : ℕ) :
    Submartingale
      (fun n : ℕ => ∑ k in Finset.range n, (1 - upcrossingStrat a b f N k) * (f (k + 1) - f k)) ℱ
      μ :=
  by
  refine'
    hf.sum_mul_sub (fun n => (adapted_const ℱ 1 n).sub (hf.adapted.upcrossing_strat_adapted n))
      (_ : ∀ n ω, (1 - upcrossing_strat a b f N n) ω ≤ 1) _
  · exact fun n ω => sub_le_self _ upcrossing_strat_nonneg
  · intro n ω
    simp [upcrossing_strat_le_one]
#align measure_theory.submartingale.sum_sub_upcrossing_strat_mul MeasureTheory.Submartingale.sum_sub_upcrossingStrat_mul
-/

#print MeasureTheory.Submartingale.sum_mul_upcrossingStrat_le /-
theorem Submartingale.sum_mul_upcrossingStrat_le [IsFiniteMeasure μ] (hf : Submartingale f ℱ μ) :
    μ[∑ k in Finset.range n, upcrossingStrat a b f N k * (f (k + 1) - f k)] ≤ μ[f n] - μ[f 0] :=
  by
  have h₁ :
    (0 : ℝ) ≤ μ[∑ k in Finset.range n, (1 - upcrossing_strat a b f N k) * (f (k + 1) - f k)] :=
    by
    have := (hf.sum_sub_upcrossing_strat_mul a b N).set_integral_le (zero_le n) MeasurableSet.univ
    rw [integral_univ, integral_univ] at this 
    refine' le_trans _ this
    simp only [Finset.range_zero, Finset.sum_empty, integral_zero']
  have h₂ :
    μ[∑ k in Finset.range n, (1 - upcrossing_strat a b f N k) * (f (k + 1) - f k)] =
      μ[∑ k in Finset.range n, (f (k + 1) - f k)] -
        μ[∑ k in Finset.range n, upcrossing_strat a b f N k * (f (k + 1) - f k)] :=
    by
    simp only [sub_mul, one_mul, Finset.sum_sub_distrib, Pi.sub_apply, Finset.sum_apply,
      Pi.mul_apply]
    refine'
      integral_sub
        (integrable.sub (integrable_finset_sum _ fun i hi => hf.integrable _)
          (integrable_finset_sum _ fun i hi => hf.integrable _))
        _
    convert (hf.sum_upcrossing_strat_mul a b N).Integrable n
    ext; simp
  rw [h₂, sub_nonneg] at h₁ 
  refine' le_trans h₁ _
  simp_rw [Finset.sum_range_sub, integral_sub' (hf.integrable _) (hf.integrable _)]
#align measure_theory.submartingale.sum_mul_upcrossing_strat_le MeasureTheory.Submartingale.sum_mul_upcrossingStrat_le
-/

#print MeasureTheory.upcrossingsBefore /-
/-- The number of upcrossings (strictly) before time `N`. -/
noncomputable def upcrossingsBefore [Preorder ι] [OrderBot ι] [InfSet ι] (a b : ℝ) (f : ι → Ω → ℝ)
    (N : ι) (ω : Ω) : ℕ :=
  sSup {n | upperCrossingTime a b f N n ω < N}
#align measure_theory.upcrossings_before MeasureTheory.upcrossingsBefore
-/

#print MeasureTheory.upcrossingsBefore_bot /-
@[simp]
theorem upcrossingsBefore_bot [Preorder ι] [OrderBot ι] [InfSet ι] {a b : ℝ} {f : ι → Ω → ℝ}
    {ω : Ω} : upcrossingsBefore a b f ⊥ ω = ⊥ := by simp [upcrossings_before]
#align measure_theory.upcrossings_before_bot MeasureTheory.upcrossingsBefore_bot
-/

#print MeasureTheory.upcrossingsBefore_zero /-
theorem upcrossingsBefore_zero : upcrossingsBefore a b f 0 ω = 0 := by simp [upcrossings_before]
#align measure_theory.upcrossings_before_zero MeasureTheory.upcrossingsBefore_zero
-/

#print MeasureTheory.upcrossingsBefore_zero' /-
@[simp]
theorem upcrossingsBefore_zero' : upcrossingsBefore a b f 0 = 0 := by ext ω;
  exact upcrossings_before_zero
#align measure_theory.upcrossings_before_zero' MeasureTheory.upcrossingsBefore_zero'
-/

#print MeasureTheory.upperCrossingTime_lt_of_le_upcrossingsBefore /-
theorem upperCrossingTime_lt_of_le_upcrossingsBefore (hN : 0 < N) (hab : a < b)
    (hn : n ≤ upcrossingsBefore a b f N ω) : upperCrossingTime a b f N n ω < N :=
  haveI : upper_crossing_time a b f N (upcrossings_before a b f N ω) ω < N :=
    (upper_crossing_time_lt_nonempty hN).cSup_mem
      ((OrderBot.bddBelow _).finite_of_bddAbove (upper_crossing_time_lt_bdd_above hab))
  lt_of_le_of_lt (upper_crossing_time_mono hn) this
#align measure_theory.upper_crossing_time_lt_of_le_upcrossings_before MeasureTheory.upperCrossingTime_lt_of_le_upcrossingsBefore
-/

#print MeasureTheory.upperCrossingTime_eq_of_upcrossingsBefore_lt /-
theorem upperCrossingTime_eq_of_upcrossingsBefore_lt (hab : a < b)
    (hn : upcrossingsBefore a b f N ω < n) : upperCrossingTime a b f N n ω = N :=
  by
  refine' le_antisymm upper_crossing_time_le (not_lt.1 _)
  convert not_mem_of_csSup_lt hn (upper_crossing_time_lt_bdd_above hab)
#align measure_theory.upper_crossing_time_eq_of_upcrossings_before_lt MeasureTheory.upperCrossingTime_eq_of_upcrossingsBefore_lt
-/

#print MeasureTheory.upcrossingsBefore_le /-
theorem upcrossingsBefore_le (f : ℕ → Ω → ℝ) (ω : Ω) (hab : a < b) :
    upcrossingsBefore a b f N ω ≤ N := by
  by_cases hN : N = 0
  · subst hN
    rw [upcrossings_before_zero]
  · refine' csSup_le ⟨0, zero_lt_iff.2 hN⟩ fun n (hn : _ < _) => _
    by_contra hnN
    exact hn.ne (upper_crossing_time_eq_of_bound_le hab (not_le.1 hnN).le)
#align measure_theory.upcrossings_before_le MeasureTheory.upcrossingsBefore_le
-/

#print MeasureTheory.crossing_eq_crossing_of_lowerCrossingTime_lt /-
theorem crossing_eq_crossing_of_lowerCrossingTime_lt {M : ℕ} (hNM : N ≤ M)
    (h : lowerCrossingTime a b f N n ω < N) :
    upperCrossingTime a b f M n ω = upperCrossingTime a b f N n ω ∧
      lowerCrossingTime a b f M n ω = lowerCrossingTime a b f N n ω :=
  by
  have h' : upper_crossing_time a b f N n ω < N :=
    lt_of_le_of_lt upper_crossing_time_le_lower_crossing_time h
  induction' n with k ih
  · simp only [Nat.zero_eq, upper_crossing_time_zero, bot_eq_zero', eq_self_iff_true,
      lower_crossing_time_zero, true_and_iff, eq_comm]
    refine' hitting_eq_hitting_of_exists hNM _
    simp only [lower_crossing_time, hitting_lt_iff] at h 
    obtain ⟨j, hj₁, hj₂⟩ := h
    exact ⟨j, ⟨hj₁.1, hj₁.2.le⟩, hj₂⟩
  · specialize
      ih (lt_of_le_of_lt (lower_crossing_time_mono (Nat.le_succ _)) h)
        (lt_of_le_of_lt (upper_crossing_time_mono (Nat.le_succ _)) h')
    have : upper_crossing_time a b f M k.succ ω = upper_crossing_time a b f N k.succ ω :=
      by
      simp only [upper_crossing_time_succ_eq, hitting_lt_iff] at h' ⊢
      obtain ⟨j, hj₁, hj₂⟩ := h'
      rw [eq_comm, ih.2]
      exact hitting_eq_hitting_of_exists hNM ⟨j, ⟨hj₁.1, hj₁.2.le⟩, hj₂⟩
    refine' ⟨this, _⟩
    simp only [lower_crossing_time, eq_comm, this]
    refine' hitting_eq_hitting_of_exists hNM _
    rw [lower_crossing_time, hitting_lt_iff _ le_rfl] at h 
    swap; · infer_instance
    obtain ⟨j, hj₁, hj₂⟩ := h
    exact ⟨j, ⟨hj₁.1, hj₁.2.le⟩, hj₂⟩
#align measure_theory.crossing_eq_crossing_of_lower_crossing_time_lt MeasureTheory.crossing_eq_crossing_of_lowerCrossingTime_lt
-/

#print MeasureTheory.crossing_eq_crossing_of_upperCrossingTime_lt /-
theorem crossing_eq_crossing_of_upperCrossingTime_lt {M : ℕ} (hNM : N ≤ M)
    (h : upperCrossingTime a b f N (n + 1) ω < N) :
    upperCrossingTime a b f M (n + 1) ω = upperCrossingTime a b f N (n + 1) ω ∧
      lowerCrossingTime a b f M n ω = lowerCrossingTime a b f N n ω :=
  by
  have :=
    (crossing_eq_crossing_of_lower_crossing_time_lt hNM
        (lt_of_le_of_lt lower_crossing_time_le_upper_crossing_time_succ h)).2
  refine' ⟨_, this⟩
  rw [upper_crossing_time_succ_eq, upper_crossing_time_succ_eq, eq_comm, this]
  refine' hitting_eq_hitting_of_exists hNM _
  simp only [upper_crossing_time_succ_eq, hitting_lt_iff] at h 
  obtain ⟨j, hj₁, hj₂⟩ := h
  exact ⟨j, ⟨hj₁.1, hj₁.2.le⟩, hj₂⟩
#align measure_theory.crossing_eq_crossing_of_upper_crossing_time_lt MeasureTheory.crossing_eq_crossing_of_upperCrossingTime_lt
-/

#print MeasureTheory.upperCrossingTime_eq_upperCrossingTime_of_lt /-
theorem upperCrossingTime_eq_upperCrossingTime_of_lt {M : ℕ} (hNM : N ≤ M)
    (h : upperCrossingTime a b f N n ω < N) :
    upperCrossingTime a b f M n ω = upperCrossingTime a b f N n ω :=
  by
  cases n
  · simp
  · exact (crossing_eq_crossing_of_upper_crossing_time_lt hNM h).1
#align measure_theory.upper_crossing_time_eq_upper_crossing_time_of_lt MeasureTheory.upperCrossingTime_eq_upperCrossingTime_of_lt
-/

#print MeasureTheory.upcrossingsBefore_mono /-
theorem upcrossingsBefore_mono (hab : a < b) : Monotone fun N ω => upcrossingsBefore a b f N ω :=
  by
  intro N M hNM ω
  simp only [upcrossings_before]
  by_cases hemp : {n : ℕ | upper_crossing_time a b f N n ω < N}.Nonempty
  · refine' csSup_le_csSup (upper_crossing_time_lt_bdd_above hab) hemp fun n hn => _
    rw [Set.mem_setOf_eq, upper_crossing_time_eq_upper_crossing_time_of_lt hNM hn]
    exact lt_of_lt_of_le hn hNM
  · rw [Set.not_nonempty_iff_eq_empty] at hemp 
    simp [hemp, csSup_empty, bot_eq_zero', zero_le']
#align measure_theory.upcrossings_before_mono MeasureTheory.upcrossingsBefore_mono
-/

#print MeasureTheory.upcrossingsBefore_lt_of_exists_upcrossing /-
theorem upcrossingsBefore_lt_of_exists_upcrossing (hab : a < b) {N₁ N₂ : ℕ} (hN₁ : N ≤ N₁)
    (hN₁' : f N₁ ω < a) (hN₂ : N₁ ≤ N₂) (hN₂' : b < f N₂ ω) :
    upcrossingsBefore a b f N ω < upcrossingsBefore a b f (N₂ + 1) ω :=
  by
  refine' lt_of_lt_of_le (Nat.lt_succ_self _) (le_csSup (upper_crossing_time_lt_bdd_above hab) _)
  rw [Set.mem_setOf_eq, upper_crossing_time_succ_eq, hitting_lt_iff _ le_rfl]
  swap
  · infer_instance
  · refine' ⟨N₂, ⟨_, Nat.lt_succ_self _⟩, hN₂'.le⟩
    rw [lower_crossing_time, hitting_le_iff_of_lt _ (Nat.lt_succ_self _)]
    refine' ⟨N₁, ⟨le_trans _ hN₁, hN₂⟩, hN₁'.le⟩
    by_cases hN : 0 < N
    · have : upper_crossing_time a b f N (upcrossings_before a b f N ω) ω < N :=
        Nat.sSup_mem (upper_crossing_time_lt_nonempty hN) (upper_crossing_time_lt_bdd_above hab)
      rw [upper_crossing_time_eq_upper_crossing_time_of_lt (hN₁.trans (hN₂.trans <| Nat.le_succ _))
          this]
      exact this.le
    · rw [not_lt, le_zero_iff] at hN 
      rw [hN, upcrossings_before_zero, upper_crossing_time_zero]
      rfl
#align measure_theory.upcrossings_before_lt_of_exists_upcrossing MeasureTheory.upcrossingsBefore_lt_of_exists_upcrossing
-/

#print MeasureTheory.lowerCrossingTime_lt_of_lt_upcrossingsBefore /-
theorem lowerCrossingTime_lt_of_lt_upcrossingsBefore (hN : 0 < N) (hab : a < b)
    (hn : n < upcrossingsBefore a b f N ω) : lowerCrossingTime a b f N n ω < N :=
  lt_of_le_of_lt lowerCrossingTime_le_upperCrossingTime_succ
    (upperCrossingTime_lt_of_le_upcrossingsBefore hN hab hn)
#align measure_theory.lower_crossing_time_lt_of_lt_upcrossings_before MeasureTheory.lowerCrossingTime_lt_of_lt_upcrossingsBefore
-/

#print MeasureTheory.le_sub_of_le_upcrossingsBefore /-
theorem le_sub_of_le_upcrossingsBefore (hN : 0 < N) (hab : a < b)
    (hn : n < upcrossingsBefore a b f N ω) :
    b - a ≤
      stoppedValue f (upperCrossingTime a b f N (n + 1)) ω -
        stoppedValue f (lowerCrossingTime a b f N n) ω :=
  sub_le_sub
    (stoppedValue_upperCrossingTime (upperCrossingTime_lt_of_le_upcrossingsBefore hN hab hn).Ne)
    (stoppedValue_lowerCrossingTime (lowerCrossingTime_lt_of_lt_upcrossingsBefore hN hab hn).Ne)
#align measure_theory.le_sub_of_le_upcrossings_before MeasureTheory.le_sub_of_le_upcrossingsBefore
-/

#print MeasureTheory.sub_eq_zero_of_upcrossingsBefore_lt /-
theorem sub_eq_zero_of_upcrossingsBefore_lt (hab : a < b) (hn : upcrossingsBefore a b f N ω < n) :
    stoppedValue f (upperCrossingTime a b f N (n + 1)) ω -
        stoppedValue f (lowerCrossingTime a b f N n) ω =
      0 :=
  by
  have : N ≤ upper_crossing_time a b f N n ω :=
    by
    rw [upcrossings_before] at hn 
    rw [← not_lt]
    exact fun h => not_le.2 hn (le_csSup (upper_crossing_time_lt_bdd_above hab) h)
  simp [stopped_value, upper_crossing_time_stabilize' (Nat.le_succ n) this,
    lower_crossing_time_stabilize' le_rfl
      (le_trans this upper_crossing_time_le_lower_crossing_time)]
#align measure_theory.sub_eq_zero_of_upcrossings_before_lt MeasureTheory.sub_eq_zero_of_upcrossingsBefore_lt
-/

#print MeasureTheory.mul_upcrossingsBefore_le /-
theorem mul_upcrossingsBefore_le (hf : a ≤ f N ω) (hab : a < b) :
    (b - a) * upcrossingsBefore a b f N ω ≤
      ∑ k in Finset.range N, upcrossingStrat a b f N k ω * (f (k + 1) - f k) ω :=
  by
  classical
  by_cases hN : N = 0
  · simp [hN]
  simp_rw [upcrossing_strat, Finset.sum_mul, ← Set.indicator_mul_left, Pi.one_apply, Pi.sub_apply,
    one_mul]
  rw [Finset.sum_comm]
  have h₁ :
    ∀ k,
      ∑ n in Finset.range N,
          (Set.Ico (lower_crossing_time a b f N k ω)
                (upper_crossing_time a b f N (k + 1) ω)).indicator
            (fun m => f (m + 1) ω - f m ω) n =
        stopped_value f (upper_crossing_time a b f N (k + 1)) ω -
          stopped_value f (lower_crossing_time a b f N k) ω :=
    by
    intro k
    rw [Finset.sum_indicator_eq_sum_filter,
      (_ :
        Finset.filter
            (fun i =>
              i ∈ Set.Ico (lower_crossing_time a b f N k ω) (upper_crossing_time a b f N (k + 1) ω))
            (Finset.range N) =
          Finset.Ico (lower_crossing_time a b f N k ω) (upper_crossing_time a b f N (k + 1) ω)),
      Finset.sum_Ico_eq_add_neg _ lower_crossing_time_le_upper_crossing_time_succ,
      Finset.sum_range_sub fun n => f n ω, Finset.sum_range_sub fun n => f n ω, neg_sub,
      sub_add_sub_cancel]
    · rfl
    · ext i
      simp only [Set.mem_Ico, Finset.mem_filter, Finset.mem_range, Finset.mem_Ico,
        and_iff_right_iff_imp, and_imp]
      exact fun _ h => lt_of_lt_of_le h upper_crossing_time_le
  simp_rw [h₁]
  have h₂ :
    ∑ k in Finset.range (upcrossings_before a b f N ω), (b - a) ≤
      ∑ k in Finset.range N,
        (stopped_value f (upper_crossing_time a b f N (k + 1)) ω -
          stopped_value f (lower_crossing_time a b f N k) ω) :=
    by
    calc
      ∑ k in Finset.range (upcrossings_before a b f N ω), (b - a) ≤
          ∑ k in Finset.range (upcrossings_before a b f N ω),
            (stopped_value f (upper_crossing_time a b f N (k + 1)) ω -
              stopped_value f (lower_crossing_time a b f N k) ω) :=
        by
        refine'
          Finset.sum_le_sum fun i hi => le_sub_of_le_upcrossings_before (zero_lt_iff.2 hN) hab _
        rwa [Finset.mem_range] at hi 
      _ ≤
          ∑ k in Finset.range N,
            (stopped_value f (upper_crossing_time a b f N (k + 1)) ω -
              stopped_value f (lower_crossing_time a b f N k) ω) :=
        by
        refine'
          Finset.sum_le_sum_of_subset_of_nonneg
            (Finset.range_subset.2 (upcrossings_before_le f ω hab)) fun i _ hi => _
        by_cases hi' : i = upcrossings_before a b f N ω
        · subst hi'
          simp only [stopped_value]
          rw [upper_crossing_time_eq_of_upcrossings_before_lt hab (Nat.lt_succ_self _)]
          by_cases heq : lower_crossing_time a b f N (upcrossings_before a b f N ω) ω = N
          · rw [HEq, sub_self]
          · rw [sub_nonneg]
            exact le_trans (stopped_value_lower_crossing_time HEq) hf
        · rw [sub_eq_zero_of_upcrossings_before_lt hab]
          rw [Finset.mem_range, not_lt] at hi 
          exact lt_of_le_of_ne hi (Ne.symm hi')
  refine' le_trans _ h₂
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_comm]
#align measure_theory.mul_upcrossings_before_le MeasureTheory.mul_upcrossingsBefore_le
-/

#print MeasureTheory.integral_mul_upcrossingsBefore_le_integral /-
theorem integral_mul_upcrossingsBefore_le_integral [IsFiniteMeasure μ] (hf : Submartingale f ℱ μ)
    (hfN : ∀ ω, a ≤ f N ω) (hfzero : 0 ≤ f 0) (hab : a < b) :
    (b - a) * μ[upcrossingsBefore a b f N] ≤ μ[f N] :=
  calc
    (b - a) * μ[upcrossingsBefore a b f N] ≤
        μ[∑ k in Finset.range N, upcrossingStrat a b f N k * (f (k + 1) - f k)] :=
      by
      rw [← integral_mul_left]
      refine' integral_mono_of_nonneg _ ((hf.sum_upcrossing_strat_mul a b N).Integrable N) _
      · exact eventually_of_forall fun ω => mul_nonneg (sub_nonneg.2 hab.le) (Nat.cast_nonneg _)
      · refine' eventually_of_forall fun ω => _
        simpa using mul_upcrossings_before_le (hfN ω) hab
    _ ≤ μ[f N] - μ[f 0] := hf.sum_mul_upcrossingStrat_le
    _ ≤ μ[f N] := (sub_le_self_iff _).2 (integral_nonneg hfzero)
#align measure_theory.integral_mul_upcrossings_before_le_integral MeasureTheory.integral_mul_upcrossingsBefore_le_integral
-/

#print MeasureTheory.crossing_pos_eq /-
theorem crossing_pos_eq (hab : a < b) :
    upperCrossingTime 0 (b - a) (fun n ω => (f n ω - a)⁺) N n = upperCrossingTime a b f N n ∧
      lowerCrossingTime 0 (b - a) (fun n ω => (f n ω - a)⁺) N n = lowerCrossingTime a b f N n :=
  by
  have hab' : 0 < b - a := sub_pos.2 hab
  have hf : ∀ ω i, b - a ≤ (f i ω - a)⁺ ↔ b ≤ f i ω :=
    by
    intro i ω
    refine' ⟨fun h => _, fun h => _⟩
    ·
      rwa [← sub_le_sub_iff_right a, ←
        LatticeOrderedCommGroup.pos_eq_self_of_pos_pos (lt_of_lt_of_le hab' h)]
    · rw [← sub_le_sub_iff_right a] at h 
      rwa [LatticeOrderedCommGroup.pos_of_nonneg _ (le_trans hab'.le h)]
  have hf' : ∀ ω i, (f i ω - a)⁺ ≤ 0 ↔ f i ω ≤ a :=
    by
    intro ω i
    rw [LatticeOrderedCommGroup.pos_nonpos_iff, sub_nonpos]
  induction' n with k ih
  · refine' ⟨rfl, _⟩
    simp only [lower_crossing_time_zero, hitting, Set.mem_Icc, Set.mem_Iic]
    ext ω
    split_ifs with h₁ h₂ h₂
    · simp_rw [hf']
    · simp_rw [Set.mem_Iic, ← hf' _ _] at h₂ 
      exact False.elim (h₂ h₁)
    · simp_rw [Set.mem_Iic, hf' _ _] at h₁ 
      exact False.elim (h₁ h₂)
    · rfl
  · have :
      upper_crossing_time 0 (b - a) (fun n ω => (f n ω - a)⁺) N (k + 1) =
        upper_crossing_time a b f N (k + 1) :=
      by
      ext ω
      simp only [upper_crossing_time_succ_eq, ← ih.2, hitting, Set.mem_Ici, tsub_le_iff_right]
      split_ifs with h₁ h₂ h₂
      · simp_rw [← sub_le_iff_le_add, hf ω]
      · simp_rw [Set.mem_Ici, ← hf _ _] at h₂ 
        exact False.elim (h₂ h₁)
      · simp_rw [Set.mem_Ici, hf _ _] at h₁ 
        exact False.elim (h₁ h₂)
      · rfl
    refine' ⟨this, _⟩
    ext ω
    simp only [lower_crossing_time, this, hitting, Set.mem_Iic]
    split_ifs with h₁ h₂ h₂
    · simp_rw [hf' ω]
    · simp_rw [Set.mem_Iic, ← hf' _ _] at h₂ 
      exact False.elim (h₂ h₁)
    · simp_rw [Set.mem_Iic, hf' _ _] at h₁ 
      exact False.elim (h₁ h₂)
    · rfl
#align measure_theory.crossing_pos_eq MeasureTheory.crossing_pos_eq
-/

#print MeasureTheory.upcrossingsBefore_pos_eq /-
theorem upcrossingsBefore_pos_eq (hab : a < b) :
    upcrossingsBefore 0 (b - a) (fun n ω => (f n ω - a)⁺) N ω = upcrossingsBefore a b f N ω := by
  simp_rw [upcrossings_before, (crossing_pos_eq hab).1]
#align measure_theory.upcrossings_before_pos_eq MeasureTheory.upcrossingsBefore_pos_eq
-/

#print MeasureTheory.mul_integral_upcrossingsBefore_le_integral_pos_part_aux /-
theorem mul_integral_upcrossingsBefore_le_integral_pos_part_aux [IsFiniteMeasure μ]
    (hf : Submartingale f ℱ μ) (hab : a < b) :
    (b - a) * μ[upcrossingsBefore a b f N] ≤ μ[fun ω => (f N ω - a)⁺] :=
  by
  refine'
    le_trans (le_of_eq _)
      (integral_mul_upcrossings_before_le_integral (hf.sub_martingale (martingale_const _ _ _)).Pos
        (fun ω => LatticeOrderedCommGroup.pos_nonneg _)
        (fun ω => LatticeOrderedCommGroup.pos_nonneg _) (sub_pos.2 hab))
  simp_rw [sub_zero, ← upcrossings_before_pos_eq hab]
  rfl
#align measure_theory.mul_integral_upcrossings_before_le_integral_pos_part_aux MeasureTheory.mul_integral_upcrossingsBefore_le_integral_pos_part_aux
-/

#print MeasureTheory.Submartingale.mul_integral_upcrossingsBefore_le_integral_pos_part /-
/-- **Doob's upcrossing estimate**: given a real valued discrete submartingale `f` and real
values `a` and `b`, we have `(b - a) * 𝔼[upcrossings_before a b f N] ≤ 𝔼[(f N - a)⁺]` where
`upcrossings_before a b f N` is the number of times the process `f` crossed from below `a` to above
`b` before the time `N`. -/
theorem Submartingale.mul_integral_upcrossingsBefore_le_integral_pos_part [IsFiniteMeasure μ]
    (a b : ℝ) (hf : Submartingale f ℱ μ) (N : ℕ) :
    (b - a) * μ[upcrossingsBefore a b f N] ≤ μ[fun ω => (f N ω - a)⁺] :=
  by
  by_cases hab : a < b
  · exact mul_integral_upcrossings_before_le_integral_pos_part_aux hf hab
  · rw [not_lt, ← sub_nonpos] at hab 
    exact
      le_trans (mul_nonpos_of_nonpos_of_nonneg hab (integral_nonneg fun ω => Nat.cast_nonneg _))
        (integral_nonneg fun ω => LatticeOrderedCommGroup.pos_nonneg _)
#align measure_theory.submartingale.mul_integral_upcrossings_before_le_integral_pos_part MeasureTheory.Submartingale.mul_integral_upcrossingsBefore_le_integral_pos_part
-/

/-!

### Variant of the upcrossing estimate

Now, we would like to prove a variant of the upcrossing estimate obtained by taking the supremum
over $N$ of the original upcrossing estimate. Namely, we want the inequality
$$
  (b - a) \sup_N \mathbb{E}[U_N(a, b)] \le \sup_N \mathbb{E}[f_N].
$$
This inequality is central for the martingale convergence theorem as it provides a uniform bound
for the upcrossings.

We note that on top of taking the supremum on both sides of the inequality, we had also used
the monotone convergence theorem on the left hand side to take the supremum outside of the
integral. To do this, we need to make sure $U_N(a, b)$ is measurable and integrable. Integrability
is easy to check as $U_N(a, b) ≤ N$ and so it suffices to show measurability. Indeed, by
noting that
$$
  U_N(a, b) = \sum_{i = 1}^N \mathbf{1}_{\{U_N(a, b) < N\}}
$$
$U_N(a, b)$ is measurable as $\{U_N(a, b) < N\}$ is a measurable set since $U_N(a, b)$ is a
stopping time.

-/


#print MeasureTheory.upcrossingsBefore_eq_sum /-
theorem upcrossingsBefore_eq_sum (hab : a < b) :
    upcrossingsBefore a b f N ω =
      ∑ i in Finset.Ico 1 (N + 1), {n | upperCrossingTime a b f N n ω < N}.indicator 1 i :=
  by
  by_cases hN : N = 0
  · simp [hN]
  rw [←
    Finset.sum_Ico_consecutive _ (Nat.succ_le_succ zero_le')
      (Nat.succ_le_succ (upcrossings_before_le f ω hab))]
  have h₁ :
    ∀ k ∈ Finset.Ico 1 (upcrossings_before a b f N ω + 1),
      {n : ℕ | upper_crossing_time a b f N n ω < N}.indicator 1 k = 1 :=
    by
    rintro k hk
    rw [Finset.mem_Ico] at hk 
    rw [Set.indicator_of_mem]
    · rfl
    ·
      exact
        upper_crossing_time_lt_of_le_upcrossings_before (zero_lt_iff.2 hN) hab
          (Nat.lt_succ_iff.1 hk.2)
  have h₂ :
    ∀ k ∈ Finset.Ico (upcrossings_before a b f N ω + 1) (N + 1),
      {n : ℕ | upper_crossing_time a b f N n ω < N}.indicator 1 k = 0 :=
    by
    rintro k hk
    rw [Finset.mem_Ico, Nat.succ_le_iff] at hk 
    rw [Set.indicator_of_not_mem]
    simp only [Set.mem_setOf_eq, not_lt]
    exact (upper_crossing_time_eq_of_upcrossings_before_lt hab hk.1).symm.le
  rw [Finset.sum_congr rfl h₁, Finset.sum_congr rfl h₂, Finset.sum_const, Finset.sum_const,
    smul_eq_mul, mul_one, smul_eq_mul, MulZeroClass.mul_zero, Nat.card_Ico, Nat.add_succ_sub_one,
    add_zero, add_zero]
#align measure_theory.upcrossings_before_eq_sum MeasureTheory.upcrossingsBefore_eq_sum
-/

#print MeasureTheory.Adapted.measurable_upcrossingsBefore /-
theorem Adapted.measurable_upcrossingsBefore (hf : Adapted ℱ f) (hab : a < b) :
    Measurable (upcrossingsBefore a b f N) :=
  by
  have :
    upcrossings_before a b f N = fun ω =>
      ∑ i in Finset.Ico 1 (N + 1), {n | upper_crossing_time a b f N n ω < N}.indicator 1 i :=
    by
    ext ω
    exact upcrossings_before_eq_sum hab
  rw [this]
  exact
    Finset.measurable_sum _ fun i hi =>
      Measurable.indicator measurable_const <|
        ℱ.le N _ (hf.is_stopping_time_upper_crossing_time.measurable_set_lt_of_pred N)
#align measure_theory.adapted.measurable_upcrossings_before MeasureTheory.Adapted.measurable_upcrossingsBefore
-/

#print MeasureTheory.Adapted.integrable_upcrossingsBefore /-
theorem Adapted.integrable_upcrossingsBefore [IsFiniteMeasure μ] (hf : Adapted ℱ f) (hab : a < b) :
    Integrable (fun ω => (upcrossingsBefore a b f N ω : ℝ)) μ :=
  haveI : ∀ᵐ ω ∂μ, ‖(upcrossings_before a b f N ω : ℝ)‖ ≤ N :=
    by
    refine' eventually_of_forall fun ω => _
    rw [Real.norm_eq_abs, Nat.abs_cast, Nat.cast_le]
    refine' upcrossings_before_le _ _ hab
  ⟨Measurable.aestronglyMeasurable
      (measurable_from_top.comp (hf.measurable_upcrossings_before hab)),
    has_finite_integral_of_bounded this⟩
#align measure_theory.adapted.integrable_upcrossings_before MeasureTheory.Adapted.integrable_upcrossingsBefore
-/

#print MeasureTheory.upcrossings /-
/-- The number of upcrossings of a realization of a stochastic process (`upcrossing` takes value
in `ℝ≥0∞` and so is allowed to be `∞`). -/
noncomputable def upcrossings [Preorder ι] [OrderBot ι] [InfSet ι] (a b : ℝ) (f : ι → Ω → ℝ)
    (ω : Ω) : ℝ≥0∞ :=
  ⨆ N, (upcrossingsBefore a b f N ω : ℝ≥0∞)
#align measure_theory.upcrossings MeasureTheory.upcrossings
-/

#print MeasureTheory.Adapted.measurable_upcrossings /-
theorem Adapted.measurable_upcrossings (hf : Adapted ℱ f) (hab : a < b) :
    Measurable (upcrossings a b f) :=
  measurable_iSup fun N => measurable_from_top.comp (hf.measurable_upcrossingsBefore hab)
#align measure_theory.adapted.measurable_upcrossings MeasureTheory.Adapted.measurable_upcrossings
-/

#print MeasureTheory.upcrossings_lt_top_iff /-
theorem upcrossings_lt_top_iff :
    upcrossings a b f ω < ∞ ↔ ∃ k, ∀ N, upcrossingsBefore a b f N ω ≤ k :=
  by
  have : upcrossings a b f ω < ∞ ↔ ∃ k : ℝ≥0, upcrossings a b f ω ≤ k :=
    by
    constructor
    · intro h
      lift upcrossings a b f ω to ℝ≥0 using h.ne with r hr
      exact ⟨r, le_rfl⟩
    · rintro ⟨k, hk⟩
      exact lt_of_le_of_lt hk ENNReal.coe_lt_top
  simp_rw [this, upcrossings, iSup_le_iff]
  constructor <;> rintro ⟨k, hk⟩
  · obtain ⟨m, hm⟩ := exists_nat_ge k
    refine' ⟨m, fun N => Nat.cast_le.1 ((hk N).trans _)⟩
    rwa [← ENNReal.coe_nat, ENNReal.coe_le_coe]
  · refine' ⟨k, fun N => _⟩
    simp only [ENNReal.coe_nat, Nat.cast_le, hk N]
#align measure_theory.upcrossings_lt_top_iff MeasureTheory.upcrossings_lt_top_iff
-/

#print MeasureTheory.Submartingale.mul_lintegral_upcrossings_le_lintegral_pos_part /-
/-- A variant of Doob's upcrossing estimate obtained by taking the supremum on both sides. -/
theorem Submartingale.mul_lintegral_upcrossings_le_lintegral_pos_part [IsFiniteMeasure μ] (a b : ℝ)
    (hf : Submartingale f ℱ μ) :
    ENNReal.ofReal (b - a) * ∫⁻ ω, upcrossings a b f ω ∂μ ≤
      ⨆ N, ∫⁻ ω, ENNReal.ofReal ((f N ω - a)⁺) ∂μ :=
  by
  by_cases hab : a < b
  · simp_rw [upcrossings]
    have : ∀ N, ∫⁻ ω, ENNReal.ofReal ((f N ω - a)⁺) ∂μ = ENNReal.ofReal (∫ ω, (f N ω - a)⁺ ∂μ) :=
      by
      intro N
      rw [of_real_integral_eq_lintegral_of_real]
      · exact (hf.sub_martingale (martingale_const _ _ _)).Pos.Integrable _
      · exact eventually_of_forall fun ω => LatticeOrderedCommGroup.pos_nonneg _
    rw [lintegral_supr']
    · simp_rw [this, ENNReal.mul_iSup, iSup_le_iff]
      intro N
      rw [(by simp :
          ∫⁻ ω, upcrossings_before a b f N ω ∂μ = ∫⁻ ω, ↑(upcrossings_before a b f N ω : ℝ≥0) ∂μ),
        lintegral_coe_eq_integral, ← ENNReal.ofReal_mul (sub_pos.2 hab).le]
      · simp_rw [NNReal.coe_nat_cast]
        exact
          (ENNReal.ofReal_le_ofReal
                (hf.mul_integral_upcrossings_before_le_integral_pos_part a b N)).trans
            (le_iSup _ N)
      · simp only [NNReal.coe_nat_cast, hf.adapted.integrable_upcrossings_before hab]
    ·
      exact fun n =>
        measurable_from_top.comp_ae_measurable
          (hf.adapted.measurable_upcrossings_before hab).AEMeasurable
    · refine' eventually_of_forall fun ω N M hNM => _
      rw [Nat.cast_le]
      exact upcrossings_before_mono hab hNM ω
  · rw [not_lt, ← sub_nonpos] at hab 
    rw [ENNReal.ofReal_of_nonpos hab, MulZeroClass.zero_mul]
    exact zero_le _
#align measure_theory.submartingale.mul_lintegral_upcrossings_le_lintegral_pos_part MeasureTheory.Submartingale.mul_lintegral_upcrossings_le_lintegral_pos_part
-/

end MeasureTheory

