/-
Copyright (c) 2020 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Markus Himmel, Scott Morrison

! This file was ported from Lean 3 source module category_theory.preadditive.schur
! leanprover-community/mathlib commit 660b3a2db3522fa0db036e569dc995a615c4c848
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Ext
import Mathbin.CategoryTheory.Simple
import Mathbin.CategoryTheory.Linear.Basic
import Mathbin.CategoryTheory.Endomorphism
import Mathbin.FieldTheory.IsAlgClosed.Spectrum

/-!
# Schur's lemma

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
We first prove the part of Schur's Lemma that holds in any preadditive category with kernels,
that any nonzero morphism between simple objects
is an isomorphism.

Second, we prove Schur's lemma for `𝕜`-linear categories with finite dimensional hom spaces,
over an algebraically closed field `𝕜`:
the hom space `X ⟶ Y` between simple objects `X` and `Y` is at most one dimensional,
and is 1-dimensional iff `X` and `Y` are isomorphic.
-/


namespace CategoryTheory

open CategoryTheory.Limits

variable {C : Type _} [Category C]

variable [Preadditive C]

#print CategoryTheory.mono_of_nonzero_from_simple /-
-- See also `epi_of_nonzero_to_simple`, which does not require `preadditive C`.
theorem mono_of_nonzero_from_simple [HasKernels C] {X Y : C} [Simple X] {f : X ⟶ Y} (w : f ≠ 0) :
    Mono f :=
  Preadditive.mono_of_kernel_zero (kernel_zero_of_nonzero_from_simple w)
#align category_theory.mono_of_nonzero_from_simple CategoryTheory.mono_of_nonzero_from_simple
-/

#print CategoryTheory.isIso_of_hom_simple /-
/-- The part of **Schur's lemma** that holds in any preadditive category with kernels:
that a nonzero morphism between simple objects is an isomorphism.
-/
theorem isIso_of_hom_simple [HasKernels C] {X Y : C} [Simple X] [Simple Y] {f : X ⟶ Y} (w : f ≠ 0) :
    IsIso f :=
  haveI := mono_of_nonzero_from_simple w
  is_iso_of_mono_of_nonzero w
#align category_theory.is_iso_of_hom_simple CategoryTheory.isIso_of_hom_simple
-/

#print CategoryTheory.isIso_iff_nonzero /-
/-- As a corollary of Schur's lemma for preadditive categories,
any morphism between simple objects is (exclusively) either an isomorphism or zero.
-/
theorem isIso_iff_nonzero [HasKernels C] {X Y : C} [Simple X] [Simple Y] (f : X ⟶ Y) :
    IsIso f ↔ f ≠ 0 :=
  ⟨fun I => by
    intro h
    apply id_nonzero X
    simp only [← is_iso.hom_inv_id f, h, zero_comp], fun w => isIso_of_hom_simple w⟩
#align category_theory.is_iso_iff_nonzero CategoryTheory.isIso_iff_nonzero
-/

/-- In any preadditive category with kernels,
the endomorphisms of a simple object form a division ring.
-/
noncomputable instance [HasKernels C] {X : C} [Simple X] : DivisionRing (End X) := by
  classical exact
    {
      (inferInstance :
        Ring
          (End
            X)) with
      inv := fun f =>
        if h : f = 0 then 0
        else
          haveI := is_iso_of_hom_simple h
          inv f
      exists_pair_ne := ⟨𝟙 X, 0, id_nonzero _⟩
      inv_zero := dif_pos rfl
      mul_inv_cancel := fun f h => by
        haveI := is_iso_of_hom_simple h
        convert is_iso.inv_hom_id f
        exact dif_neg h }

open FiniteDimensional

section

variable (𝕜 : Type _) [DivisionRing 𝕜]

#print CategoryTheory.finrank_hom_simple_simple_eq_zero_of_not_iso /-
/-- Part of **Schur's lemma** for `𝕜`-linear categories:
the hom space between two non-isomorphic simple objects is 0-dimensional.
-/
theorem finrank_hom_simple_simple_eq_zero_of_not_iso [HasKernels C] [Linear 𝕜 C] {X Y : C}
    [Simple X] [Simple Y] (h : (X ≅ Y) → False) : finrank 𝕜 (X ⟶ Y) = 0 :=
  haveI :=
    subsingleton_of_forall_eq (0 : X ⟶ Y) fun f =>
      by
      have p := not_congr (is_iso_iff_nonzero f)
      simp only [Classical.not_not, Ne.def] at p 
      refine' p.mp fun _ => h (as_iso f)
  finrank_zero_of_subsingleton
