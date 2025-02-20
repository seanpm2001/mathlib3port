/-
Copyright (c) 2022 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module data.fin.tuple.nat_antidiagonal
! leanprover-community/mathlib commit 34ee86e6a59d911a8e4f89b68793ee7577ae79c7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.BigOperators.Fin
import Mathbin.Data.Finset.NatAntidiagonal
import Mathbin.Data.Fin.VecNotation
import Mathbin.Logic.Equiv.Fin

/-!
# Collections of tuples of naturals with the same sum

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file generalizes `list.nat.antidiagonal n`, `multiset.nat.antidiagonal n`, and
`finset.nat.antidiagonal n` from the pair of elements `x : ℕ × ℕ` such that `n = x.1 + x.2`, to
the sequence of elements `x : fin k → ℕ` such that `n = ∑ i, x i`.

## Main definitions

* `list.nat.antidiagonal_tuple`
* `multiset.nat.antidiagonal_tuple`
* `finset.nat.antidiagonal_tuple`

## Main results

* `antidiagonal_tuple 2 n` is analogous to `antidiagonal n`:

  * `list.nat.antidiagonal_tuple_two`
  * `multiset.nat.antidiagonal_tuple_two`
  * `finset.nat.antidiagonal_tuple_two`

## Implementation notes

While we could implement this by filtering `(fintype.pi_finset $ λ _, range (n + 1))` or similar,
this implementation would be much slower.

In the future, we could consider generalizing `finset.nat.antidiagonal_tuple` further to
support finitely-supported functions, as is done with `cut` in
`archive/100-theorems-list/45_partition.lean`.
-/


open scoped BigOperators

/-! ### Lists -/


namespace List.Nat

#print List.Nat.antidiagonalTuple /-
/-- `list.antidiagonal_tuple k n` is a list of all `k`-tuples which sum to `n`.

This list contains no duplicates (`list.nat.nodup_antidiagonal_tuple`), and is sorted
lexicographically (`list.nat.antidiagonal_tuple_pairwise_pi_lex`), starting with `![0, ..., n]`
and ending with `![n, ..., 0]`.

```
#eval antidiagonal_tuple 3 2
-- [![0, 0, 2], ![0, 1, 1], ![0, 2, 0], ![1, 0, 1], ![1, 1, 0], ![2, 0, 0]]
```
-/
def antidiagonalTuple : ∀ k, ℕ → List (Fin k → ℕ)
  | 0, 0 => [![]]
  | 0, n + 1 => []
  | k + 1, n =>
    (List.Nat.antidiagonal n).bind fun ni =>
      (antidiagonal_tuple k ni.2).map fun x => Fin.cons ni.1 x
#align list.nat.antidiagonal_tuple List.Nat.antidiagonalTuple
-/

#print List.Nat.antidiagonalTuple_zero_zero /-
@[simp]
theorem antidiagonalTuple_zero_zero : antidiagonalTuple 0 0 = [![]] :=
  rfl
#align list.nat.antidiagonal_tuple_zero_zero List.Nat.antidiagonalTuple_zero_zero
-/

#print List.Nat.antidiagonalTuple_zero_succ /-
@[simp]
theorem antidiagonalTuple_zero_succ (n : ℕ) : antidiagonalTuple 0 n.succ = [] :=
  rfl
#align list.nat.antidiagonal_tuple_zero_succ List.Nat.antidiagonalTuple_zero_succ
-/

#print List.Nat.mem_antidiagonalTuple /-
theorem mem_antidiagonalTuple {n : ℕ} {k : ℕ} {x : Fin k → ℕ} :
    x ∈ antidiagonalTuple k n ↔ ∑ i, x i = n :=
  by
  revert n
  refine' Fin.consInduction _ _ x
  · intro n
    cases n
    · simp
    · simp [eq_comm]
  · intro k x₀ x ih n
    simp_rw [Fin.sum_cons, antidiagonal_tuple, List.mem_bind, List.mem_map,
      List.Nat.mem_antidiagonal, Fin.cons_eq_cons, exists_eq_right_right, ih,
      @eq_comm _ _ (Prod.snd _), and_comm' (Prod.snd _ = _), ← Prod.mk.inj_iff, Prod.mk.eta,
      exists_prop, exists_eq_right]
