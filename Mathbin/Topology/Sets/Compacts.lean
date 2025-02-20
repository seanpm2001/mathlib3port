/-
Copyright (c) 2020 Floris van Doorn. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Floris van Doorn, Yaël Dillies

! This file was ported from Lean 3 source module topology.sets.compacts
! leanprover-community/mathlib commit 8c1b484d6a214e059531e22f1be9898ed6c1fd47
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Topology.Sets.Closeds
import Mathbin.Topology.QuasiSeparated

/-!
# Compact sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define a few types of compact sets in a topological space.

## Main Definitions

For a topological space `α`,
* `compacts α`: The type of compact sets.
* `nonempty_compacts α`: The type of non-empty compact sets.
* `positive_compacts α`: The type of compact sets with non-empty interior.
* `compact_opens α`: The type of compact open sets. This is a central object in the study of
  spectral spaces.
-/


open Set

variable {α β γ : Type _} [TopologicalSpace α] [TopologicalSpace β] [TopologicalSpace γ]

namespace TopologicalSpace

/-! ### Compact sets -/


#print TopologicalSpace.Compacts /-
/-- The type of compact sets of a topological space. -/
structure Compacts (α : Type _) [TopologicalSpace α] where
  carrier : Set α
  is_compact' : IsCompact carrier
#align topological_space.compacts TopologicalSpace.Compacts
-/

namespace Compacts

variable {α}

instance : SetLike (Compacts α) α where
  coe := Compacts.carrier
  coe_injective' s t h := by cases s; cases t; congr

#print TopologicalSpace.Compacts.isCompact /-
protected theorem isCompact (s : Compacts α) : IsCompact (s : Set α) :=
  s.is_compact'
#align topological_space.compacts.is_compact TopologicalSpace.Compacts.isCompact
-/

instance (K : Compacts α) : CompactSpace K :=
  isCompact_iff_compactSpace.1 K.IsCompact

instance : CanLift (Set α) (Compacts α) coe IsCompact where prf K hK := ⟨⟨K, hK⟩, rfl⟩

#print TopologicalSpace.Compacts.ext /-
@[ext]
protected theorem ext {s t : Compacts α} (h : (s : Set α) = t) : s = t :=
  SetLike.ext' h
#align topological_space.compacts.ext TopologicalSpace.Compacts.ext
-/

#print TopologicalSpace.Compacts.coe_mk /-
@[simp]
theorem coe_mk (s : Set α) (h) : (mk s h : Set α) = s :=
  rfl
#align topological_space.compacts.coe_mk TopologicalSpace.Compacts.coe_mk
-/

#print TopologicalSpace.Compacts.carrier_eq_coe /-
@[simp]
theorem carrier_eq_coe (s : Compacts α) : s.carrier = s :=
  rfl
#align topological_space.compacts.carrier_eq_coe TopologicalSpace.Compacts.carrier_eq_coe
-/

instance : Sup (Compacts α) :=
  ⟨fun s t => ⟨s ∪ t, s.IsCompact.union t.IsCompact⟩⟩

instance [T2Space α] : Inf (Compacts α) :=
  ⟨fun s t => ⟨s ∩ t, s.IsCompact.inter t.IsCompact⟩⟩

instance [CompactSpace α] : Top (Compacts α) :=
  ⟨⟨univ, isCompact_univ⟩⟩

instance : Bot (Compacts α) :=
  ⟨⟨∅, isCompact_empty⟩⟩

instance : SemilatticeSup (Compacts α) :=
  SetLike.coe_injective.SemilatticeSup _ fun _ _ => rfl

instance [T2Space α] : DistribLattice (Compacts α) :=
  SetLike.coe_injective.DistribLattice _ (fun _ _ => rfl) fun _ _ => rfl

instance : OrderBot (Compacts α) :=
  OrderBot.lift (coe : _ → Set α) (fun _ _ => id) rfl

instance [CompactSpace α] : BoundedOrder (Compacts α) :=
  BoundedOrder.lift (coe : _ → Set α) (fun _ _ => id) rfl rfl

/-- The type of compact sets is inhabited, with default element the empty set. -/
instance : Inhabited (Compacts α) :=
  ⟨⊥⟩

#print TopologicalSpace.Compacts.coe_sup /-
@[simp]
theorem coe_sup (s t : Compacts α) : (↑(s ⊔ t) : Set α) = s ∪ t :=
  rfl
