/-
Copyright (c) 2020 Zhouhang Zhou. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Zhouhang Zhou

! This file was ported from Lean 3 source module data.set.intervals.unordered_interval
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Bounds.Basic
import Mathbin.Data.Set.Intervals.Basic

/-!
# Intervals without endpoints ordering

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In any lattice `α`, we define `interval a b` to be `Icc (a ⊓ b) (a ⊔ b)`, which in a linear order is
the set of elements lying between `a` and `b`.

`Icc a b` requires the assumption `a ≤ b` to be meaningful, which is sometimes inconvenient. The
interval as defined in this file is always the set of things lying between `a` and `b`, regardless
of the relative order of `a` and `b`.

For real numbers, `interval a b` is the same as `segment ℝ a b`.

In a product or pi type, `interval a b` is the smallest box containing `a` and `b`. For example,
`interval (1, -1) (-1, 1) = Icc (-1, -1) (1, 1)` is the square of vertices `(1, -1)`, `(-1, -1)`,
`(-1, 1)`, `(1, 1)`.

In `finset α` (seen as a hypercube of dimension `fintype.card α`), `interval a b` is the smallest
subcube containing both `a` and `b`.

## Notation

We use the localized notation `[a, b]` for `interval a b`. One can open the locale `interval` to
make the notation available.

-/


open Function

open OrderDual (toDual ofDual)

variable {α β : Type _}

namespace Set

section Lattice

variable [Lattice α] {a a₁ a₂ b b₁ b₂ c x : α}

#print Set.interval /-
/-- `interval a b` is the set of elements lying between `a` and `b`, with `a` and `b` included.
Note that we define it more generally in a lattice as `set.Icc (a ⊓ b) (a ⊔ b)`. In a product type,
`interval` corresponds to the bounding box of the two elements. -/
def interval (a b : α) : Set α :=
  Icc (a ⊓ b) (a ⊔ b)
#align set.interval Set.interval
-/

-- mathport name: set.interval
scoped[Interval] notation "[" a ", " b "]" => Set.interval a b

#print Set.dual_interval /-
@[simp]
theorem dual_interval (a b : α) : [toDual a, toDual b] = of_dual ⁻¹' [a, b] :=
  dual_Icc
#align set.dual_interval Set.dual_interval
-/

#print Set.interval_of_le /-
@[simp]
theorem interval_of_le (h : a ≤ b) : [a, b] = Icc a b := by
  rw [interval, inf_eq_left.2 h, sup_eq_right.2 h]
#align set.interval_of_le Set.interval_of_le
-/

#print Set.interval_of_ge /-
@[simp]
theorem interval_of_ge (h : b ≤ a) : [a, b] = Icc b a := by
  rw [interval, inf_eq_right.2 h, sup_eq_left.2 h]
#align set.interval_of_ge Set.interval_of_ge
-/

#print Set.interval_swap /-
theorem interval_swap (a b : α) : [a, b] = [b, a] := by simp_rw [interval, inf_comm, sup_comm]
#align set.interval_swap Set.interval_swap
-/

#print Set.interval_of_lt /-
theorem interval_of_lt (h : a < b) : [a, b] = Icc a b :=
  interval_of_le (le_of_lt h)
#align set.interval_of_lt Set.interval_of_lt
-/

#print Set.interval_of_gt /-
theorem interval_of_gt (h : b < a) : [a, b] = Icc b a :=
  interval_of_ge (le_of_lt h)
#align set.interval_of_gt Set.interval_of_gt
-/

#print Set.interval_self /-
@[simp]
theorem interval_self : [a, a] = {a} := by simp [interval]
#align set.interval_self Set.interval_self
-/

#print Set.nonempty_interval /-
@[simp]
theorem nonempty_interval : [a, b].Nonempty :=
  nonempty_Icc.2 inf_le_sup
#align set.nonempty_interval Set.nonempty_interval
-/

