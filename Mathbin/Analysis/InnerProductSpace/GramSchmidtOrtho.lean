/-
Copyright (c) 2022 Jiale Miao. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jiale Miao, Kevin Buzzard, Alexander Bentkamp

! This file was ported from Lean 3 source module analysis.inner_product_space.gram_schmidt_ortho
! leanprover-community/mathlib commit 61b5e2755ccb464b68d05a9acf891ae04992d09d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.PiL2
import Mathbin.LinearAlgebra.Matrix.Block

/-!
# Gram-Schmidt Orthogonalization and Orthonormalization

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we introduce Gram-Schmidt Orthogonalization and Orthonormalization.

The Gram-Schmidt process takes a set of vectors as input
and outputs a set of orthogonal vectors which have the same span.

## Main results

- `gram_schmidt` : the Gram-Schmidt process
- `gram_schmidt_orthogonal` :
  `gram_schmidt` produces an orthogonal system of vectors.
- `span_gram_schmidt` :
  `gram_schmidt` preserves span of vectors.
- `gram_schmidt_ne_zero` :
  If the input vectors of `gram_schmidt` are linearly independent,
  then the output vectors are non-zero.
- `gram_schmidt_basis` :
  The basis produced by the Gram-Schmidt process when given a basis as input.
- `gram_schmidt_normed` :
  the normalized `gram_schmidt` (i.e each vector in `gram_schmidt_normed` has unit length.)
- `gram_schmidt_orthornormal` :
  `gram_schmidt_normed` produces an orthornormal system of vectors.
- `gram_schmidt_orthonormal_basis`: orthonormal basis constructed by the Gram-Schmidt process from
  an indexed set of vectors of the right size
-/


open scoped BigOperators

open Finset Submodule FiniteDimensional

variable (𝕜 : Type _) {E : Type _} [IsROrC 𝕜] [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]

variable {ι : Type _} [LinearOrder ι] [LocallyFiniteOrderBot ι] [IsWellOrder ι (· < ·)]

attribute [local instance] IsWellOrder.toHasWellFounded

local notation "⟪" x ", " y "⟫" => @inner 𝕜 _ _ x y

#print gramSchmidt /-
/-- The Gram-Schmidt process takes a set of vectors as input
and outputs a set of orthogonal vectors which have the same span. -/
noncomputable def gramSchmidt (f : ι → E) : ι → E
  | n => f n - ∑ i : Iio n, orthogonalProjection (𝕜 ∙ gramSchmidt i) (f n)
decreasing_by exact mem_Iio.1 i.2
#align gram_schmidt gramSchmidt
-/

#print gramSchmidt_def /-
/-- This lemma uses `∑ i in` instead of `∑ i :`.-/
theorem gramSchmidt_def (f : ι → E) (n : ι) :
    gramSchmidt 𝕜 f n = f n - ∑ i in Iio n, orthogonalProjection (𝕜 ∙ gramSchmidt 𝕜 f i) (f n) := by
  rw [← sum_attach, attach_eq_univ, gramSchmidt]; rfl
#align gram_schmidt_def gramSchmidt_def
-/

#print gramSchmidt_def' /-
theorem gramSchmidt_def' (f : ι → E) (n : ι) :
    f n = gramSchmidt 𝕜 f n + ∑ i in Iio n, orthogonalProjection (𝕜 ∙ gramSchmidt 𝕜 f i) (f n) := by
  rw [gramSchmidt_def, sub_add_cancel]
#align gram_schmidt_def' gramSchmidt_def'
-/

#print gramSchmidt_def'' /-
theorem gramSchmidt_def'' (f : ι → E) (n : ι) :
    f n =
      gramSchmidt 𝕜 f n +
        ∑ i in Iio n, (⟪gramSchmidt 𝕜 f i, f n⟫ / ‖gramSchmidt 𝕜 f i‖ ^ 2) • gramSchmidt 𝕜 f i :=
  by
  convert gramSchmidt_def' 𝕜 f n
  ext i
  rw [orthogonalProjection_singleton]
#align gram_schmidt_def'' gramSchmidt_def''
-/

