/-
Copyright (c) 2019 Sébastien Gouëzel. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sébastien Gouëzel

! This file was ported from Lean 3 source module logic.equiv.local_equiv
! leanprover-community/mathlib commit be24ec5de6701447e5df5ca75400ffee19d65659
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Function
import Mathbin.Logic.Equiv.Defs

/-!
# Local equivalences

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This files defines equivalences between subsets of given types.
An element `e` of `local_equiv α β` is made of two maps `e.to_fun` and `e.inv_fun` respectively
from α to β and from  β to α (just like equivs), which are inverse to each other on the subsets
`e.source` and `e.target` of respectively α and β.

They are designed in particular to define charts on manifolds.

The main functionality is `e.trans f`, which composes the two local equivalences by restricting
the source and target to the maximal set where the composition makes sense.

As for equivs, we register a coercion to functions and use it in our simp normal form: we write
`e x` and `e.symm y` instead of `e.to_fun x` and `e.inv_fun y`.

## Main definitions

`equiv.to_local_equiv`: associating a local equiv to an equiv, with source = target = univ
`local_equiv.symm`    : the inverse of a local equiv
`local_equiv.trans`   : the composition of two local equivs
`local_equiv.refl`    : the identity local equiv
`local_equiv.of_set`  : the identity on a set `s`
`eq_on_source`        : equivalence relation describing the "right" notion of equality for local
                        equivs (see below in implementation notes)

## Implementation notes

There are at least three possible implementations of local equivalences:
* equivs on subtypes
* pairs of functions taking values in `option α` and `option β`, equal to none where the local
equivalence is not defined
* pairs of functions defined everywhere, keeping the source and target as additional data

Each of these implementations has pros and cons.
* When dealing with subtypes, one still need to define additional API for composition and
restriction of domains. Checking that one always belongs to the right subtype makes things very
tedious, and leads quickly to DTT hell (as the subtype `u ∩ v` is not the "same" as `v ∩ u`, for
instance).
* With option-valued functions, the composition is very neat (it is just the usual composition, and
the domain is restricted automatically). These are implemented in `pequiv.lean`. For manifolds,
where one wants to discuss thoroughly the smoothness of the maps, this creates however a lot of
overhead as one would need to extend all classes of smoothness to option-valued maps.
* The local_equiv version as explained above is easier to use for manifolds. The drawback is that
there is extra useless data (the values of `to_fun` and `inv_fun` outside of `source` and `target`).
In particular, the equality notion between local equivs is not "the right one", i.e., coinciding
source and target and equality there. Moreover, there are no local equivs in this sense between
an empty type and a nonempty type. Since empty types are not that useful, and since one almost never
needs to talk about equal local equivs, this is not an issue in practice.
Still, we introduce an equivalence relation `eq_on_source` that captures this right notion of
equality, and show that many properties are invariant under this equivalence relation.

### Local coding conventions

If a lemma deals with the intersection of a set with either source or target of a `local_equiv`,
then it should use `e.source ∩ s` or `e.target ∩ t`, not `s ∩ e.source` or `t ∩ e.target`.

-/


-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'Lean.Meta._root_.Lean.Parser.Command.registerSimpAttr'
/--
    The simpset `mfld_simps` records several simp lemmas that are
    especially useful in manifolds. It is a subset of the whole set of simp lemmas, but it makes it
    possible to have quicker proofs (when used with `squeeze_simp` or `simp only`) while retaining
    readability.
    
    The typical use case is the following, in a file on manifolds:
    If `simp [foo, bar]` is slow, replace it with `squeeze_simp [foo, bar] with mfld_simps` and paste
    its output. The list of lemmas should be reasonable (contrary to the output of
    `squeeze_simp [foo, bar]` which might contain tens of lemmas), and the outcome should be quick
    enough.
     -/
  register_simp_attr
  mfld_simps

-- register in the simpset `mfld_simps` several lemmas that are often useful when dealing
-- with manifolds
attribute [mfld_simps] id.def Function.comp.left_id Set.mem_setOf_eq Set.image_eq_empty
  Set.univ_inter Set.preimage_univ Set.prod_mk_mem_set_prod_eq and_true_iff Set.mem_univ
  Set.mem_image_of_mem true_and_iff Set.mem_inter_iff Set.mem_preimage Function.comp_apply
  Set.inter_subset_left Set.mem_prod Set.range_id Set.range_prod_map and_self_iff Set.mem_range_self
  eq_self_iff_true forall_const forall_true_iff Set.inter_univ Set.preimage_id
  Function.comp.right_id not_false_iff and_imp Set.prod_inter_prod Set.univ_prod_univ true_or_iff
  or_true_iff Prod.map_mk Set.preimage_inter heq_iff_eq Equiv.sigmaEquivProd_apply
  Equiv.sigmaEquivProd_symm_apply Subtype.coe_mk Equiv.toFun_as_coe Equiv.invFun_as_coe

#print mfld_cfg /-
/-- Common `@[simps]` configuration options used for manifold-related declarations. -/
def mfld_cfg : SimpsCfg where
  attrs := [`simp, `mfld_simps]
  fullyApplied := false
#align mfld_cfg mfld_cfg
-/

namespace Tactic.Interactive

