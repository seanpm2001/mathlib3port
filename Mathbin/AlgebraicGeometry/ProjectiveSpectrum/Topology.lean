/-
Copyright (c) 2020 Jujian Zhang. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jujian Zhang, Johan Commelin

! This file was ported from Lean 3 source module algebraic_geometry.projective_spectrum.topology
! leanprover-community/mathlib commit 4280f5f32e16755ec7985ce11e189b6cd6ff6735
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.GradedAlgebra.HomogeneousIdeal
import Mathbin.Topology.Category.Top.Basic
import Mathbin.Topology.Sets.Opens

/-!
# Projective spectrum of a graded ring

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The projective spectrum of a graded commutative ring is the subtype of all homogenous ideals that
are prime and do not contain the irrelevant ideal.
It is naturally endowed with a topology: the Zariski topology.

## Notation
- `R` is a commutative semiring;
- `A` is a commutative ring and an `R`-algebra;
- `𝒜 : ℕ → submodule R A` is the grading of `A`;

## Main definitions

* `projective_spectrum 𝒜`: The projective spectrum of a graded ring `A`, or equivalently, the set of
  all homogeneous ideals of `A` that is both prime and relevant i.e. not containing irrelevant
  ideal. Henceforth, we call elements of projective spectrum *relevant homogeneous prime ideals*.
* `projective_spectrum.zero_locus 𝒜 s`: The zero locus of a subset `s` of `A`
  is the subset of `projective_spectrum 𝒜` consisting of all relevant homogeneous prime ideals that
  contain `s`.
* `projective_spectrum.vanishing_ideal t`: The vanishing ideal of a subset `t` of
  `projective_spectrum 𝒜` is the intersection of points in `t` (viewed as relevant homogeneous prime
  ideals).
* `projective_spectrum.Top`: the topological space of `projective_spectrum 𝒜` endowed with the
  Zariski topology.
-/


noncomputable section

open scoped DirectSum BigOperators Pointwise

open DirectSum SetLike TopCat TopologicalSpace CategoryTheory Opposite

variable {R A : Type _}

variable [CommSemiring R] [CommRing A] [Algebra R A]

variable (𝒜 : ℕ → Submodule R A) [GradedAlgebra 𝒜]

#print ProjectiveSpectrum /-
/-- The projective spectrum of a graded commutative ring is the subtype of all homogenous ideals
that are prime and do not contain the irrelevant ideal. -/
@[ext, nolint has_nonempty_instance]
structure ProjectiveSpectrum where
  asHomogeneousIdeal : HomogeneousIdeal 𝒜
  IsPrime : as_homogeneous_ideal.toIdeal.IsPrime
  not_irrelevant_le : ¬HomogeneousIdeal.irrelevant 𝒜 ≤ as_homogeneous_ideal
#align projective_spectrum ProjectiveSpectrum
-/

attribute [instance] ProjectiveSpectrum.isPrime

namespace ProjectiveSpectrum

#print ProjectiveSpectrum.zeroLocus /-
/-- The zero locus of a set `s` of elements of a commutative ring `A` is the set of all relevant
homogeneous prime ideals of the ring that contain the set `s`.

An element `f` of `A` can be thought of as a dependent function on the projective spectrum of `𝒜`.
At a point `x` (a homogeneous prime ideal) the function (i.e., element) `f` takes values in the
quotient ring `A` modulo the prime ideal `x`. In this manner, `zero_locus s` is exactly the subset
of `projective_spectrum 𝒜` where all "functions" in `s` vanish simultaneously. -/
def zeroLocus (s : Set A) : Set (ProjectiveSpectrum 𝒜) :=
  {x | s ⊆ x.asHomogeneousIdeal}
#align projective_spectrum.zero_locus ProjectiveSpectrum.zeroLocus
-/

#print ProjectiveSpectrum.mem_zeroLocus /-
@[simp]
theorem mem_zeroLocus (x : ProjectiveSpectrum 𝒜) (s : Set A) :
    x ∈ zeroLocus 𝒜 s ↔ s ⊆ x.asHomogeneousIdeal :=
  Iff.rfl
#align projective_spectrum.mem_zero_locus ProjectiveSpectrum.mem_zeroLocus
-/

#print ProjectiveSpectrum.zeroLocus_span /-
@[simp]
theorem zeroLocus_span (s : Set A) : zeroLocus 𝒜 (Ideal.span s) = zeroLocus 𝒜 s := by ext x;
  exact (Submodule.gi _ _).gc s x.as_homogeneous_ideal.to_ideal
#align projective_spectrum.zero_locus_span ProjectiveSpectrum.zeroLocus_span
-/

variable {𝒜}

#print ProjectiveSpectrum.vanishingIdeal /-
/-- The vanishing ideal of a set `t` of points of the projective spectrum of a commutative ring `R`
is the intersection of all the relevant homogeneous prime ideals in the set `t`.

