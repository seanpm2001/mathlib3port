/-
Copyright (c) 2022 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser, Jujian Zhang

! This file was ported from Lean 3 source module algebra.direct_sum.decomposition
! leanprover-community/mathlib commit 33c67ae661dd8988516ff7f247b0be3018cdd952
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.DirectSum.Module
import Mathbin.Algebra.Module.Submodule.Basic

/-!
# Decompositions of additive monoids, groups, and modules into direct sums

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `direct_sum.decomposition ℳ`: A typeclass to provide a constructive decomposition from
  an additive monoid `M` into a family of additive submonoids `ℳ`
* `direct_sum.decompose ℳ`: The canonical equivalence provided by the above typeclass


## Main statements

* `direct_sum.decomposition.is_internal`: The link to `direct_sum.is_internal`.

## Implementation details

As we want to talk about different types of decomposition (additive monoids, modules, rings, ...),
we choose to avoid heavily bundling `direct_sum.decompose`, instead making copies for the
`add_equiv`, `linear_equiv`, etc. This means we have to repeat statements that follow from these
bundled homs, but means we don't have to repeat statements for different types of decomposition.
-/


variable {ι R M σ : Type _}

open scoped DirectSum BigOperators

namespace DirectSum

section AddCommMonoid

variable [DecidableEq ι] [AddCommMonoid M]

variable [SetLike σ M] [AddSubmonoidClass σ M] (ℳ : ι → σ)

#print DirectSum.Decomposition /-
/-- A decomposition is an equivalence between an additive monoid `M` and a direct sum of additive
submonoids `ℳ i` of that `M`, such that the "recomposition" is canonical. This definition also
works for additive groups and modules.

This is a version of `direct_sum.is_internal` which comes with a constructive inverse to the
canonical "recomposition" rather than just a proof that the "recomposition" is bijective. -/
class Decomposition where
  decompose' : M → ⨁ i, ℳ i
  left_inv : Function.LeftInverse (DirectSum.coeAddMonoidHom ℳ) decompose'
  right_inv : Function.RightInverse (DirectSum.coeAddMonoidHom ℳ) decompose'
#align direct_sum.decomposition DirectSum.Decomposition
-/

/-- `direct_sum.decomposition` instances, while carrying data, are always equal. -/
instance : Subsingleton (Decomposition ℳ) :=
  ⟨fun x y => by
    cases' x with x xl xr
    cases' y with y yl yr
    congr
    exact Function.LeftInverse.eq_rightInverse xr yl⟩

variable [Decomposition ℳ]

#print DirectSum.Decomposition.isInternal /-
protected theorem Decomposition.isInternal : DirectSum.IsInternal ℳ :=
  ⟨Decomposition.right_inv.Injective, Decomposition.left_inv.Surjective⟩
#align direct_sum.decomposition.is_internal DirectSum.Decomposition.isInternal
-/

#print DirectSum.decompose /-
/-- If `M` is graded by `ι` with degree `i` component `ℳ i`, then it is isomorphic as
to a direct sum of components. This is the canonical spelling of the `decompose'` field. -/
def decompose : M ≃ ⨁ i, ℳ i where
  toFun := Decomposition.decompose'
  invFun := DirectSum.coeAddMonoidHom ℳ
  left_inv := Decomposition.left_inv
  right_inv := Decomposition.right_inv
#align direct_sum.decompose DirectSum.decompose
-/

