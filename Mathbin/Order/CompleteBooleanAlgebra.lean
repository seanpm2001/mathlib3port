/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Yaël Dillies

! This file was ported from Lean 3 source module order.complete_boolean_algebra
! leanprover-community/mathlib commit 71b36b6f3bbe3b44e6538673819324d3ee9fcc96
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.CompleteLattice
import Mathbin.Order.Directed
import Mathbin.Logic.Equiv.Set

/-!
# Frames, completely distributive lattices and Boolean algebras

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

In this file we define and provide API for frames, completely distributive lattices and completely
distributive Boolean algebras.

## Typeclasses

* `order.frame`: Frame: A complete lattice whose `⊓` distributes over `⨆`.
* `order.coframe`: Coframe: A complete lattice whose `⊔` distributes over `⨅`.
* `complete_distrib_lattice`: Completely distributive lattices: A complete lattice whose `⊓` and `⊔`
  distribute over `⨆` and `⨅` respectively.
* `complete_boolean_algebra`: Completely distributive Boolean algebra: A Boolean algebra whose `⊓`
  and `⊔` distribute over `⨆` and `⨅` respectively.

A set of opens gives rise to a topological space precisely if it forms a frame. Such a frame is also
completely distributive, but not all frames are. `filter` is a coframe but not a completely
distributive lattice.

## TODO

Add instances for `prod`

## References

