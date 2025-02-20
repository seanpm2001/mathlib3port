/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module data.set.pointwise.big_operators
! leanprover-community/mathlib commit fa2cb8a9e2b987db233e4e6eb47645feafba8861
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Basic
import Mathbin.Data.Set.Pointwise.Basic

/-!
# Results about pointwise operations on sets and big operators.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


namespace Set

open scoped BigOperators Pointwise

open Function

variable {ι α β F : Type _}

section Monoid

variable [Monoid α] [Monoid β] [MonoidHomClass F α β]

#print Set.image_list_prod /-
@[to_additive]
theorem image_list_prod (f : F) :
    ∀ l : List (Set α), (f : α → β) '' l.Prod = (l.map fun s => f '' s).Prod
  | [] => image_one.trans <| congr_arg singleton (map_one f)
  | a :: as => by rw [List.map_cons, List.prod_cons, List.prod_cons, image_mul, image_list_prod]
#align set.image_list_prod Set.image_list_prod
#align set.image_list_sum Set.image_list_sum
-/

end Monoid

section CommMonoid

variable [CommMonoid α] [CommMonoid β] [MonoidHomClass F α β]

#print Set.image_multiset_prod /-
@[to_additive]
theorem image_multiset_prod (f : F) :
    ∀ m : Multiset (Set α), (f : α → β) '' m.Prod = (m.map fun s => f '' s).Prod :=
  Quotient.ind <| by
    simpa only [Multiset.quot_mk_to_coe, Multiset.coe_prod, Multiset.coe_map] using
      image_list_prod f
#align set.image_multiset_prod Set.image_multiset_prod
#align set.image_multiset_sum Set.image_multiset_sum
-/

#print Set.image_finset_prod /-
@[to_additive]
theorem image_finset_prod (f : F) (m : Finset ι) (s : ι → Set α) :
    (f : α → β) '' ∏ i in m, s i = ∏ i in m, f '' s i :=
  (image_multiset_prod f _).trans <| congr_arg Multiset.prod <| Multiset.map_map _ _ _
#align set.image_finset_prod Set.image_finset_prod
#align set.image_finset_sum Set.image_finset_sum
-/

#print Set.mem_finset_prod /-
/-- The n-ary version of `set.mem_mul`. -/
@[to_additive " The n-ary version of `set.mem_add`. "]
theorem mem_finset_prod (t : Finset ι) (f : ι → Set α) (a : α) :
    a ∈ ∏ i in t, f i ↔ ∃ (g : ι → α) (hg : ∀ {i}, i ∈ t → g i ∈ f i), ∏ i in t, g i = a := by
  classical
  induction' t using Finset.induction_on with i is hi ih generalizing a
  · simp_rw [Finset.prod_empty, Set.mem_one]
    exact ⟨fun h => ⟨fun i => a, fun i => False.elim, h.symm⟩, fun ⟨f, _, hf⟩ => hf.symm⟩
  rw [Finset.prod_insert hi, Set.mem_mul]
  simp_rw [Finset.prod_insert hi]
  simp_rw [ih]
  constructor
  · rintro ⟨x, y, hx, ⟨g, hg, rfl⟩, rfl⟩
    refine' ⟨Function.update g i x, fun j hj => _, _⟩
    obtain rfl | hj := finset.mem_insert.mp hj
    · rw [Function.update_same]; exact hx
    · rw [update_noteq (ne_of_mem_of_not_mem hj hi)]; exact hg hj
    rw [Finset.prod_update_of_not_mem hi, Function.update_same]
  · rintro ⟨g, hg, rfl⟩
    exact
      ⟨g i, is.prod g, hg (is.mem_insert_self _),
        ⟨g, fun i hi => hg (Finset.mem_insert_of_mem hi), rfl⟩, rfl⟩
#align set.mem_finset_prod Set.mem_finset_prod
#align set.mem_finset_sum Set.mem_finset_sum
-/

