/-
Copyright (c) 2020 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module analysis.normed_space.mazur_ulam
! leanprover-community/mathlib commit 1b0a28e1c93409dbf6d69526863cd9984ef652ce
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Instances.RealVectorSpace
import Mathbin.Analysis.NormedSpace.AffineIsometry

/-!
# Mazur-Ulam Theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Mazur-Ulam theorem states that an isometric bijection between two normed affine spaces over `ℝ` is
affine. We formalize it in three definitions:

* `isometry_equiv.to_real_linear_isometry_equiv_of_map_zero` : given `E ≃ᵢ F` sending `0` to `0`,
  returns `E ≃ₗᵢ[ℝ] F` with the same `to_fun` and `inv_fun`;
* `isometry_equiv.to_real_linear_isometry_equiv` : given `f : E ≃ᵢ F`, returns a linear isometry
  equivalence `g : E ≃ₗᵢ[ℝ] F` with `g x = f x - f 0`.
* `isometry_equiv.to_real_affine_isometry_equiv` : given `f : PE ≃ᵢ PF`, returns an affine isometry
  equivalence `g : PE ≃ᵃⁱ[ℝ] PF` whose underlying `isometry_equiv` is `f`

The formalization is based on [Jussi Väisälä, *A Proof of the Mazur-Ulam Theorem*][Vaisala_2003].

## Tags

isometry, affine map, linear map
-/


variable {E PE F PF : Type _} [NormedAddCommGroup E] [NormedSpace ℝ E] [MetricSpace PE]
  [NormedAddTorsor E PE] [NormedAddCommGroup F] [NormedSpace ℝ F] [MetricSpace PF]
  [NormedAddTorsor F PF]

open Set AffineMap AffineIsometryEquiv

noncomputable section

namespace IsometryEquiv

