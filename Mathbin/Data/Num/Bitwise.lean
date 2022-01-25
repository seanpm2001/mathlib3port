import Mathbin.Data.Num.Basic
import Mathbin.Data.Bitvec.Core

/-!
# Bitwise operations using binary representation of integers

## Definitions

* bitwise operations for `pos_num` and `num`,
* `snum`, a type that represents integers as a bit string with a sign bit at the end,
* arithmetic operations for `snum`.
-/


namespace PosNum

/-- Bitwise "or" for `pos_num`. -/
def lor : PosNum → PosNum → PosNum
  | 1, bit0 q => bit1 q
  | 1, q => q
  | bit0 p, 1 => bit1 p
  | p, 1 => p
  | bit0 p, bit0 q => bit0 (lor p q)
  | bit0 p, bit1 q => bit1 (lor p q)
  | bit1 p, bit0 q => bit1 (lor p q)
  | bit1 p, bit1 q => bit1 (lor p q)

/-- Bitwise "and" for `pos_num`. -/
def land : PosNum → PosNum → Num
  | 1, bit0 q => 0
  | 1, _ => 1
  | bit0 p, 1 => 0
  | _, 1 => 1
  | bit0 p, bit0 q => Num.bit0 (land p q)
  | bit0 p, bit1 q => Num.bit0 (land p q)
  | bit1 p, bit0 q => Num.bit0 (land p q)
  | bit1 p, bit1 q => Num.bit1 (land p q)

/-- Bitwise `λ a b, a && !b` for `pos_num`. For example, `ldiff 5 9 = 4`:

     101
    1001
    ----
     100

  -/
def ldiff : PosNum → PosNum → Num
  | 1, bit0 q => 1
  | 1, _ => 0
  | bit0 p, 1 => Num.pos (bit0 p)
  | bit1 p, 1 => Num.pos (bit0 p)
  | bit0 p, bit0 q => Num.bit0 (ldiff p q)
  | bit0 p, bit1 q => Num.bit0 (ldiff p q)
  | bit1 p, bit0 q => Num.bit1 (ldiff p q)
  | bit1 p, bit1 q => Num.bit0 (ldiff p q)

/-- Bitwise "xor" for `pos_num`. -/
def lxor : PosNum → PosNum → Num
  | 1, 1 => 0
  | 1, bit0 q => Num.pos (bit1 q)
  | 1, bit1 q => Num.pos (bit0 q)
  | bit0 p, 1 => Num.pos (bit1 p)
  | bit1 p, 1 => Num.pos (bit0 p)
  | bit0 p, bit0 q => Num.bit0 (lxor p q)
  | bit0 p, bit1 q => Num.bit1 (lxor p q)
  | bit1 p, bit0 q => Num.bit1 (lxor p q)
  | bit1 p, bit1 q => Num.bit0 (lxor p q)

/-- `a.test_bit n` is `tt` iff the `n`-th bit (starting from the LSB) in the binary representation
      of `a` is active. If the size of `a` is less than `n`, this evaluates to `ff`. -/
def test_bit : PosNum → Nat → Bool
  | 1, 0 => tt
  | 1, n + 1 => ff
  | bit0 p, 0 => ff
  | bit0 p, n + 1 => test_bit p n
  | bit1 p, 0 => tt
  | bit1 p, n + 1 => test_bit p n

/-- `n.one_bits 0` is the list of indices of active bits in the binary representation of `n`. -/
def one_bits : PosNum → Nat → List Nat
  | 1, d => [d]
  | bit0 p, d => one_bits p (d + 1)
  | bit1 p, d => d :: one_bits p (d + 1)

/-- Left-shift the binary representation of a `pos_num`. -/
def shiftl (p : PosNum) : Nat → PosNum
  | 0 => p
  | n + 1 => bit0 (shiftl n)

/-- Right-shift the binary representation of a `pos_num`. -/
def shiftr : PosNum → Nat → Num
  | p, 0 => Num.pos p
  | 1, n + 1 => 0
  | bit0 p, n + 1 => shiftr p n
  | bit1 p, n + 1 => shiftr p n

end PosNum

namespace Num

/-- Bitwise "or" for `num`. -/
def lor : Num → Num → Num
  | 0, q => q
  | p, 0 => p
  | Pos p, Pos q => Pos (p.lor q)

/-- Bitwise "and" for `num`. -/
def land : Num → Num → Num
  | 0, q => 0
  | p, 0 => 0
  | Pos p, Pos q => p.land q

/-- Bitwise `λ a b, a && !b` for `num`. For example, `ldiff 5 9 = 4`:

     101
    1001
    ----
     100

  -/
