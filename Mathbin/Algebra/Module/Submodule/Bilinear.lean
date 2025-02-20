/-
Copyright (c) 2019 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau, Eric Wieser

! This file was ported from Lean 3 source module algebra.module.submodule.bilinear
! leanprover-community/mathlib commit ee05e9ce1322178f0c12004eb93c00d2c8c00ed2
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Span
import Mathbin.LinearAlgebra.BilinearMap

/-!
# Images of pairs of submodules under bilinear maps

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides `submodule.map₂`, which is later used to implement `submodule.has_mul`.

## Main results

* `submodule.map₂_eq_span_image2`: the image of two submodules under a bilinear map is the span of
  their `set.image2`.

## Notes

This file is quite similar to the n-ary section of `data.set.basic` and to `order.filter.n_ary`.
Please keep them in sync.
-/


universe uι u v

open Set

open scoped BigOperators

open scoped Pointwise

namespace Submodule

variable {ι : Sort uι} {R M N P : Type _}

variable [CommSemiring R] [AddCommMonoid M] [AddCommMonoid N] [AddCommMonoid P]

variable [Module R M] [Module R N] [Module R P]

#print Submodule.map₂ /-
/-- Map a pair of submodules under a bilinear map.

This is the submodule version of `set.image2`.  -/
def map₂ (f : M →ₗ[R] N →ₗ[R] P) (p : Submodule R M) (q : Submodule R N) : Submodule R P :=
  ⨆ s : p, q.map <| f s
#align submodule.map₂ Submodule.map₂
-/

#print Submodule.apply_mem_map₂ /-
theorem apply_mem_map₂ (f : M →ₗ[R] N →ₗ[R] P) {m : M} {n : N} {p : Submodule R M}
    {q : Submodule R N} (hm : m ∈ p) (hn : n ∈ q) : f m n ∈ map₂ f p q :=
  (le_iSup _ ⟨m, hm⟩ : _ ≤ map₂ f p q) ⟨n, hn, rfl⟩
#align submodule.apply_mem_map₂ Submodule.apply_mem_map₂
-/

#print Submodule.map₂_le /-
theorem map₂_le {f : M →ₗ[R] N →ₗ[R] P} {p : Submodule R M} {q : Submodule R N}
    {r : Submodule R P} : map₂ f p q ≤ r ↔ ∀ m ∈ p, ∀ n ∈ q, f m n ∈ r :=
  ⟨fun H m hm n hn => H <| apply_mem_map₂ _ hm hn, fun H =>
    iSup_le fun ⟨m, hm⟩ => map_le_iff_le_comap.2 fun n hn => H m hm n hn⟩
#align submodule.map₂_le Submodule.map₂_le
-/

variable (R)

#print Submodule.map₂_span_span /-
theorem map₂_span_span (f : M →ₗ[R] N →ₗ[R] P) (s : Set M) (t : Set N) :
    map₂ f (span R s) (span R t) = span R (Set.image2 (fun m n => f m n) s t) :=
  by
  apply le_antisymm
  · rw [map₂_le]; intro a ha b hb
    apply span_induction ha
    on_goal 1 =>
      intros; apply span_induction hb
      on_goal 1 => intros; exact subset_span ⟨_, _, ‹_›, ‹_›, rfl⟩
    all_goals
      intros
      simp only [LinearMap.map_zero, LinearMap.zero_apply, zero_mem, LinearMap.map_add,
        LinearMap.add_apply, LinearMap.map_smul, LinearMap.smul_apply]
    all_goals
      solve_by_elim (config :=
        { max_depth := 4
          discharger := tactic.interactive.apply_instance }) [add_mem _ _, zero_mem _,
        smul_mem _ _ _]
  · rw [span_le]; rintro _ ⟨a, b, ha, hb, rfl⟩
    exact apply_mem_map₂ _ (subset_span ha) (subset_span hb)
#align submodule.map₂_span_span Submodule.map₂_span_span
-/

variable {R}

