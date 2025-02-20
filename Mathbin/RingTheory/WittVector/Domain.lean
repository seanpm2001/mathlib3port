/-
Copyright (c) 2022 Robert Y. Lewis. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Robert Y. Lewis

! This file was ported from Lean 3 source module ring_theory.witt_vector.domain
! leanprover-community/mathlib commit 9240e8be927a0955b9a82c6c85ef499ee3a626b8
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.RingTheory.WittVector.Identities

/-!

# Witt vectors over a domain

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file builds to the proof `witt_vector.is_domain`,
an instance that says if `R` is an integral domain, then so is `𝕎 R`.
It depends on the API around iterated applications
of `witt_vector.verschiebung` and `witt_vector.frobenius`
found in `identities.lean`.

The [proof sketch](https://math.stackexchange.com/questions/4117247/ring-of-witt-vectors-over-an-integral-domain/4118723#4118723)
goes as follows:
any nonzero $x$ is an iterated application of $V$
to some vector $w_x$ whose 0th component is nonzero (`witt_vector.verschiebung_nonzero`).
Known identities (`witt_vector.iterate_verschiebung_mul`) allow us to transform
the product of two such $x$ and $y$
to the form $V^{m+n}\left(F^n(w_x) \cdot F^m(w_y)\right)$,
the 0th component of which must be nonzero.

## Main declarations

* `witt_vector.iterate_verschiebung_mul_coeff` : an identity from [Haze09]
* `witt_vector.is_domain`

-/


noncomputable section

open scoped Classical

namespace WittVector

open Function

variable {p : ℕ} {R : Type _}

local notation "𝕎" => WittVector p

/-!
## The `shift` operator
-/


#print WittVector.shift /-
-- type as `\bbW`
/--
`witt_vector.verschiebung` translates the entries of a Witt vector upward, inserting 0s in the gaps.
`witt_vector.shift` does the opposite, removing the first entries.
This is mainly useful as an auxiliary construction for `witt_vector.verschiebung_nonzero`.
-/
def shift (x : 𝕎 R) (n : ℕ) : 𝕎 R :=
  mk' p fun i => x.coeff (n + i)
#align witt_vector.shift WittVector.shift
-/

#print WittVector.shift_coeff /-
theorem shift_coeff (x : 𝕎 R) (n k : ℕ) : (x.shift n).coeff k = x.coeff (n + k) :=
  rfl
#align witt_vector.shift_coeff WittVector.shift_coeff
-/

variable [hp : Fact p.Prime] [CommRing R]

#print WittVector.verschiebung_shift /-
theorem verschiebung_shift (x : 𝕎 R) (k : ℕ) (h : ∀ i < k + 1, x.coeff i = 0) :
    verschiebung (x.shift k.succ) = x.shift k :=
  by
  ext ⟨j⟩
  · rw [verschiebung_coeff_zero, shift_coeff, h]
    apply Nat.lt_succ_self
  · simp only [verschiebung_coeff_succ, shift]
    congr 1
    rw [Nat.add_succ, add_comm, Nat.add_succ, add_comm]
#align witt_vector.verschiebung_shift WittVector.verschiebung_shift
-/

#print WittVector.eq_iterate_verschiebung /-
theorem eq_iterate_verschiebung {x : 𝕎 R} {n : ℕ} (h : ∀ i < n, x.coeff i = 0) :
    x = (verschiebung^[n]) (x.shift n) :=
  by
  induction' n with k ih
  · cases x <;> simp [shift]
  · dsimp; rw [verschiebung_shift]
    · exact ih fun i hi => h _ (hi.trans (Nat.lt_succ_self _))
    · exact h
#align witt_vector.eq_iterate_verschiebung WittVector.eq_iterate_verschiebung
-/

#print WittVector.verschiebung_nonzero /-
theorem verschiebung_nonzero {x : 𝕎 R} (hx : x ≠ 0) :
    ∃ n : ℕ, ∃ x' : 𝕎 R, x'.coeff 0 ≠ 0 ∧ x = (verschiebung^[n]) x' :=
  by
  have hex : ∃ k : ℕ, x.coeff k ≠ 0 := by
    by_contra' hall
    apply hx
    ext i
    simp only [hall, zero_coeff]
  let n := Nat.find hex
  use n, x.shift n
  refine' ⟨Nat.find_spec hex, eq_iterate_verschiebung fun i hi => not_not.mp _⟩
  exact Nat.find_min hex hi
#align witt_vector.verschiebung_nonzero WittVector.verschiebung_nonzero
-/

/-!
## Witt vectors over a domain

If `R` is an integral domain, then so is `𝕎 R`.
This argument is adapted from
<https://math.stackexchange.com/questions/4117247/ring-of-witt-vectors-over-an-integral-domain/4118723#4118723>.
-/


instance [CharP R p] [NoZeroDivisors R] : NoZeroDivisors (𝕎 R) :=
  ⟨fun x y => by
    contrapose!
    rintro ⟨ha, hb⟩
    rcases verschiebung_nonzero ha with ⟨na, wa, hwa0, rfl⟩
    rcases verschiebung_nonzero hb with ⟨nb, wb, hwb0, rfl⟩
    refine' ne_of_apply_ne (fun x => x.coeff (na + nb)) _
    rw [iterate_verschiebung_mul_coeff, zero_coeff]
    refine' mul_ne_zero (pow_ne_zero _ hwa0) (pow_ne_zero _ hwb0)⟩

instance [CharP R p] [IsDomain R] : IsDomain (𝕎 R) :=
  NoZeroDivisors.to_isDomain _

end WittVector

