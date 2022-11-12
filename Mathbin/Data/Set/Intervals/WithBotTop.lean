/-
Copyright (c) 2022 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov
-/
import Mathbin.Data.Set.Intervals.Basic

/-!
# Intervals in `with_top α` and `with_bot α`

In this file we prove various lemmas about `set.image`s and `set.preimage`s of intervals under
`coe : α → with_top α` and `coe : α → with_bot α`.
-/


open Set

variable {α : Type _}

/-! ### `with_top` -/


namespace WithTop

@[simp]
theorem preimage_coe_top : (coe : α → WithTop α) ⁻¹' {⊤} = (∅ : Set α) :=
  eq_empty_of_subset_empty fun a => coe_ne_top
#align with_top.preimage_coe_top WithTop.preimage_coe_top

variable [PartialOrder α] {a b : α}

theorem range_coe : Range (coe : α → WithTop α) = IioCat ⊤ := by
  ext x
  rw [mem_Iio, lt_top_iff_ne_top, mem_range, ← none_eq_top, Option.ne_none_iff_exists]
  rfl
#align with_top.range_coe WithTop.range_coe

@[simp]
theorem preimage_coe_Ioi : (coe : α → WithTop α) ⁻¹' IoiCat a = IoiCat a :=
  ext fun x => coe_lt_coe
#align with_top.preimage_coe_Ioi WithTop.preimage_coe_Ioi

@[simp]
theorem preimage_coe_Ici : (coe : α → WithTop α) ⁻¹' IciCat a = IciCat a :=
  ext fun x => coe_le_coe
#align with_top.preimage_coe_Ici WithTop.preimage_coe_Ici

@[simp]
theorem preimage_coe_Iio : (coe : α → WithTop α) ⁻¹' IioCat a = IioCat a :=
  ext fun x => coe_lt_coe
#align with_top.preimage_coe_Iio WithTop.preimage_coe_Iio

@[simp]
theorem preimage_coe_Iic : (coe : α → WithTop α) ⁻¹' IicCat a = IicCat a :=
  ext fun x => coe_le_coe
#align with_top.preimage_coe_Iic WithTop.preimage_coe_Iic

@[simp]
theorem preimage_coe_Icc : (coe : α → WithTop α) ⁻¹' IccCat a b = IccCat a b := by simp [← Ici_inter_Iic]
#align with_top.preimage_coe_Icc WithTop.preimage_coe_Icc

@[simp]
theorem preimage_coe_Ico : (coe : α → WithTop α) ⁻¹' IcoCat a b = IcoCat a b := by simp [← Ici_inter_Iio]
#align with_top.preimage_coe_Ico WithTop.preimage_coe_Ico

@[simp]
theorem preimage_coe_Ioc : (coe : α → WithTop α) ⁻¹' IocCat a b = IocCat a b := by simp [← Ioi_inter_Iic]
#align with_top.preimage_coe_Ioc WithTop.preimage_coe_Ioc

@[simp]
theorem preimage_coe_Ioo : (coe : α → WithTop α) ⁻¹' IooCat a b = IooCat a b := by simp [← Ioi_inter_Iio]
#align with_top.preimage_coe_Ioo WithTop.preimage_coe_Ioo

@[simp]
theorem preimage_coe_Iio_top : (coe : α → WithTop α) ⁻¹' IioCat ⊤ = univ := by rw [← range_coe, preimage_range]
#align with_top.preimage_coe_Iio_top WithTop.preimage_coe_Iio_top

@[simp]
theorem preimage_coe_Ico_top : (coe : α → WithTop α) ⁻¹' IcoCat a ⊤ = IciCat a := by simp [← Ici_inter_Iio]
#align with_top.preimage_coe_Ico_top WithTop.preimage_coe_Ico_top

@[simp]
theorem preimage_coe_Ioo_top : (coe : α → WithTop α) ⁻¹' IooCat a ⊤ = IoiCat a := by simp [← Ioi_inter_Iio]
#align with_top.preimage_coe_Ioo_top WithTop.preimage_coe_Ioo_top

theorem image_coe_Ioi : (coe : α → WithTop α) '' IoiCat a = IooCat a ⊤ := by
  rw [← preimage_coe_Ioi, image_preimage_eq_inter_range, range_coe, Ioi_inter_Iio]
