/-
Copyright (c) 2022 Xavier Roblot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Alex J. Best, Xavier Roblot

! This file was ported from Lean 3 source module number_theory.number_field.embeddings
! leanprover-community/mathlib commit 5d0c76894ada7940957143163d7b921345474cbc
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Complex.Polynomial
import Mathbin.FieldTheory.Minpoly.IsIntegrallyClosed
import Mathbin.NumberTheory.NumberField.Basic
import Mathbin.RingTheory.Norm
import Mathbin.Topology.Instances.Complex

/-!
# Embeddings of number fields

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
This file defines the embeddings of a number field into an algebraic closed field.

## Main Results
* `number_field.embeddings.range_eval_eq_root_set_minpoly`: let `x ∈ K` with `K` number field and
  let `A` be an algebraic closed field of char. 0, then the images of `x` by the embeddings of `K`
   in `A` are exactly the roots in `A` of the minimal polynomial of `x` over `ℚ`.
* `number_field.embeddings.pow_eq_one_of_norm_eq_one`: an algebraic integer whose conjugates are
  all of norm one is a root of unity.

## Tags
number field, embeddings, places, infinite places
-/


open scoped Classical

namespace NumberField.Embeddings

section Fintype

open FiniteDimensional

variable (K : Type _) [Field K] [NumberField K]

variable (A : Type _) [Field A] [CharZero A]

/-- There are finitely many embeddings of a number field. -/
noncomputable instance : Fintype (K →+* A) :=
  Fintype.ofEquiv (K →ₐ[ℚ] A) RingHom.equivRatAlgHom.symm

variable [IsAlgClosed A]

#print NumberField.Embeddings.card /-
/-- The number of embeddings of a number field is equal to its finrank. -/
theorem card : Fintype.card (K →+* A) = finrank ℚ K := by
  rw [Fintype.ofEquiv_card ring_hom.equiv_rat_alg_hom.symm, AlgHom.card]
#align number_field.embeddings.card NumberField.Embeddings.card
-/

instance : Nonempty (K →+* A) :=
  by
  rw [← Fintype.card_pos_iff, NumberField.Embeddings.card K A]
  exact FiniteDimensional.finrank_pos

end Fintype

section Roots

open Set Polynomial

variable (K A : Type _) [Field K] [NumberField K] [Field A] [Algebra ℚ A] [IsAlgClosed A] (x : K)

#print NumberField.Embeddings.range_eval_eq_rootSet_minpoly /-
/-- Let `A` be an algebraically closed field and let `x ∈ K`, with `K` a number field.
The images of `x` by the embeddings of `K` in `A` are exactly the roots in `A` of
the minimal polynomial of `x` over `ℚ`. -/
theorem range_eval_eq_rootSet_minpoly : (range fun φ : K →+* A => φ x) = (minpoly ℚ x).rootSet A :=
  by
  convert (NumberField.isAlgebraic K).range_eval_eq_rootSet_minpoly A x using 1
  ext a
  exact ⟨fun ⟨φ, hφ⟩ => ⟨φ.toRatAlgHom, hφ⟩, fun ⟨φ, hφ⟩ => ⟨φ.toRingHom, hφ⟩⟩
#align number_field.embeddings.range_eval_eq_root_set_minpoly NumberField.Embeddings.range_eval_eq_rootSet_minpoly
-/

end Roots

section Bounded

open FiniteDimensional Polynomial Set

variable {K : Type _} [Field K] [NumberField K]

variable {A : Type _} [NormedField A] [IsAlgClosed A] [NormedAlgebra ℚ A]

