/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.multiset.lattice
! leanprover-community/mathlib commit f2f413b9d4be3a02840d0663dace76e8fe3da053
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Multiset.FinsetOps
import Mathbin.Data.Multiset.Fold

/-!
# Lattice operations on multisets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


namespace Multiset

variable {α : Type _}

/-! ### sup -/


section Sup

-- can be defined with just `[has_bot α]` where some lemmas hold without requiring `[order_bot α]`
variable [SemilatticeSup α] [OrderBot α]

#print Multiset.sup /-
/-- Supremum of a multiset: `sup {a, b, c} = a ⊔ b ⊔ c` -/
def sup (s : Multiset α) : α :=
  s.fold (· ⊔ ·) ⊥
#align multiset.sup Multiset.sup
-/

#print Multiset.sup_coe /-
@[simp]
theorem sup_coe (l : List α) : sup (l : Multiset α) = l.foldr (· ⊔ ·) ⊥ :=
  rfl
#align multiset.sup_coe Multiset.sup_coe
-/

#print Multiset.sup_zero /-
@[simp]
theorem sup_zero : (0 : Multiset α).sup = ⊥ :=
  fold_zero _ _
#align multiset.sup_zero Multiset.sup_zero
-/

#print Multiset.sup_cons /-
@[simp]
theorem sup_cons (a : α) (s : Multiset α) : (a ::ₘ s).sup = a ⊔ s.sup :=
  fold_cons_left _ _ _ _
#align multiset.sup_cons Multiset.sup_cons
-/

#print Multiset.sup_singleton /-
@[simp]
theorem sup_singleton {a : α} : ({a} : Multiset α).sup = a :=
  sup_bot_eq
#align multiset.sup_singleton Multiset.sup_singleton
-/

#print Multiset.sup_add /-
@[simp]
theorem sup_add (s₁ s₂ : Multiset α) : (s₁ + s₂).sup = s₁.sup ⊔ s₂.sup :=
  Eq.trans (by simp [sup]) (fold_add _ _ _ _ _)
#align multiset.sup_add Multiset.sup_add
-/

#print Multiset.sup_le /-
theorem sup_le {s : Multiset α} {a : α} : s.sup ≤ a ↔ ∀ b ∈ s, b ≤ a :=
  Multiset.induction_on s (by simp)
    (by simp (config := { contextual := true }) [or_imp, forall_and])
#align multiset.sup_le Multiset.sup_le
-/

#print Multiset.le_sup /-
theorem le_sup {s : Multiset α} {a : α} (h : a ∈ s) : a ≤ s.sup :=
  sup_le.1 le_rfl _ h
#align multiset.le_sup Multiset.le_sup
-/

#print Multiset.sup_mono /-
theorem sup_mono {s₁ s₂ : Multiset α} (h : s₁ ⊆ s₂) : s₁.sup ≤ s₂.sup :=
  sup_le.2 fun b hb => le_sup (h hb)
#align multiset.sup_mono Multiset.sup_mono
-/

variable [DecidableEq α]

#print Multiset.sup_dedup /-
@[simp]
theorem sup_dedup (s : Multiset α) : (dedup s).sup = s.sup :=
  fold_dedup_idem _ _ _
#align multiset.sup_dedup Multiset.sup_dedup
-/

#print Multiset.sup_ndunion /-
@[simp]
theorem sup_ndunion (s₁ s₂ : Multiset α) : (ndunion s₁ s₂).sup = s₁.sup ⊔ s₂.sup := by
  rw [← sup_dedup, dedup_ext.2, sup_dedup, sup_add] <;> simp
#align multiset.sup_ndunion Multiset.sup_ndunion
-/

#print Multiset.sup_union /-
@[simp]
theorem sup_union (s₁ s₂ : Multiset α) : (s₁ ∪ s₂).sup = s₁.sup ⊔ s₂.sup := by
  rw [← sup_dedup, dedup_ext.2, sup_dedup, sup_add] <;> simp
#align multiset.sup_union Multiset.sup_union
-/

#print Multiset.sup_ndinsert /-
@[simp]
theorem sup_ndinsert (a : α) (s : Multiset α) : (ndinsert a s).sup = a ⊔ s.sup := by
  rw [← sup_dedup, dedup_ext.2, sup_dedup, sup_cons] <;> simp
#align multiset.sup_ndinsert Multiset.sup_ndinsert
-/

