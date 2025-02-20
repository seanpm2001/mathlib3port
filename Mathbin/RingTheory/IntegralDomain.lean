/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Chris Hughes

! This file was ported from Lean 3 source module ring_theory.integral_domain
! leanprover-community/mathlib commit 0b7c740e25651db0ba63648fbae9f9d6f941e31b
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Polynomial.RingDivision
import Mathbin.GroupTheory.SpecificGroups.Cyclic
import Mathbin.Algebra.GeomSum

/-!
# Integral domains

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Assorted theorems about integral domains.

## Main theorems

* `is_cyclic_of_subgroup_is_domain`: A finite subgroup of the units of an integral domain is cyclic.
* `fintype.field_of_domain`: A finite integral domain is a field.

## TODO

Prove Wedderburn's little theorem, which shows that all finite division rings are actually fields.

## Tags

integral domain, finite integral domain, finite field
-/


section

open Finset Polynomial Function

open scoped BigOperators Nat

section CancelMonoidWithZero

-- There doesn't seem to be a better home for these right now
variable {M : Type _} [CancelMonoidWithZero M] [Finite M]

#print mul_right_bijective_of_finite₀ /-
theorem mul_right_bijective_of_finite₀ {a : M} (ha : a ≠ 0) : Bijective fun b => a * b :=
  Finite.injective_iff_bijective.1 <| mul_right_injective₀ ha
#align mul_right_bijective_of_finite₀ mul_right_bijective_of_finite₀
-/

#print mul_left_bijective_of_finite₀ /-
theorem mul_left_bijective_of_finite₀ {a : M} (ha : a ≠ 0) : Bijective fun b => b * a :=
  Finite.injective_iff_bijective.1 <| mul_left_injective₀ ha
#align mul_left_bijective_of_finite₀ mul_left_bijective_of_finite₀
-/

#print Fintype.groupWithZeroOfCancel /-
/-- Every finite nontrivial cancel_monoid_with_zero is a group_with_zero. -/
def Fintype.groupWithZeroOfCancel (M : Type _) [CancelMonoidWithZero M] [DecidableEq M] [Fintype M]
    [Nontrivial M] : GroupWithZero M :=
  { ‹Nontrivial M›,
    ‹CancelMonoidWithZero
        M› with
    inv := fun a => if h : a = 0 then 0 else Fintype.bijInv (mul_right_bijective_of_finite₀ h) 1
    mul_inv_cancel := fun a ha => by simp [Inv.inv, dif_neg ha];
      exact Fintype.rightInverse_bijInv _ _
    inv_zero := by simp [Inv.inv, dif_pos rfl] }
#align fintype.group_with_zero_of_cancel Fintype.groupWithZeroOfCancel
-/

#print exists_eq_pow_of_mul_eq_pow_of_coprime /-
theorem exists_eq_pow_of_mul_eq_pow_of_coprime {R : Type _} [CommSemiring R] [IsDomain R]
    [GCDMonoid R] [Unique Rˣ] {a b c : R} {n : ℕ} (cp : IsCoprime a b) (h : a * b = c ^ n) :
    ∃ d : R, a = d ^ n :=
  by
  refine' exists_eq_pow_of_mul_eq_pow (isUnit_of_dvd_one _ _) h
  obtain ⟨x, y, hxy⟩ := cp
  rw [← hxy]
  exact
    dvd_add (dvd_mul_of_dvd_right (gcd_dvd_left _ _) _) (dvd_mul_of_dvd_right (gcd_dvd_right _ _) _)
