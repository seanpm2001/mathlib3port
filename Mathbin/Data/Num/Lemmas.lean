/-
Copyright (c) 2014 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.num.lemmas
! leanprover-community/mathlib commit 25a9423c6b2c8626e91c688bfd6c1d0a986a3e6e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Num.Bitwise
import Mathbin.Data.Int.CharZero
import Mathbin.Data.Nat.Gcd.Basic
import Mathbin.Data.Nat.Psub
import Mathbin.Data.Nat.Size

/-!
# Properties of the binary representation of integers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


attribute [local simp] add_assoc

namespace PosNum

variable {α : Type _}

#print PosNum.cast_one /-
@[simp, norm_cast]
theorem cast_one [One α] [Add α] : ((1 : PosNum) : α) = 1 :=
  rfl
#align pos_num.cast_one PosNum.cast_one
-/

#print PosNum.cast_one' /-
@[simp]
theorem cast_one' [One α] [Add α] : (PosNum.one : α) = 1 :=
  rfl
#align pos_num.cast_one' PosNum.cast_one'
-/

#print PosNum.cast_bit0 /-
@[simp, norm_cast]
theorem cast_bit0 [One α] [Add α] (n : PosNum) : (n.bit0 : α) = bit0 n :=
  rfl
#align pos_num.cast_bit0 PosNum.cast_bit0
-/

#print PosNum.cast_bit1 /-
@[simp, norm_cast]
theorem cast_bit1 [One α] [Add α] (n : PosNum) : (n.bit1 : α) = bit1 n :=
  rfl
#align pos_num.cast_bit1 PosNum.cast_bit1
-/

#print PosNum.cast_to_nat /-
@[simp, norm_cast]
theorem cast_to_nat [AddMonoidWithOne α] : ∀ n : PosNum, ((n : ℕ) : α) = n
  | 1 => Nat.cast_one
  | bit0 p => (Nat.cast_bit0 _).trans <| congr_arg bit0 p.cast_to_nat
  | bit1 p => (Nat.cast_bit1 _).trans <| congr_arg bit1 p.cast_to_nat
#align pos_num.cast_to_nat PosNum.cast_to_nat
-/

#print PosNum.to_nat_to_int /-
@[simp, norm_cast]
theorem to_nat_to_int (n : PosNum) : ((n : ℕ) : ℤ) = n :=
  cast_to_nat _
#align pos_num.to_nat_to_int PosNum.to_nat_to_int
-/

#print PosNum.cast_to_int /-
@[simp, norm_cast]
theorem cast_to_int [AddGroupWithOne α] (n : PosNum) : ((n : ℤ) : α) = n := by
  rw [← to_nat_to_int, Int.cast_ofNat, cast_to_nat]
#align pos_num.cast_to_int PosNum.cast_to_int
-/

#print PosNum.succ_to_nat /-
theorem succ_to_nat : ∀ n, (succ n : ℕ) = n + 1
  | 1 => rfl
  | bit0 p => rfl
  | bit1 p =>
    (congr_arg bit0 (succ_to_nat p)).trans <|
      show ↑p + 1 + ↑p + 1 = ↑p + ↑p + 1 + 1 by simp [add_left_comm]
#align pos_num.succ_to_nat PosNum.succ_to_nat
-/

#print PosNum.one_add /-
theorem one_add (n : PosNum) : 1 + n = succ n := by cases n <;> rfl
#align pos_num.one_add PosNum.one_add
-/

#print PosNum.add_one /-
theorem add_one (n : PosNum) : n + 1 = succ n := by cases n <;> rfl
#align pos_num.add_one PosNum.add_one
-/

#print PosNum.add_to_nat /-
@[norm_cast]
theorem add_to_nat : ∀ m n, ((m + n : PosNum) : ℕ) = m + n
  | 1, b => by rw [one_add b, succ_to_nat, add_comm] <;> rfl
  | a, 1 => by rw [add_one a, succ_to_nat] <;> rfl
  | bit0 a, bit0 b => (congr_arg bit0 (add_to_nat a b)).trans <| add_add_add_comm _ _ _ _
  | bit0 a, bit1 b =>
    (congr_arg bit1 (add_to_nat a b)).trans <|
      show (a + b + (a + b) + 1 : ℕ) = a + a + (b + b + 1) by simp [add_left_comm]
  | bit1 a, bit0 b =>
    (congr_arg bit1 (add_to_nat a b)).trans <|
      show (a + b + (a + b) + 1 : ℕ) = a + a + 1 + (b + b) by simp [add_comm, add_left_comm]
  | bit1 a, bit1 b =>
    show (succ (a + b) + succ (a + b) : ℕ) = a + a + 1 + (b + b + 1) by
      rw [succ_to_nat, add_to_nat] <;> simp [add_left_comm]
#align pos_num.add_to_nat PosNum.add_to_nat
-/

#print PosNum.add_succ /-
theorem add_succ : ∀ m n : PosNum, m + succ n = succ (m + n)
  | 1, b => by simp [one_add]
  | bit0 a, 1 => congr_arg bit0 (add_one a)
  | bit1 a, 1 => congr_arg bit1 (add_one a)
  | bit0 a, bit0 b => rfl
  | bit0 a, bit1 b => congr_arg bit0 (add_succ a b)
  | bit1 a, bit0 b => rfl
  | bit1 a, bit1 b => congr_arg bit1 (add_succ a b)
#align pos_num.add_succ PosNum.add_succ
-/

#print PosNum.bit0_of_bit0 /-
theorem bit0_of_bit0 : ∀ n, bit0 n = bit0 n
  | 1 => rfl
  | bit0 p => congr_arg bit0 (bit0_of_bit0 p)
  | bit1 p => show bit0 (succ (bit0 p)) = _ by rw [bit0_of_bit0] <;> rfl
#align pos_num.bit0_of_bit0 PosNum.bit0_of_bit0
-/

#print PosNum.bit1_of_bit1 /-
theorem bit1_of_bit1 (n : PosNum) : bit1 n = bit1 n :=
  show bit0 n + 1 = bit1 n by rw [add_one, bit0_of_bit0] <;> rfl
#align pos_num.bit1_of_bit1 PosNum.bit1_of_bit1
-/

#print PosNum.mul_to_nat /-
@[norm_cast]
theorem mul_to_nat (m) : ∀ n, ((m * n : PosNum) : ℕ) = m * n
  | 1 => (mul_one _).symm
  | bit0 p => show (↑(m * p) + ↑(m * p) : ℕ) = ↑m * (p + p) by rw [mul_to_nat, left_distrib]
  | bit1 p =>
    (add_to_nat (bit0 (m * p)) m).trans <|
      show (↑(m * p) + ↑(m * p) + ↑m : ℕ) = ↑m * (p + p) + m by rw [mul_to_nat, left_distrib]
#align pos_num.mul_to_nat PosNum.mul_to_nat
-/

#print PosNum.to_nat_pos /-
theorem to_nat_pos : ∀ n : PosNum, 0 < (n : ℕ)
  | 1 => zero_lt_one
  | bit0 p =>
    let h := to_nat_pos p
    add_pos h h
  | bit1 p => Nat.succ_pos _
#align pos_num.to_nat_pos PosNum.to_nat_pos
-/

#print PosNum.cmp_to_nat_lemma /-
theorem cmp_to_nat_lemma {m n : PosNum} : (m : ℕ) < n → (bit1 m : ℕ) < bit0 n :=
  show (m : ℕ) < n → (m + m + 1 + 1 : ℕ) ≤ n + n by
    intro h <;> rw [Nat.add_right_comm m m 1, add_assoc] <;> exact add_le_add h h
#align pos_num.cmp_to_nat_lemma PosNum.cmp_to_nat_lemma
-/

#print PosNum.cmp_swap /-
theorem cmp_swap (m) : ∀ n, (cmp m n).symm = cmp n m := by
  induction' m with m IH m IH <;> intro n <;> cases' n with n n <;> try unfold cmp <;> try rfl <;>
        rw [← IH] <;>
      cases cmp m n <;>
    rfl
#align pos_num.cmp_swap PosNum.cmp_swap
-/

#print PosNum.cmp_to_nat /-
theorem cmp_to_nat : ∀ m n, (Ordering.casesOn (cmp m n) ((m : ℕ) < n) (m = n) ((n : ℕ) < m) : Prop)
  | 1, 1 => rfl
  | bit0 a, 1 =>
    let h : (1 : ℕ) ≤ a := to_nat_pos a
    add_le_add h h
  | bit1 a, 1 => Nat.succ_lt_succ <| to_nat_pos <| bit0 a
  | 1, bit0 b =>
    let h : (1 : ℕ) ≤ b := to_nat_pos b
    add_le_add h h
  | 1, bit1 b => Nat.succ_lt_succ <| to_nat_pos <| bit0 b
  | bit0 a, bit0 b => by
    have := cmp_to_nat a b; revert this; cases cmp a b <;> dsimp <;> intro
    · exact add_lt_add this this
    · rw [this]
    · exact add_lt_add this this
  | bit0 a, bit1 b => by
    dsimp [cmp]
    have := cmp_to_nat a b; revert this; cases cmp a b <;> dsimp <;> intro
    · exact Nat.le_succ_of_le (add_lt_add this this)
    · rw [this]; apply Nat.lt_succ_self
    · exact cmp_to_nat_lemma this
  | bit1 a, bit0 b => by
    dsimp [cmp]
    have := cmp_to_nat a b; revert this; cases cmp a b <;> dsimp <;> intro
    · exact cmp_to_nat_lemma this
    · rw [this]; apply Nat.lt_succ_self
    · exact Nat.le_succ_of_le (add_lt_add this this)
  | bit1 a, bit1 b => by
    have := cmp_to_nat a b; revert this; cases cmp a b <;> dsimp <;> intro
    · exact Nat.succ_lt_succ (add_lt_add this this)
    · rw [this]
    · exact Nat.succ_lt_succ (add_lt_add this this)
#align pos_num.cmp_to_nat PosNum.cmp_to_nat
-/

#print PosNum.lt_to_nat /-
@[norm_cast]
theorem lt_to_nat {m n : PosNum} : (m : ℕ) < n ↔ m < n :=
  show (m : ℕ) < n ↔ cmp m n = Ordering.lt from
    match cmp m n, cmp_to_nat m n with
    | Ordering.lt, h => by simp at h  <;> simp [h]
    | Ordering.eq, h => by simp at h  <;> simp [h, lt_irrefl] <;> exact by decide
    | Ordering.gt, h => by simp [not_lt_of_gt h] <;> exact by decide
#align pos_num.lt_to_nat PosNum.lt_to_nat
-/

#print PosNum.le_to_nat /-
@[norm_cast]
theorem le_to_nat {m n : PosNum} : (m : ℕ) ≤ n ↔ m ≤ n := by
  rw [← not_lt] <;> exact not_congr lt_to_nat
#align pos_num.le_to_nat PosNum.le_to_nat
-/

end PosNum

namespace Num

variable {α : Type _}

open PosNum

#print Num.add_zero /-
theorem add_zero (n : Num) : n + 0 = n := by cases n <;> rfl
#align num.add_zero Num.add_zero
-/

#print Num.zero_add /-
theorem zero_add (n : Num) : 0 + n = n := by cases n <;> rfl
#align num.zero_add Num.zero_add
-/

#print Num.add_one /-
theorem add_one : ∀ n : Num, n + 1 = succ n
  | 0 => rfl
  | Pos p => by cases p <;> rfl
#align num.add_one Num.add_one
-/

#print Num.add_succ /-
theorem add_succ : ∀ m n : Num, m + succ n = succ (m + n)
  | 0, n => by simp [zero_add]
  | Pos p, 0 => show pos (p + 1) = succ (pos p + 0) by rw [PosNum.add_one, add_zero] <;> rfl
  | Pos p, Pos q => congr_arg pos (PosNum.add_succ _ _)
#align num.add_succ Num.add_succ
-/

#print Num.bit0_of_bit0 /-
theorem bit0_of_bit0 : ∀ n : Num, bit0 n = n.bit0
  | 0 => rfl
  | Pos p => congr_arg pos p.bit0_of_bit0
#align num.bit0_of_bit0 Num.bit0_of_bit0
-/