def ldiff : Num → Num → Num
  | 0, q => 0
  | p, 0 => p
  | Pos p, Pos q => p.ldiff q

/-- Bitwise "xor" for `num`. -/
def lxor : Num → Num → Num
  | 0, q => q
  | p, 0 => p
  | Pos p, Pos q => p.lxor q

/-- Left-shift the binary representation of a `num`. -/
def shiftl : Num → Nat → Num
  | 0, n => 0
  | Pos p, n => Pos (p.shiftl n)

/-- Right-shift the binary representation of a `pos_num`. -/
def shiftr : Num → Nat → Num
  | 0, n => 0
  | Pos p, n => p.shiftr n

/-- `a.test_bit n` is `tt` iff the `n`-th bit (starting from the LSB) in the binary representation
      of `a` is active. If the size of `a` is less than `n`, this evaluates to `ff`. -/
def test_bit : Num → Nat → Bool
  | 0, n => ff
  | Pos p, n => p.test_bit n

/-- `n.one_bits` is the list of indices of active bits in the binary representation of `n`. -/
def one_bits : Num → List Nat
  | 0 => []
  | Pos p => p.one_bits 0

end Num

/-- This is a nonzero (and "non minus one") version of `snum`.
    See the documentation of `snum` for more details. -/
inductive Nzsnum : Type
  | msb : Bool → Nzsnum
  | bit : Bool → Nzsnum → Nzsnum
  deriving has_reflect, DecidableEq

/-- Alternative representation of integers using a sign bit at the end.
  The convention on sign here is to have the argument to `msb` denote
  the sign of the MSB itself, with all higher bits set to the negation
  of this sign. The result is interpreted in two's complement.

     13  = ..0001101(base 2) = nz (bit1 (bit0 (bit1 (msb tt))))
     -13 = ..1110011(base 2) = nz (bit1 (bit1 (bit0 (msb ff))))

  As with `num`, a special case must be added for zero, which has no msb,
  but by two's complement symmetry there is a second special case for -1.
  Here the `bool` field indicates the sign of the number.

     0  = ..0000000(base 2) = zero ff
     -1 = ..1111111(base 2) = zero tt -/
inductive Snum : Type
  | zero : Bool → Snum
  | nz : Nzsnum → Snum
  deriving has_reflect, DecidableEq

instance : Coe Nzsnum Snum :=
  ⟨Snum.nz⟩

instance : Zero Snum :=
  ⟨Snum.zero ff⟩

instance : One Nzsnum :=
  ⟨Nzsnum.msb tt⟩

instance : One Snum :=
  ⟨Snum.nz 1⟩

instance : Inhabited Nzsnum :=
  ⟨1⟩

instance : Inhabited Snum :=
  ⟨0⟩

/-!
The `snum` representation uses a bit string, essentially a list of 0 (`ff`) and 1 (`tt`) bits,
and the negation of the MSB is sign-extended to all higher bits.
-/


namespace Nzsnum

/-- Sign of a `nzsnum`. -/
def sign : Nzsnum → Bool
  | msb b => bnot b
  | b :: p => sign p

/-- Bitwise `not` for `nzsnum`. -/
@[matchPattern]
def Not : Nzsnum → Nzsnum
  | msb b => msb (bnot b)
  | b :: p => bnot b :: Not p

prefix:100 "~" => Not

/-- Add an inactive bit at the end of a `nzsnum`. This mimics `pos_num.bit0`. -/
def bit0 : Nzsnum → Nzsnum :=
  bit ff

/-- Add an active bit at the end of a `nzsnum`. This mimics `pos_num.bit1`. -/
def bit1 : Nzsnum → Nzsnum :=
  bit tt

/-- The `head` of a `nzsnum` is the boolean value of its LSB. -/
def head : Nzsnum → Bool
  | msb b => b
  | b :: p => b

/-- The `tail` of a `nzsnum` is the `snum` obtained by removing the LSB.
      Edge cases: `tail 1 = 0` and `tail (-2) = -1`. -/
def tail : Nzsnum → Snum
  | msb b => Snum.zero (bnot b)
  | b :: p => p

end Nzsnum

namespace Snum

open Nzsnum

/-- Sign of a `snum`. -/
def sign : Snum → Bool
  | zero z => z
  | nz p => p.sign

/-- Bitwise `not` for `snum`. -/
@[matchPattern]
def Not : Snum → Snum
  | zero z => zero (bnot z)
  | nz p => ~p

prefix:0 "~" => Not

/-- Add a bit at the end of a `snum`. This mimics `nzsnum.bit`. -/
@[matchPattern]
def bit : Bool → Snum → Snum
  | b, zero z => if b = z then zero b else msb b
  | b, nz p => p.bit b

