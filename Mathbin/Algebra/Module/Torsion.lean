/-
Copyright (c) 2022 Pierre-Alexandre Bazin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Pierre-Alexandre Bazin

! This file was ported from Lean 3 source module algebra.module.torsion
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.DirectSum.Module
import Mathbin.Algebra.Module.BigOperators
import Mathbin.LinearAlgebra.Isomorphisms
import Mathbin.GroupTheory.Torsion
import Mathbin.RingTheory.Coprime.Ideal
import Mathbin.RingTheory.Finiteness

/-!
# Torsion submodules

## Main definitions

* `torsion_of R M x` : the torsion ideal of `x`, containing all `a` such that `a • x = 0`.
* `submodule.torsion_by R M a` : the `a`-torsion submodule, containing all elements `x` of `M` such
  that `a • x = 0`.
* `submodule.torsion_by_set R M s` : the submodule containing all elements `x` of `M` such that
  `a • x = 0` for all `a` in `s`.
* `submodule.torsion' R M S` : the `S`-torsion submodule, containing all elements `x` of `M` such
  that `a • x = 0` for some `a` in `S`.
* `submodule.torsion R M` : the torsion submoule, containing all elements `x` of `M` such that
  `a • x = 0` for some non-zero-divisor `a` in `R`.
* `module.is_torsion_by R M a` : the property that defines a `a`-torsion module. Similarly,
  `is_torsion_by_set`, `is_torsion'` and `is_torsion`.
* `module.is_torsion_by_set.module` : Creates a `R ⧸ I`-module from a `R`-module that
  `is_torsion_by_set R _ I`.

## Main statements

* `quot_torsion_of_equiv_span_singleton` : isomorphism between the span of an element of `M` and
  the quotient by its torsion ideal.
* `torsion' R M S` and `torsion R M` are submodules.
* `torsion_by_set_eq_torsion_by_span` : torsion by a set is torsion by the ideal generated by it.
* `submodule.torsion_by_is_torsion_by` : the `a`-torsion submodule is a `a`-torsion module.
  Similar lemmas for `torsion'` and `torsion`.
* `submodule.torsion_by_is_internal` : a `∏ i, p i`-torsion module is the internal direct sum of its
  `p i`-torsion submodules when the `p i` are pairwise coprime. A more general version with coprime
  ideals is `submodule.torsion_by_set_is_internal`.
* `submodule.no_zero_smul_divisors_iff_torsion_bot` : a module over a domain has
  `no_zero_smul_divisors` (that is, there is no non-zero `a`, `x` such that `a • x = 0`)
  iff its torsion submodule is trivial.
* `submodule.quotient_torsion.torsion_eq_bot` : quotienting by the torsion submodule makes the
  torsion submodule of the new module trivial. If `R` is a domain, we can derive an instance
  `submodule.quotient_torsion.no_zero_smul_divisors : no_zero_smul_divisors R (M ⧸ torsion R M)`.

## Notation

* The notions are defined for a `comm_semiring R` and a `module R M`. Some additional hypotheses on
  `R` and `M` are required by some lemmas.
* The letters `a`, `b`, ... are used for scalars (in `R`), while `x`, `y`, ... are used for vectors
  (in `M`).

## Tags

Torsion, submodule, module, quotient
-/


namespace Ideal

section TorsionOf

variable (R M : Type _) [Semiring R] [AddCommMonoid M] [Module R M]

/-- The torsion ideal of `x`, containing all `a` such that `a • x = 0`.-/
@[simps]
def torsionOf (x : M) : Ideal R :=
  (LinearMap.toSpanSingleton R M x).ker
#align ideal.torsion_of Ideal.torsionOf

@[simp]
theorem torsionOf_zero : torsionOf R M (0 : M) = ⊤ := by simp [torsion_of]
#align ideal.torsion_of_zero Ideal.torsionOf_zero

variable {R M}

@[simp]
theorem mem_torsionOf_iff (x : M) (a : R) : a ∈ torsionOf R M x ↔ a • x = 0 :=
  Iff.rfl
#align ideal.mem_torsion_of_iff Ideal.mem_torsionOf_iff

variable (R)

@[simp]
theorem torsionOf_eq_top_iff (m : M) : torsionOf R M m = ⊤ ↔ m = 0 :=
  by
  refine' ⟨fun h => _, fun h => by simp [h]⟩
  rw [← one_smul R m, ← mem_torsion_of_iff m (1 : R), h]
  exact Submodule.mem_top
#align ideal.torsion_of_eq_top_iff Ideal.torsionOf_eq_top_iff

@[simp]
theorem torsionOf_eq_bot_iff_of_noZeroSMulDivisors [Nontrivial R] [NoZeroSMulDivisors R M] (m : M) :
    torsionOf R M m = ⊥ ↔ m ≠ 0 :=
  by
  refine' ⟨fun h contra => _, fun h => (Submodule.eq_bot_iff _).mpr fun r hr => _⟩
  · rw [contra, torsion_of_zero] at h
    exact bot_ne_top.symm h
  · rw [mem_torsion_of_iff, smul_eq_zero] at hr
    tauto
#align ideal.torsion_of_eq_bot_iff_of_no_zero_smul_divisors Ideal.torsionOf_eq_bot_iff_of_noZeroSMulDivisors

