/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Mario Carneiro

! This file was ported from Lean 3 source module logic.encodable.basic
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Logic.Equiv.Nat
import Mathbin.Data.Pnat.Basic
import Mathbin.Order.Directed
import Mathbin.Data.Countable.Defs
import Mathbin.Order.RelIso.Basic
import Mathbin.Data.Fin.Basic

/-!
# Encodable types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines encodable (constructively countable) types as a typeclass.
This is used to provide explicit encode/decode functions from and to `ℕ`, with the information that
those functions are inverses of each other.
The difference with `denumerable` is that finite types are encodable. For infinite types,
`encodable` and `denumerable` agree.

## Main declarations

* `encodable α`: States that there exists an explicit encoding function `encode : α → ℕ` with a
  partial inverse `decode : ℕ → option α`.
* `decode₂`: Version of `decode` that is equal to `none` outside of the range of `encode`. Useful as
  we do not require this in the definition of `decode`.
* `ulower α`: Any encodable type has an equivalent type living in the lowest universe, namely a
  subtype of `ℕ`. `ulower α` finds it.

## Implementation notes

The point of asking for an explicit partial inverse `decode : ℕ → option α` to `encode : α → ℕ` is
to make the range of `encode` decidable even when the finiteness of `α` is not.
-/


open Option List Nat Function

#print Encodable /-
/- ./././Mathport/Syntax/Translate/Command.lean:388:30: infer kinds are unsupported in Lean 4: #[`decode] [] -/
/-- Constructively countable type. Made from an explicit injection `encode : α → ℕ` and a partial
inverse `decode : ℕ → option α`. Note that finite types *are* countable. See `denumerable` if you
wish to enforce infiniteness. -/
class Encodable (α : Type _) where
  encode : α → ℕ
  decode : ℕ → Option α
  encodek : ∀ a, decode (encode a) = some a
#align encodable Encodable
-/

attribute [simp] Encodable.encodek

namespace Encodable

variable {α : Type _} {β : Type _}

universe u

#print Encodable.encode_injective /-
theorem encode_injective [Encodable α] : Function.Injective (@encode α _)
  | x, y, e => Option.some.inj <| by rw [← encodek, e, encodek]
#align encodable.encode_injective Encodable.encode_injective
-/

#print Encodable.encode_inj /-
@[simp]
theorem encode_inj [Encodable α] {a b : α} : encode a = encode b ↔ a = b :=
  encode_injective.eq_iff
#align encodable.encode_inj Encodable.encode_inj
-/

-- The priority of the instance below is less than the priorities of `subtype.countable`
-- and `quotient.countable`
instance (priority := 400) [Encodable α] : Countable α :=
  encode_injective.Countable

#print Encodable.surjective_decode_iget /-
theorem surjective_decode_iget (α : Type _) [Encodable α] [Inhabited α] :
    Surjective fun n => (Encodable.decode α n).iget := fun x =>
  ⟨Encodable.encode x, by simp_rw [Encodable.encodek]⟩
#align encodable.surjective_decode_iget Encodable.surjective_decode_iget
-/

#print Encodable.decidableEqOfEncodable /-
/-- An encodable type has decidable equality. Not set as an instance because this is usually not the
best way to infer decidability. -/
def decidableEqOfEncodable (α) [Encodable α] : DecidableEq α
  | a, b => decidable_of_iff _ encode_inj
#align encodable.decidable_eq_of_encodable Encodable.decidableEqOfEncodable
-/

#print Encodable.ofLeftInjection /-
/-- If `α` is encodable and there is an injection `f : β → α`, then `β` is encodable as well. -/
def ofLeftInjection [Encodable α] (f : β → α) (finv : α → Option β)
    (linv : ∀ b, finv (f b) = some b) : Encodable β :=
  ⟨fun b => encode (f b), fun n => (decode α n).bind finv, fun b => by
    simp [Encodable.encodek, linv]⟩
#align encodable.of_left_injection Encodable.ofLeftInjection
-/

#print Encodable.ofLeftInverse /-
/-- If `α` is encodable and `f : β → α` is invertible, then `β` is encodable as well. -/
def ofLeftInverse [Encodable α] (f : β → α) (finv : α → β) (linv : ∀ b, finv (f b) = b) :
    Encodable β :=
  ofLeftInjection f (some ∘ finv) fun b => congr_arg some (linv b)
#align encodable.of_left_inverse Encodable.ofLeftInverse
-/

#print Encodable.ofEquiv /-
/-- Encodability is preserved by equivalence. -/
def ofEquiv (α) [Encodable α] (e : β ≃ α) : Encodable β :=
  ofLeftInverse e e.symm e.left_inv
#align encodable.of_equiv Encodable.ofEquiv
-/

/- warning: encodable.encode_of_equiv -> Encodable.encode_ofEquiv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : Encodable.{u1} α] (e : Equiv.{succ u2, succ u1} β α) (b : β), Eq.{1} Nat (Encodable.encode.{u2} β (Encodable.ofEquiv.{u2, u1} β α _inst_1 e) b) (Encodable.encode.{u1} α _inst_1 (coeFn.{max 1 (max (succ u2) (succ u1)) (succ u1) (succ u2), max (succ u2) (succ u1)} (Equiv.{succ u2, succ u1} β α) (fun (_x : Equiv.{succ u2, succ u1} β α) => β -> α) (Equiv.hasCoeToFun.{succ u2, succ u1} β α) e b))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : Encodable.{u2} α] (e : Equiv.{succ u1, succ u2} β α) (b : β), Eq.{1} Nat (Encodable.encode.{u1} β (Encodable.ofEquiv.{u1, u2} β α _inst_1 e) b) (Encodable.encode.{u2} ((fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) b) _inst_1 (FunLike.coe.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β (fun (_x : β) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : β) => α) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β α (EquivLike.toEmbeddingLike.{max (succ u2) (succ u1), succ u1, succ u2} (Equiv.{succ u1, succ u2} β α) β α (Equiv.instEquivLikeEquiv.{succ u1, succ u2} β α))) e b))
Case conversion may be inaccurate. Consider using '#align encodable.encode_of_equiv Encodable.encode_ofEquivₓ'. -/
@[simp]
theorem encode_ofEquiv {α β} [Encodable α] (e : β ≃ α) (b : β) :
    @encode _ (ofEquiv _ e) b = encode (e b) :=
  rfl