#print Num.bit1_of_bit1 /-
theorem bit1_of_bit1 : ∀ n : Num, bit1 n = n.bit1
  | 0 => rfl
  | Pos p => congr_arg pos p.bit1_of_bit1
#align num.bit1_of_bit1 Num.bit1_of_bit1
-/

#print Num.ofNat'_zero /-
@[simp]
theorem ofNat'_zero : Num.ofNat' 0 = 0 := by simp [Num.ofNat']
#align num.of_nat'_zero Num.ofNat'_zero
-/

#print Num.ofNat'_bit /-
theorem ofNat'_bit (b n) : ofNat' (Nat.bit b n) = cond b Num.bit1 Num.bit0 (ofNat' n) :=
  Nat.binaryRec_eq rfl _ _
#align num.of_nat'_bit Num.ofNat'_bit
-/

#print Num.ofNat'_one /-
@[simp]
theorem ofNat'_one : Num.ofNat' 1 = 1 := by erw [of_nat'_bit tt 0, cond, of_nat'_zero] <;> rfl
#align num.of_nat'_one Num.ofNat'_one
-/

#print Num.bit1_succ /-
theorem bit1_succ : ∀ n : Num, n.bit1.succ = n.succ.bit0
  | 0 => rfl
  | Pos n => rfl
#align num.bit1_succ Num.bit1_succ
-/

#print Num.ofNat'_succ /-
theorem ofNat'_succ : ∀ {n}, ofNat' (n + 1) = ofNat' n + 1 :=
  Nat.binaryRec (by simp <;> rfl) fun b n ih =>
    by
    cases b
    · erw [of_nat'_bit tt n, of_nat'_bit]
      simp only [← bit1_of_bit1, ← bit0_of_bit0, cond, _root_.bit1]
    · erw [show n.bit tt + 1 = (n + 1).bit ff by simp [Nat.bit, _root_.bit1, _root_.bit0] <;> cc,
        of_nat'_bit, of_nat'_bit, ih]
      simp only [cond, add_one, bit1_succ]
#align num.of_nat'_succ Num.ofNat'_succ
-/

#print Num.add_ofNat' /-
@[simp]
theorem add_ofNat' (m n) : Num.ofNat' (m + n) = Num.ofNat' m + Num.ofNat' n := by
  induction n <;> simp [Nat.add_zero, of_nat'_succ, add_zero, Nat.add_succ, add_one, add_succ, *]
#align num.add_of_nat' Num.add_ofNat'
-/

#print Num.cast_zero /-
@[simp, norm_cast]
theorem cast_zero [Zero α] [One α] [Add α] : ((0 : Num) : α) = 0 :=
  rfl
#align num.cast_zero Num.cast_zero
-/

#print Num.cast_zero' /-
@[simp]
theorem cast_zero' [Zero α] [One α] [Add α] : (Num.zero : α) = 0 :=
  rfl
#align num.cast_zero' Num.cast_zero'
-/

#print Num.cast_one /-
@[simp, norm_cast]
theorem cast_one [Zero α] [One α] [Add α] : ((1 : Num) : α) = 1 :=
  rfl
#align num.cast_one Num.cast_one
-/

#print Num.cast_pos /-
@[simp]
theorem cast_pos [Zero α] [One α] [Add α] (n : PosNum) : (Num.pos n : α) = n :=
  rfl
#align num.cast_pos Num.cast_pos
-/

#print Num.succ'_to_nat /-
theorem succ'_to_nat : ∀ n, (succ' n : ℕ) = n + 1
  | 0 => (zero_add _).symm
  | Pos p => PosNum.succ_to_nat _
#align num.succ'_to_nat Num.succ'_to_nat
-/

#print Num.succ_to_nat /-
theorem succ_to_nat (n) : (succ n : ℕ) = n + 1 :=
  succ'_to_nat n
#align num.succ_to_nat Num.succ_to_nat
-/

#print Num.cast_to_nat /-
@[simp, norm_cast]
theorem cast_to_nat [AddMonoidWithOne α] : ∀ n : Num, ((n : ℕ) : α) = n
  | 0 => Nat.cast_zero
  | Pos p => p.cast_to_nat
#align num.cast_to_nat Num.cast_to_nat
-/

#print Num.add_to_nat /-
@[norm_cast]
theorem add_to_nat : ∀ m n, ((m + n : Num) : ℕ) = m + n
  | 0, 0 => rfl
  | 0, Pos q => (zero_add _).symm
  | Pos p, 0 => rfl
  | Pos p, Pos q => PosNum.add_to_nat _ _
#align num.add_to_nat Num.add_to_nat
-/

#print Num.mul_to_nat /-
@[norm_cast]
theorem mul_to_nat : ∀ m n, ((m * n : Num) : ℕ) = m * n
  | 0, 0 => rfl
  | 0, Pos q => (MulZeroClass.zero_mul _).symm
  | Pos p, 0 => rfl
  | Pos p, Pos q => PosNum.mul_to_nat _ _
#align num.mul_to_nat Num.mul_to_nat
-/

#print Num.cmp_to_nat /-
theorem cmp_to_nat : ∀ m n, (Ordering.casesOn (cmp m n) ((m : ℕ) < n) (m = n) ((n : ℕ) < m) : Prop)
  | 0, 0 => rfl
  | 0, Pos b => to_nat_pos _
  | Pos a, 0 => to_nat_pos _
  | Pos a, Pos b =>
    by
    have := PosNum.cmp_to_nat a b <;> revert this <;> dsimp [cmp] <;> cases PosNum.cmp a b
    exacts [id, congr_arg Pos, id]
#align num.cmp_to_nat Num.cmp_to_nat
-/

#print Num.lt_to_nat /-
@[norm_cast]
theorem lt_to_nat {m n : Num} : (m : ℕ) < n ↔ m < n :=
  show (m : ℕ) < n ↔ cmp m n = Ordering.lt from
    match cmp m n, cmp_to_nat m n with
    | Ordering.lt, h => by simp at h  <;> simp [h]
    | Ordering.eq, h => by simp at h  <;> simp [h, lt_irrefl] <;> exact by decide
    | Ordering.gt, h => by simp [not_lt_of_gt h] <;> exact by decide
#align num.lt_to_nat Num.lt_to_nat
-/

#print Num.le_to_nat /-
@[norm_cast]
theorem le_to_nat {m n : Num} : (m : ℕ) ≤ n ↔ m ≤ n := by
  rw [← not_lt] <;> exact not_congr lt_to_nat
#align num.le_to_nat Num.le_to_nat
-/

end Num

namespace PosNum

#print PosNum.of_to_nat' /-
@[simp]
theorem of_to_nat' : ∀ n : PosNum, Num.ofNat' (n : ℕ) = Num.pos n
  | 1 => by erw [@Num.ofNat'_bit tt 0, Num.ofNat'_zero] <;> rfl
  | bit0 p => by erw [@Num.ofNat'_bit ff, of_to_nat'] <;> rfl
  | bit1 p => by erw [@Num.ofNat'_bit tt, of_to_nat'] <;> rfl
#align pos_num.of_to_nat' PosNum.of_to_nat'
-/

end PosNum

namespace Num

#print Num.of_to_nat' /-
@[simp, norm_cast]
theorem of_to_nat' : ∀ n : Num, Num.ofNat' (n : ℕ) = n
  | 0 => ofNat'_zero
  | Pos p => p.of_to_nat'
#align num.of_to_nat' Num.of_to_nat'
-/

#print Num.to_nat_inj /-
@[norm_cast]
theorem to_nat_inj {m n : Num} : (m : ℕ) = n ↔ m = n :=
  ⟨fun h => Function.LeftInverse.injective of_to_nat' h, congr_arg _⟩
#align num.to_nat_inj Num.to_nat_inj
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/-- This tactic tries to turn an (in)equality about `num`s to one about `nat`s by rewriting.
```lean
example (n : num) (m : num) : n ≤ n + m :=
begin
  num.transfer_rw,
  exact nat.le_add_right _ _
end
```
-/
unsafe def transfer_rw : tactic Unit :=
  sorry
#align num.transfer_rw num.transfer_rw

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/--
This tactic tries to prove (in)equalities about `num`s by transfering them to the `nat` world and
then trying to call `simp`.
```lean
example (n : num) (m : num) : n ≤ n + m := by num.transfer
```
-/
unsafe def transfer : tactic Unit :=
  sorry
#align num.transfer num.transfer

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer -/
instance : AddMonoid Num where
  add := (· + ·)
  zero := 0
  zero_add := zero_add
  add_zero := add_zero
  add_assoc := by
    run_tac
      transfer

instance : AddMonoidWithOne Num :=
  { Num.addMonoid with
    natCast := Num.ofNat'
    one := 1
    natCast_zero := ofNat'_zero
    natCast_succ := fun _ => ofNat'_succ }

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer -/
instance : CommSemiring Num := by
  refine_struct
          { Num.addMonoid,
            Num.addMonoidWithOne with
            mul := (· * ·)
            one := 1
            add := (· + ·)
            zero := 0
            npow := @npowRec Num ⟨1⟩ ⟨(· * ·)⟩ } <;>
        try intros; rfl <;>
      try
        run_tac
          transfer <;>
    simp [add_comm, mul_add, add_mul, mul_assoc, mul_comm, mul_left_comm]

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
instance : OrderedCancelAddCommMonoid Num :=
  { Num.commSemiring with
    lt := (· < ·)
    lt_iff_le_not_le := by intro a b;
      run_tac
        transfer_rw;
      apply lt_iff_le_not_le
    le := (· ≤ ·)
    le_refl := by
      run_tac
        transfer
    le_trans := by intro a b c;
      run_tac
        transfer_rw;
      apply le_trans
    le_antisymm := by intro a b;
      run_tac
        transfer_rw;
      apply le_antisymm
    add_le_add_left := by
      intro a b h c; revert h;
      run_tac
        transfer_rw
      exact fun h => add_le_add_left h c
    le_of_add_le_add_left := by intro a b c;
      run_tac
        transfer_rw;
      apply le_of_add_le_add_left }

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic num.transfer_rw -/
instance : LinearOrderedSemiring Num :=
  { Num.commSemiring,
    Num.orderedCancelAddCommMonoid with
    le_total := by intro a b;
      run_tac
        transfer_rw;
      apply le_total
    zero_le_one := by decide
    mul_lt_mul_of_pos_left := by intro a b c;
      run_tac
        transfer_rw;
      apply mul_lt_mul_of_pos_left
    mul_lt_mul_of_pos_right := by intro a b c;
      run_tac
        transfer_rw;
      apply mul_lt_mul_of_pos_right
    decidableLt := Num.decidableLT
    decidableLe := Num.decidableLE
    DecidableEq := Num.decidableEq
    exists_pair_ne := ⟨0, 1, by decide⟩ }

#print Num.add_of_nat /-
@[simp, norm_cast]
theorem add_of_nat (m n) : ((m + n : ℕ) : Num) = m + n :=
  add_ofNat' _ _
#align num.add_of_nat Num.add_of_nat
-/

#print Num.to_nat_to_int /-
@[simp, norm_cast]
theorem to_nat_to_int (n : Num) : ((n : ℕ) : ℤ) = n :=
  cast_to_nat _
#align num.to_nat_to_int Num.to_nat_to_int
-/

#print Num.cast_to_int /-
@[simp, norm_cast]
theorem cast_to_int {α} [AddGroupWithOne α] (n : Num) : ((n : ℤ) : α) = n := by
  rw [← to_nat_to_int, Int.cast_ofNat, cast_to_nat]
#align num.cast_to_int Num.cast_to_int
-/

#print Num.to_of_nat /-
theorem to_of_nat : ∀ n : ℕ, ((n : Num) : ℕ) = n
  | 0 => by rw [Nat.cast_zero, cast_zero]
  | n + 1 => by rw [Nat.cast_succ, add_one, succ_to_nat, to_of_nat]
#align num.to_of_nat Num.to_of_nat
-/

#print Num.of_nat_cast /-
@[simp, norm_cast]
theorem of_nat_cast {α} [AddMonoidWithOne α] (n : ℕ) : ((n : Num) : α) = n := by
  rw [← cast_to_nat, to_of_nat]
#align num.of_nat_cast Num.of_nat_cast
-/

#print Num.of_nat_inj /-
@[simp, norm_cast]
theorem of_nat_inj {m n : ℕ} : (m : Num) = n ↔ m = n :=
  ⟨fun h => Function.LeftInverse.injective to_of_nat h, congr_arg _⟩
#align num.of_nat_inj Num.of_nat_inj
-/

#print Num.of_to_nat /-
@[simp, norm_cast]
theorem of_to_nat : ∀ n : Num, ((n : ℕ) : Num) = n :=
  of_to_nat'
#align num.of_to_nat Num.of_to_nat
-/

#print Num.dvd_to_nat /-
@[norm_cast]
theorem dvd_to_nat (m n : Num) : (m : ℕ) ∣ n ↔ m ∣ n :=
  ⟨fun ⟨k, e⟩ => ⟨k, by rw [← of_to_nat n, e] <;> simp⟩, fun ⟨k, e⟩ => ⟨k, by simp [e, mul_to_nat]⟩⟩
#align num.dvd_to_nat Num.dvd_to_nat
-/

end Num

namespace PosNum

variable {α : Type _}

open Num

#print PosNum.of_to_nat /-
@[simp, norm_cast]
theorem of_to_nat : ∀ n : PosNum, ((n : ℕ) : Num) = Num.pos n :=
  of_to_nat'
#align pos_num.of_to_nat PosNum.of_to_nat
-/

#print PosNum.to_nat_inj /-
@[norm_cast]
theorem to_nat_inj {m n : PosNum} : (m : ℕ) = n ↔ m = n :=
  ⟨fun h => Num.pos.inj <| by rw [← PosNum.of_to_nat, ← PosNum.of_to_nat, h], congr_arg _⟩
#align pos_num.to_nat_inj PosNum.to_nat_inj
-/

#print PosNum.pred'_to_nat /-
theorem pred'_to_nat : ∀ n, (pred' n : ℕ) = Nat.pred n
  | 1 => rfl
  | bit0 n =>
    have : Nat.succ ↑(pred' n) = ↑n := by
      rw [pred'_to_nat n, Nat.succ_pred_eq_of_pos (to_nat_pos n)]
    match (motive :=
      ∀ k : Num, Nat.succ ↑k = ↑n → ↑(Num.casesOn k 1 bit1 : PosNum) = Nat.pred (bit0 n)) pred' n,
      this with
    | 0, (h : ((1 : Num) : ℕ) = n) => by rw [← to_nat_inj.1 h] <;> rfl
    | Num.pos p, (h : Nat.succ ↑p = n) => by rw [← h] <;> exact (Nat.succ_add p p).symm
  | bit1 n => rfl
#align pos_num.pred'_to_nat PosNum.pred'_to_nat
-/

#print PosNum.pred'_succ' /-
@[simp]
theorem pred'_succ' (n) : pred' (succ' n) = n :=
  Num.to_nat_inj.1 <| by rw [pred'_to_nat, succ'_to_nat, Nat.add_one, Nat.pred_succ]
#align pos_num.pred'_succ' PosNum.pred'_succ'
-/

#print PosNum.succ'_pred' /-
@[simp]
theorem succ'_pred' (n) : succ' (pred' n) = n :=
  to_nat_inj.1 <| by
    rw [succ'_to_nat, pred'_to_nat, Nat.add_one, Nat.succ_pred_eq_of_pos (to_nat_pos _)]
#align pos_num.succ'_pred' PosNum.succ'_pred'
-/

instance : Dvd PosNum :=
  ⟨fun m n => Pos m ∣ Pos n⟩

#print PosNum.dvd_to_nat /-
@[norm_cast]
theorem dvd_to_nat {m n : PosNum} : (m : ℕ) ∣ n ↔ m ∣ n :=
  Num.dvd_to_nat (Pos m) (Pos n)
#align pos_num.dvd_to_nat PosNum.dvd_to_nat
-/

#print PosNum.size_to_nat /-
theorem size_to_nat : ∀ n, (size n : ℕ) = Nat.size n
  | 1 => Nat.size_one.symm
  | bit0 n => by
    rw [size, succ_to_nat, size_to_nat, cast_bit0, Nat.size_bit0 <| ne_of_gt <| to_nat_pos n]
  | bit1 n => by rw [size, succ_to_nat, size_to_nat, cast_bit1, Nat.size_bit1]
#align pos_num.size_to_nat PosNum.size_to_nat
-/

#print PosNum.size_eq_natSize /-
theorem size_eq_natSize : ∀ n, (size n : ℕ) = natSize n
  | 1 => rfl
  | bit0 n => by rw [size, succ_to_nat, nat_size, size_eq_nat_size]
  | bit1 n => by rw [size, succ_to_nat, nat_size, size_eq_nat_size]
#align pos_num.size_eq_nat_size PosNum.size_eq_natSize
-/

#print PosNum.natSize_to_nat /-
theorem natSize_to_nat (n) : natSize n = Nat.size n := by rw [← size_eq_nat_size, size_to_nat]
#align pos_num.nat_size_to_nat PosNum.natSize_to_nat
-/

#print PosNum.natSize_pos /-
theorem natSize_pos (n) : 0 < natSize n := by cases n <;> apply Nat.succ_pos
#align pos_num.nat_size_pos PosNum.natSize_pos
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/-- This tactic tries to turn an (in)equality about `pos_num`s to one about `nat`s by rewriting.
```lean
example (n : pos_num) (m : pos_num) : n ≤ n + m :=
begin
  pos_num.transfer_rw,
  exact nat.le_add_right _ _
end
```
-/
unsafe def transfer_rw : tactic Unit :=
  sorry
#align pos_num.transfer_rw pos_num.transfer_rw

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/--
This tactic tries to prove (in)equalities about `pos_num`s by transferring them to the `nat` world
and then trying to call `simp`.
```lean
example (n : pos_num) (m : pos_num) : n ≤ n + m := by pos_num.transfer
```
-/
unsafe def transfer : tactic Unit :=
  sorry
#align pos_num.transfer pos_num.transfer

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer -/
instance : AddCommSemigroup PosNum := by
  refine' { add := (· + ·) .. } <;>
    run_tac
      transfer

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer -/
instance : CommMonoid PosNum := by
  refine_struct
        { mul := (· * ·)
          one := (1 : PosNum)
          npow := @npowRec PosNum ⟨1⟩ ⟨(· * ·)⟩ } <;>
      try intros; rfl <;>
    run_tac
      transfer

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer -/
instance : Distrib PosNum := by
  refine'
      { add := (· + ·)
        mul := (· * ·) .. } <;>
    ·
      run_tac
        transfer;
      simp [mul_add, mul_comm]

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic pos_num.transfer_rw -/
instance : LinearOrder PosNum where
  lt := (· < ·)
  lt_iff_le_not_le := by intro a b;
    run_tac
      transfer_rw;
    apply lt_iff_le_not_le
  le := (· ≤ ·)
  le_refl := by
    run_tac
      transfer
  le_trans := by intro a b c;
    run_tac
      transfer_rw;
    apply le_trans
  le_antisymm := by intro a b;
    run_tac
      transfer_rw;
    apply le_antisymm
  le_total := by intro a b;
    run_tac
      transfer_rw;
    apply le_total
  decidableLt := by infer_instance
  decidableLe := by infer_instance
  DecidableEq := by infer_instance

#print PosNum.cast_to_num /-
@[simp]
theorem cast_to_num (n : PosNum) : ↑n = Num.pos n := by rw [← cast_to_nat, ← of_to_nat n]
#align pos_num.cast_to_num PosNum.cast_to_num
-/

#print PosNum.bit_to_nat /-
@[simp, norm_cast]
theorem bit_to_nat (b n) : (bit b n : ℕ) = Nat.bit b n := by cases b <;> rfl
#align pos_num.bit_to_nat PosNum.bit_to_nat
-/

#print PosNum.cast_add /-
@[simp, norm_cast]
theorem cast_add [AddMonoidWithOne α] (m n) : ((m + n : PosNum) : α) = m + n := by
  rw [← cast_to_nat, add_to_nat, Nat.cast_add, cast_to_nat, cast_to_nat]
#align pos_num.cast_add PosNum.cast_add
-/

#print PosNum.cast_succ /-
@[simp, norm_cast]
theorem cast_succ [AddMonoidWithOne α] (n : PosNum) : (succ n : α) = n + 1 := by
  rw [← add_one, cast_add, cast_one]
#align pos_num.cast_succ PosNum.cast_succ
-/

#print PosNum.cast_inj /-
@[simp, norm_cast]
theorem cast_inj [AddMonoidWithOne α] [CharZero α] {m n : PosNum} : (m : α) = n ↔ m = n := by
  rw [← cast_to_nat m, ← cast_to_nat n, Nat.cast_inj, to_nat_inj]
#align pos_num.cast_inj PosNum.cast_inj
-/

#print PosNum.one_le_cast /-
@[simp]
theorem one_le_cast [LinearOrderedSemiring α] (n : PosNum) : (1 : α) ≤ n := by
  rw [← cast_to_nat, ← Nat.cast_one, Nat.cast_le] <;> apply to_nat_pos
#align pos_num.one_le_cast PosNum.one_le_cast
-/

#print PosNum.cast_pos /-
@[simp]
theorem cast_pos [LinearOrderedSemiring α] (n : PosNum) : 0 < (n : α) :=
  lt_of_lt_of_le zero_lt_one (one_le_cast n)
#align pos_num.cast_pos PosNum.cast_pos
-/

#print PosNum.cast_mul /-
@[simp, norm_cast]
theorem cast_mul [Semiring α] (m n) : ((m * n : PosNum) : α) = m * n := by
  rw [← cast_to_nat, mul_to_nat, Nat.cast_mul, cast_to_nat, cast_to_nat]
#align pos_num.cast_mul PosNum.cast_mul
-/

#print PosNum.cmp_eq /-
@[simp]
theorem cmp_eq (m n) : cmp m n = Ordering.eq ↔ m = n :=
  by
  have := cmp_to_nat m n
  cases cmp m n <;> simp at this ⊢ <;> try exact this <;>
    · simp [show m ≠ n from fun e => by rw [e] at this  <;> exact lt_irrefl _ this]
#align pos_num.cmp_eq PosNum.cmp_eq
-/

#print PosNum.cast_lt /-
@[simp, norm_cast]
theorem cast_lt [LinearOrderedSemiring α] {m n : PosNum} : (m : α) < n ↔ m < n := by
  rw [← cast_to_nat m, ← cast_to_nat n, Nat.cast_lt, lt_to_nat]
#align pos_num.cast_lt PosNum.cast_lt
-/

#print PosNum.cast_le /-
@[simp, norm_cast]
theorem cast_le [LinearOrderedSemiring α] {m n : PosNum} : (m : α) ≤ n ↔ m ≤ n := by
  rw [← not_lt] <;> exact not_congr cast_lt
#align pos_num.cast_le PosNum.cast_le
-/

end PosNum

namespace Num

variable {α : Type _}

open PosNum

#print Num.bit_to_nat /-
theorem bit_to_nat (b n) : (bit b n : ℕ) = Nat.bit b n := by cases b <;> cases n <;> rfl
#align num.bit_to_nat Num.bit_to_nat
-/

#print Num.cast_succ' /-
theorem cast_succ' [AddMonoidWithOne α] (n) : (succ' n : α) = n + 1 := by
  rw [← PosNum.cast_to_nat, succ'_to_nat, Nat.cast_add_one, cast_to_nat]
#align num.cast_succ' Num.cast_succ'
-/

#print Num.cast_succ /-
theorem cast_succ [AddMonoidWithOne α] (n) : (succ n : α) = n + 1 :=
  cast_succ' n
#align num.cast_succ Num.cast_succ
-/

#print Num.cast_add /-
@[simp, norm_cast]
theorem cast_add [Semiring α] (m n) : ((m + n : Num) : α) = m + n := by
  rw [← cast_to_nat, add_to_nat, Nat.cast_add, cast_to_nat, cast_to_nat]
#align num.cast_add Num.cast_add
-/

#print Num.cast_bit0 /-
@[simp, norm_cast]
theorem cast_bit0 [Semiring α] (n : Num) : (n.bit0 : α) = bit0 n := by
  rw [← bit0_of_bit0, _root_.bit0, cast_add] <;> rfl
#align num.cast_bit0 Num.cast_bit0
-/

#print Num.cast_bit1 /-
@[simp, norm_cast]
theorem cast_bit1 [Semiring α] (n : Num) : (n.bit1 : α) = bit1 n := by
  rw [← bit1_of_bit1, _root_.bit1, bit0_of_bit0, cast_add, cast_bit0] <;> rfl
#align num.cast_bit1 Num.cast_bit1
-/

#print Num.cast_mul /-
@[simp, norm_cast]
theorem cast_mul [Semiring α] : ∀ m n, ((m * n : Num) : α) = m * n
  | 0, 0 => (MulZeroClass.zero_mul _).symm
  | 0, Pos q => (MulZeroClass.zero_mul _).symm
  | Pos p, 0 => (MulZeroClass.mul_zero _).symm
  | Pos p, Pos q => PosNum.cast_mul _ _
#align num.cast_mul Num.cast_mul
-/

#print Num.size_to_nat /-
theorem size_to_nat : ∀ n, (size n : ℕ) = Nat.size n
  | 0 => Nat.size_zero.symm
  | Pos p => p.size_to_nat
#align num.size_to_nat Num.size_to_nat
-/

#print Num.size_eq_natSize /-
theorem size_eq_natSize : ∀ n, (size n : ℕ) = natSize n
  | 0 => rfl
  | Pos p => p.size_eq_natSize
#align num.size_eq_nat_size Num.size_eq_natSize
-/

#print Num.natSize_to_nat /-
theorem natSize_to_nat (n) : natSize n = Nat.size n := by rw [← size_eq_nat_size, size_to_nat]
#align num.nat_size_to_nat Num.natSize_to_nat
-/

#print Num.ofNat'_eq /-
@[simp]
theorem ofNat'_eq : ∀ n, Num.ofNat' n = n :=
  Nat.binaryRec (by simp) fun b n IH => by
    rw [of_nat'] at IH ⊢
    rw [Nat.binaryRec_eq, IH]
    · cases b <;> simp [Nat.bit, bit0_of_bit0, bit1_of_bit1]
    · rfl
#align num.of_nat'_eq Num.ofNat'_eq
-/

#print Num.zneg_toZNum /-
theorem zneg_toZNum (n : Num) : -n.toZNum = n.toZNumNeg := by cases n <;> rfl
#align num.zneg_to_znum Num.zneg_toZNum
-/

#print Num.zneg_toZNumNeg /-
theorem zneg_toZNumNeg (n : Num) : -n.toZNumNeg = n.toZNum := by cases n <;> rfl
#align num.zneg_to_znum_neg Num.zneg_toZNumNeg
-/

#print Num.toZNum_inj /-
theorem toZNum_inj {m n : Num} : m.toZNum = n.toZNum ↔ m = n :=
  ⟨fun h => by cases m <;> cases n <;> cases h <;> rfl, congr_arg _⟩
#align num.to_znum_inj Num.toZNum_inj
-/

#print Num.cast_toZNum /-
@[simp, norm_cast squash]
theorem cast_toZNum [Zero α] [One α] [Add α] [Neg α] : ∀ n : Num, (n.toZNum : α) = n
  | 0 => rfl
  | Num.pos p => rfl
#align num.cast_to_znum Num.cast_toZNum
-/

#print Num.cast_toZNumNeg /-
@[simp]
theorem cast_toZNumNeg [AddGroup α] [One α] : ∀ n : Num, (n.toZNumNeg : α) = -n
  | 0 => neg_zero.symm
  | Num.pos p => rfl
#align num.cast_to_znum_neg Num.cast_toZNumNeg
-/

#print Num.add_toZNum /-
@[simp]
theorem add_toZNum (m n : Num) : Num.toZNum (m + n) = m.toZNum + n.toZNum := by
  cases m <;> cases n <;> rfl
#align num.add_to_znum Num.add_toZNum
-/

end Num

namespace PosNum

open Num

#print PosNum.pred_to_nat /-
theorem pred_to_nat {n : PosNum} (h : 1 < n) : (pred n : ℕ) = Nat.pred n :=
  by
  unfold pred
  have := pred'_to_nat n
  cases e : pred' n
  · have : (1 : ℕ) ≤ Nat.pred n := Nat.pred_le_pred ((@cast_lt ℕ _ _ _).2 h)
    rw [← pred'_to_nat, e] at this 
    exact absurd this (by decide)
  · rw [← pred'_to_nat, e]; rfl
#align pos_num.pred_to_nat PosNum.pred_to_nat
-/

#print PosNum.sub'_one /-
theorem sub'_one (a : PosNum) : sub' a 1 = (pred' a).toZNum := by cases a <;> rfl
#align pos_num.sub'_one PosNum.sub'_one
-/

#print PosNum.one_sub' /-
theorem one_sub' (a : PosNum) : sub' 1 a = (pred' a).toZNumNeg := by cases a <;> rfl
#align pos_num.one_sub' PosNum.one_sub'
-/

#print PosNum.lt_iff_cmp /-
theorem lt_iff_cmp {m n} : m < n ↔ cmp m n = Ordering.lt :=
  Iff.rfl
#align pos_num.lt_iff_cmp PosNum.lt_iff_cmp
-/

#print PosNum.le_iff_cmp /-
theorem le_iff_cmp {m n} : m ≤ n ↔ cmp m n ≠ Ordering.gt :=
  not_congr <| lt_iff_cmp.trans <| by rw [← cmp_swap] <;> cases cmp m n <;> exact by decide
#align pos_num.le_iff_cmp PosNum.le_iff_cmp
-/

end PosNum

namespace Num

variable {α : Type _}

open PosNum

#print Num.pred_to_nat /-
theorem pred_to_nat : ∀ n : Num, (pred n : ℕ) = Nat.pred n
  | 0 => rfl
  | Pos p => by rw [pred, PosNum.pred'_to_nat] <;> rfl
#align num.pred_to_nat Num.pred_to_nat
-/

#print Num.ppred_to_nat /-
theorem ppred_to_nat : ∀ n : Num, coe <$> ppred n = Nat.ppred n
  | 0 => rfl
  | Pos p => by
    rw [ppred, Option.map_some, Nat.ppred_eq_some.2] <;>
        rw [PosNum.pred'_to_nat, Nat.succ_pred_eq_of_pos (PosNum.to_nat_pos _)] <;>
      rfl
#align num.ppred_to_nat Num.ppred_to_nat
-/

#print Num.cmp_swap /-
theorem cmp_swap (m n) : (cmp m n).symm = cmp n m := by
  cases m <;> cases n <;> try unfold cmp <;> try rfl <;> apply PosNum.cmp_swap
#align num.cmp_swap Num.cmp_swap
-/

#print Num.cmp_eq /-
theorem cmp_eq (m n) : cmp m n = Ordering.eq ↔ m = n :=
  by
  have := cmp_to_nat m n
  cases cmp m n <;> simp at this ⊢ <;> try exact this <;>
    · simp [show m ≠ n from fun e => by rw [e] at this  <;> exact lt_irrefl _ this]
#align num.cmp_eq Num.cmp_eq
-/

#print Num.cast_lt /-
@[simp, norm_cast]
theorem cast_lt [LinearOrderedSemiring α] {m n : Num} : (m : α) < n ↔ m < n := by
  rw [← cast_to_nat m, ← cast_to_nat n, Nat.cast_lt, lt_to_nat]
#align num.cast_lt Num.cast_lt
-/

#print Num.cast_le /-
@[simp, norm_cast]
theorem cast_le [LinearOrderedSemiring α] {m n : Num} : (m : α) ≤ n ↔ m ≤ n := by
  rw [← not_lt] <;> exact not_congr cast_lt
#align num.cast_le Num.cast_le
-/

#print Num.cast_inj /-
@[simp, norm_cast]
theorem cast_inj [LinearOrderedSemiring α] {m n : Num} : (m : α) = n ↔ m = n := by
  rw [← cast_to_nat m, ← cast_to_nat n, Nat.cast_inj, to_nat_inj]
#align num.cast_inj Num.cast_inj
-/

#print Num.lt_iff_cmp /-
theorem lt_iff_cmp {m n} : m < n ↔ cmp m n = Ordering.lt :=
  Iff.rfl
#align num.lt_iff_cmp Num.lt_iff_cmp
-/

#print Num.le_iff_cmp /-
theorem le_iff_cmp {m n} : m ≤ n ↔ cmp m n ≠ Ordering.gt :=
  not_congr <| lt_iff_cmp.trans <| by rw [← cmp_swap] <;> cases cmp m n <;> exact by decide
#align num.le_iff_cmp Num.le_iff_cmp
-/

#print Num.bitwise'_to_nat /-
theorem bitwise'_to_nat {f : Num → Num → Num} {g : Bool → Bool → Bool} (p : PosNum → PosNum → Num)
    (gff : g false false = false) (f00 : f 0 0 = 0)
    (f0n : ∀ n, f 0 (pos n) = cond (g false true) (pos n) 0)
    (fn0 : ∀ n, f (pos n) 0 = cond (g true false) (pos n) 0)
    (fnn : ∀ m n, f (pos m) (pos n) = p m n) (p11 : p 1 1 = cond (g true true) 1 0)
    (p1b : ∀ b n, p 1 (PosNum.bit b n) = bit (g true b) (cond (g false true) (pos n) 0))
    (pb1 : ∀ a m, p (PosNum.bit a m) 1 = bit (g a true) (cond (g true false) (pos m) 0))
    (pbb : ∀ a b m n, p (PosNum.bit a m) (PosNum.bit b n) = bit (g a b) (p m n)) :
    ∀ m n : Num, (f m n : ℕ) = Nat.bitwise' g m n :=
  by
  intros;
  cases' m with m <;> cases' n with n <;> try change zero with 0 <;>
    try change ((0 : Num) : ℕ) with 0
  · rw [f00, Nat.bitwise'_zero] <;> rfl
  · unfold Nat.bitwise'; rw [f0n, Nat.binaryRec_zero]
    cases g ff tt <;> rfl
  · unfold Nat.bitwise'
    generalize h : (Pos m : ℕ) = m'; revert h
    apply Nat.bitCasesOn m' _; intro b m' h
    rw [fn0, Nat.binaryRec_eq, Nat.binaryRec_zero, ← h]
    cases g tt ff <;> rfl
    apply Nat.bitwise'_bit_aux gff
  · rw [fnn]
    have : ∀ (b) (n : PosNum), (cond b (↑n) 0 : ℕ) = ↑(cond b (Pos n) 0 : Num) := by
      intros <;> cases b <;> rfl
    induction' m with m IH m IH generalizing n <;> cases' n with n n
    any_goals change one with 1
    any_goals change Pos 1 with 1
    any_goals change PosNum.bit0 with PosNum.bit ff
    any_goals change PosNum.bit1 with PosNum.bit tt
    any_goals change ((1 : Num) : ℕ) with Nat.bit tt 0
    all_goals
      repeat'
        rw [show ∀ b n, (Pos (PosNum.bit b n) : ℕ) = Nat.bit b ↑n by intros <;> cases b <;> rfl]
      rw [Nat.bitwise'_bit]
    any_goals assumption
    any_goals rw [Nat.bitwise'_zero, p11]; cases g tt tt <;> rfl
    any_goals rw [Nat.bitwise'_zero_left, this, ← bit_to_nat, p1b]
    any_goals rw [Nat.bitwise'_zero_right _ gff, this, ← bit_to_nat, pb1]
    all_goals
      rw [← show ∀ n, ↑(p m n) = Nat.bitwise' g ↑m ↑n from IH]
      rw [← bit_to_nat, pbb]
#align num.bitwise_to_nat Num.bitwise'_to_nat
-/

#print Num.lor'_to_nat /-
@[simp, norm_cast]
theorem lor'_to_nat : ∀ m n, (lor m n : ℕ) = Nat.lor' m n := by
  apply bitwise_to_nat fun x y => Pos (PosNum.lor x y) <;> intros <;> try cases a <;>
      try cases b <;>
    rfl
#align num.lor_to_nat Num.lor'_to_nat
-/

#print Num.land'_to_nat /-
@[simp, norm_cast]
theorem land'_to_nat : ∀ m n, (land m n : ℕ) = Nat.land' m n := by
  apply bitwise_to_nat PosNum.land <;> intros <;> try cases a <;> try cases b <;> rfl
#align num.land_to_nat Num.land'_to_nat
-/

#print Num.ldiff'_to_nat /-
@[simp, norm_cast]
theorem ldiff'_to_nat : ∀ m n, (ldiff m n : ℕ) = Nat.ldiff' m n := by
  apply bitwise_to_nat PosNum.ldiff <;> intros <;> try cases a <;> try cases b <;> rfl
#align num.ldiff_to_nat Num.ldiff'_to_nat
-/

#print Num.lxor'_to_nat /-
@[simp, norm_cast]
theorem lxor'_to_nat : ∀ m n, (lxor m n : ℕ) = Nat.lxor' m n := by
  apply bitwise_to_nat PosNum.lxor <;> intros <;> try cases a <;> try cases b <;> rfl
#align num.lxor_to_nat Num.lxor'_to_nat
-/

#print Num.shiftl_to_nat /-
@[simp, norm_cast]
theorem shiftl_to_nat (m n) : (shiftl m n : ℕ) = Nat.shiftl m n :=
  by
  cases m <;> dsimp only [shiftl]; · symm; apply Nat.zero_shiftl
  simp; induction' n with n IH; · rfl
  simp [PosNum.shiftl, Nat.shiftl_succ]; rw [← IH]
#align num.shiftl_to_nat Num.shiftl_to_nat
-/

#print Num.shiftr_to_nat /-
@[simp, norm_cast]
theorem shiftr_to_nat (m n) : (shiftr m n : ℕ) = Nat.shiftr m n :=
  by
  cases' m with m <;> dsimp only [shiftr]; · symm; apply Nat.zero_shiftr
  induction' n with n IH generalizing m; · cases m <;> rfl
  cases' m with m m <;> dsimp only [PosNum.shiftr]
  · rw [Nat.shiftr_eq_div_pow]; symm; apply Nat.div_eq_of_lt
    exact @Nat.pow_lt_pow_of_lt_right 2 (by decide) 0 (n + 1) (Nat.succ_pos _)
  · trans; apply IH
    change Nat.shiftr m n = Nat.shiftr (bit1 m) (n + 1)
    rw [add_comm n 1, Nat.shiftr_add]
    apply congr_arg fun x => Nat.shiftr x n; unfold Nat.shiftr
    change (bit1 ↑m : ℕ) with Nat.bit tt m
    rw [Nat.div2_bit]
  · trans; apply IH
    change Nat.shiftr m n = Nat.shiftr (bit0 m) (n + 1)
    rw [add_comm n 1, Nat.shiftr_add]
    apply congr_arg fun x => Nat.shiftr x n; unfold Nat.shiftr
    change (bit0 ↑m : ℕ) with Nat.bit ff m
    rw [Nat.div2_bit]
#align num.shiftr_to_nat Num.shiftr_to_nat
-/

#print Num.testBit_to_nat /-
@[simp]
theorem testBit_to_nat (m n) : testBit m n = Nat.testBit m n :=
  by
  cases' m with m <;> unfold test_bit Nat.testBit
  · change (zero : Nat) with 0; rw [Nat.zero_shiftr]; rfl
  induction' n with n IH generalizing m <;> cases m <;> dsimp only [PosNum.testBit]
  · rfl
  · exact (Nat.bodd_bit _ _).symm
  · exact (Nat.bodd_bit _ _).symm
  · change ff = Nat.bodd (Nat.shiftr 1 (n + 1))
    rw [add_comm, Nat.shiftr_add]; change Nat.shiftr 1 1 with 0
    rw [Nat.zero_shiftr] <;> rfl
  · change PosNum.testBit m n = Nat.bodd (Nat.shiftr (Nat.bit tt m) (n + 1))
    rw [add_comm, Nat.shiftr_add]; unfold Nat.shiftr
    rw [Nat.div2_bit]; apply IH
  · change PosNum.testBit m n = Nat.bodd (Nat.shiftr (Nat.bit ff m) (n + 1))
    rw [add_comm, Nat.shiftr_add]; unfold Nat.shiftr
    rw [Nat.div2_bit]; apply IH
#align num.test_bit_to_nat Num.testBit_to_nat
-/

end Num

namespace ZNum

variable {α : Type _}

open PosNum

#print ZNum.cast_zero /-
@[simp, norm_cast]
theorem cast_zero [Zero α] [One α] [Add α] [Neg α] : ((0 : ZNum) : α) = 0 :=
  rfl
#align znum.cast_zero ZNum.cast_zero
-/

#print ZNum.cast_zero' /-
@[simp]
theorem cast_zero' [Zero α] [One α] [Add α] [Neg α] : (ZNum.zero : α) = 0 :=
  rfl
#align znum.cast_zero' ZNum.cast_zero'
-/

#print ZNum.cast_one /-
@[simp, norm_cast]
theorem cast_one [Zero α] [One α] [Add α] [Neg α] : ((1 : ZNum) : α) = 1 :=
  rfl
#align znum.cast_one ZNum.cast_one
-/

#print ZNum.cast_pos /-
@[simp]
theorem cast_pos [Zero α] [One α] [Add α] [Neg α] (n : PosNum) : (pos n : α) = n :=
  rfl
#align znum.cast_pos ZNum.cast_pos
-/

#print ZNum.cast_neg /-
@[simp]
theorem cast_neg [Zero α] [One α] [Add α] [Neg α] (n : PosNum) : (neg n : α) = -n :=
  rfl
#align znum.cast_neg ZNum.cast_neg
-/

#print ZNum.cast_zneg /-
@[simp, norm_cast]
theorem cast_zneg [AddGroup α] [One α] : ∀ n, ((-n : ZNum) : α) = -n
  | 0 => neg_zero.symm
  | Pos p => rfl
  | neg p => (neg_neg _).symm
#align znum.cast_zneg ZNum.cast_zneg
-/

#print ZNum.neg_zero /-
theorem neg_zero : (-0 : ZNum) = 0 :=
  rfl
#align znum.neg_zero ZNum.neg_zero
-/

#print ZNum.zneg_pos /-
theorem zneg_pos (n : PosNum) : -pos n = neg n :=
  rfl
#align znum.zneg_pos ZNum.zneg_pos
-/

#print ZNum.zneg_neg /-
theorem zneg_neg (n : PosNum) : -neg n = pos n :=
  rfl
#align znum.zneg_neg ZNum.zneg_neg
-/

#print ZNum.zneg_zneg /-
theorem zneg_zneg (n : ZNum) : - -n = n := by cases n <;> rfl
#align znum.zneg_zneg ZNum.zneg_zneg
-/

#print ZNum.zneg_bit1 /-
theorem zneg_bit1 (n : ZNum) : -n.bit1 = (-n).bitm1 := by cases n <;> rfl
#align znum.zneg_bit1 ZNum.zneg_bit1
-/

#print ZNum.zneg_bitm1 /-
theorem zneg_bitm1 (n : ZNum) : -n.bitm1 = (-n).bit1 := by cases n <;> rfl
#align znum.zneg_bitm1 ZNum.zneg_bitm1
-/

#print ZNum.zneg_succ /-
theorem zneg_succ (n : ZNum) : -n.succ = (-n).pred := by
  cases n <;> try rfl <;> rw [succ, Num.zneg_toZNumNeg] <;> rfl
#align znum.zneg_succ ZNum.zneg_succ
-/

#print ZNum.zneg_pred /-
theorem zneg_pred (n : ZNum) : -n.pred = (-n).succ := by
  rw [← zneg_zneg (succ (-n)), zneg_succ, zneg_zneg]
#align znum.zneg_pred ZNum.zneg_pred
-/

#print ZNum.abs_to_nat /-
@[simp]
theorem abs_to_nat : ∀ n, (abs n : ℕ) = Int.natAbs n
  | 0 => rfl
  | Pos p => congr_arg Int.natAbs p.to_nat_to_int
  | neg p => show Int.natAbs ((p : ℕ) : ℤ) = Int.natAbs (-p) by rw [p.to_nat_to_int, Int.natAbs_neg]
#align znum.abs_to_nat ZNum.abs_to_nat
-/

#print ZNum.abs_toZNum /-
@[simp]
theorem abs_toZNum : ∀ n : Num, abs n.toZNum = n
  | 0 => rfl
  | Num.pos p => rfl
#align znum.abs_to_znum ZNum.abs_toZNum
-/

#print ZNum.cast_to_int /-
@[simp, norm_cast]
theorem cast_to_int [AddGroupWithOne α] : ∀ n : ZNum, ((n : ℤ) : α) = n
  | 0 => by rw [cast_zero, cast_zero, Int.cast_zero]
  | Pos p => by rw [cast_pos, cast_pos, PosNum.cast_to_int]
  | neg p => by rw [cast_neg, cast_neg, Int.cast_neg, PosNum.cast_to_int]
#align znum.cast_to_int ZNum.cast_to_int
-/

#print ZNum.bit0_of_bit0 /-
theorem bit0_of_bit0 : ∀ n : ZNum, bit0 n = n.bit0
  | 0 => rfl
  | Pos a => congr_arg pos a.bit0_of_bit0
  | neg a => congr_arg neg a.bit0_of_bit0
#align znum.bit0_of_bit0 ZNum.bit0_of_bit0
-/

#print ZNum.bit1_of_bit1 /-
theorem bit1_of_bit1 : ∀ n : ZNum, bit1 n = n.bit1
  | 0 => rfl
  | Pos a => congr_arg pos a.bit1_of_bit1
  | neg a => show PosNum.sub' 1 (bit0 a) = _ by rw [PosNum.one_sub', a.bit0_of_bit0] <;> rfl
#align znum.bit1_of_bit1 ZNum.bit1_of_bit1
-/

#print ZNum.cast_bit0 /-
@[simp, norm_cast]
theorem cast_bit0 [AddGroupWithOne α] : ∀ n : ZNum, (n.bit0 : α) = bit0 n
  | 0 => (add_zero _).symm
  | Pos p => by rw [ZNum.bit0, cast_pos, cast_pos] <;> rfl
  | neg p => by
    rw [ZNum.bit0, cast_neg, cast_neg, PosNum.cast_bit0, _root_.bit0, _root_.bit0, neg_add_rev]
#align znum.cast_bit0 ZNum.cast_bit0
-/

#print ZNum.cast_bit1 /-
@[simp, norm_cast]
theorem cast_bit1 [AddGroupWithOne α] : ∀ n : ZNum, (n.bit1 : α) = bit1 n
  | 0 => by simp [ZNum.bit1, _root_.bit1, _root_.bit0]
  | Pos p => by rw [ZNum.bit1, cast_pos, cast_pos] <;> rfl
  | neg p => by
    rw [ZNum.bit1, cast_neg, cast_neg]
    cases' e : pred' p with a <;> have : p = _ := (succ'_pred' p).symm.trans (congr_arg Num.succ' e)
    · change p = 1 at this ; subst p
      simp [_root_.bit1, _root_.bit0]
    · rw [Num.succ'] at this ; subst p
      have : (↑(-↑a : ℤ) : α) = -1 + ↑(-↑a + 1 : ℤ) := by simp [add_comm]
      simpa [_root_.bit1, _root_.bit0, -add_comm]
#align znum.cast_bit1 ZNum.cast_bit1
-/

#print ZNum.cast_bitm1 /-
@[simp]
theorem cast_bitm1 [AddGroupWithOne α] (n : ZNum) : (n.bitm1 : α) = bit0 n - 1 :=
  by
  conv =>
    lhs
    rw [← zneg_zneg n]
  rw [← zneg_bit1, cast_zneg, cast_bit1]
  have : ((-1 + n + n : ℤ) : α) = (n + n + -1 : ℤ) := by simp [add_comm, add_left_comm]
  simpa [_root_.bit1, _root_.bit0, sub_eq_add_neg, -Int.add_neg_one]
#align znum.cast_bitm1 ZNum.cast_bitm1
-/

#print ZNum.add_zero /-
theorem add_zero (n : ZNum) : n + 0 = n := by cases n <;> rfl
#align znum.add_zero ZNum.add_zero
-/

#print ZNum.zero_add /-
theorem zero_add (n : ZNum) : 0 + n = n := by cases n <;> rfl
#align znum.zero_add ZNum.zero_add
-/

#print ZNum.add_one /-
theorem add_one : ∀ n : ZNum, n + 1 = succ n
  | 0 => rfl
  | Pos p => congr_arg pos p.add_one
  | neg p => by cases p <;> rfl
#align znum.add_one ZNum.add_one
-/

end ZNum

namespace PosNum

variable {α : Type _}

#print PosNum.cast_to_znum /-
theorem cast_to_znum : ∀ n : PosNum, (n : ZNum) = ZNum.pos n
  | 1 => rfl
  | bit0 p => (ZNum.bit0_of_bit0 p).trans <| congr_arg _ (cast_to_znum p)
  | bit1 p => (ZNum.bit1_of_bit1 p).trans <| congr_arg _ (cast_to_znum p)
#align pos_num.cast_to_znum PosNum.cast_to_znum
-/

attribute [-simp] Int.add_neg_one

#print PosNum.cast_sub' /-
theorem cast_sub' [AddGroupWithOne α] : ∀ m n : PosNum, (sub' m n : α) = m - n
  | a, 1 => by
    rw [sub'_one, Num.cast_toZNum, ← Num.cast_to_nat, pred'_to_nat, ← Nat.sub_one] <;>
      simp [PosNum.cast_pos]
  | 1, b => by
    rw [one_sub', Num.cast_toZNumNeg, ← neg_sub, neg_inj, ← Num.cast_to_nat, pred'_to_nat, ←
        Nat.sub_one] <;>
      simp [PosNum.cast_pos]
  | bit0 a, bit0 b => by
    rw [sub', ZNum.cast_bit0, cast_sub']
    have : ((a + -b + (a + -b) : ℤ) : α) = a + a + (-b + -b) := by simp [add_left_comm]
    simpa [_root_.bit0, sub_eq_add_neg]
  | bit0 a, bit1 b => by
    rw [sub', ZNum.cast_bitm1, cast_sub']
    have : ((-b + (a + (-b + -1)) : ℤ) : α) = (a + -1 + (-b + -b) : ℤ) := by
      simp [add_comm, add_left_comm]
    simpa [_root_.bit1, _root_.bit0, sub_eq_add_neg]
  | bit1 a, bit0 b => by
    rw [sub', ZNum.cast_bit1, cast_sub']
    have : ((-b + (a + (-b + 1)) : ℤ) : α) = (a + 1 + (-b + -b) : ℤ) := by
      simp [add_comm, add_left_comm]
    simpa [_root_.bit1, _root_.bit0, sub_eq_add_neg]
  | bit1 a, bit1 b => by
    rw [sub', ZNum.cast_bit0, cast_sub']
    have : ((-b + (a + -b) : ℤ) : α) = a + (-b + -b) := by simp [add_left_comm]
    simpa [_root_.bit1, _root_.bit0, sub_eq_add_neg]
#align pos_num.cast_sub' PosNum.cast_sub'
-/

#print PosNum.to_nat_eq_succ_pred /-
theorem to_nat_eq_succ_pred (n : PosNum) : (n : ℕ) = n.pred' + 1 := by
  rw [← Num.succ'_to_nat, n.succ'_pred']
#align pos_num.to_nat_eq_succ_pred PosNum.to_nat_eq_succ_pred
-/

#print PosNum.to_int_eq_succ_pred /-
theorem to_int_eq_succ_pred (n : PosNum) : (n : ℤ) = (n.pred' : ℕ) + 1 := by
  rw [← n.to_nat_to_int, to_nat_eq_succ_pred] <;> rfl
#align pos_num.to_int_eq_succ_pred PosNum.to_int_eq_succ_pred
-/

end PosNum

namespace Num

variable {α : Type _}

#print Num.cast_sub' /-
@[simp]
theorem cast_sub' [AddGroupWithOne α] : ∀ m n : Num, (sub' m n : α) = m - n
  | 0, 0 => (sub_zero _).symm
  | Pos a, 0 => (sub_zero _).symm
  | 0, Pos b => (zero_sub _).symm
  | Pos a, Pos b => PosNum.cast_sub' _ _
#align num.cast_sub' Num.cast_sub'
-/

#print Num.toZNum_succ /-
theorem toZNum_succ : ∀ n : Num, n.succ.toZNum = n.toZNum.succ
  | 0 => rfl
  | Pos n => rfl
#align num.to_znum_succ Num.toZNum_succ
-/

#print Num.toZNumNeg_succ /-
theorem toZNumNeg_succ : ∀ n : Num, n.succ.toZNumNeg = n.toZNumNeg.pred
  | 0 => rfl
  | Pos n => rfl
#align num.to_znum_neg_succ Num.toZNumNeg_succ
-/

#print Num.pred_succ /-
@[simp]
theorem pred_succ : ∀ n : ZNum, n.pred.succ = n
  | 0 => rfl
  | ZNum.neg p => show toZNumNeg (pos p).succ'.pred' = _ by rw [PosNum.pred'_succ'] <;> rfl
  | ZNum.pos p => by rw [ZNum.pred, ← to_znum_succ, Num.succ, PosNum.succ'_pred', to_znum]
#align num.pred_succ Num.pred_succ
-/

#print Num.succ_ofInt' /-
theorem succ_ofInt' : ∀ n, ZNum.ofInt' (n + 1) = ZNum.ofInt' n + 1
  | (n : ℕ) => by
    erw [ZNum.ofInt', ZNum.ofInt', Num.ofNat'_succ, Num.add_one, to_znum_succ, ZNum.add_one]
  | -[0+1] => by erw [ZNum.ofInt', ZNum.ofInt', of_nat'_succ, of_nat'_zero] <;> rfl
  | -[n + 1+1] => by
    erw [ZNum.ofInt', ZNum.ofInt', @Num.ofNat'_succ (n + 1), Num.add_one, to_znum_neg_succ,
      @of_nat'_succ n, Num.add_one, ZNum.add_one, pred_succ]
#align num.succ_of_int' Num.succ_ofInt'
-/

#print Num.ofInt'_toZNum /-
theorem ofInt'_toZNum : ∀ n : ℕ, toZNum n = ZNum.ofInt' n
  | 0 => rfl
  | n + 1 => by
    rw [Nat.cast_succ, Num.add_one, to_znum_succ, of_int'_to_znum, Nat.cast_succ, succ_of_int',
      ZNum.add_one]
#align num.of_int'_to_znum Num.ofInt'_toZNum
-/

#print Num.mem_ofZNum' /-
theorem mem_ofZNum' : ∀ {m : Num} {n : ZNum}, m ∈ ofZNum' n ↔ n = toZNum m
  | 0, 0 => ⟨fun _ => rfl, fun _ => rfl⟩
  | Pos m, 0 => ⟨fun h => by cases h, fun h => by cases h⟩
  | m, ZNum.pos p =>
    Option.some_inj.trans <| by cases m <;> constructor <;> intro h <;> try cases h <;> rfl
  | m, ZNum.neg p => ⟨fun h => by cases h, fun h => by cases m <;> cases h⟩
#align num.mem_of_znum' Num.mem_ofZNum'
-/

#print Num.ofZNum'_toNat /-
theorem ofZNum'_toNat : ∀ n : ZNum, coe <$> ofZNum' n = Int.toNat' n
  | 0 => rfl
  | ZNum.pos p => show _ = Int.toNat' p by rw [← PosNum.to_nat_to_int p] <;> rfl
  | ZNum.neg p =>
    (congr_arg fun x => Int.toNat' (-x)) <|
      show ((p.pred' + 1 : ℕ) : ℤ) = p by rw [← succ'_to_nat] <;> simp
#align num.of_znum'_to_nat Num.ofZNum'_toNat
-/

#print Num.ofZNum_toNat /-
@[simp]
theorem ofZNum_toNat : ∀ n : ZNum, (ofZNum n : ℕ) = Int.toNat n
  | 0 => rfl
  | ZNum.pos p => show _ = Int.toNat p by rw [← PosNum.to_nat_to_int p] <;> rfl
  | ZNum.neg p =>
    (congr_arg fun x => Int.toNat (-x)) <|
      show ((p.pred' + 1 : ℕ) : ℤ) = p by rw [← succ'_to_nat] <;> simp
#align num.of_znum_to_nat Num.ofZNum_toNat
-/

#print Num.cast_ofZNum /-
@[simp]
theorem cast_ofZNum [AddGroupWithOne α] (n : ZNum) : (ofZNum n : α) = Int.toNat n := by
  rw [← cast_to_nat, of_znum_to_nat]
#align num.cast_of_znum Num.cast_ofZNum
-/

#print Num.sub_to_nat /-
@[simp, norm_cast]
theorem sub_to_nat (m n) : ((m - n : Num) : ℕ) = m - n :=
  show (ofZNum _ : ℕ) = _ by
    rw [of_znum_to_nat, cast_sub', ← to_nat_to_int, ← to_nat_to_int, Int.toNat_sub]
#align num.sub_to_nat Num.sub_to_nat
-/

end Num

namespace ZNum

variable {α : Type _}

#print ZNum.cast_add /-
@[simp, norm_cast]
theorem cast_add [AddGroupWithOne α] : ∀ m n, ((m + n : ZNum) : α) = m + n
  | 0, a => by cases a <;> exact (_root_.zero_add _).symm
  | b, 0 => by cases b <;> exact (_root_.add_zero _).symm
  | Pos a, Pos b => PosNum.cast_add _ _
  | Pos a, neg b => by simpa only [sub_eq_add_neg] using PosNum.cast_sub' _ _
  | neg a, Pos b =>
    have : (↑b + -↑a : α) = -↑a + ↑b := by
      rw [← PosNum.cast_to_int a, ← PosNum.cast_to_int b, ← Int.cast_neg, ← Int.cast_add (-a)] <;>
        simp [add_comm]
    (PosNum.cast_sub' _ _).trans <| (sub_eq_add_neg _ _).trans this
  | neg a, neg b =>
    show -(↑(a + b) : α) = -a + -b by
      rw [PosNum.cast_add, neg_eq_iff_eq_neg, neg_add_rev, neg_neg, neg_neg, ← PosNum.cast_to_int a,
        ← PosNum.cast_to_int b, ← Int.cast_add, ← Int.cast_add, add_comm]
#align znum.cast_add ZNum.cast_add
-/

#print ZNum.cast_succ /-
@[simp]
theorem cast_succ [AddGroupWithOne α] (n) : ((succ n : ZNum) : α) = n + 1 := by
  rw [← add_one, cast_add, cast_one]
#align znum.cast_succ ZNum.cast_succ
-/

#print ZNum.mul_to_int /-
@[simp, norm_cast]
theorem mul_to_int : ∀ m n, ((m * n : ZNum) : ℤ) = m * n
  | 0, a => by cases a <;> exact (_root_.zero_mul _).symm
  | b, 0 => by cases b <;> exact (_root_.mul_zero _).symm
  | Pos a, Pos b => PosNum.cast_mul a b
  | Pos a, neg b => show -↑(a * b) = ↑a * -↑b by rw [PosNum.cast_mul, neg_mul_eq_mul_neg]
  | neg a, Pos b => show -↑(a * b) = -↑a * ↑b by rw [PosNum.cast_mul, neg_mul_eq_neg_mul]
  | neg a, neg b => show ↑(a * b) = -↑a * -↑b by rw [PosNum.cast_mul, neg_mul_neg]
#align znum.mul_to_int ZNum.mul_to_int
-/

#print ZNum.cast_mul /-
theorem cast_mul [Ring α] (m n) : ((m * n : ZNum) : α) = m * n := by
  rw [← cast_to_int, mul_to_int, Int.cast_mul, cast_to_int, cast_to_int]
#align znum.cast_mul ZNum.cast_mul
-/

#print ZNum.ofInt'_neg /-
theorem ofInt'_neg : ∀ n : ℤ, ofInt' (-n) = -ofInt' n
  | -[n+1] => show ofInt' (n + 1 : ℕ) = _ by simp only [of_int', Num.zneg_toZNumNeg]
  | 0 => show Num.toZNum _ = -Num.toZNum _ by rw [Num.ofNat'_zero] <;> rfl
  | (n + 1 : ℕ) => show Num.toZNumNeg _ = -Num.toZNum _ by rw [Num.zneg_toZNum] <;> rfl
#align znum.of_int'_neg ZNum.ofInt'_neg
-/

#print ZNum.of_to_int' /-
theorem of_to_int' : ∀ n : ZNum, ZNum.ofInt' n = n
  | 0 => by erw [of_int', Num.ofNat'_zero, Num.toZNum]
  | Pos a => by rw [cast_pos, ← PosNum.cast_to_nat, ← Num.ofInt'_toZNum, PosNum.of_to_nat] <;> rfl
  | neg a => by
    rw [cast_neg, of_int'_neg, ← PosNum.cast_to_nat, ← Num.ofInt'_toZNum, PosNum.of_to_nat] <;> rfl
#align znum.of_to_int' ZNum.of_to_int'
-/

#print ZNum.to_int_inj /-
theorem to_int_inj {m n : ZNum} : (m : ℤ) = n ↔ m = n :=
  ⟨fun h => Function.LeftInverse.injective of_to_int' h, congr_arg _⟩
#align znum.to_int_inj ZNum.to_int_inj
-/

#print ZNum.cmp_to_int /-
theorem cmp_to_int : ∀ m n, (Ordering.casesOn (cmp m n) ((m : ℤ) < n) (m = n) ((n : ℤ) < m) : Prop)
  | 0, 0 => rfl
  | Pos a, Pos b => by
    have := PosNum.cmp_to_nat a b <;> revert this <;> dsimp [cmp] <;> cases PosNum.cmp a b <;>
        dsimp <;>
      [simp; exact congr_arg Pos; simp [GT.gt]]
  | neg a, neg b => by
    have := PosNum.cmp_to_nat b a <;> revert this <;> dsimp [cmp] <;> cases PosNum.cmp b a <;>
        dsimp <;>
      [simp; simp (config := { contextual := true }); simp [GT.gt]]
  | Pos a, 0 => PosNum.cast_pos _
  | Pos a, neg b => lt_trans (neg_lt_zero.2 <| PosNum.cast_pos _) (PosNum.cast_pos _)
  | 0, neg b => neg_lt_zero.2 <| PosNum.cast_pos _
  | neg a, 0 => neg_lt_zero.2 <| PosNum.cast_pos _
  | neg a, Pos b => lt_trans (neg_lt_zero.2 <| PosNum.cast_pos _) (PosNum.cast_pos _)
  | 0, Pos b => PosNum.cast_pos _
#align znum.cmp_to_int ZNum.cmp_to_int
-/

#print ZNum.lt_to_int /-
@[norm_cast]
theorem lt_to_int {m n : ZNum} : (m : ℤ) < n ↔ m < n :=
  show (m : ℤ) < n ↔ cmp m n = Ordering.lt from
    match cmp m n, cmp_to_int m n with
    | Ordering.lt, h => by simp at h  <;> simp [h]
    | Ordering.eq, h => by simp at h  <;> simp [h, lt_irrefl] <;> exact by decide
    | Ordering.gt, h => by simp [not_lt_of_gt h] <;> exact by decide
#align znum.lt_to_int ZNum.lt_to_int
-/

#print ZNum.le_to_int /-
theorem le_to_int {m n : ZNum} : (m : ℤ) ≤ n ↔ m ≤ n := by
  rw [← not_lt] <;> exact not_congr lt_to_int
#align znum.le_to_int ZNum.le_to_int
-/

#print ZNum.cast_lt /-
@[simp, norm_cast]
theorem cast_lt [LinearOrderedRing α] {m n : ZNum} : (m : α) < n ↔ m < n := by
  rw [← cast_to_int m, ← cast_to_int n, Int.cast_lt, lt_to_int]
#align znum.cast_lt ZNum.cast_lt
-/

#print ZNum.cast_le /-
@[simp, norm_cast]
theorem cast_le [LinearOrderedRing α] {m n : ZNum} : (m : α) ≤ n ↔ m ≤ n := by
  rw [← not_lt] <;> exact not_congr cast_lt
#align znum.cast_le ZNum.cast_le
-/

#print ZNum.cast_inj /-
@[simp, norm_cast]
theorem cast_inj [LinearOrderedRing α] {m n : ZNum} : (m : α) = n ↔ m = n := by
  rw [← cast_to_int m, ← cast_to_int n, Int.cast_inj, to_int_inj]
#align znum.cast_inj ZNum.cast_inj
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/-- This tactic tries to turn an (in)equality about `znum`s to one about `int`s by rewriting.
```lean
example (n : znum) (m : znum) : n ≤ n + m * m :=
begin
  znum.transfer_rw,
  exact le_add_of_nonneg_right (mul_self_nonneg _)
end
```
-/
unsafe def transfer_rw : tactic Unit :=
  sorry
#align znum.transfer_rw znum.transfer_rw

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/--
This tactic tries to prove (in)equalities about `znum`s by transfering them to the `int` world and
then trying to call `simp`.
```lean
example (n : znum) (m : znum) : n ≤ n + m * m :=
begin
  znum.transfer,
  exact mul_self_nonneg _
end
```
-/
unsafe def transfer : tactic Unit :=
  sorry
#align znum.transfer znum.transfer

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer_rw -/
instance : LinearOrder ZNum where
  lt := (· < ·)
  lt_iff_le_not_le := by intro a b;
    run_tac
      transfer_rw;
    apply lt_iff_le_not_le
  le := (· ≤ ·)
  le_refl := by
    run_tac
      transfer
  le_trans := by intro a b c;
    run_tac
      transfer_rw;
    apply le_trans
  le_antisymm := by intro a b;
    run_tac
      transfer_rw;
    apply le_antisymm
  le_total := by intro a b;
    run_tac
      transfer_rw;
    apply le_total
  DecidableEq := ZNum.decidableEq
  decidableLe := ZNum.decidableLE
  decidableLt := ZNum.decidableLT

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
instance : AddCommGroup ZNum where
  add := (· + ·)
  add_assoc := by
    run_tac
      transfer
  zero := 0
  zero_add := zero_add
  add_zero := add_zero
  add_comm := by
    run_tac
      transfer
  neg := Neg.neg
  add_left_neg := by
    run_tac
      transfer

instance : AddMonoidWithOne ZNum :=
  { ZNum.addCommGroup with
    one := 1
    natCast := fun n => ZNum.ofInt' n
    natCast_zero := show (Num.ofNat' 0).toZNum = 0 by rw [Num.ofNat'_zero] <;> rfl
    natCast_succ := fun n =>
      show (Num.ofNat' (n + 1)).toZNum = (Num.ofNat' n).toZNum + 1 by
        rw [Num.ofNat'_succ, Num.add_one, Num.toZNum_succ, ZNum.add_one] }

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer_rw -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:69:18: unsupported non-interactive tactic znum.transfer_rw -/
instance : LinearOrderedCommRing ZNum :=
  { ZNum.linearOrder, ZNum.addCommGroup,
    ZNum.addMonoidWithOne with
    mul := (· * ·)
    mul_assoc := by
      run_tac
        transfer
    one := 1
    one_mul := by
      run_tac
        transfer
    mul_one := by
      run_tac
        transfer
    left_distrib := by
      run_tac
        transfer;
      simp [mul_add]
    right_distrib := by
      run_tac
        transfer;
      simp [mul_add, mul_comm]
    mul_comm := by
      run_tac
        transfer
    exists_pair_ne := ⟨0, 1, by decide⟩
    add_le_add_left := by intro a b h c; revert h;
      run_tac
        transfer_rw;
      exact fun h => add_le_add_left h c
    mul_pos := fun a b =>
      show 0 < a → 0 < b → 0 < a * b by
        run_tac
          transfer_rw;
        apply mul_pos
    zero_le_one := by decide }

#print ZNum.cast_sub /-
@[simp, norm_cast]
theorem cast_sub [Ring α] (m n) : ((m - n : ZNum) : α) = m - n := by simp [sub_eq_neg_add]
#align znum.cast_sub ZNum.cast_sub
-/

#print ZNum.neg_of_int /-
@[simp, norm_cast]
theorem neg_of_int : ∀ n, ((-n : ℤ) : ZNum) = -n
  | (n + 1 : ℕ) => rfl
  | 0 => by rw [Int.cast_neg, Int.cast_zero]
  | -[n+1] => (zneg_zneg _).symm
#align znum.neg_of_int ZNum.neg_of_int
-/

#print ZNum.ofInt'_eq /-
@[simp]
theorem ofInt'_eq : ∀ n : ℤ, ZNum.ofInt' n = n
  | (n : ℕ) => rfl
  | -[n+1] => by
    show Num.toZNumNeg (n + 1 : ℕ) = -(n + 1 : ℕ)
    rw [← neg_inj, neg_neg, Nat.cast_succ, Num.add_one, Num.zneg_toZNumNeg, Num.toZNum_succ,
      Nat.cast_succ, ZNum.add_one]
    rfl
#align znum.of_int'_eq ZNum.ofInt'_eq
-/

#print ZNum.of_nat_toZNum /-
@[simp]
theorem of_nat_toZNum (n : ℕ) : Num.toZNum n = n :=
  rfl
#align znum.of_nat_to_znum ZNum.of_nat_toZNum
-/

#print ZNum.of_to_int /-
@[simp, norm_cast]
theorem of_to_int (n : ZNum) : ((n : ℤ) : ZNum) = n := by rw [← of_int'_eq, of_to_int']
#align znum.of_to_int ZNum.of_to_int
-/

#print ZNum.to_of_int /-
theorem to_of_int (n : ℤ) : ((n : ZNum) : ℤ) = n :=
  Int.inductionOn' n 0 (by simp) (by simp) (by simp)
#align znum.to_of_int ZNum.to_of_int
-/

#print ZNum.of_nat_toZNumNeg /-
@[simp]
theorem of_nat_toZNumNeg (n : ℕ) : Num.toZNumNeg n = -n := by rw [← of_nat_to_znum, Num.zneg_toZNum]
#align znum.of_nat_to_znum_neg ZNum.of_nat_toZNumNeg
-/

#print ZNum.of_int_cast /-
@[simp, norm_cast]
theorem of_int_cast [AddGroupWithOne α] (n : ℤ) : ((n : ZNum) : α) = n := by
  rw [← cast_to_int, to_of_int]
#align znum.of_int_cast ZNum.of_int_cast
-/

#print ZNum.of_nat_cast /-
@[simp, norm_cast]
theorem of_nat_cast [AddGroupWithOne α] (n : ℕ) : ((n : ZNum) : α) = n := by
  rw [← Int.cast_ofNat, of_int_cast, Int.cast_ofNat]
#align znum.of_nat_cast ZNum.of_nat_cast
-/

#print ZNum.dvd_to_int /-
@[simp, norm_cast]
theorem dvd_to_int (m n : ZNum) : (m : ℤ) ∣ n ↔ m ∣ n :=
  ⟨fun ⟨k, e⟩ => ⟨k, by rw [← of_to_int n, e] <;> simp⟩, fun ⟨k, e⟩ => ⟨k, by simp [e]⟩⟩
#align znum.dvd_to_int ZNum.dvd_to_int
-/

end ZNum

namespace PosNum

#print PosNum.divMod_to_nat_aux /-
theorem divMod_to_nat_aux {n d : PosNum} {q r : Num} (h₁ : (r : ℕ) + d * bit0 q = n)
    (h₂ : (r : ℕ) < 2 * d) :
    ((divModAux d q r).2 + d * (divModAux d q r).1 : ℕ) = ↑n ∧ ((divModAux d q r).2 : ℕ) < d :=
  by
  unfold divmod_aux
  have : ∀ {r₂}, Num.ofZNum' (Num.sub' r (Num.pos d)) = some r₂ ↔ (r : ℕ) = r₂ + d :=
    by
    intro r₂
    apply num.mem_of_znum'.trans
    rw [← ZNum.to_int_inj, Num.cast_toZNum, Num.cast_sub', sub_eq_iff_eq_add, ← Int.coe_nat_inj']
    simp
  cases' e : Num.ofZNum' (Num.sub' r (Num.pos d)) with r₂ <;> simp [divmod_aux]
  · refine' ⟨h₁, lt_of_not_ge fun h => _⟩
    cases' Nat.le.dest h with r₂ e'
    rw [← Num.to_of_nat r₂, add_comm] at e' 
    cases e.symm.trans (this.2 e'.symm)
  · have := this.1 e
    constructor
    · rwa [_root_.bit1, add_comm _ 1, mul_add, mul_one, ← add_assoc, ← this]
    · rwa [this, two_mul, add_lt_add_iff_right] at h₂ 
#align pos_num.divmod_to_nat_aux PosNum.divMod_to_nat_aux
-/

#print PosNum.divMod_to_nat /-
theorem divMod_to_nat (d n : PosNum) :
    (n / d : ℕ) = (divMod d n).1 ∧ (n % d : ℕ) = (divMod d n).2 :=
  by
  rw [Nat.div_mod_unique (PosNum.cast_pos _)]
  induction' n with n IH n IH
  ·
    exact
      divmod_to_nat_aux (by simp <;> rfl) (Nat.mul_le_mul_left 2 (PosNum.cast_pos d : (0 : ℕ) < d))
  · unfold divmod
    cases' divmod d n with q r; simp only [divmod] at IH ⊢
    apply divmod_to_nat_aux <;> simp
    ·
      rw [_root_.bit1, _root_.bit1, add_right_comm, bit0_eq_two_mul (n : ℕ), ← IH.1, mul_add, ←
        bit0_eq_two_mul, mul_left_comm, ← bit0_eq_two_mul]
    · rw [← bit0_eq_two_mul]
      exact Nat.bit1_lt_bit0 IH.2
  · unfold divmod
    cases' divmod d n with q r; simp only [divmod] at IH ⊢
    apply divmod_to_nat_aux <;> simp
    ·
      rw [bit0_eq_two_mul (n : ℕ), ← IH.1, mul_add, ← bit0_eq_two_mul, mul_left_comm, ←
        bit0_eq_two_mul]
    · rw [← bit0_eq_two_mul]
      exact Nat.bit0_lt IH.2
#align pos_num.divmod_to_nat PosNum.divMod_to_nat
-/

#print PosNum.div'_to_nat /-
@[simp]
theorem div'_to_nat (n d) : (div' n d : ℕ) = n / d :=
  (divMod_to_nat _ _).1.symm
#align pos_num.div'_to_nat PosNum.div'_to_nat
-/

#print PosNum.mod'_to_nat /-
@[simp]
theorem mod'_to_nat (n d) : (mod' n d : ℕ) = n % d :=
  (divMod_to_nat _ _).2.symm
#align pos_num.mod'_to_nat PosNum.mod'_to_nat
-/

end PosNum

namespace Num

#print Num.div_zero /-
@[simp]
protected theorem div_zero (n : Num) : n / 0 = 0 :=
  show n.div 0 = 0 by cases n; rfl; simp [Num.div]
#align num.div_zero Num.div_zero
-/

#print Num.div_to_nat /-
@[simp, norm_cast]
theorem div_to_nat : ∀ n d, ((n / d : Num) : ℕ) = n / d
  | 0, 0 => by simp
  | 0, Pos d => (Nat.zero_div _).symm
  | Pos n, 0 => (Nat.div_zero _).symm
  | Pos n, Pos d => PosNum.div'_to_nat _ _
#align num.div_to_nat Num.div_to_nat
-/

#print Num.mod_zero /-
@[simp]
protected theorem mod_zero (n : Num) : n % 0 = n :=
  show n.mod 0 = n by cases n; rfl; simp [Num.mod]
#align num.mod_zero Num.mod_zero
-/

#print Num.mod_to_nat /-
@[simp, norm_cast]
theorem mod_to_nat : ∀ n d, ((n % d : Num) : ℕ) = n % d
  | 0, 0 => by simp
  | 0, Pos d => (Nat.zero_mod _).symm
  | Pos n, 0 => (Nat.mod_zero _).symm
  | Pos n, Pos d => PosNum.mod'_to_nat _ _
#align num.mod_to_nat Num.mod_to_nat
-/

#print Num.gcd_to_nat_aux /-
theorem gcd_to_nat_aux :
    ∀ {n} {a b : Num}, a ≤ b → (a * b).natSize ≤ n → (gcdAux n a b : ℕ) = Nat.gcd a b
  | 0, 0, b, ab, h => (Nat.gcd_zero_left _).symm
  | 0, Pos a, 0, ab, h => (not_lt_of_ge ab).elim rfl
  | 0, Pos a, Pos b, ab, h => (not_lt_of_le h).elim <| PosNum.natSize_pos _
  | Nat.succ n, 0, b, ab, h => (Nat.gcd_zero_left _).symm
  | Nat.succ n, Pos a, b, ab, h => by
    simp [gcd_aux]
    rw [Nat.gcd_rec, gcd_to_nat_aux, mod_to_nat]; · rfl
    · rw [← le_to_nat, mod_to_nat]
      exact le_of_lt (Nat.mod_lt _ (PosNum.cast_pos _))
    rw [nat_size_to_nat, mul_to_nat, Nat.size_le] at h ⊢
    rw [mod_to_nat, mul_comm]
    rw [pow_succ', ← Nat.mod_add_div b (Pos a)] at h 
    refine' lt_of_mul_lt_mul_right (lt_of_le_of_lt _ h) (Nat.zero_le 2)
    rw [mul_two, mul_add]
    refine'
      add_le_add_left
        (Nat.mul_le_mul_left _ (le_trans (le_of_lt (Nat.mod_lt _ (PosNum.cast_pos _))) _)) _
    suffices : 1 ≤ _; simpa using Nat.mul_le_mul_left (Pos a) this
    rw [Nat.le_div_iff_mul_le a.cast_pos, one_mul]
    exact le_to_nat.2 ab
#align num.gcd_to_nat_aux Num.gcd_to_nat_aux
-/

#print Num.gcd_to_nat /-
@[simp]
theorem gcd_to_nat : ∀ a b, (gcd a b : ℕ) = Nat.gcd a b :=
  by
  have : ∀ a b : Num, (a * b).natSize ≤ a.natSize + b.natSize :=
    by
    intros
    simp [nat_size_to_nat]
    rw [Nat.size_le, pow_add]
    exact mul_lt_mul'' (Nat.lt_size_self _) (Nat.lt_size_self _) (Nat.zero_le _) (Nat.zero_le _)
  intros
  unfold gcd
  split_ifs
  · exact gcd_to_nat_aux h (this _ _)
  · rw [Nat.gcd_comm]
    exact gcd_to_nat_aux (le_of_not_le h) (this _ _)
#align num.gcd_to_nat Num.gcd_to_nat
-/

#print Num.dvd_iff_mod_eq_zero /-
theorem dvd_iff_mod_eq_zero {m n : Num} : m ∣ n ↔ n % m = 0 := by
  rw [← dvd_to_nat, Nat.dvd_iff_mod_eq_zero, ← to_nat_inj, mod_to_nat] <;> rfl
#align num.dvd_iff_mod_eq_zero Num.dvd_iff_mod_eq_zero
-/

#print Num.decidableDvd /-
instance decidableDvd : DecidableRel ((· ∣ ·) : Num → Num → Prop)
  | a, b => decidable_of_iff' _ dvd_iff_mod_eq_zero
#align num.decidable_dvd Num.decidableDvd
-/

end Num

#print PosNum.decidableDvd /-
instance PosNum.decidableDvd : DecidableRel ((· ∣ ·) : PosNum → PosNum → Prop)
  | a, b => Num.decidableDvd _ _
#align pos_num.decidable_dvd PosNum.decidableDvd
-/

namespace ZNum

#print ZNum.div_zero /-
@[simp]
protected theorem div_zero (n : ZNum) : n / 0 = 0 :=
  show n.div 0 = 0 by
    cases n <;>
      first
      | rfl
      | simp [ZNum.div]
#align znum.div_zero ZNum.div_zero
-/

#print ZNum.div_to_int /-
@[simp, norm_cast]
theorem div_to_int : ∀ n d, ((n / d : ZNum) : ℤ) = n / d
  | 0, 0 => by simp [Int.div_zero]
  | 0, Pos d => (Int.zero_div _).symm
  | 0, neg d => (Int.zero_div _).symm
  | Pos n, 0 => (Int.div_zero _).symm
  | neg n, 0 => (Int.div_zero _).symm
  | Pos n, Pos d => (Num.cast_toZNum _).trans <| by rw [← Num.to_nat_to_int] <;> simp
  | Pos n, neg d => (Num.cast_toZNumNeg _).trans <| by rw [← Num.to_nat_to_int] <;> simp
  | neg n, Pos d =>
    show -_ = -_ / ↑d
      by
      rw [n.to_int_eq_succ_pred, d.to_int_eq_succ_pred, ← PosNum.to_nat_to_int, Num.succ'_to_nat,
        Num.div_to_nat]
      change -[n.pred' / ↑d+1] = -[n.pred' / (d.pred' + 1)+1]
      rw [d.to_nat_eq_succ_pred]
  | neg n, neg d =>
    show ↑(PosNum.pred' n / Num.pos d).succ' = -_ / -↑d
      by
      rw [n.to_int_eq_succ_pred, d.to_int_eq_succ_pred, ← PosNum.to_nat_to_int, Num.succ'_to_nat,
        Num.div_to_nat]
      change (Nat.succ (_ / d) : ℤ) = Nat.succ (n.pred' / (d.pred' + 1))
      rw [d.to_nat_eq_succ_pred]
#align znum.div_to_int ZNum.div_to_int
-/

#print ZNum.mod_to_int /-
@[simp, norm_cast]
theorem mod_to_int : ∀ n d, ((n % d : ZNum) : ℤ) = n % d
  | 0, d => (Int.zero_mod _).symm
  | Pos n, d =>
    (Num.cast_toZNum _).trans <| by
      rw [← Num.to_nat_to_int, cast_pos, Num.mod_to_nat, ← PosNum.to_nat_to_int, abs_to_nat] <;> rfl
  | neg n, d =>
    (Num.cast_sub' _ _).trans <| by
      rw [← Num.to_nat_to_int, cast_neg, ← Num.to_nat_to_int, Num.succ_to_nat, Num.mod_to_nat,
          abs_to_nat, ← Int.subNatNat_eq_coe, n.to_int_eq_succ_pred] <;>
        rfl
#align znum.mod_to_int ZNum.mod_to_int
-/

#print ZNum.gcd_to_nat /-
@[simp]
theorem gcd_to_nat (a b) : (gcd a b : ℕ) = Int.gcd a b :=
  (Num.gcd_to_nat _ _).trans <| by simpa
#align znum.gcd_to_nat ZNum.gcd_to_nat
-/

#print ZNum.dvd_iff_mod_eq_zero /-
theorem dvd_iff_mod_eq_zero {m n : ZNum} : m ∣ n ↔ n % m = 0 := by
  rw [← dvd_to_int, Int.dvd_iff_emod_eq_zero, ← to_int_inj, mod_to_int] <;> rfl
#align znum.dvd_iff_mod_eq_zero ZNum.dvd_iff_mod_eq_zero
-/

instance : DecidableRel ((· ∣ ·) : ZNum → ZNum → Prop)
  | a, b => decidable_of_iff' _ dvd_iff_mod_eq_zero

end ZNum

namespace Int

#print Int.ofSnum /-
/-- Cast a `snum` to the corresponding integer. -/
def ofSnum : SNum → ℤ :=
  SNum.rec' (fun a => cond a (-1) 0) fun a p IH => cond a (bit1 IH) (bit0 IH)
#align int.of_snum Int.ofSnum
-/

#print Int.snumCoe /-
instance snumCoe : Coe SNum ℤ :=
  ⟨ofSnum⟩
#align int.snum_coe Int.snumCoe
-/

end Int

instance : LT SNum :=
  ⟨fun a b => (a : ℤ) < b⟩

instance : LE SNum :=
  ⟨fun a b => (a : ℤ) ≤ b⟩

