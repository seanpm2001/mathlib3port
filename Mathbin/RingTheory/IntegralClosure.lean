/-
Copyright (c) 2019 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module ring_theory.integral_closure
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.Expand
import Mathbin.LinearAlgebra.FiniteDimensional
import Mathbin.LinearAlgebra.Matrix.Charpoly.LinearMap
import Mathbin.RingTheory.Adjoin.Fg
import Mathbin.RingTheory.FiniteType
import Mathbin.RingTheory.Polynomial.ScaleRoots
import Mathbin.RingTheory.Polynomial.Tower
import Mathbin.RingTheory.TensorProduct

/-!
# Integral closure of a subring.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

If A is an R-algebra then `a : A` is integral over R if it is a root of a monic polynomial
with coefficients in R. Enough theory is developed to prove that integral elements
form a sub-R-algebra of A.

## Main definitions

Let `R` be a `comm_ring` and let `A` be an R-algebra.

* `ring_hom.is_integral_elem (f : R →+* A) (x : A)` : `x` is integral with respect to the map `f`,

* `is_integral (x : A)`  : `x` is integral over `R`, i.e., is a root of a monic polynomial with
                           coefficients in `R`.
* `integral_closure R A` : the integral closure of `R` in `A`, regarded as a sub-`R`-algebra of `A`.
-/


open scoped Classical

open scoped BigOperators Polynomial

open Polynomial Submodule

section Ring

variable {R S A : Type _}

variable [CommRing R] [Ring A] [Ring S] (f : R →+* S)

#print RingHom.IsIntegralElem /-
/-- An element `x` of `A` is said to be integral over `R` with respect to `f`
if it is a root of a monic polynomial `p : R[X]` evaluated under `f` -/
def RingHom.IsIntegralElem (f : R →+* A) (x : A) :=
  ∃ p : R[X], Monic p ∧ eval₂ f x p = 0
#align ring_hom.is_integral_elem RingHom.IsIntegralElem
-/

#print RingHom.IsIntegral /-
/-- A ring homomorphism `f : R →+* A` is said to be integral
if every element `A` is integral with respect to the map `f` -/
def RingHom.IsIntegral (f : R →+* A) :=
  ∀ x : A, f.IsIntegralElem x
#align ring_hom.is_integral RingHom.IsIntegral
-/

variable [Algebra R A] (R)

#print IsIntegral /-
/-- An element `x` of an algebra `A` over a commutative ring `R` is said to be *integral*,
if it is a root of some monic polynomial `p : R[X]`.
Equivalently, the element is integral over `R` with respect to the induced `algebra_map` -/
def IsIntegral (x : A) : Prop :=
  (algebraMap R A).IsIntegralElem x
#align is_integral IsIntegral
-/

variable (A)

#print Algebra.IsIntegral /-
/-- An algebra is integral if every element of the extension is integral over the base ring -/
protected def Algebra.IsIntegral : Prop :=
  (algebraMap R A).IsIntegral
#align algebra.is_integral Algebra.IsIntegral
-/

variable {R A}

#print RingHom.is_integral_map /-
theorem RingHom.is_integral_map {x : R} : f.IsIntegralElem (f x) :=
  ⟨X - C x, monic_X_sub_C _, by simp⟩
#align ring_hom.is_integral_map RingHom.is_integral_map
-/

#print isIntegral_algebraMap /-
theorem isIntegral_algebraMap {x : R} : IsIntegral R (algebraMap R A x) :=
  (algebraMap R A).is_integral_map
#align is_integral_algebra_map isIntegral_algebraMap
-/

#print isIntegral_of_noetherian /-
theorem isIntegral_of_noetherian (H : IsNoetherian R A) (x : A) : IsIntegral R x :=
  by
  let leval : R[X] →ₗ[R] A := (aeval x).toLinearMap
  let D : ℕ → Submodule R A := fun n => (degree_le R n).map leval
  let M := WellFounded.min (isNoetherian_iff_wellFounded.1 H) (Set.range D) ⟨_, ⟨0, rfl⟩⟩
  have HM : M ∈ Set.range D := WellFounded.min_mem _ _ _
  cases' HM with N HN
  have HM : ¬M < D (N + 1) :=
    WellFounded.not_lt_min (isNoetherian_iff_wellFounded.1 H) (Set.range D) _ ⟨N + 1, rfl⟩
  rw [← HN] at HM 
  have HN2 : D (N + 1) ≤ D N :=
    by_contradiction fun H =>
      HM (lt_of_le_not_le (map_mono (degree_le_mono (WithBot.coe_le_coe.2 (Nat.le_succ N)))) H)
  have HN3 : leval (X ^ (N + 1)) ∈ D N := HN2 (mem_map_of_mem (mem_degree_le.2 (degree_X_pow_le _)))
  rcases HN3 with ⟨p, hdp, hpe⟩
  refine' ⟨X ^ (N + 1) - p, monic_X_pow_sub (mem_degree_le.1 hdp), _⟩
  show leval (X ^ (N + 1) - p) = 0
  rw [LinearMap.map_sub, hpe, sub_self]
#align is_integral_of_noetherian isIntegral_of_noetherian
-/

#print isIntegral_of_submodule_noetherian /-
theorem isIntegral_of_submodule_noetherian (S : Subalgebra R A) (H : IsNoetherian R S.toSubmodule)
    (x : A) (hx : x ∈ S) : IsIntegral R x :=
  by
  suffices IsIntegral R (show S from ⟨x, hx⟩)
    by
    rcases this with ⟨p, hpm, hpx⟩
    replace hpx := congr_arg S.val hpx
    refine' ⟨p, hpm, Eq.trans _ hpx⟩
    simp only [aeval_def, eval₂, sum_def]
    rw [S.val.map_sum]
    refine' Finset.sum_congr rfl fun n hn => _
    rw [S.val.map_mul, S.val.map_pow, S.val.commutes, S.val_apply, Subtype.coe_mk]
  refine' isIntegral_of_noetherian H ⟨x, hx⟩
#align is_integral_of_submodule_noetherian isIntegral_of_submodule_noetherian
-/

end Ring

section

variable {R A B S : Type _}

variable [CommRing R] [CommRing A] [CommRing B] [CommRing S]

variable [Algebra R A] [Algebra R B] (f : R →+* S)

#print map_isIntegral /-
theorem map_isIntegral {B C F : Type _} [Ring B] [Ring C] [Algebra R B] [Algebra A B] [Algebra R C]
    [IsScalarTower R A B] [Algebra A C] [IsScalarTower R A C] {b : B} [AlgHomClass F A B C] (f : F)
    (hb : IsIntegral R b) : IsIntegral R (f b) :=
  by
  obtain ⟨P, hP⟩ := hb
  refine' ⟨P, hP.1, _⟩
  rw [← aeval_def, show (aeval (f b)) P = (aeval (f b)) (P.map (algebraMap R A)) by simp,
    aeval_alg_hom_apply, aeval_map_algebra_map, aeval_def, hP.2, _root_.map_zero]
#align map_is_integral map_isIntegral
-/

#print isIntegral_map_of_comp_eq_of_isIntegral /-
theorem isIntegral_map_of_comp_eq_of_isIntegral {R S T U : Type _} [CommRing R] [CommRing S]
    [CommRing T] [CommRing U] [Algebra R S] [Algebra T U] (φ : R →+* T) (ψ : S →+* U)
    (h : (algebraMap T U).comp φ = ψ.comp (algebraMap R S)) {a : S} (ha : IsIntegral R a) :
    IsIntegral T (ψ a) := by
  rw [IsIntegral, RingHom.IsIntegralElem] at ha ⊢
  obtain ⟨p, hp⟩ := ha
  refine' ⟨p.map φ, hp.left.map _, _⟩
  rw [← eval_map, map_map, h, ← map_map, eval_map, eval₂_at_apply, eval_map, hp.right,
    RingHom.map_zero]
#align is_integral_map_of_comp_eq_of_is_integral isIntegral_map_of_comp_eq_of_isIntegral
-/

#print isIntegral_algHom_iff /-
theorem isIntegral_algHom_iff {A B : Type _} [Ring A] [Ring B] [Algebra R A] [Algebra R B]
    (f : A →ₐ[R] B) (hf : Function.Injective f) {x : A} : IsIntegral R (f x) ↔ IsIntegral R x :=
  by
  refine' ⟨_, map_isIntegral f⟩
  rintro ⟨p, hp, hx⟩
  use p, hp
  rwa [← f.comp_algebra_map, ← AlgHom.coe_toRingHom, ← Polynomial.hom_eval₂, AlgHom.coe_toRingHom,
    map_eq_zero_iff f hf] at hx 
#align is_integral_alg_hom_iff isIntegral_algHom_iff
-/

#print isIntegral_algEquiv /-
@[simp]
theorem isIntegral_algEquiv {A B : Type _} [Ring A] [Ring B] [Algebra R A] [Algebra R B]
    (f : A ≃ₐ[R] B) {x : A} : IsIntegral R (f x) ↔ IsIntegral R x :=
  ⟨fun h => by simpa using map_isIntegral f.symm.to_alg_hom h, map_isIntegral f.toAlgHom⟩
#align is_integral_alg_equiv isIntegral_algEquiv
-/

#print isIntegral_of_isScalarTower /-
theorem isIntegral_of_isScalarTower [Algebra A B] [IsScalarTower R A B] {x : B}
    (hx : IsIntegral R x) : IsIntegral A x :=
  let ⟨p, hp, hpx⟩ := hx
  ⟨p.map <| algebraMap R A, hp.map _, by rw [← aeval_def, aeval_map_algebra_map, aeval_def, hpx]⟩
#align is_integral_of_is_scalar_tower isIntegral_of_isScalarTower
-/

