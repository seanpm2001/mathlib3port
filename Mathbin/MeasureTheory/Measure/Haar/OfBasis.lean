/-
Copyright (c) 2022 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module measure_theory.measure.haar.of_basis
! leanprover-community/mathlib commit 2ebc1d6c2fed9f54c95bbc3998eaa5570527129a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.MeasureTheory.Measure.Haar.Basic
import Mathbin.Analysis.InnerProductSpace.PiL2

/-!
# Additive Haar measure constructed from a basis

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Given a basis of a finite-dimensional real vector space, we define the corresponding Lebesgue
measure, which gives measure `1` to the parallelepiped spanned by the basis.

## Main definitions

* `parallelepiped v` is the parallelepiped spanned by a finite family of vectors.
* `basis.parallelepiped` is the parallelepiped associated to a basis, seen as a compact set with
nonempty interior.
* `basis.add_haar` is the Lebesgue measure associated to a basis, giving measure `1` to the
corresponding parallelepiped.

In particular, we declare a `measure_space` instance on any finite-dimensional inner product space,
by using the Lebesgue measure associated to some orthonormal basis (which is in fact independent
of the basis).
-/


open Set TopologicalSpace MeasureTheory MeasureTheory.Measure FiniteDimensional

open scoped BigOperators Pointwise

noncomputable section

variable {ι ι' E F : Type _} [Fintype ι] [Fintype ι']

section AddCommGroup

variable [AddCommGroup E] [Module ℝ E] [AddCommGroup F] [Module ℝ F]

#print parallelepiped /-
/-- The closed parallelepiped spanned by a finite family of vectors. -/
def parallelepiped (v : ι → E) : Set E :=
  (fun t : ι → ℝ => ∑ i, t i • v i) '' Icc 0 1
#align parallelepiped parallelepiped
-/

#print mem_parallelepiped_iff /-
theorem mem_parallelepiped_iff (v : ι → E) (x : E) :
    x ∈ parallelepiped v ↔ ∃ (t : ι → ℝ) (ht : t ∈ Icc (0 : ι → ℝ) 1), x = ∑ i, t i • v i := by
  simp [parallelepiped, eq_comm]
#align mem_parallelepiped_iff mem_parallelepiped_iff
-/

#print image_parallelepiped /-
theorem image_parallelepiped (f : E →ₗ[ℝ] F) (v : ι → E) :
    f '' parallelepiped v = parallelepiped (f ∘ v) :=
  by
  simp only [parallelepiped, ← image_comp]
  congr 1 with t
  simp only [Function.comp_apply, LinearMap.map_sum, LinearMap.map_smulₛₗ, RingHom.id_apply]
#align image_parallelepiped image_parallelepiped
-/

