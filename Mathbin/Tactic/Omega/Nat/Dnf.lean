/-
Copyright (c) 2019 Seul Baek. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Seul Baek

! This file was ported from Lean 3 source module tactic.omega.nat.dnf
! leanprover-community/mathlib commit 402f8982dddc1864bd703da2d6e2ee304a866973
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.ProdSigma
import Mathbin.Tactic.Omega.Clause
import Mathbin.Tactic.Omega.Nat.Form

/-!
# DNF transformation
-/


namespace Omega

namespace Nat

open scoped Omega.Nat

@[simp]
def dnfCore : Preform → List Clause
  | p ∨* q => dnf_core p ++ dnf_core q
  | p ∧* q => (List.product (dnf_core p) (dnf_core q)).map fun pq => Clause.append pq.fst pq.snd
  | t =* s => [([Term.sub (canonize s) (canonize t)], [])]
  | t ≤* s => [([], [Term.sub (canonize s) (canonize t)])]
  | ¬* _ => []
#align omega.nat.dnf_core Omega.Nat.dnfCore

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic omega.nat.preform.induce -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
theorem exists_clause_holds_core {v : Nat → Nat} :
    ∀ {p : Preform},
      p.NegFree → p.SubFree → p.Holds v → ∃ c ∈ dnfCore p, Clause.Holds (fun x => ↑(v x)) c :=
  by
  run_tac
    preform.induce sorry
  · apply List.exists_mem_cons_of
    constructor; rw [List.forall_mem_singleton]
    cases' h0 with ht hs
    simp only [val_canonize ht, val_canonize hs, term.val_sub, preform.holds, sub_eq_add_neg] at *
    rw [h2, add_neg_self]; apply List.forall_mem_nil
  · apply List.exists_mem_cons_of
    constructor
    apply List.forall_mem_nil
    rw [List.forall_mem_singleton]
    simp only [val_canonize h0.left, val_canonize h0.right, term.val_sub, preform.holds,
      sub_eq_add_neg] at *
    rw [← sub_eq_add_neg, le_sub_comm, sub_zero, Int.ofNat_le]
    assumption
  · cases h1
  ·
    cases' h2 with h2 h2 <;> [· cases' ihp h1.left h0.left h2 with c h3;
              · cases' ihq h1.right h0.right h2 with c h3] <;>
            cases' h3 with h3 h4 <;>
          refine' ⟨c, list.mem_append.elim_right _, h4⟩ <;>
        [left; right] <;>
      assumption
  · rcases ihp h1.left h0.left h2.left with ⟨cp, hp1, hp2⟩
    rcases ihq h1.right h0.right h2.right with ⟨cq, hq1, hq2⟩
    refine' ⟨clause.append cp cq, ⟨_, clause.holds_append hp2 hq2⟩⟩
    simp only [dnf_core, List.mem_map]
    refine' ⟨(cp, cq), ⟨_, rfl⟩⟩
    rw [List.mem_product]
    constructor <;> assumption
#align omega.nat.exists_clause_holds_core Omega.Nat.exists_clause_holds_core

def Term.varsCore (is : List Int) : List Bool :=
  is.map fun i => if i = 0 then false else true
#align omega.nat.term.vars_core Omega.Nat.Term.varsCore

/-- Return a list of bools that encodes which variables have nonzero coefficients -/
def Term.vars (t : Term) : List Bool :=
  Term.varsCore t.snd
#align omega.nat.term.vars Omega.Nat.Term.vars

def Bools.or : List Bool → List Bool → List Bool
  | [], bs2 => bs2
  | bs1, [] => bs1
  | b1 :: bs1, b2 :: bs2 => (b1 || b2) :: bools.or bs1 bs2
#align omega.nat.bools.or Omega.Nat.Bools.or

/-- Return a list of bools that encodes which variables have nonzero coefficients in any one of the
input terms. -/
def Terms.vars : List Term → List Bool
  | [] => []
  | t :: ts => Bools.or (Term.vars t) (terms.vars ts)
