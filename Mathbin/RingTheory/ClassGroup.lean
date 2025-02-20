/-
Copyright (c) 2021 Anne Baanen. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Anne Baanen

! This file was ported from Lean 3 source module ring_theory.class_group
! leanprover-community/mathlib commit 7e5137f579de09a059a5ce98f364a04e221aabf0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.QuotientGroup
import Mathbin.RingTheory.DedekindDomain.Ideal

/-!
# The ideal class group

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the ideal class group `class_group R` of fractional ideals of `R`
inside its field of fractions.

## Main definitions
 - `to_principal_ideal` sends an invertible `x : K` to an invertible fractional ideal
 - `class_group` is the quotient of invertible fractional ideals modulo `to_principal_ideal.range`
 - `class_group.mk0` sends a nonzero integral ideal in a Dedekind domain to its class

## Main results
 - `class_group.mk0_eq_mk0_iff` shows the equivalence with the "classical" definition,
   where `I ~ J` iff `x I = y J` for `x y ≠ (0 : R)`

## Implementation details

The definition of `class_group R` involves `fraction_ring R`. However, the API should be completely
identical no matter the choice of field of fractions for `R`.
-/


variable {R K L : Type _} [CommRing R]

variable [Field K] [Field L] [DecidableEq L]

variable [Algebra R K] [IsFractionRing R K]

variable [Algebra K L] [FiniteDimensional K L]

variable [Algebra R L] [IsScalarTower R K L]

open scoped nonZeroDivisors

open IsLocalization IsFractionRing FractionalIdeal Units

section

variable (R K)

