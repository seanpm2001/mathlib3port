/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.non_unital_non_assoc_algebra
! leanprover-community/mathlib commit f47581155c818e6361af4e4fda60d27d020c226b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.NonUnitalAlg
import Mathbin.Algebra.Lie.Basic

/-!
# Lie algebras as non-unital, non-associative algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The definition of Lie algebras uses the `has_bracket` typeclass for multiplication whereas we have a
separate `has_mul` typeclass used for general algebras.

It is useful to have a special typeclass for Lie algebras because:
 * it enables us to use the traditional notation `⁅x, y⁆` for the Lie multiplication,
 * associative algebras carry a natural Lie algebra structure via the ring commutator and so we need
   them to carry both `has_mul` and `has_bracket` simultaneously,
 * more generally, Poisson algebras (not yet defined) need both typeclasses.

However there are times when it is convenient to be able to regard a Lie algebra as a general
algebra and we provide some basic definitions for doing so here.

## Main definitions

  * `commutator_ring` turns a Lie ring into a `non_unital_non_assoc_semiring` by turning its
    `has_bracket` (denoted `⁅, ⁆`) into a `has_mul` (denoted `*`).
  * `lie_hom.to_non_unital_alg_hom`

## Tags

lie algebra, non-unital, non-associative
-/


universe u v w

variable (R : Type u) (L : Type v) [CommRing R] [LieRing L] [LieAlgebra R L]

#print CommutatorRing /-
/-- Type synonym for turning a `lie_ring` into a `non_unital_non_assoc_semiring`.

A `lie_ring` can be regarded as a `non_unital_non_assoc_semiring` by turning its
`has_bracket` (denoted `⁅, ⁆`) into a `has_mul` (denoted `*`). -/
def CommutatorRing (L : Type v) : Type v :=
  L
#align commutator_ring CommutatorRing
-/

/-- A `lie_ring` can be regarded as a `non_unital_non_assoc_semiring` by turning its
`has_bracket` (denoted `⁅, ⁆`) into a `has_mul` (denoted `*`). -/
instance : NonUnitalNonAssocSemiring (CommutatorRing L) :=
  show NonUnitalNonAssocSemiring L from
    {
      (inferInstance : AddCommMonoid
          L) with
      mul := Bracket.bracket
      left_distrib := lie_add
      right_distrib := add_lie
      zero_mul := zero_lie
      mul_zero := lie_zero }

namespace LieAlgebra

instance (L : Type v) [Nonempty L] : Nonempty (CommutatorRing L) :=
  ‹Nonempty L›

instance (L : Type v) [Inhabited L] : Inhabited (CommutatorRing L) :=
  ‹Inhabited L›

instance : LieRing (CommutatorRing L) :=
  show LieRing L by infer_instance

instance : LieAlgebra R (CommutatorRing L) :=
  show LieAlgebra R L by infer_instance

#print LieAlgebra.isScalarTower /-
/-- Regarding the `lie_ring` of a `lie_algebra` as a `non_unital_non_assoc_semiring`, we can
reinterpret the `smul_lie` law as an `is_scalar_tower`. -/
instance isScalarTower : IsScalarTower R (CommutatorRing L) (CommutatorRing L) :=
  ⟨smul_lie⟩
#align lie_algebra.is_scalar_tower LieAlgebra.isScalarTower
-/

#print LieAlgebra.smulCommClass /-
/-- Regarding the `lie_ring` of a `lie_algebra` as a `non_unital_non_assoc_semiring`, we can
reinterpret the `lie_smul` law as an `smul_comm_class`. -/
instance smulCommClass : SMulCommClass R (CommutatorRing L) (CommutatorRing L) :=
  ⟨fun t x y => (lie_smul t x y).symm⟩
#align lie_algebra.smul_comm_class LieAlgebra.smulCommClass
-/

end LieAlgebra

namespace LieHom

variable {R L} {L₂ : Type w} [LieRing L₂] [LieAlgebra R L₂]

#print LieHom.toNonUnitalAlgHom /-
/-- Regarding the `lie_ring` of a `lie_algebra` as a `non_unital_non_assoc_semiring`, we can
regard a `lie_hom` as a `non_unital_alg_hom`. -/
@[simps]
def toNonUnitalAlgHom (f : L →ₗ⁅R⁆ L₂) : CommutatorRing L →ₙₐ[R] CommutatorRing L₂ :=
  { f with
    toFun := f
    map_zero' := f.map_zero
    map_mul' := f.map_lie }
#align lie_hom.to_non_unital_alg_hom LieHom.toNonUnitalAlgHom
-/

#print LieHom.toNonUnitalAlgHom_injective /-
theorem toNonUnitalAlgHom_injective :
    Function.Injective (toNonUnitalAlgHom : _ → CommutatorRing L →ₙₐ[R] CommutatorRing L₂) :=
  fun f g h => ext <| NonUnitalAlgHom.congr_fun h
#align lie_hom.to_non_unital_alg_hom_injective LieHom.toNonUnitalAlgHom_injective
-/

end LieHom

