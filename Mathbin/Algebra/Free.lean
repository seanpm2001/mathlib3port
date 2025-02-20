/-
Copyright (c) 2019 Kenny Lau. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kenny Lau

! This file was ported from Lean 3 source module algebra.free
! leanprover-community/mathlib commit 68d1483e8a718ec63219f0e227ca3f0140361086
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Hom.Group
import Mathbin.Algebra.Hom.Equiv.Basic
import Mathbin.Control.Applicative
import Mathbin.Control.Traversable.Basic
import Mathbin.Logic.Equiv.Defs
import Mathbin.Data.List.Basic

/-!
# Free constructions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

## Main definitions

* `free_magma α`: free magma (structure with binary operation without any axioms) over alphabet `α`,
  defined inductively, with traversable instance and decidable equality.
* `magma.assoc_quotient α`: quotient of a magma `α` by the associativity equivalence relation.
* `free_semigroup α`: free semigroup over alphabet `α`, defined as a structure with two fields
  `head : α` and `tail : list α` (i.e. nonempty lists), with traversable instance and decidable
  equality.
* `free_magma_assoc_quotient_equiv α`: isomorphism between `magma.assoc_quotient (free_magma α)` and
  `free_semigroup α`.
* `free_magma.lift`: the universal property of the free magma, expressing its adjointness.
-/


universe u v l

#print FreeMagma /-
/-- Free magma over a given alphabet. -/
inductive FreeMagma (α : Type u) : Type u
  | of : α → FreeMagma
  | mul : FreeMagma → FreeMagma → FreeMagma
  deriving DecidableEq
#align free_magma FreeMagma
-/

#print FreeAddMagma /-
/-- Free nonabelian additive magma over a given alphabet. -/
inductive FreeAddMagma (α : Type u) : Type u
  | of : α → FreeAddMagma
  | add : FreeAddMagma → FreeAddMagma → FreeAddMagma
  deriving DecidableEq
#align free_add_magma FreeAddMagma
-/

attribute [to_additive] FreeMagma

namespace FreeMagma

variable {α : Type u}

@[to_additive]
instance [Inhabited α] : Inhabited (FreeMagma α) :=
  ⟨of default⟩

@[to_additive]
instance : Mul (FreeMagma α) :=
  ⟨FreeMagma.mul⟩

attribute [match_pattern] Mul.mul

#print FreeMagma.mul_eq /-
@[simp, to_additive]
theorem mul_eq (x y : FreeMagma α) : mul x y = x * y :=
  rfl
#align free_magma.mul_eq FreeMagma.mul_eq
#align free_add_magma.add_eq FreeAddMagma.add_eq
-/

#print FreeMagma.recOnMul /-
/-- Recursor for `free_magma` using `x * y` instead of `free_magma.mul x y`. -/
@[elab_as_elim,
  to_additive "Recursor for `free_add_magma` using `x + y` instead of `free_add_magma.add x y`."]
def recOnMul {C : FreeMagma α → Sort l} (x) (ih1 : ∀ x, C (of x))
    (ih2 : ∀ x y, C x → C y → C (x * y)) : C x :=
  FreeMagma.recOn x ih1 ih2
#align free_magma.rec_on_mul FreeMagma.recOnMul
#align free_add_magma.rec_on_add FreeAddMagma.recOnAdd
-/

#print FreeMagma.hom_ext /-
@[ext, to_additive]
theorem hom_ext {β : Type v} [Mul β] {f g : FreeMagma α →ₙ* β} (h : f ∘ of = g ∘ of) : f = g :=
  FunLike.ext _ _ fun x => recOnMul x (congr_fun h) <| by intros; simp only [map_mul, *]
#align free_magma.hom_ext FreeMagma.hom_ext
#align free_add_magma.hom_ext FreeAddMagma.hom_ext
-/

end FreeMagma

#print FreeMagma.liftAux /-
/-- Lifts a function `α → β` to a magma homomorphism `free_magma α → β` given a magma `β`. -/
def FreeMagma.liftAux {α : Type u} {β : Type v} [Mul β] (f : α → β) : FreeMagma α → β
  | FreeMagma.of x => f x
  | x * y => x.liftAux * y.liftAux
#align free_magma.lift_aux FreeMagma.liftAux
-/

#print FreeAddMagma.liftAux /-
/-- Lifts a function `α → β` to an additive magma homomorphism `free_add_magma α → β` given
an additive magma `β`. -/
def FreeAddMagma.liftAux {α : Type u} {β : Type v} [Add β] (f : α → β) : FreeAddMagma α → β
  | FreeAddMagma.of x => f x
  | x + y => x.liftAux + y.liftAux
#align free_add_magma.lift_aux FreeAddMagma.liftAux
-/

attribute [to_additive FreeAddMagma.liftAux] FreeMagma.liftAux

namespace FreeMagma

section lift

variable {α : Type u} {β : Type v} [Mul β] (f : α → β)

#print FreeMagma.lift /-
/-- The universal property of the free magma expressing its adjointness. -/
@[to_additive "The universal property of the free additive magma expressing its adjointness.",
  simps symm_apply]
