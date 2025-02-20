/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module algebra.big_operators.order
! leanprover-community/mathlib commit 824f9ae93a4f5174d2ea948e2d75843dd83447bb
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Order.AbsoluteValue
import Mathbin.Algebra.Order.Ring.WithTop
import Mathbin.Algebra.BigOperators.Basic
import Mathbin.Data.Fintype.Card

/-!
# Results about big operators with values in an ordered algebraic structure.

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Mostly monotonicity results for the `∏` and `∑` operations.

-/


open Function

open scoped BigOperators

variable {ι α β M N G k R : Type _}

namespace Finset

section OrderedCommMonoid

variable [CommMonoid M] [OrderedCommMonoid N]

#print Finset.le_prod_nonempty_of_submultiplicative_on_pred /-
/-- Let `{x | p x}` be a subsemigroup of a commutative monoid `M`. Let `f : M → N` be a map
submultiplicative on `{x | p x}`, i.e., `p x → p y → f (x * y) ≤ f x * f y`. Let `g i`, `i ∈ s`, be
a nonempty finite family of elements of `M` such that `∀ i ∈ s, p (g i)`. Then
`f (∏ x in s, g x) ≤ ∏ x in s, f (g x)`. -/
@[to_additive le_sum_nonempty_of_subadditive_on_pred]
theorem le_prod_nonempty_of_submultiplicative_on_pred (f : M → N) (p : M → Prop)
    (h_mul : ∀ x y, p x → p y → f (x * y) ≤ f x * f y) (hp_mul : ∀ x y, p x → p y → p (x * y))
    (g : ι → M) (s : Finset ι) (hs_nonempty : s.Nonempty) (hs : ∀ i ∈ s, p (g i)) :
    f (∏ i in s, g i) ≤ ∏ i in s, f (g i) :=
  by
  refine' le_trans (Multiset.le_prod_nonempty_of_submultiplicative_on_pred f p h_mul hp_mul _ _ _) _
  · simp [hs_nonempty.ne_empty]
  · exact multiset.forall_mem_map_iff.mpr hs
  rw [Multiset.map_map]
  rfl
#align finset.le_prod_nonempty_of_submultiplicative_on_pred Finset.le_prod_nonempty_of_submultiplicative_on_pred
#align finset.le_sum_nonempty_of_subadditive_on_pred Finset.le_sum_nonempty_of_subadditive_on_pred
-/

/-- Let `{x | p x}` be an additive subsemigroup of an additive commutative monoid `M`. Let
`f : M → N` be a map subadditive on `{x | p x}`, i.e., `p x → p y → f (x + y) ≤ f x + f y`. Let
`g i`, `i ∈ s`, be a nonempty finite family of elements of `M` such that `∀ i ∈ s, p (g i)`. Then
`f (∑ i in s, g i) ≤ ∑ i in s, f (g i)`. -/
add_decl_doc le_sum_nonempty_of_subadditive_on_pred

#print Finset.le_prod_nonempty_of_submultiplicative /-
/-- If `f : M → N` is a submultiplicative function, `f (x * y) ≤ f x * f y` and `g i`, `i ∈ s`, is a
nonempty finite family of elements of `M`, then `f (∏ i in s, g i) ≤ ∏ i in s, f (g i)`. -/
@[to_additive le_sum_nonempty_of_subadditive]
theorem le_prod_nonempty_of_submultiplicative (f : M → N) (h_mul : ∀ x y, f (x * y) ≤ f x * f y)
    {s : Finset ι} (hs : s.Nonempty) (g : ι → M) : f (∏ i in s, g i) ≤ ∏ i in s, f (g i) :=
  le_prod_nonempty_of_submultiplicative_on_pred f (fun i => True) (fun x y _ _ => h_mul x y)
    (fun _ _ _ _ => trivial) g s hs fun _ _ => trivial
#align finset.le_prod_nonempty_of_submultiplicative Finset.le_prod_nonempty_of_submultiplicative
#align finset.le_sum_nonempty_of_subadditive Finset.le_sum_nonempty_of_subadditive
-/

/-- If `f : M → N` is a subadditive function, `f (x + y) ≤ f x + f y` and `g i`, `i ∈ s`, is a
nonempty finite family of elements of `M`, then `f (∑ i in s, g i) ≤ ∑ i in s, f (g i)`. -/
add_decl_doc le_sum_nonempty_of_subadditive

#print Finset.le_prod_of_submultiplicative_on_pred /-
/-- Let `{x | p x}` be a subsemigroup of a commutative monoid `M`. Let `f : M → N` be a map
such that `f 1 = 1` and `f` is submultiplicative on `{x | p x}`, i.e.,
`p x → p y → f (x * y) ≤ f x * f y`. Let `g i`, `i ∈ s`, be a finite family of elements of `M` such
that `∀ i ∈ s, p (g i)`. Then `f (∏ i in s, g i) ≤ ∏ i in s, f (g i)`. -/
@[to_additive le_sum_of_subadditive_on_pred]
theorem le_prod_of_submultiplicative_on_pred (f : M → N) (p : M → Prop) (h_one : f 1 = 1)
    (h_mul : ∀ x y, p x → p y → f (x * y) ≤ f x * f y) (hp_mul : ∀ x y, p x → p y → p (x * y))
    (g : ι → M) {s : Finset ι} (hs : ∀ i ∈ s, p (g i)) : f (∏ i in s, g i) ≤ ∏ i in s, f (g i) :=
  by
  rcases eq_empty_or_nonempty s with (rfl | hs_nonempty)
  · simp [h_one]
  · exact le_prod_nonempty_of_submultiplicative_on_pred f p h_mul hp_mul g s hs_nonempty hs
#align finset.le_prod_of_submultiplicative_on_pred Finset.le_prod_of_submultiplicative_on_pred
#align finset.le_sum_of_subadditive_on_pred Finset.le_sum_of_subadditive_on_pred
-/

/-- Let `{x | p x}` be a subsemigroup of a commutative additive monoid `M`. Let `f : M → N` be a map
such that `f 0 = 0` and `f` is subadditive on `{x | p x}`, i.e. `p x → p y → f (x + y) ≤ f x + f y`.
Let `g i`, `i ∈ s`, be a finite family of elements of `M` such that `∀ i ∈ s, p (g i)`. Then
`f (∑ x in s, g x) ≤ ∑ x in s, f (g x)`. -/
add_decl_doc le_sum_of_subadditive_on_pred

