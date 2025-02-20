/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module field_theory.fixed
! leanprover-community/mathlib commit fd4551cfe4b7484b81c2c9ba3405edae27659676
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GroupRingAction.Invariant
import Mathbin.Algebra.Polynomial.GroupRingAction
import Mathbin.FieldTheory.Normal
import Mathbin.FieldTheory.Separable
import Mathbin.FieldTheory.Tower

/-!
# Fixed field under a group action.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This is the basis of the Fundamental Theorem of Galois Theory.
Given a (finite) group `G` that acts on a field `F`, we define `fixed_points G F`,
the subfield consisting of elements of `F` fixed_points by every element of `G`.

This subfield is then normal and separable, and in addition (TODO) if `G` acts faithfully on `F`
then `finrank (fixed_points G F) F = fintype.card G`.

## Main Definitions

- `fixed_points G F`, the subfield consisting of elements of `F` fixed_points by every element of
`G`, where `G` is a group that acts on `F`.

-/


noncomputable section

open scoped Classical BigOperators

open MulAction Finset FiniteDimensional

universe u v w

variable {M : Type u} [Monoid M]

variable (G : Type u) [Group G]

variable (F : Type v) [Field F] [MulSemiringAction M F] [MulSemiringAction G F] (m : M)

#print FixedBy.subfield /-
/-- The subfield of F fixed by the field endomorphism `m`. -/
def FixedBy.subfield : Subfield F where
  carrier := fixedBy M F m
  zero_mem' := smul_zero m
  add_mem' x y hx hy := (smul_add m x y).trans <| congr_arg₂ _ hx hy
  neg_mem' x hx := (smul_neg m x).trans <| congr_arg _ hx
  one_mem' := smul_one m
  mul_mem' x y hx hy := (smul_mul' m x y).trans <| congr_arg₂ _ hx hy
  inv_mem' x hx := (smul_inv'' m x).trans <| congr_arg _ hx
#align fixed_by.subfield FixedBy.subfield
-/

section InvariantSubfields

variable (M) {F}

#print IsInvariantSubfield /-
/-- A typeclass for subrings invariant under a `mul_semiring_action`. -/
class IsInvariantSubfield (S : Subfield F) : Prop where
  smul_mem : ∀ (m : M) {x : F}, x ∈ S → m • x ∈ S
#align is_invariant_subfield IsInvariantSubfield
-/

variable (S : Subfield F)

#print IsInvariantSubfield.toMulSemiringAction /-
instance IsInvariantSubfield.toMulSemiringAction [IsInvariantSubfield M S] : MulSemiringAction M S
    where
  smul m x := ⟨m • x, IsInvariantSubfield.smul_mem m x.2⟩
  one_smul s := Subtype.eq <| one_smul M s
  mul_smul m₁ m₂ s := Subtype.eq <| mul_smul m₁ m₂ s
  smul_add m s₁ s₂ := Subtype.eq <| smul_add m s₁ s₂
  smul_zero m := Subtype.eq <| smul_zero m
  smul_one m := Subtype.eq <| smul_one m
  smul_mul m s₁ s₂ := Subtype.eq <| smul_mul' m s₁ s₂
#align is_invariant_subfield.to_mul_semiring_action IsInvariantSubfield.toMulSemiringAction
-/

instance [IsInvariantSubfield M S] : IsInvariantSubring M S.toSubring
    where smul_mem := IsInvariantSubfield.smul_mem

end InvariantSubfields

namespace FixedPoints

variable (M)

#print FixedPoints.subfield /-
-- we use `subfield.copy` so that the underlying set is `fixed_points M F`
/-- The subfield of fixed points by a monoid action. -/
def subfield : Subfield F :=
  Subfield.copy (⨅ m : M, FixedBy.subfield F m) (fixedPoints M F)
    (by ext z; simp [fixed_points, FixedBy.subfield, iInf, Subfield.mem_sInf])
#align fixed_points.subfield FixedPoints.subfield
-/

instance : IsInvariantSubfield M (FixedPoints.subfield M F)
    where smul_mem g x hx g' := by rw [hx, hx]

instance : SMulCommClass M (FixedPoints.subfield M F) F
    where smul_comm m f f' := show m • (↑f * f') = f * m • f' by rw [smul_mul', f.prop m]

#print FixedPoints.smulCommClass' /-
instance smulCommClass' : SMulCommClass (FixedPoints.subfield M F) M F :=
  SMulCommClass.symm _ _ _
#align fixed_points.smul_comm_class' FixedPoints.smulCommClass'
-/

