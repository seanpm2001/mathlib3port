/-
Copyright (c) 2018 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Mario Carneiro, Johan Commelin, Amelia Livingston, Anne Baanen

! This file was ported from Lean 3 source module ring_theory.localization.integer
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Localization.Basic

/-!
# Integer elements of a localization

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

 * `is_localization.is_integer` is a predicate stating that `x : S` is in the image of `R`

## Implementation notes

See `src/ring_theory/localization/basic.lean` for a design overview.

## Tags
localization, ring localization, commutative ring localization, characteristic predicate,
commutative ring, field of fractions
-/


variable {R : Type _} [CommRing R] {M : Submonoid R} {S : Type _} [CommRing S]

variable [Algebra R S] {P : Type _} [CommRing P]

open Function

open scoped BigOperators

namespace IsLocalization

section

variable (R) {M S}

#print IsLocalization.IsInteger /-
-- TODO: define a subalgebra of `is_integer`s
/-- Given `a : S`, `S` a localization of `R`, `is_integer R a` iff `a` is in the image of
the localization map from `R` to `S`. -/
def IsInteger (a : S) : Prop :=
  a ∈ (algebraMap R S).range
#align is_localization.is_integer IsLocalization.IsInteger
-/

end

#print IsLocalization.isInteger_zero /-
theorem isInteger_zero : IsInteger R (0 : S) :=
  Subring.zero_mem _
#align is_localization.is_integer_zero IsLocalization.isInteger_zero
-/

#print IsLocalization.isInteger_one /-
theorem isInteger_one : IsInteger R (1 : S) :=
  Subring.one_mem _
#align is_localization.is_integer_one IsLocalization.isInteger_one
-/

#print IsLocalization.isInteger_add /-
theorem isInteger_add {a b : S} (ha : IsInteger R a) (hb : IsInteger R b) : IsInteger R (a + b) :=
  Subring.add_mem _ ha hb
#align is_localization.is_integer_add IsLocalization.isInteger_add
-/

#print IsLocalization.isInteger_mul /-
theorem isInteger_mul {a b : S} (ha : IsInteger R a) (hb : IsInteger R b) : IsInteger R (a * b) :=
  Subring.mul_mem _ ha hb
#align is_localization.is_integer_mul IsLocalization.isInteger_mul
-/

#print IsLocalization.isInteger_smul /-
theorem isInteger_smul {a : R} {b : S} (hb : IsInteger R b) : IsInteger R (a • b) :=
  by
  rcases hb with ⟨b', hb⟩
  use a * b'
  rw [← hb, (algebraMap R S).map_mul, Algebra.smul_def]
#align is_localization.is_integer_smul IsLocalization.isInteger_smul
-/

variable (M) {S} [IsLocalization M S]

#print IsLocalization.exists_integer_multiple' /-
/-- Each element `a : S` has an `M`-multiple which is an integer.

This version multiplies `a` on the right, matching the argument order in `localization_map.surj`.
-/
theorem exists_integer_multiple' (a : S) : ∃ b : M, IsInteger R (a * algebraMap R S b) :=
  let ⟨⟨Num, denom⟩, h⟩ := IsLocalization.surj _ a
  ⟨denom, Set.mem_range.mpr ⟨Num, h.symm⟩⟩
#align is_localization.exists_integer_multiple' IsLocalization.exists_integer_multiple'
-/

#print IsLocalization.exists_integer_multiple /-
/-- Each element `a : S` has an `M`-multiple which is an integer.

This version multiplies `a` on the left, matching the argument order in the `has_smul` instance.
-/
theorem exists_integer_multiple (a : S) : ∃ b : M, IsInteger R ((b : R) • a) := by
  simp_rw [Algebra.smul_def, mul_comm _ a]; apply exists_integer_multiple'
#align is_localization.exists_integer_multiple IsLocalization.exists_integer_multiple
-/

