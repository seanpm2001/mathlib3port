/-
Copyright (c) 2022 Yaël Dillies, Bhavik Mehta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Bhavik Mehta

! This file was ported from Lean 3 source module combinatorics.simple_graph.regularity.increment
! leanprover-community/mathlib commit 08b63ab58a6ec1157ebeafcbbe6c7a3fb3c9f6d5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Combinatorics.SimpleGraph.Regularity.Chunk
import Mathbin.Combinatorics.SimpleGraph.Regularity.Energy

/-!
# Increment partition for Szemerédi Regularity Lemma

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In the proof of Szemerédi Regularity Lemma, we need to partition each part of a starting partition
to increase the energy. This file defines the partition obtained by gluing the parts partitions
together (the *increment partition*) and shows that the energy globally increases.

This entire file is internal to the proof of Szemerédi Regularity Lemma.

## Main declarations

* `szemeredi_regularity.increment`: The increment partition.
* `szemeredi_regularity.card_increment`: The increment partition is much bigger than the original,
  but by a controlled amount.
* `szemeredi_regularity.energy_increment`: The increment partition has energy greater than the
  original by a known (small) fixed amount.

## TODO

Once ported to mathlib4, this file will be a great golfing ground for Heather's new tactic
`rel_congr`.

## References

[Yaël Dillies, Bhavik Mehta, *Formalising Szemerédi’s Regularity Lemma in Lean*][srl_itp]
-/


open Finset Fintype SimpleGraph szemeredi_regularity

open scoped BigOperators Classical

attribute [local positivity] tactic.positivity_szemeredi_regularity

variable {α : Type _} [Fintype α] {P : Finpartition (univ : Finset α)} (hP : P.IsEquipartition)
  (G : SimpleGraph α) (ε : ℝ)

local notation "m" => (card α / stepBound P.parts.card : ℕ)

namespace szemeredi_regularity

#print SzemerediRegularity.increment /-
/-- The **increment partition** in Szemerédi's Regularity Lemma.

If an equipartition is *not* uniform, then the increment partition is a (much bigger) equipartition
with a slightly higher energy. This is helpful since the energy is bounded by a constant (see
`szemeredi_regularity.energy_le_one`), so this process eventually terminates and yields a
not-too-big uniform equipartition. -/
noncomputable def increment : Finpartition (univ : Finset α) :=
  P.bind fun U => chunk hP G ε
#align szemeredi_regularity.increment SzemerediRegularity.increment
-/

open Finpartition Finpartition.IsEquipartition

variable {hP G ε}