#align category_theory.finrank_hom_simple_simple_eq_zero_of_not_iso CategoryTheory.finrank_hom_simple_simple_eq_zero_of_not_iso
-/

end

variable (𝕜 : Type _) [Field 𝕜]

variable [IsAlgClosed 𝕜] [Linear 𝕜 C]

#print CategoryTheory.finrank_endomorphism_eq_one /-
-- In the proof below we have some difficulty using `I : finite_dimensional 𝕜 (X ⟶ X)`
-- where we need a `finite_dimensional 𝕜 (End X)`.
-- These are definitionally equal, but without eta reduction Lean can't see this.
-- To get around this, we use `convert I`,
-- then check the various instances agree field-by-field,
-- We prove this with the explicit `is_iso_iff_nonzero` assumption,
-- rather than just `[simple X]`, as this form is useful for
-- Müger's formulation of semisimplicity.
/-- An auxiliary lemma for Schur's lemma.

If `X ⟶ X` is finite dimensional, and every nonzero endomorphism is invertible,
then `X ⟶ X` is 1-dimensional.
-/
theorem finrank_endomorphism_eq_one {X : C} (is_iso_iff_nonzero : ∀ f : X ⟶ X, IsIso f ↔ f ≠ 0)
    [I : FiniteDimensional 𝕜 (X ⟶ X)] : finrank 𝕜 (X ⟶ X) = 1 :=
  by
  have id_nonzero := (is_iso_iff_nonzero (𝟙 X)).mp (by infer_instance)
  refine' finrank_eq_one (𝟙 X) id_nonzero _
  · intro f
    haveI : Nontrivial (End X) := nontrivial_of_ne _ _ id_nonzero
    obtain ⟨c, nu⟩ :=
      @spectrum.nonempty_of_isAlgClosed_of_finiteDimensional 𝕜 (End X) _ _ _ _ _
        (by convert I; ext; rfl; ext; rfl) (End.of f)
    use c
    rw [spectrum.mem_iff, IsUnit.sub_iff, is_unit_iff_is_iso, is_iso_iff_nonzero, Ne.def,
      Classical.not_not, sub_eq_zero, Algebra.algebraMap_eq_smul_one] at nu 
    exact nu.symm
#align category_theory.finrank_endomorphism_eq_one CategoryTheory.finrank_endomorphism_eq_one
-/

variable [HasKernels C]

#print CategoryTheory.finrank_endomorphism_simple_eq_one /-
/-- **Schur's lemma** for endomorphisms in `𝕜`-linear categories.
-/
theorem finrank_endomorphism_simple_eq_one (X : C) [Simple X] [I : FiniteDimensional 𝕜 (X ⟶ X)] :
    finrank 𝕜 (X ⟶ X) = 1 :=
  finrank_endomorphism_eq_one 𝕜 isIso_iff_nonzero
#align category_theory.finrank_endomorphism_simple_eq_one CategoryTheory.finrank_endomorphism_simple_eq_one
-/