#print map_isIntegral_int /-
theorem map_isIntegral_int {B C F : Type _} [Ring B] [Ring C] {b : B} [RingHomClass F B C] (f : F)
    (hb : IsIntegral ℤ b) : IsIntegral ℤ (f b) :=
  map_isIntegral (f : B →+* C).toIntAlgHom hb
#align map_is_integral_int map_isIntegral_int
-/

#print isIntegral_ofSubring /-
theorem isIntegral_ofSubring {x : A} (T : Subring R) (hx : IsIntegral T x) : IsIntegral R x :=
  isIntegral_of_isScalarTower hx
#align is_integral_of_subring isIntegral_ofSubring
-/

#print IsIntegral.algebraMap /-
theorem IsIntegral.algebraMap [Algebra A B] [IsScalarTower R A B] {x : A} (h : IsIntegral R x) :
    IsIntegral R (algebraMap A B x) :=
  by
  rcases h with ⟨f, hf, hx⟩
  use f, hf
  rw [IsScalarTower.algebraMap_eq R A B, ← hom_eval₂, hx, RingHom.map_zero]
#align is_integral.algebra_map IsIntegral.algebraMap
-/

#print isIntegral_algebraMap_iff /-
theorem isIntegral_algebraMap_iff [Algebra A B] [IsScalarTower R A B] {x : A}
    (hAB : Function.Injective (algebraMap A B)) :
    IsIntegral R (algebraMap A B x) ↔ IsIntegral R x :=
  isIntegral_algHom_iff (IsScalarTower.toAlgHom R A B) hAB
#align is_integral_algebra_map_iff isIntegral_algebraMap_iff
-/

#print isIntegral_iff_isIntegral_closure_finite /-
theorem isIntegral_iff_isIntegral_closure_finite {r : A} :
    IsIntegral R r ↔ ∃ s : Set R, s.Finite ∧ IsIntegral (Subring.closure s) r :=
  by
  constructor <;> intro hr
  · rcases hr with ⟨p, hmp, hpr⟩
    refine' ⟨_, Finset.finite_toSet _, p.restriction, monic_restriction.2 hmp, _⟩
    rw [← aeval_def, ← aeval_map_algebra_map R r p.restriction, map_restriction, aeval_def, hpr]
  rcases hr with ⟨s, hs, hsr⟩
  exact isIntegral_ofSubring _ hsr
#align is_integral_iff_is_integral_closure_finite isIntegral_iff_isIntegral_closure_finite
-/

#print FG_adjoin_singleton_of_integral /-
theorem FG_adjoin_singleton_of_integral (x : A) (hx : IsIntegral R x) :
    (Algebra.adjoin R ({x} : Set A)).toSubmodule.FG :=
  by
  rcases hx with ⟨f, hfm, hfx⟩
  exists Finset.image ((· ^ ·) x) (Finset.range (nat_degree f + 1))
  apply le_antisymm
  · rw [span_le]; intro s hs; rw [Finset.mem_coe] at hs 
    rcases Finset.mem_image.1 hs with ⟨k, hk, rfl⟩; clear hk
    exact (Algebra.adjoin R {x}).pow_mem (Algebra.subset_adjoin (Set.mem_singleton _)) k
  intro r hr; change r ∈ Algebra.adjoin R ({x} : Set A) at hr 
  rw [Algebra.adjoin_singleton_eq_range_aeval] at hr 
  rcases(aeval x).mem_range.mp hr with ⟨p, rfl⟩
  rw [← mod_by_monic_add_div p hfm]
  rw [← aeval_def] at hfx 
  rw [AlgHom.map_add, AlgHom.map_mul, hfx, MulZeroClass.zero_mul, add_zero]
  have : degree (p %ₘ f) ≤ degree f := degree_mod_by_monic_le p hfm
  generalize p %ₘ f = q at this ⊢
  rw [← sum_C_mul_X_pow_eq q, aeval_def, eval₂_sum, sum_def]
  refine' sum_mem fun k hkq => _
  rw [eval₂_mul, eval₂_C, eval₂_pow, eval₂_X, ← Algebra.smul_def]
  refine' smul_mem _ _ (subset_span _)
  rw [Finset.mem_coe]; refine' Finset.mem_image.2 ⟨_, _, rfl⟩
  rw [Finset.mem_range, Nat.lt_succ_iff]; refine' le_of_not_lt fun hk => _
  rw [degree_le_iff_coeff_zero] at this 
  rw [mem_support_iff] at hkq ; apply hkq; apply this
  exact lt_of_le_of_lt degree_le_nat_degree (WithBot.coe_lt_coe.2 hk)
#align fg_adjoin_singleton_of_integral FG_adjoin_singleton_of_integral
-/

#print FG_adjoin_of_finite /-
theorem FG_adjoin_of_finite {s : Set A} (hfs : s.Finite) (his : ∀ x ∈ s, IsIntegral R x) :
    (Algebra.adjoin R s).toSubmodule.FG :=
  Set.Finite.induction_on hfs
    (fun _ =>
      ⟨{1},
        Submodule.ext fun x =>
          by
          erw [Algebra.adjoin_empty, Finset.coe_singleton, ← one_eq_span, one_eq_range,
            LinearMap.mem_range, Algebra.mem_bot]
          rfl⟩)
    (fun a s has hs ih his => by
      rw [← Set.union_singleton, Algebra.adjoin_union_coe_submodule] <;>
        exact
          fg.mul (ih fun i hi => his i <| Set.mem_insert_of_mem a hi)
            (FG_adjoin_singleton_of_integral _ <| his a <| Set.mem_insert a s))
    his
#align fg_adjoin_of_finite FG_adjoin_of_finite
-/

#print isNoetherian_adjoin_finset /-
theorem isNoetherian_adjoin_finset [IsNoetherianRing R] (s : Finset A)
    (hs : ∀ x ∈ s, IsIntegral R x) : IsNoetherian R (Algebra.adjoin R (↑s : Set A)) :=
  isNoetherian_of_fg_of_noetherian _ (FG_adjoin_of_finite s.finite_toSet hs)
#align is_noetherian_adjoin_finset isNoetherian_adjoin_finset
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print isIntegral_of_mem_of_FG /-
/-- If `S` is a sub-`R`-algebra of `A` and `S` is finitely-generated as an `R`-module,
  then all elements of `S` are integral over `R`. -/
