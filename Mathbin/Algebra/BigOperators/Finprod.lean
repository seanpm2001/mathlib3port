/-
Copyright (c) 2020 Kexing Ying and Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kexing Ying, Kevin Buzzard, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.big_operators.finprod
! leanprover-community/mathlib commit 63f84d91dd847f50bae04a01071f3a5491934e36
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Order
import Mathbin.Algebra.IndicatorFunction

/-!
# Finite products and sums over types and sets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define products and sums over types and subsets of types, with no finiteness hypotheses.
All infinite products and sums are defined to be junk values (i.e. one or zero).
This approach is sometimes easier to use than `finset.sum`,
when issues arise with `finset` and `fintype` being data.

## Main definitions

We use the following variables:

* `α`, `β` - types with no structure;
* `s`, `t` - sets
* `M`, `N` - additive or multiplicative commutative monoids
* `f`, `g` - functions

Definitions in this file:

* `finsum f : M` : the sum of `f x` as `x` ranges over the support of `f`, if it's finite.
   Zero otherwise.

* `finprod f : M` : the product of `f x` as `x` ranges over the multiplicative support of `f`, if
   it's finite. One otherwise.

## Notation

* `∑ᶠ i, f i` and `∑ᶠ i : α, f i` for `finsum f`

* `∏ᶠ i, f i` and `∏ᶠ i : α, f i` for `finprod f`

This notation works for functions `f : p → M`, where `p : Prop`, so the following works:

* `∑ᶠ i ∈ s, f i`, where `f : α → M`, `s : set α` : sum over the set `s`;
* `∑ᶠ n < 5, f n`, where `f : ℕ → M` : same as `f 0 + f 1 + f 2 + f 3 + f 4`;
* `∏ᶠ (n >= -2) (hn : n < 3), f n`, where `f : ℤ → M` : same as `f (-2) * f (-1) * f 0 * f 1 * f 2`.

## Implementation notes

`finsum` and `finprod` is "yet another way of doing finite sums and products in Lean". However
experiments in the wild (e.g. with matroids) indicate that it is a helpful approach in settings
where the user is not interested in computability and wants to do reasoning without running into
typeclass diamonds caused by the constructive finiteness used in definitions such as `finset` and
`fintype`. By sticking solely to `set.finite` we avoid these problems. We are aware that there are
other solutions but for beginner mathematicians this approach is easier in practice.

Another application is the construction of a partition of unity from a collection of “bump”
function. In this case the finite set depends on the point and it's convenient to have a definition
that does not mention the set explicitly.

The first arguments in all definitions and lemmas is the codomain of the function of the big
operator. This is necessary for the heuristic in `@[to_additive]`.
See the documentation of `to_additive.attr` for more information.

We did not add `is_finite (X : Type) : Prop`, because it is simply `nonempty (fintype X)`.

## Tags

finsum, finprod, finite sum, finite product
-/


open Function Set

/-!
### Definition and relation to `finset.sum` and `finset.prod`
-/


section Sort

variable {G M N : Type _} {α β ι : Sort _} [CommMonoid M] [CommMonoid N]

open scoped BigOperators

section

/- Note: we use classical logic only for these definitions, to ensure that we do not write lemmas
with `classical.dec` in their statement. -/
open scoped Classical

#print finsum /-
/-- Sum of `f x` as `x` ranges over the elements of the support of `f`, if it's finite. Zero
otherwise. -/
noncomputable irreducible_def finsum {M α} [AddCommMonoid M] (f : α → M) : M :=
  if h : (support (f ∘ PLift.down)).Finite then ∑ i in h.toFinset, f i.down else 0
#align finsum finsum
-/

#print finprod /-
/-- Product of `f x` as `x` ranges over the elements of the multiplicative support of `f`, if it's
finite. One otherwise. -/
@[to_additive]
noncomputable irreducible_def finprod (f : α → M) : M :=
  if h : (mulSupport (f ∘ PLift.down)).Finite then ∏ i in h.toFinset, f i.down else 1
#align finprod finprod
#align finsum finsum
-/

end

scoped[BigOperators] notation3"∑ᶠ "(...)", "r:67:(scoped f => finsum f) => r

scoped[BigOperators] notation3"∏ᶠ "(...)", "r:67:(scoped f => finprod f) => r

#print finprod_eq_prod_pLift_of_mulSupport_toFinset_subset /-
@[to_additive]
theorem finprod_eq_prod_pLift_of_mulSupport_toFinset_subset {f : α → M}
    (hf : (mulSupport (f ∘ PLift.down)).Finite) {s : Finset (PLift α)} (hs : hf.toFinset ⊆ s) :
    ∏ᶠ i, f i = ∏ i in s, f i.down := by
  rw [finprod, dif_pos]
  refine' Finset.prod_subset hs fun x hx hxf => _
  rwa [hf.mem_to_finset, nmem_mul_support] at hxf 
#align finprod_eq_prod_plift_of_mul_support_to_finset_subset finprod_eq_prod_pLift_of_mulSupport_toFinset_subset
#align finsum_eq_sum_plift_of_support_to_finset_subset finsum_eq_sum_pLift_of_support_toFinset_subset
-/

#print finprod_eq_prod_pLift_of_mulSupport_subset /-
@[to_additive]
theorem finprod_eq_prod_pLift_of_mulSupport_subset {f : α → M} {s : Finset (PLift α)}
    (hs : mulSupport (f ∘ PLift.down) ⊆ s) : ∏ᶠ i, f i = ∏ i in s, f i.down :=
  finprod_eq_prod_pLift_of_mulSupport_toFinset_subset (s.finite_toSet.Subset hs) fun x hx => by
    rw [finite.mem_to_finset] at hx ; exact hs hx
#align finprod_eq_prod_plift_of_mul_support_subset finprod_eq_prod_pLift_of_mulSupport_subset
#align finsum_eq_sum_plift_of_support_subset finsum_eq_sum_pLift_of_support_subset
-/

#print finprod_one /-
@[simp, to_additive]
theorem finprod_one : ∏ᶠ i : α, (1 : M) = 1 :=
  by
  have : (mul_support fun x : PLift α => (fun _ => 1 : α → M) x.down) ⊆ (∅ : Finset (PLift α)) :=
    fun x h => h rfl
  rw [finprod_eq_prod_pLift_of_mulSupport_subset this, Finset.prod_empty]
#align finprod_one finprod_one
#align finsum_zero finsum_zero
-/

#print finprod_of_isEmpty /-
@[to_additive]
theorem finprod_of_isEmpty [IsEmpty α] (f : α → M) : ∏ᶠ i, f i = 1 := by rw [← finprod_one]; congr
#align finprod_of_is_empty finprod_of_isEmpty
#align finsum_of_is_empty finsum_of_isEmpty
-/

#print finprod_false /-
@[simp, to_additive]
theorem finprod_false (f : False → M) : ∏ᶠ i, f i = 1 :=
  finprod_of_isEmpty _
#align finprod_false finprod_false
#align finsum_false finsum_false
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x «expr ≠ » a) -/
#print finprod_eq_single /-
@[to_additive]
theorem finprod_eq_single (f : α → M) (a : α) (ha : ∀ (x) (_ : x ≠ a), f x = 1) : ∏ᶠ x, f x = f a :=
  by
  have : mul_support (f ∘ PLift.down) ⊆ ({PLift.up a} : Finset (PLift α)) :=
    by
    intro x; contrapose
    simpa [PLift.eq_up_iff_down_eq] using ha x.down
  rw [finprod_eq_prod_pLift_of_mulSupport_subset this, Finset.prod_singleton]
#align finprod_eq_single finprod_eq_single
#align finsum_eq_single finsum_eq_single
-/

#print finprod_unique /-
@[to_additive]
theorem finprod_unique [Unique α] (f : α → M) : ∏ᶠ i, f i = f default :=
  finprod_eq_single f default fun x hx => (hx <| Unique.eq_default _).elim
#align finprod_unique finprod_unique
#align finsum_unique finsum_unique
-/

#print finprod_true /-
@[simp, to_additive]
theorem finprod_true (f : True → M) : ∏ᶠ i, f i = f trivial :=
  @finprod_unique M True _ ⟨⟨trivial⟩, fun _ => rfl⟩ f
#align finprod_true finprod_true
#align finsum_true finsum_true
-/

#print finprod_eq_dif /-
@[to_additive]
theorem finprod_eq_dif {p : Prop} [Decidable p] (f : p → M) :
    ∏ᶠ i, f i = if h : p then f h else 1 := by
  split_ifs
  · haveI : Unique p := ⟨⟨h⟩, fun _ => rfl⟩; exact finprod_unique f
  · haveI : IsEmpty p := ⟨h⟩; exact finprod_of_isEmpty f
#align finprod_eq_dif finprod_eq_dif
#align finsum_eq_dif finsum_eq_dif
-/

#print finprod_eq_if /-
@[to_additive]
theorem finprod_eq_if {p : Prop} [Decidable p] {x : M} : ∏ᶠ i : p, x = if p then x else 1 :=
  finprod_eq_dif fun _ => x
#align finprod_eq_if finprod_eq_if
#align finsum_eq_if finsum_eq_if
-/

#print finprod_congr /-
@[to_additive]
theorem finprod_congr {f g : α → M} (h : ∀ x, f x = g x) : finprod f = finprod g :=
  congr_arg _ <| funext h
#align finprod_congr finprod_congr
#align finsum_congr finsum_congr
-/

#print finprod_congr_Prop /-
@[congr, to_additive]
theorem finprod_congr_Prop {p q : Prop} {f : p → M} {g : q → M} (hpq : p = q)
    (hfg : ∀ h : q, f (hpq.mpr h) = g h) : finprod f = finprod g := by subst q;
  exact finprod_congr hfg
#align finprod_congr_Prop finprod_congr_Prop
#align finsum_congr_Prop finsum_congr_Prop
-/

attribute [congr] finsum_congr_Prop

#print finprod_induction /-
/-- To prove a property of a finite product, it suffices to prove that the property is
multiplicative and holds on the factors. -/
@[to_additive
      "To prove a property of a finite sum, it suffices to prove that the property is\nadditive and holds on the summands."]
theorem finprod_induction {f : α → M} (p : M → Prop) (hp₀ : p 1)
    (hp₁ : ∀ x y, p x → p y → p (x * y)) (hp₂ : ∀ i, p (f i)) : p (∏ᶠ i, f i) :=
  by
  rw [finprod]
  split_ifs
  exacts [Finset.prod_induction _ _ hp₁ hp₀ fun i hi => hp₂ _, hp₀]
