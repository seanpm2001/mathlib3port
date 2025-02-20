/-
Copyright (c) 2019 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yury Kudryashov

! This file was ported from Lean 3 source module order.filter.archimedean
! leanprover-community/mathlib commit 4d392a6c9c4539cbeca399b3ee0afea398fbd2eb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Archimedean
import Mathbin.Order.Filter.AtTopBot

/-!
# `at_top` filter and archimedean (semi)rings/fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove that for a linear ordered archimedean semiring `R` and a function `f : α → ℕ`,
the function `coe ∘ f : α → R` tends to `at_top` along a filter `l` if and only if so does `f`.
We also prove that `coe : ℕ → R` tends to `at_top` along `at_top`, as well as version of these
two results for `ℤ` (and a ring `R`) and `ℚ` (and a field `R`).
-/


variable {α R : Type _}

open Filter Set

#print Nat.comap_cast_atTop /-
@[simp]
theorem Nat.comap_cast_atTop [StrictOrderedSemiring R] [Archimedean R] :
    comap (coe : ℕ → R) atTop = atTop :=
  comap_embedding_atTop (fun _ _ => Nat.cast_le) exists_nat_ge
#align nat.comap_coe_at_top Nat.comap_cast_atTop
-/

#print tendsto_nat_cast_atTop_iff /-
theorem tendsto_nat_cast_atTop_iff [StrictOrderedSemiring R] [Archimedean R] {f : α → ℕ}
    {l : Filter α} : Tendsto (fun n => (f n : R)) l atTop ↔ Tendsto f l atTop :=
  tendsto_atTop_embedding (fun a₁ a₂ => Nat.cast_le) exists_nat_ge
#align tendsto_coe_nat_at_top_iff tendsto_nat_cast_atTop_iff
-/

#print tendsto_nat_cast_atTop_atTop /-
theorem tendsto_nat_cast_atTop_atTop [StrictOrderedSemiring R] [Archimedean R] :
    Tendsto (coe : ℕ → R) atTop atTop :=
  Nat.mono_cast.tendsto_atTop_atTop exists_nat_ge
#align tendsto_coe_nat_at_top_at_top tendsto_nat_cast_atTop_atTop
-/

#print Int.comap_cast_atTop /-
@[simp]
theorem Int.comap_cast_atTop [StrictOrderedRing R] [Archimedean R] :
    comap (coe : ℤ → R) atTop = atTop :=
  comap_embedding_atTop (fun _ _ => Int.cast_le) fun r =>
    let ⟨n, hn⟩ := exists_nat_ge r
    ⟨n, by exact_mod_cast hn⟩
#align int.comap_coe_at_top Int.comap_cast_atTop
-/

#print Int.comap_cast_atBot /-
@[simp]
theorem Int.comap_cast_atBot [StrictOrderedRing R] [Archimedean R] :
    comap (coe : ℤ → R) atBot = atBot :=
  comap_embedding_atBot (fun _ _ => Int.cast_le) fun r =>
    let ⟨n, hn⟩ := exists_nat_ge (-r)
    ⟨-n, by simpa [neg_le] using hn⟩
#align int.comap_coe_at_bot Int.comap_cast_atBot
-/

#print tendsto_int_cast_atTop_iff /-
theorem tendsto_int_cast_atTop_iff [StrictOrderedRing R] [Archimedean R] {f : α → ℤ}
    {l : Filter α} : Tendsto (fun n => (f n : R)) l atTop ↔ Tendsto f l atTop := by
  rw [← tendsto_comap_iff, Int.comap_cast_atTop]
#align tendsto_coe_int_at_top_iff tendsto_int_cast_atTop_iff
-/

#print tendsto_int_cast_atBot_iff /-
theorem tendsto_int_cast_atBot_iff [StrictOrderedRing R] [Archimedean R] {f : α → ℤ}
    {l : Filter α} : Tendsto (fun n => (f n : R)) l atBot ↔ Tendsto f l atBot := by
  rw [← tendsto_comap_iff, Int.comap_cast_atBot]
#align tendsto_coe_int_at_bot_iff tendsto_int_cast_atBot_iff
-/

#print tendsto_int_cast_atTop_atTop /-
theorem tendsto_int_cast_atTop_atTop [StrictOrderedRing R] [Archimedean R] :
    Tendsto (coe : ℤ → R) atTop atTop :=
  Int.cast_mono.tendsto_atTop_atTop fun b =>
    let ⟨n, hn⟩ := exists_nat_ge b
    ⟨n, by exact_mod_cast hn⟩
