/-
Copyright (c) 2022 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.star.prod
! leanprover-community/mathlib commit 9abfa6f0727d5adc99067e325e15d1a9de17fd8e
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Star.Basic
import Mathbin.Algebra.Ring.Prod
import Mathbin.Algebra.Module.Prod

/-!
# `star` on product types

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We put a `has_star` structure on product types that operates elementwise.
-/


universe u v w

variable {R : Type u} {S : Type v}

namespace Prod

instance [Star R] [Star S] : Star (R × S) where unit x := (star x.1, star x.2)

#print Prod.fst_star /-
@[simp]
theorem fst_star [Star R] [Star S] (x : R × S) : (star x).1 = star x.1 :=
  rfl
#align prod.fst_star Prod.fst_star
-/

#print Prod.snd_star /-
@[simp]
theorem snd_star [Star R] [Star S] (x : R × S) : (star x).2 = star x.2 :=
  rfl
#align prod.snd_star Prod.snd_star
-/

#print Prod.star_def /-
theorem star_def [Star R] [Star S] (x : R × S) : star x = (star x.1, star x.2) :=
  rfl
#align prod.star_def Prod.star_def
-/

instance [Star R] [Star S] [TrivialStar R] [TrivialStar S] : TrivialStar (R × S)
    where star_trivial _ := Prod.ext (star_trivial _) (star_trivial _)

instance [InvolutiveStar R] [InvolutiveStar S] : InvolutiveStar (R × S)
    where star_involutive _ := Prod.ext (star_star _) (star_star _)

instance [Semigroup R] [Semigroup S] [StarSemigroup R] [StarSemigroup S] : StarSemigroup (R × S)
    where star_mul _ _ := Prod.ext (star_mul _ _) (star_mul _ _)

instance [AddMonoid R] [AddMonoid S] [StarAddMonoid R] [StarAddMonoid S] : StarAddMonoid (R × S)
    where star_add _ _ := Prod.ext (star_add _ _) (star_add _ _)

instance [NonUnitalSemiring R] [NonUnitalSemiring S] [StarRing R] [StarRing S] : StarRing (R × S) :=
  { Prod.starAddMonoid, (Prod.starSemigroup : StarSemigroup (R × S)) with }

instance {α : Type w} [SMul α R] [SMul α S] [Star α] [Star R] [Star S] [StarModule α R]
    [StarModule α S] : StarModule α (R × S)
    where star_smul r x := Prod.ext (star_smul _ _) (star_smul _ _)

end Prod

#print Units.embed_product_star /-
@[simp]
theorem Units.embed_product_star [Monoid R] [StarSemigroup R] (u : Rˣ) :
    Units.embedProduct R (star u) = star (Units.embedProduct R u) :=
  rfl
#align units.embed_product_star Units.embed_product_star
-/