#align finprod_induction finprod_induction
#align finsum_induction finsum_induction
-/

#print finprod_nonneg /-
theorem finprod_nonneg {R : Type _} [OrderedCommSemiring R] {f : α → R} (hf : ∀ x, 0 ≤ f x) :
    0 ≤ ∏ᶠ x, f x :=
  finprod_induction (fun x => 0 ≤ x) zero_le_one (fun x y => mul_nonneg) hf
#align finprod_nonneg finprod_nonneg
-/

#print one_le_finprod' /-
@[to_additive finsum_nonneg]
theorem one_le_finprod' {M : Type _} [OrderedCommMonoid M] {f : α → M} (hf : ∀ i, 1 ≤ f i) :
    1 ≤ ∏ᶠ i, f i :=
  finprod_induction _ le_rfl (fun _ _ => one_le_mul) hf
#align one_le_finprod' one_le_finprod'
#align finsum_nonneg finsum_nonneg
-/

#print MonoidHom.map_finprod_pLift /-
@[to_additive]
theorem MonoidHom.map_finprod_pLift (f : M →* N) (g : α → M)
    (h : (mulSupport <| g ∘ PLift.down).Finite) : f (∏ᶠ x, g x) = ∏ᶠ x, f (g x) :=
  by
  rw [finprod_eq_prod_pLift_of_mulSupport_subset h.coe_to_finset.ge,
    finprod_eq_prod_pLift_of_mulSupport_subset, f.map_prod]
  rw [h.coe_to_finset]
  exact mul_support_comp_subset f.map_one (g ∘ PLift.down)
#align monoid_hom.map_finprod_plift MonoidHom.map_finprod_pLift
#align add_monoid_hom.map_finsum_plift AddMonoidHom.map_finsum_pLift
-/

#print MonoidHom.map_finprod_Prop /-
@[to_additive]
theorem MonoidHom.map_finprod_Prop {p : Prop} (f : M →* N) (g : p → M) :
    f (∏ᶠ x, g x) = ∏ᶠ x, f (g x) :=
  f.map_finprod_pLift g (Set.toFinite _)
#align monoid_hom.map_finprod_Prop MonoidHom.map_finprod_Prop
#align add_monoid_hom.map_finsum_Prop AddMonoidHom.map_finsum_Prop
-/

#print MonoidHom.map_finprod_of_preimage_one /-
@[to_additive]
theorem MonoidHom.map_finprod_of_preimage_one (f : M →* N) (hf : ∀ x, f x = 1 → x = 1) (g : α → M) :
    f (∏ᶠ i, g i) = ∏ᶠ i, f (g i) :=
  by
  by_cases hg : (mul_support <| g ∘ PLift.down).Finite; · exact f.map_finprod_plift g hg
  rw [finprod, dif_neg, f.map_one, finprod, dif_neg]
  exacts [infinite.mono (fun x hx => mt (hf (g x.down)) hx) hg, hg]
#align monoid_hom.map_finprod_of_preimage_one MonoidHom.map_finprod_of_preimage_one
#align add_monoid_hom.map_finsum_of_preimage_zero AddMonoidHom.map_finsum_of_preimage_zero
-/