#print Set.Icc_subset_interval /-
theorem Icc_subset_interval : Icc a b ⊆ [a, b] :=
  Icc_subset_Icc inf_le_left le_sup_right
#align set.Icc_subset_interval Set.Icc_subset_interval
-/

#print Set.Icc_subset_interval' /-
theorem Icc_subset_interval' : Icc b a ⊆ [a, b] :=
  Icc_subset_Icc inf_le_right le_sup_left
#align set.Icc_subset_interval' Set.Icc_subset_interval'
-/

#print Set.left_mem_interval /-
@[simp]
theorem left_mem_interval : a ∈ [a, b] :=
  ⟨inf_le_left, le_sup_left⟩
#align set.left_mem_interval Set.left_mem_interval
-/

#print Set.right_mem_interval /-
@[simp]
theorem right_mem_interval : b ∈ [a, b] :=
  ⟨inf_le_right, le_sup_right⟩
#align set.right_mem_interval Set.right_mem_interval
-/

#print Set.mem_interval_of_le /-
theorem mem_interval_of_le (ha : a ≤ x) (hb : x ≤ b) : x ∈ [a, b] :=
  Icc_subset_interval ⟨ha, hb⟩
#align set.mem_interval_of_le Set.mem_interval_of_le
-/

#print Set.mem_interval_of_ge /-
theorem mem_interval_of_ge (hb : b ≤ x) (ha : x ≤ a) : x ∈ [a, b] :=
  Icc_subset_interval' ⟨hb, ha⟩
#align set.mem_interval_of_ge Set.mem_interval_of_ge
-/

#print Set.interval_subset_interval /-
theorem interval_subset_interval (h₁ : a₁ ∈ [a₂, b₂]) (h₂ : b₁ ∈ [a₂, b₂]) : [a₁, b₁] ⊆ [a₂, b₂] :=
  Icc_subset_Icc (le_inf h₁.1 h₂.1) (sup_le h₁.2 h₂.2)
#align set.interval_subset_interval Set.interval_subset_interval
-/

#print Set.interval_subset_Icc /-
theorem interval_subset_Icc (ha : a₁ ∈ Icc a₂ b₂) (hb : b₁ ∈ Icc a₂ b₂) : [a₁, b₁] ⊆ Icc a₂ b₂ :=
  Icc_subset_Icc (le_inf ha.1 hb.1) (sup_le ha.2 hb.2)
#align set.interval_subset_Icc Set.interval_subset_Icc
-/

#print Set.interval_subset_interval_iff_mem /-
theorem interval_subset_interval_iff_mem : [a₁, b₁] ⊆ [a₂, b₂] ↔ a₁ ∈ [a₂, b₂] ∧ b₁ ∈ [a₂, b₂] :=
  Iff.intro (fun h => ⟨h left_mem_interval, h right_mem_interval⟩) fun h =>
    interval_subset_interval h.1 h.2
#align set.interval_subset_interval_iff_mem Set.interval_subset_interval_iff_mem
-/

#print Set.interval_subset_interval_iff_le' /-
theorem interval_subset_interval_iff_le' :
    [a₁, b₁] ⊆ [a₂, b₂] ↔ a₂ ⊓ b₂ ≤ a₁ ⊓ b₁ ∧ a₁ ⊔ b₁ ≤ a₂ ⊔ b₂ :=
  Icc_subset_Icc_iff inf_le_sup
#align set.interval_subset_interval_iff_le' Set.interval_subset_interval_iff_le'
-/

#print Set.interval_subset_interval_right /-
theorem interval_subset_interval_right (h : x ∈ [a, b]) : [x, b] ⊆ [a, b] :=
  interval_subset_interval h right_mem_interval
#align set.interval_subset_interval_right Set.interval_subset_interval_right
-/

#print Set.interval_subset_interval_left /-
theorem interval_subset_interval_left (h : x ∈ [a, b]) : [a, x] ⊆ [a, b] :=
  interval_subset_interval left_mem_interval h
