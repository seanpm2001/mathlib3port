/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov, Yaël Dillies

! This file was ported from Lean 3 source module algebra.ring.order_synonym
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Ring.Defs
import Mathbin.Algebra.Group.OrderSynonym

/-!
# Ring structure on the order type synonyms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Transfer algebraic instances from `α` to `αᵒᵈ` and `lex α`.
-/


variable {α : Type _}

/-! ### Order dual -/


instance [h : Distrib α] : Distrib αᵒᵈ :=
  h

instance [Mul α] [Add α] [h : LeftDistribClass α] : LeftDistribClass αᵒᵈ :=
  h

instance [Mul α] [Add α] [h : RightDistribClass α] : RightDistribClass αᵒᵈ :=
  h

instance [h : NonUnitalNonAssocSemiring α] : NonUnitalNonAssocSemiring αᵒᵈ :=
  h

instance [h : NonUnitalSemiring α] : NonUnitalSemiring αᵒᵈ :=
  h

instance [h : NonAssocSemiring α] : NonAssocSemiring αᵒᵈ :=
  h

instance [h : Semiring α] : Semiring αᵒᵈ :=
  h

instance [h : NonUnitalCommSemiring α] : NonUnitalCommSemiring αᵒᵈ :=
  h

instance [h : CommSemiring α] : CommSemiring αᵒᵈ :=
  h

instance [Mul α] [h : HasDistribNeg α] : HasDistribNeg αᵒᵈ :=
  h

instance [h : NonUnitalNonAssocRing α] : NonUnitalNonAssocRing αᵒᵈ :=
  h

instance [h : NonUnitalRing α] : NonUnitalRing αᵒᵈ :=
  h

instance [h : NonAssocRing α] : NonAssocRing αᵒᵈ :=
  h

instance [h : Ring α] : Ring αᵒᵈ :=
  h

instance [h : NonUnitalCommRing α] : NonUnitalCommRing αᵒᵈ :=
  h

instance [h : CommRing α] : CommRing αᵒᵈ :=
  h

instance [Ring α] [h : IsDomain α] : IsDomain αᵒᵈ :=
  h

/-! ### Lexicographical order -/


instance [h : Distrib α] : Distrib (Lex α) :=
  h

instance [Mul α] [Add α] [h : LeftDistribClass α] : LeftDistribClass (Lex α) :=
  h

instance [Mul α] [Add α] [h : RightDistribClass α] : RightDistribClass (Lex α) :=
  h

instance [h : NonUnitalNonAssocSemiring α] : NonUnitalNonAssocSemiring (Lex α) :=
  h

instance [h : NonUnitalSemiring α] : NonUnitalSemiring (Lex α) :=
  h

instance [h : NonAssocSemiring α] : NonAssocSemiring (Lex α) :=
  h

instance [h : Semiring α] : Semiring (Lex α) :=
  h

instance [h : NonUnitalCommSemiring α] : NonUnitalCommSemiring (Lex α) :=
  h

instance [h : CommSemiring α] : CommSemiring (Lex α) :=
  h

instance [Mul α] [h : HasDistribNeg α] : HasDistribNeg (Lex α) :=
  h

instance [h : NonUnitalNonAssocRing α] : NonUnitalNonAssocRing (Lex α) :=
  h

instance [h : NonUnitalRing α] : NonUnitalRing (Lex α) :=
  h

instance [h : NonAssocRing α] : NonAssocRing (Lex α) :=
  h

instance [h : Ring α] : Ring (Lex α) :=
  h

instance [h : NonUnitalCommRing α] : NonUnitalCommRing (Lex α) :=
  h

instance [h : CommRing α] : CommRing (Lex α) :=
  h

instance [Ring α] [h : IsDomain α] : IsDomain (Lex α) :=
  h

