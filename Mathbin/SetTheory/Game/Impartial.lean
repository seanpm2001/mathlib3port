/-
Copyright (c) 2020 Fox Thomson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Fox Thomson

! This file was ported from Lean 3 source module set_theory.game.impartial
! leanprover-community/mathlib commit 9240e8be927a0955b9a82c6c85ef499ee3a626b8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.SetTheory.Game.Basic
import Mathbin.Tactic.NthRewrite.Default

/-!
# Basic definitions about impartial (pre-)games

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We will define an impartial game, one in which left and right can make exactly the same moves.
Our definition differs slightly by saying that the game is always equivalent to its negative,
no matter what moves are played. This allows for games such as poker-nim to be classifed as
impartial.
-/


universe u

open scoped PGame

namespace PGame

#print PGame.ImpartialAux /-
/-- The definition for a impartial game, defined using Conway induction. -/
def ImpartialAux : PGame → Prop
  | G => (G ≈ -G) ∧ (∀ i, impartial_aux (G.moveLeft i)) ∧ ∀ j, impartial_aux (G.moveRight j)
decreasing_by pgame_wf_tac
#align pgame.impartial_aux PGame.ImpartialAux
-/

#print PGame.impartialAux_def /-
theorem impartialAux_def {G : PGame} :
    G.ImpartialAux ↔
      (G ≈ -G) ∧ (∀ i, ImpartialAux (G.moveLeft i)) ∧ ∀ j, ImpartialAux (G.moveRight j) :=
  by rw [impartial_aux]
#align pgame.impartial_aux_def PGame.impartialAux_def
-/

#print PGame.Impartial /-
/-- A typeclass on impartial games. -/
class Impartial (G : PGame) : Prop where
  out : ImpartialAux G
#align pgame.impartial PGame.Impartial
-/

#print PGame.impartial_iff_aux /-
theorem impartial_iff_aux {G : PGame} : G.Impartial ↔ G.ImpartialAux :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩
#align pgame.impartial_iff_aux PGame.impartial_iff_aux
-/

#print PGame.impartial_def /-
theorem impartial_def {G : PGame} :
    G.Impartial ↔ (G ≈ -G) ∧ (∀ i, Impartial (G.moveLeft i)) ∧ ∀ j, Impartial (G.moveRight j) := by
  simpa only [impartial_iff_aux] using impartial_aux_def
#align pgame.impartial_def PGame.impartial_def
-/

namespace Impartial

#print PGame.Impartial.impartial_zero /-
instance impartial_zero : Impartial 0 := by rw [impartial_def]; dsimp; simp
#align pgame.impartial.impartial_zero PGame.Impartial.impartial_zero
-/

#print PGame.Impartial.impartial_star /-
instance impartial_star : Impartial star := by rw [impartial_def];
  simpa using impartial.impartial_zero
#align pgame.impartial.impartial_star PGame.Impartial.impartial_star
-/

#print PGame.Impartial.neg_equiv_self /-
theorem neg_equiv_self (G : PGame) [h : G.Impartial] : G ≈ -G :=
  (impartial_def.1 h).1
#align pgame.impartial.neg_equiv_self PGame.Impartial.neg_equiv_self
-/

#print PGame.Impartial.mk'_neg_equiv_self /-
@[simp]
theorem mk'_neg_equiv_self (G : PGame) [h : G.Impartial] : -⟦G⟧ = ⟦G⟧ :=
  Quot.sound (neg_equiv_self G).symm
#align pgame.impartial.mk_neg_equiv_self PGame.Impartial.mk'_neg_equiv_self
-/

#print PGame.Impartial.moveLeft_impartial /-
instance moveLeft_impartial {G : PGame} [h : G.Impartial] (i : G.LeftMoves) :
    (G.moveLeft i).Impartial :=
  (impartial_def.1 h).2.1 i
#align pgame.impartial.move_left_impartial PGame.Impartial.moveLeft_impartial
-/

