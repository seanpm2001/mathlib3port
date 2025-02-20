/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module data.set.pairwise.lattice
! leanprover-community/mathlib commit c4c2ed622f43768eff32608d4a0f8a6cec1c047d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Lattice
import Mathbin.Data.Set.Pairwise.Basic

/-!
# Relations holding pairwise

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we prove many facts about `pairwise` and the set lattice.
-/


open Function Set Order

variable {α β γ ι ι' : Type _} {κ : Sort _} {r p q : α → α → Prop}

section Pairwise

variable {f g : ι → α} {s t u : Set α} {a b : α}

namespace Set

#print Set.pairwise_iUnion /-
theorem pairwise_iUnion {f : κ → Set α} (h : Directed (· ⊆ ·) f) :
    (⋃ n, f n).Pairwise r ↔ ∀ n, (f n).Pairwise r :=
  by
  constructor
  · intro H n
    exact Pairwise.mono (subset_Union _ _) H
  · intro H i hi j hj hij
    rcases mem_Union.1 hi with ⟨m, hm⟩
    rcases mem_Union.1 hj with ⟨n, hn⟩
    rcases h m n with ⟨p, mp, np⟩
    exact H p (mp hm) (np hn) hij
#align set.pairwise_Union Set.pairwise_iUnion
-/

#print Set.pairwise_sUnion /-
theorem pairwise_sUnion {r : α → α → Prop} {s : Set (Set α)} (h : DirectedOn (· ⊆ ·) s) :
    (⋃₀ s).Pairwise r ↔ ∀ a ∈ s, Set.Pairwise a r := by
  rw [sUnion_eq_Union, pairwise_Union h.directed_coe, SetCoe.forall]; rfl
#align set.pairwise_sUnion Set.pairwise_sUnion
-/

end Set

end Pairwise

namespace Set

section PartialOrderBot

variable [PartialOrder α] [OrderBot α] {s t : Set ι} {f g : ι → α}

#print Set.pairwiseDisjoint_iUnion /-
theorem pairwiseDisjoint_iUnion {g : ι' → Set ι} (h : Directed (· ⊆ ·) g) :
    (⋃ n, g n).PairwiseDisjoint f ↔ ∀ ⦃n⦄, (g n).PairwiseDisjoint f :=
  pairwise_iUnion h
#align set.pairwise_disjoint_Union Set.pairwiseDisjoint_iUnion
-/

#print Set.pairwiseDisjoint_sUnion /-
theorem pairwiseDisjoint_sUnion {s : Set (Set ι)} (h : DirectedOn (· ⊆ ·) s) :
    (⋃₀ s).PairwiseDisjoint f ↔ ∀ ⦃a⦄, a ∈ s → Set.PairwiseDisjoint a f :=
  pairwise_sUnion h
#align set.pairwise_disjoint_sUnion Set.pairwiseDisjoint_sUnion
-/

end PartialOrderBot

section CompleteLattice

variable [CompleteLattice α] {s : Set ι} {t : Set ι'}

#print Set.PairwiseDisjoint.biUnion /-
/-- Bind operation for `set.pairwise_disjoint`. If you want to only consider finsets of indices, you
can use `set.pairwise_disjoint.bUnion_finset`. -/
theorem PairwiseDisjoint.biUnion {s : Set ι'} {g : ι' → Set ι} {f : ι → α}
    (hs : s.PairwiseDisjoint fun i' : ι' => ⨆ i ∈ g i', f i)
    (hg : ∀ i ∈ s, (g i).PairwiseDisjoint f) : (⋃ i ∈ s, g i).PairwiseDisjoint f :=
  by
  rintro a ha b hb hab
  simp_rw [Set.mem_iUnion] at ha hb 
  obtain ⟨c, hc, ha⟩ := ha
  obtain ⟨d, hd, hb⟩ := hb
  obtain hcd | hcd := eq_or_ne (g c) (g d)
  · exact hg d hd (hcd.subst ha) hb hab
  · exact (hs hc hd <| ne_of_apply_ne _ hcd).mono (le_iSup₂ a ha) (le_iSup₂ b hb)
#align set.pairwise_disjoint.bUnion Set.PairwiseDisjoint.biUnion
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Set.PairwiseDisjoint.prod_left /-
/-- If the suprema of columns are pairwise disjoint and suprema of rows as well, then everything is
pairwise disjoint. Not to be confused with `set.pairwise_disjoint.prod`. -/
theorem PairwiseDisjoint.prod_left {f : ι × ι' → α}
    (hs : s.PairwiseDisjoint fun i => ⨆ i' ∈ t, f (i, i'))
    (ht : t.PairwiseDisjoint fun i' => ⨆ i ∈ s, f (i, i')) :
    (s ×ˢ t : Set (ι × ι')).PairwiseDisjoint f :=
  by
  rintro ⟨i, i'⟩ hi ⟨j, j'⟩ hj h
  rw [mem_prod] at hi hj 
  obtain rfl | hij := eq_or_ne i j
  · refine' (ht hi.2 hj.2 <| (Prod.mk.inj_left _).ne_iff.1 h).mono _ _
    · convert le_iSup₂ i hi.1; rfl
    · convert le_iSup₂ i hj.1; rfl
  · refine' (hs hi.1 hj.1 hij).mono _ _
    · convert le_iSup₂ i' hi.2; rfl
    · convert le_iSup₂ j' hj.2; rfl
#align set.pairwise_disjoint.prod_left Set.PairwiseDisjoint.prod_left
-/

end CompleteLattice

section Frame

variable [Frame α]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Set.pairwiseDisjoint_prod_left /-
theorem pairwiseDisjoint_prod_left {s : Set ι} {t : Set ι'} {f : ι × ι' → α} :
    (s ×ˢ t : Set (ι × ι')).PairwiseDisjoint f ↔
      (s.PairwiseDisjoint fun i => ⨆ i' ∈ t, f (i, i')) ∧
        t.PairwiseDisjoint fun i' => ⨆ i ∈ s, f (i, i') :=
  by
  refine'
        ⟨fun h => ⟨fun i hi j hj hij => _, fun i hi j hj hij => _⟩, fun h => h.1.prod_left h.2⟩ <;>
      simp_rw [Function.onFun, iSup_disjoint_iff, disjoint_iSup_iff] <;>
    intro i' hi' j' hj'
  · exact h (mk_mem_prod hi hi') (mk_mem_prod hj hj') (ne_of_apply_ne Prod.fst hij)
  · exact h (mk_mem_prod hi' hi) (mk_mem_prod hj' hj) (ne_of_apply_ne Prod.snd hij)
#align set.pairwise_disjoint_prod_left Set.pairwiseDisjoint_prod_left
-/

end Frame

#print Set.biUnion_diff_biUnion_eq /-
theorem biUnion_diff_biUnion_eq {s t : Set ι} {f : ι → Set α} (h : (s ∪ t).PairwiseDisjoint f) :
    ((⋃ i ∈ s, f i) \ ⋃ i ∈ t, f i) = ⋃ i ∈ s \ t, f i :=
  by
  refine'
    (bUnion_diff_bUnion_subset f s t).antisymm
      (Union₂_subset fun i hi a ha => (mem_diff _).2 ⟨mem_bUnion hi.1 ha, _⟩)
  rw [mem_Union₂]; rintro ⟨j, hj, haj⟩
  exact (h (Or.inl hi.1) (Or.inr hj) (ne_of_mem_of_not_mem hj hi.2).symm).le_bot ⟨ha, haj⟩
#align set.bUnion_diff_bUnion_eq Set.biUnion_diff_biUnion_eq
-/

#print Set.biUnionEqSigmaOfDisjoint /-
/-- Equivalence between a disjoint bounded union and a dependent sum. -/
noncomputable def biUnionEqSigmaOfDisjoint {s : Set ι} {f : ι → Set α} (h : s.PairwiseDisjoint f) :
    (⋃ i ∈ s, f i) ≃ Σ i : s, f i :=
  (Equiv.setCongr (biUnion_eq_iUnion _ _)).trans <|
    unionEqSigmaOfDisjoint fun ⟨i, hi⟩ ⟨j, hj⟩ ne => h hi hj fun eq => Ne <| Subtype.eq Eq
#align set.bUnion_eq_sigma_of_disjoint Set.biUnionEqSigmaOfDisjoint
-/

end Set

section

variable {f : ι → Set α} {s t : Set ι}

#print Set.PairwiseDisjoint.subset_of_biUnion_subset_biUnion /-
theorem Set.PairwiseDisjoint.subset_of_biUnion_subset_biUnion (h₀ : (s ∪ t).PairwiseDisjoint f)
    (h₁ : ∀ i ∈ s, (f i).Nonempty) (h : (⋃ i ∈ s, f i) ⊆ ⋃ i ∈ t, f i) : s ⊆ t :=
  by
  rintro i hi
  obtain ⟨a, hai⟩ := h₁ i hi
  obtain ⟨j, hj, haj⟩ := mem_Union₂.1 (h <| mem_Union₂_of_mem hi hai)
  rwa [h₀.eq (subset_union_left _ _ hi) (subset_union_right _ _ hj)
      (not_disjoint_iff.2 ⟨a, hai, haj⟩)]
#align set.pairwise_disjoint.subset_of_bUnion_subset_bUnion Set.PairwiseDisjoint.subset_of_biUnion_subset_biUnion
-/

#print Pairwise.subset_of_biUnion_subset_biUnion /-
theorem Pairwise.subset_of_biUnion_subset_biUnion (h₀ : Pairwise (Disjoint on f))
    (h₁ : ∀ i ∈ s, (f i).Nonempty) (h : (⋃ i ∈ s, f i) ⊆ ⋃ i ∈ t, f i) : s ⊆ t :=
  Set.PairwiseDisjoint.subset_of_biUnion_subset_biUnion (h₀.set_pairwise _) h₁ h
#align pairwise.subset_of_bUnion_subset_bUnion Pairwise.subset_of_biUnion_subset_biUnion
-/

#print Pairwise.biUnion_injective /-
theorem Pairwise.biUnion_injective (h₀ : Pairwise (Disjoint on f)) (h₁ : ∀ i, (f i).Nonempty) :
    Injective fun s : Set ι => ⋃ i ∈ s, f i := fun s t h =>
  ((h₀.subset_of_biUnion_subset_biUnion fun _ _ => h₁ _) <| h.Subset).antisymm <|
    (h₀.subset_of_biUnion_subset_biUnion fun _ _ => h₁ _) <| h.Superset
#align pairwise.bUnion_injective Pairwise.biUnion_injective
-/

end