#print DirectSum.Decomposition.inductionOn /-
protected theorem Decomposition.inductionOn {p : M → Prop} (h_zero : p 0)
    (h_homogeneous : ∀ {i} (m : ℳ i), p (m : M)) (h_add : ∀ m m' : M, p m → p m' → p (m + m')) :
    ∀ m, p m :=
  by
  let ℳ' : ι → AddSubmonoid M := fun i =>
    (⟨ℳ i, fun _ _ => AddMemClass.add_mem, ZeroMemClass.zero_mem _⟩ : AddSubmonoid M)
  haveI t : DirectSum.Decomposition ℳ' :=
    { decompose' := DirectSum.decompose ℳ
      left_inv := fun _ => (decompose ℳ).left_inv _
      right_inv := fun _ => (decompose ℳ).right_inv _ }
  have mem : ∀ m, m ∈ iSup ℳ' := fun m =>
    (DirectSum.IsInternal.addSubmonoid_iSup_eq_top ℳ' (decomposition.is_internal ℳ')).symm ▸ trivial
  exact fun m =>
    AddSubmonoid.iSup_induction ℳ' (mem m) (fun i m h => h_homogeneous ⟨m, h⟩) h_zero h_add
#align direct_sum.decomposition.induction_on DirectSum.Decomposition.inductionOn
-/

#print DirectSum.Decomposition.decompose'_eq /-
@[simp]
theorem Decomposition.decompose'_eq : Decomposition.decompose' = decompose ℳ :=
  rfl
#align direct_sum.decomposition.decompose'_eq DirectSum.Decomposition.decompose'_eq
-/

#print DirectSum.decompose_symm_of /-
@[simp]
theorem decompose_symm_of {i : ι} (x : ℳ i) : (decompose ℳ).symm (DirectSum.of _ i x) = x :=
  DirectSum.coeAddMonoidHom_of ℳ _ _
#align direct_sum.decompose_symm_of DirectSum.decompose_symm_of
-/

#print DirectSum.decompose_coe /-
@[simp]
theorem decompose_coe {i : ι} (x : ℳ i) : decompose ℳ (x : M) = DirectSum.of _ i x := by
  rw [← decompose_symm_of, Equiv.apply_symm_apply]
#align direct_sum.decompose_coe DirectSum.decompose_coe
-/

#print DirectSum.decompose_of_mem /-
theorem decompose_of_mem {x : M} {i : ι} (hx : x ∈ ℳ i) :
    decompose ℳ x = DirectSum.of (fun i => ℳ i) i ⟨x, hx⟩ :=
  decompose_coe _ ⟨x, hx⟩
#align direct_sum.decompose_of_mem DirectSum.decompose_of_mem
-/

#print DirectSum.decompose_of_mem_same /-
theorem decompose_of_mem_same {x : M} {i : ι} (hx : x ∈ ℳ i) : (decompose ℳ x i : M) = x := by
  rw [decompose_of_mem _ hx, DirectSum.of_eq_same, Subtype.coe_mk]
#align direct_sum.decompose_of_mem_same DirectSum.decompose_of_mem_same
-/

#print DirectSum.decompose_of_mem_ne /-
theorem decompose_of_mem_ne {x : M} {i j : ι} (hx : x ∈ ℳ i) (hij : i ≠ j) :
    (decompose ℳ x j : M) = 0 := by
  rw [decompose_of_mem _ hx, DirectSum.of_eq_of_ne _ _ _ _ hij, ZeroMemClass.coe_zero]
#align direct_sum.decompose_of_mem_ne DirectSum.decompose_of_mem_ne
-/

#print DirectSum.decomposeAddEquiv /-
/-- If `M` is graded by `ι` with degree `i` component `ℳ i`, then it is isomorphic as
an additive monoid to a direct sum of components. -/
@[simps (config := { fullyApplied := false })]
def decomposeAddEquiv : M ≃+ ⨁ i, ℳ i :=
  AddEquiv.symm { (decompose ℳ).symm with map_add' := map_add (DirectSum.coeAddMonoidHom ℳ) }
#align direct_sum.decompose_add_equiv DirectSum.decomposeAddEquiv
-/

#print DirectSum.decompose_zero /-
@[simp]
theorem decompose_zero : decompose ℳ (0 : M) = 0 :=
  map_zero (decomposeAddEquiv ℳ)
#align direct_sum.decompose_zero DirectSum.decompose_zero
-/

#print DirectSum.decompose_symm_zero /-
@[simp]
theorem decompose_symm_zero : (decompose ℳ).symm 0 = (0 : M) :=
  map_zero (decomposeAddEquiv ℳ).symm
#align direct_sum.decompose_symm_zero DirectSum.decompose_symm_zero
-/

#print DirectSum.decompose_add /-
@[simp]
theorem decompose_add (x y : M) : decompose ℳ (x + y) = decompose ℳ x + decompose ℳ y :=
  map_add (decomposeAddEquiv ℳ) x y
#align direct_sum.decompose_add DirectSum.decompose_add
-/

#print DirectSum.decompose_symm_add /-
@[simp]
theorem decompose_symm_add (x y : ⨁ i, ℳ i) :
    (decompose ℳ).symm (x + y) = (decompose ℳ).symm x + (decompose ℳ).symm y :=
  map_add (decomposeAddEquiv ℳ).symm x y
#align direct_sum.decompose_symm_add DirectSum.decompose_symm_add
-/

#print DirectSum.decompose_sum /-
@[simp]
theorem decompose_sum {ι'} (s : Finset ι') (f : ι' → M) :
    decompose ℳ (∑ i in s, f i) = ∑ i in s, decompose ℳ (f i) :=
  map_sum (decomposeAddEquiv ℳ) f s
#align direct_sum.decompose_sum DirectSum.decompose_sum
-/

#print DirectSum.decompose_symm_sum /-
@[simp]
theorem decompose_symm_sum {ι'} (s : Finset ι') (f : ι' → ⨁ i, ℳ i) :
    (decompose ℳ).symm (∑ i in s, f i) = ∑ i in s, (decompose ℳ).symm (f i) :=
  map_sum (decomposeAddEquiv ℳ).symm f s
#align direct_sum.decompose_symm_sum DirectSum.decompose_symm_sum
-/

#print DirectSum.sum_support_decompose /-
theorem sum_support_decompose [∀ (i) (x : ℳ i), Decidable (x ≠ 0)] (r : M) :
    ∑ i in (decompose ℳ r).support, (decompose ℳ r i : M) = r :=
  by
  conv_rhs =>
    rw [← (decompose ℳ).symm_apply_apply r, ← sum_support_of (fun i => ℳ i) (decompose ℳ r)]
  rw [decompose_symm_sum]
  simp_rw [decompose_symm_of]
#align direct_sum.sum_support_decompose DirectSum.sum_support_decompose
-/

end AddCommMonoid

#print DirectSum.addCommGroupSetLike /-
/-- The `-` in the statements below doesn't resolve without this line.

This seems to a be a problem of synthesized vs inferred typeclasses disagreeing. If we replace
the statement of `decompose_neg` with `@eq (⨁ i, ℳ i) (decompose ℳ (-x)) (-decompose ℳ x)`
instead of `decompose ℳ (-x) = -decompose ℳ x`, which forces the typeclasses needed by `⨁ i, ℳ i` to
be found by unification rather than synthesis, then everything works fine without this instance. -/
instance addCommGroupSetLike [AddCommGroup M] [SetLike σ M] [AddSubgroupClass σ M] (ℳ : ι → σ) :
    AddCommGroup (⨁ i, ℳ i) := by infer_instance
#align direct_sum.add_comm_group_set_like DirectSum.addCommGroupSetLike
-/

section AddCommGroup

variable [DecidableEq ι] [AddCommGroup M]

variable [SetLike σ M] [AddSubgroupClass σ M] (ℳ : ι → σ)

variable [Decomposition ℳ]

#print DirectSum.decompose_neg /-
@[simp]
theorem decompose_neg (x : M) : decompose ℳ (-x) = -decompose ℳ x :=
  map_neg (decomposeAddEquiv ℳ) x
#align direct_sum.decompose_neg DirectSum.decompose_neg
-/

#print DirectSum.decompose_symm_neg /-
@[simp]
theorem decompose_symm_neg (x : ⨁ i, ℳ i) : (decompose ℳ).symm (-x) = -(decompose ℳ).symm x :=
  map_neg (decomposeAddEquiv ℳ).symm x
#align direct_sum.decompose_symm_neg DirectSum.decompose_symm_neg
-/

#print DirectSum.decompose_sub /-
@[simp]
theorem decompose_sub (x y : M) : decompose ℳ (x - y) = decompose ℳ x - decompose ℳ y :=
  map_sub (decomposeAddEquiv ℳ) x y
#align direct_sum.decompose_sub DirectSum.decompose_sub
-/

#print DirectSum.decompose_symm_sub /-
@[simp]
theorem decompose_symm_sub (x y : ⨁ i, ℳ i) :
    (decompose ℳ).symm (x - y) = (decompose ℳ).symm x - (decompose ℳ).symm y :=
  map_sub (decomposeAddEquiv ℳ).symm x y
#align direct_sum.decompose_symm_sub DirectSum.decompose_symm_sub
-/

end AddCommGroup

section Module

variable [DecidableEq ι] [Semiring R] [AddCommMonoid M] [Module R M]

variable (ℳ : ι → Submodule R M)

variable [Decomposition ℳ]

#print DirectSum.decomposeLinearEquiv /-
/-- If `M` is graded by `ι` with degree `i` component `ℳ i`, then it is isomorphic as
a module to a direct sum of components. -/
@[simps (config := { fullyApplied := false })]
def decomposeLinearEquiv : M ≃ₗ[R] ⨁ i, ℳ i :=
  LinearEquiv.symm
    { (decomposeAddEquiv ℳ).symm with map_smul' := map_smul (DirectSum.coeLinearMap ℳ) }
#align direct_sum.decompose_linear_equiv DirectSum.decomposeLinearEquiv
-/

#print DirectSum.decompose_smul /-
@[simp]
theorem decompose_smul (r : R) (x : M) : decompose ℳ (r • x) = r • decompose ℳ x :=
  map_smul (decomposeLinearEquiv ℳ) r x
#align direct_sum.decompose_smul DirectSum.decompose_smul
-/

end Module

end DirectSum

