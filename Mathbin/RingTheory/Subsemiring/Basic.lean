/-
Copyright (c) 2020 Yury Kudryashov All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov

! This file was ported from Lean 3 source module ring_theory.subsemiring.basic
! leanprover-community/mathlib commit b915e9392ecb2a861e1e766f0e1df6ac481188ca
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Module.Basic
import Mathbin.Algebra.Ring.Equiv
import Mathbin.Algebra.Ring.Prod
import Mathbin.Algebra.Order.Ring.InjSurj
import Mathbin.Algebra.GroupRingAction.Subobjects
import Mathbin.Data.Set.Finite
import Mathbin.GroupTheory.Submonoid.Centralizer
import Mathbin.GroupTheory.Submonoid.Membership

/-!
# Bundled subsemirings

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define bundled subsemirings and some standard constructions: `complete_lattice` structure,
`subtype` and `inclusion` ring homomorphisms, subsemiring `map`, `comap` and range (`srange`) of
a `ring_hom` etc.
-/


open scoped BigOperators

universe u v w

section AddSubmonoidWithOneClass

#print AddSubmonoidWithOneClass /-
/-- `add_submonoid_with_one_class S R` says `S` is a type of subsets `s ≤ R` that contain `0`, `1`,
and are closed under `(+)` -/
class AddSubmonoidWithOneClass (S : Type _) (R : Type _) [AddMonoidWithOne R] [SetLike S R] extends
    AddSubmonoidClass S R, OneMemClass S R : Prop
#align add_submonoid_with_one_class AddSubmonoidWithOneClass
-/

variable {S R : Type _} [AddMonoidWithOne R] [SetLike S R] (s : S)

#print natCast_mem /-
theorem natCast_mem [AddSubmonoidWithOneClass S R] (n : ℕ) : (n : R) ∈ s := by
  induction n <;> simp [zero_mem, add_mem, one_mem, *]
#align nat_cast_mem natCast_mem
-/

#print AddSubmonoidWithOneClass.toAddMonoidWithOne /-
instance (priority := 74) AddSubmonoidWithOneClass.toAddMonoidWithOne
    [AddSubmonoidWithOneClass S R] : AddMonoidWithOne s :=
  { AddSubmonoidClass.toAddMonoid s with
    one := ⟨_, one_mem s⟩
    natCast := fun n => ⟨n, natCast_mem s n⟩
    natCast_zero := Subtype.ext Nat.cast_zero
    natCast_succ := fun n => Subtype.ext (Nat.cast_succ _) }
#align add_submonoid_with_one_class.to_add_monoid_with_one AddSubmonoidWithOneClass.toAddMonoidWithOne
-/

end AddSubmonoidWithOneClass

variable {R : Type u} {S : Type v} {T : Type w} [NonAssocSemiring R] (M : Submonoid R)

section SubsemiringClass

#print SubsemiringClass /-
/-- `subsemiring_class S R` states that `S` is a type of subsets `s ⊆ R` that
are both a multiplicative and an additive submonoid. -/
class SubsemiringClass (S : Type _) (R : Type u) [NonAssocSemiring R] [SetLike S R] extends
    SubmonoidClass S R, AddSubmonoidClass S R : Prop
#align subsemiring_class SubsemiringClass
-/

#print SubsemiringClass.addSubmonoidWithOneClass /-
-- See note [lower instance priority]
instance (priority := 100) SubsemiringClass.addSubmonoidWithOneClass (S : Type _) (R : Type u)
    [NonAssocSemiring R] [SetLike S R] [h : SubsemiringClass S R] : AddSubmonoidWithOneClass S R :=
  { h with }
#align subsemiring_class.add_submonoid_with_one_class SubsemiringClass.addSubmonoidWithOneClass
-/

variable [SetLike S R] [hSR : SubsemiringClass S R] (s : S)

#print coe_nat_mem /-
theorem coe_nat_mem (n : ℕ) : (n : R) ∈ s := by rw [← nsmul_one]; exact nsmul_mem (one_mem _) _
#align coe_nat_mem coe_nat_mem
-/

namespace SubsemiringClass

#print SubsemiringClass.toNonAssocSemiring /-
-- Prefer subclasses of `non_assoc_semiring` over subclasses of `subsemiring_class`.
/-- A subsemiring of a `non_assoc_semiring` inherits a `non_assoc_semiring` structure -/
instance (priority := 75) toNonAssocSemiring : NonAssocSemiring s :=
  Subtype.coe_injective.NonAssocSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_non_assoc_semiring SubsemiringClass.toNonAssocSemiring
-/

#print SubsemiringClass.nontrivial /-
instance nontrivial [Nontrivial R] : Nontrivial s :=
  nontrivial_of_ne 0 1 fun H => zero_ne_one (congr_arg Subtype.val H)
#align subsemiring_class.nontrivial SubsemiringClass.nontrivial
-/

#print SubsemiringClass.noZeroDivisors /-
instance noZeroDivisors [NoZeroDivisors R] : NoZeroDivisors s
    where eq_zero_or_eq_zero_of_mul_eq_zero x y h :=
    Or.cases_on (eq_zero_or_eq_zero_of_mul_eq_zero <| Subtype.ext_iff.mp h)
      (fun h => Or.inl <| Subtype.eq h) fun h => Or.inr <| Subtype.eq h
#align subsemiring_class.no_zero_divisors SubsemiringClass.noZeroDivisors
-/

#print SubsemiringClass.subtype /-
/-- The natural ring hom from a subsemiring of semiring `R` to `R`. -/
def subtype : s →+* R :=
  { SubmonoidClass.Subtype s, AddSubmonoidClass.Subtype s with toFun := coe }
#align subsemiring_class.subtype SubsemiringClass.subtype
-/

#print SubsemiringClass.coe_subtype /-
@[simp]
theorem coe_subtype : (subtype s : s → R) = coe :=
  rfl
#align subsemiring_class.coe_subtype SubsemiringClass.coe_subtype
-/

#print SubsemiringClass.toSemiring /-
-- Prefer subclasses of `semiring` over subclasses of `subsemiring_class`.
/-- A subsemiring of a `semiring` is a `semiring`. -/
instance (priority := 75) toSemiring {R} [Semiring R] [SetLike S R] [SubsemiringClass S R] :
    Semiring s :=
  Subtype.coe_injective.Semiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_semiring SubsemiringClass.toSemiring
-/

#print SubsemiringClass.coe_pow /-
@[simp, norm_cast]
theorem coe_pow {R} [Semiring R] [SetLike S R] [SubsemiringClass S R] (x : s) (n : ℕ) :
    ((x ^ n : s) : R) = (x ^ n : R) :=
  by
  induction' n with n ih
  · simp
  · simp [pow_succ, ih]
#align subsemiring_class.coe_pow SubsemiringClass.coe_pow
-/

#print SubsemiringClass.toCommSemiring /-
/-- A subsemiring of a `comm_semiring` is a `comm_semiring`. -/
instance toCommSemiring {R} [CommSemiring R] [SetLike S R] [SubsemiringClass S R] :
    CommSemiring s :=
  Subtype.coe_injective.CommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_comm_semiring SubsemiringClass.toCommSemiring
-/

#print SubsemiringClass.toOrderedSemiring /-
/-- A subsemiring of an `ordered_semiring` is an `ordered_semiring`. -/
instance toOrderedSemiring {R} [OrderedSemiring R] [SetLike S R] [SubsemiringClass S R] :
    OrderedSemiring s :=
  Subtype.coe_injective.OrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_ordered_semiring SubsemiringClass.toOrderedSemiring
-/

#print SubsemiringClass.toStrictOrderedSemiring /-
/-- A subsemiring of an `strict_ordered_semiring` is an `strict_ordered_semiring`. -/
instance toStrictOrderedSemiring {R} [StrictOrderedSemiring R] [SetLike S R]
    [SubsemiringClass S R] : StrictOrderedSemiring s :=
  Subtype.coe_injective.StrictOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_strict_ordered_semiring SubsemiringClass.toStrictOrderedSemiring
-/

#print SubsemiringClass.toOrderedCommSemiring /-
/-- A subsemiring of an `ordered_comm_semiring` is an `ordered_comm_semiring`. -/
instance toOrderedCommSemiring {R} [OrderedCommSemiring R] [SetLike S R] [SubsemiringClass S R] :
    OrderedCommSemiring s :=
  Subtype.coe_injective.OrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_ordered_comm_semiring SubsemiringClass.toOrderedCommSemiring
-/

#print SubsemiringClass.toStrictOrderedCommSemiring /-
/-- A subsemiring of an `strict_ordered_comm_semiring` is an `strict_ordered_comm_semiring`. -/
instance toStrictOrderedCommSemiring {R} [StrictOrderedCommSemiring R] [SetLike S R]
    [SubsemiringClass S R] : StrictOrderedCommSemiring s :=
  Subtype.coe_injective.StrictOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring_class.to_strict_ordered_comm_semiring SubsemiringClass.toStrictOrderedCommSemiring
-/

#print SubsemiringClass.toLinearOrderedSemiring /-
/-- A subsemiring of a `linear_ordered_semiring` is a `linear_ordered_semiring`. -/
instance toLinearOrderedSemiring {R} [LinearOrderedSemiring R] [SetLike S R]
    [SubsemiringClass S R] : LinearOrderedSemiring s :=
  Subtype.coe_injective.LinearOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring_class.to_linear_ordered_semiring SubsemiringClass.toLinearOrderedSemiring
-/

#print SubsemiringClass.toLinearOrderedCommSemiring /-
/-- A subsemiring of a `linear_ordered_comm_semiring` is a `linear_ordered_comm_semiring`. -/
instance toLinearOrderedCommSemiring {R} [LinearOrderedCommSemiring R] [SetLike S R]
    [SubsemiringClass S R] : LinearOrderedCommSemiring s :=
  Subtype.coe_injective.LinearOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring_class.to_linear_ordered_comm_semiring SubsemiringClass.toLinearOrderedCommSemiring
-/

end SubsemiringClass

end SubsemiringClass

variable [NonAssocSemiring S] [NonAssocSemiring T]

#print Subsemiring /-
/-- A subsemiring of a semiring `R` is a subset `s` that is both a multiplicative and an additive
submonoid. -/
structure Subsemiring (R : Type u) [NonAssocSemiring R] extends Submonoid R, AddSubmonoid R
#align subsemiring Subsemiring
-/

/-- Reinterpret a `subsemiring` as a `submonoid`. -/
add_decl_doc Subsemiring.toSubmonoid

/-- Reinterpret a `subsemiring` as an `add_submonoid`. -/
add_decl_doc Subsemiring.toAddSubmonoid

namespace Subsemiring

instance : SetLike (Subsemiring R) R
    where
  coe := Subsemiring.carrier
  coe_injective' p q h := by cases p <;> cases q <;> congr