#align tendsto_coe_int_at_top_at_top tendsto_int_cast_atTop_atTop
-/

#print Rat.comap_cast_atTop /-
@[simp]
theorem Rat.comap_cast_atTop [LinearOrderedField R] [Archimedean R] :
    comap (coe : ℚ → R) atTop = atTop :=
  comap_embedding_atTop (fun _ _ => Rat.cast_le) fun r =>
    let ⟨n, hn⟩ := exists_nat_ge r
    ⟨n, by simpa⟩
#align rat.comap_coe_at_top Rat.comap_cast_atTop
-/

#print Rat.comap_cast_atBot /-
@[simp]
theorem Rat.comap_cast_atBot [LinearOrderedField R] [Archimedean R] :
    comap (coe : ℚ → R) atBot = atBot :=
  comap_embedding_atBot (fun _ _ => Rat.cast_le) fun r =>
    let ⟨n, hn⟩ := exists_nat_ge (-r)
    ⟨-n, by simpa [neg_le]⟩
#align rat.comap_coe_at_bot Rat.comap_cast_atBot
-/

#print tendsto_rat_cast_atTop_iff /-
theorem tendsto_rat_cast_atTop_iff [LinearOrderedField R] [Archimedean R] {f : α → ℚ}
    {l : Filter α} : Tendsto (fun n => (f n : R)) l atTop ↔ Tendsto f l atTop := by
  rw [← tendsto_comap_iff, Rat.comap_cast_atTop]
#align tendsto_coe_rat_at_top_iff tendsto_rat_cast_atTop_iff
-/

#print tendsto_rat_cast_atBot_iff /-
theorem tendsto_rat_cast_atBot_iff [LinearOrderedField R] [Archimedean R] {f : α → ℚ}
    {l : Filter α} : Tendsto (fun n => (f n : R)) l atBot ↔ Tendsto f l atBot := by
  rw [← tendsto_comap_iff, Rat.comap_cast_atBot]
#align tendsto_coe_rat_at_bot_iff tendsto_rat_cast_atBot_iff
-/

#print atTop_hasCountableBasis_of_archimedean /-
theorem atTop_hasCountableBasis_of_archimedean [LinearOrderedSemiring R] [Archimedean R] :
    (atTop : Filter R).HasCountableBasis (fun n : ℕ => True) fun n => Ici n :=
  { Countable := to_countable _
    to_hasBasis :=
      atTop_basis.to_hasBasis
        (fun x hx =>
          let ⟨n, hn⟩ := exists_nat_ge x
          ⟨n, trivial, Ici_subset_Ici.2 hn⟩)
        fun n hn => ⟨n, trivial, Subset.rfl⟩ }
#align at_top_countable_basis_of_archimedean atTop_hasCountableBasis_of_archimedean
-/

#print atBot_hasCountableBasis_of_archimedean /-
theorem atBot_hasCountableBasis_of_archimedean [LinearOrderedRing R] [Archimedean R] :
    (atBot : Filter R).HasCountableBasis (fun m : ℤ => True) fun m => Iic m :=
  { Countable := to_countable _
    to_hasBasis :=
      atBot_basis.to_hasBasis
        (fun x hx =>
          let ⟨m, hm⟩ := exists_int_lt x
          ⟨m, trivial, Iic_subset_Iic.2 hm.le⟩)
        fun m hm => ⟨m, trivial, Subset.rfl⟩ }
#align at_bot_countable_basis_of_archimedean atBot_hasCountableBasis_of_archimedean
-/

#print atTop_isCountablyGenerated_of_archimedean /-
instance (priority := 100) atTop_isCountablyGenerated_of_archimedean [LinearOrderedSemiring R]
    [Archimedean R] : (atTop : Filter R).IsCountablyGenerated :=
  atTop_hasCountableBasis_of_archimedean.IsCountablyGenerated
#align at_top_countably_generated_of_archimedean atTop_isCountablyGenerated_of_archimedean
-/

#print atBot_isCountablyGenerated_of_archimedean /-
instance (priority := 100) atBot_isCountablyGenerated_of_archimedean [LinearOrderedRing R]
    [Archimedean R] : (atBot : Filter R).IsCountablyGenerated :=
  atBot_hasCountableBasis_of_archimedean.IsCountablyGenerated
