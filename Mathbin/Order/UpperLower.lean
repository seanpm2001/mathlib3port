/-
Copyright (c) 2022 Yaël Dillies, Sara Rousta. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Sara Rousta
-/
import Mathbin.Data.SetLike.Basic
import Mathbin.Data.Set.Intervals.OrdConnected
import Mathbin.Data.Set.Intervals.OrderIso
import Mathbin.Order.Hom.CompleteLattice

/-!
# Up-sets and down-sets

This file defines upper and lower sets in an order.

## Main declarations

* `is_upper_set`: Predicate for a set to be an upper set. This means every element greater than a
  member of the set is in the set itself.
* `is_lower_set`: Predicate for a set to be a lower set. This means every element less than a member
  of the set is in the set itself.
* `upper_set`: The type of upper sets.
* `lower_set`: The type of lower sets.
* `upper_closure`: The greatest upper set containing a set.
* `lower_closure`: The least lower set containing a set.
* `upper_set.Ici`: Principal upper set. `set.Ici` as an upper set.
* `upper_set.Ioi`: Strict principal upper set. `set.Ioi` as an upper set.
* `lower_set.Iic`: Principal lower set. `set.Iic` as an lower set.
* `lower_set.Iio`: Strict principal lower set. `set.Iio` as an lower set.

## Notes

Upper sets are ordered by **reverse** inclusion. This convention is motivated by the fact that this
makes them order-isomorphic to lower sets and antichains, and matches the convention on `filter`.

## TODO

Lattice structure on antichains. Order equivalence between upper/lower sets and antichains.
-/


open OrderDual Set

variable {α β γ : Type _} {ι : Sort _} {κ : ι → Sort _}

/-! ### Unbundled upper/lower sets -/


section LE

variable [LE α] [LE β] {s t : Set α}

/-- An upper set in an order `α` is a set such that any element greater than one of its members is
also a member. Also called up-set, upward-closed set. -/
def IsUpperSet (s : Set α) : Prop :=
  ∀ ⦃a b : α⦄, a ≤ b → a ∈ s → b ∈ s

/-- A lower set in an order `α` is a set such that any element less than one of its members is also
a member. Also called down-set, downward-closed set. -/
def IsLowerSet (s : Set α) : Prop :=
  ∀ ⦃a b : α⦄, b ≤ a → a ∈ s → b ∈ s

theorem is_upper_set_empty : IsUpperSet (∅ : Set α) := fun _ _ _ => id

theorem is_lower_set_empty : IsLowerSet (∅ : Set α) := fun _ _ _ => id

theorem is_upper_set_univ : IsUpperSet (Univ : Set α) := fun _ _ _ => id

theorem is_lower_set_univ : IsLowerSet (Univ : Set α) := fun _ _ _ => id

theorem IsUpperSet.compl (hs : IsUpperSet s) : IsLowerSet (sᶜ) := fun a b h hb ha => hb <| hs h ha

theorem IsLowerSet.compl (hs : IsLowerSet s) : IsUpperSet (sᶜ) := fun a b h hb ha => hb <| hs h ha

@[simp]
theorem is_upper_set_compl : IsUpperSet (sᶜ) ↔ IsLowerSet s :=
  ⟨fun h => by
    convert h.compl
    rw [compl_compl], IsLowerSet.compl⟩

@[simp]
theorem is_lower_set_compl : IsLowerSet (sᶜ) ↔ IsUpperSet s :=
  ⟨fun h => by
    convert h.compl
    rw [compl_compl], IsUpperSet.compl⟩

theorem IsUpperSet.union (hs : IsUpperSet s) (ht : IsUpperSet t) : IsUpperSet (s ∪ t) := fun a b h =>
  Or.imp (hs h) (ht h)

theorem IsLowerSet.union (hs : IsLowerSet s) (ht : IsLowerSet t) : IsLowerSet (s ∪ t) := fun a b h =>
  Or.imp (hs h) (ht h)

theorem IsUpperSet.inter (hs : IsUpperSet s) (ht : IsUpperSet t) : IsUpperSet (s ∩ t) := fun a b h =>
  And.imp (hs h) (ht h)

theorem IsLowerSet.inter (hs : IsLowerSet s) (ht : IsLowerSet t) : IsLowerSet (s ∩ t) := fun a b h =>
  And.imp (hs h) (ht h)

theorem is_upper_set_Union {f : ι → Set α} (hf : ∀ i, IsUpperSet (f i)) : IsUpperSet (⋃ i, f i) := fun a b h =>
  Exists₂Cat.imp <| forall_range_iff.2 fun i => hf i h

theorem is_lower_set_Union {f : ι → Set α} (hf : ∀ i, IsLowerSet (f i)) : IsLowerSet (⋃ i, f i) := fun a b h =>
  Exists₂Cat.imp <| forall_range_iff.2 fun i => hf i h

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
theorem is_upper_set_Union₂ {f : ∀ i, κ i → Set α} (hf : ∀ i j, IsUpperSet (f i j)) : IsUpperSet (⋃ (i) (j), f i j) :=
  is_upper_set_Union fun i => is_upper_set_Union <| hf i

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
theorem is_lower_set_Union₂ {f : ∀ i, κ i → Set α} (hf : ∀ i j, IsLowerSet (f i j)) : IsLowerSet (⋃ (i) (j), f i j) :=
  is_lower_set_Union fun i => is_lower_set_Union <| hf i

theorem is_upper_set_sUnion {S : Set (Set α)} (hf : ∀ s ∈ S, IsUpperSet s) : IsUpperSet (⋃₀S) := fun a b h =>
  Exists₂Cat.imp fun s hs => hf s hs h

theorem is_lower_set_sUnion {S : Set (Set α)} (hf : ∀ s ∈ S, IsLowerSet s) : IsLowerSet (⋃₀S) := fun a b h =>
  Exists₂Cat.imp fun s hs => hf s hs h

theorem is_upper_set_Inter {f : ι → Set α} (hf : ∀ i, IsUpperSet (f i)) : IsUpperSet (⋂ i, f i) := fun a b h =>
  forall₂_imp <| forall_range_iff.2 fun i => hf i h

theorem is_lower_set_Inter {f : ι → Set α} (hf : ∀ i, IsLowerSet (f i)) : IsLowerSet (⋂ i, f i) := fun a b h =>
  forall₂_imp <| forall_range_iff.2 fun i => hf i h

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
theorem is_upper_set_Inter₂ {f : ∀ i, κ i → Set α} (hf : ∀ i j, IsUpperSet (f i j)) : IsUpperSet (⋂ (i) (j), f i j) :=
  is_upper_set_Inter fun i => is_upper_set_Inter <| hf i

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
theorem is_lower_set_Inter₂ {f : ∀ i, κ i → Set α} (hf : ∀ i j, IsLowerSet (f i j)) : IsLowerSet (⋂ (i) (j), f i j) :=
  is_lower_set_Inter fun i => is_lower_set_Inter <| hf i

theorem is_upper_set_sInter {S : Set (Set α)} (hf : ∀ s ∈ S, IsUpperSet s) : IsUpperSet (⋂₀ S) := fun a b h =>
  forall₂_imp fun s hs => hf s hs h

theorem is_lower_set_sInter {S : Set (Set α)} (hf : ∀ s ∈ S, IsLowerSet s) : IsLowerSet (⋂₀ S) := fun a b h =>
  forall₂_imp fun s hs => hf s hs h

