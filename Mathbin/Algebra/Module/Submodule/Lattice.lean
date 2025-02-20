/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Kevin Buzzard, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.module.submodule.lattice
! leanprover-community/mathlib commit 68d1483e8a718ec63219f0e227ca3f0140361086
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Submodule.Basic
import Mathbin.Algebra.PunitInstances

/-!
# The lattice structure on `submodule`s

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the lattice structure on submodules, `submodule.complete_lattice`, with `⊥`
defined as `{0}` and `⊓` defined as intersection of the underlying carrier.
If `p` and `q` are submodules of a module, `p ≤ q` means that `p ⊆ q`.

Many results about operations on this lattice structure are defined in `linear_algebra/basic.lean`,
most notably those which use `span`.

## Implementation notes

This structure should match the `add_submonoid.complete_lattice` structure, and we should try
to unify the APIs where possible.

-/


variable {R S M : Type _}

section AddCommMonoid

variable [Semiring R] [Semiring S] [AddCommMonoid M] [Module R M] [Module S M]

variable [SMul S R] [IsScalarTower S R M]

variable {p q : Submodule R M}

namespace Submodule

/-- The set `{0}` is the bottom element of the lattice of submodules. -/
instance : Bot (Submodule R M) :=
  ⟨{ (⊥ : AddSubmonoid M) with
      carrier := {0}
      smul_mem' := by simp (config := { contextual := true }) }⟩

#print Submodule.inhabited' /-
instance inhabited' : Inhabited (Submodule R M) :=
  ⟨⊥⟩
#align submodule.inhabited' Submodule.inhabited'
-/

#print Submodule.bot_coe /-
@[simp]
theorem bot_coe : ((⊥ : Submodule R M) : Set M) = {0} :=
  rfl
#align submodule.bot_coe Submodule.bot_coe
-/

#print Submodule.bot_toAddSubmonoid /-
@[simp]
theorem bot_toAddSubmonoid : (⊥ : Submodule R M).toAddSubmonoid = ⊥ :=
  rfl
#align submodule.bot_to_add_submonoid Submodule.bot_toAddSubmonoid
-/

section

variable (R)

#print Submodule.restrictScalars_bot /-
@[simp]
theorem restrictScalars_bot : restrictScalars S (⊥ : Submodule R M) = ⊥ :=
  rfl
#align submodule.restrict_scalars_bot Submodule.restrictScalars_bot
-/

#print Submodule.mem_bot /-
@[simp]
theorem mem_bot {x : M} : x ∈ (⊥ : Submodule R M) ↔ x = 0 :=
  Set.mem_singleton_iff
#align submodule.mem_bot Submodule.mem_bot
-/

end

#print Submodule.restrictScalars_eq_bot_iff /-
@[simp]
theorem restrictScalars_eq_bot_iff {p : Submodule R M} : restrictScalars S p = ⊥ ↔ p = ⊥ := by
  simp [SetLike.ext_iff]
#align submodule.restrict_scalars_eq_bot_iff Submodule.restrictScalars_eq_bot_iff
-/

#print Submodule.uniqueBot /-
instance uniqueBot : Unique (⊥ : Submodule R M) :=
  ⟨inferInstance, fun x => Subtype.ext <| (mem_bot R).1 x.Mem⟩
#align submodule.unique_bot Submodule.uniqueBot
-/

instance : OrderBot (Submodule R M) where
  bot := ⊥
  bot_le p x := by simp (config := { contextual := true }) [zero_mem]

#print Submodule.eq_bot_iff /-
protected theorem eq_bot_iff (p : Submodule R M) : p = ⊥ ↔ ∀ x ∈ p, x = (0 : M) :=
  ⟨fun h => h.symm ▸ fun x hx => (mem_bot R).mp hx, fun h =>
    eq_bot_iff.mpr fun x hx => (mem_bot R).mpr (h x hx)⟩
#align submodule.eq_bot_iff Submodule.eq_bot_iff
-/

#print Submodule.bot_ext /-
@[ext]
protected theorem bot_ext (x y : (⊥ : Submodule R M)) : x = y :=
  by
  rcases x with ⟨x, xm⟩; rcases y with ⟨y, ym⟩; congr
  rw [(Submodule.eq_bot_iff _).mp rfl x xm]
  rw [(Submodule.eq_bot_iff _).mp rfl y ym]
#align submodule.bot_ext Submodule.bot_ext
-/

#print Submodule.ne_bot_iff /-
protected theorem ne_bot_iff (p : Submodule R M) : p ≠ ⊥ ↔ ∃ x ∈ p, x ≠ (0 : M) := by
  haveI := Classical.propDecidable; simp_rw [Ne.def, p.eq_bot_iff, not_forall]
#align submodule.ne_bot_iff Submodule.ne_bot_iff
-/

#print Submodule.nonzero_mem_of_bot_lt /-
theorem nonzero_mem_of_bot_lt {p : Submodule R M} (bot_lt : ⊥ < p) : ∃ a : p, a ≠ 0 :=
  let ⟨b, hb₁, hb₂⟩ := p.ne_bot_iff.mp bot_lt.ne'
  ⟨⟨b, hb₁⟩, hb₂ ∘ congr_arg coe⟩
#align submodule.nonzero_mem_of_bot_lt Submodule.nonzero_mem_of_bot_lt
-/

#print Submodule.exists_mem_ne_zero_of_ne_bot /-
theorem exists_mem_ne_zero_of_ne_bot {p : Submodule R M} (h : p ≠ ⊥) : ∃ b : M, b ∈ p ∧ b ≠ 0 :=
  let ⟨b, hb₁, hb₂⟩ := p.ne_bot_iff.mp h
  ⟨b, hb₁, hb₂⟩
#align submodule.exists_mem_ne_zero_of_ne_bot Submodule.exists_mem_ne_zero_of_ne_bot
-/

#print Submodule.botEquivPUnit /-
/-- The bottom submodule is linearly equivalent to punit as an `R`-module. -/
@[simps]
def botEquivPUnit : (⊥ : Submodule R M) ≃ₗ[R] PUnit
    where
  toFun x := PUnit.unit
  invFun x := 0
  map_add' := by intros; ext
  map_smul' := by intros; ext
  left_inv := by intro x; ext
  right_inv := by intro x; ext
#align submodule.bot_equiv_punit Submodule.botEquivPUnit
-/

#print Submodule.eq_bot_of_subsingleton /-
theorem eq_bot_of_subsingleton (p : Submodule R M) [Subsingleton p] : p = ⊥ :=
  by
  rw [eq_bot_iff]
  intro v hv
  exact congr_arg coe (Subsingleton.elim (⟨v, hv⟩ : p) 0)
#align submodule.eq_bot_of_subsingleton Submodule.eq_bot_of_subsingleton
-/

/-- The universal set is the top element of the lattice of submodules. -/
instance : Top (Submodule R M) :=
  ⟨{ (⊤ : AddSubmonoid M) with
      carrier := Set.univ
      smul_mem' := fun _ _ _ => trivial }⟩

#print Submodule.top_coe /-
@[simp]
theorem top_coe : ((⊤ : Submodule R M) : Set M) = Set.univ :=
  rfl
#align submodule.top_coe Submodule.top_coe
-/

#print Submodule.top_toAddSubmonoid /-
@[simp]
theorem top_toAddSubmonoid : (⊤ : Submodule R M).toAddSubmonoid = ⊤ :=
  rfl
#align submodule.top_to_add_submonoid Submodule.top_toAddSubmonoid
-/

#print Submodule.mem_top /-
@[simp]
theorem mem_top {x : M} : x ∈ (⊤ : Submodule R M) :=
  trivial
#align submodule.mem_top Submodule.mem_top
-/

section

variable (R)

#print Submodule.restrictScalars_top /-
@[simp]
theorem restrictScalars_top : restrictScalars S (⊤ : Submodule R M) = ⊤ :=
  rfl
#align submodule.restrict_scalars_top Submodule.restrictScalars_top
-/

end

#print Submodule.restrictScalars_eq_top_iff /-
@[simp]
theorem restrictScalars_eq_top_iff {p : Submodule R M} : restrictScalars S p = ⊤ ↔ p = ⊤ := by
  simp [SetLike.ext_iff]
#align submodule.restrict_scalars_eq_top_iff Submodule.restrictScalars_eq_top_iff
-/

instance : OrderTop (Submodule R M) where
  top := ⊤
  le_top p x _ := trivial

#print Submodule.eq_top_iff' /-
theorem eq_top_iff' {p : Submodule R M} : p = ⊤ ↔ ∀ x, x ∈ p :=
  eq_top_iff.trans ⟨fun h x => h trivial, fun h x _ => h x⟩
#align submodule.eq_top_iff' Submodule.eq_top_iff'
-/

#print Submodule.topEquiv /-
/-- The top submodule is linearly equivalent to the module.

This is the module version of `add_submonoid.top_equiv`. -/
@[simps]
def topEquiv : (⊤ : Submodule R M) ≃ₗ[R] M
    where
  toFun x := x
  invFun x := ⟨x, by simp⟩
  map_add' := by intros; rfl
  map_smul' := by intros; rfl
  left_inv := by intro x; ext; rfl
  right_inv := by intro x; rfl
#align submodule.top_equiv Submodule.topEquiv
-/

instance : InfSet (Submodule R M) :=
  ⟨fun S =>
    { carrier := ⋂ s ∈ S, (s : Set M)
      zero_mem' := by simp [zero_mem]
      add_mem' := by simp (config := { contextual := true }) [add_mem]
      smul_mem' := by simp (config := { contextual := true }) [smul_mem] }⟩

private theorem Inf_le' {S : Set (Submodule R M)} {p} : p ∈ S → sInf S ≤ p :=
  Set.biInter_subset_of_mem

private theorem le_Inf' {S : Set (Submodule R M)} {p} : (∀ q ∈ S, p ≤ q) → p ≤ sInf S :=
  Set.subset_iInter₂

instance : Inf (Submodule R M) :=
  ⟨fun p q =>
    { carrier := p ∩ q
      zero_mem' := by simp [zero_mem]
      add_mem' := by simp (config := { contextual := true }) [add_mem]
      smul_mem' := by simp (config := { contextual := true }) [smul_mem] }⟩

instance : CompleteLattice (Submodule R M) :=
  { Submodule.orderTop, Submodule.orderBot,
    SetLike.partialOrder with
    sup := fun a b => sInf {x | a ≤ x ∧ b ≤ x}
    le_sup_left := fun a b => le_Inf' fun x ⟨ha, hb⟩ => ha
    le_sup_right := fun a b => le_Inf' fun x ⟨ha, hb⟩ => hb
    sup_le := fun a b c h₁ h₂ => sInf_le' ⟨h₁, h₂⟩
    inf := (· ⊓ ·)
    le_inf := fun a b c => Set.subset_inter
    inf_le_left := fun a b => Set.inter_subset_left _ _
    inf_le_right := fun a b => Set.inter_subset_right _ _
    sSup := fun tt => sInf {t | ∀ t' ∈ tt, t' ≤ t}
    le_sup := fun s p hs => le_Inf' fun q hq => hq _ hs
    sup_le := fun s p hs => sInf_le' hs
    sInf := sInf
    le_inf := fun s a => le_Inf'
    inf_le := fun s a => sInf_le' }

#print Submodule.inf_coe /-
@[simp]
theorem inf_coe : ↑(p ⊓ q) = (p ∩ q : Set M) :=
  rfl
#align submodule.inf_coe Submodule.inf_coe
-/

#print Submodule.mem_inf /-
@[simp]
theorem mem_inf {p q : Submodule R M} {x : M} : x ∈ p ⊓ q ↔ x ∈ p ∧ x ∈ q :=
  Iff.rfl
#align submodule.mem_inf Submodule.mem_inf
-/

#print Submodule.sInf_coe /-
@[simp]
theorem sInf_coe (P : Set (Submodule R M)) : (↑(sInf P) : Set M) = ⋂ p ∈ P, ↑p :=
  rfl
#align submodule.Inf_coe Submodule.sInf_coe
-/

#print Submodule.finset_inf_coe /-
@[simp]
theorem finset_inf_coe {ι} (s : Finset ι) (p : ι → Submodule R M) :
    (↑(s.inf p) : Set M) = ⋂ i ∈ s, ↑(p i) :=
  by
  letI := Classical.decEq ι
  refine' s.induction_on _ fun i s hi ih => _
  · simp
  · rw [Finset.inf_insert, inf_coe, ih]
    simp
#align submodule.finset_inf_coe Submodule.finset_inf_coe
-/

#print Submodule.iInf_coe /-
@[simp]
theorem iInf_coe {ι} (p : ι → Submodule R M) : (↑(⨅ i, p i) : Set M) = ⋂ i, ↑(p i) := by
  rw [iInf, Inf_coe] <;> ext a <;> simp <;> exact ⟨fun h i => h _ i rfl, fun h i x e => e ▸ h _⟩
#align submodule.infi_coe Submodule.iInf_coe
-/

#print Submodule.mem_sInf /-
@[simp]
theorem mem_sInf {S : Set (Submodule R M)} {x : M} : x ∈ sInf S ↔ ∀ p ∈ S, x ∈ p :=
  Set.mem_iInter₂
#align submodule.mem_Inf Submodule.mem_sInf
-/

#print Submodule.mem_iInf /-
@[simp]
theorem mem_iInf {ι} (p : ι → Submodule R M) {x} : (x ∈ ⨅ i, p i) ↔ ∀ i, x ∈ p i := by
  rw [← SetLike.mem_coe, infi_coe, Set.mem_iInter] <;> rfl
#align submodule.mem_infi Submodule.mem_iInf
-/

#print Submodule.mem_finset_inf /-
@[simp]
theorem mem_finset_inf {ι} {s : Finset ι} {p : ι → Submodule R M} {x : M} :
    x ∈ s.inf p ↔ ∀ i ∈ s, x ∈ p i := by
  simp only [← SetLike.mem_coe, finset_inf_coe, Set.mem_iInter]
#align submodule.mem_finset_inf Submodule.mem_finset_inf
-/

#print Submodule.mem_sup_left /-
theorem mem_sup_left {S T : Submodule R M} : ∀ {x : M}, x ∈ S → x ∈ S ⊔ T :=
  show S ≤ S ⊔ T from le_sup_left
#align submodule.mem_sup_left Submodule.mem_sup_left
-/

#print Submodule.mem_sup_right /-
theorem mem_sup_right {S T : Submodule R M} : ∀ {x : M}, x ∈ T → x ∈ S ⊔ T :=
  show T ≤ S ⊔ T from le_sup_right
#align submodule.mem_sup_right Submodule.mem_sup_right
-/

#print Submodule.add_mem_sup /-
theorem add_mem_sup {S T : Submodule R M} {s t : M} (hs : s ∈ S) (ht : t ∈ T) : s + t ∈ S ⊔ T :=
  add_mem (mem_sup_left hs) (mem_sup_right ht)
#align submodule.add_mem_sup Submodule.add_mem_sup
-/

#print Submodule.sub_mem_sup /-
theorem sub_mem_sup {R' M' : Type _} [Ring R'] [AddCommGroup M'] [Module R' M']
    {S T : Submodule R' M'} {s t : M'} (hs : s ∈ S) (ht : t ∈ T) : s - t ∈ S ⊔ T :=
  by
  rw [sub_eq_add_neg]
  exact add_mem_sup hs (neg_mem ht)
#align submodule.sub_mem_sup Submodule.sub_mem_sup
-/

#print Submodule.mem_iSup_of_mem /-
theorem mem_iSup_of_mem {ι : Sort _} {b : M} {p : ι → Submodule R M} (i : ι) (h : b ∈ p i) :
    b ∈ ⨆ i, p i :=
  have : p i ≤ ⨆ i, p i := le_iSup p i
  @this b h
#align submodule.mem_supr_of_mem Submodule.mem_iSup_of_mem
-/

open scoped BigOperators

#print Submodule.sum_mem_iSup /-
theorem sum_mem_iSup {ι : Type _} [Fintype ι] {f : ι → M} {p : ι → Submodule R M}
    (h : ∀ i, f i ∈ p i) : ∑ i, f i ∈ ⨆ i, p i :=
  sum_mem fun i hi => mem_iSup_of_mem i (h i)
#align submodule.sum_mem_supr Submodule.sum_mem_iSup
-/

#print Submodule.sum_mem_biSup /-
theorem sum_mem_biSup {ι : Type _} {s : Finset ι} {f : ι → M} {p : ι → Submodule R M}
    (h : ∀ i ∈ s, f i ∈ p i) : ∑ i in s, f i ∈ ⨆ i ∈ s, p i :=
  sum_mem fun i hi => mem_iSup_of_mem i <| mem_iSup_of_mem hi (h i hi)
#align submodule.sum_mem_bsupr Submodule.sum_mem_biSup
-/

/-! Note that `submodule.mem_supr` is provided in `linear_algebra/basic.lean`. -/


#print Submodule.mem_sSup_of_mem /-
theorem mem_sSup_of_mem {S : Set (Submodule R M)} {s : Submodule R M} (hs : s ∈ S) :
    ∀ {x : M}, x ∈ s → x ∈ sSup S :=
  show s ≤ sSup S from le_sSup hs
#align submodule.mem_Sup_of_mem Submodule.mem_sSup_of_mem
-/

#print Submodule.disjoint_def /-
theorem disjoint_def {p p' : Submodule R M} : Disjoint p p' ↔ ∀ x ∈ p, x ∈ p' → x = (0 : M) :=
  disjoint_iff_inf_le.trans <| show (∀ x, x ∈ p ∧ x ∈ p' → x ∈ ({0} : Set M)) ↔ _ by simp
#align submodule.disjoint_def Submodule.disjoint_def
-/

#print Submodule.disjoint_def' /-
theorem disjoint_def' {p p' : Submodule R M} :
    Disjoint p p' ↔ ∀ x ∈ p, ∀ y ∈ p', x = y → x = (0 : M) :=
  disjoint_def.trans
    ⟨fun h x hx y hy hxy => h x hx <| hxy.symm ▸ hy, fun h x hx hx' => h _ hx x hx' rfl⟩
#align submodule.disjoint_def' Submodule.disjoint_def'
-/

#print Submodule.eq_zero_of_coe_mem_of_disjoint /-
theorem eq_zero_of_coe_mem_of_disjoint (hpq : Disjoint p q) {a : p} (ha : (a : M) ∈ q) : a = 0 := by
  exact_mod_cast disjoint_def.mp hpq a (coe_mem a) ha
#align submodule.eq_zero_of_coe_mem_of_disjoint Submodule.eq_zero_of_coe_mem_of_disjoint
-/

end Submodule

section NatSubmodule

#print AddSubmonoid.toNatSubmodule /-
/-- An additive submonoid is equivalent to a ℕ-submodule. -/
def AddSubmonoid.toNatSubmodule : AddSubmonoid M ≃o Submodule ℕ M
    where
  toFun S := { S with smul_mem' := fun r s hs => show r • s ∈ S from nsmul_mem hs _ }
  invFun := Submodule.toAddSubmonoid
  left_inv := fun ⟨S, _, _⟩ => rfl
  right_inv := fun ⟨S, _, _, _⟩ => rfl
  map_rel_iff' a b := Iff.rfl
#align add_submonoid.to_nat_submodule AddSubmonoid.toNatSubmodule
-/

#print AddSubmonoid.toNatSubmodule_symm /-
@[simp]
theorem AddSubmonoid.toNatSubmodule_symm :
    ⇑(AddSubmonoid.toNatSubmodule.symm : _ ≃o AddSubmonoid M) = Submodule.toAddSubmonoid :=
  rfl
#align add_submonoid.to_nat_submodule_symm AddSubmonoid.toNatSubmodule_symm
-/

#print AddSubmonoid.coe_toNatSubmodule /-
@[simp]
theorem AddSubmonoid.coe_toNatSubmodule (S : AddSubmonoid M) : (S.toNatSubmodule : Set M) = S :=
  rfl
#align add_submonoid.coe_to_nat_submodule AddSubmonoid.coe_toNatSubmodule
-/

#print AddSubmonoid.toNatSubmodule_toAddSubmonoid /-
@[simp]
theorem AddSubmonoid.toNatSubmodule_toAddSubmonoid (S : AddSubmonoid M) :
    S.toNatSubmodule.toAddSubmonoid = S :=
  AddSubmonoid.toNatSubmodule.symm_apply_apply S
#align add_submonoid.to_nat_submodule_to_add_submonoid AddSubmonoid.toNatSubmodule_toAddSubmonoid
-/

#print Submodule.toAddSubmonoid_toNatSubmodule /-
@[simp]
theorem Submodule.toAddSubmonoid_toNatSubmodule (S : Submodule ℕ M) :
    S.toAddSubmonoid.toNatSubmodule = S :=
  AddSubmonoid.toNatSubmodule.apply_symm_apply S
#align submodule.to_add_submonoid_to_nat_submodule Submodule.toAddSubmonoid_toNatSubmodule
-/

end NatSubmodule

end AddCommMonoid

section IntSubmodule

variable [AddCommGroup M]

#print AddSubgroup.toIntSubmodule /-
/-- An additive subgroup is equivalent to a ℤ-submodule. -/
def AddSubgroup.toIntSubmodule : AddSubgroup M ≃o Submodule ℤ M
    where
  toFun S := { S with smul_mem' := fun r s hs => S.zsmul_mem hs _ }
  invFun := Submodule.toAddSubgroup
  left_inv := fun ⟨S, _, _, _⟩ => rfl
  right_inv := fun ⟨S, _, _, _⟩ => rfl
  map_rel_iff' a b := Iff.rfl
#align add_subgroup.to_int_submodule AddSubgroup.toIntSubmodule
-/

#print AddSubgroup.toIntSubmodule_symm /-
@[simp]
theorem AddSubgroup.toIntSubmodule_symm :
    ⇑(AddSubgroup.toIntSubmodule.symm : _ ≃o AddSubgroup M) = Submodule.toAddSubgroup :=
  rfl
#align add_subgroup.to_int_submodule_symm AddSubgroup.toIntSubmodule_symm
-/

#print AddSubgroup.coe_toIntSubmodule /-
@[simp]
theorem AddSubgroup.coe_toIntSubmodule (S : AddSubgroup M) : (S.toIntSubmodule : Set M) = S :=
  rfl
#align add_subgroup.coe_to_int_submodule AddSubgroup.coe_toIntSubmodule
-/

#print AddSubgroup.toIntSubmodule_toAddSubgroup /-
@[simp]
theorem AddSubgroup.toIntSubmodule_toAddSubgroup (S : AddSubgroup M) :
    S.toIntSubmodule.toAddSubgroup = S :=
  AddSubgroup.toIntSubmodule.symm_apply_apply S
#align add_subgroup.to_int_submodule_to_add_subgroup AddSubgroup.toIntSubmodule_toAddSubgroup
-/

#print Submodule.toAddSubgroup_toIntSubmodule /-
@[simp]
theorem Submodule.toAddSubgroup_toIntSubmodule (S : Submodule ℤ M) :
    S.toAddSubgroup.toIntSubmodule = S :=
  AddSubgroup.toIntSubmodule.apply_symm_apply S
#align submodule.to_add_subgroup_to_int_submodule Submodule.toAddSubgroup_toIntSubmodule
-/

end IntSubmodule