#align encodable.encode_of_equiv Encodable.encode_ofEquiv

/- warning: encodable.decode_of_equiv -> Encodable.decode_ofEquiv is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : Encodable.{u1} α] (e : Equiv.{succ u2, succ u1} β α) (n : Nat), Eq.{succ u2} (Option.{u2} β) (Encodable.decode.{u2} β (Encodable.ofEquiv.{u2, u1} β α _inst_1 e) n) (Option.map.{u1, u2} α β (coeFn.{max 1 (max (succ u1) (succ u2)) (succ u2) (succ u1), max (succ u1) (succ u2)} (Equiv.{succ u1, succ u2} α β) (fun (_x : Equiv.{succ u1, succ u2} α β) => α -> β) (Equiv.hasCoeToFun.{succ u1, succ u2} α β) (Equiv.symm.{succ u2, succ u1} β α e)) (Encodable.decode.{u1} α _inst_1 n))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : Encodable.{u2} α] (e : Equiv.{succ u1, succ u2} β α) (n : Nat), Eq.{succ u1} (Option.{u1} β) (Encodable.decode.{u1} β (Encodable.ofEquiv.{u1, u2} β α _inst_1 e) n) (Option.map.{u2, u1} α β (FunLike.coe.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α (fun (_x : α) => (fun (x._@.Mathlib.Data.FunLike.Embedding._hyg.19 : α) => β) _x) (EmbeddingLike.toFunLike.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α β (EquivLike.toEmbeddingLike.{max (succ u2) (succ u1), succ u2, succ u1} (Equiv.{succ u2, succ u1} α β) α β (Equiv.instEquivLikeEquiv.{succ u2, succ u1} α β))) (Equiv.symm.{succ u1, succ u2} β α e)) (Encodable.decode.{u2} α _inst_1 n))
Case conversion may be inaccurate. Consider using '#align encodable.decode_of_equiv Encodable.decode_ofEquivₓ'. -/
@[simp]
theorem decode_ofEquiv {α β} [Encodable α] (e : β ≃ α) (n : ℕ) :
    @decode _ (ofEquiv _ e) n = (decode α n).map e.symm :=
  rfl
#align encodable.decode_of_equiv Encodable.decode_ofEquiv

#print Encodable.Nat.encodable /-
instance Encodable.Nat.encodable : Encodable ℕ :=
  ⟨id, some, fun a => rfl⟩
#align nat.encodable Encodable.Nat.encodable
-/

#print Encodable.encode_nat /-
@[simp]
theorem encode_nat (n : ℕ) : encode n = n :=
  rfl
#align encodable.encode_nat Encodable.encode_nat
-/

#print Encodable.decode_nat /-
@[simp]
theorem decode_nat (n : ℕ) : decode ℕ n = some n :=
  rfl
#align encodable.decode_nat Encodable.decode_nat
-/

#print Encodable.IsEmpty.toEncodable /-
instance (priority := 100) Encodable.IsEmpty.toEncodable [IsEmpty α] : Encodable α :=
  ⟨isEmptyElim, fun n => none, isEmptyElim⟩
#align is_empty.to_encodable Encodable.IsEmpty.toEncodable
-/

#print Encodable.PUnit.encodable /-
instance Encodable.PUnit.encodable : Encodable PUnit :=
  ⟨fun _ => 0, fun n => Nat.casesOn n (some PUnit.unit) fun _ => none, fun _ => by simp⟩
#align punit.encodable Encodable.PUnit.encodable
-/

#print Encodable.encode_star /-
@[simp]
theorem encode_star : encode PUnit.unit = 0 :=
  rfl
#align encodable.encode_star Encodable.encode_star
-/

#print Encodable.decode_unit_zero /-
@[simp]
theorem decode_unit_zero : decode PUnit 0 = some PUnit.unit :=
  rfl
#align encodable.decode_unit_zero Encodable.decode_unit_zero
-/

#print Encodable.decode_unit_succ /-
@[simp]
theorem decode_unit_succ (n) : decode PUnit (succ n) = none :=
  rfl
#align encodable.decode_unit_succ Encodable.decode_unit_succ
-/

#print Option.encodable /-
/-- If `α` is encodable, then so is `option α`. -/
instance Option.encodable {α : Type _} [h : Encodable α] : Encodable (Option α) :=
  ⟨fun o => Option.casesOn o Nat.zero fun a => succ (encode a), fun n =>
    Nat.casesOn n (some none) fun m => (decode α m).map some, fun o => by
    cases o <;> dsimp <;> simp [encodek, Nat.succ_ne_zero]⟩
#align option.encodable Option.encodable
-/

#print Encodable.encode_none /-
@[simp]
theorem encode_none [Encodable α] : encode (@none α) = 0 :=
  rfl
#align encodable.encode_none Encodable.encode_none
-/

#print Encodable.encode_some /-
@[simp]
theorem encode_some [Encodable α] (a : α) : encode (some a) = succ (encode a) :=
  rfl
