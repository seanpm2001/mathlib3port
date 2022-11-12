/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro
-/
import Mathbin.Algebra.Order.AbsoluteValue
import Mathbin.Algebra.BigOperators.Order

/-!
# Cauchy sequences

A basic theory of Cauchy sequences, used in the construction of the reals and p-adic numbers. Where
applicable, lemmas that will be reused in other contexts have been stated in extra generality.

There are other "versions" of Cauchyness in the library, in particular Cauchy filters in topology.
This is a concrete implementation that is useful for simplicity and computability reasons.

## Important definitions

* `is_cau_seq`: a predicate that says `f : ℕ → β` is Cauchy.
* `cau_seq`: the type of Cauchy sequences valued in type `β` with respect to an absolute value
  function `abv`.

## Tags

sequence, cauchy, abs val, absolute value
-/


open BigOperators

open IsAbsoluteValue

variable {G α β : Type _}

theorem exists_forall_ge_and {α} [LinearOrder α] {P Q : α → Prop} :
    (∃ i, ∀ j ≥ i, P j) → (∃ i, ∀ j ≥ i, Q j) → ∃ i, ∀ j ≥ i, P j ∧ Q j
  | ⟨a, h₁⟩, ⟨b, h₂⟩ =>
    let ⟨c, ac, bc⟩ := exists_ge_of_linear a b
    ⟨c, fun j hj => ⟨h₁ _ (le_trans ac hj), h₂ _ (le_trans bc hj)⟩⟩
#align exists_forall_ge_and exists_forall_ge_and

section

variable [LinearOrderedField α] [Ring β] (abv : β → α) [IsAbsoluteValue abv]

theorem rat_add_continuous_lemma {ε : α} (ε0 : 0 < ε) :
    ∃ δ > 0, ∀ {a₁ a₂ b₁ b₂ : β}, abv (a₁ - b₁) < δ → abv (a₂ - b₂) < δ → abv (a₁ + a₂ - (b₁ + b₂)) < ε :=
  ⟨ε / 2, half_pos ε0, fun a₁ a₂ b₁ b₂ h₁ h₂ => by
    simpa [add_halves, sub_eq_add_neg, add_comm, add_left_comm, add_assoc] using
      lt_of_le_of_lt (abv_add abv _ _) (add_lt_add h₁ h₂)⟩
#align rat_add_continuous_lemma rat_add_continuous_lemma