#align set.interval_subset_interval_left Set.interval_subset_interval_left
-/

#print Set.bdd_below_bdd_above_iff_subset_interval /-
theorem bdd_below_bdd_above_iff_subset_interval (s : Set α) :
    BddBelow s ∧ BddAbove s ↔ ∃ a b, s ⊆ [a, b] :=
  bddBelow_bddAbove_iff_subset_Icc.trans
    ⟨fun ⟨a, b, h⟩ => ⟨a, b, fun x hx => Icc_subset_interval (h hx)⟩, fun ⟨a, b, h⟩ => ⟨_, _, h⟩⟩
#align set.bdd_below_bdd_above_iff_subset_interval Set.bdd_below_bdd_above_iff_subset_interval
-/

end Lattice

open Interval

section DistribLattice

variable [DistribLattice α] {a a₁ a₂ b b₁ b₂ c x : α}

#print Set.eq_of_mem_interval_of_mem_interval /-
theorem eq_of_mem_interval_of_mem_interval (ha : a ∈ [b, c]) (hb : b ∈ [a, c]) : a = b :=
  eq_of_inf_eq_sup_eq (inf_congr_right ha.1 hb.1) <| sup_congr_right ha.2 hb.2
#align set.eq_of_mem_interval_of_mem_interval Set.eq_of_mem_interval_of_mem_interval
-/

#print Set.eq_of_mem_interval_of_mem_interval' /-
theorem eq_of_mem_interval_of_mem_interval' : b ∈ [a, c] → c ∈ [a, b] → b = c := by
  simpa only [interval_swap a] using eq_of_mem_interval_of_mem_interval
#align set.eq_of_mem_interval_of_mem_interval' Set.eq_of_mem_interval_of_mem_interval'
-/

#print Set.interval_injective_right /-
theorem interval_injective_right (a : α) : Injective fun b => interval b a := fun b c h =>
  by
  rw [ext_iff] at h
  exact eq_of_mem_interval_of_mem_interval ((h _).1 left_mem_interval) ((h _).2 left_mem_interval)
#align set.interval_injective_right Set.interval_injective_right
-/

#print Set.interval_injective_left /-
theorem interval_injective_left (a : α) : Injective (interval a) := by
  simpa only [interval_swap] using interval_injective_right a
#align set.interval_injective_left Set.interval_injective_left
-/

end DistribLattice

section LinearOrder

variable [LinearOrder α] [LinearOrder β] {f : α → β} {s : Set α} {a a₁ a₂ b b₁ b₂ c x : α}

/- warning: set.Icc_min_max -> Set.Icc_min_max is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α}, Eq.{succ u1} (Set.{u1} α) (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (LinearOrder.min.{u1} α _inst_1 a b) (LinearOrder.max.{u1} α _inst_1 a b)) (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a b)
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α}, Eq.{succ u1} (Set.{u1} α) (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1))))) (Min.min.{u1} α (LinearOrder.toMin.{u1} α _inst_1) a b) (Max.max.{u1} α (LinearOrder.toMax.{u1} α _inst_1) a b)) (Set.interval.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)) a b)
Case conversion may be inaccurate. Consider using '#align set.Icc_min_max Set.Icc_min_maxₓ'. -/
theorem Icc_min_max : Icc (min a b) (max a b) = [a, b] :=
  rfl
#align set.Icc_min_max Set.Icc_min_max

#print Set.interval_of_not_le /-
theorem interval_of_not_le (h : ¬a ≤ b) : [a, b] = Icc b a :=
  interval_of_gt <| lt_of_not_ge h
#align set.interval_of_not_le Set.interval_of_not_le
-/

#print Set.interval_of_not_ge /-
theorem interval_of_not_ge (h : ¬b ≤ a) : [a, b] = Icc a b :=
  interval_of_lt <| lt_of_not_ge h
