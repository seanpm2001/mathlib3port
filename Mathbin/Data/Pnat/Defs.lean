/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Neil Strickland

! This file was ported from Lean 3 source module data.pnat.defs
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Basic
import Mathbin.Algebra.NeZero

/-!
# The positive natural numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains the definitions, and basic results.
Most algebraic facts are deferred to `data.pnat.basic`, as they need more imports.
-/


#print PNat /-
/-- `ℕ+` is the type of positive natural numbers. It is defined as a subtype,
  and the VM representation of `ℕ+` is the same as `ℕ` because the proof
  is not stored. -/
def PNat :=
  { n : ℕ // 0 < n }
deriving DecidableEq, LinearOrder
#align pnat PNat
-/

notation "ℕ+" => PNat

instance : One ℕ+ :=
  ⟨⟨1, Nat.zero_lt_one⟩⟩

#print coePNatNat /-
instance coePNatNat : Coe ℕ+ ℕ :=
  ⟨Subtype.val⟩
#align coe_pnat_nat coePNatNat
-/

instance : Repr ℕ+ :=
  ⟨fun n => repr n.1⟩

namespace PNat

#print PNat.mk_coe /-
@[simp]
theorem mk_coe (n h) : ((⟨n, h⟩ : ℕ+) : ℕ) = n :=
  rfl
#align pnat.mk_coe PNat.mk_coe
-/

#print PNat.natPred /-
/-- Predecessor of a `ℕ+`, as a `ℕ`. -/
def natPred (i : ℕ+) : ℕ :=
  i - 1
#align pnat.nat_pred PNat.natPred
-/

#print PNat.natPred_eq_pred /-
@[simp]
theorem natPred_eq_pred {n : ℕ} (h : 0 < n) : natPred (⟨n, h⟩ : ℕ+) = n.pred :=
  rfl
#align pnat.nat_pred_eq_pred PNat.natPred_eq_pred
-/

end PNat

namespace Nat

#print Nat.toPNat /-
/-- Convert a natural number to a positive natural number. The
  positivity assumption is inferred by `dec_trivial`. -/
def toPNat (n : ℕ) (h : 0 < n := by decide) : ℕ+ :=
  ⟨n, h⟩
#align nat.to_pnat Nat.toPNat
-/

#print Nat.succPNat /-
/-- Write a successor as an element of `ℕ+`. -/
def succPNat (n : ℕ) : ℕ+ :=
  ⟨succ n, succ_pos n⟩
#align nat.succ_pnat Nat.succPNat
-/

#print Nat.succPNat_coe /-
@[simp]
theorem succPNat_coe (n : ℕ) : (succPNat n : ℕ) = succ n :=
  rfl
#align nat.succ_pnat_coe Nat.succPNat_coe
-/

#print Nat.natPred_succPNat /-
@[simp]
theorem natPred_succPNat (n : ℕ) : n.succPNat.natPred = n :=
  rfl
#align nat.nat_pred_succ_pnat Nat.natPred_succPNat
-/

#print PNat.succPNat_natPred /-
@[simp]
theorem PNat.succPNat_natPred (n : ℕ+) : n.natPred.succPNat = n :=
  Subtype.eq <| succ_pred_eq_of_pos n.2
#align pnat.succ_pnat_nat_pred PNat.succPNat_natPred
-/

#print Nat.toPNat' /-
/-- Convert a natural number to a pnat. `n+1` is mapped to itself,
  and `0` becomes `1`. -/
def toPNat' (n : ℕ) : ℕ+ :=
  succPNat (pred n)
#align nat.to_pnat' Nat.toPNat'
-/

#print Nat.toPNat'_coe /-
@[simp]
theorem toPNat'_coe : ∀ n : ℕ, (toPNat' n : ℕ) = ite (0 < n) n 1
  | 0 => rfl
  | m + 1 => by rw [if_pos (succ_pos m)]; rfl
#align nat.to_pnat'_coe Nat.toPNat'_coe
-/

end Nat

namespace PNat

open Nat

#print PNat.mk_le_mk /-
/-- We now define a long list of structures on ℕ+ induced by
 similar structures on ℕ. Most of these behave in a completely
 obvious way, but there are a few things to be said about
 subtraction, division and powers.
-/
@[simp]
theorem mk_le_mk (n k : ℕ) (hn : 0 < n) (hk : 0 < k) : (⟨n, hn⟩ : ℕ+) ≤ ⟨k, hk⟩ ↔ n ≤ k :=
  Iff.rfl