#align at_bot_countably_generated_of_archimedean atBot_isCountablyGenerated_of_archimedean
-/

namespace Filter

variable {l : Filter α} {f : α → R} {r : R}

section LinearOrderedSemiring

variable [LinearOrderedSemiring R] [Archimedean R]

#print Filter.Tendsto.const_mul_atTop' /-
/-- If a function tends to infinity along a filter, then this function multiplied by a positive
constant (on the left) also tends to infinity. The archimedean assumption is convenient to get a
statement that works on `ℕ`, `ℤ` and `ℝ`, although not necessary (a version in ordered fields is
given in `filter.tendsto.const_mul_at_top`). -/
theorem Tendsto.const_mul_atTop' (hr : 0 < r) (hf : Tendsto f l atTop) :
    Tendsto (fun x => r * f x) l atTop :=
  by
  apply tendsto_at_top.2 fun b => _
  obtain ⟨n : ℕ, hn : 1 ≤ n • r⟩ := Archimedean.arch 1 hr
  rw [nsmul_eq_mul'] at hn 
  filter_upwards [tendsto_at_top.1 hf (n * max b 0)] with x hx
  calc
    b ≤ 1 * max b 0 := by rw [one_mul]; exact le_max_left _ _
    _ ≤ r * n * max b 0 := (mul_le_mul_of_nonneg_right hn (le_max_right _ _))
    _ = r * (n * max b 0) := by rw [mul_assoc]
    _ ≤ r * f x := mul_le_mul_of_nonneg_left hx (le_of_lt hr)
#align filter.tendsto.const_mul_at_top' Filter.Tendsto.const_mul_atTop'
-/

#print Filter.Tendsto.atTop_mul_const' /-
/-- If a function tends to infinity along a filter, then this function multiplied by a positive
constant (on the right) also tends to infinity. The archimedean assumption is convenient to get a
statement that works on `ℕ`, `ℤ` and `ℝ`, although not necessary (a version in ordered fields is
given in `filter.tendsto.at_top_mul_const`). -/
theorem Tendsto.atTop_mul_const' (hr : 0 < r) (hf : Tendsto f l atTop) :
    Tendsto (fun x => f x * r) l atTop :=
  by
  apply tendsto_at_top.2 fun b => _
  obtain ⟨n : ℕ, hn : 1 ≤ n • r⟩ := Archimedean.arch 1 hr
  have hn' : 1 ≤ (n : R) * r := by rwa [nsmul_eq_mul] at hn 
  filter_upwards [tendsto_at_top.1 hf (max b 0 * n)] with x hx
  calc
    b ≤ max b 0 * 1 := by rw [mul_one]; exact le_max_left _ _
    _ ≤ max b 0 * (n * r) := (mul_le_mul_of_nonneg_left hn' (le_max_right _ _))
    _ = max b 0 * n * r := by rw [mul_assoc]
    _ ≤ f x * r := mul_le_mul_of_nonneg_right hx (le_of_lt hr)
#align filter.tendsto.at_top_mul_const' Filter.Tendsto.atTop_mul_const'
-/

end LinearOrderedSemiring

section LinearOrderedRing

variable [LinearOrderedRing R] [Archimedean R]

#print Filter.Tendsto.atTop_mul_neg_const' /-
/-- See also `filter.tendsto.at_top_mul_neg_const` for a version of this lemma for
`linear_ordered_field`s which does not require the `archimedean` assumption. -/
theorem Tendsto.atTop_mul_neg_const' (hr : r < 0) (hf : Tendsto f l atTop) :
    Tendsto (fun x => f x * r) l atBot := by
  simpa only [tendsto_neg_at_top_iff, mul_neg] using hf.at_top_mul_const' (neg_pos.mpr hr)
#align filter.tendsto.at_top_mul_neg_const' Filter.Tendsto.atTop_mul_neg_const'
-/

#print Filter.Tendsto.atBot_mul_const' /-
/-- See also `filter.tendsto.at_bot_mul_const` for a version of this lemma for
`linear_ordered_field`s which does not require the `archimedean` assumption. -/
theorem Tendsto.atBot_mul_const' (hr : 0 < r) (hf : Tendsto f l atBot) :
    Tendsto (fun x => f x * r) l atBot :=
  by
  simp only [← tendsto_neg_at_top_iff, ← neg_mul] at hf ⊢
  exact hf.at_top_mul_const' hr
#align filter.tendsto.at_bot_mul_const' Filter.Tendsto.atBot_mul_const'
-/

#print Filter.Tendsto.atBot_mul_neg_const' /-
/-- See also `filter.tendsto.at_bot_mul_neg_const` for a version of this lemma for
`linear_ordered_field`s which does not require the `archimedean` assumption. -/
theorem Tendsto.atBot_mul_neg_const' (hr : r < 0) (hf : Tendsto f l atBot) :
    Tendsto (fun x => f x * r) l atTop := by
  simpa only [mul_neg, tendsto_neg_at_bot_iff] using hf.at_bot_mul_const' (neg_pos.2 hr)
#align filter.tendsto.at_bot_mul_neg_const' Filter.Tendsto.atBot_mul_neg_const'
-/

end LinearOrderedRing

section LinearOrderedCancelAddCommMonoid

variable [LinearOrderedCancelAddCommMonoid R] [Archimedean R]

#print Filter.Tendsto.atTop_nsmul_const /-
theorem Tendsto.atTop_nsmul_const {f : α → ℕ} (hr : 0 < r) (hf : Tendsto f l atTop) :
    Tendsto (fun x => f x • r) l atTop :=
  by
  refine' tendsto_at_top.mpr fun s => _
  obtain ⟨n : ℕ, hn : s ≤ n • r⟩ := Archimedean.arch s hr
  exact (tendsto_at_top.mp hf n).mono fun a ha => hn.trans (nsmul_le_nsmul hr.le ha)
#align filter.tendsto.at_top_nsmul_const Filter.Tendsto.atTop_nsmul_const
-/

end LinearOrderedCancelAddCommMonoid

section LinearOrderedAddCommGroup

variable [LinearOrderedAddCommGroup R] [Archimedean R]

#print Filter.Tendsto.atTop_nsmul_neg_const /-
theorem Tendsto.atTop_nsmul_neg_const {f : α → ℕ} (hr : r < 0) (hf : Tendsto f l atTop) :
    Tendsto (fun x => f x • r) l atBot := by simpa using hf.at_top_nsmul_const (neg_pos.2 hr)
#align filter.tendsto.at_top_nsmul_neg_const Filter.Tendsto.atTop_nsmul_neg_const
-/

#print Filter.Tendsto.atTop_zsmul_const /-
theorem Tendsto.atTop_zsmul_const {f : α → ℤ} (hr : 0 < r) (hf : Tendsto f l atTop) :
    Tendsto (fun x => f x • r) l atTop :=
  by
  refine' tendsto_at_top.mpr fun s => _
  obtain ⟨n : ℕ, hn : s ≤ n • r⟩ := Archimedean.arch s hr
  replace hn : s ≤ (n : ℤ) • r; · simpa
  exact (tendsto_at_top.mp hf n).mono fun a ha => hn.trans (zsmul_le_zsmul hr.le ha)
#align filter.tendsto.at_top_zsmul_const Filter.Tendsto.atTop_zsmul_const
-/

#print Filter.Tendsto.atTop_zsmul_neg_const /-
theorem Tendsto.atTop_zsmul_neg_const {f : α → ℤ} (hr : r < 0) (hf : Tendsto f l atTop) :
    Tendsto (fun x => f x • r) l atBot := by simpa using hf.at_top_zsmul_const (neg_pos.2 hr)
#align filter.tendsto.at_top_zsmul_neg_const Filter.Tendsto.atTop_zsmul_neg_const
-/

#print Filter.Tendsto.atBot_zsmul_const /-
theorem Tendsto.atBot_zsmul_const {f : α → ℤ} (hr : 0 < r) (hf : Tendsto f l atBot) :
    Tendsto (fun x => f x • r) l atBot :=
  by
  simp only [← tendsto_neg_at_top_iff, ← neg_zsmul] at hf ⊢
  exact hf.at_top_zsmul_const hr
#align filter.tendsto.at_bot_zsmul_const Filter.Tendsto.atBot_zsmul_const
-/

#print Filter.Tendsto.atBot_zsmul_neg_const /-
theorem Tendsto.atBot_zsmul_neg_const {f : α → ℤ} (hr : r < 0) (hf : Tendsto f l atBot) :
    Tendsto (fun x => f x • r) l atTop := by simpa using hf.at_bot_zsmul_const (neg_pos.2 hr)
#align filter.tendsto.at_bot_zsmul_neg_const Filter.Tendsto.atBot_zsmul_neg_const
-/

end LinearOrderedAddCommGroup

end Filter

