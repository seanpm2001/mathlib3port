/-
Copyright (c) 2022 Violeta Hernández Palacios. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Violeta Hernández Palacios

! This file was ported from Lean 3 source module imo.imo2006_q5
! leanprover-community/mathlib commit 308826471968962c6b59c7ff82a22757386603e3
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.RingDivision
import Mathbin.Dynamics.PeriodicPts

/-!
# IMO 2006 Q5

Let $P(x)$ be a polynomial of degree $n>1$ with integer coefficients, and let $k$ be a positive
integer. Consider the polynomial $Q(x) = P(P(\ldots P(P(x))\ldots))$, where $P$ occurs $k$ times.
Prove that there are at most $n$ integers $t$ such that $Q(t)=t$.

## Sketch of solution

The following solution is adapted from
https://artofproblemsolving.com/wiki/index.php/2006_IMO_Problems/Problem_5.

Let $P^k$ denote the polynomial $P$ composed with itself $k$ times. We rely on a key observation: if
$P^k(t)=t$, then $P(P(t))=t$. We prove this by building the cyclic list
$(P(t)-t,P^2(t)-P(t),\ldots)$, and showing that each entry divides the next, which by transitivity
implies they all divide each other, and thus have the same absolute value.

If the entries in this list are all pairwise equal, then we can show inductively that for positive
$n$, $P^n(t)-t$ must always have the same sign as $P(t)-t$. Substituting $n=k$ gives us $P(t)=t$ and
in particular $P(P(t))=t$.

Otherwise, there must be two consecutive entries that are opposites of one another. This means
$P^{n+2}(t)-P^{n+1}(t)=P^n(t)-P^{n+1}(t)$, which implies $P^{n+2}(t)=P^n(t)$ and $P(P(t))=t$.

With this lemma, we can reduce the problem to the case $k=2$. If every root of $P(P(t))-t$ is also a
root of $P(t)-t$, then we're done. Otherwise, there exist $a$ and $b$ with $a\ne b$ and $P(a)=b$,
$P(b)=a$. For any root $t$ of $P(P(t))-t$, defining $u=P(t)$, we easily verify $a-t\mid b-u$,
$b-u\mid a-t$, $a-u\mid b-t$, $b-t\mid a-u$, which imply $|a-t|=|b-u|$ and $|a-u|=|b-t|$. By casing
on these equalities, we deduce $a+b=t+u$. This means that every root of $P(P(t))-t$ is a root of
$P(t)+t-a-b$, and we're again done.
-/


open Function Polynomial

namespace imo2006_q5

/-- If every entry in a cyclic list of integers divides the next, then they all have the same
absolute value. -/
theorem Int.natAbs_eq_of_chain_dvd {l : Cycle ℤ} {x y : ℤ} (hl : l.Chain (· ∣ ·)) (hx : x ∈ l)
    (hy : y ∈ l) : x.natAbs = y.natAbs :=
  by
  rw [Cycle.chain_iff_pairwise] at hl 
  exact Int.natAbs_eq_of_dvd_dvd (hl x hx y hy) (hl y hy x hx)
#align imo2006_q5.int.nat_abs_eq_of_chain_dvd Imo2006Q5.Int.natAbs_eq_of_chain_dvd

theorem Int.add_eq_add_of_natAbs_eq_of_natAbs_eq {a b c d : ℤ} (hne : a ≠ b)
    (h₁ : (c - a).natAbs = (d - b).natAbs) (h₂ : (c - b).natAbs = (d - a).natAbs) : a + b = c + d :=
  by
  cases' Int.natAbs_eq_natAbs_iff.1 h₁ with h₁ h₁
  · cases' Int.natAbs_eq_natAbs_iff.1 h₂ with h₂ h₂
    · exact (hne <| by linarith).elim
    · linarith
  · linarith
#align imo2006_q5.int.add_eq_add_of_nat_abs_eq_of_nat_abs_eq Imo2006Q5.Int.add_eq_add_of_natAbs_eq_of_natAbs_eq

