/-
Copyright (c) 2022 Jireh Loreaux. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jireh Loreaux

! This file was ported from Lean 3 source module topology.algebra.star_subalgebra
! leanprover-community/mathlib commit 19cb3751e5e9b3d97adb51023949c50c13b5fdfd
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Star.Subalgebra
import Mathbin.Topology.Algebra.Algebra
import Mathbin.Topology.Algebra.Star

/-!
# Topological star (sub)algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A topological star algebra over a topological semiring `R` is a topological semiring with a
compatible continuous scalar multiplication by elements of `R` and a continuous star operation.
We reuse typeclass `has_continuous_smul` for topological algebras.

## Results

This is just a minimal stub for now!

The topological closure of a star subalgebra is still a star subalgebra,
which as a star algebra is a topological star algebra.
-/


open Classical Set TopologicalSpace

open scoped Classical

namespace StarSubalgebra

section TopologicalStarAlgebra

variable {R A B : Type _} [CommSemiring R] [StarRing R]

variable [TopologicalSpace A] [Semiring A] [Algebra R A] [StarRing A] [StarModule R A]

instance [TopologicalSpace R] [ContinuousSMul R A] (s : StarSubalgebra R A) : ContinuousSMul R s :=
  s.toSubalgebra.ContinuousSMul

instance [TopologicalSemiring A] (s : StarSubalgebra R A) : TopologicalSemiring s :=
  s.toSubalgebra.TopologicalSemiring

#print StarSubalgebra.embedding_inclusion /-
/-- The `star_subalgebra.inclusion` of a star subalgebra is an `embedding`. -/
theorem embedding_inclusion {S₁ S₂ : StarSubalgebra R A} (h : S₁ ≤ S₂) : Embedding (inclusion h) :=
  { induced := Eq.symm induced_compose
    inj := Subtype.map_injective h Function.injective_id }
#align star_subalgebra.embedding_inclusion StarSubalgebra.embedding_inclusion
-/

#print StarSubalgebra.closedEmbedding_inclusion /-
/-- The `star_subalgebra.inclusion` of a closed star subalgebra is a `closed_embedding`. -/
theorem closedEmbedding_inclusion {S₁ S₂ : StarSubalgebra R A} (h : S₁ ≤ S₂)
    (hS₁ : IsClosed (S₁ : Set A)) : ClosedEmbedding (inclusion h) :=
  { embedding_inclusion h with
    closed_range :=
      isClosed_induced_iff.2
        ⟨S₁, hS₁, by convert (Set.range_subtype_map id _).symm; rw [Set.image_id]; rfl⟩ }
#align star_subalgebra.closed_embedding_inclusion StarSubalgebra.closedEmbedding_inclusion
-/

variable [TopologicalSemiring A] [ContinuousStar A]

variable [TopologicalSpace B] [Semiring B] [Algebra R B] [StarRing B]

#print StarSubalgebra.topologicalClosure /-
/-- The closure of a star subalgebra in a topological star algebra as a star subalgebra. -/
def topologicalClosure (s : StarSubalgebra R A) : StarSubalgebra R A :=
  {
    s.toSubalgebra.topologicalClosure with
    carrier := closure (s : Set A)
    star_mem' := fun a ha =>
      map_mem_closure continuous_star ha fun x => (star_mem : x ∈ s → star x ∈ s) }
#align star_subalgebra.topological_closure StarSubalgebra.topologicalClosure
-/

#print StarSubalgebra.topologicalClosure_coe /-
@[simp]
theorem topologicalClosure_coe (s : StarSubalgebra R A) :
    (s.topologicalClosure : Set A) = closure (s : Set A) :=
  rfl
#align star_subalgebra.topological_closure_coe StarSubalgebra.topologicalClosure_coe
-/

#print StarSubalgebra.le_topologicalClosure /-
theorem le_topologicalClosure (s : StarSubalgebra R A) : s ≤ s.topologicalClosure :=
  subset_closure
#align star_subalgebra.le_topological_closure StarSubalgebra.le_topologicalClosure
-/

#print StarSubalgebra.isClosed_topologicalClosure /-
theorem isClosed_topologicalClosure (s : StarSubalgebra R A) :
    IsClosed (s.topologicalClosure : Set A) :=
  isClosed_closure
#align star_subalgebra.is_closed_topological_closure StarSubalgebra.isClosed_topologicalClosure
-/

instance {A : Type _} [UniformSpace A] [CompleteSpace A] [Semiring A] [StarRing A]
    [TopologicalSemiring A] [ContinuousStar A] [Algebra R A] [StarModule R A]
    {S : StarSubalgebra R A} : CompleteSpace S.topologicalClosure :=
  isClosed_closure.completeSpace_coe

