/-
Copyright (c) 2020 Yury G. Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury G. Kudryashov

! This file was ported from Lean 3 source module data.set.intervals.ord_connected
! leanprover-community/mathlib commit 76de8ae01554c3b37d66544866659ff174e66e1f
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Intervals.UnorderedInterval
import Mathbin.Data.Set.Lattice
import Mathbin.Order.Antichain

/-!
# Order-connected sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We say that a set `s : set α` is `ord_connected` if for all `x y ∈ s` it includes the
interval `[x, y]`. If `α` is a `densely_ordered` `conditionally_complete_linear_order` with
the `order_topology`, then this condition is equivalent to `is_preconnected s`. If `α` is a
`linear_ordered_field`, then this condition is also equivalent to `convex α s`.

In this file we prove that intersection of a family of `ord_connected` sets is `ord_connected` and
that all standard intervals are `ord_connected`.
-/


open scoped Interval

open OrderDual (toDual ofDual)

namespace Set

section Preorder

variable {α β : Type _} [Preorder α] [Preorder β] {s t : Set α}

#print Set.OrdConnected /-
/-- We say that a set `s : set α` is `ord_connected` if for all `x y ∈ s` it includes the
interval `[x, y]`. If `α` is a `densely_ordered` `conditionally_complete_linear_order` with
the `order_topology`, then this condition is equivalent to `is_preconnected s`. If `α` is a
`linear_ordered_field`, then this condition is also equivalent to `convex α s`.
-/
class OrdConnected (s : Set α) : Prop where
  out' ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s) : Icc x y ⊆ s
#align set.ord_connected Set.OrdConnected
-/

#print Set.OrdConnected.out /-
theorem OrdConnected.out (h : OrdConnected s) : ∀ ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s), Icc x y ⊆ s :=
  h.1
#align set.ord_connected.out Set.OrdConnected.out
-/

#print Set.ordConnected_def /-
theorem ordConnected_def : OrdConnected s ↔ ∀ ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s), Icc x y ⊆ s :=
  ⟨fun h => h.1, fun h => ⟨h⟩⟩
#align set.ord_connected_def Set.ordConnected_def
-/

#print Set.ordConnected_iff /-
/-- It suffices to prove `[x, y] ⊆ s` for `x y ∈ s`, `x ≤ y`. -/
theorem ordConnected_iff : OrdConnected s ↔ ∀ x ∈ s, ∀ y ∈ s, x ≤ y → Icc x y ⊆ s :=
  ordConnected_def.trans
    ⟨fun hs x hx y hy hxy => hs hx hy, fun H x hx y hy z hz => H x hx y hy (le_trans hz.1 hz.2) hz⟩
#align set.ord_connected_iff Set.ordConnected_iff
-/

