/-
Copyright (c) 2023 Xavier Roblot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Xavier Roblot

! This file was ported from Lean 3 source module algebra.module.zlattice
! leanprover-community/mathlib commit 660b3a2db3522fa0db036e569dc995a615c4c848
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Group.FundamentalDomain

/-!
# ℤ-lattices

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Let `E` be a finite dimensional vector space over a `normed_linear_ordered_field` `K` with a solid
norm and that is also a `floor_ring`, e.g. `ℚ` or `ℝ`. A (full) ℤ-lattice `L` of `E` is a discrete
subgroup of `E` such that `L` spans `E` over `K`.

The ℤ-lattice `L` can be defined in two ways:
* For `b` a basis of `E`, then `submodule.span ℤ (set.range b)` is a ℤ-lattice of `E`.
* As an `add_subgroup E` with the additional properties:
  `∀ r : ℝ, (L ∩ metric.closed_ball 0 r).finite`, that is `L` is discrete
  `submodule.span ℝ (L : set E) = ⊤`, that is `L` spans `E` over `K`.

## Main result
* `zspan.is_add_fundamental_domain`: for a ℤ-lattice `submodule.span ℤ (set.range b)`, proves that
the set defined by `zspan.fundamental_domain` is a fundamental domain.

-/


open scoped BigOperators

noncomputable section

namespace Zspan

open MeasureTheory MeasurableSet Submodule

variable {E ι : Type _}

section NormedLatticeField

variable {K : Type _} [NormedLinearOrderedField K]

variable [NormedAddCommGroup E] [NormedSpace K E]

variable (b : Basis ι K E)

#print Zspan.fundamentalDomain /-
/-- The fundamental domain of the ℤ-lattice spanned by `b`. See `zspan.is_add_fundamental_domain`
for the proof that it is the fundamental domain. -/
def fundamentalDomain : Set E :=
  {m | ∀ i, b.repr m i ∈ Set.Ico (0 : K) 1}
#align zspan.fundamental_domain Zspan.fundamentalDomain
-/

#print Zspan.mem_fundamentalDomain /-
@[simp]
theorem mem_fundamentalDomain {m : E} :
    m ∈ fundamentalDomain b ↔ ∀ i, b.repr m i ∈ Set.Ico (0 : K) 1 :=
  Iff.rfl
#align zspan.mem_fundamental_domain Zspan.mem_fundamentalDomain
-/

variable [FloorRing K]

section Fintype

variable [Fintype ι]

#print Zspan.floor /-
/-- The map that sends a vector of `E` to the element of the ℤ-lattice spanned by `b` obtained
by rounding down its coordinates on the basis `b`. -/
def floor (m : E) : span ℤ (Set.range b) :=
  ∑ i, ⌊b.repr m i⌋ • b.restrictScalars ℤ i
#align zspan.floor Zspan.floor
-/

#print Zspan.ceil /-
/-- The map that sends a vector of `E` to the element of the ℤ-lattice spanned by `b` obtained
by rounding up its coordinates on the basis `b`. -/
def ceil (m : E) : span ℤ (Set.range b) :=
  ∑ i, ⌈b.repr m i⌉ • b.restrictScalars ℤ i
#align zspan.ceil Zspan.ceil
-/

#print Zspan.repr_floor_apply /-
@[simp]
theorem repr_floor_apply (m : E) (i : ι) : b.repr (floor b m) i = ⌊b.repr m i⌋ := by
  classical simp only [floor, zsmul_eq_smul_cast K, b.repr.map_smul, Finsupp.single_apply,
    Finset.sum_apply', Basis.repr_self, Finsupp.smul_single', mul_one, Finset.sum_ite_eq', coe_sum,
    Finset.mem_univ, if_true, coe_smul_of_tower, Basis.restrictScalars_apply, LinearEquiv.map_sum]
#align zspan.repr_floor_apply Zspan.repr_floor_apply
-/

