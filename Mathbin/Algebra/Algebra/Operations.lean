/-
Copyright (c) 2019 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module algebra.algebra.operations
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Bilinear
import Mathbin.Algebra.Algebra.Equiv
import Mathbin.Algebra.Module.Submodule.Pointwise
import Mathbin.Algebra.Module.Submodule.Bilinear
import Mathbin.Algebra.Module.Opposites
import Mathbin.Algebra.Order.Kleene
import Mathbin.Data.Finset.Pointwise
import Mathbin.Data.Set.Semiring
import Mathbin.Data.Set.Pointwise.BigOperators
import Mathbin.GroupTheory.GroupAction.SubMulAction.Pointwise

/-!
# Multiplication and division of submodules of an algebra.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

An interface for multiplication and division of sub-R-modules of an R-algebra A is developed.

## Main definitions

Let `R` be a commutative ring (or semiring) and let `A` be an `R`-algebra.

* `1 : submodule R A`       : the R-submodule R of the R-algebra A
* `has_mul (submodule R A)` : multiplication of two sub-R-modules M and N of A is defined to be
                              the smallest submodule containing all the products `m * n`.
* `has_div (submodule R A)` : `I / J` is defined to be the submodule consisting of all `a : A` such
                              that `a • J ⊆ I`

It is proved that `submodule R A` is a semiring, and also an algebra over `set A`.

Additionally, in the `pointwise` locale we promote `submodule.pointwise_distrib_mul_action` to a
`mul_semiring_action` as `submodule.pointwise_mul_semiring_action`.

## Tags

multiplication of submodules, division of submodules, submodule semiring
-/


universe uι u v

open Algebra Set MulOpposite

open scoped BigOperators

open scoped Pointwise

namespace SubMulAction

variable {R : Type u} {A : Type v} [CommSemiring R] [Semiring A] [Algebra R A]

#print SubMulAction.algebraMap_mem /-
theorem algebraMap_mem (r : R) : algebraMap R A r ∈ (1 : SubMulAction R A) :=
  ⟨r, (algebraMap_eq_smul_one r).symm⟩
#align sub_mul_action.algebra_map_mem SubMulAction.algebraMap_mem
-/

#print SubMulAction.mem_one' /-
theorem mem_one' {x : A} : x ∈ (1 : SubMulAction R A) ↔ ∃ y, algebraMap R A y = x :=
  exists_congr fun r => by rw [algebra_map_eq_smul_one]
#align sub_mul_action.mem_one' SubMulAction.mem_one'
-/

end SubMulAction

namespace Submodule

variable {ι : Sort uι}

variable {R : Type u} [CommSemiring R]

section Ring

variable {A : Type v} [Semiring A] [Algebra R A]

variable (S T : Set A) {M N P Q : Submodule R A} {m n : A}

/-- `1 : submodule R A` is the submodule R of A. -/
instance : One (Submodule R A) :=
  ⟨(Algebra.linearMap R A).range⟩

#print Submodule.one_eq_range /-
theorem one_eq_range : (1 : Submodule R A) = (Algebra.linearMap R A).range :=
  rfl
#align submodule.one_eq_range Submodule.one_eq_range
-/

#print Submodule.le_one_toAddSubmonoid /-
theorem le_one_toAddSubmonoid : 1 ≤ (1 : Submodule R A).toAddSubmonoid :=
  by
  rintro x ⟨n, rfl⟩
  exact ⟨n, map_natCast (algebraMap R A) n⟩
#align submodule.le_one_to_add_submonoid Submodule.le_one_toAddSubmonoid
-/

#print Submodule.algebraMap_mem /-
theorem algebraMap_mem (r : R) : algebraMap R A r ∈ (1 : Submodule R A) :=
  LinearMap.mem_range_self _ _
#align submodule.algebra_map_mem Submodule.algebraMap_mem
-/

#print Submodule.mem_one /-
@[simp]
theorem mem_one {x : A} : x ∈ (1 : Submodule R A) ↔ ∃ y, algebraMap R A y = x :=
  Iff.rfl
#align submodule.mem_one Submodule.mem_one
-/

#print Submodule.toSubMulAction_one /-
@[simp]
theorem toSubMulAction_one : (1 : Submodule R A).toSubMulAction = 1 :=
  SetLike.ext fun x => mem_one.trans SubMulAction.mem_one'.symm
#align submodule.to_sub_mul_action_one Submodule.toSubMulAction_one
-/

#print Submodule.one_eq_span /-
theorem one_eq_span : (1 : Submodule R A) = R ∙ 1 :=
  by
  apply Submodule.ext
  intro a
  simp only [mem_one, mem_span_singleton, Algebra.smul_def, mul_one]
#align submodule.one_eq_span Submodule.one_eq_span
-/

#print Submodule.one_eq_span_one_set /-
theorem one_eq_span_one_set : (1 : Submodule R A) = span R 1 :=
  one_eq_span
#align submodule.one_eq_span_one_set Submodule.one_eq_span_one_set
-/

#print Submodule.one_le /-
theorem one_le : (1 : Submodule R A) ≤ P ↔ (1 : A) ∈ P := by
  simpa only [one_eq_span, span_le, Set.singleton_subset_iff]
