/-
Copyright (c) 2022 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module data.fin.tuple.monotone
! leanprover-community/mathlib commit a11f9106a169dd302a285019e5165f8ab32ff433
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Fin.VecNotation

/-!
# Monotone finite sequences

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove `simp` lemmas that allow to simplify propositions like `monotone ![a, b, c]`.
-/


open Set Fin Matrix Function

variable {α : Type _}

#print liftFun_vecCons /-
theorem liftFun_vecCons {n : ℕ} (r : α → α → Prop) [IsTrans α r] {f : Fin (n + 1) → α} {a : α} :
    ((· < ·) ⇒ r) (vecCons a f) (vecCons a f) ↔ r a (f 0) ∧ ((· < ·) ⇒ r) f f := by
  simp only [lift_fun_iff_succ r, forall_fin_succ, cons_val_succ, cons_val_zero, ← succ_cast_succ,
    cast_succ_zero]
#align lift_fun_vec_cons liftFun_vecCons
-/

variable [Preorder α] {n : ℕ} {f : Fin (n + 1) → α} {a : α}

#print strictMono_vecCons /-
@[simp]
theorem strictMono_vecCons : StrictMono (vecCons a f) ↔ a < f 0 ∧ StrictMono f :=
  liftFun_vecCons (· < ·)
#align strict_mono_vec_cons strictMono_vecCons
-/

#print monotone_vecCons /-
@[simp]
theorem monotone_vecCons : Monotone (vecCons a f) ↔ a ≤ f 0 ∧ Monotone f := by
  simpa only [monotone_iff_forall_lt] using @liftFun_vecCons α n (· ≤ ·) _ f a
#align monotone_vec_cons monotone_vecCons
-/

#print strictAnti_vecCons /-
@[simp]
theorem strictAnti_vecCons : StrictAnti (vecCons a f) ↔ f 0 < a ∧ StrictAnti f :=
  liftFun_vecCons (· > ·)
#align strict_anti_vec_cons strictAnti_vecCons
-/

#print antitone_vecCons /-
@[simp]
theorem antitone_vecCons : Antitone (vecCons a f) ↔ f 0 ≤ a ∧ Antitone f :=
  @monotone_vecCons αᵒᵈ _ _ _ _
#align antitone_vec_cons antitone_vecCons
-/

#print StrictMono.vecCons /-
theorem StrictMono.vecCons (hf : StrictMono f) (ha : a < f 0) : StrictMono (vecCons a f) :=
  strictMono_vecCons.2 ⟨ha, hf⟩
#align strict_mono.vec_cons StrictMono.vecCons
-/

#print StrictAnti.vecCons /-
theorem StrictAnti.vecCons (hf : StrictAnti f) (ha : f 0 < a) : StrictAnti (vecCons a f) :=
  strictAnti_vecCons.2 ⟨ha, hf⟩
#align strict_anti.vec_cons StrictAnti.vecCons
-/

#print Monotone.vecCons /-
theorem Monotone.vecCons (hf : Monotone f) (ha : a ≤ f 0) : Monotone (vecCons a f) :=
  monotone_vecCons.2 ⟨ha, hf⟩
#align monotone.vec_cons Monotone.vecCons
-/

#print Antitone.vecCons /-
theorem Antitone.vecCons (hf : Antitone f) (ha : f 0 ≤ a) : Antitone (vecCons a f) :=
  antitone_vecCons.2 ⟨ha, hf⟩
#align antitone.vec_cons Antitone.vecCons
-/

example : Monotone ![1, 2, 2, 3] := by simp [Subsingleton.monotone]