#align encodable.encode_some Encodable.encode_some
-/

#print Encodable.decode_option_zero /-
@[simp]
theorem decode_option_zero [Encodable α] : decode (Option α) 0 = some none :=
  rfl
#align encodable.decode_option_zero Encodable.decode_option_zero
-/

#print Encodable.decode_option_succ /-
@[simp]
theorem decode_option_succ [Encodable α] (n) : decode (Option α) (succ n) = (decode α n).map some :=
  rfl
#align encodable.decode_option_succ Encodable.decode_option_succ
-/

#print Encodable.decode₂ /-
/-- Failsafe variant of `decode`. `decode₂ α n` returns the preimage of `n` under `encode` if it
exists, and returns `none` if it doesn't. This requirement could be imposed directly on `decode` but
is not to help make the definition easier to use. -/
def decode₂ (α) [Encodable α] (n : ℕ) : Option α :=
  (decode α n).bind (Option.guard fun a => encode a = n)
#align encodable.decode₂ Encodable.decode₂
-/

#print Encodable.mem_decode₂' /-
theorem mem_decode₂' [Encodable α] {n : ℕ} {a : α} :
    a ∈ decode₂ α n ↔ a ∈ decode α n ∧ encode a = n := by
  simp [decode₂] <;> exact ⟨fun ⟨_, h₁, rfl, h₂⟩ => ⟨h₁, h₂⟩, fun ⟨h₁, h₂⟩ => ⟨_, h₁, rfl, h₂⟩⟩
#align encodable.mem_decode₂' Encodable.mem_decode₂'
-/

#print Encodable.mem_decode₂ /-
theorem mem_decode₂ [Encodable α] {n : ℕ} {a : α} : a ∈ decode₂ α n ↔ encode a = n :=
  mem_decode₂'.trans (and_iff_right_of_imp fun e => e ▸ encodek _)
#align encodable.mem_decode₂ Encodable.mem_decode₂
-/

#print Encodable.decode₂_eq_some /-
theorem decode₂_eq_some [Encodable α] {n : ℕ} {a : α} : decode₂ α n = some a ↔ encode a = n :=
  mem_decode₂
#align encodable.decode₂_eq_some Encodable.decode₂_eq_some
-/

#print Encodable.decode₂_encode /-
@[simp]
theorem decode₂_encode [Encodable α] (a : α) : decode₂ α (encode a) = some a :=
  by
  ext
  simp [mem_decode₂, eq_comm]
#align encodable.decode₂_encode Encodable.decode₂_encode
-/

#print Encodable.decode₂_ne_none_iff /-
theorem decode₂_ne_none_iff [Encodable α] {n : ℕ} :
    decode₂ α n ≠ none ↔ n ∈ Set.range (encode : α → ℕ) := by
  simp_rw [Set.range, Set.mem_setOf_eq, Ne.def, Option.eq_none_iff_forall_not_mem,
    Encodable.mem_decode₂, not_forall, not_not]
#align encodable.decode₂_ne_none_iff Encodable.decode₂_ne_none_iff
-/

#print Encodable.decode₂_is_partial_inv /-
theorem decode₂_is_partial_inv [Encodable α] : IsPartialInv encode (decode₂ α) := fun a n =>
  mem_decode₂
#align encodable.decode₂_is_partial_inv Encodable.decode₂_is_partial_inv
-/

#print Encodable.decode₂_inj /-
theorem decode₂_inj [Encodable α] {n : ℕ} {a₁ a₂ : α} (h₁ : a₁ ∈ decode₂ α n)
    (h₂ : a₂ ∈ decode₂ α n) : a₁ = a₂ :=
  encode_injective <| (mem_decode₂.1 h₁).trans (mem_decode₂.1 h₂).symm
#align encodable.decode₂_inj Encodable.decode₂_inj
-/

#print Encodable.encodek₂ /-
theorem encodek₂ [Encodable α] (a : α) : decode₂ α (encode a) = some a :=
  mem_decode₂.2 rfl
#align encodable.encodek₂ Encodable.encodek₂
-/

#print Encodable.decidableRangeEncode /-
/-- The encoding function has decidable range. -/
def decidableRangeEncode (α : Type _) [Encodable α] : DecidablePred (· ∈ Set.range (@encode α _)) :=
  fun x =>
  decidable_of_iff (Option.isSome (decode₂ α x))
    ⟨fun h => ⟨Option.get h, by rw [← decode₂_is_partial_inv (Option.get h), Option.some_get]⟩,
      fun ⟨n, hn⟩ => by rw [← hn, encodek₂] <;> exact rfl⟩
#align encodable.decidable_range_encode Encodable.decidableRangeEncode
-/

