/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies, Christopher Hoskin

! This file was ported from Lean 3 source module algebra.hom.centroid
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.GroupPower.Lemmas
import Mathbin.Algebra.Hom.GroupInstances

/-!
# Centroid homomorphisms

Let `A` be a (non unital, non associative) algebra. The centroid of `A` is the set of linear maps
`T` on `A` such that `T` commutes with left and right multiplication, that is to say, for all `a`
and `b` in `A`,
$$
T(ab) = (Ta)b, T(ab) = a(Tb).
$$
In mathlib we call elements of the centroid "centroid homomorphisms" (`centroid_hom`) in keeping
with `add_monoid_hom` etc.

We use the `fun_like` design, so each type of morphisms has a companion typeclass which is meant to
be satisfied by itself and all stricter types.

## Types of morphisms

* `centroid_hom`: Maps which preserve left and right multiplication.

## Typeclasses

* `centroid_hom_class`

## References

* [Jacobson, Structure of Rings][Jacobson1956]
* [McCrimmon, A taste of Jordan algebras][mccrimmon2004]

## Tags

centroid
-/


open Function

variable {F α : Type _}

-- Making `centroid_hom` an old structure will allow the lemma `to_add_monoid_hom_eq_coe`
-- to be true by `rfl`. After upgrading to Lean 4, this should no longer be needed
-- because eta for structures should provide the same result.
/-- The type of centroid homomorphisms from `α` to `α`. -/
structure CentroidHom (α : Type _) [NonUnitalNonAssocSemiring α] extends α →+ α where
  map_mul_left' (a b : α) : to_fun (a * b) = a * to_fun b
  map_mul_right' (a b : α) : to_fun (a * b) = to_fun a * b
#align centroid_hom CentroidHom

attribute [nolint doc_blame] CentroidHom.toAddMonoidHom

/-- `centroid_hom_class F α` states that `F` is a type of centroid homomorphisms.

You should extend this class when you extend `centroid_hom`. -/
class CentroidHomClass (F : Type _) (α : outParam <| Type _) [NonUnitalNonAssocSemiring α] extends
  AddMonoidHomClass F α α where
  map_mul_left (f : F) (a b : α) : f (a * b) = a * f b
  map_mul_right (f : F) (a b : α) : f (a * b) = f a * b
#align centroid_hom_class CentroidHomClass

export CentroidHomClass (map_mul_left map_mul_right)