#print NumberField.Embeddings.coeff_bdd_of_norm_le /-
theorem coeff_bdd_of_norm_le {B : ℝ} {x : K} (h : ∀ φ : K →+* A, ‖φ x‖ ≤ B) (i : ℕ) :
    ‖(minpoly ℚ x).coeff i‖ ≤ max B 1 ^ finrank ℚ K * (finrank ℚ K).choose (finrank ℚ K / 2) :=
  by
  have hx := IsSeparable.isIntegral ℚ x
  rw [← norm_algebraMap' A, ← coeff_map (algebraMap ℚ A)]
  refine'
    coeff_bdd_of_roots_le _ (minpoly.monic hx) (IsAlgClosed.splits_codomain _)
      (IntermediateField.minpoly.natDegree_le hx) (fun z hz => _) i
  classical
  rw [← Multiset.mem_toFinset] at hz 
  obtain ⟨φ, rfl⟩ := (range_eval_eq_root_set_minpoly K A x).symm.Subset hz
  exact h φ
#align number_field.embeddings.coeff_bdd_of_norm_le NumberField.Embeddings.coeff_bdd_of_norm_le
-/

variable (K A)

#print NumberField.Embeddings.finite_of_norm_le /-
/-- Let `B` be a real number. The set of algebraic integers in `K` whose conjugates are all
smaller in norm than `B` is finite. -/
theorem finite_of_norm_le (B : ℝ) : {x : K | IsIntegral ℤ x ∧ ∀ φ : K →+* A, ‖φ x‖ ≤ B}.Finite :=
  by
  let C := Nat.ceil (max B 1 ^ finrank ℚ K * (finrank ℚ K).choose (finrank ℚ K / 2))
  have := bUnion_roots_finite (algebraMap ℤ K) (finrank ℚ K) (finite_Icc (-C : ℤ) C)
  refine' this.subset fun x hx => _; simp_rw [mem_Union]
  have h_map_ℚ_minpoly := minpoly.isIntegrallyClosed_eq_field_fractions' ℚ hx.1
  refine' ⟨_, ⟨_, fun i => _⟩, mem_root_set.2 ⟨minpoly.ne_zero hx.1, minpoly.aeval ℤ x⟩⟩
  · rw [← (minpoly.monic hx.1).natDegree_map (algebraMap ℤ ℚ), ← h_map_ℚ_minpoly]
    exact IntermediateField.minpoly.natDegree_le (isIntegral_of_isScalarTower hx.1)
  rw [mem_Icc, ← abs_le, ← @Int.cast_le ℝ]
  refine' (Eq.trans_le _ <| coeff_bdd_of_norm_le hx.2 i).trans (Nat.le_ceil _)
  rw [h_map_ℚ_minpoly, coeff_map, eq_intCast, Int.norm_cast_rat, Int.norm_eq_abs, Int.cast_abs]
#align number_field.embeddings.finite_of_norm_le NumberField.Embeddings.finite_of_norm_le
-/

#print NumberField.Embeddings.pow_eq_one_of_norm_eq_one /-
/-- An algebraic integer whose conjugates are all of norm one is a root of unity. -/
theorem pow_eq_one_of_norm_eq_one {x : K} (hxi : IsIntegral ℤ x) (hx : ∀ φ : K →+* A, ‖φ x‖ = 1) :
    ∃ (n : ℕ) (hn : 0 < n), x ^ n = 1 :=
  by
  obtain ⟨a, -, b, -, habne, h⟩ :=
    @Set.Infinite.exists_ne_map_eq_of_mapsTo _ _ _ _ ((· ^ ·) x : ℕ → K) Set.infinite_univ _
      (finite_of_norm_le K A (1 : ℝ))
  · wlog hlt : b < a
    · exact this hxi hx b a habne.symm h.symm (habne.lt_or_lt.resolve_right hlt)
    refine' ⟨a - b, tsub_pos_of_lt hlt, _⟩
    rw [← Nat.sub_add_cancel hlt.le, pow_add, mul_left_eq_self₀] at h 
    refine' h.resolve_right fun hp => _
    specialize hx (IsAlgClosed.lift (NumberField.isAlgebraic K)).toRingHom
    rw [pow_eq_zero hp, map_zero, norm_zero] at hx ; norm_num at hx 
  · exact fun a _ => ⟨hxi.pow a, fun φ => by simp only [hx φ, norm_pow, one_pow, map_pow]⟩
#align number_field.embeddings.pow_eq_one_of_norm_eq_one NumberField.Embeddings.pow_eq_one_of_norm_eq_one
-/

end Bounded

end NumberField.Embeddings

section Place

variable {K : Type _} [Field K] {A : Type _} [NormedDivisionRing A] [Nontrivial A] (φ : K →+* A)

#print NumberField.place /-
/-- An embedding into a normed division ring defines a place of `K` -/
def NumberField.place : AbsoluteValue K ℝ :=
  (IsAbsoluteValue.toAbsoluteValue (norm : A → ℝ)).comp φ.Injective
#align number_field.place NumberField.place
-/

#print NumberField.place_apply /-
@[simp]
theorem NumberField.place_apply (x : K) : (NumberField.place φ) x = norm (φ x) :=
  rfl
#align number_field.place_apply NumberField.place_apply
-/

end Place

namespace NumberField.ComplexEmbedding

open Complex NumberField

open scoped ComplexConjugate

variable {K : Type _} [Field K]

#print NumberField.ComplexEmbedding.conjugate /-
/-- The conjugate of a complex embedding as a complex embedding. -/
@[reducible]
def conjugate (φ : K →+* ℂ) : K →+* ℂ :=
  star φ
#align number_field.complex_embedding.conjugate NumberField.ComplexEmbedding.conjugate
-/

#print NumberField.ComplexEmbedding.conjugate_coe_eq /-
@[simp]
theorem conjugate_coe_eq (φ : K →+* ℂ) (x : K) : (conjugate φ) x = conj (φ x) :=
  rfl
#align number_field.complex_embedding.conjugate_coe_eq NumberField.ComplexEmbedding.conjugate_coe_eq
-/

#print NumberField.ComplexEmbedding.place_conjugate /-
theorem place_conjugate (φ : K →+* ℂ) : place (conjugate φ) = place φ := by ext;
  simp only [place_apply, norm_eq_abs, abs_conj, conjugate_coe_eq]
#align number_field.complex_embedding.place_conjugate NumberField.ComplexEmbedding.place_conjugate
-/

#print NumberField.ComplexEmbedding.IsReal /-
/-- A embedding into `ℂ` is real if it is fixed by complex conjugation. -/
@[reducible]
def IsReal (φ : K →+* ℂ) : Prop :=
  IsSelfAdjoint φ
#align number_field.complex_embedding.is_real NumberField.ComplexEmbedding.IsReal
-/

#print NumberField.ComplexEmbedding.isReal_iff /-
theorem isReal_iff {φ : K →+* ℂ} : IsReal φ ↔ conjugate φ = φ :=
  isSelfAdjoint_iff
#align number_field.complex_embedding.is_real_iff NumberField.ComplexEmbedding.isReal_iff
-/

#print NumberField.ComplexEmbedding.IsReal.embedding /-
/-- A real embedding as a ring homomorphism from `K` to `ℝ` . -/
def IsReal.embedding {φ : K →+* ℂ} (hφ : IsReal φ) : K →+* ℝ
    where
  toFun x := (φ x).re
  map_one' := by simp only [map_one, one_re]
  map_mul' := by
    simp only [complex.conj_eq_iff_im.mp (RingHom.congr_fun hφ _), map_mul, mul_re,
      MulZeroClass.mul_zero, tsub_zero, eq_self_iff_true, forall_const]
  map_zero' := by simp only [map_zero, zero_re]
  map_add' := by simp only [map_add, add_re, eq_self_iff_true, forall_const]
#align number_field.complex_embedding.is_real.embedding NumberField.ComplexEmbedding.IsReal.embedding
-/

#print NumberField.ComplexEmbedding.IsReal.coe_embedding_apply /-
@[simp]
theorem IsReal.coe_embedding_apply {φ : K →+* ℂ} (hφ : IsReal φ) (x : K) :
    (hφ.Embedding x : ℂ) = φ x := by
  ext; · rfl
  · rw [of_real_im, eq_comm, ← Complex.conj_eq_iff_im]
    rw [is_real] at hφ 
    exact RingHom.congr_fun hφ x
#align number_field.complex_embedding.is_real.coe_embedding_apply NumberField.ComplexEmbedding.IsReal.coe_embedding_apply
-/

#print NumberField.ComplexEmbedding.IsReal.place_embedding /-
theorem IsReal.place_embedding {φ : K →+* ℂ} (hφ : IsReal φ) : place hφ.Embedding = place φ := by
  ext x;
  simp only [place_apply, Real.norm_eq_abs, ← abs_of_real, norm_eq_abs, hφ.coe_embedding_apply x]
#align number_field.complex_embedding.is_real.place_embedding NumberField.ComplexEmbedding.IsReal.place_embedding
-/

#print NumberField.ComplexEmbedding.isReal_conjugate_iff /-
theorem isReal_conjugate_iff {φ : K →+* ℂ} : IsReal (conjugate φ) ↔ IsReal φ :=
  IsSelfAdjoint.star_iff
#align number_field.complex_embedding.is_real_conjugate_iff NumberField.ComplexEmbedding.isReal_conjugate_iff
-/

end NumberField.ComplexEmbedding

section InfinitePlace

open NumberField

variable (K : Type _) [Field K]

#print NumberField.InfinitePlace /-
/-- An infinite place of a number field `K` is a place associated to a complex embedding. -/
def NumberField.InfinitePlace :=
  { w : AbsoluteValue K ℝ // ∃ φ : K →+* ℂ, place φ = w }
#align number_field.infinite_place NumberField.InfinitePlace
-/

instance [NumberField K] : Nonempty (NumberField.InfinitePlace K) :=
  Set.range.nonempty _

variable {K}

#print NumberField.InfinitePlace.mk /-
/-- Return the infinite place defined by a complex embedding `φ`. -/
noncomputable def NumberField.InfinitePlace.mk (φ : K →+* ℂ) : NumberField.InfinitePlace K :=
  ⟨place φ, ⟨φ, rfl⟩⟩
#align number_field.infinite_place.mk NumberField.InfinitePlace.mk
-/

namespace NumberField.InfinitePlace

open NumberField

instance : CoeFun (InfinitePlace K) fun _ => K → ℝ where coe w := w.1

instance : MonoidWithZeroHomClass (InfinitePlace K) K ℝ
    where
  coe w x := w.1 x
  coe_injective' _ _ h := Subtype.eq (AbsoluteValue.ext fun x => congr_fun h x)
  map_mul w _ _ := w.1.map_mul _ _
  map_one w := w.1.map_one
  map_zero w := w.1.map_zero

instance : NonnegHomClass (InfinitePlace K) K ℝ
    where
  coe w x := w x
  coe_injective' _ _ h := Subtype.eq (AbsoluteValue.ext fun x => congr_fun h x)
  map_nonneg w x := w.1.NonNeg _

#print NumberField.InfinitePlace.coe_mk /-
theorem coe_mk (φ : K →+* ℂ) : ⇑(mk φ) = place φ :=
  rfl
#align number_field.infinite_place.coe_mk NumberField.InfinitePlace.coe_mk
-/

#print NumberField.InfinitePlace.apply /-
theorem apply (φ : K →+* ℂ) (x : K) : (mk φ) x = Complex.abs (φ x) :=
  rfl
#align number_field.infinite_place.apply NumberField.InfinitePlace.apply
-/

#print NumberField.InfinitePlace.embedding /-
/-- For an infinite place `w`, return an embedding `φ` such that `w = infinite_place φ` . -/
noncomputable def embedding (w : InfinitePlace K) : K →+* ℂ :=
  w.2.some
#align number_field.infinite_place.embedding NumberField.InfinitePlace.embedding
-/

#print NumberField.InfinitePlace.mk_embedding /-
@[simp]
theorem mk_embedding (w : InfinitePlace K) : mk (embedding w) = w :=
  Subtype.ext w.2.choose_spec
#align number_field.infinite_place.mk_embedding NumberField.InfinitePlace.mk_embedding
-/

#print NumberField.InfinitePlace.abs_embedding /-
@[simp]
theorem abs_embedding (w : InfinitePlace K) (x : K) : Complex.abs (embedding w x) = w x :=
  congr_fun (congr_arg coeFn w.2.choose_spec) x
#align number_field.infinite_place.abs_embedding NumberField.InfinitePlace.abs_embedding
-/

#print NumberField.InfinitePlace.eq_iff_eq /-
theorem eq_iff_eq (x : K) (r : ℝ) : (∀ w : InfinitePlace K, w x = r) ↔ ∀ φ : K →+* ℂ, ‖φ x‖ = r :=
  ⟨fun hw φ => hw (mk φ), fun hφ ⟨w, ⟨φ, rfl⟩⟩ => hφ φ⟩
#align number_field.infinite_place.eq_iff_eq NumberField.InfinitePlace.eq_iff_eq
-/

#print NumberField.InfinitePlace.le_iff_le /-
theorem le_iff_le (x : K) (r : ℝ) : (∀ w : InfinitePlace K, w x ≤ r) ↔ ∀ φ : K →+* ℂ, ‖φ x‖ ≤ r :=
  ⟨fun hw φ => hw (mk φ), fun hφ ⟨w, ⟨φ, rfl⟩⟩ => hφ φ⟩
#align number_field.infinite_place.le_iff_le NumberField.InfinitePlace.le_iff_le
-/

#print NumberField.InfinitePlace.pos_iff /-
theorem pos_iff {w : InfinitePlace K} {x : K} : 0 < w x ↔ x ≠ 0 :=
  AbsoluteValue.pos_iff w.1
#align number_field.infinite_place.pos_iff NumberField.InfinitePlace.pos_iff
-/

#print NumberField.InfinitePlace.mk_conjugate_eq /-
@[simp]
theorem mk_conjugate_eq (φ : K →+* ℂ) : mk (ComplexEmbedding.conjugate φ) = mk φ :=
  by
  ext x
  exact congr_fun (congr_arg coeFn (complex_embedding.place_conjugate φ)) x
#align number_field.infinite_place.mk_conjugate_eq NumberField.InfinitePlace.mk_conjugate_eq
-/

#print NumberField.InfinitePlace.mk_eq_iff /-
@[simp]
theorem mk_eq_iff {φ ψ : K →+* ℂ} : mk φ = mk ψ ↔ φ = ψ ∨ ComplexEmbedding.conjugate φ = ψ :=
  by
  constructor
  · -- We prove that the map ψ ∘ φ⁻¹ between φ(K) and ℂ is uniform continuous, thus it is either the
    -- inclusion or the complex conjugation using complex.uniform_continuous_ring_hom_eq_id_or_conj
    intro h₀
    obtain ⟨j, hiφ⟩ := φ.injective.has_left_inverse
    let ι := RingEquiv.ofLeftInverse hiφ
    have hlip : LipschitzWith 1 (RingHom.comp ψ ι.symm.to_ring_hom) :=
      by
      change LipschitzWith 1 (ψ ∘ ι.symm)
      apply LipschitzWith.of_dist_le_mul
      intro x y
      rw [Nonneg.coe_one, one_mul, NormedField.dist_eq, ← map_sub, ← map_sub]
      apply le_of_eq
      suffices ‖φ (ι.symm (x - y))‖ = ‖ψ (ι.symm (x - y))‖
        by
        rw [← this, ← RingEquiv.ofLeftInverse_apply hiφ _, RingEquiv.apply_symm_apply ι _]
        rfl
      exact congr_fun (congr_arg coeFn h₀) _
    cases Complex.uniformContinuous_ringHom_eq_id_or_conj φ.field_range hlip.uniform_continuous
    · left; ext1 x
      convert (congr_fun h (ι x)).symm
      exact (RingEquiv.apply_symm_apply ι.symm x).symm
    · right; ext1 x
      convert (congr_fun h (ι x)).symm
      exact (RingEquiv.apply_symm_apply ι.symm x).symm
  · rintro (⟨h⟩ | ⟨h⟩)
    · exact congr_arg mk h
    · rw [← mk_conjugate_eq]
      exact congr_arg mk h
#align number_field.infinite_place.mk_eq_iff NumberField.InfinitePlace.mk_eq_iff
-/

#print NumberField.InfinitePlace.IsReal /-
/-- An infinite place is real if it is defined by a real embedding. -/
def IsReal (w : InfinitePlace K) : Prop :=
  ∃ φ : K →+* ℂ, ComplexEmbedding.IsReal φ ∧ mk φ = w
#align number_field.infinite_place.is_real NumberField.InfinitePlace.IsReal
-/

#print NumberField.InfinitePlace.IsComplex /-
/-- An infinite place is complex if it is defined by a complex (ie. not real) embedding. -/
def IsComplex (w : InfinitePlace K) : Prop :=
  ∃ φ : K →+* ℂ, ¬ComplexEmbedding.IsReal φ ∧ mk φ = w
#align number_field.infinite_place.is_complex NumberField.InfinitePlace.IsComplex
-/

#print NumberField.ComplexEmbeddings.IsReal.embedding_mk /-
@[simp]
theorem NumberField.ComplexEmbeddings.IsReal.embedding_mk {φ : K →+* ℂ}
    (h : ComplexEmbedding.IsReal φ) : embedding (mk φ) = φ :=
  by
  have := mk_eq_iff.mp (mk_embedding (mk φ)).symm
  rwa [complex_embedding.is_real_iff.mp h, or_self_iff, eq_comm] at this 
#align number_field.complex_embeddings.is_real.embedding_mk NumberField.ComplexEmbeddings.IsReal.embedding_mk
-/

#print NumberField.InfinitePlace.isReal_iff /-
theorem isReal_iff {w : InfinitePlace K} : IsReal w ↔ ComplexEmbedding.IsReal (embedding w) :=
  by
  constructor
  · rintro ⟨φ, ⟨hφ, rfl⟩⟩
    rwa [_root_.number_field.complex_embeddings.is_real.embedding_mk hφ]
  · exact fun h => ⟨Embedding w, h, mk_embedding w⟩
#align number_field.infinite_place.is_real_iff NumberField.InfinitePlace.isReal_iff
-/

#print NumberField.InfinitePlace.isComplex_iff /-
theorem isComplex_iff {w : InfinitePlace K} :
    IsComplex w ↔ ¬ComplexEmbedding.IsReal (embedding w) :=
  by
  constructor
  · rintro ⟨φ, ⟨hφ, rfl⟩⟩
    contrapose! hφ
    cases mk_eq_iff.mp (mk_embedding (mk φ))
    · rwa [← h]
    · rw [← complex_embedding.is_real_conjugate_iff] at hφ 
      rwa [← h]
  · exact fun h => ⟨Embedding w, h, mk_embedding w⟩
#align number_field.infinite_place.is_complex_iff NumberField.InfinitePlace.isComplex_iff
-/

#print NumberField.InfinitePlace.not_isReal_iff_isComplex /-
@[simp]
theorem not_isReal_iff_isComplex {w : InfinitePlace K} : ¬IsReal w ↔ IsComplex w := by
  rw [is_complex_iff, is_real_iff]
#align number_field.infinite_place.not_is_real_iff_is_complex NumberField.InfinitePlace.not_isReal_iff_isComplex
-/

#print NumberField.InfinitePlace.not_isComplex_iff_isReal /-
@[simp]
theorem not_isComplex_iff_isReal {w : InfinitePlace K} : ¬IsComplex w ↔ IsReal w := by
  rw [← not_is_real_iff_is_complex, Classical.not_not]
#align number_field.infinite_place.not_is_complex_iff_is_real NumberField.InfinitePlace.not_isComplex_iff_isReal
-/

#print NumberField.InfinitePlace.isReal_or_isComplex /-
theorem isReal_or_isComplex (w : InfinitePlace K) : IsReal w ∨ IsComplex w := by
  rw [← not_is_real_iff_is_complex]; exact em _
#align number_field.infinite_place.is_real_or_is_complex NumberField.InfinitePlace.isReal_or_isComplex
-/

#print NumberField.InfinitePlace.IsReal.embedding /-
/-- For `w` a real infinite place, return the corresponding embedding as a morphism `K →+* ℝ`. -/
noncomputable def IsReal.embedding {w : InfinitePlace K} (hw : IsReal w) : K →+* ℝ :=
  (isReal_iff.mp hw).Embedding
#align number_field.infinite_place.is_real.embedding NumberField.InfinitePlace.IsReal.embedding
-/

#print NumberField.InfinitePlace.IsReal.place_embedding_apply /-
@[simp]
theorem IsReal.place_embedding_apply {w : InfinitePlace K} (hw : IsReal w) (x : K) :
    place (IsReal.embedding hw) x = w x :=
  by
  rw [is_real.embedding, complex_embedding.is_real.place_embedding, ← coe_mk]
  exact congr_fun (congr_arg coeFn (mk_embedding w)) x
#align number_field.infinite_place.is_real.place_embedding_apply NumberField.InfinitePlace.IsReal.place_embedding_apply
-/

#print NumberField.InfinitePlace.IsReal.abs_embedding_apply /-
@[simp]
theorem IsReal.abs_embedding_apply {w : InfinitePlace K} (hw : IsReal w) (x : K) :
    |IsReal.embedding hw x| = w x := by rw [← is_real.place_embedding_apply hw x]; congr
#align number_field.infinite_place.is_real.abs_embedding_apply NumberField.InfinitePlace.IsReal.abs_embedding_apply
-/

variable (K)

#print NumberField.InfinitePlace.mkReal /-
/-- The map from real embeddings to real infinite places as an equiv -/
noncomputable def mkReal :
    { φ : K →+* ℂ // ComplexEmbedding.IsReal φ } ≃ { w : InfinitePlace K // IsReal w }
    where
  toFun := Subtype.map mk fun φ hφ => ⟨φ, hφ, rfl⟩
  invFun w := ⟨w.1.Embedding, isReal_iff.1 w.2⟩
  left_inv φ := Subtype.ext_iff.2 (NumberField.ComplexEmbeddings.IsReal.embedding_mk φ.2)
  right_inv w := Subtype.ext_iff.2 (mk_embedding w.1)
#align number_field.infinite_place.mk_real NumberField.InfinitePlace.mkReal
-/

#print NumberField.InfinitePlace.mkComplex /-
/-- The map from nonreal embeddings to complex infinite places -/
noncomputable def mkComplex :
    { φ : K →+* ℂ // ¬ComplexEmbedding.IsReal φ } → { w : InfinitePlace K // IsComplex w } :=
  Subtype.map mk fun φ hφ => ⟨φ, hφ, rfl⟩
#align number_field.infinite_place.mk_complex NumberField.InfinitePlace.mkComplex
-/

#print NumberField.InfinitePlace.mkComplex_embedding /-
theorem mkComplex_embedding (φ : { φ : K →+* ℂ // ¬ComplexEmbedding.IsReal φ }) :
    (mkComplex K φ : InfinitePlace K).Embedding = φ ∨
      (mkComplex K φ : InfinitePlace K).Embedding = ComplexEmbedding.conjugate φ :=
  by
  rw [@eq_comm _ _ ↑φ, @eq_comm _ _ (complex_embedding.conjugate ↑φ), ← mk_eq_iff, mk_embedding]
  rfl
#align number_field.infinite_place.mk_complex_embedding NumberField.InfinitePlace.mkComplex_embedding
-/

#print NumberField.InfinitePlace.mkReal_coe /-
@[simp]
theorem mkReal_coe (φ : { φ : K →+* ℂ // ComplexEmbedding.IsReal φ }) :
    (mkReal K φ : InfinitePlace K) = mk (φ : K →+* ℂ) :=
  rfl
#align number_field.infinite_place.mk_real_coe NumberField.InfinitePlace.mkReal_coe
-/

#print NumberField.InfinitePlace.mkComplex_coe /-
@[simp]
theorem mkComplex_coe (φ : { φ : K →+* ℂ // ¬ComplexEmbedding.IsReal φ }) :
    (mkComplex K φ : InfinitePlace K) = mk (φ : K →+* ℂ) :=
  rfl
#align number_field.infinite_place.mk_complex_coe NumberField.InfinitePlace.mkComplex_coe
-/

#print NumberField.InfinitePlace.mkReal.apply /-
@[simp]
theorem mkReal.apply (φ : { φ : K →+* ℂ // ComplexEmbedding.IsReal φ }) (x : K) :
    mkReal K φ x = Complex.abs (φ x) :=
  apply φ x
#align number_field.infinite_place.mk_real.apply NumberField.InfinitePlace.mkReal.apply
-/

#print NumberField.InfinitePlace.mkComplex.apply /-
@[simp]
theorem mkComplex.apply (φ : { φ : K →+* ℂ // ¬ComplexEmbedding.IsReal φ }) (x : K) :
    mkComplex K φ x = Complex.abs (φ x) :=
  apply φ x
#align number_field.infinite_place.mk_complex.apply NumberField.InfinitePlace.mkComplex.apply
-/

variable [NumberField K]

#print NumberField.InfinitePlace.mkComplex.filter /-
theorem mkComplex.filter (w : { w : InfinitePlace K // w.IsComplex }) :
    (Finset.univ.filterₓ fun φ => mkComplex K φ = w) =
      {⟨w.1.Embedding, isComplex_iff.1 w.2⟩,
        ⟨ComplexEmbedding.conjugate w.1.Embedding,
          ComplexEmbedding.isReal_conjugate_iff.Not.2 (isComplex_iff.1 w.2)⟩} :=
  by
  ext φ
  simp_rw [Finset.mem_filter, Subtype.val_eq_coe, Finset.mem_insert, Finset.mem_singleton,
    @Subtype.ext_iff_val (infinite_place K), @Subtype.ext_iff_val (K →+* ℂ), @eq_comm _ φ.val, ←
    mk_eq_iff, mk_embedding, @eq_comm _ _ w.val]
  simpa only [Finset.mem_univ, true_and_iff]
#align number_field.infinite_place.mk_complex.filter NumberField.InfinitePlace.mkComplex.filter
-/

#print NumberField.InfinitePlace.mkComplex.filter_card /-
theorem mkComplex.filter_card (w : { w : InfinitePlace K // w.IsComplex }) :
    (Finset.univ.filterₓ fun φ => mkComplex K φ = w).card = 2 :=
  by
  rw [mk_complex.filter]
  exact
    Finset.card_doubleton
      (subtype.mk_eq_mk.not.2 <|
        ne_comm.1 <| complex_embedding.is_real_iff.not.1 <| is_complex_iff.1 w.2)
#align number_field.infinite_place.mk_complex.filter_card NumberField.InfinitePlace.mkComplex.filter_card
-/

#print NumberField.InfinitePlace.NumberField.InfinitePlace.fintype /-
noncomputable instance NumberField.InfinitePlace.fintype : Fintype (InfinitePlace K) :=
  Set.fintypeRange _
#align number_field.infinite_place.number_field.infinite_place.fintype NumberField.InfinitePlace.NumberField.InfinitePlace.fintype
-/

#print NumberField.InfinitePlace.prod_eq_abs_norm /-
/-- The infinite part of the product formula : for `x ∈ K`, we have `Π_w ‖x‖_w = |norm(x)|` where
`‖·‖_w` is the normalized absolute value for `w`.  -/
theorem prod_eq_abs_norm (x : K) :
    (Finset.univ.Prod fun w : InfinitePlace K => ite w.IsReal (w x) (w x ^ 2)) =
      abs (Algebra.norm ℚ x) :=
  by
  convert (congr_arg Complex.abs (@Algebra.norm_eq_prod_embeddings ℚ _ _ _ _ ℂ _ _ _ _ _ x)).symm
  · rw [map_prod, ←
      Equiv.prod_comp' RingHom.equivRatAlgHom (fun f => Complex.abs (f x))
        (fun φ => Complex.abs (φ x)) fun _ => by simpa only [RingHom.equivRatAlgHom_apply]]
    dsimp only
    conv =>
      rhs
      congr
      skip
      ext
      rw [(by simp only [if_t_t] :
          Complex.abs (f x) =
            ite (complex_embedding.is_real f) (Complex.abs (f x)) (Complex.abs (f x)))]
    rw [Finset.prod_ite, Finset.prod_ite]
    refine' congr (congr_arg Mul.mul _) _
    · rw [← Finset.prod_subtype_eq_prod_filter, ← Finset.prod_subtype_eq_prod_filter]
      convert (Equiv.prod_comp' (mk_real K) (fun φ => Complex.abs (φ x)) (fun w => w x) _).symm
      any_goals ext; simp only [Finset.mem_subtype, Finset.mem_univ]
      exact fun φ => mk_real.apply K φ x
    · rw [Finset.filter_congr fun (w : infinite_place K) _ => @not_is_real_iff_is_complex K _ w, ←
        Finset.prod_subtype_eq_prod_filter, ← Finset.prod_subtype_eq_prod_filter]
      convert Finset.prod_fiberwise Finset.univ (fun φ => mk_complex K φ) fun φ => Complex.abs (φ x)
      any_goals ext; simp only [Finset.mem_subtype, Finset.mem_univ, not_is_real_iff_is_complex]
      · ext w
        rw [@Finset.prod_congr _ _ _ _ _ (fun φ => w x) _ (Eq.refl _) fun φ hφ =>
            (mk_complex.apply K φ x).symm.trans
              (congr_fun (congr_arg coeFn (Finset.mem_filter.1 hφ).2) x),
          Finset.prod_const, mk_complex.filter_card K w]
        rfl
  · rw [eq_ratCast, ← Complex.abs_ofReal, Complex.ofReal_rat_cast]
#align number_field.infinite_place.prod_eq_abs_norm NumberField.InfinitePlace.prod_eq_abs_norm
-/

open Fintype

#print NumberField.InfinitePlace.card_real_embeddings /-
theorem card_real_embeddings :
    card { φ : K →+* ℂ // ComplexEmbedding.IsReal φ } = card { w : InfinitePlace K // IsReal w } :=
  by convert (Fintype.ofEquiv_card (mk_real K)).symm
#align number_field.infinite_place.card_real_embeddings NumberField.InfinitePlace.card_real_embeddings
-/

#print NumberField.InfinitePlace.card_complex_embeddings /-
theorem card_complex_embeddings :
    card { φ : K →+* ℂ // ¬ComplexEmbedding.IsReal φ } =
      2 * card { w : InfinitePlace K // IsComplex w } :=
  by
  rw [Fintype.card, Fintype.card, mul_comm, ← Algebra.id.smul_eq_mul, ← Finset.sum_const]
  conv =>
    rhs
    congr
    skip
    ext
    rw [← mk_complex.filter_card K x]
  simp_rw [Finset.card_eq_sum_ones]
  exact (Finset.sum_fiberwise Finset.univ (fun φ => mk_complex K φ) fun φ => 1).symm
#align number_field.infinite_place.card_complex_embeddings NumberField.InfinitePlace.card_complex_embeddings
-/

end NumberField.InfinitePlace

end InfinitePlace