def lift : (α → β) ≃ (FreeMagma α →ₙ* β)
    where
  toFun f :=
    { toFun := liftAux f
      map_mul' := fun x y => rfl }
  invFun F := F ∘ of
  left_inv f := by ext; rfl
  right_inv F := by ext; rfl
#align free_magma.lift FreeMagma.lift
#align free_add_magma.lift FreeAddMagma.lift
-/

#print FreeMagma.lift_of /-
@[simp, to_additive]
theorem lift_of (x) : lift f (of x) = f x :=
  rfl
#align free_magma.lift_of FreeMagma.lift_of
#align free_add_magma.lift_of FreeAddMagma.lift_of
-/

#print FreeMagma.lift_comp_of /-
@[simp, to_additive]
theorem lift_comp_of : lift f ∘ of = f :=
  rfl
#align free_magma.lift_comp_of FreeMagma.lift_comp_of
#align free_add_magma.lift_comp_of FreeAddMagma.lift_comp_of
-/

#print FreeMagma.lift_comp_of' /-
@[simp, to_additive]
theorem lift_comp_of' (f : FreeMagma α →ₙ* β) : lift (f ∘ of) = f :=
  lift.apply_symm_apply f
#align free_magma.lift_comp_of' FreeMagma.lift_comp_of'
#align free_add_magma.lift_comp_of' FreeAddMagma.lift_comp_of'
-/

end lift

section Map

variable {α : Type u} {β : Type v} (f : α → β)

#print FreeMagma.map /-
/-- The unique magma homomorphism `free_magma α →ₙ* free_magma β` that sends
each `of x` to `of (f x)`. -/
@[to_additive
      "The unique additive magma homomorphism `free_add_magma α → free_add_magma β` that\nsends each `of x` to `of (f x)`."]
def map (f : α → β) : FreeMagma α →ₙ* FreeMagma β :=
  lift (of ∘ f)
#align free_magma.map FreeMagma.map
#align free_add_magma.map FreeAddMagma.map
-/

#print FreeMagma.map_of /-
@[simp, to_additive]
theorem map_of (x) : map f (of x) = of (f x) :=
  rfl
#align free_magma.map_of FreeMagma.map_of
#align free_add_magma.map_of FreeAddMagma.map_of
-/

end Map

section Category

variable {α β : Type u}

@[to_additive]
instance : Monad FreeMagma where
  pure _ := of
  bind _ _ x f := lift f x

#print FreeMagma.recOnPure /-
/-- Recursor on `free_magma` using `pure` instead of `of`. -/
@[elab_as_elim, to_additive "Recursor on `free_add_magma` using `pure` instead of `of`."]
protected def recOnPure {C : FreeMagma α → Sort l} (x) (ih1 : ∀ x, C (pure x))
    (ih2 : ∀ x y, C x → C y → C (x * y)) : C x :=
  FreeMagma.recOnMul x ih1 ih2
#align free_magma.rec_on_pure FreeMagma.recOnPure
#align free_add_magma.rec_on_pure FreeAddMagma.recOnPure
-/

#print FreeMagma.map_pure /-
@[simp, to_additive]
theorem map_pure (f : α → β) (x) : (f <$> pure x : FreeMagma β) = pure (f x) :=
  rfl
#align free_magma.map_pure FreeMagma.map_pure
#align free_add_magma.map_pure FreeAddMagma.map_pure
-/

#print FreeMagma.map_mul' /-
@[simp, to_additive]
theorem map_mul' (f : α → β) (x y : FreeMagma α) : f <$> (x * y) = f <$> x * f <$> y :=
  rfl
#align free_magma.map_mul' FreeMagma.map_mul'
#align free_add_magma.map_add' FreeAddMagma.map_add'
-/

#print FreeMagma.pure_bind /-
@[simp, to_additive]
theorem pure_bind (f : α → FreeMagma β) (x) : pure x >>= f = f x :=
  rfl
#align free_magma.pure_bind FreeMagma.pure_bind
#align free_add_magma.pure_bind FreeAddMagma.pure_bind
-/

#print FreeMagma.mul_bind /-
@[simp, to_additive]
theorem mul_bind (f : α → FreeMagma β) (x y : FreeMagma α) : x * y >>= f = (x >>= f) * (y >>= f) :=
  rfl
#align free_magma.mul_bind FreeMagma.mul_bind
#align free_add_magma.add_bind FreeAddMagma.add_bind
-/

#print FreeMagma.pure_seq /-
@[simp, to_additive]
theorem pure_seq {α β : Type u} {f : α → β} {x : FreeMagma α} : pure f <*> x = f <$> x :=
  rfl
#align free_magma.pure_seq FreeMagma.pure_seq
#align free_add_magma.pure_seq FreeAddMagma.pure_seq
-/

#print FreeMagma.mul_seq /-
@[simp, to_additive]
theorem mul_seq {α β : Type u} {f g : FreeMagma (α → β)} {x : FreeMagma α} :
    f * g <*> x = (f <*> x) * (g <*> x) :=
  rfl
#align free_magma.mul_seq FreeMagma.mul_seq
#align free_add_magma.add_seq FreeAddMagma.add_seq
-/

@[to_additive]
instance : LawfulMonad FreeMagma.{u}
    where
  pure_bind _ _ _ _ := rfl
  bind_assoc α β γ x f g :=
    FreeMagma.recOnPure x (fun x => rfl) fun x y ih1 ih2 => by
      rw [mul_bind, mul_bind, mul_bind, ih1, ih2]
  id_map α x := FreeMagma.recOnPure x (fun _ => rfl) fun x y ih1 ih2 => by rw [map_mul', ih1, ih2]

end Category

end FreeMagma

#print FreeMagma.traverse /-
/-- `free_magma` is traversable. -/
protected def FreeMagma.traverse {m : Type u → Type u} [Applicative m] {α β : Type u}
    (F : α → m β) : FreeMagma α → m (FreeMagma β)
  | FreeMagma.of x => FreeMagma.of <$> F x
  | x * y => (· * ·) <$> x.traverse <*> y.traverse
#align free_magma.traverse FreeMagma.traverse
-/

#print FreeAddMagma.traverse /-
/-- `free_add_magma` is traversable. -/
protected def FreeAddMagma.traverse {m : Type u → Type u} [Applicative m] {α β : Type u}
    (F : α → m β) : FreeAddMagma α → m (FreeAddMagma β)
  | FreeAddMagma.of x => FreeAddMagma.of <$> F x
  | x + y => (· + ·) <$> x.traverse <*> y.traverse
#align free_add_magma.traverse FreeAddMagma.traverse
-/

attribute [to_additive FreeAddMagma.traverse] FreeMagma.traverse

namespace FreeMagma

variable {α : Type u}

section Category

variable {β : Type u}

@[to_additive]
instance : Traversable FreeMagma :=
  ⟨@FreeMagma.traverse⟩

variable {m : Type u → Type u} [Applicative m] (F : α → m β)

#print FreeMagma.traverse_pure /-
@[simp, to_additive]
theorem traverse_pure (x) : traverse F (pure x : FreeMagma α) = pure <$> F x :=
  rfl
#align free_magma.traverse_pure FreeMagma.traverse_pure
#align free_add_magma.traverse_pure FreeAddMagma.traverse_pure
-/

#print FreeMagma.traverse_pure' /-
@[simp, to_additive]
theorem traverse_pure' : traverse F ∘ pure = fun x => (pure <$> F x : m (FreeMagma β)) :=
  rfl
#align free_magma.traverse_pure' FreeMagma.traverse_pure'
#align free_add_magma.traverse_pure' FreeAddMagma.traverse_pure'
-/

#print FreeMagma.traverse_mul /-
@[simp, to_additive]
theorem traverse_mul (x y : FreeMagma α) :
    traverse F (x * y) = (· * ·) <$> traverse F x <*> traverse F y :=
  rfl
#align free_magma.traverse_mul FreeMagma.traverse_mul
#align free_add_magma.traverse_add FreeAddMagma.traverse_add
-/

#print FreeMagma.traverse_mul' /-
@[simp, to_additive]
theorem traverse_mul' :
    Function.comp (traverse F) ∘ @Mul.mul (FreeMagma α) _ = fun x y =>
      (· * ·) <$> traverse F x <*> traverse F y :=
  rfl
#align free_magma.traverse_mul' FreeMagma.traverse_mul'
#align free_add_magma.traverse_add' FreeAddMagma.traverse_add'
-/

#print FreeMagma.traverse_eq /-
@[simp, to_additive]
theorem traverse_eq (x) : FreeMagma.traverse F x = traverse F x :=
  rfl
#align free_magma.traverse_eq FreeMagma.traverse_eq
#align free_add_magma.traverse_eq FreeAddMagma.traverse_eq
-/

#print FreeMagma.mul_map_seq /-
@[simp, to_additive]
theorem mul_map_seq (x y : FreeMagma α) :
    ((· * ·) <$> x <*> y : id (FreeMagma α)) = (x * y : FreeMagma α) :=
  rfl
#align free_magma.mul_map_seq FreeMagma.mul_map_seq
#align free_add_magma.add_map_seq FreeAddMagma.add_map_seq
-/

@[to_additive]
instance : IsLawfulTraversable FreeMagma.{u} :=
  {
    FreeMagma.lawfulMonad with
    id_traverse := fun α x =>
      FreeMagma.recOnPure x (fun x => rfl) fun x y ih1 ih2 => by
        rw [traverse_mul, ih1, ih2, mul_map_seq]
    comp_traverse := fun F G hf1 hg1 hf2 hg2 α β γ f g x =>
      FreeMagma.recOnPure x
        (fun x => by skip <;> simp only [traverse_pure, traverse_pure', functor_norm])
        fun x y ih1 ih2 => by
        skip <;> rw [traverse_mul, ih1, ih2, traverse_mul] <;>
          simp only [traverse_mul', functor_norm]
    naturality := fun F G hf1 hg1 hf2 hg2 η α β f x =>
      FreeMagma.recOnPure x (fun x => by simp only [traverse_pure, functor_norm]) fun x y ih1 ih2 =>
        by simp only [traverse_mul, functor_norm] <;> rw [ih1, ih2]
    traverse_eq_map_id := fun α β f x =>
      FreeMagma.recOnPure x (fun _ => rfl) fun x y ih1 ih2 => by
        rw [traverse_mul, ih1, ih2, map_mul', mul_map_seq] <;> rfl }

end Category

end FreeMagma

#print FreeMagma.repr /-
/-- Representation of an element of a free magma. -/
protected def FreeMagma.repr {α : Type u} [Repr α] : FreeMagma α → String
  | FreeMagma.of x => repr x
  | x * y => "( " ++ x.repr ++ " * " ++ y.repr ++ " )"
#align free_magma.repr FreeMagma.repr
-/

#print FreeAddMagma.repr /-
/-- Representation of an element of a free additive magma. -/
protected def FreeAddMagma.repr {α : Type u} [Repr α] : FreeAddMagma α → String
  | FreeAddMagma.of x => repr x
  | x + y => "( " ++ x.repr ++ " + " ++ y.repr ++ " )"
#align free_add_magma.repr FreeAddMagma.repr
-/

attribute [to_additive FreeAddMagma.repr] FreeMagma.repr

@[to_additive]
instance {α : Type u} [Repr α] : Repr (FreeMagma α) :=
  ⟨FreeMagma.repr⟩

#print FreeMagma.length /-
/-- Length of an element of a free magma. -/
@[simp]
def FreeMagma.length {α : Type u} : FreeMagma α → ℕ
  | FreeMagma.of x => 1
  | x * y => x.length + y.length
#align free_magma.length FreeMagma.length
-/

#print FreeAddMagma.length /-
/-- Length of an element of a free additive magma. -/
@[simp]
def FreeAddMagma.length {α : Type u} : FreeAddMagma α → ℕ
  | FreeAddMagma.of x => 1
  | x + y => x.length + y.length
#align free_add_magma.length FreeAddMagma.length
-/

attribute [to_additive FreeAddMagma.length] FreeMagma.length

#print AddMagma.AssocRel /-
/-- Associativity relations for an additive magma. -/
inductive AddMagma.AssocRel (α : Type u) [Add α] : α → α → Prop
  | intro : ∀ x y z, AddMagma.AssocRel (x + y + z) (x + (y + z))
  | left : ∀ w x y z, AddMagma.AssocRel (w + (x + y + z)) (w + (x + (y + z)))
#align add_magma.assoc_rel AddMagma.AssocRel
-/

#print Magma.AssocRel /-
/-- Associativity relations for a magma. -/
@[to_additive AddMagma.AssocRel "Associativity relations for an additive magma."]
inductive Magma.AssocRel (α : Type u) [Mul α] : α → α → Prop
  | intro : ∀ x y z, Magma.AssocRel (x * y * z) (x * (y * z))
  | left : ∀ w x y z, Magma.AssocRel (w * (x * y * z)) (w * (x * (y * z)))
#align magma.assoc_rel Magma.AssocRel
#align add_magma.assoc_rel AddMagma.AssocRel
-/

namespace Magma

#print Magma.AssocQuotient /-
/-- Semigroup quotient of a magma. -/
@[to_additive AddMagma.FreeAddSemigroup "Additive semigroup quotient of an additive magma."]
def AssocQuotient (α : Type u) [Mul α] : Type u :=
  Quot <| AssocRel α
#align magma.assoc_quotient Magma.AssocQuotient
#align add_magma.free_add_semigroup AddMagma.FreeAddSemigroup
-/

namespace AssocQuotient

variable {α : Type u} [Mul α]

#print Magma.AssocQuotient.quot_mk_assoc /-
@[to_additive]
theorem quot_mk_assoc (x y z : α) : Quot.mk (AssocRel α) (x * y * z) = Quot.mk _ (x * (y * z)) :=
  Quot.sound (AssocRel.intro _ _ _)
#align magma.assoc_quotient.quot_mk_assoc Magma.AssocQuotient.quot_mk_assoc
#align add_magma.free_add_semigroup.quot_mk_assoc AddMagma.FreeAddSemigroup.quot_mk_assoc
-/

#print Magma.AssocQuotient.quot_mk_assoc_left /-
@[to_additive]
theorem quot_mk_assoc_left (x y z w : α) :
    Quot.mk (AssocRel α) (x * (y * z * w)) = Quot.mk _ (x * (y * (z * w))) :=
  Quot.sound (AssocRel.left _ _ _ _)
#align magma.assoc_quotient.quot_mk_assoc_left Magma.AssocQuotient.quot_mk_assoc_left
#align add_magma.free_add_semigroup.quot_mk_assoc_left AddMagma.FreeAddSemigroup.quot_mk_assoc_left
-/

@[to_additive]
instance : Semigroup (AssocQuotient α)
    where
  mul x y := by
    refine' Quot.liftOn₂ x y (fun x y => Quot.mk _ (x * y)) _ _
    · rintro a b₁ b₂ (⟨c, d, e⟩ | ⟨c, d, e, f⟩) <;> simp only
      · exact quot_mk_assoc_left _ _ _ _
      · rw [← quot_mk_assoc, quot_mk_assoc_left, quot_mk_assoc]
    · rintro a₁ a₂ b (⟨c, d, e⟩ | ⟨c, d, e, f⟩) <;> simp only
      · simp only [quot_mk_assoc, quot_mk_assoc_left]
      ·
        rw [quot_mk_assoc, quot_mk_assoc, quot_mk_assoc_left, quot_mk_assoc_left,
          quot_mk_assoc_left, ← quot_mk_assoc c d, ← quot_mk_assoc c d, quot_mk_assoc_left]
  mul_assoc x y z := Quot.induction_on₃ x y z fun p q r => quot_mk_assoc p q r

#print Magma.AssocQuotient.of /-
/-- Embedding from magma to its free semigroup. -/
@[to_additive "Embedding from additive magma to its free additive semigroup."]
def of : α →ₙ* AssocQuotient α :=
  ⟨Quot.mk _, fun x y => rfl⟩
#align magma.assoc_quotient.of Magma.AssocQuotient.of
#align add_magma.free_add_semigroup.of AddMagma.FreeAddSemigroup.of
-/

@[to_additive]
instance [Inhabited α] : Inhabited (AssocQuotient α) :=
  ⟨of default⟩

#print Magma.AssocQuotient.induction_on /-
@[elab_as_elim, to_additive]
protected theorem induction_on {C : AssocQuotient α → Prop} (x : AssocQuotient α)
    (ih : ∀ x, C (of x)) : C x :=
  Quot.inductionOn x ih
#align magma.assoc_quotient.induction_on Magma.AssocQuotient.induction_on
#align add_magma.free_add_semigroup.induction_on AddMagma.FreeAddSemigroup.induction_on
-/

section lift

variable {β : Type v} [Semigroup β] (f : α →ₙ* β)

#print Magma.AssocQuotient.hom_ext /-
@[ext, to_additive]
theorem hom_ext {f g : AssocQuotient α →ₙ* β} (h : f.comp of = g.comp of) : f = g :=
  FunLike.ext _ _ fun x => AssocQuotient.induction_on x <| FunLike.congr_fun h
#align magma.assoc_quotient.hom_ext Magma.AssocQuotient.hom_ext
#align add_magma.free_add_semigroup.hom_ext AddMagma.FreeAddSemigroup.hom_ext
-/

#print Magma.AssocQuotient.lift /-
/-- Lifts a magma homomorphism `α → β` to a semigroup homomorphism `magma.assoc_quotient α → β`
given a semigroup `β`. -/
@[to_additive
      "Lifts an additive magma homomorphism `α → β` to an additive semigroup homomorphism\n`add_magma.assoc_quotient α → β` given an additive semigroup `β`.",
  simps symm_apply]
def lift : (α →ₙ* β) ≃ (AssocQuotient α →ₙ* β)
    where
  toFun f :=
    { toFun := fun x =>
        Quot.liftOn x f <| by
          rintro a b (⟨c, d, e⟩ | ⟨c, d, e, f⟩) <;> simp only [map_mul, mul_assoc]
      map_mul' := fun x y => Quot.induction_on₂ x y (map_mul f) }
  invFun f := f.comp of
  left_inv f := FunLike.ext _ _ fun x => rfl
  right_inv f := hom_ext <| FunLike.ext _ _ fun x => rfl
#align magma.assoc_quotient.lift Magma.AssocQuotient.lift
#align add_magma.free_add_semigroup.lift AddMagma.FreeAddSemigroup.lift
-/

#print Magma.AssocQuotient.lift_of /-
@[simp, to_additive]
theorem lift_of (x : α) : lift f (of x) = f x :=
  rfl
#align magma.assoc_quotient.lift_of Magma.AssocQuotient.lift_of
#align add_magma.free_add_semigroup.lift_of AddMagma.FreeAddSemigroup.lift_of
-/

#print Magma.AssocQuotient.lift_comp_of /-
@[simp, to_additive]
theorem lift_comp_of : (lift f).comp of = f :=
  lift.symm_apply_apply f
#align magma.assoc_quotient.lift_comp_of Magma.AssocQuotient.lift_comp_of
#align add_magma.free_add_semigroup.lift_comp_of AddMagma.FreeAddSemigroup.lift_comp_of
-/

#print Magma.AssocQuotient.lift_comp_of' /-
@[simp, to_additive]
theorem lift_comp_of' (f : AssocQuotient α →ₙ* β) : lift (f.comp of) = f :=
  lift.apply_symm_apply f
#align magma.assoc_quotient.lift_comp_of' Magma.AssocQuotient.lift_comp_of'
#align add_magma.free_add_semigroup.lift_comp_of' AddMagma.FreeAddSemigroup.lift_comp_of'
-/

end lift

variable {β : Type v} [Mul β] (f : α →ₙ* β)

#print Magma.AssocQuotient.map /-
/-- From a magma homomorphism `α →ₙ* β` to a semigroup homomorphism
`magma.assoc_quotient α →ₙ* magma.assoc_quotient β`. -/
@[to_additive
      "From an additive magma homomorphism `α → β` to an additive semigroup homomorphism\n`add_magma.assoc_quotient α → add_magma.assoc_quotient β`."]
def map : AssocQuotient α →ₙ* AssocQuotient β :=
  lift (of.comp f)
#align magma.assoc_quotient.map Magma.AssocQuotient.map
#align add_magma.free_add_semigroup.map AddMagma.FreeAddSemigroup.map
-/

#print Magma.AssocQuotient.map_of /-
@[simp, to_additive]
theorem map_of (x) : map f (of x) = of (f x) :=
  rfl
#align magma.assoc_quotient.map_of Magma.AssocQuotient.map_of
#align add_magma.free_add_semigroup.map_of AddMagma.FreeAddSemigroup.map_of
-/

end AssocQuotient

end Magma

#print FreeAddSemigroup /-
/-- Free additive semigroup over a given alphabet. -/
@[ext]
structure FreeAddSemigroup (α : Type u) where
  headI : α
  tail : List α
#align free_add_semigroup FreeAddSemigroup
-/

#print FreeSemigroup /-
/-- Free semigroup over a given alphabet. -/
@[ext, to_additive]
structure FreeSemigroup (α : Type u) where
  headI : α
  tail : List α
#align free_semigroup FreeSemigroup
#align free_add_semigroup FreeAddSemigroup
-/

namespace FreeSemigroup

variable {α : Type u}

@[to_additive]
instance : Semigroup (FreeSemigroup α)
    where
  mul L1 L2 := ⟨L1.1, L1.2 ++ L2.1 :: L2.2⟩
  mul_assoc L1 L2 L3 := ext _ _ rfl <| List.append_assoc _ _ _

#print FreeSemigroup.head_mul /-
@[simp, to_additive]
theorem head_mul (x y : FreeSemigroup α) : (x * y).1 = x.1 :=
  rfl
#align free_semigroup.head_mul FreeSemigroup.head_mul
#align free_add_semigroup.head_add FreeAddSemigroup.head_add
-/

#print FreeSemigroup.tail_mul /-
@[simp, to_additive]
theorem tail_mul (x y : FreeSemigroup α) : (x * y).2 = x.2 ++ y.1 :: y.2 :=
  rfl
#align free_semigroup.tail_mul FreeSemigroup.tail_mul
#align free_add_semigroup.tail_add FreeAddSemigroup.tail_add
-/

#print FreeSemigroup.mk_mul_mk /-
@[simp, to_additive]
theorem mk_mul_mk (x y : α) (L1 L2 : List α) : mk x L1 * mk y L2 = mk x (L1 ++ y :: L2) :=
  rfl
#align free_semigroup.mk_mul_mk FreeSemigroup.mk_mul_mk
#align free_add_semigroup.mk_add_mk FreeAddSemigroup.mk_add_mk
-/

#print FreeSemigroup.of /-
/-- The embedding `α → free_semigroup α`. -/
@[to_additive "The embedding `α → free_add_semigroup α`.", simps]
def of (x : α) : FreeSemigroup α :=
  ⟨x, []⟩
#align free_semigroup.of FreeSemigroup.of
#align free_add_semigroup.of FreeAddSemigroup.of
-/

#print FreeSemigroup.length /-
/-- Length of an element of free semigroup. -/
@[to_additive "Length of an element of free additive semigroup"]
def length (x : FreeSemigroup α) : ℕ :=
  x.tail.length + 1
#align free_semigroup.length FreeSemigroup.length
#align free_add_semigroup.length FreeAddSemigroup.length
-/

#print FreeSemigroup.length_mul /-
@[simp, to_additive]
theorem length_mul (x y : FreeSemigroup α) : (x * y).length = x.length + y.length := by
  simp [length, ← add_assoc, add_right_comm]
#align free_semigroup.length_mul FreeSemigroup.length_mul
#align free_add_semigroup.length_add FreeAddSemigroup.length_add
-/

#print FreeSemigroup.length_of /-
@[simp, to_additive]
theorem length_of (x : α) : (of x).length = 1 :=
  rfl
#align free_semigroup.length_of FreeSemigroup.length_of
#align free_add_semigroup.length_of FreeAddSemigroup.length_of
-/

@[to_additive]
instance [Inhabited α] : Inhabited (FreeSemigroup α) :=
  ⟨of default⟩

#print FreeSemigroup.recOnMul /-
/-- Recursor for free semigroup using `of` and `*`. -/
@[elab_as_elim, to_additive "Recursor for free additive semigroup using `of` and `+`."]
protected def recOnMul {C : FreeSemigroup α → Sort l} (x) (ih1 : ∀ x, C (of x))
    (ih2 : ∀ x y, C (of x) → C y → C (of x * y)) : C x :=
  FreeSemigroup.recOn x fun f s =>
    List.recOn s ih1 (fun hd tl ih f => ih2 f ⟨hd, tl⟩ (ih1 f) (ih hd)) f
#align free_semigroup.rec_on_mul FreeSemigroup.recOnMul
#align free_add_semigroup.rec_on_add FreeAddSemigroup.recOnAdd
-/

#print FreeSemigroup.hom_ext /-
@[ext, to_additive]
theorem hom_ext {β : Type v} [Mul β] {f g : FreeSemigroup α →ₙ* β} (h : f ∘ of = g ∘ of) : f = g :=
  FunLike.ext _ _ fun x =>
    FreeSemigroup.recOnMul x (congr_fun h) fun x y hx hy => by simp only [map_mul, *]
#align free_semigroup.hom_ext FreeSemigroup.hom_ext
#align free_add_semigroup.hom_ext FreeAddSemigroup.hom_ext
-/

section lift

variable {β : Type v} [Semigroup β] (f : α → β)

#print FreeSemigroup.lift /-
/-- Lifts a function `α → β` to a semigroup homomorphism `free_semigroup α → β` given
a semigroup `β`. -/
@[to_additive
      "Lifts a function `α → β` to an additive semigroup homomorphism\n`free_add_semigroup α → β` given an additive semigroup `β`.",
  simps symm_apply]
def lift : (α → β) ≃ (FreeSemigroup α →ₙ* β)
    where
  toFun f :=
    { toFun := fun x => x.2.foldl (fun a b => a * f b) (f x.1)
      map_mul' := fun x y => by
        simp only [head_mul, tail_mul, ← List.foldl_map f, List.foldl_append, List.foldl_cons,
          List.foldl_assoc] }
  invFun f := f ∘ of
  left_inv f := rfl
  right_inv f := hom_ext rfl
#align free_semigroup.lift FreeSemigroup.lift
#align free_add_semigroup.lift FreeAddSemigroup.lift
-/

#print FreeSemigroup.lift_of /-
@[simp, to_additive]
theorem lift_of (x : α) : lift f (of x) = f x :=
  rfl
#align free_semigroup.lift_of FreeSemigroup.lift_of
#align free_add_semigroup.lift_of FreeAddSemigroup.lift_of
-/

#print FreeSemigroup.lift_comp_of /-
@[simp, to_additive]
theorem lift_comp_of : lift f ∘ of = f :=
  rfl
#align free_semigroup.lift_comp_of FreeSemigroup.lift_comp_of
#align free_add_semigroup.lift_comp_of FreeAddSemigroup.lift_comp_of
-/

#print FreeSemigroup.lift_comp_of' /-
@[simp, to_additive]
theorem lift_comp_of' (f : FreeSemigroup α →ₙ* β) : lift (f ∘ of) = f :=
  hom_ext rfl
#align free_semigroup.lift_comp_of' FreeSemigroup.lift_comp_of'
#align free_add_semigroup.lift_comp_of' FreeAddSemigroup.lift_comp_of'
-/

#print FreeSemigroup.lift_of_mul /-
@[to_additive]
theorem lift_of_mul (x y) : lift f (of x * y) = f x * lift f y := by rw [map_mul, lift_of]
#align free_semigroup.lift_of_mul FreeSemigroup.lift_of_mul
#align free_add_semigroup.lift_of_add FreeAddSemigroup.lift_of_add
-/

end lift

section Map

variable {β : Type v} (f : α → β)

#print FreeSemigroup.map /-
/-- The unique semigroup homomorphism that sends `of x` to `of (f x)`. -/
@[to_additive "The unique additive semigroup homomorphism that sends `of x` to `of (f x)`."]
def map : FreeSemigroup α →ₙ* FreeSemigroup β :=
  lift <| of ∘ f
#align free_semigroup.map FreeSemigroup.map
#align free_add_semigroup.map FreeAddSemigroup.map
-/

#print FreeSemigroup.map_of /-
@[simp, to_additive]
theorem map_of (x) : map f (of x) = of (f x) :=
  rfl
#align free_semigroup.map_of FreeSemigroup.map_of
#align free_add_semigroup.map_of FreeAddSemigroup.map_of
-/

#print FreeSemigroup.length_map /-
@[simp, to_additive]
theorem length_map (x) : (map f x).length = x.length :=
  FreeSemigroup.recOnMul x (fun x => rfl) fun x y hx hy => by simp only [map_mul, length_mul, *]
#align free_semigroup.length_map FreeSemigroup.length_map
#align free_add_semigroup.length_map FreeAddSemigroup.length_map
-/

end Map

section Category

variable {β : Type u}

@[to_additive]
instance : Monad FreeSemigroup where
  pure _ := of
  bind _ _ x f := lift f x

#print FreeSemigroup.recOnPure /-
/-- Recursor that uses `pure` instead of `of`. -/
@[elab_as_elim, to_additive "Recursor that uses `pure` instead of `of`."]
def recOnPure {C : FreeSemigroup α → Sort l} (x) (ih1 : ∀ x, C (pure x))
    (ih2 : ∀ x y, C (pure x) → C y → C (pure x * y)) : C x :=
  FreeSemigroup.recOnMul x ih1 ih2
#align free_semigroup.rec_on_pure FreeSemigroup.recOnPure
#align free_add_semigroup.rec_on_pure FreeAddSemigroup.recOnPure
-/

#print FreeSemigroup.map_pure /-
@[simp, to_additive]
theorem map_pure (f : α → β) (x) : (f <$> pure x : FreeSemigroup β) = pure (f x) :=
  rfl
#align free_semigroup.map_pure FreeSemigroup.map_pure
#align free_add_semigroup.map_pure FreeAddSemigroup.map_pure
-/

#print FreeSemigroup.map_mul' /-
@[simp, to_additive]
theorem map_mul' (f : α → β) (x y : FreeSemigroup α) : f <$> (x * y) = f <$> x * f <$> y :=
  map_mul (map f) _ _
#align free_semigroup.map_mul' FreeSemigroup.map_mul'
#align free_add_semigroup.map_add' FreeAddSemigroup.map_add'
-/

#print FreeSemigroup.pure_bind /-
@[simp, to_additive]
theorem pure_bind (f : α → FreeSemigroup β) (x) : pure x >>= f = f x :=
  rfl
#align free_semigroup.pure_bind FreeSemigroup.pure_bind
#align free_add_semigroup.pure_bind FreeAddSemigroup.pure_bind
-/

#print FreeSemigroup.mul_bind /-
@[simp, to_additive]
theorem mul_bind (f : α → FreeSemigroup β) (x y : FreeSemigroup α) :
    x * y >>= f = (x >>= f) * (y >>= f) :=
  map_mul (lift f) _ _
#align free_semigroup.mul_bind FreeSemigroup.mul_bind
#align free_add_semigroup.add_bind FreeAddSemigroup.add_bind
-/

#print FreeSemigroup.pure_seq /-
@[simp, to_additive]
theorem pure_seq {f : α → β} {x : FreeSemigroup α} : pure f <*> x = f <$> x :=
  rfl
#align free_semigroup.pure_seq FreeSemigroup.pure_seq
#align free_add_semigroup.pure_seq FreeAddSemigroup.pure_seq
-/

#print FreeSemigroup.mul_seq /-
@[simp, to_additive]
theorem mul_seq {f g : FreeSemigroup (α → β)} {x : FreeSemigroup α} :
    f * g <*> x = (f <*> x) * (g <*> x) :=
  mul_bind _ _ _
#align free_semigroup.mul_seq FreeSemigroup.mul_seq
#align free_add_semigroup.add_seq FreeAddSemigroup.add_seq
-/

@[to_additive]
instance : LawfulMonad FreeSemigroup.{u}
    where
  pure_bind _ _ _ _ := rfl
  bind_assoc α β γ x f g :=
    recOnPure x (fun x => rfl) fun x y ih1 ih2 => by rw [mul_bind, mul_bind, mul_bind, ih1, ih2]
  id_map α x := recOnPure x (fun _ => rfl) fun x y ih1 ih2 => by rw [map_mul', ih1, ih2]

#print FreeSemigroup.traverse /-
/-- `free_semigroup` is traversable. -/
@[to_additive "`free_add_semigroup` is traversable."]
protected def traverse {m : Type u → Type u} [Applicative m] {α β : Type u} (F : α → m β)
    (x : FreeSemigroup α) : m (FreeSemigroup β) :=
  recOnPure x (fun x => pure <$> F x) fun x y ihx ihy => (· * ·) <$> ihx <*> ihy
#align free_semigroup.traverse FreeSemigroup.traverse
#align free_add_semigroup.traverse FreeAddSemigroup.traverse
-/

@[to_additive]
instance : Traversable FreeSemigroup :=
  ⟨@FreeSemigroup.traverse⟩

variable {m : Type u → Type u} [Applicative m] (F : α → m β)

#print FreeSemigroup.traverse_pure /-
@[simp, to_additive]
theorem traverse_pure (x) : traverse F (pure x : FreeSemigroup α) = pure <$> F x :=
  rfl
#align free_semigroup.traverse_pure FreeSemigroup.traverse_pure
#align free_add_semigroup.traverse_pure FreeAddSemigroup.traverse_pure
-/

#print FreeSemigroup.traverse_pure' /-
@[simp, to_additive]
theorem traverse_pure' : traverse F ∘ pure = fun x => (pure <$> F x : m (FreeSemigroup β)) :=
  rfl
#align free_semigroup.traverse_pure' FreeSemigroup.traverse_pure'
#align free_add_semigroup.traverse_pure' FreeAddSemigroup.traverse_pure'
-/

section

variable [LawfulApplicative m]

#print FreeSemigroup.traverse_mul /-
@[simp, to_additive]
theorem traverse_mul (x y : FreeSemigroup α) :
    traverse F (x * y) = (· * ·) <$> traverse F x <*> traverse F y :=
  let ⟨x, L1⟩ := x
  let ⟨y, L2⟩ := y
  List.recOn L1 (fun x => rfl)
    (fun hd tl ih x =>
      show
        (· * ·) <$> pure <$> F x <*> traverse F (mk hd tl * mk y L2) =
          (· * ·) <$> ((· * ·) <$> pure <$> F x <*> traverse F (mk hd tl)) <*> traverse F (mk y L2)
        by rw [ih] <;> simp only [(· ∘ ·), (mul_assoc _ _ _).symm, functor_norm])
    x
#align free_semigroup.traverse_mul FreeSemigroup.traverse_mul
#align free_add_semigroup.traverse_add FreeAddSemigroup.traverse_add
-/

#print FreeSemigroup.traverse_mul' /-
@[simp, to_additive]
theorem traverse_mul' :
    Function.comp (traverse F) ∘ @Mul.mul (FreeSemigroup α) _ = fun x y =>
      (· * ·) <$> traverse F x <*> traverse F y :=
  funext fun x => funext fun y => traverse_mul F x y
#align free_semigroup.traverse_mul' FreeSemigroup.traverse_mul'
#align free_add_semigroup.traverse_add' FreeAddSemigroup.traverse_add'
-/

end

#print FreeSemigroup.traverse_eq /-
@[simp, to_additive]
theorem traverse_eq (x) : FreeSemigroup.traverse F x = traverse F x :=
  rfl
#align free_semigroup.traverse_eq FreeSemigroup.traverse_eq
#align free_add_semigroup.traverse_eq FreeAddSemigroup.traverse_eq
-/

#print FreeSemigroup.mul_map_seq /-
@[simp, to_additive]
theorem mul_map_seq (x y : FreeSemigroup α) :
    ((· * ·) <$> x <*> y : id (FreeSemigroup α)) = (x * y : FreeSemigroup α) :=
  rfl
#align free_semigroup.mul_map_seq FreeSemigroup.mul_map_seq
#align free_add_semigroup.add_map_seq FreeAddSemigroup.add_map_seq
-/

@[to_additive]
instance : IsLawfulTraversable FreeSemigroup.{u} :=
  {
    FreeSemigroup.lawfulMonad with
    id_traverse := fun α x =>
      FreeSemigroup.recOnMul x (fun x => rfl) fun x y ih1 ih2 => by
        rw [traverse_mul, ih1, ih2, mul_map_seq]
    comp_traverse := fun F G hf1 hg1 hf2 hg2 α β γ f g x =>
      recOnPure x (fun x => by skip <;> simp only [traverse_pure, traverse_pure', functor_norm])
        fun x y ih1 ih2 => by
        skip <;> rw [traverse_mul, ih1, ih2, traverse_mul] <;>
          simp only [traverse_mul', functor_norm]
    naturality := fun F G hf1 hg1 hf2 hg2 η α β f x =>
      recOnPure x (fun x => by simp only [traverse_pure, functor_norm]) fun x y ih1 ih2 => by
        skip <;> simp only [traverse_mul, functor_norm] <;> rw [ih1, ih2]
    traverse_eq_map_id := fun α β f x =>
      FreeSemigroup.recOnMul x (fun _ => rfl) fun x y ih1 ih2 => by
        rw [traverse_mul, ih1, ih2, map_mul', mul_map_seq] <;> rfl }

end Category

@[to_additive]
instance [DecidableEq α] : DecidableEq (FreeSemigroup α) := fun x y =>
  decidable_of_iff' _ (ext_iff _ _)

end FreeSemigroup

namespace FreeMagma

variable {α : Type u} {β : Type v}

#print FreeMagma.toFreeSemigroup /-
/-- The canonical multiplicative morphism from `free_magma α` to `free_semigroup α`. -/
@[to_additive "The canonical additive morphism from `free_add_magma α` to `free_add_semigroup α`."]
def toFreeSemigroup : FreeMagma α →ₙ* FreeSemigroup α :=
  FreeMagma.lift FreeSemigroup.of
#align free_magma.to_free_semigroup FreeMagma.toFreeSemigroup
#align free_add_magma.to_free_add_semigroup FreeAddMagma.toFreeAddSemigroup
-/

#print FreeMagma.toFreeSemigroup_of /-
@[simp, to_additive]
theorem toFreeSemigroup_of (x : α) : toFreeSemigroup (of x) = FreeSemigroup.of x :=
  rfl
#align free_magma.to_free_semigroup_of FreeMagma.toFreeSemigroup_of
-/

#print FreeMagma.toFreeSemigroup_comp_of /-
@[simp, to_additive]
theorem toFreeSemigroup_comp_of : @toFreeSemigroup α ∘ of = FreeSemigroup.of :=
  rfl
#align free_magma.to_free_semigroup_comp_of FreeMagma.toFreeSemigroup_comp_of
-/

#print FreeMagma.toFreeSemigroup_comp_map /-
@[to_additive]
theorem toFreeSemigroup_comp_map (f : α → β) :
    toFreeSemigroup.comp (map f) = (FreeSemigroup.map f).comp toFreeSemigroup := by ext1; rfl
#align free_magma.to_free_semigroup_comp_map FreeMagma.toFreeSemigroup_comp_map
-/

#print FreeMagma.toFreeSemigroup_map /-
@[to_additive]
theorem toFreeSemigroup_map (f : α → β) (x : FreeMagma α) :
    (map f x).toFreeSemigroup = FreeSemigroup.map f x.toFreeSemigroup :=
  FunLike.congr_fun (toFreeSemigroup_comp_map f) x
#align free_magma.to_free_semigroup_map FreeMagma.toFreeSemigroup_map
-/

#print FreeMagma.length_toFreeSemigroup /-
@[simp, to_additive]
theorem length_toFreeSemigroup (x : FreeMagma α) : x.toFreeSemigroup.length = x.length :=
  FreeMagma.recOnMul x (fun x => rfl) fun x y hx hy => by
    rw [map_mul, FreeSemigroup.length_mul, length, hx, hy]
#align free_magma.length_to_free_semigroup FreeMagma.length_toFreeSemigroup
-/

end FreeMagma

#print FreeMagmaAssocQuotientEquiv /-
/-- Isomorphism between `magma.assoc_quotient (free_magma α)` and `free_semigroup α`. -/
@[to_additive
      "Isomorphism between\n`add_magma.assoc_quotient (free_add_magma α)` and `free_add_semigroup α`."]
def FreeMagmaAssocQuotientEquiv (α : Type u) :
    Magma.AssocQuotient (FreeMagma α) ≃* FreeSemigroup α :=
  (Magma.AssocQuotient.lift FreeMagma.toFreeSemigroup).toMulEquiv
    (FreeSemigroup.lift (Magma.AssocQuotient.of ∘ FreeMagma.of)) (by ext; rfl) (by ext1; rfl)
#align free_magma_assoc_quotient_equiv FreeMagmaAssocQuotientEquiv
-/

