/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.monoid_algebra.grading
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Finsupp
import Mathbin.Algebra.MonoidAlgebra.Support
import Mathbin.Algebra.DirectSum.Internal
import Mathbin.RingTheory.GradedAlgebra.Basic

/-!
# Internal grading of an `add_monoid_algebra`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we show that an `add_monoid_algebra` has an internal direct sum structure.

## Main results

* `add_monoid_algebra.grade_by R f i`: the `i`th grade of an `add_monoid_algebra R M` given by the
  degree function `f`.
* `add_monoid_algebra.grade R i`: the `i`th grade of an `add_monoid_algebra R M` when the degree
  function is the identity.
* `add_monoid_algebra.grade_by.graded_algebra`: `add_monoid_algebra` is an algebra graded by
  `add_monoid_algebra.grade_by`.
* `add_monoid_algebra.grade.graded_algebra`: `add_monoid_algebra` is an algebra graded by
  `add_monoid_algebra.grade`.
* `add_monoid_algebra.grade_by.is_internal`: propositionally, the statement that
  `add_monoid_algebra.grade_by` defines an internal graded structure.
* `add_monoid_algebra.grade.is_internal`: propositionally, the statement that
  `add_monoid_algebra.grade` defines an internal graded structure when the degree function
  is the identity.
-/


noncomputable section

namespace AddMonoidAlgebra

variable {M : Type _} {ι : Type _} {R : Type _} [DecidableEq M]

section

variable (R) [CommSemiring R]

