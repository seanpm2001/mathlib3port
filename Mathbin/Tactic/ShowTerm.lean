/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module tactic.show_term
! leanprover-community/mathlib commit afa534cdfa220967e744b2c39c1006e8aaae423e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Core

open Tactic

namespace Tactic.Interactive

/-- `show_term { tac }` runs the tactic `tac`,
and then prints the term that was constructed.

This is useful for
* constructing term mode proofs from tactic mode proofs, and
* understanding what tactics are doing, and how metavariables are handled.

As an example, in
```
example {P Q R : Prop} (h₁ : Q → P) (h₂ : R) (h₃ : R → Q) : P ∧ R :=
by show_term { tauto }
```
the term mode proof `⟨h₁ (h₃ h₂), eq.mpr rfl h₂⟩` produced by `tauto` will be printed.

As another example, if the goal is `ℕ × ℕ`, `show_term { split, exact 0 }` will
print `refine (0, _)`, and afterwards there will be one remaining goal (of type `ℕ`).
This indicates that `split, exact 0` partially filled in the original metavariable,
but created a new metavariable for the resulting sub-goal.
-/
unsafe def show_term (t : itactic) : itactic := do
  let g :: _ ← get_goals
  t
  let g ← tactic_statement g
  trace g
#align tactic.interactive.show_term tactic.interactive.show_term

add_tactic_doc
  { Name := "show_term"
    category := DocCategory.tactic
    declNames := [`` show_term]
    tags := ["debugging"] }

end Tactic.Interactive

