/-
Copyright (c) 2018 Kevin Buzzard, Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard, Patrick Massot

This file is to a certain extent based on `quotient_module.lean` by Johannes Hölzl.
-/
import Mathbin.GroupTheory.Congruence
import Mathbin.GroupTheory.Coset
import Mathbin.GroupTheory.Subgroup.Pointwise

/-!
# Quotients of groups by normal subgroups

This files develops the basic theory of quotients of groups by normal subgroups. In particular it
proves Noether's first and second isomorphism theorems.

## Main definitions

* `mk'`: the canonical group homomorphism `G →* G/N` given a normal subgroup `N` of `G`.
* `lift φ`: the group homomorphism `G/N →* H` given a group homomorphism `φ : G →* H` such that
  `N ⊆ ker φ`.
* `map f`: the group homomorphism `G/N →* H/M` given a group homomorphism `f : G →* H` such that
  `N ⊆ f⁻¹(M)`.

## Main statements

* `quotient_ker_equiv_range`: Noether's first isomorphism theorem, an explicit isomorphism
  `G/ker φ → range φ` for every group homomorphism `φ : G →* H`.
* `quotient_inf_equiv_prod_normal_quotient`: Noether's second isomorphism theorem, an explicit
  isomorphism between `H/(H ∩ N)` and `(HN)/N` given a subgroup `H` and a normal subgroup `N` of a
  group `G`.
* `quotient_group.quotient_quotient_equiv_quotient`: Noether's third isomorphism theorem,
  the canonical isomorphism between `(G / N) / (M / N)` and `G / M`, where `N ≤ M`.

## Tags

isomorphism theorems, quotient groups
-/


universe u v

namespace QuotientGroup

variable {G : Type u} [Group G] (N : Subgroup G) [nN : N.Normal] {H : Type v} [Group H]

include nN

/-- The congruence relation generated by a normal subgroup. -/
@[to_additive "The additive congruence relation generated by a normal additive subgroup."]
protected def con : Con G where 
  toSetoid := leftRel N
  mul' a b c d hab hcd := by 
    rw [left_rel_eq] at hab hcd⊢
    calc
      (a * c)⁻¹ * (b * d) = c⁻¹ * (a⁻¹ * b) * c⁻¹⁻¹ * (c⁻¹ * d) := by
        simp only [mul_inv_rev, mul_assoc, inv_mul_cancel_left]
      _ ∈ N := N.mul_mem (nN.conj_mem _ hab _) hcd
      
#align quotient_group.con QuotientGroup.con

@[to_additive QuotientAddGroup.addGroup]
instance Quotient.group : Group (G ⧸ N) :=
  (QuotientGroup.con N).Group
#align quotient_group.quotient.group QuotientGroup.Quotient.group

/-- The group homomorphism from `G` to `G/N`. -/
@[to_additive QuotientAddGroup.mk' "The additive group homomorphism from `G` to `G/N`."]
def mk' : G →* G ⧸ N :=
  MonoidHom.mk' QuotientGroup.mk fun _ _ => rfl
#align quotient_group.mk' QuotientGroup.mk'

@[simp, to_additive]
theorem coe_mk' : (mk' N : G → G ⧸ N) = coe :=
  rfl
#align quotient_group.coe_mk' QuotientGroup.coe_mk'

@[simp, to_additive]
theorem mk'_apply (x : G) : mk' N x = x :=
  rfl
#align quotient_group.mk'_apply QuotientGroup.mk'_apply

@[to_additive]
theorem mk'_surjective : Function.Surjective <| mk' N :=
  @mk_surjective _ _ N
#align quotient_group.mk'_surjective QuotientGroup.mk'_surjective

@[to_additive]
theorem mk'_eq_mk' {x y : G} : mk' N x = mk' N y ↔ ∃ z ∈ N, x * z = y :=
  QuotientGroup.eq'.trans <| by
    simp only [← _root_.eq_inv_mul_iff_mul_eq, exists_prop, exists_eq_right]
#align quotient_group.mk'_eq_mk' QuotientGroup.mk'_eq_mk'

/-- Two `monoid_hom`s from a quotient group are equal if their compositions with
`quotient_group.mk'` are equal.

See note [partially-applied ext lemmas]. -/
@[ext,
  to_additive
      " Two `add_monoid_hom`s from an additive quotient group are equal if their\ncompositions with `add_quotient_group.mk'` are equal.\n\nSee note [partially-applied ext lemmas]. "]
theorem monoid_hom_ext ⦃f g : G ⧸ N →* H⦄ (h : f.comp (mk' N) = g.comp (mk' N)) : f = g :=
  MonoidHom.ext fun x => QuotientGroup.induction_on x <| (MonoidHom.congr_fun h : _)
#align quotient_group.monoid_hom_ext QuotientGroup.monoid_hom_ext

@[simp, to_additive QuotientAddGroup.eq_zero_iff]
theorem eq_one_iff {N : Subgroup G} [nN : N.Normal] (x : G) : (x : G ⧸ N) = 1 ↔ x ∈ N := by
  refine' quotient_group.eq.trans _
  rw [mul_one, Subgroup.inv_mem_iff]
