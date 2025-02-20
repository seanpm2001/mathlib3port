/-
Copyright (c) 2021 Aaron Anderson, Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Aaron Anderson, Kevin Buzzard, Yaël Dillies, Eric Wieser

! This file was ported from Lean 3 source module order.sup_indep
! leanprover-community/mathlib commit c4c2ed622f43768eff32608d4a0f8a6cec1c047d
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.Sigma
import Mathbin.Data.Finset.Pairwise
import Mathbin.Data.Finset.Powerset
import Mathbin.Data.Fintype.Basic

/-!
# Supremum independence

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file, we define supremum independence of indexed sets. An indexed family `f : ι → α` is
sup-independent if, for all `a`, `f a` and the supremum of the rest are disjoint.

## Main definitions

* `finset.sup_indep s f`: a family of elements `f` are supremum independent on the finite set `s`.
* `complete_lattice.set_independent s`: a set of elements are supremum independent.
* `complete_lattice.independent f`: a family of elements are supremum independent.

## Main statements

* In a distributive lattice, supremum independence is equivalent to pairwise disjointness:
  * `finset.sup_indep_iff_pairwise_disjoint`
  * `complete_lattice.set_independent_iff_pairwise_disjoint`
  * `complete_lattice.independent_iff_pairwise_disjoint`
* Otherwise, supremum independence is stronger than pairwise disjointness:
  * `finset.sup_indep.pairwise_disjoint`
  * `complete_lattice.set_independent.pairwise_disjoint`
  * `complete_lattice.independent.pairwise_disjoint`

## Implementation notes

For the finite version, we avoid the "obvious" definition
`∀ i ∈ s, disjoint (f i) ((s.erase i).sup f)` because `erase` would require decidable equality on
`ι`.
-/


