/-
Copyright (c) 2020 Fox Thomson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Fox Thomson

! This file was ported from Lean 3 source module computability.NFA
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Computability.DFA
import Mathbin.Data.Fintype.Powerset

/-!
# Nondeterministic Finite Automata

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
This file contains the definition of a Nondeterministic Finite Automaton (NFA), a state machine
which determines whether a string (implemented as a list over an arbitrary alphabet) is in a regular
set by evaluating the string over every possible path.
We show that DFA's are equivalent to NFA's however the construction from NFA to DFA uses an
exponential number of states.
Note that this definition allows for Automaton with infinite states, a `fintype` instance must be
supplied for true NFA's.
-/


open Set

open scoped Computability

universe u v

#print NFA /-
/-- An NFA is a set of states (`σ`), a transition function from state to state labelled by the
  alphabet (`step`), a starting state (`start`) and a set of acceptance states (`accept`).
  Note the transition function sends a state to a `set` of states. These are the states that it
  may be sent to. -/
structure NFA (α : Type u) (σ : Type v) where
  step : σ → α → Set σ
  start : Set σ
  accept : Set σ
#align NFA NFA
-/

variable {α : Type u} {σ σ' : Type v} (M : NFA α σ)

namespace NFA

instance : Inhabited (NFA α σ) :=
  ⟨NFA.mk (fun _ _ => ∅) ∅ ∅⟩

#print NFA.stepSet /-
/-- `M.step_set S a` is the union of `M.step s a` for all `s ∈ S`. -/
def stepSet (S : Set σ) (a : α) : Set σ :=
  ⋃ s ∈ S, M.step s a
#align NFA.step_set NFA.stepSet
-/

#print NFA.mem_stepSet /-
theorem mem_stepSet (s : σ) (S : Set σ) (a : α) : s ∈ M.stepSet S a ↔ ∃ t ∈ S, s ∈ M.step t a :=
  mem_iUnion₂
#align NFA.mem_step_set NFA.mem_stepSet
-/

#print NFA.stepSet_empty /-
@[simp]
theorem stepSet_empty (a : α) : M.stepSet ∅ a = ∅ := by simp_rw [step_set, Union_false, Union_empty]
#align NFA.step_set_empty NFA.stepSet_empty
-/

#print NFA.evalFrom /-
/-- `M.eval_from S x` computes all possible paths though `M` with input `x` starting at an element
  of `S`. -/
def evalFrom (start : Set σ) : List α → Set σ :=
  List.foldl M.stepSet start
#align NFA.eval_from NFA.evalFrom
-/

#print NFA.evalFrom_nil /-
@[simp]
theorem evalFrom_nil (S : Set σ) : M.evalFrom S [] = S :=
  rfl
#align NFA.eval_from_nil NFA.evalFrom_nil
-/

#print NFA.evalFrom_singleton /-
@[simp]
theorem evalFrom_singleton (S : Set σ) (a : α) : M.evalFrom S [a] = M.stepSet S a :=
  rfl
#align NFA.eval_from_singleton NFA.evalFrom_singleton
-/

#print NFA.evalFrom_append_singleton /-
@[simp]
theorem evalFrom_append_singleton (S : Set σ) (x : List α) (a : α) :
    M.evalFrom S (x ++ [a]) = M.stepSet (M.evalFrom S x) a := by
  simp only [eval_from, List.foldl_append, List.foldl_cons, List.foldl_nil]
#align NFA.eval_from_append_singleton NFA.evalFrom_append_singleton
-/

#print NFA.eval /-
/-- `M.eval x` computes all possible paths though `M` with input `x` starting at an element of
  `M.start`. -/
def eval : List α → Set σ :=
  M.evalFrom M.start
#align NFA.eval NFA.eval
-/

#print NFA.eval_nil /-
@[simp]
theorem eval_nil : M.eval [] = M.start :=
  rfl
#align NFA.eval_nil NFA.eval_nil
-/

#print NFA.eval_singleton /-
@[simp]
theorem eval_singleton (a : α) : M.eval [a] = M.stepSet M.start a :=
  rfl
#align NFA.eval_singleton NFA.eval_singleton
-/

#print NFA.eval_append_singleton /-
@[simp]
theorem eval_append_singleton (x : List α) (a : α) : M.eval (x ++ [a]) = M.stepSet (M.eval x) a :=
  evalFrom_append_singleton _ _ _ _
#align NFA.eval_append_singleton NFA.eval_append_singleton
-/

#print NFA.accepts /-
/-- `M.accepts` is the language of `x` such that there is an accept state in `M.eval x`. -/
def accepts : Language α := fun x => ∃ S ∈ M.accept, S ∈ M.eval x
#align NFA.accepts NFA.accepts
-/

#print NFA.toDFA /-
/-- `M.to_DFA` is an `DFA` constructed from a `NFA` `M` using the subset construction. The
  states is the type of `set`s of `M.state` and the step function is `M.step_set`. -/
def toDFA : DFA α (Set σ) where
  step := M.stepSet
  start := M.start
  accept := {S | ∃ s ∈ S, s ∈ M.accept}
#align NFA.to_DFA NFA.toDFA
-/

#print NFA.toDFA_correct /-
@[simp]
theorem toDFA_correct : M.toDFA.accepts = M.accepts :=
  by
  ext x
  rw [accepts, DFA.accepts, eval, DFA.eval]
  change List.foldl _ _ _ ∈ {S | _} ↔ _
  constructor <;> · exact fun ⟨w, h2, h3⟩ => ⟨w, h3, h2⟩
#align NFA.to_DFA_correct NFA.toDFA_correct
-/

#print NFA.pumping_lemma /-
theorem pumping_lemma [Fintype σ] {x : List α} (hx : x ∈ M.accepts)
    (hlen : Fintype.card (Set σ) ≤ List.length x) :
    ∃ a b c,
      x = a ++ b ++ c ∧
        a.length + b.length ≤ Fintype.card (Set σ) ∧ b ≠ [] ∧ {a} * {b}∗ * {c} ≤ M.accepts :=
  by
  rw [← to_DFA_correct] at hx ⊢
  exact M.to_DFA.pumping_lemma hx hlen
#align NFA.pumping_lemma NFA.pumping_lemma
-/

end NFA

namespace DFA

#print DFA.toNFA /-
/-- `M.to_NFA` is an `NFA` constructed from a `DFA` `M` by using the same start and accept
  states and a transition function which sends `s` with input `a` to the singleton `M.step s a`. -/
def toNFA (M : DFA α σ') : NFA α σ'
    where
  step s a := {M.step s a}
  start := {M.start}
  accept := M.accept
#align DFA.to_NFA DFA.toNFA
-/

#print DFA.toNFA_evalFrom_match /-
@[simp]
theorem toNFA_evalFrom_match (M : DFA α σ) (start : σ) (s : List α) :
    M.toNFA.evalFrom {start} s = {M.evalFrom start s} :=
  by
  change List.foldl M.to_NFA.step_set {start} s = {List.foldl M.step start s}
  induction' s with a s ih generalizing start
  · tauto
  · rw [List.foldl, List.foldl,
      show M.to_NFA.step_set {start} a = {M.step start a} by simpa [NFA.stepSet]]
    tauto
#align DFA.to_NFA_eval_from_match DFA.toNFA_evalFrom_match
-/

#print DFA.toNFA_correct /-
@[simp]
theorem toNFA_correct (M : DFA α σ) : M.toNFA.accepts = M.accepts :=
  by
  ext x
  change (∃ S H, S ∈ M.to_NFA.eval_from {M.start} x) ↔ _
  rw [to_NFA_eval_from_match]
  constructor
  · rintro ⟨S, hS₁, hS₂⟩
    rwa [set.mem_singleton_iff.mp hS₂] at hS₁ 
  · exact fun h => ⟨M.eval x, h, rfl⟩
#align DFA.to_NFA_correct DFA.toNFA_correct
-/

end DFA