#print StarSubalgebra.topologicalClosure_minimal /-
theorem topologicalClosure_minimal {s t : StarSubalgebra R A} (h : s ≤ t)
    (ht : IsClosed (t : Set A)) : s.topologicalClosure ≤ t :=
  closure_minimal h ht
#align star_subalgebra.topological_closure_minimal StarSubalgebra.topologicalClosure_minimal
-/

#print StarSubalgebra.topologicalClosure_mono /-
theorem topologicalClosure_mono : Monotone (topologicalClosure : _ → StarSubalgebra R A) :=
  fun S₁ S₂ h =>
  topologicalClosure_minimal (h.trans <| le_topologicalClosure S₂) (isClosed_topologicalClosure S₂)
#align star_subalgebra.topological_closure_mono StarSubalgebra.topologicalClosure_mono
-/

#print StarSubalgebra.commSemiringTopologicalClosure /-
/-- If a star subalgebra of a topological star algebra is commutative, then so is its topological
closure. See note [reducible non-instances]. -/
@[reducible]
def commSemiringTopologicalClosure [T2Space A] (s : StarSubalgebra R A)
    (hs : ∀ x y : s, x * y = y * x) : CommSemiring s.topologicalClosure :=
  s.toSubalgebra.commSemiringTopologicalClosure hs
#align star_subalgebra.comm_semiring_topological_closure StarSubalgebra.commSemiringTopologicalClosure
-/

#print StarSubalgebra.commRingTopologicalClosure /-
/-- If a star subalgebra of a topological star algebra is commutative, then so is its topological
closure. See note [reducible non-instances]. -/
@[reducible]
def commRingTopologicalClosure {R A} [CommRing R] [StarRing R] [TopologicalSpace A] [Ring A]
    [Algebra R A] [StarRing A] [StarModule R A] [TopologicalRing A] [ContinuousStar A] [T2Space A]
    (s : StarSubalgebra R A) (hs : ∀ x y : s, x * y = y * x) : CommRing s.topologicalClosure :=
  s.toSubalgebra.commRingTopologicalClosure hs
#align star_subalgebra.comm_ring_topological_closure StarSubalgebra.commRingTopologicalClosure
-/

