/-
Copyright (c) 2020 Kenji Nakagawa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenji Nakagawa, Anne Baanen, Filippo A. E. Nuccio

! This file was ported from Lean 3 source module ring_theory.dedekind_domain.integral_closure
! leanprover-community/mathlib commit e8e130de9dba4ed6897183c3193c752ffadbcc77
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.FreeModule.Pid
import Mathbin.RingTheory.DedekindDomain.Basic
import Mathbin.RingTheory.Localization.Module
import Mathbin.RingTheory.Trace

/-!
# Integral closure of Dedekind domains

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file shows the integral closure of a Dedekind domain (in particular, the ring of integers
of a number field) is a Dedekind domain.

## Implementation notes

The definitions that involve a field of fractions choose a canonical field of fractions,
but are independent of that choice. The `..._iff` lemmas express this independence.

Often, definitions assume that Dedekind domains are not fields. We found it more practical
to add a `(h : ¬ is_field A)` assumption whenever this is explicitly needed.

## References

* [D. Marcus, *Number Fields*][marcus1977number]
* [J.W.S. Cassels, A. Frölich, *Algebraic Number Theory*][cassels1967algebraic]
* [J. Neukirch, *Algebraic Number Theory*][Neukirch1992]

## Tags

dedekind domain, dedekind ring
-/


variable (R A K : Type _) [CommRing R] [CommRing A] [Field K]

open scoped nonZeroDivisors Polynomial

variable [IsDomain A]

section IsIntegralClosure

/-! ### `is_integral_closure` section

We show that an integral closure of a Dedekind domain in a finite separable
field extension is again a Dedekind domain. This implies the ring of integers
of a number field is a Dedekind domain. -/


open Algebra

open scoped BigOperators

variable (A K) [Algebra A K] [IsFractionRing A K]

variable (L : Type _) [Field L] (C : Type _) [CommRing C]

variable [Algebra K L] [Algebra A L] [IsScalarTower A K L]

variable [Algebra C L] [IsIntegralClosure C A L] [Algebra A C] [IsScalarTower A C L]

#print IsIntegralClosure.isLocalization /-
/- If `L` is a separable extension of `K = Frac(A)` and `L` has no zero smul divisors by `A`,
then `L` is the localization of the integral closure `C` of `A` in `L` at `A⁰`. -/
theorem IsIntegralClosure.isLocalization [IsSeparable K L] [NoZeroSMulDivisors A L] :
    IsLocalization (Algebra.algebraMapSubmonoid C A⁰) L :=
  by
  haveI : IsDomain C :=
    (IsIntegralClosure.equiv A C L (integralClosure A L)).toRingEquiv.IsDomain (integralClosure A L)
  haveI : NoZeroSMulDivisors A C := IsIntegralClosure.noZeroSMulDivisors A L
  refine' ⟨_, fun z => _, fun x y => ⟨fun h => ⟨1, _⟩, _⟩⟩
  · rintro ⟨_, x, hx, rfl⟩
    rw [isUnit_iff_ne_zero, map_ne_zero_iff _ (IsIntegralClosure.algebraMap_injective C A L),
      Subtype.coe_mk, map_ne_zero_iff _ (NoZeroSMulDivisors.algebraMap_injective A C)]
    exact mem_non_zero_divisors_iff_ne_zero.mp hx
  · obtain ⟨m, hm⟩ :=
      IsIntegral.exists_multiple_integral_of_isLocalization A⁰ z (IsSeparable.isIntegral K z)
    obtain ⟨x, hx⟩ : ∃ x, algebraMap C L x = m • z := is_integral_closure.is_integral_iff.mp hm
    refine' ⟨⟨x, algebraMap A C m, m, SetLike.coe_mem m, rfl⟩, _⟩
    rw [Subtype.coe_mk, ← IsScalarTower.algebraMap_apply, hx, mul_comm, Submonoid.smul_def,
      smul_def]
  · simp only [IsIntegralClosure.algebraMap_injective C A L h]
  · rintro ⟨⟨_, m, hm, rfl⟩, h⟩
    refine' congr_arg (algebraMap C L) ((mul_right_inj' _).mp h)
    rw [Subtype.coe_mk, map_ne_zero_iff _ (NoZeroSMulDivisors.algebraMap_injective A C)]
    exact mem_non_zero_divisors_iff_ne_zero.mp hm
#align is_integral_closure.is_localization IsIntegralClosure.isLocalization
-/

variable [FiniteDimensional K L]

variable {A K L}