#align submodule.one_le Submodule.one_le
-/

#print Submodule.map_one /-
protected theorem map_one {A'} [Semiring A'] [Algebra R A'] (f : A →ₐ[R] A') :
    map f.toLinearMap (1 : Submodule R A) = 1 := by ext; simp
#align submodule.map_one Submodule.map_one
-/

#print Submodule.map_op_one /-
@[simp]
theorem map_op_one :
    map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) (1 : Submodule R A) = 1 := by ext;
  induction x using MulOpposite.rec'; simp
#align submodule.map_op_one Submodule.map_op_one
-/

#print Submodule.comap_op_one /-
@[simp]
theorem comap_op_one :
    comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) (1 : Submodule R Aᵐᵒᵖ) = 1 := by ext;
  simp
#align submodule.comap_op_one Submodule.comap_op_one
-/

#print Submodule.map_unop_one /-
@[simp]
theorem map_unop_one :
    map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) (1 : Submodule R Aᵐᵒᵖ) = 1 := by
  rw [← comap_equiv_eq_map_symm, comap_op_one]
#align submodule.map_unop_one Submodule.map_unop_one
-/

#print Submodule.comap_unop_one /-
@[simp]
theorem comap_unop_one :
    comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) (1 : Submodule R A) = 1 := by
  rw [← map_equiv_eq_comap_symm, map_op_one]
#align submodule.comap_unop_one Submodule.comap_unop_one
-/

/-- Multiplication of sub-R-modules of an R-algebra A. The submodule `M * N` is the
smallest R-submodule of `A` containing the elements `m * n` for `m ∈ M` and `n ∈ N`. -/
instance : Mul (Submodule R A) :=
  ⟨Submodule.map₂ <| LinearMap.mul R A⟩

#print Submodule.mul_mem_mul /-
theorem mul_mem_mul (hm : m ∈ M) (hn : n ∈ N) : m * n ∈ M * N :=
  apply_mem_map₂ _ hm hn
#align submodule.mul_mem_mul Submodule.mul_mem_mul
-/

#print Submodule.mul_le /-
theorem mul_le : M * N ≤ P ↔ ∀ m ∈ M, ∀ n ∈ N, m * n ∈ P :=
  map₂_le
#align submodule.mul_le Submodule.mul_le
-/

#print Submodule.mul_toAddSubmonoid /-
theorem mul_toAddSubmonoid (M N : Submodule R A) :
    (M * N).toAddSubmonoid = M.toAddSubmonoid * N.toAddSubmonoid :=
  by
  dsimp [Mul.mul]
  simp_rw [← LinearMap.mulLeft_toAddMonoidHom R, LinearMap.mulLeft, ← map_to_add_submonoid _ N,
    map₂]
  rw [supr_to_add_submonoid]
  rfl
#align submodule.mul_to_add_submonoid Submodule.mul_toAddSubmonoid
-/

#print Submodule.mul_induction_on /-
@[elab_as_elim]
protected theorem mul_induction_on {C : A → Prop} {r : A} (hr : r ∈ M * N)
    (hm : ∀ m ∈ M, ∀ n ∈ N, C (m * n)) (ha : ∀ x y, C x → C y → C (x + y)) : C r :=
  by
  rw [← mem_to_add_submonoid, mul_to_add_submonoid] at hr 
  exact AddSubmonoid.mul_induction_on hr hm ha
#align submodule.mul_induction_on Submodule.mul_induction_on
-/

#print Submodule.mul_induction_on' /-
/-- A dependent version of `mul_induction_on`. -/
@[elab_as_elim]
protected theorem mul_induction_on' {C : ∀ r, r ∈ M * N → Prop}
    (hm : ∀ m ∈ M, ∀ n ∈ N, C (m * n) (mul_mem_mul ‹_› ‹_›))
    (ha : ∀ x hx y hy, C x hx → C y hy → C (x + y) (add_mem ‹_› ‹_›)) {r : A} (hr : r ∈ M * N) :
    C r hr := by
  refine' Exists.elim _ fun (hr : r ∈ M * N) (hc : C r hr) => hc
  exact
    Submodule.mul_induction_on hr (fun x hx y hy => ⟨_, hm _ hx _ hy⟩) fun x y ⟨_, hx⟩ ⟨_, hy⟩ =>
      ⟨_, ha _ _ _ _ hx hy⟩
#align submodule.mul_induction_on' Submodule.mul_induction_on'
-/

variable (R)

#print Submodule.span_mul_span /-
theorem span_mul_span : span R S * span R T = span R (S * T) :=
  map₂_span_span _ _ _ _
#align submodule.span_mul_span Submodule.span_mul_span
-/

variable {R}

variable (M N P Q)

#print Submodule.mul_bot /-
@[simp]
theorem mul_bot : M * ⊥ = ⊥ :=
  map₂_bot_right _ _
#align submodule.mul_bot Submodule.mul_bot
-/

#print Submodule.bot_mul /-
@[simp]
theorem bot_mul : ⊥ * M = ⊥ :=
  map₂_bot_left _ _
#align submodule.bot_mul Submodule.bot_mul
-/