instance [NonUnitalNonAssocSemiring α] [CentroidHomClass F α] : CoeTC F (CentroidHom α) :=
  ⟨fun f =>
    { (f : α →+ α) with
      toFun := f
      map_mul_left' := map_mul_left f
      map_mul_right' := map_mul_right f }⟩

/-! ### Centroid homomorphisms -/


namespace CentroidHom

section NonUnitalNonAssocSemiring

variable [NonUnitalNonAssocSemiring α]

instance : CentroidHomClass (CentroidHom α) α
    where
  coe f := f.toFun
  coe_injective' f g h := by
    cases f
    cases g
    congr
  map_zero f := f.map_zero'
  map_add f := f.map_add'
  map_mul_left f := f.map_mul_left'
  map_mul_right f := f.map_mul_right'

/-- Helper instance for when there's too many metavariables to apply `fun_like.has_coe_to_fun`
directly. -/
instance : CoeFun (CentroidHom α) fun _ => α → α :=
  FunLike.hasCoeToFun

@[simp]
theorem to_fun_eq_coe {f : CentroidHom α} : f.toFun = (f : α → α) :=
  rfl
#align centroid_hom.to_fun_eq_coe CentroidHom.to_fun_eq_coe

@[ext]
theorem ext {f g : CentroidHom α} (h : ∀ a, f a = g a) : f = g :=
  FunLike.ext f g h
#align centroid_hom.ext CentroidHom.ext

@[simp, norm_cast]
theorem coe_to_add_monoid_hom (f : CentroidHom α) : ⇑(f : α →+ α) = f :=
  rfl
#align centroid_hom.coe_to_add_monoid_hom CentroidHom.coe_to_add_monoid_hom

@[simp]
theorem to_add_monoid_hom_eq_coe (f : CentroidHom α) : f.toAddMonoidHom = f :=
  rfl
#align centroid_hom.to_add_monoid_hom_eq_coe CentroidHom.to_add_monoid_hom_eq_coe

theorem coe_to_add_monoid_hom_injective : Injective (coe : CentroidHom α → α →+ α) := fun f g h =>
  ext fun a =>
    haveI := FunLike.congr_fun h a
    this
#align centroid_hom.coe_to_add_monoid_hom_injective CentroidHom.coe_to_add_monoid_hom_injective

/-- Turn a centroid homomorphism into an additive monoid endomorphism. -/
def toEnd (f : CentroidHom α) : AddMonoid.End α :=
  (f : α →+ α)
#align centroid_hom.to_End CentroidHom.toEnd

theorem to_End_injective : Injective (CentroidHom.toEnd : CentroidHom α → AddMonoid.End α) :=
  coe_to_add_monoid_hom_injective
#align centroid_hom.to_End_injective CentroidHom.to_End_injective

/-- Copy of a `centroid_hom` with a new `to_fun` equal to the old one. Useful to fix
definitional equalities. -/
protected def copy (f : CentroidHom α) (f' : α → α) (h : f' = f) : CentroidHom α :=
  { f.toAddMonoidHom.copy f' <| h with
    toFun := f'
    map_mul_left' := fun a b => by simp_rw [h, map_mul_left]
    map_mul_right' := fun a b => by simp_rw [h, map_mul_right] }
#align centroid_hom.copy CentroidHom.copy

@[simp]
theorem coe_copy (f : CentroidHom α) (f' : α → α) (h : f' = f) : ⇑(f.copy f' h) = f' :=
  rfl
#align centroid_hom.coe_copy CentroidHom.coe_copy

theorem copy_eq (f : CentroidHom α) (f' : α → α) (h : f' = f) : f.copy f' h = f :=
  FunLike.ext' h
#align centroid_hom.copy_eq CentroidHom.copy_eq

variable (α)

/-- `id` as a `centroid_hom`. -/
protected def id : CentroidHom α :=
  { AddMonoidHom.id α with
    map_mul_left' := fun _ _ => rfl
    map_mul_right' := fun _ _ => rfl }
#align centroid_hom.id CentroidHom.id

instance : Inhabited (CentroidHom α) :=
  ⟨CentroidHom.id α⟩

@[simp, norm_cast]
theorem coe_id : ⇑(CentroidHom.id α) = id :=
  rfl
#align centroid_hom.coe_id CentroidHom.coe_id

@[simp, norm_cast]
theorem coe_to_add_monoid_hom_id : (CentroidHom.id α : α →+ α) = AddMonoidHom.id α :=
  rfl
#align centroid_hom.coe_to_add_monoid_hom_id CentroidHom.coe_to_add_monoid_hom_id

variable {α}

@[simp]
theorem id_apply (a : α) : CentroidHom.id α a = a :=
  rfl
#align centroid_hom.id_apply CentroidHom.id_apply

/-- Composition of `centroid_hom`s as a `centroid_hom`. -/
def comp (g f : CentroidHom α) : CentroidHom α :=
  {
    g.toAddMonoidHom.comp
      f.toAddMonoidHom with
    map_mul_left' := fun a b => (congr_arg g <| f.map_mul_left' _ _).trans <| g.map_mul_left' _ _
    map_mul_right' := fun a b =>
      (congr_arg g <| f.map_mul_right' _ _).trans <| g.map_mul_right' _ _ }
#align centroid_hom.comp CentroidHom.comp

@[simp, norm_cast]
theorem coe_comp (g f : CentroidHom α) : ⇑(g.comp f) = g ∘ f :=
  rfl
#align centroid_hom.coe_comp CentroidHom.coe_comp

@[simp]
theorem comp_apply (g f : CentroidHom α) (a : α) : g.comp f a = g (f a) :=
  rfl
#align centroid_hom.comp_apply CentroidHom.comp_apply

@[simp, norm_cast]
theorem coe_comp_add_monoid_hom (g f : CentroidHom α) : (g.comp f : α →+ α) = (g : α →+ α).comp f :=
  rfl
#align centroid_hom.coe_comp_add_monoid_hom CentroidHom.coe_comp_add_monoid_hom

@[simp]
theorem comp_assoc (h g f : CentroidHom α) : (h.comp g).comp f = h.comp (g.comp f) :=
  rfl
#align centroid_hom.comp_assoc CentroidHom.comp_assoc

@[simp]
theorem comp_id (f : CentroidHom α) : f.comp (CentroidHom.id α) = f :=
  ext fun a => rfl
#align centroid_hom.comp_id CentroidHom.comp_id

@[simp]
theorem id_comp (f : CentroidHom α) : (CentroidHom.id α).comp f = f :=
  ext fun a => rfl
#align centroid_hom.id_comp CentroidHom.id_comp

theorem cancel_right {g₁ g₂ f : CentroidHom α} (hf : Surjective f) :
    g₁.comp f = g₂.comp f ↔ g₁ = g₂ :=
  ⟨fun h => ext <| hf.forall.2 <| FunLike.ext_iff.1 h, congr_arg _⟩
#align centroid_hom.cancel_right CentroidHom.cancel_right

theorem cancel_left {g f₁ f₂ : CentroidHom α} (hg : Injective g) :
    g.comp f₁ = g.comp f₂ ↔ f₁ = f₂ :=
  ⟨fun h => ext fun a => hg <| by rw [← comp_apply, h, comp_apply], congr_arg _⟩
#align centroid_hom.cancel_left CentroidHom.cancel_left

instance : Zero (CentroidHom α) :=
  ⟨{ (0 : α →+ α) with
      map_mul_left' := fun a b => (mul_zero _).symm
      map_mul_right' := fun a b => (zero_mul _).symm }⟩

instance : One (CentroidHom α) :=
  ⟨CentroidHom.id α⟩

instance : Add (CentroidHom α) :=
  ⟨fun f g =>
    {
      (f + g : α →+
          α) with
      map_mul_left' := fun a b => by simp [map_mul_left, mul_add]
      map_mul_right' := fun a b => by simp [map_mul_right, add_mul] }⟩

instance : Mul (CentroidHom α) :=
  ⟨comp⟩

instance hasNsmul : HasSmul ℕ (CentroidHom α) :=
  ⟨fun n f =>
    {
      (n • f :
        α →+
          α) with
      map_mul_left' := fun a b => by
        change n • f (a * b) = a * n • f b
        rw [map_mul_left f, ← mul_smul_comm]
      map_mul_right' := fun a b => by
        change n • f (a * b) = n • f a * b
        rw [map_mul_right f, ← smul_mul_assoc] }⟩
#align centroid_hom.has_nsmul CentroidHom.hasNsmul

instance hasNpowNat : Pow (CentroidHom α) ℕ :=
  ⟨fun f n =>
    {
      (f.toEnd ^ n :
        AddMonoid.End
          α) with
      map_mul_left' := fun a b => by
        induction' n with n ih
        · simp
        · rw [pow_succ]
          exact (congr_arg f.to_End ih).trans (f.map_mul_left' _ _)
      map_mul_right' := fun a b => by
        induction' n with n ih
        · simp
        · rw [pow_succ]
          exact (congr_arg f.to_End ih).trans (f.map_mul_right' _ _) }⟩
#align centroid_hom.has_npow_nat CentroidHom.hasNpowNat

@[simp, norm_cast]
theorem coe_zero : ⇑(0 : CentroidHom α) = 0 :=
  rfl
#align centroid_hom.coe_zero CentroidHom.coe_zero

@[simp, norm_cast]
theorem coe_one : ⇑(1 : CentroidHom α) = id :=
  rfl
#align centroid_hom.coe_one CentroidHom.coe_one

@[simp, norm_cast]
theorem coe_add (f g : CentroidHom α) : ⇑(f + g) = f + g :=
  rfl
#align centroid_hom.coe_add CentroidHom.coe_add

@[simp, norm_cast]
theorem coe_mul (f g : CentroidHom α) : ⇑(f * g) = f ∘ g :=
  rfl
#align centroid_hom.coe_mul CentroidHom.coe_mul

-- Eligible for `dsimp`
@[simp, norm_cast, nolint simp_nf]
theorem coe_nsmul (f : CentroidHom α) (n : ℕ) : ⇑(n • f) = n • f :=
  rfl
#align centroid_hom.coe_nsmul CentroidHom.coe_nsmul

@[simp]
theorem zero_apply (a : α) : (0 : CentroidHom α) a = 0 :=
  rfl
#align centroid_hom.zero_apply CentroidHom.zero_apply

@[simp]
theorem one_apply (a : α) : (1 : CentroidHom α) a = a :=
  rfl
#align centroid_hom.one_apply CentroidHom.one_apply

@[simp]
theorem add_apply (f g : CentroidHom α) (a : α) : (f + g) a = f a + g a :=
  rfl
#align centroid_hom.add_apply CentroidHom.add_apply

@[simp]
theorem mul_apply (f g : CentroidHom α) (a : α) : (f * g) a = f (g a) :=
  rfl
#align centroid_hom.mul_apply CentroidHom.mul_apply

-- Eligible for `dsimp`
@[simp, nolint simp_nf]
theorem nsmul_apply (f : CentroidHom α) (n : ℕ) (a : α) : (n • f) a = n • f a :=
  rfl
#align centroid_hom.nsmul_apply CentroidHom.nsmul_apply

@[simp]
theorem to_End_zero : (0 : CentroidHom α).toEnd = 0 :=
  rfl
#align centroid_hom.to_End_zero CentroidHom.to_End_zero

@[simp]
theorem to_End_add (x y : CentroidHom α) : (x + y).toEnd = x.toEnd + y.toEnd :=
  rfl
#align centroid_hom.to_End_add CentroidHom.to_End_add

theorem to_End_nsmul (x : CentroidHom α) (n : ℕ) : (n • x).toEnd = n • x.toEnd :=
  rfl
#align centroid_hom.to_End_nsmul CentroidHom.to_End_nsmul

-- cf.`add_monoid_hom.add_comm_monoid`
instance : AddCommMonoid (CentroidHom α) :=
  coe_to_add_monoid_hom_injective.AddCommMonoid _ to_End_zero to_End_add to_End_nsmul

instance : NatCast (CentroidHom α) where natCast n := n • 1

@[simp, norm_cast]
theorem coe_nat_cast (n : ℕ) : ⇑(n : CentroidHom α) = n • id :=
  rfl
#align centroid_hom.coe_nat_cast CentroidHom.coe_nat_cast

theorem nat_cast_apply (n : ℕ) (m : α) : (n : CentroidHom α) m = n • m :=
  rfl
#align centroid_hom.nat_cast_apply CentroidHom.nat_cast_apply

@[simp]
theorem to_End_one : (1 : CentroidHom α).toEnd = 1 :=
  rfl
#align centroid_hom.to_End_one CentroidHom.to_End_one

@[simp]
theorem to_End_mul (x y : CentroidHom α) : (x * y).toEnd = x.toEnd * y.toEnd :=
  rfl
#align centroid_hom.to_End_mul CentroidHom.to_End_mul

@[simp]
theorem to_End_pow (x : CentroidHom α) (n : ℕ) : (x ^ n).toEnd = x.toEnd ^ n :=
  by
  ext
  rfl
#align centroid_hom.to_End_pow CentroidHom.to_End_pow

@[simp, norm_cast]
theorem to_End_nat_cast (n : ℕ) : (n : CentroidHom α).toEnd = ↑n :=
  rfl
#align centroid_hom.to_End_nat_cast CentroidHom.to_End_nat_cast

-- cf `add_monoid.End.semiring`
instance : Semiring (CentroidHom α) :=
  to_End_injective.Semiring _ to_End_zero to_End_one to_End_add to_End_mul to_End_nsmul to_End_pow
    to_End_nat_cast

theorem comp_mul_comm (T S : CentroidHom α) (a b : α) : (T ∘ S) (a * b) = (S ∘ T) (a * b) := by
  rw [comp_app, map_mul_right, map_mul_left, ← map_mul_right, ← map_mul_left]
#align centroid_hom.comp_mul_comm CentroidHom.comp_mul_comm

end NonUnitalNonAssocSemiring

section NonUnitalNonAssocRing

variable [NonUnitalNonAssocRing α]

/-- Negation of `centroid_hom`s as a `centroid_hom`. -/
instance : Neg (CentroidHom α) :=
  ⟨fun f =>
    { (-f : α →+ α) with
      map_mul_left' := by simp [map_mul_left]
      map_mul_right' := by simp [map_mul_right] }⟩

instance : Sub (CentroidHom α) :=
  ⟨fun f g =>
    {
      (f - g : α →+
          α) with
      map_mul_left' := fun a b => by simp [map_mul_left, mul_sub]
      map_mul_right' := fun a b => by simp [map_mul_right, sub_mul] }⟩

instance hasZsmul : HasSmul ℤ (CentroidHom α) :=
  ⟨fun n f =>
    {
      (n • f :
        α →+
          α) with
      map_mul_left' := fun a b => by
        change n • f (a * b) = a * n • f b
        rw [map_mul_left f, ← mul_smul_comm]
      map_mul_right' := fun a b => by
        change n • f (a * b) = n • f a * b
        rw [map_mul_right f, ← smul_mul_assoc] }⟩
#align centroid_hom.has_zsmul CentroidHom.hasZsmul

instance : IntCast (CentroidHom α) where intCast z := z • 1

@[simp, norm_cast]
theorem coe_int_cast (z : ℤ) : ⇑(z : CentroidHom α) = z • id :=
  rfl
#align centroid_hom.coe_int_cast CentroidHom.coe_int_cast

theorem int_cast_apply (z : ℤ) (m : α) : (z : CentroidHom α) m = z • m :=
  rfl
#align centroid_hom.int_cast_apply CentroidHom.int_cast_apply

@[simp]
theorem to_End_neg (x : CentroidHom α) : (-x).toEnd = -x.toEnd :=
  rfl
#align centroid_hom.to_End_neg CentroidHom.to_End_neg

@[simp]
theorem to_End_sub (x y : CentroidHom α) : (x - y).toEnd = x.toEnd - y.toEnd :=
  rfl
#align centroid_hom.to_End_sub CentroidHom.to_End_sub

theorem to_End_zsmul (x : CentroidHom α) (n : ℤ) : (n • x).toEnd = n • x.toEnd :=
  rfl
#align centroid_hom.to_End_zsmul CentroidHom.to_End_zsmul

instance : AddCommGroup (CentroidHom α) :=
  to_End_injective.AddCommGroup _ to_End_zero to_End_add to_End_neg to_End_sub to_End_nsmul
    to_End_zsmul

@[simp, norm_cast]
theorem coe_neg (f : CentroidHom α) : ⇑(-f) = -f :=
  rfl
#align centroid_hom.coe_neg CentroidHom.coe_neg

@[simp, norm_cast]
theorem coe_sub (f g : CentroidHom α) : ⇑(f - g) = f - g :=
  rfl
#align centroid_hom.coe_sub CentroidHom.coe_sub

@[simp]
theorem neg_apply (f : CentroidHom α) (a : α) : (-f) a = -f a :=
  rfl
#align centroid_hom.neg_apply CentroidHom.neg_apply

@[simp]
theorem sub_apply (f g : CentroidHom α) (a : α) : (f - g) a = f a - g a :=
  rfl
#align centroid_hom.sub_apply CentroidHom.sub_apply

@[simp, norm_cast]
theorem to_End_int_cast (z : ℤ) : (z : CentroidHom α).toEnd = ↑z :=
  rfl
#align centroid_hom.to_End_int_cast CentroidHom.to_End_int_cast

instance : Ring (CentroidHom α) :=
  to_End_injective.Ring _ to_End_zero to_End_one to_End_add to_End_mul to_End_neg to_End_sub
    to_End_nsmul to_End_zsmul to_End_pow to_End_nat_cast to_End_int_cast

end NonUnitalNonAssocRing

section NonUnitalRing

variable [NonUnitalRing α]

-- See note [reducible non instances]
/-- A prime associative ring has commutative centroid. -/
@[reducible]
def commRing (h : ∀ a b : α, (∀ r : α, a * r * b = 0) → a = 0 ∨ b = 0) : CommRing (CentroidHom α) :=
  { CentroidHom.ring with
    mul_comm := fun f g => by
      ext
      refine' sub_eq_zero.1 ((or_self_iff _).1 <| (h _ _) fun r => _)
      rw [mul_assoc, sub_mul, sub_eq_zero, ← map_mul_right, ← map_mul_right, coe_mul, coe_mul,
        comp_mul_comm] }
#align centroid_hom.comm_ring CentroidHom.commRing

end NonUnitalRing

end CentroidHom

