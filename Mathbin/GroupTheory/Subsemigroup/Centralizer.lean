/-
Copyright (c) 2021 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning, Jireh Loreaux

! This file was ported from Lean 3 source module group_theory.subsemigroup.centralizer
! leanprover-community/mathlib commit cc67cd75b4e54191e13c2e8d722289a89e67e4fa
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subsemigroup.Center
import Mathbin.Algebra.GroupWithZero.Units.Lemmas

/-!
# Centralizers of magmas and semigroups

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `set.centralizer`: the centralizer of a subset of a magma
* `subsemigroup.centralizer`: the centralizer of a subset of a semigroup
* `set.add_centralizer`: the centralizer of a subset of an additive magma
* `add_subsemigroup.centralizer`: the centralizer of a subset of an additive semigroup

We provide `monoid.centralizer`, `add_monoid.centralizer`, `subgroup.centralizer`, and
`add_subgroup.centralizer` in other files.
-/


variable {M : Type _} {S T : Set M}

namespace Set

variable (S)

#print Set.centralizer /-
/-- The centralizer of a subset of a magma. -/
@[to_additive add_centralizer " The centralizer of a subset of an additive magma. "]
def centralizer [Mul M] : Set M :=
  {c | ∀ m ∈ S, m * c = c * m}
#align set.centralizer Set.centralizer
#align set.add_centralizer Set.addCentralizer
-/

variable {S}

#print Set.mem_centralizer_iff /-
@[to_additive mem_add_centralizer]
theorem mem_centralizer_iff [Mul M] {c : M} : c ∈ centralizer S ↔ ∀ m ∈ S, m * c = c * m :=
  Iff.rfl
#align set.mem_centralizer_iff Set.mem_centralizer_iff
#align set.mem_add_centralizer Set.mem_addCentralizer
-/

#print Set.decidableMemCentralizer /-
@[to_additive decidable_mem_add_centralizer]
instance decidableMemCentralizer [Mul M] [∀ a : M, Decidable <| ∀ b ∈ S, b * a = a * b] :
    DecidablePred (· ∈ centralizer S) := fun _ => decidable_of_iff' _ mem_centralizer_iff
#align set.decidable_mem_centralizer Set.decidableMemCentralizer
#align set.decidable_mem_add_centralizer Set.decidableMemAddCentralizer
-/

variable (S)

#print Set.one_mem_centralizer /-
@[simp, to_additive zero_mem_add_centralizer]
theorem one_mem_centralizer [MulOneClass M] : (1 : M) ∈ centralizer S := by
  simp [mem_centralizer_iff]
#align set.one_mem_centralizer Set.one_mem_centralizer
#align set.zero_mem_add_centralizer Set.zero_mem_addCentralizer
-/

#print Set.zero_mem_centralizer /-
@[simp]
theorem zero_mem_centralizer [MulZeroClass M] : (0 : M) ∈ centralizer S := by
  simp [mem_centralizer_iff]
#align set.zero_mem_centralizer Set.zero_mem_centralizer
-/

variable {S} {a b : M}

#print Set.mul_mem_centralizer /-
@[simp, to_additive add_mem_add_centralizer]
theorem mul_mem_centralizer [Semigroup M] (ha : a ∈ centralizer S) (hb : b ∈ centralizer S) :
    a * b ∈ centralizer S := fun g hg => by
  rw [mul_assoc, ← hb g hg, ← mul_assoc, ha g hg, mul_assoc]
#align set.mul_mem_centralizer Set.mul_mem_centralizer
#align set.add_mem_add_centralizer Set.add_mem_addCentralizer
-/

#print Set.inv_mem_centralizer /-
@[simp, to_additive neg_mem_add_centralizer]
theorem inv_mem_centralizer [Group M] (ha : a ∈ centralizer S) : a⁻¹ ∈ centralizer S := fun g hg =>
  by rw [mul_inv_eq_iff_eq_mul, mul_assoc, eq_inv_mul_iff_mul_eq, ha g hg]
#align set.inv_mem_centralizer Set.inv_mem_centralizer
#align set.neg_mem_add_centralizer Set.neg_mem_addCentralizer
-/

