/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin

! This file was ported from Lean 3 source module ring_theory.finite_presentation
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.FiniteType
import Mathbin.RingTheory.MvPolynomial.Tower
import Mathbin.RingTheory.Ideal.QuotientOperations

/-!
# Finiteness conditions in commutative algebra

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define several notions of finiteness that are common in commutative algebra.

## Main declarations

- `module.finite`, `algebra.finite`, `ring_hom.finite`, `alg_hom.finite`
  all of these express that some object is finitely generated *as module* over some base ring.
- `algebra.finite_type`, `ring_hom.finite_type`, `alg_hom.finite_type`
  all of these express that some object is finitely generated *as algebra* over some base ring.
- `algebra.finite_presentation`, `ring_hom.finite_presentation`, `alg_hom.finite_presentation`
  all of these express that some object is finitely presented *as algebra* over some base ring.

-/


open Function (Surjective)

open scoped BigOperators Polynomial

section ModuleAndAlgebra

variable (R A B M N : Type _)

#print Algebra.FinitePresentation /-
/-- An algebra over a commutative semiring is `finite_presentation` if it is the quotient of a
polynomial ring in `n` variables by a finitely generated ideal. -/
def Algebra.FinitePresentation [CommSemiring R] [Semiring A] [Algebra R A] : Prop :=
  ∃ (n : ℕ) (f : MvPolynomial (Fin n) R →ₐ[R] A), Surjective f ∧ f.toRingHom.ker.FG
#align algebra.finite_presentation Algebra.FinitePresentation
-/

namespace Algebra

variable [CommRing R] [CommRing A] [Algebra R A] [CommRing B] [Algebra R B]

variable [AddCommGroup M] [Module R M]

variable [AddCommGroup N] [Module R N]

namespace FiniteType

variable {R A B}

#print Algebra.FiniteType.of_finitePresentation /-
/-- A finitely presented algebra is of finite type. -/
theorem of_finitePresentation : FinitePresentation R A → FiniteType R A :=
  by
  rintro ⟨n, f, hf⟩
  apply finite_type.iff_quotient_mv_polynomial''.2
  exact ⟨n, f, hf.1⟩
#align algebra.finite_type.of_finite_presentation Algebra.FiniteType.of_finitePresentation
-/

end FiniteType

namespace FinitePresentation

variable {R A B}

#print Algebra.FinitePresentation.of_finiteType /-
/-- An algebra over a Noetherian ring is finitely generated if and only if it is finitely
presented. -/
theorem of_finiteType [IsNoetherianRing R] : FiniteType R A ↔ FinitePresentation R A :=
  by
  refine' ⟨fun h => _, Algebra.FiniteType.of_finitePresentation⟩
  obtain ⟨n, f, hf⟩ := Algebra.FiniteType.iff_quotient_mvPolynomial''.1 h
  refine' ⟨n, f, hf, _⟩
  have hnoet : IsNoetherianRing (MvPolynomial (Fin n) R) := by infer_instance
  replace hnoet := (isNoetherianRing_iff.1 hnoet).noetherian
  exact hnoet f.to_ring_hom.ker
#align algebra.finite_presentation.of_finite_type Algebra.FinitePresentation.of_finiteType
-/