* [Wikipedia, *Complete Heyting algebra*](https://en.wikipedia.org/wiki/Complete_Heyting_algebra)
* [Francis Borceux, *Handbook of Categorical Algebra III*][borceux-vol3]
-/


open Function Set

universe u v w

variable {α : Type u} {β : Type v} {ι : Sort w} {κ : ι → Sort _}

#print Order.Frame /-
/-- A frame, aka complete Heyting algebra, is a complete lattice whose `⊓` distributes over `⨆`. -/
class Order.Frame (α : Type _) extends CompleteLattice α where
  inf_sup_le_iSup_inf (a : α) (s : Set α) : a ⊓ Sup s ≤ ⨆ b ∈ s, a ⊓ b
#align order.frame Order.Frame
-/

#print Order.Coframe /-
/-- A coframe, aka complete Brouwer algebra or complete co-Heyting algebra, is a complete lattice
whose `⊔` distributes over `⨅`. -/
class Order.Coframe (α : Type _) extends CompleteLattice α where
  iInf_sup_le_sup_inf (a : α) (s : Set α) : (⨅ b ∈ s, a ⊔ b) ≤ a ⊔ Inf s
#align order.coframe Order.Coframe
-/

open Order

#print CompleteDistribLattice /-
/-- A completely distributive lattice is a complete lattice whose `⊔` and `⊓` respectively
distribute over `⨅` and `⨆`. -/
class CompleteDistribLattice (α : Type _) extends Frame α where
  iInf_sup_le_sup_inf : ∀ a s, (⨅ b ∈ s, a ⊔ b) ≤ a ⊔ Inf s
#align complete_distrib_lattice CompleteDistribLattice
-/

#print CompleteDistribLattice.toCoframe /-
-- See note [lower instance priority]
instance (priority := 100) CompleteDistribLattice.toCoframe [CompleteDistribLattice α] :
    Coframe α :=
  { ‹CompleteDistribLattice α› with }
#align complete_distrib_lattice.to_coframe CompleteDistribLattice.toCoframe
-/

section Frame

variable [Frame α] {s t : Set α} {a b : α}

#print OrderDual.coframe /-
instance OrderDual.coframe : Coframe αᵒᵈ :=
  { OrderDual.completeLattice α with iInf_sup_le_sup_inf := Frame.inf_sup_le_iSup_inf }
#align order_dual.coframe OrderDual.coframe
-/

#print inf_sSup_eq /-
theorem inf_sSup_eq : a ⊓ sSup s = ⨆ b ∈ s, a ⊓ b :=
  (Frame.inf_sup_le_iSup_inf _ _).antisymm iSup_inf_le_inf_sSup
#align inf_Sup_eq inf_sSup_eq
-/

#print sSup_inf_eq /-
theorem sSup_inf_eq : sSup s ⊓ b = ⨆ a ∈ s, a ⊓ b := by
  simpa only [inf_comm] using @inf_sSup_eq α _ s b
#align Sup_inf_eq sSup_inf_eq
-/

#print iSup_inf_eq /-
theorem iSup_inf_eq (f : ι → α) (a : α) : (⨆ i, f i) ⊓ a = ⨆ i, f i ⊓ a := by
  rw [iSup, sSup_inf_eq, iSup_range]
#align supr_inf_eq iSup_inf_eq
-/

#print inf_iSup_eq /-
theorem inf_iSup_eq (a : α) (f : ι → α) : (a ⊓ ⨆ i, f i) = ⨆ i, a ⊓ f i := by
  simpa only [inf_comm] using iSup_inf_eq f a
#align inf_supr_eq inf_iSup_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print iSup₂_inf_eq /-
theorem iSup₂_inf_eq {f : ∀ i, κ i → α} (a : α) : (⨆ (i) (j), f i j) ⊓ a = ⨆ (i) (j), f i j ⊓ a :=
  by simp only [iSup_inf_eq]
#align bsupr_inf_eq iSup₂_inf_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print inf_iSup₂_eq /-
theorem inf_iSup₂_eq {f : ∀ i, κ i → α} (a : α) : (a ⊓ ⨆ (i) (j), f i j) = ⨆ (i) (j), a ⊓ f i j :=
  by simp only [inf_iSup_eq]
#align inf_bsupr_eq inf_iSup₂_eq
-/

#print iSup_inf_iSup /-
theorem iSup_inf_iSup {ι ι' : Type _} {f : ι → α} {g : ι' → α} :
    ((⨆ i, f i) ⊓ ⨆ j, g j) = ⨆ i : ι × ι', f i.1 ⊓ g i.2 := by
  simp only [inf_iSup_eq, iSup_inf_eq, iSup_prod]
#align supr_inf_supr iSup_inf_iSup
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print biSup_inf_biSup /-
theorem biSup_inf_biSup {ι ι' : Type _} {f : ι → α} {g : ι' → α} {s : Set ι} {t : Set ι'} :
    ((⨆ i ∈ s, f i) ⊓ ⨆ j ∈ t, g j) = ⨆ p ∈ s ×ˢ t, f (p : ι × ι').1 ⊓ g p.2 :=
  by
  simp only [iSup_subtype', iSup_inf_iSup]
  exact (Equiv.surjective _).iSup_congr (Equiv.Set.prod s t).symm fun x => rfl
#align bsupr_inf_bsupr biSup_inf_biSup
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print sSup_inf_sSup /-
theorem sSup_inf_sSup : sSup s ⊓ sSup t = ⨆ p ∈ s ×ˢ t, (p : α × α).1 ⊓ p.2 := by
  simp only [sSup_eq_iSup, biSup_inf_biSup]
#align Sup_inf_Sup sSup_inf_sSup
-/

#print iSup_disjoint_iff /-
theorem iSup_disjoint_iff {f : ι → α} : Disjoint (⨆ i, f i) a ↔ ∀ i, Disjoint (f i) a := by
  simp only [disjoint_iff, iSup_inf_eq, iSup_eq_bot]
#align supr_disjoint_iff iSup_disjoint_iff
-/

#print disjoint_iSup_iff /-
theorem disjoint_iSup_iff {f : ι → α} : Disjoint a (⨆ i, f i) ↔ ∀ i, Disjoint a (f i) := by
  simpa only [disjoint_comm] using iSup_disjoint_iff
#align disjoint_supr_iff disjoint_iSup_iff
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print iSup₂_disjoint_iff /-
theorem iSup₂_disjoint_iff {f : ∀ i, κ i → α} :
    Disjoint (⨆ (i) (j), f i j) a ↔ ∀ i j, Disjoint (f i j) a := by simp_rw [iSup_disjoint_iff]
#align supr₂_disjoint_iff iSup₂_disjoint_iff
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print disjoint_iSup₂_iff /-
theorem disjoint_iSup₂_iff {f : ∀ i, κ i → α} :
    Disjoint a (⨆ (i) (j), f i j) ↔ ∀ i j, Disjoint a (f i j) := by simp_rw [disjoint_iSup_iff]
#align disjoint_supr₂_iff disjoint_iSup₂_iff
-/

#print sSup_disjoint_iff /-
theorem sSup_disjoint_iff {s : Set α} : Disjoint (sSup s) a ↔ ∀ b ∈ s, Disjoint b a := by
  simp only [disjoint_iff, sSup_inf_eq, iSup_eq_bot]
#align Sup_disjoint_iff sSup_disjoint_iff
-/

#print disjoint_sSup_iff /-
theorem disjoint_sSup_iff {s : Set α} : Disjoint a (sSup s) ↔ ∀ b ∈ s, Disjoint a b := by
  simpa only [disjoint_comm] using sSup_disjoint_iff
#align disjoint_Sup_iff disjoint_sSup_iff
-/

#print iSup_inf_of_monotone /-
theorem iSup_inf_of_monotone {ι : Type _} [Preorder ι] [IsDirected ι (· ≤ ·)] {f g : ι → α}
    (hf : Monotone f) (hg : Monotone g) : (⨆ i, f i ⊓ g i) = (⨆ i, f i) ⊓ ⨆ i, g i :=
  by
  refine' (le_iSup_inf_iSup f g).antisymm _
  rw [iSup_inf_iSup]
  refine' iSup_mono' fun i => _
  rcases directed_of (· ≤ ·) i.1 i.2 with ⟨j, h₁, h₂⟩
  exact ⟨j, inf_le_inf (hf h₁) (hg h₂)⟩
#align supr_inf_of_monotone iSup_inf_of_monotone
-/

#print iSup_inf_of_antitone /-
theorem iSup_inf_of_antitone {ι : Type _} [Preorder ι] [IsDirected ι (swap (· ≤ ·))] {f g : ι → α}
    (hf : Antitone f) (hg : Antitone g) : (⨆ i, f i ⊓ g i) = (⨆ i, f i) ⊓ ⨆ i, g i :=
  @iSup_inf_of_monotone α _ ιᵒᵈ _ _ f g hf.dual_left hg.dual_left
#align supr_inf_of_antitone iSup_inf_of_antitone
-/

#print Pi.frame /-
instance Pi.frame {ι : Type _} {π : ι → Type _} [∀ i, Frame (π i)] : Frame (∀ i, π i) :=
  { Pi.completeLattice with
    inf_sup_le_iSup_inf := fun a s i => by
      simp only [CompleteLattice.sup, sSup_apply, iSup_apply, Pi.inf_apply, inf_iSup_eq, ←
        iSup_subtype''] }
#align pi.frame Pi.frame
-/

#print Frame.toDistribLattice /-
-- see Note [lower instance priority]
instance (priority := 100) Frame.toDistribLattice : DistribLattice α :=
  DistribLattice.ofInfSupLe fun a b c => by
    rw [← sSup_pair, ← sSup_pair, inf_sSup_eq, ← sSup_image, image_pair]
#align frame.to_distrib_lattice Frame.toDistribLattice
-/

end Frame

section Coframe

variable [Coframe α] {s t : Set α} {a b : α}

#print OrderDual.frame /-
instance OrderDual.frame : Frame αᵒᵈ :=
  { OrderDual.completeLattice α with inf_sup_le_iSup_inf := Coframe.iInf_sup_le_sup_inf }
#align order_dual.frame OrderDual.frame
-/

#print sup_sInf_eq /-
theorem sup_sInf_eq : a ⊔ sInf s = ⨅ b ∈ s, a ⊔ b :=
  @inf_sSup_eq αᵒᵈ _ _ _
#align sup_Inf_eq sup_sInf_eq
-/

#print sInf_sup_eq /-
theorem sInf_sup_eq : sInf s ⊔ b = ⨅ a ∈ s, a ⊔ b :=
  @sSup_inf_eq αᵒᵈ _ _ _
#align Inf_sup_eq sInf_sup_eq
-/

#print iInf_sup_eq /-
theorem iInf_sup_eq (f : ι → α) (a : α) : (⨅ i, f i) ⊔ a = ⨅ i, f i ⊔ a :=
  @iSup_inf_eq αᵒᵈ _ _ _ _
#align infi_sup_eq iInf_sup_eq
-/

#print sup_iInf_eq /-
theorem sup_iInf_eq (a : α) (f : ι → α) : (a ⊔ ⨅ i, f i) = ⨅ i, a ⊔ f i :=
  @inf_iSup_eq αᵒᵈ _ _ _ _
#align sup_infi_eq sup_iInf_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print iInf₂_sup_eq /-
theorem iInf₂_sup_eq {f : ∀ i, κ i → α} (a : α) : (⨅ (i) (j), f i j) ⊔ a = ⨅ (i) (j), f i j ⊔ a :=
  @iSup₂_inf_eq αᵒᵈ _ _ _ _ _
#align binfi_sup_eq iInf₂_sup_eq
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
#print sup_iInf₂_eq /-
theorem sup_iInf₂_eq {f : ∀ i, κ i → α} (a : α) : (a ⊔ ⨅ (i) (j), f i j) = ⨅ (i) (j), a ⊔ f i j :=
  @inf_iSup₂_eq αᵒᵈ _ _ _ _ _
#align sup_binfi_eq sup_iInf₂_eq
-/

#print iInf_sup_iInf /-
theorem iInf_sup_iInf {ι ι' : Type _} {f : ι → α} {g : ι' → α} :
    ((⨅ i, f i) ⊔ ⨅ i, g i) = ⨅ i : ι × ι', f i.1 ⊔ g i.2 :=
  @iSup_inf_iSup αᵒᵈ _ _ _ _ _
#align infi_sup_infi iInf_sup_iInf
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print biInf_sup_biInf /-
theorem biInf_sup_biInf {ι ι' : Type _} {f : ι → α} {g : ι' → α} {s : Set ι} {t : Set ι'} :
    ((⨅ i ∈ s, f i) ⊔ ⨅ j ∈ t, g j) = ⨅ p ∈ s ×ˢ t, f (p : ι × ι').1 ⊔ g p.2 :=
  @biSup_inf_biSup αᵒᵈ _ _ _ _ _ _ _
#align binfi_sup_binfi biInf_sup_biInf
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print sInf_sup_sInf /-
theorem sInf_sup_sInf : sInf s ⊔ sInf t = ⨅ p ∈ s ×ˢ t, (p : α × α).1 ⊔ p.2 :=
  @sSup_inf_sSup αᵒᵈ _ _ _
#align Inf_sup_Inf sInf_sup_sInf
-/

#print iInf_sup_of_monotone /-
theorem iInf_sup_of_monotone {ι : Type _} [Preorder ι] [IsDirected ι (swap (· ≤ ·))] {f g : ι → α}
    (hf : Monotone f) (hg : Monotone g) : (⨅ i, f i ⊔ g i) = (⨅ i, f i) ⊔ ⨅ i, g i :=
  iSup_inf_of_antitone hf.dual_right hg.dual_right
#align infi_sup_of_monotone iInf_sup_of_monotone
-/

#print iInf_sup_of_antitone /-
theorem iInf_sup_of_antitone {ι : Type _} [Preorder ι] [IsDirected ι (· ≤ ·)] {f g : ι → α}
    (hf : Antitone f) (hg : Antitone g) : (⨅ i, f i ⊔ g i) = (⨅ i, f i) ⊔ ⨅ i, g i :=
  iSup_inf_of_monotone hf.dual_right hg.dual_right
#align infi_sup_of_antitone iInf_sup_of_antitone
-/

#print Pi.coframe /-
instance Pi.coframe {ι : Type _} {π : ι → Type _} [∀ i, Coframe (π i)] : Coframe (∀ i, π i) :=
  { Pi.completeLattice with
    sInf := sInf
    iInf_sup_le_sup_inf := fun a s i => by
      simp only [← sup_iInf_eq, sInf_apply, ← iInf_subtype'', iInf_apply, Pi.sup_apply] }
#align pi.coframe Pi.coframe
-/

#print Coframe.toDistribLattice /-
-- see Note [lower instance priority]
instance (priority := 100) Coframe.toDistribLattice : DistribLattice α :=
  { ‹Coframe α› with
    le_sup_inf := fun a b c => by
      rw [← sInf_pair, ← sInf_pair, sup_sInf_eq, ← sInf_image, image_pair] }
#align coframe.to_distrib_lattice Coframe.toDistribLattice
-/

end Coframe

section CompleteDistribLattice

variable [CompleteDistribLattice α] {a b : α} {s t : Set α}

instance : CompleteDistribLattice αᵒᵈ :=
  { OrderDual.frame, OrderDual.coframe with }

#print Pi.completeDistribLattice /-
instance Pi.completeDistribLattice {ι : Type _} {π : ι → Type _}
    [∀ i, CompleteDistribLattice (π i)] : CompleteDistribLattice (∀ i, π i) :=
  { Pi.frame, Pi.coframe with }
#align pi.complete_distrib_lattice Pi.completeDistribLattice
-/

end CompleteDistribLattice

#print CompleteBooleanAlgebra /-
/-- A complete Boolean algebra is a completely distributive Boolean algebra. -/
class CompleteBooleanAlgebra (α) extends BooleanAlgebra α, CompleteDistribLattice α
#align complete_boolean_algebra CompleteBooleanAlgebra
-/

#print Pi.completeBooleanAlgebra /-
instance Pi.completeBooleanAlgebra {ι : Type _} {π : ι → Type _}
    [∀ i, CompleteBooleanAlgebra (π i)] : CompleteBooleanAlgebra (∀ i, π i) :=
  { Pi.booleanAlgebra, Pi.completeDistribLattice with }
#align pi.complete_boolean_algebra Pi.completeBooleanAlgebra
-/

#print Prop.completeBooleanAlgebra /-
instance Prop.completeBooleanAlgebra : CompleteBooleanAlgebra Prop :=
  { Prop.booleanAlgebra,
    Prop.completeLattice with
    iInf_sup_le_sup_inf := fun p s =>
      Iff.mp <| by simp only [forall_or_left, CompleteLattice.inf, iInf_Prop_eq, sup_Prop_eq]
    inf_sup_le_iSup_inf := fun p s =>
      Iff.mp <| by simp only [CompleteLattice.sup, exists_and_left, inf_Prop_eq, iSup_Prop_eq] }
#align Prop.complete_boolean_algebra Prop.completeBooleanAlgebra
-/

section CompleteBooleanAlgebra

variable [CompleteBooleanAlgebra α] {a b : α} {s : Set α} {f : ι → α}

#print compl_iInf /-
theorem compl_iInf : iInf fᶜ = ⨆ i, f iᶜ :=
  le_antisymm
    (compl_le_of_compl_le <| le_iInf fun i => compl_le_of_compl_le <| le_iSup (compl ∘ f) i)
    (iSup_le fun i => compl_le_compl <| iInf_le _ _)
#align compl_infi compl_iInf
-/

#print compl_iSup /-
theorem compl_iSup : iSup fᶜ = ⨅ i, f iᶜ :=
  compl_injective (by simp [compl_iInf])
#align compl_supr compl_iSup
-/

#print compl_sInf /-
theorem compl_sInf : sInf sᶜ = ⨆ i ∈ s, iᶜ := by simp only [sInf_eq_iInf, compl_iInf]
#align compl_Inf compl_sInf
-/

#print compl_sSup /-
theorem compl_sSup : sSup sᶜ = ⨅ i ∈ s, iᶜ := by simp only [sSup_eq_iSup, compl_iSup]
#align compl_Sup compl_sSup
-/

#print compl_sInf' /-
theorem compl_sInf' : sInf sᶜ = sSup (compl '' s) :=
  compl_sInf.trans sSup_image.symm
#align compl_Inf' compl_sInf'
-/

#print compl_sSup' /-
theorem compl_sSup' : sSup sᶜ = sInf (compl '' s) :=
  compl_sSup.trans sInf_image.symm
#align compl_Sup' compl_sSup'
-/

end CompleteBooleanAlgebra

section lift

#print Function.Injective.frame /-
-- See note [reducible non-instances]
/-- Pullback an `order.frame` along an injection. -/
@[reducible]
protected def Function.Injective.frame [Sup α] [Inf α] [SupSet α] [InfSet α] [Top α] [Bot α]
    [Frame β] (f : α → β) (hf : Injective f) (map_sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b)
    (map_inf : ∀ a b, f (a ⊓ b) = f a ⊓ f b) (map_Sup : ∀ s, f (sSup s) = ⨆ a ∈ s, f a)
    (map_Inf : ∀ s, f (sInf s) = ⨅ a ∈ s, f a) (map_top : f ⊤ = ⊤) (map_bot : f ⊥ = ⊥) : Frame α :=
  { hf.CompleteLattice f map_sup map_inf map_Sup map_Inf map_top map_bot with
    inf_sup_le_iSup_inf := fun a s => by
      change f (a ⊓ Sup s) ≤ f _
      rw [← sSup_image, map_inf, map_Sup s, inf_iSup₂_eq]
      simp_rw [← map_inf]
      exact ((map_Sup _).trans iSup_image).ge }
#align function.injective.frame Function.Injective.frame
-/

#print Function.Injective.coframe /-
-- See note [reducible non-instances]
/-- Pullback an `order.coframe` along an injection. -/
@[reducible]
protected def Function.Injective.coframe [Sup α] [Inf α] [SupSet α] [InfSet α] [Top α] [Bot α]
    [Coframe β] (f : α → β) (hf : Injective f) (map_sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b)
    (map_inf : ∀ a b, f (a ⊓ b) = f a ⊓ f b) (map_Sup : ∀ s, f (sSup s) = ⨆ a ∈ s, f a)
    (map_Inf : ∀ s, f (sInf s) = ⨅ a ∈ s, f a) (map_top : f ⊤ = ⊤) (map_bot : f ⊥ = ⊥) :
    Coframe α :=
  { hf.CompleteLattice f map_sup map_inf map_Sup map_Inf map_top map_bot with
    iInf_sup_le_sup_inf := fun a s => by
      change f _ ≤ f (a ⊔ Inf s)
      rw [← sInf_image, map_sup, map_Inf s, sup_iInf₂_eq]
      simp_rw [← map_sup]
      exact ((map_Inf _).trans iInf_image).le }
#align function.injective.coframe Function.Injective.coframe
-/

#print Function.Injective.completeDistribLattice /-
-- See note [reducible non-instances]
/-- Pullback a `complete_distrib_lattice` along an injection. -/
@[reducible]
protected def Function.Injective.completeDistribLattice [Sup α] [Inf α] [SupSet α] [InfSet α]
    [Top α] [Bot α] [CompleteDistribLattice β] (f : α → β) (hf : Function.Injective f)
    (map_sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b) (map_inf : ∀ a b, f (a ⊓ b) = f a ⊓ f b)
    (map_Sup : ∀ s, f (sSup s) = ⨆ a ∈ s, f a) (map_Inf : ∀ s, f (sInf s) = ⨅ a ∈ s, f a)
    (map_top : f ⊤ = ⊤) (map_bot : f ⊥ = ⊥) : CompleteDistribLattice α :=
  { hf.Frame f map_sup map_inf map_Sup map_Inf map_top map_bot,
    hf.Coframe f map_sup map_inf map_Sup map_Inf map_top map_bot with }
#align function.injective.complete_distrib_lattice Function.Injective.completeDistribLattice
-/

#print Function.Injective.completeBooleanAlgebra /-
-- See note [reducible non-instances]
/-- Pullback a `complete_boolean_algebra` along an injection. -/
@[reducible]
protected def Function.Injective.completeBooleanAlgebra [Sup α] [Inf α] [SupSet α] [InfSet α]
    [Top α] [Bot α] [HasCompl α] [SDiff α] [CompleteBooleanAlgebra β] (f : α → β)
    (hf : Function.Injective f) (map_sup : ∀ a b, f (a ⊔ b) = f a ⊔ f b)
    (map_inf : ∀ a b, f (a ⊓ b) = f a ⊓ f b) (map_Sup : ∀ s, f (sSup s) = ⨆ a ∈ s, f a)
    (map_Inf : ∀ s, f (sInf s) = ⨅ a ∈ s, f a) (map_top : f ⊤ = ⊤) (map_bot : f ⊥ = ⊥)
    (map_compl : ∀ a, f (aᶜ) = f aᶜ) (map_sdiff : ∀ a b, f (a \ b) = f a \ f b) :
    CompleteBooleanAlgebra α :=
  { hf.CompleteDistribLattice f map_sup map_inf map_Sup map_Inf map_top map_bot,
    hf.BooleanAlgebra f map_sup map_inf map_top map_bot map_compl map_sdiff with }
#align function.injective.complete_boolean_algebra Function.Injective.completeBooleanAlgebra
-/

end lift

namespace PUnit

variable (s : Set PUnit.{u + 1}) (x y : PUnit.{u + 1})

instance : CompleteBooleanAlgebra PUnit := by
  refine_struct
        { PUnit.booleanAlgebra with
          sSup := fun _ => star
          sInf := fun _ => star } <;>
      intros <;>
    first
    | trivial
    | simp only [eq_iff_true_of_subsingleton, not_true, and_false_iff]

#print PUnit.sSup_eq /-
@[simp]
theorem sSup_eq : sSup s = unit :=
  rfl
#align punit.Sup_eq PUnit.sSup_eq
-/

#print PUnit.sInf_eq /-
@[simp]
theorem sInf_eq : sInf s = unit :=
  rfl
#align punit.Inf_eq PUnit.sInf_eq
-/

end PUnit

