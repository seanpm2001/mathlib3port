/-
Copyright (c) 2021 Frédéric Dupuis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Frédéric Dupuis

! This file was ported from Lean 3 source module analysis.normed_space.star.basic
! leanprover-community/mathlib commit aa6669832974f87406a3d9d70fc5707a60546207
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Analysis.Normed.Group.Hom
import Mathbin.Analysis.NormedSpace.Basic
import Mathbin.Analysis.NormedSpace.LinearIsometry
import Mathbin.Algebra.Star.SelfAdjoint
import Mathbin.Algebra.Star.Unitary
import Mathbin.Topology.Algebra.StarSubalgebra
import Mathbin.Topology.Algebra.Module.Star

/-!
# Normed star rings and algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A normed star group is a normed group with a compatible `star` which is isometric.

A C⋆-ring is a normed star group that is also a ring and that verifies the stronger
condition `‖x⋆ * x‖ = ‖x‖^2` for all `x`.  If a C⋆-ring is also a star algebra, then it is a
C⋆-algebra.

To get a C⋆-algebra `E` over field `𝕜`, use
`[normed_field 𝕜] [star_ring 𝕜] [normed_ring E] [star_ring E] [cstar_ring E]
 [normed_algebra 𝕜 E] [star_module 𝕜 E]`.

## TODO

- Show that `‖x⋆ * x‖ = ‖x‖^2` is equivalent to `‖x⋆ * x‖ = ‖x⋆‖ * ‖x‖`, which is used as the
  definition of C*-algebras in some sources (e.g. Wikipedia).

-/


open scoped Topology

local postfix:max "⋆" => star

#print NormedStarGroup /-
/-- A normed star group is a normed group with a compatible `star` which is isometric. -/
class NormedStarGroup (E : Type _) [SeminormedAddCommGroup E] [StarAddMonoid E] : Prop where
  norm_star : ∀ x : E, ‖x⋆‖ = ‖x‖
#align normed_star_group NormedStarGroup
-/

export NormedStarGroup (norm_star)

attribute [simp] norm_star

variable {𝕜 E α : Type _}

section NormedStarGroup

variable [SeminormedAddCommGroup E] [StarAddMonoid E] [NormedStarGroup E]

#print nnnorm_star /-
@[simp]
theorem nnnorm_star (x : E) : ‖star x‖₊ = ‖x‖₊ :=
  Subtype.ext <| norm_star _
#align nnnorm_star nnnorm_star
-/