#print Algebra.FinitePresentation.equiv /-
/-- If `e : A ≃ₐ[R] B` and `A` is finitely presented, then so is `B`. -/
theorem equiv (hfp : FinitePresentation R A) (e : A ≃ₐ[R] B) : FinitePresentation R B :=
  by
  obtain ⟨n, f, hf⟩ := hfp
  use n, AlgHom.comp (↑e) f
  constructor
  · exact Function.Surjective.comp e.surjective hf.1
  suffices hker : (AlgHom.comp (↑e) f).toRingHom.ker = f.to_ring_hom.ker
  · rw [hker]; exact hf.2
  · have hco : (AlgHom.comp (↑e) f).toRingHom = RingHom.comp (↑e.to_ring_equiv) f.to_ring_hom :=
      by
      have h : (AlgHom.comp (↑e) f).toRingHom = e.to_alg_hom.to_ring_hom.comp f.to_ring_hom := rfl
      have h1 : ↑e.to_ring_equiv = e.to_alg_hom.toRingHom := rfl
      rw [h, h1]
    rw [RingHom.ker_eq_comap_bot, hco, ← Ideal.comap_comap, ← RingHom.ker_eq_comap_bot,
      RingHom.ker_coe_equiv (AlgEquiv.toRingEquiv e), RingHom.ker_eq_comap_bot]
#align algebra.finite_presentation.equiv Algebra.FinitePresentation.equiv
-/

variable (R)

#print Algebra.FinitePresentation.mvPolynomial /-
/-- The ring of polynomials in finitely many variables is finitely presented. -/
protected theorem mvPolynomial (ι : Type u_2) [Finite ι] :
    FinitePresentation R (MvPolynomial ι R) := by
  cases nonempty_fintype ι <;>
    exact
      let eqv := (MvPolynomial.renameEquiv R <| Fintype.equivFin ι).symm
      ⟨Fintype.card ι, eqv, eqv.Surjective,
        ((RingHom.injective_iff_ker_eq_bot _).1 eqv.Injective).symm ▸ Submodule.fg_bot⟩
#align algebra.finite_presentation.mv_polynomial Algebra.FinitePresentation.mvPolynomial
-/

#print Algebra.FinitePresentation.self /-
/-- `R` is finitely presented as `R`-algebra. -/
theorem self : FinitePresentation R R :=
  equiv (FinitePresentation.mvPolynomial R PEmpty) (MvPolynomial.isEmptyAlgEquiv R PEmpty)
#align algebra.finite_presentation.self Algebra.FinitePresentation.self
-/

#print Algebra.FinitePresentation.polynomial /-
/-- `R[X]` is finitely presented as `R`-algebra. -/
theorem polynomial : FinitePresentation R R[X] :=
  equiv (FinitePresentation.mvPolynomial R PUnit) (MvPolynomial.pUnitAlgEquiv R)
#align algebra.finite_presentation.polynomial Algebra.FinitePresentation.polynomial
-/

variable {R}

#print Algebra.FinitePresentation.quotient /-
/-- The quotient of a finitely presented algebra by a finitely generated ideal is finitely
presented. -/
protected theorem quotient {I : Ideal A} (h : I.FG) (hfp : FinitePresentation R A) :
    FinitePresentation R (A ⧸ I) := by
  obtain ⟨n, f, hf⟩ := hfp
  refine' ⟨n, (Ideal.Quotient.mkₐ R I).comp f, _, _⟩
  · exact (Ideal.Quotient.mkₐ_surjective R I).comp hf.1
  · refine' Ideal.fg_ker_comp _ _ hf.2 _ hf.1
    simp [h]
#align algebra.finite_presentation.quotient Algebra.FinitePresentation.quotient
-/

#print Algebra.FinitePresentation.of_surjective /-
/-- If `f : A →ₐ[R] B` is surjective with finitely generated kernel and `A` is finitely presented,
then so is `B`. -/
theorem of_surjective {f : A →ₐ[R] B} (hf : Function.Surjective f) (hker : f.toRingHom.ker.FG)
    (hfp : FinitePresentation R A) : FinitePresentation R B :=
  equiv (hfp.Quotient hker) (Ideal.quotientKerAlgEquivOfSurjective hf)
#align algebra.finite_presentation.of_surjective Algebra.FinitePresentation.of_surjective
-/

