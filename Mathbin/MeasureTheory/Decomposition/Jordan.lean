/-
Copyright (c) 2021 Kexing Ying. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying

! This file was ported from Lean 3 source module measure_theory.decomposition.jordan
! leanprover-community/mathlib commit 61b5e2755ccb464b68d05a9acf891ae04992d09d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Decomposition.SignedHahn
import Mathbin.MeasureTheory.Measure.MutuallySingular

/-!
# Jordan decomposition

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves the existence and uniqueness of the Jordan decomposition for signed measures.
The Jordan decomposition theorem states that, given a signed measure `s`, there exists a
unique pair of mutually singular measures `μ` and `ν`, such that `s = μ - ν`.

The Jordan decomposition theorem for measures is a corollary of the Hahn decomposition theorem and
is useful for the Lebesgue decomposition theorem.

## Main definitions

* `measure_theory.jordan_decomposition`: a Jordan decomposition of a measurable space is a
  pair of mutually singular finite measures. We say `j` is a Jordan decomposition of a signed
  measure `s` if `s = j.pos_part - j.neg_part`.
* `measure_theory.signed_measure.to_jordan_decomposition`: the Jordan decomposition of a
  signed measure.
* `measure_theory.signed_measure.to_jordan_decomposition_equiv`: is the `equiv` between
  `measure_theory.signed_measure` and `measure_theory.jordan_decomposition` formed by
  `measure_theory.signed_measure.to_jordan_decomposition`.

## Main results

* `measure_theory.signed_measure.to_signed_measure_to_jordan_decomposition` : the Jordan
  decomposition theorem.
* `measure_theory.jordan_decomposition.to_signed_measure_injective` : the Jordan decomposition of a
  signed measure is unique.

## Tags

Jordan decomposition theorem
-/


noncomputable section

open scoped Classical MeasureTheory ENNReal NNReal

variable {α β : Type _} [MeasurableSpace α]

namespace MeasureTheory

#print MeasureTheory.JordanDecomposition /-
/-- A Jordan decomposition of a measurable space is a pair of mutually singular,
finite measures. -/
@[ext]
structure JordanDecomposition (α : Type _) [MeasurableSpace α] where
  (posPart negPart : Measure α)
  [posPart_finite : IsFiniteMeasure pos_part]
  [negPart_finite : IsFiniteMeasure neg_part]
  MutuallySingular : pos_part ⟂ₘ neg_part
#align measure_theory.jordan_decomposition MeasureTheory.JordanDecomposition
-/

attribute [instance] jordan_decomposition.pos_part_finite

attribute [instance] jordan_decomposition.neg_part_finite

namespace JordanDecomposition

open Measure VectorMeasure

variable (j : JordanDecomposition α)

instance : Zero (JordanDecomposition α) where zero := ⟨0, 0, MutuallySingular.zero_right⟩

instance : Inhabited (JordanDecomposition α) where default := 0

instance : InvolutiveNeg (JordanDecomposition α)
    where
  neg j := ⟨j.negPart, j.posPart, j.MutuallySingular.symm⟩
  neg_neg j := JordanDecomposition.ext _ _ rfl rfl

instance : SMul ℝ≥0 (JordanDecomposition α)
    where smul r j :=
    ⟨r • j.posPart, r • j.negPart,
      MutuallySingular.smul _ (MutuallySingular.smul _ j.MutuallySingular.symm).symm⟩

#print MeasureTheory.JordanDecomposition.instSMulReal /-
instance instSMulReal : SMul ℝ (JordanDecomposition α)
    where smul r j := if hr : 0 ≤ r then r.toNNReal • j else -((-r).toNNReal • j)
#align measure_theory.jordan_decomposition.has_smul_real MeasureTheory.JordanDecomposition.instSMulReal
-/

#print MeasureTheory.JordanDecomposition.zero_posPart /-
@[simp]
theorem zero_posPart : (0 : JordanDecomposition α).posPart = 0 :=
  rfl
#align measure_theory.jordan_decomposition.zero_pos_part MeasureTheory.JordanDecomposition.zero_posPart
-/

#print MeasureTheory.JordanDecomposition.zero_negPart /-
@[simp]
theorem zero_negPart : (0 : JordanDecomposition α).negPart = 0 :=
  rfl
#align measure_theory.jordan_decomposition.zero_neg_part MeasureTheory.JordanDecomposition.zero_negPart
-/

#print MeasureTheory.JordanDecomposition.neg_posPart /-
@[simp]
theorem neg_posPart : (-j).posPart = j.negPart :=
  rfl
#align measure_theory.jordan_decomposition.neg_pos_part MeasureTheory.JordanDecomposition.neg_posPart
-/

#print MeasureTheory.JordanDecomposition.neg_negPart /-
@[simp]
theorem neg_negPart : (-j).negPart = j.posPart :=
  rfl
#align measure_theory.jordan_decomposition.neg_neg_part MeasureTheory.JordanDecomposition.neg_negPart
-/

#print MeasureTheory.JordanDecomposition.smul_posPart /-
@[simp]
theorem smul_posPart (r : ℝ≥0) : (r • j).posPart = r • j.posPart :=
  rfl
#align measure_theory.jordan_decomposition.smul_pos_part MeasureTheory.JordanDecomposition.smul_posPart
-/

#print MeasureTheory.JordanDecomposition.smul_negPart /-
@[simp]
theorem smul_negPart (r : ℝ≥0) : (r • j).negPart = r • j.negPart :=
  rfl