#print Set.mem_fintype_prod /-
/-- A version of `set.mem_finset_prod` with a simpler RHS for products over a fintype. -/
@[to_additive " A version of `set.mem_finset_sum` with a simpler RHS for sums over a fintype. "]
theorem mem_fintype_prod [Fintype ι] (f : ι → Set α) (a : α) :
    a ∈ ∏ i, f i ↔ ∃ (g : ι → α) (hg : ∀ i, g i ∈ f i), ∏ i, g i = a := by rw [mem_finset_prod];
  simp
#align set.mem_fintype_prod Set.mem_fintype_prod
#align set.mem_fintype_sum Set.mem_fintype_sum
-/

#print Set.list_prod_mem_list_prod /-
/-- An n-ary version of `set.mul_mem_mul`. -/
@[to_additive " An n-ary version of `set.add_mem_add`. "]
theorem list_prod_mem_list_prod (t : List ι) (f : ι → Set α) (g : ι → α) (hg : ∀ i ∈ t, g i ∈ f i) :
    (t.map g).Prod ∈ (t.map f).Prod :=
  by
  induction' t with h tl ih
  · simp_rw [List.map_nil, List.prod_nil, Set.mem_one]
  · simp_rw [List.map_cons, List.prod_cons]
    exact
      mul_mem_mul (hg h <| List.mem_cons_self _ _)
        (ih fun i hi => hg i <| List.mem_cons_of_mem _ hi)
#align set.list_prod_mem_list_prod Set.list_prod_mem_list_prod
#align set.list_sum_mem_list_sum Set.list_sum_mem_list_sum
-/

#print Set.list_prod_subset_list_prod /-
/-- An n-ary version of `set.mul_subset_mul`. -/
@[to_additive " An n-ary version of `set.add_subset_add`. "]
theorem list_prod_subset_list_prod (t : List ι) (f₁ f₂ : ι → Set α) (hf : ∀ i ∈ t, f₁ i ⊆ f₂ i) :
    (t.map f₁).Prod ⊆ (t.map f₂).Prod :=
  by
  induction' t with h tl ih
  · rfl
  · simp_rw [List.map_cons, List.prod_cons]
    exact
      mul_subset_mul (hf h <| List.mem_cons_self _ _)
        (ih fun i hi => hf i <| List.mem_cons_of_mem _ hi)
#align set.list_prod_subset_list_prod Set.list_prod_subset_list_prod
#align set.list_sum_subset_list_sum Set.list_sum_subset_list_sum
-/

#print Set.list_prod_singleton /-
@[to_additive]
theorem list_prod_singleton {M : Type _} [CommMonoid M] (s : List M) :
    (s.map fun i => ({i} : Set M)).Prod = {s.Prod} :=
  (map_list_prod (singletonMonoidHom : M →* Set M) _).symm
#align set.list_prod_singleton Set.list_prod_singleton
#align set.list_sum_singleton Set.list_sum_singleton
-/

#print Set.multiset_prod_mem_multiset_prod /-
/-- An n-ary version of `set.mul_mem_mul`. -/
@[to_additive " An n-ary version of `set.add_mem_add`. "]
theorem multiset_prod_mem_multiset_prod (t : Multiset ι) (f : ι → Set α) (g : ι → α)
    (hg : ∀ i ∈ t, g i ∈ f i) : (t.map g).Prod ∈ (t.map f).Prod :=
  by
  induction t using Quotient.inductionOn
  simp_rw [Multiset.quot_mk_to_coe, Multiset.coe_map, Multiset.coe_prod]
  exact list_prod_mem_list_prod _ _ _ hg
#align set.multiset_prod_mem_multiset_prod Set.multiset_prod_mem_multiset_prod
#align set.multiset_sum_mem_multiset_sum Set.multiset_sum_mem_multiset_sum
-/

#print Set.multiset_prod_subset_multiset_prod /-
/-- An n-ary version of `set.mul_subset_mul`. -/
@[to_additive " An n-ary version of `set.add_subset_add`. "]
theorem multiset_prod_subset_multiset_prod (t : Multiset ι) (f₁ f₂ : ι → Set α)
    (hf : ∀ i ∈ t, f₁ i ⊆ f₂ i) : (t.map f₁).Prod ⊆ (t.map f₂).Prod :=
  by
  induction t using Quotient.inductionOn
  simp_rw [Multiset.quot_mk_to_coe, Multiset.coe_map, Multiset.coe_prod]
  exact list_prod_subset_list_prod _ _ _ hf