#print AddMonoidAlgebra.gradeBy /-
/-- The submodule corresponding to each grade given by the degree function `f`. -/
abbrev gradeBy (f : M → ι) (i : ι) : Submodule R (AddMonoidAlgebra R M) :=
  { carrier := {a | ∀ m, m ∈ a.support → f m = i}
    zero_mem' := Set.empty_subset _
    add_mem' := fun a b ha hb m h =>
      Or.rec_on (Finset.mem_union.mp (Finsupp.support_add h)) (ha m) (hb m)
    smul_mem' := fun a m h => Set.Subset.trans Finsupp.support_smul h }
#align add_monoid_algebra.grade_by AddMonoidAlgebra.gradeBy
-/

#print AddMonoidAlgebra.grade /-
/-- The submodule corresponding to each grade. -/
abbrev grade (m : M) : Submodule R (AddMonoidAlgebra R M) :=
  gradeBy R id m
#align add_monoid_algebra.grade AddMonoidAlgebra.grade
-/

#print AddMonoidAlgebra.gradeBy_id /-
theorem gradeBy_id : gradeBy R (id : M → M) = grade R := by rfl
#align add_monoid_algebra.grade_by_id AddMonoidAlgebra.gradeBy_id
-/

#print AddMonoidAlgebra.mem_gradeBy_iff /-
theorem mem_gradeBy_iff (f : M → ι) (i : ι) (a : AddMonoidAlgebra R M) :
    a ∈ gradeBy R f i ↔ (a.support : Set M) ⊆ f ⁻¹' {i} := by rfl
#align add_monoid_algebra.mem_grade_by_iff AddMonoidAlgebra.mem_gradeBy_iff
-/

#print AddMonoidAlgebra.mem_grade_iff /-
theorem mem_grade_iff (m : M) (a : AddMonoidAlgebra R M) : a ∈ grade R m ↔ a.support ⊆ {m} :=
  by
  rw [← Finset.coe_subset, Finset.coe_singleton]
  rfl
#align add_monoid_algebra.mem_grade_iff AddMonoidAlgebra.mem_grade_iff
-/

#print AddMonoidAlgebra.mem_grade_iff' /-
theorem mem_grade_iff' (m : M) (a : AddMonoidAlgebra R M) :
    a ∈ grade R m ↔
      a ∈ ((Finsupp.lsingle m : R →ₗ[R] M →₀ R).range : Submodule R (AddMonoidAlgebra R M)) :=
  by
  rw [mem_grade_iff, Finsupp.support_subset_singleton']
  apply exists_congr
  intro r
  constructor <;> exact Eq.symm
#align add_monoid_algebra.mem_grade_iff' AddMonoidAlgebra.mem_grade_iff'
-/

#print AddMonoidAlgebra.grade_eq_lsingle_range /-
theorem grade_eq_lsingle_range (m : M) : grade R m = (Finsupp.lsingle m : R →ₗ[R] M →₀ R).range :=
  Submodule.ext (mem_grade_iff' R m)
#align add_monoid_algebra.grade_eq_lsingle_range AddMonoidAlgebra.grade_eq_lsingle_range
-/

#print AddMonoidAlgebra.single_mem_gradeBy /-
theorem single_mem_gradeBy {R} [CommSemiring R] (f : M → ι) (m : M) (r : R) :
    Finsupp.single m r ∈ gradeBy R f (f m) :=
  by
  intro x hx
  rw [finset.mem_singleton.mp (Finsupp.support_single_subset hx)]
#align add_monoid_algebra.single_mem_grade_by AddMonoidAlgebra.single_mem_gradeBy
-/

#print AddMonoidAlgebra.single_mem_grade /-
theorem single_mem_grade {R} [CommSemiring R] (i : M) (r : R) : Finsupp.single i r ∈ grade R i :=
  single_mem_gradeBy _ _ _
#align add_monoid_algebra.single_mem_grade AddMonoidAlgebra.single_mem_grade
-/

end

open scoped DirectSum

#print AddMonoidAlgebra.gradeBy.gradedMonoid /-
instance gradeBy.gradedMonoid [AddMonoid M] [AddMonoid ι] [CommSemiring R] (f : M →+ ι) :
    SetLike.GradedMonoid (gradeBy R f : ι → Submodule R (AddMonoidAlgebra R M))
    where
  one_mem m h := by
    rw [one_def] at h 
    by_cases H : (1 : R) = (0 : R)
    · rw [H, Finsupp.single_zero] at h 
      exfalso
      exact h
    · rw [Finsupp.support_single_ne_zero _ H, Finset.mem_singleton] at h 
      rw [h, AddMonoidHom.map_zero]
  mul_mem i j a b ha hb c hc := by
    set h := support_mul a b hc
    simp only [Finset.mem_biUnion] at h 
    rcases h with ⟨ma, ⟨hma, ⟨mb, ⟨hmb, hmc⟩⟩⟩⟩
    rw [← ha ma hma, ← hb mb hmb, finset.mem_singleton.mp hmc]
    apply AddMonoidHom.map_add
#align add_monoid_algebra.grade_by.graded_monoid AddMonoidAlgebra.gradeBy.gradedMonoid
-/

#print AddMonoidAlgebra.grade.gradedMonoid /-
instance grade.gradedMonoid [AddMonoid M] [CommSemiring R] :
    SetLike.GradedMonoid (grade R : M → Submodule R (AddMonoidAlgebra R M)) := by
  apply grade_by.graded_monoid (AddMonoidHom.id _)
#align add_monoid_algebra.grade.graded_monoid AddMonoidAlgebra.grade.gradedMonoid
-/

variable {R} [AddMonoid M] [DecidableEq ι] [AddMonoid ι] [CommSemiring R] (f : M →+ ι)

#print AddMonoidAlgebra.decomposeAux /-
/-- Auxiliary definition; the canonical grade decomposition, used to provide
`direct_sum.decompose`. -/
def decomposeAux : AddMonoidAlgebra R M →ₐ[R] ⨁ i : ι, gradeBy R f i :=
  AddMonoidAlgebra.lift R M _
    { toFun := fun m =>
        DirectSum.of (fun i : ι => gradeBy R f i) (f m.toAdd)
          ⟨Finsupp.single m.toAdd 1, single_mem_gradeBy _ _ _⟩
      map_one' :=
        DirectSum.of_eq_of_gradedMonoid_eq
          (by
            congr 2 <;> try ext <;>
              simp only [Submodule.mem_toAddSubmonoid, toAdd_one, AddMonoidHom.map_zero])
      map_mul' := fun i j => by
        symm
        convert DirectSum.of_mul_of _ _
        apply DirectSum.of_eq_of_gradedMonoid_eq
        congr 2
        · rw [toAdd_mul, AddMonoidHom.map_add]
        · ext
          simp only [Submodule.mem_toAddSubmonoid, AddMonoidHom.map_add, toAdd_mul]
        · exact Eq.trans (by rw [one_mul, toAdd_mul]) single_mul_single.symm }
#align add_monoid_algebra.decompose_aux AddMonoidAlgebra.decomposeAux
-/

#print AddMonoidAlgebra.decomposeAux_single /-
theorem decomposeAux_single (m : M) (r : R) :
    decomposeAux f (Finsupp.single m r) =
      DirectSum.of (fun i : ι => gradeBy R f i) (f m)
        ⟨Finsupp.single m r, single_mem_gradeBy _ _ _⟩ :=
  by
  refine' (lift_single _ _ _).trans _
  refine' (DirectSum.of_smul _ _ _ _).symm.trans _
  apply DirectSum.of_eq_of_gradedMonoid_eq
  refine' Sigma.subtype_ext rfl _
  refine' (Finsupp.smul_single' _ _ _).trans _
  rw [mul_one]
  rfl
#align add_monoid_algebra.decompose_aux_single AddMonoidAlgebra.decomposeAux_single
-/

#print AddMonoidAlgebra.decomposeAux_coe /-
theorem decomposeAux_coe {i : ι} (x : gradeBy R f i) :
    decomposeAux f ↑x = DirectSum.of (fun i => gradeBy R f i) i x :=
  by
  obtain ⟨x, hx⟩ := x
  revert hx
  refine' Finsupp.induction x _ _
  · intro hx
    symm
    exact AddMonoidHom.map_zero _
  · intro m b y hmy hb ih hmby
    have : Disjoint (Finsupp.single m b).support y.support := by
      simpa only [Finsupp.support_single_ne_zero _ hb, Finset.disjoint_singleton_left]
    rw [mem_grade_by_iff, Finsupp.support_add_eq this, Finset.coe_union, Set.union_subset_iff] at
      hmby 
    cases' hmby with h1 h2
    have : f m = i := by
      rwa [Finsupp.support_single_ne_zero _ hb, Finset.coe_singleton, Set.singleton_subset_iff] at
        h1 
    subst this
    simp only [AlgHom.map_add, Submodule.coe_mk, decompose_aux_single f m]
    let ih' := ih h2
    dsimp at ih' 
    rw [ih', ← AddMonoidHom.map_add]
    apply DirectSum.of_eq_of_gradedMonoid_eq
    congr 2
#align add_monoid_algebra.decompose_aux_coe AddMonoidAlgebra.decomposeAux_coe
-/

#print AddMonoidAlgebra.gradeBy.gradedAlgebra /-
instance gradeBy.gradedAlgebra : GradedAlgebra (gradeBy R f) :=
  GradedAlgebra.ofAlgHom _ (decomposeAux f)
    (by
      ext : 2
      simp only [AlgHom.coe_toMonoidHom, Function.comp_apply, AlgHom.coe_comp,
        Function.comp.left_id, AlgHom.coe_id, AddMonoidAlgebra.of_apply, MonoidHom.coe_comp]
      rw [decompose_aux_single, DirectSum.coeAlgHom_of, Subtype.coe_mk])
    fun i x => by rw [decompose_aux_coe f x]
#align add_monoid_algebra.grade_by.graded_algebra AddMonoidAlgebra.gradeBy.gradedAlgebra
-/

#print AddMonoidAlgebra.gradeBy.decomposition /-
-- Lean can't find this later without us repeating it
instance gradeBy.decomposition : DirectSum.Decomposition (gradeBy R f) := by infer_instance
#align add_monoid_algebra.grade_by.decomposition AddMonoidAlgebra.gradeBy.decomposition
-/

#print AddMonoidAlgebra.decomposeAux_eq_decompose /-
@[simp]
theorem decomposeAux_eq_decompose :
    ⇑(decomposeAux f : AddMonoidAlgebra R M →ₐ[R] ⨁ i : ι, gradeBy R f i) =
      DirectSum.decompose (gradeBy R f) :=
  rfl
#align add_monoid_algebra.decompose_aux_eq_decompose AddMonoidAlgebra.decomposeAux_eq_decompose
-/

#print AddMonoidAlgebra.GradesBy.decompose_single /-
@[simp]
theorem GradesBy.decompose_single (m : M) (r : R) :
    DirectSum.decompose (gradeBy R f) (Finsupp.single m r : AddMonoidAlgebra R M) =
      DirectSum.of (fun i : ι => gradeBy R f i) (f m)
        ⟨Finsupp.single m r, single_mem_gradeBy _ _ _⟩ :=
  decomposeAux_single _ _ _
#align add_monoid_algebra.grades_by.decompose_single AddMonoidAlgebra.GradesBy.decompose_single
-/

#print AddMonoidAlgebra.grade.gradedAlgebra /-
instance grade.gradedAlgebra : GradedAlgebra (grade R : ι → Submodule _ _) :=
  AddMonoidAlgebra.gradeBy.gradedAlgebra (AddMonoidHom.id _)
#align add_monoid_algebra.grade.graded_algebra AddMonoidAlgebra.grade.gradedAlgebra
-/

#print AddMonoidAlgebra.grade.decomposition /-
-- Lean can't find this later without us repeating it
instance grade.decomposition : DirectSum.Decomposition (grade R : ι → Submodule _ _) := by
  infer_instance
#align add_monoid_algebra.grade.decomposition AddMonoidAlgebra.grade.decomposition
-/

#print AddMonoidAlgebra.grade.decompose_single /-
@[simp]
theorem grade.decompose_single (i : ι) (r : R) :
    DirectSum.decompose (grade R : ι → Submodule _ _) (Finsupp.single i r : AddMonoidAlgebra _ _) =
      DirectSum.of (fun i : ι => grade R i) i ⟨Finsupp.single i r, single_mem_grade _ _⟩ :=
  decomposeAux_single _ _ _
#align add_monoid_algebra.grade.decompose_single AddMonoidAlgebra.grade.decompose_single
-/

#print AddMonoidAlgebra.gradeBy.isInternal /-
/-- `add_monoid_algebra.gradesby` describe an internally graded algebra -/
theorem gradeBy.isInternal : DirectSum.IsInternal (gradeBy R f) :=
  DirectSum.Decomposition.isInternal _
#align add_monoid_algebra.grade_by.is_internal AddMonoidAlgebra.gradeBy.isInternal
-/

#print AddMonoidAlgebra.grade.isInternal /-
/-- `add_monoid_algebra.grades` describe an internally graded algebra -/
theorem grade.isInternal : DirectSum.IsInternal (grade R : ι → Submodule R _) :=
  DirectSum.Decomposition.isInternal _
#align add_monoid_algebra.grade.is_internal AddMonoidAlgebra.grade.isInternal
-/

end AddMonoidAlgebra

