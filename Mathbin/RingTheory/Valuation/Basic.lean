/-
Copyright (c) 2020 Johan Commelin. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard, Johan Commelin, Patrick Massot

! This file was ported from Lean 3 source module ring_theory.valuation.basic
! leanprover-community/mathlib commit 932872382355f00112641d305ba0619305dc8642
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.WithZero
import Mathbin.RingTheory.Ideal.Operations

/-!

# The basics of valuation theory.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The basic theory of valuations (non-archimedean norms) on a commutative ring,
following T. Wedhorn's unpublished notes “Adic Spaces” ([wedhorn_adic]).

The definition of a valuation we use here is Definition 1.22 of [wedhorn_adic].
A valuation on a ring `R` is a monoid homomorphism `v` to a linearly ordered
commutative monoid with zero, that in addition satisfies the following two axioms:
 * `v 0 = 0`
 * `∀ x y, v (x + y) ≤ max (v x) (v y)`

`valuation R Γ₀`is the type of valuations `R → Γ₀`, with a coercion to the underlying
function. If `v` is a valuation from `R` to `Γ₀` then the induced group
homomorphism `units(R) → Γ₀` is called `unit_map v`.

The equivalence "relation" `is_equiv v₁ v₂ : Prop` defined in 1.27 of [wedhorn_adic] is not strictly
speaking a relation, because `v₁ : valuation R Γ₁` and `v₂ : valuation R Γ₂` might
not have the same type. This corresponds in ZFC to the set-theoretic difficulty
that the class of all valuations (as `Γ₀` varies) on a ring `R` is not a set.
The "relation" is however reflexive, symmetric and transitive in the obvious
sense. Note that we use 1.27(iii) of [wedhorn_adic] as the definition of equivalence.

## Main definitions

* `valuation R Γ₀`, the type of valuations on `R` with values in `Γ₀`
* `valuation.is_equiv`, the heterogeneous equivalence relation on valuations
* `valuation.supp`, the support of a valuation

* `add_valuation R Γ₀`, the type of additive valuations on `R` with values in a
  linearly ordered additive commutative group with a top element, `Γ₀`.

## Implementation Details

`add_valuation R Γ₀` is implemented as `valuation R (multiplicative Γ₀)ᵒᵈ`.

## Notation

In the `discrete_valuation` locale:

 * `ℕₘ₀` is a shorthand for `with_zero (multiplicative ℕ)`
 * `ℤₘ₀` is a shorthand for `with_zero (multiplicative ℤ)`

## TODO

If ever someone extends `valuation`, we should fully comply to the `fun_like` by migrating the
boilerplate lemmas to `valuation_class`.
-/


open scoped Classical BigOperators

noncomputable section

open Function Ideal

variable {K F R : Type _} [DivisionRing K]

section

variable (F R) (Γ₀ : Type _) [LinearOrderedCommMonoidWithZero Γ₀] [Ring R]

#print Valuation /-
/-- The type of `Γ₀`-valued valuations on `R`.

When you extend this structure, make sure to extend `valuation_class`. -/
@[nolint has_nonempty_instance]
structure Valuation extends R →*₀ Γ₀ where
  map_add_le_max' : ∀ x y, to_fun (x + y) ≤ max (to_fun x) (to_fun y)
#align valuation Valuation
-/

#print ValuationClass /-
/-- `valuation_class F α β` states that `F` is a type of valuations.

You should also extend this typeclass when you extend `valuation`. -/
class ValuationClass extends MonoidWithZeroHomClass F R Γ₀ where
  map_add_le_max (f : F) (x y : R) : f (x + y) ≤ max (f x) (f y)
#align valuation_class ValuationClass
-/

export ValuationClass (map_add_le_max)