variable {α β ι ι' : Type _}

/-! ### On lattices with a bottom element, via `finset.sup` -/


namespace Finset

section Lattice

variable [Lattice α] [OrderBot α]

#print Finset.SupIndep /-
/-- Supremum independence of finite sets. We avoid the "obvious" definition using `s.erase i`
because `erase` would require decidable equality on `ι`. -/
def SupIndep (s : Finset ι) (f : ι → α) : Prop :=
  ∀ ⦃t⦄, t ⊆ s → ∀ ⦃i⦄, i ∈ s → i ∉ t → Disjoint (f i) (t.sup f)
#align finset.sup_indep Finset.SupIndep
-/

variable {s t : Finset ι} {f : ι → α} {i : ι}

instance [DecidableEq ι] [DecidableEq α] : Decidable (SupIndep s f) :=
  by
  apply @Finset.decidableForallOfDecidableSubsets _ _ _ _
  intro t ht
  apply @Finset.decidableDforallFinset _ _ _ _
  exact fun i hi => @Implies.decidable _ _ _ (decidable_of_iff' (_ = ⊥) disjoint_iff)

#print Finset.SupIndep.subset /-
theorem SupIndep.subset (ht : t.SupIndep f) (h : s ⊆ t) : s.SupIndep f := fun u hu i hi =>
  ht (hu.trans h) (h hi)
#align finset.sup_indep.subset Finset.SupIndep.subset
-/

#print Finset.supIndep_empty /-
theorem supIndep_empty (f : ι → α) : (∅ : Finset ι).SupIndep f := fun _ _ a ha => ha.elim
#align finset.sup_indep_empty Finset.supIndep_empty
-/

#print Finset.supIndep_singleton /-
theorem supIndep_singleton (i : ι) (f : ι → α) : ({i} : Finset ι).SupIndep f := fun s hs j hji hj =>
  by
  rw [eq_empty_of_ssubset_singleton ⟨hs, fun h => hj (h hji)⟩, sup_empty]
  exact disjoint_bot_right
#align finset.sup_indep_singleton Finset.supIndep_singleton
-/

#print Finset.SupIndep.pairwiseDisjoint /-
theorem SupIndep.pairwiseDisjoint (hs : s.SupIndep f) : (s : Set ι).PairwiseDisjoint f :=
  fun a ha b hb hab =>
  sup_singleton.subst <| hs (singleton_subset_iff.2 hb) ha <| not_mem_singleton.2 hab
#align finset.sup_indep.pairwise_disjoint Finset.SupIndep.pairwiseDisjoint
-/

#print Finset.SupIndep.le_sup_iff /-
theorem SupIndep.le_sup_iff (hs : s.SupIndep f) (hts : t ⊆ s) (hi : i ∈ s) (hf : ∀ i, f i ≠ ⊥) :
    f i ≤ t.sup f ↔ i ∈ t := by
  refine' ⟨fun h => _, le_sup⟩
  by_contra hit
  exact hf i (disjoint_self.1 <| (hs hts hi hit).mono_right h)
#align finset.sup_indep.le_sup_iff Finset.SupIndep.le_sup_iff
-/

#print Finset.supIndep_iff_disjoint_erase /-
/-- The RHS looks like the definition of `complete_lattice.independent`. -/
theorem supIndep_iff_disjoint_erase [DecidableEq ι] :
    s.SupIndep f ↔ ∀ i ∈ s, Disjoint (f i) ((s.eraseₓ i).sup f) :=
  ⟨fun hs i hi => hs (erase_subset _ _) hi (not_mem_erase _ _), fun hs t ht i hi hit =>
    (hs i hi).mono_right (sup_mono fun j hj => mem_erase.2 ⟨ne_of_mem_of_not_mem hj hit, ht hj⟩)⟩
#align finset.sup_indep_iff_disjoint_erase Finset.supIndep_iff_disjoint_erase
-/

#print Finset.SupIndep.image /-
theorem SupIndep.image [DecidableEq ι] {s : Finset ι'} {g : ι' → ι} (hs : s.SupIndep (f ∘ g)) :
    (s.image g).SupIndep f := by
  intro t ht i hi hit
  rw [mem_image] at hi 
  obtain ⟨i, hi, rfl⟩ := hi
  haveI : DecidableEq ι' := Classical.decEq _
  suffices hts : t ⊆ (s.erase i).image g
  · refine' (sup_indep_iff_disjoint_erase.1 hs i hi).mono_right ((sup_mono hts).trans _)
    rw [sup_image]
  rintro j hjt
  obtain ⟨j, hj, rfl⟩ := mem_image.1 (ht hjt)
  exact mem_image_of_mem _ (mem_erase.2 ⟨ne_of_apply_ne g (ne_of_mem_of_not_mem hjt hit), hj⟩)
#align finset.sup_indep.image Finset.SupIndep.image
-/

#print Finset.supIndep_map /-
theorem supIndep_map {s : Finset ι'} {g : ι' ↪ ι} : (s.map g).SupIndep f ↔ s.SupIndep (f ∘ g) :=
  by
  refine' ⟨fun hs t ht i hi hit => _, fun hs => _⟩
  · rw [← sup_map]
    exact hs (map_subset_map.2 ht) ((mem_map' _).2 hi) (by rwa [mem_map'])
  ·
    classical
    rw [map_eq_image]
    exact hs.image
#align finset.sup_indep_map Finset.supIndep_map
-/

#print Finset.supIndep_pair /-
@[simp]
theorem supIndep_pair [DecidableEq ι] {i j : ι} (hij : i ≠ j) :
    ({i, j} : Finset ι).SupIndep f ↔ Disjoint (f i) (f j) :=
  ⟨fun h => h.PairwiseDisjoint (by simp) (by simp) hij, fun h =>
    by
    rw [sup_indep_iff_disjoint_erase]
    intro k hk
    rw [Finset.mem_insert, Finset.mem_singleton] at hk 
    obtain rfl | rfl := hk
    · convert h using 1
      rw [Finset.erase_insert, Finset.sup_singleton]
      simpa using hij
    · convert h.symm using 1
      have : ({i, k} : Finset ι).eraseₓ k = {i} := by
        ext
        rw [mem_erase, mem_insert, mem_singleton, mem_singleton, and_or_left, Ne.def,
          not_and_self_iff, or_false_iff, and_iff_right_of_imp]
        rintro rfl
        exact hij
      rw [this, Finset.sup_singleton]⟩
#align finset.sup_indep_pair Finset.supIndep_pair
-/

#print Finset.supIndep_univ_bool /-
theorem supIndep_univ_bool (f : Bool → α) :
    (Finset.univ : Finset Bool).SupIndep f ↔ Disjoint (f false) (f true) :=
  haveI : tt ≠ ff := by simp only [Ne.def, not_false_iff]
  (sup_indep_pair this).trans disjoint_comm
#align finset.sup_indep_univ_bool Finset.supIndep_univ_bool
-/

#print Finset.supIndep_univ_fin_two /-
@[simp]
theorem supIndep_univ_fin_two (f : Fin 2 → α) :
    (Finset.univ : Finset (Fin 2)).SupIndep f ↔ Disjoint (f 0) (f 1) :=
  haveI : (0 : Fin 2) ≠ 1 := by simp
  sup_indep_pair this
#align finset.sup_indep_univ_fin_two Finset.supIndep_univ_fin_two
-/

#print Finset.SupIndep.attach /-
theorem SupIndep.attach (hs : s.SupIndep f) : s.attach.SupIndep fun a => f a :=
  by
  intro t ht i _ hi
  classical
  rw [← Finset.sup_image]
  refine' hs (image_subset_iff.2 fun (j : { x // x ∈ s }) _ => j.2) i.2 fun hi' => hi _
  rw [mem_image] at hi' 
  obtain ⟨j, hj, hji⟩ := hi'
  rwa [Subtype.ext hji] at hj 
#align finset.sup_indep.attach Finset.SupIndep.attach
-/

#print Finset.supIndep_attach /-
@[simp]
theorem supIndep_attach : (s.attach.SupIndep fun a => f a) ↔ s.SupIndep f :=
  by
  refine' ⟨fun h t ht i his hit => _, sup_indep.attach⟩
  classical
  convert
    h (filter_subset (fun i => (i : ι) ∈ t) _) (mem_attach _ ⟨i, ‹_›⟩) fun hi =>
      hit <| by simpa using hi using
    1
  refine' eq_of_forall_ge_iff _
  simp only [Finset.sup_le_iff, mem_filter, mem_attach, true_and_iff, Function.comp_apply,
    Subtype.forall, Subtype.coe_mk]
  exact fun a => forall_congr' fun j => ⟨fun h _ => h, fun h hj => h (ht hj) hj⟩
#align finset.sup_indep_attach Finset.supIndep_attach
-/

end Lattice

section DistribLattice

variable [DistribLattice α] [OrderBot α] {s : Finset ι} {f : ι → α}

#print Finset.supIndep_iff_pairwiseDisjoint /-
theorem supIndep_iff_pairwiseDisjoint : s.SupIndep f ↔ (s : Set ι).PairwiseDisjoint f :=
  ⟨SupIndep.pairwiseDisjoint, fun hs t ht i hi hit =>
    Finset.disjoint_sup_right.2 fun j hj => hs hi (ht hj) (ne_of_mem_of_not_mem hj hit).symm⟩
#align finset.sup_indep_iff_pairwise_disjoint Finset.supIndep_iff_pairwiseDisjoint
-/

alias sup_indep_iff_pairwise_disjoint ↔ sup_indep.pairwise_disjoint
  _root_.set.pairwise_disjoint.sup_indep
#align finset.sup_indep.pairwise_disjoint Finset.SupIndep.pairwiseDisjoint
#align set.pairwise_disjoint.sup_indep Set.PairwiseDisjoint.supIndep

#print Finset.SupIndep.sup /-
/-- Bind operation for `sup_indep`. -/
theorem SupIndep.sup [DecidableEq ι] {s : Finset ι'} {g : ι' → Finset ι} {f : ι → α}
    (hs : s.SupIndep fun i => (g i).sup f) (hg : ∀ i' ∈ s, (g i').SupIndep f) :
    (s.sup g).SupIndep f :=
  by
  simp_rw [sup_indep_iff_pairwise_disjoint] at hs hg ⊢
  rw [sup_eq_bUnion, coe_bUnion]
  exact hs.bUnion_finset hg
#align finset.sup_indep.sup Finset.SupIndep.sup
-/

#print Finset.SupIndep.biUnion /-
/-- Bind operation for `sup_indep`. -/
theorem SupIndep.biUnion [DecidableEq ι] {s : Finset ι'} {g : ι' → Finset ι} {f : ι → α}
    (hs : s.SupIndep fun i => (g i).sup f) (hg : ∀ i' ∈ s, (g i').SupIndep f) :
    (s.biUnion g).SupIndep f := by rw [← sup_eq_bUnion]; exact hs.sup hg