#print IsIntegralClosure.range_le_span_dualBasis /-
theorem IsIntegralClosure.range_le_span_dualBasis [IsSeparable K L] {ι : Type _} [Fintype ι]
    [DecidableEq ι] (b : Basis ι K L) (hb_int : ∀ i, IsIntegral A (b i)) [IsIntegrallyClosed A] :
    ((Algebra.linearMap C L).restrictScalars A).range ≤
      Submodule.span A (Set.range <| (traceForm K L).dualBasis (traceForm_nondegenerate K L) b) :=
  by
  let db := (trace_form K L).dualBasis (traceForm_nondegenerate K L) b
  rintro _ ⟨x, rfl⟩
  simp only [LinearMap.coe_restrictScalars, Algebra.linearMap_apply]
  have hx : IsIntegral A (algebraMap C L x) := (IsIntegralClosure.isIntegral A L x).algebraMap
  rsuffices ⟨c, x_eq⟩ : ∃ c : ι → A, algebraMap C L x = ∑ i, c i • db i
  · rw [x_eq]
    refine' Submodule.sum_mem _ fun i _ => Submodule.smul_mem _ _ (Submodule.subset_span _)
    rw [Set.mem_range]
    exact ⟨i, rfl⟩
  suffices ∃ c : ι → K, (∀ i, IsIntegral A (c i)) ∧ algebraMap C L x = ∑ i, c i • db i
    by
    obtain ⟨c, hc, hx⟩ := this
    have hc' : ∀ i, IsLocalization.IsInteger A (c i) := fun i =>
      is_integrally_closed.is_integral_iff.mp (hc i)
    use fun i => Classical.choose (hc' i)
    refine' hx.trans (Finset.sum_congr rfl fun i _ => _)
    conv_lhs => rw [← Classical.choose_spec (hc' i)]
    rw [← IsScalarTower.algebraMap_smul K (Classical.choose (hc' i)) (db i)]
  refine' ⟨fun i => db.repr (algebraMap C L x) i, fun i => _, (db.sum_repr _).symm⟩
  rw [BilinForm.dualBasis_repr_apply]
  exact is_integral_trace (isIntegral_mul hx (hb_int i))
#align is_integral_closure.range_le_span_dual_basis IsIntegralClosure.range_le_span_dualBasis
-/

#print integralClosure_le_span_dualBasis /-
theorem integralClosure_le_span_dualBasis [IsSeparable K L] {ι : Type _} [Fintype ι] [DecidableEq ι]
    (b : Basis ι K L) (hb_int : ∀ i, IsIntegral A (b i)) [IsIntegrallyClosed A] :
    (integralClosure A L).toSubmodule ≤
      Submodule.span A (Set.range <| (traceForm K L).dualBasis (traceForm_nondegenerate K L) b) :=
  by
  refine' le_trans _ (IsIntegralClosure.range_le_span_dualBasis (integralClosure A L) b hb_int)
  intro x hx
  exact ⟨⟨x, hx⟩, rfl⟩
#align integral_closure_le_span_dual_basis integralClosure_le_span_dualBasis
-/

variable (A) (K)

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (y «expr ≠ » (0 : A)) -/
#print exists_integral_multiples /-
/-- Send a set of `x`'es in a finite extension `L` of the fraction field of `R`
to `(y : R) • x ∈ integral_closure R L`. -/
theorem exists_integral_multiples (s : Finset L) :
    ∃ (y : _) (_ : y ≠ (0 : A)), ∀ x ∈ s, IsIntegral A (y • x) :=
  by
  haveI := Classical.decEq L
  refine' s.induction _ _
  · use 1, one_ne_zero
    rintro x ⟨⟩
  · rintro x s hx ⟨y, hy, hs⟩
    obtain ⟨x', y', hy', hx'⟩ :=
      exists_integral_multiple
        ((IsFractionRing.isAlgebraic_iff A K L).mpr (is_algebraic_of_finite _ _ x))
        ((injective_iff_map_eq_zero (algebraMap A L)).mp _)
    refine' ⟨y * y', mul_ne_zero hy hy', fun x'' hx'' => _⟩
    rcases finset.mem_insert.mp hx'' with (rfl | hx'')
    · rw [mul_smul, Algebra.smul_def, Algebra.smul_def, mul_comm _ x'', hx']
      exact isIntegral_mul isIntegral_algebraMap x'.2
    · rw [mul_comm, mul_smul, Algebra.smul_def]
      exact isIntegral_mul isIntegral_algebraMap (hs _ hx'')
    · rw [IsScalarTower.algebraMap_eq A K L]
      apply (algebraMap K L).Injective.comp
      exact IsFractionRing.injective _ _
#align exists_integral_multiples exists_integral_multiples
-/

variable (L)

#print FiniteDimensional.exists_is_basis_integral /-
/-- If `L` is a finite extension of `K = Frac(A)`,
then `L` has a basis over `A` consisting of integral elements. -/
theorem FiniteDimensional.exists_is_basis_integral :
    ∃ (s : Finset L) (b : Basis s K L), ∀ x, IsIntegral A (b x) :=
  by
  letI := Classical.decEq L
  letI : IsNoetherian K L := IsNoetherian.iff_fg.2 inferInstance
  let s' := IsNoetherian.finsetBasisIndex K L
  let bs' := IsNoetherian.finsetBasis K L
  obtain ⟨y, hy, his'⟩ := exists_integral_multiples A K (finset.univ.image bs')
  have hy' : algebraMap A L y ≠ 0 :=
    by
    refine' mt ((injective_iff_map_eq_zero (algebraMap A L)).mp _ _) hy
    rw [IsScalarTower.algebraMap_eq A K L]
    exact (algebraMap K L).Injective.comp (IsFractionRing.injective A K)
  refine'
    ⟨s',
      bs'.map
        {
          Algebra.lmul _ _
            (algebraMap A L y) with
          toFun := fun x => algebraMap A L y * x
          invFun := fun x => (algebraMap A L y)⁻¹ * x
          left_inv := _
          right_inv := _ },
      _⟩
  · intro x; simp only [inv_mul_cancel_left₀ hy']
  · intro x; simp only [mul_inv_cancel_left₀ hy']
  · rintro ⟨x', hx'⟩
    simp only [Algebra.smul_def, Finset.mem_image, exists_prop, Finset.mem_univ, true_and_iff] at
      his' 
    simp only [Basis.map_apply, LinearEquiv.coe_mk]
    exact his' _ ⟨_, rfl⟩
#align finite_dimensional.exists_is_basis_integral FiniteDimensional.exists_is_basis_integral
-/

variable (A K L) [IsSeparable K L]

#print IsIntegralClosure.isNoetherian /-
/- If `L` is a finite separable extension of `K = Frac(A)`, where `A` is
integrally closed and Noetherian, the integral closure `C` of `A` in `L` is
Noetherian over `A`. -/
theorem IsIntegralClosure.isNoetherian [IsIntegrallyClosed A] [IsNoetherianRing A] :
    IsNoetherian A C := by
  haveI := Classical.decEq L
  obtain ⟨s, b, hb_int⟩ := FiniteDimensional.exists_is_basis_integral A K L
  let b' := (trace_form K L).dualBasis (traceForm_nondegenerate K L) b
  letI := isNoetherian_span_of_finite A (Set.finite_range b')
  let f : C →ₗ[A] Submodule.span A (Set.range b') :=
    (Submodule.ofLe (IsIntegralClosure.range_le_span_dualBasis C b hb_int)).comp
      ((Algebra.linearMap C L).restrictScalars A).range_restrict
  refine' isNoetherian_of_ker_bot f _
  rw [LinearMap.ker_comp, Submodule.ker_ofLe, Submodule.comap_bot, LinearMap.ker_codRestrict]
  exact LinearMap.ker_eq_bot_of_injective (IsIntegralClosure.algebraMap_injective C A L)
#align is_integral_closure.is_noetherian IsIntegralClosure.isNoetherian
-/

#print IsIntegralClosure.isNoetherianRing /-
/- If `L` is a finite separable extension of `K = Frac(A)`, where `A` is
integrally closed and Noetherian, the integral closure `C` of `A` in `L` is
Noetherian. -/
theorem IsIntegralClosure.isNoetherianRing [IsIntegrallyClosed A] [IsNoetherianRing A] :
    IsNoetherianRing C :=
  isNoetherianRing_iff.mpr <| isNoetherian_of_tower A (IsIntegralClosure.isNoetherian A K L C)
#align is_integral_closure.is_noetherian_ring IsIntegralClosure.isNoetherianRing
-/

#print IsIntegralClosure.module_free /-
/- If `L` is a finite separable extension of `K = Frac(A)`, where `A` is a principal ring
and `L` has no zero smul divisors by `A`, the integral closure `C` of `A` in `L` is
a free `A`-module. -/
theorem IsIntegralClosure.module_free [NoZeroSMulDivisors A L] [IsPrincipalIdealRing A] :
    Module.Free A C :=
  by
  haveI : NoZeroSMulDivisors A C := IsIntegralClosure.noZeroSMulDivisors A L
  haveI : IsNoetherian A C := IsIntegralClosure.isNoetherian A K L _
  exact Module.free_of_finite_type_torsion_free'
#align is_integral_closure.module_free IsIntegralClosure.module_free
-/

#print IsIntegralClosure.rank /-
/- If `L` is a finite separable extension of `K = Frac(A)`, where `A` is a principal ring
and `L` has no zero smul divisors by `A`, the `A`-rank of the integral closure `C` of `A` in `L`
is equal to the `K`-rank of `L`. -/
theorem IsIntegralClosure.rank [IsPrincipalIdealRing A] [NoZeroSMulDivisors A L] :
    FiniteDimensional.finrank A C = FiniteDimensional.finrank K L :=
  by
  haveI : Module.Free A C := IsIntegralClosure.module_free A K L C
  haveI : IsNoetherian A C := IsIntegralClosure.isNoetherian A K L C
  haveI : IsLocalization (Algebra.algebraMapSubmonoid C A⁰) L :=
    IsIntegralClosure.isLocalization A K L C
  let b := Basis.localizationLocalization K A⁰ L (Module.Free.chooseBasis A C)
  rw [FiniteDimensional.finrank_eq_card_chooseBasisIndex, FiniteDimensional.finrank_eq_card_basis b]
#align is_integral_closure.rank IsIntegralClosure.rank
-/

variable {A K}

#print integralClosure.isNoetherianRing /-
/- If `L` is a finite separable extension of `K = Frac(A)`, where `A` is
integrally closed and Noetherian, the integral closure of `A` in `L` is
Noetherian. -/
theorem integralClosure.isNoetherianRing [IsIntegrallyClosed A] [IsNoetherianRing A] :
    IsNoetherianRing (integralClosure A L) :=
  IsIntegralClosure.isNoetherianRing A K L (integralClosure A L)
#align integral_closure.is_noetherian_ring integralClosure.isNoetherianRing
-/

variable (A K) [IsDomain C]

#print IsIntegralClosure.isDedekindDomain /-
/- If `L` is a finite separable extension of `K = Frac(A)`, where `A` is a Dedekind domain,
the integral closure `C` of `A` in `L` is a Dedekind domain.

Can't be an instance since `A`, `K` or `L` can't be inferred. See also the instance
`integral_closure.is_dedekind_domain_fraction_ring` where `K := fraction_ring A`
and `C := integral_closure A L`.
-/
theorem IsIntegralClosure.isDedekindDomain [h : IsDedekindDomain A] : IsDedekindDomain C :=
  haveI : IsFractionRing C L := IsIntegralClosure.isFractionRing_of_finite_extension A K L C
  ⟨IsIntegralClosure.isNoetherianRing A K L C, h.dimension_le_one.is_integral_closure _ L _,
    (isIntegrallyClosed_iff L).mpr fun x hx =>
      ⟨IsIntegralClosure.mk' C x (isIntegral_trans (IsIntegralClosure.isIntegral_algebra A L) _ hx),
        IsIntegralClosure.algebraMap_mk' _ _ _⟩⟩
#align is_integral_closure.is_dedekind_domain IsIntegralClosure.isDedekindDomain
-/

#print integralClosure.isDedekindDomain /-
/- If `L` is a finite separable extension of `K = Frac(A)`, where `A` is a Dedekind domain,
the integral closure of `A` in `L` is a Dedekind domain.

Can't be an instance since `K` can't be inferred. See also the instance
`integral_closure.is_dedekind_domain_fraction_ring` where `K := fraction_ring A`.
-/
theorem integralClosure.isDedekindDomain [h : IsDedekindDomain A] :
    IsDedekindDomain (integralClosure A L) :=
  IsIntegralClosure.isDedekindDomain A K L (integralClosure A L)
#align integral_closure.is_dedekind_domain integralClosure.isDedekindDomain
-/

variable [Algebra (FractionRing A) L] [IsScalarTower A (FractionRing A) L]

variable [FiniteDimensional (FractionRing A) L] [IsSeparable (FractionRing A) L]

#print integralClosure.isDedekindDomain_fractionRing /-
/- If `L` is a finite separable extension of `Frac(A)`, where `A` is a Dedekind domain,
the integral closure of `A` in `L` is a Dedekind domain.

See also the lemma `integral_closure.is_dedekind_domain` where you can choose
the field of fractions yourself.
-/
instance integralClosure.isDedekindDomain_fractionRing [IsDedekindDomain A] :
    IsDedekindDomain (integralClosure A L) :=
  integralClosure.isDedekindDomain A (FractionRing A) L
#align integral_closure.is_dedekind_domain_fraction_ring integralClosure.isDedekindDomain_fractionRing
-/

end IsIntegralClosure