#align measure_theory.jordan_decomposition.smul_neg_part MeasureTheory.JordanDecomposition.smul_negPart
-/

#print MeasureTheory.JordanDecomposition.real_smul_def /-
theorem real_smul_def (r : ℝ) (j : JordanDecomposition α) :
    r • j = if hr : 0 ≤ r then r.toNNReal • j else -((-r).toNNReal • j) :=
  rfl
#align measure_theory.jordan_decomposition.real_smul_def MeasureTheory.JordanDecomposition.real_smul_def
-/

#print MeasureTheory.JordanDecomposition.coe_smul /-
@[simp]
theorem coe_smul (r : ℝ≥0) : (r : ℝ) • j = r • j :=
  show dite _ _ _ = _ by rw [dif_pos (NNReal.coe_nonneg r), Real.toNNReal_coe]
#align measure_theory.jordan_decomposition.coe_smul MeasureTheory.JordanDecomposition.coe_smul
-/

#print MeasureTheory.JordanDecomposition.real_smul_nonneg /-
theorem real_smul_nonneg (r : ℝ) (hr : 0 ≤ r) : r • j = r.toNNReal • j :=
  dif_pos hr
#align measure_theory.jordan_decomposition.real_smul_nonneg MeasureTheory.JordanDecomposition.real_smul_nonneg
-/

#print MeasureTheory.JordanDecomposition.real_smul_neg /-
theorem real_smul_neg (r : ℝ) (hr : r < 0) : r • j = -((-r).toNNReal • j) :=
  dif_neg (not_le.2 hr)
#align measure_theory.jordan_decomposition.real_smul_neg MeasureTheory.JordanDecomposition.real_smul_neg
-/

#print MeasureTheory.JordanDecomposition.real_smul_posPart_nonneg /-
theorem real_smul_posPart_nonneg (r : ℝ) (hr : 0 ≤ r) : (r • j).posPart = r.toNNReal • j.posPart :=
  by rw [real_smul_def, ← smul_pos_part, dif_pos hr]
#align measure_theory.jordan_decomposition.real_smul_pos_part_nonneg MeasureTheory.JordanDecomposition.real_smul_posPart_nonneg
-/

#print MeasureTheory.JordanDecomposition.real_smul_negPart_nonneg /-
theorem real_smul_negPart_nonneg (r : ℝ) (hr : 0 ≤ r) : (r • j).negPart = r.toNNReal • j.negPart :=
  by rw [real_smul_def, ← smul_neg_part, dif_pos hr]
#align measure_theory.jordan_decomposition.real_smul_neg_part_nonneg MeasureTheory.JordanDecomposition.real_smul_negPart_nonneg
-/

#print MeasureTheory.JordanDecomposition.real_smul_posPart_neg /-
theorem real_smul_posPart_neg (r : ℝ) (hr : r < 0) : (r • j).posPart = (-r).toNNReal • j.negPart :=
  by rw [real_smul_def, ← smul_neg_part, dif_neg (not_le.2 hr), neg_pos_part]
#align measure_theory.jordan_decomposition.real_smul_pos_part_neg MeasureTheory.JordanDecomposition.real_smul_posPart_neg
-/

#print MeasureTheory.JordanDecomposition.real_smul_negPart_neg /-
theorem real_smul_negPart_neg (r : ℝ) (hr : r < 0) : (r • j).negPart = (-r).toNNReal • j.posPart :=
  by rw [real_smul_def, ← smul_pos_part, dif_neg (not_le.2 hr), neg_neg_part]
#align measure_theory.jordan_decomposition.real_smul_neg_part_neg MeasureTheory.JordanDecomposition.real_smul_negPart_neg
-/

#print MeasureTheory.JordanDecomposition.toSignedMeasure /-
/-- The signed measure associated with a Jordan decomposition. -/
def toSignedMeasure : SignedMeasure α :=
  j.posPart.toSignedMeasure - j.negPart.toSignedMeasure
#align measure_theory.jordan_decomposition.to_signed_measure MeasureTheory.JordanDecomposition.toSignedMeasure
-/

#print MeasureTheory.JordanDecomposition.toSignedMeasure_zero /-
theorem toSignedMeasure_zero : (0 : JordanDecomposition α).toSignedMeasure = 0 :=
  by
  ext1 i hi
  erw [to_signed_measure, to_signed_measure_sub_apply hi, sub_self, zero_apply]
#align measure_theory.jordan_decomposition.to_signed_measure_zero MeasureTheory.JordanDecomposition.toSignedMeasure_zero
-/

#print MeasureTheory.JordanDecomposition.toSignedMeasure_neg /-
theorem toSignedMeasure_neg : (-j).toSignedMeasure = -j.toSignedMeasure :=
  by
  ext1 i hi
  rw [neg_apply, to_signed_measure, to_signed_measure, to_signed_measure_sub_apply hi,
    to_signed_measure_sub_apply hi, neg_sub]
  rfl
#align measure_theory.jordan_decomposition.to_signed_measure_neg MeasureTheory.JordanDecomposition.toSignedMeasure_neg
-/

