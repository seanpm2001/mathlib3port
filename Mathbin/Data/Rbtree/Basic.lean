/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura

! This file was ported from Lean 3 source module data.rbtree.basic
! leanprover-community/mathlib commit 5cb17dd1617d2dc55eb17777c3dcded3306fadb5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Rbtree.Init
import Mathbin.Logic.IsEmpty
import Mathbin.Tactic.Interactive

universe u

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
unsafe def tactic.interactive.blast_disjs : tactic Unit :=
  sorry
#align tactic.interactive.blast_disjs tactic.interactive.blast_disjs

namespace Std.RBNode

variable {α : Type u}

open Color Nat

inductive Std.RBNode.IsNodeOf : Std.RBNode α → Std.RBNode α → α → Std.RBNode α → Prop
  | of_red (l v r) : is_node_of (Std.RBNode.node l v r) l v r
  | of_black (l v r) : is_node_of (black_node l v r) l v r
#align rbnode.is_node_of Std.RBNode.IsNodeOf

def Std.RBNode.Lift (lt : α → α → Prop) : Option α → Option α → Prop
  | some a, some b => lt a b
  | _, _ => True
#align rbnode.lift Std.RBNode.Lift

inductive Std.RBNode.IsSearchable (lt : α → α → Prop) : Std.RBNode α → Option α → Option α → Prop
  | leaf_s {lo hi} (hlt : Std.RBNode.Lift lt lo hi) : is_searchable Std.RBNode.nil lo hi
  |
  red_s {l r v lo hi} (hs₁ : is_searchable l lo (some v)) (hs₂ : is_searchable r (some v) hi) :
    is_searchable (Std.RBNode.node l v r) lo hi
  |
  black_s {l r v lo hi} (hs₁ : is_searchable l lo (some v)) (hs₂ : is_searchable r (some v) hi) :
    is_searchable (black_node l v r) lo hi
#align rbnode.is_searchable Std.RBNode.IsSearchable

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
unsafe def is_searchable_tactic : tactic Unit :=
  sorry
#align rbnode.is_searchable_tactic rbnode.is_searchable_tactic

open Std.RBNode (Mem)

open IsSearchable

section IsSearchableLemmas

variable {lt : α → α → Prop}

theorem Std.RBNode.lo_lt_hi {t : Std.RBNode α} {lt} [IsTrans α lt] :
    ∀ {lo hi}, Std.RBNode.IsSearchable lt t lo hi → Std.RBNode.Lift lt lo hi :=
  by
  induction t <;> intro lo hi hs
  case leaf => cases hs; assumption
  all_goals
    cases hs
    have h₁ := t_ih_lchild hs_hs₁
    have h₂ := t_ih_rchild hs_hs₂
    cases lo <;> cases hi <;> simp [lift] at *
    apply trans_of lt h₁ h₂
