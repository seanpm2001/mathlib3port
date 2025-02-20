/-
Copyright (c) 2018 Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Y. Lewis

! This file was ported from Lean 3 source module number_theory.padics.padic_numbers
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.NumberTheory.Padics.PadicNorm
import Mathbin.Analysis.Normed.Field.Basic

/-!
# p-adic numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the `p`-adic numbers (rationals) `ℚ_[p]` as
the completion of `ℚ` with respect to the `p`-adic norm.
We show that the `p`-adic norm on `ℚ` extends to `ℚ_[p]`, that `ℚ` is embedded in `ℚ_[p]`,
and that `ℚ_[p]` is Cauchy complete.

## Important definitions

* `padic` : the type of `p`-adic numbers
* `padic_norm_e` : the rational valued `p`-adic norm on `ℚ_[p]`
* `padic.add_valuation` : the additive `p`-adic valuation on `ℚ_[p]`, with values in `with_top ℤ`

## Notation

We introduce the notation `ℚ_[p]` for the `p`-adic numbers.

## Implementation notes

Much, but not all, of this file assumes that `p` is prime. This assumption is inferred automatically
by taking `[fact p.prime]` as a type class argument.

We use the same concrete Cauchy sequence construction that is used to construct `ℝ`.
`ℚ_[p]` inherits a field structure from this construction.
The extension of the norm on `ℚ` to `ℚ_[p]` is *not* analogous to extending the absolute value to
`ℝ` and hence the proof that `ℚ_[p]` is complete is different from the proof that ℝ is complete.

A small special-purpose simplification tactic, `padic_index_simp`, is used to manipulate sequence
indices in the proof that the norm extends.

`padic_norm_e` is the rational-valued `p`-adic norm on `ℚ_[p]`.
To instantiate `ℚ_[p]` as a normed field, we must cast this into a `ℝ`-valued norm.
The `ℝ`-valued norm, using notation `‖ ‖` from normed spaces,
is the canonical representation of this norm.

`simp` prefers `padic_norm` to `padic_norm_e` when possible.
Since `padic_norm_e` and `‖ ‖` have different types, `simp` does not rewrite one to the other.

Coercions from `ℚ` to `ℚ_[p]` are set up to work with the `norm_cast` tactic.

## References