#print MeasureTheory.JordanDecomposition.toSignedMeasure_smul /-
theorem toSignedMeasure_smul (r : ℝ≥0) : (r • j).toSignedMeasure = r • j.toSignedMeasure :=
  by
  ext1 i hi
  rw [vector_measure.smul_apply, to_signed_measure, to_signed_measure,
    to_signed_measure_sub_apply hi, to_signed_measure_sub_apply hi, smul_sub, smul_pos_part,
    smul_neg_part, ← ENNReal.toReal_smul, ← ENNReal.toReal_smul]
  rfl
#align measure_theory.jordan_decomposition.to_signed_measure_smul MeasureTheory.JordanDecomposition.toSignedMeasure_smul
-/

#print MeasureTheory.JordanDecomposition.exists_compl_positive_negative /-
/-- A Jordan decomposition provides a Hahn decomposition. -/
theorem exists_compl_positive_negative :
    ∃ S : Set α,
      MeasurableSet S ∧
        j.toSignedMeasure ≤[S] 0 ∧
          0 ≤[Sᶜ] j.toSignedMeasure ∧ j.posPart S = 0 ∧ j.negPart (Sᶜ) = 0 :=
  by
  obtain ⟨S, hS₁, hS₂, hS₃⟩ := j.mutually_singular
  refine' ⟨S, hS₁, _, _, hS₂, hS₃⟩
  · refine' restrict_le_restrict_of_subset_le _ _ fun A hA hA₁ => _
    rw [to_signed_measure, to_signed_measure_sub_apply hA,
      show j.pos_part A = 0 from nonpos_iff_eq_zero.1 (hS₂ ▸ measure_mono hA₁), ENNReal.zero_toReal,
      zero_sub, neg_le, zero_apply, neg_zero]
    exact ENNReal.toReal_nonneg
  · refine' restrict_le_restrict_of_subset_le _ _ fun A hA hA₁ => _
    rw [to_signed_measure, to_signed_measure_sub_apply hA,
      show j.neg_part A = 0 from nonpos_iff_eq_zero.1 (hS₃ ▸ measure_mono hA₁), ENNReal.zero_toReal,
      sub_zero]
    exact ENNReal.toReal_nonneg
#align measure_theory.jordan_decomposition.exists_compl_positive_negative MeasureTheory.JordanDecomposition.exists_compl_positive_negative
-/

end JordanDecomposition

namespace SignedMeasure

open Classical JordanDecomposition Measure Set VectorMeasure

variable {s : SignedMeasure α} {μ ν : Measure α} [IsFiniteMeasure μ] [IsFiniteMeasure ν]

#print MeasureTheory.SignedMeasure.toJordanDecomposition /-
/-- Given a signed measure `s`, `s.to_jordan_decomposition` is the Jordan decomposition `j`,
such that `s = j.to_signed_measure`. This property is known as the Jordan decomposition
theorem, and is shown by
`measure_theory.signed_measure.to_signed_measure_to_jordan_decomposition`. -/
def toJordanDecomposition (s : SignedMeasure α) : JordanDecomposition α :=
  let i := choose s.exists_compl_positive_negative
  let hi := choose_spec s.exists_compl_positive_negative
  { posPart := s.toMeasureOfZeroLE i hi.1 hi.2.1
    negPart := s.toMeasureOfLEZero (iᶜ) hi.1.compl hi.2.2
    posPart_finite := inferInstance
    negPart_finite := inferInstance
    MutuallySingular := by
      refine' ⟨iᶜ, hi.1.compl, _, _⟩
      · rw [to_measure_of_zero_le_apply _ _ hi.1 hi.1.compl]; simp
      · rw [to_measure_of_le_zero_apply _ _ hi.1.compl hi.1.compl.compl]; simp }
#align measure_theory.signed_measure.to_jordan_decomposition MeasureTheory.SignedMeasure.toJordanDecomposition
-/

#print MeasureTheory.SignedMeasure.toJordanDecomposition_spec /-
theorem toJordanDecomposition_spec (s : SignedMeasure α) :
    ∃ (i : Set α) (hi₁ : MeasurableSet i) (hi₂ : 0 ≤[i] s) (hi₃ : s ≤[iᶜ] 0),
      s.toJordanDecomposition.posPart = s.toMeasureOfZeroLE i hi₁ hi₂ ∧
        s.toJordanDecomposition.negPart = s.toMeasureOfLEZero (iᶜ) hi₁.compl hi₃ :=
  by
  set i := some s.exists_compl_positive_negative
  obtain ⟨hi₁, hi₂, hi₃⟩ := some_spec s.exists_compl_positive_negative
  exact ⟨i, hi₁, hi₂, hi₃, rfl, rfl⟩
#align measure_theory.signed_measure.to_jordan_decomposition_spec MeasureTheory.SignedMeasure.toJordanDecomposition_spec
-/

#print MeasureTheory.SignedMeasure.toSignedMeasure_toJordanDecomposition /-
/-- **The Jordan decomposition theorem**: Given a signed measure `s`, there exists a pair of
mutually singular measures `μ` and `ν` such that `s = μ - ν`. In this case, the measures `μ`
and `ν` are given by `s.to_jordan_decomposition.pos_part` and
`s.to_jordan_decomposition.neg_part` respectively.

