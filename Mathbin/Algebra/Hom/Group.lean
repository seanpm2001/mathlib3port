/-
Copyright (c) 2018 Patrick Massot. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Patrick Massot, Kevin Buzzard, Scott Morrison, Johan Commelin, Chris Hughes,
  Johannes Hölzl, Yury Kudryashov

! This file was ported from Lean 3 source module algebra.hom.group
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.NeZero
import Mathbin.Algebra.Group.Basic
import Mathbin.Algebra.GroupWithZero.Defs
import Mathbin.Data.FunLike.Basic

/-!
# Monoid and group homomorphisms

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the bundled structures for monoid and group homomorphisms. Namely, we define
`monoid_hom` (resp., `add_monoid_hom`) to be bundled homomorphisms between multiplicative (resp.,
additive) monoids or groups.

We also define coercion to a function, and  usual operations: composition, identity homomorphism,
pointwise multiplication and pointwise inversion.

This file also defines the lesser-used (and notation-less) homomorphism types which are used as
building blocks for other homomorphisms:

* `zero_hom`
* `one_hom`
* `add_hom`
* `mul_hom`
* `monoid_with_zero_hom`

## Notations

* `→+`: Bundled `add_monoid` homs. Also use for `add_group` homs.
* `→*`: Bundled `monoid` homs. Also use for `group` homs.
* `→*₀`: Bundled `monoid_with_zero` homs. Also use for `group_with_zero` homs.
* `→ₙ*`: Bundled `semigroup` homs.

## Implementation notes

There's a coercion from bundled homs to fun, and the canonical
notation is to use the bundled hom as a function via this coercion.

There is no `group_hom` -- the idea is that `monoid_hom` is used.
The constructor for `monoid_hom` needs a proof of `map_one` as well
as `map_mul`; a separate constructor `monoid_hom.mk'` will construct
group homs (i.e. monoid homs between groups) given only a proof
that multiplication is preserved,

Implicit `{}` brackets are often used instead of type class `[]` brackets.  This is done when the
instances can be inferred because they are implicit arguments to the type `monoid_hom`.  When they
can be inferred from the type it is faster to use this method than to use type class inference.

Historically this file also included definitions of unbundled homomorphism classes; they were
deprecated and moved to `deprecated/group`.

## Tags

monoid_hom, add_monoid_hom

-/


variable {α β M N P : Type _}

-- monoids
variable {G : Type _} {H : Type _}

-- groups
variable {F : Type _}

-- homs
-- for easy multiple inheritance
section Zero

#print ZeroHom /-
/-- `zero_hom M N` is the type of functions `M → N` that preserve zero.

When possible, instead of parametrizing results over `(f : zero_hom M N)`,
you should parametrize over `(F : Type*) [zero_hom_class F M N] (f : F)`.

When you extend this structure, make sure to also extend `zero_hom_class`.
-/
structure ZeroHom (M : Type _) (N : Type _) [Zero M] [Zero N] where
  toFun : M → N
  map_zero' : to_fun 0 = 0
#align zero_hom ZeroHom
-/

#print ZeroHomClass /-
/-- `zero_hom_class F M N` states that `F` is a type of zero-preserving homomorphisms.

You should extend this typeclass when you extend `zero_hom`.
-/
class ZeroHomClass (F : Type _) (M N : outParam <| Type _) [Zero M] [Zero N] extends
    FunLike F M fun _ => N where
  map_zero : ∀ f : F, f 0 = 0
#align zero_hom_class ZeroHomClass
-/

-- Instances and lemmas are defined below through `@[to_additive]`.
end Zero

namespace NeZero

#print NeZero.of_map /-
theorem of_map {R M} [Zero R] [Zero M] [ZeroHomClass F R M] (f : F) {r : R} [NeZero (f r)] :
    NeZero r :=
  ⟨fun h => ne (f r) <| by convert ZeroHomClass.map_zero f⟩
#align ne_zero.of_map NeZero.of_map
-/

#print NeZero.of_injective /-
theorem of_injective {R M} [Zero R] {r : R} [NeZero r] [Zero M] [ZeroHomClass F R M] {f : F}
    (hf : Function.Injective f) : NeZero (f r) :=
  ⟨by rw [← ZeroHomClass.map_zero f]; exact hf.ne (Ne r)⟩
#align ne_zero.of_injective NeZero.of_injective
-/

end NeZero

section Add

#print AddHom /-
/-- `add_hom M N` is the type of functions `M → N` that preserve addition.

When possible, instead of parametrizing results over `(f : add_hom M N)`,
you should parametrize over `(F : Type*) [add_hom_class F M N] (f : F)`.

When you extend this structure, make sure to extend `add_hom_class`.
-/
structure AddHom (M : Type _) (N : Type _) [Add M] [Add N] where
  toFun : M → N
  map_add' : ∀ x y, to_fun (x + y) = to_fun x + to_fun y
#align add_hom AddHom
-/

#print AddHomClass /-
/-- `add_hom_class F M N` states that `F` is a type of addition-preserving homomorphisms.
You should declare an instance of this typeclass when you extend `add_hom`.
-/
class AddHomClass (F : Type _) (M N : outParam <| Type _) [Add M] [Add N] extends
    FunLike F M fun _ => N where
  map_add : ∀ (f : F) (x y : M), f (x + y) = f x + f y
#align add_hom_class AddHomClass
-/

-- Instances and lemmas are defined below through `@[to_additive]`.
end Add

section add_zero

#print AddMonoidHom /-
/-- `M →+ N` is the type of functions `M → N` that preserve the `add_zero_class` structure.

`add_monoid_hom` is also used for group homomorphisms.

When possible, instead of parametrizing results over `(f : M →+ N)`,
you should parametrize over `(F : Type*) [add_monoid_hom_class F M N] (f : F)`.

When you extend this structure, make sure to extend `add_monoid_hom_class`.
-/
structure AddMonoidHom (M : Type _) (N : Type _) [AddZeroClass M] [AddZeroClass N] extends
    ZeroHom M N, AddHom M N
#align add_monoid_hom AddMonoidHom
-/

attribute [nolint doc_blame] AddMonoidHom.toAddHom

attribute [nolint doc_blame] AddMonoidHom.toZeroHom

infixr:25 " →+ " => AddMonoidHom

#print AddMonoidHomClass /-
/-- `add_monoid_hom_class F M N` states that `F` is a type of `add_zero_class`-preserving
homomorphisms.

You should also extend this typeclass when you extend `add_monoid_hom`.
-/
class AddMonoidHomClass (F : Type _) (M N : outParam <| Type _) [AddZeroClass M]
    [AddZeroClass N] extends AddHomClass F M N, ZeroHomClass F M N
#align add_monoid_hom_class AddMonoidHomClass
-/

-- Instances and lemmas are defined below through `@[to_additive]`.
end add_zero

section One

variable [One M] [One N]

#print OneHom /-
/-- `one_hom M N` is the type of functions `M → N` that preserve one.

When possible, instead of parametrizing results over `(f : one_hom M N)`,
you should parametrize over `(F : Type*) [one_hom_class F M N] (f : F)`.

When you extend this structure, make sure to also extend `one_hom_class`.
-/
@[to_additive]
structure OneHom (M : Type _) (N : Type _) [One M] [One N] where
  toFun : M → N
  map_one' : to_fun 1 = 1
#align one_hom OneHom
#align zero_hom ZeroHom
-/

#print OneHomClass /-
/-- `one_hom_class F M N` states that `F` is a type of one-preserving homomorphisms.
You should extend this typeclass when you extend `one_hom`.
-/
@[to_additive]
class OneHomClass (F : Type _) (M N : outParam <| Type _) [One M] [One N] extends
    FunLike F M fun _ => N where
  map_one : ∀ f : F, f 1 = 1
#align one_hom_class OneHomClass
#align zero_hom_class ZeroHomClass
-/

#print OneHom.oneHomClass /-
@[to_additive]
instance OneHom.oneHomClass : OneHomClass (OneHom M N) M N
    where
  coe := OneHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_one := OneHom.map_one'
#align one_hom.one_hom_class OneHom.oneHomClass
#align zero_hom.zero_hom_class ZeroHom.zeroHomClass
-/

#print map_one /-
@[simp, to_additive]
theorem map_one [OneHomClass F M N] (f : F) : f 1 = 1 :=
  OneHomClass.map_one f
#align map_one map_one
#align map_zero map_zero
-/

#print map_eq_one_iff /-
@[to_additive]
theorem map_eq_one_iff [OneHomClass F M N] (f : F) (hf : Function.Injective f) {x : M} :
    f x = 1 ↔ x = 1 :=
  hf.eq_iff' (map_one f)
#align map_eq_one_iff map_eq_one_iff
#align map_eq_zero_iff map_eq_zero_iff
-/

#print map_ne_one_iff /-
@[to_additive]
theorem map_ne_one_iff {R S F : Type _} [One R] [One S] [OneHomClass F R S] (f : F)
    (hf : Function.Injective f) {x : R} : f x ≠ 1 ↔ x ≠ 1 :=
  (map_eq_one_iff f hf).Not
#align map_ne_one_iff map_ne_one_iff
#align map_ne_zero_iff map_ne_zero_iff
-/

#print ne_one_of_map /-
@[to_additive]
theorem ne_one_of_map {R S F : Type _} [One R] [One S] [OneHomClass F R S] {f : F} {x : R}
    (hx : f x ≠ 1) : x ≠ 1 :=
  ne_of_apply_ne f <| ne_of_ne_of_eq hx (map_one f).symm
#align ne_one_of_map ne_one_of_map
#align ne_zero_of_map ne_zero_of_map
-/