#print Encodable.equivRangeEncode /-
/-- An encodable type is equivalent to the range of its encoding function. -/
def equivRangeEncode (α : Type _) [Encodable α] : α ≃ Set.range (@encode α _)
    where
  toFun := fun a : α => ⟨encode a, Set.mem_range_self _⟩
  invFun n :=
    Option.get
      (show isSome (decode₂ α n.1) by cases' n.2 with x hx <;> rw [← hx, encodek₂] <;> exact rfl)
  left_inv a := by dsimp <;> rw [← Option.some_inj, Option.some_get, encodek₂]
  right_inv := fun ⟨n, x, hx⟩ => by
    apply Subtype.eq
    dsimp
    conv =>
      rhs
      rw [← hx]
    rw [encode_injective.eq_iff, ← Option.some_inj, Option.some_get, ← hx, encodek₂]
#align encodable.equiv_range_encode Encodable.equivRangeEncode
-/

#print Encodable.Unique.encodable /-
/-- A type with unique element is encodable. This is not an instance to avoid diamonds. -/
def Encodable.Unique.encodable [Unique α] : Encodable α :=
  ⟨fun _ => 0, fun _ => some default, Unique.forall_iff.2 rfl⟩
#align unique.encodable Encodable.Unique.encodable
-/

section Sum

variable [Encodable α] [Encodable β]

#print Encodable.encodeSum /-
/-- Explicit encoding function for the sum of two encodable types. -/
def encodeSum : Sum α β → ℕ
  | Sum.inl a => bit0 <| encode a
  | Sum.inr b => bit1 <| encode b
#align encodable.encode_sum Encodable.encodeSum
-/

#print Encodable.decodeSum /-
/-- Explicit decoding function for the sum of two encodable types. -/
def decodeSum (n : ℕ) : Option (Sum α β) :=
  match boddDiv2 n with
  | (ff, m) => (decode α m).map Sum.inl
  | (tt, m) => (decode β m).map Sum.inr
#align encodable.decode_sum Encodable.decodeSum
-/

#print Encodable.Sum.encodable /-
/-- If `α` and `β` are encodable, then so is their sum. -/
instance Encodable.Sum.encodable : Encodable (Sum α β) :=
  ⟨encodeSum, decodeSum, fun s => by cases s <;> simp [encode_sum, decode_sum, encodek] <;> rfl⟩
#align sum.encodable Encodable.Sum.encodable
-/

@[simp]
theorem encode_inl (a : α) : @encode (Sum α β) _ (Sum.inl a) = bit0 (encode a) :=
  rfl
#align encodable.encode_inl Encodable.encode_inlₓ

@[simp]
theorem encode_inr (b : β) : @encode (Sum α β) _ (Sum.inr b) = bit1 (encode b) :=
  rfl
#align encodable.encode_inr Encodable.encode_inrₓ

/- warning: encodable.decode_sum_val -> Encodable.decode_sum_val is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : Encodable.{u1} α] [_inst_2 : Encodable.{u2} β] (n : Nat), Eq.{succ (max u1 u2)} (Option.{max u1 u2} (Sum.{u1, u2} α β)) (Encodable.decode.{max u1 u2} (Sum.{u1, u2} α β) (Encodable.Sum.encodable.{u1, u2} α β _inst_1 _inst_2) n) (Encodable.decodeSum.{u1, u2} α β _inst_1 _inst_2 n)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : Encodable.{u2} α] [_inst_2 : Encodable.{u1} β] (n : Nat), Eq.{max (succ u2) (succ u1)} (Option.{max u2 u1} (Sum.{u2, u1} α β)) (Encodable.decode.{max u2 u1} (Sum.{u2, u1} α β) (Encodable.Sum.encodable.{u2, u1} α β _inst_1 _inst_2) n) (Encodable.decodeSum.{u2, u1} α β _inst_1 _inst_2 n)
Case conversion may be inaccurate. Consider using '#align encodable.decode_sum_val Encodable.decode_sum_valₓ'. -/
@[simp]
theorem decode_sum_val (n : ℕ) : decode (Sum α β) n = decodeSum n :=
  rfl
#align encodable.decode_sum_val Encodable.decode_sum_val

end Sum

#print Encodable.Bool.encodable /-
instance Encodable.Bool.encodable : Encodable Bool :=
  ofEquiv (Sum Unit Unit) Equiv.boolEquivPUnitSumPUnit
#align bool.encodable Encodable.Bool.encodable
-/

#print Encodable.encode_true /-
@[simp]
theorem encode_true : encode true = 1 :=
  rfl
#align encodable.encode_tt Encodable.encode_true
-/

#print Encodable.encode_false /-
@[simp]
theorem encode_false : encode false = 0 :=
  rfl
#align encodable.encode_ff Encodable.encode_false
-/

#print Encodable.decode_zero /-
@[simp]
theorem decode_zero : decode Bool 0 = some false :=
  rfl
#align encodable.decode_zero Encodable.decode_zero
-/

#print Encodable.decode_one /-
@[simp]
theorem decode_one : decode Bool 1 = some true :=
  rfl
#align encodable.decode_one Encodable.decode_one
-/

#print Encodable.decode_ge_two /-
theorem decode_ge_two (n) (h : 2 ≤ n) : decode Bool n = none :=
  by
  suffices decode_sum n = none by
    change (decode_sum n).map _ = none
    rw [this]
    rfl
  have : 1 ≤ div2 n := by
    rw [div2_val, Nat.le_div_iff_mul_le]
    exacts[h, by decide]
  cases' exists_eq_succ_of_ne_zero (ne_of_gt this) with m e
  simp [decode_sum] <;> cases bodd n <;> simp [decode_sum] <;> rw [e] <;> rfl
#align encodable.decode_ge_two Encodable.decode_ge_two
-/

#print Encodable.PropCat.encodable /-
noncomputable instance Encodable.PropCat.encodable : Encodable Prop :=
  ofEquiv Bool Equiv.propEquivBool
#align Prop.encodable Encodable.PropCat.encodable
-/

section Sigma

variable {γ : α → Type _} [Encodable α] [∀ a, Encodable (γ a)]

#print Encodable.encodeSigma /-
/-- Explicit encoding function for `sigma γ` -/
def encodeSigma : Sigma γ → ℕ
  | ⟨a, b⟩ => mkpair (encode a) (encode b)
#align encodable.encode_sigma Encodable.encodeSigma
-/

#print Encodable.decodeSigma /-
/-- Explicit decoding function for `sigma γ` -/
def decodeSigma (n : ℕ) : Option (Sigma γ) :=
  let (n₁, n₂) := unpair n
  (decode α n₁).bind fun a => (decode (γ a) n₂).map <| Sigma.mk a