Note that we use `measure_theory.jordan_decomposition.to_signed_measure` to represent the
signed measure corresponding to
`s.to_jordan_decomposition.pos_part - s.to_jordan_decomposition.neg_part`. -/
@[simp]
theorem toSignedMeasure_toJordanDecomposition (s : SignedMeasure α) :
    s.toJordanDecomposition.toSignedMeasure = s :=
  by
  obtain ⟨i, hi₁, hi₂, hi₃, hμ, hν⟩ := s.to_jordan_decomposition_spec
  simp only [jordan_decomposition.to_signed_measure, hμ, hν]
  ext k hk
  rw [to_signed_measure_sub_apply hk, to_measure_of_zero_le_apply _ hi₂ hi₁ hk,
    to_measure_of_le_zero_apply _ hi₃ hi₁.compl hk]
  simp only [ENNReal.coe_toReal, Subtype.coe_mk, ENNReal.some_eq_coe, sub_neg_eq_add]
  rw [← of_union _ (MeasurableSet.inter hi₁ hk) (MeasurableSet.inter hi₁.compl hk),
    Set.inter_comm i, Set.inter_comm (iᶜ), Set.inter_union_compl _ _]
  · infer_instance
  · exact (disjoint_compl_right.inf_left _).inf_right _
#align measure_theory.signed_measure.to_signed_measure_to_jordan_decomposition MeasureTheory.SignedMeasure.toSignedMeasure_toJordanDecomposition
-/

section

variable {u v w : Set α}

#print MeasureTheory.SignedMeasure.subset_positive_null_set /-
/-- A subset `v` of a null-set `w` has zero measure if `w` is a subset of a positive set `u`. -/
theorem subset_positive_null_set (hu : MeasurableSet u) (hv : MeasurableSet v)
    (hw : MeasurableSet w) (hsu : 0 ≤[u] s) (hw₁ : s w = 0) (hw₂ : w ⊆ u) (hwt : v ⊆ w) : s v = 0 :=
  by
  have : s v + s (w \ v) = 0 :=
    by
    rw [← hw₁, ← of_union Set.disjoint_sdiff_right hv (hw.diff hv), Set.union_diff_self,
      Set.union_eq_self_of_subset_left hwt]
    infer_instance
  have h₁ := nonneg_of_zero_le_restrict _ (restrict_le_restrict_subset _ _ hu hsu (hwt.trans hw₂))
  have h₂ :=
    nonneg_of_zero_le_restrict _
      (restrict_le_restrict_subset _ _ hu hsu ((w.diff_subset v).trans hw₂))
  linarith
#align measure_theory.signed_measure.subset_positive_null_set MeasureTheory.SignedMeasure.subset_positive_null_set
-/

#print MeasureTheory.SignedMeasure.subset_negative_null_set /-
/-- A subset `v` of a null-set `w` has zero measure if `w` is a subset of a negative set `u`. -/
theorem subset_negative_null_set (hu : MeasurableSet u) (hv : MeasurableSet v)
    (hw : MeasurableSet w) (hsu : s ≤[u] 0) (hw₁ : s w = 0) (hw₂ : w ⊆ u) (hwt : v ⊆ w) : s v = 0 :=
  by
  rw [← s.neg_le_neg_iff _ hu, neg_zero] at hsu 
  have := subset_positive_null_set hu hv hw hsu
  simp only [Pi.neg_apply, neg_eq_zero, coe_neg] at this 
  exact this hw₁ hw₂ hwt
#align measure_theory.signed_measure.subset_negative_null_set MeasureTheory.SignedMeasure.subset_negative_null_set
-/

#print MeasureTheory.SignedMeasure.of_diff_eq_zero_of_symmDiff_eq_zero_positive /-
/-- If the symmetric difference of two positive sets is a null-set, then so are the differences
between the two sets. -/
theorem of_diff_eq_zero_of_symmDiff_eq_zero_positive (hu : MeasurableSet u) (hv : MeasurableSet v)
    (hsu : 0 ≤[u] s) (hsv : 0 ≤[v] s) (hs : s (u ∆ v) = 0) : s (u \ v) = 0 ∧ s (v \ u) = 0 :=
  by
  rw [restrict_le_restrict_iff] at hsu hsv 
  have a := hsu (hu.diff hv) (u.diff_subset v)
  have b := hsv (hv.diff hu) (v.diff_subset u)
  erw [of_union (Set.disjoint_of_subset_left (u.diff_subset v) disjoint_sdiff_self_right)
      (hu.diff hv) (hv.diff hu)] at
    hs 
  rw [zero_apply] at a b 
  constructor
  all_goals
    first
    | linarith
    | infer_instance
    | assumption
#align measure_theory.signed_measure.of_diff_eq_zero_of_symm_diff_eq_zero_positive MeasureTheory.SignedMeasure.of_diff_eq_zero_of_symmDiff_eq_zero_positive
-/

#print MeasureTheory.SignedMeasure.of_diff_eq_zero_of_symmDiff_eq_zero_negative /-
/-- If the symmetric difference of two negative sets is a null-set, then so are the differences
between the two sets. -/
theorem of_diff_eq_zero_of_symmDiff_eq_zero_negative (hu : MeasurableSet u) (hv : MeasurableSet v)
    (hsu : s ≤[u] 0) (hsv : s ≤[v] 0) (hs : s (u ∆ v) = 0) : s (u \ v) = 0 ∧ s (v \ u) = 0 :=
  by
  rw [← s.neg_le_neg_iff _ hu, neg_zero] at hsu 
  rw [← s.neg_le_neg_iff _ hv, neg_zero] at hsv 
  have := of_diff_eq_zero_of_symm_diff_eq_zero_positive hu hv hsu hsv
  simp only [Pi.neg_apply, neg_eq_zero, coe_neg] at this 
  exact this hs
