/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Callum Sutton, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.big_operators.ring_equiv
! leanprover-community/mathlib commit 327c3c0d9232d80e250dc8f65e7835b82b266ea5
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Basic
import Mathbin.Algebra.Ring.Equiv

/-!
# Results about mapping big operators across ring equivalences

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


namespace RingEquiv

open scoped BigOperators

variable {α R S : Type _}

#print RingEquiv.map_list_prod /-
protected theorem map_list_prod [Semiring R] [Semiring S] (f : R ≃+* S) (l : List R) :
    f l.Prod = (l.map f).Prod :=
  map_list_prod f l
#align ring_equiv.map_list_prod RingEquiv.map_list_prod
-/

#print RingEquiv.map_list_sum /-
protected theorem map_list_sum [NonAssocSemiring R] [NonAssocSemiring S] (f : R ≃+* S)
    (l : List R) : f l.Sum = (l.map f).Sum :=
  map_list_sum f l
#align ring_equiv.map_list_sum RingEquiv.map_list_sum
-/

#print RingEquiv.unop_map_list_prod /-
/-- An isomorphism into the opposite ring acts on the product by acting on the reversed elements -/
protected theorem unop_map_list_prod [Semiring R] [Semiring S] (f : R ≃+* Sᵐᵒᵖ) (l : List R) :
    MulOpposite.unop (f l.Prod) = (l.map (MulOpposite.unop ∘ f)).reverse.Prod :=
  unop_map_list_prod f l
#align ring_equiv.unop_map_list_prod RingEquiv.unop_map_list_prod
-/

#print RingEquiv.map_multiset_prod /-
protected theorem map_multiset_prod [CommSemiring R] [CommSemiring S] (f : R ≃+* S)
    (s : Multiset R) : f s.Prod = (s.map f).Prod :=
  map_multiset_prod f s
#align ring_equiv.map_multiset_prod RingEquiv.map_multiset_prod
-/

#print RingEquiv.map_multiset_sum /-
protected theorem map_multiset_sum [NonAssocSemiring R] [NonAssocSemiring S] (f : R ≃+* S)
    (s : Multiset R) : f s.Sum = (s.map f).Sum :=
  map_multiset_sum f s
#align ring_equiv.map_multiset_sum RingEquiv.map_multiset_sum
-/

#print RingEquiv.map_prod /-
protected theorem map_prod [CommSemiring R] [CommSemiring S] (g : R ≃+* S) (f : α → R)
    (s : Finset α) : g (∏ x in s, f x) = ∏ x in s, g (f x) :=
  map_prod g f s
#align ring_equiv.map_prod RingEquiv.map_prod
-/

#print RingEquiv.map_sum /-
protected theorem map_sum [NonAssocSemiring R] [NonAssocSemiring S] (g : R ≃+* S) (f : α → R)
    (s : Finset α) : g (∑ x in s, f x) = ∑ x in s, g (f x) :=
  map_sum g f s
#align ring_equiv.map_sum RingEquiv.map_sum
-/

end RingEquiv

