/-
Copyright (c) 2021 Oliver Nash. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Oliver Nash

! This file was ported from Lean 3 source module algebra.lie.nilpotent
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Lie.Solvable
import Mathbin.Algebra.Lie.Quotient
import Mathbin.Algebra.Lie.Centralizer
import Mathbin.LinearAlgebra.Eigenspace
import Mathbin.RingTheory.Nilpotent

/-!
# Nilpotent Lie algebras

Like groups, Lie algebras admit a natural concept of nilpotency. More generally, any Lie module
carries a natural concept of nilpotency. We define these here via the lower central series.

## Main definitions

  * `lie_module.lower_central_series`
  * `lie_module.is_nilpotent`

## Tags

lie algebra, lower central series, nilpotent
-/


universe u v w w₁ w₂

section NilpotentModules

variable {R : Type u} {L : Type v} {M : Type w}

variable [CommRing R] [LieRing L] [LieAlgebra R L] [AddCommGroup M] [Module R M]

variable [LieRingModule L M] [LieModule R L M]

variable (k : ℕ) (N : LieSubmodule R L M)

namespace LieSubmodule

/-- A generalisation of the lower central series. The zeroth term is a specified Lie submodule of
a Lie module. In the case when we specify the top ideal `⊤` of the Lie algebra, regarded as a Lie
module over itself, we get the usual lower central series of a Lie algebra.

It can be more convenient to work with this generalisation when considering the lower central series
of a Lie submodule, regarded as a Lie module in its own right, since it provides a type-theoretic
expression of the fact that the terms of the Lie submodule's lower central series are also Lie
submodules of the enclosing Lie module.

See also `lie_module.lower_central_series_eq_lcs_comap` and
`lie_module.lower_central_series_map_eq_lcs` below, as well as `lie_submodule.ucs`. -/
def lcs : LieSubmodule R L M → LieSubmodule R L M :=
  (fun N => ⁅(⊤ : LieIdeal R L), N⁆)^[k]
#align lie_submodule.lcs LieSubmodule.lcs

@[simp]
theorem lcs_zero (N : LieSubmodule R L M) : N.lcs 0 = N :=
  rfl
#align lie_submodule.lcs_zero LieSubmodule.lcs_zero

@[simp]
theorem lcs_succ : N.lcs (k + 1) = ⁅(⊤ : LieIdeal R L), N.lcs k⁆ :=
  Function.iterate_succ_apply' (fun N' => ⁅⊤, N'⁆) k N
#align lie_submodule.lcs_succ LieSubmodule.lcs_succ

end LieSubmodule

namespace LieModule

variable (R L M)

/-- The lower central series of Lie submodules of a Lie module. -/
def lowerCentralSeries : LieSubmodule R L M :=
  (⊤ : LieSubmodule R L M).lcs k
#align lie_module.lower_central_series LieModule.lowerCentralSeries

@[simp]
theorem lower_central_series_zero : lowerCentralSeries R L M 0 = ⊤ :=
  rfl
#align lie_module.lower_central_series_zero LieModule.lower_central_series_zero

@[simp]
theorem lower_central_series_succ :
    lowerCentralSeries R L M (k + 1) = ⁅(⊤ : LieIdeal R L), lowerCentralSeries R L M k⁆ :=
  (⊤ : LieSubmodule R L M).lcs_succ k
#align lie_module.lower_central_series_succ LieModule.lower_central_series_succ

end LieModule

namespace LieSubmodule

open LieModule

variable {R L M}

theorem lcs_le_self : N.lcs k ≤ N := by
  induction' k with k ih
  · simp
  · simp only [lcs_succ]
    exact (LieSubmodule.mono_lie_right _ _ ⊤ ih).trans (N.lie_le_right ⊤)
#align lie_submodule.lcs_le_self LieSubmodule.lcs_le_self

theorem lower_central_series_eq_lcs_comap : lowerCentralSeries R L N k = (N.lcs k).comap N.incl :=
  by
  induction' k with k ih
  · simp
  · simp only [lcs_succ, lower_central_series_succ] at ih⊢
    have : N.lcs k ≤ N.incl.range := by
      rw [N.range_incl]
      apply lcs_le_self
    rw [ih, LieSubmodule.comap_bracket_eq _ _ N.incl N.ker_incl this]
#align
  lie_submodule.lower_central_series_eq_lcs_comap LieSubmodule.lower_central_series_eq_lcs_comap

theorem lower_central_series_map_eq_lcs : (lowerCentralSeries R L N k).map N.incl = N.lcs k :=
  by
  rw [lower_central_series_eq_lcs_comap, LieSubmodule.map_comap_incl, inf_eq_right]
  apply lcs_le_self
#align lie_submodule.lower_central_series_map_eq_lcs LieSubmodule.lower_central_series_map_eq_lcs

end LieSubmodule

namespace LieModule

variable (R L M)

theorem antitone_lower_central_series : Antitone <| lowerCentralSeries R L M :=
  by
  intro l k
  induction' k with k ih generalizing l <;> intro h
  · exact (le_zero_iff.mp h).symm ▸ le_rfl
  · rcases Nat.of_le_succ h with (hk | hk)
    · rw [lower_central_series_succ]
      exact (LieSubmodule.mono_lie_right _ _ ⊤ (ih hk)).trans (LieSubmodule.lie_le_right _ _)
    · exact hk.symm ▸ le_rfl
#align lie_module.antitone_lower_central_series LieModule.antitone_lower_central_series

