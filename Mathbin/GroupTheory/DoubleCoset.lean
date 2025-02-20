/-
Copyright (c) 2021 Chris Birkbeck. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Birkbeck

! This file was ported from Lean 3 source module group_theory.double_coset
! leanprover-community/mathlib commit 50832daea47b195a48b5b33b1c8b2162c48c3afc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Setoid.Basic
import Mathbin.GroupTheory.Subgroup.Basic
import Mathbin.GroupTheory.Coset
import Mathbin.GroupTheory.Subgroup.Pointwise
import Mathbin.Data.Set.Basic
import Mathbin.Tactic.Group

/-!
# Double cosets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines double cosets for two subgroups `H K` of a group `G` and the quotient of `G` by
the double coset relation, i.e. `H \ G / K`. We also prove that `G` can be writen as a disjoint
union of the double cosets and that if one of `H` or `K` is the trivial group (i.e. `⊥` ) then
this is the usual left or right quotient of a group by a subgroup.

## Main definitions

* `rel`: The double coset relation defined by two subgroups `H K` of `G`.
* `double_coset.quotient`: The quotient of `G` by the double coset relation, i.e, ``H \ G / K`.
-/


variable {G : Type _} [Group G] {α : Type _} [Mul α] (J : Subgroup G) (g : G)

namespace Doset.doset

open scoped Pointwise

#print Doset.doset /-
/-- The double_coset as an element of `set α` corresponding to `s a t` -/
def Doset.doset (a : α) (s t : Set α) : Set α :=
  s * {a} * t
#align doset Doset.doset
-/

#print Doset.mem_doset /-
theorem mem_doset {s t : Set α} {a b : α} :
    b ∈ Doset.doset a s t ↔ ∃ x ∈ s, ∃ y ∈ t, b = x * a * y :=
  ⟨fun ⟨_, y, ⟨x, _, hx, rfl, rfl⟩, hy, h⟩ => ⟨x, hx, y, hy, h.symm⟩, fun ⟨x, hx, y, hy, h⟩ =>
    ⟨x * a, y, ⟨x, a, hx, rfl, rfl⟩, hy, h.symm⟩⟩
#align doset.mem_doset Doset.mem_doset
-/

#print Doset.mem_doset_self /-
theorem mem_doset_self (H K : Subgroup G) (a : G) : a ∈ Doset.doset a H K :=
  mem_doset.mpr ⟨1, H.one_mem, 1, K.one_mem, (one_mul a).symm.trans (mul_one (1 * a)).symm⟩
#align doset.mem_doset_self Doset.mem_doset_self
-/

#print Doset.doset_eq_of_mem /-
theorem doset_eq_of_mem {H K : Subgroup G} {a b : G} (hb : b ∈ Doset.doset a H K) :
    Doset.doset b H K = Doset.doset a H K :=
  by
  obtain ⟨_, k, ⟨h, a, hh, rfl : _ = _, rfl⟩, hk, rfl⟩ := hb
  rw [Doset.doset, Doset.doset, ← Set.singleton_mul_singleton, ← Set.singleton_mul_singleton,
    mul_assoc, mul_assoc, Subgroup.singleton_mul_subgroup hk, ← mul_assoc, ← mul_assoc,
    Subgroup.subgroup_mul_singleton hh]
#align doset.doset_eq_of_mem Doset.doset_eq_of_mem
-/

#print Doset.mem_doset_of_not_disjoint /-
theorem mem_doset_of_not_disjoint {H K : Subgroup G} {a b : G}
    (h : ¬Disjoint (Doset.doset a H K) (Doset.doset b H K)) : b ∈ Doset.doset a H K :=
  by
  rw [Set.not_disjoint_iff] at h 
  simp only [mem_doset] at *
  obtain ⟨x, ⟨l, hl, r, hr, hrx⟩, y, hy, ⟨r', hr', rfl⟩⟩ := h
  refine' ⟨y⁻¹ * l, H.mul_mem (H.inv_mem hy) hl, r * r'⁻¹, K.mul_mem hr (K.inv_mem hr'), _⟩
  rwa [mul_assoc, mul_assoc, eq_inv_mul_iff_mul_eq, ← mul_assoc, ← mul_assoc, eq_mul_inv_iff_mul_eq]
#align doset.mem_doset_of_not_disjoint Doset.mem_doset_of_not_disjoint
-/

#print Doset.eq_of_not_disjoint /-
theorem eq_of_not_disjoint {H K : Subgroup G} {a b : G}
    (h : ¬Disjoint (Doset.doset a H K) (Doset.doset b H K)) :
    Doset.doset a H K = Doset.doset b H K :=
  by
  rw [disjoint_comm] at h 
  have ha : a ∈ Doset.doset b H K := mem_doset_of_not_disjoint h
  apply doset_eq_of_mem ha
#align doset.eq_of_not_disjoint Doset.eq_of_not_disjoint
-/

#print Doset.setoid /-
/-- The setoid defined by the double_coset relation -/
def setoid (H K : Set G) : Setoid G :=
  Setoid.ker fun x => Doset.doset x H K
#align doset.setoid Doset.setoid
-/

#print Doset.Quotient /-
/-- Quotient of `G` by the double coset relation, i.e. `H \ G / K` -/
def Quotient (H K : Set G) : Type _ :=
  Quotient (setoid H K)
#align doset.quotient Doset.Quotient
-/

#print Doset.rel_iff /-
theorem rel_iff {H K : Subgroup G} {x y : G} :
    (setoid ↑H ↑K).Rel x y ↔ ∃ a ∈ H, ∃ b ∈ K, y = a * x * b :=
  Iff.trans
    ⟨fun hxy => (congr_arg _ hxy).mpr (mem_doset_self H K y), fun hxy => (doset_eq_of_mem hxy).symm⟩
    mem_doset
#align doset.rel_iff Doset.rel_iff
-/

#print Doset.bot_rel_eq_leftRel /-
theorem bot_rel_eq_leftRel (H : Subgroup G) :
    (setoid ↑(⊥ : Subgroup G) ↑H).Rel = (QuotientGroup.leftRel H).Rel :=
  by
  ext a b
  rw [rel_iff, Setoid.Rel, QuotientGroup.leftRel_apply]
  constructor
  · rintro ⟨a, rfl : a = 1, b, hb, rfl⟩
    change a⁻¹ * (1 * a * b) ∈ H
    rwa [one_mul, inv_mul_cancel_left]
  · rintro (h : a⁻¹ * b ∈ H)
    exact ⟨1, rfl, a⁻¹ * b, h, by rw [one_mul, mul_inv_cancel_left]⟩
#align doset.bot_rel_eq_left_rel Doset.bot_rel_eq_leftRel
-/

#print Doset.rel_bot_eq_right_group_rel /-
theorem rel_bot_eq_right_group_rel (H : Subgroup G) :
    (setoid ↑H ↑(⊥ : Subgroup G)).Rel = (QuotientGroup.rightRel H).Rel :=
  by
  ext a b
  rw [rel_iff, Setoid.Rel, QuotientGroup.rightRel_apply]
  constructor
  · rintro ⟨b, hb, a, rfl : a = 1, rfl⟩
    change b * a * 1 * a⁻¹ ∈ H
    rwa [mul_one, mul_inv_cancel_right]
  · rintro (h : b * a⁻¹ ∈ H)
    exact ⟨b * a⁻¹, h, 1, rfl, by rw [mul_one, inv_mul_cancel_right]⟩
#align doset.rel_bot_eq_right_group_rel Doset.rel_bot_eq_right_group_rel
-/

#print Doset.quotToDoset /-
/-- Create a doset out of an element of `H \ G / K`-/
def quotToDoset (H K : Subgroup G) (q : Quotient ↑H ↑K) : Set G :=
  Doset.doset q.out' H K
#align doset.quot_to_doset Doset.quotToDoset
-/

#print Doset.mk /-
/-- Map from `G` to `H \ G / K`-/
abbrev mk (H K : Subgroup G) (a : G) : Quotient ↑H ↑K :=
  Quotient.mk'' a
#align doset.mk Doset.mk
-/

instance (H K : Subgroup G) : Inhabited (Quotient ↑H ↑K) :=
  ⟨mk H K (1 : G)⟩

#print Doset.eq /-
theorem eq (H K : Subgroup G) (a b : G) : mk H K a = mk H K b ↔ ∃ h ∈ H, ∃ k ∈ K, b = h * a * k :=
  by rw [Quotient.eq'']; apply rel_iff
#align doset.eq Doset.eq
-/

#print Doset.out_eq' /-
theorem out_eq' (H K : Subgroup G) (q : Quotient ↑H ↑K) : mk H K q.out' = q :=
  Quotient.out_eq' q
#align doset.out_eq' Doset.out_eq'
-/

#print Doset.mk_out'_eq_mul /-
theorem mk_out'_eq_mul (H K : Subgroup G) (g : G) :
    ∃ h k : G, h ∈ H ∧ k ∈ K ∧ (mk H K g : Quotient ↑H ↑K).out' = h * g * k :=
  by
  have := Eq H K (mk H K g : Quotient ↑H ↑K).out' g
  rw [out_eq'] at this 
  obtain ⟨h, h_h, k, hk, T⟩ := this.1 rfl
  refine' ⟨h⁻¹, k⁻¹, H.inv_mem h_h, K.inv_mem hk, eq_mul_inv_of_mul_eq (eq_inv_mul_of_mul_eq _)⟩
  rw [← mul_assoc, ← T]
#align doset.mk_out'_eq_mul Doset.mk_out'_eq_mul
-/

#print Doset.mk_eq_of_doset_eq /-
theorem mk_eq_of_doset_eq {H K : Subgroup G} {a b : G} (h : Doset.doset a H K = Doset.doset b H K) :
    mk H K a = mk H K b := by
  rw [Eq]
  exact mem_doset.mp (h.symm ▸ mem_doset_self H K b)
#align doset.mk_eq_of_doset_eq Doset.mk_eq_of_doset_eq
-/

#print Doset.disjoint_out' /-
theorem disjoint_out' {H K : Subgroup G} {a b : Quotient H.1 K} :
    a ≠ b → Disjoint (Doset.doset a.out' H K) (Doset.doset b.out' H K) :=
  by
  contrapose!
  intro h
  simpa [out_eq'] using mk_eq_of_doset_eq (eq_of_not_disjoint h)
#align doset.disjoint_out' Doset.disjoint_out'
-/

#print Doset.union_quotToDoset /-
theorem union_quotToDoset (H K : Subgroup G) : (⋃ q, quotToDoset H K q) = Set.univ :=
  by
  ext x
  simp only [Set.mem_iUnion, quot_to_doset, mem_doset, SetLike.mem_coe, exists_prop, Set.mem_univ,
    iff_true_iff]
  use mk H K x
  obtain ⟨h, k, h3, h4, h5⟩ := mk_out'_eq_mul H K x
  refine' ⟨h⁻¹, H.inv_mem h3, k⁻¹, K.inv_mem h4, _⟩
  simp only [h5, Subgroup.coe_mk, ← mul_assoc, one_mul, mul_left_inv, mul_inv_cancel_right]
#align doset.union_quot_to_doset Doset.union_quotToDoset
-/

#print Doset.doset_union_rightCoset /-
theorem doset_union_rightCoset (H K : Subgroup G) (a : G) :
    (⋃ k : K, rightCoset (↑H) (a * k)) = Doset.doset a H K :=
  by
  ext x
  simp only [mem_rightCoset_iff, exists_prop, mul_inv_rev, Set.mem_iUnion, mem_doset,
    Subgroup.mem_carrier, SetLike.mem_coe]
  constructor
  · rintro ⟨y, h_h⟩
    refine' ⟨x * (y⁻¹ * a⁻¹), h_h, y, y.2, _⟩
    simp only [← mul_assoc, Subgroup.coe_mk, inv_mul_cancel_right]
  · rintro ⟨x, hx, y, hy, hxy⟩
    refine' ⟨⟨y, hy⟩, _⟩
    simp only [hxy, ← mul_assoc, hx, mul_inv_cancel_right, Subgroup.coe_mk]
#align doset.doset_union_right_coset Doset.doset_union_rightCoset
-/

#print Doset.doset_union_leftCoset /-
theorem doset_union_leftCoset (H K : Subgroup G) (a : G) :
    (⋃ h : H, leftCoset (h * a : G) K) = Doset.doset a H K :=
  by
  ext x
  simp only [mem_leftCoset_iff, mul_inv_rev, Set.mem_iUnion, mem_doset]
  constructor
  · rintro ⟨y, h_h⟩
    refine' ⟨y, y.2, a⁻¹ * y⁻¹ * x, h_h, _⟩
    simp only [← mul_assoc, one_mul, mul_right_inv, mul_inv_cancel_right]
  · rintro ⟨x, hx, y, hy, hxy⟩
    refine' ⟨⟨x, hx⟩, _⟩
    simp only [hxy, ← mul_assoc, hy, one_mul, mul_left_inv, Subgroup.coe_mk, inv_mul_cancel_right]
#align doset.doset_union_left_coset Doset.doset_union_leftCoset
-/

#print Doset.left_bot_eq_left_quot /-
theorem left_bot_eq_left_quot (H : Subgroup G) : Quotient (⊥ : Subgroup G).1 H = (G ⧸ H) :=
  by
  unfold Quotient
  congr
  ext
  simp_rw [← bot_rel_eq_left_rel H]
  rfl
#align doset.left_bot_eq_left_quot Doset.left_bot_eq_left_quot
-/

#print Doset.right_bot_eq_right_quot /-
theorem right_bot_eq_right_quot (H : Subgroup G) :
    Quotient H.1 (⊥ : Subgroup G) = Quotient (QuotientGroup.rightRel H) :=
  by
  unfold Quotient
  congr
  ext
  simp_rw [← rel_bot_eq_right_group_rel H]
  rfl
#align doset.right_bot_eq_right_quot Doset.right_bot_eq_right_quot
-/

end Doset.doset