#align rbnode.lo_lt_hi Std.RBNode.lo_lt_hi

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic rbnode.is_searchable_tactic -/
theorem Std.RBNode.isSearchableOfIsSearchableOfIncomp [IsStrictWeakOrder α lt] {t} :
    ∀ {lo hi hi'} (hc : ¬lt hi' hi ∧ ¬lt hi hi') (hs : Std.RBNode.IsSearchable lt t lo (some hi)),
      Std.RBNode.IsSearchable lt t lo (some hi') :=
  by
  classical
  induction t <;> intros <;>
    run_tac
      is_searchable_tactic
  · cases lo <;> simp_all [lift]; apply lt_of_lt_of_incomp; assumption; exact ⟨hc.2, hc.1⟩
  all_goals apply t_ih_rchild hc hs_hs₂
#align rbnode.is_searchable_of_is_searchable_of_incomp Std.RBNode.isSearchableOfIsSearchableOfIncomp

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic rbnode.is_searchable_tactic -/
theorem Std.RBNode.isSearchableOfIncompOfIsSearchable [IsStrictWeakOrder α lt] {t} :
    ∀ {lo lo' hi} (hc : ¬lt lo' lo ∧ ¬lt lo lo') (hs : Std.RBNode.IsSearchable lt t (some lo) hi),
      Std.RBNode.IsSearchable lt t (some lo') hi :=
  by
  classical
  induction t <;> intros <;>
    run_tac
      is_searchable_tactic
  · cases hi <;> simp_all [lift]; apply lt_of_incomp_of_lt; assumption; assumption
  all_goals apply t_ih_lchild hc hs_hs₁
#align rbnode.is_searchable_of_incomp_of_is_searchable Std.RBNode.isSearchableOfIncompOfIsSearchable

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic rbnode.is_searchable_tactic -/
theorem Std.RBNode.isSearchableSomeLowOfIsSearchableOfLt {t} [IsTrans α lt] :
    ∀ {lo hi lo'} (hlt : lt lo' lo) (hs : Std.RBNode.IsSearchable lt t (some lo) hi),
      Std.RBNode.IsSearchable lt t (some lo') hi :=
  by
  induction t <;> intros <;>
    run_tac
      is_searchable_tactic
  · cases hi <;> simp_all [lift]; apply trans_of lt hlt; assumption
  all_goals apply t_ih_lchild hlt hs_hs₁
#align rbnode.is_searchable_some_low_of_is_searchable_of_lt Std.RBNode.isSearchableSomeLowOfIsSearchableOfLt

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic rbnode.is_searchable_tactic -/
theorem Std.RBNode.isSearchableNoneLowOfIsSearchableSomeLow {t} :
    ∀ {y hi} (hlt : Std.RBNode.IsSearchable lt t (some y) hi),
      Std.RBNode.IsSearchable lt t none hi :=
  by
  induction t <;> intros <;>
    run_tac
      is_searchable_tactic
  · simp [lift]
  all_goals apply t_ih_lchild hlt_hs₁
#align rbnode.is_searchable_none_low_of_is_searchable_some_low Std.RBNode.isSearchableNoneLowOfIsSearchableSomeLow

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic rbnode.is_searchable_tactic -/
theorem Std.RBNode.isSearchableSomeHighOfIsSearchableOfLt {t} [IsTrans α lt] :
    ∀ {lo hi hi'} (hlt : lt hi hi') (hs : Std.RBNode.IsSearchable lt t lo (some hi)),
      Std.RBNode.IsSearchable lt t lo (some hi') :=
  by
  induction t <;> intros <;>
    run_tac
      is_searchable_tactic
  · cases lo <;> simp_all [lift]; apply trans_of lt; assumption; assumption
  all_goals apply t_ih_rchild hlt hs_hs₂
#align rbnode.is_searchable_some_high_of_is_searchable_of_lt Std.RBNode.isSearchableSomeHighOfIsSearchableOfLt

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic rbnode.is_searchable_tactic -/
theorem Std.RBNode.isSearchableNoneHighOfIsSearchableSomeHigh {t} :
    ∀ {lo y} (hlt : Std.RBNode.IsSearchable lt t lo (some y)),
      Std.RBNode.IsSearchable lt t lo none :=
  by
  induction t <;> intros <;>
    run_tac
      is_searchable_tactic
  · cases lo <;> simp [lift]
  all_goals apply t_ih_rchild hlt_hs₂
#align rbnode.is_searchable_none_high_of_is_searchable_some_high Std.RBNode.isSearchableNoneHighOfIsSearchableSomeHigh

theorem Std.RBNode.range [IsStrictWeakOrder α lt] {t : Std.RBNode α} {x} :
    ∀ {lo hi},
      Std.RBNode.IsSearchable lt t lo hi →
        Std.RBNode.Mem lt x t → Std.RBNode.Lift lt lo (some x) ∧ Std.RBNode.Lift lt (some x) hi :=
  by
  classical
  induction t
  case leaf => simp [mem]
  all_goals
    -- red_node and black_node are identical
    intro lo hi h₁ h₂;
    cases h₁
    simp only [mem] at h₂ 
    have val_hi : lift lt (some t_val) hi := by apply lo_lt_hi; assumption
    have lo_val : lift lt lo (some t_val) := by apply lo_lt_hi; assumption
    cases_type* or.1
    · have h₃ : lift lt lo (some x) ∧ lift lt (some x) (some t_val) := by apply t_ih_lchild;
        assumption; assumption
      cases' h₃ with lo_x x_val
      constructor
      show lift lt lo (some x); · assumption
      show lift lt (some x) hi
      · cases' hi with hi <;> simp [lift] at *
        apply trans_of lt x_val val_hi
    · cases h₂
      cases' lo with lo <;> cases' hi with hi <;> simp [lift] at *
      · apply lt_of_incomp_of_lt _ val_hi; simp [*]
      · apply lt_of_lt_of_incomp lo_val; simp [*]
      constructor
      · apply lt_of_lt_of_incomp lo_val; simp [*]
      · apply lt_of_incomp_of_lt _ val_hi; simp [*]
    · have h₃ : lift lt (some t_val) (some x) ∧ lift lt (some x) hi := by apply t_ih_rchild;
        assumption; assumption
      cases' h₃ with val_x x_hi
      cases' lo with lo <;> cases' hi with hi <;> simp [lift] at *
      · assumption
      · apply trans_of lt lo_val val_x
      constructor
      · apply trans_of lt lo_val val_x
      · assumption
#align rbnode.range Std.RBNode.range

theorem Std.RBNode.ltOfMemLeft [IsStrictWeakOrder α lt] {y : α} {t l r : Std.RBNode α} :
    ∀ {lo hi},
      Std.RBNode.IsSearchable lt t lo hi →
        Std.RBNode.IsNodeOf t l y r → ∀ {x}, Std.RBNode.Mem lt x l → lt x y :=
  by
  intro _ _ hs hn x hm; cases hn <;> cases hs
  all_goals exact (range hs_hs₁ hm).2
#align rbnode.lt_of_mem_left Std.RBNode.ltOfMemLeft

theorem Std.RBNode.ltOfMemRight [IsStrictWeakOrder α lt] {y : α} {t l r : Std.RBNode α} :
    ∀ {lo hi},
      Std.RBNode.IsSearchable lt t lo hi →
        Std.RBNode.IsNodeOf t l y r → ∀ {z}, Std.RBNode.Mem lt z r → lt y z :=
  by
  intro _ _ hs hn z hm; cases hn <;> cases hs
  all_goals exact (range hs_hs₂ hm).1
#align rbnode.lt_of_mem_right Std.RBNode.ltOfMemRight

theorem Std.RBNode.ltOfMemLeftRight [IsStrictWeakOrder α lt] {y : α} {t l r : Std.RBNode α} :
    ∀ {lo hi},
      Std.RBNode.IsSearchable lt t lo hi →
        Std.RBNode.IsNodeOf t l y r →
          ∀ {x z}, Std.RBNode.Mem lt x l → Std.RBNode.Mem lt z r → lt x z :=
  by
  intro _ _ hs hn x z hm₁ hm₂; cases hn <;> cases hs
  all_goals
    have h₁ := range hs_hs₁ hm₁
    have h₂ := range hs_hs₂ hm₂
    exact trans_of lt h₁.2 h₂.1
#align rbnode.lt_of_mem_left_right Std.RBNode.ltOfMemLeftRight

end IsSearchableLemmas

inductive Std.RBNode.IsRedBlack : Std.RBNode α → RBColor → Nat → Prop
  | leaf_rb : is_red_black Std.RBNode.nil black 0
  |
  red_rb {v l r n} (rb_l : is_red_black l black n) (rb_r : is_red_black r black n) :
    is_red_black (Std.RBNode.node l v r) red n
  |
  black_rb {v l r n c₁ c₂} (rb_l : is_red_black l c₁ n) (rb_r : is_red_black r c₂ n) :
    is_red_black (black_node l v r) black (succ n)
#align rbnode.is_red_black Std.RBNode.IsRedBlack

open IsRedBlack

theorem Std.RBNode.depth_min :
    ∀ {c n} {t : Std.RBNode α}, Std.RBNode.IsRedBlack t c n → n ≤ Std.RBNode.depth min t :=
  by
  intro c n' t h
  induction h
  case leaf_rb => exact le_refl _
  case red_rb =>
    simp [depth]
    have : min (depth min h_l) (depth min h_r) ≥ h_n := by apply le_min <;> assumption
    apply le_succ_of_le; assumption
  case black_rb =>
    simp [depth]
    apply succ_le_succ
    apply le_min <;> assumption
#align rbnode.depth_min Std.RBNode.depth_min

private def upper : RBColor → Nat → Nat
  | red, n => 2 * n + 1
  | black, n => 2 * n

private theorem upper_le : ∀ c n, upper c n ≤ 2 * n + 1
  | red, n => le_refl _
  | black, n => by apply le_succ

theorem Std.RBNode.depth_max' :
    ∀ {c n} {t : Std.RBNode α}, Std.RBNode.IsRedBlack t c n → Std.RBNode.depth max t ≤ upper c n :=
  by
  intro c n' t h
  induction h
  case leaf_rb => simp [max, depth, upper, Nat.mul_zero]
  case
    red_rb =>
    suffices succ (max (depth max h_l) (depth max h_r)) ≤ 2 * h_n + 1 by simp_all [depth, upper]
    apply succ_le_succ
    apply max_le <;> assumption
  case
    black_rb =>
    have : depth max h_l ≤ 2 * h_n + 1 := le_trans h_ih_rb_l (upper_le _ _)
    have : depth max h_r ≤ 2 * h_n + 1 := le_trans h_ih_rb_r (upper_le _ _)
    suffices new : max (depth max h_l) (depth max h_r) + 1 ≤ 2 * h_n + 2 * 1
    · simp_all [depth, upper, succ_eq_add_one, Nat.left_distrib]
    apply succ_le_succ; apply max_le <;> assumption
#align rbnode.depth_max' Std.RBNode.depth_max'

theorem Std.RBNode.depth_max {c n} {t : Std.RBNode α} (h : Std.RBNode.IsRedBlack t c n) :
    Std.RBNode.depth max t ≤ 2 * n + 1 :=
  le_trans (Std.RBNode.depth_max' h) (upper_le _ _)
#align rbnode.depth_max Std.RBNode.depth_max

theorem Std.RBNode.balanced {c n} {t : Std.RBNode α} (h : Std.RBNode.IsRedBlack t c n) :
    Std.RBNode.depth max t ≤ 2 * Std.RBNode.depth min t + 1 :=
  by
  have : 2 * depth min t + 1 ≥ 2 * n + 1 := by apply succ_le_succ; apply Nat.mul_le_mul_left;
    apply depth_min h
  apply le_trans; apply depth_max h; apply this
#align rbnode.balanced Std.RBNode.balanced

end Std.RBNode

