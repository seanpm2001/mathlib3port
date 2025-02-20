/-
Copyright (c) 2022 Adam Topaz. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Adam Topaz, Junyan Xu

! This file was ported from Lean 3 source module ring_theory.localization.as_subring
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Localization.LocalizationLocalization

/-!

# Localizations of domains as subalgebras of the fraction field.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a domain `A` with fraction field `K`, and a submonoid `S` of `A` which
does not contain zero, this file constructs the localization of `A` at `S`
as a subalgebra of the field `K` over `A`.

-/


namespace Localization

open scoped nonZeroDivisors

variable {A : Type _} (K : Type _) [CommRing A] (S : Submonoid A) (hS : S ≤ A⁰)

section CommRing

variable [CommRing K] [Algebra A K] [IsFractionRing A K]

#print Localization.map_isUnit_of_le /-
theorem map_isUnit_of_le (hS : S ≤ A⁰) (s : S) : IsUnit (algebraMap A K s) := by
  apply IsLocalization.map_units K (⟨s.1, hS s.2⟩ : A⁰)
#align localization.map_is_unit_of_le Localization.map_isUnit_of_le
-/

#print Localization.mapToFractionRing /-
/-- The canonical map from a localization of `A` at `S` to the fraction ring
  of `A`, given that `S ≤ A⁰`. -/
