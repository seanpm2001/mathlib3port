/-
Copyright (c) 2020 Joseph Myers. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Joseph Myers, Sébastien Gouëzel, Heather Macbeth

! This file was ported from Lean 3 source module analysis.inner_product_space.pi_L2
! leanprover-community/mathlib commit f60c6087a7275b72d5db3c5a1d0e19e35a429c0a
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.InnerProductSpace.Projection
import Mathbin.Analysis.NormedSpace.PiLp
import Mathbin.LinearAlgebra.FiniteDimensional
import Mathbin.LinearAlgebra.UnitaryGroup

/-!
# `L²` inner product space structure on finite products of inner product spaces

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The `L²` norm on a finite product of inner product spaces is compatible with an inner product
$$
\langle x, y\rangle = \sum \langle x_i, y_i \rangle.
$$
This is recorded in this file as an inner product space instance on `pi_Lp 2`.

This file develops the notion of a finite dimensional Hilbert space over `𝕜 = ℂ, ℝ`, referred to as
`E`. We define an `orthonormal_basis 𝕜 ι E` as a linear isometric equivalence
between `E` and `euclidean_space 𝕜 ι`. Then `std_orthonormal_basis` shows that such an equivalence
always exists if `E` is finite dimensional. We provide language for converting between a basis
that is orthonormal and an orthonormal basis (e.g. `basis.to_orthonormal_basis`). We show that
orthonormal bases for each summand in a direct sum of spaces can be combined into an orthonormal
basis for the the whole sum in `direct_sum.submodule_is_internal.subordinate_orthonormal_basis`. In
the last section, various properties of matrices are explored.

## Main definitions

- `euclidean_space 𝕜 n`: defined to be `pi_Lp 2 (n → 𝕜)` for any `fintype n`, i.e., the space
  from functions to `n` to `𝕜` with the `L²` norm. We register several instances on it (notably
  that it is a finite-dimensional inner product space).

- `orthonormal_basis 𝕜 ι`: defined to be an isometry to Euclidean space from a given
  finite-dimensional innner product space, `E ≃ₗᵢ[𝕜] euclidean_space 𝕜 ι`.

- `basis.to_orthonormal_basis`: constructs an `orthonormal_basis` for a finite-dimensional
  Euclidean space from a `basis` which is `orthonormal`.

- `orthonormal.exists_orthonormal_basis_extension`: provides an existential result of an
  `orthonormal_basis` extending a given orthonormal set

- `exists_orthonormal_basis`: provides an orthonormal basis on a finite dimensional vector space

- `std_orthonormal_basis`: provides an arbitrarily-chosen `orthonormal_basis` of a given finite
  dimensional inner product space

For consequences in infinite dimension (Hilbert bases, etc.), see the file
`analysis.inner_product_space.l2_space`.

-/


open Real Set Filter IsROrC Submodule Function

open scoped BigOperators uniformity Topology NNReal ENNReal ComplexConjugate DirectSum

noncomputable section

