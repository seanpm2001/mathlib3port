/-
Copyright (c) 2022 Alex J. Best. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alex J. Best, Yaël Dillies

! This file was ported from Lean 3 source module algebra.order.complete_field
! leanprover-community/mathlib commit 6b31d1eebd64eab86d5bd9936bfaada6ca8b5842
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.Hom.Ring
import Mathbin.Algebra.Order.Pointwise
import Mathbin.Analysis.SpecialFunctions.Pow.Real

/-!
# Conditionally complete linear ordered fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file shows that the reals are unique, or, more formally, given a type satisfying the common
axioms of the reals (field, conditionally complete, linearly ordered) that there is an isomorphism
preserving these properties to the reals. This is `rat.induced_order_ring_iso`. Moreover this
isomorphism is unique.

We introduce definitions of conditionally complete linear ordered fields, and show all such are
archimedean. We also construct the natural map from a `linear_ordered_field` to such a field.

## Main definitions

* `conditionally_complete_linear_ordered_field`: A field satisfying the standard axiomatization of
  the real numbers, being a Dedekind complete and linear ordered field.
* `linear_ordered_field.induced_map`: A (unique) map from any archimedean linear ordered field to a
  conditionally complete linear ordered field. Various bundlings are available.

## Main results

* `unique.order_ring_hom` : Uniqueness of `order_ring_hom`s from an archimedean linear ordered field
  to a conditionally complete linear ordered field.
* `unique.order_ring_iso` : Uniqueness of `order_ring_iso`s between two
  conditionally complete linearly ordered fields.

## References

* https://mathoverflow.net/questions/362991/
  who-first-characterized-the-real-numbers-as-the-unique-complete-ordered-field

## Tags

reals, conditionally complete, ordered field, uniqueness
-/


variable {F α β γ : Type _}

noncomputable section

open Function Rat Real Set

open scoped Classical Pointwise

#print ConditionallyCompleteLinearOrderedField /-
/- ./././Mathport/Syntax/Translate/Command.lean:422:11: unsupported: advanced extends in structure -/
/-- A field which is both linearly ordered and conditionally complete with respect to the order.
This axiomatizes the reals. -/
@[protect_proj]
class ConditionallyCompleteLinearOrderedField (α : Type _) extends
    "./././Mathport/Syntax/Translate/Command.lean:422:11: unsupported: advanced extends in structure",
    ConditionallyCompleteLinearOrder α
#align conditionally_complete_linear_ordered_field ConditionallyCompleteLinearOrderedField
-/

#print ConditionallyCompleteLinearOrderedField.to_archimedean /-
-- see Note [lower instance priority]
/-- Any conditionally complete linearly ordered field is archimedean. -/
instance (priority := 100) ConditionallyCompleteLinearOrderedField.to_archimedean
    [ConditionallyCompleteLinearOrderedField α] : Archimedean α :=
  archimedean_iff_nat_lt.2
    (by
      by_contra' h
      obtain ⟨x, h⟩ := h
      have :=
        csSup_le (range_nonempty (coe : ℕ → α))
          (forall_range_iff.2 fun n =>
            le_sub_iff_add_le.2 <| le_csSup ⟨x, forall_range_iff.2 h⟩ ⟨n + 1, Nat.cast_succ n⟩)
      linarith)
#align conditionally_complete_linear_ordered_field.to_archimedean ConditionallyCompleteLinearOrderedField.to_archimedean
-/

/-- The reals are a conditionally complete linearly ordered field. -/
instance : ConditionallyCompleteLinearOrderedField ℝ :=
  { Real.linearOrderedField, Real.conditionallyCompleteLinearOrder with }

namespace LinearOrderedField

/-!
### Rational cut map

The idea is that a conditionally complete linear ordered field is fully characterized by its copy of
the rationals. Hence we define `rat.cut_map β : α → set β` which sends `a : α` to the "rationals in
`β`" that are less than `a`.
-/


section CutMap

variable [LinearOrderedField α]

section DivisionRing

variable (β) [DivisionRing β] {a a₁ a₂ : α} {b : β} {q : ℚ}

#print LinearOrderedField.cutMap /-
/-- The lower cut of rationals inside a linear ordered field that are less than a given element of
another linear ordered field. -/
def cutMap (a : α) : Set β :=
  (coe : ℚ → β) '' {t | ↑t < a}
#align linear_ordered_field.cut_map LinearOrderedField.cutMap
-/