theorem trivial_iff_lower_central_eq_bot : IsTrivial L M ↔ lowerCentralSeries R L M 1 = ⊥ :=
  by
  constructor <;> intro h
  · erw [eq_bot_iff, LieSubmodule.lie_span_le]
    rintro m ⟨x, n, hn⟩
    rw [← hn, h.trivial]
    simp
  · rw [LieSubmodule.eq_bot_iff] at h
    apply is_trivial.mk
    intro x m
    apply h
    apply LieSubmodule.subset_lie_span
    use x, m
    rfl
#align lie_module.trivial_iff_lower_central_eq_bot LieModule.trivial_iff_lower_central_eq_bot

theorem iterate_to_endomorphism_mem_lower_central_series (x : L) (m : M) (k : ℕ) :
    (toEndomorphism R L M x^[k]) m ∈ lowerCentralSeries R L M k :=
  by
  induction' k with k ih
  · simp only [Function.iterate_zero]
  · simp only [lower_central_series_succ, Function.comp_apply, Function.iterate_succ',
      to_endomorphism_apply_apply]
    exact LieSubmodule.lie_mem_lie _ _ (LieSubmodule.mem_top x) ih
#align
  lie_module.iterate_to_endomorphism_mem_lower_central_series LieModule.iterate_to_endomorphism_mem_lower_central_series

variable {R L M}

theorem map_lower_central_series_le {M₂ : Type w₁} [AddCommGroup M₂] [Module R M₂]
    [LieRingModule L M₂] [LieModule R L M₂] (k : ℕ) (f : M →ₗ⁅R,L⁆ M₂) :
    LieSubmodule.map f (lowerCentralSeries R L M k) ≤ lowerCentralSeries R L M₂ k :=
  by
  induction' k with k ih
  · simp only [LieModule.lower_central_series_zero, le_top]
  · simp only [LieModule.lower_central_series_succ, LieSubmodule.map_bracket_eq]
    exact LieSubmodule.mono_lie_right _ _ ⊤ ih
#align lie_module.map_lower_central_series_le LieModule.map_lower_central_series_le

variable (R L M)

open LieAlgebra

theorem derived_series_le_lower_central_series (k : ℕ) :
    derivedSeries R L k ≤ lowerCentralSeries R L L k :=
  by
  induction' k with k h
  · rw [derived_series_def, derived_series_of_ideal_zero, lower_central_series_zero]
    exact le_rfl
  · have h' : derived_series R L k ≤ ⊤ := by simp only [le_top]
    rw [derived_series_def, derived_series_of_ideal_succ, lower_central_series_succ]
    exact LieSubmodule.mono_lie _ _ _ _ h' h
#align
  lie_module.derived_series_le_lower_central_series LieModule.derived_series_le_lower_central_series

/-- A Lie module is nilpotent if its lower central series reaches 0 (in a finite number of
steps). -/
class IsNilpotent : Prop where
  nilpotent : ∃ k, lowerCentralSeries R L M k = ⊥
#align lie_module.is_nilpotent LieModule.IsNilpotent

/-- See also `lie_module.is_nilpotent_iff_exists_ucs_eq_top`. -/
theorem is_nilpotent_iff : IsNilpotent R L M ↔ ∃ k, lowerCentralSeries R L M k = ⊥ :=
  ⟨fun h => h.nilpotent, fun h => ⟨h⟩⟩
#align lie_module.is_nilpotent_iff LieModule.is_nilpotent_iff

variable {R L M}

theorem LieSubmodule.is_nilpotent_iff_exists_lcs_eq_bot (N : LieSubmodule R L M) :
    LieModule.IsNilpotent R L N ↔ ∃ k, N.lcs k = ⊥ :=
  by
  rw [is_nilpotent_iff]
  refine' exists_congr fun k => _
  rw [N.lower_central_series_eq_lcs_comap k, LieSubmodule.comap_incl_eq_bot,
    inf_eq_right.mpr (N.lcs_le_self k)]
#align
  lie_submodule.is_nilpotent_iff_exists_lcs_eq_bot LieSubmodule.is_nilpotent_iff_exists_lcs_eq_bot

variable (R L M)

instance (priority := 100) trivialIsNilpotent [IsTrivial L M] : IsNilpotent R L M :=
  ⟨by
    use 1
    change ⁅⊤, ⊤⁆ = ⊥
    simp⟩
#align lie_module.trivial_is_nilpotent LieModule.trivialIsNilpotent

theorem nilpotent_endo_of_nilpotent_module [hM : IsNilpotent R L M] :
    ∃ k : ℕ, ∀ x : L, toEndomorphism R L M x ^ k = 0 :=
  by
  obtain ⟨k, hM⟩ := hM
  use k
  intro x; ext m
  rw [LinearMap.pow_apply, LinearMap.zero_apply, ← @LieSubmodule.mem_bot R L M, ← hM]
  exact iterate_to_endomorphism_mem_lower_central_series R L M x m k
#align lie_module.nilpotent_endo_of_nilpotent_module LieModule.nilpotent_endo_of_nilpotent_module

/-- For a nilpotent Lie module, the weight space of the 0 weight is the whole module.

This result will be used downstream to show that weight spaces are Lie submodules, at which time
it will be possible to state it in the language of weight spaces. -/
theorem infi_max_gen_zero_eigenspace_eq_top_of_nilpotent [IsNilpotent R L M] :
    (⨅ x : L, (toEndomorphism R L M x).maximalGeneralizedEigenspace 0) = ⊤ :=
  by
  ext m
  simp only [Module.EndCat.mem_maximal_generalized_eigenspace, Submodule.mem_top, sub_zero,
    iff_true_iff, zero_smul, Submodule.mem_infi]
  intro x
  obtain ⟨k, hk⟩ := nilpotent_endo_of_nilpotent_module R L M
  use k; rw [hk]
  exact LinearMap.zero_apply m