instance : SubsemiringClass (Subsemiring R) R
    where
  zero_mem := zero_mem'
  add_mem := add_mem'
  one_mem := one_mem'
  mul_mem := mul_mem'

#print Subsemiring.mem_carrier /-
@[simp]
theorem mem_carrier {s : Subsemiring R} {x : R} : x ∈ s.carrier ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_carrier Subsemiring.mem_carrier
-/

#print Subsemiring.ext /-
/-- Two subsemirings are equal if they have the same elements. -/
@[ext]
theorem ext {S T : Subsemiring R} (h : ∀ x, x ∈ S ↔ x ∈ T) : S = T :=
  SetLike.ext h
#align subsemiring.ext Subsemiring.ext
-/

#print Subsemiring.copy /-
/-- Copy of a subsemiring with a new `carrier` equal to the old one. Useful to fix definitional
equalities.-/
protected def copy (S : Subsemiring R) (s : Set R) (hs : s = ↑S) : Subsemiring R :=
  { S.toAddSubmonoid.copy s hs, S.toSubmonoid.copy s hs with carrier := s }
#align subsemiring.copy Subsemiring.copy
-/

#print Subsemiring.coe_copy /-
@[simp]
theorem coe_copy (S : Subsemiring R) (s : Set R) (hs : s = ↑S) : (S.copy s hs : Set R) = s :=
  rfl
#align subsemiring.coe_copy Subsemiring.coe_copy
-/

#print Subsemiring.copy_eq /-
theorem copy_eq (S : Subsemiring R) (s : Set R) (hs : s = ↑S) : S.copy s hs = S :=
  SetLike.coe_injective hs
#align subsemiring.copy_eq Subsemiring.copy_eq
-/

#print Subsemiring.toSubmonoid_injective /-
theorem toSubmonoid_injective : Function.Injective (toSubmonoid : Subsemiring R → Submonoid R)
  | r, s, h => ext (SetLike.ext_iff.mp h : _)
#align subsemiring.to_submonoid_injective Subsemiring.toSubmonoid_injective
-/

#print Subsemiring.toSubmonoid_strictMono /-
@[mono]
theorem toSubmonoid_strictMono : StrictMono (toSubmonoid : Subsemiring R → Submonoid R) :=
  fun _ _ => id
#align subsemiring.to_submonoid_strict_mono Subsemiring.toSubmonoid_strictMono
-/

#print Subsemiring.toSubmonoid_mono /-
@[mono]
theorem toSubmonoid_mono : Monotone (toSubmonoid : Subsemiring R → Submonoid R) :=
  toSubmonoid_strictMono.Monotone
#align subsemiring.to_submonoid_mono Subsemiring.toSubmonoid_mono
-/

#print Subsemiring.toAddSubmonoid_injective /-
theorem toAddSubmonoid_injective :
    Function.Injective (toAddSubmonoid : Subsemiring R → AddSubmonoid R)
  | r, s, h => ext (SetLike.ext_iff.mp h : _)
#align subsemiring.to_add_submonoid_injective Subsemiring.toAddSubmonoid_injective
-/

#print Subsemiring.toAddSubmonoid_strictMono /-
@[mono]
theorem toAddSubmonoid_strictMono : StrictMono (toAddSubmonoid : Subsemiring R → AddSubmonoid R) :=
  fun _ _ => id
#align subsemiring.to_add_submonoid_strict_mono Subsemiring.toAddSubmonoid_strictMono
-/

#print Subsemiring.toAddSubmonoid_mono /-
@[mono]
theorem toAddSubmonoid_mono : Monotone (toAddSubmonoid : Subsemiring R → AddSubmonoid R) :=
  toAddSubmonoid_strictMono.Monotone
#align subsemiring.to_add_submonoid_mono Subsemiring.toAddSubmonoid_mono
-/

#print Subsemiring.mk' /-
/-- Construct a `subsemiring R` from a set `s`, a submonoid `sm`, and an additive
submonoid `sa` such that `x ∈ s ↔ x ∈ sm ↔ x ∈ sa`. -/
protected def mk' (s : Set R) (sm : Submonoid R) (hm : ↑sm = s) (sa : AddSubmonoid R)
    (ha : ↑sa = s) : Subsemiring R where
  carrier := s
  zero_mem' := ha ▸ sa.zero_mem
  one_mem' := hm ▸ sm.one_mem
  add_mem' x y := by simpa only [← ha] using sa.add_mem
  mul_mem' x y := by simpa only [← hm] using sm.mul_mem
#align subsemiring.mk' Subsemiring.mk'
-/