#print LinearOrderedField.cutMap_mono /-
theorem cutMap_mono (h : a₁ ≤ a₂) : cutMap β a₁ ⊆ cutMap β a₂ :=
  image_subset _ fun _ => h.trans_lt'
#align linear_ordered_field.cut_map_mono LinearOrderedField.cutMap_mono
-/

variable {β}

#print LinearOrderedField.mem_cutMap_iff /-
@[simp]
theorem mem_cutMap_iff : b ∈ cutMap β a ↔ ∃ q : ℚ, (q : α) < a ∧ (q : β) = b :=
  Iff.rfl
#align linear_ordered_field.mem_cut_map_iff LinearOrderedField.mem_cutMap_iff
-/

#print LinearOrderedField.coe_mem_cutMap_iff /-
@[simp]
theorem coe_mem_cutMap_iff [CharZero β] : (q : β) ∈ cutMap β a ↔ (q : α) < a :=
  Rat.cast_injective.mem_set_image
#align linear_ordered_field.coe_mem_cut_map_iff LinearOrderedField.coe_mem_cutMap_iff
-/

#print LinearOrderedField.cutMap_self /-
theorem cutMap_self (a : α) : cutMap α a = Iio a ∩ range (coe : ℚ → α) :=
  by
  ext
  constructor
  · rintro ⟨q, h, rfl⟩
    exact ⟨h, q, rfl⟩
  · rintro ⟨h, q, rfl⟩
    exact ⟨q, h, rfl⟩
#align linear_ordered_field.cut_map_self LinearOrderedField.cutMap_self
-/

end DivisionRing

variable (β) [LinearOrderedField β] {a a₁ a₂ : α} {b : β} {q : ℚ}

#print LinearOrderedField.cutMap_coe /-
theorem cutMap_coe (q : ℚ) : cutMap β (q : α) = coe '' {r : ℚ | (r : β) < q} := by
  simp_rw [cut_map, Rat.cast_lt]
#align linear_ordered_field.cut_map_coe LinearOrderedField.cutMap_coe
-/

variable [Archimedean α]

#print LinearOrderedField.cutMap_nonempty /-
theorem cutMap_nonempty (a : α) : (cutMap β a).Nonempty :=
  Nonempty.image _ <| exists_rat_lt a
#align linear_ordered_field.cut_map_nonempty LinearOrderedField.cutMap_nonempty
-/