#print Submodule.one_mul /-
@[simp]
protected theorem one_mul : (1 : Submodule R A) * M = M := by
  conv_lhs => rw [one_eq_span, ← span_eq M]; erw [span_mul_span, one_mul, span_eq]
#align submodule.one_mul Submodule.one_mul
-/

#print Submodule.mul_one /-
@[simp]
protected theorem mul_one : M * 1 = M := by conv_lhs => rw [one_eq_span, ← span_eq M];
  erw [span_mul_span, mul_one, span_eq]
#align submodule.mul_one Submodule.mul_one
-/

variable {M N P Q}

#print Submodule.mul_le_mul /-
@[mono]
theorem mul_le_mul (hmp : M ≤ P) (hnq : N ≤ Q) : M * N ≤ P * Q :=
  map₂_le_map₂ hmp hnq
#align submodule.mul_le_mul Submodule.mul_le_mul
-/

#print Submodule.mul_le_mul_left /-
theorem mul_le_mul_left (h : M ≤ N) : M * P ≤ N * P :=
  map₂_le_map₂_left h
#align submodule.mul_le_mul_left Submodule.mul_le_mul_left
-/

#print Submodule.mul_le_mul_right /-
theorem mul_le_mul_right (h : N ≤ P) : M * N ≤ M * P :=
  map₂_le_map₂_right h
#align submodule.mul_le_mul_right Submodule.mul_le_mul_right
-/

variable (M N P)

#print Submodule.mul_sup /-
theorem mul_sup : M * (N ⊔ P) = M * N ⊔ M * P :=
  map₂_sup_right _ _ _ _
#align submodule.mul_sup Submodule.mul_sup
-/

#print Submodule.sup_mul /-
theorem sup_mul : (M ⊔ N) * P = M * P ⊔ N * P :=
  map₂_sup_left _ _ _ _
#align submodule.sup_mul Submodule.sup_mul
-/

#print Submodule.mul_subset_mul /-
theorem mul_subset_mul : (↑M : Set A) * (↑N : Set A) ⊆ (↑(M * N) : Set A) :=
  image2_subset_map₂ (Algebra.lmul R A).toLinearMap M N
#align submodule.mul_subset_mul Submodule.mul_subset_mul
-/

#print Submodule.map_mul /-
protected theorem map_mul {A'} [Semiring A'] [Algebra R A'] (f : A →ₐ[R] A') :
    map f.toLinearMap (M * N) = map f.toLinearMap M * map f.toLinearMap N :=
  calc
    map f.toLinearMap (M * N) = ⨆ i : M, (N.map (LinearMap.mul R A i)).map f.toLinearMap :=
      map_iSup _ _
    _ = map f.toLinearMap M * map f.toLinearMap N :=
      by
      apply congr_arg Sup
      ext S
      constructor <;> rintro ⟨y, hy⟩
      · use f y, mem_map.mpr ⟨y.1, y.2, rfl⟩
        refine' trans _ hy
        ext
        simp
      · obtain ⟨y', hy', fy_eq⟩ := mem_map.mp y.2
        use y', hy'
        refine' trans _ hy
        rw [f.to_linear_map_apply] at fy_eq 
        ext
        simp [fy_eq]
#align submodule.map_mul Submodule.map_mul
-/

#print Submodule.map_op_mul /-
theorem map_op_mul :
    map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) (M * N) =
      map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) N *
        map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) M :=
  by
  apply le_antisymm
  · simp_rw [map_le_iff_le_comap]
    refine' mul_le.2 fun m hm n hn => _
    rw [mem_comap, map_equiv_eq_comap_symm, map_equiv_eq_comap_symm]
    show op n * op m ∈ _
    exact mul_mem_mul hn hm
  · refine' mul_le.2 (MulOpposite.rec' fun m hm => MulOpposite.rec' fun n hn => _)
    rw [Submodule.mem_map_equiv] at hm hn ⊢
    exact mul_mem_mul hn hm
#align submodule.map_op_mul Submodule.map_op_mul
-/

#print Submodule.comap_unop_mul /-
theorem comap_unop_mul :
    comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) (M * N) =
      comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) N *
        comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) M :=
  by simp_rw [← map_equiv_eq_comap_symm, map_op_mul]
#align submodule.comap_unop_mul Submodule.comap_unop_mul
-/

#print Submodule.map_unop_mul /-
theorem map_unop_mul (M N : Submodule R Aᵐᵒᵖ) :
    map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) (M * N) =
      map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) N *
        map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) M :=
  have : Function.Injective (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) :=
    LinearEquiv.injective _
  map_injective_of_injective this <| by
    rw [← map_comp, map_op_mul, ← map_comp, ← map_comp, LinearEquiv.comp_coe,
      LinearEquiv.symm_trans_self, LinearEquiv.refl_toLinearMap, map_id, map_id, map_id]
#align submodule.map_unop_mul Submodule.map_unop_mul
-/

#print Submodule.comap_op_mul /-
theorem comap_op_mul (M N : Submodule R Aᵐᵒᵖ) :
    comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) (M * N) =
      comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) N *
        comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) M :=
  by simp_rw [comap_equiv_eq_map_symm, map_unop_mul]