#align encodable.decode_sigma Encodable.decodeSigma
-/

#print Encodable.Sigma.encodable /-
instance Encodable.Sigma.encodable : Encodable (Sigma γ) :=
  ⟨encodeSigma, decodeSigma, fun ⟨a, b⟩ => by
    simp [encode_sigma, decode_sigma, unpair_mkpair, encodek]⟩
#align sigma.encodable Encodable.Sigma.encodable
-/

/- warning: encodable.decode_sigma_val -> Encodable.decode_sigma_val is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {γ : α -> Type.{u2}} [_inst_1 : Encodable.{u1} α] [_inst_2 : forall (a : α), Encodable.{u2} (γ a)] (n : Nat), Eq.{succ (max u1 u2)} (Option.{max u1 u2} (Sigma.{u1, u2} α γ)) (Encodable.decode.{max u1 u2} (Sigma.{u1, u2} α γ) (Encodable.Sigma.encodable.{u1, u2} α γ _inst_1 (fun (a : α) => _inst_2 a)) n) (Option.bind.{u1, max u1 u2} α (Sigma.{u1, u2} α γ) (Encodable.decode.{u1} α _inst_1 (Prod.fst.{0, 0} Nat Nat (Nat.unpair n))) (fun (a : α) => Option.map.{u2, max u1 u2} (γ a) (Sigma.{u1, u2} α γ) (Sigma.mk.{u1, u2} α γ a) (Encodable.decode.{u2} (γ a) (_inst_2 a) (Prod.snd.{0, 0} Nat Nat (Nat.unpair n)))))
but is expected to have type
  forall {α : Type.{u2}} {γ : α -> Type.{u1}} [_inst_1 : Encodable.{u2} α] [_inst_2 : forall (a : α), Encodable.{u1} (γ a)] (n : Nat), Eq.{max (succ u2) (succ u1)} (Option.{max u2 u1} (Sigma.{u2, u1} α γ)) (Encodable.decode.{max u2 u1} (Sigma.{u2, u1} α γ) (Encodable.Sigma.encodable.{u2, u1} α γ _inst_1 (fun (a : α) => _inst_2 a)) n) (Option.bind.{u2, max u2 u1} α (Sigma.{u2, u1} α γ) (Encodable.decode.{u2} α _inst_1 (Prod.fst.{0, 0} Nat Nat (Nat.unpair n))) (fun (a : α) => Option.map.{u1, max u2 u1} (γ a) (Sigma.{u2, u1} α γ) (Sigma.mk.{u2, u1} α γ a) (Encodable.decode.{u1} (γ a) (_inst_2 a) (Prod.snd.{0, 0} Nat Nat (Nat.unpair n)))))
Case conversion may be inaccurate. Consider using '#align encodable.decode_sigma_val Encodable.decode_sigma_valₓ'. -/
@[simp]
theorem decode_sigma_val (n : ℕ) :
    decode (Sigma γ) n =
      (decode α n.unpair.1).bind fun a => (decode (γ a) n.unpair.2).map <| Sigma.mk a :=
  show decodeSigma._match1 _ = _ by cases n.unpair <;> rfl
#align encodable.decode_sigma_val Encodable.decode_sigma_val

#print Encodable.encode_sigma_val /-
@[simp]
theorem encode_sigma_val (a b) : @encode (Sigma γ) _ ⟨a, b⟩ = mkpair (encode a) (encode b) :=
  rfl
#align encodable.encode_sigma_val Encodable.encode_sigma_val
-/

end Sigma

section Prod

variable [Encodable α] [Encodable β]

/-- If `α` and `β` are encodable, then so is their product. -/
instance Prod.encodable : Encodable (α × β) :=
  ofEquiv _ (Equiv.sigmaEquivProd α β).symm
#align prod.encodable Prod.encodable