#print Set.ordConnected_of_Ioo /-
theorem ordConnected_of_Ioo {α : Type _} [PartialOrder α] {s : Set α}
    (hs : ∀ x ∈ s, ∀ y ∈ s, x < y → Ioo x y ⊆ s) : OrdConnected s :=
  by
  rw [ord_connected_iff]
  intro x hx y hy hxy
  rcases eq_or_lt_of_le hxy with (rfl | hxy'); · simpa
  rw [← Ioc_insert_left hxy, ← Ioo_insert_right hxy']
  exact insert_subset.2 ⟨hx, insert_subset.2 ⟨hy, hs x hx y hy hxy'⟩⟩
#align set.ord_connected_of_Ioo Set.ordConnected_of_Ioo
-/

#print Set.OrdConnected.preimage_mono /-
theorem OrdConnected.preimage_mono {f : β → α} (hs : OrdConnected s) (hf : Monotone f) :
    OrdConnected (f ⁻¹' s) :=
  ⟨fun x hx y hy z hz => hs.out hx hy ⟨hf hz.1, hf hz.2⟩⟩
#align set.ord_connected.preimage_mono Set.OrdConnected.preimage_mono
-/

#print Set.OrdConnected.preimage_anti /-
theorem OrdConnected.preimage_anti {f : β → α} (hs : OrdConnected s) (hf : Antitone f) :
    OrdConnected (f ⁻¹' s) :=
  ⟨fun x hx y hy z hz => hs.out hy hx ⟨hf hz.2, hf hz.1⟩⟩
#align set.ord_connected.preimage_anti Set.OrdConnected.preimage_anti
-/

#print Set.Icc_subset /-
protected theorem Icc_subset (s : Set α) [hs : OrdConnected s] {x y} (hx : x ∈ s) (hy : y ∈ s) :
    Icc x y ⊆ s :=
  hs.out hx hy
#align set.Icc_subset Set.Icc_subset
-/

#print Set.OrdConnected.inter /-
theorem OrdConnected.inter {s t : Set α} (hs : OrdConnected s) (ht : OrdConnected t) :
    OrdConnected (s ∩ t) :=
  ⟨fun x hx y hy => subset_inter (hs.out hx.1 hy.1) (ht.out hx.2 hy.2)⟩
#align set.ord_connected.inter Set.OrdConnected.inter
-/

#print Set.OrdConnected.inter' /-
instance OrdConnected.inter' {s t : Set α} [OrdConnected s] [OrdConnected t] :
    OrdConnected (s ∩ t) :=
  OrdConnected.inter ‹_› ‹_›
#align set.ord_connected.inter' Set.OrdConnected.inter'
-/

#print Set.OrdConnected.dual /-
theorem OrdConnected.dual {s : Set α} (hs : OrdConnected s) :
    OrdConnected (OrderDual.ofDual ⁻¹' s) :=
  ⟨fun x hx y hy z hz => hs.out hy hx ⟨hz.2, hz.1⟩⟩
#align set.ord_connected.dual Set.OrdConnected.dual
-/

#print Set.ordConnected_dual /-
theorem ordConnected_dual {s : Set α} : OrdConnected (OrderDual.ofDual ⁻¹' s) ↔ OrdConnected s :=
  ⟨fun h => by simpa only [ord_connected_def] using h.dual, fun h => h.dual⟩
#align set.ord_connected_dual Set.ordConnected_dual
-/

#print Set.ordConnected_sInter /-
theorem ordConnected_sInter {S : Set (Set α)} (hS : ∀ s ∈ S, OrdConnected s) :
    OrdConnected (⋂₀ S) :=
  ⟨fun x hx y hy => subset_sInter fun s hs => (hS s hs).out (hx s hs) (hy s hs)⟩
#align set.ord_connected_sInter Set.ordConnected_sInter
-/

#print Set.ordConnected_iInter /-
theorem ordConnected_iInter {ι : Sort _} {s : ι → Set α} (hs : ∀ i, OrdConnected (s i)) :
    OrdConnected (⋂ i, s i) :=
  ordConnected_sInter <| forall_range_iff.2 hs
#align set.ord_connected_Inter Set.ordConnected_iInter
-/

#print Set.ordConnected_iInter' /-
instance ordConnected_iInter' {ι : Sort _} {s : ι → Set α} [∀ i, OrdConnected (s i)] :
    OrdConnected (⋂ i, s i) :=
  ordConnected_iInter ‹_›
#align set.ord_connected_Inter' Set.ordConnected_iInter'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (i hi) -/
#print Set.ordConnected_biInter /-
theorem ordConnected_biInter {ι : Sort _} {p : ι → Prop} {s : ∀ (i : ι) (hi : p i), Set α}
    (hs : ∀ i hi, OrdConnected (s i hi)) : OrdConnected (⋂ (i) (hi), s i hi) :=
  ordConnected_iInter fun i => ordConnected_iInter <| hs i
#align set.ord_connected_bInter Set.ordConnected_biInter
-/

#print Set.ordConnected_pi /-
theorem ordConnected_pi {ι : Type _} {α : ι → Type _} [∀ i, Preorder (α i)] {s : Set ι}
    {t : ∀ i, Set (α i)} (h : ∀ i ∈ s, OrdConnected (t i)) : OrdConnected (s.pi t) :=
  ⟨fun x hx y hy z hz i hi => (h i hi).out (hx i hi) (hy i hi) ⟨hz.1 i, hz.2 i⟩⟩
#align set.ord_connected_pi Set.ordConnected_pi
-/

#print Set.ordConnected_pi' /-
instance ordConnected_pi' {ι : Type _} {α : ι → Type _} [∀ i, Preorder (α i)] {s : Set ι}
    {t : ∀ i, Set (α i)} [h : ∀ i, OrdConnected (t i)] : OrdConnected (s.pi t) :=
  ordConnected_pi fun i hi => h i
#align set.ord_connected_pi' Set.ordConnected_pi'
-/

#print Set.ordConnected_Ici /-
@[instance]
theorem ordConnected_Ici {a : α} : OrdConnected (Ici a) :=
  ⟨fun x hx y hy z hz => le_trans hx hz.1⟩
#align set.ord_connected_Ici Set.ordConnected_Ici
-/

#print Set.ordConnected_Iic /-
@[instance]
theorem ordConnected_Iic {a : α} : OrdConnected (Iic a) :=
  ⟨fun x hx y hy z hz => le_trans hz.2 hy⟩
#align set.ord_connected_Iic Set.ordConnected_Iic
-/

#print Set.ordConnected_Ioi /-
@[instance]
theorem ordConnected_Ioi {a : α} : OrdConnected (Ioi a) :=
  ⟨fun x hx y hy z hz => lt_of_lt_of_le hx hz.1⟩
#align set.ord_connected_Ioi Set.ordConnected_Ioi
-/

#print Set.ordConnected_Iio /-
@[instance]
theorem ordConnected_Iio {a : α} : OrdConnected (Iio a) :=
  ⟨fun x hx y hy z hz => lt_of_le_of_lt hz.2 hy⟩
#align set.ord_connected_Iio Set.ordConnected_Iio
-/

#print Set.ordConnected_Icc /-
@[instance]
theorem ordConnected_Icc {a b : α} : OrdConnected (Icc a b) :=
  ordConnected_Ici.inter ordConnected_Iic
#align set.ord_connected_Icc Set.ordConnected_Icc
-/

#print Set.ordConnected_Ico /-
@[instance]
theorem ordConnected_Ico {a b : α} : OrdConnected (Ico a b) :=
  ordConnected_Ici.inter ordConnected_Iio
#align set.ord_connected_Ico Set.ordConnected_Ico
-/

#print Set.ordConnected_Ioc /-
@[instance]
theorem ordConnected_Ioc {a b : α} : OrdConnected (Ioc a b) :=
  ordConnected_Ioi.inter ordConnected_Iic
#align set.ord_connected_Ioc Set.ordConnected_Ioc
-/

#print Set.ordConnected_Ioo /-
@[instance]
theorem ordConnected_Ioo {a b : α} : OrdConnected (Ioo a b) :=
  ordConnected_Ioi.inter ordConnected_Iio
#align set.ord_connected_Ioo Set.ordConnected_Ioo
-/

#print Set.ordConnected_singleton /-
@[instance]
theorem ordConnected_singleton {α : Type _} [PartialOrder α] {a : α} : OrdConnected ({a} : Set α) :=
  by rw [← Icc_self]; exact ord_connected_Icc
#align set.ord_connected_singleton Set.ordConnected_singleton
-/

#print Set.ordConnected_empty /-
@[instance]
theorem ordConnected_empty : OrdConnected (∅ : Set α) :=
  ⟨fun x => False.elim⟩
#align set.ord_connected_empty Set.ordConnected_empty
-/

#print Set.ordConnected_univ /-
@[instance]
theorem ordConnected_univ : OrdConnected (univ : Set α) :=
  ⟨fun _ _ _ _ => subset_univ _⟩
#align set.ord_connected_univ Set.ordConnected_univ
-/

/-- In a dense order `α`, the subtype from an `ord_connected` set is also densely ordered. -/
instance [DenselyOrdered α] {s : Set α} [hs : OrdConnected s] : DenselyOrdered s :=
  ⟨fun a b (h : (a : α) < b) =>
    let ⟨x, H⟩ := exists_between h
    ⟨⟨x, (hs.out a.2 b.2) (Ioo_subset_Icc_self H)⟩, H⟩⟩

#print Set.ordConnected_preimage /-
@[instance]
theorem ordConnected_preimage {F : Type _} [OrderHomClass F α β] (f : F) {s : Set β}
    [hs : OrdConnected s] : OrdConnected (f ⁻¹' s) :=
  ⟨fun x hx y hy z hz => hs.out hx hy ⟨OrderHomClass.mono _ hz.1, OrderHomClass.mono _ hz.2⟩⟩
#align set.ord_connected_preimage Set.ordConnected_preimage
-/

#print Set.ordConnected_image /-
@[instance]
theorem ordConnected_image {E : Type _} [OrderIsoClass E α β] (e : E) {s : Set α}
    [hs : OrdConnected s] : OrdConnected (e '' s) := by erw [(e : α ≃o β).image_eq_preimage];
  apply ord_connected_preimage
#align set.ord_connected_image Set.ordConnected_image
-/

#print Set.ordConnected_range /-
@[instance]
theorem ordConnected_range {E : Type _} [OrderIsoClass E α β] (e : E) : OrdConnected (range e) := by
  simp_rw [← image_univ, ord_connected_image e]
#align set.ord_connected_range Set.ordConnected_range
-/

#print Set.dual_ordConnected_iff /-
@[simp]
theorem dual_ordConnected_iff {s : Set α} : OrdConnected (ofDual ⁻¹' s) ↔ OrdConnected s :=
  by
  simp_rw [ord_connected_def, to_dual.surjective.forall, dual_Icc, Subtype.forall']
  exact forall_swap
#align set.dual_ord_connected_iff Set.dual_ordConnected_iff
-/

#print Set.dual_ordConnected /-
@[instance]
theorem dual_ordConnected {s : Set α} [OrdConnected s] : OrdConnected (ofDual ⁻¹' s) :=
  dual_ordConnected_iff.2 ‹_›
#align set.dual_ord_connected Set.dual_ordConnected
-/

end Preorder

section PartialOrder

variable {α : Type _} [PartialOrder α] {s : Set α}

#print IsAntichain.ordConnected /-
protected theorem IsAntichain.ordConnected (hs : IsAntichain (· ≤ ·) s) : s.OrdConnected :=
  ⟨fun x hx y hy z hz => by
    obtain rfl := hs.eq hx hy (hz.1.trans hz.2)
    rw [Icc_self, mem_singleton_iff] at hz ; rwa [hz]⟩
#align is_antichain.ord_connected IsAntichain.ordConnected
-/

end PartialOrder

section LinearOrder

variable {α : Type _} [LinearOrder α] {s : Set α} {x : α}

#print Set.ordConnected_uIcc /-
@[instance]
theorem ordConnected_uIcc {a b : α} : OrdConnected [a, b] :=
  ordConnected_Icc
#align set.ord_connected_uIcc Set.ordConnected_uIcc
-/

#print Set.ordConnected_uIoc /-
@[instance]
theorem ordConnected_uIoc {a b : α} : OrdConnected (Ι a b) :=
  ordConnected_Ioc
#align set.ord_connected_uIoc Set.ordConnected_uIoc
-/

#print Set.OrdConnected.uIcc_subset /-
theorem OrdConnected.uIcc_subset (hs : OrdConnected s) ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s) :
    [x, y] ⊆ s :=
  hs.out (min_rec' (· ∈ s) hx hy) (max_rec' (· ∈ s) hx hy)
#align set.ord_connected.uIcc_subset Set.OrdConnected.uIcc_subset
-/

#print Set.OrdConnected.uIoc_subset /-
theorem OrdConnected.uIoc_subset (hs : OrdConnected s) ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s) :
    Ι x y ⊆ s :=
  Ioc_subset_Icc_self.trans <| hs.uIcc_subset hx hy
#align set.ord_connected.uIoc_subset Set.OrdConnected.uIoc_subset
-/

#print Set.ordConnected_iff_uIcc_subset /-
theorem ordConnected_iff_uIcc_subset :
    OrdConnected s ↔ ∀ ⦃x⦄ (hx : x ∈ s) ⦃y⦄ (hy : y ∈ s), [x, y] ⊆ s :=
  ⟨fun h => h.uIcc_subset, fun H => ⟨fun x hx y hy => Icc_subset_uIcc.trans <| H hx hy⟩⟩
#align set.ord_connected_iff_uIcc_subset Set.ordConnected_iff_uIcc_subset
-/

#print Set.ordConnected_of_uIcc_subset_left /-
theorem ordConnected_of_uIcc_subset_left (h : ∀ y ∈ s, [x, y] ⊆ s) : OrdConnected s :=
  ordConnected_iff_uIcc_subset.2 fun y hy z hz =>
    calc
      [y, z] ⊆ [y, x] ∪ [x, z] := uIcc_subset_uIcc_union_uIcc
      _ = [x, y] ∪ [x, z] := by rw [uIcc_comm]
      _ ⊆ s := union_subset (h y hy) (h z hz)
#align set.ord_connected_of_uIcc_subset_left Set.ordConnected_of_uIcc_subset_left
-/

#print Set.ordConnected_iff_uIcc_subset_left /-
theorem ordConnected_iff_uIcc_subset_left (hx : x ∈ s) :
    OrdConnected s ↔ ∀ ⦃y⦄, y ∈ s → [x, y] ⊆ s :=
  ⟨fun hs => hs.uIcc_subset hx, ordConnected_of_uIcc_subset_left⟩
#align set.ord_connected_iff_uIcc_subset_left Set.ordConnected_iff_uIcc_subset_left
-/

#print Set.ordConnected_iff_uIcc_subset_right /-
theorem ordConnected_iff_uIcc_subset_right (hx : x ∈ s) :
    OrdConnected s ↔ ∀ ⦃y⦄, y ∈ s → [y, x] ⊆ s := by
  simp_rw [ord_connected_iff_uIcc_subset_left hx, uIcc_comm]
#align set.ord_connected_iff_uIcc_subset_right Set.ordConnected_iff_uIcc_subset_right
-/

end LinearOrder

end Set