#print Zspan.repr_ceil_apply /-
@[simp]
theorem repr_ceil_apply (m : E) (i : ι) : b.repr (ceil b m) i = ⌈b.repr m i⌉ := by
  classical simp only [ceil, zsmul_eq_smul_cast K, b.repr.map_smul, Finsupp.single_apply,
    Finset.sum_apply', Basis.repr_self, Finsupp.smul_single', mul_one, Finset.sum_ite_eq', coe_sum,
    Finset.mem_univ, if_true, coe_smul_of_tower, Basis.restrictScalars_apply, LinearEquiv.map_sum]
#align zspan.repr_ceil_apply Zspan.repr_ceil_apply
-/

#print Zspan.floor_eq_self_of_mem /-
@[simp]
theorem floor_eq_self_of_mem (m : E) (h : m ∈ span ℤ (Set.range b)) : (floor b m : E) = m :=
  by
  apply b.ext_elem
  simp_rw [repr_floor_apply b]
  intro i
  obtain ⟨z, hz⟩ := (b.mem_span_iff_repr_mem ℤ _).mp h i
  rw [← hz]
  exact congr_arg (coe : ℤ → K) (Int.floor_intCast z)
#align zspan.floor_eq_self_of_mem Zspan.floor_eq_self_of_mem
-/

#print Zspan.ceil_eq_self_of_mem /-
@[simp]
theorem ceil_eq_self_of_mem (m : E) (h : m ∈ span ℤ (Set.range b)) : (ceil b m : E) = m :=
  by
  apply b.ext_elem
  simp_rw [repr_ceil_apply b]
  intro i
  obtain ⟨z, hz⟩ := (b.mem_span_iff_repr_mem ℤ _).mp h i
  rw [← hz]
  exact congr_arg (coe : ℤ → K) (Int.ceil_intCast z)
#align zspan.ceil_eq_self_of_mem Zspan.ceil_eq_self_of_mem
-/

#print Zspan.fract /-
/-- The map that sends a vector `E` to the fundamental domain of the lattice,
see `zspan.fract_mem_fundamental_domain`. -/
def fract (m : E) : E :=
  m - floor b m
#align zspan.fract Zspan.fract
-/

#print Zspan.fract_apply /-
theorem fract_apply (m : E) : fract b m = m - floor b m :=
  rfl
#align zspan.fract_apply Zspan.fract_apply
-/

#print Zspan.repr_fract_apply /-
@[simp]
theorem repr_fract_apply (m : E) (i : ι) : b.repr (fract b m) i = Int.fract (b.repr m i) := by
  rw [fract, map_sub, Finsupp.coe_sub, Pi.sub_apply, repr_floor_apply, Int.fract]
#align zspan.repr_fract_apply Zspan.repr_fract_apply
-/

#print Zspan.fract_fract /-
@[simp]
theorem fract_fract (m : E) : fract b (fract b m) = fract b m :=
  Basis.ext_elem b fun _ => by classical simp only [repr_fract_apply, Int.fract_fract]
#align zspan.fract_fract Zspan.fract_fract
-/

#print Zspan.fract_zspan_add /-
@[simp]
theorem fract_zspan_add (m : E) {v : E} (h : v ∈ span ℤ (Set.range b)) :
    fract b (v + m) = fract b m := by
  classical
  refine' (Basis.ext_elem_iff b).mpr fun i => _
  simp_rw [repr_fract_apply, Int.fract_eq_fract]
  use (b.restrict_scalars ℤ).repr ⟨v, h⟩ i
  rw [map_add, Finsupp.coe_add, Pi.add_apply, add_tsub_cancel_right, ←
    eq_intCast (algebraMap ℤ K) _, Basis.restrictScalars_repr_apply, coe_mk]
#align zspan.fract_zspan_add Zspan.fract_zspan_add
-/

#print Zspan.fract_add_zspan /-
@[simp]
theorem fract_add_zspan (m : E) {v : E} (h : v ∈ span ℤ (Set.range b)) :
    fract b (m + v) = fract b m := by rw [add_comm, fract_zspan_add b m h]
#align zspan.fract_add_zspan Zspan.fract_add_zspan
-/

variable {b}

