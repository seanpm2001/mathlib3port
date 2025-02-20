/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro, Kevin Buzzard, Yury Kudryashov, Frédéric Dupuis,
  Heather Macbeth

! This file was ported from Lean 3 source module linear_algebra.basic
! leanprover-community/mathlib commit 9d684a893c52e1d6692a504a118bfccbae04feeb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Pi
import Mathbin.Algebra.Module.Hom
import Mathbin.Algebra.Module.Prod
import Mathbin.Algebra.Module.Submodule.Lattice
import Mathbin.Data.Dfinsupp.Basic
import Mathbin.Data.Finsupp.Basic

/-!
# Linear algebra

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the basics of linear algebra. It sets up the "categorical/lattice structure" of
modules over a ring, submodules, and linear maps.

Many of the relevant definitions, including `module`, `submodule`, and `linear_map`, are found in
`src/algebra/module`.

## Main definitions

* Many constructors for (semi)linear maps
* The kernel `ker` and range `range` of a linear map are submodules of the domain and codomain
  respectively.

See `linear_algebra.span` for the span of a set (as a submodule),
and `linear_algebra.quotient` for quotients by submodules.

## Main theorems

See `linear_algebra.isomorphisms` for Noether's three isomorphism theorems for modules.

## Notations

* We continue to use the notations `M →ₛₗ[σ] M₂` and `M →ₗ[R] M₂` for the type of semilinear
  (resp. linear) maps from `M` to `M₂` over the ring homomorphism `σ` (resp. over the ring `R`).

## Implementation notes

We note that, when constructing linear maps, it is convenient to use operations defined on bundled
maps (`linear_map.prod`, `linear_map.coprod`, arithmetic operations like `+`) instead of defining a
function and proving it is linear.

## TODO

* Parts of this file have not yet been generalized to semilinear maps

## Tags
linear algebra, vector space, module

-/


open Function

open scoped BigOperators Pointwise

variable {R : Type _} {R₁ : Type _} {R₂ : Type _} {R₃ : Type _} {R₄ : Type _}

variable {S : Type _}

variable {K : Type _} {K₂ : Type _}