#align topological_space.compacts.coe_sup TopologicalSpace.Compacts.coe_sup
-/

#print TopologicalSpace.Compacts.coe_inf /-
@[simp]
theorem coe_inf [T2Space α] (s t : Compacts α) : (↑(s ⊓ t) : Set α) = s ∩ t :=
  rfl
#align topological_space.compacts.coe_inf TopologicalSpace.Compacts.coe_inf
-/

#print TopologicalSpace.Compacts.coe_top /-
@[simp]
theorem coe_top [CompactSpace α] : (↑(⊤ : Compacts α) : Set α) = univ :=
  rfl
#align topological_space.compacts.coe_top TopologicalSpace.Compacts.coe_top
-/

#print TopologicalSpace.Compacts.coe_bot /-
@[simp]
theorem coe_bot : (↑(⊥ : Compacts α) : Set α) = ∅ :=
  rfl
#align topological_space.compacts.coe_bot TopologicalSpace.Compacts.coe_bot
-/

#print TopologicalSpace.Compacts.coe_finset_sup /-
@[simp]
theorem coe_finset_sup {ι : Type _} {s : Finset ι} {f : ι → Compacts α} :
    (↑(s.sup f) : Set α) = s.sup fun i => f i := by
  classical
  refine' Finset.induction_on s rfl fun a s _ h => _
  simp_rw [Finset.sup_insert, coe_sup, sup_eq_union]
  congr
#align topological_space.compacts.coe_finset_sup TopologicalSpace.Compacts.coe_finset_sup
-/

#print TopologicalSpace.Compacts.map /-
/-- The image of a compact set under a continuous function. -/
protected def map (f : α → β) (hf : Continuous f) (K : Compacts α) : Compacts β :=
  ⟨f '' K.1, K.2.image hf⟩
#align topological_space.compacts.map TopologicalSpace.Compacts.map
-/

#print TopologicalSpace.Compacts.coe_map /-
@[simp, norm_cast]
theorem coe_map {f : α → β} (hf : Continuous f) (s : Compacts α) : (s.map f hf : Set β) = f '' s :=
  rfl
#align topological_space.compacts.coe_map TopologicalSpace.Compacts.coe_map
-/

#print TopologicalSpace.Compacts.map_id /-
@[simp]
theorem map_id (K : Compacts α) : K.map id continuous_id = K :=
  Compacts.ext <| Set.image_id _
#align topological_space.compacts.map_id TopologicalSpace.Compacts.map_id
-/

#print TopologicalSpace.Compacts.map_comp /-
theorem map_comp (f : β → γ) (g : α → β) (hf : Continuous f) (hg : Continuous g) (K : Compacts α) :
    K.map (f ∘ g) (hf.comp hg) = (K.map g hg).map f hf :=
  Compacts.ext <| Set.image_comp _ _ _
#align topological_space.compacts.map_comp TopologicalSpace.Compacts.map_comp
-/

#print TopologicalSpace.Compacts.equiv /-
/-- A homeomorphism induces an equivalence on compact sets, by taking the image. -/
@[simps]
protected def equiv (f : α ≃ₜ β) : Compacts α ≃ Compacts β
    where
  toFun := Compacts.map f f.Continuous
  invFun := Compacts.map _ f.symm.Continuous
  left_inv s := by ext1; simp only [coe_map, ← image_comp, f.symm_comp_self, image_id]
  right_inv s := by ext1; simp only [coe_map, ← image_comp, f.self_comp_symm, image_id]
#align topological_space.compacts.equiv TopologicalSpace.Compacts.equiv
-/

#print TopologicalSpace.Compacts.equiv_refl /-
@[simp]
theorem equiv_refl : Compacts.equiv (Homeomorph.refl α) = Equiv.refl _ :=
  Equiv.ext map_id
#align topological_space.compacts.equiv_refl TopologicalSpace.Compacts.equiv_refl
-/

#print TopologicalSpace.Compacts.equiv_trans /-
@[simp]
theorem equiv_trans (f : α ≃ₜ β) (g : β ≃ₜ γ) :
    Compacts.equiv (f.trans g) = (Compacts.equiv f).trans (Compacts.equiv g) :=
  Equiv.ext <| map_comp _ _ _ _
#align topological_space.compacts.equiv_trans TopologicalSpace.Compacts.equiv_trans
-/

