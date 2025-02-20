/-
Copyright (c) 2021 Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard, Ines Wright, Joachim Breitner

! This file was ported from Lean 3 source module group_theory.nilpotent
! leanprover-community/mathlib commit 599fffe78f0e11eb6a034e834ec51882167b9688
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.QuotientGroup
import Mathbin.GroupTheory.Solvable
import Mathbin.GroupTheory.PGroup
import Mathbin.GroupTheory.Sylow
import Mathbin.Data.Nat.Factorization.Basic
import Mathbin.Tactic.Tfae

/-!

# Nilpotent groups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

An API for nilpotent groups, that is, groups for which the upper central series
reaches `⊤`.

## Main definitions

Recall that if `H K : subgroup G` then `⁅H, K⁆ : subgroup G` is the subgroup of `G` generated
by the commutators `hkh⁻¹k⁻¹`. Recall also Lean's conventions that `⊤` denotes the
subgroup `G` of `G`, and `⊥` denotes the trivial subgroup `{1}`.

* `upper_central_series G : ℕ → subgroup G` : the upper central series of a group `G`.
     This is an increasing sequence of normal subgroups `H n` of `G` with `H 0 = ⊥` and
     `H (n + 1) / H n` is the centre of `G / H n`.
* `lower_central_series G : ℕ → subgroup G` : the lower central series of a group `G`.
     This is a decreasing sequence of normal subgroups `H n` of `G` with `H 0 = ⊤` and
     `H (n + 1) = ⁅H n, G⁆`.
* `is_nilpotent` : A group G is nilpotent if its upper central series reaches `⊤`, or
    equivalently if its lower central series reaches `⊥`.
* `nilpotency_class` : the length of the upper central series of a nilpotent group.
* `is_ascending_central_series (H : ℕ → subgroup G) : Prop` and
* `is_descending_central_series (H : ℕ → subgroup G) : Prop` : Note that in the literature
    a "central series" for a group is usually defined to be a *finite* sequence of normal subgroups
    `H 0`, `H 1`, ..., starting at `⊤`, finishing at `⊥`, and with each `H n / H (n + 1)`
    central in `G / H (n + 1)`. In this formalisation it is convenient to have two weaker predicates
    on an infinite sequence of subgroups `H n` of `G`: we say a sequence is a *descending central
    series* if it starts at `G` and `⁅H n, ⊤⁆ ⊆ H (n + 1)` for all `n`. Note that this series
    may not terminate at `⊥`, and the `H i` need not be normal. Similarly a sequence is an
    *ascending central series* if `H 0 = ⊥` and `⁅H (n + 1), ⊤⁆ ⊆ H n` for all `n`, again with no
    requirement that the series reaches `⊤` or that the `H i` are normal.

## Main theorems

`G` is *defined* to be nilpotent if the upper central series reaches `⊤`.
* `nilpotent_iff_finite_ascending_central_series` : `G` is nilpotent iff some ascending central
    series reaches `⊤`.
* `nilpotent_iff_finite_descending_central_series` : `G` is nilpotent iff some descending central
    series reaches `⊥`.
* `nilpotent_iff_lower` : `G` is nilpotent iff the lower central series reaches `⊥`.
* The `nilpotency_class` can likeways be obtained from these equivalent
  definitions, see `least_ascending_central_series_length_eq_nilpotency_class`,
  `least_descending_central_series_length_eq_nilpotency_class` and
  `lower_central_series_length_eq_nilpotency_class`.
* If `G` is nilpotent, then so are its subgroups, images, quotients and preimages.
  Binary and finite products of nilpotent groups are nilpotent.
  Infinite products are nilpotent if their nilpotent class is bounded.
  Corresponding lemmas about the `nilpotency_class` are provided.
* The `nilpotency_class` of `G ⧸ center G` is given explicitly, and an induction principle
  is derived from that.
* `is_nilpotent.to_is_solvable`: If `G` is nilpotent, it is solvable.


## Warning

A "central series" is usually defined to be a finite sequence of normal subgroups going
from `⊥` to `⊤` with the property that each subquotient is contained within the centre of
the associated quotient of `G`. This means that if `G` is not nilpotent, then
none of what we have called `upper_central_series G`, `lower_central_series G` or
the sequences satisfying `is_ascending_central_series` or `is_descending_central_series`
are actually central series. Note that the fact that the upper and lower central series
are not central series if `G` is not nilpotent is a standard abuse of notation.

-/


open Subgroup

section WithGroup

variable {G : Type _} [Group G] (H : Subgroup G) [Normal H]

#print upperCentralSeriesStep /-
/-- If `H` is a normal subgroup of `G`, then the set `{x : G | ∀ y : G, x*y*x⁻¹*y⁻¹ ∈ H}`
is a subgroup of `G` (because it is the preimage in `G` of the centre of the
quotient group `G/H`.)
-/
def upperCentralSeriesStep : Subgroup G
    where
  carrier := {x : G | ∀ y : G, x * y * x⁻¹ * y⁻¹ ∈ H}
  one_mem' y := by simp [Subgroup.one_mem]
  mul_mem' a b ha hb y :=
    by
    convert Subgroup.mul_mem _ (ha (b * y * b⁻¹)) (hb y) using 1
    group
  inv_mem' x hx y := by
    specialize hx y⁻¹
    rw [mul_assoc, inv_inv] at hx ⊢
    exact Subgroup.Normal.mem_comm inferInstance hx
#align upper_central_series_step upperCentralSeriesStep
-/

#print mem_upperCentralSeriesStep /-
theorem mem_upperCentralSeriesStep (x : G) :
    x ∈ upperCentralSeriesStep H ↔ ∀ y, x * y * x⁻¹ * y⁻¹ ∈ H :=
  Iff.rfl
#align mem_upper_central_series_step mem_upperCentralSeriesStep
-/

open QuotientGroup