#print FixedPoints.smul /-
@[simp]
theorem smul (m : M) (x : FixedPoints.subfield M F) : m • x = x :=
  Subtype.eq <| x.2 m
#align fixed_points.smul FixedPoints.smul
-/

#print FixedPoints.smul_polynomial /-
-- Why is this so slow?
@[simp]
theorem smul_polynomial (m : M) (p : Polynomial (FixedPoints.subfield M F)) : m • p = p :=
  Polynomial.induction_on p (fun x => by rw [Polynomial.smul_C, smul])
    (fun p q ihp ihq => by rw [smul_add, ihp, ihq]) fun n x ih => by
    rw [smul_mul', Polynomial.smul_C, smul, smul_pow', Polynomial.smul_X]
#align fixed_points.smul_polynomial FixedPoints.smul_polynomial
-/

instance : Algebra (FixedPoints.subfield M F) F := by infer_instance

#print FixedPoints.coe_algebraMap /-
theorem coe_algebraMap :
    algebraMap (FixedPoints.subfield M F) F = Subfield.subtype (FixedPoints.subfield M F) :=
  rfl
#align fixed_points.coe_algebra_map FixedPoints.coe_algebraMap
-/

#print FixedPoints.linearIndependent_smul_of_linearIndependent /-
theorem linearIndependent_smul_of_linearIndependent {s : Finset F} :
    (LinearIndependent (FixedPoints.subfield G F) fun i : (s : Set F) => (i : F)) →
      LinearIndependent F fun i : (s : Set F) => MulAction.toFun G F i :=
  by
  haveI : IsEmpty ((∅ : Finset F) : Set F) := ⟨Subtype.prop⟩
  refine' Finset.induction_on s (fun _ => linearIndependent_empty_type) fun a s has ih hs => _
  rw [coe_insert] at hs ⊢
  rw [linearIndependent_insert (mt mem_coe.1 has)] at hs 
  rw [linearIndependent_insert' (mt mem_coe.1 has)]; refine' ⟨ih hs.1, fun ha => _⟩
  rw [Finsupp.mem_span_image_iff_total] at ha ; rcases ha with ⟨l, hl, hla⟩
  rw [Finsupp.total_apply_of_mem_supported F hl] at hla 
  suffices ∀ i ∈ s, l i ∈ FixedPoints.subfield G F
    by
    replace hla := (sum_apply _ _ fun i => l i • to_fun G F i).symm.trans (congr_fun hla 1)
    simp_rw [Pi.smul_apply, to_fun_apply, one_smul] at hla 
    refine' hs.2 (hla ▸ Submodule.sum_mem _ fun c hcs => _)
    change (⟨l c, this c hcs⟩ : FixedPoints.subfield G F) • c ∈ _
    exact Submodule.smul_mem _ _ (Submodule.subset_span <| mem_coe.2 hcs)
  intro i his g
  refine'
    eq_of_sub_eq_zero
      (linearIndependent_iff'.1 (ih hs.1) s.attach (fun i => g • l i - l i) _ ⟨i, his⟩
          (mem_attach _ _) :
        _)
  refine' (@sum_attach _ _ s _ fun i => (g • l i - l i) • MulAction.toFun G F i).trans _
  ext g'; dsimp only
  conv_lhs =>
    rw [sum_apply]
    congr
    skip
    ext
    rw [Pi.smul_apply, sub_smul, smul_eq_mul]
  rw [sum_sub_distrib, Pi.zero_apply, sub_eq_zero]
  conv_lhs =>
    congr
    skip
    ext
    rw [to_fun_apply, ← mul_inv_cancel_left g g', mul_smul, ← smul_mul', ← to_fun_apply _ x]
  show
    ∑ x in s, g • (fun y => l y • MulAction.toFun G F y) x (g⁻¹ * g') =
      ∑ x in s, (fun y => l y • MulAction.toFun G F y) x g'
  rw [← smul_sum, ← sum_apply _ _ fun y => l y • to_fun G F y, ←
    sum_apply _ _ fun y => l y • to_fun G F y]
  dsimp only
  rw [hla, to_fun_apply, to_fun_apply, smul_smul, mul_inv_cancel_left]
#align fixed_points.linear_independent_smul_of_linear_independent FixedPoints.linearIndependent_smul_of_linearIndependent
-/

section Fintype

variable [Fintype G] (x : F)

#print FixedPoints.minpoly /-
/-- `minpoly G F x` is the minimal polynomial of `(x : F)` over `fixed_points G F`. -/
def minpoly : Polynomial (FixedPoints.subfield G F) :=
  (prodXSubSmul G F x).toSubring (FixedPoints.subfield G F).toSubring fun c hc g =>
    let ⟨n, hc0, hn⟩ := Polynomial.mem_frange_iff.1 hc
    hn.symm ▸ prodXSubSmul.coeff G F x g n
#align fixed_points.minpoly FixedPoints.minpoly
-/

namespace minpoly

#print FixedPoints.minpoly.monic /-
theorem monic : (minpoly G F x).Monic := by simp only [minpoly, Polynomial.monic_toSubring];
  exact prodXSubSmul.monic G F x
#align fixed_points.minpoly.monic FixedPoints.minpoly.monic
-/

#print FixedPoints.minpoly.eval₂ /-
theorem eval₂ :
    Polynomial.eval₂ (Subring.subtype <| (FixedPoints.subfield G F).toSubring) x (minpoly G F x) =
      0 :=
  by
  rw [← prodXSubSmul.eval G F x, Polynomial.eval₂_eq_eval_map]
  simp only [minpoly, Polynomial.map_toSubring]
#align fixed_points.minpoly.eval₂ FixedPoints.minpoly.eval₂
-/

#print FixedPoints.minpoly.eval₂' /-
theorem eval₂' :
    Polynomial.eval₂ (Subfield.subtype <| FixedPoints.subfield G F) x (minpoly G F x) = 0 :=
  eval₂ G F x
#align fixed_points.minpoly.eval₂' FixedPoints.minpoly.eval₂'
-/

#print FixedPoints.minpoly.ne_one /-
theorem ne_one : minpoly G F x ≠ (1 : Polynomial (FixedPoints.subfield G F)) := fun H =>
  have := eval₂ G F x
  (one_ne_zero : (1 : F) ≠ 0) <| by rwa [H, Polynomial.eval₂_one] at this 
#align fixed_points.minpoly.ne_one FixedPoints.minpoly.ne_one
-/

#print FixedPoints.minpoly.of_eval₂ /-
theorem of_eval₂ (f : Polynomial (FixedPoints.subfield G F))
    (hf : Polynomial.eval₂ (Subfield.subtype <| FixedPoints.subfield G F) x f = 0) :
    minpoly G F x ∣ f :=
  by
  erw [← Polynomial.map_dvd_map' (Subfield.subtype <| FixedPoints.subfield G F), minpoly,
    Polynomial.map_toSubring _ (Subfield G F).toSubring, prodXSubSmul]
  refine'
    Fintype.prod_dvd_of_coprime
      (Polynomial.pairwise_coprime_X_sub_C <| MulAction.injective_ofQuotientStabilizer G x) fun y =>
      QuotientGroup.induction_on y fun g => _
  rw [Polynomial.dvd_iff_isRoot, Polynomial.IsRoot.def, MulAction.ofQuotientStabilizer_mk,
    Polynomial.eval_smul', ← Subfield.toSubring_subtype_eq_subtype, ←
    IsInvariantSubring.coe_subtypeHom' G (FixedPoints.subfield G F).toSubring, ←
    MulSemiringActionHom.coe_polynomial, ← MulSemiringActionHom.map_smul, smul_polynomial,
    MulSemiringActionHom.coe_polynomial, IsInvariantSubring.coe_subtypeHom', Polynomial.eval_map,
    Subfield.toSubring_subtype_eq_subtype, hf, smul_zero]
#align fixed_points.minpoly.of_eval₂ FixedPoints.minpoly.of_eval₂
-/

#print FixedPoints.minpoly.irreducible_aux /-
-- Why is this so slow?
theorem irreducible_aux (f g : Polynomial (FixedPoints.subfield G F)) (hf : f.Monic) (hg : g.Monic)
    (hfg : f * g = minpoly G F x) : f = 1 ∨ g = 1 :=
  by
  have hf2 : f ∣ minpoly G F x := by rw [← hfg]; exact dvd_mul_right _ _
  have hg2 : g ∣ minpoly G F x := by rw [← hfg]; exact dvd_mul_left _ _
  have := eval₂ G F x
  rw [← hfg, Polynomial.eval₂_mul, mul_eq_zero] at this 
  cases this
  · right
    have hf3 : f = minpoly G F x :=
      Polynomial.eq_of_monic_of_associated hf (monic G F x)
        (associated_of_dvd_dvd hf2 <| @of_eval₂ G _ F _ _ _ x f this)
    rwa [← mul_one (minpoly G F x), hf3, mul_right_inj' (monic G F x).NeZero] at hfg 
  · left
    have hg3 : g = minpoly G F x :=
      Polynomial.eq_of_monic_of_associated hg (monic G F x)
        (associated_of_dvd_dvd hg2 <| @of_eval₂ G _ F _ _ _ x g this)
    rwa [← one_mul (minpoly G F x), hg3, mul_left_inj' (monic G F x).NeZero] at hfg 
#align fixed_points.minpoly.irreducible_aux FixedPoints.minpoly.irreducible_aux
-/

#print FixedPoints.minpoly.irreducible /-
theorem irreducible : Irreducible (minpoly G F x) :=
  (Polynomial.irreducible_of_monic (monic G F x) (ne_one G F x)).2 (irreducible_aux G F x)
#align fixed_points.minpoly.irreducible FixedPoints.minpoly.irreducible
-/

end minpoly

end Fintype

#print FixedPoints.isIntegral /-
theorem isIntegral [Finite G] (x : F) : IsIntegral (FixedPoints.subfield G F) x := by
  cases nonempty_fintype G; exact ⟨minpoly G F x, minpoly.monic G F x, minpoly.eval₂ G F x⟩
#align fixed_points.is_integral FixedPoints.isIntegral
-/

section Fintype

variable [Fintype G] (x : F)

#print FixedPoints.minpoly_eq_minpoly /-
theorem minpoly_eq_minpoly : minpoly G F x = minpoly (FixedPoints.subfield G F) x :=
  minpoly.eq_of_irreducible_of_monic (minpoly.irreducible G F x) (minpoly.eval₂ G F x)
    (minpoly.monic G F x)
#align fixed_points.minpoly_eq_minpoly FixedPoints.minpoly_eq_minpoly
-/

#print FixedPoints.rank_le_card /-
theorem rank_le_card : Module.rank (FixedPoints.subfield G F) F ≤ Fintype.card G :=
  rank_le fun s hs => by
    simpa only [rank_fun', Cardinal.mk_coe_finset, Finset.coe_sort_coe, Cardinal.lift_natCast,
      Cardinal.natCast_le] using
      cardinal_lift_le_rank_of_linearIndependent'
        (linear_independent_smul_of_linear_independent G F hs)
#align fixed_points.rank_le_card FixedPoints.rank_le_card
-/

end Fintype

section Finite

variable [Finite G]

#print FixedPoints.normal /-
instance normal : Normal (FixedPoints.subfield G F) F :=
  ⟨fun x => (isIntegral G F x).IsAlgebraic _, fun x =>
    (Polynomial.splits_id_iff_splits _).1 <|
      by
      cases nonempty_fintype G
      rw [← minpoly_eq_minpoly, minpoly, coe_algebra_map, ← Subfield.toSubring_subtype_eq_subtype,
        Polynomial.map_toSubring _ (Subfield G F).toSubring, prodXSubSmul]
      exact Polynomial.splits_prod _ fun _ _ => Polynomial.splits_X_sub_C _⟩
#align fixed_points.normal FixedPoints.normal
-/

#print FixedPoints.separable /-
instance separable : IsSeparable (FixedPoints.subfield G F) F :=
  ⟨isIntegral G F, fun x => by
    cases nonempty_fintype G
    -- this was a plain rw when we were using unbundled subrings
    erw [← minpoly_eq_minpoly, ← Polynomial.separable_map (FixedPoints.subfield G F).Subtype,
      minpoly, Polynomial.map_toSubring _ (Subfield G F).toSubring]
    exact Polynomial.separable_prod_X_sub_C_iff.2 (injective_of_quotient_stabilizer G x)⟩
#align fixed_points.separable FixedPoints.separable
-/

instance : FiniteDimensional (subfield G F) F := by cases nonempty_fintype G;
  exact
    IsNoetherian.iff_fg.1
      (IsNoetherian.iff_rank_lt_aleph0.2 <| (rank_le_card G F).trans_lt <| Cardinal.nat_lt_aleph0 _)

end Finite

#print FixedPoints.finrank_le_card /-
theorem finrank_le_card [Fintype G] : finrank (subfield G F) F ≤ Fintype.card G :=
  by
  rw [← Cardinal.natCast_le, finrank_eq_rank]
  apply rank_le_card
#align fixed_points.finrank_le_card FixedPoints.finrank_le_card
-/

end FixedPoints

#print linearIndependent_toLinearMap /-
theorem linearIndependent_toLinearMap (R : Type u) (A : Type v) (B : Type w) [CommSemiring R]
    [Ring A] [Algebra R A] [CommRing B] [IsDomain B] [Algebra R B] :
    LinearIndependent B (AlgHom.toLinearMap : (A →ₐ[R] B) → A →ₗ[R] B) :=
  have : LinearIndependent B (LinearMap.ltoFun R A B ∘ AlgHom.toLinearMap) :=
    ((linearIndependent_monoidHom A B).comp (coe : (A →ₐ[R] B) → A →* B) fun f g hfg =>
        AlgHom.ext <| MonoidHom.ext_iff.1 hfg :
      _)
  this.of_comp _
#align linear_independent_to_linear_map linearIndependent_toLinearMap
-/

#print cardinal_mk_algHom /-
theorem cardinal_mk_algHom (K : Type u) (V : Type v) (W : Type w) [Field K] [Field V] [Algebra K V]
    [FiniteDimensional K V] [Field W] [Algebra K W] [FiniteDimensional K W] :
    Cardinal.mk (V →ₐ[K] W) ≤ finrank W (V →ₗ[K] W) :=
  cardinal_mk_le_finrank_of_linearIndependent <| linearIndependent_toLinearMap K V W
#align cardinal_mk_alg_hom cardinal_mk_algHom
-/

#print AlgEquiv.fintype /-
noncomputable instance AlgEquiv.fintype (K : Type u) (V : Type v) [Field K] [Field V] [Algebra K V]
    [FiniteDimensional K V] : Fintype (V ≃ₐ[K] V) :=
  Fintype.ofEquiv (V →ₐ[K] V) (algEquivEquivAlgHom K V).symm
#align alg_equiv.fintype AlgEquiv.fintype
-/

#print finrank_algHom /-
theorem finrank_algHom (K : Type u) (V : Type v) [Field K] [Field V] [Algebra K V]
    [FiniteDimensional K V] : Fintype.card (V →ₐ[K] V) ≤ finrank V (V →ₗ[K] V) :=
  fintype_card_le_finrank_of_linearIndependent <| linearIndependent_toLinearMap K V V
#align finrank_alg_hom finrank_algHom
-/

namespace FixedPoints

#print FixedPoints.finrank_eq_card /-
theorem finrank_eq_card (G : Type u) (F : Type v) [Group G] [Field F] [Fintype G]
    [MulSemiringAction G F] [FaithfulSMul G F] :
    finrank (FixedPoints.subfield G F) F = Fintype.card G :=
  le_antisymm (FixedPoints.finrank_le_card G F) <|
    calc
      Fintype.card G ≤ Fintype.card (F →ₐ[FixedPoints.subfield G F] F) :=
        Fintype.card_le_of_injective _ (MulSemiringAction.toAlgHom_injective _ F)
      _ ≤ finrank F (F →ₗ[FixedPoints.subfield G F] F) := (finrank_algHom (fixedPoints G F) F)
      _ = finrank (FixedPoints.subfield G F) F := finrank_linear_map' _ _ _
#align fixed_points.finrank_eq_card FixedPoints.finrank_eq_card
-/

#print FixedPoints.toAlgHom_bijective /-
/-- `mul_semiring_action.to_alg_hom` is bijective. -/
theorem toAlgHom_bijective (G : Type u) (F : Type v) [Group G] [Field F] [Finite G]
    [MulSemiringAction G F] [FaithfulSMul G F] :
    Function.Bijective (MulSemiringAction.toAlgHom _ _ : G → F →ₐ[subfield G F] F) :=
  by
  cases nonempty_fintype G
  rw [Fintype.bijective_iff_injective_and_card]
  constructor
  · exact MulSemiringAction.toAlgHom_injective _ F
  · apply le_antisymm
    · exact Fintype.card_le_of_injective _ (MulSemiringAction.toAlgHom_injective _ F)
    · rw [← finrank_eq_card G F]
      exact LE.le.trans_eq (finrank_algHom _ F) (finrank_linear_map' _ _ _)
#align fixed_points.to_alg_hom_bijective FixedPoints.toAlgHom_bijective
-/

#print FixedPoints.toAlgHomEquiv /-
/-- Bijection between G and algebra homomorphisms that fix the fixed points -/
def toAlgHomEquiv (G : Type u) (F : Type v) [Group G] [Field F] [Fintype G] [MulSemiringAction G F]
    [FaithfulSMul G F] : G ≃ (F →ₐ[FixedPoints.subfield G F] F) :=
  Equiv.ofBijective _ (toAlgHom_bijective G F)
#align fixed_points.to_alg_hom_equiv FixedPoints.toAlgHomEquiv
-/

end FixedPoints

