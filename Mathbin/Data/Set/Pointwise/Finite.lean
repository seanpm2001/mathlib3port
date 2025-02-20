/-
Copyright (c) 2019 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Floris van Doorn

! This file was ported from Lean 3 source module data.set.pointwise.finite
! leanprover-community/mathlib commit c941bb9426d62e266612b6d99e6c9fc93e7a1d07
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Finite
import Mathbin.Data.Set.Pointwise.Smul

/-!
# Finiteness lemmas for pointwise operations on sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


open scoped Pointwise

variable {F α β γ : Type _}

namespace Set

section One

variable [One α]

#print Set.finite_one /-
@[simp, to_additive]
theorem finite_one : (1 : Set α).Finite :=
  finite_singleton _
#align set.finite_one Set.finite_one
#align set.finite_zero Set.finite_zero
-/

end One

section InvolutiveInv

variable [InvolutiveInv α] {s : Set α}

#print Set.Finite.inv /-
@[to_additive]
theorem Finite.inv (hs : s.Finite) : s⁻¹.Finite :=
  hs.Preimage <| inv_injective.InjOn _
#align set.finite.inv Set.Finite.inv
#align set.finite.neg Set.Finite.neg
-/

end InvolutiveInv

section Mul

variable [Mul α] {s t : Set α}

#print Set.Finite.mul /-
@[to_additive]
theorem Finite.mul : s.Finite → t.Finite → (s * t).Finite :=
  Finite.image2 _
#align set.finite.mul Set.Finite.mul
#align set.finite.add Set.Finite.add
-/

#print Set.fintypeMul /-
/-- Multiplication preserves finiteness. -/
@[to_additive "Addition preserves finiteness."]
def fintypeMul [DecidableEq α] (s t : Set α) [Fintype s] [Fintype t] : Fintype (s * t : Set α) :=
  Set.fintypeImage2 _ _ _
#align set.fintype_mul Set.fintypeMul
#align set.fintype_add Set.fintypeAdd
-/

end Mul

section Monoid

variable [Monoid α] {s t : Set α}

#print Set.decidableMemMul /-
@[to_additive]
instance decidableMemMul [Fintype α] [DecidableEq α] [DecidablePred (· ∈ s)]
    [DecidablePred (· ∈ t)] : DecidablePred (· ∈ s * t) := fun _ => decidable_of_iff _ mem_mul.symm
#align set.decidable_mem_mul Set.decidableMemMul
#align set.decidable_mem_add Set.decidableMemAdd
-/

#print Set.decidableMemPow /-
@[to_additive]
instance decidableMemPow [Fintype α] [DecidableEq α] [DecidablePred (· ∈ s)] (n : ℕ) :
    DecidablePred (· ∈ s ^ n) := by
  induction' n with n ih
  · simp_rw [pow_zero, mem_one]; infer_instance
  · letI := ih; rw [pow_succ]; infer_instance
#align set.decidable_mem_pow Set.decidableMemPow
#align set.decidable_mem_nsmul Set.decidableMemNSMul
-/

end Monoid

section SMul

variable [SMul α β] {s : Set α} {t : Set β}

#print Set.Finite.smul /-
@[to_additive]
theorem Finite.smul : s.Finite → t.Finite → (s • t).Finite :=
  Finite.image2 _
#align set.finite.smul Set.Finite.smul
#align set.finite.vadd Set.Finite.vadd
-/

end SMul

section HasSmulSet

variable [SMul α β] {s : Set β} {a : α}

#print Set.Finite.smul_set /-
@[to_additive]
theorem Finite.smul_set : s.Finite → (a • s).Finite :=
  Finite.image _
#align set.finite.smul_set Set.Finite.smul_set
#align set.finite.vadd_set Set.Finite.vadd_set
-/

#print Set.Infinite.of_smul_set /-
@[to_additive]
theorem Infinite.of_smul_set : (a • s).Infinite → s.Infinite :=
  Infinite.of_image _
#align set.infinite.of_smul_set Set.Infinite.of_smul_set
#align set.infinite.of_vadd_set Set.Infinite.of_vadd_set
-/

end HasSmulSet

section Vsub

variable [VSub α β] {s t : Set β}

#print Set.Finite.vsub /-
theorem Finite.vsub (hs : s.Finite) (ht : t.Finite) : Set.Finite (s -ᵥ t) :=
  hs.image2 _ ht
#align set.finite.vsub Set.Finite.vsub
-/

end Vsub

section Cancel

variable [Mul α] [IsLeftCancelMul α] [IsRightCancelMul α] {s t : Set α}