#align pnat.mk_le_mk PNat.mk_le_mk
-/

#print PNat.mk_lt_mk /-
@[simp]
theorem mk_lt_mk (n k : ℕ) (hn : 0 < n) (hk : 0 < k) : (⟨n, hn⟩ : ℕ+) < ⟨k, hk⟩ ↔ n < k :=
  Iff.rfl
#align pnat.mk_lt_mk PNat.mk_lt_mk
-/

#print PNat.coe_le_coe /-
@[simp, norm_cast]
theorem coe_le_coe (n k : ℕ+) : (n : ℕ) ≤ k ↔ n ≤ k :=
  Iff.rfl
#align pnat.coe_le_coe PNat.coe_le_coe
-/

#print PNat.coe_lt_coe /-
@[simp, norm_cast]
theorem coe_lt_coe (n k : ℕ+) : (n : ℕ) < k ↔ n < k :=
  Iff.rfl
#align pnat.coe_lt_coe PNat.coe_lt_coe
-/

#print PNat.pos /-
@[simp]
theorem pos (n : ℕ+) : 0 < (n : ℕ) :=
  n.2
#align pnat.pos PNat.pos
-/

#print PNat.eq /-
theorem eq {m n : ℕ+} : (m : ℕ) = n → m = n :=
  Subtype.eq
#align pnat.eq PNat.eq
-/

#print PNat.coe_injective /-
theorem coe_injective : Function.Injective (coe : ℕ+ → ℕ) :=
  Subtype.coe_injective
#align pnat.coe_injective PNat.coe_injective
-/

#print PNat.ne_zero /-
@[simp]
theorem ne_zero (n : ℕ+) : (n : ℕ) ≠ 0 :=
  n.2.ne'
#align pnat.ne_zero PNat.ne_zero
-/

#print NeZero.pnat /-
instance NeZero.pnat {a : ℕ+} : NeZero (a : ℕ) :=
  ⟨a.NeZero⟩
#align ne_zero.pnat NeZero.pnat
-/

#print PNat.toPNat'_coe /-
theorem toPNat'_coe {n : ℕ} : 0 < n → (n.toPNat' : ℕ) = n :=
  succ_pred_eq_of_pos
#align pnat.to_pnat'_coe PNat.toPNat'_coe
-/

