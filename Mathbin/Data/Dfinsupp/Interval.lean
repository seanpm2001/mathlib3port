/-
Copyright (c) 2021 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module data.dfinsupp.interval
! leanprover-community/mathlib commit b6da1a0b3e7cd83b1f744c49ce48ef8c6307d2f6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.LocallyFinite
import Mathbin.Data.Finset.Pointwise
import Mathbin.Data.Fintype.BigOperators
import Mathbin.Data.Dfinsupp.Order

/-!
# Finite intervals of finitely supported functions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides the `locally_finite_order` instance for `Π₀ i, α i` when `α` itself is locally
finite and calculates the cardinality of its finite intervals.
-/


open Dfinsupp Finset

open scoped BigOperators Pointwise

variable {ι : Type _} {α : ι → Type _}

namespace Finset

variable [DecidableEq ι] [∀ i, Zero (α i)] {s : Finset ι} {f : Π₀ i, α i} {t : ∀ i, Finset (α i)}

#print Finset.dfinsupp /-
/-- Finitely supported product of finsets. -/
def dfinsupp (s : Finset ι) (t : ∀ i, Finset (α i)) : Finset (Π₀ i, α i) :=
  (s.pi t).map
    ⟨fun f => Dfinsupp.mk s fun i => f i i.2,
      by
      refine' (mk_injective _).comp fun f g h => _
      ext i hi
      convert congr_fun h ⟨i, hi⟩⟩
#align finset.dfinsupp Finset.dfinsupp
-/

#print Finset.card_dfinsupp /-
@[simp]
theorem card_dfinsupp (s : Finset ι) (t : ∀ i, Finset (α i)) :
    (s.Dfinsupp t).card = ∏ i in s, (t i).card :=
  (card_map _).trans <| card_pi _ _
#align finset.card_dfinsupp Finset.card_dfinsupp
-/

variable [∀ i, DecidableEq (α i)]

#print Finset.mem_dfinsupp_iff /-
theorem mem_dfinsupp_iff : f ∈ s.Dfinsupp t ↔ f.support ⊆ s ∧ ∀ i ∈ s, f i ∈ t i :=
  by
  refine' mem_map.trans ⟨_, _⟩
  · rintro ⟨f, hf, rfl⟩
    refine' ⟨support_mk_subset, fun i hi => _⟩
    convert mem_pi.1 hf i hi
    exact mk_of_mem hi
  · refine' fun h => ⟨fun i _ => f i, mem_pi.2 h.2, _⟩
    ext i
    dsimp
    exact ite_eq_left_iff.2 fun hi => (not_mem_support_iff.1 fun H => hi <| h.1 H).symm
#align finset.mem_dfinsupp_iff Finset.mem_dfinsupp_iff
-/

#print Finset.mem_dfinsupp_iff_of_support_subset /-
/-- When `t` is supported on `s`, `f ∈ s.dfinsupp t` precisely means that `f` is pointwise in `t`.
-/
@[simp]
theorem mem_dfinsupp_iff_of_support_subset {t : Π₀ i, Finset (α i)} (ht : t.support ⊆ s) :
    f ∈ s.Dfinsupp t ↔ ∀ i, f i ∈ t i :=
  by
  refine'
    mem_dfinsupp_iff.trans
      (forall_and_distrib.symm.trans <|
        forall_congr' fun i =>
          ⟨fun h => _, fun h =>
            ⟨fun hi => ht <| mem_support_iff.2 fun H => mem_support_iff.1 hi _, fun _ => h⟩⟩)
  · by_cases hi : i ∈ s
    · exact h.2 hi
    · rw [not_mem_support_iff.1 (mt h.1 hi), not_mem_support_iff.1 (not_mem_mono ht hi)]
      exact zero_mem_zero
  · rwa [H, mem_zero] at h 
#align finset.mem_dfinsupp_iff_of_support_subset Finset.mem_dfinsupp_iff_of_support_subset
-/

end Finset

open Finset

namespace Dfinsupp

section BundledSingleton

variable [∀ i, Zero (α i)] {f : Π₀ i, α i} {i : ι} {a : α i}