#align measure_theory.signed_measure.of_diff_eq_zero_of_symm_diff_eq_zero_negative MeasureTheory.SignedMeasure.of_diff_eq_zero_of_symmDiff_eq_zero_negative
-/

#print MeasureTheory.SignedMeasure.of_inter_eq_of_symmDiff_eq_zero_positive /-
theorem of_inter_eq_of_symmDiff_eq_zero_positive (hu : MeasurableSet u) (hv : MeasurableSet v)
    (hw : MeasurableSet w) (hsu : 0 ≤[u] s) (hsv : 0 ≤[v] s) (hs : s (u ∆ v) = 0) :
    s (w ∩ u) = s (w ∩ v) :=
  by
  have hwuv : s ((w ∩ u) ∆ (w ∩ v)) = 0 :=
    by
    refine'
      subset_positive_null_set (hu.union hv) ((hw.inter hu).symmDiff (hw.inter hv))
        (hu.symm_diff hv) (restrict_le_restrict_union _ _ hu hsu hv hsv) hs symm_diff_subset_union _
    rw [← inter_symm_diff_distrib_left]
    exact inter_subset_right _ _
  obtain ⟨huv, hvu⟩ :=
    of_diff_eq_zero_of_symm_diff_eq_zero_positive (hw.inter hu) (hw.inter hv)
      (restrict_le_restrict_subset _ _ hu hsu (w.inter_subset_right u))
      (restrict_le_restrict_subset _ _ hv hsv (w.inter_subset_right v)) hwuv
  rw [← of_diff_of_diff_eq_zero (hw.inter hu) (hw.inter hv) hvu, huv, zero_add]
#align measure_theory.signed_measure.of_inter_eq_of_symm_diff_eq_zero_positive MeasureTheory.SignedMeasure.of_inter_eq_of_symmDiff_eq_zero_positive
-/

#print MeasureTheory.SignedMeasure.of_inter_eq_of_symmDiff_eq_zero_negative /-
theorem of_inter_eq_of_symmDiff_eq_zero_negative (hu : MeasurableSet u) (hv : MeasurableSet v)
    (hw : MeasurableSet w) (hsu : s ≤[u] 0) (hsv : s ≤[v] 0) (hs : s (u ∆ v) = 0) :
    s (w ∩ u) = s (w ∩ v) :=
  by
  rw [← s.neg_le_neg_iff _ hu, neg_zero] at hsu 
  rw [← s.neg_le_neg_iff _ hv, neg_zero] at hsv 
  have := of_inter_eq_of_symm_diff_eq_zero_positive hu hv hw hsu hsv
  simp only [Pi.neg_apply, neg_inj, neg_eq_zero, coe_neg] at this 
  exact this hs
#align measure_theory.signed_measure.of_inter_eq_of_symm_diff_eq_zero_negative MeasureTheory.SignedMeasure.of_inter_eq_of_symmDiff_eq_zero_negative
-/

end

end SignedMeasure

namespace JordanDecomposition

open Measure VectorMeasure SignedMeasure Function