#print IsLocalization.exist_integer_multiples /-
/-- We can clear the denominators of a `finset`-indexed family of fractions. -/
theorem exist_integer_multiples {ι : Type _} (s : Finset ι) (f : ι → S) :
    ∃ b : M, ∀ i ∈ s, IsLocalization.IsInteger R ((b : R) • f i) :=
  by
  haveI := Classical.propDecidable
  refine' ⟨∏ i in s, (sec M (f i)).2, fun i hi => ⟨_, _⟩⟩
  · exact (∏ j in s.erase i, (sec M (f j)).2) * (sec M (f i)).1
  rw [RingHom.map_mul, sec_spec', ← mul_assoc, ← (algebraMap R S).map_mul, ← Algebra.smul_def]
  congr 2
  refine' trans _ ((Submonoid.subtype M).map_prod _ _).symm
  rw [mul_comm, ← Finset.prod_insert (s.not_mem_erase i), Finset.insert_erase hi]
  rfl
#align is_localization.exist_integer_multiples IsLocalization.exist_integer_multiples
-/

#print IsLocalization.exist_integer_multiples_of_finite /-
/-- We can clear the denominators of a finite indexed family of fractions. -/
theorem exist_integer_multiples_of_finite {ι : Type _} [Finite ι] (f : ι → S) :
    ∃ b : M, ∀ i, IsLocalization.IsInteger R ((b : R) • f i) :=
  by
  cases nonempty_fintype ι
  obtain ⟨b, hb⟩ := exist_integer_multiples M Finset.univ f
  exact ⟨b, fun i => hb i (Finset.mem_univ _)⟩
#align is_localization.exist_integer_multiples_of_finite IsLocalization.exist_integer_multiples_of_finite
-/

#print IsLocalization.exist_integer_multiples_of_finset /-
/-- We can clear the denominators of a finite set of fractions. -/
theorem exist_integer_multiples_of_finset (s : Finset S) :
    ∃ b : M, ∀ a ∈ s, IsInteger R ((b : R) • a) :=
  exist_integer_multiples M s id
#align is_localization.exist_integer_multiples_of_finset IsLocalization.exist_integer_multiples_of_finset
-/

#print IsLocalization.commonDenom /-
/-- A choice of a common multiple of the denominators of a `finset`-indexed family of fractions. -/
noncomputable def commonDenom {ι : Type _} (s : Finset ι) (f : ι → S) : M :=
  (exist_integer_multiples M s f).some
#align is_localization.common_denom IsLocalization.commonDenom
-/

#print IsLocalization.integerMultiple /-
/-- The numerator of a fraction after clearing the denominators
of a `finset`-indexed family of fractions. -/
noncomputable def integerMultiple {ι : Type _} (s : Finset ι) (f : ι → S) (i : s) : R :=
  ((exist_integer_multiples M s f).choose_spec i i.Prop).some
#align is_localization.integer_multiple IsLocalization.integerMultiple
-/

#print IsLocalization.map_integerMultiple /-
@[simp]
theorem map_integerMultiple {ι : Type _} (s : Finset ι) (f : ι → S) (i : s) :
    algebraMap R S (integerMultiple M s f i) = commonDenom M s f • f i :=
  ((exist_integer_multiples M s f).choose_spec _ i.Prop).choose_spec
#align is_localization.map_integer_multiple IsLocalization.map_integerMultiple
-/

#print IsLocalization.commonDenomOfFinset /-
/-- A choice of a common multiple of the denominators of a finite set of fractions. -/
noncomputable def commonDenomOfFinset (s : Finset S) : M :=
  commonDenom M s id
#align is_localization.common_denom_of_finset IsLocalization.commonDenomOfFinset
-/

#print IsLocalization.finsetIntegerMultiple /-
/-- The finset of numerators after clearing the denominators of a finite set of fractions. -/
noncomputable def finsetIntegerMultiple [DecidableEq R] (s : Finset S) : Finset R :=
  s.attach.image fun t => integerMultiple M s id t
#align is_localization.finset_integer_multiple IsLocalization.finsetIntegerMultiple
-/

open scoped Pointwise

#print IsLocalization.finsetIntegerMultiple_image /-
theorem finsetIntegerMultiple_image [DecidableEq R] (s : Finset S) :
    algebraMap R S '' finsetIntegerMultiple M s = commonDenomOfFinset M s • s :=
  by
  delta finset_integer_multiple common_denom
  rw [Finset.coe_image]
  ext
  constructor
  · rintro ⟨_, ⟨x, -, rfl⟩, rfl⟩
    rw [map_integer_multiple]
    exact Set.mem_image_of_mem _ x.prop
  · rintro ⟨x, hx, rfl⟩
    exact ⟨_, ⟨⟨x, hx⟩, s.mem_attach _, rfl⟩, map_integer_multiple M s id _⟩
#align is_localization.finset_integer_multiple_image IsLocalization.finsetIntegerMultiple_image
-/

end IsLocalization