#align set.interval_of_not_ge Set.interval_of_not_ge
-/

/- warning: set.interval_eq_union -> Set.interval_eq_union is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α}, Eq.{succ u1} (Set.{u1} α) (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a b) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) a b) (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) b a))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α}, Eq.{succ u1} (Set.{u1} α) (Set.interval.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)) a b) (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet_1.{u1} α) (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1))))) a b) (Set.Icc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1))))) b a))
Case conversion may be inaccurate. Consider using '#align set.interval_eq_union Set.interval_eq_unionₓ'. -/
theorem interval_eq_union : [a, b] = Icc a b ∪ Icc b a := by rw [Icc_union_Icc', max_comm] <;> rfl
#align set.interval_eq_union Set.interval_eq_union

#print Set.mem_interval /-
theorem mem_interval : a ∈ [b, c] ↔ b ≤ a ∧ a ≤ c ∨ c ≤ a ∧ a ≤ b := by simp [interval_eq_union]
#align set.mem_interval Set.mem_interval
-/

#print Set.not_mem_interval_of_lt /-
theorem not_mem_interval_of_lt (ha : c < a) (hb : c < b) : c ∉ [a, b] :=
  not_mem_Icc_of_lt <| lt_min_iff.mpr ⟨ha, hb⟩
#align set.not_mem_interval_of_lt Set.not_mem_interval_of_lt
-/

#print Set.not_mem_interval_of_gt /-
theorem not_mem_interval_of_gt (ha : a < c) (hb : b < c) : c ∉ [a, b] :=
  not_mem_Icc_of_gt <| max_lt_iff.mpr ⟨ha, hb⟩
#align set.not_mem_interval_of_gt Set.not_mem_interval_of_gt
-/

/- warning: set.interval_subset_interval_iff_le -> Set.interval_subset_interval_iff_le is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a₁ : α} {a₂ : α} {b₁ : α} {b₂ : α}, Iff (HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a₁ b₁) (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a₂ b₂)) (And (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) (LinearOrder.min.{u1} α _inst_1 a₂ b₂) (LinearOrder.min.{u1} α _inst_1 a₁ b₁)) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1))))) (LinearOrder.max.{u1} α _inst_1 a₁ b₁) (LinearOrder.max.{u1} α _inst_1 a₂ b₂)))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a₁ : α} {a₂ : α} {b₁ : α} {b₂ : α}, Iff (HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet_1.{u1} α) (Set.interval.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)) a₁ b₁) (Set.interval.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)) a₂ b₂)) (And (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)))))) (Min.min.{u1} α (LinearOrder.toMin.{u1} α _inst_1) a₂ b₂) (Min.min.{u1} α (LinearOrder.toMin.{u1} α _inst_1) a₁ b₁)) (LE.le.{u1} α (Preorder.toLE.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)))))) (Max.max.{u1} α (LinearOrder.toMax.{u1} α _inst_1) a₁ b₁) (Max.max.{u1} α (LinearOrder.toMax.{u1} α _inst_1) a₂ b₂)))
Case conversion may be inaccurate. Consider using '#align set.interval_subset_interval_iff_le Set.interval_subset_interval_iff_leₓ'. -/
theorem interval_subset_interval_iff_le :
    [a₁, b₁] ⊆ [a₂, b₂] ↔ min a₂ b₂ ≤ min a₁ b₁ ∧ max a₁ b₁ ≤ max a₂ b₂ :=
  interval_subset_interval_iff_le'
#align set.interval_subset_interval_iff_le Set.interval_subset_interval_iff_le