#align exists_eq_pow_of_mul_eq_pow_of_coprime exists_eq_pow_of_mul_eq_pow_of_coprime
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (i j «expr ∈ » s) -/
#print Finset.exists_eq_pow_of_mul_eq_pow_of_coprime /-
theorem Finset.exists_eq_pow_of_mul_eq_pow_of_coprime {ι R : Type _} [CommSemiring R] [IsDomain R]
    [GCDMonoid R] [Unique Rˣ] {n : ℕ} {c : R} {s : Finset ι} {f : ι → R}
    (h : ∀ (i) (_ : i ∈ s) (j) (_ : j ∈ s), i ≠ j → IsCoprime (f i) (f j))
    (hprod : ∏ i in s, f i = c ^ n) : ∀ i ∈ s, ∃ d : R, f i = d ^ n := by
  classical
  intro i hi
  rw [← insert_erase hi, prod_insert (not_mem_erase i s)] at hprod 
  refine'
    exists_eq_pow_of_mul_eq_pow_of_coprime
      (IsCoprime.prod_right fun j hj => h i hi j (erase_subset i s hj) fun hij => _) hprod
  rw [hij] at hj 
  exact (s.not_mem_erase _) hj
#align finset.exists_eq_pow_of_mul_eq_pow_of_coprime Finset.exists_eq_pow_of_mul_eq_pow_of_coprime
-/

end CancelMonoidWithZero

variable {R : Type _} {G : Type _}

section Ring

variable [Ring R] [IsDomain R] [Fintype R]

#print Fintype.divisionRingOfIsDomain /-
/-- Every finite domain is a division ring.

TODO: Prove Wedderburn's little theorem,
which shows a finite domain is in fact commutative, hence a field. -/
def Fintype.divisionRingOfIsDomain (R : Type _) [Ring R] [IsDomain R] [DecidableEq R] [Fintype R] :
    DivisionRing R :=
  { show GroupWithZero R from Fintype.groupWithZeroOfCancel R, ‹Ring R› with }
#align fintype.division_ring_of_is_domain Fintype.divisionRingOfIsDomain
-/

#print Fintype.fieldOfDomain /-
/-- Every finite commutative domain is a field.

TODO: Prove Wedderburn's little theorem, which shows a finite domain is automatically commutative,
dropping one assumption from this theorem. -/
def Fintype.fieldOfDomain (R) [CommRing R] [IsDomain R] [DecidableEq R] [Fintype R] : Field R :=
  { Fintype.groupWithZeroOfCancel R, ‹CommRing R› with }
#align fintype.field_of_domain Fintype.fieldOfDomain
-/

#print Finite.isField_of_domain /-
theorem Finite.isField_of_domain (R) [CommRing R] [IsDomain R] [Finite R] : IsField R :=
  by
  cases nonempty_fintype R
  exact @Field.toIsField R (@Fintype.fieldOfDomain R _ _ (Classical.decEq R) _)
#align finite.is_field_of_domain Finite.isField_of_domain
-/

end Ring

variable [CommRing R] [IsDomain R] [Group G]

#print card_nthRoots_subgroup_units /-
theorem card_nthRoots_subgroup_units [Fintype G] (f : G →* R) (hf : Injective f) {n : ℕ}
    (hn : 0 < n) (g₀ : G) : ({g ∈ univ | g ^ n = g₀} : Finset G).card ≤ (nthRoots n (f g₀)).card :=
  by
  haveI : DecidableEq R := Classical.decEq _
  refine' le_trans _ (nth_roots n (f g₀)).toFinset_card_le
  apply card_le_card_of_inj_on f
  · intro g hg
    rw [sep_def, mem_filter] at hg 
    rw [Multiset.mem_toFinset, mem_nth_roots hn, ← f.map_pow, hg.2]
  · intros; apply hf; assumption
#align card_nth_roots_subgroup_units card_nthRoots_subgroup_units
-/

#print isCyclic_of_subgroup_isDomain /-
/-- A finite subgroup of the unit group of an integral domain is cyclic. -/
theorem isCyclic_of_subgroup_isDomain [Finite G] (f : G →* R) (hf : Injective f) : IsCyclic G := by
  classical
  cases nonempty_fintype G
  apply isCyclic_of_card_pow_eq_one_le
  intro n hn
  convert le_trans (card_nthRoots_subgroup_units f hf hn 1) (card_nth_roots n (f 1))