An element `f` of `A` can be thought of as a dependent function on the projective spectrum of `𝒜`.
At a point `x` (a homogeneous prime ideal) the function (i.e., element) `f` takes values in the
quotient ring `A` modulo the prime ideal `x`. In this manner, `vanishing_ideal t` is exactly the
ideal of `A` consisting of all "functions" that vanish on all of `t`. -/
def vanishingIdeal (t : Set (ProjectiveSpectrum 𝒜)) : HomogeneousIdeal 𝒜 :=
  ⨅ (x : ProjectiveSpectrum 𝒜) (h : x ∈ t), x.asHomogeneousIdeal
#align projective_spectrum.vanishing_ideal ProjectiveSpectrum.vanishingIdeal
-/

#print ProjectiveSpectrum.coe_vanishingIdeal /-
theorem coe_vanishingIdeal (t : Set (ProjectiveSpectrum 𝒜)) :
    (vanishingIdeal t : Set A) =
      {f | ∀ x : ProjectiveSpectrum 𝒜, x ∈ t → f ∈ x.asHomogeneousIdeal} :=
  by
  ext f
  rw [vanishing_ideal, SetLike.mem_coe, ← HomogeneousIdeal.mem_iff, HomogeneousIdeal.toIdeal_iInf,
    Submodule.mem_iInf]
  apply forall_congr' fun x => _
  rw [HomogeneousIdeal.toIdeal_iInf, Submodule.mem_iInf, HomogeneousIdeal.mem_iff]
#align projective_spectrum.coe_vanishing_ideal ProjectiveSpectrum.coe_vanishingIdeal
-/

#print ProjectiveSpectrum.mem_vanishingIdeal /-
theorem mem_vanishingIdeal (t : Set (ProjectiveSpectrum 𝒜)) (f : A) :
    f ∈ vanishingIdeal t ↔ ∀ x : ProjectiveSpectrum 𝒜, x ∈ t → f ∈ x.asHomogeneousIdeal := by
  rw [← SetLike.mem_coe, coe_vanishing_ideal, Set.mem_setOf_eq]
#align projective_spectrum.mem_vanishing_ideal ProjectiveSpectrum.mem_vanishingIdeal
-/

#print ProjectiveSpectrum.vanishingIdeal_singleton /-
@[simp]
theorem vanishingIdeal_singleton (x : ProjectiveSpectrum 𝒜) :
    vanishingIdeal ({x} : Set (ProjectiveSpectrum 𝒜)) = x.asHomogeneousIdeal := by
  simp [vanishing_ideal]
#align projective_spectrum.vanishing_ideal_singleton ProjectiveSpectrum.vanishingIdeal_singleton
-/

#print ProjectiveSpectrum.subset_zeroLocus_iff_le_vanishingIdeal /-
theorem subset_zeroLocus_iff_le_vanishingIdeal (t : Set (ProjectiveSpectrum 𝒜)) (I : Ideal A) :
    t ⊆ zeroLocus 𝒜 I ↔ I ≤ (vanishingIdeal t).toIdeal :=
  ⟨fun h f k => (mem_vanishingIdeal _ _).mpr fun x j => (mem_zeroLocus _ _ _).mpr (h j) k, fun h =>
    fun x j =>
    (mem_zeroLocus _ _ _).mpr (le_trans h fun f h => ((mem_vanishingIdeal _ _).mp h) x j)⟩
#align projective_spectrum.subset_zero_locus_iff_le_vanishing_ideal ProjectiveSpectrum.subset_zeroLocus_iff_le_vanishingIdeal
-/

variable (𝒜)

#print ProjectiveSpectrum.gc_ideal /-
/-- `zero_locus` and `vanishing_ideal` form a galois connection. -/
theorem gc_ideal :
    @GaloisConnection (Ideal A) (Set (ProjectiveSpectrum 𝒜))ᵒᵈ _ _ (fun I => zeroLocus 𝒜 I) fun t =>
      (vanishingIdeal t).toIdeal :=
  fun I t => subset_zeroLocus_iff_le_vanishingIdeal t I
#align projective_spectrum.gc_ideal ProjectiveSpectrum.gc_ideal
-/

#print ProjectiveSpectrum.gc_set /-
/-- `zero_locus` and `vanishing_ideal` form a galois connection. -/
theorem gc_set :
    @GaloisConnection (Set A) (Set (ProjectiveSpectrum 𝒜))ᵒᵈ _ _ (fun s => zeroLocus 𝒜 s) fun t =>
      vanishingIdeal t :=
  by
  have ideal_gc : GaloisConnection Ideal.span coe := (Submodule.gi A _).gc
  simpa [zero_locus_span, Function.comp] using GaloisConnection.compose ideal_gc (gc_ideal 𝒜)
#align projective_spectrum.gc_set ProjectiveSpectrum.gc_set
-/

#print ProjectiveSpectrum.gc_homogeneousIdeal /-
theorem gc_homogeneousIdeal :
    @GaloisConnection (HomogeneousIdeal 𝒜) (Set (ProjectiveSpectrum 𝒜))ᵒᵈ _ _
      (fun I => zeroLocus 𝒜 I) fun t => vanishingIdeal t :=
  fun I t => by
  simpa [show I.to_ideal ≤ (vanishing_ideal t).toIdeal ↔ I ≤ vanishing_ideal t from Iff.rfl] using
    subset_zero_locus_iff_le_vanishing_ideal t I.to_ideal