#print PGame.Impartial.moveRight_impartial /-
instance moveRight_impartial {G : PGame} [h : G.Impartial] (j : G.RightMoves) :
    (G.moveRight j).Impartial :=
  (impartial_def.1 h).2.2 j
#align pgame.impartial.move_right_impartial PGame.Impartial.moveRight_impartial
-/

#print PGame.Impartial.impartial_congr /-
theorem impartial_congr : ∀ {G H : PGame} (e : G ≡r H) [G.Impartial], H.Impartial
  | G, H => fun e => by
    intro h
    exact
      impartial_def.2
        ⟨e.symm.equiv.trans ((neg_equiv_self G).trans (neg_equiv_neg_iff.2 e.equiv)), fun i =>
          impartial_congr (e.move_left_symm i), fun j => impartial_congr (e.move_right_symm j)⟩
decreasing_by pgame_wf_tac
#align pgame.impartial.impartial_congr PGame.Impartial.impartial_congr
-/

#print PGame.Impartial.impartial_add /-
instance impartial_add : ∀ (G H : PGame) [G.Impartial] [H.Impartial], (G + H).Impartial
  | G, H => by
    intro hG hH
    rw [impartial_def]
    refine'
      ⟨(add_congr (neg_equiv_self _) (neg_equiv_self _)).trans (neg_add_relabelling _ _).Equiv.symm,
        fun k => _, fun k => _⟩
    · apply left_moves_add_cases k
      all_goals
        intro i; simp only [add_move_left_inl, add_move_left_inr]
        apply impartial_add
    · apply right_moves_add_cases k
      all_goals
        intro i; simp only [add_move_right_inl, add_move_right_inr]
        apply impartial_add
decreasing_by pgame_wf_tac
#align pgame.impartial.impartial_add PGame.Impartial.impartial_add
-/