#print CategoryTheory.endomorphism_simple_eq_smul_id /-
theorem endomorphism_simple_eq_smul_id {X : C} [Simple X] [I : FiniteDimensional 𝕜 (X ⟶ X)]
    (f : X ⟶ X) : ∃ c : 𝕜, c • 𝟙 X = f :=
  (finrank_eq_one_iff_of_nonzero' (𝟙 X) (id_nonzero X)).mp (finrank_endomorphism_simple_eq_one 𝕜 X)
    f
#align category_theory.endomorphism_simple_eq_smul_id CategoryTheory.endomorphism_simple_eq_smul_id
-/

#print CategoryTheory.fieldEndOfFiniteDimensional /-
/-- Endomorphisms of a simple object form a field if they are finite dimensional.
This can't be an instance as `𝕜` would be undetermined.
-/
noncomputable def fieldEndOfFiniteDimensional (X : C) [Simple X] [I : FiniteDimensional 𝕜 (X ⟶ X)] :
    Field (End X) := by
  classical exact
    { (inferInstance : DivisionRing (End X)) with
      mul_comm := fun f g =>
        by
        obtain ⟨c, rfl⟩ := endomorphism_simple_eq_smul_id 𝕜 f
        obtain ⟨d, rfl⟩ := endomorphism_simple_eq_smul_id 𝕜 g
        simp [← mul_smul, mul_comm c d] }
#align category_theory.field_End_of_finite_dimensional CategoryTheory.fieldEndOfFiniteDimensional
-/

#print CategoryTheory.finrank_hom_simple_simple_le_one /-
-- There is a symmetric argument that uses `[finite_dimensional 𝕜 (Y ⟶ Y)]` instead,
-- but we don't bother proving that here.
/-- **Schur's lemma** for `𝕜`-linear categories:
if hom spaces are finite dimensional, then the hom space between simples is at most 1-dimensional.

See `finrank_hom_simple_simple_eq_one_iff` and `finrank_hom_simple_simple_eq_zero_iff` below
for the refinements when we know whether or not the simples are isomorphic.
-/
theorem finrank_hom_simple_simple_le_one (X Y : C) [FiniteDimensional 𝕜 (X ⟶ X)] [Simple X]
    [Simple Y] : finrank 𝕜 (X ⟶ Y) ≤ 1 :=
  by
  cases' subsingleton_or_nontrivial (X ⟶ Y) with h
  · skip
    rw [finrank_zero_of_subsingleton]
    exact zero_le_one
  · obtain ⟨f, nz⟩ := (nontrivial_iff_exists_ne 0).mp h
    haveI fi := (is_iso_iff_nonzero f).mpr nz
    refine' finrank_le_one f _
    intro g
    obtain ⟨c, w⟩ := endomorphism_simple_eq_smul_id 𝕜 (g ≫ inv f)
    exact ⟨c, by simpa using w =≫ f⟩
#align category_theory.finrank_hom_simple_simple_le_one CategoryTheory.finrank_hom_simple_simple_le_one
-/

#print CategoryTheory.finrank_hom_simple_simple_eq_one_iff /-
theorem finrank_hom_simple_simple_eq_one_iff (X Y : C) [FiniteDimensional 𝕜 (X ⟶ X)]
    [FiniteDimensional 𝕜 (X ⟶ Y)] [Simple X] [Simple Y] :
    finrank 𝕜 (X ⟶ Y) = 1 ↔ Nonempty (X ≅ Y) :=
  by
  fconstructor
  · intro h
    rw [finrank_eq_one_iff'] at h 
    obtain ⟨f, nz, -⟩ := h
    rw [← is_iso_iff_nonzero] at nz 
    exact ⟨as_iso f⟩
  · rintro ⟨f⟩
    have le_one := finrank_hom_simple_simple_le_one 𝕜 X Y
    have zero_lt : 0 < finrank 𝕜 (X ⟶ Y) :=
      finrank_pos_iff_exists_ne_zero.mpr ⟨f.hom, (is_iso_iff_nonzero f.hom).mp inferInstance⟩
    linarith
#align category_theory.finrank_hom_simple_simple_eq_one_iff CategoryTheory.finrank_hom_simple_simple_eq_one_iff
-/

#print CategoryTheory.finrank_hom_simple_simple_eq_zero_iff /-
theorem finrank_hom_simple_simple_eq_zero_iff (X Y : C) [FiniteDimensional 𝕜 (X ⟶ X)]
    [FiniteDimensional 𝕜 (X ⟶ Y)] [Simple X] [Simple Y] : finrank 𝕜 (X ⟶ Y) = 0 ↔ IsEmpty (X ≅ Y) :=
  by
  rw [← not_nonempty_iff, ← not_congr (finrank_hom_simple_simple_eq_one_iff 𝕜 X Y)]
  refine' ⟨fun h => by rw [h]; simp, fun h => _⟩
  have := finrank_hom_simple_simple_le_one 𝕜 X Y
  interval_cases h' : finrank 𝕜 (X ⟶ Y)
  · exact h'
  · exact False.elim (h h')
#align category_theory.finrank_hom_simple_simple_eq_zero_iff CategoryTheory.finrank_hom_simple_simple_eq_zero_iff
-/

open scoped Classical

#print CategoryTheory.finrank_hom_simple_simple /-
theorem finrank_hom_simple_simple (X Y : C) [∀ X Y : C, FiniteDimensional 𝕜 (X ⟶ Y)] [Simple X]
    [Simple Y] : finrank 𝕜 (X ⟶ Y) = if Nonempty (X ≅ Y) then 1 else 0 :=
  by
  split_ifs
  exact (finrank_hom_simple_simple_eq_one_iff 𝕜 X Y).2 h
  exact (finrank_hom_simple_simple_eq_zero_iff 𝕜 X Y).2 (not_nonempty_iff.mp h)
#align category_theory.finrank_hom_simple_simple CategoryTheory.finrank_hom_simple_simple
-/

end CategoryTheory

