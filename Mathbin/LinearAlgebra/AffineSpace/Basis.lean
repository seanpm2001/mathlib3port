/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module linear_algebra.affine_space.basis
! leanprover-community/mathlib commit 9d2f0748e6c50d7a2657c564b1ff2c695b39148d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.AffineSpace.Independent
import Mathbin.LinearAlgebra.Basis

/-!
# Affine bases and barycentric coordinates

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Suppose `P` is an affine space modelled on the module `V` over the ring `k`, and `p : ι → P` is an
affine-independent family of points spanning `P`. Given this data, each point `q : P` may be written
uniquely as an affine combination: `q = w₀ p₀ + w₁ p₁ + ⋯` for some (finitely-supported) weights
`wᵢ`. For each `i : ι`, we thus have an affine map `P →ᵃ[k] k`, namely `q ↦ wᵢ`. This family of
maps is known as the family of barycentric coordinates. It is defined in this file.

## The construction

Fixing `i : ι`, and allowing `j : ι` to range over the values `j ≠ i`, we obtain a basis `bᵢ` of `V`
defined by `bᵢ j = p j -ᵥ p i`. Let `fᵢ j : V →ₗ[k] k` be the corresponding dual basis and let
`fᵢ = ∑ j, fᵢ j : V →ₗ[k] k` be the corresponding "sum of all coordinates" form. Then the `i`th
barycentric coordinate of `q : P` is `1 - fᵢ (q -ᵥ p i)`.

## Main definitions

 * `affine_basis`: a structure representing an affine basis of an affine space.
 * `affine_basis.coord`: the map `P →ᵃ[k] k` corresponding to `i : ι`.
 * `affine_basis.coord_apply_eq`: the behaviour of `affine_basis.coord i` on `p i`.
 * `affine_basis.coord_apply_ne`: the behaviour of `affine_basis.coord i` on `p j` when `j ≠ i`.
 * `affine_basis.coord_apply`: the behaviour of `affine_basis.coord i` on `p j` for general `j`.
 * `affine_basis.coord_apply_combination`: the characterisation of `affine_basis.coord i` in terms
    of affine combinations, i.e., `affine_basis.coord i (w₀ p₀ + w₁ p₁ + ⋯) = wᵢ`.

## TODO

 * Construct the affine equivalence between `P` and `{ f : ι →₀ k | f.sum = 1 }`.

-/


open scoped Affine BigOperators

open Set

universe u₁ u₂ u₃ u₄

#print AffineBasis /-
/-- An affine basis is a family of affine-independent points whose span is the top subspace. -/
@[protect_proj]
structure AffineBasis (ι : Type u₁) (k : Type u₂) {V : Type u₃} (P : Type u₄) [AddCommGroup V]
    [affine_space V P] [Ring k] [Module k V] where
  toFun : ι → P
  ind' : AffineIndependent k to_fun
  tot' : affineSpan k (range to_fun) = ⊤
#align affine_basis AffineBasis
-/

