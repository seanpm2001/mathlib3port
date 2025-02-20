/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module group_theory.subsemigroup.membership
! leanprover-community/mathlib commit baba818b9acea366489e8ba32d2cc0fcaf50a1f7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subsemigroup.Basic

/-!
# Subsemigroups: membership criteria

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove various facts about membership in a subsemigroup.
The intent is to mimic `group_theory/submonoid/membership`, but currently this file is mostly a
stub and only provides rudimentary support.

* `mem_supr_of_directed`, `coe_supr_of_directed`, `mem_Sup_of_directed_on`,
  `coe_Sup_of_directed_on`: the supremum of a directed collection of subsemigroup is their union.

## TODO

* Define the `free_semigroup` generated by a set. This might require some rather substantial
  additions to low-level API. For example, developing the subtype of nonempty lists, then defining
  a product on nonempty lists, powers where the exponent is a positive natural, et cetera.
  Another option would be to define the `free_semigroup` as the subsemigroup (pushed to be a
  semigroup) of the `free_monoid` consisting of non-identity elements.

## Tags
subsemigroup
-/


variable {ι : Sort _} {M A B : Type _}

section NonAssoc

variable [Mul M]

open Set

namespace Subsemigroup

#print Subsemigroup.mem_iSup_of_directed /-
-- TODO: this section can be generalized to `[mul_mem_class B M] [complete_lattice B]`
-- such that `complete_lattice.le` coincides with `set_like.le`
@[to_additive]
theorem mem_iSup_of_directed {S : ι → Subsemigroup M} (hS : Directed (· ≤ ·) S) {x : M} :
    (x ∈ ⨆ i, S i) ↔ ∃ i, x ∈ S i :=
  by
  refine' ⟨_, fun ⟨i, hi⟩ => (SetLike.le_def.1 <| le_iSup S i) hi⟩
  suffices x ∈ closure (⋃ i, (S i : Set M)) → ∃ i, x ∈ S i by
    simpa only [closure_iUnion, closure_eq (S _)] using this
  refine' fun hx => closure_induction hx (fun y hy => mem_Union.mp hy) _
  · rintro x y ⟨i, hi⟩ ⟨j, hj⟩
    rcases hS i j with ⟨k, hki, hkj⟩
    exact ⟨k, (S k).mul_mem (hki hi) (hkj hj)⟩
#align subsemigroup.mem_supr_of_directed Subsemigroup.mem_iSup_of_directed
#align add_subsemigroup.mem_supr_of_directed AddSubsemigroup.mem_iSup_of_directed
-/

#print Subsemigroup.coe_iSup_of_directed /-
@[to_additive]
theorem coe_iSup_of_directed {S : ι → Subsemigroup M} (hS : Directed (· ≤ ·) S) :
    ((⨆ i, S i : Subsemigroup M) : Set M) = ⋃ i, ↑(S i) :=
  Set.ext fun x => by simp [mem_supr_of_directed hS]
#align subsemigroup.coe_supr_of_directed Subsemigroup.coe_iSup_of_directed
#align add_subsemigroup.coe_supr_of_directed AddSubsemigroup.coe_iSup_of_directed
-/