#align finset.sup_indep.bUnion Finset.SupIndep.biUnion
-/

#print Finset.SupIndep.sigma /-
/-- Bind operation for `sup_indep`. -/
theorem SupIndep.sigma {β : ι → Type _} {s : Finset ι} {g : ∀ i, Finset (β i)} {f : Sigma β → α}
    (hs : s.SupIndep fun i => (g i).sup fun b => f ⟨i, b⟩)
    (hg : ∀ i ∈ s, (g i).SupIndep fun b => f ⟨i, b⟩) : (s.Sigma g).SupIndep f :=
  by
  rintro t ht ⟨i, b⟩ hi hit
  rw [Finset.disjoint_sup_right]
  rintro ⟨j, c⟩ hj
  have hbc := (ne_of_mem_of_not_mem hj hit).symm
  replace hj := ht hj
  rw [mem_sigma] at hi hj 
  obtain rfl | hij := eq_or_ne i j
  · exact (hg _ hj.1).PairwiseDisjoint hi.2 hj.2 (sigma_mk_injective.ne_iff.1 hbc)
  · refine' (hs.pairwise_disjoint hi.1 hj.1 hij).mono _ _
    · convert le_sup hi.2
    · convert le_sup hj.2
#align finset.sup_indep.sigma Finset.SupIndep.sigma
-/