#align projective_spectrum.gc_homogeneous_ideal ProjectiveSpectrum.gc_homogeneousIdeal
-/

#print ProjectiveSpectrum.subset_zeroLocus_iff_subset_vanishingIdeal /-
theorem subset_zeroLocus_iff_subset_vanishingIdeal (t : Set (ProjectiveSpectrum 𝒜)) (s : Set A) :
    t ⊆ zeroLocus 𝒜 s ↔ s ⊆ vanishingIdeal t :=
  (gc_set _) s t
#align projective_spectrum.subset_zero_locus_iff_subset_vanishing_ideal ProjectiveSpectrum.subset_zeroLocus_iff_subset_vanishingIdeal
-/

#print ProjectiveSpectrum.subset_vanishingIdeal_zeroLocus /-
theorem subset_vanishingIdeal_zeroLocus (s : Set A) : s ⊆ vanishingIdeal (zeroLocus 𝒜 s) :=
  (gc_set _).le_u_l s
#align projective_spectrum.subset_vanishing_ideal_zero_locus ProjectiveSpectrum.subset_vanishingIdeal_zeroLocus
-/

#print ProjectiveSpectrum.ideal_le_vanishingIdeal_zeroLocus /-
theorem ideal_le_vanishingIdeal_zeroLocus (I : Ideal A) :
    I ≤ (vanishingIdeal (zeroLocus 𝒜 I)).toIdeal :=
  (gc_ideal _).le_u_l I
#align projective_spectrum.ideal_le_vanishing_ideal_zero_locus ProjectiveSpectrum.ideal_le_vanishingIdeal_zeroLocus
-/

#print ProjectiveSpectrum.homogeneousIdeal_le_vanishingIdeal_zeroLocus /-
theorem homogeneousIdeal_le_vanishingIdeal_zeroLocus (I : HomogeneousIdeal 𝒜) :
    I ≤ vanishingIdeal (zeroLocus 𝒜 I) :=
  (gc_homogeneousIdeal _).le_u_l I
#align projective_spectrum.homogeneous_ideal_le_vanishing_ideal_zero_locus ProjectiveSpectrum.homogeneousIdeal_le_vanishingIdeal_zeroLocus
-/

#print ProjectiveSpectrum.subset_zeroLocus_vanishingIdeal /-
theorem subset_zeroLocus_vanishingIdeal (t : Set (ProjectiveSpectrum 𝒜)) :
    t ⊆ zeroLocus 𝒜 (vanishingIdeal t) :=
  (gc_ideal _).l_u_le t
#align projective_spectrum.subset_zero_locus_vanishing_ideal ProjectiveSpectrum.subset_zeroLocus_vanishingIdeal
-/

#print ProjectiveSpectrum.zeroLocus_anti_mono /-
theorem zeroLocus_anti_mono {s t : Set A} (h : s ⊆ t) : zeroLocus 𝒜 t ⊆ zeroLocus 𝒜 s :=
  (gc_set _).monotone_l h
#align projective_spectrum.zero_locus_anti_mono ProjectiveSpectrum.zeroLocus_anti_mono
-/

#print ProjectiveSpectrum.zeroLocus_anti_mono_ideal /-
theorem zeroLocus_anti_mono_ideal {s t : Ideal A} (h : s ≤ t) :
    zeroLocus 𝒜 (t : Set A) ⊆ zeroLocus 𝒜 (s : Set A) :=
  (gc_ideal _).monotone_l h
#align projective_spectrum.zero_locus_anti_mono_ideal ProjectiveSpectrum.zeroLocus_anti_mono_ideal
-/

#print ProjectiveSpectrum.zeroLocus_anti_mono_homogeneousIdeal /-
theorem zeroLocus_anti_mono_homogeneousIdeal {s t : HomogeneousIdeal 𝒜} (h : s ≤ t) :
    zeroLocus 𝒜 (t : Set A) ⊆ zeroLocus 𝒜 (s : Set A) :=
  (gc_homogeneousIdeal _).monotone_l h
#align projective_spectrum.zero_locus_anti_mono_homogeneous_ideal ProjectiveSpectrum.zeroLocus_anti_mono_homogeneousIdeal
-/

#print ProjectiveSpectrum.vanishingIdeal_anti_mono /-
theorem vanishingIdeal_anti_mono {s t : Set (ProjectiveSpectrum 𝒜)} (h : s ⊆ t) :
    vanishingIdeal t ≤ vanishingIdeal s :=
  (gc_ideal _).monotone_u h
#align projective_spectrum.vanishing_ideal_anti_mono ProjectiveSpectrum.vanishingIdeal_anti_mono
-/

#print ProjectiveSpectrum.zeroLocus_bot /-
theorem zeroLocus_bot : zeroLocus 𝒜 ((⊥ : Ideal A) : Set A) = Set.univ :=
  (gc_ideal 𝒜).l_bot
#align projective_spectrum.zero_locus_bot ProjectiveSpectrum.zeroLocus_bot
-/