#print PNat.coe_toPNat' /-
@[simp]
theorem coe_toPNat' (n : ℕ+) : (n : ℕ).toPNat' = n :=
  eq (toPNat'_coe n.Pos)
#align pnat.coe_to_pnat' PNat.coe_toPNat'
-/

#print PNat.one_le /-
@[simp]
theorem one_le (n : ℕ+) : (1 : ℕ+) ≤ n :=
  n.2
#align pnat.one_le PNat.one_le
-/

#print PNat.not_lt_one /-
@[simp]
theorem not_lt_one (n : ℕ+) : ¬n < 1 :=
  not_lt_of_le n.one_le
#align pnat.not_lt_one PNat.not_lt_one
-/

instance : Inhabited ℕ+ :=
  ⟨1⟩

#print PNat.mk_one /-
-- Some lemmas that rewrite `pnat.mk n h`, for `n` an explicit numeral, into explicit numerals.
@[simp]
theorem mk_one {h} : (⟨1, h⟩ : ℕ+) = (1 : ℕ+) :=
  rfl
#align pnat.mk_one PNat.mk_one
-/

#print PNat.one_coe /-
@[norm_cast]
theorem one_coe : ((1 : ℕ+) : ℕ) = 1 :=
  rfl
#align pnat.one_coe PNat.one_coe
-/

#print PNat.coe_eq_one_iff /-
@[simp, norm_cast]
theorem coe_eq_one_iff {m : ℕ+} : (m : ℕ) = 1 ↔ m = 1 :=
  Subtype.coe_injective.eq_iff' one_coe
#align pnat.coe_eq_one_iff PNat.coe_eq_one_iff
-/

instance : WellFoundedRelation ℕ+ :=
  ⟨(· < ·), measure_wf coe⟩

#print PNat.strongInductionOn /-
/-- Strong induction on `ℕ+`. -/
def strongInductionOn {p : ℕ+ → Sort _} : ∀ (n : ℕ+) (h : ∀ k, (∀ m, m < k → p m) → p k), p n
  | n => fun IH => IH _ fun a h => strong_induction_on a IH
#align pnat.strong_induction_on PNat.strongInductionOn
-/

#print PNat.modDivAux /-
/-- We define `m % k` and `m / k` in the same way as for `ℕ`
  except that when `m = n * k` we take `m % k = k` and
  `m / k = n - 1`.  This ensures that `m % k` is always positive
  and `m = (m % k) + k * (m / k)` in all cases.  Later we
  define a function `div_exact` which gives the usual `m / k`
  in the case where `k` divides `m`.
-/
def modDivAux : ℕ+ → ℕ → ℕ → ℕ+ × ℕ
  | k, 0, q => ⟨k, q.pred⟩
  | k, r + 1, q => ⟨⟨r + 1, Nat.succ_pos r⟩, q⟩
#align pnat.mod_div_aux PNat.modDivAux
-/

#print PNat.modDiv /-
/-- `mod_div m k = (m % k, m / k)`.
  We define `m % k` and `m / k` in the same way as for `ℕ`
  except that when `m = n * k` we take `m % k = k` and
  `m / k = n - 1`.  This ensures that `m % k` is always positive
  and `m = (m % k) + k * (m / k)` in all cases.  Later we
  define a function `div_exact` which gives the usual `m / k`
  in the case where `k` divides `m`.
-/
def modDiv (m k : ℕ+) : ℕ+ × ℕ :=
  modDivAux k ((m : ℕ) % (k : ℕ)) ((m : ℕ) / (k : ℕ))
#align pnat.mod_div PNat.modDiv
-/

#print PNat.mod /-
/-- We define `m % k` in the same way as for `ℕ`
  except that when `m = n * k` we take `m % k = k` This ensures that `m % k` is always positive.
-/
def mod (m k : ℕ+) : ℕ+ :=
  (modDiv m k).1
#align pnat.mod PNat.mod
-/

#print PNat.div /-
/-- We define `m / k` in the same way as for `ℕ` except that when `m = n * k` we take
  `m / k = n - 1`. This ensures that `m = (m % k) + k * (m / k)` in all cases. Later we
  define a function `div_exact` which gives the usual `m / k` in the case where `k` divides `m`.
-/
def div (m k : ℕ+) : ℕ :=
  (modDiv m k).2
#align pnat.div PNat.div
-/

#print PNat.mod_coe /-
theorem mod_coe (m k : ℕ+) :
    (mod m k : ℕ) = ite ((m : ℕ) % (k : ℕ) = 0) (k : ℕ) ((m : ℕ) % (k : ℕ)) :=
  by
  dsimp [mod, mod_div]
  cases (m : ℕ) % (k : ℕ)
  · rw [if_pos rfl]; rfl
  · rw [if_neg n.succ_ne_zero]; rfl
#align pnat.mod_coe PNat.mod_coe
-/

#print PNat.div_coe /-
theorem div_coe (m k : ℕ+) :
    (div m k : ℕ) = ite ((m : ℕ) % (k : ℕ) = 0) ((m : ℕ) / (k : ℕ)).pred ((m : ℕ) / (k : ℕ)) :=
  by
  dsimp [div, mod_div]
  cases (m : ℕ) % (k : ℕ)
  · rw [if_pos rfl]; rfl
  · rw [if_neg n.succ_ne_zero]; rfl
#align pnat.div_coe PNat.div_coe
-/

#print PNat.divExact /-
/-- If `h : k | m`, then `k * (div_exact m k) = m`. Note that this is not equal to `m / k`. -/
def divExact (m k : ℕ+) : ℕ+ :=
  ⟨(div m k).succ, Nat.succ_pos _⟩
#align pnat.div_exact PNat.divExact
-/

end PNat

section CanLift

#print Nat.canLiftPNat /-
instance Nat.canLiftPNat : CanLift ℕ ℕ+ coe ((· < ·) 0) :=
  ⟨fun n hn => ⟨Nat.toPNat' n, PNat.toPNat'_coe hn⟩⟩
#align nat.can_lift_pnat Nat.canLiftPNat
-/

#print Int.canLiftPNat /-
instance Int.canLiftPNat : CanLift ℤ ℕ+ coe ((· < ·) 0) :=
  ⟨fun n hn =>
    ⟨Nat.toPNat' (Int.natAbs n), by
      rw [coe_coe, Nat.toPNat'_coe, if_pos (Int.natAbs_pos_of_ne_zero hn.ne'),
        Int.natAbs_of_nonneg hn.le]⟩⟩
#align int.can_lift_pnat Int.canLiftPNat
-/

end CanLift

