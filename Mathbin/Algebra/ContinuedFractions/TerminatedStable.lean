/-
Copyright (c) 2020 Kevin Kappelmann. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Kappelmann

! This file was ported from Lean 3 source module algebra.continued_fractions.terminated_stable
! leanprover-community/mathlib commit b5ad141426bb005414324f89719c77c0aa3ec612
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.ContinuedFractions.Translations

/-!
# Stabilisation of gcf Computations Under Termination

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Summary

We show that the continuants and convergents of a gcf stabilise once the gcf terminates.
-/


namespace GeneralizedContinuedFraction

/- ./././Mathport/Syntax/Translate/Command.lean:230:11: unsupported: unusual advanced open style -/
variable {K : Type _} {g : GeneralizedContinuedFraction K} {n m : ℕ}

#print GeneralizedContinuedFraction.terminated_stable /-
/-- If a gcf terminated at position `n`, it also terminated at `m ≥ n`.-/
theorem terminated_stable (n_le_m : n ≤ m) (terminated_at_n : g.TerminatedAt n) :
    g.TerminatedAt m :=
  g.s.terminated_stable n_le_m terminated_at_n
#align generalized_continued_fraction.terminated_stable GeneralizedContinuedFraction.terminated_stable
-/

variable [DivisionRing K]

#print GeneralizedContinuedFraction.continuantsAux_stable_step_of_terminated /-
theorem continuantsAux_stable_step_of_terminated (terminated_at_n : g.TerminatedAt n) :
    g.continuantsAux (n + 2) = g.continuantsAux (n + 1) :=
  by
  rw [terminated_at_iff_s_none] at terminated_at_n 
  simp only [terminated_at_n, continuants_aux]
#align generalized_continued_fraction.continuants_aux_stable_step_of_terminated GeneralizedContinuedFraction.continuantsAux_stable_step_of_terminated
-/

#print GeneralizedContinuedFraction.continuantsAux_stable_of_terminated /-
theorem continuantsAux_stable_of_terminated (n_lt_m : n < m) (terminated_at_n : g.TerminatedAt n) :
    g.continuantsAux m = g.continuantsAux (n + 1) :=
  by
  refine' Nat.le_induction rfl (fun k hnk hk => _) _ n_lt_m
  rcases Nat.exists_eq_add_of_lt hnk with ⟨k, rfl⟩
  refine' (continuants_aux_stable_step_of_terminated _).trans hk
  exact terminated_stable (Nat.le_add_right _ _) terminated_at_n
#align generalized_continued_fraction.continuants_aux_stable_of_terminated GeneralizedContinuedFraction.continuantsAux_stable_of_terminated
-/

#print GeneralizedContinuedFraction.convergents'Aux_stable_step_of_terminated /-
theorem convergents'Aux_stable_step_of_terminated {s : Seq <| Pair K}
    (terminated_at_n : s.TerminatedAt n) : convergents'Aux s (n + 1) = convergents'Aux s n :=
  by
  change s.nth n = none at terminated_at_n 
  induction' n with n IH generalizing s
  case zero => simp only [convergents'_aux, terminated_at_n, seq.head]
  case succ =>
    cases' s_head_eq : s.head with gp_head
    case none => simp only [convergents'_aux, s_head_eq]
    case
      some =>
      have : s.tail.terminated_at n := by simp only [seq.terminated_at, s.nth_tail, terminated_at_n]
      simp only [convergents'_aux, s_head_eq, IH this]
#align generalized_continued_fraction.convergents'_aux_stable_step_of_terminated GeneralizedContinuedFraction.convergents'Aux_stable_step_of_terminated
-/

#print GeneralizedContinuedFraction.convergents'Aux_stable_of_terminated /-
theorem convergents'Aux_stable_of_terminated {s : Seq <| Pair K} (n_le_m : n ≤ m)
    (terminated_at_n : s.TerminatedAt n) : convergents'Aux s m = convergents'Aux s n :=
  by
  induction' n_le_m with m n_le_m IH
  · rfl
  · refine' (convergents'_aux_stable_step_of_terminated _).trans IH
    exact s.terminated_stable n_le_m terminated_at_n
#align generalized_continued_fraction.convergents'_aux_stable_of_terminated GeneralizedContinuedFraction.convergents'Aux_stable_of_terminated
-/

#print GeneralizedContinuedFraction.continuants_stable_of_terminated /-
theorem continuants_stable_of_terminated (n_le_m : n ≤ m) (terminated_at_n : g.TerminatedAt n) :
    g.continuants m = g.continuants n := by
  simp only [nth_cont_eq_succ_nth_cont_aux,
    continuants_aux_stable_of_terminated (nat.pred_le_iff.elim_left n_le_m) terminated_at_n]
#align generalized_continued_fraction.continuants_stable_of_terminated GeneralizedContinuedFraction.continuants_stable_of_terminated
-/

#print GeneralizedContinuedFraction.numerators_stable_of_terminated /-
theorem numerators_stable_of_terminated (n_le_m : n ≤ m) (terminated_at_n : g.TerminatedAt n) :
    g.numerators m = g.numerators n := by
  simp only [num_eq_conts_a, continuants_stable_of_terminated n_le_m terminated_at_n]
#align generalized_continued_fraction.numerators_stable_of_terminated GeneralizedContinuedFraction.numerators_stable_of_terminated
-/

#print GeneralizedContinuedFraction.denominators_stable_of_terminated /-
theorem denominators_stable_of_terminated (n_le_m : n ≤ m) (terminated_at_n : g.TerminatedAt n) :
    g.denominators m = g.denominators n := by
  simp only [denom_eq_conts_b, continuants_stable_of_terminated n_le_m terminated_at_n]
#align generalized_continued_fraction.denominators_stable_of_terminated GeneralizedContinuedFraction.denominators_stable_of_terminated
-/

#print GeneralizedContinuedFraction.convergents_stable_of_terminated /-
theorem convergents_stable_of_terminated (n_le_m : n ≤ m) (terminated_at_n : g.TerminatedAt n) :
    g.convergents m = g.convergents n := by
  simp only [convergents, denominators_stable_of_terminated n_le_m terminated_at_n,
    numerators_stable_of_terminated n_le_m terminated_at_n]
#align generalized_continued_fraction.convergents_stable_of_terminated GeneralizedContinuedFraction.convergents_stable_of_terminated
-/

#print GeneralizedContinuedFraction.convergents'_stable_of_terminated /-
theorem convergents'_stable_of_terminated (n_le_m : n ≤ m) (terminated_at_n : g.TerminatedAt n) :
    g.convergents' m = g.convergents' n := by
  simp only [convergents', convergents'_aux_stable_of_terminated n_le_m terminated_at_n]
#align generalized_continued_fraction.convergents'_stable_of_terminated GeneralizedContinuedFraction.convergents'_stable_of_terminated
-/

end GeneralizedContinuedFraction