#print Submodule.map₂_bot_right /-
@[simp]
theorem map₂_bot_right (f : M →ₗ[R] N →ₗ[R] P) (p : Submodule R M) : map₂ f p ⊥ = ⊥ :=
  eq_bot_iff.2 <|
    map₂_le.2 fun m hm n hn => by rw [Submodule.mem_bot] at hn ⊢; rw [hn, LinearMap.map_zero]
#align submodule.map₂_bot_right Submodule.map₂_bot_right
-/

#print Submodule.map₂_bot_left /-
@[simp]
theorem map₂_bot_left (f : M →ₗ[R] N →ₗ[R] P) (q : Submodule R N) : map₂ f ⊥ q = ⊥ :=
  eq_bot_iff.2 <|
    map₂_le.2 fun m hm n hn => by rw [Submodule.mem_bot] at hm ⊢; rw [hm, LinearMap.map_zero₂]
#align submodule.map₂_bot_left Submodule.map₂_bot_left
-/

#print Submodule.map₂_le_map₂ /-
@[mono]
theorem map₂_le_map₂ {f : M →ₗ[R] N →ₗ[R] P} {p₁ p₂ : Submodule R M} {q₁ q₂ : Submodule R N}
    (hp : p₁ ≤ p₂) (hq : q₁ ≤ q₂) : map₂ f p₁ q₁ ≤ map₂ f p₂ q₂ :=
  map₂_le.2 fun m hm n hn => apply_mem_map₂ _ (hp hm) (hq hn)
#align submodule.map₂_le_map₂ Submodule.map₂_le_map₂
-/

#print Submodule.map₂_le_map₂_left /-
theorem map₂_le_map₂_left {f : M →ₗ[R] N →ₗ[R] P} {p₁ p₂ : Submodule R M} {q : Submodule R N}
    (h : p₁ ≤ p₂) : map₂ f p₁ q ≤ map₂ f p₂ q :=
  map₂_le_map₂ h (le_refl q)
#align submodule.map₂_le_map₂_left Submodule.map₂_le_map₂_left
-/

#print Submodule.map₂_le_map₂_right /-
theorem map₂_le_map₂_right {f : M →ₗ[R] N →ₗ[R] P} {p : Submodule R M} {q₁ q₂ : Submodule R N}
    (h : q₁ ≤ q₂) : map₂ f p q₁ ≤ map₂ f p q₂ :=
  map₂_le_map₂ (le_refl p) h
#align submodule.map₂_le_map₂_right Submodule.map₂_le_map₂_right
-/

#print Submodule.map₂_sup_right /-
theorem map₂_sup_right (f : M →ₗ[R] N →ₗ[R] P) (p : Submodule R M) (q₁ q₂ : Submodule R N) :
    map₂ f p (q₁ ⊔ q₂) = map₂ f p q₁ ⊔ map₂ f p q₂ :=
  le_antisymm
    (map₂_le.2 fun m hm np hnp =>
      let ⟨n, hn, p, hp, hnp⟩ := mem_sup.1 hnp
      mem_sup.2 ⟨_, apply_mem_map₂ _ hm hn, _, apply_mem_map₂ _ hm hp, hnp ▸ (map_add _ _ _).symm⟩)
    (sup_le (map₂_le_map₂_right le_sup_left) (map₂_le_map₂_right le_sup_right))
#align submodule.map₂_sup_right Submodule.map₂_sup_right
-/

#print Submodule.map₂_sup_left /-
theorem map₂_sup_left (f : M →ₗ[R] N →ₗ[R] P) (p₁ p₂ : Submodule R M) (q : Submodule R N) :
    map₂ f (p₁ ⊔ p₂) q = map₂ f p₁ q ⊔ map₂ f p₂ q :=
  le_antisymm
    (map₂_le.2 fun mn hmn p hp =>
      let ⟨m, hm, n, hn, hmn⟩ := mem_sup.1 hmn
      mem_sup.2
        ⟨_, apply_mem_map₂ _ hm hp, _, apply_mem_map₂ _ hn hp,
          hmn ▸ (LinearMap.map_add₂ _ _ _ _).symm⟩)
    (sup_le (map₂_le_map₂_left le_sup_left) (map₂_le_map₂_left le_sup_right))
#align submodule.map₂_sup_left Submodule.map₂_sup_left
-/

