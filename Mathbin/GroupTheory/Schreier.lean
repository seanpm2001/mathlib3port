/-
Copyright (c) 2022 Thomas Browning. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Browning
-/
import Mathbin.GroupTheory.Abelianization
import Mathbin.GroupTheory.Exponent
import Mathbin.GroupTheory.Transfer

/-!
# Schreier's Lemma

In this file we prove Schreier's lemma.

## Main results

- `closure_mul_image_eq` : **Schreier's Lemma**: If `R : set G` is a right_transversal
  of `H : subgroup G` with `1 ∈ R`, and if `G` is generated by `S : set G`,
  then `H` is generated by the `set` `(R * S).image (λ g, g * (to_fun hR g)⁻¹)`.
- `fg_of_index_ne_zero` : **Schreier's Lemma**: A finite index subgroup of a finitely generated
  group is finitely generated.
-/


open Pointwise

namespace Subgroup

open MemRightTransversals

variable {G : Type _} [Group G] {H : Subgroup G} {R S : Set G}

theorem closure_mul_image_mul_eq_top (hR : R ∈ RightTransversals (H : Set G)) (hR1 : (1 : G) ∈ R) (hS : closure S = ⊤) :
    (closure ((R * S).Image fun g => g * (toFun hR g)⁻¹) : Set G) * R = ⊤ := by
  let f : G → R := fun g => to_fun hR g
  let U : Set G := (R * S).Image fun g => g * (f g)⁻¹
  change (closure U : Set G) * R = ⊤
  refine' top_le_iff.mp fun g hg => _
  apply closure_induction_right (eq_top_iff.mp hS (mem_top g))
  · exact ⟨1, 1, (closure U).one_mem, hR1, one_mul 1⟩
    
  · rintro - s hs ⟨u, r, hu, hr, rfl⟩
    rw [show u * r * s = u * (r * s * (f (r * s))⁻¹) * f (r * s) by group]
    refine' Set.mul_mem_mul ((closure U).mul_mem hu _) (f (r * s)).coe_prop
    exact subset_closure ⟨r * s, Set.mul_mem_mul hr hs, rfl⟩
    
  · rintro - s hs ⟨u, r, hu, hr, rfl⟩
    rw [show u * r * s⁻¹ = u * (f (r * s⁻¹) * s * r⁻¹)⁻¹ * f (r * s⁻¹) by group]
    refine' Set.mul_mem_mul ((closure U).mul_mem hu ((closure U).inv_mem _)) (f (r * s⁻¹)).2
    refine' subset_closure ⟨f (r * s⁻¹) * s, Set.mul_mem_mul (f (r * s⁻¹)).2 hs, _⟩
    rw [mul_right_inj, inv_inj, ← Subtype.coe_mk r hr, ← Subtype.ext_iff, Subtype.coe_mk]
    apply
      (mem_right_transversals_iff_exists_unique_mul_inv_mem.mp hR (f (r * s⁻¹) * s)).unique
        (mul_inv_to_fun_mem hR (f (r * s⁻¹) * s))
    rw [mul_assoc, ← inv_inv s, ← mul_inv_rev, inv_inv]
    exact to_fun_mul_inv_mem hR (r * s⁻¹)
    

/-- **Schreier's Lemma**: If `R : set G` is a right_transversal of `H : subgroup G`
  with `1 ∈ R`, and if `G` is generated by `S : set G`, then `H` is generated by the `set`
  `(R * S).image (λ g, g * (to_fun hR g)⁻¹)`. -/