@[simp]
theorem is_lower_set_preimage_of_dual_iff : IsLowerSet (of_dual ⁻¹' s) ↔ IsUpperSet s :=
  Iff.rfl

@[simp]
theorem is_upper_set_preimage_of_dual_iff : IsUpperSet (of_dual ⁻¹' s) ↔ IsLowerSet s :=
  Iff.rfl

@[simp]
theorem is_lower_set_preimage_to_dual_iff {s : Set αᵒᵈ} : IsLowerSet (to_dual ⁻¹' s) ↔ IsUpperSet s :=
  Iff.rfl

@[simp]
theorem is_upper_set_preimage_to_dual_iff {s : Set αᵒᵈ} : IsUpperSet (to_dual ⁻¹' s) ↔ IsLowerSet s :=
  Iff.rfl

alias is_lower_set_preimage_of_dual_iff ↔ _ IsUpperSet.of_dual

alias is_upper_set_preimage_of_dual_iff ↔ _ IsLowerSet.of_dual

alias is_lower_set_preimage_to_dual_iff ↔ _ IsUpperSet.to_dual

alias is_upper_set_preimage_to_dual_iff ↔ _ IsLowerSet.to_dual

end LE

section Preorder

variable [Preorder α] [Preorder β] {s : Set α} {p : α → Prop} (a : α)

theorem is_upper_set_Ici : IsUpperSet (IciCat a) := fun _ _ => ge_trans

theorem is_lower_set_Iic : IsLowerSet (IicCat a) := fun _ _ => le_trans

theorem is_upper_set_Ioi : IsUpperSet (IoiCat a) := fun _ _ => flip lt_of_lt_of_le

theorem is_lower_set_Iio : IsLowerSet (IioCat a) := fun _ _ => lt_of_le_of_lt

theorem is_upper_set_iff_Ici_subset : IsUpperSet s ↔ ∀ ⦃a⦄, a ∈ s → IciCat a ⊆ s := by
  simp [IsUpperSet, subset_def, @forall_swap (_ ∈ s)]

theorem is_lower_set_iff_Iic_subset : IsLowerSet s ↔ ∀ ⦃a⦄, a ∈ s → IicCat a ⊆ s := by
  simp [IsLowerSet, subset_def, @forall_swap (_ ∈ s)]

alias is_upper_set_iff_Ici_subset ↔ IsUpperSet.Ici_subset _

alias is_lower_set_iff_Iic_subset ↔ IsLowerSet.Iic_subset _

theorem IsUpperSet.ord_connected (h : IsUpperSet s) : s.OrdConnected :=
  ⟨fun a ha b _ => Icc_subset_Ici_self.trans <| h.Ici_subset ha⟩

theorem IsLowerSet.ord_connected (h : IsLowerSet s) : s.OrdConnected :=
  ⟨fun a _ b hb => Icc_subset_Iic_self.trans <| h.Iic_subset hb⟩

theorem IsUpperSet.preimage (hs : IsUpperSet s) {f : β → α} (hf : Monotone f) : IsUpperSet (f ⁻¹' s : Set β) :=
  fun x y hxy => hs <| hf hxy

theorem IsLowerSet.preimage (hs : IsLowerSet s) {f : β → α} (hf : Monotone f) : IsLowerSet (f ⁻¹' s : Set β) :=
  fun x y hxy => hs <| hf hxy

theorem IsUpperSet.image (hs : IsUpperSet s) (f : α ≃o β) : IsUpperSet (f '' s : Set β) := by
  change IsUpperSet ((f : α ≃ β) '' s)
  rw [Set.image_equiv_eq_preimage_symm]
  exact hs.preimage f.symm.monotone

theorem IsLowerSet.image (hs : IsLowerSet s) (f : α ≃o β) : IsLowerSet (f '' s : Set β) := by
  change IsLowerSet ((f : α ≃ β) '' s)
  rw [Set.image_equiv_eq_preimage_symm]
  exact hs.preimage f.symm.monotone

@[simp]
theorem Set.monotone_mem : Monotone (· ∈ s) ↔ IsUpperSet s :=
  Iff.rfl

@[simp]
theorem Set.antitone_mem : Antitone (· ∈ s) ↔ IsLowerSet s :=
  forall_swap

@[simp]
theorem is_upper_set_set_of : IsUpperSet { a | p a } ↔ Monotone p :=
  Iff.rfl

@[simp]
theorem is_lower_set_set_of : IsLowerSet { a | p a } ↔ Antitone p :=
  forall_swap

section OrderTop

variable [OrderTop α]

theorem IsLowerSet.top_mem (hs : IsLowerSet s) : ⊤ ∈ s ↔ s = univ :=
  ⟨fun h => eq_univ_of_forall fun a => hs le_top h, fun h => h.symm ▸ mem_univ _⟩

theorem IsUpperSet.top_mem (hs : IsUpperSet s) : ⊤ ∈ s ↔ s.Nonempty :=
  ⟨fun h => ⟨_, h⟩, fun ⟨a, ha⟩ => hs le_top ha⟩

theorem IsUpperSet.not_top_mem (hs : IsUpperSet s) : ⊤ ∉ s ↔ s = ∅ :=
  hs.top_mem.Not.trans not_nonempty_iff_eq_empty

end OrderTop

section OrderBot

variable [OrderBot α]

theorem IsUpperSet.bot_mem (hs : IsUpperSet s) : ⊥ ∈ s ↔ s = univ :=
  ⟨fun h => eq_univ_of_forall fun a => hs bot_le h, fun h => h.symm ▸ mem_univ _⟩

theorem IsLowerSet.bot_mem (hs : IsLowerSet s) : ⊥ ∈ s ↔ s.Nonempty :=
  ⟨fun h => ⟨_, h⟩, fun ⟨a, ha⟩ => hs bot_le ha⟩

theorem IsLowerSet.not_bot_mem (hs : IsLowerSet s) : ⊥ ∉ s ↔ s = ∅ :=
  hs.bot_mem.Not.trans not_nonempty_iff_eq_empty

end OrderBot

section NoMaxOrder

variable [NoMaxOrder α] (a)

theorem IsUpperSet.not_bdd_above (hs : IsUpperSet s) : s.Nonempty → ¬BddAbove s := by
  rintro ⟨a, ha⟩ ⟨b, hb⟩
  obtain ⟨c, hc⟩ := exists_gt b
  exact hc.not_le (hb <| hs ((hb ha).trans hc.le) ha)

theorem not_bdd_above_Ici : ¬BddAbove (IciCat a) :=
  (is_upper_set_Ici _).not_bdd_above nonempty_Ici

theorem not_bdd_above_Ioi : ¬BddAbove (IoiCat a) :=
  (is_upper_set_Ioi _).not_bdd_above nonempty_Ioi

end NoMaxOrder

section NoMinOrder

variable [NoMinOrder α] (a)

theorem IsLowerSet.not_bdd_below (hs : IsLowerSet s) : s.Nonempty → ¬BddBelow s := by
  rintro ⟨a, ha⟩ ⟨b, hb⟩
  obtain ⟨c, hc⟩ := exists_lt b
  exact hc.not_le (hb <| hs (hc.le.trans <| hb ha) ha)

theorem not_bdd_below_Iic : ¬BddBelow (IicCat a) :=
  (is_lower_set_Iic _).not_bdd_below nonempty_Iic

theorem not_bdd_below_Iio : ¬BddBelow (IioCat a) :=
  (is_lower_set_Iio _).not_bdd_below nonempty_Iio

end NoMinOrder

end Preorder

section PartialOrder

variable [PartialOrder α] {s : Set α}

theorem is_upper_set_iff_forall_lt : IsUpperSet s ↔ ∀ ⦃a b : α⦄, a < b → a ∈ s → b ∈ s :=
  forall_congr' fun a => by simp [le_iff_eq_or_lt, or_imp, forall_and]

theorem is_lower_set_iff_forall_lt : IsLowerSet s ↔ ∀ ⦃a b : α⦄, b < a → a ∈ s → b ∈ s :=
  forall_congr' fun a => by simp [le_iff_eq_or_lt, or_imp, forall_and]

theorem is_upper_set_iff_Ioi_subset : IsUpperSet s ↔ ∀ ⦃a⦄, a ∈ s → IoiCat a ⊆ s := by
  simp [is_upper_set_iff_forall_lt, subset_def, @forall_swap (_ ∈ s)]

theorem is_lower_set_iff_Iio_subset : IsLowerSet s ↔ ∀ ⦃a⦄, a ∈ s → IioCat a ⊆ s := by
  simp [is_lower_set_iff_forall_lt, subset_def, @forall_swap (_ ∈ s)]

alias is_upper_set_iff_Ioi_subset ↔ IsUpperSet.Ioi_subset _

alias is_lower_set_iff_Iio_subset ↔ IsLowerSet.Iio_subset _

end PartialOrder

/-! ### Bundled upper/lower sets -/


section LE

variable [LE α]

/-- The type of upper sets of an order. -/
structure UpperSet (α : Type _) [LE α] where
  Carrier : Set α
  upper' : IsUpperSet carrier

/-- The type of lower sets of an order. -/
structure LowerSet (α : Type _) [LE α] where
  Carrier : Set α
  lower' : IsLowerSet carrier

namespace UpperSet

instance : SetLike (UpperSet α) α where
  coe := UpperSet.Carrier
  coe_injective' s t h := by
    cases s
    cases t
    congr

@[ext]
theorem ext {s t : UpperSet α} : (s : Set α) = t → s = t :=
  SetLike.ext'

@[simp]
theorem carrier_eq_coe (s : UpperSet α) : s.Carrier = s :=
  rfl

protected theorem upper (s : UpperSet α) : IsUpperSet (s : Set α) :=
  s.upper'

@[simp]
theorem mem_mk (carrier : Set α) (upper') {a : α} : a ∈ mk carrier upper' ↔ a ∈ carrier :=
  Iff.rfl

end UpperSet

namespace LowerSet

instance : SetLike (LowerSet α) α where
  coe := LowerSet.Carrier
  coe_injective' s t h := by
    cases s
    cases t
    congr

@[ext]
theorem ext {s t : LowerSet α} : (s : Set α) = t → s = t :=
  SetLike.ext'

@[simp]
theorem carrier_eq_coe (s : LowerSet α) : s.Carrier = s :=
  rfl

protected theorem lower (s : LowerSet α) : IsLowerSet (s : Set α) :=
  s.lower'

@[simp]
theorem mem_mk (carrier : Set α) (lower') {a : α} : a ∈ mk carrier lower' ↔ a ∈ carrier :=
  Iff.rfl

end LowerSet

/-! #### Order -/


namespace UpperSet

variable {S : Set (UpperSet α)} {s t : UpperSet α} {a : α}

instance : HasSup (UpperSet α) :=
  ⟨fun s t => ⟨s ∩ t, s.upper.inter t.upper⟩⟩

instance : HasInf (UpperSet α) :=
  ⟨fun s t => ⟨s ∪ t, s.upper.union t.upper⟩⟩

instance : HasTop (UpperSet α) :=
  ⟨⟨∅, is_upper_set_empty⟩⟩

instance : HasBot (UpperSet α) :=
  ⟨⟨Univ, is_upper_set_univ⟩⟩

instance : HasSup (UpperSet α) :=
  ⟨fun S => ⟨⋂ s ∈ S, ↑s, is_upper_set_Inter₂ fun s _ => s.upper⟩⟩

instance : HasInf (UpperSet α) :=
  ⟨fun S => ⟨⋃ s ∈ S, ↑s, is_upper_set_Union₂ fun s _ => s.upper⟩⟩

instance : CompleteDistribLattice (UpperSet α) :=
  (toDual.Injective.comp <| SetLike.coe_injective).CompleteDistribLattice _ (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ => rfl) (fun _ => rfl) rfl rfl

instance : Inhabited (UpperSet α) :=
  ⟨⊥⟩

@[simp, norm_cast]
theorem coe_subset_coe : (s : Set α) ⊆ t ↔ t ≤ s :=
  Iff.rfl

@[simp, norm_cast]
theorem coe_top : ((⊤ : UpperSet α) : Set α) = ∅ :=
  rfl

@[simp, norm_cast]
theorem coe_bot : ((⊥ : UpperSet α) : Set α) = univ :=
  rfl

@[simp, norm_cast]
theorem coe_sup (s t : UpperSet α) : (↑(s ⊔ t) : Set α) = s ∩ t :=
  rfl

@[simp, norm_cast]
theorem coe_inf (s t : UpperSet α) : (↑(s ⊓ t) : Set α) = s ∪ t :=
  rfl

@[simp, norm_cast]
theorem coe_Sup (S : Set (UpperSet α)) : (↑(sup S) : Set α) = ⋂ s ∈ S, ↑s :=
  rfl

@[simp, norm_cast]
theorem coe_Inf (S : Set (UpperSet α)) : (↑(inf S) : Set α) = ⋃ s ∈ S, ↑s :=
  rfl

@[simp, norm_cast]
theorem coe_supr (f : ι → UpperSet α) : (↑(⨆ i, f i) : Set α) = ⋂ i, f i := by simp [supr]

@[simp, norm_cast]
theorem coe_infi (f : ι → UpperSet α) : (↑(⨅ i, f i) : Set α) = ⋃ i, f i := by simp [infi]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp, norm_cast]
theorem coe_supr₂ (f : ∀ i, κ i → UpperSet α) : (↑(⨆ (i) (j), f i j) : Set α) = ⋂ (i) (j), f i j := by
  simp_rw [coe_supr]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp, norm_cast]
theorem coe_infi₂ (f : ∀ i, κ i → UpperSet α) : (↑(⨅ (i) (j), f i j) : Set α) = ⋃ (i) (j), f i j := by
  simp_rw [coe_infi]

@[simp]
theorem not_mem_top : a ∉ (⊤ : UpperSet α) :=
  id

@[simp]
theorem mem_bot : a ∈ (⊥ : UpperSet α) :=
  trivial

@[simp]
theorem mem_sup_iff : a ∈ s ⊔ t ↔ a ∈ s ∧ a ∈ t :=
  Iff.rfl

@[simp]
theorem mem_inf_iff : a ∈ s ⊓ t ↔ a ∈ s ∨ a ∈ t :=
  Iff.rfl

@[simp]
theorem mem_Sup_iff : a ∈ sup S ↔ ∀ s ∈ S, a ∈ s :=
  mem_Inter₂

@[simp]
theorem mem_Inf_iff : a ∈ inf S ↔ ∃ s ∈ S, a ∈ s :=
  mem_Union₂

@[simp]
theorem mem_supr_iff {f : ι → UpperSet α} : (a ∈ ⨆ i, f i) ↔ ∀ i, a ∈ f i := by
  rw [← SetLike.mem_coe, coe_supr]
  exact mem_Inter

@[simp]
theorem mem_infi_iff {f : ι → UpperSet α} : (a ∈ ⨅ i, f i) ↔ ∃ i, a ∈ f i := by
  rw [← SetLike.mem_coe, coe_infi]
  exact mem_Union

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem mem_supr₂_iff {f : ∀ i, κ i → UpperSet α} : (a ∈ ⨆ (i) (j), f i j) ↔ ∀ i j, a ∈ f i j := by
  simp_rw [mem_supr_iff]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem mem_infi₂_iff {f : ∀ i, κ i → UpperSet α} : (a ∈ ⨅ (i) (j), f i j) ↔ ∃ i j, a ∈ f i j := by
  simp_rw [mem_infi_iff]

end UpperSet

namespace LowerSet

variable {S : Set (LowerSet α)} {s t : LowerSet α} {a : α}

instance : HasSup (LowerSet α) :=
  ⟨fun s t => ⟨s ∪ t, fun a b h => Or.imp (s.lower h) (t.lower h)⟩⟩

instance : HasInf (LowerSet α) :=
  ⟨fun s t => ⟨s ∩ t, fun a b h => And.imp (s.lower h) (t.lower h)⟩⟩

instance : HasTop (LowerSet α) :=
  ⟨⟨Univ, fun a b h => id⟩⟩

instance : HasBot (LowerSet α) :=
  ⟨⟨∅, fun a b h => id⟩⟩

instance : HasSup (LowerSet α) :=
  ⟨fun S => ⟨⋃ s ∈ S, ↑s, is_lower_set_Union₂ fun s _ => s.lower⟩⟩

instance : HasInf (LowerSet α) :=
  ⟨fun S => ⟨⋂ s ∈ S, ↑s, is_lower_set_Inter₂ fun s _ => s.lower⟩⟩

instance : CompleteDistribLattice (LowerSet α) :=
  SetLike.coe_injective.CompleteDistribLattice _ (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ => rfl) rfl rfl

instance : Inhabited (LowerSet α) :=
  ⟨⊥⟩

@[simp, norm_cast]
theorem coe_subset_coe : (s : Set α) ⊆ t ↔ s ≤ t :=
  Iff.rfl

@[simp, norm_cast]
theorem coe_top : ((⊤ : LowerSet α) : Set α) = univ :=
  rfl

@[simp, norm_cast]
theorem coe_bot : ((⊥ : LowerSet α) : Set α) = ∅ :=
  rfl

@[simp, norm_cast]
theorem coe_sup (s t : LowerSet α) : (↑(s ⊔ t) : Set α) = s ∪ t :=
  rfl

@[simp, norm_cast]
theorem coe_inf (s t : LowerSet α) : (↑(s ⊓ t) : Set α) = s ∩ t :=
  rfl

@[simp, norm_cast]
theorem coe_Sup (S : Set (LowerSet α)) : (↑(sup S) : Set α) = ⋃ s ∈ S, ↑s :=
  rfl

@[simp, norm_cast]
theorem coe_Inf (S : Set (LowerSet α)) : (↑(inf S) : Set α) = ⋂ s ∈ S, ↑s :=
  rfl

@[simp, norm_cast]
theorem coe_supr (f : ι → LowerSet α) : (↑(⨆ i, f i) : Set α) = ⋃ i, f i := by
  simp_rw [supr, coe_Sup, mem_range, Union_exists, Union_Union_eq']

@[simp, norm_cast]
theorem coe_infi (f : ι → LowerSet α) : (↑(⨅ i, f i) : Set α) = ⋂ i, f i := by
  simp_rw [infi, coe_Inf, mem_range, Inter_exists, Inter_Inter_eq']

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp, norm_cast]
theorem coe_supr₂ (f : ∀ i, κ i → LowerSet α) : (↑(⨆ (i) (j), f i j) : Set α) = ⋃ (i) (j), f i j := by
  simp_rw [coe_supr]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp, norm_cast]
theorem coe_infi₂ (f : ∀ i, κ i → LowerSet α) : (↑(⨅ (i) (j), f i j) : Set α) = ⋂ (i) (j), f i j := by
  simp_rw [coe_infi]

@[simp]
theorem mem_top : a ∈ (⊤ : LowerSet α) :=
  trivial

@[simp]
theorem not_mem_bot : a ∉ (⊥ : LowerSet α) :=
  id

@[simp]
theorem mem_sup_iff : a ∈ s ⊔ t ↔ a ∈ s ∨ a ∈ t :=
  Iff.rfl

@[simp]
theorem mem_inf_iff : a ∈ s ⊓ t ↔ a ∈ s ∧ a ∈ t :=
  Iff.rfl

@[simp]
theorem mem_Sup_iff : a ∈ sup S ↔ ∃ s ∈ S, a ∈ s :=
  mem_Union₂

@[simp]
theorem mem_Inf_iff : a ∈ inf S ↔ ∀ s ∈ S, a ∈ s :=
  mem_Inter₂

@[simp]
theorem mem_supr_iff {f : ι → LowerSet α} : (a ∈ ⨆ i, f i) ↔ ∃ i, a ∈ f i := by
  rw [← SetLike.mem_coe, coe_supr]
  exact mem_Union

@[simp]
theorem mem_infi_iff {f : ι → LowerSet α} : (a ∈ ⨅ i, f i) ↔ ∀ i, a ∈ f i := by
  rw [← SetLike.mem_coe, coe_infi]
  exact mem_Inter

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem mem_supr₂_iff {f : ∀ i, κ i → LowerSet α} : (a ∈ ⨆ (i) (j), f i j) ↔ ∃ i j, a ∈ f i j := by
  simp_rw [mem_supr_iff]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem mem_infi₂_iff {f : ∀ i, κ i → LowerSet α} : (a ∈ ⨅ (i) (j), f i j) ↔ ∀ i j, a ∈ f i j := by
  simp_rw [mem_infi_iff]

end LowerSet

/-! #### Complement -/


/-- The complement of a lower set as an upper set. -/
def UpperSet.compl (s : UpperSet α) : LowerSet α :=
  ⟨sᶜ, s.upper.compl⟩

/-- The complement of a lower set as an upper set. -/
def LowerSet.compl (s : LowerSet α) : UpperSet α :=
  ⟨sᶜ, s.lower.compl⟩

namespace UpperSet

variable {s t : UpperSet α} {a : α}

@[simp]
theorem coe_compl (s : UpperSet α) : (s.compl : Set α) = sᶜ :=
  rfl

@[simp]
theorem mem_compl_iff : a ∈ s.compl ↔ a ∉ s :=
  Iff.rfl

@[simp]
theorem compl_compl (s : UpperSet α) : s.compl.compl = s :=
  UpperSet.ext <| compl_compl _

@[simp]
theorem compl_le_compl : s.compl ≤ t.compl ↔ s ≤ t :=
  compl_subset_compl

@[simp]
protected theorem compl_sup (s t : UpperSet α) : (s ⊔ t).compl = s.compl ⊔ t.compl :=
  LowerSet.ext compl_inf

@[simp]
protected theorem compl_inf (s t : UpperSet α) : (s ⊓ t).compl = s.compl ⊓ t.compl :=
  LowerSet.ext compl_sup

@[simp]
protected theorem compl_top : (⊤ : UpperSet α).compl = ⊤ :=
  LowerSet.ext compl_empty

@[simp]
protected theorem compl_bot : (⊥ : UpperSet α).compl = ⊥ :=
  LowerSet.ext compl_univ

@[simp]
protected theorem compl_Sup (S : Set (UpperSet α)) : (sup S).compl = ⨆ s ∈ S, UpperSet.compl s :=
  LowerSet.ext <| by simp only [coe_compl, coe_Sup, compl_Inter₂, LowerSet.coe_supr₂]

@[simp]
protected theorem compl_Inf (S : Set (UpperSet α)) : (inf S).compl = ⨅ s ∈ S, UpperSet.compl s :=
  LowerSet.ext <| by simp only [coe_compl, coe_Inf, compl_Union₂, LowerSet.coe_infi₂]

@[simp]
protected theorem compl_supr (f : ι → UpperSet α) : (⨆ i, f i).compl = ⨆ i, (f i).compl :=
  LowerSet.ext <| by simp only [coe_compl, coe_supr, compl_Inter, LowerSet.coe_supr]

@[simp]
protected theorem compl_infi (f : ι → UpperSet α) : (⨅ i, f i).compl = ⨅ i, (f i).compl :=
  LowerSet.ext <| by simp only [coe_compl, coe_infi, compl_Union, LowerSet.coe_infi]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem compl_supr₂ (f : ∀ i, κ i → UpperSet α) : (⨆ (i) (j), f i j).compl = ⨆ (i) (j), (f i j).compl := by
  simp_rw [UpperSet.compl_supr]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem compl_infi₂ (f : ∀ i, κ i → UpperSet α) : (⨅ (i) (j), f i j).compl = ⨅ (i) (j), (f i j).compl := by
  simp_rw [UpperSet.compl_infi]

end UpperSet

namespace LowerSet

variable {s t : LowerSet α} {a : α}

@[simp]
theorem coe_compl (s : LowerSet α) : (s.compl : Set α) = sᶜ :=
  rfl

@[simp]
theorem mem_compl_iff : a ∈ s.compl ↔ a ∉ s :=
  Iff.rfl

@[simp]
theorem compl_compl (s : LowerSet α) : s.compl.compl = s :=
  LowerSet.ext <| compl_compl _

@[simp]
theorem compl_le_compl : s.compl ≤ t.compl ↔ s ≤ t :=
  compl_subset_compl

protected theorem compl_sup (s t : LowerSet α) : (s ⊔ t).compl = s.compl ⊔ t.compl :=
  UpperSet.ext compl_sup

protected theorem compl_inf (s t : LowerSet α) : (s ⊓ t).compl = s.compl ⊓ t.compl :=
  UpperSet.ext compl_inf

protected theorem compl_top : (⊤ : LowerSet α).compl = ⊤ :=
  UpperSet.ext compl_univ

protected theorem compl_bot : (⊥ : LowerSet α).compl = ⊥ :=
  UpperSet.ext compl_empty

protected theorem compl_Sup (S : Set (LowerSet α)) : (sup S).compl = ⨆ s ∈ S, LowerSet.compl s :=
  UpperSet.ext <| by simp only [coe_compl, coe_Sup, compl_Union₂, UpperSet.coe_supr₂]

protected theorem compl_Inf (S : Set (LowerSet α)) : (inf S).compl = ⨅ s ∈ S, LowerSet.compl s :=
  UpperSet.ext <| by simp only [coe_compl, coe_Inf, compl_Inter₂, UpperSet.coe_infi₂]

protected theorem compl_supr (f : ι → LowerSet α) : (⨆ i, f i).compl = ⨆ i, (f i).compl :=
  UpperSet.ext <| by simp only [coe_compl, coe_supr, compl_Union, UpperSet.coe_supr]

protected theorem compl_infi (f : ι → LowerSet α) : (⨅ i, f i).compl = ⨅ i, (f i).compl :=
  UpperSet.ext <| by simp only [coe_compl, coe_infi, compl_Inter, UpperSet.coe_infi]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem compl_supr₂ (f : ∀ i, κ i → LowerSet α) : (⨆ (i) (j), f i j).compl = ⨆ (i) (j), (f i j).compl := by
  simp_rw [LowerSet.compl_supr]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem compl_infi₂ (f : ∀ i, κ i → LowerSet α) : (⨅ (i) (j), f i j).compl = ⨅ (i) (j), (f i j).compl := by
  simp_rw [LowerSet.compl_infi]

end LowerSet

/-- Upper sets are order-isomorphic to lower sets under complementation. -/
@[simps]
def upperSetIsoLowerSet : UpperSet α ≃o LowerSet α where
  toFun := UpperSet.compl
  invFun := LowerSet.compl
  left_inv := UpperSet.compl_compl
  right_inv := LowerSet.compl_compl
  map_rel_iff' _ _ := UpperSet.compl_le_compl

end LE

/-! #### Map -/


section

variable [Preorder α] [Preorder β] [Preorder γ]

namespace UpperSet

variable {f : α ≃o β} {s t : UpperSet α} {a : α} {b : β}

/-- An order isomorphism of preorders induces an order isomorphism of their upper sets. -/
def map (f : α ≃o β) : UpperSet α ≃o UpperSet β where
  toFun s := ⟨f '' s, s.upper.Image f⟩
  invFun t := ⟨f ⁻¹' t, t.upper.Preimage f.Monotone⟩
  left_inv _ := ext <| f.preimage_image _
  right_inv _ := ext <| f.image_preimage _
  map_rel_iff' s t := image_subset_image_iff f.Injective

@[simp]
theorem symm_map (f : α ≃o β) : (map f).symm = map f.symm :=
  (FunLike.ext _ _) fun s => ext <| Set.preimage_equiv_eq_image_symm _ _

@[simp]
theorem mem_map : b ∈ map f s ↔ f.symm b ∈ s := by
  rw [← f.symm_symm, ← symm_map, f.symm_symm]
  rfl

@[simp]
theorem map_refl : map (OrderIso.refl α) = OrderIso.refl _ := by
  ext
  simp

@[simp]
theorem map_map (g : β ≃o γ) (f : α ≃o β) : map g (map f s) = map (f.trans g) s := by
  ext
  simp

variable (f s t)

@[simp, norm_cast]
theorem coe_map : (map f s : Set β) = f '' s :=
  rfl

@[simp]
protected theorem map_sup : map f (s ⊔ t) = map f s ⊔ map f t :=
  ext <| (image_inter f.Injective).symm

@[simp]
protected theorem map_inf : map f (s ⊓ t) = map f s ⊓ map f t :=
  ext <| image_union _ _ _

@[simp]
protected theorem map_top : map f ⊤ = ⊤ :=
  ext <| image_empty _

@[simp]
protected theorem map_bot : map f ⊥ = ⊥ :=
  ext <| image_univ_of_surjective f.Surjective

@[simp]
protected theorem map_Sup (S : Set (UpperSet α)) : map f (sup S) = ⨆ s ∈ S, map f s :=
  ext <| by
    push_cast
    exact image_Inter₂ f.bijective _

@[simp]
protected theorem map_Inf (S : Set (UpperSet α)) : map f (inf S) = ⨅ s ∈ S, map f s :=
  ext <| by
    push_cast
    exact image_Union₂ _ _

@[simp]
protected theorem map_supr (g : ι → UpperSet α) : map f (⨆ i, g i) = ⨆ i, map f (g i) :=
  ext <| by
    push_cast
    exact image_Inter f.bijective _

@[simp]
protected theorem map_infi (g : ι → UpperSet α) : map f (⨅ i, g i) = ⨅ i, map f (g i) :=
  ext <| by
    push_cast
    exact image_Union

end UpperSet

namespace LowerSet

variable {f : α ≃o β} {s t : LowerSet α} {a : α} {b : β}

/-- An order isomorphism of preorders induces an order isomorphism of their lower sets. -/
def map (f : α ≃o β) : LowerSet α ≃o LowerSet β where
  toFun s := ⟨f '' s, s.lower.Image f⟩
  invFun t := ⟨f ⁻¹' t, t.lower.Preimage f.Monotone⟩
  left_inv _ := SetLike.coe_injective <| f.preimage_image _
  right_inv _ := SetLike.coe_injective <| f.image_preimage _
  map_rel_iff' s t := image_subset_image_iff f.Injective

@[simp]
theorem symm_map (f : α ≃o β) : (map f).symm = map f.symm :=
  (FunLike.ext _ _) fun s => SetLike.coe_injective <| Set.preimage_equiv_eq_image_symm _ _

@[simp]
theorem mem_map {f : α ≃o β} {b : β} : b ∈ map f s ↔ f.symm b ∈ s := by
  rw [← f.symm_symm, ← symm_map, f.symm_symm]
  rfl

@[simp]
theorem map_refl : map (OrderIso.refl α) = OrderIso.refl _ := by
  ext
  simp

@[simp]
theorem map_map (g : β ≃o γ) (f : α ≃o β) : map g (map f s) = map (f.trans g) s := by
  ext
  simp

variable (f s t)

@[simp, norm_cast]
theorem coe_map : (map f s : Set β) = f '' s :=
  rfl

@[simp]
protected theorem map_sup : map f (s ⊔ t) = map f s ⊔ map f t :=
  ext <| image_union _ _ _

@[simp]
protected theorem map_inf : map f (s ⊓ t) = map f s ⊓ map f t :=
  ext <| (image_inter f.Injective).symm

@[simp]
protected theorem map_top : map f ⊤ = ⊤ :=
  ext <| image_univ_of_surjective f.Surjective

@[simp]
protected theorem map_bot : map f ⊥ = ⊥ :=
  ext <| image_empty _

@[simp]
protected theorem map_Sup (S : Set (LowerSet α)) : map f (sup S) = ⨆ s ∈ S, map f s :=
  ext <| by
    push_cast
    exact image_Union₂ _ _

protected theorem map_Inf (S : Set (LowerSet α)) : map f (inf S) = ⨅ s ∈ S, map f s :=
  ext <| by
    push_cast
    exact image_Inter₂ f.bijective _

protected theorem map_supr (g : ι → LowerSet α) : map f (⨆ i, g i) = ⨆ i, map f (g i) :=
  ext <| by
    push_cast
    exact image_Union

protected theorem map_infi (g : ι → LowerSet α) : map f (⨅ i, g i) = ⨅ i, map f (g i) :=
  ext <| by
    push_cast
    exact image_Inter f.bijective _

end LowerSet

namespace UpperSet

@[simp]
theorem compl_map (f : α ≃o β) (s : UpperSet α) : (map f s).compl = LowerSet.map f s.compl :=
  SetLike.coe_injective (Set.image_compl_eq f.Bijective).symm

end UpperSet

namespace LowerSet

@[simp]
theorem compl_map (f : α ≃o β) (s : LowerSet α) : (map f s).compl = UpperSet.map f s.compl :=
  SetLike.coe_injective (Set.image_compl_eq f.Bijective).symm

end LowerSet

end

/-! #### Principal sets -/


namespace UpperSet

section Preorder

variable [Preorder α] [Preorder β] {s : UpperSet α} {a b : α}

/-- The smallest upper set containing a given element. -/
def ici (a : α) : UpperSet α :=
  ⟨IciCat a, is_upper_set_Ici a⟩

/-- The smallest upper set containing a given element. -/
def ioi (a : α) : UpperSet α :=
  ⟨IoiCat a, is_upper_set_Ioi a⟩

@[simp]
theorem coe_Ici (a : α) : ↑(ici a) = Set.IciCat a :=
  rfl

@[simp]
theorem coe_Ioi (a : α) : ↑(ioi a) = Set.IoiCat a :=
  rfl

@[simp]
theorem mem_Ici_iff : b ∈ ici a ↔ a ≤ b :=
  Iff.rfl

@[simp]
theorem mem_Ioi_iff : b ∈ ioi a ↔ a < b :=
  Iff.rfl

@[simp]
theorem map_Ici (f : α ≃o β) (a : α) : map f (ici a) = ici (f a) := by
  ext
  simp

@[simp]
theorem map_Ioi (f : α ≃o β) (a : α) : map f (ioi a) = ioi (f a) := by
  ext
  simp

theorem Ici_le_Ioi (a : α) : ici a ≤ ioi a :=
  Ioi_subset_Ici_self

@[simp]
theorem Ioi_top [OrderTop α] : ioi (⊤ : α) = ⊤ :=
  SetLike.coe_injective Ioi_top

@[simp]
theorem Ici_bot [OrderBot α] : ici (⊥ : α) = ⊥ :=
  SetLike.coe_injective Ici_bot

end Preorder

section SemilatticeSup

variable [SemilatticeSup α]

@[simp]
theorem Ici_sup (a b : α) : ici (a ⊔ b) = ici a ⊔ ici b :=
  ext Ici_inter_Ici.symm

/-- `upper_set.Ici` as a `sup_hom`. -/
def iciSupHom : SupHom α (UpperSet α) :=
  ⟨ici, Ici_sup⟩

@[simp]
theorem Ici_sup_hom_apply (a : α) : iciSupHom a = ici a :=
  rfl

end SemilatticeSup

section CompleteLattice

variable [CompleteLattice α]

@[simp]
theorem Ici_Sup (S : Set α) : ici (sup S) = ⨆ a ∈ S, ici a :=
  SetLike.ext fun c => by simp only [mem_Ici_iff, mem_supr_iff, Sup_le_iff]

@[simp]
theorem Ici_supr (f : ι → α) : ici (⨆ i, f i) = ⨆ i, ici (f i) :=
  SetLike.ext fun c => by simp only [mem_Ici_iff, mem_supr_iff, supr_le_iff]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem Ici_supr₂ (f : ∀ i, κ i → α) : ici (⨆ (i) (j), f i j) = ⨆ (i) (j), ici (f i j) := by simp_rw [Ici_supr]

/- warning: upper_set.Ici_Sup_hom clashes with upper_set.Ici_sup_hom -> UpperSet.iciSupHom
Case conversion may be inaccurate. Consider using '#align upper_set.Ici_Sup_hom UpperSet.iciSupHomₓ'. -/
#print UpperSet.iciSupHom /-
/-- `upper_set.Ici` as a `Sup_hom`. -/
def iciSupHom : SupHom α (UpperSet α) :=
  ⟨ici, fun s => (Ici_Sup s).trans Sup_image.symm⟩
-/

@[simp]
theorem Ici_Sup_hom_apply (a : α) : iciSupHom a = toDual (ici a) :=
  rfl

end CompleteLattice

end UpperSet

namespace LowerSet

section Preorder

variable [Preorder α] [Preorder β] {s : LowerSet α} {a b : α}

/-- Principal lower set. `set.Iic` as a lower set. The smallest lower set containing a given
element. -/
def iic (a : α) : LowerSet α :=
  ⟨IicCat a, is_lower_set_Iic a⟩

/-- Strict principal lower set. `set.Iio` as a lower set. -/
def iio (a : α) : LowerSet α :=
  ⟨IioCat a, is_lower_set_Iio a⟩

@[simp]
theorem coe_Iic (a : α) : ↑(iic a) = Set.IicCat a :=
  rfl

@[simp]
theorem coe_Iio (a : α) : ↑(iio a) = Set.IioCat a :=
  rfl

@[simp]
theorem mem_Iic_iff : b ∈ iic a ↔ b ≤ a :=
  Iff.rfl

@[simp]
theorem mem_Iio_iff : b ∈ iio a ↔ b < a :=
  Iff.rfl

@[simp]
theorem map_Iic (f : α ≃o β) (a : α) : map f (iic a) = iic (f a) := by
  ext
  simp

@[simp]
theorem map_Iio (f : α ≃o β) (a : α) : map f (iio a) = iio (f a) := by
  ext
  simp

theorem Ioi_le_Ici (a : α) : IoiCat a ≤ IciCat a :=
  Ioi_subset_Ici_self

@[simp]
theorem Iic_top [OrderTop α] : iic (⊤ : α) = ⊤ :=
  SetLike.coe_injective Iic_top

@[simp]
theorem Iio_bot [OrderBot α] : iio (⊥ : α) = ⊥ :=
  SetLike.coe_injective Iio_bot

end Preorder

section SemilatticeInf

variable [SemilatticeInf α]

@[simp]
theorem Iic_inf (a b : α) : iic (a ⊓ b) = iic a ⊓ iic b :=
  SetLike.coe_injective Iic_inter_Iic.symm

/-- `lower_set.Iic` as an `inf_hom`. -/
def iicInfHom : InfHom α (LowerSet α) :=
  ⟨iic, Iic_inf⟩

@[simp]
theorem coe_Iic_inf_hom : (iicInfHom : α → LowerSet α) = Iic :=
  rfl

@[simp]
theorem Iic_inf_hom_apply (a : α) : iicInfHom a = iic a :=
  rfl

end SemilatticeInf

section CompleteLattice

variable [CompleteLattice α]

@[simp]
theorem Iic_Inf (S : Set α) : iic (inf S) = ⨅ a ∈ S, iic a :=
  SetLike.ext fun c => by simp only [mem_Iic_iff, mem_infi₂_iff, le_Inf_iff]

@[simp]
theorem Iic_infi (f : ι → α) : iic (⨅ i, f i) = ⨅ i, iic (f i) :=
  SetLike.ext fun c => by simp only [mem_Iic_iff, mem_infi_iff, le_infi_iff]

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i j) -/
@[simp]
theorem Iic_infi₂ (f : ∀ i, κ i → α) : iic (⨅ (i) (j), f i j) = ⨅ (i) (j), iic (f i j) := by simp_rw [Iic_infi]

/- warning: lower_set.Iic_Inf_hom clashes with lower_set.Iic_inf_hom -> LowerSet.iicInfHom
Case conversion may be inaccurate. Consider using '#align lower_set.Iic_Inf_hom LowerSet.iicInfHomₓ'. -/
#print LowerSet.iicInfHom /-
/-- `lower_set.Iic` as an `Inf_hom`. -/
def iicInfHom : InfHom α (LowerSet α) :=
  ⟨iic, fun s => (Iic_Inf s).trans Inf_image.symm⟩
-/

@[simp]
theorem coe_Iic_Inf_hom : (iicInfHom : α → LowerSet α) = Iic :=
  rfl

@[simp]
theorem Iic_Inf_hom_apply (a : α) : iicInfHom a = iic a :=
  rfl

end CompleteLattice

end LowerSet

section Closure

variable [Preorder α] [Preorder β] {s t : Set α} {x : α}

/-- The greatest upper set containing a given set. -/
def upperClosure (s : Set α) : UpperSet α :=
  ⟨{ x | ∃ a ∈ s, a ≤ x }, fun x y h => Exists₂Cat.imp fun a _ => h.trans'⟩

/-- The least lower set containing a given set. -/
def lowerClosure (s : Set α) : LowerSet α :=
  ⟨{ x | ∃ a ∈ s, x ≤ a }, fun x y h => Exists₂Cat.imp fun a _ => h.trans⟩

-- We do not tag those two as `simp` to respect the abstraction.
@[norm_cast]
theorem coe_upper_closure (s : Set α) : ↑(upperClosure s) = { x | ∃ a ∈ s, a ≤ x } :=
  rfl

@[norm_cast]
theorem coe_lower_closure (s : Set α) : ↑(lowerClosure s) = { x | ∃ a ∈ s, x ≤ a } :=
  rfl

@[simp]
theorem mem_upper_closure : x ∈ upperClosure s ↔ ∃ a ∈ s, a ≤ x :=
  Iff.rfl

@[simp]
theorem mem_lower_closure : x ∈ lowerClosure s ↔ ∃ a ∈ s, x ≤ a :=
  Iff.rfl

theorem subset_upper_closure : s ⊆ upperClosure s := fun x hx => ⟨x, hx, le_rfl⟩

theorem subset_lower_closure : s ⊆ lowerClosure s := fun x hx => ⟨x, hx, le_rfl⟩

theorem upper_closure_min (h : s ⊆ t) (ht : IsUpperSet t) : ↑(upperClosure s) ⊆ t := fun a ⟨b, hb, hba⟩ =>
  ht hba <| h hb

theorem lower_closure_min (h : s ⊆ t) (ht : IsLowerSet t) : ↑(lowerClosure s) ⊆ t := fun a ⟨b, hb, hab⟩ =>
  ht hab <| h hb

protected theorem IsUpperSet.upper_closure (hs : IsUpperSet s) : ↑(upperClosure s) = s :=
  (upper_closure_min Subset.rfl hs).antisymm subset_upper_closure

protected theorem IsLowerSet.lower_closure (hs : IsLowerSet s) : ↑(lowerClosure s) = s :=
  (lower_closure_min Subset.rfl hs).antisymm subset_lower_closure

@[simp]
protected theorem UpperSet.upper_closure (s : UpperSet α) : upperClosure (s : Set α) = s :=
  SetLike.coe_injective s.2.upperClosure

@[simp]
protected theorem LowerSet.lower_closure (s : LowerSet α) : lowerClosure (s : Set α) = s :=
  SetLike.coe_injective s.2.lowerClosure

@[simp]
theorem upper_closure_image (f : α ≃o β) : upperClosure (f '' s) = UpperSet.map f (upperClosure s) := by
  rw [← f.symm_symm, ← UpperSet.symm_map, f.symm_symm]
  ext
  simp [-UpperSet.symm_map, UpperSet.map, OrderIso.symm, ← f.le_symm_apply]

@[simp]
theorem lower_closure_image (f : α ≃o β) : lowerClosure (f '' s) = LowerSet.map f (lowerClosure s) := by
  rw [← f.symm_symm, ← LowerSet.symm_map, f.symm_symm]
  ext
  simp [-LowerSet.symm_map, LowerSet.map, OrderIso.symm, ← f.symm_apply_le]

@[simp]
theorem UpperSet.infi_Ici (s : Set α) : (⨅ a ∈ s, UpperSet.ici a) = upperClosure s := by
  ext
  simp

@[simp]
theorem LowerSet.supr_Iic (s : Set α) : (⨆ a ∈ s, LowerSet.iic a) = lowerClosure s := by
  ext
  simp

theorem gc_upper_closure_coe : GaloisConnection (to_dual ∘ upperClosure : Set α → (UpperSet α)ᵒᵈ) (coe ∘ of_dual) :=
  fun s t => ⟨fun h => subset_upper_closure.trans <| UpperSet.coe_subset_coe.2 h, fun h => upper_closure_min h t.upper⟩

theorem gc_lower_closure_coe : GaloisConnection (lowerClosure : Set α → LowerSet α) coe := fun s t =>
  ⟨fun h => subset_lower_closure.trans <| LowerSet.coe_subset_coe.2 h, fun h => lower_closure_min h t.lower⟩

/-- `upper_closure` forms a reversed Galois insertion with the coercion from upper sets to sets. -/
def giUpperClosureCoe : GaloisInsertion (to_dual ∘ upperClosure : Set α → (UpperSet α)ᵒᵈ) (coe ∘ of_dual) where
  choice s hs := toDual (⟨s, fun a b hab ha => hs ⟨a, ha, hab⟩⟩ : UpperSet α)
  gc := gc_upper_closure_coe
  le_l_u _ := subset_upper_closure
  choice_eq s hs := ofDual.Injective <| SetLike.coe_injective <| subset_upper_closure.antisymm hs

/-- `lower_closure` forms a Galois insertion with the coercion from lower sets to sets. -/
def giLowerClosureCoe : GaloisInsertion (lowerClosure : Set α → LowerSet α) coe where
  choice s hs := ⟨s, fun a b hba ha => hs ⟨a, ha, hba⟩⟩
  gc := gc_lower_closure_coe
  le_l_u _ := subset_lower_closure
  choice_eq s hs := SetLike.coe_injective <| subset_lower_closure.antisymm hs

theorem upper_closure_anti : Antitone (upperClosure : Set α → UpperSet α) :=
  gc_upper_closure_coe.monotone_l

theorem lower_closure_mono : Monotone (lowerClosure : Set α → LowerSet α) :=
  gc_lower_closure_coe.monotone_l

@[simp]
theorem upper_closure_empty : upperClosure (∅ : Set α) = ⊤ := by
  ext
  simp

@[simp]
theorem lower_closure_empty : lowerClosure (∅ : Set α) = ⊥ := by
  ext
  simp

@[simp]
theorem upper_closure_singleton (a : α) : upperClosure ({a} : Set α) = UpperSet.ici a := by
  ext
  simp

@[simp]
theorem lower_closure_singleton (a : α) : lowerClosure ({a} : Set α) = LowerSet.iic a := by
  ext
  simp

@[simp]
theorem upper_closure_univ : upperClosure (Univ : Set α) = ⊥ :=
  le_bot_iff.1 subset_upper_closure

@[simp]
theorem lower_closure_univ : lowerClosure (Univ : Set α) = ⊤ :=
  top_le_iff.1 subset_lower_closure

@[simp]
theorem upper_closure_eq_top_iff : upperClosure s = ⊤ ↔ s = ∅ :=
  ⟨fun h => subset_empty_iff.1 <| subset_upper_closure.trans (congr_arg coe h).Subset, by
    rintro rfl
    exact upper_closure_empty⟩

@[simp]
theorem lower_closure_eq_bot_iff : lowerClosure s = ⊥ ↔ s = ∅ :=
  ⟨fun h => subset_empty_iff.1 <| subset_lower_closure.trans (congr_arg coe h).Subset, by
    rintro rfl
    exact lower_closure_empty⟩

@[simp]
theorem upper_closure_union (s t : Set α) : upperClosure (s ∪ t) = upperClosure s ⊓ upperClosure t := by
  ext
  simp [or_and_right, exists_or]

@[simp]
theorem lower_closure_union (s t : Set α) : lowerClosure (s ∪ t) = lowerClosure s ⊔ lowerClosure t := by
  ext
  simp [or_and_right, exists_or]

@[simp]
theorem upper_closure_Union (f : ι → Set α) : upperClosure (⋃ i, f i) = ⨅ i, upperClosure (f i) := by
  ext
  simp [← exists_and_right, @exists_comm α]

@[simp]
theorem lower_closure_Union (f : ι → Set α) : lowerClosure (⋃ i, f i) = ⨆ i, lowerClosure (f i) := by
  ext
  simp [← exists_and_right, @exists_comm α]

@[simp]
theorem upper_closure_sUnion (S : Set (Set α)) : upperClosure (⋃₀S) = ⨅ s ∈ S, upperClosure s := by
  simp_rw [sUnion_eq_bUnion, upper_closure_Union]

@[simp]
theorem lower_closure_sUnion (S : Set (Set α)) : lowerClosure (⋃₀S) = ⨆ s ∈ S, lowerClosure s := by
  simp_rw [sUnion_eq_bUnion, lower_closure_Union]

theorem Set.OrdConnected.upper_closure_inter_lower_closure (h : s.OrdConnected) :
    ↑(upperClosure s) ∩ ↑(lowerClosure s) = s :=
  (subset_inter subset_upper_closure subset_lower_closure).antisymm' fun a ⟨⟨b, hb, hba⟩, c, hc, hac⟩ =>
    h.out hb hc ⟨hba, hac⟩

theorem ord_connected_iff_upper_closure_inter_lower_closure :
    s.OrdConnected ↔ ↑(upperClosure s) ∩ ↑(lowerClosure s) = s := by
  refine' ⟨Set.OrdConnected.upper_closure_inter_lower_closure, fun h => _⟩
  rw [← h]
  exact (UpperSet.upper _).OrdConnected.inter (LowerSet.lower _).OrdConnected

end Closure

/-! ### Product -/


section Preorder

variable [Preorder α] [Preorder β] {s : Set α} {t : Set β} {x : α × β}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem IsUpperSet.prod (hs : IsUpperSet s) (ht : IsUpperSet t) : IsUpperSet (s ×ˢ t) := fun a b h ha =>
  ⟨hs h.1 ha.1, ht h.2 ha.2⟩

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
theorem IsLowerSet.prod (hs : IsLowerSet s) (ht : IsLowerSet t) : IsLowerSet (s ×ˢ t) := fun a b h ha =>
  ⟨hs h.1 ha.1, ht h.2 ha.2⟩

namespace UpperSet

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The product of two upper sets as an upper set. -/
def prod (s : UpperSet α) (t : UpperSet β) : UpperSet (α × β) :=
  ⟨s ×ˢ t, s.2.Prod t.2⟩

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem coe_prod (s : UpperSet α) (t : UpperSet β) : (s.Prod t : Set (α × β)) = s ×ˢ t :=
  rfl

@[simp]
theorem mem_prod {s : UpperSet α} {t : UpperSet β} : x ∈ s.Prod t ↔ x.1 ∈ s ∧ x.2 ∈ t :=
  Iff.rfl

theorem Ici_prod (x : α × β) : ici x = (ici x.1).Prod (ici x.2) :=
  rfl

@[simp]
theorem Ici_prod_Ici (a : α) (b : β) : (ici a).Prod (ici b) = ici (a, b) :=
  rfl

@[simp]
theorem bot_prod_bot : (⊥ : UpperSet α).Prod (⊥ : UpperSet β) = ⊥ :=
  ext univ_prod_univ

@[simp]
theorem prod_top (s : UpperSet α) : s.Prod (⊤ : UpperSet β) = ⊤ :=
  ext prod_empty

@[simp]
theorem top_prod (t : UpperSet β) : (⊤ : UpperSet α).Prod t = ⊤ :=
  ext empty_prod

end UpperSet

namespace LowerSet

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/-- The product of two lower sets as a lower set. -/
def prod (s : LowerSet α) (t : LowerSet β) : LowerSet (α × β) :=
  ⟨s ×ˢ t, s.2.Prod t.2⟩

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem coe_prod (s : LowerSet α) (t : LowerSet β) : (s.Prod t : Set (α × β)) = s ×ˢ t :=
  rfl

@[simp]
theorem mem_prod {s : LowerSet α} {t : LowerSet β} : x ∈ s.Prod t ↔ x.1 ∈ s ∧ x.2 ∈ t :=
  Iff.rfl

theorem Iic_prod (x : α × β) : iic x = (iic x.1).Prod (iic x.2) :=
  rfl

@[simp]
theorem Ici_prod_Ici (a : α) (b : β) : (iic a).Prod (iic b) = iic (a, b) :=
  rfl

@[simp]
theorem prod_bot (s : LowerSet α) : s.Prod (⊥ : LowerSet β) = ⊥ :=
  ext prod_empty

@[simp]
theorem bot_prod (t : LowerSet β) : (⊥ : LowerSet α).Prod t = ⊥ :=
  ext empty_prod

@[simp]
theorem top_prod_top : (⊤ : LowerSet α).Prod (⊤ : LowerSet β) = ⊤ :=
  ext univ_prod_univ

end LowerSet

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem upper_closure_prod (s : Set α) (t : Set β) : upperClosure (s ×ˢ t) = (upperClosure s).Prod (upperClosure t) :=
  by
  ext
  simp [Prod.le_def, and_and_and_comm _ (_ ∈ t)]

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem lower_closure_prod (s : Set α) (t : Set β) : lowerClosure (s ×ˢ t) = (lowerClosure s).Prod (lowerClosure t) :=
  by
  ext
  simp [Prod.le_def, and_and_and_comm _ (_ ∈ t)]

end Preorder