#print IsometryEquiv.midpoint_fixed /-
/-- If an isometric self-homeomorphism of a normed vector space over `ℝ` fixes `x` and `y`,
then it fixes the midpoint of `[x, y]`. This is a lemma for a more general Mazur-Ulam theorem,
see below. -/
theorem midpoint_fixed {x y : PE} :
    ∀ e : PE ≃ᵢ PE, e x = x → e y = y → e (midpoint ℝ x y) = midpoint ℝ x y :=
  by
  set z := midpoint ℝ x y
  -- Consider the set of `e : E ≃ᵢ E` such that `e x = x` and `e y = y`
  set s := {e : PE ≃ᵢ PE | e x = x ∧ e y = y}
  haveI : Nonempty s := ⟨⟨IsometryEquiv.refl PE, rfl, rfl⟩⟩
  -- On the one hand, `e` cannot send the midpoint `z` of `[x, y]` too far
  have h_bdd : BddAbove (range fun e : s => dist (e z) z) :=
    by
    refine' ⟨dist x z + dist x z, forall_range_iff.2 <| Subtype.forall.2 _⟩
    rintro e ⟨hx, hy⟩
    calc
      dist (e z) z ≤ dist (e z) x + dist x z := dist_triangle (e z) x z
      _ = dist (e x) (e z) + dist x z := by rw [hx, dist_comm]
      _ = dist x z + dist x z := by erw [e.dist_eq x z]
  -- On the other hand, consider the map `f : (E ≃ᵢ E) → (E ≃ᵢ E)`
  -- sending each `e` to `R ∘ e⁻¹ ∘ R ∘ e`, where `R` is the point reflection in the
  -- midpoint `z` of `[x, y]`.
  set R : PE ≃ᵢ PE := (point_reflection ℝ z).toIsometryEquiv
  set f : PE ≃ᵢ PE → PE ≃ᵢ PE := fun e => ((e.trans R).trans e.symm).trans R
  -- Note that `f` doubles the value of ``dist (e z) z`
  have hf_dist : ∀ e, dist (f e z) z = 2 * dist (e z) z :=
    by
    intro e
    dsimp [f]
    rw [dist_point_reflection_fixed, ← e.dist_eq, e.apply_symm_apply,
      dist_point_reflection_self_real, dist_comm]
  -- Also note that `f` maps `s` to itself
  have hf_maps_to : maps_to f s s := by
    rintro e ⟨hx, hy⟩
    constructor <;> simp [hx, hy, e.symm_apply_eq.2 hx.symm, e.symm_apply_eq.2 hy.symm]
  -- Therefore, `dist (e z) z = 0` for all `e ∈ s`.
  set c := ⨆ e : s, dist ((e : PE ≃ᵢ PE) z) z
  have : c ≤ c / 2 := by
    apply ciSup_le
    rintro ⟨e, he⟩
    simp only [Subtype.coe_mk, le_div_iff' (zero_lt_two' ℝ), ← hf_dist]
    exact le_ciSup h_bdd ⟨f e, hf_maps_to he⟩
  replace : c ≤ 0; · linarith
  refine' fun e hx hy => dist_le_zero.1 (le_trans _ this)
  exact le_ciSup h_bdd ⟨e, hx, hy⟩
#align isometry_equiv.midpoint_fixed IsometryEquiv.midpoint_fixed
-/

#print IsometryEquiv.map_midpoint /-
/-- A bijective isometry sends midpoints to midpoints. -/
theorem map_midpoint (f : PE ≃ᵢ PF) (x y : PE) : f (midpoint ℝ x y) = midpoint ℝ (f x) (f y) :=
  by
  set e : PE ≃ᵢ PE :=
    ((f.trans <| (point_reflection ℝ <| midpoint ℝ (f x) (f y)).toIsometryEquiv).trans f.symm).trans
      (point_reflection ℝ <| midpoint ℝ x y).toIsometryEquiv
  have hx : e x = x := by simp
  have hy : e y = y := by simp
  have hm := e.midpoint_fixed hx hy
  simp only [e, trans_apply] at hm 
  rwa [← eq_symm_apply, to_isometry_equiv_symm, point_reflection_symm, coe_to_isometry_equiv,
    coe_to_isometry_equiv, point_reflection_self, symm_apply_eq, point_reflection_fixed_iff] at hm 
#align isometry_equiv.map_midpoint IsometryEquiv.map_midpoint
-/

/-!
Since `f : PE ≃ᵢ PF` sends midpoints to midpoints, it is an affine map.
We define a conversion to a `continuous_linear_equiv` first, then a conversion to an `affine_map`.
-/


#print IsometryEquiv.toRealLinearIsometryEquivOfMapZero /-
/-- **Mazur-Ulam Theorem**: if `f` is an isometric bijection between two normed vector spaces
over `ℝ` and `f 0 = 0`, then `f` is a linear isometry equivalence. -/
def toRealLinearIsometryEquivOfMapZero (f : E ≃ᵢ F) (h0 : f 0 = 0) : E ≃ₗᵢ[ℝ] F :=
  { (AddMonoidHom.ofMapMidpoint ℝ ℝ f h0 f.map_midpoint).toRealLinearMap f.Continuous, f with
    norm_map' := fun x => show ‖f x‖ = ‖x‖ by simp only [← dist_zero_right, ← h0, f.dist_eq] }
#align isometry_equiv.to_real_linear_isometry_equiv_of_map_zero IsometryEquiv.toRealLinearIsometryEquivOfMapZero
-/

#print IsometryEquiv.coe_to_real_linear_equiv_of_map_zero /-
@[simp]
theorem coe_to_real_linear_equiv_of_map_zero (f : E ≃ᵢ F) (h0 : f 0 = 0) :
    ⇑(f.toRealLinearIsometryEquivOfMapZero h0) = f :=
  rfl
#align isometry_equiv.coe_to_real_linear_equiv_of_map_zero IsometryEquiv.coe_to_real_linear_equiv_of_map_zero
-/

#print IsometryEquiv.coe_to_real_linear_equiv_of_map_zero_symm /-
@[simp]
theorem coe_to_real_linear_equiv_of_map_zero_symm (f : E ≃ᵢ F) (h0 : f 0 = 0) :
    ⇑(f.toRealLinearIsometryEquivOfMapZero h0).symm = f.symm :=
  rfl
#align isometry_equiv.coe_to_real_linear_equiv_of_map_zero_symm IsometryEquiv.coe_to_real_linear_equiv_of_map_zero_symm
-/

#print IsometryEquiv.toRealLinearIsometryEquiv /-
/-- **Mazur-Ulam Theorem**: if `f` is an isometric bijection between two normed vector spaces
over `ℝ`, then `x ↦ f x - f 0` is a linear isometry equivalence. -/
def toRealLinearIsometryEquiv (f : E ≃ᵢ F) : E ≃ₗᵢ[ℝ] F :=
  (f.trans (IsometryEquiv.addRight (f 0)).symm).toRealLinearIsometryEquivOfMapZero
    (by simpa only [sub_eq_add_neg] using sub_self (f 0))
#align isometry_equiv.to_real_linear_isometry_equiv IsometryEquiv.toRealLinearIsometryEquiv
-/

#print IsometryEquiv.to_real_linear_equiv_apply /-
@[simp]
theorem to_real_linear_equiv_apply (f : E ≃ᵢ F) (x : E) :
    (f.toRealLinearIsometryEquiv : E → F) x = f x - f 0 :=
  (sub_eq_add_neg (f x) (f 0)).symm
#align isometry_equiv.to_real_linear_equiv_apply IsometryEquiv.to_real_linear_equiv_apply
-/

#print IsometryEquiv.toRealLinearIsometryEquiv_symm_apply /-
@[simp]
theorem toRealLinearIsometryEquiv_symm_apply (f : E ≃ᵢ F) (y : F) :
    (f.toRealLinearIsometryEquiv.symm : F → E) y = f.symm (y + f 0) :=
  rfl
#align isometry_equiv.to_real_linear_isometry_equiv_symm_apply IsometryEquiv.toRealLinearIsometryEquiv_symm_apply
-/

#print IsometryEquiv.toRealAffineIsometryEquiv /-
/-- **Mazur-Ulam Theorem**: if `f` is an isometric bijection between two normed add-torsors over
normed vector spaces over `ℝ`, then `f` is an affine isometry equivalence. -/
def toRealAffineIsometryEquiv (f : PE ≃ᵢ PF) : PE ≃ᵃⁱ[ℝ] PF :=
  AffineIsometryEquiv.mk' f
    ((vaddConst (Classical.arbitrary PE)).trans <|
        f.trans (vaddConst (f <| Classical.arbitrary PE)).symm).toRealLinearIsometryEquiv
    (Classical.arbitrary PE) fun p => by simp
#align isometry_equiv.to_real_affine_isometry_equiv IsometryEquiv.toRealAffineIsometryEquiv
-/

#print IsometryEquiv.coeFn_toRealAffineIsometryEquiv /-
@[simp]
theorem coeFn_toRealAffineIsometryEquiv (f : PE ≃ᵢ PF) : ⇑f.toRealAffineIsometryEquiv = f :=
  rfl
#align isometry_equiv.coe_fn_to_real_affine_isometry_equiv IsometryEquiv.coeFn_toRealAffineIsometryEquiv
-/

#print IsometryEquiv.coe_toRealAffineIsometryEquiv /-
@[simp]
theorem coe_toRealAffineIsometryEquiv (f : PE ≃ᵢ PF) :
    f.toRealAffineIsometryEquiv.toIsometryEquiv = f := by ext; rfl
#align isometry_equiv.coe_to_real_affine_isometry_equiv IsometryEquiv.coe_toRealAffineIsometryEquiv
-/

end IsometryEquiv