#print Zspan.fract_eq_self /-
theorem fract_eq_self {x : E} : fract b x = x ↔ x ∈ fundamentalDomain b := by
  classical simp only [Basis.ext_elem_iff b, repr_fract_apply, Int.fract_eq_self,
    mem_fundamental_domain, Set.mem_Ico]
#align zspan.fract_eq_self Zspan.fract_eq_self
-/

variable (b)

#print Zspan.fract_mem_fundamentalDomain /-
theorem fract_mem_fundamentalDomain (x : E) : fract b x ∈ fundamentalDomain b :=
  fract_eq_self.mp (fract_fract b _)
#align zspan.fract_mem_fundamental_domain Zspan.fract_mem_fundamentalDomain
-/

#print Zspan.fract_eq_fract /-
theorem fract_eq_fract (m n : E) : fract b m = fract b n ↔ -m + n ∈ span ℤ (Set.range b) := by
  classical
  rw [eq_comm, Basis.ext_elem_iff b]
  simp_rw [repr_fract_apply, Int.fract_eq_fract, eq_comm, Basis.mem_span_iff_repr_mem,
    sub_eq_neg_add, map_add, LinearEquiv.map_neg, Finsupp.coe_add, Finsupp.coe_neg, Pi.add_apply,
    Pi.neg_apply, ← eq_intCast (algebraMap ℤ K) _, Set.mem_range]
#align zspan.fract_eq_fract Zspan.fract_eq_fract
-/

#print Zspan.norm_fract_le /-
theorem norm_fract_le [HasSolidNorm K] (m : E) : ‖fract b m‖ ≤ ∑ i, ‖b i‖ := by
  classical
  calc
    ‖fract b m‖ = ‖∑ i, b.repr (fract b m) i • b i‖ := by rw [b.sum_repr]
    _ = ‖∑ i, Int.fract (b.repr m i) • b i‖ := by simp_rw [repr_fract_apply]
    _ ≤ ∑ i, ‖Int.fract (b.repr m i) • b i‖ := (norm_sum_le _ _)
    _ ≤ ∑ i, ‖Int.fract (b.repr m i)‖ * ‖b i‖ := by simp_rw [norm_smul]
    _ ≤ ∑ i, ‖b i‖ := Finset.sum_le_sum fun i _ => _
  suffices ‖Int.fract ((b.repr m) i)‖ ≤ 1
    by
    convert mul_le_mul_of_nonneg_right this (norm_nonneg _ : 0 ≤ ‖b i‖)
    exact (one_mul _).symm
  rw [(norm_one.symm : 1 = ‖(1 : K)‖)]
  apply norm_le_norm_of_abs_le_abs
  rw [abs_one, Int.abs_fract]
  exact le_of_lt (Int.fract_lt_one _)
#align zspan.norm_fract_le Zspan.norm_fract_le
-/

section Unique

variable [Unique ι]

#print Zspan.coe_floor_self /-
@[simp]
theorem coe_floor_self (k : K) : (floor (Basis.singleton ι K) k : K) = ⌊k⌋ :=
  Basis.ext_elem _ fun _ => by rw [repr_floor_apply, Basis.singleton_repr, Basis.singleton_repr]
#align zspan.coe_floor_self Zspan.coe_floor_self
-/

#print Zspan.coe_fract_self /-
@[simp]
theorem coe_fract_self (k : K) : (fract (Basis.singleton ι K) k : K) = Int.fract k :=
  Basis.ext_elem _ fun _ => by rw [repr_fract_apply, Basis.singleton_repr, Basis.singleton_repr]
#align zspan.coe_fract_self Zspan.coe_fract_self
-/

end Unique

end Fintype

#print Zspan.fundamentalDomain_bounded /-
theorem fundamentalDomain_bounded [Finite ι] [HasSolidNorm K] :
    Metric.Bounded (fundamentalDomain b) :=
  by
  cases nonempty_fintype ι
  use 2 * ∑ j, ‖b j‖
  intro x hx y hy
  refine' le_trans (dist_le_norm_add_norm x y) _
  rw [← fract_eq_self.mpr hx, ← fract_eq_self.mpr hy]
  refine' (add_le_add (norm_fract_le b x) (norm_fract_le b y)).trans _
  rw [← two_mul]
