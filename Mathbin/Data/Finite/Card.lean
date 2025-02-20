/-
Copyright (c) 2022 Kyle Miller. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kyle Miller

! This file was ported from Lean 3 source module data.finite.card
! leanprover-community/mathlib commit 3ff3f2d6a3118b8711063de7111a0d77a53219a8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.SetTheory.Cardinal.Finite

/-!

# Cardinality of finite types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The cardinality of a finite type `α` is given by `nat.card α`. This function has
the "junk value" of `0` for infinite types, but to ensure the function has valid
output, one just needs to know that it's possible to produce a `finite` instance
for the type. (Note: we could have defined a `finite.card` that required you to
supply a `finite` instance, but (a) the function would be `noncomputable` anyway
so there is no need to supply the instance and (b) the function would have a more
complicated dependent type that easily leads to "motive not type correct" errors.)

## Implementation notes

Theorems about `nat.card` are sometimes incidentally true for both finite and infinite
types. If removing a finiteness constraint results in no loss in legibility, we remove
it. We generally put such theorems into the `set_theory.cardinal.finite` module.

-/


noncomputable section

open scoped Classical

variable {α β γ : Type _}

#print Finite.equivFin /-
/-- There is (noncomputably) an equivalence between a finite type `α` and `fin (nat.card α)`. -/
def Finite.equivFin (α : Type _) [Finite α] : α ≃ Fin (Nat.card α) :=
  by
  have := (Finite.exists_equiv_fin α).choose_spec.some
  rwa [Nat.card_eq_of_equiv_fin this]
#align finite.equiv_fin Finite.equivFin
-/

#print Finite.equivFinOfCardEq /-
/-- Similar to `finite.equiv_fin` but with control over the term used for the cardinality. -/
def Finite.equivFinOfCardEq [Finite α] {n : ℕ} (h : Nat.card α = n) : α ≃ Fin n := by subst h;
  apply Finite.equivFin
#align finite.equiv_fin_of_card_eq Finite.equivFinOfCardEq
-/

#print Nat.card_eq /-
theorem Nat.card_eq (α : Type _) :
    Nat.card α = if h : Finite α then @Fintype.card α (Fintype.ofFinite α) else 0 :=
  by
  cases finite_or_infinite α
  · letI := Fintype.ofFinite α
    simp only [*, Nat.card_eq_fintype_card, dif_pos]
  · simp [*, not_finite_iff_infinite.mpr h]
#align nat.card_eq Nat.card_eq
-/

#print Finite.card_pos_iff /-
theorem Finite.card_pos_iff [Finite α] : 0 < Nat.card α ↔ Nonempty α :=
  by
  haveI := Fintype.ofFinite α
  rw [Nat.card_eq_fintype_card, Fintype.card_pos_iff]
#align finite.card_pos_iff Finite.card_pos_iff
-/

#print Finite.card_pos /-
theorem Finite.card_pos [Finite α] [h : Nonempty α] : 0 < Nat.card α :=
  Finite.card_pos_iff.mpr h
#align finite.card_pos Finite.card_pos
-/

namespace Finite

#print Finite.cast_card_eq_mk /-
theorem cast_card_eq_mk {α : Type _} [Finite α] : ↑(Nat.card α) = Cardinal.mk α :=
  Cardinal.cast_toNat_of_lt_aleph0 (Cardinal.lt_aleph0_of_finite α)
#align finite.cast_card_eq_mk Finite.cast_card_eq_mk
-/

#print Finite.card_eq /-
theorem card_eq [Finite α] [Finite β] : Nat.card α = Nat.card β ↔ Nonempty (α ≃ β) := by
  haveI := Fintype.ofFinite α; haveI := Fintype.ofFinite β; simp [Fintype.card_eq]
#align finite.card_eq Finite.card_eq
-/

#print Finite.card_le_one_iff_subsingleton /-
theorem card_le_one_iff_subsingleton [Finite α] : Nat.card α ≤ 1 ↔ Subsingleton α := by
  haveI := Fintype.ofFinite α; simp [Fintype.card_le_one_iff_subsingleton]
#align finite.card_le_one_iff_subsingleton Finite.card_le_one_iff_subsingleton
-/

#print Finite.one_lt_card_iff_nontrivial /-
theorem one_lt_card_iff_nontrivial [Finite α] : 1 < Nat.card α ↔ Nontrivial α := by
  haveI := Fintype.ofFinite α; simp [Fintype.one_lt_card_iff_nontrivial]