variable {ι ι' k V P : Type _} [AddCommGroup V] [affine_space V P]

namespace AffineBasis

section Ring

variable [Ring k] [Module k V] (b : AffineBasis ι k P) {s : Finset ι} {i j : ι} (e : ι ≃ ι')

/-- The unique point in a single-point space is the simplest example of an affine basis. -/
instance : Inhabited (AffineBasis PUnit k PUnit) :=
  ⟨⟨id, affineIndependent_of_subsingleton k id, by simp⟩⟩

#print AffineBasis.funLike /-
instance funLike : FunLike (AffineBasis ι k P) ι fun _ => P
    where
  coe := AffineBasis.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
#align affine_basis.fun_like AffineBasis.funLike
-/

#print AffineBasis.ext /-
@[ext]
theorem ext {b₁ b₂ : AffineBasis ι k P} (h : (b₁ : ι → P) = b₂) : b₁ = b₂ :=
  FunLike.coe_injective h
#align affine_basis.ext AffineBasis.ext
-/

#print AffineBasis.ind /-
theorem ind : AffineIndependent k b :=
  b.ind'
#align affine_basis.ind AffineBasis.ind
-/

#print AffineBasis.tot /-
theorem tot : affineSpan k (range b) = ⊤ :=
  b.tot'
#align affine_basis.tot AffineBasis.tot
-/

#print AffineBasis.nonempty /-
protected theorem nonempty : Nonempty ι :=
  not_isEmpty_iff.mp fun hι => by
    simpa only [@range_eq_empty _ _ hι, AffineSubspace.span_empty, bot_ne_top] using b.tot
#align affine_basis.nonempty AffineBasis.nonempty
-/

#print AffineBasis.reindex /-
/-- Composition of an affine basis and an equivalence of index types. -/
def reindex (e : ι ≃ ι') : AffineBasis ι' k P :=
  ⟨b ∘ e.symm, b.ind.comp_embedding e.symm.toEmbedding, by rw [e.symm.surjective.range_comp];
    exact b.3⟩
#align affine_basis.reindex AffineBasis.reindex
-/

#print AffineBasis.coe_reindex /-
@[simp, norm_cast]
theorem coe_reindex : ⇑(b.reindex e) = b ∘ e.symm :=
  rfl
#align affine_basis.coe_reindex AffineBasis.coe_reindex
-/

#print AffineBasis.reindex_apply /-
@[simp]
theorem reindex_apply (i' : ι') : b.reindex e i' = b (e.symm i') :=
  rfl
#align affine_basis.reindex_apply AffineBasis.reindex_apply
-/

#print AffineBasis.reindex_refl /-
@[simp]
theorem reindex_refl : b.reindex (Equiv.refl _) = b :=
  ext rfl
#align affine_basis.reindex_refl AffineBasis.reindex_refl
-/

#print AffineBasis.basisOf /-
/-- Given an affine basis for an affine space `P`, if we single out one member of the family, we
obtain a linear basis for the model space `V`.

The linear basis corresponding to the singled-out member `i : ι` is indexed by `{j : ι // j ≠ i}`
and its `j`th element is `b j -ᵥ b i`. (See `basis_of_apply`.) -/
noncomputable def basisOf (i : ι) : Basis { j : ι // j ≠ i } k V :=
  Basis.mk ((affineIndependent_iff_linearIndependent_vsub k b i).mp b.ind)
    (by
      suffices
        Submodule.span k (range fun j : { x // x ≠ i } => b ↑j -ᵥ b i) = vectorSpan k (range b) by
        rw [this, ← direction_affineSpan, b.tot, AffineSubspace.direction_top]; exact le_rfl
      conv_rhs => rw [← image_univ]
      rw [vectorSpan_image_eq_span_vsub_set_right_ne k b (mem_univ i)]
      congr
      ext v
      simp)
#align affine_basis.basis_of AffineBasis.basisOf
-/

#print AffineBasis.basisOf_apply /-
@[simp]
theorem basisOf_apply (i : ι) (j : { j : ι // j ≠ i }) : b.basisOf i j = b ↑j -ᵥ b i := by
  simp [basis_of]
#align affine_basis.basis_of_apply AffineBasis.basisOf_apply
-/

#print AffineBasis.basisOf_reindex /-
@[simp]
theorem basisOf_reindex (i : ι') :
    (b.reindex e).basisOf i =
      (b.basisOf <| e.symm i).reindex (e.subtypeEquiv fun _ => e.eq_symm_apply.Not) :=
  by ext j; simp
#align affine_basis.basis_of_reindex AffineBasis.basisOf_reindex
-/

#print AffineBasis.coord /-
/-- The `i`th barycentric coordinate of a point. -/
noncomputable def coord (i : ι) : P →ᵃ[k] k
    where
  toFun q := 1 - (b.basisOf i).sumCoords (q -ᵥ b i)
  linear := -(b.basisOf i).sumCoords
  map_vadd' q v := by
    rw [vadd_vsub_assoc, LinearMap.map_add, vadd_eq_add, LinearMap.neg_apply,
      sub_add_eq_sub_sub_swap, add_comm, sub_eq_add_neg]
#align affine_basis.coord AffineBasis.coord
-/

#print AffineBasis.linear_eq_sumCoords /-
@[simp]
theorem linear_eq_sumCoords (i : ι) : (b.Coord i).linear = -(b.basisOf i).sumCoords :=
  rfl
#align affine_basis.linear_eq_sum_coords AffineBasis.linear_eq_sumCoords
-/

#print AffineBasis.coord_reindex /-
@[simp]
theorem coord_reindex (i : ι') : (b.reindex e).Coord i = b.Coord (e.symm i) :=
  by
  ext
  classical simp [AffineBasis.coord]
#align affine_basis.coord_reindex AffineBasis.coord_reindex
-/

#print AffineBasis.coord_apply_eq /-
@[simp]
theorem coord_apply_eq (i : ι) : b.Coord i (b i) = 1 := by
  simp only [coord, Basis.coe_sumCoords, LinearEquiv.map_zero, LinearEquiv.coe_coe, sub_zero,
    AffineMap.coe_mk, Finsupp.sum_zero_index, vsub_self]
#align affine_basis.coord_apply_eq AffineBasis.coord_apply_eq
-/

#print AffineBasis.coord_apply_ne /-
@[simp]
theorem coord_apply_ne (h : i ≠ j) : b.Coord i (b j) = 0 := by
  rw [coord, AffineMap.coe_mk, ← Subtype.coe_mk j h.symm, ← b.basis_of_apply,
    Basis.sumCoords_self_apply, sub_self]
#align affine_basis.coord_apply_ne AffineBasis.coord_apply_ne
-/

#print AffineBasis.coord_apply /-
theorem coord_apply [DecidableEq ι] (i j : ι) : b.Coord i (b j) = if i = j then 1 else 0 := by
  cases eq_or_ne i j <;> simp [h]
#align affine_basis.coord_apply AffineBasis.coord_apply
-/

#print AffineBasis.coord_apply_combination_of_mem /-
@[simp]
theorem coord_apply_combination_of_mem (hi : i ∈ s) {w : ι → k} (hw : s.Sum w = 1) :
    b.Coord i (s.affineCombination k b w) = w i := by
  classical simp only [coord_apply, hi, Finset.affineCombination_eq_linear_combination, if_true,
    mul_boole, hw, Function.comp_apply, smul_eq_mul, s.sum_ite_eq, s.map_affine_combination b w hw]
#align affine_basis.coord_apply_combination_of_mem AffineBasis.coord_apply_combination_of_mem
-/

#print AffineBasis.coord_apply_combination_of_not_mem /-
@[simp]
theorem coord_apply_combination_of_not_mem (hi : i ∉ s) {w : ι → k} (hw : s.Sum w = 1) :
    b.Coord i (s.affineCombination k b w) = 0 := by
  classical simp only [coord_apply, hi, Finset.affineCombination_eq_linear_combination, if_false,
    mul_boole, hw, Function.comp_apply, smul_eq_mul, s.sum_ite_eq, s.map_affine_combination b w hw]
#align affine_basis.coord_apply_combination_of_not_mem AffineBasis.coord_apply_combination_of_not_mem
-/

#print AffineBasis.sum_coord_apply_eq_one /-
@[simp]
theorem sum_coord_apply_eq_one [Fintype ι] (q : P) : ∑ i, b.Coord i q = 1 :=
  by
  have hq : q ∈ affineSpan k (range b) := by rw [b.tot]; exact AffineSubspace.mem_top k V q
  obtain ⟨w, hw, rfl⟩ := eq_affineCombination_of_mem_affineSpan_of_fintype hq
  convert hw
  ext i
  exact b.coord_apply_combination_of_mem (Finset.mem_univ i) hw
#align affine_basis.sum_coord_apply_eq_one AffineBasis.sum_coord_apply_eq_one
-/

#print AffineBasis.affineCombination_coord_eq_self /-
@[simp]
theorem affineCombination_coord_eq_self [Fintype ι] (q : P) :
    (Finset.univ.affineCombination k b fun i => b.Coord i q) = q :=
  by
  have hq : q ∈ affineSpan k (range b) := by rw [b.tot]; exact AffineSubspace.mem_top k V q
  obtain ⟨w, hw, rfl⟩ := eq_affineCombination_of_mem_affineSpan_of_fintype hq
  congr
  ext i
  exact b.coord_apply_combination_of_mem (Finset.mem_univ i) hw
#align affine_basis.affine_combination_coord_eq_self AffineBasis.affineCombination_coord_eq_self
-/

#print AffineBasis.linear_combination_coord_eq_self /-
/-- A variant of `affine_basis.affine_combination_coord_eq_self` for the special case when the
affine space is a module so we can talk about linear combinations. -/
@[simp]
theorem linear_combination_coord_eq_self [Fintype ι] (b : AffineBasis ι k V) (v : V) :
    ∑ i, b.Coord i v • b i = v :=
  by
  have hb := b.affine_combination_coord_eq_self v
  rwa [finset.univ.affine_combination_eq_linear_combination _ _ (b.sum_coord_apply_eq_one v)] at hb 
#align affine_basis.linear_combination_coord_eq_self AffineBasis.linear_combination_coord_eq_self
-/

#print AffineBasis.ext_elem /-
theorem ext_elem [Finite ι] {q₁ q₂ : P} (h : ∀ i, b.Coord i q₁ = b.Coord i q₂) : q₁ = q₂ :=
  by
  cases nonempty_fintype ι
  rw [← b.affine_combination_coord_eq_self q₁, ← b.affine_combination_coord_eq_self q₂]
  simp only [h]
#align affine_basis.ext_elem AffineBasis.ext_elem
-/

#print AffineBasis.coe_coord_of_subsingleton_eq_one /-
@[simp]
theorem coe_coord_of_subsingleton_eq_one [Subsingleton ι] (i : ι) : (b.Coord i : P → k) = 1 :=
  by
  ext q
  have hp : (range b).Subsingleton := by
    rw [← image_univ]
    apply subsingleton.image
    apply subsingleton_of_subsingleton
  haveI := AffineSubspace.subsingleton_of_subsingleton_span_eq_top hp b.tot
  let s : Finset ι := {i}
  have hi : i ∈ s := by simp
  have hw : s.sum (Function.const ι (1 : k)) = 1 := by simp
  have hq : q = s.affine_combination k b (Function.const ι (1 : k)) := by simp
  rw [Pi.one_apply, hq, b.coord_apply_combination_of_mem hi hw]
#align affine_basis.coe_coord_of_subsingleton_eq_one AffineBasis.coe_coord_of_subsingleton_eq_one
-/

#print AffineBasis.surjective_coord /-
theorem surjective_coord [Nontrivial ι] (i : ι) : Function.Surjective <| b.Coord i := by
  classical
  intro x
  obtain ⟨j, hij⟩ := exists_ne i
  let s : Finset ι := {i, j}
  have hi : i ∈ s := by simp
  have hj : j ∈ s := by simp
  let w : ι → k := fun j' => if j' = i then x else 1 - x
  have hw : s.sum w = 1 := by simp [hij, Finset.sum_ite, Finset.filter_insert, Finset.filter_eq']
  use s.affine_combination k b w
  simp [b.coord_apply_combination_of_mem hi hw]
#align affine_basis.surjective_coord AffineBasis.surjective_coord
-/

#print AffineBasis.coords /-
/-- Barycentric coordinates as an affine map. -/
noncomputable def coords : P →ᵃ[k] ι → k
    where
  toFun q i := b.Coord i q
  linear :=
    { toFun := fun v i => -(b.basisOf i).sumCoords v
      map_add' := fun v w => by ext i; simp only [LinearMap.map_add, Pi.add_apply, neg_add]
      map_smul' := fun t v => by ext i; simpa only [LinearMap.map_smul, Pi.smul_apply, smul_neg] }
  map_vadd' p v := by
    ext i
    simp only [linear_eq_sum_coords, LinearMap.coe_mk, LinearMap.neg_apply, Pi.vadd_apply',
      AffineMap.map_vadd]
#align affine_basis.coords AffineBasis.coords
-/

#print AffineBasis.coords_apply /-
@[simp]
theorem coords_apply (q : P) (i : ι) : b.coords q i = b.Coord i q :=
  rfl
#align affine_basis.coords_apply AffineBasis.coords_apply
-/

end Ring

section DivisionRing

variable [DivisionRing k] [Module k V]

#print AffineBasis.coord_apply_centroid /-
@[simp]
theorem coord_apply_centroid [CharZero k] (b : AffineBasis ι k P) {s : Finset ι} {i : ι}
    (hi : i ∈ s) : b.Coord i (s.centroid k b) = (s.card : k)⁻¹ := by
  rw [Finset.centroid,
    b.coord_apply_combination_of_mem hi (s.sum_centroid_weights_eq_one_of_nonempty _ ⟨i, hi⟩),
    Finset.centroidWeights]
#align affine_basis.coord_apply_centroid AffineBasis.coord_apply_centroid
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (s «expr ⊆ » t) -/
#print AffineBasis.exists_affine_subbasis /-
theorem exists_affine_subbasis {t : Set P} (ht : affineSpan k t = ⊤) :
    ∃ (s : _) (_ : s ⊆ t) (b : AffineBasis (↥s) k P), ⇑b = coe :=
  by
  obtain ⟨s, hst, h_tot, h_ind⟩ := exists_affineIndependent k V t
  refine' ⟨s, hst, ⟨coe, h_ind, _⟩, rfl⟩
  rw [Subtype.range_coe, h_tot, ht]
#align affine_basis.exists_affine_subbasis AffineBasis.exists_affine_subbasis
-/

variable (k V P)

#print AffineBasis.exists_affineBasis /-
theorem exists_affineBasis : ∃ (s : Set P) (b : AffineBasis (↥s) k P), ⇑b = coe :=
  let ⟨s, _, hs⟩ := exists_affine_subbasis (AffineSubspace.span_univ k V P)
  ⟨s, hs⟩
#align affine_basis.exists_affine_basis AffineBasis.exists_affineBasis
-/

end DivisionRing

end AffineBasis