* [F. Q. Gouvêa, *p-adic numbers*][gouvea1997]
* [R. Y. Lewis, *A formal proof of Hensel's lemma over the p-adic integers*][lewis2019]
* <https://en.wikipedia.org/wiki/P-adic_number>

## Tags

p-adic, p adic, padic, norm, valuation, cauchy, completion, p-adic completion
-/


noncomputable section

open scoped Classical

open Nat multiplicity padicNorm CauSeq CauSeq.Completion Metric

#print PadicSeq /-
/-- The type of Cauchy sequences of rationals with respect to the `p`-adic norm. -/
@[reducible]
def PadicSeq (p : ℕ) :=
  CauSeq _ (padicNorm p)
#align padic_seq PadicSeq
-/

namespace PadicSeq

section

variable {p : ℕ} [Fact p.Prime]

#print PadicSeq.stationary /-
/-- The `p`-adic norm of the entries of a nonzero Cauchy sequence of rationals is eventually
constant. -/
theorem stationary {f : CauSeq ℚ (padicNorm p)} (hf : ¬f ≈ 0) :
    ∃ N, ∀ m n, N ≤ m → N ≤ n → padicNorm p (f n) = padicNorm p (f m) :=
  have : ∃ ε > 0, ∃ N1, ∀ j ≥ N1, ε ≤ padicNorm p (f j) :=
    CauSeq.abv_pos_of_not_limZero <| not_limZero_of_not_congr_zero hf
  let ⟨ε, hε, N1, hN1⟩ := this
  let ⟨N2, hN2⟩ := CauSeq.cauchy₂ f hε
  ⟨max N1 N2, fun n m hn hm =>
    by
    have : padicNorm p (f n - f m) < ε := hN2 _ (max_le_iff.1 hn).2 _ (max_le_iff.1 hm).2
    have : padicNorm p (f n - f m) < padicNorm p (f n) :=
      lt_of_lt_of_le this <| hN1 _ (max_le_iff.1 hn).1
    have : padicNorm p (f n - f m) < max (padicNorm p (f n)) (padicNorm p (f m)) :=
      lt_max_iff.2 (Or.inl this)
    by_contra hne
    rw [← padicNorm.neg (f m)] at hne 
    have hnam := add_eq_max_of_ne hne
    rw [padicNorm.neg, max_comm] at hnam 
    rw [← hnam, sub_eq_add_neg, add_comm] at this 
    apply _root_.lt_irrefl _ this⟩
#align padic_seq.stationary PadicSeq.stationary
-/

#print PadicSeq.stationaryPoint /-
/-- For all `n ≥ stationary_point f hf`, the `p`-adic norm of `f n` is the same. -/
def stationaryPoint {f : PadicSeq p} (hf : ¬f ≈ 0) : ℕ :=
  Classical.choose <| stationary hf
#align padic_seq.stationary_point PadicSeq.stationaryPoint
-/

#print PadicSeq.stationaryPoint_spec /-
theorem stationaryPoint_spec {f : PadicSeq p} (hf : ¬f ≈ 0) :
    ∀ {m n},
      stationaryPoint hf ≤ m → stationaryPoint hf ≤ n → padicNorm p (f n) = padicNorm p (f m) :=
  Classical.choose_spec <| stationary hf
#align padic_seq.stationary_point_spec PadicSeq.stationaryPoint_spec
-/

#print PadicSeq.norm /-
/-- Since the norm of the entries of a Cauchy sequence is eventually stationary,
we can lift the norm to sequences. -/
def norm (f : PadicSeq p) : ℚ :=
  if hf : f ≈ 0 then 0 else padicNorm p (f (stationaryPoint hf))
#align padic_seq.norm PadicSeq.norm
-/

#print PadicSeq.norm_zero_iff /-
theorem norm_zero_iff (f : PadicSeq p) : f.norm = 0 ↔ f ≈ 0 :=
  by
  constructor
  · intro h
    by_contra hf
    unfold norm at h ; split_ifs at h 
    apply hf
    intro ε hε
    exists stationary_point hf
    intro j hj
    have heq := stationary_point_spec hf le_rfl hj
    simpa [h, HEq]
  · intro h
    simp [norm, h]
#align padic_seq.norm_zero_iff PadicSeq.norm_zero_iff
-/

end

section Embedding

open CauSeq

variable {p : ℕ} [Fact p.Prime]

#print PadicSeq.equiv_zero_of_val_eq_of_equiv_zero /-
theorem equiv_zero_of_val_eq_of_equiv_zero {f g : PadicSeq p}
    (h : ∀ k, padicNorm p (f k) = padicNorm p (g k)) (hf : f ≈ 0) : g ≈ 0 := fun ε hε =>
  let ⟨i, hi⟩ := hf _ hε
  ⟨i, fun j hj => by simpa [h] using hi _ hj⟩
#align padic_seq.equiv_zero_of_val_eq_of_equiv_zero PadicSeq.equiv_zero_of_val_eq_of_equiv_zero
-/

#print PadicSeq.norm_nonzero_of_not_equiv_zero /-
theorem norm_nonzero_of_not_equiv_zero {f : PadicSeq p} (hf : ¬f ≈ 0) : f.norm ≠ 0 :=
  hf ∘ f.norm_zero_iff.1
#align padic_seq.norm_nonzero_of_not_equiv_zero PadicSeq.norm_nonzero_of_not_equiv_zero
-/

#print PadicSeq.norm_eq_norm_app_of_nonzero /-
theorem norm_eq_norm_app_of_nonzero {f : PadicSeq p} (hf : ¬f ≈ 0) :
    ∃ k, f.norm = padicNorm p k ∧ k ≠ 0 :=
  have heq : f.norm = padicNorm p (f <| stationaryPoint hf) := by simp [norm, hf]
  ⟨f <| stationaryPoint hf, HEq, fun h =>
    norm_nonzero_of_not_equiv_zero hf (by simpa [h] using HEq)⟩
#align padic_seq.norm_eq_norm_app_of_nonzero PadicSeq.norm_eq_norm_app_of_nonzero
-/

#print PadicSeq.not_limZero_const_of_nonzero /-
theorem not_limZero_const_of_nonzero {q : ℚ} (hq : q ≠ 0) : ¬LimZero (const (padicNorm p) q) :=
  fun h' => hq <| const_limZero.1 h'
#align padic_seq.not_lim_zero_const_of_nonzero PadicSeq.not_limZero_const_of_nonzero
-/

#print PadicSeq.not_equiv_zero_const_of_nonzero /-
theorem not_equiv_zero_const_of_nonzero {q : ℚ} (hq : q ≠ 0) : ¬const (padicNorm p) q ≈ 0 :=
  fun h : LimZero (const (padicNorm p) q - 0) => not_limZero_const_of_nonzero hq <| by simpa using h
#align padic_seq.not_equiv_zero_const_of_nonzero PadicSeq.not_equiv_zero_const_of_nonzero
-/

#print PadicSeq.norm_nonneg /-
theorem norm_nonneg (f : PadicSeq p) : 0 ≤ f.norm :=
  if hf : f ≈ 0 then by simp [hf, norm] else by simp [norm, hf, padicNorm.nonneg]
#align padic_seq.norm_nonneg PadicSeq.norm_nonneg
-/

#print PadicSeq.lift_index_left_left /-
/-- An auxiliary lemma for manipulating sequence indices. -/
theorem lift_index_left_left {f : PadicSeq p} (hf : ¬f ≈ 0) (v2 v3 : ℕ) :
    padicNorm p (f (stationaryPoint hf)) = padicNorm p (f (max (stationaryPoint hf) (max v2 v3))) :=
  by
  apply stationary_point_spec hf
  · apply le_max_left
  · exact le_rfl
#align padic_seq.lift_index_left_left PadicSeq.lift_index_left_left
-/

#print PadicSeq.lift_index_left /-
/-- An auxiliary lemma for manipulating sequence indices. -/
theorem lift_index_left {f : PadicSeq p} (hf : ¬f ≈ 0) (v1 v3 : ℕ) :
    padicNorm p (f (stationaryPoint hf)) = padicNorm p (f (max v1 (max (stationaryPoint hf) v3))) :=
  by
  apply stationary_point_spec hf
  · apply le_trans
    · apply le_max_left _ v3
    · apply le_max_right
  · exact le_rfl
#align padic_seq.lift_index_left PadicSeq.lift_index_left
-/

#print PadicSeq.lift_index_right /-
/-- An auxiliary lemma for manipulating sequence indices. -/
theorem lift_index_right {f : PadicSeq p} (hf : ¬f ≈ 0) (v1 v2 : ℕ) :
    padicNorm p (f (stationaryPoint hf)) = padicNorm p (f (max v1 (max v2 (stationaryPoint hf)))) :=
  by
  apply stationary_point_spec hf
  · apply le_trans
    · apply le_max_right v2
    · apply le_max_right
  · exact le_rfl
#align padic_seq.lift_index_right PadicSeq.lift_index_right
-/

end Embedding

section Valuation

open CauSeq

variable {p : ℕ} [Fact p.Prime]

/-! ### Valuation on `padic_seq` -/


#print PadicSeq.valuation /-
/-- The `p`-adic valuation on `ℚ` lifts to `padic_seq p`.
`valuation f` is defined to be the valuation of the (`ℚ`-valued) stationary point of `f`. -/
def valuation (f : PadicSeq p) : ℤ :=
  if hf : f ≈ 0 then 0 else padicValRat p (f (stationaryPoint hf))
#align padic_seq.valuation PadicSeq.valuation
-/

#print PadicSeq.norm_eq_pow_val /-
theorem norm_eq_pow_val {f : PadicSeq p} (hf : ¬f ≈ 0) : f.norm = p ^ (-f.Valuation : ℤ) :=
  by
  rw [norm, Valuation, dif_neg hf, dif_neg hf, padicNorm, if_neg]
  intro H
  apply CauSeq.not_limZero_of_not_congr_zero hf
  intro ε hε
  use stationary_point hf
  intro n hn
  rw [stationary_point_spec hf le_rfl hn]
  simpa [H] using hε
#align padic_seq.norm_eq_pow_val PadicSeq.norm_eq_pow_val
-/

#print PadicSeq.val_eq_iff_norm_eq /-
theorem val_eq_iff_norm_eq {f g : PadicSeq p} (hf : ¬f ≈ 0) (hg : ¬g ≈ 0) :
    f.Valuation = g.Valuation ↔ f.norm = g.norm :=
  by
  rw [norm_eq_pow_val hf, norm_eq_pow_val hg, ← neg_inj, zpow_inj]
  · exact_mod_cast (Fact.out p.prime).Pos
  · exact_mod_cast (Fact.out p.prime).ne_one
#align padic_seq.val_eq_iff_norm_eq PadicSeq.val_eq_iff_norm_eq
-/

end Valuation

end PadicSeq

section

open PadicSeq

private unsafe def index_simp_core (hh hf hg : expr)
    (at_ : Interactive.Loc := Interactive.Loc.ns [none]) : tactic Unit := do
  let [v1, v2, v3] ← [hh, hf, hg].mapM fun n => tactic.mk_app `` stationary_point [n] <|> return n
  let e1 ← tactic.mk_app `` lift_index_left_left [hh, v2, v3] <|> return q(True)
  let e2 ← tactic.mk_app `` lift_index_left [hf, v1, v3] <|> return q(True)
  let e3 ← tactic.mk_app `` lift_index_right [hg, v1, v2] <|> return q(True)
  let sl ← [e1, e2, e3].foldlM (fun s e => simp_lemmas.add s e) simp_lemmas.mk
  when at_ (tactic.simp_target sl >> tactic.skip)
  let hs ← at_.get_locals
  hs (tactic.simp_hyp sl [])

/-- This is a special-purpose tactic that lifts `padic_norm (f (stationary_point f))` to
`padic_norm (f (max _ _ _))`. -/
unsafe def tactic.interactive.padic_index_simp (l : interactive.parse interactive.types.pexpr_list)
    (at_ : interactive.parse interactive.types.location) : tactic Unit := do
  let [h, f, g] ← l.mapM tactic.i_to_expr
  index_simp_core h f g at_
#align tactic.interactive.padic_index_simp tactic.interactive.padic_index_simp

end

namespace PadicSeq

section Embedding

open CauSeq

variable {p : ℕ} [hp : Fact p.Prime]

#print PadicSeq.norm_mul /-
theorem norm_mul (f g : PadicSeq p) : (f * g).norm = f.norm * g.norm :=
  if hf : f ≈ 0 then by
    have hg : f * g ≈ 0 := mul_equiv_zero' _ hf
    simp only [hf, hg, norm, dif_pos, MulZeroClass.zero_mul]
  else
    if hg : g ≈ 0 then by
      have hf : f * g ≈ 0 := mul_equiv_zero _ hg
      simp only [hf, hg, norm, dif_pos, MulZeroClass.mul_zero]
    else by
      have hfg : ¬f * g ≈ 0 := by apply mul_not_equiv_zero <;> assumption
      unfold norm
      split_ifs
      padic_index_simp [hfg, hf, hg]
      apply padicNorm.mul
#align padic_seq.norm_mul PadicSeq.norm_mul
-/

#print PadicSeq.eq_zero_iff_equiv_zero /-
theorem eq_zero_iff_equiv_zero (f : PadicSeq p) : mk f = 0 ↔ f ≈ 0 :=
  mk_eq
#align padic_seq.eq_zero_iff_equiv_zero PadicSeq.eq_zero_iff_equiv_zero
-/

#print PadicSeq.ne_zero_iff_nequiv_zero /-
theorem ne_zero_iff_nequiv_zero (f : PadicSeq p) : mk f ≠ 0 ↔ ¬f ≈ 0 :=
  not_iff_not.2 (eq_zero_iff_equiv_zero _)
#align padic_seq.ne_zero_iff_nequiv_zero PadicSeq.ne_zero_iff_nequiv_zero
-/

#print PadicSeq.norm_const /-
theorem norm_const (q : ℚ) : norm (const (padicNorm p) q) = padicNorm p q :=
  if hq : q = 0 then
    by
    have : const (padicNorm p) q ≈ 0 := by simp [hq] <;> apply Setoid.refl (const (padicNorm p) 0)
    subst hq <;> simp [norm, this]
  else by
    have : ¬const (padicNorm p) q ≈ 0 := not_equiv_zero_const_of_nonzero hq
    simp [norm, this]
#align padic_seq.norm_const PadicSeq.norm_const
-/

#print PadicSeq.norm_values_discrete /-
theorem norm_values_discrete (a : PadicSeq p) (ha : ¬a ≈ 0) : ∃ z : ℤ, a.norm = p ^ (-z) :=
  by
  let ⟨k, hk, hk'⟩ := norm_eq_norm_app_of_nonzero ha
  simpa [hk] using padicNorm.values_discrete hk'
#align padic_seq.norm_values_discrete PadicSeq.norm_values_discrete
-/

#print PadicSeq.norm_one /-
theorem norm_one : norm (1 : PadicSeq p) = 1 :=
  by
  have h1 : ¬(1 : PadicSeq p) ≈ 0 := one_not_equiv_zero _
  simp [h1, norm, hp.1.one_lt]
#align padic_seq.norm_one PadicSeq.norm_one
-/

private theorem norm_eq_of_equiv_aux {f g : PadicSeq p} (hf : ¬f ≈ 0) (hg : ¬g ≈ 0) (hfg : f ≈ g)
    (h : padicNorm p (f (stationaryPoint hf)) ≠ padicNorm p (g (stationaryPoint hg)))
    (hlt : padicNorm p (g (stationaryPoint hg)) < padicNorm p (f (stationaryPoint hf))) : False :=
  by
  have hpn : 0 < padicNorm p (f (stationary_point hf)) - padicNorm p (g (stationary_point hg)) :=
    sub_pos_of_lt hlt
  cases' hfg _ hpn with N hN
  let i := max N (max (stationary_point hf) (stationary_point hg))
  have hi : N ≤ i := le_max_left _ _
  have hN' := hN _ hi
  padic_index_simp [N, hf, hg] at hN' h hlt 
  have hpne : padicNorm p (f i) ≠ padicNorm p (-g i) := by rwa [← padicNorm.neg (g i)] at h 
  let hpnem := add_eq_max_of_ne hpne
  have hpeq : padicNorm p ((f - g) i) = max (padicNorm p (f i)) (padicNorm p (g i)) := by
    rwa [padicNorm.neg] at hpnem 
  rw [hpeq, max_eq_left_of_lt hlt] at hN' 
  have : padicNorm p (f i) < padicNorm p (f i) := by apply lt_of_lt_of_le hN'; apply sub_le_self;
    apply padicNorm.nonneg
  exact lt_irrefl _ this

private theorem norm_eq_of_equiv {f g : PadicSeq p} (hf : ¬f ≈ 0) (hg : ¬g ≈ 0) (hfg : f ≈ g) :
    padicNorm p (f (stationaryPoint hf)) = padicNorm p (g (stationaryPoint hg)) :=
  by
  by_contra h
  cases'
    Decidable.em
      (padicNorm p (g (stationary_point hg)) < padicNorm p (f (stationary_point hf))) with
    hlt hnlt
  · exact norm_eq_of_equiv_aux hf hg hfg h hlt
  · apply norm_eq_of_equiv_aux hg hf (Setoid.symm hfg) (Ne.symm h)
    apply lt_of_le_of_ne
    apply le_of_not_gt hnlt
    apply h

#print PadicSeq.norm_equiv /-
theorem norm_equiv {f g : PadicSeq p} (hfg : f ≈ g) : f.norm = g.norm :=
  if hf : f ≈ 0 then by
    have hg : g ≈ 0 := Setoid.trans (Setoid.symm hfg) hf
    simp [norm, hf, hg]
  else by
    have hg : ¬g ≈ 0 := hf ∘ Setoid.trans hfg
    unfold norm <;> split_ifs <;> exact norm_eq_of_equiv hf hg hfg
#align padic_seq.norm_equiv PadicSeq.norm_equiv
-/

private theorem norm_nonarchimedean_aux {f g : PadicSeq p} (hfg : ¬f + g ≈ 0) (hf : ¬f ≈ 0)
    (hg : ¬g ≈ 0) : (f + g).norm ≤ max f.norm g.norm :=
  by
  unfold norm; split_ifs
  padic_index_simp [hfg, hf, hg]
  apply padicNorm.nonarchimedean

#print PadicSeq.norm_nonarchimedean /-
theorem norm_nonarchimedean (f g : PadicSeq p) : (f + g).norm ≤ max f.norm g.norm :=
  if hfg : f + g ≈ 0 then
    by
    have : 0 ≤ max f.norm g.norm := le_max_of_le_left (norm_nonneg _)
    simpa only [hfg, norm, Ne.def, le_max_iff, CauSeq.add_apply, not_true, dif_pos]
  else
    if hf : f ≈ 0 then
      by
      have hfg' : f + g ≈ g := by
        change lim_zero (f - 0) at hf 
        show lim_zero (f + g - g); · simpa only [sub_zero, add_sub_cancel] using hf
      have hcfg : (f + g).norm = g.norm := norm_equiv hfg'
      have hcl : f.norm = 0 := (norm_zero_iff f).2 hf
      have : max f.norm g.norm = g.norm := by rw [hcl] <;> exact max_eq_right (norm_nonneg _)
      rw [this, hcfg]
    else
      if hg : g ≈ 0 then
        by
        have hfg' : f + g ≈ f := by
          change lim_zero (g - 0) at hg 
          show lim_zero (f + g - f); · simpa only [add_sub_cancel', sub_zero] using hg
        have hcfg : (f + g).norm = f.norm := norm_equiv hfg'
        have hcl : g.norm = 0 := (norm_zero_iff g).2 hg
        have : max f.norm g.norm = f.norm := by rw [hcl] <;> exact max_eq_left (norm_nonneg _)
        rw [this, hcfg]
      else norm_nonarchimedean_aux hfg hf hg
#align padic_seq.norm_nonarchimedean PadicSeq.norm_nonarchimedean
-/

#print PadicSeq.norm_eq /-
theorem norm_eq {f g : PadicSeq p} (h : ∀ k, padicNorm p (f k) = padicNorm p (g k)) :
    f.norm = g.norm :=
  if hf : f ≈ 0 then by
    have hg : g ≈ 0 := equiv_zero_of_val_eq_of_equiv_zero h hf
    simp only [hf, hg, norm, dif_pos]
  else
    by
    have hg : ¬g ≈ 0 := fun hg =>
      hf <| equiv_zero_of_val_eq_of_equiv_zero (by simp only [h, forall_const, eq_self_iff_true]) hg
    simp only [hg, hf, norm, dif_neg, not_false_iff]
    let i := max (stationary_point hf) (stationary_point hg)
    have hpf : padicNorm p (f (stationary_point hf)) = padicNorm p (f i) := by
      apply stationary_point_spec; apply le_max_left; exact le_rfl
    have hpg : padicNorm p (g (stationary_point hg)) = padicNorm p (g i) := by
      apply stationary_point_spec; apply le_max_right; exact le_rfl
    rw [hpf, hpg, h]
#align padic_seq.norm_eq PadicSeq.norm_eq
-/

#print PadicSeq.norm_neg /-
theorem norm_neg (a : PadicSeq p) : (-a).norm = a.norm :=
  norm_eq <| by simp
#align padic_seq.norm_neg PadicSeq.norm_neg
-/

#print PadicSeq.norm_eq_of_add_equiv_zero /-
theorem norm_eq_of_add_equiv_zero {f g : PadicSeq p} (h : f + g ≈ 0) : f.norm = g.norm :=
  by
  have : LimZero (f + g - 0) := h
  have : f ≈ -g := show LimZero (f - -g) by simpa only [sub_zero, sub_neg_eq_add]
  have : f.norm = (-g).norm := norm_equiv this
  simpa only [norm_neg] using this
#align padic_seq.norm_eq_of_add_equiv_zero PadicSeq.norm_eq_of_add_equiv_zero
-/

#print PadicSeq.add_eq_max_of_ne /-
theorem add_eq_max_of_ne {f g : PadicSeq p} (hfgne : f.norm ≠ g.norm) :
    (f + g).norm = max f.norm g.norm :=
  have hfg : ¬f + g ≈ 0 := mt norm_eq_of_add_equiv_zero hfgne
  if hf : f ≈ 0 then by
    have : LimZero (f - 0) := hf
    have : f + g ≈ g := show LimZero (f + g - g) by simpa only [sub_zero, add_sub_cancel]
    have h1 : (f + g).norm = g.norm := norm_equiv this
    have h2 : f.norm = 0 := (norm_zero_iff _).2 hf
    rw [h1, h2] <;> rw [max_eq_right (norm_nonneg _)]
  else
    if hg : g ≈ 0 then by
      have : LimZero (g - 0) := hg
      have : f + g ≈ f := show LimZero (f + g - f) by rw [add_sub_cancel'] <;> simpa only [sub_zero]
      have h1 : (f + g).norm = f.norm := norm_equiv this
      have h2 : g.norm = 0 := (norm_zero_iff _).2 hg
      rw [h1, h2] <;> rw [max_eq_left (norm_nonneg _)]
    else by
      unfold norm at hfgne ⊢; split_ifs at hfgne ⊢
      padic_index_simp [hfg, hf, hg] at hfgne ⊢
      exact padicNorm.add_eq_max_of_ne hfgne
#align padic_seq.add_eq_max_of_ne PadicSeq.add_eq_max_of_ne
-/

end Embedding

end PadicSeq

#print Padic /-
/-- The `p`-adic numbers `ℚ_[p]` are the Cauchy completion of `ℚ` with respect to the `p`-adic norm.
-/
def Padic (p : ℕ) [Fact p.Prime] :=
  @CauSeq.Completion.Cauchy _ _ _ _ (padicNorm p) _
#align padic Padic
-/

notation "ℚ_[" p "]" => Padic p

namespace Padic

section Completion

variable {p : ℕ} [Fact p.Prime]

instance : Field ℚ_[p] :=
  Cauchy.field

instance : Inhabited ℚ_[p] :=
  ⟨0⟩

-- short circuits
instance : CommRing ℚ_[p] :=
  Cauchy.commRing

instance : Ring ℚ_[p] :=
  Cauchy.ring

instance : Zero ℚ_[p] := by infer_instance

instance : One ℚ_[p] := by infer_instance

instance : Add ℚ_[p] := by infer_instance

instance : Mul ℚ_[p] := by infer_instance

instance : Sub ℚ_[p] := by infer_instance

instance : Neg ℚ_[p] := by infer_instance

instance : Div ℚ_[p] := by infer_instance

instance : AddCommGroup ℚ_[p] := by infer_instance

#print Padic.mk /-
/-- Builds the equivalence class of a Cauchy sequence of rationals. -/
def mk : PadicSeq p → ℚ_[p] :=
  Quotient.mk'
#align padic.mk Padic.mk
-/

variable (p)

#print Padic.zero_def /-
theorem zero_def : (0 : ℚ_[p]) = ⟦0⟧ :=
  rfl
#align padic.zero_def Padic.zero_def
-/

#print Padic.mk_eq /-
theorem mk_eq {f g : PadicSeq p} : mk f = mk g ↔ f ≈ g :=
  Quotient.eq'
#align padic.mk_eq Padic.mk_eq
-/

#print Padic.const_equiv /-
theorem const_equiv {q r : ℚ} : const (padicNorm p) q ≈ const (padicNorm p) r ↔ q = r :=
  ⟨fun heq => eq_of_sub_eq_zero <| const_limZero.1 HEq, fun heq => by
    rw [HEq] <;> apply Setoid.refl _⟩
#align padic.const_equiv Padic.const_equiv
-/

#print Padic.coe_inj /-
@[norm_cast]
theorem coe_inj {q r : ℚ} : (↑q : ℚ_[p]) = ↑r ↔ q = r :=
  ⟨(const_equiv p).1 ∘ Quotient.eq'.1, fun h => by rw [h]⟩
#align padic.coe_inj Padic.coe_inj
-/

instance : CharZero ℚ_[p] :=
  ⟨fun m n => by rw [← Rat.cast_coe_nat]; norm_cast; exact id⟩

#print Padic.coe_add /-
@[norm_cast]
theorem coe_add : ∀ {x y : ℚ}, (↑(x + y) : ℚ_[p]) = ↑x + ↑y :=
  Rat.cast_add
#align padic.coe_add Padic.coe_add
-/

#print Padic.coe_neg /-
@[norm_cast]
theorem coe_neg : ∀ {x : ℚ}, (↑(-x) : ℚ_[p]) = -↑x :=
  Rat.cast_neg
#align padic.coe_neg Padic.coe_neg
-/

#print Padic.coe_mul /-
@[norm_cast]
theorem coe_mul : ∀ {x y : ℚ}, (↑(x * y) : ℚ_[p]) = ↑x * ↑y :=
  Rat.cast_mul
#align padic.coe_mul Padic.coe_mul
-/

#print Padic.coe_sub /-
@[norm_cast]
theorem coe_sub : ∀ {x y : ℚ}, (↑(x - y) : ℚ_[p]) = ↑x - ↑y :=
  Rat.cast_sub
#align padic.coe_sub Padic.coe_sub
-/

#print Padic.coe_div /-
@[norm_cast]
theorem coe_div : ∀ {x y : ℚ}, (↑(x / y) : ℚ_[p]) = ↑x / ↑y :=
  Rat.cast_div
#align padic.coe_div Padic.coe_div
-/

#print Padic.coe_one /-
@[norm_cast]
theorem coe_one : (↑1 : ℚ_[p]) = 1 :=
  rfl
#align padic.coe_one Padic.coe_one
-/

#print Padic.coe_zero /-
@[norm_cast]
theorem coe_zero : (↑0 : ℚ_[p]) = 0 :=
  rfl
#align padic.coe_zero Padic.coe_zero
-/

end Completion

end Padic

#print padicNormE /-
/-- The rational-valued `p`-adic norm on `ℚ_[p]` is lifted from the norm on Cauchy sequences. The
canonical form of this function is the normed space instance, with notation `‖ ‖`. -/
def padicNormE {p : ℕ} [hp : Fact p.Prime] : AbsoluteValue ℚ_[p] ℚ
    where
  toFun := Quotient.lift PadicSeq.norm <| @PadicSeq.norm_equiv _ _
  map_mul' q r := Quotient.induction_on₂ q r <| PadicSeq.norm_mul
  nonneg' q := Quotient.inductionOn q <| PadicSeq.norm_nonneg
  eq_zero' q :=
    Quotient.inductionOn q <| by
      simpa only [Padic.zero_def, Quotient.eq'] using PadicSeq.norm_zero_iff
  add_le' q r :=
    by
    trans
      max ((Quotient.lift PadicSeq.norm <| @PadicSeq.norm_equiv _ _) q)
        ((Quotient.lift PadicSeq.norm <| @PadicSeq.norm_equiv _ _) r)
    exact Quotient.induction_on₂ q r <| PadicSeq.norm_nonarchimedean
    refine' max_le_add_of_nonneg (Quotient.inductionOn q <| PadicSeq.norm_nonneg) _
    exact Quotient.inductionOn r <| PadicSeq.norm_nonneg
#align padic_norm_e padicNormE
-/

namespace padicNormE

section Embedding

open PadicSeq

variable {p : ℕ} [Fact p.Prime]

#print padicNormE.defn /-
theorem defn (f : PadicSeq p) {ε : ℚ} (hε : 0 < ε) : ∃ N, ∀ i ≥ N, padicNormE (⟦f⟧ - f i) < ε :=
  by
  dsimp [padicNormE]
  change ∃ N, ∀ i ≥ N, (f - const _ (f i)).norm < ε
  by_contra' h
  cases' cauchy₂ f hε with N hN
  rcases h N with ⟨i, hi, hge⟩
  have hne : ¬f - const (padicNorm p) (f i) ≈ 0 := by intro h;
    unfold PadicSeq.norm at hge  <;> split_ifs at hge ; exact not_lt_of_ge hge hε
  unfold PadicSeq.norm at hge  <;> split_ifs at hge 
  apply not_le_of_gt _ hge
  cases' em (N ≤ stationary_point hne) with hgen hngen
  · apply hN _ hgen _ hi
  · have := stationary_point_spec hne le_rfl (le_of_not_le hngen)
    rw [← this]
    exact hN _ le_rfl _ hi
#align padic_norm_e.defn padicNormE.defn
-/

#print padicNormE.nonarchimedean' /-
/-- Theorems about `padic_norm_e` are named with a `'` so the names do not conflict with the
equivalent theorems about `norm` (`‖ ‖`). -/
theorem nonarchimedean' (q r : ℚ_[p]) : padicNormE (q + r) ≤ max (padicNormE q) (padicNormE r) :=
  Quotient.induction_on₂ q r <| norm_nonarchimedean
#align padic_norm_e.nonarchimedean' padicNormE.nonarchimedean'
-/

#print padicNormE.add_eq_max_of_ne' /-
/-- Theorems about `padic_norm_e` are named with a `'` so the names do not conflict with the
equivalent theorems about `norm` (`‖ ‖`). -/
theorem add_eq_max_of_ne' {q r : ℚ_[p]} :
    padicNormE q ≠ padicNormE r → padicNormE (q + r) = max (padicNormE q) (padicNormE r) :=
  Quotient.induction_on₂ q r fun _ _ => PadicSeq.add_eq_max_of_ne
#align padic_norm_e.add_eq_max_of_ne' padicNormE.add_eq_max_of_ne'
-/

#print padicNormE.eq_padic_norm' /-
@[simp]
theorem eq_padic_norm' (q : ℚ) : padicNormE (q : ℚ_[p]) = padicNorm p q :=
  norm_const _
#align padic_norm_e.eq_padic_norm' padicNormE.eq_padic_norm'
-/

#print padicNormE.image' /-
protected theorem image' {q : ℚ_[p]} : q ≠ 0 → ∃ n : ℤ, padicNormE q = p ^ (-n) :=
  Quotient.inductionOn q fun f hf =>
    have : ¬f ≈ 0 := (ne_zero_iff_nequiv_zero f).1 hf
    norm_values_discrete f this
#align padic_norm_e.image' padicNormE.image'
-/

end Embedding

end padicNormE

namespace Padic

section Complete

open PadicSeq Padic

variable {p : ℕ} [Fact p.Prime] (f : CauSeq _ (@padicNormE p _))

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (m n «expr ≥ » N) -/
#print Padic.rat_dense' /-
theorem rat_dense' (q : ℚ_[p]) {ε : ℚ} (hε : 0 < ε) : ∃ r : ℚ, padicNormE (q - r) < ε :=
  Quotient.inductionOn q fun q' =>
    have : ∃ N, ∀ (m) (_ : m ≥ N) (n) (_ : n ≥ N), padicNorm p (q' m - q' n) < ε := cauchy₂ _ hε
    let ⟨N, hN⟩ := this
    ⟨q' N, by
      dsimp [padicNormE]
      change PadicSeq.norm (q' - const _ (q' N)) < ε
      cases' Decidable.em (q' - const (padicNorm p) (q' N) ≈ 0) with heq hne'
      · simpa only [HEq, PadicSeq.norm, dif_pos]
      · simp only [PadicSeq.norm, dif_neg hne']
        change padicNorm p (q' _ - q' _) < ε
        have := stationary_point_spec hne'
        cases' Decidable.em (stationary_point hne' ≤ N) with hle hle
        · have := Eq.symm (this le_rfl hle)
          simp only [const_apply, sub_apply, padicNorm.zero, sub_self] at this 
          simpa only [this]
        · exact hN _ (lt_of_not_ge hle).le _ le_rfl⟩
#align padic.rat_dense' Padic.rat_dense'
-/

open Classical

private theorem div_nat_pos (n : ℕ) : 0 < 1 / (n + 1 : ℚ) :=
  div_pos zero_lt_one (by exact_mod_cast succ_pos _)

#print Padic.limSeq /-
/-- `lim_seq f`, for `f` a Cauchy sequence of `p`-adic numbers, is a sequence of rationals with the
same limit point as `f`. -/
def limSeq : ℕ → ℚ := fun n => Classical.choose (rat_dense' (f n) (div_nat_pos n))
#align padic.lim_seq Padic.limSeq
-/

#print Padic.exi_rat_seq_conv /-
theorem exi_rat_seq_conv {ε : ℚ} (hε : 0 < ε) :
    ∃ N, ∀ i ≥ N, padicNormE (f i - (limSeq f i : ℚ_[p])) < ε :=
  by
  refine' (exists_nat_gt (1 / ε)).imp fun N hN i hi => _
  have h := Classical.choose_spec (rat_dense' (f i) (div_nat_pos i))
  refine' lt_of_lt_of_le h ((div_le_iff' <| by exact_mod_cast succ_pos _).mpr _)
  rw [right_distrib]
  apply le_add_of_le_of_nonneg
  · exact (div_le_iff hε).mp (le_trans (le_of_lt hN) (by exact_mod_cast hi))
  · apply le_of_lt; simpa
#align padic.exi_rat_seq_conv Padic.exi_rat_seq_conv
-/

#print Padic.exi_rat_seq_conv_cauchy /-
theorem exi_rat_seq_conv_cauchy : IsCauSeq (padicNorm p) (limSeq f) := fun ε hε =>
  by
  have hε3 : 0 < ε / 3 := div_pos hε (by norm_num)
  let ⟨N, hN⟩ := exi_rat_seq_conv f hε3
  let ⟨N2, hN2⟩ := f.cauchy₂ hε3
  exists max N N2
  intro j hj
  suffices padicNormE (lim_seq f j - f (max N N2) + (f (max N N2) - lim_seq f (max N N2))) < ε
    by
    ring_nf at this ⊢
    rw [← padicNormE.eq_padic_norm']
    exact_mod_cast this
  · apply lt_of_le_of_lt
    · apply padic_norm_e.add_le
    · have : (3 : ℚ) ≠ 0 := by norm_num
      have : ε = ε / 3 + ε / 3 + ε / 3 := by field_simp [this];
        simp only [bit0, bit1, mul_add, mul_one]
      rw [this]
      apply add_lt_add
      · suffices padicNormE (lim_seq f j - f j + (f j - f (max N N2))) < ε / 3 + ε / 3 by
          simpa only [sub_add_sub_cancel]
        apply lt_of_le_of_lt
        · apply padic_norm_e.add_le
        · apply add_lt_add
          · rw [padic_norm_e.map_sub]
            apply_mod_cast hN
            exact le_of_max_le_left hj
          · exact hN2 _ (le_of_max_le_right hj) _ (le_max_right _ _)
      · apply_mod_cast hN
        apply le_max_left
#align padic.exi_rat_seq_conv_cauchy Padic.exi_rat_seq_conv_cauchy
-/

private def lim' : PadicSeq p :=
  ⟨_, exi_rat_seq_conv_cauchy f⟩

private def lim : ℚ_[p] :=
  ⟦lim' f⟧

#print Padic.complete' /-
theorem complete' : ∃ q : ℚ_[p], ∀ ε > 0, ∃ N, ∀ i ≥ N, padicNormE (q - f i) < ε :=
  ⟨limUnder f, fun ε hε =>
    by
    obtain ⟨N, hN⟩ := exi_rat_seq_conv f (half_pos hε)
    obtain ⟨N2, hN2⟩ := padicNormE.defn (lim' f) (half_pos hε)
    refine' ⟨max N N2, fun i hi => _⟩
    rw [← sub_add_sub_cancel _ (lim' f i : ℚ_[p]) _]
    refine' (padic_norm_e.add_le _ _).trans_lt _
    rw [← add_halves ε]
    apply add_lt_add
    · apply hN2 _ (le_of_max_le_right hi)
    · rw [padic_norm_e.map_sub]
      exact hN _ (le_of_max_le_left hi)⟩
#align padic.complete' Padic.complete'
-/

end Complete

section NormedSpace

variable (p : ℕ) [Fact p.Prime]

instance : Dist ℚ_[p] :=
  ⟨fun x y => padicNormE (x - y)⟩

instance : MetricSpace ℚ_[p] where
  dist_self := by simp [dist]
  dist := dist
  dist_comm x y := by simp [dist, ← padic_norm_e.map_neg (x - y)]
  dist_triangle x y z := by
    unfold dist
    exact_mod_cast padic_norm_e.sub_le _ _ _
  eq_of_dist_eq_zero := by
    unfold dist; intro _ _ h
    apply eq_of_sub_eq_zero
    apply padic_norm_e.eq_zero.1
    exact_mod_cast h

instance : Norm ℚ_[p] :=
  ⟨fun x => padicNormE x⟩

instance : NormedField ℚ_[p] :=
  { Padic.field,
    Padic.metricSpace p with
    dist_eq := fun _ _ => rfl
    norm_mul' := by simp [Norm.norm, map_mul]
    norm := norm }

#print Padic.isAbsoluteValue /-
instance isAbsoluteValue : IsAbsoluteValue fun a : ℚ_[p] => ‖a‖
    where
  abv_nonneg := norm_nonneg
  abv_eq_zero _ := norm_eq_zero
  abv_add := norm_add_le
  abv_mul := by simp [Norm.norm, map_mul]
#align padic.is_absolute_value Padic.isAbsoluteValue
-/

#print Padic.rat_dense /-
theorem rat_dense (q : ℚ_[p]) {ε : ℝ} (hε : 0 < ε) : ∃ r : ℚ, ‖q - r‖ < ε :=
  let ⟨ε', hε'l, hε'r⟩ := exists_rat_btwn hε
  let ⟨r, hr⟩ := rat_dense' q (by simpa using hε'l)
  ⟨r, lt_trans (by simpa [Norm.norm] using hr) hε'r⟩
#align padic.rat_dense Padic.rat_dense
-/

end NormedSpace

end Padic

namespace padicNormE

section NormedSpace

variable {p : ℕ} [hp : Fact p.Prime]

#print padicNormE.mul /-
@[simp]
protected theorem mul (q r : ℚ_[p]) : ‖q * r‖ = ‖q‖ * ‖r‖ := by simp [Norm.norm, map_mul]
#align padic_norm_e.mul padicNormE.mul
-/

#print padicNormE.is_norm /-
protected theorem is_norm (q : ℚ_[p]) : ↑(padicNormE q) = ‖q‖ :=
  rfl
#align padic_norm_e.is_norm padicNormE.is_norm
-/

#print padicNormE.nonarchimedean /-
theorem nonarchimedean (q r : ℚ_[p]) : ‖q + r‖ ≤ max ‖q‖ ‖r‖ :=
  by
  unfold Norm.norm
  exact_mod_cast nonarchimedean' _ _
#align padic_norm_e.nonarchimedean padicNormE.nonarchimedean
-/

#print padicNormE.add_eq_max_of_ne /-
theorem add_eq_max_of_ne {q r : ℚ_[p]} (h : ‖q‖ ≠ ‖r‖) : ‖q + r‖ = max ‖q‖ ‖r‖ :=
  by
  unfold Norm.norm
  apply_mod_cast add_eq_max_of_ne'
  intro h'
  apply h
  unfold Norm.norm
  exact_mod_cast h'
#align padic_norm_e.add_eq_max_of_ne padicNormE.add_eq_max_of_ne
-/

#print padicNormE.eq_padicNorm /-
@[simp]
theorem eq_padicNorm (q : ℚ) : ‖(q : ℚ_[p])‖ = padicNorm p q :=
  by
  unfold Norm.norm
  rw [← padicNormE.eq_padic_norm']
#align padic_norm_e.eq_padic_norm padicNormE.eq_padicNorm
-/

#print padicNormE.norm_p /-
@[simp]
theorem norm_p : ‖(p : ℚ_[p])‖ = p⁻¹ :=
  by
  have p₀ : p ≠ 0 := hp.1.NeZero
  have p₁ : p ≠ 1 := hp.1.ne_one
  rw [← @Rat.cast_coe_nat ℝ _ p]
  rw [← @Rat.cast_coe_nat ℚ_[p] _ p]
  simp [p₀, p₁, norm, padicNorm, padicValRat, padicValInt, zpow_neg, -Rat.cast_coe_nat]
#align padic_norm_e.norm_p padicNormE.norm_p
-/

#print padicNormE.norm_p_lt_one /-
theorem norm_p_lt_one : ‖(p : ℚ_[p])‖ < 1 :=
  by
  rw [norm_p]
  apply inv_lt_one
  exact_mod_cast hp.1.one_lt
#align padic_norm_e.norm_p_lt_one padicNormE.norm_p_lt_one
-/

#print padicNormE.norm_p_zpow /-
@[simp]
theorem norm_p_zpow (n : ℤ) : ‖(p ^ n : ℚ_[p])‖ = p ^ (-n) := by
  rw [norm_zpow, norm_p, zpow_neg, inv_zpow]
#align padic_norm_e.norm_p_zpow padicNormE.norm_p_zpow
-/

#print padicNormE.norm_p_pow /-
@[simp]
theorem norm_p_pow (n : ℕ) : ‖(p ^ n : ℚ_[p])‖ = p ^ (-n : ℤ) := by rw [← norm_p_zpow, zpow_ofNat]
#align padic_norm_e.norm_p_pow padicNormE.norm_p_pow
-/

instance : NontriviallyNormedField ℚ_[p] :=
  { Padic.normedField p with
    non_trivial :=
      ⟨p⁻¹, by
        rw [norm_inv, norm_p, inv_inv]
        exact_mod_cast hp.1.one_lt⟩ }

#print padicNormE.image /-
protected theorem image {q : ℚ_[p]} : q ≠ 0 → ∃ n : ℤ, ‖q‖ = ↑((p : ℚ) ^ (-n)) :=
  Quotient.inductionOn q fun f hf =>
    have : ¬f ≈ 0 := (PadicSeq.ne_zero_iff_nequiv_zero f).1 hf
    let ⟨n, hn⟩ := PadicSeq.norm_values_discrete f this
    ⟨n, congr_arg coe hn⟩
#align padic_norm_e.image padicNormE.image
-/

#print padicNormE.is_rat /-
protected theorem is_rat (q : ℚ_[p]) : ∃ q' : ℚ, ‖q‖ = q' :=
  if h : q = 0 then ⟨0, by simp [h]⟩
  else
    let ⟨n, hn⟩ := padicNormE.image h
    ⟨_, hn⟩
#align padic_norm_e.is_rat padicNormE.is_rat
-/

#print padicNormE.ratNorm /-
/-- `rat_norm q`, for a `p`-adic number `q` is the `p`-adic norm of `q`, as rational number.

The lemma `padic_norm_e.eq_rat_norm` asserts `‖q‖ = rat_norm q`. -/
def ratNorm (q : ℚ_[p]) : ℚ :=
  Classical.choose (padicNormE.is_rat q)
#align padic_norm_e.rat_norm padicNormE.ratNorm
-/

#print padicNormE.eq_ratNorm /-
theorem eq_ratNorm (q : ℚ_[p]) : ‖q‖ = ratNorm q :=
  Classical.choose_spec (padicNormE.is_rat q)
#align padic_norm_e.eq_rat_norm padicNormE.eq_ratNorm
-/

#print padicNormE.norm_rat_le_one /-
theorem norm_rat_le_one : ∀ {q : ℚ} (hq : ¬p ∣ q.den), ‖(q : ℚ_[p])‖ ≤ 1
  | ⟨n, d, hn, hd⟩ => fun hq : ¬p ∣ d =>
    if hnz : n = 0 then
      by
      have : (⟨n, d, hn, hd⟩ : ℚ) = 0 := Rat.zero_iff_num_zero.mpr hnz
      norm_num [this]
    else
      by
      have hnz' :
        {   num := n
            den := d
            Pos := hn
            cop := hd } ≠ 0 := mt Rat.zero_iff_num_zero.1 hnz
      rw [padicNormE.eq_padicNorm]
      norm_cast
      rw [padicNorm.eq_zpow_of_nonzero hnz', padicValRat, neg_sub,
        padicValNat.eq_zero_of_not_dvd hq]
      norm_cast
      rw [zero_sub, zpow_neg, zpow_ofNat]
      apply inv_le_one
      · norm_cast
        apply one_le_pow
        exact hp.1.Pos
#align padic_norm_e.norm_rat_le_one padicNormE.norm_rat_le_one
-/

#print padicNormE.norm_int_le_one /-
theorem norm_int_le_one (z : ℤ) : ‖(z : ℚ_[p])‖ ≤ 1 :=
  suffices ‖((z : ℚ) : ℚ_[p])‖ ≤ 1 by simpa
  norm_rat_le_one <| by simp [hp.1.ne_one]
#align padic_norm_e.norm_int_le_one padicNormE.norm_int_le_one
-/

#print padicNormE.norm_int_lt_one_iff_dvd /-
theorem norm_int_lt_one_iff_dvd (k : ℤ) : ‖(k : ℚ_[p])‖ < 1 ↔ ↑p ∣ k :=
  by
  constructor
  · intro h
    contrapose! h
    apply le_of_eq
    rw [eq_comm]
    calc
      ‖(k : ℚ_[p])‖ = ‖((k : ℚ) : ℚ_[p])‖ := by norm_cast
      _ = padicNorm p k := (padicNormE.eq_padicNorm _)
      _ = 1 := _
    rw [padicNorm]
    split_ifs with H
    · exfalso
      apply h
      norm_cast at H 
      rw [H]
      apply dvd_zero
    · norm_cast at H ⊢
      convert zpow_zero _
      rw [neg_eq_zero, padicValRat.of_int]
      norm_cast
      apply padicValInt.eq_zero_of_not_dvd h
  · rintro ⟨x, rfl⟩
    push_cast
    rw [padicNormE.mul]
    calc
      _ ≤ ‖(p : ℚ_[p])‖ * 1 :=
        mul_le_mul le_rfl (by simpa using norm_int_le_one _) (norm_nonneg _) (norm_nonneg _)
      _ < 1 := _
    · rw [mul_one, padicNormE.norm_p]
      apply inv_lt_one
      exact_mod_cast hp.1.one_lt
#align padic_norm_e.norm_int_lt_one_iff_dvd padicNormE.norm_int_lt_one_iff_dvd
-/

#print padicNormE.norm_int_le_pow_iff_dvd /-
theorem norm_int_le_pow_iff_dvd (k : ℤ) (n : ℕ) : ‖(k : ℚ_[p])‖ ≤ ↑p ^ (-n : ℤ) ↔ ↑(p ^ n) ∣ k :=
  by
  have : (p : ℝ) ^ (-n : ℤ) = ↑(p ^ (-n : ℤ) : ℚ) := by simp
  rw [show (k : ℚ_[p]) = ((k : ℚ) : ℚ_[p]) by norm_cast, eq_padic_norm, this]
  norm_cast
  rw [← padicNorm.dvd_iff_norm_le]
#align padic_norm_e.norm_int_le_pow_iff_dvd padicNormE.norm_int_le_pow_iff_dvd
-/

#print padicNormE.eq_of_norm_add_lt_right /-
theorem eq_of_norm_add_lt_right {z1 z2 : ℚ_[p]} (h : ‖z1 + z2‖ < ‖z2‖) : ‖z1‖ = ‖z2‖ :=
  by_contradiction fun hne =>
    not_lt_of_ge (by rw [padicNormE.add_eq_max_of_ne hne] <;> apply le_max_right) h
#align padic_norm_e.eq_of_norm_add_lt_right padicNormE.eq_of_norm_add_lt_right
-/

#print padicNormE.eq_of_norm_add_lt_left /-
theorem eq_of_norm_add_lt_left {z1 z2 : ℚ_[p]} (h : ‖z1 + z2‖ < ‖z1‖) : ‖z1‖ = ‖z2‖ :=
  by_contradiction fun hne =>
    not_lt_of_ge (by rw [padicNormE.add_eq_max_of_ne hne] <;> apply le_max_left) h
#align padic_norm_e.eq_of_norm_add_lt_left padicNormE.eq_of_norm_add_lt_left
-/

end NormedSpace

end padicNormE

namespace Padic

variable {p : ℕ} [hp : Fact p.Prime]

/- ./././Mathport/Syntax/Translate/Basic.lean:334:40: warning: unsupported option eqn_compiler.zeta -/
set_option eqn_compiler.zeta true

#print Padic.complete /-
instance complete : CauSeq.IsComplete ℚ_[p] norm :=
  by
  constructor; intro f
  have cau_seq_norm_e : IsCauSeq padicNormE f :=
    by
    intro ε hε
    let h := is_cau f ε (by exact_mod_cast hε)
    unfold norm at h 
    apply_mod_cast h
  cases' Padic.complete' ⟨f, cau_seq_norm_e⟩ with q hq
  exists q
  intro ε hε
  cases' exists_rat_btwn hε with ε' hε'
  norm_cast at hε' 
  cases' hq ε' hε'.1 with N hN; exists N
  intro i hi; let h := hN i hi
  unfold norm
  rw_mod_cast [padic_norm_e.map_sub]
  refine' lt_trans _ hε'.2
  exact_mod_cast hN i hi
#align padic.complete Padic.complete
-/

#print Padic.padicNormE_lim_le /-
theorem padicNormE_lim_le {f : CauSeq ℚ_[p] norm} {a : ℝ} (ha : 0 < a) (hf : ∀ i, ‖f i‖ ≤ a) :
    ‖f.lim‖ ≤ a :=
  let ⟨N, hN⟩ := Setoid.symm (CauSeq.equiv_lim f) _ ha
  calc
    ‖f.lim‖ = ‖f.lim - f N + f N‖ := by simp
    _ ≤ max ‖f.lim - f N‖ ‖f N‖ := (padicNormE.nonarchimedean _ _)
    _ ≤ a := max_le (le_of_lt (hN _ le_rfl)) (hf _)
#align padic.padic_norm_e_lim_le Padic.padicNormE_lim_le
-/

open Filter Set

instance : CompleteSpace ℚ_[p] :=
  by
  apply complete_of_cauchy_seq_tendsto
  intro u hu
  let c : CauSeq ℚ_[p] norm := ⟨u, metric.cauchy_seq_iff'.mp hu⟩
  refine' ⟨c.lim, fun s h => _⟩
  rcases Metric.mem_nhds_iff.1 h with ⟨ε, ε0, hε⟩
  have := c.equiv_lim ε ε0
  simp only [mem_map, mem_at_top_sets, mem_set_of_eq]
  exact this.imp fun N hN n hn => hε (hN n hn)

/-! ### Valuation on `ℚ_[p]` -/


#print Padic.valuation /-
/-- `padic.valuation` lifts the `p`-adic valuation on rationals to `ℚ_[p]`. -/
def valuation : ℚ_[p] → ℤ :=
  Quotient.lift (@PadicSeq.valuation p _) fun f g h =>
    by
    by_cases hf : f ≈ 0
    · have hg : g ≈ 0 := Setoid.trans (Setoid.symm h) hf
      simp [hf, hg, PadicSeq.valuation]
    · have hg : ¬g ≈ 0 := fun hg => hf (Setoid.trans h hg)
      rw [PadicSeq.val_eq_iff_norm_eq hf hg]
      exact PadicSeq.norm_equiv h
#align padic.valuation Padic.valuation
-/

#print Padic.valuation_zero /-
@[simp]
theorem valuation_zero : valuation (0 : ℚ_[p]) = 0 :=
  dif_pos ((const_equiv p).2 rfl)
#align padic.valuation_zero Padic.valuation_zero
-/

#print Padic.valuation_one /-
@[simp]
theorem valuation_one : valuation (1 : ℚ_[p]) = 0 :=
  by
  change dite (CauSeq.const (padicNorm p) 1 ≈ _) _ _ = _
  have h : ¬CauSeq.const (padicNorm p) 1 ≈ 0 := by intro H; erw [const_equiv p] at H ;
    exact one_ne_zero H
  rw [dif_neg h]
  simp
#align padic.valuation_one Padic.valuation_one
-/

#print Padic.norm_eq_pow_val /-
theorem norm_eq_pow_val {x : ℚ_[p]} : x ≠ 0 → ‖x‖ = p ^ (-x.Valuation) :=
  by
  apply Quotient.inductionOn' x; clear x
  intro f hf
  change (PadicSeq.norm _ : ℝ) = (p : ℝ) ^ (-PadicSeq.valuation _)
  rw [PadicSeq.norm_eq_pow_val]
  change ↑((p : ℚ) ^ (-PadicSeq.valuation f)) = (p : ℝ) ^ (-PadicSeq.valuation f)
  · rw [Rat.cast_zpow, Rat.cast_coe_nat]
  · apply CauSeq.not_limZero_of_not_congr_zero
    contrapose! hf
    apply Quotient.sound
    simpa using hf
#align padic.norm_eq_pow_val Padic.norm_eq_pow_val
-/

#print Padic.valuation_p /-
@[simp]
theorem valuation_p : valuation (p : ℚ_[p]) = 1 :=
  by
  have h : (1 : ℝ) < p := by exact_mod_cast (Fact.out p.prime).one_lt
  refine' neg_injective ((zpow_strictMono h).Injective <| (norm_eq_pow_val _).symm.trans _)
  · exact_mod_cast (Fact.out p.prime).NeZero
  · simp
#align padic.valuation_p Padic.valuation_p
-/

#print Padic.valuation_map_add /-
theorem valuation_map_add {x y : ℚ_[p]} (hxy : x + y ≠ 0) :
    min (valuation x) (valuation y) ≤ valuation (x + y) :=
  by
  by_cases hx : x = 0
  · rw [hx, zero_add]
    exact min_le_right _ _
  · by_cases hy : y = 0
    · rw [hy, add_zero]
      exact min_le_left _ _
    · have h_norm : ‖x + y‖ ≤ max ‖x‖ ‖y‖ := padicNormE.nonarchimedean x y
      have hp_one : (1 : ℝ) < p := by
        rw [← Nat.cast_one, Nat.cast_lt]
        exact Nat.Prime.one_lt hp.elim
      rwa [norm_eq_pow_val hx, norm_eq_pow_val hy, norm_eq_pow_val hxy,
        zpow_le_max_iff_min_le hp_one] at h_norm 
#align padic.valuation_map_add Padic.valuation_map_add
-/

#print Padic.valuation_map_mul /-
@[simp]
theorem valuation_map_mul {x y : ℚ_[p]} (hx : x ≠ 0) (hy : y ≠ 0) :
    valuation (x * y) = valuation x + valuation y :=
  by
  have h_norm : ‖x * y‖ = ‖x‖ * ‖y‖ := norm_mul x y
  have hp_ne_one : (p : ℝ) ≠ 1 :=
    by
    rw [← Nat.cast_one, Ne.def, Nat.cast_inj]
    exact Nat.Prime.ne_one hp.elim
  have hp_pos : (0 : ℝ) < p := by
    rw [← Nat.cast_zero, Nat.cast_lt]
    exact Nat.Prime.pos hp.elim
  rw [norm_eq_pow_val hx, norm_eq_pow_val hy, norm_eq_pow_val (mul_ne_zero hx hy), ←
    zpow_add₀ (ne_of_gt hp_pos), zpow_inj hp_pos hp_ne_one, ← neg_add, neg_inj] at h_norm 
  exact h_norm
#align padic.valuation_map_mul Padic.valuation_map_mul
-/

#print Padic.addValuationDef /-
/-- The additive `p`-adic valuation on `ℚ_[p]`, with values in `with_top ℤ`. -/
def addValuationDef : ℚ_[p] → WithTop ℤ := fun x => if x = 0 then ⊤ else x.Valuation
#align padic.add_valuation_def Padic.addValuationDef
-/

#print Padic.AddValuation.map_zero /-
@[simp]
theorem AddValuation.map_zero : addValuationDef (0 : ℚ_[p]) = ⊤ := by
  simp only [add_valuation_def, if_pos (Eq.refl _)]
#align padic.add_valuation.map_zero Padic.AddValuation.map_zero
-/

#print Padic.AddValuation.map_one /-
@[simp]
theorem AddValuation.map_one : addValuationDef (1 : ℚ_[p]) = 0 := by
  simp only [add_valuation_def, if_neg one_ne_zero, valuation_one, WithTop.coe_zero]
#align padic.add_valuation.map_one Padic.AddValuation.map_one
-/

#print Padic.AddValuation.map_mul /-
theorem AddValuation.map_mul (x y : ℚ_[p]) :
    addValuationDef (x * y) = addValuationDef x + addValuationDef y :=
  by
  simp only [add_valuation_def]
  by_cases hx : x = 0
  · rw [hx, if_pos (Eq.refl _), MulZeroClass.zero_mul, if_pos (Eq.refl _), WithTop.top_add]
  · by_cases hy : y = 0
    · rw [hy, if_pos (Eq.refl _), MulZeroClass.mul_zero, if_pos (Eq.refl _), WithTop.add_top]
    ·
      rw [if_neg hx, if_neg hy, if_neg (mul_ne_zero hx hy), ← WithTop.coe_add, WithTop.coe_eq_coe,
        valuation_map_mul hx hy]
#align padic.add_valuation.map_mul Padic.AddValuation.map_mul
-/

#print Padic.AddValuation.map_add /-
theorem AddValuation.map_add (x y : ℚ_[p]) :
    min (addValuationDef x) (addValuationDef y) ≤ addValuationDef (x + y) :=
  by
  simp only [add_valuation_def]
  by_cases hxy : x + y = 0
  · rw [hxy, if_pos (Eq.refl _)]
    exact le_top
  · by_cases hx : x = 0
    · simp only [hx, if_pos (Eq.refl _), min_eq_right, le_top, zero_add, le_refl]
    · by_cases hy : y = 0
      · simp only [hy, if_pos (Eq.refl _), min_eq_left, le_top, add_zero, le_refl]
      · rw [if_neg hx, if_neg hy, if_neg hxy, ← WithTop.coe_min, WithTop.coe_le_coe]
        exact valuation_map_add hxy
#align padic.add_valuation.map_add Padic.AddValuation.map_add
-/

#print Padic.addValuation /-
/-- The additive `p`-adic valuation on `ℚ_[p]`, as an `add_valuation`. -/
def addValuation : AddValuation ℚ_[p] (WithTop ℤ) :=
  AddValuation.of addValuationDef AddValuation.map_zero AddValuation.map_one AddValuation.map_add
    AddValuation.map_mul
#align padic.add_valuation Padic.addValuation
-/

#print Padic.addValuation.apply /-
@[simp]
theorem addValuation.apply {x : ℚ_[p]} (hx : x ≠ 0) : x.AddValuation = x.Valuation := by
  simp only [AddValuation, AddValuation.of_apply, add_valuation_def, if_neg hx]
#align padic.add_valuation.apply Padic.addValuation.apply
-/

section NormLeIff

/-! ### Various characterizations of open unit balls -/


#print Padic.norm_le_pow_iff_norm_lt_pow_add_one /-
theorem norm_le_pow_iff_norm_lt_pow_add_one (x : ℚ_[p]) (n : ℤ) : ‖x‖ ≤ p ^ n ↔ ‖x‖ < p ^ (n + 1) :=
  by
  have aux : ∀ n : ℤ, 0 < (p ^ n : ℝ) := by apply Nat.zpow_pos_of_pos; exact hp.1.Pos
  by_cases hx0 : x = 0; · simp [hx0, norm_zero, aux, le_of_lt (aux _)]
  rw [norm_eq_pow_val hx0]
  have h1p : 1 < (p : ℝ) := by exact_mod_cast hp.1.one_lt
  have H := zpow_strictMono h1p
  rw [H.le_iff_le, H.lt_iff_lt, Int.lt_add_one_iff]
#align padic.norm_le_pow_iff_norm_lt_pow_add_one Padic.norm_le_pow_iff_norm_lt_pow_add_one
-/

#print Padic.norm_lt_pow_iff_norm_le_pow_sub_one /-
theorem norm_lt_pow_iff_norm_le_pow_sub_one (x : ℚ_[p]) (n : ℤ) : ‖x‖ < p ^ n ↔ ‖x‖ ≤ p ^ (n - 1) :=
  by rw [norm_le_pow_iff_norm_lt_pow_add_one, sub_add_cancel]
#align padic.norm_lt_pow_iff_norm_le_pow_sub_one Padic.norm_lt_pow_iff_norm_le_pow_sub_one
-/

#print Padic.norm_le_one_iff_val_nonneg /-
theorem norm_le_one_iff_val_nonneg (x : ℚ_[p]) : ‖x‖ ≤ 1 ↔ 0 ≤ x.Valuation :=
  by
  by_cases hx : x = 0
  · simp only [hx, norm_zero, valuation_zero, zero_le_one, le_refl]
  · rw [norm_eq_pow_val hx, ← zpow_zero (p : ℝ), zpow_le_iff_le, Right.neg_nonpos_iff]
    exact Nat.one_lt_cast.2 (Nat.Prime.one_lt' p).1
#align padic.norm_le_one_iff_val_nonneg Padic.norm_le_one_iff_val_nonneg
-/

end NormLeIff

end Padic

