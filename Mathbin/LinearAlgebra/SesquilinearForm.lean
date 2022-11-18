/-
Copyright (c) 2018 Andreas Swerdlow. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Andreas Swerdlow
-/
import Mathbin.Algebra.Module.LinearMap
import Mathbin.LinearAlgebra.BilinearMap
import Mathbin.Algebra.EuclideanDomain.Instances
import Mathbin.RingTheory.NonZeroDivisors

/-!
# Sesquilinear form

This files provides properties about sesquilinear forms. The maps considered are of the form
`M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R`, where `I₁ : R₁ →+* R` and `I₂ : R₂ →+* R` are ring homomorphisms and
`M₁` is a module over `R₁` and `M₂` is a module over `R₂`.
Sesquilinear forms are the special case that `M₁ = M₂`, `R₁ = R₂ = R`, and `I₁ = ring_hom.id R`.
Taking additionally `I₂ = ring_hom.id R`, then one obtains bilinear forms.

These forms are a special case of the bilinear maps defined in `bilinear_map.lean` and all basic
lemmas about construction and elementary calculations are found there.

## Main declarations

* `is_ortho`: states that two vectors are orthogonal with respect to a sesquilinear form
* `is_symm`, `is_alt`: states that a sesquilinear form is symmetric and alternating, respectively
* `orthogonal_bilin`: provides the orthogonal complement with respect to sesquilinear form

## References

* <https://en.wikipedia.org/wiki/Sesquilinear_form#Over_arbitrary_rings>

## Tags

Sesquilinear form,
-/


open BigOperators

variable {R R₁ R₂ R₃ M M₁ M₂ Mₗ₁ Mₗ₁' Mₗ₂ Mₗ₂' K K₁ K₂ V V₁ V₂ n : Type _}

namespace LinearMap

/-! ### Orthogonal vectors -/


section CommRing

-- the `ₗ` subscript variables are for special cases about linear (as opposed to semilinear) maps
variable [CommSemiring R] [CommSemiring R₁] [AddCommMonoid M₁] [Module R₁ M₁] [CommSemiring R₂] [AddCommMonoid M₂]
  [Module R₂ M₂] {I₁ : R₁ →+* R} {I₂ : R₂ →+* R} {I₁' : R₁ →+* R}

/-- The proposition that two elements of a sesquilinear form space are orthogonal -/
def IsOrtho (B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R) (x y) : Prop :=
  B x y = 0
#align linear_map.is_ortho LinearMap.IsOrtho

theorem is_ortho_def {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} {x y} : B.IsOrtho x y ↔ B x y = 0 :=
  Iff.rfl
#align linear_map.is_ortho_def LinearMap.is_ortho_def

theorem isOrthoZeroLeft (B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R) (x) : IsOrtho B (0 : M₁) x := by
  dsimp only [is_ortho]
  rw [map_zero B, zero_apply]
#align linear_map.is_ortho_zero_left LinearMap.isOrthoZeroLeft

theorem isOrthoZeroRight (B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R) (x) : IsOrtho B x (0 : M₂) :=
  map_zero (B x)
#align linear_map.is_ortho_zero_right LinearMap.isOrthoZeroRight

theorem is_ortho_flip {B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₁'] R} {x y} : B.IsOrtho x y ↔ B.flip.IsOrtho y x := by
  simp_rw [is_ortho_def, flip_apply]
#align linear_map.is_ortho_flip LinearMap.is_ortho_flip

/- warning: linear_map.is_Ortho clashes with linear_map.is_ortho -> LinearMap.IsOrtho
warning: linear_map.is_Ortho -> LinearMap.IsOrtho is a dubious translation:
lean 3 declaration is
  forall {R : Type.{u_1}} {R₁ : Type.{u_2}} {M₁ : Type.{u_6}} {n : Type.{u_18}} [_inst_1 : CommSemiring.{u_1} R] [_inst_2 : CommSemiring.{u_2} R₁] [_inst_3 : AddCommMonoid.{u_6} M₁] [_inst_4 : Module.{u_2 u_6} R₁ M₁ (CommSemiring.toSemiring.{u_2} R₁ _inst_2) _inst_3] {I₁ : RingHom.{u_2 u_1} R₁ R (Semiring.toNonAssocSemiring.{u_2} R₁ (CommSemiring.toSemiring.{u_2} R₁ _inst_2)) (Semiring.toNonAssocSemiring.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1))} {I₁' : RingHom.{u_2 u_1} R₁ R (Semiring.toNonAssocSemiring.{u_2} R₁ (CommSemiring.toSemiring.{u_2} R₁ _inst_2)) (Semiring.toNonAssocSemiring.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1))}, (LinearMap.{u_2 u_1 u_6 (max u_6 u_1)} R₁ R (CommSemiring.toSemiring.{u_2} R₁ _inst_2) (CommSemiring.toSemiring.{u_1} R _inst_1) I₁ M₁ (LinearMap.{u_2 u_1 u_6 u_1} R₁ R (CommSemiring.toSemiring.{u_2} R₁ _inst_2) (CommSemiring.toSemiring.{u_1} R _inst_1) I₁' M₁ R _inst_3 (NonUnitalNonAssocSemiring.toAddCommMonoid.{u_1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u_1} R (Semiring.toNonAssocSemiring.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1)))) _inst_4 (Semiring.toModule.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1))) _inst_3 (LinearMap.addCommMonoid.{u_2 u_1 u_6 u_1} R₁ R M₁ R (CommSemiring.toSemiring.{u_2} R₁ _inst_2) (CommSemiring.toSemiring.{u_1} R _inst_1) _inst_3 (NonUnitalNonAssocSemiring.toAddCommMonoid.{u_1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u_1} R (Semiring.toNonAssocSemiring.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1)))) _inst_4 (Semiring.toModule.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1)) I₁') _inst_4 (LinearMap.module.{u_2 u_1 u_1 u_6 u_1} R₁ R R M₁ R (CommSemiring.toSemiring.{u_2} R₁ _inst_2) (CommSemiring.toSemiring.{u_1} R _inst_1) _inst_3 (NonUnitalNonAssocSemiring.toAddCommMonoid.{u_1} R (NonAssocSemiring.toNonUnitalNonAssocSemiring.{u_1} R (Semiring.toNonAssocSemiring.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1)))) _inst_4 (Semiring.toModule.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1)) I₁' (CommSemiring.toSemiring.{u_1} R _inst_1) (Semiring.toModule.{u_1} R (CommSemiring.toSemiring.{u_1} R _inst_1)) (LinearMap.IsOrtho._proof_1.{u_1} R _inst_1))) -> (n -> M₁) -> Prop