/-- Add an inactive bit at the end of a `snum`. This mimics `znum.bit0`. -/
def bit0 : Snum → Snum :=
  bit ff

/-- Add an active bit at the end of a `snum`. This mimics `znum.bit1`. -/
def bit1 : Snum → Snum :=
  bit tt

theorem bit_zero b : b :: zero b = zero b := by
  cases b <;> rfl

theorem bit_one b : b :: zero (bnot b) = msb b := by
  cases b <;> rfl

end Snum

namespace Nzsnum

open Snum

/-- A dependent induction principle for `nzsnum`, with base cases
      `0 : snum` and `(-1) : snum`. -/
def drec' {C : Snum → Sort _} (z : ∀ b, C (Snum.zero b)) (s : ∀ b p, C p → C (b :: p)) : ∀ p : Nzsnum, C p
  | msb b => by
    rw [← bit_one] <;> exact s b (Snum.zero (bnot b)) (z (bnot b))
  | bit b p => s b p (drec' p)

end Nzsnum

namespace Snum

open Nzsnum

/-- The `head` of a `snum` is the boolean value of its LSB. -/
def head : Snum → Bool
  | zero z => z
  | nz p => p.head

/-- The `tail` of a `snum` is obtained by removing the LSB.
      Edge cases: `tail 1 = 0`, `tail (-2) = -1`, `tail 0 = 0` and `tail (-1) = -1`. -/
def tail : Snum → Snum
  | zero z => zero z
  | nz p => p.tail

/-- A dependent induction principle for `snum` which avoids relying on `nzsnum`. -/
def drec' {C : Snum → Sort _} (z : ∀ b, C (Snum.zero b)) (s : ∀ b p, C p → C (b :: p)) : ∀ p, C p
  | zero b => z b
  | nz p => p.drec' z s

/-- An induction principle for `snum` which avoids relying on `nzsnum`. -/
def rec' {α} (z : Bool → α) (s : Bool → Snum → α → α) : Snum → α :=
  drec' z s

/-- `snum.test_bit n a` is `tt` iff the `n`-th bit (starting from the LSB) of `a` is active.
      If the size of `a` is less than `n`, this evaluates to `ff`. -/
def test_bit : Nat → Snum → Bool
  | 0, p => head p
  | n + 1, p => test_bit n (tail p)

/-- The successor of a `snum` (i.e. the operation adding one). -/
def succ : Snum → Snum :=
  rec' (fun b => cond b 0 1) fun b p succp => cond b (ff :: succp) (tt :: p)

/-- The predecessor of a `snum` (i.e. the operation of removing one). -/
def pred : Snum → Snum :=
  rec' (fun b => cond b (~1) (~0)) fun b p predp => cond b (ff :: p) (tt :: predp)

/-- The opposite of a `snum`. -/
protected def neg (n : Snum) : Snum :=
  succ (~n)

instance : Neg Snum :=
  ⟨Snum.neg⟩

/-- `snum.czadd a b n` is `n + a - b` (where `a` and `b` should be read as either 0 or 1).
      This is useful to implement the carry system in `cadd`. -/
def czadd : Bool → Bool → Snum → Snum
  | ff, ff, p => p
  | ff, tt, p => pred p
  | tt, ff, p => succ p
  | tt, tt, p => p

end Snum

namespace Snum

/-- `a.bits n` is the vector of the `n` first bits of `a` (starting from the LSB). -/
def bits : Snum → ∀ n, Vector Bool n
  | p, 0 => Vector.nil
  | p, n + 1 => head p::ᵥbits (tail p) n

def cadd : Snum → Snum → Bool → Snum :=
  (rec' fun a p c => czadd c a p) $ fun a p IH =>
    (rec' fun b c => czadd c b (a :: p)) $ fun b q _ c => Bitvec.xor3 a b c :: IH q (Bitvec.carry a b c)

/-- Add two `snum`s. -/
protected def add (a b : Snum) : Snum :=
  cadd a b ff

instance : Add Snum :=
  ⟨Snum.add⟩

/-- Substract two `snum`s. -/
protected def sub (a b : Snum) : Snum :=
  a + -b

instance : Sub Snum :=
  ⟨Snum.sub⟩

/-- Multiply two `snum`s. -/
protected def mul (a : Snum) : Snum → Snum :=
  (rec' fun b => cond b (-a) 0) $ fun b q IH => cond b (bit0 IH + a) (bit0 IH)

instance : Mul Snum :=
  ⟨Snum.mul⟩

end Snum