#print Dfinsupp.singleton /-
/-- Pointwise `finset.singleton` bundled as a `dfinsupp`. -/
def singleton (f : Π₀ i, α i) : Π₀ i, Finset (α i)
    where
  toFun i := {f i}
  support' := f.support'.map fun s => ⟨s, fun i => (s.Prop i).imp id (congr_arg _)⟩
#align dfinsupp.singleton Dfinsupp.singleton
-/

#print Dfinsupp.mem_singleton_apply_iff /-
theorem mem_singleton_apply_iff : a ∈ f.singleton i ↔ a = f i :=
  mem_singleton
#align dfinsupp.mem_singleton_apply_iff Dfinsupp.mem_singleton_apply_iff
-/

end BundledSingleton

section BundledIcc

variable [∀ i, Zero (α i)] [∀ i, PartialOrder (α i)] [∀ i, LocallyFiniteOrder (α i)]
  {f g : Π₀ i, α i} {i : ι} {a : α i}

#print Dfinsupp.rangeIcc /-
/-- Pointwise `finset.Icc` bundled as a `dfinsupp`. -/
def rangeIcc (f g : Π₀ i, α i) : Π₀ i, Finset (α i)
    where
  toFun i := Icc (f i) (g i)
  support' :=
    f.support'.bind fun fs =>
      g.support'.map fun gs =>
        ⟨fs + gs, fun i =>
          or_iff_not_imp_left.2 fun h =>
            by
            have hf : f i = 0 :=
              (fs.prop i).resolve_left
                (Multiset.not_mem_mono (Multiset.Le.subset <| Multiset.le_add_right _ _) h)
            have hg : g i = 0 :=
              (gs.prop i).resolve_left
                (Multiset.not_mem_mono (Multiset.Le.subset <| Multiset.le_add_left _ _) h)
            rw [hf, hg]
            exact Icc_self _⟩
#align dfinsupp.range_Icc Dfinsupp.rangeIcc
-/

#print Dfinsupp.rangeIcc_apply /-
@[simp]
theorem rangeIcc_apply (f g : Π₀ i, α i) (i : ι) : f.rangeIcc g i = Icc (f i) (g i) :=
  rfl
#align dfinsupp.range_Icc_apply Dfinsupp.rangeIcc_apply
-/

#print Dfinsupp.mem_rangeIcc_apply_iff /-
theorem mem_rangeIcc_apply_iff : a ∈ f.rangeIcc g i ↔ f i ≤ a ∧ a ≤ g i :=
  mem_Icc
#align dfinsupp.mem_range_Icc_apply_iff Dfinsupp.mem_rangeIcc_apply_iff
-/

#print Dfinsupp.support_rangeIcc_subset /-
theorem support_rangeIcc_subset [DecidableEq ι] [∀ i, DecidableEq (α i)] :
    (f.rangeIcc g).support ⊆ f.support ∪ g.support :=
  by
  refine' fun x hx => _
  by_contra
  refine' not_mem_support_iff.2 _ hx
  rw [range_Icc_apply, not_mem_support_iff.1 (not_mem_mono (subset_union_left _ _) h),
    not_mem_support_iff.1 (not_mem_mono (subset_union_right _ _) h)]
  exact Icc_self _
#align dfinsupp.support_range_Icc_subset Dfinsupp.support_rangeIcc_subset
-/

end BundledIcc

section Pi

variable [∀ i, Zero (α i)] [DecidableEq ι] [∀ i, DecidableEq (α i)]

#print Dfinsupp.pi /-
/-- Given a finitely supported function `f : Π₀ i, finset (α i)`, one can define the finset
`f.pi` of all finitely supported functions whose value at `i` is in `f i` for all `i`. -/
def pi (f : Π₀ i, Finset (α i)) : Finset (Π₀ i, α i) :=
  f.support.Dfinsupp f
#align dfinsupp.pi Dfinsupp.pi
-/

