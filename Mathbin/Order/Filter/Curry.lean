/-
Copyright (c) 2022 Kevin H. Wilson. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin H. Wilson

! This file was ported from Lean 3 source module order.filter.curry
! leanprover-community/mathlib commit 63f84d91dd847f50bae04a01071f3a5491934e36
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Filter.Prod

/-!
# Curried Filters

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides an operation (`filter.curry`) on filters which provides the equivalence
`∀ᶠ a in l, ∀ᶠ b in l', p (a, b) ↔ ∀ᶠ c in (l.curry l'), p c` (see `filter.eventually_curry_iff`).

To understand when this operation might arise, it is helpful to think of `∀ᶠ` as a combination of
the quantifiers `∃ ∀`. For instance, `∀ᶠ n in at_top, p n ↔ ∃ N, ∀ n ≥ N, p n`. A curried filter
yields the quantifier order `∃ ∀ ∃ ∀`. For instance,
`∀ᶠ n in at_top.curry at_top, p n ↔ ∃ M, ∀ m ≥ M, ∃ N, ∀ n ≥ N, p (m, n)`.

This is different from a product filter, which instead yields a quantifier order `∃ ∃ ∀ ∀`. For
instance, `∀ᶠ n in at_top ×ᶠ at_top, p n ↔ ∃ M, ∃ N, ∀ m ≥ M, ∀ n ≥ N, p (m, n)`. This makes it
clear that if something eventually occurs on the product filter, it eventually occurs on the curried
filter (see `filter.curry_le_prod` and `filter.eventually.curry`), but the converse is not true.

Another way to think about the curried versus the product filter is that tending to some limit on
the product filter is a version of uniform convergence (see `tendsto_prod_filter_iff`) whereas
tending to some limit on a curried filter is just iterated limits (see `tendsto.curry`).

## Main definitions

* `filter.curry`: A binary operation on filters which represents iterated limits

## Main statements

* `filter.eventually_curry_iff`: An alternative definition of a curried filter
* `filter.curry_le_prod`: Something that is eventually true on the a product filter is eventually
   true on the curried filter

## Tags

uniform convergence, curried filters, product filters
-/


namespace Filter

variable {α β γ : Type _}

#print Filter.curry /-
/-- This filter is characterized by `filter.eventually_curry_iff`:
`(∀ᶠ (x : α × β) in f.curry g, p x) ↔ ∀ᶠ (x : α) in f, ∀ᶠ (y : β) in g, p (x, y)`. Useful
in adding quantifiers to the middle of `tendsto`s. See
`has_fderiv_at_of_tendsto_uniformly_on_filter`. -/
def curry (f : Filter α) (g : Filter β) : Filter (α × β)
    where
  sets := {s | ∀ᶠ a : α in f, ∀ᶠ b : β in g, (a, b) ∈ s}
  univ_sets := by simp only [Set.mem_setOf_eq, Set.mem_univ, eventually_true]
  sets_of_superset := by
    intro x y hx hxy
    simp only [Set.mem_setOf_eq] at hx ⊢
    exact hx.mono fun a ha => ha.mono fun b hb => Set.mem_of_subset_of_mem hxy hb
  inter_sets := by
    intro x y hx hy
    simp only [Set.mem_setOf_eq, Set.mem_inter_iff] at hx hy ⊢
    exact (hx.and hy).mono fun a ha => (ha.1.And ha.2).mono fun b hb => hb
#align filter.curry Filter.curry
-/

#print Filter.eventually_curry_iff /-
theorem eventually_curry_iff {f : Filter α} {g : Filter β} {p : α × β → Prop} :
    (∀ᶠ x : α × β in f.curry g, p x) ↔ ∀ᶠ x : α in f, ∀ᶠ y : β in g, p (x, y) :=
  Iff.rfl
#align filter.eventually_curry_iff Filter.eventually_curry_iff
-/

#print Filter.curry_le_prod /-
theorem curry_le_prod {f : Filter α} {g : Filter β} : f.curry g ≤ f.Prod g :=
  by
  intro u hu
  rw [← eventually_mem_set] at hu ⊢
  rw [eventually_curry_iff]
  exact hu.curry
#align filter.curry_le_prod Filter.curry_le_prod
-/

#print Filter.Tendsto.curry /-
theorem Tendsto.curry {f : α → β → γ} {la : Filter α} {lb : Filter β} {lc : Filter γ} :
    (∀ᶠ a in la, Tendsto (fun b : β => f a b) lb lc) → Tendsto (↿f) (la.curry lb) lc :=
  by
  intro h
  rw [tendsto_def]
  simp only [curry, Filter.mem_mk, Set.mem_setOf_eq, Set.mem_preimage]
  simp_rw [tendsto_def] at h 
  refine' fun s hs => h.mono fun a ha => eventually_iff.mpr _
  simpa [Function.HasUncurry.uncurry, Set.preimage] using ha s hs
#align filter.tendsto.curry Filter.Tendsto.curry
-/

end Filter