variable {ι : Type _} {ι' : Type _}

variable {𝕜 : Type _} [IsROrC 𝕜]

variable {E : Type _} [NormedAddCommGroup E] [InnerProductSpace 𝕜 E]

variable {E' : Type _} [NormedAddCommGroup E'] [InnerProductSpace 𝕜 E']

variable {F : Type _} [NormedAddCommGroup F] [InnerProductSpace ℝ F]

variable {F' : Type _} [NormedAddCommGroup F'] [InnerProductSpace ℝ F']

local notation "⟪" x ", " y "⟫" => @inner 𝕜 _ _ x y

#print PiLp.innerProductSpace /-
/-
 If `ι` is a finite type and each space `f i`, `i : ι`, is an inner product space,
then `Π i, f i` is an inner product space as well. Since `Π i, f i` is endowed with the sup norm,
we use instead `pi_Lp 2 f` for the product space, which is endowed with the `L^2` norm.
-/
instance PiLp.innerProductSpace {ι : Type _} [Fintype ι] (f : ι → Type _)
    [∀ i, NormedAddCommGroup (f i)] [∀ i, InnerProductSpace 𝕜 (f i)] :
    InnerProductSpace 𝕜 (PiLp 2 f)
    where
  inner x y := ∑ i, inner (x i) (y i)
  norm_sq_eq_inner x := by
    simp only [PiLp.norm_sq_eq_of_L2, AddMonoidHom.map_sum, ← norm_sq_eq_inner, one_div]
  conj_symm := by
    intro x y
    unfold inner
    rw [RingHom.map_sum]
    apply Finset.sum_congr rfl
    rintro z -
    apply inner_conj_symm
  add_left x y z :=
    show ∑ i, inner (x i + y i) (z i) = ∑ i, inner (x i) (z i) + ∑ i, inner (y i) (z i) by
      simp only [inner_add_left, Finset.sum_add_distrib]
  smul_left x y r :=
    show ∑ i : ι, inner (r • x i) (y i) = conj r * ∑ i, inner (x i) (y i) by
      simp only [Finset.mul_sum, inner_smul_left]
#align pi_Lp.inner_product_space PiLp.innerProductSpace
-/

#print PiLp.inner_apply /-
@[simp]
theorem PiLp.inner_apply {ι : Type _} [Fintype ι] {f : ι → Type _} [∀ i, NormedAddCommGroup (f i)]
    [∀ i, InnerProductSpace 𝕜 (f i)] (x y : PiLp 2 f) : ⟪x, y⟫ = ∑ i, ⟪x i, y i⟫ :=
  rfl
#align pi_Lp.inner_apply PiLp.inner_apply
-/

#print EuclideanSpace /-
/-- The standard real/complex Euclidean space, functions on a finite type. For an `n`-dimensional
space use `euclidean_space 𝕜 (fin n)`. -/
@[reducible, nolint unused_arguments]
def EuclideanSpace (𝕜 : Type _) [IsROrC 𝕜] (n : Type _) [Fintype n] : Type _ :=
  PiLp 2 fun i : n => 𝕜
#align euclidean_space EuclideanSpace
-/

#print EuclideanSpace.nnnorm_eq /-
theorem EuclideanSpace.nnnorm_eq {𝕜 : Type _} [IsROrC 𝕜] {n : Type _} [Fintype n]
    (x : EuclideanSpace 𝕜 n) : ‖x‖₊ = NNReal.sqrt (∑ i, ‖x i‖₊ ^ 2) :=
  PiLp.nnnorm_eq_of_L2 x
#align euclidean_space.nnnorm_eq EuclideanSpace.nnnorm_eq
-/

#print EuclideanSpace.norm_eq /-
theorem EuclideanSpace.norm_eq {𝕜 : Type _} [IsROrC 𝕜] {n : Type _} [Fintype n]
    (x : EuclideanSpace 𝕜 n) : ‖x‖ = Real.sqrt (∑ i, ‖x i‖ ^ 2) := by
  simpa only [Real.coe_sqrt, NNReal.coe_sum] using congr_arg (coe : ℝ≥0 → ℝ) x.nnnorm_eq
#align euclidean_space.norm_eq EuclideanSpace.norm_eq
-/

#print EuclideanSpace.dist_eq /-
theorem EuclideanSpace.dist_eq {𝕜 : Type _} [IsROrC 𝕜] {n : Type _} [Fintype n]
    (x y : EuclideanSpace 𝕜 n) : dist x y = (∑ i, dist (x i) (y i) ^ 2).sqrt :=
  (PiLp.dist_eq_of_L2 x y : _)
#align euclidean_space.dist_eq EuclideanSpace.dist_eq
-/

#print EuclideanSpace.nndist_eq /-
theorem EuclideanSpace.nndist_eq {𝕜 : Type _} [IsROrC 𝕜] {n : Type _} [Fintype n]
    (x y : EuclideanSpace 𝕜 n) : nndist x y = (∑ i, nndist (x i) (y i) ^ 2).sqrt :=
  (PiLp.nndist_eq_of_L2 x y : _)
#align euclidean_space.nndist_eq EuclideanSpace.nndist_eq
-/

#print EuclideanSpace.edist_eq /-
theorem EuclideanSpace.edist_eq {𝕜 : Type _} [IsROrC 𝕜] {n : Type _} [Fintype n]
    (x y : EuclideanSpace 𝕜 n) : edist x y = (∑ i, edist (x i) (y i) ^ 2) ^ (1 / 2 : ℝ) :=
  (PiLp.edist_eq_of_L2 x y : _)
#align euclidean_space.edist_eq EuclideanSpace.edist_eq
-/

variable [Fintype ι]

section

attribute [local reducible] PiLp

instance : FiniteDimensional 𝕜 (EuclideanSpace 𝕜 ι) := by infer_instance

instance : InnerProductSpace 𝕜 (EuclideanSpace 𝕜 ι) := by infer_instance

#print finrank_euclideanSpace /-
@[simp]
theorem finrank_euclideanSpace :
    FiniteDimensional.finrank 𝕜 (EuclideanSpace 𝕜 ι) = Fintype.card ι := by simp
#align finrank_euclidean_space finrank_euclideanSpace
-/

#print finrank_euclideanSpace_fin /-
theorem finrank_euclideanSpace_fin {n : ℕ} :
    FiniteDimensional.finrank 𝕜 (EuclideanSpace 𝕜 (Fin n)) = n := by simp
#align finrank_euclidean_space_fin finrank_euclideanSpace_fin
-/

#print EuclideanSpace.inner_eq_star_dotProduct /-
theorem EuclideanSpace.inner_eq_star_dotProduct (x y : EuclideanSpace 𝕜 ι) :
    ⟪x, y⟫ = Matrix.dotProduct (star <| PiLp.equiv _ _ x) (PiLp.equiv _ _ y) :=
  rfl
#align euclidean_space.inner_eq_star_dot_product EuclideanSpace.inner_eq_star_dotProduct
-/

#print EuclideanSpace.inner_piLp_equiv_symm /-
theorem EuclideanSpace.inner_piLp_equiv_symm (x y : ι → 𝕜) :
    ⟪(PiLp.equiv 2 _).symm x, (PiLp.equiv 2 _).symm y⟫ = Matrix.dotProduct (star x) y :=
  rfl
#align euclidean_space.inner_pi_Lp_equiv_symm EuclideanSpace.inner_piLp_equiv_symm
-/

#print DirectSum.IsInternal.isometryL2OfOrthogonalFamily /-
/-- A finite, mutually orthogonal family of subspaces of `E`, which span `E`, induce an isometry
from `E` to `pi_Lp 2` of the subspaces equipped with the `L2` inner product. -/
def DirectSum.IsInternal.isometryL2OfOrthogonalFamily [DecidableEq ι] {V : ι → Submodule 𝕜 E}
    (hV : DirectSum.IsInternal V)
    (hV' : OrthogonalFamily 𝕜 (fun i => V i) fun i => (V i).subtypeₗᵢ) :
    E ≃ₗᵢ[𝕜] PiLp 2 fun i => V i :=
  by
  let e₁ := DirectSum.linearEquivFunOnFintype 𝕜 ι fun i => V i
  let e₂ := LinearEquiv.ofBijective (DirectSum.coeLinearMap V) hV
  refine' LinearEquiv.isometryOfInner (e₂.symm.trans e₁) _
  suffices ∀ v w, ⟪v, w⟫ = ⟪e₂ (e₁.symm v), e₂ (e₁.symm w)⟫
    by
    intro v₀ w₀
    convert this (e₁ (e₂.symm v₀)) (e₁ (e₂.symm w₀)) <;>
      simp only [LinearEquiv.symm_apply_apply, LinearEquiv.apply_symm_apply]
  intro v w
  trans ⟪∑ i, (V i).subtypeₗᵢ (v i), ∑ i, (V i).subtypeₗᵢ (w i)⟫
  · simp only [sum_inner, hV'.inner_right_fintype, PiLp.inner_apply]
  · congr <;> simp
#align direct_sum.is_internal.isometry_L2_of_orthogonal_family DirectSum.IsInternal.isometryL2OfOrthogonalFamily
-/

#print DirectSum.IsInternal.isometryL2OfOrthogonalFamily_symm_apply /-
@[simp]
theorem DirectSum.IsInternal.isometryL2OfOrthogonalFamily_symm_apply [DecidableEq ι]
    {V : ι → Submodule 𝕜 E} (hV : DirectSum.IsInternal V)
    (hV' : OrthogonalFamily 𝕜 (fun i => V i) fun i => (V i).subtypeₗᵢ) (w : PiLp 2 fun i => V i) :
    (hV.isometryL2OfOrthogonalFamily hV').symm w = ∑ i, (w i : E) := by
  classical
  let e₁ := DirectSum.linearEquivFunOnFintype 𝕜 ι fun i => V i
  let e₂ := LinearEquiv.ofBijective (DirectSum.coeLinearMap V) hV
  suffices ∀ v : ⨁ i, V i, e₂ v = ∑ i, e₁ v i by exact this (e₁.symm w)
  intro v
  simp [e₂, DirectSum.coeLinearMap, DirectSum.toModule, Dfinsupp.sumAddHom_apply]
#align direct_sum.is_internal.isometry_L2_of_orthogonal_family_symm_apply DirectSum.IsInternal.isometryL2OfOrthogonalFamily_symm_apply
-/

end

variable (ι 𝕜)

#print EuclideanSpace.equiv /-
-- TODO : This should be generalized to `pi_Lp` with finite dimensional factors.
/-- `pi_Lp.linear_equiv` upgraded to a continuous linear map between `euclidean_space 𝕜 ι`
and `ι → 𝕜`. -/
@[simps]
def EuclideanSpace.equiv : EuclideanSpace 𝕜 ι ≃L[𝕜] ι → 𝕜 :=
  (PiLp.linearEquiv 2 𝕜 fun i : ι => 𝕜).toContinuousLinearEquiv
#align euclidean_space.equiv EuclideanSpace.equiv
-/

variable {ι 𝕜}

#print EuclideanSpace.projₗ /-
-- TODO : This should be generalized to `pi_Lp`.
/-- The projection on the `i`-th coordinate of `euclidean_space 𝕜 ι`, as a linear map. -/
@[simps]
def EuclideanSpace.projₗ (i : ι) : EuclideanSpace 𝕜 ι →ₗ[𝕜] 𝕜 :=
  (LinearMap.proj i).comp (PiLp.linearEquiv 2 𝕜 fun i : ι => 𝕜 : EuclideanSpace 𝕜 ι →ₗ[𝕜] ι → 𝕜)
#align euclidean_space.projₗ EuclideanSpace.projₗ
-/

#print EuclideanSpace.proj /-
-- TODO : This should be generalized to `pi_Lp`.
/-- The projection on the `i`-th coordinate of `euclidean_space 𝕜 ι`,
as a continuous linear map. -/
@[simps]
def EuclideanSpace.proj (i : ι) : EuclideanSpace 𝕜 ι →L[𝕜] 𝕜 :=
  ⟨EuclideanSpace.projₗ i, continuous_apply i⟩
#align euclidean_space.proj EuclideanSpace.proj
-/

#print EuclideanSpace.single /-
-- TODO : This should be generalized to `pi_Lp`.
/-- The vector given in euclidean space by being `1 : 𝕜` at coordinate `i : ι` and `0 : 𝕜` at
all other coordinates. -/
def EuclideanSpace.single [DecidableEq ι] (i : ι) (a : 𝕜) : EuclideanSpace 𝕜 ι :=
  (PiLp.equiv _ _).symm (Pi.single i a)
#align euclidean_space.single EuclideanSpace.single
-/

#print PiLp.equiv_single /-
@[simp]
theorem PiLp.equiv_single [DecidableEq ι] (i : ι) (a : 𝕜) :
    PiLp.equiv _ _ (EuclideanSpace.single i a) = Pi.single i a :=
  rfl
#align pi_Lp.equiv_single PiLp.equiv_single
-/

#print PiLp.equiv_symm_single /-
@[simp]
theorem PiLp.equiv_symm_single [DecidableEq ι] (i : ι) (a : 𝕜) :
    (PiLp.equiv _ _).symm (Pi.single i a) = EuclideanSpace.single i a :=
  rfl
#align pi_Lp.equiv_symm_single PiLp.equiv_symm_single
-/

#print EuclideanSpace.single_apply /-
@[simp]
theorem EuclideanSpace.single_apply [DecidableEq ι] (i : ι) (a : 𝕜) (j : ι) :
    (EuclideanSpace.single i a) j = ite (j = i) a 0 := by
  rw [EuclideanSpace.single, PiLp.equiv_symm_apply, ← Pi.single_apply i a j]
#align euclidean_space.single_apply EuclideanSpace.single_apply
-/

#print EuclideanSpace.inner_single_left /-
theorem EuclideanSpace.inner_single_left [DecidableEq ι] (i : ι) (a : 𝕜) (v : EuclideanSpace 𝕜 ι) :
    ⟪EuclideanSpace.single i (a : 𝕜), v⟫ = conj a * v i := by simp [apply_ite conj]
#align euclidean_space.inner_single_left EuclideanSpace.inner_single_left
-/

#print EuclideanSpace.inner_single_right /-
theorem EuclideanSpace.inner_single_right [DecidableEq ι] (i : ι) (a : 𝕜) (v : EuclideanSpace 𝕜 ι) :
    ⟪v, EuclideanSpace.single i (a : 𝕜)⟫ = a * conj (v i) := by simp [apply_ite conj, mul_comm]
#align euclidean_space.inner_single_right EuclideanSpace.inner_single_right
-/

#print EuclideanSpace.norm_single /-
@[simp]
theorem EuclideanSpace.norm_single [DecidableEq ι] (i : ι) (a : 𝕜) :
    ‖EuclideanSpace.single i (a : 𝕜)‖ = ‖a‖ :=
  (PiLp.norm_equiv_symm_single 2 (fun i => 𝕜) i a : _)
#align euclidean_space.norm_single EuclideanSpace.norm_single
-/

#print EuclideanSpace.nnnorm_single /-
@[simp]
theorem EuclideanSpace.nnnorm_single [DecidableEq ι] (i : ι) (a : 𝕜) :
    ‖EuclideanSpace.single i (a : 𝕜)‖₊ = ‖a‖₊ :=
  (PiLp.nnnorm_equiv_symm_single 2 (fun i => 𝕜) i a : _)
#align euclidean_space.nnnorm_single EuclideanSpace.nnnorm_single
-/

#print EuclideanSpace.dist_single_same /-
@[simp]
theorem EuclideanSpace.dist_single_same [DecidableEq ι] (i : ι) (a b : 𝕜) :
    dist (EuclideanSpace.single i (a : 𝕜)) (EuclideanSpace.single i (b : 𝕜)) = dist a b :=
  (PiLp.dist_equiv_symm_single_same 2 (fun i => 𝕜) i a b : _)
#align euclidean_space.dist_single_same EuclideanSpace.dist_single_same
-/

#print EuclideanSpace.nndist_single_same /-
@[simp]
theorem EuclideanSpace.nndist_single_same [DecidableEq ι] (i : ι) (a b : 𝕜) :
    nndist (EuclideanSpace.single i (a : 𝕜)) (EuclideanSpace.single i (b : 𝕜)) = nndist a b :=
  (PiLp.nndist_equiv_symm_single_same 2 (fun i => 𝕜) i a b : _)
#align euclidean_space.nndist_single_same EuclideanSpace.nndist_single_same
-/

#print EuclideanSpace.edist_single_same /-
@[simp]
theorem EuclideanSpace.edist_single_same [DecidableEq ι] (i : ι) (a b : 𝕜) :
    edist (EuclideanSpace.single i (a : 𝕜)) (EuclideanSpace.single i (b : 𝕜)) = edist a b :=
  (PiLp.edist_equiv_symm_single_same 2 (fun i => 𝕜) i a b : _)
#align euclidean_space.edist_single_same EuclideanSpace.edist_single_same
-/

#print EuclideanSpace.orthonormal_single /-
/-- `euclidean_space.single` forms an orthonormal family. -/
theorem EuclideanSpace.orthonormal_single [DecidableEq ι] :
    Orthonormal 𝕜 fun i : ι => EuclideanSpace.single i (1 : 𝕜) :=
  by
  simp_rw [orthonormal_iff_ite, EuclideanSpace.inner_single_left, map_one, one_mul,
    EuclideanSpace.single_apply]
  intro i j
  rfl
#align euclidean_space.orthonormal_single EuclideanSpace.orthonormal_single
-/

#print EuclideanSpace.piLpCongrLeft_single /-
theorem EuclideanSpace.piLpCongrLeft_single [DecidableEq ι] {ι' : Type _} [Fintype ι']
    [DecidableEq ι'] (e : ι' ≃ ι) (i' : ι') (v : 𝕜) :
    LinearIsometryEquiv.piLpCongrLeft 2 𝕜 𝕜 e (EuclideanSpace.single i' v) =
      EuclideanSpace.single (e i') v :=
  LinearIsometryEquiv.piLpCongrLeft_single e i' _
#align euclidean_space.pi_Lp_congr_left_single EuclideanSpace.piLpCongrLeft_single
-/

variable (ι 𝕜 E)

#print OrthonormalBasis /-
/-- An orthonormal basis on E is an identification of `E` with its dimensional-matching
`euclidean_space 𝕜 ι`. -/
structure OrthonormalBasis where ofRepr ::
  repr : E ≃ₗᵢ[𝕜] EuclideanSpace 𝕜 ι
#align orthonormal_basis OrthonormalBasis
-/

variable {ι 𝕜 E}

namespace OrthonormalBasis

instance : Inhabited (OrthonormalBasis ι 𝕜 (EuclideanSpace 𝕜 ι)) :=
  ⟨ofRepr (LinearIsometryEquiv.refl 𝕜 (EuclideanSpace 𝕜 ι))⟩

/-- `b i` is the `i`th basis vector. -/
instance : CoeFun (OrthonormalBasis ι 𝕜 E) fun _ => ι → E
    where coe b i := by classical exact b.repr.symm (EuclideanSpace.single i (1 : 𝕜))

#print OrthonormalBasis.coe_ofRepr /-
@[simp]
theorem coe_ofRepr [DecidableEq ι] (e : E ≃ₗᵢ[𝕜] EuclideanSpace 𝕜 ι) :
    ⇑(OrthonormalBasis.ofRepr e) = fun i => e.symm (EuclideanSpace.single i (1 : 𝕜)) :=
  by
  rw [coeFn]
  unfold CoeFun.coe
  funext
  congr
  simp only [eq_iff_true_of_subsingleton]
#align orthonormal_basis.coe_of_repr OrthonormalBasis.coe_ofRepr
-/

#print OrthonormalBasis.repr_symm_single /-
@[simp]
protected theorem repr_symm_single [DecidableEq ι] (b : OrthonormalBasis ι 𝕜 E) (i : ι) :
    b.repr.symm (EuclideanSpace.single i (1 : 𝕜)) = b i := by
  classical
  congr
  simp
#align orthonormal_basis.repr_symm_single OrthonormalBasis.repr_symm_single
-/

#print OrthonormalBasis.repr_self /-
@[simp]
protected theorem repr_self [DecidableEq ι] (b : OrthonormalBasis ι 𝕜 E) (i : ι) :
    b.repr (b i) = EuclideanSpace.single i (1 : 𝕜) := by
  rw [← b.repr_symm_single i, LinearIsometryEquiv.apply_symm_apply]
#align orthonormal_basis.repr_self OrthonormalBasis.repr_self
-/

#print OrthonormalBasis.repr_apply_apply /-
protected theorem repr_apply_apply (b : OrthonormalBasis ι 𝕜 E) (v : E) (i : ι) :
    b.repr v i = ⟪b i, v⟫ := by
  classical
  rw [← b.repr.inner_map_map (b i) v, b.repr_self i, EuclideanSpace.inner_single_left]
  simp only [one_mul, eq_self_iff_true, map_one]
#align orthonormal_basis.repr_apply_apply OrthonormalBasis.repr_apply_apply
-/

#print OrthonormalBasis.orthonormal /-
@[simp]
protected theorem orthonormal (b : OrthonormalBasis ι 𝕜 E) : Orthonormal 𝕜 b := by
  classical
  rw [orthonormal_iff_ite]
  intro i j
  rw [← b.repr.inner_map_map (b i) (b j), b.repr_self i, b.repr_self j,
    EuclideanSpace.inner_single_left, EuclideanSpace.single_apply, map_one, one_mul]
#align orthonormal_basis.orthonormal OrthonormalBasis.orthonormal
-/

#print OrthonormalBasis.toBasis /-
/-- The `basis ι 𝕜 E` underlying the `orthonormal_basis` -/
protected def toBasis (b : OrthonormalBasis ι 𝕜 E) : Basis ι 𝕜 E :=
  Basis.ofEquivFun b.repr.toLinearEquiv
#align orthonormal_basis.to_basis OrthonormalBasis.toBasis
-/

#print OrthonormalBasis.coe_toBasis /-
@[simp]
protected theorem coe_toBasis (b : OrthonormalBasis ι 𝕜 E) : (⇑b.toBasis : ι → E) = ⇑b :=
  by
  change ⇑(Basis.ofEquivFun b.repr.to_linear_equiv) = b
  ext j
  classical
  rw [Basis.coe_ofEquivFun]
  congr
#align orthonormal_basis.coe_to_basis OrthonormalBasis.coe_toBasis
-/

#print OrthonormalBasis.coe_toBasis_repr /-
@[simp]
protected theorem coe_toBasis_repr (b : OrthonormalBasis ι 𝕜 E) :
    b.toBasis.equivFun = b.repr.toLinearEquiv :=
  Basis.equivFun_ofEquivFun _
#align orthonormal_basis.coe_to_basis_repr OrthonormalBasis.coe_toBasis_repr
-/

#print OrthonormalBasis.coe_toBasis_repr_apply /-
@[simp]
protected theorem coe_toBasis_repr_apply (b : OrthonormalBasis ι 𝕜 E) (x : E) (i : ι) :
    b.toBasis.repr x i = b.repr x i := by
  rw [← Basis.equivFun_apply, OrthonormalBasis.coe_toBasis_repr,
    LinearIsometryEquiv.coe_toLinearEquiv]
#align orthonormal_basis.coe_to_basis_repr_apply OrthonormalBasis.coe_toBasis_repr_apply
-/

#print OrthonormalBasis.sum_repr /-
protected theorem sum_repr (b : OrthonormalBasis ι 𝕜 E) (x : E) : ∑ i, b.repr x i • b i = x := by
  simp_rw [← b.coe_to_basis_repr_apply, ← b.coe_to_basis]; exact b.to_basis.sum_repr x
#align orthonormal_basis.sum_repr OrthonormalBasis.sum_repr
-/

#print OrthonormalBasis.sum_repr_symm /-
protected theorem sum_repr_symm (b : OrthonormalBasis ι 𝕜 E) (v : EuclideanSpace 𝕜 ι) :
    ∑ i, v i • b i = b.repr.symm v := by simpa using (b.to_basis.equiv_fun_symm_apply v).symm
#align orthonormal_basis.sum_repr_symm OrthonormalBasis.sum_repr_symm
-/

#print OrthonormalBasis.sum_inner_mul_inner /-
protected theorem sum_inner_mul_inner (b : OrthonormalBasis ι 𝕜 E) (x y : E) :
    ∑ i, ⟪x, b i⟫ * ⟪b i, y⟫ = ⟪x, y⟫ :=
  by
  have := congr_arg (innerSL 𝕜 x) (b.sum_repr y)
  rw [map_sum] at this 
  convert this
  ext i
  rw [SMulHomClass.map_smul, b.repr_apply_apply, mul_comm]
  rfl
#align orthonormal_basis.sum_inner_mul_inner OrthonormalBasis.sum_inner_mul_inner
-/

#print OrthonormalBasis.orthogonalProjection_eq_sum /-
protected theorem orthogonalProjection_eq_sum {U : Submodule 𝕜 E} [CompleteSpace U]
    (b : OrthonormalBasis ι 𝕜 U) (x : E) : orthogonalProjection U x = ∑ i, ⟪(b i : E), x⟫ • b i :=
  by
  simpa only [b.repr_apply_apply, inner_orthogonalProjection_eq_of_mem_left] using
    (b.sum_repr (orthogonalProjection U x)).symm
#align orthonormal_basis.orthogonal_projection_eq_sum OrthonormalBasis.orthogonalProjection_eq_sum
-/

#print OrthonormalBasis.map /-
/-- Mapping an orthonormal basis along a `linear_isometry_equiv`. -/
protected def map {G : Type _} [NormedAddCommGroup G] [InnerProductSpace 𝕜 G]
    (b : OrthonormalBasis ι 𝕜 E) (L : E ≃ₗᵢ[𝕜] G) : OrthonormalBasis ι 𝕜 G
    where repr := L.symm.trans b.repr
#align orthonormal_basis.map OrthonormalBasis.map
-/

#print OrthonormalBasis.map_apply /-
@[simp]
protected theorem map_apply {G : Type _} [NormedAddCommGroup G] [InnerProductSpace 𝕜 G]
    (b : OrthonormalBasis ι 𝕜 E) (L : E ≃ₗᵢ[𝕜] G) (i : ι) : b.map L i = L (b i) :=
  rfl
#align orthonormal_basis.map_apply OrthonormalBasis.map_apply
-/

#print OrthonormalBasis.toBasis_map /-
@[simp]
protected theorem toBasis_map {G : Type _} [NormedAddCommGroup G] [InnerProductSpace 𝕜 G]
    (b : OrthonormalBasis ι 𝕜 E) (L : E ≃ₗᵢ[𝕜] G) :
    (b.map L).toBasis = b.toBasis.map L.toLinearEquiv :=
  rfl
#align orthonormal_basis.to_basis_map OrthonormalBasis.toBasis_map
-/

#print Basis.toOrthonormalBasis /-
/-- A basis that is orthonormal is an orthonormal basis. -/
def Basis.toOrthonormalBasis (v : Basis ι 𝕜 E) (hv : Orthonormal 𝕜 v) : OrthonormalBasis ι 𝕜 E :=
  OrthonormalBasis.ofRepr <|
    LinearEquiv.isometryOfInner v.equivFun
      (by
        intro x y
        let p : EuclideanSpace 𝕜 ι := v.equiv_fun x
        let q : EuclideanSpace 𝕜 ι := v.equiv_fun y
        have key : ⟪p, q⟫ = ⟪∑ i, p i • v i, ∑ i, q i • v i⟫ := by
          simp [sum_inner, inner_smul_left, hv.inner_right_fintype]
        convert key
        · rw [← v.equiv_fun.symm_apply_apply x, v.equiv_fun_symm_apply]
        · rw [← v.equiv_fun.symm_apply_apply y, v.equiv_fun_symm_apply])
#align basis.to_orthonormal_basis Basis.toOrthonormalBasis
-/

#print Basis.coe_toOrthonormalBasis_repr /-
@[simp]
theorem Basis.coe_toOrthonormalBasis_repr (v : Basis ι 𝕜 E) (hv : Orthonormal 𝕜 v) :
    ((v.toOrthonormalBasis hv).repr : E → EuclideanSpace 𝕜 ι) = v.equivFun :=
  rfl
#align basis.coe_to_orthonormal_basis_repr Basis.coe_toOrthonormalBasis_repr
-/

#print Basis.coe_toOrthonormalBasis_repr_symm /-
@[simp]
theorem Basis.coe_toOrthonormalBasis_repr_symm (v : Basis ι 𝕜 E) (hv : Orthonormal 𝕜 v) :
    ((v.toOrthonormalBasis hv).repr.symm : EuclideanSpace 𝕜 ι → E) = v.equivFun.symm :=
  rfl
#align basis.coe_to_orthonormal_basis_repr_symm Basis.coe_toOrthonormalBasis_repr_symm
-/

#print Basis.toBasis_toOrthonormalBasis /-
@[simp]
theorem Basis.toBasis_toOrthonormalBasis (v : Basis ι 𝕜 E) (hv : Orthonormal 𝕜 v) :
    (v.toOrthonormalBasis hv).toBasis = v := by
  simp [Basis.toOrthonormalBasis, OrthonormalBasis.toBasis]
#align basis.to_basis_to_orthonormal_basis Basis.toBasis_toOrthonormalBasis
-/

#print Basis.coe_toOrthonormalBasis /-
@[simp]
theorem Basis.coe_toOrthonormalBasis (v : Basis ι 𝕜 E) (hv : Orthonormal 𝕜 v) :
    (v.toOrthonormalBasis hv : ι → E) = (v : ι → E) :=
  calc
    (v.toOrthonormalBasis hv : ι → E) = ((v.toOrthonormalBasis hv).toBasis : ι → E) := by
      classical rw [OrthonormalBasis.coe_toBasis]
    _ = (v : ι → E) := by simp
#align basis.coe_to_orthonormal_basis Basis.coe_toOrthonormalBasis
-/

variable {v : ι → E}

#print OrthonormalBasis.mk /-
/-- A finite orthonormal set that spans is an orthonormal basis -/
protected def mk (hon : Orthonormal 𝕜 v) (hsp : ⊤ ≤ Submodule.span 𝕜 (Set.range v)) :
    OrthonormalBasis ι 𝕜 E :=
  (Basis.mk (Orthonormal.linearIndependent hon) hsp).toOrthonormalBasis (by rwa [Basis.coe_mk])
#align orthonormal_basis.mk OrthonormalBasis.mk
-/

#print OrthonormalBasis.coe_mk /-
@[simp]
protected theorem coe_mk (hon : Orthonormal 𝕜 v) (hsp : ⊤ ≤ Submodule.span 𝕜 (Set.range v)) :
    ⇑(OrthonormalBasis.mk hon hsp) = v := by
  classical rw [OrthonormalBasis.mk, _root_.basis.coe_to_orthonormal_basis, Basis.coe_mk]
#align orthonormal_basis.coe_mk OrthonormalBasis.coe_mk
-/

#print OrthonormalBasis.span /-
/-- Any finite subset of a orthonormal family is an `orthonormal_basis` for its span. -/
protected def span [DecidableEq E] {v' : ι' → E} (h : Orthonormal 𝕜 v') (s : Finset ι') :
    OrthonormalBasis s 𝕜 (span 𝕜 (s.image v' : Set E)) :=
  let e₀' : Basis s 𝕜 _ :=
    Basis.span (h.LinearIndependent.comp (coe : s → ι') Subtype.coe_injective)
  let e₀ : OrthonormalBasis s 𝕜 _ :=
    OrthonormalBasis.mk
      (by
        convert orthonormal_span (h.comp (coe : s → ι') Subtype.coe_injective)
        ext
        simp [e₀', Basis.span_apply])
      e₀'.span_eq.ge
  let φ : span 𝕜 (s.image v' : Set E) ≃ₗᵢ[𝕜] span 𝕜 (range (v' ∘ (coe : s → ι'))) :=
    LinearIsometryEquiv.ofEq _ _
      (by
        rw [Finset.coe_image, image_eq_range]
        rfl)
  e₀.map φ.symm
#align orthonormal_basis.span OrthonormalBasis.span
-/

#print OrthonormalBasis.span_apply /-
@[simp]
protected theorem span_apply [DecidableEq E] {v' : ι' → E} (h : Orthonormal 𝕜 v') (s : Finset ι')
    (i : s) : (OrthonormalBasis.span h s i : E) = v' i := by
  simp only [OrthonormalBasis.span, Basis.span_apply, LinearIsometryEquiv.ofEq_symm,
    OrthonormalBasis.map_apply, OrthonormalBasis.coe_mk, LinearIsometryEquiv.coe_ofEq_apply]
#align orthonormal_basis.span_apply OrthonormalBasis.span_apply
-/

open Submodule

#print OrthonormalBasis.mkOfOrthogonalEqBot /-
/-- A finite orthonormal family of vectors whose span has trivial orthogonal complement is an
orthonormal basis. -/
protected def mkOfOrthogonalEqBot (hon : Orthonormal 𝕜 v) (hsp : (span 𝕜 (Set.range v))ᗮ = ⊥) :
    OrthonormalBasis ι 𝕜 E :=
  OrthonormalBasis.mk hon
    (by
      refine' Eq.ge _
      haveI : FiniteDimensional 𝕜 (span 𝕜 (range v)) :=
        FiniteDimensional.span_of_finite 𝕜 (finite_range v)
      haveI : CompleteSpace (span 𝕜 (range v)) := FiniteDimensional.complete 𝕜 _
      rwa [orthogonal_eq_bot_iff] at hsp )
#align orthonormal_basis.mk_of_orthogonal_eq_bot OrthonormalBasis.mkOfOrthogonalEqBot
-/

#print OrthonormalBasis.coe_of_orthogonal_eq_bot_mk /-
@[simp]
protected theorem coe_of_orthogonal_eq_bot_mk (hon : Orthonormal 𝕜 v)
    (hsp : (span 𝕜 (Set.range v))ᗮ = ⊥) : ⇑(OrthonormalBasis.mkOfOrthogonalEqBot hon hsp) = v :=
  OrthonormalBasis.coe_mk hon _
#align orthonormal_basis.coe_of_orthogonal_eq_bot_mk OrthonormalBasis.coe_of_orthogonal_eq_bot_mk
-/

variable [Fintype ι']

#print OrthonormalBasis.reindex /-
/-- `b.reindex (e : ι ≃ ι')` is an `orthonormal_basis` indexed by `ι'` -/
def reindex (b : OrthonormalBasis ι 𝕜 E) (e : ι ≃ ι') : OrthonormalBasis ι' 𝕜 E :=
  OrthonormalBasis.ofRepr (b.repr.trans (LinearIsometryEquiv.piLpCongrLeft 2 𝕜 𝕜 e))
#align orthonormal_basis.reindex OrthonormalBasis.reindex
-/

#print OrthonormalBasis.reindex_apply /-
protected theorem reindex_apply (b : OrthonormalBasis ι 𝕜 E) (e : ι ≃ ι') (i' : ι') :
    (b.reindex e) i' = b (e.symm i') := by
  classical
  dsimp [reindex, OrthonormalBasis.hasCoeToFun]
  rw [coe_of_repr]
  dsimp
  rw [← b.repr_symm_single, LinearIsometryEquiv.piLpCongrLeft_symm,
    EuclideanSpace.piLpCongrLeft_single]
#align orthonormal_basis.reindex_apply OrthonormalBasis.reindex_apply
-/

#print OrthonormalBasis.coe_reindex /-
@[simp]
protected theorem coe_reindex (b : OrthonormalBasis ι 𝕜 E) (e : ι ≃ ι') :
    ⇑(b.reindex e) = ⇑b ∘ ⇑e.symm :=
  funext (b.reindex_apply e)
#align orthonormal_basis.coe_reindex OrthonormalBasis.coe_reindex
-/

#print OrthonormalBasis.repr_reindex /-
@[simp]
protected theorem repr_reindex (b : OrthonormalBasis ι 𝕜 E) (e : ι ≃ ι') (x : E) (i' : ι') :
    (b.reindex e).repr x i' = b.repr x (e.symm i') := by
  classical rw [OrthonormalBasis.repr_apply_apply, b.repr_apply_apply, OrthonormalBasis.coe_reindex]
#align orthonormal_basis.repr_reindex OrthonormalBasis.repr_reindex
-/

end OrthonormalBasis

#print Complex.orthonormalBasisOneI /-
/-- `![1, I]` is an orthonormal basis for `ℂ` considered as a real inner product space. -/
def Complex.orthonormalBasisOneI : OrthonormalBasis (Fin 2) ℝ ℂ :=
  Complex.basisOneI.toOrthonormalBasis
    (by
      rw [orthonormal_iff_ite]
      intro i; fin_cases i <;> intro j <;> fin_cases j <;> simp [real_inner_eq_re_inner])
#align complex.orthonormal_basis_one_I Complex.orthonormalBasisOneI
-/

#print Complex.orthonormalBasisOneI_repr_apply /-
@[simp]
theorem Complex.orthonormalBasisOneI_repr_apply (z : ℂ) :
    Complex.orthonormalBasisOneI.repr z = ![z.re, z.im] :=
  rfl
#align complex.orthonormal_basis_one_I_repr_apply Complex.orthonormalBasisOneI_repr_apply
-/

#print Complex.orthonormalBasisOneI_repr_symm_apply /-
@[simp]
theorem Complex.orthonormalBasisOneI_repr_symm_apply (x : EuclideanSpace ℝ (Fin 2)) :
    Complex.orthonormalBasisOneI.repr.symm x = x 0 + x 1 * i :=
  rfl
#align complex.orthonormal_basis_one_I_repr_symm_apply Complex.orthonormalBasisOneI_repr_symm_apply
-/

#print Complex.toBasis_orthonormalBasisOneI /-
@[simp]
theorem Complex.toBasis_orthonormalBasisOneI :
    Complex.orthonormalBasisOneI.toBasis = Complex.basisOneI :=
  Basis.toBasis_toOrthonormalBasis _ _
#align complex.to_basis_orthonormal_basis_one_I Complex.toBasis_orthonormalBasisOneI
-/

#print Complex.coe_orthonormalBasisOneI /-
@[simp]
theorem Complex.coe_orthonormalBasisOneI : (Complex.orthonormalBasisOneI : Fin 2 → ℂ) = ![1, i] :=
  by simp [Complex.orthonormalBasisOneI]
#align complex.coe_orthonormal_basis_one_I Complex.coe_orthonormalBasisOneI
-/

#print Complex.isometryOfOrthonormal /-
/-- The isometry between `ℂ` and a two-dimensional real inner product space given by a basis. -/
def Complex.isometryOfOrthonormal (v : OrthonormalBasis (Fin 2) ℝ F) : ℂ ≃ₗᵢ[ℝ] F :=
  Complex.orthonormalBasisOneI.repr.trans v.repr.symm
#align complex.isometry_of_orthonormal Complex.isometryOfOrthonormal
-/

#print Complex.map_isometryOfOrthonormal /-
@[simp]
theorem Complex.map_isometryOfOrthonormal (v : OrthonormalBasis (Fin 2) ℝ F) (f : F ≃ₗᵢ[ℝ] F') :
    Complex.isometryOfOrthonormal (v.map f) = (Complex.isometryOfOrthonormal v).trans f := by
  simp [Complex.isometryOfOrthonormal, LinearIsometryEquiv.trans_assoc, OrthonormalBasis.map]
#align complex.map_isometry_of_orthonormal Complex.map_isometryOfOrthonormal
-/

#print Complex.isometryOfOrthonormal_symm_apply /-
theorem Complex.isometryOfOrthonormal_symm_apply (v : OrthonormalBasis (Fin 2) ℝ F) (f : F) :
    (Complex.isometryOfOrthonormal v).symm f =
      (v.toBasis.Coord 0 f : ℂ) + (v.toBasis.Coord 1 f : ℂ) * i :=
  by simp [Complex.isometryOfOrthonormal]
#align complex.isometry_of_orthonormal_symm_apply Complex.isometryOfOrthonormal_symm_apply
-/

#print Complex.isometryOfOrthonormal_apply /-
theorem Complex.isometryOfOrthonormal_apply (v : OrthonormalBasis (Fin 2) ℝ F) (z : ℂ) :
    Complex.isometryOfOrthonormal v z = z.re • v 0 + z.im • v 1 := by
  simp [Complex.isometryOfOrthonormal, ← v.sum_repr_symm]
#align complex.isometry_of_orthonormal_apply Complex.isometryOfOrthonormal_apply
-/

open FiniteDimensional

/-! ### Matrix representation of an orthonormal basis with respect to another -/


section ToMatrix

variable [DecidableEq ι]

section

variable (a b : OrthonormalBasis ι 𝕜 E)

#print OrthonormalBasis.toMatrix_orthonormalBasis_mem_unitary /-
/-- The change-of-basis matrix between two orthonormal bases `a`, `b` is a unitary matrix. -/
theorem OrthonormalBasis.toMatrix_orthonormalBasis_mem_unitary :
    a.toBasis.toMatrix b ∈ Matrix.unitaryGroup ι 𝕜 :=
  by
  rw [Matrix.mem_unitaryGroup_iff']
  ext i j
  convert a.repr.inner_map_map (b i) (b j)
  rw [orthonormal_iff_ite.mp b.orthonormal i j]
  rfl
#align orthonormal_basis.to_matrix_orthonormal_basis_mem_unitary OrthonormalBasis.toMatrix_orthonormalBasis_mem_unitary
-/

#print OrthonormalBasis.det_to_matrix_orthonormalBasis /-
/-- The determinant of the change-of-basis matrix between two orthonormal bases `a`, `b` has
unit length. -/
@[simp]
theorem OrthonormalBasis.det_to_matrix_orthonormalBasis : ‖a.toBasis.det b‖ = 1 :=
  by
  have : (norm_sq (a.to_basis.det b) : 𝕜) = 1 := by
    simpa [IsROrC.mul_conj] using
      (Matrix.det_of_mem_unitary (a.to_matrix_orthonormal_basis_mem_unitary b)).2
  norm_cast at this 
  rwa [← sqrt_norm_sq_eq_norm, sqrt_eq_one]
#align orthonormal_basis.det_to_matrix_orthonormal_basis OrthonormalBasis.det_to_matrix_orthonormalBasis
-/

end

section Real

variable (a b : OrthonormalBasis ι ℝ F)

#print OrthonormalBasis.toMatrix_orthonormalBasis_mem_orthogonal /-
/-- The change-of-basis matrix between two orthonormal bases `a`, `b` is an orthogonal matrix. -/
theorem OrthonormalBasis.toMatrix_orthonormalBasis_mem_orthogonal :
    a.toBasis.toMatrix b ∈ Matrix.orthogonalGroup ι ℝ :=
  a.toMatrix_orthonormalBasis_mem_unitary b
#align orthonormal_basis.to_matrix_orthonormal_basis_mem_orthogonal OrthonormalBasis.toMatrix_orthonormalBasis_mem_orthogonal
-/

#print OrthonormalBasis.det_to_matrix_orthonormalBasis_real /-
/-- The determinant of the change-of-basis matrix between two orthonormal bases `a`, `b` is ±1. -/
theorem OrthonormalBasis.det_to_matrix_orthonormalBasis_real :
    a.toBasis.det b = 1 ∨ a.toBasis.det b = -1 :=
  by
  rw [← sq_eq_one_iff]
  simpa [unitary, sq] using Matrix.det_of_mem_unitary (a.to_matrix_orthonormal_basis_mem_unitary b)
#align orthonormal_basis.det_to_matrix_orthonormal_basis_real OrthonormalBasis.det_to_matrix_orthonormalBasis_real
-/

end Real

end ToMatrix

/-! ### Existence of orthonormal basis, etc. -/


section FiniteDimensional

variable {v : Set E}

variable {A : ι → Submodule 𝕜 E}

#print DirectSum.IsInternal.collectedOrthonormalBasis /-
/-- Given an internal direct sum decomposition of a module `M`, and an orthonormal basis for each
of the components of the direct sum, the disjoint union of these orthonormal bases is an
orthonormal basis for `M`. -/
noncomputable def DirectSum.IsInternal.collectedOrthonormalBasis
    (hV : OrthogonalFamily 𝕜 (fun i => A i) fun i => (A i).subtypeₗᵢ) [DecidableEq ι]
    (hV_sum : DirectSum.IsInternal fun i => A i) {α : ι → Type _} [∀ i, Fintype (α i)]
    (v_family : ∀ i, OrthonormalBasis (α i) 𝕜 (A i)) : OrthonormalBasis (Σ i, α i) 𝕜 E :=
  (hV_sum.collectedBasis fun i => (v_family i).toBasis).toOrthonormalBasis <| by
    simpa using
      hV.orthonormal_sigma_orthonormal (show ∀ i, Orthonormal 𝕜 (v_family i).toBasis by simp)
#align direct_sum.is_internal.collected_orthonormal_basis DirectSum.IsInternal.collectedOrthonormalBasis
-/

#print DirectSum.IsInternal.collectedOrthonormalBasis_mem /-
theorem DirectSum.IsInternal.collectedOrthonormalBasis_mem [DecidableEq ι]
    (h : DirectSum.IsInternal A) {α : ι → Type _} [∀ i, Fintype (α i)]
    (hV : OrthogonalFamily 𝕜 (fun i => A i) fun i => (A i).subtypeₗᵢ)
    (v : ∀ i, OrthonormalBasis (α i) 𝕜 (A i)) (a : Σ i, α i) :
    h.collectedOrthonormalBasis hV v a ∈ A a.1 := by
  simp [DirectSum.IsInternal.collectedOrthonormalBasis]
#align direct_sum.is_internal.collected_orthonormal_basis_mem DirectSum.IsInternal.collectedOrthonormalBasis_mem
-/

variable [FiniteDimensional 𝕜 E]

#print Orthonormal.exists_orthonormalBasis_extension /-
/-- In a finite-dimensional `inner_product_space`, any orthonormal subset can be extended to an
orthonormal basis. -/
theorem Orthonormal.exists_orthonormalBasis_extension (hv : Orthonormal 𝕜 (coe : v → E)) :
    ∃ (u : Finset E) (b : OrthonormalBasis u 𝕜 E), v ⊆ u ∧ ⇑b = coe :=
  by
  obtain ⟨u₀, hu₀s, hu₀, hu₀_max⟩ := exists_maximal_orthonormal hv
  rw [maximal_orthonormal_iff_orthogonalComplement_eq_bot hu₀] at hu₀_max 
  have hu₀_finite : u₀.finite := hu₀.linear_independent.finite
  let u : Finset E := hu₀_finite.to_finset
  let fu : ↥u ≃ ↥u₀ := Equiv.cast (congr_arg coeSort hu₀_finite.coe_to_finset)
  have hfu : (coe : u → E) = (coe : u₀ → E) ∘ fu := by ext; simp
  have hu : Orthonormal 𝕜 (coe : u → E) := by simpa [hfu] using hu₀.comp _ fu.injective
  refine' ⟨u, OrthonormalBasis.mkOfOrthogonalEqBot hu _, _, _⟩
  · simpa using hu₀_max
  · simpa using hu₀s
  · simp
#align orthonormal.exists_orthonormal_basis_extension Orthonormal.exists_orthonormalBasis_extension
-/

#print Orthonormal.exists_orthonormalBasis_extension_of_card_eq /-
theorem Orthonormal.exists_orthonormalBasis_extension_of_card_eq {ι : Type _} [Fintype ι]
    (card_ι : finrank 𝕜 E = Fintype.card ι) {v : ι → E} {s : Set ι}
    (hv : Orthonormal 𝕜 (s.restrict v)) : ∃ b : OrthonormalBasis ι 𝕜 E, ∀ i ∈ s, b i = v i :=
  by
  have hsv : injective (s.restrict v) := hv.linear_independent.injective
  have hX : Orthonormal 𝕜 (coe : Set.range (s.restrict v) → E) := by
    rwa [orthonormal_subtype_range hsv]
  obtain ⟨Y, b₀, hX, hb₀⟩ := hX.exists_orthonormal_basis_extension
  have hιY : Fintype.card ι = Y.card :=
    by
    refine' card_ι.symm.trans _
    exact FiniteDimensional.finrank_eq_card_finset_basis b₀.to_basis
  have hvsY : s.maps_to v Y := (s.maps_to_image v).mono_right (by rwa [← range_restrict])
  have hsv' : Set.InjOn v s := by
    rw [Set.injOn_iff_injective]
    exact hsv
  obtain ⟨g, hg⟩ := hvsY.exists_equiv_extend_of_card_eq hιY hsv'
  use b₀.reindex g.symm
  intro i hi
  · simp [hb₀, hg i hi]
#align orthonormal.exists_orthonormal_basis_extension_of_card_eq Orthonormal.exists_orthonormalBasis_extension_of_card_eq
-/

variable (𝕜 E)

#print exists_orthonormalBasis /-
/-- A finite-dimensional inner product space admits an orthonormal basis. -/
theorem exists_orthonormalBasis :
    ∃ (w : Finset E) (b : OrthonormalBasis w 𝕜 E), ⇑b = (coe : w → E) :=
  let ⟨w, hw, hw', hw''⟩ := (orthonormal_empty 𝕜 E).exists_orthonormalBasis_extension
  ⟨w, hw, hw''⟩
#align exists_orthonormal_basis exists_orthonormalBasis
-/

#print stdOrthonormalBasis /-
/-- A finite-dimensional `inner_product_space` has an orthonormal basis. -/
irreducible_def stdOrthonormalBasis : OrthonormalBasis (Fin (finrank 𝕜 E)) 𝕜 E :=
  by
  let b := Classical.choose (Classical.choose_spec <| exists_orthonormalBasis 𝕜 E)
  rw [finrank_eq_card_basis b.to_basis]
  exact b.reindex (Fintype.equivFinOfCardEq rfl)
#align std_orthonormal_basis stdOrthonormalBasis
-/

#print orthonormalBasis_one_dim /-
/-- An orthonormal basis of `ℝ` is made either of the vector `1`, or of the vector `-1`. -/
theorem orthonormalBasis_one_dim (b : OrthonormalBasis ι ℝ ℝ) :
    (⇑b = fun _ => (1 : ℝ)) ∨ ⇑b = fun _ => (-1 : ℝ) :=
  by
  have : Unique ι := b.to_basis.unique
  have : b default = 1 ∨ b default = -1 :=
    by
    have : ‖b default‖ = 1 := b.orthonormal.1 _
    rwa [Real.norm_eq_abs, abs_eq (zero_le_one : (0 : ℝ) ≤ 1)] at this 
  rw [eq_const_of_unique b]
  refine' this.imp _ _ <;> simp
#align orthonormal_basis_one_dim orthonormalBasis_one_dim
-/

variable {𝕜 E}

section SubordinateOrthonormalBasis

open DirectSum

variable {n : ℕ} (hn : finrank 𝕜 E = n) [DecidableEq ι] {V : ι → Submodule 𝕜 E} (hV : IsInternal V)

#print DirectSum.IsInternal.sigmaOrthonormalBasisIndexEquiv /-
/-- Exhibit a bijection between `fin n` and the index set of a certain basis of an `n`-dimensional
inner product space `E`.  This should not be accessed directly, but only via the subsequent API. -/
irreducible_def DirectSum.IsInternal.sigmaOrthonormalBasisIndexEquiv
    (hV' : OrthogonalFamily 𝕜 (fun i => V i) fun i => (V i).subtypeₗᵢ) :
    (Σ i, Fin (finrank 𝕜 (V i))) ≃ Fin n :=
  let b := hV.collectedOrthonormalBasis hV' fun i => stdOrthonormalBasis 𝕜 (V i)
  Fintype.equivFinOfCardEq <| (FiniteDimensional.finrank_eq_card_basis b.toBasis).symm.trans hn
#align direct_sum.is_internal.sigma_orthonormal_basis_index_equiv DirectSum.IsInternal.sigmaOrthonormalBasisIndexEquiv
-/

#print DirectSum.IsInternal.subordinateOrthonormalBasis /-
/-- An `n`-dimensional `inner_product_space` equipped with a decomposition as an internal direct
sum has an orthonormal basis indexed by `fin n` and subordinate to that direct sum. -/
irreducible_def DirectSum.IsInternal.subordinateOrthonormalBasis
    (hV' : OrthogonalFamily 𝕜 (fun i => V i) fun i => (V i).subtypeₗᵢ) :
    OrthonormalBasis (Fin n) 𝕜 E :=
  (hV.collectedOrthonormalBasis hV' fun i => stdOrthonormalBasis 𝕜 (V i)).reindex
    (hV.sigmaOrthonormalBasisIndexEquiv hn hV')
#align direct_sum.is_internal.subordinate_orthonormal_basis DirectSum.IsInternal.subordinateOrthonormalBasis
-/

#print DirectSum.IsInternal.subordinateOrthonormalBasisIndex /-
/-- An `n`-dimensional `inner_product_space` equipped with a decomposition as an internal direct
sum has an orthonormal basis indexed by `fin n` and subordinate to that direct sum. This function
provides the mapping by which it is subordinate. -/
irreducible_def DirectSum.IsInternal.subordinateOrthonormalBasisIndex (a : Fin n)
    (hV' : OrthogonalFamily 𝕜 (fun i => V i) fun i => (V i).subtypeₗᵢ) : ι :=
  ((hV.sigmaOrthonormalBasisIndexEquiv hn hV').symm a).1
#align direct_sum.is_internal.subordinate_orthonormal_basis_index DirectSum.IsInternal.subordinateOrthonormalBasisIndex
-/

#print DirectSum.IsInternal.subordinateOrthonormalBasis_subordinate /-
/-- The basis constructed in `orthogonal_family.subordinate_orthonormal_basis` is subordinate to
the `orthogonal_family` in question. -/
theorem DirectSum.IsInternal.subordinateOrthonormalBasis_subordinate (a : Fin n)
    (hV' : OrthogonalFamily 𝕜 (fun i => V i) fun i => (V i).subtypeₗᵢ) :
    hV.subordinateOrthonormalBasis hn hV' a ∈ V (hV.subordinateOrthonormalBasisIndex hn a hV') := by
  simpa only [DirectSum.IsInternal.subordinateOrthonormalBasis, OrthonormalBasis.coe_reindex,
    DirectSum.IsInternal.subordinateOrthonormalBasisIndex] using
    hV.collected_orthonormal_basis_mem hV' (fun i => stdOrthonormalBasis 𝕜 (V i))
      ((hV.sigma_orthonormal_basis_index_equiv hn hV').symm a)
#align direct_sum.is_internal.subordinate_orthonormal_basis_subordinate DirectSum.IsInternal.subordinateOrthonormalBasis_subordinate
-/

end SubordinateOrthonormalBasis

end FiniteDimensional

attribute [local instance] fact_finite_dimensional_of_finrank_eq_succ

#print OrthonormalBasis.fromOrthogonalSpanSingleton /-
/-- Given a natural number `n` one less than the `finrank` of a finite-dimensional inner product
space, there exists an isometry from the orthogonal complement of a nonzero singleton to
`euclidean_space 𝕜 (fin n)`. -/
def OrthonormalBasis.fromOrthogonalSpanSingleton (n : ℕ) [Fact (finrank 𝕜 E = n + 1)] {v : E}
    (hv : v ≠ 0) : OrthonormalBasis (Fin n) 𝕜 (𝕜 ∙ v)ᗮ :=
  (stdOrthonormalBasis _ _).reindex <| finCongr <| finrank_orthogonal_span_singleton hv
#align orthonormal_basis.from_orthogonal_span_singleton OrthonormalBasis.fromOrthogonalSpanSingleton
-/

section LinearIsometry

variable {V : Type _} [NormedAddCommGroup V] [InnerProductSpace 𝕜 V] [FiniteDimensional 𝕜 V]

variable {S : Submodule 𝕜 V} {L : S →ₗᵢ[𝕜] V}

open FiniteDimensional

#print LinearIsometry.extend /-
/-- Let `S` be a subspace of a finite-dimensional complex inner product space `V`.  A linear
isometry mapping `S` into `V` can be extended to a full isometry of `V`.

TODO:  The case when `S` is a finite-dimensional subspace of an infinite-dimensional `V`.-/
noncomputable def LinearIsometry.extend (L : S →ₗᵢ[𝕜] V) : V →ₗᵢ[𝕜] V :=
  by
  -- Build an isometry from Sᗮ to L(S)ᗮ through euclidean_space
  let d := finrank 𝕜 Sᗮ
  have dim_S_perp : finrank 𝕜 Sᗮ = d := rfl
  let LS := L.to_linear_map.range
  have E : Sᗮ ≃ₗᵢ[𝕜] LSᗮ := by
    have dim_LS_perp : finrank 𝕜 LSᗮ = d
    calc
      finrank 𝕜 LSᗮ = finrank 𝕜 V - finrank 𝕜 LS := by
        simp only [← LS.finrank_add_finrank_orthogonal, add_tsub_cancel_left]
      _ = finrank 𝕜 V - finrank 𝕜 S := by simp only [LinearMap.finrank_range_of_inj L.injective]
      _ = finrank 𝕜 Sᗮ := by simp only [← S.finrank_add_finrank_orthogonal, add_tsub_cancel_left]
    exact
      (stdOrthonormalBasis 𝕜 Sᗮ).repr.trans
        ((stdOrthonormalBasis 𝕜 LSᗮ).reindex <| finCongr dim_LS_perp).repr.symm
  let L3 := LSᗮ.subtypeₗᵢ.comp E.to_linear_isometry
  -- Project onto S and Sᗮ
  haveI : CompleteSpace S := FiniteDimensional.complete 𝕜 S
  haveI : CompleteSpace V := FiniteDimensional.complete 𝕜 V
  let p1 := (orthogonalProjection S).toLinearMap
  let p2 := (orthogonalProjection Sᗮ).toLinearMap
  -- Build a linear map from the isometries on S and Sᗮ
  let M := L.to_linear_map.comp p1 + L3.to_linear_map.comp p2
  -- Prove that M is an isometry
  have M_norm_map : ∀ x : V, ‖M x‖ = ‖x‖ := by
    intro x
    -- Apply M to the orthogonal decomposition of x
    have Mx_decomp : M x = L (p1 x) + L3 (p2 x) := by
      simp only [LinearMap.add_apply, LinearMap.comp_apply, LinearMap.comp_apply,
        LinearIsometry.coe_toLinearMap]
    -- Mx_decomp is the orthogonal decomposition of M x
    have Mx_orth : ⟪L (p1 x), L3 (p2 x)⟫ = 0 :=
      by
      have Lp1x : L (p1 x) ∈ L.to_linear_map.range :=
        LinearMap.mem_range_self L.to_linear_map (p1 x)
      have Lp2x : L3 (p2 x) ∈ L.to_linear_map.rangeᗮ :=
        by
        simp only [L3, LinearIsometry.coe_comp, Function.comp_apply, Submodule.coe_subtypeₗᵢ, ←
          Submodule.range_subtype LSᗮ]
        apply LinearMap.mem_range_self
      apply Submodule.inner_right_of_mem_orthogonal Lp1x Lp2x
    -- Apply the Pythagorean theorem and simplify
    rw [← sq_eq_sq (norm_nonneg _) (norm_nonneg _), norm_sq_eq_add_norm_sq_projection x S]
    simp only [sq, Mx_decomp]
    rw [norm_add_sq_eq_norm_sq_add_norm_sq_of_inner_eq_zero (L (p1 x)) (L3 (p2 x)) Mx_orth]
    simp only [LinearIsometry.norm_map, p1, p2, ContinuousLinearMap.toLinearMap_eq_coe,
      add_left_inj, mul_eq_mul_left_iff, norm_eq_zero, true_or_iff, eq_self_iff_true,
      ContinuousLinearMap.coe_coe, Submodule.coe_norm, Submodule.coe_eq_zero]
  exact
    { toLinearMap := M
      norm_map' := M_norm_map }
#align linear_isometry.extend LinearIsometry.extend
-/

#print LinearIsometry.extend_apply /-
theorem LinearIsometry.extend_apply (L : S →ₗᵢ[𝕜] V) (s : S) : L.extend s = L s :=
  by
  haveI : CompleteSpace S := FiniteDimensional.complete 𝕜 S
  simp only [LinearIsometry.extend, ContinuousLinearMap.toLinearMap_eq_coe, ←
    LinearIsometry.coe_toLinearMap]
  simp only [add_right_eq_self, LinearIsometry.coe_toLinearMap,
    LinearIsometryEquiv.coe_toLinearIsometry, LinearIsometry.coe_comp, Function.comp_apply,
    orthogonalProjection_mem_subspace_eq_self, LinearMap.coe_comp, ContinuousLinearMap.coe_coe,
    Submodule.coeSubtype, LinearMap.add_apply, Submodule.coe_eq_zero,
    LinearIsometryEquiv.map_eq_zero_iff, Submodule.coe_subtypeₗᵢ,
    orthogonalProjection_mem_subspace_orthogonalComplement_eq_zero, Submodule.orthogonal_orthogonal,
    Submodule.coe_mem]
#align linear_isometry.extend_apply LinearIsometry.extend_apply
-/

end LinearIsometry

section Matrix

open scoped Matrix

variable {m n : Type _}

namespace Matrix

variable [Fintype m] [Fintype n] [DecidableEq n]

#print Matrix.toEuclideanLin /-
/-- `matrix.to_lin'` adapted for `euclidean_space 𝕜 _`. -/
def toEuclideanLin : Matrix m n 𝕜 ≃ₗ[𝕜] EuclideanSpace 𝕜 n →ₗ[𝕜] EuclideanSpace 𝕜 m :=
  Matrix.toLin' ≪≫ₗ
    LinearEquiv.arrowCongr (PiLp.linearEquiv _ 𝕜 fun _ : n => 𝕜).symm
      (PiLp.linearEquiv _ 𝕜 fun _ : m => 𝕜).symm
#align matrix.to_euclidean_lin Matrix.toEuclideanLin
-/

#print Matrix.toEuclideanLin_piLp_equiv_symm /-
@[simp]
theorem toEuclideanLin_piLp_equiv_symm (A : Matrix m n 𝕜) (x : n → 𝕜) :
    A.toEuclideanLin ((PiLp.equiv _ _).symm x) = (PiLp.equiv _ _).symm (A.toLin' x) :=
  rfl
#align matrix.to_euclidean_lin_pi_Lp_equiv_symm Matrix.toEuclideanLin_piLp_equiv_symm
-/

#print Matrix.piLp_equiv_toEuclideanLin /-
@[simp]
theorem piLp_equiv_toEuclideanLin (A : Matrix m n 𝕜) (x : EuclideanSpace 𝕜 n) :
    PiLp.equiv _ _ (A.toEuclideanLin x) = A.toLin' (PiLp.equiv _ _ x) :=
  rfl
#align matrix.pi_Lp_equiv_to_euclidean_lin Matrix.piLp_equiv_toEuclideanLin
-/

#print Matrix.toEuclideanLin_eq_toLin /-
-- `matrix.to_euclidean_lin` is the same as `matrix.to_lin` applied to `pi_Lp.basis_fun`,
theorem toEuclideanLin_eq_toLin :
    (toEuclideanLin : Matrix m n 𝕜 ≃ₗ[𝕜] _) =
      Matrix.toLin (PiLp.basisFun _ _ _) (PiLp.basisFun _ _ _) :=
  rfl
#align matrix.to_euclidean_lin_eq_to_lin Matrix.toEuclideanLin_eq_toLin
-/

end Matrix

local notation "⟪" x ", " y "⟫ₑ" => @inner 𝕜 _ _ ((PiLp.equiv 2 _).symm x) ((PiLp.equiv 2 _).symm y)

#print inner_matrix_row_row /-
/-- The inner product of a row of `A` and a row of `B` is an entry of `B ⬝ Aᴴ`. -/
theorem inner_matrix_row_row [Fintype n] (A B : Matrix m n 𝕜) (i j : m) :
    ⟪A i, B j⟫ₑ = (B ⬝ Aᴴ) j i := by
  simp_rw [EuclideanSpace.inner_piLp_equiv_symm, Matrix.mul_apply', Matrix.dotProduct_comm,
    Matrix.conjTranspose_apply, Pi.star_def]
#align inner_matrix_row_row inner_matrix_row_row
-/

#print inner_matrix_col_col /-
/-- The inner product of a column of `A` and a column of `B` is an entry of `Aᴴ ⬝ B`. -/
theorem inner_matrix_col_col [Fintype m] (A B : Matrix m n 𝕜) (i j : n) :
    ⟪Aᵀ i, Bᵀ j⟫ₑ = (Aᴴ ⬝ B) i j :=
  rfl
#align inner_matrix_col_col inner_matrix_col_col
-/

end Matrix

