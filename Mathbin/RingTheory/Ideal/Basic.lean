/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Chris Hughes, Mario Carneiro

! This file was ported from Lean 3 source module ring_theory.ideal.basic
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Associated
import Mathbin.LinearAlgebra.Basic
import Mathbin.Order.Atoms
import Mathbin.Order.CompactlyGenerated
import Mathbin.Tactic.Abel
import Mathbin.Data.Nat.Choose.Sum
import Mathbin.LinearAlgebra.Finsupp

/-!

# Ideals over a ring

This file defines `ideal R`, the type of (left) ideals over a ring `R`.
Note that over commutative rings, left ideals and two-sided ideals are equivalent.

## Implementation notes

`ideal R` is implemented using `submodule R R`, where `•` is interpreted as `*`.

## TODO

Support right ideals, and two-sided ideals over non-commutative rings.
-/


universe u v w

variable {α : Type u} {β : Type v}

open Set Function

open Classical BigOperators Pointwise

/-- A (left) ideal in a semiring `R` is an additive submonoid `s` such that
`a * b ∈ s` whenever `b ∈ s`. If `R` is a ring, then `s` is an additive subgroup.  -/
@[reducible]
def Ideal (R : Type u) [Semiring R] :=
  Submodule R R
#align ideal Ideal

section Semiring

namespace Ideal

variable [Semiring α] (I : Ideal α) {a b : α}

protected theorem zero_mem : (0 : α) ∈ I :=
  I.zero_mem
#align ideal.zero_mem Ideal.zero_mem

protected theorem add_mem : a ∈ I → b ∈ I → a + b ∈ I :=
  I.add_mem
#align ideal.add_mem Ideal.add_mem

variable (a)

theorem mul_mem_left : b ∈ I → a * b ∈ I :=
  I.smul_mem a
#align ideal.mul_mem_left Ideal.mul_mem_left

variable {a}

@[ext]
theorem ext {I J : Ideal α} (h : ∀ x, x ∈ I ↔ x ∈ J) : I = J :=
  Submodule.ext h
#align ideal.ext Ideal.ext

theorem sum_mem (I : Ideal α) {ι : Type _} {t : Finset ι} {f : ι → α} :
    (∀ c ∈ t, f c ∈ I) → (∑ i in t, f i) ∈ I :=
  Submodule.sum_mem I
#align ideal.sum_mem Ideal.sum_mem

theorem eq_top_of_unit_mem (x y : α) (hx : x ∈ I) (h : y * x = 1) : I = ⊤ :=
  eq_top_iff.2 fun z _ =>
    calc
      z = z * (y * x) := by simp [h]
      _ = z * y * x := Eq.symm <| mul_assoc z y x
      _ ∈ I := I.mul_mem_left _ hx
      
#align ideal.eq_top_of_unit_mem Ideal.eq_top_of_unit_mem

theorem eq_top_of_is_unit_mem {x} (hx : x ∈ I) (h : IsUnit x) : I = ⊤ :=
  let ⟨y, hy⟩ := h.exists_left_inv
  eq_top_of_unit_mem I x y hx hy
#align ideal.eq_top_of_is_unit_mem Ideal.eq_top_of_is_unit_mem

theorem eq_top_iff_one : I = ⊤ ↔ (1 : α) ∈ I :=
  ⟨by rintro rfl <;> trivial, fun h => eq_top_of_unit_mem _ _ 1 h (by simp)⟩
#align ideal.eq_top_iff_one Ideal.eq_top_iff_one

theorem ne_top_iff_one : I ≠ ⊤ ↔ (1 : α) ∉ I :=
  not_congr I.eq_top_iff_one
#align ideal.ne_top_iff_one Ideal.ne_top_iff_one

