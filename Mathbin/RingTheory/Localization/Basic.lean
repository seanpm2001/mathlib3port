/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Mario Carneiro, Johan Commelin, Amelia Livingston, Anne Baanen
-/
import Mathbin.Algebra.Algebra.Basic
import Mathbin.Algebra.Ring.Equiv
import Mathbin.GroupTheory.MonoidLocalization
import Mathbin.RingTheory.Ideal.Basic
import Mathbin.RingTheory.NonZeroDivisors
import Mathbin.Tactic.RingExp

/-!
# Localizations of commutative rings

We characterize the localization of a commutative ring `R` at a submonoid `M` up to
isomorphism; that is, a commutative ring `S` is the localization of `R` at `M` iff we can find a
ring homomorphism `f : R →+* S` satisfying 3 properties:
1. For all `y ∈ M`, `f y` is a unit;
2. For all `z : S`, there exists `(x, y) : R × M` such that `z * f y = f x`;
3. For all `x, y : R`, `f x = f y` iff there exists `c ∈ M` such that `x * c = y * c`.

In the following, let `R, P` be commutative rings, `S, Q` be `R`- and `P`-algebras
and `M, T` be submonoids of `R` and `P` respectively, e.g.:
```
variables (R S P Q : Type*) [comm_ring R] [comm_ring S] [comm_ring P] [comm_ring Q]
variables [algebra R S] [algebra P Q] (M : submonoid R) (T : submonoid P)
```

## Main definitions

 * `is_localization (M : submonoid R) (S : Type*)` is a typeclass expressing that `S` is a
   localization of `R` at `M`, i.e. the canonical map `algebra_map R S : R →+* S` is a
   localization map (satisfying the above properties).
 * `is_localization.mk' S` is a surjection sending `(x, y) : R × M` to `f x * (f y)⁻¹`
 * `is_localization.lift` is the ring homomorphism from `S` induced by a homomorphism from `R`
   which maps elements of `M` to invertible elements of the codomain.
 * `is_localization.map S Q` is the ring homomorphism from `S` to `Q` which maps elements
   of `M` to elements of `T`
 * `is_localization.ring_equiv_of_ring_equiv`: if `R` and `P` are isomorphic by an isomorphism
   sending `M` to `T`, then `S` and `Q` are isomorphic
 * `is_localization.alg_equiv`: if `Q` is another localization of `R` at `M`, then `S` and `Q`
   are isomorphic as `R`-algebras

## Main results

 * `localization M S`, a construction of the localization as a quotient type, defined in
   `group_theory.monoid_localization`, has `comm_ring`, `algebra R` and `is_localization M`
   instances if `R` is a ring. `localization.away`, `localization.at_prime` and `fraction_ring`
   are abbreviations for `localization`s and have their corresponding `is_localization` instances

## Implementation notes

In maths it is natural to reason up to isomorphism, but in Lean we cannot naturally `rewrite` one
structure with an isomorphic one; one way around this is to isolate a predicate characterizing
a structure up to isomorphism, and reason about things that satisfy the predicate.

A previous version of this file used a fully bundled type of ring localization maps,
then used a type synonym `f.codomain` for `f : localization_map M S` to instantiate the
`R`-algebra structure on `S`. This results in defining ad-hoc copies for everything already
defined on `S`. By making `is_localization` a predicate on the `algebra_map R S`,
we can ensure the localization map commutes nicely with other `algebra_map`s.

To prove most lemmas about a localization map `algebra_map R S` in this file we invoke the
corresponding proof for the underlying `comm_monoid` localization map
`is_localization.to_localization_map M S`, which can be found in `group_theory.monoid_localization`
and the namespace `submonoid.localization_map`.

To reason about the localization as a quotient type, use `mk_eq_of_mk'` and associated lemmas.
These show the quotient map `mk : R → M → localization M` equals the surjection
`localization_map.mk'` induced by the map `algebra_map : R →+* localization M`.
The lemma `mk_eq_of_mk'` hence gives you access to the results in the rest of the file,
which are about the `localization_map.mk'` induced by any localization map.

The proof that "a `comm_ring` `K` which is the localization of an integral domain `R` at `R \ {0}`
is a field" is a `def` rather than an `instance`, so if you want to reason about a field of
fractions `K`, assume `[field K]` instead of just `[comm_ring K]`.

## Tags
localization, ring localization, commutative ring localization, characteristic predicate,
commutative ring, field of fractions
-/


open Function

open BigOperators

section CommSemiring

variable {R : Type _} [CommSemiring R] (M : Submonoid R) (S : Type _) [CommSemiring S]

variable [Algebra R S] {P : Type _} [CommSemiring P]

/- ./././Mathport/Syntax/Translate/Command.lean:379:30: infer kinds are unsupported in Lean 4: #[`map_units] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:379:30: infer kinds are unsupported in Lean 4: #[`surj] [] -/
/- ./././Mathport/Syntax/Translate/Command.lean:379:30: infer kinds are unsupported in Lean 4: #[`eq_iff_exists] [] -/
/-- The typeclass `is_localization (M : submodule R) S` where `S` is an `R`-algebra
expresses that `S` is isomorphic to the localization of `R` at `M`. -/
class IsLocalization : Prop where
  map_units : ∀ y : M, IsUnit (algebraMap R S y)
  surj : ∀ z : S, ∃ x : R × M, z * algebraMap R S x.2 = algebraMap R S x.1
  eq_iff_exists : ∀ {x y}, algebraMap R S x = algebraMap R S y ↔ ∃ c : M, x * c = y * c
#align is_localization IsLocalization

variable {M S}

namespace IsLocalization

section IsLocalization

variable [IsLocalization M S]

section

variable (M)

theorem of_le (N : Submonoid R) (h₁ : M ≤ N) (h₂ : ∀ r ∈ N, IsUnit (algebraMap R S r)) :
    IsLocalization N S :=
  { map_units := fun r => h₂ r r.2,
    surj := fun s => by 
      obtain ⟨⟨x, y, hy⟩, H⟩ := IsLocalization.surj M s
      exact ⟨⟨x, y, h₁ hy⟩, H⟩,
    eq_iff_exists := fun x y => by 
      constructor
      · rw [IsLocalization.eq_iff_exists M]
        rintro ⟨c, hc⟩
        exact ⟨⟨c, h₁ c.2⟩, hc⟩
      · rintro ⟨c, h⟩
        simpa only [SetLike.coe_mk, map_mul, (h₂ c c.2).mul_left_inj] using
          congr_arg (algebraMap R S) h }
#align is_localization.of_le IsLocalization.of_le

variable (S)

/-- `is_localization.to_localization_with_zero_map M S` shows `S` is the monoid localization of
`R` at `M`. -/
@[simps]
def toLocalizationWithZeroMap : Submonoid.LocalizationWithZeroMap M S :=
  { algebraMap R S with toFun := algebraMap R S, map_units' := IsLocalization.map_units _,
    surj' := IsLocalization.surj _, eq_iff_exists' := fun _ _ => IsLocalization.eq_iff_exists _ _ }
#align is_localization.to_localization_with_zero_map IsLocalization.toLocalizationWithZeroMap

/-- `is_localization.to_localization_map M S` shows `S` is the monoid localization of `R` at `M`. -/
abbrev toLocalizationMap : Submonoid.LocalizationMap M S :=
  (toLocalizationWithZeroMap M S).toLocalizationMap
#align is_localization.to_localization_map IsLocalization.toLocalizationMap

@[simp]
theorem to_localization_map_to_map : (toLocalizationMap M S).toMap = (algebraMap R S : R →*₀ S) :=
  rfl
#align is_localization.to_localization_map_to_map IsLocalization.to_localization_map_to_map

theorem to_localization_map_to_map_apply (x) : (toLocalizationMap M S).toMap x = algebraMap R S x :=
  rfl
#align
  is_localization.to_localization_map_to_map_apply IsLocalization.to_localization_map_to_map_apply

end

variable (M)

/-- Given a localization map `f : M →* N`, a section function sending `z : N` to some
`(x, y) : M × S` such that `f x * (f y)⁻¹ = z`. -/
noncomputable def sec (z : S) : R × M :=
  Classical.choose <| IsLocalization.surj _ z
#align is_localization.sec IsLocalization.sec

@[simp]
theorem to_localization_map_sec : (toLocalizationMap M S).sec = sec M :=
  rfl
#align is_localization.to_localization_map_sec IsLocalization.to_localization_map_sec

/-- Given `z : S`, `is_localization.sec M z` is defined to be a pair `(x, y) : R × M` such
that `z * f y = f x` (so this lemma is true by definition). -/
theorem sec_spec (z : S) :
    z * algebraMap R S (IsLocalization.sec M z).2 = algebraMap R S (IsLocalization.sec M z).1 :=
  Classical.choose_spec <| IsLocalization.surj _ z