#print PGame.Impartial.impartial_neg /-
instance impartial_neg : ∀ (G : PGame) [G.Impartial], (-G).Impartial
  | G => by
    intro hG
    rw [impartial_def]
    refine' ⟨_, fun i => _, fun i => _⟩
    · rw [neg_neg]
      exact (neg_equiv_self G).symm
    · rw [move_left_neg']
      apply impartial_neg
    · rw [move_right_neg']
      apply impartial_neg
decreasing_by pgame_wf_tac
#align pgame.impartial.impartial_neg PGame.Impartial.impartial_neg
-/

variable (G : PGame) [Impartial G]

#print PGame.Impartial.nonpos /-
theorem nonpos : ¬0 < G := fun h =>
  by
  have h' := neg_lt_neg_iff.2 h
  rw [neg_zero, lt_congr_left (neg_equiv_self G).symm] at h' 
  exact (h.trans h').False
#align pgame.impartial.nonpos PGame.Impartial.nonpos
-/

#print PGame.Impartial.nonneg /-
theorem nonneg : ¬G < 0 := fun h =>
  by
  have h' := neg_lt_neg_iff.2 h
  rw [neg_zero, lt_congr_right (neg_equiv_self G).symm] at h' 
  exact (h.trans h').False
#align pgame.impartial.nonneg PGame.Impartial.nonneg
-/

#print PGame.Impartial.equiv_or_fuzzy_zero /-
/-- In an impartial game, either the first player always wins, or the second player always wins. -/
theorem equiv_or_fuzzy_zero : (G ≈ 0) ∨ G ‖ 0 :=
  by
  rcases lt_or_equiv_or_gt_or_fuzzy G 0 with (h | h | h | h)
  · exact ((nonneg G) h).elim
  · exact Or.inl h
  · exact ((nonpos G) h).elim
  · exact Or.inr h
#align pgame.impartial.equiv_or_fuzzy_zero PGame.Impartial.equiv_or_fuzzy_zero
-/

#print PGame.Impartial.not_equiv_zero_iff /-
@[simp]
theorem not_equiv_zero_iff : ¬(G ≈ 0) ↔ G ‖ 0 :=
  ⟨(equiv_or_fuzzy_zero G).resolve_left, Fuzzy.not_equiv⟩
#align pgame.impartial.not_equiv_zero_iff PGame.Impartial.not_equiv_zero_iff
-/

#print PGame.Impartial.not_fuzzy_zero_iff /-
@[simp]
theorem not_fuzzy_zero_iff : ¬G ‖ 0 ↔ (G ≈ 0) :=
  ⟨(equiv_or_fuzzy_zero G).resolve_right, Equiv.not_fuzzy⟩
#align pgame.impartial.not_fuzzy_zero_iff PGame.Impartial.not_fuzzy_zero_iff
-/

#print PGame.Impartial.add_self /-
theorem add_self : G + G ≈ 0 :=
  (add_congr_left (neg_equiv_self G)).trans (add_left_neg_equiv G)
#align pgame.impartial.add_self PGame.Impartial.add_self
-/

#print PGame.Impartial.mk'_add_self /-
@[simp]
theorem mk'_add_self : ⟦G⟧ + ⟦G⟧ = 0 :=
  Quot.sound (add_self G)
#align pgame.impartial.mk_add_self PGame.Impartial.mk'_add_self
-/

#print PGame.Impartial.equiv_iff_add_equiv_zero /-
/-- This lemma doesn't require `H` to be impartial. -/
theorem equiv_iff_add_equiv_zero (H : PGame) : (H ≈ G) ↔ (H + G ≈ 0) := by
  rw [equiv_iff_game_eq, equiv_iff_game_eq, ← @add_right_cancel_iff _ _ _ (-⟦G⟧)]; simpa
#align pgame.impartial.equiv_iff_add_equiv_zero PGame.Impartial.equiv_iff_add_equiv_zero
-/

#print PGame.Impartial.equiv_iff_add_equiv_zero' /-
/-- This lemma doesn't require `H` to be impartial. -/
theorem equiv_iff_add_equiv_zero' (H : PGame) : (G ≈ H) ↔ (G + H ≈ 0) := by
  rw [equiv_iff_game_eq, equiv_iff_game_eq, ← @add_left_cancel_iff _ _ _ (-⟦G⟧), eq_comm]; simpa
#align pgame.impartial.equiv_iff_add_equiv_zero' PGame.Impartial.equiv_iff_add_equiv_zero'
-/

#print PGame.Impartial.le_zero_iff /-
theorem le_zero_iff {G : PGame} [G.Impartial] : G ≤ 0 ↔ 0 ≤ G := by
  rw [← zero_le_neg_iff, le_congr_right (neg_equiv_self G)]
#align pgame.impartial.le_zero_iff PGame.Impartial.le_zero_iff
-/

#print PGame.Impartial.lf_zero_iff /-
theorem lf_zero_iff {G : PGame} [G.Impartial] : G ⧏ 0 ↔ 0 ⧏ G := by
  rw [← zero_lf_neg_iff, lf_congr_right (neg_equiv_self G)]
#align pgame.impartial.lf_zero_iff PGame.Impartial.lf_zero_iff
-/

#print PGame.Impartial.equiv_zero_iff_le /-
theorem equiv_zero_iff_le : (G ≈ 0) ↔ G ≤ 0 :=
  ⟨And.left, fun h => ⟨h, le_zero_iff.1 h⟩⟩
#align pgame.impartial.equiv_zero_iff_le PGame.Impartial.equiv_zero_iff_le
-/

#print PGame.Impartial.fuzzy_zero_iff_lf /-
theorem fuzzy_zero_iff_lf : G ‖ 0 ↔ G ⧏ 0 :=
  ⟨And.left, fun h => ⟨h, lf_zero_iff.1 h⟩⟩
#align pgame.impartial.fuzzy_zero_iff_lf PGame.Impartial.fuzzy_zero_iff_lf
-/

#print PGame.Impartial.equiv_zero_iff_ge /-
theorem equiv_zero_iff_ge : (G ≈ 0) ↔ 0 ≤ G :=
  ⟨And.right, fun h => ⟨le_zero_iff.2 h, h⟩⟩
#align pgame.impartial.equiv_zero_iff_ge PGame.Impartial.equiv_zero_iff_ge
-/

#print PGame.Impartial.fuzzy_zero_iff_gf /-
theorem fuzzy_zero_iff_gf : G ‖ 0 ↔ 0 ⧏ G :=
  ⟨And.right, fun h => ⟨lf_zero_iff.2 h, h⟩⟩
#align pgame.impartial.fuzzy_zero_iff_gf PGame.Impartial.fuzzy_zero_iff_gf
-/

#print PGame.Impartial.forall_leftMoves_fuzzy_iff_equiv_zero /-
theorem forall_leftMoves_fuzzy_iff_equiv_zero : (∀ i, G.moveLeft i ‖ 0) ↔ (G ≈ 0) :=
  by
  refine' ⟨fun hb => _, fun hp i => _⟩
  · rw [equiv_zero_iff_le G, le_zero_lf]
    exact fun i => (hb i).1
  · rw [fuzzy_zero_iff_lf]
    exact hp.1.moveLeft_lf i
#align pgame.impartial.forall_left_moves_fuzzy_iff_equiv_zero PGame.Impartial.forall_leftMoves_fuzzy_iff_equiv_zero
-/

#print PGame.Impartial.forall_rightMoves_fuzzy_iff_equiv_zero /-
theorem forall_rightMoves_fuzzy_iff_equiv_zero : (∀ j, G.moveRight j ‖ 0) ↔ (G ≈ 0) :=
  by
  refine' ⟨fun hb => _, fun hp i => _⟩
  · rw [equiv_zero_iff_ge G, zero_le_lf]
    exact fun i => (hb i).2
  · rw [fuzzy_zero_iff_gf]
    exact hp.2.lf_moveRight i
#align pgame.impartial.forall_right_moves_fuzzy_iff_equiv_zero PGame.Impartial.forall_rightMoves_fuzzy_iff_equiv_zero
-/

#print PGame.Impartial.exists_left_move_equiv_iff_fuzzy_zero /-
theorem exists_left_move_equiv_iff_fuzzy_zero : (∃ i, G.moveLeft i ≈ 0) ↔ G ‖ 0 :=
  by
  refine' ⟨fun ⟨i, hi⟩ => (fuzzy_zero_iff_gf G).2 (lf_of_le_move_left hi.2), fun hn => _⟩
  rw [fuzzy_zero_iff_gf G, zero_lf_le] at hn 
  cases' hn with i hi
  exact ⟨i, (equiv_zero_iff_ge _).2 hi⟩
#align pgame.impartial.exists_left_move_equiv_iff_fuzzy_zero PGame.Impartial.exists_left_move_equiv_iff_fuzzy_zero
-/

#print PGame.Impartial.exists_right_move_equiv_iff_fuzzy_zero /-
theorem exists_right_move_equiv_iff_fuzzy_zero : (∃ j, G.moveRight j ≈ 0) ↔ G ‖ 0 :=
  by
  refine' ⟨fun ⟨i, hi⟩ => (fuzzy_zero_iff_lf G).2 (lf_of_move_right_le hi.1), fun hn => _⟩
  rw [fuzzy_zero_iff_lf G, lf_zero_le] at hn 
  cases' hn with i hi
  exact ⟨i, (equiv_zero_iff_le _).2 hi⟩
#align pgame.impartial.exists_right_move_equiv_iff_fuzzy_zero PGame.Impartial.exists_right_move_equiv_iff_fuzzy_zero
-/

end Impartial

end PGame