#print TopologicalSpace.Compacts.equiv_symm /-
@[simp]
theorem equiv_symm (f : α ≃ₜ β) : Compacts.equiv f.symm = (Compacts.equiv f).symm :=
  rfl
#align topological_space.compacts.equiv_symm TopologicalSpace.Compacts.equiv_symm
-/

#print TopologicalSpace.Compacts.coe_equiv_apply_eq_preimage /-
/-- The image of a compact set under a homeomorphism can also be expressed as a preimage. -/
theorem coe_equiv_apply_eq_preimage (f : α ≃ₜ β) (K : Compacts α) :
    (Compacts.equiv f K : Set β) = f.symm ⁻¹' (K : Set α) :=
  f.toEquiv.image_eq_preimage K
#align topological_space.compacts.coe_equiv_apply_eq_preimage TopologicalSpace.Compacts.coe_equiv_apply_eq_preimage
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print TopologicalSpace.Compacts.prod /-
/-- The product of two `compacts`, as a `compacts` in the product space. -/
protected def prod (K : Compacts α) (L : Compacts β) : Compacts (α × β)
    where
  carrier := K ×ˢ L
  is_compact' := IsCompact.prod K.2 L.2
#align topological_space.compacts.prod TopologicalSpace.Compacts.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print TopologicalSpace.Compacts.coe_prod /-
@[simp]
theorem coe_prod (K : Compacts α) (L : Compacts β) : (K.Prod L : Set (α × β)) = K ×ˢ L :=
  rfl
#align topological_space.compacts.coe_prod TopologicalSpace.Compacts.coe_prod
-/

end Compacts

/-! ### Nonempty compact sets -/


#print TopologicalSpace.NonemptyCompacts /-
/-- The type of nonempty compact sets of a topological space. -/
structure NonemptyCompacts (α : Type _) [TopologicalSpace α] extends Compacts α where
  nonempty' : carrier.Nonempty
#align topological_space.nonempty_compacts TopologicalSpace.NonemptyCompacts
-/

namespace NonemptyCompacts

instance : SetLike (NonemptyCompacts α) α
    where
  coe s := s.carrier
  coe_injective' s t h := by obtain ⟨⟨_, _⟩, _⟩ := s; obtain ⟨⟨_, _⟩, _⟩ := t; congr

#print TopologicalSpace.NonemptyCompacts.isCompact /-
protected theorem isCompact (s : NonemptyCompacts α) : IsCompact (s : Set α) :=
  s.is_compact'
#align topological_space.nonempty_compacts.is_compact TopologicalSpace.NonemptyCompacts.isCompact
-/

#print TopologicalSpace.NonemptyCompacts.nonempty /-
protected theorem nonempty (s : NonemptyCompacts α) : (s : Set α).Nonempty :=
  s.nonempty'
#align topological_space.nonempty_compacts.nonempty TopologicalSpace.NonemptyCompacts.nonempty
-/

#print TopologicalSpace.NonemptyCompacts.toCloseds /-
/-- Reinterpret a nonempty compact as a closed set. -/
def toCloseds [T2Space α] (s : NonemptyCompacts α) : Closeds α :=
  ⟨s, s.IsCompact.IsClosed⟩
#align topological_space.nonempty_compacts.to_closeds TopologicalSpace.NonemptyCompacts.toCloseds
-/

#print TopologicalSpace.NonemptyCompacts.ext /-
@[ext]
protected theorem ext {s t : NonemptyCompacts α} (h : (s : Set α) = t) : s = t :=
  SetLike.ext' h
#align topological_space.nonempty_compacts.ext TopologicalSpace.NonemptyCompacts.ext
-/

#print TopologicalSpace.NonemptyCompacts.coe_mk /-
@[simp]
theorem coe_mk (s : Compacts α) (h) : (mk s h : Set α) = s :=
  rfl
#align topological_space.nonempty_compacts.coe_mk TopologicalSpace.NonemptyCompacts.coe_mk
-/

#print TopologicalSpace.NonemptyCompacts.carrier_eq_coe /-
@[simp]
theorem carrier_eq_coe (s : NonemptyCompacts α) : s.carrier = s :=
  rfl
#align topological_space.nonempty_compacts.carrier_eq_coe TopologicalSpace.NonemptyCompacts.carrier_eq_coe
-/