/-- The main lemma in the proof: if $P^k(t)=t$, then $P(P(t))=t$. -/
theorem Polynomial.isPeriodicPt_eval_two {P : Polynomial ℤ} {t : ℤ}
    (ht : t ∈ periodicPts fun x => P.eval x) : IsPeriodicPt (fun x => P.eval x) 2 t :=
  by
  -- The cycle [P(t) - t, P(P(t)) - P(t), ...]
  let C : Cycle ℤ := (periodic_orbit (fun x => P.eval x) t).map fun x => P.eval x - x
  have HC : ∀ {n : ℕ}, ((fun x => P.eval x)^[n + 1]) t - ((fun x => P.eval x)^[n]) t ∈ C :=
    by
    intro n
    rw [Cycle.mem_map, Function.iterate_succ_apply']
    exact ⟨_, iterate_mem_periodic_orbit ht n, rfl⟩
  -- Elements in C are all divisible by one another.
  have Hdvd : C.chain (· ∣ ·) :=
    by
    rw [Cycle.chain_map, periodic_orbit_chain' _ ht]
    intro n
    convert sub_dvd_eval_sub (((fun x => P.eval x)^[n + 1]) t) (((fun x => P.eval x)^[n]) t) P <;>
      rw [Function.iterate_succ_apply']
  -- Any two entries in C have the same absolute value.
  have Habs :
    ∀ m n : ℕ,
      (((fun x => P.eval x)^[m + 1]) t - ((fun x => P.eval x)^[m]) t).natAbs =
        (((fun x => P.eval x)^[n + 1]) t - ((fun x => P.eval x)^[n]) t).natAbs :=
    fun m n => int.nat_abs_eq_of_chain_dvd Hdvd HC HC
  -- We case on whether the elements on C are pairwise equal.
  by_cases HC' : C.chain (· = ·)
  · -- Any two entries in C are equal.
    have Heq :
      ∀ m n : ℕ,
        ((fun x => P.eval x)^[m + 1]) t - ((fun x => P.eval x)^[m]) t =
          ((fun x => P.eval x)^[n + 1]) t - ((fun x => P.eval x)^[n]) t :=
      fun m n => Cycle.chain_iff_pairwise.1 HC' _ HC _ HC
    -- The sign of P^n(t) - t is the same as P(t) - t for positive n. Proven by induction on n.
    have IH : ∀ n : ℕ, (((fun x => P.eval x)^[n + 1]) t - t).sign = (P.eval t - t).sign :=
      by
      intro n
      induction' n with n IH
      · rfl
      · apply Eq.trans _ (Int.sign_add_eq_of_sign_eq IH)
        have H := Heq n.succ 0
        dsimp at H ⊢
        rw [← H, sub_add_sub_cancel']
    -- This implies that the sign of P(t) - t is the same as the sign of P^k(t) - t, which is 0.
    -- Hence P(t) = t and P(P(t)) = P(t).
    rcases ht with ⟨_ | k, hk, hk'⟩
    · exact (irrefl 0 hk).elim
    · have H := IH k
      rw [hk'.is_fixed_pt.eq, sub_self, Int.sign_zero, eq_comm, Int.sign_eq_zero_iff_zero,
        sub_eq_zero] at H 
      simp [is_periodic_pt, is_fixed_pt, H]
  · -- We take two nonequal consecutive entries.
    rw [Cycle.chain_map, periodic_orbit_chain' _ ht] at HC' 
    push_neg at HC' 
    cases' HC' with n hn
    -- They must have opposite sign, so that P^{k + 1}(t) - P^k(t) = P^{k + 2}(t) - P^{k + 1}(t).
    cases' Int.natAbs_eq_natAbs_iff.1 (Habs n n.succ) with hn' hn'
    · apply (hn _).elim
      convert hn' <;> simp only [Function.iterate_succ_apply']
    -- We deduce P^{k + 2}(t) = P^k(t) and hence P(P(t)) = t.
    · rw [neg_sub, sub_right_inj] at hn' 
      simp only [Function.iterate_succ_apply'] at hn' 
      exact @is_periodic_pt_of_mem_periodic_pts_of_is_periodic_pt_iterate _ _ t 2 n ht hn'.symm
#align imo2006_q5.polynomial.is_periodic_pt_eval_two Imo2006Q5.Polynomial.isPeriodicPt_eval_two

theorem Polynomial.iterate_comp_sub_x_ne {P : Polynomial ℤ} (hP : 1 < P.natDegree) {k : ℕ}
    (hk : 0 < k) : (P.comp^[k]) X - X ≠ 0 := by rw [sub_ne_zero]; apply_fun nat_degree;
  simpa using (one_lt_pow hP hk.ne').ne'
#align imo2006_q5.polynomial.iterate_comp_sub_X_ne Imo2006Q5.Polynomial.iterate_comp_sub_x_ne

/-- We solve the problem for the specific case k = 2 first. -/
theorem imo2006_q5' {P : Polynomial ℤ} (hP : 1 < P.natDegree) :
    (P.comp P - X).roots.toFinset.card ≤ P.natDegree :=
  by
  -- Auxiliary lemmas on degrees.
  have hPX : (P - X).natDegree = P.nat_degree :=
    by
    rw [nat_degree_sub_eq_left_of_nat_degree_lt]
    simpa using hP
  have hPX' : P - X ≠ 0 := by
    intro h
    rw [h, nat_degree_zero] at hPX 
    rw [← hPX] at hP 
    exact (zero_le_one.not_lt hP).elim
  -- If every root of P(P(t)) - t is also a root of P(t) - t, then we're done.
  by_cases H : (P.comp P - X).roots.toFinset ⊆ (P - X).roots.toFinset
  ·
    exact
      (Finset.card_le_of_subset H).trans
        ((Multiset.toFinset_card_le _).trans ((card_roots' _).trans_eq hPX))
  -- Otherwise, take a, b with P(a) = b, P(b) = a, a ≠ b.
  · rcases Finset.not_subset.1 H with ⟨a, ha, hab⟩
    replace ha := is_root_of_mem_roots (Multiset.mem_toFinset.1 ha)
    simp [sub_eq_zero] at ha 
    simp [mem_roots hPX'] at hab 
    set b := P.eval a
    rw [sub_eq_zero] at hab 
    -- More auxiliary lemmas on degrees.
    have hPab : (P + X - a - b).natDegree = P.nat_degree :=
      by
      rw [sub_sub, ← Int.cast_add]
      have h₁ : (P + X).natDegree = P.nat_degree :=
        by
        rw [nat_degree_add_eq_left_of_nat_degree_lt]
        simpa using hP
      rw [nat_degree_sub_eq_left_of_nat_degree_lt] <;> rwa [h₁]
      rw [nat_degree_int_cast]
      exact zero_lt_one.trans hP
    have hPab' : P + X - a - b ≠ 0 := by
      intro h
      rw [h, nat_degree_zero] at hPab 
      rw [← hPab] at hP 
      exact (zero_le_one.not_lt hP).elim
    -- We claim that every root of P(P(t)) - t is a root of P(t) + t - a - b. This allows us to
    -- conclude the problem.
    suffices H' : (P.comp P - X).roots.toFinset ⊆ (P + X - a - b).roots.toFinset
    ·
      exact
        (Finset.card_le_of_subset H').trans
          ((Multiset.toFinset_card_le _).trans <| (card_roots' _).trans_eq hPab)
    · -- Let t be a root of P(P(t)) - t, define u = P(t).
      intro t ht
      replace ht := is_root_of_mem_roots (Multiset.mem_toFinset.1 ht)
      simp [sub_eq_zero] at ht 
      simp only [mem_roots hPab', sub_eq_iff_eq_add, Multiset.mem_toFinset, is_root.def, eval_sub,
        eval_add, eval_X, eval_C, eval_int_cast, Int.cast_id, zero_add]
      -- An auxiliary lemma proved earlier implies we only need to show |t - a| = |u - b| and
          -- |t - b| = |u - a|. We prove this by establishing that each side of either equation divides
          -- the other.
          apply (int.add_eq_add_of_nat_abs_eq_of_nat_abs_eq hab _ _).symm <;>
          apply Int.natAbs_eq_of_dvd_dvd <;>
        set u := P.eval t
      · rw [← ha, ← ht]; apply sub_dvd_eval_sub
      · apply sub_dvd_eval_sub
      · rw [← ht]; apply sub_dvd_eval_sub
      · rw [← ha]; apply sub_dvd_eval_sub
#align imo2006_q5.imo2006_q5' Imo2006Q5.imo2006_q5'

end imo2006_q5

open imo2006_q5

/-- The general problem follows easily from the k = 2 case. -/
theorem imo2006_q5 {P : Polynomial ℤ} (hP : 1 < P.natDegree) {k : ℕ} (hk : 0 < k) :
    ((P.comp^[k]) X - X).roots.toFinset.card ≤ P.natDegree :=
  by
  apply (Finset.card_le_of_subset fun t ht => _).trans (imo2006_q5' hP)
  have hP' : P.comp P - X ≠ 0 := by simpa using polynomial.iterate_comp_sub_X_ne hP zero_lt_two
  replace ht := is_root_of_mem_roots (Multiset.mem_toFinset.1 ht)
  simp only [sub_eq_zero, is_root.def, eval_sub, iterate_comp_eval, eval_X] at ht 
  simpa [mem_roots hP', sub_eq_zero] using polynomial.is_periodic_pt_eval_two ⟨k, hk, ht⟩
#align imo2006_q5 imo2006_q5