#align quotient_group.eq_one_iff QuotientGroup.eq_one_iff

@[simp, to_additive QuotientAddGroup.ker_mk]
theorem ker_mk : MonoidHom.ker (QuotientGroup.mk' N : G →* G ⧸ N) = N :=
  Subgroup.ext eq_one_iff
#align quotient_group.ker_mk QuotientGroup.ker_mk

@[to_additive QuotientAddGroup.eq_iff_sub_mem]
theorem eq_iff_div_mem {N : Subgroup G} [nN : N.Normal] {x y : G} : (x : G ⧸ N) = y ↔ x / y ∈ N :=
  by 
  refine' eq_comm.trans (quotient_group.eq.trans _)
  rw [nN.mem_comm_iff, div_eq_mul_inv]
#align quotient_group.eq_iff_div_mem QuotientGroup.eq_iff_div_mem

-- for commutative groups we don't need normality assumption
omit nN

@[to_additive QuotientAddGroup.addCommGroup]
instance {G : Type _} [CommGroup G] (N : Subgroup G) : CommGroup (G ⧸ N) :=
  { @QuotientGroup.Quotient.group _ _ N N.normal_of_comm with
    mul_comm := fun a b => Quotient.inductionOn₂' a b fun a b => congr_arg mk (mul_comm a b) }

include nN

-- mathport name: exprQ
local notation " Q " => G ⧸ N

@[simp, to_additive QuotientAddGroup.coe_zero]
theorem coe_one : ((1 : G) : Q ) = 1 :=
  rfl
#align quotient_group.coe_one QuotientGroup.coe_one

@[simp, to_additive QuotientAddGroup.coe_add]
theorem coe_mul (a b : G) : ((a * b : G) : Q ) = a * b :=
  rfl
#align quotient_group.coe_mul QuotientGroup.coe_mul

@[simp, to_additive QuotientAddGroup.coe_neg]
theorem coe_inv (a : G) : ((a⁻¹ : G) : Q ) = a⁻¹ :=
  rfl
#align quotient_group.coe_inv QuotientGroup.coe_inv

@[simp, to_additive QuotientAddGroup.coe_sub]
theorem coe_div (a b : G) : ((a / b : G) : Q ) = a / b :=
  rfl
#align quotient_group.coe_div QuotientGroup.coe_div

@[simp, to_additive QuotientAddGroup.coe_nsmul]
theorem coe_pow (a : G) (n : ℕ) : ((a ^ n : G) : Q ) = a ^ n :=
  rfl
#align quotient_group.coe_pow QuotientGroup.coe_pow

@[simp, to_additive QuotientAddGroup.coe_zsmul]
theorem coe_zpow (a : G) (n : ℤ) : ((a ^ n : G) : Q ) = a ^ n :=
  rfl
#align quotient_group.coe_zpow QuotientGroup.coe_zpow

/-- A group homomorphism `φ : G →* H` with `N ⊆ ker(φ)` descends (i.e. `lift`s) to a
group homomorphism `G/N →* H`. -/
@[to_additive QuotientAddGroup.lift
      "An `add_group` homomorphism `φ : G →+ H` with `N ⊆ ker(φ)`\ndescends (i.e. `lift`s) to a group homomorphism `G/N →* H`."]
def lift (φ : G →* H) (HN : ∀ x ∈ N, φ x = 1) : Q →* H :=
  ((QuotientGroup.con N).lift φ) fun x y h => by
    simp only [QuotientGroup.con, left_rel_apply, Con.rel_mk] at h
    calc
      φ x = φ (y * (x⁻¹ * y)⁻¹) := by rw [mul_inv_rev, inv_inv, mul_inv_cancel_left]
      _ = φ y := by rw [φ.map_mul, HN _ (N.inv_mem h), mul_one]
      
#align quotient_group.lift QuotientGroup.lift

@[simp, to_additive QuotientAddGroup.lift_mk]
theorem lift_mk {φ : G →* H} (HN : ∀ x ∈ N, φ x = 1) (g : G) : lift N φ HN (g : Q ) = φ g :=
  rfl
#align quotient_group.lift_mk QuotientGroup.lift_mk

@[simp, to_additive QuotientAddGroup.lift_mk']
theorem lift_mk' {φ : G →* H} (HN : ∀ x ∈ N, φ x = 1) (g : G) : lift N φ HN (mk g : Q ) = φ g :=
  rfl
#align quotient_group.lift_mk' QuotientGroup.lift_mk'

@[simp, to_additive QuotientAddGroup.lift_quot_mk]
theorem lift_quot_mk {φ : G →* H} (HN : ∀ x ∈ N, φ x = 1) (g : G) :
    lift N φ HN (Quot.mk _ g : Q ) = φ g :=
  rfl
#align quotient_group.lift_quot_mk QuotientGroup.lift_quot_mk

/-- A group homomorphism `f : G →* H` induces a map `G/N →* H/M` if `N ⊆ f⁻¹(M)`. -/
@[to_additive QuotientAddGroup.map
      "An `add_group` homomorphism `f : G →+ H` induces a map\n`G/N →+ H/M` if `N ⊆ f⁻¹(M)`."]
def map (M : Subgroup H) [M.Normal] (f : G →* H) (h : N ≤ M.comap f) : G ⧸ N →* H ⧸ M := by
  refine' QuotientGroup.lift N ((mk' M).comp f) _
  intro x hx
  refine' QuotientGroup.eq.2 _
  rw [mul_one, Subgroup.inv_mem_iff]
  exact h hx
#align quotient_group.map QuotientGroup.map

@[simp, to_additive QuotientAddGroup.map_coe]
theorem map_coe (M : Subgroup H) [M.Normal] (f : G →* H) (h : N ≤ M.comap f) (x : G) :
    map N M f h ↑x = ↑(f x) :=
  lift_mk' _ _ x
#align quotient_group.map_coe QuotientGroup.map_coe

@[to_additive QuotientAddGroup.map_mk']
theorem map_mk' (M : Subgroup H) [M.Normal] (f : G →* H) (h : N ≤ M.comap f) (x : G) :
    map N M f h (mk' _ x) = ↑(f x) :=
  QuotientGroup.lift_mk' _ _ x
#align quotient_group.map_mk' QuotientGroup.map_mk'

@[to_additive]
theorem map_id_apply (h : N ≤ Subgroup.comap (MonoidHom.id _) N := (Subgroup.comap_id N).le) (x) :
    map N N (MonoidHom.id _) h x = x := by
  refine' induction_on' x fun x => _
  simp only [map_coe, MonoidHom.id_apply]
#align quotient_group.map_id_apply QuotientGroup.map_id_apply

@[simp, to_additive]
theorem map_id (h : N ≤ Subgroup.comap (MonoidHom.id _) N := (Subgroup.comap_id N).le) :
    map N N (MonoidHom.id _) h = MonoidHom.id _ :=
  MonoidHom.ext (map_id_apply N h)
#align quotient_group.map_id QuotientGroup.map_id

@[simp, to_additive]
theorem map_map {I : Type _} [Group I] (M : Subgroup H) (O : Subgroup I) [M.Normal] [O.Normal]
    (f : G →* H) (g : H →* I) (hf : N ≤ Subgroup.comap f M) (hg : M ≤ Subgroup.comap g O)
    (hgf : N ≤ Subgroup.comap (g.comp f) O :=
      hf.trans ((Subgroup.comap_mono hg).trans_eq (Subgroup.comap_comap _ _ _)))
    (x : G ⧸ N) : map M O g hg (map N M f hf x) = map N O (g.comp f) hgf x := by
  refine' induction_on' x fun x => _
  simp only [map_coe, MonoidHom.comp_apply]
#align quotient_group.map_map QuotientGroup.map_map

@[simp, to_additive]
theorem map_comp_map {I : Type _} [Group I] (M : Subgroup H) (O : Subgroup I) [M.Normal] [O.Normal]
    (f : G →* H) (g : H →* I) (hf : N ≤ Subgroup.comap f M) (hg : M ≤ Subgroup.comap g O)
    (hgf : N ≤ Subgroup.comap (g.comp f) O :=
      hf.trans ((Subgroup.comap_mono hg).trans_eq (Subgroup.comap_comap _ _ _))) :
    (map M O g hg).comp (map N M f hf) = map N O (g.comp f) hgf :=
  MonoidHom.ext (map_map N M O f g hf hg hgf)
#align quotient_group.map_comp_map QuotientGroup.map_comp_map

omit nN

section congr

variable (G' : Subgroup G) (H' : Subgroup H) [Subgroup.Normal G'] [Subgroup.Normal H']

/-- `quotient_group.congr` lifts the isomorphism `e : G ≃ H` to `G ⧸ G' ≃ H ⧸ H'`,
given that `e` maps `G` to `H`. -/
@[to_additive
      "`quotient_add_group.congr` lifts the isomorphism `e : G ≃ H` to `G ⧸ G' ≃ H ⧸ H'`,\ngiven that `e` maps `G` to `H`."]
def congr (e : G ≃* H) (he : G'.map ↑e = H') : G ⧸ G' ≃* H ⧸ H' :=
  { -- `simp` doesn't like this lemma...
      -- `simp` doesn't like this lemma...
      map
      G' H' (↑e) (he ▸ G'.le_comap_map e) with
    toFun := map G' H' (↑e) (he ▸ G'.le_comap_map e),
    invFun := map H' G' (↑e.symm) (he ▸ (G'.map_equiv_eq_comap_symm e).le),
    left_inv := fun x => by
      rw [map_map] <;>
        simp only [map_map, ← MulEquiv.coe_monoid_hom_trans, MulEquiv.self_trans_symm,
          MulEquiv.coe_monoid_hom_refl, map_id_apply],
    right_inv := fun x => by
      rw [map_map] <;>
        simp only [← MulEquiv.coe_monoid_hom_trans, MulEquiv.symm_trans_self,
          MulEquiv.coe_monoid_hom_refl, map_id_apply] }
#align quotient_group.congr QuotientGroup.congr

@[simp]
theorem congr_mk (e : G ≃* H) (he : G'.map ↑e = H') (x) : congr G' H' e he (mk x) = e x :=
  map_mk' G' _ _ (he ▸ G'.le_comap_map e) _
#align quotient_group.congr_mk QuotientGroup.congr_mk

theorem congr_mk' (e : G ≃* H) (he : G'.map ↑e = H') (x) :
    congr G' H' e he (mk' G' x) = mk' H' (e x) :=
  map_mk' G' _ _ (he ▸ G'.le_comap_map e) _
#align quotient_group.congr_mk' QuotientGroup.congr_mk'

@[simp]
theorem congr_apply (e : G ≃* H) (he : G'.map ↑e = H') (x : G) :
    congr G' H' e he x = mk' H' (e x) :=
  map_mk' G' _ _ (he ▸ G'.le_comap_map e) _
#align quotient_group.congr_apply QuotientGroup.congr_apply

@[simp]
theorem congr_refl (he : G'.map (MulEquiv.refl G : G →* G) = G' := Subgroup.map_id G') :
    congr G' G' (MulEquiv.refl G) he = MulEquiv.refl (G ⧸ G') := by
  ext x <;> refine' induction_on' x fun x' => _ <;> simp
#align quotient_group.congr_refl QuotientGroup.congr_refl

@[simp]
theorem congr_symm (e : G ≃* H) (he : G'.map ↑e = H') :
    (congr G' H' e he).symm = congr H' G' e.symm ((Subgroup.map_symm_eq_iff_map_eq _).mpr he) :=
  rfl
#align quotient_group.congr_symm QuotientGroup.congr_symm

end congr

variable (φ : G →* H)

open Function MonoidHom

/-- The induced map from the quotient by the kernel to the codomain. -/
@[to_additive QuotientAddGroup.kerLift
      "The induced map from the quotient by the kernel to the\ncodomain."]
def kerLift : G ⧸ ker φ →* H :=
  (lift _ φ) fun g => φ.mem_ker.mp
#align quotient_group.ker_lift QuotientGroup.kerLift

@[simp, to_additive QuotientAddGroup.ker_lift_mk]
theorem ker_lift_mk (g : G) : (kerLift φ) g = φ g :=
  lift_mk _ _ _
#align quotient_group.ker_lift_mk QuotientGroup.ker_lift_mk

@[simp, to_additive QuotientAddGroup.ker_lift_mk']
theorem ker_lift_mk' (g : G) : (kerLift φ) (mk g) = φ g :=
  lift_mk' _ _ _
#align quotient_group.ker_lift_mk' QuotientGroup.ker_lift_mk'

@[to_additive QuotientAddGroup.ker_lift_injective]
theorem ker_lift_injective : Injective (kerLift φ) := fun a b =>
  (Quotient.inductionOn₂' a b) fun a b (h : φ a = φ b) =>
    Quotient.sound' <| by rw [left_rel_apply, mem_ker, φ.map_mul, ← h, φ.map_inv, inv_mul_self]
#align quotient_group.ker_lift_injective QuotientGroup.ker_lift_injective

-- Note that `ker φ` isn't definitionally `ker (φ.range_restrict)`
-- so there is a bit of annoying code duplication here
/-- The induced map from the quotient by the kernel to the range. -/
@[to_additive QuotientAddGroup.rangeKerLift
      "The induced map from the quotient by the kernel to\nthe range."]
def rangeKerLift : G ⧸ ker φ →* φ.range :=
  (lift _ φ.range_restrict) fun g hg => (mem_ker _).mp <| by rwa [ker_range_restrict]
#align quotient_group.range_ker_lift QuotientGroup.rangeKerLift

@[to_additive QuotientAddGroup.range_ker_lift_injective]
theorem range_ker_lift_injective : Injective (rangeKerLift φ) := fun a b =>
  (Quotient.inductionOn₂' a b) fun a b (h : φ.range_restrict a = φ.range_restrict b) =>
    Quotient.sound' <| by
      rw [left_rel_apply, ← ker_range_restrict, mem_ker, φ.range_restrict.map_mul, ← h,
        φ.range_restrict.map_inv, inv_mul_self]
#align quotient_group.range_ker_lift_injective QuotientGroup.range_ker_lift_injective

@[to_additive QuotientAddGroup.range_ker_lift_surjective]
theorem range_ker_lift_surjective : Surjective (rangeKerLift φ) := by
  rintro ⟨_, g, rfl⟩
  use mk g
  rfl
#align quotient_group.range_ker_lift_surjective QuotientGroup.range_ker_lift_surjective

/-- **Noether's first isomorphism theorem** (a definition): the canonical isomorphism between
`G/(ker φ)` to `range φ`. -/
@[to_additive QuotientAddGroup.quotientKerEquivRange
      "The first isomorphism theorem\n(a definition): the canonical isomorphism between `G/(ker φ)` to `range φ`."]
noncomputable def quotientKerEquivRange : G ⧸ ker φ ≃* range φ :=
  MulEquiv.ofBijective (rangeKerLift φ) ⟨range_ker_lift_injective φ, range_ker_lift_surjective φ⟩
#align quotient_group.quotient_ker_equiv_range QuotientGroup.quotientKerEquivRange

/-- The canonical isomorphism `G/(ker φ) ≃* H` induced by a homomorphism `φ : G →* H`
with a right inverse `ψ : H → G`. -/
@[to_additive QuotientAddGroup.quotientKerEquivOfRightInverse
      "The canonical isomorphism\n`G/(ker φ) ≃+ H` induced by a homomorphism `φ : G →+ H` with a right inverse `ψ : H → G`.",
  simps]
def quotientKerEquivOfRightInverse (ψ : H → G) (hφ : Function.RightInverse ψ φ) : G ⧸ ker φ ≃* H :=
  { kerLift φ with toFun := kerLift φ, invFun := mk ∘ ψ,
    left_inv := fun x => ker_lift_injective φ (by rw [Function.comp_apply, ker_lift_mk', hφ]),
    right_inv := hφ }
#align
  quotient_group.quotient_ker_equiv_of_right_inverse QuotientGroup.quotientKerEquivOfRightInverse

/-- The canonical isomorphism `G/⊥ ≃* G`. -/
@[to_additive QuotientAddGroup.quotientBot "The canonical isomorphism `G/⊥ ≃+ G`.", simps]
def quotientBot : G ⧸ (⊥ : Subgroup G) ≃* G :=
  quotientKerEquivOfRightInverse (MonoidHom.id G) id fun x => rfl
#align quotient_group.quotient_bot QuotientGroup.quotientBot

/-- The canonical isomorphism `G/(ker φ) ≃* H` induced by a surjection `φ : G →* H`.

For a `computable` version, see `quotient_group.quotient_ker_equiv_of_right_inverse`.
-/
@[to_additive QuotientAddGroup.quotientKerEquivOfSurjective
      "The canonical isomorphism\n`G/(ker φ) ≃+ H` induced by a surjection `φ : G →+ H`.\n\nFor a `computable` version, see `quotient_add_group.quotient_ker_equiv_of_right_inverse`."]
noncomputable def quotientKerEquivOfSurjective (hφ : Function.Surjective φ) : G ⧸ ker φ ≃* H :=
  quotientKerEquivOfRightInverse φ _ hφ.HasRightInverse.some_spec
#align quotient_group.quotient_ker_equiv_of_surjective QuotientGroup.quotientKerEquivOfSurjective

/-- If two normal subgroups `M` and `N` of `G` are the same, their quotient groups are
isomorphic. -/
@[to_additive
      "If two normal subgroups `M` and `N` of `G` are the same, their quotient groups are\nisomorphic."]
def quotientMulEquivOfEq {M N : Subgroup G} [M.Normal] [N.Normal] (h : M = N) : G ⧸ M ≃* G ⧸ N :=
  { Subgroup.quotientEquivOfEq h with
    map_mul' := fun q r => Quotient.inductionOn₂' q r fun g h => rfl }
#align quotient_group.quotient_mul_equiv_of_eq QuotientGroup.quotientMulEquivOfEq

@[simp, to_additive]
theorem quotient_mul_equiv_of_eq_mk {M N : Subgroup G} [M.Normal] [N.Normal] (h : M = N) (x : G) :
    QuotientGroup.quotientMulEquivOfEq h (QuotientGroup.mk x) = QuotientGroup.mk x :=
  rfl
#align quotient_group.quotient_mul_equiv_of_eq_mk QuotientGroup.quotient_mul_equiv_of_eq_mk

/-- Let `A', A, B', B` be subgroups of `G`. If `A' ≤ B'` and `A ≤ B`,
then there is a map `A / (A' ⊓ A) →* B / (B' ⊓ B)` induced by the inclusions. -/
@[to_additive
      "Let `A', A, B', B` be subgroups of `G`. If `A' ≤ B'` and `A ≤ B`,\nthen there is a map `A / (A' ⊓ A) →+ B / (B' ⊓ B)` induced by the inclusions."]
def quotientMapSubgroupOfOfLe {A' A B' B : Subgroup G} [hAN : (A'.subgroupOf A).Normal]
    [hBN : (B'.subgroupOf B).Normal] (h' : A' ≤ B') (h : A ≤ B) :
    A ⧸ A'.subgroupOf A →* B ⧸ B'.subgroupOf B :=
  map _ _ (Subgroup.inclusion h) <| Subgroup.comap_mono h'
#align quotient_group.quotient_map_subgroup_of_of_le QuotientGroup.quotientMapSubgroupOfOfLe

@[simp, to_additive]
theorem quotient_map_subgroup_of_of_le_coe {A' A B' B : Subgroup G} [hAN : (A'.subgroupOf A).Normal]
    [hBN : (B'.subgroupOf B).Normal] (h' : A' ≤ B') (h : A ≤ B) (x : A) :
    quotientMapSubgroupOfOfLe h' h x = ↑(Subgroup.inclusion h x : B) :=
  rfl
#align
  quotient_group.quotient_map_subgroup_of_of_le_coe QuotientGroup.quotient_map_subgroup_of_of_le_coe

/-- Let `A', A, B', B` be subgroups of `G`.
If `A' = B'` and `A = B`, then the quotients `A / (A' ⊓ A)` and `B / (B' ⊓ B)` are isomorphic.

Applying this equiv is nicer than rewriting along the equalities, since the type of
`(A'.subgroup_of A : subgroup A)` depends on on `A`.
-/
@[to_additive
      "Let `A', A, B', B` be subgroups of `G`.\nIf `A' = B'` and `A = B`, then the quotients `A / (A' ⊓ A)` and `B / (B' ⊓ B)` are isomorphic.\n\nApplying this equiv is nicer than rewriting along the equalities, since the type of\n`(A'.add_subgroup_of A : add_subgroup A)` depends on on `A`.\n"]
def equivQuotientSubgroupOfOfEq {A' A B' B : Subgroup G} [hAN : (A'.subgroupOf A).Normal]
    [hBN : (B'.subgroupOf B).Normal] (h' : A' = B') (h : A = B) :
    A ⧸ A'.subgroupOf A ≃* B ⧸ B'.subgroupOf B :=
  MonoidHom.toMulEquiv (quotientMapSubgroupOfOfLe h'.le h.le) (quotientMapSubgroupOfOfLe h'.ge h.ge)
    (by 
      ext ⟨x, hx⟩
      rfl)
    (by 
      ext ⟨x, hx⟩
      rfl)
#align quotient_group.equiv_quotient_subgroup_of_of_eq QuotientGroup.equivQuotientSubgroupOfOfEq

section Zpow

variable {A B C : Type u} [CommGroup A] [CommGroup B] [CommGroup C]

variable (f : A →* B) (g : B →* A) (e : A ≃* B) (d : B ≃* C) (n : ℤ)

/-- The map of quotients by powers of an integer induced by a group homomorphism. -/
@[to_additive
      "The map of quotients by multiples of an integer induced by an additive group\nhomomorphism."]
def homQuotientZpowOfHom :
    A ⧸ (zpowGroupHom n : A →* A).range →* B ⧸ (zpowGroupHom n : B →* B).range :=
  (lift _ ((mk' _).comp f)) fun g ⟨h, (hg : h ^ n = g)⟩ =>
    (eq_one_iff _).mpr ⟨_, by simpa only [← hg, map_zpow] ⟩
#align quotient_group.hom_quotient_zpow_of_hom QuotientGroup.homQuotientZpowOfHom

@[simp, to_additive]
theorem hom_quotient_zpow_of_hom_id : homQuotientZpowOfHom (MonoidHom.id A) n = MonoidHom.id _ :=
  monoid_hom_ext _ rfl
#align quotient_group.hom_quotient_zpow_of_hom_id QuotientGroup.hom_quotient_zpow_of_hom_id

@[simp, to_additive]
theorem hom_quotient_zpow_of_hom_comp :
    homQuotientZpowOfHom (f.comp g) n =
      (homQuotientZpowOfHom f n).comp (homQuotientZpowOfHom g n) :=
  monoid_hom_ext _ rfl
#align quotient_group.hom_quotient_zpow_of_hom_comp QuotientGroup.hom_quotient_zpow_of_hom_comp

@[simp, to_additive]
theorem hom_quotient_zpow_of_hom_comp_of_right_inverse (i : Function.RightInverse g f) :
    (homQuotientZpowOfHom f n).comp (homQuotientZpowOfHom g n) = MonoidHom.id _ :=
  monoid_hom_ext _ <| MonoidHom.ext fun x => congr_arg coe <| i x
#align
  quotient_group.hom_quotient_zpow_of_hom_comp_of_right_inverse QuotientGroup.hom_quotient_zpow_of_hom_comp_of_right_inverse

/-- The equivalence of quotients by powers of an integer induced by a group isomorphism. -/
@[to_additive
      "The equivalence of quotients by multiples of an integer induced by an additive group\nisomorphism."]
def equivQuotientZpowOfEquiv :
    A ⧸ (zpowGroupHom n : A →* A).range ≃* B ⧸ (zpowGroupHom n : B →* B).range :=
  MonoidHom.toMulEquiv _ _ (hom_quotient_zpow_of_hom_comp_of_right_inverse e.symm e n e.left_inv)
    (hom_quotient_zpow_of_hom_comp_of_right_inverse e e.symm n e.right_inv)
#align quotient_group.equiv_quotient_zpow_of_equiv QuotientGroup.equivQuotientZpowOfEquiv

@[simp, to_additive]
theorem equiv_quotient_zpow_of_equiv_refl :
    MulEquiv.refl (A ⧸ (zpowGroupHom n : A →* A).range) =
      equivQuotientZpowOfEquiv (MulEquiv.refl A) n :=
  by 
  ext x
  rw [← Quotient.out_eq' x]
  rfl
#align
  quotient_group.equiv_quotient_zpow_of_equiv_refl QuotientGroup.equiv_quotient_zpow_of_equiv_refl

@[simp, to_additive]
theorem equiv_quotient_zpow_of_equiv_symm :
    (equivQuotientZpowOfEquiv e n).symm = equivQuotientZpowOfEquiv e.symm n :=
  rfl
#align
  quotient_group.equiv_quotient_zpow_of_equiv_symm QuotientGroup.equiv_quotient_zpow_of_equiv_symm

@[simp, to_additive]
theorem equiv_quotient_zpow_of_equiv_trans :
    (equivQuotientZpowOfEquiv e n).trans (equivQuotientZpowOfEquiv d n) =
      equivQuotientZpowOfEquiv (e.trans d) n :=
  by 
  ext x
  rw [← Quotient.out_eq' x]
  rfl
#align
  quotient_group.equiv_quotient_zpow_of_equiv_trans QuotientGroup.equiv_quotient_zpow_of_equiv_trans

end Zpow

section SndIsomorphismThm

open _Root_.Subgroup

/-- **Noether's second isomorphism theorem**: given two subgroups `H` and `N` of a group `G`, where
`N` is normal, defines an isomorphism between `H/(H ∩ N)` and `(HN)/N`. -/
@[to_additive
      "The second isomorphism theorem: given two subgroups `H` and `N` of a group `G`,\nwhere `N` is normal, defines an isomorphism between `H/(H ∩ N)` and `(H + N)/N`"]
noncomputable def quotientInfEquivProdNormalQuotient (H N : Subgroup G) [N.Normal] :
    H ⧸ N.subgroupOf H ≃* _ ⧸ N.subgroupOf (H ⊔ N) :=
  let
    φ :-- φ is the natural homomorphism H →* (HN)/N.
      H →*
      _ ⧸ N.subgroupOf (H ⊔ N) :=
    (mk' <| N.subgroupOf (H ⊔ N)).comp (inclusion le_sup_left)
  have φ_surjective : Function.Surjective φ := fun x =>
    x.inductionOn' <| by 
      rintro ⟨y, hy : y ∈ ↑(H ⊔ N)⟩; rw [mul_normal H N] at hy
      rcases hy with ⟨h, n, hh, hn, rfl⟩
      use h, hh; apply quotient.eq.mpr
      change Setoid.r _ _
      rw [left_rel_apply]
      change h⁻¹ * (h * n) ∈ N
      rwa [← mul_assoc, inv_mul_self, one_mul]
  (quotientMulEquivOfEq (by simp [← comap_ker])).trans (quotientKerEquivOfSurjective φ φ_surjective)
#align
  quotient_group.quotient_inf_equiv_prod_normal_quotient QuotientGroup.quotientInfEquivProdNormalQuotient

end SndIsomorphismThm

section ThirdIsoThm

variable (M : Subgroup G) [nM : M.Normal]

include nM nN

@[to_additive]
instance map_normal : (M.map (QuotientGroup.mk' N)).Normal :=
  nM.map _ mk_surjective
#align quotient_group.map_normal QuotientGroup.map_normal

variable (h : N ≤ M)

/-- The map from the third isomorphism theorem for groups: `(G / N) / (M / N) → G / M`. -/
@[to_additive QuotientAddGroup.quotientQuotientEquivQuotientAux
      "The map from the third isomorphism theorem for additive groups: `(A / N) / (M / N) → A / M`."]
def quotientQuotientEquivQuotientAux : (G ⧸ N) ⧸ M.map (mk' N) →* G ⧸ M :=
  lift (M.map (mk' N)) (map N M (MonoidHom.id G) h)
    (by 
      rintro _ ⟨x, hx, rfl⟩
      rw [map_mk' N M _ _ x]
      exact (QuotientGroup.eq_one_iff _).mpr hx)
#align
  quotient_group.quotient_quotient_equiv_quotient_aux QuotientGroup.quotientQuotientEquivQuotientAux

@[simp, to_additive QuotientAddGroup.quotient_quotient_equiv_quotient_aux_coe]
theorem quotient_quotient_equiv_quotient_aux_coe (x : G ⧸ N) :
    quotientQuotientEquivQuotientAux N M h x = QuotientGroup.map N M (MonoidHom.id G) h x :=
  QuotientGroup.lift_mk' _ _ x
#align
  quotient_group.quotient_quotient_equiv_quotient_aux_coe QuotientGroup.quotient_quotient_equiv_quotient_aux_coe

@[to_additive QuotientAddGroup.quotient_quotient_equiv_quotient_aux_coe_coe]
theorem quotient_quotient_equiv_quotient_aux_coe_coe (x : G) :
    quotientQuotientEquivQuotientAux N M h (x : G ⧸ N) = x :=
  QuotientGroup.lift_mk' _ _ x
#align
  quotient_group.quotient_quotient_equiv_quotient_aux_coe_coe QuotientGroup.quotient_quotient_equiv_quotient_aux_coe_coe

/-- **Noether's third isomorphism theorem** for groups: `(G / N) / (M / N) ≃ G / M`. -/
@[to_additive QuotientAddGroup.quotientQuotientEquivQuotient
      "**Noether's third isomorphism theorem** for additive groups: `(A / N) / (M / N) ≃ A / M`."]
def quotientQuotientEquivQuotient : (G ⧸ N) ⧸ M.map (QuotientGroup.mk' N) ≃* G ⧸ M :=
  MonoidHom.toMulEquiv (quotientQuotientEquivQuotientAux N M h)
    (QuotientGroup.map _ _ (QuotientGroup.mk' N) (Subgroup.le_comap_map _ _))
    (by 
      ext
      simp)
    (by 
      ext
      simp)
#align quotient_group.quotient_quotient_equiv_quotient QuotientGroup.quotientQuotientEquivQuotient

end ThirdIsoThm

section trivial

@[to_additive]
theorem subsingleton_quotient_top : Subsingleton (G ⧸ (⊤ : Subgroup G)) := by
  dsimp [HasQuotient.quotient, subgroup.has_quotient, Quotient]
  rw [left_rel_eq]
  exact @Trunc.subsingleton G
#align quotient_group.subsingleton_quotient_top QuotientGroup.subsingleton_quotient_top

/-- If the quotient by a subgroup gives a singleton then the subgroup is the whole group. -/
@[to_additive
      "If the quotient by an additive subgroup gives a singleton then the additive subgroup\nis the whole additive group."]
theorem subgroup_eq_top_of_subsingleton (H : Subgroup G) (h : Subsingleton (G ⧸ H)) : H = ⊤ :=
  top_unique fun x _ => by
    have this : 1⁻¹ * x ∈ H := QuotientGroup.eq.1 (Subsingleton.elim _ _)
    rwa [inv_one, one_mul] at this
#align quotient_group.subgroup_eq_top_of_subsingleton QuotientGroup.subgroup_eq_top_of_subsingleton

end trivial

@[to_additive QuotientAddGroup.comap_comap_center]
theorem comap_comap_center {H₁ : Subgroup G} [H₁.Normal] {H₂ : Subgroup (G ⧸ H₁)} [H₂.Normal] :
    ((Subgroup.center ((G ⧸ H₁) ⧸ H₂)).comap (mk' H₂)).comap (mk' H₁) =
      (Subgroup.center (G ⧸ H₂.comap (mk' H₁))).comap (mk' (H₂.comap (mk' H₁))) :=
  by 
  ext x
  simp only [mk'_apply, Subgroup.mem_comap, Subgroup.mem_center_iff, forall_coe, ← coe_mul,
    eq_iff_div_mem, coe_div]
#align quotient_group.comap_comap_center QuotientGroup.comap_comap_center

end QuotientGroup

namespace Group

open Classical

open QuotientGroup Subgroup

variable {F G H : Type u} [Group F] [Group G] [Group H] [Fintype F] [Fintype H]

variable (f : F →* G) (g : G →* H)

/-- If `F` and `H` are finite such that `ker(G →* H) ≤ im(F →* G)`, then `G` is finite. -/
@[to_additive "If `F` and `H` are finite such that `ker(G →+ H) ≤ im(F →+ G)`, then `G` is finite."]
noncomputable def fintypeOfKerLeRange (h : g.ker ≤ f.range) : Fintype G :=
  @Fintype.ofEquiv _ _
    (@Prod.fintype _ _ (Fintype.ofInjective _ <| ker_lift_injective g) <|
      Fintype.ofInjective _ <| inclusion_injective h)
    groupEquivQuotientTimesSubgroup.symm
#align group.fintype_of_ker_le_range Group.fintypeOfKerLeRange

/-- If `F` and `H` are finite such that `ker(G →* H) = im(F →* G)`, then `G` is finite. -/
@[to_additive "If `F` and `H` are finite such that `ker(G →+ H) = im(F →+ G)`, then `G` is finite."]
noncomputable def fintypeOfKerEqRange (h : g.ker = f.range) : Fintype G :=
  fintypeOfKerLeRange _ _ h.le
#align group.fintype_of_ker_eq_range Group.fintypeOfKerEqRange

/-- If `ker(G →* H)` and `H` are finite, then `G` is finite. -/
@[to_additive "If `ker(G →+ H)` and `H` are finite, then `G` is finite."]
noncomputable def fintypeOfKerOfCodom [Fintype g.ker] : Fintype G :=
  (fintypeOfKerLeRange ((topEquiv : _ ≃* G).toMonoidHom.comp <| inclusion le_top) g) fun x hx =>
    ⟨⟨x, hx⟩, rfl⟩
#align group.fintype_of_ker_of_codom Group.fintypeOfKerOfCodom

/-- If `F` and `coker(F →* G)` are finite, then `G` is finite. -/
@[to_additive "If `F` and `coker(F →+ G)` are finite, then `G` is finite."]
noncomputable def fintypeOfDomOfCoker [Normal f.range] [Fintype <| G ⧸ f.range] : Fintype G :=
  (fintypeOfKerLeRange _ (mk' f.range)) fun x => (eq_one_iff x).mp
#align group.fintype_of_dom_of_coker Group.fintypeOfDomOfCoker

end Group