theorem isIntegral_of_mem_of_FG (S : Subalgebra R A) (HS : S.toSubmodule.FG) (x : A) (hx : x ∈ S) :
    IsIntegral R x :=
  by
  -- say `x ∈ S`. We want to prove that `x` is integral over `R`.
  -- Say `S` is generated as an `R`-module by the set `y`.
  cases' HS with y hy
  -- We can write `x` as `∑ rᵢ yᵢ` for `yᵢ ∈ Y`.
  obtain ⟨lx, hlx1, hlx2⟩ :
    ∃ (l : A →₀ R) (H : l ∈ Finsupp.supported R R ↑y), (Finsupp.total A A R id) l = x := by
    rwa [← @Finsupp.mem_span_image_iff_total A A R _ _ _ id (↑y) x, Set.image_id ↑y, hy]
  -- Note that `y ⊆ S`.
  have hyS : ∀ {p}, p ∈ y → p ∈ S := fun p hp =>
    show p ∈ S.to_submodule by rw [← hy]; exact subset_span hp
  -- Now `S` is a subalgebra so the product of two elements of `y` is also in `S`.
  have : ∀ jk : (↑(y ×ˢ y) : Set (A × A)), jk.1.1 * jk.1.2 ∈ S.to_submodule := fun jk =>
    S.mul_mem (hyS (Finset.mem_product.1 jk.2).1) (hyS (Finset.mem_product.1 jk.2).2)
  rw [← hy, ← Set.image_id ↑y] at this ; simp only [Finsupp.mem_span_image_iff_total] at this 
  -- Say `yᵢyⱼ = ∑rᵢⱼₖ yₖ`
  choose ly hly1 hly2
  -- Now let `S₀` be the subring of `R` generated by the `rᵢ` and the `rᵢⱼₖ`.
  let S₀ : Subring R :=
    Subring.closure ↑(lx.frange ∪ Finset.biUnion Finset.univ (Finsupp.frange ∘ ly))
  -- It suffices to prove that `x` is integral over `S₀`.
  refine' isIntegral_ofSubring S₀ _
  letI : CommRing S₀ := SubringClass.toCommRing S₀
  letI : Algebra S₀ A := Algebra.ofSubring S₀
  -- Claim: the `S₀`-module span (in `A`) of the set `y ∪ {1}` is closed under
  -- multiplication (indeed, this is the motivation for the definition of `S₀`).
  have :
    span S₀ (insert 1 ↑y : Set A) * span S₀ (insert 1 ↑y : Set A) ≤ span S₀ (insert 1 ↑y : Set A) :=
    by
    rw [span_mul_span]; refine' span_le.2 fun z hz => _
    rcases Set.mem_mul.1 hz with ⟨p, q, rfl | hp, hq, rfl⟩
    · rw [one_mul]; exact subset_span hq
    rcases hq with (rfl | hq)
    · rw [mul_one]; exact subset_span (Or.inr hp)
    erw [← hly2 ⟨(p, q), Finset.mem_product.2 ⟨hp, hq⟩⟩]
    rw [Finsupp.total_apply, Finsupp.sum]
    refine' (span S₀ (insert 1 ↑y : Set A)).sum_mem fun t ht => _
    have : ly ⟨(p, q), Finset.mem_product.2 ⟨hp, hq⟩⟩ t ∈ S₀ :=
      Subring.subset_closure
        (Finset.mem_union_right _ <|
          Finset.mem_biUnion.2
            ⟨⟨(p, q), Finset.mem_product.2 ⟨hp, hq⟩⟩, Finset.mem_univ _,
              Finsupp.mem_frange.2 ⟨Finsupp.mem_support_iff.1 ht, _, rfl⟩⟩)
    change (⟨_, this⟩ : S₀) • t ∈ _; exact smul_mem _ _ (subset_span <| Or.inr <| hly1 _ ht)
  -- Hence this span is a subring. Call this subring `S₁`.
  let S₁ : Subring A :=
    { carrier := span S₀ (insert 1 ↑y : Set A)
      one_mem' := subset_span <| Or.inl rfl
      mul_mem' := fun p q hp hq => this <| mul_mem_mul hp hq
      zero_mem' := (span S₀ (insert 1 ↑y : Set A)).zero_mem
      add_mem' := fun _ _ => (span S₀ (insert 1 ↑y : Set A)).add_mem
      neg_mem' := fun _ => (span S₀ (insert 1 ↑y : Set A)).neg_mem }
  have : S₁ = Subalgebra.toSubring (Algebra.adjoin S₀ (↑y : Set A)) :=
    by
    ext z
    suffices
      z ∈ span (↥S₀) (insert 1 ↑y : Set A) ↔ z ∈ (Algebra.adjoin (↥S₀) (y : Set A)).toSubmodule by
      simpa
    constructor <;> intro hz
    ·
      exact
        (span_le.2
            (Set.insert_subset_iff.2 ⟨(Algebra.adjoin S₀ ↑y).one_mem, Algebra.subset_adjoin⟩))
          hz
    · rw [Subalgebra.mem_toSubmodule, Algebra.mem_adjoin_iff] at hz 
      suffices Subring.closure (Set.range ⇑(algebraMap (↥S₀) A) ∪ ↑y) ≤ S₁ by exact this hz
      refine' Subring.closure_le.2 (Set.union_subset _ fun t ht => subset_span <| Or.inr ht)
      rw [Set.range_subset_iff]
      intro y
      rw [Algebra.algebraMap_eq_smul_one]
      exact smul_mem _ y (subset_span (Or.inl rfl))
  have foo : ∀ z, z ∈ S₁ ↔ z ∈ Algebra.adjoin (↥S₀) (y : Set A)
  simp [this]
  haveI : IsNoetherianRing ↥S₀ := is_noetherian_subring_closure _ (Finset.finite_toSet _)
  refine'
    isIntegral_of_submodule_noetherian (Algebra.adjoin S₀ ↑y)
      (isNoetherian_of_fg_of_noetherian _
        ⟨insert 1 y, by rw [Finset.coe_insert]; ext z; simp [S₁]; convert foo z⟩)
      _ _
  rw [← hlx2, Finsupp.total_apply, Finsupp.sum]; refine' Subalgebra.sum_mem _ fun r hr => _
  have : lx r ∈ S₀ :=
    Subring.subset_closure (Finset.mem_union_left _ (Finset.mem_image_of_mem _ hr))
  change (⟨_, this⟩ : S₀) • r ∈ _
  rw [Finsupp.mem_supported] at hlx1 
  exact Subalgebra.smul_mem _ (Algebra.subset_adjoin <| hlx1 hr) _
#align is_integral_of_mem_of_fg isIntegral_of_mem_of_FG
-/

#print Module.End.isIntegral /-
theorem Module.End.isIntegral {M : Type _} [AddCommGroup M] [Module R M] [Module.Finite R M] :
    Algebra.IsIntegral R (Module.End R M) :=
  LinearMap.exists_monic_and_aeval_eq_zero R
#align module.End.is_integral Module.End.isIntegral
-/

#print isIntegral_of_smul_mem_submodule /-
/-- Suppose `A` is an `R`-algebra, `M` is an `A`-module such that `a • m ≠ 0` for all non-zero `a`
and `m`. If `x : A` fixes a nontrivial f.g. `R`-submodule `N` of `M`, then `x` is `R`-integral. -/
theorem isIntegral_of_smul_mem_submodule {M : Type _} [AddCommGroup M] [Module R M] [Module A M]
    [IsScalarTower R A M] [NoZeroSMulDivisors A M] (N : Submodule R M) (hN : N ≠ ⊥) (hN' : N.FG)
    (x : A) (hx : ∀ n ∈ N, x • n ∈ N) : IsIntegral R x :=
  by
  let A' : Subalgebra R A :=
    { carrier := {x | ∀ n ∈ N, x • n ∈ N}
      mul_mem' := fun a b ha hb n hn => smul_smul a b n ▸ ha _ (hb _ hn)
      one_mem' := fun n hn => (one_smul A n).symm ▸ hn
      add_mem' := fun a b ha hb n hn => (add_smul a b n).symm ▸ N.add_mem (ha _ hn) (hb _ hn)
      zero_mem' := fun n hn => (zero_smul A n).symm ▸ N.zero_mem
      algebraMap_mem' := fun r n hn => (algebraMap_smul A r n).symm ▸ N.smul_mem r hn }
  let f : A' →ₐ[R] Module.End R N :=
    AlgHom.ofLinearMap
      { toFun := fun x => (DistribMulAction.toLinearMap R M x).restrict x.Prop
        map_add' := fun x y => LinearMap.ext fun n => Subtype.ext <| add_smul x y n
        map_smul' := fun r s => LinearMap.ext fun n => Subtype.ext <| smul_assoc r s n }
      (LinearMap.ext fun n => Subtype.ext <| one_smul _ _) fun x y =>
      LinearMap.ext fun n => Subtype.ext <| mul_smul x y n
  obtain ⟨a, ha₁, ha₂⟩ : ∃ a ∈ N, a ≠ (0 : M) := by by_contra h'; push_neg at h' ; apply hN;
    rwa [eq_bot_iff]
  have : Function.Injective f :=
    by
    show Function.Injective f.to_linear_map
    rw [← LinearMap.ker_eq_bot, eq_bot_iff]
    intro s hs
    have : s.1 • a = 0 := congr_arg Subtype.val (LinearMap.congr_fun hs ⟨a, ha₁⟩)
    exact Subtype.ext ((eq_zero_or_eq_zero_of_smul_eq_zero this).resolve_right ha₂)
  show IsIntegral R (A'.val ⟨x, hx⟩)
  rw [isIntegral_algHom_iff A'.val Subtype.val_injective, ← isIntegral_algHom_iff f this]
  haveI : Module.Finite R N := by rwa [Module.finite_def, Submodule.fg_top]
  apply Module.End.isIntegral
#align is_integral_of_smul_mem_submodule isIntegral_of_smul_mem_submodule
-/

variable {f}

#print RingHom.Finite.to_isIntegral /-
theorem RingHom.Finite.to_isIntegral (h : f.Finite) : f.IsIntegral :=
  letI := f.to_algebra
  fun x => isIntegral_of_mem_of_FG ⊤ h.1 _ trivial
#align ring_hom.finite.to_is_integral RingHom.Finite.to_isIntegral
-/

alias RingHom.Finite.to_isIntegral ← RingHom.IsIntegral.of_finite
#align ring_hom.is_integral.of_finite RingHom.IsIntegral.of_finite

#print RingHom.IsIntegral.to_finite /-
theorem RingHom.IsIntegral.to_finite (h : f.IsIntegral) (h' : f.FiniteType) : f.Finite :=
  by
  letI := f.to_algebra
  obtain ⟨s, hs⟩ := h'
  constructor
  change (⊤ : Subalgebra R S).toSubmodule.FG
  rw [← hs]
  exact FG_adjoin_of_finite (Set.toFinite _) fun x _ => h x
#align ring_hom.is_integral.to_finite RingHom.IsIntegral.to_finite
-/

alias RingHom.IsIntegral.to_finite ← RingHom.Finite.of_isIntegral_of_finiteType
#align ring_hom.finite.of_is_integral_of_finite_type RingHom.Finite.of_isIntegral_of_finiteType

#print RingHom.finite_iff_isIntegral_and_finiteType /-
/-- finite = integral + finite type -/
theorem RingHom.finite_iff_isIntegral_and_finiteType : f.Finite ↔ f.IsIntegral ∧ f.FiniteType :=
  ⟨fun h => ⟨h.to_isIntegral, h.to_finiteType⟩, fun ⟨h, h'⟩ => h.toFinite h'⟩
#align ring_hom.finite_iff_is_integral_and_finite_type RingHom.finite_iff_isIntegral_and_finiteType
-/

#print Algebra.IsIntegral.finite /-
theorem Algebra.IsIntegral.finite (h : Algebra.IsIntegral R A) [h' : Algebra.FiniteType R A] :
    Module.Finite R A :=
  by
  have :=
    h.to_finite (by delta RingHom.FiniteType; convert h'; ext; exact (Algebra.smul_def _ _).symm)
  delta RingHom.Finite at this ; convert this; ext; exact Algebra.smul_def _ _
#align algebra.is_integral.finite Algebra.IsIntegral.finite
-/

#print Algebra.IsIntegral.of_finite /-
theorem Algebra.IsIntegral.of_finite [h : Module.Finite R A] : Algebra.IsIntegral R A :=
  by
  apply RingHom.Finite.to_isIntegral
  delta RingHom.Finite; convert h; ext; exact (Algebra.smul_def _ _).symm
#align algebra.is_integral.of_finite Algebra.IsIntegral.of_finite
-/

#print Algebra.finite_iff_isIntegral_and_finiteType /-
/-- finite = integral + finite type -/
theorem Algebra.finite_iff_isIntegral_and_finiteType :
    Module.Finite R A ↔ Algebra.IsIntegral R A ∧ Algebra.FiniteType R A :=
  ⟨fun h => ⟨Algebra.IsIntegral.of_finite, inferInstance⟩, fun ⟨h, h'⟩ => h.finite⟩
#align algebra.finite_iff_is_integral_and_finite_type Algebra.finite_iff_isIntegral_and_finiteType
-/

variable (f)

#print RingHom.is_integral_of_mem_closure /-
theorem RingHom.is_integral_of_mem_closure {x y z : S} (hx : f.IsIntegralElem x)
    (hy : f.IsIntegralElem y) (hz : z ∈ Subring.closure ({x, y} : Set S)) : f.IsIntegralElem z :=
  by
  letI : Algebra R S := f.to_algebra
  have := (FG_adjoin_singleton_of_integral x hx).mul (FG_adjoin_singleton_of_integral y hy)
  rw [← Algebra.adjoin_union_coe_submodule, Set.singleton_union] at this 
  exact
    isIntegral_of_mem_of_FG (Algebra.adjoin R {x, y}) this z
      (Algebra.mem_adjoin_iff.2 <| Subring.closure_mono (Set.subset_union_right _ _) hz)
#align ring_hom.is_integral_of_mem_closure RingHom.is_integral_of_mem_closure
-/

#print isIntegral_of_mem_closure /-
theorem isIntegral_of_mem_closure {x y z : A} (hx : IsIntegral R x) (hy : IsIntegral R y)
    (hz : z ∈ Subring.closure ({x, y} : Set A)) : IsIntegral R z :=
  (algebraMap R A).is_integral_of_mem_closure hx hy hz
#align is_integral_of_mem_closure isIntegral_of_mem_closure
-/

#print RingHom.is_integral_zero /-
theorem RingHom.is_integral_zero : f.IsIntegralElem 0 :=
  f.map_zero ▸ f.is_integral_map
#align ring_hom.is_integral_zero RingHom.is_integral_zero
-/

#print isIntegral_zero /-
theorem isIntegral_zero : IsIntegral R (0 : A) :=
  (algebraMap R A).is_integral_zero
#align is_integral_zero isIntegral_zero
-/

#print RingHom.is_integral_one /-
theorem RingHom.is_integral_one : f.IsIntegralElem 1 :=
  f.map_one ▸ f.is_integral_map
#align ring_hom.is_integral_one RingHom.is_integral_one
-/

#print isIntegral_one /-
theorem isIntegral_one : IsIntegral R (1 : A) :=
  (algebraMap R A).is_integral_one
#align is_integral_one isIntegral_one
-/

#print RingHom.is_integral_add /-
theorem RingHom.is_integral_add {x y : S} (hx : f.IsIntegralElem x) (hy : f.IsIntegralElem y) :
    f.IsIntegralElem (x + y) :=
  f.is_integral_of_mem_closure hx hy <|
    Subring.add_mem _ (Subring.subset_closure (Or.inl rfl)) (Subring.subset_closure (Or.inr rfl))
#align ring_hom.is_integral_add RingHom.is_integral_add
-/

#print isIntegral_add /-
theorem isIntegral_add {x y : A} (hx : IsIntegral R x) (hy : IsIntegral R y) :
    IsIntegral R (x + y) :=
  (algebraMap R A).is_integral_add hx hy
#align is_integral_add isIntegral_add
-/

#print RingHom.is_integral_neg /-
theorem RingHom.is_integral_neg {x : S} (hx : f.IsIntegralElem x) : f.IsIntegralElem (-x) :=
  f.is_integral_of_mem_closure hx hx (Subring.neg_mem _ (Subring.subset_closure (Or.inl rfl)))
#align ring_hom.is_integral_neg RingHom.is_integral_neg
-/

#print isIntegral_neg /-
theorem isIntegral_neg {x : A} (hx : IsIntegral R x) : IsIntegral R (-x) :=
  (algebraMap R A).is_integral_neg hx
#align is_integral_neg isIntegral_neg
-/

#print RingHom.is_integral_sub /-
theorem RingHom.is_integral_sub {x y : S} (hx : f.IsIntegralElem x) (hy : f.IsIntegralElem y) :
    f.IsIntegralElem (x - y) := by
  simpa only [sub_eq_add_neg] using f.is_integral_add hx (f.is_integral_neg hy)
#align ring_hom.is_integral_sub RingHom.is_integral_sub
-/

#print isIntegral_sub /-
theorem isIntegral_sub {x y : A} (hx : IsIntegral R x) (hy : IsIntegral R y) :
    IsIntegral R (x - y) :=
  (algebraMap R A).is_integral_sub hx hy
#align is_integral_sub isIntegral_sub
-/

#print RingHom.is_integral_mul /-
theorem RingHom.is_integral_mul {x y : S} (hx : f.IsIntegralElem x) (hy : f.IsIntegralElem y) :
    f.IsIntegralElem (x * y) :=
  f.is_integral_of_mem_closure hx hy
    (Subring.mul_mem _ (Subring.subset_closure (Or.inl rfl)) (Subring.subset_closure (Or.inr rfl)))
#align ring_hom.is_integral_mul RingHom.is_integral_mul
-/

#print isIntegral_mul /-
theorem isIntegral_mul {x y : A} (hx : IsIntegral R x) (hy : IsIntegral R y) :
    IsIntegral R (x * y) :=
  (algebraMap R A).is_integral_mul hx hy
#align is_integral_mul isIntegral_mul
-/

#print isIntegral_smul /-
theorem isIntegral_smul [Algebra S A] [Algebra R S] [IsScalarTower R S A] {x : A} (r : R)
    (hx : IsIntegral S x) : IsIntegral S (r • x) :=
  by
  rw [Algebra.smul_def, IsScalarTower.algebraMap_apply R S A]
  exact isIntegral_mul isIntegral_algebraMap hx
#align is_integral_smul isIntegral_smul
-/

#print isIntegral_of_pow /-
theorem isIntegral_of_pow {x : A} {n : ℕ} (hn : 0 < n) (hx : IsIntegral R <| x ^ n) :
    IsIntegral R x := by
  rcases hx with ⟨p, ⟨hmonic, heval⟩⟩
  exact
    ⟨expand R n p, monic.expand hn hmonic, by
      rwa [eval₂_eq_eval_map, map_expand, expand_eval, ← eval₂_eq_eval_map]⟩
#align is_integral_of_pow isIntegral_of_pow
-/

variable (R A)

#print integralClosure /-
/-- The integral closure of R in an R-algebra A. -/
def integralClosure : Subalgebra R A
    where
  carrier := {r | IsIntegral R r}
  zero_mem' := isIntegral_zero
  one_mem' := isIntegral_one
  add_mem' _ _ := isIntegral_add
  mul_mem' _ _ := isIntegral_mul
  algebraMap_mem' x := isIntegral_algebraMap
#align integral_closure integralClosure
-/

#print mem_integralClosure_iff_mem_FG /-
theorem mem_integralClosure_iff_mem_FG {r : A} :
    r ∈ integralClosure R A ↔ ∃ M : Subalgebra R A, M.toSubmodule.FG ∧ r ∈ M :=
  ⟨fun hr =>
    ⟨Algebra.adjoin R {r}, FG_adjoin_singleton_of_integral _ hr, Algebra.subset_adjoin rfl⟩,
    fun ⟨M, Hf, hrM⟩ => isIntegral_of_mem_of_FG M Hf _ hrM⟩
#align mem_integral_closure_iff_mem_fg mem_integralClosure_iff_mem_FG
-/

variable {R} {A}

#print adjoin_le_integralClosure /-
theorem adjoin_le_integralClosure {x : A} (hx : IsIntegral R x) :
    Algebra.adjoin R {x} ≤ integralClosure R A :=
  by
  rw [Algebra.adjoin_le_iff]
  simp only [SetLike.mem_coe, Set.singleton_subset_iff]
  exact hx
#align adjoin_le_integral_closure adjoin_le_integralClosure
-/

#print le_integralClosure_iff_isIntegral /-
theorem le_integralClosure_iff_isIntegral {S : Subalgebra R A} :
    S ≤ integralClosure R A ↔ Algebra.IsIntegral R S :=
  SetLike.forall.symm.trans
    (forall_congr' fun x =>
      show IsIntegral R (algebraMap S A x) ↔ IsIntegral R x from
        isIntegral_algebraMap_iff Subtype.coe_injective)
#align le_integral_closure_iff_is_integral le_integralClosure_iff_isIntegral
-/

#print isIntegral_sup /-
theorem isIntegral_sup {S T : Subalgebra R A} :
    Algebra.IsIntegral R ↥(S ⊔ T) ↔ Algebra.IsIntegral R S ∧ Algebra.IsIntegral R T := by
  simp only [← le_integralClosure_iff_isIntegral, sup_le_iff]
#align is_integral_sup isIntegral_sup
-/

#print integralClosure_map_algEquiv /-
/-- Mapping an integral closure along an `alg_equiv` gives the integral closure. -/
theorem integralClosure_map_algEquiv (f : A ≃ₐ[R] B) :
    (integralClosure R A).map (f : A →ₐ[R] B) = integralClosure R B :=
  by
  ext y
  rw [Subalgebra.mem_map]
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact map_isIntegral f hx
  · intro hy
    use f.symm y, map_isIntegral (f.symm : B →ₐ[R] A) hy
    simp
#align integral_closure_map_alg_equiv integralClosure_map_algEquiv
-/

#print integralClosure.isIntegral /-
theorem integralClosure.isIntegral (x : integralClosure R A) : IsIntegral R x :=
  let ⟨p, hpm, hpx⟩ := x.2
  ⟨p, hpm,
    Subtype.eq <| by
      rwa [← aeval_def, Subtype.val_eq_coe, ← Subalgebra.val_apply, aeval_alg_hom_apply] at hpx ⟩
#align integral_closure.is_integral integralClosure.isIntegral
-/

#print RingHom.is_integral_of_is_integral_mul_unit /-
theorem RingHom.is_integral_of_is_integral_mul_unit (x y : S) (r : R) (hr : f r * y = 1)
    (hx : f.IsIntegralElem (x * y)) : f.IsIntegralElem x :=
  by
  obtain ⟨p, ⟨p_monic, hp⟩⟩ := hx
  refine' ⟨scale_roots p r, ⟨(monic_scale_roots_iff r).2 p_monic, _⟩⟩
  convert scale_roots_eval₂_eq_zero f hp
  rw [mul_comm x y, ← mul_assoc, hr, one_mul]
#align ring_hom.is_integral_of_is_integral_mul_unit RingHom.is_integral_of_is_integral_mul_unit
-/

#print isIntegral_of_isIntegral_mul_unit /-
theorem isIntegral_of_isIntegral_mul_unit {x y : A} {r : R} (hr : algebraMap R A r * y = 1)
    (hx : IsIntegral R (x * y)) : IsIntegral R x :=
  (algebraMap R A).is_integral_of_is_integral_mul_unit x y r hr hx
#align is_integral_of_is_integral_mul_unit isIntegral_of_isIntegral_mul_unit
-/

#print isIntegral_of_mem_closure' /-
/-- Generalization of `is_integral_of_mem_closure` bootstrapped up from that lemma -/
theorem isIntegral_of_mem_closure' (G : Set A) (hG : ∀ x ∈ G, IsIntegral R x) :
    ∀ x ∈ Subring.closure G, IsIntegral R x := fun x hx =>
  Subring.closure_induction hx hG isIntegral_zero isIntegral_one (fun _ _ => isIntegral_add)
    (fun _ => isIntegral_neg) fun _ _ => isIntegral_mul
#align is_integral_of_mem_closure' isIntegral_of_mem_closure'
-/

#print is_integral_of_mem_closure'' /-
theorem is_integral_of_mem_closure'' {S : Type _} [CommRing S] {f : R →+* S} (G : Set S)
    (hG : ∀ x ∈ G, f.IsIntegralElem x) : ∀ x ∈ Subring.closure G, f.IsIntegralElem x := fun x hx =>
  @isIntegral_of_mem_closure' R S _ _ f.toAlgebra G hG x hx
#align is_integral_of_mem_closure'' is_integral_of_mem_closure''
-/

#print IsIntegral.pow /-
theorem IsIntegral.pow {x : A} (h : IsIntegral R x) (n : ℕ) : IsIntegral R (x ^ n) :=
  (integralClosure R A).pow_mem h n
#align is_integral.pow IsIntegral.pow
-/

#print IsIntegral.nsmul /-
theorem IsIntegral.nsmul {x : A} (h : IsIntegral R x) (n : ℕ) : IsIntegral R (n • x) :=
  (integralClosure R A).nsmul_mem h n
#align is_integral.nsmul IsIntegral.nsmul
-/

#print IsIntegral.zsmul /-
theorem IsIntegral.zsmul {x : A} (h : IsIntegral R x) (n : ℤ) : IsIntegral R (n • x) :=
  (integralClosure R A).zsmul_mem h n
#align is_integral.zsmul IsIntegral.zsmul
-/

#print IsIntegral.multiset_prod /-
theorem IsIntegral.multiset_prod {s : Multiset A} (h : ∀ x ∈ s, IsIntegral R x) :
    IsIntegral R s.Prod :=
  (integralClosure R A).multiset_prod_mem h
#align is_integral.multiset_prod IsIntegral.multiset_prod
-/

#print IsIntegral.multiset_sum /-
theorem IsIntegral.multiset_sum {s : Multiset A} (h : ∀ x ∈ s, IsIntegral R x) :
    IsIntegral R s.Sum :=
  (integralClosure R A).multiset_sum_mem h
#align is_integral.multiset_sum IsIntegral.multiset_sum
-/

#print IsIntegral.prod /-
theorem IsIntegral.prod {α : Type _} {s : Finset α} (f : α → A) (h : ∀ x ∈ s, IsIntegral R (f x)) :
    IsIntegral R (∏ x in s, f x) :=
  (integralClosure R A).prod_mem h
#align is_integral.prod IsIntegral.prod
-/

#print IsIntegral.sum /-
theorem IsIntegral.sum {α : Type _} {s : Finset α} (f : α → A) (h : ∀ x ∈ s, IsIntegral R (f x)) :
    IsIntegral R (∑ x in s, f x) :=
  (integralClosure R A).sum_mem h
#align is_integral.sum IsIntegral.sum
-/

#print IsIntegral.det /-
theorem IsIntegral.det {n : Type _} [Fintype n] [DecidableEq n] {M : Matrix n n A}
    (h : ∀ i j, IsIntegral R (M i j)) : IsIntegral R M.det :=
  by
  rw [Matrix.det_apply]
  exact IsIntegral.sum _ fun σ hσ => IsIntegral.zsmul (IsIntegral.prod _ fun i hi => h _ _) _
#align is_integral.det IsIntegral.det
-/

#print IsIntegral.pow_iff /-
@[simp]
theorem IsIntegral.pow_iff {x : A} {n : ℕ} (hn : 0 < n) : IsIntegral R (x ^ n) ↔ IsIntegral R x :=
  ⟨isIntegral_of_pow hn, fun hx => IsIntegral.pow hx n⟩
#align is_integral.pow_iff IsIntegral.pow_iff
-/

open scoped TensorProduct

#print IsIntegral.tmul /-
theorem IsIntegral.tmul (x : A) {y : B} (h : IsIntegral R y) : IsIntegral A (x ⊗ₜ[R] y) :=
  by
  obtain ⟨p, hp, hp'⟩ := h
  refine' ⟨(p.map (algebraMap R A)).scaleRoots x, _, _⟩
  · rw [Polynomial.monic_scaleRoots_iff]; exact hp.map _
  convert
    @Polynomial.scaleRoots_eval₂_mul (A ⊗[R] B) A _ _ _
      algebra.tensor_product.include_left.to_ring_hom (1 ⊗ₜ y) x using
    2
  ·
    simp only [AlgHom.toRingHom_eq_coe, AlgHom.coe_toRingHom, mul_one, one_mul,
      Algebra.TensorProduct.includeLeft_apply, Algebra.TensorProduct.tmul_mul_tmul]
  convert (MulZeroClass.mul_zero _).symm
  rw [Polynomial.eval₂_map, Algebra.TensorProduct.includeLeft_comp_algebraMap, ←
    Polynomial.eval₂_map]
  convert Polynomial.eval₂_at_apply algebra.tensor_product.include_right.to_ring_hom y
  rw [Polynomial.eval_map, hp', _root_.map_zero]
#align is_integral.tmul IsIntegral.tmul
-/

section

variable (p : R[X]) (x : S)

#print normalizeScaleRoots /-
/-- The monic polynomial whose roots are `p.leading_coeff * x` for roots `x` of `p`. -/
noncomputable def normalizeScaleRoots (p : R[X]) : R[X] :=
  ∑ i in p.support,
    monomial i (if i = p.natDegree then 1 else p.coeff i * p.leadingCoeff ^ (p.natDegree - 1 - i))
#align normalize_scale_roots normalizeScaleRoots
-/

#print normalizeScaleRoots_coeff_mul_leadingCoeff_pow /-
theorem normalizeScaleRoots_coeff_mul_leadingCoeff_pow (i : ℕ) (hp : 1 ≤ natDegree p) :
    (normalizeScaleRoots p).coeff i * p.leadingCoeff ^ i =
      p.coeff i * p.leadingCoeff ^ (p.natDegree - 1) :=
  by
  simp only [normalizeScaleRoots, finset_sum_coeff, coeff_monomial, Finset.sum_ite_eq', one_mul,
    MulZeroClass.zero_mul, mem_support_iff, ite_mul, Ne.def, ite_not]
  split_ifs with h₁ h₂
  · simp [h₁]
  · rw [h₂, leading_coeff, ← pow_succ, tsub_add_cancel_of_le hp]
  · rw [mul_assoc, ← pow_add, tsub_add_cancel_of_le]
    apply Nat.le_pred_of_lt
    rw [lt_iff_le_and_ne]
    exact ⟨le_nat_degree_of_ne_zero h₁, h₂⟩
#align normalize_scale_roots_coeff_mul_leading_coeff_pow normalizeScaleRoots_coeff_mul_leadingCoeff_pow
-/

#print leadingCoeff_smul_normalizeScaleRoots /-
theorem leadingCoeff_smul_normalizeScaleRoots (p : R[X]) :
    p.leadingCoeff • normalizeScaleRoots p = scaleRoots p p.leadingCoeff :=
  by
  ext
  simp only [coeff_scale_roots, normalizeScaleRoots, coeff_monomial, coeff_smul, Finset.smul_sum,
    Ne.def, Finset.sum_ite_eq', finset_sum_coeff, smul_ite, smul_zero, mem_support_iff]
  split_ifs with h₁ h₂
  · simp [*]
  · simp [*]
  · rw [Algebra.id.smul_eq_mul, mul_comm, mul_assoc, ← pow_succ', tsub_right_comm,
      tsub_add_cancel_of_le]
    rw [Nat.succ_le_iff]
    exact tsub_pos_of_lt (lt_of_le_of_ne (le_nat_degree_of_ne_zero h₁) h₂)
#align leading_coeff_smul_normalize_scale_roots leadingCoeff_smul_normalizeScaleRoots
-/

#print normalizeScaleRoots_support /-
theorem normalizeScaleRoots_support : (normalizeScaleRoots p).support ≤ p.support :=
  by
  intro x
  contrapose
  simp only [not_mem_support_iff, normalizeScaleRoots, finset_sum_coeff, coeff_monomial,
    Finset.sum_ite_eq', mem_support_iff, Ne.def, Classical.not_not, ite_eq_right_iff]
  intro h₁ h₂
  exact (h₂ h₁).rec _
#align normalize_scale_roots_support normalizeScaleRoots_support
-/

#print normalizeScaleRoots_degree /-
theorem normalizeScaleRoots_degree : (normalizeScaleRoots p).degree = p.degree :=
  by
  apply le_antisymm
  · exact Finset.sup_mono (normalizeScaleRoots_support p)
  · rw [← degree_scale_roots, ← leadingCoeff_smul_normalizeScaleRoots]
    exact degree_smul_le _ _
#align normalize_scale_roots_degree normalizeScaleRoots_degree
-/

#print normalizeScaleRoots_eval₂_leadingCoeff_mul /-
theorem normalizeScaleRoots_eval₂_leadingCoeff_mul (h : 1 ≤ p.natDegree) (f : R →+* S) (x : S) :
    (normalizeScaleRoots p).eval₂ f (f p.leadingCoeff * x) =
      f p.leadingCoeff ^ (p.natDegree - 1) * p.eval₂ f x :=
  by
  rw [eval₂_eq_sum_range, eval₂_eq_sum_range, Finset.mul_sum]
  apply Finset.sum_congr
  · rw [nat_degree_eq_of_degree_eq (normalizeScaleRoots_degree p)]
  intro n hn
  rw [mul_pow, ← mul_assoc, ← f.map_pow, ← f.map_mul,
    normalizeScaleRoots_coeff_mul_leadingCoeff_pow _ _ h, f.map_mul, f.map_pow]
  ring
#align normalize_scale_roots_eval₂_leading_coeff_mul normalizeScaleRoots_eval₂_leadingCoeff_mul
-/

#print normalizeScaleRoots_monic /-
theorem normalizeScaleRoots_monic (h : p ≠ 0) : (normalizeScaleRoots p).Monic :=
  by
  delta monic leading_coeff
  rw [nat_degree_eq_of_degree_eq (normalizeScaleRoots_degree p)]
  suffices p = 0 → (0 : R) = 1 by simpa [normalizeScaleRoots, coeff_monomial]
  exact fun h' => (h h').rec _
#align normalize_scale_roots_monic normalizeScaleRoots_monic
-/

#print RingHom.isIntegralElem_leadingCoeff_mul /-
/-- Given a `p : R[X]` and a `x : S` such that `p.eval₂ f x = 0`,
`f p.leading_coeff * x` is integral. -/
theorem RingHom.isIntegralElem_leadingCoeff_mul (h : p.eval₂ f x = 0) :
    f.IsIntegralElem (f p.leadingCoeff * x) :=
  by
  by_cases h' : 1 ≤ p.nat_degree
  · use normalizeScaleRoots p
    have : p ≠ 0 := fun h'' => by rw [h'', nat_degree_zero] at h' ; exact Nat.not_succ_le_zero 0 h'
    use normalizeScaleRoots_monic p this
    rw [normalizeScaleRoots_eval₂_leadingCoeff_mul p h' f x, h, MulZeroClass.mul_zero]
  · by_cases hp : p.map f = 0
    · apply_fun fun q => coeff q p.nat_degree at hp 
      rw [coeff_map, coeff_zero, coeff_nat_degree] at hp 
      rw [hp, MulZeroClass.zero_mul]
      exact f.is_integral_zero
    · rw [Nat.one_le_iff_ne_zero, Classical.not_not] at h' 
      rw [eq_C_of_nat_degree_eq_zero h', eval₂_C] at h 
      suffices p.map f = 0 by exact (hp this).rec _
      rw [eq_C_of_nat_degree_eq_zero h', map_C, h, C_eq_zero]
#align ring_hom.is_integral_elem_leading_coeff_mul RingHom.isIntegralElem_leadingCoeff_mul
-/

#print isIntegral_leadingCoeff_smul /-
/-- Given a `p : R[X]` and a root `x : S`,
then `p.leading_coeff • x : S` is integral over `R`. -/
theorem isIntegral_leadingCoeff_smul [Algebra R S] (h : aeval x p = 0) :
    IsIntegral R (p.leadingCoeff • x) :=
  by
  rw [aeval_def] at h 
  rw [Algebra.smul_def]
  exact (algebraMap R S).isIntegralElem_leadingCoeff_mul p x h
#align is_integral_leading_coeff_smul isIntegral_leadingCoeff_smul
-/

end

end

section IsIntegralClosure

#print IsIntegralClosure /-
/- ./././Mathport/Syntax/Translate/Command.lean:393:30: infer kinds are unsupported in Lean 4: #[`algebraMap_injective] [] -/
/-- `is_integral_closure A R B` is the characteristic predicate stating `A` is
the integral closure of `R` in `B`,
i.e. that an element of `B` is integral over `R` iff it is an element of (the image of) `A`.
-/
class IsIntegralClosure (A R B : Type _) [CommRing R] [CommSemiring A] [CommRing B] [Algebra R B]
    [Algebra A B] : Prop where
  algebraMap_injective : Function.Injective (algebraMap A B)
  isIntegral_iff : ∀ {x : B}, IsIntegral R x ↔ ∃ y, algebraMap A B y = x
#align is_integral_closure IsIntegralClosure
-/

#print integralClosure.isIntegralClosure /-
instance integralClosure.isIntegralClosure (R A : Type _) [CommRing R] [CommRing A] [Algebra R A] :
    IsIntegralClosure (integralClosure R A) R A :=
  ⟨Subtype.coe_injective, fun x => ⟨fun h => ⟨⟨x, h⟩, rfl⟩, by rintro ⟨⟨_, h⟩, rfl⟩; exact h⟩⟩
#align integral_closure.is_integral_closure integralClosure.isIntegralClosure
-/

namespace IsIntegralClosure

variable {R A B : Type _} [CommRing R] [CommRing A] [CommRing B]

variable [Algebra R B] [Algebra A B] [IsIntegralClosure A R B]

variable (R) {A} (B)

#print IsIntegralClosure.isIntegral /-
protected theorem isIntegral [Algebra R A] [IsScalarTower R A B] (x : A) : IsIntegral R x :=
  (isIntegral_algebraMap_iff (algebraMap_injective A R B)).mp <|
    show IsIntegral R (algebraMap A B x) from isIntegral_iff.mpr ⟨x, rfl⟩
#align is_integral_closure.is_integral IsIntegralClosure.isIntegral
-/

#print IsIntegralClosure.isIntegral_algebra /-
theorem isIntegral_algebra [Algebra R A] [IsScalarTower R A B] : Algebra.IsIntegral R A := fun x =>
  IsIntegralClosure.isIntegral R B x
#align is_integral_closure.is_integral_algebra IsIntegralClosure.isIntegral_algebra
-/

#print IsIntegralClosure.noZeroSMulDivisors /-
theorem noZeroSMulDivisors [Algebra R A] [IsScalarTower R A B] [NoZeroSMulDivisors R B] :
    NoZeroSMulDivisors R A :=
  by
  refine'
    Function.Injective.noZeroSMulDivisors _ (IsIntegralClosure.algebraMap_injective A R B)
      (map_zero _) fun _ _ => _
  simp only [Algebra.algebraMap_eq_smul_one, IsScalarTower.smul_assoc]
#align is_integral_closure.no_zero_smul_divisors IsIntegralClosure.noZeroSMulDivisors
-/

variable {R} (A) {B}

#print IsIntegralClosure.mk' /-
/-- If `x : B` is integral over `R`, then it is an element of the integral closure of `R` in `B`. -/
noncomputable def mk' (x : B) (hx : IsIntegral R x) : A :=
  Classical.choose (isIntegral_iff.mp hx)
#align is_integral_closure.mk' IsIntegralClosure.mk'
-/

#print IsIntegralClosure.algebraMap_mk' /-
@[simp]
theorem algebraMap_mk' (x : B) (hx : IsIntegral R x) : algebraMap A B (mk' A x hx) = x :=
  Classical.choose_spec (isIntegral_iff.mp hx)
#align is_integral_closure.algebra_map_mk' IsIntegralClosure.algebraMap_mk'
-/

#print IsIntegralClosure.mk'_one /-
@[simp]
theorem mk'_one (h : IsIntegral R (1 : B) := isIntegral_one) : mk' A 1 h = 1 :=
  algebraMap_injective A R B <| by rw [algebra_map_mk', RingHom.map_one]
#align is_integral_closure.mk'_one IsIntegralClosure.mk'_one
-/

#print IsIntegralClosure.mk'_zero /-
@[simp]
theorem mk'_zero (h : IsIntegral R (0 : B) := isIntegral_zero) : mk' A 0 h = 0 :=
  algebraMap_injective A R B <| by rw [algebra_map_mk', RingHom.map_zero]
#align is_integral_closure.mk'_zero IsIntegralClosure.mk'_zero
-/

#print IsIntegralClosure.mk'_add /-
@[simp]
theorem mk'_add (x y : B) (hx : IsIntegral R x) (hy : IsIntegral R y) :
    mk' A (x + y) (isIntegral_add hx hy) = mk' A x hx + mk' A y hy :=
  algebraMap_injective A R B <| by simp only [algebra_map_mk', RingHom.map_add]
#align is_integral_closure.mk'_add IsIntegralClosure.mk'_add
-/

#print IsIntegralClosure.mk'_mul /-
@[simp]
theorem mk'_mul (x y : B) (hx : IsIntegral R x) (hy : IsIntegral R y) :
    mk' A (x * y) (isIntegral_mul hx hy) = mk' A x hx * mk' A y hy :=
  algebraMap_injective A R B <| by simp only [algebra_map_mk', RingHom.map_mul]
#align is_integral_closure.mk'_mul IsIntegralClosure.mk'_mul
-/

#print IsIntegralClosure.mk'_algebraMap /-
@[simp]
theorem mk'_algebraMap [Algebra R A] [IsScalarTower R A B] (x : R)
    (h : IsIntegral R (algebraMap R B x) := isIntegral_algebraMap) :
    IsIntegralClosure.mk' A (algebraMap R B x) h = algebraMap R A x :=
  algebraMap_injective A R B <| by rw [algebra_map_mk', ← IsScalarTower.algebraMap_apply]
#align is_integral_closure.mk'_algebra_map IsIntegralClosure.mk'_algebraMap
-/

section lift

variable {R} (A B) {S : Type _} [CommRing S] [Algebra R S] [Algebra S B] [IsScalarTower R S B]

variable [Algebra R A] [IsScalarTower R A B] (h : Algebra.IsIntegral R S)

#print IsIntegralClosure.lift /-
/-- If `B / S / R` is a tower of ring extensions where `S` is integral over `R`,
then `S` maps (uniquely) into an integral closure `B / A / R`. -/
noncomputable def lift : S →ₐ[R] A
    where
  toFun x := mk' A (algebraMap S B x) (IsIntegral.algebraMap (h x))
  map_one' := by simp only [RingHom.map_one, mk'_one]
  map_zero' := by simp only [RingHom.map_zero, mk'_zero]
  map_add' x y := by simp_rw [← mk'_add, RingHom.map_add]
  map_mul' x y := by simp_rw [← mk'_mul, RingHom.map_mul]
  commutes' x := by simp_rw [← IsScalarTower.algebraMap_apply, mk'_algebra_map]
#align is_integral_closure.lift IsIntegralClosure.lift
-/

#print IsIntegralClosure.algebraMap_lift /-
@[simp]
theorem algebraMap_lift (x : S) : algebraMap A B (lift A B h x) = algebraMap S B x :=
  algebraMap_mk' _ _ _
#align is_integral_closure.algebra_map_lift IsIntegralClosure.algebraMap_lift
-/

end lift

section Equiv

variable (R A B) (A' : Type _) [CommRing A'] [Algebra A' B] [IsIntegralClosure A' R B]

variable [Algebra R A] [Algebra R A'] [IsScalarTower R A B] [IsScalarTower R A' B]

#print IsIntegralClosure.equiv /-
/-- Integral closures are all isomorphic to each other. -/
noncomputable def equiv : A ≃ₐ[R] A' :=
  AlgEquiv.ofAlgHom (lift _ B (isIntegral_algebra R B)) (lift _ B (isIntegral_algebra R B))
    (by ext x; apply algebraMap_injective A' R B; simp)
    (by ext x; apply algebraMap_injective A R B; simp)
#align is_integral_closure.equiv IsIntegralClosure.equiv
-/

#print IsIntegralClosure.algebraMap_equiv /-
@[simp]
theorem algebraMap_equiv (x : A) : algebraMap A' B (equiv R A B A' x) = algebraMap A B x :=
  algebraMap_lift _ _ _ _
#align is_integral_closure.algebra_map_equiv IsIntegralClosure.algebraMap_equiv
-/

end Equiv

end IsIntegralClosure

end IsIntegralClosure

section Algebra

open Algebra

variable {R A B S T : Type _}

variable [CommRing R] [CommRing A] [CommRing B] [CommRing S] [CommRing T]

variable [Algebra A B] [Algebra R B] (f : R →+* S) (g : S →+* T)

#print isIntegral_trans_aux /-
theorem isIntegral_trans_aux (x : B) {p : A[X]} (pmonic : Monic p) (hp : aeval x p = 0) :
    IsIntegral (adjoin R (↑(p.map <| algebraMap A B).frange : Set B)) x :=
  by
  generalize hS : (↑(p.map <| algebraMap A B).frange : Set B) = S
  have coeffs_mem : ∀ i, (p.map <| algebraMap A B).coeff i ∈ adjoin R S :=
    by
    intro i; by_cases hi : (p.map <| algebraMap A B).coeff i = 0
    · rw [hi]; exact Subalgebra.zero_mem _
    rw [← hS]
    exact subset_adjoin (coeff_mem_frange _ _ hi)
  obtain ⟨q, hq⟩ :
    ∃ q : (adjoin R S)[X], q.map (algebraMap (adjoin R S) B) = (p.map <| algebraMap A B) := by
    rw [← Set.mem_range]; exact (Polynomial.mem_map_range _).2 fun i => ⟨⟨_, coeffs_mem i⟩, rfl⟩
  use q
  constructor
  · suffices h : (q.map (algebraMap (adjoin R S) B)).Monic
    · refine' monic_of_injective _ h
      exact Subtype.val_injective
    · rw [hq]; exact pmonic.map _
  · convert hp using 1
    replace hq := congr_arg (eval x) hq
    convert hq using 1 <;> symm <;> apply eval_map
#align is_integral_trans_aux isIntegral_trans_aux
-/

variable [Algebra R A] [IsScalarTower R A B]

#print isIntegral_trans /-
/-- If A is an R-algebra all of whose elements are integral over R,
and x is an element of an A-algebra that is integral over A, then x is integral over R.-/
theorem isIntegral_trans (A_int : Algebra.IsIntegral R A) (x : B) (hx : IsIntegral A x) :
    IsIntegral R x := by
  rcases hx with ⟨p, pmonic, hp⟩
  let S : Set B := ↑(p.map <| algebraMap A B).frange
  refine' isIntegral_of_mem_of_FG (adjoin R (S ∪ {x})) _ _ (subset_adjoin <| Or.inr rfl)
  refine' fg_trans (FG_adjoin_of_finite (Finset.finite_toSet _) fun x hx => _) _
  · rw [Finset.mem_coe, frange, Finset.mem_image] at hx 
    rcases hx with ⟨i, _, rfl⟩
    rw [coeff_map]
    exact map_isIntegral (IsScalarTower.toAlgHom R A B) (A_int _)
  · apply FG_adjoin_singleton_of_integral
    exact isIntegral_trans_aux _ pmonic hp
#align is_integral_trans isIntegral_trans
-/

#print Algebra.isIntegral_trans /-
/-- If A is an R-algebra all of whose elements are integral over R,
and B is an A-algebra all of whose elements are integral over A,
then all elements of B are integral over R.-/
theorem Algebra.isIntegral_trans (hA : Algebra.IsIntegral R A) (hB : Algebra.IsIntegral A B) :
    Algebra.IsIntegral R B := fun x => isIntegral_trans hA x (hB x)
#align algebra.is_integral_trans Algebra.isIntegral_trans
-/

#print RingHom.isIntegral_trans /-
theorem RingHom.isIntegral_trans (hf : f.IsIntegral) (hg : g.IsIntegral) : (g.comp f).IsIntegral :=
  @Algebra.isIntegral_trans R S T _ _ _ g.toAlgebra (g.comp f).toAlgebra f.toAlgebra
    (@IsScalarTower.of_algebraMap_eq R S T _ _ _ f.toAlgebra g.toAlgebra (g.comp f).toAlgebra
      (RingHom.comp_apply g f))
    hf hg
#align ring_hom.is_integral_trans RingHom.isIntegral_trans
-/

#print RingHom.isIntegral_of_surjective /-
theorem RingHom.isIntegral_of_surjective (hf : Function.Surjective f) : f.IsIntegral := fun x =>
  (hf x).recOn fun y hy => (hy ▸ f.is_integral_map : f.IsIntegralElem x)
#align ring_hom.is_integral_of_surjective RingHom.isIntegral_of_surjective
-/

#print isIntegral_of_surjective /-
theorem isIntegral_of_surjective (h : Function.Surjective (algebraMap R A)) :
    Algebra.IsIntegral R A :=
  (algebraMap R A).isIntegral_of_surjective h
#align is_integral_of_surjective isIntegral_of_surjective
-/

#print isIntegral_tower_bot_of_isIntegral /-
/-- If `R → A → B` is an algebra tower with `A → B` injective,
then if the entire tower is an integral extension so is `R → A` -/
theorem isIntegral_tower_bot_of_isIntegral (H : Function.Injective (algebraMap A B)) {x : A}
    (h : IsIntegral R (algebraMap A B x)) : IsIntegral R x :=
  by
  rcases h with ⟨p, ⟨hp, hp'⟩⟩
  refine' ⟨p, ⟨hp, _⟩⟩
  rw [IsScalarTower.algebraMap_eq R A B, ← eval₂_map, eval₂_hom, ←
    RingHom.map_zero (algebraMap A B)] at hp' 
  rw [eval₂_eq_eval_map]
  exact H hp'
#align is_integral_tower_bot_of_is_integral isIntegral_tower_bot_of_isIntegral
-/

#print RingHom.isIntegral_tower_bot_of_isIntegral /-
theorem RingHom.isIntegral_tower_bot_of_isIntegral (hg : Function.Injective g)
    (hfg : (g.comp f).IsIntegral) : f.IsIntegral := fun x =>
  @isIntegral_tower_bot_of_isIntegral R S T _ _ _ g.toAlgebra (g.comp f).toAlgebra f.toAlgebra
    (@IsScalarTower.of_algebraMap_eq R S T _ _ _ f.toAlgebra g.toAlgebra (g.comp f).toAlgebra
      (RingHom.comp_apply g f))
    hg x (hfg (g x))
#align ring_hom.is_integral_tower_bot_of_is_integral RingHom.isIntegral_tower_bot_of_isIntegral
-/

#print isIntegral_tower_bot_of_isIntegral_field /-
theorem isIntegral_tower_bot_of_isIntegral_field {R A B : Type _} [CommRing R] [Field A]
    [CommRing B] [Nontrivial B] [Algebra R A] [Algebra A B] [Algebra R B] [IsScalarTower R A B]
    {x : A} (h : IsIntegral R (algebraMap A B x)) : IsIntegral R x :=
  isIntegral_tower_bot_of_isIntegral (algebraMap A B).Injective h
#align is_integral_tower_bot_of_is_integral_field isIntegral_tower_bot_of_isIntegral_field
-/

#print RingHom.isIntegralElem_of_isIntegralElem_comp /-
theorem RingHom.isIntegralElem_of_isIntegralElem_comp {x : T} (h : (g.comp f).IsIntegralElem x) :
    g.IsIntegralElem x :=
  let ⟨p, ⟨hp, hp'⟩⟩ := h
  ⟨p.map f, hp.map f, by rwa [← eval₂_map] at hp' ⟩
#align ring_hom.is_integral_elem_of_is_integral_elem_comp RingHom.isIntegralElem_of_isIntegralElem_comp
-/

#print RingHom.isIntegral_tower_top_of_isIntegral /-
theorem RingHom.isIntegral_tower_top_of_isIntegral (h : (g.comp f).IsIntegral) : g.IsIntegral :=
  fun x => RingHom.isIntegralElem_of_isIntegralElem_comp f g (h x)
#align ring_hom.is_integral_tower_top_of_is_integral RingHom.isIntegral_tower_top_of_isIntegral
-/

#print isIntegral_tower_top_of_isIntegral /-
/-- If `R → A → B` is an algebra tower,
then if the entire tower is an integral extension so is `A → B`. -/
theorem isIntegral_tower_top_of_isIntegral {x : B} (h : IsIntegral R x) : IsIntegral A x :=
  by
  rcases h with ⟨p, ⟨hp, hp'⟩⟩
  refine' ⟨p.map (algebraMap R A), ⟨hp.map (algebraMap R A), _⟩⟩
  rw [IsScalarTower.algebraMap_eq R A B, ← eval₂_map] at hp' 
  exact hp'
#align is_integral_tower_top_of_is_integral isIntegral_tower_top_of_isIntegral
-/

#print RingHom.isIntegral_quotient_of_isIntegral /-
theorem RingHom.isIntegral_quotient_of_isIntegral {I : Ideal S} (hf : f.IsIntegral) :
    (Ideal.quotientMap I f le_rfl).IsIntegral :=
  by
  rintro ⟨x⟩
  obtain ⟨p, ⟨p_monic, hpx⟩⟩ := hf x
  refine' ⟨p.map (Ideal.Quotient.mk _), ⟨p_monic.map _, _⟩⟩
  simpa only [hom_eval₂, eval₂_map] using congr_arg (Ideal.Quotient.mk I) hpx
#align ring_hom.is_integral_quotient_of_is_integral RingHom.isIntegral_quotient_of_isIntegral
-/

#print isIntegral_quotient_of_isIntegral /-
theorem isIntegral_quotient_of_isIntegral {I : Ideal A} (hRA : Algebra.IsIntegral R A) :
    Algebra.IsIntegral (R ⧸ I.comap (algebraMap R A)) (A ⧸ I) :=
  (algebraMap R A).isIntegral_quotient_of_isIntegral hRA
#align is_integral_quotient_of_is_integral isIntegral_quotient_of_isIntegral
-/

#print isIntegral_quotientMap_iff /-
theorem isIntegral_quotientMap_iff {I : Ideal S} :
    (Ideal.quotientMap I f le_rfl).IsIntegral ↔
      ((Ideal.Quotient.mk I).comp f : R →+* S ⧸ I).IsIntegral :=
  by
  let g := Ideal.Quotient.mk (I.comap f)
  have := Ideal.quotientMap_comp_mk le_rfl
  refine' ⟨fun h => _, fun h => RingHom.isIntegral_tower_top_of_isIntegral g _ (this ▸ h)⟩
  refine' this ▸ RingHom.isIntegral_trans g (Ideal.quotientMap I f le_rfl) _ h
  exact RingHom.isIntegral_of_surjective g Ideal.Quotient.mk_surjective
#align is_integral_quotient_map_iff isIntegral_quotientMap_iff
-/

#print isField_of_isIntegral_of_isField /-
/-- If the integral extension `R → S` is injective, and `S` is a field, then `R` is also a field. -/
theorem isField_of_isIntegral_of_isField {R S : Type _} [CommRing R] [Nontrivial R] [CommRing S]
    [IsDomain S] [Algebra R S] (H : Algebra.IsIntegral R S)
    (hRS : Function.Injective (algebraMap R S)) (hS : IsField S) : IsField R :=
  by
  refine' ⟨⟨0, 1, zero_ne_one⟩, mul_comm, fun a ha => _⟩
  -- Let `a_inv` be the inverse of `algebra_map R S a`,
  -- then we need to show that `a_inv` is of the form `algebra_map R S b`.
  obtain ⟨a_inv, ha_inv⟩ := hS.mul_inv_cancel fun h => ha (hRS (trans h (RingHom.map_zero _).symm))
  -- Let `p : R[X]` be monic with root `a_inv`,
  -- and `q` be `p` with coefficients reversed (so `q(a) = q'(a) * a + 1`).
  -- We claim that `q(a) = 0`, so `-q'(a)` is the inverse of `a`.
  obtain ⟨p, p_monic, hp⟩ := H a_inv
  use -∑ i : ℕ in Finset.range p.nat_degree, p.coeff i * a ^ (p.nat_degree - i - 1)
  -- `q(a) = 0`, because multiplying everything with `a_inv^n` gives `p(a_inv) = 0`.
  -- TODO: this could be a lemma for `polynomial.reverse`.
  have hq : ∑ i : ℕ in Finset.range (p.nat_degree + 1), p.coeff i * a ^ (p.nat_degree - i) = 0 :=
    by
    apply (injective_iff_map_eq_zero (algebraMap R S)).mp hRS
    have a_inv_ne_zero : a_inv ≠ 0 := right_ne_zero_of_mul (mt ha_inv.symm.trans one_ne_zero)
    refine' (mul_eq_zero.mp _).resolve_right (pow_ne_zero p.nat_degree a_inv_ne_zero)
    rw [eval₂_eq_sum_range] at hp 
    rw [RingHom.map_sum, Finset.sum_mul]
    refine' (Finset.sum_congr rfl fun i hi => _).trans hp
    rw [RingHom.map_mul, mul_assoc]
    congr
    have : a_inv ^ p.nat_degree = a_inv ^ (p.nat_degree - i) * a_inv ^ i := by
      rw [← pow_add a_inv, tsub_add_cancel_of_le (Nat.le_of_lt_succ (finset.mem_range.mp hi))]
    rw [RingHom.map_pow, this, ← mul_assoc, ← mul_pow, ha_inv, one_pow, one_mul]
  -- Since `q(a) = 0` and `q(a) = q'(a) * a + 1`, we have `a * -q'(a) = 1`.
  -- TODO: we could use a lemma for `polynomial.div_X` here.
  rw [Finset.sum_range_succ_comm, p_monic.coeff_nat_degree, one_mul, tsub_self, pow_zero,
    add_eq_zero_iff_eq_neg, eq_comm] at hq 
  rw [mul_comm, neg_mul, Finset.sum_mul]
  convert hq using 2
  refine' Finset.sum_congr rfl fun i hi => _
  have : 1 ≤ p.nat_degree - i := le_tsub_of_add_le_left (finset.mem_range.mp hi)
  rw [mul_assoc, ← pow_succ', tsub_add_cancel_of_le this]
#align is_field_of_is_integral_of_is_field isField_of_isIntegral_of_isField
-/

#print isField_of_isIntegral_of_isField' /-
theorem isField_of_isIntegral_of_isField' {R S : Type _} [CommRing R] [CommRing S] [IsDomain S]
    [Algebra R S] (H : Algebra.IsIntegral R S) (hR : IsField R) : IsField S :=
  by
  letI := hR.to_field
  refine' ⟨⟨0, 1, zero_ne_one⟩, mul_comm, fun x hx => _⟩
  let A := Algebra.adjoin R ({x} : Set S)
  haveI : IsNoetherian R A :=
    isNoetherian_of_fg_of_noetherian A.to_submodule (FG_adjoin_singleton_of_integral x (H x))
  haveI : Module.Finite R A := Module.IsNoetherian.finite R A
  obtain ⟨y, hy⟩ :=
    LinearMap.surjective_of_injective
      (@LinearMap.mulLeft_injective R A _ _ _ _ ⟨x, subset_adjoin (Set.mem_singleton x)⟩ fun h =>
        hx (subtype.ext_iff.mp h))
      1
  exact ⟨y, subtype.ext_iff.mp hy⟩
#align is_field_of_is_integral_of_is_field' isField_of_isIntegral_of_isField'
-/

#print Algebra.IsIntegral.isField_iff_isField /-
theorem Algebra.IsIntegral.isField_iff_isField {R S : Type _} [CommRing R] [Nontrivial R]
    [CommRing S] [IsDomain S] [Algebra R S] (H : Algebra.IsIntegral R S)
    (hRS : Function.Injective (algebraMap R S)) : IsField R ↔ IsField S :=
  ⟨isField_of_isIntegral_of_isField' H, isField_of_isIntegral_of_isField H hRS⟩
#align algebra.is_integral.is_field_iff_is_field Algebra.IsIntegral.isField_iff_isField
-/

end Algebra

#print integralClosure_idem /-
theorem integralClosure_idem {R : Type _} {A : Type _} [CommRing R] [CommRing A] [Algebra R A] :
    integralClosure (integralClosure R A : Set A) A = ⊥ :=
  eq_bot_iff.2 fun x hx =>
    Algebra.mem_bot.2
      ⟨⟨x,
          @isIntegral_trans _ _ _ _ _ _ _ _ (integralClosure R A).Algebra _
            integralClosure.isIntegral x hx⟩,
        rfl⟩
#align integral_closure_idem integralClosure_idem
-/

section IsDomain

variable {R S : Type _} [CommRing R] [CommRing S] [IsDomain S] [Algebra R S]

instance : IsDomain (integralClosure R S) :=
  inferInstance

#print roots_mem_integralClosure /-
theorem roots_mem_integralClosure {f : R[X]} (hf : f.Monic) {a : S}
    (ha : a ∈ (f.map <| algebraMap R S).roots) : a ∈ integralClosure R S :=
  ⟨f, hf, (eval₂_eq_eval_map _).trans <| (mem_roots <| (hf.map _).NeZero).1 ha⟩
#align roots_mem_integral_closure roots_mem_integralClosure
-/

end IsDomain