/- warning: set.interval_subset_interval_union_interval -> Set.interval_subset_interval_union_interval is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α} {c : α}, HasSubset.Subset.{u1} (Set.{u1} α) (Set.hasSubset.{u1} α) (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a c) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a b) (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) b c))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α} {c : α}, HasSubset.Subset.{u1} (Set.{u1} α) (Set.instHasSubsetSet_1.{u1} α) (Set.interval.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)) a c) (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet_1.{u1} α) (Set.interval.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)) a b) (Set.interval.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1)) b c))
Case conversion may be inaccurate. Consider using '#align set.interval_subset_interval_union_interval Set.interval_subset_interval_union_intervalₓ'. -/
/-- A sort of triangle inequality. -/
theorem interval_subset_interval_union_interval : [a, c] ⊆ [a, b] ∪ [b, c] := fun x => by
  simp only [mem_interval, mem_union] <;> cases le_total a c <;> cases le_total x b <;> tauto
#align set.interval_subset_interval_union_interval Set.interval_subset_interval_union_interval

/- warning: set.monotone_or_antitone_iff_interval -> Set.monotone_or_antitone_iff_interval is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : LinearOrder.{u2} β] {f : α -> β}, Iff (Or (Monotone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (LinearOrder.toLattice.{u2} β _inst_2)))) f) (Antitone.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (LinearOrder.toLattice.{u2} β _inst_2)))) f)) (forall (a : α) (b : α) (c : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) c (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a b)) -> (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) (f c) (Set.interval.{u2} β (LinearOrder.toLattice.{u2} β _inst_2) (f a) (f b))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : LinearOrder.{u1} β] {f : α -> β}, Iff (Or (Monotone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (DistribLattice.toLattice.{u1} β (instDistribLattice.{u1} β _inst_2))))) f) (Antitone.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (DistribLattice.toLattice.{u1} β (instDistribLattice.{u1} β _inst_2))))) f)) (forall (a : α) (b : α) (c : α), (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) c (Set.interval.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)) a b)) -> (Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) (f c) (Set.interval.{u1} β (DistribLattice.toLattice.{u1} β (instDistribLattice.{u1} β _inst_2)) (f a) (f b))))
Case conversion may be inaccurate. Consider using '#align set.monotone_or_antitone_iff_interval Set.monotone_or_antitone_iff_intervalₓ'. -/
theorem monotone_or_antitone_iff_interval :
    Monotone f ∨ Antitone f ↔ ∀ a b c, c ∈ [a, b] → f c ∈ [f a, f b] :=
  by
  constructor
  · rintro (hf | hf) a b c <;> simp_rw [← Icc_min_max, ← hf.map_min, ← hf.map_max]
    exacts[fun hc => ⟨hf hc.1, hf hc.2⟩, fun hc => ⟨hf hc.2, hf hc.1⟩]
  contrapose!
  rw [not_monotone_not_antitone_iff_exists_le_le]
  rintro ⟨a, b, c, hab, hbc, ⟨hfab, hfcb⟩ | ⟨hfba, hfbc⟩⟩
  · exact ⟨a, c, b, Icc_subset_interval ⟨hab, hbc⟩, fun h => h.2.not_lt <| max_lt hfab hfcb⟩
  · exact ⟨a, c, b, Icc_subset_interval ⟨hab, hbc⟩, fun h => h.1.not_lt <| lt_min hfba hfbc⟩
#align set.monotone_or_antitone_iff_interval Set.monotone_or_antitone_iff_interval