/- warning: encodable.decode_prod_val -> Encodable.decode_prod_val is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : Encodable.{u1} α] [_inst_2 : Encodable.{u2} β] (n : Nat), Eq.{succ (max u1 u2)} (Option.{max u1 u2} (Prod.{u1, u2} α β)) (Encodable.decode.{max u1 u2} (Prod.{u1, u2} α β) (Prod.encodable.{u1, u2} α β _inst_1 _inst_2) n) (Option.bind.{u1, max u1 u2} α (Prod.{u1, u2} α β) (Encodable.decode.{u1} α _inst_1 (Prod.fst.{0, 0} Nat Nat (Nat.unpair n))) (fun (a : α) => Option.map.{u2, max u1 u2} β (Prod.{u1, u2} α β) (Prod.mk.{u1, u2} α β a) (Encodable.decode.{u2} β _inst_2 (Prod.snd.{0, 0} Nat Nat (Nat.unpair n)))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : Encodable.{u1} β] [_inst_2 : Encodable.{u2} α] (n : Nat), Eq.{max (succ u2) (succ u1)} (Option.{max u1 u2} (Prod.{u2, u1} α β)) (Encodable.decode.{max u1 u2} (Prod.{u2, u1} α β) (Encodable.Prod.encodable.{u2, u1} α β _inst_2 _inst_1) n) (Option.bind.{u2, max u1 u2} α (Prod.{u2, u1} α β) (Encodable.decode.{u2} α _inst_2 (Prod.fst.{0, 0} Nat Nat (Nat.unpair n))) (fun (a : α) => Option.map.{u1, max u1 u2} β (Prod.{u2, u1} α β) (Prod.mk.{u2, u1} α β a) (Encodable.decode.{u1} β _inst_1 (Prod.snd.{0, 0} Nat Nat (Nat.unpair n)))))
Case conversion may be inaccurate. Consider using '#align encodable.decode_prod_val Encodable.decode_prod_valₓ'. -/
@[simp]
theorem decode_prod_val (n : ℕ) :
    decode (α × β) n = (decode α n.unpair.1).bind fun a => (decode β n.unpair.2).map <| Prod.mk a :=
  show (decode (Sigma fun _ => β) n).map (Equiv.sigmaEquivProd α β) = _ by
    simp <;> cases decode α n.unpair.1 <;> simp <;> cases decode β n.unpair.2 <;> rfl
#align encodable.decode_prod_val Encodable.decode_prod_val

#print Encodable.encode_prod_val /-
@[simp]
theorem encode_prod_val (a b) : @encode (α × β) _ (a, b) = mkpair (encode a) (encode b) :=
  rfl
#align encodable.encode_prod_val Encodable.encode_prod_val
-/

end Prod

section Subtype

open Subtype Decidable

variable {P : α → Prop} [encA : Encodable α] [decP : DecidablePred P]

include encA

#print Encodable.encodeSubtype /-
/-- Explicit encoding function for a decidable subtype of an encodable type -/
def encodeSubtype : { a : α // P a } → ℕ
  | ⟨v, h⟩ => encode v
#align encodable.encode_subtype Encodable.encodeSubtype
-/

include decP

#print Encodable.decodeSubtype /-
/-- Explicit decoding function for a decidable subtype of an encodable type -/
def decodeSubtype (v : ℕ) : Option { a : α // P a } :=
  (decode α v).bind fun a => if h : P a then some ⟨a, h⟩ else none
#align encodable.decode_subtype Encodable.decodeSubtype
-/

#print Encodable.Subtype.encodable /-
/-- A decidable subtype of an encodable type is encodable. -/
instance Encodable.Subtype.encodable : Encodable { a : α // P a } :=
  ⟨encodeSubtype, decodeSubtype, fun ⟨v, h⟩ => by simp [encode_subtype, decode_subtype, encodek, h]⟩
#align subtype.encodable Encodable.Subtype.encodable
-/

#print Encodable.Subtype.encode_eq /-
theorem Subtype.encode_eq (a : Subtype P) : encode a = encode a.val := by cases a <;> rfl
#align encodable.subtype.encode_eq Encodable.Subtype.encode_eq
-/

end Subtype

#print Encodable.Fin.encodable /-
instance Encodable.Fin.encodable (n) : Encodable (Fin n) :=
  ofEquiv _ Fin.equivSubtype
#align fin.encodable Encodable.Fin.encodable
-/

#print Encodable.Int.encodable /-
instance Encodable.Int.encodable : Encodable ℤ :=
  ofEquiv _ Equiv.intEquivNat
#align int.encodable Encodable.Int.encodable
-/

#print Encodable.PNat.encodable /-
instance Encodable.PNat.encodable : Encodable ℕ+ :=
  ofEquiv _ Equiv.pnatEquivNat
#align pnat.encodable Encodable.PNat.encodable
-/

#print Encodable.ULift.encodable /-
/-- The lift of an encodable type is encodable. -/
instance Encodable.ULift.encodable [Encodable α] : Encodable (ULift α) :=
  ofEquiv _ Equiv.ulift
#align ulift.encodable Encodable.ULift.encodable
-/

#print Encodable.PLift.encodable /-
/-- The lift of an encodable type is encodable. -/
instance Encodable.PLift.encodable [Encodable α] : Encodable (PLift α) :=
  ofEquiv _ Equiv.plift
#align plift.encodable Encodable.PLift.encodable
-/

#print Encodable.ofInj /-
/-- If `β` is encodable and there is an injection `f : α → β`, then `α` is encodable as well. -/
noncomputable def ofInj [Encodable β] (f : α → β) (hf : Injective f) : Encodable α :=
  ofLeftInjection f (partialInv f) fun x => (partialInv_of_injective hf _ _).2 rfl
#align encodable.of_inj Encodable.ofInj
-/

#print Encodable.ofCountable /-
/-- If `α` is countable, then it has a (non-canonical) `encodable` structure. -/
noncomputable def ofCountable (α : Type _) [Countable α] : Encodable α :=
  Nonempty.some <|
    let ⟨f, hf⟩ := exists_injective_nat α
    ⟨ofInj f hf⟩
#align encodable.of_countable Encodable.ofCountable
-/

#print Encodable.nonempty_encodable /-
@[simp]
theorem nonempty_encodable : Nonempty (Encodable α) ↔ Countable α :=
  ⟨fun ⟨h⟩ => @Encodable.countable α h, fun h => ⟨@ofCountable _ h⟩⟩
#align encodable.nonempty_encodable Encodable.nonempty_encodable
-/

end Encodable

#print nonempty_encodable /-
/-- See also `nonempty_fintype`, `nonempty_denumerable`. -/
theorem nonempty_encodable (α : Type _) [Countable α] : Nonempty (Encodable α) :=
  ⟨Encodable.ofCountable _⟩
#align nonempty_encodable nonempty_encodable
-/

instance : Countable ℕ+ :=
  Subtype.countable

-- short-circuit instance search
section Ulower

attribute [local instance] Encodable.decidableRangeEncode

#print Ulower /-
/-- `ulower α : Type` is an equivalent type in the lowest universe, given `encodable α`. -/
def Ulower (α : Type _) [Encodable α] : Type :=
  Set.range (Encodable.encode : α → ℕ)deriving DecidableEq, Encodable
#align ulower Ulower
-/

end Ulower

namespace Ulower

variable (α : Type _) [Encodable α]

#print Ulower.equiv /-
/-- The equivalence between the encodable type `α` and `ulower α : Type`. -/
def equiv : α ≃ Ulower α :=
  Encodable.equivRangeEncode α
#align ulower.equiv Ulower.equiv
-/

variable {α}

#print Ulower.down /-
/-- Lowers an `a : α` into `ulower α`. -/
def down (a : α) : Ulower α :=
  equiv α a
#align ulower.down Ulower.down
-/

instance [Inhabited α] : Inhabited (Ulower α) :=
  ⟨down default⟩

#print Ulower.up /-
/-- Lifts an `a : ulower α` into `α`. -/
def up (a : Ulower α) : α :=
  (equiv α).symm a
#align ulower.up Ulower.up
-/

#print Ulower.down_up /-
@[simp]
theorem down_up {a : Ulower α} : down a.up = a :=
  Equiv.right_inv _ _
#align ulower.down_up Ulower.down_up
-/

#print Ulower.up_down /-
@[simp]
theorem up_down {a : α} : (down a).up = a :=
  Equiv.left_inv _ _
#align ulower.up_down Ulower.up_down
-/

#print Ulower.up_eq_up /-
@[simp]
theorem up_eq_up {a b : Ulower α} : a.up = b.up ↔ a = b :=
  Equiv.apply_eq_iff_eq _
#align ulower.up_eq_up Ulower.up_eq_up
-/

#print Ulower.down_eq_down /-
@[simp]
theorem down_eq_down {a b : α} : down a = down b ↔ a = b :=
  Equiv.apply_eq_iff_eq _
#align ulower.down_eq_down Ulower.down_eq_down
-/

#print Ulower.ext /-
@[ext]
protected theorem ext {a b : Ulower α} : a.up = b.up → a = b :=
  up_eq_up.1
#align ulower.ext Ulower.ext
-/

end Ulower

/-
Choice function for encodable types and decidable predicates.
We provide the following API

choose      {α : Type*} {p : α → Prop} [c : encodable α] [d : decidable_pred p] : (∃ x, p x) → α :=
choose_spec {α : Type*} {p : α → Prop} [c : encodable α] [d : decidable_pred p] (ex : ∃ x, p x) :
  p (choose ex) :=
-/
namespace Encodable

section FindA

variable {α : Type _} (p : α → Prop) [Encodable α] [DecidablePred p]

private def good : Option α → Prop
  | some a => p a
  | none => False
#align encodable.good encodable.good

private def decidable_good : DecidablePred (Good p)
  | n => by cases n <;> unfold good <;> infer_instance
#align encodable.decidable_good encodable.decidable_good

attribute [local instance] decidable_good

open Encodable

variable {p}

#print Encodable.chooseX /-
/-- Constructive choice function for a decidable subtype of an encodable type. -/
def chooseX (h : ∃ x, p x) : { a : α // p a } :=
  have : ∃ n, Good p (decode α n) :=
    let ⟨w, pw⟩ := h
    ⟨encode w, by simp [good, encodek, pw]⟩
  match (motive := ∀ o, Good p o → { a // p a }) _, Nat.find_spec this with
  | some a, h => ⟨a, h⟩
#align encodable.choose_x Encodable.chooseX
-/

#print Encodable.choose /-
/-- Constructive choice function for a decidable predicate over an encodable type. -/
def choose (h : ∃ x, p x) : α :=
  (chooseX h).1
#align encodable.choose Encodable.choose
-/

#print Encodable.choose_spec /-
theorem choose_spec (h : ∃ x, p x) : p (choose h) :=
  (chooseX h).2
#align encodable.choose_spec Encodable.choose_spec
-/

end FindA

/- warning: encodable.axiom_of_choice -> Encodable.axiom_of_choice is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : α -> Type.{u2}} {R : forall (x : α), (β x) -> Prop} [_inst_1 : forall (a : α), Encodable.{u2} (β a)] [_inst_2 : forall (x : α) (y : β x), Decidable (R x y)], (forall (x : α), Exists.{succ u2} (β x) (fun (y : β x) => R x y)) -> (Exists.{max (succ u1) (succ u2)} (forall (a : α), β a) (fun (f : forall (a : α), β a) => forall (x : α), R x (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : α -> Type.{u1}} {R : forall (x : α), (β x) -> Prop} [_inst_1 : forall (a : α), Encodable.{u1} (β a)] [_inst_2 : forall (x : α) (y : β x), Decidable (R x y)], (forall (x : α), Exists.{succ u1} (β x) (fun (y : β x) => R x y)) -> (Exists.{max (succ u2) (succ u1)} (forall (a : α), β a) (fun (f : forall (a : α), β a) => forall (x : α), R x (f x)))
Case conversion may be inaccurate. Consider using '#align encodable.axiom_of_choice Encodable.axiom_of_choiceₓ'. -/
/-- A constructive version of `classical.axiom_of_choice` for `encodable` types. -/
theorem axiom_of_choice {α : Type _} {β : α → Type _} {R : ∀ x, β x → Prop} [∀ a, Encodable (β a)]
    [∀ x y, Decidable (R x y)] (H : ∀ x, ∃ y, R x y) : ∃ f : ∀ a, β a, ∀ x, R x (f x) :=
  ⟨fun x => choose (H x), fun x => choose_spec (H x)⟩
#align encodable.axiom_of_choice Encodable.axiom_of_choice

/- warning: encodable.skolem -> Encodable.skolem is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : α -> Type.{u2}} {P : forall (x : α), (β x) -> Prop} [c : forall (a : α), Encodable.{u2} (β a)] [d : forall (x : α) (y : β x), Decidable (P x y)], Iff (forall (x : α), Exists.{succ u2} (β x) (fun (y : β x) => P x y)) (Exists.{max (succ u1) (succ u2)} (forall (a : α), β a) (fun (f : forall (a : α), β a) => forall (x : α), P x (f x)))
but is expected to have type
  forall {α : Type.{u2}} {β : α -> Type.{u1}} {P : forall (x : α), (β x) -> Prop} [c : forall (a : α), Encodable.{u1} (β a)] [d : forall (x : α) (y : β x), Decidable (P x y)], Iff (forall (x : α), Exists.{succ u1} (β x) (fun (y : β x) => P x y)) (Exists.{max (succ u2) (succ u1)} (forall (a : α), β a) (fun (f : forall (a : α), β a) => forall (x : α), P x (f x)))
Case conversion may be inaccurate. Consider using '#align encodable.skolem Encodable.skolemₓ'. -/
/-- A constructive version of `classical.skolem` for `encodable` types. -/
theorem skolem {α : Type _} {β : α → Type _} {P : ∀ x, β x → Prop} [c : ∀ a, Encodable (β a)]
    [d : ∀ x y, Decidable (P x y)] : (∀ x, ∃ y, P x y) ↔ ∃ f : ∀ a, β a, ∀ x, P x (f x) :=
  ⟨axiom_of_choice, fun ⟨f, H⟩ x => ⟨_, H x⟩⟩
#align encodable.skolem Encodable.skolem

#print Encodable.encode' /-
/-
There is a total ordering on the elements of an encodable type, induced by the map to ℕ.
-/
/-- The `encode` function, viewed as an embedding. -/
def encode' (α) [Encodable α] : α ↪ ℕ :=
  ⟨Encodable.encode, Encodable.encode_injective⟩
#align encodable.encode' Encodable.encode'
-/

instance {α} [Encodable α] : IsTrans _ (encode' α ⁻¹'o (· ≤ ·)) :=
  (RelEmbedding.preimage _ _).IsTrans

instance {α} [Encodable α] : IsAntisymm _ (Encodable.encode' α ⁻¹'o (· ≤ ·)) :=
  (RelEmbedding.preimage _ _).IsAntisymm

instance {α} [Encodable α] : IsTotal _ (Encodable.encode' α ⁻¹'o (· ≤ ·)) :=
  (RelEmbedding.preimage _ _).IsTotal

end Encodable

namespace Directed

open Encodable

variable {α : Type _} {β : Type _} [Encodable α] [Inhabited α]

#print Directed.sequence /-
/-- Given a `directed r` function `f : α → β` defined on an encodable inhabited type,
construct a noncomputable sequence such that `r (f (x n)) (f (x (n + 1)))`
and `r (f a) (f (x (encode a + 1))`. -/
protected noncomputable def sequence {r : β → β → Prop} (f : α → β) (hf : Directed r f) : ℕ → α
  | 0 => default
  | n + 1 =>
    let p := sequence n
    match decode α n with
    | none => Classical.choose (hf p p)
    | some a => Classical.choose (hf p a)
#align directed.sequence Directed.sequence
-/

#print Directed.sequence_mono_nat /-
theorem sequence_mono_nat {r : β → β → Prop} {f : α → β} (hf : Directed r f) (n : ℕ) :
    r (f (hf.sequence f n)) (f (hf.sequence f (n + 1))) :=
  by
  dsimp [Directed.sequence]
  generalize eq : hf.sequence f n = p
  cases' h : decode α n with a
  · exact (Classical.choose_spec (hf p p)).1
  · exact (Classical.choose_spec (hf p a)).1
#align directed.sequence_mono_nat Directed.sequence_mono_nat
-/

#print Directed.rel_sequence /-
theorem rel_sequence {r : β → β → Prop} {f : α → β} (hf : Directed r f) (a : α) :
    r (f a) (f (hf.sequence f (encode a + 1))) :=
  by
  simp only [Directed.sequence, encodek]
  exact (Classical.choose_spec (hf _ a)).2
#align directed.rel_sequence Directed.rel_sequence
-/

variable [Preorder β] {f : α → β} (hf : Directed (· ≤ ·) f)

#print Directed.sequence_mono /-
theorem sequence_mono : Monotone (f ∘ hf.sequence f) :=
  monotone_nat_of_le_succ <| hf.sequence_mono_nat
#align directed.sequence_mono Directed.sequence_mono
-/

#print Directed.le_sequence /-
theorem le_sequence (a : α) : f a ≤ f (hf.sequence f (encode a + 1)) :=
  hf.rel_sequence a
#align directed.le_sequence Directed.le_sequence
-/

end Directed

section Quotient

open Encodable Quotient

variable {α : Type _} {s : Setoid α} [@DecidableRel α (· ≈ ·)] [Encodable α]

#print Quotient.rep /-
/-- Representative of an equivalence class. This is a computable version of `quot.out` for a setoid
on an encodable type. -/
def Quotient.rep (q : Quotient s) : α :=
  choose (exists_rep q)
#align quotient.rep Quotient.rep
-/

#print Quotient.rep_spec /-
theorem Quotient.rep_spec (q : Quotient s) : ⟦q.rep⟧ = q :=
  choose_spec (exists_rep q)
#align quotient.rep_spec Quotient.rep_spec
-/

#print encodableQuotient /-
/-- The quotient of an encodable space by a decidable equivalence relation is encodable. -/
def encodableQuotient : Encodable (Quotient s) :=
  ⟨fun q => encode q.rep, fun n => Quotient.mk'' <$> decode α n, by
    rintro ⟨l⟩ <;> rw [encodek] <;> exact congr_arg some ⟦l⟧.rep_spec⟩
#align encodable_quotient encodableQuotient
-/

end Quotient