#print parallelepiped_comp_equiv /-
/-- Reindexing a family of vectors does not change their parallelepiped. -/
@[simp]
theorem parallelepiped_comp_equiv (v : ι → E) (e : ι' ≃ ι) :
    parallelepiped (v ∘ e) = parallelepiped v :=
  by
  simp only [parallelepiped]
  let K : (ι' → ℝ) ≃ (ι → ℝ) := Equiv.piCongrLeft' (fun a : ι' => ℝ) e
  have : Icc (0 : ι → ℝ) 1 = K '' Icc (0 : ι' → ℝ) 1 :=
    by
    rw [← Equiv.preimage_eq_iff_eq_image]
    ext x
    simp only [mem_preimage, mem_Icc, Pi.le_def, Pi.zero_apply, Equiv.piCongrLeft'_apply,
      Pi.one_apply]
    refine'
      ⟨fun h => ⟨fun i => _, fun i => _⟩, fun h =>
        ⟨fun i => h.1 (e.symm i), fun i => h.2 (e.symm i)⟩⟩
    · simpa only [Equiv.symm_apply_apply] using h.1 (e i)
    · simpa only [Equiv.symm_apply_apply] using h.2 (e i)
  rw [this, ← image_comp]
  congr 1 with x
  simpa only [OrthonormalBasis.coe_reindex, Function.comp_apply, Equiv.symm_apply_apply,
    Equiv.piCongrLeft'_apply, Equiv.apply_symm_apply] using
    (e.symm.sum_comp fun i : ι' => x i • v (e i)).symm
#align parallelepiped_comp_equiv parallelepiped_comp_equiv
-/

#print parallelepiped_orthonormalBasis_one_dim /-
-- The parallelepiped associated to an orthonormal basis of `ℝ` is either `[0, 1]` or `[-1, 0]`.
theorem parallelepiped_orthonormalBasis_one_dim (b : OrthonormalBasis ι ℝ ℝ) :
    parallelepiped b = Icc 0 1 ∨ parallelepiped b = Icc (-1) 0 :=
  by
  have e : ι ≃ Fin 1 := by
    apply Fintype.equivFinOfCardEq
    simp only [← finrank_eq_card_basis b.to_basis, finrank_self]
  have B : parallelepiped (b.reindex e) = parallelepiped b :=
    by
    convert parallelepiped_comp_equiv b e.symm
    ext i
    simp only [OrthonormalBasis.coe_reindex]
  rw [← B]
  let F : ℝ → Fin 1 → ℝ := fun t => fun i => t
  have A : Icc (0 : Fin 1 → ℝ) 1 = F '' Icc (0 : ℝ) 1 :=
    by
    apply subset.antisymm
    · intro x hx
      refine' ⟨x 0, ⟨hx.1 0, hx.2 0⟩, _⟩
      ext j
      simp only [Subsingleton.elim j 0]
    · rintro x ⟨y, hy, rfl⟩
      exact ⟨fun j => hy.1, fun j => hy.2⟩
  rcases orthonormalBasis_one_dim (b.reindex e) with (H | H)
  · left
    simp only [H, parallelepiped, Algebra.id.smul_eq_mul, mul_one, A, Finset.sum_singleton, ←
      image_comp, image_id', Finset.univ_unique]
  · right
    simp only [H, parallelepiped, Algebra.id.smul_eq_mul, mul_one]
    rw [A]
    simp only [← image_comp, mul_neg, mul_one, Finset.sum_singleton, image_neg, preimage_neg_Icc,
      neg_zero, Finset.univ_unique]
#align parallelepiped_orthonormal_basis_one_dim parallelepiped_orthonormalBasis_one_dim
-/

#print parallelepiped_eq_sum_segment /-
theorem parallelepiped_eq_sum_segment (v : ι → E) : parallelepiped v = ∑ i, segment ℝ 0 (v i) :=
  by
  ext
  simp only [mem_parallelepiped_iff, Set.mem_finset_sum, Finset.mem_univ, forall_true_left,
    segment_eq_image, smul_zero, zero_add, ← Set.pi_univ_Icc, Set.mem_univ_pi]
  constructor
  · rintro ⟨t, ht, rfl⟩
    exact ⟨t • v, fun i => ⟨t i, ht _, by simp⟩, rfl⟩
  rintro ⟨g, hg, rfl⟩
  change ∀ i, _ at hg 
  choose t ht hg using hg
  refine' ⟨t, ht, _⟩
  simp_rw [hg]
#align parallelepiped_eq_sum_segment parallelepiped_eq_sum_segment
-/

#print convex_parallelepiped /-
theorem convex_parallelepiped (v : ι → E) : Convex ℝ (parallelepiped v) :=
  by
  rw [parallelepiped_eq_sum_segment]
  -- TODO: add `convex.sum` to match `convex.add`
  let this.1 : AddSubmonoid (Set E) :=
    { carrier := {s | Convex ℝ s}
      zero_mem' := convex_singleton _
      add_mem' := fun x y => Convex.add }
  exact this.sum_mem fun i hi => convex_segment _ _
#align convex_parallelepiped convex_parallelepiped
-/

#print parallelepiped_eq_convexHull /-
/-- A `parallelepiped` is the convex hull of its vertices -/
theorem parallelepiped_eq_convexHull (v : ι → E) :
    parallelepiped v = convexHull ℝ (∑ i, {(0 : E), v i}) :=
  by
  -- TODO: add `convex_hull_sum` to match `convex_hull_add`
  let this.1 : Set E →+ Set E :=
    { toFun := convexHull ℝ
      map_zero' := convexHull_singleton _
      map_add' := convexHull_add }
  simp_rw [parallelepiped_eq_sum_segment, ← convexHull_pair]
  exact (this.map_sum _ _).symm
#align parallelepiped_eq_convex_hull parallelepiped_eq_convexHull
-/

#print parallelepiped_single /-
/-- The axis aligned parallelepiped over `ι → ℝ` is a cuboid. -/
theorem parallelepiped_single [DecidableEq ι] (a : ι → ℝ) :
    (parallelepiped fun i => Pi.single i (a i)) = Set.uIcc 0 a :=
  by
  ext
  simp_rw [Set.uIcc, mem_parallelepiped_iff, Set.mem_Icc, Pi.le_def, ← forall_and, Pi.inf_apply,
    Pi.sup_apply, ← Pi.single_smul', Pi.one_apply, Pi.zero_apply, ← Pi.smul_apply',
    Finset.univ_sum_single (_ : ι → ℝ)]
  constructor
  · rintro ⟨t, ht, rfl⟩ i
    specialize ht i
    simp_rw [smul_eq_mul, Pi.mul_apply]
    cases' le_total (a i) 0 with hai hai
    · rw [sup_eq_left.mpr hai, inf_eq_right.mpr hai]
      exact ⟨le_mul_of_le_one_left hai ht.2, mul_nonpos_of_nonneg_of_nonpos ht.1 hai⟩
    · rw [sup_eq_right.mpr hai, inf_eq_left.mpr hai]
      exact ⟨mul_nonneg ht.1 hai, mul_le_of_le_one_left hai ht.2⟩
  · intro h
    refine' ⟨fun i => x i / a i, fun i => _, funext fun i => _⟩
    · specialize h i
      cases' le_total (a i) 0 with hai hai
      · rw [sup_eq_left.mpr hai, inf_eq_right.mpr hai] at h 
        exact ⟨div_nonneg_of_nonpos h.2 hai, div_le_one_of_ge h.1 hai⟩
      · rw [sup_eq_right.mpr hai, inf_eq_left.mpr hai] at h 
        exact ⟨div_nonneg h.1 hai, div_le_one_of_le h.2 hai⟩
    · specialize h i
      simp only [smul_eq_mul, Pi.mul_apply]
      cases' eq_or_ne (a i) 0 with hai hai
      · rw [hai, inf_idem, sup_idem, ← le_antisymm_iff] at h 
        rw [hai, ← h, zero_div, MulZeroClass.zero_mul]
      · rw [div_mul_cancel _ hai]
#align parallelepiped_single parallelepiped_single
-/

end AddCommGroup

section NormedSpace

variable [NormedAddCommGroup E] [NormedAddCommGroup F] [NormedSpace ℝ E] [NormedSpace ℝ F]

#print Basis.parallelepiped /-
/-- The parallelepiped spanned by a basis, as a compact set with nonempty interior. -/
def Basis.parallelepiped (b : Basis ι ℝ E) : PositiveCompacts E
    where
  carrier := parallelepiped b
  is_compact' :=
    isCompact_Icc.image
      (continuous_finset_sum Finset.univ fun (i : ι) (H : i ∈ Finset.univ) =>
        (continuous_apply i).smul continuous_const)
  interior_nonempty' :=
    by
    suffices H : Set.Nonempty (interior (b.equiv_funL.symm.to_homeomorph '' Icc 0 1))
    · dsimp only [parallelepiped]
      convert H
      ext t
      exact (b.equiv_fun_symm_apply t).symm
    have A : Set.Nonempty (interior (Icc (0 : ι → ℝ) 1)) :=
      by
      rw [← pi_univ_Icc, interior_pi_set (@finite_univ ι _)]
      simp only [univ_pi_nonempty_iff, Pi.zero_apply, Pi.one_apply, interior_Icc, nonempty_Ioo,
        zero_lt_one, imp_true_iff]
    rwa [← Homeomorph.image_interior, nonempty_image_iff]
#align basis.parallelepiped Basis.parallelepiped
-/

@[simp]
theorem Basis.coe_parallelepiped (b : Basis ι ℝ E) :
    (b.parallelepiped : Set E) = parallelepiped b :=
  rfl
#align basis.coe_parallelepiped Basis.coe_parallelepiped

#print Basis.parallelepiped_reindex /-
@[simp]
theorem Basis.parallelepiped_reindex (b : Basis ι ℝ E) (e : ι ≃ ι') :
    (b.reindex e).parallelepiped = b.parallelepiped :=
  PositiveCompacts.ext <|
    (congr_arg parallelepiped (b.coe_reindex _)).trans (parallelepiped_comp_equiv b e.symm)
#align basis.parallelepiped_reindex Basis.parallelepiped_reindex
-/

#print Basis.parallelepiped_map /-
theorem Basis.parallelepiped_map (b : Basis ι ℝ E) (e : E ≃ₗ[ℝ] F) :
    (b.map e).parallelepiped =
      b.parallelepiped.map e
        (haveI := FiniteDimensional.of_fintype_basis b
        e.to_linear_map.continuous_of_finite_dimensional)
        haveI := FiniteDimensional.of_fintype_basis (b.map e)
        e.to_linear_map.is_open_map_of_finite_dimensional e.surjective :=
  PositiveCompacts.ext (image_parallelepiped e.toLinearMap _).symm
#align basis.parallelepiped_map Basis.parallelepiped_map
-/

variable [MeasurableSpace E] [BorelSpace E]

#print Basis.addHaar /-
/-- The Lebesgue measure associated to a basis, giving measure `1` to the parallelepiped spanned
by the basis. -/
irreducible_def Basis.addHaar (b : Basis ι ℝ E) : Measure E :=
  Measure.addHaarMeasure b.parallelepiped
#align basis.add_haar Basis.addHaar
-/

#print IsAddHaarMeasure_basis_addHaar /-
instance IsAddHaarMeasure_basis_addHaar (b : Basis ι ℝ E) : IsAddHaarMeasure b.addHaar := by
  rw [Basis.addHaar]; exact measure.is_add_haar_measure_add_haar_measure _
#align is_add_haar_measure_basis_add_haar IsAddHaarMeasure_basis_addHaar
-/

#print Basis.addHaar_self /-
theorem Basis.addHaar_self (b : Basis ι ℝ E) : b.addHaar (parallelepiped b) = 1 := by
  rw [Basis.addHaar]; exact add_haar_measure_self
#align basis.add_haar_self Basis.addHaar_self
-/

end NormedSpace

#print measureSpaceOfInnerProductSpace /-
/-- A finite dimensional inner product space has a canonical measure, the Lebesgue measure giving
volume `1` to the parallelepiped spanned by any orthonormal basis. We define the measure using
some arbitrary choice of orthonormal basis. The fact that it works with any orthonormal basis
is proved in `orthonormal_basis.volume_parallelepiped`. -/
instance (priority := 100) measureSpaceOfInnerProductSpace [NormedAddCommGroup E]
    [InnerProductSpace ℝ E] [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] :
    MeasureSpace E where volume := (stdOrthonormalBasis ℝ E).toBasis.addHaar
#align measure_space_of_inner_product_space measureSpaceOfInnerProductSpace
-/

#print Real.measureSpace /-
/- This instance should not be necessary, but Lean has difficulties to find it in product
situations if we do not declare it explicitly. -/
instance Real.measureSpace : MeasureSpace ℝ := by infer_instance
#align real.measure_space Real.measureSpace
-/

/-! # Miscellaneous instances for `euclidean_space`

In combination with `measure_space_of_inner_product_space`, these put a `measure_space` structure
on `euclidean_space`. -/


namespace EuclideanSpace

variable (ι)

-- TODO: do we want these instances for `pi_Lp` too?
instance : MeasurableSpace (EuclideanSpace ℝ ι) :=
  MeasurableSpace.pi

instance : BorelSpace (EuclideanSpace ℝ ι) :=
  Pi.borelSpace

#print EuclideanSpace.measurableEquiv /-
/-- `pi_Lp.equiv` as a `measurable_equiv`. -/
@[simps toEquiv]
protected def measurableEquiv : EuclideanSpace ℝ ι ≃ᵐ (ι → ℝ)
    where
  toEquiv := PiLp.equiv _ _
  measurable_to_fun := measurable_id
  measurable_inv_fun := measurable_id
#align euclidean_space.measurable_equiv EuclideanSpace.measurableEquiv
-/

#print EuclideanSpace.coe_measurableEquiv /-
theorem coe_measurableEquiv : ⇑(EuclideanSpace.measurableEquiv ι) = PiLp.equiv 2 _ :=
  rfl
#align euclidean_space.coe_measurable_equiv EuclideanSpace.coe_measurableEquiv
-/

end EuclideanSpace