#align submodule.comap_op_mul Submodule.comap_op_mul
-/

section

open scoped Pointwise

#print Submodule.hasDistribPointwiseNeg /-
/-- `submodule.has_pointwise_neg` distributes over multiplication.

This is available as an instance in the `pointwise` locale. -/
protected def hasDistribPointwiseNeg {A} [Ring A] [Algebra R A] : HasDistribNeg (Submodule R A) :=
  toAddSubmonoid_injective.HasDistribNeg _ neg_toAddSubmonoid mul_toAddSubmonoid
#align submodule.has_distrib_pointwise_neg Submodule.hasDistribPointwiseNeg
-/

scoped[Pointwise] attribute [instance] Submodule.hasDistribPointwiseNeg

end

section DecidableEq

open scoped Classical

#print Submodule.mem_span_mul_finite_of_mem_span_mul /-
theorem mem_span_mul_finite_of_mem_span_mul {R A} [Semiring R] [AddCommMonoid A] [Mul A]
    [Module R A] {S : Set A} {S' : Set A} {x : A} (hx : x ∈ span R (S * S')) :
    ∃ T T' : Finset A, ↑T ⊆ S ∧ ↑T' ⊆ S' ∧ x ∈ span R (T * T' : Set A) :=
  by
  obtain ⟨U, h, hU⟩ := mem_span_finite_of_mem_span hx
  obtain ⟨T, T', hS, hS', h⟩ := Finset.subset_mul h
  use T, T', hS, hS'
  have h' : (U : Set A) ⊆ T * T' := by assumption_mod_cast
  have h'' := span_mono h' hU
  assumption
#align submodule.mem_span_mul_finite_of_mem_span_mul Submodule.mem_span_mul_finite_of_mem_span_mul
-/

end DecidableEq

#print Submodule.mul_eq_span_mul_set /-
theorem mul_eq_span_mul_set (s t : Submodule R A) : s * t = span R ((s : Set A) * (t : Set A)) :=
  map₂_eq_span_image2 _ s t
#align submodule.mul_eq_span_mul_set Submodule.mul_eq_span_mul_set
-/

#print Submodule.iSup_mul /-
theorem iSup_mul (s : ι → Submodule R A) (t : Submodule R A) : (⨆ i, s i) * t = ⨆ i, s i * t :=
  map₂_iSup_left _ s t
#align submodule.supr_mul Submodule.iSup_mul
-/

#print Submodule.mul_iSup /-
theorem mul_iSup (t : Submodule R A) (s : ι → Submodule R A) : (t * ⨆ i, s i) = ⨆ i, t * s i :=
  map₂_iSup_right _ t s
#align submodule.mul_supr Submodule.mul_iSup
-/