#print StarAlgHom.ext_topologicalClosure /-
/-- Continuous `star_alg_hom`s from the the topological closure of a `star_subalgebra` whose
compositions with the `star_subalgebra.inclusion` map agree are, in fact, equal. -/
theorem StarAlgHom.ext_topologicalClosure [T2Space B] {S : StarSubalgebra R A}
    {φ ψ : S.topologicalClosure →⋆ₐ[R] B} (hφ : Continuous φ) (hψ : Continuous ψ)
    (h :
      φ.comp (inclusion (le_topologicalClosure S)) = ψ.comp (inclusion (le_topologicalClosure S))) :
    φ = ψ := by
  rw [FunLike.ext'_iff]
  have : Dense (Set.range <| inclusion (le_topological_closure S)) :=
    by
    refine' embedding_subtype_coe.to_inducing.dense_iff.2 fun x => _
    convert show ↑x ∈ closure (S : Set A) from x.prop
    rw [← Set.range_comp]
    exact Set.ext fun y => ⟨by rintro ⟨y, rfl⟩; exact y.prop, fun hy => ⟨⟨y, hy⟩, rfl⟩⟩
  refine' Continuous.ext_on this hφ hψ _
  rintro _ ⟨x, rfl⟩
  simpa only using FunLike.congr_fun h x
#align star_alg_hom.ext_topological_closure StarAlgHom.ext_topologicalClosure
-/

#print StarAlgHomClass.ext_topologicalClosure /-
theorem StarAlgHomClass.ext_topologicalClosure [T2Space B] {F : Type _} {S : StarSubalgebra R A}
    [StarAlgHomClass F R S.topologicalClosure B] {φ ψ : F} (hφ : Continuous φ) (hψ : Continuous ψ)
    (h :
      ∀ x : S,
        φ (inclusion (le_topologicalClosure S) x) = ψ ((inclusion (le_topologicalClosure S)) x)) :
    φ = ψ :=
  by
  have : (φ : S.topological_closure →⋆ₐ[R] B) = (ψ : S.topological_closure →⋆ₐ[R] B) := by
    refine' StarAlgHom.ext_topologicalClosure hφ hψ (StarAlgHom.ext _) <;>
      simpa only [StarAlgHom.coe_comp, StarAlgHom.coe_coe] using h
  simpa only [FunLike.ext'_iff, StarAlgHom.coe_coe]
#align star_alg_hom_class.ext_topological_closure StarAlgHomClass.ext_topologicalClosure
-/

end TopologicalStarAlgebra

end StarSubalgebra

section Elemental

open StarSubalgebra

variable (R : Type _) {A B : Type _} [CommSemiring R] [StarRing R]

variable [TopologicalSpace A] [Semiring A] [StarRing A] [TopologicalSemiring A]

variable [ContinuousStar A] [Algebra R A] [StarModule R A]

variable [TopologicalSpace B] [Semiring B] [StarRing B] [Algebra R B]

#print elementalStarAlgebra /-
/-- The topological closure of the subalgebra generated by a single element. -/
def elementalStarAlgebra (x : A) : StarSubalgebra R A :=
  (adjoin R ({x} : Set A)).topologicalClosure
#align elemental_star_algebra elementalStarAlgebra
-/

namespace elementalStarAlgebra

#print elementalStarAlgebra.self_mem /-
theorem self_mem (x : A) : x ∈ elementalStarAlgebra R x :=
  SetLike.le_def.mp (le_topologicalClosure _) (self_mem_adjoin_singleton R x)
#align elemental_star_algebra.self_mem elementalStarAlgebra.self_mem
-/

#print elementalStarAlgebra.star_self_mem /-
theorem star_self_mem (x : A) : star x ∈ elementalStarAlgebra R x :=
  star_mem <| self_mem R x
#align elemental_star_algebra.star_self_mem elementalStarAlgebra.star_self_mem
-/

/-- The `elemental_star_algebra` generated by a normal element is commutative. -/
instance [T2Space A] {x : A} [IsStarNormal x] : CommSemiring (elementalStarAlgebra R x) :=
  StarSubalgebra.commSemiringTopologicalClosure _ mul_comm

/-- The `elemental_star_algebra` generated by a normal element is commutative. -/
instance {R A} [CommRing R] [StarRing R] [TopologicalSpace A] [Ring A] [Algebra R A] [StarRing A]
    [StarModule R A] [TopologicalRing A] [ContinuousStar A] [T2Space A] {x : A} [IsStarNormal x] :
    CommRing (elementalStarAlgebra R x) :=
  StarSubalgebra.commRingTopologicalClosure _ mul_comm

#print elementalStarAlgebra.isClosed /-
protected theorem isClosed (x : A) : IsClosed (elementalStarAlgebra R x : Set A) :=
  isClosed_closure
#align elemental_star_algebra.is_closed elementalStarAlgebra.isClosed
-/

instance {A : Type _} [UniformSpace A] [CompleteSpace A] [Semiring A] [StarRing A]
    [TopologicalSemiring A] [ContinuousStar A] [Algebra R A] [StarModule R A] (x : A) :
    CompleteSpace (elementalStarAlgebra R x) :=
  isClosed_closure.completeSpace_coe

#print elementalStarAlgebra.le_of_isClosed_of_mem /-
theorem le_of_isClosed_of_mem {S : StarSubalgebra R A} (hS : IsClosed (S : Set A)) {x : A}
    (hx : x ∈ S) : elementalStarAlgebra R x ≤ S :=
  topologicalClosure_minimal (adjoin_le <| Set.singleton_subset_iff.2 hx) hS
#align elemental_star_algebra.le_of_is_closed_of_mem elementalStarAlgebra.le_of_isClosed_of_mem
-/

#print elementalStarAlgebra.closedEmbedding_coe /-
/-- The coercion from an elemental algebra to the full algebra as a `closed_embedding`. -/
theorem closedEmbedding_coe (x : A) : ClosedEmbedding (coe : elementalStarAlgebra R x → A) :=
  { induced := rfl
    inj := Subtype.coe_injective
    closed_range := by
      convert elementalStarAlgebra.isClosed R x
      exact Set.ext fun y => ⟨by rintro ⟨y, rfl⟩; exact y.prop, fun hy => ⟨⟨y, hy⟩, rfl⟩⟩ }
#align elemental_star_algebra.closed_embedding_coe elementalStarAlgebra.closedEmbedding_coe
-/

#print elementalStarAlgebra.starAlgHomClass_ext /-
theorem starAlgHomClass_ext [T2Space B] {F : Type _} {a : A}
    [StarAlgHomClass F R (elementalStarAlgebra R a) B] {φ ψ : F} (hφ : Continuous φ)
    (hψ : Continuous ψ) (h : φ ⟨a, self_mem R a⟩ = ψ ⟨a, self_mem R a⟩) : φ = ψ :=
  by
  refine' StarAlgHomClass.ext_topologicalClosure hφ hψ fun x => adjoin_induction' x _ _ _ _ _
  exacts [fun y hy => by simpa only [set.mem_singleton_iff.mp hy] using h, fun r => by
    simp only [AlgHomClass.commutes], fun x y hx hy => by simp only [map_add, hx, hy],
    fun x y hx hy => by simp only [map_mul, hx, hy], fun x hx => by simp only [map_star, hx]]
#align elemental_star_algebra.star_alg_hom_class_ext elementalStarAlgebra.starAlgHomClass_ext
-/

end elementalStarAlgebra

end Elemental