#print Dfinsupp.mem_pi /-
@[simp]
theorem mem_pi {f : Π₀ i, Finset (α i)} {g : Π₀ i, α i} : g ∈ f.pi ↔ ∀ i, g i ∈ f i :=
  mem_dfinsupp_iff_of_support_subset <| Subset.refl _
#align dfinsupp.mem_pi Dfinsupp.mem_pi
-/

#print Dfinsupp.card_pi /-
@[simp]
theorem card_pi (f : Π₀ i, Finset (α i)) : f.pi.card = f.Prod fun i => (f i).card :=
  by
  rw [pi, card_dfinsupp]
  exact Finset.prod_congr rfl fun i _ => by simp only [Pi.nat_apply, Nat.cast_id]
#align dfinsupp.card_pi Dfinsupp.card_pi
-/

end Pi

section LocallyFinite

variable [DecidableEq ι] [∀ i, DecidableEq (α i)]

variable [∀ i, PartialOrder (α i)] [∀ i, Zero (α i)] [∀ i, LocallyFiniteOrder (α i)]

instance : LocallyFiniteOrder (Π₀ i, α i) :=
  LocallyFiniteOrder.ofIcc (Π₀ i, α i) (fun f g => (f.support ∪ g.support).Dfinsupp <| f.rangeIcc g)
    fun f g x =>
    by
    refine' (mem_dfinsupp_iff_of_support_subset <| support_range_Icc_subset).trans _
    simp_rw [mem_range_Icc_apply_iff, forall_and]
    rfl

variable (f g : Π₀ i, α i)

#print Dfinsupp.Icc_eq /-
theorem Icc_eq : Icc f g = (f.support ∪ g.support).Dfinsupp (f.rangeIcc g) :=
  rfl
#align dfinsupp.Icc_eq Dfinsupp.Icc_eq
-/

#print Dfinsupp.card_Icc /-
theorem card_Icc : (Icc f g).card = ∏ i in f.support ∪ g.support, (Icc (f i) (g i)).card :=
  card_dfinsupp _ _
#align dfinsupp.card_Icc Dfinsupp.card_Icc
-/

#print Dfinsupp.card_Ico /-
theorem card_Ico : (Ico f g).card = ∏ i in f.support ∪ g.support, (Icc (f i) (g i)).card - 1 := by
  rw [card_Ico_eq_card_Icc_sub_one, card_Icc]
#align dfinsupp.card_Ico Dfinsupp.card_Ico
-/

#print Dfinsupp.card_Ioc /-
theorem card_Ioc : (Ioc f g).card = ∏ i in f.support ∪ g.support, (Icc (f i) (g i)).card - 1 := by
  rw [card_Ioc_eq_card_Icc_sub_one, card_Icc]
#align dfinsupp.card_Ioc Dfinsupp.card_Ioc
-/

#print Dfinsupp.card_Ioo /-
theorem card_Ioo : (Ioo f g).card = ∏ i in f.support ∪ g.support, (Icc (f i) (g i)).card - 2 := by
  rw [card_Ioo_eq_card_Icc_sub_two, card_Icc]
#align dfinsupp.card_Ioo Dfinsupp.card_Ioo
-/

end LocallyFinite

section CanonicallyOrdered

variable [DecidableEq ι] [∀ i, DecidableEq (α i)]

variable [∀ i, CanonicallyOrderedAddMonoid (α i)] [∀ i, LocallyFiniteOrder (α i)]

variable (f : Π₀ i, α i)

#print Dfinsupp.card_Iic /-
theorem card_Iic : (Iic f).card = ∏ i in f.support, (Iic (f i)).card := by
  simp_rw [Iic_eq_Icc, card_Icc, Dfinsupp.bot_eq_zero, support_zero, empty_union, zero_apply,
    bot_eq_zero]
#align dfinsupp.card_Iic Dfinsupp.card_Iic
-/

#print Dfinsupp.card_Iio /-
theorem card_Iio : (Iio f).card = ∏ i in f.support, (Iic (f i)).card - 1 := by
  rw [card_Iio_eq_card_Iic_sub_one, card_Iic]
#align dfinsupp.card_Iio Dfinsupp.card_Iio
-/

end CanonicallyOrdered

end Dfinsupp