#print Submodule.mem_span_mul_finite_of_mem_mul /-
theorem mem_span_mul_finite_of_mem_mul {P Q : Submodule R A} {x : A} (hx : x ∈ P * Q) :
    ∃ T T' : Finset A, (T : Set A) ⊆ P ∧ (T' : Set A) ⊆ Q ∧ x ∈ span R (T * T' : Set A) :=
  Submodule.mem_span_mul_finite_of_mem_span_mul
    (by rwa [← Submodule.span_eq P, ← Submodule.span_eq Q, Submodule.span_mul_span] at hx )
#align submodule.mem_span_mul_finite_of_mem_mul Submodule.mem_span_mul_finite_of_mem_mul
-/

variable {M N P}

#print Submodule.mem_span_singleton_mul /-
theorem mem_span_singleton_mul {x y : A} : x ∈ span R {y} * P ↔ ∃ z ∈ P, y * z = x := by
  simp_rw [(· * ·), map₂_span_singleton_eq_map, exists_prop]; rfl
#align submodule.mem_span_singleton_mul Submodule.mem_span_singleton_mul
-/

#print Submodule.mem_mul_span_singleton /-
theorem mem_mul_span_singleton {x y : A} : x ∈ P * span R {y} ↔ ∃ z ∈ P, z * y = x := by
  simp_rw [(· * ·), map₂_span_singleton_eq_map_flip, exists_prop]; rfl
#align submodule.mem_mul_span_singleton Submodule.mem_mul_span_singleton
-/

/-- Sub-R-modules of an R-algebra form an idempotent semiring. -/
instance : IdemSemiring (Submodule R A) :=
  { toAddSubmonoid_injective.Semigroup _ fun m n : Submodule R A => mul_toAddSubmonoid m n,
    AddMonoidWithOne.unary, Submodule.pointwiseAddCommMonoid, Submodule.one, Submodule.mul,
    (by infer_instance : OrderBot (Submodule R A)),
    (by infer_instance :
      Lattice (Submodule R A)) with
    one_mul := Submodule.one_mul
    mul_one := Submodule.mul_one
    zero_mul := bot_mul
    mul_zero := mul_bot
    left_distrib := mul_sup
    right_distrib := sup_mul }

variable (M)

#print Submodule.span_pow /-
theorem span_pow (s : Set A) : ∀ n : ℕ, span R s ^ n = span R (s ^ n)
  | 0 => by rw [pow_zero, pow_zero, one_eq_span_one_set]
  | n + 1 => by rw [pow_succ, pow_succ, span_pow, span_mul_span]
#align submodule.span_pow Submodule.span_pow
-/

#print Submodule.pow_eq_span_pow_set /-
theorem pow_eq_span_pow_set (n : ℕ) : M ^ n = span R ((M : Set A) ^ n) := by
  rw [← span_pow, span_eq]
#align submodule.pow_eq_span_pow_set Submodule.pow_eq_span_pow_set
-/

#print Submodule.pow_subset_pow /-
theorem pow_subset_pow {n : ℕ} : (↑M : Set A) ^ n ⊆ ↑(M ^ n : Submodule R A) :=
  (pow_eq_span_pow_set M n).symm ▸ subset_span
#align submodule.pow_subset_pow Submodule.pow_subset_pow
-/

#print Submodule.pow_mem_pow /-
theorem pow_mem_pow {x : A} (hx : x ∈ M) (n : ℕ) : x ^ n ∈ M ^ n :=
  pow_subset_pow _ <| Set.pow_mem_pow hx _
#align submodule.pow_mem_pow Submodule.pow_mem_pow
-/

#print Submodule.pow_toAddSubmonoid /-
theorem pow_toAddSubmonoid {n : ℕ} (h : n ≠ 0) : (M ^ n).toAddSubmonoid = M.toAddSubmonoid ^ n :=
  by
  induction' n with n ih
  · exact (h rfl).elim
  · rw [pow_succ, pow_succ, mul_to_add_submonoid]
    cases n
    · rw [pow_zero, pow_zero, mul_one, ← mul_to_add_submonoid, mul_one]
    · rw [ih n.succ_ne_zero]
#align submodule.pow_to_add_submonoid Submodule.pow_toAddSubmonoid
-/

#print Submodule.le_pow_toAddSubmonoid /-
theorem le_pow_toAddSubmonoid {n : ℕ} : M.toAddSubmonoid ^ n ≤ (M ^ n).toAddSubmonoid :=
  by
  obtain rfl | hn := Decidable.eq_or_ne n 0
  · rw [pow_zero, pow_zero]; exact le_one_to_add_submonoid
  · exact (pow_to_add_submonoid M hn).ge
#align submodule.le_pow_to_add_submonoid Submodule.le_pow_toAddSubmonoid
-/

#print Submodule.pow_induction_on_left' /-
/-- Dependent version of `submodule.pow_induction_on_left`. -/
@[elab_as_elim]
protected theorem pow_induction_on_left' {C : ∀ (n : ℕ) (x), x ∈ M ^ n → Prop}
    (hr : ∀ r : R, C 0 (algebraMap _ _ r) (algebraMap_mem r))
    (hadd : ∀ x y i hx hy, C i x hx → C i y hy → C i (x + y) (add_mem ‹_› ‹_›))
    (hmul : ∀ m ∈ M, ∀ (i x hx), C i x hx → C i.succ (m * x) (mul_mem_mul H hx)) {x : A} {n : ℕ}
    (hx : x ∈ M ^ n) : C n x hx :=
  by
  induction' n with n n_ih generalizing x
  · rw [pow_zero] at hx 
    obtain ⟨r, rfl⟩ := hx
    exact hr r
  exact
    Submodule.mul_induction_on' (fun m hm x ih => hmul _ hm _ _ _ (n_ih ih))
      (fun x hx y hy Cx Cy => hadd _ _ _ _ _ Cx Cy) hx
#align submodule.pow_induction_on_left' Submodule.pow_induction_on_left'
-/

#print Submodule.pow_induction_on_right' /-
/-- Dependent version of `submodule.pow_induction_on_right`. -/
@[elab_as_elim]
protected theorem pow_induction_on_right' {C : ∀ (n : ℕ) (x), x ∈ M ^ n → Prop}
    (hr : ∀ r : R, C 0 (algebraMap _ _ r) (algebraMap_mem r))
    (hadd : ∀ x y i hx hy, C i x hx → C i y hy → C i (x + y) (add_mem ‹_› ‹_›))
    (hmul :
      ∀ i x hx, C i x hx → ∀ m ∈ M, C i.succ (x * m) ((pow_succ' M i).symm ▸ mul_mem_mul hx H))
    {x : A} {n : ℕ} (hx : x ∈ M ^ n) : C n x hx :=
  by
  induction' n with n n_ih generalizing x
  · rw [pow_zero] at hx 
    obtain ⟨r, rfl⟩ := hx
    exact hr r
  revert hx
  simp_rw [pow_succ']
  intro hx
  exact
    Submodule.mul_induction_on' (fun m hm x ih => hmul _ _ hm (n_ih _) _ ih)
      (fun x hx y hy Cx Cy => hadd _ _ _ _ _ Cx Cy) hx
#align submodule.pow_induction_on_right' Submodule.pow_induction_on_right'
-/

#print Submodule.pow_induction_on_left /-
/-- To show a property on elements of `M ^ n` holds, it suffices to show that it holds for scalars,
is closed under addition, and holds for `m * x` where `m ∈ M` and it holds for `x` -/
@[elab_as_elim]
protected theorem pow_induction_on_left {C : A → Prop} (hr : ∀ r : R, C (algebraMap _ _ r))
    (hadd : ∀ x y, C x → C y → C (x + y)) (hmul : ∀ m ∈ M, ∀ (x), C x → C (m * x)) {x : A} {n : ℕ}
    (hx : x ∈ M ^ n) : C x :=
  Submodule.pow_induction_on_left' M hr (fun x y i hx hy => hadd x y)
    (fun m hm i x hx => hmul _ hm _) hx
#align submodule.pow_induction_on_left Submodule.pow_induction_on_left
-/

#print Submodule.pow_induction_on_right /-
/-- To show a property on elements of `M ^ n` holds, it suffices to show that it holds for scalars,
is closed under addition, and holds for `x * m` where `m ∈ M` and it holds for `x` -/
@[elab_as_elim]
protected theorem pow_induction_on_right {C : A → Prop} (hr : ∀ r : R, C (algebraMap _ _ r))
    (hadd : ∀ x y, C x → C y → C (x + y)) (hmul : ∀ x, C x → ∀ m ∈ M, C (x * m)) {x : A} {n : ℕ}
    (hx : x ∈ M ^ n) : C x :=
  Submodule.pow_induction_on_right' M hr (fun x y i hx hy => hadd x y) (fun i x hx => hmul _) hx
#align submodule.pow_induction_on_right Submodule.pow_induction_on_right
-/

#print Submodule.mapHom /-
/-- `submonoid.map` as a `monoid_with_zero_hom`, when applied to `alg_hom`s. -/
@[simps]
def mapHom {A'} [Semiring A'] [Algebra R A'] (f : A →ₐ[R] A') : Submodule R A →*₀ Submodule R A'
    where
  toFun := map f.toLinearMap
  map_zero' := Submodule.map_bot _
  map_one' := Submodule.map_one _
  map_mul' _ _ := Submodule.map_mul _ _ _
#align submodule.map_hom Submodule.mapHom
-/

#print Submodule.equivOpposite /-
/-- The ring of submodules of the opposite algebra is isomorphic to the opposite ring of
submodules. -/
@[simps apply symm_apply]
def equivOpposite : Submodule R Aᵐᵒᵖ ≃+* (Submodule R A)ᵐᵒᵖ
    where
  toFun p := op <| p.comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ)
  invFun p := p.unop.comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A)
  left_inv p := SetLike.coe_injective <| rfl
  right_inv p := unop_injective <| SetLike.coe_injective rfl
  map_add' p q := by simp [comap_equiv_eq_map_symm, ← op_add]
  map_mul' p q := congr_arg op <| comap_op_mul _ _
#align submodule.equiv_opposite Submodule.equivOpposite
-/

#print Submodule.map_pow /-
protected theorem map_pow {A'} [Semiring A'] [Algebra R A'] (f : A →ₐ[R] A') (n : ℕ) :
    map f.toLinearMap (M ^ n) = map f.toLinearMap M ^ n :=
  map_pow (mapHom f) M n
#align submodule.map_pow Submodule.map_pow
-/

#print Submodule.comap_unop_pow /-
theorem comap_unop_pow (n : ℕ) :
    comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) (M ^ n) =
      comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) M ^ n :=
  (equivOpposite : Submodule R Aᵐᵒᵖ ≃+* _).symm.map_pow (op M) n
#align submodule.comap_unop_pow Submodule.comap_unop_pow
-/

#print Submodule.comap_op_pow /-
theorem comap_op_pow (n : ℕ) (M : Submodule R Aᵐᵒᵖ) :
    comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) (M ^ n) =
      comap (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) M ^ n :=
  op_injective <| (equivOpposite : Submodule R Aᵐᵒᵖ ≃+* _).map_pow M n