/- warning: set.monotone_on_or_antitone_on_iff_interval -> Set.monotoneOn_or_antitoneOn_iff_interval is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}} [_inst_1 : LinearOrder.{u1} α] [_inst_2 : LinearOrder.{u2} β] {f : α -> β} {s : Set.{u1} α}, Iff (Or (MonotoneOn.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (LinearOrder.toLattice.{u2} β _inst_2)))) f s) (AntitoneOn.{u1, u2} α β (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) (PartialOrder.toPreorder.{u2} β (SemilatticeInf.toPartialOrder.{u2} β (Lattice.toSemilatticeInf.{u2} β (LinearOrder.toLattice.{u2} β _inst_2)))) f s)) (forall (a : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) a s) -> (forall (b : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) b s) -> (forall (c : α), (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) c s) -> (Membership.Mem.{u1, u1} α (Set.{u1} α) (Set.hasMem.{u1} α) c (Set.interval.{u1} α (LinearOrder.toLattice.{u1} α _inst_1) a b)) -> (Membership.Mem.{u2, u2} β (Set.{u2} β) (Set.hasMem.{u2} β) (f c) (Set.interval.{u2} β (LinearOrder.toLattice.{u2} β _inst_2) (f a) (f b))))))
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}} [_inst_1 : LinearOrder.{u2} α] [_inst_2 : LinearOrder.{u1} β] {f : α -> β} {s : Set.{u2} α}, Iff (Or (MonotoneOn.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (DistribLattice.toLattice.{u1} β (instDistribLattice.{u1} β _inst_2))))) f s) (AntitoneOn.{u2, u1} α β (PartialOrder.toPreorder.{u2} α (SemilatticeInf.toPartialOrder.{u2} α (Lattice.toSemilatticeInf.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1))))) (PartialOrder.toPreorder.{u1} β (SemilatticeInf.toPartialOrder.{u1} β (Lattice.toSemilatticeInf.{u1} β (DistribLattice.toLattice.{u1} β (instDistribLattice.{u1} β _inst_2))))) f s)) (forall (a : α), (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) a s) -> (forall (b : α), (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) b s) -> (forall (c : α), (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) c s) -> (Membership.mem.{u2, u2} α (Set.{u2} α) (Set.instMembershipSet.{u2} α) c (Set.interval.{u2} α (DistribLattice.toLattice.{u2} α (instDistribLattice.{u2} α _inst_1)) a b)) -> (Membership.mem.{u1, u1} β (Set.{u1} β) (Set.instMembershipSet.{u1} β) (f c) (Set.interval.{u1} β (DistribLattice.toLattice.{u1} β (instDistribLattice.{u1} β _inst_2)) (f a) (f b))))))
Case conversion may be inaccurate. Consider using '#align set.monotone_on_or_antitone_on_iff_interval Set.monotoneOn_or_antitoneOn_iff_intervalₓ'. -/
/- ./././Mathport/Syntax/Translate/Basic.lean:632:2: warning: expanding binder collection (a b c «expr ∈ » s) -/
theorem monotoneOn_or_antitoneOn_iff_interval :
    MonotoneOn f s ∨ AntitoneOn f s ↔
      ∀ (a) (_ : a ∈ s) (b) (_ : b ∈ s) (c) (_ : c ∈ s), c ∈ [a, b] → f c ∈ [f a, f b] :=
  by
  simp [monotone_on_iff_monotone, antitone_on_iff_antitone, monotone_or_antitone_iff_interval,
    mem_interval]
#align set.monotone_on_or_antitone_on_iff_interval Set.monotoneOn_or_antitoneOn_iff_interval

#print Set.intervalOC /-
/-- The open-closed interval with unordered bounds. -/
def intervalOC : α → α → Set α := fun a b => Ioc (min a b) (max a b)
#align set.interval_oc Set.intervalOC
-/

-- mathport name: exprΙ
-- Below is a capital iota
scoped[Interval] notation "Ι" => Set.intervalOC

#print Set.intervalOC_of_le /-
@[simp]
theorem intervalOC_of_le (h : a ≤ b) : Ι a b = Ioc a b := by simp [interval_oc, h]
#align set.interval_oc_of_le Set.intervalOC_of_le
-/

#print Set.intervalOC_of_lt /-
@[simp]
theorem intervalOC_of_lt (h : b < a) : Ι a b = Ioc b a := by simp [interval_oc, le_of_lt h]
#align set.interval_oc_of_lt Set.intervalOC_of_lt
-/