#print Finset.SupIndep.product /-
theorem SupIndep.product {s : Finset ι} {t : Finset ι'} {f : ι × ι' → α}
    (hs : s.SupIndep fun i => t.sup fun i' => f (i, i'))
    (ht : t.SupIndep fun i' => s.sup fun i => f (i, i')) : (s.product t).SupIndep f :=
  by
  rintro u hu ⟨i, i'⟩ hi hiu
  rw [Finset.disjoint_sup_right]
  rintro ⟨j, j'⟩ hj
  have hij := (ne_of_mem_of_not_mem hj hiu).symm
  replace hj := hu hj
  rw [mem_product] at hi hj 
  obtain rfl | hij := eq_or_ne i j
  · refine' (ht.pairwise_disjoint hi.2 hj.2 <| (Prod.mk.inj_left _).ne_iff.1 hij).mono _ _
    · convert le_sup hi.1
    · convert le_sup hj.1
  · refine' (hs.pairwise_disjoint hi.1 hj.1 hij).mono _ _
    · convert le_sup hi.2
    · convert le_sup hj.2
#align finset.sup_indep.product Finset.SupIndep.product
-/

#print Finset.supIndep_product_iff /-
theorem supIndep_product_iff {s : Finset ι} {t : Finset ι'} {f : ι × ι' → α} :
    (s.product t).SupIndep f ↔
      (s.SupIndep fun i => t.sup fun i' => f (i, i')) ∧
        t.SupIndep fun i' => s.sup fun i => f (i, i') :=
  by
  refine' ⟨_, fun h => h.1.product h.2⟩
  simp_rw [sup_indep_iff_pairwise_disjoint]
  refine' fun h => ⟨fun i hi j hj hij => _, fun i hi j hj hij => _⟩ <;>
      simp_rw [Function.onFun, Finset.disjoint_sup_left, Finset.disjoint_sup_right] <;>
    intro i' hi' j' hj'
  · exact h (mk_mem_product hi hi') (mk_mem_product hj hj') (ne_of_apply_ne Prod.fst hij)
  · exact h (mk_mem_product hi' hi) (mk_mem_product hj' hj) (ne_of_apply_ne Prod.snd hij)