#align zspan.fundamental_domain_bounded Zspan.fundamentalDomain_bounded
-/

#print Zspan.vadd_mem_fundamentalDomain /-
theorem vadd_mem_fundamentalDomain [Fintype ι] (y : span ℤ (Set.range b)) (x : E) :
    y +ᵥ x ∈ fundamentalDomain b ↔ y = -floor b x := by
  rw [Subtype.ext_iff, ← add_right_inj x, AddSubgroupClass.coe_neg, ← sub_eq_add_neg, ← fract_apply,
    ← fract_zspan_add b _ (Subtype.mem y), add_comm, ← vadd_eq_add, ← vadd_def, eq_comm, ←
    fract_eq_self]
#align zspan.vadd_mem_fundamental_domain Zspan.vadd_mem_fundamentalDomain
-/

#print Zspan.exist_unique_vadd_mem_fundamentalDomain /-
theorem exist_unique_vadd_mem_fundamentalDomain [Finite ι] (x : E) :
    ∃! v : span ℤ (Set.range b), v +ᵥ x ∈ fundamentalDomain b :=
  by
  cases nonempty_fintype ι
  refine' ⟨-floor b x, _, fun y h => _⟩
  · exact (vadd_mem_fundamental_domain b (-floor b x) x).mpr rfl
  · exact (vadd_mem_fundamental_domain b y x).mp h
#align zspan.exist_unique_vadd_mem_fundamental_domain Zspan.exist_unique_vadd_mem_fundamentalDomain
-/

end NormedLatticeField

section Real

variable [NormedAddCommGroup E] [NormedSpace ℝ E]

variable (b : Basis ι ℝ E)

#print Zspan.fundamentalDomain_measurableSet /-
@[measurability]
theorem fundamentalDomain_measurableSet [MeasurableSpace E] [OpensMeasurableSpace E] [Finite ι] :
    MeasurableSet (fundamentalDomain b) :=
  by
  haveI : FiniteDimensional ℝ E := FiniteDimensional.of_fintype_basis b
  let f := (Finsupp.linearEquivFunOnFinite ℝ ℝ ι).toLinearMap.comp b.repr.to_linear_map
  let D : Set (ι → ℝ) := Set.pi Set.univ fun i : ι => Set.Ico (0 : ℝ) 1
  rw [(_ : fundamental_domain b = f ⁻¹' D)]
  · refine' measurableSet_preimage (LinearMap.continuous_of_finiteDimensional f).Measurable _
    exact pi set.univ.to_countable fun (i : ι) (H : i ∈ Set.univ) => measurableSet_Ico
  · ext
    simp only [fundamental_domain, Set.mem_setOf_eq, LinearMap.coe_comp,
      LinearEquiv.coe_toLinearMap, Set.mem_preimage, Function.comp_apply, Set.mem_univ_pi,
      Finsupp.linearEquivFunOnFinite_apply]
#align zspan.fundamental_domain_measurable_set Zspan.fundamentalDomain_measurableSet
-/

#print Zspan.isAddFundamentalDomain /-
/-- For a ℤ-lattice `submodule.span ℤ (set.range b)`, proves that the set defined
by `zspan.fundamental_domain` is a fundamental domain. -/
protected theorem isAddFundamentalDomain [Finite ι] [MeasurableSpace E] [OpensMeasurableSpace E]
    (μ : Measure E) :
    IsAddFundamentalDomain (span ℤ (Set.range b)).toAddSubgroup (fundamentalDomain b) μ :=
  by
  cases nonempty_fintype ι
  exact
    is_add_fundamental_domain.mk' (null_measurable_set (fundamental_domain_measurable_set b))
      fun x => exist_unique_vadd_mem_fundamental_domain b x
#align zspan.is_add_fundamental_domain Zspan.isAddFundamentalDomain
-/

end Real

end Zspan