#align is_localization.sec_spec IsLocalization.sec_spec

/-- Given `z : S`, `is_localization.sec M z` is defined to be a pair `(x, y) : R × M` such
that `z * f y = f x`, so this lemma is just an application of `S`'s commutativity. -/
theorem sec_spec' (z : S) :
    algebraMap R S (IsLocalization.sec M z).1 = algebraMap R S (IsLocalization.sec M z).2 * z := by
  rw [mul_comm, sec_spec]
#align is_localization.sec_spec' IsLocalization.sec_spec'

variable {R M}

theorem map_right_cancel {x y} {c : M} (h : algebraMap R S (c * x) = algebraMap R S (c * y)) :
    algebraMap R S x = algebraMap R S y :=
  (toLocalizationMap M S).map_right_cancel h
#align is_localization.map_right_cancel IsLocalization.map_right_cancel

theorem map_left_cancel {x y} {c : M} (h : algebraMap R S (x * c) = algebraMap R S (y * c)) :
    algebraMap R S x = algebraMap R S y :=
  (toLocalizationMap M S).map_left_cancel h
#align is_localization.map_left_cancel IsLocalization.map_left_cancel

theorem eq_zero_of_fst_eq_zero {z x} {y : M} (h : z * algebraMap R S y = algebraMap R S x)
    (hx : x = 0) : z = 0 := by 
  rw [hx, (algebraMap R S).map_zero] at h
  exact (IsUnit.mul_left_eq_zero (IsLocalization.map_units S y)).1 h
#align is_localization.eq_zero_of_fst_eq_zero IsLocalization.eq_zero_of_fst_eq_zero

variable (M S)

theorem map_eq_zero_iff (r : R) : algebraMap R S r = 0 ↔ ∃ m : M, r * m = 0 := by
  constructor
  intro h
  · obtain ⟨m, hm⟩ := (IsLocalization.eq_iff_exists M S).mp ((algebraMap R S).map_zero.trans h.symm)
    exact ⟨m, by simpa using hm.symm⟩
  · rintro ⟨m, hm⟩
    rw [← (IsLocalization.map_units S m).mul_left_inj, zero_mul, ← RingHom.map_mul, hm,
      RingHom.map_zero]
#align is_localization.map_eq_zero_iff IsLocalization.map_eq_zero_iff

variable {M}

/-- `is_localization.mk' S` is the surjection sending `(x, y) : R × M` to
`f x * (f y)⁻¹`. -/
noncomputable def mk' (x : R) (y : M) : S :=
  (toLocalizationMap M S).mk' x y
#align is_localization.mk' IsLocalization.mk'

@[simp]
theorem mk'_sec (z : S) : mk' S (IsLocalization.sec M z).1 (IsLocalization.sec M z).2 = z :=
  (toLocalizationMap M S).mk'_sec _
#align is_localization.mk'_sec IsLocalization.mk'_sec

theorem mk'_mul (x₁ x₂ : R) (y₁ y₂ : M) : mk' S (x₁ * x₂) (y₁ * y₂) = mk' S x₁ y₁ * mk' S x₂ y₂ :=
  (toLocalizationMap M S).mk'_mul _ _ _ _
#align is_localization.mk'_mul IsLocalization.mk'_mul

theorem mk'_one (x) : mk' S x (1 : M) = algebraMap R S x :=
  (toLocalizationMap M S).mk'_one _
#align is_localization.mk'_one IsLocalization.mk'_one

@[simp]
theorem mk'_spec (x) (y : M) : mk' S x y * algebraMap R S y = algebraMap R S x :=
  (toLocalizationMap M S).mk'_spec _ _
#align is_localization.mk'_spec IsLocalization.mk'_spec

@[simp]
theorem mk'_spec' (x) (y : M) : algebraMap R S y * mk' S x y = algebraMap R S x :=
  (toLocalizationMap M S).mk'_spec' _ _
#align is_localization.mk'_spec' IsLocalization.mk'_spec'

@[simp]
theorem mk'_spec_mk (x) (y : R) (hy : y ∈ M) :
    mk' S x ⟨y, hy⟩ * algebraMap R S y = algebraMap R S x :=
  mk'_spec S x ⟨y, hy⟩
#align is_localization.mk'_spec_mk IsLocalization.mk'_spec_mk

@[simp]
theorem mk'_spec'_mk (x) (y : R) (hy : y ∈ M) :
    algebraMap R S y * mk' S x ⟨y, hy⟩ = algebraMap R S x :=
  mk'_spec' S x ⟨y, hy⟩
#align is_localization.mk'_spec'_mk IsLocalization.mk'_spec'_mk

variable {S}

theorem eq_mk'_iff_mul_eq {x} {y : M} {z} :
    z = mk' S x y ↔ z * algebraMap R S y = algebraMap R S x :=
  (toLocalizationMap M S).eq_mk'_iff_mul_eq
#align is_localization.eq_mk'_iff_mul_eq IsLocalization.eq_mk'_iff_mul_eq

theorem mk'_eq_iff_eq_mul {x} {y : M} {z} :
    mk' S x y = z ↔ algebraMap R S x = z * algebraMap R S y :=
  (toLocalizationMap M S).mk'_eq_iff_eq_mul
#align is_localization.mk'_eq_iff_eq_mul IsLocalization.mk'_eq_iff_eq_mul