#print Multiset.nodup_sup_iff /-
theorem nodup_sup_iff {α : Type _} [DecidableEq α] {m : Multiset (Multiset α)} :
    m.sup.Nodup ↔ ∀ a : Multiset α, a ∈ m → a.Nodup :=
  by
  apply m.induction_on
  · simp
  · intro a s h
    simp [h]
#align multiset.nodup_sup_iff Multiset.nodup_sup_iff
-/

end Sup

/-! ### inf -/


section Inf

-- can be defined with just `[has_top α]` where some lemmas hold without requiring `[order_top α]`
variable [SemilatticeInf α] [OrderTop α]

#print Multiset.inf /-
/-- Infimum of a multiset: `inf {a, b, c} = a ⊓ b ⊓ c` -/
def inf (s : Multiset α) : α :=
  s.fold (· ⊓ ·) ⊤
#align multiset.inf Multiset.inf
-/

#print Multiset.inf_coe /-
@[simp]
theorem inf_coe (l : List α) : inf (l : Multiset α) = l.foldr (· ⊓ ·) ⊤ :=
  rfl
#align multiset.inf_coe Multiset.inf_coe
-/

#print Multiset.inf_zero /-
@[simp]
theorem inf_zero : (0 : Multiset α).inf = ⊤ :=
  fold_zero _ _
#align multiset.inf_zero Multiset.inf_zero
-/

#print Multiset.inf_cons /-
@[simp]
theorem inf_cons (a : α) (s : Multiset α) : (a ::ₘ s).inf = a ⊓ s.inf :=
  fold_cons_left _ _ _ _
#align multiset.inf_cons Multiset.inf_cons
-/

#print Multiset.inf_singleton /-
@[simp]
theorem inf_singleton {a : α} : ({a} : Multiset α).inf = a :=
  inf_top_eq
#align multiset.inf_singleton Multiset.inf_singleton
-/

#print Multiset.inf_add /-
@[simp]
theorem inf_add (s₁ s₂ : Multiset α) : (s₁ + s₂).inf = s₁.inf ⊓ s₂.inf :=
  Eq.trans (by simp [inf]) (fold_add _ _ _ _ _)
#align multiset.inf_add Multiset.inf_add
-/

#print Multiset.le_inf /-
theorem le_inf {s : Multiset α} {a : α} : a ≤ s.inf ↔ ∀ b ∈ s, a ≤ b :=
  Multiset.induction_on s (by simp)
    (by simp (config := { contextual := true }) [or_imp, forall_and])
#align multiset.le_inf Multiset.le_inf
-/

#print Multiset.inf_le /-
theorem inf_le {s : Multiset α} {a : α} (h : a ∈ s) : s.inf ≤ a :=
  le_inf.1 le_rfl _ h
#align multiset.inf_le Multiset.inf_le
-/

#print Multiset.inf_mono /-
theorem inf_mono {s₁ s₂ : Multiset α} (h : s₁ ⊆ s₂) : s₂.inf ≤ s₁.inf :=
  le_inf.2 fun b hb => inf_le (h hb)
#align multiset.inf_mono Multiset.inf_mono
-/

variable [DecidableEq α]

#print Multiset.inf_dedup /-
@[simp]
theorem inf_dedup (s : Multiset α) : (dedup s).inf = s.inf :=
  fold_dedup_idem _ _ _
#align multiset.inf_dedup Multiset.inf_dedup
-/

#print Multiset.inf_ndunion /-
@[simp]
theorem inf_ndunion (s₁ s₂ : Multiset α) : (ndunion s₁ s₂).inf = s₁.inf ⊓ s₂.inf := by
  rw [← inf_dedup, dedup_ext.2, inf_dedup, inf_add] <;> simp
#align multiset.inf_ndunion Multiset.inf_ndunion
-/

#print Multiset.inf_union /-
@[simp]
theorem inf_union (s₁ s₂ : Multiset α) : (s₁ ∪ s₂).inf = s₁.inf ⊓ s₂.inf := by
  rw [← inf_dedup, dedup_ext.2, inf_dedup, inf_add] <;> simp
#align multiset.inf_union Multiset.inf_union
-/

#print Multiset.inf_ndinsert /-
@[simp]
theorem inf_ndinsert (a : α) (s : Multiset α) : (ndinsert a s).inf = a ⊓ s.inf := by
  rw [← inf_dedup, dedup_ext.2, inf_dedup, inf_cons] <;> simp
#align multiset.inf_ndinsert Multiset.inf_ndinsert
-/

end Inf

end Multiset