#align finset.sup_indep_product_iff Finset.supIndep_product_iff
-/

end DistribLattice

end Finset

/-! ### On complete lattices via `has_Sup.Sup` -/


namespace CompleteLattice

variable [CompleteLattice α]

open Set Function

#print CompleteLattice.SetIndependent /-
/-- An independent set of elements in a complete lattice is one in which every element is disjoint
  from the `Sup` of the rest. -/
def SetIndependent (s : Set α) : Prop :=
  ∀ ⦃a⦄, a ∈ s → Disjoint a (sSup (s \ {a}))
#align complete_lattice.set_independent CompleteLattice.SetIndependent
-/

variable {s : Set α} (hs : SetIndependent s)

#print CompleteLattice.setIndependent_empty /-
@[simp]
theorem setIndependent_empty : SetIndependent (∅ : Set α) := fun x hx =>
  (Set.not_mem_empty x hx).elim
#align complete_lattice.set_independent_empty CompleteLattice.setIndependent_empty
-/

#print CompleteLattice.SetIndependent.mono /-
theorem SetIndependent.mono {t : Set α} (hst : t ⊆ s) : SetIndependent t := fun a ha =>
  (hs (hst ha)).mono_right (sSup_le_sSup (diff_subset_diff_left hst))
#align complete_lattice.set_independent.mono CompleteLattice.SetIndependent.mono
-/

#print CompleteLattice.SetIndependent.pairwiseDisjoint /-
/-- If the elements of a set are independent, then any pair within that set is disjoint. -/
theorem SetIndependent.pairwiseDisjoint : s.PairwiseDisjoint id := fun x hx y hy h =>
  disjoint_sSup_right (hs hx) ((mem_diff y).mpr ⟨hy, h.symm⟩)
#align complete_lattice.set_independent.pairwise_disjoint CompleteLattice.SetIndependent.pairwiseDisjoint
-/

#print CompleteLattice.setIndependent_pair /-
theorem setIndependent_pair {a b : α} (hab : a ≠ b) :
    SetIndependent ({a, b} : Set α) ↔ Disjoint a b :=
  by
  constructor
  · intro h
    exact h.pairwise_disjoint (mem_insert _ _) (mem_insert_of_mem _ (mem_singleton _)) hab
  · rintro h c ((rfl : c = a) | (rfl : c = b))
    · convert h using 1
      simp [hab, sSup_singleton]
    · convert h.symm using 1
      simp [hab, sSup_singleton]
#align complete_lattice.set_independent_pair CompleteLattice.setIndependent_pair
-/

#print CompleteLattice.SetIndependent.disjoint_sSup /-
/-- If the elements of a set are independent, then any element is disjoint from the `Sup` of some
subset of the rest. -/
theorem SetIndependent.disjoint_sSup {x : α} {y : Set α} (hx : x ∈ s) (hy : y ⊆ s) (hxy : x ∉ y) :
    Disjoint x (sSup y) :=
  by
  have := (hs.mono <| insert_subset.mpr ⟨hx, hy⟩) (mem_insert x _)
  rw [insert_diff_of_mem _ (mem_singleton _), diff_singleton_eq_self hxy] at this 
  exact this