#align list.nat.mem_antidiagonal_tuple List.Nat.mem_antidiagonalTuple
-/

#print List.Nat.nodup_antidiagonalTuple /-
/-- The antidiagonal of `n` does not contain duplicate entries. -/
theorem nodup_antidiagonalTuple (k n : ℕ) : List.Nodup (antidiagonalTuple k n) :=
  by
  induction' k with k ih generalizing n
  · cases n
    · simp
    · simp [eq_comm]
  simp_rw [antidiagonal_tuple, List.nodup_bind]
  constructor
  · intro i hi
    exact (ih i.snd).map (Fin.cons_right_injective (i.fst : (fun _ => ℕ) 0))
  induction n
  · exact List.pairwise_singleton _ _
  · rw [List.Nat.antidiagonal_succ]
    refine' List.Pairwise.cons (fun a ha x hx₁ hx₂ => _) (n_ih.map _ fun a b h x hx₁ hx₂ => _)
    · rw [List.mem_map] at hx₁ hx₂ ha 
      obtain ⟨⟨a, -, rfl⟩, ⟨x₁, -, rfl⟩, ⟨x₂, -, h⟩⟩ := ha, hx₁, hx₂
      rw [Fin.cons_eq_cons] at h 
      injection h.1
    · rw [List.mem_map] at hx₁ hx₂ 
      obtain ⟨⟨x₁, hx₁, rfl⟩, ⟨x₂, hx₂, h₁₂⟩⟩ := hx₁, hx₂
      dsimp at h₁₂ 
      rw [Fin.cons_eq_cons, Nat.succ_inj'] at h₁₂ 
      obtain ⟨h₁₂, rfl⟩ := h₁₂
      rw [h₁₂] at h 
      exact h (List.mem_map_of_mem _ hx₁) (List.mem_map_of_mem _ hx₂)
#align list.nat.nodup_antidiagonal_tuple List.Nat.nodup_antidiagonalTuple
-/

#print List.Nat.antidiagonalTuple_zero_right /-
theorem antidiagonalTuple_zero_right : ∀ k, antidiagonalTuple k 0 = [0]
  | 0 => (congr_arg fun x => [x]) <| Subsingleton.elim _ _
  | k + 1 =>
    by
    rw [antidiagonal_tuple, antidiagonal_zero, List.bind_singleton, antidiagonal_tuple_zero_right k,
      List.map_singleton]
    exact congr_arg (fun x => [x]) Matrix.cons_zero_zero
#align list.nat.antidiagonal_tuple_zero_right List.Nat.antidiagonalTuple_zero_right
-/

#print List.Nat.antidiagonalTuple_one /-
@[simp]
theorem antidiagonalTuple_one (n : ℕ) : antidiagonalTuple 1 n = [![n]] :=
  by
  simp_rw [antidiagonal_tuple, antidiagonal, List.range_succ, List.map_append, List.map_singleton,
    tsub_self, List.bind_append, List.bind_singleton, antidiagonal_tuple_zero_zero,
    List.map_singleton, List.map_bind]
  conv_rhs => rw [← List.nil_append [![n]]]
  congr 1
  simp_rw [List.bind_eq_nil, List.mem_range, List.map_eq_nil]
  intro x hx
  obtain ⟨m, rfl⟩ := Nat.exists_eq_add_of_lt hx
  rw [add_assoc, add_tsub_cancel_left, antidiagonal_tuple_zero_succ]
#align list.nat.antidiagonal_tuple_one List.Nat.antidiagonalTuple_one
-/

#print List.Nat.antidiagonalTuple_two /-
theorem antidiagonalTuple_two (n : ℕ) :
    antidiagonalTuple 2 n = (antidiagonal n).map fun i => ![i.1, i.2] :=
  by
  rw [antidiagonal_tuple]
  simp_rw [antidiagonal_tuple_one, List.map_singleton]
  rw [List.map_eq_bind]
  rfl
#align list.nat.antidiagonal_tuple_two List.Nat.antidiagonalTuple_two
-/

#print List.Nat.antidiagonalTuple_pairwise_pi_lex /-
theorem antidiagonalTuple_pairwise_pi_lex :
    ∀ k n, (antidiagonalTuple k n).Pairwise (Pi.Lex (· < ·) fun _ => (· < ·))
  | 0, 0 => List.pairwise_singleton _ _
  | 0, n + 1 => List.Pairwise.nil
  | k + 1, n =>
    by
    simp_rw [antidiagonal_tuple, List.pairwise_bind, List.pairwise_map', List.mem_map,
      forall_exists_index, and_imp, forall_apply_eq_imp_iff₂]
    simp only [mem_antidiagonal, Prod.forall, and_imp, forall_apply_eq_imp_iff₂]
    simp only [Fin.pi_lex_lt_cons_cons, eq_self_iff_true, true_and_iff, lt_self_iff_false,
      false_or_iff]
    refine' ⟨fun _ _ _ => antidiagonal_tuple_pairwise_pi_lex k _, _⟩
    induction n
    · rw [antidiagonal_zero]
      exact List.pairwise_singleton _ _
    · rw [antidiagonal_succ, List.pairwise_cons, List.pairwise_map']
      refine' ⟨fun p hp x hx y hy => _, _⟩
      · rw [List.mem_map, Prod.exists] at hp 
        obtain ⟨a, b, hab, rfl : (Nat.succ a, b) = p⟩ := hp
        exact Or.inl (Nat.zero_lt_succ _)
      dsimp
      simp_rw [Nat.succ_inj', Nat.succ_lt_succ_iff]
      exact n_ih
#align list.nat.antidiagonal_tuple_pairwise_pi_lex List.Nat.antidiagonalTuple_pairwise_pi_lex
-/

end List.Nat

/-! ### Multisets -/


namespace Multiset.Nat

#print Multiset.Nat.antidiagonalTuple /-
/-- `multiset.antidiagonal_tuple k n` is a multiset of `k`-tuples summing to `n` -/
def antidiagonalTuple (k n : ℕ) : Multiset (Fin k → ℕ) :=
  List.Nat.antidiagonalTuple k n
#align multiset.nat.antidiagonal_tuple Multiset.Nat.antidiagonalTuple
-/

#print Multiset.Nat.antidiagonalTuple_zero_zero /-
@[simp]
theorem antidiagonalTuple_zero_zero : antidiagonalTuple 0 0 = {![]} :=
  rfl
#align multiset.nat.antidiagonal_tuple_zero_zero Multiset.Nat.antidiagonalTuple_zero_zero
-/

#print Multiset.Nat.antidiagonalTuple_zero_succ /-
@[simp]
theorem antidiagonalTuple_zero_succ (n : ℕ) : antidiagonalTuple 0 n.succ = 0 :=
  rfl
#align multiset.nat.antidiagonal_tuple_zero_succ Multiset.Nat.antidiagonalTuple_zero_succ
-/

#print Multiset.Nat.mem_antidiagonalTuple /-
theorem mem_antidiagonalTuple {n : ℕ} {k : ℕ} {x : Fin k → ℕ} :
    x ∈ antidiagonalTuple k n ↔ ∑ i, x i = n :=
  List.Nat.mem_antidiagonalTuple
#align multiset.nat.mem_antidiagonal_tuple Multiset.Nat.mem_antidiagonalTuple
-/

#print Multiset.Nat.nodup_antidiagonalTuple /-
theorem nodup_antidiagonalTuple (k n : ℕ) : (antidiagonalTuple k n).Nodup :=
  List.Nat.nodup_antidiagonalTuple _ _
#align multiset.nat.nodup_antidiagonal_tuple Multiset.Nat.nodup_antidiagonalTuple
-/

#print Multiset.Nat.antidiagonalTuple_zero_right /-
theorem antidiagonalTuple_zero_right (k : ℕ) : antidiagonalTuple k 0 = {0} :=
  congr_arg _ (List.Nat.antidiagonalTuple_zero_right k)
#align multiset.nat.antidiagonal_tuple_zero_right Multiset.Nat.antidiagonalTuple_zero_right
-/

#print Multiset.Nat.antidiagonalTuple_one /-
@[simp]
theorem antidiagonalTuple_one (n : ℕ) : antidiagonalTuple 1 n = {![n]} :=
  congr_arg _ (List.Nat.antidiagonalTuple_one n)
#align multiset.nat.antidiagonal_tuple_one Multiset.Nat.antidiagonalTuple_one
-/

#print Multiset.Nat.antidiagonalTuple_two /-
theorem antidiagonalTuple_two (n : ℕ) :
    antidiagonalTuple 2 n = (antidiagonal n).map fun i => ![i.1, i.2] :=
  congr_arg _ (List.Nat.antidiagonalTuple_two n)
#align multiset.nat.antidiagonal_tuple_two Multiset.Nat.antidiagonalTuple_two
-/

end Multiset.Nat

/-! ### Finsets -/


namespace Finset.Nat

#print Finset.Nat.antidiagonalTuple /-
/-- `finset.antidiagonal_tuple k n` is a finset of `k`-tuples summing to `n` -/
def antidiagonalTuple (k n : ℕ) : Finset (Fin k → ℕ) :=
  ⟨Multiset.Nat.antidiagonalTuple k n, Multiset.Nat.nodup_antidiagonalTuple k n⟩
#align finset.nat.antidiagonal_tuple Finset.Nat.antidiagonalTuple
-/

#print Finset.Nat.antidiagonalTuple_zero_zero /-
@[simp]
theorem antidiagonalTuple_zero_zero : antidiagonalTuple 0 0 = {![]} :=
  rfl
#align finset.nat.antidiagonal_tuple_zero_zero Finset.Nat.antidiagonalTuple_zero_zero
-/

#print Finset.Nat.antidiagonalTuple_zero_succ /-
@[simp]
theorem antidiagonalTuple_zero_succ (n : ℕ) : antidiagonalTuple 0 n.succ = ∅ :=
  rfl
#align finset.nat.antidiagonal_tuple_zero_succ Finset.Nat.antidiagonalTuple_zero_succ
-/

#print Finset.Nat.mem_antidiagonalTuple /-
theorem mem_antidiagonalTuple {n : ℕ} {k : ℕ} {x : Fin k → ℕ} :
    x ∈ antidiagonalTuple k n ↔ ∑ i, x i = n :=
  List.Nat.mem_antidiagonalTuple
#align finset.nat.mem_antidiagonal_tuple Finset.Nat.mem_antidiagonalTuple
-/

#print Finset.Nat.antidiagonalTuple_zero_right /-
theorem antidiagonalTuple_zero_right (k : ℕ) : antidiagonalTuple k 0 = {0} :=
  Finset.eq_of_veq (Multiset.Nat.antidiagonalTuple_zero_right k)
#align finset.nat.antidiagonal_tuple_zero_right Finset.Nat.antidiagonalTuple_zero_right
-/

#print Finset.Nat.antidiagonalTuple_one /-
@[simp]
theorem antidiagonalTuple_one (n : ℕ) : antidiagonalTuple 1 n = {![n]} :=
  Finset.eq_of_veq (Multiset.Nat.antidiagonalTuple_one n)
#align finset.nat.antidiagonal_tuple_one Finset.Nat.antidiagonalTuple_one
-/

#print Finset.Nat.antidiagonalTuple_two /-
theorem antidiagonalTuple_two (n : ℕ) :
    antidiagonalTuple 2 n = (antidiagonal n).map (piFinTwoEquiv fun _ => ℕ).symm.toEmbedding :=
  Finset.eq_of_veq (Multiset.Nat.antidiagonalTuple_two n)
#align finset.nat.antidiagonal_tuple_two Finset.Nat.antidiagonalTuple_two
-/

section EquivProd

#print Finset.Nat.sigmaAntidiagonalTupleEquivTuple /-
/-- The disjoint union of antidiagonal tuples `Σ n, antidiagonal_tuple k n` is equivalent to the
`k`-tuple `fin k → ℕ`. This is such an equivalence, obtained by mapping `(n, x)` to `x`.

This is the tuple version of `finset.nat.sigma_antidiagonal_equiv_prod`. -/
@[simps]
def sigmaAntidiagonalTupleEquivTuple (k : ℕ) : (Σ n, antidiagonalTuple k n) ≃ (Fin k → ℕ)
    where
  toFun x := x.2
  invFun x := ⟨∑ i, x i, x, mem_antidiagonalTuple.mpr rfl⟩
  left_inv := fun ⟨n, t, h⟩ => Sigma.subtype_ext (mem_antidiagonalTuple.mp h) rfl
  right_inv x := rfl
#align finset.nat.sigma_antidiagonal_tuple_equiv_tuple Finset.Nat.sigmaAntidiagonalTupleEquivTuple
-/

end EquivProd

end Finset.Nat