but is expected to have type
  PUnit.{0}
Case conversion may be inaccurate. Consider using '#align linear_map.is_Ortho LinearMap.IsOrthoₓ'. -/
/-- A set of vectors `v` is orthogonal with respect to some bilinear form `B` if and only
if for all `i ≠ j`, `B (v i) (v j) = 0`. For orthogonality between two elements, use
`bilin_form.is_ortho` -/
def IsOrtho (B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₁'] R) (v : n → M₁) : Prop :=
  Pairwise (B.IsOrtho on v)
#align linear_map.is_Ortho LinearMap.IsOrtho

theorem is_Ortho_def {B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₁'] R} {v : n → M₁} : B.IsOrtho v ↔ ∀ i j : n, i ≠ j → B (v i) (v j) = 0 :=
  Iff.rfl
#align linear_map.is_Ortho_def LinearMap.is_Ortho_def

theorem is_Ortho_flip (B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₁'] R) {v : n → M₁} : B.IsOrtho v ↔ B.flip.IsOrtho v := by
  simp_rw [is_Ortho_def]
  constructor <;> intro h i j hij
  · rw [flip_apply]
    exact h j i (Ne.symm hij)
    
  simp_rw [flip_apply] at h
  exact h j i (Ne.symm hij)
#align linear_map.is_Ortho_flip LinearMap.is_Ortho_flip

end CommRing

section Field

variable [Field K] [Field K₁] [AddCommGroup V₁] [Module K₁ V₁] [Field K₂] [AddCommGroup V₂] [Module K₂ V₂]
  {I₁ : K₁ →+* K} {I₂ : K₂ →+* K} {I₁' : K₁ →+* K} {J₁ : K →+* K} {J₂ : K →+* K}

-- todo: this also holds for [comm_ring R] [is_domain R] when J₁ is invertible
theorem ortho_smul_left {B : V₁ →ₛₗ[I₁] V₂ →ₛₗ[I₂] K} {x y} {a : K₁} (ha : a ≠ 0) :
    IsOrtho B x y ↔ IsOrtho B (a • x) y := by
  dsimp only [is_ortho]
  constructor <;> intro H
  · rw [map_smulₛₗ₂, H, smul_zero]
    
  · rw [map_smulₛₗ₂, smul_eq_zero] at H
    cases H
    · rw [map_eq_zero I₁] at H
      trivial
      
    · exact H
      
    
#align linear_map.ortho_smul_left LinearMap.ortho_smul_left

-- todo: this also holds for [comm_ring R] [is_domain R] when J₂ is invertible
theorem ortho_smul_right {B : V₁ →ₛₗ[I₁] V₂ →ₛₗ[I₂] K} {x y} {a : K₂} {ha : a ≠ 0} :
    IsOrtho B x y ↔ IsOrtho B x (a • y) := by
  dsimp only [is_ortho]
  constructor <;> intro H
  · rw [map_smulₛₗ, H, smul_zero]
    
  · rw [map_smulₛₗ, smul_eq_zero] at H
    cases H
    · simp at H
      exfalso
      exact ha H
      
    · exact H
      
    
#align linear_map.ortho_smul_right LinearMap.ortho_smul_right

/-- A set of orthogonal vectors `v` with respect to some sesquilinear form `B` is linearly
  independent if for all `i`, `B (v i) (v i) ≠ 0`. -/
theorem linear_independent_of_is_Ortho {B : V₁ →ₛₗ[I₁] V₁ →ₛₗ[I₁'] K} {v : n → V₁} (hv₁ : B.IsOrtho v)
    (hv₂ : ∀ i, ¬B.IsOrtho (v i) (v i)) : LinearIndependent K₁ v := by classical
  rw [linear_independent_iff']
  intro s w hs i hi
  have : B (s.sum fun i : n => w i • v i) (v i) = 0 := by rw [hs, map_zero, zero_apply]
  have hsum : (s.sum fun j : n => I₁ (w j) * B (v j) (v i)) = I₁ (w i) * B (v i) (v i) := by
    apply Finset.sum_eq_single_of_mem i hi
    intro j hj hij
    rw [is_Ortho_def.1 hv₁ _ _ hij, mul_zero]
  simp_rw [B.map_sum₂, map_smulₛₗ₂, smul_eq_mul, hsum] at this
  apply (map_eq_zero I₁).mp
  exact eq_zero_of_ne_zero_of_mul_right_eq_zero (hv₂ i) this
#align linear_map.linear_independent_of_is_Ortho LinearMap.linear_independent_of_is_Ortho

end Field

/-! ### Reflexive bilinear forms -/


section Reflexive

variable [CommSemiring R] [CommSemiring R₁] [AddCommMonoid M₁] [Module R₁ M₁] {I₁ : R₁ →+* R} {I₂ : R₁ →+* R}
  {B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₂] R}

/-- The proposition that a sesquilinear form is reflexive -/
def IsRefl (B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₂] R) : Prop :=
  ∀ x y, B x y = 0 → B y x = 0
#align linear_map.is_refl LinearMap.IsRefl

namespace IsRefl

variable (H : B.IsRefl)

theorem eq_zero : ∀ {x y}, B x y = 0 → B y x = 0 := fun x y => H x y
#align linear_map.is_refl.eq_zero LinearMap.IsRefl.eq_zero

theorem ortho_comm {x y} : IsOrtho B x y ↔ IsOrtho B y x :=
  ⟨eq_zero H, eq_zero H⟩
#align linear_map.is_refl.ortho_comm LinearMap.IsRefl.ortho_comm

theorem domRestrictRefl (H : B.IsRefl) (p : Submodule R₁ M₁) : (B.domRestrict₁₂ p p).IsRefl := fun _ _ => by
  simp_rw [dom_restrict₁₂_apply]
  exact H _ _
#align linear_map.is_refl.dom_restrict_refl LinearMap.IsRefl.domRestrictRefl

@[simp]
theorem flip_is_refl_iff : B.flip.IsRefl ↔ B.IsRefl :=
  ⟨fun h x y H => h y x ((B.flip_apply _ _).trans H), fun h x y => h y x⟩
#align linear_map.is_refl.flip_is_refl_iff LinearMap.IsRefl.flip_is_refl_iff

theorem ker_flip_eq_bot (H : B.IsRefl) (h : B.ker = ⊥) : B.flip.ker = ⊥ := by
  refine' ker_eq_bot'.mpr fun _ hx => ker_eq_bot'.mp h _ _
  ext
  exact H _ _ (LinearMap.congr_fun hx _)
#align linear_map.is_refl.ker_flip_eq_bot LinearMap.IsRefl.ker_flip_eq_bot

theorem ker_eq_bot_iff_ker_flip_eq_bot (H : B.IsRefl) : B.ker = ⊥ ↔ B.flip.ker = ⊥ := by
  refine' ⟨ker_flip_eq_bot H, fun h => _⟩
  exact (congr_arg _ B.flip_flip.symm).trans (ker_flip_eq_bot (flip_is_refl_iff.mpr H) h)
#align linear_map.is_refl.ker_eq_bot_iff_ker_flip_eq_bot LinearMap.IsRefl.ker_eq_bot_iff_ker_flip_eq_bot

end IsRefl

end Reflexive

/-! ### Symmetric bilinear forms -/


section Symmetric

variable [CommSemiring R] [AddCommMonoid M] [Module R M] {I : R →+* R} {B : M →ₛₗ[I] M →ₗ[R] R}

/-- The proposition that a sesquilinear form is symmetric -/
def IsSymm (B : M →ₛₗ[I] M →ₗ[R] R) : Prop :=
  ∀ x y, I (B x y) = B y x
#align linear_map.is_symm LinearMap.IsSymm

namespace IsSymm

protected theorem eq (H : B.IsSymm) (x y) : I (B x y) = B y x :=
  H x y
#align linear_map.is_symm.eq LinearMap.IsSymm.eq

theorem isRefl (H : B.IsSymm) : B.IsRefl := fun x y H1 => by
  rw [← H.eq]
  simp [H1]
#align linear_map.is_symm.is_refl LinearMap.IsSymm.isRefl

theorem ortho_comm (H : B.IsSymm) {x y} : IsOrtho B x y ↔ IsOrtho B y x :=
  H.IsRefl.ortho_comm
#align linear_map.is_symm.ortho_comm LinearMap.IsSymm.ortho_comm

theorem domRestrictSymm (H : B.IsSymm) (p : Submodule R M) : (B.domRestrict₁₂ p p).IsSymm := fun _ _ => by
  simp_rw [dom_restrict₁₂_apply]
  exact H _ _
#align linear_map.is_symm.dom_restrict_symm LinearMap.IsSymm.domRestrictSymm

end IsSymm

theorem is_symm_iff_eq_flip {B : M →ₗ[R] M →ₗ[R] R} : B.IsSymm ↔ B = B.flip := by
  constructor <;> intro h
  · ext
    rw [← h, flip_apply, RingHom.id_apply]
    
  intro x y
  conv_lhs => rw [h]
  rw [flip_apply, RingHom.id_apply]
#align linear_map.is_symm_iff_eq_flip LinearMap.is_symm_iff_eq_flip

end Symmetric

/-! ### Alternating bilinear forms -/


section Alternating

variable [CommRing R] [CommSemiring R₁] [AddCommMonoid M₁] [Module R₁ M₁] {I₁ : R₁ →+* R} {I₂ : R₁ →+* R} {I : R₁ →+* R}
  {B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₂] R}

/-- The proposition that a sesquilinear form is alternating -/
def IsAlt (B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₂] R) : Prop :=
  ∀ x, B x x = 0
#align linear_map.is_alt LinearMap.IsAlt

namespace IsAlt

variable (H : B.IsAlt)

include H

theorem self_eq_zero (x) : B x x = 0 :=
  H x
#align linear_map.is_alt.self_eq_zero LinearMap.IsAlt.self_eq_zero

theorem neg (x y) : -B x y = B y x := by
  have H1 : B (y + x) (y + x) = 0 := self_eq_zero H (y + x)
  simp [map_add, self_eq_zero H] at H1
  rw [add_eq_zero_iff_neg_eq] at H1
  exact H1
#align linear_map.is_alt.neg LinearMap.IsAlt.neg

theorem isRefl : B.IsRefl := by
  intro x y h
  rw [← neg H, h, neg_zero]
#align linear_map.is_alt.is_refl LinearMap.IsAlt.isRefl

theorem ortho_comm {x y} : IsOrtho B x y ↔ IsOrtho B y x :=
  H.IsRefl.ortho_comm
#align linear_map.is_alt.ortho_comm LinearMap.IsAlt.ortho_comm

end IsAlt

theorem is_alt_iff_eq_neg_flip [NoZeroDivisors R] [CharZero R] {B : M₁ →ₛₗ[I] M₁ →ₛₗ[I] R} : B.IsAlt ↔ B = -B.flip := by
  constructor <;> intro h
  · ext
    simp_rw [neg_apply, flip_apply]
    exact (h.neg _ _).symm
    
  intro x
  let h' := congr_fun₂ h x x
  simp only [neg_apply, flip_apply, ← add_eq_zero_iff_eq_neg] at h'
  exact add_self_eq_zero.mp h'
#align linear_map.is_alt_iff_eq_neg_flip LinearMap.is_alt_iff_eq_neg_flip

end Alternating

end LinearMap

namespace Submodule

/-! ### The orthogonal complement -/


variable [CommRing R] [CommRing R₁] [AddCommGroup M₁] [Module R₁ M₁] {I₁ : R₁ →+* R} {I₂ : R₁ →+* R}
  {B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₂] R}

/-- The orthogonal complement of a submodule `N` with respect to some bilinear form is the set of
elements `x` which are orthogonal to all elements of `N`; i.e., for all `y` in `N`, `B x y = 0`.

Note that for general (neither symmetric nor antisymmetric) bilinear forms this definition has a
chirality; in addition to this "left" orthogonal complement one could define a "right" orthogonal
complement for which, for all `y` in `N`, `B y x = 0`.  This variant definition is not currently
provided in mathlib. -/
def orthogonalBilin (N : Submodule R₁ M₁) (B : M₁ →ₛₗ[I₁] M₁ →ₛₗ[I₂] R) : Submodule R₁ M₁ where
  carrier := { m | ∀ n ∈ N, B.IsOrtho n m }
  zero_mem' x _ := B.isOrthoZeroRight x
  add_mem' x y hx hy n hn := by
    rw [LinearMap.IsOrtho, map_add, show B n x = 0 from hx n hn, show B n y = 0 from hy n hn, zero_add]
  smul_mem' c x hx n hn := by rw [LinearMap.IsOrtho, LinearMap.map_smulₛₗ, show B n x = 0 from hx n hn, smul_zero]
#align submodule.orthogonal_bilin Submodule.orthogonalBilin

variable {N L : Submodule R₁ M₁}

@[simp]
theorem mem_orthogonal_bilin_iff {m : M₁} : m ∈ N.orthogonalBilin B ↔ ∀ n ∈ N, B.IsOrtho n m :=
  Iff.rfl
#align submodule.mem_orthogonal_bilin_iff Submodule.mem_orthogonal_bilin_iff

theorem orthogonal_bilin_le (h : N ≤ L) : L.orthogonalBilin B ≤ N.orthogonalBilin B := fun _ hn l hl => hn l (h hl)
#align submodule.orthogonal_bilin_le Submodule.orthogonal_bilin_le

theorem le_orthogonal_bilin_orthogonal_bilin (b : B.IsRefl) : N ≤ (N.orthogonalBilin B).orthogonalBilin B :=
  fun n hn m hm => b _ _ (hm n hn)
#align submodule.le_orthogonal_bilin_orthogonal_bilin Submodule.le_orthogonal_bilin_orthogonal_bilin

end Submodule

namespace LinearMap

section Orthogonal

variable [Field K] [AddCommGroup V] [Module K V] [Field K₁] [AddCommGroup V₁] [Module K₁ V₁] {J : K →+* K}
  {J₁ : K₁ →+* K} {J₁' : K₁ →+* K}

-- ↓ This lemma only applies in fields as we require `a * b = 0 → a = 0 ∨ b = 0`
theorem span_singleton_inf_orthogonal_eq_bot (B : V₁ →ₛₗ[J₁] V₁ →ₛₗ[J₁'] K) (x : V₁) (hx : ¬B.IsOrtho x x) :
    (K₁ ∙ x) ⊓ Submodule.orthogonalBilin (K₁ ∙ x) B = ⊥ := by
  rw [← Finset.coe_singleton]
  refine' eq_bot_iff.2 fun y h => _
  rcases mem_span_finset.1 h.1 with ⟨μ, rfl⟩
  have := h.2 x _
  · rw [Finset.sum_singleton] at this⊢
    suffices hμzero : μ x = 0
    · rw [hμzero, zero_smul, Submodule.mem_bot]
      
    change B x (μ x • x) = 0 at this
    rw [map_smulₛₗ, smul_eq_mul] at this
    exact
      Or.elim (zero_eq_mul.mp this.symm)
        (fun y => by
          simp at y
          exact y)
        fun hfalse => False.elim <| hx hfalse
    
  · rw [Submodule.mem_span] <;> exact fun _ hp => hp <| Finset.mem_singleton_self _
    
#align linear_map.span_singleton_inf_orthogonal_eq_bot LinearMap.span_singleton_inf_orthogonal_eq_bot

-- ↓ This lemma only applies in fields since we use the `mul_eq_zero`
theorem orthogonal_span_singleton_eq_to_lin_ker {B : V →ₗ[K] V →ₛₗ[J] K} (x : V) :
    Submodule.orthogonalBilin (K ∙ x) B = (B x).ker := by
  ext y
  simp_rw [Submodule.mem_orthogonal_bilin_iff, LinearMap.mem_ker, Submodule.mem_span_singleton]
  constructor
  · exact fun h => h x ⟨1, one_smul _ _⟩
    
  · rintro h _ ⟨z, rfl⟩
    rw [is_ortho, map_smulₛₗ₂, smul_eq_zero]
    exact Or.intro_right _ h
    
#align linear_map.orthogonal_span_singleton_eq_to_lin_ker LinearMap.orthogonal_span_singleton_eq_to_lin_ker

-- todo: Generalize this to sesquilinear maps
theorem span_singleton_sup_orthogonal_eq_top {B : V →ₗ[K] V →ₗ[K] K} {x : V} (hx : ¬B.IsOrtho x x) :
    (K ∙ x) ⊔ Submodule.orthogonalBilin (K ∙ x) B = ⊤ := by
  rw [orthogonal_span_singleton_eq_to_lin_ker]
  exact (B x).span_singleton_sup_ker_eq_top hx
#align linear_map.span_singleton_sup_orthogonal_eq_top LinearMap.span_singleton_sup_orthogonal_eq_top

-- todo: Generalize this to sesquilinear maps
/-- Given a bilinear form `B` and some `x` such that `B x x ≠ 0`, the span of the singleton of `x`
  is complement to its orthogonal complement. -/
theorem is_compl_span_singleton_orthogonal {B : V →ₗ[K] V →ₗ[K] K} {x : V} (hx : ¬B.IsOrtho x x) :
    IsCompl (K ∙ x) (Submodule.orthogonalBilin (K ∙ x) B) :=
  { Disjoint := disjoint_iff.2 <| span_singleton_inf_orthogonal_eq_bot B x hx,
    Codisjoint := codisjoint_iff.2 <| span_singleton_sup_orthogonal_eq_top hx }
#align linear_map.is_compl_span_singleton_orthogonal LinearMap.is_compl_span_singleton_orthogonal

end Orthogonal

/-! ### Adjoint pairs -/


section AdjointPair

section AddCommMonoid

variable [CommSemiring R]

variable [AddCommMonoid M] [Module R M]

variable [AddCommMonoid M₁] [Module R M₁]

variable [AddCommMonoid M₂] [Module R M₂]

variable {I : R →+* R}

variable {B F : M →ₗ[R] M →ₛₗ[I] R} {B' : M₁ →ₗ[R] M₁ →ₛₗ[I] R} {B'' : M₂ →ₗ[R] M₂ →ₛₗ[I] R}

variable {f f' : M →ₗ[R] M₁} {g g' : M₁ →ₗ[R] M}

variable (B B' f g)

/-- Given a pair of modules equipped with bilinear forms, this is the condition for a pair of
maps between them to be mutually adjoint. -/
def IsAdjointPair :=
  ∀ x y, B' (f x) y = B x (g y)
#align linear_map.is_adjoint_pair LinearMap.IsAdjointPair

variable {B B' f g}

theorem is_adjoint_pair_iff_comp_eq_compl₂ : IsAdjointPair B B' f g ↔ B'.comp f = B.compl₂ g := by
  constructor <;> intro h
  · ext (x y)
    rw [comp_apply, compl₂_apply]
    exact h x y
    
  · intro _ _
    rw [← compl₂_apply, ← comp_apply, h]
    
#align linear_map.is_adjoint_pair_iff_comp_eq_compl₂ LinearMap.is_adjoint_pair_iff_comp_eq_compl₂

theorem isAdjointPairZero : IsAdjointPair B B' 0 0 := fun _ _ => by simp only [zero_apply, map_zero]
#align linear_map.is_adjoint_pair_zero LinearMap.isAdjointPairZero

theorem isAdjointPairId : IsAdjointPair B B 1 1 := fun x y => rfl
#align linear_map.is_adjoint_pair_id LinearMap.isAdjointPairId

theorem IsAdjointPair.add (h : IsAdjointPair B B' f g) (h' : IsAdjointPair B B' f' g') :
    IsAdjointPair B B' (f + f') (g + g') := fun x _ => by
  rw [f.add_apply, g.add_apply, B'.map_add₂, (B x).map_add, h, h']
#align linear_map.is_adjoint_pair.add LinearMap.IsAdjointPair.add

theorem IsAdjointPair.comp {f' : M₁ →ₗ[R] M₂} {g' : M₂ →ₗ[R] M₁} (h : IsAdjointPair B B' f g)
    (h' : IsAdjointPair B' B'' f' g') : IsAdjointPair B B'' (f'.comp f) (g.comp g') := fun _ _ => by
  rw [LinearMap.comp_apply, LinearMap.comp_apply, h', h]
#align linear_map.is_adjoint_pair.comp LinearMap.IsAdjointPair.comp

theorem IsAdjointPair.mul {f g f' g' : Module.EndCat R M} (h : IsAdjointPair B B f g) (h' : IsAdjointPair B B f' g') :
    IsAdjointPair B B (f * f') (g' * g) :=
  h'.comp h
#align linear_map.is_adjoint_pair.mul LinearMap.IsAdjointPair.mul

end AddCommMonoid

section AddCommGroup

variable [CommRing R]

variable [AddCommGroup M] [Module R M]

variable [AddCommGroup M₁] [Module R M₁]

variable {B F : M →ₗ[R] M →ₗ[R] R} {B' : M₁ →ₗ[R] M₁ →ₗ[R] R}

variable {f f' : M →ₗ[R] M₁} {g g' : M₁ →ₗ[R] M}

theorem IsAdjointPair.sub (h : IsAdjointPair B B' f g) (h' : IsAdjointPair B B' f' g') :
    IsAdjointPair B B' (f - f') (g - g') := fun x _ => by
  rw [f.sub_apply, g.sub_apply, B'.map_sub₂, (B x).map_sub, h, h']
#align linear_map.is_adjoint_pair.sub LinearMap.IsAdjointPair.sub

theorem IsAdjointPair.smul (c : R) (h : IsAdjointPair B B' f g) : IsAdjointPair B B' (c • f) (c • g) := fun _ _ => by
  simp only [smul_apply, map_smul, smul_eq_mul, h _ _]
#align linear_map.is_adjoint_pair.smul LinearMap.IsAdjointPair.smul

end AddCommGroup

end AdjointPair

/-! ### Self-adjoint pairs-/


section SelfadjointPair

section AddCommMonoid

variable [CommSemiring R]

variable [AddCommMonoid M] [Module R M]

variable {I : R →+* R}

variable (B F : M →ₗ[R] M →ₛₗ[I] R)

/-- The condition for an endomorphism to be "self-adjoint" with respect to a pair of bilinear forms
on the underlying module. In the case that these two forms are identical, this is the usual concept
of self adjointness. In the case that one of the forms is the negation of the other, this is the
usual concept of skew adjointness. -/
def IsPairSelfAdjoint (f : Module.EndCat R M) :=
  IsAdjointPair B F f f
#align linear_map.is_pair_self_adjoint LinearMap.IsPairSelfAdjoint

/-- An endomorphism of a module is self-adjoint with respect to a bilinear form if it serves as an
adjoint for itself. -/
protected def IsSelfAdjoint (f : Module.EndCat R M) :=
  IsAdjointPair B B f f
#align linear_map.is_self_adjoint LinearMap.IsSelfAdjoint

end AddCommMonoid

section AddCommGroup

variable [CommRing R]

variable [AddCommGroup M] [Module R M]

variable [AddCommGroup M₁] [Module R M₁] (B F : M →ₗ[R] M →ₗ[R] R)

/-- The set of pair-self-adjoint endomorphisms are a submodule of the type of all endomorphisms. -/
def isPairSelfAdjointSubmodule : Submodule R (Module.EndCat R M) where
  carrier := { f | IsPairSelfAdjoint B F f }
  zero_mem' := isAdjointPairZero
  add_mem' f g hf hg := hf.add hg
  smul_mem' c f h := h.smul c
#align linear_map.is_pair_self_adjoint_submodule LinearMap.isPairSelfAdjointSubmodule

/-- An endomorphism of a module is skew-adjoint with respect to a bilinear form if its negation
serves as an adjoint. -/
def IsSkewAdjoint (f : Module.EndCat R M) :=
  IsAdjointPair B B f (-f)
#align linear_map.is_skew_adjoint LinearMap.IsSkewAdjoint

/-- The set of self-adjoint endomorphisms of a module with bilinear form is a submodule. (In fact
it is a Jordan subalgebra.) -/
def selfAdjointSubmodule :=
  isPairSelfAdjointSubmodule B B
#align linear_map.self_adjoint_submodule LinearMap.selfAdjointSubmodule

/-- The set of skew-adjoint endomorphisms of a module with bilinear form is a submodule. (In fact
it is a Lie subalgebra.) -/
def skewAdjointSubmodule :=
  isPairSelfAdjointSubmodule (-B) B
#align linear_map.skew_adjoint_submodule LinearMap.skewAdjointSubmodule

variable {B F}

@[simp]
theorem mem_is_pair_self_adjoint_submodule (f : Module.EndCat R M) :
    f ∈ isPairSelfAdjointSubmodule B F ↔ IsPairSelfAdjoint B F f :=
  Iff.rfl
#align linear_map.mem_is_pair_self_adjoint_submodule LinearMap.mem_is_pair_self_adjoint_submodule

theorem is_pair_self_adjoint_equiv (e : M₁ ≃ₗ[R] M) (f : Module.EndCat R M) :
    IsPairSelfAdjoint B F f ↔ IsPairSelfAdjoint (B.compl₁₂ ↑e ↑e) (F.compl₁₂ ↑e ↑e) (e.symm.conj f) := by
  have hₗ :
    (F.compl₁₂ (↑e : M₁ →ₗ[R] M) (↑e : M₁ →ₗ[R] M)).comp (e.symm.conj f) =
      (F.comp f).compl₁₂ (↑e : M₁ →ₗ[R] M) (↑e : M₁ →ₗ[R] M) :=
    by
    ext
    simp only [LinearEquiv.symm_conj_apply, coe_comp, LinearEquiv.coe_coe, compl₁₂_apply, LinearEquiv.apply_symm_apply]
  have hᵣ :
    (B.compl₁₂ (↑e : M₁ →ₗ[R] M) (↑e : M₁ →ₗ[R] M)).compl₂ (e.symm.conj f) =
      (B.compl₂ f).compl₁₂ (↑e : M₁ →ₗ[R] M) (↑e : M₁ →ₗ[R] M) :=
    by
    ext
    simp only [LinearEquiv.symm_conj_apply, compl₂_apply, coe_comp, LinearEquiv.coe_coe, compl₁₂_apply,
      LinearEquiv.apply_symm_apply]
  have he : Function.Surjective (⇑(↑e : M₁ →ₗ[R] M) : M₁ → M) := e.surjective
  simp_rw [is_pair_self_adjoint, is_adjoint_pair_iff_comp_eq_compl₂, hₗ, hᵣ, compl₁₂_inj he he]
#align linear_map.is_pair_self_adjoint_equiv LinearMap.is_pair_self_adjoint_equiv

theorem is_skew_adjoint_iff_neg_self_adjoint (f : Module.EndCat R M) : B.IsSkewAdjoint f ↔ IsAdjointPair (-B) B f f :=
  show (∀ x y, B (f x) y = B x ((-f) y)) ↔ ∀ x y, B (f x) y = (-B) x (f y) by simp
#align linear_map.is_skew_adjoint_iff_neg_self_adjoint LinearMap.is_skew_adjoint_iff_neg_self_adjoint

@[simp]
theorem mem_self_adjoint_submodule (f : Module.EndCat R M) : f ∈ B.selfAdjointSubmodule ↔ B.IsSelfAdjoint f :=
  Iff.rfl
#align linear_map.mem_self_adjoint_submodule LinearMap.mem_self_adjoint_submodule

@[simp]
theorem mem_skew_adjoint_submodule (f : Module.EndCat R M) : f ∈ B.skewAdjointSubmodule ↔ B.IsSkewAdjoint f := by
  rw [is_skew_adjoint_iff_neg_self_adjoint]
  exact Iff.rfl
#align linear_map.mem_skew_adjoint_submodule LinearMap.mem_skew_adjoint_submodule

end AddCommGroup

end SelfadjointPair

/-! ### Nondegenerate bilinear forms -/


section Nondegenerate

section CommSemiring

variable [CommSemiring R] [CommSemiring R₁] [AddCommMonoid M₁] [Module R₁ M₁] [CommSemiring R₂] [AddCommMonoid M₂]
  [Module R₂ M₂] {I₁ : R₁ →+* R} {I₂ : R₂ →+* R} {I₁' : R₁ →+* R}

/-- A bilinear form is called left-separating if
the only element that is left-orthogonal to every other element is `0`; i.e.,
for every nonzero `x` in `M₁`, there exists `y` in `M₂` with `B x y ≠ 0`.-/
def SeparatingLeft (B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R) : Prop :=
  ∀ x : M₁, (∀ y : M₂, B x y = 0) → x = 0
#align linear_map.separating_left LinearMap.SeparatingLeft

variable (M₁ M₂ I₁ I₂)

/-- In a non-trivial module, zero is not non-degenerate. -/
theorem not_separating_left_zero [Nontrivial M₁] : ¬(0 : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R).SeparatingLeft :=
  let ⟨m, hm⟩ := exists_ne (0 : M₁)
  fun h => hm ((h m) fun n => rfl)
#align linear_map.not_separating_left_zero LinearMap.not_separating_left_zero

variable {M₁ M₂ I₁ I₂}

theorem SeparatingLeft.ne_zero [Nontrivial M₁] {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} (h : B.SeparatingLeft) : B ≠ 0 := fun h0 =>
  not_separating_left_zero M₁ M₂ I₁ I₂ <| h0 ▸ h
#align linear_map.separating_left.ne_zero LinearMap.SeparatingLeft.ne_zero

section Linear

variable [AddCommMonoid Mₗ₁] [AddCommMonoid Mₗ₂] [AddCommMonoid Mₗ₁'] [AddCommMonoid Mₗ₂']

variable [Module R Mₗ₁] [Module R Mₗ₂] [Module R Mₗ₁'] [Module R Mₗ₂']

variable {B : Mₗ₁ →ₗ[R] Mₗ₂ →ₗ[R] R} (e₁ : Mₗ₁ ≃ₗ[R] Mₗ₁') (e₂ : Mₗ₂ ≃ₗ[R] Mₗ₂')

theorem SeparatingLeft.congr (h : B.SeparatingLeft) :
    (e₁.arrowCongr (e₂.arrowCongr (LinearEquiv.refl R R)) B).SeparatingLeft := by
  intro x hx
  rw [← e₁.symm.map_eq_zero_iff]
  refine' h (e₁.symm x) fun y => _
  specialize hx (e₂ y)
  simp only [LinearEquiv.arrow_congr_apply, LinearEquiv.symm_apply_apply, LinearEquiv.map_eq_zero_iff] at hx
  exact hx
#align linear_map.separating_left.congr LinearMap.SeparatingLeft.congr

@[simp]
theorem separating_left_congr_iff :
    (e₁.arrowCongr (e₂.arrowCongr (LinearEquiv.refl R R)) B).SeparatingLeft ↔ B.SeparatingLeft :=
  ⟨fun h => by
    convert h.congr e₁.symm e₂.symm
    ext (x y)
    simp, SeparatingLeft.congr e₁ e₂⟩
#align linear_map.separating_left_congr_iff LinearMap.separating_left_congr_iff

end Linear

/-- A bilinear form is called right-separating if
the only element that is right-orthogonal to every other element is `0`; i.e.,
for every nonzero `y` in `M₂`, there exists `x` in `M₁` with `B x y ≠ 0`.-/
def SeparatingRight (B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R) : Prop :=
  ∀ y : M₂, (∀ x : M₁, B x y = 0) → y = 0
#align linear_map.separating_right LinearMap.SeparatingRight

/-- A bilinear form is called non-degenerate if it is left-separating and right-separating. -/
def Nondegenerate (B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R) : Prop :=
  SeparatingLeft B ∧ SeparatingRight B
#align linear_map.nondegenerate LinearMap.Nondegenerate

@[simp]
theorem flip_separating_right {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} : B.flip.SeparatingRight ↔ B.SeparatingLeft :=
  ⟨fun hB x hy => hB x hy, fun hB x hy => hB x hy⟩
#align linear_map.flip_separating_right LinearMap.flip_separating_right

@[simp]
theorem flip_separating_left {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} : B.flip.SeparatingLeft ↔ SeparatingRight B := by
  rw [← flip_separating_right, flip_flip]
#align linear_map.flip_separating_left LinearMap.flip_separating_left

@[simp]
theorem flip_nondegenerate {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} : B.flip.Nondegenerate ↔ B.Nondegenerate :=
  Iff.trans and_comm (and_congr flip_separating_right flip_separating_left)
#align linear_map.flip_nondegenerate LinearMap.flip_nondegenerate

theorem separating_left_iff_linear_nontrivial {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} :
    B.SeparatingLeft ↔ ∀ x : M₁, B x = 0 → x = 0 := by
  constructor <;> intro h x hB
  · let h' := h x
    simp only [hB, zero_apply, eq_self_iff_true, forall_const] at h'
    exact h'
    
  have h' : B x = 0 := by
    ext
    rw [zero_apply]
    exact hB _
  exact h x h'
#align linear_map.separating_left_iff_linear_nontrivial LinearMap.separating_left_iff_linear_nontrivial

theorem separating_right_iff_linear_flip_nontrivial {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} :
    B.SeparatingRight ↔ ∀ y : M₂, B.flip y = 0 → y = 0 := by
  rw [← flip_separating_left, separating_left_iff_linear_nontrivial]
#align linear_map.separating_right_iff_linear_flip_nontrivial LinearMap.separating_right_iff_linear_flip_nontrivial

/-- A bilinear form is left-separating if and only if it has a trivial kernel. -/
theorem separating_left_iff_ker_eq_bot {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} : B.SeparatingLeft ↔ B.ker = ⊥ :=
  Iff.trans separating_left_iff_linear_nontrivial LinearMap.ker_eq_bot'.symm
#align linear_map.separating_left_iff_ker_eq_bot LinearMap.separating_left_iff_ker_eq_bot

/-- A bilinear form is right-separating if and only if its flip has a trivial kernel. -/
theorem separating_right_iff_flip_ker_eq_bot {B : M₁ →ₛₗ[I₁] M₂ →ₛₗ[I₂] R} : B.SeparatingRight ↔ B.flip.ker = ⊥ := by
  rw [← flip_separating_left, separating_left_iff_ker_eq_bot]
#align linear_map.separating_right_iff_flip_ker_eq_bot LinearMap.separating_right_iff_flip_ker_eq_bot

end CommSemiring

section CommRing

variable [CommRing R] [AddCommGroup M] [Module R M] {I I' : R →+* R}

theorem IsRefl.nondegenerateOfSeparatingLeft {B : M →ₗ[R] M →ₗ[R] R} (hB : B.IsRefl) (hB' : B.SeparatingLeft) :
    B.Nondegenerate := by
  refine' ⟨hB', _⟩
  rw [separating_right_iff_flip_ker_eq_bot, hB.ker_eq_bot_iff_ker_flip_eq_bot.mp]
  rwa [← separating_left_iff_ker_eq_bot]
#align linear_map.is_refl.nondegenerate_of_separating_left LinearMap.IsRefl.nondegenerateOfSeparatingLeft

theorem IsRefl.nondegenerateOfSeparatingRight {B : M →ₗ[R] M →ₗ[R] R} (hB : B.IsRefl) (hB' : B.SeparatingRight) :
    B.Nondegenerate := by
  refine' ⟨_, hB'⟩
  rw [separating_left_iff_ker_eq_bot, hB.ker_eq_bot_iff_ker_flip_eq_bot.mpr]
  rwa [← separating_right_iff_flip_ker_eq_bot]
#align linear_map.is_refl.nondegenerate_of_separating_right LinearMap.IsRefl.nondegenerateOfSeparatingRight

/-- The restriction of a reflexive bilinear form `B` onto a submodule `W` is
nondegenerate if `W` has trivial intersection with its orthogonal complement,
that is `disjoint W (W.orthogonal_bilin B)`. -/
theorem nondegenerateRestrictOfDisjointOrthogonal {B : M →ₗ[R] M →ₗ[R] R} (hB : B.IsRefl) {W : Submodule R M}
    (hW : Disjoint W (W.orthogonalBilin B)) : (B.domRestrict₁₂ W W).Nondegenerate := by
  refine' (hB.dom_restrict_refl W).nondegenerateOfSeparatingLeft _
  rintro ⟨x, hx⟩ b₁
  rw [Submodule.mk_eq_zero, ← Submodule.mem_bot R]
  refine' hW.le_bot ⟨hx, fun y hy => _⟩
  specialize b₁ ⟨y, hy⟩
  simp_rw [dom_restrict₁₂_apply, Submodule.coe_mk] at b₁
  rw [hB.ortho_comm]
  exact b₁
#align linear_map.nondegenerate_restrict_of_disjoint_orthogonal LinearMap.nondegenerateRestrictOfDisjointOrthogonal

/-- An orthogonal basis with respect to a left-separating bilinear form has no self-orthogonal
elements. -/
theorem IsOrtho.not_is_ortho_basis_self_of_separating_left [Nontrivial R] {B : M →ₛₗ[I] M →ₛₗ[I'] R} {v : Basis n R M}
    (h : B.IsOrtho v) (hB : B.SeparatingLeft) (i : n) : ¬B.IsOrtho (v i) (v i) := by
  intro ho
  refine' v.ne_zero i ((hB (v i)) fun m => _)
  obtain ⟨vi, rfl⟩ := v.repr.symm.surjective m
  rw [Basis.repr_symm_apply, Finsupp.total_apply, Finsupp.sum, map_sum]
  apply Finset.sum_eq_zero
  rintro j -
  rw [map_smulₛₗ]
  convert mul_zero _ using 2
  obtain rfl | hij := eq_or_ne i j
  · exact ho
    
  · exact h hij
    
#align
  linear_map.is_Ortho.not_is_ortho_basis_self_of_separating_left LinearMap.IsOrtho.not_is_ortho_basis_self_of_separating_left

/-- An orthogonal basis with respect to a right-separating bilinear form has no self-orthogonal
elements. -/
theorem IsOrtho.not_is_ortho_basis_self_of_separating_right [Nontrivial R] {B : M →ₛₗ[I] M →ₛₗ[I'] R} {v : Basis n R M}
    (h : B.IsOrtho v) (hB : B.SeparatingRight) (i : n) : ¬B.IsOrtho (v i) (v i) := by
  rw [is_Ortho_flip] at h
  rw [is_ortho_flip]
  exact h.not_is_ortho_basis_self_of_separating_left (flip_separating_left.mpr hB) i
#align
  linear_map.is_Ortho.not_is_ortho_basis_self_of_separating_right LinearMap.IsOrtho.not_is_ortho_basis_self_of_separating_right

/-- Given an orthogonal basis with respect to a bilinear form, the bilinear form is left-separating
if the basis has no elements which are self-orthogonal. -/
theorem IsOrtho.separatingLeftOfNotIsOrthoBasisSelf [NoZeroDivisors R] {B : M →ₗ[R] M →ₗ[R] R} (v : Basis n R M)
    (hO : B.IsOrtho v) (h : ∀ i, ¬B.IsOrtho (v i) (v i)) : B.SeparatingLeft := by
  intro m hB
  obtain ⟨vi, rfl⟩ := v.repr.symm.surjective m
  rw [LinearEquiv.map_eq_zero_iff]
  ext i
  rw [Finsupp.zero_apply]
  specialize hB (v i)
  simp_rw [Basis.repr_symm_apply, Finsupp.total_apply, Finsupp.sum, map_sum₂, map_smulₛₗ₂, smul_eq_mul] at hB
  rw [Finset.sum_eq_single i] at hB
  · exact eq_zero_of_ne_zero_of_mul_right_eq_zero (h i) hB
    
  · intro j hj hij
    convert mul_zero _ using 2
    exact hO hij
    
  · intro hi
    convert zero_mul _ using 2
    exact finsupp.not_mem_support_iff.mp hi
    
#align
  linear_map.is_Ortho.separating_left_of_not_is_ortho_basis_self LinearMap.IsOrtho.separatingLeftOfNotIsOrthoBasisSelf

/-- Given an orthogonal basis with respect to a bilinear form, the bilinear form is right-separating
if the basis has no elements which are self-orthogonal. -/
theorem IsOrtho.separatingRightIffNotIsOrthoBasisSelf [NoZeroDivisors R] {B : M →ₗ[R] M →ₗ[R] R} (v : Basis n R M)
    (hO : B.IsOrtho v) (h : ∀ i, ¬B.IsOrtho (v i) (v i)) : B.SeparatingRight := by
  rw [is_Ortho_flip] at hO
  rw [← flip_separating_left]
  refine' is_Ortho.separating_left_of_not_is_ortho_basis_self v hO fun i => _
  rw [is_ortho_flip]
  exact h i
#align
  linear_map.is_Ortho.separating_right_iff_not_is_ortho_basis_self LinearMap.IsOrtho.separatingRightIffNotIsOrthoBasisSelf

/-- Given an orthogonal basis with respect to a bilinear form, the bilinear form is nondegenerate
if the basis has no elements which are self-orthogonal. -/
theorem IsOrtho.nondegenerateOfNotIsOrthoBasisSelf [NoZeroDivisors R] {B : M →ₗ[R] M →ₗ[R] R} (v : Basis n R M)
    (hO : B.IsOrtho v) (h : ∀ i, ¬B.IsOrtho (v i) (v i)) : B.Nondegenerate :=
  ⟨IsOrtho.separatingLeftOfNotIsOrthoBasisSelf v hO h, IsOrtho.separatingRightIffNotIsOrthoBasisSelf v hO h⟩
#align linear_map.is_Ortho.nondegenerate_of_not_is_ortho_basis_self LinearMap.IsOrtho.nondegenerateOfNotIsOrthoBasisSelf

end CommRing

end Nondegenerate

end LinearMap