@[simp]
theorem unit_mul_mem_iff_mem {x y : α} (hy : IsUnit y) : y * x ∈ I ↔ x ∈ I := by
  refine' ⟨fun h => _, fun h => I.mul_mem_left y h⟩
  obtain ⟨y', hy'⟩ := hy.exists_left_inv
  have := I.mul_mem_left y' h
  rwa [← mul_assoc, hy', one_mul] at this
#align ideal.unit_mul_mem_iff_mem Ideal.unit_mul_mem_iff_mem

/-- The ideal generated by a subset of a ring -/
def span (s : Set α) : Ideal α :=
  Submodule.span α s
#align ideal.span Ideal.span

@[simp]
theorem submodule_span_eq {s : Set α} : Submodule.span α s = Ideal.span s :=
  rfl
#align ideal.submodule_span_eq Ideal.submodule_span_eq

@[simp]
theorem span_empty : span (∅ : Set α) = ⊥ :=
  Submodule.span_empty
#align ideal.span_empty Ideal.span_empty

@[simp]
theorem span_univ : span (Set.univ : Set α) = ⊤ :=
  Submodule.span_univ
#align ideal.span_univ Ideal.span_univ

theorem span_union (s t : Set α) : span (s ∪ t) = span s ⊔ span t :=
  Submodule.span_union _ _
#align ideal.span_union Ideal.span_union

theorem span_Union {ι} (s : ι → Set α) : span (⋃ i, s i) = ⨆ i, span (s i) :=
  Submodule.span_Union _
#align ideal.span_Union Ideal.span_Union

theorem mem_span {s : Set α} (x) : x ∈ span s ↔ ∀ p : Ideal α, s ⊆ p → x ∈ p :=
  mem_Inter₂
#align ideal.mem_span Ideal.mem_span

theorem subset_span {s : Set α} : s ⊆ span s :=
  Submodule.subset_span
#align ideal.subset_span Ideal.subset_span

theorem span_le {s : Set α} {I} : span s ≤ I ↔ s ⊆ I :=
  Submodule.span_le
#align ideal.span_le Ideal.span_le

theorem span_mono {s t : Set α} : s ⊆ t → span s ≤ span t :=
  Submodule.span_mono
#align ideal.span_mono Ideal.span_mono

@[simp]
theorem span_eq : span (I : Set α) = I :=
  Submodule.span_eq _
#align ideal.span_eq Ideal.span_eq

@[simp]
theorem span_singleton_one : span ({1} : Set α) = ⊤ :=
  (eq_top_iff_one _).2 <| subset_span <| mem_singleton _
#align ideal.span_singleton_one Ideal.span_singleton_one

theorem mem_span_insert {s : Set α} {x y} :
    x ∈ span (insert y s) ↔ ∃ a, ∃ z ∈ span s, x = a * y + z :=
  Submodule.mem_span_insert
#align ideal.mem_span_insert Ideal.mem_span_insert

theorem mem_span_singleton' {x y : α} : x ∈ span ({y} : Set α) ↔ ∃ a, a * y = x :=
  Submodule.mem_span_singleton
#align ideal.mem_span_singleton' Ideal.mem_span_singleton'

theorem span_singleton_le_iff_mem {x : α} : span {x} ≤ I ↔ x ∈ I :=
  Submodule.span_singleton_le_iff_mem _ _
#align ideal.span_singleton_le_iff_mem Ideal.span_singleton_le_iff_mem

theorem span_insert (x) (s : Set α) : span (insert x s) = span ({x} : Set α) ⊔ span s :=
  Submodule.span_insert x s
#align ideal.span_insert Ideal.span_insert

theorem span_eq_bot {s : Set α} : span s = ⊥ ↔ ∀ x ∈ s, (x : α) = 0 :=
  Submodule.span_eq_bot
#align ideal.span_eq_bot Ideal.span_eq_bot

@[simp]
theorem span_singleton_eq_bot {x} : span ({x} : Set α) = ⊥ ↔ x = 0 :=
  Submodule.span_singleton_eq_bot
#align ideal.span_singleton_eq_bot Ideal.span_singleton_eq_bot

theorem span_singleton_ne_top {α : Type _} [CommSemiring α] {x : α} (hx : ¬IsUnit x) :
    Ideal.span ({x} : Set α) ≠ ⊤ :=
  (Ideal.ne_top_iff_one _).mpr fun h1 =>
    let ⟨y, hy⟩ := Ideal.mem_span_singleton'.mp h1
    hx ⟨⟨x, y, mul_comm y x ▸ hy, hy⟩, rfl⟩
#align ideal.span_singleton_ne_top Ideal.span_singleton_ne_top

@[simp]
theorem span_zero : span (0 : Set α) = ⊥ := by rw [← Set.singleton_zero, span_singleton_eq_bot]
#align ideal.span_zero Ideal.span_zero

@[simp]
theorem span_one : span (1 : Set α) = ⊤ := by rw [← Set.singleton_one, span_singleton_one]
#align ideal.span_one Ideal.span_one

theorem span_eq_top_iff_finite (s : Set α) :
    span s = ⊤ ↔ ∃ s' : Finset α, ↑s' ⊆ s ∧ span (s' : Set α) = ⊤ := by
  simp_rw [eq_top_iff_one]
  exact ⟨Submodule.mem_span_finite_of_mem_span, fun ⟨s', h₁, h₂⟩ => span_mono h₁ h₂⟩
#align ideal.span_eq_top_iff_finite Ideal.span_eq_top_iff_finite

theorem mem_span_singleton_sup {S : Type _} [CommSemiring S] {x y : S} {I : Ideal S} :
    x ∈ Ideal.span {y} ⊔ I ↔ ∃ a : S, ∃ b ∈ I, a * y + b = x := by
  rw [Submodule.mem_sup]
  constructor
  · rintro ⟨ya, hya, b, hb, rfl⟩
    obtain ⟨a, rfl⟩ := mem_span_singleton'.mp hya
    exact ⟨a, b, hb, rfl⟩
  · rintro ⟨a, b, hb, rfl⟩
    exact ⟨a * y, ideal.mem_span_singleton'.mpr ⟨a, rfl⟩, b, hb, rfl⟩
#align ideal.mem_span_singleton_sup Ideal.mem_span_singleton_sup

/-- The ideal generated by an arbitrary binary relation.
-/
def ofRel (r : α → α → Prop) : Ideal α :=
  Submodule.span α { x | ∃ (a b : _)(h : r a b), x + b = a }
#align ideal.of_rel Ideal.ofRel

/-- An ideal `P` of a ring `R` is prime if `P ≠ R` and `xy ∈ P → x ∈ P ∨ y ∈ P` -/
class IsPrime (I : Ideal α) : Prop where
  ne_top' : I ≠ ⊤
  mem_or_mem' : ∀ {x y : α}, x * y ∈ I → x ∈ I ∨ y ∈ I
#align ideal.is_prime Ideal.IsPrime

theorem is_prime_iff {I : Ideal α} : IsPrime I ↔ I ≠ ⊤ ∧ ∀ {x y : α}, x * y ∈ I → x ∈ I ∨ y ∈ I :=
  ⟨fun h => ⟨h.1, fun _ _ => h.2⟩, fun h => ⟨h.1, fun _ _ => h.2⟩⟩
#align ideal.is_prime_iff Ideal.is_prime_iff

theorem IsPrime.ne_top {I : Ideal α} (hI : I.IsPrime) : I ≠ ⊤ :=
  hI.1
#align ideal.is_prime.ne_top Ideal.IsPrime.ne_top

theorem IsPrime.mem_or_mem {I : Ideal α} (hI : I.IsPrime) {x y : α} : x * y ∈ I → x ∈ I ∨ y ∈ I :=
  hI.2
#align ideal.is_prime.mem_or_mem Ideal.IsPrime.mem_or_mem

theorem IsPrime.mem_or_mem_of_mul_eq_zero {I : Ideal α} (hI : I.IsPrime) {x y : α} (h : x * y = 0) :
    x ∈ I ∨ y ∈ I :=
  hI.mem_or_mem (h.symm ▸ I.zero_mem)
#align ideal.is_prime.mem_or_mem_of_mul_eq_zero Ideal.IsPrime.mem_or_mem_of_mul_eq_zero

theorem IsPrime.mem_of_pow_mem {I : Ideal α} (hI : I.IsPrime) {r : α} (n : ℕ) (H : r ^ n ∈ I) :
    r ∈ I := by 
  induction' n with n ih
  · rw [pow_zero] at H
    exact (mt (eq_top_iff_one _).2 hI.1).elim H
  · rw [pow_succ] at H
    exact Or.cases_on (hI.mem_or_mem H) id ih
#align ideal.is_prime.mem_of_pow_mem Ideal.IsPrime.mem_of_pow_mem

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (x «expr ∉ » I) -/
/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (y «expr ∉ » I) -/
theorem not_is_prime_iff {I : Ideal α} :
    ¬I.IsPrime ↔ I = ⊤ ∨ ∃ (x : _)(_ : x ∉ I)(y : _)(_ : y ∉ I), x * y ∈ I := by
  simp_rw [Ideal.is_prime_iff, not_and_or, Ne.def, not_not, not_forall, not_or]
  exact
    or_congr Iff.rfl
      ⟨fun ⟨x, y, hxy, hx, hy⟩ => ⟨x, hx, y, hy, hxy⟩, fun ⟨x, hx, y, hy, hxy⟩ =>
        ⟨x, y, hxy, hx, hy⟩⟩
#align ideal.not_is_prime_iff Ideal.not_is_prime_iff

theorem zero_ne_one_of_proper {I : Ideal α} (h : I ≠ ⊤) : (0 : α) ≠ 1 := fun hz =>
  I.ne_top_iff_one.1 h <| hz ▸ I.zero_mem
#align ideal.zero_ne_one_of_proper Ideal.zero_ne_one_of_proper

theorem bot_prime {R : Type _} [Ring R] [IsDomain R] : (⊥ : Ideal R).IsPrime :=
  ⟨fun h => one_ne_zero (by rwa [Ideal.eq_top_iff_one, Submodule.mem_bot] at h), fun x y h =>
    mul_eq_zero.mp (by simpa only [Submodule.mem_bot] using h)⟩
#align ideal.bot_prime Ideal.bot_prime

/-- An ideal is maximal if it is maximal in the collection of proper ideals. -/
class IsMaximal (I : Ideal α) : Prop where
  out : IsCoatom I
#align ideal.is_maximal Ideal.IsMaximal

theorem is_maximal_def {I : Ideal α} : I.IsMaximal ↔ IsCoatom I :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩
#align ideal.is_maximal_def Ideal.is_maximal_def

theorem IsMaximal.ne_top {I : Ideal α} (h : I.IsMaximal) : I ≠ ⊤ :=
  (is_maximal_def.1 h).1
#align ideal.is_maximal.ne_top Ideal.IsMaximal.ne_top

theorem is_maximal_iff {I : Ideal α} :
    I.IsMaximal ↔ (1 : α) ∉ I ∧ ∀ (J : Ideal α) (x), I ≤ J → x ∉ I → x ∈ J → (1 : α) ∈ J :=
  is_maximal_def.trans <|
    and_congr I.ne_top_iff_one <|
      forall_congr' fun J => by
        rw [lt_iff_le_not_le] <;>
          exact
            ⟨fun H x h hx₁ hx₂ => J.eq_top_iff_one.1 <| H ⟨h, not_subset.2 ⟨_, hx₂, hx₁⟩⟩,
              fun H ⟨h₁, h₂⟩ =>
              let ⟨x, xJ, xI⟩ := not_subset.1 h₂
              J.eq_top_iff_one.2 <| H x h₁ xI xJ⟩
#align ideal.is_maximal_iff Ideal.is_maximal_iff

theorem IsMaximal.eq_of_le {I J : Ideal α} (hI : I.IsMaximal) (hJ : J ≠ ⊤) (IJ : I ≤ J) : I = J :=
  eq_iff_le_not_lt.2 ⟨IJ, fun h => hJ (hI.1.2 _ h)⟩
#align ideal.is_maximal.eq_of_le Ideal.IsMaximal.eq_of_le

instance : IsCoatomic (Ideal α) := by
  apply CompleteLattice.coatomic_of_top_compact
  rw [← span_singleton_one]
  exact Submodule.singletonSpanIsCompactElement 1

/-- **Krull's theorem**: if `I` is an ideal that is not the whole ring, then it is included in some
    maximal ideal. -/
theorem exists_le_maximal (I : Ideal α) (hI : I ≠ ⊤) : ∃ M : Ideal α, M.IsMaximal ∧ I ≤ M :=
  let ⟨m, hm⟩ := (eq_top_or_exists_le_coatom I).resolve_left hI
  ⟨m, ⟨⟨hm.1⟩, hm.2⟩⟩
#align ideal.exists_le_maximal Ideal.exists_le_maximal

variable (α)

/-- Krull's theorem: a nontrivial ring has a maximal ideal. -/
theorem exists_maximal [Nontrivial α] : ∃ M : Ideal α, M.IsMaximal :=
  let ⟨I, ⟨hI, _⟩⟩ := exists_le_maximal (⊥ : Ideal α) bot_ne_top
  ⟨I, hI⟩
#align ideal.exists_maximal Ideal.exists_maximal

variable {α}

instance [Nontrivial α] : Nontrivial (Ideal α) := by
  rcases@exists_maximal α _ _ with ⟨M, hM, _⟩
  exact nontrivial_of_ne M ⊤ hM

/-- If P is not properly contained in any maximal ideal then it is not properly contained
  in any proper ideal -/
theorem maximal_of_no_maximal {R : Type u} [Semiring R] {P : Ideal R}
    (hmax : ∀ m : Ideal R, P < m → ¬IsMaximal m) (J : Ideal R) (hPJ : P < J) : J = ⊤ := by
  by_contra hnonmax
  rcases exists_le_maximal J hnonmax with ⟨M, hM1, hM2⟩
  exact hmax M (lt_of_lt_of_le hPJ hM2) hM1
#align ideal.maximal_of_no_maximal Ideal.maximal_of_no_maximal

theorem mem_span_pair {x y z : α} : z ∈ span ({x, y} : Set α) ↔ ∃ a b, a * x + b * y = z := by
  simp [mem_span_insert, mem_span_singleton', @eq_comm _ _ z]
#align ideal.mem_span_pair Ideal.mem_span_pair

theorem IsMaximal.exists_inv {I : Ideal α} (hI : I.IsMaximal) {x} (hx : x ∉ I) :
    ∃ y, ∃ i ∈ I, y * x + i = 1 := by
  cases' is_maximal_iff.1 hI with H₁ H₂
  rcases mem_span_insert.1
      (H₂ (span (insert x I)) x (Set.Subset.trans (subset_insert _ _) subset_span) hx
        (subset_span (mem_insert _ _))) with
    ⟨y, z, hz, hy⟩
  refine' ⟨y, z, _, hy.symm⟩
  rwa [← span_eq I]
#align ideal.is_maximal.exists_inv Ideal.IsMaximal.exists_inv

section Lattice

variable {R : Type u} [Semiring R]

theorem mem_sup_left {S T : Ideal R} : ∀ {x : R}, x ∈ S → x ∈ S ⊔ T :=
  show S ≤ S ⊔ T from le_sup_left
#align ideal.mem_sup_left Ideal.mem_sup_left

theorem mem_sup_right {S T : Ideal R} : ∀ {x : R}, x ∈ T → x ∈ S ⊔ T :=
  show T ≤ S ⊔ T from le_sup_right
#align ideal.mem_sup_right Ideal.mem_sup_right

theorem mem_supr_of_mem {ι : Sort _} {S : ι → Ideal R} (i : ι) : ∀ {x : R}, x ∈ S i → x ∈ supr S :=
  show S i ≤ supr S from le_supr _ _
#align ideal.mem_supr_of_mem Ideal.mem_supr_of_mem

theorem mem_Sup_of_mem {S : Set (Ideal R)} {s : Ideal R} (hs : s ∈ S) :
    ∀ {x : R}, x ∈ s → x ∈ sup S :=
  show s ≤ sup S from le_Sup hs
#align ideal.mem_Sup_of_mem Ideal.mem_Sup_of_mem

theorem mem_Inf {s : Set (Ideal R)} {x : R} : x ∈ inf s ↔ ∀ ⦃I⦄, I ∈ s → x ∈ I :=
  ⟨fun hx I his => hx I ⟨I, infi_pos his⟩, fun H I ⟨J, hij⟩ => hij ▸ fun S ⟨hj, hS⟩ => hS ▸ H hj⟩
#align ideal.mem_Inf Ideal.mem_Inf

@[simp]
theorem mem_inf {I J : Ideal R} {x : R} : x ∈ I ⊓ J ↔ x ∈ I ∧ x ∈ J :=
  Iff.rfl
#align ideal.mem_inf Ideal.mem_inf

@[simp]
theorem mem_infi {ι : Sort _} {I : ι → Ideal R} {x : R} : x ∈ infi I ↔ ∀ i, x ∈ I i :=
  Submodule.mem_infi _
#align ideal.mem_infi Ideal.mem_infi

@[simp]
theorem mem_bot {x : R} : x ∈ (⊥ : Ideal R) ↔ x = 0 :=
  Submodule.mem_bot _
#align ideal.mem_bot Ideal.mem_bot

end Lattice

section Pi

variable (ι : Type v)

/-- `I^n` as an ideal of `R^n`. -/
def pi : Ideal (ι → α) where 
  carrier := { x | ∀ i, x i ∈ I }
  zero_mem' i := I.zero_mem
  add_mem' a b ha hb i := I.add_mem (ha i) (hb i)
  smul_mem' a b hb i := I.mul_mem_left (a i) (hb i)
#align ideal.pi Ideal.pi

theorem mem_pi (x : ι → α) : x ∈ I.pi ι ↔ ∀ i, x i ∈ I :=
  Iff.rfl
#align ideal.mem_pi Ideal.mem_pi

end Pi

theorem Inf_is_prime_of_is_chain {s : Set (Ideal α)} (hs : s.Nonempty) (hs' : IsChain (· ≤ ·) s)
    (H : ∀ p ∈ s, Ideal.IsPrime p) : (inf s).IsPrime :=
  ⟨fun e =>
    let ⟨x, hx⟩ := hs
    (H x hx).ne_top (eq_top_iff.mpr (e.symm.trans_le (Inf_le hx))),
    fun x y e =>
    or_iff_not_imp_left.mpr fun hx => by
      rw [Ideal.mem_Inf] at hx e⊢
      push_neg  at hx
      obtain ⟨I, hI, hI'⟩ := hx
      intro J hJ
      cases hs'.total hI hJ
      · exact h (((H I hI).mem_or_mem (e hI)).resolve_left hI')
      · exact ((H J hJ).mem_or_mem (e hJ)).resolve_left fun x => hI' <| h x⟩
#align ideal.Inf_is_prime_of_is_chain Ideal.Inf_is_prime_of_is_chain

end Ideal

end Semiring

section CommSemiring

variable {a b : α}

-- A separate namespace definition is needed because the variables were historically in a different
-- order.
namespace Ideal

variable [CommSemiring α] (I : Ideal α)

@[simp]
theorem mul_unit_mem_iff_mem {x y : α} (hy : IsUnit y) : x * y ∈ I ↔ x ∈ I :=
  mul_comm y x ▸ unit_mul_mem_iff_mem I hy
#align ideal.mul_unit_mem_iff_mem Ideal.mul_unit_mem_iff_mem

theorem mem_span_singleton {x y : α} : x ∈ span ({y} : Set α) ↔ y ∣ x :=
  mem_span_singleton'.trans <| exists_congr fun _ => by rw [eq_comm, mul_comm]
#align ideal.mem_span_singleton Ideal.mem_span_singleton

theorem span_singleton_le_span_singleton {x y : α} :
    span ({x} : Set α) ≤ span ({y} : Set α) ↔ y ∣ x :=
  span_le.trans <| singleton_subset_iff.trans mem_span_singleton
#align ideal.span_singleton_le_span_singleton Ideal.span_singleton_le_span_singleton

theorem span_singleton_eq_span_singleton {α : Type u} [CommRing α] [IsDomain α] {x y : α} :
    span ({x} : Set α) = span ({y} : Set α) ↔ Associated x y := by
  rw [← dvd_dvd_iff_associated, le_antisymm_iff, and_comm']
  apply and_congr <;> rw [span_singleton_le_span_singleton]
#align ideal.span_singleton_eq_span_singleton Ideal.span_singleton_eq_span_singleton

theorem span_singleton_mul_right_unit {a : α} (h2 : IsUnit a) (x : α) :
    span ({x * a} : Set α) = span {x} := by
  apply le_antisymm
  · rw [span_singleton_le_span_singleton]
    use a
  · rw [span_singleton_le_span_singleton]
    rw [IsUnit.mul_right_dvd h2]
#align ideal.span_singleton_mul_right_unit Ideal.span_singleton_mul_right_unit

theorem span_singleton_mul_left_unit {a : α} (h2 : IsUnit a) (x : α) :
    span ({a * x} : Set α) = span {x} := by rw [mul_comm, span_singleton_mul_right_unit h2]
#align ideal.span_singleton_mul_left_unit Ideal.span_singleton_mul_left_unit

theorem span_singleton_eq_top {x} : span ({x} : Set α) = ⊤ ↔ IsUnit x := by
  rw [isUnit_iff_dvd_one, ← span_singleton_le_span_singleton, span_singleton_one, eq_top_iff]
#align ideal.span_singleton_eq_top Ideal.span_singleton_eq_top

theorem span_singleton_prime {p : α} (hp : p ≠ 0) : IsPrime (span ({p} : Set α)) ↔ Prime p := by
  simp [is_prime_iff, Prime, span_singleton_eq_top, hp, mem_span_singleton]
#align ideal.span_singleton_prime Ideal.span_singleton_prime

theorem IsMaximal.is_prime {I : Ideal α} (H : I.IsMaximal) : I.IsPrime :=
  ⟨H.1.1, fun x y hxy =>
    or_iff_not_imp_left.2 fun hx => by
      let J : Ideal α := Submodule.span α (insert x ↑I)
      have IJ : I ≤ J := Set.Subset.trans (subset_insert _ _) subset_span
      have xJ : x ∈ J := Ideal.subset_span (Set.mem_insert x I)
      cases' is_maximal_iff.1 H with _ oJ
      specialize oJ J x IJ hx xJ
      rcases submodule.mem_span_insert.mp oJ with ⟨a, b, h, oe⟩
      obtain F : y * 1 = y * (a • x + b) := congr_arg (fun g : α => y * g) oe
      rw [← mul_one y, F, mul_add, mul_comm, smul_eq_mul, mul_assoc]
      refine' Submodule.add_mem I (I.mul_mem_left a hxy) (Submodule.smul_mem I y _)
      rwa [Submodule.span_eq] at h⟩
#align ideal.is_maximal.is_prime Ideal.IsMaximal.is_prime

-- see Note [lower instance priority]
instance (priority := 100) IsMaximal.is_prime' (I : Ideal α) : ∀ [H : I.IsMaximal], I.IsPrime :=
  is_maximal.is_prime
#align ideal.is_maximal.is_prime' Ideal.IsMaximal.is_prime'

theorem span_singleton_lt_span_singleton [CommRing β] [IsDomain β] {x y : β} :
    span ({x} : Set β) < span ({y} : Set β) ↔ DvdNotUnit y x := by
  rw [lt_iff_le_not_le, span_singleton_le_span_singleton, span_singleton_le_span_singleton,
    dvd_and_not_dvd_iff]
#align ideal.span_singleton_lt_span_singleton Ideal.span_singleton_lt_span_singleton

theorem factors_decreasing [CommRing β] [IsDomain β] (b₁ b₂ : β) (h₁ : b₁ ≠ 0) (h₂ : ¬IsUnit b₂) :
    span ({b₁ * b₂} : Set β) < span {b₁} :=
  (lt_of_le_not_le
      (Ideal.span_le.2 <| singleton_subset_iff.2 <| Ideal.mem_span_singleton.2 ⟨b₂, rfl⟩))
    fun h =>
    h₂ <|
      isUnit_of_dvd_one _ <|
        (mul_dvd_mul_iff_left h₁).1 <| by rwa [mul_one, ← Ideal.span_singleton_le_span_singleton]
#align ideal.factors_decreasing Ideal.factors_decreasing

variable (b)

theorem mul_mem_right (h : a ∈ I) : a * b ∈ I :=
  mul_comm b a ▸ I.mul_mem_left b h
#align ideal.mul_mem_right Ideal.mul_mem_right

variable {b}

theorem pow_mem_of_mem (ha : a ∈ I) (n : ℕ) (hn : 0 < n) : a ^ n ∈ I :=
  Nat.casesOn n (Not.elim (by decide))
    (fun m hm => (pow_succ a m).symm ▸ I.mul_mem_right (a ^ m) ha) hn
#align ideal.pow_mem_of_mem Ideal.pow_mem_of_mem

theorem IsPrime.mul_mem_iff_mem_or_mem {I : Ideal α} (hI : I.IsPrime) :
    ∀ {x y : α}, x * y ∈ I ↔ x ∈ I ∨ y ∈ I := fun x y =>
  ⟨hI.mem_or_mem, by 
    rintro (h | h)
    exacts[I.mul_mem_right y h, I.mul_mem_left x h]⟩
#align ideal.is_prime.mul_mem_iff_mem_or_mem Ideal.IsPrime.mul_mem_iff_mem_or_mem

theorem IsPrime.pow_mem_iff_mem {I : Ideal α} (hI : I.IsPrime) {r : α} (n : ℕ) (hn : 0 < n) :
    r ^ n ∈ I ↔ r ∈ I :=
  ⟨hI.mem_of_pow_mem n, fun hr => I.pow_mem_of_mem hr n hn⟩
#align ideal.is_prime.pow_mem_iff_mem Ideal.IsPrime.pow_mem_iff_mem

theorem pow_multiset_sum_mem_span_pow (s : Multiset α) (n : ℕ) :
    s.Sum ^ (s.card * n + 1) ∈ span ((s.map fun x => x ^ (n + 1)).toFinset : Set α) := by
  induction' s using Multiset.induction_on with a s hs
  · simp
  simp only [Finset.coe_insert, Multiset.map_cons, Multiset.to_finset_cons, Multiset.sum_cons,
    Multiset.card_cons, add_pow]
  refine' Submodule.sum_mem _ _
  intro c hc
  rw [mem_span_insert]
  by_cases h : n + 1 ≤ c
  · refine'
      ⟨a ^ (c - (n + 1)) * s.sum ^ ((s.card + 1) * n + 1 - c) * ((s.card + 1) * n + 1).choose c, 0,
        Submodule.zero_mem _, _⟩
    rw [mul_comm _ (a ^ (n + 1))]
    simp_rw [← mul_assoc]
    rw [← pow_add, add_zero, add_tsub_cancel_of_le h]
  · use 0
    simp_rw [zero_mul, zero_add]
    refine' ⟨_, _, rfl⟩
    replace h : c ≤ n := nat.lt_succ_iff.mp (not_le.mp h)
    have : (s.card + 1) * n + 1 - c = s.card * n + 1 + (n - c) := by
      rw [add_mul, one_mul, add_assoc, add_comm n 1, ← add_assoc, add_tsub_assoc_of_le h]
    rw [this, pow_add]
    simp_rw [mul_assoc, mul_comm (s.sum ^ (s.card * n + 1)), ← mul_assoc]
    exact mul_mem_left _ _ hs
#align ideal.pow_multiset_sum_mem_span_pow Ideal.pow_multiset_sum_mem_span_pow

theorem sum_pow_mem_span_pow {ι} (s : Finset ι) (f : ι → α) (n : ℕ) :
    (∑ i in s, f i) ^ (s.card * n + 1) ∈ span ((fun i => f i ^ (n + 1)) '' s) := by
  convert pow_multiset_sum_mem_span_pow (s.1.map f) n
  · rw [Multiset.card_map]
    rfl
  rw [Multiset.map_map, Multiset.to_finset_map, Finset.val_to_finset, Finset.coe_image]
#align ideal.sum_pow_mem_span_pow Ideal.sum_pow_mem_span_pow

theorem span_pow_eq_top (s : Set α) (hs : span s = ⊤) (n : ℕ) : span ((fun x => x ^ n) '' s) = ⊤ :=
  by 
  rw [eq_top_iff_one]
  cases n
  · obtain rfl | ⟨x, hx⟩ := eq_empty_or_nonempty s
    · rw [Set.image_empty, hs]
      trivial
    · exact subset_span ⟨_, hx, pow_zero _⟩
  rw [eq_top_iff_one, span, Finsupp.mem_span_iff_total] at hs
  rcases hs with ⟨f, hf⟩
  change (f.support.sum fun a => f a * a) = 1 at hf
  have := sum_pow_mem_span_pow f.support (fun a => f a * a) n
  rw [hf, one_pow] at this
  refine' span_le.mpr _ this
  rintro _ hx
  simp_rw [Finset.mem_coe, Set.mem_image] at hx
  rcases hx with ⟨x, hx, rfl⟩
  have : span ({x ^ (n + 1)} : Set α) ≤ span ((fun x : α => x ^ (n + 1)) '' s) := by
    rw [span_le, Set.singleton_subset_iff]
    exact subset_span ⟨x, x.prop, rfl⟩
  refine' this _
  rw [mul_pow, mem_span_singleton]
  exact ⟨f x ^ (n + 1), mul_comm _ _⟩
#align ideal.span_pow_eq_top Ideal.span_pow_eq_top

end Ideal

end CommSemiring

section Ring

namespace Ideal

variable [Ring α] (I : Ideal α) {a b : α}

protected theorem neg_mem_iff : -a ∈ I ↔ a ∈ I :=
  neg_mem_iff
#align ideal.neg_mem_iff Ideal.neg_mem_iff

protected theorem add_mem_iff_left : b ∈ I → (a + b ∈ I ↔ a ∈ I) :=
  I.add_mem_iff_left
#align ideal.add_mem_iff_left Ideal.add_mem_iff_left

protected theorem add_mem_iff_right : a ∈ I → (a + b ∈ I ↔ b ∈ I) :=
  I.add_mem_iff_right
#align ideal.add_mem_iff_right Ideal.add_mem_iff_right

protected theorem sub_mem : a ∈ I → b ∈ I → a - b ∈ I :=
  sub_mem
#align ideal.sub_mem Ideal.sub_mem

theorem mem_span_insert' {s : Set α} {x y} : x ∈ span (insert y s) ↔ ∃ a, x + a * y ∈ span s :=
  Submodule.mem_span_insert'
#align ideal.mem_span_insert' Ideal.mem_span_insert'

end Ideal

end Ring

section DivisionRing

variable {K : Type u} [DivisionRing K] (I : Ideal K)

namespace Ideal

/-- All ideals in a division ring are trivial. -/
theorem eq_bot_or_top : I = ⊥ ∨ I = ⊤ := by
  rw [or_iff_not_imp_right]
  change _ ≠ _ → _
  rw [Ideal.ne_top_iff_one]
  intro h1
  rw [eq_bot_iff]
  intro r hr
  by_cases H : r = 0; · simpa
  simpa [H, h1] using I.mul_mem_left r⁻¹ hr
#align ideal.eq_bot_or_top Ideal.eq_bot_or_top

/-- Ideals of a `division_ring` are a simple order. Thanks to the way abbreviations work, this
automatically gives a `is_simple_module K` instance. -/
instance : IsSimpleOrder (Ideal K) :=
  ⟨eq_bot_or_top⟩

theorem eq_bot_of_prime [h : I.IsPrime] : I = ⊥ :=
  or_iff_not_imp_right.mp I.eq_bot_or_top h.1
#align ideal.eq_bot_of_prime Ideal.eq_bot_of_prime

theorem bot_is_maximal : IsMaximal (⊥ : Ideal K) :=
  ⟨⟨fun h => absurd ((eq_top_iff_one (⊤ : Ideal K)).mp rfl) (by rw [← h] <;> simp), fun I hI =>
      or_iff_not_imp_left.mp (eq_bot_or_top I) (ne_of_gt hI)⟩⟩
#align ideal.bot_is_maximal Ideal.bot_is_maximal

end Ideal

end DivisionRing

section CommRing

namespace Ideal

theorem mul_sub_mul_mem {R : Type _} [CommRing R] (I : Ideal R) {a b c d : R} (h1 : a - b ∈ I)
    (h2 : c - d ∈ I) : a * c - b * d ∈ I := by
  rw [show a * c - b * d = (a - b) * c + b * (c - d) by
      rw [sub_mul, mul_sub]
      abel]
  exact I.add_mem (I.mul_mem_right _ h1) (I.mul_mem_left _ h2)
#align ideal.mul_sub_mul_mem Ideal.mul_sub_mul_mem

end Ideal

end CommRing

namespace Ring

variable {R : Type _} [CommRing R]

theorem not_is_field_of_subsingleton {R : Type _} [Ring R] [Subsingleton R] : ¬IsField R :=
  fun ⟨⟨x, y, hxy⟩, _, _⟩ => hxy (Subsingleton.elim x y)
#align ring.not_is_field_of_subsingleton Ring.not_is_field_of_subsingleton

/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (x «expr ≠ » (0 : R)) -/
theorem exists_not_is_unit_of_not_is_field [Nontrivial R] (hf : ¬IsField R) :
    ∃ (x : _)(_ : x ≠ (0 : R)), ¬IsUnit x := by
  have : ¬_ := fun h => hf ⟨exists_pair_ne R, mul_comm, h⟩
  simp_rw [isUnit_iff_exists_inv]
  push_neg  at this⊢
  obtain ⟨x, hx, not_unit⟩ := this
  exact ⟨x, hx, not_unit⟩
#align ring.exists_not_is_unit_of_not_is_field Ring.exists_not_is_unit_of_not_is_field

theorem not_is_field_iff_exists_ideal_bot_lt_and_lt_top [Nontrivial R] :
    ¬IsField R ↔ ∃ I : Ideal R, ⊥ < I ∧ I < ⊤ := by
  constructor
  · intro h
    obtain ⟨x, nz, nu⟩ := exists_not_is_unit_of_not_is_field h
    use Ideal.span {x}
    rw [bot_lt_iff_ne_bot, lt_top_iff_ne_top]
    exact ⟨mt ideal.span_singleton_eq_bot.mp nz, mt ideal.span_singleton_eq_top.mp nu⟩
  · rintro ⟨I, bot_lt, lt_top⟩ hf
    obtain ⟨x, mem, ne_zero⟩ := SetLike.exists_of_lt bot_lt
    rw [Submodule.mem_bot] at ne_zero
    obtain ⟨y, hy⟩ := hf.mul_inv_cancel NeZero
    rw [lt_top_iff_ne_top, Ne.def, Ideal.eq_top_iff_one, ← hy] at lt_top
    exact lt_top (I.mul_mem_right _ mem)
#align
  ring.not_is_field_iff_exists_ideal_bot_lt_and_lt_top Ring.not_is_field_iff_exists_ideal_bot_lt_and_lt_top

theorem not_is_field_iff_exists_prime [Nontrivial R] :
    ¬IsField R ↔ ∃ p : Ideal R, p ≠ ⊥ ∧ p.IsPrime :=
  not_is_field_iff_exists_ideal_bot_lt_and_lt_top.trans
    ⟨fun ⟨I, bot_lt, lt_top⟩ =>
      let ⟨p, hp, le_p⟩ := I.exists_le_maximal (lt_top_iff_ne_top.mp lt_top)
      ⟨p, bot_lt_iff_ne_bot.mp (lt_of_lt_of_le bot_lt le_p), hp.IsPrime⟩,
      fun ⟨p, ne_bot, Prime⟩ => ⟨p, bot_lt_iff_ne_bot.mpr ne_bot, lt_top_iff_ne_top.mpr Prime.1⟩⟩
#align ring.not_is_field_iff_exists_prime Ring.not_is_field_iff_exists_prime

/-- When a ring is not a field, the maximal ideals are nontrivial. -/
theorem ne_bot_of_is_maximal_of_not_is_field [Nontrivial R] {M : Ideal R} (max : M.IsMaximal)
    (not_field : ¬IsField R) : M ≠ ⊥ := by 
  rintro h
  rw [h] at max
  rcases max with ⟨⟨h1, h2⟩⟩
  obtain ⟨I, hIbot, hItop⟩ := not_is_field_iff_exists_ideal_bot_lt_and_lt_top.mp not_field
  exact ne_of_lt hItop (h2 I hIbot)
#align ring.ne_bot_of_is_maximal_of_not_is_field Ring.ne_bot_of_is_maximal_of_not_is_field

end Ring

namespace Ideal

variable {R : Type u} [CommRing R] [Nontrivial R]

theorem bot_lt_of_maximal (M : Ideal R) [hm : M.IsMaximal] (non_field : ¬IsField R) : ⊥ < M := by
  rcases Ring.not_is_field_iff_exists_ideal_bot_lt_and_lt_top.1 non_field with ⟨I, Ibot, Itop⟩
  constructor; · simp
  intro mle
  apply @irrefl _ (· < ·) _ (⊤ : Ideal R)
  have : M = ⊥ := eq_bot_iff.mpr mle
  rw [this] at *
  rwa [hm.1.2 I Ibot] at Itop
#align ideal.bot_lt_of_maximal Ideal.bot_lt_of_maximal

end Ideal

variable {a b : α}

/-- The set of non-invertible elements of a monoid. -/
def nonunits (α : Type u) [Monoid α] : Set α :=
  { a | ¬IsUnit a }
#align nonunits nonunits

@[simp]
theorem mem_nonunits_iff [Monoid α] : a ∈ nonunits α ↔ ¬IsUnit a :=
  Iff.rfl
#align mem_nonunits_iff mem_nonunits_iff

theorem mul_mem_nonunits_right [CommMonoid α] : b ∈ nonunits α → a * b ∈ nonunits α :=
  mt isUnit_of_mul_isUnit_right
#align mul_mem_nonunits_right mul_mem_nonunits_right

theorem mul_mem_nonunits_left [CommMonoid α] : a ∈ nonunits α → a * b ∈ nonunits α :=
  mt isUnit_of_mul_isUnit_left
#align mul_mem_nonunits_left mul_mem_nonunits_left

theorem zero_mem_nonunits [Semiring α] : 0 ∈ nonunits α ↔ (0 : α) ≠ 1 :=
  not_congr isUnit_zero_iff
#align zero_mem_nonunits zero_mem_nonunits

@[simp]
theorem one_not_mem_nonunits [Monoid α] : (1 : α) ∉ nonunits α :=
  not_not_intro isUnit_one
#align one_not_mem_nonunits one_not_mem_nonunits

theorem coe_subset_nonunits [Semiring α] {I : Ideal α} (h : I ≠ ⊤) : (I : Set α) ⊆ nonunits α :=
  fun x hx hu => h <| I.eq_top_of_is_unit_mem hx hu
#align coe_subset_nonunits coe_subset_nonunits

theorem exists_max_ideal_of_mem_nonunits [CommSemiring α] (h : a ∈ nonunits α) :
    ∃ I : Ideal α, I.IsMaximal ∧ a ∈ I := by
  have : Ideal.span ({a} : Set α) ≠ ⊤ := by 
    intro H
    rw [Ideal.span_singleton_eq_top] at H
    contradiction
  rcases Ideal.exists_le_maximal _ this with ⟨I, Imax, H⟩
  use I, Imax
  apply H
  apply Ideal.subset_span
  exact Set.mem_singleton a
#align exists_max_ideal_of_mem_nonunits exists_max_ideal_of_mem_nonunits