#print Finset.le_prod_of_submultiplicative /-
/-- If `f : M → N` is a submultiplicative function, `f (x * y) ≤ f x * f y`, `f 1 = 1`, and `g i`,
`i ∈ s`, is a finite family of elements of `M`, then `f (∏ i in s, g i) ≤ ∏ i in s, f (g i)`. -/
@[to_additive le_sum_of_subadditive]
theorem le_prod_of_submultiplicative (f : M → N) (h_one : f 1 = 1)
    (h_mul : ∀ x y, f (x * y) ≤ f x * f y) (s : Finset ι) (g : ι → M) :
    f (∏ i in s, g i) ≤ ∏ i in s, f (g i) :=
  by
  refine' le_trans (Multiset.le_prod_of_submultiplicative f h_one h_mul _) _
  rw [Multiset.map_map]
  rfl
#align finset.le_prod_of_submultiplicative Finset.le_prod_of_submultiplicative
#align finset.le_sum_of_subadditive Finset.le_sum_of_subadditive
-/

/-- If `f : M → N` is a subadditive function, `f (x + y) ≤ f x + f y`, `f 0 = 0`, and `g i`,
`i ∈ s`, is a finite family of elements of `M`, then `f (∑ i in s, g i) ≤ ∑ i in s, f (g i)`. -/
add_decl_doc le_sum_of_subadditive

variable {f g : ι → N} {s t : Finset ι}

#print Finset.prod_le_prod' /-
/-- In an ordered commutative monoid, if each factor `f i` of one finite product is less than or
equal to the corresponding factor `g i` of another finite product, then
`∏ i in s, f i ≤ ∏ i in s, g i`. -/
@[to_additive sum_le_sum]
theorem prod_le_prod' (h : ∀ i ∈ s, f i ≤ g i) : ∏ i in s, f i ≤ ∏ i in s, g i :=
  Multiset.prod_map_le_prod_map f g h
#align finset.prod_le_prod' Finset.prod_le_prod'
#align finset.sum_le_sum Finset.sum_le_sum
-/

/-- In an ordered additive commutative monoid, if each summand `f i` of one finite sum is less than
or equal to the corresponding summand `g i` of another finite sum, then
`∑ i in s, f i ≤ ∑ i in s, g i`. -/
add_decl_doc sum_le_sum

