/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.nat.succ_pred
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fin.Basic
import Mathbin.Order.SuccPred.Basic

/-!
# Successors and predecessors of naturals

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we show that `ℕ` is both an archimedean `succ_order` and an archimedean `pred_order`.
-/


open Function Order

namespace Nat

-- so that Lean reads `nat.succ` through `succ_order.succ`
@[reducible]
instance : SuccOrder ℕ :=
  { SuccOrder.ofSuccLeIff succ fun a b => Iff.rfl with succ := succ }

-- so that Lean reads `nat.pred` through `pred_order.pred`
@[reducible]
instance : PredOrder ℕ where
  pred := pred
  pred_le := pred_le
  min_of_le_pred a ha := by
    cases a
    · exact isMin_bot
    · exact (not_succ_le_self _ ha).elim
  le_pred_of_lt a b h := by
    cases b
    · exact (a.not_lt_zero h).elim
    · exact le_of_succ_le_succ h
  le_of_pred_lt a b h := by
    cases a
    · exact b.zero_le
    · exact h

#print Nat.succ_eq_succ /-
@[simp]
theorem succ_eq_succ : Order.succ = succ :=
  rfl
#align nat.succ_eq_succ Nat.succ_eq_succ
-/

#print Nat.pred_eq_pred /-
@[simp]
theorem pred_eq_pred : Order.pred = pred :=
  rfl
#align nat.pred_eq_pred Nat.pred_eq_pred
-/

#print Nat.succ_iterate /-
theorem succ_iterate (a : ℕ) : ∀ n, (succ^[n]) a = a + n
  | 0 => rfl
  | n + 1 => by rw [Function.iterate_succ', add_succ]; exact congr_arg _ n.succ_iterate
#align nat.succ_iterate Nat.succ_iterate
-/

#print Nat.pred_iterate /-
theorem pred_iterate (a : ℕ) : ∀ n, (pred^[n]) a = a - n
  | 0 => rfl
  | n + 1 => by rw [Function.iterate_succ', sub_succ]; exact congr_arg _ n.pred_iterate
#align nat.pred_iterate Nat.pred_iterate
-/

instance : IsSuccArchimedean ℕ :=
  ⟨fun a b h => ⟨b - a, by rw [succ_eq_succ, succ_iterate, add_tsub_cancel_of_le h]⟩⟩

instance : IsPredArchimedean ℕ :=
  ⟨fun a b h => ⟨b - a, by rw [pred_eq_pred, pred_iterate, tsub_tsub_cancel_of_le h]⟩⟩

/-! ### Covering relation -/


#print Nat.covby_iff_succ_eq /-
protected theorem covby_iff_succ_eq {m n : ℕ} : m ⋖ n ↔ m + 1 = n :=
  succ_eq_iff_covby.symm
#align nat.covby_iff_succ_eq Nat.covby_iff_succ_eq
-/

end Nat

#print Fin.coe_covby_iff /-
@[simp, norm_cast]
theorem Fin.coe_covby_iff {n : ℕ} {a b : Fin n} : (a : ℕ) ⋖ b ↔ a ⋖ b :=
  and_congr_right' ⟨fun h c hc => h hc, fun h c ha hb => @h ⟨c, hb.trans b.Prop⟩ ha hb⟩
#align fin.coe_covby_iff Fin.coe_covby_iff
-/

alias Fin.coe_covby_iff ↔ _ Covby.coe_fin
#align covby.coe_fin Covby.coe_fin