#print upperCentralSeriesStep_eq_comap_center /-
/-- The proof that `upper_central_series_step H` is the preimage of the centre of `G/H` under
the canonical surjection. -/
theorem upperCentralSeriesStep_eq_comap_center :
    upperCentralSeriesStep H = Subgroup.comap (mk' H) (center (G ⧸ H)) :=
  by
  ext
  rw [mem_comap, mem_center_iff, forall_coe]
  apply forall_congr'
  intro y
  rw [coe_mk', ← QuotientGroup.mk_mul, ← QuotientGroup.mk_mul, eq_comm, eq_iff_div_mem,
    div_eq_mul_inv, mul_inv_rev, mul_assoc]
#align upper_central_series_step_eq_comap_center upperCentralSeriesStep_eq_comap_center
-/

instance : Normal (upperCentralSeriesStep H) :=
  by
  rw [upperCentralSeriesStep_eq_comap_center]
  infer_instance

variable (G)

#print upperCentralSeriesAux /-
/-- An auxiliary type-theoretic definition defining both the upper central series of
a group, and a proof that it is normal, all in one go. -/
def upperCentralSeriesAux : ℕ → Σ' H : Subgroup G, Normal H
  | 0 => ⟨⊥, inferInstance⟩
  | n + 1 =>
    let un := upperCentralSeriesAux n
    let un_normal := un.2
    ⟨upperCentralSeriesStep un.1, inferInstance⟩
#align upper_central_series_aux upperCentralSeriesAux
-/

#print upperCentralSeries /-
/-- `upper_central_series G n` is the `n`th term in the upper central series of `G`. -/
def upperCentralSeries (n : ℕ) : Subgroup G :=
  (upperCentralSeriesAux G n).1
#align upper_central_series upperCentralSeries
-/

instance (n : ℕ) : Normal (upperCentralSeries G n) :=
  (upperCentralSeriesAux G n).2

#print upperCentralSeries_zero /-
@[simp]
theorem upperCentralSeries_zero : upperCentralSeries G 0 = ⊥ :=
  rfl
#align upper_central_series_zero upperCentralSeries_zero
-/

#print upperCentralSeries_one /-
@[simp]
theorem upperCentralSeries_one : upperCentralSeries G 1 = center G :=
  by
  ext
  simp only [upperCentralSeries, upperCentralSeriesAux, upperCentralSeriesStep, center, Set.center,
    mem_mk, mem_bot, Set.mem_setOf_eq]
  exact forall_congr' fun y => by rw [mul_inv_eq_one, mul_inv_eq_iff_eq_mul, eq_comm]
#align upper_central_series_one upperCentralSeries_one
-/

#print mem_upperCentralSeries_succ_iff /-
/-- The `n+1`st term of the upper central series `H i` has underlying set equal to the `x` such
that `⁅x,G⁆ ⊆ H n`-/
theorem mem_upperCentralSeries_succ_iff (n : ℕ) (x : G) :
    x ∈ upperCentralSeries G (n + 1) ↔ ∀ y : G, x * y * x⁻¹ * y⁻¹ ∈ upperCentralSeries G n :=
  Iff.rfl
#align mem_upper_central_series_succ_iff mem_upperCentralSeries_succ_iff
-/

#print Group.IsNilpotent /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`nilpotent] [] -/
-- is_nilpotent is already defined in the root namespace (for elements of rings).
/-- A group `G` is nilpotent if its upper central series is eventually `G`. -/
class Group.IsNilpotent (G : Type _) [Group G] : Prop where
  nilpotent : ∃ n : ℕ, upperCentralSeries G n = ⊤
#align group.is_nilpotent Group.IsNilpotent
-/

open Group

variable {G}

#print IsAscendingCentralSeries /-
/-- A sequence of subgroups of `G` is an ascending central series if `H 0` is trivial and
  `⁅H (n + 1), G⁆ ⊆ H n` for all `n`. Note that we do not require that `H n = G` for some `n`. -/
def IsAscendingCentralSeries (H : ℕ → Subgroup G) : Prop :=
  H 0 = ⊥ ∧ ∀ (x : G) (n : ℕ), x ∈ H (n + 1) → ∀ g, x * g * x⁻¹ * g⁻¹ ∈ H n
#align is_ascending_central_series IsAscendingCentralSeries
-/

#print IsDescendingCentralSeries /-
/-- A sequence of subgroups of `G` is a descending central series if `H 0` is `G` and
  `⁅H n, G⁆ ⊆ H (n + 1)` for all `n`. Note that we do not requre that `H n = {1}` for some `n`. -/
def IsDescendingCentralSeries (H : ℕ → Subgroup G) :=
  H 0 = ⊤ ∧ ∀ (x : G) (n : ℕ), x ∈ H n → ∀ g, x * g * x⁻¹ * g⁻¹ ∈ H (n + 1)
#align is_descending_central_series IsDescendingCentralSeries
-/

#print ascending_central_series_le_upper /-
/-- Any ascending central series for a group is bounded above by the upper central series. -/
theorem ascending_central_series_le_upper (H : ℕ → Subgroup G) (hH : IsAscendingCentralSeries H) :
    ∀ n : ℕ, H n ≤ upperCentralSeries G n
  | 0 => hH.1.symm ▸ le_refl ⊥
  | n + 1 => by
    intro x hx
    rw [mem_upperCentralSeries_succ_iff]
    exact fun y => ascending_central_series_le_upper n (hH.2 x n hx y)
#align ascending_central_series_le_upper ascending_central_series_le_upper
-/

variable (G)

#print upperCentralSeries_isAscendingCentralSeries /-
/-- The upper central series of a group is an ascending central series. -/
theorem upperCentralSeries_isAscendingCentralSeries :
    IsAscendingCentralSeries (upperCentralSeries G) :=
  ⟨rfl, fun x n h => h⟩
#align upper_central_series_is_ascending_central_series upperCentralSeries_isAscendingCentralSeries
-/

#print upperCentralSeries_mono /-
theorem upperCentralSeries_mono : Monotone (upperCentralSeries G) :=
  by
  refine' monotone_nat_of_le_succ _
  intro n x hx y
  rw [mul_assoc, mul_assoc, ← mul_assoc y x⁻¹ y⁻¹]
  exact mul_mem hx (normal.conj_mem (upperCentralSeries.Subgroup.normal G n) x⁻¹ (inv_mem hx) y)
#align upper_central_series_mono upperCentralSeries_mono
-/

#print nilpotent_iff_finite_ascending_central_series /-
/-- A group `G` is nilpotent iff there exists an ascending central series which reaches `G` in
  finitely many steps. -/
theorem nilpotent_iff_finite_ascending_central_series :
    IsNilpotent G ↔ ∃ n : ℕ, ∃ H : ℕ → Subgroup G, IsAscendingCentralSeries H ∧ H n = ⊤ :=
  by
  constructor
  · rintro ⟨n, nH⟩
    refine' ⟨_, _, upperCentralSeries_isAscendingCentralSeries G, nH⟩
  · rintro ⟨n, H, hH, hn⟩
    use n
    rw [eq_top_iff, ← hn]
    exact ascending_central_series_le_upper H hH n
#align nilpotent_iff_finite_ascending_central_series nilpotent_iff_finite_ascending_central_series
-/

#print is_decending_rev_series_of_is_ascending /-
theorem is_decending_rev_series_of_is_ascending {H : ℕ → Subgroup G} {n : ℕ} (hn : H n = ⊤)
    (hasc : IsAscendingCentralSeries H) : IsDescendingCentralSeries fun m : ℕ => H (n - m) :=
  by
  cases' hasc with h0 hH
  refine' ⟨hn, fun x m hx g => _⟩
  dsimp at hx 
  by_cases hm : n ≤ m
  · rw [tsub_eq_zero_of_le hm, h0, Subgroup.mem_bot] at hx 
    subst hx
    convert Subgroup.one_mem _
    group
  · push_neg at hm 
    apply hH
    convert hx
    rw [tsub_add_eq_add_tsub (Nat.succ_le_of_lt hm), Nat.succ_sub_succ]
#align is_decending_rev_series_of_is_ascending is_decending_rev_series_of_is_ascending
-/

#print is_ascending_rev_series_of_is_descending /-
theorem is_ascending_rev_series_of_is_descending {H : ℕ → Subgroup G} {n : ℕ} (hn : H n = ⊥)
    (hdesc : IsDescendingCentralSeries H) : IsAscendingCentralSeries fun m : ℕ => H (n - m) :=
  by
  cases' hdesc with h0 hH
  refine' ⟨hn, fun x m hx g => _⟩
  dsimp only at hx ⊢
  by_cases hm : n ≤ m
  · have hnm : n - m = 0 := tsub_eq_zero_iff_le.mpr hm
    rw [hnm, h0]
    exact mem_top _
  · push_neg at hm 
    convert hH x _ hx g
    rw [tsub_add_eq_add_tsub (Nat.succ_le_of_lt hm), Nat.succ_sub_succ]
#align is_ascending_rev_series_of_is_descending is_ascending_rev_series_of_is_descending
-/

#print nilpotent_iff_finite_descending_central_series /-
/-- A group `G` is nilpotent iff there exists a descending central series which reaches the
  trivial group in a finite time. -/
theorem nilpotent_iff_finite_descending_central_series :
    IsNilpotent G ↔ ∃ n : ℕ, ∃ H : ℕ → Subgroup G, IsDescendingCentralSeries H ∧ H n = ⊥ :=
  by
  rw [nilpotent_iff_finite_ascending_central_series]
  constructor
  · rintro ⟨n, H, hH, hn⟩
    refine' ⟨n, fun m => H (n - m), is_decending_rev_series_of_is_ascending G hn hH, _⟩
    rw [tsub_self]
    exact hH.1
  · rintro ⟨n, H, hH, hn⟩
    refine' ⟨n, fun m => H (n - m), is_ascending_rev_series_of_is_descending G hn hH, _⟩
    rw [tsub_self]
    exact hH.1
#align nilpotent_iff_finite_descending_central_series nilpotent_iff_finite_descending_central_series
-/

#print lowerCentralSeries /-
/-- The lower central series of a group `G` is a sequence `H n` of subgroups of `G`, defined
  by `H 0` is all of `G` and for `n≥1`, `H (n + 1) = ⁅H n, G⁆` -/
def lowerCentralSeries (G : Type _) [Group G] : ℕ → Subgroup G
  | 0 => ⊤
  | n + 1 => ⁅lowerCentralSeries n, ⊤⁆
#align lower_central_series lowerCentralSeries
-/

variable {G}

#print lowerCentralSeries_zero /-
@[simp]
theorem lowerCentralSeries_zero : lowerCentralSeries G 0 = ⊤ :=
  rfl
#align lower_central_series_zero lowerCentralSeries_zero
-/

#print lowerCentralSeries_one /-
@[simp]
theorem lowerCentralSeries_one : lowerCentralSeries G 1 = commutator G :=
  rfl
#align lower_central_series_one lowerCentralSeries_one
-/

#print mem_lowerCentralSeries_succ_iff /-
theorem mem_lowerCentralSeries_succ_iff (n : ℕ) (q : G) :
    q ∈ lowerCentralSeries G (n + 1) ↔
      q ∈
        closure {x | ∃ p ∈ lowerCentralSeries G n, ∃ q ∈ (⊤ : Subgroup G), p * q * p⁻¹ * q⁻¹ = x} :=
  Iff.rfl
#align mem_lower_central_series_succ_iff mem_lowerCentralSeries_succ_iff
-/

#print lowerCentralSeries_succ /-
theorem lowerCentralSeries_succ (n : ℕ) :
    lowerCentralSeries G (n + 1) =
      closure {x | ∃ p ∈ lowerCentralSeries G n, ∃ q ∈ (⊤ : Subgroup G), p * q * p⁻¹ * q⁻¹ = x} :=
  rfl
#align lower_central_series_succ lowerCentralSeries_succ
-/

instance (n : ℕ) : Normal (lowerCentralSeries G n) :=
  by
  induction' n with d hd
  · exact (⊤ : Subgroup G).normal_of_characteristic
  · exact Subgroup.commutator_normal (lowerCentralSeries G d) ⊤

#print lowerCentralSeries_antitone /-
theorem lowerCentralSeries_antitone : Antitone (lowerCentralSeries G) :=
  by
  refine' antitone_nat_of_succ_le fun n x hx => _
  simp only [mem_lowerCentralSeries_succ_iff, exists_prop, mem_top, exists_true_left,
    true_and_iff] at hx 
  refine'
    closure_induction hx _ (Subgroup.one_mem _) (@Subgroup.mul_mem _ _ _) (@Subgroup.inv_mem _ _ _)
  rintro y ⟨z, hz, a, ha⟩
  rw [← ha, mul_assoc, mul_assoc, ← mul_assoc a z⁻¹ a⁻¹]
  exact mul_mem hz (normal.conj_mem (lowerCentralSeries.Subgroup.normal n) z⁻¹ (inv_mem hz) a)
#align lower_central_series_antitone lowerCentralSeries_antitone
-/

#print lowerCentralSeries_isDescendingCentralSeries /-
/-- The lower central series of a group is a descending central series. -/
theorem lowerCentralSeries_isDescendingCentralSeries :
    IsDescendingCentralSeries (lowerCentralSeries G) :=
  by
  constructor; rfl
  intro x n hxn g
  exact commutator_mem_commutator hxn (mem_top g)
#align lower_central_series_is_descending_central_series lowerCentralSeries_isDescendingCentralSeries
-/

#print descending_central_series_ge_lower /-
/-- Any descending central series for a group is bounded below by the lower central series. -/
theorem descending_central_series_ge_lower (H : ℕ → Subgroup G) (hH : IsDescendingCentralSeries H) :
    ∀ n : ℕ, lowerCentralSeries G n ≤ H n
  | 0 => hH.1.symm ▸ le_refl ⊤
  | n + 1 => commutator_le.mpr fun x hx q _ => hH.2 x n (descending_central_series_ge_lower n hx) q
#align descending_central_series_ge_lower descending_central_series_ge_lower
-/

#print nilpotent_iff_lowerCentralSeries /-
/-- A group is nilpotent if and only if its lower central series eventually reaches
  the trivial subgroup. -/
theorem nilpotent_iff_lowerCentralSeries : IsNilpotent G ↔ ∃ n, lowerCentralSeries G n = ⊥ :=
  by
  rw [nilpotent_iff_finite_descending_central_series]
  constructor
  · rintro ⟨n, H, ⟨h0, hs⟩, hn⟩
    use n
    rw [eq_bot_iff, ← hn]
    exact descending_central_series_ge_lower H ⟨h0, hs⟩ n
  · rintro ⟨n, hn⟩
    exact ⟨n, lowerCentralSeries G, lowerCentralSeries_isDescendingCentralSeries, hn⟩
#align nilpotent_iff_lower_central_series nilpotent_iff_lowerCentralSeries
-/

section Classical

open scoped Classical

variable [hG : IsNilpotent G]

variable (G)

#print Group.nilpotencyClass /-
/-- The nilpotency class of a nilpotent group is the smallest natural `n` such that
the `n`'th term of the upper central series is `G`. -/
noncomputable def Group.nilpotencyClass : ℕ :=
  Nat.find (IsNilpotent.nilpotent G)
#align group.nilpotency_class Group.nilpotencyClass
-/

variable {G}

#print upperCentralSeries_nilpotencyClass /-
@[simp]
theorem upperCentralSeries_nilpotencyClass : upperCentralSeries G (Group.nilpotencyClass G) = ⊤ :=
  Nat.find_spec (IsNilpotent.nilpotent G)
#align upper_central_series_nilpotency_class upperCentralSeries_nilpotencyClass
-/

#print upperCentralSeries_eq_top_iff_nilpotencyClass_le /-
theorem upperCentralSeries_eq_top_iff_nilpotencyClass_le {n : ℕ} :
    upperCentralSeries G n = ⊤ ↔ Group.nilpotencyClass G ≤ n :=
  by
  constructor
  · intro h
    exact Nat.find_le h
  · intro h
    apply eq_top_iff.mpr
    rw [← upperCentralSeries_nilpotencyClass]
    exact upperCentralSeries_mono _ h
#align upper_central_series_eq_top_iff_nilpotency_class_le upperCentralSeries_eq_top_iff_nilpotencyClass_le
-/

#print least_ascending_central_series_length_eq_nilpotencyClass /-
/-- The nilpotency class of a nilpotent `G` is equal to the smallest `n` for which an ascending
central series reaches `G` in its `n`'th term. -/
theorem least_ascending_central_series_length_eq_nilpotencyClass :
    Nat.find ((nilpotent_iff_finite_ascending_central_series G).mp hG) = Group.nilpotencyClass G :=
  by
  refine' le_antisymm (Nat.find_mono _) (Nat.find_mono _)
  · intro n hn
    exact ⟨upperCentralSeries G, upperCentralSeries_isAscendingCentralSeries G, hn⟩
  · rintro n ⟨H, ⟨hH, hn⟩⟩
    rw [← top_le_iff, ← hn]
    exact ascending_central_series_le_upper H hH n
#align least_ascending_central_series_length_eq_nilpotency_class least_ascending_central_series_length_eq_nilpotencyClass
-/

#print least_descending_central_series_length_eq_nilpotencyClass /-
/-- The nilpotency class of a nilpotent `G` is equal to the smallest `n` for which the descending
central series reaches `⊥` in its `n`'th term. -/
theorem least_descending_central_series_length_eq_nilpotencyClass :
    Nat.find ((nilpotent_iff_finite_descending_central_series G).mp hG) = Group.nilpotencyClass G :=
  by
  rw [← least_ascending_central_series_length_eq_nilpotencyClass]
  refine' le_antisymm (Nat.find_mono _) (Nat.find_mono _)
  · rintro n ⟨H, ⟨hH, hn⟩⟩
    refine' ⟨fun m => H (n - m), is_decending_rev_series_of_is_ascending G hn hH, _⟩
    rw [tsub_self]
    exact hH.1
  · rintro n ⟨H, ⟨hH, hn⟩⟩
    refine' ⟨fun m => H (n - m), is_ascending_rev_series_of_is_descending G hn hH, _⟩
    rw [tsub_self]
    exact hH.1
#align least_descending_central_series_length_eq_nilpotency_class least_descending_central_series_length_eq_nilpotencyClass
-/

#print lowerCentralSeries_length_eq_nilpotencyClass /-
/-- The nilpotency class of a nilpotent `G` is equal to the length of the lower central series. -/
theorem lowerCentralSeries_length_eq_nilpotencyClass :
    Nat.find (nilpotent_iff_lowerCentralSeries.mp hG) = @Group.nilpotencyClass G _ _ :=
  by
  rw [← least_descending_central_series_length_eq_nilpotencyClass]
  refine' le_antisymm (Nat.find_mono _) (Nat.find_mono _)
  · rintro n ⟨H, ⟨hH, hn⟩⟩
    rw [← le_bot_iff, ← hn]
    exact descending_central_series_ge_lower H hH n
  · rintro n h
    exact ⟨lowerCentralSeries G, ⟨lowerCentralSeries_isDescendingCentralSeries, h⟩⟩
#align lower_central_series_length_eq_nilpotency_class lowerCentralSeries_length_eq_nilpotencyClass
-/

#print lowerCentralSeries_nilpotencyClass /-
@[simp]
theorem lowerCentralSeries_nilpotencyClass : lowerCentralSeries G (Group.nilpotencyClass G) = ⊥ :=
  by
  rw [← lowerCentralSeries_length_eq_nilpotencyClass]
  exact Nat.find_spec (nilpotent_iff_lower_central_series.mp _)
#align lower_central_series_nilpotency_class lowerCentralSeries_nilpotencyClass
-/

#print lowerCentralSeries_eq_bot_iff_nilpotencyClass_le /-
theorem lowerCentralSeries_eq_bot_iff_nilpotencyClass_le {n : ℕ} :
    lowerCentralSeries G n = ⊥ ↔ Group.nilpotencyClass G ≤ n :=
  by
  constructor
  · intro h
    rw [← lowerCentralSeries_length_eq_nilpotencyClass]
    exact Nat.find_le h
  · intro h
    apply eq_bot_iff.mpr
    rw [← lowerCentralSeries_nilpotencyClass]
    exact lowerCentralSeries_antitone h
#align lower_central_series_eq_bot_iff_nilpotency_class_le lowerCentralSeries_eq_bot_iff_nilpotencyClass_le
-/

end Classical

#print lowerCentralSeries_map_subtype_le /-
theorem lowerCentralSeries_map_subtype_le (H : Subgroup G) (n : ℕ) :
    (lowerCentralSeries H n).map H.Subtype ≤ lowerCentralSeries G n :=
  by
  induction' n with d hd
  · simp
  · rw [lowerCentralSeries_succ, lowerCentralSeries_succ, MonoidHom.map_closure]
    apply Subgroup.closure_mono
    rintro x1 ⟨x2, ⟨x3, hx3, x4, hx4, rfl⟩, rfl⟩
    exact ⟨x3, hd (mem_map.mpr ⟨x3, hx3, rfl⟩), x4, by simp⟩
#align lower_central_series_map_subtype_le lowerCentralSeries_map_subtype_le
-/

#print Subgroup.isNilpotent /-
/-- A subgroup of a nilpotent group is nilpotent -/
instance Subgroup.isNilpotent (H : Subgroup G) [hG : IsNilpotent G] : IsNilpotent H :=
  by
  rw [nilpotent_iff_lowerCentralSeries] at *
  rcases hG with ⟨n, hG⟩
  use n
  have := lowerCentralSeries_map_subtype_le H n
  simp only [hG, SetLike.le_def, mem_map, forall_apply_eq_imp_iff₂, exists_imp] at this 
  exact eq_bot_iff.mpr fun x hx => Subtype.ext (this x hx)
#align subgroup.is_nilpotent Subgroup.isNilpotent
-/

#print Subgroup.nilpotencyClass_le /-
/-- A the nilpotency class of a subgroup is less or equal the the nilpotency class of the group -/
theorem Subgroup.nilpotencyClass_le (H : Subgroup G) [hG : IsNilpotent G] :
    Group.nilpotencyClass H ≤ Group.nilpotencyClass G :=
  by
  repeat' rw [← lowerCentralSeries_length_eq_nilpotencyClass]
  apply Nat.find_mono
  intro n hG
  have := lowerCentralSeries_map_subtype_le H n
  simp only [hG, SetLike.le_def, mem_map, forall_apply_eq_imp_iff₂, exists_imp] at this 
  exact eq_bot_iff.mpr fun x hx => Subtype.ext (this x hx)
#align subgroup.nilpotency_class_le Subgroup.nilpotencyClass_le
-/

#print isNilpotent_of_subsingleton /-
instance (priority := 100) isNilpotent_of_subsingleton [Subsingleton G] : IsNilpotent G :=
  nilpotent_iff_lowerCentralSeries.2 ⟨0, Subsingleton.elim ⊤ ⊥⟩
#align is_nilpotent_of_subsingleton isNilpotent_of_subsingleton
-/

#print upperCentralSeries.map /-
theorem upperCentralSeries.map {H : Type _} [Group H] {f : G →* H} (h : Function.Surjective f)
    (n : ℕ) : Subgroup.map f (upperCentralSeries G n) ≤ upperCentralSeries H n :=
  by
  induction' n with d hd
  · simp
  · rintro _ ⟨x, hx : x ∈ upperCentralSeries G d.succ, rfl⟩ y'
    rcases h y' with ⟨y, rfl⟩
    simpa using hd (mem_map_of_mem f (hx y))
#align upper_central_series.map upperCentralSeries.map
-/

#print lowerCentralSeries.map /-
theorem lowerCentralSeries.map {H : Type _} [Group H] (f : G →* H) (n : ℕ) :
    Subgroup.map f (lowerCentralSeries G n) ≤ lowerCentralSeries H n :=
  by
  induction' n with d hd
  · simp [Nat.zero_eq]
  · rintro a ⟨x, hx : x ∈ lowerCentralSeries G d.succ, rfl⟩
    refine'
      closure_induction hx _ (by simp [f.map_one, Subgroup.one_mem _])
        (fun y z hy hz => by simp [MonoidHom.map_mul, Subgroup.mul_mem _ hy hz]) fun y hy => by
        simp [f.map_inv, Subgroup.inv_mem _ hy]
    rintro a ⟨y, hy, z, ⟨-, rfl⟩⟩
    apply mem_closure.mpr
    exact fun K hK => hK ⟨f y, hd (mem_map_of_mem f hy), by simp [commutatorElement_def]⟩
#align lower_central_series.map lowerCentralSeries.map
-/

#print lowerCentralSeries_succ_eq_bot /-
theorem lowerCentralSeries_succ_eq_bot {n : ℕ} (h : lowerCentralSeries G n ≤ center G) :
    lowerCentralSeries G (n + 1) = ⊥ :=
  by
  rw [lowerCentralSeries_succ, closure_eq_bot_iff, Set.subset_singleton_iff]
  rintro x ⟨y, hy1, z, ⟨⟩, rfl⟩
  rw [mul_assoc, ← mul_inv_rev, mul_inv_eq_one, eq_comm]
  exact mem_center_iff.mp (h hy1) z
#align lower_central_series_succ_eq_bot lowerCentralSeries_succ_eq_bot
-/

#print isNilpotent_of_ker_le_center /-
/-- The preimage of a nilpotent group is nilpotent if the kernel of the homomorphism is contained
in the center -/
theorem isNilpotent_of_ker_le_center {H : Type _} [Group H] (f : G →* H) (hf1 : f.ker ≤ center G)
    (hH : IsNilpotent H) : IsNilpotent G :=
  by
  rw [nilpotent_iff_lowerCentralSeries] at *
  rcases hH with ⟨n, hn⟩
  use n + 1
  refine' lowerCentralSeries_succ_eq_bot (le_trans ((Subgroup.map_eq_bot_iff _).mp _) hf1)
  exact eq_bot_iff.mpr (hn ▸ lowerCentralSeries.map f n)
#align is_nilpotent_of_ker_le_center isNilpotent_of_ker_le_center
-/

#print nilpotencyClass_le_of_ker_le_center /-
theorem nilpotencyClass_le_of_ker_le_center {H : Type _} [Group H] (f : G →* H)
    (hf1 : f.ker ≤ center G) (hH : IsNilpotent H) :
    @Group.nilpotencyClass G _ (isNilpotent_of_ker_le_center f hf1 hH) ≤
      Group.nilpotencyClass H + 1 :=
  by
  rw [← lowerCentralSeries_length_eq_nilpotencyClass]
  apply Nat.find_min'
  refine' lowerCentralSeries_succ_eq_bot (le_trans ((Subgroup.map_eq_bot_iff _).mp _) hf1)
  apply eq_bot_iff.mpr
  apply le_trans (lowerCentralSeries.map f _)
  simp only [lowerCentralSeries_nilpotencyClass, le_bot_iff]
#align nilpotency_class_le_of_ker_le_center nilpotencyClass_le_of_ker_le_center
-/

#print nilpotent_of_surjective /-
/-- The range of a surjective homomorphism from a nilpotent group is nilpotent -/
theorem nilpotent_of_surjective {G' : Type _} [Group G'] [h : IsNilpotent G] (f : G →* G')
    (hf : Function.Surjective f) : IsNilpotent G' :=
  by
  rcases h with ⟨n, hn⟩
  use n
  apply eq_top_iff.mpr
  calc
    ⊤ = f.range := symm (f.range_top_of_surjective hf)
    _ = Subgroup.map f ⊤ := (MonoidHom.range_eq_map _)
    _ = Subgroup.map f (upperCentralSeries G n) := by rw [hn]
    _ ≤ upperCentralSeries G' n := upperCentralSeries.map hf n
#align nilpotent_of_surjective nilpotent_of_surjective
-/

#print nilpotencyClass_le_of_surjective /-
/-- The nilpotency class of the range of a surejctive homomorphism from a
nilpotent group is less or equal the nilpotency class of the domain -/
theorem nilpotencyClass_le_of_surjective {G' : Type _} [Group G'] (f : G →* G')
    (hf : Function.Surjective f) [h : IsNilpotent G] :
    @Group.nilpotencyClass G' _ (nilpotent_of_surjective _ hf) ≤ Group.nilpotencyClass G :=
  by
  apply Nat.find_mono
  intro n hn
  apply eq_top_iff.mpr
  calc
    ⊤ = f.range := symm (f.range_top_of_surjective hf)
    _ = Subgroup.map f ⊤ := (MonoidHom.range_eq_map _)
    _ = Subgroup.map f (upperCentralSeries G n) := by rw [hn]
    _ ≤ upperCentralSeries G' n := upperCentralSeries.map hf n
#align nilpotency_class_le_of_surjective nilpotencyClass_le_of_surjective
-/

#print nilpotent_of_mulEquiv /-
/-- Nilpotency respects isomorphisms -/
theorem nilpotent_of_mulEquiv {G' : Type _} [Group G'] [h : IsNilpotent G] (f : G ≃* G') :
    IsNilpotent G' :=
  nilpotent_of_surjective f.toMonoidHom (MulEquiv.surjective f)
#align nilpotent_of_mul_equiv nilpotent_of_mulEquiv
-/

#print nilpotent_quotient_of_nilpotent /-
/-- A quotient of a nilpotent group is nilpotent -/
instance nilpotent_quotient_of_nilpotent (H : Subgroup G) [H.Normal] [h : IsNilpotent G] :
    IsNilpotent (G ⧸ H) :=
  nilpotent_of_surjective _ (show Function.Surjective (QuotientGroup.mk' H) by tidy)
#align nilpotent_quotient_of_nilpotent nilpotent_quotient_of_nilpotent
-/

#print nilpotencyClass_quotient_le /-
/-- The nilpotency class of a quotient of `G` is less or equal the nilpotency class of `G` -/
theorem nilpotencyClass_quotient_le (H : Subgroup G) [H.Normal] [h : IsNilpotent G] :
    Group.nilpotencyClass (G ⧸ H) ≤ Group.nilpotencyClass G :=
  nilpotencyClass_le_of_surjective _ _
#align nilpotency_class_quotient_le nilpotencyClass_quotient_le
-/

-- This technical lemma helps with rewriting the subgroup, which occurs in indices
private theorem comap_center_subst {H₁ H₂ : Subgroup G} [Normal H₁] [Normal H₂] (h : H₁ = H₂) :
    comap (mk' H₁) (center (G ⧸ H₁)) = comap (mk' H₂) (center (G ⧸ H₂)) := by subst h

#print comap_upperCentralSeries_quotient_center /-
theorem comap_upperCentralSeries_quotient_center (n : ℕ) :
    comap (mk' (center G)) (upperCentralSeries (G ⧸ center G) n) = upperCentralSeries G n.succ :=
  by
  induction' n with n ih
  · simp
  · let Hn := upperCentralSeries (G ⧸ center G) n
    calc
      comap (mk' (center G)) (upperCentralSeriesStep Hn) =
          comap (mk' (center G)) (comap (mk' Hn) (center ((G ⧸ center G) ⧸ Hn))) :=
        by rw [upperCentralSeriesStep_eq_comap_center]
      _ = comap (mk' (comap (mk' (center G)) Hn)) (center (G ⧸ comap (mk' (center G)) Hn)) :=
        QuotientGroup.comap_comap_center
      _ = comap (mk' (upperCentralSeries G n.succ)) (center (G ⧸ upperCentralSeries G n.succ)) :=
        (comap_center_subst ih)
      _ = upperCentralSeriesStep (upperCentralSeries G n.succ) :=
        symm (upperCentralSeriesStep_eq_comap_center _)
#align comap_upper_central_series_quotient_center comap_upperCentralSeries_quotient_center
-/

#print nilpotencyClass_zero_iff_subsingleton /-
theorem nilpotencyClass_zero_iff_subsingleton [IsNilpotent G] :
    Group.nilpotencyClass G = 0 ↔ Subsingleton G := by
  simp [Group.nilpotencyClass, Nat.find_eq_zero, subsingleton_iff_bot_eq_top]
#align nilpotency_class_zero_iff_subsingleton nilpotencyClass_zero_iff_subsingleton
-/

#print nilpotencyClass_quotient_center /-
/-- Quotienting the `center G` reduces the nilpotency class by 1 -/
theorem nilpotencyClass_quotient_center [hH : IsNilpotent G] :
    Group.nilpotencyClass (G ⧸ center G) = Group.nilpotencyClass G - 1 :=
  by
  generalize hn : Group.nilpotencyClass G = n
  rcases n with (rfl | n)
  · simp [nilpotencyClass_zero_iff_subsingleton] at *
    haveI := hn
    infer_instance
  · suffices Group.nilpotencyClass (G ⧸ center G) = n by simpa
    apply le_antisymm
    · apply upper_central_series_eq_top_iff_nilpotency_class_le.mp
      apply @comap_injective G _ _ _ (mk' (center G)) (surjective_quot_mk _)
      rw [comap_upperCentralSeries_quotient_center, comap_top, ← hn]
      exact upperCentralSeries_nilpotencyClass
    · apply le_of_add_le_add_right
      calc
        n + 1 = n.succ := rfl
        _ = Group.nilpotencyClass G := (symm hn)
        _ ≤ Group.nilpotencyClass (G ⧸ center G) + 1 :=
          nilpotencyClass_le_of_ker_le_center _ (le_of_eq (ker_mk _)) _
#align nilpotency_class_quotient_center nilpotencyClass_quotient_center
-/

#print nilpotencyClass_eq_quotient_center_plus_one /-
/-- The nilpotency class of a non-trivial group is one more than its quotient by the center -/
theorem nilpotencyClass_eq_quotient_center_plus_one [hH : IsNilpotent G] [Nontrivial G] :
    Group.nilpotencyClass G = Group.nilpotencyClass (G ⧸ center G) + 1 :=
  by
  rw [nilpotencyClass_quotient_center]
  rcases h : Group.nilpotencyClass G with ⟨⟩
  · exfalso
    rw [nilpotencyClass_zero_iff_subsingleton] at h ; skip
    apply false_of_nontrivial_of_subsingleton G
  · simp
#align nilpotency_class_eq_quotient_center_plus_one nilpotencyClass_eq_quotient_center_plus_one
-/

#print of_quotient_center_nilpotent /-
/-- If the quotient by `center G` is nilpotent, then so is G. -/
theorem of_quotient_center_nilpotent (h : IsNilpotent (G ⧸ center G)) : IsNilpotent G :=
  by
  obtain ⟨n, hn⟩ := h.nilpotent
  use n.succ
  simp [← comap_upperCentralSeries_quotient_center, hn]
#align of_quotient_center_nilpotent of_quotient_center_nilpotent
-/

#print nilpotent_center_quotient_ind /-
/-- A custom induction principle for nilpotent groups. The base case is a trivial group
(`subsingleton G`), and in the induction step, one can assume the hypothesis for
the group quotiented by its center. -/
@[elab_as_elim]
theorem nilpotent_center_quotient_ind {P : ∀ (G) [Group G], ∀ [IsNilpotent G], Prop} (G : Type _)
    [Group G] [IsNilpotent G] (hbase : ∀ (G) [Group G] [Subsingleton G], P G)
    (hstep : ∀ (G) [Group G], ∀ [IsNilpotent G], ∀ ih : P (G ⧸ center G), P G) : P G :=
  by
  obtain ⟨n, h⟩ : ∃ n, Group.nilpotencyClass G = n := ⟨_, rfl⟩
  induction' n with n ih generalizing G
  · haveI := nilpotency_class_zero_iff_subsingleton.mp h
    exact hbase _
  · have hn : Group.nilpotencyClass (G ⧸ center G) = n := by
      simp [nilpotencyClass_quotient_center, h]
    exact hstep _ (ih _ hn)
#align nilpotent_center_quotient_ind nilpotent_center_quotient_ind
-/

#print derived_le_lower_central /-
theorem derived_le_lower_central (n : ℕ) : derivedSeries G n ≤ lowerCentralSeries G n := by
  induction' n with i ih; · simp; · apply commutator_mono ih; simp
#align derived_le_lower_central derived_le_lower_central
-/

#print CommGroup.isNilpotent /-
/-- Abelian groups are nilpotent -/
instance (priority := 100) CommGroup.isNilpotent {G : Type _} [CommGroup G] : IsNilpotent G :=
  by
  use 1
  rw [upperCentralSeries_one]
  apply CommGroup.center_eq_top
#align comm_group.is_nilpotent CommGroup.isNilpotent
-/

#print CommGroup.nilpotencyClass_le_one /-
/-- Abelian groups have nilpotency class at most one -/
theorem CommGroup.nilpotencyClass_le_one {G : Type _} [CommGroup G] : Group.nilpotencyClass G ≤ 1 :=
  by
  apply upper_central_series_eq_top_iff_nilpotency_class_le.mp
  rw [upperCentralSeries_one]
  apply CommGroup.center_eq_top
#align comm_group.nilpotency_class_le_one CommGroup.nilpotencyClass_le_one
-/

#print commGroupOfNilpotencyClass /-
/-- Groups with nilpotency class at most one are abelian -/
def commGroupOfNilpotencyClass [IsNilpotent G] (h : Group.nilpotencyClass G ≤ 1) : CommGroup G :=
  Group.commGroupOfCenterEqTop <| by
    rw [← upperCentralSeries_one]
    exact upper_central_series_eq_top_iff_nilpotency_class_le.mpr h
#align comm_group_of_nilpotency_class commGroupOfNilpotencyClass
-/

section Prod

variable {G₁ G₂ : Type _} [Group G₁] [Group G₂]

#print lowerCentralSeries_prod /-
theorem lowerCentralSeries_prod (n : ℕ) :
    lowerCentralSeries (G₁ × G₂) n = (lowerCentralSeries G₁ n).Prod (lowerCentralSeries G₂ n) :=
  by
  induction' n with n ih
  · simp
  ·
    calc
      lowerCentralSeries (G₁ × G₂) n.succ = ⁅lowerCentralSeries (G₁ × G₂) n, ⊤⁆ := rfl
      _ = ⁅(lowerCentralSeries G₁ n).Prod (lowerCentralSeries G₂ n), ⊤⁆ := by rw [ih]
      _ = ⁅(lowerCentralSeries G₁ n).Prod (lowerCentralSeries G₂ n), (⊤ : Subgroup G₁).Prod ⊤⁆ := by
        simp
      _ = ⁅lowerCentralSeries G₁ n, (⊤ : Subgroup G₁)⁆.Prod ⁅lowerCentralSeries G₂ n, ⊤⁆ :=
        (commutator_prod_prod _ _ _ _)
      _ = (lowerCentralSeries G₁ n.succ).Prod (lowerCentralSeries G₂ n.succ) := rfl
#align lower_central_series_prod lowerCentralSeries_prod
-/

#print isNilpotent_prod /-
/-- Products of nilpotent groups are nilpotent -/
instance isNilpotent_prod [IsNilpotent G₁] [IsNilpotent G₂] : IsNilpotent (G₁ × G₂) :=
  by
  rw [nilpotent_iff_lowerCentralSeries]
  refine' ⟨max (Group.nilpotencyClass G₁) (Group.nilpotencyClass G₂), _⟩
  rw [lowerCentralSeries_prod,
    lower_central_series_eq_bot_iff_nilpotency_class_le.mpr (le_max_left _ _),
    lower_central_series_eq_bot_iff_nilpotency_class_le.mpr (le_max_right _ _), bot_prod_bot]
#align is_nilpotent_prod isNilpotent_prod
-/

#print nilpotencyClass_prod /-
/-- The nilpotency class of a product is the max of the nilpotency classes of the factors -/
theorem nilpotencyClass_prod [IsNilpotent G₁] [IsNilpotent G₂] :
    Group.nilpotencyClass (G₁ × G₂) = max (Group.nilpotencyClass G₁) (Group.nilpotencyClass G₂) :=
  by
  refine' eq_of_forall_ge_iff fun k => _
  simp only [max_le_iff, ← lowerCentralSeries_eq_bot_iff_nilpotencyClass_le,
    lowerCentralSeries_prod, prod_eq_bot_iff]
#align nilpotency_class_prod nilpotencyClass_prod
-/

end Prod

section BoundedPi

-- First the case of infinite products with bounded nilpotency class
variable {η : Type _} {Gs : η → Type _} [∀ i, Group (Gs i)]

#print lowerCentralSeries_pi_le /-
theorem lowerCentralSeries_pi_le (n : ℕ) :
    lowerCentralSeries (∀ i, Gs i) n ≤ Subgroup.pi Set.univ fun i => lowerCentralSeries (Gs i) n :=
  by
  let pi := fun f : ∀ i, Subgroup (Gs i) => Subgroup.pi Set.univ f
  induction' n with n ih
  · simp [pi_top]
  ·
    calc
      lowerCentralSeries (∀ i, Gs i) n.succ = ⁅lowerCentralSeries (∀ i, Gs i) n, ⊤⁆ := rfl
      _ ≤ ⁅pi fun i => lowerCentralSeries (Gs i) n, ⊤⁆ := (commutator_mono ih (le_refl _))
      _ = ⁅pi fun i => lowerCentralSeries (Gs i) n, pi fun i => ⊤⁆ := by simp [pi, pi_top]
      _ ≤ pi fun i => ⁅lowerCentralSeries (Gs i) n, ⊤⁆ := (commutator_pi_pi_le _ _)
      _ = pi fun i => lowerCentralSeries (Gs i) n.succ := rfl
#align lower_central_series_pi_le lowerCentralSeries_pi_le
-/

#print isNilpotent_pi_of_bounded_class /-
/-- products of nilpotent groups are nilpotent if their nipotency class is bounded -/
theorem isNilpotent_pi_of_bounded_class [∀ i, IsNilpotent (Gs i)] (n : ℕ)
    (h : ∀ i, Group.nilpotencyClass (Gs i) ≤ n) : IsNilpotent (∀ i, Gs i) :=
  by
  rw [nilpotent_iff_lowerCentralSeries]
  refine' ⟨n, _⟩
  rw [eq_bot_iff]
  apply le_trans (lowerCentralSeries_pi_le _)
  rw [← eq_bot_iff, pi_eq_bot_iff]
  intro i
  apply lower_central_series_eq_bot_iff_nilpotency_class_le.mpr (h i)
#align is_nilpotent_pi_of_bounded_class isNilpotent_pi_of_bounded_class
-/

end BoundedPi

section FinitePi

-- Now for finite products
variable {η : Type _} {Gs : η → Type _} [∀ i, Group (Gs i)]

#print lowerCentralSeries_pi_of_finite /-
theorem lowerCentralSeries_pi_of_finite [Finite η] (n : ℕ) :
    lowerCentralSeries (∀ i, Gs i) n = Subgroup.pi Set.univ fun i => lowerCentralSeries (Gs i) n :=
  by
  let pi := fun f : ∀ i, Subgroup (Gs i) => Subgroup.pi Set.univ f
  induction' n with n ih
  · simp [pi_top]
  ·
    calc
      lowerCentralSeries (∀ i, Gs i) n.succ = ⁅lowerCentralSeries (∀ i, Gs i) n, ⊤⁆ := rfl
      _ = ⁅pi fun i => lowerCentralSeries (Gs i) n, ⊤⁆ := by rw [ih]
      _ = ⁅pi fun i => lowerCentralSeries (Gs i) n, pi fun i => ⊤⁆ := by simp [pi, pi_top]
      _ = pi fun i => ⁅lowerCentralSeries (Gs i) n, ⊤⁆ := (commutator_pi_pi_of_finite _ _)
      _ = pi fun i => lowerCentralSeries (Gs i) n.succ := rfl
#align lower_central_series_pi_of_finite lowerCentralSeries_pi_of_finite
-/

#print isNilpotent_pi /-
/-- n-ary products of nilpotent groups are nilpotent -/
instance isNilpotent_pi [Finite η] [∀ i, IsNilpotent (Gs i)] : IsNilpotent (∀ i, Gs i) :=
  by
  cases nonempty_fintype η
  rw [nilpotent_iff_lowerCentralSeries]
  refine' ⟨finset.univ.sup fun i => Group.nilpotencyClass (Gs i), _⟩
  rw [lowerCentralSeries_pi_of_finite, pi_eq_bot_iff]
  intro i
  apply lower_central_series_eq_bot_iff_nilpotency_class_le.mpr
  exact
    @Finset.le_sup _ _ _ _ Finset.univ (fun i => Group.nilpotencyClass (Gs i)) _ (Finset.mem_univ i)
#align is_nilpotent_pi isNilpotent_pi
-/

#print nilpotencyClass_pi /-
/-- The nilpotency class of an n-ary product is the sup of the nilpotency classes of the factors -/
theorem nilpotencyClass_pi [Fintype η] [∀ i, IsNilpotent (Gs i)] :
    Group.nilpotencyClass (∀ i, Gs i) = Finset.univ.sup fun i => Group.nilpotencyClass (Gs i) :=
  by
  apply eq_of_forall_ge_iff
  intro k
  simp only [Finset.sup_le_iff, ← lowerCentralSeries_eq_bot_iff_nilpotencyClass_le,
    lowerCentralSeries_pi_of_finite, pi_eq_bot_iff, Finset.mem_univ, true_imp_iff]
#align nilpotency_class_pi nilpotencyClass_pi
-/

end FinitePi

#print IsNilpotent.to_isSolvable /-
/-- A nilpotent subgroup is solvable -/
instance (priority := 100) IsNilpotent.to_isSolvable [h : IsNilpotent G] : IsSolvable G :=
  by
  obtain ⟨n, hn⟩ := nilpotent_iff_lowerCentralSeries.1 h
  use n
  rw [eq_bot_iff, ← hn]
  exact derived_le_lower_central n
#align is_nilpotent.to_is_solvable IsNilpotent.to_isSolvable
-/

#print normalizerCondition_of_isNilpotent /-
theorem normalizerCondition_of_isNilpotent [h : IsNilpotent G] : NormalizerCondition G :=
  by
  -- roughly based on https://groupprops.subwiki.org/wiki/Nilpotent_implies_normalizer_condition
  rw [normalizerCondition_iff_only_full_group_self_normalizing]
  apply nilpotent_center_quotient_ind G <;> clear! G
  · intro G _ _ H _; apply Subsingleton.elim
  · intro G _ _ ih H hH
    have hch : center G ≤ H := subgroup.center_le_normalizer.trans (le_of_eq hH)
    have hkh : (mk' (center G)).ker ≤ H := by simpa using hch
    have hsur : Function.Surjective (mk' (center G)) := surjective_quot_mk _
    let H' := H.map (mk' (center G))
    have hH' : H'.normalizer = H' := by
      apply comap_injective hsur
      rw [comap_normalizer_eq_of_surjective _ hsur, comap_map_eq_self hkh]
      exact hH
    apply map_injective_of_ker_le (mk' (center G)) hkh le_top
    exact (ih H' hH').trans (symm (map_top_of_surjective _ hsur))
#align normalizer_condition_of_is_nilpotent normalizerCondition_of_isNilpotent
-/

end WithGroup

section WithFiniteGroup

open Group Fintype

variable {G : Type _} [hG : Group G]

#print IsPGroup.isNilpotent /-
/-- A p-group is nilpotent -/
theorem IsPGroup.isNilpotent [Finite G] {p : ℕ} [hp : Fact (Nat.Prime p)] (h : IsPGroup p G) :
    IsNilpotent G := by
  cases nonempty_fintype G
  classical
  revert hG
  induction' val using Fintype.induction_subsingleton_or_nontrivial with G hG hS G hG hN ih
  · infer_instance
  · intro; intro h
    have hcq : Fintype.card (G ⧸ center G) < Fintype.card G :=
      by
      rw [card_eq_card_quotient_mul_card_subgroup (center G)]
      apply lt_mul_of_one_lt_right
      exact fintype.card_pos_iff.mpr One.nonempty
      exact (Subgroup.one_lt_card_iff_ne_bot _).mpr (ne_of_gt h.bot_lt_center)
    have hnq : IsNilpotent (G ⧸ center G) := ih _ hcq (h.to_quotient (center G))
    exact of_quotient_center_nilpotent hnq
#align is_p_group.is_nilpotent IsPGroup.isNilpotent
-/

variable [Fintype G]

#print isNilpotent_of_product_of_sylow_group /-
/-- If a finite group is the direct product of its Sylow groups, it is nilpotent -/
theorem isNilpotent_of_product_of_sylow_group
    (e : (∀ p : (Fintype.card G).factorization.support, ∀ P : Sylow p G, (↑P : Subgroup G)) ≃* G) :
    IsNilpotent G := by
  classical
  let ps := (Fintype.card G).factorization.support
  have : ∀ (p : ps) (P : Sylow p G), IsNilpotent (↑P : Subgroup G) :=
    by
    intro p P
    haveI : Fact (Nat.Prime ↑p) := Fact.mk (Nat.prime_of_mem_factorization (Finset.coe_mem p))
    exact P.is_p_group'.is_nilpotent
  exact nilpotent_of_mulEquiv e
#align is_nilpotent_of_product_of_sylow_group isNilpotent_of_product_of_sylow_group
-/

#print isNilpotent_of_finite_tFAE /-
/-- A finite group is nilpotent iff the normalizer condition holds, and iff all maximal groups are
normal and iff all sylow groups are normal and iff the group is the direct product of its sylow
groups. -/
theorem isNilpotent_of_finite_tFAE :
    TFAE
      [IsNilpotent G, NormalizerCondition G, ∀ H : Subgroup G, IsCoatom H → H.Normal,
        ∀ (p : ℕ) (hp : Fact p.Prime) (P : Sylow p G), (↑P : Subgroup G).Normal,
        Nonempty
          ((∀ p : (card G).factorization.support, ∀ P : Sylow p G, (↑P : Subgroup G)) ≃* G)] :=
  by
  tfae_have 1 → 2; · exact @normalizerCondition_of_isNilpotent _ _
  tfae_have 2 → 3; · exact fun h H => normalizer_condition.normal_of_coatom H h
  tfae_have 3 → 4; · intro h p _ P; exact Sylow.normal_of_all_max_subgroups_normal h _
  tfae_have 4 → 5; · exact fun h => Nonempty.intro (Sylow.directProductOfNormal h)
  tfae_have 5 → 1; · rintro ⟨e⟩; exact isNilpotent_of_product_of_sylow_group e
  tfae_finish
#align is_nilpotent_of_finite_tfae isNilpotent_of_finite_tFAE
-/

end WithFiniteGroup