#print Set.infinite_mul /-
@[to_additive]
theorem infinite_mul : (s * t).Infinite ↔ s.Infinite ∧ t.Nonempty ∨ t.Infinite ∧ s.Nonempty :=
  infinite_image2 (fun _ _ => (mul_left_injective _).InjOn _) fun _ _ =>
    (mul_right_injective _).InjOn _
#align set.infinite_mul Set.infinite_mul
#align set.infinite_add Set.infinite_add
-/

end Cancel

section Group

variable [Group α] [MulAction α β] {a : α} {s : Set β}

#print Set.finite_smul_set /-
@[simp, to_additive]
theorem finite_smul_set : (a • s).Finite ↔ s.Finite :=
  finite_image_iff <| (MulAction.injective _).InjOn _
#align set.finite_smul_set Set.finite_smul_set
#align set.finite_vadd_set Set.finite_vadd_set
-/

#print Set.infinite_smul_set /-
@[simp, to_additive]
theorem infinite_smul_set : (a • s).Infinite ↔ s.Infinite :=
  infinite_image_iff <| (MulAction.injective _).InjOn _
#align set.infinite_smul_set Set.infinite_smul_set
#align set.infinite_vadd_set Set.infinite_vadd_set
-/

alias finite_smul_set ↔ finite.of_smul_set _
#align set.finite.of_smul_set Set.Finite.of_smul_set

alias infinite_smul_set ↔ _ infinite.smul_set
#align set.infinite.smul_set Set.Infinite.smul_set

attribute [to_additive] finite.of_smul_set infinite.smul_set

end Group

end Set

open Set

namespace Group

variable {G : Type _} [Group G] [Fintype G] (S : Set G)

#print Group.card_pow_eq_card_pow_card_univ /-
@[to_additive]
theorem card_pow_eq_card_pow_card_univ [∀ k : ℕ, DecidablePred (· ∈ S ^ k)] :
    ∀ k, Fintype.card G ≤ k → Fintype.card ↥(S ^ k) = Fintype.card ↥(S ^ Fintype.card G) :=
  by
  have hG : 0 < Fintype.card G := fintype.card_pos_iff.mpr ⟨1⟩
  by_cases hS : S = ∅
  · refine' fun k hk => Fintype.card_congr _
    rw [hS, empty_pow (ne_of_gt (lt_of_lt_of_le hG hk)), empty_pow (ne_of_gt hG)]
  obtain ⟨a, ha⟩ := Set.nonempty_iff_ne_empty.2 hS
  classical!
  have key : ∀ (a) (s t : Set G), (∀ b : G, b ∈ s → a * b ∈ t) → Fintype.card s ≤ Fintype.card t :=
    by
    refine' fun a s t h => Fintype.card_le_of_injective (fun ⟨b, hb⟩ => ⟨a * b, h b hb⟩) _
    rintro ⟨b, hb⟩ ⟨c, hc⟩ hbc
    exact Subtype.ext (mul_left_cancel (subtype.ext_iff.mp hbc))
  have mono : Monotone (fun n => Fintype.card ↥(S ^ n) : ℕ → ℕ) :=
    monotone_nat_of_le_succ fun n => key a _ _ fun b hb => Set.mul_mem_mul ha hb
  convert
    card_pow_eq_card_pow_card_univ_aux mono (fun n => set_fintype_card_le_univ (S ^ n)) fun n h =>
      le_antisymm (mono (n + 1).le_succ) (key a⁻¹ _ _ _)
  · simp only [Finset.filter_congr_decidable, Fintype.card_ofFinset]
  replace h : {a} * S ^ n = S ^ (n + 1)
  · refine' Set.eq_of_subset_of_card_le _ (le_trans (ge_of_eq h) _)
    · exact mul_subset_mul (set.singleton_subset_iff.mpr ha) Set.Subset.rfl
    · convert key a (S ^ n) ({a} * S ^ n) fun b hb => Set.mul_mem_mul (Set.mem_singleton a) hb
  rw [pow_succ', ← h, mul_assoc, ← pow_succ', h]
  rintro _ ⟨b, c, hb, hc, rfl⟩
  rwa [set.mem_singleton_iff.mp hb, inv_mul_cancel_left]
#align group.card_pow_eq_card_pow_card_univ Group.card_pow_eq_card_pow_card_univ
#align add_group.card_nsmul_eq_card_nsmul_card_univ AddGroup.card_nsmul_eq_card_nsmul_card_univ
-/

end Group

