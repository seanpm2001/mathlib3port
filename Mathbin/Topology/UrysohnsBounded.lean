/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module topology.urysohns_bounded
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.UrysohnsLemma
import Mathbin.Topology.ContinuousFunction.Bounded

/-!
# Urysohn's lemma for bounded continuous functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we reformulate Urysohn's lemma `exists_continuous_zero_one_of_closed` in terms of
bounded continuous functions `X →ᵇ ℝ`. These lemmas live in a separate file because
`topology.continuous_function.bounded` imports too many other files.

## Tags

Urysohn's lemma, normal topological space
-/


open scoped BoundedContinuousFunction

open Set Function

#print exists_bounded_zero_one_of_closed /-
/-- Urysohns lemma: if `s` and `t` are two disjoint closed sets in a normal topological space `X`,
then there exists a continuous function `f : X → ℝ` such that

* `f` equals zero on `s`;
* `f` equals one on `t`;
* `0 ≤ f x ≤ 1` for all `x`.
-/
theorem exists_bounded_zero_one_of_closed {X : Type _} [TopologicalSpace X] [NormalSpace X]
    {s t : Set X} (hs : IsClosed s) (ht : IsClosed t) (hd : Disjoint s t) :
    ∃ f : X →ᵇ ℝ, EqOn f 0 s ∧ EqOn f 1 t ∧ ∀ x, f x ∈ Icc (0 : ℝ) 1 :=
  let ⟨f, hfs, hft, hf⟩ := exists_continuous_zero_one_of_closed hs ht hd
  ⟨⟨f, 1, fun x y => Real.dist_le_of_mem_Icc_01 (hf _) (hf _)⟩, hfs, hft, hf⟩
#align exists_bounded_zero_one_of_closed exists_bounded_zero_one_of_closed
-/

#print exists_bounded_mem_Icc_of_closed_of_le /-
/-- Urysohns lemma: if `s` and `t` are two disjoint closed sets in a normal topological space `X`,
and `a ≤ b` are two real numbers, then there exists a continuous function `f : X → ℝ` such that

* `f` equals `a` on `s`;
* `f` equals `b` on `t`;
* `a ≤ f x ≤ b` for all `x`.
-/
theorem exists_bounded_mem_Icc_of_closed_of_le {X : Type _} [TopologicalSpace X] [NormalSpace X]
    {s t : Set X} (hs : IsClosed s) (ht : IsClosed t) (hd : Disjoint s t) {a b : ℝ} (hle : a ≤ b) :
    ∃ f : X →ᵇ ℝ, EqOn f (const X a) s ∧ EqOn f (const X b) t ∧ ∀ x, f x ∈ Icc a b :=
  let ⟨f, hfs, hft, hf01⟩ := exists_bounded_zero_one_of_closed hs ht hd
  ⟨BoundedContinuousFunction.const X a + (b - a) • f, fun x hx => by simp [hfs hx], fun x hx => by
    simp [hft hx], fun x =>
    ⟨by dsimp <;> nlinarith [(hf01 x).1], by dsimp <;> nlinarith [(hf01 x).2]⟩⟩
#align exists_bounded_mem_Icc_of_closed_of_le exists_bounded_mem_Icc_of_closed_of_le
-/

