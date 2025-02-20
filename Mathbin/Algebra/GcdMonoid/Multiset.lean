/-
Copyright (c) 2020 Aaron Anderson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson

! This file was ported from Lean 3 source module algebra.gcd_monoid.multiset
! leanprover-community/mathlib commit e04043d6bf7264a3c84bc69711dc354958ca4516
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GcdMonoid.Basic
import Mathbin.Data.Multiset.FinsetOps
import Mathbin.Data.Multiset.Fold

/-!
# GCD and LCM operations on multisets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

- `multiset.gcd` - the greatest common denominator of a `multiset` of elements of a `gcd_monoid`
- `multiset.lcm` - the least common multiple of a `multiset` of elements of a `gcd_monoid`

## Implementation notes

TODO: simplify with a tactic and `data.multiset.lattice`

## Tags

multiset, gcd
-/


namespace Multiset

variable {α : Type _} [CancelCommMonoidWithZero α] [NormalizedGCDMonoid α]

/-! ### lcm -/


section Lcm

#print Multiset.lcm /-
/-- Least common multiple of a multiset -/
def lcm (s : Multiset α) : α :=
  s.fold GCDMonoid.lcm 1
#align multiset.lcm Multiset.lcm
-/

#print Multiset.lcm_zero /-
@[simp]
theorem lcm_zero : (0 : Multiset α).lcm = 1 :=
  fold_zero _ _
#align multiset.lcm_zero Multiset.lcm_zero
-/

#print Multiset.lcm_cons /-
@[simp]
theorem lcm_cons (a : α) (s : Multiset α) : (a ::ₘ s).lcm = GCDMonoid.lcm a s.lcm :=
  fold_cons_left _ _ _ _
#align multiset.lcm_cons Multiset.lcm_cons
-/

#print Multiset.lcm_singleton /-
@[simp]
theorem lcm_singleton {a : α} : ({a} : Multiset α).lcm = normalize a :=
  (fold_singleton _ _ _).trans <| lcm_one_right _
#align multiset.lcm_singleton Multiset.lcm_singleton
-/

#print Multiset.lcm_add /-
@[simp]
theorem lcm_add (s₁ s₂ : Multiset α) : (s₁ + s₂).lcm = GCDMonoid.lcm s₁.lcm s₂.lcm :=
  Eq.trans (by simp [lcm]) (fold_add _ _ _ _ _)
#align multiset.lcm_add Multiset.lcm_add
-/

#print Multiset.lcm_dvd /-
theorem lcm_dvd {s : Multiset α} {a : α} : s.lcm ∣ a ↔ ∀ b ∈ s, b ∣ a :=
  Multiset.induction_on s (by simp)
    (by simp (config := { contextual := true }) [or_imp, forall_and, lcm_dvd_iff])
#align multiset.lcm_dvd Multiset.lcm_dvd
-/

#print Multiset.dvd_lcm /-
theorem dvd_lcm {s : Multiset α} {a : α} (h : a ∈ s) : a ∣ s.lcm :=
  lcm_dvd.1 dvd_rfl _ h
#align multiset.dvd_lcm Multiset.dvd_lcm
-/

#print Multiset.lcm_mono /-
theorem lcm_mono {s₁ s₂ : Multiset α} (h : s₁ ⊆ s₂) : s₁.lcm ∣ s₂.lcm :=
  lcm_dvd.2 fun b hb => dvd_lcm (h hb)
#align multiset.lcm_mono Multiset.lcm_mono
-/

#print Multiset.normalize_lcm /-
@[simp]
theorem normalize_lcm (s : Multiset α) : normalize s.lcm = s.lcm :=
  Multiset.induction_on s (by simp) fun a s IH => by simp
#align multiset.normalize_lcm Multiset.normalize_lcm
-/

#print Multiset.lcm_eq_zero_iff /-
@[simp]
theorem lcm_eq_zero_iff [Nontrivial α] (s : Multiset α) : s.lcm = 0 ↔ (0 : α) ∈ s :=
  by
  induction' s using Multiset.induction_on with a s ihs
  · simp only [lcm_zero, one_ne_zero, not_mem_zero]
  · simp only [mem_cons, lcm_cons, lcm_eq_zero_iff, ihs, @eq_comm _ a]
#align multiset.lcm_eq_zero_iff Multiset.lcm_eq_zero_iff
-/

variable [DecidableEq α]