#print SzemerediRegularity.card_increment /-
/-- The increment partition has a prescribed (very big) size in terms of the original partition. -/
theorem card_increment (hPα : P.parts.card * 16 ^ P.parts.card ≤ card α) (hPG : ¬P.IsUniform G ε) :
    (increment hP G ε).parts.card = stepBound P.parts.card :=
  by
  have hPα' : step_bound P.parts.card ≤ card α :=
    (mul_le_mul_left' (pow_le_pow_of_le_left' (by norm_num) _) _).trans hPα
  have hPpos : 0 < step_bound P.parts.card := step_bound_pos (nonempty_of_not_uniform hPG).card_pos
  rw [increment, card_bind]
  simp_rw [chunk, apply_dite Finpartition.parts, apply_dite card, sum_dite]
  rw [sum_const_nat, sum_const_nat, card_attach, card_attach]; rotate_left
  any_goals exact fun x hx => card_parts_equitabilise _ _ (Nat.div_pos hPα' hPpos).ne'
  rw [Nat.sub_add_cancel a_add_one_le_four_pow_parts_card,
    Nat.sub_add_cancel ((Nat.le_succ _).trans a_add_one_le_four_pow_parts_card), ← add_mul]
  congr
  rw [filter_card_add_filter_neg_card_eq_card, card_attach]
#align szemeredi_regularity.card_increment SzemerediRegularity.card_increment
-/

#print SzemerediRegularity.increment_isEquipartition /-
theorem increment_isEquipartition (hP : P.IsEquipartition) (G : SimpleGraph α) (ε : ℝ) :
    (increment hP G ε).IsEquipartition :=
  by
  simp_rw [is_equipartition, Set.equitableOn_iff_exists_eq_eq_add_one]
  refine' ⟨m, fun A hA => _⟩
  rw [mem_coe, increment, mem_bind] at hA 
  obtain ⟨U, hU, hA⟩ := hA
  exact card_eq_of_mem_parts_chunk hA
#align szemeredi_regularity.increment_is_equipartition SzemerediRegularity.increment_isEquipartition
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
private theorem distinct_pairs_increment :
    (P.parts.offDiag.attach.biUnion fun UV =>
        (chunk hP G ε (mem_offDiag.1 UV.2).1).parts ×ˢ
          (chunk hP G ε (mem_offDiag.1 UV.2).2.1).parts) ⊆
      (increment hP G ε).parts.offDiag :=
  by
  rintro ⟨Ui, Vj⟩
  simp only [increment, mem_off_diag, bind_parts, mem_bUnion, Prod.exists, exists_and_left,
    exists_prop, mem_product, mem_attach, true_and_iff, Subtype.exists, and_imp, mem_off_diag,
    forall_exists_index, bex_imp, Ne.def]
  refine' fun U V hUV hUi hVj => ⟨⟨_, hUV.1, hUi⟩, ⟨_, hUV.2.1, hVj⟩, _⟩
  rintro rfl
  obtain ⟨i, hi⟩ := nonempty_of_mem_parts _ hUi
  exact
    hUV.2.2
      (P.disjoint.elim_finset hUV.1 hUV.2.1 i (Finpartition.le _ hUi hi) <|
        Finpartition.le _ hVj hi)

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The contribution to `finpartition.energy` of a pair of distinct parts of a finpartition. -/
private noncomputable def pair_contrib (G : SimpleGraph α) (ε : ℝ) (hP : P.IsEquipartition)
    (x : { x // x ∈ P.parts.offDiag }) : ℚ :=
  ∑ i in (chunk hP G ε (mem_offDiag.1 x.2).1).parts ×ˢ (chunk hP G ε (mem_offDiag.1 x.2).2.1).parts,
    G.edgeDensity i.fst i.snd ^ 2

#print SzemerediRegularity.offDiag_pairs_le_increment_energy /-
theorem offDiag_pairs_le_increment_energy :
    ∑ x in P.parts.offDiag.attach, pairContrib G ε hP x / (increment hP G ε).parts.card ^ 2 ≤
      (increment hP G ε).energy G :=
  by
  simp_rw [pair_contrib, ← sum_div]
  refine' div_le_div_of_le_of_nonneg _ (sq_nonneg _)
  rw [← sum_bUnion]
  · exact sum_le_sum_of_subset_of_nonneg distinct_pairs_increment fun i _ _ => sq_nonneg _
  simp only [Set.PairwiseDisjoint, Function.onFun, disjoint_left, inf_eq_inter, mem_inter,
    mem_product]
  rintro ⟨⟨s₁, s₂⟩, hs⟩ _ ⟨⟨t₁, t₂⟩, ht⟩ _ hst ⟨u, v⟩ huv₁ huv₂
  rw [mem_off_diag] at hs ht 
  obtain ⟨a, ha⟩ := Finpartition.nonempty_of_mem_parts _ huv₁.1
  obtain ⟨b, hb⟩ := Finpartition.nonempty_of_mem_parts _ huv₁.2
  exact
    hst
      (Subtype.ext_val <|
        Prod.ext
            (P.disjoint.elim_finset hs.1 ht.1 a (Finpartition.le _ huv₁.1 ha) <|
              Finpartition.le _ huv₂.1 ha) <|
          P.disjoint.elim_finset hs.2.1 ht.2.1 b (Finpartition.le _ huv₁.2 hb) <|
            Finpartition.le _ huv₂.2 hb)
#align szemeredi_regularity.off_diag_pairs_le_increment_energy SzemerediRegularity.offDiag_pairs_le_increment_energy
-/

#print SzemerediRegularity.pairContrib_lower_bound /-
theorem pairContrib_lower_bound [Nonempty α] (x : { i // i ∈ P.parts.offDiag }) (hε₁ : ε ≤ 1)
    (hPα : P.parts.card * 16 ^ P.parts.card ≤ card α) (hPε : 100 ≤ 4 ^ P.parts.card * ε ^ 5) :
    (↑(G.edgeDensity x.1.1 x.1.2) ^ 2 - ε ^ 5 / 25 +
        if G.IsUniform ε x.1.1 x.1.2 then 0 else ε ^ 4 / 3) ≤
      pairContrib G ε hP x / 16 ^ P.parts.card :=
  by
  rw [pair_contrib]
  push_cast
  split_ifs
  · rw [add_zero]
    exact edge_density_chunk_uniform hPα hPε _ _
  · exact edge_density_chunk_not_uniform hPα hPε hε₁ (mem_off_diag.1 x.2).2.2 h
#align szemeredi_regularity.pair_contrib_lower_bound SzemerediRegularity.pairContrib_lower_bound
-/

#print SzemerediRegularity.uniform_add_nonuniform_eq_offDiag_pairs /-
theorem uniform_add_nonuniform_eq_offDiag_pairs [Nonempty α] (hε₁ : ε ≤ 1) (hP₇ : 7 ≤ P.parts.card)
    (hPα : P.parts.card * 16 ^ P.parts.card ≤ card α) (hPε : 100 ≤ 4 ^ P.parts.card * ε ^ 5)
    (hPG : ¬P.IsUniform G ε) :
    (∑ x in P.parts.offDiag, G.edgeDensity x.1 x.2 ^ 2 + P.parts.card ^ 2 * (ε ^ 5 / 4) : ℝ) /
        P.parts.card ^ 2 ≤
      ∑ x in P.parts.offDiag.attach, pairContrib G ε hP x / (increment hP G ε).parts.card ^ 2 :=
  by
  conv_rhs =>
    rw [← sum_div, card_increment hPα hPG, step_bound, ← Nat.cast_pow, mul_pow, pow_right_comm,
      Nat.cast_mul, mul_comm, ← div_div, show 4 ^ 2 = 16 by norm_num, sum_div]
  rw [← Nat.cast_pow, Nat.cast_pow 16]
  refine' div_le_div_of_le_of_nonneg _ (Nat.cast_nonneg _)
  norm_num
  trans
    ∑ x in P.parts.off_diag.attach,
      (G.edge_density x.1.1 x.1.2 ^ 2 - ε ^ 5 / 25 +
          if G.is_uniform ε x.1.1 x.1.2 then 0 else ε ^ 4 / 3 :
        ℝ)
  swap
  · exact sum_le_sum fun i hi => pair_contrib_lower_bound i hε₁ hPα hPε
  have :
    ∑ x in P.parts.off_diag.attach,
        (G.edge_density x.1.1 x.1.2 ^ 2 - ε ^ 5 / 25 +
            if G.is_uniform ε x.1.1 x.1.2 then 0 else ε ^ 4 / 3 :
          ℝ) =
      ∑ x in P.parts.off_diag,
        (G.edge_density x.1 x.2 ^ 2 - ε ^ 5 / 25 +
          if G.is_uniform ε x.1 x.2 then 0 else ε ^ 4 / 3) :=
    by convert sum_attach; rfl
  rw [this, sum_add_distrib, sum_sub_distrib, sum_const, nsmul_eq_mul, sum_ite, sum_const_zero,
    zero_add, sum_const, nsmul_eq_mul, ← Finpartition.nonUniforms]
  rw [Finpartition.IsUniform, not_le] at hPG 
  refine' le_trans _ (add_le_add_left (mul_le_mul_of_nonneg_right hPG.le <| by positivity) _)
  conv_rhs =>
    congr
    congr
    skip
    rw [off_diag_card]
    congr
    congr
    conv =>
      congr
      skip
      rw [← mul_one P.parts.card]
    rw [← Nat.mul_sub_left_distrib]
  simp_rw [mul_assoc, sub_add_eq_add_sub, add_sub_assoc, ← mul_sub_left_distrib, mul_div_assoc' ε, ←
    pow_succ, div_eq_mul_one_div (ε ^ 5), ← mul_sub_left_distrib, mul_left_comm _ (ε ^ 5), sq,
    Nat.cast_mul, mul_assoc, ← mul_assoc (ε ^ 5)]
  refine' add_le_add_left (mul_le_mul_of_nonneg_left _ <| by positivity) _
  rw [Nat.cast_sub (P.parts_nonempty <| univ_nonempty.ne_empty).card_pos, mul_sub_right_distrib,
    Nat.cast_one, one_mul, le_sub_comm, ← mul_sub_left_distrib, ←
    div_le_iff (show (0 : ℝ) < 1 / 3 - 1 / 25 - 1 / 4 by norm_num)]
  exact le_trans (show _ ≤ (7 : ℝ) by norm_num) (by exact_mod_cast hP₇)
#align szemeredi_regularity.uniform_add_nonuniform_eq_off_diag_pairs SzemerediRegularity.uniform_add_nonuniform_eq_offDiag_pairs
-/

#print SzemerediRegularity.energy_increment /-
/-- The increment partition has energy greater than the original one by a known fixed amount. -/
theorem energy_increment [Nonempty α] (hP : P.IsEquipartition) (hP₇ : 7 ≤ P.parts.card)
    (hε : 100 < 4 ^ P.parts.card * ε ^ 5) (hPα : P.parts.card * 16 ^ P.parts.card ≤ card α)
    (hPG : ¬P.IsUniform G ε) (hε₁ : ε ≤ 1) :
    ↑(P.energy G) + ε ^ 5 / 4 ≤ (increment hP G ε).energy G :=
  by
  rw [coe_energy]
  have h := uniform_add_nonuniform_eq_off_diag_pairs hε₁ hP₇ hPα hε.le hPG
  rw [add_div, mul_div_cancel_left] at h 
  exact h.trans (by exact_mod_cast off_diag_pairs_le_increment_energy)
  positivity
#align szemeredi_regularity.energy_increment SzemerediRegularity.energy_increment
-/

end szemeredi_regularity

