/-
Copyright (c) 2019 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module ring_theory.adjoin.fg
! leanprover-community/mathlib commit 31ca6f9cf5f90a6206092cd7f84b359dcb6d52e0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.Polynomial.Basic
import Mathbin.RingTheory.PrincipalIdealDomain
import Mathbin.Data.MvPolynomial.Basic

/-!
# Adjoining elements to form subalgebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file develops the basic theory of finitely-generated subalgebras.

## Definitions

* `fg (S : subalgebra R A)` : A predicate saying that the subalgebra is finitely-generated
as an A-algebra

## Tags

adjoin, algebra, finitely-generated algebra

-/


universe u v w

open Subsemiring Ring Submodule

open scoped Pointwise

namespace Algebra

variable {R : Type u} {A : Type v} {B : Type w} [CommSemiring R] [CommSemiring A] [Algebra R A]
  {s t : Set A}

#print Algebra.fg_trans /-
theorem fg_trans (h1 : (adjoin R s).toSubmodule.FG) (h2 : (adjoin (adjoin R s) t).toSubmodule.FG) :
    (adjoin R (s ∪ t)).toSubmodule.FG :=
  by
  rcases fg_def.1 h1 with ⟨p, hp, hp'⟩
  rcases fg_def.1 h2 with ⟨q, hq, hq'⟩
  refine' fg_def.2 ⟨p * q, hp.mul hq, le_antisymm _ _⟩
  · rw [span_le]
    rintro _ ⟨x, y, hx, hy, rfl⟩
    change x * y ∈ _
    refine' Subalgebra.mul_mem _ _ _
    · have : x ∈ (adjoin R s).toSubmodule := by rw [← hp']; exact subset_span hx
      exact adjoin_mono (Set.subset_union_left _ _) this
    have : y ∈ (adjoin (adjoin R s) t).toSubmodule := by rw [← hq']; exact subset_span hy
    change y ∈ adjoin R (s ∪ t); rwa [adjoin_union_eq_adjoin_adjoin]
  · intro r hr
    change r ∈ adjoin R (s ∪ t) at hr 
    rw [adjoin_union_eq_adjoin_adjoin] at hr 
    change r ∈ (adjoin (adjoin R s) t).toSubmodule at hr 
    rw [← hq', ← Set.image_id q, Finsupp.mem_span_image_iff_total (adjoin R s)] at hr 
    rcases hr with ⟨l, hlq, rfl⟩
    have := @Finsupp.total_apply A A (adjoin R s)
    rw [this, Finsupp.sum]
    refine' sum_mem _
    intro z hz; change (l z).1 * _ ∈ _
    have : (l z).1 ∈ (adjoin R s).toSubmodule := (l z).2
    rw [← hp', ← Set.image_id p, Finsupp.mem_span_image_iff_total R] at this 
    rcases this with ⟨l2, hlp, hl⟩
    have := @Finsupp.total_apply A A R
    rw [this] at hl 
    rw [← hl, Finsupp.sum_mul]
    refine' sum_mem _
    intro t ht; change _ * _ ∈ _; rw [smul_mul_assoc]; refine' smul_mem _ _ _
    exact subset_span ⟨t, z, hlp ht, hlq hz, rfl⟩
#align algebra.fg_trans Algebra.fg_trans
-/

end Algebra

namespace Subalgebra

variable {R : Type u} {A : Type v} {B : Type w}

variable [CommSemiring R] [Semiring A] [Algebra R A] [Semiring B] [Algebra R B]

#print Subalgebra.FG /-
/-- A subalgebra `S` is finitely generated if there exists `t : finset A` such that
`algebra.adjoin R t = S`. -/
def FG (S : Subalgebra R A) : Prop :=
  ∃ t : Finset A, Algebra.adjoin R ↑t = S
#align subalgebra.fg Subalgebra.FG
-/

#print Subalgebra.fg_adjoin_finset /-
theorem fg_adjoin_finset (s : Finset A) : (Algebra.adjoin R (↑s : Set A)).FG :=
  ⟨s, rfl⟩
#align subalgebra.fg_adjoin_finset Subalgebra.fg_adjoin_finset
-/

#print Subalgebra.fg_def /-
theorem fg_def {S : Subalgebra R A} : S.FG ↔ ∃ t : Set A, Set.Finite t ∧ Algebra.adjoin R t = S :=
  Iff.symm Set.exists_finite_iff_finset
#align subalgebra.fg_def Subalgebra.fg_def
-/

#print Subalgebra.fg_bot /-
theorem fg_bot : (⊥ : Subalgebra R A).FG :=
  ⟨∅, Algebra.adjoin_empty R A⟩
#align subalgebra.fg_bot Subalgebra.fg_bot
-/

#print Subalgebra.fg_of_fg_toSubmodule /-
theorem fg_of_fg_toSubmodule {S : Subalgebra R A} : S.toSubmodule.FG → S.FG := fun ⟨t, ht⟩ =>
  ⟨t,
    le_antisymm (Algebra.adjoin_le fun x hx => show x ∈ S.toSubmodule from ht ▸ subset_span hx) <|
      show S.toSubmodule ≤ (Algebra.adjoin R ↑t).toSubmodule from fun x hx =>
        span_le.mpr (fun x hx => Algebra.subset_adjoin hx)
          (show x ∈ span R ↑t by rw [ht]; exact hx)⟩
#align subalgebra.fg_of_fg_to_submodule Subalgebra.fg_of_fg_toSubmodule
-/

#print Subalgebra.fg_of_noetherian /-
theorem fg_of_noetherian [IsNoetherian R A] (S : Subalgebra R A) : S.FG :=
  fg_of_fg_toSubmodule (IsNoetherian.noetherian S.toSubmodule)
#align subalgebra.fg_of_noetherian Subalgebra.fg_of_noetherian
-/

#print Subalgebra.fg_of_submodule_fg /-
theorem fg_of_submodule_fg (h : (⊤ : Submodule R A).FG) : (⊤ : Subalgebra R A).FG :=
  let ⟨s, hs⟩ := h
  ⟨s,
    toSubmodule.Injective <| by rw [Algebra.top_toSubmodule, eq_top_iff, ← hs, span_le];
      exact Algebra.subset_adjoin⟩
#align subalgebra.fg_of_submodule_fg Subalgebra.fg_of_submodule_fg
-/

#print Subalgebra.FG.prod /-
theorem FG.prod {S : Subalgebra R A} {T : Subalgebra R B} (hS : S.FG) (hT : T.FG) : (S.Prod T).FG :=
  by
  obtain ⟨s, hs⟩ := fg_def.1 hS
  obtain ⟨t, ht⟩ := fg_def.1 hT
  rw [← hs.2, ← ht.2]
  exact
    fg_def.2
      ⟨LinearMap.inl R A B '' (s ∪ {1}) ∪ LinearMap.inr R A B '' (t ∪ {1}),
        Set.Finite.union (Set.Finite.image _ (Set.Finite.union hs.1 (Set.finite_singleton _)))
          (Set.Finite.image _ (Set.Finite.union ht.1 (Set.finite_singleton _))),
        Algebra.adjoin_inl_union_inr_eq_prod R s t⟩
#align subalgebra.fg.prod Subalgebra.FG.prod
-/

section

open scoped Classical

#print Subalgebra.FG.map /-
theorem FG.map {S : Subalgebra R A} (f : A →ₐ[R] B) (hs : S.FG) : (S.map f).FG :=
  let ⟨s, hs⟩ := hs
  ⟨s.image f, by rw [Finset.coe_image, Algebra.adjoin_image, hs]⟩
#align subalgebra.fg.map Subalgebra.FG.map
-/

end

#print Subalgebra.fg_of_fg_map /-
theorem fg_of_fg_map (S : Subalgebra R A) (f : A →ₐ[R] B) (hf : Function.Injective f)
    (hs : (S.map f).FG) : S.FG :=
  let ⟨s, hs⟩ := hs
  ⟨s.Preimage f fun _ _ _ _ h => hf h,
    map_injective hf <|
      by
      rw [← Algebra.adjoin_image, Finset.coe_preimage, Set.image_preimage_eq_of_subset, hs]
      rw [← AlgHom.coe_range, ← Algebra.adjoin_le_iff, hs, ← Algebra.map_top];
      exact map_mono le_top⟩
#align subalgebra.fg_of_fg_map Subalgebra.fg_of_fg_map
-/

#print Subalgebra.fg_top /-
theorem fg_top (S : Subalgebra R A) : (⊤ : Subalgebra R S).FG ↔ S.FG :=
  ⟨fun h => by rw [← S.range_val, ← Algebra.map_top]; exact fg.map _ h, fun h =>
    fg_of_fg_map _ S.val Subtype.val_injective <| by rw [Algebra.map_top, range_val]; exact h⟩
#align subalgebra.fg_top Subalgebra.fg_top
-/

#print Subalgebra.induction_on_adjoin /-
theorem induction_on_adjoin [IsNoetherian R A] (P : Subalgebra R A → Prop) (base : P ⊥)
    (ih : ∀ (S : Subalgebra R A) (x : A), P S → P (Algebra.adjoin R (insert x S)))
    (S : Subalgebra R A) : P S := by
  classical
  obtain ⟨t, rfl⟩ := S.fg_of_noetherian
  refine' Finset.induction_on t _ _
  · simpa using base
  intro x t hxt h
  rw [Finset.coe_insert]
  simpa only [Algebra.adjoin_insert_adjoin] using ih _ x h
#align subalgebra.induction_on_adjoin Subalgebra.induction_on_adjoin
-/

end Subalgebra

section Semiring

variable {R : Type u} {A : Type v} {B : Type w}

variable [CommSemiring R] [CommRing A] [CommRing B] [Algebra R A] [Algebra R B]

#print AlgHom.isNoetherianRing_range /-
/-- The image of a Noetherian R-algebra under an R-algebra map is a Noetherian ring. -/
instance AlgHom.isNoetherianRing_range (f : A →ₐ[R] B) [IsNoetherianRing A] :
    IsNoetherianRing f.range :=
  isNoetherianRing_range f.toRingHom
#align alg_hom.is_noetherian_ring_range AlgHom.isNoetherianRing_range
-/

end Semiring

section Ring

variable {R : Type u} {A : Type v} {B : Type w}

variable [CommRing R] [CommRing A] [CommRing B] [Algebra R A] [Algebra R B]

#print isNoetherianRing_of_fg /-
theorem isNoetherianRing_of_fg {S : Subalgebra R A} (HS : S.FG) [IsNoetherianRing R] :
    IsNoetherianRing S :=
  let ⟨t, ht⟩ := HS
  ht ▸
    (Algebra.adjoin_eq_range R (↑t : Set A)).symm ▸ by
      haveI : IsNoetherianRing (MvPolynomial (↑t : Set A) R) := MvPolynomial.isNoetherianRing <;>
          convert AlgHom.isNoetherianRing_range _ <;>
        infer_instance
#align is_noetherian_ring_of_fg isNoetherianRing_of_fg
-/

#print is_noetherian_subring_closure /-
theorem is_noetherian_subring_closure (s : Set R) (hs : s.Finite) :
    IsNoetherianRing (Subring.closure s) :=
  show IsNoetherianRing (subalgebraOfSubring (Subring.closure s)) from
    Algebra.adjoin_int s ▸ isNoetherianRing_of_fg (Subalgebra.fg_def.2 ⟨s, hs, rfl⟩)
#align is_noetherian_subring_closure is_noetherian_subring_closure
-/

end Ring