#align is_cyclic_of_subgroup_is_domain isCyclic_of_subgroup_isDomain
-/

/-- The unit group of a finite integral domain is cyclic.

To support `ℤˣ` and other infinite monoids with finite groups of units, this requires only
`finite Rˣ` rather than deducing it from `finite R`. -/
instance [Finite Rˣ] : IsCyclic Rˣ :=
  isCyclic_of_subgroup_isDomain (Units.coeHom R) <| Units.ext

section

variable (S : Subgroup Rˣ) [Finite S]

#print subgroup_units_cyclic /-
/-- A finite subgroup of the units of an integral domain is cyclic. -/
instance subgroup_units_cyclic : IsCyclic S :=
  by
  refine' isCyclic_of_subgroup_isDomain ⟨(coe : S → R), _, _⟩ (units.ext.comp Subtype.val_injective)
  · simp
  · intros; simp
#align subgroup_units_cyclic subgroup_units_cyclic
-/

end

section EuclideanDivision

namespace Polynomial

open scoped Polynomial

variable (K : Type) [Field K] [Algebra R[X] K] [IsFractionRing R[X] K]

#print Polynomial.div_eq_quo_add_rem_div /-
theorem div_eq_quo_add_rem_div (f : R[X]) {g : R[X]} (hg : g.Monic) :
    ∃ q r : R[X], r.degree < g.degree ∧ (↑f : K) / ↑g = ↑q + ↑r / ↑g :=
  by
  refine' ⟨f /ₘ g, f %ₘ g, _, _⟩
  · exact degree_mod_by_monic_lt _ hg
  · have hg' : (↑g : K) ≠ 0 := by exact_mod_cast monic.ne_zero hg
    field_simp [hg']
    norm_cast
    rw [add_comm, mul_comm, mod_by_monic_add_div f hg]
#align polynomial.div_eq_quo_add_rem_div Polynomial.div_eq_quo_add_rem_div
-/

end Polynomial

end EuclideanDivision

variable [Fintype G]

#print card_fiber_eq_of_mem_range /-
theorem card_fiber_eq_of_mem_range {H : Type _} [Group H] [DecidableEq H] (f : G →* H) {x y : H}
    (hx : x ∈ Set.range f) (hy : y ∈ Set.range f) :
    (univ.filterₓ fun g => f g = x).card = (univ.filterₓ fun g => f g = y).card :=
  by
  rcases hx with ⟨x, rfl⟩
  rcases hy with ⟨y, rfl⟩
  refine' card_congr (fun g _ => g * x⁻¹ * y) _ _ fun g hg => ⟨g * y⁻¹ * x, _⟩
  ·
    simp (config := { contextual := true }) only [mem_filter, one_mul, MonoidHom.map_mul, mem_univ,
      mul_right_inv, eq_self_iff_true, MonoidHom.map_mul_inv, and_self_iff, forall_true_iff]
  · simp only [mul_left_inj, imp_self, forall₂_true_iff]
  · simp only [true_and_iff, mem_filter, mem_univ] at hg 
    simp only [hg, mem_filter, one_mul, MonoidHom.map_mul, mem_univ, mul_right_inv,
      eq_self_iff_true, exists_prop_of_true, MonoidHom.map_mul_inv, and_self_iff,
      mul_inv_cancel_right, inv_mul_cancel_right]
#align card_fiber_eq_of_mem_range card_fiber_eq_of_mem_range
-/

#print sum_hom_units_eq_zero /-
/-- In an integral domain, a sum indexed by a nontrivial homomorphism from a finite group is zero.
-/
theorem sum_hom_units_eq_zero (f : G →* R) (hf : f ≠ 1) : ∑ g : G, f g = 0 := by
  classical
  obtain ⟨x, hx⟩ :
    ∃ x : MonoidHom.range f.to_hom_units,
      ∀ y : MonoidHom.range f.to_hom_units, y ∈ Submonoid.powers x
  exact IsCyclic.exists_monoid_generator
  have hx1 : x ≠ 1 := by
    rintro rfl
    apply hf
    ext g
    rw [MonoidHom.one_apply]
    cases' hx ⟨f.to_hom_units g, g, rfl⟩ with n hn
    rwa [Subtype.ext_iff, Units.ext_iff, Subtype.coe_mk, MonoidHom.coe_toHomUnits, one_pow,
      eq_comm] at hn 
  replace hx1 : (x : R) - 1 ≠ 0
  exact fun h => hx1 (Subtype.eq (Units.ext (sub_eq_zero.1 h)))
  let c := (univ.filter fun g => f.to_hom_units g = 1).card
  calc
    ∑ g : G, f g = ∑ g : G, f.to_hom_units g := rfl
    _ =
        ∑ u : Rˣ in univ.image f.to_hom_units,
          (univ.filter fun g => f.to_hom_units g = u).card • u :=
      (sum_comp (coe : Rˣ → R) f.to_hom_units)
    _ = ∑ u : Rˣ in univ.image f.to_hom_units, c • u :=
      (sum_congr rfl fun u hu => congr_arg₂ _ _ rfl)
    -- remaining goal 1, proven below
        _ =
        ∑ b : MonoidHom.range f.to_hom_units, c • ↑b :=
      (Finset.sum_subtype _ (by simp) _)
    _ = c • ∑ b : MonoidHom.range f.to_hom_units, (b : R) := smul_sum.symm
    _ = c • 0 := (congr_arg₂ _ rfl _)
    -- remaining goal 2, proven below
        _ =
        0 :=
      smul_zero _
  · -- remaining goal 1
    show (univ.filter fun g : G => f.to_hom_units g = u).card = c
    apply card_fiber_eq_of_mem_range f.to_hom_units
    · simpa only [mem_image, mem_univ, exists_prop_of_true, Set.mem_range] using hu
    · exact ⟨1, f.to_hom_units.map_one⟩
  -- remaining goal 2
  show ∑ b : MonoidHom.range f.to_hom_units, (b : R) = 0
  calc
    ∑ b : MonoidHom.range f.to_hom_units, (b : R) = ∑ n in range (orderOf x), x ^ n :=
      Eq.symm <|
        sum_bij (fun n _ => x ^ n) (by simp only [mem_univ, forall_true_iff])
          (by
            simp only [imp_true_iff, eq_self_iff_true, Subgroup.coe_pow, Units.val_pow_eq_pow_val,
              coe_coe])
          (fun m n hm hn =>
            pow_injective_of_lt_orderOf _ (by simpa only [mem_range] using hm)
              (by simpa only [mem_range] using hn))
          fun b hb =>
          let ⟨n, hn⟩ := hx b
          ⟨n % orderOf x, mem_range.2 (Nat.mod_lt _ (orderOf_pos _)), by
            rw [← pow_eq_mod_orderOf, hn]⟩
    _ = 0 := _
  rw [← mul_left_inj' hx1, MulZeroClass.zero_mul, geom_sum_mul, coe_coe]
  norm_cast
  simp [pow_orderOf_eq_one]
#align sum_hom_units_eq_zero sum_hom_units_eq_zero
-/

#print sum_hom_units /-
/-- In an integral domain, a sum indexed by a homomorphism from a finite group is zero,
unless the homomorphism is trivial, in which case the sum is equal to the cardinality of the group.
-/
theorem sum_hom_units (f : G →* R) [Decidable (f = 1)] :
    ∑ g : G, f g = if f = 1 then Fintype.card G else 0 :=
  by
  split_ifs with h h
  · simp [h, card_univ]
  · exact sum_hom_units_eq_zero f h
#align sum_hom_units sum_hom_units
-/

end

