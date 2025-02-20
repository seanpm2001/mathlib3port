/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Jens Wagemaker

! This file was ported from Lean 3 source module algebra.associated
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Divisibility.Basic
import Mathbin.Algebra.GroupPower.Lemmas
import Mathbin.Algebra.Parity

/-!
# Associated, prime, and irreducible elements.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


variable {α : Type _} {β : Type _} {γ : Type _} {δ : Type _}

section Prime

variable [CommMonoidWithZero α]

#print Prime /-
/-- prime element of a `comm_monoid_with_zero` -/
def Prime (p : α) : Prop :=
  p ≠ 0 ∧ ¬IsUnit p ∧ ∀ a b, p ∣ a * b → p ∣ a ∨ p ∣ b
#align prime Prime
-/

namespace Prime

variable {p : α} (hp : Prime p)

#print Prime.ne_zero /-
theorem ne_zero : p ≠ 0 :=
  hp.1
#align prime.ne_zero Prime.ne_zero
-/

#print Prime.not_unit /-
theorem not_unit : ¬IsUnit p :=
  hp.2.1
#align prime.not_unit Prime.not_unit
-/

#print Prime.not_dvd_one /-
theorem not_dvd_one : ¬p ∣ 1 :=
  mt (isUnit_of_dvd_one _) hp.not_unit
#align prime.not_dvd_one Prime.not_dvd_one
-/

#print Prime.ne_one /-
theorem ne_one : p ≠ 1 := fun h => hp.2.1 (h.symm ▸ isUnit_one)
#align prime.ne_one Prime.ne_one
-/

#print Prime.dvd_or_dvd /-
theorem dvd_or_dvd (hp : Prime p) {a b : α} (h : p ∣ a * b) : p ∣ a ∨ p ∣ b :=
  hp.2.2 a b h
#align prime.dvd_or_dvd Prime.dvd_or_dvd
-/

#print Prime.dvd_of_dvd_pow /-
theorem dvd_of_dvd_pow (hp : Prime p) {a : α} {n : ℕ} (h : p ∣ a ^ n) : p ∣ a :=
  by
  induction' n with n ih
  · rw [pow_zero] at h 
    have := isUnit_of_dvd_one _ h
    have := not_unit hp
    contradiction
  rw [pow_succ] at h 
  cases' dvd_or_dvd hp h with dvd_a dvd_pow
  · assumption
  exact ih dvd_pow
#align prime.dvd_of_dvd_pow Prime.dvd_of_dvd_pow
-/

end Prime

#print not_prime_zero /-
@[simp]
theorem not_prime_zero : ¬Prime (0 : α) := fun h => h.NeZero rfl
#align not_prime_zero not_prime_zero
-/

#print not_prime_one /-
@[simp]
theorem not_prime_one : ¬Prime (1 : α) := fun h => h.not_unit isUnit_one
#align not_prime_one not_prime_one
-/

section Map

variable [CommMonoidWithZero β] {F : Type _} {G : Type _} [MonoidWithZeroHomClass F α β]
  [MulHomClass G β α] (f : F) (g : G) {p : α}

#print comap_prime /-
theorem comap_prime (hinv : ∀ a, g (f a : β) = a) (hp : Prime (f p)) : Prime p :=
  ⟨fun h => hp.1 <| by simp [h], fun h => hp.2.1 <| h.map f, fun a b h => by
    refine' (hp.2.2 (f a) (f b) <| by convert map_dvd f h; simp).imp _ _ <;>
      · intro h; convert ← map_dvd g h <;> apply hinv⟩
#align comap_prime comap_prime
-/

#print MulEquiv.prime_iff /-
theorem MulEquiv.prime_iff (e : α ≃* β) : Prime p ↔ Prime (e p) :=
  ⟨fun h => (comap_prime e.symm e fun a => by simp) <| (e.symm_apply_apply p).substr h,
    comap_prime e e.symm fun a => by simp⟩
#align mul_equiv.prime_iff MulEquiv.prime_iff
-/

end Map

end Prime