#align
  lie_module.infi_max_gen_zero_eigenspace_eq_top_of_nilpotent LieModule.infi_max_gen_zero_eigenspace_eq_top_of_nilpotent

/-- If the quotient of a Lie module `M` by a Lie submodule on which the Lie algebra acts trivially
is nilpotent then `M` is nilpotent.

This is essentially the Lie module equivalent of the fact that a central
extension of nilpotent Lie algebras is nilpotent. See `lie_algebra.nilpotent_of_nilpotent_quotient`
below for the corresponding result for Lie algebras. -/
theorem nilpotentOfNilpotentQuotient {N : LieSubmodule R L M} (h₁ : N ≤ maxTrivSubmodule R L M)
    (h₂ : IsNilpotent R L (M ⧸ N)) : IsNilpotent R L M :=
  by
  obtain ⟨k, hk⟩ := h₂
  use k + 1
  simp only [lower_central_series_succ]
  suffices lower_central_series R L M k ≤ N
    by
    replace this := LieSubmodule.mono_lie_right _ _ ⊤ (le_trans this h₁)
    rwa [ideal_oper_max_triv_submodule_eq_bot, le_bot_iff] at this
  rw [← LieSubmodule.Quotient.map_mk'_eq_bot_le, ← le_bot_iff, ← hk]
  exact map_lower_central_series_le k (LieSubmodule.Quotient.mk' N)
#align lie_module.nilpotent_of_nilpotent_quotient LieModule.nilpotentOfNilpotentQuotient

/-- Given a nilpotent Lie module `M` with lower central series `M = C₀ ≥ C₁ ≥ ⋯ ≥ Cₖ = ⊥`, this is
the natural number `k` (the number of inclusions).

For a non-nilpotent module, we use the junk value 0. -/
noncomputable def nilpotencyLength : ℕ :=
  infₛ { k | lowerCentralSeries R L M k = ⊥ }
#align lie_module.nilpotency_length LieModule.nilpotencyLength

theorem nilpotency_length_eq_zero_iff [IsNilpotent R L M] :
    nilpotencyLength R L M = 0 ↔ Subsingleton M :=
  by
  let s := { k | lower_central_series R L M k = ⊥ }
  have hs : s.nonempty :=
    by
    obtain ⟨k, hk⟩ := (by infer_instance : IsNilpotent R L M)
    exact ⟨k, hk⟩
  change Inf s = 0 ↔ _
  rw [← LieSubmodule.subsingleton_iff R L M, ← subsingleton_iff_bot_eq_top, ←
    lower_central_series_zero, @eq_comm (LieSubmodule R L M)]
  refine' ⟨fun h => h ▸ Nat.Inf_mem hs, fun h => _⟩
  rw [Nat.Inf_eq_zero]
  exact Or.inl h
#align lie_module.nilpotency_length_eq_zero_iff LieModule.nilpotency_length_eq_zero_iff

theorem nilpotency_length_eq_succ_iff (k : ℕ) :
    nilpotencyLength R L M = k + 1 ↔
      lowerCentralSeries R L M (k + 1) = ⊥ ∧ lowerCentralSeries R L M k ≠ ⊥ :=
  by
  let s := { k | lower_central_series R L M k = ⊥ }
  change Inf s = k + 1 ↔ k + 1 ∈ s ∧ k ∉ s
  have hs : ∀ k₁ k₂, k₁ ≤ k₂ → k₁ ∈ s → k₂ ∈ s :=
    by
    rintro k₁ k₂ h₁₂ (h₁ : lower_central_series R L M k₁ = ⊥)
    exact eq_bot_iff.mpr (h₁ ▸ antitone_lower_central_series R L M h₁₂)
  exact Nat.Inf_upward_closed_eq_succ_iff hs k
#align lie_module.nilpotency_length_eq_succ_iff LieModule.nilpotency_length_eq_succ_iff

/-- Given a non-trivial nilpotent Lie module `M` with lower central series
`M = C₀ ≥ C₁ ≥ ⋯ ≥ Cₖ = ⊥`, this is the `k-1`th term in the lower central series (the last
non-trivial term).

For a trivial or non-nilpotent module, this is the bottom submodule, `⊥`. -/
noncomputable def lowerCentralSeriesLast : LieSubmodule R L M :=
  match nilpotencyLength R L M with
  | 0 => ⊥
  | k + 1 => lowerCentralSeries R L M k
#align lie_module.lower_central_series_last LieModule.lowerCentralSeriesLast

theorem lower_central_series_last_le_max_triv :
    lowerCentralSeriesLast R L M ≤ maxTrivSubmodule R L M :=
  by
  rw [lower_central_series_last]
  cases' h : nilpotency_length R L M with k
  · exact bot_le
  · rw [le_max_triv_iff_bracket_eq_bot]
    rw [nilpotency_length_eq_succ_iff, lower_central_series_succ] at h
    exact h.1
#align
  lie_module.lower_central_series_last_le_max_triv LieModule.lower_central_series_last_le_max_triv

theorem nontrivial_lower_central_series_last [Nontrivial M] [IsNilpotent R L M] :
    Nontrivial (lowerCentralSeriesLast R L M) :=
  by
  rw [LieSubmodule.nontrivial_iff_ne_bot, lower_central_series_last]
  cases h : nilpotency_length R L M
  · rw [nilpotency_length_eq_zero_iff, ← not_nontrivial_iff_subsingleton] at h
    contradiction
  · rw [nilpotency_length_eq_succ_iff] at h
    exact h.2
#align
  lie_module.nontrivial_lower_central_series_last LieModule.nontrivial_lower_central_series_last

theorem nontrivial_max_triv_of_is_nilpotent [Nontrivial M] [IsNilpotent R L M] :
    Nontrivial (maxTrivSubmodule R L M) :=
  Set.nontrivial_mono (lower_central_series_last_le_max_triv R L M)
    (nontrivial_lower_central_series_last R L M)
#align lie_module.nontrivial_max_triv_of_is_nilpotent LieModule.nontrivial_max_triv_of_is_nilpotent

@[simp]
theorem coe_lcs_range_to_endomorphism_eq (k : ℕ) :
    (lowerCentralSeries R (toEndomorphism R L M).range M k : Submodule R M) =
      lowerCentralSeries R L M k :=
  by
  induction' k with k ih
  · simp
  · simp only [lower_central_series_succ, LieSubmodule.lie_ideal_oper_eq_linear_span', ←
      (lower_central_series R (to_endomorphism R L M).range M k).mem_coe_submodule, ih]
    congr
    ext m
    constructor
    · rintro ⟨⟨-, ⟨y, rfl⟩⟩, -, n, hn, rfl⟩
      exact ⟨y, LieSubmodule.mem_top _, n, hn, rfl⟩
    · rintro ⟨x, hx, n, hn, rfl⟩
      exact
        ⟨⟨to_endomorphism R L M x, LieHom.mem_range_self _ x⟩, LieSubmodule.mem_top _, n, hn, rfl⟩
#align lie_module.coe_lcs_range_to_endomorphism_eq LieModule.coe_lcs_range_to_endomorphism_eq

@[simp]
theorem is_nilpotent_range_to_endomorphism_iff :
    IsNilpotent R (toEndomorphism R L M).range M ↔ IsNilpotent R L M := by
  constructor <;> rintro ⟨k, hk⟩ <;> use k <;>
      rw [← LieSubmodule.coe_to_submodule_eq_iff] at hk⊢ <;>
    simpa using hk
#align
  lie_module.is_nilpotent_range_to_endomorphism_iff LieModule.is_nilpotent_range_to_endomorphism_iff

end LieModule

namespace LieSubmodule

variable {N₁ N₂ : LieSubmodule R L M}

/-- The upper (aka ascending) central series.

See also `lie_submodule.lcs`. -/
def ucs (k : ℕ) : LieSubmodule R L M → LieSubmodule R L M :=
  centralizer^[k]
#align lie_submodule.ucs LieSubmodule.ucs

@[simp]
theorem ucs_zero : N.ucs 0 = N :=
  rfl
#align lie_submodule.ucs_zero LieSubmodule.ucs_zero

@[simp]
theorem ucs_succ (k : ℕ) : N.ucs (k + 1) = (N.ucs k).centralizer :=
  Function.iterate_succ_apply' centralizer k N
#align lie_submodule.ucs_succ LieSubmodule.ucs_succ

theorem ucs_add (k l : ℕ) : N.ucs (k + l) = (N.ucs l).ucs k :=
  Function.iterate_add_apply centralizer k l N
#align lie_submodule.ucs_add LieSubmodule.ucs_add

@[mono]
theorem ucs_mono (k : ℕ) (h : N₁ ≤ N₂) : N₁.ucs k ≤ N₂.ucs k :=
  by
  induction' k with k ih; · simpa
  simp only [ucs_succ]
  mono
#align lie_submodule.ucs_mono LieSubmodule.ucs_mono

theorem ucs_eq_self_of_centralizer_eq_self (h : N₁.centralizer = N₁) (k : ℕ) : N₁.ucs k = N₁ :=
  by
  induction' k with k ih
  · simp
  · rwa [ucs_succ, ih]
#align
  lie_submodule.ucs_eq_self_of_centralizer_eq_self LieSubmodule.ucs_eq_self_of_centralizer_eq_self

/-- If a Lie module `M` contains a self-centralizing Lie submodule `N`, then all terms of the upper
central series of `M` are contained in `N`.

An important instance of this situation arises from a Cartan subalgebra `H ⊆ L` with the roles of
`L`, `M`, `N` played by `H`, `L`, `H`, respectively. -/
theorem ucs_le_of_centralizer_eq_self (h : N₁.centralizer = N₁) (k : ℕ) :
    (⊥ : LieSubmodule R L M).ucs k ≤ N₁ :=
  by
  rw [← ucs_eq_self_of_centralizer_eq_self h k]
  mono
  simp
#align lie_submodule.ucs_le_of_centralizer_eq_self LieSubmodule.ucs_le_of_centralizer_eq_self

theorem lcs_add_le_iff (l k : ℕ) : N₁.lcs (l + k) ≤ N₂ ↔ N₁.lcs l ≤ N₂.ucs k :=
  by
  revert l
  induction' k with k ih; · simp
  intro l
  rw [(by abel : l + (k + 1) = l + 1 + k), ih, ucs_succ, lcs_succ, top_lie_le_iff_le_centralizer]
#align lie_submodule.lcs_add_le_iff LieSubmodule.lcs_add_le_iff

theorem lcs_le_iff (k : ℕ) : N₁.lcs k ≤ N₂ ↔ N₁ ≤ N₂.ucs k :=
  by
  convert lcs_add_le_iff 0 k
  rw [zero_add]
#align lie_submodule.lcs_le_iff LieSubmodule.lcs_le_iff

theorem gc_lcs_ucs (k : ℕ) :
    GaloisConnection (fun N : LieSubmodule R L M => N.lcs k) fun N : LieSubmodule R L M =>
      N.ucs k :=
  fun N₁ N₂ => lcs_le_iff k
#align lie_submodule.gc_lcs_ucs LieSubmodule.gc_lcs_ucs

theorem ucs_eq_top_iff (k : ℕ) : N.ucs k = ⊤ ↔ LieModule.lowerCentralSeries R L M k ≤ N :=
  by
  rw [eq_top_iff, ← lcs_le_iff]
  rfl
#align lie_submodule.ucs_eq_top_iff LieSubmodule.ucs_eq_top_iff

theorem LieModule.is_nilpotent_iff_exists_ucs_eq_top :
    LieModule.IsNilpotent R L M ↔ ∃ k, (⊥ : LieSubmodule R L M).ucs k = ⊤ :=
  by
  rw [LieModule.is_nilpotent_iff]
  exact exists_congr fun k => by simp [ucs_eq_top_iff]
#align lie_module.is_nilpotent_iff_exists_ucs_eq_top LieModule.is_nilpotent_iff_exists_ucs_eq_top

theorem ucs_comap_incl (k : ℕ) :
    ((⊥ : LieSubmodule R L M).ucs k).comap N.incl = (⊥ : LieSubmodule R L N).ucs k :=
  by
  induction' k with k ih
  · exact N.ker_incl
  · simp [← ih]
#align lie_submodule.ucs_comap_incl LieSubmodule.ucs_comap_incl

theorem is_nilpotent_iff_exists_self_le_ucs :
    LieModule.IsNilpotent R L N ↔ ∃ k, N ≤ (⊥ : LieSubmodule R L M).ucs k := by
  simp_rw [LieModule.is_nilpotent_iff_exists_ucs_eq_top, ← ucs_comap_incl, comap_incl_eq_top]
#align
  lie_submodule.is_nilpotent_iff_exists_self_le_ucs LieSubmodule.is_nilpotent_iff_exists_self_le_ucs

end LieSubmodule

section Morphisms

open LieModule Function

variable {L₂ M₂ : Type _} [LieRing L₂] [LieAlgebra R L₂]

variable [AddCommGroup M₂] [Module R M₂] [LieRingModule L₂ M₂] [LieModule R L₂ M₂]

variable {f : L →ₗ⁅R⁆ L₂} {g : M →ₗ[R] M₂}

variable (hf : Surjective f) (hg : Surjective g) (hfg : ∀ x m, ⁅f x, g m⁆ = g ⁅x, m⁆)

include hf hg hfg

theorem Function.Surjective.lie_module_lcs_map_eq (k : ℕ) :
    (lowerCentralSeries R L M k : Submodule R M).map g = lowerCentralSeries R L₂ M₂ k :=
  by
  induction' k with k ih
  · simp [LinearMap.range_eq_top, hg]
  · suffices
      g '' { m | ∃ (x : L)(n : _), n ∈ lower_central_series R L M k ∧ ⁅x, n⁆ = m } =
        { m | ∃ (x : L₂)(n : _), n ∈ lower_central_series R L M k ∧ ⁅x, g n⁆ = m }
      by
      simp only [← LieSubmodule.mem_coe_submodule] at this
      simp [← LieSubmodule.mem_coe_submodule, ← ih, LieSubmodule.lie_ideal_oper_eq_linear_span',
        Submodule.map_span, -Submodule.span_image, this]
    ext m₂
    constructor
    · rintro ⟨m, ⟨x, n, hn, rfl⟩, rfl⟩
      exact ⟨f x, n, hn, hfg x n⟩
    · rintro ⟨x, n, hn, rfl⟩
      obtain ⟨y, rfl⟩ := hf x
      exact ⟨⁅y, n⁆, ⟨y, n, hn, rfl⟩, (hfg y n).symm⟩
#align function.surjective.lie_module_lcs_map_eq Function.Surjective.lie_module_lcs_map_eq

theorem Function.Surjective.lieModuleIsNilpotent [IsNilpotent R L M] : IsNilpotent R L₂ M₂ :=
  by
  obtain ⟨k, hk⟩ := id (by infer_instance : IsNilpotent R L M)
  use k
  rw [← LieSubmodule.coe_to_submodule_eq_iff] at hk⊢
  simp [← hf.lie_module_lcs_map_eq hg hfg k, hk]
#align function.surjective.lie_module_is_nilpotent Function.Surjective.lieModuleIsNilpotent

omit hf hg hfg

theorem Equiv.lie_module_is_nilpotent_iff (f : L ≃ₗ⁅R⁆ L₂) (g : M ≃ₗ[R] M₂)
    (hfg : ∀ x m, ⁅f x, g m⁆ = g ⁅x, m⁆) : IsNilpotent R L M ↔ IsNilpotent R L₂ M₂ :=
  by
  constructor <;> intro h
  · have hg : surjective (g : M →ₗ[R] M₂) := g.surjective
    exact f.surjective.lie_module_is_nilpotent hg hfg
  · have hg : surjective (g.symm : M₂ →ₗ[R] M) := g.symm.surjective
    refine' f.symm.surjective.lie_module_is_nilpotent hg fun x m => _
    rw [LinearEquiv.coe_coe, LieEquiv.coe_to_lie_hom, ← g.symm_apply_apply ⁅f.symm x, g.symm m⁆, ←
      hfg, f.apply_symm_apply, g.apply_symm_apply]
#align equiv.lie_module_is_nilpotent_iff Equiv.lie_module_is_nilpotent_iff

@[simp]
theorem LieModule.is_nilpotent_of_top_iff :
    IsNilpotent R (⊤ : LieSubalgebra R L) M ↔ IsNilpotent R L M :=
  Equiv.lie_module_is_nilpotent_iff LieSubalgebra.topEquiv (1 : M ≃ₗ[R] M) fun x m => rfl
#align lie_module.is_nilpotent_of_top_iff LieModule.is_nilpotent_of_top_iff

end Morphisms

end NilpotentModules

instance (priority := 100) LieAlgebra.isSolvableOfIsNilpotent (R : Type u) (L : Type v) [CommRing R]
    [LieRing L] [LieAlgebra R L] [hL : LieModule.IsNilpotent R L L] : LieAlgebra.IsSolvable R L :=
  by
  obtain ⟨k, h⟩ : ∃ k, LieModule.lowerCentralSeries R L L k = ⊥ := hL.nilpotent
  use k; rw [← le_bot_iff] at h⊢
  exact le_trans (LieModule.derived_series_le_lower_central_series R L k) h
#align lie_algebra.is_solvable_of_is_nilpotent LieAlgebra.isSolvableOfIsNilpotent

section NilpotentAlgebras

variable (R : Type u) (L : Type v) (L' : Type w)

variable [CommRing R] [LieRing L] [LieAlgebra R L] [LieRing L'] [LieAlgebra R L']

/-- We say a Lie algebra is nilpotent when it is nilpotent as a Lie module over itself via the
adjoint representation. -/
abbrev LieAlgebra.IsNilpotent (R : Type u) (L : Type v) [CommRing R] [LieRing L] [LieAlgebra R L] :
    Prop :=
  LieModule.IsNilpotent R L L
#align lie_algebra.is_nilpotent LieAlgebra.IsNilpotent

open LieAlgebra

theorem LieAlgebra.nilpotent_ad_of_nilpotent_algebra [IsNilpotent R L] :
    ∃ k : ℕ, ∀ x : L, ad R L x ^ k = 0 :=
  LieModule.nilpotent_endo_of_nilpotent_module R L L
#align lie_algebra.nilpotent_ad_of_nilpotent_algebra LieAlgebra.nilpotent_ad_of_nilpotent_algebra

/-- See also `lie_algebra.zero_root_space_eq_top_of_nilpotent`. -/
theorem LieAlgebra.infi_max_gen_zero_eigenspace_eq_top_of_nilpotent [IsNilpotent R L] :
    (⨅ x : L, (ad R L x).maximalGeneralizedEigenspace 0) = ⊤ :=
  LieModule.infi_max_gen_zero_eigenspace_eq_top_of_nilpotent R L L
#align
  lie_algebra.infi_max_gen_zero_eigenspace_eq_top_of_nilpotent LieAlgebra.infi_max_gen_zero_eigenspace_eq_top_of_nilpotent

-- TODO Generalise the below to Lie modules if / when we define morphisms, equivs of Lie modules
-- covering a Lie algebra morphism of (possibly different) Lie algebras.
variable {R L L'}

open LieModule (lowerCentralSeries)

/-- Given an ideal `I` of a Lie algebra `L`, the lower central series of `L ⧸ I` is the same
whether we regard `L ⧸ I` as an `L` module or an `L ⧸ I` module.

TODO: This result obviously generalises but the generalisation requires the missing definition of
morphisms between Lie modules over different Lie algebras. -/
theorem coe_lower_central_series_ideal_quot_eq {I : LieIdeal R L} (k : ℕ) :
    (lowerCentralSeries R L (L ⧸ I) k : Submodule R (L ⧸ I)) =
      lowerCentralSeries R (L ⧸ I) (L ⧸ I) k :=
  by
  induction' k with k ih
  · simp only [LieSubmodule.top_coe_submodule, LieModule.lower_central_series_zero]
  · simp only [LieModule.lower_central_series_succ, LieSubmodule.lie_ideal_oper_eq_linear_span]
    congr
    ext x
    constructor
    · rintro ⟨⟨y, -⟩, ⟨z, hz⟩, rfl : ⁅y, z⁆ = x⟩
      erw [← LieSubmodule.mem_coe_submodule, ih, LieSubmodule.mem_coe_submodule] at hz
      exact ⟨⟨LieSubmodule.Quotient.mk y, LieSubmodule.mem_top _⟩, ⟨z, hz⟩, rfl⟩
    · rintro ⟨⟨⟨y⟩, -⟩, ⟨z, hz⟩, rfl : ⁅y, z⁆ = x⟩
      erw [← LieSubmodule.mem_coe_submodule, ← ih, LieSubmodule.mem_coe_submodule] at hz
      exact ⟨⟨y, LieSubmodule.mem_top _⟩, ⟨z, hz⟩, rfl⟩
#align coe_lower_central_series_ideal_quot_eq coe_lower_central_series_ideal_quot_eq

/-- Note that the below inequality can be strict. For example the ideal of strictly-upper-triangular
2x2 matrices inside the Lie algebra of upper-triangular 2x2 matrices with `k = 1`. -/
theorem LieModule.coe_lower_central_series_ideal_le {I : LieIdeal R L} (k : ℕ) :
    (lowerCentralSeries R I I k : Submodule R I) ≤ lowerCentralSeries R L I k :=
  by
  induction' k with k ih
  · simp
  · simp only [LieModule.lower_central_series_succ, LieSubmodule.lie_ideal_oper_eq_linear_span]
    apply Submodule.span_mono
    rintro x ⟨⟨y, -⟩, ⟨z, hz⟩, rfl : ⁅y, z⁆ = x⟩
    exact ⟨⟨y.val, LieSubmodule.mem_top _⟩, ⟨z, ih hz⟩, rfl⟩
#align lie_module.coe_lower_central_series_ideal_le LieModule.coe_lower_central_series_ideal_le

/-- A central extension of nilpotent Lie algebras is nilpotent. -/
theorem LieAlgebra.nilpotent_of_nilpotent_quotient {I : LieIdeal R L} (h₁ : I ≤ center R L)
    (h₂ : IsNilpotent R (L ⧸ I)) : IsNilpotent R L :=
  by
  suffices LieModule.IsNilpotent R L (L ⧸ I) by
    exact LieModule.nilpotentOfNilpotentQuotient R L L h₁ this
  obtain ⟨k, hk⟩ := h₂
  use k
  simp [← LieSubmodule.coe_to_submodule_eq_iff, coe_lower_central_series_ideal_quot_eq, hk]
#align lie_algebra.nilpotent_of_nilpotent_quotient LieAlgebra.nilpotent_of_nilpotent_quotient

theorem LieAlgebra.non_trivial_center_of_is_nilpotent [Nontrivial L] [IsNilpotent R L] :
    Nontrivial <| center R L :=
  LieModule.nontrivial_max_triv_of_is_nilpotent R L L
#align lie_algebra.non_trivial_center_of_is_nilpotent LieAlgebra.non_trivial_center_of_is_nilpotent

theorem LieIdeal.map_lower_central_series_le (k : ℕ) {f : L →ₗ⁅R⁆ L'} :
    LieIdeal.map f (lowerCentralSeries R L L k) ≤ lowerCentralSeries R L' L' k :=
  by
  induction' k with k ih
  · simp only [LieModule.lower_central_series_zero, le_top]
  · simp only [LieModule.lower_central_series_succ]
    exact le_trans (LieIdeal.map_bracket_le f) (LieSubmodule.mono_lie _ _ _ _ le_top ih)
#align lie_ideal.map_lower_central_series_le LieIdeal.map_lower_central_series_le

theorem LieIdeal.lower_central_series_map_eq (k : ℕ) {f : L →ₗ⁅R⁆ L'} (h : Function.Surjective f) :
    LieIdeal.map f (lowerCentralSeries R L L k) = lowerCentralSeries R L' L' k :=
  by
  have h' : (⊤ : LieIdeal R L).map f = ⊤ :=
    by
    rw [← f.ideal_range_eq_map]
    exact f.ideal_range_eq_top_of_surjective h
  induction' k with k ih
  · simp only [LieModule.lower_central_series_zero]
    exact h'
  · simp only [LieModule.lower_central_series_succ, LieIdeal.map_bracket_eq f h, ih, h']
#align lie_ideal.lower_central_series_map_eq LieIdeal.lower_central_series_map_eq

theorem Function.Injective.lie_algebra_is_nilpotent [h₁ : IsNilpotent R L'] {f : L →ₗ⁅R⁆ L'}
    (h₂ : Function.Injective f) : IsNilpotent R L :=
  {
    nilpotent := by
      obtain ⟨k, hk⟩ := id h₁
      use k
      apply LieIdeal.bot_of_map_eq_bot h₂; rw [eq_bot_iff, ← hk]
      apply LieIdeal.map_lower_central_series_le }
#align function.injective.lie_algebra_is_nilpotent Function.Injective.lie_algebra_is_nilpotent

theorem Function.Surjective.lie_algebra_is_nilpotent [h₁ : IsNilpotent R L] {f : L →ₗ⁅R⁆ L'}
    (h₂ : Function.Surjective f) : IsNilpotent R L' :=
  {
    nilpotent := by
      obtain ⟨k, hk⟩ := id h₁
      use k
      rw [← LieIdeal.lower_central_series_map_eq k h₂, hk]
      simp only [LieIdeal.map_eq_bot_iff, bot_le] }
#align function.surjective.lie_algebra_is_nilpotent Function.Surjective.lie_algebra_is_nilpotent

theorem LieEquiv.nilpotent_iff_equiv_nilpotent (e : L ≃ₗ⁅R⁆ L') :
    IsNilpotent R L ↔ IsNilpotent R L' :=
  by
  constructor <;> intro h
  · exact e.symm.injective.lie_algebra_is_nilpotent
  · exact e.injective.lie_algebra_is_nilpotent
#align lie_equiv.nilpotent_iff_equiv_nilpotent LieEquiv.nilpotent_iff_equiv_nilpotent

theorem LieHom.is_nilpotent_range [IsNilpotent R L] (f : L →ₗ⁅R⁆ L') : IsNilpotent R f.range :=
  f.surjective_range_restrict.lie_algebra_is_nilpotent
#align lie_hom.is_nilpotent_range LieHom.is_nilpotent_range

/-- Note that this result is not quite a special case of
`lie_module.is_nilpotent_range_to_endomorphism_iff` which concerns nilpotency of the
`(ad R L).range`-module `L`, whereas this result concerns nilpotency of the `(ad R L).range`-module
`(ad R L).range`. -/
@[simp]
theorem LieAlgebra.is_nilpotent_range_ad_iff : IsNilpotent R (ad R L).range ↔ IsNilpotent R L :=
  by
  refine' ⟨fun h => _, _⟩
  · have : (ad R L).ker = center R L := by simp
    exact
      LieAlgebra.nilpotent_of_nilpotent_quotient (le_of_eq this)
        ((ad R L).quotKerEquivRange.nilpotent_iff_equiv_nilpotent.mpr h)
  · intro h
    exact (ad R L).is_nilpotent_range
#align lie_algebra.is_nilpotent_range_ad_iff LieAlgebra.is_nilpotent_range_ad_iff

instance [h : LieAlgebra.IsNilpotent R L] : LieAlgebra.IsNilpotent R (⊤ : LieSubalgebra R L) :=
  LieSubalgebra.topEquiv.nilpotent_iff_equiv_nilpotent.mpr h

end NilpotentAlgebras

namespace LieIdeal

open LieModule

variable {R L : Type _} [CommRing R] [LieRing L] [LieAlgebra R L] (I : LieIdeal R L)

variable (M : Type _) [AddCommGroup M] [Module R M] [LieRingModule L M] [LieModule R L M]

variable (k : ℕ)

/-- Given a Lie module `M` over a Lie algebra `L` together with an ideal `I` of `L`, this is the
lower central series of `M` as an `I`-module. The advantage of using this definition instead of
`lie_module.lower_central_series R I M` is that its terms are Lie submodules of `M` as an
`L`-module, rather than just as an `I`-module.

See also `lie_ideal.coe_lcs_eq`. -/
def lcs : LieSubmodule R L M :=
  ((fun N => ⁅I, N⁆)^[k]) ⊤
#align lie_ideal.lcs LieIdeal.lcs

@[simp]
theorem lcs_zero : I.lcs M 0 = ⊤ :=
  rfl
#align lie_ideal.lcs_zero LieIdeal.lcs_zero

@[simp]
theorem lcs_succ : I.lcs M (k + 1) = ⁅I, I.lcs M k⁆ :=
  Function.iterate_succ_apply' (fun N => ⁅I, N⁆) k ⊤
#align lie_ideal.lcs_succ LieIdeal.lcs_succ

theorem lcs_top : (⊤ : LieIdeal R L).lcs M k = lowerCentralSeries R L M k :=
  rfl
#align lie_ideal.lcs_top LieIdeal.lcs_top

theorem coe_lcs_eq : (I.lcs M k : Submodule R M) = lowerCentralSeries R I M k :=
  by
  induction' k with k ih
  · simp
  · simp_rw [lower_central_series_succ, lcs_succ, LieSubmodule.lie_ideal_oper_eq_linear_span', ←
      (I.lcs M k).mem_coe_submodule, ih, LieSubmodule.mem_coe_submodule, LieSubmodule.mem_top,
      exists_true_left, (I : LieSubalgebra R L).coe_bracket_of_module]
    congr
    ext m
    constructor
    · rintro ⟨x, hx, m, hm, rfl⟩
      exact ⟨⟨x, hx⟩, m, hm, rfl⟩
    · rintro ⟨⟨x, hx⟩, m, hm, rfl⟩
      exact ⟨x, hx, m, hm, rfl⟩
#align lie_ideal.coe_lcs_eq LieIdeal.coe_lcs_eq

end LieIdeal

section OfAssociative

variable (R : Type u) {A : Type v} [CommRing R] [Ring A] [Algebra R A]

theorem LieAlgebra.ad_nilpotent_of_nilpotent {a : A} (h : IsNilpotent a) :
    IsNilpotent (LieAlgebra.ad R A a) :=
  by
  rw [LieAlgebra.ad_eq_lmul_left_sub_lmul_right]
  have hl : IsNilpotent (LinearMap.mulLeft R a) := by rwa [LinearMap.is_nilpotent_mul_left_iff]
  have hr : IsNilpotent (LinearMap.mulRight R a) := by rwa [LinearMap.is_nilpotent_mul_right_iff]
  have := @LinearMap.commute_mul_left_right R A _ _ _ _ _ a a
  exact this.is_nilpotent_sub hl hr
#align lie_algebra.ad_nilpotent_of_nilpotent LieAlgebra.ad_nilpotent_of_nilpotent

variable {R}

theorem LieSubalgebra.is_nilpotent_ad_of_is_nilpotent_ad {L : Type v} [LieRing L] [LieAlgebra R L]
    (K : LieSubalgebra R L) {x : K} (h : IsNilpotent (LieAlgebra.ad R L ↑x)) :
    IsNilpotent (LieAlgebra.ad R K x) :=
  by
  obtain ⟨n, hn⟩ := h
  use n
  exact LinearMap.submodule_pow_eq_zero_of_pow_eq_zero (K.ad_comp_incl_eq x) hn
#align
  lie_subalgebra.is_nilpotent_ad_of_is_nilpotent_ad LieSubalgebra.is_nilpotent_ad_of_is_nilpotent_ad

theorem LieAlgebra.is_nilpotent_ad_of_is_nilpotent {L : LieSubalgebra R A} {x : L}
    (h : IsNilpotent (x : A)) : IsNilpotent (LieAlgebra.ad R L x) :=
  L.is_nilpotent_ad_of_is_nilpotent_ad <| LieAlgebra.ad_nilpotent_of_nilpotent R h
#align lie_algebra.is_nilpotent_ad_of_is_nilpotent LieAlgebra.is_nilpotent_ad_of_is_nilpotent

end OfAssociative