#align submodule.comap_op_pow Submodule.comap_op_pow
-/

#print Submodule.map_op_pow /-
theorem map_op_pow (n : ℕ) :
    map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) (M ^ n) =
      map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ) : A →ₗ[R] Aᵐᵒᵖ) M ^ n :=
  by rw [map_equiv_eq_comap_symm, map_equiv_eq_comap_symm, comap_unop_pow]
#align submodule.map_op_pow Submodule.map_op_pow
-/

#print Submodule.map_unop_pow /-
theorem map_unop_pow (n : ℕ) (M : Submodule R Aᵐᵒᵖ) :
    map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) (M ^ n) =
      map (↑(opLinearEquiv R : A ≃ₗ[R] Aᵐᵒᵖ).symm : Aᵐᵒᵖ →ₗ[R] A) M ^ n :=
  by rw [← comap_equiv_eq_map_symm, ← comap_equiv_eq_map_symm, comap_op_pow]
#align submodule.map_unop_pow Submodule.map_unop_pow
-/

#print Submodule.span.ringHom /-
/-- `span` is a semiring homomorphism (recall multiplication is pointwise multiplication of subsets
on either side). -/
@[simps]
def span.ringHom : SetSemiring A →+* Submodule R A
    where
  toFun s := Submodule.span R s.down
  map_zero' := span_empty
  map_one' := one_eq_span.symm
  map_add' := span_union
  map_mul' s t := by rw [SetSemiring.down_mul, span_mul_span, ← image_mul_prod]