#print Set.add_mem_centralizer /-
@[simp]
theorem add_mem_centralizer [Distrib M] (ha : a ∈ centralizer S) (hb : b ∈ centralizer S) :
    a + b ∈ centralizer S := fun c hc => by rw [add_mul, mul_add, ha c hc, hb c hc]
#align set.add_mem_centralizer Set.add_mem_centralizer
-/

#print Set.neg_mem_centralizer /-
@[simp]
theorem neg_mem_centralizer [Mul M] [HasDistribNeg M] (ha : a ∈ centralizer S) :
    -a ∈ centralizer S := fun c hc => by rw [mul_neg, ha c hc, neg_mul]
#align set.neg_mem_centralizer Set.neg_mem_centralizer
-/

#print Set.inv_mem_centralizer₀ /-
@[simp]
theorem inv_mem_centralizer₀ [GroupWithZero M] (ha : a ∈ centralizer S) : a⁻¹ ∈ centralizer S :=
  (eq_or_ne a 0).elim (fun h => by rw [h, inv_zero]; exact zero_mem_centralizer S) fun ha0 c hc =>
    by rw [mul_inv_eq_iff_eq_mul₀ ha0, mul_assoc, eq_inv_mul_iff_mul_eq₀ ha0, ha c hc]
#align set.inv_mem_centralizer₀ Set.inv_mem_centralizer₀
-/

#print Set.div_mem_centralizer /-
@[simp, to_additive sub_mem_add_centralizer]
theorem div_mem_centralizer [Group M] (ha : a ∈ centralizer S) (hb : b ∈ centralizer S) :
    a / b ∈ centralizer S := by
  rw [div_eq_mul_inv]
  exact mul_mem_centralizer ha (inv_mem_centralizer hb)
#align set.div_mem_centralizer Set.div_mem_centralizer
#align set.sub_mem_add_centralizer Set.sub_mem_addCentralizer
-/

#print Set.div_mem_centralizer₀ /-
@[simp]
theorem div_mem_centralizer₀ [GroupWithZero M] (ha : a ∈ centralizer S) (hb : b ∈ centralizer S) :
    a / b ∈ centralizer S := by
  rw [div_eq_mul_inv]
  exact mul_mem_centralizer ha (inv_mem_centralizer₀ hb)
#align set.div_mem_centralizer₀ Set.div_mem_centralizer₀
-/

#print Set.centralizer_subset /-
@[to_additive add_centralizer_subset]
theorem centralizer_subset [Mul M] (h : S ⊆ T) : centralizer T ⊆ centralizer S := fun t ht s hs =>
  ht s (h hs)
#align set.centralizer_subset Set.centralizer_subset
#align set.add_centralizer_subset Set.addCentralizer_subset
-/

#print Set.center_subset_centralizer /-
@[to_additive add_center_subset_add_centralizer]
theorem center_subset_centralizer [Mul M] (S : Set M) : Set.center M ⊆ S.centralizer :=
  fun x hx m _ => hx m
#align set.center_subset_centralizer Set.center_subset_centralizer
#align set.add_center_subset_add_centralizer Set.addCenter_subset_addCentralizer
-/

#print Set.centralizer_eq_top_iff_subset /-
@[simp, to_additive add_centralizer_eq_top_iff_subset]
theorem centralizer_eq_top_iff_subset {s : Set M} [Mul M] :
    centralizer s = Set.univ ↔ s ⊆ center M :=
  eq_top_iff.trans <| ⟨fun h x hx g => (h trivial _ hx).symm, fun h x _ m hm => (h hm x).symm⟩
#align set.centralizer_eq_top_iff_subset Set.centralizer_eq_top_iff_subset
#align set.add_centralizer_eq_top_iff_subset Set.addCentralizer_eq_top_iff_subset
-/

variable (M)

#print Set.centralizer_univ /-
@[simp, to_additive add_centralizer_univ]
theorem centralizer_univ [Mul M] : centralizer univ = center M :=
  Subset.antisymm (fun a ha b => ha b (Set.mem_univ b)) fun a ha b hb => ha b
#align set.centralizer_univ Set.centralizer_univ
#align set.add_centralizer_univ Set.addCentralizer_univ
-/

