/-
Copyright (c) 2022 Damiano Testa. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Damiano Testa

! This file was ported from Lean 3 source module algebra.monoid_algebra.degree
! leanprover-community/mathlib commit 932872382355f00112641d305ba0619305dc8642
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.MonoidAlgebra.Support

/-!
# Lemmas about the `sup` and `inf` of the support of `add_monoid_algebra`

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## TODO
The current plan is to state and prove lemmas about `finset.sup (finsupp.support f) D` with a
"generic" degree/weight function `D` from the grading Type `A` to a somewhat ordered Type `B`.

Next, the general lemmas get specialized for some yet-to-be-defined `degree`s.
-/


variable {R A T B ι : Type _}

namespace AddMonoidAlgebra

open scoped Classical BigOperators

/-! ### Results about the `finset.sup` and `finset.inf` of `finsupp.support` -/


section GeneralResultsAssumingSemilatticeSup

variable [SemilatticeSup B] [OrderBot B] [SemilatticeInf T] [OrderTop T]

section Semiring

variable [Semiring R]

section ExplicitDegrees

/-!

In this section, we use `degb` and `degt` to denote "degree functions" on `A` with values in
a type with *b*ot or *t*op respectively.
-/


variable (degb : A → B) (degt : A → T) (f g : AddMonoidAlgebra R A)

#print AddMonoidAlgebra.sup_support_add_le /-
theorem sup_support_add_le : (f + g).support.sup degb ≤ f.support.sup degb ⊔ g.support.sup degb :=
  (Finset.sup_mono Finsupp.support_add).trans_eq Finset.sup_union
#align add_monoid_algebra.sup_support_add_le AddMonoidAlgebra.sup_support_add_le
-/

#print AddMonoidAlgebra.le_inf_support_add /-
theorem le_inf_support_add : f.support.inf degt ⊓ g.support.inf degt ≤ (f + g).support.inf degt :=
  sup_support_add_le (fun a : A => OrderDual.toDual (degt a)) f g
#align add_monoid_algebra.le_inf_support_add AddMonoidAlgebra.le_inf_support_add
-/

end ExplicitDegrees

section AddOnly

variable [Add A] [Add B] [Add T] [CovariantClass B B (· + ·) (· ≤ ·)]
  [CovariantClass B B (Function.swap (· + ·)) (· ≤ ·)] [CovariantClass T T (· + ·) (· ≤ ·)]
  [CovariantClass T T (Function.swap (· + ·)) (· ≤ ·)]

#print AddMonoidAlgebra.sup_support_mul_le /-
theorem sup_support_mul_le {degb : A → B} (degbm : ∀ {a b}, degb (a + b) ≤ degb a + degb b)
    (f g : AddMonoidAlgebra R A) :
    (f * g).support.sup degb ≤ f.support.sup degb + g.support.sup degb :=
  by
  refine' (Finset.sup_mono <| support_mul _ _).trans _
  simp_rw [Finset.sup_biUnion, Finset.sup_singleton]
  refine' Finset.sup_le fun fd fds => Finset.sup_le fun gd gds => degbm.trans <| add_le_add _ _ <;>
    exact Finset.le_sup ‹_›
#align add_monoid_algebra.sup_support_mul_le AddMonoidAlgebra.sup_support_mul_le
-/

#print AddMonoidAlgebra.le_inf_support_mul /-
theorem le_inf_support_mul {degt : A → T} (degtm : ∀ {a b}, degt a + degt b ≤ degt (a + b))
    (f g : AddMonoidAlgebra R A) :
    f.support.inf degt + g.support.inf degt ≤ (f * g).support.inf degt :=
  OrderDual.ofDual_le_ofDual.mpr <|
    sup_support_mul_le (fun a b => OrderDual.ofDual_le_ofDual.mp degtm) f g
#align add_monoid_algebra.le_inf_support_mul AddMonoidAlgebra.le_inf_support_mul
-/

end AddOnly

section AddMonoids

variable [AddMonoid A] [AddMonoid B] [CovariantClass B B (· + ·) (· ≤ ·)]
  [CovariantClass B B (Function.swap (· + ·)) (· ≤ ·)] [AddMonoid T]
  [CovariantClass T T (· + ·) (· ≤ ·)] [CovariantClass T T (Function.swap (· + ·)) (· ≤ ·)]
  {degb : A → B} {degt : A → T}

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print AddMonoidAlgebra.sup_support_list_prod_le /-
theorem sup_support_list_prod_le (degb0 : degb 0 ≤ 0)
    (degbm : ∀ a b, degb (a + b) ≤ degb a + degb b) :
    ∀ l : List (AddMonoidAlgebra R A),
      l.Prod.support.sup degb ≤ (l.map fun f : AddMonoidAlgebra R A => f.support.sup degb).Sum
  | [] => by
    rw [List.map_nil, Finset.sup_le_iff, List.prod_nil, List.sum_nil]
    exact fun a ha => by rwa [finset.mem_singleton.mp (Finsupp.support_single_subset ha)]
  | f::fs => by
    rw [List.prod_cons, List.map_cons, List.sum_cons]
    exact (sup_support_mul_le degbm _ _).trans (add_le_add_left (sup_support_list_prod_le _) _)
#align add_monoid_algebra.sup_support_list_prod_le AddMonoidAlgebra.sup_support_list_prod_le
-/

