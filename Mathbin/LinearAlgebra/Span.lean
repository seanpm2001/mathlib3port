/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Kevin Buzzard, Yury Kudryashov, Frédéric Dupuis,
  Heather Macbeth

! This file was ported from Lean 3 source module linear_algebra.span
! leanprover-community/mathlib commit 10878f6bf1dab863445907ab23fbfcefcb5845d0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.LinearAlgebra.Basic
import Mathbin.Order.CompactlyGenerated
import Mathbin.Order.OmegaCompletePartialOrder

/-!
# The span of a set of vectors, as a submodule

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

* `submodule.span s` is defined to be the smallest submodule containing the set `s`.

## Notations

* We introduce the notation `R ∙ v` for the span of a singleton, `submodule.span R {v}`.  This is
  `\.`, not the same as the scalar multiplication `•`/`\bub`.

-/


variable {R R₂ K M M₂ V S : Type _}

namespace Submodule

open Function Set

open scoped Pointwise

section AddCommMonoid

variable [Semiring R] [AddCommMonoid M] [Module R M]

variable {x : M} (p p' : Submodule R M)

variable [Semiring R₂] {σ₁₂ : R →+* R₂}

variable [AddCommMonoid M₂] [Module R₂ M₂]

section

variable (R)

#print Submodule.span /-
/-- The span of a set `s ⊆ M` is the smallest submodule of M that contains `s`. -/
def span (s : Set M) : Submodule R M :=
  sInf {p | s ⊆ p}
#align submodule.span Submodule.span
-/

end

variable {s t : Set M}

#print Submodule.mem_span /-
theorem mem_span : x ∈ span R s ↔ ∀ p : Submodule R M, s ⊆ p → x ∈ p :=
  mem_iInter₂
#align submodule.mem_span Submodule.mem_span
-/

#print Submodule.subset_span /-
theorem subset_span : s ⊆ span R s := fun x h => mem_span.2 fun p hp => hp h
#align submodule.subset_span Submodule.subset_span
-/

#print Submodule.span_le /-
theorem span_le {p} : span R s ≤ p ↔ s ⊆ p :=
  ⟨Subset.trans subset_span, fun ss x h => mem_span.1 h _ ss⟩
#align submodule.span_le Submodule.span_le
-/

#print Submodule.span_mono /-
theorem span_mono (h : s ⊆ t) : span R s ≤ span R t :=
  span_le.2 <| Subset.trans h subset_span
#align submodule.span_mono Submodule.span_mono
-/

#print Submodule.span_monotone /-
theorem span_monotone : Monotone (span R : Set M → Submodule R M) := fun _ _ => span_mono
#align submodule.span_monotone Submodule.span_monotone
-/

#print Submodule.span_eq_of_le /-
theorem span_eq_of_le (h₁ : s ⊆ p) (h₂ : p ≤ span R s) : span R s = p :=
  le_antisymm (span_le.2 h₁) h₂
#align submodule.span_eq_of_le Submodule.span_eq_of_le
-/

#print Submodule.span_eq /-
theorem span_eq : span R (p : Set M) = p :=
  span_eq_of_le _ (Subset.refl _) subset_span
#align submodule.span_eq Submodule.span_eq
-/

#print Submodule.span_eq_span /-
theorem span_eq_span (hs : s ⊆ span R t) (ht : t ⊆ span R s) : span R s = span R t :=
  le_antisymm (span_le.2 hs) (span_le.2 ht)
#align submodule.span_eq_span Submodule.span_eq_span
-/

#print Submodule.span_coe_eq_restrictScalars /-
/-- A version of `submodule.span_eq` for when the span is by a smaller ring. -/
@[simp]
theorem span_coe_eq_restrictScalars [Semiring S] [SMul S R] [Module S M] [IsScalarTower S R M] :
    span S (p : Set M) = p.restrictScalars S :=
  span_eq (p.restrictScalars S)
#align submodule.span_coe_eq_restrict_scalars Submodule.span_coe_eq_restrictScalars
-/

#print Submodule.map_span /-
theorem map_span [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) (s : Set M) :
    (span R s).map f = span R₂ (f '' s) :=
  Eq.symm <|
    span_eq_of_le _ (Set.image_subset f subset_span) <|
      map_le_iff_le_comap.2 <| span_le.2 fun x hx => subset_span ⟨x, hx, rfl⟩
#align submodule.map_span Submodule.map_span
-/

alias Submodule.map_span ← _root_.linear_map.map_span
#align linear_map.map_span LinearMap.map_span

#print Submodule.map_span_le /-
theorem map_span_le [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) (s : Set M) (N : Submodule R₂ M₂) :
    map f (span R s) ≤ N ↔ ∀ m ∈ s, f m ∈ N :=
  by
  rw [f.map_span, span_le, Set.image_subset_iff]
  exact Iff.rfl
#align submodule.map_span_le Submodule.map_span_le
-/

alias Submodule.map_span_le ← _root_.linear_map.map_span_le
#align linear_map.map_span_le LinearMap.map_span_le

#print Submodule.span_insert_zero /-
@[simp]
theorem span_insert_zero : span R (insert (0 : M) s) = span R s :=
  by
  refine' le_antisymm _ (Submodule.span_mono (Set.subset_insert 0 s))
  rw [span_le, Set.insert_subset_iff]
  exact ⟨by simp only [SetLike.mem_coe, Submodule.zero_mem], Submodule.subset_span⟩
#align submodule.span_insert_zero Submodule.span_insert_zero
-/

#print Submodule.span_preimage_le /-
-- See also `span_preimage_eq` below.
theorem span_preimage_le (f : M →ₛₗ[σ₁₂] M₂) (s : Set M₂) :
    span R (f ⁻¹' s) ≤ (span R₂ s).comap f := by rw [span_le, comap_coe];
  exact preimage_mono subset_span
#align submodule.span_preimage_le Submodule.span_preimage_le
-/

alias Submodule.span_preimage_le ← _root_.linear_map.span_preimage_le
#align linear_map.span_preimage_le LinearMap.span_preimage_le

#print Submodule.closure_subset_span /-
theorem closure_subset_span {s : Set M} : (AddSubmonoid.closure s : Set M) ⊆ span R s :=
  (@AddSubmonoid.closure_le _ _ _ (span R s).toAddSubmonoid).mpr subset_span
#align submodule.closure_subset_span Submodule.closure_subset_span
-/

#print Submodule.closure_le_toAddSubmonoid_span /-
theorem closure_le_toAddSubmonoid_span {s : Set M} :
    AddSubmonoid.closure s ≤ (span R s).toAddSubmonoid :=
  closure_subset_span
#align submodule.closure_le_to_add_submonoid_span Submodule.closure_le_toAddSubmonoid_span
-/

#print Submodule.span_closure /-
@[simp]
theorem span_closure {s : Set M} : span R (AddSubmonoid.closure s : Set M) = span R s :=
  le_antisymm (span_le.mpr closure_subset_span) (span_mono AddSubmonoid.subset_closure)
#align submodule.span_closure Submodule.span_closure
-/

#print Submodule.span_induction /-
/-- An induction principle for span membership. If `p` holds for 0 and all elements of `s`, and is
preserved under addition and scalar multiplication, then `p` holds for all elements of the span of
`s`. -/
@[elab_as_elim]
theorem span_induction {p : M → Prop} (h : x ∈ span R s) (Hs : ∀ x ∈ s, p x) (H0 : p 0)
    (H1 : ∀ x y, p x → p y → p (x + y)) (H2 : ∀ (a : R) (x), p x → p (a • x)) : p x :=
  (@span_le _ _ _ _ _ _ ⟨p, H1, H0, H2⟩).2 Hs h
#align submodule.span_induction Submodule.span_induction
-/

#print Submodule.span_induction' /-
/-- A dependent version of `submodule.span_induction`. -/
theorem span_induction' {p : ∀ x, x ∈ span R s → Prop} (Hs : ∀ (x) (h : x ∈ s), p x (subset_span h))
    (H0 : p 0 (Submodule.zero_mem _))
    (H1 : ∀ x hx y hy, p x hx → p y hy → p (x + y) (Submodule.add_mem _ ‹_› ‹_›))
    (H2 : ∀ (a : R) (x hx), p x hx → p (a • x) (Submodule.smul_mem _ _ ‹_›)) {x}
    (hx : x ∈ span R s) : p x hx :=
  by
  refine' Exists.elim _ fun (hx : x ∈ span R s) (hc : p x hx) => hc
  refine'
    span_induction hx (fun m hm => ⟨subset_span hm, Hs m hm⟩) ⟨zero_mem _, H0⟩
      (fun x y hx hy =>
        Exists.elim hx fun hx' hx =>
          Exists.elim hy fun hy' hy => ⟨add_mem hx' hy', H1 _ _ _ _ hx hy⟩)
      fun r x hx => Exists.elim hx fun hx' hx => ⟨smul_mem _ _ hx', H2 r _ _ hx⟩
#align submodule.span_induction' Submodule.span_induction'
-/

#print Submodule.span_span_coe_preimage /-
@[simp]
theorem span_span_coe_preimage : span R ((coe : span R s → M) ⁻¹' s) = ⊤ :=
  eq_top_iff.2 fun x =>
    Subtype.recOn x fun x hx _ =>
      by
      refine' span_induction' (fun x hx => _) _ (fun x y _ _ => _) (fun r x _ => _) hx
      · exact subset_span hx
      · exact zero_mem _
      · exact add_mem
      · exact smul_mem _ _
#align submodule.span_span_coe_preimage Submodule.span_span_coe_preimage
-/

#print Submodule.span_nat_eq_addSubmonoid_closure /-
theorem span_nat_eq_addSubmonoid_closure (s : Set M) :
    (span ℕ s).toAddSubmonoid = AddSubmonoid.closure s :=
  by
  refine' Eq.symm (AddSubmonoid.closure_eq_of_le subset_span _)
  apply add_submonoid.to_nat_submodule.symm.to_galois_connection.l_le _
  rw [span_le]
  exact AddSubmonoid.subset_closure
#align submodule.span_nat_eq_add_submonoid_closure Submodule.span_nat_eq_addSubmonoid_closure
-/

#print Submodule.span_nat_eq /-
@[simp]
theorem span_nat_eq (s : AddSubmonoid M) : (span ℕ (s : Set M)).toAddSubmonoid = s := by
  rw [span_nat_eq_add_submonoid_closure, s.closure_eq]
#align submodule.span_nat_eq Submodule.span_nat_eq
-/

#print Submodule.span_int_eq_addSubgroup_closure /-
theorem span_int_eq_addSubgroup_closure {M : Type _} [AddCommGroup M] (s : Set M) :
    (span ℤ s).toAddSubgroup = AddSubgroup.closure s :=
  Eq.symm <|
    AddSubgroup.closure_eq_of_le _ subset_span fun x hx =>
      span_induction hx (fun x hx => AddSubgroup.subset_closure hx) (AddSubgroup.zero_mem _)
        (fun _ _ => AddSubgroup.add_mem _) fun _ _ _ => AddSubgroup.zsmul_mem _ ‹_› _
#align submodule.span_int_eq_add_subgroup_closure Submodule.span_int_eq_addSubgroup_closure
-/

#print Submodule.span_int_eq /-
@[simp]
theorem span_int_eq {M : Type _} [AddCommGroup M] (s : AddSubgroup M) :
    (span ℤ (s : Set M)).toAddSubgroup = s := by rw [span_int_eq_add_subgroup_closure, s.closure_eq]
#align submodule.span_int_eq Submodule.span_int_eq
-/

section

variable (R M)

#print Submodule.gi /-
/-- `span` forms a Galois insertion with the coercion from submodule to set. -/
protected def gi : GaloisInsertion (@span R M _ _ _) coe
    where
  choice s _ := span R s
  gc s t := span_le
  le_l_u s := subset_span
  choice_eq s h := rfl
#align submodule.gi Submodule.gi
-/

end

#print Submodule.span_empty /-
@[simp]
theorem span_empty : span R (∅ : Set M) = ⊥ :=
  (Submodule.gi R M).gc.l_bot
#align submodule.span_empty Submodule.span_empty
-/

#print Submodule.span_univ /-
@[simp]
theorem span_univ : span R (univ : Set M) = ⊤ :=
  eq_top_iff.2 <| SetLike.le_def.2 <| subset_span
#align submodule.span_univ Submodule.span_univ
-/

#print Submodule.span_union /-
theorem span_union (s t : Set M) : span R (s ∪ t) = span R s ⊔ span R t :=
  (Submodule.gi R M).gc.l_sup
#align submodule.span_union Submodule.span_union
-/

#print Submodule.span_iUnion /-
theorem span_iUnion {ι} (s : ι → Set M) : span R (⋃ i, s i) = ⨆ i, span R (s i) :=
  (Submodule.gi R M).gc.l_iSup
#align submodule.span_Union Submodule.span_iUnion
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print Submodule.span_iUnion₂ /-
theorem span_iUnion₂ {ι} {κ : ι → Sort _} (s : ∀ i, κ i → Set M) :
    span R (⋃ (i) (j), s i j) = ⨆ (i) (j), span R (s i j) :=
  (Submodule.gi R M).gc.l_iSup₂
#align submodule.span_Union₂ Submodule.span_iUnion₂
-/

#print Submodule.span_attach_biUnion /-
theorem span_attach_biUnion [DecidableEq M] {α : Type _} (s : Finset α) (f : s → Finset M) :
    span R (s.attach.biUnion f : Set M) = ⨆ x, span R (f x) := by simpa [span_Union]
#align submodule.span_attach_bUnion Submodule.span_attach_biUnion
-/

#print Submodule.sup_span /-
theorem sup_span : p ⊔ span R s = span R (p ∪ s) := by rw [Submodule.span_union, p.span_eq]
#align submodule.sup_span Submodule.sup_span
-/

#print Submodule.span_sup /-
theorem span_sup : span R s ⊔ p = span R (s ∪ p) := by rw [Submodule.span_union, p.span_eq]
#align submodule.span_sup Submodule.span_sup
-/

notation:1000
  /- Note that the character `∙` U+2219 used below is different from the scalar multiplication
character `•` U+2022 and the matrix multiplication character `⬝` U+2B1D. -/
R " ∙ " x => span R (@singleton _ _ Set.hasSingleton x)

#print Submodule.span_eq_iSup_of_singleton_spans /-
theorem span_eq_iSup_of_singleton_spans (s : Set M) : span R s = ⨆ x ∈ s, R ∙ x := by
  simp only [← span_Union, Set.biUnion_of_singleton s]
#align submodule.span_eq_supr_of_singleton_spans Submodule.span_eq_iSup_of_singleton_spans
-/

#print Submodule.span_range_eq_iSup /-
theorem span_range_eq_iSup {ι : Type _} {v : ι → M} : span R (range v) = ⨆ i, R ∙ v i := by
  rw [span_eq_supr_of_singleton_spans, iSup_range]
#align submodule.span_range_eq_supr Submodule.span_range_eq_iSup
-/

#print Submodule.span_smul_le /-
theorem span_smul_le (s : Set M) (r : R) : span R (r • s) ≤ span R s :=
  by
  rw [span_le]
  rintro _ ⟨x, hx, rfl⟩
  exact smul_mem (span R s) r (subset_span hx)
#align submodule.span_smul_le Submodule.span_smul_le
-/

#print Submodule.subset_span_trans /-
theorem subset_span_trans {U V W : Set M} (hUV : U ⊆ Submodule.span R V)
    (hVW : V ⊆ Submodule.span R W) : U ⊆ Submodule.span R W :=
  (Submodule.gi R M).gc.le_u_l_trans hUV hVW
#align submodule.subset_span_trans Submodule.subset_span_trans
-/

#print Submodule.span_smul_eq_of_isUnit /-
/-- See `submodule.span_smul_eq` (in `ring_theory.ideal.operations`) for
`span R (r • s) = r • span R s` that holds for arbitrary `r` in a `comm_semiring`. -/
theorem span_smul_eq_of_isUnit (s : Set M) (r : R) (hr : IsUnit r) : span R (r • s) = span R s :=
  by
  apply le_antisymm
  · apply span_smul_le
  · convert span_smul_le (r • s) ((hr.unit⁻¹ : _) : R)
    rw [smul_smul]
    erw [hr.unit.inv_val]
    rw [one_smul]
#align submodule.span_smul_eq_of_is_unit Submodule.span_smul_eq_of_isUnit
-/

#print Submodule.coe_iSup_of_directed /-
@[simp]
theorem coe_iSup_of_directed {ι} [hι : Nonempty ι] (S : ι → Submodule R M)
    (H : Directed (· ≤ ·) S) : ((iSup S : Submodule R M) : Set M) = ⋃ i, S i :=
  by
  refine' subset.antisymm _ (Union_subset <| le_iSup S)
  suffices (span R (⋃ i, (S i : Set M)) : Set M) ⊆ ⋃ i : ι, ↑(S i) by
    simpa only [span_Union, span_eq] using this
  refine' fun x hx => span_induction hx (fun _ => id) _ _ _ <;> simp only [mem_Union, exists_imp]
  · exact hι.elim fun i => ⟨i, (S i).zero_mem⟩
  · intro x y i hi j hj
    rcases H i j with ⟨k, ik, jk⟩
    exact ⟨k, add_mem (ik hi) (jk hj)⟩
  · exact fun a x i hi => ⟨i, smul_mem _ a hi⟩
#align submodule.coe_supr_of_directed Submodule.coe_iSup_of_directed
-/

#print Submodule.mem_iSup_of_directed /-
@[simp]
theorem mem_iSup_of_directed {ι} [Nonempty ι] (S : ι → Submodule R M) (H : Directed (· ≤ ·) S) {x} :
    x ∈ iSup S ↔ ∃ i, x ∈ S i := by rw [← SetLike.mem_coe, coe_supr_of_directed S H, mem_Union]; rfl
#align submodule.mem_supr_of_directed Submodule.mem_iSup_of_directed
-/

#print Submodule.mem_sSup_of_directed /-
theorem mem_sSup_of_directed {s : Set (Submodule R M)} {z} (hs : s.Nonempty)
    (hdir : DirectedOn (· ≤ ·) s) : z ∈ sSup s ↔ ∃ y ∈ s, z ∈ y :=
  by
  haveI : Nonempty s := hs.to_subtype
  simp only [sSup_eq_iSup', mem_supr_of_directed _ hdir.directed_coe, SetCoe.exists, Subtype.coe_mk]
#align submodule.mem_Sup_of_directed Submodule.mem_sSup_of_directed
-/

#print Submodule.coe_iSup_of_chain /-
@[norm_cast, simp]
theorem coe_iSup_of_chain (a : ℕ →o Submodule R M) : (↑(⨆ k, a k) : Set M) = ⋃ k, (a k : Set M) :=
  coe_iSup_of_directed a a.Monotone.directed_le
#align submodule.coe_supr_of_chain Submodule.coe_iSup_of_chain
-/

#print Submodule.coe_scott_continuous /-
/-- We can regard `coe_supr_of_chain` as the statement that `coe : (submodule R M) → set M` is
Scott continuous for the ω-complete partial order induced by the complete lattice structures. -/
theorem coe_scott_continuous :
    OmegaCompletePartialOrder.Continuous' (coe : Submodule R M → Set M) :=
  ⟨SetLike.coe_mono, coe_iSup_of_chain⟩
#align submodule.coe_scott_continuous Submodule.coe_scott_continuous
-/

#print Submodule.mem_iSup_of_chain /-
@[simp]
theorem mem_iSup_of_chain (a : ℕ →o Submodule R M) (m : M) : (m ∈ ⨆ k, a k) ↔ ∃ k, m ∈ a k :=
  mem_iSup_of_directed a a.Monotone.directed_le
#align submodule.mem_supr_of_chain Submodule.mem_iSup_of_chain
-/

section

variable {p p'}

#print Submodule.mem_sup /-
theorem mem_sup : x ∈ p ⊔ p' ↔ ∃ y ∈ p, ∃ z ∈ p', y + z = x :=
  ⟨fun h => by
    rw [← span_eq p, ← span_eq p', ← span_union] at h 
    apply span_induction h
    · rintro y (h | h)
      · exact ⟨y, h, 0, by simp, by simp⟩
      · exact ⟨0, by simp, y, h, by simp⟩
    · exact ⟨0, by simp, 0, by simp⟩
    · rintro _ _ ⟨y₁, hy₁, z₁, hz₁, rfl⟩ ⟨y₂, hy₂, z₂, hz₂, rfl⟩
      exact ⟨_, add_mem hy₁ hy₂, _, add_mem hz₁ hz₂, by simp [add_assoc] <;> cc⟩
    · rintro a _ ⟨y, hy, z, hz, rfl⟩
      exact ⟨_, smul_mem _ a hy, _, smul_mem _ a hz, by simp [smul_add]⟩, by
    rintro ⟨y, hy, z, hz, rfl⟩ <;>
      exact add_mem ((le_sup_left : p ≤ p ⊔ p') hy) ((le_sup_right : p' ≤ p ⊔ p') hz)⟩
#align submodule.mem_sup Submodule.mem_sup
-/

#print Submodule.mem_sup' /-
theorem mem_sup' : x ∈ p ⊔ p' ↔ ∃ (y : p) (z : p'), (y : M) + z = x :=
  mem_sup.trans <| by simp only [SetLike.exists, coe_mk]
#align submodule.mem_sup' Submodule.mem_sup'
-/

variable (p p')

#print Submodule.coe_sup /-
theorem coe_sup : ↑(p ⊔ p') = (p + p' : Set M) := by ext;
  rw [SetLike.mem_coe, mem_sup, Set.mem_add]; simp
#align submodule.coe_sup Submodule.coe_sup
-/

#print Submodule.sup_toAddSubmonoid /-
theorem sup_toAddSubmonoid : (p ⊔ p').toAddSubmonoid = p.toAddSubmonoid ⊔ p'.toAddSubmonoid :=
  by
  ext x
  rw [mem_to_add_submonoid, mem_sup, AddSubmonoid.mem_sup]
  rfl
#align submodule.sup_to_add_submonoid Submodule.sup_toAddSubmonoid
-/

#print Submodule.sup_toAddSubgroup /-
theorem sup_toAddSubgroup {R M : Type _} [Ring R] [AddCommGroup M] [Module R M]
    (p p' : Submodule R M) : (p ⊔ p').toAddSubgroup = p.toAddSubgroup ⊔ p'.toAddSubgroup :=
  by
  ext x
  rw [mem_to_add_subgroup, mem_sup, AddSubgroup.mem_sup]
  rfl
#align submodule.sup_to_add_subgroup Submodule.sup_toAddSubgroup
-/

end

#print Submodule.mem_span_singleton_self /-
theorem mem_span_singleton_self (x : M) : x ∈ R ∙ x :=
  subset_span rfl
#align submodule.mem_span_singleton_self Submodule.mem_span_singleton_self
-/

#print Submodule.nontrivial_span_singleton /-
theorem nontrivial_span_singleton {x : M} (h : x ≠ 0) : Nontrivial (R ∙ x) :=
  ⟨by
    use 0, x, Submodule.mem_span_singleton_self x
    intro H
    rw [eq_comm, Submodule.mk_eq_zero] at H 
    exact h H⟩
#align submodule.nontrivial_span_singleton Submodule.nontrivial_span_singleton
-/

#print Submodule.mem_span_singleton /-
theorem mem_span_singleton {y : M} : (x ∈ R ∙ y) ↔ ∃ a : R, a • y = x :=
  ⟨fun h => by
    apply span_induction h
    · rintro y (rfl | ⟨⟨⟩⟩); exact ⟨1, by simp⟩
    · exact ⟨0, by simp⟩
    · rintro _ _ ⟨a, rfl⟩ ⟨b, rfl⟩
      exact ⟨a + b, by simp [add_smul]⟩
    · rintro a _ ⟨b, rfl⟩
      exact ⟨a * b, by simp [smul_smul]⟩, by
    rintro ⟨a, y, rfl⟩ <;> exact smul_mem _ _ (subset_span <| by simp)⟩
#align submodule.mem_span_singleton Submodule.mem_span_singleton
-/

#print Submodule.le_span_singleton_iff /-
theorem le_span_singleton_iff {s : Submodule R M} {v₀ : M} :
    (s ≤ R ∙ v₀) ↔ ∀ v ∈ s, ∃ r : R, r • v₀ = v := by simp_rw [SetLike.le_def, mem_span_singleton]
#align submodule.le_span_singleton_iff Submodule.le_span_singleton_iff
-/

variable (R)

#print Submodule.span_singleton_eq_top_iff /-
theorem span_singleton_eq_top_iff (x : M) : (R ∙ x) = ⊤ ↔ ∀ v, ∃ r : R, r • x = v := by
  rw [eq_top_iff, le_span_singleton_iff]; tauto
#align submodule.span_singleton_eq_top_iff Submodule.span_singleton_eq_top_iff
-/

#print Submodule.span_zero_singleton /-
@[simp]
theorem span_zero_singleton : (R ∙ (0 : M)) = ⊥ := by ext; simp [mem_span_singleton, eq_comm]
#align submodule.span_zero_singleton Submodule.span_zero_singleton
-/

#print Submodule.span_singleton_eq_range /-
theorem span_singleton_eq_range (y : M) : ↑(R ∙ y) = range ((· • y) : R → M) :=
  Set.ext fun x => mem_span_singleton
#align submodule.span_singleton_eq_range Submodule.span_singleton_eq_range
-/

#print Submodule.span_singleton_smul_le /-
theorem span_singleton_smul_le {S} [Monoid S] [SMul S R] [MulAction S M] [IsScalarTower S R M]
    (r : S) (x : M) : (R ∙ r • x) ≤ R ∙ x :=
  by
  rw [span_le, Set.singleton_subset_iff, SetLike.mem_coe]
  exact smul_of_tower_mem _ _ (mem_span_singleton_self _)
#align submodule.span_singleton_smul_le Submodule.span_singleton_smul_le
-/

#print Submodule.span_singleton_group_smul_eq /-
theorem span_singleton_group_smul_eq {G} [Group G] [SMul G R] [MulAction G M] [IsScalarTower G R M]
    (g : G) (x : M) : (R ∙ g • x) = R ∙ x :=
  by
  refine' le_antisymm (span_singleton_smul_le R g x) _
  convert span_singleton_smul_le R g⁻¹ (g • x)
  exact (inv_smul_smul g x).symm
#align submodule.span_singleton_group_smul_eq Submodule.span_singleton_group_smul_eq
-/

variable {R}

#print Submodule.span_singleton_smul_eq /-
theorem span_singleton_smul_eq {r : R} (hr : IsUnit r) (x : M) : (R ∙ r • x) = R ∙ x :=
  by
  lift r to Rˣ using hr
  rw [← Units.smul_def]
  exact span_singleton_group_smul_eq R r x
#align submodule.span_singleton_smul_eq Submodule.span_singleton_smul_eq
-/

#print Submodule.disjoint_span_singleton /-
theorem disjoint_span_singleton {K E : Type _} [DivisionRing K] [AddCommGroup E] [Module K E]
    {s : Submodule K E} {x : E} : Disjoint s (K ∙ x) ↔ x ∈ s → x = 0 :=
  by
  refine' disjoint_def.trans ⟨fun H hx => H x hx <| subset_span <| mem_singleton x, _⟩
  intro H y hy hyx
  obtain ⟨c, rfl⟩ := mem_span_singleton.1 hyx
  by_cases hc : c = 0
  · rw [hc, zero_smul]
  · rw [s.smul_mem_iff hc] at hy 
    rw [H hy, smul_zero]
#align submodule.disjoint_span_singleton Submodule.disjoint_span_singleton
-/

#print Submodule.disjoint_span_singleton' /-
theorem disjoint_span_singleton' {K E : Type _} [DivisionRing K] [AddCommGroup E] [Module K E]
    {p : Submodule K E} {x : E} (x0 : x ≠ 0) : Disjoint p (K ∙ x) ↔ x ∉ p :=
  disjoint_span_singleton.trans ⟨fun h₁ h₂ => x0 (h₁ h₂), fun h₁ h₂ => (h₁ h₂).elim⟩
#align submodule.disjoint_span_singleton' Submodule.disjoint_span_singleton'
-/

#print Submodule.mem_span_singleton_trans /-
theorem mem_span_singleton_trans {x y z : M} (hxy : x ∈ R ∙ y) (hyz : y ∈ R ∙ z) : x ∈ R ∙ z :=
  by
  rw [← SetLike.mem_coe, ← singleton_subset_iff] at *
  exact Submodule.subset_span_trans hxy hyz
#align submodule.mem_span_singleton_trans Submodule.mem_span_singleton_trans
-/

#print Submodule.mem_span_insert /-
theorem mem_span_insert {y} : x ∈ span R (insert y s) ↔ ∃ a : R, ∃ z ∈ span R s, x = a • y + z :=
  by
  simp only [← union_singleton, span_union, mem_sup, mem_span_singleton, exists_prop,
    exists_exists_eq_and]
  rw [exists_comm]
  simp only [eq_comm, add_comm, exists_and_left]
#align submodule.mem_span_insert Submodule.mem_span_insert
-/

#print Submodule.mem_span_pair /-
theorem mem_span_pair {x y z : M} : z ∈ span R ({x, y} : Set M) ↔ ∃ a b : R, a • x + b • y = z := by
  simp_rw [mem_span_insert, mem_span_singleton, exists_prop, exists_exists_eq_and, eq_comm]
#align submodule.mem_span_pair Submodule.mem_span_pair
-/

#print Submodule.span_insert /-
theorem span_insert (x) (s : Set M) : span R (insert x s) = span R ({x} : Set M) ⊔ span R s := by
  rw [insert_eq, span_union]
#align submodule.span_insert Submodule.span_insert
-/

#print Submodule.span_insert_eq_span /-
theorem span_insert_eq_span (h : x ∈ span R s) : span R (insert x s) = span R s :=
  span_eq_of_le _ (Set.insert_subset_iff.mpr ⟨h, subset_span⟩) (span_mono <| subset_insert _ _)
#align submodule.span_insert_eq_span Submodule.span_insert_eq_span
-/

#print Submodule.span_span /-
theorem span_span : span R (span R s : Set M) = span R s :=
  span_eq _
#align submodule.span_span Submodule.span_span
-/

variable (R S s)

#print Submodule.span_le_restrictScalars /-
/-- If `R` is "smaller" ring than `S` then the span by `R` is smaller than the span by `S`. -/
theorem span_le_restrictScalars [Semiring S] [SMul R S] [Module S M] [IsScalarTower R S M] :
    span R s ≤ (span S s).restrictScalars R :=
  Submodule.span_le.2 Submodule.subset_span
#align submodule.span_le_restrict_scalars Submodule.span_le_restrictScalars
-/

#print Submodule.span_subset_span /-
/-- A version of `submodule.span_le_restrict_scalars` with coercions. -/
@[simp]
theorem span_subset_span [Semiring S] [SMul R S] [Module S M] [IsScalarTower R S M] :
    ↑(span R s) ⊆ (span S s : Set M) :=
  span_le_restrictScalars R S s
#align submodule.span_subset_span Submodule.span_subset_span
-/

#print Submodule.span_span_of_tower /-
/-- Taking the span by a large ring of the span by the small ring is the same as taking the span
by just the large ring. -/
theorem span_span_of_tower [Semiring S] [SMul R S] [Module S M] [IsScalarTower R S M] :
    span S (span R s : Set M) = span S s :=
  le_antisymm (span_le.2 <| span_subset_span R S s) (span_mono subset_span)
#align submodule.span_span_of_tower Submodule.span_span_of_tower
-/

variable {R S s}

#print Submodule.span_eq_bot /-
theorem span_eq_bot : span R (s : Set M) = ⊥ ↔ ∀ x ∈ s, (x : M) = 0 :=
  eq_bot_iff.trans
    ⟨fun H x h => (mem_bot R).1 <| H <| subset_span h, fun H =>
      span_le.2 fun x h => (mem_bot R).2 <| H x h⟩
#align submodule.span_eq_bot Submodule.span_eq_bot
-/

#print Submodule.span_singleton_eq_bot /-
@[simp]
theorem span_singleton_eq_bot : (R ∙ x) = ⊥ ↔ x = 0 :=
  span_eq_bot.trans <| by simp
#align submodule.span_singleton_eq_bot Submodule.span_singleton_eq_bot
-/

#print Submodule.span_zero /-
@[simp]
theorem span_zero : span R (0 : Set M) = ⊥ := by rw [← singleton_zero, span_singleton_eq_bot]
#align submodule.span_zero Submodule.span_zero
-/

#print Submodule.span_singleton_eq_span_singleton /-
theorem span_singleton_eq_span_singleton {R M : Type _} [Ring R] [AddCommGroup M] [Module R M]
    [NoZeroSMulDivisors R M] {x y : M} : ((R ∙ x) = R ∙ y) ↔ ∃ z : Rˣ, z • x = y :=
  by
  by_cases hx : x = 0
  · rw [hx, span_zero_singleton, eq_comm, span_singleton_eq_bot]
    exact ⟨fun hy => ⟨1, by rw [hy, smul_zero]⟩, fun ⟨_, hz⟩ => by rw [← hz, smul_zero]⟩
  by_cases hy : y = 0
  · rw [hy, span_zero_singleton, span_singleton_eq_bot]
    exact ⟨fun hx => ⟨1, by rw [hx, smul_zero]⟩, fun ⟨z, hz⟩ => (smul_eq_zero_iff_eq z).mp hz⟩
  constructor
  · intro hxy
    cases' mem_span_singleton.mp (by rw [hxy]; apply mem_span_singleton_self) with v hv
    cases' mem_span_singleton.mp (by rw [← hxy]; apply mem_span_singleton_self) with i hi
    have vi : v * i = 1 := by rw [← one_smul R y, ← hi, smul_smul] at hv ;
      exact smul_left_injective R hy hv
    have iv : i * v = 1 := by rw [← one_smul R x, ← hv, smul_smul] at hi ;
      exact smul_left_injective R hx hi
    exact ⟨⟨v, i, vi, iv⟩, hv⟩
  · rintro ⟨v, rfl⟩
    rw [span_singleton_group_smul_eq]
#align submodule.span_singleton_eq_span_singleton Submodule.span_singleton_eq_span_singleton
-/

#print Submodule.span_image /-
@[simp]
theorem span_image [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) :
    span R₂ (f '' s) = map f (span R s) :=
  (map_span f s).symm
#align submodule.span_image Submodule.span_image
-/

#print Submodule.apply_mem_span_image_of_mem_span /-
theorem apply_mem_span_image_of_mem_span [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) {x : M}
    {s : Set M} (h : x ∈ Submodule.span R s) : f x ∈ Submodule.span R₂ (f '' s) :=
  by
  rw [Submodule.span_image]
  exact Submodule.mem_map_of_mem h
#align submodule.apply_mem_span_image_of_mem_span Submodule.apply_mem_span_image_of_mem_span
-/

#print Submodule.map_subtype_span_singleton /-
@[simp]
theorem map_subtype_span_singleton {p : Submodule R M} (x : p) :
    map p.Subtype (R ∙ x) = R ∙ (x : M) := by simp [← span_image]
#align submodule.map_subtype_span_singleton Submodule.map_subtype_span_singleton
-/

#print Submodule.not_mem_span_of_apply_not_mem_span_image /-
/-- `f` is an explicit argument so we can `apply` this theorem and obtain `h` as a new goal. -/
theorem not_mem_span_of_apply_not_mem_span_image [RingHomSurjective σ₁₂] (f : M →ₛₗ[σ₁₂] M₂) {x : M}
    {s : Set M} (h : f x ∉ Submodule.span R₂ (f '' s)) : x ∉ Submodule.span R s :=
  h.imp (apply_mem_span_image_of_mem_span f)
#align submodule.not_mem_span_of_apply_not_mem_span_image Submodule.not_mem_span_of_apply_not_mem_span_image
-/

#print Submodule.iSup_span /-
theorem iSup_span {ι : Sort _} (p : ι → Set M) : (⨆ i, span R (p i)) = span R (⋃ i, p i) :=
  le_antisymm (iSup_le fun i => span_mono <| subset_iUnion _ i) <|
    span_le.mpr <| iUnion_subset fun i m hm => mem_iSup_of_mem i <| subset_span hm
#align submodule.supr_span Submodule.iSup_span
-/

#print Submodule.iSup_eq_span /-
theorem iSup_eq_span {ι : Sort _} (p : ι → Submodule R M) : (⨆ i, p i) = span R (⋃ i, ↑(p i)) := by
  simp_rw [← supr_span, span_eq]
#align submodule.supr_eq_span Submodule.iSup_eq_span
-/

#print Submodule.iSup_toAddSubmonoid /-
theorem iSup_toAddSubmonoid {ι : Sort _} (p : ι → Submodule R M) :
    (⨆ i, p i).toAddSubmonoid = ⨆ i, (p i).toAddSubmonoid :=
  by
  refine' le_antisymm (fun x => _) (iSup_le fun i => to_add_submonoid_mono <| le_iSup _ i)
  simp_rw [supr_eq_span, AddSubmonoid.iSup_eq_closure, mem_to_add_submonoid, coe_to_add_submonoid]
  intro hx
  refine' Submodule.span_induction hx (fun x hx => _) _ (fun x y hx hy => _) fun r x hx => _
  · exact AddSubmonoid.subset_closure hx
  · exact AddSubmonoid.zero_mem _
  · exact AddSubmonoid.add_mem _ hx hy
  · apply AddSubmonoid.closure_induction hx
    · rintro x ⟨_, ⟨i, rfl⟩, hix : x ∈ p i⟩
      apply AddSubmonoid.subset_closure (set.mem_Union.mpr ⟨i, _⟩)
      exact smul_mem _ r hix
    · rw [smul_zero]
      exact AddSubmonoid.zero_mem _
    · intro x y hx hy
      rw [smul_add]
      exact AddSubmonoid.add_mem _ hx hy
#align submodule.supr_to_add_submonoid Submodule.iSup_toAddSubmonoid
-/

#print Submodule.iSup_induction /-
/-- An induction principle for elements of `⨆ i, p i`.
If `C` holds for `0` and all elements of `p i` for all `i`, and is preserved under addition,
then it holds for all elements of the supremum of `p`. -/
@[elab_as_elim]
theorem iSup_induction {ι : Sort _} (p : ι → Submodule R M) {C : M → Prop} {x : M}
    (hx : x ∈ ⨆ i, p i) (hp : ∀ (i), ∀ x ∈ p i, C x) (h0 : C 0)
    (hadd : ∀ x y, C x → C y → C (x + y)) : C x :=
  by
  rw [← mem_to_add_submonoid, supr_to_add_submonoid] at hx 
  exact AddSubmonoid.iSup_induction _ hx hp h0 hadd
#align submodule.supr_induction Submodule.iSup_induction
-/

#print Submodule.iSup_induction' /-
/-- A dependent version of `submodule.supr_induction`. -/
@[elab_as_elim]
theorem iSup_induction' {ι : Sort _} (p : ι → Submodule R M) {C : ∀ x, (x ∈ ⨆ i, p i) → Prop}
    (hp : ∀ (i), ∀ x ∈ p i, C x (mem_iSup_of_mem i ‹_›)) (h0 : C 0 (zero_mem _))
    (hadd : ∀ x y hx hy, C x hx → C y hy → C (x + y) (add_mem ‹_› ‹_›)) {x : M}
    (hx : x ∈ ⨆ i, p i) : C x hx :=
  by
  refine' Exists.elim _ fun (hx : x ∈ ⨆ i, p i) (hc : C x hx) => hc
  refine' supr_induction p hx (fun i x hx => _) _ fun x y => _
  · exact ⟨_, hp _ _ hx⟩
  · exact ⟨_, h0⟩
  · rintro ⟨_, Cx⟩ ⟨_, Cy⟩
    refine' ⟨_, hadd _ _ _ _ Cx Cy⟩
#align submodule.supr_induction' Submodule.iSup_induction'
-/

#print Submodule.span_singleton_le_iff_mem /-
@[simp]
theorem span_singleton_le_iff_mem (m : M) (p : Submodule R M) : (R ∙ m) ≤ p ↔ m ∈ p := by
  rw [span_le, singleton_subset_iff, SetLike.mem_coe]
#align submodule.span_singleton_le_iff_mem Submodule.span_singleton_le_iff_mem
-/

#print Submodule.singleton_span_isCompactElement /-
theorem singleton_span_isCompactElement (x : M) :
    CompleteLattice.IsCompactElement (span R {x} : Submodule R M) :=
  by
  rw [CompleteLattice.isCompactElement_iff_le_of_directed_sSup_le]
  intro d hemp hdir hsup
  have : x ∈ Sup d := (set_like.le_def.mp hsup) (mem_span_singleton_self x)
  obtain ⟨y, ⟨hyd, hxy⟩⟩ := (mem_Sup_of_directed hemp hdir).mp this
  exact ⟨y, ⟨hyd, by simpa only [span_le, singleton_subset_iff]⟩⟩
#align submodule.singleton_span_is_compact_element Submodule.singleton_span_isCompactElement
-/

#print Submodule.finset_span_isCompactElement /-
/-- The span of a finite subset is compact in the lattice of submodules. -/
theorem finset_span_isCompactElement (S : Finset M) :
    CompleteLattice.IsCompactElement (span R S : Submodule R M) :=
  by
  rw [span_eq_supr_of_singleton_spans]
  simp only [Finset.mem_coe]
  rw [← Finset.sup_eq_iSup]
  exact
    CompleteLattice.finset_sup_compact_of_compact S fun x _ => singleton_span_is_compact_element x
#align submodule.finset_span_is_compact_element Submodule.finset_span_isCompactElement
-/

#print Submodule.finite_span_isCompactElement /-
/-- The span of a finite subset is compact in the lattice of submodules. -/
theorem finite_span_isCompactElement (S : Set M) (h : S.Finite) :
    CompleteLattice.IsCompactElement (span R S : Submodule R M) :=
  Finite.coe_toFinset h ▸ finset_span_isCompactElement h.toFinset
#align submodule.finite_span_is_compact_element Submodule.finite_span_isCompactElement
-/

instance : IsCompactlyGenerated (Submodule R M) :=
  ⟨fun s =>
    ⟨(fun x => span R {x}) '' s,
      ⟨fun t ht => by
        rcases(Set.mem_image _ _ _).1 ht with ⟨x, hx, rfl⟩
        apply singleton_span_is_compact_element, by
        rw [sSup_eq_iSup, iSup_image, ← span_eq_supr_of_singleton_spans, span_eq]⟩⟩⟩

#print Submodule.submodule_eq_sSup_le_nonzero_spans /-
/-- A submodule is equal to the supremum of the spans of the submodule's nonzero elements. -/
theorem submodule_eq_sSup_le_nonzero_spans (p : Submodule R M) :
    p = sSup {T : Submodule R M | ∃ (m : M) (hm : m ∈ p) (hz : m ≠ 0), T = span R {m}} :=
  by
  let S := {T : Submodule R M | ∃ (m : M) (hm : m ∈ p) (hz : m ≠ 0), T = span R {m}}
  apply le_antisymm
  · intro m hm; by_cases h : m = 0
    · rw [h]; simp
    · exact @le_sSup _ _ S _ ⟨m, ⟨hm, ⟨h, rfl⟩⟩⟩ m (mem_span_singleton_self m)
  · rw [sSup_le_iff]; rintro S ⟨_, ⟨_, ⟨_, rfl⟩⟩⟩; rwa [span_singleton_le_iff_mem]
#align submodule.submodule_eq_Sup_le_nonzero_spans Submodule.submodule_eq_sSup_le_nonzero_spans
-/

#print Submodule.lt_sup_iff_not_mem /-
theorem lt_sup_iff_not_mem {I : Submodule R M} {a : M} : (I < I ⊔ R ∙ a) ↔ a ∉ I :=
  by
  constructor
  · intro h
    by_contra akey
    have h1 : (I ⊔ R ∙ a) ≤ I := by
      simp only [sup_le_iff]
      constructor
      · exact le_refl I
      · exact (span_singleton_le_iff_mem a I).mpr akey
    have h2 := gt_of_ge_of_gt h1 h
    exact lt_irrefl I h2
  · intro h
    apply set_like.lt_iff_le_and_exists.mpr; constructor
    simp only [le_sup_left]
    use a
    constructor; swap; · assumption
    · have : (R ∙ a) ≤ I ⊔ R ∙ a := le_sup_right
      exact this (mem_span_singleton_self a)
#align submodule.lt_sup_iff_not_mem Submodule.lt_sup_iff_not_mem
-/

#print Submodule.mem_iSup /-
theorem mem_iSup {ι : Sort _} (p : ι → Submodule R M) {m : M} :
    (m ∈ ⨆ i, p i) ↔ ∀ N, (∀ i, p i ≤ N) → m ∈ N :=
  by
  rw [← span_singleton_le_iff_mem, le_iSup_iff]
  simp only [span_singleton_le_iff_mem]
#align submodule.mem_supr Submodule.mem_iSup
-/

section

open scoped Classical

#print Submodule.mem_span_finite_of_mem_span /-
/-- For every element in the span of a set, there exists a finite subset of the set
such that the element is contained in the span of the subset. -/
theorem mem_span_finite_of_mem_span {S : Set M} {x : M} (hx : x ∈ span R S) :
    ∃ T : Finset M, ↑T ⊆ S ∧ x ∈ span R (T : Set M) :=
  by
  refine' span_induction hx (fun x hx => _) _ _ _
  · refine' ⟨{x}, _, _⟩
    · rwa [Finset.coe_singleton, Set.singleton_subset_iff]
    · rw [Finset.coe_singleton]
      exact Submodule.mem_span_singleton_self x
  · use ∅; simp
  · rintro x y ⟨X, hX, hxX⟩ ⟨Y, hY, hyY⟩
    refine' ⟨X ∪ Y, _, _⟩
    · rw [Finset.coe_union]
      exact Set.union_subset hX hY
    rw [Finset.coe_union, span_union, mem_sup]
    exact ⟨x, hxX, y, hyY, rfl⟩
  · rintro a x ⟨T, hT, h2⟩
    exact ⟨T, hT, smul_mem _ _ h2⟩
#align submodule.mem_span_finite_of_mem_span Submodule.mem_span_finite_of_mem_span
-/

end

variable {M' : Type _} [AddCommMonoid M'] [Module R M'] (q₁ q₁' : Submodule R M')

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Submodule.prod /-
/-- The product of two submodules is a submodule. -/
def prod : Submodule R (M × M') :=
  {
    p.toAddSubmonoid.Prod q₁.toAddSubmonoid with
    carrier := p ×ˢ q₁
    smul_mem' := by rintro a ⟨x, y⟩ ⟨hx, hy⟩ <;> exact ⟨smul_mem _ a hx, smul_mem _ a hy⟩ }
#align submodule.prod Submodule.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Submodule.prod_coe /-
@[simp]
theorem prod_coe : (prod p q₁ : Set (M × M')) = p ×ˢ q₁ :=
  rfl
#align submodule.prod_coe Submodule.prod_coe
-/

#print Submodule.mem_prod /-
@[simp]
theorem mem_prod {p : Submodule R M} {q : Submodule R M'} {x : M × M'} :
    x ∈ prod p q ↔ x.1 ∈ p ∧ x.2 ∈ q :=
  Set.mem_prod
#align submodule.mem_prod Submodule.mem_prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Submodule.span_prod_le /-
theorem span_prod_le (s : Set M) (t : Set M') : span R (s ×ˢ t) ≤ prod (span R s) (span R t) :=
  span_le.2 <| Set.prod_mono subset_span subset_span
#align submodule.span_prod_le Submodule.span_prod_le
-/

#print Submodule.prod_top /-
@[simp]
theorem prod_top : (prod ⊤ ⊤ : Submodule R (M × M')) = ⊤ := by ext <;> simp
#align submodule.prod_top Submodule.prod_top
-/

#print Submodule.prod_bot /-
@[simp]
theorem prod_bot : (prod ⊥ ⊥ : Submodule R (M × M')) = ⊥ := by ext ⟨x, y⟩ <;> simp [Prod.zero_eq_mk]
#align submodule.prod_bot Submodule.prod_bot
-/

#print Submodule.prod_mono /-
theorem prod_mono {p p' : Submodule R M} {q q' : Submodule R M'} :
    p ≤ p' → q ≤ q' → prod p q ≤ prod p' q' :=
  prod_mono
#align submodule.prod_mono Submodule.prod_mono
-/

#print Submodule.prod_inf_prod /-
@[simp]
theorem prod_inf_prod : prod p q₁ ⊓ prod p' q₁' = prod (p ⊓ p') (q₁ ⊓ q₁') :=
  SetLike.coe_injective Set.prod_inter_prod
#align submodule.prod_inf_prod Submodule.prod_inf_prod
-/

#print Submodule.prod_sup_prod /-
@[simp]
theorem prod_sup_prod : prod p q₁ ⊔ prod p' q₁' = prod (p ⊔ p') (q₁ ⊔ q₁') :=
  by
  refine'
    le_antisymm (sup_le (prod_mono le_sup_left le_sup_left) (prod_mono le_sup_right le_sup_right)) _
  simp [SetLike.le_def]; intro xx yy hxx hyy
  rcases mem_sup.1 hxx with ⟨x, hx, x', hx', rfl⟩
  rcases mem_sup.1 hyy with ⟨y, hy, y', hy', rfl⟩
  refine' mem_sup.2 ⟨(x, y), ⟨hx, hy⟩, (x', y'), ⟨hx', hy'⟩, rfl⟩
#align submodule.prod_sup_prod Submodule.prod_sup_prod
-/

end AddCommMonoid

section AddCommGroup

variable [Ring R] [AddCommGroup M] [Module R M]

#print Submodule.span_neg /-
@[simp]
theorem span_neg (s : Set M) : span R (-s) = span R s :=
  calc
    span R (-s) = span R ((-LinearMap.id : M →ₗ[R] M) '' s) := by simp
    _ = map (-LinearMap.id) (span R s) := ((-LinearMap.id).map_span _).symm
    _ = span R s := by simp
#align submodule.span_neg Submodule.span_neg
-/

#print Submodule.mem_span_insert' /-
theorem mem_span_insert' {x y} {s : Set M} :
    x ∈ span R (insert y s) ↔ ∃ a : R, x + a • y ∈ span R s :=
  by
  rw [mem_span_insert]; constructor
  · rintro ⟨a, z, hz, rfl⟩; exact ⟨-a, by simp [hz, add_assoc]⟩
  · rintro ⟨a, h⟩; exact ⟨-a, _, h, by simp [add_comm, add_left_comm]⟩
#align submodule.mem_span_insert' Submodule.mem_span_insert'
-/

instance : IsModularLattice (Submodule R M) :=
  ⟨fun x y z xz a ha => by
    rw [mem_inf, mem_sup] at ha 
    rcases ha with ⟨⟨b, hb, c, hc, rfl⟩, haz⟩
    rw [mem_sup]
    refine' ⟨b, hb, c, mem_inf.2 ⟨hc, _⟩, rfl⟩
    rw [← add_sub_cancel c b, add_comm]
    apply z.sub_mem haz (xz hb)⟩

end AddCommGroup

section AddCommGroup

variable [Semiring R] [Semiring R₂]

variable [AddCommGroup M] [Module R M] [AddCommGroup M₂] [Module R₂ M₂]

variable {τ₁₂ : R →+* R₂} [RingHomSurjective τ₁₂]

variable {F : Type _} [sc : SemilinearMapClass F τ₁₂ M M₂]

#print Submodule.comap_map_eq /-
theorem comap_map_eq (f : F) (p : Submodule R M) : comap f (map f p) = p ⊔ LinearMap.ker f :=
  by
  refine' le_antisymm _ (sup_le (le_comap_map _ _) (comap_mono bot_le))
  rintro x ⟨y, hy, e⟩
  exact mem_sup.2 ⟨y, hy, x - y, by simpa using sub_eq_zero.2 e.symm, by simp⟩
#align submodule.comap_map_eq Submodule.comap_map_eq
-/

#print Submodule.comap_map_eq_self /-
theorem comap_map_eq_self {f : F} {p : Submodule R M} (h : LinearMap.ker f ≤ p) :
    comap f (map f p) = p := by rw [Submodule.comap_map_eq, sup_of_le_left h]
#align submodule.comap_map_eq_self Submodule.comap_map_eq_self
-/

end AddCommGroup

end Submodule

namespace LinearMap

open Submodule Function

section AddCommGroup

variable [Semiring R] [Semiring R₂]

variable [AddCommGroup M] [AddCommGroup M₂]

variable [Module R M] [Module R₂ M₂]

variable {τ₁₂ : R →+* R₂} [RingHomSurjective τ₁₂]

variable {F : Type _} [sc : SemilinearMapClass F τ₁₂ M M₂]

#print LinearMap.map_le_map_iff /-
protected theorem map_le_map_iff (f : F) {p p'} : map f p ≤ map f p' ↔ p ≤ p' ⊔ ker f := by
  rw [map_le_iff_le_comap, Submodule.comap_map_eq]
#align linear_map.map_le_map_iff LinearMap.map_le_map_iff
-/

#print LinearMap.map_le_map_iff' /-
theorem map_le_map_iff' {f : F} (hf : ker f = ⊥) {p p'} : map f p ≤ map f p' ↔ p ≤ p' := by
  rw [LinearMap.map_le_map_iff, hf, sup_bot_eq]
#align linear_map.map_le_map_iff' LinearMap.map_le_map_iff'
-/

#print LinearMap.map_injective /-
theorem map_injective {f : F} (hf : ker f = ⊥) : Injective (map f) := fun p p' h =>
  le_antisymm ((map_le_map_iff' hf).1 (le_of_eq h)) ((map_le_map_iff' hf).1 (ge_of_eq h))
#align linear_map.map_injective LinearMap.map_injective
-/

#print LinearMap.map_eq_top_iff /-
theorem map_eq_top_iff {f : F} (hf : range f = ⊤) {p : Submodule R M} :
    p.map f = ⊤ ↔ p ⊔ LinearMap.ker f = ⊤ := by
  simp_rw [← top_le_iff, ← hf, range_eq_map, LinearMap.map_le_map_iff]
#align linear_map.map_eq_top_iff LinearMap.map_eq_top_iff
-/

end AddCommGroup

section

variable (R) (M) [Semiring R] [AddCommMonoid M] [Module R M]

#print LinearMap.toSpanSingleton /-
/-- Given an element `x` of a module `M` over `R`, the natural map from
    `R` to scalar multiples of `x`.-/
@[simps]
def toSpanSingleton (x : M) : R →ₗ[R] M :=
  LinearMap.id.smul_right x
#align linear_map.to_span_singleton LinearMap.toSpanSingleton
-/

#print LinearMap.span_singleton_eq_range /-
/-- The range of `to_span_singleton x` is the span of `x`.-/
theorem span_singleton_eq_range (x : M) : (R ∙ x) = (toSpanSingleton R M x).range :=
  Submodule.ext fun y => by refine' Iff.trans _ linear_map.mem_range.symm; exact mem_span_singleton
#align linear_map.span_singleton_eq_range LinearMap.span_singleton_eq_range
-/

#print LinearMap.toSpanSingleton_one /-
@[simp]
theorem toSpanSingleton_one (x : M) : toSpanSingleton R M x 1 = x :=
  one_smul _ _
#align linear_map.to_span_singleton_one LinearMap.toSpanSingleton_one
-/

#print LinearMap.toSpanSingleton_zero /-
@[simp]
theorem toSpanSingleton_zero : toSpanSingleton R M 0 = 0 := by ext; simp
#align linear_map.to_span_singleton_zero LinearMap.toSpanSingleton_zero
-/

end

section AddCommMonoid

variable [Semiring R] [AddCommMonoid M] [Module R M]

variable [Semiring R₂] [AddCommMonoid M₂] [Module R₂ M₂]

variable {σ₁₂ : R →+* R₂}

#print LinearMap.eqOn_span /-
/-- If two linear maps are equal on a set `s`, then they are equal on `submodule.span s`.

See also `linear_map.eq_on_span'` for a version using `set.eq_on`. -/
theorem eqOn_span {s : Set M} {f g : M →ₛₗ[σ₁₂] M₂} (H : Set.EqOn f g s) ⦃x⦄ (h : x ∈ span R s) :
    f x = g x := by apply span_induction h H <;> simp (config := { contextual := true })
#align linear_map.eq_on_span LinearMap.eqOn_span
-/

#print LinearMap.eqOn_span' /-
/-- If two linear maps are equal on a set `s`, then they are equal on `submodule.span s`.

This version uses `set.eq_on`, and the hidden argument will expand to `h : x ∈ (span R s : set M)`.
See `linear_map.eq_on_span` for a version that takes `h : x ∈ span R s` as an argument. -/
theorem eqOn_span' {s : Set M} {f g : M →ₛₗ[σ₁₂] M₂} (H : Set.EqOn f g s) :
    Set.EqOn f g (span R s : Set M) :=
  eqOn_span H
#align linear_map.eq_on_span' LinearMap.eqOn_span'
-/

#print LinearMap.ext_on /-
/-- If `s` generates the whole module and linear maps `f`, `g` are equal on `s`, then they are
equal. -/
theorem ext_on {s : Set M} {f g : M →ₛₗ[σ₁₂] M₂} (hv : span R s = ⊤) (h : Set.EqOn f g s) : f = g :=
  LinearMap.ext fun x => eqOn_span h (eq_top_iff'.1 hv _)
#align linear_map.ext_on LinearMap.ext_on
-/

#print LinearMap.ext_on_range /-
/-- If the range of `v : ι → M` generates the whole module and linear maps `f`, `g` are equal at
each `v i`, then they are equal. -/
theorem ext_on_range {ι : Type _} {v : ι → M} {f g : M →ₛₗ[σ₁₂] M₂} (hv : span R (Set.range v) = ⊤)
    (h : ∀ i, f (v i) = g (v i)) : f = g :=
  ext_on hv (Set.forall_range_iff.2 h)
#align linear_map.ext_on_range LinearMap.ext_on_range
-/

end AddCommMonoid

section NoZeroDivisors

variable (R M) [Ring R] [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]

#print LinearMap.ker_toSpanSingleton /-
theorem ker_toSpanSingleton {x : M} (h : x ≠ 0) : (toSpanSingleton R M x).ker = ⊥ :=
  SetLike.ext fun c => smul_eq_zero.trans <| or_iff_left_of_imp fun h' => (h h').elim
#align linear_map.ker_to_span_singleton LinearMap.ker_toSpanSingleton
-/

end NoZeroDivisors

section Field

variable {K V} [Field K] [AddCommGroup V] [Module K V]

noncomputable section

open scoped Classical

#print LinearMap.span_singleton_sup_ker_eq_top /-
theorem span_singleton_sup_ker_eq_top (f : V →ₗ[K] K) {x : V} (hx : f x ≠ 0) :
    (K ∙ x) ⊔ f.ker = ⊤ :=
  eq_top_iff.2 fun y hy =>
    Submodule.mem_sup.2
      ⟨(f y * (f x)⁻¹) • x, Submodule.mem_span_singleton.2 ⟨f y * (f x)⁻¹, rfl⟩,
        ⟨y - (f y * (f x)⁻¹) • x, by
          rw [LinearMap.mem_ker, f.map_sub, f.map_smul, smul_eq_mul, mul_assoc, inv_mul_cancel hx,
            mul_one, sub_self],
          by simp only [add_sub_cancel'_right]⟩⟩
#align linear_map.span_singleton_sup_ker_eq_top LinearMap.span_singleton_sup_ker_eq_top
-/

end Field

end LinearMap

open LinearMap

namespace LinearEquiv

variable (R M) [Ring R] [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M] (x : M) (h : x ≠ 0)

#print LinearEquiv.toSpanNonzeroSingleton /-
/-- Given a nonzero element `x` of a torsion-free module `M` over a ring `R`, the natural
isomorphism from `R` to the span of `x` given by $r \mapsto r \cdot x$. -/
def toSpanNonzeroSingleton : R ≃ₗ[R] R ∙ x :=
  LinearEquiv.trans
    (LinearEquiv.ofInjective (LinearMap.toSpanSingleton R M x)
      (ker_eq_bot.1 <| ker_toSpanSingleton R M h))
    (LinearEquiv.ofEq (toSpanSingleton R M x).range (R ∙ x) (span_singleton_eq_range R M x).symm)
#align linear_equiv.to_span_nonzero_singleton LinearEquiv.toSpanNonzeroSingleton
-/

#print LinearEquiv.toSpanNonzeroSingleton_one /-
theorem toSpanNonzeroSingleton_one :
    LinearEquiv.toSpanNonzeroSingleton R M x h 1 =
      (⟨x, Submodule.mem_span_singleton_self x⟩ : R ∙ x) :=
  by
  apply set_like.coe_eq_coe.mp
  have : ↑(to_span_nonzero_singleton R M x h 1) = to_span_singleton R M x 1 := rfl
  rw [this, to_span_singleton_one, Submodule.coe_mk]
#align linear_equiv.to_span_nonzero_singleton_one LinearEquiv.toSpanNonzeroSingleton_one
-/

#print LinearEquiv.coord /-
/-- Given a nonzero element `x` of a torsion-free module `M` over a ring `R`, the natural
isomorphism from the span of `x` to `R` given by $r \cdot x \mapsto r$. -/
abbrev coord : (R ∙ x) ≃ₗ[R] R :=
  (toSpanNonzeroSingleton R M x h).symm
#align linear_equiv.coord LinearEquiv.coord
-/

#print LinearEquiv.coord_self /-
theorem coord_self : (coord R M x h) (⟨x, Submodule.mem_span_singleton_self x⟩ : R ∙ x) = 1 := by
  rw [← to_span_nonzero_singleton_one R M x h, LinearEquiv.symm_apply_apply]
#align linear_equiv.coord_self LinearEquiv.coord_self
-/

#print LinearEquiv.coord_apply_smul /-
theorem coord_apply_smul (y : Submodule.span R ({x} : Set M)) : coord R M x h y • x = y :=
  Subtype.ext_iff.1 <| (toSpanNonzeroSingleton R M x h).apply_symm_apply _
#align linear_equiv.coord_apply_smul LinearEquiv.coord_apply_smul
-/

end LinearEquiv

