/-
Copyright (c) 2022 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module data.set.intervals.with_bot_top
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.Basic

/-!
# Intervals in `with_top α` and `with_bot α`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove various lemmas about `set.image`s and `set.preimage`s of intervals under
`coe : α → with_top α` and `coe : α → with_bot α`.
-/


open Set

variable {α : Type _}

/-! ### `with_top` -/


namespace WithTop

#print WithTop.preimage_coe_top /-
@[simp]
theorem preimage_coe_top : (coe : α → WithTop α) ⁻¹' {⊤} = (∅ : Set α) :=
  eq_empty_of_subset_empty fun a => coe_ne_top
#align with_top.preimage_coe_top WithTop.preimage_coe_top
-/

variable [PartialOrder α] {a b : α}

#print WithTop.range_coe /-
theorem range_coe : range (coe : α → WithTop α) = Iio ⊤ :=
  by
  ext x
  rw [mem_Iio, lt_top_iff_ne_top, mem_range, ← none_eq_top, Option.ne_none_iff_exists]
  rfl
#align with_top.range_coe WithTop.range_coe
-/

#print WithTop.preimage_coe_Ioi /-
@[simp]
theorem preimage_coe_Ioi : (coe : α → WithTop α) ⁻¹' Ioi a = Ioi a :=
  ext fun x => coe_lt_coe
#align with_top.preimage_coe_Ioi WithTop.preimage_coe_Ioi
-/

#print WithTop.preimage_coe_Ici /-
@[simp]
theorem preimage_coe_Ici : (coe : α → WithTop α) ⁻¹' Ici a = Ici a :=
  ext fun x => coe_le_coe
#align with_top.preimage_coe_Ici WithTop.preimage_coe_Ici
-/

#print WithTop.preimage_coe_Iio /-
@[simp]
theorem preimage_coe_Iio : (coe : α → WithTop α) ⁻¹' Iio a = Iio a :=
  ext fun x => coe_lt_coe
#align with_top.preimage_coe_Iio WithTop.preimage_coe_Iio
-/

#print WithTop.preimage_coe_Iic /-
@[simp]
theorem preimage_coe_Iic : (coe : α → WithTop α) ⁻¹' Iic a = Iic a :=
  ext fun x => coe_le_coe
#align with_top.preimage_coe_Iic WithTop.preimage_coe_Iic
-/

#print WithTop.preimage_coe_Icc /-
@[simp]
theorem preimage_coe_Icc : (coe : α → WithTop α) ⁻¹' Icc a b = Icc a b := by simp [← Ici_inter_Iic]
#align with_top.preimage_coe_Icc WithTop.preimage_coe_Icc
-/

#print WithTop.preimage_coe_Ico /-
@[simp]
theorem preimage_coe_Ico : (coe : α → WithTop α) ⁻¹' Ico a b = Ico a b := by simp [← Ici_inter_Iio]
#align with_top.preimage_coe_Ico WithTop.preimage_coe_Ico
-/

#print WithTop.preimage_coe_Ioc /-
@[simp]
theorem preimage_coe_Ioc : (coe : α → WithTop α) ⁻¹' Ioc a b = Ioc a b := by simp [← Ioi_inter_Iic]
#align with_top.preimage_coe_Ioc WithTop.preimage_coe_Ioc
-/

#print WithTop.preimage_coe_Ioo /-
@[simp]
theorem preimage_coe_Ioo : (coe : α → WithTop α) ⁻¹' Ioo a b = Ioo a b := by simp [← Ioi_inter_Iio]
#align with_top.preimage_coe_Ioo WithTop.preimage_coe_Ioo
-/

#print WithTop.preimage_coe_Iio_top /-
@[simp]
theorem preimage_coe_Iio_top : (coe : α → WithTop α) ⁻¹' Iio ⊤ = univ := by
  rw [← range_coe, preimage_range]
#align with_top.preimage_coe_Iio_top WithTop.preimage_coe_Iio_top
-/

#print WithTop.preimage_coe_Ico_top /-
@[simp]
theorem preimage_coe_Ico_top : (coe : α → WithTop α) ⁻¹' Ico a ⊤ = Ici a := by
  simp [← Ici_inter_Iio]
#align with_top.preimage_coe_Ico_top WithTop.preimage_coe_Ico_top
-/

#print WithTop.preimage_coe_Ioo_top /-
@[simp]
theorem preimage_coe_Ioo_top : (coe : α → WithTop α) ⁻¹' Ioo a ⊤ = Ioi a := by
  simp [← Ioi_inter_Iio]
#align with_top.preimage_coe_Ioo_top WithTop.preimage_coe_Ioo_top
-/

#print WithTop.image_coe_Ioi /-
theorem image_coe_Ioi : (coe : α → WithTop α) '' Ioi a = Ioo a ⊤ := by
  rw [← preimage_coe_Ioi, image_preimage_eq_inter_range, range_coe, Ioi_inter_Iio]