#align with_top.image_coe_Ioi WithTop.image_coe_Ioi

theorem image_coe_Ici : (coe : α → WithTop α) '' IciCat a = IcoCat a ⊤ := by
  rw [← preimage_coe_Ici, image_preimage_eq_inter_range, range_coe, Ici_inter_Iio]
#align with_top.image_coe_Ici WithTop.image_coe_Ici

theorem image_coe_Iio : (coe : α → WithTop α) '' IioCat a = IioCat a := by
  rw [← preimage_coe_Iio, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Iio_subset_Iio le_top)]
#align with_top.image_coe_Iio WithTop.image_coe_Iio

theorem image_coe_Iic : (coe : α → WithTop α) '' IicCat a = IicCat a := by
  rw [← preimage_coe_Iic, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Iic_subset_Iio.2 <| coe_lt_top a)]
#align with_top.image_coe_Iic WithTop.image_coe_Iic

theorem image_coe_Icc : (coe : α → WithTop α) '' IccCat a b = IccCat a b := by
  rw [← preimage_coe_Icc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Icc_subset_Iic_self <| Iic_subset_Iio.2 <| coe_lt_top b)]
#align with_top.image_coe_Icc WithTop.image_coe_Icc

theorem image_coe_Ico : (coe : α → WithTop α) '' IcoCat a b = IcoCat a b := by
  rw [← preimage_coe_Ico, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ico_subset_Iio_self <| Iio_subset_Iio le_top)]
#align with_top.image_coe_Ico WithTop.image_coe_Ico

theorem image_coe_Ioc : (coe : α → WithTop α) '' IocCat a b = IocCat a b := by
  rw [← preimage_coe_Ioc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ioc_subset_Iic_self <| Iic_subset_Iio.2 <| coe_lt_top b)]
#align with_top.image_coe_Ioc WithTop.image_coe_Ioc

theorem image_coe_Ioo : (coe : α → WithTop α) '' IooCat a b = IooCat a b := by
  rw [← preimage_coe_Ioo, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ioo_subset_Iio_self <| Iio_subset_Iio le_top)]
#align with_top.image_coe_Ioo WithTop.image_coe_Ioo

end WithTop

/-! ### `with_bot` -/


namespace WithBot

@[simp]
theorem preimage_coe_bot : (coe : α → WithBot α) ⁻¹' {⊥} = (∅ : Set α) :=
  @WithTop.preimage_coe_top αᵒᵈ
#align with_bot.preimage_coe_bot WithBot.preimage_coe_bot

variable [PartialOrder α] {a b : α}

theorem range_coe : Range (coe : α → WithBot α) = IoiCat ⊥ :=
  @WithTop.range_coe αᵒᵈ _
#align with_bot.range_coe WithBot.range_coe

@[simp]
theorem preimage_coe_Ioi : (coe : α → WithBot α) ⁻¹' IoiCat a = IoiCat a :=
  ext fun x => coe_lt_coe
#align with_bot.preimage_coe_Ioi WithBot.preimage_coe_Ioi

@[simp]
theorem preimage_coe_Ici : (coe : α → WithBot α) ⁻¹' IciCat a = IciCat a :=
  ext fun x => coe_le_coe
#align with_bot.preimage_coe_Ici WithBot.preimage_coe_Ici

@[simp]
theorem preimage_coe_Iio : (coe : α → WithBot α) ⁻¹' IioCat a = IioCat a :=
  ext fun x => coe_lt_coe
#align with_bot.preimage_coe_Iio WithBot.preimage_coe_Iio

@[simp]
theorem preimage_coe_Iic : (coe : α → WithBot α) ⁻¹' IicCat a = IicCat a :=
  ext fun x => coe_le_coe
#align with_bot.preimage_coe_Iic WithBot.preimage_coe_Iic

@[simp]
theorem preimage_coe_Icc : (coe : α → WithBot α) ⁻¹' IccCat a b = IccCat a b := by simp [← Ici_inter_Iic]
#align with_bot.preimage_coe_Icc WithBot.preimage_coe_Icc