#align submodule.span.ring_hom Submodule.span.ringHom
-/

section

variable {α : Type _} [Monoid α] [MulSemiringAction α A] [SMulCommClass α R A]

#print Submodule.pointwiseMulSemiringAction /-
/-- The action on a submodule corresponding to applying the action to every element.

This is available as an instance in the `pointwise` locale.

This is a stronger version of `submodule.pointwise_distrib_mul_action`. -/
protected def pointwiseMulSemiringAction : MulSemiringAction α (Submodule R A) :=
  {
    Submodule.pointwiseDistribMulAction with
    smul_mul := fun r x y => Submodule.map_mul x y <| MulSemiringAction.toAlgHom R A r
    smul_one := fun r => Submodule.map_one <| MulSemiringAction.toAlgHom R A r }
#align submodule.pointwise_mul_semiring_action Submodule.pointwiseMulSemiringAction
-/

scoped[Pointwise] attribute [instance] Submodule.pointwiseMulSemiringAction

end

end Ring

section CommRing

variable {A : Type v} [CommSemiring A] [Algebra R A]

variable {M N : Submodule R A} {m n : A}

#print Submodule.mul_mem_mul_rev /-
theorem mul_mem_mul_rev (hm : m ∈ M) (hn : n ∈ N) : n * m ∈ M * N :=
  mul_comm m n ▸ mul_mem_mul hm hn
#align submodule.mul_mem_mul_rev Submodule.mul_mem_mul_rev
-/

variable (M N)

#print Submodule.mul_comm /-
protected theorem mul_comm : M * N = N * M :=
  le_antisymm (mul_le.2 fun r hrm s hsn => mul_mem_mul_rev hsn hrm)
    (mul_le.2 fun r hrn s hsm => mul_mem_mul_rev hsm hrn)
#align submodule.mul_comm Submodule.mul_comm
-/

/-- Sub-R-modules of an R-algebra A form a semiring. -/
instance : IdemCommSemiring (Submodule R A) :=
  { Submodule.idemSemiring with mul_comm := Submodule.mul_comm }

#print Submodule.prod_span /-
theorem prod_span {ι : Type _} (s : Finset ι) (M : ι → Set A) :
    ∏ i in s, Submodule.span R (M i) = Submodule.span R (∏ i in s, M i) :=
  by
  letI := Classical.decEq ι
  refine' Finset.induction_on s _ _
  · simp [one_eq_span, Set.singleton_one]
  · intro _ _ H ih
    rw [Finset.prod_insert H, Finset.prod_insert H, ih, span_mul_span]
#align submodule.prod_span Submodule.prod_span
-/

#print Submodule.prod_span_singleton /-
theorem prod_span_singleton {ι : Type _} (s : Finset ι) (x : ι → A) :
    ∏ i in s, span R ({x i} : Set A) = span R {∏ i in s, x i} := by
  rw [prod_span, Set.finset_prod_singleton]
#align submodule.prod_span_singleton Submodule.prod_span_singleton
-/

variable (R A)

#print Submodule.moduleSet /-
/-- R-submodules of the R-algebra A are a module over `set A`. -/
instance moduleSet : Module (SetSemiring A) (Submodule R A)
    where
  smul s P := span R s.down * P
  smul_add _ _ _ := mul_add _ _ _
  add_smul s t P := by simp_rw [SMul.smul, SetSemiring.down_add, span_union, sup_mul, add_eq_sup]
  mul_smul s t P := by simp_rw [SMul.smul, SetSemiring.down_mul, ← mul_assoc, span_mul_span]
  one_smul P := by simp_rw [SMul.smul, SetSemiring.down_one, ← one_eq_span_one_set, one_mul]
  zero_smul P := by simp_rw [SMul.smul, SetSemiring.down_zero, span_empty, bot_mul, bot_eq_zero]
  smul_zero _ := mul_bot _
#align submodule.module_set Submodule.moduleSet
-/

variable {R A}

#print Submodule.smul_def /-
theorem smul_def (s : SetSemiring A) (P : Submodule R A) : s • P = span R s.down * P :=
  rfl
#align submodule.smul_def Submodule.smul_def
-/

#print Submodule.smul_le_smul /-
theorem smul_le_smul {s t : SetSemiring A} {M N : Submodule R A} (h₁ : s.down ⊆ t.down)
    (h₂ : M ≤ N) : s • M ≤ t • N :=
  mul_le_mul (span_mono h₁) h₂
#align submodule.smul_le_smul Submodule.smul_le_smul
-/

#print Submodule.smul_singleton /-
theorem smul_singleton (a : A) (M : Submodule R A) :
    ({a} : Set A).up • M = M.map (LinearMap.mulLeft R a) :=
  by
  conv_lhs => rw [← span_eq M]
  change span _ _ * span _ _ = _
  rw [span_mul_span]
  apply le_antisymm
  · rw [span_le]
    rintro _ ⟨b, m, hb, hm, rfl⟩
    rw [SetLike.mem_coe, mem_map, set.mem_singleton_iff.mp hb]
    exact ⟨m, hm, rfl⟩
  · rintro _ ⟨m, hm, rfl⟩; exact subset_span ⟨a, m, Set.mem_singleton a, hm, rfl⟩