#align finite.one_lt_card_iff_nontrivial Finite.one_lt_card_iff_nontrivial
-/

#print Finite.one_lt_card /-
theorem one_lt_card [Finite α] [h : Nontrivial α] : 1 < Nat.card α :=
  one_lt_card_iff_nontrivial.mpr h
#align finite.one_lt_card Finite.one_lt_card
-/

#print Finite.card_option /-
@[simp]
theorem card_option [Finite α] : Nat.card (Option α) = Nat.card α + 1 := by
  haveI := Fintype.ofFinite α; simp
#align finite.card_option Finite.card_option
-/

#print Finite.card_le_of_injective /-
theorem card_le_of_injective [Finite β] (f : α → β) (hf : Function.Injective f) :
    Nat.card α ≤ Nat.card β := by
  haveI := Fintype.ofFinite β; haveI := Fintype.ofInjective f hf
  simpa using Fintype.card_le_of_injective f hf
#align finite.card_le_of_injective Finite.card_le_of_injective
-/

#print Finite.card_le_of_embedding /-
theorem card_le_of_embedding [Finite β] (f : α ↪ β) : Nat.card α ≤ Nat.card β :=
  card_le_of_injective _ f.Injective
#align finite.card_le_of_embedding Finite.card_le_of_embedding
-/

#print Finite.card_le_of_surjective /-
theorem card_le_of_surjective [Finite α] (f : α → β) (hf : Function.Surjective f) :
    Nat.card β ≤ Nat.card α := by
  haveI := Fintype.ofFinite α; haveI := Fintype.ofSurjective f hf
  simpa using Fintype.card_le_of_surjective f hf
#align finite.card_le_of_surjective Finite.card_le_of_surjective
-/

#print Finite.card_eq_zero_iff /-
theorem card_eq_zero_iff [Finite α] : Nat.card α = 0 ↔ IsEmpty α := by haveI := Fintype.ofFinite α;
  simp [Fintype.card_eq_zero_iff]
#align finite.card_eq_zero_iff Finite.card_eq_zero_iff
-/

#print Finite.card_le_of_injective' /-
/-- If `f` is injective, then `nat.card α ≤ nat.card β`. We must also assume
  `nat.card β = 0 → nat.card α = 0` since `nat.card` is defined to be `0` for infinite types. -/
