/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Chris Hughes, Mario Carneiro

! This file was ported from Lean 3 source module ring_theory.ideal.local_ring
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Algebra.Basic
import Mathbin.RingTheory.Ideal.Operations
import Mathbin.RingTheory.JacobsonIdeal
import Mathbin.Logic.Equiv.TransferInstance

/-!

# Local rings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Define local rings as commutative rings having a unique maximal ideal.

## Main definitions

* `local_ring`: A predicate on commutative semirings, stating that for any pair of elements that
  adds up to `1`, one of them is a unit. This is shown to be equivalent to the condition that there
  exists a unique maximal ideal.
* `local_ring.maximal_ideal`: The unique maximal ideal for a local rings. Its carrier set is the
  set of non units.
* `is_local_ring_hom`: A predicate on semiring homomorphisms, requiring that it maps nonunits
  to nonunits. For local rings, this means that the image of the unique maximal ideal is again
  contained in the unique maximal ideal.
* `local_ring.residue_field`: The quotient of a local ring by its maximal ideal.

-/


universe u v w u'

variable {R : Type u} {S : Type v} {T : Type w} {K : Type u'}

#print LocalRing /-
/-- A semiring is local if it is nontrivial and `a` or `b` is a unit whenever `a + b = 1`.
Note that `local_ring` is a predicate. -/
class LocalRing (R : Type u) [Semiring R] extends Nontrivial R : Prop where
  of_is_unit_or_is_unit_of_add_one ::
  isUnit_or_isUnit_of_add_one {a b : R} (h : a + b = 1) : IsUnit a ∨ IsUnit b
#align local_ring LocalRing
-/

section CommSemiring

variable [CommSemiring R]

namespace LocalRing

#print LocalRing.of_isUnit_or_isUnit_of_isUnit_add /-
theorem of_isUnit_or_isUnit_of_isUnit_add [Nontrivial R]
    (h : ∀ a b : R, IsUnit (a + b) → IsUnit a ∨ IsUnit b) : LocalRing R :=
  ⟨fun a b hab => h a b <| hab.symm ▸ isUnit_one⟩
#align local_ring.of_is_unit_or_is_unit_of_is_unit_add LocalRing.of_isUnit_or_isUnit_of_isUnit_add
-/

#print LocalRing.of_nonunits_add /-
/-- A semiring is local if it is nontrivial and the set of nonunits is closed under the addition. -/
theorem of_nonunits_add [Nontrivial R]
    (h : ∀ a b : R, a ∈ nonunits R → b ∈ nonunits R → a + b ∈ nonunits R) : LocalRing R :=
  ⟨fun a b hab => or_iff_not_and_not.2 fun H => h a b H.1 H.2 <| hab.symm ▸ isUnit_one⟩
#align local_ring.of_nonunits_add LocalRing.of_nonunits_add
-/

#print LocalRing.of_unique_max_ideal /-
/-- A semiring is local if it has a unique maximal ideal. -/
theorem of_unique_max_ideal (h : ∃! I : Ideal R, I.IsMaximal) : LocalRing R :=
  @of_nonunits_add _ _
    (nontrivial_of_ne (0 : R) 1 <|
      let ⟨I, Imax, _⟩ := h
      fun H : 0 = 1 => Imax.1.1 <| I.eq_top_iff_one.2 <| H ▸ I.zero_mem)
    fun x y hx hy H =>
    let ⟨I, Imax, Iuniq⟩ := h
    let ⟨Ix, Ixmax, Hx⟩ := exists_max_ideal_of_mem_nonunits hx
    let ⟨Iy, Iymax, Hy⟩ := exists_max_ideal_of_mem_nonunits hy
    have xmemI : x ∈ I := Iuniq Ix Ixmax ▸ Hx
    have ymemI : y ∈ I := Iuniq Iy Iymax ▸ Hy
    Imax.1.1 <| I.eq_top_of_isUnit_mem (I.add_mem xmemI ymemI) H
#align local_ring.of_unique_max_ideal LocalRing.of_unique_max_ideal
-/

#print LocalRing.of_unique_nonzero_prime /-
theorem of_unique_nonzero_prime (h : ∃! P : Ideal R, P ≠ ⊥ ∧ Ideal.IsPrime P) : LocalRing R :=
  of_unique_max_ideal
    (by
      rcases h with ⟨P, ⟨hPnonzero, hPnot_top, _⟩, hPunique⟩
      refine' ⟨P, ⟨⟨hPnot_top, _⟩⟩, fun M hM => hPunique _ ⟨_, Ideal.IsMaximal.isPrime hM⟩⟩
      · refine' Ideal.maximal_of_no_maximal fun M hPM hM => ne_of_lt hPM _
        exact (hPunique _ ⟨ne_bot_of_gt hPM, Ideal.IsMaximal.isPrime hM⟩).symm
      · rintro rfl
        exact hPnot_top (hM.1.2 P (bot_lt_iff_ne_bot.2 hPnonzero)))
#align local_ring.of_unique_nonzero_prime LocalRing.of_unique_nonzero_prime
-/

variable [LocalRing R]

#print LocalRing.isUnit_or_isUnit_of_isUnit_add /-
theorem isUnit_or_isUnit_of_isUnit_add {a b : R} (h : IsUnit (a + b)) : IsUnit a ∨ IsUnit b :=
  by
  rcases h with ⟨u, hu⟩
  rw [← Units.inv_mul_eq_one, mul_add] at hu 
  apply Or.imp _ _ (is_unit_or_is_unit_of_add_one hu) <;> exact isUnit_of_mul_isUnit_right
#align local_ring.is_unit_or_is_unit_of_is_unit_add LocalRing.isUnit_or_isUnit_of_isUnit_add
-/

#print LocalRing.nonunits_add /-
theorem nonunits_add {a b : R} (ha : a ∈ nonunits R) (hb : b ∈ nonunits R) : a + b ∈ nonunits R :=
  fun H => not_or_of_not ha hb (isUnit_or_isUnit_of_isUnit_add H)
#align local_ring.nonunits_add LocalRing.nonunits_add
-/

variable (R)

#print LocalRing.maximalIdeal /-
/-- The ideal of elements that are not units. -/
def maximalIdeal : Ideal R where
  carrier := nonunits R
  zero_mem' := zero_mem_nonunits.2 <| zero_ne_one
  add_mem' x y hx hy := nonunits_add hx hy
  smul_mem' a x := mul_mem_nonunits_right
#align local_ring.maximal_ideal LocalRing.maximalIdeal
-/

#print LocalRing.maximalIdeal.isMaximal /-
instance maximalIdeal.isMaximal : (maximalIdeal R).IsMaximal :=
  by
  rw [Ideal.isMaximal_iff]
  constructor
  · intro h; apply h; exact isUnit_one
  · intro I x hI hx H
    erw [Classical.not_not] at hx 
    rcases hx with ⟨u, rfl⟩
    simpa using I.mul_mem_left (↑u⁻¹) H
#align local_ring.maximal_ideal.is_maximal LocalRing.maximalIdeal.isMaximal
-/

#print LocalRing.maximal_ideal_unique /-
theorem maximal_ideal_unique : ∃! I : Ideal R, I.IsMaximal :=
  ⟨maximalIdeal R, maximalIdeal.isMaximal R, fun I hI =>
    hI.eq_of_le (maximalIdeal.isMaximal R).1.1 fun x hx => hI.1.1 ∘ I.eq_top_of_isUnit_mem hx⟩
#align local_ring.maximal_ideal_unique LocalRing.maximal_ideal_unique
-/

variable {R}

#print LocalRing.eq_maximalIdeal /-
theorem eq_maximalIdeal {I : Ideal R} (hI : I.IsMaximal) : I = maximalIdeal R :=
  ExistsUnique.unique (maximal_ideal_unique R) hI <| maximalIdeal.isMaximal R
#align local_ring.eq_maximal_ideal LocalRing.eq_maximalIdeal
-/

#print LocalRing.le_maximalIdeal /-
theorem le_maximalIdeal {J : Ideal R} (hJ : J ≠ ⊤) : J ≤ maximalIdeal R :=
  by
  rcases Ideal.exists_le_maximal J hJ with ⟨M, hM1, hM2⟩
  rwa [← eq_maximal_ideal hM1]
#align local_ring.le_maximal_ideal LocalRing.le_maximalIdeal
-/

#print LocalRing.mem_maximalIdeal /-
@[simp]
theorem mem_maximalIdeal (x) : x ∈ maximalIdeal R ↔ x ∈ nonunits R :=
  Iff.rfl
#align local_ring.mem_maximal_ideal LocalRing.mem_maximalIdeal
-/

#print LocalRing.isField_iff_maximalIdeal_eq /-
theorem isField_iff_maximalIdeal_eq : IsField R ↔ maximalIdeal R = ⊥ :=
  not_iff_not.mp
    ⟨Ring.ne_bot_of_isMaximal_of_not_isField inferInstance, fun h =>
      Ring.not_isField_iff_exists_prime.mpr ⟨_, h, Ideal.IsMaximal.isPrime' _⟩⟩
#align local_ring.is_field_iff_maximal_ideal_eq LocalRing.isField_iff_maximalIdeal_eq
-/

end LocalRing

end CommSemiring

section CommRing

variable [CommRing R]

namespace LocalRing

#print LocalRing.of_isUnit_or_isUnit_one_sub_self /-
theorem of_isUnit_or_isUnit_one_sub_self [Nontrivial R] (h : ∀ a : R, IsUnit a ∨ IsUnit (1 - a)) :
    LocalRing R :=
  ⟨fun a b hab => add_sub_cancel' a b ▸ hab.symm ▸ h a⟩
#align local_ring.of_is_unit_or_is_unit_one_sub_self LocalRing.of_isUnit_or_isUnit_one_sub_self
-/

variable [LocalRing R]

#print LocalRing.isUnit_or_isUnit_one_sub_self /-
theorem isUnit_or_isUnit_one_sub_self (a : R) : IsUnit a ∨ IsUnit (1 - a) :=
  isUnit_or_isUnit_of_isUnit_add <| (add_sub_cancel'_right a 1).symm ▸ isUnit_one
#align local_ring.is_unit_or_is_unit_one_sub_self LocalRing.isUnit_or_isUnit_one_sub_self
-/

#print LocalRing.isUnit_of_mem_nonunits_one_sub_self /-
theorem isUnit_of_mem_nonunits_one_sub_self (a : R) (h : 1 - a ∈ nonunits R) : IsUnit a :=
  or_iff_not_imp_right.1 (isUnit_or_isUnit_one_sub_self a) h
#align local_ring.is_unit_of_mem_nonunits_one_sub_self LocalRing.isUnit_of_mem_nonunits_one_sub_self
-/

#print LocalRing.isUnit_one_sub_self_of_mem_nonunits /-
theorem isUnit_one_sub_self_of_mem_nonunits (a : R) (h : a ∈ nonunits R) : IsUnit (1 - a) :=
  or_iff_not_imp_left.1 (isUnit_or_isUnit_one_sub_self a) h
#align local_ring.is_unit_one_sub_self_of_mem_nonunits LocalRing.isUnit_one_sub_self_of_mem_nonunits
-/

#print LocalRing.of_surjective' /-
theorem of_surjective' [CommRing S] [Nontrivial S] (f : R →+* S) (hf : Function.Surjective f) :
    LocalRing S :=
  of_isUnit_or_isUnit_one_sub_self
    (by
      intro b
      obtain ⟨a, rfl⟩ := hf b
      apply (is_unit_or_is_unit_one_sub_self a).imp f.is_unit_map _
      rw [← f.map_one, ← f.map_sub]
      apply f.is_unit_map)
#align local_ring.of_surjective' LocalRing.of_surjective'
-/

#print LocalRing.jacobson_eq_maximalIdeal /-
theorem jacobson_eq_maximalIdeal (I : Ideal R) (h : I ≠ ⊤) :
    I.jacobson = LocalRing.maximalIdeal R :=
  by
  apply le_antisymm
  · exact sInf_le ⟨LocalRing.le_maximalIdeal h, LocalRing.maximalIdeal.isMaximal R⟩
  · exact le_sInf fun J (hJ : I ≤ J ∧ J.IsMaximal) => le_of_eq (LocalRing.eq_maximalIdeal hJ.2).symm
#align local_ring.jacobson_eq_maximal_ideal LocalRing.jacobson_eq_maximalIdeal
-/

end LocalRing

end CommRing

#print IsLocalRingHom /-
/-- A local ring homomorphism is a homomorphism `f` between local rings such that `a` in the domain
  is a unit if `f a` is a unit for any `a`. See `local_ring.local_hom_tfae` for other equivalent
  definitions. -/
class IsLocalRingHom [Semiring R] [Semiring S] (f : R →+* S) : Prop where
  map_nonunit : ∀ a, IsUnit (f a) → IsUnit a
#align is_local_ring_hom IsLocalRingHom
-/

section

variable [Semiring R] [Semiring S] [Semiring T]

#print isLocalRingHom_id /-
instance isLocalRingHom_id (R : Type _) [Semiring R] : IsLocalRingHom (RingHom.id R)
    where map_nonunit a := id
#align is_local_ring_hom_id isLocalRingHom_id
-/

#print isUnit_map_iff /-
@[simp]
theorem isUnit_map_iff (f : R →+* S) [IsLocalRingHom f] (a) : IsUnit (f a) ↔ IsUnit a :=
  ⟨IsLocalRingHom.map_nonunit a, f.isUnit_map⟩
#align is_unit_map_iff isUnit_map_iff
-/

#print map_mem_nonunits_iff /-
@[simp]
theorem map_mem_nonunits_iff (f : R →+* S) [IsLocalRingHom f] (a) :
    f a ∈ nonunits S ↔ a ∈ nonunits R :=
  ⟨fun h ha => h <| (isUnit_map_iff f a).mpr ha, fun h ha => h <| (isUnit_map_iff f a).mp ha⟩
#align map_mem_nonunits_iff map_mem_nonunits_iff
-/

#print isLocalRingHom_comp /-
instance isLocalRingHom_comp (g : S →+* T) (f : R →+* S) [IsLocalRingHom g] [IsLocalRingHom f] :
    IsLocalRingHom (g.comp f)
    where map_nonunit a := IsLocalRingHom.map_nonunit a ∘ IsLocalRingHom.map_nonunit (f a)
#align is_local_ring_hom_comp isLocalRingHom_comp
-/

#print isLocalRingHom_equiv /-
instance isLocalRingHom_equiv (f : R ≃+* S) : IsLocalRingHom (f : R →+* S)
    where map_nonunit a ha := by
    convert (f.symm : S →+* R).isUnit_map ha
    exact (RingEquiv.symm_apply_apply f a).symm
#align is_local_ring_hom_equiv isLocalRingHom_equiv
-/

#print isUnit_of_map_unit /-
@[simp]
theorem isUnit_of_map_unit (f : R →+* S) [IsLocalRingHom f] (a) (h : IsUnit (f a)) : IsUnit a :=
  IsLocalRingHom.map_nonunit a h
#align is_unit_of_map_unit isUnit_of_map_unit
-/

#print of_irreducible_map /-
theorem of_irreducible_map (f : R →+* S) [h : IsLocalRingHom f] {x} (hfx : Irreducible (f x)) :
    Irreducible x :=
  ⟨fun h => hfx.not_unit <| IsUnit.map f h, fun p q hx =>
    let ⟨H⟩ := h
    Or.imp (H p) (H q) <| hfx.isUnit_or_isUnit <| f.map_mul p q ▸ congr_arg f hx⟩
#align of_irreducible_map of_irreducible_map
-/

#print isLocalRingHom_of_comp /-
theorem isLocalRingHom_of_comp (f : R →+* S) (g : S →+* T) [IsLocalRingHom (g.comp f)] :
    IsLocalRingHom f :=
  ⟨fun a ha => (isUnit_map_iff (g.comp f) _).mp (g.isUnit_map ha)⟩
#align is_local_ring_hom_of_comp isLocalRingHom_of_comp
-/

#print RingHom.domain_localRing /-
/-- If `f : R →+* S` is a local ring hom, then `R` is a local ring if `S` is. -/
theorem RingHom.domain_localRing {R S : Type _} [CommSemiring R] [CommSemiring S] [H : LocalRing S]
    (f : R →+* S) [IsLocalRingHom f] : LocalRing R :=
  by
  haveI : Nontrivial R := pullback_nonzero f f.map_zero f.map_one
  apply LocalRing.of_nonunits_add
  intro a b
  simp_rw [← map_mem_nonunits_iff f, f.map_add]
  exact LocalRing.nonunits_add
#align ring_hom.domain_local_ring RingHom.domain_localRing
-/

end

section

open LocalRing

variable [CommSemiring R] [LocalRing R] [CommSemiring S] [LocalRing S]

#print map_nonunit /-
/--
The image of the maximal ideal of the source is contained within the maximal ideal of the target.
-/
theorem map_nonunit (f : R →+* S) [IsLocalRingHom f] (a : R) (h : a ∈ maximalIdeal R) :
    f a ∈ maximalIdeal S := fun H => h <| isUnit_of_map_unit f a H
#align map_nonunit map_nonunit
-/

end

namespace LocalRing

section

variable [CommSemiring R] [LocalRing R] [CommSemiring S] [LocalRing S]

#print LocalRing.local_hom_TFAE /-
/-- A ring homomorphism between local rings is a local ring hom iff it reflects units,
i.e. any preimage of a unit is still a unit. https://stacks.math.columbia.edu/tag/07BJ
-/
theorem local_hom_TFAE (f : R →+* S) :
    TFAE
      [IsLocalRingHom f, f '' (maximalIdeal R).1 ⊆ maximalIdeal S,
        (maximalIdeal R).map f ≤ maximalIdeal S, maximalIdeal R ≤ (maximalIdeal S).comap f,
        (maximalIdeal S).comap f = maximalIdeal R] :=
  by
  tfae_have 1 → 2; rintro _ _ ⟨a, ha, rfl⟩
  skip; exact map_nonunit f a ha
  tfae_have 2 → 4; exact Set.image_subset_iff.1
  tfae_have 3 ↔ 4; exact Ideal.map_le_iff_le_comap
  tfae_have 4 → 1; intro h; fconstructor; exact fun x => not_imp_not.1 (@h x)
  tfae_have 1 → 5; intro; skip; ext
  exact not_iff_not.2 (isUnit_map_iff f x)
  tfae_have 5 → 4; exact fun h => le_of_eq h.symm
  tfae_finish
#align local_ring.local_hom_tfae LocalRing.local_hom_TFAE
-/

end

#print LocalRing.of_surjective /-
theorem of_surjective [CommSemiring R] [LocalRing R] [CommSemiring S] [Nontrivial S] (f : R →+* S)
    [IsLocalRingHom f] (hf : Function.Surjective f) : LocalRing S :=
  of_isUnit_or_isUnit_of_isUnit_add
    (by
      intro a b hab
      obtain ⟨a, rfl⟩ := hf a
      obtain ⟨b, rfl⟩ := hf b
      rw [← map_add] at hab 
      exact
        (is_unit_or_is_unit_of_is_unit_add <| IsLocalRingHom.map_nonunit _ hab).imp f.is_unit_map
          f.is_unit_map)
#align local_ring.of_surjective LocalRing.of_surjective
-/

#print LocalRing.surjective_units_map_of_local_ringHom /-
/-- If `f : R →+* S` is a surjective local ring hom, then the induced units map is surjective. -/
theorem surjective_units_map_of_local_ringHom [CommRing R] [CommRing S] (f : R →+* S)
    (hf : Function.Surjective f) (h : IsLocalRingHom f) :
    Function.Surjective (Units.map <| f.toMonoidHom) :=
  by
  intro a
  obtain ⟨b, hb⟩ := hf (a : S)
  use (isUnit_of_map_unit f _ (by rw [hb]; exact Units.isUnit _)).Unit; ext; exact hb
#align local_ring.surjective_units_map_of_local_ring_hom LocalRing.surjective_units_map_of_local_ringHom
-/

section

variable (R) [CommRing R] [LocalRing R] [CommRing S] [LocalRing S] [CommRing T] [LocalRing T]

#print LocalRing.ResidueField /-
/-- The residue field of a local ring is the quotient of the ring by its maximal ideal. -/
def ResidueField :=
  R ⧸ maximalIdeal R
deriving Ring, CommRing, Inhabited
#align local_ring.residue_field LocalRing.ResidueField
-/

#print LocalRing.ResidueField.field /-
noncomputable instance ResidueField.field : Field (ResidueField R) :=
  Ideal.Quotient.field (maximalIdeal R)
#align local_ring.residue_field.field LocalRing.ResidueField.field
-/

#print LocalRing.residue /-
/-- The quotient map from a local ring to its residue field. -/
def residue : R →+* ResidueField R :=
  Ideal.Quotient.mk _
#align local_ring.residue LocalRing.residue
-/

#print LocalRing.ResidueField.algebra /-
instance ResidueField.algebra : Algebra R (ResidueField R) :=
  Ideal.Quotient.algebra _
#align local_ring.residue_field.algebra LocalRing.ResidueField.algebra
-/

#print LocalRing.ResidueField.algebraMap_eq /-
theorem ResidueField.algebraMap_eq : algebraMap R (ResidueField R) = residue R :=
  rfl
#align local_ring.residue_field.algebra_map_eq LocalRing.ResidueField.algebraMap_eq
-/

instance : IsLocalRingHom (LocalRing.residue R) :=
  ⟨fun a ha =>
    Classical.not_not.mp (Ideal.Quotient.eq_zero_iff_mem.Not.mp (isUnit_iff_ne_zero.mp ha))⟩

variable {R}

namespace ResidueField

#print LocalRing.ResidueField.lift /-
/-- A local ring homomorphism into a field can be descended onto the residue field. -/
def lift {R S : Type _} [CommRing R] [LocalRing R] [Field S] (f : R →+* S) [IsLocalRingHom f] :
    LocalRing.ResidueField R →+* S :=
  Ideal.Quotient.lift _ f fun a ha =>
    by_contradiction fun h => ha (isUnit_of_map_unit f a (isUnit_iff_ne_zero.mpr h))
#align local_ring.residue_field.lift LocalRing.ResidueField.lift
-/

#print LocalRing.ResidueField.lift_comp_residue /-
theorem lift_comp_residue {R S : Type _} [CommRing R] [LocalRing R] [Field S] (f : R →+* S)
    [IsLocalRingHom f] : (lift f).comp (residue R) = f :=
  RingHom.ext fun _ => rfl
#align local_ring.residue_field.lift_comp_residue LocalRing.ResidueField.lift_comp_residue
-/

#print LocalRing.ResidueField.lift_residue_apply /-
@[simp]
theorem lift_residue_apply {R S : Type _} [CommRing R] [LocalRing R] [Field S] (f : R →+* S)
    [IsLocalRingHom f] (x) : lift f (residue R x) = f x :=
  rfl
#align local_ring.residue_field.lift_residue_apply LocalRing.ResidueField.lift_residue_apply
-/

#print LocalRing.ResidueField.map /-
/-- The map on residue fields induced by a local homomorphism between local rings -/
def map (f : R →+* S) [IsLocalRingHom f] : ResidueField R →+* ResidueField S :=
  Ideal.Quotient.lift (maximalIdeal R) ((Ideal.Quotient.mk _).comp f) fun a ha =>
    by
    erw [Ideal.Quotient.eq_zero_iff_mem]
    exact map_nonunit f a ha
#align local_ring.residue_field.map LocalRing.ResidueField.map
-/

#print LocalRing.ResidueField.map_id /-
/-- Applying `residue_field.map` to the identity ring homomorphism gives the identity
ring homomorphism. -/
@[simp]
theorem map_id :
    LocalRing.ResidueField.map (RingHom.id R) = RingHom.id (LocalRing.ResidueField R) :=
  Ideal.Quotient.ringHom_ext <| RingHom.ext fun x => rfl
#align local_ring.residue_field.map_id LocalRing.ResidueField.map_id
-/

#print LocalRing.ResidueField.map_comp /-
/-- The composite of two `residue_field.map`s is the `residue_field.map` of the composite. -/
theorem map_comp (f : T →+* R) (g : R →+* S) [IsLocalRingHom f] [IsLocalRingHom g] :
    LocalRing.ResidueField.map (g.comp f) =
      (LocalRing.ResidueField.map g).comp (LocalRing.ResidueField.map f) :=
  Ideal.Quotient.ringHom_ext <| RingHom.ext fun x => rfl
#align local_ring.residue_field.map_comp LocalRing.ResidueField.map_comp
-/

#print LocalRing.ResidueField.map_comp_residue /-
theorem map_comp_residue (f : R →+* S) [IsLocalRingHom f] :
    (ResidueField.map f).comp (residue R) = (residue S).comp f :=
  rfl
#align local_ring.residue_field.map_comp_residue LocalRing.ResidueField.map_comp_residue
-/

#print LocalRing.ResidueField.map_residue /-
theorem map_residue (f : R →+* S) [IsLocalRingHom f] (r : R) :
    ResidueField.map f (residue R r) = residue S (f r) :=
  rfl
#align local_ring.residue_field.map_residue LocalRing.ResidueField.map_residue
-/

#print LocalRing.ResidueField.map_id_apply /-
theorem map_id_apply (x : ResidueField R) : map (RingHom.id R) x = x :=
  FunLike.congr_fun map_id x
#align local_ring.residue_field.map_id_apply LocalRing.ResidueField.map_id_apply
-/

#print LocalRing.ResidueField.map_map /-
@[simp]
theorem map_map (f : R →+* S) (g : S →+* T) (x : ResidueField R) [IsLocalRingHom f]
    [IsLocalRingHom g] : map g (map f x) = map (g.comp f) x :=
  FunLike.congr_fun (map_comp f g).symm x
#align local_ring.residue_field.map_map LocalRing.ResidueField.map_map
-/

#print LocalRing.ResidueField.mapEquiv /-
/-- A ring isomorphism defines an isomorphism of residue fields. -/
@[simps apply]
def mapEquiv (f : R ≃+* S) : LocalRing.ResidueField R ≃+* LocalRing.ResidueField S
    where
  toFun := map (f : R →+* S)
  invFun := map (f.symm : S →+* R)
  left_inv x := by simp only [map_map, RingEquiv.symm_comp, map_id, RingHom.id_apply]
  right_inv x := by simp only [map_map, RingEquiv.comp_symm, map_id, RingHom.id_apply]
  map_mul' := RingHom.map_mul _
  map_add' := RingHom.map_add _
#align local_ring.residue_field.map_equiv LocalRing.ResidueField.mapEquiv
-/

#print LocalRing.ResidueField.mapEquiv.symm /-
@[simp]
theorem mapEquiv.symm (f : R ≃+* S) : (mapEquiv f).symm = mapEquiv f.symm :=
  rfl
#align local_ring.residue_field.map_equiv.symm LocalRing.ResidueField.mapEquiv.symm
-/

#print LocalRing.ResidueField.mapEquiv_trans /-
@[simp]
theorem mapEquiv_trans (e₁ : R ≃+* S) (e₂ : S ≃+* T) :
    mapEquiv (e₁.trans e₂) = (mapEquiv e₁).trans (mapEquiv e₂) :=
  RingEquiv.toRingHom_injective <| map_comp (e₁ : R →+* S) (e₂ : S →+* T)
#align local_ring.residue_field.map_equiv_trans LocalRing.ResidueField.mapEquiv_trans
-/

#print LocalRing.ResidueField.mapEquiv_refl /-
@[simp]
theorem mapEquiv_refl : mapEquiv (RingEquiv.refl R) = RingEquiv.refl _ :=
  RingEquiv.toRingHom_injective map_id
#align local_ring.residue_field.map_equiv_refl LocalRing.ResidueField.mapEquiv_refl
-/

#print LocalRing.ResidueField.mapAut /-
/-- The group homomorphism from `ring_aut R` to `ring_aut k` where `k`
is the residue field of `R`. -/
@[simps]
def mapAut : RingAut R →* RingAut (LocalRing.ResidueField R)
    where
  toFun := mapEquiv
  map_mul' e₁ e₂ := mapEquiv_trans e₂ e₁
  map_one' := mapEquiv_refl
#align local_ring.residue_field.map_aut LocalRing.ResidueField.mapAut
-/

section MulSemiringAction

variable (G : Type _) [Group G] [MulSemiringAction G R]

/-- If `G` acts on `R` as a `mul_semiring_action`, then it also acts on `residue_field R`. -/
instance : MulSemiringAction G (LocalRing.ResidueField R) :=
  MulSemiringAction.compHom _ <| mapAut.comp (MulSemiringAction.toRingAut G R)

#print LocalRing.ResidueField.residue_smul /-
@[simp]
theorem residue_smul (g : G) (r : R) : residue R (g • r) = g • residue R r :=
  rfl
#align local_ring.residue_field.residue_smul LocalRing.ResidueField.residue_smul
-/

end MulSemiringAction

end ResidueField

#print LocalRing.ker_eq_maximalIdeal /-
theorem ker_eq_maximalIdeal [Field K] (φ : R →+* K) (hφ : Function.Surjective φ) :
    φ.ker = maximalIdeal R :=
  LocalRing.eq_maximalIdeal <| (RingHom.ker_isMaximal_of_surjective φ) hφ
#align local_ring.ker_eq_maximal_ideal LocalRing.ker_eq_maximalIdeal
-/

#print LocalRing.isLocalRingHom_residue /-
theorem isLocalRingHom_residue : IsLocalRingHom (LocalRing.residue R) :=
  by
  constructor
  intro a ha
  by_contra
  erw [ideal.quotient.eq_zero_iff_mem.mpr ((LocalRing.mem_maximalIdeal _).mpr h)] at ha 
  exact ha.ne_zero rfl
#align local_ring.is_local_ring_hom_residue LocalRing.isLocalRingHom_residue
-/

end

end LocalRing

namespace Field

variable (K) [Field K]

open scoped Classical

-- see Note [lower instance priority]
instance (priority := 100) : LocalRing K :=
  LocalRing.of_isUnit_or_isUnit_one_sub_self fun a =>
    if h : a = 0 then Or.inr (by rw [h, sub_zero] <;> exact isUnit_one)
    else Or.inl <| IsUnit.mk0 a h

end Field

#print LocalRing.maximalIdeal_eq_bot /-
theorem LocalRing.maximalIdeal_eq_bot {R : Type _} [Field R] : LocalRing.maximalIdeal R = ⊥ :=
  LocalRing.isField_iff_maximalIdeal_eq.mp (Field.toIsField R)
#align local_ring.maximal_ideal_eq_bot LocalRing.maximalIdeal_eq_bot
-/

namespace RingEquiv

#print RingEquiv.localRing /-
@[reducible]
protected theorem localRing {A B : Type _} [CommSemiring A] [LocalRing A] [CommSemiring B]
    (e : A ≃+* B) : LocalRing B :=
  haveI := e.symm.to_equiv.nontrivial
  LocalRing.of_surjective (e : A →+* B) e.surjective
#align ring_equiv.local_ring RingEquiv.localRing
-/

end RingEquiv