variable {M} (S)

#print Set.centralizer_eq_univ /-
@[simp, to_additive add_centralizer_eq_univ]
theorem centralizer_eq_univ [CommSemigroup M] : centralizer S = univ :=
  Subset.antisymm (subset_univ _) fun x hx y hy => mul_comm y x
#align set.centralizer_eq_univ Set.centralizer_eq_univ
#align set.add_centralizer_eq_univ Set.addCentralizer_eq_univ
-/

end Set

namespace Subsemigroup

section

variable {M} [Semigroup M] (S)

#print Subsemigroup.centralizer /-
/-- The centralizer of a subset of a semigroup `M`. -/
@[to_additive "The centralizer of a subset of an additive semigroup."]
def centralizer : Subsemigroup M where
  carrier := S.centralizer
  mul_mem' a b := Set.mul_mem_centralizer
#align subsemigroup.centralizer Subsemigroup.centralizer
#align add_subsemigroup.centralizer AddSubsemigroup.centralizer
-/

#print Subsemigroup.coe_centralizer /-
@[simp, norm_cast, to_additive]
theorem coe_centralizer : ↑(centralizer S) = S.centralizer :=
  rfl
#align subsemigroup.coe_centralizer Subsemigroup.coe_centralizer
#align add_subsemigroup.coe_centralizer AddSubsemigroup.coe_centralizer
-/

variable {S}

#print Subsemigroup.mem_centralizer_iff /-
@[to_additive]
theorem mem_centralizer_iff {z : M} : z ∈ centralizer S ↔ ∀ g ∈ S, g * z = z * g :=
  Iff.rfl
#align subsemigroup.mem_centralizer_iff Subsemigroup.mem_centralizer_iff
#align add_subsemigroup.mem_centralizer_iff AddSubsemigroup.mem_centralizer_iff
-/

#print Subsemigroup.decidableMemCentralizer /-
@[to_additive]
instance decidableMemCentralizer (a) [Decidable <| ∀ b ∈ S, b * a = a * b] :
    Decidable (a ∈ centralizer S) :=
  decidable_of_iff' _ mem_centralizer_iff
#align subsemigroup.decidable_mem_centralizer Subsemigroup.decidableMemCentralizer
#align add_subsemigroup.decidable_mem_centralizer AddSubsemigroup.decidableMemCentralizer
-/

#print Subsemigroup.center_le_centralizer /-
@[to_additive]
theorem center_le_centralizer (S) : center M ≤ centralizer S :=
  S.center_subset_centralizer
#align subsemigroup.center_le_centralizer Subsemigroup.center_le_centralizer
#align add_subsemigroup.center_le_centralizer AddSubsemigroup.center_le_centralizer
-/

#print Subsemigroup.centralizer_le /-
@[to_additive]
theorem centralizer_le (h : S ⊆ T) : centralizer T ≤ centralizer S :=
  Set.centralizer_subset h
#align subsemigroup.centralizer_le Subsemigroup.centralizer_le
#align add_subsemigroup.centralizer_le AddSubsemigroup.centralizer_le
-/

#print Subsemigroup.centralizer_eq_top_iff_subset /-
@[simp, to_additive]
theorem centralizer_eq_top_iff_subset {s : Set M} : centralizer s = ⊤ ↔ s ⊆ center M :=
  SetLike.ext'_iff.trans Set.centralizer_eq_top_iff_subset
#align subsemigroup.centralizer_eq_top_iff_subset Subsemigroup.centralizer_eq_top_iff_subset
#align add_subsemigroup.centralizer_eq_top_iff_subset AddSubsemigroup.centralizer_eq_top_iff_subset
-/

variable (M)

#print Subsemigroup.centralizer_univ /-
@[simp, to_additive]
theorem centralizer_univ : centralizer Set.univ = center M :=
  SetLike.ext' (Set.centralizer_univ M)
#align subsemigroup.centralizer_univ Subsemigroup.centralizer_univ
#align add_subsemigroup.centralizer_univ AddSubsemigroup.centralizer_univ
-/

end

end Subsemigroup

-- Guard against import creep
assert_not_exists Finset