#print Prime.left_dvd_or_dvd_right_of_dvd_mul /-
theorem Prime.left_dvd_or_dvd_right_of_dvd_mul [CancelCommMonoidWithZero α] {p : α} (hp : Prime p)
    {a b : α} : a ∣ p * b → p ∣ a ∨ a ∣ b :=
  by
  rintro ⟨c, hc⟩
  rcases hp.2.2 a c (hc ▸ dvd_mul_right _ _) with (h | ⟨x, rfl⟩)
  · exact Or.inl h
  · rw [mul_left_comm, mul_right_inj' hp.ne_zero] at hc 
    exact Or.inr (hc.symm ▸ dvd_mul_right _ _)
#align prime.left_dvd_or_dvd_right_of_dvd_mul Prime.left_dvd_or_dvd_right_of_dvd_mul
-/

#print Prime.pow_dvd_of_dvd_mul_left /-
theorem Prime.pow_dvd_of_dvd_mul_left [CancelCommMonoidWithZero α] {p a b : α} (hp : Prime p)
    (n : ℕ) (h : ¬p ∣ a) (h' : p ^ n ∣ a * b) : p ^ n ∣ b :=
  by
  induction' n with n ih
  · rw [pow_zero]; exact one_dvd b
  · obtain ⟨c, rfl⟩ := ih (dvd_trans (pow_dvd_pow p n.le_succ) h')
    rw [pow_succ']
    apply mul_dvd_mul_left _ ((hp.dvd_or_dvd _).resolve_left h)
    rwa [← mul_dvd_mul_iff_left (pow_ne_zero n hp.ne_zero), ← pow_succ', mul_left_comm]
#align prime.pow_dvd_of_dvd_mul_left Prime.pow_dvd_of_dvd_mul_left
-/

#print Prime.pow_dvd_of_dvd_mul_right /-
theorem Prime.pow_dvd_of_dvd_mul_right [CancelCommMonoidWithZero α] {p a b : α} (hp : Prime p)
    (n : ℕ) (h : ¬p ∣ b) (h' : p ^ n ∣ a * b) : p ^ n ∣ a := by rw [mul_comm] at h' ;
  exact hp.pow_dvd_of_dvd_mul_left n h h'
#align prime.pow_dvd_of_dvd_mul_right Prime.pow_dvd_of_dvd_mul_right
-/

#print Prime.dvd_of_pow_dvd_pow_mul_pow_of_square_not_dvd /-
theorem Prime.dvd_of_pow_dvd_pow_mul_pow_of_square_not_dvd [CancelCommMonoidWithZero α] {p a b : α}
    {n : ℕ} (hp : Prime p) (hpow : p ^ n.succ ∣ a ^ n.succ * b ^ n) (hb : ¬p ^ 2 ∣ b) : p ∣ a :=
  by
  -- Suppose `p ∣ b`, write `b = p * x` and `hy : a ^ n.succ * b ^ n = p ^ n.succ * y`.
  cases' hp.dvd_or_dvd ((dvd_pow_self p (Nat.succ_ne_zero n)).trans hpow) with H hbdiv
  · exact hp.dvd_of_dvd_pow H
  obtain ⟨x, rfl⟩ := hp.dvd_of_dvd_pow hbdiv
  obtain ⟨y, hy⟩ := hpow
  -- Then we can divide out a common factor of `p ^ n` from the equation `hy`.
  have : a ^ n.succ * x ^ n = p * y :=
    by
    refine' mul_left_cancel₀ (pow_ne_zero n hp.ne_zero) _
    rw [← mul_assoc _ p, ← pow_succ', ← hy, mul_pow, ← mul_assoc (a ^ n.succ), mul_comm _ (p ^ n),
      mul_assoc]
  -- So `p ∣ a` (and we're done) or `p ∣ x`, which can't be the case since it implies `p^2 ∣ b`.
  refine' hp.dvd_of_dvd_pow ((hp.dvd_or_dvd ⟨_, this⟩).resolve_right fun hdvdx => hb _)
  obtain ⟨z, rfl⟩ := hp.dvd_of_dvd_pow hdvdx
  rw [pow_two, ← mul_assoc]
  exact dvd_mul_right _ _
#align prime.dvd_of_pow_dvd_pow_mul_pow_of_square_not_dvd Prime.dvd_of_pow_dvd_pow_mul_pow_of_square_not_dvd
-/

#print prime_pow_succ_dvd_mul /-
theorem prime_pow_succ_dvd_mul {α : Type _} [CancelCommMonoidWithZero α] {p x y : α} (h : Prime p)
    {i : ℕ} (hxy : p ^ (i + 1) ∣ x * y) : p ^ (i + 1) ∣ x ∨ p ∣ y :=
  by
  rw [or_iff_not_imp_right]
  intro hy
  induction' i with i ih generalizing x
  · simp only [zero_add, pow_one] at *
    exact (h.dvd_or_dvd hxy).resolve_right hy
  rw [pow_succ] at hxy ⊢
  obtain ⟨x', rfl⟩ := (h.dvd_or_dvd (dvd_of_mul_right_dvd hxy)).resolve_right hy
  rw [mul_assoc] at hxy 
  exact mul_dvd_mul_left p (ih ((mul_dvd_mul_iff_left h.ne_zero).mp hxy))
#align prime_pow_succ_dvd_mul prime_pow_succ_dvd_mul
-/

#print Irreducible /-
/-- `irreducible p` states that `p` is non-unit and only factors into units.

We explicitly avoid stating that `p` is non-zero, this would require a semiring. Assuming only a
monoid allows us to reuse irreducible for associated elements.
-/
structure Irreducible [Monoid α] (p : α) : Prop where
  not_unit : ¬IsUnit p
  isUnit_or_is_unit' : ∀ a b, p = a * b → IsUnit a ∨ IsUnit b
#align irreducible Irreducible
-/

namespace Irreducible

#print Irreducible.not_dvd_one /-
theorem not_dvd_one [CommMonoid α] {p : α} (hp : Irreducible p) : ¬p ∣ 1 :=
  mt (isUnit_of_dvd_one _) hp.not_unit
#align irreducible.not_dvd_one Irreducible.not_dvd_one
-/

#print Irreducible.isUnit_or_isUnit /-
theorem isUnit_or_isUnit [Monoid α] {p : α} (hp : Irreducible p) {a b : α} (h : p = a * b) :
    IsUnit a ∨ IsUnit b :=
  hp.isUnit_or_is_unit' a b h
#align irreducible.is_unit_or_is_unit Irreducible.isUnit_or_isUnit
-/

end Irreducible

#print irreducible_iff /-
theorem irreducible_iff [Monoid α] {p : α} :
    Irreducible p ↔ ¬IsUnit p ∧ ∀ a b, p = a * b → IsUnit a ∨ IsUnit b :=
  ⟨fun h => ⟨h.1, h.2⟩, fun h => ⟨h.1, h.2⟩⟩
#align irreducible_iff irreducible_iff
-/

#print not_irreducible_one /-
@[simp]
theorem not_irreducible_one [Monoid α] : ¬Irreducible (1 : α) := by simp [irreducible_iff]
#align not_irreducible_one not_irreducible_one
-/

#print Irreducible.ne_one /-
theorem Irreducible.ne_one [Monoid α] : ∀ {p : α}, Irreducible p → p ≠ 1
  | _, hp, rfl => not_irreducible_one hp
#align irreducible.ne_one Irreducible.ne_one
-/

#print not_irreducible_zero /-
@[simp]
theorem not_irreducible_zero [MonoidWithZero α] : ¬Irreducible (0 : α)
  | ⟨hn0, h⟩ =>
    have : IsUnit (0 : α) ∨ IsUnit (0 : α) := h 0 0 (MulZeroClass.mul_zero 0).symm
    this.elim hn0 hn0
#align not_irreducible_zero not_irreducible_zero
-/

#print Irreducible.ne_zero /-
theorem Irreducible.ne_zero [MonoidWithZero α] : ∀ {p : α}, Irreducible p → p ≠ 0
  | _, hp, rfl => not_irreducible_zero hp
#align irreducible.ne_zero Irreducible.ne_zero
-/

#print of_irreducible_mul /-
theorem of_irreducible_mul {α} [Monoid α] {x y : α} : Irreducible (x * y) → IsUnit x ∨ IsUnit y
  | ⟨_, h⟩ => h _ _ rfl
#align of_irreducible_mul of_irreducible_mul
-/

#print of_irreducible_pow /-
theorem of_irreducible_pow {α} [Monoid α] {x : α} {n : ℕ} (hn : n ≠ 1) :
    Irreducible (x ^ n) → IsUnit x :=
  by
  obtain hn | hn := hn.lt_or_lt
  · simp only [nat.lt_one_iff.mp hn, IsEmpty.forall_iff, not_irreducible_one, pow_zero]
  intro h
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_lt hn
  rw [pow_succ, add_comm] at h 
  exact (or_iff_left_of_imp is_unit_pow_succ_iff.mp).mp (of_irreducible_mul h)
#align of_irreducible_pow of_irreducible_pow
-/

#print irreducible_or_factor /-
theorem irreducible_or_factor {α} [Monoid α] (x : α) (h : ¬IsUnit x) :
    Irreducible x ∨ ∃ a b, ¬IsUnit a ∧ ¬IsUnit b ∧ a * b = x :=
  by
  haveI := Classical.dec
  refine' or_iff_not_imp_right.2 fun H => _
  simp [h, irreducible_iff] at H ⊢
  refine' fun a b h => by_contradiction fun o => _
  simp [not_or] at o 
  exact H _ o.1 _ o.2 h.symm
#align irreducible_or_factor irreducible_or_factor
-/

#print Irreducible.dvd_symm /-
/-- If `p` and `q` are irreducible, then `p ∣ q` implies `q ∣ p`. -/
theorem Irreducible.dvd_symm [Monoid α] {p q : α} (hp : Irreducible p) (hq : Irreducible q) :
    p ∣ q → q ∣ p := by
  rintro ⟨q', rfl⟩
  rw [IsUnit.mul_right_dvd (Or.resolve_left (of_irreducible_mul hq) hp.not_unit)]
#align irreducible.dvd_symm Irreducible.dvd_symm
-/

#print Irreducible.dvd_comm /-
theorem Irreducible.dvd_comm [Monoid α] {p q : α} (hp : Irreducible p) (hq : Irreducible q) :
    p ∣ q ↔ q ∣ p :=
  ⟨hp.dvd_symm hq, hq.dvd_symm hp⟩
#align irreducible.dvd_comm Irreducible.dvd_comm
-/

section

variable [Monoid α]

#print irreducible_units_mul /-
theorem irreducible_units_mul (a : αˣ) (b : α) : Irreducible (↑a * b) ↔ Irreducible b :=
  by
  simp only [irreducible_iff, Units.isUnit_units_mul, and_congr_right_iff]
  refine' fun hu => ⟨fun h A B HAB => _, fun h A B HAB => _⟩
  · rw [← a.is_unit_units_mul]
    apply h
    rw [mul_assoc, ← HAB]
  · rw [← a⁻¹.isUnit_units_mul]
    apply h
    rw [mul_assoc, ← HAB, Units.inv_mul_cancel_left]
#align irreducible_units_mul irreducible_units_mul
-/

#print irreducible_isUnit_mul /-
theorem irreducible_isUnit_mul {a b : α} (h : IsUnit a) : Irreducible (a * b) ↔ Irreducible b :=
  let ⟨a, ha⟩ := h
  ha ▸ irreducible_units_mul a b
#align irreducible_is_unit_mul irreducible_isUnit_mul
-/

#print irreducible_mul_units /-
theorem irreducible_mul_units (a : αˣ) (b : α) : Irreducible (b * ↑a) ↔ Irreducible b :=
  by
  simp only [irreducible_iff, Units.isUnit_mul_units, and_congr_right_iff]
  refine' fun hu => ⟨fun h A B HAB => _, fun h A B HAB => _⟩
  · rw [← Units.isUnit_mul_units B a]
    apply h
    rw [← mul_assoc, ← HAB]
  · rw [← Units.isUnit_mul_units B a⁻¹]
    apply h
    rw [← mul_assoc, ← HAB, Units.mul_inv_cancel_right]
#align irreducible_mul_units irreducible_mul_units
-/

#print irreducible_mul_isUnit /-
theorem irreducible_mul_isUnit {a b : α} (h : IsUnit a) : Irreducible (b * a) ↔ Irreducible b :=
  let ⟨a, ha⟩ := h
  ha ▸ irreducible_mul_units a b
#align irreducible_mul_is_unit irreducible_mul_isUnit
-/

#print irreducible_mul_iff /-
theorem irreducible_mul_iff {a b : α} :
    Irreducible (a * b) ↔ Irreducible a ∧ IsUnit b ∨ Irreducible b ∧ IsUnit a :=
  by
  constructor
  · refine' fun h => Or.imp (fun h' => ⟨_, h'⟩) (fun h' => ⟨_, h'⟩) (h.isUnit_or_isUnit rfl).symm
    · rwa [irreducible_mul_isUnit h'] at h 
    · rwa [irreducible_isUnit_mul h'] at h 
  · rintro (⟨ha, hb⟩ | ⟨hb, ha⟩)
    · rwa [irreducible_mul_isUnit hb]
    · rwa [irreducible_isUnit_mul ha]
#align irreducible_mul_iff irreducible_mul_iff
-/

end

section CommMonoid

variable [CommMonoid α] {a : α}

#print Irreducible.not_square /-
theorem Irreducible.not_square (ha : Irreducible a) : ¬IsSquare a := by rintro ⟨b, rfl⟩;
  simp only [irreducible_mul_iff, or_self_iff] at ha ; exact ha.1.not_unit ha.2
#align irreducible.not_square Irreducible.not_square
-/

#print IsSquare.not_irreducible /-
theorem IsSquare.not_irreducible (ha : IsSquare a) : ¬Irreducible a := fun h => h.not_square ha
#align is_square.not_irreducible IsSquare.not_irreducible
-/

end CommMonoid

section CancelCommMonoidWithZero

variable [CancelCommMonoidWithZero α] {a p : α}

#print Prime.irreducible /-
protected theorem Prime.irreducible (hp : Prime p) : Irreducible p :=
  ⟨hp.not_unit, fun a b hab =>
    (show a * b ∣ a ∨ a * b ∣ b from hab ▸ hp.dvd_or_dvd (hab ▸ dvd_rfl)).elim
      (fun ⟨x, hx⟩ =>
        Or.inr
          (isUnit_iff_dvd_one.2
            ⟨x,
              mul_right_cancel₀ (show a ≠ 0 from fun h => by simp_all [Prime]) <| by
                conv =>
                    lhs
                    rw [hx] <;>
                  simp [mul_comm, mul_assoc, mul_left_comm]⟩))
      fun ⟨x, hx⟩ =>
      Or.inl
        (isUnit_iff_dvd_one.2
          ⟨x,
            mul_right_cancel₀ (show b ≠ 0 from fun h => by simp_all [Prime]) <| by
              conv =>
                  lhs
                  rw [hx] <;>
                simp [mul_comm, mul_assoc, mul_left_comm]⟩)⟩
#align prime.irreducible Prime.irreducible
-/

#print succ_dvd_or_succ_dvd_of_succ_sum_dvd_mul /-
theorem succ_dvd_or_succ_dvd_of_succ_sum_dvd_mul (hp : Prime p) {a b : α} {k l : ℕ} :
    p ^ k ∣ a → p ^ l ∣ b → p ^ (k + l + 1) ∣ a * b → p ^ (k + 1) ∣ a ∨ p ^ (l + 1) ∣ b :=
  fun ⟨x, hx⟩ ⟨y, hy⟩ ⟨z, hz⟩ =>
  have h : p ^ (k + l) * (x * y) = p ^ (k + l) * (p * z) := by
    simpa [mul_comm, pow_add, hx, hy, mul_assoc, mul_left_comm] using hz
  have hp0 : p ^ (k + l) ≠ 0 := pow_ne_zero _ hp.NeZero
  have hpd : p ∣ x * y := ⟨z, by rwa [mul_right_inj' hp0] at h ⟩
  (hp.dvd_or_dvd hpd).elim
    (fun ⟨d, hd⟩ => Or.inl ⟨d, by simp [*, pow_succ, mul_comm, mul_left_comm, mul_assoc]⟩)
    fun ⟨d, hd⟩ => Or.inr ⟨d, by simp [*, pow_succ, mul_comm, mul_left_comm, mul_assoc]⟩
#align succ_dvd_or_succ_dvd_of_succ_sum_dvd_mul succ_dvd_or_succ_dvd_of_succ_sum_dvd_mul
-/

#print Prime.not_square /-
theorem Prime.not_square (hp : Prime p) : ¬IsSquare p :=
  hp.Irreducible.not_square
#align prime.not_square Prime.not_square
-/

#print IsSquare.not_prime /-
theorem IsSquare.not_prime (ha : IsSquare a) : ¬Prime a := fun h => h.not_square ha
#align is_square.not_prime IsSquare.not_prime
-/

#print pow_not_prime /-
theorem pow_not_prime {n : ℕ} (hn : n ≠ 1) : ¬Prime (a ^ n) := fun hp =>
  hp.not_unit <| IsUnit.pow _ <| of_irreducible_pow hn <| hp.Irreducible
#align pow_not_prime pow_not_prime
-/

end CancelCommMonoidWithZero

#print Associated /-
/-- Two elements of a `monoid` are `associated` if one of them is another one
multiplied by a unit on the right. -/
def Associated [Monoid α] (x y : α) : Prop :=
  ∃ u : αˣ, x * u = y
#align associated Associated
-/

local infixl:50 " ~ᵤ " => Associated

namespace Associated

#print Associated.refl /-
@[refl]
protected theorem refl [Monoid α] (x : α) : x ~ᵤ x :=
  ⟨1, by simp⟩
#align associated.refl Associated.refl
-/

instance [Monoid α] : IsRefl α Associated :=
  ⟨Associated.refl⟩

#print Associated.symm /-
@[symm]
protected theorem symm [Monoid α] : ∀ {x y : α}, x ~ᵤ y → y ~ᵤ x
  | x, _, ⟨u, rfl⟩ => ⟨u⁻¹, by rw [mul_assoc, Units.mul_inv, mul_one]⟩
#align associated.symm Associated.symm
-/

instance [Monoid α] : IsSymm α Associated :=
  ⟨fun a b => Associated.symm⟩

#print Associated.comm /-
protected theorem comm [Monoid α] {x y : α} : x ~ᵤ y ↔ y ~ᵤ x :=
  ⟨Associated.symm, Associated.symm⟩
#align associated.comm Associated.comm
-/

#print Associated.trans /-
@[trans]
protected theorem trans [Monoid α] : ∀ {x y z : α}, x ~ᵤ y → y ~ᵤ z → x ~ᵤ z
  | x, _, _, ⟨u, rfl⟩, ⟨v, rfl⟩ => ⟨u * v, by rw [Units.val_mul, mul_assoc]⟩
#align associated.trans Associated.trans
-/

instance [Monoid α] : IsTrans α Associated :=
  ⟨fun a b c => Associated.trans⟩

#print Associated.setoid /-
/-- The setoid of the relation `x ~ᵤ y` iff there is a unit `u` such that `x * u = y` -/
protected def setoid (α : Type _) [Monoid α] : Setoid α
    where
  R := Associated
  iseqv := ⟨Associated.refl, fun a b => Associated.symm, fun a b c => Associated.trans⟩
#align associated.setoid Associated.setoid
-/

end Associated

attribute [local instance] Associated.setoid

#print unit_associated_one /-
theorem unit_associated_one [Monoid α] {u : αˣ} : (u : α) ~ᵤ 1 :=
  ⟨u⁻¹, Units.mul_inv u⟩
#align unit_associated_one unit_associated_one
-/

#print associated_one_iff_isUnit /-
theorem associated_one_iff_isUnit [Monoid α] {a : α} : (a : α) ~ᵤ 1 ↔ IsUnit a :=
  Iff.intro
    (fun h =>
      let ⟨c, h⟩ := h.symm
      h ▸ ⟨c, (one_mul _).symm⟩)
    fun ⟨c, h⟩ => Associated.symm ⟨c, by simp [h]⟩
#align associated_one_iff_is_unit associated_one_iff_isUnit
-/

#print associated_zero_iff_eq_zero /-
theorem associated_zero_iff_eq_zero [MonoidWithZero α] (a : α) : a ~ᵤ 0 ↔ a = 0 :=
  Iff.intro
    (fun h => by
      let ⟨u, h⟩ := h.symm
      simpa using h.symm)
    fun h => h ▸ Associated.refl a
#align associated_zero_iff_eq_zero associated_zero_iff_eq_zero
-/

#print associated_one_of_mul_eq_one /-
theorem associated_one_of_mul_eq_one [CommMonoid α] {a : α} (b : α) (hab : a * b = 1) : a ~ᵤ 1 :=
  show (Units.mkOfMulEqOne a b hab : α) ~ᵤ 1 from unit_associated_one
#align associated_one_of_mul_eq_one associated_one_of_mul_eq_one
-/

#print associated_one_of_associated_mul_one /-
theorem associated_one_of_associated_mul_one [CommMonoid α] {a b : α} : a * b ~ᵤ 1 → a ~ᵤ 1
  | ⟨u, h⟩ => associated_one_of_mul_eq_one (b * u) <| by simpa [mul_assoc] using h
#align associated_one_of_associated_mul_one associated_one_of_associated_mul_one
-/

#print associated_mul_unit_left /-
theorem associated_mul_unit_left {β : Type _} [Monoid β] (a u : β) (hu : IsUnit u) :
    Associated (a * u) a :=
  let ⟨u', hu⟩ := hu
  ⟨u'⁻¹, hu ▸ Units.mul_inv_cancel_right _ _⟩
#align associated_mul_unit_left associated_mul_unit_left
-/

#print associated_unit_mul_left /-
theorem associated_unit_mul_left {β : Type _} [CommMonoid β] (a u : β) (hu : IsUnit u) :
    Associated (u * a) a := by
  rw [mul_comm]
  exact associated_mul_unit_left _ _ hu
#align associated_unit_mul_left associated_unit_mul_left
-/

#print associated_mul_unit_right /-
theorem associated_mul_unit_right {β : Type _} [Monoid β] (a u : β) (hu : IsUnit u) :
    Associated a (a * u) :=
  (associated_mul_unit_left a u hu).symm
#align associated_mul_unit_right associated_mul_unit_right
-/

#print associated_unit_mul_right /-
theorem associated_unit_mul_right {β : Type _} [CommMonoid β] (a u : β) (hu : IsUnit u) :
    Associated a (u * a) :=
  (associated_unit_mul_left a u hu).symm
#align associated_unit_mul_right associated_unit_mul_right
-/

#print associated_mul_isUnit_left_iff /-
theorem associated_mul_isUnit_left_iff {β : Type _} [Monoid β] {a u b : β} (hu : IsUnit u) :
    Associated (a * u) b ↔ Associated a b :=
  ⟨trans (associated_mul_unit_right _ _ hu), trans (associated_mul_unit_left _ _ hu)⟩
#align associated_mul_is_unit_left_iff associated_mul_isUnit_left_iff
-/

#print associated_isUnit_mul_left_iff /-
theorem associated_isUnit_mul_left_iff {β : Type _} [CommMonoid β] {u a b : β} (hu : IsUnit u) :
    Associated (u * a) b ↔ Associated a b :=
  by
  rw [mul_comm]
  exact associated_mul_isUnit_left_iff hu
#align associated_is_unit_mul_left_iff associated_isUnit_mul_left_iff
-/

#print associated_mul_isUnit_right_iff /-
theorem associated_mul_isUnit_right_iff {β : Type _} [Monoid β] {a b u : β} (hu : IsUnit u) :
    Associated a (b * u) ↔ Associated a b :=
  Associated.comm.trans <| (associated_mul_isUnit_left_iff hu).trans Associated.comm
#align associated_mul_is_unit_right_iff associated_mul_isUnit_right_iff
-/

#print associated_isUnit_mul_right_iff /-
theorem associated_isUnit_mul_right_iff {β : Type _} [CommMonoid β] {a u b : β} (hu : IsUnit u) :
    Associated a (u * b) ↔ Associated a b :=
  Associated.comm.trans <| (associated_isUnit_mul_left_iff hu).trans Associated.comm
#align associated_is_unit_mul_right_iff associated_isUnit_mul_right_iff
-/

#print associated_mul_unit_left_iff /-
@[simp]
theorem associated_mul_unit_left_iff {β : Type _} [Monoid β] {a b : β} {u : Units β} :
    Associated (a * u) b ↔ Associated a b :=
  associated_mul_isUnit_left_iff u.IsUnit
#align associated_mul_unit_left_iff associated_mul_unit_left_iff
-/

#print associated_unit_mul_left_iff /-
@[simp]
theorem associated_unit_mul_left_iff {β : Type _} [CommMonoid β] {a b : β} {u : Units β} :
    Associated (↑u * a) b ↔ Associated a b :=
  associated_isUnit_mul_left_iff u.IsUnit
#align associated_unit_mul_left_iff associated_unit_mul_left_iff
-/

#print associated_mul_unit_right_iff /-
@[simp]
theorem associated_mul_unit_right_iff {β : Type _} [Monoid β] {a b : β} {u : Units β} :
    Associated a (b * u) ↔ Associated a b :=
  associated_mul_isUnit_right_iff u.IsUnit
#align associated_mul_unit_right_iff associated_mul_unit_right_iff
-/

#print associated_unit_mul_right_iff /-
@[simp]
theorem associated_unit_mul_right_iff {β : Type _} [CommMonoid β] {a b : β} {u : Units β} :
    Associated a (↑u * b) ↔ Associated a b :=
  associated_isUnit_mul_right_iff u.IsUnit
#align associated_unit_mul_right_iff associated_unit_mul_right_iff
-/

#print Associated.mul_mul /-
theorem Associated.mul_mul [CommMonoid α] {a₁ a₂ b₁ b₂ : α} :
    a₁ ~ᵤ b₁ → a₂ ~ᵤ b₂ → a₁ * a₂ ~ᵤ b₁ * b₂
  | ⟨c₁, h₁⟩, ⟨c₂, h₂⟩ => ⟨c₁ * c₂, by simp [h₁.symm, h₂.symm, mul_assoc, mul_comm, mul_left_comm]⟩
#align associated.mul_mul Associated.mul_mul
-/

#print Associated.mul_left /-
theorem Associated.mul_left [CommMonoid α] (a : α) {b c : α} (h : b ~ᵤ c) : a * b ~ᵤ a * c :=
  (Associated.refl a).mul_mul h
#align associated.mul_left Associated.mul_left
-/

#print Associated.mul_right /-
theorem Associated.mul_right [CommMonoid α] {a b : α} (h : a ~ᵤ b) (c : α) : a * c ~ᵤ b * c :=
  h.mul_mul (Associated.refl c)
#align associated.mul_right Associated.mul_right
-/

#print Associated.pow_pow /-
theorem Associated.pow_pow [CommMonoid α] {a b : α} {n : ℕ} (h : a ~ᵤ b) : a ^ n ~ᵤ b ^ n :=
  by
  induction' n with n ih; · simp [h]
  convert h.mul_mul ih <;> rw [pow_succ]
#align associated.pow_pow Associated.pow_pow
-/

#print Associated.dvd /-
protected theorem Associated.dvd [Monoid α] {a b : α} : a ~ᵤ b → a ∣ b := fun ⟨u, hu⟩ =>
  ⟨u, hu.symm⟩
#align associated.dvd Associated.dvd
-/

#print Associated.dvd_dvd /-
protected theorem Associated.dvd_dvd [Monoid α] {a b : α} (h : a ~ᵤ b) : a ∣ b ∧ b ∣ a :=
  ⟨h.Dvd, h.symm.Dvd⟩
#align associated.dvd_dvd Associated.dvd_dvd
-/

#print associated_of_dvd_dvd /-
theorem associated_of_dvd_dvd [CancelMonoidWithZero α] {a b : α} (hab : a ∣ b) (hba : b ∣ a) :
    a ~ᵤ b := by
  rcases hab with ⟨c, rfl⟩
  rcases hba with ⟨d, a_eq⟩
  by_cases ha0 : a = 0
  · simp_all
  have hac0 : a * c ≠ 0 := by intro con; rw [Con, MulZeroClass.zero_mul] at a_eq ; apply ha0 a_eq
  have : a * (c * d) = a * 1 := by rw [← mul_assoc, ← a_eq, mul_one]
  have hcd : c * d = 1 := mul_left_cancel₀ ha0 this
  have : a * c * (d * c) = a * c * 1 := by rw [← mul_assoc, ← a_eq, mul_one]
  have hdc : d * c = 1 := mul_left_cancel₀ hac0 this
  exact ⟨⟨c, d, hcd, hdc⟩, rfl⟩
#align associated_of_dvd_dvd associated_of_dvd_dvd
-/

#print dvd_dvd_iff_associated /-
theorem dvd_dvd_iff_associated [CancelMonoidWithZero α] {a b : α} : a ∣ b ∧ b ∣ a ↔ a ~ᵤ b :=
  ⟨fun ⟨h1, h2⟩ => associated_of_dvd_dvd h1 h2, Associated.dvd_dvd⟩
#align dvd_dvd_iff_associated dvd_dvd_iff_associated
-/

instance [CancelMonoidWithZero α] [DecidableRel ((· ∣ ·) : α → α → Prop)] :
    DecidableRel ((· ~ᵤ ·) : α → α → Prop) := fun a b => decidable_of_iff _ dvd_dvd_iff_associated

#print Associated.dvd_iff_dvd_left /-
theorem Associated.dvd_iff_dvd_left [Monoid α] {a b c : α} (h : a ~ᵤ b) : a ∣ c ↔ b ∣ c :=
  let ⟨u, hu⟩ := h
  hu ▸ Units.mul_right_dvd.symm
#align associated.dvd_iff_dvd_left Associated.dvd_iff_dvd_left
-/

#print Associated.dvd_iff_dvd_right /-
theorem Associated.dvd_iff_dvd_right [Monoid α] {a b c : α} (h : b ~ᵤ c) : a ∣ b ↔ a ∣ c :=
  let ⟨u, hu⟩ := h
  hu ▸ Units.dvd_mul_right.symm
#align associated.dvd_iff_dvd_right Associated.dvd_iff_dvd_right
-/

#print Associated.eq_zero_iff /-
theorem Associated.eq_zero_iff [MonoidWithZero α] {a b : α} (h : a ~ᵤ b) : a = 0 ↔ b = 0 :=
  ⟨fun ha => by
    let ⟨u, hu⟩ := h
    simp [hu.symm, ha], fun hb => by
    let ⟨u, hu⟩ := h.symm
    simp [hu.symm, hb]⟩
#align associated.eq_zero_iff Associated.eq_zero_iff
-/

#print Associated.ne_zero_iff /-
theorem Associated.ne_zero_iff [MonoidWithZero α] {a b : α} (h : a ~ᵤ b) : a ≠ 0 ↔ b ≠ 0 :=
  not_congr h.eq_zero_iff
#align associated.ne_zero_iff Associated.ne_zero_iff
-/

#print Associated.prime /-
protected theorem Associated.prime [CommMonoidWithZero α] {p q : α} (h : p ~ᵤ q) (hp : Prime p) :
    Prime q :=
  ⟨h.neZero_iff.1 hp.NeZero,
    let ⟨u, hu⟩ := h
    ⟨fun ⟨v, hv⟩ => hp.not_unit ⟨v * u⁻¹, by simp [hv, hu.symm]⟩,
      hu ▸ by simp [Units.mul_right_dvd]; intro a b; exact hp.dvd_or_dvd⟩⟩
#align associated.prime Associated.prime
-/

#print Irreducible.associated_of_dvd /-
theorem Irreducible.associated_of_dvd [CancelMonoidWithZero α] {p q : α} (p_irr : Irreducible p)
    (q_irr : Irreducible q) (dvd : p ∣ q) : Associated p q :=
  associated_of_dvd_dvd dvd (p_irr.dvd_symm q_irr dvd)
#align irreducible.associated_of_dvd Irreducible.associated_of_dvd
-/

#print Irreducible.dvd_irreducible_iff_associated /-
theorem Irreducible.dvd_irreducible_iff_associated [CancelMonoidWithZero α] {p q : α}
    (pp : Irreducible p) (qp : Irreducible q) : p ∣ q ↔ Associated p q :=
  ⟨Irreducible.associated_of_dvd pp qp, Associated.dvd⟩
#align irreducible.dvd_irreducible_iff_associated Irreducible.dvd_irreducible_iff_associated
-/

#print Prime.associated_of_dvd /-
theorem Prime.associated_of_dvd [CancelCommMonoidWithZero α] {p q : α} (p_prime : Prime p)
    (q_prime : Prime q) (dvd : p ∣ q) : Associated p q :=
  p_prime.Irreducible.associated_of_dvd q_prime.Irreducible dvd
#align prime.associated_of_dvd Prime.associated_of_dvd
-/

#print Prime.dvd_prime_iff_associated /-
theorem Prime.dvd_prime_iff_associated [CancelCommMonoidWithZero α] {p q : α} (pp : Prime p)
    (qp : Prime q) : p ∣ q ↔ Associated p q :=
  pp.Irreducible.dvd_irreducible_iff_associated qp.Irreducible
#align prime.dvd_prime_iff_associated Prime.dvd_prime_iff_associated
-/

#print Associated.prime_iff /-
theorem Associated.prime_iff [CommMonoidWithZero α] {p q : α} (h : p ~ᵤ q) : Prime p ↔ Prime q :=
  ⟨h.Prime, h.symm.Prime⟩
#align associated.prime_iff Associated.prime_iff
-/

#print Associated.isUnit /-
protected theorem Associated.isUnit [Monoid α] {a b : α} (h : a ~ᵤ b) : IsUnit a → IsUnit b :=
  let ⟨u, hu⟩ := h
  fun ⟨v, hv⟩ => ⟨v * u, by simp [hv, hu.symm]⟩
#align associated.is_unit Associated.isUnit
-/

#print Associated.isUnit_iff /-
theorem Associated.isUnit_iff [Monoid α] {a b : α} (h : a ~ᵤ b) : IsUnit a ↔ IsUnit b :=
  ⟨h.IsUnit, h.symm.IsUnit⟩
#align associated.is_unit_iff Associated.isUnit_iff
-/

#print Associated.irreducible /-
protected theorem Associated.irreducible [Monoid α] {p q : α} (h : p ~ᵤ q) (hp : Irreducible p) :
    Irreducible q :=
  ⟨mt h.symm.IsUnit hp.1,
    let ⟨u, hu⟩ := h
    fun a b hab =>
    have hpab : p = a * (b * (u⁻¹ : αˣ)) :=
      calc
        p = p * u * (u⁻¹ : αˣ) := by simp
        _ = _ := by rw [hu] <;> simp [hab, mul_assoc]
    (hp.isUnit_or_isUnit hpab).elim Or.inl fun ⟨v, hv⟩ => Or.inr ⟨v * u, by simp [hv]⟩⟩
#align associated.irreducible Associated.irreducible
-/

#print Associated.irreducible_iff /-
protected theorem Associated.irreducible_iff [Monoid α] {p q : α} (h : p ~ᵤ q) :
    Irreducible p ↔ Irreducible q :=
  ⟨h.Irreducible, h.symm.Irreducible⟩
#align associated.irreducible_iff Associated.irreducible_iff
-/

#print Associated.of_mul_left /-
theorem Associated.of_mul_left [CancelCommMonoidWithZero α] {a b c d : α} (h : a * b ~ᵤ c * d)
    (h₁ : a ~ᵤ c) (ha : a ≠ 0) : b ~ᵤ d :=
  let ⟨u, hu⟩ := h
  let ⟨v, hv⟩ := Associated.symm h₁
  ⟨u * (v : αˣ),
    mul_left_cancel₀ ha
      (by
        rw [← hv, mul_assoc c (v : α) d, mul_left_comm c, ← hu]
        simp [hv.symm, mul_assoc, mul_comm, mul_left_comm])⟩
#align associated.of_mul_left Associated.of_mul_left
-/

#print Associated.of_mul_right /-
theorem Associated.of_mul_right [CancelCommMonoidWithZero α] {a b c d : α} :
    a * b ~ᵤ c * d → b ~ᵤ d → b ≠ 0 → a ~ᵤ c := by
  rw [mul_comm a, mul_comm c] <;> exact Associated.of_mul_left
#align associated.of_mul_right Associated.of_mul_right
-/

#print Associated.of_pow_associated_of_prime /-
theorem Associated.of_pow_associated_of_prime [CancelCommMonoidWithZero α] {p₁ p₂ : α} {k₁ k₂ : ℕ}
    (hp₁ : Prime p₁) (hp₂ : Prime p₂) (hk₁ : 0 < k₁) (h : p₁ ^ k₁ ~ᵤ p₂ ^ k₂) : p₁ ~ᵤ p₂ :=
  by
  have : p₁ ∣ p₂ ^ k₂ := by
    rw [← h.dvd_iff_dvd_right]
    apply dvd_pow_self _ hk₁.ne'
  rw [← hp₁.dvd_prime_iff_associated hp₂]
  exact hp₁.dvd_of_dvd_pow this
#align associated.of_pow_associated_of_prime Associated.of_pow_associated_of_prime
-/

#print Associated.of_pow_associated_of_prime' /-
theorem Associated.of_pow_associated_of_prime' [CancelCommMonoidWithZero α] {p₁ p₂ : α} {k₁ k₂ : ℕ}
    (hp₁ : Prime p₁) (hp₂ : Prime p₂) (hk₂ : 0 < k₂) (h : p₁ ^ k₁ ~ᵤ p₂ ^ k₂) : p₁ ~ᵤ p₂ :=
  (h.symm.of_pow_associated_of_prime hp₂ hp₁ hk₂).symm
#align associated.of_pow_associated_of_prime' Associated.of_pow_associated_of_prime'
-/

section UniqueUnits

variable [Monoid α] [Unique αˣ]

#print units_eq_one /-
theorem units_eq_one (u : αˣ) : u = 1 :=
  Subsingleton.elim u 1
#align units_eq_one units_eq_one
-/

#print associated_iff_eq /-
theorem associated_iff_eq {x y : α} : x ~ᵤ y ↔ x = y :=
  by
  constructor
  · rintro ⟨c, rfl⟩; rw [units_eq_one c, Units.val_one, mul_one]
  · rintro rfl; rfl
#align associated_iff_eq associated_iff_eq
-/

#print associated_eq_eq /-
theorem associated_eq_eq : (Associated : α → α → Prop) = Eq := by ext; rw [associated_iff_eq]
#align associated_eq_eq associated_eq_eq
-/

#print prime_dvd_prime_iff_eq /-
theorem prime_dvd_prime_iff_eq {M : Type _} [CancelCommMonoidWithZero M] [Unique Mˣ] {p q : M}
    (pp : Prime p) (qp : Prime q) : p ∣ q ↔ p = q := by
  rw [pp.dvd_prime_iff_associated qp, ← associated_eq_eq]
#align prime_dvd_prime_iff_eq prime_dvd_prime_iff_eq
-/

end UniqueUnits

section UniqueUnits₀

variable {R : Type _} [CancelCommMonoidWithZero R] [Unique Rˣ] {p₁ p₂ : R} {k₁ k₂ : ℕ}

#print eq_of_prime_pow_eq /-
theorem eq_of_prime_pow_eq (hp₁ : Prime p₁) (hp₂ : Prime p₂) (hk₁ : 0 < k₁)
    (h : p₁ ^ k₁ = p₂ ^ k₂) : p₁ = p₂ := by rw [← associated_iff_eq] at h ⊢;
  apply h.of_pow_associated_of_prime hp₁ hp₂ hk₁
#align eq_of_prime_pow_eq eq_of_prime_pow_eq
-/

#print eq_of_prime_pow_eq' /-
theorem eq_of_prime_pow_eq' (hp₁ : Prime p₁) (hp₂ : Prime p₂) (hk₁ : 0 < k₂)
    (h : p₁ ^ k₁ = p₂ ^ k₂) : p₁ = p₂ := by rw [← associated_iff_eq] at h ⊢;
  apply h.of_pow_associated_of_prime' hp₁ hp₂ hk₁
#align eq_of_prime_pow_eq' eq_of_prime_pow_eq'
-/

end UniqueUnits₀

#print Associates /-
/-- The quotient of a monoid by the `associated` relation. Two elements `x` and `y`
  are associated iff there is a unit `u` such that `x * u = y`. There is a natural
  monoid structure on `associates α`. -/
def Associates (α : Type _) [Monoid α] : Type _ :=
  Quotient (Associated.setoid α)
#align associates Associates
-/

namespace Associates

open Associated

#print Associates.mk /-
/-- The canonical quotient map from a monoid `α` into the `associates` of `α` -/
protected def mk {α : Type _} [Monoid α] (a : α) : Associates α :=
  ⟦a⟧
#align associates.mk Associates.mk
-/

instance [Monoid α] : Inhabited (Associates α) :=
  ⟨⟦1⟧⟩

#print Associates.mk_eq_mk_iff_associated /-
theorem mk_eq_mk_iff_associated [Monoid α] {a b : α} : Associates.mk a = Associates.mk b ↔ a ~ᵤ b :=
  Iff.intro Quotient.exact Quot.sound
#align associates.mk_eq_mk_iff_associated Associates.mk_eq_mk_iff_associated
-/

#print Associates.quotient_mk_eq_mk /-
theorem quotient_mk_eq_mk [Monoid α] (a : α) : ⟦a⟧ = Associates.mk a :=
  rfl
#align associates.quotient_mk_eq_mk Associates.quotient_mk_eq_mk
-/

#print Associates.quot_mk_eq_mk /-
theorem quot_mk_eq_mk [Monoid α] (a : α) : Quot.mk Setoid.r a = Associates.mk a :=
  rfl
#align associates.quot_mk_eq_mk Associates.quot_mk_eq_mk
-/

#print Associates.forall_associated /-
theorem forall_associated [Monoid α] {p : Associates α → Prop} :
    (∀ a, p a) ↔ ∀ a, p (Associates.mk a) :=
  Iff.intro (fun h a => h _) fun h a => Quotient.inductionOn a h
#align associates.forall_associated Associates.forall_associated
-/

#print Associates.mk_surjective /-
theorem mk_surjective [Monoid α] : Function.Surjective (@Associates.mk α _) :=
  forall_associated.2 fun a => ⟨a, rfl⟩
#align associates.mk_surjective Associates.mk_surjective
-/

instance [Monoid α] : One (Associates α) :=
  ⟨⟦1⟧⟩

#print Associates.mk_one /-
@[simp]
theorem mk_one [Monoid α] : Associates.mk (1 : α) = 1 :=
  rfl
#align associates.mk_one Associates.mk_one
-/

#print Associates.one_eq_mk_one /-
theorem one_eq_mk_one [Monoid α] : (1 : Associates α) = Associates.mk 1 :=
  rfl
#align associates.one_eq_mk_one Associates.one_eq_mk_one
-/

instance [Monoid α] : Bot (Associates α) :=
  ⟨1⟩

#print Associates.bot_eq_one /-
theorem bot_eq_one [Monoid α] : (⊥ : Associates α) = 1 :=
  rfl
#align associates.bot_eq_one Associates.bot_eq_one
-/

#print Associates.exists_rep /-
theorem exists_rep [Monoid α] (a : Associates α) : ∃ a0 : α, Associates.mk a0 = a :=
  Quot.exists_rep a
#align associates.exists_rep Associates.exists_rep
-/

instance [Monoid α] [Subsingleton α] : Unique (Associates α)
    where
  default := 1
  uniq a := by apply Quotient.recOnSubsingleton₂; intro a b; congr

#print Associates.mk_injective /-
theorem mk_injective [Monoid α] [Unique (Units α)] : Function.Injective (@Associates.mk α _) :=
  fun a b h => associated_iff_eq.mp (Associates.mk_eq_mk_iff_associated.mp h)
#align associates.mk_injective Associates.mk_injective
-/

section CommMonoid

variable [CommMonoid α]

instance : Mul (Associates α) :=
  ⟨fun a' b' =>
    Quotient.liftOn₂ a' b' (fun a b => ⟦a * b⟧) fun a₁ a₂ b₁ b₂ ⟨c₁, h₁⟩ ⟨c₂, h₂⟩ =>
      Quotient.sound <| ⟨c₁ * c₂, by simp [h₁.symm, h₂.symm, mul_assoc, mul_comm, mul_left_comm]⟩⟩

#print Associates.mk_mul_mk /-
theorem mk_mul_mk {x y : α} : Associates.mk x * Associates.mk y = Associates.mk (x * y) :=
  rfl
#align associates.mk_mul_mk Associates.mk_mul_mk
-/

instance : CommMonoid (Associates α) where
  one := 1
  mul := (· * ·)
  mul_one a' := Quotient.inductionOn a' fun a => show ⟦a * 1⟧ = ⟦a⟧ by simp
  one_mul a' := Quotient.inductionOn a' fun a => show ⟦1 * a⟧ = ⟦a⟧ by simp
  mul_assoc a' b' c' :=
    Quotient.induction_on₃ a' b' c' fun a b c => show ⟦a * b * c⟧ = ⟦a * (b * c)⟧ by rw [mul_assoc]
  mul_comm a' b' := Quotient.induction_on₂ a' b' fun a b => show ⟦a * b⟧ = ⟦b * a⟧ by rw [mul_comm]

instance : Preorder (Associates α) where
  le := Dvd.Dvd
  le_refl := dvd_refl
  le_trans a b c := dvd_trans

#print Associates.mkMonoidHom /-
/-- `associates.mk` as a `monoid_hom`. -/
protected def mkMonoidHom : α →* Associates α :=
  ⟨Associates.mk, mk_one, fun x y => mk_mul_mk⟩
#align associates.mk_monoid_hom Associates.mkMonoidHom
-/

#print Associates.mkMonoidHom_apply /-
@[simp]
theorem mkMonoidHom_apply (a : α) : Associates.mkMonoidHom a = Associates.mk a :=
  rfl
#align associates.mk_monoid_hom_apply Associates.mkMonoidHom_apply
-/

#print Associates.associated_map_mk /-
theorem associated_map_mk {f : Associates α →* α} (hinv : Function.RightInverse f Associates.mk)
    (a : α) : a ~ᵤ f (Associates.mk a) :=
  Associates.mk_eq_mk_iff_associated.1 (hinv (Associates.mk a)).symm
#align associates.associated_map_mk Associates.associated_map_mk
-/

#print Associates.mk_pow /-
theorem mk_pow (a : α) (n : ℕ) : Associates.mk (a ^ n) = Associates.mk a ^ n := by
  induction n <;> simp [*, pow_succ, associates.mk_mul_mk.symm]
#align associates.mk_pow Associates.mk_pow
-/

#print Associates.dvd_eq_le /-
theorem dvd_eq_le : ((· ∣ ·) : Associates α → Associates α → Prop) = (· ≤ ·) :=
  rfl
#align associates.dvd_eq_le Associates.dvd_eq_le
-/

#print Associates.mul_eq_one_iff /-
theorem mul_eq_one_iff {x y : Associates α} : x * y = 1 ↔ x = 1 ∧ y = 1 :=
  Iff.intro
    (Quotient.induction_on₂ x y fun a b h =>
      have : a * b ~ᵤ 1 := Quotient.exact h
      ⟨Quotient.sound <| associated_one_of_associated_mul_one this,
        Quotient.sound <| associated_one_of_associated_mul_one <| by rwa [mul_comm] at this ⟩)
    (by simp (config := { contextual := true }))
#align associates.mul_eq_one_iff Associates.mul_eq_one_iff
-/

#print Associates.units_eq_one /-
theorem units_eq_one (u : (Associates α)ˣ) : u = 1 :=
  Units.ext (mul_eq_one_iff.1 u.val_inv).1
#align associates.units_eq_one Associates.units_eq_one
-/

#print Associates.uniqueUnits /-
instance uniqueUnits : Unique (Associates α)ˣ
    where
  default := 1
  uniq := Associates.units_eq_one
#align associates.unique_units Associates.uniqueUnits
-/

#print Associates.coe_unit_eq_one /-
theorem coe_unit_eq_one (u : (Associates α)ˣ) : (u : Associates α) = 1 := by simp
#align associates.coe_unit_eq_one Associates.coe_unit_eq_one
-/

#print Associates.isUnit_iff_eq_one /-
theorem isUnit_iff_eq_one (a : Associates α) : IsUnit a ↔ a = 1 :=
  Iff.intro (fun ⟨u, h⟩ => h ▸ coe_unit_eq_one _) fun h => h.symm ▸ isUnit_one
#align associates.is_unit_iff_eq_one Associates.isUnit_iff_eq_one
-/

#print Associates.isUnit_iff_eq_bot /-
theorem isUnit_iff_eq_bot {a : Associates α} : IsUnit a ↔ a = ⊥ := by
  rw [Associates.isUnit_iff_eq_one, bot_eq_one]
#align associates.is_unit_iff_eq_bot Associates.isUnit_iff_eq_bot
-/

#print Associates.isUnit_mk /-
theorem isUnit_mk {a : α} : IsUnit (Associates.mk a) ↔ IsUnit a :=
  calc
    IsUnit (Associates.mk a) ↔ a ~ᵤ 1 := by
      rw [is_unit_iff_eq_one, one_eq_mk_one, mk_eq_mk_iff_associated]
    _ ↔ IsUnit a := associated_one_iff_isUnit
#align associates.is_unit_mk Associates.isUnit_mk
-/

section Order

#print Associates.mul_mono /-
theorem mul_mono {a b c d : Associates α} (h₁ : a ≤ b) (h₂ : c ≤ d) : a * c ≤ b * d :=
  let ⟨x, hx⟩ := h₁
  let ⟨y, hy⟩ := h₂
  ⟨x * y, by simp [hx, hy, mul_comm, mul_assoc, mul_left_comm]⟩
#align associates.mul_mono Associates.mul_mono
-/

#print Associates.one_le /-
theorem one_le {a : Associates α} : 1 ≤ a :=
  Dvd.intro _ (one_mul a)
#align associates.one_le Associates.one_le
-/

#print Associates.le_mul_right /-
theorem le_mul_right {a b : Associates α} : a ≤ a * b :=
  ⟨b, rfl⟩
#align associates.le_mul_right Associates.le_mul_right
-/

#print Associates.le_mul_left /-
theorem le_mul_left {a b : Associates α} : a ≤ b * a := by rw [mul_comm] <;> exact le_mul_right
#align associates.le_mul_left Associates.le_mul_left
-/

instance : OrderBot (Associates α) where
  bot := 1
  bot_le a := one_le

end Order

#print Associates.dvd_of_mk_le_mk /-
theorem dvd_of_mk_le_mk {a b : α} : Associates.mk a ≤ Associates.mk b → a ∣ b
  | ⟨c', hc'⟩ =>
    (Quotient.inductionOn c' fun c hc =>
        let ⟨d, hd⟩ := (Quotient.exact hc).symm
        ⟨↑d * c,
          calc
            b = a * c * ↑d := hd.symm
            _ = a * (↑d * c) := by ac_rfl⟩)
      hc'
#align associates.dvd_of_mk_le_mk Associates.dvd_of_mk_le_mk
-/

#print Associates.mk_le_mk_of_dvd /-
theorem mk_le_mk_of_dvd {a b : α} : a ∣ b → Associates.mk a ≤ Associates.mk b := fun ⟨c, hc⟩ =>
  ⟨Associates.mk c, by simp [hc] <;> rfl⟩
#align associates.mk_le_mk_of_dvd Associates.mk_le_mk_of_dvd
-/

#print Associates.mk_le_mk_iff_dvd_iff /-
theorem mk_le_mk_iff_dvd_iff {a b : α} : Associates.mk a ≤ Associates.mk b ↔ a ∣ b :=
  Iff.intro dvd_of_mk_le_mk mk_le_mk_of_dvd
#align associates.mk_le_mk_iff_dvd_iff Associates.mk_le_mk_iff_dvd_iff
-/

#print Associates.mk_dvd_mk /-
theorem mk_dvd_mk {a b : α} : Associates.mk a ∣ Associates.mk b ↔ a ∣ b :=
  Iff.intro dvd_of_mk_le_mk mk_le_mk_of_dvd
#align associates.mk_dvd_mk Associates.mk_dvd_mk
-/

end CommMonoid

instance [Zero α] [Monoid α] : Zero (Associates α) :=
  ⟨⟦0⟧⟩

instance [Zero α] [Monoid α] : Top (Associates α) :=
  ⟨0⟩

section MonoidWithZero

variable [MonoidWithZero α]

#print Associates.mk_eq_zero /-
@[simp]
theorem mk_eq_zero {a : α} : Associates.mk a = 0 ↔ a = 0 :=
  ⟨fun h => (associated_zero_iff_eq_zero a).1 <| Quotient.exact h, fun h => h.symm ▸ rfl⟩
#align associates.mk_eq_zero Associates.mk_eq_zero
-/

#print Associates.mk_ne_zero /-
theorem mk_ne_zero {a : α} : Associates.mk a ≠ 0 ↔ a ≠ 0 :=
  not_congr mk_eq_zero
#align associates.mk_ne_zero Associates.mk_ne_zero
-/

instance [Nontrivial α] : Nontrivial (Associates α) :=
  ⟨⟨0, 1, fun h =>
      have : (0 : α) ~ᵤ 1 := Quotient.exact h
      have : (0 : α) = 1 := ((associated_zero_iff_eq_zero 1).1 this.symm).symm
      zero_ne_one this⟩⟩

#print Associates.exists_non_zero_rep /-
theorem exists_non_zero_rep {a : Associates α} : a ≠ 0 → ∃ a0 : α, a0 ≠ 0 ∧ Associates.mk a0 = a :=
  Quotient.inductionOn a fun b nz => ⟨b, mt (congr_arg Quotient.mk') nz, rfl⟩
#align associates.exists_non_zero_rep Associates.exists_non_zero_rep
-/

end MonoidWithZero

section CommMonoidWithZero

variable [CommMonoidWithZero α]

instance : CommMonoidWithZero (Associates α) :=
  { Associates.commMonoid,
    Associates.hasZero with
    zero_mul := by rintro ⟨a⟩; show Associates.mk (0 * a) = Associates.mk 0;
      rw [MulZeroClass.zero_mul]
    mul_zero := by rintro ⟨a⟩; show Associates.mk (a * 0) = Associates.mk 0;
      rw [MulZeroClass.mul_zero] }

instance : OrderTop (Associates α) where
  top := 0
  le_top a := ⟨0, (MulZeroClass.mul_zero a).symm⟩

instance : BoundedOrder (Associates α) :=
  { Associates.orderTop, Associates.orderBot with }

instance [DecidableRel ((· ∣ ·) : α → α → Prop)] :
    DecidableRel ((· ∣ ·) : Associates α → Associates α → Prop) := fun a b =>
  Quotient.recOnSubsingleton₂ a b fun a b => decidable_of_iff' _ mk_dvd_mk

#print Associates.Prime.le_or_le /-
theorem Prime.le_or_le {p : Associates α} (hp : Prime p) {a b : Associates α} (h : p ≤ a * b) :
    p ≤ a ∨ p ≤ b :=
  hp.2.2 a b h
#align associates.prime.le_or_le Associates.Prime.le_or_le
-/

#print Associates.prime_mk /-
theorem prime_mk (p : α) : Prime (Associates.mk p) ↔ Prime p :=
  by
  rw [Prime, _root_.prime, forall_associated]
  trans
  · apply and_congr; rfl
    apply and_congr; rfl
    apply forall_congr'; intro a
    exact forall_associated
  apply and_congr mk_ne_zero
  apply and_congr
  · rw [is_unit_mk]
  refine' forall₂_congr fun a b => _
  rw [mk_mul_mk, mk_dvd_mk, mk_dvd_mk, mk_dvd_mk]
#align associates.prime_mk Associates.prime_mk
-/

#print Associates.irreducible_mk /-
theorem irreducible_mk (a : α) : Irreducible (Associates.mk a) ↔ Irreducible a :=
  by
  simp only [irreducible_iff, is_unit_mk]
  apply and_congr Iff.rfl
  constructor
  · rintro h x y rfl
    simpa [is_unit_mk] using h (Associates.mk x) (Associates.mk y) rfl
  · intro h x y
    refine' Quotient.induction_on₂ x y fun x y a_eq => _
    rcases Quotient.exact a_eq.symm with ⟨u, a_eq⟩
    rw [mul_assoc] at a_eq 
    show IsUnit (Associates.mk x) ∨ IsUnit (Associates.mk y)
    simpa [is_unit_mk] using h _ _ a_eq.symm
#align associates.irreducible_mk Associates.irreducible_mk
-/

#print Associates.mk_dvdNotUnit_mk_iff /-
theorem mk_dvdNotUnit_mk_iff {a b : α} :
    DvdNotUnit (Associates.mk a) (Associates.mk b) ↔ DvdNotUnit a b :=
  by
  rw [DvdNotUnit, DvdNotUnit, mk_ne_zero]
  apply and_congr_right; intro ane0
  constructor
  · contrapose!; rw [forall_associated]
    intro h x hx hbax
    rw [mk_mul_mk, mk_eq_mk_iff_associated] at hbax 
    cases' hbax with u hu
    apply h (x * ↑u⁻¹)
    · rw [is_unit_mk] at hx 
      rw [Associated.isUnit_iff]
      apply hx
      use u
      simp
    simp [← mul_assoc, ← hu]
  · rintro ⟨x, ⟨hx, rfl⟩⟩
    use Associates.mk x
    simp [is_unit_mk, mk_mul_mk, hx]
#align associates.mk_dvd_not_unit_mk_iff Associates.mk_dvdNotUnit_mk_iff
-/

#print Associates.dvdNotUnit_of_lt /-
theorem dvdNotUnit_of_lt {a b : Associates α} (hlt : a < b) : DvdNotUnit a b :=
  by
  constructor; · rintro rfl; apply not_lt_of_le _ hlt; apply dvd_zero
  rcases hlt with ⟨⟨x, rfl⟩, ndvd⟩
  refine' ⟨x, _, rfl⟩
  contrapose! ndvd
  rcases ndvd with ⟨u, rfl⟩
  simp
#align associates.dvd_not_unit_of_lt Associates.dvdNotUnit_of_lt
-/

#print Associates.irreducible_iff_prime_iff /-
theorem irreducible_iff_prime_iff :
    (∀ a : α, Irreducible a ↔ Prime a) ↔ ∀ a : Associates α, Irreducible a ↔ Prime a := by
  simp_rw [forall_associated, irreducible_mk, prime_mk]
#align associates.irreducible_iff_prime_iff Associates.irreducible_iff_prime_iff
-/

end CommMonoidWithZero

section CancelCommMonoidWithZero

variable [CancelCommMonoidWithZero α]

instance : PartialOrder (Associates α) :=
  { Associates.preorder with
    le_antisymm := fun a' b' =>
      Quotient.induction_on₂ a' b' fun a b hab hba =>
        Quot.sound <| associated_of_dvd_dvd (dvd_of_mk_le_mk hab) (dvd_of_mk_le_mk hba) }

instance : OrderedCommMonoid (Associates α) :=
  { Associates.commMonoid, Associates.partialOrder with
    mul_le_mul_left := fun a b ⟨d, hd⟩ c => hd.symm ▸ mul_assoc c a d ▸ le_mul_right }

instance : NoZeroDivisors (Associates α) :=
  ⟨fun x y =>
    Quotient.induction_on₂ x y fun a b h =>
      have : a * b = 0 := (associated_zero_iff_eq_zero _).1 (Quotient.exact h)
      have : a = 0 ∨ b = 0 := mul_eq_zero.1 this
      this.imp (fun h => h.symm ▸ rfl) fun h => h.symm ▸ rfl⟩

instance : CancelCommMonoidWithZero (Associates α) :=
  { (inferInstance : CommMonoidWithZero (Associates α)) with
    mul_left_cancel_of_ne_zero := by
      rintro ⟨a⟩ ⟨b⟩ ⟨c⟩ ha h
      rcases Quotient.exact' h with ⟨u, hu⟩
      rw [mul_assoc] at hu 
      exact Quotient.sound' ⟨u, mul_left_cancel₀ (mk_ne_zero.1 ha) hu⟩ }

#print Associates.le_of_mul_le_mul_left /-
theorem le_of_mul_le_mul_left (a b c : Associates α) (ha : a ≠ 0) : a * b ≤ a * c → b ≤ c
  | ⟨d, hd⟩ => ⟨d, mul_left_cancel₀ ha <| by rwa [← mul_assoc]⟩
#align associates.le_of_mul_le_mul_left Associates.le_of_mul_le_mul_left
-/

#print Associates.one_or_eq_of_le_of_prime /-
theorem one_or_eq_of_le_of_prime : ∀ p m : Associates α, Prime p → m ≤ p → m = 1 ∨ m = p
  | _, m, ⟨hp0, hp1, h⟩, ⟨d, rfl⟩ =>
    match h m d dvd_rfl with
    | Or.inl h =>
      by_cases (fun this : m = 0 => by simp [this]) fun this : m ≠ 0 =>
        by
        have : m * d ≤ m * 1 := by simpa using h
        have : d ≤ 1 := Associates.le_of_mul_le_mul_left m d 1 ‹m ≠ 0› this
        have : d = 1 := bot_unique this
        simp [this]
    | Or.inr h =>
      by_cases (fun this : d = 0 => by simp [this] at hp0  <;> contradiction) fun this : d ≠ 0 =>
        have : d * m ≤ d * 1 := by simpa [mul_comm] using h
        Or.inl <| bot_unique <| Associates.le_of_mul_le_mul_left d m 1 ‹d ≠ 0› this
#align associates.one_or_eq_of_le_of_prime Associates.one_or_eq_of_le_of_prime
-/

instance : CanonicallyOrderedMonoid (Associates α) :=
  { Associates.cancelCommMonoidWithZero, Associates.boundedOrder,
    Associates.orderedCommMonoid with
    exists_mul_of_le := fun a b => id
    le_self_mul := fun a b => ⟨b, rfl⟩ }

#print Associates.dvdNotUnit_iff_lt /-
theorem dvdNotUnit_iff_lt {a b : Associates α} : DvdNotUnit a b ↔ a < b :=
  dvd_and_not_dvd_iff.symm
#align associates.dvd_not_unit_iff_lt Associates.dvdNotUnit_iff_lt
-/

#print Associates.le_one_iff /-
theorem le_one_iff {p : Associates α} : p ≤ 1 ↔ p = 1 := by rw [← Associates.bot_eq_one, le_bot_iff]
#align associates.le_one_iff Associates.le_one_iff
-/

end CancelCommMonoidWithZero

end Associates

section CommMonoidWithZero

#print DvdNotUnit.isUnit_of_irreducible_right /-
theorem DvdNotUnit.isUnit_of_irreducible_right [CommMonoidWithZero α] {p q : α} (h : DvdNotUnit p q)
    (hq : Irreducible q) : IsUnit p :=
  by
  obtain ⟨hp', x, hx, hx'⟩ := h
  exact Or.resolve_right ((irreducible_iff.1 hq).right p x hx') hx
#align dvd_not_unit.is_unit_of_irreducible_right DvdNotUnit.isUnit_of_irreducible_right
-/

#print not_irreducible_of_not_unit_dvdNotUnit /-
theorem not_irreducible_of_not_unit_dvdNotUnit [CommMonoidWithZero α] {p q : α} (hp : ¬IsUnit p)
    (h : DvdNotUnit p q) : ¬Irreducible q :=
  mt h.isUnit_of_irreducible_right hp
#align not_irreducible_of_not_unit_dvd_not_unit not_irreducible_of_not_unit_dvdNotUnit
-/

#print DvdNotUnit.not_unit /-
theorem DvdNotUnit.not_unit [CommMonoidWithZero α] {p q : α} (hp : DvdNotUnit p q) : ¬IsUnit q :=
  by
  obtain ⟨-, x, hx, rfl⟩ := hp
  exact fun hc => hx (is_unit_iff_dvd_one.mpr (dvd_of_mul_left_dvd (is_unit_iff_dvd_one.mp hc)))
#align dvd_not_unit.not_unit DvdNotUnit.not_unit
-/

#print dvdNotUnit_of_dvdNotUnit_associated /-
theorem dvdNotUnit_of_dvdNotUnit_associated [CommMonoidWithZero α] [Nontrivial α] {p q r : α}
    (h : DvdNotUnit p q) (h' : Associated q r) : DvdNotUnit p r :=
  by
  obtain ⟨u, rfl⟩ := Associated.symm h'
  obtain ⟨hp, x, hx⟩ := h
  refine' ⟨hp, x * ↑u⁻¹, DvdNotUnit.not_unit ⟨u⁻¹.NeZero, x, hx.left, mul_comm _ _⟩, _⟩
  rw [← mul_assoc, ← hx.right, mul_assoc, Units.mul_inv, mul_one]
#align dvd_not_unit_of_dvd_not_unit_associated dvdNotUnit_of_dvdNotUnit_associated
-/

end CommMonoidWithZero

section CancelCommMonoidWithZero

#print isUnit_of_associated_mul /-
theorem isUnit_of_associated_mul [CancelCommMonoidWithZero α] {p b : α} (h : Associated (p * b) p)
    (hp : p ≠ 0) : IsUnit b := by
  cases' h with a ha
  refine' isUnit_of_mul_eq_one b a ((mul_right_inj' hp).mp _)
  rwa [← mul_assoc, mul_one]
#align is_unit_of_associated_mul isUnit_of_associated_mul
-/

#print DvdNotUnit.not_associated /-
theorem DvdNotUnit.not_associated [CancelCommMonoidWithZero α] {p q : α} (h : DvdNotUnit p q) :
    ¬Associated p q := by
  rintro ⟨a, rfl⟩
  obtain ⟨hp, x, hx, hx'⟩ := h
  rcases(mul_right_inj' hp).mp hx' with rfl
  exact hx a.is_unit
#align dvd_not_unit.not_associated DvdNotUnit.not_associated
-/

#print DvdNotUnit.ne /-
theorem DvdNotUnit.ne [CancelCommMonoidWithZero α] {p q : α} (h : DvdNotUnit p q) : p ≠ q :=
  by
  by_contra hcontra
  obtain ⟨hp, x, hx', hx''⟩ := h
  conv_lhs at hx'' => rw [← hcontra, ← mul_one p]
  rw [(mul_left_cancel₀ hp hx'').symm] at hx' 
  exact hx' isUnit_one
#align dvd_not_unit.ne DvdNotUnit.ne
-/

#print pow_injective_of_not_unit /-
theorem pow_injective_of_not_unit [CancelCommMonoidWithZero α] {q : α} (hq : ¬IsUnit q)
    (hq' : q ≠ 0) : Function.Injective fun n : ℕ => q ^ n :=
  by
  refine' injective_of_lt_imp_ne fun n m h => DvdNotUnit.ne ⟨pow_ne_zero n hq', q ^ (m - n), _, _⟩
  · exact not_isUnit_of_not_isUnit_dvd hq (dvd_pow (dvd_refl _) (Nat.sub_pos_of_lt h).ne')
  · exact (pow_mul_pow_sub q h.le).symm
#align pow_injective_of_not_unit pow_injective_of_not_unit
-/

#print dvd_prime_pow /-
theorem dvd_prime_pow [CancelCommMonoidWithZero α] {p q : α} (hp : Prime p) (n : ℕ) :
    q ∣ p ^ n ↔ ∃ i ≤ n, Associated q (p ^ i) :=
  by
  induction' n with n ih generalizing q
  · simp [← isUnit_iff_dvd_one, associated_one_iff_isUnit]
  refine' ⟨fun h => _, fun ⟨i, hi, hq⟩ => hq.dvd.trans (pow_dvd_pow p hi)⟩
  rw [pow_succ] at h 
  rcases hp.left_dvd_or_dvd_right_of_dvd_mul h with (⟨q, rfl⟩ | hno)
  · rw [mul_dvd_mul_iff_left hp.ne_zero, ih] at h 
    rcases h with ⟨i, hi, hq⟩
    refine' ⟨i + 1, Nat.succ_le_succ hi, (hq.mul_left p).trans _⟩
    rw [pow_succ]
  · obtain ⟨i, hi, hq⟩ := ih.mp hno
    exact ⟨i, hi.trans n.le_succ, hq⟩
#align dvd_prime_pow dvd_prime_pow
-/

end CancelCommMonoidWithZero

assert_not_exists Multiset