/- warning: set.interval_oc_eq_union -> Set.intervalOC_eq_union is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α}, Eq.{succ u1} (Set.{u1} α) (Set.intervalOC.{u1} α _inst_1 a b) (Union.union.{u1} (Set.{u1} α) (Set.hasUnion.{u1} α) (Set.Ioc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) a b) (Set.Ioc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (LinearOrder.toLattice.{u1} α _inst_1)))) b a))
but is expected to have type
  forall {α : Type.{u1}} [_inst_1 : LinearOrder.{u1} α] {a : α} {b : α}, Eq.{succ u1} (Set.{u1} α) (Set.intervalOC.{u1} α _inst_1 a b) (Union.union.{u1} (Set.{u1} α) (Set.instUnionSet_1.{u1} α) (Set.Ioc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1))))) a b) (Set.Ioc.{u1} α (PartialOrder.toPreorder.{u1} α (SemilatticeInf.toPartialOrder.{u1} α (Lattice.toSemilatticeInf.{u1} α (DistribLattice.toLattice.{u1} α (instDistribLattice.{u1} α _inst_1))))) b a))
Case conversion may be inaccurate. Consider using '#align set.interval_oc_eq_union Set.intervalOC_eq_unionₓ'. -/
theorem intervalOC_eq_union : Ι a b = Ioc a b ∪ Ioc b a := by
  cases le_total a b <;> simp [interval_oc, *]
#align set.interval_oc_eq_union Set.intervalOC_eq_union

#print Set.mem_intervalOC /-
theorem mem_intervalOC : a ∈ Ι b c ↔ b < a ∧ a ≤ c ∨ c < a ∧ a ≤ b := by
  simp only [interval_oc_eq_union, mem_union, mem_Ioc]
#align set.mem_interval_oc Set.mem_intervalOC
-/

#print Set.not_mem_intervalOC /-
theorem not_mem_intervalOC : a ∉ Ι b c ↔ a ≤ b ∧ a ≤ c ∨ c < a ∧ b < a :=
  by
  simp only [interval_oc_eq_union, mem_union, mem_Ioc, not_lt, ← not_le]
  tauto
#align set.not_mem_interval_oc Set.not_mem_intervalOC
-/

#print Set.left_mem_intervalOC /-
@[simp]
theorem left_mem_intervalOC : a ∈ Ι a b ↔ b < a := by simp [mem_interval_oc]
#align set.left_mem_interval_oc Set.left_mem_intervalOC
-/

#print Set.right_mem_intervalOC /-
@[simp]
theorem right_mem_intervalOC : b ∈ Ι a b ↔ a < b := by simp [mem_interval_oc]
#align set.right_mem_interval_oc Set.right_mem_intervalOC
-/

#print Set.forall_intervalOC_iff /-
theorem forall_intervalOC_iff {P : α → Prop} :
    (∀ x ∈ Ι a b, P x) ↔ (∀ x ∈ Ioc a b, P x) ∧ ∀ x ∈ Ioc b a, P x := by
  simp only [interval_oc_eq_union, mem_union, or_imp, forall_and]
#align set.forall_interval_oc_iff Set.forall_intervalOC_iff
-/

#print Set.intervalOC_subset_intervalOC_of_interval_subset_interval /-
theorem intervalOC_subset_intervalOC_of_interval_subset_interval {a b c d : α}
    (h : [a, b] ⊆ [c, d]) : Ι a b ⊆ Ι c d :=
  Ioc_subset_Ioc (interval_subset_interval_iff_le.1 h).1 (interval_subset_interval_iff_le.1 h).2
#align
  set.interval_oc_subset_interval_oc_of_interval_subset_interval Set.intervalOC_subset_intervalOC_of_interval_subset_interval
-/

#print Set.intervalOC_swap /-
theorem intervalOC_swap (a b : α) : Ι a b = Ι b a := by
  simp only [interval_oc, min_comm a b, max_comm a b]
#align set.interval_oc_swap Set.intervalOC_swap
-/