#print toPrincipalIdeal /-
/-- `to_principal_ideal R K x` sends `x ≠ 0 : K` to the fractional `R`-ideal generated by `x` -/
irreducible_def toPrincipalIdeal : Kˣ →* (FractionalIdeal R⁰ K)ˣ :=
  { toFun := fun x =>
      ⟨spanSingleton _ x, spanSingleton _ x⁻¹, by
        simp only [span_singleton_one, Units.mul_inv', span_singleton_mul_span_singleton], by
        simp only [span_singleton_one, Units.inv_mul', span_singleton_mul_span_singleton]⟩
    map_mul' := fun x y =>
      ext (by simp only [Units.val_mk, Units.val_mul, span_singleton_mul_span_singleton])
    map_one' := ext (by simp only [span_singleton_one, Units.val_mk, Units.val_one]) }
#align to_principal_ideal toPrincipalIdeal
-/

variable {R K}

#print coe_toPrincipalIdeal /-
@[simp]
theorem coe_toPrincipalIdeal (x : Kˣ) :
    (toPrincipalIdeal R K x : FractionalIdeal R⁰ K) = spanSingleton _ x := by
  simp only [toPrincipalIdeal]; rfl
#align coe_to_principal_ideal coe_toPrincipalIdeal
-/

#print toPrincipalIdeal_eq_iff /-
@[simp]
theorem toPrincipalIdeal_eq_iff {I : (FractionalIdeal R⁰ K)ˣ} {x : Kˣ} :
    toPrincipalIdeal R K x = I ↔ spanSingleton R⁰ (x : K) = I := by simp only [toPrincipalIdeal];
  exact Units.ext_iff
#align to_principal_ideal_eq_iff toPrincipalIdeal_eq_iff
-/

#print mem_principal_ideals_iff /-
theorem mem_principal_ideals_iff {I : (FractionalIdeal R⁰ K)ˣ} :
    I ∈ (toPrincipalIdeal R K).range ↔ ∃ x : K, spanSingleton R⁰ x = I :=
  by
  simp only [MonoidHom.mem_range, toPrincipalIdeal_eq_iff]
  constructor <;> rintro ⟨x, hx⟩
  · exact ⟨x, hx⟩
  · refine' ⟨Units.mk0 x _, hx⟩
    rintro rfl
    simpa [I.ne_zero.symm] using hx
#align mem_principal_ideals_iff mem_principal_ideals_iff
-/

#print PrincipalIdeals.normal /-
instance PrincipalIdeals.normal : (toPrincipalIdeal R K).range.Normal :=
  Subgroup.normal_of_comm _
#align principal_ideals.normal PrincipalIdeals.normal
-/

end

variable (R) [IsDomain R]

#print ClassGroup /-
/-- The ideal class group of `R` is the group of invertible fractional ideals
modulo the principal ideals. -/
def ClassGroup :=
  (FractionalIdeal R⁰ (FractionRing R))ˣ ⧸ (toPrincipalIdeal R (FractionRing R)).range
deriving CommGroup
#align class_group ClassGroup
-/

noncomputable instance : Inhabited (ClassGroup R) :=
  ⟨1⟩

variable {R K}

#print ClassGroup.mk /-
/-- Send a nonzero fractional ideal to the corresponding class in the class group. -/
noncomputable def ClassGroup.mk : (FractionalIdeal R⁰ K)ˣ →* ClassGroup R :=
  (QuotientGroup.mk' (toPrincipalIdeal R (FractionRing R)).range).comp
    (Units.map (FractionalIdeal.canonicalEquiv R⁰ K (FractionRing R)))
#align class_group.mk ClassGroup.mk
-/

#print ClassGroup.mk_eq_mk /-
theorem ClassGroup.mk_eq_mk {I J : (FractionalIdeal R⁰ <| FractionRing R)ˣ} :
    ClassGroup.mk I = ClassGroup.mk J ↔
      ∃ x : (FractionRing R)ˣ, I * toPrincipalIdeal R (FractionRing R) x = J :=
  by
  erw [QuotientGroup.mk'_eq_mk', canonical_equiv_self, Units.map_id, Set.exists_range_iff]
  rfl
#align class_group.mk_eq_mk ClassGroup.mk_eq_mk
-/

#print ClassGroup.mk_eq_mk_of_coe_ideal /-
theorem ClassGroup.mk_eq_mk_of_coe_ideal {I J : (FractionalIdeal R⁰ <| FractionRing R)ˣ}
    {I' J' : Ideal R} (hI : (I : FractionalIdeal R⁰ <| FractionRing R) = I')
    (hJ : (J : FractionalIdeal R⁰ <| FractionRing R) = J') :
    ClassGroup.mk I = ClassGroup.mk J ↔
      ∃ x y : R, x ≠ 0 ∧ y ≠ 0 ∧ Ideal.span {x} * I' = Ideal.span {y} * J' :=
  by
  rw [ClassGroup.mk_eq_mk]
  constructor
  · rintro ⟨x, rfl⟩
    rw [Units.val_mul, hI, coe_toPrincipalIdeal, mul_comm,
      span_singleton_mul_coe_ideal_eq_coe_ideal] at hJ 
    exact ⟨_, _, sec_fst_ne_zero le_rfl x.ne_zero, sec_snd_ne_zero le_rfl ↑x, hJ⟩
  · rintro ⟨x, y, hx, hy, h⟩
    constructor; rw [mul_comm, ← Units.eq_iff, Units.val_mul, coe_toPrincipalIdeal]
    convert
      (mk'_mul_coe_ideal_eq_coe_ideal (FractionRing R) <| mem_nonZeroDivisors_of_ne_zero hy).2 h
    apply (Ne.isUnit _).unit_spec
    rwa [Ne, mk'_eq_zero_iff_eq_zero]
#align class_group.mk_eq_mk_of_coe_ideal ClassGroup.mk_eq_mk_of_coe_ideal
-/

#print ClassGroup.mk_eq_one_of_coe_ideal /-
theorem ClassGroup.mk_eq_one_of_coe_ideal {I : (FractionalIdeal R⁰ <| FractionRing R)ˣ}
    {I' : Ideal R} (hI : (I : FractionalIdeal R⁰ <| FractionRing R) = I') :
    ClassGroup.mk I = 1 ↔ ∃ x : R, x ≠ 0 ∧ I' = Ideal.span {x} :=
  by
  rw [← map_one ClassGroup.mk, ClassGroup.mk_eq_mk_of_coe_ideal hI (_ : _ = ↑⊤)]
  any_goals rfl
  constructor
  · rintro ⟨x, y, hx, hy, h⟩
    rw [Ideal.mul_top] at h 
    rcases ideal.mem_span_singleton_mul.mp ((Ideal.span_singleton_le_iff_mem _).mp h.ge) with
      ⟨i, hi, rfl⟩
    rw [← Ideal.span_singleton_mul_span_singleton, Ideal.span_singleton_mul_right_inj hx] at h 
    exact ⟨i, right_ne_zero_of_mul hy, h⟩
  · rintro ⟨x, hx, rfl⟩
    exact ⟨1, x, one_ne_zero, hx, by rw [Ideal.span_singleton_one, Ideal.top_mul, Ideal.mul_top]⟩
#align class_group.mk_eq_one_of_coe_ideal ClassGroup.mk_eq_one_of_coe_ideal
-/

variable (K)

#print ClassGroup.induction /-
/-- Induction principle for the class group: to show something holds for all `x : class_group R`,
we can choose a fraction field `K` and show it holds for the equivalence class of each
`I : fractional_ideal R⁰ K`. -/
@[elab_as_elim]
theorem ClassGroup.induction {P : ClassGroup R → Prop}
    (h : ∀ I : (FractionalIdeal R⁰ K)ˣ, P (ClassGroup.mk I)) (x : ClassGroup R) : P x :=
  QuotientGroup.induction_on x fun I =>
    by
    convert h (Units.mapEquiv (↑(canonical_equiv R⁰ (FractionRing R) K)) I)
    ext : 1
    rw [Units.coe_map, Units.coe_mapEquiv]
    exact (canonical_equiv_flip R⁰ K (FractionRing R) I).symm
#align class_group.induction ClassGroup.induction
-/

#print ClassGroup.equiv /-
/-- The definition of the class group does not depend on the choice of field of fractions. -/
noncomputable def ClassGroup.equiv :
    ClassGroup R ≃* (FractionalIdeal R⁰ K)ˣ ⧸ (toPrincipalIdeal R K).range :=
  QuotientGroup.congr _ _
      (Units.mapEquiv
        (FractionalIdeal.canonicalEquiv R⁰ (FractionRing R) K :
          FractionalIdeal R⁰ (FractionRing R) ≃* FractionalIdeal R⁰ K)) <|
    by
    ext I
    simp only [Subgroup.mem_map, mem_principal_ideals_iff, MonoidHom.coe_coe]
    constructor
    · rintro ⟨I, ⟨x, hx⟩, rfl⟩
      refine' ⟨FractionRing.algEquiv R K x, _⟩
      rw [Units.coe_mapEquiv, ← hx, RingEquiv.coe_toMulEquiv, canonical_equiv_span_singleton]
      rfl
    · rintro ⟨x, hx⟩
      refine'
        ⟨Units.mapEquiv (↑(canonical_equiv R⁰ K (FractionRing R))) I,
          ⟨(FractionRing.algEquiv R K).symm x, _⟩, Units.ext _⟩
      · rw [Units.coe_mapEquiv, ← hx, RingEquiv.coe_toMulEquiv, canonical_equiv_span_singleton]
        rfl
      simp only [RingEquiv.coe_toMulEquiv, canonical_equiv_flip, Units.coe_mapEquiv]
#align class_group.equiv ClassGroup.equiv
-/

#print ClassGroup.equiv_mk /-
@[simp]
theorem ClassGroup.equiv_mk (K' : Type _) [Field K'] [Algebra R K'] [IsFractionRing R K']
    (I : (FractionalIdeal R⁰ K)ˣ) :
    ClassGroup.equiv K' (ClassGroup.mk I) =
      QuotientGroup.mk' _ (Units.mapEquiv (↑(FractionalIdeal.canonicalEquiv R⁰ K K')) I) :=
  by
  rw [ClassGroup.equiv, ClassGroup.mk, MonoidHom.comp_apply, QuotientGroup.congr_mk']
  congr
  ext : 1
  rw [Units.coe_mapEquiv, Units.coe_mapEquiv, Units.coe_map]
  exact FractionalIdeal.canonicalEquiv_canonicalEquiv _ _ _ _ _
#align class_group.equiv_mk ClassGroup.equiv_mk
-/

#print ClassGroup.mk_canonicalEquiv /-
@[simp]
theorem ClassGroup.mk_canonicalEquiv (K' : Type _) [Field K'] [Algebra R K'] [IsFractionRing R K']
    (I : (FractionalIdeal R⁰ K)ˣ) :
    ClassGroup.mk (Units.map (↑(canonicalEquiv R⁰ K K')) I : (FractionalIdeal R⁰ K')ˣ) =
      ClassGroup.mk I :=
  by
  rw [ClassGroup.mk, MonoidHom.comp_apply, ← MonoidHom.comp_apply (Units.map _), ← Units.map_comp, ←
      RingEquiv.coe_monoidHom_trans, FractionalIdeal.canonicalEquiv_trans_canonicalEquiv] <;>
    rfl
#align class_group.mk_canonical_equiv ClassGroup.mk_canonicalEquiv
-/

#print FractionalIdeal.mk0 /-
/-- Send a nonzero integral ideal to an invertible fractional ideal. -/
noncomputable def FractionalIdeal.mk0 [IsDedekindDomain R] : (Ideal R)⁰ →* (FractionalIdeal R⁰ K)ˣ
    where
  toFun I := Units.mk0 I (coeIdeal_ne_zero.mpr <| mem_nonZeroDivisors_iff_ne_zero.mp I.2)
  map_one' := by simp
  map_mul' x y := by simp
#align fractional_ideal.mk0 FractionalIdeal.mk0
-/

#print FractionalIdeal.coe_mk0 /-
@[simp]
theorem FractionalIdeal.coe_mk0 [IsDedekindDomain R] (I : (Ideal R)⁰) :
    (FractionalIdeal.mk0 K I : FractionalIdeal R⁰ K) = I :=
  rfl
#align fractional_ideal.coe_mk0 FractionalIdeal.coe_mk0
-/

#print FractionalIdeal.canonicalEquiv_mk0 /-
theorem FractionalIdeal.canonicalEquiv_mk0 [IsDedekindDomain R] (K' : Type _) [Field K']
    [Algebra R K'] [IsFractionRing R K'] (I : (Ideal R)⁰) :
    FractionalIdeal.canonicalEquiv R⁰ K K' (FractionalIdeal.mk0 K I) = FractionalIdeal.mk0 K' I :=
  by simp only [FractionalIdeal.coe_mk0, coe_coe, FractionalIdeal.canonicalEquiv_coeIdeal]
#align fractional_ideal.canonical_equiv_mk0 FractionalIdeal.canonicalEquiv_mk0
-/

#print FractionalIdeal.map_canonicalEquiv_mk0 /-
@[simp]
theorem FractionalIdeal.map_canonicalEquiv_mk0 [IsDedekindDomain R] (K' : Type _) [Field K']
    [Algebra R K'] [IsFractionRing R K'] (I : (Ideal R)⁰) :
    Units.map (↑(FractionalIdeal.canonicalEquiv R⁰ K K')) (FractionalIdeal.mk0 K I) =
      FractionalIdeal.mk0 K' I :=
  Units.ext (FractionalIdeal.canonicalEquiv_mk0 K K' I)
#align fractional_ideal.map_canonical_equiv_mk0 FractionalIdeal.map_canonicalEquiv_mk0
-/

#print ClassGroup.mk0 /-
/-- Send a nonzero ideal to the corresponding class in the class group. -/
noncomputable def ClassGroup.mk0 [IsDedekindDomain R] : (Ideal R)⁰ →* ClassGroup R :=
  ClassGroup.mk.comp (FractionalIdeal.mk0 (FractionRing R))
#align class_group.mk0 ClassGroup.mk0
-/

#print ClassGroup.mk_mk0 /-
@[simp]
theorem ClassGroup.mk_mk0 [IsDedekindDomain R] (I : (Ideal R)⁰) :
    ClassGroup.mk (FractionalIdeal.mk0 K I) = ClassGroup.mk0 I := by
  rw [ClassGroup.mk0, MonoidHom.comp_apply, ← ClassGroup.mk_canonicalEquiv K (FractionRing R),
    FractionalIdeal.map_canonicalEquiv_mk0]
#align class_group.mk_mk0 ClassGroup.mk_mk0
-/

#print ClassGroup.equiv_mk0 /-
@[simp]
theorem ClassGroup.equiv_mk0 [IsDedekindDomain R] (I : (Ideal R)⁰) :
    ClassGroup.equiv K (ClassGroup.mk0 I) =
      QuotientGroup.mk' (toPrincipalIdeal R K).range (FractionalIdeal.mk0 K I) :=
  by
  rw [ClassGroup.mk0, MonoidHom.comp_apply, ClassGroup.equiv_mk]
  congr
  ext
  simp
#align class_group.equiv_mk0 ClassGroup.equiv_mk0
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ≠ » (0 : K)) -/
#print ClassGroup.mk0_eq_mk0_iff_exists_fraction_ring /-
theorem ClassGroup.mk0_eq_mk0_iff_exists_fraction_ring [IsDedekindDomain R] {I J : (Ideal R)⁰} :
    ClassGroup.mk0 I = ClassGroup.mk0 J ↔ ∃ (x : _) (_ : x ≠ (0 : K)), spanSingleton R⁰ x * I = J :=
  by
  refine' (ClassGroup.equiv K).Injective.eq_iff.symm.trans _
  simp only [ClassGroup.equiv_mk0, QuotientGroup.mk'_eq_mk', mem_principal_ideals_iff, coe_coe,
    Units.ext_iff, Units.val_mul, FractionalIdeal.coe_mk0, exists_prop]
  constructor
  · rintro ⟨X, ⟨x, hX⟩, hx⟩
    refine' ⟨x, _, _⟩
    · rintro rfl; simpa [X.ne_zero.symm] using hX
    simpa only [hX, mul_comm] using hx
  · rintro ⟨x, hx, eq_J⟩
    refine' ⟨Units.mk0 _ (span_singleton_ne_zero_iff.mpr hx), ⟨x, rfl⟩, _⟩
    simpa only [mul_comm] using eq_J
#align class_group.mk0_eq_mk0_iff_exists_fraction_ring ClassGroup.mk0_eq_mk0_iff_exists_fraction_ring
-/

variable {K}

#print ClassGroup.mk0_eq_mk0_iff /-
theorem ClassGroup.mk0_eq_mk0_iff [IsDedekindDomain R] {I J : (Ideal R)⁰} :
    ClassGroup.mk0 I = ClassGroup.mk0 J ↔
      ∃ (x y : R) (hx : x ≠ 0) (hy : y ≠ 0), Ideal.span {x} * (I : Ideal R) = Ideal.span {y} * J :=
  by
  refine' (ClassGroup.mk0_eq_mk0_iff_exists_fraction_ring (FractionRing R)).trans ⟨_, _⟩
  · rintro ⟨z, hz, h⟩
    obtain ⟨x, ⟨y, hy⟩, rfl⟩ := IsLocalization.mk'_surjective R⁰ z
    refine' ⟨x, y, _, mem_non_zero_divisors_iff_ne_zero.mp hy, _⟩
    · rintro hx; apply hz
      rw [hx, IsFractionRing.mk'_eq_div, _root_.map_zero, zero_div]
    · exact (FractionalIdeal.mk'_mul_coeIdeal_eq_coeIdeal _ hy).mp h
  · rintro ⟨x, y, hx, hy, h⟩
    have hy' : y ∈ R⁰ := mem_non_zero_divisors_iff_ne_zero.mpr hy
    refine' ⟨IsLocalization.mk' _ x ⟨y, hy'⟩, _, _⟩
    · contrapose! hx
      rwa [mk'_eq_iff_eq_mul, MulZeroClass.zero_mul, ← (algebraMap R (FractionRing R)).map_zero,
        (IsFractionRing.injective R (FractionRing R)).eq_iff] at hx 
    · exact (FractionalIdeal.mk'_mul_coeIdeal_eq_coeIdeal _ hy').mpr h
#align class_group.mk0_eq_mk0_iff ClassGroup.mk0_eq_mk0_iff
-/

#print ClassGroup.mk0_surjective /-
theorem ClassGroup.mk0_surjective [IsDedekindDomain R] :
    Function.Surjective (ClassGroup.mk0 : (Ideal R)⁰ → ClassGroup R) :=
  by
  rintro ⟨I⟩
  obtain ⟨a, a_ne_zero', ha⟩ := I.1.2
  have a_ne_zero := mem_non_zero_divisors_iff_ne_zero.mp a_ne_zero'
  have fa_ne_zero : (algebraMap R (FractionRing R)) a ≠ 0 :=
    IsFractionRing.to_map_ne_zero_of_mem_nonZeroDivisors a_ne_zero'
  refine' ⟨⟨{ carrier := {x | (algebraMap R _ a)⁻¹ * algebraMap R _ x ∈ I.1} .. }, _⟩, _⟩
  · simp only [RingHom.map_add, Set.mem_setOf_eq, MulZeroClass.mul_zero, RingHom.map_mul, mul_add]
    exact fun _ _ ha hb => Submodule.add_mem I ha hb
  · simp only [RingHom.map_zero, Set.mem_setOf_eq, MulZeroClass.mul_zero, RingHom.map_mul]
    exact Submodule.zero_mem I
  · intro c _ hb
    simp only [smul_eq_mul, Set.mem_setOf_eq, MulZeroClass.mul_zero, RingHom.map_mul, mul_add,
      mul_left_comm ((algebraMap R (FractionRing R)) a)⁻¹]
    rw [← Algebra.smul_def c]
    exact Submodule.smul_mem I c hb
  · rw [mem_nonZeroDivisors_iff_ne_zero, Submodule.zero_eq_bot, Submodule.ne_bot_iff]
    obtain ⟨x, x_ne, x_mem⟩ := exists_ne_zero_mem_is_integer I.ne_zero
    refine' ⟨a * x, _, mul_ne_zero a_ne_zero x_ne⟩
    change ((algebraMap R _) a)⁻¹ * (algebraMap R _) (a * x) ∈ I.1
    rwa [RingHom.map_mul, ← mul_assoc, inv_mul_cancel fa_ne_zero, one_mul]
  · symm
    apply Quotient.sound
    change Setoid.r _ _
    rw [QuotientGroup.leftRel_apply]
    refine' ⟨Units.mk0 (algebraMap R _ a) fa_ne_zero, _⟩
    rw [_root_.eq_inv_mul_iff_mul_eq, eq_comm, mul_comm I]
    apply Units.ext
    simp only [FractionalIdeal.coe_mk0, FractionalIdeal.map_canonicalEquiv_mk0, SetLike.coe_mk,
      Units.val_mk0, coe_toPrincipalIdeal, coe_coe, Units.val_mul,
      FractionalIdeal.eq_spanSingleton_mul]
    constructor
    · intro zJ' hzJ'
      obtain ⟨zJ, hzJ : (algebraMap R _ a)⁻¹ * algebraMap R _ zJ ∈ ↑I, rfl⟩ :=
        (mem_coe_ideal R⁰).mp hzJ'
      refine' ⟨_, hzJ, _⟩
      rw [← mul_assoc, mul_inv_cancel fa_ne_zero, one_mul]
    · intro zI' hzI'
      obtain ⟨y, hy⟩ := ha zI' hzI'
      rw [← Algebra.smul_def, mem_coe_ideal]
      refine' ⟨y, _, hy⟩
      show (algebraMap R _ a)⁻¹ * algebraMap R _ y ∈ (I : FractionalIdeal R⁰ (FractionRing R))
      rwa [hy, Algebra.smul_def, ← mul_assoc, inv_mul_cancel fa_ne_zero, one_mul]
#align class_group.mk0_surjective ClassGroup.mk0_surjective
-/

#print ClassGroup.mk_eq_one_iff /-
theorem ClassGroup.mk_eq_one_iff {I : (FractionalIdeal R⁰ K)ˣ} :
    ClassGroup.mk I = 1 ↔ (I : Submodule R K).IsPrincipal :=
  by
  simp only [← (ClassGroup.equiv K).Injective.eq_iff, _root_.map_one, ClassGroup.equiv_mk,
    QuotientGroup.mk'_apply, QuotientGroup.eq_one_iff, MonoidHom.mem_range, Units.ext_iff,
    coe_toPrincipalIdeal, Units.coe_mapEquiv, FractionalIdeal.canonicalEquiv_self, coe_coe,
    RingEquiv.coe_mulEquiv_refl, MulEquiv.refl_apply]
  refine' ⟨fun ⟨x, hx⟩ => ⟨⟨x, by rw [← hx, coe_span_singleton]⟩⟩, _⟩
  intro hI
  obtain ⟨x, hx⟩ := @Submodule.IsPrincipal.principal _ _ _ _ _ _ hI
  have hx' : (I : FractionalIdeal R⁰ K) = span_singleton R⁰ x := by apply Subtype.coe_injective;
    rw [hx, coe_span_singleton]
  refine' ⟨Units.mk0 x _, _⟩
  · intro x_eq; apply Units.ne_zero I; simp [hx', x_eq]
  simp [hx']
#align class_group.mk_eq_one_iff ClassGroup.mk_eq_one_iff
-/

#print ClassGroup.mk0_eq_one_iff /-
theorem ClassGroup.mk0_eq_one_iff [IsDedekindDomain R] {I : Ideal R} (hI : I ∈ (Ideal R)⁰) :
    ClassGroup.mk0 ⟨I, hI⟩ = 1 ↔ I.IsPrincipal :=
  ClassGroup.mk_eq_one_iff.trans (coeSubmodule_isPrincipal R _)
#align class_group.mk0_eq_one_iff ClassGroup.mk0_eq_one_iff
-/

/-- The class group of principal ideal domain is finite (in fact a singleton).

See `class_group.fintype_of_admissible` for a finiteness proof that works for rings of integers
of global fields.
-/
noncomputable instance [IsPrincipalIdealRing R] : Fintype (ClassGroup R)
    where
  elems := {1}
  complete := by
    refine' ClassGroup.induction (FractionRing R) fun I => _
    rw [Finset.mem_singleton]
    exact class_group.mk_eq_one_iff.mpr (I : FractionalIdeal R⁰ (FractionRing R)).IsPrincipal

#print card_classGroup_eq_one /-
/-- The class number of a principal ideal domain is `1`. -/
theorem card_classGroup_eq_one [IsPrincipalIdealRing R] : Fintype.card (ClassGroup R) = 1 :=
  by
  rw [Fintype.card_eq_one_iff]
  use 1
  refine' ClassGroup.induction (FractionRing R) fun I => _
  exact class_group.mk_eq_one_iff.mpr (I : FractionalIdeal R⁰ (FractionRing R)).IsPrincipal
#align card_class_group_eq_one card_classGroup_eq_one
-/

#print card_classGroup_eq_one_iff /-
/-- The class number is `1` iff the ring of integers is a principal ideal domain. -/
theorem card_classGroup_eq_one_iff [IsDedekindDomain R] [Fintype (ClassGroup R)] :
    Fintype.card (ClassGroup R) = 1 ↔ IsPrincipalIdealRing R :=
  by
  constructor; swap; · intros; convert card_classGroup_eq_one; assumption
  rw [Fintype.card_eq_one_iff]
  rintro ⟨I, hI⟩
  have eq_one : ∀ J : ClassGroup R, J = 1 := fun J => trans (hI J) (hI 1).symm
  refine' ⟨fun I => _⟩
  by_cases hI : I = ⊥
  · rw [hI]; exact bot_isPrincipal
  exact (ClassGroup.mk0_eq_one_iff (mem_non_zero_divisors_iff_ne_zero.mpr hI)).mp (eq_one _)
#align card_class_group_eq_one_iff card_classGroup_eq_one_iff
-/