#print LinearOrderedField.cutMap_bddAbove /-
theorem cutMap_bddAbove (a : α) : BddAbove (cutMap β a) :=
  by
  obtain ⟨q, hq⟩ := exists_rat_gt a
  exact ⟨q, ball_image_iff.2 fun r hr => by exact_mod_cast (hq.trans' hr).le⟩
#align linear_ordered_field.cut_map_bdd_above LinearOrderedField.cutMap_bddAbove
-/

#print LinearOrderedField.cutMap_add /-
theorem cutMap_add (a b : α) : cutMap β (a + b) = cutMap β a + cutMap β b :=
  by
  refine' (image_subset_iff.2 fun q hq => _).antisymm _
  · rw [mem_set_of_eq, ← sub_lt_iff_lt_add] at hq 
    obtain ⟨q₁, hq₁q, hq₁ab⟩ := exists_rat_btwn hq
    refine' ⟨q₁, q - q₁, _, _, add_sub_cancel'_right _ _⟩ <;> try norm_cast <;>
      rwa [coe_mem_cut_map_iff]
    exact_mod_cast sub_lt_comm.mp hq₁q
  · rintro _ ⟨_, _, ⟨qa, ha, rfl⟩, ⟨qb, hb, rfl⟩, rfl⟩
    refine' ⟨qa + qb, _, by norm_cast⟩
    rw [mem_set_of_eq, cast_add]
    exact add_lt_add ha hb
#align linear_ordered_field.cut_map_add LinearOrderedField.cutMap_add
-/

end CutMap

/-!
### Induced map

`rat.cut_map` spits out a `set β`. To get something in `β`, we now take the supremum.
-/


section InducedMap

variable (α β γ) [LinearOrderedField α] [ConditionallyCompleteLinearOrderedField β]
  [ConditionallyCompleteLinearOrderedField γ]

#print LinearOrderedField.inducedMap /-
/-- The induced order preserving function from a linear ordered field to a conditionally complete
linear ordered field, defined by taking the Sup in the codomain of all the rationals less than the
input. -/
def inducedMap (x : α) : β :=
  sSup <| cutMap β x
#align linear_ordered_field.induced_map LinearOrderedField.inducedMap
-/

variable [Archimedean α]

#print LinearOrderedField.inducedMap_mono /-
theorem inducedMap_mono : Monotone (inducedMap α β) := fun a b h =>
  csSup_le_csSup (cutMap_bddAbove β _) (cutMap_nonempty β _) (cutMap_mono β h)
#align linear_ordered_field.induced_map_mono LinearOrderedField.inducedMap_mono
-/

#print LinearOrderedField.inducedMap_rat /-
theorem inducedMap_rat (q : ℚ) : inducedMap α β (q : α) = q :=
  by
  refine'
    csSup_eq_of_forall_le_of_forall_lt_exists_gt (cut_map_nonempty β q) (fun x h => _) fun w h => _
  · rw [cut_map_coe] at h 
    obtain ⟨r, h, rfl⟩ := h
    exact le_of_lt h
  · obtain ⟨q', hwq, hq⟩ := exists_rat_btwn h
    rw [cut_map_coe]
    exact ⟨q', ⟨_, hq, rfl⟩, hwq⟩
#align linear_ordered_field.induced_map_rat LinearOrderedField.inducedMap_rat
-/

#print LinearOrderedField.inducedMap_zero /-
@[simp]
theorem inducedMap_zero : inducedMap α β 0 = 0 := by exact_mod_cast induced_map_rat α β 0
#align linear_ordered_field.induced_map_zero LinearOrderedField.inducedMap_zero
-/

#print LinearOrderedField.inducedMap_one /-
@[simp]
theorem inducedMap_one : inducedMap α β 1 = 1 := by exact_mod_cast induced_map_rat α β 1
#align linear_ordered_field.induced_map_one LinearOrderedField.inducedMap_one
-/

variable {α β} {a : α} {b : β} {q : ℚ}

#print LinearOrderedField.inducedMap_nonneg /-
theorem inducedMap_nonneg (ha : 0 ≤ a) : 0 ≤ inducedMap α β a :=
  (inducedMap_zero α _).ge.trans <| inducedMap_mono _ _ ha
#align linear_ordered_field.induced_map_nonneg LinearOrderedField.inducedMap_nonneg
-/

#print LinearOrderedField.coe_lt_inducedMap_iff /-
theorem coe_lt_inducedMap_iff : (q : β) < inducedMap α β a ↔ (q : α) < a :=
  by
  refine' ⟨fun h => _, fun hq => _⟩
  · rw [← induced_map_rat α] at h 
    exact (induced_map_mono α β).reflect_lt h
  · obtain ⟨q', hq, hqa⟩ := exists_rat_btwn hq
    apply lt_csSup_of_lt (cut_map_bdd_above β a) (coe_mem_cut_map_iff.mpr hqa)
    exact_mod_cast hq
#align linear_ordered_field.coe_lt_induced_map_iff LinearOrderedField.coe_lt_inducedMap_iff
-/

#print LinearOrderedField.lt_inducedMap_iff /-
theorem lt_inducedMap_iff : b < inducedMap α β a ↔ ∃ q : ℚ, b < q ∧ (q : α) < a :=
  ⟨fun h => (exists_rat_btwn h).imp fun q => And.imp_right coe_lt_inducedMap_iff.1,
    fun ⟨q, hbq, hqa⟩ => hbq.trans <| by rwa [coe_lt_induced_map_iff]⟩
#align linear_ordered_field.lt_induced_map_iff LinearOrderedField.lt_inducedMap_iff
-/

#print LinearOrderedField.inducedMap_self /-
@[simp]
theorem inducedMap_self (b : β) : inducedMap β β b = b :=
  eq_of_forall_rat_lt_iff_lt fun q => coe_lt_inducedMap_iff
#align linear_ordered_field.induced_map_self LinearOrderedField.inducedMap_self
-/

variable (α β)

#print LinearOrderedField.inducedMap_inducedMap /-
@[simp]
theorem inducedMap_inducedMap (a : α) : inducedMap β γ (inducedMap α β a) = inducedMap α γ a :=
  eq_of_forall_rat_lt_iff_lt fun q => by
    rw [coe_lt_induced_map_iff, coe_lt_induced_map_iff, Iff.comm, coe_lt_induced_map_iff]
#align linear_ordered_field.induced_map_induced_map LinearOrderedField.inducedMap_inducedMap
-/

#print LinearOrderedField.inducedMap_inv_self /-
@[simp]
theorem inducedMap_inv_self (b : β) : inducedMap γ β (inducedMap β γ b) = b := by
  rw [induced_map_induced_map, induced_map_self]
#align linear_ordered_field.induced_map_inv_self LinearOrderedField.inducedMap_inv_self
-/

#print LinearOrderedField.inducedMap_add /-
theorem inducedMap_add (x y : α) : inducedMap α β (x + y) = inducedMap α β x + inducedMap α β y :=
  by
  rw [induced_map, cut_map_add]
  exact
    csSup_add (cut_map_nonempty β x) (cut_map_bdd_above β x) (cut_map_nonempty β y)
      (cut_map_bdd_above β y)
#align linear_ordered_field.induced_map_add LinearOrderedField.inducedMap_add
-/

variable {α β}

#print LinearOrderedField.le_inducedMap_mul_self_of_mem_cutMap /-
/-- Preparatory lemma for `induced_ring_hom`. -/
theorem le_inducedMap_mul_self_of_mem_cutMap (ha : 0 < a) (b : β) (hb : b ∈ cutMap β (a * a)) :
    b ≤ inducedMap α β a * inducedMap α β a :=
  by
  obtain ⟨q, hb, rfl⟩ := hb
  obtain ⟨q', hq', hqq', hqa⟩ := exists_rat_pow_btwn two_ne_zero hb (mul_self_pos.2 ha.ne')
  trans (q' : β) ^ 2
  exact_mod_cast hqq'.le
  rw [pow_two] at hqa ⊢
  exact
    mul_self_le_mul_self (by exact_mod_cast hq'.le)
      (le_csSup (cut_map_bdd_above β a) <|
        coe_mem_cut_map_iff.2 <| lt_of_mul_self_lt_mul_self ha.le hqa)
#align linear_ordered_field.le_induced_map_mul_self_of_mem_cut_map LinearOrderedField.le_inducedMap_mul_self_of_mem_cutMap
-/

#print LinearOrderedField.exists_mem_cutMap_mul_self_of_lt_inducedMap_mul_self /-
/-- Preparatory lemma for `induced_ring_hom`. -/
theorem exists_mem_cutMap_mul_self_of_lt_inducedMap_mul_self (ha : 0 < a) (b : β)
    (hba : b < inducedMap α β a * inducedMap α β a) : ∃ c ∈ cutMap β (a * a), b < c :=
  by
  obtain hb | hb := lt_or_le b 0
  · refine' ⟨0, _, hb⟩
    rw [← Rat.cast_zero, coe_mem_cut_map_iff, Rat.cast_zero]
    exact mul_self_pos.2 ha.ne'
  obtain ⟨q, hq, hbq, hqa⟩ := exists_rat_pow_btwn two_ne_zero hba (hb.trans_lt hba)
  rw [← cast_pow] at hbq 
  refine' ⟨(q ^ 2 : ℚ), coe_mem_cut_map_iff.2 _, hbq⟩
  rw [pow_two] at hqa ⊢
  push_cast
  obtain ⟨q', hq', hqa'⟩ := lt_induced_map_iff.1 (lt_of_mul_self_lt_mul_self _ hqa)
  exact mul_self_lt_mul_self (by exact_mod_cast hq.le) (hqa'.trans' <| by assumption_mod_cast)
  exact induced_map_nonneg ha.le
#align linear_ordered_field.exists_mem_cut_map_mul_self_of_lt_induced_map_mul_self LinearOrderedField.exists_mem_cutMap_mul_self_of_lt_inducedMap_mul_self
-/

variable (α β)

#print LinearOrderedField.inducedAddHom /-
/-- `induced_map` as an additive homomorphism. -/
def inducedAddHom : α →+ β :=
  ⟨inducedMap α β, inducedMap_zero α β, inducedMap_add α β⟩
#align linear_ordered_field.induced_add_hom LinearOrderedField.inducedAddHom
-/

#print LinearOrderedField.inducedOrderRingHom /-
/-- `induced_map` as an `order_ring_hom`. -/
@[simps]
def inducedOrderRingHom : α →+*o β :=
  {
    (inducedAddHom α β).mkRingHomOfMulSelfOfTwoNeZero
      (-- reduce to the case of x = y
      by
        -- reduce to the case of 0 < x
        suffices
          ∀ x, 0 < x → induced_add_hom α β (x * x) = induced_add_hom α β x * induced_add_hom α β x
          by
          rintro x
          obtain h | rfl | h := lt_trichotomy x 0
          · convert this (-x) (neg_pos.2 h) using 1
            · rw [neg_mul, mul_neg, neg_neg]
            · simp_rw [AddMonoidHom.map_neg, neg_mul, mul_neg, neg_neg]
          · simp only [MulZeroClass.mul_zero, AddMonoidHom.map_zero]
          · exact this x h
        -- prove that the (Sup of rationals less than x) ^ 2 is the Sup of the set of rationals less
        -- than (x ^ 2) by showing it is an upper bound and any smaller number is not an upper bound
        refine' fun x hx => csSup_eq_of_forall_le_of_forall_lt_exists_gt (cut_map_nonempty β _) _ _
        exact le_induced_map_mul_self_of_mem_cut_map hx
        exact exists_mem_cut_map_mul_self_of_lt_induced_map_mul_self hx)
      two_ne_zero (inducedMap_one _ _) with
    monotone' := inducedMap_mono _ _ }
#align linear_ordered_field.induced_order_ring_hom LinearOrderedField.inducedOrderRingHom
-/

#print LinearOrderedField.inducedOrderRingIso /-
/-- The isomorphism of ordered rings between two conditionally complete linearly ordered fields. -/
def inducedOrderRingIso : β ≃+*o γ :=
  { inducedOrderRingHom β γ with
    invFun := inducedMap γ β
    left_inv := inducedMap_inv_self _ _
    right_inv := inducedMap_inv_self _ _
    map_le_map_iff' := fun x y =>
      by
      refine' ⟨fun h => _, fun h => induced_map_mono _ _ h⟩
      simpa [induced_order_ring_hom, AddMonoidHom.mkRingHomOfMulSelfOfTwoNeZero,
        induced_add_hom] using induced_map_mono γ β h }
#align linear_ordered_field.induced_order_ring_iso LinearOrderedField.inducedOrderRingIso
-/

#print LinearOrderedField.coe_inducedOrderRingIso /-
@[simp]
theorem coe_inducedOrderRingIso : ⇑(inducedOrderRingIso β γ) = inducedMap β γ :=
  rfl
#align linear_ordered_field.coe_induced_order_ring_iso LinearOrderedField.coe_inducedOrderRingIso
-/

#print LinearOrderedField.inducedOrderRingIso_symm /-
@[simp]
theorem inducedOrderRingIso_symm : (inducedOrderRingIso β γ).symm = inducedOrderRingIso γ β :=
  rfl
#align linear_ordered_field.induced_order_ring_iso_symm LinearOrderedField.inducedOrderRingIso_symm
-/

#print LinearOrderedField.inducedOrderRingIso_self /-
@[simp]
theorem inducedOrderRingIso_self : inducedOrderRingIso β β = OrderRingIso.refl β :=
  OrderRingIso.ext inducedMap_self
#align linear_ordered_field.induced_order_ring_iso_self LinearOrderedField.inducedOrderRingIso_self
-/

open OrderRingIso

/-- There is a unique ordered ring homomorphism from an archimedean linear ordered field to a
conditionally complete linear ordered field. -/
instance : Unique (α →+*o β) :=
  uniqueOfSubsingleton <| inducedOrderRingHom α β

/-- There is a unique ordered ring isomorphism between two conditionally complete linear ordered
fields. -/
instance : Unique (β ≃+*o γ) :=
  uniqueOfSubsingleton <| inducedOrderRingIso β γ

end InducedMap

end LinearOrderedField

section Real

variable {R S : Type _} [OrderedRing R] [LinearOrderedRing S]

#print ringHom_monotone /-
theorem ringHom_monotone (hR : ∀ r : R, 0 ≤ r → ∃ s : R, s ^ 2 = r) (f : R →+* S) : Monotone f :=
  (monotone_iff_map_nonneg f).2 fun r h => by obtain ⟨s, rfl⟩ := hR r h; rw [map_pow];
    apply sq_nonneg
#align ring_hom_monotone ringHom_monotone
-/

#print Real.RingHom.unique /-
/-- There exists no nontrivial ring homomorphism `ℝ →+* ℝ`. -/
instance Real.RingHom.unique : Unique (ℝ →+* ℝ)
    where
  default := RingHom.id ℝ
  uniq f :=
    congr_arg OrderRingHom.toRingHom
      (Subsingleton.elim ⟨f, ringHom_monotone (fun r hr => ⟨Real.sqrt r, sq_sqrt hr⟩) f⟩ default)
#align real.ring_hom.unique Real.RingHom.unique
-/

end Real