#print AddMonoidAlgebra.le_inf_support_list_prod /-
theorem le_inf_support_list_prod (degt0 : 0 ≤ degt 0)
    (degtm : ∀ a b, degt a + degt b ≤ degt (a + b)) (l : List (AddMonoidAlgebra R A)) :
    (l.map fun f : AddMonoidAlgebra R A => f.support.inf degt).Sum ≤ l.Prod.support.inf degt :=
  OrderDual.ofDual_le_ofDual.mpr <|
    sup_support_list_prod_le (OrderDual.ofDual_le_ofDual.mp degt0)
      (fun a b => OrderDual.ofDual_le_ofDual.mp (degtm _ _)) l
#align add_monoid_algebra.le_inf_support_list_prod AddMonoidAlgebra.le_inf_support_list_prod
-/

#print AddMonoidAlgebra.sup_support_pow_le /-
theorem sup_support_pow_le (degb0 : degb 0 ≤ 0) (degbm : ∀ a b, degb (a + b) ≤ degb a + degb b)
    (n : ℕ) (f : AddMonoidAlgebra R A) : (f ^ n).support.sup degb ≤ n • f.support.sup degb :=
  by
  rw [← List.prod_replicate, ← List.sum_replicate]
  refine' (sup_support_list_prod_le degb0 degbm _).trans_eq _
  rw [List.map_replicate]
#align add_monoid_algebra.sup_support_pow_le AddMonoidAlgebra.sup_support_pow_le
-/

#print AddMonoidAlgebra.le_inf_support_pow /-
theorem le_inf_support_pow (degt0 : 0 ≤ degt 0) (degtm : ∀ a b, degt a + degt b ≤ degt (a + b))
    (n : ℕ) (f : AddMonoidAlgebra R A) : n • f.support.inf degt ≤ (f ^ n).support.inf degt :=
  OrderDual.ofDual_le_ofDual.mpr <|
    sup_support_pow_le (OrderDual.ofDual_le_ofDual.mp degt0)
      (fun a b => OrderDual.ofDual_le_ofDual.mp (degtm _ _)) n f
#align add_monoid_algebra.le_inf_support_pow AddMonoidAlgebra.le_inf_support_pow
-/

end AddMonoids

end Semiring

section CommutativeLemmas

variable [CommSemiring R] [AddCommMonoid A] [AddCommMonoid B] [CovariantClass B B (· + ·) (· ≤ ·)]
  [CovariantClass B B (Function.swap (· + ·)) (· ≤ ·)] [AddCommMonoid T]
  [CovariantClass T T (· + ·) (· ≤ ·)] [CovariantClass T T (Function.swap (· + ·)) (· ≤ ·)]
  {degb : A → B} {degt : A → T}

#print AddMonoidAlgebra.sup_support_multiset_prod_le /-
theorem sup_support_multiset_prod_le (degb0 : degb 0 ≤ 0)
    (degbm : ∀ a b, degb (a + b) ≤ degb a + degb b) (m : Multiset (AddMonoidAlgebra R A)) :
    m.Prod.support.sup degb ≤ (m.map fun f : AddMonoidAlgebra R A => f.support.sup degb).Sum :=
  by
  induction m using Quot.inductionOn
  rw [Multiset.quot_mk_to_coe'', Multiset.coe_map, Multiset.coe_sum, Multiset.coe_prod]
  exact sup_support_list_prod_le degb0 degbm m
#align add_monoid_algebra.sup_support_multiset_prod_le AddMonoidAlgebra.sup_support_multiset_prod_le
-/

#print AddMonoidAlgebra.le_inf_support_multiset_prod /-
theorem le_inf_support_multiset_prod (degt0 : 0 ≤ degt 0)
    (degtm : ∀ a b, degt a + degt b ≤ degt (a + b)) (m : Multiset (AddMonoidAlgebra R A)) :
    (m.map fun f : AddMonoidAlgebra R A => f.support.inf degt).Sum ≤ m.Prod.support.inf degt :=
  OrderDual.ofDual_le_ofDual.mpr <|
    sup_support_multiset_prod_le (OrderDual.ofDual_le_ofDual.mp degt0)
      (fun a b => OrderDual.ofDual_le_ofDual.mp (degtm _ _)) m
#align add_monoid_algebra.le_inf_support_multiset_prod AddMonoidAlgebra.le_inf_support_multiset_prod
-/

#print AddMonoidAlgebra.sup_support_finset_prod_le /-
theorem sup_support_finset_prod_le (degb0 : degb 0 ≤ 0)
    (degbm : ∀ a b, degb (a + b) ≤ degb a + degb b) (s : Finset ι) (f : ι → AddMonoidAlgebra R A) :
    (∏ i in s, f i).support.sup degb ≤ ∑ i in s, (f i).support.sup degb :=
  (sup_support_multiset_prod_le degb0 degbm _).trans_eq <| congr_arg _ <| Multiset.map_map _ _ _
#align add_monoid_algebra.sup_support_finset_prod_le AddMonoidAlgebra.sup_support_finset_prod_le
-/

#print AddMonoidAlgebra.le_inf_support_finset_prod /-
theorem le_inf_support_finset_prod (degt0 : 0 ≤ degt 0)
    (degtm : ∀ a b, degt a + degt b ≤ degt (a + b)) (s : Finset ι) (f : ι → AddMonoidAlgebra R A) :
    ∑ i in s, (f i).support.inf degt ≤ (∏ i in s, f i).support.inf degt :=
  le_of_eq_of_le (by rw [Multiset.map_map] <;> rfl) (le_inf_support_multiset_prod degt0 degtm _)
#align add_monoid_algebra.le_inf_support_finset_prod AddMonoidAlgebra.le_inf_support_finset_prod
-/

end CommutativeLemmas

end GeneralResultsAssumingSemilatticeSup

end AddMonoidAlgebra