#align omega.nat.terms.vars Omega.Nat.Terms.vars

open scoped List.Func

-- get notation for list.func.set
def nonnegConstsCore : Nat → List Bool → List Term
  | _, [] => []
  | k, ff :: bs => nonneg_consts_core (k + 1) bs
  | k, tt :: bs => ⟨0, [] {k ↦ 1}⟩ :: nonneg_consts_core (k + 1) bs
#align omega.nat.nonneg_consts_core Omega.Nat.nonnegConstsCore

def nonnegConsts (bs : List Bool) : List Term :=
  nonnegConstsCore 0 bs
#align omega.nat.nonneg_consts Omega.Nat.nonnegConsts

def nonnegate : Clause → Clause
  | (eqs, les) =>
    let xs := Terms.vars eqs
    let ys := Terms.vars les
    let bs := Bools.or xs ys
    (eqs, nonnegConsts bs ++ les)
#align omega.nat.nonnegate Omega.Nat.nonnegate

/-- DNF transformation -/
def dnf (p : Preform) : List Clause :=
  (dnfCore p).map nonnegate
#align omega.nat.dnf Omega.Nat.dnf

theorem holds_nonnegConstsCore {v : Nat → Int} (h1 : ∀ x, 0 ≤ v x) :
    ∀ m bs, ∀ t ∈ nonnegConstsCore m bs, 0 ≤ Term.val v t
  | _, [] => fun _ h2 => by cases h2
  | k, ff :: bs => holds_nonneg_consts_core (k + 1) bs
  | k, tt :: bs => by
    simp only [nonneg_consts_core]
    rw [List.forall_mem_cons]
    constructor
    · simp only [term.val, one_mul, zero_add, coeffs.val_set]
      apply h1
    · apply holds_nonneg_consts_core (k + 1) bs
#align omega.nat.holds_nonneg_consts_core Omega.Nat.holds_nonnegConstsCore

theorem holds_nonnegConsts {v : Nat → Int} {bs : List Bool} :
    (∀ x, 0 ≤ v x) → ∀ t ∈ nonnegConsts bs, 0 ≤ Term.val v t
  | h1 => by apply holds_nonneg_consts_core h1
#align omega.nat.holds_nonneg_consts Omega.Nat.holds_nonnegConsts

theorem exists_clause_holds {v : Nat → Nat} {p : Preform} :
    p.NegFree → p.SubFree → p.Holds v → ∃ c ∈ dnf p, Clause.Holds (fun x => ↑(v x)) c :=
  by
  intro h1 h2 h3
  rcases exists_clause_holds_core h1 h2 h3 with ⟨c, h4, h5⟩
  exists nonnegate c
  have h6 : nonnegate c ∈ dnf p := by
    simp only [dnf]; rw [List.mem_map]
    refine' ⟨c, h4, rfl⟩
  refine' ⟨h6, _⟩; cases' c with eqs les
  simp only [nonnegate, clause.holds]
  constructor; apply h5.left
  rw [List.forall_mem_append]
  apply And.intro (holds_nonneg_consts _) h5.right
  intro x
  apply Int.coe_nat_nonneg
#align omega.nat.exists_clause_holds Omega.Nat.exists_clause_holds

theorem exists_clause_sat {p : Preform} :
    p.NegFree → p.SubFree → p.Sat → ∃ c ∈ dnf p, Clause.Sat c :=
  by
  intro h1 h2 h3; cases' h3 with v h3
  rcases exists_clause_holds h1 h2 h3 with ⟨c, h4, h5⟩
  refine' ⟨c, h4, _, h5⟩
#align omega.nat.exists_clause_sat Omega.Nat.exists_clause_sat

theorem unsat_of_unsat_dnf (p : Preform) :
    p.NegFree → p.SubFree → Clauses.Unsat (dnf p) → p.Unsat :=
  by
  intro hnf hsf h1 h2; apply h1
  apply exists_clause_sat hnf hsf h2
#align omega.nat.unsat_of_unsat_dnf Omega.Nat.unsat_of_unsat_dnf

end Nat

end Omega