#align with_top.image_coe_Ioi WithTop.image_coe_Ioi
-/

#print WithTop.image_coe_Ici /-
theorem image_coe_Ici : (coe : α → WithTop α) '' Ici a = Ico a ⊤ := by
  rw [← preimage_coe_Ici, image_preimage_eq_inter_range, range_coe, Ici_inter_Iio]
#align with_top.image_coe_Ici WithTop.image_coe_Ici
-/

#print WithTop.image_coe_Iio /-
theorem image_coe_Iio : (coe : α → WithTop α) '' Iio a = Iio a := by
  rw [← preimage_coe_Iio, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Iio_subset_Iio le_top)]
#align with_top.image_coe_Iio WithTop.image_coe_Iio
-/

#print WithTop.image_coe_Iic /-
theorem image_coe_Iic : (coe : α → WithTop α) '' Iic a = Iic a := by
  rw [← preimage_coe_Iic, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Iic_subset_Iio.2 <| coe_lt_top a)]
#align with_top.image_coe_Iic WithTop.image_coe_Iic
-/

#print WithTop.image_coe_Icc /-
theorem image_coe_Icc : (coe : α → WithTop α) '' Icc a b = Icc a b := by
  rw [← preimage_coe_Icc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left
      (subset.trans Icc_subset_Iic_self <| Iic_subset_Iio.2 <| coe_lt_top b)]
#align with_top.image_coe_Icc WithTop.image_coe_Icc
-/

#print WithTop.image_coe_Ico /-
theorem image_coe_Ico : (coe : α → WithTop α) '' Ico a b = Ico a b := by
  rw [← preimage_coe_Ico, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ico_subset_Iio_self <| Iio_subset_Iio le_top)]
#align with_top.image_coe_Ico WithTop.image_coe_Ico
-/

#print WithTop.image_coe_Ioc /-
theorem image_coe_Ioc : (coe : α → WithTop α) '' Ioc a b = Ioc a b := by
  rw [← preimage_coe_Ioc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left
      (subset.trans Ioc_subset_Iic_self <| Iic_subset_Iio.2 <| coe_lt_top b)]
#align with_top.image_coe_Ioc WithTop.image_coe_Ioc
-/

#print WithTop.image_coe_Ioo /-
theorem image_coe_Ioo : (coe : α → WithTop α) '' Ioo a b = Ioo a b := by
  rw [← preimage_coe_Ioo, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ioo_subset_Iio_self <| Iio_subset_Iio le_top)]
#align with_top.image_coe_Ioo WithTop.image_coe_Ioo
-/

end WithTop

/-! ### `with_bot` -/


namespace WithBot

#print WithBot.preimage_coe_bot /-
@[simp]
theorem preimage_coe_bot : (coe : α → WithBot α) ⁻¹' {⊥} = (∅ : Set α) :=
  @WithTop.preimage_coe_top αᵒᵈ
#align with_bot.preimage_coe_bot WithBot.preimage_coe_bot
-/

variable [PartialOrder α] {a b : α}

#print WithBot.range_coe /-
theorem range_coe : range (coe : α → WithBot α) = Ioi ⊥ :=
  @WithTop.range_coe αᵒᵈ _
#align with_bot.range_coe WithBot.range_coe
-/

#print WithBot.preimage_coe_Ioi /-
@[simp]
theorem preimage_coe_Ioi : (coe : α → WithBot α) ⁻¹' Ioi a = Ioi a :=
  ext fun x => coe_lt_coe
#align with_bot.preimage_coe_Ioi WithBot.preimage_coe_Ioi
-/

#print WithBot.preimage_coe_Ici /-
@[simp]
theorem preimage_coe_Ici : (coe : α → WithBot α) ⁻¹' Ici a = Ici a :=
  ext fun x => coe_le_coe
#align with_bot.preimage_coe_Ici WithBot.preimage_coe_Ici
-/

#print WithBot.preimage_coe_Iio /-
@[simp]
theorem preimage_coe_Iio : (coe : α → WithBot α) ⁻¹' Iio a = Iio a :=
  ext fun x => coe_lt_coe
#align with_bot.preimage_coe_Iio WithBot.preimage_coe_Iio
-/

#print WithBot.preimage_coe_Iic /-
@[simp]
theorem preimage_coe_Iic : (coe : α → WithBot α) ⁻¹' Iic a = Iic a :=
  ext fun x => coe_le_coe
#align with_bot.preimage_coe_Iic WithBot.preimage_coe_Iic
-/

#print WithBot.preimage_coe_Icc /-
@[simp]
theorem preimage_coe_Icc : (coe : α → WithBot α) ⁻¹' Icc a b = Icc a b := by simp [← Ici_inter_Iic]
#align with_bot.preimage_coe_Icc WithBot.preimage_coe_Icc
-/