#align set.multiset_prod_subset_multiset_prod Set.multiset_prod_subset_multiset_prod
#align set.multiset_sum_subset_multiset_sum Set.multiset_sum_subset_multiset_sum
-/

#print Set.multiset_prod_singleton /-
@[to_additive]
theorem multiset_prod_singleton {M : Type _} [CommMonoid M] (s : Multiset M) :
    (s.map fun i => ({i} : Set M)).Prod = {s.Prod} :=
  (map_multiset_prod (singletonMonoidHom : M →* Set M) _).symm
#align set.multiset_prod_singleton Set.multiset_prod_singleton
#align set.multiset_sum_singleton Set.multiset_sum_singleton
-/

#print Set.finset_prod_mem_finset_prod /-
/-- An n-ary version of `set.mul_mem_mul`. -/
@[to_additive " An n-ary version of `set.add_mem_add`. "]
theorem finset_prod_mem_finset_prod (t : Finset ι) (f : ι → Set α) (g : ι → α)
    (hg : ∀ i ∈ t, g i ∈ f i) : ∏ i in t, g i ∈ ∏ i in t, f i :=
  multiset_prod_mem_multiset_prod _ _ _ hg
#align set.finset_prod_mem_finset_prod Set.finset_prod_mem_finset_prod
#align set.finset_sum_mem_finset_sum Set.finset_sum_mem_finset_sum
-/

#print Set.finset_prod_subset_finset_prod /-
/-- An n-ary version of `set.mul_subset_mul`. -/
@[to_additive " An n-ary version of `set.add_subset_add`. "]
theorem finset_prod_subset_finset_prod (t : Finset ι) (f₁ f₂ : ι → Set α)
    (hf : ∀ i ∈ t, f₁ i ⊆ f₂ i) : ∏ i in t, f₁ i ⊆ ∏ i in t, f₂ i :=
  multiset_prod_subset_multiset_prod _ _ _ hf
#align set.finset_prod_subset_finset_prod Set.finset_prod_subset_finset_prod
#align set.finset_sum_subset_finset_sum Set.finset_sum_subset_finset_sum
-/

#print Set.finset_prod_singleton /-
@[to_additive]
theorem finset_prod_singleton {M ι : Type _} [CommMonoid M] (s : Finset ι) (I : ι → M) :
    ∏ i : ι in s, ({I i} : Set M) = {∏ i : ι in s, I i} :=
  (map_prod (singletonMonoidHom : M →* Set M) _ _).symm
#align set.finset_prod_singleton Set.finset_prod_singleton
#align set.finset_sum_singleton Set.finset_sum_singleton
-/

#print Set.image_finset_prod_pi /-
/-- The n-ary version of `set.image_mul_prod`. -/
@[to_additive "The n-ary version of `set.add_image_prod`. "]
theorem image_finset_prod_pi (l : Finset ι) (S : ι → Set α) :
    (fun f : ι → α => ∏ i in l, f i) '' (l : Set ι).pi S = ∏ i in l, S i := by ext;
  simp_rw [mem_finset_prod, mem_image, mem_pi, exists_prop, Finset.mem_coe]
#align set.image_finset_prod_pi Set.image_finset_prod_pi
#align set.image_finset_sum_pi Set.image_finset_sum_pi
-/

#print Set.image_fintype_prod_pi /-
/-- A special case of `set.image_finset_prod_pi` for `finset.univ`. -/
@[to_additive "A special case of `set.image_finset_sum_pi` for `finset.univ`. "]
theorem image_fintype_prod_pi [Fintype ι] (S : ι → Set α) :
    (fun f : ι → α => ∏ i, f i) '' univ.pi S = ∏ i, S i := by
  simpa only [Finset.coe_univ] using image_finset_prod_pi Finset.univ S
#align set.image_fintype_prod_pi Set.image_fintype_prod_pi
#align set.image_fintype_sum_pi Set.image_fintype_sum_pi
-/

end CommMonoid

/-! TODO: define `decidable_mem_finset_prod` and `decidable_mem_finset_sum`. -/


end Set

