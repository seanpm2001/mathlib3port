/-
Copyright (c) 2019 mathlib community. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro, Wojciech Nawrocki

! This file was ported from Lean 3 source module data.tree
! leanprover-community/mathlib commit bbeb185db4ccee8ed07dc48449414ebfa39cb821
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Rbtree.Init
import Mathbin.Data.Num.Basic

/-!
# Binary tree

Provides binary tree storage for values of any type, with O(lg n) retrieval.
See also `data.rbtree` for red-black trees - this version allows more operations
to be defined and is better suited for in-kernel computation.

## References

<https://leanprover-community.github.io/archive/stream/113488-general/topic/tactic.20question.html>
-/


/-- A binary tree with values stored in non-leaf nodes. -/
inductive Tree.{u} (α : Type u) : Type u
  | nil : Tree
  | node : α → Tree → Tree → Tree
  deriving has_reflect, DecidableEq
#align tree Tree

namespace Tree

universe u

variable {α : Type u}

/-- Construct a string representation of a tree. Provides a `has_repr` instance. -/
def repr [Repr α] : Tree α → String
  | nil => "nil"
  | node a t1 t2 => "tree.node " ++ Repr.repr a ++ " (" ++ repr t1 ++ ") (" ++ repr t2 ++ ")"
#align tree.repr Tree.repr

instance [Repr α] : Repr (Tree α) :=
  ⟨Tree.repr⟩

instance : Inhabited (Tree α) :=
  ⟨nil⟩

/-- Makes a `tree α` out of a red-black tree. -/
def ofRbnode : Rbnode α → Tree α
  | Rbnode.leaf => nil
  | Rbnode.red_node l a r => node a (of_rbnode l) (of_rbnode r)
  | Rbnode.black_node l a r => node a (of_rbnode l) (of_rbnode r)
#align tree.of_rbnode Tree.ofRbnode

/-- Finds the index of an element in the tree assuming the tree has been
constructed according to the provided decidable order on its elements.
If it hasn't, the result will be incorrect. If it has, but the element
is not in the tree, returns none. -/
def indexOf (lt : α → α → Prop) [DecidableRel lt] (x : α) : Tree α → Option PosNum
  | nil => none
  | node a t₁ t₂ =>
    match cmpUsing lt x a with
    | Ordering.lt => PosNum.bit0 <$> index_of t₁
    | Ordering.eq => some PosNum.one
    | Ordering.gt => PosNum.bit1 <$> index_of t₂
#align tree.index_of Tree.indexOf

/-- Retrieves an element uniquely determined by a `pos_num` from the tree,
taking the following path to get to the element:
- `bit0` - go to left child
- `bit1` - go to right child
- `pos_num.one` - retrieve from here -/
def get : PosNum → Tree α → Option α
  | _, nil => none
  | PosNum.one, node a t₁ t₂ => some a
  | PosNum.bit0 n, node a t₁ t₂ => t₁.get n
  | PosNum.bit1 n, node a t₁ t₂ => t₂.get n
#align tree.get Tree.get

/-- Retrieves an element from the tree, or the provided default value
if the index is invalid. See `tree.get`. -/
def getOrElse (n : PosNum) (t : Tree α) (v : α) : α :=
  (t.get n).getOrElse v
#align tree.get_or_else Tree.getOrElse

/- warning: tree.map -> Tree.map is a dubious translation:
lean 3 declaration is
  forall {α : Type.{u1}} {β : Type.{u2}}, (α -> β) -> (Tree.{u1} α) -> (Tree.{u2} β)
but is expected to have type
  forall {α : Type.{u2}} {β : Type.{u1}}, (α -> β) -> (Tree.{u2} α) -> (Tree.{u1} β)
Case conversion may be inaccurate. Consider using '#align tree.map Tree.mapₓ'. -/
/-- Apply a function to each value in the tree.  This is the `map` function for the `tree` functor.
TODO: implement `traversable tree`. -/
def map {β} (f : α → β) : Tree α → Tree β
  | nil => nil
  | node a l r => node (f a) (map l) (map r)
#align tree.map Tree.map

end Tree