theorem rat_mul_continuous_lemma {ε K₁ K₂ : α} (ε0 : 0 < ε) :
    ∃ δ > 0,
      ∀ {a₁ a₂ b₁ b₂ : β},
        abv a₁ < K₁ → abv b₂ < K₂ → abv (a₁ - b₁) < δ → abv (a₂ - b₂) < δ → abv (a₁ * a₂ - b₁ * b₂) < ε :=
  by
  have K0 : (0 : α) < max 1 (max K₁ K₂) := lt_of_lt_of_le zero_lt_one (le_max_left _ _)
  have εK := div_pos (half_pos ε0) K0
  refine' ⟨_, εK, fun a₁ a₂ b₁ b₂ ha₁ hb₂ h₁ h₂ => _⟩
  replace ha₁ := lt_of_lt_of_le ha₁ (le_trans (le_max_left _ K₂) (le_max_right 1 _))
  replace hb₂ := lt_of_lt_of_le hb₂ (le_trans (le_max_right K₁ _) (le_max_right 1 _))
  have :=
    add_lt_add (mul_lt_mul' (le_of_lt h₁) hb₂ (abv_nonneg abv _) εK)
      (mul_lt_mul' (le_of_lt h₂) ha₁ (abv_nonneg abv _) εK)
  rw [← abv_mul abv, mul_comm, div_mul_cancel _ (ne_of_gt K0), ← abv_mul abv, add_halves] at this
  simpa [mul_add, add_mul, sub_eq_add_neg, add_comm, add_left_comm] using lt_of_le_of_lt (abv_add abv _ _) this
#align rat_mul_continuous_lemma rat_mul_continuous_lemma

theorem rat_inv_continuous_lemma {β : Type _} [Field β] (abv : β → α) [IsAbsoluteValue abv] {ε K : α} (ε0 : 0 < ε)
    (K0 : 0 < K) : ∃ δ > 0, ∀ {a b : β}, K ≤ abv a → K ≤ abv b → abv (a - b) < δ → abv (a⁻¹ - b⁻¹) < ε := by
  have KK := mul_pos K0 K0
  have εK := mul_pos ε0 KK
  refine' ⟨_, εK, fun a b ha hb h => _⟩
  have a0 := lt_of_lt_of_le K0 ha
  have b0 := lt_of_lt_of_le K0 hb
  rw [inv_sub_inv ((abv_pos abv).1 a0) ((abv_pos abv).1 b0), abv_div abv, abv_mul abv, mul_comm, abv_sub abv, ←
    mul_div_cancel ε (ne_of_gt KK)]
  exact div_lt_div h (mul_le_mul hb ha (le_of_lt K0) (abv_nonneg abv _)) (le_of_lt <| mul_pos ε0 KK) KK
#align rat_inv_continuous_lemma rat_inv_continuous_lemma

end

/-- A sequence is Cauchy if the distance between its entries tends to zero. -/
def IsCauSeq {α : Type _} [LinearOrderedField α] {β : Type _} [Ring β] (abv : β → α) (f : ℕ → β) : Prop :=
  ∀ ε > 0, ∃ i, ∀ j ≥ i, abv (f j - f i) < ε
#align is_cau_seq IsCauSeq

namespace IsCauSeq

variable [LinearOrderedField α] [Ring β] {abv : β → α} [IsAbsoluteValue abv] {f g : ℕ → β}

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (j k «expr ≥ » i) -/
-- see Note [nolint_ge]
@[nolint ge_or_gt]
theorem cauchy₂ (hf : IsCauSeq abv f) {ε : α} (ε0 : 0 < ε) :
    ∃ i, ∀ (j k) (_ : j ≥ i) (_ : k ≥ i), abv (f j - f k) < ε := by
  refine' (hf _ (half_pos ε0)).imp fun i hi j ij k ik => _
  rw [← add_halves ε]
  refine' lt_of_le_of_lt (abv_sub_le abv _ _ _) (add_lt_add (hi _ ij) _)
  rw [abv_sub abv]
  exact hi _ ik
#align is_cau_seq.cauchy₂ IsCauSeq.cauchy₂

theorem cauchy₃ (hf : IsCauSeq abv f) {ε : α} (ε0 : 0 < ε) : ∃ i, ∀ j ≥ i, ∀ k ≥ j, abv (f k - f j) < ε :=
  let ⟨i, H⟩ := hf.cauchy₂ ε0
  ⟨i, fun j ij k jk => H _ (le_trans ij jk) _ ij⟩
#align is_cau_seq.cauchy₃ IsCauSeq.cauchy₃

theorem add (hf : IsCauSeq abv f) (hg : IsCauSeq abv g) : IsCauSeq abv (f + g) := fun ε ε0 =>
  let ⟨δ, δ0, Hδ⟩ := rat_add_continuous_lemma abv ε0
  let ⟨i, H⟩ := exists_forall_ge_and (hf.cauchy₃ δ0) (hg.cauchy₃ δ0)
  ⟨i, fun j ij =>
    let ⟨H₁, H₂⟩ := H _ le_rfl
    Hδ (H₁ _ ij) (H₂ _ ij)⟩
#align is_cau_seq.add IsCauSeq.add

end IsCauSeq

/-- `cau_seq β abv` is the type of `β`-valued Cauchy sequences, with respect to the absolute value
function `abv`. -/
def CauSeq {α : Type _} [LinearOrderedField α] (β : Type _) [Ring β] (abv : β → α) : Type _ :=
  { f : ℕ → β // IsCauSeq abv f }
#align cau_seq CauSeq

namespace CauSeq

variable [LinearOrderedField α]

section Ring

variable [Ring β] {abv : β → α}

instance : CoeFun (CauSeq β abv) fun _ => ℕ → β :=
  ⟨Subtype.val⟩

@[simp]
theorem mk_to_fun (f) (hf : IsCauSeq abv f) : @coeFn (CauSeq β abv) _ _ ⟨f, hf⟩ = f :=
  rfl
#align cau_seq.mk_to_fun CauSeq.mk_to_fun

theorem ext {f g : CauSeq β abv} (h : ∀ i, f i = g i) : f = g :=
  Subtype.eq (funext h)
#align cau_seq.ext CauSeq.ext

theorem isCau (f : CauSeq β abv) : IsCauSeq abv f :=
  f.2
#align cau_seq.is_cau CauSeq.isCau

theorem cauchy (f : CauSeq β abv) : ∀ {ε}, 0 < ε → ∃ i, ∀ j ≥ i, abv (f j - f i) < ε :=
  f.2
#align cau_seq.cauchy CauSeq.cauchy

/-- Given a Cauchy sequence `f`, create a Cauchy sequence from a sequence `g` with
the same values as `f`. -/
def ofEq (f : CauSeq β abv) (g : ℕ → β) (e : ∀ i, f i = g i) : CauSeq β abv :=
  ⟨g, fun ε => by rw [show g = f from (funext e).symm] <;> exact f.cauchy⟩
#align cau_seq.of_eq CauSeq.ofEq

variable [IsAbsoluteValue abv]

/- ./././Mathport/Syntax/Translate/Basic.lean:610:2: warning: expanding binder collection (j k «expr ≥ » i) -/
-- see Note [nolint_ge]
@[nolint ge_or_gt]
theorem cauchy₂ (f : CauSeq β abv) {ε} : 0 < ε → ∃ i, ∀ (j k) (_ : j ≥ i) (_ : k ≥ i), abv (f j - f k) < ε :=
  f.2.cauchy₂
#align cau_seq.cauchy₂ CauSeq.cauchy₂

theorem cauchy₃ (f : CauSeq β abv) {ε} : 0 < ε → ∃ i, ∀ j ≥ i, ∀ k ≥ j, abv (f k - f j) < ε :=
  f.2.cauchy₃
#align cau_seq.cauchy₃ CauSeq.cauchy₃

theorem bounded (f : CauSeq β abv) : ∃ r, ∀ i, abv (f i) < r := by
  cases' f.cauchy zero_lt_one with i h
  let R := ∑ j in Finset.range (i + 1), abv (f j)
  have : ∀ j ≤ i, abv (f j) ≤ R := by
    intro j ij
    change (fun j => abv (f j)) j ≤ R
    apply Finset.single_le_sum
    · intros
      apply abv_nonneg abv
      
    · rwa [Finset.mem_range, Nat.lt_succ_iff]
      
  refine' ⟨R + 1, fun j => _⟩
  cases' lt_or_le j i with ij ij
  · exact lt_of_le_of_lt (this _ (le_of_lt ij)) (lt_add_one _)
    
  · have := lt_of_le_of_lt (abv_add abv _ _) (add_lt_add_of_le_of_lt (this _ le_rfl) (h _ ij))
    rw [add_sub, add_comm] at this
    simpa
    
#align cau_seq.bounded CauSeq.bounded

theorem bounded' (f : CauSeq β abv) (x : α) : ∃ r > x, ∀ i, abv (f i) < r :=
  let ⟨r, h⟩ := f.Bounded
  ⟨max r (x + 1), lt_of_lt_of_le (lt_add_one _) (le_max_right _ _), fun i => lt_of_lt_of_le (h i) (le_max_left _ _)⟩
#align cau_seq.bounded' CauSeq.bounded'

instance : Add (CauSeq β abv) :=
  ⟨fun f g => ⟨f + g, f.2.add g.2⟩⟩

@[simp, norm_cast]
theorem coe_add (f g : CauSeq β abv) : ⇑(f + g) = f + g :=
  rfl
#align cau_seq.coe_add CauSeq.coe_add

@[simp, norm_cast]
theorem add_apply (f g : CauSeq β abv) (i : ℕ) : (f + g) i = f i + g i :=
  rfl
#align cau_seq.add_apply CauSeq.add_apply

variable (abv)

/-- The constant Cauchy sequence. -/
def const (x : β) : CauSeq β abv :=
  ⟨fun i => x, fun ε ε0 => ⟨0, fun j ij => by simpa [abv_zero abv] using ε0⟩⟩
#align cau_seq.const CauSeq.const

variable {abv}

-- mathport name: exprconst
local notation "const" => const abv

@[simp, norm_cast]
theorem coe_const (x : β) : ⇑(const x) = Function.const _ x :=
  rfl
#align cau_seq.coe_const CauSeq.coe_const

@[simp, norm_cast]
theorem const_apply (x : β) (i : ℕ) : (const x : ℕ → β) i = x :=
  rfl
#align cau_seq.const_apply CauSeq.const_apply

theorem const_inj {x y : β} : (const x : CauSeq β abv) = const y ↔ x = y :=
  ⟨fun h => congr_arg (fun f : CauSeq β abv => (f : ℕ → β) 0) h, congr_arg _⟩
#align cau_seq.const_inj CauSeq.const_inj

instance : Zero (CauSeq β abv) :=
  ⟨const 0⟩

instance : One (CauSeq β abv) :=
  ⟨const 1⟩

instance : Inhabited (CauSeq β abv) :=
  ⟨0⟩

@[simp, norm_cast]
theorem coe_zero : ⇑(0 : CauSeq β abv) = 0 :=
  rfl
#align cau_seq.coe_zero CauSeq.coe_zero

@[simp, norm_cast]
theorem coe_one : ⇑(1 : CauSeq β abv) = 1 :=
  rfl
#align cau_seq.coe_one CauSeq.coe_one

@[simp, norm_cast]
theorem zero_apply (i) : (0 : CauSeq β abv) i = 0 :=
  rfl
#align cau_seq.zero_apply CauSeq.zero_apply

@[simp, norm_cast]
theorem one_apply (i) : (1 : CauSeq β abv) i = 1 :=
  rfl
#align cau_seq.one_apply CauSeq.one_apply

@[simp]
theorem const_zero : const 0 = 0 :=
  rfl
#align cau_seq.const_zero CauSeq.const_zero

@[simp]
theorem const_one : const 1 = 1 :=
  rfl
#align cau_seq.const_one CauSeq.const_one

theorem const_add (x y : β) : const (x + y) = const x + const y :=
  rfl
#align cau_seq.const_add CauSeq.const_add

instance : Mul (CauSeq β abv) :=
  ⟨fun f g =>
    ⟨f * g, fun ε ε0 =>
      let ⟨F, F0, hF⟩ := f.bounded' 0
      let ⟨G, G0, hG⟩ := g.bounded' 0
      let ⟨δ, δ0, Hδ⟩ := rat_mul_continuous_lemma abv ε0
      let ⟨i, H⟩ := exists_forall_ge_and (f.cauchy₃ δ0) (g.cauchy₃ δ0)
      ⟨i, fun j ij =>
        let ⟨H₁, H₂⟩ := H _ le_rfl
        Hδ (hF j) (hG i) (H₁ _ ij) (H₂ _ ij)⟩⟩⟩

@[simp, norm_cast]
theorem coe_mul (f g : CauSeq β abv) : ⇑(f * g) = f * g :=
  rfl
#align cau_seq.coe_mul CauSeq.coe_mul

@[simp, norm_cast]
theorem mul_apply (f g : CauSeq β abv) (i : ℕ) : (f * g) i = f i * g i :=
  rfl
#align cau_seq.mul_apply CauSeq.mul_apply

theorem const_mul (x y : β) : const (x * y) = const x * const y :=
  rfl
#align cau_seq.const_mul CauSeq.const_mul

instance : Neg (CauSeq β abv) :=
  ⟨fun f => ofEq (const (-1) * f) (fun x => -f x) fun i => by simp⟩

@[simp, norm_cast]
theorem coe_neg (f : CauSeq β abv) : ⇑(-f) = -f :=
  rfl
#align cau_seq.coe_neg CauSeq.coe_neg

@[simp, norm_cast]
theorem neg_apply (f : CauSeq β abv) (i) : (-f) i = -f i :=
  rfl
#align cau_seq.neg_apply CauSeq.neg_apply

theorem const_neg (x : β) : const (-x) = -const x :=
  rfl
#align cau_seq.const_neg CauSeq.const_neg

instance : Sub (CauSeq β abv) :=
  ⟨fun f g => ofEq (f + -g) (fun x => f x - g x) fun i => by simp [sub_eq_add_neg]⟩

@[simp, norm_cast]
theorem coe_sub (f g : CauSeq β abv) : ⇑(f - g) = f - g :=
  rfl
#align cau_seq.coe_sub CauSeq.coe_sub

@[simp, norm_cast]
theorem sub_apply (f g : CauSeq β abv) (i : ℕ) : (f - g) i = f i - g i :=
  rfl
#align cau_seq.sub_apply CauSeq.sub_apply

theorem const_sub (x y : β) : const (x - y) = const x - const y :=
  rfl
#align cau_seq.const_sub CauSeq.const_sub

section HasSmul

variable [HasSmul G β] [IsScalarTower G β β]

instance : HasSmul G (CauSeq β abv) :=
  ⟨fun a f => (ofEq (const (a • 1) * f) (a • f)) fun i => smul_one_mul _ _⟩

@[simp, norm_cast]
theorem coe_smul (a : G) (f : CauSeq β abv) : ⇑(a • f) = a • f :=
  rfl
#align cau_seq.coe_smul CauSeq.coe_smul

@[simp, norm_cast]
theorem smul_apply (a : G) (f : CauSeq β abv) (i : ℕ) : (a • f) i = a • f i :=
  rfl
#align cau_seq.smul_apply CauSeq.smul_apply

theorem const_smul (a : G) (x : β) : const (a • x) = a • const x :=
  rfl
#align cau_seq.const_smul CauSeq.const_smul

end HasSmul

instance : AddGroup (CauSeq β abv) := by
  refine_struct
      { add := (· + ·), neg := Neg.neg, zero := (0 : CauSeq β abv), sub := Sub.sub, zsmul := (· • ·),
        nsmul := (· • ·) } <;>
    intros <;> try rfl <;> apply ext <;> simp [add_comm, add_left_comm, sub_eq_add_neg, add_mul]

instance : AddGroupWithOne (CauSeq β abv) :=
  { CauSeq.addGroup with one := 1, natCast := fun n => const n, nat_cast_zero := congr_arg const Nat.cast_zero,
    nat_cast_succ := fun n => congr_arg const (Nat.cast_succ n), intCast := fun n => const n,
    int_cast_of_nat := fun n => congr_arg const (Int.cast_of_nat n),
    int_cast_neg_succ_of_nat := fun n => congr_arg const (Int.cast_negSucc n) }

instance : Pow (CauSeq β abv) ℕ :=
  ⟨fun f n => (ofEq (npowRec n f) fun i => f i ^ n) <| by induction n <;> simp [*, npowRec, pow_succ]⟩

@[simp, norm_cast]
theorem coe_pow (f : CauSeq β abv) (n : ℕ) : ⇑(f ^ n) = f ^ n :=
  rfl
#align cau_seq.coe_pow CauSeq.coe_pow

@[simp, norm_cast]
theorem pow_apply (f : CauSeq β abv) (n i : ℕ) : (f ^ n) i = f i ^ n :=
  rfl
#align cau_seq.pow_apply CauSeq.pow_apply

theorem const_pow (x : β) (n : ℕ) : const (x ^ n) = const x ^ n :=
  rfl
#align cau_seq.const_pow CauSeq.const_pow

instance : Ring (CauSeq β abv) := by
  refine_struct
      { CauSeq.addGroupWithOne with add := (· + ·), zero := (0 : CauSeq β abv), mul := (· * ·), one := 1,
        npow := fun n f => f ^ n } <;>
    intros <;>
      try rfl <;> apply ext <;> simp [mul_add, mul_assoc, add_mul, add_comm, add_left_comm, sub_eq_add_neg, pow_succ]

instance {β : Type _} [CommRing β] {abv : β → α} [IsAbsoluteValue abv] : CommRing (CauSeq β abv) :=
  { CauSeq.ring with mul_comm := by intros <;> apply ext <;> simp [mul_left_comm, mul_comm] }

/-- `lim_zero f` holds when `f` approaches 0. -/
def LimZero {abv : β → α} (f : CauSeq β abv) : Prop :=
  ∀ ε > 0, ∃ i, ∀ j ≥ i, abv (f j) < ε
#align cau_seq.lim_zero CauSeq.LimZero

theorem addLimZero {f g : CauSeq β abv} (hf : LimZero f) (hg : LimZero g) : LimZero (f + g)
  | ε, ε0 =>
    (exists_forall_ge_and (hf _ <| half_pos ε0) (hg _ <| half_pos ε0)).imp fun i H j ij => by
      let ⟨H₁, H₂⟩ := H _ ij
      simpa [add_halves ε] using lt_of_le_of_lt (abv_add abv _ _) (add_lt_add H₁ H₂)
#align cau_seq.add_lim_zero CauSeq.addLimZero

theorem mulLimZeroRight (f : CauSeq β abv) {g} (hg : LimZero g) : LimZero (f * g)
  | ε, ε0 =>
    let ⟨F, F0, hF⟩ := f.bounded' 0
    (hg _ <| div_pos ε0 F0).imp fun i H j ij => by
      have := mul_lt_mul' (le_of_lt <| hF j) (H _ ij) (abv_nonneg abv _) F0 <;>
        rwa [mul_comm F, div_mul_cancel _ (ne_of_gt F0), ← abv_mul abv] at this
#align cau_seq.mul_lim_zero_right CauSeq.mulLimZeroRight

theorem mulLimZeroLeft {f} (g : CauSeq β abv) (hg : LimZero f) : LimZero (f * g)
  | ε, ε0 =>
    let ⟨G, G0, hG⟩ := g.bounded' 0
    (hg _ <| div_pos ε0 G0).imp fun i H j ij => by
      have := mul_lt_mul'' (H _ ij) (hG j) (abv_nonneg abv _) (abv_nonneg abv _) <;>
        rwa [div_mul_cancel _ (ne_of_gt G0), ← abv_mul abv] at this
#align cau_seq.mul_lim_zero_left CauSeq.mulLimZeroLeft

theorem negLimZero {f : CauSeq β abv} (hf : LimZero f) : LimZero (-f) := by
  rw [← neg_one_mul] <;> exact mul_lim_zero_right _ hf
#align cau_seq.neg_lim_zero CauSeq.negLimZero

theorem subLimZero {f g : CauSeq β abv} (hf : LimZero f) (hg : LimZero g) : LimZero (f - g) := by
  simpa only [sub_eq_add_neg] using add_lim_zero hf (neg_lim_zero hg)
#align cau_seq.sub_lim_zero CauSeq.subLimZero

theorem limZeroSubRev {f g : CauSeq β abv} (hfg : LimZero (f - g)) : LimZero (g - f) := by simpa using neg_lim_zero hfg
#align cau_seq.lim_zero_sub_rev CauSeq.limZeroSubRev

theorem zeroLimZero : LimZero (0 : CauSeq β abv)
  | ε, ε0 => ⟨0, fun j ij => by simpa [abv_zero abv] using ε0⟩
#align cau_seq.zero_lim_zero CauSeq.zeroLimZero

theorem const_lim_zero {x : β} : LimZero (const x) ↔ x = 0 :=
  ⟨fun H =>
    (abv_eq_zero abv).1 <|
      (eq_of_le_of_forall_le_of_dense (abv_nonneg abv _)) fun ε ε0 =>
        let ⟨i, hi⟩ := H _ ε0
        le_of_lt <| hi _ le_rfl,
    fun e => e.symm ▸ zero_lim_zero⟩
#align cau_seq.const_lim_zero CauSeq.const_lim_zero

instance equiv : Setoid (CauSeq β abv) :=
  ⟨fun f g => LimZero (f - g),
    ⟨fun f => by simp [zero_lim_zero], fun f g h => by simpa using neg_lim_zero h, fun f g h fg gh => by
      simpa [sub_eq_add_neg, add_assoc] using add_lim_zero fg gh⟩⟩
#align cau_seq.equiv CauSeq.equiv

theorem add_equiv_add {f1 f2 g1 g2 : CauSeq β abv} (hf : f1 ≈ f2) (hg : g1 ≈ g2) : f1 + g1 ≈ f2 + g2 := by
  simpa only [← add_sub_add_comm] using add_lim_zero hf hg
#align cau_seq.add_equiv_add CauSeq.add_equiv_add

theorem neg_equiv_neg {f g : CauSeq β abv} (hf : f ≈ g) : -f ≈ -g := by simpa only [neg_sub'] using neg_lim_zero hf
#align cau_seq.neg_equiv_neg CauSeq.neg_equiv_neg

theorem sub_equiv_sub {f1 f2 g1 g2 : CauSeq β abv} (hf : f1 ≈ f2) (hg : g1 ≈ g2) : f1 - g1 ≈ f2 - g2 := by
  simpa only [sub_eq_add_neg] using add_equiv_add hf (neg_equiv_neg hg)
#align cau_seq.sub_equiv_sub CauSeq.sub_equiv_sub

theorem equiv_def₃ {f g : CauSeq β abv} (h : f ≈ g) {ε : α} (ε0 : 0 < ε) : ∃ i, ∀ j ≥ i, ∀ k ≥ j, abv (f k - g j) < ε :=
  (exists_forall_ge_and (h _ <| half_pos ε0) (f.cauchy₃ <| half_pos ε0)).imp fun i H j ij k jk => by
    let ⟨h₁, h₂⟩ := H _ ij
    have := lt_of_le_of_lt (abv_add abv (f j - g j) _) (add_lt_add h₁ (h₂ _ jk)) <;>
      rwa [sub_add_sub_cancel', add_halves] at this
#align cau_seq.equiv_def₃ CauSeq.equiv_def₃

theorem lim_zero_congr {f g : CauSeq β abv} (h : f ≈ g) : LimZero f ↔ LimZero g :=
  ⟨fun l => by simpa using add_lim_zero (Setoid.symm h) l, fun l => by simpa using add_lim_zero h l⟩
#align cau_seq.lim_zero_congr CauSeq.lim_zero_congr

theorem abv_pos_of_not_lim_zero {f : CauSeq β abv} (hf : ¬LimZero f) : ∃ K > 0, ∃ i, ∀ j ≥ i, K ≤ abv (f j) := by
  haveI := Classical.propDecidable
  by_contra nk
  refine' hf fun ε ε0 => _
  simp [not_forall] at nk
  cases' f.cauchy₃ (half_pos ε0) with i hi
  rcases nk _ (half_pos ε0) i with ⟨j, ij, hj⟩
  refine' ⟨j, fun k jk => _⟩
  have := lt_of_le_of_lt (abv_add abv _ _) (add_lt_add (hi j ij k jk) hj)
  rwa [sub_add_cancel, add_halves] at this
#align cau_seq.abv_pos_of_not_lim_zero CauSeq.abv_pos_of_not_lim_zero

theorem ofNear (f : ℕ → β) (g : CauSeq β abv) (h : ∀ ε > 0, ∃ i, ∀ j ≥ i, abv (f j - g j) < ε) : IsCauSeq abv f
  | ε, ε0 =>
    let ⟨i, hi⟩ := exists_forall_ge_and (h _ (half_pos <| half_pos ε0)) (g.cauchy₃ <| half_pos ε0)
    ⟨i, fun j ij => by
      cases' hi _ le_rfl with h₁ h₂
      rw [abv_sub abv] at h₁
      have := lt_of_le_of_lt (abv_add abv _ _) (add_lt_add (hi _ ij).1 h₁)
      have := lt_of_le_of_lt (abv_add abv _ _) (add_lt_add this (h₂ _ ij))
      rwa [add_halves, add_halves, add_right_comm, sub_add_sub_cancel, sub_add_sub_cancel] at this⟩
#align cau_seq.of_near CauSeq.ofNear

theorem not_lim_zero_of_not_congr_zero {f : CauSeq _ abv} (hf : ¬f ≈ 0) : ¬LimZero f := fun this : LimZero f =>
  have : LimZero (f - 0) := by simpa
  hf this
#align cau_seq.not_lim_zero_of_not_congr_zero CauSeq.not_lim_zero_of_not_congr_zero

theorem mul_equiv_zero (g : CauSeq _ abv) {f : CauSeq _ abv} (hf : f ≈ 0) : g * f ≈ 0 :=
  have : LimZero (f - 0) := hf
  have : LimZero (g * f) := mulLimZeroRight _ <| by simpa
  show LimZero (g * f - 0) by simpa
#align cau_seq.mul_equiv_zero CauSeq.mul_equiv_zero

theorem mul_not_equiv_zero {f g : CauSeq _ abv} (hf : ¬f ≈ 0) (hg : ¬g ≈ 0) : ¬f * g ≈ 0 :=
  fun this : LimZero (f * g - 0) => by
  have hlz : LimZero (f * g) := by simpa
  have hf' : ¬LimZero f := by simpa using show ¬lim_zero (f - 0) from hf
  have hg' : ¬LimZero g := by simpa using show ¬lim_zero (g - 0) from hg
  rcases abv_pos_of_not_lim_zero hf' with ⟨a1, ha1, N1, hN1⟩
  rcases abv_pos_of_not_lim_zero hg' with ⟨a2, ha2, N2, hN2⟩
  have : 0 < a1 * a2 := mul_pos ha1 ha2
  cases' hlz _ this with N hN
  let i := max N (max N1 N2)
  have hN' := hN i (le_max_left _ _)
  have hN1' := hN1 i (le_trans (le_max_left _ _) (le_max_right _ _))
  have hN1' := hN2 i (le_trans (le_max_right _ _) (le_max_right _ _))
  apply not_le_of_lt hN'
  change _ ≤ abv (_ * _)
  rw [IsAbsoluteValue.abv_mul abv]
  apply mul_le_mul <;> try assumption
  · apply le_of_lt ha2
    
  · apply IsAbsoluteValue.abv_nonneg abv
    
#align cau_seq.mul_not_equiv_zero CauSeq.mul_not_equiv_zero

theorem const_equiv {x y : β} : const x ≈ const y ↔ x = y :=
  show LimZero _ ↔ _ by rw [← const_sub, const_lim_zero, sub_eq_zero]
#align cau_seq.const_equiv CauSeq.const_equiv

end Ring

section CommRing

variable [CommRing β] {abv : β → α} [IsAbsoluteValue abv]

theorem mul_equiv_zero' (g : CauSeq _ abv) {f : CauSeq _ abv} (hf : f ≈ 0) : f * g ≈ 0 := by
  rw [mul_comm] <;> apply mul_equiv_zero _ hf
#align cau_seq.mul_equiv_zero' CauSeq.mul_equiv_zero'

theorem mul_equiv_mul {f1 f2 g1 g2 : CauSeq β abv} (hf : f1 ≈ f2) (hg : g1 ≈ g2) : f1 * g1 ≈ f2 * g2 := by
  simpa only [mul_sub, mul_comm, sub_add_sub_cancel] using
    add_lim_zero (mul_lim_zero_right g1 hf) (mul_lim_zero_right f2 hg)
#align cau_seq.mul_equiv_mul CauSeq.mul_equiv_mul

end CommRing

section IsDomain

variable [Ring β] [IsDomain β] (abv : β → α) [IsAbsoluteValue abv]

theorem one_not_equiv_zero : ¬const abv 1 ≈ const abv 0 := fun h =>
  have : ∀ ε > 0, ∃ i, ∀ k, i ≤ k → abv (1 - 0) < ε := h
  have h1 : abv 1 ≤ 0 :=
    le_of_not_gt fun h2 : 0 < abv 1 =>
      (Exists.elim (this _ h2)) fun i hi => lt_irrefl (abv 1) <| by simpa using hi _ le_rfl
  have h2 : 0 ≤ abv 1 := IsAbsoluteValue.abv_nonneg _ _
  have : abv 1 = 0 := le_antisymm h1 h2
  have : (1 : β) = 0 := (IsAbsoluteValue.abv_eq_zero abv).1 this
  absurd this one_ne_zero
#align cau_seq.one_not_equiv_zero CauSeq.one_not_equiv_zero

end IsDomain

section Field

variable [Field β] {abv : β → α} [IsAbsoluteValue abv]

theorem inv_aux {f : CauSeq β abv} (hf : ¬LimZero f) : ∀ ε > 0, ∃ i, ∀ j ≥ i, abv ((f j)⁻¹ - (f i)⁻¹) < ε
  | ε, ε0 =>
    let ⟨K, K0, HK⟩ := abv_pos_of_not_lim_zero hf
    let ⟨δ, δ0, Hδ⟩ := rat_inv_continuous_lemma abv ε0 K0
    let ⟨i, H⟩ := exists_forall_ge_and HK (f.cauchy₃ δ0)
    ⟨i, fun j ij =>
      let ⟨iK, H'⟩ := H _ le_rfl
      Hδ (H _ ij).1 iK (H' _ ij)⟩
#align cau_seq.inv_aux CauSeq.inv_aux

/-- Given a Cauchy sequence `f` with nonzero limit, create a Cauchy sequence with values equal to
the inverses of the values of `f`. -/
def inv (f : CauSeq β abv) (hf : ¬LimZero f) : CauSeq β abv :=
  ⟨_, inv_aux hf⟩
#align cau_seq.inv CauSeq.inv

@[simp, norm_cast]
theorem coe_inv {f : CauSeq β abv} (hf) : ⇑(inv f hf) = f⁻¹ :=
  rfl
#align cau_seq.coe_inv CauSeq.coe_inv

@[simp, norm_cast]
theorem inv_apply {f : CauSeq β abv} (hf i) : inv f hf i = (f i)⁻¹ :=
  rfl
#align cau_seq.inv_apply CauSeq.inv_apply

theorem inv_mul_cancel {f : CauSeq β abv} (hf) : inv f hf * f ≈ 1 := fun ε ε0 =>
  let ⟨K, K0, i, H⟩ := abv_pos_of_not_lim_zero hf
  ⟨i, fun j ij => by simpa [(abv_pos abv).1 (lt_of_lt_of_le K0 (H _ ij)), abv_zero abv] using ε0⟩
#align cau_seq.inv_mul_cancel CauSeq.inv_mul_cancel

theorem const_inv {x : β} (hx : x ≠ 0) : const abv x⁻¹ = inv (const abv x) (by rwa [const_lim_zero]) :=
  rfl
#align cau_seq.const_inv CauSeq.const_inv

end Field

section Abs

-- mathport name: exprconst
local notation "const" => const abs

/-- The entries of a positive Cauchy sequence eventually have a positive lower bound. -/
def Pos (f : CauSeq α abs) : Prop :=
  ∃ K > 0, ∃ i, ∀ j ≥ i, K ≤ f j
#align cau_seq.pos CauSeq.Pos

theorem not_lim_zero_of_pos {f : CauSeq α abs} : Pos f → ¬LimZero f
  | ⟨F, F0, hF⟩, H =>
    let ⟨i, h⟩ := exists_forall_ge_and hF (H _ F0)
    let ⟨h₁, h₂⟩ := h _ le_rfl
    not_lt_of_le h₁ (abs_lt.1 h₂).2
#align cau_seq.not_lim_zero_of_pos CauSeq.not_lim_zero_of_pos

theorem const_pos {x : α} : Pos (const x) ↔ 0 < x :=
  ⟨fun ⟨K, K0, i, h⟩ => lt_of_lt_of_le K0 (h _ le_rfl), fun h => ⟨x, h, 0, fun j _ => le_rfl⟩⟩
#align cau_seq.const_pos CauSeq.const_pos

theorem addPos {f g : CauSeq α abs} : Pos f → Pos g → Pos (f + g)
  | ⟨F, F0, hF⟩, ⟨G, G0, hG⟩ =>
    let ⟨i, h⟩ := exists_forall_ge_and hF hG
    ⟨_, add_pos F0 G0, i, fun j ij =>
      let ⟨h₁, h₂⟩ := h _ ij
      add_le_add h₁ h₂⟩
#align cau_seq.add_pos CauSeq.addPos

theorem posAddLimZero {f g : CauSeq α abs} : Pos f → LimZero g → Pos (f + g)
  | ⟨F, F0, hF⟩, H =>
    let ⟨i, h⟩ := exists_forall_ge_and hF (H _ (half_pos F0))
    ⟨_, half_pos F0, i, fun j ij => by
      cases' h j ij with h₁ h₂
      have := add_le_add h₁ (le_of_lt (abs_lt.1 h₂).1)
      rwa [← sub_eq_add_neg, sub_self_div_two] at this⟩
#align cau_seq.pos_add_lim_zero CauSeq.posAddLimZero

protected theorem mulPos {f g : CauSeq α abs} : Pos f → Pos g → Pos (f * g)
  | ⟨F, F0, hF⟩, ⟨G, G0, hG⟩ =>
    let ⟨i, h⟩ := exists_forall_ge_and hF hG
    ⟨_, mul_pos F0 G0, i, fun j ij =>
      let ⟨h₁, h₂⟩ := h _ ij
      mul_le_mul h₁ h₂ (le_of_lt G0) (le_trans (le_of_lt F0) h₁)⟩
#align cau_seq.mul_pos CauSeq.mulPos

theorem trichotomy (f : CauSeq α abs) : Pos f ∨ LimZero f ∨ Pos (-f) := by
  cases Classical.em (lim_zero f) <;> simp [*]
  rcases abv_pos_of_not_lim_zero h with ⟨K, K0, hK⟩
  rcases exists_forall_ge_and hK (f.cauchy₃ K0) with ⟨i, hi⟩
  refine' (le_total 0 (f i)).imp _ _ <;>
    refine' fun h => ⟨K, K0, i, fun j ij => _⟩ <;> have := (hi _ ij).1 <;> cases' hi _ le_rfl with h₁ h₂
  · rwa [abs_of_nonneg] at this
    rw [abs_of_nonneg h] at h₁
    exact (le_add_iff_nonneg_right _).1 (le_trans h₁ <| neg_le_sub_iff_le_add'.1 <| le_of_lt (abs_lt.1 <| h₂ _ ij).1)
    
  · rwa [abs_of_nonpos] at this
    rw [abs_of_nonpos h] at h₁
    rw [← sub_le_sub_iff_right, zero_sub]
    exact le_trans (le_of_lt (abs_lt.1 <| h₂ _ ij).2) h₁
    
#align cau_seq.trichotomy CauSeq.trichotomy

instance : LT (CauSeq α abs) :=
  ⟨fun f g => Pos (g - f)⟩

instance : LE (CauSeq α abs) :=
  ⟨fun f g => f < g ∨ f ≈ g⟩

theorem lt_of_lt_of_eq {f g h : CauSeq α abs} (fg : f < g) (gh : g ≈ h) : f < h :=
  show Pos (h - f) by simpa [sub_eq_add_neg, add_comm, add_left_comm] using pos_add_lim_zero fg (neg_lim_zero gh)
#align cau_seq.lt_of_lt_of_eq CauSeq.lt_of_lt_of_eq

theorem lt_of_eq_of_lt {f g h : CauSeq α abs} (fg : f ≈ g) (gh : g < h) : f < h := by
  have := pos_add_lim_zero gh (neg_lim_zero fg) <;> rwa [← sub_eq_add_neg, sub_sub_sub_cancel_right] at this
#align cau_seq.lt_of_eq_of_lt CauSeq.lt_of_eq_of_lt

theorem lt_trans {f g h : CauSeq α abs} (fg : f < g) (gh : g < h) : f < h :=
  show Pos (h - f) by simpa [sub_eq_add_neg, add_comm, add_left_comm] using add_pos fg gh
#align cau_seq.lt_trans CauSeq.lt_trans

theorem lt_irrefl {f : CauSeq α abs} : ¬f < f
  | h => not_lim_zero_of_pos h (by simp [zero_lim_zero])
#align cau_seq.lt_irrefl CauSeq.lt_irrefl

theorem le_of_eq_of_le {f g h : CauSeq α abs} (hfg : f ≈ g) (hgh : g ≤ h) : f ≤ h :=
  hgh.elim (Or.inl ∘ CauSeq.lt_of_eq_of_lt hfg) (Or.inr ∘ Setoid.trans hfg)
#align cau_seq.le_of_eq_of_le CauSeq.le_of_eq_of_le

theorem le_of_le_of_eq {f g h : CauSeq α abs} (hfg : f ≤ g) (hgh : g ≈ h) : f ≤ h :=
  hfg.elim (fun h => Or.inl (CauSeq.lt_of_lt_of_eq h hgh)) fun h => Or.inr (Setoid.trans h hgh)
#align cau_seq.le_of_le_of_eq CauSeq.le_of_le_of_eq

instance : Preorder (CauSeq α abs) where
  lt := (· < ·)
  le f g := f < g ∨ f ≈ g
  le_refl f := Or.inr (Setoid.refl _)
  le_trans f g h fg :=
    match fg with
    | Or.inl fg, Or.inl gh => Or.inl <| lt_trans fg gh
    | Or.inl fg, Or.inr gh => Or.inl <| lt_of_lt_of_eq fg gh
    | Or.inr fg, Or.inl gh => Or.inl <| lt_of_eq_of_lt fg gh
    | Or.inr fg, Or.inr gh => Or.inr <| Setoid.trans fg gh
  lt_iff_le_not_le f g :=
    ⟨fun h => ⟨Or.inl h, not_or_of_not (mt (lt_trans h) lt_irrefl) (not_lim_zero_of_pos h)⟩, fun ⟨h₁, h₂⟩ =>
      h₁.resolve_right (mt (fun h => Or.inr (Setoid.symm h)) h₂)⟩

theorem le_antisymm {f g : CauSeq α abs} (fg : f ≤ g) (gf : g ≤ f) : f ≈ g :=
  fg.resolve_left (not_lt_of_le gf)
#align cau_seq.le_antisymm CauSeq.le_antisymm

theorem lt_total (f g : CauSeq α abs) : f < g ∨ f ≈ g ∨ g < f :=
  (trichotomy (g - f)).imp_right fun h => h.imp (fun h => Setoid.symm h) fun h => by rwa [neg_sub] at h
#align cau_seq.lt_total CauSeq.lt_total

theorem le_total (f g : CauSeq α abs) : f ≤ g ∨ g ≤ f :=
  (or_assoc.2 (lt_total f g)).imp_right Or.inl
#align cau_seq.le_total CauSeq.le_total

theorem const_lt {x y : α} : const x < const y ↔ x < y :=
  show Pos _ ↔ _ by rw [← const_sub, const_pos, sub_pos]
#align cau_seq.const_lt CauSeq.const_lt

theorem const_le {x y : α} : const x ≤ const y ↔ x ≤ y := by
  rw [le_iff_lt_or_eq] <;> exact or_congr const_lt const_equiv
#align cau_seq.const_le CauSeq.const_le

theorem le_of_exists {f g : CauSeq α abs} (h : ∃ i, ∀ j ≥ i, f j ≤ g j) : f ≤ g :=
  let ⟨i, hi⟩ := h
  (or_assoc.2 (CauSeq.lt_total f g)).elim id fun hgf =>
    False.elim
      (let ⟨K, hK0, j, hKj⟩ := hgf
      not_lt_of_ge (hi (max i j) (le_max_left _ _)) (sub_pos.1 (lt_of_lt_of_le hK0 (hKj _ (le_max_right _ _)))))
#align cau_seq.le_of_exists CauSeq.le_of_exists

theorem exists_gt (f : CauSeq α abs) : ∃ a : α, f < const a :=
  let ⟨K, H⟩ := f.Bounded
  ⟨K + 1, 1, zero_lt_one, 0, fun i _ => by
    rw [sub_apply, const_apply, le_sub_iff_add_le', add_le_add_iff_right]
    exact le_of_lt (abs_lt.1 (H _)).2⟩
#align cau_seq.exists_gt CauSeq.exists_gt

theorem exists_lt (f : CauSeq α abs) : ∃ a : α, const a < f :=
  let ⟨a, h⟩ := (-f).exists_gt
  ⟨-a, show Pos _ by rwa [const_neg, sub_neg_eq_add, add_comm, ← sub_neg_eq_add]⟩
#align cau_seq.exists_lt CauSeq.exists_lt

-- so named to match `rat_add_continuous_lemma`
theorem _root_.rat_sup_continuous_lemma {ε : α} {a₁ a₂ b₁ b₂ : α} :
    abs (a₁ - b₁) < ε → abs (a₂ - b₂) < ε → abs (a₁ ⊔ a₂ - b₁ ⊔ b₂) < ε := fun h₁ h₂ =>
  (abs_max_sub_max_le_max _ _ _ _).trans_lt (max_lt h₁ h₂)
#align cau_seq._root_.rat_sup_continuous_lemma cau_seq._root_.rat_sup_continuous_lemma

-- so named to match `rat_add_continuous_lemma`
theorem _root_.rat_inf_continuous_lemma {ε : α} {a₁ a₂ b₁ b₂ : α} :
    abs (a₁ - b₁) < ε → abs (a₂ - b₂) < ε → abs (a₁ ⊓ a₂ - b₁ ⊓ b₂) < ε := fun h₁ h₂ =>
  (abs_min_sub_min_le_max _ _ _ _).trans_lt (max_lt h₁ h₂)
#align cau_seq._root_.rat_inf_continuous_lemma cau_seq._root_.rat_inf_continuous_lemma

instance : HasSup (CauSeq α abs) :=
  ⟨fun f g =>
    ⟨f ⊔ g, fun ε ε0 =>
      (exists_forall_ge_and (f.cauchy₃ ε0) (g.cauchy₃ ε0)).imp fun i H j ij =>
        let ⟨H₁, H₂⟩ := H _ le_rfl
        rat_sup_continuous_lemma (H₁ _ ij) (H₂ _ ij)⟩⟩

instance : HasInf (CauSeq α abs) :=
  ⟨fun f g =>
    ⟨f ⊓ g, fun ε ε0 =>
      (exists_forall_ge_and (f.cauchy₃ ε0) (g.cauchy₃ ε0)).imp fun i H j ij =>
        let ⟨H₁, H₂⟩ := H _ le_rfl
        rat_inf_continuous_lemma (H₁ _ ij) (H₂ _ ij)⟩⟩

@[simp, norm_cast]
theorem coe_sup (f g : CauSeq α abs) : ⇑(f ⊔ g) = f ⊔ g :=
  rfl
#align cau_seq.coe_sup CauSeq.coe_sup

@[simp, norm_cast]
theorem coe_inf (f g : CauSeq α abs) : ⇑(f ⊓ g) = f ⊓ g :=
  rfl
#align cau_seq.coe_inf CauSeq.coe_inf

theorem supLimZero {f g : CauSeq α abs} (hf : LimZero f) (hg : LimZero g) : LimZero (f ⊔ g)
  | ε, ε0 =>
    (exists_forall_ge_and (hf _ ε0) (hg _ ε0)).imp fun i H j ij => by
      let ⟨H₁, H₂⟩ := H _ ij
      rw [abs_lt] at H₁ H₂⊢
      exact ⟨lt_sup_iff.mpr (Or.inl H₁.1), sup_lt_iff.mpr ⟨H₁.2, H₂.2⟩⟩
#align cau_seq.sup_lim_zero CauSeq.supLimZero

theorem infLimZero {f g : CauSeq α abs} (hf : LimZero f) (hg : LimZero g) : LimZero (f ⊓ g)
  | ε, ε0 =>
    (exists_forall_ge_and (hf _ ε0) (hg _ ε0)).imp fun i H j ij => by
      let ⟨H₁, H₂⟩ := H _ ij
      rw [abs_lt] at H₁ H₂⊢
      exact ⟨lt_inf_iff.mpr ⟨H₁.1, H₂.1⟩, inf_lt_iff.mpr (Or.inl H₁.2)⟩
#align cau_seq.inf_lim_zero CauSeq.infLimZero

theorem sup_equiv_sup {a₁ b₁ a₂ b₂ : CauSeq α abs} (ha : a₁ ≈ a₂) (hb : b₁ ≈ b₂) : a₁ ⊔ b₁ ≈ a₂ ⊔ b₂ := by
  intro ε ε0
  obtain ⟨ai, hai⟩ := ha ε ε0
  obtain ⟨bi, hbi⟩ := hb ε ε0
  exact
    ⟨ai ⊔ bi, fun i hi =>
      (abs_max_sub_max_le_max (a₁ i) (b₁ i) (a₂ i) (b₂ i)).trans_lt
        (max_lt (hai i (sup_le_iff.mp hi).1) (hbi i (sup_le_iff.mp hi).2))⟩
#align cau_seq.sup_equiv_sup CauSeq.sup_equiv_sup

theorem inf_equiv_inf {a₁ b₁ a₂ b₂ : CauSeq α abs} (ha : a₁ ≈ a₂) (hb : b₁ ≈ b₂) : a₁ ⊓ b₁ ≈ a₂ ⊓ b₂ := by
  intro ε ε0
  obtain ⟨ai, hai⟩ := ha ε ε0
  obtain ⟨bi, hbi⟩ := hb ε ε0
  exact
    ⟨ai ⊔ bi, fun i hi =>
      (abs_min_sub_min_le_max (a₁ i) (b₁ i) (a₂ i) (b₂ i)).trans_lt
        (max_lt (hai i (sup_le_iff.mp hi).1) (hbi i (sup_le_iff.mp hi).2))⟩
#align cau_seq.inf_equiv_inf CauSeq.inf_equiv_inf

protected theorem sup_lt {a b c : CauSeq α abs} (ha : a < c) (hb : b < c) : a ⊔ b < c := by
  obtain ⟨⟨εa, εa0, ia, ha⟩, ⟨εb, εb0, ib, hb⟩⟩ := ha, hb
  refine' ⟨εa ⊓ εb, lt_inf_iff.mpr ⟨εa0, εb0⟩, ia ⊔ ib, fun i hi => _⟩
  have := min_le_min (ha _ (sup_le_iff.mp hi).1) (hb _ (sup_le_iff.mp hi).2)
  exact this.trans_eq (min_sub_sub_left _ _ _)
#align cau_seq.sup_lt CauSeq.sup_lt

protected theorem lt_inf {a b c : CauSeq α abs} (hb : a < b) (hc : a < c) : a < b ⊓ c := by
  obtain ⟨⟨εb, εb0, ib, hb⟩, ⟨εc, εc0, ic, hc⟩⟩ := hb, hc
  refine' ⟨εb ⊓ εc, lt_inf_iff.mpr ⟨εb0, εc0⟩, ib ⊔ ic, fun i hi => _⟩
  have := min_le_min (hb _ (sup_le_iff.mp hi).1) (hc _ (sup_le_iff.mp hi).2)
  exact this.trans_eq (min_sub_sub_right _ _ _)
#align cau_seq.lt_inf CauSeq.lt_inf

@[simp]
protected theorem sup_idem (a : CauSeq α abs) : a ⊔ a = a :=
  Subtype.ext sup_idem
#align cau_seq.sup_idem CauSeq.sup_idem

@[simp]
protected theorem inf_idem (a : CauSeq α abs) : a ⊓ a = a :=
  Subtype.ext inf_idem
#align cau_seq.inf_idem CauSeq.inf_idem

protected theorem sup_comm (a b : CauSeq α abs) : a ⊔ b = b ⊔ a :=
  Subtype.ext sup_comm
#align cau_seq.sup_comm CauSeq.sup_comm

protected theorem inf_comm (a b : CauSeq α abs) : a ⊓ b = b ⊓ a :=
  Subtype.ext inf_comm
#align cau_seq.inf_comm CauSeq.inf_comm

protected theorem sup_eq_right {a b : CauSeq α abs} (h : a ≤ b) : a ⊔ b ≈ b := by
  obtain ⟨ε, ε0 : _ < _, i, h⟩ | h := h
  · intro _ _
    refine' ⟨i, fun j hj => _⟩
    dsimp
    erw [← max_sub_sub_right]
    rwa [sub_self, max_eq_right, abs_zero]
    rw [sub_nonpos, ← sub_nonneg]
    exact ε0.le.trans (h _ hj)
    
  · refine' Setoid.trans (sup_equiv_sup h (Setoid.refl _)) _
    rw [CauSeq.sup_idem]
    exact Setoid.refl _
    
#align cau_seq.sup_eq_right CauSeq.sup_eq_right

protected theorem inf_eq_right {a b : CauSeq α abs} (h : b ≤ a) : a ⊓ b ≈ b := by
  obtain ⟨ε, ε0 : _ < _, i, h⟩ | h := h
  · intro _ _
    refine' ⟨i, fun j hj => _⟩
    dsimp
    erw [← min_sub_sub_right]
    rwa [sub_self, min_eq_right, abs_zero]
    exact ε0.le.trans (h _ hj)
    
  · refine' Setoid.trans (inf_equiv_inf (Setoid.symm h) (Setoid.refl _)) _
    rw [CauSeq.inf_idem]
    exact Setoid.refl _
    
#align cau_seq.inf_eq_right CauSeq.inf_eq_right

protected theorem sup_eq_left {a b : CauSeq α abs} (h : b ≤ a) : a ⊔ b ≈ a := by
  simpa only [CauSeq.sup_comm] using CauSeq.sup_eq_right h
#align cau_seq.sup_eq_left CauSeq.sup_eq_left

protected theorem inf_eq_left {a b : CauSeq α abs} (h : a ≤ b) : a ⊓ b ≈ a := by
  simpa only [CauSeq.inf_comm] using CauSeq.inf_eq_right h
#align cau_seq.inf_eq_left CauSeq.inf_eq_left

protected theorem le_sup_left {a b : CauSeq α abs} : a ≤ a ⊔ b :=
  le_of_exists ⟨0, fun j hj => le_sup_left⟩
#align cau_seq.le_sup_left CauSeq.le_sup_left

protected theorem inf_le_left {a b : CauSeq α abs} : a ⊓ b ≤ a :=
  le_of_exists ⟨0, fun j hj => inf_le_left⟩
#align cau_seq.inf_le_left CauSeq.inf_le_left

protected theorem le_sup_right {a b : CauSeq α abs} : b ≤ a ⊔ b :=
  le_of_exists ⟨0, fun j hj => le_sup_right⟩
#align cau_seq.le_sup_right CauSeq.le_sup_right

protected theorem inf_le_right {a b : CauSeq α abs} : a ⊓ b ≤ b :=
  le_of_exists ⟨0, fun j hj => inf_le_right⟩
#align cau_seq.inf_le_right CauSeq.inf_le_right

protected theorem sup_le {a b c : CauSeq α abs} (ha : a ≤ c) (hb : b ≤ c) : a ⊔ b ≤ c := by
  cases' ha with ha ha
  · cases' hb with hb hb
    · exact Or.inl (CauSeq.sup_lt ha hb)
      
    · replace ha := le_of_le_of_eq ha.le (Setoid.symm hb)
      refine' le_of_le_of_eq (Or.inr _) hb
      exact CauSeq.sup_eq_right ha
      
    
  · replace hb := le_of_le_of_eq hb (Setoid.symm ha)
    refine' le_of_le_of_eq (Or.inr _) ha
    exact CauSeq.sup_eq_left hb
    
#align cau_seq.sup_le CauSeq.sup_le

protected theorem le_inf {a b c : CauSeq α abs} (hb : a ≤ b) (hc : a ≤ c) : a ≤ b ⊓ c := by
  cases' hb with hb hb
  · cases' hc with hc hc
    · exact Or.inl (CauSeq.lt_inf hb hc)
      
    · replace hb := le_of_eq_of_le (Setoid.symm hc) hb.le
      refine' le_of_eq_of_le hc (Or.inr _)
      exact Setoid.symm (CauSeq.inf_eq_right hb)
      
    
  · replace hc := le_of_eq_of_le (Setoid.symm hb) hc
    refine' le_of_eq_of_le hb (Or.inr _)
    exact Setoid.symm (CauSeq.inf_eq_left hc)
    
#align cau_seq.le_inf CauSeq.le_inf

/-! Note that `distrib_lattice (cau_seq α abs)` is not true because there is no `partial_order`. -/


protected theorem sup_inf_distrib_left (a b c : CauSeq α abs) : a ⊔ b ⊓ c = (a ⊔ b) ⊓ (a ⊔ c) :=
  Subtype.ext <| funext fun i => max_min_distrib_left
#align cau_seq.sup_inf_distrib_left CauSeq.sup_inf_distrib_left

protected theorem sup_inf_distrib_right (a b c : CauSeq α abs) : a ⊓ b ⊔ c = (a ⊔ c) ⊓ (b ⊔ c) :=
  Subtype.ext <| funext fun i => max_min_distrib_right
#align cau_seq.sup_inf_distrib_right CauSeq.sup_inf_distrib_right

end Abs

end CauSeq