@[to_additive]
instance [OneHomClass F M N] : CoeTC F (OneHom M N) :=
  ⟨fun f =>
    { toFun := f
      map_one' := map_one f }⟩

#print OneHom.coe_coe /-
@[simp, to_additive]
theorem OneHom.coe_coe [OneHomClass F M N] (f : F) : ((f : OneHom M N) : M → N) = f :=
  rfl
#align one_hom.coe_coe OneHom.coe_coe
#align zero_hom.coe_coe ZeroHom.coe_coe
-/

end One

section Mul

variable [Mul M] [Mul N]

#print MulHom /-
/-- `M →ₙ* N` is the type of functions `M → N` that preserve multiplication. The `ₙ` in the notation
stands for "non-unital" because it is intended to match the notation for `non_unital_alg_hom` and
`non_unital_ring_hom`, so a `mul_hom` is a non-unital monoid hom.

When possible, instead of parametrizing results over `(f : M →ₙ* N)`,
you should parametrize over `(F : Type*) [mul_hom_class F M N] (f : F)`.
When you extend this structure, make sure to extend `mul_hom_class`.
-/
@[to_additive]
structure MulHom (M : Type _) (N : Type _) [Mul M] [Mul N] where
  toFun : M → N
  map_mul' : ∀ x y, to_fun (x * y) = to_fun x * to_fun y
#align mul_hom MulHom
#align add_hom AddHom
-/

infixr:25 " →ₙ* " => MulHom

#print MulHomClass /-
/-- `mul_hom_class F M N` states that `F` is a type of multiplication-preserving homomorphisms.

You should declare an instance of this typeclass when you extend `mul_hom`.
-/
@[to_additive]
class MulHomClass (F : Type _) (M N : outParam <| Type _) [Mul M] [Mul N] extends
    FunLike F M fun _ => N where
  map_mul : ∀ (f : F) (x y : M), f (x * y) = f x * f y
#align mul_hom_class MulHomClass
#align add_hom_class AddHomClass
-/

#print MulHom.mulHomClass /-
@[to_additive]
instance MulHom.mulHomClass : MulHomClass (M →ₙ* N) M N
    where
  coe := MulHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_mul := MulHom.map_mul'
#align mul_hom.mul_hom_class MulHom.mulHomClass
#align add_hom.add_hom_class AddHom.addHomClass
-/

#print map_mul /-
@[simp, to_additive]
theorem map_mul [MulHomClass F M N] (f : F) (x y : M) : f (x * y) = f x * f y :=
  MulHomClass.map_mul f x y
#align map_mul map_mul
#align map_add map_add
-/

@[to_additive]
instance [MulHomClass F M N] : CoeTC F (M →ₙ* N) :=
  ⟨fun f =>
    { toFun := f
      map_mul' := map_mul f }⟩

#print MulHom.coe_coe /-
@[simp, to_additive]
theorem MulHom.coe_coe [MulHomClass F M N] (f : F) : ((f : MulHom M N) : M → N) = f :=
  rfl
#align mul_hom.coe_coe MulHom.coe_coe
#align add_hom.coe_coe AddHom.coe_coe
-/

end Mul

section mul_one

variable [MulOneClass M] [MulOneClass N]

#print MonoidHom /-
/-- `M →* N` is the type of functions `M → N` that preserve the `monoid` structure.
`monoid_hom` is also used for group homomorphisms.

When possible, instead of parametrizing results over `(f : M →+ N)`,
you should parametrize over `(F : Type*) [monoid_hom_class F M N] (f : F)`.

When you extend this structure, make sure to extend `monoid_hom_class`.
-/
@[to_additive]
structure MonoidHom (M : Type _) (N : Type _) [MulOneClass M] [MulOneClass N] extends OneHom M N,
    M →ₙ* N
#align monoid_hom MonoidHom
#align add_monoid_hom AddMonoidHom
-/

attribute [nolint doc_blame] MonoidHom.toMulHom

attribute [nolint doc_blame] MonoidHom.toOneHom

infixr:25 " →* " => MonoidHom

#print MonoidHomClass /-
/-- `monoid_hom_class F M N` states that `F` is a type of `monoid`-preserving homomorphisms.
You should also extend this typeclass when you extend `monoid_hom`. -/
@[to_additive
      "`add_monoid_hom_class F M N` states that `F` is a type of `add_monoid`-preserving homomorphisms.\nYou should also extend this typeclass when you extend `add_monoid_hom`."]
class MonoidHomClass (F : Type _) (M N : outParam <| Type _) [MulOneClass M] [MulOneClass N] extends
    MulHomClass F M N, OneHomClass F M N
#align monoid_hom_class MonoidHomClass
#align add_monoid_hom_class AddMonoidHomClass
-/

#print MonoidHom.monoidHomClass /-
@[to_additive]
instance MonoidHom.monoidHomClass : MonoidHomClass (M →* N) M N
    where
  coe := MonoidHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_mul := MonoidHom.map_mul'
  map_one := MonoidHom.map_one'
#align monoid_hom.monoid_hom_class MonoidHom.monoidHomClass
#align add_monoid_hom.add_monoid_hom_class AddMonoidHom.addMonoidHomClass
-/

@[to_additive]
instance [MonoidHomClass F M N] : CoeTC F (M →* N) :=
  ⟨fun f =>
    { toFun := f
      map_one' := map_one f
      map_mul' := map_mul f }⟩

#print MonoidHom.coe_coe /-
@[simp, to_additive]
theorem MonoidHom.coe_coe [MonoidHomClass F M N] (f : F) : ((f : M →* N) : M → N) = f :=
  rfl
#align monoid_hom.coe_coe MonoidHom.coe_coe
#align add_monoid_hom.coe_coe AddMonoidHom.coe_coe
-/

#print map_mul_eq_one /-
@[to_additive]
theorem map_mul_eq_one [MonoidHomClass F M N] (f : F) {a b : M} (h : a * b = 1) : f a * f b = 1 :=
  by rw [← map_mul, h, map_one]
#align map_mul_eq_one map_mul_eq_one
#align map_add_eq_zero map_add_eq_zero
-/

#print map_div' /-
@[to_additive]
theorem map_div' [DivInvMonoid G] [DivInvMonoid H] [MonoidHomClass F G H] (f : F)
    (hf : ∀ a, f a⁻¹ = (f a)⁻¹) (a b : G) : f (a / b) = f a / f b := by
  rw [div_eq_mul_inv, div_eq_mul_inv, map_mul, hf]
#align map_div' map_div'
#align map_sub' map_sub'
-/

#print map_inv /-
/-- Group homomorphisms preserve inverse. -/
@[simp, to_additive "Additive group homomorphisms preserve negation."]
theorem map_inv [Group G] [DivisionMonoid H] [MonoidHomClass F G H] (f : F) (a : G) :
    f a⁻¹ = (f a)⁻¹ :=
  eq_inv_of_mul_eq_one_left <| map_mul_eq_one f <| inv_mul_self _
#align map_inv map_inv
#align map_neg map_neg
-/

#print map_mul_inv /-
/-- Group homomorphisms preserve division. -/
@[simp, to_additive "Additive group homomorphisms preserve subtraction."]
theorem map_mul_inv [Group G] [DivisionMonoid H] [MonoidHomClass F G H] (f : F) (a b : G) :
    f (a * b⁻¹) = f a * (f b)⁻¹ := by rw [map_mul, map_inv]
#align map_mul_inv map_mul_inv
#align map_add_neg map_add_neg
-/

#print map_div /-
/-- Group homomorphisms preserve division. -/
@[simp, to_additive "Additive group homomorphisms preserve subtraction."]
theorem map_div [Group G] [DivisionMonoid H] [MonoidHomClass F G H] (f : F) :
    ∀ a b, f (a / b) = f a / f b :=
  map_div' _ <| map_inv f
#align map_div map_div
#align map_sub map_sub
-/

#print map_pow /-
-- to_additive puts the arguments in the wrong order, so generate an auxiliary lemma, then
-- swap its arguments.
@[to_additive map_nsmul.aux, simp]
theorem map_pow [Monoid G] [Monoid H] [MonoidHomClass F G H] (f : F) (a : G) :
    ∀ n : ℕ, f (a ^ n) = f a ^ n
  | 0 => by rw [pow_zero, pow_zero, map_one]
  | n + 1 => by rw [pow_succ, pow_succ, map_mul, map_pow]
#align map_pow map_pow
#align map_nsmul map_nsmul
-/

#print map_nsmul /-
@[simp]
theorem map_nsmul [AddMonoid G] [AddMonoid H] [AddMonoidHomClass F G H] (f : F) (n : ℕ) (a : G) :
    f (n • a) = n • f a :=
  map_nsmul.aux f a n
#align map_nsmul map_nsmul
-/

attribute [to_additive_reorder 8, to_additive] map_pow

#print map_zpow' /-
@[to_additive]
theorem map_zpow' [DivInvMonoid G] [DivInvMonoid H] [MonoidHomClass F G H] (f : F)
    (hf : ∀ x : G, f x⁻¹ = (f x)⁻¹) (a : G) : ∀ n : ℤ, f (a ^ n) = f a ^ n
  | (n : ℕ) => by rw [zpow_ofNat, map_pow, zpow_ofNat]
  | -[n+1] => by rw [zpow_negSucc, hf, map_pow, ← zpow_negSucc]
#align map_zpow' map_zpow'
#align map_zsmul' map_zsmul'
-/

#print map_zpow /-
-- to_additive puts the arguments in the wrong order, so generate an auxiliary lemma, then
-- swap its arguments.
/-- Group homomorphisms preserve integer power. -/
@[to_additive map_zsmul.aux, simp]
theorem map_zpow [Group G] [DivisionMonoid H] [MonoidHomClass F G H] (f : F) (g : G) (n : ℤ) :
    f (g ^ n) = f g ^ n :=
  map_zpow' f (map_inv f) g n
#align map_zpow map_zpow
#align map_zsmul map_zsmul
-/

#print map_zsmul /-
/-- Additive group homomorphisms preserve integer scaling. -/
theorem map_zsmul [AddGroup G] [SubtractionMonoid H] [AddMonoidHomClass F G H] (f : F) (n : ℤ)
    (g : G) : f (n • g) = n • f g :=
  map_zsmul.aux f g n
#align map_zsmul map_zsmul
-/

attribute [to_additive_reorder 8, to_additive] map_zpow

end mul_one

section MulZeroOne

variable [MulZeroOneClass M] [MulZeroOneClass N]

#print MonoidWithZeroHom /-
/-- `M →*₀ N` is the type of functions `M → N` that preserve
the `monoid_with_zero` structure.

`monoid_with_zero_hom` is also used for group homomorphisms.

When possible, instead of parametrizing results over `(f : M →*₀ N)`,
you should parametrize over `(F : Type*) [monoid_with_zero_hom_class F M N] (f : F)`.

When you extend this structure, make sure to extend `monoid_with_zero_hom_class`.
-/
structure MonoidWithZeroHom (M : Type _) (N : Type _) [MulZeroOneClass M]
    [MulZeroOneClass N] extends ZeroHom M N, MonoidHom M N
#align monoid_with_zero_hom MonoidWithZeroHom
-/

attribute [nolint doc_blame] MonoidWithZeroHom.toMonoidHom

attribute [nolint doc_blame] MonoidWithZeroHom.toZeroHom

infixr:25 " →*₀ " => MonoidWithZeroHom

#print MonoidWithZeroHomClass /-
/-- `monoid_with_zero_hom_class F M N` states that `F` is a type of
`monoid_with_zero`-preserving homomorphisms.

You should also extend this typeclass when you extend `monoid_with_zero_hom`.
-/
class MonoidWithZeroHomClass (F : Type _) (M N : outParam <| Type _) [MulZeroOneClass M]
    [MulZeroOneClass N] extends MonoidHomClass F M N, ZeroHomClass F M N
#align monoid_with_zero_hom_class MonoidWithZeroHomClass
-/

#print MonoidWithZeroHom.monoidWithZeroHomClass /-
instance MonoidWithZeroHom.monoidWithZeroHomClass : MonoidWithZeroHomClass (M →*₀ N) M N
    where
  coe := MonoidWithZeroHom.toFun
  coe_injective' f g h := by cases f <;> cases g <;> congr
  map_mul := MonoidWithZeroHom.map_mul'
  map_one := MonoidWithZeroHom.map_one'
  map_zero := MonoidWithZeroHom.map_zero'
#align monoid_with_zero_hom.monoid_with_zero_hom_class MonoidWithZeroHom.monoidWithZeroHomClass
-/

instance [MonoidWithZeroHomClass F M N] : CoeTC F (M →*₀ N) :=
  ⟨fun f =>
    { toFun := f
      map_one' := map_one f
      map_zero' := map_zero f
      map_mul' := map_mul f }⟩

#print MonoidWithZeroHom.coe_coe /-
@[simp]
theorem MonoidWithZeroHom.coe_coe [MonoidWithZeroHomClass F M N] (f : F) :
    ((f : M →*₀ N) : M → N) = f :=
  rfl
#align monoid_with_zero_hom.coe_coe MonoidWithZeroHom.coe_coe
-/

end MulZeroOne

-- completely uninteresting lemmas about coercion to function, that all homs need
section Coes

/-! Bundled morphisms can be down-cast to weaker bundlings -/


#print MonoidHom.coeToOneHom /-
@[to_additive]
instance MonoidHom.coeToOneHom {mM : MulOneClass M} {mN : MulOneClass N} :
    Coe (M →* N) (OneHom M N) :=
  ⟨MonoidHom.toOneHom⟩
#align monoid_hom.has_coe_to_one_hom MonoidHom.coeToOneHom
#align add_monoid_hom.has_coe_to_zero_hom AddMonoidHom.coeToZeroHom
-/

#print MonoidHom.coeToMulHom /-
@[to_additive]
instance MonoidHom.coeToMulHom {mM : MulOneClass M} {mN : MulOneClass N} : Coe (M →* N) (M →ₙ* N) :=
  ⟨MonoidHom.toMulHom⟩
#align monoid_hom.has_coe_to_mul_hom MonoidHom.coeToMulHom
#align add_monoid_hom.has_coe_to_add_hom AddMonoidHom.coeToAddHom
-/

#print MonoidWithZeroHom.coeToMonoidHom /-
instance MonoidWithZeroHom.coeToMonoidHom {mM : MulZeroOneClass M} {mN : MulZeroOneClass N} :
    Coe (M →*₀ N) (M →* N) :=
  ⟨MonoidWithZeroHom.toMonoidHom⟩
#align monoid_with_zero_hom.has_coe_to_monoid_hom MonoidWithZeroHom.coeToMonoidHom
-/

#print MonoidWithZeroHom.coeToZeroHom /-
instance MonoidWithZeroHom.coeToZeroHom {mM : MulZeroOneClass M} {mN : MulZeroOneClass N} :
    Coe (M →*₀ N) (ZeroHom M N) :=
  ⟨MonoidWithZeroHom.toZeroHom⟩
#align monoid_with_zero_hom.has_coe_to_zero_hom MonoidWithZeroHom.coeToZeroHom
-/

/-! The simp-normal form of morphism coercion is `f.to_..._hom`. This choice is primarily because
this is the way things were before the above coercions were introduced. Bundled morphisms defined
elsewhere in Mathlib may choose `↑f` as their simp-normal form instead. -/


@[simp, to_additive]
theorem MonoidHom.coe_eq_toOneHom {mM : MulOneClass M} {mN : MulOneClass N} (f : M →* N) :
    (f : OneHom M N) = f.toOneHom :=
  rfl
#align monoid_hom.coe_eq_to_one_hom MonoidHom.coe_eq_toOneHom
#align add_monoid_hom.coe_eq_to_zero_hom AddMonoidHom.coe_eq_to_zero_hom

@[simp, to_additive]
theorem MonoidHom.coe_eq_toMulHom {mM : MulOneClass M} {mN : MulOneClass N} (f : M →* N) :
    (f : M →ₙ* N) = f.toMulHom :=
  rfl
#align monoid_hom.coe_eq_to_mul_hom MonoidHom.coe_eq_toMulHom
#align add_monoid_hom.coe_eq_to_add_hom AddMonoidHom.coe_eq_to_add_hom

@[simp]
theorem MonoidWithZeroHom.coe_eq_toMonoidHom {mM : MulZeroOneClass M} {mN : MulZeroOneClass N}
    (f : M →*₀ N) : (f : M →* N) = f.toMonoidHom :=
  rfl
#align monoid_with_zero_hom.coe_eq_to_monoid_hom MonoidWithZeroHom.coe_eq_toMonoidHom

@[simp]
theorem MonoidWithZeroHom.coe_eq_toZeroHom {mM : MulZeroOneClass M} {mN : MulZeroOneClass N}
    (f : M →*₀ N) : (f : ZeroHom M N) = f.toZeroHom :=
  rfl
#align monoid_with_zero_hom.coe_eq_to_zero_hom MonoidWithZeroHom.coe_eq_toZeroHom

-- Fallback `has_coe_to_fun` instances to help the elaborator
@[to_additive]
instance {mM : One M} {mN : One N} : CoeFun (OneHom M N) fun _ => M → N :=
  ⟨OneHom.toFun⟩

@[to_additive]
instance {mM : Mul M} {mN : Mul N} : CoeFun (M →ₙ* N) fun _ => M → N :=
  ⟨MulHom.toFun⟩

@[to_additive]
instance {mM : MulOneClass M} {mN : MulOneClass N} : CoeFun (M →* N) fun _ => M → N :=
  ⟨MonoidHom.toFun⟩

instance {mM : MulZeroOneClass M} {mN : MulZeroOneClass N} : CoeFun (M →*₀ N) fun _ => M → N :=
  ⟨MonoidWithZeroHom.toFun⟩

-- these must come after the coe_to_fun definitions
initialize_simps_projections ZeroHom (toFun → apply)

initialize_simps_projections AddHom (toFun → apply)

initialize_simps_projections AddMonoidHom (toFun → apply)

initialize_simps_projections OneHom (toFun → apply)

initialize_simps_projections MulHom (toFun → apply)

initialize_simps_projections MonoidHom (toFun → apply)

initialize_simps_projections MonoidWithZeroHom (toFun → apply)

#print OneHom.toFun_eq_coe /-
@[simp, to_additive]
theorem OneHom.toFun_eq_coe [One M] [One N] (f : OneHom M N) : f.toFun = f :=
  rfl
#align one_hom.to_fun_eq_coe OneHom.toFun_eq_coe
#align zero_hom.to_fun_eq_coe ZeroHom.toFun_eq_coe
-/

#print MulHom.toFun_eq_coe /-
@[simp, to_additive]
theorem MulHom.toFun_eq_coe [Mul M] [Mul N] (f : M →ₙ* N) : f.toFun = f :=
  rfl
#align mul_hom.to_fun_eq_coe MulHom.toFun_eq_coe
#align add_hom.to_fun_eq_coe AddHom.toFun_eq_coe
-/

#print MonoidHom.toFun_eq_coe /-
@[simp, to_additive]
theorem MonoidHom.toFun_eq_coe [MulOneClass M] [MulOneClass N] (f : M →* N) : f.toFun = f :=
  rfl
#align monoid_hom.to_fun_eq_coe MonoidHom.toFun_eq_coe
#align add_monoid_hom.to_fun_eq_coe AddMonoidHom.toFun_eq_coe
-/

@[simp]
theorem MonoidWithZeroHom.toFun_eq_coe [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) :
    f.toFun = f :=
  rfl
#align monoid_with_zero_hom.to_fun_eq_coe MonoidWithZeroHom.toFun_eq_coe

#print OneHom.coe_mk /-
@[simp, to_additive]
theorem OneHom.coe_mk [One M] [One N] (f : M → N) (h1) : (OneHom.mk f h1 : M → N) = f :=
  rfl
#align one_hom.coe_mk OneHom.coe_mk
#align zero_hom.coe_mk ZeroHom.coe_mk
-/

#print MulHom.coe_mk /-
@[simp, to_additive]
theorem MulHom.coe_mk [Mul M] [Mul N] (f : M → N) (hmul) : (MulHom.mk f hmul : M → N) = f :=
  rfl
#align mul_hom.coe_mk MulHom.coe_mk
#align add_hom.coe_mk AddHom.coe_mk
-/

#print MonoidHom.coe_mk /-
@[simp, to_additive]
theorem MonoidHom.coe_mk [MulOneClass M] [MulOneClass N] (f : M → N) (h1 hmul) :
    (MonoidHom.mk f h1 hmul : M → N) = f :=
  rfl
#align monoid_hom.coe_mk MonoidHom.coe_mk
#align add_monoid_hom.coe_mk AddMonoidHom.coe_mk
-/

#print MonoidWithZeroHom.coe_mk /-
@[simp]
theorem MonoidWithZeroHom.coe_mk [MulZeroOneClass M] [MulZeroOneClass N] (f : M → N) (h0 h1 hmul) :
    (MonoidWithZeroHom.mk f h0 h1 hmul : M → N) = f :=
  rfl
#align monoid_with_zero_hom.coe_mk MonoidWithZeroHom.coe_mk
-/

#print MonoidHom.toOneHom_coe /-
@[simp, to_additive]
theorem MonoidHom.toOneHom_coe [MulOneClass M] [MulOneClass N] (f : M →* N) :
    (f.toOneHom : M → N) = f :=
  rfl
#align monoid_hom.to_one_hom_coe MonoidHom.toOneHom_coe
#align add_monoid_hom.to_zero_hom_coe AddMonoidHom.toZeroHom_coe
-/

#print MonoidHom.toMulHom_coe /-
@[simp, to_additive]
theorem MonoidHom.toMulHom_coe [MulOneClass M] [MulOneClass N] (f : M →* N) :
    (f.toMulHom : M → N) = f :=
  rfl
#align monoid_hom.to_mul_hom_coe MonoidHom.toMulHom_coe
#align add_monoid_hom.to_add_hom_coe AddMonoidHom.toAddHom_coe
-/

#print MonoidWithZeroHom.toZeroHom_coe /-
@[simp]
theorem MonoidWithZeroHom.toZeroHom_coe [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) :
    (f.toZeroHom : M → N) = f :=
  rfl
#align monoid_with_zero_hom.to_zero_hom_coe MonoidWithZeroHom.toZeroHom_coe
-/

#print MonoidWithZeroHom.toMonoidHom_coe /-
@[simp]
theorem MonoidWithZeroHom.toMonoidHom_coe [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) :
    (f.toMonoidHom : M → N) = f :=
  rfl
#align monoid_with_zero_hom.to_monoid_hom_coe MonoidWithZeroHom.toMonoidHom_coe
-/

#print OneHom.ext /-
@[ext, to_additive]
theorem OneHom.ext [One M] [One N] ⦃f g : OneHom M N⦄ (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align one_hom.ext OneHom.ext
#align zero_hom.ext ZeroHom.ext
-/

#print MulHom.ext /-
@[ext, to_additive]
theorem MulHom.ext [Mul M] [Mul N] ⦃f g : M →ₙ* N⦄ (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align mul_hom.ext MulHom.ext
#align add_hom.ext AddHom.ext
-/

#print MonoidHom.ext /-
@[ext, to_additive]
theorem MonoidHom.ext [MulOneClass M] [MulOneClass N] ⦃f g : M →* N⦄ (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align monoid_hom.ext MonoidHom.ext
#align add_monoid_hom.ext AddMonoidHom.ext
-/

#print MonoidWithZeroHom.ext /-
@[ext]
theorem MonoidWithZeroHom.ext [MulZeroOneClass M] [MulZeroOneClass N] ⦃f g : M →*₀ N⦄
    (h : ∀ x, f x = g x) : f = g :=
  FunLike.ext _ _ h
#align monoid_with_zero_hom.ext MonoidWithZeroHom.ext
-/

section Deprecated

#print OneHom.congr_fun /-
/-- Deprecated: use `fun_like.congr_fun` instead. -/
@[to_additive "Deprecated: use `fun_like.congr_fun` instead."]
theorem OneHom.congr_fun [One M] [One N] {f g : OneHom M N} (h : f = g) (x : M) : f x = g x :=
  FunLike.congr_fun h x
#align one_hom.congr_fun OneHom.congr_fun
#align zero_hom.congr_fun ZeroHom.congr_fun
-/

#print MulHom.congr_fun /-
/-- Deprecated: use `fun_like.congr_fun` instead. -/
@[to_additive "Deprecated: use `fun_like.congr_fun` instead."]
theorem MulHom.congr_fun [Mul M] [Mul N] {f g : M →ₙ* N} (h : f = g) (x : M) : f x = g x :=
  FunLike.congr_fun h x
#align mul_hom.congr_fun MulHom.congr_fun
#align add_hom.congr_fun AddHom.congr_fun
-/

#print MonoidHom.congr_fun /-
/-- Deprecated: use `fun_like.congr_fun` instead. -/
@[to_additive "Deprecated: use `fun_like.congr_fun` instead."]
theorem MonoidHom.congr_fun [MulOneClass M] [MulOneClass N] {f g : M →* N} (h : f = g) (x : M) :
    f x = g x :=
  FunLike.congr_fun h x
#align monoid_hom.congr_fun MonoidHom.congr_fun
#align add_monoid_hom.congr_fun AddMonoidHom.congr_fun
-/

#print MonoidWithZeroHom.congr_fun /-
/-- Deprecated: use `fun_like.congr_fun` instead. -/
theorem MonoidWithZeroHom.congr_fun [MulZeroOneClass M] [MulZeroOneClass N] {f g : M →*₀ N}
    (h : f = g) (x : M) : f x = g x :=
  FunLike.congr_fun h x
#align monoid_with_zero_hom.congr_fun MonoidWithZeroHom.congr_fun
-/

#print OneHom.congr_arg /-
/-- Deprecated: use `fun_like.congr_arg` instead. -/
@[to_additive "Deprecated: use `fun_like.congr_arg` instead."]
theorem OneHom.congr_arg [One M] [One N] (f : OneHom M N) {x y : M} (h : x = y) : f x = f y :=
  FunLike.congr_arg f h
#align one_hom.congr_arg OneHom.congr_arg
#align zero_hom.congr_arg ZeroHom.congr_arg
-/

#print MulHom.congr_arg /-
/-- Deprecated: use `fun_like.congr_arg` instead. -/
@[to_additive "Deprecated: use `fun_like.congr_arg` instead."]
theorem MulHom.congr_arg [Mul M] [Mul N] (f : M →ₙ* N) {x y : M} (h : x = y) : f x = f y :=
  FunLike.congr_arg f h
#align mul_hom.congr_arg MulHom.congr_arg
#align add_hom.congr_arg AddHom.congr_arg
-/

#print MonoidHom.congr_arg /-
/-- Deprecated: use `fun_like.congr_arg` instead. -/
@[to_additive "Deprecated: use `fun_like.congr_arg` instead."]
theorem MonoidHom.congr_arg [MulOneClass M] [MulOneClass N] (f : M →* N) {x y : M} (h : x = y) :
    f x = f y :=
  FunLike.congr_arg f h
#align monoid_hom.congr_arg MonoidHom.congr_arg
#align add_monoid_hom.congr_arg AddMonoidHom.congr_arg
-/

#print MonoidWithZeroHom.congr_arg /-
/-- Deprecated: use `fun_like.congr_arg` instead. -/
theorem MonoidWithZeroHom.congr_arg [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) {x y : M}
    (h : x = y) : f x = f y :=
  FunLike.congr_arg f h
#align monoid_with_zero_hom.congr_arg MonoidWithZeroHom.congr_arg
-/

#print OneHom.coe_inj /-
/-- Deprecated: use `fun_like.coe_injective` instead. -/
@[to_additive "Deprecated: use `fun_like.coe_injective` instead."]
theorem OneHom.coe_inj [One M] [One N] ⦃f g : OneHom M N⦄ (h : (f : M → N) = g) : f = g :=
  FunLike.coe_injective h
#align one_hom.coe_inj OneHom.coe_inj
#align zero_hom.coe_inj ZeroHom.coe_inj
-/

#print MulHom.coe_inj /-
/-- Deprecated: use `fun_like.coe_injective` instead. -/
@[to_additive "Deprecated: use `fun_like.coe_injective` instead."]
theorem MulHom.coe_inj [Mul M] [Mul N] ⦃f g : M →ₙ* N⦄ (h : (f : M → N) = g) : f = g :=
  FunLike.coe_injective h
#align mul_hom.coe_inj MulHom.coe_inj
#align add_hom.coe_inj AddHom.coe_inj
-/

#print MonoidHom.coe_inj /-
/-- Deprecated: use `fun_like.coe_injective` instead. -/
@[to_additive "Deprecated: use `fun_like.coe_injective` instead."]
theorem MonoidHom.coe_inj [MulOneClass M] [MulOneClass N] ⦃f g : M →* N⦄ (h : (f : M → N) = g) :
    f = g :=
  FunLike.coe_injective h
#align monoid_hom.coe_inj MonoidHom.coe_inj
#align add_monoid_hom.coe_inj AddMonoidHom.coe_inj
-/

#print MonoidWithZeroHom.coe_inj /-
/-- Deprecated: use `fun_like.coe_injective` instead. -/
theorem MonoidWithZeroHom.coe_inj [MulZeroOneClass M] [MulZeroOneClass N] ⦃f g : M →*₀ N⦄
    (h : (f : M → N) = g) : f = g :=
  FunLike.coe_injective h
#align monoid_with_zero_hom.coe_inj MonoidWithZeroHom.coe_inj
-/

#print OneHom.ext_iff /-
/-- Deprecated: use `fun_like.ext_iff` instead. -/
@[to_additive "Deprecated: use `fun_like.ext_iff` instead."]
theorem OneHom.ext_iff [One M] [One N] {f g : OneHom M N} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align one_hom.ext_iff OneHom.ext_iff
#align zero_hom.ext_iff ZeroHom.ext_iff
-/

#print MulHom.ext_iff /-
/-- Deprecated: use `fun_like.ext_iff` instead. -/
@[to_additive "Deprecated: use `fun_like.ext_iff` instead."]
theorem MulHom.ext_iff [Mul M] [Mul N] {f g : M →ₙ* N} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align mul_hom.ext_iff MulHom.ext_iff
#align add_hom.ext_iff AddHom.ext_iff
-/

#print MonoidHom.ext_iff /-
/-- Deprecated: use `fun_like.ext_iff` instead. -/
@[to_additive "Deprecated: use `fun_like.ext_iff` instead."]
theorem MonoidHom.ext_iff [MulOneClass M] [MulOneClass N] {f g : M →* N} : f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align monoid_hom.ext_iff MonoidHom.ext_iff
#align add_monoid_hom.ext_iff AddMonoidHom.ext_iff
-/

#print MonoidWithZeroHom.ext_iff /-
/-- Deprecated: use `fun_like.ext_iff` instead. -/
theorem MonoidWithZeroHom.ext_iff [MulZeroOneClass M] [MulZeroOneClass N] {f g : M →*₀ N} :
    f = g ↔ ∀ x, f x = g x :=
  FunLike.ext_iff
#align monoid_with_zero_hom.ext_iff MonoidWithZeroHom.ext_iff
-/

end Deprecated

#print OneHom.mk_coe /-
@[simp, to_additive]
theorem OneHom.mk_coe [One M] [One N] (f : OneHom M N) (h1) : OneHom.mk f h1 = f :=
  OneHom.ext fun _ => rfl
#align one_hom.mk_coe OneHom.mk_coe
#align zero_hom.mk_coe ZeroHom.mk_coe
-/

#print MulHom.mk_coe /-
@[simp, to_additive]
theorem MulHom.mk_coe [Mul M] [Mul N] (f : M →ₙ* N) (hmul) : MulHom.mk f hmul = f :=
  MulHom.ext fun _ => rfl
#align mul_hom.mk_coe MulHom.mk_coe
#align add_hom.mk_coe AddHom.mk_coe
-/

#print MonoidHom.mk_coe /-
@[simp, to_additive]
theorem MonoidHom.mk_coe [MulOneClass M] [MulOneClass N] (f : M →* N) (h1 hmul) :
    MonoidHom.mk f h1 hmul = f :=
  MonoidHom.ext fun _ => rfl
#align monoid_hom.mk_coe MonoidHom.mk_coe
#align add_monoid_hom.mk_coe AddMonoidHom.mk_coe
-/

#print MonoidWithZeroHom.mk_coe /-
@[simp]
theorem MonoidWithZeroHom.mk_coe [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N)
    (h0 h1 hmul) : MonoidWithZeroHom.mk f h0 h1 hmul = f :=
  MonoidWithZeroHom.ext fun _ => rfl
#align monoid_with_zero_hom.mk_coe MonoidWithZeroHom.mk_coe
-/

end Coes

#print OneHom.copy /-
/-- Copy of a `one_hom` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
@[to_additive
      "Copy of a `zero_hom` with a new `to_fun` equal to the old one. Useful to fix\ndefinitional equalities."]
protected def OneHom.copy {hM : One M} {hN : One N} (f : OneHom M N) (f' : M → N) (h : f' = f) :
    OneHom M N where
  toFun := f'
  map_one' := h.symm ▸ f.map_one'
#align one_hom.copy OneHom.copy
#align zero_hom.copy ZeroHom.copy
-/

#print OneHom.coe_copy /-
@[simp, to_additive]
theorem OneHom.coe_copy {hM : One M} {hN : One N} (f : OneHom M N) (f' : M → N) (h : f' = f) :
    ⇑(f.copy f' h) = f' :=
  rfl
#align one_hom.coe_copy OneHom.coe_copy
#align zero_hom.coe_copy ZeroHom.coe_copy
-/

#print OneHom.coe_copy_eq /-
@[to_additive]
theorem OneHom.coe_copy_eq {hM : One M} {hN : One N} (f : OneHom M N) (f' : M → N) (h : f' = f) :
    f.copy f' h = f :=
  FunLike.ext' h
#align one_hom.coe_copy_eq OneHom.coe_copy_eq
#align zero_hom.coe_copy_eq ZeroHom.coe_copy_eq
-/

#print MulHom.copy /-
/-- Copy of a `mul_hom` with a new `to_fun` equal to the old one. Useful to fix definitional
equalities. -/
@[to_additive
      "Copy of an `add_hom` with a new `to_fun` equal to the old one. Useful to fix\ndefinitional equalities."]
protected def MulHom.copy {hM : Mul M} {hN : Mul N} (f : M →ₙ* N) (f' : M → N) (h : f' = f) :
    M →ₙ* N where
  toFun := f'
  map_mul' := h.symm ▸ f.map_mul'
#align mul_hom.copy MulHom.copy
#align add_hom.copy AddHom.copy
-/

#print MulHom.coe_copy /-
@[simp, to_additive]
theorem MulHom.coe_copy {hM : Mul M} {hN : Mul N} (f : M →ₙ* N) (f' : M → N) (h : f' = f) :
    ⇑(f.copy f' h) = f' :=
  rfl
#align mul_hom.coe_copy MulHom.coe_copy
#align add_hom.coe_copy AddHom.coe_copy
-/

#print MulHom.coe_copy_eq /-
@[to_additive]
theorem MulHom.coe_copy_eq {hM : Mul M} {hN : Mul N} (f : M →ₙ* N) (f' : M → N) (h : f' = f) :
    f.copy f' h = f :=
  FunLike.ext' h
#align mul_hom.coe_copy_eq MulHom.coe_copy_eq
#align add_hom.coe_copy_eq AddHom.coe_copy_eq
-/

#print MonoidHom.copy /-
/-- Copy of a `monoid_hom` with a new `to_fun` equal to the old one. Useful to fix
definitional equalities. -/
@[to_additive
      "Copy of an `add_monoid_hom` with a new `to_fun` equal to the old one. Useful to fix\ndefinitional equalities."]
protected def MonoidHom.copy {hM : MulOneClass M} {hN : MulOneClass N} (f : M →* N) (f' : M → N)
    (h : f' = f) : M →* N :=
  { f.toOneHom.copy f' h, f.toMulHom.copy f' h with }
#align monoid_hom.copy MonoidHom.copy
#align add_monoid_hom.copy AddMonoidHom.copy
-/

#print MonoidHom.coe_copy /-
@[simp, to_additive]
theorem MonoidHom.coe_copy {hM : MulOneClass M} {hN : MulOneClass N} (f : M →* N) (f' : M → N)
    (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align monoid_hom.coe_copy MonoidHom.coe_copy
#align add_monoid_hom.coe_copy AddMonoidHom.coe_copy
-/

#print MonoidHom.copy_eq /-
@[to_additive]
theorem MonoidHom.copy_eq {hM : MulOneClass M} {hN : MulOneClass N} (f : M →* N) (f' : M → N)
    (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align monoid_hom.copy_eq MonoidHom.copy_eq
#align add_monoid_hom.copy_eq AddMonoidHom.copy_eq
-/

#print MonoidWithZeroHom.copy /-
/-- Copy of a `monoid_hom` with a new `to_fun` equal to the old one. Useful to fix
definitional equalities. -/
protected def MonoidWithZeroHom.copy {hM : MulZeroOneClass M} {hN : MulZeroOneClass N} (f : M →*₀ N)
    (f' : M → N) (h : f' = f) : M →* N :=
  { f.toZeroHom.copy f' h, f.toMonoidHom.copy f' h with }
#align monoid_with_zero_hom.copy MonoidWithZeroHom.copy
-/

#print MonoidWithZeroHom.coe_copy /-
@[simp]
theorem MonoidWithZeroHom.coe_copy {hM : MulZeroOneClass M} {hN : MulZeroOneClass N} (f : M →*₀ N)
    (f' : M → N) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align monoid_with_zero_hom.coe_copy MonoidWithZeroHom.coe_copy
-/

#print MonoidWithZeroHom.copy_eq /-
theorem MonoidWithZeroHom.copy_eq {hM : MulZeroOneClass M} {hN : MulZeroOneClass N} (f : M →*₀ N)
    (f' : M → N) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align monoid_with_zero_hom.copy_eq MonoidWithZeroHom.copy_eq
-/

#print OneHom.map_one /-
@[to_additive]
protected theorem OneHom.map_one [One M] [One N] (f : OneHom M N) : f 1 = 1 :=
  f.map_one'
#align one_hom.map_one OneHom.map_one
#align zero_hom.map_zero ZeroHom.map_zero
-/

#print MonoidHom.map_one /-
/-- If `f` is a monoid homomorphism then `f 1 = 1`. -/
@[to_additive]
protected theorem MonoidHom.map_one [MulOneClass M] [MulOneClass N] (f : M →* N) : f 1 = 1 :=
  f.map_one'
#align monoid_hom.map_one MonoidHom.map_one
#align add_monoid_hom.map_zero AddMonoidHom.map_zero
-/

#print MonoidWithZeroHom.map_one /-
protected theorem MonoidWithZeroHom.map_one [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) :
    f 1 = 1 :=
  f.map_one'
#align monoid_with_zero_hom.map_one MonoidWithZeroHom.map_one
-/

/-- If `f` is an additive monoid homomorphism then `f 0 = 0`. -/
add_decl_doc AddMonoidHom.map_zero

#print MonoidWithZeroHom.map_zero /-
protected theorem MonoidWithZeroHom.map_zero [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) :
    f 0 = 0 :=
  f.map_zero'
#align monoid_with_zero_hom.map_zero MonoidWithZeroHom.map_zero
-/

#print MulHom.map_mul /-
@[to_additive]
protected theorem MulHom.map_mul [Mul M] [Mul N] (f : M →ₙ* N) (a b : M) : f (a * b) = f a * f b :=
  f.map_mul' a b
#align mul_hom.map_mul MulHom.map_mul
#align add_hom.map_add AddHom.map_add
-/

#print MonoidHom.map_mul /-
/-- If `f` is a monoid homomorphism then `f (a * b) = f a * f b`. -/
@[to_additive]
protected theorem MonoidHom.map_mul [MulOneClass M] [MulOneClass N] (f : M →* N) (a b : M) :
    f (a * b) = f a * f b :=
  f.map_mul' a b
#align monoid_hom.map_mul MonoidHom.map_mul
#align add_monoid_hom.map_add AddMonoidHom.map_add
-/

#print MonoidWithZeroHom.map_mul /-
protected theorem MonoidWithZeroHom.map_mul [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N)
    (a b : M) : f (a * b) = f a * f b :=
  f.map_mul' a b
#align monoid_with_zero_hom.map_mul MonoidWithZeroHom.map_mul
-/

/-- If `f` is an additive monoid homomorphism then `f (a + b) = f a + f b`. -/
add_decl_doc AddMonoidHom.map_add

namespace MonoidHom

variable {mM : MulOneClass M} {mN : MulOneClass N} [MonoidHomClass F M N]

#print MonoidHom.map_exists_right_inv /-
/-- Given a monoid homomorphism `f : M →* N` and an element `x : M`, if `x` has a right inverse,
then `f x` has a right inverse too. For elements invertible on both sides see `is_unit.map`. -/
@[to_additive
      "Given an add_monoid homomorphism `f : M →+ N` and an element `x : M`, if `x` has\na right inverse, then `f x` has a right inverse too."]
theorem map_exists_right_inv (f : F) {x : M} (hx : ∃ y, x * y = 1) : ∃ y, f x * y = 1 :=
  let ⟨y, hy⟩ := hx
  ⟨f y, map_mul_eq_one f hy⟩
#align monoid_hom.map_exists_right_inv MonoidHom.map_exists_right_inv
#align add_monoid_hom.map_exists_right_neg AddMonoidHom.map_exists_right_neg
-/

#print MonoidHom.map_exists_left_inv /-
/-- Given a monoid homomorphism `f : M →* N` and an element `x : M`, if `x` has a left inverse,
then `f x` has a left inverse too. For elements invertible on both sides see `is_unit.map`. -/
@[to_additive
      "Given an add_monoid homomorphism `f : M →+ N` and an element `x : M`, if `x` has\na left inverse, then `f x` has a left inverse too. For elements invertible on both sides see\n`is_add_unit.map`."]
theorem map_exists_left_inv (f : F) {x : M} (hx : ∃ y, y * x = 1) : ∃ y, y * f x = 1 :=
  let ⟨y, hy⟩ := hx
  ⟨f y, map_mul_eq_one f hy⟩
#align monoid_hom.map_exists_left_inv MonoidHom.map_exists_left_inv
#align add_monoid_hom.map_exists_left_neg AddMonoidHom.map_exists_left_neg
-/

end MonoidHom

section DivisionCommMonoid

variable [DivisionCommMonoid α]

#print invMonoidHom /-
/-- Inversion on a commutative group, considered as a monoid homomorphism. -/
@[to_additive
      "Negation on a commutative additive group, considered as an additive monoid\nhomomorphism."]
def invMonoidHom : α →* α where
  toFun := Inv.inv
  map_one' := inv_one
  map_mul' := mul_inv
#align inv_monoid_hom invMonoidHom
#align neg_add_monoid_hom negAddMonoidHom
-/

#print coe_invMonoidHom /-
@[simp]
theorem coe_invMonoidHom : (invMonoidHom : α → α) = Inv.inv :=
  rfl
#align coe_inv_monoid_hom coe_invMonoidHom
-/

#print invMonoidHom_apply /-
@[simp]
theorem invMonoidHom_apply (a : α) : invMonoidHom a = a⁻¹ :=
  rfl
#align inv_monoid_hom_apply invMonoidHom_apply
-/

end DivisionCommMonoid

#print OneHom.id /-
/-- The identity map from a type with 1 to itself. -/
@[to_additive, simps]
def OneHom.id (M : Type _) [One M] : OneHom M M
    where
  toFun x := x
  map_one' := rfl
#align one_hom.id OneHom.id
#align zero_hom.id ZeroHom.id
-/

#print MulHom.id /-
/-- The identity map from a type with multiplication to itself. -/
@[to_additive, simps]
def MulHom.id (M : Type _) [Mul M] : M →ₙ* M
    where
  toFun x := x
  map_mul' _ _ := rfl
#align mul_hom.id MulHom.id
#align add_hom.id AddHom.id
-/

#print MonoidHom.id /-
/-- The identity map from a monoid to itself. -/
@[to_additive, simps]
def MonoidHom.id (M : Type _) [MulOneClass M] : M →* M
    where
  toFun x := x
  map_one' := rfl
  map_mul' _ _ := rfl
#align monoid_hom.id MonoidHom.id
#align add_monoid_hom.id AddMonoidHom.id
-/

#print MonoidWithZeroHom.id /-
/-- The identity map from a monoid_with_zero to itself. -/
@[simps]
def MonoidWithZeroHom.id (M : Type _) [MulZeroOneClass M] : M →*₀ M
    where
  toFun x := x
  map_zero' := rfl
  map_one' := rfl
  map_mul' _ _ := rfl
#align monoid_with_zero_hom.id MonoidWithZeroHom.id
-/

/-- The identity map from an type with zero to itself. -/
add_decl_doc ZeroHom.id

/-- The identity map from an type with addition to itself. -/
add_decl_doc AddHom.id

/-- The identity map from an additive monoid to itself. -/
add_decl_doc AddMonoidHom.id

#print OneHom.comp /-
/-- Composition of `one_hom`s as a `one_hom`. -/
@[to_additive]
def OneHom.comp [One M] [One N] [One P] (hnp : OneHom N P) (hmn : OneHom M N) : OneHom M P
    where
  toFun := hnp ∘ hmn
  map_one' := by simp
#align one_hom.comp OneHom.comp
#align zero_hom.comp ZeroHom.comp
-/

#print MulHom.comp /-
/-- Composition of `mul_hom`s as a `mul_hom`. -/
@[to_additive]
def MulHom.comp [Mul M] [Mul N] [Mul P] (hnp : N →ₙ* P) (hmn : M →ₙ* N) : M →ₙ* P
    where
  toFun := hnp ∘ hmn
  map_mul' := by simp
#align mul_hom.comp MulHom.comp
#align add_hom.comp AddHom.comp
-/

#print MonoidHom.comp /-
/-- Composition of monoid morphisms as a monoid morphism. -/
@[to_additive]
def MonoidHom.comp [MulOneClass M] [MulOneClass N] [MulOneClass P] (hnp : N →* P) (hmn : M →* N) :
    M →* P where
  toFun := hnp ∘ hmn
  map_one' := by simp
  map_mul' := by simp
#align monoid_hom.comp MonoidHom.comp
#align add_monoid_hom.comp AddMonoidHom.comp
-/

#print MonoidWithZeroHom.comp /-
/-- Composition of `monoid_with_zero_hom`s as a `monoid_with_zero_hom`. -/
def MonoidWithZeroHom.comp [MulZeroOneClass M] [MulZeroOneClass N] [MulZeroOneClass P]
    (hnp : N →*₀ P) (hmn : M →*₀ N) : M →*₀ P
    where
  toFun := hnp ∘ hmn
  map_zero' := by simp
  map_one' := by simp
  map_mul' := by simp
#align monoid_with_zero_hom.comp MonoidWithZeroHom.comp
-/

/-- Composition of `zero_hom`s as a `zero_hom`. -/
add_decl_doc ZeroHom.comp

/-- Composition of `add_hom`s as a `add_hom`. -/
add_decl_doc AddHom.comp

/-- Composition of additive monoid morphisms as an additive monoid morphism. -/
add_decl_doc AddMonoidHom.comp

#print OneHom.coe_comp /-
@[simp, to_additive]
theorem OneHom.coe_comp [One M] [One N] [One P] (g : OneHom N P) (f : OneHom M N) :
    ⇑(g.comp f) = g ∘ f :=
  rfl
#align one_hom.coe_comp OneHom.coe_comp
#align zero_hom.coe_comp ZeroHom.coe_comp
-/

#print MulHom.coe_comp /-
@[simp, to_additive]
theorem MulHom.coe_comp [Mul M] [Mul N] [Mul P] (g : N →ₙ* P) (f : M →ₙ* N) : ⇑(g.comp f) = g ∘ f :=
  rfl
#align mul_hom.coe_comp MulHom.coe_comp
#align add_hom.coe_comp AddHom.coe_comp
-/

#print MonoidHom.coe_comp /-
@[simp, to_additive]
theorem MonoidHom.coe_comp [MulOneClass M] [MulOneClass N] [MulOneClass P] (g : N →* P)
    (f : M →* N) : ⇑(g.comp f) = g ∘ f :=
  rfl
#align monoid_hom.coe_comp MonoidHom.coe_comp
#align add_monoid_hom.coe_comp AddMonoidHom.coe_comp
-/

#print MonoidWithZeroHom.coe_comp /-
@[simp]
theorem MonoidWithZeroHom.coe_comp [MulZeroOneClass M] [MulZeroOneClass N] [MulZeroOneClass P]
    (g : N →*₀ P) (f : M →*₀ N) : ⇑(g.comp f) = g ∘ f :=
  rfl
#align monoid_with_zero_hom.coe_comp MonoidWithZeroHom.coe_comp
-/

#print OneHom.comp_apply /-
@[to_additive]
theorem OneHom.comp_apply [One M] [One N] [One P] (g : OneHom N P) (f : OneHom M N) (x : M) :
    g.comp f x = g (f x) :=
  rfl
#align one_hom.comp_apply OneHom.comp_apply
#align zero_hom.comp_apply ZeroHom.comp_apply
-/

#print MulHom.comp_apply /-
@[to_additive]
theorem MulHom.comp_apply [Mul M] [Mul N] [Mul P] (g : N →ₙ* P) (f : M →ₙ* N) (x : M) :
    g.comp f x = g (f x) :=
  rfl
#align mul_hom.comp_apply MulHom.comp_apply
#align add_hom.comp_apply AddHom.comp_apply
-/

#print MonoidHom.comp_apply /-
@[to_additive]
theorem MonoidHom.comp_apply [MulOneClass M] [MulOneClass N] [MulOneClass P] (g : N →* P)
    (f : M →* N) (x : M) : g.comp f x = g (f x) :=
  rfl
#align monoid_hom.comp_apply MonoidHom.comp_apply
#align add_monoid_hom.comp_apply AddMonoidHom.comp_apply
-/

#print MonoidWithZeroHom.comp_apply /-
theorem MonoidWithZeroHom.comp_apply [MulZeroOneClass M] [MulZeroOneClass N] [MulZeroOneClass P]
    (g : N →*₀ P) (f : M →*₀ N) (x : M) : g.comp f x = g (f x) :=
  rfl
#align monoid_with_zero_hom.comp_apply MonoidWithZeroHom.comp_apply
-/

#print OneHom.comp_assoc /-
/-- Composition of monoid homomorphisms is associative. -/
@[to_additive "Composition of additive monoid homomorphisms is associative."]
theorem OneHom.comp_assoc {Q : Type _} [One M] [One N] [One P] [One Q] (f : OneHom M N)
    (g : OneHom N P) (h : OneHom P Q) : (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align one_hom.comp_assoc OneHom.comp_assoc
#align zero_hom.comp_assoc ZeroHom.comp_assoc
-/

#print MulHom.comp_assoc /-
@[to_additive]
theorem MulHom.comp_assoc {Q : Type _} [Mul M] [Mul N] [Mul P] [Mul Q] (f : M →ₙ* N) (g : N →ₙ* P)
    (h : P →ₙ* Q) : (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align mul_hom.comp_assoc MulHom.comp_assoc
#align add_hom.comp_assoc AddHom.comp_assoc
-/

#print MonoidHom.comp_assoc /-
@[to_additive]
theorem MonoidHom.comp_assoc {Q : Type _} [MulOneClass M] [MulOneClass N] [MulOneClass P]
    [MulOneClass Q] (f : M →* N) (g : N →* P) (h : P →* Q) :
    (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align monoid_hom.comp_assoc MonoidHom.comp_assoc
#align add_monoid_hom.comp_assoc AddMonoidHom.comp_assoc
-/

#print MonoidWithZeroHom.comp_assoc /-
theorem MonoidWithZeroHom.comp_assoc {Q : Type _} [MulZeroOneClass M] [MulZeroOneClass N]
    [MulZeroOneClass P] [MulZeroOneClass Q] (f : M →*₀ N) (g : N →*₀ P) (h : P →*₀ Q) :
    (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align monoid_with_zero_hom.comp_assoc MonoidWithZeroHom.comp_assoc
-/

#print OneHom.cancel_right /-
@[to_additive]
theorem OneHom.cancel_right [One M] [One N] [One P] {g₁ g₂ : OneHom N P} {f : OneHom M N}
    (hf : Function.Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => OneHom.ext <| hf.forall.2 (OneHom.ext_iff.1 h), fun h => h ▸ rfl⟩
#align one_hom.cancel_right OneHom.cancel_right
#align zero_hom.cancel_right ZeroHom.cancel_right
-/

#print MulHom.cancel_right /-
@[to_additive]
theorem MulHom.cancel_right [Mul M] [Mul N] [Mul P] {g₁ g₂ : N →ₙ* P} {f : M →ₙ* N}
    (hf : Function.Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => MulHom.ext <| hf.forall.2 (MulHom.ext_iff.1 h), fun h => h ▸ rfl⟩
#align mul_hom.cancel_right MulHom.cancel_right
#align add_hom.cancel_right AddHom.cancel_right
-/

#print MonoidHom.cancel_right /-
@[to_additive]
theorem MonoidHom.cancel_right [MulOneClass M] [MulOneClass N] [MulOneClass P] {g₁ g₂ : N →* P}
    {f : M →* N} (hf : Function.Surjective f) : g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => MonoidHom.ext <| hf.forall.2 (MonoidHom.ext_iff.1 h), fun h => h ▸ rfl⟩
#align monoid_hom.cancel_right MonoidHom.cancel_right
#align add_monoid_hom.cancel_right AddMonoidHom.cancel_right
-/

#print MonoidWithZeroHom.cancel_right /-
theorem MonoidWithZeroHom.cancel_right [MulZeroOneClass M] [MulZeroOneClass N] [MulZeroOneClass P]
    {g₁ g₂ : N →*₀ P} {f : M →*₀ N} (hf : Function.Surjective f) :
    g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => MonoidWithZeroHom.ext <| hf.forall.2 (MonoidWithZeroHom.ext_iff.1 h), fun h => h ▸ rfl⟩
#align monoid_with_zero_hom.cancel_right MonoidWithZeroHom.cancel_right
-/

#print OneHom.cancel_left /-
@[to_additive]
theorem OneHom.cancel_left [One M] [One N] [One P] {g : OneHom N P} {f₁ f₂ : OneHom M N}
    (hg : Function.Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => OneHom.ext fun x => hg <| by rw [← OneHom.comp_apply, h, OneHom.comp_apply], fun h =>
    h ▸ rfl⟩
#align one_hom.cancel_left OneHom.cancel_left
#align zero_hom.cancel_left ZeroHom.cancel_left
-/

#print MulHom.cancel_left /-
@[to_additive]
theorem MulHom.cancel_left [Mul M] [Mul N] [Mul P] {g : N →ₙ* P} {f₁ f₂ : M →ₙ* N}
    (hg : Function.Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => MulHom.ext fun x => hg <| by rw [← MulHom.comp_apply, h, MulHom.comp_apply], fun h =>
    h ▸ rfl⟩
#align mul_hom.cancel_left MulHom.cancel_left
#align add_hom.cancel_left AddHom.cancel_left
-/

#print MonoidHom.cancel_left /-
@[to_additive]
theorem MonoidHom.cancel_left [MulOneClass M] [MulOneClass N] [MulOneClass P] {g : N →* P}
    {f₁ f₂ : M →* N} (hg : Function.Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => MonoidHom.ext fun x => hg <| by rw [← MonoidHom.comp_apply, h, MonoidHom.comp_apply],
    fun h => h ▸ rfl⟩
#align monoid_hom.cancel_left MonoidHom.cancel_left
#align add_monoid_hom.cancel_left AddMonoidHom.cancel_left
-/

#print MonoidWithZeroHom.cancel_left /-
theorem MonoidWithZeroHom.cancel_left [MulZeroOneClass M] [MulZeroOneClass N] [MulZeroOneClass P]
    {g : N →*₀ P} {f₁ f₂ : M →*₀ N} (hg : Function.Injective g) : g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h =>
    MonoidWithZeroHom.ext fun x =>
      hg <| by rw [← MonoidWithZeroHom.comp_apply, h, MonoidWithZeroHom.comp_apply],
    fun h => h ▸ rfl⟩
#align monoid_with_zero_hom.cancel_left MonoidWithZeroHom.cancel_left
-/

#print MonoidHom.toOneHom_injective /-
@[to_additive]
theorem MonoidHom.toOneHom_injective [MulOneClass M] [MulOneClass N] :
    Function.Injective (MonoidHom.toOneHom : (M →* N) → OneHom M N) := fun f g h =>
  MonoidHom.ext <| OneHom.ext_iff.mp h
#align monoid_hom.to_one_hom_injective MonoidHom.toOneHom_injective
#align add_monoid_hom.to_zero_hom_injective AddMonoidHom.toZeroHom_injective
-/

#print MonoidHom.toMulHom_injective /-
@[to_additive]
theorem MonoidHom.toMulHom_injective [MulOneClass M] [MulOneClass N] :
    Function.Injective (MonoidHom.toMulHom : (M →* N) → M →ₙ* N) := fun f g h =>
  MonoidHom.ext <| MulHom.ext_iff.mp h
#align monoid_hom.to_mul_hom_injective MonoidHom.toMulHom_injective
#align add_monoid_hom.to_add_hom_injective AddMonoidHom.toAddHom_injective
-/

#print MonoidWithZeroHom.toMonoidHom_injective /-
theorem MonoidWithZeroHom.toMonoidHom_injective [MulZeroOneClass M] [MulZeroOneClass N] :
    Function.Injective (MonoidWithZeroHom.toMonoidHom : (M →*₀ N) → M →* N) := fun f g h =>
  MonoidWithZeroHom.ext <| MonoidHom.ext_iff.mp h
#align monoid_with_zero_hom.to_monoid_hom_injective MonoidWithZeroHom.toMonoidHom_injective
-/

#print MonoidWithZeroHom.toZeroHom_injective /-
theorem MonoidWithZeroHom.toZeroHom_injective [MulZeroOneClass M] [MulZeroOneClass N] :
    Function.Injective (MonoidWithZeroHom.toZeroHom : (M →*₀ N) → ZeroHom M N) := fun f g h =>
  MonoidWithZeroHom.ext <| ZeroHom.ext_iff.mp h
#align monoid_with_zero_hom.to_zero_hom_injective MonoidWithZeroHom.toZeroHom_injective
-/

#print OneHom.comp_id /-
@[simp, to_additive]
theorem OneHom.comp_id [One M] [One N] (f : OneHom M N) : f.comp (OneHom.id M) = f :=
  OneHom.ext fun x => rfl
#align one_hom.comp_id OneHom.comp_id
#align zero_hom.comp_id ZeroHom.comp_id
-/

#print MulHom.comp_id /-
@[simp, to_additive]
theorem MulHom.comp_id [Mul M] [Mul N] (f : M →ₙ* N) : f.comp (MulHom.id M) = f :=
  MulHom.ext fun x => rfl
#align mul_hom.comp_id MulHom.comp_id
#align add_hom.comp_id AddHom.comp_id
-/

#print MonoidHom.comp_id /-
@[simp, to_additive]
theorem MonoidHom.comp_id [MulOneClass M] [MulOneClass N] (f : M →* N) :
    f.comp (MonoidHom.id M) = f :=
  MonoidHom.ext fun x => rfl
#align monoid_hom.comp_id MonoidHom.comp_id
#align add_monoid_hom.comp_id AddMonoidHom.comp_id
-/

#print MonoidWithZeroHom.comp_id /-
@[simp]
theorem MonoidWithZeroHom.comp_id [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) :
    f.comp (MonoidWithZeroHom.id M) = f :=
  MonoidWithZeroHom.ext fun x => rfl
#align monoid_with_zero_hom.comp_id MonoidWithZeroHom.comp_id
-/

#print OneHom.id_comp /-
@[simp, to_additive]
theorem OneHom.id_comp [One M] [One N] (f : OneHom M N) : (OneHom.id N).comp f = f :=
  OneHom.ext fun x => rfl
#align one_hom.id_comp OneHom.id_comp
#align zero_hom.id_comp ZeroHom.id_comp
-/

#print MulHom.id_comp /-
@[simp, to_additive]
theorem MulHom.id_comp [Mul M] [Mul N] (f : M →ₙ* N) : (MulHom.id N).comp f = f :=
  MulHom.ext fun x => rfl
#align mul_hom.id_comp MulHom.id_comp
#align add_hom.id_comp AddHom.id_comp
-/

#print MonoidHom.id_comp /-
@[simp, to_additive]
theorem MonoidHom.id_comp [MulOneClass M] [MulOneClass N] (f : M →* N) :
    (MonoidHom.id N).comp f = f :=
  MonoidHom.ext fun x => rfl
#align monoid_hom.id_comp MonoidHom.id_comp
#align add_monoid_hom.id_comp AddMonoidHom.id_comp
-/

#print MonoidWithZeroHom.id_comp /-
@[simp]
theorem MonoidWithZeroHom.id_comp [MulZeroOneClass M] [MulZeroOneClass N] (f : M →*₀ N) :
    (MonoidWithZeroHom.id N).comp f = f :=
  MonoidWithZeroHom.ext fun x => rfl
#align monoid_with_zero_hom.id_comp MonoidWithZeroHom.id_comp
-/

#print MonoidHom.map_pow /-
@[to_additive AddMonoidHom.map_nsmul]
protected theorem MonoidHom.map_pow [Monoid M] [Monoid N] (f : M →* N) (a : M) (n : ℕ) :
    f (a ^ n) = f a ^ n :=
  map_pow f a n
#align monoid_hom.map_pow MonoidHom.map_pow
#align add_monoid_hom.map_nsmul AddMonoidHom.map_nsmul
-/

#print MonoidHom.map_zpow' /-
@[to_additive]
protected theorem MonoidHom.map_zpow' [DivInvMonoid M] [DivInvMonoid N] (f : M →* N)
    (hf : ∀ x, f x⁻¹ = (f x)⁻¹) (a : M) (n : ℤ) : f (a ^ n) = f a ^ n :=
  map_zpow' f hf a n
#align monoid_hom.map_zpow' MonoidHom.map_zpow'
#align add_monoid_hom.map_zsmul' AddMonoidHom.map_zsmul'
-/

section End

namespace Monoid

variable (M) [MulOneClass M]

#print Monoid.End /-
/-- The monoid of endomorphisms. -/
protected def End :=
  M →* M
#align monoid.End Monoid.End
-/

namespace End

instance : Monoid (Monoid.End M) where
  mul := MonoidHom.comp
  one := MonoidHom.id M
  mul_assoc _ _ _ := MonoidHom.comp_assoc _ _ _
  mul_one := MonoidHom.comp_id
  one_mul := MonoidHom.id_comp

instance : Inhabited (Monoid.End M) :=
  ⟨1⟩

instance : MonoidHomClass (Monoid.End M) M M :=
  MonoidHom.monoidHomClass

end End

#print Monoid.coe_one /-
@[simp]
theorem coe_one : ((1 : Monoid.End M) : M → M) = id :=
  rfl
#align monoid.coe_one Monoid.coe_one
-/

#print Monoid.coe_mul /-
@[simp]
theorem coe_mul (f g) : ((f * g : Monoid.End M) : M → M) = f ∘ g :=
  rfl
#align monoid.coe_mul Monoid.coe_mul
-/

end Monoid

namespace AddMonoid

variable (A : Type _) [AddZeroClass A]

#print AddMonoid.End /-
/-- The monoid of endomorphisms. -/
protected def End :=
  A →+ A
#align add_monoid.End AddMonoid.End
-/

namespace End

instance : Monoid (AddMonoid.End A)
    where
  mul := AddMonoidHom.comp
  one := AddMonoidHom.id A
  mul_assoc _ _ _ := AddMonoidHom.comp_assoc _ _ _
  mul_one := AddMonoidHom.comp_id
  one_mul := AddMonoidHom.id_comp

instance : Inhabited (AddMonoid.End A) :=
  ⟨1⟩

instance : AddMonoidHomClass (AddMonoid.End A) A A :=
  AddMonoidHom.addMonoidHomClass

end End

#print AddMonoid.coe_one /-
@[simp]
theorem coe_one : ((1 : AddMonoid.End A) : A → A) = id :=
  rfl
#align add_monoid.coe_one AddMonoid.coe_one
-/

#print AddMonoid.coe_mul /-
@[simp]
theorem coe_mul (f g) : ((f * g : AddMonoid.End A) : A → A) = f ∘ g :=
  rfl
#align add_monoid.coe_mul AddMonoid.coe_mul
-/

end AddMonoid

end End

/-- `1` is the homomorphism sending all elements to `1`. -/
@[to_additive]
instance [One M] [One N] : One (OneHom M N) :=
  ⟨⟨fun _ => 1, rfl⟩⟩

/-- `1` is the multiplicative homomorphism sending all elements to `1`. -/
@[to_additive]
instance [Mul M] [MulOneClass N] : One (M →ₙ* N) :=
  ⟨⟨fun _ => 1, fun _ _ => (one_mul 1).symm⟩⟩

/-- `1` is the monoid homomorphism sending all elements to `1`. -/
@[to_additive]
instance [MulOneClass M] [MulOneClass N] : One (M →* N) :=
  ⟨⟨fun _ => 1, rfl, fun _ _ => (one_mul 1).symm⟩⟩

/-- `0` is the homomorphism sending all elements to `0`. -/
add_decl_doc ZeroHom.hasZero

/-- `0` is the additive homomorphism sending all elements to `0`. -/
add_decl_doc AddHom.hasZero

/-- `0` is the additive monoid homomorphism sending all elements to `0`. -/
add_decl_doc AddMonoidHom.hasZero

#print OneHom.one_apply /-
@[simp, to_additive]
theorem OneHom.one_apply [One M] [One N] (x : M) : (1 : OneHom M N) x = 1 :=
  rfl
#align one_hom.one_apply OneHom.one_apply
#align zero_hom.zero_apply ZeroHom.zero_apply
-/

#print MonoidHom.one_apply /-
@[simp, to_additive]
theorem MonoidHom.one_apply [MulOneClass M] [MulOneClass N] (x : M) : (1 : M →* N) x = 1 :=
  rfl
#align monoid_hom.one_apply MonoidHom.one_apply
#align add_monoid_hom.zero_apply AddMonoidHom.zero_apply
-/

#print OneHom.one_comp /-
@[simp, to_additive]
theorem OneHom.one_comp [One M] [One N] [One P] (f : OneHom M N) : (1 : OneHom N P).comp f = 1 :=
  rfl
#align one_hom.one_comp OneHom.one_comp
#align zero_hom.zero_comp ZeroHom.zero_comp
-/

#print OneHom.comp_one /-
@[simp, to_additive]
theorem OneHom.comp_one [One M] [One N] [One P] (f : OneHom N P) : f.comp (1 : OneHom M N) = 1 := by
  ext; simp only [OneHom.map_one, OneHom.coe_comp, Function.comp_apply, OneHom.one_apply]
#align one_hom.comp_one OneHom.comp_one
#align zero_hom.comp_zero ZeroHom.comp_zero
-/

@[to_additive]
instance [One M] [One N] : Inhabited (OneHom M N) :=
  ⟨1⟩

@[to_additive]
instance [Mul M] [MulOneClass N] : Inhabited (M →ₙ* N) :=
  ⟨1⟩

@[to_additive]
instance [MulOneClass M] [MulOneClass N] : Inhabited (M →* N) :=
  ⟨1⟩

-- unlike the other homs, `monoid_with_zero_hom` does not have a `1` or `0`
instance [MulZeroOneClass M] : Inhabited (M →*₀ M) :=
  ⟨MonoidWithZeroHom.id M⟩

namespace MulHom

/-- Given two mul morphisms `f`, `g` to a commutative semigroup, `f * g` is the mul morphism
sending `x` to `f x * g x`. -/
@[to_additive]
instance [Mul M] [CommSemigroup N] : Mul (M →ₙ* N) :=
  ⟨fun f g =>
    { toFun := fun m => f m * g m
      map_mul' := by
        intros; show f (x * y) * g (x * y) = f x * g x * (f y * g y)
        rw [f.map_mul, g.map_mul, ← mul_assoc, ← mul_assoc, mul_right_comm (f x)] }⟩

/-- Given two additive morphisms `f`, `g` to an additive commutative semigroup, `f + g` is the
additive morphism sending `x` to `f x + g x`. -/
add_decl_doc AddHom.hasAdd

#print MulHom.mul_apply /-
@[simp, to_additive]
theorem mul_apply {M N} {mM : Mul M} {mN : CommSemigroup N} (f g : M →ₙ* N) (x : M) :
    (f * g) x = f x * g x :=
  rfl
#align mul_hom.mul_apply MulHom.mul_apply
#align add_hom.add_apply AddHom.add_apply
-/

#print MulHom.mul_comp /-
@[to_additive]
theorem mul_comp [Mul M] [Mul N] [CommSemigroup P] (g₁ g₂ : N →ₙ* P) (f : M →ₙ* N) :
    (g₁ * g₂).comp f = g₁.comp f * g₂.comp f :=
  rfl
#align mul_hom.mul_comp MulHom.mul_comp
#align add_hom.add_comp AddHom.add_comp
-/

#print MulHom.comp_mul /-
@[to_additive]
theorem comp_mul [Mul M] [CommSemigroup N] [CommSemigroup P] (g : N →ₙ* P) (f₁ f₂ : M →ₙ* N) :
    g.comp (f₁ * f₂) = g.comp f₁ * g.comp f₂ := by ext;
  simp only [mul_apply, Function.comp_apply, map_mul, coe_comp]
#align mul_hom.comp_mul MulHom.comp_mul
#align add_hom.comp_add AddHom.comp_add
-/

end MulHom

namespace MonoidHom

variable [mM : MulOneClass M] [mN : MulOneClass N] [mP : MulOneClass P]

variable [Group G] [CommGroup H]

/-- Given two monoid morphisms `f`, `g` to a commutative monoid, `f * g` is the monoid morphism
sending `x` to `f x * g x`. -/
@[to_additive]
instance {M N} {mM : MulOneClass M} [CommMonoid N] : Mul (M →* N) :=
  ⟨fun f g =>
    { toFun := fun m => f m * g m
      map_one' := show f 1 * g 1 = 1 by simp
      map_mul' := by
        intros; show f (x * y) * g (x * y) = f x * g x * (f y * g y)
        rw [f.map_mul, g.map_mul, ← mul_assoc, ← mul_assoc, mul_right_comm (f x)] }⟩

/-- Given two additive monoid morphisms `f`, `g` to an additive commutative monoid, `f + g` is the
additive monoid morphism sending `x` to `f x + g x`. -/
add_decl_doc AddMonoidHom.hasAdd

#print MonoidHom.mul_apply /-
@[simp, to_additive]
theorem mul_apply {M N} {mM : MulOneClass M} {mN : CommMonoid N} (f g : M →* N) (x : M) :
    (f * g) x = f x * g x :=
  rfl
#align monoid_hom.mul_apply MonoidHom.mul_apply
#align add_monoid_hom.add_apply AddMonoidHom.add_apply
-/

#print MonoidHom.one_comp /-
@[simp, to_additive]
theorem one_comp [MulOneClass M] [MulOneClass N] [MulOneClass P] (f : M →* N) :
    (1 : N →* P).comp f = 1 :=
  rfl
#align monoid_hom.one_comp MonoidHom.one_comp
#align add_monoid_hom.zero_comp AddMonoidHom.zero_comp
-/

#print MonoidHom.comp_one /-
@[simp, to_additive]
theorem comp_one [MulOneClass M] [MulOneClass N] [MulOneClass P] (f : N →* P) :
    f.comp (1 : M →* N) = 1 := by ext; simp only [map_one, coe_comp, Function.comp_apply, one_apply]
#align monoid_hom.comp_one MonoidHom.comp_one
#align add_monoid_hom.comp_zero AddMonoidHom.comp_zero
-/

#print MonoidHom.mul_comp /-
@[to_additive]
theorem mul_comp [MulOneClass M] [MulOneClass N] [CommMonoid P] (g₁ g₂ : N →* P) (f : M →* N) :
    (g₁ * g₂).comp f = g₁.comp f * g₂.comp f :=
  rfl
#align monoid_hom.mul_comp MonoidHom.mul_comp
#align add_monoid_hom.add_comp AddMonoidHom.add_comp
-/

#print MonoidHom.comp_mul /-
@[to_additive]
theorem comp_mul [MulOneClass M] [CommMonoid N] [CommMonoid P] (g : N →* P) (f₁ f₂ : M →* N) :
    g.comp (f₁ * f₂) = g.comp f₁ * g.comp f₂ := by ext;
  simp only [mul_apply, Function.comp_apply, map_mul, coe_comp]
#align monoid_hom.comp_mul MonoidHom.comp_mul
#align add_monoid_hom.comp_add AddMonoidHom.comp_add
-/

#print MonoidHom.map_inv /-
/-- Group homomorphisms preserve inverse. -/
@[to_additive "Additive group homomorphisms preserve negation."]
protected theorem map_inv [Group α] [DivisionMonoid β] (f : α →* β) (a : α) : f a⁻¹ = (f a)⁻¹ :=
  map_inv f _
#align monoid_hom.map_inv MonoidHom.map_inv
#align add_monoid_hom.map_neg AddMonoidHom.map_neg
-/

#print MonoidHom.map_zpow /-
/-- Group homomorphisms preserve integer power. -/
@[to_additive "Additive group homomorphisms preserve integer scaling."]
protected theorem map_zpow [Group α] [DivisionMonoid β] (f : α →* β) (g : α) (n : ℤ) :
    f (g ^ n) = f g ^ n :=
  map_zpow f g n
#align monoid_hom.map_zpow MonoidHom.map_zpow
#align add_monoid_hom.map_zsmul AddMonoidHom.map_zsmul
-/

#print MonoidHom.map_div /-
/-- Group homomorphisms preserve division. -/
@[to_additive "Additive group homomorphisms preserve subtraction."]
protected theorem map_div [Group α] [DivisionMonoid β] (f : α →* β) (g h : α) :
    f (g / h) = f g / f h :=
  map_div f g h
#align monoid_hom.map_div MonoidHom.map_div
#align add_monoid_hom.map_sub AddMonoidHom.map_sub
-/

#print MonoidHom.map_mul_inv /-
/-- Group homomorphisms preserve division. -/
@[to_additive "Additive group homomorphisms preserve subtraction."]
protected theorem map_mul_inv [Group α] [DivisionMonoid β] (f : α →* β) (g h : α) :
    f (g * h⁻¹) = f g * (f h)⁻¹ :=
  map_mul_inv f g h
#align monoid_hom.map_mul_inv MonoidHom.map_mul_inv
#align add_monoid_hom.map_add_neg AddMonoidHom.map_add_neg
-/

#print injective_iff_map_eq_one /-
/-- A homomorphism from a group to a monoid is injective iff its kernel is trivial.
For the iff statement on the triviality of the kernel, see `injective_iff_map_eq_one'`.  -/
@[to_additive
      "A homomorphism from an additive group to an additive monoid is injective iff\nits kernel is trivial. For the iff statement on the triviality of the kernel,\nsee `injective_iff_map_eq_zero'`."]
theorem injective_iff_map_eq_one {G H} [Group G] [MulOneClass H] [MonoidHomClass F G H] (f : F) :
    Function.Injective f ↔ ∀ a, f a = 1 → a = 1 :=
  ⟨fun h x => (map_eq_one_iff f h).mp, fun h x y hxy =>
    mul_inv_eq_one.1 <| h _ <| by rw [map_mul, hxy, ← map_mul, mul_inv_self, map_one]⟩
#align injective_iff_map_eq_one injective_iff_map_eq_one
#align injective_iff_map_eq_zero injective_iff_map_eq_zero
-/

#print injective_iff_map_eq_one' /-
/-- A homomorphism from a group to a monoid is injective iff its kernel is trivial,
stated as an iff on the triviality of the kernel.
For the implication, see `injective_iff_map_eq_one`. -/
@[to_additive
      "A homomorphism from an additive group to an additive monoid is injective iff its\nkernel is trivial, stated as an iff on the triviality of the kernel. For the implication, see\n`injective_iff_map_eq_zero`."]
theorem injective_iff_map_eq_one' {G H} [Group G] [MulOneClass H] [MonoidHomClass F G H] (f : F) :
    Function.Injective f ↔ ∀ a, f a = 1 ↔ a = 1 :=
  (injective_iff_map_eq_one f).trans <|
    forall_congr' fun a => ⟨fun h => ⟨h, fun H => H.symm ▸ map_one f⟩, Iff.mp⟩
#align injective_iff_map_eq_one' injective_iff_map_eq_one'
#align injective_iff_map_eq_zero' injective_iff_map_eq_zero'
-/

#print MonoidHom.mk' /-
/-- Makes a group homomorphism from a proof that the map preserves multiplication. -/
@[to_additive "Makes an additive group homomorphism from a proof that the map preserves addition.",
  simps (config := { fullyApplied := false })]
def mk' (f : M → G) (map_mul : ∀ a b : M, f (a * b) = f a * f b) : M →* G
    where
  toFun := f
  map_mul' := map_mul
  map_one' := mul_left_eq_self.1 <| by rw [← map_mul, mul_one]
#align monoid_hom.mk' MonoidHom.mk'
#align add_monoid_hom.mk' AddMonoidHom.mk'
-/

#print MonoidHom.ofMapMulInv /-
/-- Makes a group homomorphism from a proof that the map preserves right division `λ x y, x * y⁻¹`.
See also `monoid_hom.of_map_div` for a version using `λ x y, x / y`.
-/
@[to_additive
      "Makes an additive group homomorphism from a proof that the map preserves\nthe operation `λ a b, a + -b`. See also `add_monoid_hom.of_map_sub` for a version using\n`λ a b, a - b`."]
def ofMapMulInv {H : Type _} [Group H] (f : G → H)
    (map_div : ∀ a b : G, f (a * b⁻¹) = f a * (f b)⁻¹) : G →* H :=
  mk' f fun x y =>
    calc
      f (x * y) = f x * (f <| 1 * 1⁻¹ * y⁻¹)⁻¹ := by
        simp only [one_mul, inv_one, ← map_div, inv_inv]
      _ = f x * f y := by simp only [map_div]; simp only [mul_right_inv, one_mul, inv_inv]
#align monoid_hom.of_map_mul_inv MonoidHom.ofMapMulInv
#align add_monoid_hom.of_map_add_neg AddMonoidHom.ofMapAddNeg
-/

#print MonoidHom.coe_of_map_mul_inv /-
@[simp, to_additive]
theorem coe_of_map_mul_inv {H : Type _} [Group H] (f : G → H)
    (map_div : ∀ a b : G, f (a * b⁻¹) = f a * (f b)⁻¹) : ⇑(ofMapMulInv f map_div) = f :=
  rfl
#align monoid_hom.coe_of_map_mul_inv MonoidHom.coe_of_map_mul_inv
#align add_monoid_hom.coe_of_map_add_neg AddMonoidHom.coe_of_map_add_neg
-/

#print MonoidHom.ofMapDiv /-
/-- Define a morphism of additive groups given a map which respects ratios. -/
@[to_additive "Define a morphism of additive groups given a map which respects difference."]
def ofMapDiv {H : Type _} [Group H] (f : G → H) (hf : ∀ x y, f (x / y) = f x / f y) : G →* H :=
  ofMapMulInv f (by simpa only [div_eq_mul_inv] using hf)
#align monoid_hom.of_map_div MonoidHom.ofMapDiv
#align add_monoid_hom.of_map_sub AddMonoidHom.ofMapSub
-/

#print MonoidHom.coe_of_map_div /-
@[simp, to_additive]
theorem coe_of_map_div {H : Type _} [Group H] (f : G → H) (hf : ∀ x y, f (x / y) = f x / f y) :
    ⇑(ofMapDiv f hf) = f :=
  rfl
#align monoid_hom.coe_of_map_div MonoidHom.coe_of_map_div
#align add_monoid_hom.coe_of_map_sub AddMonoidHom.coe_of_map_sub
-/

/-- If `f` is a monoid homomorphism to a commutative group, then `f⁻¹` is the homomorphism sending
`x` to `(f x)⁻¹`. -/
@[to_additive]
instance {M G} [MulOneClass M] [CommGroup G] : Inv (M →* G) :=
  ⟨fun f => mk' (fun g => (f g)⁻¹) fun a b => by rw [← mul_inv, f.map_mul]⟩

/-- If `f` is an additive monoid homomorphism to an additive commutative group, then `-f` is the
homomorphism sending `x` to `-(f x)`. -/
add_decl_doc AddMonoidHom.hasNeg

#print MonoidHom.inv_apply /-
@[simp, to_additive]
theorem inv_apply {M G} {mM : MulOneClass M} {gG : CommGroup G} (f : M →* G) (x : M) :
    f⁻¹ x = (f x)⁻¹ :=
  rfl
#align monoid_hom.inv_apply MonoidHom.inv_apply
#align add_monoid_hom.neg_apply AddMonoidHom.neg_apply
-/

#print MonoidHom.inv_comp /-
@[simp, to_additive]
theorem inv_comp {M N A} {mM : MulOneClass M} {gN : MulOneClass N} {gA : CommGroup A} (φ : N →* A)
    (ψ : M →* N) : φ⁻¹.comp ψ = (φ.comp ψ)⁻¹ := by ext;
  simp only [Function.comp_apply, inv_apply, coe_comp]
#align monoid_hom.inv_comp MonoidHom.inv_comp
#align add_monoid_hom.neg_comp AddMonoidHom.neg_comp
-/

#print MonoidHom.comp_inv /-
@[simp, to_additive]
theorem comp_inv {M A B} {mM : MulOneClass M} {mA : CommGroup A} {mB : CommGroup B} (φ : A →* B)
    (ψ : M →* A) : φ.comp ψ⁻¹ = (φ.comp ψ)⁻¹ := by ext;
  simp only [Function.comp_apply, inv_apply, map_inv, coe_comp]
#align monoid_hom.comp_inv MonoidHom.comp_inv
#align add_monoid_hom.comp_neg AddMonoidHom.comp_neg
-/

/-- If `f` and `g` are monoid homomorphisms to a commutative group, then `f / g` is the homomorphism
sending `x` to `(f x) / (g x)`. -/
@[to_additive]
instance {M G} [MulOneClass M] [CommGroup G] : Div (M →* G) :=
  ⟨fun f g =>
    mk' (fun x => f x / g x) fun a b => by
      simp [div_eq_mul_inv, mul_assoc, mul_left_comm, mul_comm]⟩

/-- If `f` and `g` are monoid homomorphisms to an additive commutative group, then `f - g`
is the homomorphism sending `x` to `(f x) - (g x)`. -/
add_decl_doc AddMonoidHom.hasSub

#print MonoidHom.div_apply /-
@[simp, to_additive]
theorem div_apply {M G} {mM : MulOneClass M} {gG : CommGroup G} (f g : M →* G) (x : M) :
    (f / g) x = f x / g x :=
  rfl
#align monoid_hom.div_apply MonoidHom.div_apply
#align add_monoid_hom.sub_apply AddMonoidHom.sub_apply
-/

end MonoidHom

/-- Given two monoid with zero morphisms `f`, `g` to a commutative monoid, `f * g` is the monoid
with zero morphism sending `x` to `f x * g x`. -/
instance {M N} {hM : MulZeroOneClass M} [CommMonoidWithZero N] : Mul (M →*₀ N) :=
  ⟨fun f g =>
    { (f * g : M →* N) with
      toFun := fun a => f a * g a
      map_zero' := by rw [map_zero, MulZeroClass.zero_mul] }⟩