private theorem eq_of_pos_part_eq_pos_part {j₁ j₂ : JordanDecomposition α}
    (hj : j₁.posPart = j₂.posPart) (hj' : j₁.toSignedMeasure = j₂.toSignedMeasure) : j₁ = j₂ :=
  by
  ext1
  · exact hj
  · rw [← to_signed_measure_eq_to_signed_measure_iff]
    suffices
      j₁.pos_part.to_signed_measure - j₁.neg_part.to_signed_measure =
        j₁.pos_part.to_signed_measure - j₂.neg_part.to_signed_measure
      by exact sub_right_inj.mp this
    convert hj'

#print MeasureTheory.JordanDecomposition.toSignedMeasure_injective /-
/-- The Jordan decomposition of a signed measure is unique. -/
theorem toSignedMeasure_injective : Injective <| @JordanDecomposition.toSignedMeasure α _ :=
  by
  /- The main idea is that two Jordan decompositions of a signed measure provide two
    Hahn decompositions for that measure. Then, from `of_symm_diff_compl_positive_negative`,
    the symmetric difference of the two Hahn decompositions has measure zero, thus, allowing us to
    show the equality of the underlying measures of the Jordan decompositions. -/
  intro j₁ j₂ hj
  -- obtain the two Hahn decompositions from the Jordan decompositions
  obtain ⟨S, hS₁, hS₂, hS₃, hS₄, hS₅⟩ := j₁.exists_compl_positive_negative
  obtain ⟨T, hT₁, hT₂, hT₃, hT₄, hT₅⟩ := j₂.exists_compl_positive_negative
  rw [← hj] at hT₂ hT₃ 
  -- the symmetric differences of the two Hahn decompositions have measure zero
  obtain ⟨hST₁, -⟩ :=
    of_symm_diff_compl_positive_negative hS₁.compl hT₁.compl ⟨hS₃, (compl_compl S).symm ▸ hS₂⟩
      ⟨hT₃, (compl_compl T).symm ▸ hT₂⟩
  -- it suffices to show the Jordan decompositions have the same positive parts
  refine' eq_of_pos_part_eq_pos_part _ hj
  ext1 i hi
  -- we see that the positive parts of the two Jordan decompositions are equal to their
  -- associated signed measures restricted on their associated Hahn decompositions
  have hμ₁ : (j₁.pos_part i).toReal = j₁.to_signed_measure (i ∩ Sᶜ) :=
    by
    rw [to_signed_measure, to_signed_measure_sub_apply (hi.inter hS₁.compl),
      show j₁.neg_part (i ∩ Sᶜ) = 0 from
        nonpos_iff_eq_zero.1 (hS₅ ▸ measure_mono (Set.inter_subset_right _ _)),
      ENNReal.zero_toReal, sub_zero]
    conv_lhs => rw [← Set.inter_union_compl i S]
    rw [measure_union,
      show j₁.pos_part (i ∩ S) = 0 from
        nonpos_iff_eq_zero.1 (hS₄ ▸ measure_mono (Set.inter_subset_right _ _)),
      zero_add]
    ·
      refine'
        Set.disjoint_of_subset_left (Set.inter_subset_right _ _)
          (Set.disjoint_of_subset_right (Set.inter_subset_right _ _) disjoint_compl_right)
    · exact hi.inter hS₁.compl
  have hμ₂ : (j₂.pos_part i).toReal = j₂.to_signed_measure (i ∩ Tᶜ) :=
    by
    rw [to_signed_measure, to_signed_measure_sub_apply (hi.inter hT₁.compl),
      show j₂.neg_part (i ∩ Tᶜ) = 0 from
        nonpos_iff_eq_zero.1 (hT₅ ▸ measure_mono (Set.inter_subset_right _ _)),
      ENNReal.zero_toReal, sub_zero]
    conv_lhs => rw [← Set.inter_union_compl i T]
    rw [measure_union,
      show j₂.pos_part (i ∩ T) = 0 from
        nonpos_iff_eq_zero.1 (hT₄ ▸ measure_mono (Set.inter_subset_right _ _)),
      zero_add]
    ·
      exact
        Set.disjoint_of_subset_left (Set.inter_subset_right _ _)
          (Set.disjoint_of_subset_right (Set.inter_subset_right _ _) disjoint_compl_right)
    · exact hi.inter hT₁.compl
  -- since the two signed measures associated with the Jordan decompositions are the same,
  -- and the symmetric difference of the Hahn decompositions have measure zero, the result follows
  rw [← ENNReal.toReal_eq_toReal (measure_ne_top _ _) (measure_ne_top _ _), hμ₁, hμ₂, ← hj]
  exact of_inter_eq_of_symm_diff_eq_zero_positive hS₁.compl hT₁.compl hi hS₃ hT₃ hST₁
  all_goals infer_instance
#align measure_theory.jordan_decomposition.to_signed_measure_injective MeasureTheory.JordanDecomposition.toSignedMeasure_injective
-/

#print MeasureTheory.JordanDecomposition.toJordanDecomposition_toSignedMeasure /-
@[simp]
theorem toJordanDecomposition_toSignedMeasure (j : JordanDecomposition α) :
    j.toSignedMeasure.toJordanDecomposition = j :=
  (@toSignedMeasure_injective _ _ j j.toSignedMeasure.toJordanDecomposition (by simp)).symm
#align measure_theory.jordan_decomposition.to_jordan_decomposition_to_signed_measure MeasureTheory.JordanDecomposition.toJordanDecomposition_toSignedMeasure
-/

end JordanDecomposition

namespace SignedMeasure

open JordanDecomposition

#print MeasureTheory.SignedMeasure.toJordanDecompositionEquiv /-
/-- `measure_theory.signed_measure.to_jordan_decomposition` and
`measure_theory.jordan_decomposition.to_signed_measure` form a `equiv`. -/
@[simps apply symm_apply]
def toJordanDecompositionEquiv (α : Type _) [MeasurableSpace α] :
    SignedMeasure α ≃ JordanDecomposition α
    where
  toFun := toJordanDecomposition
  invFun := toSignedMeasure
  left_inv := toSignedMeasure_toJordanDecomposition
  right_inv := toJordanDecomposition_toSignedMeasure
#align measure_theory.signed_measure.to_jordan_decomposition_equiv MeasureTheory.SignedMeasure.toJordanDecompositionEquiv
-/

#print MeasureTheory.SignedMeasure.toJordanDecomposition_zero /-
theorem toJordanDecomposition_zero : (0 : SignedMeasure α).toJordanDecomposition = 0 :=
  by
  apply to_signed_measure_injective
  simp [to_signed_measure_zero]
#align measure_theory.signed_measure.to_jordan_decomposition_zero MeasureTheory.SignedMeasure.toJordanDecomposition_zero
-/

#print MeasureTheory.SignedMeasure.toJordanDecomposition_neg /-
theorem toJordanDecomposition_neg (s : SignedMeasure α) :
    (-s).toJordanDecomposition = -s.toJordanDecomposition :=
  by
  apply to_signed_measure_injective
  simp [to_signed_measure_neg]
#align measure_theory.signed_measure.to_jordan_decomposition_neg MeasureTheory.SignedMeasure.toJordanDecomposition_neg
-/

#print MeasureTheory.SignedMeasure.toJordanDecomposition_smul /-
theorem toJordanDecomposition_smul (s : SignedMeasure α) (r : ℝ≥0) :
    (r • s).toJordanDecomposition = r • s.toJordanDecomposition :=
  by
  apply to_signed_measure_injective
  simp [to_signed_measure_smul]
#align measure_theory.signed_measure.to_jordan_decomposition_smul MeasureTheory.SignedMeasure.toJordanDecomposition_smul
-/

private theorem to_jordan_decomposition_smul_real_nonneg (s : SignedMeasure α) (r : ℝ)
    (hr : 0 ≤ r) : (r • s).toJordanDecomposition = r • s.toJordanDecomposition :=
  by
  lift r to ℝ≥0 using hr
  rw [jordan_decomposition.coe_smul, ← to_jordan_decomposition_smul]
  rfl

#print MeasureTheory.SignedMeasure.toJordanDecomposition_smul_real /-
theorem toJordanDecomposition_smul_real (s : SignedMeasure α) (r : ℝ) :
    (r • s).toJordanDecomposition = r • s.toJordanDecomposition :=
  by
  by_cases hr : 0 ≤ r
  · exact to_jordan_decomposition_smul_real_nonneg s r hr
  · ext1
    · rw [real_smul_pos_part_neg _ _ (not_le.1 hr),
        show r • s = -(-r • s) by rw [neg_smul, neg_neg], to_jordan_decomposition_neg, neg_pos_part,
        to_jordan_decomposition_smul_real_nonneg, ← smul_neg_part, real_smul_nonneg]
      all_goals exact Left.nonneg_neg_iff.2 (le_of_lt (not_le.1 hr))
    · rw [real_smul_neg_part_neg _ _ (not_le.1 hr),
        show r • s = -(-r • s) by rw [neg_smul, neg_neg], to_jordan_decomposition_neg, neg_neg_part,
        to_jordan_decomposition_smul_real_nonneg, ← smul_pos_part, real_smul_nonneg]
      all_goals exact Left.nonneg_neg_iff.2 (le_of_lt (not_le.1 hr))
#align measure_theory.signed_measure.to_jordan_decomposition_smul_real MeasureTheory.SignedMeasure.toJordanDecomposition_smul_real
-/

#print MeasureTheory.SignedMeasure.toJordanDecomposition_eq /-
theorem toJordanDecomposition_eq {s : SignedMeasure α} {j : JordanDecomposition α}
    (h : s = j.toSignedMeasure) : s.toJordanDecomposition = j := by
  rw [h, to_jordan_decomposition_to_signed_measure]
#align measure_theory.signed_measure.to_jordan_decomposition_eq MeasureTheory.SignedMeasure.toJordanDecomposition_eq
-/

#print MeasureTheory.SignedMeasure.totalVariation /-
/-- The total variation of a signed measure. -/
def totalVariation (s : SignedMeasure α) : Measure α :=
  s.toJordanDecomposition.posPart + s.toJordanDecomposition.negPart
#align measure_theory.signed_measure.total_variation MeasureTheory.SignedMeasure.totalVariation
-/

#print MeasureTheory.SignedMeasure.totalVariation_zero /-
theorem totalVariation_zero : (0 : SignedMeasure α).totalVariation = 0 := by
  simp [total_variation, to_jordan_decomposition_zero]
#align measure_theory.signed_measure.total_variation_zero MeasureTheory.SignedMeasure.totalVariation_zero
-/

#print MeasureTheory.SignedMeasure.totalVariation_neg /-
theorem totalVariation_neg (s : SignedMeasure α) : (-s).totalVariation = s.totalVariation := by
  simp [total_variation, to_jordan_decomposition_neg, add_comm]
#align measure_theory.signed_measure.total_variation_neg MeasureTheory.SignedMeasure.totalVariation_neg
-/

#print MeasureTheory.SignedMeasure.null_of_totalVariation_zero /-
theorem null_of_totalVariation_zero (s : SignedMeasure α) {i : Set α}
    (hs : s.totalVariation i = 0) : s i = 0 :=
  by
  rw [total_variation, measure.coe_add, Pi.add_apply, add_eq_zero_iff] at hs 
  rw [← to_signed_measure_to_jordan_decomposition s, to_signed_measure, vector_measure.coe_sub,
    Pi.sub_apply, measure.to_signed_measure_apply, measure.to_signed_measure_apply]
  by_cases hi : MeasurableSet i
  · rw [if_pos hi, if_pos hi]; simp [hs.1, hs.2]
  · simp [if_neg hi]
#align measure_theory.signed_measure.null_of_total_variation_zero MeasureTheory.SignedMeasure.null_of_totalVariation_zero
-/

#print MeasureTheory.SignedMeasure.absolutelyContinuous_ennreal_iff /-
theorem absolutelyContinuous_ennreal_iff (s : SignedMeasure α) (μ : VectorMeasure α ℝ≥0∞) :
    s ≪ᵥ μ ↔ s.totalVariation ≪ μ.ennrealToMeasure :=
  by
  constructor <;> intro h
  · refine' measure.absolutely_continuous.mk fun S hS₁ hS₂ => _
    obtain ⟨i, hi₁, hi₂, hi₃, hpos, hneg⟩ := s.to_jordan_decomposition_spec
    rw [total_variation, measure.add_apply, hpos, hneg, to_measure_of_zero_le_apply _ _ _ hS₁,
      to_measure_of_le_zero_apply _ _ _ hS₁]
    rw [← vector_measure.absolutely_continuous.ennreal_to_measure] at h 
    simp [h (measure_mono_null (i.inter_subset_right S) hS₂),
      h (measure_mono_null (iᶜ.inter_subset_right S) hS₂)]
  · refine' vector_measure.absolutely_continuous.mk fun S hS₁ hS₂ => _
    rw [← vector_measure.ennreal_to_measure_apply hS₁] at hS₂ 
    exact null_of_total_variation_zero s (h hS₂)
#align measure_theory.signed_measure.absolutely_continuous_ennreal_iff MeasureTheory.SignedMeasure.absolutelyContinuous_ennreal_iff
-/

#print MeasureTheory.SignedMeasure.totalVariation_absolutelyContinuous_iff /-
theorem totalVariation_absolutelyContinuous_iff (s : SignedMeasure α) (μ : Measure α) :
    s.totalVariation ≪ μ ↔
      s.toJordanDecomposition.posPart ≪ μ ∧ s.toJordanDecomposition.negPart ≪ μ :=
  by
  constructor <;> intro h
  · constructor;
    all_goals
      refine' measure.absolutely_continuous.mk fun S hS₁ hS₂ => _
      have := h hS₂
      rw [total_variation, measure.add_apply, add_eq_zero_iff] at this 
    exacts [this.1, this.2]
  · refine' measure.absolutely_continuous.mk fun S hS₁ hS₂ => _
    rw [total_variation, measure.add_apply, h.1 hS₂, h.2 hS₂, add_zero]
#align measure_theory.signed_measure.total_variation_absolutely_continuous_iff MeasureTheory.SignedMeasure.totalVariation_absolutelyContinuous_iff
-/

#print MeasureTheory.SignedMeasure.mutuallySingular_iff /-
-- TODO: Generalize to vector measures once total variation on vector measures is defined
theorem mutuallySingular_iff (s t : SignedMeasure α) :
    s ⟂ᵥ t ↔ s.totalVariation ⟂ₘ t.totalVariation :=
  by
  constructor
  · rintro ⟨u, hmeas, hu₁, hu₂⟩
    obtain ⟨i, hi₁, hi₂, hi₃, hipos, hineg⟩ := s.to_jordan_decomposition_spec
    obtain ⟨j, hj₁, hj₂, hj₃, hjpos, hjneg⟩ := t.to_jordan_decomposition_spec
    refine' ⟨u, hmeas, _, _⟩
    · rw [total_variation, measure.add_apply, hipos, hineg, to_measure_of_zero_le_apply _ _ _ hmeas,
        to_measure_of_le_zero_apply _ _ _ hmeas]
      simp [hu₁ _ (Set.inter_subset_right _ _)]
    · rw [total_variation, measure.add_apply, hjpos, hjneg,
        to_measure_of_zero_le_apply _ _ _ hmeas.compl,
        to_measure_of_le_zero_apply _ _ _ hmeas.compl]
      simp [hu₂ _ (Set.inter_subset_right _ _)]
  · rintro ⟨u, hmeas, hu₁, hu₂⟩
    exact
      ⟨u, hmeas, fun t htu => null_of_total_variation_zero _ (measure_mono_null htu hu₁),
        fun t htv => null_of_total_variation_zero _ (measure_mono_null htv hu₂)⟩
#align measure_theory.signed_measure.mutually_singular_iff MeasureTheory.SignedMeasure.mutuallySingular_iff
-/

#print MeasureTheory.SignedMeasure.mutuallySingular_ennreal_iff /-
theorem mutuallySingular_ennreal_iff (s : SignedMeasure α) (μ : VectorMeasure α ℝ≥0∞) :
    s ⟂ᵥ μ ↔ s.totalVariation ⟂ₘ μ.ennrealToMeasure :=
  by
  constructor
  · rintro ⟨u, hmeas, hu₁, hu₂⟩
    obtain ⟨i, hi₁, hi₂, hi₃, hpos, hneg⟩ := s.to_jordan_decomposition_spec
    refine' ⟨u, hmeas, _, _⟩
    · rw [total_variation, measure.add_apply, hpos, hneg, to_measure_of_zero_le_apply _ _ _ hmeas,
        to_measure_of_le_zero_apply _ _ _ hmeas]
      simp [hu₁ _ (Set.inter_subset_right _ _)]
    · rw [vector_measure.ennreal_to_measure_apply hmeas.compl]
      exact hu₂ _ (Set.Subset.refl _)
  · rintro ⟨u, hmeas, hu₁, hu₂⟩
    refine'
      vector_measure.mutually_singular.mk u hmeas
        (fun t htu _ => null_of_total_variation_zero _ (measure_mono_null htu hu₁)) fun t htv hmt =>
        _
    rw [← vector_measure.ennreal_to_measure_apply hmt]
    exact measure_mono_null htv hu₂
#align measure_theory.signed_measure.mutually_singular_ennreal_iff MeasureTheory.SignedMeasure.mutuallySingular_ennreal_iff
-/

#print MeasureTheory.SignedMeasure.totalVariation_mutuallySingular_iff /-
theorem totalVariation_mutuallySingular_iff (s : SignedMeasure α) (μ : Measure α) :
    s.totalVariation ⟂ₘ μ ↔
      s.toJordanDecomposition.posPart ⟂ₘ μ ∧ s.toJordanDecomposition.negPart ⟂ₘ μ :=
  Measure.MutuallySingular.add_left_iff
#align measure_theory.signed_measure.total_variation_mutually_singular_iff MeasureTheory.SignedMeasure.totalVariation_mutuallySingular_iff
-/

end SignedMeasure

end MeasureTheory