#print Subsemigroup.mem_sSup_of_directed_on /-
@[to_additive]
theorem mem_sSup_of_directed_on {S : Set (Subsemigroup M)} (hS : DirectedOn (· ≤ ·) S) {x : M} :
    x ∈ sSup S ↔ ∃ s ∈ S, x ∈ s := by
  simp only [sSup_eq_iSup', mem_supr_of_directed hS.directed_coe, SetCoe.exists, Subtype.coe_mk]
#align subsemigroup.mem_Sup_of_directed_on Subsemigroup.mem_sSup_of_directed_on
#align add_subsemigroup.mem_Sup_of_directed_on AddSubsemigroup.mem_sSup_of_directed_on
-/

#print Subsemigroup.coe_sSup_of_directed_on /-
@[to_additive]
theorem coe_sSup_of_directed_on {S : Set (Subsemigroup M)} (hS : DirectedOn (· ≤ ·) S) :
    (↑(sSup S) : Set M) = ⋃ s ∈ S, ↑s :=
  Set.ext fun x => by simp [mem_Sup_of_directed_on hS]
#align subsemigroup.coe_Sup_of_directed_on Subsemigroup.coe_sSup_of_directed_on
#align add_subsemigroup.coe_Sup_of_directed_on AddSubsemigroup.coe_sSup_of_directed_on
-/

#print Subsemigroup.mem_sup_left /-
@[to_additive]
theorem mem_sup_left {S T : Subsemigroup M} : ∀ {x : M}, x ∈ S → x ∈ S ⊔ T :=
  show S ≤ S ⊔ T from le_sup_left
#align subsemigroup.mem_sup_left Subsemigroup.mem_sup_left
#align add_subsemigroup.mem_sup_left AddSubsemigroup.mem_sup_left
-/

#print Subsemigroup.mem_sup_right /-
@[to_additive]
theorem mem_sup_right {S T : Subsemigroup M} : ∀ {x : M}, x ∈ T → x ∈ S ⊔ T :=
  show T ≤ S ⊔ T from le_sup_right
#align subsemigroup.mem_sup_right Subsemigroup.mem_sup_right
#align add_subsemigroup.mem_sup_right AddSubsemigroup.mem_sup_right
-/

#print Subsemigroup.mul_mem_sup /-
@[to_additive]
theorem mul_mem_sup {S T : Subsemigroup M} {x y : M} (hx : x ∈ S) (hy : y ∈ T) : x * y ∈ S ⊔ T :=
  mul_mem (mem_sup_left hx) (mem_sup_right hy)
#align subsemigroup.mul_mem_sup Subsemigroup.mul_mem_sup
#align add_subsemigroup.add_mem_sup AddSubsemigroup.add_mem_sup
-/

#print Subsemigroup.mem_iSup_of_mem /-
@[to_additive]
theorem mem_iSup_of_mem {S : ι → Subsemigroup M} (i : ι) : ∀ {x : M}, x ∈ S i → x ∈ iSup S :=
  show S i ≤ iSup S from le_iSup _ _
#align subsemigroup.mem_supr_of_mem Subsemigroup.mem_iSup_of_mem
#align add_subsemigroup.mem_supr_of_mem AddSubsemigroup.mem_iSup_of_mem
-/

#print Subsemigroup.mem_sSup_of_mem /-
@[to_additive]
theorem mem_sSup_of_mem {S : Set (Subsemigroup M)} {s : Subsemigroup M} (hs : s ∈ S) :
    ∀ {x : M}, x ∈ s → x ∈ sSup S :=
  show s ≤ sSup S from le_sSup hs
#align subsemigroup.mem_Sup_of_mem Subsemigroup.mem_sSup_of_mem
#align add_subsemigroup.mem_Sup_of_mem AddSubsemigroup.mem_sSup_of_mem
-/

#print Subsemigroup.iSup_induction /-
/-- An induction principle for elements of `⨆ i, S i`.
If `C` holds all elements of `S i` for all `i`, and is preserved under multiplication,
then it holds for all elements of the supremum of `S`. -/
@[elab_as_elim,
  to_additive
      " An induction principle for elements of `⨆ i, S i`.\nIf `C` holds all elements of `S i` for all `i`, and is preserved under addition,\nthen it holds for all elements of the supremum of `S`. "]
theorem iSup_induction (S : ι → Subsemigroup M) {C : M → Prop} {x : M} (hx : x ∈ ⨆ i, S i)
    (hp : ∀ (i), ∀ x ∈ S i, C x) (hmul : ∀ x y, C x → C y → C (x * y)) : C x :=
  by
  rw [supr_eq_closure] at hx 
  refine' closure_induction hx (fun x hx => _) hmul
  obtain ⟨i, hi⟩ := set.mem_Union.mp hx
  exact hp _ _ hi
#align subsemigroup.supr_induction Subsemigroup.iSup_induction
#align add_subsemigroup.supr_induction AddSubsemigroup.iSup_induction
-/

#print Subsemigroup.iSup_induction' /-
/-- A dependent version of `subsemigroup.supr_induction`. -/
@[elab_as_elim, to_additive "A dependent version of `add_subsemigroup.supr_induction`. "]
theorem iSup_induction' (S : ι → Subsemigroup M) {C : ∀ x, (x ∈ ⨆ i, S i) → Prop}
    (hp : ∀ (i), ∀ x ∈ S i, C x (mem_iSup_of_mem i ‹_›))
    (hmul : ∀ x y hx hy, C x hx → C y hy → C (x * y) (mul_mem ‹_› ‹_›)) {x : M}
    (hx : x ∈ ⨆ i, S i) : C x hx :=
  by
  refine' Exists.elim _ fun (hx : x ∈ ⨆ i, S i) (hc : C x hx) => hc
  refine' supr_induction S hx (fun i x hx => _) fun x y => _
  · exact ⟨_, hp _ _ hx⟩
  · rintro ⟨_, Cx⟩ ⟨_, Cy⟩
    exact ⟨_, hmul _ _ _ _ Cx Cy⟩
#align subsemigroup.supr_induction' Subsemigroup.iSup_induction'
#align add_subsemigroup.supr_induction' AddSubsemigroup.iSup_induction'
-/

end Subsemigroup

end NonAssoc