#print Set.Ioc_subset_intervalOC /-
theorem Ioc_subset_intervalOC : Ioc a b ⊆ Ι a b :=
  Ioc_subset_Ioc (min_le_left _ _) (le_max_right _ _)
#align set.Ioc_subset_interval_oc Set.Ioc_subset_intervalOC
-/

#print Set.Ioc_subset_intervalOC' /-
theorem Ioc_subset_intervalOC' : Ioc a b ⊆ Ι b a :=
  Ioc_subset_Ioc (min_le_right _ _) (le_max_left _ _)
#align set.Ioc_subset_interval_oc' Set.Ioc_subset_intervalOC'
-/

#print Set.eq_of_mem_intervalOC_of_mem_intervalOC /-
theorem eq_of_mem_intervalOC_of_mem_intervalOC : a ∈ Ι b c → b ∈ Ι a c → a = b := by
  simp_rw [mem_interval_oc] <;> rintro (⟨_, _⟩ | ⟨_, _⟩) (⟨_, _⟩ | ⟨_, _⟩) <;> apply le_antisymm <;>
    first |assumption|exact le_of_lt ‹_›|exact le_trans ‹_› (le_of_lt ‹_›)
#align set.eq_of_mem_interval_oc_of_mem_interval_oc Set.eq_of_mem_intervalOC_of_mem_intervalOC
-/

#print Set.eq_of_mem_intervalOC_of_mem_intervalOC' /-
theorem eq_of_mem_intervalOC_of_mem_intervalOC' : b ∈ Ι a c → c ∈ Ι a b → b = c := by
  simpa only [interval_oc_swap a] using eq_of_mem_interval_oc_of_mem_interval_oc
#align set.eq_of_mem_interval_oc_of_mem_interval_oc' Set.eq_of_mem_intervalOC_of_mem_intervalOC'
-/

#print Set.eq_of_not_mem_intervalOC_of_not_mem_intervalOC /-
theorem eq_of_not_mem_intervalOC_of_not_mem_intervalOC (ha : a ≤ c) (hb : b ≤ c) :
    a ∉ Ι b c → b ∉ Ι a c → a = b := by
  simp_rw [not_mem_interval_oc] <;> rintro (⟨_, _⟩ | ⟨_, _⟩) (⟨_, _⟩ | ⟨_, _⟩) <;>
      apply le_antisymm <;>
    first |assumption|exact le_of_lt ‹_›|cases not_le_of_lt ‹_› ‹_›
#align
  set.eq_of_not_mem_interval_oc_of_not_mem_interval_oc Set.eq_of_not_mem_intervalOC_of_not_mem_intervalOC
-/

#print Set.intervalOC_injective_right /-
theorem intervalOC_injective_right (a : α) : Injective fun b => Ι b a :=
  by
  rintro b c h
  rw [ext_iff] at h
  obtain ha | ha := le_or_lt b a
  · have hb := (h b).Not
    simp only [ha, left_mem_interval_oc, not_lt, true_iff_iff, not_mem_interval_oc, ← not_le,
      and_true_iff, not_true, false_and_iff, not_false_iff, true_iff_iff, or_false_iff] at hb
    refine' hb.eq_of_not_lt fun hc => _
    simpa [ha, and_iff_right hc, ← @not_le _ _ _ a, -not_le] using h c
  · refine'
      eq_of_mem_interval_oc_of_mem_interval_oc ((h _).1 <| left_mem_interval_oc.2 ha)
        ((h _).2 <| left_mem_interval_oc.2 <| ha.trans_le _)
    simpa [ha, ha.not_le, mem_interval_oc] using h b
#align set.interval_oc_injective_right Set.intervalOC_injective_right
-/

#print Set.intervalOC_injective_left /-
theorem intervalOC_injective_left (a : α) : Injective (Ι a) := by
  simpa only [interval_oc_swap] using interval_oc_injective_right a
#align set.interval_oc_injective_left Set.intervalOC_injective_left
-/

end LinearOrder

end Set