instance : Sup (NonemptyCompacts α) :=
  ⟨fun s t => ⟨s.toCompacts ⊔ t.toCompacts, s.Nonempty.mono <| subset_union_left _ _⟩⟩

instance [CompactSpace α] [Nonempty α] : Top (NonemptyCompacts α) :=
  ⟨⟨⊤, univ_nonempty⟩⟩

instance : SemilatticeSup (NonemptyCompacts α) :=
  SetLike.coe_injective.SemilatticeSup _ fun _ _ => rfl

instance [CompactSpace α] [Nonempty α] : OrderTop (NonemptyCompacts α) :=
  OrderTop.lift (coe : _ → Set α) (fun _ _ => id) rfl

#print TopologicalSpace.NonemptyCompacts.coe_sup /-
@[simp]
theorem coe_sup (s t : NonemptyCompacts α) : (↑(s ⊔ t) : Set α) = s ∪ t :=
  rfl
#align topological_space.nonempty_compacts.coe_sup TopologicalSpace.NonemptyCompacts.coe_sup
-/

#print TopologicalSpace.NonemptyCompacts.coe_top /-
@[simp]
theorem coe_top [CompactSpace α] [Nonempty α] : (↑(⊤ : NonemptyCompacts α) : Set α) = univ :=
  rfl
#align topological_space.nonempty_compacts.coe_top TopologicalSpace.NonemptyCompacts.coe_top
-/

