/-
Copyright (c) 2020 Yakov Pechersky. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yakov Pechersky

! This file was ported from Lean 3 source module data.buffer.parser.basic
! leanprover-community/mathlib commit bb9d1c5085e0b7ea619806a68c5021927cecb2a6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.String.Basic
import Mathbin.Data.Buffer.Basic
import Mathbin.Data.Nat.Digits
import Leanbin.Data.Buffer.Parser

/-!
# Parsers

`parser α` is the type that describes a computation that can ingest a `char_buffer`
and output, if successful, a term of type `α`.
This file expands on the definitions in the core library, proving that all the core library
parsers are `mono`. There are also lemmas on the composability of parsers.

## Main definitions

* `parse_result.pos` : The position of a `char_buffer` at which a `parser α` has finished.
* `parser.mono` : The property that a parser only moves forward within a buffer,
  in both cases of success or failure.

## Implementation details

Lemmas about how parsers are mono are in the `mono` namespace. That allows using projection
notation for shorter term proofs that are parallel to the definitions of the parsers in structure.

-/


open Parser ParseResult

/-- For some `parse_result α`, give the position at which the result was provided, in either the
`done` or the `fail` case.
-/
@[simp]
def ParseResult.pos {α} : ParseResult α → ℕ
  | done n _ => n
  | fail n _ => n
#align parse_result.pos ParseResult.pos

namespace Parser

section DefnLemmas

variable {α β : Type} (msgs : Thunk (List String)) (msg : Thunk String)