#align complete_lattice.set_independent.disjoint_Sup CompleteLattice.SetIndependent.disjoint_sSup
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print CompleteLattice.Independent /-
/-- An independent indexed family of elements in a complete lattice is one in which every element
  is disjoint from the `supr` of the rest.

  Example: an indexed family of non-zero elements in a
  vector space is linearly independent iff the indexed family of subspaces they generate is
  independent in this sense.

  Example: an indexed family of submodules of a module is independent in this sense if
  and only the natural map from the direct sum of the submodules to the module is injective. -/
def Independent {ι : Sort _} {α : Type _} [CompleteLattice α] (t : ι → α) : Prop :=
  ∀ i : ι, Disjoint (t i) (⨆ (j) (_ : j ≠ i), t j)
#align complete_lattice.independent CompleteLattice.Independent
-/

#print CompleteLattice.setIndependent_iff /-
theorem setIndependent_iff {α : Type _} [CompleteLattice α] (s : Set α) :
    SetIndependent s ↔ Independent (coe : s → α) :=
  by
  simp_rw [independent, set_independent, SetCoe.forall, sSup_eq_iSup]
  refine' forall₂_congr fun a ha => _
  congr 2
  convert supr_subtype.symm
  simp [iSup_and]
#align complete_lattice.set_independent_iff CompleteLattice.setIndependent_iff
-/

variable {t : ι → α} (ht : Independent t)

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print CompleteLattice.independent_def /-
theorem independent_def : Independent t ↔ ∀ i : ι, Disjoint (t i) (⨆ (j) (_ : j ≠ i), t j) :=
  Iff.rfl
#align complete_lattice.independent_def CompleteLattice.independent_def
-/

#print CompleteLattice.independent_def' /-
theorem independent_def' : Independent t ↔ ∀ i, Disjoint (t i) (sSup (t '' {j | j ≠ i})) := by
  simp_rw [sSup_image]; rfl
