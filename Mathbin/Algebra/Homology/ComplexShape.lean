/-
Copyright (c) 2021 Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johan Commelin, Scott Morrison

! This file was ported from Lean 3 source module algebra.homology.complex_shape
! leanprover-community/mathlib commit 448144f7ae193a8990cb7473c9e9a01990f64ac7
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.Group.Defs
import Mathbin.Logic.Relation

/-!
# Shapes of homological complexes

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

We define a structure `complex_shape ι` for describing the shapes of homological complexes
indexed by a type `ι`.
This is intended to capture chain complexes and cochain complexes, indexed by either `ℕ` or `ℤ`,
as well as more exotic examples.

Rather than insisting that the indexing type has a `succ` function
specifying where differentials should go,
inside `c : complex_shape` we have `c.rel : ι → ι → Prop`,
and when we define `homological_complex`
we only allow nonzero differentials `d i j` from `i` to `j` if `c.rel i j`.
Further, we require that `{ j // c.rel i j }` and `{ i // c.rel i j }` are subsingletons.
This means that the shape consists of some union of lines, rays, intervals, and circles.

Convenience functions `c.next` and `c.prev` provide these related elements
when they exist, and return their input otherwise.

This design aims to avoid certain problems arising from dependent type theory.
In particular we never have to ensure morphisms `d i : X i ⟶ X (succ i)` compose as
expected (which would often require rewriting by equations in the indexing type).
Instead such identities become separate proof obligations when verifying that a
complex we've constructed is of the desired shape.

If `α` is an `add_right_cancel_semigroup`, then we define `up α : complex_shape α`,
the shape appropriate for cohomology,so `d : X i ⟶ X j` is nonzero only when `j = i + 1`,
as well as `down α : complex_shape α`, appropriate for homology,
so `d : X i ⟶ X j` is nonzero only when `i = j + 1`.
(Later we'll introduce `cochain_complex` and `chain_complex` as abbreviations for
`homological_complex` with one of these shapes baked in.)
-/


open scoped Classical

noncomputable section

#print ComplexShape /-
/-- A `c : complex_shape ι` describes the shape of a chain complex,
with chain groups indexed by `ι`.
Typically `ι` will be `ℕ`, `ℤ`, or `fin n`.

There is a relation `rel : ι → ι → Prop`,
and we will only allow a non-zero differential from `i` to `j` when `rel i j`.

There are axioms which imply `{ j // c.rel i j }` and `{ i // c.rel i j }` are subsingletons.
This means that the shape consists of some union of lines, rays, intervals, and circles.