#print WithBot.preimage_coe_Ico /-
@[simp]
theorem preimage_coe_Ico : (coe : α → WithBot α) ⁻¹' Ico a b = Ico a b := by simp [← Ici_inter_Iio]
#align with_bot.preimage_coe_Ico WithBot.preimage_coe_Ico
-/

#print WithBot.preimage_coe_Ioc /-
@[simp]
theorem preimage_coe_Ioc : (coe : α → WithBot α) ⁻¹' Ioc a b = Ioc a b := by simp [← Ioi_inter_Iic]
#align with_bot.preimage_coe_Ioc WithBot.preimage_coe_Ioc
-/

#print WithBot.preimage_coe_Ioo /-
@[simp]
theorem preimage_coe_Ioo : (coe : α → WithBot α) ⁻¹' Ioo a b = Ioo a b := by simp [← Ioi_inter_Iio]
#align with_bot.preimage_coe_Ioo WithBot.preimage_coe_Ioo
-/

#print WithBot.preimage_coe_Ioi_bot /-
@[simp]
theorem preimage_coe_Ioi_bot : (coe : α → WithBot α) ⁻¹' Ioi ⊥ = univ := by
  rw [← range_coe, preimage_range]
#align with_bot.preimage_coe_Ioi_bot WithBot.preimage_coe_Ioi_bot
-/

#print WithBot.preimage_coe_Ioc_bot /-
@[simp]
theorem preimage_coe_Ioc_bot : (coe : α → WithBot α) ⁻¹' Ioc ⊥ a = Iic a := by
  simp [← Ioi_inter_Iic]
#align with_bot.preimage_coe_Ioc_bot WithBot.preimage_coe_Ioc_bot
-/

#print WithBot.preimage_coe_Ioo_bot /-
@[simp]
theorem preimage_coe_Ioo_bot : (coe : α → WithBot α) ⁻¹' Ioo ⊥ a = Iio a := by
  simp [← Ioi_inter_Iio]
#align with_bot.preimage_coe_Ioo_bot WithBot.preimage_coe_Ioo_bot
-/

#print WithBot.image_coe_Iio /-
theorem image_coe_Iio : (coe : α → WithBot α) '' Iio a = Ioo ⊥ a := by
  rw [← preimage_coe_Iio, image_preimage_eq_inter_range, range_coe, inter_comm, Ioi_inter_Iio]
#align with_bot.image_coe_Iio WithBot.image_coe_Iio
-/

#print WithBot.image_coe_Iic /-
theorem image_coe_Iic : (coe : α → WithBot α) '' Iic a = Ioc ⊥ a := by
  rw [← preimage_coe_Iic, image_preimage_eq_inter_range, range_coe, inter_comm, Ioi_inter_Iic]
#align with_bot.image_coe_Iic WithBot.image_coe_Iic
-/

#print WithBot.image_coe_Ioi /-
theorem image_coe_Ioi : (coe : α → WithBot α) '' Ioi a = Ioi a := by
  rw [← preimage_coe_Ioi, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Ioi_subset_Ioi bot_le)]
#align with_bot.image_coe_Ioi WithBot.image_coe_Ioi
-/

#print WithBot.image_coe_Ici /-
theorem image_coe_Ici : (coe : α → WithBot α) '' Ici a = Ici a := by
  rw [← preimage_coe_Ici, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Ici_subset_Ioi.2 <| bot_lt_coe a)]
#align with_bot.image_coe_Ici WithBot.image_coe_Ici
-/

#print WithBot.image_coe_Icc /-
theorem image_coe_Icc : (coe : α → WithBot α) '' Icc a b = Icc a b := by
  rw [← preimage_coe_Icc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left
      (subset.trans Icc_subset_Ici_self <| Ici_subset_Ioi.2 <| bot_lt_coe a)]
#align with_bot.image_coe_Icc WithBot.image_coe_Icc
-/

#print WithBot.image_coe_Ioc /-
theorem image_coe_Ioc : (coe : α → WithBot α) '' Ioc a b = Ioc a b := by
  rw [← preimage_coe_Ioc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ioc_subset_Ioi_self <| Ioi_subset_Ioi bot_le)]
#align with_bot.image_coe_Ioc WithBot.image_coe_Ioc
-/

#print WithBot.image_coe_Ico /-
theorem image_coe_Ico : (coe : α → WithBot α) '' Ico a b = Ico a b := by
  rw [← preimage_coe_Ico, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left
      (subset.trans Ico_subset_Ici_self <| Ici_subset_Ioi.2 <| bot_lt_coe a)]
#align with_bot.image_coe_Ico WithBot.image_coe_Ico
-/

#print WithBot.image_coe_Ioo /-
theorem image_coe_Ioo : (coe : α → WithBot α) '' Ioo a b = Ioo a b := by
  rw [← preimage_coe_Ioo, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ioo_subset_Ioi_self <| Ioi_subset_Ioi bot_le)]
#align with_bot.image_coe_Ioo WithBot.image_coe_Ioo
-/

end WithBot