#print Finset.one_le_prod' /-
@[to_additive sum_nonneg]
theorem one_le_prod' (h : ∀ i ∈ s, 1 ≤ f i) : 1 ≤ ∏ i in s, f i :=
  le_trans (by rw [prod_const_one]) (prod_le_prod' h)
#align finset.one_le_prod' Finset.one_le_prod'
#align finset.sum_nonneg Finset.sum_nonneg
-/

#print Finset.one_le_prod'' /-
@[to_additive Finset.sum_nonneg']
theorem one_le_prod'' (h : ∀ i : ι, 1 ≤ f i) : 1 ≤ ∏ i : ι in s, f i :=
  Finset.one_le_prod' fun i hi => h i
#align finset.one_le_prod'' Finset.one_le_prod''
#align finset.sum_nonneg' Finset.sum_nonneg'
-/

#print Finset.prod_le_one' /-
@[to_additive sum_nonpos]
theorem prod_le_one' (h : ∀ i ∈ s, f i ≤ 1) : ∏ i in s, f i ≤ 1 :=
  (prod_le_prod' h).trans_eq (by rw [prod_const_one])
#align finset.prod_le_one' Finset.prod_le_one'
#align finset.sum_nonpos Finset.sum_nonpos
-/

#print Finset.prod_le_prod_of_subset_of_one_le' /-
@[to_additive sum_le_sum_of_subset_of_nonneg]
theorem prod_le_prod_of_subset_of_one_le' (h : s ⊆ t) (hf : ∀ i ∈ t, i ∉ s → 1 ≤ f i) :
    ∏ i in s, f i ≤ ∏ i in t, f i := by
  classical calc
    ∏ i in s, f i ≤ (∏ i in t \ s, f i) * ∏ i in s, f i :=
      le_mul_of_one_le_left' <| one_le_prod' <| by simpa only [mem_sdiff, and_imp]
    _ = ∏ i in t \ s ∪ s, f i := (prod_union sdiff_disjoint).symm
    _ = ∏ i in t, f i := by rw [sdiff_union_of_subset h]
#align finset.prod_le_prod_of_subset_of_one_le' Finset.prod_le_prod_of_subset_of_one_le'
#align finset.sum_le_sum_of_subset_of_nonneg Finset.sum_le_sum_of_subset_of_nonneg
-/

#print Finset.prod_mono_set_of_one_le' /-
@[to_additive sum_mono_set_of_nonneg]
theorem prod_mono_set_of_one_le' (hf : ∀ x, 1 ≤ f x) : Monotone fun s => ∏ x in s, f x :=
  fun s t hst => prod_le_prod_of_subset_of_one_le' hst fun x _ _ => hf x
#align finset.prod_mono_set_of_one_le' Finset.prod_mono_set_of_one_le'
#align finset.sum_mono_set_of_nonneg Finset.sum_mono_set_of_nonneg
-/

#print Finset.prod_le_univ_prod_of_one_le' /-
@[to_additive sum_le_univ_sum_of_nonneg]
theorem prod_le_univ_prod_of_one_le' [Fintype ι] {s : Finset ι} (w : ∀ x, 1 ≤ f x) :
    ∏ x in s, f x ≤ ∏ x, f x :=
  prod_le_prod_of_subset_of_one_le' (subset_univ s) fun a _ _ => w a
#align finset.prod_le_univ_prod_of_one_le' Finset.prod_le_univ_prod_of_one_le'
#align finset.sum_le_univ_sum_of_nonneg Finset.sum_le_univ_sum_of_nonneg
-/

#print Finset.prod_eq_one_iff_of_one_le' /-
@[to_additive sum_eq_zero_iff_of_nonneg]
theorem prod_eq_one_iff_of_one_le' : (∀ i ∈ s, 1 ≤ f i) → (∏ i in s, f i = 1 ↔ ∀ i ∈ s, f i = 1) :=
  by
  classical
  apply Finset.induction_on s
  exact fun _ => ⟨fun _ _ => False.elim, fun _ => rfl⟩
  intro a s ha ih H
  have : ∀ i ∈ s, 1 ≤ f i := fun _ => H _ ∘ mem_insert_of_mem
  rw [prod_insert ha, mul_eq_one_iff' (H _ <| mem_insert_self _ _) (one_le_prod' this),
    forall_mem_insert, ih this]
#align finset.prod_eq_one_iff_of_one_le' Finset.prod_eq_one_iff_of_one_le'
#align finset.sum_eq_zero_iff_of_nonneg Finset.sum_eq_zero_iff_of_nonneg
-/

#print Finset.prod_eq_one_iff_of_le_one' /-
@[to_additive sum_eq_zero_iff_of_nonneg]
theorem prod_eq_one_iff_of_le_one' : (∀ i ∈ s, f i ≤ 1) → (∏ i in s, f i = 1 ↔ ∀ i ∈ s, f i = 1) :=
  @prod_eq_one_iff_of_one_le' _ Nᵒᵈ _ _ _
#align finset.prod_eq_one_iff_of_le_one' Finset.prod_eq_one_iff_of_le_one'
#align finset.sum_eq_zero_iff_of_nonneg Finset.sum_eq_zero_iff_of_nonneg
-/

#print Finset.single_le_prod' /-
@[to_additive single_le_sum]
theorem single_le_prod' (hf : ∀ i ∈ s, 1 ≤ f i) {a} (h : a ∈ s) : f a ≤ ∏ x in s, f x :=
  calc
    f a = ∏ i in {a}, f i := prod_singleton.symm
    _ ≤ ∏ i in s, f i :=
      prod_le_prod_of_subset_of_one_le' (singleton_subset_iff.2 h) fun i hi _ => hf i hi
#align finset.single_le_prod' Finset.single_le_prod'
#align finset.single_le_sum Finset.single_le_sum
-/

#print Finset.prod_le_pow_card /-
@[to_additive sum_le_card_nsmul]
theorem prod_le_pow_card (s : Finset ι) (f : ι → N) (n : N) (h : ∀ x ∈ s, f x ≤ n) :
    s.Prod f ≤ n ^ s.card :=
  by
  refine' (Multiset.prod_le_pow_card (s.val.map f) n _).trans _
  · simpa using h
  · simpa
#align finset.prod_le_pow_card Finset.prod_le_pow_card
#align finset.sum_le_card_nsmul Finset.sum_le_card_nsmul
-/

#print Finset.pow_card_le_prod /-
@[to_additive card_nsmul_le_sum]
theorem pow_card_le_prod (s : Finset ι) (f : ι → N) (n : N) (h : ∀ x ∈ s, n ≤ f x) :
    n ^ s.card ≤ s.Prod f :=
  @Finset.prod_le_pow_card _ Nᵒᵈ _ _ _ _ h
#align finset.pow_card_le_prod Finset.pow_card_le_prod
#align finset.card_nsmul_le_sum Finset.card_nsmul_le_sum
-/

#print Finset.card_biUnion_le_card_mul /-
theorem card_biUnion_le_card_mul [DecidableEq β] (s : Finset ι) (f : ι → Finset β) (n : ℕ)
    (h : ∀ a ∈ s, (f a).card ≤ n) : (s.biUnion f).card ≤ s.card * n :=
  card_biUnion_le.trans <| sum_le_card_nsmul _ _ _ h
#align finset.card_bUnion_le_card_mul Finset.card_biUnion_le_card_mul
-/

variable {ι' : Type _} [DecidableEq ι']

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (y «expr ∉ » t) -/
#print Finset.prod_fiberwise_le_prod_of_one_le_prod_fiber' /-
@[to_additive sum_fiberwise_le_sum_of_sum_fiber_nonneg]
theorem prod_fiberwise_le_prod_of_one_le_prod_fiber' {t : Finset ι'} {g : ι → ι'} {f : ι → N}
    (h : ∀ (y) (_ : y ∉ t), (1 : N) ≤ ∏ x in s.filterₓ fun x => g x = y, f x) :
    ∏ y in t, ∏ x in s.filterₓ fun x => g x = y, f x ≤ ∏ x in s, f x :=
  calc
    ∏ y in t, ∏ x in s.filterₓ fun x => g x = y, f x ≤
        ∏ y in t ∪ s.image g, ∏ x in s.filterₓ fun x => g x = y, f x :=
      prod_le_prod_of_subset_of_one_le' (subset_union_left _ _) fun y hyts => h y
    _ = ∏ x in s, f x :=
      prod_fiberwise_of_maps_to (fun x hx => mem_union.2 <| Or.inr <| mem_image_of_mem _ hx) _
#align finset.prod_fiberwise_le_prod_of_one_le_prod_fiber' Finset.prod_fiberwise_le_prod_of_one_le_prod_fiber'
#align finset.sum_fiberwise_le_sum_of_sum_fiber_nonneg Finset.sum_fiberwise_le_sum_of_sum_fiber_nonneg
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (y «expr ∉ » t) -/
#print Finset.prod_le_prod_fiberwise_of_prod_fiber_le_one' /-
@[to_additive sum_le_sum_fiberwise_of_sum_fiber_nonpos]
theorem prod_le_prod_fiberwise_of_prod_fiber_le_one' {t : Finset ι'} {g : ι → ι'} {f : ι → N}
    (h : ∀ (y) (_ : y ∉ t), ∏ x in s.filterₓ fun x => g x = y, f x ≤ 1) :
    ∏ x in s, f x ≤ ∏ y in t, ∏ x in s.filterₓ fun x => g x = y, f x :=
  @prod_fiberwise_le_prod_of_one_le_prod_fiber' _ Nᵒᵈ _ _ _ _ _ _ _ h
#align finset.prod_le_prod_fiberwise_of_prod_fiber_le_one' Finset.prod_le_prod_fiberwise_of_prod_fiber_le_one'
#align finset.sum_le_sum_fiberwise_of_sum_fiber_nonpos Finset.sum_le_sum_fiberwise_of_sum_fiber_nonpos
-/

end OrderedCommMonoid

#print Finset.abs_sum_le_sum_abs /-
theorem abs_sum_le_sum_abs {G : Type _} [LinearOrderedAddCommGroup G] (f : ι → G) (s : Finset ι) :
    |∑ i in s, f i| ≤ ∑ i in s, |f i| :=
  le_sum_of_subadditive _ abs_zero abs_add s f
#align finset.abs_sum_le_sum_abs Finset.abs_sum_le_sum_abs
-/

#print Finset.abs_sum_of_nonneg /-
theorem abs_sum_of_nonneg {G : Type _} [LinearOrderedAddCommGroup G] {f : ι → G} {s : Finset ι}
    (hf : ∀ i ∈ s, 0 ≤ f i) : |∑ i : ι in s, f i| = ∑ i : ι in s, f i := by
  rw [abs_of_nonneg (Finset.sum_nonneg hf)]
#align finset.abs_sum_of_nonneg Finset.abs_sum_of_nonneg
-/

#print Finset.abs_sum_of_nonneg' /-
theorem abs_sum_of_nonneg' {G : Type _} [LinearOrderedAddCommGroup G] {f : ι → G} {s : Finset ι}
    (hf : ∀ i, 0 ≤ f i) : |∑ i : ι in s, f i| = ∑ i : ι in s, f i := by
  rw [abs_of_nonneg (Finset.sum_nonneg' hf)]
#align finset.abs_sum_of_nonneg' Finset.abs_sum_of_nonneg'
-/

#print Finset.abs_prod /-
theorem abs_prod {R : Type _} [LinearOrderedCommRing R] {f : ι → R} {s : Finset ι} :
    |∏ x in s, f x| = ∏ x in s, |f x| :=
  (absHom.toMonoidHom : R →* R).map_prod _ _
#align finset.abs_prod Finset.abs_prod
-/

section Pigeonhole

variable [DecidableEq β]

#print Finset.card_le_mul_card_image_of_maps_to /-
theorem card_le_mul_card_image_of_maps_to {f : α → β} {s : Finset α} {t : Finset β}
    (Hf : ∀ a ∈ s, f a ∈ t) (n : ℕ) (hn : ∀ a ∈ t, (s.filterₓ fun x => f x = a).card ≤ n) :
    s.card ≤ n * t.card :=
  calc
    s.card = ∑ a in t, (s.filterₓ fun x => f x = a).card := card_eq_sum_card_fiberwise Hf
    _ ≤ ∑ _ in t, n := (sum_le_sum hn)
    _ = _ := by simp [mul_comm]
#align finset.card_le_mul_card_image_of_maps_to Finset.card_le_mul_card_image_of_maps_to
-/

#print Finset.card_le_mul_card_image /-
theorem card_le_mul_card_image {f : α → β} (s : Finset α) (n : ℕ)
    (hn : ∀ a ∈ s.image f, (s.filterₓ fun x => f x = a).card ≤ n) : s.card ≤ n * (s.image f).card :=
  card_le_mul_card_image_of_maps_to (fun x => mem_image_of_mem _) n hn
#align finset.card_le_mul_card_image Finset.card_le_mul_card_image
-/

#print Finset.mul_card_image_le_card_of_maps_to /-
theorem mul_card_image_le_card_of_maps_to {f : α → β} {s : Finset α} {t : Finset β}
    (Hf : ∀ a ∈ s, f a ∈ t) (n : ℕ) (hn : ∀ a ∈ t, n ≤ (s.filterₓ fun x => f x = a).card) :
    n * t.card ≤ s.card :=
  calc
    n * t.card = ∑ _ in t, n := by simp [mul_comm]
    _ ≤ ∑ a in t, (s.filterₓ fun x => f x = a).card := (sum_le_sum hn)
    _ = s.card := by rw [← card_eq_sum_card_fiberwise Hf]
#align finset.mul_card_image_le_card_of_maps_to Finset.mul_card_image_le_card_of_maps_to
-/

#print Finset.mul_card_image_le_card /-
theorem mul_card_image_le_card {f : α → β} (s : Finset α) (n : ℕ)
    (hn : ∀ a ∈ s.image f, n ≤ (s.filterₓ fun x => f x = a).card) : n * (s.image f).card ≤ s.card :=
  mul_card_image_le_card_of_maps_to (fun x => mem_image_of_mem _) n hn
#align finset.mul_card_image_le_card Finset.mul_card_image_le_card
-/

end Pigeonhole

section DoubleCounting

variable [DecidableEq α] {s : Finset α} {B : Finset (Finset α)} {n : ℕ}

#print Finset.sum_card_inter_le /-
/-- If every element belongs to at most `n` finsets, then the sum of their sizes is at most `n`
times how many they are. -/
theorem sum_card_inter_le (h : ∀ a ∈ s, (B.filterₓ <| (· ∈ ·) a).card ≤ n) :
    ∑ t in B, (s ∩ t).card ≤ s.card * n :=
  by
  refine' le_trans _ (s.sum_le_card_nsmul _ _ h)
  simp_rw [← filter_mem_eq_inter, card_eq_sum_ones, sum_filter]
  exact sum_comm.le
#align finset.sum_card_inter_le Finset.sum_card_inter_le
-/

#print Finset.sum_card_le /-
/-- If every element belongs to at most `n` finsets, then the sum of their sizes is at most `n`
times how many they are. -/
theorem sum_card_le [Fintype α] (h : ∀ a, (B.filterₓ <| (· ∈ ·) a).card ≤ n) :
    ∑ s in B, s.card ≤ Fintype.card α * n :=
  calc
    ∑ s in B, s.card = ∑ s in B, (univ ∩ s).card := by simp_rw [univ_inter]
    _ ≤ Fintype.card α * n := sum_card_inter_le fun a _ => h a
#align finset.sum_card_le Finset.sum_card_le
-/

#print Finset.le_sum_card_inter /-
/-- If every element belongs to at least `n` finsets, then the sum of their sizes is at least `n`
times how many they are. -/
theorem le_sum_card_inter (h : ∀ a ∈ s, n ≤ (B.filterₓ <| (· ∈ ·) a).card) :
    s.card * n ≤ ∑ t in B, (s ∩ t).card :=
  by
  apply (s.card_nsmul_le_sum _ _ h).trans
  simp_rw [← filter_mem_eq_inter, card_eq_sum_ones, sum_filter]
  exact sum_comm.le
#align finset.le_sum_card_inter Finset.le_sum_card_inter
-/

#print Finset.le_sum_card /-
/-- If every element belongs to at least `n` finsets, then the sum of their sizes is at least `n`
times how many they are. -/
theorem le_sum_card [Fintype α] (h : ∀ a, n ≤ (B.filterₓ <| (· ∈ ·) a).card) :
    Fintype.card α * n ≤ ∑ s in B, s.card :=
  calc
    Fintype.card α * n ≤ ∑ s in B, (univ ∩ s).card := le_sum_card_inter fun a _ => h a
    _ = ∑ s in B, s.card := by simp_rw [univ_inter]
#align finset.le_sum_card Finset.le_sum_card
-/

#print Finset.sum_card_inter /-
/-- If every element belongs to exactly `n` finsets, then the sum of their sizes is `n` times how
many they are. -/
theorem sum_card_inter (h : ∀ a ∈ s, (B.filterₓ <| (· ∈ ·) a).card = n) :
    ∑ t in B, (s ∩ t).card = s.card * n :=
  (sum_card_inter_le fun a ha => (h a ha).le).antisymm (le_sum_card_inter fun a ha => (h a ha).ge)
#align finset.sum_card_inter Finset.sum_card_inter
-/

#print Finset.sum_card /-
/-- If every element belongs to exactly `n` finsets, then the sum of their sizes is `n` times how
many they are. -/
theorem sum_card [Fintype α] (h : ∀ a, (B.filterₓ <| (· ∈ ·) a).card = n) :
    ∑ s in B, s.card = Fintype.card α * n := by
  simp_rw [Fintype.card, ← sum_card_inter fun a _ => h a, univ_inter]
#align finset.sum_card Finset.sum_card
-/

#print Finset.card_le_card_biUnion /-
theorem card_le_card_biUnion {s : Finset ι} {f : ι → Finset α} (hs : (s : Set ι).PairwiseDisjoint f)
    (hf : ∀ i ∈ s, (f i).Nonempty) : s.card ≤ (s.biUnion f).card := by
  rw [card_bUnion hs, card_eq_sum_ones]; exact sum_le_sum fun i hi => (hf i hi).card_pos
#align finset.card_le_card_bUnion Finset.card_le_card_biUnion
-/

#print Finset.card_le_card_biUnion_add_card_fiber /-
theorem card_le_card_biUnion_add_card_fiber {s : Finset ι} {f : ι → Finset α}
    (hs : (s : Set ι).PairwiseDisjoint f) :
    s.card ≤ (s.biUnion f).card + (s.filterₓ fun i => f i = ∅).card :=
  by
  rw [← Finset.filter_card_add_filter_neg_card_eq_card fun i => f i = ∅, add_comm]
  exact
    add_le_add_right
      ((card_le_card_bUnion (hs.subset <| filter_subset _ _) fun i hi =>
            nonempty_of_ne_empty <| (mem_filter.1 hi).2).trans <|
        card_le_of_subset <| bUnion_subset_bUnion_of_subset_left _ <| filter_subset _ _)
      _
#align finset.card_le_card_bUnion_add_card_fiber Finset.card_le_card_biUnion_add_card_fiber
-/

#print Finset.card_le_card_biUnion_add_one /-
theorem card_le_card_biUnion_add_one {s : Finset ι} {f : ι → Finset α} (hf : Injective f)
    (hs : (s : Set ι).PairwiseDisjoint f) : s.card ≤ (s.biUnion f).card + 1 :=
  (card_le_card_biUnion_add_card_fiber hs).trans <|
    add_le_add_left
      (card_le_one.2 fun i hi j hj => hf <| (mem_filter.1 hi).2.trans (mem_filter.1 hj).2.symm) _
#align finset.card_le_card_bUnion_add_one Finset.card_le_card_biUnion_add_one
-/

end DoubleCounting

section CanonicallyOrderedMonoid

variable [CanonicallyOrderedMonoid M] {f : ι → M} {s t : Finset ι}

#print Finset.prod_eq_one_iff' /-
@[simp, to_additive sum_eq_zero_iff]
theorem prod_eq_one_iff' : ∏ x in s, f x = 1 ↔ ∀ x ∈ s, f x = 1 :=
  prod_eq_one_iff_of_one_le' fun x hx => one_le (f x)
#align finset.prod_eq_one_iff' Finset.prod_eq_one_iff'
#align finset.sum_eq_zero_iff Finset.sum_eq_zero_iff
-/

#print Finset.prod_le_prod_of_subset' /-
@[to_additive sum_le_sum_of_subset]
theorem prod_le_prod_of_subset' (h : s ⊆ t) : ∏ x in s, f x ≤ ∏ x in t, f x :=
  prod_le_prod_of_subset_of_one_le' h fun x h₁ h₂ => one_le _
#align finset.prod_le_prod_of_subset' Finset.prod_le_prod_of_subset'
#align finset.sum_le_sum_of_subset Finset.sum_le_sum_of_subset
-/

#print Finset.prod_mono_set' /-
@[to_additive sum_mono_set]
theorem prod_mono_set' (f : ι → M) : Monotone fun s => ∏ x in s, f x := fun s₁ s₂ hs =>
  prod_le_prod_of_subset' hs
#align finset.prod_mono_set' Finset.prod_mono_set'
#align finset.sum_mono_set Finset.sum_mono_set
-/

#print Finset.prod_le_prod_of_ne_one' /-
@[to_additive sum_le_sum_of_ne_zero]
theorem prod_le_prod_of_ne_one' (h : ∀ x ∈ s, f x ≠ 1 → x ∈ t) : ∏ x in s, f x ≤ ∏ x in t, f x := by
  classical calc
    ∏ x in s, f x =
        (∏ x in s.filter fun x => f x = 1, f x) * ∏ x in s.filter fun x => f x ≠ 1, f x :=
      by
      rw [← prod_union, filter_union_filter_neg_eq] <;>
        exact disjoint_filter.2 fun _ _ h n_h => n_h h
    _ ≤ ∏ x in t, f x :=
      mul_le_of_le_one_of_le
        (prod_le_one' <| by simp only [mem_filter, and_imp] <;> exact fun _ _ => le_of_eq)
        (prod_le_prod_of_subset' <| by simpa only [subset_iff, mem_filter, and_imp])
#align finset.prod_le_prod_of_ne_one' Finset.prod_le_prod_of_ne_one'
#align finset.sum_le_sum_of_ne_zero Finset.sum_le_sum_of_ne_zero
-/

end CanonicallyOrderedMonoid

section OrderedCancelCommMonoid

variable [OrderedCancelCommMonoid M] {f g : ι → M} {s t : Finset ι}

#print Finset.prod_lt_prod' /-
@[to_additive sum_lt_sum]
theorem prod_lt_prod' (Hle : ∀ i ∈ s, f i ≤ g i) (Hlt : ∃ i ∈ s, f i < g i) :
    ∏ i in s, f i < ∏ i in s, g i := by
  classical
  rcases Hlt with ⟨i, hi, hlt⟩
  rw [← insert_erase hi, prod_insert (not_mem_erase _ _), prod_insert (not_mem_erase _ _)]
  exact mul_lt_mul_of_lt_of_le hlt (prod_le_prod' fun j hj => Hle j <| mem_of_mem_erase hj)
#align finset.prod_lt_prod' Finset.prod_lt_prod'
#align finset.sum_lt_sum Finset.sum_lt_sum
-/

#print Finset.prod_lt_prod_of_nonempty' /-
@[to_additive sum_lt_sum_of_nonempty]
theorem prod_lt_prod_of_nonempty' (hs : s.Nonempty) (Hlt : ∀ i ∈ s, f i < g i) :
    ∏ i in s, f i < ∏ i in s, g i := by
  apply prod_lt_prod'
  · intro i hi; apply le_of_lt (Hlt i hi)
  cases' hs with i hi
  exact ⟨i, hi, Hlt i hi⟩
#align finset.prod_lt_prod_of_nonempty' Finset.prod_lt_prod_of_nonempty'
#align finset.sum_lt_sum_of_nonempty Finset.sum_lt_sum_of_nonempty
-/

#print Finset.prod_lt_prod_of_subset' /-
@[to_additive sum_lt_sum_of_subset]
theorem prod_lt_prod_of_subset' (h : s ⊆ t) {i : ι} (ht : i ∈ t) (hs : i ∉ s) (hlt : 1 < f i)
    (hle : ∀ j ∈ t, j ∉ s → 1 ≤ f j) : ∏ j in s, f j < ∏ j in t, f j := by
  classical calc
    ∏ j in s, f j < ∏ j in insert i s, f j :=
      by
      rw [prod_insert hs]
      exact lt_mul_of_one_lt_left' (∏ j in s, f j) hlt
    _ ≤ ∏ j in t, f j := by
      apply prod_le_prod_of_subset_of_one_le'
      · simp [Finset.insert_subset_iff, h, ht]
      · intro x hx h'x
        simp only [mem_insert, not_or] at h'x 
        exact hle x hx h'x.2
#align finset.prod_lt_prod_of_subset' Finset.prod_lt_prod_of_subset'
#align finset.sum_lt_sum_of_subset Finset.sum_lt_sum_of_subset
-/

#print Finset.single_lt_prod' /-
@[to_additive single_lt_sum]
theorem single_lt_prod' {i j : ι} (hij : j ≠ i) (hi : i ∈ s) (hj : j ∈ s) (hlt : 1 < f j)
    (hle : ∀ k ∈ s, k ≠ i → 1 ≤ f k) : f i < ∏ k in s, f k :=
  calc
    f i = ∏ k in {i}, f k := prod_singleton.symm
    _ < ∏ k in s, f k :=
      prod_lt_prod_of_subset' (singleton_subset_iff.2 hi) hj (mt mem_singleton.1 hij) hlt
        fun k hks hki => hle k hks (mt mem_singleton.2 hki)
#align finset.single_lt_prod' Finset.single_lt_prod'
#align finset.single_lt_sum Finset.single_lt_sum
-/

#print Finset.one_lt_prod /-
@[to_additive sum_pos]
theorem one_lt_prod (h : ∀ i ∈ s, 1 < f i) (hs : s.Nonempty) : 1 < ∏ i in s, f i :=
  lt_of_le_of_lt (by rw [prod_const_one]) <| prod_lt_prod_of_nonempty' hs h
#align finset.one_lt_prod Finset.one_lt_prod
#align finset.sum_pos Finset.sum_pos
-/

#print Finset.prod_lt_one /-
@[to_additive]
theorem prod_lt_one (h : ∀ i ∈ s, f i < 1) (hs : s.Nonempty) : ∏ i in s, f i < 1 :=
  (prod_lt_prod_of_nonempty' hs h).trans_le (by rw [prod_const_one])
#align finset.prod_lt_one Finset.prod_lt_one
#align finset.sum_neg Finset.sum_neg
-/

#print Finset.one_lt_prod' /-
@[to_additive sum_pos']
theorem one_lt_prod' (h : ∀ i ∈ s, 1 ≤ f i) (hs : ∃ i ∈ s, 1 < f i) : 1 < ∏ i in s, f i :=
  prod_const_one.symm.trans_lt <| prod_lt_prod' h hs
#align finset.one_lt_prod' Finset.one_lt_prod'
#align finset.sum_pos' Finset.sum_pos'
-/

#print Finset.prod_lt_one' /-
@[to_additive]
theorem prod_lt_one' (h : ∀ i ∈ s, f i ≤ 1) (hs : ∃ i ∈ s, f i < 1) : ∏ i in s, f i < 1 :=
  prod_const_one.le.trans_lt' <| prod_lt_prod' h hs
#align finset.prod_lt_one' Finset.prod_lt_one'
#align finset.sum_neg' Finset.sum_neg'
-/

#print Finset.prod_eq_prod_iff_of_le /-
@[to_additive]
theorem prod_eq_prod_iff_of_le {f g : ι → M} (h : ∀ i ∈ s, f i ≤ g i) :
    ∏ i in s, f i = ∏ i in s, g i ↔ ∀ i ∈ s, f i = g i := by
  classical
  revert h
  refine'
    Finset.induction_on s (fun _ => ⟨fun _ _ => False.elim, fun _ => rfl⟩) fun a s ha ih H => _
  specialize ih fun i => H i ∘ Finset.mem_insert_of_mem
  rw [Finset.prod_insert ha, Finset.prod_insert ha, Finset.forall_mem_insert, ← ih]
  exact
    mul_eq_mul_iff_eq_and_eq (H a (s.mem_insert_self a))
      (Finset.prod_le_prod' fun i => H i ∘ Finset.mem_insert_of_mem)
#align finset.prod_eq_prod_iff_of_le Finset.prod_eq_prod_iff_of_le
#align finset.sum_eq_sum_iff_of_le Finset.sum_eq_sum_iff_of_le
-/

end OrderedCancelCommMonoid

section LinearOrderedCancelCommMonoid

variable [LinearOrderedCancelCommMonoid M] {f g : ι → M} {s t : Finset ι}

#print Finset.exists_lt_of_prod_lt' /-
@[to_additive exists_lt_of_sum_lt]
theorem exists_lt_of_prod_lt' (Hlt : ∏ i in s, f i < ∏ i in s, g i) : ∃ i ∈ s, f i < g i :=
  by
  contrapose! Hlt with Hle
  exact prod_le_prod' Hle
#align finset.exists_lt_of_prod_lt' Finset.exists_lt_of_prod_lt'
#align finset.exists_lt_of_sum_lt Finset.exists_lt_of_sum_lt
-/

#print Finset.exists_le_of_prod_le' /-
@[to_additive exists_le_of_sum_le]
theorem exists_le_of_prod_le' (hs : s.Nonempty) (Hle : ∏ i in s, f i ≤ ∏ i in s, g i) :
    ∃ i ∈ s, f i ≤ g i := by
  contrapose! Hle with Hlt
  exact prod_lt_prod_of_nonempty' hs Hlt
#align finset.exists_le_of_prod_le' Finset.exists_le_of_prod_le'
#align finset.exists_le_of_sum_le Finset.exists_le_of_sum_le
-/

#print Finset.exists_one_lt_of_prod_one_of_exists_ne_one' /-
@[to_additive exists_pos_of_sum_zero_of_exists_nonzero]
theorem exists_one_lt_of_prod_one_of_exists_ne_one' (f : ι → M) (h₁ : ∏ i in s, f i = 1)
    (h₂ : ∃ i ∈ s, f i ≠ 1) : ∃ i ∈ s, 1 < f i :=
  by
  contrapose! h₁
  obtain ⟨i, m, i_ne⟩ : ∃ i ∈ s, f i ≠ 1 := h₂
  apply ne_of_lt
  calc
    ∏ j in s, f j < ∏ j in s, 1 := prod_lt_prod' h₁ ⟨i, m, (h₁ i m).lt_of_ne i_ne⟩
    _ = 1 := prod_const_one
#align finset.exists_one_lt_of_prod_one_of_exists_ne_one' Finset.exists_one_lt_of_prod_one_of_exists_ne_one'
#align finset.exists_pos_of_sum_zero_of_exists_nonzero Finset.exists_pos_of_sum_zero_of_exists_nonzero
-/

end LinearOrderedCancelCommMonoid

section OrderedCommSemiring

variable [OrderedCommSemiring R] {f g : ι → R} {s t : Finset ι}

open scoped Classical

#print Finset.prod_nonneg /-
-- this is also true for a ordered commutative multiplicative monoid with zero
theorem prod_nonneg (h0 : ∀ i ∈ s, 0 ≤ f i) : 0 ≤ ∏ i in s, f i :=
  prod_induction f (fun i => 0 ≤ i) (fun _ _ ha hb => mul_nonneg ha hb) zero_le_one h0
#align finset.prod_nonneg Finset.prod_nonneg
-/

#print Finset.prod_le_prod /-
/-- If all `f i`, `i ∈ s`, are nonnegative and each `f i` is less than or equal to `g i`, then the
product of `f i` is less than or equal to the product of `g i`. See also `finset.prod_le_prod'` for
the case of an ordered commutative multiplicative monoid. -/
theorem prod_le_prod (h0 : ∀ i ∈ s, 0 ≤ f i) (h1 : ∀ i ∈ s, f i ≤ g i) :
    ∏ i in s, f i ≤ ∏ i in s, g i :=
  by
  induction' s using Finset.induction with a s has ih h
  · simp
  · simp only [prod_insert has]; apply mul_le_mul
    · exact h1 a (mem_insert_self a s)
    · apply ih (fun x H => h0 _ _) fun x H => h1 _ _ <;> exact mem_insert_of_mem H
    · apply prod_nonneg fun x H => h0 x (mem_insert_of_mem H)
    · apply le_trans (h0 a (mem_insert_self a s)) (h1 a (mem_insert_self a s))
#align finset.prod_le_prod Finset.prod_le_prod
-/

#print Finset.prod_le_one /-
/-- If each `f i`, `i ∈ s` belongs to `[0, 1]`, then their product is less than or equal to one.
See also `finset.prod_le_one'` for the case of an ordered commutative multiplicative monoid. -/
theorem prod_le_one (h0 : ∀ i ∈ s, 0 ≤ f i) (h1 : ∀ i ∈ s, f i ≤ 1) : ∏ i in s, f i ≤ 1 :=
  by
  convert ← prod_le_prod h0 h1
  exact Finset.prod_const_one
#align finset.prod_le_one Finset.prod_le_one
-/

#print Finset.prod_add_prod_le /-
/-- If `g, h ≤ f` and `g i + h i ≤ f i`, then the product of `f` over `s` is at least the
  sum of the products of `g` and `h`. This is the version for `ordered_comm_semiring`. -/
theorem prod_add_prod_le {i : ι} {f g h : ι → R} (hi : i ∈ s) (h2i : g i + h i ≤ f i)
    (hgf : ∀ j ∈ s, j ≠ i → g j ≤ f j) (hhf : ∀ j ∈ s, j ≠ i → h j ≤ f j) (hg : ∀ i ∈ s, 0 ≤ g i)
    (hh : ∀ i ∈ s, 0 ≤ h i) : ∏ i in s, g i + ∏ i in s, h i ≤ ∏ i in s, f i :=
  by
  simp_rw [prod_eq_mul_prod_diff_singleton hi]
  refine' le_trans _ (mul_le_mul_of_nonneg_right h2i _)
  · rw [right_distrib]
    apply add_le_add <;> apply mul_le_mul_of_nonneg_left <;> try apply_assumption <;> assumption <;>
        apply prod_le_prod <;>
      simp (config := { contextual := true }) [*]
  · apply prod_nonneg; simp only [and_imp, mem_sdiff, mem_singleton]
    intro j h1j h2j; exact le_trans (hg j h1j) (hgf j h1j h2j)
#align finset.prod_add_prod_le Finset.prod_add_prod_le
-/

end OrderedCommSemiring

section StrictOrderedCommSemiring

variable [StrictOrderedCommSemiring R] [Nontrivial R] {f : ι → R} {s : Finset ι}

#print Finset.prod_pos /-
-- This is also true for a ordered commutative multiplicative monoid with zero
theorem prod_pos (h0 : ∀ i ∈ s, 0 < f i) : 0 < ∏ i in s, f i :=
  prod_induction f (fun x => 0 < x) (fun _ _ ha hb => mul_pos ha hb) zero_lt_one h0
#align finset.prod_pos Finset.prod_pos
-/

end StrictOrderedCommSemiring

section CanonicallyOrderedCommSemiring

variable [CanonicallyOrderedCommSemiring R] {f g h : ι → R} {s : Finset ι} {i : ι}

#print CanonicallyOrderedCommSemiring.multiset_prod_pos /-
@[simp]
theorem CanonicallyOrderedCommSemiring.multiset_prod_pos [Nontrivial R] {m : Multiset R} :
    0 < m.Prod ↔ ∀ x ∈ m, (0 : R) < x :=
  by
  induction m using Quotient.inductionOn
  rw [Multiset.quot_mk_to_coe, Multiset.coe_prod]
  exact CanonicallyOrderedCommSemiring.list_prod_pos
#align canonically_ordered_comm_semiring.multiset_prod_pos CanonicallyOrderedCommSemiring.multiset_prod_pos
-/

#print CanonicallyOrderedCommSemiring.prod_pos /-
/-- Note that the name is to match `canonically_ordered_comm_semiring.mul_pos`. -/
@[simp]
theorem CanonicallyOrderedCommSemiring.prod_pos [Nontrivial R] :
    0 < ∏ i in s, f i ↔ ∀ i ∈ s, (0 : R) < f i :=
  CanonicallyOrderedCommSemiring.multiset_prod_pos.trans <| by simp
#align canonically_ordered_comm_semiring.prod_pos CanonicallyOrderedCommSemiring.prod_pos
-/

#print Finset.prod_add_prod_le' /-
/-- If `g, h ≤ f` and `g i + h i ≤ f i`, then the product of `f` over `s` is at least the
  sum of the products of `g` and `h`. This is the version for `canonically_ordered_comm_semiring`.
-/
theorem prod_add_prod_le' (hi : i ∈ s) (h2i : g i + h i ≤ f i) (hgf : ∀ j ∈ s, j ≠ i → g j ≤ f j)
    (hhf : ∀ j ∈ s, j ≠ i → h j ≤ f j) : ∏ i in s, g i + ∏ i in s, h i ≤ ∏ i in s, f i := by
  classical
  simp_rw [prod_eq_mul_prod_diff_singleton hi]
  refine' le_trans _ (mul_le_mul_right' h2i _)
  rw [right_distrib]
  apply add_le_add <;> apply mul_le_mul_left' <;> apply prod_le_prod' <;>
          simp only [and_imp, mem_sdiff, mem_singleton] <;>
        intros <;>
      apply_assumption <;>
    assumption
#align finset.prod_add_prod_le' Finset.prod_add_prod_le'
-/

end CanonicallyOrderedCommSemiring

end Finset

namespace Fintype

variable [Fintype ι]

#print Fintype.prod_mono' /-
@[to_additive sum_mono, mono]
theorem prod_mono' [OrderedCommMonoid M] : Monotone fun f : ι → M => ∏ i, f i := fun f g hfg =>
  Finset.prod_le_prod' fun x _ => hfg x
#align fintype.prod_mono' Fintype.prod_mono'
#align fintype.sum_mono Fintype.sum_mono
-/

attribute [mono] sum_mono

#print Fintype.prod_strict_mono' /-
@[to_additive sum_strict_mono]
theorem prod_strict_mono' [OrderedCancelCommMonoid M] : StrictMono fun f : ι → M => ∏ x, f x :=
  fun f g hfg =>
  let ⟨hle, i, hlt⟩ := Pi.lt_def.mp hfg
  Finset.prod_lt_prod' (fun i _ => hle i) ⟨i, Finset.mem_univ i, hlt⟩
#align fintype.prod_strict_mono' Fintype.prod_strict_mono'
#align fintype.sum_strict_mono Fintype.sum_strict_mono
-/

end Fintype

namespace WithTop

open Finset

#print WithTop.prod_lt_top /-
/-- A product of finite numbers is still finite -/
theorem prod_lt_top [CommMonoidWithZero R] [NoZeroDivisors R] [Nontrivial R] [DecidableEq R] [LT R]
    {s : Finset ι} {f : ι → WithTop R} (h : ∀ i ∈ s, f i ≠ ⊤) : ∏ i in s, f i < ⊤ :=
  prod_induction f (fun a => a < ⊤) (fun a b h₁ h₂ => mul_lt_top' h₁ h₂) (coe_lt_top 1) fun a ha =>
    WithTop.lt_top_iff_ne_top.2 (h a ha)
#align with_top.prod_lt_top WithTop.prod_lt_top
-/

#print WithTop.sum_eq_top_iff /-
/-- A sum of numbers is infinite iff one of them is infinite -/
theorem sum_eq_top_iff [AddCommMonoid M] {s : Finset ι} {f : ι → WithTop M} :
    ∑ i in s, f i = ⊤ ↔ ∃ i ∈ s, f i = ⊤ := by
  induction s using Finset.cons_induction <;> simp [*, or_and_right, exists_or]
#align with_top.sum_eq_top_iff WithTop.sum_eq_top_iff
-/

#print WithTop.sum_lt_top_iff /-
/-- A sum of finite numbers is still finite -/
theorem sum_lt_top_iff [AddCommMonoid M] [LT M] {s : Finset ι} {f : ι → WithTop M} :
    ∑ i in s, f i < ⊤ ↔ ∀ i ∈ s, f i < ⊤ := by
  simp only [WithTop.lt_top_iff_ne_top, Ne.def, sum_eq_top_iff, not_exists]
#align with_top.sum_lt_top_iff WithTop.sum_lt_top_iff
-/

#print WithTop.sum_lt_top /-
/-- A sum of finite numbers is still finite -/
theorem sum_lt_top [AddCommMonoid M] [LT M] {s : Finset ι} {f : ι → WithTop M}
    (h : ∀ i ∈ s, f i ≠ ⊤) : ∑ i in s, f i < ⊤ :=
  sum_lt_top_iff.2 fun i hi => WithTop.lt_top_iff_ne_top.2 (h i hi)
#align with_top.sum_lt_top WithTop.sum_lt_top
-/

end WithTop

section AbsoluteValue

variable {S : Type _}

#print AbsoluteValue.sum_le /-
theorem AbsoluteValue.sum_le [Semiring R] [OrderedSemiring S] (abv : AbsoluteValue R S)
    (s : Finset ι) (f : ι → R) : abv (∑ i in s, f i) ≤ ∑ i in s, abv (f i) :=
  Finset.le_sum_of_subadditive abv (map_zero _) abv.add_le _ _
#align absolute_value.sum_le AbsoluteValue.sum_le
-/

#print IsAbsoluteValue.abv_sum /-
theorem IsAbsoluteValue.abv_sum [Semiring R] [OrderedSemiring S] (abv : R → S) [IsAbsoluteValue abv]
    (f : ι → R) (s : Finset ι) : abv (∑ i in s, f i) ≤ ∑ i in s, abv (f i) :=
  (IsAbsoluteValue.toAbsoluteValue abv).sum_le _ _
#align is_absolute_value.abv_sum IsAbsoluteValue.abv_sum
-/

#print AbsoluteValue.map_prod /-
theorem AbsoluteValue.map_prod [CommSemiring R] [Nontrivial R] [LinearOrderedCommRing S]
    (abv : AbsoluteValue R S) (f : ι → R) (s : Finset ι) :
    abv (∏ i in s, f i) = ∏ i in s, abv (f i) :=
  abv.toMonoidHom.map_prod f s
#align absolute_value.map_prod AbsoluteValue.map_prod
-/

#print IsAbsoluteValue.map_prod /-
theorem IsAbsoluteValue.map_prod [CommSemiring R] [Nontrivial R] [LinearOrderedCommRing S]
    (abv : R → S) [IsAbsoluteValue abv] (f : ι → R) (s : Finset ι) :
    abv (∏ i in s, f i) = ∏ i in s, abv (f i) :=
  (IsAbsoluteValue.toAbsoluteValue abv).map_prod _ _
#align is_absolute_value.map_prod IsAbsoluteValue.map_prod
-/

end AbsoluteValue