#print gramSchmidt_zero /-
@[simp]
theorem gramSchmidt_zero {ι : Type _} [LinearOrder ι] [LocallyFiniteOrder ι] [OrderBot ι]
    [IsWellOrder ι (· < ·)] (f : ι → E) : gramSchmidt 𝕜 f ⊥ = f ⊥ := by
  rw [gramSchmidt_def, Iio_eq_Ico, Finset.Ico_self, Finset.sum_empty, sub_zero]
#align gram_schmidt_zero gramSchmidt_zero
-/

#print gramSchmidt_orthogonal /-
/-- **Gram-Schmidt Orthogonalisation**:
`gram_schmidt` produces an orthogonal system of vectors. -/
theorem gramSchmidt_orthogonal (f : ι → E) {a b : ι} (h₀ : a ≠ b) :
    ⟪gramSchmidt 𝕜 f a, gramSchmidt 𝕜 f b⟫ = 0 :=
  by
  suffices ∀ a b : ι, a < b → ⟪gramSchmidt 𝕜 f a, gramSchmidt 𝕜 f b⟫ = 0
    by
    cases' h₀.lt_or_lt with ha hb
    · exact this _ _ ha
    · rw [inner_eq_zero_symm]
      exact this _ _ hb
  clear h₀ a b
  intro a b h₀
  revert a
  apply WellFounded.induction (@IsWellFounded.wf ι (· < ·) _) b
  intro b ih a h₀
  simp only [gramSchmidt_def 𝕜 f b, inner_sub_right, inner_sum, orthogonalProjection_singleton,
    inner_smul_right]
  rw [Finset.sum_eq_single_of_mem a (finset.mem_Iio.mpr h₀)]
  · by_cases h : gramSchmidt 𝕜 f a = 0
    · simp only [h, inner_zero_left, zero_div, MulZeroClass.zero_mul, sub_zero]
    · rw [← inner_self_eq_norm_sq_to_K, div_mul_cancel, sub_self]
      rwa [inner_self_ne_zero]
  simp_intro i hi hia only [Finset.mem_range]
  simp only [mul_eq_zero, div_eq_zero_iff, inner_self_eq_zero]
  right
  cases' hia.lt_or_lt with hia₁ hia₂
  · rw [inner_eq_zero_symm]
    exact ih a h₀ i hia₁
  · exact ih i (mem_Iio.1 hi) a hia₂
#align gram_schmidt_orthogonal gramSchmidt_orthogonal
-/

#print gramSchmidt_pairwise_orthogonal /-
/-- This is another version of `gram_schmidt_orthogonal` using `pairwise` instead. -/
theorem gramSchmidt_pairwise_orthogonal (f : ι → E) :
    Pairwise fun a b => ⟪gramSchmidt 𝕜 f a, gramSchmidt 𝕜 f b⟫ = 0 := fun a b =>
  gramSchmidt_orthogonal 𝕜 f
#align gram_schmidt_pairwise_orthogonal gramSchmidt_pairwise_orthogonal
-/

#print gramSchmidt_inv_triangular /-
theorem gramSchmidt_inv_triangular (v : ι → E) {i j : ι} (hij : i < j) :
    ⟪gramSchmidt 𝕜 v j, v i⟫ = 0 := by
  rw [gramSchmidt_def'' 𝕜 v]
  simp only [inner_add_right, inner_sum, inner_smul_right]
  set b : ι → E := gramSchmidt 𝕜 v
  convert zero_add (0 : 𝕜)
  · exact gramSchmidt_orthogonal 𝕜 v hij.ne'
  apply Finset.sum_eq_zero
  rintro k hki'
  have hki : k < i := by simpa using hki'
  have : ⟪b j, b k⟫ = 0 := gramSchmidt_orthogonal 𝕜 v (hki.trans hij).ne'
  simp [this]
#align gram_schmidt_inv_triangular gramSchmidt_inv_triangular
-/

open Submodule Set Order