#print ProjectiveSpectrum.zeroLocus_singleton_zero /-
@[simp]
theorem zeroLocus_singleton_zero : zeroLocus 𝒜 ({0} : Set A) = Set.univ :=
  zeroLocus_bot _
#align projective_spectrum.zero_locus_singleton_zero ProjectiveSpectrum.zeroLocus_singleton_zero
-/

#print ProjectiveSpectrum.zeroLocus_empty /-
@[simp]
theorem zeroLocus_empty : zeroLocus 𝒜 (∅ : Set A) = Set.univ :=
  (gc_set 𝒜).l_bot
#align projective_spectrum.zero_locus_empty ProjectiveSpectrum.zeroLocus_empty
-/

#print ProjectiveSpectrum.vanishingIdeal_univ /-
@[simp]
theorem vanishingIdeal_univ : vanishingIdeal (∅ : Set (ProjectiveSpectrum 𝒜)) = ⊤ := by
  simpa using (gc_ideal _).u_top
#align projective_spectrum.vanishing_ideal_univ ProjectiveSpectrum.vanishingIdeal_univ
-/

#print ProjectiveSpectrum.zeroLocus_empty_of_one_mem /-
theorem zeroLocus_empty_of_one_mem {s : Set A} (h : (1 : A) ∈ s) : zeroLocus 𝒜 s = ∅ :=
  Set.eq_empty_iff_forall_not_mem.mpr fun x hx =>
    (inferInstance : x.asHomogeneousIdeal.toIdeal.IsPrime).ne_top <|
      x.asHomogeneousIdeal.toIdeal.eq_top_iff_one.mpr <| hx h
#align projective_spectrum.zero_locus_empty_of_one_mem ProjectiveSpectrum.zeroLocus_empty_of_one_mem
-/

#print ProjectiveSpectrum.zeroLocus_singleton_one /-
@[simp]
theorem zeroLocus_singleton_one : zeroLocus 𝒜 ({1} : Set A) = ∅ :=
  zeroLocus_empty_of_one_mem 𝒜 (Set.mem_singleton (1 : A))
#align projective_spectrum.zero_locus_singleton_one ProjectiveSpectrum.zeroLocus_singleton_one
-/

#print ProjectiveSpectrum.zeroLocus_univ /-
@[simp]
theorem zeroLocus_univ : zeroLocus 𝒜 (Set.univ : Set A) = ∅ :=
  zeroLocus_empty_of_one_mem _ (Set.mem_univ 1)
#align projective_spectrum.zero_locus_univ ProjectiveSpectrum.zeroLocus_univ
-/

#print ProjectiveSpectrum.zeroLocus_sup_ideal /-
theorem zeroLocus_sup_ideal (I J : Ideal A) :
    zeroLocus 𝒜 ((I ⊔ J : Ideal A) : Set A) = zeroLocus _ I ∩ zeroLocus _ J :=
  (gc_ideal 𝒜).l_sup
#align projective_spectrum.zero_locus_sup_ideal ProjectiveSpectrum.zeroLocus_sup_ideal
-/

#print ProjectiveSpectrum.zeroLocus_sup_homogeneousIdeal /-
theorem zeroLocus_sup_homogeneousIdeal (I J : HomogeneousIdeal 𝒜) :
    zeroLocus 𝒜 ((I ⊔ J : HomogeneousIdeal 𝒜) : Set A) = zeroLocus _ I ∩ zeroLocus _ J :=
  (gc_homogeneousIdeal 𝒜).l_sup
#align projective_spectrum.zero_locus_sup_homogeneous_ideal ProjectiveSpectrum.zeroLocus_sup_homogeneousIdeal
-/

#print ProjectiveSpectrum.zeroLocus_union /-
theorem zeroLocus_union (s s' : Set A) : zeroLocus 𝒜 (s ∪ s') = zeroLocus _ s ∩ zeroLocus _ s' :=
  (gc_set 𝒜).l_sup
#align projective_spectrum.zero_locus_union ProjectiveSpectrum.zeroLocus_union
-/