theorem card_le_of_injective' {f : α → β} (hf : Function.Injective f)
    (h : Nat.card β = 0 → Nat.card α = 0) : Nat.card α ≤ Nat.card β :=
  (or_not_of_imp h).casesOn (fun h => le_of_eq_of_le h zero_le') fun h =>
    @card_le_of_injective α β (Nat.finite_of_card_ne_zero h) f hf
#align finite.card_le_of_injective' Finite.card_le_of_injective'
-/

#print Finite.card_le_of_embedding' /-
/-- If `f` is an embedding, then `nat.card α ≤ nat.card β`. We must also assume
  `nat.card β = 0 → nat.card α = 0` since `nat.card` is defined to be `0` for infinite types. -/
theorem card_le_of_embedding' (f : α ↪ β) (h : Nat.card β = 0 → Nat.card α = 0) :
    Nat.card α ≤ Nat.card β :=
  card_le_of_injective' f.2 h
#align finite.card_le_of_embedding' Finite.card_le_of_embedding'
-/

#print Finite.card_le_of_surjective' /-
/-- If `f` is surjective, then `nat.card β ≤ nat.card α`. We must also assume
  `nat.card α = 0 → nat.card β = 0` since `nat.card` is defined to be `0` for infinite types. -/
theorem card_le_of_surjective' {f : α → β} (hf : Function.Surjective f)
    (h : Nat.card α = 0 → Nat.card β = 0) : Nat.card β ≤ Nat.card α :=
  (or_not_of_imp h).casesOn (fun h => le_of_eq_of_le h zero_le') fun h =>
    @card_le_of_surjective α β (Nat.finite_of_card_ne_zero h) f hf
#align finite.card_le_of_surjective' Finite.card_le_of_surjective'
-/

#print Finite.card_eq_zero_of_surjective /-
/-- NB: `nat.card` is defined to be `0` for infinite types. -/
theorem card_eq_zero_of_surjective {f : α → β} (hf : Function.Surjective f) (h : Nat.card β = 0) :
    Nat.card α = 0 := by
  cases finite_or_infinite β
  · haveI := card_eq_zero_iff.mp h
    haveI := Function.isEmpty f
    exact Nat.card_of_isEmpty
  · haveI := Infinite.of_surjective f hf
    exact Nat.card_eq_zero_of_infinite
#align finite.card_eq_zero_of_surjective Finite.card_eq_zero_of_surjective
-/

#print Finite.card_eq_zero_of_injective /-
/-- NB: `nat.card` is defined to be `0` for infinite types. -/
theorem card_eq_zero_of_injective [Nonempty α] {f : α → β} (hf : Function.Injective f)
    (h : Nat.card α = 0) : Nat.card β = 0 :=
  card_eq_zero_of_surjective (Function.invFun_surjective hf) h
#align finite.card_eq_zero_of_injective Finite.card_eq_zero_of_injective
-/

#print Finite.card_eq_zero_of_embedding /-
/-- NB: `nat.card` is defined to be `0` for infinite types. -/
theorem card_eq_zero_of_embedding [Nonempty α] (f : α ↪ β) (h : Nat.card α = 0) : Nat.card β = 0 :=
  card_eq_zero_of_injective f.2 h
#align finite.card_eq_zero_of_embedding Finite.card_eq_zero_of_embedding
-/

#print Finite.card_sum /-
theorem card_sum [Finite α] [Finite β] : Nat.card (Sum α β) = Nat.card α + Nat.card β := by
  haveI := Fintype.ofFinite α; haveI := Fintype.ofFinite β; simp
#align finite.card_sum Finite.card_sum
-/

#print Finite.card_image_le /-
theorem card_image_le {s : Set α} [Finite s] (f : α → β) : Nat.card (f '' s) ≤ Nat.card s :=
  card_le_of_surjective _ Set.surjective_onto_image
#align finite.card_image_le Finite.card_image_le
-/

#print Finite.card_range_le /-
theorem card_range_le [Finite α] (f : α → β) : Nat.card (Set.range f) ≤ Nat.card α :=
  card_le_of_surjective _ Set.surjective_onto_range
#align finite.card_range_le Finite.card_range_le
-/

#print Finite.card_subtype_le /-
theorem card_subtype_le [Finite α] (p : α → Prop) : Nat.card { x // p x } ≤ Nat.card α := by
  haveI := Fintype.ofFinite α; simpa using Fintype.card_subtype_le p
#align finite.card_subtype_le Finite.card_subtype_le
-/

#print Finite.card_subtype_lt /-
theorem card_subtype_lt [Finite α] {p : α → Prop} {x : α} (hx : ¬p x) :
    Nat.card { x // p x } < Nat.card α := by haveI := Fintype.ofFinite α;
  simpa using Fintype.card_subtype_lt hx
#align finite.card_subtype_lt Finite.card_subtype_lt
-/

end Finite

namespace PartENat

/- warning: part_enat.card_eq_coe_nat_card clashes with part_enat.card_of_finite -> PartENat.card_eq_coe_nat_card
Case conversion may be inaccurate. Consider using '#align part_enat.card_eq_coe_nat_card PartENat.card_eq_coe_nat_cardₓ'. -/
#print PartENat.card_eq_coe_nat_card /-
theorem card_eq_coe_nat_card (α : Type _) [Finite α] : card α = Nat.card α :=
  by
  unfold PartENat.card
  apply symm
  rw [Cardinal.natCast_eq_toPartENat_iff]
  exact Finite.cast_card_eq_mk
#align part_enat.card_eq_coe_nat_card PartENat.card_eq_coe_nat_card
-/

end PartENat

namespace Set

#print Set.card_union_le /-
theorem card_union_le (s t : Set α) : Nat.card ↥(s ∪ t) ≤ Nat.card s + Nat.card t :=
  by
  cases' _root_.finite_or_infinite ↥(s ∪ t) with h h
  · rw [finite_coe_iff, finite_union, ← finite_coe_iff, ← finite_coe_iff] at h 
    cases h
    rw [← Cardinal.natCast_le, Nat.cast_add, Finite.cast_card_eq_mk, Finite.cast_card_eq_mk,
      Finite.cast_card_eq_mk]
    exact Cardinal.mk_union_le s t
  · exact nat.card_eq_zero_of_infinite.trans_le (zero_le _)
#align set.card_union_le Set.card_union_le
-/

end Set