#print Algebra.FinitePresentation.iff /-
theorem iff :
    FinitePresentation R A ↔
      ∃ (n : _) (I : Ideal (MvPolynomial (Fin n) R)) (e : (_ ⧸ I) ≃ₐ[R] A), I.FG :=
  by
  constructor
  · rintro ⟨n, f, hf⟩
    exact ⟨n, f.to_ring_hom.ker, Ideal.quotientKerAlgEquivOfSurjective hf.1, hf.2⟩
  · rintro ⟨n, I, e, hfg⟩
    exact Equiv ((finite_presentation.mv_polynomial R _).Quotient hfg) e
#align algebra.finite_presentation.iff Algebra.FinitePresentation.iff
-/

#print Algebra.FinitePresentation.iff_quotient_mvPolynomial' /-
/-- An algebra is finitely presented if and only if it is a quotient of a polynomial ring whose
variables are indexed by a fintype by a finitely generated ideal. -/
theorem iff_quotient_mvPolynomial' :
    FinitePresentation R A ↔
      ∃ (ι : Type u_2) (_ : Fintype ι) (f : MvPolynomial ι R →ₐ[R] A),
        Surjective f ∧ f.toRingHom.ker.FG :=
  by
  constructor
  · rintro ⟨n, f, hfs, hfk⟩
    set ulift_var := MvPolynomial.renameEquiv R Equiv.ulift
    refine'
      ⟨ULift (Fin n), inferInstance, f.comp ulift_var.to_alg_hom, hfs.comp ulift_var.surjective,
        Ideal.fg_ker_comp _ _ _ hfk ulift_var.surjective⟩
    convert Submodule.fg_bot
    exact RingHom.ker_coe_equiv ulift_var.to_ring_equiv
  · rintro ⟨ι, hfintype, f, hf⟩
    skip
    have equiv := MvPolynomial.renameEquiv R (Fintype.equivFin ι)
    refine'
      ⟨Fintype.card ι, f.comp Equiv.symm, hf.1.comp (AlgEquiv.symm Equiv).Surjective,
        Ideal.fg_ker_comp _ f _ hf.2 equiv.symm.surjective⟩
    convert Submodule.fg_bot
    exact RingHom.ker_coe_equiv equiv.symm.to_ring_equiv
#align algebra.finite_presentation.iff_quotient_mv_polynomial' Algebra.FinitePresentation.iff_quotient_mvPolynomial'
-/