noncomputable def mapToFractionRing (B : Type _) [CommRing B] [Algebra A B] [IsLocalization S B]
    (hS : S ≤ A⁰) : B →ₐ[A] K :=
  { IsLocalization.lift (map_isUnit_of_le K S hS) with commutes' := fun a => by simp }
#align localization.map_to_fraction_ring Localization.mapToFractionRing
-/

#print Localization.mapToFractionRing_apply /-
@[simp]
theorem mapToFractionRing_apply {B : Type _} [CommRing B] [Algebra A B] [IsLocalization S B]
    (hS : S ≤ A⁰) (b : B) :
    mapToFractionRing K S B hS b = IsLocalization.lift (map_isUnit_of_le K S hS) b :=
  rfl
#align localization.map_to_fraction_ring_apply Localization.mapToFractionRing_apply
-/

#print Localization.mem_range_mapToFractionRing_iff /-
theorem mem_range_mapToFractionRing_iff (B : Type _) [CommRing B] [Algebra A B] [IsLocalization S B]
    (hS : S ≤ A⁰) (x : K) :
    x ∈ (mapToFractionRing K S B hS).range ↔
      ∃ (a s : A) (hs : s ∈ S), x = IsLocalization.mk' K a ⟨s, hS hs⟩ :=
  ⟨by
    rintro ⟨x, rfl⟩; obtain ⟨a, s, rfl⟩ := IsLocalization.mk'_surjective S x
    use a, s, s.2; apply IsLocalization.lift_mk',
    by
    rintro ⟨a, s, hs, rfl⟩; use IsLocalization.mk' _ a ⟨s, hs⟩
    apply IsLocalization.lift_mk'⟩
#align localization.mem_range_map_to_fraction_ring_iff Localization.mem_range_mapToFractionRing_iff
-/

#print Localization.isLocalization_range_mapToFractionRing /-
instance isLocalization_range_mapToFractionRing (B : Type _) [CommRing B] [Algebra A B]
    [IsLocalization S B] (hS : S ≤ A⁰) : IsLocalization S (mapToFractionRing K S B hS).range :=
  IsLocalization.isLocalization_of_algEquiv S <|
    show B ≃ₐ[A] _ from
      AlgEquiv.ofBijective (mapToFractionRing K S B hS).range_restrict
        (by
          refine' ⟨fun a b h => _, Set.surjective_onto_range⟩
          refine' (IsLocalization.lift_injective_iff _).2 (fun a b => _) (Subtype.ext_iff.1 h)
          exact
            ⟨fun h => congr_arg _ (IsLocalization.injective _ hS h), fun h =>
              congr_arg _ (IsFractionRing.injective A K h)⟩)
#align localization.is_localization_range_map_to_fraction_ring Localization.isLocalization_range_mapToFractionRing
-/

#print Localization.isFractionRing_range_mapToFractionRing /-
instance isFractionRing_range_mapToFractionRing (B : Type _) [CommRing B] [Algebra A B]
    [IsLocalization S B] (hS : S ≤ A⁰) : IsFractionRing (mapToFractionRing K S B hS).range K :=
  IsFractionRing.isFractionRing_of_isLocalization S _ _ hS
#align localization.is_fraction_ring_range_map_to_fraction_ring Localization.isFractionRing_range_mapToFractionRing
-/

#print Localization.subalgebra /-
/-- Given a commutative ring `A` with fraction ring `K`, and a submonoid `S` of `A` which
contains no zero divisor, this is the localization of `A` at `S`, considered as
a subalgebra of `K` over `A`.

The carrier of this subalgebra is defined as the set of all `x : K` of the form
`is_localization.mk' K a ⟨s, _⟩`, where `s ∈ S`.
-/
noncomputable def subalgebra (hS : S ≤ A⁰) : Subalgebra A K :=
  (mapToFractionRing K S (Localization S) hS).range.copy
      {x | ∃ (a s : A) (hs : s ∈ S), x = IsLocalization.mk' K a ⟨s, hS hs⟩} <|
    by ext; symm; apply mem_range_map_to_fraction_ring_iff
#align localization.subalgebra Localization.subalgebra
-/

namespace Subalgebra

#print Localization.subalgebra.isLocalization_subalgebra /-
instance isLocalization_subalgebra : IsLocalization S (subalgebra K S hS) := by
  dsimp only [Localization.subalgebra]; rw [Subalgebra.copy_eq]; infer_instance
#align localization.subalgebra.is_localization_subalgebra Localization.subalgebra.isLocalization_subalgebra
-/

#print Localization.subalgebra.isFractionRing /-
instance isFractionRing : IsFractionRing (subalgebra K S hS) K :=
  IsFractionRing.isFractionRing_of_isLocalization S _ _ hS
#align localization.subalgebra.is_fraction_ring Localization.subalgebra.isFractionRing
-/

end Subalgebra

end CommRing

section Field

variable [Field K] [Algebra A K] [IsFractionRing A K]

namespace Subalgebra

#print Localization.subalgebra.mem_range_mapToFractionRing_iff_ofField /-
theorem mem_range_mapToFractionRing_iff_ofField (B : Type _) [CommRing B] [Algebra A B]
    [IsLocalization S B] (x : K) :
    x ∈ (mapToFractionRing K S B hS).range ↔
      ∃ (a s : A) (hs : s ∈ S), x = algebraMap A K a * (algebraMap A K s)⁻¹ :=
  by
  rw [mem_range_map_to_fraction_ring_iff]
  iterate 3 congr with; convert Iff.rfl; rw [Units.val_inv_eq_inv_val]; rfl
#align localization.subalgebra.mem_range_map_to_fraction_ring_iff_of_field Localization.subalgebra.mem_range_mapToFractionRing_iff_ofField
-/

#print Localization.subalgebra.ofField /-
/-- Given a domain `A` with fraction field `K`, and a submonoid `S` of `A` which
contains no zero divisor, this is the localization of `A` at `S`, considered as
a subalgebra of `K` over `A`.

The carrier of this subalgebra is defined as the set of all `x : K` of the form
`algebra_map A K a * (algebra_map A K s)⁻¹` where `a s : A` and `s ∈ S`.
-/
noncomputable def ofField : Subalgebra A K :=
  (mapToFractionRing K S (Localization S) hS).range.copy
      {x | ∃ (a s : A) (hs : s ∈ S), x = algebraMap A K a * (algebraMap A K s)⁻¹} <|
    by ext; symm; apply mem_range_map_to_fraction_ring_iff_of_field
#align localization.subalgebra.of_field Localization.subalgebra.ofField
-/

#print Localization.subalgebra.isLocalization_ofField /-
instance isLocalization_ofField : IsLocalization S (subalgebra.ofField K S hS) := by
  dsimp only [Localization.subalgebra.ofField]; rw [Subalgebra.copy_eq]; infer_instance
#align localization.subalgebra.is_localization_of_field Localization.subalgebra.isLocalization_ofField
-/

#print Localization.subalgebra.isFractionRing_ofField /-
instance isFractionRing_ofField : IsFractionRing (subalgebra.ofField K S hS) K :=
  IsFractionRing.isFractionRing_of_isLocalization S _ _ hS
#align localization.subalgebra.is_fraction_ring_of_field Localization.subalgebra.isFractionRing_ofField
-/

end Subalgebra

end Field

end Localization