variable {M : Type _} {M' : Type _} {M₁ : Type _} {M₂ : Type _} {M₃ : Type _} {M₄ : Type _}

variable {N : Type _} {N₂ : Type _}

variable {ι : Type _}

variable {V : Type _} {V₂ : Type _}

namespace Finsupp

#print Finsupp.smul_sum /-
theorem smul_sum {α : Type _} {β : Type _} {R : Type _} {M : Type _} [Zero β] [AddCommMonoid M]
    [DistribSMul R M] {v : α →₀ β} {c : R} {h : α → β → M} :
    c • v.Sum h = v.Sum fun a b => c • h a b :=
  Finset.smul_sum
#align finsupp.smul_sum Finsupp.smul_sum
-/

#print Finsupp.sum_smul_index_linearMap' /-
@[simp]
theorem sum_smul_index_linearMap' {α : Type _} {R : Type _} {M : Type _} {M₂ : Type _} [Semiring R]
    [AddCommMonoid M] [Module R M] [AddCommMonoid M₂] [Module R M₂] {v : α →₀ M} {c : R}
    {h : α → M →ₗ[R] M₂} : ((c • v).Sum fun a => h a) = c • v.Sum fun a => h a :=
  by
  rw [Finsupp.sum_smul_index', Finsupp.smul_sum]
  · simp only [map_smul]
  · intro i; exact (h i).map_zero
#align finsupp.sum_smul_index_linear_map' Finsupp.sum_smul_index_linearMap'
-/

variable (α : Type _) [Finite α]

variable (R M) [AddCommMonoid M] [Semiring R] [Module R M]

#print Finsupp.linearEquivFunOnFinite /-
/-- Given `finite α`, `linear_equiv_fun_on_finite R` is the natural `R`-linear equivalence between
`α →₀ β` and `α → β`. -/
@[simps apply]
noncomputable def linearEquivFunOnFinite : (α →₀ M) ≃ₗ[R] α → M :=
  { equivFunOnFinite with
    toFun := coeFn
    map_add' := fun f g => rfl
    map_smul' := fun c f => rfl }
#align finsupp.linear_equiv_fun_on_finite Finsupp.linearEquivFunOnFinite
-/

#print Finsupp.linearEquivFunOnFinite_single /-
@[simp]
theorem linearEquivFunOnFinite_single [DecidableEq α] (x : α) (m : M) :
    (linearEquivFunOnFinite R M α) (single x m) = Pi.single x m :=
  equivFunOnFinite_single x m
#align finsupp.linear_equiv_fun_on_finite_single Finsupp.linearEquivFunOnFinite_single
-/

#print Finsupp.linearEquivFunOnFinite_symm_single /-
@[simp]
theorem linearEquivFunOnFinite_symm_single [DecidableEq α] (x : α) (m : M) :
    (linearEquivFunOnFinite R M α).symm (Pi.single x m) = single x m :=
  equivFunOnFinite_symm_single x m
#align finsupp.linear_equiv_fun_on_finite_symm_single Finsupp.linearEquivFunOnFinite_symm_single
-/

#print Finsupp.linearEquivFunOnFinite_symm_coe /-
@[simp]
theorem linearEquivFunOnFinite_symm_coe (f : α →₀ M) : (linearEquivFunOnFinite R M α).symm f = f :=
  (linearEquivFunOnFinite R M α).symm_apply_apply f
#align finsupp.linear_equiv_fun_on_finite_symm_coe Finsupp.linearEquivFunOnFinite_symm_coe
-/

#print Finsupp.LinearEquiv.finsuppUnique /-
/-- If `α` has a unique term, then the type of finitely supported functions `α →₀ M` is
`R`-linearly equivalent to `M`. -/
noncomputable def LinearEquiv.finsuppUnique (α : Type _) [Unique α] : (α →₀ M) ≃ₗ[R] M :=
  {
    Finsupp.equivFunOnFinite.trans
      (Equiv.funUnique α M) with
    map_add' := fun x y => rfl
    map_smul' := fun r x => rfl }
#align finsupp.linear_equiv.finsupp_unique Finsupp.LinearEquiv.finsuppUnique
-/

variable {R M α}

#print Finsupp.LinearEquiv.finsuppUnique_apply /-
@[simp]
theorem LinearEquiv.finsuppUnique_apply (α : Type _) [Unique α] (f : α →₀ M) :
    LinearEquiv.finsuppUnique R M α f = f default :=
  rfl
#align finsupp.linear_equiv.finsupp_unique_apply Finsupp.LinearEquiv.finsuppUnique_apply
-/

#print Finsupp.LinearEquiv.finsuppUnique_symm_apply /-
@[simp]
theorem LinearEquiv.finsuppUnique_symm_apply {α : Type _} [Unique α] (m : M) :
    (LinearEquiv.finsuppUnique R M α).symm m = Finsupp.single default m := by
  ext <;> simp [linear_equiv.finsupp_unique]
#align finsupp.linear_equiv.finsupp_unique_symm_apply Finsupp.LinearEquiv.finsuppUnique_symm_apply
-/

end Finsupp

#print pi_eq_sum_univ /-
/-- decomposing `x : ι → R` as a sum along the canonical basis -/
theorem pi_eq_sum_univ {ι : Type _} [Fintype ι] [DecidableEq ι] {R : Type _} [Semiring R]
    (x : ι → R) : x = ∑ i, x i • fun j => if i = j then 1 else 0 := by ext; simp
#align pi_eq_sum_univ pi_eq_sum_univ
-/

/-! ### Properties of linear maps -/


namespace LinearMap

section AddCommMonoid

variable [Semiring R] [Semiring R₂] [Semiring R₃] [Semiring R₄]

variable [AddCommMonoid M] [AddCommMonoid M₁] [AddCommMonoid M₂]

variable [AddCommMonoid M₃] [AddCommMonoid M₄]

variable [Module R M] [Module R M₁] [Module R₂ M₂] [Module R₃ M₃] [Module R₄ M₄]

variable {σ₁₂ : R →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₃₄ : R₃ →+* R₄}

variable {σ₁₃ : R →+* R₃} {σ₂₄ : R₂ →+* R₄} {σ₁₄ : R →+* R₄}

variable [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃] [RingHomCompTriple σ₂₃ σ₃₄ σ₂₄]

variable [RingHomCompTriple σ₁₃ σ₃₄ σ₁₄] [RingHomCompTriple σ₁₂ σ₂₄ σ₁₄]

variable (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₃] M₃)

#print LinearMap.map_sum /-
@[simp]
theorem map_sum {ι : Type _} {t : Finset ι} {g : ι → M} : f (∑ i in t, g i) = ∑ i in t, f (g i) :=
  f.toAddMonoidHom.map_sum _ _
#align linear_map.map_sum LinearMap.map_sum
-/

#print LinearMap.comp_assoc /-
theorem comp_assoc (h : M₃ →ₛₗ[σ₃₄] M₄) :
    ((h.comp g : M₂ →ₛₗ[σ₂₄] M₄).comp f : M →ₛₗ[σ₁₄] M₄) = h.comp (g.comp f : M →ₛₗ[σ₁₃] M₃) :=
  rfl
#align linear_map.comp_assoc LinearMap.comp_assoc
-/

#print LinearMap.domRestrict /-
/-- The restriction of a linear map `f : M → M₂` to a submodule `p ⊆ M` gives a linear map
`p → M₂`. -/
def domRestrict (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) : p →ₛₗ[σ₁₂] M₂ :=
  f.comp p.Subtype
#align linear_map.dom_restrict LinearMap.domRestrict
-/

#print LinearMap.domRestrict_apply /-
@[simp]
theorem domRestrict_apply (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) (x : p) :
    f.domRestrict p x = f x :=
  rfl
#align linear_map.dom_restrict_apply LinearMap.domRestrict_apply
-/

#print LinearMap.codRestrict /-
/-- A linear map `f : M₂ → M` whose values lie in a submodule `p ⊆ M` can be restricted to a
linear map M₂ → p. -/
def codRestrict (p : Submodule R₂ M₂) (f : M →ₛₗ[σ₁₂] M₂) (h : ∀ c, f c ∈ p) : M →ₛₗ[σ₁₂] p := by
  refine' { toFun := fun c => ⟨f c, h c⟩ .. } <;> intros <;> apply SetCoe.ext <;> simp
#align linear_map.cod_restrict LinearMap.codRestrict
-/

#print LinearMap.codRestrict_apply /-
@[simp]
theorem codRestrict_apply (p : Submodule R₂ M₂) (f : M →ₛₗ[σ₁₂] M₂) {h} (x : M) :
    (codRestrict p f h x : M₂) = f x :=
  rfl
#align linear_map.cod_restrict_apply LinearMap.codRestrict_apply
-/

#print LinearMap.comp_codRestrict /-
@[simp]
theorem comp_codRestrict (p : Submodule R₃ M₃) (h : ∀ b, g b ∈ p) :
    ((codRestrict p g h).comp f : M →ₛₗ[σ₁₃] p) = codRestrict p (g.comp f) fun b => h _ :=
  ext fun b => rfl
#align linear_map.comp_cod_restrict LinearMap.comp_codRestrict
-/

#print LinearMap.subtype_comp_codRestrict /-
@[simp]
theorem subtype_comp_codRestrict (p : Submodule R₂ M₂) (h : ∀ b, f b ∈ p) :
    p.Subtype.comp (codRestrict p f h) = f :=
  ext fun b => rfl
#align linear_map.subtype_comp_cod_restrict LinearMap.subtype_comp_codRestrict
-/

#print LinearMap.restrict /-
/-- Restrict domain and codomain of a linear map. -/
def restrict (f : M →ₗ[R] M₁) {p : Submodule R M} {q : Submodule R M₁} (hf : ∀ x ∈ p, f x ∈ q) :
    p →ₗ[R] q :=
  (f.domRestrict p).codRestrict q <| SetLike.forall.2 hf
#align linear_map.restrict LinearMap.restrict
-/

#print LinearMap.restrict_coe_apply /-
@[simp]
theorem restrict_coe_apply (f : M →ₗ[R] M₁) {p : Submodule R M} {q : Submodule R M₁}
    (hf : ∀ x ∈ p, f x ∈ q) (x : p) : ↑(f.restrict hf x) = f x :=
  rfl
#align linear_map.restrict_coe_apply LinearMap.restrict_coe_apply
-/

#print LinearMap.restrict_apply /-
theorem restrict_apply {f : M →ₗ[R] M₁} {p : Submodule R M} {q : Submodule R M₁}
    (hf : ∀ x ∈ p, f x ∈ q) (x : p) : f.restrict hf x = ⟨f x, hf x.1 x.2⟩ :=
  rfl
#align linear_map.restrict_apply LinearMap.restrict_apply
-/

#print LinearMap.subtype_comp_restrict /-
theorem subtype_comp_restrict {f : M →ₗ[R] M₁} {p : Submodule R M} {q : Submodule R M₁}
    (hf : ∀ x ∈ p, f x ∈ q) : q.Subtype.comp (f.restrict hf) = f.domRestrict p :=
  rfl
#align linear_map.subtype_comp_restrict LinearMap.subtype_comp_restrict
-/

#print LinearMap.restrict_eq_codRestrict_domRestrict /-
theorem restrict_eq_codRestrict_domRestrict {f : M →ₗ[R] M₁} {p : Submodule R M}
    {q : Submodule R M₁} (hf : ∀ x ∈ p, f x ∈ q) :
    f.restrict hf = (f.domRestrict p).codRestrict q fun x => hf x.1 x.2 :=
  rfl
#align linear_map.restrict_eq_cod_restrict_dom_restrict LinearMap.restrict_eq_codRestrict_domRestrict
-/

#print LinearMap.restrict_eq_domRestrict_codRestrict /-
theorem restrict_eq_domRestrict_codRestrict {f : M →ₗ[R] M₁} {p : Submodule R M}
    {q : Submodule R M₁} (hf : ∀ x, f x ∈ q) :
    (f.restrict fun x _ => hf x) = (f.codRestrict q hf).domRestrict p :=
  rfl
#align linear_map.restrict_eq_dom_restrict_cod_restrict LinearMap.restrict_eq_domRestrict_codRestrict
-/

#print LinearMap.uniqueOfLeft /-
instance uniqueOfLeft [Subsingleton M] : Unique (M →ₛₗ[σ₁₂] M₂) :=
  { LinearMap.inhabited with
    uniq := fun f => ext fun x => by rw [Subsingleton.elim x 0, map_zero, map_zero] }
#align linear_map.unique_of_left LinearMap.uniqueOfLeft
-/

#print LinearMap.uniqueOfRight /-
instance uniqueOfRight [Subsingleton M₂] : Unique (M →ₛₗ[σ₁₂] M₂) :=
  coe_injective.unique
#align linear_map.unique_of_right LinearMap.uniqueOfRight
-/

#print LinearMap.evalAddMonoidHom /-
/-- Evaluation of a `σ₁₂`-linear map at a fixed `a`, as an `add_monoid_hom`. -/
def evalAddMonoidHom (a : M) : (M →ₛₗ[σ₁₂] M₂) →+ M₂
    where
  toFun f := f a
  map_add' f g := LinearMap.add_apply f g a
  map_zero' := rfl
#align linear_map.eval_add_monoid_hom LinearMap.evalAddMonoidHom
-/

#print LinearMap.toAddMonoidHom' /-
/-- `linear_map.to_add_monoid_hom` promoted to an `add_monoid_hom` -/
def toAddMonoidHom' : (M →ₛₗ[σ₁₂] M₂) →+ M →+ M₂
    where
  toFun := toAddMonoidHom
  map_zero' := by ext <;> rfl
  map_add' := by intros <;> ext <;> rfl
#align linear_map.to_add_monoid_hom' LinearMap.toAddMonoidHom'
-/

#print LinearMap.sum_apply /-
theorem sum_apply (t : Finset ι) (f : ι → M →ₛₗ[σ₁₂] M₂) (b : M) :
    (∑ d in t, f d) b = ∑ d in t, f d b :=
  AddMonoidHom.map_sum ((AddMonoidHom.eval b).comp toAddMonoidHom') f _
#align linear_map.sum_apply LinearMap.sum_apply
-/

section SmulRight

variable [Semiring S] [Module R S] [Module S M] [IsScalarTower R S M]

#print LinearMap.smulRight /-
/-- When `f` is an `R`-linear map taking values in `S`, then `λb, f b • x` is an `R`-linear map. -/
def smulRight (f : M₁ →ₗ[R] S) (x : M) : M₁ →ₗ[R] M
    where
  toFun b := f b • x
  map_add' x y := by rw [f.map_add, add_smul]
  map_smul' b y := by dsimp <;> rw [map_smul, smul_assoc]
#align linear_map.smul_right LinearMap.smulRight
-/

#print LinearMap.coe_smulRight /-
@[simp]
theorem coe_smulRight (f : M₁ →ₗ[R] S) (x : M) : (smulRight f x : M₁ → M) = fun c => f c • x :=
  rfl
#align linear_map.coe_smul_right LinearMap.coe_smulRight
-/

#print LinearMap.smulRight_apply /-
theorem smulRight_apply (f : M₁ →ₗ[R] S) (x : M) (c : M₁) : smulRight f x c = f c • x :=
  rfl
#align linear_map.smul_right_apply LinearMap.smulRight_apply
-/

end SmulRight

instance [Nontrivial M] : Nontrivial (Module.End R M) :=
  by
  obtain ⟨m, ne⟩ := (nontrivial_iff_exists_ne (0 : M)).mp inferInstance
  exact nontrivial_of_ne 1 0 fun p => Ne (LinearMap.congr_fun p m)

#print LinearMap.coeFn_sum /-
@[simp, norm_cast]
theorem coeFn_sum {ι : Type _} (t : Finset ι) (f : ι → M →ₛₗ[σ₁₂] M₂) :
    ⇑(∑ i in t, f i) = ∑ i in t, (f i : M → M₂) :=
  AddMonoidHom.map_sum ⟨@toFun R R₂ _ _ σ₁₂ M M₂ _ _ _ _, rfl, fun x y => rfl⟩ _ _
#align linear_map.coe_fn_sum LinearMap.coeFn_sum
-/

#print LinearMap.pow_apply /-
@[simp]
theorem pow_apply (f : M →ₗ[R] M) (n : ℕ) (m : M) : (f ^ n) m = (f^[n]) m :=
  by
  induction' n with n ih
  · rfl
  · simp only [Function.comp_apply, Function.iterate_succ, LinearMap.mul_apply, pow_succ, ih]
    exact (Function.Commute.iterate_self _ _ m).symm
#align linear_map.pow_apply LinearMap.pow_apply
-/

#print LinearMap.pow_map_zero_of_le /-
theorem pow_map_zero_of_le {f : Module.End R M} {m : M} {k l : ℕ} (hk : k ≤ l)
    (hm : (f ^ k) m = 0) : (f ^ l) m = 0 := by
  rw [← tsub_add_cancel_of_le hk, pow_add, mul_apply, hm, map_zero]
#align linear_map.pow_map_zero_of_le LinearMap.pow_map_zero_of_le
-/

#print LinearMap.commute_pow_left_of_commute /-
theorem commute_pow_left_of_commute {f : M →ₛₗ[σ₁₂] M₂} {g : Module.End R M} {g₂ : Module.End R₂ M₂}
    (h : g₂.comp f = f.comp g) (k : ℕ) : (g₂ ^ k).comp f = f.comp (g ^ k) :=
  by
  induction' k with k ih
  · simpa only [pow_zero]
  ·
    rw [pow_succ, pow_succ, LinearMap.mul_eq_comp, LinearMap.comp_assoc, ih, ← LinearMap.comp_assoc,
      h, LinearMap.comp_assoc, LinearMap.mul_eq_comp]
#align linear_map.commute_pow_left_of_commute LinearMap.commute_pow_left_of_commute
-/

#print LinearMap.submodule_pow_eq_zero_of_pow_eq_zero /-
theorem submodule_pow_eq_zero_of_pow_eq_zero {N : Submodule R M} {g : Module.End R N}
    {G : Module.End R M} (h : G.comp N.Subtype = N.Subtype.comp g) {k : ℕ} (hG : G ^ k = 0) :
    g ^ k = 0 := by
  ext m
  have hg : N.subtype.comp (g ^ k) m = 0 := by
    rw [← commute_pow_left_of_commute h, hG, zero_comp, zero_apply]
  simp only [Submodule.subtype_apply, comp_app, Submodule.coe_eq_zero, coe_comp] at hg 
  rw [hg, LinearMap.zero_apply]
#align linear_map.submodule_pow_eq_zero_of_pow_eq_zero LinearMap.submodule_pow_eq_zero_of_pow_eq_zero
-/

#print LinearMap.coe_pow /-
theorem coe_pow (f : M →ₗ[R] M) (n : ℕ) : ⇑(f ^ n) = f^[n] := by ext m; apply pow_apply
#align linear_map.coe_pow LinearMap.coe_pow
-/

#print LinearMap.id_pow /-
@[simp]
theorem id_pow (n : ℕ) : (id : M →ₗ[R] M) ^ n = id :=
  one_pow n
#align linear_map.id_pow LinearMap.id_pow
-/

section

variable {f' : M →ₗ[R] M}

#print LinearMap.iterate_succ /-
theorem iterate_succ (n : ℕ) : f' ^ (n + 1) = comp (f' ^ n) f' := by rw [pow_succ', mul_eq_comp]
#align linear_map.iterate_succ LinearMap.iterate_succ
-/

#print LinearMap.iterate_surjective /-
theorem iterate_surjective (h : Surjective f') : ∀ n : ℕ, Surjective ⇑(f' ^ n)
  | 0 => surjective_id
  | n + 1 => by rw [iterate_succ]; exact surjective.comp (iterate_surjective n) h
#align linear_map.iterate_surjective LinearMap.iterate_surjective
-/

#print LinearMap.iterate_injective /-
theorem iterate_injective (h : Injective f') : ∀ n : ℕ, Injective ⇑(f' ^ n)
  | 0 => injective_id
  | n + 1 => by rw [iterate_succ]; exact injective.comp (iterate_injective n) h
#align linear_map.iterate_injective LinearMap.iterate_injective
-/

#print LinearMap.iterate_bijective /-
theorem iterate_bijective (h : Bijective f') : ∀ n : ℕ, Bijective ⇑(f' ^ n)
  | 0 => bijective_id
  | n + 1 => by rw [iterate_succ]; exact bijective.comp (iterate_bijective n) h
#align linear_map.iterate_bijective LinearMap.iterate_bijective
-/

#print LinearMap.injective_of_iterate_injective /-
theorem injective_of_iterate_injective {n : ℕ} (hn : n ≠ 0) (h : Injective ⇑(f' ^ n)) :
    Injective f' :=
  by
  rw [← Nat.succ_pred_eq_of_pos (pos_iff_ne_zero.mpr hn), iterate_succ, coe_comp] at h 
  exact injective.of_comp h
#align linear_map.injective_of_iterate_injective LinearMap.injective_of_iterate_injective
-/

#print LinearMap.surjective_of_iterate_surjective /-
theorem surjective_of_iterate_surjective {n : ℕ} (hn : n ≠ 0) (h : Surjective ⇑(f' ^ n)) :
    Surjective f' :=
  by
  rw [← Nat.succ_pred_eq_of_pos (pos_iff_ne_zero.mpr hn), Nat.succ_eq_add_one, add_comm, pow_add] at
    h 
  exact surjective.of_comp h
#align linear_map.surjective_of_iterate_surjective LinearMap.surjective_of_iterate_surjective
-/

#print LinearMap.pow_apply_mem_of_forall_mem /-
theorem pow_apply_mem_of_forall_mem {p : Submodule R M} (n : ℕ) (h : ∀ x ∈ p, f' x ∈ p) (x : M)
    (hx : x ∈ p) : (f' ^ n) x ∈ p :=
  by
  induction' n with n ih generalizing x; · simpa
  simpa only [iterate_succ, coe_comp, Function.comp_apply, restrict_apply] using ih _ (h _ hx)
#align linear_map.pow_apply_mem_of_forall_mem LinearMap.pow_apply_mem_of_forall_mem
-/

#print LinearMap.pow_restrict /-
theorem pow_restrict {p : Submodule R M} (n : ℕ) (h : ∀ x ∈ p, f' x ∈ p)
    (h' := pow_apply_mem_of_forall_mem n h) : f'.restrict h ^ n = (f' ^ n).restrict h' :=
  by
  induction' n with n ih <;> ext
  · simp [restrict_apply]
  · simp [restrict_apply, LinearMap.iterate_succ, -LinearMap.pow_apply, ih]
#align linear_map.pow_restrict LinearMap.pow_restrict
-/

end

#print LinearMap.pi_apply_eq_sum_univ /-
/-- A linear map `f` applied to `x : ι → R` can be computed using the image under `f` of elements
of the canonical basis. -/
theorem pi_apply_eq_sum_univ [Fintype ι] [DecidableEq ι] (f : (ι → R) →ₗ[R] M) (x : ι → R) :
    f x = ∑ i, x i • f fun j => if i = j then 1 else 0 :=
  by
  conv_lhs => rw [pi_eq_sum_univ x, f.map_sum]
  apply Finset.sum_congr rfl fun l hl => _
  rw [map_smul]
#align linear_map.pi_apply_eq_sum_univ LinearMap.pi_apply_eq_sum_univ
-/

end AddCommMonoid

section Module

variable [Semiring R] [Semiring S] [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]
  [Module R M] [Module R M₂] [Module R M₃] [Module S M₂] [Module S M₃] [SMulCommClass R S M₂]
  [SMulCommClass R S M₃] (f : M →ₗ[R] M₂)

variable (S)

#print LinearMap.applyₗ' /-
/-- Applying a linear map at `v : M`, seen as `S`-linear map from `M →ₗ[R] M₂` to `M₂`.

 See `linear_map.applyₗ` for a version where `S = R`. -/
@[simps]
def applyₗ' : M →+ (M →ₗ[R] M₂) →ₗ[S] M₂
    where
  toFun v :=
    { toFun := fun f => f v
      map_add' := fun f g => f.add_apply g v
      map_smul' := fun x f => f.smul_apply x v }
  map_zero' := LinearMap.ext fun f => f.map_zero
  map_add' x y := LinearMap.ext fun f => f.map_add _ _
#align linear_map.applyₗ' LinearMap.applyₗ'
-/

section

variable (R M)

#print LinearMap.ringLmapEquivSelf /-
/-- The equivalence between R-linear maps from `R` to `M`, and points of `M` itself.
This says that the forgetful functor from `R`-modules to types is representable, by `R`.

This as an `S`-linear equivalence, under the assumption that `S` acts on `M` commuting with `R`.
When `R` is commutative, we can take this to be the usual action with `S = R`.
Otherwise, `S = ℕ` shows that the equivalence is additive.
See note [bundled maps over different rings].
-/
@[simps]
def ringLmapEquivSelf [Module S M] [SMulCommClass R S M] : (R →ₗ[R] M) ≃ₗ[S] M :=
  { applyₗ' S (1 : R) with
    toFun := fun f => f 1
    invFun := smulRight (1 : R →ₗ[R] R)
    left_inv := fun f => by ext; simp
    right_inv := fun x => by simp }
#align linear_map.ring_lmap_equiv_self LinearMap.ringLmapEquivSelf
-/

end

end Module

section CommSemiring

variable [CommSemiring R] [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [Module R M] [Module R M₂] [Module R M₃]

variable (f g : M →ₗ[R] M₂)

#print LinearMap.compRight /-
/-- Composition by `f : M₂ → M₃` is a linear map from the space of linear maps `M → M₂`
to the space of linear maps `M₂ → M₃`. -/
def compRight (f : M₂ →ₗ[R] M₃) : (M →ₗ[R] M₂) →ₗ[R] M →ₗ[R] M₃
    where
  toFun := f.comp
  map_add' _ _ := LinearMap.ext fun _ => map_add f _ _
  map_smul' _ _ := LinearMap.ext fun _ => map_smul f _ _
#align linear_map.comp_right LinearMap.compRight
-/

#print LinearMap.compRight_apply /-
@[simp]
theorem compRight_apply (f : M₂ →ₗ[R] M₃) (g : M →ₗ[R] M₂) : compRight f g = f.comp g :=
  rfl
#align linear_map.comp_right_apply LinearMap.compRight_apply
-/

#print LinearMap.applyₗ /-
/-- Applying a linear map at `v : M`, seen as a linear map from `M →ₗ[R] M₂` to `M₂`.
See also `linear_map.applyₗ'` for a version that works with two different semirings.

This is the `linear_map` version of `add_monoid_hom.eval`. -/
@[simps]
def applyₗ : M →ₗ[R] (M →ₗ[R] M₂) →ₗ[R] M₂ :=
  { applyₗ' R with
    toFun := fun v => { applyₗ' R v with toFun := fun f => f v }
    map_smul' := fun x y => LinearMap.ext fun f => map_smul f _ _ }
#align linear_map.applyₗ LinearMap.applyₗ
-/

#print LinearMap.domRestrict' /-
/-- Alternative version of `dom_restrict` as a linear map. -/
def domRestrict' (p : Submodule R M) : (M →ₗ[R] M₂) →ₗ[R] p →ₗ[R] M₂
    where
  toFun φ := φ.domRestrict p
  map_add' := by simp [LinearMap.ext_iff]
  map_smul' := by simp [LinearMap.ext_iff]
#align linear_map.dom_restrict' LinearMap.domRestrict'
-/

#print LinearMap.domRestrict'_apply /-
@[simp]
theorem domRestrict'_apply (f : M →ₗ[R] M₂) (p : Submodule R M) (x : p) :
    domRestrict' p f x = f x :=
  rfl
#align linear_map.dom_restrict'_apply LinearMap.domRestrict'_apply
-/

#print LinearMap.smulRightₗ /-
/--
The family of linear maps `M₂ → M` parameterised by `f ∈ M₂ → R`, `x ∈ M`, is linear in `f`, `x`.
-/
def smulRightₗ : (M₂ →ₗ[R] R) →ₗ[R] M →ₗ[R] M₂ →ₗ[R] M
    where
  toFun f :=
    { toFun := LinearMap.smulRight f
      map_add' := fun m m' => by ext; apply smul_add
      map_smul' := fun c m => by ext; apply smul_comm }
  map_add' f f' := by ext; apply add_smul
  map_smul' c f := by ext; apply mul_smul
#align linear_map.smul_rightₗ LinearMap.smulRightₗ
-/

#print LinearMap.smulRightₗ_apply /-
@[simp]
theorem smulRightₗ_apply (f : M₂ →ₗ[R] R) (x : M) (c : M₂) :
    (smulRightₗ : (M₂ →ₗ[R] R) →ₗ[R] M →ₗ[R] M₂ →ₗ[R] M) f x c = f c • x :=
  rfl
#align linear_map.smul_rightₗ_apply LinearMap.smulRightₗ_apply
-/

end CommSemiring

end LinearMap

#print addMonoidHomLequivNat /-
/--
The `R`-linear equivalence between additive morphisms `A →+ B` and `ℕ`-linear morphisms `A →ₗ[ℕ] B`.
-/
@[simps]
def addMonoidHomLequivNat {A B : Type _} (R : Type _) [Semiring R] [AddCommMonoid A]
    [AddCommMonoid B] [Module R B] : (A →+ B) ≃ₗ[R] A →ₗ[ℕ] B
    where
  toFun := AddMonoidHom.toNatLinearMap
  invFun := LinearMap.toAddMonoidHom
  map_add' := by intros; ext; rfl
  map_smul' := by intros; ext; rfl
  left_inv := by intro f; ext; rfl
  right_inv := by intro f; ext; rfl
#align add_monoid_hom_lequiv_nat addMonoidHomLequivNat
-/

#print addMonoidHomLequivInt /-
/--
The `R`-linear equivalence between additive morphisms `A →+ B` and `ℤ`-linear morphisms `A →ₗ[ℤ] B`.
-/
@[simps]
def addMonoidHomLequivInt {A B : Type _} (R : Type _) [Semiring R] [AddCommGroup A] [AddCommGroup B]
    [Module R B] : (A →+ B) ≃ₗ[R] A →ₗ[ℤ] B
    where
  toFun := AddMonoidHom.toIntLinearMap
  invFun := LinearMap.toAddMonoidHom
  map_add' := by intros; ext; rfl
  map_smul' := by intros; ext; rfl
  left_inv := by intro f; ext; rfl
  right_inv := by intro f; ext; rfl
#align add_monoid_hom_lequiv_int addMonoidHomLequivInt
-/

/-! ### Properties of submodules -/


namespace Submodule

section AddCommMonoid

variable [Semiring R] [Semiring R₂] [Semiring R₃]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M']

variable [Module R M] [Module R M'] [Module R₂ M₂] [Module R₃ M₃]

variable {σ₁₂ : R →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R →+* R₃}

variable {σ₂₁ : R₂ →+* R}

variable [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂]

variable [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable (p p' : Submodule R M) (q q' : Submodule R₂ M₂)

variable (q₁ q₁' : Submodule R M')

variable {r : R} {x y : M}

open Set

variable {p p'}

#print Submodule.ofLe /-
/-- If two submodules `p` and `p'` satisfy `p ⊆ p'`, then `of_le p p'` is the linear map version of
this inclusion. -/
def ofLe (h : p ≤ p') : p →ₗ[R] p' :=
  p.Subtype.codRestrict p' fun ⟨x, hx⟩ => h hx
#align submodule.of_le Submodule.ofLe
-/

#print Submodule.coe_ofLe /-
@[simp]
theorem coe_ofLe (h : p ≤ p') (x : p) : (ofLe h x : M) = x :=
  rfl
#align submodule.coe_of_le Submodule.coe_ofLe
-/

#print Submodule.ofLe_apply /-
theorem ofLe_apply (h : p ≤ p') (x : p) : ofLe h x = ⟨x, h x.2⟩ :=
  rfl
#align submodule.of_le_apply Submodule.ofLe_apply
-/

#print Submodule.ofLe_injective /-
theorem ofLe_injective (h : p ≤ p') : Function.Injective (ofLe h) := fun x y h =>
  Subtype.val_injective (Subtype.mk.inj h)
#align submodule.of_le_injective Submodule.ofLe_injective
-/

variable (p p')

#print Submodule.subtype_comp_ofLe /-
theorem subtype_comp_ofLe (p q : Submodule R M) (h : p ≤ q) : q.Subtype.comp (ofLe h) = p.Subtype :=
  by ext ⟨b, hb⟩; rfl
#align submodule.subtype_comp_of_le Submodule.subtype_comp_ofLe
-/

variable (R)

#print Submodule.subsingleton_iff /-
@[simp]
theorem subsingleton_iff : Subsingleton (Submodule R M) ↔ Subsingleton M :=
  have h : Subsingleton (Submodule R M) ↔ Subsingleton (AddSubmonoid M) :=
    by
    rw [← subsingleton_iff_bot_eq_top, ← subsingleton_iff_bot_eq_top]
    convert to_add_submonoid_eq.symm <;> rfl
  h.trans AddSubmonoid.subsingleton_iff
#align submodule.subsingleton_iff Submodule.subsingleton_iff
-/

#print Submodule.nontrivial_iff /-
@[simp]
theorem nontrivial_iff : Nontrivial (Submodule R M) ↔ Nontrivial M :=
  not_iff_not.mp
    ((not_nontrivial_iff_subsingleton.trans <| subsingleton_iff R).trans
      not_nontrivial_iff_subsingleton.symm)
#align submodule.nontrivial_iff Submodule.nontrivial_iff
-/

variable {R}

instance [Subsingleton M] : Unique (Submodule R M) :=
  ⟨⟨⊥⟩, fun a => @Subsingleton.elim _ ((subsingleton_iff R).mpr ‹_›) a _⟩

#print Submodule.unique' /-
instance unique' [Subsingleton R] : Unique (Submodule R M) := by
  haveI := Module.subsingleton R M <;> infer_instance
#align submodule.unique' Submodule.unique'
-/

instance [Nontrivial M] : Nontrivial (Submodule R M) :=
  (nontrivial_iff R).mpr ‹_›

#print Submodule.mem_right_iff_eq_zero_of_disjoint /-
theorem mem_right_iff_eq_zero_of_disjoint {p p' : Submodule R M} (h : Disjoint p p') {x : p} :
    (x : M) ∈ p' ↔ x = 0 :=
  ⟨fun hx => coe_eq_zero.1 <| disjoint_def.1 h x x.2 hx, fun h => h.symm ▸ p'.zero_mem⟩
#align submodule.mem_right_iff_eq_zero_of_disjoint Submodule.mem_right_iff_eq_zero_of_disjoint
-/

#print Submodule.mem_left_iff_eq_zero_of_disjoint /-
theorem mem_left_iff_eq_zero_of_disjoint {p p' : Submodule R M} (h : Disjoint p p') {x : p'} :
    (x : M) ∈ p ↔ x = 0 :=
  ⟨fun hx => coe_eq_zero.1 <| disjoint_def.1 h x hx x.2, fun h => h.symm ▸ p.zero_mem⟩
#align submodule.mem_left_iff_eq_zero_of_disjoint Submodule.mem_left_iff_eq_zero_of_disjoint
-/

section

variable [RingHomSurjective σ₁₂] {F : Type _} [sc : SemilinearMapClass F σ₁₂ M M₂]

#print Submodule.map /-
/-- The pushforward of a submodule `p ⊆ M` by `f : M → M₂` -/
def map (f : F) (p : Submodule R M) : Submodule R₂ M₂ :=
  { p.toAddSubmonoid.map f with
    carrier := f '' p
    smul_mem' := by
      rintro c x ⟨y, hy, rfl⟩
      obtain ⟨a, rfl⟩ := σ₁₂.is_surjective c
      exact ⟨_, p.smul_mem a hy, map_smulₛₗ f _ _⟩ }
#align submodule.map Submodule.map
-/

#print Submodule.map_coe /-
@[simp]
theorem map_coe (f : F) (p : Submodule R M) : (map f p : Set M₂) = f '' p :=
  rfl
#align submodule.map_coe Submodule.map_coe
-/

#print Submodule.map_toAddSubmonoid /-
theorem map_toAddSubmonoid (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) :
    (p.map f).toAddSubmonoid = p.toAddSubmonoid.map (f : M →+ M₂) :=
  SetLike.coe_injective rfl
#align submodule.map_to_add_submonoid Submodule.map_toAddSubmonoid
-/

#print Submodule.map_to_add_submonoid' /-
theorem map_to_add_submonoid' (f : M →ₛₗ[σ₁₂] M₂) (p : Submodule R M) :
    (p.map f).toAddSubmonoid = p.toAddSubmonoid.map f :=
  SetLike.coe_injective rfl
#align submodule.map_to_add_submonoid' Submodule.map_to_add_submonoid'
-/

#print Submodule.mem_map /-
@[simp]
theorem mem_map {f : F} {p : Submodule R M} {x : M₂} : x ∈ map f p ↔ ∃ y, y ∈ p ∧ f y = x :=
  Iff.rfl
#align submodule.mem_map Submodule.mem_map
-/

#print Submodule.mem_map_of_mem /-
theorem mem_map_of_mem {f : F} {p : Submodule R M} {r} (h : r ∈ p) : f r ∈ map f p :=
  Set.mem_image_of_mem _ h
#align submodule.mem_map_of_mem Submodule.mem_map_of_mem
-/

#print Submodule.apply_coe_mem_map /-
theorem apply_coe_mem_map (f : F) {p : Submodule R M} (r : p) : f r ∈ map f p :=
  mem_map_of_mem r.Prop
#align submodule.apply_coe_mem_map Submodule.apply_coe_mem_map
-/

#print Submodule.map_id /-
@[simp]
theorem map_id : map (LinearMap.id : M →ₗ[R] M) p = p :=
  Submodule.ext fun a => by simp
#align submodule.map_id Submodule.map_id
-/

#print Submodule.map_comp /-
theorem map_comp [RingHomSurjective σ₂₃] [RingHomSurjective σ₁₃] (f : M →ₛₗ[σ₁₂] M₂)
    (g : M₂ →ₛₗ[σ₂₃] M₃) (p : Submodule R M) : map (g.comp f : M →ₛₗ[σ₁₃] M₃) p = map g (map f p) :=
  SetLike.coe_injective <| by simp only [← image_comp, map_coe, LinearMap.coe_comp, comp_app]
#align submodule.map_comp Submodule.map_comp
-/

#print Submodule.map_mono /-
theorem map_mono {f : F} {p p' : Submodule R M} : p ≤ p' → map f p ≤ map f p' :=
  image_subset _
#align submodule.map_mono Submodule.map_mono
-/

#print Submodule.map_zero /-
@[simp]
theorem map_zero : map (0 : M →ₛₗ[σ₁₂] M₂) p = ⊥ :=
  have : ∃ x : M, x ∈ p := ⟨0, p.zero_mem⟩
  ext <| by simp [this, eq_comm]
#align submodule.map_zero Submodule.map_zero
-/

#print Submodule.map_add_le /-
theorem map_add_le (f g : M →ₛₗ[σ₁₂] M₂) : map (f + g) p ≤ map f p ⊔ map g p :=
  by
  rintro x ⟨m, hm, rfl⟩
  exact add_mem_sup (mem_map_of_mem hm) (mem_map_of_mem hm)
#align submodule.map_add_le Submodule.map_add_le
-/

#print Submodule.range_map_nonempty /-
theorem range_map_nonempty (N : Submodule R M) :
    (Set.range (fun ϕ => Submodule.map ϕ N : (M →ₛₗ[σ₁₂] M₂) → Submodule R₂ M₂)).Nonempty :=
  ⟨_, Set.mem_range.mpr ⟨0, rfl⟩⟩
#align submodule.range_map_nonempty Submodule.range_map_nonempty
-/

end

variable {F : Type _} [sc : SemilinearMapClass F σ₁₂ M M₂]

#print Submodule.equivMapOfInjective /-
/-- The pushforward of a submodule by an injective linear map is
linearly equivalent to the original submodule. See also `linear_equiv.submodule_map` for a
computable version when `f` has an explicit inverse. -/
noncomputable def equivMapOfInjective (f : F) (i : Injective f) (p : Submodule R M) :
    p ≃ₛₗ[σ₁₂] p.map f :=
  {
    Equiv.Set.image f p
      i with
    map_add' := by
      intros; simp only [coe_add, map_add, Equiv.toFun_as_coe, Equiv.Set.image_apply]
      rfl
    map_smul' := by
      intros; simp only [coe_smul_of_tower, map_smulₛₗ, Equiv.toFun_as_coe, Equiv.Set.image_apply]
      rfl }
#align submodule.equiv_map_of_injective Submodule.equivMapOfInjective
-/

#print Submodule.coe_equivMapOfInjective_apply /-
@[simp]
theorem coe_equivMapOfInjective_apply (f : F) (i : Injective f) (p : Submodule R M) (x : p) :
    (equivMapOfInjective f i p x : M₂) = f x :=
  rfl
#align submodule.coe_equiv_map_of_injective_apply Submodule.coe_equivMapOfInjective_apply
-/

#print Submodule.comap /-
/-- The pullback of a submodule `p ⊆ M₂` along `f : M → M₂` -/
def comap (f : F) (p : Submodule R₂ M₂) : Submodule R M :=
  { p.toAddSubmonoid.comap f with
    carrier := f ⁻¹' p
    smul_mem' := fun a x h => by simp [p.smul_mem _ h] }
#align submodule.comap Submodule.comap
-/

#print Submodule.comap_coe /-
@[simp]
theorem comap_coe (f : F) (p : Submodule R₂ M₂) : (comap f p : Set M) = f ⁻¹' p :=
  rfl
#align submodule.comap_coe Submodule.comap_coe
-/

#print Submodule.mem_comap /-
@[simp]
theorem mem_comap {f : F} {p : Submodule R₂ M₂} : x ∈ comap f p ↔ f x ∈ p :=
  Iff.rfl
#align submodule.mem_comap Submodule.mem_comap
-/

#print Submodule.comap_id /-
@[simp]
theorem comap_id : comap (LinearMap.id : M →ₗ[R] M) p = p :=
  SetLike.coe_injective rfl
#align submodule.comap_id Submodule.comap_id
-/

#print Submodule.comap_comp /-
theorem comap_comp (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₃] M₃) (p : Submodule R₃ M₃) :
    comap (g.comp f : M →ₛₗ[σ₁₃] M₃) p = comap f (comap g p) :=
  rfl
#align submodule.comap_comp Submodule.comap_comp
-/

#print Submodule.comap_mono /-
theorem comap_mono {f : F} {q q' : Submodule R₂ M₂} : q ≤ q' → comap f q ≤ comap f q' :=
  preimage_mono
#align submodule.comap_mono Submodule.comap_mono
-/

#print Submodule.le_comap_pow_of_le_comap /-
theorem le_comap_pow_of_le_comap (p : Submodule R M) {f : M →ₗ[R] M} (h : p ≤ p.comap f) (k : ℕ) :
    p ≤ p.comap (f ^ k) := by
  induction' k with k ih
  · simp [LinearMap.one_eq_id]
  · simp [LinearMap.iterate_succ, comap_comp, h.trans (comap_mono ih)]
#align submodule.le_comap_pow_of_le_comap Submodule.le_comap_pow_of_le_comap
-/

section

variable [RingHomSurjective σ₁₂]

#print Submodule.map_le_iff_le_comap /-
theorem map_le_iff_le_comap {f : F} {p : Submodule R M} {q : Submodule R₂ M₂} :
    map f p ≤ q ↔ p ≤ comap f q :=
  image_subset_iff
#align submodule.map_le_iff_le_comap Submodule.map_le_iff_le_comap
-/

#print Submodule.gc_map_comap /-
theorem gc_map_comap (f : F) : GaloisConnection (map f) (comap f)
  | p, q => map_le_iff_le_comap
#align submodule.gc_map_comap Submodule.gc_map_comap
-/

#print Submodule.map_bot /-
@[simp]
theorem map_bot (f : F) : map f ⊥ = ⊥ :=
  (gc_map_comap f).l_bot
#align submodule.map_bot Submodule.map_bot
-/

#print Submodule.map_sup /-
@[simp]
theorem map_sup (f : F) : map f (p ⊔ p') = map f p ⊔ map f p' :=
  (gc_map_comap f : GaloisConnection (map f) (comap f)).l_sup
#align submodule.map_sup Submodule.map_sup
-/

#print Submodule.map_iSup /-
@[simp]
theorem map_iSup {ι : Sort _} (f : F) (p : ι → Submodule R M) :
    map f (⨆ i, p i) = ⨆ i, map f (p i) :=
  (gc_map_comap f : GaloisConnection (map f) (comap f)).l_iSup
#align submodule.map_supr Submodule.map_iSup
-/

end

#print Submodule.comap_top /-
@[simp]
theorem comap_top (f : F) : comap f ⊤ = ⊤ :=
  rfl
#align submodule.comap_top Submodule.comap_top
-/

#print Submodule.comap_inf /-
@[simp]
theorem comap_inf (f : F) : comap f (q ⊓ q') = comap f q ⊓ comap f q' :=
  rfl
#align submodule.comap_inf Submodule.comap_inf
-/

#print Submodule.comap_iInf /-
@[simp]
theorem comap_iInf [RingHomSurjective σ₁₂] {ι : Sort _} (f : F) (p : ι → Submodule R₂ M₂) :
    comap f (⨅ i, p i) = ⨅ i, comap f (p i) :=
  (gc_map_comap f : GaloisConnection (map f) (comap f)).u_iInf
#align submodule.comap_infi Submodule.comap_iInf
-/

#print Submodule.comap_zero /-
@[simp]
theorem comap_zero : comap (0 : M →ₛₗ[σ₁₂] M₂) q = ⊤ :=
  ext <| by simp
#align submodule.comap_zero Submodule.comap_zero
-/

#print Submodule.map_comap_le /-
theorem map_comap_le [RingHomSurjective σ₁₂] (f : F) (q : Submodule R₂ M₂) :
    map f (comap f q) ≤ q :=
  (gc_map_comap f).l_u_le _
#align submodule.map_comap_le Submodule.map_comap_le
-/

#print Submodule.le_comap_map /-
theorem le_comap_map [RingHomSurjective σ₁₂] (f : F) (p : Submodule R M) : p ≤ comap f (map f p) :=
  (gc_map_comap f).le_u_l _
#align submodule.le_comap_map Submodule.le_comap_map
-/

section GaloisInsertion

variable {f : F} (hf : Surjective f)

variable [RingHomSurjective σ₁₂]

#print Submodule.giMapComap /-
/-- `map f` and `comap f` form a `galois_insertion` when `f` is surjective. -/
def giMapComap : GaloisInsertion (map f) (comap f) :=
  (gc_map_comap f).toGaloisInsertion fun S x hx =>
    by
    rcases hf x with ⟨y, rfl⟩
    simp only [mem_map, mem_comap]
    exact ⟨y, hx, rfl⟩
#align submodule.gi_map_comap Submodule.giMapComap
-/

#print Submodule.map_comap_eq_of_surjective /-
theorem map_comap_eq_of_surjective (p : Submodule R₂ M₂) : (p.comap f).map f = p :=
  (giMapComap hf).l_u_eq _
#align submodule.map_comap_eq_of_surjective Submodule.map_comap_eq_of_surjective
-/

#print Submodule.map_surjective_of_surjective /-
theorem map_surjective_of_surjective : Function.Surjective (map f) :=
  (giMapComap hf).l_surjective
#align submodule.map_surjective_of_surjective Submodule.map_surjective_of_surjective
-/

#print Submodule.comap_injective_of_surjective /-
theorem comap_injective_of_surjective : Function.Injective (comap f) :=
  (giMapComap hf).u_injective
#align submodule.comap_injective_of_surjective Submodule.comap_injective_of_surjective
-/

#print Submodule.map_sup_comap_of_surjective /-
theorem map_sup_comap_of_surjective (p q : Submodule R₂ M₂) :
    (p.comap f ⊔ q.comap f).map f = p ⊔ q :=
  (giMapComap hf).l_sup_u _ _
#align submodule.map_sup_comap_of_surjective Submodule.map_sup_comap_of_surjective
-/

#print Submodule.map_iSup_comap_of_sujective /-
theorem map_iSup_comap_of_sujective {ι : Sort _} (S : ι → Submodule R₂ M₂) :
    (⨆ i, (S i).comap f).map f = iSup S :=
  (giMapComap hf).l_iSup_u _
#align submodule.map_supr_comap_of_sujective Submodule.map_iSup_comap_of_sujective
-/

#print Submodule.map_inf_comap_of_surjective /-
theorem map_inf_comap_of_surjective (p q : Submodule R₂ M₂) :
    (p.comap f ⊓ q.comap f).map f = p ⊓ q :=
  (giMapComap hf).l_inf_u _ _
#align submodule.map_inf_comap_of_surjective Submodule.map_inf_comap_of_surjective
-/

#print Submodule.map_iInf_comap_of_surjective /-
theorem map_iInf_comap_of_surjective {ι : Sort _} (S : ι → Submodule R₂ M₂) :
    (⨅ i, (S i).comap f).map f = iInf S :=
  (giMapComap hf).l_iInf_u _
#align submodule.map_infi_comap_of_surjective Submodule.map_iInf_comap_of_surjective
-/

#print Submodule.comap_le_comap_iff_of_surjective /-
theorem comap_le_comap_iff_of_surjective (p q : Submodule R₂ M₂) : p.comap f ≤ q.comap f ↔ p ≤ q :=
  (giMapComap hf).u_le_u_iff
#align submodule.comap_le_comap_iff_of_surjective Submodule.comap_le_comap_iff_of_surjective
-/

#print Submodule.comap_strictMono_of_surjective /-
theorem comap_strictMono_of_surjective : StrictMono (comap f) :=
  (giMapComap hf).strictMono_u
#align submodule.comap_strict_mono_of_surjective Submodule.comap_strictMono_of_surjective
-/

end GaloisInsertion

section GaloisCoinsertion

variable [RingHomSurjective σ₁₂] {f : F} (hf : Injective f)

#print Submodule.gciMapComap /-
/-- `map f` and `comap f` form a `galois_coinsertion` when `f` is injective. -/
def gciMapComap : GaloisCoinsertion (map f) (comap f) :=
  (gc_map_comap f).toGaloisCoinsertion fun S x => by simp [mem_comap, mem_map, hf.eq_iff]
#align submodule.gci_map_comap Submodule.gciMapComap
-/

#print Submodule.comap_map_eq_of_injective /-
theorem comap_map_eq_of_injective (p : Submodule R M) : (p.map f).comap f = p :=
  (gciMapComap hf).u_l_eq _
#align submodule.comap_map_eq_of_injective Submodule.comap_map_eq_of_injective
-/

#print Submodule.comap_surjective_of_injective /-
theorem comap_surjective_of_injective : Function.Surjective (comap f) :=
  (gciMapComap hf).u_surjective
#align submodule.comap_surjective_of_injective Submodule.comap_surjective_of_injective
-/

#print Submodule.map_injective_of_injective /-
theorem map_injective_of_injective : Function.Injective (map f) :=
  (gciMapComap hf).l_injective
#align submodule.map_injective_of_injective Submodule.map_injective_of_injective
-/

#print Submodule.comap_inf_map_of_injective /-
theorem comap_inf_map_of_injective (p q : Submodule R M) : (p.map f ⊓ q.map f).comap f = p ⊓ q :=
  (gciMapComap hf).u_inf_l _ _
#align submodule.comap_inf_map_of_injective Submodule.comap_inf_map_of_injective
-/

#print Submodule.comap_iInf_map_of_injective /-
theorem comap_iInf_map_of_injective {ι : Sort _} (S : ι → Submodule R M) :
    (⨅ i, (S i).map f).comap f = iInf S :=
  (gciMapComap hf).u_iInf_l _
#align submodule.comap_infi_map_of_injective Submodule.comap_iInf_map_of_injective
-/

#print Submodule.comap_sup_map_of_injective /-
theorem comap_sup_map_of_injective (p q : Submodule R M) : (p.map f ⊔ q.map f).comap f = p ⊔ q :=
  (gciMapComap hf).u_sup_l _ _
#align submodule.comap_sup_map_of_injective Submodule.comap_sup_map_of_injective
-/

#print Submodule.comap_iSup_map_of_injective /-
theorem comap_iSup_map_of_injective {ι : Sort _} (S : ι → Submodule R M) :
    (⨆ i, (S i).map f).comap f = iSup S :=
  (gciMapComap hf).u_iSup_l _
#align submodule.comap_supr_map_of_injective Submodule.comap_iSup_map_of_injective
-/

#print Submodule.map_le_map_iff_of_injective /-
theorem map_le_map_iff_of_injective (p q : Submodule R M) : p.map f ≤ q.map f ↔ p ≤ q :=
  (gciMapComap hf).l_le_l_iff
#align submodule.map_le_map_iff_of_injective Submodule.map_le_map_iff_of_injective
-/

#print Submodule.map_strictMono_of_injective /-
theorem map_strictMono_of_injective : StrictMono (map f) :=
  (gciMapComap hf).strictMono_l
#align submodule.map_strict_mono_of_injective Submodule.map_strictMono_of_injective
-/

end GaloisCoinsertion

section OrderIso

variable [SemilinearEquivClass F σ₁₂ M M₂]

#print Submodule.orderIsoMapComap /-
/-- A linear isomorphism induces an order isomorphism of submodules. -/
@[simps symm_apply apply]
def orderIsoMapComap (f : F) : Submodule R M ≃o Submodule R₂ M₂
    where
  toFun := map f
  invFun := comap f
  left_inv := comap_map_eq_of_injective <| EquivLike.injective f
  right_inv := map_comap_eq_of_surjective <| EquivLike.surjective f
  map_rel_iff' := map_le_map_iff_of_injective <| EquivLike.injective f
#align submodule.order_iso_map_comap Submodule.orderIsoMapComap
-/

end OrderIso

#print Submodule.map_inf_eq_map_inf_comap /-
--TODO(Mario): is there a way to prove this from order properties?
theorem map_inf_eq_map_inf_comap [RingHomSurjective σ₁₂] {f : F} {p : Submodule R M}
    {p' : Submodule R₂ M₂} : map f p ⊓ p' = map f (p ⊓ comap f p') :=
  le_antisymm (by rintro _ ⟨⟨x, h₁, rfl⟩, h₂⟩ <;> exact ⟨_, ⟨h₁, h₂⟩, rfl⟩)
    (le_inf (map_mono inf_le_left) (map_le_iff_le_comap.2 inf_le_right))
#align submodule.map_inf_eq_map_inf_comap Submodule.map_inf_eq_map_inf_comap
-/

#print Submodule.map_comap_subtype /-
theorem map_comap_subtype : map p.Subtype (comap p.Subtype p') = p ⊓ p' :=
  ext fun x => ⟨by rintro ⟨⟨_, h₁⟩, h₂, rfl⟩ <;> exact ⟨h₁, h₂⟩, fun ⟨h₁, h₂⟩ => ⟨⟨_, h₁⟩, h₂, rfl⟩⟩
#align submodule.map_comap_subtype Submodule.map_comap_subtype
-/

#print Submodule.eq_zero_of_bot_submodule /-
theorem eq_zero_of_bot_submodule : ∀ b : (⊥ : Submodule R M), b = 0
  | ⟨b', hb⟩ => Subtype.eq <| show b' = 0 from (mem_bot R).1 hb
#align submodule.eq_zero_of_bot_submodule Submodule.eq_zero_of_bot_submodule
-/

#print LinearMap.iInf_invariant /-
/-- The infimum of a family of invariant submodule of an endomorphism is also an invariant
submodule. -/
theorem LinearMap.iInf_invariant {σ : R →+* R} [RingHomSurjective σ] {ι : Sort _} (f : M →ₛₗ[σ] M)
    {p : ι → Submodule R M} (hf : ∀ i, ∀ v ∈ p i, f v ∈ p i) : ∀ v ∈ iInf p, f v ∈ iInf p :=
  by
  have : ∀ i, (p i).map f ≤ p i := by
    rintro i - ⟨v, hv, rfl⟩
    exact hf i v hv
  suffices (iInf p).map f ≤ iInf p by exact fun v hv => this ⟨v, hv, rfl⟩
  exact le_iInf fun i => (Submodule.map_mono (iInf_le p i)).trans (this i)
#align linear_map.infi_invariant LinearMap.iInf_invariant
-/

end AddCommMonoid

section AddCommGroup

variable [Ring R] [AddCommGroup M] [Module R M] (p : Submodule R M)

variable [AddCommGroup M₂] [Module R M₂]

#print Submodule.neg_coe /-
-- See `neg_coe_set`
theorem neg_coe : -(p : Set M) = p :=
  Set.ext fun x => p.neg_mem_iff
#align submodule.neg_coe Submodule.neg_coe
-/

#print Submodule.map_neg /-
@[simp]
protected theorem map_neg (f : M →ₗ[R] M₂) : map (-f) p = map f p :=
  ext fun y =>
    ⟨fun ⟨x, hx, hy⟩ => hy ▸ ⟨-x, show -x ∈ p from neg_mem hx, map_neg f x⟩, fun ⟨x, hx, hy⟩ =>
      hy ▸ ⟨-x, show -x ∈ p from neg_mem hx, (map_neg (-f) _).trans (neg_neg (f x))⟩⟩
#align submodule.map_neg Submodule.map_neg
-/

end AddCommGroup

end Submodule

namespace Submodule

variable [Field K]

variable [AddCommGroup V] [Module K V]

variable [AddCommGroup V₂] [Module K V₂]

#print Submodule.comap_smul /-
theorem comap_smul (f : V →ₗ[K] V₂) (p : Submodule K V₂) (a : K) (h : a ≠ 0) :
    p.comap (a • f) = p.comap f := by
  ext b <;> simp only [Submodule.mem_comap, p.smul_mem_iff h, LinearMap.smul_apply]
#align submodule.comap_smul Submodule.comap_smul
-/

#print Submodule.map_smul /-
theorem map_smul (f : V →ₗ[K] V₂) (p : Submodule K V) (a : K) (h : a ≠ 0) :
    p.map (a • f) = p.map f :=
  le_antisymm (by rw [map_le_iff_le_comap, comap_smul f _ a h, ← map_le_iff_le_comap]; exact le_rfl)
    (by rw [map_le_iff_le_comap, ← comap_smul f _ a h, ← map_le_iff_le_comap]; exact le_rfl)
#align submodule.map_smul Submodule.map_smul
-/

#print Submodule.comap_smul' /-
theorem comap_smul' (f : V →ₗ[K] V₂) (p : Submodule K V₂) (a : K) :
    p.comap (a • f) = ⨅ h : a ≠ 0, p.comap f := by classical by_cases a = 0 <;> simp [h, comap_smul]
#align submodule.comap_smul' Submodule.comap_smul'
-/

#print Submodule.map_smul' /-
theorem map_smul' (f : V →ₗ[K] V₂) (p : Submodule K V) (a : K) :
    p.map (a • f) = ⨆ h : a ≠ 0, p.map f := by classical by_cases a = 0 <;> simp [h, map_smul]
#align submodule.map_smul' Submodule.map_smul'
-/

end Submodule

/-! ### Properties of linear maps -/


namespace LinearMap

section AddCommMonoid

variable [Semiring R] [Semiring R₂] [Semiring R₃]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable {σ₁₂ : R →+* R₂} {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R →+* R₃}

variable [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable [Module R M] [Module R₂ M₂] [Module R₃ M₃]

open Submodule

section Finsupp

variable {γ : Type _} [Zero γ]

#print LinearMap.map_finsupp_sum /-
@[simp]
theorem map_finsupp_sum (f : M →ₛₗ[σ₁₂] M₂) {t : ι →₀ γ} {g : ι → γ → M} :
    f (t.Sum g) = t.Sum fun i d => f (g i d) :=
  f.map_sum
#align linear_map.map_finsupp_sum LinearMap.map_finsupp_sum
-/

#print LinearMap.coe_finsupp_sum /-
theorem coe_finsupp_sum (t : ι →₀ γ) (g : ι → γ → M →ₛₗ[σ₁₂] M₂) :
    ⇑(t.Sum g) = t.Sum fun i d => g i d :=
  coeFn_sum _ _
#align linear_map.coe_finsupp_sum LinearMap.coe_finsupp_sum
-/

#print LinearMap.finsupp_sum_apply /-
@[simp]
theorem finsupp_sum_apply (t : ι →₀ γ) (g : ι → γ → M →ₛₗ[σ₁₂] M₂) (b : M) :
    (t.Sum g) b = t.Sum fun i d => g i d b :=
  sum_apply _ _ _
#align linear_map.finsupp_sum_apply LinearMap.finsupp_sum_apply
-/

end Finsupp

section Dfinsupp

open Dfinsupp

variable {γ : ι → Type _} [DecidableEq ι]

section Sum

variable [∀ i, Zero (γ i)] [∀ (i) (x : γ i), Decidable (x ≠ 0)]

#print LinearMap.map_dfinsupp_sum /-
@[simp]
theorem map_dfinsupp_sum (f : M →ₛₗ[σ₁₂] M₂) {t : Π₀ i, γ i} {g : ∀ i, γ i → M} :
    f (t.Sum g) = t.Sum fun i d => f (g i d) :=
  f.map_sum
#align linear_map.map_dfinsupp_sum LinearMap.map_dfinsupp_sum
-/

#print LinearMap.coe_dfinsupp_sum /-
theorem coe_dfinsupp_sum (t : Π₀ i, γ i) (g : ∀ i, γ i → M →ₛₗ[σ₁₂] M₂) :
    ⇑(t.Sum g) = t.Sum fun i d => g i d :=
  coeFn_sum _ _
#align linear_map.coe_dfinsupp_sum LinearMap.coe_dfinsupp_sum
-/

#print LinearMap.dfinsupp_sum_apply /-
@[simp]
theorem dfinsupp_sum_apply (t : Π₀ i, γ i) (g : ∀ i, γ i → M →ₛₗ[σ₁₂] M₂) (b : M) :
    (t.Sum g) b = t.Sum fun i d => g i d b :=
  sum_apply _ _ _
#align linear_map.dfinsupp_sum_apply LinearMap.dfinsupp_sum_apply
-/

end Sum

section SumAddHom

variable [∀ i, AddZeroClass (γ i)]

#print LinearMap.map_dfinsupp_sumAddHom /-
@[simp]
theorem map_dfinsupp_sumAddHom (f : M →ₛₗ[σ₁₂] M₂) {t : Π₀ i, γ i} {g : ∀ i, γ i →+ M} :
    f (sumAddHom g t) = sumAddHom (fun i => f.toAddMonoidHom.comp (g i)) t :=
  f.toAddMonoidHom.map_dfinsupp_sumAddHom _ _
#align linear_map.map_dfinsupp_sum_add_hom LinearMap.map_dfinsupp_sumAddHom
-/

end SumAddHom

end Dfinsupp

variable {σ₂₁ : R₂ →+* R} {τ₁₂ : R →+* R₂} {τ₂₃ : R₂ →+* R₃} {τ₁₃ : R →+* R₃}

variable [RingHomCompTriple τ₁₂ τ₂₃ τ₁₃]

#print LinearMap.map_codRestrict /-
theorem map_codRestrict [RingHomSurjective σ₂₁] (p : Submodule R M) (f : M₂ →ₛₗ[σ₂₁] M) (h p') :
    Submodule.map (codRestrict p f h) p' = comap p.Subtype (p'.map f) :=
  Submodule.ext fun ⟨x, hx⟩ => by simp [Subtype.ext_iff_val]
#align linear_map.map_cod_restrict LinearMap.map_codRestrict
-/

#print LinearMap.comap_codRestrict /-
theorem comap_codRestrict (p : Submodule R M) (f : M₂ →ₛₗ[σ₂₁] M) (hf p') :
    Submodule.comap (codRestrict p f hf) p' = Submodule.comap f (map p.Subtype p') :=
  Submodule.ext fun x => ⟨fun h => ⟨⟨_, hf x⟩, h, rfl⟩, by rintro ⟨⟨_, _⟩, h, ⟨⟩⟩ <;> exact h⟩
#align linear_map.comap_cod_restrict LinearMap.comap_codRestrict
-/

section

variable {F : Type _} [sc : SemilinearMapClass F τ₁₂ M M₂]

#print LinearMap.range /-
/-- The range of a linear map `f : M → M₂` is a submodule of `M₂`.
See Note [range copy pattern]. -/
def range [RingHomSurjective τ₁₂] (f : F) : Submodule R₂ M₂ :=
  (map f ⊤).copy (Set.range f) Set.image_univ.symm
#align linear_map.range LinearMap.range
-/

#print LinearMap.range_coe /-
theorem range_coe [RingHomSurjective τ₁₂] (f : F) : (range f : Set M₂) = Set.range f :=
  rfl
#align linear_map.range_coe LinearMap.range_coe
-/

#print LinearMap.range_toAddSubmonoid /-
theorem range_toAddSubmonoid [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) :
    f.range.toAddSubmonoid = f.toAddMonoidHom.mrange :=
  rfl
#align linear_map.range_to_add_submonoid LinearMap.range_toAddSubmonoid
-/

#print LinearMap.mem_range /-
@[simp]
theorem mem_range [RingHomSurjective τ₁₂] {f : F} {x} : x ∈ range f ↔ ∃ y, f y = x :=
  Iff.rfl
#align linear_map.mem_range LinearMap.mem_range
-/

#print LinearMap.range_eq_map /-
theorem range_eq_map [RingHomSurjective τ₁₂] (f : F) : range f = map f ⊤ := by ext; simp
#align linear_map.range_eq_map LinearMap.range_eq_map
-/

#print LinearMap.mem_range_self /-
theorem mem_range_self [RingHomSurjective τ₁₂] (f : F) (x : M) : f x ∈ range f :=
  ⟨x, rfl⟩
#align linear_map.mem_range_self LinearMap.mem_range_self
-/

#print LinearMap.range_id /-
@[simp]
theorem range_id : range (LinearMap.id : M →ₗ[R] M) = ⊤ :=
  SetLike.coe_injective Set.range_id
#align linear_map.range_id LinearMap.range_id
-/

#print LinearMap.range_comp /-
theorem range_comp [RingHomSurjective τ₁₂] [RingHomSurjective τ₂₃] [RingHomSurjective τ₁₃]
    (f : M →ₛₗ[τ₁₂] M₂) (g : M₂ →ₛₗ[τ₂₃] M₃) : range (g.comp f : M →ₛₗ[τ₁₃] M₃) = map g (range f) :=
  SetLike.coe_injective (Set.range_comp g f)
#align linear_map.range_comp LinearMap.range_comp
-/

#print LinearMap.range_comp_le_range /-
theorem range_comp_le_range [RingHomSurjective τ₂₃] [RingHomSurjective τ₁₃] (f : M →ₛₗ[τ₁₂] M₂)
    (g : M₂ →ₛₗ[τ₂₃] M₃) : range (g.comp f : M →ₛₗ[τ₁₃] M₃) ≤ range g :=
  SetLike.coe_mono (Set.range_comp_subset_range f g)
#align linear_map.range_comp_le_range LinearMap.range_comp_le_range
-/

#print LinearMap.range_eq_top /-
theorem range_eq_top [RingHomSurjective τ₁₂] {f : F} : range f = ⊤ ↔ Surjective f := by
  rw [SetLike.ext'_iff, range_coe, top_coe, Set.range_iff_surjective]
#align linear_map.range_eq_top LinearMap.range_eq_top
-/

#print LinearMap.range_le_iff_comap /-
theorem range_le_iff_comap [RingHomSurjective τ₁₂] {f : F} {p : Submodule R₂ M₂} :
    range f ≤ p ↔ comap f p = ⊤ := by rw [range_eq_map, map_le_iff_le_comap, eq_top_iff]
#align linear_map.range_le_iff_comap LinearMap.range_le_iff_comap
-/

#print LinearMap.map_le_range /-
theorem map_le_range [RingHomSurjective τ₁₂] {f : F} {p : Submodule R M} : map f p ≤ range f :=
  SetLike.coe_mono (Set.image_subset_range f p)
#align linear_map.map_le_range LinearMap.map_le_range
-/

#print LinearMap.range_neg /-
@[simp]
theorem range_neg {R : Type _} {R₂ : Type _} {M : Type _} {M₂ : Type _} [Semiring R] [Ring R₂]
    [AddCommMonoid M] [AddCommGroup M₂] [Module R M] [Module R₂ M₂] {τ₁₂ : R →+* R₂}
    [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : (-f).range = f.range :=
  by
  change ((-LinearMap.id : M₂ →ₗ[R₂] M₂).comp f).range = _
  rw [range_comp, Submodule.map_neg, Submodule.map_id]
#align linear_map.range_neg LinearMap.range_neg
-/

#print LinearMap.eqLocus /-
/-- A linear map version of `add_monoid_hom.eq_locus` -/
def eqLocus (f g : M →ₛₗ[τ₁₂] M₂) : Submodule R M :=
  {
    f.toAddMonoidHom.eqLocus
      g.toAddMonoidHom with
    carrier := {x | f x = g x}
    smul_mem' := fun r x (hx : _ = _) =>
      show _ = _ by simpa only [LinearMap.map_smulₛₗ] using congr_arg ((· • ·) (τ₁₂ r)) hx }
#align linear_map.eq_locus LinearMap.eqLocus
-/

#print LinearMap.mem_eqLocus /-
@[simp]
theorem mem_eqLocus {x : M} {f g : M →ₛₗ[τ₁₂] M₂} : x ∈ f.eqLocus g ↔ f x = g x :=
  Iff.rfl
#align linear_map.mem_eq_locus LinearMap.mem_eqLocus
-/

#print LinearMap.eqLocus_toAddSubmonoid /-
theorem eqLocus_toAddSubmonoid (f g : M →ₛₗ[τ₁₂] M₂) :
    (f.eqLocus g).toAddSubmonoid = (f : M →+ M₂).eqLocus g :=
  rfl
#align linear_map.eq_locus_to_add_submonoid LinearMap.eqLocus_toAddSubmonoid
-/

#print LinearMap.eqLocus_same /-
@[simp]
theorem eqLocus_same (f : M →ₛₗ[τ₁₂] M₂) : f.eqLocus f = ⊤ :=
  SetLike.ext fun _ => eq_self_iff_true _
#align linear_map.eq_locus_same LinearMap.eqLocus_same
-/

end

#print LinearMap.iterateRange /-
/-- The decreasing sequence of submodules consisting of the ranges of the iterates of a linear map.
-/
@[simps]
def iterateRange (f : M →ₗ[R] M) : ℕ →o (Submodule R M)ᵒᵈ :=
  ⟨fun n => (f ^ n).range, fun n m w x h =>
    by
    obtain ⟨c, rfl⟩ := le_iff_exists_add.mp w
    rw [LinearMap.mem_range] at h 
    obtain ⟨m, rfl⟩ := h
    rw [LinearMap.mem_range]
    use (f ^ c) m
    rw [pow_add, LinearMap.mul_apply]⟩
#align linear_map.iterate_range LinearMap.iterateRange
-/

#print LinearMap.rangeRestrict /-
/-- Restrict the codomain of a linear map `f` to `f.range`.

This is the bundled version of `set.range_factorization`. -/
@[reducible]
def rangeRestrict [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) : M →ₛₗ[τ₁₂] f.range :=
  f.codRestrict f.range f.mem_range_self
#align linear_map.range_restrict LinearMap.rangeRestrict
-/

#print LinearMap.fintypeRange /-
/-- The range of a linear map is finite if the domain is finite.
Note: this instance can form a diamond with `subtype.fintype` in the
  presence of `fintype M₂`. -/
instance fintypeRange [Fintype M] [DecidableEq M₂] [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) :
    Fintype (range f) :=
  Set.fintypeRange f
#align linear_map.fintype_range LinearMap.fintypeRange
-/

variable {F : Type _} [sc : SemilinearMapClass F τ₁₂ M M₂]

#print LinearMap.ker /-
/-- The kernel of a linear map `f : M → M₂` is defined to be `comap f ⊥`. This is equivalent to the
set of `x : M` such that `f x = 0`. The kernel is a submodule of `M`. -/
def ker (f : F) : Submodule R M :=
  comap f ⊥
#align linear_map.ker LinearMap.ker
-/

#print LinearMap.mem_ker /-
@[simp]
theorem mem_ker {f : F} {y} : y ∈ ker f ↔ f y = 0 :=
  mem_bot R₂
#align linear_map.mem_ker LinearMap.mem_ker
-/

#print LinearMap.ker_id /-
@[simp]
theorem ker_id : ker (LinearMap.id : M →ₗ[R] M) = ⊥ :=
  rfl
#align linear_map.ker_id LinearMap.ker_id
-/

#print LinearMap.map_coe_ker /-
@[simp]
theorem map_coe_ker (f : F) (x : ker f) : f x = 0 :=
  mem_ker.1 x.2
#align linear_map.map_coe_ker LinearMap.map_coe_ker
-/

#print LinearMap.ker_toAddSubmonoid /-
theorem ker_toAddSubmonoid (f : M →ₛₗ[τ₁₂] M₂) : f.ker.toAddSubmonoid = f.toAddMonoidHom.mker :=
  rfl
#align linear_map.ker_to_add_submonoid LinearMap.ker_toAddSubmonoid
-/

#print LinearMap.comp_ker_subtype /-
theorem comp_ker_subtype (f : M →ₛₗ[τ₁₂] M₂) : f.comp f.ker.Subtype = 0 :=
  LinearMap.ext fun x =>
    suffices f x = 0 by simp [this]
    mem_ker.1 x.2
#align linear_map.comp_ker_subtype LinearMap.comp_ker_subtype
-/

#print LinearMap.ker_comp /-
theorem ker_comp (f : M →ₛₗ[τ₁₂] M₂) (g : M₂ →ₛₗ[τ₂₃] M₃) :
    ker (g.comp f : M →ₛₗ[τ₁₃] M₃) = comap f (ker g) :=
  rfl
#align linear_map.ker_comp LinearMap.ker_comp
-/

#print LinearMap.ker_le_ker_comp /-
theorem ker_le_ker_comp (f : M →ₛₗ[τ₁₂] M₂) (g : M₂ →ₛₗ[τ₂₃] M₃) :
    ker f ≤ ker (g.comp f : M →ₛₗ[τ₁₃] M₃) := by rw [ker_comp] <;> exact comap_mono bot_le
#align linear_map.ker_le_ker_comp LinearMap.ker_le_ker_comp
-/

#print LinearMap.disjoint_ker /-
theorem disjoint_ker {f : F} {p : Submodule R M} : Disjoint p (ker f) ↔ ∀ x ∈ p, f x = 0 → x = 0 :=
  by simp [disjoint_def]
#align linear_map.disjoint_ker LinearMap.disjoint_ker
-/

#print LinearMap.ker_eq_bot' /-
theorem ker_eq_bot' {f : F} : ker f = ⊥ ↔ ∀ m, f m = 0 → m = 0 := by
  simpa [disjoint_iff_inf_le] using @disjoint_ker _ _ _ _ _ _ _ _ _ _ _ _ _ f ⊤
#align linear_map.ker_eq_bot' LinearMap.ker_eq_bot'
-/

#print LinearMap.ker_eq_bot_of_inverse /-
theorem ker_eq_bot_of_inverse {τ₂₁ : R₂ →+* R} [RingHomInvPair τ₁₂ τ₂₁] {f : M →ₛₗ[τ₁₂] M₂}
    {g : M₂ →ₛₗ[τ₂₁] M} (h : (g.comp f : M →ₗ[R] M) = id) : ker f = ⊥ :=
  ker_eq_bot'.2 fun m hm => by rw [← id_apply m, ← h, comp_apply, hm, g.map_zero]
#align linear_map.ker_eq_bot_of_inverse LinearMap.ker_eq_bot_of_inverse
-/

#print LinearMap.le_ker_iff_map /-
theorem le_ker_iff_map [RingHomSurjective τ₁₂] {f : F} {p : Submodule R M} :
    p ≤ ker f ↔ map f p = ⊥ := by rw [ker, eq_bot_iff, map_le_iff_le_comap]
#align linear_map.le_ker_iff_map LinearMap.le_ker_iff_map
-/

#print LinearMap.ker_codRestrict /-
theorem ker_codRestrict {τ₂₁ : R₂ →+* R} (p : Submodule R M) (f : M₂ →ₛₗ[τ₂₁] M) (hf) :
    ker (codRestrict p f hf) = ker f := by rw [ker, comap_cod_restrict, Submodule.map_bot] <;> rfl
#align linear_map.ker_cod_restrict LinearMap.ker_codRestrict
-/

#print LinearMap.range_codRestrict /-
theorem range_codRestrict {τ₂₁ : R₂ →+* R} [RingHomSurjective τ₂₁] (p : Submodule R M)
    (f : M₂ →ₛₗ[τ₂₁] M) (hf) : range (codRestrict p f hf) = comap p.Subtype f.range := by
  simpa only [range_eq_map] using map_cod_restrict _ _ _ _
#align linear_map.range_cod_restrict LinearMap.range_codRestrict
-/

#print LinearMap.ker_restrict /-
theorem ker_restrict [AddCommMonoid M₁] [Module R M₁] {p : Submodule R M} {q : Submodule R M₁}
    {f : M →ₗ[R] M₁} (hf : ∀ x : M, x ∈ p → f x ∈ q) :
    ker (f.restrict hf) = (f.domRestrict p).ker := by
  rw [restrict_eq_cod_restrict_dom_restrict, ker_cod_restrict]
#align linear_map.ker_restrict LinearMap.ker_restrict
-/

#print Submodule.map_comap_eq /-
theorem Submodule.map_comap_eq [RingHomSurjective τ₁₂] (f : F) (q : Submodule R₂ M₂) :
    map f (comap f q) = range f ⊓ q :=
  le_antisymm (le_inf map_le_range (map_comap_le _ _)) <| by
    rintro _ ⟨⟨x, _, rfl⟩, hx⟩ <;> exact ⟨x, hx, rfl⟩
#align submodule.map_comap_eq Submodule.map_comap_eq
-/

#print Submodule.map_comap_eq_self /-
theorem Submodule.map_comap_eq_self [RingHomSurjective τ₁₂] {f : F} {q : Submodule R₂ M₂}
    (h : q ≤ range f) : map f (comap f q) = q := by rwa [Submodule.map_comap_eq, inf_eq_right]
#align submodule.map_comap_eq_self Submodule.map_comap_eq_self
-/

#print LinearMap.ker_zero /-
@[simp]
theorem ker_zero : ker (0 : M →ₛₗ[τ₁₂] M₂) = ⊤ :=
  eq_top_iff'.2 fun x => by simp
#align linear_map.ker_zero LinearMap.ker_zero
-/

#print LinearMap.range_zero /-
@[simp]
theorem range_zero [RingHomSurjective τ₁₂] : range (0 : M →ₛₗ[τ₁₂] M₂) = ⊥ := by
  simpa only [range_eq_map] using Submodule.map_zero _
#align linear_map.range_zero LinearMap.range_zero
-/

#print LinearMap.ker_eq_top /-
theorem ker_eq_top {f : M →ₛₗ[τ₁₂] M₂} : ker f = ⊤ ↔ f = 0 :=
  ⟨fun h => ext fun x => mem_ker.1 <| h.symm ▸ trivial, fun h => h.symm ▸ ker_zero⟩
#align linear_map.ker_eq_top LinearMap.ker_eq_top
-/

section

variable [RingHomSurjective τ₁₂]

#print LinearMap.range_le_bot_iff /-
theorem range_le_bot_iff (f : M →ₛₗ[τ₁₂] M₂) : range f ≤ ⊥ ↔ f = 0 := by
  rw [range_le_iff_comap] <;> exact ker_eq_top
#align linear_map.range_le_bot_iff LinearMap.range_le_bot_iff
-/

#print LinearMap.range_eq_bot /-
theorem range_eq_bot {f : M →ₛₗ[τ₁₂] M₂} : range f = ⊥ ↔ f = 0 := by
  rw [← range_le_bot_iff, le_bot_iff]
#align linear_map.range_eq_bot LinearMap.range_eq_bot
-/

#print LinearMap.range_le_ker_iff /-
theorem range_le_ker_iff {f : M →ₛₗ[τ₁₂] M₂} {g : M₂ →ₛₗ[τ₂₃] M₃} :
    range f ≤ ker g ↔ (g.comp f : M →ₛₗ[τ₁₃] M₃) = 0 :=
  ⟨fun h => ker_eq_top.1 <| eq_top_iff'.2 fun x => h <| ⟨_, rfl⟩, fun h x hx =>
    mem_ker.2 <| Exists.elim hx fun y hy => by rw [← hy, ← comp_apply, h, zero_apply]⟩
#align linear_map.range_le_ker_iff LinearMap.range_le_ker_iff
-/

#print LinearMap.comap_le_comap_iff /-
theorem comap_le_comap_iff {f : F} (hf : range f = ⊤) {p p'} : comap f p ≤ comap f p' ↔ p ≤ p' :=
  ⟨fun H x hx => by rcases range_eq_top.1 hf x with ⟨y, hy, rfl⟩ <;> exact H hx, comap_mono⟩
#align linear_map.comap_le_comap_iff LinearMap.comap_le_comap_iff
-/

#print LinearMap.comap_injective /-
theorem comap_injective {f : F} (hf : range f = ⊤) : Injective (comap f) := fun p p' h =>
  le_antisymm ((comap_le_comap_iff hf).1 (le_of_eq h)) ((comap_le_comap_iff hf).1 (ge_of_eq h))
#align linear_map.comap_injective LinearMap.comap_injective
-/

end

#print LinearMap.ker_eq_bot_of_injective /-
theorem ker_eq_bot_of_injective {f : F} (hf : Injective f) : ker f = ⊥ :=
  by
  have : Disjoint ⊤ (ker f) := by rw [disjoint_ker, ← map_zero f]; exact fun x hx H => hf H
  simpa [disjoint_iff_inf_le]
#align linear_map.ker_eq_bot_of_injective LinearMap.ker_eq_bot_of_injective
-/

#print LinearMap.iterateKer /-
/-- The increasing sequence of submodules consisting of the kernels of the iterates of a linear map.
-/
@[simps]
def iterateKer (f : M →ₗ[R] M) : ℕ →o Submodule R M :=
  ⟨fun n => (f ^ n).ker, fun n m w x h =>
    by
    obtain ⟨c, rfl⟩ := le_iff_exists_add.mp w
    rw [LinearMap.mem_ker] at h 
    rw [LinearMap.mem_ker, add_comm, pow_add, LinearMap.mul_apply, h, LinearMap.map_zero]⟩
#align linear_map.iterate_ker LinearMap.iterateKer
-/

end AddCommMonoid

section Ring

variable [Ring R] [Ring R₂] [Ring R₃]

variable [AddCommGroup M] [AddCommGroup M₂] [AddCommGroup M₃]

variable [Module R M] [Module R₂ M₂] [Module R₃ M₃]

variable {τ₁₂ : R →+* R₂} {τ₂₃ : R₂ →+* R₃} {τ₁₃ : R →+* R₃}

variable [RingHomCompTriple τ₁₂ τ₂₃ τ₁₃]

variable {F : Type _} [sc : SemilinearMapClass F τ₁₂ M M₂]

variable {f : F}

open Submodule

#print LinearMap.range_toAddSubgroup /-
theorem range_toAddSubgroup [RingHomSurjective τ₁₂] (f : M →ₛₗ[τ₁₂] M₂) :
    f.range.toAddSubgroup = f.toAddMonoidHom.range :=
  rfl
#align linear_map.range_to_add_subgroup LinearMap.range_toAddSubgroup
-/

#print LinearMap.ker_toAddSubgroup /-
theorem ker_toAddSubgroup (f : M →ₛₗ[τ₁₂] M₂) : f.ker.toAddSubgroup = f.toAddMonoidHom.ker :=
  rfl
#align linear_map.ker_to_add_subgroup LinearMap.ker_toAddSubgroup
-/

#print LinearMap.eqLocus_eq_ker_sub /-
theorem eqLocus_eq_ker_sub (f g : M →ₛₗ[τ₁₂] M₂) : f.eqLocus g = (f - g).ker :=
  SetLike.ext fun v => sub_eq_zero.symm
#align linear_map.eq_locus_eq_ker_sub LinearMap.eqLocus_eq_ker_sub
-/

#print LinearMap.sub_mem_ker_iff /-
theorem sub_mem_ker_iff {x y} : x - y ∈ ker f ↔ f x = f y := by rw [mem_ker, map_sub, sub_eq_zero]
#align linear_map.sub_mem_ker_iff LinearMap.sub_mem_ker_iff
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (x y «expr ∈ » p) -/
#print LinearMap.disjoint_ker' /-
theorem disjoint_ker' {p : Submodule R M} :
    Disjoint p (ker f) ↔ ∀ (x) (_ : x ∈ p) (y) (_ : y ∈ p), f x = f y → x = y :=
  disjoint_ker.trans
    ⟨fun H x hx y hy h => eq_of_sub_eq_zero <| H _ (sub_mem hx hy) (by simp [h]), fun H x h₁ h₂ =>
      H x h₁ 0 (zero_mem _) (by simpa using h₂)⟩
#align linear_map.disjoint_ker' LinearMap.disjoint_ker'
-/

#print LinearMap.injOn_of_disjoint_ker /-
theorem injOn_of_disjoint_ker {p : Submodule R M} {s : Set M} (h : s ⊆ p)
    (hd : Disjoint p (ker f)) : Set.InjOn f s := fun x hx y hy =>
  disjoint_ker'.1 hd _ (h hx) _ (h hy)
#align linear_map.inj_on_of_disjoint_ker LinearMap.injOn_of_disjoint_ker
-/

variable (F)

#print LinearMapClass.ker_eq_bot /-
theorem LinearMapClass.ker_eq_bot : ker f = ⊥ ↔ Injective f := by
  simpa [disjoint_iff_inf_le] using @disjoint_ker' _ _ _ _ _ _ _ _ _ _ _ _ _ f ⊤
#align linear_map_class.ker_eq_bot LinearMapClass.ker_eq_bot
-/

variable {F}

#print LinearMap.ker_eq_bot /-
theorem ker_eq_bot {f : M →ₛₗ[τ₁₂] M₂} : ker f = ⊥ ↔ Injective f :=
  LinearMapClass.ker_eq_bot _
#align linear_map.ker_eq_bot LinearMap.ker_eq_bot
-/

#print LinearMap.ker_le_iff /-
theorem ker_le_iff [RingHomSurjective τ₁₂] {p : Submodule R M} :
    ker f ≤ p ↔ ∃ y ∈ range f, f ⁻¹' {y} ⊆ p :=
  by
  constructor
  · intro h; use 0; rw [← SetLike.mem_coe, range_coe]; exact ⟨⟨0, map_zero f⟩, h⟩
  · rintro ⟨y, h₁, h₂⟩
    rw [SetLike.le_def]; intro z hz; simp only [mem_ker, SetLike.mem_coe] at hz 
    rw [← SetLike.mem_coe, range_coe, Set.mem_range] at h₁ ; obtain ⟨x, hx⟩ := h₁
    have hx' : x ∈ p := h₂ hx
    have hxz : z + x ∈ p := by apply h₂; simp [hx, hz]
    suffices z + x - x ∈ p by simpa only [this, add_sub_cancel]
    exact p.sub_mem hxz hx'
#align linear_map.ker_le_iff LinearMap.ker_le_iff
-/

end Ring

section Field

variable [Field K] [Field K₂]

variable [AddCommGroup V] [Module K V]

variable [AddCommGroup V₂] [Module K V₂]

#print LinearMap.ker_smul /-
theorem ker_smul (f : V →ₗ[K] V₂) (a : K) (h : a ≠ 0) : ker (a • f) = ker f :=
  Submodule.comap_smul f _ a h
#align linear_map.ker_smul LinearMap.ker_smul
-/

#print LinearMap.ker_smul' /-
theorem ker_smul' (f : V →ₗ[K] V₂) (a : K) : ker (a • f) = ⨅ h : a ≠ 0, ker f :=
  Submodule.comap_smul' f _ a
#align linear_map.ker_smul' LinearMap.ker_smul'
-/

#print LinearMap.range_smul /-
theorem range_smul (f : V →ₗ[K] V₂) (a : K) (h : a ≠ 0) : range (a • f) = range f := by
  simpa only [range_eq_map] using Submodule.map_smul f _ a h
#align linear_map.range_smul LinearMap.range_smul
-/

#print LinearMap.range_smul' /-
theorem range_smul' (f : V →ₗ[K] V₂) (a : K) : range (a • f) = ⨆ h : a ≠ 0, range f := by
  simpa only [range_eq_map] using Submodule.map_smul' f _ a
#align linear_map.range_smul' LinearMap.range_smul'
-/

end Field

end LinearMap

namespace IsLinearMap

#print IsLinearMap.isLinearMap_add /-
theorem isLinearMap_add [Semiring R] [AddCommMonoid M] [Module R M] :
    IsLinearMap R fun x : M × M => x.1 + x.2 :=
  by
  apply IsLinearMap.mk
  · intro x y
    simp only [Prod.fst_add, Prod.snd_add]; cc
  · intro x y
    simp [smul_add]
#align is_linear_map.is_linear_map_add IsLinearMap.isLinearMap_add
-/

#print IsLinearMap.isLinearMap_sub /-
theorem isLinearMap_sub {R M : Type _} [Semiring R] [AddCommGroup M] [Module R M] :
    IsLinearMap R fun x : M × M => x.1 - x.2 :=
  by
  apply IsLinearMap.mk
  · intro x y
    simp [add_comm, add_left_comm, sub_eq_add_neg]
  · intro x y
    simp [smul_sub]
#align is_linear_map.is_linear_map_sub IsLinearMap.isLinearMap_sub
-/

end IsLinearMap

namespace Submodule

section AddCommMonoid

variable [Semiring R] [Semiring R₂] [AddCommMonoid M] [AddCommMonoid M₂]

variable [Module R M] [Module R₂ M₂]

variable (p p' : Submodule R M) (q : Submodule R₂ M₂)

variable {τ₁₂ : R →+* R₂}

variable {F : Type _} [sc : SemilinearMapClass F τ₁₂ M M₂]

open LinearMap

#print Submodule.map_top /-
@[simp]
theorem map_top [RingHomSurjective τ₁₂] (f : F) : map f ⊤ = range f :=
  (range_eq_map f).symm
#align submodule.map_top Submodule.map_top
-/

#print Submodule.comap_bot /-
@[simp]
theorem comap_bot (f : F) : comap f ⊥ = ker f :=
  rfl
#align submodule.comap_bot Submodule.comap_bot
-/

#print Submodule.ker_subtype /-
@[simp]
theorem ker_subtype : p.Subtype.ker = ⊥ :=
  ker_eq_bot_of_injective fun x y => Subtype.ext_val
#align submodule.ker_subtype Submodule.ker_subtype
-/

#print Submodule.range_subtype /-
@[simp]
theorem range_subtype : p.Subtype.range = p := by simpa using map_comap_subtype p ⊤
#align submodule.range_subtype Submodule.range_subtype
-/

#print Submodule.map_subtype_le /-
theorem map_subtype_le (p' : Submodule R p) : map p.Subtype p' ≤ p := by
  simpa using (map_le_range : map p.subtype p' ≤ p.subtype.range)
#align submodule.map_subtype_le Submodule.map_subtype_le
-/

#print Submodule.map_subtype_top /-
/-- Under the canonical linear map from a submodule `p` to the ambient space `M`, the image of the
maximal submodule of `p` is just `p `. -/
@[simp]
theorem map_subtype_top : map p.Subtype (⊤ : Submodule R p) = p := by simp
#align submodule.map_subtype_top Submodule.map_subtype_top
-/

#print Submodule.comap_subtype_eq_top /-
@[simp]
theorem comap_subtype_eq_top {p p' : Submodule R M} : comap p.Subtype p' = ⊤ ↔ p ≤ p' :=
  eq_top_iff.trans <| map_le_iff_le_comap.symm.trans <| by rw [map_subtype_top]
#align submodule.comap_subtype_eq_top Submodule.comap_subtype_eq_top
-/

#print Submodule.comap_subtype_self /-
@[simp]
theorem comap_subtype_self : comap p.Subtype p = ⊤ :=
  comap_subtype_eq_top.2 le_rfl
#align submodule.comap_subtype_self Submodule.comap_subtype_self
-/

#print Submodule.ker_ofLe /-
@[simp]
theorem ker_ofLe (p p' : Submodule R M) (h : p ≤ p') : (ofLe h).ker = ⊥ := by
  rw [of_le, ker_cod_restrict, ker_subtype]
#align submodule.ker_of_le Submodule.ker_ofLe
-/

#print Submodule.range_ofLe /-
theorem range_ofLe (p q : Submodule R M) (h : p ≤ q) : (ofLe h).range = comap q.Subtype p := by
  rw [← map_top, of_le, LinearMap.map_codRestrict, map_top, range_subtype]
#align submodule.range_of_le Submodule.range_ofLe
-/

#print Submodule.map_subtype_range_ofLe /-
@[simp]
theorem map_subtype_range_ofLe {p p' : Submodule R M} (h : p ≤ p') :
    map p'.Subtype (ofLe h).range = p := by simp [range_of_le, map_comap_eq, h]
#align submodule.map_subtype_range_of_le Submodule.map_subtype_range_ofLe
-/

#print Submodule.disjoint_iff_comap_eq_bot /-
theorem disjoint_iff_comap_eq_bot {p q : Submodule R M} : Disjoint p q ↔ comap p.Subtype q = ⊥ := by
  rw [← (map_injective_of_injective (show injective p.subtype from Subtype.coe_injective)).eq_iff,
    map_comap_subtype, map_bot, disjoint_iff]
#align submodule.disjoint_iff_comap_eq_bot Submodule.disjoint_iff_comap_eq_bot
-/

#print Submodule.MapSubtype.relIso /-
/-- If `N ⊆ M` then submodules of `N` are the same as submodules of `M` contained in `N` -/
def MapSubtype.relIso : Submodule R p ≃o { p' : Submodule R M // p' ≤ p }
    where
  toFun p' := ⟨map p.Subtype p', map_subtype_le p _⟩
  invFun q := comap p.Subtype q
  left_inv p' := comap_map_eq_of_injective Subtype.coe_injective p'
  right_inv := fun ⟨q, hq⟩ => Subtype.ext_val <| by simp [map_comap_subtype p, inf_of_le_right hq]
  map_rel_iff' p₁ p₂ :=
    Subtype.coe_le_coe.symm.trans
      (by
        dsimp
        rw [map_le_iff_le_comap,
          comap_map_eq_of_injective (show injective p.subtype from Subtype.coe_injective) p₂])
#align submodule.map_subtype.rel_iso Submodule.MapSubtype.relIso
-/

#print Submodule.MapSubtype.orderEmbedding /-
/-- If `p ⊆ M` is a submodule, the ordering of submodules of `p` is embedded in the ordering of
submodules of `M`. -/
def MapSubtype.orderEmbedding : Submodule R p ↪o Submodule R M :=
  (RelIso.toRelEmbedding <| MapSubtype.relIso p).trans (Subtype.relEmbedding _ _)
#align submodule.map_subtype.order_embedding Submodule.MapSubtype.orderEmbedding
-/

#print Submodule.map_subtype_embedding_eq /-
@[simp]
theorem map_subtype_embedding_eq (p' : Submodule R p) :
    MapSubtype.orderEmbedding p p' = map p.Subtype p' :=
  rfl
#align submodule.map_subtype_embedding_eq Submodule.map_subtype_embedding_eq
-/

end AddCommMonoid

end Submodule

namespace LinearMap

section Semiring

variable [Semiring R] [Semiring R₂] [Semiring R₃]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [Module R M] [Module R₂ M₂] [Module R₃ M₃]

variable {τ₁₂ : R →+* R₂} {τ₂₃ : R₂ →+* R₃} {τ₁₃ : R →+* R₃}

variable [RingHomCompTriple τ₁₂ τ₂₃ τ₁₃]

#print LinearMap.ker_eq_bot_of_cancel /-
/-- A monomorphism is injective. -/
theorem ker_eq_bot_of_cancel {f : M →ₛₗ[τ₁₂] M₂}
    (h : ∀ u v : f.ker →ₗ[R] M, f.comp u = f.comp v → u = v) : f.ker = ⊥ :=
  by
  have h₁ : f.comp (0 : f.ker →ₗ[R] M) = 0 := comp_zero _
  rw [← Submodule.range_subtype f.ker, ← h 0 f.ker.subtype (Eq.trans h₁ (comp_ker_subtype f).symm)]
  exact range_zero
#align linear_map.ker_eq_bot_of_cancel LinearMap.ker_eq_bot_of_cancel
-/

#print LinearMap.range_comp_of_range_eq_top /-
theorem range_comp_of_range_eq_top [RingHomSurjective τ₁₂] [RingHomSurjective τ₂₃]
    [RingHomSurjective τ₁₃] {f : M →ₛₗ[τ₁₂] M₂} (g : M₂ →ₛₗ[τ₂₃] M₃) (hf : range f = ⊤) :
    range (g.comp f : M →ₛₗ[τ₁₃] M₃) = range g := by rw [range_comp, hf, Submodule.map_top]
#align linear_map.range_comp_of_range_eq_top LinearMap.range_comp_of_range_eq_top
-/

#print LinearMap.ker_comp_of_ker_eq_bot /-
theorem ker_comp_of_ker_eq_bot (f : M →ₛₗ[τ₁₂] M₂) {g : M₂ →ₛₗ[τ₂₃] M₃} (hg : ker g = ⊥) :
    ker (g.comp f : M →ₛₗ[τ₁₃] M₃) = ker f := by rw [ker_comp, hg, Submodule.comap_bot]
#align linear_map.ker_comp_of_ker_eq_bot LinearMap.ker_comp_of_ker_eq_bot
-/

section Image

#print LinearMap.submoduleImage /-
/-- If `O` is a submodule of `M`, and `Φ : O →ₗ M'` is a linear map,
then `(ϕ : O →ₗ M').submodule_image N` is `ϕ(N)` as a submodule of `M'` -/
def submoduleImage {M' : Type _} [AddCommMonoid M'] [Module R M'] {O : Submodule R M}
    (ϕ : O →ₗ[R] M') (N : Submodule R M) : Submodule R M' :=
  (N.comap O.Subtype).map ϕ
#align linear_map.submodule_image LinearMap.submoduleImage
-/

#print LinearMap.mem_submoduleImage /-
@[simp]
theorem mem_submoduleImage {M' : Type _} [AddCommMonoid M'] [Module R M'] {O : Submodule R M}
    {ϕ : O →ₗ[R] M'} {N : Submodule R M} {x : M'} :
    x ∈ ϕ.submoduleImage N ↔ ∃ (y : _) (yO : y ∈ O) (yN : y ∈ N), ϕ ⟨y, yO⟩ = x :=
  by
  refine' submodule.mem_map.trans ⟨_, _⟩ <;> simp_rw [Submodule.mem_comap]
  · rintro ⟨⟨y, yO⟩, yN : y ∈ N, h⟩
    exact ⟨y, yO, yN, h⟩
  · rintro ⟨y, yO, yN, h⟩
    exact ⟨⟨y, yO⟩, yN, h⟩
#align linear_map.mem_submodule_image LinearMap.mem_submoduleImage
-/

#print LinearMap.mem_submoduleImage_of_le /-
theorem mem_submoduleImage_of_le {M' : Type _} [AddCommMonoid M'] [Module R M'] {O : Submodule R M}
    {ϕ : O →ₗ[R] M'} {N : Submodule R M} (hNO : N ≤ O) {x : M'} :
    x ∈ ϕ.submoduleImage N ↔ ∃ (y : _) (yN : y ∈ N), ϕ ⟨y, hNO yN⟩ = x :=
  by
  refine' mem_submodule_image.trans ⟨_, _⟩
  · rintro ⟨y, yO, yN, h⟩
    exact ⟨y, yN, h⟩
  · rintro ⟨y, yN, h⟩
    exact ⟨y, hNO yN, yN, h⟩
#align linear_map.mem_submodule_image_of_le LinearMap.mem_submoduleImage_of_le
-/

#print LinearMap.submoduleImage_apply_ofLe /-
theorem submoduleImage_apply_ofLe {M' : Type _} [AddCommGroup M'] [Module R M'] {O : Submodule R M}
    (ϕ : O →ₗ[R] M') (N : Submodule R M) (hNO : N ≤ O) :
    ϕ.submoduleImage N = (ϕ.comp (Submodule.ofLe hNO)).range := by
  rw [submodule_image, range_comp, Submodule.range_ofLe]
#align linear_map.submodule_image_apply_of_le LinearMap.submoduleImage_apply_ofLe
-/

end Image

end Semiring

end LinearMap

#print LinearMap.range_rangeRestrict /-
@[simp]
theorem LinearMap.range_rangeRestrict [Semiring R] [AddCommMonoid M] [AddCommMonoid M₂] [Module R M]
    [Module R M₂] (f : M →ₗ[R] M₂) : f.range_restrict.range = ⊤ := by simp [f.range_cod_restrict _]
#align linear_map.range_range_restrict LinearMap.range_rangeRestrict
-/

#print LinearMap.ker_rangeRestrict /-
@[simp]
theorem LinearMap.ker_rangeRestrict [Semiring R] [AddCommMonoid M] [AddCommMonoid M₂] [Module R M]
    [Module R M₂] (f : M →ₗ[R] M₂) : f.range_restrict.ker = f.ker :=
  LinearMap.ker_codRestrict _ _ _
#align linear_map.ker_range_restrict LinearMap.ker_rangeRestrict
-/

/-! ### Linear equivalences -/


namespace LinearEquiv

section AddCommMonoid

section Subsingleton

variable [Semiring R] [Semiring R₂]

variable [AddCommMonoid M] [AddCommMonoid M₂]

variable [Module R M] [Module R₂ M₂]

variable {σ₁₂ : R →+* R₂} {σ₂₁ : R₂ →+* R}

variable [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂]

section Module

variable [Subsingleton M] [Subsingleton M₂]

/-- Between two zero modules, the zero map is an equivalence. -/
instance : Zero (M ≃ₛₗ[σ₁₂] M₂) :=
  ⟨{ (0 : M →ₛₗ[σ₁₂] M₂) with
      toFun := 0
      invFun := 0
      right_inv := fun x => Subsingleton.elim _ _
      left_inv := fun x => Subsingleton.elim _ _ }⟩

#print LinearEquiv.zero_symm /-
-- Even though these are implied by `subsingleton.elim` via the `unique` instance below, they're
-- nice to have as `rfl`-lemmas for `dsimp`.
@[simp]
theorem zero_symm : (0 : M ≃ₛₗ[σ₁₂] M₂).symm = 0 :=
  rfl
#align linear_equiv.zero_symm LinearEquiv.zero_symm
-/

#print LinearEquiv.coe_zero /-
@[simp]
theorem coe_zero : ⇑(0 : M ≃ₛₗ[σ₁₂] M₂) = 0 :=
  rfl
#align linear_equiv.coe_zero LinearEquiv.coe_zero
-/

#print LinearEquiv.zero_apply /-
theorem zero_apply (x : M) : (0 : M ≃ₛₗ[σ₁₂] M₂) x = 0 :=
  rfl
#align linear_equiv.zero_apply LinearEquiv.zero_apply
-/

/-- Between two zero modules, the zero map is the only equivalence. -/
instance : Unique (M ≃ₛₗ[σ₁₂] M₂)
    where
  uniq f := toLinearMap_injective (Subsingleton.elim _ _)
  default := 0

end Module

#print LinearEquiv.uniqueOfSubsingleton /-
instance uniqueOfSubsingleton [Subsingleton R] [Subsingleton R₂] : Unique (M ≃ₛₗ[σ₁₂] M₂) := by
  haveI := Module.subsingleton R M; haveI := Module.subsingleton R₂ M₂; infer_instance
#align linear_equiv.unique_of_subsingleton LinearEquiv.uniqueOfSubsingleton
-/

end Subsingleton

section

variable [Semiring R] [Semiring R₂] [Semiring R₃] [Semiring R₄]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]

variable {module_M : Module R M} {module_M₂ : Module R₂ M₂}

variable {σ₁₂ : R →+* R₂} {σ₂₁ : R₂ →+* R}

variable {re₁₂ : RingHomInvPair σ₁₂ σ₂₁} {re₂₁ : RingHomInvPair σ₂₁ σ₁₂}

variable (e e' : M ≃ₛₗ[σ₁₂] M₂)

#print LinearEquiv.map_sum /-
@[simp]
theorem map_sum {s : Finset ι} (u : ι → M) : e (∑ i in s, u i) = ∑ i in s, e (u i) :=
  e.toLinearMap.map_sum
#align linear_equiv.map_sum LinearEquiv.map_sum
-/

#print LinearEquiv.map_eq_comap /-
theorem map_eq_comap {p : Submodule R M} :
    (p.map (e : M →ₛₗ[σ₁₂] M₂) : Submodule R₂ M₂) = p.comap (e.symm : M₂ →ₛₗ[σ₂₁] M) :=
  SetLike.coe_injective <| by simp [e.image_eq_preimage]
#align linear_equiv.map_eq_comap LinearEquiv.map_eq_comap
-/

#print LinearEquiv.submoduleMap /-
/-- A linear equivalence of two modules restricts to a linear equivalence from any submodule
`p` of the domain onto the image of that submodule.

This is the linear version of `add_equiv.submonoid_map` and `add_equiv.subgroup_map`.

This is `linear_equiv.of_submodule'` but with `map` on the right instead of `comap` on the left. -/
def submoduleMap (p : Submodule R M) : p ≃ₛₗ[σ₁₂] ↥(p.map (e : M →ₛₗ[σ₁₂] M₂) : Submodule R₂ M₂) :=
  {
    ((e : M →ₛₗ[σ₁₂] M₂).domRestrict p).codRestrict (p.map (e : M →ₛₗ[σ₁₂] M₂)) fun x =>
      ⟨x, by
        simp only [LinearMap.domRestrict_apply, eq_self_iff_true, and_true_iff, SetLike.coe_mem,
          SetLike.mem_coe]⟩ with
    invFun := fun y =>
      ⟨(e.symm : M₂ →ₛₗ[σ₂₁] M) y, by
        rcases y with ⟨y', hy⟩; rw [Submodule.mem_map] at hy ; rcases hy with ⟨x, hx, hxy⟩;
        subst hxy
        simp only [symm_apply_apply, Submodule.coe_mk, coe_coe, hx]⟩
    left_inv := fun x => by
      simp only [LinearMap.domRestrict_apply, LinearMap.codRestrict_apply, LinearMap.toFun_eq_coe,
        LinearEquiv.coe_coe, LinearEquiv.symm_apply_apply, SetLike.eta]
    right_inv := fun y => by apply SetCoe.ext;
      simp only [LinearMap.domRestrict_apply, LinearMap.codRestrict_apply, LinearMap.toFun_eq_coe,
        LinearEquiv.coe_coe, SetLike.coe_mk, LinearEquiv.apply_symm_apply] }
#align linear_equiv.submodule_map LinearEquiv.submoduleMap
-/

#print LinearEquiv.submoduleMap_apply /-
@[simp]
theorem submoduleMap_apply (p : Submodule R M) (x : p) : ↑(e.submoduleMap p x) = e x :=
  rfl
#align linear_equiv.submodule_map_apply LinearEquiv.submoduleMap_apply
-/

#print LinearEquiv.submoduleMap_symm_apply /-
@[simp]
theorem submoduleMap_symm_apply (p : Submodule R M)
    (x : (p.map (e : M →ₛₗ[σ₁₂] M₂) : Submodule R₂ M₂)) : ↑((e.submoduleMap p).symm x) = e.symm x :=
  rfl
#align linear_equiv.submodule_map_symm_apply LinearEquiv.submoduleMap_symm_apply
-/

end

section Finsupp

variable {γ : Type _}

variable [Semiring R] [Semiring R₂]

variable [AddCommMonoid M] [AddCommMonoid M₂]

variable [Module R M] [Module R₂ M₂] [Zero γ]

variable {τ₁₂ : R →+* R₂} {τ₂₁ : R₂ →+* R}

variable [RingHomInvPair τ₁₂ τ₂₁] [RingHomInvPair τ₂₁ τ₁₂]

#print LinearEquiv.map_finsupp_sum /-
@[simp]
theorem map_finsupp_sum (f : M ≃ₛₗ[τ₁₂] M₂) {t : ι →₀ γ} {g : ι → γ → M} :
    f (t.Sum g) = t.Sum fun i d => f (g i d) :=
  f.map_sum _
#align linear_equiv.map_finsupp_sum LinearEquiv.map_finsupp_sum
-/

end Finsupp

section Dfinsupp

open Dfinsupp

variable [Semiring R] [Semiring R₂]

variable [AddCommMonoid M] [AddCommMonoid M₂]

variable [Module R M] [Module R₂ M₂]

variable {τ₁₂ : R →+* R₂} {τ₂₁ : R₂ →+* R}

variable [RingHomInvPair τ₁₂ τ₂₁] [RingHomInvPair τ₂₁ τ₁₂]

variable {γ : ι → Type _} [DecidableEq ι]

#print LinearEquiv.map_dfinsupp_sum /-
@[simp]
theorem map_dfinsupp_sum [∀ i, Zero (γ i)] [∀ (i) (x : γ i), Decidable (x ≠ 0)] (f : M ≃ₛₗ[τ₁₂] M₂)
    (t : Π₀ i, γ i) (g : ∀ i, γ i → M) : f (t.Sum g) = t.Sum fun i d => f (g i d) :=
  f.map_sum _
#align linear_equiv.map_dfinsupp_sum LinearEquiv.map_dfinsupp_sum
-/

#print LinearEquiv.map_dfinsupp_sumAddHom /-
@[simp]
theorem map_dfinsupp_sumAddHom [∀ i, AddZeroClass (γ i)] (f : M ≃ₛₗ[τ₁₂] M₂) (t : Π₀ i, γ i)
    (g : ∀ i, γ i →+ M) :
    f (sumAddHom g t) = sumAddHom (fun i => f.toAddEquiv.toAddMonoidHom.comp (g i)) t :=
  f.toAddEquiv.map_dfinsupp_sumAddHom _ _
#align linear_equiv.map_dfinsupp_sum_add_hom LinearEquiv.map_dfinsupp_sumAddHom
-/

end Dfinsupp

section Uncurry

variable [Semiring R] [Semiring R₂] [Semiring R₃] [Semiring R₄]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]

variable (V V₂ R)

#print LinearEquiv.curry /-
/-- Linear equivalence between a curried and uncurried function.
  Differs from `tensor_product.curry`. -/
protected def curry : (V × V₂ → R) ≃ₗ[R] V → V₂ → R :=
  { Equiv.curry _ _ _ with
    map_add' := fun _ _ => by ext; rfl
    map_smul' := fun _ _ => by ext; rfl }
#align linear_equiv.curry LinearEquiv.curry
-/

#print LinearEquiv.coe_curry /-
@[simp]
theorem coe_curry : ⇑(LinearEquiv.curry R V V₂) = curry :=
  rfl
#align linear_equiv.coe_curry LinearEquiv.coe_curry
-/

#print LinearEquiv.coe_curry_symm /-
@[simp]
theorem coe_curry_symm : ⇑(LinearEquiv.curry R V V₂).symm = uncurry :=
  rfl
#align linear_equiv.coe_curry_symm LinearEquiv.coe_curry_symm
-/

end Uncurry

section

variable [Semiring R] [Semiring R₂] [Semiring R₃] [Semiring R₄]

variable [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃] [AddCommMonoid M₄]

variable {module_M : Module R M} {module_M₂ : Module R₂ M₂} {module_M₃ : Module R₃ M₃}

variable {σ₁₂ : R →+* R₂} {σ₂₁ : R₂ →+* R}

variable {σ₂₃ : R₂ →+* R₃} {σ₁₃ : R →+* R₃} [RingHomCompTriple σ₁₂ σ₂₃ σ₁₃]

variable {σ₃₂ : R₃ →+* R₂}

variable {re₁₂ : RingHomInvPair σ₁₂ σ₂₁} {re₂₁ : RingHomInvPair σ₂₁ σ₁₂}

variable {re₂₃ : RingHomInvPair σ₂₃ σ₃₂} {re₃₂ : RingHomInvPair σ₃₂ σ₂₃}

variable (f : M →ₛₗ[σ₁₂] M₂) (g : M₂ →ₛₗ[σ₂₁] M) (e : M ≃ₛₗ[σ₁₂] M₂) (h : M₂ →ₛₗ[σ₂₃] M₃)

variable (e'' : M₂ ≃ₛₗ[σ₂₃] M₃)

variable (p q : Submodule R M)

#print LinearEquiv.ofEq /-
/-- Linear equivalence between two equal submodules. -/
def ofEq (h : p = q) : p ≃ₗ[R] q :=
  { Equiv.Set.ofEq (congr_arg _ h) with
    map_smul' := fun _ _ => rfl
    map_add' := fun _ _ => rfl }
#align linear_equiv.of_eq LinearEquiv.ofEq
-/

variable {p q}

#print LinearEquiv.coe_ofEq_apply /-
@[simp]
theorem coe_ofEq_apply (h : p = q) (x : p) : (ofEq p q h x : M) = x :=
  rfl
#align linear_equiv.coe_of_eq_apply LinearEquiv.coe_ofEq_apply
-/

#print LinearEquiv.ofEq_symm /-
@[simp]
theorem ofEq_symm (h : p = q) : (ofEq p q h).symm = ofEq q p h.symm :=
  rfl
#align linear_equiv.of_eq_symm LinearEquiv.ofEq_symm
-/

#print LinearEquiv.ofEq_rfl /-
@[simp]
theorem ofEq_rfl : ofEq p p rfl = LinearEquiv.refl R p := by ext <;> rfl
#align linear_equiv.of_eq_rfl LinearEquiv.ofEq_rfl
-/

#print LinearEquiv.ofSubmodules /-
/-- A linear equivalence which maps a submodule of one module onto another, restricts to a linear
equivalence of the two submodules. -/
def ofSubmodules (p : Submodule R M) (q : Submodule R₂ M₂) (h : p.map (e : M →ₛₗ[σ₁₂] M₂) = q) :
    p ≃ₛₗ[σ₁₂] q :=
  (e.submoduleMap p).trans (LinearEquiv.ofEq _ _ h)
#align linear_equiv.of_submodules LinearEquiv.ofSubmodules
-/

#print LinearEquiv.ofSubmodules_apply /-
@[simp]
theorem ofSubmodules_apply {p : Submodule R M} {q : Submodule R₂ M₂} (h : p.map ↑e = q) (x : p) :
    ↑(e.ofSubmodules p q h x) = e x :=
  rfl
#align linear_equiv.of_submodules_apply LinearEquiv.ofSubmodules_apply
-/

#print LinearEquiv.ofSubmodules_symm_apply /-
@[simp]
theorem ofSubmodules_symm_apply {p : Submodule R M} {q : Submodule R₂ M₂} (h : p.map ↑e = q)
    (x : q) : ↑((e.ofSubmodules p q h).symm x) = e.symm x :=
  rfl
#align linear_equiv.of_submodules_symm_apply LinearEquiv.ofSubmodules_symm_apply
-/

#print LinearEquiv.ofSubmodule' /-
/-- A linear equivalence of two modules restricts to a linear equivalence from the preimage of any
submodule to that submodule.

This is `linear_equiv.of_submodule` but with `comap` on the left instead of `map` on the right. -/
def ofSubmodule' [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂) (U : Submodule R₂ M₂) :
    U.comap (f : M →ₛₗ[σ₁₂] M₂) ≃ₛₗ[σ₁₂] U :=
  (f.symm.ofSubmodules _ _ f.symm.map_eq_comap).symm
#align linear_equiv.of_submodule' LinearEquiv.ofSubmodule'
-/

#print LinearEquiv.ofSubmodule'_toLinearMap /-
theorem ofSubmodule'_toLinearMap [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂)
    (U : Submodule R₂ M₂) :
    (f.ofSubmodule' U).toLinearMap = (f.toLinearMap.domRestrict _).codRestrict _ Subtype.prop := by
  ext; rfl
#align linear_equiv.of_submodule'_to_linear_map LinearEquiv.ofSubmodule'_toLinearMap
-/

#print LinearEquiv.ofSubmodule'_apply /-
@[simp]
theorem ofSubmodule'_apply [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂) (U : Submodule R₂ M₂)
    (x : U.comap (f : M →ₛₗ[σ₁₂] M₂)) : (f.ofSubmodule' U x : M₂) = f (x : M) :=
  rfl
#align linear_equiv.of_submodule'_apply LinearEquiv.ofSubmodule'_apply
-/

#print LinearEquiv.ofSubmodule'_symm_apply /-
@[simp]
theorem ofSubmodule'_symm_apply [Module R M] [Module R₂ M₂] (f : M ≃ₛₗ[σ₁₂] M₂)
    (U : Submodule R₂ M₂) (x : U) : ((f.ofSubmodule' U).symm x : M) = f.symm (x : M₂) :=
  rfl
#align linear_equiv.of_submodule'_symm_apply LinearEquiv.ofSubmodule'_symm_apply
-/

variable (p)

#print LinearEquiv.ofTop /-
/-- The top submodule of `M` is linearly equivalent to `M`. -/
def ofTop (h : p = ⊤) : p ≃ₗ[R] M :=
  { p.Subtype with
    invFun := fun x => ⟨x, h.symm ▸ trivial⟩
    left_inv := fun ⟨x, h⟩ => rfl
    right_inv := fun x => rfl }
#align linear_equiv.of_top LinearEquiv.ofTop
-/

#print LinearEquiv.ofTop_apply /-
@[simp]
theorem ofTop_apply {h} (x : p) : ofTop p h x = x :=
  rfl
#align linear_equiv.of_top_apply LinearEquiv.ofTop_apply
-/

#print LinearEquiv.coe_ofTop_symm_apply /-
@[simp]
theorem coe_ofTop_symm_apply {h} (x : M) : ((ofTop p h).symm x : M) = x :=
  rfl
#align linear_equiv.coe_of_top_symm_apply LinearEquiv.coe_ofTop_symm_apply
-/

#print LinearEquiv.ofTop_symm_apply /-
theorem ofTop_symm_apply {h} (x : M) : (ofTop p h).symm x = ⟨x, h.symm ▸ trivial⟩ :=
  rfl
#align linear_equiv.of_top_symm_apply LinearEquiv.ofTop_symm_apply
-/

#print LinearEquiv.ofLinear /-
/-- If a linear map has an inverse, it is a linear equivalence. -/
def ofLinear (h₁ : f.comp g = LinearMap.id) (h₂ : g.comp f = LinearMap.id) : M ≃ₛₗ[σ₁₂] M₂ :=
  { f with
    invFun := g
    left_inv := LinearMap.ext_iff.1 h₂
    right_inv := LinearMap.ext_iff.1 h₁ }
#align linear_equiv.of_linear LinearEquiv.ofLinear
-/

#print LinearEquiv.ofLinear_apply /-
@[simp]
theorem ofLinear_apply {h₁ h₂} (x : M) : ofLinear f g h₁ h₂ x = f x :=
  rfl
#align linear_equiv.of_linear_apply LinearEquiv.ofLinear_apply
-/

#print LinearEquiv.ofLinear_symm_apply /-
@[simp]
theorem ofLinear_symm_apply {h₁ h₂} (x : M₂) : (ofLinear f g h₁ h₂).symm x = g x :=
  rfl
#align linear_equiv.of_linear_symm_apply LinearEquiv.ofLinear_symm_apply
-/

#print LinearEquiv.range /-
@[simp]
protected theorem range : (e : M →ₛₗ[σ₁₂] M₂).range = ⊤ :=
  LinearMap.range_eq_top.2 e.toEquiv.Surjective
#align linear_equiv.range LinearEquiv.range
-/

#print LinearEquivClass.range /-
@[simp]
protected theorem LinearEquivClass.range [Module R M] [Module R₂ M₂] {F : Type _}
    [SemilinearEquivClass F σ₁₂ M M₂] (e : F) : LinearMap.range e = ⊤ :=
  LinearMap.range_eq_top.2 (EquivLike.surjective e)
#align linear_equiv_class.range LinearEquivClass.range
-/

#print LinearEquiv.eq_bot_of_equiv /-
theorem eq_bot_of_equiv [Module R₂ M₂] (e : p ≃ₛₗ[σ₁₂] (⊥ : Submodule R₂ M₂)) : p = ⊥ :=
  by
  refine' bot_unique (SetLike.le_def.2 fun b hb => (Submodule.mem_bot R).2 _)
  rw [← p.mk_eq_zero hb, ← e.map_eq_zero_iff]
  apply Submodule.eq_zero_of_bot_submodule
#align linear_equiv.eq_bot_of_equiv LinearEquiv.eq_bot_of_equiv
-/

#print LinearEquiv.ker /-
@[simp]
protected theorem ker : (e : M →ₛₗ[σ₁₂] M₂).ker = ⊥ :=
  LinearMap.ker_eq_bot_of_injective e.toEquiv.Injective
#align linear_equiv.ker LinearEquiv.ker
-/

#print LinearEquiv.range_comp /-
@[simp]
theorem range_comp [RingHomSurjective σ₁₂] [RingHomSurjective σ₂₃] [RingHomSurjective σ₁₃] :
    (h.comp (e : M →ₛₗ[σ₁₂] M₂) : M →ₛₗ[σ₁₃] M₃).range = h.range :=
  LinearMap.range_comp_of_range_eq_top _ e.range
#align linear_equiv.range_comp LinearEquiv.range_comp
-/

#print LinearEquiv.ker_comp /-
@[simp]
theorem ker_comp (l : M →ₛₗ[σ₁₂] M₂) :
    (((e'' : M₂ →ₛₗ[σ₂₃] M₃).comp l : M →ₛₗ[σ₁₃] M₃) : M →ₛₗ[σ₁₃] M₃).ker = l.ker :=
  LinearMap.ker_comp_of_ker_eq_bot _ e''.ker
#align linear_equiv.ker_comp LinearEquiv.ker_comp
-/

variable {f g}

#print LinearEquiv.ofLeftInverse /-
/-- An linear map `f : M →ₗ[R] M₂` with a left-inverse `g : M₂ →ₗ[R] M` defines a linear
equivalence between `M` and `f.range`.

This is a computable alternative to `linear_equiv.of_injective`, and a bidirectional version of
`linear_map.range_restrict`. -/
def ofLeftInverse [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] {g : M₂ → M}
    (h : Function.LeftInverse g f) : M ≃ₛₗ[σ₁₂] f.range :=
  { f.range_restrict with
    toFun := f.range_restrict
    invFun := g ∘ f.range.Subtype
    left_inv := h
    right_inv := fun x =>
      Subtype.ext <|
        let ⟨x', hx'⟩ := LinearMap.mem_range.mp x.Prop
        show f (g x) = x by rw [← hx', h x'] }
#align linear_equiv.of_left_inverse LinearEquiv.ofLeftInverse
-/

#print LinearEquiv.ofLeftInverse_apply /-
@[simp]
theorem ofLeftInverse_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂]
    (h : Function.LeftInverse g f) (x : M) : ↑(ofLeftInverse h x) = f x :=
  rfl
#align linear_equiv.of_left_inverse_apply LinearEquiv.ofLeftInverse_apply
-/

#print LinearEquiv.ofLeftInverse_symm_apply /-
@[simp]
theorem ofLeftInverse_symm_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂]
    (h : Function.LeftInverse g f) (x : f.range) : (ofLeftInverse h).symm x = g x :=
  rfl
#align linear_equiv.of_left_inverse_symm_apply LinearEquiv.ofLeftInverse_symm_apply
-/

variable (f)

#print LinearEquiv.ofInjective /-
/-- An `injective` linear map `f : M →ₗ[R] M₂` defines a linear equivalence
between `M` and `f.range`. See also `linear_map.of_left_inverse`. -/
noncomputable def ofInjective [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] (h : Injective f) :
    M ≃ₛₗ[σ₁₂] f.range :=
  ofLeftInverse <| Classical.choose_spec h.HasLeftInverse
#align linear_equiv.of_injective LinearEquiv.ofInjective
-/

#print LinearEquiv.ofInjective_apply /-
@[simp]
theorem ofInjective_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] {h : Injective f}
    (x : M) : ↑(ofInjective f h x) = f x :=
  rfl
#align linear_equiv.of_injective_apply LinearEquiv.ofInjective_apply
-/

#print LinearEquiv.ofBijective /-
/-- A bijective linear map is a linear equivalence. -/
noncomputable def ofBijective [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] (hf : Bijective f) :
    M ≃ₛₗ[σ₁₂] M₂ :=
  (ofInjective f hf.Injective).trans (ofTop _ <| LinearMap.range_eq_top.2 hf.Surjective)
#align linear_equiv.of_bijective LinearEquiv.ofBijective
-/

#print LinearEquiv.ofBijective_apply /-
@[simp]
theorem ofBijective_apply [RingHomInvPair σ₁₂ σ₂₁] [RingHomInvPair σ₂₁ σ₁₂] {hf} (x : M) :
    ofBijective f hf x = f x :=
  rfl
#align linear_equiv.of_bijective_apply LinearEquiv.ofBijective_apply
-/

end

end AddCommMonoid

section AddCommGroup

variable [Semiring R] [Semiring R₂] [Semiring R₃] [Semiring R₄]

variable [AddCommGroup M] [AddCommGroup M₂] [AddCommGroup M₃] [AddCommGroup M₄]

variable {module_M : Module R M} {module_M₂ : Module R₂ M₂}

variable {module_M₃ : Module R₃ M₃} {module_M₄ : Module R₄ M₄}

variable {σ₁₂ : R →+* R₂} {σ₃₄ : R₃ →+* R₄}

variable {σ₂₁ : R₂ →+* R} {σ₄₃ : R₄ →+* R₃}

variable {re₁₂ : RingHomInvPair σ₁₂ σ₂₁} {re₂₁ : RingHomInvPair σ₂₁ σ₁₂}

variable {re₃₄ : RingHomInvPair σ₃₄ σ₄₃} {re₄₃ : RingHomInvPair σ₄₃ σ₃₄}

variable (e e₁ : M ≃ₛₗ[σ₁₂] M₂) (e₂ : M₃ ≃ₛₗ[σ₃₄] M₄)

#print LinearEquiv.map_neg /-
@[simp]
theorem map_neg (a : M) : e (-a) = -e a :=
  e.toLinearMap.map_neg a
#align linear_equiv.map_neg LinearEquiv.map_neg
-/

#print LinearEquiv.map_sub /-
@[simp]
theorem map_sub (a b : M) : e (a - b) = e a - e b :=
  e.toLinearMap.map_sub a b
#align linear_equiv.map_sub LinearEquiv.map_sub
-/

end AddCommGroup

section Neg

variable (R) [Semiring R] [AddCommGroup M] [Module R M]

#print LinearEquiv.neg /-
/-- `x ↦ -x` as a `linear_equiv` -/
def neg : M ≃ₗ[R] M :=
  { Equiv.neg M, (-LinearMap.id : M →ₗ[R] M) with }
#align linear_equiv.neg LinearEquiv.neg
-/

variable {R}

#print LinearEquiv.coe_neg /-
@[simp]
theorem coe_neg : ⇑(neg R : M ≃ₗ[R] M) = -id :=
  rfl
#align linear_equiv.coe_neg LinearEquiv.coe_neg
-/

#print LinearEquiv.neg_apply /-
theorem neg_apply (x : M) : neg R x = -x := by simp
#align linear_equiv.neg_apply LinearEquiv.neg_apply
-/

#print LinearEquiv.symm_neg /-
@[simp]
theorem symm_neg : (neg R : M ≃ₗ[R] M).symm = neg R :=
  rfl
#align linear_equiv.symm_neg LinearEquiv.symm_neg
-/

end Neg

section CommSemiring

variable [CommSemiring R] [AddCommMonoid M] [AddCommMonoid M₂] [AddCommMonoid M₃]

variable [Module R M] [Module R M₂] [Module R M₃]

open _Root_.LinearMap

#print LinearEquiv.smulOfUnit /-
/-- Multiplying by a unit `a` of the ring `R` is a linear equivalence. -/
def smulOfUnit (a : Rˣ) : M ≃ₗ[R] M :=
  DistribMulAction.toLinearEquiv R M a
#align linear_equiv.smul_of_unit LinearEquiv.smulOfUnit
-/

#print LinearEquiv.arrowCongr /-
/-- A linear isomorphism between the domains and codomains of two spaces of linear maps gives a
linear isomorphism between the two function spaces. -/
def arrowCongr {R M₁ M₂ M₂₁ M₂₂ : Sort _} [CommSemiring R] [AddCommMonoid M₁] [AddCommMonoid M₂]
    [AddCommMonoid M₂₁] [AddCommMonoid M₂₂] [Module R M₁] [Module R M₂] [Module R M₂₁]
    [Module R M₂₂] (e₁ : M₁ ≃ₗ[R] M₂) (e₂ : M₂₁ ≃ₗ[R] M₂₂) : (M₁ →ₗ[R] M₂₁) ≃ₗ[R] M₂ →ₗ[R] M₂₂
    where
  toFun := fun f : M₁ →ₗ[R] M₂₁ => (e₂ : M₂₁ →ₗ[R] M₂₂).comp <| f.comp (e₁.symm : M₂ →ₗ[R] M₁)
  invFun f := (e₂.symm : M₂₂ →ₗ[R] M₂₁).comp <| f.comp (e₁ : M₁ →ₗ[R] M₂)
  left_inv f := by ext x; simp only [symm_apply_apply, comp_app, coe_comp, coe_coe]
  right_inv f := by ext x; simp only [comp_app, apply_symm_apply, coe_comp, coe_coe]
  map_add' f g := by ext x; simp only [map_add, add_apply, comp_app, coe_comp, coe_coe]
  map_smul' c f := by ext x; simp only [smul_apply, comp_app, coe_comp, map_smulₛₗ e₂, coe_coe]
#align linear_equiv.arrow_congr LinearEquiv.arrowCongr
-/

#print LinearEquiv.arrowCongr_apply /-
@[simp]
theorem arrowCongr_apply {R M₁ M₂ M₂₁ M₂₂ : Sort _} [CommSemiring R] [AddCommMonoid M₁]
    [AddCommMonoid M₂] [AddCommMonoid M₂₁] [AddCommMonoid M₂₂] [Module R M₁] [Module R M₂]
    [Module R M₂₁] [Module R M₂₂] (e₁ : M₁ ≃ₗ[R] M₂) (e₂ : M₂₁ ≃ₗ[R] M₂₂) (f : M₁ →ₗ[R] M₂₁)
    (x : M₂) : arrowCongr e₁ e₂ f x = e₂ (f (e₁.symm x)) :=
  rfl
#align linear_equiv.arrow_congr_apply LinearEquiv.arrowCongr_apply
-/

#print LinearEquiv.arrowCongr_symm_apply /-
@[simp]
theorem arrowCongr_symm_apply {R M₁ M₂ M₂₁ M₂₂ : Sort _} [CommSemiring R] [AddCommMonoid M₁]
    [AddCommMonoid M₂] [AddCommMonoid M₂₁] [AddCommMonoid M₂₂] [Module R M₁] [Module R M₂]
    [Module R M₂₁] [Module R M₂₂] (e₁ : M₁ ≃ₗ[R] M₂) (e₂ : M₂₁ ≃ₗ[R] M₂₂) (f : M₂ →ₗ[R] M₂₂)
    (x : M₁) : (arrowCongr e₁ e₂).symm f x = e₂.symm (f (e₁ x)) :=
  rfl
#align linear_equiv.arrow_congr_symm_apply LinearEquiv.arrowCongr_symm_apply
-/

#print LinearEquiv.arrowCongr_comp /-
theorem arrowCongr_comp {N N₂ N₃ : Sort _} [AddCommMonoid N] [AddCommMonoid N₂] [AddCommMonoid N₃]
    [Module R N] [Module R N₂] [Module R N₃] (e₁ : M ≃ₗ[R] N) (e₂ : M₂ ≃ₗ[R] N₂) (e₃ : M₃ ≃ₗ[R] N₃)
    (f : M →ₗ[R] M₂) (g : M₂ →ₗ[R] M₃) :
    arrowCongr e₁ e₃ (g.comp f) = (arrowCongr e₂ e₃ g).comp (arrowCongr e₁ e₂ f) := by ext;
  simp only [symm_apply_apply, arrow_congr_apply, LinearMap.comp_apply]
#align linear_equiv.arrow_congr_comp LinearEquiv.arrowCongr_comp
-/

#print LinearEquiv.arrowCongr_trans /-
theorem arrowCongr_trans {M₁ M₂ M₃ N₁ N₂ N₃ : Sort _} [AddCommMonoid M₁] [Module R M₁]
    [AddCommMonoid M₂] [Module R M₂] [AddCommMonoid M₃] [Module R M₃] [AddCommMonoid N₁]
    [Module R N₁] [AddCommMonoid N₂] [Module R N₂] [AddCommMonoid N₃] [Module R N₃]
    (e₁ : M₁ ≃ₗ[R] M₂) (e₂ : N₁ ≃ₗ[R] N₂) (e₃ : M₂ ≃ₗ[R] M₃) (e₄ : N₂ ≃ₗ[R] N₃) :
    (arrowCongr e₁ e₂).trans (arrowCongr e₃ e₄) = arrowCongr (e₁.trans e₃) (e₂.trans e₄) :=
  rfl
#align linear_equiv.arrow_congr_trans LinearEquiv.arrowCongr_trans
-/

#print LinearEquiv.congrRight /-
/-- If `M₂` and `M₃` are linearly isomorphic then the two spaces of linear maps from `M` into `M₂`
and `M` into `M₃` are linearly isomorphic. -/
def congrRight (f : M₂ ≃ₗ[R] M₃) : (M →ₗ[R] M₂) ≃ₗ[R] M →ₗ[R] M₃ :=
  arrowCongr (LinearEquiv.refl R M) f
#align linear_equiv.congr_right LinearEquiv.congrRight
-/

#print LinearEquiv.conj /-
/-- If `M` and `M₂` are linearly isomorphic then the two spaces of linear maps from `M` and `M₂` to
themselves are linearly isomorphic. -/
def conj (e : M ≃ₗ[R] M₂) : Module.End R M ≃ₗ[R] Module.End R M₂ :=
  arrowCongr e e
#align linear_equiv.conj LinearEquiv.conj
-/

#print LinearEquiv.conj_apply /-
theorem conj_apply (e : M ≃ₗ[R] M₂) (f : Module.End R M) :
    e.conj f = ((↑e : M →ₗ[R] M₂).comp f).comp (e.symm : M₂ →ₗ[R] M) :=
  rfl
#align linear_equiv.conj_apply LinearEquiv.conj_apply
-/

#print LinearEquiv.conj_apply_apply /-
theorem conj_apply_apply (e : M ≃ₗ[R] M₂) (f : Module.End R M) (x : M₂) :
    e.conj f x = e (f (e.symm x)) :=
  rfl
#align linear_equiv.conj_apply_apply LinearEquiv.conj_apply_apply
-/

#print LinearEquiv.symm_conj_apply /-
theorem symm_conj_apply (e : M ≃ₗ[R] M₂) (f : Module.End R M₂) :
    e.symm.conj f = ((↑e.symm : M₂ →ₗ[R] M).comp f).comp (e : M →ₗ[R] M₂) :=
  rfl
#align linear_equiv.symm_conj_apply LinearEquiv.symm_conj_apply
-/

#print LinearEquiv.conj_comp /-
theorem conj_comp (e : M ≃ₗ[R] M₂) (f g : Module.End R M) :
    e.conj (g.comp f) = (e.conj g).comp (e.conj f) :=
  arrowCongr_comp e e e f g
#align linear_equiv.conj_comp LinearEquiv.conj_comp
-/

#print LinearEquiv.conj_trans /-
theorem conj_trans (e₁ : M ≃ₗ[R] M₂) (e₂ : M₂ ≃ₗ[R] M₃) :
    e₁.conj.trans e₂.conj = (e₁.trans e₂).conj := by ext f x; rfl
#align linear_equiv.conj_trans LinearEquiv.conj_trans
-/

#print LinearEquiv.conj_id /-
@[simp]
theorem conj_id (e : M ≃ₗ[R] M₂) : e.conj LinearMap.id = LinearMap.id := by ext; simp [conj_apply]
#align linear_equiv.conj_id LinearEquiv.conj_id
-/

end CommSemiring

section Field

variable [Field K] [AddCommGroup M] [AddCommGroup M₂] [AddCommGroup M₃]

variable [Module K M] [Module K M₂] [Module K M₃]

variable (K) (M)

open _Root_.LinearMap

#print LinearEquiv.smulOfNeZero /-
/-- Multiplying by a nonzero element `a` of the field `K` is a linear equivalence. -/
@[simps]
def smulOfNeZero (a : K) (ha : a ≠ 0) : M ≃ₗ[K] M :=
  smulOfUnit <| Units.mk0 a ha
#align linear_equiv.smul_of_ne_zero LinearEquiv.smulOfNeZero
-/

end Field

end LinearEquiv

namespace Submodule

section Module

variable [Semiring R] [AddCommMonoid M] [Module R M]

#print Submodule.equivSubtypeMap /-
/-- Given `p` a submodule of the module `M` and `q` a submodule of `p`, `p.equiv_subtype_map q`
is the natural `linear_equiv` between `q` and `q.map p.subtype`. -/
def equivSubtypeMap (p : Submodule R M) (q : Submodule R p) : q ≃ₗ[R] q.map p.Subtype :=
  {
    (p.Subtype.domRestrict q).codRestrict _
      (by
        rintro ⟨x, hx⟩
        refine'
          ⟨x, hx,
            rfl⟩) with
    invFun := by
      rintro ⟨x, hx⟩
      refine' ⟨⟨x, _⟩, _⟩ <;> rcases hx with ⟨⟨_, h⟩, _, rfl⟩ <;> assumption
    left_inv := fun ⟨⟨_, _⟩, _⟩ => rfl
    right_inv := fun ⟨x, ⟨_, h⟩, _, rfl⟩ => rfl }
#align submodule.equiv_subtype_map Submodule.equivSubtypeMap
-/

#print Submodule.equivSubtypeMap_apply /-
@[simp]
theorem equivSubtypeMap_apply {p : Submodule R M} {q : Submodule R p} (x : q) :
    (p.equivSubtypeMap q x : M) = p.Subtype.domRestrict q x :=
  rfl
#align submodule.equiv_subtype_map_apply Submodule.equivSubtypeMap_apply
-/

#print Submodule.equivSubtypeMap_symm_apply /-
@[simp]
theorem equivSubtypeMap_symm_apply {p : Submodule R M} {q : Submodule R p} (x : q.map p.Subtype) :
    ((p.equivSubtypeMap q).symm x : M) = x := by cases x; rfl
#align submodule.equiv_subtype_map_symm_apply Submodule.equivSubtypeMap_symm_apply
-/

#print Submodule.comapSubtypeEquivOfLe /-
/-- If `s ≤ t`, then we can view `s` as a submodule of `t` by taking the comap
of `t.subtype`. -/
@[simps]
def comapSubtypeEquivOfLe {p q : Submodule R M} (hpq : p ≤ q) : comap q.Subtype p ≃ₗ[R] p
    where
  toFun x := ⟨x, x.2⟩
  invFun x := ⟨⟨x, hpq x.2⟩, x.2⟩
  left_inv x := by simp only [coe_mk, SetLike.eta, coe_coe]
  right_inv x := by simp only [Subtype.coe_mk, SetLike.eta, coe_coe]
  map_add' x y := rfl
  map_smul' c x := rfl
#align submodule.comap_subtype_equiv_of_le Submodule.comapSubtypeEquivOfLe
-/

end Module

end Submodule

namespace Submodule

variable [CommSemiring R] [CommSemiring R₂]

variable [AddCommMonoid M] [AddCommMonoid M₂] [Module R M] [Module R₂ M₂]

variable [AddCommMonoid N] [AddCommMonoid N₂] [Module R N] [Module R N₂]

variable {τ₁₂ : R →+* R₂} {τ₂₁ : R₂ →+* R}

variable [RingHomInvPair τ₁₂ τ₂₁] [RingHomInvPair τ₂₁ τ₁₂]

variable (p : Submodule R M) (q : Submodule R₂ M₂)

variable (pₗ : Submodule R N) (qₗ : Submodule R N₂)

#print Submodule.mem_map_equiv /-
@[simp]
theorem mem_map_equiv {e : M ≃ₛₗ[τ₁₂] M₂} {x : M₂} : x ∈ p.map (e : M →ₛₗ[τ₁₂] M₂) ↔ e.symm x ∈ p :=
  by
  rw [Submodule.mem_map]; constructor
  · rintro ⟨y, hy, hx⟩; simp [← hx, hy]
  · intro hx; refine' ⟨e.symm x, hx, by simp⟩
#align submodule.mem_map_equiv Submodule.mem_map_equiv
-/

#print Submodule.map_equiv_eq_comap_symm /-
theorem map_equiv_eq_comap_symm (e : M ≃ₛₗ[τ₁₂] M₂) (K : Submodule R M) :
    K.map (e : M →ₛₗ[τ₁₂] M₂) = K.comap (e.symm : M₂ →ₛₗ[τ₂₁] M) :=
  Submodule.ext fun _ => by rw [mem_map_equiv, mem_comap, LinearEquiv.coe_coe]
#align submodule.map_equiv_eq_comap_symm Submodule.map_equiv_eq_comap_symm
-/

#print Submodule.comap_equiv_eq_map_symm /-
theorem comap_equiv_eq_map_symm (e : M ≃ₛₗ[τ₁₂] M₂) (K : Submodule R₂ M₂) :
    K.comap (e : M →ₛₗ[τ₁₂] M₂) = K.map (e.symm : M₂ →ₛₗ[τ₂₁] M) :=
  (map_equiv_eq_comap_symm e.symm K).symm
#align submodule.comap_equiv_eq_map_symm Submodule.comap_equiv_eq_map_symm
-/

variable {p}

#print Submodule.map_symm_eq_iff /-
theorem map_symm_eq_iff (e : M ≃ₛₗ[τ₁₂] M₂) {K : Submodule R₂ M₂} :
    K.map e.symm = p ↔ p.map e = K :=
  by
  constructor <;> rintro rfl
  ·
    calc
      map e (map e.symm K) = comap e.symm (map e.symm K) := map_equiv_eq_comap_symm _ _
      _ = K := comap_map_eq_of_injective e.symm.injective _
  ·
    calc
      map e.symm (map e p) = comap e (map e p) := (comap_equiv_eq_map_symm _ _).symm
      _ = p := comap_map_eq_of_injective e.injective _
#align submodule.map_symm_eq_iff Submodule.map_symm_eq_iff
-/

#print Submodule.orderIsoMapComap_apply' /-
theorem orderIsoMapComap_apply' (e : M ≃ₛₗ[τ₁₂] M₂) (p : Submodule R M) :
    orderIsoMapComap e p = comap e.symm p :=
  p.map_equiv_eq_comap_symm _
#align submodule.order_iso_map_comap_apply' Submodule.orderIsoMapComap_apply'
-/

#print Submodule.orderIsoMapComap_symm_apply' /-
theorem orderIsoMapComap_symm_apply' (e : M ≃ₛₗ[τ₁₂] M₂) (p : Submodule R₂ M₂) :
    (orderIsoMapComap e).symm p = map e.symm p :=
  p.comap_equiv_eq_map_symm _
#align submodule.order_iso_map_comap_symm_apply' Submodule.orderIsoMapComap_symm_apply'
-/

#print Submodule.comap_le_comap_smul /-
theorem comap_le_comap_smul (fₗ : N →ₗ[R] N₂) (c : R) : comap fₗ qₗ ≤ comap (c • fₗ) qₗ :=
  by
  rw [SetLike.le_def]
  intro m h
  change c • fₗ m ∈ qₗ
  change fₗ m ∈ qₗ at h 
  apply qₗ.smul_mem _ h
#align submodule.comap_le_comap_smul Submodule.comap_le_comap_smul
-/

#print Submodule.inf_comap_le_comap_add /-
theorem inf_comap_le_comap_add (f₁ f₂ : M →ₛₗ[τ₁₂] M₂) :
    comap f₁ q ⊓ comap f₂ q ≤ comap (f₁ + f₂) q :=
  by
  rw [SetLike.le_def]
  intro m h
  change f₁ m + f₂ m ∈ q
  change f₁ m ∈ q ∧ f₂ m ∈ q at h 
  apply q.add_mem h.1 h.2
#align submodule.inf_comap_le_comap_add Submodule.inf_comap_le_comap_add
-/

#print Submodule.compatibleMaps /-
/-- Given modules `M`, `M₂` over a commutative ring, together with submodules `p ⊆ M`, `q ⊆ M₂`,
the set of maps $\{f ∈ Hom(M, M₂) | f(p) ⊆ q \}$ is a submodule of `Hom(M, M₂)`. -/
def compatibleMaps : Submodule R (N →ₗ[R] N₂)
    where
  carrier := {fₗ | pₗ ≤ comap fₗ qₗ}
  zero_mem' := by change pₗ ≤ comap (0 : N →ₗ[R] N₂) qₗ; rw [comap_zero]; refine' le_top
  add_mem' f₁ f₂ h₁ h₂ :=
    by
    apply le_trans _ (inf_comap_le_comap_add qₗ f₁ f₂)
    rw [le_inf_iff]; exact ⟨h₁, h₂⟩
  smul_mem' c fₗ h := le_trans h (comap_le_comap_smul qₗ fₗ c)
#align submodule.compatible_maps Submodule.compatibleMaps
-/

end Submodule

namespace Equiv

variable [Semiring R] [AddCommMonoid M] [Module R M] [AddCommMonoid M₂] [Module R M₂]

#print Equiv.toLinearEquiv /-
/-- An equivalence whose underlying function is linear is a linear equivalence. -/
def toLinearEquiv (e : M ≃ M₂) (h : IsLinearMap R (e : M → M₂)) : M ≃ₗ[R] M₂ :=
  { e, h.mk' e with }
#align equiv.to_linear_equiv Equiv.toLinearEquiv
-/

end Equiv

section FunLeft

variable (R M) [Semiring R] [AddCommMonoid M] [Module R M]

variable {m n p : Type _}

namespace LinearMap

#print LinearMap.funLeft /-
/-- Given an `R`-module `M` and a function `m → n` between arbitrary types,
construct a linear map `(n → M) →ₗ[R] (m → M)` -/
def funLeft (f : m → n) : (n → M) →ₗ[R] m → M
    where
  toFun := (· ∘ f)
  map_add' _ _ := rfl
  map_smul' _ _ := rfl
#align linear_map.fun_left LinearMap.funLeft
-/

#print LinearMap.funLeft_apply /-
@[simp]
theorem funLeft_apply (f : m → n) (g : n → M) (i : m) : funLeft R M f g i = g (f i) :=
  rfl
#align linear_map.fun_left_apply LinearMap.funLeft_apply
-/

#print LinearMap.funLeft_id /-
@[simp]
theorem funLeft_id (g : n → M) : funLeft R M id g = g :=
  rfl
#align linear_map.fun_left_id LinearMap.funLeft_id
-/

#print LinearMap.funLeft_comp /-
theorem funLeft_comp (f₁ : n → p) (f₂ : m → n) :
    funLeft R M (f₁ ∘ f₂) = (funLeft R M f₂).comp (funLeft R M f₁) :=
  rfl
#align linear_map.fun_left_comp LinearMap.funLeft_comp
-/

#print LinearMap.funLeft_surjective_of_injective /-
theorem funLeft_surjective_of_injective (f : m → n) (hf : Injective f) :
    Surjective (funLeft R M f) := by
  classical
  intro g
  refine' ⟨fun x => if h : ∃ y, f y = x then g h.some else 0, _⟩
  · ext
    dsimp only [fun_left_apply]
    split_ifs with w
    · congr
      exact hf w.some_spec
    · simpa only [not_true, exists_apply_eq_apply] using w
#align linear_map.fun_left_surjective_of_injective LinearMap.funLeft_surjective_of_injective
-/

#print LinearMap.funLeft_injective_of_surjective /-
theorem funLeft_injective_of_surjective (f : m → n) (hf : Surjective f) :
    Injective (funLeft R M f) :=
  by
  obtain ⟨g, hg⟩ := hf.has_right_inverse
  suffices left_inverse (fun_left R M g) (fun_left R M f) by exact this.injective
  intro x
  rw [← LinearMap.comp_apply, ← fun_left_comp, hg.id, fun_left_id]
#align linear_map.fun_left_injective_of_surjective LinearMap.funLeft_injective_of_surjective
-/

end LinearMap

namespace LinearEquiv

open _Root_.LinearMap

#print LinearEquiv.funCongrLeft /-
/-- Given an `R`-module `M` and an equivalence `m ≃ n` between arbitrary types,
construct a linear equivalence `(n → M) ≃ₗ[R] (m → M)` -/
def funCongrLeft (e : m ≃ n) : (n → M) ≃ₗ[R] m → M :=
  LinearEquiv.ofLinear (funLeft R M e) (funLeft R M e.symm)
    (LinearMap.ext fun x =>
      funext fun i => by rw [id_apply, ← fun_left_comp, Equiv.symm_comp_self, fun_left_id])
    (LinearMap.ext fun x =>
      funext fun i => by rw [id_apply, ← fun_left_comp, Equiv.self_comp_symm, fun_left_id])
#align linear_equiv.fun_congr_left LinearEquiv.funCongrLeft
-/

#print LinearEquiv.funCongrLeft_apply /-
@[simp]
theorem funCongrLeft_apply (e : m ≃ n) (x : n → M) : funCongrLeft R M e x = funLeft R M e x :=
  rfl
#align linear_equiv.fun_congr_left_apply LinearEquiv.funCongrLeft_apply
-/

#print LinearEquiv.funCongrLeft_id /-
@[simp]
theorem funCongrLeft_id : funCongrLeft R M (Equiv.refl n) = LinearEquiv.refl R (n → M) :=
  rfl
#align linear_equiv.fun_congr_left_id LinearEquiv.funCongrLeft_id
-/

#print LinearEquiv.funCongrLeft_comp /-
@[simp]
theorem funCongrLeft_comp (e₁ : m ≃ n) (e₂ : n ≃ p) :
    funCongrLeft R M (Equiv.trans e₁ e₂) =
      LinearEquiv.trans (funCongrLeft R M e₂) (funCongrLeft R M e₁) :=
  rfl
#align linear_equiv.fun_congr_left_comp LinearEquiv.funCongrLeft_comp
-/

#print LinearEquiv.funCongrLeft_symm /-
@[simp]
theorem funCongrLeft_symm (e : m ≃ n) : (funCongrLeft R M e).symm = funCongrLeft R M e.symm :=
  rfl
#align linear_equiv.fun_congr_left_symm LinearEquiv.funCongrLeft_symm
-/

end LinearEquiv

end FunLeft

