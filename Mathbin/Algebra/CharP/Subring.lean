/-
Copyright (c) 2020 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module algebra.char_p.subring
! leanprover-community/mathlib commit 10bf4f825ad729c5653adc039dafa3622e7f93c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.CharP.Basic
import Mathbin.RingTheory.Subring.Basic

/-!
# Characteristic of subrings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


universe u v

namespace CharP

#print CharP.subsemiring /-
instance subsemiring (R : Type u) [Semiring R] (p : ℕ) [CharP R p] (S : Subsemiring R) :
    CharP S p :=
  ⟨fun x =>
    Iff.symm <|
      (CharP.cast_eq_zero_iff R p x).symm.trans
        ⟨fun h => Subtype.eq <| show S.Subtype x = 0 by rw [map_natCast, h], fun h =>
          map_natCast S.Subtype x ▸ by rw [h, RingHom.map_zero]⟩⟩
#align char_p.subsemiring CharP.subsemiring
-/

#print CharP.subring /-
instance subring (R : Type u) [Ring R] (p : ℕ) [CharP R p] (S : Subring R) : CharP S p :=
  ⟨fun x =>
    Iff.symm <|
      (CharP.cast_eq_zero_iff R p x).symm.trans
        ⟨fun h => Subtype.eq <| show S.Subtype x = 0 by rw [map_natCast, h], fun h =>
          map_natCast S.Subtype x ▸ by rw [h, RingHom.map_zero]⟩⟩
#align char_p.subring CharP.subring
-/

#print CharP.subring' /-
instance subring' (R : Type u) [CommRing R] (p : ℕ) [CharP R p] (S : Subring R) : CharP S p :=
  CharP.subring R p S
#align char_p.subring' CharP.subring'
-/

end CharP