#align complete_lattice.independent_def' CompleteLattice.independent_def'
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (j «expr ≠ » i) -/
#print CompleteLattice.independent_def'' /-
theorem independent_def'' :
    Independent t ↔ ∀ i, Disjoint (t i) (sSup {a | ∃ (j : _) (_ : j ≠ i), t j = a}) := by
  rw [independent_def']; tidy
#align complete_lattice.independent_def'' CompleteLattice.independent_def''
-/

#print CompleteLattice.independent_empty /-
@[simp]
theorem independent_empty (t : Empty → α) : Independent t :=
  fun.
#align complete_lattice.independent_empty CompleteLattice.independent_empty
-/

#print CompleteLattice.independent_pempty /-
@[simp]
theorem independent_pempty (t : PEmpty → α) : Independent t :=
  fun.
#align complete_lattice.independent_pempty CompleteLattice.independent_pempty
-/

#print CompleteLattice.Independent.pairwiseDisjoint /-
/-- If the elements of a set are independent, then any pair within that set is disjoint. -/
theorem Independent.pairwiseDisjoint : Pairwise (Disjoint on t) := fun x y h =>
  disjoint_sSup_right (ht x) ⟨y, iSup_pos h.symm⟩
#align complete_lattice.independent.pairwise_disjoint CompleteLattice.Independent.pairwiseDisjoint
-/

#print CompleteLattice.Independent.mono /-
theorem Independent.mono {s t : ι → α} (hs : Independent s) (hst : t ≤ s) : Independent t :=
  fun i => (hs i).mono (hst i) <| iSup₂_mono fun j _ => hst j
#align complete_lattice.independent.mono CompleteLattice.Independent.mono
-/

#print CompleteLattice.Independent.comp /-
/-- Composing an independent indexed family with an injective function on the index results in
another indepedendent indexed family. -/
theorem Independent.comp {ι ι' : Sort _} {t : ι → α} {f : ι' → ι} (ht : Independent t)
    (hf : Injective f) : Independent (t ∘ f) := fun i =>
  (ht (f i)).mono_right <|
    by
    refine' (iSup_mono fun i => _).trans (iSup_comp_le _ f)
    exact iSup_const_mono hf.ne
#align complete_lattice.independent.comp CompleteLattice.Independent.comp
-/

#print CompleteLattice.Independent.comp' /-
theorem Independent.comp' {ι ι' : Sort _} {t : ι → α} {f : ι' → ι} (ht : Independent <| t ∘ f)
    (hf : Surjective f) : Independent t := by
  intro i
  obtain ⟨i', rfl⟩ := hf i
  rw [← hf.supr_comp]
  exact (ht i').mono_right (biSup_mono fun j' hij => mt (congr_arg f) hij)
#align complete_lattice.independent.comp' CompleteLattice.Independent.comp'
-/

#print CompleteLattice.Independent.setIndependent_range /-
theorem Independent.setIndependent_range (ht : Independent t) : SetIndependent <| range t :=
  by
  rw [set_independent_iff]
  rw [← coe_comp_range_factorization t] at ht 
  exact ht.comp' surjective_onto_range
#align complete_lattice.independent.set_independent_range CompleteLattice.Independent.setIndependent_range
-/

#print CompleteLattice.Independent.injective /-
theorem Independent.injective (ht : Independent t) (h_ne_bot : ∀ i, t i ≠ ⊥) : Injective t :=
  by
  intro i j h
  by_contra' contra
  apply h_ne_bot j
  suffices t j ≤ ⨆ (k) (hk : k ≠ i), t k
    by
    replace ht := (ht i).mono_right this
    rwa [h, disjoint_self] at ht 
  replace contra : j ≠ i; · exact Ne.symm contra
  exact le_iSup₂ j contra
#align complete_lattice.independent.injective CompleteLattice.Independent.injective
-/

#print CompleteLattice.independent_pair /-
theorem independent_pair {i j : ι} (hij : i ≠ j) (huniv : ∀ k, k = i ∨ k = j) :
    Independent t ↔ Disjoint (t i) (t j) := by
  constructor
  · exact fun h => h.PairwiseDisjoint hij
  · rintro h k
    obtain rfl | rfl := huniv k
    · refine' h.mono_right (iSup_le fun i => iSup_le fun hi => Eq.le _)
      rw [(huniv i).resolve_left hi]
    · refine' h.symm.mono_right (iSup_le fun j => iSup_le fun hj => Eq.le _)
      rw [(huniv j).resolve_right hj]
#align complete_lattice.independent_pair CompleteLattice.independent_pair
-/

#print CompleteLattice.Independent.map_orderIso /-
/-- Composing an indepedent indexed family with an order isomorphism on the elements results in
another indepedendent indexed family. -/
theorem Independent.map_orderIso {ι : Sort _} {α β : Type _} [CompleteLattice α] [CompleteLattice β]
    (f : α ≃o β) {a : ι → α} (ha : Independent a) : Independent (f ∘ a) := fun i =>
  ((ha i).map_orderIso f).mono_right (f.Monotone.le_map_iSup₂ _)
#align complete_lattice.independent.map_order_iso CompleteLattice.Independent.map_orderIso
-/

#print CompleteLattice.independent_map_orderIso_iff /-
@[simp]
theorem independent_map_orderIso_iff {ι : Sort _} {α β : Type _} [CompleteLattice α]
    [CompleteLattice β] (f : α ≃o β) {a : ι → α} : Independent (f ∘ a) ↔ Independent a :=
  ⟨fun h =>
    have hf : f.symm ∘ f ∘ a = a := congr_arg (· ∘ a) f.left_inv.comp_eq_id
    hf ▸ h.map_orderIso f.symm,
    fun h => h.map_orderIso f⟩
#align complete_lattice.independent_map_order_iso_iff CompleteLattice.independent_map_orderIso_iff
-/

#print CompleteLattice.Independent.disjoint_biSup /-
/-- If the elements of a set are independent, then any element is disjoint from the `supr` of some
subset of the rest. -/
theorem Independent.disjoint_biSup {ι : Type _} {α : Type _} [CompleteLattice α] {t : ι → α}
    (ht : Independent t) {x : ι} {y : Set ι} (hx : x ∉ y) : Disjoint (t x) (⨆ i ∈ y, t i) :=
  Disjoint.mono_right (biSup_mono fun i hi => (ne_of_mem_of_not_mem hi hx : _)) (ht x)
#align complete_lattice.independent.disjoint_bsupr CompleteLattice.Independent.disjoint_biSup
-/

end CompleteLattice

#print CompleteLattice.independent_iff_supIndep /-
theorem CompleteLattice.independent_iff_supIndep [CompleteLattice α] {s : Finset ι} {f : ι → α} :
    CompleteLattice.Independent (f ∘ (coe : s → ι)) ↔ s.SupIndep f := by
  classical
  rw [Finset.supIndep_iff_disjoint_erase]
  refine' subtype.forall.trans (forall₂_congr fun a b => _)
  rw [Finset.sup_eq_iSup]
  congr 2
  refine' supr_subtype.trans _
  congr 1 with x
  simp [iSup_and, @iSup_comm _ (x ∈ s)]
#align complete_lattice.independent_iff_sup_indep CompleteLattice.independent_iff_supIndep
-/

alias CompleteLattice.independent_iff_supIndep ↔ CompleteLattice.Independent.supIndep
  Finset.SupIndep.independent
#align complete_lattice.independent.sup_indep CompleteLattice.Independent.supIndep
#align finset.sup_indep.independent Finset.SupIndep.independent

#print CompleteLattice.independent_iff_supIndep_univ /-
/-- A variant of `complete_lattice.independent_iff_sup_indep` for `fintype`s. -/
theorem CompleteLattice.independent_iff_supIndep_univ [CompleteLattice α] [Fintype ι] {f : ι → α} :
    CompleteLattice.Independent f ↔ Finset.univ.SupIndep f := by
  classical simp [Finset.supIndep_iff_disjoint_erase, CompleteLattice.Independent,
    Finset.sup_eq_iSup]
#align complete_lattice.independent_iff_sup_indep_univ CompleteLattice.independent_iff_supIndep_univ
-/

alias CompleteLattice.independent_iff_supIndep_univ ↔ CompleteLattice.Independent.sup_indep_univ
  Finset.SupIndep.independent_of_univ
#align complete_lattice.independent.sup_indep_univ CompleteLattice.Independent.sup_indep_univ
#align finset.sup_indep.independent_of_univ Finset.SupIndep.independent_of_univ

section Frame

namespace CompleteLattice

variable [Order.Frame α]

#print CompleteLattice.setIndependent_iff_pairwiseDisjoint /-
theorem setIndependent_iff_pairwiseDisjoint {s : Set α} :
    SetIndependent s ↔ s.PairwiseDisjoint id :=
  ⟨SetIndependent.pairwiseDisjoint, fun hs i hi =>
    disjoint_sSup_iff.2 fun j hj => hs hi hj.1 <| Ne.symm hj.2⟩
#align complete_lattice.set_independent_iff_pairwise_disjoint CompleteLattice.setIndependent_iff_pairwiseDisjoint
-/

alias set_independent_iff_pairwise_disjoint ↔ _ _root_.set.pairwise_disjoint.set_independent
#align set.pairwise_disjoint.set_independent Set.PairwiseDisjoint.setIndependent

#print CompleteLattice.independent_iff_pairwiseDisjoint /-
theorem independent_iff_pairwiseDisjoint {f : ι → α} : Independent f ↔ Pairwise (Disjoint on f) :=
  ⟨Independent.pairwiseDisjoint, fun hs i =>
    disjoint_iSup_iff.2 fun j => disjoint_iSup_iff.2 fun hij => hs hij.symm⟩
#align complete_lattice.independent_iff_pairwise_disjoint CompleteLattice.independent_iff_pairwiseDisjoint
-/

end CompleteLattice

end Frame

