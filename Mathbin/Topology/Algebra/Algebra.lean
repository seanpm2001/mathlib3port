/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Scott Morrison

! This file was ported from Lean 3 source module topology.algebra.algebra
! leanprover-community/mathlib commit 75be6b616681ab6ca66d798ead117e75cd64f125
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Subalgebra.Basic
import Mathbin.Topology.Algebra.Module.Basic
import Mathbin.RingTheory.Adjoin.Basic

/-!
# Topological (sub)algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A topological algebra over a topological semiring `R` is a topological semiring with a compatible
continuous scalar multiplication by elements of `R`. We reuse typeclass `has_continuous_smul` for
topological algebras.

## Results

This is just a minimal stub for now!

The topological closure of a subalgebra is still a subalgebra,
which as an algebra is a topological algebra.
-/


open Classical Set TopologicalSpace Algebra

open scoped Classical

universe u v w

section TopologicalAlgebra

variable (R : Type _) (A : Type u)

variable [CommSemiring R] [Semiring A] [Algebra R A]

variable [TopologicalSpace R] [TopologicalSpace A] [TopologicalSemiring A]

#print continuous_algebraMap_iff_smul /-
theorem continuous_algebraMap_iff_smul :
    Continuous (algebraMap R A) ↔ Continuous fun p : R × A => p.1 • p.2 :=
  by
  refine' ⟨fun h => _, fun h => _⟩
  · simp only [Algebra.smul_def]; exact (h.comp continuous_fst).mul continuous_snd
  · rw [algebra_map_eq_smul_one']; exact h.comp (continuous_id.prod_mk continuous_const)
#align continuous_algebra_map_iff_smul continuous_algebraMap_iff_smul
-/

#print continuous_algebraMap /-
@[continuity]
theorem continuous_algebraMap [ContinuousSMul R A] : Continuous (algebraMap R A) :=
  (continuous_algebraMap_iff_smul R A).2 continuous_smul
#align continuous_algebra_map continuous_algebraMap
-/

#print continuousSMul_of_algebraMap /-
theorem continuousSMul_of_algebraMap (h : Continuous (algebraMap R A)) : ContinuousSMul R A :=
  ⟨(continuous_algebraMap_iff_smul R A).1 h⟩
#align has_continuous_smul_of_algebra_map continuousSMul_of_algebraMap
-/

variable [ContinuousSMul R A]

#print algebraMapClm /-
/-- The inclusion of the base ring in a topological algebra as a continuous linear map. -/
@[simps]
def algebraMapClm : R →L[R] A :=
  { Algebra.linearMap R A with
    toFun := algebraMap R A
    cont := continuous_algebraMap R A }
#align algebra_map_clm algebraMapClm
-/

#print algebraMapClm_coe /-
theorem algebraMapClm_coe : ⇑(algebraMapClm R A) = algebraMap R A :=
  rfl
#align algebra_map_clm_coe algebraMapClm_coe
-/

#print algebraMapClm_toLinearMap /-
theorem algebraMapClm_toLinearMap : (algebraMapClm R A).toLinearMap = Algebra.linearMap R A :=
  rfl
#align algebra_map_clm_to_linear_map algebraMapClm_toLinearMap
-/

end TopologicalAlgebra

section TopologicalAlgebra

variable {R : Type _} [CommSemiring R]

variable {A : Type u} [TopologicalSpace A]

variable [Semiring A] [Algebra R A]

#print Subalgebra.continuousSMul /-
instance Subalgebra.continuousSMul [TopologicalSpace R] [ContinuousSMul R A] (s : Subalgebra R A) :
    ContinuousSMul R s :=
  s.toSubmodule.ContinuousSMul
#align subalgebra.has_continuous_smul Subalgebra.continuousSMul
-/

variable [TopologicalSemiring A]

#print Subalgebra.topologicalClosure /-
/-- The closure of a subalgebra in a topological algebra as a subalgebra. -/
def Subalgebra.topologicalClosure (s : Subalgebra R A) : Subalgebra R A :=
  {
    s.toSubsemiring.topologicalClosure with
    carrier := closure (s : Set A)
    algebraMap_mem' := fun r => s.toSubsemiring.le_topologicalClosure (s.algebraMap_mem r) }
#align subalgebra.topological_closure Subalgebra.topologicalClosure
-/

#print Subalgebra.topologicalClosure_coe /-
@[simp]
theorem Subalgebra.topologicalClosure_coe (s : Subalgebra R A) :
    (s.topologicalClosure : Set A) = closure (s : Set A) :=
  rfl
#align subalgebra.topological_closure_coe Subalgebra.topologicalClosure_coe
-/

#print Subalgebra.topologicalSemiring /-
instance Subalgebra.topologicalSemiring (s : Subalgebra R A) : TopologicalSemiring s :=
  s.toSubsemiring.TopologicalSemiring
#align subalgebra.topological_semiring Subalgebra.topologicalSemiring
-/

#print Subalgebra.le_topologicalClosure /-
theorem Subalgebra.le_topologicalClosure (s : Subalgebra R A) : s ≤ s.topologicalClosure :=
  subset_closure
#align subalgebra.le_topological_closure Subalgebra.le_topologicalClosure
-/

#print Subalgebra.isClosed_topologicalClosure /-
theorem Subalgebra.isClosed_topologicalClosure (s : Subalgebra R A) :
    IsClosed (s.topologicalClosure : Set A) := by convert isClosed_closure
#align subalgebra.is_closed_topological_closure Subalgebra.isClosed_topologicalClosure
-/

#print Subalgebra.topologicalClosure_minimal /-
theorem Subalgebra.topologicalClosure_minimal (s : Subalgebra R A) {t : Subalgebra R A} (h : s ≤ t)
    (ht : IsClosed (t : Set A)) : s.topologicalClosure ≤ t :=
  closure_minimal h ht
#align subalgebra.topological_closure_minimal Subalgebra.topologicalClosure_minimal
-/

#print Subalgebra.commSemiringTopologicalClosure /-
/-- If a subalgebra of a topological algebra is commutative, then so is its topological closure. -/
def Subalgebra.commSemiringTopologicalClosure [T2Space A] (s : Subalgebra R A)
    (hs : ∀ x y : s, x * y = y * x) : CommSemiring s.topologicalClosure :=
  { s.topologicalClosure.toSemiring, s.toSubmonoid.commMonoidTopologicalClosure hs with }
#align subalgebra.comm_semiring_topological_closure Subalgebra.commSemiringTopologicalClosure
-/

#print Subalgebra.topologicalClosure_comap_homeomorph /-
/-- This is really a statement about topological algebra isomorphisms,
but we don't have those, so we use the clunky approach of talking about
an algebra homomorphism, and a separate homeomorphism,
along with a witness that as functions they are the same.
-/
theorem Subalgebra.topologicalClosure_comap_homeomorph (s : Subalgebra R A) {B : Type _}
    [TopologicalSpace B] [Ring B] [TopologicalRing B] [Algebra R B] (f : B →ₐ[R] A) (f' : B ≃ₜ A)
    (w : (f : B → A) = f') : s.topologicalClosure.comap f = (s.comap f).topologicalClosure :=
  by
  apply SetLike.ext'
  simp only [Subalgebra.topologicalClosure_coe]
  simp only [Subalgebra.coe_comap, Subsemiring.coe_comap, AlgHom.coe_toRingHom]
  rw [w]
  exact f'.preimage_closure _
#align subalgebra.topological_closure_comap_homeomorph Subalgebra.topologicalClosure_comap_homeomorph
-/

end TopologicalAlgebra

section Ring

variable {R : Type _} [CommRing R]

variable {A : Type u} [TopologicalSpace A]

variable [Ring A]

variable [Algebra R A] [TopologicalRing A]

#print Subalgebra.commRingTopologicalClosure /-
/-- If a subalgebra of a topological algebra is commutative, then so is its topological closure.
See note [reducible non-instances]. -/
@[reducible]
def Subalgebra.commRingTopologicalClosure [T2Space A] (s : Subalgebra R A)
    (hs : ∀ x y : s, x * y = y * x) : CommRing s.topologicalClosure :=
  { s.topologicalClosure.toRing, s.toSubmonoid.commMonoidTopologicalClosure hs with }
#align subalgebra.comm_ring_topological_closure Subalgebra.commRingTopologicalClosure
-/

variable (R)

#print Algebra.elementalAlgebra /-
/-- The topological closure of the subalgebra generated by a single element. -/
def Algebra.elementalAlgebra (x : A) : Subalgebra R A :=
  (Algebra.adjoin R ({x} : Set A)).topologicalClosure
#align algebra.elemental_algebra Algebra.elementalAlgebra
-/

#print Algebra.self_mem_elementalAlgebra /-
theorem Algebra.self_mem_elementalAlgebra (x : A) : x ∈ Algebra.elementalAlgebra R x :=
  SetLike.le_def.mp (Subalgebra.le_topologicalClosure (Algebra.adjoin R ({x} : Set A))) <|
    Algebra.self_mem_adjoin_singleton R x
#align algebra.self_mem_elemental_algebra Algebra.self_mem_elementalAlgebra
-/

variable {R}

instance [T2Space A] {x : A} : CommRing (Algebra.elementalAlgebra R x) :=
  Subalgebra.commRingTopologicalClosure _
    letI : CommRing (Algebra.adjoin R ({x} : Set A)) :=
      Algebra.adjoinCommRingOfComm R fun y hy z hz => by rw [mem_singleton_iff] at hy hz ;
        rw [hy, hz]
    fun _ _ => mul_comm _ _

end Ring

section DivisionRing

#print DivisionRing.continuousConstSMul_rat /-
/-- The action induced by `algebra_rat` is continuous. -/
instance DivisionRing.continuousConstSMul_rat {A} [DivisionRing A] [TopologicalSpace A]
    [ContinuousMul A] [CharZero A] : ContinuousConstSMul ℚ A :=
  ⟨fun r => by simpa only [Algebra.smul_def] using continuous_const.mul continuous_id⟩
#align division_ring.has_continuous_const_smul_rat DivisionRing.continuousConstSMul_rat
-/

end DivisionRing

