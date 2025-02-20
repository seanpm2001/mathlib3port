/-
Copyright (c) 2022 Antoine Labelle. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Antoine Labelle

! This file was ported from Lean 3 source module representation_theory.invariants
! leanprover-community/mathlib commit 55b3f8206b8596db8bb1804d8a92814a0b6670c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RepresentationTheory.Basic
import Mathbin.RepresentationTheory.FdRep

/-!
# Subspace of invariants a group representation

This file introduces the subspace of invariants of a group representation
and proves basic results about it.
The main tool used is the average of all elements of the group, seen as an element of
`monoid_algebra k G`. The action of this special element gives a projection onto the
subspace of invariants.
In order for the definition of the average element to make sense, we need to assume for most of the
results that the order of `G` is invertible in `k` (e. g. `k` has characteristic `0`).
-/


open scoped BigOperators

open MonoidAlgebra

open Representation

namespace GroupAlgebra

variable (k G : Type _) [CommSemiring k] [Group G]

variable [Fintype G] [Invertible (Fintype.card G : k)]

/-- The average of all elements of the group `G`, considered as an element of `monoid_algebra k G`.
-/
noncomputable def average : MonoidAlgebra k G :=
  ⅟ (Fintype.card G : k) • ∑ g : G, of k G g
#align group_algebra.average GroupAlgebra.average

/-- `average k G` is invariant under left multiplication by elements of `G`.
-/
@[simp]
theorem mul_average_left (g : G) :
    (Finsupp.single g 1 * average k G : MonoidAlgebra k G) = average k G :=
  by
  simp only [mul_one, Finset.mul_sum, Algebra.mul_smul_comm, average, MonoidAlgebra.of_apply,
    Finset.sum_congr, MonoidAlgebra.single_mul_single]
  set f : G → MonoidAlgebra k G := fun x => Finsupp.single x 1
  show ⅟ ↑(Fintype.card G) • ∑ x : G, f (g * x) = ⅟ ↑(Fintype.card G) • ∑ x : G, f x
  rw [Function.Bijective.sum_comp (Group.mulLeft_bijective g) _]
#align group_algebra.mul_average_left GroupAlgebra.mul_average_left

/-- `average k G` is invariant under right multiplication by elements of `G`.
-/
@[simp]
theorem mul_average_right (g : G) : average k G * Finsupp.single g 1 = average k G :=
  by
  simp only [mul_one, Finset.sum_mul, Algebra.smul_mul_assoc, average, MonoidAlgebra.of_apply,
    Finset.sum_congr, MonoidAlgebra.single_mul_single]
  set f : G → MonoidAlgebra k G := fun x => Finsupp.single x 1
  show ⅟ ↑(Fintype.card G) • ∑ x : G, f (x * g) = ⅟ ↑(Fintype.card G) • ∑ x : G, f x
  rw [Function.Bijective.sum_comp (Group.mulRight_bijective g) _]
#align group_algebra.mul_average_right GroupAlgebra.mul_average_right

end GroupAlgebra

namespace Representation

section Invariants

open GroupAlgebra

variable {k G V : Type _} [CommSemiring k] [Group G] [AddCommMonoid V] [Module k V]

variable (ρ : Representation k G V)

/-- The subspace of invariants, consisting of the vectors fixed by all elements of `G`.
-/
def invariants : Submodule k V
    where
  carrier := setOf fun v => ∀ g : G, ρ g v = v
  zero_mem' g := by simp only [map_zero]
  add_mem' v w hv hw g := by simp only [hv g, hw g, map_add]
  smul_mem' r v hv g := by simp only [hv g, LinearMap.map_smulₛₗ, RingHom.id_apply]
#align representation.invariants Representation.invariants

@[simp]
theorem mem_invariants (v : V) : v ∈ invariants ρ ↔ ∀ g : G, ρ g v = v := by rfl
#align representation.mem_invariants Representation.mem_invariants