#print mem_span_gramSchmidt /-
theorem mem_span_gramSchmidt (f : ι → E) {i j : ι} (hij : i ≤ j) :
    f i ∈ span 𝕜 (gramSchmidt 𝕜 f '' Iic j) :=
  by
  rw [gramSchmidt_def' 𝕜 f i]
  simp_rw [orthogonalProjection_singleton]
  exact
    Submodule.add_mem _ (subset_span <| mem_image_of_mem _ hij)
      (Submodule.sum_mem _ fun k hk =>
        smul_mem (span 𝕜 (gramSchmidt 𝕜 f '' Iic j)) _ <|
          subset_span <| mem_image_of_mem (gramSchmidt 𝕜 f) <| (Finset.mem_Iio.1 hk).le.trans hij)
#align mem_span_gram_schmidt mem_span_gramSchmidt
-/

#print gramSchmidt_mem_span /-
theorem gramSchmidt_mem_span (f : ι → E) : ∀ {j i}, i ≤ j → gramSchmidt 𝕜 f i ∈ span 𝕜 (f '' Iic j)
  | j => fun i hij => by
    rw [gramSchmidt_def 𝕜 f i]
    simp_rw [orthogonalProjection_singleton]
    refine'
      Submodule.sub_mem _ (subset_span (mem_image_of_mem _ hij)) (Submodule.sum_mem _ fun k hk => _)
    let hkj : k < j := (Finset.mem_Iio.1 hk).trans_le hij
    exact
      smul_mem _ _
        (span_mono (image_subset f <| Iic_subset_Iic.2 hkj.le) <| gramSchmidt_mem_span le_rfl)
#align gram_schmidt_mem_span gramSchmidt_mem_span
-/

#print span_gramSchmidt_Iic /-
theorem span_gramSchmidt_Iic (f : ι → E) (c : ι) :
    span 𝕜 (gramSchmidt 𝕜 f '' Iic c) = span 𝕜 (f '' Iic c) :=
  span_eq_span (Set.image_subset_iff.2 fun i => gramSchmidt_mem_span _ _) <|
    Set.image_subset_iff.2 fun i => mem_span_gramSchmidt _ _
#align span_gram_schmidt_Iic span_gramSchmidt_Iic
-/

#print span_gramSchmidt_Iio /-
theorem span_gramSchmidt_Iio (f : ι → E) (c : ι) :
    span 𝕜 (gramSchmidt 𝕜 f '' Iio c) = span 𝕜 (f '' Iio c) :=
  span_eq_span
      (Set.image_subset_iff.2 fun i hi =>
        span_mono (image_subset _ <| Iic_subset_Iio.2 hi) <| gramSchmidt_mem_span _ _ le_rfl) <|
    Set.image_subset_iff.2 fun i hi =>
      span_mono (image_subset _ <| Iic_subset_Iio.2 hi) <| mem_span_gramSchmidt _ _ le_rfl
#align span_gram_schmidt_Iio span_gramSchmidt_Iio
-/

#print span_gramSchmidt /-
/-- `gram_schmidt` preserves span of vectors. -/
theorem span_gramSchmidt (f : ι → E) : span 𝕜 (range (gramSchmidt 𝕜 f)) = span 𝕜 (range f) :=
  span_eq_span
      (range_subset_iff.2 fun i =>
        span_mono (image_subset_range _ _) <| gramSchmidt_mem_span _ _ le_rfl) <|
    range_subset_iff.2 fun i =>
      span_mono (image_subset_range _ _) <| mem_span_gramSchmidt _ _ le_rfl
#align span_gram_schmidt span_gramSchmidt
-/

#print gramSchmidt_of_orthogonal /-
theorem gramSchmidt_of_orthogonal {f : ι → E} (hf : Pairwise fun i j => ⟪f i, f j⟫ = 0) :
    gramSchmidt 𝕜 f = f := by
  ext i
  rw [gramSchmidt_def]
  trans f i - 0
  · congr
    apply Finset.sum_eq_zero
    intro j hj
    rw [coe_eq_zero]
    suffices span 𝕜 (f '' Set.Iic j) ⟂ 𝕜 ∙ f i
      by
      apply orthogonalProjection_mem_subspace_orthogonalComplement_eq_zero
      rw [mem_orthogonal_singleton_iff_inner_left]
      rw [← mem_orthogonal_singleton_iff_inner_right]
      exact this (gramSchmidt_mem_span 𝕜 f (le_refl j))
    rw [is_ortho_span]
    rintro u ⟨k, hk, rfl⟩ v (rfl : v = f i)
    apply hf
    exact (lt_of_le_of_lt hk (finset.mem_Iio.mp hj)).Ne
  · simp
#align gram_schmidt_of_orthogonal gramSchmidt_of_orthogonal
-/

variable {𝕜}

#print gramSchmidt_ne_zero_coe /-
theorem gramSchmidt_ne_zero_coe {f : ι → E} (n : ι)
    (h₀ : LinearIndependent 𝕜 (f ∘ (coe : Set.Iic n → ι))) : gramSchmidt 𝕜 f n ≠ 0 :=
  by
  by_contra h
  have h₁ : f n ∈ span 𝕜 (f '' Iio n) :=
    by
    rw [← span_gramSchmidt_Iio 𝕜 f n, gramSchmidt_def' _ f, h, zero_add]
    apply Submodule.sum_mem _ _
    simp_intro a ha only [Finset.mem_Ico]
    simp only [Set.mem_image, Set.mem_Iio, orthogonalProjection_singleton]
    apply Submodule.smul_mem _ _ _
    rw [Finset.mem_Iio] at ha 
    refine' subset_span ⟨a, ha, by rfl⟩
  have h₂ :
    (f ∘ (coe : Set.Iic n → ι)) ⟨n, le_refl n⟩ ∈
      span 𝕜 (f ∘ (coe : Set.Iic n → ι) '' Iio ⟨n, le_refl n⟩) :=
    by
    rw [image_comp]
    convert h₁ using 3
    ext i
    simpa using @le_of_lt _ _ i n
  apply LinearIndependent.not_mem_span_image h₀ _ h₂
  simp only [Set.mem_Iio, lt_self_iff_false, not_false_iff]
#align gram_schmidt_ne_zero_coe gramSchmidt_ne_zero_coe
-/

#print gramSchmidt_ne_zero /-
/-- If the input vectors of `gram_schmidt` are linearly independent,
then the output vectors are non-zero. -/
theorem gramSchmidt_ne_zero {f : ι → E} (n : ι) (h₀ : LinearIndependent 𝕜 f) :
    gramSchmidt 𝕜 f n ≠ 0 :=
  gramSchmidt_ne_zero_coe _ (LinearIndependent.comp h₀ _ Subtype.coe_injective)
#align gram_schmidt_ne_zero gramSchmidt_ne_zero
-/

#print gramSchmidt_triangular /-
/-- `gram_schmidt` produces a triangular matrix of vectors when given a basis. -/
theorem gramSchmidt_triangular {i j : ι} (hij : i < j) (b : Basis ι 𝕜 E) :
    b.repr (gramSchmidt 𝕜 b i) j = 0 :=
  by
  have : gramSchmidt 𝕜 b i ∈ span 𝕜 (gramSchmidt 𝕜 b '' Set.Iio j) :=
    subset_span ((Set.mem_image _ _ _).2 ⟨i, hij, rfl⟩)
  have : gramSchmidt 𝕜 b i ∈ span 𝕜 (b '' Set.Iio j) := by rwa [← span_gramSchmidt_Iio 𝕜 b j]
  have : ↑(b.repr (gramSchmidt 𝕜 b i)).support ⊆ Set.Iio j :=
    Basis.repr_support_subset_of_mem_span b (Set.Iio j) this
  exact (Finsupp.mem_supported' _ _).1 ((Finsupp.mem_supported 𝕜 _).2 this) j Set.not_mem_Iio_self
#align gram_schmidt_triangular gramSchmidt_triangular
-/

#print gramSchmidt_linearIndependent /-
/-- `gram_schmidt` produces linearly independent vectors when given linearly independent vectors. -/
theorem gramSchmidt_linearIndependent {f : ι → E} (h₀ : LinearIndependent 𝕜 f) :
    LinearIndependent 𝕜 (gramSchmidt 𝕜 f) :=
  linearIndependent_of_ne_zero_of_inner_eq_zero (fun i => gramSchmidt_ne_zero _ h₀) fun i j =>
    gramSchmidt_orthogonal 𝕜 f
#align gram_schmidt_linear_independent gramSchmidt_linearIndependent
-/

#print gramSchmidtBasis /-
/-- When given a basis, `gram_schmidt` produces a basis. -/
noncomputable def gramSchmidtBasis (b : Basis ι 𝕜 E) : Basis ι 𝕜 E :=
  Basis.mk (gramSchmidt_linearIndependent b.LinearIndependent)
    ((span_gramSchmidt 𝕜 b).trans b.span_eq).ge
#align gram_schmidt_basis gramSchmidtBasis
-/

#print coe_gramSchmidtBasis /-
theorem coe_gramSchmidtBasis (b : Basis ι 𝕜 E) : (gramSchmidtBasis b : ι → E) = gramSchmidt 𝕜 b :=
  Basis.coe_mk _ _
#align coe_gram_schmidt_basis coe_gramSchmidtBasis
-/

variable (𝕜)

#print gramSchmidtNormed /-
/-- the normalized `gram_schmidt`
(i.e each vector in `gram_schmidt_normed` has unit length.) -/
noncomputable def gramSchmidtNormed (f : ι → E) (n : ι) : E :=
  (‖gramSchmidt 𝕜 f n‖ : 𝕜)⁻¹ • gramSchmidt 𝕜 f n
#align gram_schmidt_normed gramSchmidtNormed
-/

variable {𝕜}

#print gramSchmidtNormed_unit_length_coe /-
theorem gramSchmidtNormed_unit_length_coe {f : ι → E} (n : ι)
    (h₀ : LinearIndependent 𝕜 (f ∘ (coe : Set.Iic n → ι))) : ‖gramSchmidtNormed 𝕜 f n‖ = 1 := by
  simp only [gramSchmidt_ne_zero_coe n h₀, gramSchmidtNormed, norm_smul_inv_norm, Ne.def,
    not_false_iff]
#align gram_schmidt_normed_unit_length_coe gramSchmidtNormed_unit_length_coe
-/

#print gramSchmidtNormed_unit_length /-
theorem gramSchmidtNormed_unit_length {f : ι → E} (n : ι) (h₀ : LinearIndependent 𝕜 f) :
    ‖gramSchmidtNormed 𝕜 f n‖ = 1 :=
  gramSchmidtNormed_unit_length_coe _ (LinearIndependent.comp h₀ _ Subtype.coe_injective)
#align gram_schmidt_normed_unit_length gramSchmidtNormed_unit_length
-/

#print gramSchmidtNormed_unit_length' /-
theorem gramSchmidtNormed_unit_length' {f : ι → E} {n : ι} (hn : gramSchmidtNormed 𝕜 f n ≠ 0) :
    ‖gramSchmidtNormed 𝕜 f n‖ = 1 :=
  by
  rw [gramSchmidtNormed] at *
  rw [norm_smul_inv_norm]
  simpa using hn
#align gram_schmidt_normed_unit_length' gramSchmidtNormed_unit_length'
-/

#print gramSchmidt_orthonormal /-
/-- **Gram-Schmidt Orthonormalization**:
`gram_schmidt_normed` applied to a linearly independent set of vectors produces an orthornormal
system of vectors. -/
theorem gramSchmidt_orthonormal {f : ι → E} (h₀ : LinearIndependent 𝕜 f) :
    Orthonormal 𝕜 (gramSchmidtNormed 𝕜 f) :=
  by
  unfold Orthonormal
  constructor
  · simp only [gramSchmidtNormed_unit_length, h₀, eq_self_iff_true, imp_true_iff]
  · intro i j hij
    simp only [gramSchmidtNormed, inner_smul_left, inner_smul_right, IsROrC.conj_inv,
      IsROrC.conj_ofReal, mul_eq_zero, inv_eq_zero, IsROrC.ofReal_eq_zero, norm_eq_zero]
    repeat' right
    exact gramSchmidt_orthogonal 𝕜 f hij
#align gram_schmidt_orthonormal gramSchmidt_orthonormal
-/

#print gramSchmidt_orthonormal' /-
/-- **Gram-Schmidt Orthonormalization**:
`gram_schmidt_normed` produces an orthornormal system of vectors after removing the vectors which
become zero in the process. -/
theorem gramSchmidt_orthonormal' (f : ι → E) :
    Orthonormal 𝕜 fun i : {i | gramSchmidtNormed 𝕜 f i ≠ 0} => gramSchmidtNormed 𝕜 f i :=
  by
  refine' ⟨fun i => gramSchmidtNormed_unit_length' i.Prop, _⟩
  rintro i j (hij : ¬_)
  rw [Subtype.ext_iff] at hij 
  simp [gramSchmidtNormed, inner_smul_left, inner_smul_right, gramSchmidt_orthogonal 𝕜 f hij]
#align gram_schmidt_orthonormal' gramSchmidt_orthonormal'
-/

#print span_gramSchmidtNormed /-
theorem span_gramSchmidtNormed (f : ι → E) (s : Set ι) :
    span 𝕜 (gramSchmidtNormed 𝕜 f '' s) = span 𝕜 (gramSchmidt 𝕜 f '' s) :=
  by
  refine'
    span_eq_span
      (Set.image_subset_iff.2 fun i hi => smul_mem _ _ <| subset_span <| mem_image_of_mem _ hi)
      (Set.image_subset_iff.2 fun i hi =>
        span_mono (image_subset _ <| singleton_subset_set_iff.2 hi) _)
  simp only [coe_singleton, Set.image_singleton]
  by_cases h : gramSchmidt 𝕜 f i = 0
  · simp [h]
  · refine' mem_span_singleton.2 ⟨‖gramSchmidt 𝕜 f i‖, smul_inv_smul₀ _ _⟩
    exact_mod_cast norm_ne_zero_iff.2 h
#align span_gram_schmidt_normed span_gramSchmidtNormed
-/

#print span_gramSchmidtNormed_range /-
theorem span_gramSchmidtNormed_range (f : ι → E) :
    span 𝕜 (range (gramSchmidtNormed 𝕜 f)) = span 𝕜 (range (gramSchmidt 𝕜 f)) := by
  simpa only [image_univ.symm] using span_gramSchmidtNormed f univ
#align span_gram_schmidt_normed_range span_gramSchmidtNormed_range
-/

section OrthonormalBasis

variable [Fintype ι] [FiniteDimensional 𝕜 E] (h : finrank 𝕜 E = Fintype.card ι) (f : ι → E)

#print gramSchmidtOrthonormalBasis /-
/-- Given an indexed family `f : ι → E` of vectors in an inner product space `E`, for which the
size of the index set is the dimension of `E`, produce an orthonormal basis for `E` which agrees
with the orthonormal set produced by the Gram-Schmidt orthonormalization process on the elements of
`ι` for which this process gives a nonzero number. -/
noncomputable def gramSchmidtOrthonormalBasis : OrthonormalBasis ι 𝕜 E :=
  ((gramSchmidt_orthonormal' f).exists_orthonormalBasis_extension_of_card_eq h).some
#align gram_schmidt_orthonormal_basis gramSchmidtOrthonormalBasis
-/

#print gramSchmidtOrthonormalBasis_apply /-
theorem gramSchmidtOrthonormalBasis_apply {f : ι → E} {i : ι} (hi : gramSchmidtNormed 𝕜 f i ≠ 0) :
    gramSchmidtOrthonormalBasis h f i = gramSchmidtNormed 𝕜 f i :=
  ((gramSchmidt_orthonormal' f).exists_orthonormalBasis_extension_of_card_eq h).choose_spec i hi
#align gram_schmidt_orthonormal_basis_apply gramSchmidtOrthonormalBasis_apply
-/

#print gramSchmidtOrthonormalBasis_apply_of_orthogonal /-
theorem gramSchmidtOrthonormalBasis_apply_of_orthogonal {f : ι → E}
    (hf : Pairwise fun i j => ⟪f i, f j⟫ = 0) {i : ι} (hi : f i ≠ 0) :
    gramSchmidtOrthonormalBasis h f i = (‖f i‖⁻¹ : 𝕜) • f i :=
  by
  have H : gramSchmidtNormed 𝕜 f i = (‖f i‖⁻¹ : 𝕜) • f i := by
    rw [gramSchmidtNormed, gramSchmidt_of_orthogonal 𝕜 hf]
  rw [gramSchmidtOrthonormalBasis_apply h, H]
  simpa [H] using hi
#align gram_schmidt_orthonormal_basis_apply_of_orthogonal gramSchmidtOrthonormalBasis_apply_of_orthogonal
-/

#print inner_gramSchmidtOrthonormalBasis_eq_zero /-
theorem inner_gramSchmidtOrthonormalBasis_eq_zero {f : ι → E} {i : ι}
    (hi : gramSchmidtNormed 𝕜 f i = 0) (j : ι) : ⟪gramSchmidtOrthonormalBasis h f i, f j⟫ = 0 :=
  by
  rw [← mem_orthogonal_singleton_iff_inner_right]
  suffices span 𝕜 (gramSchmidtNormed 𝕜 f '' Iic j) ⟂ 𝕜 ∙ gramSchmidtOrthonormalBasis h f i
    by
    apply this
    rw [span_gramSchmidtNormed]
    exact mem_span_gramSchmidt 𝕜 f le_rfl
  rw [is_ortho_span]
  rintro u ⟨k, hk, rfl⟩ v (rfl : v = _)
  by_cases hk : gramSchmidtNormed 𝕜 f k = 0
  · rw [hk, inner_zero_left]
  rw [← gramSchmidtOrthonormalBasis_apply h hk]
  have : k ≠ i := by
    rintro rfl
    exact hk hi
  exact (gramSchmidtOrthonormalBasis h f).Orthonormal.2 this
#align inner_gram_schmidt_orthonormal_basis_eq_zero inner_gramSchmidtOrthonormalBasis_eq_zero
-/

#print gramSchmidtOrthonormalBasis_inv_triangular /-
theorem gramSchmidtOrthonormalBasis_inv_triangular {i j : ι} (hij : i < j) :
    ⟪gramSchmidtOrthonormalBasis h f j, f i⟫ = 0 :=
  by
  by_cases hi : gramSchmidtNormed 𝕜 f j = 0
  · rw [inner_gramSchmidtOrthonormalBasis_eq_zero h hi]
  ·
    simp [gramSchmidtOrthonormalBasis_apply h hi, gramSchmidtNormed, inner_smul_left,
      gramSchmidt_inv_triangular 𝕜 f hij]
#align gram_schmidt_orthonormal_basis_inv_triangular gramSchmidtOrthonormalBasis_inv_triangular
-/

#print gramSchmidtOrthonormalBasis_inv_triangular' /-
theorem gramSchmidtOrthonormalBasis_inv_triangular' {i j : ι} (hij : i < j) :
    (gramSchmidtOrthonormalBasis h f).repr (f i) j = 0 := by
  simpa [OrthonormalBasis.repr_apply_apply] using gramSchmidtOrthonormalBasis_inv_triangular h f hij
#align gram_schmidt_orthonormal_basis_inv_triangular' gramSchmidtOrthonormalBasis_inv_triangular'
-/

#print gramSchmidtOrthonormalBasis_inv_blockTriangular /-
/-- Given an indexed family `f : ι → E` of vectors in an inner product space `E`, for which the
size of the index set is the dimension of `E`, the matrix of coefficients of `f` with respect to the
orthonormal basis `gram_schmidt_orthonormal_basis` constructed from `f` is upper-triangular. -/
theorem gramSchmidtOrthonormalBasis_inv_blockTriangular :
    ((gramSchmidtOrthonormalBasis h f).toBasis.toMatrix f).BlockTriangular id := fun i j =>
  gramSchmidtOrthonormalBasis_inv_triangular' h f
#align gram_schmidt_orthonormal_basis_inv_block_triangular gramSchmidtOrthonormalBasis_inv_blockTriangular
-/

#print gramSchmidtOrthonormalBasis_det /-
theorem gramSchmidtOrthonormalBasis_det :
    (gramSchmidtOrthonormalBasis h f).toBasis.det f =
      ∏ i, ⟪gramSchmidtOrthonormalBasis h f i, f i⟫ :=
  by
  convert Matrix.det_of_upperTriangular (gramSchmidtOrthonormalBasis_inv_blockTriangular h f)
  ext i
  exact ((gramSchmidtOrthonormalBasis h f).repr_apply_apply (f i) i).symm
#align gram_schmidt_orthonormal_basis_det gramSchmidtOrthonormalBasis_det
-/

end OrthonormalBasis