/-- See also `complete_lattice.independent.linear_independent` which provides the same conclusion
but requires the stronger hypothesis `no_zero_smul_divisors R M`. -/
theorem CompleteLattice.Independent.linear_independent' {ι R M : Type _} {v : ι → M} [Ring R]
    [AddCommGroup M] [Module R M] (hv : CompleteLattice.Independent fun i => R ∙ v i)
    (h_ne_zero : ∀ i, Ideal.torsionOf R M (v i) = ⊥) : LinearIndependent R v :=
  by
  refine' linear_independent_iff_not_smul_mem_span.mpr fun i r hi => _
  replace hv := complete_lattice.independent_def.mp hv i
  simp only [supᵢ_subtype', ← Submodule.span_range_eq_supᵢ, disjoint_iff] at hv
  have : r • v i ∈ ⊥ := by
    rw [← hv, Submodule.mem_inf]
    refine' ⟨submodule.mem_span_singleton.mpr ⟨r, rfl⟩, _⟩
    convert hi
    ext
    simp
  rw [← Submodule.mem_bot R, ← h_ne_zero i]
  simpa using this
#align ideal.complete_lattice.independent.linear_independent' Ideal.CompleteLattice.Independent.linear_independent'

end TorsionOf

section

variable (R M : Type _) [Ring R] [AddCommGroup M] [Module R M]

/-- The span of `x` in `M` is isomorphic to `R` quotiented by the torsion ideal of `x`.-/
noncomputable def quotTorsionOfEquivSpanSingleton (x : M) : (R ⧸ torsionOf R M x) ≃ₗ[R] R ∙ x :=
  (LinearMap.toSpanSingleton R M x).quotKerEquivRange.trans <|
    LinearEquiv.ofEq _ _ (LinearMap.span_singleton_eq_range R M x).symm
#align ideal.quot_torsion_of_equiv_span_singleton Ideal.quotTorsionOfEquivSpanSingleton

variable {R M}

@[simp]
theorem quotTorsionOfEquivSpanSingleton_apply_mk (x : M) (a : R) :
    quotTorsionOfEquivSpanSingleton R M x (Submodule.Quotient.mk a) =
      a • ⟨x, Submodule.mem_span_singleton_self x⟩ :=
  rfl
#align ideal.quot_torsion_of_equiv_span_singleton_apply_mk Ideal.quotTorsionOfEquivSpanSingleton_apply_mk

end

end Ideal

open nonZeroDivisors

section Defs

variable (R M : Type _) [CommSemiring R] [AddCommMonoid M] [Module R M]

namespace Submodule

/-- The `a`-torsion submodule for `a` in `R`, containing all elements `x` of `M` such that
  `a • x = 0`. -/
@[simps]
def torsionBy (a : R) : Submodule R M :=
  (DistribMulAction.toLinearMap R M a).ker
#align submodule.torsion_by Submodule.torsionBy

/-- The submodule containing all elements `x` of `M` such that `a • x = 0` for all `a` in `s`. -/
@[simps]
def torsionBySet (s : Set R) : Submodule R M :=
  infₛ (torsionBy R M '' s)
#align submodule.torsion_by_set Submodule.torsionBySet

/-- The `S`-torsion submodule, containing all elements `x` of `M` such that `a • x = 0` for some
`a` in `S`. -/
@[simps]
def torsion' (S : Type _) [CommMonoid S] [DistribMulAction S M] [SMulCommClass S R M] :
    Submodule R M where
  carrier := { x | ∃ a : S, a • x = 0 }
  zero_mem' := ⟨1, smul_zero _⟩
  add_mem' := fun x y ⟨a, hx⟩ ⟨b, hy⟩ =>
    ⟨b * a, by rw [smul_add, mul_smul, mul_comm, mul_smul, hx, hy, smul_zero, smul_zero, add_zero]⟩
  smul_mem' := fun a x ⟨b, h⟩ => ⟨b, by rw [smul_comm, h, smul_zero]⟩
#align submodule.torsion' Submodule.torsion'

/-- The torsion submodule, containing all elements `x` of `M` such that  `a • x = 0` for some
  non-zero-divisor `a` in `R`. -/
@[reducible]
def torsion :=
  torsion' R M R⁰
#align submodule.torsion Submodule.torsion

end Submodule

namespace Module

/-- A `a`-torsion module is a module where every element is `a`-torsion. -/
@[reducible]
def IsTorsionBy (a : R) :=
  ∀ ⦃x : M⦄, a • x = 0
#align module.is_torsion_by Module.IsTorsionBy

/-- A module where every element is `a`-torsion for all `a` in `s`. -/
@[reducible]
def IsTorsionBySet (s : Set R) :=
  ∀ ⦃x : M⦄ ⦃a : s⦄, (a : R) • x = 0
#align module.is_torsion_by_set Module.IsTorsionBySet

/-- A `S`-torsion module is a module where every element is `a`-torsion for some `a` in `S`. -/
@[reducible]
def IsTorsion' (S : Type _) [SMul S M] :=
  ∀ ⦃x : M⦄, ∃ a : S, a • x = 0
#align module.is_torsion' Module.IsTorsion'

/-- A torsion module is a module where every element is `a`-torsion for some non-zero-divisor `a`.
-/
@[reducible]
def IsTorsion :=
  ∀ ⦃x : M⦄, ∃ a : R⁰, a • x = 0
#align module.is_torsion Module.IsTorsion

end Module

end Defs

variable {R M : Type _}

section

variable [CommSemiring R] [AddCommMonoid M] [Module R M] (s : Set R) (a : R)

namespace Submodule

@[simp]
theorem smul_torsionBy (x : torsionBy R M a) : a • x = 0 :=
  Subtype.ext x.Prop
#align submodule.smul_torsion_by Submodule.smul_torsionBy

@[simp]
theorem smul_coe_torsionBy (x : torsionBy R M a) : a • (x : M) = 0 :=
  x.Prop
#align submodule.smul_coe_torsion_by Submodule.smul_coe_torsionBy

@[simp]
theorem mem_torsionBy_iff (x : M) : x ∈ torsionBy R M a ↔ a • x = 0 :=
  Iff.rfl
#align submodule.mem_torsion_by_iff Submodule.mem_torsionBy_iff

@[simp]
theorem mem_torsionBySet_iff (x : M) : x ∈ torsionBySet R M s ↔ ∀ a : s, (a : R) • x = 0 :=
  by
  refine' ⟨fun h ⟨a, ha⟩ => mem_Inf.mp h _ (Set.mem_image_of_mem _ ha), fun h => mem_Inf.mpr _⟩
  rintro _ ⟨a, ha, rfl⟩; exact h ⟨a, ha⟩
#align submodule.mem_torsion_by_set_iff Submodule.mem_torsionBySet_iff

@[simp]
theorem torsionBy_singleton_eq : torsionBySet R M {a} = torsionBy R M a :=
  by
  ext x
  simp only [mem_torsion_by_set_iff, SetCoe.forall, Subtype.coe_mk, Set.mem_singleton_iff,
    forall_eq, mem_torsion_by_iff]
#align submodule.torsion_by_singleton_eq Submodule.torsionBy_singleton_eq

theorem torsionBySet_le_torsionBySet_of_subset {s t : Set R} (st : s ⊆ t) :
    torsionBySet R M t ≤ torsionBySet R M s :=
  infₛ_le_infₛ fun _ ⟨a, ha, h⟩ => ⟨a, st ha, h⟩
#align submodule.torsion_by_set_le_torsion_by_set_of_subset Submodule.torsionBySet_le_torsionBySet_of_subset

/-- Torsion by a set is torsion by the ideal generated by it. -/
theorem torsionBySet_eq_torsion_by_span : torsionBySet R M s = torsionBySet R M (Ideal.span s) :=
  by
  refine' le_antisymm (fun x hx => _) (torsion_by_set_le_torsion_by_set_of_subset subset_span)
  rw [mem_torsion_by_set_iff] at hx⊢
  suffices Ideal.span s ≤ Ideal.torsionOf R M x
    by
    rintro ⟨a, ha⟩
    exact this ha
  rw [Ideal.span_le]
  exact fun a ha => hx ⟨a, ha⟩
#align submodule.torsion_by_set_eq_torsion_by_span Submodule.torsionBySet_eq_torsion_by_span

theorem torsionBy_span_singleton_eq : torsionBySet R M (R ∙ a) = torsionBy R M a :=
  (torsionBySet_eq_torsion_by_span _).symm.trans <| torsionBy_singleton_eq _
#align submodule.torsion_by_span_singleton_eq Submodule.torsionBy_span_singleton_eq

theorem torsionBy_le_torsionBy_of_dvd (a b : R) (dvd : a ∣ b) : torsionBy R M a ≤ torsionBy R M b :=
  by
  rw [← torsion_by_span_singleton_eq, ← torsion_by_singleton_eq]
  apply torsion_by_set_le_torsion_by_set_of_subset
  rintro c (rfl : c = b); exact ideal.mem_span_singleton.mpr dvd
#align submodule.torsion_by_le_torsion_by_of_dvd Submodule.torsionBy_le_torsionBy_of_dvd

@[simp]
theorem torsionBy_one : torsionBy R M 1 = ⊥ :=
  eq_bot_iff.mpr fun _ h => by
    rw [mem_torsion_by_iff, one_smul] at h
    exact h
#align submodule.torsion_by_one Submodule.torsionBy_one

@[simp]
theorem torsion_by_univ : torsionBySet R M Set.univ = ⊥ :=
  by
  rw [eq_bot_iff, ← torsion_by_one, ← torsion_by_singleton_eq]
  exact torsion_by_set_le_torsion_by_set_of_subset fun _ _ => trivial
#align submodule.torsion_by_univ Submodule.torsion_by_univ

end Submodule

open Submodule

namespace Module

@[simp]
theorem isTorsionBy_singleton_iff : IsTorsionBySet R M {a} ↔ IsTorsionBy R M a :=
  by
  refine' ⟨fun h x => @h _ ⟨_, Set.mem_singleton _⟩, fun h x => _⟩
  rintro ⟨b, rfl : b = a⟩; exact @h _
#align module.is_torsion_by_singleton_iff Module.isTorsionBy_singleton_iff

theorem isTorsionBySet_iff_torsionBySet_eq_top :
    IsTorsionBySet R M s ↔ Submodule.torsionBySet R M s = ⊤ :=
  ⟨fun h => eq_top_iff.mpr fun _ _ => (mem_torsionBySet_iff _ _).mpr <| @h _, fun h x =>
    by
    rw [← mem_torsion_by_set_iff, h]
    trivial⟩
#align module.is_torsion_by_set_iff_torsion_by_set_eq_top Module.isTorsionBySet_iff_torsionBySet_eq_top

/-- A `a`-torsion module is a module whose `a`-torsion submodule is the full space. -/
theorem isTorsionBy_iff_torsionBy_eq_top : IsTorsionBy R M a ↔ torsionBy R M a = ⊤ := by
  rw [← torsion_by_singleton_eq, ← is_torsion_by_singleton_iff,
    is_torsion_by_set_iff_torsion_by_set_eq_top]
#align module.is_torsion_by_iff_torsion_by_eq_top Module.isTorsionBy_iff_torsionBy_eq_top

theorem isTorsionBySet_iff_is_torsion_by_span :
    IsTorsionBySet R M s ↔ IsTorsionBySet R M (Ideal.span s) := by
  rw [is_torsion_by_set_iff_torsion_by_set_eq_top, is_torsion_by_set_iff_torsion_by_set_eq_top,
    torsion_by_set_eq_torsion_by_span]
#align module.is_torsion_by_set_iff_is_torsion_by_span Module.isTorsionBySet_iff_is_torsion_by_span

theorem isTorsionBy_span_singleton_iff : IsTorsionBySet R M (R ∙ a) ↔ IsTorsionBy R M a :=
  (isTorsionBySet_iff_is_torsion_by_span _).symm.trans <| isTorsionBy_singleton_iff _
#align module.is_torsion_by_span_singleton_iff Module.isTorsionBy_span_singleton_iff

end Module

namespace Submodule

open Module

theorem torsionBySet_isTorsionBySet : IsTorsionBySet R (torsionBySet R M s) s := fun ⟨x, hx⟩ a =>
  Subtype.ext <| (mem_torsionBySet_iff _ _).mp hx a
#align submodule.torsion_by_set_is_torsion_by_set Submodule.torsionBySet_isTorsionBySet

/-- The `a`-torsion submodule is a `a`-torsion module. -/
theorem torsionBy_isTorsionBy : IsTorsionBy R (torsionBy R M a) a := fun _ => smul_torsionBy _ _
#align submodule.torsion_by_is_torsion_by Submodule.torsionBy_isTorsionBy

@[simp]
theorem torsionBy_torsionBy_eq_top : torsionBy R (torsionBy R M a) a = ⊤ :=
  (isTorsionBy_iff_torsionBy_eq_top a).mp <| torsionBy_isTorsionBy a
#align submodule.torsion_by_torsion_by_eq_top Submodule.torsionBy_torsionBy_eq_top

@[simp]
theorem torsionBySet_torsionBySet_eq_top : torsionBySet R (torsionBySet R M s) s = ⊤ :=
  (isTorsionBySet_iff_torsionBySet_eq_top s).mp <| torsionBySet_isTorsionBySet s
#align submodule.torsion_by_set_torsion_by_set_eq_top Submodule.torsionBySet_torsionBySet_eq_top

variable (R M)

theorem torsion_gc :
    @GaloisConnection (Submodule R M) (Ideal R)ᵒᵈ _ _ annihilator fun I =>
      torsionBySet R M <| I.ofDual :=
  fun A I =>
  ⟨fun h x hx => (mem_torsionBySet_iff _ _).mpr fun ⟨a, ha⟩ => mem_annihilator.mp (h ha) x hx,
    fun h a ha => mem_annihilator.mpr fun x hx => (mem_torsionBySet_iff _ _).mp (h hx) ⟨a, ha⟩⟩
#align submodule.torsion_gc Submodule.torsion_gc

variable {R M}

section Coprime

open BigOperators

variable {ι : Type _} {p : ι → Ideal R} {S : Finset ι}

variable (hp : (S : Set ι).Pairwise fun i j => p i ⊔ p j = ⊤)

include hp

theorem supᵢ_torsion_by_ideal_eq_torsion_by_infᵢ :
    (⨆ i ∈ S, torsionBySet R M <| p i) = torsionBySet R M ↑(⨅ i ∈ S, p i) :=
  by
  cases' S.eq_empty_or_nonempty with h h
  · rw [h]
    convert supᵢ_emptyset
    convert torsion_by_univ
    convert top_coe
    exact infᵢ_emptyset
  apply le_antisymm
  · apply supᵢ_le _
    intro i
    apply supᵢ_le _
    intro is
    apply torsion_by_set_le_torsion_by_set_of_subset
    exact (infᵢ_le (fun i => ⨅ H : i ∈ S, p i) i).trans (infᵢ_le _ is)
  · intro x hx
    rw [mem_supr_finset_iff_exists_sum]
    obtain ⟨μ, hμ⟩ :=
      (mem_supr_finset_iff_exists_sum _ _).mp
        ((Ideal.eq_top_iff_one _).mp <| (Ideal.supᵢ_infᵢ_eq_top_iff_pairwise h _).mpr hp)
    refine' ⟨fun i => ⟨(μ i : R) • x, _⟩, _⟩
    · rw [mem_torsion_by_set_iff] at hx⊢
      rintro ⟨a, ha⟩
      rw [smul_smul]
      suffices : a * μ i ∈ ⨅ i ∈ S, p i
      exact hx ⟨_, this⟩
      rw [mem_infi]
      intro j
      rw [mem_infi]
      intro hj
      by_cases ij : j = i
      · rw [ij]
        exact Ideal.mul_mem_right _ _ ha
      · have := coe_mem (μ i)
        simp only [mem_infi] at this
        exact Ideal.mul_mem_left _ _ (this j hj ij)
    · simp_rw [coe_mk]
      rw [← Finset.sum_smul, hμ, one_smul]
#align submodule.supr_torsion_by_ideal_eq_torsion_by_infi Submodule.supᵢ_torsion_by_ideal_eq_torsion_by_infᵢ

theorem supIndep_torsion_by_ideal : S.SupIndep fun i => torsionBySet R M <| p i :=
  fun T hT i hi hiT =>
  by
  rw [disjoint_iff, Finset.sup_eq_supᵢ,
    supr_torsion_by_ideal_eq_torsion_by_infi fun i hi j hj ij => hp (hT hi) (hT hj) ij]
  have :=
    @GaloisConnection.u_inf _ _ (OrderDual.toDual _) (OrderDual.toDual _) _ _ _ _ (torsion_gc R M)
  dsimp at this⊢
  rw [← this, Ideal.sup_infᵢ_eq_top, top_coe, torsion_by_univ]
  intro j hj; apply hp hi (hT hj); rintro rfl; exact hiT hj
#align submodule.sup_indep_torsion_by_ideal Submodule.supIndep_torsion_by_ideal

omit hp

variable {q : ι → R} (hq : (S : Set ι).Pairwise <| (IsCoprime on q))

include hq

theorem supᵢ_torsionBy_eq_torsionBy_prod :
    (⨆ i ∈ S, torsionBy R M <| q i) = torsionBy R M (∏ i in S, q i) :=
  by
  rw [← torsion_by_span_singleton_eq, Ideal.submodule_span_eq, ←
    Ideal.finset_inf_span_singleton _ _ hq, Finset.inf_eq_infᵢ, ←
    supr_torsion_by_ideal_eq_torsion_by_infi]
  · congr
    ext : 1
    congr
    ext : 1
    exact (torsion_by_span_singleton_eq _).symm
  · exact fun i hi j hj ij => (Ideal.sup_eq_top_iff_isCoprime _ _).mpr (hq hi hj ij)
#align submodule.supr_torsion_by_eq_torsion_by_prod Submodule.supᵢ_torsionBy_eq_torsionBy_prod

theorem supIndep_torsionBy : S.SupIndep fun i => torsionBy R M <| q i :=
  by
  convert
    sup_indep_torsion_by_ideal fun i hi j hj ij =>
      (Ideal.sup_eq_top_iff_isCoprime (q i) _).mpr <| hq hi hj ij
  ext : 1; exact (torsion_by_span_singleton_eq _).symm
#align submodule.sup_indep_torsion_by Submodule.supIndep_torsionBy

end Coprime

end Submodule

end

section NeedsGroup

variable [CommRing R] [AddCommGroup M] [Module R M]

namespace Submodule

open BigOperators

variable {ι : Type _} [DecidableEq ι] {S : Finset ι}

/-- If the `p i` are pairwise coprime, a `⨅ i, p i`-torsion module is the internal direct sum of
its `p i`-torsion submodules.-/
theorem torsionBySet_isInternal {p : ι → Ideal R}
    (hp : (S : Set ι).Pairwise fun i j => p i ⊔ p j = ⊤)
    (hM : Module.IsTorsionBySet R M (⨅ i ∈ S, p i : Ideal R)) :
    DirectSum.IsInternal fun i : S => torsionBySet R M <| p i :=
  DirectSum.isInternal_submodule_of_independent_of_supᵢ_eq_top
    (CompleteLattice.independent_iff_supIndep.mpr <| supIndep_torsion_by_ideal hp)
    ((supᵢ_subtype'' ↑S fun i => torsionBySet R M <| p i).trans <|
      (supᵢ_torsion_by_ideal_eq_torsion_by_infᵢ hp).trans <|
        (Module.isTorsionBySet_iff_torsionBySet_eq_top _).mp hM)
#align submodule.torsion_by_set_is_internal Submodule.torsionBySet_isInternal

/-- If the `q i` are pairwise coprime, a `∏ i, q i`-torsion module is the internal direct sum of
its `q i`-torsion submodules.-/
theorem torsionBy_isInternal {q : ι → R} (hq : (S : Set ι).Pairwise <| (IsCoprime on q))
    (hM : Module.IsTorsionBy R M <| ∏ i in S, q i) :
    DirectSum.IsInternal fun i : S => torsionBy R M <| q i :=
  by
  rw [← Module.isTorsionBy_span_singleton_iff, Ideal.submodule_span_eq, ←
    Ideal.finset_inf_span_singleton _ _ hq, Finset.inf_eq_infᵢ] at hM
  convert
    torsion_by_set_is_internal
      (fun i hi j hj ij => (Ideal.sup_eq_top_iff_isCoprime (q i) _).mpr <| hq hi hj ij) hM
  ext : 1; exact (torsion_by_span_singleton_eq _).symm
#align submodule.torsion_by_is_internal Submodule.torsionBy_isInternal

end Submodule

namespace Module

variable {I : Ideal R} (hM : IsTorsionBySet R M I)

include hM

/-- can't be an instance because hM can't be inferred -/
def IsTorsionBySet.hasSmul : SMul (R ⧸ I) M
    where smul b x :=
    Quotient.liftOn' b (· • x) fun b₁ b₂ h =>
      by
      show b₁ • x = b₂ • x
      have : (-b₁ + b₂) • x = 0 := @hM x ⟨_, quotient_add_group.left_rel_apply.mp h⟩
      rw [add_smul, neg_smul, neg_add_eq_zero] at this
      exact this
#align module.is_torsion_by_set.has_smul Module.IsTorsionBySet.hasSmul

@[simp]
theorem IsTorsionBySet.mk_smul (b : R) (x : M) :
    haveI := hM.has_smul
    Ideal.Quotient.mk I b • x = b • x :=
  rfl
#align module.is_torsion_by_set.mk_smul Module.IsTorsionBySet.mk_smul

/-- A `(R ⧸ I)`-module is a `R`-module which `is_torsion_by_set R M I`. -/
def IsTorsionBySet.module : Module (R ⧸ I) M :=
  @Function.Surjective.moduleLeft _ _ _ _ _ _ _ hM.HasSmul _ Ideal.Quotient.mk_surjective
    (IsTorsionBySet.mk_smul hM)
#align module.is_torsion_by_set.module Module.IsTorsionBySet.module

instance IsTorsionBySet.isScalarTower {S : Type _} [SMul S R] [SMul S M] [IsScalarTower S R M]
    [IsScalarTower S R R] : @IsScalarTower S (R ⧸ I) M _ (IsTorsionBySet.module hM).toHasSmul _
    where smul_assoc b d x := Quotient.inductionOn' d fun c => (smul_assoc b c x : _)
#align module.is_torsion_by_set.is_scalar_tower Module.IsTorsionBySet.isScalarTower

omit hM

instance : Module (R ⧸ I) (M ⧸ I • (⊤ : Submodule R M)) :=
  IsTorsionBySet.module fun x r =>
    by
    induction x using Quotient.inductionOn
    refine' (Submodule.Quotient.mk_eq_zero _).mpr (Submodule.smul_mem_smul r.prop _)
    trivial

end Module

namespace Submodule

instance (I : Ideal R) : Module (R ⧸ I) (torsionBySet R M I) :=
  Module.IsTorsionBySet.module <| torsionBySet_isTorsionBySet I

@[simp]
theorem torsionBySet.mk_smul (I : Ideal R) (b : R) (x : torsionBySet R M I) :
    Ideal.Quotient.mk I b • x = b • x :=
  rfl
#align submodule.torsion_by_set.mk_smul Submodule.torsionBySet.mk_smul

instance (I : Ideal R) {S : Type _} [SMul S R] [SMul S M] [IsScalarTower S R M]
    [IsScalarTower S R R] : IsScalarTower S (R ⧸ I) (torsionBySet R M I) :=
  inferInstance

/-- The `a`-torsion submodule as a `(R ⧸ R∙a)`-module. -/
instance (a : R) : Module (R ⧸ R ∙ a) (torsionBy R M a) :=
  Module.IsTorsionBySet.module <|
    (Module.isTorsionBy_span_singleton_iff a).mpr <| torsionBy_isTorsionBy a

@[simp]
theorem torsionBy.mk_smul (a b : R) (x : torsionBy R M a) :
    Ideal.Quotient.mk (R ∙ a) b • x = b • x :=
  rfl
#align submodule.torsion_by.mk_smul Submodule.torsionBy.mk_smul

instance (a : R) {S : Type _} [SMul S R] [SMul S M] [IsScalarTower S R M] [IsScalarTower S R R] :
    IsScalarTower S (R ⧸ R ∙ a) (torsionBy R M a) :=
  inferInstance

end Submodule

end NeedsGroup

namespace Submodule

section Torsion'

open Module

variable [CommSemiring R] [AddCommMonoid M] [Module R M]

variable (S : Type _) [CommMonoid S] [DistribMulAction S M] [SMulCommClass S R M]

@[simp]
theorem mem_torsion'_iff (x : M) : x ∈ torsion' R M S ↔ ∃ a : S, a • x = 0 :=
  Iff.rfl
#align submodule.mem_torsion'_iff Submodule.mem_torsion'_iff

@[simp]
theorem mem_torsion_iff (x : M) : x ∈ torsion R M ↔ ∃ a : R⁰, a • x = 0 :=
  Iff.rfl
#align submodule.mem_torsion_iff Submodule.mem_torsion_iff

@[simps]
instance : SMul S (torsion' R M S) :=
  ⟨fun s x =>
    ⟨s • x, by
      obtain ⟨x, a, h⟩ := x
      use a
      dsimp
      rw [smul_comm, h, smul_zero]⟩⟩

instance : DistribMulAction S (torsion' R M S) :=
  Subtype.coe_injective.DistribMulAction (torsion' R M S).Subtype.toAddMonoidHom fun (c : S) x =>
    rfl

instance : SMulCommClass S R (torsion' R M S) :=
  ⟨fun s a x => Subtype.ext <| smul_comm _ _ _⟩

/-- A `S`-torsion module is a module whose `S`-torsion submodule is the full space. -/
theorem isTorsion'_iff_torsion'_eq_top : IsTorsion' M S ↔ torsion' R M S = ⊤ :=
  ⟨fun h => eq_top_iff.mpr fun _ _ => @h _, fun h x =>
    by
    rw [← @mem_torsion'_iff R, h]
    trivial⟩
#align submodule.is_torsion'_iff_torsion'_eq_top Submodule.isTorsion'_iff_torsion'_eq_top

/-- The `S`-torsion submodule is a `S`-torsion module. -/
theorem torsion'_isTorsion' : IsTorsion' (torsion' R M S) S := fun ⟨x, ⟨a, h⟩⟩ => ⟨a, Subtype.ext h⟩
#align submodule.torsion'_is_torsion' Submodule.torsion'_isTorsion'

@[simp]
theorem torsion'_torsion'_eq_top : torsion' R (torsion' R M S) S = ⊤ :=
  (isTorsion'_iff_torsion'_eq_top S).mp <| torsion'_isTorsion' S
#align submodule.torsion'_torsion'_eq_top Submodule.torsion'_torsion'_eq_top

/-- The torsion submodule of the torsion submodule (viewed as a module) is the full
torsion module. -/
@[simp]
theorem torsion_torsion_eq_top : torsion R (torsion R M) = ⊤ :=
  torsion'_torsion'_eq_top R⁰
#align submodule.torsion_torsion_eq_top Submodule.torsion_torsion_eq_top

/-- The torsion submodule is always a torsion module. -/
theorem torsion_isTorsion : Module.IsTorsion R (torsion R M) :=
  torsion'_isTorsion' R⁰
#align submodule.torsion_is_torsion Submodule.torsion_isTorsion

end Torsion'

section Torsion

variable [CommSemiring R] [AddCommMonoid M] [Module R M]

open BigOperators

theorem isTorsion_by_ideal_of_finite_of_isTorsion [Module.Finite R M] (hM : Module.IsTorsion R M) :
    ∃ I : Ideal R, (I : Set R) ∩ R⁰ ≠ ∅ ∧ Module.IsTorsionBySet R M I :=
  by
  cases' (module.finite_def.mp inferInstance : (⊤ : Submodule R M).Fg) with S h
  refine' ⟨∏ x in S, Ideal.torsionOf R M x, _, _⟩
  · refine' Set.Nonempty.ne_empty ⟨_, _, (∏ x in S, (@hM x).some : R⁰).2⟩
    rw [Subtype.val_eq_coe, Submonoid.coe_finset_prod]
    apply Ideal.prod_mem_prod
    exact fun x _ => (@hM x).some_spec
  · rw [Module.isTorsionBySet_iff_torsionBySet_eq_top, eq_top_iff, ← h, span_le]
    intro x hx
    apply torsion_by_set_le_torsion_by_set_of_subset
    · apply Ideal.le_of_dvd
      exact Finset.dvd_prod_of_mem _ hx
    · rw [mem_torsion_by_set_iff]
      rintro ⟨a, ha⟩
      exact ha
#align submodule.is_torsion_by_ideal_of_finite_of_is_torsion Submodule.isTorsion_by_ideal_of_finite_of_isTorsion

variable [NoZeroDivisors R] [Nontrivial R]

theorem coe_torsion_eq_annihilator_ne_bot :
    (torsion R M : Set M) = { x : M | (R ∙ x).annihilator ≠ ⊥ } :=
  by
  ext x; simp_rw [Submodule.ne_bot_iff, mem_annihilator, mem_span_singleton]
  exact
    ⟨fun ⟨a, hax⟩ =>
      ⟨a, fun _ ⟨b, hb⟩ => by rw [← hb, smul_comm, ← Submonoid.smul_def, hax, smul_zero],
        nonZeroDivisors.coe_ne_zero _⟩,
      fun ⟨a, hax, ha⟩ => ⟨⟨_, mem_nonZeroDivisors_of_ne_zero ha⟩, hax x ⟨1, one_smul _ _⟩⟩⟩
#align submodule.coe_torsion_eq_annihilator_ne_bot Submodule.coe_torsion_eq_annihilator_ne_bot

/-- A module over a domain has `no_zero_smul_divisors` iff its torsion submodule is trivial. -/
theorem noZeroSMulDivisors_iff_torsion_eq_bot : NoZeroSMulDivisors R M ↔ torsion R M = ⊥ :=
  by
  constructor <;> intro h
  · haveI : NoZeroSMulDivisors R M := h
    rw [eq_bot_iff]
    rintro x ⟨a, hax⟩
    change (a : R) • x = 0 at hax
    cases' eq_zero_or_eq_zero_of_smul_eq_zero hax with h0 h0
    · exfalso
      exact nonZeroDivisors.coe_ne_zero a h0
    · exact h0
  ·
    exact
      {
        eq_zero_or_eq_zero_of_smul_eq_zero := fun a x hax =>
          by
          by_cases ha : a = 0
          · left
            exact ha
          · right
            rw [← mem_bot _, ← h]
            exact ⟨⟨a, mem_nonZeroDivisors_of_ne_zero ha⟩, hax⟩ }
#align submodule.no_zero_smul_divisors_iff_torsion_eq_bot Submodule.noZeroSMulDivisors_iff_torsion_eq_bot

end Torsion

namespace QuotientTorsion

variable [CommRing R] [AddCommGroup M] [Module R M]

/-- Quotienting by the torsion submodule gives a torsion-free module. -/
@[simp]
theorem torsion_eq_bot : torsion R (M ⧸ torsion R M) = ⊥ :=
  eq_bot_iff.mpr fun z =>
    Quotient.inductionOn' z fun x ⟨a, hax⟩ =>
      by
      rw [Quotient.mk'_eq_mk'', ← quotient.mk_smul, quotient.mk_eq_zero] at hax
      rw [mem_bot, Quotient.mk'_eq_mk'', quotient.mk_eq_zero]
      cases' hax with b h
      exact ⟨b * a, (mul_smul _ _ _).trans h⟩
#align submodule.quotient_torsion.torsion_eq_bot Submodule.QuotientTorsion.torsion_eq_bot

instance noZeroSMulDivisors [IsDomain R] : NoZeroSMulDivisors R (M ⧸ torsion R M) :=
  noZeroSMulDivisors_iff_torsion_eq_bot.mpr torsion_eq_bot
#align submodule.quotient_torsion.no_zero_smul_divisors Submodule.QuotientTorsion.noZeroSMulDivisors

end QuotientTorsion

section PTorsion

open Module

section

variable [Monoid R] [AddCommMonoid M] [DistribMulAction R M]

theorem isTorsion'_powers_iff (p : R) :
    IsTorsion' M (Submonoid.powers p) ↔ ∀ x : M, ∃ n : ℕ, p ^ n • x = 0 :=
  ⟨fun h x =>
    let ⟨⟨a, ⟨n, rfl⟩⟩, hx⟩ := @h x
    ⟨n, hx⟩,
    fun h x =>
    let ⟨n, hn⟩ := h x
    ⟨⟨_, ⟨n, rfl⟩⟩, hn⟩⟩
#align submodule.is_torsion'_powers_iff Submodule.isTorsion'_powers_iff

/-- In a `p ^ ∞`-torsion module (that is, a module where all elements are cancelled by scalar
multiplication by some power of `p`), the smallest `n` such that `p ^ n • x = 0`.-/
def pOrder {p : R} (hM : IsTorsion' M <| Submonoid.powers p) (x : M)
    [∀ n : ℕ, Decidable (p ^ n • x = 0)] :=
  Nat.find <| (isTorsion'_powers_iff p).mp hM x
#align submodule.p_order Submodule.pOrder

@[simp]
theorem pow_pOrder_smul {p : R} (hM : IsTorsion' M <| Submonoid.powers p) (x : M)
    [∀ n : ℕ, Decidable (p ^ n • x = 0)] : p ^ pOrder hM x • x = 0 :=
  Nat.find_spec <| (isTorsion'_powers_iff p).mp hM x
#align submodule.pow_p_order_smul Submodule.pow_pOrder_smul

end

variable [CommSemiring R] [AddCommMonoid M] [Module R M] [∀ x : M, Decidable (x = 0)]

theorem exists_isTorsionBy {p : R} (hM : IsTorsion' M <| Submonoid.powers p) (d : ℕ) (hd : d ≠ 0)
    (s : Fin d → M) (hs : span R (Set.range s) = ⊤) :
    ∃ j : Fin d, Module.IsTorsionBy R M (p ^ pOrder hM (s j)) :=
  by
  let oj := List.argmax (fun i => p_order hM <| s i) (List.finRange d)
  have hoj : oj.is_some :=
    option.ne_none_iff_is_some.mp fun eq_none =>
      hd <| list.fin_range_eq_nil.mp <| list.argmax_eq_none.mp eq_none
  use Option.get hoj
  rw [is_torsion_by_iff_torsion_by_eq_top, eq_top_iff, ← hs, Submodule.span_le,
    Set.range_subset_iff]
  intro i; change _ • _ = _
  have : p_order hM (s i) ≤ p_order hM (s <| Option.get hoj) :=
    List.le_of_mem_argmax (List.mem_finRange i) (Option.get_mem hoj)
  rw [← Nat.sub_add_cancel this, pow_add, mul_smul, pow_p_order_smul, smul_zero]
#align submodule.exists_is_torsion_by Submodule.exists_isTorsionBy

end PTorsion

end Submodule

namespace Ideal.Quotient

open Submodule

theorem torsionBy_eq_span_singleton {R : Type _} [CommRing R] (a b : R) (ha : a ∈ R⁰) :
    torsionBy R (R ⧸ R ∙ a * b) a = R ∙ mk _ b :=
  by
  ext x; rw [mem_torsion_by_iff, mem_span_singleton]
  obtain ⟨x, rfl⟩ := mk_surjective x; constructor <;> intro h
  · rw [← mk_eq_mk, ← quotient.mk_smul, quotient.mk_eq_zero, mem_span_singleton] at h
    obtain ⟨c, h⟩ := h
    rw [smul_eq_mul, smul_eq_mul, mul_comm, mul_assoc, mul_cancel_left_mem_non_zero_divisor ha,
      mul_comm] at h
    use c
    rw [← h, ← mk_eq_mk, ← quotient.mk_smul, smul_eq_mul, mk_eq_mk]
  · obtain ⟨c, h⟩ := h
    rw [← h, smul_comm, ← mk_eq_mk, ← quotient.mk_smul,
      (quotient.mk_eq_zero _).mpr <| mem_span_singleton_self _, smul_zero]
#align ideal.quotient.torsion_by_eq_span_singleton Ideal.Quotient.torsionBy_eq_span_singleton

end Ideal.Quotient

namespace AddMonoid

theorem isTorsion_iff_isTorsion_nat [AddCommMonoid M] :
    AddMonoid.IsTorsion M ↔ Module.IsTorsion ℕ M :=
  by
  refine' ⟨fun h x => _, fun h x => _⟩
  · obtain ⟨n, h0, hn⟩ := (is_of_fin_add_order_iff_nsmul_eq_zero x).mp (h x)
    exact ⟨⟨n, mem_nonZeroDivisors_of_ne_zero <| ne_of_gt h0⟩, hn⟩
  · rw [is_of_fin_add_order_iff_nsmul_eq_zero]
    obtain ⟨n, hn⟩ := @h x
    refine' ⟨n, Nat.pos_of_ne_zero (nonZeroDivisors.coe_ne_zero _), hn⟩
#align add_monoid.is_torsion_iff_is_torsion_nat AddMonoid.isTorsion_iff_isTorsion_nat

theorem isTorsion_iff_isTorsion_int [AddCommGroup M] :
    AddMonoid.IsTorsion M ↔ Module.IsTorsion ℤ M :=
  by
  refine' ⟨fun h x => _, fun h x => _⟩
  · obtain ⟨n, h0, hn⟩ := (is_of_fin_add_order_iff_nsmul_eq_zero x).mp (h x)
    exact
      ⟨⟨n, mem_nonZeroDivisors_of_ne_zero <| ne_of_gt <| int.coe_nat_pos.mpr h0⟩,
        (coe_nat_zsmul _ _).trans hn⟩
  · rw [is_of_fin_add_order_iff_nsmul_eq_zero]
    obtain ⟨n, hn⟩ := @h x
    exact exists_nsmul_eq_zero_of_zsmul_eq_zero (nonZeroDivisors.coe_ne_zero n) hn
#align add_monoid.is_torsion_iff_is_torsion_int AddMonoid.isTorsion_iff_isTorsion_int

end AddMonoid

