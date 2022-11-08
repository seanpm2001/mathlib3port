/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies
-/
import Mathbin.Analysis.Convex.Join

/-!
# Stone's separation theorem

This file prove Stone's separation theorem. This tells us that any two disjoint convex sets can be
separated by a convex set whose complement is also convex.

In locally convex real topological vector spaces, the Hahn-Banach separation theorems provide
stronger statements: one may find a separating hyperplane, instead of merely a convex set whose
complement is convex.
-/


open Set

open BigOperators

variable {𝕜 E ι : Type _} [LinearOrderedField 𝕜] [AddCommGroup E] [Module 𝕜 E] {s t : Set E}

/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:52:50: missing argument -/
/- ./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr «expr + »(«expr * »(«expr * »(az, av), bu), «expr + »(«expr * »(«expr * »(bz, au), bv), «expr * »(au, av)))]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg -/
/- ./././Mathport/Syntax/Translate/Tactic/Basic.lean:31:4: unsupported: too many args: fin_cases ... #[[]] -/
/-- In a tetrahedron with vertices `x`, `y`, `p`, `q`, any segment `[u, v]` joining the opposite
edges `[x, p]` and `[y, q]` passes through any triangle of vertices `p`, `q`, `z` where
`z ∈ [x, y]`. -/
theorem not_disjoint_segment_convex_hull_triple {p q u v x y z : E} (hz : z ∈ Segment 𝕜 x y) (hu : u ∈ Segment 𝕜 x p)
    (hv : v ∈ Segment 𝕜 y q) : ¬Disjoint (Segment 𝕜 u v) (convexHull 𝕜 {p, q, z}) := by
  rw [not_disjoint_iff]
  obtain ⟨az, bz, haz, hbz, habz, rfl⟩ := hz
  obtain rfl | haz' := haz.eq_or_lt
  · rw [zero_add] at habz
    rw [zero_smul, zero_add, habz, one_smul]
    refine' ⟨v, right_mem_segment _ _ _, segment_subset_convex_hull _ _ hv⟩ <;> simp
    
  obtain ⟨av, bv, hav, hbv, habv, rfl⟩ := hv
  obtain rfl | hav' := hav.eq_or_lt
  · rw [zero_add] at habv
    rw [zero_smul, zero_add, habv, one_smul]
    exact ⟨q, right_mem_segment _ _ _, subset_convex_hull _ _ <| by simp⟩
    
  obtain ⟨au, bu, hau, hbu, habu, rfl⟩ := hu
  have hab : 0 < az * av + bz * au := add_pos_of_pos_of_nonneg (mul_pos haz' hav') (mul_nonneg hbz hau)
  refine'
    ⟨(az * av / (az * av + bz * au)) • (au • x + bu • p) + (bz * au / (az * av + bz * au)) • (av • y + bv • q),
      ⟨_, _, _, _, _, rfl⟩, _⟩
  · exact div_nonneg (mul_nonneg haz hav) hab.le
    
  · exact div_nonneg (mul_nonneg hbz hau) hab.le
    
  · rw [← add_div, div_self hab.ne']
    
  rw [smul_add, smul_add, add_add_add_comm, add_comm, ← mul_smul, ← mul_smul]
  classical
  let w : Fin 3 → 𝕜 := ![az * av * bu, bz * au * bv, au * av]
  let z : Fin 3 → E := ![p, q, az • x + bz • y]
  have hw₀ : ∀ i, 0 ≤ w i := by
    rintro i
    fin_cases i
    · exact mul_nonneg (mul_nonneg haz hav) hbu
      
    · exact mul_nonneg (mul_nonneg hbz hau) hbv
      
    · exact mul_nonneg hau hav
      
  have hw : (∑ i, w i) = az * av + bz * au := by
    trace
      "./././Mathport/Syntax/Translate/Tactic/Builtin.lean:65:38: in transitivity #[[expr «expr + »(«expr * »(«expr * »(az, av), bu), «expr + »(«expr * »(«expr * »(bz, au), bv), «expr * »(au, av)))]]: ./././Mathport/Syntax/Translate/Tactic/Basic.lean:55:35: expecting parse arg"
    · simp [w, Fin.sum_univ_succ, Fin.sum_univ_zero]
      
    rw [← one_mul (au * av), ← habz, add_mul, ← add_assoc, add_add_add_comm, mul_assoc, ← mul_add, mul_assoc, ← mul_add,
      mul_comm av, ← add_mul, ← mul_add, add_comm bu, add_comm bv, habu, habv, one_mul, mul_one]
  have hz : ∀ i, z i ∈ ({p, q, az • x + bz • y} : Set E) := by
    rintro i
    fin_cases i <;> simp [z]
  convert
    Finset.center_mass_mem_convex_hull (Finset.univ : Finset (Fin 3)) (fun i _ => hw₀ i) (by rwa [hw]) fun i _ => hz i
  rw [Finset.centerMass]
  simp_rw [div_eq_inv_mul, hw, mul_assoc, mul_smul (az * av + bz * au)⁻¹, ← smul_add, add_assoc, ← mul_assoc]
  congr 3
  rw [← mul_smul, ← mul_rotate, mul_right_comm, mul_smul, ← mul_smul _ av, mul_rotate, mul_smul _ bz, ← smul_add]
  simp only [List.map, List.pmap, Nat.add_def, add_zero, Fin.mk_bit0, Fin.mk_one, List.foldr_cons, List.foldr_nil]
  rfl

/-- **Stone's Separation Theorem** -/
theorem exists_convex_convex_compl_subset (hs : Convex 𝕜 s) (ht : Convex 𝕜 t) (hst : Disjoint s t) :
    ∃ C : Set E, Convex 𝕜 C ∧ Convex 𝕜 (Cᶜ) ∧ s ⊆ C ∧ t ⊆ Cᶜ := by
  let S : Set (Set E) := { C | Convex 𝕜 C ∧ Disjoint C t }
  obtain ⟨C, hC, hsC, hCmax⟩ :=
    zorn_subset_nonempty S
      (fun c hcS hc ⟨t, ht⟩ =>
        ⟨⋃₀c, ⟨hc.directed_on.convex_sUnion fun s hs => (hcS hs).1, disjoint_sUnion_left.2 fun c hc => (hcS hc).2⟩,
          fun s => subset_sUnion_of_mem⟩)
      s ⟨hs, hst⟩
  refine' ⟨C, hC.1, convex_iff_segment_subset.2 fun x hx y hy z hz hzC => _, hsC, hC.2.subset_compl_left⟩
  suffices h : ∀ c ∈ Cᶜ, ∃ a ∈ C, (Segment 𝕜 c a ∩ t).Nonempty
  · obtain ⟨p, hp, u, hu, hut⟩ := h x hx
    obtain ⟨q, hq, v, hv, hvt⟩ := h y hy
    refine'
      not_disjoint_segment_convex_hull_triple hz hu hv
        (hC.2.symm.mono (ht.segment_subset hut hvt) <| convex_hull_min _ hC.1)
    simp [insert_subset, hp, hq, singleton_subset_iff.2 hzC]
    
  rintro c hc
  by_contra' h
  suffices h : Disjoint (convexHull 𝕜 (insert c C)) t
  · rw [← hCmax _ ⟨convex_convex_hull _ _, h⟩ ((subset_insert _ _).trans <| subset_convex_hull _ _)] at hc
    exact hc (subset_convex_hull _ _ <| mem_insert _ _)
    
  rw [convex_hull_insert ⟨z, hzC⟩, convex_join_singleton_left]
  refine' disjoint_Union₂_left.2 fun a ha b hb => h a _ ⟨b, hb⟩
  rwa [← hC.1.convex_hull_eq]