#print Algebra.FinitePresentation.mvPolynomial_of_finitePresentation /-
/-- If `A` is a finitely presented `R`-algebra, then `mv_polynomial (fin n) A` is finitely presented
as `R`-algebra. -/
theorem mvPolynomial_of_finitePresentation (hfp : FinitePresentation R A) (ι : Type _) [Finite ι] :
    FinitePresentation R (MvPolynomial ι A) :=
  by
  rw [iff_quotient_mv_polynomial'] at hfp ⊢
  classical
  obtain ⟨ι', _, f, hf_surj, hf_ker⟩ := hfp
  skip
  let g := (MvPolynomial.mapAlgHom f).comp (MvPolynomial.sumAlgEquiv R ι ι').toAlgHom
  cases nonempty_fintype (Sum ι ι')
  refine'
    ⟨Sum ι ι', by infer_instance, g,
      (MvPolynomial.map_surjective f.to_ring_hom hf_surj).comp (AlgEquiv.surjective _),
      Ideal.fg_ker_comp _ _ _ _ (AlgEquiv.surjective _)⟩
  · convert Submodule.fg_bot
    exact RingHom.ker_coe_equiv (MvPolynomial.sumAlgEquiv R ι ι').toRingEquiv
  · rw [AlgHom.toRingHom_eq_coe, MvPolynomial.mapAlgHom_coe_ringHom, MvPolynomial.ker_map]
    exact hf_ker.map MvPolynomial.C
#align algebra.finite_presentation.mv_polynomial_of_finite_presentation Algebra.FinitePresentation.mvPolynomial_of_finitePresentation
-/

#print Algebra.FinitePresentation.trans /-
/-- If `A` is an `R`-algebra and `S` is an `A`-algebra, both finitely presented, then `S` is
  finitely presented as `R`-algebra. -/
theorem trans [Algebra A B] [IsScalarTower R A B] (hfpA : FinitePresentation R A)
    (hfpB : FinitePresentation A B) : FinitePresentation R B :=
  by
  obtain ⟨n, I, e, hfg⟩ := Iff.1 hfpB
  exact Equiv ((mv_polynomial_of_finite_presentation hfpA _).Quotient hfg) (e.restrict_scalars R)
#align algebra.finite_presentation.trans Algebra.FinitePresentation.trans
-/

open MvPolynomial

#print Algebra.FinitePresentation.of_restrict_scalars_finitePresentation /-
-- We follow the proof of https://stacks.math.columbia.edu/tag/0561
-- TODO: extract out helper lemmas and tidy proof.
theorem of_restrict_scalars_finitePresentation [Algebra A B] [IsScalarTower R A B]
    (hRB : FinitePresentation R B) [hRA : FiniteType R A] : FinitePresentation A B := by
  classical
  obtain ⟨n, f, hf, s, hs⟩ := hRB
  let RX := MvPolynomial (Fin n) R
  let AX := MvPolynomial (Fin n) A
  refine' ⟨n, MvPolynomial.aeval (f ∘ X), _, _⟩
  · rw [← Algebra.range_top_iff_surjective, ← Algebra.adjoin_range_eq_range_aeval, Set.range_comp,
      _root_.eq_top_iff, ← @adjoin_adjoin_of_tower R A B, adjoin_image, adjoin_range_X,
      Algebra.map_top, (Algebra.range_top_iff_surjective _).mpr hf]
    exact subset_adjoin
  · obtain ⟨t, ht⟩ := hRA.out
    have := fun i : t => hf (algebraMap A B i)
    choose t' ht'
    have ht'' : Algebra.adjoin R (algebraMap A AX '' t ∪ Set.range (X : _ → AX)) = ⊤ :=
      by
      rw [adjoin_union_eq_adjoin_adjoin, ← Subalgebra.restrictScalars_top R]
      congr 1
      swap; · exact Subalgebra.isScalarTower_mid _
      rw [adjoin_algebra_map, ht]
      apply Subalgebra.restrictScalars_injective R
      rw [← adjoin_restrict_scalars, adjoin_range_X, Subalgebra.restrictScalars_top,
        Subalgebra.restrictScalars_top]
    let g : t → AX := fun x => C (x : A) - map (algebraMap R A) (t' x)
    refine' ⟨s.image (map (algebraMap R A)) ∪ t.attach.image g, _⟩
    rw [Finset.coe_union, Finset.coe_image, Finset.coe_image, Finset.attach_eq_univ,
      Finset.coe_univ, Set.image_univ]
    let s₀ := _; let I := _; change Ideal.span s₀ = I
    have leI : Ideal.span s₀ ≤ I := by
      rw [Ideal.span_le]
      rintro _ (⟨x, hx, rfl⟩ | ⟨⟨x, hx⟩, rfl⟩)
      all_goals dsimp [g]; rw [RingHom.mem_ker, AlgHom.toRingHom_eq_coe, AlgHom.coe_toRingHom]
      · rw [MvPolynomial.aeval_map_algebraMap, ← aeval_unique]
        have := Ideal.subset_span hx
        rwa [hs] at this 
      ·
        rw [map_sub, MvPolynomial.aeval_map_algebraMap, ← aeval_unique, aeval_C, ht',
          Subtype.coe_mk, sub_self]
    apply leI.antisymm
    intro x hx
    rw [RingHom.mem_ker, AlgHom.toRingHom_eq_coe, AlgHom.coe_toRingHom] at hx 
    let s₀ := _; change x ∈ Ideal.span s₀
    have :
      x ∈
        (map (algebraMap R A) : _ →+* AX).srange.toAddSubmonoid ⊔ (Ideal.span s₀).toAddSubmonoid :=
      by
      have : x ∈ (⊤ : Subalgebra R AX) := trivial
      rw [← ht''] at this 
      apply adjoin_induction this
      · rintro _ (⟨x, hx, rfl⟩ | ⟨i, rfl⟩)
        · rw [algebra_map_eq, ← sub_add_cancel (C x) (map (algebraMap R A) (t' ⟨x, hx⟩)), add_comm]
          apply AddSubmonoid.add_mem_sup
          · exact Set.mem_range_self _
          · apply Ideal.subset_span
            apply Set.mem_union_right
            exact Set.mem_range_self ⟨x, hx⟩
        · apply AddSubmonoid.mem_sup_left
          exact ⟨X i, map_X _ _⟩
      · intro r; apply AddSubmonoid.mem_sup_left; exact ⟨C r, map_C _ _⟩
      · intro _ _ h₁ h₂; exact add_mem h₁ h₂
      · intro x₁ x₂ h₁ h₂
        obtain ⟨_, ⟨p₁, rfl⟩, q₁, hq₁, rfl⟩ := add_submonoid.mem_sup.mp h₁
        obtain ⟨_, ⟨p₂, rfl⟩, q₂, hq₂, rfl⟩ := add_submonoid.mem_sup.mp h₂
        rw [add_mul, mul_add, add_assoc, ← map_mul]
        apply AddSubmonoid.add_mem_sup
        · exact Set.mem_range_self _
        · refine' add_mem (Ideal.mul_mem_left _ _ hq₂) (Ideal.mul_mem_right _ _ hq₁)
    obtain ⟨_, ⟨p, rfl⟩, q, hq, rfl⟩ := add_submonoid.mem_sup.mp this
    rw [map_add, aeval_map_algebra_map, ← aeval_unique, show aeval (f ∘ X) q = 0 from leI hq,
      add_zero] at hx 
    suffices Ideal.span (s : Set RX) ≤ (Ideal.span s₀).comap (map <| algebraMap R A) by
      refine' add_mem _ hq; rw [hs] at this ; exact this hx
    rw [Ideal.span_le]
    intro x hx
    apply Ideal.subset_span
    apply Set.mem_union_left
    exact Set.mem_image_of_mem _ hx
#align algebra.finite_presentation.of_restrict_scalars_finite_presentation Algebra.FinitePresentation.of_restrict_scalars_finitePresentation
-/

#print Algebra.FinitePresentation.ker_fg_of_mvPolynomial /-
-- TODO: extract out helper lemmas and tidy proof.
/-- This is used to prove the strictly stronger `ker_fg_of_surjective`. Use it instead. -/
theorem ker_fg_of_mvPolynomial {n : ℕ} (f : MvPolynomial (Fin n) R →ₐ[R] A)
    (hf : Function.Surjective f) (hfp : FinitePresentation R A) : f.toRingHom.ker.FG := by
  classical
  obtain ⟨m, f', hf', s, hs⟩ := hfp
  let RXn := MvPolynomial (Fin n) R
  let RXm := MvPolynomial (Fin m) R
  have := fun i : Fin n => hf' (f <| X i)
  choose g hg
  have := fun i : Fin m => hf (f' <| X i)
  choose h hh
  let aeval_h : RXm →ₐ[R] RXn := aeval h
  let g' : Fin n → RXn := fun i => X i - aeval_h (g i)
  refine' ⟨finset.univ.image g' ∪ s.image aeval_h, _⟩
  simp only [Finset.coe_image, Finset.coe_union, Finset.coe_univ, Set.image_univ]
  have hh' : ∀ x, f (aeval_h x) = f' x := by
    intro x; rw [← f.coe_to_ring_hom, map_aeval]; simp_rw [AlgHom.coe_toRingHom, hh]
    rw [AlgHom.comp_algebraMap, ← aeval_eq_eval₂_hom, ← aeval_unique]
  let s' := Set.range g' ∪ aeval_h '' s
  have leI : Ideal.span s' ≤ f.to_ring_hom.ker :=
    by
    rw [Ideal.span_le]
    rintro _ (⟨i, rfl⟩ | ⟨x, hx, rfl⟩)
    · change f (g' i) = 0; rw [map_sub, ← hg, hh', sub_self]
    · change f (aeval_h x) = 0
      rw [hh']
      change x ∈ f'.to_ring_hom.ker
      rw [← hs]
      exact Ideal.subset_span hx
  apply leI.antisymm
  intro x hx
  have : x ∈ aeval_h.range.to_add_submonoid ⊔ (Ideal.span s').toAddSubmonoid :=
    by
    have : x ∈ adjoin R (Set.range X : Set RXn) := by rw [adjoin_range_X]; trivial
    apply adjoin_induction this
    · rintro _ ⟨i, rfl⟩
      rw [← sub_add_cancel (X i) (aeval h (g i)), add_comm]
      apply AddSubmonoid.add_mem_sup
      · exact Set.mem_range_self _
      · apply Submodule.subset_span
        apply Set.mem_union_left
        exact Set.mem_range_self _
    · intro r; apply AddSubmonoid.mem_sup_left; exact ⟨C r, aeval_C _ _⟩
    · intro _ _ h₁ h₂; exact add_mem h₁ h₂
    · intro p₁ p₂ h₁ h₂
      obtain ⟨_, ⟨x₁, rfl⟩, y₁, hy₁, rfl⟩ := add_submonoid.mem_sup.mp h₁
      obtain ⟨_, ⟨x₂, rfl⟩, y₂, hy₂, rfl⟩ := add_submonoid.mem_sup.mp h₂
      rw [mul_add, add_mul, add_assoc, ← map_mul]
      apply AddSubmonoid.add_mem_sup
      · exact Set.mem_range_self _
      · exact add_mem (Ideal.mul_mem_right _ _ hy₁) (Ideal.mul_mem_left _ _ hy₂)
  obtain ⟨_, ⟨x, rfl⟩, y, hy, rfl⟩ := add_submonoid.mem_sup.mp this
  refine' add_mem _ hy
  simp only [RingHom.mem_ker, AlgHom.toRingHom_eq_coe, AlgHom.coe_toRingHom, map_add,
    show f y = 0 from leI hy, add_zero, hh'] at hx 
  suffices Ideal.span (s : Set RXm) ≤ (Ideal.span s').comap aeval_h by apply this; rwa [hs]
  rw [Ideal.span_le]
  intro x hx
  apply Submodule.subset_span
  apply Set.mem_union_right
  exact Set.mem_image_of_mem _ hx
#align algebra.finite_presentation.ker_fg_of_mv_polynomial Algebra.FinitePresentation.ker_fg_of_mvPolynomial
-/

#print Algebra.FinitePresentation.ker_fG_of_surjective /-
/-- If `f : A →ₐ[R] B` is a sujection between finitely-presented `R`-algebras, then the kernel of
`f` is finitely generated. -/
theorem ker_fG_of_surjective (f : A →ₐ[R] B) (hf : Function.Surjective f)
    (hRA : FinitePresentation R A) (hRB : FinitePresentation R B) : f.toRingHom.ker.FG :=
  by
  obtain ⟨n, g, hg, hg'⟩ := hRA
  convert (ker_fg_of_mv_polynomial (f.comp g) (hf.comp hg) hRB).map g.to_ring_hom
  simp_rw [RingHom.ker_eq_comap_bot, AlgHom.toRingHom_eq_coe, AlgHom.comp_toRingHom]
  rw [← Ideal.comap_comap, Ideal.map_comap_of_surjective (g : MvPolynomial (Fin n) R →+* A) hg]
#align algebra.finite_presentation.ker_fg_of_surjective Algebra.FinitePresentation.ker_fG_of_surjective
-/

end FinitePresentation

end Algebra

end ModuleAndAlgebra

namespace RingHom

variable {A B C : Type _} [CommRing A] [CommRing B] [CommRing C]

#print RingHom.FinitePresentation /-
/-- A ring morphism `A →+* B` is of `finite_presentation` if `B` is finitely presented as
`A`-algebra. -/
def FinitePresentation (f : A →+* B) : Prop :=
  @Algebra.FinitePresentation A B _ _ f.toAlgebra
#align ring_hom.finite_presentation RingHom.FinitePresentation
-/

namespace FiniteType

#print RingHom.FiniteType.of_finitePresentation /-
theorem of_finitePresentation {f : A →+* B} (hf : f.FinitePresentation) : f.FiniteType :=
  @Algebra.FiniteType.of_finitePresentation A B _ _ f.toAlgebra hf
#align ring_hom.finite_type.of_finite_presentation RingHom.FiniteType.of_finitePresentation
-/

end FiniteType

namespace FinitePresentation

variable (A)

#print RingHom.FinitePresentation.id /-
theorem id : FinitePresentation (RingHom.id A) :=
  Algebra.FinitePresentation.self A
#align ring_hom.finite_presentation.id RingHom.FinitePresentation.id
-/

variable {A}

#print RingHom.FinitePresentation.comp_surjective /-
theorem comp_surjective {f : A →+* B} {g : B →+* C} (hf : f.FinitePresentation) (hg : Surjective g)
    (hker : g.ker.FG) : (g.comp f).FinitePresentation :=
  @Algebra.FinitePresentation.of_surjective A B C _ _ f.toAlgebra _ (g.comp f).toAlgebra
    { g with
      toFun := g
      commutes' := fun a => rfl }
    hg hker hf
#align ring_hom.finite_presentation.comp_surjective RingHom.FinitePresentation.comp_surjective
-/

#print RingHom.FinitePresentation.of_surjective /-
theorem of_surjective (f : A →+* B) (hf : Surjective f) (hker : f.ker.FG) : f.FinitePresentation :=
  by rw [← f.comp_id]; exact (id A).comp_surjective hf hker
#align ring_hom.finite_presentation.of_surjective RingHom.FinitePresentation.of_surjective
-/

#print RingHom.FinitePresentation.of_finiteType /-
theorem of_finiteType [IsNoetherianRing A] {f : A →+* B} : f.FiniteType ↔ f.FinitePresentation :=
  @Algebra.FinitePresentation.of_finiteType A B _ _ f.toAlgebra _
#align ring_hom.finite_presentation.of_finite_type RingHom.FinitePresentation.of_finiteType
-/

#print RingHom.FinitePresentation.comp /-
theorem comp {g : B →+* C} {f : A →+* B} (hg : g.FinitePresentation) (hf : f.FinitePresentation) :
    (g.comp f).FinitePresentation :=
  @Algebra.FinitePresentation.trans A B C _ _ f.toAlgebra _ (g.comp f).toAlgebra g.toAlgebra
    {
      smul_assoc := fun a b c =>
        by
        simp only [Algebra.smul_def, RingHom.map_mul, mul_assoc]
        rfl }
    hf hg
#align ring_hom.finite_presentation.comp RingHom.FinitePresentation.comp
-/

#print RingHom.FinitePresentation.of_comp_finiteType /-
theorem of_comp_finiteType (f : A →+* B) {g : B →+* C} (hg : (g.comp f).FinitePresentation)
    (hf : f.FiniteType) : g.FinitePresentation :=
  @Algebra.FinitePresentation.of_restrict_scalars_finitePresentation _ _ f.toAlgebra _
    (g.comp f).toAlgebra g.toAlgebra
    (@IsScalarTower.of_algebraMap_eq' _ _ _ f.toAlgebra g.toAlgebra (g.comp f).toAlgebra rfl) hg hf
#align ring_hom.finite_presentation.of_comp_finite_type RingHom.FinitePresentation.of_comp_finiteType
-/

end FinitePresentation

end RingHom

namespace AlgHom

variable {R A B C : Type _} [CommRing R]

variable [CommRing A] [CommRing B] [CommRing C]

variable [Algebra R A] [Algebra R B] [Algebra R C]

#print AlgHom.FinitePresentation /-
/-- An algebra morphism `A →ₐ[R] B` is of `finite_presentation` if it is of finite presentation as
ring morphism. In other words, if `B` is finitely presented as `A`-algebra. -/
def FinitePresentation (f : A →ₐ[R] B) : Prop :=
  f.toRingHom.FinitePresentation
#align alg_hom.finite_presentation AlgHom.FinitePresentation
-/

namespace FiniteType

variable {R A}

#print AlgHom.FiniteType.of_finitePresentation /-
theorem of_finitePresentation {f : A →ₐ[R] B} (hf : f.FinitePresentation) : f.FiniteType :=
  RingHom.FiniteType.of_finitePresentation hf
#align alg_hom.finite_type.of_finite_presentation AlgHom.FiniteType.of_finitePresentation
-/

end FiniteType

namespace FinitePresentation

variable (R A)

#print AlgHom.FinitePresentation.id /-
theorem id : FinitePresentation (AlgHom.id R A) :=
  RingHom.FinitePresentation.id A
#align alg_hom.finite_presentation.id AlgHom.FinitePresentation.id
-/

variable {R A}

#print AlgHom.FinitePresentation.comp /-
theorem comp {g : B →ₐ[R] C} {f : A →ₐ[R] B} (hg : g.FinitePresentation)
    (hf : f.FinitePresentation) : (g.comp f).FinitePresentation :=
  RingHom.FinitePresentation.comp hg hf
#align alg_hom.finite_presentation.comp AlgHom.FinitePresentation.comp
-/

#print AlgHom.FinitePresentation.comp_surjective /-
theorem comp_surjective {f : A →ₐ[R] B} {g : B →ₐ[R] C} (hf : f.FinitePresentation)
    (hg : Surjective g) (hker : g.toRingHom.ker.FG) : (g.comp f).FinitePresentation :=
  RingHom.FinitePresentation.comp_surjective hf hg hker
#align alg_hom.finite_presentation.comp_surjective AlgHom.FinitePresentation.comp_surjective
-/

#print AlgHom.FinitePresentation.of_surjective /-
theorem of_surjective (f : A →ₐ[R] B) (hf : Surjective f) (hker : f.toRingHom.ker.FG) :
    f.FinitePresentation :=
  RingHom.FinitePresentation.of_surjective f hf hker
#align alg_hom.finite_presentation.of_surjective AlgHom.FinitePresentation.of_surjective
-/

#print AlgHom.FinitePresentation.of_finiteType /-
theorem of_finiteType [IsNoetherianRing A] {f : A →ₐ[R] B} : f.FiniteType ↔ f.FinitePresentation :=
  RingHom.FinitePresentation.of_finiteType
#align alg_hom.finite_presentation.of_finite_type AlgHom.FinitePresentation.of_finiteType
-/

#print AlgHom.FinitePresentation.of_comp_finiteType /-
theorem of_comp_finiteType (f : A →ₐ[R] B) {g : B →ₐ[R] C} (h : (g.comp f).FinitePresentation)
    (h' : f.FiniteType) : g.FinitePresentation :=
  h.of_comp_finiteType _ h'
#align alg_hom.finite_presentation.of_comp_finite_type AlgHom.FinitePresentation.of_comp_finiteType
-/

end FinitePresentation

end AlgHom