/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
/- ./././Mathport/Syntax/Translate/Expr.lean:336:4: warning: unsupported (TODO): `[tacs] -/
-- PLEASE REPORT THIS TO MATHPORT DEVS, THIS SHOULD NOT HAPPEN.
-- failed to format: unknown constant 'term.pseudo.antiquot'
/--
      A very basic tactic to show that sets showing up in manifolds coincide or are included in
      one another. -/
    unsafe
  def
    mfld_set_tac
    : tactic Unit
    :=
      do
        let goal ← tactic.target
          match
            goal
            with
            | q( $ ( e₁ ) = $ ( e₂ ) ) => sorry
              | q( $ ( e₁ ) ⊆ $ ( e₂ ) ) => sorry
              | _ => tactic.fail "goal should be an equality or an inclusion"
#align tactic.interactive.mfld_set_tac tactic.interactive.mfld_set_tac

end Tactic.Interactive

open Function Set

variable {α : Type _} {β : Type _} {γ : Type _} {δ : Type _}

#print LocalEquiv /-
/-- Local equivalence between subsets `source` and `target` of α and β respectively. The (global)
maps `to_fun : α → β` and `inv_fun : β → α` map `source` to `target` and conversely, and are inverse
to each other there. The values of `to_fun` outside of `source` and of `inv_fun` outside of `target`
are irrelevant. -/
structure LocalEquiv (α : Type _) (β : Type _) where
  toFun : α → β
  invFun : β → α
  source : Set α
  target : Set β
  map_source' : ∀ ⦃x⦄, x ∈ source → to_fun x ∈ target
  map_target' : ∀ ⦃x⦄, x ∈ target → inv_fun x ∈ source
  left_inv' : ∀ ⦃x⦄, x ∈ source → inv_fun (to_fun x) = x
  right_inv' : ∀ ⦃x⦄, x ∈ target → to_fun (inv_fun x) = x
#align local_equiv LocalEquiv
-/

namespace LocalEquiv

variable (e : LocalEquiv α β) (e' : LocalEquiv β γ)

instance [Inhabited α] [Inhabited β] : Inhabited (LocalEquiv α β) :=
  ⟨⟨const α default, const β default, ∅, ∅, mapsTo_empty _ _, mapsTo_empty _ _, eqOn_empty _ _,
      eqOn_empty _ _⟩⟩

#print LocalEquiv.symm /-
/-- The inverse of a local equiv -/
protected def symm : LocalEquiv β α where
  toFun := e.invFun
  invFun := e.toFun
  source := e.target
  target := e.source
  map_source' := e.map_target'
  map_target' := e.map_source'
  left_inv' := e.right_inv'
  right_inv' := e.left_inv'
#align local_equiv.symm LocalEquiv.symm
-/

instance : CoeFun (LocalEquiv α β) fun _ => α → β :=
  ⟨LocalEquiv.toFun⟩

#print LocalEquiv.Simps.symm_apply /-
/-- See Note [custom simps projection] -/
def Simps.symm_apply (e : LocalEquiv α β) : β → α :=
  e.symm
#align local_equiv.simps.symm_apply LocalEquiv.Simps.symm_apply
-/

initialize_simps_projections LocalEquiv (toFun → apply, invFun → symm_apply)

@[simp, mfld_simps]
theorem coe_mk (f : α → β) (g s t ml mr il ir) : (LocalEquiv.mk f g s t ml mr il ir : α → β) = f :=
  rfl
#align local_equiv.coe_mk LocalEquiv.coe_mk

#print LocalEquiv.coe_symm_mk /-
@[simp, mfld_simps]
theorem coe_symm_mk (f : α → β) (g s t ml mr il ir) :
    ((LocalEquiv.mk f g s t ml mr il ir).symm : β → α) = g :=
  rfl
#align local_equiv.coe_symm_mk LocalEquiv.coe_symm_mk
-/

@[simp, mfld_simps]
theorem toFun_as_coe : e.toFun = e :=
  rfl
#align local_equiv.to_fun_as_coe LocalEquiv.toFun_as_coe

#print LocalEquiv.invFun_as_coe /-
@[simp, mfld_simps]
theorem invFun_as_coe : e.invFun = e.symm :=
  rfl
#align local_equiv.inv_fun_as_coe LocalEquiv.invFun_as_coe
-/

#print LocalEquiv.map_source /-
@[simp, mfld_simps]
theorem map_source {x : α} (h : x ∈ e.source) : e x ∈ e.target :=
  e.map_source' h
#align local_equiv.map_source LocalEquiv.map_source
-/

#print LocalEquiv.map_target /-
@[simp, mfld_simps]
theorem map_target {x : β} (h : x ∈ e.target) : e.symm x ∈ e.source :=
  e.map_target' h
#align local_equiv.map_target LocalEquiv.map_target
-/

#print LocalEquiv.left_inv /-
@[simp, mfld_simps]
theorem left_inv {x : α} (h : x ∈ e.source) : e.symm (e x) = x :=
  e.left_inv' h
#align local_equiv.left_inv LocalEquiv.left_inv
-/

#print LocalEquiv.right_inv /-
@[simp, mfld_simps]
theorem right_inv {x : β} (h : x ∈ e.target) : e (e.symm x) = x :=
  e.right_inv' h
#align local_equiv.right_inv LocalEquiv.right_inv
-/

#print LocalEquiv.eq_symm_apply /-
theorem eq_symm_apply {x : α} {y : β} (hx : x ∈ e.source) (hy : y ∈ e.target) :
    x = e.symm y ↔ e x = y :=
  ⟨fun h => by rw [← e.right_inv hy, h], fun h => by rw [← e.left_inv hx, h]⟩
#align local_equiv.eq_symm_apply LocalEquiv.eq_symm_apply
-/

#print LocalEquiv.mapsTo /-
protected theorem mapsTo : MapsTo e e.source e.target := fun x => e.map_source
#align local_equiv.maps_to LocalEquiv.mapsTo
-/

#print LocalEquiv.symm_mapsTo /-
theorem symm_mapsTo : MapsTo e.symm e.target e.source :=
  e.symm.MapsTo
#align local_equiv.symm_maps_to LocalEquiv.symm_mapsTo
-/

#print LocalEquiv.leftInvOn /-
protected theorem leftInvOn : LeftInvOn e.symm e e.source := fun x => e.left_inv
#align local_equiv.left_inv_on LocalEquiv.leftInvOn
-/

#print LocalEquiv.rightInvOn /-
protected theorem rightInvOn : RightInvOn e.symm e e.target := fun x => e.right_inv
#align local_equiv.right_inv_on LocalEquiv.rightInvOn
-/

#print LocalEquiv.invOn /-
protected theorem invOn : InvOn e.symm e e.source e.target :=
  ⟨e.LeftInvOn, e.RightInvOn⟩
#align local_equiv.inv_on LocalEquiv.invOn
-/

#print LocalEquiv.injOn /-
protected theorem injOn : InjOn e e.source :=
  e.LeftInvOn.InjOn
#align local_equiv.inj_on LocalEquiv.injOn
-/

#print LocalEquiv.bijOn /-
protected theorem bijOn : BijOn e e.source e.target :=
  e.InvOn.BijOn e.MapsTo e.symm_mapsTo
#align local_equiv.bij_on LocalEquiv.bijOn
-/

#print LocalEquiv.surjOn /-
protected theorem surjOn : SurjOn e e.source e.target :=
  e.BijOn.SurjOn
#align local_equiv.surj_on LocalEquiv.surjOn
-/

#print Equiv.toLocalEquiv /-
/-- Associating a local_equiv to an equiv-/
@[simps (config := mfld_cfg)]
def Equiv.toLocalEquiv (e : α ≃ β) : LocalEquiv α β
    where
  toFun := e
  invFun := e.symm
  source := univ
  target := univ
  map_source' x hx := mem_univ _
  map_target' y hy := mem_univ _
  left_inv' x hx := e.left_inv x
  right_inv' x hx := e.right_inv x
#align equiv.to_local_equiv Equiv.toLocalEquiv
-/

#print LocalEquiv.inhabitedOfEmpty /-
instance inhabitedOfEmpty [IsEmpty α] [IsEmpty β] : Inhabited (LocalEquiv α β) :=
  ⟨((Equiv.equivEmpty α).trans (Equiv.equivEmpty β).symm).toLocalEquiv⟩
#align local_equiv.inhabited_of_empty LocalEquiv.inhabitedOfEmpty
-/

#print LocalEquiv.copy /-
/-- Create a copy of a `local_equiv` providing better definitional equalities. -/
@[simps (config := { fullyApplied := false })]
def copy (e : LocalEquiv α β) (f : α → β) (hf : ⇑e = f) (g : β → α) (hg : ⇑e.symm = g) (s : Set α)
    (hs : e.source = s) (t : Set β) (ht : e.target = t) : LocalEquiv α β
    where
  toFun := f
  invFun := g
  source := s
  target := t
  map_source' x := ht ▸ hs ▸ hf ▸ e.map_source
  map_target' y := hs ▸ ht ▸ hg ▸ e.map_target
  left_inv' x := hs ▸ hf ▸ hg ▸ e.left_inv
  right_inv' x := ht ▸ hf ▸ hg ▸ e.right_inv
#align local_equiv.copy LocalEquiv.copy
-/

#print LocalEquiv.copy_eq /-
theorem copy_eq (e : LocalEquiv α β) (f : α → β) (hf : ⇑e = f) (g : β → α) (hg : ⇑e.symm = g)
    (s : Set α) (hs : e.source = s) (t : Set β) (ht : e.target = t) :
    e.copy f hf g hg s hs t ht = e := by substs f g s t; cases e; rfl
#align local_equiv.copy_eq LocalEquiv.copy_eq
-/

#print LocalEquiv.toEquiv /-
/-- Associating to a local_equiv an equiv between the source and the target -/
protected def toEquiv : Equiv e.source e.target
    where
  toFun x := ⟨e x, e.map_source x.Mem⟩
  invFun y := ⟨e.symm y, e.map_target y.Mem⟩
  left_inv := fun ⟨x, hx⟩ => Subtype.eq <| e.left_inv hx
  right_inv := fun ⟨y, hy⟩ => Subtype.eq <| e.right_inv hy
#align local_equiv.to_equiv LocalEquiv.toEquiv
-/

#print LocalEquiv.symm_source /-
@[simp, mfld_simps]
theorem symm_source : e.symm.source = e.target :=
  rfl
#align local_equiv.symm_source LocalEquiv.symm_source
-/

#print LocalEquiv.symm_target /-
@[simp, mfld_simps]
theorem symm_target : e.symm.target = e.source :=
  rfl
#align local_equiv.symm_target LocalEquiv.symm_target
-/

#print LocalEquiv.symm_symm /-
@[simp, mfld_simps]
theorem symm_symm : e.symm.symm = e := by cases e; rfl
#align local_equiv.symm_symm LocalEquiv.symm_symm
-/

#print LocalEquiv.image_source_eq_target /-
theorem image_source_eq_target : e '' e.source = e.target :=
  e.BijOn.image_eq
#align local_equiv.image_source_eq_target LocalEquiv.image_source_eq_target
-/

#print LocalEquiv.forall_mem_target /-
theorem forall_mem_target {p : β → Prop} : (∀ y ∈ e.target, p y) ↔ ∀ x ∈ e.source, p (e x) := by
  rw [← image_source_eq_target, ball_image_iff]
#align local_equiv.forall_mem_target LocalEquiv.forall_mem_target
-/

#print LocalEquiv.exists_mem_target /-
theorem exists_mem_target {p : β → Prop} : (∃ y ∈ e.target, p y) ↔ ∃ x ∈ e.source, p (e x) := by
  rw [← image_source_eq_target, bex_image_iff]
#align local_equiv.exists_mem_target LocalEquiv.exists_mem_target
-/

#print LocalEquiv.IsImage /-
/-- We say that `t : set β` is an image of `s : set α` under a local equivalence if
any of the following equivalent conditions hold:

* `e '' (e.source ∩ s) = e.target ∩ t`;
* `e.source ∩ e ⁻¹ t = e.source ∩ s`;
* `∀ x ∈ e.source, e x ∈ t ↔ x ∈ s` (this one is used in the definition).
-/
def IsImage (s : Set α) (t : Set β) : Prop :=
  ∀ ⦃x⦄, x ∈ e.source → (e x ∈ t ↔ x ∈ s)
#align local_equiv.is_image LocalEquiv.IsImage
-/

namespace IsImage

variable {e} {s : Set α} {t : Set β} {x : α} {y : β}

#print LocalEquiv.IsImage.apply_mem_iff /-
theorem apply_mem_iff (h : e.IsImage s t) (hx : x ∈ e.source) : e x ∈ t ↔ x ∈ s :=
  h hx
#align local_equiv.is_image.apply_mem_iff LocalEquiv.IsImage.apply_mem_iff
-/

#print LocalEquiv.IsImage.symm_apply_mem_iff /-
theorem symm_apply_mem_iff (h : e.IsImage s t) : ∀ ⦃y⦄, y ∈ e.target → (e.symm y ∈ s ↔ y ∈ t) :=
  e.forall_mem_target.mpr fun x hx => by rw [e.left_inv hx, h hx]
#align local_equiv.is_image.symm_apply_mem_iff LocalEquiv.IsImage.symm_apply_mem_iff
-/

#print LocalEquiv.IsImage.symm /-
protected theorem symm (h : e.IsImage s t) : e.symm.IsImage t s :=
  h.symm_apply_mem_iff
#align local_equiv.is_image.symm LocalEquiv.IsImage.symm
-/

#print LocalEquiv.IsImage.symm_iff /-
@[simp]
theorem symm_iff : e.symm.IsImage t s ↔ e.IsImage s t :=
  ⟨fun h => h.symm, fun h => h.symm⟩
#align local_equiv.is_image.symm_iff LocalEquiv.IsImage.symm_iff
-/

#print LocalEquiv.IsImage.mapsTo /-
protected theorem mapsTo (h : e.IsImage s t) : MapsTo e (e.source ∩ s) (e.target ∩ t) := fun x hx =>
  ⟨e.MapsTo hx.1, (h hx.1).2 hx.2⟩
#align local_equiv.is_image.maps_to LocalEquiv.IsImage.mapsTo
-/

#print LocalEquiv.IsImage.symm_mapsTo /-
theorem symm_mapsTo (h : e.IsImage s t) : MapsTo e.symm (e.target ∩ t) (e.source ∩ s) :=
  h.symm.MapsTo
#align local_equiv.is_image.symm_maps_to LocalEquiv.IsImage.symm_mapsTo
-/

#print LocalEquiv.IsImage.restr /-
/-- Restrict a `local_equiv` to a pair of corresponding sets. -/
@[simps (config := { fullyApplied := false })]
def restr (h : e.IsImage s t) : LocalEquiv α β
    where
  toFun := e
  invFun := e.symm
  source := e.source ∩ s
  target := e.target ∩ t
  map_source' := h.MapsTo
  map_target' := h.symm_mapsTo
  left_inv' := e.LeftInvOn.mono (inter_subset_left _ _)
  right_inv' := e.RightInvOn.mono (inter_subset_left _ _)
#align local_equiv.is_image.restr LocalEquiv.IsImage.restr
-/

#print LocalEquiv.IsImage.image_eq /-
theorem image_eq (h : e.IsImage s t) : e '' (e.source ∩ s) = e.target ∩ t :=
  h.restr.image_source_eq_target
#align local_equiv.is_image.image_eq LocalEquiv.IsImage.image_eq
-/

#print LocalEquiv.IsImage.symm_image_eq /-
theorem symm_image_eq (h : e.IsImage s t) : e.symm '' (e.target ∩ t) = e.source ∩ s :=
  h.symm.image_eq
#align local_equiv.is_image.symm_image_eq LocalEquiv.IsImage.symm_image_eq
-/

#print LocalEquiv.IsImage.iff_preimage_eq /-
theorem iff_preimage_eq : e.IsImage s t ↔ e.source ∩ e ⁻¹' t = e.source ∩ s := by
  simp only [is_image, Set.ext_iff, mem_inter_iff, and_congr_right_iff, mem_preimage]
#align local_equiv.is_image.iff_preimage_eq LocalEquiv.IsImage.iff_preimage_eq
-/

alias iff_preimage_eq ↔ preimage_eq of_preimage_eq
#align local_equiv.is_image.preimage_eq LocalEquiv.IsImage.preimage_eq
#align local_equiv.is_image.of_preimage_eq LocalEquiv.IsImage.of_preimage_eq

#print LocalEquiv.IsImage.iff_symm_preimage_eq /-
theorem iff_symm_preimage_eq : e.IsImage s t ↔ e.target ∩ e.symm ⁻¹' s = e.target ∩ t :=
  symm_iff.symm.trans iff_preimage_eq
#align local_equiv.is_image.iff_symm_preimage_eq LocalEquiv.IsImage.iff_symm_preimage_eq
-/

alias iff_symm_preimage_eq ↔ symm_preimage_eq of_symm_preimage_eq
#align local_equiv.is_image.symm_preimage_eq LocalEquiv.IsImage.symm_preimage_eq
#align local_equiv.is_image.of_symm_preimage_eq LocalEquiv.IsImage.of_symm_preimage_eq

#print LocalEquiv.IsImage.of_image_eq /-
theorem of_image_eq (h : e '' (e.source ∩ s) = e.target ∩ t) : e.IsImage s t :=
  of_symm_preimage_eq <| Eq.trans (of_symm_preimage_eq rfl).image_eq.symm h
#align local_equiv.is_image.of_image_eq LocalEquiv.IsImage.of_image_eq
-/

#print LocalEquiv.IsImage.of_symm_image_eq /-
theorem of_symm_image_eq (h : e.symm '' (e.target ∩ t) = e.source ∩ s) : e.IsImage s t :=
  of_preimage_eq <| Eq.trans (of_preimage_eq rfl).symm_image_eq.symm h
#align local_equiv.is_image.of_symm_image_eq LocalEquiv.IsImage.of_symm_image_eq
-/

#print LocalEquiv.IsImage.compl /-
protected theorem compl (h : e.IsImage s t) : e.IsImage (sᶜ) (tᶜ) := fun x hx => not_congr (h hx)
#align local_equiv.is_image.compl LocalEquiv.IsImage.compl
-/

#print LocalEquiv.IsImage.inter /-
protected theorem inter {s' t'} (h : e.IsImage s t) (h' : e.IsImage s' t') :
    e.IsImage (s ∩ s') (t ∩ t') := fun x hx => and_congr (h hx) (h' hx)
#align local_equiv.is_image.inter LocalEquiv.IsImage.inter
-/

#print LocalEquiv.IsImage.union /-
protected theorem union {s' t'} (h : e.IsImage s t) (h' : e.IsImage s' t') :
    e.IsImage (s ∪ s') (t ∪ t') := fun x hx => or_congr (h hx) (h' hx)
#align local_equiv.is_image.union LocalEquiv.IsImage.union
-/

#print LocalEquiv.IsImage.diff /-
protected theorem diff {s' t'} (h : e.IsImage s t) (h' : e.IsImage s' t') :
    e.IsImage (s \ s') (t \ t') :=
  h.inter h'.compl
#align local_equiv.is_image.diff LocalEquiv.IsImage.diff
-/

#print LocalEquiv.IsImage.leftInvOn_piecewise /-
theorem leftInvOn_piecewise {e' : LocalEquiv α β} [∀ i, Decidable (i ∈ s)] [∀ i, Decidable (i ∈ t)]
    (h : e.IsImage s t) (h' : e'.IsImage s t) :
    LeftInvOn (t.piecewise e.symm e'.symm) (s.piecewise e e') (s.ite e.source e'.source) :=
  by
  rintro x (⟨he, hs⟩ | ⟨he, hs : x ∉ s⟩)
  · rw [piecewise_eq_of_mem _ _ _ hs, piecewise_eq_of_mem _ _ _ ((h he).2 hs), e.left_inv he]
  ·
    rw [piecewise_eq_of_not_mem _ _ _ hs, piecewise_eq_of_not_mem _ _ _ ((h'.compl he).2 hs),
      e'.left_inv he]
#align local_equiv.is_image.left_inv_on_piecewise LocalEquiv.IsImage.leftInvOn_piecewise
-/

#print LocalEquiv.IsImage.inter_eq_of_inter_eq_of_eqOn /-
theorem inter_eq_of_inter_eq_of_eqOn {e' : LocalEquiv α β} (h : e.IsImage s t) (h' : e'.IsImage s t)
    (hs : e.source ∩ s = e'.source ∩ s) (Heq : EqOn e e' (e.source ∩ s)) :
    e.target ∩ t = e'.target ∩ t := by rw [← h.image_eq, ← h'.image_eq, ← hs, Heq.image_eq]
#align local_equiv.is_image.inter_eq_of_inter_eq_of_eq_on LocalEquiv.IsImage.inter_eq_of_inter_eq_of_eqOn
-/

#print LocalEquiv.IsImage.symm_eq_on_of_inter_eq_of_eqOn /-
theorem symm_eq_on_of_inter_eq_of_eqOn {e' : LocalEquiv α β} (h : e.IsImage s t)
    (hs : e.source ∩ s = e'.source ∩ s) (Heq : EqOn e e' (e.source ∩ s)) :
    EqOn e.symm e'.symm (e.target ∩ t) :=
  by
  rw [← h.image_eq]
  rintro y ⟨x, hx, rfl⟩
  have hx' := hx; rw [hs] at hx' 
  rw [e.left_inv hx.1, Heq hx, e'.left_inv hx'.1]
#align local_equiv.is_image.symm_eq_on_of_inter_eq_of_eq_on LocalEquiv.IsImage.symm_eq_on_of_inter_eq_of_eqOn
-/

end IsImage

#print LocalEquiv.isImage_source_target /-
theorem isImage_source_target : e.IsImage e.source e.target := fun x hx => by simp [hx]
#align local_equiv.is_image_source_target LocalEquiv.isImage_source_target
-/

#print LocalEquiv.isImage_source_target_of_disjoint /-
theorem isImage_source_target_of_disjoint (e' : LocalEquiv α β) (hs : Disjoint e.source e'.source)
    (ht : Disjoint e.target e'.target) : e.IsImage e'.source e'.target :=
  IsImage.of_image_eq <| by rw [hs.inter_eq, ht.inter_eq, image_empty]
#align local_equiv.is_image_source_target_of_disjoint LocalEquiv.isImage_source_target_of_disjoint
-/

#print LocalEquiv.image_source_inter_eq' /-
theorem image_source_inter_eq' (s : Set α) : e '' (e.source ∩ s) = e.target ∩ e.symm ⁻¹' s := by
  rw [inter_comm, e.left_inv_on.image_inter', image_source_eq_target, inter_comm]
#align local_equiv.image_source_inter_eq' LocalEquiv.image_source_inter_eq'
-/

#print LocalEquiv.image_source_inter_eq /-
theorem image_source_inter_eq (s : Set α) :
    e '' (e.source ∩ s) = e.target ∩ e.symm ⁻¹' (e.source ∩ s) := by
  rw [inter_comm, e.left_inv_on.image_inter, image_source_eq_target, inter_comm]
#align local_equiv.image_source_inter_eq LocalEquiv.image_source_inter_eq
-/

#print LocalEquiv.image_eq_target_inter_inv_preimage /-
theorem image_eq_target_inter_inv_preimage {s : Set α} (h : s ⊆ e.source) :
    e '' s = e.target ∩ e.symm ⁻¹' s := by
  rw [← e.image_source_inter_eq', inter_eq_self_of_subset_right h]
#align local_equiv.image_eq_target_inter_inv_preimage LocalEquiv.image_eq_target_inter_inv_preimage
-/

#print LocalEquiv.symm_image_eq_source_inter_preimage /-
theorem symm_image_eq_source_inter_preimage {s : Set β} (h : s ⊆ e.target) :
    e.symm '' s = e.source ∩ e ⁻¹' s :=
  e.symm.image_eq_target_inter_inv_preimage h
#align local_equiv.symm_image_eq_source_inter_preimage LocalEquiv.symm_image_eq_source_inter_preimage
-/

#print LocalEquiv.symm_image_target_inter_eq /-
theorem symm_image_target_inter_eq (s : Set β) :
    e.symm '' (e.target ∩ s) = e.source ∩ e ⁻¹' (e.target ∩ s) :=
  e.symm.image_source_inter_eq _
#align local_equiv.symm_image_target_inter_eq LocalEquiv.symm_image_target_inter_eq
-/

#print LocalEquiv.symm_image_target_inter_eq' /-
theorem symm_image_target_inter_eq' (s : Set β) : e.symm '' (e.target ∩ s) = e.source ∩ e ⁻¹' s :=
  e.symm.image_source_inter_eq' _
#align local_equiv.symm_image_target_inter_eq' LocalEquiv.symm_image_target_inter_eq'
-/

#print LocalEquiv.source_inter_preimage_inv_preimage /-
theorem source_inter_preimage_inv_preimage (s : Set α) :
    e.source ∩ e ⁻¹' (e.symm ⁻¹' s) = e.source ∩ s :=
  Set.ext fun x => and_congr_right_iff.2 fun hx => by simp only [mem_preimage, e.left_inv hx]
#align local_equiv.source_inter_preimage_inv_preimage LocalEquiv.source_inter_preimage_inv_preimage
-/

#print LocalEquiv.source_inter_preimage_target_inter /-
theorem source_inter_preimage_target_inter (s : Set β) :
    e.source ∩ e ⁻¹' (e.target ∩ s) = e.source ∩ e ⁻¹' s :=
  ext fun x => ⟨fun hx => ⟨hx.1, hx.2.2⟩, fun hx => ⟨hx.1, e.map_source hx.1, hx.2⟩⟩
#align local_equiv.source_inter_preimage_target_inter LocalEquiv.source_inter_preimage_target_inter
-/

#print LocalEquiv.target_inter_inv_preimage_preimage /-
theorem target_inter_inv_preimage_preimage (s : Set β) :
    e.target ∩ e.symm ⁻¹' (e ⁻¹' s) = e.target ∩ s :=
  e.symm.source_inter_preimage_inv_preimage _
#align local_equiv.target_inter_inv_preimage_preimage LocalEquiv.target_inter_inv_preimage_preimage
-/

#print LocalEquiv.symm_image_image_of_subset_source /-
theorem symm_image_image_of_subset_source {s : Set α} (h : s ⊆ e.source) : e.symm '' (e '' s) = s :=
  (e.LeftInvOn.mono h).image_image
#align local_equiv.symm_image_image_of_subset_source LocalEquiv.symm_image_image_of_subset_source
-/

#print LocalEquiv.image_symm_image_of_subset_target /-
theorem image_symm_image_of_subset_target {s : Set β} (h : s ⊆ e.target) : e '' (e.symm '' s) = s :=
  e.symm.symm_image_image_of_subset_source h
#align local_equiv.image_symm_image_of_subset_target LocalEquiv.image_symm_image_of_subset_target
-/

#print LocalEquiv.source_subset_preimage_target /-
theorem source_subset_preimage_target : e.source ⊆ e ⁻¹' e.target :=
  e.MapsTo
#align local_equiv.source_subset_preimage_target LocalEquiv.source_subset_preimage_target
-/

#print LocalEquiv.symm_image_target_eq_source /-
theorem symm_image_target_eq_source : e.symm '' e.target = e.source :=
  e.symm.image_source_eq_target
#align local_equiv.symm_image_target_eq_source LocalEquiv.symm_image_target_eq_source
-/

#print LocalEquiv.target_subset_preimage_source /-
theorem target_subset_preimage_source : e.target ⊆ e.symm ⁻¹' e.source :=
  e.symm_mapsTo
#align local_equiv.target_subset_preimage_source LocalEquiv.target_subset_preimage_source
-/

#print LocalEquiv.ext /-
/-- Two local equivs that have the same `source`, same `to_fun` and same `inv_fun`, coincide. -/
@[ext]
protected theorem ext {e e' : LocalEquiv α β} (h : ∀ x, e x = e' x)
    (hsymm : ∀ x, e.symm x = e'.symm x) (hs : e.source = e'.source) : e = e' :=
  by
  have A : (e : α → β) = e' := by ext x; exact h x
  have B : (e.symm : β → α) = e'.symm := by ext x; exact hsymm x
  have I : e '' e.source = e.target := e.image_source_eq_target
  have I' : e' '' e'.source = e'.target := e'.image_source_eq_target
  rw [A, hs, I'] at I 
  cases e <;> cases e'
  simp_all
#align local_equiv.ext LocalEquiv.ext
-/

#print LocalEquiv.restr /-
/-- Restricting a local equivalence to e.source ∩ s -/
protected def restr (s : Set α) : LocalEquiv α β :=
  (@IsImage.of_symm_preimage_eq α β e s (e.symm ⁻¹' s) rfl).restr
#align local_equiv.restr LocalEquiv.restr
-/

#print LocalEquiv.restr_coe /-
@[simp, mfld_simps]
theorem restr_coe (s : Set α) : (e.restr s : α → β) = e :=
  rfl
#align local_equiv.restr_coe LocalEquiv.restr_coe
-/

#print LocalEquiv.restr_coe_symm /-
@[simp, mfld_simps]
theorem restr_coe_symm (s : Set α) : ((e.restr s).symm : β → α) = e.symm :=
  rfl
#align local_equiv.restr_coe_symm LocalEquiv.restr_coe_symm
-/

#print LocalEquiv.restr_source /-
@[simp, mfld_simps]
theorem restr_source (s : Set α) : (e.restr s).source = e.source ∩ s :=
  rfl
#align local_equiv.restr_source LocalEquiv.restr_source
-/

#print LocalEquiv.restr_target /-
@[simp, mfld_simps]
theorem restr_target (s : Set α) : (e.restr s).target = e.target ∩ e.symm ⁻¹' s :=
  rfl
#align local_equiv.restr_target LocalEquiv.restr_target
-/

#print LocalEquiv.restr_eq_of_source_subset /-
theorem restr_eq_of_source_subset {e : LocalEquiv α β} {s : Set α} (h : e.source ⊆ s) :
    e.restr s = e :=
  LocalEquiv.ext (fun _ => rfl) (fun _ => rfl) (by simp [inter_eq_self_of_subset_left h])
#align local_equiv.restr_eq_of_source_subset LocalEquiv.restr_eq_of_source_subset
-/

#print LocalEquiv.restr_univ /-
@[simp, mfld_simps]
theorem restr_univ {e : LocalEquiv α β} : e.restr univ = e :=
  restr_eq_of_source_subset (subset_univ _)
#align local_equiv.restr_univ LocalEquiv.restr_univ
-/

#print LocalEquiv.refl /-
/-- The identity local equiv -/
protected def refl (α : Type _) : LocalEquiv α α :=
  (Equiv.refl α).toLocalEquiv
#align local_equiv.refl LocalEquiv.refl
-/

#print LocalEquiv.refl_source /-
@[simp, mfld_simps]
theorem refl_source : (LocalEquiv.refl α).source = univ :=
  rfl
#align local_equiv.refl_source LocalEquiv.refl_source
-/

#print LocalEquiv.refl_target /-
@[simp, mfld_simps]
theorem refl_target : (LocalEquiv.refl α).target = univ :=
  rfl
#align local_equiv.refl_target LocalEquiv.refl_target
-/

#print LocalEquiv.refl_coe /-
@[simp, mfld_simps]
theorem refl_coe : (LocalEquiv.refl α : α → α) = id :=
  rfl
#align local_equiv.refl_coe LocalEquiv.refl_coe
-/

#print LocalEquiv.refl_symm /-
@[simp, mfld_simps]
theorem refl_symm : (LocalEquiv.refl α).symm = LocalEquiv.refl α :=
  rfl
#align local_equiv.refl_symm LocalEquiv.refl_symm
-/

#print LocalEquiv.refl_restr_source /-
@[simp, mfld_simps]
theorem refl_restr_source (s : Set α) : ((LocalEquiv.refl α).restr s).source = s := by simp
#align local_equiv.refl_restr_source LocalEquiv.refl_restr_source
-/

#print LocalEquiv.refl_restr_target /-
@[simp, mfld_simps]
theorem refl_restr_target (s : Set α) : ((LocalEquiv.refl α).restr s).target = s := by
  change univ ∩ id ⁻¹' s = s; simp
#align local_equiv.refl_restr_target LocalEquiv.refl_restr_target
-/

#print LocalEquiv.ofSet /-
/-- The identity local equiv on a set `s` -/
def ofSet (s : Set α) : LocalEquiv α α where
  toFun := id
  invFun := id
  source := s
  target := s
  map_source' x hx := hx
  map_target' x hx := hx
  left_inv' x hx := rfl
  right_inv' x hx := rfl
#align local_equiv.of_set LocalEquiv.ofSet
-/

#print LocalEquiv.ofSet_source /-
@[simp, mfld_simps]
theorem ofSet_source (s : Set α) : (LocalEquiv.ofSet s).source = s :=
  rfl
#align local_equiv.of_set_source LocalEquiv.ofSet_source
-/

#print LocalEquiv.ofSet_target /-
@[simp, mfld_simps]
theorem ofSet_target (s : Set α) : (LocalEquiv.ofSet s).target = s :=
  rfl
#align local_equiv.of_set_target LocalEquiv.ofSet_target
-/

#print LocalEquiv.ofSet_coe /-
@[simp, mfld_simps]
theorem ofSet_coe (s : Set α) : (LocalEquiv.ofSet s : α → α) = id :=
  rfl
#align local_equiv.of_set_coe LocalEquiv.ofSet_coe
-/

#print LocalEquiv.ofSet_symm /-
@[simp, mfld_simps]
theorem ofSet_symm (s : Set α) : (LocalEquiv.ofSet s).symm = LocalEquiv.ofSet s :=
  rfl
#align local_equiv.of_set_symm LocalEquiv.ofSet_symm
-/

#print LocalEquiv.trans' /-
/-- Composing two local equivs if the target of the first coincides with the source of the
second. -/
protected def trans' (e' : LocalEquiv β γ) (h : e.target = e'.source) : LocalEquiv α γ
    where
  toFun := e' ∘ e
  invFun := e.symm ∘ e'.symm
  source := e.source
  target := e'.target
  map_source' x hx := by simp [h.symm, hx]
  map_target' y hy := by simp [h, hy]
  left_inv' x hx := by simp [hx, h.symm]
  right_inv' y hy := by simp [hy, h]
#align local_equiv.trans' LocalEquiv.trans'
-/

#print LocalEquiv.trans /-
/-- Composing two local equivs, by restricting to the maximal domain where their composition
is well defined. -/
protected def trans : LocalEquiv α γ :=
  LocalEquiv.trans' (e.symm.restr e'.source).symm (e'.restr e.target) (inter_comm _ _)
#align local_equiv.trans LocalEquiv.trans
-/

#print LocalEquiv.coe_trans /-
@[simp, mfld_simps]
theorem coe_trans : (e.trans e' : α → γ) = e' ∘ e :=
  rfl
#align local_equiv.coe_trans LocalEquiv.coe_trans
-/

#print LocalEquiv.coe_trans_symm /-
@[simp, mfld_simps]
theorem coe_trans_symm : ((e.trans e').symm : γ → α) = e.symm ∘ e'.symm :=
  rfl
#align local_equiv.coe_trans_symm LocalEquiv.coe_trans_symm
-/

#print LocalEquiv.trans_apply /-
theorem trans_apply {x : α} : (e.trans e') x = e' (e x) :=
  rfl
#align local_equiv.trans_apply LocalEquiv.trans_apply
-/

#print LocalEquiv.trans_symm_eq_symm_trans_symm /-
theorem trans_symm_eq_symm_trans_symm : (e.trans e').symm = e'.symm.trans e.symm := by
  cases e <;> cases e' <;> rfl
#align local_equiv.trans_symm_eq_symm_trans_symm LocalEquiv.trans_symm_eq_symm_trans_symm
-/

#print LocalEquiv.trans_source /-
@[simp, mfld_simps]
theorem trans_source : (e.trans e').source = e.source ∩ e ⁻¹' e'.source :=
  rfl
#align local_equiv.trans_source LocalEquiv.trans_source
-/

#print LocalEquiv.trans_source' /-
theorem trans_source' : (e.trans e').source = e.source ∩ e ⁻¹' (e.target ∩ e'.source) := by
  mfld_set_tac
#align local_equiv.trans_source' LocalEquiv.trans_source'
-/

#print LocalEquiv.trans_source'' /-
theorem trans_source'' : (e.trans e').source = e.symm '' (e.target ∩ e'.source) := by
  rw [e.trans_source', e.symm_image_target_inter_eq]
#align local_equiv.trans_source'' LocalEquiv.trans_source''
-/

#print LocalEquiv.image_trans_source /-
theorem image_trans_source : e '' (e.trans e').source = e.target ∩ e'.source :=
  (e.symm.restr e'.source).symm.image_source_eq_target
#align local_equiv.image_trans_source LocalEquiv.image_trans_source
-/

#print LocalEquiv.trans_target /-
@[simp, mfld_simps]
theorem trans_target : (e.trans e').target = e'.target ∩ e'.symm ⁻¹' e.target :=
  rfl
#align local_equiv.trans_target LocalEquiv.trans_target
-/

#print LocalEquiv.trans_target' /-
theorem trans_target' : (e.trans e').target = e'.target ∩ e'.symm ⁻¹' (e'.source ∩ e.target) :=
  trans_source' e'.symm e.symm
#align local_equiv.trans_target' LocalEquiv.trans_target'
-/

#print LocalEquiv.trans_target'' /-
theorem trans_target'' : (e.trans e').target = e' '' (e'.source ∩ e.target) :=
  trans_source'' e'.symm e.symm
#align local_equiv.trans_target'' LocalEquiv.trans_target''
-/

#print LocalEquiv.inv_image_trans_target /-
theorem inv_image_trans_target : e'.symm '' (e.trans e').target = e'.source ∩ e.target :=
  image_trans_source e'.symm e.symm
#align local_equiv.inv_image_trans_target LocalEquiv.inv_image_trans_target
-/

#print LocalEquiv.trans_assoc /-
theorem trans_assoc (e'' : LocalEquiv γ δ) : (e.trans e').trans e'' = e.trans (e'.trans e'') :=
  LocalEquiv.ext (fun x => rfl) (fun x => rfl)
    (by simp [trans_source, @preimage_comp α β γ, inter_assoc])
#align local_equiv.trans_assoc LocalEquiv.trans_assoc
-/

#print LocalEquiv.trans_refl /-
@[simp, mfld_simps]
theorem trans_refl : e.trans (LocalEquiv.refl β) = e :=
  LocalEquiv.ext (fun x => rfl) (fun x => rfl) (by simp [trans_source])
#align local_equiv.trans_refl LocalEquiv.trans_refl
-/

#print LocalEquiv.refl_trans /-
@[simp, mfld_simps]
theorem refl_trans : (LocalEquiv.refl α).trans e = e :=
  LocalEquiv.ext (fun x => rfl) (fun x => rfl) (by simp [trans_source, preimage_id])
#align local_equiv.refl_trans LocalEquiv.refl_trans
-/

#print LocalEquiv.trans_refl_restr /-
theorem trans_refl_restr (s : Set β) : e.trans ((LocalEquiv.refl β).restr s) = e.restr (e ⁻¹' s) :=
  LocalEquiv.ext (fun x => rfl) (fun x => rfl) (by simp [trans_source])
#align local_equiv.trans_refl_restr LocalEquiv.trans_refl_restr
-/

#print LocalEquiv.trans_refl_restr' /-
theorem trans_refl_restr' (s : Set β) :
    e.trans ((LocalEquiv.refl β).restr s) = e.restr (e.source ∩ e ⁻¹' s) :=
  (LocalEquiv.ext (fun x => rfl) fun x => rfl) <| by simp [trans_source];
    rw [← inter_assoc, inter_self]
#align local_equiv.trans_refl_restr' LocalEquiv.trans_refl_restr'
-/

#print LocalEquiv.restr_trans /-
theorem restr_trans (s : Set α) : (e.restr s).trans e' = (e.trans e').restr s :=
  (LocalEquiv.ext (fun x => rfl) fun x => rfl) <| by simp [trans_source, inter_comm];
    rwa [inter_assoc]
#align local_equiv.restr_trans LocalEquiv.restr_trans
-/

#print LocalEquiv.mem_symm_trans_source /-
/-- A lemma commonly useful when `e` and `e'` are charts of a manifold. -/
theorem mem_symm_trans_source {e' : LocalEquiv α γ} {x : α} (he : x ∈ e.source)
    (he' : x ∈ e'.source) : e x ∈ (e.symm.trans e').source :=
  ⟨e.MapsTo he, by rwa [mem_preimage, LocalEquiv.symm_symm, e.left_inv he]⟩
#align local_equiv.mem_symm_trans_source LocalEquiv.mem_symm_trans_source
-/

#print LocalEquiv.transEquiv /-
/-- Postcompose a local equivalence with an equivalence.
We modify the source and target to have better definitional behavior. -/
@[simps]
def transEquiv (e' : β ≃ γ) : LocalEquiv α γ :=
  (e.trans e'.toLocalEquiv).copy _ rfl _ rfl e.source (inter_univ _) (e'.symm ⁻¹' e.target)
    (univ_inter _)
#align local_equiv.trans_equiv LocalEquiv.transEquiv
-/

#print LocalEquiv.transEquiv_eq_trans /-
theorem transEquiv_eq_trans (e' : β ≃ γ) : e.transEquiv e' = e.trans e'.toLocalEquiv :=
  copy_eq _ _ _ _ _ _ _ _ _
#align local_equiv.trans_equiv_eq_trans LocalEquiv.transEquiv_eq_trans
-/

#print Equiv.transLocalEquiv /-
/-- Precompose a local equivalence with an equivalence.
We modify the source and target to have better definitional behavior. -/
@[simps]
def Equiv.transLocalEquiv (e : α ≃ β) : LocalEquiv α γ :=
  (e.toLocalEquiv.trans e').copy _ rfl _ rfl (e ⁻¹' e'.source) (univ_inter _) e'.target
    (inter_univ _)
#align equiv.trans_local_equiv Equiv.transLocalEquiv
-/

#print Equiv.transLocalEquiv_eq_trans /-
theorem Equiv.transLocalEquiv_eq_trans (e : α ≃ β) :
    e.transLocalEquiv e' = e.toLocalEquiv.trans e' :=
  copy_eq _ _ _ _ _ _ _ _ _
#align equiv.trans_local_equiv_eq_trans Equiv.transLocalEquiv_eq_trans
-/

#print LocalEquiv.EqOnSource /-
/-- `eq_on_source e e'` means that `e` and `e'` have the same source, and coincide there. Then `e`
and `e'` should really be considered the same local equiv. -/
def EqOnSource (e e' : LocalEquiv α β) : Prop :=
  e.source = e'.source ∧ e.source.EqOn e e'
#align local_equiv.eq_on_source LocalEquiv.EqOnSource
-/

#print LocalEquiv.eqOnSourceSetoid /-
/-- `eq_on_source` is an equivalence relation -/
instance eqOnSourceSetoid : Setoid (LocalEquiv α β)
    where
  R := EqOnSource
  iseqv :=
    ⟨fun e => by simp [eq_on_source], fun e e' h => by simp [eq_on_source, h.1.symm];
      exact fun x hx => (h.2 hx).symm, fun e e' e'' h h' =>
      ⟨by rwa [← h'.1, ← h.1], fun x hx => by rw [← h'.2, h.2 hx]; rwa [← h.1]⟩⟩
#align local_equiv.eq_on_source_setoid LocalEquiv.eqOnSourceSetoid
-/

#print LocalEquiv.eqOnSource_refl /-
theorem eqOnSource_refl : e ≈ e :=
  Setoid.refl _
#align local_equiv.eq_on_source_refl LocalEquiv.eqOnSource_refl
-/

#print LocalEquiv.EqOnSource.source_eq /-
/-- Two equivalent local equivs have the same source -/
theorem EqOnSource.source_eq {e e' : LocalEquiv α β} (h : e ≈ e') : e.source = e'.source :=
  h.1
#align local_equiv.eq_on_source.source_eq LocalEquiv.EqOnSource.source_eq
-/

#print LocalEquiv.EqOnSource.eqOn /-
/-- Two equivalent local equivs coincide on the source -/
theorem EqOnSource.eqOn {e e' : LocalEquiv α β} (h : e ≈ e') : e.source.EqOn e e' :=
  h.2
#align local_equiv.eq_on_source.eq_on LocalEquiv.EqOnSource.eqOn
-/

#print LocalEquiv.EqOnSource.target_eq /-
/-- Two equivalent local equivs have the same target -/
theorem EqOnSource.target_eq {e e' : LocalEquiv α β} (h : e ≈ e') : e.target = e'.target := by
  simp only [← image_source_eq_target, ← h.source_eq, h.2.image_eq]
#align local_equiv.eq_on_source.target_eq LocalEquiv.EqOnSource.target_eq
-/

#print LocalEquiv.EqOnSource.symm' /-
/-- If two local equivs are equivalent, so are their inverses. -/
theorem EqOnSource.symm' {e e' : LocalEquiv α β} (h : e ≈ e') : e.symm ≈ e'.symm :=
  by
  refine' ⟨h.target_eq, eq_on_of_left_inv_on_of_right_inv_on e.left_inv_on _ _⟩ <;>
    simp only [symm_source, h.target_eq, h.source_eq, e'.symm_maps_to]
  exact e'.right_inv_on.congr_right e'.symm_maps_to (h.source_eq ▸ h.eq_on.symm)
#align local_equiv.eq_on_source.symm' LocalEquiv.EqOnSource.symm'
-/

#print LocalEquiv.EqOnSource.symm_eqOn /-
/-- Two equivalent local equivs have coinciding inverses on the target -/
theorem EqOnSource.symm_eqOn {e e' : LocalEquiv α β} (h : e ≈ e') : EqOn e.symm e'.symm e.target :=
  h.symm'.EqOn
#align local_equiv.eq_on_source.symm_eq_on LocalEquiv.EqOnSource.symm_eqOn
-/

#print LocalEquiv.EqOnSource.trans' /-
/-- Composition of local equivs respects equivalence -/
theorem EqOnSource.trans' {e e' : LocalEquiv α β} {f f' : LocalEquiv β γ} (he : e ≈ e')
    (hf : f ≈ f') : e.trans f ≈ e'.trans f' :=
  by
  constructor
  · rw [trans_source'', trans_source'', ← he.target_eq, ← hf.1]
    exact (he.symm'.eq_on.mono <| inter_subset_left _ _).image_eq
  · intro x hx
    rw [trans_source] at hx 
    simp [(he.2 hx.1).symm, hf.2 hx.2]
#align local_equiv.eq_on_source.trans' LocalEquiv.EqOnSource.trans'
-/

#print LocalEquiv.EqOnSource.restr /-
/-- Restriction of local equivs respects equivalence -/
theorem EqOnSource.restr {e e' : LocalEquiv α β} (he : e ≈ e') (s : Set α) :
    e.restr s ≈ e'.restr s := by
  constructor
  · simp [he.1]
  · intro x hx
    simp only [mem_inter_iff, restr_source] at hx 
    exact he.2 hx.1
#align local_equiv.eq_on_source.restr LocalEquiv.EqOnSource.restr
-/

#print LocalEquiv.EqOnSource.source_inter_preimage_eq /-
/-- Preimages are respected by equivalence -/
theorem EqOnSource.source_inter_preimage_eq {e e' : LocalEquiv α β} (he : e ≈ e') (s : Set β) :
    e.source ∩ e ⁻¹' s = e'.source ∩ e' ⁻¹' s := by rw [he.eq_on.inter_preimage_eq, he.source_eq]
#align local_equiv.eq_on_source.source_inter_preimage_eq LocalEquiv.EqOnSource.source_inter_preimage_eq
-/

#print LocalEquiv.trans_self_symm /-
/-- Composition of a local equiv and its inverse is equivalent to the restriction of the identity
to the source -/
theorem trans_self_symm : e.trans e.symm ≈ LocalEquiv.ofSet e.source :=
  by
  have A : (e.trans e.symm).source = e.source := by mfld_set_tac
  refine' ⟨by simp [A], fun x hx => _⟩
  rw [A] at hx 
  simp only [hx, mfld_simps]
#align local_equiv.trans_self_symm LocalEquiv.trans_self_symm
-/

#print LocalEquiv.trans_symm_self /-
/-- Composition of the inverse of a local equiv and this local equiv is equivalent to the
restriction of the identity to the target -/
theorem trans_symm_self : e.symm.trans e ≈ LocalEquiv.ofSet e.target :=
  trans_self_symm e.symm
#align local_equiv.trans_symm_self LocalEquiv.trans_symm_self
-/

#print LocalEquiv.eq_of_eq_on_source_univ /-
/-- Two equivalent local equivs are equal when the source and target are univ -/
theorem eq_of_eq_on_source_univ (e e' : LocalEquiv α β) (h : e ≈ e') (s : e.source = univ)
    (t : e.target = univ) : e = e' :=
  by
  apply LocalEquiv.ext (fun x => _) (fun x => _) h.1
  · apply h.2
    rw [s]
    exact mem_univ _
  · apply h.symm'.2
    rw [symm_source, t]
    exact mem_univ _
#align local_equiv.eq_of_eq_on_source_univ LocalEquiv.eq_of_eq_on_source_univ
-/

section Prod

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print LocalEquiv.prod /-
/-- The product of two local equivs, as a local equiv on the product. -/
def prod (e : LocalEquiv α β) (e' : LocalEquiv γ δ) : LocalEquiv (α × γ) (β × δ)
    where
  source := e.source ×ˢ e'.source
  target := e.target ×ˢ e'.target
  toFun p := (e p.1, e' p.2)
  invFun p := (e.symm p.1, e'.symm p.2)
  map_source' p hp := by simp at hp ; simp [hp]
  map_target' p hp := by simp at hp ; simp [map_target, hp]
  left_inv' p hp := by simp at hp ; simp [hp]
  right_inv' p hp := by simp at hp ; simp [hp]
#align local_equiv.prod LocalEquiv.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print LocalEquiv.prod_source /-
@[simp, mfld_simps]
theorem prod_source (e : LocalEquiv α β) (e' : LocalEquiv γ δ) :
    (e.Prod e').source = e.source ×ˢ e'.source :=
  rfl
#align local_equiv.prod_source LocalEquiv.prod_source
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print LocalEquiv.prod_target /-
@[simp, mfld_simps]
theorem prod_target (e : LocalEquiv α β) (e' : LocalEquiv γ δ) :
    (e.Prod e').target = e.target ×ˢ e'.target :=
  rfl
#align local_equiv.prod_target LocalEquiv.prod_target
-/

#print LocalEquiv.prod_coe /-
@[simp, mfld_simps]
theorem prod_coe (e : LocalEquiv α β) (e' : LocalEquiv γ δ) :
    (e.Prod e' : α × γ → β × δ) = fun p => (e p.1, e' p.2) :=
  rfl
#align local_equiv.prod_coe LocalEquiv.prod_coe
-/

#print LocalEquiv.prod_coe_symm /-
theorem prod_coe_symm (e : LocalEquiv α β) (e' : LocalEquiv γ δ) :
    ((e.Prod e').symm : β × δ → α × γ) = fun p => (e.symm p.1, e'.symm p.2) :=
  rfl
#align local_equiv.prod_coe_symm LocalEquiv.prod_coe_symm
-/

#print LocalEquiv.prod_symm /-
@[simp, mfld_simps]
theorem prod_symm (e : LocalEquiv α β) (e' : LocalEquiv γ δ) :
    (e.Prod e').symm = e.symm.Prod e'.symm := by ext x <;> simp [prod_coe_symm]
#align local_equiv.prod_symm LocalEquiv.prod_symm
-/

#print LocalEquiv.refl_prod_refl /-
@[simp, mfld_simps]
theorem refl_prod_refl : (LocalEquiv.refl α).Prod (LocalEquiv.refl β) = LocalEquiv.refl (α × β) :=
  by ext1 ⟨x, y⟩; · rfl; · rintro ⟨x, y⟩; rfl; exact univ_prod_univ
#align local_equiv.refl_prod_refl LocalEquiv.refl_prod_refl
-/

#print LocalEquiv.prod_trans /-
@[simp, mfld_simps]
theorem prod_trans {η : Type _} {ε : Type _} (e : LocalEquiv α β) (f : LocalEquiv β γ)
    (e' : LocalEquiv δ η) (f' : LocalEquiv η ε) :
    (e.Prod e').trans (f.Prod f') = (e.trans f).Prod (e'.trans f') := by
  ext x <;> simp [ext_iff] <;> tauto
#align local_equiv.prod_trans LocalEquiv.prod_trans
-/

end Prod

#print LocalEquiv.piecewise /-
/-- Combine two `local_equiv`s using `set.piecewise`. The source of the new `local_equiv` is
`s.ite e.source e'.source = e.source ∩ s ∪ e'.source \ s`, and similarly for target.  The function
sends `e.source ∩ s` to `e.target ∩ t` using `e` and `e'.source \ s` to `e'.target \ t` using `e'`,
and similarly for the inverse function. The definition assumes `e.is_image s t` and
`e'.is_image s t`. -/
@[simps (config := { fullyApplied := false })]
def piecewise (e e' : LocalEquiv α β) (s : Set α) (t : Set β) [∀ x, Decidable (x ∈ s)]
    [∀ y, Decidable (y ∈ t)] (H : e.IsImage s t) (H' : e'.IsImage s t) : LocalEquiv α β
    where
  toFun := s.piecewise e e'
  invFun := t.piecewise e.symm e'.symm
  source := s.ite e.source e'.source
  target := t.ite e.target e'.target
  map_source' := H.MapsTo.piecewise_ite H'.compl.MapsTo
  map_target' := H.symm.MapsTo.piecewise_ite H'.symm.compl.MapsTo
  left_inv' := H.leftInvOn_piecewise H'
  right_inv' := H.symm.leftInvOn_piecewise H'.symm
#align local_equiv.piecewise LocalEquiv.piecewise
-/

#print LocalEquiv.symm_piecewise /-
theorem symm_piecewise (e e' : LocalEquiv α β) {s : Set α} {t : Set β} [∀ x, Decidable (x ∈ s)]
    [∀ y, Decidable (y ∈ t)] (H : e.IsImage s t) (H' : e'.IsImage s t) :
    (e.piecewise e' s t H H').symm = e.symm.piecewise e'.symm t s H.symm H'.symm :=
  rfl
#align local_equiv.symm_piecewise LocalEquiv.symm_piecewise
-/

#print LocalEquiv.disjointUnion /-
/-- Combine two `local_equiv`s with disjoint sources and disjoint targets. We reuse
`local_equiv.piecewise`, then override `source` and `target` to ensure better definitional
equalities. -/
@[simps (config := { fullyApplied := false })]
def disjointUnion (e e' : LocalEquiv α β) (hs : Disjoint e.source e'.source)
    (ht : Disjoint e.target e'.target) [∀ x, Decidable (x ∈ e.source)]
    [∀ y, Decidable (y ∈ e.target)] : LocalEquiv α β :=
  (e.piecewise e' e.source e.target e.isImage_source_target <|
        e'.isImage_source_target_of_disjoint _ hs.symm ht.symm).copy
    _ rfl _ rfl (e.source ∪ e'.source) (ite_left _ _) (e.target ∪ e'.target) (ite_left _ _)
#align local_equiv.disjoint_union LocalEquiv.disjointUnion
-/

#print LocalEquiv.disjointUnion_eq_piecewise /-
theorem disjointUnion_eq_piecewise (e e' : LocalEquiv α β) (hs : Disjoint e.source e'.source)
    (ht : Disjoint e.target e'.target) [∀ x, Decidable (x ∈ e.source)]
    [∀ y, Decidable (y ∈ e.target)] :
    e.disjointUnion e' hs ht =
      e.piecewise e' e.source e.target e.isImage_source_target
        (e'.isImage_source_target_of_disjoint _ hs.symm ht.symm) :=
  copy_eq _ _ _ _ _ _ _ _ _
#align local_equiv.disjoint_union_eq_piecewise LocalEquiv.disjointUnion_eq_piecewise
-/

section Pi

variable {ι : Type _} {αi βi : ι → Type _} (ei : ∀ i, LocalEquiv (αi i) (βi i))

#print LocalEquiv.pi /-
/-- The product of a family of local equivs, as a local equiv on the pi type. -/
@[simps (config := mfld_cfg)]
protected def pi : LocalEquiv (∀ i, αi i) (∀ i, βi i)
    where
  toFun f i := ei i (f i)
  invFun f i := (ei i).symm (f i)
  source := pi univ fun i => (ei i).source
  target := pi univ fun i => (ei i).target
  map_source' f hf i hi := (ei i).map_source (hf i hi)
  map_target' f hf i hi := (ei i).map_target (hf i hi)
  left_inv' f hf := funext fun i => (ei i).left_inv (hf i trivial)
  right_inv' f hf := funext fun i => (ei i).right_inv (hf i trivial)
#align local_equiv.pi LocalEquiv.pi
-/

end Pi

end LocalEquiv

namespace Set

#print Set.BijOn.toLocalEquiv /-
-- All arguments are explicit to avoid missing information in the pretty printer output
/-- A bijection between two sets `s : set α` and `t : set β` provides a local equivalence
between `α` and `β`. -/
@[simps (config := { fullyApplied := false })]
noncomputable def BijOn.toLocalEquiv [Nonempty α] (f : α → β) (s : Set α) (t : Set β)
    (hf : BijOn f s t) : LocalEquiv α β where
  toFun := f
  invFun := invFunOn f s
  source := s
  target := t
  map_source' := hf.MapsTo
  map_target' := hf.SurjOn.mapsTo_invFunOn
  left_inv' := hf.invOn_invFunOn.1
  right_inv' := hf.invOn_invFunOn.2
#align set.bij_on.to_local_equiv Set.BijOn.toLocalEquiv
-/

#print Set.InjOn.toLocalEquiv /-
/-- A map injective on a subset of its domain provides a local equivalence. -/
@[simp, mfld_simps]
noncomputable def InjOn.toLocalEquiv [Nonempty α] (f : α → β) (s : Set α) (hf : InjOn f s) :
    LocalEquiv α β :=
  hf.bijOn_image.toLocalEquiv f s (f '' s)
#align set.inj_on.to_local_equiv Set.InjOn.toLocalEquiv
-/

end Set

namespace Equiv

/- equivs give rise to local_equiv. We set up simp lemmas to reduce most properties of the local
equiv to that of the equiv. -/
variable (e : α ≃ β) (e' : β ≃ γ)

#print Equiv.refl_toLocalEquiv /-
@[simp, mfld_simps]
theorem refl_toLocalEquiv : (Equiv.refl α).toLocalEquiv = LocalEquiv.refl α :=
  rfl
#align equiv.refl_to_local_equiv Equiv.refl_toLocalEquiv
-/

#print Equiv.symm_toLocalEquiv /-
@[simp, mfld_simps]
theorem symm_toLocalEquiv : e.symm.toLocalEquiv = e.toLocalEquiv.symm :=
  rfl
#align equiv.symm_to_local_equiv Equiv.symm_toLocalEquiv
-/

#print Equiv.trans_toLocalEquiv /-
@[simp, mfld_simps]
theorem trans_toLocalEquiv : (e.trans e').toLocalEquiv = e.toLocalEquiv.trans e'.toLocalEquiv :=
  LocalEquiv.ext (fun x => rfl) (fun x => rfl)
    (by simp [LocalEquiv.trans_source, Equiv.toLocalEquiv])
#align equiv.trans_to_local_equiv Equiv.trans_toLocalEquiv
-/

end Equiv