theorem mk'_add_eq_iff_add_mul_eq_mul {x} {y : M} {z₁ z₂} :
    mk' S x y + z₁ = z₂ ↔ algebraMap R S x + z₁ * algebraMap R S y = z₂ * algebraMap R S y := by
  rw [← mk'_spec S x y, ← IsUnit.mul_left_inj (IsLocalization.map_units S y), right_distrib]
#align is_localization.mk'_add_eq_iff_add_mul_eq_mul IsLocalization.mk'_add_eq_iff_add_mul_eq_mul

variable (M)

theorem mk'_surjective (z : S) : ∃ (x : _)(y : M), mk' S x y = z :=
  let ⟨r, hr⟩ := IsLocalization.surj _ z
  ⟨r.1, r.2, (eq_mk'_iff_mul_eq.2 hr).symm⟩
#align is_localization.mk'_surjective IsLocalization.mk'_surjective

variable (S)

include M

/-- The localization of a `fintype` is a `fintype`. Cannot be an instance. -/
noncomputable def fintype' [Fintype R] : Fintype S :=
  have := Classical.propDecidable
  Fintype.ofSurjective (Function.uncurry <| IsLocalization.mk' S) fun a =>
    prod.exists'.mpr <| IsLocalization.mk'_surjective M a
#align is_localization.fintype' IsLocalization.fintype'

omit M

variable {M S}

/-- Localizing at a submonoid with 0 inside it leads to the trivial ring. -/
def uniqueOfZeroMem (h : (0 : R) ∈ M) : Unique S :=
  uniqueOfZeroEqOne <| by simpa using IsLocalization.map_units S ⟨0, h⟩
#align is_localization.unique_of_zero_mem IsLocalization.uniqueOfZeroMem

theorem mk'_eq_iff_eq {x₁ x₂} {y₁ y₂ : M} :
    mk' S x₁ y₁ = mk' S x₂ y₂ ↔ algebraMap R S (x₁ * y₂) = algebraMap R S (x₂ * y₁) :=
  (toLocalizationMap M S).mk'_eq_iff_eq
#align is_localization.mk'_eq_iff_eq IsLocalization.mk'_eq_iff_eq

theorem mk'_mem_iff {x} {y : M} {I : Ideal S} : mk' S x y ∈ I ↔ algebraMap R S x ∈ I := by
  constructor <;> intro h
  · rw [← mk'_spec S x y, mul_comm]
    exact I.mul_mem_left ((algebraMap R S) y) h
  · rw [← mk'_spec S x y] at h
    obtain ⟨b, hb⟩ := isUnit_iff_exists_inv.1 (map_units S y)
    have := I.mul_mem_left b h
    rwa [mul_comm, mul_assoc, hb, mul_one] at this
#align is_localization.mk'_mem_iff IsLocalization.mk'_mem_iff

protected theorem eq {a₁ b₁} {a₂ b₂ : M} :
    mk' S a₁ a₂ = mk' S b₁ b₂ ↔ ∃ c : M, a₁ * b₂ * c = b₁ * a₂ * c :=
  (toLocalizationMap M S).Eq
#align is_localization.eq IsLocalization.eq

theorem mk'_eq_zero_iff (x : R) (s : M) : mk' S x s = 0 ↔ ∃ m : M, x * m = 0 := by
  rw [← (map_units S s).mul_left_inj, mk'_spec, zero_mul, map_eq_zero_iff M]
#align is_localization.mk'_eq_zero_iff IsLocalization.mk'_eq_zero_iff

@[simp]
theorem mk'_zero (s : M) : IsLocalization.mk' S 0 s = 0 := by
  rw [eq_comm, IsLocalization.eq_mk'_iff_mul_eq, zero_mul, map_zero]
#align is_localization.mk'_zero IsLocalization.mk'_zero

theorem ne_zero_of_mk'_ne_zero {x : R} {y : M} (hxy : IsLocalization.mk' S x y ≠ 0) : x ≠ 0 := by
  rintro rfl
  exact hxy (IsLocalization.mk'_zero _)
#align is_localization.ne_zero_of_mk'_ne_zero IsLocalization.ne_zero_of_mk'_ne_zero

section Ext

variable [Algebra R P] [IsLocalization M P]

theorem eq_iff_eq {x y} :
    algebraMap R S x = algebraMap R S y ↔ algebraMap R P x = algebraMap R P y :=
  (toLocalizationMap M S).eq_iff_eq (toLocalizationMap M P)
#align is_localization.eq_iff_eq IsLocalization.eq_iff_eq

theorem mk'_eq_iff_mk'_eq {x₁ x₂} {y₁ y₂ : M} :
    mk' S x₁ y₁ = mk' S x₂ y₂ ↔ mk' P x₁ y₁ = mk' P x₂ y₂ :=
  (toLocalizationMap M S).mk'_eq_iff_mk'_eq (toLocalizationMap M P)
#align is_localization.mk'_eq_iff_mk'_eq IsLocalization.mk'_eq_iff_mk'_eq

theorem mk'_eq_of_eq {a₁ b₁ : R} {a₂ b₂ : M} (H : b₁ * a₂ = a₁ * b₂) : mk' S a₁ a₂ = mk' S b₁ b₂ :=
  (toLocalizationMap M S).mk'_eq_of_eq H
#align is_localization.mk'_eq_of_eq IsLocalization.mk'_eq_of_eq

variable (S)

@[simp]
theorem mk'_self {x : R} (hx : x ∈ M) : mk' S x ⟨x, hx⟩ = 1 :=
  (toLocalizationMap M S).mk'_self _ hx
#align is_localization.mk'_self IsLocalization.mk'_self

@[simp]
theorem mk'_self' {x : M} : mk' S (x : R) x = 1 :=
  (toLocalizationMap M S).mk'_self' _
#align is_localization.mk'_self' IsLocalization.mk'_self'

theorem mk'_self'' {x : M} : mk' S x.1 x = 1 :=
  mk'_self' _
#align is_localization.mk'_self'' IsLocalization.mk'_self''

end Ext

theorem mul_mk'_eq_mk'_of_mul (x y : R) (z : M) :
    (algebraMap R S) x * mk' S y z = mk' S (x * y) z :=
  (toLocalizationMap M S).mul_mk'_eq_mk'_of_mul _ _ _
#align is_localization.mul_mk'_eq_mk'_of_mul IsLocalization.mul_mk'_eq_mk'_of_mul

theorem mk'_eq_mul_mk'_one (x : R) (y : M) : mk' S x y = (algebraMap R S) x * mk' S 1 y :=
  ((toLocalizationMap M S).mul_mk'_one_eq_mk' _ _).symm
#align is_localization.mk'_eq_mul_mk'_one IsLocalization.mk'_eq_mul_mk'_one

@[simp]
theorem mk'_mul_cancel_left (x : R) (y : M) : mk' S (y * x : R) y = (algebraMap R S) x :=
  (toLocalizationMap M S).mk'_mul_cancel_left _ _
#align is_localization.mk'_mul_cancel_left IsLocalization.mk'_mul_cancel_left

theorem mk'_mul_cancel_right (x : R) (y : M) : mk' S (x * y) y = (algebraMap R S) x :=
  (toLocalizationMap M S).mk'_mul_cancel_right _ _
#align is_localization.mk'_mul_cancel_right IsLocalization.mk'_mul_cancel_right

@[simp]
theorem mk'_mul_mk'_eq_one (x y : M) : mk' S (x : R) y * mk' S (y : R) x = 1 := by
  rw [← mk'_mul, mul_comm] <;> exact mk'_self _ _
#align is_localization.mk'_mul_mk'_eq_one IsLocalization.mk'_mul_mk'_eq_one

theorem mk'_mul_mk'_eq_one' (x : R) (y : M) (h : x ∈ M) : mk' S x y * mk' S (y : R) ⟨x, h⟩ = 1 :=
  mk'_mul_mk'_eq_one ⟨x, h⟩ _
#align is_localization.mk'_mul_mk'_eq_one' IsLocalization.mk'_mul_mk'_eq_one'

section

variable (M)

theorem is_unit_comp (j : S →+* P) (y : M) : IsUnit (j.comp (algebraMap R S) y) :=
  (toLocalizationMap M S).is_unit_comp j.toMonoidHom _
#align is_localization.is_unit_comp IsLocalization.is_unit_comp

end

/-- Given a localization map `f : R →+* S` for a submonoid `M ⊆ R` and a map of `comm_semiring`s
`g : R →+* P` such that `g(M) ⊆ units P`, `f x = f y → g x = g y` for all `x y : R`. -/
theorem eq_of_eq {g : R →+* P} (hg : ∀ y : M, IsUnit (g y)) {x y}
    (h : (algebraMap R S) x = (algebraMap R S) y) : g x = g y :=
  @Submonoid.LocalizationMap.eq_of_eq _ _ _ _ _ _ _ (toLocalizationMap M S) g.toMonoidHom hg _ _ h
#align is_localization.eq_of_eq IsLocalization.eq_of_eq

theorem mk'_add (x₁ x₂ : R) (y₁ y₂ : M) :
    mk' S (x₁ * y₂ + x₂ * y₁) (y₁ * y₂) = mk' S x₁ y₁ + mk' S x₂ y₂ :=
  mk'_eq_iff_eq_mul.2 <|
    Eq.symm
      (by
        rw [mul_comm (_ + _), mul_add, mul_mk'_eq_mk'_of_mul, mk'_add_eq_iff_add_mul_eq_mul,
          mul_comm (_ * _), ← mul_assoc, add_comm, ← map_mul, mul_mk'_eq_mk'_of_mul,
          mk'_add_eq_iff_add_mul_eq_mul]
        simp only [map_add, Submonoid.coe_mul, map_mul]
        ring)
#align is_localization.mk'_add IsLocalization.mk'_add

theorem mul_add_inv_left {g : R →+* P} (h : ∀ y : M, IsUnit (g y)) (y : M) (w z₁ z₂ : P) :
    w * ↑(IsUnit.liftRight (g.toMonoidHom.restrict M) h y)⁻¹ + z₁ = z₂ ↔ w + g y * z₁ = g y * z₂ :=
  by
  rw [mul_comm, ← one_mul z₁, ← Units.inv_mul (IsUnit.liftRight (g.to_monoid_hom.restrict M) h y),
    mul_assoc, ← mul_add, Units.inv_mul_eq_iff_eq_mul, Units.inv_mul_cancel_left,
    IsUnit.coe_lift_right]
  simp only [RingHom.to_monoid_hom_eq_coe, MonoidHom.restrict_apply, RingHom.coe_monoid_hom]
#align is_localization.mul_add_inv_left IsLocalization.mul_add_inv_left

theorem lift_spec_mul_add {g : R →+* P} (hg : ∀ y : M, IsUnit (g y)) (z w w' v) :
    ((toLocalizationWithZeroMap M S).lift g.toMonoidWithZeroHom hg) z * w + w' = v ↔
      g ((toLocalizationMap M S).sec z).1 * w + g ((toLocalizationMap M S).sec z).2 * w' =
        g ((toLocalizationMap M S).sec z).2 * v :=
  by 
  show _ * _ * _ + _ = _ ↔ _ = _
  erw [mul_comm, ← mul_assoc, mul_add_inv_left hg, mul_comm]
  rfl
#align is_localization.lift_spec_mul_add IsLocalization.lift_spec_mul_add

/-- Given a localization map `f : R →+* S` for a submonoid `M ⊆ R` and a map of `comm_semiring`s
`g : R →+* P` such that `g y` is invertible for all `y : M`, the homomorphism induced from
`S` to `P` sending `z : S` to `g x * (g y)⁻¹`, where `(x, y) : R × M` are such that
`z = f x * (f y)⁻¹`. -/
noncomputable def lift {g : R →+* P} (hg : ∀ y : M, IsUnit (g y)) : S →+* P :=
  { @Submonoid.LocalizationWithZeroMap.lift _ _ _ _ _ _ _ (toLocalizationWithZeroMap M S)
      g.toMonoidWithZeroHom hg with
    map_add' := by 
      intro x y
      erw [(to_localization_map M S).lift_spec, mul_add, mul_comm, eq_comm, lift_spec_mul_add,
        add_comm, mul_comm, mul_assoc, mul_comm, mul_assoc, lift_spec_mul_add]
      simp_rw [← mul_assoc]
      show g _ * g _ * g _ + g _ * g _ * g _ = g _ * g _ * g _
      simp_rw [← map_mul g, ← map_add g]
      apply @eq_of_eq _ _ _ S _ _ _ _ _ g hg
      simp only [sec_spec', to_localization_map_sec, map_add, map_mul]
      ring }
#align is_localization.lift IsLocalization.lift

variable {g : R →+* P} (hg : ∀ y : M, IsUnit (g y))

/-- Given a localization map `f : R →+* S` for a submonoid `M ⊆ R` and a map of `comm_semiring`s
`g : R →* P` such that `g y` is invertible for all `y : M`, the homomorphism induced from
`S` to `P` maps `f x * (f y)⁻¹` to `g x * (g y)⁻¹` for all `x : R, y ∈ M`. -/
theorem lift_mk' (x y) :
    lift hg (mk' S x y) = g x * ↑(IsUnit.liftRight (g.toMonoidHom.restrict M) hg y)⁻¹ :=
  (toLocalizationMap M S).lift_mk' _ _ _
#align is_localization.lift_mk' IsLocalization.lift_mk'

theorem lift_mk'_spec (x v) (y : M) : lift hg (mk' S x y) = v ↔ g x = g y * v :=
  (toLocalizationMap M S).lift_mk'_spec _ _ _ _
#align is_localization.lift_mk'_spec IsLocalization.lift_mk'_spec

@[simp]
theorem lift_eq (x : R) : lift hg ((algebraMap R S) x) = g x :=
  (toLocalizationMap M S).liftEq _ _
#align is_localization.lift_eq IsLocalization.lift_eq

theorem lift_eq_iff {x y : R × M} :
    lift hg (mk' S x.1 x.2) = lift hg (mk' S y.1 y.2) ↔ g (x.1 * y.2) = g (y.1 * x.2) :=
  (toLocalizationMap M S).lift_eq_iff _
#align is_localization.lift_eq_iff IsLocalization.lift_eq_iff

@[simp]
theorem lift_comp : (lift hg).comp (algebraMap R S) = g :=
  RingHom.ext <| MonoidHom.ext_iff.1 <| (toLocalizationMap M S).lift_comp _
#align is_localization.lift_comp IsLocalization.lift_comp

@[simp]
theorem lift_of_comp (j : S →+* P) : lift (is_unit_comp M j) = j :=
  RingHom.ext <| MonoidHom.ext_iff.1 <| (toLocalizationMap M S).lift_of_comp j.toMonoidHom
#align is_localization.lift_of_comp IsLocalization.lift_of_comp

variable (M)

/-- See note [partially-applied ext lemmas] -/
theorem monoid_hom_ext ⦃j k : S →* P⦄
    (h : j.comp (algebraMap R S : R →* S) = k.comp (algebraMap R S)) : j = k :=
  Submonoid.LocalizationMap.epic_of_localization_map (toLocalizationMap M S) <|
    MonoidHom.congr_fun h
#align is_localization.monoid_hom_ext IsLocalization.monoid_hom_ext

/-- See note [partially-applied ext lemmas] -/
theorem ring_hom_ext ⦃j k : S →+* P⦄ (h : j.comp (algebraMap R S) = k.comp (algebraMap R S)) :
    j = k :=
  RingHom.coe_monoid_hom_injective <| monoid_hom_ext M <| MonoidHom.ext <| RingHom.congr_fun h
#align is_localization.ring_hom_ext IsLocalization.ring_hom_ext

/- This is not an instance because the submonoid `M` would become a metavariable
  in typeclass search. -/
theorem alg_hom_subsingleton [Algebra R P] : Subsingleton (S →ₐ[R] P) :=
  ⟨fun f g =>
    AlgHom.coe_ring_hom_injective <|
      IsLocalization.ring_hom_ext M <| by rw [f.comp_algebra_map, g.comp_algebra_map]⟩
#align is_localization.alg_hom_subsingleton IsLocalization.alg_hom_subsingleton

/-- To show `j` and `k` agree on the whole localization, it suffices to show they agree
on the image of the base ring, if they preserve `1` and `*`. -/
protected theorem ext (j k : S → P) (hj1 : j 1 = 1) (hk1 : k 1 = 1)
    (hjm : ∀ a b, j (a * b) = j a * j b) (hkm : ∀ a b, k (a * b) = k a * k b)
    (h : ∀ a, j (algebraMap R S a) = k (algebraMap R S a)) : j = k :=
  MonoidHom.mk.inj (monoid_hom_ext M <| MonoidHom.ext h : (⟨j, hj1, hjm⟩ : S →* P) = ⟨k, hk1, hkm⟩)
#align is_localization.ext IsLocalization.ext

variable {M}

theorem lift_unique {j : S →+* P} (hj : ∀ x, j ((algebraMap R S) x) = g x) : lift hg = j :=
  RingHom.ext <|
    MonoidHom.ext_iff.1 <|
      @Submonoid.LocalizationMap.lift_unique _ _ _ _ _ _ _ (toLocalizationMap M S) g.toMonoidHom hg
        j.toMonoidHom hj
#align is_localization.lift_unique IsLocalization.lift_unique

@[simp]
theorem lift_id (x) : lift (map_units S : ∀ y : M, IsUnit _) x = x :=
  (toLocalizationMap M S).lift_id _
#align is_localization.lift_id IsLocalization.lift_id

theorem lift_surjective_iff :
    Surjective (lift hg : S → P) ↔ ∀ v : P, ∃ x : R × M, v * g x.2 = g x.1 :=
  (toLocalizationMap M S).lift_surjective_iff hg
#align is_localization.lift_surjective_iff IsLocalization.lift_surjective_iff

theorem lift_injective_iff :
    Injective (lift hg : S → P) ↔ ∀ x y, algebraMap R S x = algebraMap R S y ↔ g x = g y :=
  (toLocalizationMap M S).lift_injective_iff hg
#align is_localization.lift_injective_iff IsLocalization.lift_injective_iff

section Map

variable {T : Submonoid P} {Q : Type _} [CommSemiring Q] (hy : M ≤ T.comap g)

variable [Algebra P Q] [IsLocalization T Q]

section

variable (Q)

/-- Map a homomorphism `g : R →+* P` to `S →+* Q`, where `S` and `Q` are
localizations of `R` and `P` at `M` and `T` respectively,
such that `g(M) ⊆ T`.

We send `z : S` to `algebra_map P Q (g x) * (algebra_map P Q (g y))⁻¹`, where
`(x, y) : R × M` are such that `z = f x * (f y)⁻¹`. -/
noncomputable def map (g : R →+* P) (hy : M ≤ T.comap g) : S →+* Q :=
  @lift R _ M _ _ _ _ _ _ ((algebraMap P Q).comp g) fun y => map_units _ ⟨g y, hy y.2⟩
#align is_localization.map IsLocalization.map

end

theorem map_eq (x) : map Q g hy ((algebraMap R S) x) = algebraMap P Q (g x) :=
  lift_eq (fun y => map_units _ ⟨g y, hy y.2⟩) x
#align is_localization.map_eq IsLocalization.map_eq

@[simp]
theorem map_comp : (map Q g hy).comp (algebraMap R S) = (algebraMap P Q).comp g :=
  lift_comp fun y => map_units _ ⟨g y, hy y.2⟩
#align is_localization.map_comp IsLocalization.map_comp

theorem map_mk' (x) (y : M) : map Q g hy (mk' S x y) = mk' Q (g x) ⟨g y, hy y.2⟩ :=
  @Submonoid.LocalizationMap.map_mk' _ _ _ _ _ _ _ (toLocalizationMap M S) g.toMonoidHom _
    (fun y => hy y.2) _ _ (toLocalizationMap T Q) _ _
#align is_localization.map_mk' IsLocalization.map_mk'

@[simp]
theorem map_id (z : S) (h : M ≤ M.comap (RingHom.id R) := le_refl M) :
    map S (RingHom.id _) h z = z :=
  lift_id _
#align is_localization.map_id IsLocalization.map_id

theorem map_unique (j : S →+* Q) (hj : ∀ x : R, j (algebraMap R S x) = algebraMap P Q (g x)) :
    map Q g hy = j :=
  lift_unique (fun y => map_units _ ⟨g y, hy y.2⟩) hj
#align is_localization.map_unique IsLocalization.map_unique

/-- If `comm_semiring` homs `g : R →+* P, l : P →+* A` induce maps of localizations, the composition
of the induced maps equals the map of localizations induced by `l ∘ g`. -/
theorem map_comp_map {A : Type _} [CommSemiring A] {U : Submonoid A} {W} [CommSemiring W]
    [Algebra A W] [IsLocalization U W] {l : P →+* A} (hl : T ≤ U.comap l) :
    (map W l hl).comp (map Q g hy : S →+* _) = map W (l.comp g) fun x hx => hl (hy hx) :=
  RingHom.ext fun x =>
    @Submonoid.LocalizationMap.map_map _ _ _ _ _ P _ (toLocalizationMap M S) g _ _ _ _ _ _ _ _ _ _
      (toLocalizationMap U W) l _ x
#align is_localization.map_comp_map IsLocalization.map_comp_map

/-- If `comm_semiring` homs `g : R →+* P, l : P →+* A` induce maps of localizations, the composition
of the induced maps equals the map of localizations induced by `l ∘ g`. -/
theorem map_map {A : Type _} [CommSemiring A] {U : Submonoid A} {W} [CommSemiring W] [Algebra A W]
    [IsLocalization U W] {l : P →+* A} (hl : T ≤ U.comap l) (x : S) :
    map W l hl (map Q g hy x) = map W (l.comp g) (fun x hx => hl (hy hx)) x := by
  rw [← map_comp_map hy hl] <;> rfl
#align is_localization.map_map IsLocalization.map_map

theorem map_smul (x : S) (z : R) : map Q g hy (z • x : S) = g z • map Q g hy x := by
  rw [Algebra.smul_def, Algebra.smul_def, RingHom.map_mul, map_eq]
#align is_localization.map_smul IsLocalization.map_smul

section

variable (S Q)

/-- If `S`, `Q` are localizations of `R` and `P` at submonoids `M, T` respectively, an
isomorphism `j : R ≃+* P` such that `j(M) = T` induces an isomorphism of localizations
`S ≃+* Q`. -/
@[simps]
noncomputable def ringEquivOfRingEquiv (h : R ≃+* P) (H : M.map h.toMonoidHom = T) : S ≃+* Q :=
  have H' : T.map h.symm.toMonoidHom = M := by
    rw [← M.map_id, ← H, Submonoid.map_map]
    congr
    ext
    apply h.symm_apply_apply
  { map Q (h : R →+* P) _ with toFun := map Q (h : R →+* P) (M.le_comap_of_map_le (le_of_eq H)),
    invFun := map S (h.symm : P →+* R) (T.le_comap_of_map_le (le_of_eq H')),
    left_inv := fun x => by
      rw [map_map, map_unique _ (RingHom.id _), RingHom.id_apply]
      intro x
      convert congr_arg (algebraMap R S) (h.symm_apply_apply x).symm,
    right_inv := fun x => by
      rw [map_map, map_unique _ (RingHom.id _), RingHom.id_apply]
      intro x
      convert congr_arg (algebraMap P Q) (h.apply_symm_apply x).symm }
#align is_localization.ring_equiv_of_ring_equiv IsLocalization.ringEquivOfRingEquiv

end

theorem ring_equiv_of_ring_equiv_eq_map {j : R ≃+* P} (H : M.map j.toMonoidHom = T) :
    (ringEquivOfRingEquiv S Q j H : S →+* Q) =
      map Q (j : R →+* P) (M.le_comap_of_map_le (le_of_eq H)) :=
  rfl
#align
  is_localization.ring_equiv_of_ring_equiv_eq_map IsLocalization.ring_equiv_of_ring_equiv_eq_map

@[simp]
theorem ring_equiv_of_ring_equiv_eq {j : R ≃+* P} (H : M.map j.toMonoidHom = T) (x) :
    ringEquivOfRingEquiv S Q j H ((algebraMap R S) x) = algebraMap P Q (j x) :=
  map_eq _ _
#align is_localization.ring_equiv_of_ring_equiv_eq IsLocalization.ring_equiv_of_ring_equiv_eq

theorem ring_equiv_of_ring_equiv_mk' {j : R ≃+* P} (H : M.map j.toMonoidHom = T) (x : R) (y : M) :
    ringEquivOfRingEquiv S Q j H (mk' S x y) =
      mk' Q (j x) ⟨j y, show j y ∈ T from H ▸ Set.mem_image_of_mem j y.2⟩ :=
  map_mk' _ _ _
#align is_localization.ring_equiv_of_ring_equiv_mk' IsLocalization.ring_equiv_of_ring_equiv_mk'

end Map

section AlgEquiv

variable {Q : Type _} [CommSemiring Q] [Algebra R Q] [IsLocalization M Q]

section

variable (M S Q)

/-- If `S`, `Q` are localizations of `R` at the submonoid `M` respectively,
there is an isomorphism of localizations `S ≃ₐ[R] Q`. -/
@[simps]
noncomputable def algEquiv : S ≃ₐ[R] Q :=
  { ringEquivOfRingEquiv S Q (RingEquiv.refl R) M.map_id with
    commutes' := ring_equiv_of_ring_equiv_eq _ }
#align is_localization.alg_equiv IsLocalization.algEquiv

end

@[simp]
theorem alg_equiv_mk' (x : R) (y : M) : algEquiv M S Q (mk' S x y) = mk' Q x y :=
  map_mk' _ _ _
#align is_localization.alg_equiv_mk' IsLocalization.alg_equiv_mk'

@[simp]
theorem alg_equiv_symm_mk' (x : R) (y : M) : (algEquiv M S Q).symm (mk' Q x y) = mk' S x y :=
  map_mk' _ _ _
#align is_localization.alg_equiv_symm_mk' IsLocalization.alg_equiv_symm_mk'

end AlgEquiv

end IsLocalization

section

variable (M)

theorem is_localization_of_alg_equiv [Algebra R P] [IsLocalization M S] (h : S ≃ₐ[R] P) :
    IsLocalization M P := by 
  constructor
  · intro y
    convert (IsLocalization.map_units S y).map h.to_alg_hom.to_ring_hom.to_monoid_hom
    exact (h.commutes y).symm
  · intro y
    obtain ⟨⟨x, s⟩, e⟩ := IsLocalization.surj M (h.symm y)
    apply_fun h  at e
    simp only [h.map_mul, h.apply_symm_apply, h.commutes] at e
    exact ⟨⟨x, s⟩, e⟩
  · intro x y
    rw [← h.symm.to_equiv.injective.eq_iff, ← IsLocalization.eq_iff_exists M S, ← h.symm.commutes, ←
      h.symm.commutes]
    rfl
#align is_localization.is_localization_of_alg_equiv IsLocalization.is_localization_of_alg_equiv

theorem is_localization_iff_of_alg_equiv [Algebra R P] (h : S ≃ₐ[R] P) :
    IsLocalization M S ↔ IsLocalization M P :=
  ⟨fun _ => is_localization_of_alg_equiv M h, fun _ => is_localization_of_alg_equiv M h.symm⟩
#align
  is_localization.is_localization_iff_of_alg_equiv IsLocalization.is_localization_iff_of_alg_equiv

theorem is_localization_iff_of_ring_equiv (h : S ≃+* P) :
    IsLocalization M S ↔ @IsLocalization _ M P _ (h.toRingHom.comp <| algebraMap R S).toAlgebra :=
  letI := (h.to_ring_hom.comp <| algebraMap R S).toAlgebra
  is_localization_iff_of_alg_equiv M { h with commutes' := fun _ => rfl }
#align
  is_localization.is_localization_iff_of_ring_equiv IsLocalization.is_localization_iff_of_ring_equiv

variable (S)

theorem is_localization_of_base_ring_equiv [IsLocalization M S] (h : R ≃+* P) :
    @IsLocalization _ (M.map h.toMonoidHom) S _
      ((algebraMap R S).comp h.symm.toRingHom).toAlgebra :=
  by 
  constructor
  · rintro ⟨_, ⟨y, hy, rfl⟩⟩
    convert IsLocalization.map_units S ⟨y, hy⟩
    dsimp only [RingHom.algebra_map_to_algebra, RingHom.comp_apply]
    exact congr_arg _ (h.symm_apply_apply _)
  · intro y
    obtain ⟨⟨x, s⟩, e⟩ := IsLocalization.surj M y
    refine' ⟨⟨h x, _, _, s.prop, rfl⟩, _⟩
    dsimp only [RingHom.algebra_map_to_algebra, RingHom.comp_apply] at e⊢
    convert e <;> exact h.symm_apply_apply _
  · intro x y
    rw [RingHom.algebra_map_to_algebra, RingHom.comp_apply, RingHom.comp_apply,
      IsLocalization.eq_iff_exists M S]
    simp_rw [← h.to_equiv.apply_eq_iff_eq]
    change (∃ c : M, h (h.symm x * c) = h (h.symm y * c)) ↔ _
    simp only [RingEquiv.apply_symm_apply, RingEquiv.map_mul]
    exact
      ⟨fun ⟨c, e⟩ => ⟨⟨_, _, c.Prop, rfl⟩, e⟩, fun ⟨⟨_, c, h, e₁⟩, e₂⟩ => ⟨⟨_, h⟩, e₁.symm ▸ e₂⟩⟩
#align
  is_localization.is_localization_of_base_ring_equiv IsLocalization.is_localization_of_base_ring_equiv

theorem is_localization_iff_of_base_ring_equiv (h : R ≃+* P) :
    IsLocalization M S ↔
      @IsLocalization _ (M.map h.toMonoidHom) S _
        ((algebraMap R S).comp h.symm.toRingHom).toAlgebra :=
  by 
  refine' ⟨fun _ => is_localization_of_base_ring_equiv _ _ h, _⟩
  letI := ((algebraMap R S).comp h.symm.to_ring_hom).toAlgebra
  intro H
  convert @is_localization_of_base_ring_equiv _ _ _ _ _ _ H h.symm
  · erw [Submonoid.map_equiv_eq_comap_symm, Submonoid.comap_map_eq_of_injective]
    exact h.to_equiv.injective
  rw [RingHom.algebra_map_to_algebra, RingHom.comp_assoc]
  simp only [RingHom.comp_id, RingEquiv.symm_symm, RingEquiv.symm_to_ring_hom_comp_to_ring_hom]
  apply Algebra.algebra_ext
  intro r
  rw [RingHom.algebra_map_to_algebra]
#align
  is_localization.is_localization_iff_of_base_ring_equiv IsLocalization.is_localization_iff_of_base_ring_equiv

end

variable (M S)

include M

theorem non_zero_divisors_le_comap [IsLocalization M S] :
    nonZeroDivisors R ≤ (nonZeroDivisors S).comap (algebraMap R S) := by
  rintro a ha b (e : b * algebraMap R S a = 0)
  obtain ⟨x, s, rfl⟩ := mk'_surjective M b
  rw [← @mk'_one R _ M, ← mk'_mul, ← (algebraMap R S).map_zero, ← @mk'_one R _ M,
    IsLocalization.eq] at e
  obtain ⟨c, e⟩ := e
  rw [zero_mul, zero_mul, Submonoid.coe_one, mul_one, mul_comm x a, mul_assoc, mul_comm] at e
  rw [mk'_eq_zero_iff]
  exact ⟨c, ha _ e⟩
#align is_localization.non_zero_divisors_le_comap IsLocalization.non_zero_divisors_le_comap

theorem map_non_zero_divisors_le [IsLocalization M S] :
    (nonZeroDivisors R).map (algebraMap R S) ≤ nonZeroDivisors S :=
  Submonoid.map_le_iff_le_comap.mpr (non_zero_divisors_le_comap M S)
#align is_localization.map_non_zero_divisors_le IsLocalization.map_non_zero_divisors_le

end IsLocalization

namespace Localization

open IsLocalization

/-! ### Constructing a localization at a given submonoid -/


variable {M}

section

instance [Subsingleton R] : Unique (Localization M) :=
  ⟨⟨1⟩, by intro a; induction a; induction default; congr ; rfl; rfl⟩

/-- Addition in a ring localization is defined as `⟨a, b⟩ + ⟨c, d⟩ = ⟨b * c + d * a, b * d⟩`.

Should not be confused with `add_localization.add`, which is defined as
`⟨a, b⟩ + ⟨c, d⟩ = ⟨a + c, b + d⟩`.
-/
protected irreducible_def add (z w : Localization M) : Localization M :=
  (Localization.liftOn₂ z w fun a b c d => mk ((b : R) * c + d * a) (b * d))
    fun a a' b b' c c' d d' h1 h2 =>
    mk_eq_mk_iff.2
      (by 
        rw [r_eq_r'] at h1 h2⊢
        cases' h1 with t₅ ht₅
        cases' h2 with t₆ ht₆
        use t₆ * t₅
        calc
          ((b : R) * c + d * a) * (b' * d') * (t₆ * t₅) =
              c * d' * t₆ * (b * b' * t₅) + a * b' * t₅ * (d * d' * t₆) :=
            by ring
          _ = (b' * c' + d' * a') * (b * d) * (t₆ * t₅) := by rw [ht₆, ht₅] <;> ring
          )
#align localization.add Localization.add

instance : Add (Localization M) :=
  ⟨Localization.add⟩

theorem add_mk (a b c d) : (mk a b : Localization M) + mk c d = mk (b * c + d * a) (b * d) := by
  unfold Add.add Localization.add
  apply lift_on₂_mk
#align localization.add_mk Localization.add_mk

theorem add_mk_self (a b c) : (mk a b : Localization M) + mk c b = mk (a + c) b := by
  rw [add_mk, mk_eq_mk_iff, r_eq_r']
  refine' (r' M).symm ⟨1, _⟩
  simp only [Submonoid.coe_one, Submonoid.coe_mul]
  ring
#align localization.add_mk_self Localization.add_mk_self

/- ./././Mathport/Syntax/Translate/Expr.lean:333:4: warning: unsupported (TODO): `[tacs] -/
private unsafe def tac :=
  sorry
#align localization.tac localization.tac

/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:61:18: unsupported non-interactive tactic _private.1717185221.tac -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:61:18: unsupported non-interactive tactic _private.1717185221.tac -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:61:18: unsupported non-interactive tactic _private.1717185221.tac -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:61:18: unsupported non-interactive tactic _private.1717185221.tac -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:61:18: unsupported non-interactive tactic _private.1717185221.tac -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:61:18: unsupported non-interactive tactic _private.1717185221.tac -/
instance : CommSemiring (Localization M) :=
  { Localization.commMonoidWithZero M with zero := 0, one := 1, add := (· + ·), mul := (· * ·),
    npow := Localization.npow _, nsmul := (· • ·),
    nsmul_zero' := fun x =>
      Localization.induction_on x fun x => by simp only [smul_mk, zero_nsmul, mk_zero],
    nsmul_succ' := fun n x =>
      Localization.induction_on x fun x => by simp only [smul_mk, succ_nsmul, add_mk_self],
    add_assoc := fun m n k =>
      Localization.induction_on₃ m n k
        (by
          run_tac
            tac),
    zero_add := fun y =>
      Localization.induction_on y
        (by
          run_tac
            tac),
    add_zero := fun y =>
      Localization.induction_on y
        (by
          run_tac
            tac),
    add_comm := fun y z =>
      Localization.induction_on₂ z y
        (by
          run_tac
            tac),
    left_distrib := fun m n k =>
      Localization.induction_on₃ m n k
        (by
          run_tac
            tac),
    right_distrib := fun m n k =>
      Localization.induction_on₃ m n k
        (by
          run_tac
            tac) }

/-- For any given denominator `b : M`, the map `a ↦ a / b` is an `add_monoid_hom` from `R` to
  `localization M`-/
@[simps]
def mkAddMonoidHom (b : M) :
    R →+ Localization M where 
  toFun a := mk a b
  map_zero' := mk_zero _
  map_add' x y := (add_mk_self _ _ _).symm
#align localization.mk_add_monoid_hom Localization.mkAddMonoidHom

theorem mk_sum {ι : Type _} (f : ι → R) (s : Finset ι) (b : M) :
    mk (∑ i in s, f i) b = ∑ i in s, mk (f i) b :=
  (mkAddMonoidHom b).map_sum f s
#align localization.mk_sum Localization.mk_sum

theorem mk_list_sum (l : List R) (b : M) : mk l.Sum b = (l.map fun a => mk a b).Sum :=
  (mkAddMonoidHom b).map_list_sum l
#align localization.mk_list_sum Localization.mk_list_sum

theorem mk_multiset_sum (l : Multiset R) (b : M) : mk l.Sum b = (l.map fun a => mk a b).Sum :=
  (mkAddMonoidHom b).map_multiset_sum l
#align localization.mk_multiset_sum Localization.mk_multiset_sum

instance {S : Type _} [Monoid S] [DistribMulAction S R] [IsScalarTower S R R] :
    DistribMulAction S
      (Localization
        M) where 
  smul_zero s := by simp only [← Localization.mk_zero 1, Localization.smul_mk, smul_zero]
  smul_add s x y :=
    Localization.induction_on₂ x y <|
      Prod.rec fun r₁ x₁ =>
        Prod.rec fun r₂ x₂ => by
          simp only [Localization.smul_mk, Localization.add_mk, smul_add, mul_comm _ (s • _),
            mul_comm _ r₁, mul_comm _ r₂, smul_mul_assoc]

instance {S : Type _} [Semiring S] [MulSemiringAction S R] [IsScalarTower S R R] :
    MulSemiringAction S (Localization M) :=
  { Localization.mulDistribMulAction with }

instance {S : Type _} [Semiring S] [Module S R] [IsScalarTower S R R] : Module S (Localization M) :=
  { Localization.distribMulAction with
    zero_smul :=
      Localization.ind <|
        Prod.rec <| by 
          intros
          simp only [Localization.smul_mk, zero_smul, mk_zero],
    add_smul := fun s₁ s₂ =>
      Localization.ind <|
        Prod.rec <| by 
          intros
          simp only [Localization.smul_mk, add_smul, add_mk_self] }

instance {S : Type _} [CommSemiring S] [Algebra S R] :
    Algebra S
      (Localization
        M) where 
  toRingHom :=
    RingHom.comp
      { Localization.monoidOf M with toFun := (monoidOf M).toMap,
        map_zero' := by rw [← mk_zero (1 : M), mk_one_eq_monoid_of_mk],
        map_add' := fun x y => by
          simp only [← mk_one_eq_monoid_of_mk, add_mk, Submonoid.coe_one, one_mul, add_comm] }
      (algebraMap S R)
  smul_def' s :=
    Localization.ind <|
      Prod.rec <| by 
        intro r x
        dsimp
        simp only [← mk_one_eq_monoid_of_mk, mk_mul, Localization.smul_mk, one_mul,
          Algebra.smul_def]
  commutes' s :=
    Localization.ind <|
      Prod.rec <| by 
        intro r x
        dsimp
        simp only [← mk_one_eq_monoid_of_mk, mk_mul, Localization.smul_mk, one_mul, mul_one,
          Algebra.commutes]

instance :
    IsLocalization M
      (Localization
        M) where 
  map_units := (Localization.monoidOf M).map_units
  surj := (Localization.monoidOf M).surj
  eq_iff_exists _ _ := (Localization.monoidOf M).eq_iff_exists

end

@[simp]
theorem to_localization_map_eq_monoid_of : toLocalizationMap M (Localization M) = monoidOf M :=
  rfl
#align localization.to_localization_map_eq_monoid_of Localization.to_localization_map_eq_monoid_of

theorem monoid_of_eq_algebra_map (x) : (monoidOf M).toMap x = algebraMap R (Localization M) x :=
  rfl
#align localization.monoid_of_eq_algebra_map Localization.monoid_of_eq_algebra_map

theorem mk_one_eq_algebra_map (x) : mk x 1 = algebraMap R (Localization M) x :=
  rfl
#align localization.mk_one_eq_algebra_map Localization.mk_one_eq_algebra_map

theorem mk_eq_mk'_apply (x y) : mk x y = IsLocalization.mk' (Localization M) x y := by
  rw [mk_eq_monoid_of_mk'_apply, mk', to_localization_map_eq_monoid_of]
#align localization.mk_eq_mk'_apply Localization.mk_eq_mk'_apply

@[simp]
theorem mk_eq_mk' : (mk : R → M → Localization M) = IsLocalization.mk' (Localization M) :=
  mk_eq_monoid_of_mk'
#align localization.mk_eq_mk' Localization.mk_eq_mk'

theorem mk_algebra_map {A : Type _} [CommSemiring A] [Algebra A R] (m : A) :
    mk (algebraMap A R m) 1 = algebraMap A (Localization M) m := by
  rw [mk_eq_mk', mk'_eq_iff_eq_mul, Submonoid.coe_one, map_one, mul_one] <;> rfl
#align localization.mk_algebra_map Localization.mk_algebra_map

theorem mk_nat_cast (m : ℕ) : (mk m 1 : Localization M) = m := by
  simpa using @mk_algebra_map R _ M ℕ _ _ m
#align localization.mk_nat_cast Localization.mk_nat_cast

variable [IsLocalization M S]

section

variable (M S)

/-- The localization of `R` at `M` as a quotient type is isomorphic to any other localization. -/
@[simps]
noncomputable def algEquiv : Localization M ≃ₐ[R] S :=
  IsLocalization.algEquiv M _ _
#align localization.alg_equiv Localization.algEquiv

/-- The localization of a singleton is a singleton. Cannot be an instance due to metavariables. -/
noncomputable def IsLocalization.unique (R Rₘ) [CommSemiring R] [CommSemiring Rₘ] (M : Submonoid R)
    [Subsingleton R] [Algebra R Rₘ] [IsLocalization M Rₘ] : Unique Rₘ :=
  have : Inhabited Rₘ := ⟨1⟩
  (AlgEquiv M Rₘ).symm.Injective.unique
#align is_localization.unique IsLocalization.unique

end

@[simp]
theorem alg_equiv_mk' (x : R) (y : M) : algEquiv M S (mk' (Localization M) x y) = mk' S x y :=
  alg_equiv_mk' _ _
#align localization.alg_equiv_mk' Localization.alg_equiv_mk'

@[simp]
theorem alg_equiv_symm_mk' (x : R) (y : M) :
    (algEquiv M S).symm (mk' S x y) = mk' (Localization M) x y :=
  alg_equiv_symm_mk' _ _
#align localization.alg_equiv_symm_mk' Localization.alg_equiv_symm_mk'

theorem alg_equiv_mk (x y) : algEquiv M S (mk x y) = mk' S x y := by rw [mk_eq_mk', alg_equiv_mk']
#align localization.alg_equiv_mk Localization.alg_equiv_mk

theorem alg_equiv_symm_mk (x : R) (y : M) : (algEquiv M S).symm (mk' S x y) = mk x y := by
  rw [mk_eq_mk', alg_equiv_symm_mk']
#align localization.alg_equiv_symm_mk Localization.alg_equiv_symm_mk

end Localization

end CommSemiring

section CommRing

variable {R : Type _} [CommRing R] {M : Submonoid R} (S : Type _) [CommRing S]

variable [Algebra R S] {P : Type _} [CommRing P]

namespace Localization

/-- Negation in a ring localization is defined as `-⟨a, b⟩ = ⟨-a, b⟩`. -/
protected irreducible_def neg (z : Localization M) : Localization M :=
  (Localization.liftOn z fun a b => mk (-a) b) fun a b c d h =>
    mk_eq_mk_iff.2
      (by 
        rw [r_eq_r'] at h⊢
        cases' h with t ht
        use t
        rw [neg_mul, neg_mul, ht]
        ring_nf)
#align localization.neg Localization.neg

instance : Neg (Localization M) :=
  ⟨Localization.neg⟩

theorem neg_mk (a b) : -(mk a b : Localization M) = mk (-a) b := by
  unfold Neg.neg Localization.neg
  apply lift_on_mk
#align localization.neg_mk Localization.neg_mk

instance : CommRing (Localization M) :=
  { Localization.commSemiring with zsmul := (· • ·),
    zsmul_zero' := fun x =>
      Localization.induction_on x fun x => by simp only [smul_mk, zero_zsmul, mk_zero],
    zsmul_succ' := fun n x =>
      Localization.induction_on x fun x => by
        simp [smul_mk, add_mk_self, -mk_eq_monoid_of_mk', add_comm (n : ℤ) 1, add_smul],
    zsmul_neg' := fun n x =>
      Localization.induction_on x fun x => by
        rw [smul_mk, smul_mk, neg_mk, ← neg_smul]
        rfl,
    neg := Neg.neg, sub := fun x y => x + -y, sub_eq_add_neg := fun x y => rfl,
    add_left_neg := fun y =>
      Localization.induction_on y
        (by 
          intros
          simp only [add_mk, Localization.mk_mul, neg_mk, ← mk_zero 1]
          refine' mk_eq_mk_iff.mpr (r_of_eq _)
          simp only [Submonoid.coe_mul]
          ring) }

theorem sub_mk (a c) (b d) : (mk a b : Localization M) - mk c d = mk (d * a - b * c) (b * d) :=
  calc
    mk a b - mk c d = mk a b + -mk c d := sub_eq_add_neg _ _
    _ = mk a b + mk (-c) d := by rw [neg_mk]
    _ = mk (b * -c + d * a) (b * d) := add_mk _ _ _ _
    _ = mk (d * a - b * c) (b * d) := by congr <;> ring
    
#align localization.sub_mk Localization.sub_mk

theorem mk_int_cast (m : ℤ) : (mk m 1 : Localization M) = m := by
  simpa using @mk_algebra_map R _ M ℤ _ _ m
#align localization.mk_int_cast Localization.mk_int_cast

end Localization

namespace IsLocalization

variable {R M} (S) {K : Type _} [IsLocalization M S]

theorem to_map_eq_zero_iff {x : R} (hM : M ≤ nonZeroDivisors R) : algebraMap R S x = 0 ↔ x = 0 := by
  rw [← (algebraMap R S).map_zero]
  constructor <;> intro h
  · cases' (eq_iff_exists M S).mp h with c hc
    rw [zero_mul] at hc
    exact hM c.2 x hc
  · rw [h]
#align is_localization.to_map_eq_zero_iff IsLocalization.to_map_eq_zero_iff

protected theorem injective (hM : M ≤ nonZeroDivisors R) : Injective (algebraMap R S) := by
  rw [injective_iff_map_eq_zero (algebraMap R S)]
  intro a ha
  rwa [to_map_eq_zero_iff S hM] at ha
#align is_localization.injective IsLocalization.injective

protected theorem to_map_ne_zero_of_mem_non_zero_divisors [Nontrivial R]
    (hM : M ≤ nonZeroDivisors R) {x : R} (hx : x ∈ nonZeroDivisors R) : algebraMap R S x ≠ 0 :=
  show (algebraMap R S).toMonoidWithZeroHom x ≠ 0 from
    map_ne_zero_of_mem_non_zero_divisors (algebraMap R S) (IsLocalization.injective S hM) hx
#align
  is_localization.to_map_ne_zero_of_mem_non_zero_divisors IsLocalization.to_map_ne_zero_of_mem_non_zero_divisors

variable {S}

theorem sec_snd_ne_zero [Nontrivial R] (hM : M ≤ nonZeroDivisors R) (x : S) :
    ((sec M x).snd : R) ≠ 0 :=
  nonZeroDivisors.coe_ne_zero ⟨(sec M x).snd.val, hM (sec M x).snd.property⟩
#align is_localization.sec_snd_ne_zero IsLocalization.sec_snd_ne_zero

theorem sec_fst_ne_zero [Nontrivial R] [NoZeroDivisors S] (hM : M ≤ nonZeroDivisors R) {x : S}
    (hx : x ≠ 0) : (sec M x).fst ≠ 0 := by
  have hsec := sec_spec M x
  intro hfst
  rw [hfst, map_zero, mul_eq_zero, _root_.map_eq_zero_iff] at hsec
  · exact Or.elim hsec hx (sec_snd_ne_zero hM x)
  · exact IsLocalization.injective S hM
#align is_localization.sec_fst_ne_zero IsLocalization.sec_fst_ne_zero

variable (S M) (Q : Type _) [CommRing Q] {g : R →+* P} [Algebra P Q]

/-- Injectivity of a map descends to the map induced on localizations. -/
theorem map_injective_of_injective (hg : Function.Injective g)
    [IsLocalization (M.map g : Submonoid P) Q] :
    Function.Injective (map Q g M.le_comap_map : S → Q) := by
  rw [injective_iff_map_eq_zero]
  intro z hz
  obtain ⟨a, b, rfl⟩ := mk'_surjective M z
  rw [map_mk', mk'_eq_zero_iff] at hz
  obtain ⟨⟨m', hm'⟩, hm⟩ := hz
  rw [Submonoid.mem_map] at hm'
  obtain ⟨n, hn, hnm⟩ := hm'
  rw [Subtype.coe_mk, ← hnm, ← map_mul, ← map_zero g] at hm
  rw [mk'_eq_zero_iff]
  exact ⟨⟨n, hn⟩, hg hm⟩
#align is_localization.map_injective_of_injective IsLocalization.map_injective_of_injective

variable {S Q M}

variable (A : Type _) [CommRing A] [IsDomain A]

/-- A `comm_ring` `S` which is the localization of an integral domain `R` at a subset of
non-zero elements is an integral domain.
See note [reducible non-instances]. -/
@[reducible]
theorem is_domain_of_le_non_zero_divisors [Algebra A S] {M : Submonoid A} [IsLocalization M S]
    (hM : M ≤ nonZeroDivisors A) : IsDomain S :=
  { eq_zero_or_eq_zero_of_mul_eq_zero := by 
      intro z w h
      cases' surj M z with x hx
      cases' surj M w with y hy
      have :
        z * w * algebraMap A S y.2 * algebraMap A S x.2 = algebraMap A S x.1 * algebraMap A S y.1 :=
        by rw [mul_assoc z, hy, ← hx] <;> ring
      rw [h, zero_mul, zero_mul, ← (algebraMap A S).map_mul] at this
      cases' eq_zero_or_eq_zero_of_mul_eq_zero ((to_map_eq_zero_iff S hM).mp this.symm) with H H
      · exact Or.inl (eq_zero_of_fst_eq_zero hx H)
      · exact Or.inr (eq_zero_of_fst_eq_zero hy H),
    exists_pair_ne :=
      ⟨(algebraMap A S) 0, (algebraMap A S) 1, fun h =>
        zero_ne_one (IsLocalization.injective S hM h)⟩ }
#align
  is_localization.is_domain_of_le_non_zero_divisors IsLocalization.is_domain_of_le_non_zero_divisors

variable {A}

/-- The localization at of an integral domain to a set of non-zero elements is an integral domain.
See note [reducible non-instances]. -/
@[reducible]
theorem is_domain_localization {M : Submonoid A} (hM : M ≤ nonZeroDivisors A) :
    IsDomain (Localization M) :=
  is_domain_of_le_non_zero_divisors _ hM
#align is_localization.is_domain_localization IsLocalization.is_domain_localization

end IsLocalization

open IsLocalization

/-- If `R` is a field, then localizing at a submonoid not containing `0` adds no new elements. -/
theorem IsField.localization_map_bijective {R Rₘ : Type _} [CommRing R] [CommRing Rₘ]
    {M : Submonoid R} (hM : (0 : R) ∉ M) (hR : IsField R) [Algebra R Rₘ] [IsLocalization M Rₘ] :
    Function.Bijective (algebraMap R Rₘ) := by
  letI := hR.to_field
  replace hM := le_non_zero_divisors_of_no_zero_divisors hM
  refine' ⟨IsLocalization.injective _ hM, fun x => _⟩
  obtain ⟨r, ⟨m, hm⟩, rfl⟩ := mk'_surjective M x
  obtain ⟨n, hn⟩ := hR.mul_inv_cancel (nonZeroDivisors.ne_zero <| hM hm)
  exact ⟨r * n, by erw [eq_mk'_iff_mul_eq, ← map_mul, mul_assoc, mul_comm n, hn, mul_one]⟩
#align is_field.localization_map_bijective IsField.localization_map_bijective

/-- If `R` is a field, then localizing at a submonoid not containing `0` adds no new elements. -/
theorem Field.localization_map_bijective {K Kₘ : Type _} [Field K] [CommRing Kₘ] {M : Submonoid K}
    (hM : (0 : K) ∉ M) [Algebra K Kₘ] [IsLocalization M Kₘ] :
    Function.Bijective (algebraMap K Kₘ) :=
  (Field.to_is_field K).localization_map_bijective hM
#align field.localization_map_bijective Field.localization_map_bijective

-- this looks weird due to the `letI` inside the above lemma, but trying to do it the other
-- way round causes issues with defeq of instances, so this is actually easier.
section Algebra

variable {R S} {Rₘ Sₘ : Type _} [CommRing Rₘ] [CommRing Sₘ]

variable [Algebra R Rₘ] [IsLocalization M Rₘ]

variable [Algebra S Sₘ] [IsLocalization (Algebra.algebraMapSubmonoid S M) Sₘ]

section

variable (S M)

/-- Definition of the natural algebra induced by the localization of an algebra.
Given an algebra `R → S`, a submonoid `R` of `M`, and a localization `Rₘ` for `M`,
let `Sₘ` be the localization of `S` to the image of `M` under `algebra_map R S`.
Then this is the natural algebra structure on `Rₘ → Sₘ`, such that the entire square commutes,
where `localization_map.map_comp` gives the commutativity of the underlying maps -/
noncomputable def localizationAlgebra : Algebra Rₘ Sₘ :=
  (map Sₘ (algebraMap R S)
        (show _ ≤ (Algebra.algebraMapSubmonoid S M).comap _ from M.le_comap_map) :
      Rₘ →+* Sₘ).toAlgebra
#align localization_algebra localizationAlgebra

end

theorem algebra_map_mk' (r : R) (m : M) :
    (@algebraMap Rₘ Sₘ _ _ (localizationAlgebra M S)) (mk' Rₘ r m) =
      mk' Sₘ (algebraMap R S r) ⟨algebraMap R S m, Algebra.mem_algebra_map_submonoid_of_mem m⟩ :=
  map_mk' _ _ _
#align algebra_map_mk' algebra_map_mk'

variable (Rₘ Sₘ)

/-- Injectivity of the underlying `algebra_map` descends to the algebra induced by localization. -/
theorem localization_algebra_injective (hRS : Function.Injective (algebraMap R S)) :
    Function.Injective (@algebraMap Rₘ Sₘ _ _ (localizationAlgebra M S)) :=
  IsLocalization.map_injective_of_injective M Rₘ Sₘ hRS
#align localization_algebra_injective localization_algebra_injective

end Algebra

end CommRing