#print ProjectiveSpectrum.vanishingIdeal_union /-
theorem vanishingIdeal_union (t t' : Set (ProjectiveSpectrum 𝒜)) :
    vanishingIdeal (t ∪ t') = vanishingIdeal t ⊓ vanishingIdeal t' := by
  ext1 <;> convert (gc_ideal 𝒜).u_inf
#align projective_spectrum.vanishing_ideal_union ProjectiveSpectrum.vanishingIdeal_union
-/

#print ProjectiveSpectrum.zeroLocus_iSup_ideal /-
theorem zeroLocus_iSup_ideal {γ : Sort _} (I : γ → Ideal A) :
    zeroLocus _ ((⨆ i, I i : Ideal A) : Set A) = ⋂ i, zeroLocus 𝒜 (I i) :=
  (gc_ideal 𝒜).l_iSup
#align projective_spectrum.zero_locus_supr_ideal ProjectiveSpectrum.zeroLocus_iSup_ideal
-/

#print ProjectiveSpectrum.zeroLocus_iSup_homogeneousIdeal /-
theorem zeroLocus_iSup_homogeneousIdeal {γ : Sort _} (I : γ → HomogeneousIdeal 𝒜) :
    zeroLocus _ ((⨆ i, I i : HomogeneousIdeal 𝒜) : Set A) = ⋂ i, zeroLocus 𝒜 (I i) :=
  (gc_homogeneousIdeal 𝒜).l_iSup
#align projective_spectrum.zero_locus_supr_homogeneous_ideal ProjectiveSpectrum.zeroLocus_iSup_homogeneousIdeal
-/

#print ProjectiveSpectrum.zeroLocus_iUnion /-
theorem zeroLocus_iUnion {γ : Sort _} (s : γ → Set A) :
    zeroLocus 𝒜 (⋃ i, s i) = ⋂ i, zeroLocus 𝒜 (s i) :=
  (gc_set 𝒜).l_iSup
#align projective_spectrum.zero_locus_Union ProjectiveSpectrum.zeroLocus_iUnion
-/

#print ProjectiveSpectrum.zeroLocus_bUnion /-
theorem zeroLocus_bUnion (s : Set (Set A)) :
    zeroLocus 𝒜 (⋃ s' ∈ s, s' : Set A) = ⋂ s' ∈ s, zeroLocus 𝒜 s' := by simp only [zero_locus_Union]
#align projective_spectrum.zero_locus_bUnion ProjectiveSpectrum.zeroLocus_bUnion
-/

#print ProjectiveSpectrum.vanishingIdeal_iUnion /-
theorem vanishingIdeal_iUnion {γ : Sort _} (t : γ → Set (ProjectiveSpectrum 𝒜)) :
    vanishingIdeal (⋃ i, t i) = ⨅ i, vanishingIdeal (t i) :=
  HomogeneousIdeal.toIdeal_injective <| by
    convert (gc_ideal 𝒜).u_iInf <;> exact HomogeneousIdeal.toIdeal_iInf _
#align projective_spectrum.vanishing_ideal_Union ProjectiveSpectrum.vanishingIdeal_iUnion
-/

#print ProjectiveSpectrum.zeroLocus_inf /-
theorem zeroLocus_inf (I J : Ideal A) :
    zeroLocus 𝒜 ((I ⊓ J : Ideal A) : Set A) = zeroLocus 𝒜 I ∪ zeroLocus 𝒜 J :=
  Set.ext fun x => x.IsPrime.inf_le
#align projective_spectrum.zero_locus_inf ProjectiveSpectrum.zeroLocus_inf
-/

#print ProjectiveSpectrum.union_zeroLocus /-
theorem union_zeroLocus (s s' : Set A) :
    zeroLocus 𝒜 s ∪ zeroLocus 𝒜 s' = zeroLocus 𝒜 (Ideal.span s ⊓ Ideal.span s' : Ideal A) := by
  rw [zero_locus_inf]; simp
#align projective_spectrum.union_zero_locus ProjectiveSpectrum.union_zeroLocus
-/

#print ProjectiveSpectrum.zeroLocus_mul_ideal /-
theorem zeroLocus_mul_ideal (I J : Ideal A) :
    zeroLocus 𝒜 ((I * J : Ideal A) : Set A) = zeroLocus 𝒜 I ∪ zeroLocus 𝒜 J :=
  Set.ext fun x => x.IsPrime.mul_le
#align projective_spectrum.zero_locus_mul_ideal ProjectiveSpectrum.zeroLocus_mul_ideal
-/

#print ProjectiveSpectrum.zeroLocus_mul_homogeneousIdeal /-
theorem zeroLocus_mul_homogeneousIdeal (I J : HomogeneousIdeal 𝒜) :
    zeroLocus 𝒜 ((I * J : HomogeneousIdeal 𝒜) : Set A) = zeroLocus 𝒜 I ∪ zeroLocus 𝒜 J :=
  Set.ext fun x => x.IsPrime.mul_le
#align projective_spectrum.zero_locus_mul_homogeneous_ideal ProjectiveSpectrum.zeroLocus_mul_homogeneousIdeal
-/

#print ProjectiveSpectrum.zeroLocus_singleton_mul /-
theorem zeroLocus_singleton_mul (f g : A) :
    zeroLocus 𝒜 ({f * g} : Set A) = zeroLocus 𝒜 {f} ∪ zeroLocus 𝒜 {g} :=
  Set.ext fun x => by simpa using x.is_prime.mul_mem_iff_mem_or_mem
#align projective_spectrum.zero_locus_singleton_mul ProjectiveSpectrum.zeroLocus_singleton_mul
-/

#print ProjectiveSpectrum.zeroLocus_singleton_pow /-
@[simp]
theorem zeroLocus_singleton_pow (f : A) (n : ℕ) (hn : 0 < n) :
    zeroLocus 𝒜 ({f ^ n} : Set A) = zeroLocus 𝒜 {f} :=
  Set.ext fun x => by simpa using x.is_prime.pow_mem_iff_mem n hn
#align projective_spectrum.zero_locus_singleton_pow ProjectiveSpectrum.zeroLocus_singleton_pow
-/

#print ProjectiveSpectrum.sup_vanishingIdeal_le /-
theorem sup_vanishingIdeal_le (t t' : Set (ProjectiveSpectrum 𝒜)) :
    vanishingIdeal t ⊔ vanishingIdeal t' ≤ vanishingIdeal (t ∩ t') :=
  by
  intro r
  rw [← HomogeneousIdeal.mem_iff, HomogeneousIdeal.toIdeal_sup, mem_vanishing_ideal,
    Submodule.mem_sup]
  rintro ⟨f, hf, g, hg, rfl⟩ x ⟨hxt, hxt'⟩
  erw [mem_vanishing_ideal] at hf hg 
  apply Submodule.add_mem <;> solve_by_elim
#align projective_spectrum.sup_vanishing_ideal_le ProjectiveSpectrum.sup_vanishingIdeal_le
-/

#print ProjectiveSpectrum.mem_compl_zeroLocus_iff_not_mem /-
theorem mem_compl_zeroLocus_iff_not_mem {f : A} {I : ProjectiveSpectrum 𝒜} :
    I ∈ (zeroLocus 𝒜 {f} : Set (ProjectiveSpectrum 𝒜))ᶜ ↔ f ∉ I.asHomogeneousIdeal := by
  rw [Set.mem_compl_iff, mem_zero_locus, Set.singleton_subset_iff] <;> rfl
#align projective_spectrum.mem_compl_zero_locus_iff_not_mem ProjectiveSpectrum.mem_compl_zeroLocus_iff_not_mem
-/

#print ProjectiveSpectrum.zariskiTopology /-
/-- The Zariski topology on the prime spectrum of a commutative ring is defined via the closed sets
of the topology: they are exactly those sets that are the zero locus of a subset of the ring. -/
instance zariskiTopology : TopologicalSpace (ProjectiveSpectrum 𝒜) :=
  TopologicalSpace.ofClosed (Set.range (ProjectiveSpectrum.zeroLocus 𝒜)) ⟨Set.univ, by simp⟩
    (by
      intro Zs h
      rw [Set.sInter_eq_iInter]
      let f : Zs → Set _ := fun i => Classical.choose (h i.2)
      have hf : ∀ i : Zs, ↑i = zero_locus 𝒜 (f i) := fun i => (Classical.choose_spec (h i.2)).symm
      simp only [hf]
      exact ⟨_, zero_locus_Union 𝒜 _⟩)
    (by rintro _ ⟨s, rfl⟩ _ ⟨t, rfl⟩; exact ⟨_, (union_zero_locus 𝒜 s t).symm⟩)
#align projective_spectrum.zariski_topology ProjectiveSpectrum.zariskiTopology
-/

#print ProjectiveSpectrum.top /-
/-- The underlying topology of `Proj` is the projective spectrum of graded ring `A`. -/
def top : TopCat :=
  TopCat.of (ProjectiveSpectrum 𝒜)
#align projective_spectrum.Top ProjectiveSpectrum.top
-/

#print ProjectiveSpectrum.isOpen_iff /-
theorem isOpen_iff (U : Set (ProjectiveSpectrum 𝒜)) : IsOpen U ↔ ∃ s, Uᶜ = zeroLocus 𝒜 s := by
  simp only [@eq_comm _ (Uᶜ)] <;> rfl
#align projective_spectrum.is_open_iff ProjectiveSpectrum.isOpen_iff
-/

#print ProjectiveSpectrum.isClosed_iff_zeroLocus /-
theorem isClosed_iff_zeroLocus (Z : Set (ProjectiveSpectrum 𝒜)) :
    IsClosed Z ↔ ∃ s, Z = zeroLocus 𝒜 s := by rw [← isOpen_compl_iff, is_open_iff, compl_compl]
#align projective_spectrum.is_closed_iff_zero_locus ProjectiveSpectrum.isClosed_iff_zeroLocus
-/

#print ProjectiveSpectrum.isClosed_zeroLocus /-
theorem isClosed_zeroLocus (s : Set A) : IsClosed (zeroLocus 𝒜 s) := by
  rw [is_closed_iff_zero_locus]; exact ⟨s, rfl⟩
#align projective_spectrum.is_closed_zero_locus ProjectiveSpectrum.isClosed_zeroLocus
-/

#print ProjectiveSpectrum.zeroLocus_vanishingIdeal_eq_closure /-
theorem zeroLocus_vanishingIdeal_eq_closure (t : Set (ProjectiveSpectrum 𝒜)) :
    zeroLocus 𝒜 (vanishingIdeal t : Set A) = closure t :=
  by
  apply Set.Subset.antisymm
  · rintro x hx t' ⟨ht', ht⟩
    obtain ⟨fs, rfl⟩ : ∃ s, t' = zero_locus 𝒜 s := by rwa [is_closed_iff_zero_locus] at ht' 
    rw [subset_zero_locus_iff_subset_vanishing_ideal] at ht 
    exact Set.Subset.trans ht hx
  · rw [(is_closed_zero_locus _ _).closure_subset_iff]
    exact subset_zero_locus_vanishing_ideal 𝒜 t
#align projective_spectrum.zero_locus_vanishing_ideal_eq_closure ProjectiveSpectrum.zeroLocus_vanishingIdeal_eq_closure
-/

#print ProjectiveSpectrum.vanishingIdeal_closure /-
theorem vanishingIdeal_closure (t : Set (ProjectiveSpectrum 𝒜)) :
    vanishingIdeal (closure t) = vanishingIdeal t :=
  by
  have := (gc_ideal 𝒜).u_l_u_eq_u t
  dsimp only at this 
  ext1
  erw [zero_locus_vanishing_ideal_eq_closure 𝒜 t] at this 
  exact this
#align projective_spectrum.vanishing_ideal_closure ProjectiveSpectrum.vanishingIdeal_closure
-/

section BasicOpen

#print ProjectiveSpectrum.basicOpen /-
/-- `basic_open r` is the open subset containing all prime ideals not containing `r`. -/
def basicOpen (r : A) : TopologicalSpace.Opens (ProjectiveSpectrum 𝒜)
    where
  carrier := {x | r ∉ x.asHomogeneousIdeal}
  is_open' := ⟨{r}, Set.ext fun x => Set.singleton_subset_iff.trans <| Classical.not_not.symm⟩
#align projective_spectrum.basic_open ProjectiveSpectrum.basicOpen
-/

#print ProjectiveSpectrum.mem_basicOpen /-
@[simp]
theorem mem_basicOpen (f : A) (x : ProjectiveSpectrum 𝒜) :
    x ∈ basicOpen 𝒜 f ↔ f ∉ x.asHomogeneousIdeal :=
  Iff.rfl
#align projective_spectrum.mem_basic_open ProjectiveSpectrum.mem_basicOpen
-/

#print ProjectiveSpectrum.mem_coe_basicOpen /-
theorem mem_coe_basicOpen (f : A) (x : ProjectiveSpectrum 𝒜) :
    x ∈ (↑(basicOpen 𝒜 f) : Set (ProjectiveSpectrum 𝒜)) ↔ f ∉ x.asHomogeneousIdeal :=
  Iff.rfl
#align projective_spectrum.mem_coe_basic_open ProjectiveSpectrum.mem_coe_basicOpen
-/

#print ProjectiveSpectrum.isOpen_basicOpen /-
theorem isOpen_basicOpen {a : A} : IsOpen (basicOpen 𝒜 a : Set (ProjectiveSpectrum 𝒜)) :=
  (basicOpen 𝒜 a).IsOpen
#align projective_spectrum.is_open_basic_open ProjectiveSpectrum.isOpen_basicOpen
-/

#print ProjectiveSpectrum.basicOpen_eq_zeroLocus_compl /-
@[simp]
theorem basicOpen_eq_zeroLocus_compl (r : A) :
    (basicOpen 𝒜 r : Set (ProjectiveSpectrum 𝒜)) = zeroLocus 𝒜 {r}ᶜ :=
  Set.ext fun x => by simpa only [Set.mem_compl_iff, mem_zero_locus, Set.singleton_subset_iff]
#align projective_spectrum.basic_open_eq_zero_locus_compl ProjectiveSpectrum.basicOpen_eq_zeroLocus_compl
-/

#print ProjectiveSpectrum.basicOpen_one /-
@[simp]
theorem basicOpen_one : basicOpen 𝒜 (1 : A) = ⊤ :=
  TopologicalSpace.Opens.ext <| by simp
#align projective_spectrum.basic_open_one ProjectiveSpectrum.basicOpen_one
-/

#print ProjectiveSpectrum.basicOpen_zero /-
@[simp]
theorem basicOpen_zero : basicOpen 𝒜 (0 : A) = ⊥ :=
  TopologicalSpace.Opens.ext <| by simp
#align projective_spectrum.basic_open_zero ProjectiveSpectrum.basicOpen_zero
-/

#print ProjectiveSpectrum.basicOpen_mul /-
theorem basicOpen_mul (f g : A) : basicOpen 𝒜 (f * g) = basicOpen 𝒜 f ⊓ basicOpen 𝒜 g :=
  TopologicalSpace.Opens.ext <| by simp [zero_locus_singleton_mul]
#align projective_spectrum.basic_open_mul ProjectiveSpectrum.basicOpen_mul
-/

#print ProjectiveSpectrum.basicOpen_mul_le_left /-
theorem basicOpen_mul_le_left (f g : A) : basicOpen 𝒜 (f * g) ≤ basicOpen 𝒜 f := by
  rw [basic_open_mul 𝒜 f g]; exact inf_le_left
#align projective_spectrum.basic_open_mul_le_left ProjectiveSpectrum.basicOpen_mul_le_left
-/

#print ProjectiveSpectrum.basicOpen_mul_le_right /-
theorem basicOpen_mul_le_right (f g : A) : basicOpen 𝒜 (f * g) ≤ basicOpen 𝒜 g := by
  rw [basic_open_mul 𝒜 f g]; exact inf_le_right
#align projective_spectrum.basic_open_mul_le_right ProjectiveSpectrum.basicOpen_mul_le_right
-/

#print ProjectiveSpectrum.basicOpen_pow /-
@[simp]
theorem basicOpen_pow (f : A) (n : ℕ) (hn : 0 < n) : basicOpen 𝒜 (f ^ n) = basicOpen 𝒜 f :=
  TopologicalSpace.Opens.ext <| by simpa using zero_locus_singleton_pow 𝒜 f n hn
#align projective_spectrum.basic_open_pow ProjectiveSpectrum.basicOpen_pow
-/

#print ProjectiveSpectrum.basicOpen_eq_union_of_projection /-
theorem basicOpen_eq_union_of_projection (f : A) :
    basicOpen 𝒜 f = ⨆ i : ℕ, basicOpen 𝒜 (GradedAlgebra.proj 𝒜 i f) :=
  TopologicalSpace.Opens.ext <|
    Set.ext fun z => by
      erw [mem_coe_basic_open, TopologicalSpace.Opens.mem_sSup]
      constructor <;> intro hz
      · rcases show ∃ i, GradedAlgebra.proj 𝒜 i f ∉ z.as_homogeneous_ideal
            by
            contrapose! hz with H
            classical
            rw [← DirectSum.sum_support_decompose 𝒜 f]
            apply Ideal.sum_mem _ fun i hi => H i with
          ⟨i, hi⟩
        exact ⟨basic_open 𝒜 (GradedAlgebra.proj 𝒜 i f), ⟨i, rfl⟩, by rwa [mem_basic_open]⟩
      · obtain ⟨_, ⟨i, rfl⟩, hz⟩ := hz
        exact fun rid => hz (z.1.2 i rid)
#align projective_spectrum.basic_open_eq_union_of_projection ProjectiveSpectrum.basicOpen_eq_union_of_projection
-/

#print ProjectiveSpectrum.isTopologicalBasis_basic_opens /-
theorem isTopologicalBasis_basic_opens :
    TopologicalSpace.IsTopologicalBasis
      (Set.range fun r : A => (basicOpen 𝒜 r : Set (ProjectiveSpectrum 𝒜))) :=
  by
  apply TopologicalSpace.isTopologicalBasis_of_open_of_nhds
  · rintro _ ⟨r, rfl⟩
    exact is_open_basic_open 𝒜
  · rintro p U hp ⟨s, hs⟩
    rw [← compl_compl U, Set.mem_compl_iff, ← hs, mem_zero_locus, Set.not_subset] at hp 
    obtain ⟨f, hfs, hfp⟩ := hp
    refine' ⟨basic_open 𝒜 f, ⟨f, rfl⟩, hfp, _⟩
    rw [← Set.compl_subset_compl, ← hs, basic_open_eq_zero_locus_compl, compl_compl]
    exact zero_locus_anti_mono 𝒜 (set.singleton_subset_iff.mpr hfs)
#align projective_spectrum.is_topological_basis_basic_opens ProjectiveSpectrum.isTopologicalBasis_basic_opens
-/

end BasicOpen

section Order

/-!
## The specialization order

We endow `projective_spectrum 𝒜` with a partial order,
where `x ≤ y` if and only if `y ∈ closure {x}`.
-/


instance : PartialOrder (ProjectiveSpectrum 𝒜) :=
  PartialOrder.lift asHomogeneousIdeal fun ⟨_, _, _⟩ ⟨_, _, _⟩ => mk.inj_eq.mpr

#print ProjectiveSpectrum.as_ideal_le_as_ideal /-
@[simp]
theorem as_ideal_le_as_ideal (x y : ProjectiveSpectrum 𝒜) :
    x.asHomogeneousIdeal ≤ y.asHomogeneousIdeal ↔ x ≤ y :=
  Iff.rfl
#align projective_spectrum.as_ideal_le_as_ideal ProjectiveSpectrum.as_ideal_le_as_ideal
-/

#print ProjectiveSpectrum.as_ideal_lt_as_ideal /-
@[simp]
theorem as_ideal_lt_as_ideal (x y : ProjectiveSpectrum 𝒜) :
    x.asHomogeneousIdeal < y.asHomogeneousIdeal ↔ x < y :=
  Iff.rfl
#align projective_spectrum.as_ideal_lt_as_ideal ProjectiveSpectrum.as_ideal_lt_as_ideal
-/

#print ProjectiveSpectrum.le_iff_mem_closure /-
theorem le_iff_mem_closure (x y : ProjectiveSpectrum 𝒜) :
    x ≤ y ↔ y ∈ closure ({x} : Set (ProjectiveSpectrum 𝒜)) :=
  by
  rw [← as_ideal_le_as_ideal, ← zero_locus_vanishing_ideal_eq_closure, mem_zero_locus,
    vanishing_ideal_singleton]
  simp only [coe_subset_coe, Subtype.coe_le_coe, coe_coe]
#align projective_spectrum.le_iff_mem_closure ProjectiveSpectrum.le_iff_mem_closure
-/

end Order

end ProjectiveSpectrum