variable (p q : Parser α) (cb : CharBuffer) (n n' : ℕ) {err : Std.DList String}

variable {a : α} {b : β}

/-- A `p : parser α` is defined to be `mono` if the result `p cb n` it gives,
for some `cb : char_buffer` and `n : ℕ`, (whether `done` or `fail`),
is always at a `parse_result.pos` that is at least `n`.
The `mono` property is used mainly for proper `orelse` behavior.
-/
class Mono : Prop where
  le' : ∀ (cb : CharBuffer) (n : ℕ), n ≤ (p cb n).Pos
#align parser.mono Parser.Mono

theorem Mono.le [p.mono] : n ≤ (p cb n).Pos :=
  Mono.le' cb n
#align parser.mono.le Parser.Mono.le

/-- A `parser α` is defined to be `static` if it does not move on success.
-/
class Static : Prop where
  of_done : ∀ {cb : CharBuffer} {n n' : ℕ} {a : α}, p cb n = done n' a → n = n'
#align parser.static Parser.Static

/-- A `parser α` is defined to be `err_static` if it does not move on error.
-/
class ErrStatic : Prop where
  of_fail : ∀ {cb : CharBuffer} {n n' : ℕ} {err : Std.DList String}, p cb n = fail n' err → n = n'
#align parser.err_static Parser.ErrStatic

/-- A `parser α` is defined to be `step` if it always moves exactly one char forward on success.
-/
class Step : Prop where
  of_done : ∀ {cb : CharBuffer} {n n' : ℕ} {a : α}, p cb n = done n' a → n' = n + 1
#align parser.step Parser.Step

/-- A `parser α` is defined to be `prog` if it always moves forward on success.
-/
class Prog : Prop where
  of_done : ∀ {cb : CharBuffer} {n n' : ℕ} {a : α}, p cb n = done n' a → n < n'
#align parser.prog Parser.Prog

/-- A `parser a` is defined to be `bounded` if it produces a
`fail` `parse_result` when it is parsing outside the provided `char_buffer`.
-/
class Bounded : Prop where
  ex' :
    ∀ {cb : CharBuffer} {n : ℕ},
      cb.size ≤ n → ∃ (n' : ℕ) (err : Std.DList String), p cb n = fail n' err
#align parser.bounded Parser.Bounded

theorem Bounded.exists (p : Parser α) [p.Bounded] {cb : CharBuffer} {n : ℕ} (h : cb.size ≤ n) :
    ∃ (n' : ℕ) (err : Std.DList String), p cb n = fail n' err :=
  Bounded.ex' h
#align parser.bounded.exists Parser.Bounded.exists

/-- A `parser a` is defined to be `unfailing` if it always produces a `done` `parse_result`.
-/
class Unfailing : Prop where
  ex' : ∀ (cb : CharBuffer) (n : ℕ), ∃ (n' : ℕ) (a : α), p cb n = done n' a
#align parser.unfailing Parser.Unfailing

/-- A `parser a` is defined to be `conditionally_unfailing` if it produces a
`done` `parse_result` as long as it is parsing within the provided `char_buffer`.
-/
class ConditionallyUnfailing : Prop where
  ex' : ∀ {cb : CharBuffer} {n : ℕ}, n < cb.size → ∃ (n' : ℕ) (a : α), p cb n = done n' a
#align parser.conditionally_unfailing Parser.ConditionallyUnfailing

theorem fail_iff :
    (∀ pos' result, p cb n ≠ done pos' result) ↔
      ∃ (pos' : ℕ) (err : Std.DList String), p cb n = fail pos' err :=
  by cases p cb n <;> simp
#align parser.fail_iff Parser.fail_iff

theorem success_iff :
    (∀ pos' err, p cb n ≠ fail pos' err) ↔ ∃ (pos' : ℕ) (result : α), p cb n = done pos' result :=
  by cases p cb n <;> simp
#align parser.success_iff Parser.success_iff

variable {p q cb n n' msgs msg}

theorem Mono.of_done [p.mono] (h : p cb n = done n' a) : n ≤ n' := by simpa [h] using mono.le p cb n
#align parser.mono.of_done Parser.Mono.of_done

theorem Mono.of_fail [p.mono] (h : p cb n = fail n' err) : n ≤ n' := by
  simpa [h] using mono.le p cb n
#align parser.mono.of_fail Parser.Mono.of_fail

theorem Bounded.of_done [p.Bounded] (h : p cb n = done n' a) : n < cb.size :=
  by
  contrapose! h
  obtain ⟨np, err, hp⟩ := bounded.exists p h
  simp [hp]
#align parser.bounded.of_done Parser.Bounded.of_done

theorem Static.iff :
    Static p ↔ ∀ (cb : CharBuffer) (n n' : ℕ) (a : α), p cb n = done n' a → n = n' :=
  ⟨fun h _ _ _ _ hp =>
    haveI := h
    static.of_done hp,
    fun h => ⟨h⟩⟩
#align parser.static.iff Parser.Static.iff

theorem exists_done (p : Parser α) [p.Unfailing] (cb : CharBuffer) (n : ℕ) :
    ∃ (n' : ℕ) (a : α), p cb n = done n' a :=
  Unfailing.ex' cb n
#align parser.exists_done Parser.exists_done

theorem Unfailing.of_fail [p.Unfailing] (h : p cb n = fail n' err) : False :=
  by
  obtain ⟨np, a, hp⟩ := p.exists_done cb n
  simpa [hp] using h
#align parser.unfailing.of_fail Parser.Unfailing.of_fail

-- see Note [lower instance priority]
instance (priority := 100) conditionallyUnfailing_of_unfailing [p.Unfailing] :
    ConditionallyUnfailing p :=
  ⟨fun _ _ _ => p.exists_done _ _⟩
#align parser.conditionally_unfailing_of_unfailing Parser.conditionallyUnfailing_of_unfailing

theorem exists_done_in_bounds (p : Parser α) [p.ConditionallyUnfailing] {cb : CharBuffer} {n : ℕ}
    (h : n < cb.size) : ∃ (n' : ℕ) (a : α), p cb n = done n' a :=
  ConditionallyUnfailing.ex' h
#align parser.exists_done_in_bounds Parser.exists_done_in_bounds

theorem ConditionallyUnfailing.of_fail [p.ConditionallyUnfailing] (h : p cb n = fail n' err)
    (hn : n < cb.size) : False :=
  by
  obtain ⟨np, a, hp⟩ := p.exists_done_in_bounds hn
  simpa [hp] using h
#align parser.conditionally_unfailing.of_fail Parser.ConditionallyUnfailing.of_fail

theorem decorateErrors_fail (h : p cb n = fail n' err) :
    @decorateErrors α msgs p cb n = fail n (Std.DList.lazy_ofList (msgs ())) := by
  simp [decorate_errors, h]
#align parser.decorate_errors_fail Parser.decorateErrors_fail

theorem decorateErrors_success (h : p cb n = done n' a) :
    @decorateErrors α msgs p cb n = done n' a := by simp [decorate_errors, h]
#align parser.decorate_errors_success Parser.decorateErrors_success

theorem decorateError_fail (h : p cb n = fail n' err) :
    @decorateError α msg p cb n = fail n (Std.DList.lazy_ofList [msg ()]) :=
  decorateErrors_fail h
#align parser.decorate_error_fail Parser.decorateError_fail

theorem decorateError_success (h : p cb n = done n' a) : @decorateError α msg p cb n = done n' a :=
  decorateErrors_success h
#align parser.decorate_error_success Parser.decorateError_success

@[simp]
theorem decorateErrors_eq_done : @decorateErrors α msgs p cb n = done n' a ↔ p cb n = done n' a :=
  by cases h : p cb n <;> simp [decorate_errors, h]
#align parser.decorate_errors_eq_done Parser.decorateErrors_eq_done

@[simp]
theorem decorateError_eq_done : @decorateError α msg p cb n = done n' a ↔ p cb n = done n' a :=
  decorateErrors_eq_done
#align parser.decorate_error_eq_done Parser.decorateError_eq_done

@[simp]
theorem decorateErrors_eq_fail :
    @decorateErrors α msgs p cb n = fail n' err ↔
      n = n' ∧ err = Std.DList.lazy_ofList (msgs ()) ∧ ∃ np err', p cb n = fail np err' :=
  by cases h : p cb n <;> simp [decorate_errors, h, eq_comm]
#align parser.decorate_errors_eq_fail Parser.decorateErrors_eq_fail

@[simp]
theorem decorateError_eq_fail :
    @decorateError α msg p cb n = fail n' err ↔
      n = n' ∧ err = Std.DList.lazy_ofList [msg ()] ∧ ∃ np err', p cb n = fail np err' :=
  decorateErrors_eq_fail
#align parser.decorate_error_eq_fail Parser.decorateError_eq_fail

@[simp]
theorem return_eq_pure : @return Parser _ _ a = pure a :=
  rfl
#align parser.return_eq_pure Parser.return_eq_pure

theorem pure_eq_done : @pure Parser _ _ a = fun _ n => done n a :=
  rfl
#align parser.pure_eq_done Parser.pure_eq_done

@[simp]
theorem pure_ne_fail : (pure a : Parser α) cb n ≠ fail n' err := by simp [pure_eq_done]
#align parser.pure_ne_fail Parser.pure_ne_fail

section Bind

variable (f : α → Parser β)

@[simp]
theorem bind_eq_bind : p.bind f = p >>= f :=
  rfl
#align parser.bind_eq_bind Parser.bind_eq_bind

variable {f}

@[simp]
theorem bind_eq_done :
    (p >>= f) cb n = done n' b ↔ ∃ (np : ℕ) (a : α), p cb n = done np a ∧ f a cb np = done n' b :=
  by cases hp : p cb n <;> simp [hp, ← bind_eq_bind, Parser.bind, and_assoc']
#align parser.bind_eq_done Parser.bind_eq_done

@[simp]
theorem bind_eq_fail :
    (p >>= f) cb n = fail n' err ↔
      p cb n = fail n' err ∨ ∃ (np : ℕ) (a : α), p cb n = done np a ∧ f a cb np = fail n' err :=
  by cases hp : p cb n <;> simp [hp, ← bind_eq_bind, Parser.bind, and_assoc']
#align parser.bind_eq_fail Parser.bind_eq_fail

@[simp]
theorem andThen_eq_bind {α β : Type} {m : Type → Type} [Monad m] (a : m α) (b : m β) :
    a >> b = a >>= fun _ => b :=
  rfl
#align parser.and_then_eq_bind Parser.andThen_eq_bind

theorem andThen_fail : (p >> return ()) cb n = ParseResult.fail n' err ↔ p cb n = fail n' err := by
  simp [pure_eq_done]
#align parser.and_then_fail Parser.andThen_fail

theorem andThen_success :
    (p >> return ()) cb n = ParseResult.done n' () ↔ ∃ a, p cb n = done n' a := by
  simp [pure_eq_done]
#align parser.and_then_success Parser.andThen_success

end Bind

section Map

variable {f : α → β}

@[simp]
theorem map_eq_done : (f <$> p) cb n = done n' b ↔ ∃ a : α, p cb n = done n' a ∧ f a = b := by
  cases hp : p cb n <;> simp [← LawfulMonad.bind_pure_comp, hp, and_assoc', pure_eq_done]
#align parser.map_eq_done Parser.map_eq_done

@[simp]
theorem map_eq_fail : (f <$> p) cb n = fail n' err ↔ p cb n = fail n' err := by
  simp [← bind_pure_comp_eq_map, pure_eq_done]
#align parser.map_eq_fail Parser.map_eq_fail

@[simp]
theorem mapConst_eq_done {b'} : (b <$ p) cb n = done n' b' ↔ ∃ a : α, p cb n = done n' a ∧ b = b' :=
  by simp [map_const_eq]
#align parser.map_const_eq_done Parser.mapConst_eq_done

@[simp]
theorem mapConst_eq_fail : (b <$ p) cb n = fail n' err ↔ p cb n = fail n' err := by
  simp only [map_const_eq, map_eq_fail]
#align parser.map_const_eq_fail Parser.mapConst_eq_fail

theorem mapConstRev_eq_done {b'} :
    (p $> b) cb n = done n' b' ↔ ∃ a : α, p cb n = done n' a ∧ b = b' :=
  mapConst_eq_done
#align parser.map_const_rev_eq_done Parser.mapConstRev_eq_done

theorem map_rev_const_eq_fail : (p $> b) cb n = fail n' err ↔ p cb n = fail n' err :=
  mapConst_eq_fail
#align parser.map_rev_const_eq_fail Parser.map_rev_const_eq_fail

end Map

@[simp]
theorem orelse_eq_orelse : p.orelse q = (p <|> q) :=
  rfl
#align parser.orelse_eq_orelse Parser.orelse_eq_orelse

@[simp]
theorem orelse_eq_done :
    (p <|> q) cb n = done n' a ↔
      p cb n = done n' a ∨ q cb n = done n' a ∧ ∃ err, p cb n = fail n err :=
  by
  cases' hp : p cb n with np resp np errp
  · simp [hp, ← orelse_eq_orelse, Parser.orelse]
  · by_cases hn : np = n
    · cases' hq : q cb n with nq resq nq errq
      · simp [hp, hn, hq, ← orelse_eq_orelse, Parser.orelse]
      ·
        rcases lt_trichotomy nq n with (H | rfl | H) <;>
          first
          | simp [hp, hn, hq, H, not_lt_of_lt H, lt_irrefl, ← orelse_eq_orelse, Parser.orelse]
          | simp [hp, hn, hq, lt_irrefl, ← orelse_eq_orelse, Parser.orelse]
    · simp [hp, hn, ← orelse_eq_orelse, Parser.orelse]
#align parser.orelse_eq_done Parser.orelse_eq_done

@[simp]
theorem orelse_eq_fail_eq :
    (p <|> q) cb n = fail n err ↔
      (p cb n = fail n err ∧ ∃ nq errq, n < nq ∧ q cb n = fail nq errq) ∨
        ∃ errp errq, p cb n = fail n errp ∧ q cb n = fail n errq ∧ errp ++ errq = err :=
  by
  cases' hp : p cb n with np resp np errp
  · simp [hp, ← orelse_eq_orelse, Parser.orelse]
  · by_cases hn : np = n
    · cases' hq : q cb n with nq resq nq errq
      · simp [hp, hn, hq, ← orelse_eq_orelse, Parser.orelse]
      ·
        rcases lt_trichotomy nq n with (H | rfl | H) <;>
          first
          |
            simp [hp, hq, hn, ← orelse_eq_orelse, Parser.orelse, H, ne_of_gt H, ne_of_lt H,
              not_lt_of_lt H]
          | simp [hp, hq, hn, ← orelse_eq_orelse, Parser.orelse, lt_irrefl]
    · simp [hp, hn, ← orelse_eq_orelse, Parser.orelse]
#align parser.orelse_eq_fail_eq Parser.orelse_eq_fail_eq

theorem orelse_eq_fail_not_mono_lt (hn : n' < n) :
    (p <|> q) cb n = fail n' err ↔
      p cb n = fail n' err ∨ q cb n = fail n' err ∧ ∃ errp, p cb n = fail n errp :=
  by
  cases' hp : p cb n with np resp np errp
  · simp [hp, ← orelse_eq_orelse, Parser.orelse]
  · by_cases h : np = n
    · cases' hq : q cb n with nq resq nq errq
      · simp [hp, h, hn, hq, ne_of_gt hn, ← orelse_eq_orelse, Parser.orelse]
      · rcases lt_trichotomy nq n with (H | H | H)
        · simp [hp, hq, h, H, ne_of_gt hn, not_lt_of_lt H, ← orelse_eq_orelse, Parser.orelse]
        · simp [hp, hq, h, H, ne_of_gt hn, lt_irrefl, ← orelse_eq_orelse, Parser.orelse]
        · simp [hp, hq, h, H, ne_of_gt (hn.trans H), ← orelse_eq_orelse, Parser.orelse]
    · simp [hp, h, ← orelse_eq_orelse, Parser.orelse]
#align parser.orelse_eq_fail_not_mono_lt Parser.orelse_eq_fail_not_mono_lt

theorem orelse_eq_fail_of_mono_ne [q.mono] (hn : n ≠ n') :
    (p <|> q) cb n = fail n' err ↔ p cb n = fail n' err :=
  by
  cases' hp : p cb n with np resp np errp
  · simp [hp, ← orelse_eq_orelse, Parser.orelse]
  · by_cases h : np = n
    · cases' hq : q cb n with nq resq nq errq
      · simp [hp, h, hn, hq, hn, ← orelse_eq_orelse, Parser.orelse]
      · have : n ≤ nq := mono.of_fail hq
        rcases eq_or_lt_of_le this with (rfl | H)
        · simp [hp, hq, h, hn, lt_irrefl, ← orelse_eq_orelse, Parser.orelse]
        · simp [hp, hq, h, hn, H, ← orelse_eq_orelse, Parser.orelse]
    · simp [hp, h, ← orelse_eq_orelse, Parser.orelse]
#align parser.orelse_eq_fail_of_mono_ne Parser.orelse_eq_fail_of_mono_ne

@[simp]
theorem failure_eq_failure : @Parser.failure α = failure :=
  rfl
#align parser.failure_eq_failure Parser.failure_eq_failure

@[simp]
theorem failure_def : (failure : Parser α) cb n = fail n Std.DList.empty :=
  rfl
#align parser.failure_def Parser.failure_def

theorem not_failure_eq_done : ¬(failure : Parser α) cb n = done n' a := by simp
#align parser.not_failure_eq_done Parser.not_failure_eq_done

theorem failure_eq_fail :
    (failure : Parser α) cb n = fail n' err ↔ n = n' ∧ err = Std.DList.empty := by simp [eq_comm]
#align parser.failure_eq_fail Parser.failure_eq_fail

theorem seq_eq_done {f : Parser (α → β)} {p : Parser α} :
    (f <*> p) cb n = done n' b ↔
      ∃ (nf : ℕ) (f' : α → β) (a : α), f cb n = done nf f' ∧ p cb nf = done n' a ∧ f' a = b :=
  by simp [seq_eq_bind_map]
#align parser.seq_eq_done Parser.seq_eq_done

theorem seq_eq_fail {f : Parser (α → β)} {p : Parser α} :
    (f <*> p) cb n = fail n' err ↔
      f cb n = fail n' err ∨ ∃ (nf : ℕ) (f' : α → β), f cb n = done nf f' ∧ p cb nf = fail n' err :=
  by simp [seq_eq_bind_map]
#align parser.seq_eq_fail Parser.seq_eq_fail

theorem seqLeft_eq_done {p : Parser α} {q : Parser β} :
    (p <* q) cb n = done n' a ↔ ∃ (np : ℕ) (b : β), p cb n = done np a ∧ q cb np = done n' b :=
  by
  have :
    ∀ p q : ℕ → α → Prop,
      (∃ (np : ℕ) (x : α), p np x ∧ q np x ∧ x = a) ↔ ∃ np : ℕ, p np a ∧ q np a :=
    fun _ _ => ⟨fun ⟨np, x, hp, hq, rfl⟩ => ⟨np, hp, hq⟩, fun ⟨np, hp, hq⟩ => ⟨np, a, hp, hq, rfl⟩⟩
  simp [seq_left_eq, seq_eq_done, map_eq_done, this]
#align parser.seq_left_eq_done Parser.seqLeft_eq_done

theorem seqLeft_eq_fail {p : Parser α} {q : Parser β} :
    (p <* q) cb n = fail n' err ↔
      p cb n = fail n' err ∨ ∃ (np : ℕ) (a : α), p cb n = done np a ∧ q cb np = fail n' err :=
  by simp [seq_left_eq, seq_eq_fail]
#align parser.seq_left_eq_fail Parser.seqLeft_eq_fail

theorem seqRight_eq_done {p : Parser α} {q : Parser β} :
    (p *> q) cb n = done n' b ↔ ∃ (np : ℕ) (a : α), p cb n = done np a ∧ q cb np = done n' b := by
  simp [seq_right_eq, seq_eq_done, map_eq_done, and_comm, and_assoc]
#align parser.seq_right_eq_done Parser.seqRight_eq_done

theorem seqRight_eq_fail {p : Parser α} {q : Parser β} :
    (p *> q) cb n = fail n' err ↔
      p cb n = fail n' err ∨ ∃ (np : ℕ) (a : α), p cb n = done np a ∧ q cb np = fail n' err :=
  by simp [seq_right_eq, seq_eq_fail]
#align parser.seq_right_eq_fail Parser.seqRight_eq_fail

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem mapM_eq_done {f : α → Parser β} {a : α} {l : List α} {b : β} {l' : List β} :
    (a::l).mapM f cb n = done n' (b::l') ↔
      ∃ np : ℕ, f a cb n = done np b ∧ l.mapM f cb np = done n' l' :=
  by simp [mmap, and_comm, and_assoc, and_left_comm, pure_eq_done]
#align parser.mmap_eq_done Parser.mapM_eq_done

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem mapM'_eq_done {f : α → Parser β} {a : α} {l : List α} :
    (a::l).mapM' f cb n = done n' () ↔
      ∃ (np : ℕ) (b : β), f a cb n = done np b ∧ l.mapM' f cb np = done n' () :=
  by simp [mmap']
#align parser.mmap'_eq_done Parser.mapM'_eq_done

theorem guard_eq_done {p : Prop} [Decidable p] {u : Unit} :
    @guard Parser _ p _ cb n = done n' u ↔ p ∧ n = n' := by
  by_cases hp : p <;> simp [guard, hp, pure_eq_done]
#align parser.guard_eq_done Parser.guard_eq_done

theorem guard_eq_fail {p : Prop} [Decidable p] :
    @guard Parser _ p _ cb n = fail n' err ↔ ¬p ∧ n = n' ∧ err = Std.DList.empty := by
  by_cases hp : p <;> simp [guard, hp, eq_comm, pure_eq_done]
#align parser.guard_eq_fail Parser.guard_eq_fail

namespace Mono

variable {sep : Parser Unit}

instance pure : Mono (pure a) :=
  ⟨fun _ _ => by simp [pure_eq_done]⟩
#align parser.mono.pure Parser.Mono.pure

instance bind {f : α → Parser β} [p.mono] [∀ a, (f a).mono] : (p >>= f).mono :=
  by
  constructor
  intro cb n
  cases hx : (p >>= f) cb n
  · obtain ⟨n', a, h, h'⟩ := bind_eq_done.mp hx
    refine' le_trans (of_done h) _
    simpa [h'] using of_done h'
  · obtain h | ⟨n', a, h, h'⟩ := bind_eq_fail.mp hx
    · simpa [h] using of_fail h
    · refine' le_trans (of_done h) _
      simpa [h'] using of_fail h'
#align parser.mono.bind Parser.Mono.bind

instance andThen {q : Parser β} [p.mono] [q.mono] : (p >> q).mono :=
  Mono.bind
#align parser.mono.and_then Parser.Mono.andThen

instance map [p.mono] {f : α → β} : (f <$> p).mono :=
  Mono.bind
#align parser.mono.map Parser.Mono.map

instance seq {f : Parser (α → β)} [f.mono] [p.mono] : (f <*> p).mono :=
  Mono.bind
#align parser.mono.seq Parser.Mono.seq

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM : ∀ {l : List α} {f : α → Parser β} [∀ a ∈ l, (f a).mono], (l.mapM f).mono
  | [], _, _ => Mono.pure
  | a::l, f, h => by
    convert mono.bind
    · exact h _ (List.mem_cons_self _ _)
    · intro
      convert mono.map
      convert mmap
      exact fun _ ha => h _ (List.mem_cons_of_mem _ ha)
#align parser.mono.mmap Parser.Mono.mapM

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM' : ∀ {l : List α} {f : α → Parser β} [∀ a ∈ l, (f a).mono], (l.mapM' f).mono
  | [], _, _ => Mono.pure
  | a::l, f, h => by
    convert mono.and_then
    · exact h _ (List.mem_cons_self _ _)
    · convert mmap'
      exact fun _ ha => h _ (List.mem_cons_of_mem _ ha)
#align parser.mono.mmap' Parser.Mono.mapM'

instance failure : (failure : Parser α).mono :=
  ⟨by simp [le_refl]⟩
#align parser.mono.failure Parser.Mono.failure

instance guard {p : Prop} [Decidable p] : Mono (guard p) :=
  ⟨by by_cases h : p <;> simp [h, pure_eq_done, le_refl]⟩
#align parser.mono.guard Parser.Mono.guard

instance orelse [p.mono] [q.mono] : (p <|> q).mono :=
  by
  constructor
  intro cb n
  cases' hx : (p <|> q) cb n with posx resx posx errx
  · obtain h | ⟨h, -, -⟩ := orelse_eq_done.mp hx <;> simpa [h] using of_done h
  · by_cases h : n = posx
    · simp [hx, h]
    · simp only [orelse_eq_fail_of_mono_ne h] at hx 
      exact of_fail hx
#align parser.mono.orelse Parser.Mono.orelse

instance decorateErrors [p.mono] : (@decorateErrors α msgs p).mono :=
  by
  constructor
  intro cb n
  cases h : p cb n
  · simpa [decorate_errors, h] using of_done h
  · simp [decorate_errors, h]
#align parser.mono.decorate_errors Parser.Mono.decorateErrors

instance decorateError [p.mono] : (@decorateError α msg p).mono :=
  Mono.decorateErrors
#align parser.mono.decorate_error Parser.Mono.decorateError

instance anyChar : Mono anyChar := by
  constructor
  intro cb n
  by_cases h : n < cb.size <;> simp [any_char, h]
#align parser.mono.any_char Parser.Mono.anyChar

instance sat {p : Char → Prop} [DecidablePred p] : Mono (sat p) :=
  by
  constructor
  intro cb n
  simp only [sat]
  split_ifs <;> simp
#align parser.mono.sat Parser.Mono.sat

instance eps : Mono eps :=
  Mono.pure
#align parser.mono.eps Parser.Mono.eps

instance ch {c : Char} : Mono (ch c) :=
  Mono.decorateError
#align parser.mono.ch Parser.Mono.ch

instance charBuf {s : CharBuffer} : Mono (charBuf s) :=
  Mono.decorateError
#align parser.mono.char_buf Parser.Mono.charBuf

instance oneOf {cs : List Char} : (oneOf cs).mono :=
  Mono.decorateErrors
#align parser.mono.one_of Parser.Mono.oneOf

instance oneOf' {cs : List Char} : (oneOf' cs).mono :=
  Mono.andThen
#align parser.mono.one_of' Parser.Mono.oneOf'

instance str {s : String} : (str s).mono :=
  Mono.decorateError
#align parser.mono.str Parser.Mono.str

instance remaining : remaining.mono :=
  ⟨fun _ _ => le_rfl⟩
#align parser.mono.remaining Parser.Mono.remaining

instance eof : eof.mono :=
  Mono.decorateError
#align parser.mono.eof Parser.Mono.eof

instance foldrCore {f : α → β → β} {b : β} [p.mono] : ∀ {reps : ℕ}, (foldrCore f p b reps).mono
  | 0 => Mono.failure
  | reps + 1 => by
    convert mono.orelse
    · convert mono.bind
      · infer_instance
      · exact fun _ => @mono.bind _ _ _ _ foldr_core _
    · exact mono.pure
#align parser.mono.foldr_core Parser.Mono.foldrCore

instance foldr {f : α → β → β} [p.mono] : Mono (foldr f p b) :=
  ⟨fun _ _ => by convert mono.le (foldr_core f p b _) _ _; exact mono.foldr_core⟩
#align parser.mono.foldr Parser.Mono.foldr

instance foldlCore {f : α → β → α} {p : Parser β} [p.mono] :
    ∀ {a : α} {reps : ℕ}, (foldlCore f a p reps).mono
  | _, 0 => Mono.failure
  | _, reps + 1 => by
    convert mono.orelse
    · convert mono.bind
      · infer_instance
      · exact fun _ => foldl_core
    · exact mono.pure
#align parser.mono.foldl_core Parser.Mono.foldlCore

instance foldl {f : α → β → α} {p : Parser β} [p.mono] : Mono (foldl f a p) :=
  ⟨fun _ _ => by convert mono.le (foldl_core f a p _) _ _; exact mono.foldl_core⟩
#align parser.mono.foldl Parser.Mono.foldl

instance many [p.mono] : p.anyM.mono :=
  Mono.foldr
#align parser.mono.many Parser.Mono.many

instance manyChar {p : Parser Char} [p.mono] : p.manyChar.mono :=
  Mono.map
#align parser.mono.many_char Parser.Mono.manyChar

instance many' [p.mono] : p.many'.mono :=
  Mono.andThen
#align parser.mono.many' Parser.Mono.many'

instance many1 [p.mono] : p.many1.mono :=
  Mono.seq
#align parser.mono.many1 Parser.Mono.many1

instance manyChar1 {p : Parser Char} [p.mono] : p.manyChar1.mono :=
  Mono.map
#align parser.mono.many_char1 Parser.Mono.manyChar1

instance sepBy1 [p.mono] [sep.mono] : Mono (sepBy1 sep p) :=
  Mono.seq
#align parser.mono.sep_by1 Parser.Mono.sepBy1

instance sepBy [p.mono] [hs : sep.mono] : Mono (sepBy sep p) :=
  Mono.orelse
#align parser.mono.sep_by Parser.Mono.sepBy

theorem fixCore {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.mono → (F p).mono) :
    ∀ max_depth : ℕ, Mono (fixCore F max_depth)
  | 0 => Mono.failure
  | max_depth + 1 => hF _ (fix_core _)
#align parser.mono.fix_core Parser.Mono.fixCore

instance digit : digit.mono :=
  Mono.decorateError
#align parser.mono.digit Parser.Mono.digit

instance nat : nat.mono :=
  Mono.decorateError
#align parser.mono.nat Parser.Mono.nat

theorem fix {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.mono → (F p).mono) : Mono (fix F) :=
  ⟨fun _ _ => by convert mono.le (Parser.fixCore F _) _ _; exact fix_core hF _⟩
#align parser.mono.fix Parser.Mono.fix

end Mono

@[simp]
theorem orelse_pure_eq_fail : (p <|> pure a) cb n = fail n' err ↔ p cb n = fail n' err ∧ n ≠ n' :=
  by
  by_cases hn : n = n'
  · simp [hn, pure_eq_done]
  · simp [orelse_eq_fail_of_mono_ne, hn]
#align parser.orelse_pure_eq_fail Parser.orelse_pure_eq_fail

end DefnLemmas

section Done

variable {α β : Type} {cb : CharBuffer} {n n' : ℕ} {a a' : α} {b : β} {c : Char} {u : Unit}
  {err : Std.DList String}

theorem anyChar_eq_done :
    anyChar cb n = done n' c ↔ ∃ hn : n < cb.size, n' = n + 1 ∧ cb.read ⟨n, hn⟩ = c :=
  by
  simp_rw [any_char]
  split_ifs with h <;> simp [h, eq_comm]
#align parser.any_char_eq_done Parser.anyChar_eq_done

theorem anyChar_eq_fail :
    anyChar cb n = fail n' err ↔ n = n' ∧ err = Std.DList.empty ∧ cb.size ≤ n :=
  by
  simp_rw [any_char]
  split_ifs with h <;> simp [← not_lt, h, eq_comm]
#align parser.any_char_eq_fail Parser.anyChar_eq_fail

theorem sat_eq_done {p : Char → Prop} [DecidablePred p] :
    sat p cb n = done n' c ↔ ∃ hn : n < cb.size, p c ∧ n' = n + 1 ∧ cb.read ⟨n, hn⟩ = c :=
  by
  by_cases hn : n < cb.size
  · by_cases hp : p (cb.read ⟨n, hn⟩)
    · simp only [sat, hn, hp, dif_pos, if_true, exists_prop_of_true]
      constructor
      · rintro ⟨rfl, rfl⟩; simp [hp]
      · rintro ⟨-, rfl, rfl⟩; simp
    · simp only [sat, hn, hp, dif_pos, false_iff_iff, not_and, exists_prop_of_true, if_false]
      rintro H - rfl
      exact hp H
  · simp [sat, hn]
#align parser.sat_eq_done Parser.sat_eq_done

theorem sat_eq_fail {p : Char → Prop} [DecidablePred p] :
    sat p cb n = fail n' err ↔
      n = n' ∧ err = Std.DList.empty ∧ ∀ h : n < cb.size, ¬p (cb.read ⟨n, h⟩) :=
  by
  dsimp only [sat]
  split_ifs <;> simp [*, eq_comm]
#align parser.sat_eq_fail Parser.sat_eq_fail

theorem eps_eq_done : eps cb n = done n' u ↔ n = n' := by simp [eps, pure_eq_done]
#align parser.eps_eq_done Parser.eps_eq_done

theorem ch_eq_done : ch c cb n = done n' u ↔ ∃ hn : n < cb.size, n' = n + 1 ∧ cb.read ⟨n, hn⟩ = c :=
  by simp [ch, eps_eq_done, sat_eq_done, and_comm, @eq_comm _ n']
#align parser.ch_eq_done Parser.ch_eq_done

theorem charBuf_eq_done {cb' : CharBuffer} :
    charBuf cb' cb n = done n' u ↔ n + cb'.size = n' ∧ cb'.toList <+: cb.toList.drop n :=
  by
  simp only [char_buf, decorate_error_eq_done, Ne.def, ← Buffer.length_toList]
  induction' cb'.to_list with hd tl hl generalizing cb n n'
  · simp [pure_eq_done, mmap'_eq_done, -Buffer.length_toList, List.nil_prefix]
  · simp only [ch_eq_done, and_comm, and_assoc, and_left_comm, hl, mmap', and_then_eq_bind,
      bind_eq_done, List.length, exists_and_left, exists_const]
    constructor
    · rintro ⟨np, h, rfl, rfl, hn, rfl⟩
      simp only [add_comm, add_left_comm, h, true_and_iff, eq_self_iff_true, and_true_iff]
      have : n < cb.to_list.length := by simpa using hn
      rwa [← Buffer.nthLe_toList _ this, ← List.cons_nthLe_drop_succ this, List.prefix_cons_inj]
    · rintro ⟨h, rfl⟩
      by_cases hn : n < cb.size
      · have : n < cb.to_list.length := by simpa using hn
        rw [← List.cons_nthLe_drop_succ this, List.cons_prefix_iff] at h 
        use n + 1, h.right
        simpa [Buffer.nthLe_toList, add_comm, add_left_comm, add_assoc, hn] using h.left.symm
      · have : cb.to_list.length ≤ n := by simpa using hn
        rw [List.drop_eq_nil_of_le this] at h 
        simpa using h
#align parser.char_buf_eq_done Parser.charBuf_eq_done

theorem oneOf_eq_done {cs : List Char} :
    oneOf cs cb n = done n' c ↔ ∃ hn : n < cb.size, c ∈ cs ∧ n' = n + 1 ∧ cb.read ⟨n, hn⟩ = c := by
  simp [one_of, sat_eq_done]
#align parser.one_of_eq_done Parser.oneOf_eq_done

theorem oneOf'_eq_done {cs : List Char} :
    oneOf' cs cb n = done n' u ↔ ∃ hn : n < cb.size, cb.read ⟨n, hn⟩ ∈ cs ∧ n' = n + 1 :=
  by
  simp only [one_of', one_of_eq_done, eps_eq_done, and_comm, and_then_eq_bind, bind_eq_done,
    exists_eq_left, exists_and_left]
  constructor
  · rintro ⟨c, hc, rfl, hn, rfl⟩
    exact ⟨rfl, hn, hc⟩
  · rintro ⟨rfl, hn, hc⟩
    exact ⟨cb.read ⟨n, hn⟩, hc, rfl, hn, rfl⟩
#align parser.one_of'_eq_done Parser.oneOf'_eq_done

theorem str_eq_charBuf (s : String) : str s = charBuf s.toList.toBuffer :=
  by
  ext cb n
  rw [str, char_buf]
  congr
  · simp [Buffer.toString, String.asString_inv_toList]
  · simp
#align parser.str_eq_char_buf Parser.str_eq_charBuf

theorem str_eq_done {s : String} :
    str s cb n = done n' u ↔ n + s.length = n' ∧ s.toList <+: cb.toList.drop n := by
  simp [str_eq_char_buf, char_buf_eq_done]
#align parser.str_eq_done Parser.str_eq_done

theorem remaining_eq_done {r : ℕ} : remaining cb n = done n' r ↔ n = n' ∧ cb.size - n = r := by
  simp [remaining]
#align parser.remaining_eq_done Parser.remaining_eq_done

theorem remaining_ne_fail : remaining cb n ≠ fail n' err := by simp [remaining]
#align parser.remaining_ne_fail Parser.remaining_ne_fail

theorem eof_eq_done {u : Unit} : eof cb n = done n' u ↔ n = n' ∧ cb.size ≤ n := by
  simp [eof, guard_eq_done, remaining_eq_done, tsub_eq_zero_iff_le, and_comm', and_assoc']
#align parser.eof_eq_done Parser.eof_eq_done

@[simp]
theorem foldrCore_zero_eq_done {f : α → β → β} {p : Parser α} {b' : β} :
    foldrCore f p b 0 cb n ≠ done n' b' := by simp [foldr_core]
#align parser.foldr_core_zero_eq_done Parser.foldrCore_zero_eq_done

theorem foldrCore_eq_done {f : α → β → β} {p : Parser α} {reps : ℕ} {b' : β} :
    foldrCore f p b (reps + 1) cb n = done n' b' ↔
      (∃ (np : ℕ) (a : α) (xs : β),
          p cb n = done np a ∧ foldrCore f p b reps cb np = done n' xs ∧ f a xs = b') ∨
        n = n' ∧
          b = b' ∧
            ∃ err,
              p cb n = fail n err ∨
                ∃ (np : ℕ) (a : α), p cb n = done np a ∧ foldrCore f p b reps cb np = fail n err :=
  by simp [foldr_core, and_comm, and_assoc, pure_eq_done]
#align parser.foldr_core_eq_done Parser.foldrCore_eq_done

@[simp]
theorem foldrCore_zero_eq_fail {f : α → β → β} {p : Parser α} {err : Std.DList String} :
    foldrCore f p b 0 cb n = fail n' err ↔ n = n' ∧ err = Std.DList.empty := by
  simp [foldr_core, eq_comm]
#align parser.foldr_core_zero_eq_fail Parser.foldrCore_zero_eq_fail

theorem foldrCore_succ_eq_fail {f : α → β → β} {p : Parser α} {reps : ℕ} {err : Std.DList String} :
    foldrCore f p b (reps + 1) cb n = fail n' err ↔
      n ≠ n' ∧
        (p cb n = fail n' err ∨
          ∃ (np : ℕ) (a : α), p cb n = done np a ∧ foldrCore f p b reps cb np = fail n' err) :=
  by simp [foldr_core, and_comm']
#align parser.foldr_core_succ_eq_fail Parser.foldrCore_succ_eq_fail

theorem foldr_eq_done {f : α → β → β} {p : Parser α} {b' : β} :
    foldr f p b cb n = done n' b' ↔
      (∃ (np : ℕ) (a : α) (x : β),
          p cb n = done np a ∧ foldrCore f p b (cb.size - n) cb np = done n' x ∧ f a x = b') ∨
        n = n' ∧
          b = b' ∧
            ∃ err,
              p cb n = ParseResult.fail n err ∨
                ∃ (np : ℕ) (x : α),
                  p cb n = done np x ∧ foldrCore f p b (cb.size - n) cb np = fail n err :=
  by simp [foldr, foldr_core_eq_done]
#align parser.foldr_eq_done Parser.foldr_eq_done

theorem foldr_eq_fail_iff_mono_at_end {f : α → β → β} {p : Parser α} {err : Std.DList String}
    [p.mono] (hc : cb.size ≤ n) :
    foldr f p b cb n = fail n' err ↔
      n < n' ∧ (p cb n = fail n' err ∨ ∃ a : α, p cb n = done n' a ∧ err = Std.DList.empty) :=
  by
  have : cb.size - n = 0 := tsub_eq_zero_iff_le.mpr hc
  simp only [foldr, foldr_core_succ_eq_fail, this, and_left_comm, foldr_core_zero_eq_fail,
    ne_iff_lt_iff_le, exists_and_right, exists_eq_left, and_congr_left_iff, exists_and_left]
  rintro (h | ⟨⟨a, h⟩, rfl⟩)
  · exact mono.of_fail h
  · exact mono.of_done h
#align parser.foldr_eq_fail_iff_mono_at_end Parser.foldr_eq_fail_iff_mono_at_end

theorem foldr_eq_fail {f : α → β → β} {p : Parser α} {err : Std.DList String} :
    foldr f p b cb n = fail n' err ↔
      n ≠ n' ∧
        (p cb n = fail n' err ∨
          ∃ (np : ℕ) (a : α),
            p cb n = done np a ∧ foldrCore f p b (cb.size - n) cb np = fail n' err) :=
  by simp [foldr, foldr_core_succ_eq_fail]
#align parser.foldr_eq_fail Parser.foldr_eq_fail

@[simp]
theorem foldlCore_zero_eq_done {f : β → α → β} {p : Parser α} {b' : β} :
    foldlCore f b p 0 cb n = done n' b' ↔ False := by simp [foldl_core]
#align parser.foldl_core_zero_eq_done Parser.foldlCore_zero_eq_done

theorem foldlCore_eq_done {f : β → α → β} {p : Parser α} {reps : ℕ} {b' : β} :
    foldlCore f b p (reps + 1) cb n = done n' b' ↔
      (∃ (np : ℕ) (a : α), p cb n = done np a ∧ foldlCore f (f b a) p reps cb np = done n' b') ∨
        n = n' ∧
          b = b' ∧
            ∃ err,
              p cb n = fail n err ∨
                ∃ (np : ℕ) (a : α),
                  p cb n = done np a ∧ foldlCore f (f b a) p reps cb np = fail n err :=
  by simp [foldl_core, and_assoc, pure_eq_done]
#align parser.foldl_core_eq_done Parser.foldlCore_eq_done

@[simp]
theorem foldlCore_zero_eq_fail {f : β → α → β} {p : Parser α} {err : Std.DList String} :
    foldlCore f b p 0 cb n = fail n' err ↔ n = n' ∧ err = Std.DList.empty := by
  simp [foldl_core, eq_comm]
#align parser.foldl_core_zero_eq_fail Parser.foldlCore_zero_eq_fail

theorem foldlCore_succ_eq_fail {f : β → α → β} {p : Parser α} {reps : ℕ} {err : Std.DList String} :
    foldlCore f b p (reps + 1) cb n = fail n' err ↔
      n ≠ n' ∧
        (p cb n = fail n' err ∨
          ∃ (np : ℕ) (a : α),
            p cb n = done np a ∧ foldlCore f (f b a) p reps cb np = fail n' err) :=
  by simp [foldl_core, and_comm']
#align parser.foldl_core_succ_eq_fail Parser.foldlCore_succ_eq_fail

theorem foldl_eq_done {f : β → α → β} {p : Parser α} {b' : β} :
    foldl f b p cb n = done n' b' ↔
      (∃ (np : ℕ) (a : α),
          p cb n = done np a ∧ foldlCore f (f b a) p (cb.size - n) cb np = done n' b') ∨
        n = n' ∧
          b = b' ∧
            ∃ err,
              p cb n = fail n err ∨
                ∃ (np : ℕ) (a : α),
                  p cb n = done np a ∧ foldlCore f (f b a) p (cb.size - n) cb np = fail n err :=
  by simp [foldl, foldl_core_eq_done]
#align parser.foldl_eq_done Parser.foldl_eq_done

theorem foldl_eq_fail {f : β → α → β} {p : Parser α} {err : Std.DList String} :
    foldl f b p cb n = fail n' err ↔
      n ≠ n' ∧
        (p cb n = fail n' err ∨
          ∃ (np : ℕ) (a : α),
            p cb n = done np a ∧ foldlCore f (f b a) p (cb.size - n) cb np = fail n' err) :=
  by simp [foldl, foldl_core_succ_eq_fail]
#align parser.foldl_eq_fail Parser.foldl_eq_fail

theorem foldl_eq_fail_iff_mono_at_end {f : β → α → β} {p : Parser α} {err : Std.DList String}
    [p.mono] (hc : cb.size ≤ n) :
    foldl f b p cb n = fail n' err ↔
      n < n' ∧ (p cb n = fail n' err ∨ ∃ a : α, p cb n = done n' a ∧ err = Std.DList.empty) :=
  by
  have : cb.size - n = 0 := tsub_eq_zero_iff_le.mpr hc
  simp only [foldl, foldl_core_succ_eq_fail, this, and_left_comm, ne_iff_lt_iff_le, exists_eq_left,
    exists_and_right, and_congr_left_iff, exists_and_left, foldl_core_zero_eq_fail]
  rintro (h | ⟨⟨a, h⟩, rfl⟩)
  · exact mono.of_fail h
  · exact mono.of_done h
#align parser.foldl_eq_fail_iff_mono_at_end Parser.foldl_eq_fail_iff_mono_at_end

theorem many_eq_done_nil {p : Parser α} :
    many p cb n = done n' (@List.nil α) ↔
      n = n' ∧
        ∃ err,
          p cb n = fail n err ∨
            ∃ (np : ℕ) (a : α),
              p cb n = done np a ∧ foldrCore List.cons p [] (cb.size - n) cb np = fail n err :=
  by simp [many, foldr_eq_done]
#align parser.many_eq_done_nil Parser.many_eq_done_nil

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem many_eq_done {p : Parser α} {x : α} {xs : List α} :
    many p cb n = done n' (x::xs) ↔
      ∃ np : ℕ, p cb n = done np x ∧ foldrCore List.cons p [] (cb.size - n) cb np = done n' xs :=
  by simp [many, foldr_eq_done, and_comm, and_assoc, and_left_comm]
#align parser.many_eq_done Parser.many_eq_done

theorem many_eq_fail {p : Parser α} {err : Std.DList String} :
    many p cb n = fail n' err ↔
      n ≠ n' ∧
        (p cb n = fail n' err ∨
          ∃ (np : ℕ) (a : α),
            p cb n = done np a ∧ foldrCore List.cons p [] (cb.size - n) cb np = fail n' err) :=
  by simp [many, foldr_eq_fail]
#align parser.many_eq_fail Parser.many_eq_fail

theorem manyChar_eq_done_empty {p : Parser Char} :
    manyChar p cb n = done n' String.empty ↔
      n = n' ∧
        ∃ err,
          p cb n = fail n err ∨
            ∃ (np : ℕ) (c : Char),
              p cb n = done np c ∧ foldrCore List.cons p [] (cb.size - n) cb np = fail n err :=
  by simp [many_char, many_eq_done_nil, map_eq_done, List.asString_eq]
#align parser.many_char_eq_done_empty Parser.manyChar_eq_done_empty

theorem manyChar_eq_done_not_empty {p : Parser Char} {s : String} (h : s ≠ "") :
    manyChar p cb n = done n' s ↔
      ∃ np : ℕ,
        p cb n = done np s.headI ∧
          foldrCore List.cons p List.nil (Buffer.size cb - n) cb np = done n' (s.drop 1).toList :=
  by simp [many_char, List.asString_eq, String.toList_nonempty h, many_eq_done]
#align parser.many_char_eq_done_not_empty Parser.manyChar_eq_done_not_empty

theorem manyChar_eq_many_of_toList {p : Parser Char} {s : String} :
    manyChar p cb n = done n' s ↔ many p cb n = done n' s.toList := by
  simp [many_char, List.asString_eq]
#align parser.many_char_eq_many_of_to_list Parser.manyChar_eq_many_of_toList

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem many'_eq_done {p : Parser α} :
    many' p cb n = done n' u ↔
      many p cb n = done n' [] ∨
        ∃ (np : ℕ) (a : α) (l : List α),
          many p cb n = done n' (a::l) ∧
            p cb n = done np a ∧ foldrCore List.cons p [] (Buffer.size cb - n) cb np = done n' l :=
  by
  simp only [many', eps_eq_done, many, foldr, and_then_eq_bind, exists_and_right, bind_eq_done,
    exists_eq_right]
  constructor
  · rintro ⟨_ | ⟨hd, tl⟩, hl⟩
    · exact Or.inl hl
    · have hl2 := hl
      simp only [foldr_core_eq_done, or_false_iff, exists_and_left, and_false_iff, false_and_iff,
        exists_eq_right_right] at hl 
      obtain ⟨np, hp, h⟩ := hl
      refine' Or.inr ⟨np, _, _, hl2, hp, h⟩
  · rintro (h | ⟨np, a, l, hp, h⟩)
    · exact ⟨[], h⟩
    · refine' ⟨a::l, hp⟩
#align parser.many'_eq_done Parser.many'_eq_done

@[simp]
theorem many1_ne_done_nil {p : Parser α} : many1 p cb n ≠ done n' [] := by simp [many1, seq_eq_done]
#align parser.many1_ne_done_nil Parser.many1_ne_done_nil

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem many1_eq_done {p : Parser α} {l : List α} :
    many1 p cb n = done n' (a::l) ↔ ∃ np : ℕ, p cb n = done np a ∧ many p cb np = done n' l := by
  simp [many1, seq_eq_done, map_eq_done]
#align parser.many1_eq_done Parser.many1_eq_done

theorem many1_eq_fail {p : Parser α} {err : Std.DList String} :
    many1 p cb n = fail n' err ↔
      p cb n = fail n' err ∨ ∃ (np : ℕ) (a : α), p cb n = done np a ∧ many p cb np = fail n' err :=
  by simp [many1, seq_eq_fail]
#align parser.many1_eq_fail Parser.many1_eq_fail

@[simp]
theorem manyChar1_ne_empty {p : Parser Char} : manyChar1 p cb n ≠ done n' "" := by
  simp [many_char1, ← String.nil_asString_eq_empty]
#align parser.many_char1_ne_empty Parser.manyChar1_ne_empty

theorem manyChar1_eq_done {p : Parser Char} {s : String} (h : s ≠ "") :
    manyChar1 p cb n = done n' s ↔
      ∃ np : ℕ, p cb n = done np s.headI ∧ manyChar p cb np = done n' (s.drop 1) :=
  by
  simp [many_char1, List.asString_eq, String.toList_nonempty h, many1_eq_done,
    many_char_eq_many_of_to_list]
#align parser.many_char1_eq_done Parser.manyChar1_eq_done

@[simp]
theorem sepBy1_ne_done_nil {sep : Parser Unit} {p : Parser α} : sepBy1 sep p cb n ≠ done n' [] := by
  simp [sep_by1, seq_eq_done]
#align parser.sep_by1_ne_done_nil Parser.sepBy1_ne_done_nil

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem sepBy1_eq_done {sep : Parser Unit} {p : Parser α} {l : List α} :
    sepBy1 sep p cb n = done n' (a::l) ↔
      ∃ np : ℕ, p cb n = done np a ∧ (sep >> p).anyM cb np = done n' l :=
  by simp [sep_by1, seq_eq_done]
#align parser.sep_by1_eq_done Parser.sepBy1_eq_done

theorem sepBy_eq_done_nil {sep : Parser Unit} {p : Parser α} :
    sepBy sep p cb n = done n' [] ↔ n = n' ∧ ∃ err, sepBy1 sep p cb n = fail n err := by
  simp [sep_by, pure_eq_done]
#align parser.sep_by_eq_done_nil Parser.sepBy_eq_done_nil

@[simp]
theorem fixCore_ne_done_zero {F : Parser α → Parser α} : fixCore F 0 cb n ≠ done n' a := by
  simp [fix_core]
#align parser.fix_core_ne_done_zero Parser.fixCore_ne_done_zero

theorem fixCore_eq_done {F : Parser α → Parser α} {max_depth : ℕ} :
    fixCore F (max_depth + 1) cb n = done n' a ↔ F (fixCore F max_depth) cb n = done n' a := by
  simp [fix_core]
#align parser.fix_core_eq_done Parser.fixCore_eq_done

theorem digit_eq_done {k : ℕ} :
    digit cb n = done n' k ↔
      ∃ hn : n < cb.size,
        n' = n + 1 ∧
          k ≤ 9 ∧
            (cb.read ⟨n, hn⟩).toNat - '0'.toNat = k ∧
              '0' ≤ cb.read ⟨n, hn⟩ ∧ cb.read ⟨n, hn⟩ ≤ '9' :=
  by
  have c9 : '9'.toNat - '0'.toNat = 9 := rfl
  have l09 : '0'.toNat ≤ '9'.toNat := by decide
  have le_iff_le : ∀ {c c' : Char}, c ≤ c' ↔ c.toNat ≤ c'.toNat := fun _ _ => Iff.rfl
  constructor
  · simp only [digit, sat_eq_done, pure_eq_done, decorate_error_eq_done, bind_eq_done, ← c9]
    rintro ⟨np, c, ⟨hn, ⟨ge0, le9⟩, rfl, rfl⟩, rfl, rfl⟩
    simpa [hn, ge0, le9, true_and_iff, and_true_iff, eq_self_iff_true, exists_prop_of_true,
      tsub_le_tsub_iff_right, l09] using le_iff_le.mp le9
  · simp only [digit, sat_eq_done, pure_eq_done, decorate_error_eq_done, bind_eq_done, ← c9,
      le_iff_le]
    rintro ⟨hn, rfl, -, rfl, ge0, le9⟩
    use n + 1, cb.read ⟨n, hn⟩
    simp [hn, ge0, le9]
#align parser.digit_eq_done Parser.digit_eq_done

theorem digit_eq_fail :
    digit cb n = fail n' err ↔
      n = n' ∧
        err = Std.DList.ofList ["<digit>"] ∧
          ∀ h : n < cb.size, ¬(fun c => '0' ≤ c ∧ c ≤ '9') (cb.read ⟨n, h⟩) :=
  by simp [digit, sat_eq_fail]
#align parser.digit_eq_fail Parser.digit_eq_fail

end Done

namespace Static

variable {α β : Type} {p q : Parser α} {msgs : Thunk (List String)} {msg : Thunk String}
  {cb : CharBuffer} {n' n : ℕ} {err : Std.DList String} {a : α} {b : β} {sep : Parser Unit}

theorem not_of_ne (h : p cb n = done n' a) (hne : n ≠ n') : ¬Static p := by intro;
  exact hne (of_done h)
#align parser.static.not_of_ne Parser.Static.not_of_ne

instance pure : Static (pure a) :=
  ⟨fun _ _ _ _ => by simp_rw [pure_eq_done]; rw [and_comm]; simp⟩
#align parser.static.pure Parser.Static.pure

instance bind {f : α → Parser β} [p.Static] [∀ a, (f a).Static] : (p >>= f).Static :=
  ⟨fun _ _ _ _ => by rw [bind_eq_done]; rintro ⟨_, _, hp, hf⟩;
    exact trans (of_done hp) (of_done hf)⟩
#align parser.static.bind Parser.Static.bind

instance andThen {q : Parser β} [p.Static] [q.Static] : (p >> q).Static :=
  Static.bind
#align parser.static.and_then Parser.Static.andThen

instance map [p.Static] {f : α → β} : (f <$> p).Static :=
  ⟨fun _ _ _ _ => by simp_rw [map_eq_done]; rintro ⟨_, hp, _⟩; exact of_done hp⟩
#align parser.static.map Parser.Static.map

instance seq {f : Parser (α → β)} [f.Static] [p.Static] : (f <*> p).Static :=
  Static.bind
#align parser.static.seq Parser.Static.seq

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM : ∀ {l : List α} {f : α → Parser β} [∀ a, (f a).Static], (l.mapM f).Static
  | [], _, _ => Static.pure
  | a::l, _, h => by
    convert static.bind
    · exact h _
    · intro
      convert static.bind
      · convert mmap
        exact h
      · exact fun _ => static.pure
#align parser.static.mmap Parser.Static.mapM

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM' : ∀ {l : List α} {f : α → Parser β} [∀ a, (f a).Static], (l.mapM' f).Static
  | [], _, _ => Static.pure
  | a::l, _, h => by
    convert static.and_then
    · exact h _
    · convert mmap'
      exact h
#align parser.static.mmap' Parser.Static.mapM'

instance failure : @Parser.Static α failure :=
  ⟨fun _ _ _ _ => by simp⟩
#align parser.static.failure Parser.Static.failure

instance guard {p : Prop} [Decidable p] : Static (guard p) :=
  ⟨fun _ _ _ _ => by simp [guard_eq_done]⟩
#align parser.static.guard Parser.Static.guard

instance orelse [p.Static] [q.Static] : (p <|> q).Static :=
  ⟨fun _ _ _ _ => by simp_rw [orelse_eq_done]; rintro (h | ⟨h, -⟩) <;> exact of_done h⟩
#align parser.static.orelse Parser.Static.orelse

instance decorateErrors [p.Static] : (@decorateErrors α msgs p).Static :=
  ⟨fun _ _ _ _ => by rw [decorate_errors_eq_done]; exact of_done⟩
#align parser.static.decorate_errors Parser.Static.decorateErrors

instance decorateError [p.Static] : (@decorateError α msg p).Static :=
  Static.decorateErrors
#align parser.static.decorate_error Parser.Static.decorateError

theorem anyChar : ¬Static anyChar :=
  haveI : any_char "s".toCharBuffer 0 = done 1 's' :=
    by
    have : 0 < "s".toCharBuffer.size := by decide
    simpa [any_char_eq_done, this]
  not_of_ne this zero_ne_one
#align parser.static.any_char Parser.Static.anyChar

theorem sat_iff {p : Char → Prop} [DecidablePred p] : Static (sat p) ↔ ∀ c, ¬p c :=
  by
  constructor
  · intro
    intro c hc
    have : sat p [c].toBuffer 0 = done 1 c := by simp [sat_eq_done, hc]
    exact zero_ne_one (of_done this)
  · contrapose!
    simp only [Iff, sat_eq_done, and_imp, exists_prop, exists_and_right, exists_and_left,
      exists_imp, not_forall]
    rintro _ _ _ a h hne rfl hp -
    exact ⟨a, hp⟩
#align parser.static.sat_iff Parser.Static.sat_iff

instance sat : Static (sat fun _ => False) := by apply sat_iff.mpr; simp
#align parser.static.sat Parser.Static.sat

instance eps : Static eps :=
  Static.pure
#align parser.static.eps Parser.Static.eps

theorem ch (c : Char) : ¬Static (ch c) :=
  haveI : ch c [c].toBuffer 0 = done 1 () :=
    by
    have : 0 < [c].toBuffer.size := by decide
    simp [ch_eq_done, this]
  not_of_ne this zero_ne_one
#align parser.static.ch Parser.Static.ch

theorem charBuf_iff {cb' : CharBuffer} : Static (charBuf cb') ↔ cb' = Buffer.nil :=
  by
  rw [← Buffer.size_eq_zero_iff]
  have : char_buf cb' cb' 0 = done cb'.size () := by simp [char_buf_eq_done]
  cases' hc : cb'.size with n
  · simp only [eq_self_iff_true, iff_true_iff]
    exact ⟨fun _ _ _ _ h => by simpa [hc] using (char_buf_eq_done.mp h).left⟩
  · rw [hc] at this 
    simpa [Nat.succ_ne_zero] using not_of_ne this (Nat.succ_ne_zero n).symm
#align parser.static.char_buf_iff Parser.Static.charBuf_iff

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem oneOf_iff {cs : List Char} : Static (oneOf cs) ↔ cs = [] :=
  by
  cases' cs with hd tl
  · simp [one_of, static.decorate_errors]
  · have : one_of (hd::tl) (hd::tl).toBuffer 0 = done 1 hd := by simp [one_of_eq_done]
    simpa using not_of_ne this zero_ne_one
#align parser.static.one_of_iff Parser.Static.oneOf_iff

instance oneOf : Static (oneOf []) := by apply one_of_iff.mpr; rfl
#align parser.static.one_of Parser.Static.oneOf

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem oneOf'_iff {cs : List Char} : Static (oneOf' cs) ↔ cs = [] :=
  by
  cases' cs with hd tl
  · simp [one_of', static.bind]
  · have : one_of' (hd::tl) (hd::tl).toBuffer 0 = done 1 () := by simp [one_of'_eq_done]
    simpa using not_of_ne this zero_ne_one
#align parser.static.one_of'_iff Parser.Static.oneOf'_iff

instance one_of' : Static (oneOf []) := by apply one_of_iff.mpr; rfl
#align parser.static.one_of' Parser.Static.one_of'

theorem str_iff {s : String} : Static (str s) ↔ s = "" := by
  simp [str_eq_char_buf, char_buf_iff, ← String.toList_inj, Buffer.ext_iff]
#align parser.static.str_iff Parser.Static.str_iff

instance remaining : remaining.Static :=
  ⟨fun _ _ _ _ h => (remaining_eq_done.mp h).left⟩
#align parser.static.remaining Parser.Static.remaining

instance eof : eof.Static :=
  Static.decorateError
#align parser.static.eof Parser.Static.eof

instance foldrCore {f : α → β → β} [p.Static] : ∀ {b : β} {reps : ℕ}, (foldrCore f p b reps).Static
  | _, 0 => Static.failure
  | _, reps + 1 => by
    simp_rw [Parser.foldrCore]
    convert static.orelse
    · convert static.bind
      · infer_instance
      · intro
        convert static.bind
        · exact foldr_core
        · infer_instance
    · exact static.pure
#align parser.static.foldr_core Parser.Static.foldrCore

instance foldr {f : α → β → β} [p.Static] : Static (foldr f p b) :=
  ⟨fun _ _ _ _ => by dsimp [foldr]; exact of_done⟩
#align parser.static.foldr Parser.Static.foldr

instance foldlCore {f : α → β → α} {p : Parser β} [p.Static] :
    ∀ {a : α} {reps : ℕ}, (foldlCore f a p reps).Static
  | _, 0 => Static.failure
  | _, reps + 1 => by
    convert static.orelse
    · convert static.bind
      · infer_instance
      · exact fun _ => foldl_core
    · exact static.pure
#align parser.static.foldl_core Parser.Static.foldlCore

instance foldl {f : α → β → α} {p : Parser β} [p.Static] : Static (foldl f a p) :=
  ⟨fun _ _ _ _ => by dsimp [foldl]; exact of_done⟩
#align parser.static.foldl Parser.Static.foldl

instance many [p.Static] : p.anyM.Static :=
  Static.foldr
#align parser.static.many Parser.Static.many

instance manyChar {p : Parser Char} [p.Static] : p.manyChar.Static :=
  Static.map
#align parser.static.many_char Parser.Static.manyChar

instance many' [p.Static] : p.many'.Static :=
  Static.andThen
#align parser.static.many' Parser.Static.many'

instance many1 [p.Static] : p.many1.Static :=
  Static.seq
#align parser.static.many1 Parser.Static.many1

instance manyChar1 {p : Parser Char} [p.Static] : p.manyChar1.Static :=
  Static.map
#align parser.static.many_char1 Parser.Static.manyChar1

instance sepBy1 [p.Static] [sep.Static] : Static (sepBy1 sep p) :=
  Static.seq
#align parser.static.sep_by1 Parser.Static.sepBy1

instance sepBy [p.Static] [sep.Static] : Static (sepBy sep p) :=
  Static.orelse
#align parser.static.sep_by Parser.Static.sepBy

theorem fixCore {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.Static → (F p).Static) :
    ∀ max_depth : ℕ, Static (fixCore F max_depth)
  | 0 => Static.failure
  | max_depth + 1 => hF _ (fix_core _)
#align parser.static.fix_core Parser.Static.fixCore

theorem digit : ¬digit.Static :=
  haveI : digit "1".toCharBuffer 0 = done 1 1 :=
    by
    have : 0 < "s".toCharBuffer.size := by decide
    simpa [this]
  not_of_ne this zero_ne_one
#align parser.static.digit Parser.Static.digit

theorem nat : ¬nat.Static :=
  haveI : Nat "1".toCharBuffer 0 = done 1 1 :=
    by
    have : 0 < "s".toCharBuffer.size := by decide
    simpa [this]
  not_of_ne this zero_ne_one
#align parser.static.nat Parser.Static.nat

theorem fix {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.Static → (F p).Static) :
    Static (fix F) :=
  ⟨fun cb n _ _ h => by haveI := fix_core hF (cb.size - n + 1); dsimp [fix] at h ;
    exact static.of_done h⟩
#align parser.static.fix Parser.Static.fix

end Static

namespace Bounded

variable {α β : Type} {msgs : Thunk (List String)} {msg : Thunk String}

variable {p q : Parser α} {cb : CharBuffer} {n n' : ℕ} {err : Std.DList String}

variable {a : α} {b : β}

theorem done_of_unbounded (h : ¬p.Bounded) :
    ∃ (cb : CharBuffer) (n n' : ℕ) (a : α), p cb n = done n' a ∧ cb.size ≤ n :=
  by
  contrapose! h
  constructor
  intro cb n hn
  cases hp : p cb n
  · exact absurd hn (h _ _ _ _ hp).not_le
  · simp [hp]
#align parser.bounded.done_of_unbounded Parser.Bounded.done_of_unbounded

theorem pure : ¬Bounded (pure a) := by
  intro
  have : (pure a : Parser α) Buffer.nil 0 = done 0 a := by simp [pure_eq_done]
  exact absurd (bounded.of_done this) (lt_irrefl _)
#align parser.bounded.pure Parser.Bounded.pure

instance bind {f : α → Parser β} [p.Bounded] : (p >>= f).Bounded :=
  by
  constructor
  intro cb n hn
  obtain ⟨_, _, hp⟩ := bounded.exists p hn
  simp [hp]
#align parser.bounded.bind Parser.Bounded.bind

instance andThen {q : Parser β} [p.Bounded] : (p >> q).Bounded :=
  Bounded.bind
#align parser.bounded.and_then Parser.Bounded.andThen

instance map [p.Bounded] {f : α → β} : (f <$> p).Bounded :=
  Bounded.bind
#align parser.bounded.map Parser.Bounded.map

instance seq {f : Parser (α → β)} [f.Bounded] : (f <*> p).Bounded :=
  Bounded.bind
#align parser.bounded.seq Parser.Bounded.seq

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM {a : α} {l : List α} {f : α → Parser β} [∀ a, (f a).Bounded] :
    ((a::l).mapM f).Bounded :=
  Bounded.bind
#align parser.bounded.mmap Parser.Bounded.mapM

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM' {a : α} {l : List α} {f : α → Parser β} [∀ a, (f a).Bounded] :
    ((a::l).mapM' f).Bounded :=
  Bounded.andThen
#align parser.bounded.mmap' Parser.Bounded.mapM'

instance failure : @Parser.Bounded α failure :=
  ⟨by simp⟩
#align parser.bounded.failure Parser.Bounded.failure

theorem guard_iff {p : Prop} [Decidable p] : Bounded (guard p) ↔ ¬p := by
  simpa [guard, apply_ite bounded, pure, failure] using fun _ => bounded.failure
#align parser.bounded.guard_iff Parser.Bounded.guard_iff

instance orelse [p.Bounded] [q.Bounded] : (p <|> q).Bounded :=
  by
  constructor
  intro cb n hn
  cases' hx : (p <|> q) cb n with posx resx posx errx
  · obtain h | ⟨h, -, -⟩ := orelse_eq_done.mp hx <;> exact absurd hn (of_done h).not_le
  · simp
#align parser.bounded.orelse Parser.Bounded.orelse

instance decorateErrors [p.Bounded] : (@decorateErrors α msgs p).Bounded :=
  by
  constructor
  intro _ _
  simpa using bounded.exists p
#align parser.bounded.decorate_errors Parser.Bounded.decorateErrors

theorem decorateErrors_iff : (@Parser.decorateErrors α msgs p).Bounded ↔ p.Bounded :=
  by
  constructor
  · intro
    constructor
    intro _ _ hn
    obtain ⟨_, _, h⟩ := bounded.exists (@Parser.decorateErrors α msgs p) hn
    simp [decorate_errors_eq_fail] at h 
    exact h.right.right
  · intro
    constructor
    intro _ _ hn
    obtain ⟨_, _, h⟩ := bounded.exists p hn
    simp [h]
#align parser.bounded.decorate_errors_iff Parser.Bounded.decorateErrors_iff

instance decorateError [p.Bounded] : (@decorateError α msg p).Bounded :=
  Bounded.decorateErrors
#align parser.bounded.decorate_error Parser.Bounded.decorateError

theorem decorateError_iff : (@Parser.decorateError α msg p).Bounded ↔ p.Bounded :=
  decorateErrors_iff
#align parser.bounded.decorate_error_iff Parser.Bounded.decorateError_iff

instance anyChar : Bounded anyChar :=
  ⟨fun cb n hn => by simp [any_char, hn]⟩
#align parser.bounded.any_char Parser.Bounded.anyChar

instance sat {p : Char → Prop} [DecidablePred p] : Bounded (sat p) :=
  ⟨fun cb n hn => by simp [sat, hn]⟩
#align parser.bounded.sat Parser.Bounded.sat

theorem eps : ¬Bounded eps :=
  pure
#align parser.bounded.eps Parser.Bounded.eps

instance ch {c : Char} : Bounded (ch c) :=
  Bounded.decorateError
#align parser.bounded.ch Parser.Bounded.ch

theorem charBuf_iff {cb' : CharBuffer} : Bounded (charBuf cb') ↔ cb' ≠ Buffer.nil :=
  by
  have : cb' ≠ Buffer.nil ↔ cb'.to_list ≠ [] :=
    not_congr ⟨fun h => by simp [h], fun h => by simpa using congr_arg List.toBuffer h⟩
  rw [char_buf, decorate_error_iff, this]
  cases cb'.to_list
  · simp [pure, ch]
  · simp only [iff_true_iff, Ne.def, not_false_iff]
    infer_instance
#align parser.bounded.char_buf_iff Parser.Bounded.charBuf_iff

instance oneOf {cs : List Char} : (oneOf cs).Bounded :=
  Bounded.decorateErrors
#align parser.bounded.one_of Parser.Bounded.oneOf

instance oneOf' {cs : List Char} : (oneOf' cs).Bounded :=
  Bounded.andThen
#align parser.bounded.one_of' Parser.Bounded.oneOf'

theorem str_iff {s : String} : (str s).Bounded ↔ s ≠ "" :=
  by
  rw [str, decorate_error_iff]
  cases hs : s.to_list
  · have : s = "" := by cases s; rw [String.toList] at hs ; simpa [hs]
    simp [pure, this]
  · have : s ≠ "" := by intro H; simpa [H] using hs
    simp only [this, iff_true_iff, Ne.def, not_false_iff]
    infer_instance
#align parser.bounded.str_iff Parser.Bounded.str_iff

theorem remaining : ¬remaining.Bounded := by
  intro
  have : remaining Buffer.nil 0 = done 0 0 := by simp [remaining_eq_done]
  exact absurd (bounded.of_done this) (lt_irrefl _)
#align parser.bounded.remaining Parser.Bounded.remaining

theorem eof : ¬eof.Bounded := by
  intro
  have : eof Buffer.nil 0 = done 0 () := by simp [eof_eq_done]
  exact absurd (bounded.of_done this) (lt_irrefl _)
#align parser.bounded.eof Parser.Bounded.eof

section Fold

instance foldrCore_zero {f : α → β → β} : (foldrCore f p b 0).Bounded :=
  Bounded.failure
#align parser.bounded.foldr_core_zero Parser.Bounded.foldrCore_zero

instance foldlCore_zero {f : β → α → β} {b : β} : (foldlCore f b p 0).Bounded :=
  Bounded.failure
#align parser.bounded.foldl_core_zero Parser.Bounded.foldlCore_zero

variable {reps : ℕ} [hpb : p.Bounded] (he : ∀ cb n n' err, p cb n = fail n' err → n ≠ n')

theorem foldrCore {f : α → β → β} : (foldrCore f p b reps).Bounded :=
  by
  cases reps
  · exact bounded.foldr_core_zero
  constructor
  intro cb n hn
  obtain ⟨np, errp, hp⟩ := bounded.exists p hn
  simpa [foldr_core_succ_eq_fail, hp] using he cb n np errp
#align parser.bounded.foldr_core Parser.Bounded.foldrCore

theorem foldr {f : α → β → β} : Bounded (foldr f p b) :=
  by
  constructor
  intro cb n hn
  haveI : (Parser.foldrCore f p b (cb.size - n + 1)).Bounded := foldr_core he
  obtain ⟨np, errp, hp⟩ := bounded.exists (Parser.foldrCore f p b (cb.size - n + 1)) hn
  simp [foldr, hp]
#align parser.bounded.foldr Parser.Bounded.foldr

theorem foldlCore {f : β → α → β} : (foldlCore f b p reps).Bounded :=
  by
  cases reps
  · exact bounded.foldl_core_zero
  constructor
  intro cb n hn
  obtain ⟨np, errp, hp⟩ := bounded.exists p hn
  simpa [foldl_core_succ_eq_fail, hp] using he cb n np errp
#align parser.bounded.foldl_core Parser.Bounded.foldlCore

theorem foldl {f : β → α → β} : Bounded (foldl f b p) :=
  by
  constructor
  intro cb n hn
  haveI : (Parser.foldlCore f b p (cb.size - n + 1)).Bounded := foldl_core he
  obtain ⟨np, errp, hp⟩ := bounded.exists (Parser.foldlCore f b p (cb.size - n + 1)) hn
  simp [foldl, hp]
#align parser.bounded.foldl Parser.Bounded.foldl

theorem many : p.anyM.Bounded :=
  foldr he
#align parser.bounded.many Parser.Bounded.many

theorem manyChar {pc : Parser Char} [pc.Bounded]
    (he : ∀ cb n n' err, pc cb n = fail n' err → n ≠ n') : pc.manyChar.Bounded := by
  convert bounded.map; exact many he
#align parser.bounded.many_char Parser.Bounded.manyChar

theorem many' : p.many'.Bounded := by convert bounded.and_then; exact many he
#align parser.bounded.many' Parser.Bounded.many'

end Fold

instance many1 [p.Bounded] : p.many1.Bounded :=
  Bounded.seq
#align parser.bounded.many1 Parser.Bounded.many1

instance manyChar1 {p : Parser Char} [p.Bounded] : p.manyChar1.Bounded :=
  Bounded.map
#align parser.bounded.many_char1 Parser.Bounded.manyChar1

instance sepBy1 {sep : Parser Unit} [p.Bounded] : Bounded (sepBy1 sep p) :=
  Bounded.seq
#align parser.bounded.sep_by1 Parser.Bounded.sepBy1

theorem fixCore {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.Bounded → (F p).Bounded) :
    ∀ max_depth : ℕ, Bounded (fixCore F max_depth)
  | 0 => Bounded.failure
  | max_depth + 1 => hF _ (fix_core _)
#align parser.bounded.fix_core Parser.Bounded.fixCore

instance digit : digit.Bounded :=
  Bounded.decorateError
#align parser.bounded.digit Parser.Bounded.digit

instance nat : nat.Bounded :=
  Bounded.decorateError
#align parser.bounded.nat Parser.Bounded.nat

theorem fix {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.Bounded → (F p).Bounded) :
    Bounded (fix F) := by
  constructor
  intro cb n hn
  haveI : (Parser.fixCore F (cb.size - n + 1)).Bounded := fix_core hF _
  obtain ⟨np, errp, hp⟩ := bounded.exists (Parser.fixCore F (cb.size - n + 1)) hn
  simp [fix, hp]
#align parser.bounded.fix Parser.Bounded.fix

end Bounded

namespace Unfailing

variable {α β : Type} {p q : Parser α} {msgs : Thunk (List String)} {msg : Thunk String}
  {cb : CharBuffer} {n' n : ℕ} {err : Std.DList String} {a : α} {b : β} {sep : Parser Unit}

theorem of_bounded [p.Bounded] : ¬Unfailing p :=
  by
  intro
  cases h : p Buffer.nil 0
  · simpa [lt_irrefl] using bounded.of_done h
  · exact of_fail h
#align parser.unfailing.of_bounded Parser.Unfailing.of_bounded

instance pure : Unfailing (pure a) :=
  ⟨fun _ _ => by simp [pure_eq_done]⟩
#align parser.unfailing.pure Parser.Unfailing.pure

instance bind {f : α → Parser β} [p.Unfailing] [∀ a, (f a).Unfailing] : (p >>= f).Unfailing :=
  ⟨fun cb n => by
    obtain ⟨np, a, hp⟩ := exists_done p cb n
    simpa [hp, and_comm, and_left_comm, and_assoc] using exists_done (f a) cb np⟩
#align parser.unfailing.bind Parser.Unfailing.bind

instance andThen {q : Parser β} [p.Unfailing] [q.Unfailing] : (p >> q).Unfailing :=
  Unfailing.bind
#align parser.unfailing.and_then Parser.Unfailing.andThen

instance map [p.Unfailing] {f : α → β} : (f <$> p).Unfailing :=
  Unfailing.bind
#align parser.unfailing.map Parser.Unfailing.map

instance seq {f : Parser (α → β)} [f.Unfailing] [p.Unfailing] : (f <*> p).Unfailing :=
  Unfailing.bind
#align parser.unfailing.seq Parser.Unfailing.seq

instance mapM {l : List α} {f : α → Parser β} [∀ a, (f a).Unfailing] : (l.mapM f).Unfailing :=
  by
  constructor
  induction' l with hd tl hl
  · intros
    simp [pure_eq_done]
  · intros
    obtain ⟨np, a, hp⟩ := exists_done (f hd) cb n
    obtain ⟨n', b, hf⟩ := hl cb np
    simp [hp, hf, and_comm, and_left_comm, and_assoc, pure_eq_done]
#align parser.unfailing.mmap Parser.Unfailing.mapM

instance mapM' {l : List α} {f : α → Parser β} [∀ a, (f a).Unfailing] : (l.mapM' f).Unfailing :=
  by
  constructor
  induction' l with hd tl hl
  · intros
    simp [pure_eq_done]
  · intros
    obtain ⟨np, a, hp⟩ := exists_done (f hd) cb n
    obtain ⟨n', b, hf⟩ := hl cb np
    simp [hp, hf, and_comm, and_left_comm, and_assoc, pure_eq_done]
#align parser.unfailing.mmap' Parser.Unfailing.mapM'

theorem failure : ¬@Parser.Unfailing α failure :=
  by
  intro h
  have : (failure : Parser α) Buffer.nil 0 = fail 0 Std.DList.empty := by simp
  exact of_fail this
#align parser.unfailing.failure Parser.Unfailing.failure

instance guard_true : Unfailing (guard True) :=
  Unfailing.pure
#align parser.unfailing.guard_true Parser.Unfailing.guard_true

theorem guard : ¬Unfailing (guard False) :=
  Unfailing.failure
#align parser.unfailing.guard Parser.Unfailing.guard

instance orelse [p.Unfailing] : (p <|> q).Unfailing :=
  ⟨fun cb n => by obtain ⟨_, _, h⟩ := p.exists_done cb n; simp [success_iff, h]⟩
#align parser.unfailing.orelse Parser.Unfailing.orelse

instance decorateErrors [p.Unfailing] : (@decorateErrors α msgs p).Unfailing :=
  ⟨fun cb n => by obtain ⟨_, _, h⟩ := p.exists_done cb n; simp [success_iff, h]⟩
#align parser.unfailing.decorate_errors Parser.Unfailing.decorateErrors

instance decorateError [p.Unfailing] : (@decorateError α msg p).Unfailing :=
  Unfailing.decorateErrors
#align parser.unfailing.decorate_error Parser.Unfailing.decorateError

instance anyChar : ConditionallyUnfailing anyChar :=
  ⟨fun _ _ hn => by simp [success_iff, any_char_eq_done, hn]⟩
#align parser.unfailing.any_char Parser.Unfailing.anyChar

theorem sat : ConditionallyUnfailing (sat fun _ => True) :=
  ⟨fun _ _ hn => by simp [success_iff, sat_eq_done, hn]⟩
#align parser.unfailing.sat Parser.Unfailing.sat

instance eps : Unfailing eps :=
  Unfailing.pure
#align parser.unfailing.eps Parser.Unfailing.eps

instance remaining : remaining.Unfailing :=
  ⟨fun _ _ => by simp [success_iff, remaining_eq_done]⟩
#align parser.unfailing.remaining Parser.Unfailing.remaining

theorem foldrCore_zero {f : α → β → β} {b : β} : ¬(foldrCore f p b 0).Unfailing :=
  Unfailing.failure
#align parser.unfailing.foldr_core_zero Parser.Unfailing.foldrCore_zero

instance foldrCore_of_static {f : α → β → β} {b : β} {reps : ℕ} [p.Static] [p.Unfailing] :
    (foldrCore f p b (reps + 1)).Unfailing :=
  by
  induction' reps with reps hr
  · constructor
    intro cb n
    obtain ⟨np, a, h⟩ := p.exists_done cb n
    simpa [foldr_core_eq_done, h] using (static.of_done h).symm
  · constructor
    haveI := hr
    intro cb n
    obtain ⟨np, a, h⟩ := p.exists_done cb n
    obtain rfl : n = np := static.of_done h
    obtain ⟨np, b', hf⟩ := exists_done (foldr_core f p b (reps + 1)) cb n
    obtain rfl : n = np := static.of_done hf
    refine' ⟨n, f a b', _⟩
    rw [foldr_core_eq_done]
    simp [h, hf, and_comm, and_left_comm, and_assoc]
#align parser.unfailing.foldr_core_of_static Parser.Unfailing.foldrCore_of_static

instance foldrCore_one_of_errStatic {f : α → β → β} {b : β} [p.Static] [p.ErrStatic] :
    (foldrCore f p b 1).Unfailing := by
  constructor
  intro cb n
  cases h : p cb n
  · simpa [foldr_core_eq_done, h] using (static.of_done h).symm
  · simpa [foldr_core_eq_done, h] using (err_static.of_fail h).symm
#align parser.unfailing.foldr_core_one_of_err_static Parser.Unfailing.foldrCore_one_of_errStatic

-- TODO: add foldr and foldl, many, etc, fix_core
theorem digit : ¬digit.Unfailing :=
  of_bounded
#align parser.unfailing.digit Parser.Unfailing.digit

theorem nat : ¬nat.Unfailing :=
  of_bounded
#align parser.unfailing.nat Parser.Unfailing.nat

end Unfailing

namespace ErrStatic

variable {α β : Type} {p q : Parser α} {msgs : Thunk (List String)} {msg : Thunk String}
  {cb : CharBuffer} {n' n : ℕ} {err : Std.DList String} {a : α} {b : β} {sep : Parser Unit}

theorem not_of_ne (h : p cb n = fail n' err) (hne : n ≠ n') : ¬ErrStatic p := by intro;
  exact hne (of_fail h)
#align parser.err_static.not_of_ne Parser.ErrStatic.not_of_ne

instance pure : ErrStatic (pure a) :=
  ⟨fun _ _ _ _ => by simp [pure_eq_done]⟩
#align parser.err_static.pure Parser.ErrStatic.pure

instance bind {f : α → Parser β} [p.Static] [p.ErrStatic] [∀ a, (f a).ErrStatic] :
    (p >>= f).ErrStatic :=
  ⟨fun cb n n' err => by
    rw [bind_eq_fail]
    rintro (hp | ⟨_, _, hp, hf⟩)
    · exact of_fail hp
    · exact trans (static.of_done hp) (of_fail hf)⟩
#align parser.err_static.bind Parser.ErrStatic.bind

instance bind_of_unfailing {f : α → Parser β} [p.ErrStatic] [∀ a, (f a).Unfailing] :
    (p >>= f).ErrStatic :=
  ⟨fun cb n n' err => by
    rw [bind_eq_fail]
    rintro (hp | ⟨_, _, hp, hf⟩)
    · exact of_fail hp
    · exact False.elim (unfailing.of_fail hf)⟩
#align parser.err_static.bind_of_unfailing Parser.ErrStatic.bind_of_unfailing

instance andThen {q : Parser β} [p.Static] [p.ErrStatic] [q.ErrStatic] : (p >> q).ErrStatic :=
  ErrStatic.bind
#align parser.err_static.and_then Parser.ErrStatic.andThen

instance andThen_of_unfailing {q : Parser β} [p.ErrStatic] [q.Unfailing] : (p >> q).ErrStatic :=
  ErrStatic.bind_of_unfailing
#align parser.err_static.and_then_of_unfailing Parser.ErrStatic.andThen_of_unfailing

instance map [p.ErrStatic] {f : α → β} : (f <$> p).ErrStatic :=
  ⟨fun _ _ _ _ => by rw [map_eq_fail]; exact of_fail⟩
#align parser.err_static.map Parser.ErrStatic.map

instance seq {f : Parser (α → β)} [f.Static] [f.ErrStatic] [p.ErrStatic] : (f <*> p).ErrStatic :=
  ErrStatic.bind
#align parser.err_static.seq Parser.ErrStatic.seq

instance seq_of_unfailing {f : Parser (α → β)} [f.ErrStatic] [p.Unfailing] : (f <*> p).ErrStatic :=
  ErrStatic.bind_of_unfailing
#align parser.err_static.seq_of_unfailing Parser.ErrStatic.seq_of_unfailing

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM :
    ∀ {l : List α} {f : α → Parser β} [∀ a, (f a).Static] [∀ a, (f a).ErrStatic],
      (l.mapM f).ErrStatic
  | [], _, _, _ => ErrStatic.pure
  | a::l, _, h, h' => by
    convert err_static.bind
    · exact h _
    · exact h' _
    · intro
      convert err_static.bind
      · convert static.mmap
        exact h
      · apply mmap
        · exact h
        · exact h'
      · exact fun _ => err_static.pure
#align parser.err_static.mmap Parser.ErrStatic.mapM

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM_of_unfailing :
    ∀ {l : List α} {f : α → Parser β} [∀ a, (f a).Unfailing] [∀ a, (f a).ErrStatic],
      (l.mapM f).ErrStatic
  | [], _, _, _ => ErrStatic.pure
  | a::l, _, h, h' => by
    convert err_static.bind_of_unfailing
    · exact h' _
    · intro
      convert unfailing.bind
      · convert unfailing.mmap
        exact h
      · exact fun _ => unfailing.pure
#align parser.err_static.mmap_of_unfailing Parser.ErrStatic.mapM_of_unfailing

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM' :
    ∀ {l : List α} {f : α → Parser β} [∀ a, (f a).Static] [∀ a, (f a).ErrStatic],
      (l.mapM' f).ErrStatic
  | [], _, _, _ => ErrStatic.pure
  | a::l, _, h, h' => by
    convert err_static.and_then
    · exact h _
    · exact h' _
    · convert mmap'
      · exact h
      · exact h'
#align parser.err_static.mmap' Parser.ErrStatic.mapM'

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM'_of_unfailing :
    ∀ {l : List α} {f : α → Parser β} [∀ a, (f a).Unfailing] [∀ a, (f a).ErrStatic],
      (l.mapM' f).ErrStatic
  | [], _, _, _ => ErrStatic.pure
  | a::l, _, h, h' => by
    convert err_static.and_then_of_unfailing
    · exact h' _
    · convert unfailing.mmap'
      exact h
#align parser.err_static.mmap'_of_unfailing Parser.ErrStatic.mapM'_of_unfailing

instance failure : @Parser.ErrStatic α failure :=
  ⟨fun _ _ _ _ h => (failure_eq_fail.mp h).left⟩
#align parser.err_static.failure Parser.ErrStatic.failure

instance guard {p : Prop} [Decidable p] : ErrStatic (guard p) :=
  ⟨fun _ _ _ _ h => (guard_eq_fail.mp h).right.left⟩
#align parser.err_static.guard Parser.ErrStatic.guard

instance orelse [p.ErrStatic] [q.mono] : (p <|> q).ErrStatic :=
  ⟨fun _ n n' _ => by
    by_cases hn : n = n'
    · exact fun _ => hn
    · rw [orelse_eq_fail_of_mono_ne hn]
      · exact of_fail
      · infer_instance⟩
#align parser.err_static.orelse Parser.ErrStatic.orelse

instance decorateErrors : (@decorateErrors α msgs p).ErrStatic :=
  ⟨fun _ _ _ _ h => (decorateErrors_eq_fail.mp h).left⟩
#align parser.err_static.decorate_errors Parser.ErrStatic.decorateErrors

instance decorateError : (@decorateError α msg p).ErrStatic :=
  ErrStatic.decorateErrors
#align parser.err_static.decorate_error Parser.ErrStatic.decorateError

instance anyChar : ErrStatic anyChar :=
  ⟨fun _ _ _ _ => by rw [any_char_eq_fail, and_comm]; simp⟩
#align parser.err_static.any_char Parser.ErrStatic.anyChar

instance sat_iff {p : Char → Prop} [DecidablePred p] : ErrStatic (sat p) :=
  ⟨fun _ _ _ _ h => (sat_eq_fail.mp h).left⟩
#align parser.err_static.sat_iff Parser.ErrStatic.sat_iff

instance eps : ErrStatic eps :=
  ErrStatic.pure
#align parser.err_static.eps Parser.ErrStatic.eps

instance ch (c : Char) : ErrStatic (ch c) :=
  ErrStatic.decorateError
#align parser.err_static.ch Parser.ErrStatic.ch

instance charBuf {cb' : CharBuffer} : ErrStatic (charBuf cb') :=
  ErrStatic.decorateError
#align parser.err_static.char_buf Parser.ErrStatic.charBuf

instance oneOf {cs : List Char} : ErrStatic (oneOf cs) :=
  ErrStatic.decorateErrors
#align parser.err_static.one_of Parser.ErrStatic.oneOf

instance oneOf' {cs : List Char} : ErrStatic (oneOf' cs) :=
  ErrStatic.andThen_of_unfailing
#align parser.err_static.one_of' Parser.ErrStatic.oneOf'

instance str {s : String} : ErrStatic (str s) :=
  ErrStatic.decorateError
#align parser.err_static.str Parser.ErrStatic.str

instance remaining : remaining.ErrStatic :=
  ⟨fun _ _ _ _ => by simp [remaining_ne_fail]⟩
#align parser.err_static.remaining Parser.ErrStatic.remaining

instance eof : eof.ErrStatic :=
  ErrStatic.decorateError
#align parser.err_static.eof Parser.ErrStatic.eof

-- TODO: add foldr and foldl, many, etc, fix_core
theorem fixCore {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.ErrStatic → (F p).ErrStatic) :
    ∀ max_depth : ℕ, ErrStatic (fixCore F max_depth)
  | 0 => ErrStatic.failure
  | max_depth + 1 => hF _ (fix_core _)
#align parser.err_static.fix_core Parser.ErrStatic.fixCore

instance digit : digit.ErrStatic :=
  ErrStatic.decorateError
#align parser.err_static.digit Parser.ErrStatic.digit

instance nat : nat.ErrStatic :=
  ErrStatic.decorateError
#align parser.err_static.nat Parser.ErrStatic.nat

theorem fix {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.ErrStatic → (F p).ErrStatic) :
    ErrStatic (fix F) :=
  ⟨fun cb n _ _ h => by haveI := fix_core hF (cb.size - n + 1); dsimp [fix] at h ;
    exact err_static.of_fail h⟩
#align parser.err_static.fix Parser.ErrStatic.fix

end ErrStatic

namespace Step

variable {α β : Type} {p q : Parser α} {msgs : Thunk (List String)} {msg : Thunk String}
  {cb : CharBuffer} {n' n : ℕ} {err : Std.DList String} {a : α} {b : β} {sep : Parser Unit}

theorem not_step_of_static_done [Static p] (h : ∃ cb n n' a, p cb n = done n' a) : ¬Step p :=
  by
  intro
  rcases h with ⟨cb, n, n', a, h⟩
  have hs := static.of_done h
  simpa [← hs] using of_done h
#align parser.step.not_step_of_static_done Parser.Step.not_step_of_static_done

theorem pure (a : α) : ¬Step (pure a) :=
  by
  apply not_step_of_static_done
  simp [pure_eq_done]
#align parser.step.pure Parser.Step.pure

instance bind {f : α → Parser β} [p.step] [∀ a, (f a).Static] : (p >>= f).step :=
  ⟨fun _ _ _ _ => by
    simp_rw [bind_eq_done]; rintro ⟨_, _, hp, hf⟩
    exact static.of_done hf ▸ of_done hp⟩
#align parser.step.bind Parser.Step.bind

instance bind' {f : α → Parser β} [p.Static] [∀ a, (f a).step] : (p >>= f).step :=
  ⟨fun _ _ _ _ => by
    simp_rw [bind_eq_done]; rintro ⟨_, _, hp, hf⟩
    rw [static.of_done hp]; exact of_done hf⟩
#align parser.step.bind' Parser.Step.bind'

instance andThen {q : Parser β} [p.step] [q.Static] : (p >> q).step :=
  Step.bind
#align parser.step.and_then Parser.Step.andThen

instance and_then' {q : Parser β} [p.Static] [q.step] : (p >> q).step :=
  Step.bind'
#align parser.step.and_then' Parser.Step.and_then'

instance map [p.step] {f : α → β} : (f <$> p).step :=
  ⟨fun _ _ _ _ => by simp_rw [map_eq_done]; rintro ⟨_, hp, _⟩; exact of_done hp⟩
#align parser.step.map Parser.Step.map

instance seq {f : Parser (α → β)} [f.step] [p.Static] : (f <*> p).step :=
  Step.bind
#align parser.step.seq Parser.Step.seq

instance seq' {f : Parser (α → β)} [f.Static] [p.step] : (f <*> p).step :=
  Step.bind'
#align parser.step.seq' Parser.Step.seq'

instance mapM {f : α → Parser β} [(f a).step] : ([a].mapM f).step :=
  by
  convert step.bind
  · infer_instance
  · intro
    convert static.bind
    · exact static.pure
    · exact fun _ => static.pure
#align parser.step.mmap Parser.Step.mapM

instance mapM' {f : α → Parser β} [(f a).step] : ([a].mapM' f).step :=
  by
  convert step.and_then
  · infer_instance
  · exact static.pure
#align parser.step.mmap' Parser.Step.mapM'

instance failure : @Parser.Step α failure :=
  ⟨fun _ _ _ _ => by simp⟩
#align parser.step.failure Parser.Step.failure

theorem guard_true : ¬Step (guard True) :=
  pure _
#align parser.step.guard_true Parser.Step.guard_true

instance guard : Step (guard False) :=
  Step.failure
#align parser.step.guard Parser.Step.guard

instance orelse [p.step] [q.step] : (p <|> q).step :=
  ⟨fun _ _ _ _ => by simp_rw [orelse_eq_done]; rintro (h | ⟨h, -⟩) <;> exact of_done h⟩
#align parser.step.orelse Parser.Step.orelse

theorem decorateErrors_iff : (@Parser.decorateErrors α msgs p).step ↔ p.step :=
  by
  constructor
  · intro
    constructor
    intro cb n n' a h
    have : (@Parser.decorateErrors α msgs p) cb n = done n' a := by simpa using h
    exact of_done this
  · intro
    constructor
    intro _ _ _ _ h
    rw [decorate_errors_eq_done] at h 
    exact of_done h
#align parser.step.decorate_errors_iff Parser.Step.decorateErrors_iff

instance decorateErrors [p.step] : (@decorateErrors α msgs p).step :=
  ⟨fun _ _ _ _ => by rw [decorate_errors_eq_done]; exact of_done⟩
#align parser.step.decorate_errors Parser.Step.decorateErrors

theorem decorateError_iff : (@Parser.decorateError α msg p).step ↔ p.step :=
  decorateErrors_iff
#align parser.step.decorate_error_iff Parser.Step.decorateError_iff

instance decorateError [p.step] : (@decorateError α msg p).step :=
  Step.decorateErrors
#align parser.step.decorate_error Parser.Step.decorateError

instance anyChar : Step anyChar := by
  constructor
  intro cb n
  simp_rw [any_char_eq_done]
  rintro _ _ ⟨_, rfl, -⟩
  simp
#align parser.step.any_char Parser.Step.anyChar

instance sat {p : Char → Prop} [DecidablePred p] : Step (sat p) :=
  by
  constructor
  intro cb n
  simp_rw [sat_eq_done]
  rintro _ _ ⟨_, _, rfl, -⟩
  simp
#align parser.step.sat Parser.Step.sat

theorem eps : ¬Step eps :=
  Step.pure ()
#align parser.step.eps Parser.Step.eps

instance ch {c : Char} : Step (ch c) :=
  Step.decorateError
#align parser.step.ch Parser.Step.ch

theorem charBuf_iff {cb' : CharBuffer} : (charBuf cb').step ↔ cb'.size = 1 :=
  by
  have : char_buf cb' cb' 0 = done cb'.size () := by simp [char_buf_eq_done]
  constructor
  · intro
    simpa using of_done this
  · intro h
    constructor
    intro cb n n' _
    rw [char_buf_eq_done, h]
    rintro ⟨rfl, -⟩
    rfl
#align parser.step.char_buf_iff Parser.Step.charBuf_iff

instance oneOf {cs : List Char} : (oneOf cs).step :=
  Step.decorateErrors
#align parser.step.one_of Parser.Step.oneOf

instance oneOf' {cs : List Char} : (oneOf' cs).step :=
  Step.andThen
#align parser.step.one_of' Parser.Step.oneOf'

theorem str_iff {s : String} : (str s).step ↔ s.length = 1 := by
  simp [str_eq_char_buf, char_buf_iff, ← String.toList_inj, Buffer.ext_iff]
#align parser.step.str_iff Parser.Step.str_iff

theorem remaining : ¬remaining.step :=
  by
  apply not_step_of_static_done
  simp [remaining_eq_done]
#align parser.step.remaining Parser.Step.remaining

theorem eof : ¬eof.step := by
  apply not_step_of_static_done
  simp only [eof_eq_done, exists_eq_left', exists_const]
  use Buffer.nil, 0
  simp
#align parser.step.eof Parser.Step.eof

-- TODO: add foldr and foldl, many, etc, fix_core
theorem fixCore {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.step → (F p).step) :
    ∀ max_depth : ℕ, Step (fixCore F max_depth)
  | 0 => Step.failure
  | max_depth + 1 => hF _ (fix_core _)
#align parser.step.fix_core Parser.Step.fixCore

instance digit : digit.step :=
  Step.decorateError
#align parser.step.digit Parser.Step.digit

theorem fix {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.step → (F p).step) : Step (fix F) :=
  ⟨fun cb n _ _ h => by haveI := fix_core hF (cb.size - n + 1); dsimp [fix] at h ; exact of_done h⟩
#align parser.step.fix Parser.Step.fix

end Step

section Step

variable {α β : Type} {p q : Parser α} {msgs : Thunk (List String)} {msg : Thunk String}
  {cb : CharBuffer} {n' n : ℕ} {err : Std.DList String} {a : α} {b : β} {sep : Parser Unit}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem many1_eq_done_iff_many_eq_done [p.step] [p.Bounded] {x : α} {xs : List α} :
    many1 p cb n = done n' (x::xs) ↔ many p cb n = done n' (x::xs) :=
  by
  induction' hx : x::xs with hd tl IH generalizing x xs n n'
  · simpa using hx
  constructor
  · simp only [many1_eq_done, and_imp, exists_imp]
    intro np hp hm
    have : np = n + 1 := step.of_done hp
    have hn : n < cb.size := bounded.of_done hp
    subst this
    obtain ⟨k, hk⟩ : ∃ k, cb.size - n = k + 1 :=
      Nat.exists_eq_succ_of_ne_zero (ne_of_gt (tsub_pos_of_lt hn))
    cases k
    ·
      cases tl <;>
        simpa [many_eq_done_nil, Nat.sub_succ, hk, many_eq_done, hp, foldr_core_eq_done] using hm
    cases' tl with hd' tl'
    · simpa [many_eq_done_nil, Nat.sub_succ, hk, many_eq_done, hp, foldr_core_eq_done] using hm
    · rw [← @IH hd' tl'] at hm ; swap; rfl
      simp only [many1_eq_done, many, foldr] at hm 
      obtain ⟨np, hp', hf⟩ := hm
      obtain rfl : np = n + 1 + 1 := step.of_done hp'
      simpa [Nat.sub_succ, many_eq_done, hp, hk, foldr_core_eq_done, hp'] using hf
  · simp only [many_eq_done, many1_eq_done, and_imp, exists_imp]
    intro np hp hm
    have : np = n + 1 := step.of_done hp
    have hn : n < cb.size := bounded.of_done hp
    subst this
    obtain ⟨k, hk⟩ : ∃ k, cb.size - n = k + 1 :=
      Nat.exists_eq_succ_of_ne_zero (ne_of_gt (tsub_pos_of_lt hn))
    cases k
    ·
      cases tl <;>
        simpa [many_eq_done_nil, Nat.sub_succ, hk, many_eq_done, hp, foldr_core_eq_done] using hm
    cases' tl with hd' tl'
    · simpa [many_eq_done_nil, Nat.sub_succ, hk, many_eq_done, hp, foldr_core_eq_done] using hm
    · simp [hp]
      rw [← @IH hd' tl' (n + 1) n']; swap; rfl
      rw [hk, foldr_core_eq_done, or_comm] at hm 
      obtain hm | ⟨np, hd', tl', hp', hf, hm⟩ := hm
      · simpa using hm
      simp only at hm 
      obtain ⟨rfl, rfl⟩ := hm
      obtain rfl : np = n + 1 + 1 := step.of_done hp'
      simp [Nat.sub_succ, many, many1_eq_done, hp, hk, foldr_core_eq_done, hp', ← hf, foldr]
#align parser.many1_eq_done_iff_many_eq_done Parser.many1_eq_done_iff_many_eq_done

end Step

namespace Prog

variable {α β : Type} {p q : Parser α} {msgs : Thunk (List String)} {msg : Thunk String}
  {cb : CharBuffer} {n' n : ℕ} {err : Std.DList String} {a : α} {b : β} {sep : Parser Unit}

-- see Note [lower instance priority]
instance (priority := 100) of_step [Step p] : Prog p :=
  ⟨fun _ _ _ _ h => by rw [step.of_done h]; exact Nat.lt_succ_self _⟩
#align parser.prog.of_step Parser.Prog.of_step

theorem pure (a : α) : ¬Prog (pure a) := by
  intro h
  have : (pure a : Parser α) Buffer.nil 0 = done 0 a := by simp [pure_eq_done]
  replace this : 0 < 0 := prog.of_done this
  exact (lt_irrefl _) this
#align parser.prog.pure Parser.Prog.pure

instance bind {f : α → Parser β} [p.Prog] [∀ a, (f a).mono] : (p >>= f).Prog :=
  ⟨fun _ _ _ _ => by
    simp_rw [bind_eq_done]; rintro ⟨_, _, hp, hf⟩
    exact lt_of_lt_of_le (of_done hp) (mono.of_done hf)⟩
#align parser.prog.bind Parser.Prog.bind

instance andThen {q : Parser β} [p.Prog] [q.mono] : (p >> q).Prog :=
  Prog.bind
#align parser.prog.and_then Parser.Prog.andThen

instance map [p.Prog] {f : α → β} : (f <$> p).Prog :=
  ⟨fun _ _ _ _ => by simp_rw [map_eq_done]; rintro ⟨_, hp, _⟩; exact of_done hp⟩
#align parser.prog.map Parser.Prog.map

instance seq {f : Parser (α → β)} [f.Prog] [p.mono] : (f <*> p).Prog :=
  Prog.bind
#align parser.prog.seq Parser.Prog.seq

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM {l : List α} {f : α → Parser β} [(f a).Prog] [∀ a, (f a).mono] :
    ((a::l).mapM f).Prog := by
  constructor
  simp only [and_imp, bind_eq_done, return_eq_pure, mmap, exists_imp, pure_eq_done]
  rintro _ _ _ _ _ _ h _ _ hp rfl rfl
  exact lt_of_lt_of_le (of_done h) (mono.of_done hp)
#align parser.prog.mmap Parser.Prog.mapM

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
instance mapM' {l : List α} {f : α → Parser β} [(f a).Prog] [∀ a, (f a).mono] :
    ((a::l).mapM' f).Prog := by
  constructor
  simp only [and_imp, bind_eq_done, mmap', exists_imp, and_then_eq_bind]
  intro _ _ _ _ _ _ h hm
  exact lt_of_lt_of_le (of_done h) (mono.of_done hm)
#align parser.prog.mmap' Parser.Prog.mapM'

instance failure : @Parser.Prog α failure :=
  Prog.of_step
#align parser.prog.failure Parser.Prog.failure

theorem guard_true : ¬Prog (guard True) :=
  pure _
#align parser.prog.guard_true Parser.Prog.guard_true

instance guard : Prog (guard False) :=
  Prog.failure
#align parser.prog.guard Parser.Prog.guard

instance orelse [p.Prog] [q.Prog] : (p <|> q).Prog :=
  ⟨fun _ _ _ _ => by simp_rw [orelse_eq_done]; rintro (h | ⟨h, -⟩) <;> exact of_done h⟩
#align parser.prog.orelse Parser.Prog.orelse

theorem decorateErrors_iff : (@Parser.decorateErrors α msgs p).Prog ↔ p.Prog :=
  by
  constructor
  · intro
    constructor
    intro cb n n' a h
    have : (@Parser.decorateErrors α msgs p) cb n = done n' a := by simpa using h
    exact of_done this
  · intro
    constructor
    intro _ _ _ _ h
    rw [decorate_errors_eq_done] at h 
    exact of_done h
#align parser.prog.decorate_errors_iff Parser.Prog.decorateErrors_iff

instance decorateErrors [p.Prog] : (@decorateErrors α msgs p).Prog :=
  ⟨fun _ _ _ _ => by rw [decorate_errors_eq_done]; exact of_done⟩
#align parser.prog.decorate_errors Parser.Prog.decorateErrors

theorem decorateError_iff : (@Parser.decorateError α msg p).Prog ↔ p.Prog :=
  decorateErrors_iff
#align parser.prog.decorate_error_iff Parser.Prog.decorateError_iff

instance decorateError [p.Prog] : (@decorateError α msg p).Prog :=
  Prog.decorateErrors
#align parser.prog.decorate_error Parser.Prog.decorateError

instance anyChar : Prog anyChar :=
  Prog.of_step
#align parser.prog.any_char Parser.Prog.anyChar

instance sat {p : Char → Prop} [DecidablePred p] : Prog (sat p) :=
  Prog.of_step
#align parser.prog.sat Parser.Prog.sat

theorem eps : ¬Prog eps :=
  Prog.pure ()
#align parser.prog.eps Parser.Prog.eps

instance ch {c : Char} : Prog (ch c) :=
  Prog.of_step
#align parser.prog.ch Parser.Prog.ch

theorem charBuf_iff {cb' : CharBuffer} : (charBuf cb').Prog ↔ cb' ≠ Buffer.nil :=
  by
  have : cb' ≠ Buffer.nil ↔ cb'.to_list ≠ [] :=
    not_congr ⟨fun h => by simp [h], fun h => by simpa using congr_arg List.toBuffer h⟩
  rw [char_buf, this, decorate_error_iff]
  cases cb'.to_list
  · simp [pure]
  · simp only [iff_true_iff, Ne.def, not_false_iff]
    infer_instance
#align parser.prog.char_buf_iff Parser.Prog.charBuf_iff

instance oneOf {cs : List Char} : (oneOf cs).Prog :=
  Prog.decorateErrors
#align parser.prog.one_of Parser.Prog.oneOf

instance oneOf' {cs : List Char} : (oneOf' cs).Prog :=
  Prog.andThen
#align parser.prog.one_of' Parser.Prog.oneOf'

theorem str_iff {s : String} : (str s).Prog ↔ s ≠ "" := by
  simp [str_eq_char_buf, char_buf_iff, ← String.toList_inj, Buffer.ext_iff]
#align parser.prog.str_iff Parser.Prog.str_iff

theorem remaining : ¬remaining.Prog := by
  intro h
  have : remaining Buffer.nil 0 = done 0 0 := by simp [remaining_eq_done]
  replace this : 0 < 0 := prog.of_done this
  exact (lt_irrefl _) this
#align parser.prog.remaining Parser.Prog.remaining

theorem eof : ¬eof.Prog := by
  intro h
  have : eof Buffer.nil 0 = done 0 () := by simpa [remaining_eq_done]
  replace this : 0 < 0 := prog.of_done this
  exact (lt_irrefl _) this
#align parser.prog.eof Parser.Prog.eof

-- TODO: add foldr and foldl, many, etc, fix_core
instance many1 [p.mono] [p.Prog] : p.many1.Prog :=
  by
  constructor
  rintro cb n n' (_ | ⟨hd, tl⟩)
  · simp
  · rw [many1_eq_done]
    rintro ⟨np, hp, h⟩
    exact (of_done hp).trans_le (mono.of_done h)
#align parser.prog.many1 Parser.Prog.many1

theorem fixCore {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.Prog → (F p).Prog) :
    ∀ max_depth : ℕ, Prog (fixCore F max_depth)
  | 0 => Prog.failure
  | max_depth + 1 => hF _ (fix_core _)
#align parser.prog.fix_core Parser.Prog.fixCore

instance digit : digit.Prog :=
  Prog.of_step
#align parser.prog.digit Parser.Prog.digit

instance nat : nat.Prog :=
  Prog.decorateError
#align parser.prog.nat Parser.Prog.nat

theorem fix {F : Parser α → Parser α} (hF : ∀ p : Parser α, p.Prog → (F p).Prog) : Prog (fix F) :=
  ⟨fun cb n _ _ h => by haveI := fix_core hF (cb.size - n + 1); dsimp [fix] at h ; exact of_done h⟩
#align parser.prog.fix Parser.Prog.fix

end Prog

variable {α β : Type} {msgs : Thunk (List String)} {msg : Thunk String}

variable {p q : Parser α} {cb : CharBuffer} {n n' : ℕ} {err : Std.DList String}

variable {a : α} {b : β}

section Many

-- TODO: generalize to p.prog instead of p.step
theorem many_sublist_of_done [p.step] [p.Bounded] {l : List α} (h : p.anyM cb n = done n' l) :
    ∀ k < n' - n, p.anyM cb (n + k) = done n' (l.drop k) :=
  by
  induction' l with hd tl hl generalizing n
  · rw [many_eq_done_nil] at h 
    simp [h.left]
  intro m hm
  cases m
  · exact h
  rw [List.drop, Nat.add_succ, ← Nat.succ_add]
  apply hl
  · rw [← many1_eq_done_iff_many_eq_done, many1_eq_done] at h 
    obtain ⟨_, hp, h⟩ := h
    convert h
    exact (step.of_done hp).symm
  · exact nat.lt_pred_iff.mpr hm
#align parser.many_sublist_of_done Parser.many_sublist_of_done

theorem many_eq_nil_of_done [p.step] [p.Bounded] {l : List α} (h : p.anyM cb n = done n' l) :
    p.anyM cb n' = done n' [] :=
  by
  induction' l with hd tl hl generalizing n
  · convert h
    rw [many_eq_done_nil] at h 
    exact h.left.symm
  · rw [← many1_eq_done_iff_many_eq_done, many1_eq_done] at h 
    obtain ⟨_, -, h⟩ := h
    exact hl h
#align parser.many_eq_nil_of_done Parser.many_eq_nil_of_done

theorem many_eq_nil_of_out_of_bound [p.Bounded] {l : List α} (h : p.anyM cb n = done n' l)
    (hn : cb.size < n) : n' = n ∧ l = [] := by
  cases l
  · rw [many_eq_done_nil] at h 
    exact ⟨h.left.symm, rfl⟩
  · rw [many_eq_done] at h 
    obtain ⟨np, hp, -⟩ := h
    exact absurd (bounded.of_done hp) hn.not_lt
#align parser.many_eq_nil_of_out_of_bound Parser.many_eq_nil_of_out_of_bound

theorem many1_length_of_done [p.mono] [p.step] [p.Bounded] {l : List α}
    (h : many1 p cb n = done n' l) : l.length = n' - n :=
  by
  induction' l with hd tl hl generalizing n n'
  · simpa using h
  · obtain ⟨k, hk⟩ : ∃ k, n' = n + k + 1 := Nat.exists_eq_add_of_lt (prog.of_done h)
    subst hk
    simp only [many1_eq_done] at h 
    obtain ⟨_, hp, h⟩ := h
    obtain rfl := step.of_done hp
    cases tl
    · simp only [many_eq_done_nil, add_left_inj, exists_and_right, self_eq_add_right] at h 
      rcases h with ⟨rfl, -⟩
      simp
    rw [← many1_eq_done_iff_many_eq_done] at h 
    specialize hl h
    simp [hl, add_comm, add_assoc, Nat.sub_succ]
#align parser.many1_length_of_done Parser.many1_length_of_done

theorem many1_bounded_of_done [p.step] [p.Bounded] {l : List α} (h : many1 p cb n = done n' l) :
    n' ≤ cb.size := by
  induction' l with hd tl hl generalizing n n'
  · simpa using h
  · simp only [many1_eq_done] at h 
    obtain ⟨np, hp, h⟩ := h
    obtain rfl := step.of_done hp
    cases tl
    · simp only [many_eq_done_nil, exists_and_right] at h 
      simpa [← h.left] using bounded.of_done hp
    · rw [← many1_eq_done_iff_many_eq_done] at h 
      exact hl h
#align parser.many1_bounded_of_done Parser.many1_bounded_of_done

end Many

section Nat

/-- The `val : ℕ` produced by a successful parse of a `cb : char_buffer` is the numerical value
represented by the string of decimal digits (possibly padded with 0s on the left)
starting from the parsing position `n` and ending at position `n'`. The number
of characters parsed in is necessarily `n' - n`.

This is one of the directions of `nat_eq_done`.
-/
theorem nat_of_done {val : ℕ} (h : nat cb n = done n' val) :
    val =
      Nat.ofDigits 10
        (((cb.toList.drop n).take (n' - n)).reverse.map fun c => c.toNat - '0'.toNat) :=
  by
  /- The parser `parser.nat` that generates a decimal number from a string of digit characters does
    several things. First it ingests in as many digits as it can with `many1 digit`. Then, it folds
    over the resulting `list ℕ` using a helper function that keeps track of both the running sum an
    and the magnitude so far, using a `(sum, magnitude) : (ℕ × ℕ)` pair. The final sum is extracted
    using a `prod.fst`.
  
    To prove that the value that `parser.nat` produces, after moving precisely `n' - n` steps, is
    precisely what `nat.of_digits` would give, if supplied the string that is in the ingested
    `char_buffer` (modulo conversion from `char` to `ℕ ), we need to induct over the length `n' - n`
    of `cb : char_buffer` ingested, and prove that the parser must have terminated due to hitting
    either the end of the `char_buffer` or a non-digit character.
  
    The statement of the lemma is phrased using a combination of `list.drop` and `list.map` because
    there is no currently better way to extract an "interval" from a `char_buffer`. Additionally, the
    statement uses a `list.reverse` because `nat.of_digits` is little-endian.
  
    We try to stop referring to the `cb : char_buffer` as soon as possible, so that we can instead
    regard a `list char` instead, which lends itself better to proofs via induction.
    -/
  /- We first prove some helper lemmas about the definition of `parser.nat`. Since it is defined
    in core, we have to work with how it is defined instead of changing its definition.
    In its definition, the function that folds over the parsed in digits is defined internally,
    as a lambda with anonymous destructor syntax, which leads to an unpleasant `nat._match_1` term
    when rewriting the definition of `parser.nat` away. Since we know exactly what the function is,
    we have a `rfl`-like lemma here to rewrite it back into a readable form.
    -/
  have natm : nat._match_1 = fun (d : ℕ) p => ⟨p.1 + d * p.2, p.2 * 10⟩ := by ext1; ext1 ⟨⟩; rfl
  -- We also have to prove what is the `prod.snd` of the result of the fold of a `list (ℕ × ℕ)` with
  -- the function above. We use this lemma later when we finish our inductive case.
  have hpow :
    ∀ l,
      (List.foldr (fun (digit : ℕ) (x : ℕ × ℕ) => (x.fst + digit * x.snd, x.snd * 10)) (0, 1)
            l).snd =
        10 ^ l.length :=
    by
    intro l
    induction' l with hd tl hl
    · simp
    · simp [hl, pow_succ, mul_comm]
  -- We convert the hypothesis that `parser.nat` has succeeded into an existential that there is
  -- some list of digits that it has parsed in, and that those digits, when folded over by the
  -- function above, give the value at hand.
  simp only [Nat, pure_eq_done, natm, decorate_error_eq_done, bind_eq_done] at h 
  obtain ⟨n', l, hp, rfl, rfl⟩ := h
  -- We now want to stop working with the `cb : char_buffer` and parse positions `n` and `n'`,
  -- and just deal with the parsed digit list `l : list ℕ`. To do so, we have to show that
  -- this is precisely the list that could have been parsed in, no smaller and no greater.
  induction' l with lhd ltl IH generalizing n n' cb
  ·-- Base case: we parsed in no digits whatsoever. But this is impossible because `parser.many1`
    -- must produce a list that is not `list.nil`, by `many1_ne_done_nil`.
    simpa using hp
  -- Inductive case:
  -- We must prove that the first digit parsed in `lhd : ℕ` is precisely the digit that is
  -- represented by the character at position `n` in `cb : char_buffer`.
  -- We will also prove the correspondence between the subsequent digits `ltl : list ℕ` and the
  -- remaining characters past position `n` up to position `n'`.
  cases' hx : List.drop n (Buffer.toList cb) with chd ctl
  · -- Are there even characters left to parse, at position `n` in the `cb : char_buffer`? In other
    -- words, are we already out of bounds, and thus could not have parsed in any value
    -- successfully. But this must be a contradiction because `parser.digit` is a `bounded` parser,
    -- (due to its being defined via `parser.decorate_error`), which means it only succeeds
    -- in-bounds, and the `many1` parser combinator retains that property.
    have : cb.size ≤ n := by simpa using list.drop_eq_nil_iff_le.mp hx
    exact absurd (bounded.of_done hp) this.not_lt
  -- We prove that the first digit parsed in is precisely the digit that is represented by the
  -- character at position `n`, which we now call `chd : char`.
  have chdh : chd.to_nat - '0'.toNat = lhd :=
    by
    simp only [many1_eq_done] at hp 
    -- We know that `parser.digit` succeeded, so it has moved to a possibly different position.
    -- In fact, we know that this new position is `n + 1`, by the `step` property of
    -- `parser.digit`.
    obtain ⟨_, hp, -⟩ := hp
    obtain rfl := step.of_done hp
    -- We now unfold what it means for `parser.digit` to succeed, which means that the character
    -- parsed in was "numeric" (for some definition of that property), and, more importantly,
    -- that the `n`th character of `cb`, let's say `c`, when converted to a `ℕ` via
    -- `char.to_nat c - '0'.to_nat`, must be equal to the resulting value, `lhd` in our case.
    simp only [digit_eq_done, Buffer.read_eq_nthLe_toList, hx, Buffer.length_toList, true_and_iff,
      add_left_inj, List.length, List.nthLe, eq_self_iff_true, exists_and_left, Fin.val_mk] at hp 
    rcases hp with ⟨_, hn, rfl, _, _⟩
    -- But we already know the list corresponding to `cb : char_buffer` from position `n` and on
    -- is equal to `(chd :: ctl) : list char`, so our `c` above must satisfy `c = chd`.
    have hn' : n < cb.to_list.length := by simpa using hn
    rw [← List.cons_nthLe_drop_succ hn'] at hx 
    -- We can ignore proving any correspondence of `ctl : list char` to the other portions of the
    -- `cb : char_buffer`.
    simp only at hx 
    simp [hx]
  -- We know that we parsed in more than one character because of the `prog` property of
  -- `parser.digit`, which the `many1` parser combinator retains. In other words, we know that
  -- `n < n'`, and so, the list of digits `ltl` must correspond to the list of digits that
  -- `digit.many1 cb (n + 1)` would produce. We know that the shift of `1` in `n ↦ n + 1` holds
  -- due to the `step` property of `parser.digit`.
  -- We also get here `k : ℕ` which will indicate how many characters we parsed in past position
  -- `n`. We will prove later that this must be the number of digits we produced as well in `ltl`.
  obtain ⟨k, hk⟩ : ∃ k, n' = n + k + 1 := Nat.exists_eq_add_of_lt (prog.of_done hp)
  have hdm : ltl = [] ∨ digit.many1 cb (n + 1) = done n' ltl :=
    by
    cases ltl
    · simp
    · rw [many1_eq_done] at hp 
      obtain ⟨_, hp, hp'⟩ := hp
      simpa [step.of_done hp, many1_eq_done_iff_many_eq_done] using hp'
  -- Now we case on the two possibilities, that there was only a single digit parsed in, and
  -- `ltl = []`, or, had we started parsing at `n + 1` instead, we'd parse in the value associated
  -- with `ltl`.
  -- We prove that the LHS, which is a fold over a `list ℕ` is equal to the RHS, which is that
  -- the `val : ℕ` that `nat.of_digits` produces when supplied a `list ℕ that has been produced
  -- via mapping a `list char` using `char.to_nat`. Specifically, that `list char` are the
  -- characters in the `cb : char_buffer`, from position `n` to position `n'` (excluding `n'`),
  -- in reverse.
  rcases hdm with (rfl | hdm)
  · -- Case that `ltl = []`.
    simp only [many1_eq_done, many_eq_done_nil, exists_and_right] at hp 
    -- This means we must have failed parsing with `parser.digit` at some other position,
    -- which we prove must be `n + 1` via the `step` property.
    obtain ⟨_, hp, rfl, hp'⟩ := hp
    obtain rfl := step.of_done hp
    -- Now we rely on the simplifier, which simplfies the LHS, which is a fold over a singleton
    -- list. On the RHS, `list.take (n + 1 - n)` also produces a singleton list, which, when
    -- reversed, is the same list. `nat.of_digits` of a singleton list is precisely the value in
    -- the list. And we already have that `chd.to_nat - '0'.to_nat = lhd`.
    simp [chdh]
  -- We now have to deal with the case where we parsed in more than one digit, and thus
  -- `n + 1 < n'`, which means `ctl` has one or more elements. Similarly, `ltl` has one or more
  -- elements.
  -- We finish ridding ourselves of references to `cb : char_buffer`, by relying on the fact that
  -- our `ctl : list char` must be the appropriate portion of `cb` once enough elements have been
  -- dropped and taken.
  have rearr :
    List.take (n + (k + 1) - (n + 1)) (List.drop (n + 1) (Buffer.toList cb)) = ctl.take k := by
    simp [← List.tail_drop, hx, Nat.sub_succ, hk]
  -- We have to prove that the number of digits produced (given by `ltl`) is equal to the number
  -- of characters parsed in, as given by `ctl.take k`, and that this is precisely `k`. We phrase it
  -- in the statement using `min`, because lemmas about `list.length (list.take ...)` simplify to
  -- a statement that uses `min`. The `list.length` term appears from the reduction of the folding
  -- function, as proven above.
  have ltll : min k ctl.length = ltl.length :=
    by
    -- Here is an example of how statements about the `list.length` of `list.take` simplify.
    have : (ctl.take k).length = min k ctl.length := by simp
    -- We bring back the underlying definition of `ctl` as the result of a sequence of `list.take`
    -- and `list.drop`, so that lemmas about `list.length` of those can fire.
    rw [← this, ← rearr, many1_length_of_done hdm]
    -- Likewise, we rid ourselves of the `k` we generated earlier.
    have : k = n' - n - 1 := by simp [hk, add_assoc]
    subst this
    simp only [Nat.sub_succ, add_comm, ← Nat.pred_sub, Buffer.length_toList, Nat.pred_one_add,
      min_eq_left_iff, List.length_drop, add_tsub_cancel_left, List.length_take, tsub_zero]
    -- We now have a goal of proving an inequality dealing with `nat` subtraction and `nat.pred`,
    -- both of which require special care to provide positivity hypotheses.
    rw [tsub_le_tsub_iff_right, Nat.pred_le_iff]
    · -- We know that `n' ≤ cb.size` because of the `bounded` property, that a parser will not
      -- produce a `done` result at a position farther than the size of the underlying
      -- `char_buffer`.
      convert many1_bounded_of_done hp
      -- What is now left to prove is that `0 < cb.size`, which can be rephrased
      -- as proving that it is nonempty.
      cases hc : cb.size
      · -- Proof by contradiction. Let's say that `cb.size = 0`. But we know that we succeeded
        -- parsing in at position `n` using a `bounded` parser, so we must have that
        -- `n < cb.size`.
        have := bounded.of_done hp
        rw [hc] at this 
        -- But then `n < 0`, a contradiction.
        exact absurd n.zero_le this.not_le
      · simp
    ·-- Here, we use the same result as above, that `n < cb.size`, and relate it to
      -- `n ≤ cb.size.pred`.
      exact Nat.le_pred_of_lt (bounded.of_done hp)
  -- Finally, we simplify. On the LHS, we have a fold over `lhd :: ltl`, which simplifies to
  -- the operation of the summing folding function on `lhd` and the fold over `ltl`. To that we can
  -- apply the induction hypothesis, because we know that our parser would have succeeded had we
  -- started at position `n + 1`. We replace mentions of `cb : char_buffer` with the appropriate
  -- `chd :: ctl`, replace `lhd` with the appropriate statement of how it is calculated from `chd`,
  -- and use the lemmas describing the length of `ltl` and how it is associated with `k`. We also
  -- remove mentions of `n'` and replace with an expression using solely `n + k + 1`.
  -- We use the lemma we proved above about how the folding function produces the
  -- `prod.snd` value, which is `10` to the power of the length of the list provided to the fold.
  -- Finally, we rely on `nat.of_digits_append` for the related statement of how digits given
  -- are used in the `nat.of_digits` calculation, which also involves `10 ^ list.length ...`.
  -- The `list.append` operation appears due to the `list.reverse (chd :: ctl)`.
  -- We include some addition and multiplication lemmas to help the simplifier rearrange terms.
  simp [IH _ hdm, hx, hk, rearr, ← chdh, ← ltll, hpow, add_assoc, Nat.ofDigits_append, mul_comm]
#align parser.nat_of_done Parser.nat_of_done

/--
If we know that `parser.nat` was successful, starting at position `n` and ending at position `n'`,
then it must be the case that for all `k : ℕ`, `n ≤ k`, `k < n'`, the character at the `k`th
position in `cb : char_buffer` is "numeric", that is, is between `'0'` and `'9'` inclusive.

This is a necessary part of proving one of the directions of `nat_eq_done`.
-/
theorem nat_of_done_as_digit {val : ℕ} (h : nat cb n = done n' val) :
    ∀ (hn : n' ≤ cb.size) (k) (hk : k < n'),
      n ≤ k → '0' ≤ cb.read ⟨k, hk.trans_le hn⟩ ∧ cb.read ⟨k, hk.trans_le hn⟩ ≤ '9' :=
  by
  -- The properties to be shown for the characters involved rely solely on the success of
  -- `parser.digit` at the relevant positions, and not on the actual value `parser.nat` produced.
  -- We break done the success of `parser.nat` into the `parser.digit` success and throw away
  -- the resulting value given by `parser.nat`, and focus solely on the `list ℕ` generated by
  -- `parser.digit.many1`.
  simp only [Nat, pure_eq_done, and_left_comm, decorate_error_eq_done, bind_eq_done, exists_eq_left,
    exists_and_left] at h 
  obtain ⟨xs, h, -⟩ := h
  -- We want to avoid having to make statements about the `cb : char_buffer` itself. Instead, we
  -- induct on the `xs : list ℕ` that `parser.digit.many1` produced.
  induction' xs with hd tl hl generalizing n n'
  ·-- Base case: `xs` is empty. But this is a contradiction because `many1` always produces a
    -- nonempty list, as proven by `many1_ne_done_nil`.
    simpa using h
  -- Inductive case: we prove that the `parser.digit.many1` produced a valid `(hd :: tl) : list ℕ`,
  -- by showing that is the case for the character at position `n`, which gave `hd`, and use the
  -- induction hypothesis on the remaining `tl`.
  -- We break apart a `many1` success into a success of the underlying `parser.digit` to give `hd`
  -- and a `parser.digit.many` which gives `tl`. We first deal with the `hd`.
  rw [many1_eq_done] at h 
  -- Right away, we can throw away the information about the "new" position that `parser.digit`
  -- ended on because we will soon prove that it must have been `n + 1`.
  obtain ⟨_, hp, h⟩ := h
  -- The main lemma here is `digit_eq_done`, which already proves the necessary conditions about
  -- the character at hand. What is left to do is properly unpack the information.
  simp only [digit_eq_done, and_comm, and_left_comm, digit_eq_fail, true_and_iff, exists_eq_left,
    eq_self_iff_true, exists_and_left, exists_and_left] at hp 
  obtain ⟨rfl, -, hn, ge0, le9, rfl⟩ := hp
  -- Let's now consider a position `k` between `n` and `n'`, excluding `n'`.
  intro hn k hk hk'
  -- What if we are at `n`? What if we are past `n`? We case on the `n ≤ k`.
  rcases hk'.eq_or_lt with (rfl | hk')
  ·-- The `n = k` case. But this is exactly what we know already, so we provide the
    -- relevant hypotheses.
    exact ⟨ge0, le9⟩
  -- The `n < k` case. First, we check if there would have even been digits parsed in. So, we
  -- case on `tl : list ℕ`
  cases tl
  · -- Case where `tl = []`. But that means `many` gave us a `[]` so either the character at
    -- position `k` was not "numeric" or we are out of bounds. More importantly, when `many`
    -- successfully produces a `[]`, it does not progress the parser head, so we have that
    -- `n + 1 = n'`. This will lead to a contradiction because now we have `n < k` and `k < n + 1`.
    simp only [many_eq_done_nil, exists_and_right] at h 
    -- Extract out just the `n + 1 = n'`.
    obtain ⟨rfl, -⟩ := h
    -- Form the contradictory hypothesis, and discharge the goal.
    have : k < k := hk.trans_le (Nat.succ_le_of_lt hk')
    exact absurd this (lt_irrefl _)
  · -- Case where `tl ≠ []`. But that means that `many` produced a nonempty list as a result, so
    -- `many1` would have successfully parsed at this position too. We use this statement to
    -- rewrite our hypothesis into something that works with the induction hypothesis, and apply it.
    rw [← many1_eq_done_iff_many_eq_done] at h 
    apply hl h
    -- All that is left to prove is that our `k` is at least our new "lower bound" `n + 1`, which
    -- we have from our original split of the `n ≤ k`, since we are now on the `n < k` case.
    exact Nat.succ_le_of_lt hk'
#align parser.nat_of_done_as_digit Parser.nat_of_done_as_digit

/--
If we know that `parser.nat` was successful, starting at position `n` and ending at position `n'`,
then it must be the case that for the ending position `n'`, either it is beyond the end of the
`cb : char_buffer`, or the character at that position is not "numeric", that is,  between `'0'` and
`'9'` inclusive.

This is a necessary part of proving one of the directions of `nat_eq_done`.
-/
theorem nat_of_done_bounded {val : ℕ} (h : nat cb n = done n' val) :
    ∀ hn : n' < cb.size, '0' ≤ cb.read ⟨n', hn⟩ → '9' < cb.read ⟨n', hn⟩ :=
  by
  -- The properties to be shown for the characters involved rely solely on the success of
  -- `parser.digit` at the relevant positions, and not on the actual value `parser.nat` produced.
  -- We break done the success of `parser.nat` into the `parser.digit` success and throw away
  -- the resulting value given by `parser.nat`, and focus solely on the `list ℕ` generated by
  -- `parser.digit.many1`.
  -- We deal with the case of `n'` is "out-of-bounds" right away by requiring that
  -- `∀ (hn : n' < cb.size)`. Thus we only have to prove the lemma for the cases where `n'` is still
  -- "in-bounds".
  simp only [Nat, pure_eq_done, and_left_comm, decorate_error_eq_done, bind_eq_done, exists_eq_left,
    exists_and_left] at h 
  obtain ⟨xs, h, -⟩ := h
  -- We want to avoid having to make statements about the `cb : char_buffer` itself. Instead, we
  -- induct on the `xs : list ℕ` that `parser.digit.many1` produced.
  induction' xs with hd tl hl generalizing n n'
  ·-- Base case: `xs` is empty. But this is a contradiction because `many1` always produces a
    -- nonempty list, as proven by `many1_ne_done_nil`.
    simpa using h
  -- Inductive case: at least one character has been parsed in, starting at position `n`.
  -- We know that the size of `cb : char_buffer` must be at least `n + 1` because
  -- `parser.digit.many1` is `bounded` (`n < cb.size`).
  -- We show that either we parsed in just that one character, or we use the inductive hypothesis.
  obtain ⟨k, hk⟩ : ∃ k, cb.size = n + k + 1 := Nat.exists_eq_add_of_lt (bounded.of_done h)
  cases tl
  · -- Case where `tl = []`, so we parsed in only `hd`. That must mean that `parser.digit` failed
    -- at `n + 1`.
    simp only [many1_eq_done, many_eq_done_nil, and_left_comm, exists_and_right, exists_eq_left] at
      h 
    -- We throw away the success information of what happened at position `n`, and we do not need
    -- the "error" value that the failure produced.
    obtain ⟨-, _, h⟩ := h
    -- If `parser.digit` failed at `n + 1`, then either we hit a non-numeric character, or
    -- we are out of bounds. `digit_eq_fail` provides us with those two cases.
    simp only [digit_eq_done, and_comm, and_left_comm, digit_eq_fail, true_and_iff, exists_eq_left,
      eq_self_iff_true, exists_and_left] at h 
    obtain ⟨rfl, h⟩ | ⟨h, -⟩ := h
    · -- First case: we are still in bounds, but the character is not numeric. We must prove
      -- that we are still in bounds. But we know that from our initial requirement.
      intro hn
      simpa using h hn
    ·-- Second case: we are out of bounds, and somehow the fold that `many1` relied on failed.
      -- But we know that `parser.digit` is mono, that is, it never goes backward in position,
      -- in neither success nor in failure. We also have that `foldr_core` respects `mono`.
      -- But in this case, `foldr_core` is starting at position `n' + 1` but failing at
      -- position `n'`, which is a contradiction, because otherwise we would have `n' + 1 ≤ n'`.
      simpa using mono.of_fail h
  · -- Case where `tl ≠ []`. But that means that `many` produced a nonempty list as a result, so
    -- `many1` would have successfully parsed at this position too. We use this statement to
    -- rewrite our hypothesis into something that works with the induction hypothesis, and apply it.
    rw [many1_eq_done] at h 
    obtain ⟨_, -, h⟩ := h
    rw [← many1_eq_done_iff_many_eq_done] at h 
    exact hl h
#align parser.nat_of_done_bounded Parser.nat_of_done_bounded

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:567:6: unsupported: specialize @hyp -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The `val : ℕ` produced by a successful parse of a `cb : char_buffer` is the numerical value
represented by the string of decimal digits (possibly padded with 0s on the left)
starting from the parsing position `n` and ending at position `n'`, where `n < n'`. The number
of characters parsed in is necessarily `n' - n`. Additionally, all of the characters in the `cb`
starting at position `n` (inclusive) up to position `n'` (exclusive) are "numeric", in that they
are between `'0'` and `'9'` inclusive. Such a `char_buffer` would produce the `ℕ` value encoded
by its decimal characters.
-/
theorem nat_eq_done {val : ℕ} :
    nat cb n = done n' val ↔
      ∃ hn : n < n',
        val =
            Nat.ofDigits 10
              (((cb.toList.drop n).take (n' - n)).reverse.map fun c => c.toNat - '0'.toNat) ∧
          (∀ hn' : n' < cb.size, '0' ≤ cb.read ⟨n', hn'⟩ → '9' < cb.read ⟨n', hn'⟩) ∧
            ∃ hn'' : n' ≤ cb.size,
              ∀ (k) (hk : k < n'),
                n ≤ k → '0' ≤ cb.read ⟨k, hk.trans_le hn''⟩ ∧ cb.read ⟨k, hk.trans_le hn''⟩ ≤ '9' :=
  by
  -- To prove this iff, we have most of the way in the forward direction, using the lemmas proven
  -- above. First, we must use that `parser.nat` is `prog`, which means that on success, it must
  -- move forward. We also have to prove the statement that a success means the parsed in
  -- characters were properly "numeric". It involves first generating ane existential witness
  -- that the parse was completely "in-bounds".
  -- For the reverse direction, we first discharge the goals that deal with proving that our parser
  -- succeeded because it encountered characters with the proper "numeric" properties, was
  -- "in-bounds" and hit a nonnumeric character. The more difficult portion is proving that the
  -- list of characters from positions `n` to `n'`, when folded over by the function defined inside
  -- `parser.nat` gives exactly the same value as `nat.of_digits` when supplied with the same
  -- (modulo rearrangement) list. To reach this goal, we try to remove any reliance on the
  -- underlying `cb : char_buffer` or parsers as soon as possible, via a cased-induction.
  refine' ⟨fun h => ⟨prog.of_done h, nat_of_done h, nat_of_done_bounded h, _⟩, _⟩
  · -- To provide the existential witness that `n'` is within the bounds of the `cb : char_buffer`,
    -- we rely on the fact that `parser.nat` is primarily a `parser.digit.many1`, and that `many1`,
    -- must finish with the bounds of the `cb`, as long as the underlying parser is `step` and
    -- `bounded`, which `digit` is. We do not prove this as a separate lemma about `parser.nat`
    -- because it would almost always be only relevant in this larger theorem.
    -- We clone the success hypothesis `h` so that we can supply it back later.
    have H := h
    -- We unwrap the `parser.nat` success down to the `many1` success, throwing away other info.
    rw [Nat] at h 
    simp only [decorate_error_eq_done, bind_eq_done, pure_eq_done, and_left_comm, exists_eq_left,
      exists_and_left] at h 
    obtain ⟨_, h, -⟩ := h
    -- Now we get our existential witness that `n' ≤ cb.size`.
    replace h := many1_bounded_of_done h
    -- With that, we can use the lemma proved above that our characters are "numeric"
    exact ⟨h, nat_of_done_as_digit H h⟩
  -- We now prove that given the `cb : char_buffer` with characters within the `n ≤ k < n'` interval
  -- properly "numeric" and such that their `nat.of_digits` generates the `val : ℕ`, `parser.nat`
  -- of that `cb`, when starting at `n`, will finish at `n'` and produce the same `val`.
  -- We first introduce the relevant hypotheses, including the fact that we have a valid interval
  -- where `n < n'` and that characters at `n'` and beyond are no longer numeric.
  rintro ⟨hn, hv, hb, hn', ho⟩
  -- We first unwrap the `parser.nat` definition to the underlying `parser.digit.many1` success
  -- and the fold function of the digits.
  rw [Nat]
  simp only [and_left_comm, pure_eq_done, hv, decorate_error_eq_done, List.map_reverse,
    bind_eq_done, exists_eq_left, exists_and_left]
  -- We won't actually need the `val : ℕ` itself, since it is entirely characterized by the
  -- underlying characters. Instead, we will induct over the `list char` of characters from
  -- position `n` onwards, showing that if we could have provided a list at `n`, we could have
  -- provided a valid list of characters at `n + 1` too.
  clear hv val
  /- We first prove some helper lemmas about the definition of `parser.nat`. Since it is defined
    in core, we have to work with how it is defined instead of changing its definition.
    In its definition, the function that folds over the parsed in digits is defined internally,
    as a lambda with anonymous destructor syntax, which leads to an unpleasant `nat._match_1` term
    when rewriting the definition of `parser.nat` away. Since we know exactly what the function is,
    we have a `rfl`-like lemma here to rewrite it back into a readable form.
    -/
  have natm : nat._match_1 = fun (d : ℕ) p => ⟨p.1 + d * p.2, p.2 * 10⟩ := by ext1; ext1 ⟨⟩; rfl
  -- We induct over the characters available at position `n` and onwards. Because `cb` is used
  -- in other expressions, we utilize the `induction H : ...` tactic to induct separately from
  -- destructing `cb` itself.
  induction' H : cb.to_list.drop n with hd tl IH generalizing n
  · -- Base case: there are no characters at position `n` or onwards, which means that
    -- `cb.size ≤ n`. But this is a contradiction, since we have `n < n' ≤ cb.size`.
    rw [List.drop_eq_nil_iff_le] at H 
    refine' absurd ((lt_of_le_of_lt H hn).trans_le hn') _
    simp
  · -- Inductive case: we prove that if we could have parsed from `n + 1`, we could have also parsed
    -- from `n`, if there was a valid numerical character at `n`. Most of the body
    -- of this inductive case is generating the appropriate conditions for use of the inductive
    -- hypothesis.
    specialize IH (n + 1)
    -- We have, by the inductive case, that there is at least one character `hd` at position `n`,
    -- with the rest at `tl`. We rearrange our inductive case to make `tl` be expressed as
    -- list.drop (n + 1), which fits out induction hypothesis conditions better. To use the
    -- rearranging lemma, we must prove that we are "dropping" in bounds, which we supply on-the-fly
    simp only [←
      List.cons_nthLe_drop_succ (show n < cb.to_list.length by simpa using hn.trans_le hn')] at H 
    -- We prove that parsing our `n`th character, `hd`, would have resulted in a success from
    -- `parser.digit`, with the appropriate `ℕ` success value. We use this later to simplify the
    -- unwrapped fold, since `hd` is our head character.
    have hdigit : digit cb n = done (n + 1) (hd.to_nat - '0'.toNat) :=
      by
      -- By our necessary condition, we know that `n` is in bounds, and that the `n`th character
      -- has the necessary "numeric" properties.
      specialize ho n hn le_rfl
      -- We prove an additional result that the conversion of `hd : char` to a `ℕ` would give a
      -- value `x ≤ 9`, since that is part of the iff statement in the `digit_eq_done` lemma.
      have : (Buffer.read cb ⟨n, hn.trans_le hn'⟩).toNat - '0'.toNat ≤ 9 :=
        by
        -- We rewrite the statement to be a statement about characters instead, and split the
        -- inequality into the case that our hypotheses prove, and that `'0' ≤ '9'`, which
        -- is true by computation, handled by `dec_trivial`.
        rw [show 9 = '9'.toNat - '0'.toNat by decide, tsub_le_tsub_iff_right]
        · exact ho.right
        · decide
      -- We rely on the simplifier, mostly powered by `digit_eq_done`, and supply all the
      -- necessary conditions of bounds and identities about `hd`.
      simp [digit_eq_done, this, ← H.left, Buffer.nthLe_toList, hn.trans_le hn', ho]
    -- We now case on whether we've moved to the end of our parse or not. We phrase this as
    -- casing on either `n + 1 < n` or `n ≤ n + 1`. The more difficult goal comes first.
    cases' lt_or_ge (n + 1) n' with hn'' hn''
    · -- Case `n + 1 < n'`. We can directly supply this to our induction hypothesis.
      -- We now have to prove, for the induction hypothesis, that the characters at positions `k`,
      -- `n + 1 ≤ k < n'` are "numeric". We already had this for `n ≤ k < n`, so we just rearrange
      -- the hypotheses we already have.
      specialize IH hn'' _ H.right
      · intro k hk hk'
        apply ho
        exact Nat.le_of_succ_le hk'
      -- With the induction hypothesis conditions satisfier, we can extract out a list that
      -- `parser.digit.many1` would have generated from position `n + 1`, as well as the associated
      -- property of the list, that it folds into what `nat.of_digits` generates from the
      -- characters in `cb : char_buffer`, now known as `hd :: tl`.
      obtain ⟨l, hdl, hvl⟩ := IH
      -- Of course, the parsed in list from position `n` would be `l` prepended with the result
      -- of parsing in `hd`, which is provided explicitly.
      use (hd.to_nat - '0'.toNat)::l
      -- We case on `l : list ℕ` so that we can make statements about the fold on `l`
      cases' l with lhd ltl
      ·-- As before, if `l = []` then `many1` produced a `[]` success, which is a contradiction.
        simpa using hdl
      -- Case `l = lhd :: ltl`. We can rewrite the fold of the function inside `parser.nat` on
      -- `lhd :: ltl`, which will be used to rewrite in the goal.
      simp only [natm, List.foldr] at hvl 
      -- We also expand the fold in the goal, using the expanded fold from our hypothesis, powered
      -- by `many1_eq_done` to proceed in the parsing. We know exactly what the next `many` will
      -- produce from `many1_eq_done_iff_many_eq_done.mp` of our `hdl` hypothesis. Finally,
      -- we also use `hdigit` to express what the single `parser.digit` result would be at `n`.
      simp only [natm, hvl, many1_eq_done, hdigit, many1_eq_done_iff_many_eq_done.mp hdl,
        true_and_iff, and_true_iff, eq_self_iff_true, List.foldr, exists_eq_left']
      -- Now our goal is solely about the equality of two different folding functions, one from the
      -- function defined inside `parser.nat` and the other as `nat.of_digits`, when applied to
      -- similar list inputs.
      -- First, we rid ourselves of `n'` by replacing with `n + m + 1`, which allows us to
      -- simplify the term of how many elements we are keeping using a `list.take`.
      obtain ⟨m, rfl⟩ : ∃ m, n' = n + m + 1 := Nat.exists_eq_add_of_lt hn
      -- The following rearrangement lemma is to simplify the `list.take (n' - n)` expression we had
      have : n + m + 1 - n = m + 1 :=
        by
        rw [add_assoc, tsub_eq_iff_eq_add_of_le, add_comm]
        exact Nat.le_add_right _ _
      -- We also have to prove what is the `prod.snd` of the result of the fold of a `list (ℕ × ℕ)`
      -- with the function above. We use this lemma to finish our inductive case.
      have hpow :
        ∀ l,
          (List.foldr (fun (digit : ℕ) (x : ℕ × ℕ) => (x.fst + digit * x.snd, x.snd * 10)) (0, 1)
                l).snd =
            10 ^ l.length :=
        by
        intro l
        induction' l with hd tl hl
        · simp
        · simp [hl, pow_succ, mul_comm]
      -- We prove that the parsed list of digits `(lhd :: ltl) : list ℕ` must be of length `m`
      -- which is used later when the `parser.nat` fold places `ltl.length` in the exponent.
      have hml : ltl.length + 1 = m := by simpa using many1_length_of_done hdl
      -- A simplified `list.length (list.take ...)` expression refers to the minimum of the
      -- underlying length and the amount of elements taken. We know that `m ≤ tl.length`, so
      -- we provide this auxiliary lemma so that the simplified "take-length" can simplify further
      have ltll : min m tl.length = m :=
        by-- On the way to proving this, we have to actually show that `m ≤ tl.length`, by showing
        -- that since `tl` was a subsequence in `cb`, and was retrieved from `n + 1` to `n + m + 1`,
        -- then since `n + m + 1 ≤ cb.size`, we have that `tl` must be at least `m` in length.
        simpa [← H.right, le_tsub_iff_right (hn''.trans_le hn').le, add_comm, add_assoc,
          add_left_comm] using hn'
      -- Finally, we rely on the simplifier. We already expressions of `nat.of_digits` on both
      -- the LHS and RHS. All that is left to do is to prove that the summand on the LHS is produced
      -- by the fold of `nat.of_digits` on the RHS of `hd :: tl`. The `nat.of_digits_append` is used
      -- because of the append that forms from the included `list.reverse`. The lengths of the lists
      -- are placed in the exponents with `10` as a base, and are combined using `←pow_succ 10`.
      -- Any complicated expression about list lengths is further simplified by the auxiliary
      -- lemmas we just proved. Finally, we assist the simplifier by rearranging terms with our
      -- `n + m + 1 - n = m + 1` proof and `mul_comm`.
      simp [this, hpow, Nat.ofDigits_append, mul_comm, ← pow_succ 10, hml, ltll]
    · -- Consider the case that `n' ≤ n + 1`. But then since `n < n' ≤ n + 1`, `n' = n + 1`.
      obtain rfl : n' = n + 1 := le_antisymm hn'' (Nat.succ_le_of_lt hn)
      -- This means we have only parsed in a single character, so the resulting parsed in list
      -- is explicitly formed from an expression we can construct from `hd`.
      use [hd.to_nat - '0'.toNat]
      -- Our list expression simplifies nicely because it is a fold over a singleton, so we
      -- do not have to supply any auxiliary lemmas for it, other than what we already know about
      -- `hd` and the function defined in `parser.nat`. However, we will have to prove that our
      -- parse ended because of a good reason: either we are out of bounds or we hit a nonnumeric
      -- character.
      simp only [many1_eq_done, many_eq_done_nil, digit_eq_fail, natm, and_comm, and_left_comm,
        hdigit, true_and_iff, mul_one, Nat.ofDigits_singleton, List.take, exists_eq_left,
        exists_and_right, add_tsub_cancel_left, eq_self_iff_true, List.reverse_singleton, zero_add,
        List.foldr, List.map]
      -- We take the route of proving that we hit a nonnumeric character, since we already have
      -- a hypothesis that says that characters at `n'` and past it are nonnumeric. (Note, by now
      -- we have substituted `n + 1` for `n'.
      -- We are also asked to provide the error value that our failed parse would report. But
      -- `digit_eq_fail` already knows what it is, so we can discharge that with an inline `rfl`.
      refine' ⟨_, Or.inl ⟨rfl, _⟩⟩
      -- The nonnumeric condition looks almost exactly like the hypothesis we already have, so
      -- we let the simplifier align them for us
      simpa using hb
#align parser.nat_eq_done Parser.nat_eq_done

end Nat

end Parser