#align submodule.smul_singleton Submodule.smul_singleton
-/

section Quotient

/-- The elements of `I / J` are the `x` such that `x • J ⊆ I`.

In fact, we define `x ∈ I / J` to be `∀ y ∈ J, x * y ∈ I` (see `mem_div_iff_forall_mul_mem`),
which is equivalent to `x • J ⊆ I` (see `mem_div_iff_smul_subset`), but nicer to use in proofs.

This is the general form of the ideal quotient, traditionally written $I : J$.
-/
instance : Div (Submodule R A) :=
  ⟨fun I J =>
    { carrier := {x | ∀ y ∈ J, x * y ∈ I}
      zero_mem' := fun y hy => by rw [MulZeroClass.zero_mul]; apply Submodule.zero_mem
      add_mem' := fun a b ha hb y hy => by rw [add_mul];
        exact Submodule.add_mem _ (ha _ hy) (hb _ hy)
      smul_mem' := fun r x hx y hy => by
        rw [Algebra.smul_mul_assoc]
        exact Submodule.smul_mem _ _ (hx _ hy) }⟩

#print Submodule.mem_div_iff_forall_mul_mem /-
theorem mem_div_iff_forall_mul_mem {x : A} {I J : Submodule R A} : x ∈ I / J ↔ ∀ y ∈ J, x * y ∈ I :=
  Iff.refl _
#align submodule.mem_div_iff_forall_mul_mem Submodule.mem_div_iff_forall_mul_mem
-/

#print Submodule.mem_div_iff_smul_subset /-
theorem mem_div_iff_smul_subset {x : A} {I J : Submodule R A} : x ∈ I / J ↔ x • (J : Set A) ⊆ I :=
  ⟨fun h y ⟨y', hy', xy'_eq_y⟩ => by rw [← xy'_eq_y]; apply h; assumption, fun h y hy =>
    h (Set.smul_mem_smul_set hy)⟩
#align submodule.mem_div_iff_smul_subset Submodule.mem_div_iff_smul_subset
-/

#print Submodule.le_div_iff /-
theorem le_div_iff {I J K : Submodule R A} : I ≤ J / K ↔ ∀ x ∈ I, ∀ z ∈ K, x * z ∈ J :=
  Iff.refl _
#align submodule.le_div_iff Submodule.le_div_iff
-/

#print Submodule.le_div_iff_mul_le /-
theorem le_div_iff_mul_le {I J K : Submodule R A} : I ≤ J / K ↔ I * K ≤ J := by
  rw [le_div_iff, mul_le]
#align submodule.le_div_iff_mul_le Submodule.le_div_iff_mul_le
-/

#print Submodule.one_le_one_div /-
@[simp]
theorem one_le_one_div {I : Submodule R A} : 1 ≤ 1 / I ↔ I ≤ 1 :=
  by
  constructor; all_goals intro hI
  · rwa [le_div_iff_mul_le, one_mul] at hI 
  · rwa [le_div_iff_mul_le, one_mul]
#align submodule.one_le_one_div Submodule.one_le_one_div
-/

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:132:4: warning: unsupported: rw with cfg: { occs := occurrences.pos[occurrences.pos] «expr[ ,]»([1]) } -/
#print Submodule.le_self_mul_one_div /-
theorem le_self_mul_one_div {I : Submodule R A} (hI : I ≤ 1) : I ≤ I * (1 / I) :=
  by
  rw [← mul_one I]
  apply mul_le_mul_right (one_le_one_div.mpr hI)
#align submodule.le_self_mul_one_div Submodule.le_self_mul_one_div
-/

#print Submodule.mul_one_div_le_one /-
theorem mul_one_div_le_one {I : Submodule R A} : I * (1 / I) ≤ 1 :=
  by
  rw [Submodule.mul_le]
  intro m hm n hn
  rw [Submodule.mem_div_iff_forall_mul_mem] at hn 
  rw [mul_comm]
  exact hn m hm
#align submodule.mul_one_div_le_one Submodule.mul_one_div_le_one
-/

#print Submodule.map_div /-
@[simp]
protected theorem map_div {B : Type _} [CommSemiring B] [Algebra R B] (I J : Submodule R A)
    (h : A ≃ₐ[R] B) : (I / J).map h.toLinearMap = I.map h.toLinearMap / J.map h.toLinearMap :=
  by
  ext x
  simp only [mem_map, mem_div_iff_forall_mul_mem]
  constructor
  · rintro ⟨x, hx, rfl⟩ _ ⟨y, hy, rfl⟩
    exact ⟨x * y, hx _ hy, h.map_mul x y⟩
  · rintro hx
    refine' ⟨h.symm x, fun z hz => _, h.apply_symm_apply x⟩
    obtain ⟨xz, xz_mem, hxz⟩ := hx (h z) ⟨z, hz, rfl⟩
    convert xz_mem
    apply h.injective
    erw [h.map_mul, h.apply_symm_apply, hxz]
#align submodule.map_div Submodule.map_div
-/

end Quotient

end CommRing

end Submodule

