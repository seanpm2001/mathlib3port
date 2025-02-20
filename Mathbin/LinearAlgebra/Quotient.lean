/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Kevin Buzzard, Yury Kudryashov

! This file was ported from Lean 3 source module linear_algebra.quotient
! leanprover-community/mathlib commit 23aa88e32dcc9d2a24cca7bc23268567ed4cd7d6
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.QuotientGroup
import Mathbin.LinearAlgebra.Span

/-!
# Quotients by submodules

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

* If `p` is a submodule of `M`, `M ⧸ p` is the quotient of `M` with respect to `p`:
  that is, elements of `M` are identified if their difference is in `p`. This is itself a module.

-/


-- For most of this file we work over a noncommutative ring
section Ring

namespace Submodule

variable {R M : Type _} {r : R} {x y : M} [Ring R] [AddCommGroup M] [Module R M]

variable (p p' : Submodule R M)

open LinearMap quotientAddGroup

#print Submodule.quotientRel /-
/-- The equivalence relation associated to a submodule `p`, defined by `x ≈ y` iff `-x + y ∈ p`.

Note this is equivalent to `y - x ∈ p`, but defined this way to be be defeq to the `add_subgroup`
version, where commutativity can't be assumed. -/
def quotientRel : Setoid M :=
  QuotientAddGroup.leftRel p.toAddSubgroup
#align submodule.quotient_rel Submodule.quotientRel
-/

#print Submodule.quotientRel_r_def /-
theorem quotientRel_r_def {x y : M} : @Setoid.r _ p.quotientRel x y ↔ x - y ∈ p :=
  Iff.trans (by rw [left_rel_apply, sub_eq_add_neg, neg_add, neg_neg]; rfl) neg_mem_iff
#align submodule.quotient_rel_r_def Submodule.quotientRel_r_def
-/

#print Submodule.hasQuotient /-
/-- The quotient of a module `M` by a submodule `p ⊆ M`. -/
instance hasQuotient : HasQuotient M (Submodule R M) :=
  ⟨fun p => Quotient (quotientRel p)⟩
#align submodule.has_quotient Submodule.hasQuotient
-/

namespace Quotient

#print Submodule.Quotient.mk /-
/-- Map associating to an element of `M` the corresponding element of `M/p`,
when `p` is a submodule of `M`. -/
def mk {p : Submodule R M} : M → M ⧸ p :=
  Quotient.mk''
#align submodule.quotient.mk Submodule.Quotient.mk
-/

#print Submodule.Quotient.mk'_eq_mk' /-
@[simp]
theorem mk'_eq_mk' {p : Submodule R M} (x : M) : @Quotient.mk' _ (quotientRel p) x = mk x :=
  rfl
#align submodule.quotient.mk_eq_mk Submodule.Quotient.mk'_eq_mk'
-/

#print Submodule.Quotient.mk''_eq_mk /-
@[simp]
theorem mk''_eq_mk {p : Submodule R M} (x : M) : (Quotient.mk'' x : M ⧸ p) = mk x :=
  rfl
#align submodule.quotient.mk'_eq_mk Submodule.Quotient.mk''_eq_mk
-/

#print Submodule.Quotient.quot_mk_eq_mk /-
@[simp]
theorem quot_mk_eq_mk {p : Submodule R M} (x : M) : (Quot.mk _ x : M ⧸ p) = mk x :=
  rfl
#align submodule.quotient.quot_mk_eq_mk Submodule.Quotient.quot_mk_eq_mk
-/

#print Submodule.Quotient.eq' /-
protected theorem eq' {x y : M} : (mk x : M ⧸ p) = mk y ↔ -x + y ∈ p :=
  QuotientAddGroup.eq
#align submodule.quotient.eq' Submodule.Quotient.eq'
-/

#print Submodule.Quotient.eq /-
protected theorem eq {x y : M} : (mk x : M ⧸ p) = mk y ↔ x - y ∈ p :=
  p.Quotient.eq''.trans (leftRel_apply.symm.trans p.quotientRel_r_def)
#align submodule.quotient.eq Submodule.Quotient.eq
-/

instance : Zero (M ⧸ p) :=
  ⟨mk 0⟩

instance : Inhabited (M ⧸ p) :=
  ⟨0⟩

#print Submodule.Quotient.mk_zero /-
@[simp]
theorem mk_zero : mk 0 = (0 : M ⧸ p) :=
  rfl
#align submodule.quotient.mk_zero Submodule.Quotient.mk_zero
-/

#print Submodule.Quotient.mk_eq_zero /-
@[simp]
theorem mk_eq_zero : (mk x : M ⧸ p) = 0 ↔ x ∈ p := by simpa using (Quotient.eq' p : mk x = 0 ↔ _)
#align submodule.quotient.mk_eq_zero Submodule.Quotient.mk_eq_zero
-/

#print Submodule.Quotient.addCommGroup /-
instance addCommGroup : AddCommGroup (M ⧸ p) :=
  QuotientAddGroup.Quotient.addCommGroup p.toAddSubgroup
#align submodule.quotient.add_comm_group Submodule.Quotient.addCommGroup
-/

#print Submodule.Quotient.mk_add /-
@[simp]
theorem mk_add : (mk (x + y) : M ⧸ p) = mk x + mk y :=
  rfl
#align submodule.quotient.mk_add Submodule.Quotient.mk_add
-/

#print Submodule.Quotient.mk_neg /-
@[simp]
theorem mk_neg : (mk (-x) : M ⧸ p) = -mk x :=
  rfl
#align submodule.quotient.mk_neg Submodule.Quotient.mk_neg
-/

#print Submodule.Quotient.mk_sub /-
@[simp]
theorem mk_sub : (mk (x - y) : M ⧸ p) = mk x - mk y :=
  rfl
#align submodule.quotient.mk_sub Submodule.Quotient.mk_sub
-/

section SMul

variable {S : Type _} [SMul S R] [SMul S M] [IsScalarTower S R M] (P : Submodule R M)

#print Submodule.Quotient.hasSmul' /-
instance hasSmul' : SMul S (M ⧸ P) :=
  ⟨fun a =>
    Quotient.map' ((· • ·) a) fun x y h =>
      leftRel_apply.mpr <| by simpa [smul_sub] using P.smul_mem (a • 1 : R) (left_rel_apply.mp h)⟩
#align submodule.quotient.has_smul' Submodule.Quotient.hasSmul'
-/

#print Submodule.Quotient.hasSmul /-
/-- Shortcut to help the elaborator in the common case. -/
instance hasSmul : SMul R (M ⧸ P) :=
  Quotient.hasSmul' P
#align submodule.quotient.has_smul Submodule.Quotient.hasSmul
-/

#print Submodule.Quotient.mk_smul /-
@[simp]
theorem mk_smul (r : S) (x : M) : (mk (r • x) : M ⧸ p) = r • mk x :=
  rfl
#align submodule.quotient.mk_smul Submodule.Quotient.mk_smul
-/

#print Submodule.Quotient.smulCommClass /-
instance smulCommClass (T : Type _) [SMul T R] [SMul T M] [IsScalarTower T R M]
    [SMulCommClass S T M] : SMulCommClass S T (M ⧸ P)
    where smul_comm x y := Quotient.ind' fun z => congr_arg mk (smul_comm _ _ _)
#align submodule.quotient.smul_comm_class Submodule.Quotient.smulCommClass
-/

#print Submodule.Quotient.isScalarTower /-
instance isScalarTower (T : Type _) [SMul T R] [SMul T M] [IsScalarTower T R M] [SMul S T]
    [IsScalarTower S T M] : IsScalarTower S T (M ⧸ P)
    where smul_assoc x y := Quotient.ind' fun z => congr_arg mk (smul_assoc _ _ _)
#align submodule.quotient.is_scalar_tower Submodule.Quotient.isScalarTower
-/

#print Submodule.Quotient.isCentralScalar /-
instance isCentralScalar [SMul Sᵐᵒᵖ R] [SMul Sᵐᵒᵖ M] [IsScalarTower Sᵐᵒᵖ R M]
    [IsCentralScalar S M] : IsCentralScalar S (M ⧸ P)
    where op_smul_eq_smul x := Quotient.ind' fun z => congr_arg mk <| op_smul_eq_smul _ _
#align submodule.quotient.is_central_scalar Submodule.Quotient.isCentralScalar
-/

end SMul

section Module

variable {S : Type _}

#print Submodule.Quotient.mulAction' /-
instance mulAction' [Monoid S] [SMul S R] [MulAction S M] [IsScalarTower S R M]
    (P : Submodule R M) : MulAction S (M ⧸ P) :=
  Function.Surjective.mulAction mk (surjective_quot_mk _) P.Quotient.mk_smul
#align submodule.quotient.mul_action' Submodule.Quotient.mulAction'
-/

#print Submodule.Quotient.mulAction /-
instance mulAction (P : Submodule R M) : MulAction R (M ⧸ P) :=
  Quotient.mulAction' P
#align submodule.quotient.mul_action Submodule.Quotient.mulAction
-/

#print Submodule.Quotient.smulZeroClass' /-
instance smulZeroClass' [SMul S R] [SMulZeroClass S M] [IsScalarTower S R M] (P : Submodule R M) :
    SMulZeroClass S (M ⧸ P) :=
  ZeroHom.smulZeroClass ⟨mk, mk_zero _⟩ P.Quotient.mk_smul
#align submodule.quotient.smul_zero_class' Submodule.Quotient.smulZeroClass'
-/

#print Submodule.Quotient.smulZeroClass /-
instance smulZeroClass (P : Submodule R M) : SMulZeroClass R (M ⧸ P) :=
  Quotient.smulZeroClass' P
#align submodule.quotient.smul_zero_class Submodule.Quotient.smulZeroClass
-/

#print Submodule.Quotient.distribSmul' /-
instance distribSmul' [SMul S R] [DistribSMul S M] [IsScalarTower S R M] (P : Submodule R M) :
    DistribSMul S (M ⧸ P) :=
  Function.Surjective.distribSMul ⟨mk, rfl, fun _ _ => rfl⟩ (surjective_quot_mk _)
    P.Quotient.mk_smul
#align submodule.quotient.distrib_smul' Submodule.Quotient.distribSmul'
-/

#print Submodule.Quotient.distribSmul /-
instance distribSmul (P : Submodule R M) : DistribSMul R (M ⧸ P) :=
  Quotient.distribSmul' P
#align submodule.quotient.distrib_smul Submodule.Quotient.distribSmul
-/

#print Submodule.Quotient.distribMulAction' /-
instance distribMulAction' [Monoid S] [SMul S R] [DistribMulAction S M] [IsScalarTower S R M]
    (P : Submodule R M) : DistribMulAction S (M ⧸ P) :=
  Function.Surjective.distribMulAction ⟨mk, rfl, fun _ _ => rfl⟩ (surjective_quot_mk _)
    P.Quotient.mk_smul
#align submodule.quotient.distrib_mul_action' Submodule.Quotient.distribMulAction'
-/

#print Submodule.Quotient.distribMulAction /-
instance distribMulAction (P : Submodule R M) : DistribMulAction R (M ⧸ P) :=
  Quotient.distribMulAction' P
#align submodule.quotient.distrib_mul_action Submodule.Quotient.distribMulAction
-/

#print Submodule.Quotient.module' /-
instance module' [Semiring S] [SMul S R] [Module S M] [IsScalarTower S R M] (P : Submodule R M) :
    Module S (M ⧸ P) :=
  Function.Surjective.module _ ⟨mk, rfl, fun _ _ => rfl⟩ (surjective_quot_mk _) P.Quotient.mk_smul
#align submodule.quotient.module' Submodule.Quotient.module'
-/

#print Submodule.Quotient.module /-
instance module (P : Submodule R M) : Module R (M ⧸ P) :=
  Quotient.module' P
#align submodule.quotient.module Submodule.Quotient.module
-/

variable (S)

#print Submodule.Quotient.restrictScalarsEquiv /-
/-- The quotient of `P` as an `S`-submodule is the same as the quotient of `P` as an `R`-submodule,
where `P : submodule R M`.
-/
def restrictScalarsEquiv [Ring S] [SMul S R] [Module S M] [IsScalarTower S R M]
    (P : Submodule R M) : (M ⧸ P.restrictScalars S) ≃ₗ[S] M ⧸ P :=
  {
    Quotient.congrRight fun _ _ =>
      Iff.rfl with
    map_add' := fun x y => Quotient.inductionOn₂' x y fun x' y' => rfl
    map_smul' := fun c x => Quotient.inductionOn' x fun x' => rfl }
#align submodule.quotient.restrict_scalars_equiv Submodule.Quotient.restrictScalarsEquiv
-/

#print Submodule.Quotient.restrictScalarsEquiv_mk /-
@[simp]
theorem restrictScalarsEquiv_mk [Ring S] [SMul S R] [Module S M] [IsScalarTower S R M]
    (P : Submodule R M) (x : M) : restrictScalarsEquiv S P (mk x) = mk x :=
  rfl
#align submodule.quotient.restrict_scalars_equiv_mk Submodule.Quotient.restrictScalarsEquiv_mk
-/

#print Submodule.Quotient.restrictScalarsEquiv_symm_mk /-
@[simp]
theorem restrictScalarsEquiv_symm_mk [Ring S] [SMul S R] [Module S M] [IsScalarTower S R M]
    (P : Submodule R M) (x : M) : (restrictScalarsEquiv S P).symm (mk x) = mk x :=
  rfl
#align submodule.quotient.restrict_scalars_equiv_symm_mk Submodule.Quotient.restrictScalarsEquiv_symm_mk
-/

end Module

#print Submodule.Quotient.mk_surjective /-
theorem mk_surjective : Function.Surjective (@mk _ _ _ _ _ p) := by rintro ⟨x⟩; exact ⟨x, rfl⟩
#align submodule.quotient.mk_surjective Submodule.Quotient.mk_surjective
-/

#print Submodule.Quotient.nontrivial_of_lt_top /-
theorem nontrivial_of_lt_top (h : p < ⊤) : Nontrivial (M ⧸ p) :=
  by
  obtain ⟨x, _, not_mem_s⟩ := SetLike.exists_of_lt h
  refine' ⟨⟨mk x, 0, _⟩⟩
  simpa using not_mem_s
#align submodule.quotient.nontrivial_of_lt_top Submodule.Quotient.nontrivial_of_lt_top
-/

end Quotient

#print Submodule.QuotientBot.infinite /-
instance QuotientBot.infinite [Infinite M] : Infinite (M ⧸ (⊥ : Submodule R M)) :=
  Infinite.of_injective Submodule.Quotient.mk fun x y h =>
    sub_eq_zero.mp <| (Submodule.Quotient.eq ⊥).mp h
#align submodule.quotient_bot.infinite Submodule.QuotientBot.infinite
-/

#print Submodule.QuotientTop.unique /-
instance QuotientTop.unique : Unique (M ⧸ (⊤ : Submodule R M))
    where
  default := 0
  uniq x := Quotient.inductionOn' x fun x => (Submodule.Quotient.eq ⊤).mpr Submodule.mem_top
#align submodule.quotient_top.unique Submodule.QuotientTop.unique
-/

#print Submodule.QuotientTop.fintype /-
instance QuotientTop.fintype : Fintype (M ⧸ (⊤ : Submodule R M)) :=
  Fintype.ofSubsingleton 0
#align submodule.quotient_top.fintype Submodule.QuotientTop.fintype
-/

variable {p}

#print Submodule.subsingleton_quotient_iff_eq_top /-
theorem subsingleton_quotient_iff_eq_top : Subsingleton (M ⧸ p) ↔ p = ⊤ :=
  by
  constructor
  · rintro h
    refine' eq_top_iff.mpr fun x _ => _
    have : x - 0 ∈ p := (Submodule.Quotient.eq p).mp (Subsingleton.elim _ _)
    rwa [sub_zero] at this 
  · rintro rfl
    infer_instance
#align submodule.subsingleton_quotient_iff_eq_top Submodule.subsingleton_quotient_iff_eq_top
-/

#print Submodule.unique_quotient_iff_eq_top /-
theorem unique_quotient_iff_eq_top : Nonempty (Unique (M ⧸ p)) ↔ p = ⊤ :=
  ⟨fun ⟨h⟩ => subsingleton_quotient_iff_eq_top.mp (@Unique.subsingleton h), by rintro rfl;
    exact ⟨quotient_top.unique⟩⟩
#align submodule.unique_quotient_iff_eq_top Submodule.unique_quotient_iff_eq_top
-/

variable (p)

#print Submodule.Quotient.fintype /-
noncomputable instance Quotient.fintype [Fintype M] (S : Submodule R M) : Fintype (M ⧸ S) :=
  @Quotient.fintype _ _ fun _ _ => Classical.dec _
#align submodule.quotient.fintype Submodule.Quotient.fintype
-/

#print Submodule.card_eq_card_quotient_mul_card /-
theorem card_eq_card_quotient_mul_card [Fintype M] (S : Submodule R M) [DecidablePred (· ∈ S)] :
    Fintype.card M = Fintype.card S * Fintype.card (M ⧸ S) :=
  by
  rw [mul_comm, ← Fintype.card_prod]
  exact Fintype.card_congr AddSubgroup.addGroupEquivQuotientProdAddSubgroup
#align submodule.card_eq_card_quotient_mul_card Submodule.card_eq_card_quotient_mul_card
-/

section

variable {M₂ : Type _} [AddCommGroup M₂] [Module R M₂]

#print Submodule.quot_hom_ext /-
theorem quot_hom_ext ⦃f g : M ⧸ p →ₗ[R] M₂⦄ (h : ∀ x, f (Quotient.mk x) = g (Quotient.mk x)) :
    f = g :=
  LinearMap.ext fun x => Quotient.inductionOn' x h
#align submodule.quot_hom_ext Submodule.quot_hom_ext
-/

#print Submodule.mkQ /-
/-- The map from a module `M` to the quotient of `M` by a submodule `p` as a linear map. -/
def mkQ : M →ₗ[R] M ⧸ p where
  toFun := Quotient.mk
  map_add' := by simp
  map_smul' := by simp
#align submodule.mkq Submodule.mkQ
-/

#print Submodule.mkQ_apply /-
@[simp]
theorem mkQ_apply (x : M) : p.mkQ x = Quotient.mk x :=
  rfl
#align submodule.mkq_apply Submodule.mkQ_apply
-/

#print Submodule.mkQ_surjective /-
theorem mkQ_surjective (A : Submodule R M) : Function.Surjective A.mkQ := by
  rintro ⟨x⟩ <;> exact ⟨x, rfl⟩
#align submodule.mkq_surjective Submodule.mkQ_surjective
-/

end

variable {R₂ M₂ : Type _} [Ring R₂] [AddCommGroup M₂] [Module R₂ M₂] {τ₁₂ : R →+* R₂}

#print Submodule.linearMap_qext /-
/-- Two `linear_map`s from a quotient module are equal if their compositions with
`submodule.mkq` are equal.

See note [partially-applied ext lemmas]. -/
@[ext]
theorem linearMap_qext ⦃f g : M ⧸ p →ₛₗ[τ₁₂] M₂⦄ (h : f.comp p.mkQ = g.comp p.mkQ) : f = g :=
  LinearMap.ext fun x => Quotient.inductionOn' x <| (LinearMap.congr_fun h : _)
#align submodule.linear_map_qext Submodule.linearMap_qext
-/

#print Submodule.liftQ /-
/-- The map from the quotient of `M` by a submodule `p` to `M₂` induced by a linear map `f : M → M₂`
vanishing on `p`, as a linear map. -/
def liftQ (f : M →ₛₗ[τ₁₂] M₂) (h : p ≤ f.ker) : M ⧸ p →ₛₗ[τ₁₂] M₂ :=
  { QuotientAddGroup.lift p.toAddSubgroup f.toAddMonoidHom h with
    map_smul' := by rintro a ⟨x⟩ <;> exact f.map_smulₛₗ a x }
#align submodule.liftq Submodule.liftQ
-/

#print Submodule.liftQ_apply /-
@[simp]
theorem liftQ_apply (f : M →ₛₗ[τ₁₂] M₂) {h} (x : M) : p.liftQ f h (Quotient.mk x) = f x :=
  rfl
#align submodule.liftq_apply Submodule.liftQ_apply
-/

#print Submodule.liftQ_mkQ /-
@[simp]
theorem liftQ_mkQ (f : M →ₛₗ[τ₁₂] M₂) (h) : (p.liftQ f h).comp p.mkQ = f := by ext <;> rfl
#align submodule.liftq_mkq Submodule.liftQ_mkQ
-/

#print Submodule.liftQSpanSingleton /-
/-- Special case of `liftq` when `p` is the span of `x`. In this case, the condition on `f` simply
becomes vanishing at `x`.-/
def liftQSpanSingleton (x : M) (f : M →ₛₗ[τ₁₂] M₂) (h : f x = 0) : (M ⧸ R ∙ x) →ₛₗ[τ₁₂] M₂ :=
  (R ∙ x).liftQ f <| by rw [span_singleton_le_iff_mem, LinearMap.mem_ker, h]
#align submodule.liftq_span_singleton Submodule.liftQSpanSingleton
-/

#print Submodule.liftQSpanSingleton_apply /-
@[simp]
theorem liftQSpanSingleton_apply (x : M) (f : M →ₛₗ[τ₁₂] M₂) (h : f x = 0) (y : M) :
    liftQSpanSingleton x f h (Quotient.mk y) = f y :=
  rfl
#align submodule.liftq_span_singleton_apply Submodule.liftQSpanSingleton_apply
-/

#print Submodule.range_mkQ /-
@[simp]
theorem range_mkQ : p.mkQ.range = ⊤ :=
  eq_top_iff'.2 <| by rintro ⟨x⟩ <;> exact ⟨x, rfl⟩
#align submodule.range_mkq Submodule.range_mkQ
-/

#print Submodule.ker_mkQ /-
@[simp]
theorem ker_mkQ : p.mkQ.ker = p := by ext <;> simp
#align submodule.ker_mkq Submodule.ker_mkQ
-/

#print Submodule.le_comap_mkQ /-
theorem le_comap_mkQ (p' : Submodule R (M ⧸ p)) : p ≤ comap p.mkQ p' := by
  simpa using (comap_mono bot_le : p.mkq.ker ≤ comap p.mkq p')
#align submodule.le_comap_mkq Submodule.le_comap_mkQ
-/

#print Submodule.mkQ_map_self /-
@[simp]
theorem mkQ_map_self : map p.mkQ p = ⊥ := by
  rw [eq_bot_iff, map_le_iff_le_comap, comap_bot, ker_mkq] <;> exact le_rfl
#align submodule.mkq_map_self Submodule.mkQ_map_self
-/

#print Submodule.comap_map_mkQ /-
@[simp]
theorem comap_map_mkQ : comap p.mkQ (map p.mkQ p') = p ⊔ p' := by simp [comap_map_eq, sup_comm]
#align submodule.comap_map_mkq Submodule.comap_map_mkQ
-/

#print Submodule.map_mkQ_eq_top /-
@[simp]
theorem map_mkQ_eq_top : map p.mkQ p' = ⊤ ↔ p ⊔ p' = ⊤ := by
  simp only [map_eq_top_iff p.range_mkq, sup_comm, ker_mkq]
#align submodule.map_mkq_eq_top Submodule.map_mkQ_eq_top
-/

variable (q : Submodule R₂ M₂)

#print Submodule.mapQ /-
/-- The map from the quotient of `M` by submodule `p` to the quotient of `M₂` by submodule `q` along
`f : M → M₂` is linear. -/
def mapQ (f : M →ₛₗ[τ₁₂] M₂) (h : p ≤ comap f q) : M ⧸ p →ₛₗ[τ₁₂] M₂ ⧸ q :=
  p.liftQ (q.mkQ.comp f) <| by simpa [ker_comp] using h
#align submodule.mapq Submodule.mapQ
-/

#print Submodule.mapQ_apply /-
@[simp]
theorem mapQ_apply (f : M →ₛₗ[τ₁₂] M₂) {h} (x : M) :
    mapQ p q f h (Quotient.mk x) = Quotient.mk (f x) :=
  rfl
#align submodule.mapq_apply Submodule.mapQ_apply
-/

#print Submodule.mapQ_mkQ /-
theorem mapQ_mkQ (f : M →ₛₗ[τ₁₂] M₂) {h} : (mapQ p q f h).comp p.mkQ = q.mkQ.comp f := by
  ext x <;> rfl
#align submodule.mapq_mkq Submodule.mapQ_mkQ
-/

#print Submodule.mapQ_zero /-
@[simp]
theorem mapQ_zero (h : p ≤ q.comap (0 : M →ₛₗ[τ₁₂] M₂) := (by simp)) :
    p.mapQ q (0 : M →ₛₗ[τ₁₂] M₂) h = 0 := by ext; simp
#align submodule.mapq_zero Submodule.mapQ_zero
-/

#print Submodule.mapQ_comp /-
/-- Given submodules `p ⊆ M`, `p₂ ⊆ M₂`, `p₃ ⊆ M₃` and maps `f : M → M₂`, `g : M₂ → M₃` inducing
`mapq f : M ⧸ p → M₂ ⧸ p₂` and `mapq g : M₂ ⧸ p₂ → M₃ ⧸ p₃` then
`mapq (g ∘ f) = (mapq g) ∘ (mapq f)`. -/
theorem mapQ_comp {R₃ M₃ : Type _} [Ring R₃] [AddCommGroup M₃] [Module R₃ M₃] (p₂ : Submodule R₂ M₂)
    (p₃ : Submodule R₃ M₃) {τ₂₃ : R₂ →+* R₃} {τ₁₃ : R →+* R₃} [RingHomCompTriple τ₁₂ τ₂₃ τ₁₃]
    (f : M →ₛₗ[τ₁₂] M₂) (g : M₂ →ₛₗ[τ₂₃] M₃) (hf : p ≤ p₂.comap f) (hg : p₂ ≤ p₃.comap g)
    (h := hf.trans (comap_mono hg)) :
    p.mapQ p₃ (g.comp f) h = (p₂.mapQ p₃ g hg).comp (p.mapQ p₂ f hf) := by ext; simp
#align submodule.mapq_comp Submodule.mapQ_comp
-/

#print Submodule.mapQ_id /-
@[simp]
theorem mapQ_id (h : p ≤ p.comap LinearMap.id := (by rw [comap_id]; exact le_refl _)) :
    p.mapQ p LinearMap.id h = LinearMap.id := by ext; simp
#align submodule.mapq_id Submodule.mapQ_id
-/

#print Submodule.mapQ_pow /-
theorem mapQ_pow {f : M →ₗ[R] M} (h : p ≤ p.comap f) (k : ℕ)
    (h' : p ≤ p.comap (f ^ k) := p.le_comap_pow_of_le_comap h k) :
    p.mapQ p (f ^ k) h' = p.mapQ p f h ^ k :=
  by
  induction' k with k ih
  · simp [LinearMap.one_eq_id]
  · simp only [LinearMap.iterate_succ, ← ih]
    apply p.mapq_comp
#align submodule.mapq_pow Submodule.mapQ_pow
-/

#print Submodule.comap_liftQ /-
theorem comap_liftQ (f : M →ₛₗ[τ₁₂] M₂) (h) : q.comap (p.liftQ f h) = (q.comap f).map (mkQ p) :=
  le_antisymm (by rintro ⟨x⟩ hx <;> exact ⟨_, hx, rfl⟩)
    (by rw [map_le_iff_le_comap, ← comap_comp, liftq_mkq] <;> exact le_rfl)
#align submodule.comap_liftq Submodule.comap_liftQ
-/

#print Submodule.map_liftQ /-
theorem map_liftQ [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) (h) (q : Submodule R (M ⧸ p)) :
    q.map (p.liftQ f h) = (q.comap p.mkQ).map f :=
  le_antisymm (by rintro _ ⟨⟨x⟩, hxq, rfl⟩ <;> exact ⟨x, hxq, rfl⟩)
    (by rintro _ ⟨x, hxq, rfl⟩ <;> exact ⟨Quotient.mk' x, hxq, rfl⟩)
#align submodule.map_liftq Submodule.map_liftQ
-/

#print Submodule.ker_liftQ /-
theorem ker_liftQ (f : M →ₛₗ[τ₁₂] M₂) (h) : ker (p.liftQ f h) = (ker f).map (mkQ p) :=
  comap_liftQ _ _ _ _
#align submodule.ker_liftq Submodule.ker_liftQ
-/

#print Submodule.range_liftQ /-
theorem range_liftQ [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) (h) :
    range (p.liftQ f h) = range f := by simpa only [range_eq_map] using map_liftq _ _ _ _
#align submodule.range_liftq Submodule.range_liftQ
-/

#print Submodule.ker_liftQ_eq_bot /-
theorem ker_liftQ_eq_bot (f : M →ₛₗ[τ₁₂] M₂) (h) (h' : ker f ≤ p) : ker (p.liftQ f h) = ⊥ := by
  rw [ker_liftq, le_antisymm h h', mkq_map_self]
#align submodule.ker_liftq_eq_bot Submodule.ker_liftQ_eq_bot
-/

#print Submodule.comapMkQRelIso /-
/-- The correspondence theorem for modules: there is an order isomorphism between submodules of the
quotient of `M` by `p`, and submodules of `M` larger than `p`. -/
def Submodule.comapMkQRelIso : Submodule R (M ⧸ p) ≃o { p' : Submodule R M // p ≤ p' }
    where
  toFun p' := ⟨comap p.mkQ p', le_comap_mkQ p _⟩
  invFun q := map p.mkQ q
  left_inv p' := map_comap_eq_self <| by simp
  right_inv := fun ⟨q, hq⟩ => Subtype.ext_val <| by simpa [comap_map_mkq p]
  map_rel_iff' p₁ p₂ := comap_le_comap_iff <| range_mkQ _
#align submodule.comap_mkq.rel_iso Submodule.comapMkQRelIso
-/

#print Submodule.comapMkQOrderEmbedding /-
/-- The ordering on submodules of the quotient of `M` by `p` embeds into the ordering on submodules
of `M`. -/
def Submodule.comapMkQOrderEmbedding : Submodule R (M ⧸ p) ↪o Submodule R M :=
  (RelIso.toRelEmbedding <| Submodule.comapMkQRelIso p).trans (Subtype.relEmbedding _ _)
#align submodule.comap_mkq.order_embedding Submodule.comapMkQOrderEmbedding
-/

#print Submodule.comapMkQOrderEmbedding_eq /-
@[simp]
theorem comapMkQOrderEmbedding_eq (p' : Submodule R (M ⧸ p)) :
    Submodule.comapMkQOrderEmbedding p p' = comap p.mkQ p' :=
  rfl
#align submodule.comap_mkq_embedding_eq Submodule.comapMkQOrderEmbedding_eq
-/

#print Submodule.span_preimage_eq /-
theorem span_preimage_eq [RingHomSurjective τ₁₂] {f : M →ₛₗ[τ₁₂] M₂} {s : Set M₂} (h₀ : s.Nonempty)
    (h₁ : s ⊆ range f) : span R (f ⁻¹' s) = (span R₂ s).comap f :=
  by
  suffices (span R₂ s).comap f ≤ span R (f ⁻¹' s) by exact le_antisymm (span_preimage_le f s) this
  have hk : ker f ≤ span R (f ⁻¹' s) :=
    by
    let y := Classical.choose h₀; have hy : y ∈ s := Classical.choose_spec h₀
    rw [ker_le_iff]; use y, h₁ hy; rw [← Set.singleton_subset_iff] at hy 
    exact Set.Subset.trans subset_span (span_mono (Set.preimage_mono hy))
  rw [← left_eq_sup] at hk ; rw [f.range_coe] at h₁ 
  rw [hk, ← LinearMap.map_le_map_iff, map_span, map_comap_eq, Set.image_preimage_eq_of_subset h₁]
  exact inf_le_right
#align submodule.span_preimage_eq Submodule.span_preimage_eq
-/

#print Submodule.Quotient.equiv /-
/-- If `P` is a submodule of `M` and `Q` a submodule of `N`,
and `f : M ≃ₗ N` maps `P` to `Q`, then `M ⧸ P` is equivalent to `N ⧸ Q`. -/
@[simps]
def Quotient.equiv {N : Type _} [AddCommGroup N] [Module R N] (P : Submodule R M)
    (Q : Submodule R N) (f : M ≃ₗ[R] N) (hf : P.map f = Q) : (M ⧸ P) ≃ₗ[R] N ⧸ Q :=
  {
    P.mapQ Q (f : M →ₗ[R] N) fun x hx =>
      hf ▸
        Submodule.mem_map_of_mem
          hx with
    toFun := P.mapQ Q (f : M →ₗ[R] N) fun x hx => hf ▸ Submodule.mem_map_of_mem hx
    invFun :=
      Q.mapQ P (f.symm : N →ₗ[R] M) fun x hx =>
        by
        rw [← hf, Submodule.mem_map] at hx 
        obtain ⟨y, hy, rfl⟩ := hx
        simpa
    left_inv := fun x => Quotient.inductionOn' x (by simp)
    right_inv := fun x => Quotient.inductionOn' x (by simp) }
#align submodule.quotient.equiv Submodule.Quotient.equiv
-/

#print Submodule.Quotient.equiv_symm /-
@[simp]
theorem Quotient.equiv_symm {R M N : Type _} [CommRing R] [AddCommGroup M] [Module R M]
    [AddCommGroup N] [Module R N] (P : Submodule R M) (Q : Submodule R N) (f : M ≃ₗ[R] N)
    (hf : P.map f = Q) :
    (Quotient.equiv P Q f hf).symm =
      Quotient.equiv Q P f.symm ((Submodule.map_symm_eq_iff f).mpr hf) :=
  rfl
#align submodule.quotient.equiv_symm Submodule.Quotient.equiv_symm
-/

#print Submodule.Quotient.equiv_trans /-
@[simp]
theorem Quotient.equiv_trans {N O : Type _} [AddCommGroup N] [Module R N] [AddCommGroup O]
    [Module R O] (P : Submodule R M) (Q : Submodule R N) (S : Submodule R O) (e : M ≃ₗ[R] N)
    (f : N ≃ₗ[R] O) (he : P.map e = Q) (hf : Q.map f = S) (hef : P.map (e.trans f) = S) :
    Quotient.equiv P S (e.trans f) hef =
      (Quotient.equiv P Q e he).trans (Quotient.equiv Q S f hf) :=
  by
  ext
  -- `simp` can deal with `hef` depending on `e` and `f`
  simp only [quotient.equiv_apply, LinearEquiv.trans_apply, LinearEquiv.coe_trans]
  -- `rw` can deal with `mapq_comp` needing extra hypotheses coming from the RHS
  rw [mapq_comp, LinearMap.comp_apply]
#align submodule.quotient.equiv_trans Submodule.Quotient.equiv_trans
-/

end Submodule

open Submodule

namespace LinearMap

section Ring

variable {R M R₂ M₂ R₃ M₃ : Type _}

variable [Ring R] [Ring R₂] [Ring R₃]

variable [AddCommMonoid M] [AddCommGroup M₂] [AddCommMonoid M₃]

variable [Module R M] [Module R₂ M₂] [Module R₃ M₃]

variable {τ₁₂ : R →+* R₂} {τ₂₃ : R₂ →+* R₃} {τ₁₃ : R →+* R₃}

variable [RingHomCompTriple τ₁₂ τ₂₃ τ₁₃] [RingHomSurjective τ₁₂]

#print LinearMap.range_mkQ_comp /-
theorem range_mkQ_comp (f : M →ₛₗ[τ₁₂] M₂) : f.range.mkQ.comp f = 0 :=
  LinearMap.ext fun x => by simp
#align linear_map.range_mkq_comp LinearMap.range_mkQ_comp
-/

#print LinearMap.ker_le_range_iff /-
theorem ker_le_range_iff {f : M →ₛₗ[τ₁₂] M₂} {g : M₂ →ₛₗ[τ₂₃] M₃} :
    g.ker ≤ f.range ↔ f.range.mkQ.comp g.ker.Subtype = 0 := by
  rw [← range_le_ker_iff, Submodule.ker_mkQ, Submodule.range_subtype]
#align linear_map.ker_le_range_iff LinearMap.ker_le_range_iff
-/

#print LinearMap.range_eq_top_of_cancel /-
/-- An epimorphism is surjective. -/
theorem range_eq_top_of_cancel {f : M →ₛₗ[τ₁₂] M₂}
    (h : ∀ u v : M₂ →ₗ[R₂] M₂ ⧸ f.range, u.comp f = v.comp f → u = v) : f.range = ⊤ :=
  by
  have h₁ : (0 : M₂ →ₗ[R₂] M₂ ⧸ f.range).comp f = 0 := zero_comp _
  rw [← Submodule.ker_mkQ f.range, ← h 0 f.range.mkq (Eq.trans h₁ (range_mkq_comp _).symm)]
  exact ker_zero
#align linear_map.range_eq_top_of_cancel LinearMap.range_eq_top_of_cancel
-/

end Ring

end LinearMap

open LinearMap

namespace Submodule

variable {R M : Type _} {r : R} {x y : M} [Ring R] [AddCommGroup M] [Module R M]

variable (p p' : Submodule R M)

#print Submodule.quotEquivOfEqBot /-
/-- If `p = ⊥`, then `M / p ≃ₗ[R] M`. -/
def quotEquivOfEqBot (hp : p = ⊥) : (M ⧸ p) ≃ₗ[R] M :=
  LinearEquiv.ofLinear (p.liftQ id <| hp.symm ▸ bot_le) p.mkQ (liftQ_mkQ _ _ _) <|
    p.quot_hom_ext fun x => rfl
#align submodule.quot_equiv_of_eq_bot Submodule.quotEquivOfEqBot
-/

#print Submodule.quotEquivOfEqBot_apply_mk /-
@[simp]
theorem quotEquivOfEqBot_apply_mk (hp : p = ⊥) (x : M) :
    p.quotEquivOfEqBot hp (Quotient.mk x) = x :=
  rfl
#align submodule.quot_equiv_of_eq_bot_apply_mk Submodule.quotEquivOfEqBot_apply_mk
-/

#print Submodule.quotEquivOfEqBot_symm_apply /-
@[simp]
theorem quotEquivOfEqBot_symm_apply (hp : p = ⊥) (x : M) :
    (p.quotEquivOfEqBot hp).symm x = Quotient.mk x :=
  rfl
#align submodule.quot_equiv_of_eq_bot_symm_apply Submodule.quotEquivOfEqBot_symm_apply
-/

#print Submodule.coe_quotEquivOfEqBot_symm /-
@[simp]
theorem coe_quotEquivOfEqBot_symm (hp : p = ⊥) :
    ((p.quotEquivOfEqBot hp).symm : M →ₗ[R] M ⧸ p) = p.mkQ :=
  rfl
#align submodule.coe_quot_equiv_of_eq_bot_symm Submodule.coe_quotEquivOfEqBot_symm
-/

#print Submodule.quotEquivOfEq /-
/-- Quotienting by equal submodules gives linearly equivalent quotients. -/
def quotEquivOfEq (h : p = p') : (M ⧸ p) ≃ₗ[R] M ⧸ p' :=
  {
    @Quotient.congr _ _ (quotientRel p) (quotientRel p') (Equiv.refl _) fun a b => by subst h;
      rfl with
    map_add' := by rintro ⟨x⟩ ⟨y⟩; rfl
    map_smul' := by rintro x ⟨y⟩; rfl }
#align submodule.quot_equiv_of_eq Submodule.quotEquivOfEq
-/

#print Submodule.quotEquivOfEq_mk /-
@[simp]
theorem quotEquivOfEq_mk (h : p = p') (x : M) :
    Submodule.quotEquivOfEq p p' h (Submodule.Quotient.mk x) = Submodule.Quotient.mk x :=
  rfl
#align submodule.quot_equiv_of_eq_mk Submodule.quotEquivOfEq_mk
-/

#print Submodule.Quotient.equiv_refl /-
@[simp]
theorem Quotient.equiv_refl (P : Submodule R M) (Q : Submodule R M)
    (hf : P.map (LinearEquiv.refl R M : M →ₗ[R] M) = Q) :
    Quotient.equiv P Q (LinearEquiv.refl R M) hf = quotEquivOfEq _ _ (by simpa using hf) :=
  rfl
#align submodule.quotient.equiv_refl Submodule.Quotient.equiv_refl
-/

end Submodule

end Ring

section CommRing

variable {R M M₂ : Type _} {r : R} {x y : M} [CommRing R] [AddCommGroup M] [Module R M]
  [AddCommGroup M₂] [Module R M₂] (p : Submodule R M) (q : Submodule R M₂)

namespace Submodule

#print Submodule.mapQLinear /-
/-- Given modules `M`, `M₂` over a commutative ring, together with submodules `p ⊆ M`, `q ⊆ M₂`,
the natural map $\{f ∈ Hom(M, M₂) | f(p) ⊆ q \} \to Hom(M/p, M₂/q)$ is linear. -/
def mapQLinear : compatibleMaps p q →ₗ[R] M ⧸ p →ₗ[R] M₂ ⧸ q
    where
  toFun f := mapQ _ _ f.val f.property
  map_add' x y := by ext; rfl
  map_smul' c f := by ext; rfl
#align submodule.mapq_linear Submodule.mapQLinear
-/

end Submodule

end CommRing

