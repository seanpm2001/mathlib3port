/-
Copyright (c) 2019 Seul Baek. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Seul Baek

! This file was ported from Lean 3 source module tactic.omega.find_scalars
! leanprover-community/mathlib commit 58581d0fe523063f5651df0619be2bf65012a94a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Tactic.Omega.Term
import Mathbin.Data.List.MinMax

/-
Tactic for performing Fourier–Motzkin elimination to find
a contradictory linear combination of input constraints.
-/
open List.Func

namespace Omega

/-- Divide linear combinations into three groups by the coefficient of the
    `m`th variable in their resultant terms: negative, zero, or positive. -/
unsafe def trisect (m : Nat) :
    List (List Nat × Term) →
      List (List Nat × Term) × List (List Nat × Term) × List (List Nat × Term)
  | [] => ([], [], [])
  | (p, t) :: pts =>
    let (neg, zero, Pos) := trisect pts
    if get m t.snd < 0 then ((p, t) :: neg, zero, Pos)
    else if get m t.snd = 0 then (neg, (p, t) :: zero, Pos) else (neg, zero, (p, t) :: Pos)
#align omega.trisect omega.trisect

/-- Use two linear combinations to obtain a third linear combination
    whose resultant term does not include the `m`th variable. -/
unsafe def elim_var_aux (m : Nat) : (List Nat × Term) × List Nat × Term → tactic (List Nat × Term)
  | ((p1, t1), (p2, t2)) =>
    let n := Int.natAbs (get m t1.snd)
    let o := Int.natAbs (get m t2.snd)
    let lcm := Nat.lcm n o
    let n' := lcm / n
    let o' := lcm / o
    return (add (p1.map ((· * ·) n')) (p2.map ((· * ·) o')), Term.add (t1.mul n') (t2.mul o'))
#align omega.elim_var_aux omega.elim_var_aux

/-- Use two lists of linear combinations (one in which the resultant terms
    include occurrences of the `m`th variable with positive coefficients,
    and one with negative coefficients) and linearly combine them in every
    possible way that eliminates the `m`th variable. -/
unsafe def elim_var (m : Nat) (neg pos : List (List Nat × Term)) :
    tactic (List (List Nat × Term)) :=
  let pairs := List.product neg Pos
  Monad.mapM (elim_var_aux m) pairs
#align omega.elim_var omega.elim_var

/-- Search through a list of (linear combination × resultant term) pairs,
    find the first pair whose resultant term has a negative constant term,
    and return its linear combination -/
unsafe def find_neg_const : List (List Nat × Term) → tactic (List Nat)
  | [] => tactic.failed
  | (π, ⟨c, _⟩) :: l => if c < 0 then return π else find_neg_const l
#align omega.find_neg_const omega.find_neg_const

/-- First, eliminate all variables by Fourier–Motzkin elimination.
    When all variables have been eliminated, find and return the
    linear combination which produces a constraint of the form
    `0 < k + t` such that `k` is the constant term of the RHS and `k < 0`. -/
unsafe def find_scalars_core : Nat → List (List Nat × Term) → tactic (List Nat)
  | 0, pts => find_neg_const pts
  | m + 1, pts =>
    let (neg, zero, Pos) := trisect m pts
    do
    let new ← elim_var m neg Pos
    find_scalars_core m (new ++ zero)
#align omega.find_scalars_core omega.find_scalars_core

/-- Perform Fourier–Motzkin elimination to find a contradictory
    linear combination of input constraints. -/
unsafe def find_scalars (ts : List Term) : tactic (List Nat) :=
  find_scalars_core (ts.map fun t : Term => t.snd.length).maximum.iget
    (ts.mapIdx fun m t => (List.Func.set 1 [] m, t))
#align omega.find_scalars omega.find_scalars

end Omega