theorem invariants_eq_inter : (invariants ρ).carrier = ⋂ g : G, Function.fixedPoints (ρ g) := by
  ext; simp [Function.IsFixedPt]
#align representation.invariants_eq_inter Representation.invariants_eq_inter

variable [Fintype G] [Invertible (Fintype.card G : k)]

/-- The action of `average k G` gives a projection map onto the subspace of invariants.
-/
@[simp]
noncomputable def averageMap : V →ₗ[k] V :=
  asAlgebraHom ρ (average k G)
#align representation.average_map Representation.averageMap

/-- The `average_map` sends elements of `V` to the subspace of invariants.
-/
theorem averageMap_invariant (v : V) : averageMap ρ v ∈ invariants ρ := fun g => by
  rw [average_map, ← as_algebra_hom_single_one, ← LinearMap.mul_apply, ← map_mul (as_algebra_hom ρ),
    mul_average_left]
#align representation.average_map_invariant Representation.averageMap_invariant

/-- The `average_map` acts as the identity on the subspace of invariants.
-/
theorem averageMap_id (v : V) (hv : v ∈ invariants ρ) : averageMap ρ v = v :=
  by
  rw [mem_invariants] at hv 
  simp [average, map_sum, hv, Finset.card_univ, nsmul_eq_smul_cast k _ v, smul_smul]
#align representation.average_map_id Representation.averageMap_id

theorem isProj_averageMap : LinearMap.IsProj ρ.invariants ρ.averageMap :=
  ⟨ρ.averageMap_invariant, ρ.averageMap_id⟩
#align representation.is_proj_average_map Representation.isProj_averageMap

end Invariants

namespace LinHom

universe u

open CategoryTheory Action

section Rep

variable {k : Type u} [CommRing k] {G : GroupCat.{u}}

theorem mem_invariants_iff_comm {X Y : Rep k G} (f : X.V →ₗ[k] Y.V) (g : G) :
    (linHom X.ρ Y.ρ) g f = f ↔ f.comp (X.ρ g) = (Y.ρ g).comp f :=
  by
  dsimp
  erw [← ρ_Aut_apply_inv]
  rw [← LinearMap.comp_assoc, ← ModuleCat.comp_def, ← ModuleCat.comp_def, iso.inv_comp_eq,
    ρ_Aut_apply_hom]
  exact comm
#align representation.lin_hom.mem_invariants_iff_comm Representation.linHom.mem_invariants_iff_comm

/-- The invariants of the representation `lin_hom X.ρ Y.ρ` correspond to the the representation
homomorphisms from `X` to `Y` -/
@[simps]
def invariantsEquivRepHom (X Y : Rep k G) : (linHom X.ρ Y.ρ).invariants ≃ₗ[k] X ⟶ Y
    where
  toFun f := ⟨f.val, fun g => (mem_invariants_iff_comm _ g).1 (f.property g)⟩
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
  invFun f := ⟨f.hom, fun g => (mem_invariants_iff_comm _ g).2 (f.comm g)⟩
  left_inv _ := by ext; rfl
  right_inv _ := by ext; rfl
#align representation.lin_hom.invariants_equiv_Rep_hom Representation.linHom.invariantsEquivRepHom

end Rep

section FdRep

variable {k : Type u} [Field k] {G : GroupCat.{u}}

/-- The invariants of the representation `lin_hom X.ρ Y.ρ` correspond to the the representation
homomorphisms from `X` to `Y` -/
def invariantsEquivFdRepHom (X Y : FdRep k G) : (linHom X.ρ Y.ρ).invariants ≃ₗ[k] X ⟶ Y :=
  by
  rw [← FdRep.forget₂_ρ, ← FdRep.forget₂_ρ]
  exact lin_hom.invariants_equiv_Rep_hom _ _ ≪≫ₗ FdRep.forget₂HomLinearEquiv X Y
#align representation.lin_hom.invariants_equiv_fdRep_hom Representation.linHom.invariantsEquivFdRepHom

end FdRep

end LinHom

end Representation