@[simp]
theorem preimage_coe_Ico : (coe : α → WithBot α) ⁻¹' IcoCat a b = IcoCat a b := by simp [← Ici_inter_Iio]
#align with_bot.preimage_coe_Ico WithBot.preimage_coe_Ico

@[simp]
theorem preimage_coe_Ioc : (coe : α → WithBot α) ⁻¹' IocCat a b = IocCat a b := by simp [← Ioi_inter_Iic]
#align with_bot.preimage_coe_Ioc WithBot.preimage_coe_Ioc

@[simp]
theorem preimage_coe_Ioo : (coe : α → WithBot α) ⁻¹' IooCat a b = IooCat a b := by simp [← Ioi_inter_Iio]
#align with_bot.preimage_coe_Ioo WithBot.preimage_coe_Ioo

@[simp]
theorem preimage_coe_Ioi_bot : (coe : α → WithBot α) ⁻¹' IoiCat ⊥ = univ := by rw [← range_coe, preimage_range]
#align with_bot.preimage_coe_Ioi_bot WithBot.preimage_coe_Ioi_bot

@[simp]
theorem preimage_coe_Ioc_bot : (coe : α → WithBot α) ⁻¹' IocCat ⊥ a = IicCat a := by simp [← Ioi_inter_Iic]
#align with_bot.preimage_coe_Ioc_bot WithBot.preimage_coe_Ioc_bot

@[simp]
theorem preimage_coe_Ioo_bot : (coe : α → WithBot α) ⁻¹' IooCat ⊥ a = IioCat a := by simp [← Ioi_inter_Iio]
#align with_bot.preimage_coe_Ioo_bot WithBot.preimage_coe_Ioo_bot

theorem image_coe_Iio : (coe : α → WithBot α) '' IioCat a = IooCat ⊥ a := by
  rw [← preimage_coe_Iio, image_preimage_eq_inter_range, range_coe, inter_comm, Ioi_inter_Iio]
#align with_bot.image_coe_Iio WithBot.image_coe_Iio

theorem image_coe_Iic : (coe : α → WithBot α) '' IicCat a = IocCat ⊥ a := by
  rw [← preimage_coe_Iic, image_preimage_eq_inter_range, range_coe, inter_comm, Ioi_inter_Iic]
#align with_bot.image_coe_Iic WithBot.image_coe_Iic

theorem image_coe_Ioi : (coe : α → WithBot α) '' IoiCat a = IoiCat a := by
  rw [← preimage_coe_Ioi, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Ioi_subset_Ioi bot_le)]
#align with_bot.image_coe_Ioi WithBot.image_coe_Ioi

theorem image_coe_Ici : (coe : α → WithBot α) '' IciCat a = IciCat a := by
  rw [← preimage_coe_Ici, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (Ici_subset_Ioi.2 <| bot_lt_coe a)]
#align with_bot.image_coe_Ici WithBot.image_coe_Ici

theorem image_coe_Icc : (coe : α → WithBot α) '' IccCat a b = IccCat a b := by
  rw [← preimage_coe_Icc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Icc_subset_Ici_self <| Ici_subset_Ioi.2 <| bot_lt_coe a)]
#align with_bot.image_coe_Icc WithBot.image_coe_Icc

theorem image_coe_Ioc : (coe : α → WithBot α) '' IocCat a b = IocCat a b := by
  rw [← preimage_coe_Ioc, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ioc_subset_Ioi_self <| Ioi_subset_Ioi bot_le)]
#align with_bot.image_coe_Ioc WithBot.image_coe_Ioc

theorem image_coe_Ico : (coe : α → WithBot α) '' IcoCat a b = IcoCat a b := by
  rw [← preimage_coe_Ico, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ico_subset_Ici_self <| Ici_subset_Ioi.2 <| bot_lt_coe a)]
#align with_bot.image_coe_Ico WithBot.image_coe_Ico

theorem image_coe_Ioo : (coe : α → WithBot α) '' IooCat a b = IooCat a b := by
  rw [← preimage_coe_Ioo, image_preimage_eq_inter_range, range_coe,
    inter_eq_self_of_subset_left (subset.trans Ioo_subset_Ioi_self <| Ioi_subset_Ioi bot_le)]
#align with_bot.image_coe_Ioo WithBot.image_coe_Ioo

end WithBot