#print Submodule.image2_subset_map₂ /-
theorem image2_subset_map₂ (f : M →ₗ[R] N →ₗ[R] P) (p : Submodule R M) (q : Submodule R N) :
    Set.image2 (fun m n => f m n) (↑p : Set M) (↑q : Set N) ⊆ (↑(map₂ f p q) : Set P) := by
  rintro _ ⟨i, j, hi, hj, rfl⟩; exact apply_mem_map₂ _ hi hj
#align submodule.image2_subset_map₂ Submodule.image2_subset_map₂
-/

#print Submodule.map₂_eq_span_image2 /-
theorem map₂_eq_span_image2 (f : M →ₗ[R] N →ₗ[R] P) (p : Submodule R M) (q : Submodule R N) :
    map₂ f p q = span R (Set.image2 (fun m n => f m n) (p : Set M) (q : Set N)) := by
  rw [← map₂_span_span, span_eq, span_eq]
#align submodule.map₂_eq_span_image2 Submodule.map₂_eq_span_image2
-/

#print Submodule.map₂_flip /-
theorem map₂_flip (f : M →ₗ[R] N →ₗ[R] P) (p : Submodule R M) (q : Submodule R N) :
    map₂ f.flip q p = map₂ f p q := by
  rw [map₂_eq_span_image2, map₂_eq_span_image2, Set.image2_swap]; rfl
#align submodule.map₂_flip Submodule.map₂_flip
-/

#print Submodule.map₂_iSup_left /-
theorem map₂_iSup_left (f : M →ₗ[R] N →ₗ[R] P) (s : ι → Submodule R M) (t : Submodule R N) :
    map₂ f (⨆ i, s i) t = ⨆ i, map₂ f (s i) t :=
  by
  suffices map₂ f (⨆ i, span R (s i : Set M)) (span R t) = ⨆ i, map₂ f (span R (s i)) (span R t) by
    simpa only [span_eq] using this
  simp_rw [map₂_span_span, ← span_Union, map₂_span_span, Set.image2_iUnion_left]
#align submodule.map₂_supr_left Submodule.map₂_iSup_left
-/

#print Submodule.map₂_iSup_right /-
theorem map₂_iSup_right (f : M →ₗ[R] N →ₗ[R] P) (s : Submodule R M) (t : ι → Submodule R N) :
    map₂ f s (⨆ i, t i) = ⨆ i, map₂ f s (t i) :=
  by
  suffices map₂ f (span R s) (⨆ i, span R (t i : Set N)) = ⨆ i, map₂ f (span R s) (span R (t i)) by
    simpa only [span_eq] using this
  simp_rw [map₂_span_span, ← span_Union, map₂_span_span, Set.image2_iUnion_right]
#align submodule.map₂_supr_right Submodule.map₂_iSup_right
-/

#print Submodule.map₂_span_singleton_eq_map /-
theorem map₂_span_singleton_eq_map (f : M →ₗ[R] N →ₗ[R] P) (m : M) :
    map₂ f (span R {m}) = map (f m) := by
  funext; rw [map₂_eq_span_image2]; apply le_antisymm
  · rw [span_le, Set.image2_subset_iff]
    intro x hx y hy
    obtain ⟨a, rfl⟩ := mem_span_singleton.1 hx
    rw [f.map_smul]
    exact smul_mem _ a (mem_map_of_mem hy)
  · rintro _ ⟨n, hn, rfl⟩
    exact subset_span ⟨m, n, mem_span_singleton_self m, hn, rfl⟩
#align submodule.map₂_span_singleton_eq_map Submodule.map₂_span_singleton_eq_map
-/

#print Submodule.map₂_span_singleton_eq_map_flip /-
theorem map₂_span_singleton_eq_map_flip (f : M →ₗ[R] N →ₗ[R] P) (s : Submodule R M) (n : N) :
    map₂ f s (span R {n}) = map (f.flip n) s := by rw [← map₂_span_singleton_eq_map, map₂_flip]
#align submodule.map₂_span_singleton_eq_map_flip Submodule.map₂_span_singleton_eq_map_flip
-/

end Submodule