#print starNormedAddGroupHom /-
/-- The `star` map in a normed star group is a normed group homomorphism. -/
def starNormedAddGroupHom : NormedAddGroupHom E E :=
  { starAddEquiv with bound' := ⟨1, fun v => le_trans (norm_star _).le (one_mul _).symm.le⟩ }
#align star_normed_add_group_hom starNormedAddGroupHom
-/

#print star_isometry /-
/-- The `star` map in a normed star group is an isometry -/
theorem star_isometry : Isometry (star : E → E) :=
  show Isometry starAddEquiv from
    AddMonoidHomClass.isometry_of_norm starAddEquiv (show ∀ x, ‖x⋆‖ = ‖x‖ from norm_star)
#align star_isometry star_isometry
-/

#print NormedStarGroup.to_continuousStar /-
instance (priority := 100) NormedStarGroup.to_continuousStar : ContinuousStar E :=
  ⟨star_isometry.Continuous⟩
#align normed_star_group.to_has_continuous_star NormedStarGroup.to_continuousStar
-/

end NormedStarGroup

#print RingHomIsometric.starRingEnd /-
instance RingHomIsometric.starRingEnd [NormedCommRing E] [StarRing E] [NormedStarGroup E] :
    RingHomIsometric (starRingEnd E) :=
  ⟨norm_star⟩
#align ring_hom_isometric.star_ring_end RingHomIsometric.starRingEnd
-/

#print CstarRing /-
/-- A C*-ring is a normed star ring that satifies the stronger condition `‖x⋆ * x‖ = ‖x‖^2`
for every `x`. -/
class CstarRing (E : Type _) [NonUnitalNormedRing E] [StarRing E] : Prop where
  norm_star_mul_self : ∀ {x : E}, ‖x⋆ * x‖ = ‖x‖ * ‖x‖
#align cstar_ring CstarRing
-/

instance : CstarRing ℝ where norm_star_mul_self x := by simp only [star, id.def, norm_mul]

namespace CstarRing

section NonUnital

variable [NonUnitalNormedRing E] [StarRing E] [CstarRing E]

#print CstarRing.to_normedStarGroup /-
-- see Note [lower instance priority]
/-- In a C*-ring, star preserves the norm. -/
instance (priority := 100) to_normedStarGroup : NormedStarGroup E :=
  ⟨by
    intro x
    by_cases htriv : x = 0
    · simp only [htriv, star_zero]
    · have hnt : 0 < ‖x‖ := norm_pos_iff.mpr htriv
      have hnt_star : 0 < ‖x⋆‖ :=
        norm_pos_iff.mpr ((AddEquiv.map_ne_zero_iff starAddEquiv).mpr htriv)
      have h₁ :=
        calc
          ‖x‖ * ‖x‖ = ‖x⋆ * x‖ := norm_star_mul_self.symm
          _ ≤ ‖x⋆‖ * ‖x‖ := norm_mul_le _ _
      have h₂ :=
        calc
          ‖x⋆‖ * ‖x⋆‖ = ‖x * x⋆‖ := by rw [← norm_star_mul_self, star_star]
          _ ≤ ‖x‖ * ‖x⋆‖ := norm_mul_le _ _
      exact le_antisymm (le_of_mul_le_mul_right h₂ hnt_star) (le_of_mul_le_mul_right h₁ hnt)⟩
#align cstar_ring.to_normed_star_group CstarRing.to_normedStarGroup
-/

#print CstarRing.norm_self_mul_star /-
theorem norm_self_mul_star {x : E} : ‖x * x⋆‖ = ‖x‖ * ‖x‖ := by nth_rw 1 [← star_star x];
  simp only [norm_star_mul_self, norm_star]
#align cstar_ring.norm_self_mul_star CstarRing.norm_self_mul_star
-/

#print CstarRing.norm_star_mul_self' /-
theorem norm_star_mul_self' {x : E} : ‖x⋆ * x‖ = ‖x⋆‖ * ‖x‖ := by rw [norm_star_mul_self, norm_star]
#align cstar_ring.norm_star_mul_self' CstarRing.norm_star_mul_self'
-/

#print CstarRing.nnnorm_self_mul_star /-
theorem nnnorm_self_mul_star {x : E} : ‖x * star x‖₊ = ‖x‖₊ * ‖x‖₊ :=
  Subtype.ext norm_self_mul_star
#align cstar_ring.nnnorm_self_mul_star CstarRing.nnnorm_self_mul_star
-/

#print CstarRing.nnnorm_star_mul_self /-
theorem nnnorm_star_mul_self {x : E} : ‖x⋆ * x‖₊ = ‖x‖₊ * ‖x‖₊ :=
  Subtype.ext norm_star_mul_self
#align cstar_ring.nnnorm_star_mul_self CstarRing.nnnorm_star_mul_self
-/

#print CstarRing.star_mul_self_eq_zero_iff /-
@[simp]
theorem star_mul_self_eq_zero_iff (x : E) : star x * x = 0 ↔ x = 0 := by
  rw [← norm_eq_zero, norm_star_mul_self]; exact mul_self_eq_zero.trans norm_eq_zero
#align cstar_ring.star_mul_self_eq_zero_iff CstarRing.star_mul_self_eq_zero_iff
-/

#print CstarRing.star_mul_self_ne_zero_iff /-
theorem star_mul_self_ne_zero_iff (x : E) : star x * x ≠ 0 ↔ x ≠ 0 := by
  simp only [Ne.def, star_mul_self_eq_zero_iff]
#align cstar_ring.star_mul_self_ne_zero_iff CstarRing.star_mul_self_ne_zero_iff
-/

#print CstarRing.mul_star_self_eq_zero_iff /-
@[simp]
theorem mul_star_self_eq_zero_iff (x : E) : x * star x = 0 ↔ x = 0 := by
  simpa only [star_eq_zero, star_star] using @star_mul_self_eq_zero_iff _ _ _ _ (star x)
#align cstar_ring.mul_star_self_eq_zero_iff CstarRing.mul_star_self_eq_zero_iff
-/

#print CstarRing.mul_star_self_ne_zero_iff /-
theorem mul_star_self_ne_zero_iff (x : E) : x * star x ≠ 0 ↔ x ≠ 0 := by
  simp only [Ne.def, mul_star_self_eq_zero_iff]
#align cstar_ring.mul_star_self_ne_zero_iff CstarRing.mul_star_self_ne_zero_iff
-/

end NonUnital

section ProdPi

variable {ι R₁ R₂ : Type _} {R : ι → Type _}

variable [NonUnitalNormedRing R₁] [StarRing R₁] [CstarRing R₁]

variable [NonUnitalNormedRing R₂] [StarRing R₂] [CstarRing R₂]

variable [∀ i, NonUnitalNormedRing (R i)] [∀ i, StarRing (R i)]

#print Pi.starRing' /-
/-- This instance exists to short circuit type class resolution because of problems with
inference involving Π-types. -/
instance Pi.starRing' : StarRing (∀ i, R i) :=
  inferInstance
#align pi.star_ring' Pi.starRing'
-/

variable [Fintype ι] [∀ i, CstarRing (R i)]

#print Prod.cstarRing /-
instance Prod.cstarRing : CstarRing (R₁ × R₂)
    where norm_star_mul_self x := by
    unfold norm
    simp only [Prod.fst_mul, Prod.fst_star, Prod.snd_mul, Prod.snd_star, norm_star_mul_self, ← sq]
    refine' le_antisymm _ _
    · refine' max_le _ _ <;> rw [sq_le_sq, abs_of_nonneg (norm_nonneg _)]
      exact (le_max_left _ _).trans (le_abs_self _)
      exact (le_max_right _ _).trans (le_abs_self _)
    · rw [le_sup_iff]
      rcases le_total ‖x.fst‖ ‖x.snd‖ with (h | h) <;> simp [h]
#align prod.cstar_ring Prod.cstarRing
-/

#print Pi.cstarRing /-
instance Pi.cstarRing : CstarRing (∀ i, R i)
    where norm_star_mul_self x :=
    by
    simp only [norm, Pi.mul_apply, Pi.star_apply, nnnorm_star_mul_self, ← sq]
    norm_cast
    exact
      (Finset.comp_sup_eq_sup_comp_of_is_total (fun x : NNReal => x ^ 2)
          (fun x y h => by simpa only [sq] using mul_le_mul' h h) (by simp)).symm
#align pi.cstar_ring Pi.cstarRing
-/

#print Pi.cstarRing' /-
instance Pi.cstarRing' : CstarRing (ι → R₁) :=
  Pi.cstarRing
#align pi.cstar_ring' Pi.cstarRing'
-/

end ProdPi

section Unital

variable [NormedRing E] [StarRing E] [CstarRing E]

#print CstarRing.norm_one /-
@[simp]
theorem norm_one [Nontrivial E] : ‖(1 : E)‖ = 1 :=
  by
  have : 0 < ‖(1 : E)‖ := norm_pos_iff.mpr one_ne_zero
  rw [← mul_left_inj' this.ne', ← norm_star_mul_self, mul_one, star_one, one_mul]
#align cstar_ring.norm_one CstarRing.norm_one
-/

-- see Note [lower instance priority]
instance (priority := 100) [Nontrivial E] : NormOneClass E :=
  ⟨norm_one⟩

#print CstarRing.norm_coe_unitary /-
theorem norm_coe_unitary [Nontrivial E] (U : unitary E) : ‖(U : E)‖ = 1 := by
  rw [← sq_eq_sq (norm_nonneg _) zero_le_one, one_pow 2, sq, ← CstarRing.norm_star_mul_self,
    unitary.coe_star_mul_self, CstarRing.norm_one]
#align cstar_ring.norm_coe_unitary CstarRing.norm_coe_unitary
-/

#print CstarRing.norm_of_mem_unitary /-
@[simp]
theorem norm_of_mem_unitary [Nontrivial E] {U : E} (hU : U ∈ unitary E) : ‖U‖ = 1 :=
  norm_coe_unitary ⟨U, hU⟩
#align cstar_ring.norm_of_mem_unitary CstarRing.norm_of_mem_unitary
-/

#print CstarRing.norm_coe_unitary_mul /-
@[simp]
theorem norm_coe_unitary_mul (U : unitary E) (A : E) : ‖(U : E) * A‖ = ‖A‖ :=
  by
  nontriviality E
  refine' le_antisymm _ _
  ·
    calc
      _ ≤ ‖(U : E)‖ * ‖A‖ := norm_mul_le _ _
      _ = ‖A‖ := by rw [norm_coe_unitary, one_mul]
  ·
    calc
      _ = ‖(U : E)⋆ * U * A‖ := by rw [unitary.coe_star_mul_self U, one_mul]
      _ ≤ ‖(U : E)⋆‖ * ‖(U : E) * A‖ := by rw [mul_assoc]; exact norm_mul_le _ _
      _ = ‖(U : E) * A‖ := by rw [norm_star, norm_coe_unitary, one_mul]
#align cstar_ring.norm_coe_unitary_mul CstarRing.norm_coe_unitary_mul
-/

#print CstarRing.norm_unitary_smul /-
@[simp]
theorem norm_unitary_smul (U : unitary E) (A : E) : ‖U • A‖ = ‖A‖ :=
  norm_coe_unitary_mul U A
#align cstar_ring.norm_unitary_smul CstarRing.norm_unitary_smul
-/

#print CstarRing.norm_mem_unitary_mul /-
theorem norm_mem_unitary_mul {U : E} (A : E) (hU : U ∈ unitary E) : ‖U * A‖ = ‖A‖ :=
  norm_coe_unitary_mul ⟨U, hU⟩ A
#align cstar_ring.norm_mem_unitary_mul CstarRing.norm_mem_unitary_mul
-/

#print CstarRing.norm_mul_coe_unitary /-
@[simp]
theorem norm_mul_coe_unitary (A : E) (U : unitary E) : ‖A * U‖ = ‖A‖ :=
  calc
    _ = ‖((U : E)⋆ * A⋆)⋆‖ := by simp only [star_star, star_mul]
    _ = ‖(U : E)⋆ * A⋆‖ := by rw [norm_star]
    _ = ‖A⋆‖ := (norm_mem_unitary_mul (star A) (unitary.star_mem U.Prop))
    _ = ‖A‖ := norm_star _
#align cstar_ring.norm_mul_coe_unitary CstarRing.norm_mul_coe_unitary
-/

#print CstarRing.norm_mul_mem_unitary /-
theorem norm_mul_mem_unitary (A : E) {U : E} (hU : U ∈ unitary E) : ‖A * U‖ = ‖A‖ :=
  norm_mul_coe_unitary A ⟨U, hU⟩
#align cstar_ring.norm_mul_mem_unitary CstarRing.norm_mul_mem_unitary
-/

end Unital

end CstarRing

#print IsSelfAdjoint.nnnorm_pow_two_pow /-
theorem IsSelfAdjoint.nnnorm_pow_two_pow [NormedRing E] [StarRing E] [CstarRing E] {x : E}
    (hx : IsSelfAdjoint x) (n : ℕ) : ‖x ^ 2 ^ n‖₊ = ‖x‖₊ ^ 2 ^ n :=
  by
  induction' n with k hk
  · simp only [pow_zero, pow_one]
  · rw [pow_succ, pow_mul', sq]
    nth_rw 1 [← self_adjoint.mem_iff.mp hx]
    rw [← star_pow, CstarRing.nnnorm_star_mul_self, ← sq, hk, pow_mul']
#align is_self_adjoint.nnnorm_pow_two_pow IsSelfAdjoint.nnnorm_pow_two_pow
-/

#print selfAdjoint.nnnorm_pow_two_pow /-
theorem selfAdjoint.nnnorm_pow_two_pow [NormedRing E] [StarRing E] [CstarRing E] (x : selfAdjoint E)
    (n : ℕ) : ‖x ^ 2 ^ n‖₊ = ‖x‖₊ ^ 2 ^ n :=
  x.Prop.nnnorm_pow_two_pow _
#align self_adjoint.nnnorm_pow_two_pow selfAdjoint.nnnorm_pow_two_pow
-/

section starₗᵢ

variable [CommSemiring 𝕜] [StarRing 𝕜]

variable [SeminormedAddCommGroup E] [StarAddMonoid E] [NormedStarGroup E]

variable [Module 𝕜 E] [StarModule 𝕜 E]

variable (𝕜)

#print starₗᵢ /-
/-- `star` bundled as a linear isometric equivalence -/
def starₗᵢ : E ≃ₗᵢ⋆[𝕜] E :=
  { starAddEquiv with
    map_smul' := star_smul
    norm_map' := norm_star }
#align starₗᵢ starₗᵢ
-/

variable {𝕜}

#print coe_starₗᵢ /-
@[simp]
theorem coe_starₗᵢ : (starₗᵢ 𝕜 : E → E) = star :=
  rfl
#align coe_starₗᵢ coe_starₗᵢ
-/

#print starₗᵢ_apply /-
theorem starₗᵢ_apply {x : E} : starₗᵢ 𝕜 x = star x :=
  rfl
#align starₗᵢ_apply starₗᵢ_apply
-/

#print starₗᵢ_toContinuousLinearEquiv /-
@[simp]
theorem starₗᵢ_toContinuousLinearEquiv :
    (starₗᵢ 𝕜 : E ≃ₗᵢ⋆[𝕜] E).toContinuousLinearEquiv = (starL 𝕜 : E ≃L⋆[𝕜] E) :=
  ContinuousLinearEquiv.ext rfl
#align starₗᵢ_to_continuous_linear_equiv starₗᵢ_toContinuousLinearEquiv
-/

end starₗᵢ

namespace StarSubalgebra

#print StarSubalgebra.toNormedAlgebra /-
instance toNormedAlgebra {𝕜 A : Type _} [NormedField 𝕜] [StarRing 𝕜] [SeminormedRing A] [StarRing A]
    [NormedAlgebra 𝕜 A] [StarModule 𝕜 A] (S : StarSubalgebra 𝕜 A) : NormedAlgebra 𝕜 S :=
  @NormedAlgebra.induced _ 𝕜 S A _ (SubringClass.toRing S) S.Algebra _ _ _ S.Subtype
#align star_subalgebra.to_normed_algebra StarSubalgebra.toNormedAlgebra
-/

#print StarSubalgebra.to_cstarRing /-
instance to_cstarRing {R A} [CommRing R] [StarRing R] [NormedRing A] [StarRing A] [CstarRing A]
    [Algebra R A] [StarModule R A] (S : StarSubalgebra R A) : CstarRing S
    where norm_star_mul_self x := @CstarRing.norm_star_mul_self A _ _ _ x
#align star_subalgebra.to_cstar_ring StarSubalgebra.to_cstarRing
-/

end StarSubalgebra

