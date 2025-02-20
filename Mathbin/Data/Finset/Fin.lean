/-
Copyright (c) 2018 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes, Scott Morrison, Johan Commelin

! This file was ported from Lean 3 source module data.finset.fin
! leanprover-community/mathlib commit e04043d6bf7264a3c84bc69711dc354958ca4516
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Finset.Card

/-!
# Finsets in `fin n`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A few constructions for finsets in `fin n`.

## Main declarations

* `finset.attach_fin`: Turns a finset of naturals strictly less than `n` into a `finset (fin n)`.
-/


variable {n : ℕ}

namespace Finset

#print Finset.attachFin /-
/-- Given a finset `s` of `ℕ` contained in `{0,..., n-1}`, the corresponding finset in `fin n`
is `s.attach_fin h` where `h` is a proof that all elements of `s` are less than `n`. -/
def attachFin (s : Finset ℕ) {n : ℕ} (h : ∀ m ∈ s, m < n) : Finset (Fin n) :=
  ⟨s.1.pmap (fun a ha => ⟨a, ha⟩) h, s.Nodup.pmap fun _ _ _ _ => Fin.veq_of_eq⟩
#align finset.attach_fin Finset.attachFin
-/

#print Finset.mem_attachFin /-
@[simp]
theorem mem_attachFin {n : ℕ} {s : Finset ℕ} (h : ∀ m ∈ s, m < n) {a : Fin n} :
    a ∈ s.attachFin h ↔ (a : ℕ) ∈ s :=
  ⟨fun h =>
    let ⟨b, hb₁, hb₂⟩ := Multiset.mem_pmap.1 h
    hb₂ ▸ hb₁,
    fun h => Multiset.mem_pmap.2 ⟨a, h, Fin.eta _ _⟩⟩
#align finset.mem_attach_fin Finset.mem_attachFin
-/

#print Finset.card_attachFin /-
@[simp]
theorem card_attachFin {n : ℕ} (s : Finset ℕ) (h : ∀ m ∈ s, m < n) :
    (s.attachFin h).card = s.card :=
  Multiset.card_pmap _ _ _
#align finset.card_attach_fin Finset.card_attachFin
-/

end Finset

