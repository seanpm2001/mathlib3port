/-
Copyright (c) 2021 Yakov Pechersky All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yakov Pechersky

! This file was ported from Lean 3 source module tactic.norm_swap
! leanprover-community/mathlib commit 9407b03373c8cd201df99d6bc5514fc2db44054f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Equiv.Defs
import Mathbin.Tactic.NormFin

/-!
# `norm_swap`

Evaluating `swap x y z` for numerals `x y z` that are `ℕ`, `ℤ`, or `ℚ`, via a `norm_num` plugin.
Terms are passed to `eval`, quickly failing if not of the form `swap x y z`.
The expressions for numerals `x y z` are converted to `nat`, and then compared.
Based on equality of these `nat`s, equality proofs are generated using either
`equiv.swap_apply_left`, `equiv.swap_apply_right`, or `swap_apply_of_ne_of_ne`.
-/


open Equiv Tactic Expr

open NormNum

namespace NormSwap

/-- A `norm_num` plugin for normalizing `equiv.swap a b c`
where `a b c` are numerals of `ℕ`, `ℤ`, `ℚ` or `fin n`.

```
example : equiv.swap 1 2 1 = 2 := by norm_num
```
-/
@[norm_num]
unsafe def eval : expr → tactic (expr × expr) := fun e => do
  let (swapt, fun_ty, coe_fn_inst, fexpr, c) ←
    e.match_app_coe_fn <|> fail "did not get an app coe_fn expr"
  guard (fexpr = `` Equiv.swap) <|> fail "coe_fn not of equiv.swap"
  let [α, deceq_inst, a, b] ←
    pure fexpr.get_app_args <|> fail "swap did not have exactly two args applied"
  let na ←
    a.to_rat <|> do
        let (fa, _) ← norm_fin.eval_fin_num a
        fa
  let nb ←
    b.to_rat <|> do
        let (fb, _) ← norm_fin.eval_fin_num b
        fb
  let nc ←
    c.to_rat <|> do
        let (fc, _) ← norm_fin.eval_fin_num c
        fc
  if nc = na then do
      let p ← mk_mapp `equiv.swap_apply_left [α, deceq_inst, a, b]
      pure (b, p)
    else
      if nc = nb then do
        let p ← mk_mapp `equiv.swap_apply_right [α, deceq_inst, a, b]
        pure (a, p)
      else do
        let nic ← mk_instance_cache α
        let hca ←
          Prod.snd <$> prove_ne nic c a nc na <|> do
              let (_, ff, p) ← norm_fin.prove_eq_ne_fin c a
              pure p
        let hcb ←
          Prod.snd <$> prove_ne nic c b nc nb <|> do
              let (_, ff, p) ← norm_fin.prove_eq_ne_fin c b
              pure p
        let p ← mk_mapp `equiv.swap_apply_of_ne_of_ne [α, deceq_inst, a, b, c, hca, hcb]
        pure (c, p)
#align norm_swap.eval norm_swap.eval

end NormSwap

