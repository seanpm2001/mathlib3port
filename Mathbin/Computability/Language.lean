/-
Copyright (c) 2020 Fox Thomson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Fox Thomson

! This file was ported from Lean 3 source module computability.language
! leanprover-community/mathlib commit e97cf15cd1aec9bd5c193b2ffac5a6dc9118912b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Ring
import Mathbin.Algebra.Order.Kleene
import Mathbin.Data.List.Join
import Mathbin.Data.Set.Lattice

/-!
# Languages

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file contains the definition and operations on formal languages over an alphabet. Note strings
are implemented as lists over the alphabet.
The operations in this file define a [Kleene algebra](https://en.wikipedia.org/wiki/Kleene_algebra)
over the languages.
-/


open List Set

open scoped Computability

universe v

variable {α β γ : Type _}

/- ./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_mem[has_mem] (list[list] α) -/
/- ./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_singleton[has_singleton] (list[list] α) -/
/- ./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_insert[has_insert] (list[list] α) -/
#print Language /-
/-- A language is a set of strings over an alphabet. -/
def Language (α) :=
  Set (List α)
deriving
  «./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_mem[has_mem] (list[list] α)»,
  «./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_singleton[has_singleton] (list[list] α)»,
  «./././Mathport/Syntax/Translate/Command.lean:43:9: unsupported derive handler has_insert[has_insert] (list[list] α)»,
  CompleteBooleanAlgebra
#align language Language
-/

namespace Language

variable {l m : Language α} {a b x : List α}

attribute [local reducible] Language

/-- Zero language has no elements. -/
instance : Zero (Language α) :=
  ⟨(∅ : Set _)⟩

/-- `1 : language α` contains only one element `[]`. -/
instance : One (Language α) :=
  ⟨{[]}⟩

instance : Inhabited (Language α) :=
  ⟨0⟩

/-- The sum of two languages is their union. -/
instance : Add (Language α) :=
  ⟨(· ∪ ·)⟩

/-- The product of two languages `l` and `m` is the language made of the strings `x ++ y` where
`x ∈ l` and `y ∈ m`. -/
instance : Mul (Language α) :=
  ⟨image2 (· ++ ·)⟩

#print Language.zero_def /-
theorem zero_def : (0 : Language α) = (∅ : Set _) :=
  rfl
#align language.zero_def Language.zero_def
-/

#print Language.one_def /-
theorem one_def : (1 : Language α) = {[]} :=
  rfl
#align language.one_def Language.one_def
-/

#print Language.add_def /-
theorem add_def (l m : Language α) : l + m = l ∪ m :=
  rfl
#align language.add_def Language.add_def
-/

#print Language.mul_def /-
theorem mul_def (l m : Language α) : l * m = image2 (· ++ ·) l m :=
  rfl
#align language.mul_def Language.mul_def
-/

/-- The Kleene star of a language `L` is the set of all strings which can be written by
concatenating strings from `L`. -/
instance : KStar (Language α) :=
  ⟨fun l => {x | ∃ L : List (List α), x = L.join ∧ ∀ y ∈ L, y ∈ l}⟩

#print Language.kstar_def /-
theorem kstar_def (l : Language α) : l∗ = {x | ∃ L : List (List α), x = L.join ∧ ∀ y ∈ L, y ∈ l} :=
  rfl
#align language.kstar_def Language.kstar_def
-/

#print Language.not_mem_zero /-
@[simp]
theorem not_mem_zero (x : List α) : x ∉ (0 : Language α) :=
  id
#align language.not_mem_zero Language.not_mem_zero
-/

#print Language.mem_one /-
@[simp]
theorem mem_one (x : List α) : x ∈ (1 : Language α) ↔ x = [] := by rfl
#align language.mem_one Language.mem_one
-/

#print Language.nil_mem_one /-
theorem nil_mem_one : [] ∈ (1 : Language α) :=
  Set.mem_singleton _
#align language.nil_mem_one Language.nil_mem_one
-/

#print Language.mem_add /-
theorem mem_add (l m : Language α) (x : List α) : x ∈ l + m ↔ x ∈ l ∨ x ∈ m :=
  Iff.rfl
#align language.mem_add Language.mem_add
-/

#print Language.mem_mul /-
theorem mem_mul : x ∈ l * m ↔ ∃ a b, a ∈ l ∧ b ∈ m ∧ a ++ b = x :=
  mem_image2
#align language.mem_mul Language.mem_mul
-/

#print Language.append_mem_mul /-
theorem append_mem_mul : a ∈ l → b ∈ m → a ++ b ∈ l * m :=
  mem_image2_of_mem
#align language.append_mem_mul Language.append_mem_mul
-/

#print Language.mem_kstar /-
theorem mem_kstar : x ∈ l∗ ↔ ∃ L : List (List α), x = L.join ∧ ∀ y ∈ L, y ∈ l :=
  Iff.rfl
#align language.mem_kstar Language.mem_kstar
-/

#print Language.join_mem_kstar /-
theorem join_mem_kstar {L : List (List α)} (h : ∀ y ∈ L, y ∈ l) : L.join ∈ l∗ :=
  ⟨L, rfl, h⟩
#align language.join_mem_kstar Language.join_mem_kstar
-/

#print Language.nil_mem_kstar /-
theorem nil_mem_kstar (l : Language α) : [] ∈ l∗ :=
  ⟨[], rfl, fun _ => False.elim⟩
#align language.nil_mem_kstar Language.nil_mem_kstar
-/

instance : Semiring (Language α) where
  add := (· + ·)
  add_assoc := union_assoc
  zero := 0
  zero_add := empty_union
  add_zero := union_empty
  add_comm := union_comm
  mul := (· * ·)
  mul_assoc _ _ _ := image2_assoc append_assoc
  zero_mul _ := image2_empty_left
  mul_zero _ := image2_empty_right
  one := 1
  one_mul l := by simp [mul_def, one_def]
  mul_one l := by simp [mul_def, one_def]
  natCast n := if n = 0 then 0 else 1
  natCast_zero := rfl
  natCast_succ n := by cases n <;> simp [Nat.cast, add_def, zero_def]
  left_distrib _ _ _ := image2_union_right
  right_distrib _ _ _ := image2_union_left

#print Language.add_self /-
@[simp]
theorem add_self (l : Language α) : l + l = l :=
  sup_idem
#align language.add_self Language.add_self
-/

#print Language.map /-
/-- Maps the alphabet of a language. -/
def map (f : α → β) : Language α →+* Language β
    where
  toFun := image (List.map f)
  map_zero' := image_empty _
  map_one' := image_singleton
  map_add' := image_union _
  map_mul' _ _ := image_image2_distrib <| map_append _
#align language.map Language.map
-/

#print Language.map_id /-
@[simp]
theorem map_id (l : Language α) : map id l = l := by simp [map]
#align language.map_id Language.map_id
-/

#print Language.map_map /-
@[simp]
theorem map_map (g : β → γ) (f : α → β) (l : Language α) : map g (map f l) = map (g ∘ f) l := by
  simp [map, image_image]
#align language.map_map Language.map_map
-/

#print Language.kstar_def_nonempty /-
theorem kstar_def_nonempty (l : Language α) :
    l∗ = {x | ∃ S : List (List α), x = S.join ∧ ∀ y ∈ S, y ∈ l ∧ y ≠ []} :=
  by
  ext x
  constructor
  · rintro ⟨S, rfl, h⟩
    refine' ⟨S.filter fun l => ¬List.isEmpty l, by simp, fun y hy => _⟩
    rw [mem_filter, empty_iff_eq_nil] at hy 
    exact ⟨h y hy.1, hy.2⟩
  · rintro ⟨S, hx, h⟩
    exact ⟨S, hx, fun y hy => (h y hy).1⟩
#align language.kstar_def_nonempty Language.kstar_def_nonempty
-/

#print Language.le_iff /-
theorem le_iff (l m : Language α) : l ≤ m ↔ l + m = m :=
  sup_eq_right.symm
#align language.le_iff Language.le_iff
-/

#print Language.le_mul_congr /-
theorem le_mul_congr {l₁ l₂ m₁ m₂ : Language α} : l₁ ≤ m₁ → l₂ ≤ m₂ → l₁ * l₂ ≤ m₁ * m₂ :=
  by
  intro h₁ h₂ x hx
  simp only [mul_def, exists_and_left, mem_image2, image_prod] at hx ⊢
  tauto
#align language.le_mul_congr Language.le_mul_congr
-/

#print Language.le_add_congr /-
theorem le_add_congr {l₁ l₂ m₁ m₂ : Language α} : l₁ ≤ m₁ → l₂ ≤ m₂ → l₁ + l₂ ≤ m₁ + m₂ :=
  sup_le_sup
#align language.le_add_congr Language.le_add_congr
-/

#print Language.mem_iSup /-
theorem mem_iSup {ι : Sort v} {l : ι → Language α} {x : List α} : (x ∈ ⨆ i, l i) ↔ ∃ i, x ∈ l i :=
  mem_iUnion
#align language.mem_supr Language.mem_iSup
-/

#print Language.iSup_mul /-
theorem iSup_mul {ι : Sort v} (l : ι → Language α) (m : Language α) :
    (⨆ i, l i) * m = ⨆ i, l i * m :=
  image2_iUnion_left _ _ _
#align language.supr_mul Language.iSup_mul
-/

#print Language.mul_iSup /-
theorem mul_iSup {ι : Sort v} (l : ι → Language α) (m : Language α) :
    (m * ⨆ i, l i) = ⨆ i, m * l i :=
  image2_iUnion_right _ _ _
#align language.mul_supr Language.mul_iSup
-/

#print Language.iSup_add /-
theorem iSup_add {ι : Sort v} [Nonempty ι] (l : ι → Language α) (m : Language α) :
    (⨆ i, l i) + m = ⨆ i, l i + m :=
  iSup_sup
#align language.supr_add Language.iSup_add
-/

#print Language.add_iSup /-
theorem add_iSup {ι : Sort v} [Nonempty ι] (l : ι → Language α) (m : Language α) :
    (m + ⨆ i, l i) = ⨆ i, m + l i :=
  sup_iSup
#align language.add_supr Language.add_iSup
-/

#print Language.mem_pow /-
theorem mem_pow {l : Language α} {x : List α} {n : ℕ} :
    x ∈ l ^ n ↔ ∃ S : List (List α), x = S.join ∧ S.length = n ∧ ∀ y ∈ S, y ∈ l :=
  by
  induction' n with n ihn generalizing x
  · simp only [mem_one, pow_zero, length_eq_zero]
    constructor
    · rintro rfl; exact ⟨[], rfl, rfl, fun y h => h.elim⟩
    · rintro ⟨_, rfl, rfl, _⟩; rfl
  · simp only [pow_succ, mem_mul, ihn]
    constructor
    · rintro ⟨a, b, ha, ⟨S, rfl, rfl, hS⟩, rfl⟩
      exact ⟨a :: S, rfl, rfl, forall_mem_cons.2 ⟨ha, hS⟩⟩
    · rintro ⟨_ | ⟨a, S⟩, rfl, hn, hS⟩ <;> cases hn
      rw [forall_mem_cons] at hS 
      exact ⟨a, _, hS.1, ⟨S, rfl, rfl, hS.2⟩, rfl⟩
#align language.mem_pow Language.mem_pow
-/

#print Language.kstar_eq_iSup_pow /-
theorem kstar_eq_iSup_pow (l : Language α) : l∗ = ⨆ i : ℕ, l ^ i :=
  by
  ext x
  simp only [mem_kstar, mem_supr, mem_pow]
  constructor
  · rintro ⟨S, rfl, hS⟩; exact ⟨_, S, rfl, rfl, hS⟩
  · rintro ⟨_, S, rfl, rfl, hS⟩; exact ⟨S, rfl, hS⟩
#align language.kstar_eq_supr_pow Language.kstar_eq_iSup_pow
-/

#print Language.map_kstar /-
@[simp]
theorem map_kstar (f : α → β) (l : Language α) : map f l∗ = (map f l)∗ :=
  by
  rw [kstar_eq_supr_pow, kstar_eq_supr_pow]
  simp_rw [← map_pow]
  exact image_Union
#align language.map_kstar Language.map_kstar
-/

#print Language.mul_self_kstar_comm /-
theorem mul_self_kstar_comm (l : Language α) : l∗ * l = l * l∗ := by
  simp only [kstar_eq_supr_pow, mul_supr, supr_mul, ← pow_succ, ← pow_succ']
#align language.mul_self_kstar_comm Language.mul_self_kstar_comm
-/

#print Language.one_add_self_mul_kstar_eq_kstar /-
@[simp]
theorem one_add_self_mul_kstar_eq_kstar (l : Language α) : 1 + l * l∗ = l∗ :=
  by
  simp only [kstar_eq_supr_pow, mul_supr, ← pow_succ, ← pow_zero l]
  exact sup_iSup_nat_succ _
#align language.one_add_self_mul_kstar_eq_kstar Language.one_add_self_mul_kstar_eq_kstar
-/

#print Language.one_add_kstar_mul_self_eq_kstar /-
@[simp]
theorem one_add_kstar_mul_self_eq_kstar (l : Language α) : 1 + l∗ * l = l∗ := by
  rw [mul_self_kstar_comm, one_add_self_mul_kstar_eq_kstar]
#align language.one_add_kstar_mul_self_eq_kstar Language.one_add_kstar_mul_self_eq_kstar
-/

instance : KleeneAlgebra (Language α) :=
  { Language.semiring, Set.completeBooleanAlgebra,
    Language.hasKstar with
    one_le_kstar := fun a l hl => ⟨[], hl, by simp⟩
    mul_kstar_le_kstar := fun a => (one_add_self_mul_kstar_eq_kstar a).le.trans' le_sup_right
    kstar_mul_le_kstar := fun a => (one_add_kstar_mul_self_eq_kstar a).le.trans' le_sup_right
    kstar_mul_le_self := fun l m h =>
      by
      rw [kstar_eq_supr_pow, supr_mul]
      refine' iSup_le fun n => _
      induction' n with n ih
      · simp
      rw [pow_succ', mul_assoc (l ^ n) l m]
      exact le_trans (le_mul_congr le_rfl h) ih
    mul_kstar_le_self := fun l m h =>
      by
      rw [kstar_eq_supr_pow, mul_supr]
      refine' iSup_le fun n => _
      induction' n with n ih
      · simp
      rw [pow_succ, ← mul_assoc m l (l ^ n)]
      exact le_trans (le_mul_congr h le_rfl) ih }

end Language

