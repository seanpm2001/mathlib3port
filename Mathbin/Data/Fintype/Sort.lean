/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.fintype.sort
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.Sort
import Mathbin.Data.Fintype.Basic

/-!
# Sorting a finite type

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file provides two equivalences for linearly ordered fintypes:
* `mono_equiv_of_fin`: Order isomorphism between `α` and `fin (card α)`.
* `fin_sum_equiv_of_finset`: Equivalence between `α` and `fin m ⊕ fin n` where `m` and `n` are
  respectively the cardinalities of some `finset α` and its complement.
-/


open Finset

#print monoEquivOfFin /-
/-- Given a linearly ordered fintype `α` of cardinal `k`, the order isomorphism
`mono_equiv_of_fin α h` is the increasing bijection between `fin k` and `α`. Here, `h` is a proof
that the cardinality of `α` is `k`. We use this instead of an isomorphism `fin (card α) ≃o α` to
avoid casting issues in further uses of this function. -/
def monoEquivOfFin (α : Type _) [Fintype α] [LinearOrder α] {k : ℕ} (h : Fintype.card α = k) :
    Fin k ≃o α :=
  (univ.orderIsoOfFin h).trans <| (OrderIso.setCongr _ _ coe_univ).trans OrderIso.Set.univ
#align mono_equiv_of_fin monoEquivOfFin
-/

variable {α : Type _} [DecidableEq α] [Fintype α] [LinearOrder α] {m n : ℕ} {s : Finset α}

#print finSumEquivOfFinset /-
/-- If `α` is a linearly ordered fintype, `s : finset α` has cardinality `m` and its complement has
cardinality `n`, then `fin m ⊕ fin n ≃ α`. The equivalence sends elements of `fin m` to
elements of `s` and elements of `fin n` to elements of `sᶜ` while preserving order on each
"half" of `fin m ⊕ fin n` (using `set.order_iso_of_fin`). -/
def finSumEquivOfFinset (hm : s.card = m) (hn : sᶜ.card = n) : Sum (Fin m) (Fin n) ≃ α :=
  calc
    Sum (Fin m) (Fin n) ≃ Sum (s : Set α) (sᶜ : Set α) :=
      Equiv.sumCongr (s.orderIsoOfFin hm).toEquiv <|
        (sᶜ.orderIsoOfFin hn).toEquiv.trans <| Equiv.Set.ofEq s.coe_compl
    _ ≃ α := Equiv.Set.sumCompl _
#align fin_sum_equiv_of_finset finSumEquivOfFinset
-/

#print finSumEquivOfFinset_inl /-
@[simp]
theorem finSumEquivOfFinset_inl (hm : s.card = m) (hn : sᶜ.card = n) (i : Fin m) :
    finSumEquivOfFinset hm hn (Sum.inl i) = s.orderEmbOfFin hm i :=
  rfl
#align fin_sum_equiv_of_finset_inl finSumEquivOfFinset_inl
-/

#print finSumEquivOfFinset_inr /-
@[simp]
theorem finSumEquivOfFinset_inr (hm : s.card = m) (hn : sᶜ.card = n) (i : Fin n) :
    finSumEquivOfFinset hm hn (Sum.inr i) = sᶜ.orderEmbOfFin hn i :=
  rfl
#align fin_sum_equiv_of_finset_inr finSumEquivOfFinset_inr
-/