Below we define `c.next` and `c.prev` which provide these related elements.
-/
@[ext, nolint has_nonempty_instance]
structure ComplexShape (ι : Type _) where
  Rel : ι → ι → Prop
  next_eq : ∀ {i j j'}, Rel i j → Rel i j' → j = j'
  prev_eq : ∀ {i i' j}, Rel i j → Rel i' j → i = i'
#align complex_shape ComplexShape
-/

namespace ComplexShape

variable {ι : Type _}

#print ComplexShape.refl /-
/-- The complex shape where only differentials from each `X.i` to itself are allowed.

This is mostly only useful so we can describe the relation of "related in `k` steps" below.
-/
@[simps]
def refl (ι : Type _) : ComplexShape ι
    where
  Rel i j := i = j
  next_eq i j j' w w' := w.symm.trans w'
  prev_eq i i' j w w' := w.trans w'.symm
#align complex_shape.refl ComplexShape.refl
-/

#print ComplexShape.symm /-
/-- The reverse of a `complex_shape`.
-/
@[simps]
def symm (c : ComplexShape ι) : ComplexShape ι
    where
  Rel i j := c.Rel j i
  next_eq i j j' w w' := c.prev_eq w w'
  prev_eq i i' j w w' := c.next_eq w w'
#align complex_shape.symm ComplexShape.symm
-/

#print ComplexShape.symm_symm /-
@[simp]
theorem symm_symm (c : ComplexShape ι) : c.symm.symm = c := by ext; simp
#align complex_shape.symm_symm ComplexShape.symm_symm
-/

#print ComplexShape.trans /-
/-- The "composition" of two `complex_shape`s.

We need this to define "related in k steps" later.
-/
@[simp]
def trans (c₁ c₂ : ComplexShape ι) : ComplexShape ι
    where
  Rel := Relation.Comp c₁.Rel c₂.Rel
  next_eq i j j' w w' := by
    obtain ⟨k, w₁, w₂⟩ := w
    obtain ⟨k', w₁', w₂'⟩ := w'
    rw [c₁.next_eq w₁ w₁'] at w₂ 
    exact c₂.next_eq w₂ w₂'
  prev_eq i i' j w w' := by
    obtain ⟨k, w₁, w₂⟩ := w
    obtain ⟨k', w₁', w₂'⟩ := w'
    rw [c₂.prev_eq w₂ w₂'] at w₁ 
    exact c₁.prev_eq w₁ w₁'
#align complex_shape.trans ComplexShape.trans
-/

#print ComplexShape.subsingleton_next /-
instance subsingleton_next (c : ComplexShape ι) (i : ι) : Subsingleton { j // c.Rel i j } :=
  by
  fconstructor
  rintro ⟨j, rij⟩ ⟨k, rik⟩
  congr
  exact c.next_eq rij rik
#align complex_shape.subsingleton_next ComplexShape.subsingleton_next
-/

#print ComplexShape.subsingleton_prev /-
instance subsingleton_prev (c : ComplexShape ι) (j : ι) : Subsingleton { i // c.Rel i j } :=
  by
  fconstructor
  rintro ⟨i, rik⟩ ⟨j, rjk⟩
  congr
  exact c.prev_eq rik rjk
#align complex_shape.subsingleton_prev ComplexShape.subsingleton_prev
-/

#print ComplexShape.next /-
/-- An arbitary choice of index `j` such that `rel i j`, if such exists.
Returns `i` otherwise.
-/
def next (c : ComplexShape ι) (i : ι) : ι :=
  if h : ∃ j, c.Rel i j then h.some else i
#align complex_shape.next ComplexShape.next
-/

#print ComplexShape.prev /-
/-- An arbitary choice of index `i` such that `rel i j`, if such exists.
Returns `j` otherwise.
-/
def prev (c : ComplexShape ι) (j : ι) : ι :=
  if h : ∃ i, c.Rel i j then h.some else j
#align complex_shape.prev ComplexShape.prev
-/

#print ComplexShape.next_eq' /-
theorem next_eq' (c : ComplexShape ι) {i j : ι} (h : c.Rel i j) : c.next i = j := by
  apply c.next_eq _ h; dsimp only [next]; rw [dif_pos]; exact Exists.choose_spec ⟨j, h⟩
#align complex_shape.next_eq' ComplexShape.next_eq'
-/

#print ComplexShape.prev_eq' /-
theorem prev_eq' (c : ComplexShape ι) {i j : ι} (h : c.Rel i j) : c.prev j = i := by
  apply c.prev_eq _ h; dsimp only [prev]; rw [dif_pos]; exact Exists.choose_spec ⟨i, h⟩
#align complex_shape.prev_eq' ComplexShape.prev_eq'
-/

#print ComplexShape.up' /-
/-- The `complex_shape` allowing differentials from `X i` to `X (i+a)`.
(For example when `a = 1`, a cohomology theory indexed by `ℕ` or `ℤ`)
-/
@[simps]
def up' {α : Type _} [AddRightCancelSemigroup α] (a : α) : ComplexShape α
    where
  Rel i j := i + a = j
  next_eq i j k hi hj := hi.symm.trans hj
  prev_eq i j k hi hj := add_right_cancel (hi.trans hj.symm)
#align complex_shape.up' ComplexShape.up'
-/

#print ComplexShape.down' /-
/-- The `complex_shape` allowing differentials from `X (j+a)` to `X j`.
(For example when `a = 1`, a homology theory indexed by `ℕ` or `ℤ`)
-/
@[simps]
def down' {α : Type _} [AddRightCancelSemigroup α] (a : α) : ComplexShape α
    where
  Rel i j := j + a = i
  next_eq i j k hi hj := add_right_cancel (hi.trans hj.symm)
  prev_eq i j k hi hj := hi.symm.trans hj
#align complex_shape.down' ComplexShape.down'
-/

#print ComplexShape.down'_mk /-
theorem down'_mk {α : Type _} [AddRightCancelSemigroup α] (a : α) (i j : α) (h : j + a = i) :
    (down' a).Rel i j :=
  h
#align complex_shape.down'_mk ComplexShape.down'_mk
-/

#print ComplexShape.up /-
/-- The `complex_shape` appropriate for cohomology, so `d : X i ⟶ X j` only when `j = i + 1`.
-/
@[simps]
def up (α : Type _) [AddRightCancelSemigroup α] [One α] : ComplexShape α :=
  up' 1
#align complex_shape.up ComplexShape.up
-/

#print ComplexShape.down /-
/-- The `complex_shape` appropriate for homology, so `d : X i ⟶ X j` only when `i = j + 1`.
-/
@[simps]
def down (α : Type _) [AddRightCancelSemigroup α] [One α] : ComplexShape α :=
  down' 1
#align complex_shape.down ComplexShape.down
-/

#print ComplexShape.down_mk /-
theorem down_mk {α : Type _} [AddRightCancelSemigroup α] [One α] (i j : α) (h : j + 1 = i) :
    (down α).Rel i j :=
  down'_mk (1 : α) i j h
#align complex_shape.down_mk ComplexShape.down_mk
-/

end ComplexShape