instance [ValuationClass F R Γ₀] : CoeTC F (Valuation R Γ₀) :=
  ⟨fun f =>
    { toFun := f
      map_one' := map_one f
      map_zero' := map_zero f
      map_mul' := map_mul f
      map_add_le_max' := map_add_le_max f }⟩

end

namespace Valuation

variable {Γ₀ : Type _}

variable {Γ'₀ : Type _}

variable {Γ''₀ : Type _} [LinearOrderedCommMonoidWithZero Γ''₀]

section Basic

variable [Ring R]

section Monoid

variable [LinearOrderedCommMonoidWithZero Γ₀] [LinearOrderedCommMonoidWithZero Γ'₀]

instance : ValuationClass (Valuation R Γ₀) R Γ₀
    where
  coe f := f.toFun
  coe_injective' f g h := by obtain ⟨⟨_, _⟩, _⟩ := f; obtain ⟨⟨_, _⟩, _⟩ := g; congr
  map_mul f := f.map_mul'
  map_one f := f.map_one'
  map_zero f := f.map_zero'
  map_add_le_max f := f.map_add_le_max'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (Valuation R Γ₀) fun _ => R → Γ₀ :=
  FunLike.hasCoeToFun

#print Valuation.toFun_eq_coe /-
@[simp]
theorem toFun_eq_coe (v : Valuation R Γ₀) : v.toFun = v :=
  rfl
#align valuation.to_fun_eq_coe Valuation.toFun_eq_coe
-/

#print Valuation.ext /-
@[ext]
theorem ext {v₁ v₂ : Valuation R Γ₀} (h : ∀ r, v₁ r = v₂ r) : v₁ = v₂ :=
  FunLike.ext _ _ h
#align valuation.ext Valuation.ext
-/

variable (v : Valuation R Γ₀) {x y z : R}

#print Valuation.coe_coe /-
@[simp, norm_cast]
theorem coe_coe : ⇑(v : R →*₀ Γ₀) = v :=
  rfl
#align valuation.coe_coe Valuation.coe_coe
-/

#print Valuation.map_zero /-
@[simp]
theorem map_zero : v 0 = 0 :=
  v.map_zero'
#align valuation.map_zero Valuation.map_zero
-/

#print Valuation.map_one /-
@[simp]
theorem map_one : v 1 = 1 :=
  v.map_one'
#align valuation.map_one Valuation.map_one
-/

#print Valuation.map_mul /-
@[simp]
theorem map_mul : ∀ x y, v (x * y) = v x * v y :=
  v.map_mul'
#align valuation.map_mul Valuation.map_mul
-/

#print Valuation.map_add /-
@[simp]
theorem map_add : ∀ x y, v (x + y) ≤ max (v x) (v y) :=
  v.map_add_le_max'
#align valuation.map_add Valuation.map_add
-/

#print Valuation.map_add_le /-
theorem map_add_le {x y g} (hx : v x ≤ g) (hy : v y ≤ g) : v (x + y) ≤ g :=
  le_trans (v.map_add x y) <| max_le hx hy
#align valuation.map_add_le Valuation.map_add_le
-/

#print Valuation.map_add_lt /-
theorem map_add_lt {x y g} (hx : v x < g) (hy : v y < g) : v (x + y) < g :=
  lt_of_le_of_lt (v.map_add x y) <| max_lt hx hy
#align valuation.map_add_lt Valuation.map_add_lt
-/

#print Valuation.map_sum_le /-
theorem map_sum_le {ι : Type _} {s : Finset ι} {f : ι → R} {g : Γ₀} (hf : ∀ i ∈ s, v (f i) ≤ g) :
    v (∑ i in s, f i) ≤ g :=
  by
  refine'
    Finset.induction_on s (fun _ => trans_rel_right (· ≤ ·) v.map_zero zero_le')
      (fun a s has ih hf => _) hf
  rw [Finset.forall_mem_insert] at hf ; rw [Finset.sum_insert has]
  exact v.map_add_le hf.1 (ih hf.2)
#align valuation.map_sum_le Valuation.map_sum_le
-/

#print Valuation.map_sum_lt /-
theorem map_sum_lt {ι : Type _} {s : Finset ι} {f : ι → R} {g : Γ₀} (hg : g ≠ 0)
    (hf : ∀ i ∈ s, v (f i) < g) : v (∑ i in s, f i) < g :=
  by
  refine'
    Finset.induction_on s (fun _ => trans_rel_right (· < ·) v.map_zero (zero_lt_iff.2 hg))
      (fun a s has ih hf => _) hf
  rw [Finset.forall_mem_insert] at hf ; rw [Finset.sum_insert has]
  exact v.map_add_lt hf.1 (ih hf.2)
#align valuation.map_sum_lt Valuation.map_sum_lt
-/

#print Valuation.map_sum_lt' /-
theorem map_sum_lt' {ι : Type _} {s : Finset ι} {f : ι → R} {g : Γ₀} (hg : 0 < g)
    (hf : ∀ i ∈ s, v (f i) < g) : v (∑ i in s, f i) < g :=
  v.map_sum_lt (ne_of_gt hg) hf
#align valuation.map_sum_lt' Valuation.map_sum_lt'
-/

#print Valuation.map_pow /-
@[simp]
theorem map_pow : ∀ (x) (n : ℕ), v (x ^ n) = v x ^ n :=
  v.toMonoidWithZeroHom.toMonoidHom.map_pow
#align valuation.map_pow Valuation.map_pow
-/

#print Valuation.ext_iff /-
/-- Deprecated. Use `fun_like.ext_iff`. -/
theorem ext_iff {v₁ v₂ : Valuation R Γ₀} : v₁ = v₂ ↔ ∀ r, v₁ r = v₂ r :=
  FunLike.ext_iff
#align valuation.ext_iff Valuation.ext_iff
-/

#print Valuation.toPreorder /-
-- The following definition is not an instance, because we have more than one `v` on a given `R`.
-- In addition, type class inference would not be able to infer `v`.
/-- A valuation gives a preorder on the underlying ring. -/
def toPreorder : Preorder R :=
  Preorder.lift v
#align valuation.to_preorder Valuation.toPreorder
-/

#print Valuation.zero_iff /-
/-- If `v` is a valuation on a division ring then `v(x) = 0` iff `x = 0`. -/
@[simp]
theorem zero_iff [Nontrivial Γ₀] (v : Valuation K Γ₀) {x : K} : v x = 0 ↔ x = 0 :=
  map_eq_zero v
#align valuation.zero_iff Valuation.zero_iff
-/

#print Valuation.ne_zero_iff /-
theorem ne_zero_iff [Nontrivial Γ₀] (v : Valuation K Γ₀) {x : K} : v x ≠ 0 ↔ x ≠ 0 :=
  map_ne_zero v
#align valuation.ne_zero_iff Valuation.ne_zero_iff
-/

#print Valuation.unit_map_eq /-
theorem unit_map_eq (u : Rˣ) : (Units.map (v : R →* Γ₀) u : Γ₀) = v u :=
  rfl
#align valuation.unit_map_eq Valuation.unit_map_eq
-/

#print Valuation.comap /-
/-- A ring homomorphism `S → R` induces a map `valuation R Γ₀ → valuation S Γ₀`. -/
def comap {S : Type _} [Ring S] (f : S →+* R) (v : Valuation R Γ₀) : Valuation S Γ₀ :=
  {
    v.toMonoidWithZeroHom.comp
      f.toMonoidWithZeroHom with
    toFun := v ∘ f
    map_add_le_max' := fun x y => by simp only [comp_app, map_add, f.map_add] }
#align valuation.comap Valuation.comap
-/

#print Valuation.comap_apply /-
@[simp]
theorem comap_apply {S : Type _} [Ring S] (f : S →+* R) (v : Valuation R Γ₀) (s : S) :
    v.comap f s = v (f s) :=
  rfl
#align valuation.comap_apply Valuation.comap_apply
-/

#print Valuation.comap_id /-
@[simp]
theorem comap_id : v.comap (RingHom.id R) = v :=
  ext fun r => rfl
#align valuation.comap_id Valuation.comap_id
-/

#print Valuation.comap_comp /-
theorem comap_comp {S₁ : Type _} {S₂ : Type _} [Ring S₁] [Ring S₂] (f : S₁ →+* S₂) (g : S₂ →+* R) :
    v.comap (g.comp f) = (v.comap g).comap f :=
  ext fun r => rfl
#align valuation.comap_comp Valuation.comap_comp
-/

#print Valuation.map /-
/-- A `≤`-preserving group homomorphism `Γ₀ → Γ'₀` induces a map `valuation R Γ₀ → valuation R Γ'₀`.
-/
def map (f : Γ₀ →*₀ Γ'₀) (hf : Monotone f) (v : Valuation R Γ₀) : Valuation R Γ'₀ :=
  {
    MonoidWithZeroHom.comp f v.toMonoidWithZeroHom with
    toFun := f ∘ v
    map_add_le_max' := fun r s =>
      calc
        f (v (r + s)) ≤ f (max (v r) (v s)) := hf (v.map_add r s)
        _ = max (f (v r)) (f (v s)) := hf.map_max }
#align valuation.map Valuation.map
-/

#print Valuation.IsEquiv /-
/-- Two valuations on `R` are defined to be equivalent if they induce the same preorder on `R`. -/
def IsEquiv (v₁ : Valuation R Γ₀) (v₂ : Valuation R Γ'₀) : Prop :=
  ∀ r s, v₁ r ≤ v₁ s ↔ v₂ r ≤ v₂ s
#align valuation.is_equiv Valuation.IsEquiv
-/

end Monoid

section Group

variable [LinearOrderedCommGroupWithZero Γ₀] {R} {Γ₀} (v : Valuation R Γ₀) {x y z : R}

#print Valuation.map_neg /-
@[simp]
theorem map_neg (x : R) : v (-x) = v x :=
  v.toMonoidWithZeroHom.toMonoidHom.map_neg x
#align valuation.map_neg Valuation.map_neg
-/

#print Valuation.map_sub_swap /-
theorem map_sub_swap (x y : R) : v (x - y) = v (y - x) :=
  v.toMonoidWithZeroHom.toMonoidHom.map_sub_swap x y
#align valuation.map_sub_swap Valuation.map_sub_swap
-/

#print Valuation.map_sub /-
theorem map_sub (x y : R) : v (x - y) ≤ max (v x) (v y) :=
  calc
    v (x - y) = v (x + -y) := by rw [sub_eq_add_neg]
    _ ≤ max (v x) (v <| -y) := (v.map_add _ _)
    _ = max (v x) (v y) := by rw [map_neg]
#align valuation.map_sub Valuation.map_sub
-/

#print Valuation.map_sub_le /-
theorem map_sub_le {x y g} (hx : v x ≤ g) (hy : v y ≤ g) : v (x - y) ≤ g :=
  by
  rw [sub_eq_add_neg]
  exact v.map_add_le hx (le_trans (le_of_eq (v.map_neg y)) hy)
#align valuation.map_sub_le Valuation.map_sub_le
-/

#print Valuation.map_add_of_distinct_val /-
theorem map_add_of_distinct_val (h : v x ≠ v y) : v (x + y) = max (v x) (v y) :=
  by
  suffices : ¬v (x + y) < max (v x) (v y)
  exact or_iff_not_imp_right.1 (le_iff_eq_or_lt.1 (v.map_add x y)) this
  intro h'
  wlog vyx : v y < v x
  · refine' this v h.symm _ (h.lt_or_lt.resolve_right vyx); rwa [add_comm, max_comm]
  rw [max_eq_left_of_lt vyx] at h' 
  apply lt_irrefl (v x)
  calc
    v x = v (x + y - y) := by simp
    _ ≤ max (v <| x + y) (v y) := (map_sub _ _ _)
    _ < v x := max_lt h' vyx
#align valuation.map_add_of_distinct_val Valuation.map_add_of_distinct_val
-/

#print Valuation.map_add_eq_of_lt_right /-
theorem map_add_eq_of_lt_right (h : v x < v y) : v (x + y) = v y :=
  by
  convert v.map_add_of_distinct_val _
  · symm; rw [max_eq_right_iff]; exact le_of_lt h
  · exact ne_of_lt h
#align valuation.map_add_eq_of_lt_right Valuation.map_add_eq_of_lt_right
-/

#print Valuation.map_add_eq_of_lt_left /-
theorem map_add_eq_of_lt_left (h : v y < v x) : v (x + y) = v x := by rw [add_comm];
  exact map_add_eq_of_lt_right _ h
#align valuation.map_add_eq_of_lt_left Valuation.map_add_eq_of_lt_left
-/

#print Valuation.map_eq_of_sub_lt /-
theorem map_eq_of_sub_lt (h : v (y - x) < v x) : v y = v x :=
  by
  have := Valuation.map_add_of_distinct_val v (ne_of_gt h).symm
  rw [max_eq_right (le_of_lt h)] at this 
  simpa using this
#align valuation.map_eq_of_sub_lt Valuation.map_eq_of_sub_lt
-/

#print Valuation.map_one_add_of_lt /-
theorem map_one_add_of_lt (h : v x < 1) : v (1 + x) = 1 :=
  by
  rw [← v.map_one] at h 
  simpa only [v.map_one] using v.map_add_eq_of_lt_left h
#align valuation.map_one_add_of_lt Valuation.map_one_add_of_lt
-/

#print Valuation.map_one_sub_of_lt /-
theorem map_one_sub_of_lt (h : v x < 1) : v (1 - x) = 1 :=
  by
  rw [← v.map_one, ← v.map_neg] at h 
  rw [sub_eq_add_neg 1 x]
  simpa only [v.map_one, v.map_neg] using v.map_add_eq_of_lt_left h
#align valuation.map_one_sub_of_lt Valuation.map_one_sub_of_lt
-/

#print Valuation.one_lt_val_iff /-
theorem one_lt_val_iff (v : Valuation K Γ₀) {x : K} (h : x ≠ 0) : 1 < v x ↔ v x⁻¹ < 1 := by
  simpa using (inv_lt_inv₀ (v.ne_zero_iff.2 h) one_ne_zero).symm
#align valuation.one_lt_val_iff Valuation.one_lt_val_iff
-/

#print Valuation.ltAddSubgroup /-
/-- The subgroup of elements whose valuation is less than a certain unit.-/
def ltAddSubgroup (v : Valuation R Γ₀) (γ : Γ₀ˣ) : AddSubgroup R
    where
  carrier := {x | v x < γ}
  zero_mem' := by have h := Units.ne_zero γ; contrapose! h; simpa using h
  add_mem' x y x_in y_in := lt_of_le_of_lt (v.map_add x y) (max_lt x_in y_in)
  neg_mem' x x_in := by rwa [Set.mem_setOf_eq, map_neg]
#align valuation.lt_add_subgroup Valuation.ltAddSubgroup
-/

end Group

end Basic

-- end of section
namespace IsEquiv

variable [Ring R]

variable [LinearOrderedCommMonoidWithZero Γ₀] [LinearOrderedCommMonoidWithZero Γ'₀]

variable {v : Valuation R Γ₀}

variable {v₁ : Valuation R Γ₀} {v₂ : Valuation R Γ'₀} {v₃ : Valuation R Γ''₀}

#print Valuation.IsEquiv.refl /-
@[refl]
theorem refl : v.IsEquiv v := fun _ _ => Iff.refl _
#align valuation.is_equiv.refl Valuation.IsEquiv.refl
-/

#print Valuation.IsEquiv.symm /-
@[symm]
theorem symm (h : v₁.IsEquiv v₂) : v₂.IsEquiv v₁ := fun _ _ => Iff.symm (h _ _)
#align valuation.is_equiv.symm Valuation.IsEquiv.symm
-/

#print Valuation.IsEquiv.trans /-
@[trans]
theorem trans (h₁₂ : v₁.IsEquiv v₂) (h₂₃ : v₂.IsEquiv v₃) : v₁.IsEquiv v₃ := fun _ _ =>
  Iff.trans (h₁₂ _ _) (h₂₃ _ _)
#align valuation.is_equiv.trans Valuation.IsEquiv.trans
-/

#print Valuation.IsEquiv.of_eq /-
theorem of_eq {v' : Valuation R Γ₀} (h : v = v') : v.IsEquiv v' := by subst h
#align valuation.is_equiv.of_eq Valuation.IsEquiv.of_eq
-/

#print Valuation.IsEquiv.map /-
theorem map {v' : Valuation R Γ₀} (f : Γ₀ →*₀ Γ'₀) (hf : Monotone f) (inf : Injective f)
    (h : v.IsEquiv v') : (v.map f hf).IsEquiv (v'.map f hf) :=
  let H : StrictMono f := hf.strictMono_of_injective inf
  fun r s =>
  calc
    f (v r) ≤ f (v s) ↔ v r ≤ v s := by rw [H.le_iff_le]
    _ ↔ v' r ≤ v' s := (h r s)
    _ ↔ f (v' r) ≤ f (v' s) := by rw [H.le_iff_le]
#align valuation.is_equiv.map Valuation.IsEquiv.map
-/

#print Valuation.IsEquiv.comap /-
/-- `comap` preserves equivalence. -/
theorem comap {S : Type _} [Ring S] (f : S →+* R) (h : v₁.IsEquiv v₂) :
    (v₁.comap f).IsEquiv (v₂.comap f) := fun r s => h (f r) (f s)
#align valuation.is_equiv.comap Valuation.IsEquiv.comap
-/

#print Valuation.IsEquiv.val_eq /-
theorem val_eq (h : v₁.IsEquiv v₂) {r s : R} : v₁ r = v₁ s ↔ v₂ r = v₂ s := by
  simpa only [le_antisymm_iff] using and_congr (h r s) (h s r)
#align valuation.is_equiv.val_eq Valuation.IsEquiv.val_eq
-/

#print Valuation.IsEquiv.ne_zero /-
theorem ne_zero (h : v₁.IsEquiv v₂) {r : R} : v₁ r ≠ 0 ↔ v₂ r ≠ 0 :=
  by
  have : v₁ r ≠ v₁ 0 ↔ v₂ r ≠ v₂ 0 := not_congr h.val_eq
  rwa [v₁.map_zero, v₂.map_zero] at this 
#align valuation.is_equiv.ne_zero Valuation.IsEquiv.ne_zero
-/

end IsEquiv

-- end of namespace
section

#print Valuation.isEquiv_of_map_strictMono /-
theorem isEquiv_of_map_strictMono [LinearOrderedCommMonoidWithZero Γ₀]
    [LinearOrderedCommMonoidWithZero Γ'₀] [Ring R] {v : Valuation R Γ₀} (f : Γ₀ →*₀ Γ'₀)
    (H : StrictMono f) : IsEquiv (v.map f H.Monotone) v := fun x y =>
  ⟨H.le_iff_le.mp, fun h => H.Monotone h⟩
#align valuation.is_equiv_of_map_strict_mono Valuation.isEquiv_of_map_strictMono
-/

#print Valuation.isEquiv_of_val_le_one /-
theorem isEquiv_of_val_le_one [LinearOrderedCommGroupWithZero Γ₀]
    [LinearOrderedCommGroupWithZero Γ'₀] (v : Valuation K Γ₀) (v' : Valuation K Γ'₀)
    (h : ∀ {x : K}, v x ≤ 1 ↔ v' x ≤ 1) : v.IsEquiv v' :=
  by
  intro x y
  by_cases hy : y = 0; · simp [hy, zero_iff]
  rw [show y = 1 * y by rw [one_mul]]
  rw [← inv_mul_cancel_right₀ hy x]
  iterate 2 rw [v.map_mul _ y, v'.map_mul _ y]
  rw [v.map_one, v'.map_one]
  constructor <;> intro H
  · apply mul_le_mul_right'
    replace hy := v.ne_zero_iff.mpr hy
    replace H := le_of_le_mul_right hy H
    rwa [h] at H 
  · apply mul_le_mul_right'
    replace hy := v'.ne_zero_iff.mpr hy
    replace H := le_of_le_mul_right hy H
    rwa [h]
#align valuation.is_equiv_of_val_le_one Valuation.isEquiv_of_val_le_one
-/

#print Valuation.isEquiv_iff_val_le_one /-
theorem isEquiv_iff_val_le_one [LinearOrderedCommGroupWithZero Γ₀]
    [LinearOrderedCommGroupWithZero Γ'₀] (v : Valuation K Γ₀) (v' : Valuation K Γ'₀) :
    v.IsEquiv v' ↔ ∀ {x : K}, v x ≤ 1 ↔ v' x ≤ 1 :=
  ⟨fun h x => by simpa using h x 1, isEquiv_of_val_le_one _ _⟩
#align valuation.is_equiv_iff_val_le_one Valuation.isEquiv_iff_val_le_one
-/

#print Valuation.isEquiv_iff_val_eq_one /-
theorem isEquiv_iff_val_eq_one [LinearOrderedCommGroupWithZero Γ₀]
    [LinearOrderedCommGroupWithZero Γ'₀] (v : Valuation K Γ₀) (v' : Valuation K Γ'₀) :
    v.IsEquiv v' ↔ ∀ {x : K}, v x = 1 ↔ v' x = 1 :=
  by
  constructor
  · intro h x
    simpa using @is_equiv.val_eq _ _ _ _ _ _ v v' h x 1
  · intro h; apply is_equiv_of_val_le_one; intro x
    constructor
    · intro hx
      cases' lt_or_eq_of_le hx with hx' hx'
      · have : v (1 + x) = 1 := by rw [← v.map_one]; apply map_add_eq_of_lt_left; simpa
        rw [h] at this 
        rw [show x = -1 + (1 + x) by simp]
        refine' le_trans (v'.map_add _ _) _
        simp [this]
      · rw [h] at hx' ; exact le_of_eq hx'
    · intro hx
      cases' lt_or_eq_of_le hx with hx' hx'
      · have : v' (1 + x) = 1 := by rw [← v'.map_one]; apply map_add_eq_of_lt_left; simpa
        rw [← h] at this 
        rw [show x = -1 + (1 + x) by simp]
        refine' le_trans (v.map_add _ _) _
        simp [this]
      · rw [← h] at hx' ; exact le_of_eq hx'
#align valuation.is_equiv_iff_val_eq_one Valuation.isEquiv_iff_val_eq_one
-/

#print Valuation.isEquiv_iff_val_lt_one /-
theorem isEquiv_iff_val_lt_one [LinearOrderedCommGroupWithZero Γ₀]
    [LinearOrderedCommGroupWithZero Γ'₀] (v : Valuation K Γ₀) (v' : Valuation K Γ'₀) :
    v.IsEquiv v' ↔ ∀ {x : K}, v x < 1 ↔ v' x < 1 :=
  by
  constructor
  · intro h x
    simp only [lt_iff_le_and_ne,
      and_congr ((is_equiv_iff_val_le_one _ _).1 h) ((is_equiv_iff_val_eq_one _ _).1 h).Not]
  · rw [is_equiv_iff_val_eq_one]
    intro h x
    by_cases hx : x = 0; · simp only [(zero_iff _).2 hx, zero_ne_one]
    constructor
    · intro hh
      by_contra h_1
      cases ne_iff_lt_or_gt.1 h_1
      · simpa [hh, lt_self_iff_false] using h.2 h_2
      · rw [← inv_one, ← inv_eq_iff_eq_inv, ← map_inv₀] at hh 
        exact hh.not_lt (h.2 ((one_lt_val_iff v' hx).1 h_2))
    · intro hh
      by_contra h_1
      cases ne_iff_lt_or_gt.1 h_1
      · simpa [hh, lt_self_iff_false] using h.1 h_2
      · rw [← inv_one, ← inv_eq_iff_eq_inv, ← map_inv₀] at hh 
        exact hh.not_lt (h.1 ((one_lt_val_iff v hx).1 h_2))
#align valuation.is_equiv_iff_val_lt_one Valuation.isEquiv_iff_val_lt_one
-/

#print Valuation.isEquiv_iff_val_sub_one_lt_one /-
theorem isEquiv_iff_val_sub_one_lt_one [LinearOrderedCommGroupWithZero Γ₀]
    [LinearOrderedCommGroupWithZero Γ'₀] (v : Valuation K Γ₀) (v' : Valuation K Γ'₀) :
    v.IsEquiv v' ↔ ∀ {x : K}, v (x - 1) < 1 ↔ v' (x - 1) < 1 :=
  by
  rw [is_equiv_iff_val_lt_one]
  exact (Equiv.subRight 1).Surjective.forall
#align valuation.is_equiv_iff_val_sub_one_lt_one Valuation.isEquiv_iff_val_sub_one_lt_one
-/

#print Valuation.isEquiv_tfae /-
theorem isEquiv_tfae [LinearOrderedCommGroupWithZero Γ₀] [LinearOrderedCommGroupWithZero Γ'₀]
    (v : Valuation K Γ₀) (v' : Valuation K Γ'₀) :
    [v.IsEquiv v', ∀ {x}, v x ≤ 1 ↔ v' x ≤ 1, ∀ {x}, v x = 1 ↔ v' x = 1, ∀ {x}, v x < 1 ↔ v' x < 1,
        ∀ {x}, v (x - 1) < 1 ↔ v' (x - 1) < 1].TFAE :=
  by
  tfae_have 1 ↔ 2; · apply is_equiv_iff_val_le_one
  tfae_have 1 ↔ 3; · apply is_equiv_iff_val_eq_one
  tfae_have 1 ↔ 4; · apply is_equiv_iff_val_lt_one
  tfae_have 1 ↔ 5; · apply is_equiv_iff_val_sub_one_lt_one
  tfae_finish
#align valuation.is_equiv_tfae Valuation.isEquiv_tfae
-/

end

section Supp

variable [CommRing R]

variable [LinearOrderedCommMonoidWithZero Γ₀] [LinearOrderedCommMonoidWithZero Γ'₀]

variable (v : Valuation R Γ₀)

#print Valuation.supp /-
/-- The support of a valuation `v : R → Γ₀` is the ideal of `R` where `v` vanishes. -/
def supp : Ideal R where
  carrier := {x | v x = 0}
  zero_mem' := map_zero v
  add_mem' x y hx hy :=
    le_zero_iff.mp <|
      calc
        v (x + y) ≤ max (v x) (v y) := v.map_add x y
        _ ≤ 0 := max_le (le_zero_iff.mpr hx) (le_zero_iff.mpr hy)
  smul_mem' c x hx :=
    calc
      v (c * x) = v c * v x := map_mul v c x
      _ = v c * 0 := (congr_arg _ hx)
      _ = 0 := MulZeroClass.mul_zero _
#align valuation.supp Valuation.supp
-/

#print Valuation.mem_supp_iff /-
@[simp]
theorem mem_supp_iff (x : R) : x ∈ supp v ↔ v x = 0 :=
  Iff.rfl
#align valuation.mem_supp_iff Valuation.mem_supp_iff
-/

-- @[simp] lemma mem_supp_iff' (x : R) : x ∈ (supp v : set R) ↔ v x = 0 := iff.rfl
/-- The support of a valuation is a prime ideal. -/
instance [Nontrivial Γ₀] [NoZeroDivisors Γ₀] : Ideal.IsPrime (supp v) :=
  ⟨fun h : v.supp = ⊤ =>
    one_ne_zero <|
      show (1 : Γ₀) = 0 from
        calc
          1 = v 1 := v.map_one.symm
          _ = 0 := show (1 : R) ∈ supp v by rw [h]; trivial,
    fun x y hxy => by
    show v x = 0 ∨ v y = 0
    change v (x * y) = 0 at hxy 
    rw [v.map_mul x y] at hxy 
    exact eq_zero_or_eq_zero_of_mul_eq_zero hxy⟩

#print Valuation.map_add_supp /-
theorem map_add_supp (a : R) {s : R} (h : s ∈ supp v) : v (a + s) = v a :=
  by
  have aux : ∀ a s, v s = 0 → v (a + s) ≤ v a := by intro a' s' h';
    refine' le_trans (v.map_add a' s') (max_le le_rfl _); simp [h']
  apply le_antisymm (aux a s h)
  calc
    v a = v (a + s + -s) := by simp
    _ ≤ v (a + s) := aux (a + s) (-s) (by rwa [← Ideal.neg_mem_iff] at h )
#align valuation.map_add_supp Valuation.map_add_supp
-/

#print Valuation.comap_supp /-
theorem comap_supp {S : Type _} [CommRing S] (f : S →+* R) :
    supp (v.comap f) = Ideal.comap f v.supp :=
  Ideal.ext fun x => by
    rw [mem_supp_iff, Ideal.mem_comap, mem_supp_iff]
    rfl
#align valuation.comap_supp Valuation.comap_supp
-/

end Supp

-- end of section
end Valuation

section AddMonoid

variable (R) [Ring R] (Γ₀ : Type _) [LinearOrderedAddCommMonoidWithTop Γ₀]

#print AddValuation /-
/-- The type of `Γ₀`-valued additive valuations on `R`. -/
@[nolint has_nonempty_instance]
def AddValuation :=
  Valuation R (Multiplicative Γ₀ᵒᵈ)
#align add_valuation AddValuation
-/

end AddMonoid

namespace AddValuation

variable {Γ₀ : Type _} {Γ'₀ : Type _}

section Basic

section Monoid

variable [LinearOrderedAddCommMonoidWithTop Γ₀] [LinearOrderedAddCommMonoidWithTop Γ'₀]

variable (R) (Γ₀) [Ring R]

/-- A valuation is coerced to the underlying function `R → Γ₀`. -/
instance : CoeFun (AddValuation R Γ₀) fun _ => R → Γ₀ where coe v := v.toMonoidWithZeroHom.toFun

variable {R} {Γ₀} (v : AddValuation R Γ₀) {x y z : R}

section

variable (f : R → Γ₀) (h0 : f 0 = ⊤) (h1 : f 1 = 0)

variable (hadd : ∀ x y, min (f x) (f y) ≤ f (x + y)) (hmul : ∀ x y, f (x * y) = f x + f y)

#print AddValuation.of /-
/-- An alternate constructor of `add_valuation`, that doesn't reference `multiplicative Γ₀ᵒᵈ` -/
def of : AddValuation R Γ₀ where
  toFun := f
  map_one' := h1
  map_zero' := h0
  map_add_le_max' := hadd
  map_mul' := hmul
#align add_valuation.of AddValuation.of
-/

variable {h0} {h1} {hadd} {hmul} {r : R}

#print AddValuation.of_apply /-
@[simp]
theorem of_apply : (of f h0 h1 hadd hmul) r = f r :=
  rfl
#align add_valuation.of_apply AddValuation.of_apply
-/

#print AddValuation.valuation /-
/-- The `valuation` associated to an `add_valuation` (useful if the latter is constructed using
`add_valuation.of`). -/
def valuation : Valuation R (Multiplicative Γ₀ᵒᵈ) :=
  v
#align add_valuation.valuation AddValuation.valuation
-/

#print AddValuation.valuation_apply /-
@[simp]
theorem valuation_apply (r : R) : v.Valuation r = Multiplicative.ofAdd (OrderDual.toDual (v r)) :=
  rfl
#align add_valuation.valuation_apply AddValuation.valuation_apply
-/

end

#print AddValuation.map_zero /-
@[simp]
theorem map_zero : v 0 = ⊤ :=
  v.map_zero
#align add_valuation.map_zero AddValuation.map_zero
-/

#print AddValuation.map_one /-
@[simp]
theorem map_one : v 1 = 0 :=
  v.map_one
#align add_valuation.map_one AddValuation.map_one
-/

#print AddValuation.map_mul /-
@[simp]
theorem map_mul : ∀ x y, v (x * y) = v x + v y :=
  v.map_mul
#align add_valuation.map_mul AddValuation.map_mul
-/

#print AddValuation.map_add /-
@[simp]
theorem map_add : ∀ x y, min (v x) (v y) ≤ v (x + y) :=
  v.map_add
#align add_valuation.map_add AddValuation.map_add
-/

#print AddValuation.map_le_add /-
theorem map_le_add {x y g} (hx : g ≤ v x) (hy : g ≤ v y) : g ≤ v (x + y) :=
  v.map_add_le hx hy
#align add_valuation.map_le_add AddValuation.map_le_add
-/

#print AddValuation.map_lt_add /-
theorem map_lt_add {x y g} (hx : g < v x) (hy : g < v y) : g < v (x + y) :=
  v.map_add_lt hx hy
#align add_valuation.map_lt_add AddValuation.map_lt_add
-/

#print AddValuation.map_le_sum /-
theorem map_le_sum {ι : Type _} {s : Finset ι} {f : ι → R} {g : Γ₀} (hf : ∀ i ∈ s, g ≤ v (f i)) :
    g ≤ v (∑ i in s, f i) :=
  v.map_sum_le hf
#align add_valuation.map_le_sum AddValuation.map_le_sum
-/

#print AddValuation.map_lt_sum /-
theorem map_lt_sum {ι : Type _} {s : Finset ι} {f : ι → R} {g : Γ₀} (hg : g ≠ ⊤)
    (hf : ∀ i ∈ s, g < v (f i)) : g < v (∑ i in s, f i) :=
  v.map_sum_lt hg hf
#align add_valuation.map_lt_sum AddValuation.map_lt_sum
-/

#print AddValuation.map_lt_sum' /-
theorem map_lt_sum' {ι : Type _} {s : Finset ι} {f : ι → R} {g : Γ₀} (hg : g < ⊤)
    (hf : ∀ i ∈ s, g < v (f i)) : g < v (∑ i in s, f i) :=
  v.map_sum_lt' hg hf
#align add_valuation.map_lt_sum' AddValuation.map_lt_sum'
-/

#print AddValuation.map_pow /-
@[simp]
theorem map_pow : ∀ (x) (n : ℕ), v (x ^ n) = n • v x :=
  v.map_pow
#align add_valuation.map_pow AddValuation.map_pow
-/

#print AddValuation.ext /-
@[ext]
theorem ext {v₁ v₂ : AddValuation R Γ₀} (h : ∀ r, v₁ r = v₂ r) : v₁ = v₂ :=
  Valuation.ext h
#align add_valuation.ext AddValuation.ext
-/

#print AddValuation.ext_iff /-
theorem ext_iff {v₁ v₂ : AddValuation R Γ₀} : v₁ = v₂ ↔ ∀ r, v₁ r = v₂ r :=
  Valuation.ext_iff
#align add_valuation.ext_iff AddValuation.ext_iff
-/

#print AddValuation.toPreorder /-
-- The following definition is not an instance, because we have more than one `v` on a given `R`.
-- In addition, type class inference would not be able to infer `v`.
/-- A valuation gives a preorder on the underlying ring. -/
def toPreorder : Preorder R :=
  Preorder.lift v
#align add_valuation.to_preorder AddValuation.toPreorder
-/

#print AddValuation.top_iff /-
/-- If `v` is an additive valuation on a division ring then `v(x) = ⊤` iff `x = 0`. -/
@[simp]
theorem top_iff [Nontrivial Γ₀] (v : AddValuation K Γ₀) {x : K} : v x = ⊤ ↔ x = 0 :=
  v.zero_iff
#align add_valuation.top_iff AddValuation.top_iff
-/

#print AddValuation.ne_top_iff /-
theorem ne_top_iff [Nontrivial Γ₀] (v : AddValuation K Γ₀) {x : K} : v x ≠ ⊤ ↔ x ≠ 0 :=
  v.neZero_iff
#align add_valuation.ne_top_iff AddValuation.ne_top_iff
-/

#print AddValuation.comap /-
/-- A ring homomorphism `S → R` induces a map `add_valuation R Γ₀ → add_valuation S Γ₀`. -/
def comap {S : Type _} [Ring S] (f : S →+* R) (v : AddValuation R Γ₀) : AddValuation S Γ₀ :=
  v.comap f
#align add_valuation.comap AddValuation.comap
-/

#print AddValuation.comap_id /-
@[simp]
theorem comap_id : v.comap (RingHom.id R) = v :=
  v.comap_id
#align add_valuation.comap_id AddValuation.comap_id
-/

#print AddValuation.comap_comp /-
theorem comap_comp {S₁ : Type _} {S₂ : Type _} [Ring S₁] [Ring S₂] (f : S₁ →+* S₂) (g : S₂ →+* R) :
    v.comap (g.comp f) = (v.comap g).comap f :=
  v.comap_comp f g
#align add_valuation.comap_comp AddValuation.comap_comp
-/

#print AddValuation.map /-
/-- A `≤`-preserving, `⊤`-preserving group homomorphism `Γ₀ → Γ'₀` induces a map
  `add_valuation R Γ₀ → add_valuation R Γ'₀`.
-/
def map (f : Γ₀ →+ Γ'₀) (ht : f ⊤ = ⊤) (hf : Monotone f) (v : AddValuation R Γ₀) :
    AddValuation R Γ'₀ :=
  v.map
    { toFun := f
      map_mul' := f.map_add
      map_one' := f.map_zero
      map_zero' := ht } fun x y h => hf h
#align add_valuation.map AddValuation.map
-/

#print AddValuation.IsEquiv /-
/-- Two additive valuations on `R` are defined to be equivalent if they induce the same
  preorder on `R`. -/
def IsEquiv (v₁ : AddValuation R Γ₀) (v₂ : AddValuation R Γ'₀) : Prop :=
  v₁.IsEquiv v₂
#align add_valuation.is_equiv AddValuation.IsEquiv
-/

end Monoid

section Group

variable [LinearOrderedAddCommGroupWithTop Γ₀] [Ring R] (v : AddValuation R Γ₀) {x y z : R}

#print AddValuation.map_inv /-
@[simp]
theorem map_inv (v : AddValuation K Γ₀) {x : K} : v x⁻¹ = -v x :=
  map_inv₀ v.Valuation x
#align add_valuation.map_inv AddValuation.map_inv
-/

#print AddValuation.map_neg /-
@[simp]
theorem map_neg (x : R) : v (-x) = v x :=
  v.map_neg x
#align add_valuation.map_neg AddValuation.map_neg
-/

#print AddValuation.map_sub_swap /-
theorem map_sub_swap (x y : R) : v (x - y) = v (y - x) :=
  v.map_sub_swap x y
#align add_valuation.map_sub_swap AddValuation.map_sub_swap
-/

#print AddValuation.map_sub /-
theorem map_sub (x y : R) : min (v x) (v y) ≤ v (x - y) :=
  v.map_sub x y
#align add_valuation.map_sub AddValuation.map_sub
-/

#print AddValuation.map_le_sub /-
theorem map_le_sub {x y g} (hx : g ≤ v x) (hy : g ≤ v y) : g ≤ v (x - y) :=
  v.map_sub_le hx hy
#align add_valuation.map_le_sub AddValuation.map_le_sub
-/

#print AddValuation.map_add_of_distinct_val /-
theorem map_add_of_distinct_val (h : v x ≠ v y) : v (x + y) = min (v x) (v y) :=
  v.map_add_of_distinct_val h
#align add_valuation.map_add_of_distinct_val AddValuation.map_add_of_distinct_val
-/

#print AddValuation.map_eq_of_lt_sub /-
theorem map_eq_of_lt_sub (h : v x < v (y - x)) : v y = v x :=
  v.map_eq_of_sub_lt h
#align add_valuation.map_eq_of_lt_sub AddValuation.map_eq_of_lt_sub
-/

end Group

end Basic

namespace IsEquiv

variable [LinearOrderedAddCommMonoidWithTop Γ₀] [LinearOrderedAddCommMonoidWithTop Γ'₀]

variable [Ring R]

variable {Γ''₀ : Type _} [LinearOrderedAddCommMonoidWithTop Γ''₀]

variable {v : AddValuation R Γ₀}

variable {v₁ : AddValuation R Γ₀} {v₂ : AddValuation R Γ'₀} {v₃ : AddValuation R Γ''₀}

#print AddValuation.IsEquiv.refl /-
@[refl]
theorem refl : v.IsEquiv v :=
  Valuation.IsEquiv.refl
#align add_valuation.is_equiv.refl AddValuation.IsEquiv.refl
-/

#print AddValuation.IsEquiv.symm /-
@[symm]
theorem symm (h : v₁.IsEquiv v₂) : v₂.IsEquiv v₁ :=
  h.symm
#align add_valuation.is_equiv.symm AddValuation.IsEquiv.symm
-/

#print AddValuation.IsEquiv.trans /-
@[trans]
theorem trans (h₁₂ : v₁.IsEquiv v₂) (h₂₃ : v₂.IsEquiv v₃) : v₁.IsEquiv v₃ :=
  h₁₂.trans h₂₃
#align add_valuation.is_equiv.trans AddValuation.IsEquiv.trans
-/

#print AddValuation.IsEquiv.of_eq /-
theorem of_eq {v' : AddValuation R Γ₀} (h : v = v') : v.IsEquiv v' :=
  Valuation.IsEquiv.of_eq h
#align add_valuation.is_equiv.of_eq AddValuation.IsEquiv.of_eq
-/

#print AddValuation.IsEquiv.map /-
theorem map {v' : AddValuation R Γ₀} (f : Γ₀ →+ Γ'₀) (ht : f ⊤ = ⊤) (hf : Monotone f)
    (inf : Injective f) (h : v.IsEquiv v') : (v.map f ht hf).IsEquiv (v'.map f ht hf) :=
  h.map
    { toFun := f
      map_mul' := f.map_add
      map_one' := f.map_zero
      map_zero' := ht } (fun x y h => hf h) inf
#align add_valuation.is_equiv.map AddValuation.IsEquiv.map
-/

#print AddValuation.IsEquiv.comap /-
/-- `comap` preserves equivalence. -/
theorem comap {S : Type _} [Ring S] (f : S →+* R) (h : v₁.IsEquiv v₂) :
    (v₁.comap f).IsEquiv (v₂.comap f) :=
  h.comap f
#align add_valuation.is_equiv.comap AddValuation.IsEquiv.comap
-/

#print AddValuation.IsEquiv.val_eq /-
theorem val_eq (h : v₁.IsEquiv v₂) {r s : R} : v₁ r = v₁ s ↔ v₂ r = v₂ s :=
  h.val_eq
#align add_valuation.is_equiv.val_eq AddValuation.IsEquiv.val_eq
-/

#print AddValuation.IsEquiv.ne_top /-
theorem ne_top (h : v₁.IsEquiv v₂) {r : R} : v₁ r ≠ ⊤ ↔ v₂ r ≠ ⊤ :=
  h.NeZero
#align add_valuation.is_equiv.ne_top AddValuation.IsEquiv.ne_top
-/

end IsEquiv

section Supp

variable [LinearOrderedAddCommMonoidWithTop Γ₀] [LinearOrderedAddCommMonoidWithTop Γ'₀]

variable [CommRing R]

variable (v : AddValuation R Γ₀)

#print AddValuation.supp /-
/-- The support of an additive valuation `v : R → Γ₀` is the ideal of `R` where `v x = ⊤` -/
def supp : Ideal R :=
  v.supp
#align add_valuation.supp AddValuation.supp
-/

#print AddValuation.mem_supp_iff /-
@[simp]
theorem mem_supp_iff (x : R) : x ∈ supp v ↔ v x = ⊤ :=
  v.mem_supp_iff x
#align add_valuation.mem_supp_iff AddValuation.mem_supp_iff
-/

#print AddValuation.map_add_supp /-
theorem map_add_supp (a : R) {s : R} (h : s ∈ supp v) : v (a + s) = v a :=
  v.map_add_supp a h
#align add_valuation.map_add_supp AddValuation.map_add_supp
-/

end Supp

-- end of section
end AddValuation

section ValuationNotation

scoped[DiscreteValuation] notation "ℕₘ₀" => WithZero (Multiplicative ℕ)

scoped[DiscreteValuation] notation "ℤₘ₀" => WithZero (Multiplicative ℤ)

end ValuationNotation