theorem closure_mul_image_eq (hR : R ∈ RightTransversals (H : Set G)) (hR1 : (1 : G) ∈ R) (hS : closure S = ⊤) :
    closure ((R * S).Image fun g => g * (toFun hR g)⁻¹) = H := by
  have hU : closure ((R * S).Image fun g => g * (to_fun hR g)⁻¹) ≤ H := by
    rw [closure_le]
    rintro - ⟨g, -, rfl⟩
    exact mul_inv_to_fun_mem hR g
  refine' le_antisymm hU fun h hh => _
  obtain ⟨g, r, hg, hr, rfl⟩ := show h ∈ _ from eq_top_iff.mp (closure_mul_image_mul_eq_top hR hR1 hS) (mem_top h)
  suffices (⟨r, hr⟩ : R) = (⟨1, hR1⟩ : R) by rwa [show r = 1 from subtype.ext_iff.mp this, mul_one]
  apply (mem_right_transversals_iff_exists_unique_mul_inv_mem.mp hR r).unique
  · rw [Subtype.coe_mk, mul_inv_self]
    exact H.one_mem
    
  · rw [Subtype.coe_mk, inv_one, mul_one]
    exact (H.mul_mem_cancel_left (hU hg)).mp hh
    

/-- **Schreier's Lemma**: If `R : set G` is a right_transversal of `H : subgroup G`
  with `1 ∈ R`, and if `G` is generated by `S : set G`, then `H` is generated by the `set`
  `(R * S).image (λ g, g * (to_fun hR g)⁻¹)`. -/
theorem closure_mul_image_eq_top (hR : R ∈ RightTransversals (H : Set G)) (hR1 : (1 : G) ∈ R) (hS : closure S = ⊤) :
    closure ((R * S).Image fun g => ⟨g * (toFun hR g)⁻¹, mul_inv_to_fun_mem hR g⟩ : Set H) = ⊤ := by
  rw [eq_top_iff, ← map_subtype_le_map_subtype, MonoidHom.map_closure, Set.image_image]
  exact (map_subtype_le ⊤).trans (ge_of_eq (closure_mul_image_eq hR hR1 hS))

/-- **Schreier's Lemma**: If `R : finset G` is a right_transversal of `H : subgroup G`
  with `1 ∈ R`, and if `G` is generated by `S : finset G`, then `H` is generated by the `finset`
  `(R * S).image (λ g, g * (to_fun hR g)⁻¹)`. -/
theorem closure_mul_image_eq_top' [DecidableEq G] {R S : Finset G} (hR : (R : Set G) ∈ RightTransversals (H : Set G))
    (hR1 : (1 : G) ∈ R) (hS : closure (S : Set G) = ⊤) :
    closure (((R * S).Image fun g => ⟨_, mul_inv_to_fun_mem hR g⟩ : Finset H) : Set H) = ⊤ := by
  rw [Finset.coe_image, Finset.coe_mul]
  exact closure_mul_image_eq_top hR hR1 hS

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem exists_finset_card_le_mul (hH : H.index ≠ 0) {S : Finset G} (hS : closure (S : Set G) = ⊤) :
    ∃ T : Finset H, T.card ≤ H.index * S.card ∧ closure (T : Set H) = ⊤ := by
  haveI : DecidableEq G := Classical.decEq G
  obtain ⟨R₀, hR : R₀ ∈ right_transversals (H : Set G), hR1⟩ := exists_right_transversal (1 : G)
  haveI : Fintype (G ⧸ H) := fintype_of_index_ne_zero hH
  haveI : Fintype R₀ := Fintype.ofEquiv _ (mem_right_transversals.to_equiv hR)
  let R : Finset G := Set.toFinset R₀
  replace hR : (R : Set G) ∈ right_transversals (H : Set G) := by rwa [Set.coe_to_finset]
  replace hR1 : (1 : G) ∈ R := by rwa [Set.mem_to_finset]
  refine' ⟨_, _, closure_mul_image_eq_top' hR hR1 hS⟩
  calc
    _ ≤ (R * S).card := Finset.card_image_le
    _ ≤ (R ×ˢ S).card := Finset.card_image_le
    _ = R.card * S.card := R.card_product S
    _ = H.index * S.card := congr_arg (· * S.card) _
    
  calc
    R.card = Fintype.card R := (Fintype.card_coe R).symm
    _ = _ := (Fintype.card_congr (mem_right_transversals.to_equiv hR)).symm
    _ = Fintype.card (G ⧸ H) := QuotientGroup.card_quotient_right_rel H
    _ = H.index := H.index_eq_card.symm
    