/-- In an inhabited space, the type of nonempty compact subsets is also inhabited, with
default element the singleton set containing the default element. -/
instance [Inhabited α] : Inhabited (NonemptyCompacts α) :=
  ⟨{  carrier := {default}
      is_compact' := isCompact_singleton
      nonempty' := singleton_nonempty _ }⟩

#print TopologicalSpace.NonemptyCompacts.toCompactSpace /-
instance toCompactSpace {s : NonemptyCompacts α} : CompactSpace s :=
  isCompact_iff_compactSpace.1 s.IsCompact
#align topological_space.nonempty_compacts.to_compact_space TopologicalSpace.NonemptyCompacts.toCompactSpace
-/

#print TopologicalSpace.NonemptyCompacts.toNonempty /-
instance toNonempty {s : NonemptyCompacts α} : Nonempty s :=
  s.Nonempty.to_subtype
#align topological_space.nonempty_compacts.to_nonempty TopologicalSpace.NonemptyCompacts.toNonempty
-/

#print TopologicalSpace.NonemptyCompacts.prod /-
/-- The product of two `nonempty_compacts`, as a `nonempty_compacts` in the product space. -/
protected def prod (K : NonemptyCompacts α) (L : NonemptyCompacts β) : NonemptyCompacts (α × β) :=
  { K.toCompacts.Prod L.toCompacts with nonempty' := K.Nonempty.Prod L.Nonempty }
#align topological_space.nonempty_compacts.prod TopologicalSpace.NonemptyCompacts.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print TopologicalSpace.NonemptyCompacts.coe_prod /-
@[simp]
theorem coe_prod (K : NonemptyCompacts α) (L : NonemptyCompacts β) :
    (K.Prod L : Set (α × β)) = K ×ˢ L :=
  rfl
#align topological_space.nonempty_compacts.coe_prod TopologicalSpace.NonemptyCompacts.coe_prod
-/

end NonemptyCompacts

/-! ### Positive compact sets -/


#print TopologicalSpace.PositiveCompacts /-
/-- The type of compact sets with nonempty interior of a topological space.
See also `compacts` and `nonempty_compacts`. -/
structure PositiveCompacts (α : Type _) [TopologicalSpace α] extends Compacts α where
  interior_nonempty' : (interior carrier).Nonempty
#align topological_space.positive_compacts TopologicalSpace.PositiveCompacts
-/

namespace PositiveCompacts

instance : SetLike (PositiveCompacts α) α
    where
  coe s := s.carrier
  coe_injective' s t h := by obtain ⟨⟨_, _⟩, _⟩ := s; obtain ⟨⟨_, _⟩, _⟩ := t; congr

#print TopologicalSpace.PositiveCompacts.isCompact /-
protected theorem isCompact (s : PositiveCompacts α) : IsCompact (s : Set α) :=
  s.is_compact'
#align topological_space.positive_compacts.is_compact TopologicalSpace.PositiveCompacts.isCompact
-/

#print TopologicalSpace.PositiveCompacts.interior_nonempty /-
theorem interior_nonempty (s : PositiveCompacts α) : (interior (s : Set α)).Nonempty :=
  s.interior_nonempty'
#align topological_space.positive_compacts.interior_nonempty TopologicalSpace.PositiveCompacts.interior_nonempty
-/

#print TopologicalSpace.PositiveCompacts.nonempty /-
protected theorem nonempty (s : PositiveCompacts α) : (s : Set α).Nonempty :=
  s.interior_nonempty.mono interior_subset
#align topological_space.positive_compacts.nonempty TopologicalSpace.PositiveCompacts.nonempty
-/

#print TopologicalSpace.PositiveCompacts.toNonemptyCompacts /-
/-- Reinterpret a positive compact as a nonempty compact. -/
def toNonemptyCompacts (s : PositiveCompacts α) : NonemptyCompacts α :=
  ⟨s.toCompacts, s.Nonempty⟩
#align topological_space.positive_compacts.to_nonempty_compacts TopologicalSpace.PositiveCompacts.toNonemptyCompacts
-/

#print TopologicalSpace.PositiveCompacts.ext /-
@[ext]
protected theorem ext {s t : PositiveCompacts α} (h : (s : Set α) = t) : s = t :=
  SetLike.ext' h
#align topological_space.positive_compacts.ext TopologicalSpace.PositiveCompacts.ext
-/

#print TopologicalSpace.PositiveCompacts.coe_mk /-
@[simp]
theorem coe_mk (s : Compacts α) (h) : (mk s h : Set α) = s :=
  rfl
#align topological_space.positive_compacts.coe_mk TopologicalSpace.PositiveCompacts.coe_mk
-/

#print TopologicalSpace.PositiveCompacts.carrier_eq_coe /-
@[simp]
theorem carrier_eq_coe (s : PositiveCompacts α) : s.carrier = s :=
  rfl
#align topological_space.positive_compacts.carrier_eq_coe TopologicalSpace.PositiveCompacts.carrier_eq_coe
-/

instance : Sup (PositiveCompacts α) :=
  ⟨fun s t =>
    ⟨s.toCompacts ⊔ t.toCompacts,
      s.interior_nonempty.mono <| interior_mono <| subset_union_left _ _⟩⟩

instance [CompactSpace α] [Nonempty α] : Top (PositiveCompacts α) :=
  ⟨⟨⊤, interior_univ.symm.subst univ_nonempty⟩⟩

instance : SemilatticeSup (PositiveCompacts α) :=
  SetLike.coe_injective.SemilatticeSup _ fun _ _ => rfl

instance [CompactSpace α] [Nonempty α] : OrderTop (PositiveCompacts α) :=
  OrderTop.lift (coe : _ → Set α) (fun _ _ => id) rfl

#print TopologicalSpace.PositiveCompacts.coe_sup /-
@[simp]
theorem coe_sup (s t : PositiveCompacts α) : (↑(s ⊔ t) : Set α) = s ∪ t :=
  rfl
#align topological_space.positive_compacts.coe_sup TopologicalSpace.PositiveCompacts.coe_sup
-/

#print TopologicalSpace.PositiveCompacts.coe_top /-
@[simp]
theorem coe_top [CompactSpace α] [Nonempty α] : (↑(⊤ : PositiveCompacts α) : Set α) = univ :=
  rfl
#align topological_space.positive_compacts.coe_top TopologicalSpace.PositiveCompacts.coe_top
-/

#print TopologicalSpace.PositiveCompacts.map /-
/-- The image of a positive compact set under a continuous open map. -/
protected def map (f : α → β) (hf : Continuous f) (hf' : IsOpenMap f) (K : PositiveCompacts α) :
    PositiveCompacts β :=
  { K.map f hf with
    interior_nonempty' :=
      (K.interior_nonempty'.image _).mono (hf'.image_interior_subset K.toCompacts) }
#align topological_space.positive_compacts.map TopologicalSpace.PositiveCompacts.map
-/

#print TopologicalSpace.PositiveCompacts.coe_map /-
@[simp, norm_cast]
theorem coe_map {f : α → β} (hf : Continuous f) (hf' : IsOpenMap f) (s : PositiveCompacts α) :
    (s.map f hf hf' : Set β) = f '' s :=
  rfl
#align topological_space.positive_compacts.coe_map TopologicalSpace.PositiveCompacts.coe_map
-/

#print TopologicalSpace.PositiveCompacts.map_id /-
@[simp]
theorem map_id (K : PositiveCompacts α) : K.map id continuous_id IsOpenMap.id = K :=
  PositiveCompacts.ext <| Set.image_id _
#align topological_space.positive_compacts.map_id TopologicalSpace.PositiveCompacts.map_id
-/

#print TopologicalSpace.PositiveCompacts.map_comp /-
theorem map_comp (f : β → γ) (g : α → β) (hf : Continuous f) (hg : Continuous g) (hf' : IsOpenMap f)
    (hg' : IsOpenMap g) (K : PositiveCompacts α) :
    K.map (f ∘ g) (hf.comp hg) (hf'.comp hg') = (K.map g hg hg').map f hf hf' :=
  PositiveCompacts.ext <| Set.image_comp _ _ _
#align topological_space.positive_compacts.map_comp TopologicalSpace.PositiveCompacts.map_comp
-/

#print exists_positiveCompacts_subset /-
theorem exists_positiveCompacts_subset [LocallyCompactSpace α] {U : Set α} (ho : IsOpen U)
    (hn : U.Nonempty) : ∃ K : PositiveCompacts α, ↑K ⊆ U :=
  let ⟨x, hx⟩ := hn
  let ⟨K, hKc, hxK, hKU⟩ := exists_compact_subset ho hx
  ⟨⟨⟨K, hKc⟩, ⟨x, hxK⟩⟩, hKU⟩
#align exists_positive_compacts_subset exists_positiveCompacts_subset
-/

instance [CompactSpace α] [Nonempty α] : Inhabited (PositiveCompacts α) :=
  ⟨⊤⟩

#print TopologicalSpace.PositiveCompacts.nonempty' /-
/-- In a nonempty locally compact space, there exists a compact set with nonempty interior. -/
instance nonempty' [LocallyCompactSpace α] [Nonempty α] : Nonempty (PositiveCompacts α) :=
  nonempty_of_exists <| exists_positiveCompacts_subset isOpen_univ univ_nonempty
#align topological_space.positive_compacts.nonempty' TopologicalSpace.PositiveCompacts.nonempty'
-/

#print TopologicalSpace.PositiveCompacts.prod /-
/-- The product of two `positive_compacts`, as a `positive_compacts` in the product space. -/
protected def prod (K : PositiveCompacts α) (L : PositiveCompacts β) : PositiveCompacts (α × β) :=
  { K.toCompacts.Prod L.toCompacts with
    interior_nonempty' :=
      by
      simp only [compacts.carrier_eq_coe, compacts.coe_prod, interior_prod_eq]
      exact K.interior_nonempty.prod L.interior_nonempty }
#align topological_space.positive_compacts.prod TopologicalSpace.PositiveCompacts.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print TopologicalSpace.PositiveCompacts.coe_prod /-
@[simp]
theorem coe_prod (K : PositiveCompacts α) (L : PositiveCompacts β) :
    (K.Prod L : Set (α × β)) = K ×ˢ L :=
  rfl
#align topological_space.positive_compacts.coe_prod TopologicalSpace.PositiveCompacts.coe_prod
-/

end PositiveCompacts

/-! ### Compact open sets -/


#print TopologicalSpace.CompactOpens /-
/-- The type of compact open sets of a topological space. This is useful in non Hausdorff contexts,
in particular spectral spaces. -/
structure CompactOpens (α : Type _) [TopologicalSpace α] extends Compacts α where
  is_open' : IsOpen carrier
#align topological_space.compact_opens TopologicalSpace.CompactOpens
-/

namespace CompactOpens

instance : SetLike (CompactOpens α) α
    where
  coe s := s.carrier
  coe_injective' s t h := by obtain ⟨⟨_, _⟩, _⟩ := s; obtain ⟨⟨_, _⟩, _⟩ := t; congr

#print TopologicalSpace.CompactOpens.isCompact /-
protected theorem isCompact (s : CompactOpens α) : IsCompact (s : Set α) :=
  s.is_compact'
#align topological_space.compact_opens.is_compact TopologicalSpace.CompactOpens.isCompact
-/

#print TopologicalSpace.CompactOpens.isOpen /-
protected theorem isOpen (s : CompactOpens α) : IsOpen (s : Set α) :=
  s.is_open'
#align topological_space.compact_opens.is_open TopologicalSpace.CompactOpens.isOpen
-/

#print TopologicalSpace.CompactOpens.toOpens /-
/-- Reinterpret a compact open as an open. -/
@[simps]
def toOpens (s : CompactOpens α) : Opens α :=
  ⟨s, s.IsOpen⟩
#align topological_space.compact_opens.to_opens TopologicalSpace.CompactOpens.toOpens
-/

#print TopologicalSpace.CompactOpens.toClopens /-
/-- Reinterpret a compact open as a clopen. -/
@[simps]
def toClopens [T2Space α] (s : CompactOpens α) : Clopens α :=
  ⟨s, s.IsOpen, s.IsCompact.IsClosed⟩
#align topological_space.compact_opens.to_clopens TopologicalSpace.CompactOpens.toClopens
-/

#print TopologicalSpace.CompactOpens.ext /-
@[ext]
protected theorem ext {s t : CompactOpens α} (h : (s : Set α) = t) : s = t :=
  SetLike.ext' h
#align topological_space.compact_opens.ext TopologicalSpace.CompactOpens.ext
-/

#print TopologicalSpace.CompactOpens.coe_mk /-
@[simp]
theorem coe_mk (s : Compacts α) (h) : (mk s h : Set α) = s :=
  rfl
#align topological_space.compact_opens.coe_mk TopologicalSpace.CompactOpens.coe_mk
-/

instance : Sup (CompactOpens α) :=
  ⟨fun s t => ⟨s.toCompacts ⊔ t.toCompacts, s.IsOpen.union t.IsOpen⟩⟩

instance [QuasiSeparatedSpace α] : Inf (CompactOpens α) :=
  ⟨fun U V =>
    ⟨⟨(U : Set α) ∩ (V : Set α),
        QuasiSeparatedSpace.inter_isCompact U.1.1 V.1.1 U.2 U.1.2 V.2 V.1.2⟩,
      U.2.inter V.2⟩⟩

instance [QuasiSeparatedSpace α] : SemilatticeInf (CompactOpens α) :=
  SetLike.coe_injective.SemilatticeInf _ fun _ _ => rfl

instance [CompactSpace α] : Top (CompactOpens α) :=
  ⟨⟨⊤, isOpen_univ⟩⟩

instance : Bot (CompactOpens α) :=
  ⟨⟨⊥, isOpen_empty⟩⟩

instance [T2Space α] : SDiff (CompactOpens α) :=
  ⟨fun s t => ⟨⟨s \ t, s.IsCompact.diffₓ t.IsOpen⟩, s.IsOpen.sdiff t.IsCompact.IsClosed⟩⟩

instance [T2Space α] [CompactSpace α] : HasCompl (CompactOpens α) :=
  ⟨fun s => ⟨⟨sᶜ, s.IsOpen.isClosed_compl.IsCompact⟩, s.IsCompact.IsClosed.isOpen_compl⟩⟩

instance : SemilatticeSup (CompactOpens α) :=
  SetLike.coe_injective.SemilatticeSup _ fun _ _ => rfl

instance : OrderBot (CompactOpens α) :=
  OrderBot.lift (coe : _ → Set α) (fun _ _ => id) rfl

instance [T2Space α] : GeneralizedBooleanAlgebra (CompactOpens α) :=
  SetLike.coe_injective.GeneralizedBooleanAlgebra _ (fun _ _ => rfl) (fun _ _ => rfl) rfl fun _ _ =>
    rfl

instance [CompactSpace α] : BoundedOrder (CompactOpens α) :=
  BoundedOrder.lift (coe : _ → Set α) (fun _ _ => id) rfl rfl

instance [T2Space α] [CompactSpace α] : BooleanAlgebra (CompactOpens α) :=
  SetLike.coe_injective.BooleanAlgebra _ (fun _ _ => rfl) (fun _ _ => rfl) rfl rfl (fun _ => rfl)
    fun _ _ => rfl

#print TopologicalSpace.CompactOpens.coe_sup /-
@[simp]
theorem coe_sup (s t : CompactOpens α) : (↑(s ⊔ t) : Set α) = s ∪ t :=
  rfl
#align topological_space.compact_opens.coe_sup TopologicalSpace.CompactOpens.coe_sup
-/

#print TopologicalSpace.CompactOpens.coe_inf /-
@[simp]
theorem coe_inf [T2Space α] (s t : CompactOpens α) : (↑(s ⊓ t) : Set α) = s ∩ t :=
  rfl
#align topological_space.compact_opens.coe_inf TopologicalSpace.CompactOpens.coe_inf
-/

#print TopologicalSpace.CompactOpens.coe_top /-
@[simp]
theorem coe_top [CompactSpace α] : (↑(⊤ : CompactOpens α) : Set α) = univ :=
  rfl
#align topological_space.compact_opens.coe_top TopologicalSpace.CompactOpens.coe_top
-/

#print TopologicalSpace.CompactOpens.coe_bot /-
@[simp]
theorem coe_bot : (↑(⊥ : CompactOpens α) : Set α) = ∅ :=
  rfl
#align topological_space.compact_opens.coe_bot TopologicalSpace.CompactOpens.coe_bot
-/

#print TopologicalSpace.CompactOpens.coe_sdiff /-
@[simp]
theorem coe_sdiff [T2Space α] (s t : CompactOpens α) : (↑(s \ t) : Set α) = s \ t :=
  rfl
#align topological_space.compact_opens.coe_sdiff TopologicalSpace.CompactOpens.coe_sdiff
-/

#print TopologicalSpace.CompactOpens.coe_compl /-
@[simp]
theorem coe_compl [T2Space α] [CompactSpace α] (s : CompactOpens α) : (↑(sᶜ) : Set α) = sᶜ :=
  rfl
#align topological_space.compact_opens.coe_compl TopologicalSpace.CompactOpens.coe_compl
-/

instance : Inhabited (CompactOpens α) :=
  ⟨⊥⟩

#print TopologicalSpace.CompactOpens.map /-
/-- The image of a compact open under a continuous open map. -/
@[simps]
def map (f : α → β) (hf : Continuous f) (hf' : IsOpenMap f) (s : CompactOpens α) : CompactOpens β :=
  ⟨s.toCompacts.map f hf, hf' _ s.IsOpen⟩
#align topological_space.compact_opens.map TopologicalSpace.CompactOpens.map
-/

#print TopologicalSpace.CompactOpens.coe_map /-
@[simp, norm_cast]
theorem coe_map {f : α → β} (hf : Continuous f) (hf' : IsOpenMap f) (s : CompactOpens α) :
    (s.map f hf hf' : Set β) = f '' s :=
  rfl
#align topological_space.compact_opens.coe_map TopologicalSpace.CompactOpens.coe_map
-/

#print TopologicalSpace.CompactOpens.map_id /-
@[simp]
theorem map_id (K : CompactOpens α) : K.map id continuous_id IsOpenMap.id = K :=
  CompactOpens.ext <| Set.image_id _
#align topological_space.compact_opens.map_id TopologicalSpace.CompactOpens.map_id
-/

#print TopologicalSpace.CompactOpens.map_comp /-
theorem map_comp (f : β → γ) (g : α → β) (hf : Continuous f) (hg : Continuous g) (hf' : IsOpenMap f)
    (hg' : IsOpenMap g) (K : CompactOpens α) :
    K.map (f ∘ g) (hf.comp hg) (hf'.comp hg') = (K.map g hg hg').map f hf hf' :=
  CompactOpens.ext <| Set.image_comp _ _ _
#align topological_space.compact_opens.map_comp TopologicalSpace.CompactOpens.map_comp
-/

#print TopologicalSpace.CompactOpens.prod /-
/-- The product of two `compact_opens`, as a `compact_opens` in the product space. -/
protected def prod (K : CompactOpens α) (L : CompactOpens β) : CompactOpens (α × β) :=
  { K.toCompacts.Prod L.toCompacts with is_open' := K.IsOpen.Prod L.IsOpen }
#align topological_space.compact_opens.prod TopologicalSpace.CompactOpens.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print TopologicalSpace.CompactOpens.coe_prod /-
@[simp]
theorem coe_prod (K : CompactOpens α) (L : CompactOpens β) : (K.Prod L : Set (α × β)) = K ×ˢ L :=
  rfl
#align topological_space.compact_opens.coe_prod TopologicalSpace.CompactOpens.coe_prod
-/

end CompactOpens

end TopologicalSpace