#print Subsemiring.coe_mk' /-
@[simp]
theorem coe_mk' {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R} (ha : ↑sa = s) :
    (Subsemiring.mk' s sm hm sa ha : Set R) = s :=
  rfl
#align subsemiring.coe_mk' Subsemiring.coe_mk'
-/

#print Subsemiring.mem_mk' /-
@[simp]
theorem mem_mk' {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R} (ha : ↑sa = s)
    {x : R} : x ∈ Subsemiring.mk' s sm hm sa ha ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_mk' Subsemiring.mem_mk'
-/

#print Subsemiring.mk'_toSubmonoid /-
@[simp]
theorem mk'_toSubmonoid {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R}
    (ha : ↑sa = s) : (Subsemiring.mk' s sm hm sa ha).toSubmonoid = sm :=
  SetLike.coe_injective hm.symm
#align subsemiring.mk'_to_submonoid Subsemiring.mk'_toSubmonoid
-/

#print Subsemiring.mk'_toAddSubmonoid /-
@[simp]
theorem mk'_toAddSubmonoid {s : Set R} {sm : Submonoid R} (hm : ↑sm = s) {sa : AddSubmonoid R}
    (ha : ↑sa = s) : (Subsemiring.mk' s sm hm sa ha).toAddSubmonoid = sa :=
  SetLike.coe_injective ha.symm
#align subsemiring.mk'_to_add_submonoid Subsemiring.mk'_toAddSubmonoid
-/

end Subsemiring

namespace Subsemiring

variable (s : Subsemiring R)

#print Subsemiring.one_mem /-
/-- A subsemiring contains the semiring's 1. -/
protected theorem one_mem : (1 : R) ∈ s :=
  one_mem s
#align subsemiring.one_mem Subsemiring.one_mem
-/

#print Subsemiring.zero_mem /-
/-- A subsemiring contains the semiring's 0. -/
protected theorem zero_mem : (0 : R) ∈ s :=
  zero_mem s
#align subsemiring.zero_mem Subsemiring.zero_mem
-/

#print Subsemiring.mul_mem /-
/-- A subsemiring is closed under multiplication. -/
protected theorem mul_mem {x y : R} : x ∈ s → y ∈ s → x * y ∈ s :=
  mul_mem
#align subsemiring.mul_mem Subsemiring.mul_mem
-/

#print Subsemiring.add_mem /-
/-- A subsemiring is closed under addition. -/
protected theorem add_mem {x y : R} : x ∈ s → y ∈ s → x + y ∈ s :=
  add_mem
#align subsemiring.add_mem Subsemiring.add_mem
-/

#print Subsemiring.list_prod_mem /-
/-- Product of a list of elements in a `subsemiring` is in the `subsemiring`. -/
theorem list_prod_mem {R : Type _} [Semiring R] (s : Subsemiring R) {l : List R} :
    (∀ x ∈ l, x ∈ s) → l.Prod ∈ s :=
  list_prod_mem
#align subsemiring.list_prod_mem Subsemiring.list_prod_mem
-/

#print Subsemiring.list_sum_mem /-
/-- Sum of a list of elements in a `subsemiring` is in the `subsemiring`. -/
protected theorem list_sum_mem {l : List R} : (∀ x ∈ l, x ∈ s) → l.Sum ∈ s :=
  list_sum_mem
#align subsemiring.list_sum_mem Subsemiring.list_sum_mem
-/

#print Subsemiring.multiset_prod_mem /-
/-- Product of a multiset of elements in a `subsemiring` of a `comm_semiring`
    is in the `subsemiring`. -/
protected theorem multiset_prod_mem {R} [CommSemiring R] (s : Subsemiring R) (m : Multiset R) :
    (∀ a ∈ m, a ∈ s) → m.Prod ∈ s :=
  multiset_prod_mem m
#align subsemiring.multiset_prod_mem Subsemiring.multiset_prod_mem
-/

#print Subsemiring.multiset_sum_mem /-
/-- Sum of a multiset of elements in a `subsemiring` of a `semiring` is
in the `add_subsemiring`. -/
protected theorem multiset_sum_mem (m : Multiset R) : (∀ a ∈ m, a ∈ s) → m.Sum ∈ s :=
  multiset_sum_mem m
#align subsemiring.multiset_sum_mem Subsemiring.multiset_sum_mem
-/

#print Subsemiring.prod_mem /-
/-- Product of elements of a subsemiring of a `comm_semiring` indexed by a `finset` is in the
    subsemiring. -/
protected theorem prod_mem {R : Type _} [CommSemiring R] (s : Subsemiring R) {ι : Type _}
    {t : Finset ι} {f : ι → R} (h : ∀ c ∈ t, f c ∈ s) : ∏ i in t, f i ∈ s :=
  prod_mem h
#align subsemiring.prod_mem Subsemiring.prod_mem
-/

#print Subsemiring.sum_mem /-
/-- Sum of elements in an `subsemiring` of an `semiring` indexed by a `finset`
is in the `add_subsemiring`. -/
protected theorem sum_mem (s : Subsemiring R) {ι : Type _} {t : Finset ι} {f : ι → R}
    (h : ∀ c ∈ t, f c ∈ s) : ∑ i in t, f i ∈ s :=
  sum_mem h
#align subsemiring.sum_mem Subsemiring.sum_mem
-/

#print Subsemiring.toNonAssocSemiring /-
/-- A subsemiring of a `non_assoc_semiring` inherits a `non_assoc_semiring` structure -/
instance toNonAssocSemiring : NonAssocSemiring s :=
  { s.toSubmonoid.toMulOneClass,
    s.toAddSubmonoid.toAddCommMonoid with
    mul_zero := fun x => Subtype.eq <| MulZeroClass.mul_zero x
    zero_mul := fun x => Subtype.eq <| MulZeroClass.zero_mul x
    right_distrib := fun x y z => Subtype.eq <| right_distrib x y z
    left_distrib := fun x y z => Subtype.eq <| left_distrib x y z
    natCast := fun n => ⟨n, coe_nat_mem s n⟩
    natCast_zero := by simp [Nat.cast] <;> rfl
    natCast_succ := fun _ => by simp [Nat.cast] <;> rfl }
#align subsemiring.to_non_assoc_semiring Subsemiring.toNonAssocSemiring
-/

#print Subsemiring.coe_one /-
@[simp, norm_cast]
theorem coe_one : ((1 : s) : R) = (1 : R) :=
  rfl
#align subsemiring.coe_one Subsemiring.coe_one
-/

#print Subsemiring.coe_zero /-
@[simp, norm_cast]
theorem coe_zero : ((0 : s) : R) = (0 : R) :=
  rfl
#align subsemiring.coe_zero Subsemiring.coe_zero
-/

#print Subsemiring.coe_add /-
@[simp, norm_cast]
theorem coe_add (x y : s) : ((x + y : s) : R) = (x + y : R) :=
  rfl
#align subsemiring.coe_add Subsemiring.coe_add
-/

#print Subsemiring.coe_mul /-
@[simp, norm_cast]
theorem coe_mul (x y : s) : ((x * y : s) : R) = (x * y : R) :=
  rfl
#align subsemiring.coe_mul Subsemiring.coe_mul
-/

#print Subsemiring.nontrivial /-
instance nontrivial [Nontrivial R] : Nontrivial s :=
  nontrivial_of_ne 0 1 fun H => zero_ne_one (congr_arg Subtype.val H)
#align subsemiring.nontrivial Subsemiring.nontrivial
-/

#print Subsemiring.pow_mem /-
protected theorem pow_mem {R : Type _} [Semiring R] (s : Subsemiring R) {x : R} (hx : x ∈ s)
    (n : ℕ) : x ^ n ∈ s :=
  pow_mem hx n
#align subsemiring.pow_mem Subsemiring.pow_mem
-/

#print Subsemiring.noZeroDivisors /-
instance noZeroDivisors [NoZeroDivisors R] : NoZeroDivisors s
    where eq_zero_or_eq_zero_of_mul_eq_zero x y h :=
    Or.cases_on (eq_zero_or_eq_zero_of_mul_eq_zero <| Subtype.ext_iff.mp h)
      (fun h => Or.inl <| Subtype.eq h) fun h => Or.inr <| Subtype.eq h
#align subsemiring.no_zero_divisors Subsemiring.noZeroDivisors
-/

#print Subsemiring.toSemiring /-
/-- A subsemiring of a `semiring` is a `semiring`. -/
instance toSemiring {R} [Semiring R] (s : Subsemiring R) : Semiring s :=
  { s.toNonAssocSemiring, s.toSubmonoid.toMonoid with }
#align subsemiring.to_semiring Subsemiring.toSemiring
-/

#print Subsemiring.coe_pow /-
@[simp, norm_cast]
theorem coe_pow {R} [Semiring R] (s : Subsemiring R) (x : s) (n : ℕ) :
    ((x ^ n : s) : R) = (x ^ n : R) :=
  by
  induction' n with n ih
  · simp
  · simp [pow_succ, ih]
#align subsemiring.coe_pow Subsemiring.coe_pow
-/

#print Subsemiring.toCommSemiring /-
/-- A subsemiring of a `comm_semiring` is a `comm_semiring`. -/
instance toCommSemiring {R} [CommSemiring R] (s : Subsemiring R) : CommSemiring s :=
  { s.toSemiring with mul_comm := fun _ _ => Subtype.eq <| mul_comm _ _ }
#align subsemiring.to_comm_semiring Subsemiring.toCommSemiring
-/

#print Subsemiring.subtype /-
/-- The natural ring hom from a subsemiring of semiring `R` to `R`. -/
def subtype : s →+* R :=
  { s.toSubmonoid.Subtype, s.toAddSubmonoid.Subtype with toFun := coe }
#align subsemiring.subtype Subsemiring.subtype
-/

#print Subsemiring.coe_subtype /-
@[simp]
theorem coe_subtype : ⇑s.Subtype = coe :=
  rfl
#align subsemiring.coe_subtype Subsemiring.coe_subtype
-/

#print Subsemiring.toOrderedSemiring /-
/-- A subsemiring of an `ordered_semiring` is an `ordered_semiring`. -/
instance toOrderedSemiring {R} [OrderedSemiring R] (s : Subsemiring R) : OrderedSemiring s :=
  Subtype.coe_injective.OrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_ordered_semiring Subsemiring.toOrderedSemiring
-/

#print Subsemiring.toStrictOrderedSemiring /-
/-- A subsemiring of a `strict_ordered_semiring` is a `strict_ordered_semiring`. -/
instance toStrictOrderedSemiring {R} [StrictOrderedSemiring R] (s : Subsemiring R) :
    StrictOrderedSemiring s :=
  Subtype.coe_injective.StrictOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_strict_ordered_semiring Subsemiring.toStrictOrderedSemiring
-/

#print Subsemiring.toOrderedCommSemiring /-
/-- A subsemiring of an `ordered_comm_semiring` is an `ordered_comm_semiring`. -/
instance toOrderedCommSemiring {R} [OrderedCommSemiring R] (s : Subsemiring R) :
    OrderedCommSemiring s :=
  Subtype.coe_injective.OrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_ordered_comm_semiring Subsemiring.toOrderedCommSemiring
-/

#print Subsemiring.toStrictOrderedCommSemiring /-
/-- A subsemiring of a `strict_ordered_comm_semiring` is a `strict_ordered_comm_semiring`. -/
instance toStrictOrderedCommSemiring {R} [StrictOrderedCommSemiring R] (s : Subsemiring R) :
    StrictOrderedCommSemiring s :=
  Subtype.coe_injective.StrictOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) fun _ => rfl
#align subsemiring.to_strict_ordered_comm_semiring Subsemiring.toStrictOrderedCommSemiring
-/

#print Subsemiring.toLinearOrderedSemiring /-
/-- A subsemiring of a `linear_ordered_semiring` is a `linear_ordered_semiring`. -/
instance toLinearOrderedSemiring {R} [LinearOrderedSemiring R] (s : Subsemiring R) :
    LinearOrderedSemiring s :=
  Subtype.coe_injective.LinearOrderedSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring.to_linear_ordered_semiring Subsemiring.toLinearOrderedSemiring
-/

#print Subsemiring.toLinearOrderedCommSemiring /-
/-- A subsemiring of a `linear_ordered_comm_semiring` is a `linear_ordered_comm_semiring`. -/
instance toLinearOrderedCommSemiring {R} [LinearOrderedCommSemiring R] (s : Subsemiring R) :
    LinearOrderedCommSemiring s :=
  Subtype.coe_injective.LinearOrderedCommSemiring coe rfl rfl (fun _ _ => rfl) (fun _ _ => rfl)
    (fun _ _ => rfl) (fun _ _ => rfl) (fun _ => rfl) (fun _ _ => rfl) fun _ _ => rfl
#align subsemiring.to_linear_ordered_comm_semiring Subsemiring.toLinearOrderedCommSemiring
-/

#print Subsemiring.nsmul_mem /-
protected theorem nsmul_mem {x : R} (hx : x ∈ s) (n : ℕ) : n • x ∈ s :=
  nsmul_mem hx n
#align subsemiring.nsmul_mem Subsemiring.nsmul_mem
-/

#print Subsemiring.mem_toSubmonoid /-
@[simp]
theorem mem_toSubmonoid {s : Subsemiring R} {x : R} : x ∈ s.toSubmonoid ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_to_submonoid Subsemiring.mem_toSubmonoid
-/

#print Subsemiring.coe_toSubmonoid /-
@[simp]
theorem coe_toSubmonoid (s : Subsemiring R) : (s.toSubmonoid : Set R) = s :=
  rfl
#align subsemiring.coe_to_submonoid Subsemiring.coe_toSubmonoid
-/

#print Subsemiring.mem_toAddSubmonoid /-
@[simp]
theorem mem_toAddSubmonoid {s : Subsemiring R} {x : R} : x ∈ s.toAddSubmonoid ↔ x ∈ s :=
  Iff.rfl
#align subsemiring.mem_to_add_submonoid Subsemiring.mem_toAddSubmonoid
-/

#print Subsemiring.coe_toAddSubmonoid /-
@[simp]
theorem coe_toAddSubmonoid (s : Subsemiring R) : (s.toAddSubmonoid : Set R) = s :=
  rfl
#align subsemiring.coe_to_add_submonoid Subsemiring.coe_toAddSubmonoid
-/

/-- The subsemiring `R` of the semiring `R`. -/
instance : Top (Subsemiring R) :=
  ⟨{ (⊤ : Submonoid R), (⊤ : AddSubmonoid R) with }⟩

#print Subsemiring.mem_top /-
@[simp]
theorem mem_top (x : R) : x ∈ (⊤ : Subsemiring R) :=
  Set.mem_univ x
#align subsemiring.mem_top Subsemiring.mem_top
-/

#print Subsemiring.coe_top /-
@[simp]
theorem coe_top : ((⊤ : Subsemiring R) : Set R) = Set.univ :=
  rfl
#align subsemiring.coe_top Subsemiring.coe_top
-/

#print Subsemiring.topEquiv /-
/-- The ring equiv between the top element of `subsemiring R` and `R`. -/
@[simps]
def topEquiv : (⊤ : Subsemiring R) ≃+* R
    where
  toFun r := r
  invFun r := ⟨r, Subsemiring.mem_top r⟩
  left_inv r := SetLike.eta r _
  right_inv r := SetLike.coe_mk r _
  map_mul' := (⊤ : Subsemiring R).coe_mul
  map_add' := (⊤ : Subsemiring R).val_add
#align subsemiring.top_equiv Subsemiring.topEquiv
-/

#print Subsemiring.comap /-
/-- The preimage of a subsemiring along a ring homomorphism is a subsemiring. -/
def comap (f : R →+* S) (s : Subsemiring S) : Subsemiring R :=
  { s.toSubmonoid.comap (f : R →* S), s.toAddSubmonoid.comap (f : R →+ S) with carrier := f ⁻¹' s }
#align subsemiring.comap Subsemiring.comap
-/

#print Subsemiring.coe_comap /-
@[simp]
theorem coe_comap (s : Subsemiring S) (f : R →+* S) : (s.comap f : Set R) = f ⁻¹' s :=
  rfl
#align subsemiring.coe_comap Subsemiring.coe_comap
-/

#print Subsemiring.mem_comap /-
@[simp]
theorem mem_comap {s : Subsemiring S} {f : R →+* S} {x : R} : x ∈ s.comap f ↔ f x ∈ s :=
  Iff.rfl
#align subsemiring.mem_comap Subsemiring.mem_comap
-/

#print Subsemiring.comap_comap /-
theorem comap_comap (s : Subsemiring T) (g : S →+* T) (f : R →+* S) :
    (s.comap g).comap f = s.comap (g.comp f) :=
  rfl
#align subsemiring.comap_comap Subsemiring.comap_comap
-/

#print Subsemiring.map /-
/-- The image of a subsemiring along a ring homomorphism is a subsemiring. -/
def map (f : R →+* S) (s : Subsemiring R) : Subsemiring S :=
  { s.toSubmonoid.map (f : R →* S), s.toAddSubmonoid.map (f : R →+ S) with carrier := f '' s }
#align subsemiring.map Subsemiring.map
-/

#print Subsemiring.coe_map /-
@[simp]
theorem coe_map (f : R →+* S) (s : Subsemiring R) : (s.map f : Set S) = f '' s :=
  rfl
#align subsemiring.coe_map Subsemiring.coe_map
-/

#print Subsemiring.mem_map /-
@[simp]
theorem mem_map {f : R →+* S} {s : Subsemiring R} {y : S} : y ∈ s.map f ↔ ∃ x ∈ s, f x = y :=
  Set.mem_image_iff_bex
#align subsemiring.mem_map Subsemiring.mem_map
-/

#print Subsemiring.map_id /-
@[simp]
theorem map_id : s.map (RingHom.id R) = s :=
  SetLike.coe_injective <| Set.image_id _
#align subsemiring.map_id Subsemiring.map_id
-/

#print Subsemiring.map_map /-
theorem map_map (g : S →+* T) (f : R →+* S) : (s.map f).map g = s.map (g.comp f) :=
  SetLike.coe_injective <| Set.image_image _ _ _
#align subsemiring.map_map Subsemiring.map_map
-/

#print Subsemiring.map_le_iff_le_comap /-
theorem map_le_iff_le_comap {f : R →+* S} {s : Subsemiring R} {t : Subsemiring S} :
    s.map f ≤ t ↔ s ≤ t.comap f :=
  Set.image_subset_iff
#align subsemiring.map_le_iff_le_comap Subsemiring.map_le_iff_le_comap
-/

#print Subsemiring.gc_map_comap /-
theorem gc_map_comap (f : R →+* S) : GaloisConnection (map f) (comap f) := fun S T =>
  map_le_iff_le_comap
#align subsemiring.gc_map_comap Subsemiring.gc_map_comap
-/

#print Subsemiring.equivMapOfInjective /-
/-- A subsemiring is isomorphic to its image under an injective function -/
noncomputable def equivMapOfInjective (f : R →+* S) (hf : Function.Injective f) : s ≃+* s.map f :=
  {
    Equiv.Set.image f s
      hf with
    map_mul' := fun _ _ => Subtype.ext (f.map_mul _ _)
    map_add' := fun _ _ => Subtype.ext (f.map_add _ _) }
#align subsemiring.equiv_map_of_injective Subsemiring.equivMapOfInjective
-/

#print Subsemiring.coe_equivMapOfInjective_apply /-
@[simp]
theorem coe_equivMapOfInjective_apply (f : R →+* S) (hf : Function.Injective f) (x : s) :
    (equivMapOfInjective s f hf x : S) = f x :=
  rfl
#align subsemiring.coe_equiv_map_of_injective_apply Subsemiring.coe_equivMapOfInjective_apply
-/

end Subsemiring

namespace RingHom

variable (g : S →+* T) (f : R →+* S)

#print RingHom.rangeS /-
/-- The range of a ring homomorphism is a subsemiring. See Note [range copy pattern]. -/
def rangeS : Subsemiring S :=
  ((⊤ : Subsemiring R).map f).copy (Set.range f) Set.image_univ.symm
#align ring_hom.srange RingHom.rangeS
-/

#print RingHom.coe_rangeS /-
@[simp]
theorem coe_rangeS : (f.srange : Set S) = Set.range f :=
  rfl
#align ring_hom.coe_srange RingHom.coe_rangeS
-/

#print RingHom.mem_rangeS /-
@[simp]
theorem mem_rangeS {f : R →+* S} {y : S} : y ∈ f.srange ↔ ∃ x, f x = y :=
  Iff.rfl
#align ring_hom.mem_srange RingHom.mem_rangeS
-/

#print RingHom.rangeS_eq_map /-
theorem rangeS_eq_map (f : R →+* S) : f.srange = (⊤ : Subsemiring R).map f := by ext; simp
#align ring_hom.srange_eq_map RingHom.rangeS_eq_map
-/

#print RingHom.mem_rangeS_self /-
theorem mem_rangeS_self (f : R →+* S) (x : R) : f x ∈ f.srange :=
  mem_rangeS.mpr ⟨x, rfl⟩
#align ring_hom.mem_srange_self RingHom.mem_rangeS_self
-/

#print RingHom.map_rangeS /-
theorem map_rangeS : f.srange.map g = (g.comp f).srange := by
  simpa only [srange_eq_map] using (⊤ : Subsemiring R).map_map g f
#align ring_hom.map_srange RingHom.map_rangeS
-/

#print RingHom.fintypeRangeS /-
/-- The range of a morphism of semirings is a fintype, if the domain is a fintype.
Note: this instance can form a diamond with `subtype.fintype` in the
  presence of `fintype S`.-/
instance fintypeRangeS [Fintype R] [DecidableEq S] (f : R →+* S) : Fintype (rangeS f) :=
  Set.fintypeRange f
#align ring_hom.fintype_srange RingHom.fintypeRangeS
-/

end RingHom

namespace Subsemiring

instance : Bot (Subsemiring R) :=
  ⟨(Nat.castRingHom R).srange⟩

instance : Inhabited (Subsemiring R) :=
  ⟨⊥⟩

#print Subsemiring.coe_bot /-
theorem coe_bot : ((⊥ : Subsemiring R) : Set R) = Set.range (coe : ℕ → R) :=
  (Nat.castRingHom R).coe_srange
#align subsemiring.coe_bot Subsemiring.coe_bot
-/

#print Subsemiring.mem_bot /-
theorem mem_bot {x : R} : x ∈ (⊥ : Subsemiring R) ↔ ∃ n : ℕ, ↑n = x :=
  RingHom.mem_rangeS
#align subsemiring.mem_bot Subsemiring.mem_bot
-/

/-- The inf of two subsemirings is their intersection. -/
instance : Inf (Subsemiring R) :=
  ⟨fun s t =>
    { s.toSubmonoid ⊓ t.toSubmonoid, s.toAddSubmonoid ⊓ t.toAddSubmonoid with carrier := s ∩ t }⟩

#print Subsemiring.coe_inf /-
@[simp]
theorem coe_inf (p p' : Subsemiring R) : ((p ⊓ p' : Subsemiring R) : Set R) = p ∩ p' :=
  rfl
#align subsemiring.coe_inf Subsemiring.coe_inf
-/

#print Subsemiring.mem_inf /-
@[simp]
theorem mem_inf {p p' : Subsemiring R} {x : R} : x ∈ p ⊓ p' ↔ x ∈ p ∧ x ∈ p' :=
  Iff.rfl
#align subsemiring.mem_inf Subsemiring.mem_inf
-/

instance : InfSet (Subsemiring R) :=
  ⟨fun s =>
    Subsemiring.mk' (⋂ t ∈ s, ↑t) (⨅ t ∈ s, Subsemiring.toSubmonoid t) (by simp)
      (⨅ t ∈ s, Subsemiring.toAddSubmonoid t) (by simp)⟩

#print Subsemiring.coe_sInf /-
@[simp, norm_cast]
theorem coe_sInf (S : Set (Subsemiring R)) : ((sInf S : Subsemiring R) : Set R) = ⋂ s ∈ S, ↑s :=
  rfl
#align subsemiring.coe_Inf Subsemiring.coe_sInf
-/

#print Subsemiring.mem_sInf /-
theorem mem_sInf {S : Set (Subsemiring R)} {x : R} : x ∈ sInf S ↔ ∀ p ∈ S, x ∈ p :=
  Set.mem_iInter₂
#align subsemiring.mem_Inf Subsemiring.mem_sInf
-/

#print Subsemiring.sInf_toSubmonoid /-
@[simp]
theorem sInf_toSubmonoid (s : Set (Subsemiring R)) :
    (sInf s).toSubmonoid = ⨅ t ∈ s, Subsemiring.toSubmonoid t :=
  mk'_toSubmonoid _ _
#align subsemiring.Inf_to_submonoid Subsemiring.sInf_toSubmonoid
-/

#print Subsemiring.sInf_toAddSubmonoid /-
@[simp]
theorem sInf_toAddSubmonoid (s : Set (Subsemiring R)) :
    (sInf s).toAddSubmonoid = ⨅ t ∈ s, Subsemiring.toAddSubmonoid t :=
  mk'_toAddSubmonoid _ _
#align subsemiring.Inf_to_add_submonoid Subsemiring.sInf_toAddSubmonoid
-/

/-- Subsemirings of a semiring form a complete lattice. -/
instance : CompleteLattice (Subsemiring R) :=
  {
    completeLatticeOfInf (Subsemiring R) fun s =>
      IsGLB.of_image (fun s t => show (s : Set R) ≤ t ↔ s ≤ t from SetLike.coe_subset_coe)
        isGLB_biInf with
    bot := ⊥
    bot_le := fun s x hx =>
      let ⟨n, hn⟩ := mem_bot.1 hx
      hn ▸ coe_nat_mem s n
    top := ⊤
    le_top := fun s x hx => trivial
    inf := (· ⊓ ·)
    inf_le_left := fun s t x => And.left
    inf_le_right := fun s t x => And.right
    le_inf := fun s t₁ t₂ h₁ h₂ x hx => ⟨h₁ hx, h₂ hx⟩ }

#print Subsemiring.eq_top_iff' /-
theorem eq_top_iff' (A : Subsemiring R) : A = ⊤ ↔ ∀ x : R, x ∈ A :=
  eq_top_iff.trans ⟨fun h m => h <| mem_top m, fun h m _ => h m⟩
#align subsemiring.eq_top_iff' Subsemiring.eq_top_iff'
-/

section Center

#print Subsemiring.center /-
/-- The center of a semiring `R` is the set of elements that commute with everything in `R` -/
def center (R) [Semiring R] : Subsemiring R :=
  { Submonoid.center R with
    carrier := Set.center R
    zero_mem' := Set.zero_mem_center R
    add_mem' := fun a b => Set.add_mem_center }
#align subsemiring.center Subsemiring.center
-/

#print Subsemiring.coe_center /-
theorem coe_center (R) [Semiring R] : ↑(center R) = Set.center R :=
  rfl
#align subsemiring.coe_center Subsemiring.coe_center
-/

#print Subsemiring.center_toSubmonoid /-
@[simp]
theorem center_toSubmonoid (R) [Semiring R] : (center R).toSubmonoid = Submonoid.center R :=
  rfl
#align subsemiring.center_to_submonoid Subsemiring.center_toSubmonoid
-/

#print Subsemiring.mem_center_iff /-
theorem mem_center_iff {R} [Semiring R] {z : R} : z ∈ center R ↔ ∀ g, g * z = z * g :=
  Iff.rfl
#align subsemiring.mem_center_iff Subsemiring.mem_center_iff
-/

#print Subsemiring.decidableMemCenter /-
instance decidableMemCenter {R} [Semiring R] [DecidableEq R] [Fintype R] :
    DecidablePred (· ∈ center R) := fun _ => decidable_of_iff' _ mem_center_iff
#align subsemiring.decidable_mem_center Subsemiring.decidableMemCenter
-/

#print Subsemiring.center_eq_top /-
@[simp]
theorem center_eq_top (R) [CommSemiring R] : center R = ⊤ :=
  SetLike.coe_injective (Set.center_eq_univ R)
#align subsemiring.center_eq_top Subsemiring.center_eq_top
-/

/-- The center is commutative. -/
instance {R} [Semiring R] : CommSemiring (center R) :=
  { Submonoid.center.commMonoid, (center R).toSemiring with }

end Center

section Centralizer

#print Subsemiring.centralizer /-
/-- The centralizer of a set as subsemiring. -/
def centralizer {R} [Semiring R] (s : Set R) : Subsemiring R :=
  { Submonoid.centralizer s with
    carrier := s.centralizer
    zero_mem' := Set.zero_mem_centralizer _
    add_mem' := fun x y hx hy => Set.add_mem_centralizer hx hy }
#align subsemiring.centralizer Subsemiring.centralizer
-/

#print Subsemiring.coe_centralizer /-
@[simp, norm_cast]
theorem coe_centralizer {R} [Semiring R] (s : Set R) : (centralizer s : Set R) = s.centralizer :=
  rfl
#align subsemiring.coe_centralizer Subsemiring.coe_centralizer
-/

#print Subsemiring.centralizer_toSubmonoid /-
theorem centralizer_toSubmonoid {R} [Semiring R] (s : Set R) :
    (centralizer s).toSubmonoid = Submonoid.centralizer s :=
  rfl
#align subsemiring.centralizer_to_submonoid Subsemiring.centralizer_toSubmonoid
-/

#print Subsemiring.mem_centralizer_iff /-
theorem mem_centralizer_iff {R} [Semiring R] {s : Set R} {z : R} :
    z ∈ centralizer s ↔ ∀ g ∈ s, g * z = z * g :=
  Iff.rfl
#align subsemiring.mem_centralizer_iff Subsemiring.mem_centralizer_iff
-/

#print Subsemiring.center_le_centralizer /-
theorem center_le_centralizer {R} [Semiring R] (s) : center R ≤ centralizer s :=
  s.center_subset_centralizer
#align subsemiring.center_le_centralizer Subsemiring.center_le_centralizer
-/

#print Subsemiring.centralizer_le /-
theorem centralizer_le {R} [Semiring R] (s t : Set R) (h : s ⊆ t) : centralizer t ≤ centralizer s :=
  Set.centralizer_subset h
#align subsemiring.centralizer_le Subsemiring.centralizer_le
-/

#print Subsemiring.centralizer_eq_top_iff_subset /-
@[simp]
theorem centralizer_eq_top_iff_subset {R} [Semiring R] {s : Set R} :
    centralizer s = ⊤ ↔ s ⊆ center R :=
  SetLike.ext'_iff.trans Set.centralizer_eq_top_iff_subset
#align subsemiring.centralizer_eq_top_iff_subset Subsemiring.centralizer_eq_top_iff_subset
-/

#print Subsemiring.centralizer_univ /-
@[simp]
theorem centralizer_univ {R} [Semiring R] : centralizer Set.univ = center R :=
  SetLike.ext' (Set.centralizer_univ R)
#align subsemiring.centralizer_univ Subsemiring.centralizer_univ
-/

end Centralizer

#print Subsemiring.closure /-
/-- The `subsemiring` generated by a set. -/
def closure (s : Set R) : Subsemiring R :=
  sInf {S | s ⊆ S}
#align subsemiring.closure Subsemiring.closure
-/

#print Subsemiring.mem_closure /-
theorem mem_closure {x : R} {s : Set R} : x ∈ closure s ↔ ∀ S : Subsemiring R, s ⊆ S → x ∈ S :=
  mem_sInf
#align subsemiring.mem_closure Subsemiring.mem_closure
-/

#print Subsemiring.subset_closure /-
/-- The subsemiring generated by a set includes the set. -/
@[simp]
theorem subset_closure {s : Set R} : s ⊆ closure s := fun x hx => mem_closure.2 fun S hS => hS hx
#align subsemiring.subset_closure Subsemiring.subset_closure
-/

#print Subsemiring.not_mem_of_not_mem_closure /-
theorem not_mem_of_not_mem_closure {s : Set R} {P : R} (hP : P ∉ closure s) : P ∉ s := fun h =>
  hP (subset_closure h)
#align subsemiring.not_mem_of_not_mem_closure Subsemiring.not_mem_of_not_mem_closure
-/

#print Subsemiring.closure_le /-
/-- A subsemiring `S` includes `closure s` if and only if it includes `s`. -/
@[simp]
theorem closure_le {s : Set R} {t : Subsemiring R} : closure s ≤ t ↔ s ⊆ t :=
  ⟨Set.Subset.trans subset_closure, fun h => sInf_le h⟩
#align subsemiring.closure_le Subsemiring.closure_le
-/

#print Subsemiring.closure_mono /-
/-- Subsemiring closure of a set is monotone in its argument: if `s ⊆ t`,
then `closure s ≤ closure t`. -/
theorem closure_mono ⦃s t : Set R⦄ (h : s ⊆ t) : closure s ≤ closure t :=
  closure_le.2 <| Set.Subset.trans h subset_closure
#align subsemiring.closure_mono Subsemiring.closure_mono
-/

#print Subsemiring.closure_eq_of_le /-
theorem closure_eq_of_le {s : Set R} {t : Subsemiring R} (h₁ : s ⊆ t) (h₂ : t ≤ closure s) :
    closure s = t :=
  le_antisymm (closure_le.2 h₁) h₂
#align subsemiring.closure_eq_of_le Subsemiring.closure_eq_of_le
-/

#print Subsemiring.mem_map_equiv /-
theorem mem_map_equiv {f : R ≃+* S} {K : Subsemiring R} {x : S} :
    x ∈ K.map (f : R →+* S) ↔ f.symm x ∈ K :=
  @Set.mem_image_equiv _ _ (↑K) f.toEquiv x
#align subsemiring.mem_map_equiv Subsemiring.mem_map_equiv
-/

#print Subsemiring.map_equiv_eq_comap_symm /-
theorem map_equiv_eq_comap_symm (f : R ≃+* S) (K : Subsemiring R) :
    K.map (f : R →+* S) = K.comap f.symm :=
  SetLike.coe_injective (f.toEquiv.image_eq_preimage K)
#align subsemiring.map_equiv_eq_comap_symm Subsemiring.map_equiv_eq_comap_symm
-/

#print Subsemiring.comap_equiv_eq_map_symm /-
theorem comap_equiv_eq_map_symm (f : R ≃+* S) (K : Subsemiring S) :
    K.comap (f : R →+* S) = K.map f.symm :=
  (map_equiv_eq_comap_symm f.symm K).symm
#align subsemiring.comap_equiv_eq_map_symm Subsemiring.comap_equiv_eq_map_symm
-/

end Subsemiring

namespace Submonoid

#print Submonoid.subsemiringClosure /-
/-- The additive closure of a submonoid is a subsemiring. -/
def subsemiringClosure (M : Submonoid R) : Subsemiring R :=
  {
    AddSubmonoid.closure
      (M : Set
          R) with
    one_mem' := AddSubmonoid.mem_closure.mpr fun y hy => hy M.one_mem
    mul_mem' := fun x y => MulMemClass.mul_mem_add_closure }
#align submonoid.subsemiring_closure Submonoid.subsemiringClosure
-/

#print Submonoid.subsemiringClosure_coe /-
theorem subsemiringClosure_coe :
    (M.subsemiringClosure : Set R) = AddSubmonoid.closure (M : Set R) :=
  rfl
#align submonoid.subsemiring_closure_coe Submonoid.subsemiringClosure_coe
-/

#print Submonoid.subsemiringClosure_toAddSubmonoid /-
theorem subsemiringClosure_toAddSubmonoid :
    M.subsemiringClosure.toAddSubmonoid = AddSubmonoid.closure (M : Set R) :=
  rfl
#align submonoid.subsemiring_closure_to_add_submonoid Submonoid.subsemiringClosure_toAddSubmonoid
-/

#print Submonoid.subsemiringClosure_eq_closure /-
/-- The `subsemiring` generated by a multiplicative submonoid coincides with the
`subsemiring.closure` of the submonoid itself . -/
theorem subsemiringClosure_eq_closure : M.subsemiringClosure = Subsemiring.closure (M : Set R) :=
  by
  ext
  refine'
        ⟨fun hx => _, fun hx =>
          (subsemiring.mem_closure.mp hx) M.subsemiring_closure fun s sM => _⟩ <;>
      rintro - ⟨H1, rfl⟩ <;>
    rintro - ⟨H2, rfl⟩
  · exact add_submonoid.mem_closure.mp hx H1.to_add_submonoid H2
  · exact H2 sM
#align submonoid.subsemiring_closure_eq_closure Submonoid.subsemiringClosure_eq_closure
-/

end Submonoid

namespace Subsemiring

#print Subsemiring.closure_submonoid_closure /-
@[simp]
theorem closure_submonoid_closure (s : Set R) : closure ↑(Submonoid.closure s) = closure s :=
  le_antisymm
    (closure_le.mpr fun y hy =>
      (Submonoid.mem_closure.mp hy) (closure s).toSubmonoid subset_closure)
    (closure_mono Submonoid.subset_closure)
#align subsemiring.closure_submonoid_closure Subsemiring.closure_submonoid_closure
-/

#print Subsemiring.coe_closure_eq /-
/-- The elements of the subsemiring closure of `M` are exactly the elements of the additive closure
of a multiplicative submonoid `M`. -/
theorem coe_closure_eq (s : Set R) :
    (closure s : Set R) = AddSubmonoid.closure (Submonoid.closure s : Set R) := by
  simp [← Submonoid.subsemiringClosure_toAddSubmonoid, Submonoid.subsemiringClosure_eq_closure]
#align subsemiring.coe_closure_eq Subsemiring.coe_closure_eq
-/

#print Subsemiring.mem_closure_iff /-
theorem mem_closure_iff {s : Set R} {x} :
    x ∈ closure s ↔ x ∈ AddSubmonoid.closure (Submonoid.closure s : Set R) :=
  Set.ext_iff.mp (coe_closure_eq s) x
#align subsemiring.mem_closure_iff Subsemiring.mem_closure_iff
-/

#print Subsemiring.closure_addSubmonoid_closure /-
@[simp]
theorem closure_addSubmonoid_closure {s : Set R} : closure ↑(AddSubmonoid.closure s) = closure s :=
  by
  ext x
  refine' ⟨fun hx => _, fun hx => closure_mono AddSubmonoid.subset_closure hx⟩
  rintro - ⟨H, rfl⟩
  rintro - ⟨J, rfl⟩
  refine' (add_submonoid.mem_closure.mp (mem_closure_iff.mp hx)) H.to_add_submonoid fun y hy => _
  refine' (submonoid.mem_closure.mp hy) H.to_submonoid fun z hz => _
  exact (add_submonoid.mem_closure.mp hz) H.to_add_submonoid fun w hw => J hw
#align subsemiring.closure_add_submonoid_closure Subsemiring.closure_addSubmonoid_closure
-/

#print Subsemiring.closure_induction /-
/-- An induction principle for closure membership. If `p` holds for `0`, `1`, and all elements
of `s`, and is preserved under addition and multiplication, then `p` holds for all elements
of the closure of `s`. -/
@[elab_as_elim]
theorem closure_induction {s : Set R} {p : R → Prop} {x} (h : x ∈ closure s) (Hs : ∀ x ∈ s, p x)
    (H0 : p 0) (H1 : p 1) (Hadd : ∀ x y, p x → p y → p (x + y))
    (Hmul : ∀ x y, p x → p y → p (x * y)) : p x :=
  (@closure_le _ _ _ ⟨p, Hmul, H1, Hadd, H0⟩).2 Hs h
#align subsemiring.closure_induction Subsemiring.closure_induction
-/

#print Subsemiring.closure_induction₂ /-
/-- An induction principle for closure membership for predicates with two arguments. -/
@[elab_as_elim]
theorem closure_induction₂ {s : Set R} {p : R → R → Prop} {x} {y : R} (hx : x ∈ closure s)
    (hy : y ∈ closure s) (Hs : ∀ x ∈ s, ∀ y ∈ s, p x y) (H0_left : ∀ x, p 0 x)
    (H0_right : ∀ x, p x 0) (H1_left : ∀ x, p 1 x) (H1_right : ∀ x, p x 1)
    (Hadd_left : ∀ x₁ x₂ y, p x₁ y → p x₂ y → p (x₁ + x₂) y)
    (Hadd_right : ∀ x y₁ y₂, p x y₁ → p x y₂ → p x (y₁ + y₂))
    (Hmul_left : ∀ x₁ x₂ y, p x₁ y → p x₂ y → p (x₁ * x₂) y)
    (Hmul_right : ∀ x y₁ y₂, p x y₁ → p x y₂ → p x (y₁ * y₂)) : p x y :=
  closure_induction hx
    (fun x₁ x₁s =>
      closure_induction hy (Hs x₁ x₁s) (H0_right x₁) (H1_right x₁) (Hadd_right x₁) (Hmul_right x₁))
    (H0_left y) (H1_left y) (fun z z' => Hadd_left z z' y) fun z z' => Hmul_left z z' y
#align subsemiring.closure_induction₂ Subsemiring.closure_induction₂
-/

#print Subsemiring.mem_closure_iff_exists_list /-
theorem mem_closure_iff_exists_list {R} [Semiring R] {s : Set R} {x} :
    x ∈ closure s ↔ ∃ L : List (List R), (∀ t ∈ L, ∀ y ∈ t, y ∈ s) ∧ (L.map List.prod).Sum = x :=
  ⟨fun hx =>
    AddSubmonoid.closure_induction (mem_closure_iff.1 hx)
      (fun x hx =>
        suffices ∃ t : List R, (∀ y ∈ t, y ∈ s) ∧ t.Prod = x from
          let ⟨t, ht1, ht2⟩ := this
          ⟨[t], List.forall_mem_singleton.2 ht1, by
            rw [List.map_singleton, List.sum_singleton, ht2]⟩
        Submonoid.closure_induction hx
          (fun x hx => ⟨[x], List.forall_mem_singleton.2 hx, one_mul x⟩)
          ⟨[], List.forall_mem_nil _, rfl⟩ fun x y ⟨t, ht1, ht2⟩ ⟨u, hu1, hu2⟩ =>
          ⟨t ++ u, List.forall_mem_append.2 ⟨ht1, hu1⟩, by rw [List.prod_append, ht2, hu2]⟩)
      ⟨[], List.forall_mem_nil _, rfl⟩ fun x y ⟨L, HL1, HL2⟩ ⟨M, HM1, HM2⟩ =>
      ⟨L ++ M, List.forall_mem_append.2 ⟨HL1, HM1⟩, by
        rw [List.map_append, List.sum_append, HL2, HM2]⟩,
    fun ⟨L, HL1, HL2⟩ =>
    HL2 ▸
      list_sum_mem fun r hr =>
        let ⟨t, ht1, ht2⟩ := List.mem_map.1 hr
        ht2 ▸ list_prod_mem _ fun y hy => subset_closure <| HL1 t ht1 y hy⟩
#align subsemiring.mem_closure_iff_exists_list Subsemiring.mem_closure_iff_exists_list
-/

variable (R)

#print Subsemiring.gi /-
/-- `closure` forms a Galois insertion with the coercion to set. -/
protected def gi : GaloisInsertion (@closure R _) coe
    where
  choice s _ := closure s
  gc s t := closure_le
  le_l_u s := subset_closure
  choice_eq s h := rfl
#align subsemiring.gi Subsemiring.gi
-/

variable {R}

#print Subsemiring.closure_eq /-
/-- Closure of a subsemiring `S` equals `S`. -/
theorem closure_eq (s : Subsemiring R) : closure (s : Set R) = s :=
  (Subsemiring.gi R).l_u_eq s
#align subsemiring.closure_eq Subsemiring.closure_eq
-/

#print Subsemiring.closure_empty /-
@[simp]
theorem closure_empty : closure (∅ : Set R) = ⊥ :=
  (Subsemiring.gi R).gc.l_bot
#align subsemiring.closure_empty Subsemiring.closure_empty
-/

#print Subsemiring.closure_univ /-
@[simp]
theorem closure_univ : closure (Set.univ : Set R) = ⊤ :=
  @coe_top R _ ▸ closure_eq ⊤
#align subsemiring.closure_univ Subsemiring.closure_univ
-/

#print Subsemiring.closure_union /-
theorem closure_union (s t : Set R) : closure (s ∪ t) = closure s ⊔ closure t :=
  (Subsemiring.gi R).gc.l_sup
#align subsemiring.closure_union Subsemiring.closure_union
-/

#print Subsemiring.closure_iUnion /-
theorem closure_iUnion {ι} (s : ι → Set R) : closure (⋃ i, s i) = ⨆ i, closure (s i) :=
  (Subsemiring.gi R).gc.l_iSup
#align subsemiring.closure_Union Subsemiring.closure_iUnion
-/

#print Subsemiring.closure_sUnion /-
theorem closure_sUnion (s : Set (Set R)) : closure (⋃₀ s) = ⨆ t ∈ s, closure t :=
  (Subsemiring.gi R).gc.l_sSup
#align subsemiring.closure_sUnion Subsemiring.closure_sUnion
-/

#print Subsemiring.map_sup /-
theorem map_sup (s t : Subsemiring R) (f : R →+* S) : (s ⊔ t).map f = s.map f ⊔ t.map f :=
  (gc_map_comap f).l_sup
#align subsemiring.map_sup Subsemiring.map_sup
-/

#print Subsemiring.map_iSup /-
theorem map_iSup {ι : Sort _} (f : R →+* S) (s : ι → Subsemiring R) :
    (iSup s).map f = ⨆ i, (s i).map f :=
  (gc_map_comap f).l_iSup
#align subsemiring.map_supr Subsemiring.map_iSup
-/

#print Subsemiring.comap_inf /-
theorem comap_inf (s t : Subsemiring S) (f : R →+* S) : (s ⊓ t).comap f = s.comap f ⊓ t.comap f :=
  (gc_map_comap f).u_inf
#align subsemiring.comap_inf Subsemiring.comap_inf
-/

#print Subsemiring.comap_iInf /-
theorem comap_iInf {ι : Sort _} (f : R →+* S) (s : ι → Subsemiring S) :
    (iInf s).comap f = ⨅ i, (s i).comap f :=
  (gc_map_comap f).u_iInf
#align subsemiring.comap_infi Subsemiring.comap_iInf
-/

#print Subsemiring.map_bot /-
@[simp]
theorem map_bot (f : R →+* S) : (⊥ : Subsemiring R).map f = ⊥ :=
  (gc_map_comap f).l_bot
#align subsemiring.map_bot Subsemiring.map_bot
-/

#print Subsemiring.comap_top /-
@[simp]
theorem comap_top (f : R →+* S) : (⊤ : Subsemiring S).comap f = ⊤ :=
  (gc_map_comap f).u_top
#align subsemiring.comap_top Subsemiring.comap_top
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Subsemiring.prod /-
/-- Given `subsemiring`s `s`, `t` of semirings `R`, `S` respectively, `s.prod t` is `s × t`
as a subsemiring of `R × S`. -/
def prod (s : Subsemiring R) (t : Subsemiring S) : Subsemiring (R × S) :=
  { s.toSubmonoid.Prod t.toSubmonoid, s.toAddSubmonoid.Prod t.toAddSubmonoid with
    carrier := s ×ˢ t }
#align subsemiring.prod Subsemiring.prod
-/

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
#print Subsemiring.coe_prod /-
@[norm_cast]
theorem coe_prod (s : Subsemiring R) (t : Subsemiring S) : (s.Prod t : Set (R × S)) = s ×ˢ t :=
  rfl
#align subsemiring.coe_prod Subsemiring.coe_prod
-/

#print Subsemiring.mem_prod /-
theorem mem_prod {s : Subsemiring R} {t : Subsemiring S} {p : R × S} :
    p ∈ s.Prod t ↔ p.1 ∈ s ∧ p.2 ∈ t :=
  Iff.rfl
#align subsemiring.mem_prod Subsemiring.mem_prod
-/

#print Subsemiring.prod_mono /-
@[mono]
theorem prod_mono ⦃s₁ s₂ : Subsemiring R⦄ (hs : s₁ ≤ s₂) ⦃t₁ t₂ : Subsemiring S⦄ (ht : t₁ ≤ t₂) :
    s₁.Prod t₁ ≤ s₂.Prod t₂ :=
  Set.prod_mono hs ht
#align subsemiring.prod_mono Subsemiring.prod_mono
-/

#print Subsemiring.prod_mono_right /-
theorem prod_mono_right (s : Subsemiring R) : Monotone fun t : Subsemiring S => s.Prod t :=
  prod_mono (le_refl s)
#align subsemiring.prod_mono_right Subsemiring.prod_mono_right
-/

#print Subsemiring.prod_mono_left /-
theorem prod_mono_left (t : Subsemiring S) : Monotone fun s : Subsemiring R => s.Prod t :=
  fun s₁ s₂ hs => prod_mono hs (le_refl t)
#align subsemiring.prod_mono_left Subsemiring.prod_mono_left
-/

#print Subsemiring.prod_top /-
theorem prod_top (s : Subsemiring R) : s.Prod (⊤ : Subsemiring S) = s.comap (RingHom.fst R S) :=
  ext fun x => by simp [mem_prod, MonoidHom.coe_fst]
#align subsemiring.prod_top Subsemiring.prod_top
-/

#print Subsemiring.top_prod /-
theorem top_prod (s : Subsemiring S) : (⊤ : Subsemiring R).Prod s = s.comap (RingHom.snd R S) :=
  ext fun x => by simp [mem_prod, MonoidHom.coe_snd]
#align subsemiring.top_prod Subsemiring.top_prod
-/

#print Subsemiring.top_prod_top /-
@[simp]
theorem top_prod_top : (⊤ : Subsemiring R).Prod (⊤ : Subsemiring S) = ⊤ :=
  (top_prod _).trans <| comap_top _
#align subsemiring.top_prod_top Subsemiring.top_prod_top
-/

#print Subsemiring.prodEquiv /-
/-- Product of subsemirings is isomorphic to their product as monoids. -/
def prodEquiv (s : Subsemiring R) (t : Subsemiring S) : s.Prod t ≃+* s × t :=
  { Equiv.Set.prod ↑s ↑t with
    map_mul' := fun x y => rfl
    map_add' := fun x y => rfl }
#align subsemiring.prod_equiv Subsemiring.prodEquiv
-/

#print Subsemiring.mem_iSup_of_directed /-
theorem mem_iSup_of_directed {ι} [hι : Nonempty ι] {S : ι → Subsemiring R} (hS : Directed (· ≤ ·) S)
    {x : R} : (x ∈ ⨆ i, S i) ↔ ∃ i, x ∈ S i :=
  by
  refine' ⟨_, fun ⟨i, hi⟩ => (SetLike.le_def.1 <| le_iSup S i) hi⟩
  let U : Subsemiring R :=
    Subsemiring.mk' (⋃ i, (S i : Set R)) (⨆ i, (S i).toSubmonoid)
      (Submonoid.coe_iSup_of_directed <| hS.mono_comp _ fun _ _ => id) (⨆ i, (S i).toAddSubmonoid)
      (AddSubmonoid.coe_iSup_of_directed <| hS.mono_comp _ fun _ _ => id)
  suffices (⨆ i, S i) ≤ U by simpa using @this x
  exact iSup_le fun i x hx => Set.mem_iUnion.2 ⟨i, hx⟩
#align subsemiring.mem_supr_of_directed Subsemiring.mem_iSup_of_directed
-/

#print Subsemiring.coe_iSup_of_directed /-
theorem coe_iSup_of_directed {ι} [hι : Nonempty ι] {S : ι → Subsemiring R}
    (hS : Directed (· ≤ ·) S) : ((⨆ i, S i : Subsemiring R) : Set R) = ⋃ i, ↑(S i) :=
  Set.ext fun x => by simp [mem_supr_of_directed hS]
#align subsemiring.coe_supr_of_directed Subsemiring.coe_iSup_of_directed
-/

#print Subsemiring.mem_sSup_of_directedOn /-
theorem mem_sSup_of_directedOn {S : Set (Subsemiring R)} (Sne : S.Nonempty)
    (hS : DirectedOn (· ≤ ·) S) {x : R} : x ∈ sSup S ↔ ∃ s ∈ S, x ∈ s :=
  by
  haveI : Nonempty S := Sne.to_subtype
  simp only [sSup_eq_iSup', mem_supr_of_directed hS.directed_coe, SetCoe.exists, Subtype.coe_mk]
#align subsemiring.mem_Sup_of_directed_on Subsemiring.mem_sSup_of_directedOn
-/

#print Subsemiring.coe_sSup_of_directedOn /-
theorem coe_sSup_of_directedOn {S : Set (Subsemiring R)} (Sne : S.Nonempty)
    (hS : DirectedOn (· ≤ ·) S) : (↑(sSup S) : Set R) = ⋃ s ∈ S, ↑s :=
  Set.ext fun x => by simp [mem_Sup_of_directed_on Sne hS]
#align subsemiring.coe_Sup_of_directed_on Subsemiring.coe_sSup_of_directedOn
-/

end Subsemiring

namespace RingHom

variable [NonAssocSemiring T] {s : Subsemiring R}

variable {σR σS : Type _}

variable [SetLike σR R] [SetLike σS S] [SubsemiringClass σR R] [SubsemiringClass σS S]

open Subsemiring

#print RingHom.domRestrict /-
/-- Restriction of a ring homomorphism to a subsemiring of the domain. -/
def domRestrict (f : R →+* S) (s : σR) : s →+* S :=
  f.comp <| SubsemiringClass.subtype s
#align ring_hom.dom_restrict RingHom.domRestrict
-/

#print RingHom.restrict_apply /-
@[simp]
theorem restrict_apply (f : R →+* S) {s : σR} (x : s) : f.domRestrict s x = f x :=
  rfl
#align ring_hom.restrict_apply RingHom.restrict_apply
-/

#print RingHom.codRestrict /-
/-- Restriction of a ring homomorphism to a subsemiring of the codomain. -/
def codRestrict (f : R →+* S) (s : σS) (h : ∀ x, f x ∈ s) : R →+* s :=
  { (f : R →* S).codRestrict s h, (f : R →+ S).codRestrict s h with toFun := fun n => ⟨f n, h n⟩ }
#align ring_hom.cod_restrict RingHom.codRestrict
-/

#print RingHom.restrict /-
/-- The ring homomorphism from the preimage of `s` to `s`. -/
def restrict (f : R →+* S) (s' : σR) (s : σS) (h : ∀ x ∈ s', f x ∈ s) : s' →+* s :=
  (f.domRestrict s').codRestrict s fun x => h x x.2
#align ring_hom.restrict RingHom.restrict
-/

#print RingHom.coe_restrict_apply /-
@[simp]
theorem coe_restrict_apply (f : R →+* S) (s' : σR) (s : σS) (h : ∀ x ∈ s', f x ∈ s) (x : s') :
    (f.restrict s' s h x : S) = f x :=
  rfl
#align ring_hom.coe_restrict_apply RingHom.coe_restrict_apply
-/

#print RingHom.comp_restrict /-
@[simp]
theorem comp_restrict (f : R →+* S) (s' : σR) (s : σS) (h : ∀ x ∈ s', f x ∈ s) :
    (SubsemiringClass.subtype s).comp (f.restrict s' s h) = f.comp (SubsemiringClass.subtype s') :=
  rfl
#align ring_hom.comp_restrict RingHom.comp_restrict
-/

#print RingHom.rangeSRestrict /-
/-- Restriction of a ring homomorphism to its range interpreted as a subsemiring.

This is the bundled version of `set.range_factorization`. -/
def rangeSRestrict (f : R →+* S) : R →+* f.srange :=
  f.codRestrict f.srange f.mem_rangeS_self
#align ring_hom.srange_restrict RingHom.rangeSRestrict
-/

#print RingHom.coe_rangeSRestrict /-
@[simp]
theorem coe_rangeSRestrict (f : R →+* S) (x : R) : (f.srangeRestrict x : S) = f x :=
  rfl
#align ring_hom.coe_srange_restrict RingHom.coe_rangeSRestrict
-/

#print RingHom.rangeSRestrict_surjective /-
theorem rangeSRestrict_surjective (f : R →+* S) : Function.Surjective f.srangeRestrict :=
  fun ⟨y, hy⟩ =>
  let ⟨x, hx⟩ := mem_rangeS.mp hy
  ⟨x, Subtype.ext hx⟩
#align ring_hom.srange_restrict_surjective RingHom.rangeSRestrict_surjective
-/

#print RingHom.rangeS_top_iff_surjective /-
theorem rangeS_top_iff_surjective {f : R →+* S} :
    f.srange = (⊤ : Subsemiring S) ↔ Function.Surjective f :=
  SetLike.ext'_iff.trans <| Iff.trans (by rw [coe_srange, coe_top]) Set.range_iff_surjective
#align ring_hom.srange_top_iff_surjective RingHom.rangeS_top_iff_surjective
-/

#print RingHom.rangeS_top_of_surjective /-
/-- The range of a surjective ring homomorphism is the whole of the codomain. -/
theorem rangeS_top_of_surjective (f : R →+* S) (hf : Function.Surjective f) :
    f.srange = (⊤ : Subsemiring S) :=
  rangeS_top_iff_surjective.2 hf
#align ring_hom.srange_top_of_surjective RingHom.rangeS_top_of_surjective
-/

#print RingHom.eqLocusS /-
/-- The subsemiring of elements `x : R` such that `f x = g x` -/
def eqLocusS (f g : R →+* S) : Subsemiring R :=
  { (f : R →* S).eqLocus g, (f : R →+ S).eqLocus g with carrier := {x | f x = g x} }
#align ring_hom.eq_slocus RingHom.eqLocusS
-/

#print RingHom.eqLocusS_same /-
@[simp]
theorem eqLocusS_same (f : R →+* S) : f.eqLocusS f = ⊤ :=
  SetLike.ext fun _ => eq_self_iff_true _
#align ring_hom.eq_slocus_same RingHom.eqLocusS_same
-/

#print RingHom.eqOn_sclosure /-
/-- If two ring homomorphisms are equal on a set, then they are equal on its subsemiring closure. -/
theorem eqOn_sclosure {f g : R →+* S} {s : Set R} (h : Set.EqOn f g s) : Set.EqOn f g (closure s) :=
  show closure s ≤ f.eqLocusS g from closure_le.2 h
#align ring_hom.eq_on_sclosure RingHom.eqOn_sclosure
-/

#print RingHom.eq_of_eqOn_stop /-
theorem eq_of_eqOn_stop {f g : R →+* S} (h : Set.EqOn f g (⊤ : Subsemiring R)) : f = g :=
  ext fun x => h trivial
#align ring_hom.eq_of_eq_on_stop RingHom.eq_of_eqOn_stop
-/

#print RingHom.eq_of_eqOn_sdense /-
theorem eq_of_eqOn_sdense {s : Set R} (hs : closure s = ⊤) {f g : R →+* S} (h : s.EqOn f g) :
    f = g :=
  eq_of_eqOn_stop <| hs ▸ eqOn_sclosure h
#align ring_hom.eq_of_eq_on_sdense RingHom.eq_of_eqOn_sdense
-/

#print RingHom.sclosure_preimage_le /-
theorem sclosure_preimage_le (f : R →+* S) (s : Set S) : closure (f ⁻¹' s) ≤ (closure s).comap f :=
  closure_le.2 fun x hx => SetLike.mem_coe.2 <| mem_comap.2 <| subset_closure hx
#align ring_hom.sclosure_preimage_le RingHom.sclosure_preimage_le
-/

#print RingHom.map_closureS /-
/-- The image under a ring homomorphism of the subsemiring generated by a set equals
the subsemiring generated by the image of the set. -/
theorem map_closureS (f : R →+* S) (s : Set R) : (closure s).map f = closure (f '' s) :=
  le_antisymm
    (map_le_iff_le_comap.2 <|
      le_trans (closure_mono <| Set.subset_preimage_image _ _) (sclosure_preimage_le _ _))
    (closure_le.2 <| Set.image_subset _ subset_closure)
#align ring_hom.map_sclosure RingHom.map_closureS
-/

end RingHom

namespace Subsemiring

open RingHom

#print Subsemiring.inclusion /-
/-- The ring homomorphism associated to an inclusion of subsemirings. -/
def inclusion {S T : Subsemiring R} (h : S ≤ T) : S →+* T :=
  S.Subtype.codRestrict _ fun x => h x.2
#align subsemiring.inclusion Subsemiring.inclusion
-/

#print Subsemiring.rangeS_subtype /-
@[simp]
theorem rangeS_subtype (s : Subsemiring R) : s.Subtype.srange = s :=
  SetLike.coe_injective <| (coe_rangeS _).trans Subtype.range_coe
#align subsemiring.srange_subtype Subsemiring.rangeS_subtype
-/

#print Subsemiring.range_fst /-
@[simp]
theorem range_fst : (fst R S).srange = ⊤ :=
  (fst R S).srange_top_of_surjective <| Prod.fst_surjective
#align subsemiring.range_fst Subsemiring.range_fst
-/

#print Subsemiring.range_snd /-
@[simp]
theorem range_snd : (snd R S).srange = ⊤ :=
  (snd R S).srange_top_of_surjective <| Prod.snd_surjective
#align subsemiring.range_snd Subsemiring.range_snd
-/

#print Subsemiring.prod_bot_sup_bot_prod /-
@[simp]
theorem prod_bot_sup_bot_prod (s : Subsemiring R) (t : Subsemiring S) :
    s.Prod ⊥ ⊔ prod ⊥ t = s.Prod t :=
  le_antisymm (sup_le (prod_mono_right s bot_le) (prod_mono_left t bot_le)) fun p hp =>
    Prod.fst_mul_snd p ▸
      mul_mem
        ((le_sup_left : s.Prod ⊥ ≤ s.Prod ⊥ ⊔ prod ⊥ t) ⟨hp.1, SetLike.mem_coe.2 <| one_mem ⊥⟩)
        ((le_sup_right : prod ⊥ t ≤ s.Prod ⊥ ⊔ prod ⊥ t) ⟨SetLike.mem_coe.2 <| one_mem ⊥, hp.2⟩)
#align subsemiring.prod_bot_sup_bot_prod Subsemiring.prod_bot_sup_bot_prod
-/

end Subsemiring

namespace RingEquiv

variable {s t : Subsemiring R}

#print RingEquiv.subsemiringCongr /-
/-- Makes the identity isomorphism from a proof two subsemirings of a multiplicative
    monoid are equal. -/
def subsemiringCongr (h : s = t) : s ≃+* t :=
  {
    Equiv.setCongr <| congr_arg _ h with
    map_mul' := fun _ _ => rfl
    map_add' := fun _ _ => rfl }
#align ring_equiv.subsemiring_congr RingEquiv.subsemiringCongr
-/

#print RingEquiv.ofLeftInverseS /-
/-- Restrict a ring homomorphism with a left inverse to a ring isomorphism to its
`ring_hom.srange`. -/
def ofLeftInverseS {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f) : R ≃+* f.srange :=
  { f.srangeRestrict with
    toFun := fun x => f.srangeRestrict x
    invFun := fun x => (g ∘ f.srange.Subtype) x
    left_inv := h
    right_inv := fun x =>
      Subtype.ext <|
        let ⟨x', hx'⟩ := RingHom.mem_rangeS.mp x.Prop
        show f (g x) = x by rw [← hx', h x'] }
#align ring_equiv.sof_left_inverse RingEquiv.ofLeftInverseS
-/

#print RingEquiv.ofLeftInverseS_apply /-
@[simp]
theorem ofLeftInverseS_apply {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f) (x : R) :
    ↑(ofLeftInverseS h x) = f x :=
  rfl
#align ring_equiv.sof_left_inverse_apply RingEquiv.ofLeftInverseS_apply
-/

#print RingEquiv.ofLeftInverseS_symm_apply /-
@[simp]
theorem ofLeftInverseS_symm_apply {g : S → R} {f : R →+* S} (h : Function.LeftInverse g f)
    (x : f.srange) : (ofLeftInverseS h).symm x = g x :=
  rfl
#align ring_equiv.sof_left_inverse_symm_apply RingEquiv.ofLeftInverseS_symm_apply
-/

#print RingEquiv.subsemiringMap /-
/-- Given an equivalence `e : R ≃+* S` of semirings and a subsemiring `s` of `R`,
`subsemiring_map e s` is the induced equivalence between `s` and `s.map e` -/
@[simps]
def subsemiringMap (e : R ≃+* S) (s : Subsemiring R) : s ≃+* s.map e.toRingHom :=
  { e.toAddEquiv.addSubmonoidMap s.toAddSubmonoid, e.toMulEquiv.submonoidMap s.toSubmonoid with }
#align ring_equiv.subsemiring_map RingEquiv.subsemiringMap
-/

end RingEquiv

/-! ### Actions by `subsemiring`s

These are just copies of the definitions about `submonoid` starting from `submonoid.mul_action`.
The only new result is `subsemiring.module`.

When `R` is commutative, `algebra.of_subsemiring` provides a stronger result than those found in
this file, which uses the same scalar action.
-/


section Actions

namespace Subsemiring

variable {R' α β : Type _}

section NonAssocSemiring

variable [NonAssocSemiring R']

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [SMul R' α] (S : Subsemiring R') : SMul S α :=
  S.toSubmonoid.SMul

#print Subsemiring.smul_def /-
theorem smul_def [SMul R' α] {S : Subsemiring R'} (g : S) (m : α) : g • m = (g : R') • m :=
  rfl
#align subsemiring.smul_def Subsemiring.smul_def
-/

#print Subsemiring.smulCommClass_left /-
instance smulCommClass_left [SMul R' β] [SMul α β] [SMulCommClass R' α β] (S : Subsemiring R') :
    SMulCommClass S α β :=
  S.toSubmonoid.smulCommClass_left
#align subsemiring.smul_comm_class_left Subsemiring.smulCommClass_left
-/

#print Subsemiring.smulCommClass_right /-
instance smulCommClass_right [SMul α β] [SMul R' β] [SMulCommClass α R' β] (S : Subsemiring R') :
    SMulCommClass α S β :=
  S.toSubmonoid.smulCommClass_right
#align subsemiring.smul_comm_class_right Subsemiring.smulCommClass_right
-/

/-- Note that this provides `is_scalar_tower S R R` which is needed by `smul_mul_assoc`. -/
instance [SMul α β] [SMul R' α] [SMul R' β] [IsScalarTower R' α β] (S : Subsemiring R') :
    IsScalarTower S α β :=
  S.toSubmonoid.IsScalarTower

instance [SMul R' α] [FaithfulSMul R' α] (S : Subsemiring R') : FaithfulSMul S α :=
  S.toSubmonoid.FaithfulSMul

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Zero α] [SMulWithZero R' α] (S : Subsemiring R') : SMulWithZero S α :=
  SMulWithZero.compHom _ S.Subtype.toMonoidWithZeroHom.toZeroHom

end NonAssocSemiring

variable [Semiring R']

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [MulAction R' α] (S : Subsemiring R') : MulAction S α :=
  S.toSubmonoid.MulAction

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [AddMonoid α] [DistribMulAction R' α] (S : Subsemiring R') : DistribMulAction S α :=
  S.toSubmonoid.DistribMulAction

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Monoid α] [MulDistribMulAction R' α] (S : Subsemiring R') : MulDistribMulAction S α :=
  S.toSubmonoid.MulDistribMulAction

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Zero α] [MulActionWithZero R' α] (S : Subsemiring R') : MulActionWithZero S α :=
  MulActionWithZero.compHom _ S.Subtype.toMonoidWithZeroHom

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [AddCommMonoid α] [Module R' α] (S : Subsemiring R') : Module S α :=
  { Module.compHom _ S.Subtype with smul := (· • ·) }

/-- The action by a subsemiring is the action by the underlying semiring. -/
instance [Semiring α] [MulSemiringAction R' α] (S : Subsemiring R') : MulSemiringAction S α :=
  S.toSubmonoid.MulSemiringAction

#print Subsemiring.center.smulCommClass_left /-
/-- The center of a semiring acts commutatively on that semiring. -/
instance center.smulCommClass_left : SMulCommClass (center R') R' R' :=
  Submonoid.center.smulCommClass_left
#align subsemiring.center.smul_comm_class_left Subsemiring.center.smulCommClass_left
-/

#print Subsemiring.center.smulCommClass_right /-
/-- The center of a semiring acts commutatively on that semiring. -/
instance center.smulCommClass_right : SMulCommClass R' (center R') R' :=
  Submonoid.center.smulCommClass_right
#align subsemiring.center.smul_comm_class_right Subsemiring.center.smulCommClass_right
-/

#print Subsemiring.closureCommSemiringOfComm /-
/-- If all the elements of a set `s` commute, then `closure s` is a commutative monoid. -/
def closureCommSemiringOfComm {s : Set R'} (hcomm : ∀ a ∈ s, ∀ b ∈ s, a * b = b * a) :
    CommSemiring (closure s) :=
  { (closure s).toSemiring with
    mul_comm := fun x y => by
      ext
      simp only [Subsemiring.coe_mul]
      refine'
        closure_induction₂ x.prop y.prop hcomm
          (fun x => by simp only [MulZeroClass.zero_mul, MulZeroClass.mul_zero])
          (fun x => by simp only [MulZeroClass.zero_mul, MulZeroClass.mul_zero])
          (fun x => by simp only [one_mul, mul_one]) (fun x => by simp only [one_mul, mul_one])
          (fun x y z h₁ h₂ => by simp only [add_mul, mul_add, h₁, h₂])
          (fun x y z h₁ h₂ => by simp only [add_mul, mul_add, h₁, h₂])
          (fun x y z h₁ h₂ => by rw [mul_assoc, h₂, ← mul_assoc, h₁, mul_assoc]) fun x y z h₁ h₂ =>
          by rw [← mul_assoc, h₁, mul_assoc, h₂, ← mul_assoc] }
#align subsemiring.closure_comm_semiring_of_comm Subsemiring.closureCommSemiringOfComm
-/

end Subsemiring

end Actions

#print posSubmonoid /-
-- While this definition is not about `subsemiring`s, this is the earliest we have
-- both `strict_ordered_semiring` and `submonoid` available.
/-- Submonoid of positive elements of an ordered semiring. -/
def posSubmonoid (R : Type _) [StrictOrderedSemiring R] : Submonoid R
    where
  carrier := {x | 0 < x}
  one_mem' := show (0 : R) < 1 from zero_lt_one
  mul_mem' x y (hx : 0 < x) (hy : 0 < y) := mul_pos hx hy
#align pos_submonoid posSubmonoid
-/

#print mem_posSubmonoid /-
@[simp]
theorem mem_posSubmonoid {R : Type _} [StrictOrderedSemiring R] (u : Rˣ) :
    ↑u ∈ posSubmonoid R ↔ (0 : R) < u :=
  Iff.rfl
#align mem_pos_monoid mem_posSubmonoid
-/

