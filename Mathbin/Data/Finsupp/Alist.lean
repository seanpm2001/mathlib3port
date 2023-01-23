/-
Copyright (c) 2022 Violeta Hernández. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Violeta Hernández

! This file was ported from Lean 3 source module data.finsupp.alist
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finsupp.Basic
import Mathbin.Data.List.Alist

/-!
# Connections between `finsupp` and `alist`

## Main definitions

* `finsupp.to_alist`
* `alist.lookup_finsupp`: converts an association list into a finitely supported function
  via `alist.lookup`, sending absent keys to zero.

-/


namespace Finsupp

variable {α M : Type _} [Zero M]

/-- Produce an association list for the finsupp over its support using choice. -/
@[simps]
noncomputable def toAlist (f : α →₀ M) : AList fun x : α => M :=
  ⟨f.graph.toList.map Prod.toSigma,
    by
    rw [List.NodupKeys, List.keys, List.map_map, Prod.fst_comp_toSigma, List.nodup_map_iff_inj_on]
    · rintro ⟨b, m⟩ hb ⟨c, n⟩ hc (rfl : b = c)
      rw [Finset.mem_toList, Finsupp.mem_graph_iff] at hb hc
      dsimp at hb hc
      rw [← hc.1, hb.1]
    · apply Finset.nodup_toList⟩
#align finsupp.to_alist Finsupp.toAlist

@[simp]
theorem toAlist_keys_toFinset [DecidableEq α] (f : α →₀ M) : f.toAlist.keys.toFinset = f.support :=
  by
  ext
  simp [to_alist, AList.mem_keys, AList.keys, List.keys]
#align finsupp.to_alist_keys_to_finset Finsupp.toAlist_keys_toFinset

@[simp]
theorem mem_toAlist {f : α →₀ M} {x : α} : x ∈ f.toAlist ↔ f x ≠ 0 := by
  classical rw [AList.mem_keys, ← List.mem_toFinset, to_alist_keys_to_finset, mem_support_iff]
#align finsupp.mem_to_alist Finsupp.mem_toAlist

end Finsupp

namespace AList

variable {α M : Type _} [Zero M]

open List

/-- Converts an association list into a finitely supported function via `alist.lookup`, sending
absent keys to zero. -/
noncomputable def lookupFinsupp (l : AList fun x : α => M) : α →₀ M
    where
  support := by
    haveI := Classical.decEq α <;> haveI := Classical.decEq M <;>
      exact (l.1.filter fun x => Sigma.snd x ≠ 0).keys.toFinset
  toFun a :=
    haveI := Classical.decEq α
    (l.lookup a).getOrElse 0
  mem_support_to_fun a := by
    classical
      simp_rw [mem_to_finset, List.mem_keys, List.mem_filter, ← mem_lookup_iff]
      cases lookup a l <;> simp
#align alist.lookup_finsupp AList.lookupFinsupp

@[simp]
theorem lookupFinsupp_apply [DecidableEq α] (l : AList fun x : α => M) (a : α) :
    l.lookupFinsupp a = (l.lookup a).getOrElse 0 := by convert rfl
#align alist.lookup_finsupp_apply AList.lookupFinsupp_apply

@[simp]
theorem lookupFinsupp_support [DecidableEq α] [DecidableEq M] (l : AList fun x : α => M) :
    l.lookupFinsupp.support = (l.1.filter fun x => Sigma.snd x ≠ 0).keys.toFinset := by convert rfl
#align alist.lookup_finsupp_support AList.lookupFinsupp_support

theorem lookupFinsupp_eq_iff_of_ne_zero [DecidableEq α] {l : AList fun x : α => M} {a : α} {x : M}
    (hx : x ≠ 0) : l.lookupFinsupp a = x ↔ x ∈ l.lookup a :=
  by
  rw [lookup_finsupp_apply]
  cases' lookup a l with m <;> simp [hx.symm]
#align alist.lookup_finsupp_eq_iff_of_ne_zero AList.lookupFinsupp_eq_iff_of_ne_zero

theorem lookupFinsupp_eq_zero_iff [DecidableEq α] {l : AList fun x : α => M} {a : α} :
    l.lookupFinsupp a = 0 ↔ a ∉ l ∨ (0 : M) ∈ l.lookup a :=
  by
  rw [lookup_finsupp_apply, ← lookup_eq_none]
  cases' lookup a l with m <;> simp
#align alist.lookup_finsupp_eq_zero_iff AList.lookupFinsupp_eq_zero_iff

@[simp]
theorem empty_lookupFinsupp : lookupFinsupp (∅ : AList fun x : α => M) = 0 := by
  classical
    ext
    simp
#align alist.empty_lookup_finsupp AList.empty_lookupFinsupp

@[simp]
theorem insert_lookupFinsupp [DecidableEq α] (l : AList fun x : α => M) (a : α) (m : M) :
    (l.insert a m).lookupFinsupp = l.lookupFinsupp.update a m :=
  by
  ext b
  by_cases h : b = a <;> simp [h]
#align alist.insert_lookup_finsupp AList.insert_lookupFinsupp

@[simp]
theorem singleton_lookupFinsupp (a : α) (m : M) :
    (singleton a m).lookupFinsupp = Finsupp.single a m := by classical simp [← AList.insert_empty]
#align alist.singleton_lookup_finsupp AList.singleton_lookupFinsupp

@[simp]
theorem Finsupp.toAlist_lookupFinsupp (f : α →₀ M) : f.toAlist.lookupFinsupp = f :=
  by
  ext
  by_cases h : f a = 0
  · suffices f.to_alist.lookup a = none by simp [h, this]
    · simp [lookup_eq_none, h]
  · suffices f.to_alist.lookup a = some (f a) by simp [h, this]
    · apply mem_lookup_iff.2
      simpa using h
#align finsupp.to_alist_lookup_finsupp Finsupp.toAlist_lookupFinsupp

theorem lookupFinsupp_surjective : Function.Surjective (@lookupFinsupp α M _) := fun f =>
  ⟨_, Finsupp.toAlist_lookupFinsupp f⟩
#align alist.lookup_finsupp_surjective AList.lookupFinsupp_surjective

end AList