#print Multiset.lcm_dedup /-
@[simp]
theorem lcm_dedup (s : Multiset α) : (dedup s).lcm = s.lcm :=
  Multiset.induction_on s (by simp) fun a s IH =>
    by
    by_cases a ∈ s <;> simp [IH, h]
    unfold lcm
    rw [← cons_erase h, fold_cons_left, ← lcm_assoc, lcm_same]
    apply lcm_eq_of_associated_left (associated_normalize _)
#align multiset.lcm_dedup Multiset.lcm_dedup
-/

#print Multiset.lcm_ndunion /-
@[simp]
theorem lcm_ndunion (s₁ s₂ : Multiset α) : (ndunion s₁ s₂).lcm = GCDMonoid.lcm s₁.lcm s₂.lcm := by
  rw [← lcm_dedup, dedup_ext.2, lcm_dedup, lcm_add]; simp
#align multiset.lcm_ndunion Multiset.lcm_ndunion
-/

#print Multiset.lcm_union /-
@[simp]
theorem lcm_union (s₁ s₂ : Multiset α) : (s₁ ∪ s₂).lcm = GCDMonoid.lcm s₁.lcm s₂.lcm := by
  rw [← lcm_dedup, dedup_ext.2, lcm_dedup, lcm_add]; simp
#align multiset.lcm_union Multiset.lcm_union
-/

#print Multiset.lcm_ndinsert /-
@[simp]
theorem lcm_ndinsert (a : α) (s : Multiset α) : (ndinsert a s).lcm = GCDMonoid.lcm a s.lcm := by
  rw [← lcm_dedup, dedup_ext.2, lcm_dedup, lcm_cons]; simp
#align multiset.lcm_ndinsert Multiset.lcm_ndinsert
-/

end Lcm

/-! ### gcd -/


section Gcd

#print Multiset.gcd /-
/-- Greatest common divisor of a multiset -/
def gcd (s : Multiset α) : α :=
  s.fold GCDMonoid.gcd 0
#align multiset.gcd Multiset.gcd
-/

#print Multiset.gcd_zero /-
@[simp]
theorem gcd_zero : (0 : Multiset α).gcd = 0 :=
  fold_zero _ _
#align multiset.gcd_zero Multiset.gcd_zero
-/

#print Multiset.gcd_cons /-
@[simp]
theorem gcd_cons (a : α) (s : Multiset α) : (a ::ₘ s).gcd = GCDMonoid.gcd a s.gcd :=
  fold_cons_left _ _ _ _
#align multiset.gcd_cons Multiset.gcd_cons
-/

#print Multiset.gcd_singleton /-
@[simp]
theorem gcd_singleton {a : α} : ({a} : Multiset α).gcd = normalize a :=
  (fold_singleton _ _ _).trans <| gcd_zero_right _
#align multiset.gcd_singleton Multiset.gcd_singleton
-/

#print Multiset.gcd_add /-
@[simp]
theorem gcd_add (s₁ s₂ : Multiset α) : (s₁ + s₂).gcd = GCDMonoid.gcd s₁.gcd s₂.gcd :=
  Eq.trans (by simp [gcd]) (fold_add _ _ _ _ _)
#align multiset.gcd_add Multiset.gcd_add
-/

#print Multiset.dvd_gcd /-
theorem dvd_gcd {s : Multiset α} {a : α} : a ∣ s.gcd ↔ ∀ b ∈ s, a ∣ b :=
  Multiset.induction_on s (by simp)
    (by simp (config := { contextual := true }) [or_imp, forall_and, dvd_gcd_iff])
#align multiset.dvd_gcd Multiset.dvd_gcd
-/

#print Multiset.gcd_dvd /-
theorem gcd_dvd {s : Multiset α} {a : α} (h : a ∈ s) : s.gcd ∣ a :=
  dvd_gcd.1 dvd_rfl _ h
#align multiset.gcd_dvd Multiset.gcd_dvd
-/

#print Multiset.gcd_mono /-
theorem gcd_mono {s₁ s₂ : Multiset α} (h : s₁ ⊆ s₂) : s₂.gcd ∣ s₁.gcd :=
  dvd_gcd.2 fun b hb => gcd_dvd (h hb)
#align multiset.gcd_mono Multiset.gcd_mono
-/

#print Multiset.normalize_gcd /-
@[simp]
theorem normalize_gcd (s : Multiset α) : normalize s.gcd = s.gcd :=
  Multiset.induction_on s (by simp) fun a s IH => by simp
#align multiset.normalize_gcd Multiset.normalize_gcd
-/