#print MonoidHom.map_finprod_of_injective /-
@[to_additive]
theorem MonoidHom.map_finprod_of_injective (g : M →* N) (hg : Injective g) (f : α → M) :
    g (∏ᶠ i, f i) = ∏ᶠ i, g (f i) :=
  g.map_finprod_of_preimage_one (fun x => (hg.eq_iff' g.map_one).mp) f
#align monoid_hom.map_finprod_of_injective MonoidHom.map_finprod_of_injective
#align add_monoid_hom.map_finsum_of_injective AddMonoidHom.map_finsum_of_injective
-/

#print MulEquiv.map_finprod /-
@[to_additive]
theorem MulEquiv.map_finprod (g : M ≃* N) (f : α → M) : g (∏ᶠ i, f i) = ∏ᶠ i, g (f i) :=
  g.toMonoidHom.map_finprod_of_injective g.Injective f
#align mul_equiv.map_finprod MulEquiv.map_finprod
#align add_equiv.map_finsum AddEquiv.map_finsum
-/

#print finsum_smul /-
theorem finsum_smul {R M : Type _} [Ring R] [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (f : ι → R) (x : M) : (∑ᶠ i, f i) • x = ∑ᶠ i, f i • x :=
  by
  rcases eq_or_ne x 0 with (rfl | hx); · simp
  exact ((smulAddHom R M).flip x).map_finsum_of_injective (smul_left_injective R hx) _
#align finsum_smul finsum_smul
-/

#print smul_finsum /-
theorem smul_finsum {R M : Type _} [Ring R] [AddCommGroup M] [Module R M] [NoZeroSMulDivisors R M]
    (c : R) (f : ι → M) : c • ∑ᶠ i, f i = ∑ᶠ i, c • f i :=
  by
  rcases eq_or_ne c 0 with (rfl | hc); · simp
  exact (smulAddHom R M c).map_finsum_of_injective (smul_right_injective M hc) _
#align smul_finsum smul_finsum
-/

#print finprod_inv_distrib /-
@[to_additive]
theorem finprod_inv_distrib [DivisionCommMonoid G] (f : α → G) : ∏ᶠ x, (f x)⁻¹ = (∏ᶠ x, f x)⁻¹ :=
  ((MulEquiv.inv G).map_finprod f).symm
#align finprod_inv_distrib finprod_inv_distrib
#align finsum_neg_distrib finsum_neg_distrib
-/

end Sort

section Type

variable {α β ι G M N : Type _} [CommMonoid M] [CommMonoid N]

open scoped BigOperators

#print finprod_eq_mulIndicator_apply /-
@[to_additive]
theorem finprod_eq_mulIndicator_apply (s : Set α) (f : α → M) (a : α) :
    ∏ᶠ h : a ∈ s, f a = mulIndicator s f a := by convert finprod_eq_if
#align finprod_eq_mul_indicator_apply finprod_eq_mulIndicator_apply
#align finsum_eq_indicator_apply finsum_eq_indicator_apply
-/

#print finprod_mem_mulSupport /-
@[simp, to_additive]
theorem finprod_mem_mulSupport (f : α → M) (a : α) : ∏ᶠ h : f a ≠ 1, f a = f a := by
  rw [← mem_mul_support, finprod_eq_mulIndicator_apply, mul_indicator_mul_support]
#align finprod_mem_mul_support finprod_mem_mulSupport
#align finsum_mem_support finsum_mem_support
-/

#print finprod_mem_def /-
@[to_additive]
theorem finprod_mem_def (s : Set α) (f : α → M) : ∏ᶠ a ∈ s, f a = ∏ᶠ a, mulIndicator s f a :=
  finprod_congr <| finprod_eq_mulIndicator_apply s f
#align finprod_mem_def finprod_mem_def
#align finsum_mem_def finsum_mem_def
-/

#print finprod_eq_prod_of_mulSupport_subset /-
@[to_additive]
theorem finprod_eq_prod_of_mulSupport_subset (f : α → M) {s : Finset α} (h : mulSupport f ⊆ s) :
    ∏ᶠ i, f i = ∏ i in s, f i :=
  by
  have A : mul_support (f ∘ PLift.down) = equiv.plift.symm '' mul_support f :=
    by
    rw [mul_support_comp_eq_preimage]
    exact (equiv.plift.symm.image_eq_preimage _).symm
  have : mul_support (f ∘ PLift.down) ⊆ s.map equiv.plift.symm.to_embedding := by
    rw [A, Finset.coe_map]; exact image_subset _ h
  rw [finprod_eq_prod_pLift_of_mulSupport_subset this]
  simp
#align finprod_eq_prod_of_mul_support_subset finprod_eq_prod_of_mulSupport_subset
#align finsum_eq_sum_of_support_subset finsum_eq_sum_of_support_subset
-/

#print finprod_eq_prod_of_mulSupport_toFinset_subset /-
@[to_additive]
theorem finprod_eq_prod_of_mulSupport_toFinset_subset (f : α → M) (hf : (mulSupport f).Finite)
    {s : Finset α} (h : hf.toFinset ⊆ s) : ∏ᶠ i, f i = ∏ i in s, f i :=
  finprod_eq_prod_of_mulSupport_subset _ fun x hx => h <| hf.mem_toFinset.2 hx
#align finprod_eq_prod_of_mul_support_to_finset_subset finprod_eq_prod_of_mulSupport_toFinset_subset
#align finsum_eq_sum_of_support_to_finset_subset finsum_eq_sum_of_support_toFinset_subset
-/

#print finprod_eq_finset_prod_of_mulSupport_subset /-
@[to_additive]
theorem finprod_eq_finset_prod_of_mulSupport_subset (f : α → M) {s : Finset α}
    (h : mulSupport f ⊆ (s : Set α)) : ∏ᶠ i, f i = ∏ i in s, f i :=
  haveI h' : (s.finite_to_set.subset h).toFinset ⊆ s := by
    simpa [← Finset.coe_subset, Set.coe_toFinset]
  finprod_eq_prod_of_mulSupport_toFinset_subset _ _ h'
#align finprod_eq_finset_prod_of_mul_support_subset finprod_eq_finset_prod_of_mulSupport_subset
#align finsum_eq_finset_sum_of_support_subset finsum_eq_finset_sum_of_support_subset
-/

#print finprod_def /-
@[to_additive]
theorem finprod_def (f : α → M) [Decidable (mulSupport f).Finite] :
    ∏ᶠ i : α, f i = if h : (mulSupport f).Finite then ∏ i in h.toFinset, f i else 1 :=
  by
  split_ifs
  · exact finprod_eq_prod_of_mulSupport_toFinset_subset _ h (Finset.Subset.refl _)
  · rw [finprod, dif_neg]
    rw [mul_support_comp_eq_preimage]
    exact mt (fun hf => hf.of_preimage equiv.plift.surjective) h
#align finprod_def finprod_def
#align finsum_def finsum_def
-/

#print finprod_of_infinite_mulSupport /-
@[to_additive]
theorem finprod_of_infinite_mulSupport {f : α → M} (hf : (mulSupport f).Infinite) : ∏ᶠ i, f i = 1 :=
  by classical rw [finprod_def, dif_neg hf]
#align finprod_of_infinite_mul_support finprod_of_infinite_mulSupport
#align finsum_of_infinite_support finsum_of_infinite_support
-/

#print finprod_eq_prod /-
@[to_additive]
theorem finprod_eq_prod (f : α → M) (hf : (mulSupport f).Finite) :
    ∏ᶠ i : α, f i = ∏ i in hf.toFinset, f i := by classical rw [finprod_def, dif_pos hf]
#align finprod_eq_prod finprod_eq_prod
#align finsum_eq_sum finsum_eq_sum
-/

#print finprod_eq_prod_of_fintype /-
@[to_additive]
theorem finprod_eq_prod_of_fintype [Fintype α] (f : α → M) : ∏ᶠ i : α, f i = ∏ i, f i :=
  finprod_eq_prod_of_mulSupport_toFinset_subset _ (Set.toFinite _) <| Finset.subset_univ _
#align finprod_eq_prod_of_fintype finprod_eq_prod_of_fintype
#align finsum_eq_sum_of_fintype finsum_eq_sum_of_fintype
-/

#print finprod_cond_eq_prod_of_cond_iff /-
@[to_additive]
theorem finprod_cond_eq_prod_of_cond_iff (f : α → M) {p : α → Prop} {t : Finset α}
    (h : ∀ {x}, f x ≠ 1 → (p x ↔ x ∈ t)) : ∏ᶠ (i) (hi : p i), f i = ∏ i in t, f i :=
  by
  set s := {x | p x}
  have : mul_support (s.mul_indicator f) ⊆ t := by rw [Set.mulSupport_mulIndicator]; intro x hx;
    exact (h hx.2).1 hx.1
  erw [finprod_mem_def, finprod_eq_prod_of_mulSupport_subset _ this]
  refine' Finset.prod_congr rfl fun x hx => mul_indicator_apply_eq_self.2 fun hxs => _
  contrapose! hxs
  exact (h hxs).2 hx
#align finprod_cond_eq_prod_of_cond_iff finprod_cond_eq_prod_of_cond_iff
#align finsum_cond_eq_sum_of_cond_iff finsum_cond_eq_sum_of_cond_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (i «expr ≠ » a) -/
#print finprod_cond_ne /-
@[to_additive]
theorem finprod_cond_ne (f : α → M) (a : α) [DecidableEq α] (hf : (mulSupport f).Finite) :
    ∏ᶠ (i) (_ : i ≠ a), f i = ∏ i in hf.toFinset.eraseₓ a, f i :=
  by
  apply finprod_cond_eq_prod_of_cond_iff
  intro x hx
  rw [Finset.mem_erase, finite.mem_to_finset, mem_mul_support]
  exact ⟨fun h => And.intro h hx, fun h => h.1⟩
#align finprod_cond_ne finprod_cond_ne
#align finsum_cond_ne finsum_cond_ne
-/

#print finprod_mem_eq_prod_of_inter_mulSupport_eq /-
@[to_additive]
theorem finprod_mem_eq_prod_of_inter_mulSupport_eq (f : α → M) {s : Set α} {t : Finset α}
    (h : s ∩ mulSupport f = t ∩ mulSupport f) : ∏ᶠ i ∈ s, f i = ∏ i in t, f i :=
  finprod_cond_eq_prod_of_cond_iff _ <| by simpa [Set.ext_iff] using h
#align finprod_mem_eq_prod_of_inter_mul_support_eq finprod_mem_eq_prod_of_inter_mulSupport_eq
#align finsum_mem_eq_sum_of_inter_support_eq finsum_mem_eq_sum_of_inter_support_eq
-/

#print finprod_mem_eq_prod_of_subset /-
@[to_additive]
theorem finprod_mem_eq_prod_of_subset (f : α → M) {s : Set α} {t : Finset α}
    (h₁ : s ∩ mulSupport f ⊆ t) (h₂ : ↑t ⊆ s) : ∏ᶠ i ∈ s, f i = ∏ i in t, f i :=
  finprod_cond_eq_prod_of_cond_iff _ fun x hx => ⟨fun h => h₁ ⟨h, hx⟩, fun h => h₂ h⟩
#align finprod_mem_eq_prod_of_subset finprod_mem_eq_prod_of_subset
#align finsum_mem_eq_sum_of_subset finsum_mem_eq_sum_of_subset
-/

#print finprod_mem_eq_prod /-
@[to_additive]
theorem finprod_mem_eq_prod (f : α → M) {s : Set α} (hf : (s ∩ mulSupport f).Finite) :
    ∏ᶠ i ∈ s, f i = ∏ i in hf.toFinset, f i :=
  finprod_mem_eq_prod_of_inter_mulSupport_eq _ <| by simp [inter_assoc]
#align finprod_mem_eq_prod finprod_mem_eq_prod
#align finsum_mem_eq_sum finsum_mem_eq_sum
-/

#print finprod_mem_eq_prod_filter /-
@[to_additive]
theorem finprod_mem_eq_prod_filter (f : α → M) (s : Set α) [DecidablePred (· ∈ s)]
    (hf : (mulSupport f).Finite) : ∏ᶠ i ∈ s, f i = ∏ i in Finset.filter (· ∈ s) hf.toFinset, f i :=
  finprod_mem_eq_prod_of_inter_mulSupport_eq _ <| by simp [inter_comm, inter_left_comm]
#align finprod_mem_eq_prod_filter finprod_mem_eq_prod_filter
#align finsum_mem_eq_sum_filter finsum_mem_eq_sum_filter
-/

#print finprod_mem_eq_toFinset_prod /-
@[to_additive]
theorem finprod_mem_eq_toFinset_prod (f : α → M) (s : Set α) [Fintype s] :
    ∏ᶠ i ∈ s, f i = ∏ i in s.toFinset, f i :=
  finprod_mem_eq_prod_of_inter_mulSupport_eq _ <| by rw [coe_to_finset]
#align finprod_mem_eq_to_finset_prod finprod_mem_eq_toFinset_prod
#align finsum_mem_eq_to_finset_sum finsum_mem_eq_toFinset_sum
-/

#print finprod_mem_eq_finite_toFinset_prod /-
@[to_additive]
theorem finprod_mem_eq_finite_toFinset_prod (f : α → M) {s : Set α} (hs : s.Finite) :
    ∏ᶠ i ∈ s, f i = ∏ i in hs.toFinset, f i :=
  finprod_mem_eq_prod_of_inter_mulSupport_eq _ <| by rw [hs.coe_to_finset]
#align finprod_mem_eq_finite_to_finset_prod finprod_mem_eq_finite_toFinset_prod
#align finsum_mem_eq_finite_to_finset_sum finsum_mem_eq_finite_toFinset_sum
-/

#print finprod_mem_finset_eq_prod /-
@[to_additive]
theorem finprod_mem_finset_eq_prod (f : α → M) (s : Finset α) : ∏ᶠ i ∈ s, f i = ∏ i in s, f i :=
  finprod_mem_eq_prod_of_inter_mulSupport_eq _ rfl
#align finprod_mem_finset_eq_prod finprod_mem_finset_eq_prod
#align finsum_mem_finset_eq_sum finsum_mem_finset_eq_sum
-/

#print finprod_mem_coe_finset /-
@[to_additive]
theorem finprod_mem_coe_finset (f : α → M) (s : Finset α) :
    ∏ᶠ i ∈ (s : Set α), f i = ∏ i in s, f i :=
  finprod_mem_eq_prod_of_inter_mulSupport_eq _ rfl
#align finprod_mem_coe_finset finprod_mem_coe_finset
#align finsum_mem_coe_finset finsum_mem_coe_finset
-/

#print finprod_mem_eq_one_of_infinite /-
@[to_additive]
theorem finprod_mem_eq_one_of_infinite {f : α → M} {s : Set α} (hs : (s ∩ mulSupport f).Infinite) :
    ∏ᶠ i ∈ s, f i = 1 := by
  rw [finprod_mem_def]
  apply finprod_of_infinite_mulSupport
  rwa [← mul_support_mul_indicator] at hs 
#align finprod_mem_eq_one_of_infinite finprod_mem_eq_one_of_infinite
#align finsum_mem_eq_zero_of_infinite finsum_mem_eq_zero_of_infinite
-/

#print finprod_mem_eq_one_of_forall_eq_one /-
@[to_additive]
theorem finprod_mem_eq_one_of_forall_eq_one {f : α → M} {s : Set α} (h : ∀ x ∈ s, f x = 1) :
    ∏ᶠ i ∈ s, f i = 1 := by simp (config := { contextual := true }) [h]
#align finprod_mem_eq_one_of_forall_eq_one finprod_mem_eq_one_of_forall_eq_one
#align finsum_mem_eq_zero_of_forall_eq_zero finsum_mem_eq_zero_of_forall_eq_zero
-/

#print finprod_mem_inter_mulSupport /-
@[to_additive]
theorem finprod_mem_inter_mulSupport (f : α → M) (s : Set α) :
    ∏ᶠ i ∈ s ∩ mulSupport f, f i = ∏ᶠ i ∈ s, f i := by
  rw [finprod_mem_def, finprod_mem_def, mul_indicator_inter_mul_support]
#align finprod_mem_inter_mul_support finprod_mem_inter_mulSupport
#align finsum_mem_inter_support finsum_mem_inter_support
-/

#print finprod_mem_inter_mulSupport_eq /-
@[to_additive]
theorem finprod_mem_inter_mulSupport_eq (f : α → M) (s t : Set α)
    (h : s ∩ mulSupport f = t ∩ mulSupport f) : ∏ᶠ i ∈ s, f i = ∏ᶠ i ∈ t, f i := by
  rw [← finprod_mem_inter_mulSupport, h, finprod_mem_inter_mulSupport]
#align finprod_mem_inter_mul_support_eq finprod_mem_inter_mulSupport_eq
#align finsum_mem_inter_support_eq finsum_mem_inter_support_eq
-/

#print finprod_mem_inter_mulSupport_eq' /-
@[to_additive]
theorem finprod_mem_inter_mulSupport_eq' (f : α → M) (s t : Set α)
    (h : ∀ x ∈ mulSupport f, x ∈ s ↔ x ∈ t) : ∏ᶠ i ∈ s, f i = ∏ᶠ i ∈ t, f i :=
  by
  apply finprod_mem_inter_mulSupport_eq
  ext x
  exact and_congr_left (h x)
#align finprod_mem_inter_mul_support_eq' finprod_mem_inter_mulSupport_eq'
#align finsum_mem_inter_support_eq' finsum_mem_inter_support_eq'
-/

#print finprod_mem_univ /-
@[to_additive]
theorem finprod_mem_univ (f : α → M) : ∏ᶠ i ∈ @Set.univ α, f i = ∏ᶠ i : α, f i :=
  finprod_congr fun i => finprod_true _
#align finprod_mem_univ finprod_mem_univ
#align finsum_mem_univ finsum_mem_univ
-/

variable {f g : α → M} {a b : α} {s t : Set α}

#print finprod_mem_congr /-
@[to_additive]
theorem finprod_mem_congr (h₀ : s = t) (h₁ : ∀ x ∈ t, f x = g x) : ∏ᶠ i ∈ s, f i = ∏ᶠ i ∈ t, g i :=
  h₀.symm ▸ finprod_congr fun i => finprod_congr_Prop rfl (h₁ i)
#align finprod_mem_congr finprod_mem_congr
#align finsum_mem_congr finsum_mem_congr
-/

#print finprod_eq_one_of_forall_eq_one /-
@[to_additive]
theorem finprod_eq_one_of_forall_eq_one {f : α → M} (h : ∀ x, f x = 1) : ∏ᶠ i, f i = 1 := by
  simp (config := { contextual := true }) [h]
#align finprod_eq_one_of_forall_eq_one finprod_eq_one_of_forall_eq_one
#align finsum_eq_zero_of_forall_eq_zero finsum_eq_zero_of_forall_eq_zero
-/

/-!
### Distributivity w.r.t. addition, subtraction, and (scalar) multiplication
-/


#print finprod_mul_distrib /-
/-- If the multiplicative supports of `f` and `g` are finite, then the product of `f i * g i` equals
the product of `f i` multiplied by the product of `g i`. -/
@[to_additive
      "If the additive supports of `f` and `g` are finite, then the sum of `f i + g i`\nequals the sum of `f i` plus the sum of `g i`."]
theorem finprod_mul_distrib (hf : (mulSupport f).Finite) (hg : (mulSupport g).Finite) :
    ∏ᶠ i, f i * g i = (∏ᶠ i, f i) * ∏ᶠ i, g i := by
  classical
  rw [finprod_eq_prod_of_mulSupport_toFinset_subset _ hf (Finset.subset_union_left _ _),
    finprod_eq_prod_of_mulSupport_toFinset_subset _ hg (Finset.subset_union_right _ _), ←
    Finset.prod_mul_distrib]
  refine' finprod_eq_prod_of_mulSupport_subset _ _
  simp [mul_support_mul]
#align finprod_mul_distrib finprod_mul_distrib
#align finsum_add_distrib finsum_add_distrib
-/

#print finprod_div_distrib /-
/-- If the multiplicative supports of `f` and `g` are finite, then the product of `f i / g i`
equals the product of `f i` divided by the product of `g i`. -/
@[to_additive
      "If the additive supports of `f` and `g` are finite, then the sum of `f i - g i`\nequals the sum of `f i` minus the sum of `g i`."]
theorem finprod_div_distrib [DivisionCommMonoid G] {f g : α → G} (hf : (mulSupport f).Finite)
    (hg : (mulSupport g).Finite) : ∏ᶠ i, f i / g i = (∏ᶠ i, f i) / ∏ᶠ i, g i := by
  simp only [div_eq_mul_inv, finprod_mul_distrib hf ((mul_support_inv g).symm.rec hg),
    finprod_inv_distrib]
#align finprod_div_distrib finprod_div_distrib
#align finsum_sub_distrib finsum_sub_distrib
-/

#print finprod_mem_mul_distrib' /-
/-- A more general version of `finprod_mem_mul_distrib` that only requires `s ∩ mul_support f` and
`s ∩ mul_support g` rather than `s` to be finite. -/
@[to_additive
      "A more general version of `finsum_mem_add_distrib` that only requires `s ∩ support f`\nand `s ∩ support g` rather than `s` to be finite."]
theorem finprod_mem_mul_distrib' (hf : (s ∩ mulSupport f).Finite) (hg : (s ∩ mulSupport g).Finite) :
    ∏ᶠ i ∈ s, f i * g i = (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ s, g i :=
  by
  rw [← mul_support_mul_indicator] at hf hg 
  simp only [finprod_mem_def, mul_indicator_mul, finprod_mul_distrib hf hg]
#align finprod_mem_mul_distrib' finprod_mem_mul_distrib'
#align finsum_mem_add_distrib' finsum_mem_add_distrib'
-/

#print finprod_mem_one /-
/-- The product of the constant function `1` over any set equals `1`. -/
@[to_additive "The product of the constant function `0` over any set equals `0`."]
theorem finprod_mem_one (s : Set α) : ∏ᶠ i ∈ s, (1 : M) = 1 := by simp
#align finprod_mem_one finprod_mem_one
#align finsum_mem_zero finsum_mem_zero
-/

#print finprod_mem_of_eqOn_one /-
/-- If a function `f` equals `1` on a set `s`, then the product of `f i` over `i ∈ s` equals `1`. -/
@[to_additive
      "If a function `f` equals `0` on a set `s`, then the product of `f i` over `i ∈ s`\nequals `0`."]
theorem finprod_mem_of_eqOn_one (hf : s.EqOn f 1) : ∏ᶠ i ∈ s, f i = 1 := by
  rw [← finprod_mem_one s]; exact finprod_mem_congr rfl hf
#align finprod_mem_of_eq_on_one finprod_mem_of_eqOn_one
#align finsum_mem_of_eq_on_zero finsum_mem_of_eqOn_zero
-/

#print exists_ne_one_of_finprod_mem_ne_one /-
/-- If the product of `f i` over `i ∈ s` is not equal to `1`, then there is some `x ∈ s` such that
`f x ≠ 1`. -/
@[to_additive
      "If the product of `f i` over `i ∈ s` is not equal to `0`, then there is some `x ∈ s`\nsuch that `f x ≠ 0`."]
theorem exists_ne_one_of_finprod_mem_ne_one (h : ∏ᶠ i ∈ s, f i ≠ 1) : ∃ x ∈ s, f x ≠ 1 :=
  by
  by_contra' h'
  exact h (finprod_mem_of_eqOn_one h')
#align exists_ne_one_of_finprod_mem_ne_one exists_ne_one_of_finprod_mem_ne_one
#align exists_ne_zero_of_finsum_mem_ne_zero exists_ne_zero_of_finsum_mem_ne_zero
-/

#print finprod_mem_mul_distrib /-
/-- Given a finite set `s`, the product of `f i * g i` over `i ∈ s` equals the product of `f i`
over `i ∈ s` times the product of `g i` over `i ∈ s`. -/
@[to_additive
      "Given a finite set `s`, the sum of `f i + g i` over `i ∈ s` equals the sum of `f i`\nover `i ∈ s` plus the sum of `g i` over `i ∈ s`."]
theorem finprod_mem_mul_distrib (hs : s.Finite) :
    ∏ᶠ i ∈ s, f i * g i = (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ s, g i :=
  finprod_mem_mul_distrib' (hs.inter_of_left _) (hs.inter_of_left _)
#align finprod_mem_mul_distrib finprod_mem_mul_distrib
#align finsum_mem_add_distrib finsum_mem_add_distrib
-/

#print MonoidHom.map_finprod /-
@[to_additive]
theorem MonoidHom.map_finprod {f : α → M} (g : M →* N) (hf : (mulSupport f).Finite) :
    g (∏ᶠ i, f i) = ∏ᶠ i, g (f i) :=
  g.map_finprod_pLift f <| hf.Preimage <| Equiv.plift.Injective.InjOn _
#align monoid_hom.map_finprod MonoidHom.map_finprod
#align add_monoid_hom.map_finsum AddMonoidHom.map_finsum
-/

#print finprod_pow /-
@[to_additive]
theorem finprod_pow (hf : (mulSupport f).Finite) (n : ℕ) : (∏ᶠ i, f i) ^ n = ∏ᶠ i, f i ^ n :=
  (powMonoidHom n).map_finprod hf
#align finprod_pow finprod_pow
#align finsum_nsmul finsum_nsmul
-/

#print MonoidHom.map_finprod_mem' /-
/-- A more general version of `monoid_hom.map_finprod_mem` that requires `s ∩ mul_support f` rather
than `s` to be finite. -/
@[to_additive
      "A more general version of `add_monoid_hom.map_finsum_mem` that requires\n`s ∩ support f` rather than `s` to be finite."]
theorem MonoidHom.map_finprod_mem' {f : α → M} (g : M →* N) (h₀ : (s ∩ mulSupport f).Finite) :
    g (∏ᶠ j ∈ s, f j) = ∏ᶠ i ∈ s, g (f i) :=
  by
  rw [g.map_finprod]
  · simp only [g.map_finprod_Prop]
  · simpa only [finprod_eq_mulIndicator_apply, mul_support_mul_indicator]
#align monoid_hom.map_finprod_mem' MonoidHom.map_finprod_mem'
#align add_monoid_hom.map_finsum_mem' AddMonoidHom.map_finsum_mem'
-/

#print MonoidHom.map_finprod_mem /-
/-- Given a monoid homomorphism `g : M →* N` and a function `f : α → M`, the value of `g` at the
product of `f i` over `i ∈ s` equals the product of `g (f i)` over `s`. -/
@[to_additive
      "Given an additive monoid homomorphism `g : M →* N` and a function `f : α → M`, the\nvalue of `g` at the sum of `f i` over `i ∈ s` equals the sum of `g (f i)` over `s`."]
theorem MonoidHom.map_finprod_mem (f : α → M) (g : M →* N) (hs : s.Finite) :
    g (∏ᶠ j ∈ s, f j) = ∏ᶠ i ∈ s, g (f i) :=
  g.map_finprod_mem' (hs.inter_of_left _)
#align monoid_hom.map_finprod_mem MonoidHom.map_finprod_mem
#align add_monoid_hom.map_finsum_mem AddMonoidHom.map_finsum_mem
-/

#print MulEquiv.map_finprod_mem /-
@[to_additive]
theorem MulEquiv.map_finprod_mem (g : M ≃* N) (f : α → M) {s : Set α} (hs : s.Finite) :
    g (∏ᶠ i ∈ s, f i) = ∏ᶠ i ∈ s, g (f i) :=
  g.toMonoidHom.map_finprod_mem f hs
#align mul_equiv.map_finprod_mem MulEquiv.map_finprod_mem
#align add_equiv.map_finsum_mem AddEquiv.map_finsum_mem
-/

#print finprod_mem_inv_distrib /-
@[to_additive]
theorem finprod_mem_inv_distrib [DivisionCommMonoid G] (f : α → G) (hs : s.Finite) :
    ∏ᶠ x ∈ s, (f x)⁻¹ = (∏ᶠ x ∈ s, f x)⁻¹ :=
  ((MulEquiv.inv G).map_finprod_mem f hs).symm
#align finprod_mem_inv_distrib finprod_mem_inv_distrib
#align finsum_mem_neg_distrib finsum_mem_neg_distrib
-/

#print finprod_mem_div_distrib /-
/-- Given a finite set `s`, the product of `f i / g i` over `i ∈ s` equals the product of `f i`
over `i ∈ s` divided by the product of `g i` over `i ∈ s`. -/
@[to_additive
      "Given a finite set `s`, the sum of `f i / g i` over `i ∈ s` equals the sum of `f i`\nover `i ∈ s` minus the sum of `g i` over `i ∈ s`."]
theorem finprod_mem_div_distrib [DivisionCommMonoid G] (f g : α → G) (hs : s.Finite) :
    ∏ᶠ i ∈ s, f i / g i = (∏ᶠ i ∈ s, f i) / ∏ᶠ i ∈ s, g i := by
  simp only [div_eq_mul_inv, finprod_mem_mul_distrib hs, finprod_mem_inv_distrib g hs]
#align finprod_mem_div_distrib finprod_mem_div_distrib
#align finsum_mem_sub_distrib finsum_mem_sub_distrib
-/

/-!
### `∏ᶠ x ∈ s, f x` and set operations
-/


#print finprod_mem_empty /-
/-- The product of any function over an empty set is `1`. -/
@[to_additive "The sum of any function over an empty set is `0`."]
theorem finprod_mem_empty : ∏ᶠ i ∈ (∅ : Set α), f i = 1 := by simp
#align finprod_mem_empty finprod_mem_empty
#align finsum_mem_empty finsum_mem_empty
-/

#print nonempty_of_finprod_mem_ne_one /-
/-- A set `s` is nonempty if the product of some function over `s` is not equal to `1`. -/
@[to_additive "A set `s` is nonempty if the sum of some function over `s` is not equal to `0`."]
theorem nonempty_of_finprod_mem_ne_one (h : ∏ᶠ i ∈ s, f i ≠ 1) : s.Nonempty :=
  nonempty_iff_ne_empty.2 fun h' => h <| h'.symm ▸ finprod_mem_empty
#align nonempty_of_finprod_mem_ne_one nonempty_of_finprod_mem_ne_one
#align nonempty_of_finsum_mem_ne_zero nonempty_of_finsum_mem_ne_zero
-/

#print finprod_mem_union_inter /-
/-- Given finite sets `s` and `t`, the product of `f i` over `i ∈ s ∪ t` times the product of
`f i` over `i ∈ s ∩ t` equals the product of `f i` over `i ∈ s` times the product of `f i`
over `i ∈ t`. -/
@[to_additive
      "Given finite sets `s` and `t`, the sum of `f i` over `i ∈ s ∪ t` plus the sum of\n`f i` over `i ∈ s ∩ t` equals the sum of `f i` over `i ∈ s` plus the sum of `f i` over `i ∈ t`."]
theorem finprod_mem_union_inter (hs : s.Finite) (ht : t.Finite) :
    (∏ᶠ i ∈ s ∪ t, f i) * ∏ᶠ i ∈ s ∩ t, f i = (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ t, f i :=
  by
  lift s to Finset α using hs; lift t to Finset α using ht
  classical
  rw [← Finset.coe_union, ← Finset.coe_inter]
  simp only [finprod_mem_coe_finset, Finset.prod_union_inter]
#align finprod_mem_union_inter finprod_mem_union_inter
#align finsum_mem_union_inter finsum_mem_union_inter
-/

#print finprod_mem_union_inter' /-
/-- A more general version of `finprod_mem_union_inter` that requires `s ∩ mul_support f` and
`t ∩ mul_support f` rather than `s` and `t` to be finite. -/
@[to_additive
      "A more general version of `finsum_mem_union_inter` that requires `s ∩ support f` and\n`t ∩ support f` rather than `s` and `t` to be finite."]
theorem finprod_mem_union_inter' (hs : (s ∩ mulSupport f).Finite) (ht : (t ∩ mulSupport f).Finite) :
    (∏ᶠ i ∈ s ∪ t, f i) * ∏ᶠ i ∈ s ∩ t, f i = (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ t, f i :=
  by
  rw [← finprod_mem_inter_mulSupport f s, ← finprod_mem_inter_mulSupport f t, ←
    finprod_mem_union_inter hs ht, ← union_inter_distrib_right, finprod_mem_inter_mulSupport, ←
    finprod_mem_inter_mulSupport f (s ∩ t)]
  congr 2
  rw [inter_left_comm, inter_assoc, inter_assoc, inter_self, inter_left_comm]
#align finprod_mem_union_inter' finprod_mem_union_inter'
#align finsum_mem_union_inter' finsum_mem_union_inter'
-/

#print finprod_mem_union' /-
/-- A more general version of `finprod_mem_union` that requires `s ∩ mul_support f` and
`t ∩ mul_support f` rather than `s` and `t` to be finite. -/
@[to_additive
      "A more general version of `finsum_mem_union` that requires `s ∩ support f` and\n`t ∩ support f` rather than `s` and `t` to be finite."]
theorem finprod_mem_union' (hst : Disjoint s t) (hs : (s ∩ mulSupport f).Finite)
    (ht : (t ∩ mulSupport f).Finite) : ∏ᶠ i ∈ s ∪ t, f i = (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ t, f i := by
  rw [← finprod_mem_union_inter' hs ht, disjoint_iff_inter_eq_empty.1 hst, finprod_mem_empty,
    mul_one]
#align finprod_mem_union' finprod_mem_union'
#align finsum_mem_union' finsum_mem_union'
-/

#print finprod_mem_union /-
/-- Given two finite disjoint sets `s` and `t`, the product of `f i` over `i ∈ s ∪ t` equals the
product of `f i` over `i ∈ s` times the product of `f i` over `i ∈ t`. -/
@[to_additive
      "Given two finite disjoint sets `s` and `t`, the sum of `f i` over `i ∈ s ∪ t` equals\nthe sum of `f i` over `i ∈ s` plus the sum of `f i` over `i ∈ t`."]
theorem finprod_mem_union (hst : Disjoint s t) (hs : s.Finite) (ht : t.Finite) :
    ∏ᶠ i ∈ s ∪ t, f i = (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ t, f i :=
  finprod_mem_union' hst (hs.inter_of_left _) (ht.inter_of_left _)
#align finprod_mem_union finprod_mem_union
#align finsum_mem_union finsum_mem_union
-/

#print finprod_mem_union'' /-
/-- A more general version of `finprod_mem_union'` that requires `s ∩ mul_support f` and
`t ∩ mul_support f` rather than `s` and `t` to be disjoint -/
@[to_additive
      "A more general version of `finsum_mem_union'` that requires `s ∩ support f` and\n`t ∩ support f` rather than `s` and `t` to be disjoint"]
theorem finprod_mem_union'' (hst : Disjoint (s ∩ mulSupport f) (t ∩ mulSupport f))
    (hs : (s ∩ mulSupport f).Finite) (ht : (t ∩ mulSupport f).Finite) :
    ∏ᶠ i ∈ s ∪ t, f i = (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ t, f i := by
  rw [← finprod_mem_inter_mulSupport f s, ← finprod_mem_inter_mulSupport f t, ←
    finprod_mem_union hst hs ht, ← union_inter_distrib_right, finprod_mem_inter_mulSupport]
#align finprod_mem_union'' finprod_mem_union''
#align finsum_mem_union'' finsum_mem_union''
-/

#print finprod_mem_singleton /-
/-- The product of `f i` over `i ∈ {a}` equals `f a`. -/
@[to_additive "The sum of `f i` over `i ∈ {a}` equals `f a`."]
theorem finprod_mem_singleton : ∏ᶠ i ∈ ({a} : Set α), f i = f a := by
  rw [← Finset.coe_singleton, finprod_mem_coe_finset, Finset.prod_singleton]
#align finprod_mem_singleton finprod_mem_singleton
#align finsum_mem_singleton finsum_mem_singleton
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (i «expr = » a) -/
#print finprod_cond_eq_left /-
@[simp, to_additive]
theorem finprod_cond_eq_left : ∏ᶠ (i) (_ : i = a), f i = f a :=
  finprod_mem_singleton
#align finprod_cond_eq_left finprod_cond_eq_left
#align finsum_cond_eq_left finsum_cond_eq_left
-/

#print finprod_cond_eq_right /-
@[simp, to_additive]
theorem finprod_cond_eq_right : ∏ᶠ (i) (hi : a = i), f i = f a := by simp [@eq_comm _ a]
#align finprod_cond_eq_right finprod_cond_eq_right
#align finsum_cond_eq_right finsum_cond_eq_right
-/

#print finprod_mem_insert' /-
/-- A more general version of `finprod_mem_insert` that requires `s ∩ mul_support f` rather than `s`
to be finite. -/
@[to_additive
      "A more general version of `finsum_mem_insert` that requires `s ∩ support f` rather\nthan `s` to be finite."]
theorem finprod_mem_insert' (f : α → M) (h : a ∉ s) (hs : (s ∩ mulSupport f).Finite) :
    ∏ᶠ i ∈ insert a s, f i = f a * ∏ᶠ i ∈ s, f i :=
  by
  rw [insert_eq, finprod_mem_union' _ _ hs, finprod_mem_singleton]
  · rwa [disjoint_singleton_left]
  · exact (finite_singleton a).inter_of_left _
#align finprod_mem_insert' finprod_mem_insert'
#align finsum_mem_insert' finsum_mem_insert'
-/

#print finprod_mem_insert /-
/-- Given a finite set `s` and an element `a ∉ s`, the product of `f i` over `i ∈ insert a s` equals
`f a` times the product of `f i` over `i ∈ s`. -/
@[to_additive
      "Given a finite set `s` and an element `a ∉ s`, the sum of `f i` over `i ∈ insert a s`\nequals `f a` plus the sum of `f i` over `i ∈ s`."]
theorem finprod_mem_insert (f : α → M) (h : a ∉ s) (hs : s.Finite) :
    ∏ᶠ i ∈ insert a s, f i = f a * ∏ᶠ i ∈ s, f i :=
  finprod_mem_insert' f h <| hs.inter_of_left _
#align finprod_mem_insert finprod_mem_insert
#align finsum_mem_insert finsum_mem_insert
-/

#print finprod_mem_insert_of_eq_one_if_not_mem /-
/-- If `f a = 1` when `a ∉ s`, then the product of `f i` over `i ∈ insert a s` equals the product of
`f i` over `i ∈ s`. -/
@[to_additive
      "If `f a = 0` when `a ∉ s`, then the sum of `f i` over `i ∈ insert a s` equals the sum\nof `f i` over `i ∈ s`."]
theorem finprod_mem_insert_of_eq_one_if_not_mem (h : a ∉ s → f a = 1) :
    ∏ᶠ i ∈ insert a s, f i = ∏ᶠ i ∈ s, f i :=
  by
  refine' finprod_mem_inter_mulSupport_eq' _ _ _ fun x hx => ⟨_, Or.inr⟩
  rintro (rfl | hxs)
  exacts [not_imp_comm.1 h hx, hxs]
#align finprod_mem_insert_of_eq_one_if_not_mem finprod_mem_insert_of_eq_one_if_not_mem
#align finsum_mem_insert_of_eq_zero_if_not_mem finsum_mem_insert_of_eq_zero_if_not_mem
-/

#print finprod_mem_insert_one /-
/-- If `f a = 1`, then the product of `f i` over `i ∈ insert a s` equals the product of `f i` over
`i ∈ s`. -/
@[to_additive
      "If `f a = 0`, then the sum of `f i` over `i ∈ insert a s` equals the sum of `f i`\nover `i ∈ s`."]
theorem finprod_mem_insert_one (h : f a = 1) : ∏ᶠ i ∈ insert a s, f i = ∏ᶠ i ∈ s, f i :=
  finprod_mem_insert_of_eq_one_if_not_mem fun _ => h
#align finprod_mem_insert_one finprod_mem_insert_one
#align finsum_mem_insert_zero finsum_mem_insert_zero
-/

#print finprod_mem_dvd /-
/-- If the multiplicative support of `f` is finite, then for every `x` in the domain of `f`, `f x`
divides `finprod f`.  -/
theorem finprod_mem_dvd {f : α → N} (a : α) (hf : (mulSupport f).Finite) : f a ∣ finprod f :=
  by
  by_cases ha : a ∈ mul_support f
  · rw [finprod_eq_prod_of_mulSupport_toFinset_subset f hf (Set.Subset.refl _)]
    exact Finset.dvd_prod_of_mem f ((finite.mem_to_finset hf).mpr ha)
  · rw [nmem_mul_support.mp ha]
    exact one_dvd (finprod f)
#align finprod_mem_dvd finprod_mem_dvd
-/

#print finprod_mem_pair /-
/-- The product of `f i` over `i ∈ {a, b}`, `a ≠ b`, is equal to `f a * f b`. -/
@[to_additive "The sum of `f i` over `i ∈ {a, b}`, `a ≠ b`, is equal to `f a + f b`."]
theorem finprod_mem_pair (h : a ≠ b) : ∏ᶠ i ∈ ({a, b} : Set α), f i = f a * f b := by
  rw [finprod_mem_insert, finprod_mem_singleton]; exacts [h, finite_singleton b]
#align finprod_mem_pair finprod_mem_pair
#align finsum_mem_pair finsum_mem_pair
-/

#print finprod_mem_image' /-
/-- The product of `f y` over `y ∈ g '' s` equals the product of `f (g i)` over `s`
provided that `g` is injective on `s ∩ mul_support (f ∘ g)`. -/
@[to_additive
      "The sum of `f y` over `y ∈ g '' s` equals the sum of `f (g i)` over `s` provided that\n`g` is injective on `s ∩ support (f ∘ g)`."]
theorem finprod_mem_image' {s : Set β} {g : β → α} (hg : (s ∩ mulSupport (f ∘ g)).InjOn g) :
    ∏ᶠ i ∈ g '' s, f i = ∏ᶠ j ∈ s, f (g j) := by
  classical
  by_cases hs : (s ∩ mul_support (f ∘ g)).Finite
  · have hg : ∀ x ∈ hs.to_finset, ∀ y ∈ hs.to_finset, g x = g y → x = y := by
      simpa only [hs.mem_to_finset]
    rw [finprod_mem_eq_prod _ hs, ← Finset.prod_image hg]
    refine' finprod_mem_eq_prod_of_inter_mulSupport_eq f _
    rw [Finset.coe_image, hs.coe_to_finset, ← image_inter_mul_support_eq, inter_assoc, inter_self]
  · rw [finprod_mem_eq_one_of_infinite hs, finprod_mem_eq_one_of_infinite]
    rwa [image_inter_mul_support_eq, infinite_image_iff hg]
#align finprod_mem_image' finprod_mem_image'
#align finsum_mem_image' finsum_mem_image'
-/

#print finprod_mem_image /-
/-- The product of `f y` over `y ∈ g '' s` equals the product of `f (g i)` over `s` provided that
`g` is injective on `s`. -/
@[to_additive
      "The sum of `f y` over `y ∈ g '' s` equals the sum of `f (g i)` over `s` provided that\n`g` is injective on `s`."]
theorem finprod_mem_image {s : Set β} {g : β → α} (hg : s.InjOn g) :
    ∏ᶠ i ∈ g '' s, f i = ∏ᶠ j ∈ s, f (g j) :=
  finprod_mem_image' <| hg.mono <| inter_subset_left _ _
#align finprod_mem_image finprod_mem_image
#align finsum_mem_image finsum_mem_image
-/

#print finprod_mem_range' /-
/-- The product of `f y` over `y ∈ set.range g` equals the product of `f (g i)` over all `i`
provided that `g` is injective on `mul_support (f ∘ g)`. -/
@[to_additive
      "The sum of `f y` over `y ∈ set.range g` equals the sum of `f (g i)` over all `i`\nprovided that `g` is injective on `support (f ∘ g)`."]
theorem finprod_mem_range' {g : β → α} (hg : (mulSupport (f ∘ g)).InjOn g) :
    ∏ᶠ i ∈ range g, f i = ∏ᶠ j, f (g j) :=
  by
  rw [← image_univ, finprod_mem_image', finprod_mem_univ]
  rwa [univ_inter]
#align finprod_mem_range' finprod_mem_range'
#align finsum_mem_range' finsum_mem_range'
-/

#print finprod_mem_range /-
/-- The product of `f y` over `y ∈ set.range g` equals the product of `f (g i)` over all `i`
provided that `g` is injective. -/
@[to_additive
      "The sum of `f y` over `y ∈ set.range g` equals the sum of `f (g i)` over all `i`\nprovided that `g` is injective."]
theorem finprod_mem_range {g : β → α} (hg : Injective g) : ∏ᶠ i ∈ range g, f i = ∏ᶠ j, f (g j) :=
  finprod_mem_range' (hg.InjOn _)
#align finprod_mem_range finprod_mem_range
#align finsum_mem_range finsum_mem_range
-/

#print finprod_mem_eq_of_bijOn /-
/-- See also `finset.prod_bij`. -/
@[to_additive "See also `finset.sum_bij`."]
theorem finprod_mem_eq_of_bijOn {s : Set α} {t : Set β} {f : α → M} {g : β → M} (e : α → β)
    (he₀ : s.BijOn e t) (he₁ : ∀ x ∈ s, f x = g (e x)) : ∏ᶠ i ∈ s, f i = ∏ᶠ j ∈ t, g j :=
  by
  rw [← Set.BijOn.image_eq he₀, finprod_mem_image he₀.2.1]
  exact finprod_mem_congr rfl he₁
#align finprod_mem_eq_of_bij_on finprod_mem_eq_of_bijOn
#align finsum_mem_eq_of_bij_on finsum_mem_eq_of_bijOn
-/

#print finprod_eq_of_bijective /-
/-- See `finprod_comp`, `fintype.prod_bijective` and `finset.prod_bij`. -/
@[to_additive "See `finsum_comp`, `fintype.sum_bijective` and `finset.sum_bij`."]
theorem finprod_eq_of_bijective {f : α → M} {g : β → M} (e : α → β) (he₀ : Bijective e)
    (he₁ : ∀ x, f x = g (e x)) : ∏ᶠ i, f i = ∏ᶠ j, g j :=
  by
  rw [← finprod_mem_univ f, ← finprod_mem_univ g]
  exact finprod_mem_eq_of_bijOn _ (bijective_iff_bij_on_univ.mp he₀) fun x _ => he₁ x
#align finprod_eq_of_bijective finprod_eq_of_bijective
#align finsum_eq_of_bijective finsum_eq_of_bijective
-/

#print finprod_comp /-
/-- See also `finprod_eq_of_bijective`, `fintype.prod_bijective` and `finset.prod_bij`. -/
@[to_additive "See also `finsum_eq_of_bijective`, `fintype.sum_bijective` and `finset.sum_bij`."]
theorem finprod_comp {g : β → M} (e : α → β) (he₀ : Function.Bijective e) :
    ∏ᶠ i, g (e i) = ∏ᶠ j, g j :=
  finprod_eq_of_bijective e he₀ fun x => rfl
#align finprod_comp finprod_comp
#align finsum_comp finsum_comp
-/

#print finprod_comp_equiv /-
@[to_additive]
theorem finprod_comp_equiv (e : α ≃ β) {f : β → M} : ∏ᶠ i, f (e i) = ∏ᶠ i', f i' :=
  finprod_comp e e.Bijective
#align finprod_comp_equiv finprod_comp_equiv
#align finsum_comp_equiv finsum_comp_equiv
-/

#print finprod_set_coe_eq_finprod_mem /-
@[to_additive]
theorem finprod_set_coe_eq_finprod_mem (s : Set α) : ∏ᶠ j : s, f j = ∏ᶠ i ∈ s, f i :=
  by
  rw [← finprod_mem_range, Subtype.range_coe]
  exact Subtype.coe_injective
#align finprod_set_coe_eq_finprod_mem finprod_set_coe_eq_finprod_mem
#align finsum_set_coe_eq_finsum_mem finsum_set_coe_eq_finsum_mem
-/

#print finprod_subtype_eq_finprod_cond /-
@[to_additive]
theorem finprod_subtype_eq_finprod_cond (p : α → Prop) :
    ∏ᶠ j : Subtype p, f j = ∏ᶠ (i) (hi : p i), f i :=
  finprod_set_coe_eq_finprod_mem {i | p i}
#align finprod_subtype_eq_finprod_cond finprod_subtype_eq_finprod_cond
#align finsum_subtype_eq_finsum_cond finsum_subtype_eq_finsum_cond
-/

#print finprod_mem_inter_mul_diff' /-
@[to_additive]
theorem finprod_mem_inter_mul_diff' (t : Set α) (h : (s ∩ mulSupport f).Finite) :
    (∏ᶠ i ∈ s ∩ t, f i) * ∏ᶠ i ∈ s \ t, f i = ∏ᶠ i ∈ s, f i :=
  by
  rw [← finprod_mem_union', inter_union_diff]
  rw [disjoint_iff_inf_le]
  exacts [fun x hx => hx.2.2 hx.1.2, h.subset fun x hx => ⟨hx.1.1, hx.2⟩,
    h.subset fun x hx => ⟨hx.1.1, hx.2⟩]
#align finprod_mem_inter_mul_diff' finprod_mem_inter_mul_diff'
#align finsum_mem_inter_add_diff' finsum_mem_inter_add_diff'
-/

#print finprod_mem_inter_mul_diff /-
@[to_additive]
theorem finprod_mem_inter_mul_diff (t : Set α) (h : s.Finite) :
    (∏ᶠ i ∈ s ∩ t, f i) * ∏ᶠ i ∈ s \ t, f i = ∏ᶠ i ∈ s, f i :=
  finprod_mem_inter_mul_diff' _ <| h.inter_of_left _
#align finprod_mem_inter_mul_diff finprod_mem_inter_mul_diff
#align finsum_mem_inter_add_diff finsum_mem_inter_add_diff
-/

#print finprod_mem_mul_diff' /-
/-- A more general version of `finprod_mem_mul_diff` that requires `t ∩ mul_support f` rather than
`t` to be finite. -/
@[to_additive
      "A more general version of `finsum_mem_add_diff` that requires `t ∩ support f` rather\nthan `t` to be finite."]
theorem finprod_mem_mul_diff' (hst : s ⊆ t) (ht : (t ∩ mulSupport f).Finite) :
    (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ t \ s, f i = ∏ᶠ i ∈ t, f i := by
  rw [← finprod_mem_inter_mul_diff' _ ht, inter_eq_self_of_subset_right hst]
#align finprod_mem_mul_diff' finprod_mem_mul_diff'
#align finsum_mem_add_diff' finsum_mem_add_diff'
-/

#print finprod_mem_mul_diff /-
/-- Given a finite set `t` and a subset `s` of `t`, the product of `f i` over `i ∈ s`
times the product of `f i` over `t \ s` equals the product of `f i` over `i ∈ t`. -/
@[to_additive
      "Given a finite set `t` and a subset `s` of `t`, the sum of `f i` over `i ∈ s` plus\nthe sum of `f i` over `t \\ s` equals the sum of `f i` over `i ∈ t`."]
theorem finprod_mem_mul_diff (hst : s ⊆ t) (ht : t.Finite) :
    (∏ᶠ i ∈ s, f i) * ∏ᶠ i ∈ t \ s, f i = ∏ᶠ i ∈ t, f i :=
  finprod_mem_mul_diff' hst (ht.inter_of_left _)
#align finprod_mem_mul_diff finprod_mem_mul_diff
#align finsum_mem_add_diff finsum_mem_add_diff
-/

#print finprod_mem_iUnion /-
/-- Given a family of pairwise disjoint finite sets `t i` indexed by a finite type, the product of
`f a` over the union `⋃ i, t i` is equal to the product over all indexes `i` of the products of
`f a` over `a ∈ t i`. -/
@[to_additive
      "Given a family of pairwise disjoint finite sets `t i` indexed by a finite type, the\nsum of `f a` over the union `⋃ i, t i` is equal to the sum over all indexes `i` of the sums of `f a`\nover `a ∈ t i`."]
theorem finprod_mem_iUnion [Finite ι] {t : ι → Set α} (h : Pairwise (Disjoint on t))
    (ht : ∀ i, (t i).Finite) : ∏ᶠ a ∈ ⋃ i : ι, t i, f a = ∏ᶠ i, ∏ᶠ a ∈ t i, f a :=
  by
  cases nonempty_fintype ι
  lift t to ι → Finset α using ht
  classical
  rw [← bUnion_univ, ← Finset.coe_univ, ← Finset.coe_biUnion, finprod_mem_coe_finset,
    Finset.prod_biUnion]
  · simp only [finprod_mem_coe_finset, finprod_eq_prod_of_fintype]
  · exact fun x _ y _ hxy => Finset.disjoint_coe.1 (h hxy)
#align finprod_mem_Union finprod_mem_iUnion
#align finsum_mem_Union finsum_mem_iUnion
-/

#print finprod_mem_biUnion /-
/-- Given a family of sets `t : ι → set α`, a finite set `I` in the index type such that all sets
`t i`, `i ∈ I`, are finite, if all `t i`, `i ∈ I`, are pairwise disjoint, then the product of `f a`
over `a ∈ ⋃ i ∈ I, t i` is equal to the product over `i ∈ I` of the products of `f a` over
`a ∈ t i`. -/
@[to_additive
      "Given a family of sets `t : ι → set α`, a finite set `I` in the index type such that\nall sets `t i`, `i ∈ I`, are finite, if all `t i`, `i ∈ I`, are pairwise disjoint, then the sum of\n`f a` over `a ∈ ⋃ i ∈ I, t i` is equal to the sum over `i ∈ I` of the sums of `f a` over\n`a ∈ t i`."]
theorem finprod_mem_biUnion {I : Set ι} {t : ι → Set α} (h : I.PairwiseDisjoint t) (hI : I.Finite)
    (ht : ∀ i ∈ I, (t i).Finite) : ∏ᶠ a ∈ ⋃ x ∈ I, t x, f a = ∏ᶠ i ∈ I, ∏ᶠ j ∈ t i, f j :=
  by
  haveI := hI.fintype
  rw [bUnion_eq_Union, finprod_mem_iUnion, ← finprod_set_coe_eq_finprod_mem]
  exacts [fun x y hxy => h x.2 y.2 (subtype.coe_injective.ne hxy), fun b => ht b b.2]
#align finprod_mem_bUnion finprod_mem_biUnion
#align finsum_mem_bUnion finsum_mem_biUnion
-/

#print finprod_mem_sUnion /-
/-- If `t` is a finite set of pairwise disjoint finite sets, then the product of `f a`
over `a ∈ ⋃₀ t` is the product over `s ∈ t` of the products of `f a` over `a ∈ s`. -/
@[to_additive
      "If `t` is a finite set of pairwise disjoint finite sets, then the sum of `f a` over\n`a ∈ ⋃₀ t` is the sum over `s ∈ t` of the sums of `f a` over `a ∈ s`."]
theorem finprod_mem_sUnion {t : Set (Set α)} (h : t.PairwiseDisjoint id) (ht₀ : t.Finite)
    (ht₁ : ∀ x ∈ t, Set.Finite x) : ∏ᶠ a ∈ ⋃₀ t, f a = ∏ᶠ s ∈ t, ∏ᶠ a ∈ s, f a := by
  rw [Set.sUnion_eq_biUnion]; exact finprod_mem_biUnion h ht₀ ht₁
#align finprod_mem_sUnion finprod_mem_sUnion
#align finsum_mem_sUnion finsum_mem_sUnion
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (i «expr ≠ » a) -/
#print mul_finprod_cond_ne /-
@[to_additive]
theorem mul_finprod_cond_ne (a : α) (hf : (mulSupport f).Finite) :
    f a * ∏ᶠ (i) (_ : i ≠ a), f i = ∏ᶠ i, f i := by
  classical
  rw [finprod_eq_prod _ hf]
  have h : ∀ x : α, f x ≠ 1 → (x ≠ a ↔ x ∈ hf.to_finset \ {a}) :=
    by
    intro x hx
    rw [Finset.mem_sdiff, Finset.mem_singleton, finite.mem_to_finset, mem_mul_support]
    exact ⟨fun h => And.intro hx h, fun h => h.2⟩
  rw [finprod_cond_eq_prod_of_cond_iff f h, Finset.sdiff_singleton_eq_erase]
  by_cases ha : a ∈ mul_support f
  · apply Finset.mul_prod_erase _ _ ((finite.mem_to_finset _).mpr ha)
  · rw [mem_mul_support, Classical.not_not] at ha 
    rw [ha, one_mul]
    apply Finset.prod_erase _ ha
#align mul_finprod_cond_ne mul_finprod_cond_ne
#align add_finsum_cond_ne add_finsum_cond_ne
-/

#print finprod_mem_comm /-
/-- If `s : set α` and `t : set β` are finite sets, then taking the product over `s` commutes with
taking the product over `t`. -/
@[to_additive
      "If `s : set α` and `t : set β` are finite sets, then summing over `s` commutes with\nsumming over `t`."]
theorem finprod_mem_comm {s : Set α} {t : Set β} (f : α → β → M) (hs : s.Finite) (ht : t.Finite) :
    ∏ᶠ i ∈ s, ∏ᶠ j ∈ t, f i j = ∏ᶠ j ∈ t, ∏ᶠ i ∈ s, f i j :=
  by
  lift s to Finset α using hs; lift t to Finset β using ht
  simp only [finprod_mem_coe_finset]
  exact Finset.prod_comm
#align finprod_mem_comm finprod_mem_comm
#align finsum_mem_comm finsum_mem_comm
-/

#print finprod_mem_induction /-
/-- To prove a property of a finite product, it suffices to prove that the property is
multiplicative and holds on factors. -/
@[to_additive
      "To prove a property of a finite sum, it suffices to prove that the property is\nadditive and holds on summands."]
theorem finprod_mem_induction (p : M → Prop) (hp₀ : p 1) (hp₁ : ∀ x y, p x → p y → p (x * y))
    (hp₂ : ∀ x ∈ s, p <| f x) : p (∏ᶠ i ∈ s, f i) :=
  finprod_induction _ hp₀ hp₁ fun x => finprod_induction _ hp₀ hp₁ <| hp₂ x
#align finprod_mem_induction finprod_mem_induction
#align finsum_mem_induction finsum_mem_induction
-/

#print finprod_cond_nonneg /-
theorem finprod_cond_nonneg {R : Type _} [OrderedCommSemiring R] {p : α → Prop} {f : α → R}
    (hf : ∀ x, p x → 0 ≤ f x) : 0 ≤ ∏ᶠ (x) (h : p x), f x :=
  finprod_nonneg fun x => finprod_nonneg <| hf x
#align finprod_cond_nonneg finprod_cond_nonneg
-/

#print single_le_finprod /-
@[to_additive]
theorem single_le_finprod {M : Type _} [OrderedCommMonoid M] (i : α) {f : α → M}
    (hf : (mulSupport f).Finite) (h : ∀ j, 1 ≤ f j) : f i ≤ ∏ᶠ j, f j := by
  classical calc
    f i ≤ ∏ j in insert i hf.to_finset, f j :=
      Finset.single_le_prod' (fun j hj => h j) (Finset.mem_insert_self _ _)
    _ = ∏ᶠ j, f j :=
      (finprod_eq_prod_of_mulSupport_toFinset_subset _ hf (Finset.subset_insert _ _)).symm
#align single_le_finprod single_le_finprod
#align single_le_finsum single_le_finsum
-/

#print finprod_eq_zero /-
theorem finprod_eq_zero {M₀ : Type _} [CommMonoidWithZero M₀] (f : α → M₀) (x : α) (hx : f x = 0)
    (hf : (mulSupport f).Finite) : ∏ᶠ x, f x = 0 :=
  by
  nontriviality
  rw [finprod_eq_prod f hf]
  refine' Finset.prod_eq_zero (hf.mem_to_finset.2 _) hx
  simp [hx]
#align finprod_eq_zero finprod_eq_zero
-/

#print finprod_prod_comm /-
@[to_additive]
theorem finprod_prod_comm (s : Finset β) (f : α → β → M)
    (h : ∀ b ∈ s, (mulSupport fun a => f a b).Finite) :
    ∏ᶠ a : α, ∏ b in s, f a b = ∏ b in s, ∏ᶠ a : α, f a b :=
  by
  have hU :
    (mul_support fun a => ∏ b in s, f a b) ⊆
      (s.finite_to_set.bUnion fun b hb => h b (Finset.mem_coe.1 hb)).toFinset :=
    by
    rw [finite.coe_to_finset]
    intro x hx
    simp only [exists_prop, mem_Union, Ne.def, mem_mul_support, Finset.mem_coe]
    contrapose! hx
    rw [mem_mul_support, Classical.not_not, Finset.prod_congr rfl hx, Finset.prod_const_one]
  rw [finprod_eq_prod_of_mulSupport_subset _ hU, Finset.prod_comm]
  refine' Finset.prod_congr rfl fun b hb => (finprod_eq_prod_of_mulSupport_subset _ _).symm
  intro a ha
  simp only [finite.coe_to_finset, mem_Union]
  exact ⟨b, hb, ha⟩
#align finprod_prod_comm finprod_prod_comm
#align finsum_sum_comm finsum_sum_comm
-/

#print prod_finprod_comm /-
@[to_additive]
theorem prod_finprod_comm (s : Finset α) (f : α → β → M) (h : ∀ a ∈ s, (mulSupport (f a)).Finite) :
    ∏ a in s, ∏ᶠ b : β, f a b = ∏ᶠ b : β, ∏ a in s, f a b :=
  (finprod_prod_comm s (fun b a => f a b) h).symm
#align prod_finprod_comm prod_finprod_comm
#align sum_finsum_comm sum_finsum_comm
-/

#print mul_finsum /-
theorem mul_finsum {R : Type _} [Semiring R] (f : α → R) (r : R) (h : (support f).Finite) :
    r * ∑ᶠ a : α, f a = ∑ᶠ a : α, r * f a :=
  (AddMonoidHom.mulLeft r).map_finsum h
#align mul_finsum mul_finsum
-/

#print finsum_mul /-
theorem finsum_mul {R : Type _} [Semiring R] (f : α → R) (r : R) (h : (support f).Finite) :
    (∑ᶠ a : α, f a) * r = ∑ᶠ a : α, f a * r :=
  (AddMonoidHom.mulRight r).map_finsum h
#align finsum_mul finsum_mul
-/

#print Finset.mulSupport_of_fiberwise_prod_subset_image /-
@[to_additive]
theorem Finset.mulSupport_of_fiberwise_prod_subset_image [DecidableEq β] (s : Finset α) (f : α → M)
    (g : α → β) : (mulSupport fun b => (s.filterₓ fun a => g a = b).Prod f) ⊆ s.image g :=
  by
  simp only [Finset.coe_image, Set.mem_image, Finset.mem_coe, Function.support_subset_iff]
  intro b h
  suffices (s.filter fun a : α => g a = b).Nonempty by
    simpa only [s.fiber_nonempty_iff_mem_image g b, Finset.mem_image, exists_prop]
  exact Finset.nonempty_of_prod_ne_one h
#align finset.mul_support_of_fiberwise_prod_subset_image Finset.mulSupport_of_fiberwise_prod_subset_image
#align finset.support_of_fiberwise_sum_subset_image Finset.support_of_fiberwise_sum_subset_image
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
#print finprod_mem_finset_product' /-
/-- Note that `b ∈ (s.filter (λ ab, prod.fst ab = a)).image prod.snd` iff `(a, b) ∈ s` so we can
simplify the right hand side of this lemma. However the form stated here is more useful for
iterating this lemma, e.g., if we have `f : α × β × γ → M`. -/
@[to_additive
      "Note that `b ∈ (s.filter (λ ab, prod.fst ab = a)).image prod.snd` iff `(a, b) ∈ s` so\nwe can simplify the right hand side of this lemma. However the form stated here is more useful for\niterating this lemma, e.g., if we have `f : α × β × γ → M`."]
theorem finprod_mem_finset_product' [DecidableEq α] [DecidableEq β] (s : Finset (α × β))
    (f : α × β → M) :
    ∏ᶠ (ab) (h : ab ∈ s), f ab =
      ∏ᶠ (a) (b) (h : b ∈ (s.filterₓ fun ab => Prod.fst ab = a).image Prod.snd), f (a, b) :=
  by
  have :
    ∀ a,
      ∏ i : β in (s.filter fun ab => Prod.fst ab = a).image Prod.snd, f (a, i) =
        (Finset.filter (fun ab => Prod.fst ab = a) s).Prod f :=
    by
    refine' fun a => Finset.prod_bij (fun b _ => (a, b)) _ _ _ _ <;>-- `finish` closes these goals
      try simp; done
    suffices ∀ a' b, (a', b) ∈ s → a' = a → (a, b) ∈ s ∧ a' = a by simpa
    rintro a' b hp rfl
    exact ⟨hp, rfl⟩
  rw [finprod_mem_finset_eq_prod]
  simp_rw [finprod_mem_finset_eq_prod, this]
  rw [finprod_eq_prod_of_mulSupport_subset _
      (s.mul_support_of_fiberwise_prod_subset_image f Prod.fst),
    ← Finset.prod_fiberwise_of_maps_to _ f]
  -- `finish` could close the goal here
  simp only [Finset.mem_image, Prod.mk.eta]
  exact fun x hx => ⟨x, hx, rfl⟩
#align finprod_mem_finset_product' finprod_mem_finset_product'
#align finsum_mem_finset_product' finsum_mem_finset_product'
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
#print finprod_mem_finset_product /-
/-- See also `finprod_mem_finset_product'`. -/
@[to_additive "See also `finsum_mem_finset_product'`."]
theorem finprod_mem_finset_product (s : Finset (α × β)) (f : α × β → M) :
    ∏ᶠ (ab) (h : ab ∈ s), f ab = ∏ᶠ (a) (b) (h : (a, b) ∈ s), f (a, b) := by
  classical
  rw [finprod_mem_finset_product']
  simp
#align finprod_mem_finset_product finprod_mem_finset_product
#align finsum_mem_finset_product finsum_mem_finset_product
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b c) -/
#print finprod_mem_finset_product₃ /-
@[to_additive]
theorem finprod_mem_finset_product₃ {γ : Type _} (s : Finset (α × β × γ)) (f : α × β × γ → M) :
    ∏ᶠ (abc) (h : abc ∈ s), f abc = ∏ᶠ (a) (b) (c) (h : (a, b, c) ∈ s), f (a, b, c) := by
  classical
  rw [finprod_mem_finset_product']
  simp_rw [finprod_mem_finset_product']
  simp
#align finprod_mem_finset_product₃ finprod_mem_finset_product₃
#align finsum_mem_finset_product₃ finsum_mem_finset_product₃
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b) -/
#print finprod_curry /-
@[to_additive]
theorem finprod_curry (f : α × β → M) (hf : (mulSupport f).Finite) :
    ∏ᶠ ab, f ab = ∏ᶠ (a) (b), f (a, b) :=
  by
  have h₁ : ∀ a, ∏ᶠ h : a ∈ hf.to_finset, f a = f a := by simp
  have h₂ : ∏ᶠ a, f a = ∏ᶠ (a) (h : a ∈ hf.to_finset), f a := by simp
  simp_rw [h₂, finprod_mem_finset_product, h₁]
#align finprod_curry finprod_curry
#align finsum_curry finsum_curry
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:107:6: warning: expanding binder group (a b c) -/
#print finprod_curry₃ /-
@[to_additive]
theorem finprod_curry₃ {γ : Type _} (f : α × β × γ → M) (h : (mulSupport f).Finite) :
    ∏ᶠ abc, f abc = ∏ᶠ (a) (b) (c), f (a, b, c) := by rw [finprod_curry f h]; congr; ext a;
  rw [finprod_curry]; simp [h]
#align finprod_curry₃ finprod_curry₃
#align finsum_curry₃ finsum_curry₃
-/

#print finprod_dmem /-
@[to_additive]
theorem finprod_dmem {s : Set α} [DecidablePred (· ∈ s)] (f : ∀ a : α, a ∈ s → M) :
    ∏ᶠ (a : α) (h : a ∈ s), f a h = ∏ᶠ (a : α) (h : a ∈ s), if h' : a ∈ s then f a h' else 1 :=
  finprod_congr fun a => finprod_congr fun ha => (dif_pos ha).symm
#align finprod_dmem finprod_dmem
#align finsum_dmem finsum_dmem
-/

#print finprod_emb_domain' /-
@[to_additive]
theorem finprod_emb_domain' {f : α → β} (hf : Injective f) [DecidablePred (· ∈ Set.range f)]
    (g : α → M) :
    (∏ᶠ b : β, if h : b ∈ Set.range f then g (Classical.choose h) else 1) = ∏ᶠ a : α, g a :=
  by
  simp_rw [← finprod_eq_dif]
  rw [finprod_dmem, finprod_mem_range hf, finprod_congr fun a => _]
  rw [dif_pos (Set.mem_range_self a), hf (Classical.choose_spec (Set.mem_range_self a))]
#align finprod_emb_domain' finprod_emb_domain'
#align finsum_emb_domain' finsum_emb_domain'
-/

#print finprod_emb_domain /-
@[to_additive]
theorem finprod_emb_domain (f : α ↪ β) [DecidablePred (· ∈ Set.range f)] (g : α → M) :
    (∏ᶠ b : β, if h : b ∈ Set.range f then g (Classical.choose h) else 1) = ∏ᶠ a : α, g a :=
  finprod_emb_domain' f.Injective g
#align finprod_emb_domain finprod_emb_domain
#align finsum_emb_domain finsum_emb_domain
-/

end Type