/-- **Schreier's Lemma**: A finite index subgroup of a finitely generated
  group is finitely generated. -/
theorem fg_of_index_ne_zero [hG : Group.Fg G] (hH : H.index ≠ 0) : Group.Fg H := by
  obtain ⟨S, hS⟩ := hG.1
  obtain ⟨T, -, hT⟩ := exists_finset_card_le_mul hH hS
  exact ⟨⟨T, hT⟩⟩

theorem rank_le_index_mul_rank [hG : Group.Fg G] {H : Subgroup G} (hH : H.index ≠ 0) :
    @Group.rank H _ (fg_of_index_ne_zero hH) ≤ H.index * Group.rank G := by
  haveI := fg_of_index_ne_zero hH
  obtain ⟨S, hS₀, hS⟩ := Group.rank_spec G
  obtain ⟨T, hT₀, hT⟩ := exists_finset_card_le_mul hH hS
  calc
    Group.rank H ≤ T.card := Group.rank_le H hT
    _ ≤ H.index * S.card := hT₀
    _ = H.index * Group.rank G := congr_arg ((· * ·) H.index) hS₀
    

variable (G)

/-- If `G` has `n` commutators `[g₁, g₂]`, then `|G'| ∣ [G : Z(G)] ^ ([G : Z(G)] * n + 1)`,
where `G'` denotes the commutator of `G`. -/
theorem card_commutator_dvd_index_center_pow [Finite (CommutatorSet G)] :
    Nat.card (commutator G) ∣ (center G).index ^ ((center G).index * Nat.card (CommutatorSet G) + 1) := by
  -- First handle the case when `Z(G)` has infinite index and `[G : Z(G)]` is defined to be `0`
  by_cases hG:(center G).index = 0
  · simp_rw [hG, zero_mul, zero_add, pow_one, dvd_zero]
    
  -- Rewrite as `|Z(G) ∩ G'| * [G' : Z(G) ∩ G'] ∣ [G : Z(G)] ^ ([G : Z(G)] * n) * [G : Z(G)]`
  rw [← ((center G).subgroupOf (commutator G)).card_mul_index, pow_succ']
  -- We have `h1 : [G' : Z(G) ∩ G'] ∣ [G : Z(G)]`
  have h1 := relindex_dvd_index_of_normal (center G) (commutator G)
  -- So we can reduce to proving `|Z(G) ∩ G'| ∣ [G : Z(G)] ^ ([G : Z(G)] * n)`
  refine' mul_dvd_mul _ h1
  -- We have `h2 : rank (Z(G) ∩ G') ≤ [G' : Z(G) ∩ G'] * rank G'` by Schreier's lemma
  have h2 := rank_le_index_mul_rank (ne_zero_of_dvd_ne_zero hG h1)
  -- We have `h3 : [G' : Z(G) ∩ G'] * rank G' ≤ [G : Z(G)] * n` by `h1` and `rank G' ≤ n`
  have h3 := Nat.mul_le_mul (Nat.le_of_dvd (Nat.pos_of_ne_zero hG) h1) (rank_commutator_le_card G)
  -- So we can reduce to proving `|Z(G) ∩ G'| ∣ [G : Z(G)] ^ rank (Z(G) ∩ G')`
  refine' dvd_trans _ (pow_dvd_pow (center G).index (h2.trans h3))
  -- `Z(G) ∩ G'` is abelian, so it enough to prove that `g ^ [G : Z(G)] = 1` for `g ∈ Z(G) ∩ G'`
  apply card_dvd_exponent_pow_rank' _ fun g => _
  -- `Z(G)` is abelian, so `g ∈ Z(G) ∩ G' ≤ G' ≤ ker (transfer : G → Z(G))`
  have := Abelianization.commutator_subset_ker (MonoidHom.transferCenterPow' hG) g.1.2
  -- `transfer g` is defeq to `g ^ [G : Z(G)]`, so we are done
  simpa only [MonoidHom.mem_ker, Subtype.ext_iff] using this

end Subgroup