#print Multiset.gcd_eq_zero_iff /-
theorem gcd_eq_zero_iff (s : Multiset α) : s.gcd = 0 ↔ ∀ x : α, x ∈ s → x = 0 :=
  by
  constructor
  · intro h x hx
    apply eq_zero_of_zero_dvd
    rw [← h]
    apply gcd_dvd hx
  · apply s.induction_on
    · simp
    intro a s sgcd h
    simp [h a (mem_cons_self a s), sgcd fun x hx => h x (mem_cons_of_mem hx)]
#align multiset.gcd_eq_zero_iff Multiset.gcd_eq_zero_iff
-/

#print Multiset.gcd_map_mul /-
theorem gcd_map_mul (a : α) (s : Multiset α) : (s.map ((· * ·) a)).gcd = normalize a * s.gcd :=
  by
  refine' s.induction_on _ fun b s ih => _
  · simp_rw [map_zero, gcd_zero, MulZeroClass.mul_zero]
  · simp_rw [map_cons, gcd_cons, ← gcd_mul_left]; rw [ih]
    apply ((normalize_associated a).mul_right _).gcd_eq_right
#align multiset.gcd_map_mul Multiset.gcd_map_mul
-/

section

variable [DecidableEq α]

#print Multiset.gcd_dedup /-
@[simp]
theorem gcd_dedup (s : Multiset α) : (dedup s).gcd = s.gcd :=
  Multiset.induction_on s (by simp) fun a s IH =>
    by
    by_cases a ∈ s <;> simp [IH, h]
    unfold gcd
    rw [← cons_erase h, fold_cons_left, ← gcd_assoc, gcd_same]
    apply (associated_normalize _).gcd_eq_left
#align multiset.gcd_dedup Multiset.gcd_dedup
-/

#print Multiset.gcd_ndunion /-
@[simp]
theorem gcd_ndunion (s₁ s₂ : Multiset α) : (ndunion s₁ s₂).gcd = GCDMonoid.gcd s₁.gcd s₂.gcd := by
  rw [← gcd_dedup, dedup_ext.2, gcd_dedup, gcd_add]; simp
#align multiset.gcd_ndunion Multiset.gcd_ndunion
-/

#print Multiset.gcd_union /-
@[simp]
theorem gcd_union (s₁ s₂ : Multiset α) : (s₁ ∪ s₂).gcd = GCDMonoid.gcd s₁.gcd s₂.gcd := by
  rw [← gcd_dedup, dedup_ext.2, gcd_dedup, gcd_add]; simp
#align multiset.gcd_union Multiset.gcd_union
-/

#print Multiset.gcd_ndinsert /-
@[simp]
theorem gcd_ndinsert (a : α) (s : Multiset α) : (ndinsert a s).gcd = GCDMonoid.gcd a s.gcd := by
  rw [← gcd_dedup, dedup_ext.2, gcd_dedup, gcd_cons]; simp
#align multiset.gcd_ndinsert Multiset.gcd_ndinsert
-/

end

#print Multiset.extract_gcd' /-
theorem extract_gcd' (s t : Multiset α) (hs : ∃ x, x ∈ s ∧ x ≠ (0 : α))
    (ht : s = t.map ((· * ·) s.gcd)) : t.gcd = 1 :=
  ((@mul_right_eq_self₀ _ _ s.gcd _).1 <| by
        conv_lhs => rw [← normalize_gcd, ← gcd_map_mul, ← ht]).resolve_right <|
    by contrapose! hs; exact s.gcd_eq_zero_iff.1 hs
#align multiset.extract_gcd' Multiset.extract_gcd'
-/

#print Multiset.extract_gcd /-
theorem extract_gcd (s : Multiset α) (hs : s ≠ 0) :
    ∃ t : Multiset α, s = t.map ((· * ·) s.gcd) ∧ t.gcd = 1 := by
  classical
  by_cases h : ∀ x ∈ s, x = (0 : α)
  · use replicate s.card 1
    rw [map_replicate, eq_replicate, mul_one, s.gcd_eq_zero_iff.2 h, ← nsmul_singleton, ← gcd_dedup]
    rw [dedup_nsmul (card_pos.2 hs).ne', dedup_singleton, gcd_singleton]
    exact ⟨⟨rfl, h⟩, normalize_one⟩
  · choose f hf using @gcd_dvd _ _ _ s
    have := _; push_neg at h 
    refine' ⟨s.pmap @f fun _ => id, this, extract_gcd' s _ h this⟩
    rw [map_pmap]; conv_lhs => rw [← s.map_id, ← s.pmap_eq_map _ _ fun _ => id]
    congr with (x hx); rw [id, ← hf hx]
#align multiset.extract_gcd Multiset.extract_gcd
-/

end Gcd

end Multiset

