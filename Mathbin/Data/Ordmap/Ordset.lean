/-
Copyright (c) 2017 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.ordmap.ordset
! leanprover-community/mathlib commit af471b9e3ce868f296626d33189b4ce730fa4c00
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Ordmap.Ordnode
import Mathbin.Algebra.Order.Ring.Defs
import Mathbin.Data.Nat.Dist
import Mathbin.Tactic.Linarith.Default

/-!
# Verification of the `ordnode α` datatype

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves the correctness of the operations in `data.ordmap.ordnode`.
The public facing version is the type `ordset α`, which is a wrapper around
`ordnode α` which includes the correctness invariant of the type, and it exposes
parallel operations like `insert` as functions on `ordset` that do the same
thing but bundle the correctness proofs. The advantage is that it is possible
to, for example, prove that the result of `find` on `insert` will actually find
the element, while `ordnode` cannot guarantee this if the input tree did not
satisfy the type invariants.

## Main definitions

* `ordset α`: A well formed set of values of type `α`

## Implementation notes

The majority of this file is actually in the `ordnode` namespace, because we first
have to prove the correctness of all the operations (and defining what correctness
means here is actually somewhat subtle). So all the actual `ordset` operations are
at the very end, once we have all the theorems.

An `ordnode α` is an inductive type which describes a tree which stores the `size` at
internal nodes. The correctness invariant of an `ordnode α` is:

* `ordnode.sized t`: All internal `size` fields must match the actual measured
  size of the tree. (This is not hard to satisfy.)
* `ordnode.balanced t`: Unless the tree has the form `()` or `((a) b)` or `(a (b))`
  (that is, nil or a single singleton subtree), the two subtrees must satisfy
  `size l ≤ δ * size r` and `size r ≤ δ * size l`, where `δ := 3` is a global
  parameter of the data structure (and this property must hold recursively at subtrees).
  This is why we say this is a "size balanced tree" data structure.
* `ordnode.bounded lo hi t`: The members of the tree must be in strictly increasing order,
  meaning that if `a` is in the left subtree and `b` is the root, then `a ≤ b` and
  `¬ (b ≤ a)`. We enforce this using `ordnode.bounded` which includes also a global
  upper and lower bound.

Because the `ordnode` file was ported from Haskell, the correctness invariants of some
of the functions have not been spelled out, and some theorems like
`ordnode.valid'.balance_l_aux` show very intricate assumptions on the sizes,
which may need to be revised if it turns out some operations violate these assumptions,
because there is a decent amount of slop in the actual data structure invariants, so the
theorem will go through with multiple choices of assumption.

**Note:** This file is incomplete, in the sense that the intent is to have verified
versions and lemmas about all the definitions in `ordnode.lean`, but at the moment only
a few operations are verified (the hard part should be out of the way, but still).
Contributors are encouraged to pick this up and finish the job, if it appeals to you.

## Tags

ordered map, ordered set, data structure, verified programming

-/


variable {α : Type _}

namespace Ordnode

/-! ### delta and ratio -/


#print Ordnode.not_le_delta /-
theorem not_le_delta {s} (H : 1 ≤ s) : ¬s ≤ delta * 0 :=
  not_le_of_gt H
#align ordnode.not_le_delta Ordnode.not_le_delta
-/

#print Ordnode.delta_lt_false /-
theorem delta_lt_false {a b : ℕ} (h₁ : delta * a < b) (h₂ : delta * b < a) : False :=
  not_le_of_lt (lt_trans ((mul_lt_mul_left (by decide)).2 h₁) h₂) <| by
    simpa [mul_assoc] using Nat.mul_le_mul_right a (by decide : 1 ≤ delta * delta)
#align ordnode.delta_lt_false Ordnode.delta_lt_false
-/

/-! ### `singleton` -/


/-! ### `size` and `empty` -/


#print Ordnode.realSize /-
/-- O(n). Computes the actual number of elements in the set, ignoring the cached `size` field. -/
def realSize : Ordnode α → ℕ
  | nil => 0
  | node _ l _ r => real_size l + real_size r + 1
#align ordnode.real_size Ordnode.realSize
-/

/-! ### `sized` -/


#print Ordnode.Sized /-
/-- The `sized` property asserts that all the `size` fields in nodes match the actual size of the
respective subtrees. -/
def Sized : Ordnode α → Prop
  | nil => True
  | node s l _ r => s = size l + size r + 1 ∧ sized l ∧ sized r
#align ordnode.sized Ordnode.Sized
-/

#print Ordnode.Sized.node' /-
theorem Sized.node' {l x r} (hl : @Sized α l) (hr : Sized r) : Sized (node' l x r) :=
  ⟨rfl, hl, hr⟩
#align ordnode.sized.node' Ordnode.Sized.node'
-/

#print Ordnode.Sized.eq_node' /-
theorem Sized.eq_node' {s l x r} (h : @Sized α (node s l x r)) : node s l x r = node' l x r := by
  rw [h.1] <;> rfl
#align ordnode.sized.eq_node' Ordnode.Sized.eq_node'
-/

#print Ordnode.Sized.size_eq /-
theorem Sized.size_eq {s l x r} (H : Sized (@node α s l x r)) :
    size (@node α s l x r) = size l + size r + 1 :=
  H.1
#align ordnode.sized.size_eq Ordnode.Sized.size_eq
-/

#print Ordnode.Sized.induction /-
@[elab_as_elim]
theorem Sized.induction {t} (hl : @Sized α t) {C : Ordnode α → Prop} (H0 : C nil)
    (H1 : ∀ l x r, C l → C r → C (node' l x r)) : C t :=
  by
  induction t; · exact H0
  rw [hl.eq_node']
  exact H1 _ _ _ (t_ih_l hl.2.1) (t_ih_r hl.2.2)
#align ordnode.sized.induction Ordnode.Sized.induction
-/

#print Ordnode.size_eq_realSize /-
theorem size_eq_realSize : ∀ {t : Ordnode α}, Sized t → size t = realSize t
  | nil, _ => rfl
  | node s l x r, ⟨h₁, h₂, h₃⟩ => by
    rw [size, h₁, size_eq_real_size h₂, size_eq_real_size h₃] <;> rfl
#align ordnode.size_eq_real_size Ordnode.size_eq_realSize
-/

#print Ordnode.Sized.size_eq_zero /-
@[simp]
theorem Sized.size_eq_zero {t : Ordnode α} (ht : Sized t) : size t = 0 ↔ t = nil := by
  cases t <;> [simp; simp [ht.1]]
#align ordnode.sized.size_eq_zero Ordnode.Sized.size_eq_zero
-/

#print Ordnode.Sized.pos /-
theorem Sized.pos {s l x r} (h : Sized (@node α s l x r)) : 0 < s := by
  rw [h.1] <;> apply Nat.le_add_left
#align ordnode.sized.pos Ordnode.Sized.pos
-/

/-! `dual` -/


#print Ordnode.dual_dual /-
theorem dual_dual : ∀ t : Ordnode α, dual (dual t) = t
  | nil => rfl
  | node s l x r => by rw [dual, dual, dual_dual, dual_dual]
#align ordnode.dual_dual Ordnode.dual_dual
-/

#print Ordnode.size_dual /-
@[simp]
theorem size_dual (t : Ordnode α) : size (dual t) = size t := by cases t <;> rfl
#align ordnode.size_dual Ordnode.size_dual
-/

/-! `balanced` -/


#print Ordnode.BalancedSz /-
/-- The `balanced_sz l r` asserts that a hypothetical tree with children of sizes `l` and `r` is
balanced: either `l ≤ δ * r` and `r ≤ δ * r`, or the tree is trivial with a singleton on one side
and nothing on the other. -/
def BalancedSz (l r : ℕ) : Prop :=
  l + r ≤ 1 ∨ l ≤ delta * r ∧ r ≤ delta * l
#align ordnode.balanced_sz Ordnode.BalancedSz
-/

#print Ordnode.BalancedSz.dec /-
instance BalancedSz.dec : DecidableRel BalancedSz := fun l r => Or.decidable
#align ordnode.balanced_sz.dec Ordnode.BalancedSz.dec
-/

#print Ordnode.Balanced /-
/-- The `balanced t` asserts that the tree `t` satisfies the balance invariants
(at every level). -/
def Balanced : Ordnode α → Prop
  | nil => True
  | node _ l _ r => BalancedSz (size l) (size r) ∧ Balanced l ∧ Balanced r
#align ordnode.balanced Ordnode.Balanced
-/

#print Ordnode.Balanced.dec /-
instance Balanced.dec : DecidablePred (@Balanced α)
  | t => by induction t <;> unfold Balanced <;> skip <;> infer_instance
#align ordnode.balanced.dec Ordnode.Balanced.dec
-/

#print Ordnode.BalancedSz.symm /-
theorem BalancedSz.symm {l r : ℕ} : BalancedSz l r → BalancedSz r l :=
  Or.imp (by rw [add_comm] <;> exact id) And.symm
#align ordnode.balanced_sz.symm Ordnode.BalancedSz.symm
-/

#print Ordnode.balancedSz_zero /-
theorem balancedSz_zero {l : ℕ} : BalancedSz l 0 ↔ l ≤ 1 := by
  simp (config := { contextual := true }) [balanced_sz]
#align ordnode.balanced_sz_zero Ordnode.balancedSz_zero
-/

#print Ordnode.balancedSz_up /-
theorem balancedSz_up {l r₁ r₂ : ℕ} (h₁ : r₁ ≤ r₂) (h₂ : l + r₂ ≤ 1 ∨ r₂ ≤ delta * l)
    (H : BalancedSz l r₁) : BalancedSz l r₂ :=
  by
  refine' or_iff_not_imp_left.2 fun h => _
  refine' ⟨_, h₂.resolve_left h⟩
  cases H
  · cases r₂
    · cases h (le_trans (Nat.add_le_add_left (Nat.zero_le _) _) H)
    · exact le_trans (le_trans (Nat.le_add_right _ _) H) (Nat.le_add_left 1 _)
  · exact le_trans H.1 (Nat.mul_le_mul_left _ h₁)
#align ordnode.balanced_sz_up Ordnode.balancedSz_up
-/

#print Ordnode.balancedSz_down /-
theorem balancedSz_down {l r₁ r₂ : ℕ} (h₁ : r₁ ≤ r₂) (h₂ : l + r₂ ≤ 1 ∨ l ≤ delta * r₁)
    (H : BalancedSz l r₂) : BalancedSz l r₁ :=
  have : l + r₂ ≤ 1 → BalancedSz l r₁ := fun H => Or.inl (le_trans (Nat.add_le_add_left h₁ _) H)
  Or.cases_on H this fun H => Or.cases_on h₂ this fun h₂ => Or.inr ⟨h₂, le_trans h₁ H.2⟩
#align ordnode.balanced_sz_down Ordnode.balancedSz_down
-/

#print Ordnode.Balanced.dual /-
theorem Balanced.dual : ∀ {t : Ordnode α}, Balanced t → Balanced (dual t)
  | nil, h => ⟨⟩
  | node s l x r, ⟨b, bl, br⟩ => ⟨by rw [size_dual, size_dual] <;> exact b.symm, br.dual, bl.dual⟩
#align ordnode.balanced.dual Ordnode.Balanced.dual
-/

/-! ### `rotate` and `balance` -/


#print Ordnode.node3L /-
/-- Build a tree from three nodes, left associated (ignores the invariants). -/
def node3L (l : Ordnode α) (x : α) (m : Ordnode α) (y : α) (r : Ordnode α) : Ordnode α :=
  node' (node' l x m) y r
#align ordnode.node3_l Ordnode.node3L
-/

#print Ordnode.node3R /-
/-- Build a tree from three nodes, right associated (ignores the invariants). -/
def node3R (l : Ordnode α) (x : α) (m : Ordnode α) (y : α) (r : Ordnode α) : Ordnode α :=
  node' l x (node' m y r)
#align ordnode.node3_r Ordnode.node3R
-/

#print Ordnode.node4L /-
/-- Build a tree from three nodes, with `a () b -> (a ()) b` and `a (b c) d -> ((a b) (c d))`. -/
def node4L : Ordnode α → α → Ordnode α → α → Ordnode α → Ordnode α
  | l, x, node _ ml y mr, z, r => node' (node' l x ml) y (node' mr z r)
  | l, x, nil, z, r => node3L l x nil z r
#align ordnode.node4_l Ordnode.node4L
-/

#print Ordnode.node4R /-
-- should not happen
/-- Build a tree from three nodes, with `a () b -> a (() b)` and `a (b c) d -> ((a b) (c d))`. -/
def node4R : Ordnode α → α → Ordnode α → α → Ordnode α → Ordnode α
  | l, x, node _ ml y mr, z, r => node' (node' l x ml) y (node' mr z r)
  | l, x, nil, z, r => node3R l x nil z r
#align ordnode.node4_r Ordnode.node4R
-/

#print Ordnode.rotateL /-
-- should not happen
/-- Concatenate two nodes, performing a left rotation `x (y z) -> ((x y) z)`
if balance is upset. -/
def rotateL : Ordnode α → α → Ordnode α → Ordnode α
  | l, x, node _ m y r => if size m < ratio * size r then node3L l x m y r else node4L l x m y r
  | l, x, nil => node' l x nil
#align ordnode.rotate_l Ordnode.rotateL
-/

#print Ordnode.rotateR /-
-- should not happen
/-- Concatenate two nodes, performing a right rotation `(x y) z -> (x (y z))`
if balance is upset. -/
def rotateR : Ordnode α → α → Ordnode α → Ordnode α
  | node _ l x m, y, r => if size m < ratio * size l then node3R l x m y r else node4R l x m y r
  | nil, y, r => node' nil y r
#align ordnode.rotate_r Ordnode.rotateR
-/

#print Ordnode.balanceL' /-
-- should not happen
/-- A left balance operation. This will rebalance a concatenation, assuming the original nodes are
not too far from balanced. -/
def balanceL' (l : Ordnode α) (x : α) (r : Ordnode α) : Ordnode α :=
  if size l + size r ≤ 1 then node' l x r
  else if size l > delta * size r then rotateR l x r else node' l x r
#align ordnode.balance_l' Ordnode.balanceL'
-/

#print Ordnode.balanceR' /-
/-- A right balance operation. This will rebalance a concatenation, assuming the original nodes are
not too far from balanced. -/
def balanceR' (l : Ordnode α) (x : α) (r : Ordnode α) : Ordnode α :=
  if size l + size r ≤ 1 then node' l x r
  else if size r > delta * size l then rotateL l x r else node' l x r
#align ordnode.balance_r' Ordnode.balanceR'
-/

#print Ordnode.balance' /-
/-- The full balance operation. This is the same as `balance`, but with less manual inlining.
It is somewhat easier to work with this version in proofs. -/
def balance' (l : Ordnode α) (x : α) (r : Ordnode α) : Ordnode α :=
  if size l + size r ≤ 1 then node' l x r
  else
    if size r > delta * size l then rotateL l x r
    else if size l > delta * size r then rotateR l x r else node' l x r
#align ordnode.balance' Ordnode.balance'
-/

#print Ordnode.dual_node' /-
theorem dual_node' (l : Ordnode α) (x : α) (r : Ordnode α) :
    dual (node' l x r) = node' (dual r) x (dual l) := by simp [node', add_comm]
#align ordnode.dual_node' Ordnode.dual_node'
-/

#print Ordnode.dual_node3L /-
theorem dual_node3L (l : Ordnode α) (x : α) (m : Ordnode α) (y : α) (r : Ordnode α) :
    dual (node3L l x m y r) = node3R (dual r) y (dual m) x (dual l) := by
  simp [node3_l, node3_r, dual_node']
#align ordnode.dual_node3_l Ordnode.dual_node3L
-/

#print Ordnode.dual_node3R /-
theorem dual_node3R (l : Ordnode α) (x : α) (m : Ordnode α) (y : α) (r : Ordnode α) :
    dual (node3R l x m y r) = node3L (dual r) y (dual m) x (dual l) := by
  simp [node3_l, node3_r, dual_node']
#align ordnode.dual_node3_r Ordnode.dual_node3R
-/

#print Ordnode.dual_node4L /-
theorem dual_node4L (l : Ordnode α) (x : α) (m : Ordnode α) (y : α) (r : Ordnode α) :
    dual (node4L l x m y r) = node4R (dual r) y (dual m) x (dual l) := by
  cases m <;> simp [node4_l, node4_r, dual_node3_l, dual_node']
#align ordnode.dual_node4_l Ordnode.dual_node4L
-/

#print Ordnode.dual_node4R /-
theorem dual_node4R (l : Ordnode α) (x : α) (m : Ordnode α) (y : α) (r : Ordnode α) :
    dual (node4R l x m y r) = node4L (dual r) y (dual m) x (dual l) := by
  cases m <;> simp [node4_l, node4_r, dual_node3_r, dual_node']
#align ordnode.dual_node4_r Ordnode.dual_node4R
-/

#print Ordnode.dual_rotateL /-
theorem dual_rotateL (l : Ordnode α) (x : α) (r : Ordnode α) :
    dual (rotateL l x r) = rotateR (dual r) x (dual l) := by
  cases r <;> simp [rotate_l, rotate_r, dual_node'] <;> split_ifs <;>
    simp [dual_node3_l, dual_node4_l]
#align ordnode.dual_rotate_l Ordnode.dual_rotateL
-/

#print Ordnode.dual_rotateR /-
theorem dual_rotateR (l : Ordnode α) (x : α) (r : Ordnode α) :
    dual (rotateR l x r) = rotateL (dual r) x (dual l) := by
  rw [← dual_dual (rotate_l _ _ _), dual_rotate_l, dual_dual, dual_dual]
#align ordnode.dual_rotate_r Ordnode.dual_rotateR
-/

#print Ordnode.dual_balance' /-
theorem dual_balance' (l : Ordnode α) (x : α) (r : Ordnode α) :
    dual (balance' l x r) = balance' (dual r) x (dual l) :=
  by
  simp [balance', add_comm]; split_ifs <;> simp [dual_node', dual_rotate_l, dual_rotate_r]
  cases delta_lt_false h_1 h_2
#align ordnode.dual_balance' Ordnode.dual_balance'
-/

#print Ordnode.dual_balanceL /-
theorem dual_balanceL (l : Ordnode α) (x : α) (r : Ordnode α) :
    dual (balanceL l x r) = balanceR (dual r) x (dual l) :=
  by
  unfold balance_l balance_r
  cases' r with rs rl rx rr
  · cases' l with ls ll lx lr; · rfl
    cases' ll with lls lll llx llr <;> cases' lr with lrs lrl lrx lrr <;> dsimp only [dual] <;>
      try rfl
    split_ifs <;> repeat' simp [h, add_comm]
  · cases' l with ls ll lx lr; · rfl
    dsimp only [dual]
    split_ifs; swap; · simp [add_comm]
    cases' ll with lls lll llx llr <;> cases' lr with lrs lrl lrx lrr <;> try rfl
    dsimp only [dual]
    split_ifs <;> simp [h, add_comm]
#align ordnode.dual_balance_l Ordnode.dual_balanceL
-/

#print Ordnode.dual_balanceR /-
theorem dual_balanceR (l : Ordnode α) (x : α) (r : Ordnode α) :
    dual (balanceR l x r) = balanceL (dual r) x (dual l) := by
  rw [← dual_dual (balance_l _ _ _), dual_balance_l, dual_dual, dual_dual]
#align ordnode.dual_balance_r Ordnode.dual_balanceR
-/

#print Ordnode.Sized.node3L /-
theorem Sized.node3L {l x m y r} (hl : @Sized α l) (hm : Sized m) (hr : Sized r) :
    Sized (node3L l x m y r) :=
  (hl.node' hm).node' hr
#align ordnode.sized.node3_l Ordnode.Sized.node3L
-/

#print Ordnode.Sized.node3R /-
theorem Sized.node3R {l x m y r} (hl : @Sized α l) (hm : Sized m) (hr : Sized r) :
    Sized (node3R l x m y r) :=
  hl.node' (hm.node' hr)
#align ordnode.sized.node3_r Ordnode.Sized.node3R
-/

#print Ordnode.Sized.node4L /-
theorem Sized.node4L {l x m y r} (hl : @Sized α l) (hm : Sized m) (hr : Sized r) :
    Sized (node4L l x m y r) := by
  cases m <;> [exact (hl.node' hm).node' hr; exact (hl.node' hm.2.1).node' (hm.2.2.node' hr)]
#align ordnode.sized.node4_l Ordnode.Sized.node4L
-/

#print Ordnode.node3L_size /-
theorem node3L_size {l x m y r} : size (@node3L α l x m y r) = size l + size m + size r + 2 := by
  dsimp [node3_l, node', size] <;> rw [add_right_comm _ 1]
#align ordnode.node3_l_size Ordnode.node3L_size
-/

#print Ordnode.node3R_size /-
theorem node3R_size {l x m y r} : size (@node3R α l x m y r) = size l + size m + size r + 2 := by
  dsimp [node3_r, node', size] <;> rw [← add_assoc, ← add_assoc]
#align ordnode.node3_r_size Ordnode.node3R_size
-/

#print Ordnode.node4L_size /-
theorem node4L_size {l x m y r} (hm : Sized m) :
    size (@node4L α l x m y r) = size l + size m + size r + 2 := by
  cases m <;> simp [node4_l, node3_l, node', add_comm, add_left_comm] <;> [skip;
        simp [size, hm.1]] <;>
      rw [← add_assoc, ← bit0] <;>
    simp [add_comm, add_left_comm]
#align ordnode.node4_l_size Ordnode.node4L_size
-/

#print Ordnode.Sized.dual /-
theorem Sized.dual : ∀ {t : Ordnode α} (h : Sized t), Sized (dual t)
  | nil, h => ⟨⟩
  | node s l x r, ⟨rfl, sl, sr⟩ => ⟨by simp [size_dual, add_comm], sized.dual sr, sized.dual sl⟩
#align ordnode.sized.dual Ordnode.Sized.dual
-/

#print Ordnode.Sized.dual_iff /-
theorem Sized.dual_iff {t : Ordnode α} : Sized (dual t) ↔ Sized t :=
  ⟨fun h => by rw [← dual_dual t] <;> exact h.dual, Sized.dual⟩
#align ordnode.sized.dual_iff Ordnode.Sized.dual_iff
-/

#print Ordnode.Sized.rotateL /-
theorem Sized.rotateL {l x r} (hl : @Sized α l) (hr : Sized r) : Sized (rotateL l x r) :=
  by
  cases r; · exact hl.node' hr
  rw [rotate_l]; split_ifs
  · exact hl.node3_l hr.2.1 hr.2.2
  · exact hl.node4_l hr.2.1 hr.2.2
#align ordnode.sized.rotate_l Ordnode.Sized.rotateL
-/

#print Ordnode.Sized.rotateR /-
theorem Sized.rotateR {l x r} (hl : @Sized α l) (hr : Sized r) : Sized (rotateR l x r) :=
  Sized.dual_iff.1 <| by rw [dual_rotate_r] <;> exact hr.dual.rotate_l hl.dual
#align ordnode.sized.rotate_r Ordnode.Sized.rotateR
-/

#print Ordnode.Sized.rotateL_size /-
theorem Sized.rotateL_size {l x r} (hm : Sized r) : size (@rotateL α l x r) = size l + size r + 1 :=
  by
  cases r <;> simp [rotate_l]
  simp [size, hm.1, add_comm, add_left_comm]; rw [← add_assoc, ← bit0]; simp
  split_ifs <;> simp [node3_l_size, node4_l_size hm.2.1, add_comm, add_left_comm]
#align ordnode.sized.rotate_l_size Ordnode.Sized.rotateL_size
-/

#print Ordnode.Sized.rotateR_size /-
theorem Sized.rotateR_size {l x r} (hl : Sized l) : size (@rotateR α l x r) = size l + size r + 1 :=
  by rw [← size_dual, dual_rotate_r, hl.dual.rotate_l_size, size_dual, size_dual, add_comm (size l)]
#align ordnode.sized.rotate_r_size Ordnode.Sized.rotateR_size
-/

#print Ordnode.Sized.balance' /-
theorem Sized.balance' {l x r} (hl : @Sized α l) (hr : Sized r) : Sized (balance' l x r) :=
  by
  unfold balance'; split_ifs
  · exact hl.node' hr
  · exact hl.rotate_l hr
  · exact hl.rotate_r hr
  · exact hl.node' hr
#align ordnode.sized.balance' Ordnode.Sized.balance'
-/

#print Ordnode.size_balance' /-
theorem size_balance' {l x r} (hl : @Sized α l) (hr : Sized r) :
    size (@balance' α l x r) = size l + size r + 1 :=
  by
  unfold balance'; split_ifs
  · rfl
  · exact hr.rotate_l_size
  · exact hl.rotate_r_size
  · rfl
#align ordnode.size_balance' Ordnode.size_balance'
-/

/-! ## `all`, `any`, `emem`, `amem` -/


#print Ordnode.All.imp /-
theorem All.imp {P Q : α → Prop} (H : ∀ a, P a → Q a) : ∀ {t}, All P t → All Q t
  | nil, h => ⟨⟩
  | node _ l x r, ⟨h₁, h₂, h₃⟩ => ⟨h₁.imp, H _ h₂, h₃.imp⟩
#align ordnode.all.imp Ordnode.All.imp
-/

#print Ordnode.Any.imp /-
theorem Any.imp {P Q : α → Prop} (H : ∀ a, P a → Q a) : ∀ {t}, Any P t → Any Q t
  | nil => id
  | node _ l x r => Or.imp any.imp <| Or.imp (H _) any.imp
#align ordnode.any.imp Ordnode.Any.imp
-/

#print Ordnode.all_singleton /-
theorem all_singleton {P : α → Prop} {x : α} : All P (singleton x) ↔ P x :=
  ⟨fun h => h.2.1, fun h => ⟨⟨⟩, h, ⟨⟩⟩⟩
#align ordnode.all_singleton Ordnode.all_singleton
-/

#print Ordnode.any_singleton /-
theorem any_singleton {P : α → Prop} {x : α} : Any P (singleton x) ↔ P x :=
  ⟨by rintro (⟨⟨⟩⟩ | h | ⟨⟨⟩⟩) <;> exact h, fun h => Or.inr (Or.inl h)⟩
#align ordnode.any_singleton Ordnode.any_singleton
-/

#print Ordnode.all_dual /-
theorem all_dual {P : α → Prop} : ∀ {t : Ordnode α}, All P (dual t) ↔ All P t
  | nil => Iff.rfl
  | node s l x r =>
    ⟨fun ⟨hr, hx, hl⟩ => ⟨all_dual.1 hl, hx, all_dual.1 hr⟩, fun ⟨hl, hx, hr⟩ =>
      ⟨all_dual.2 hr, hx, all_dual.2 hl⟩⟩
#align ordnode.all_dual Ordnode.all_dual
-/

#print Ordnode.all_iff_forall /-
theorem all_iff_forall {P : α → Prop} : ∀ {t}, All P t ↔ ∀ x, Emem x t → P x
  | nil => (iff_true_intro <| by rintro _ ⟨⟩).symm
  | node _ l x r => by simp [all, emem, all_iff_forall, any, or_imp, forall_and]
#align ordnode.all_iff_forall Ordnode.all_iff_forall
-/

#print Ordnode.any_iff_exists /-
theorem any_iff_exists {P : α → Prop} : ∀ {t}, Any P t ↔ ∃ x, Emem x t ∧ P x
  | nil => ⟨by rintro ⟨⟩, by rintro ⟨_, ⟨⟩, _⟩⟩
  | node _ l x r => by simp [any, emem, any_iff_exists, or_and_right, exists_or]
#align ordnode.any_iff_exists Ordnode.any_iff_exists
-/

#print Ordnode.emem_iff_all /-
theorem emem_iff_all {x : α} {t} : Emem x t ↔ ∀ P, All P t → P x :=
  ⟨fun h P al => all_iff_forall.1 al _ h, fun H => H _ <| all_iff_forall.2 fun _ => id⟩
#align ordnode.emem_iff_all Ordnode.emem_iff_all
-/

#print Ordnode.all_node' /-
theorem all_node' {P l x r} : @All α P (node' l x r) ↔ All P l ∧ P x ∧ All P r :=
  Iff.rfl
#align ordnode.all_node' Ordnode.all_node'
-/

#print Ordnode.all_node3L /-
theorem all_node3L {P l x m y r} :
    @All α P (node3L l x m y r) ↔ All P l ∧ P x ∧ All P m ∧ P y ∧ All P r := by
  simp [node3_l, all_node', and_assoc']
#align ordnode.all_node3_l Ordnode.all_node3L
-/

#print Ordnode.all_node3R /-
theorem all_node3R {P l x m y r} :
    @All α P (node3R l x m y r) ↔ All P l ∧ P x ∧ All P m ∧ P y ∧ All P r :=
  Iff.rfl
#align ordnode.all_node3_r Ordnode.all_node3R
-/

#print Ordnode.all_node4L /-
theorem all_node4L {P l x m y r} :
    @All α P (node4L l x m y r) ↔ All P l ∧ P x ∧ All P m ∧ P y ∧ All P r := by
  cases m <;> simp [node4_l, all_node', all, all_node3_l, and_assoc']
#align ordnode.all_node4_l Ordnode.all_node4L
-/

#print Ordnode.all_node4R /-
theorem all_node4R {P l x m y r} :
    @All α P (node4R l x m y r) ↔ All P l ∧ P x ∧ All P m ∧ P y ∧ All P r := by
  cases m <;> simp [node4_r, all_node', all, all_node3_r, and_assoc']
#align ordnode.all_node4_r Ordnode.all_node4R
-/

#print Ordnode.all_rotateL /-
theorem all_rotateL {P l x r} : @All α P (rotateL l x r) ↔ All P l ∧ P x ∧ All P r := by
  cases r <;> simp [rotate_l, all_node'] <;> split_ifs <;> simp [all_node3_l, all_node4_l, all]
#align ordnode.all_rotate_l Ordnode.all_rotateL
-/

#print Ordnode.all_rotateR /-
theorem all_rotateR {P l x r} : @All α P (rotateR l x r) ↔ All P l ∧ P x ∧ All P r := by
  rw [← all_dual, dual_rotate_r, all_rotate_l] <;> simp [all_dual, and_comm', and_left_comm]
#align ordnode.all_rotate_r Ordnode.all_rotateR
-/

#print Ordnode.all_balance' /-
theorem all_balance' {P l x r} : @All α P (balance' l x r) ↔ All P l ∧ P x ∧ All P r := by
  rw [balance'] <;> split_ifs <;> simp [all_node', all_rotate_l, all_rotate_r]
#align ordnode.all_balance' Ordnode.all_balance'
-/

/-! ### `to_list` -/


#print Ordnode.foldr_cons_eq_toList /-
theorem foldr_cons_eq_toList : ∀ (t : Ordnode α) (r : List α), t.foldr List.cons r = toList t ++ r
  | nil, r => rfl
  | node _ l x r, r' => by
    rw [foldr, foldr_cons_eq_to_list, foldr_cons_eq_to_list, ← List.cons_append, ←
        List.append_assoc, ← foldr_cons_eq_to_list] <;>
      rfl
#align ordnode.foldr_cons_eq_to_list Ordnode.foldr_cons_eq_toList
-/

#print Ordnode.toList_nil /-
@[simp]
theorem toList_nil : toList (@nil α) = [] :=
  rfl
#align ordnode.to_list_nil Ordnode.toList_nil
-/

#print Ordnode.toList_node /-
@[simp]
theorem toList_node (s l x r) : toList (@node α s l x r) = toList l ++ x :: toList r := by
  rw [to_list, foldr, foldr_cons_eq_to_list] <;> rfl
#align ordnode.to_list_node Ordnode.toList_node
-/

#print Ordnode.emem_iff_mem_toList /-
theorem emem_iff_mem_toList {x : α} {t} : Emem x t ↔ x ∈ toList t := by
  unfold emem <;> induction t <;> simp [any, *, or_assoc']
#align ordnode.emem_iff_mem_to_list Ordnode.emem_iff_mem_toList
-/

#print Ordnode.length_toList' /-
theorem length_toList' : ∀ t : Ordnode α, (toList t).length = t.realSize
  | nil => rfl
  | node _ l _ r => by
    rw [to_list_node, List.length_append, List.length_cons, length_to_list', length_to_list'] <;>
      rfl
#align ordnode.length_to_list' Ordnode.length_toList'
-/

#print Ordnode.length_toList /-
theorem length_toList {t : Ordnode α} (h : Sized t) : (toList t).length = t.size := by
  rw [length_to_list', size_eq_real_size h]
#align ordnode.length_to_list Ordnode.length_toList
-/

#print Ordnode.equiv_iff /-
theorem equiv_iff {t₁ t₂ : Ordnode α} (h₁ : Sized t₁) (h₂ : Sized t₂) :
    Equiv t₁ t₂ ↔ toList t₁ = toList t₂ :=
  and_iff_right_of_imp fun h => by rw [← length_to_list h₁, h, length_to_list h₂]
#align ordnode.equiv_iff Ordnode.equiv_iff
-/

/-! ### `mem` -/


#print Ordnode.pos_size_of_mem /-
theorem pos_size_of_mem [LE α] [@DecidableRel α (· ≤ ·)] {x : α} {t : Ordnode α} (h : Sized t)
    (h_mem : x ∈ t) : 0 < size t := by cases t; · contradiction; · simp [h.1]
#align ordnode.pos_size_of_mem Ordnode.pos_size_of_mem
-/

/-! ### `(find/erase/split)_(min/max)` -/


#print Ordnode.findMin'_dual /-
theorem findMin'_dual : ∀ (t) (x : α), findMin' (dual t) x = findMax' x t
  | nil, x => rfl
  | node _ l x r, _ => find_min'_dual r x
#align ordnode.find_min'_dual Ordnode.findMin'_dual
-/

#print Ordnode.findMax'_dual /-
theorem findMax'_dual (t) (x : α) : findMax' x (dual t) = findMin' t x := by
  rw [← find_min'_dual, dual_dual]
#align ordnode.find_max'_dual Ordnode.findMax'_dual
-/

#print Ordnode.findMin_dual /-
theorem findMin_dual : ∀ t : Ordnode α, findMin (dual t) = findMax t
  | nil => rfl
  | node _ l x r => congr_arg some <| findMin'_dual _ _
#align ordnode.find_min_dual Ordnode.findMin_dual
-/

#print Ordnode.findMax_dual /-
theorem findMax_dual (t : Ordnode α) : findMax (dual t) = findMin t := by
  rw [← find_min_dual, dual_dual]
#align ordnode.find_max_dual Ordnode.findMax_dual
-/

#print Ordnode.dual_eraseMin /-
theorem dual_eraseMin : ∀ t : Ordnode α, dual (eraseMin t) = eraseMax (dual t)
  | nil => rfl
  | node _ nil x r => rfl
  | node _ (l@(node _ _ _ _)) x r => by
    rw [erase_min, dual_balance_r, dual_erase_min, dual, dual, dual, erase_max]
#align ordnode.dual_erase_min Ordnode.dual_eraseMin
-/

#print Ordnode.dual_eraseMax /-
theorem dual_eraseMax (t : Ordnode α) : dual (eraseMax t) = eraseMin (dual t) := by
  rw [← dual_dual (erase_min _), dual_erase_min, dual_dual]
#align ordnode.dual_erase_max Ordnode.dual_eraseMax
-/

#print Ordnode.splitMin_eq /-
theorem splitMin_eq : ∀ (s l) (x : α) (r), splitMin' l x r = (findMin' l x, eraseMin (node s l x r))
  | _, nil, x, r => rfl
  | _, node ls ll lx lr, x, r => by rw [split_min', split_min_eq, split_min', find_min', erase_min]
#align ordnode.split_min_eq Ordnode.splitMin_eq
-/

#print Ordnode.splitMax_eq /-
theorem splitMax_eq : ∀ (s l) (x : α) (r), splitMax' l x r = (eraseMax (node s l x r), findMax' x r)
  | _, l, x, nil => rfl
  | _, l, x, node ls ll lx lr => by rw [split_max', split_max_eq, split_max', find_max', erase_max]
#align ordnode.split_max_eq Ordnode.splitMax_eq
-/

#print Ordnode.findMin'_all /-
@[elab_as_elim]
theorem findMin'_all {P : α → Prop} : ∀ (t) (x : α), All P t → P x → P (findMin' t x)
  | nil, x, h, hx => hx
  | node _ ll lx lr, x, ⟨h₁, h₂, h₃⟩, hx => find_min'_all _ _ h₁ h₂
#align ordnode.find_min'_all Ordnode.findMin'_all
-/

#print Ordnode.findMax'_all /-
@[elab_as_elim]
theorem findMax'_all {P : α → Prop} : ∀ (x : α) (t), P x → All P t → P (findMax' x t)
  | x, nil, hx, h => hx
  | x, node _ ll lx lr, hx, ⟨h₁, h₂, h₃⟩ => find_max'_all _ _ h₂ h₃
#align ordnode.find_max'_all Ordnode.findMax'_all
-/

/-! ### `glue` -/


/-! ### `merge` -/


#print Ordnode.merge_nil_left /-
@[simp]
theorem merge_nil_left (t : Ordnode α) : merge t nil = t := by cases t <;> rfl
#align ordnode.merge_nil_left Ordnode.merge_nil_left
-/

#print Ordnode.merge_nil_right /-
@[simp]
theorem merge_nil_right (t : Ordnode α) : merge nil t = t :=
  rfl
#align ordnode.merge_nil_right Ordnode.merge_nil_right
-/

#print Ordnode.merge_node /-
@[simp]
theorem merge_node {ls ll lx lr rs rl rx rr} :
    merge (@node α ls ll lx lr) (node rs rl rx rr) =
      if delta * ls < rs then balanceL (merge (node ls ll lx lr) rl) rx rr
      else
        if delta * rs < ls then balanceR ll lx (merge lr (node rs rl rx rr))
        else glue (node ls ll lx lr) (node rs rl rx rr) :=
  rfl
#align ordnode.merge_node Ordnode.merge_node
-/

/-! ### `insert` -/


#print Ordnode.dual_insert /-
theorem dual_insert [Preorder α] [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (x : α) :
    ∀ t : Ordnode α, dual (Ordnode.insert x t) = @Ordnode.insert αᵒᵈ _ _ x (dual t)
  | nil => rfl
  | node _ l y r => by
    have : @cmpLE αᵒᵈ _ _ x y = cmpLE y x := rfl
    rw [Ordnode.insert, dual, Ordnode.insert, this, ← cmpLE_swap x y]
    cases cmpLE x y <;>
      simp [Ordering.swap, Ordnode.insert, dual_balance_l, dual_balance_r, dual_insert]
#align ordnode.dual_insert Ordnode.dual_insert
-/

/-! ### `balance` properties -/


#print Ordnode.balance_eq_balance' /-
theorem balance_eq_balance' {l x r} (hl : Balanced l) (hr : Balanced r) (sl : Sized l)
    (sr : Sized r) : @balance α l x r = balance' l x r :=
  by
  cases' l with ls ll lx lr
  · cases' r with rs rl rx rr
    · rfl
    · rw [sr.eq_node'] at hr ⊢
      cases' rl with rls rll rlx rlr <;> cases' rr with rrs rrl rrx rrr <;>
        dsimp [balance, balance']
      · rfl
      · have : size rrl = 0 ∧ size rrr = 0 :=
          by
          have := balanced_sz_zero.1 hr.1.symm
          rwa [size, sr.2.2.1, Nat.succ_le_succ_iff, le_zero_iff, add_eq_zero_iff] at this 
        cases sr.2.2.2.1.size_eq_zero.1 this.1
        cases sr.2.2.2.2.size_eq_zero.1 this.2
        obtain rfl : rrs = 1 := sr.2.2.1
        rw [if_neg, if_pos, rotate_l, if_pos]; · rfl
        all_goals exact by decide
      · have : size rll = 0 ∧ size rlr = 0 :=
          by
          have := balanced_sz_zero.1 hr.1
          rwa [size, sr.2.1.1, Nat.succ_le_succ_iff, le_zero_iff, add_eq_zero_iff] at this 
        cases sr.2.1.2.1.size_eq_zero.1 this.1
        cases sr.2.1.2.2.size_eq_zero.1 this.2
        obtain rfl : rls = 1 := sr.2.1.1
        rw [if_neg, if_pos, rotate_l, if_neg]; · rfl
        all_goals exact by decide
      · symm; rw [zero_add, if_neg, if_pos, rotate_l]
        · split_ifs
          · simp [node3_l, node', add_comm, add_left_comm]
          · simp [node4_l, node', sr.2.1.1, add_comm, add_left_comm]
        · exact by decide
        · exact not_le_of_gt (Nat.succ_lt_succ (add_pos sr.2.1.Pos sr.2.2.Pos))
  · cases' r with rs rl rx rr
    · rw [sl.eq_node'] at hl ⊢
      cases' ll with lls lll llx llr <;> cases' lr with lrs lrl lrx lrr <;>
        dsimp [balance, balance']
      · rfl
      · have : size lrl = 0 ∧ size lrr = 0 :=
          by
          have := balanced_sz_zero.1 hl.1.symm
          rwa [size, sl.2.2.1, Nat.succ_le_succ_iff, le_zero_iff, add_eq_zero_iff] at this 
        cases sl.2.2.2.1.size_eq_zero.1 this.1
        cases sl.2.2.2.2.size_eq_zero.1 this.2
        obtain rfl : lrs = 1 := sl.2.2.1
        rw [if_neg, if_neg, if_pos, rotate_r, if_neg]; · rfl
        all_goals exact by decide
      · have : size lll = 0 ∧ size llr = 0 :=
          by
          have := balanced_sz_zero.1 hl.1
          rwa [size, sl.2.1.1, Nat.succ_le_succ_iff, le_zero_iff, add_eq_zero_iff] at this 
        cases sl.2.1.2.1.size_eq_zero.1 this.1
        cases sl.2.1.2.2.size_eq_zero.1 this.2
        obtain rfl : lls = 1 := sl.2.1.1
        rw [if_neg, if_neg, if_pos, rotate_r, if_pos]; · rfl
        all_goals exact by decide
      · symm; rw [if_neg, if_neg, if_pos, rotate_r]
        · split_ifs
          · simp [node3_r, node', add_comm, add_left_comm]
          · simp [node4_r, node', sl.2.2.1, add_comm, add_left_comm]
        · exact by decide
        · exact by decide
        · exact not_le_of_gt (Nat.succ_lt_succ (add_pos sl.2.1.Pos sl.2.2.Pos))
    · simp [balance, balance']
      symm; rw [if_neg]
      · split_ifs
        · have rd : delta ≤ size rl + size rr :=
            by
            have := lt_of_le_of_lt (Nat.mul_le_mul_left _ sl.pos) h
            rwa [sr.1, Nat.lt_succ_iff] at this 
          cases' rl with rls rll rlx rlr
          · rw [size, zero_add] at rd 
            exact absurd (le_trans rd (balanced_sz_zero.1 hr.1.symm)) (by decide)
          cases' rr with rrs rrl rrx rrr
          · exact absurd (le_trans rd (balanced_sz_zero.1 hr.1)) (by decide)
          dsimp [rotate_l]; split_ifs
          · simp [node3_l, node', sr.1, add_comm, add_left_comm]
          · simp [node4_l, node', sr.1, sr.2.1.1, add_comm, add_left_comm]
        · have ld : delta ≤ size ll + size lr :=
            by
            have := lt_of_le_of_lt (Nat.mul_le_mul_left _ sr.pos) h_1
            rwa [sl.1, Nat.lt_succ_iff] at this 
          cases' ll with lls lll llx llr
          · rw [size, zero_add] at ld 
            exact absurd (le_trans ld (balanced_sz_zero.1 hl.1.symm)) (by decide)
          cases' lr with lrs lrl lrx lrr
          · exact absurd (le_trans ld (balanced_sz_zero.1 hl.1)) (by decide)
          dsimp [rotate_r]; split_ifs
          · simp [node3_r, node', sl.1, add_comm, add_left_comm]
          · simp [node4_r, node', sl.1, sl.2.2.1, add_comm, add_left_comm]
        · simp [node']
      · exact not_le_of_gt (add_le_add sl.pos sr.pos : 2 ≤ ls + rs)
#align ordnode.balance_eq_balance' Ordnode.balance_eq_balance'
-/

#print Ordnode.balanceL_eq_balance /-
theorem balanceL_eq_balance {l x r} (sl : Sized l) (sr : Sized r) (H1 : size l = 0 → size r ≤ 1)
    (H2 : 1 ≤ size l → 1 ≤ size r → size r ≤ delta * size l) : @balanceL α l x r = balance l x r :=
  by
  cases' r with rs rl rx rr
  · rfl
  · cases' l with ls ll lx lr
    · have : size rl = 0 ∧ size rr = 0 := by
        have := H1 rfl
        rwa [size, sr.1, Nat.succ_le_succ_iff, le_zero_iff, add_eq_zero_iff] at this 
      cases sr.2.1.size_eq_zero.1 this.1
      cases sr.2.2.size_eq_zero.1 this.2
      rw [sr.eq_node']; rfl
    · replace H2 : ¬rs > delta * ls := not_lt_of_le (H2 sl.pos sr.pos)
      simp [balance_l, balance, H2] <;> split_ifs <;> simp [add_comm]
#align ordnode.balance_l_eq_balance Ordnode.balanceL_eq_balance
-/

#print Ordnode.Raised /-
/-- `raised n m` means `m` is either equal or one up from `n`. -/
def Raised (n m : ℕ) : Prop :=
  m = n ∨ m = n + 1
#align ordnode.raised Ordnode.Raised
-/

#print Ordnode.raised_iff /-
theorem raised_iff {n m} : Raised n m ↔ n ≤ m ∧ m ≤ n + 1 :=
  by
  constructor; rintro (rfl | rfl)
  · exact ⟨le_rfl, Nat.le_succ _⟩
  · exact ⟨Nat.le_succ _, le_rfl⟩
  · rintro ⟨h₁, h₂⟩
    rcases eq_or_lt_of_le h₁ with (rfl | h₁)
    · exact Or.inl rfl
    · exact Or.inr (le_antisymm h₂ h₁)
#align ordnode.raised_iff Ordnode.raised_iff
-/

#print Ordnode.Raised.dist_le /-
theorem Raised.dist_le {n m} (H : Raised n m) : Nat.dist n m ≤ 1 := by
  cases' raised_iff.1 H with H1 H2 <;> rwa [Nat.dist_eq_sub_of_le H1, tsub_le_iff_left]
#align ordnode.raised.dist_le Ordnode.Raised.dist_le
-/

#print Ordnode.Raised.dist_le' /-
theorem Raised.dist_le' {n m} (H : Raised n m) : Nat.dist m n ≤ 1 := by
  rw [Nat.dist_comm] <;> exact H.dist_le
#align ordnode.raised.dist_le' Ordnode.Raised.dist_le'
-/

#print Ordnode.Raised.add_left /-
theorem Raised.add_left (k) {n m} (H : Raised n m) : Raised (k + n) (k + m) :=
  by
  rcases H with (rfl | rfl)
  · exact Or.inl rfl
  · exact Or.inr rfl
#align ordnode.raised.add_left Ordnode.Raised.add_left
-/

#print Ordnode.Raised.add_right /-
theorem Raised.add_right (k) {n m} (H : Raised n m) : Raised (n + k) (m + k) := by
  rw [add_comm, add_comm m] <;> exact H.add_left _
#align ordnode.raised.add_right Ordnode.Raised.add_right
-/

#print Ordnode.Raised.right /-
theorem Raised.right {l x₁ x₂ r₁ r₂} (H : Raised (size r₁) (size r₂)) :
    Raised (size (@node' α l x₁ r₁)) (size (@node' α l x₂ r₂)) :=
  by
  dsimp [node', size]; generalize size r₂ = m at H ⊢
  rcases H with (rfl | rfl)
  · exact Or.inl rfl
  · exact Or.inr rfl
#align ordnode.raised.right Ordnode.Raised.right
-/

#print Ordnode.balanceL_eq_balance' /-
theorem balanceL_eq_balance' {l x r} (hl : Balanced l) (hr : Balanced r) (sl : Sized l)
    (sr : Sized r)
    (H :
      (∃ l', Raised l' (size l) ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised (size r) r' ∧ BalancedSz (size l) r') :
    @balanceL α l x r = balance' l x r :=
  by
  rw [← balance_eq_balance' hl hr sl sr, balance_l_eq_balance sl sr]
  · intro l0; rw [l0] at H 
    rcases H with (⟨_, ⟨⟨⟩⟩ | ⟨⟨⟩⟩, H⟩ | ⟨r', e, H⟩)
    · exact balanced_sz_zero.1 H.symm
    exact le_trans (raised_iff.1 e).1 (balanced_sz_zero.1 H.symm)
  · intro l1 r1
    rcases H with (⟨l', e, H | ⟨H₁, H₂⟩⟩ | ⟨r', e, H | ⟨H₁, H₂⟩⟩)
    · exact le_trans (le_trans (Nat.le_add_left _ _) H) (mul_pos (by decide) l1 : (0 : ℕ) < _)
    · exact le_trans H₂ (Nat.mul_le_mul_left _ (raised_iff.1 e).1)
    · cases raised_iff.1 e; unfold delta; linarith
    · exact le_trans (raised_iff.1 e).1 H₂
#align ordnode.balance_l_eq_balance' Ordnode.balanceL_eq_balance'
-/

#print Ordnode.balance_sz_dual /-
theorem balance_sz_dual {l r}
    (H :
      (∃ l', Raised (@size α l) l' ∧ BalancedSz l' (@size α r)) ∨
        ∃ r', Raised r' (size r) ∧ BalancedSz (size l) r') :
    (∃ l', Raised l' (size (dual r)) ∧ BalancedSz l' (size (dual l))) ∨
      ∃ r', Raised (size (dual l)) r' ∧ BalancedSz (size (dual r)) r' :=
  by
  rw [size_dual, size_dual]
  exact
    H.symm.imp (Exists.imp fun _ => And.imp_right balanced_sz.symm)
      (Exists.imp fun _ => And.imp_right balanced_sz.symm)
#align ordnode.balance_sz_dual Ordnode.balance_sz_dual
-/

#print Ordnode.size_balanceL /-
theorem size_balanceL {l x r} (hl : Balanced l) (hr : Balanced r) (sl : Sized l) (sr : Sized r)
    (H :
      (∃ l', Raised l' (size l) ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised (size r) r' ∧ BalancedSz (size l) r') :
    size (@balanceL α l x r) = size l + size r + 1 := by
  rw [balance_l_eq_balance' hl hr sl sr H, size_balance' sl sr]
#align ordnode.size_balance_l Ordnode.size_balanceL
-/

#print Ordnode.all_balanceL /-
theorem all_balanceL {P l x r} (hl : Balanced l) (hr : Balanced r) (sl : Sized l) (sr : Sized r)
    (H :
      (∃ l', Raised l' (size l) ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised (size r) r' ∧ BalancedSz (size l) r') :
    All P (@balanceL α l x r) ↔ All P l ∧ P x ∧ All P r := by
  rw [balance_l_eq_balance' hl hr sl sr H, all_balance']
#align ordnode.all_balance_l Ordnode.all_balanceL
-/

#print Ordnode.balanceR_eq_balance' /-
theorem balanceR_eq_balance' {l x r} (hl : Balanced l) (hr : Balanced r) (sl : Sized l)
    (sr : Sized r)
    (H :
      (∃ l', Raised (size l) l' ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised r' (size r) ∧ BalancedSz (size l) r') :
    @balanceR α l x r = balance' l x r := by
  rw [← dual_dual (balance_r l x r), dual_balance_r,
    balance_l_eq_balance' hr.dual hl.dual sr.dual sl.dual (balance_sz_dual H), ← dual_balance',
    dual_dual]
#align ordnode.balance_r_eq_balance' Ordnode.balanceR_eq_balance'
-/

#print Ordnode.size_balanceR /-
theorem size_balanceR {l x r} (hl : Balanced l) (hr : Balanced r) (sl : Sized l) (sr : Sized r)
    (H :
      (∃ l', Raised (size l) l' ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised r' (size r) ∧ BalancedSz (size l) r') :
    size (@balanceR α l x r) = size l + size r + 1 := by
  rw [balance_r_eq_balance' hl hr sl sr H, size_balance' sl sr]
#align ordnode.size_balance_r Ordnode.size_balanceR
-/

#print Ordnode.all_balanceR /-
theorem all_balanceR {P l x r} (hl : Balanced l) (hr : Balanced r) (sl : Sized l) (sr : Sized r)
    (H :
      (∃ l', Raised (size l) l' ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised r' (size r) ∧ BalancedSz (size l) r') :
    All P (@balanceR α l x r) ↔ All P l ∧ P x ∧ All P r := by
  rw [balance_r_eq_balance' hl hr sl sr H, all_balance']
#align ordnode.all_balance_r Ordnode.all_balanceR
-/

/-! ### `bounded` -/


section

variable [Preorder α]

#print Ordnode.Bounded /-
/-- `bounded t lo hi` says that every element `x ∈ t` is in the range `lo < x < hi`, and also this
property holds recursively in subtrees, making the full tree a BST. The bounds can be set to
`lo = ⊥` and `hi = ⊤` if we care only about the internal ordering constraints. -/
def Bounded : Ordnode α → WithBot α → WithTop α → Prop
  | nil, some a, some b => a < b
  | nil, _, _ => True
  | node _ l x r, o₁, o₂ => bounded l o₁ ↑x ∧ bounded r (↑x) o₂
#align ordnode.bounded Ordnode.Bounded
-/

#print Ordnode.Bounded.dual /-
theorem Bounded.dual :
    ∀ {t : Ordnode α} {o₁ o₂} (h : Bounded t o₁ o₂), @Bounded αᵒᵈ _ (dual t) o₂ o₁
  | nil, o₁, o₂, h => by cases o₁ <;> cases o₂ <;> try trivial <;> exact h
  | node s l x r, _, _, ⟨ol, Or⟩ => ⟨Or.dual, ol.dual⟩
#align ordnode.bounded.dual Ordnode.Bounded.dual
-/

#print Ordnode.Bounded.dual_iff /-
theorem Bounded.dual_iff {t : Ordnode α} {o₁ o₂} :
    Bounded t o₁ o₂ ↔ @Bounded αᵒᵈ _ (dual t) o₂ o₁ :=
  ⟨Bounded.dual, fun h => by
    have := bounded.dual h <;> rwa [dual_dual, OrderDual.Preorder.dual_dual] at this ⟩
#align ordnode.bounded.dual_iff Ordnode.Bounded.dual_iff
-/

#print Ordnode.Bounded.weak_left /-
theorem Bounded.weak_left : ∀ {t : Ordnode α} {o₁ o₂}, Bounded t o₁ o₂ → Bounded t ⊥ o₂
  | nil, o₁, o₂, h => by cases o₂ <;> try trivial <;> exact h
  | node s l x r, _, _, ⟨ol, Or⟩ => ⟨ol.weak_left, Or⟩
#align ordnode.bounded.weak_left Ordnode.Bounded.weak_left
-/

#print Ordnode.Bounded.weak_right /-
theorem Bounded.weak_right : ∀ {t : Ordnode α} {o₁ o₂}, Bounded t o₁ o₂ → Bounded t o₁ ⊤
  | nil, o₁, o₂, h => by cases o₁ <;> try trivial <;> exact h
  | node s l x r, _, _, ⟨ol, Or⟩ => ⟨ol, Or.weak_right⟩
#align ordnode.bounded.weak_right Ordnode.Bounded.weak_right
-/

#print Ordnode.Bounded.weak /-
theorem Bounded.weak {t : Ordnode α} {o₁ o₂} (h : Bounded t o₁ o₂) : Bounded t ⊥ ⊤ :=
  h.weak_left.weak_right
#align ordnode.bounded.weak Ordnode.Bounded.weak
-/

#print Ordnode.Bounded.mono_left /-
theorem Bounded.mono_left {x y : α} (xy : x ≤ y) :
    ∀ {t : Ordnode α} {o}, Bounded t (↑y) o → Bounded t (↑x) o
  | nil, none, h => ⟨⟩
  | nil, some z, h => lt_of_le_of_lt xy h
  | node s l z r, o, ⟨ol, Or⟩ => ⟨ol.mono_left, Or⟩
#align ordnode.bounded.mono_left Ordnode.Bounded.mono_left
-/

#print Ordnode.Bounded.mono_right /-
theorem Bounded.mono_right {x y : α} (xy : x ≤ y) :
    ∀ {t : Ordnode α} {o}, Bounded t o ↑x → Bounded t o ↑y
  | nil, none, h => ⟨⟩
  | nil, some z, h => lt_of_lt_of_le h xy
  | node s l z r, o, ⟨ol, Or⟩ => ⟨ol, Or.mono_right⟩
#align ordnode.bounded.mono_right Ordnode.Bounded.mono_right
-/

#print Ordnode.Bounded.to_lt /-
theorem Bounded.to_lt : ∀ {t : Ordnode α} {x y : α}, Bounded t x y → x < y
  | nil, x, y, h => h
  | node _ l y r, x, z, ⟨h₁, h₂⟩ => lt_trans h₁.to_lt h₂.to_lt
#align ordnode.bounded.to_lt Ordnode.Bounded.to_lt
-/

#print Ordnode.Bounded.to_nil /-
theorem Bounded.to_nil {t : Ordnode α} : ∀ {o₁ o₂}, Bounded t o₁ o₂ → Bounded nil o₁ o₂
  | none, _, h => ⟨⟩
  | some _, none, h => ⟨⟩
  | some x, some y, h => h.to_lt
#align ordnode.bounded.to_nil Ordnode.Bounded.to_nil
-/

#print Ordnode.Bounded.trans_left /-
theorem Bounded.trans_left {t₁ t₂ : Ordnode α} {x : α} :
    ∀ {o₁ o₂}, Bounded t₁ o₁ ↑x → Bounded t₂ (↑x) o₂ → Bounded t₂ o₁ o₂
  | none, o₂, h₁, h₂ => h₂.weak_left
  | some y, o₂, h₁, h₂ => h₂.mono_left (le_of_lt h₁.to_lt)
#align ordnode.bounded.trans_left Ordnode.Bounded.trans_left
-/

#print Ordnode.Bounded.trans_right /-
theorem Bounded.trans_right {t₁ t₂ : Ordnode α} {x : α} :
    ∀ {o₁ o₂}, Bounded t₁ o₁ ↑x → Bounded t₂ (↑x) o₂ → Bounded t₁ o₁ o₂
  | o₁, none, h₁, h₂ => h₁.weak_right
  | o₁, some y, h₁, h₂ => h₁.mono_right (le_of_lt h₂.to_lt)
#align ordnode.bounded.trans_right Ordnode.Bounded.trans_right
-/

#print Ordnode.Bounded.mem_lt /-
theorem Bounded.mem_lt : ∀ {t o} {x : α}, Bounded t o ↑x → All (· < x) t
  | nil, o, x, _ => ⟨⟩
  | node _ l y r, o, x, ⟨h₁, h₂⟩ =>
    ⟨h₁.mem_lt.imp fun z h => lt_trans h h₂.to_lt, h₂.to_lt, h₂.mem_lt⟩
#align ordnode.bounded.mem_lt Ordnode.Bounded.mem_lt
-/

#print Ordnode.Bounded.mem_gt /-
theorem Bounded.mem_gt : ∀ {t o} {x : α}, Bounded t (↑x) o → All (· > x) t
  | nil, o, x, _ => ⟨⟩
  | node _ l y r, o, x, ⟨h₁, h₂⟩ => ⟨h₁.mem_gt, h₁.to_lt, h₂.mem_gt.imp fun z => lt_trans h₁.to_lt⟩
#align ordnode.bounded.mem_gt Ordnode.Bounded.mem_gt
-/

#print Ordnode.Bounded.of_lt /-
theorem Bounded.of_lt :
    ∀ {t o₁ o₂} {x : α}, Bounded t o₁ o₂ → Bounded nil o₁ ↑x → All (· < x) t → Bounded t o₁ ↑x
  | nil, o₁, o₂, x, _, hn, _ => hn
  | node _ l y r, o₁, o₂, x, ⟨h₁, h₂⟩, hn, ⟨al₁, al₂, al₃⟩ => ⟨h₁, h₂.of_lt al₂ al₃⟩
#align ordnode.bounded.of_lt Ordnode.Bounded.of_lt
-/

#print Ordnode.Bounded.of_gt /-
theorem Bounded.of_gt :
    ∀ {t o₁ o₂} {x : α}, Bounded t o₁ o₂ → Bounded nil (↑x) o₂ → All (· > x) t → Bounded t (↑x) o₂
  | nil, o₁, o₂, x, _, hn, _ => hn
  | node _ l y r, o₁, o₂, x, ⟨h₁, h₂⟩, hn, ⟨al₁, al₂, al₃⟩ => ⟨h₁.of_gt al₂ al₁, h₂⟩
#align ordnode.bounded.of_gt Ordnode.Bounded.of_gt
-/

#print Ordnode.Bounded.to_sep /-
theorem Bounded.to_sep {t₁ t₂ o₁ o₂} {x : α} (h₁ : Bounded t₁ o₁ ↑x) (h₂ : Bounded t₂ (↑x) o₂) :
    t₁.all fun y => t₂.all fun z : α => y < z :=
  h₁.mem_lt.imp fun y yx => h₂.mem_gt.imp fun z xz => lt_trans yx xz
#align ordnode.bounded.to_sep Ordnode.Bounded.to_sep
-/

end

/-! ### `valid` -/


section

variable [Preorder α]

#print Ordnode.Valid' /-
/-- The validity predicate for an `ordnode` subtree. This asserts that the `size` fields are
correct, the tree is balanced, and the elements of the tree are organized according to the
ordering. This version of `valid` also puts all elements in the tree in the interval `(lo, hi)`. -/
structure Valid' (lo : WithBot α) (t : Ordnode α) (hi : WithTop α) : Prop where
  ord : t.Bounded lo hi
  sz : t.Sized
  bal : t.Balanced
#align ordnode.valid' Ordnode.Valid'
-/

#print Ordnode.Valid /-
/-- The validity predicate for an `ordnode` subtree. This asserts that the `size` fields are
correct, the tree is balanced, and the elements of the tree are organized according to the
ordering. -/
def Valid (t : Ordnode α) : Prop :=
  Valid' ⊥ t ⊤
#align ordnode.valid Ordnode.Valid
-/

#print Ordnode.Valid'.mono_left /-
theorem Valid'.mono_left {x y : α} (xy : x ≤ y) {t : Ordnode α} {o} (h : Valid' (↑y) t o) :
    Valid' (↑x) t o :=
  ⟨h.1.mono_left xy, h.2, h.3⟩
#align ordnode.valid'.mono_left Ordnode.Valid'.mono_left
-/

#print Ordnode.Valid'.mono_right /-
theorem Valid'.mono_right {x y : α} (xy : x ≤ y) {t : Ordnode α} {o} (h : Valid' o t ↑x) :
    Valid' o t ↑y :=
  ⟨h.1.mono_right xy, h.2, h.3⟩
#align ordnode.valid'.mono_right Ordnode.Valid'.mono_right
-/

#print Ordnode.Valid'.trans_left /-
theorem Valid'.trans_left {t₁ t₂ : Ordnode α} {x : α} {o₁ o₂} (h : Bounded t₁ o₁ ↑x)
    (H : Valid' (↑x) t₂ o₂) : Valid' o₁ t₂ o₂ :=
  ⟨h.trans_left H.1, H.2, H.3⟩
#align ordnode.valid'.trans_left Ordnode.Valid'.trans_left
-/

#print Ordnode.Valid'.trans_right /-
theorem Valid'.trans_right {t₁ t₂ : Ordnode α} {x : α} {o₁ o₂} (H : Valid' o₁ t₁ ↑x)
    (h : Bounded t₂ (↑x) o₂) : Valid' o₁ t₁ o₂ :=
  ⟨H.1.trans_right h, H.2, H.3⟩
#align ordnode.valid'.trans_right Ordnode.Valid'.trans_right
-/

#print Ordnode.Valid'.of_lt /-
theorem Valid'.of_lt {t : Ordnode α} {x : α} {o₁ o₂} (H : Valid' o₁ t o₂) (h₁ : Bounded nil o₁ ↑x)
    (h₂ : All (· < x) t) : Valid' o₁ t ↑x :=
  ⟨H.1.of_lt h₁ h₂, H.2, H.3⟩
#align ordnode.valid'.of_lt Ordnode.Valid'.of_lt
-/

#print Ordnode.Valid'.of_gt /-
theorem Valid'.of_gt {t : Ordnode α} {x : α} {o₁ o₂} (H : Valid' o₁ t o₂) (h₁ : Bounded nil (↑x) o₂)
    (h₂ : All (· > x) t) : Valid' (↑x) t o₂ :=
  ⟨H.1.of_gt h₁ h₂, H.2, H.3⟩
#align ordnode.valid'.of_gt Ordnode.Valid'.of_gt
-/

#print Ordnode.Valid'.valid /-
theorem Valid'.valid {t o₁ o₂} (h : @Valid' α _ o₁ t o₂) : Valid t :=
  ⟨h.1.weak, h.2, h.3⟩
#align ordnode.valid'.valid Ordnode.Valid'.valid
-/

#print Ordnode.valid'_nil /-
theorem valid'_nil {o₁ o₂} (h : Bounded nil o₁ o₂) : Valid' o₁ (@nil α) o₂ :=
  ⟨h, ⟨⟩, ⟨⟩⟩
#align ordnode.valid'_nil Ordnode.valid'_nil
-/

#print Ordnode.valid_nil /-
theorem valid_nil : Valid (@nil α) :=
  valid'_nil ⟨⟩
#align ordnode.valid_nil Ordnode.valid_nil
-/

#print Ordnode.Valid'.node /-
theorem Valid'.node {s l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H : BalancedSz (size l) (size r)) (hs : s = size l + size r + 1) :
    Valid' o₁ (@node α s l x r) o₂ :=
  ⟨⟨hl.1, hr.1⟩, ⟨hs, hl.2, hr.2⟩, ⟨H, hl.3, hr.3⟩⟩
#align ordnode.valid'.node Ordnode.Valid'.node
-/

#print Ordnode.Valid'.dual /-
theorem Valid'.dual : ∀ {t : Ordnode α} {o₁ o₂} (h : Valid' o₁ t o₂), @Valid' αᵒᵈ _ o₂ (dual t) o₁
  | nil, o₁, o₂, h => valid'_nil h.1.dual
  | node s l x r, o₁, o₂, ⟨⟨ol, Or⟩, ⟨rfl, sl, sr⟩, ⟨b, bl, br⟩⟩ =>
    let ⟨ol', sl', bl'⟩ := valid'.dual ⟨ol, sl, bl⟩
    let ⟨or', sr', br'⟩ := valid'.dual ⟨Or, sr, br⟩
    ⟨⟨or', ol'⟩, ⟨by simp [size_dual, add_comm], sr', sl'⟩,
      ⟨by rw [size_dual, size_dual] <;> exact b.symm, br', bl'⟩⟩
#align ordnode.valid'.dual Ordnode.Valid'.dual
-/

#print Ordnode.Valid'.dual_iff /-
theorem Valid'.dual_iff {t : Ordnode α} {o₁ o₂} : Valid' o₁ t o₂ ↔ @Valid' αᵒᵈ _ o₂ (dual t) o₁ :=
  ⟨Valid'.dual, fun h => by
    have := valid'.dual h <;> rwa [dual_dual, OrderDual.Preorder.dual_dual] at this ⟩
#align ordnode.valid'.dual_iff Ordnode.Valid'.dual_iff
-/

#print Ordnode.Valid.dual /-
theorem Valid.dual {t : Ordnode α} : Valid t → @Valid αᵒᵈ _ (dual t) :=
  Valid'.dual
#align ordnode.valid.dual Ordnode.Valid.dual
-/

#print Ordnode.Valid.dual_iff /-
theorem Valid.dual_iff {t : Ordnode α} : Valid t ↔ @Valid αᵒᵈ _ (dual t) :=
  Valid'.dual_iff
#align ordnode.valid.dual_iff Ordnode.Valid.dual_iff
-/

#print Ordnode.Valid'.left /-
theorem Valid'.left {s l x r o₁ o₂} (H : Valid' o₁ (@node α s l x r) o₂) : Valid' o₁ l x :=
  ⟨H.1.1, H.2.2.1, H.3.2.1⟩
#align ordnode.valid'.left Ordnode.Valid'.left
-/

#print Ordnode.Valid'.right /-
theorem Valid'.right {s l x r o₁ o₂} (H : Valid' o₁ (@node α s l x r) o₂) : Valid' (↑x) r o₂ :=
  ⟨H.1.2, H.2.2.2, H.3.2.2⟩
#align ordnode.valid'.right Ordnode.Valid'.right
-/

#print Ordnode.Valid.left /-
theorem Valid.left {s l x r} (H : Valid (@node α s l x r)) : Valid l :=
  H.left.valid
#align ordnode.valid.left Ordnode.Valid.left
-/

#print Ordnode.Valid.right /-
theorem Valid.right {s l x r} (H : Valid (@node α s l x r)) : Valid r :=
  H.right.valid
#align ordnode.valid.right Ordnode.Valid.right
-/

#print Ordnode.Valid.size_eq /-
theorem Valid.size_eq {s l x r} (H : Valid (@node α s l x r)) :
    size (@node α s l x r) = size l + size r + 1 :=
  H.2.1
#align ordnode.valid.size_eq Ordnode.Valid.size_eq
-/

#print Ordnode.Valid'.node' /-
theorem Valid'.node' {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H : BalancedSz (size l) (size r)) : Valid' o₁ (@node' α l x r) o₂ :=
  hl.node hr H rfl
#align ordnode.valid'.node' Ordnode.Valid'.node'
-/

#print Ordnode.valid'_singleton /-
theorem valid'_singleton {x : α} {o₁ o₂} (h₁ : Bounded nil o₁ ↑x) (h₂ : Bounded nil (↑x) o₂) :
    Valid' o₁ (singleton x : Ordnode α) o₂ :=
  (valid'_nil h₁).node (valid'_nil h₂) (Or.inl zero_le_one) rfl
#align ordnode.valid'_singleton Ordnode.valid'_singleton
-/

#print Ordnode.valid_singleton /-
theorem valid_singleton {x : α} : Valid (singleton x : Ordnode α) :=
  valid'_singleton ⟨⟩ ⟨⟩
#align ordnode.valid_singleton Ordnode.valid_singleton
-/

#print Ordnode.Valid'.node3L /-
theorem Valid'.node3L {l x m y r o₁ o₂} (hl : Valid' o₁ l ↑x) (hm : Valid' (↑x) m ↑y)
    (hr : Valid' (↑y) r o₂) (H1 : BalancedSz (size l) (size m))
    (H2 : BalancedSz (size l + size m + 1) (size r)) : Valid' o₁ (@node3L α l x m y r) o₂ :=
  (hl.node' hm H1).node' hr H2
#align ordnode.valid'.node3_l Ordnode.Valid'.node3L
-/

#print Ordnode.Valid'.node3R /-
theorem Valid'.node3R {l x m y r o₁ o₂} (hl : Valid' o₁ l ↑x) (hm : Valid' (↑x) m ↑y)
    (hr : Valid' (↑y) r o₂) (H1 : BalancedSz (size l) (size m + size r + 1))
    (H2 : BalancedSz (size m) (size r)) : Valid' o₁ (@node3R α l x m y r) o₂ :=
  hl.node' (hm.node' hr H2) H1
#align ordnode.valid'.node3_r Ordnode.Valid'.node3R
-/

#print Ordnode.Valid'.node4L_lemma₁ /-
theorem Valid'.node4L_lemma₁ {a b c d : ℕ} (lr₂ : 3 * (b + c + 1 + d) ≤ 16 * a + 9)
    (mr₂ : b + c + 1 ≤ 3 * d) (mm₁ : b ≤ 3 * c) : b < 3 * a + 1 := by linarith
#align ordnode.valid'.node4_l_lemma₁ Ordnode.Valid'.node4L_lemma₁
-/

#print Ordnode.Valid'.node4L_lemma₂ /-
theorem Valid'.node4L_lemma₂ {b c d : ℕ} (mr₂ : b + c + 1 ≤ 3 * d) : c ≤ 3 * d := by linarith
#align ordnode.valid'.node4_l_lemma₂ Ordnode.Valid'.node4L_lemma₂
-/

#print Ordnode.Valid'.node4L_lemma₃ /-
theorem Valid'.node4L_lemma₃ {b c d : ℕ} (mr₁ : 2 * d ≤ b + c + 1) (mm₁ : b ≤ 3 * c) : d ≤ 3 * c :=
  by linarith
#align ordnode.valid'.node4_l_lemma₃ Ordnode.Valid'.node4L_lemma₃
-/

#print Ordnode.Valid'.node4L_lemma₄ /-
theorem Valid'.node4L_lemma₄ {a b c d : ℕ} (lr₁ : 3 * a ≤ b + c + 1 + d) (mr₂ : b + c + 1 ≤ 3 * d)
    (mm₁ : b ≤ 3 * c) : a + b + 1 ≤ 3 * (c + d + 1) := by linarith
#align ordnode.valid'.node4_l_lemma₄ Ordnode.Valid'.node4L_lemma₄
-/

#print Ordnode.Valid'.node4L_lemma₅ /-
theorem Valid'.node4L_lemma₅ {a b c d : ℕ} (lr₂ : 3 * (b + c + 1 + d) ≤ 16 * a + 9)
    (mr₁ : 2 * d ≤ b + c + 1) (mm₂ : c ≤ 3 * b) : c + d + 1 ≤ 3 * (a + b + 1) := by linarith
#align ordnode.valid'.node4_l_lemma₅ Ordnode.Valid'.node4L_lemma₅
-/

#print Ordnode.Valid'.node4L /-
theorem Valid'.node4L {l x m y r o₁ o₂} (hl : Valid' o₁ l ↑x) (hm : Valid' (↑x) m ↑y)
    (hr : Valid' (↑y) r o₂) (Hm : 0 < size m)
    (H :
      size l = 0 ∧ size m = 1 ∧ size r ≤ 1 ∨
        0 < size l ∧
          ratio * size r ≤ size m ∧
            delta * size l ≤ size m + size r ∧
              3 * (size m + size r) ≤ 16 * size l + 9 ∧ size m ≤ delta * size r) :
    Valid' o₁ (@node4L α l x m y r) o₂ :=
  by
  cases' m with s ml z mr; · cases Hm
  suffices :
    balanced_sz (size l) (size ml) ∧
      balanced_sz (size mr) (size r) ∧ balanced_sz (size l + size ml + 1) (size mr + size r + 1)
  exact valid'.node' (hl.node' hm.left this.1) (hm.right.node' hr this.2.1) this.2.2
  rcases H with (⟨l0, m1, r0⟩ | ⟨l0, mr₁, lr₁, lr₂, mr₂⟩)
  · rw [hm.2.size_eq, Nat.succ_inj', add_eq_zero_iff] at m1 
    rw [l0, m1.1, m1.2]; rcases size r with (_ | _ | _) <;> exact by decide
  · cases' Nat.eq_zero_or_pos (size r) with r0 r0
    · rw [r0] at mr₂ ; cases not_le_of_lt Hm mr₂
    rw [hm.2.size_eq] at lr₁ lr₂ mr₁ mr₂ 
    by_cases mm : size ml + size mr ≤ 1
    · have r1 :=
        le_antisymm
          ((mul_le_mul_left (by decide)).1 (le_trans mr₁ (Nat.succ_le_succ mm) : _ ≤ ratio * 1)) r0
      rw [r1, add_assoc] at lr₁ 
      have l1 :=
        le_antisymm
          ((mul_le_mul_left (by decide)).1 (le_trans lr₁ (add_le_add_right mm 2) : _ ≤ delta * 1))
          l0
      rw [l1, r1]
      cases size ml <;> cases size mr
      · exact by decide
      · rw [zero_add] at mm ; rcases mm with (_ | ⟨⟨⟩⟩)
        exact by decide
      · rcases mm with (_ | ⟨⟨⟩⟩); exact by decide
      · rw [Nat.succ_add] at mm ; rcases mm with (_ | ⟨⟨⟩⟩)
    rcases hm.3.1.resolve_left mm with ⟨mm₁, mm₂⟩
    cases' Nat.eq_zero_or_pos (size ml) with ml0 ml0
    · rw [ml0, MulZeroClass.mul_zero, le_zero_iff] at mm₂ 
      rw [ml0, mm₂] at mm ; cases mm (by decide)
    have : 2 * size l ≤ size ml + size mr + 1 :=
      by
      have := Nat.mul_le_mul_left _ lr₁
      rw [mul_left_comm, mul_add] at this 
      have := le_trans this (add_le_add_left mr₁ _)
      rw [← Nat.succ_mul] at this 
      exact (mul_le_mul_left (by decide)).1 this
    refine' ⟨Or.inr ⟨_, _⟩, Or.inr ⟨_, _⟩, Or.inr ⟨_, _⟩⟩
    · refine' (mul_le_mul_left (by decide)).1 (le_trans this _)
      rw [two_mul, Nat.succ_le_iff]
      refine' add_lt_add_of_lt_of_le _ mm₂
      simpa using (mul_lt_mul_right ml0).2 (by decide : 1 < 3)
    · exact Nat.le_of_lt_succ (valid'.node4_l_lemma₁ lr₂ mr₂ mm₁)
    · exact valid'.node4_l_lemma₂ mr₂
    · exact valid'.node4_l_lemma₃ mr₁ mm₁
    · exact valid'.node4_l_lemma₄ lr₁ mr₂ mm₁
    · exact valid'.node4_l_lemma₅ lr₂ mr₁ mm₂
#align ordnode.valid'.node4_l Ordnode.Valid'.node4L
-/

#print Ordnode.Valid'.rotateL_lemma₁ /-
theorem Valid'.rotateL_lemma₁ {a b c : ℕ} (H2 : 3 * a ≤ b + c) (hb₂ : c ≤ 3 * b) : a ≤ 3 * b := by
  linarith
#align ordnode.valid'.rotate_l_lemma₁ Ordnode.Valid'.rotateL_lemma₁
-/

#print Ordnode.Valid'.rotateL_lemma₂ /-
theorem Valid'.rotateL_lemma₂ {a b c : ℕ} (H3 : 2 * (b + c) ≤ 9 * a + 3) (h : b < 2 * c) :
    b < 3 * a + 1 := by linarith
#align ordnode.valid'.rotate_l_lemma₂ Ordnode.Valid'.rotateL_lemma₂
-/

#print Ordnode.Valid'.rotateL_lemma₃ /-
theorem Valid'.rotateL_lemma₃ {a b c : ℕ} (H2 : 3 * a ≤ b + c) (h : b < 2 * c) : a + b < 3 * c := by
  linarith
#align ordnode.valid'.rotate_l_lemma₃ Ordnode.Valid'.rotateL_lemma₃
-/

#print Ordnode.Valid'.rotateL_lemma₄ /-
theorem Valid'.rotateL_lemma₄ {a b : ℕ} (H3 : 2 * b ≤ 9 * a + 3) : 3 * b ≤ 16 * a + 9 := by linarith
#align ordnode.valid'.rotate_l_lemma₄ Ordnode.Valid'.rotateL_lemma₄
-/

#print Ordnode.Valid'.rotateL /-
theorem Valid'.rotateL {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H1 : ¬size l + size r ≤ 1) (H2 : delta * size l < size r)
    (H3 : 2 * size r ≤ 9 * size l + 5 ∨ size r ≤ 3) : Valid' o₁ (@rotateL α l x r) o₂ :=
  by
  cases' r with rs rl rx rr; · cases H2
  rw [hr.2.size_eq, Nat.lt_succ_iff] at H2 
  rw [hr.2.size_eq] at H3 
  replace H3 : 2 * (size rl + size rr) ≤ 9 * size l + 3 ∨ size rl + size rr ≤ 2 :=
    H3.imp (@Nat.le_of_add_le_add_right 2 _ _) Nat.le_of_succ_le_succ
  have H3_0 : size l = 0 → size rl + size rr ≤ 2 :=
    by
    intro l0; rw [l0] at H3 
    exact
      (or_iff_right_of_imp fun h => (mul_le_mul_left (by decide)).1 (le_trans h (by decide))).1 H3
  have H3p : size l > 0 → 2 * (size rl + size rr) ≤ 9 * size l + 3 := fun l0 : 1 ≤ size l =>
    (or_iff_left_of_imp <| by intro <;> linarith).1 H3
  have ablem : ∀ {a b : ℕ}, 1 ≤ a → a + b ≤ 2 → b ≤ 1 := by intros; linarith
  have hlp : size l > 0 → ¬size rl + size rr ≤ 1 := fun l0 hb =>
    absurd (le_trans (le_trans (Nat.mul_le_mul_left _ l0) H2) hb) (by decide)
  rw [rotate_l]; split_ifs
  · have rr0 : size rr > 0 :=
      (mul_lt_mul_left (by decide)).1 (lt_of_le_of_lt (Nat.zero_le _) h : ratio * 0 < _)
    suffices balanced_sz (size l) (size rl) ∧ balanced_sz (size l + size rl + 1) (size rr) by
      exact hl.node3_l hr.left hr.right this.1 this.2
    cases' Nat.eq_zero_or_pos (size l) with l0 l0
    · rw [l0]; replace H3 := H3_0 l0
      have := hr.3.1
      cases' Nat.eq_zero_or_pos (size rl) with rl0 rl0
      · rw [rl0] at this ⊢
        rw [le_antisymm (balanced_sz_zero.1 this.symm) rr0]
        exact by decide
      have rr1 : size rr = 1 := le_antisymm (ablem rl0 H3) rr0
      rw [add_comm] at H3 
      rw [rr1, show size rl = 1 from le_antisymm (ablem rr0 H3) rl0]
      exact by decide
    replace H3 := H3p l0
    rcases hr.3.1.resolve_left (hlp l0) with ⟨hb₁, hb₂⟩
    refine' ⟨Or.inr ⟨_, _⟩, Or.inr ⟨_, _⟩⟩
    · exact valid'.rotate_l_lemma₁ H2 hb₂
    · exact Nat.le_of_lt_succ (valid'.rotate_l_lemma₂ H3 h)
    · exact valid'.rotate_l_lemma₃ H2 h
    ·
      exact
        le_trans hb₂
          (Nat.mul_le_mul_left _ <| le_trans (Nat.le_add_left _ _) (Nat.le_add_right _ _))
  · cases' Nat.eq_zero_or_pos (size rl) with rl0 rl0
    · rw [rl0, not_lt, le_zero_iff, Nat.mul_eq_zero] at h 
      replace h := h.resolve_left (by decide)
      rw [rl0, h, le_zero_iff, Nat.mul_eq_zero] at H2 
      rw [hr.2.size_eq, rl0, h, H2.resolve_left (by decide)] at H1 
      cases H1 (by decide)
    refine' hl.node4_l hr.left hr.right rl0 _
    cases' Nat.eq_zero_or_pos (size l) with l0 l0
    · replace H3 := H3_0 l0
      cases' Nat.eq_zero_or_pos (size rr) with rr0 rr0
      · have := hr.3.1
        rw [rr0] at this 
        exact Or.inl ⟨l0, le_antisymm (balanced_sz_zero.1 this) rl0, rr0.symm ▸ zero_le_one⟩
      exact Or.inl ⟨l0, le_antisymm (ablem rr0 <| by rwa [add_comm]) rl0, ablem rl0 H3⟩
    exact
      Or.inr ⟨l0, not_lt.1 h, H2, valid'.rotate_l_lemma₄ (H3p l0), (hr.3.1.resolve_left (hlp l0)).1⟩
#align ordnode.valid'.rotate_l Ordnode.Valid'.rotateL
-/

#print Ordnode.Valid'.rotateR /-
theorem Valid'.rotateR {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H1 : ¬size l + size r ≤ 1) (H2 : delta * size r < size l)
    (H3 : 2 * size l ≤ 9 * size r + 5 ∨ size l ≤ 3) : Valid' o₁ (@rotateR α l x r) o₂ :=
  by
  refine' valid'.dual_iff.2 _
  rw [dual_rotate_r]
  refine' hr.dual.rotate_l hl.dual _ _ _
  · rwa [size_dual, size_dual, add_comm]
  · rwa [size_dual, size_dual]
  · rwa [size_dual, size_dual]
#align ordnode.valid'.rotate_r Ordnode.Valid'.rotateR
-/

#print Ordnode.Valid'.balance'_aux /-
theorem Valid'.balance'_aux {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H₁ : 2 * @size α r ≤ 9 * size l + 5 ∨ size r ≤ 3)
    (H₂ : 2 * @size α l ≤ 9 * size r + 5 ∨ size l ≤ 3) : Valid' o₁ (@balance' α l x r) o₂ :=
  by
  rw [balance']; split_ifs
  · exact hl.node' hr (Or.inl h)
  · exact hl.rotate_l hr h h_1 H₁
  · exact hl.rotate_r hr h h_2 H₂
  · exact hl.node' hr (Or.inr ⟨not_lt.1 h_2, not_lt.1 h_1⟩)
#align ordnode.valid'.balance'_aux Ordnode.Valid'.balance'_aux
-/

#print Ordnode.Valid'.balance'_lemma /-
theorem Valid'.balance'_lemma {α l l' r r'} (H1 : BalancedSz l' r')
    (H2 : Nat.dist (@size α l) l' ≤ 1 ∧ size r = r' ∨ Nat.dist (size r) r' ≤ 1 ∧ size l = l') :
    2 * @size α r ≤ 9 * size l + 5 ∨ size r ≤ 3 :=
  by
  suffices @size α r ≤ 3 * (size l + 1)
    by
    cases' Nat.eq_zero_or_pos (size l) with l0 l0
    · apply Or.inr; rwa [l0] at this 
    change 1 ≤ _ at l0 ; apply Or.inl; linarith
  rcases H2 with (⟨hl, rfl⟩ | ⟨hr, rfl⟩) <;> rcases H1 with (h | ⟨h₁, h₂⟩)
  · exact le_trans (Nat.le_add_left _ _) (le_trans h (Nat.le_add_left _ _))
  ·
    exact
      le_trans h₂
        (Nat.mul_le_mul_left _ <| le_trans (Nat.dist_tri_right _ _) (Nat.add_le_add_left hl _))
  ·
    exact
      le_trans (Nat.dist_tri_left' _ _)
        (le_trans (add_le_add hr (le_trans (Nat.le_add_left _ _) h)) (by decide))
  · rw [Nat.mul_succ]
    exact le_trans (Nat.dist_tri_right' _ _) (add_le_add h₂ (le_trans hr (by decide)))
#align ordnode.valid'.balance'_lemma Ordnode.Valid'.balance'_lemma
-/

#print Ordnode.Valid'.balance' /-
theorem Valid'.balance' {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H :
      ∃ l' r',
        BalancedSz l' r' ∧
          (Nat.dist (size l) l' ≤ 1 ∧ size r = r' ∨ Nat.dist (size r) r' ≤ 1 ∧ size l = l')) :
    Valid' o₁ (@balance' α l x r) o₂ :=
  let ⟨l', r', H1, H2⟩ := H
  Valid'.balance'_aux hl hr (Valid'.balance'_lemma H1 H2) (Valid'.balance'_lemma H1.symm H2.symm)
#align ordnode.valid'.balance' Ordnode.Valid'.balance'
-/

#print Ordnode.Valid'.balance /-
theorem Valid'.balance {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H :
      ∃ l' r',
        BalancedSz l' r' ∧
          (Nat.dist (size l) l' ≤ 1 ∧ size r = r' ∨ Nat.dist (size r) r' ≤ 1 ∧ size l = l')) :
    Valid' o₁ (@balance α l x r) o₂ := by
  rw [balance_eq_balance' hl.3 hr.3 hl.2 hr.2] <;> exact hl.balance' hr H
#align ordnode.valid'.balance Ordnode.Valid'.balance
-/

#print Ordnode.Valid'.balanceL_aux /-
theorem Valid'.balanceL_aux {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H₁ : size l = 0 → size r ≤ 1) (H₂ : 1 ≤ size l → 1 ≤ size r → size r ≤ delta * size l)
    (H₃ : 2 * @size α l ≤ 9 * size r + 5 ∨ size l ≤ 3) : Valid' o₁ (@balanceL α l x r) o₂ :=
  by
  rw [balance_l_eq_balance hl.2 hr.2 H₁ H₂, balance_eq_balance' hl.3 hr.3 hl.2 hr.2]
  refine' hl.balance'_aux hr (Or.inl _) H₃
  cases' Nat.eq_zero_or_pos (size r) with r0 r0
  · rw [r0]; exact Nat.zero_le _
  cases' Nat.eq_zero_or_pos (size l) with l0 l0
  · rw [l0]; exact le_trans (Nat.mul_le_mul_left _ (H₁ l0)) (by decide)
  replace H₂ : _ ≤ 3 * _ := H₂ l0 r0; linarith
#align ordnode.valid'.balance_l_aux Ordnode.Valid'.balanceL_aux
-/

#print Ordnode.Valid'.balanceL /-
theorem Valid'.balanceL {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H :
      (∃ l', Raised l' (size l) ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised (size r) r' ∧ BalancedSz (size l) r') :
    Valid' o₁ (@balanceL α l x r) o₂ :=
  by
  rw [balance_l_eq_balance' hl.3 hr.3 hl.2 hr.2 H]
  refine' hl.balance' hr _
  rcases H with (⟨l', e, H⟩ | ⟨r', e, H⟩)
  · exact ⟨_, _, H, Or.inl ⟨e.dist_le', rfl⟩⟩
  · exact ⟨_, _, H, Or.inr ⟨e.dist_le, rfl⟩⟩
#align ordnode.valid'.balance_l Ordnode.Valid'.balanceL
-/

#print Ordnode.Valid'.balanceR_aux /-
theorem Valid'.balanceR_aux {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H₁ : size r = 0 → size l ≤ 1) (H₂ : 1 ≤ size r → 1 ≤ size l → size l ≤ delta * size r)
    (H₃ : 2 * @size α r ≤ 9 * size l + 5 ∨ size r ≤ 3) : Valid' o₁ (@balanceR α l x r) o₂ :=
  by
  rw [valid'.dual_iff, dual_balance_r]
  have := hr.dual.balance_l_aux hl.dual
  rw [size_dual, size_dual] at this 
  exact this H₁ H₂ H₃
#align ordnode.valid'.balance_r_aux Ordnode.Valid'.balanceR_aux
-/

#print Ordnode.Valid'.balanceR /-
theorem Valid'.balanceR {l x r o₁ o₂} (hl : Valid' o₁ l ↑x) (hr : Valid' (↑x) r o₂)
    (H :
      (∃ l', Raised (size l) l' ∧ BalancedSz l' (size r)) ∨
        ∃ r', Raised r' (size r) ∧ BalancedSz (size l) r') :
    Valid' o₁ (@balanceR α l x r) o₂ := by
  rw [valid'.dual_iff, dual_balance_r] <;> exact hr.dual.balance_l hl.dual (balance_sz_dual H)
#align ordnode.valid'.balance_r Ordnode.Valid'.balanceR
-/

#print Ordnode.Valid'.eraseMax_aux /-
theorem Valid'.eraseMax_aux {s l x r o₁ o₂} (H : Valid' o₁ (node s l x r) o₂) :
    Valid' o₁ (@eraseMax α (node' l x r)) ↑(findMax' x r) ∧
      size (node' l x r) = size (eraseMax (node' l x r)) + 1 :=
  by
  have := H.2.eq_node'; rw [this] at H ; clear this
  induction' r with rs rl rx rr IHrl IHrr generalizing l x o₁
  · exact ⟨H.left, rfl⟩
  have := H.2.2.2.eq_node'; rw [this] at H ⊢
  rcases IHrr H.right with ⟨h, e⟩
  refine' ⟨valid'.balance_l H.left h (Or.inr ⟨_, Or.inr e, H.3.1⟩), _⟩
  rw [erase_max, size_balance_l H.3.2.1 h.3 H.2.2.1 h.2 (Or.inr ⟨_, Or.inr e, H.3.1⟩)]
  rw [size, e]; rfl
#align ordnode.valid'.erase_max_aux Ordnode.Valid'.eraseMax_aux
-/

#print Ordnode.Valid'.eraseMin_aux /-
theorem Valid'.eraseMin_aux {s l x r o₁ o₂} (H : Valid' o₁ (node s l x r) o₂) :
    Valid' (↑(findMin' l x)) (@eraseMin α (node' l x r)) o₂ ∧
      size (node' l x r) = size (eraseMin (node' l x r)) + 1 :=
  by
  have := H.dual.erase_max_aux <;>
    rwa [← dual_node', size_dual, ← dual_erase_min, size_dual, ← valid'.dual_iff, find_max'_dual] at
      this 
#align ordnode.valid'.erase_min_aux Ordnode.Valid'.eraseMin_aux
-/

#print Ordnode.eraseMin.valid /-
theorem eraseMin.valid : ∀ {t} (h : @Valid α _ t), Valid (eraseMin t)
  | nil, _ => valid_nil
  | node _ l x r, h => by rw [h.2.eq_node'] <;> exact h.erase_min_aux.1.valid
#align ordnode.erase_min.valid Ordnode.eraseMin.valid
-/

#print Ordnode.eraseMax.valid /-
theorem eraseMax.valid {t} (h : @Valid α _ t) : Valid (eraseMax t) := by
  rw [valid.dual_iff, dual_erase_max] <;> exact erase_min.valid h.dual
#align ordnode.erase_max.valid Ordnode.eraseMax.valid
-/

#print Ordnode.Valid'.glue_aux /-
theorem Valid'.glue_aux {l r o₁ o₂} (hl : Valid' o₁ l o₂) (hr : Valid' o₁ r o₂)
    (sep : l.all fun x => r.all fun y => x < y) (bal : BalancedSz (size l) (size r)) :
    Valid' o₁ (@glue α l r) o₂ ∧ size (glue l r) = size l + size r :=
  by
  cases' l with ls ll lx lr; · exact ⟨hr, (zero_add _).symm⟩
  cases' r with rs rl rx rr; · exact ⟨hl, rfl⟩
  dsimp [glue]; split_ifs
  · rw [split_max_eq, glue]
    cases' valid'.erase_max_aux hl with v e
    suffices H
    refine' ⟨valid'.balance_r v (hr.of_gt _ _) H, _⟩
    · refine' find_max'_all lx lr hl.1.2.to_nil (sep.2.2.imp _)
      exact fun x h => hr.1.2.to_nil.mono_left (le_of_lt h.2.1)
    · exact @find_max'_all _ (fun a => all (· > a) (node rs rl rx rr)) lx lr sep.2.1 sep.2.2
    · rw [size_balance_r v.3 hr.3 v.2 hr.2 H, add_right_comm, ← e, hl.2.1]; rfl
    · refine' Or.inl ⟨_, Or.inr e, _⟩
      rwa [hl.2.eq_node'] at bal 
  · rw [split_min_eq, glue]
    cases' valid'.erase_min_aux hr with v e
    suffices H
    refine' ⟨valid'.balance_l (hl.of_lt _ _) v H, _⟩
    · refine' @find_min'_all _ (fun a => bounded nil o₁ ↑a) rl rx (sep.2.1.1.imp _) hr.1.1.to_nil
      exact fun y h => hl.1.1.to_nil.mono_right (le_of_lt h)
    ·
      exact
        @find_min'_all _ (fun a => all (· < a) (node ls ll lx lr)) rl rx
          (all_iff_forall.2 fun x hx => sep.imp fun y hy => all_iff_forall.1 hy.1 _ hx)
          (sep.imp fun y hy => hy.2.1)
    · rw [size_balance_l hl.3 v.3 hl.2 v.2 H, add_assoc, ← e, hr.2.1]; rfl
    · refine' Or.inr ⟨_, Or.inr e, _⟩
      rwa [hr.2.eq_node'] at bal 
#align ordnode.valid'.glue_aux Ordnode.Valid'.glue_aux
-/

#print Ordnode.Valid'.glue /-
theorem Valid'.glue {l x r o₁ o₂} (hl : Valid' o₁ l ↑(x : α)) (hr : Valid' (↑x) r o₂) :
    BalancedSz (size l) (size r) →
      Valid' o₁ (@glue α l r) o₂ ∧ size (@glue α l r) = size l + size r :=
  Valid'.glue_aux (hl.trans_right hr.1) (hr.trans_left hl.1) (hl.1.to_sep hr.1)
#align ordnode.valid'.glue Ordnode.Valid'.glue
-/

#print Ordnode.Valid'.merge_lemma /-
theorem Valid'.merge_lemma {a b c : ℕ} (h₁ : 3 * a < b + c + 1) (h₂ : b ≤ 3 * c) :
    2 * (a + b) ≤ 9 * c + 5 := by linarith
#align ordnode.valid'.merge_lemma Ordnode.Valid'.merge_lemma
-/

#print Ordnode.Valid'.merge_aux₁ /-
theorem Valid'.merge_aux₁ {o₁ o₂ ls ll lx lr rs rl rx rr t}
    (hl : Valid' o₁ (@node α ls ll lx lr) o₂) (hr : Valid' o₁ (node rs rl rx rr) o₂)
    (h : delta * ls < rs) (v : Valid' o₁ t ↑rx) (e : size t = ls + size rl) :
    Valid' o₁ (balanceL t rx rr) o₂ ∧ size (balanceL t rx rr) = ls + rs :=
  by
  rw [hl.2.1] at e 
  rw [hl.2.1, hr.2.1, delta] at h 
  rcases hr.3.1 with (H | ⟨hr₁, hr₂⟩); · linarith
  suffices H₂; suffices H₁
  refine' ⟨valid'.balance_l_aux v hr.right H₁ H₂ _, _⟩
  · rw [e]; exact Or.inl (valid'.merge_lemma h hr₁)
  · rw [balance_l_eq_balance v.2 hr.2.2.2 H₁ H₂, balance_eq_balance' v.3 hr.3.2.2 v.2 hr.2.2.2,
      size_balance' v.2 hr.2.2.2, e, hl.2.1, hr.2.1]
    simp [add_comm, add_left_comm]
  · rw [e, add_right_comm]; rintro ⟨⟩
  · intro _ h₁; rw [e]; unfold delta at hr₂ ⊢; linarith
#align ordnode.valid'.merge_aux₁ Ordnode.Valid'.merge_aux₁
-/

#print Ordnode.Valid'.merge_aux /-
theorem Valid'.merge_aux {l r o₁ o₂} (hl : Valid' o₁ l o₂) (hr : Valid' o₁ r o₂)
    (sep : l.all fun x => r.all fun y => x < y) :
    Valid' o₁ (@merge α l r) o₂ ∧ size (merge l r) = size l + size r :=
  by
  induction' l with ls ll lx lr IHll IHlr generalizing o₁ o₂ r
  · exact ⟨hr, (zero_add _).symm⟩
  induction' r with rs rl rx rr IHrl IHrr generalizing o₁ o₂
  · exact ⟨hl, rfl⟩
  rw [merge_node]; split_ifs
  · cases'
      IHrl (sep.imp fun x h => h.1) (hl.of_lt hr.1.1.to_nil <| sep.imp fun x h => h.2.1)
        hr.left with
      v e
    exact valid'.merge_aux₁ hl hr h v e
  · cases' IHlr hl.right (hr.of_gt hl.1.2.to_nil sep.2.1) sep.2.2 with v e
    have := valid'.merge_aux₁ hr.dual hl.dual h_1 v.dual
    rw [size_dual, add_comm, size_dual, ← dual_balance_r, ← valid'.dual_iff, size_dual,
      add_comm rs] at this 
    exact this e
  · refine' valid'.glue_aux hl hr sep (Or.inr ⟨not_lt.1 h_1, not_lt.1 h⟩)
#align ordnode.valid'.merge_aux Ordnode.Valid'.merge_aux
-/

#print Ordnode.Valid.merge /-
theorem Valid.merge {l r} (hl : Valid l) (hr : Valid r)
    (sep : l.all fun x => r.all fun y => x < y) : Valid (@merge α l r) :=
  (Valid'.merge_aux hl hr sep).1
#align ordnode.valid.merge Ordnode.Valid.merge
-/

#print Ordnode.insertWith.valid_aux /-
theorem insertWith.valid_aux [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (f : α → α) (x : α)
    (hf : ∀ y, x ≤ y ∧ y ≤ x → x ≤ f y ∧ f y ≤ x) :
    ∀ {t o₁ o₂},
      Valid' o₁ t o₂ →
        Bounded nil o₁ ↑x →
          Bounded nil (↑x) o₂ →
            Valid' o₁ (insertWith f x t) o₂ ∧ Raised (size t) (size (insertWith f x t))
  | nil, o₁, o₂, _, bl, br => ⟨valid'_singleton bl br, Or.inr rfl⟩
  | node sz l y r, o₁, o₂, h, bl, br =>
    by
    rw [insert_with, cmpLE]
    split_ifs <;> rw [insert_with]
    · rcases h with ⟨⟨lx, xr⟩, hs, hb⟩
      rcases hf _ ⟨h_1, h_2⟩ with ⟨xf, fx⟩
      refine'
        ⟨⟨⟨lx.mono_right (le_trans h_2 xf), xr.mono_left (le_trans fx h_1)⟩, hs, hb⟩, Or.inl rfl⟩
    · rcases insert_with.valid_aux h.left bl (lt_of_le_not_le h_1 h_2) with ⟨vl, e⟩
      suffices H
      · refine' ⟨vl.balance_l h.right H, _⟩
        rw [size_balance_l vl.3 h.3.2.2 vl.2 h.2.2.2 H, h.2.size_eq]
        refine' (e.add_right _).add_right _
      · exact Or.inl ⟨_, e, h.3.1⟩
    · have : y < x := lt_of_le_not_le ((total_of (· ≤ ·) _ _).resolve_left h_1) h_1
      rcases insert_with.valid_aux h.right this br with ⟨vr, e⟩
      suffices H
      · refine' ⟨h.left.balance_r vr H, _⟩
        rw [size_balance_r h.3.2.1 vr.3 h.2.2.1 vr.2 H, h.2.size_eq]
        refine' (e.add_left _).add_right _
      · exact Or.inr ⟨_, e, h.3.1⟩
#align ordnode.insert_with.valid_aux Ordnode.insertWith.valid_aux
-/

#print Ordnode.insertWith.valid /-
theorem insertWith.valid [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (f : α → α) (x : α)
    (hf : ∀ y, x ≤ y ∧ y ≤ x → x ≤ f y ∧ f y ≤ x) {t} (h : Valid t) : Valid (insertWith f x t) :=
  (insertWith.valid_aux _ _ hf h ⟨⟩ ⟨⟩).1
#align ordnode.insert_with.valid Ordnode.insertWith.valid
-/

#print Ordnode.insert_eq_insertWith /-
theorem insert_eq_insertWith [@DecidableRel α (· ≤ ·)] (x : α) :
    ∀ t, Ordnode.insert x t = insertWith (fun _ => x) x t
  | nil => rfl
  | node _ l y r => by
    unfold Ordnode.insert insert_with <;> cases cmpLE x y <;> unfold Ordnode.insert insert_with <;>
      simp [insert_eq_insert_with]
#align ordnode.insert_eq_insert_with Ordnode.insert_eq_insertWith
-/

#print Ordnode.insert.valid /-
theorem insert.valid [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (x : α) {t} (h : Valid t) :
    Valid (Ordnode.insert x t) := by
  rw [insert_eq_insert_with] <;> exact insert_with.valid _ _ (fun _ _ => ⟨le_rfl, le_rfl⟩) h
#align ordnode.insert.valid Ordnode.insert.valid
-/

#print Ordnode.insert'_eq_insertWith /-
theorem insert'_eq_insertWith [@DecidableRel α (· ≤ ·)] (x : α) :
    ∀ t, insert' x t = insertWith id x t
  | nil => rfl
  | node _ l y r => by
    unfold insert' insert_with <;> cases cmpLE x y <;> unfold insert' insert_with <;>
      simp [insert'_eq_insert_with]
#align ordnode.insert'_eq_insert_with Ordnode.insert'_eq_insertWith
-/

#print Ordnode.insert'.valid /-
theorem insert'.valid [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (x : α) {t} (h : Valid t) :
    Valid (insert' x t) := by
  rw [insert'_eq_insert_with] <;> exact insert_with.valid _ _ (fun _ => id) h
#align ordnode.insert'.valid Ordnode.insert'.valid
-/

#print Ordnode.Valid'.map_aux /-
theorem Valid'.map_aux {β} [Preorder β] {f : α → β} (f_strict_mono : StrictMono f) {t a₁ a₂}
    (h : Valid' a₁ t a₂) :
    Valid' (Option.map f a₁) (map f t) (Option.map f a₂) ∧ (map f t).size = t.size :=
  by
  induction t generalizing a₁ a₂
  · simp [map]; apply valid'_nil
    cases a₁; · trivial
    cases a₂; · trivial
    simp [bounded]
    exact f_strict_mono h.ord
  · have t_ih_l' := t_ih_l h.left
    have t_ih_r' := t_ih_r h.right
    clear t_ih_l t_ih_r
    cases' t_ih_l' with t_l_valid t_l_size
    cases' t_ih_r' with t_r_valid t_r_size
    simp [map]
    constructor
    · exact And.intro t_l_valid.ord t_r_valid.ord
    · repeat' constructor
      · rw [t_l_size, t_r_size]; exact h.sz.1
      · exact t_l_valid.sz
      · exact t_r_valid.sz
    · repeat' constructor
      · rw [t_l_size, t_r_size]; exact h.bal.1
      · exact t_l_valid.bal
      · exact t_r_valid.bal
#align ordnode.valid'.map_aux Ordnode.Valid'.map_aux
-/

#print Ordnode.map.valid /-
theorem map.valid {β} [Preorder β] {f : α → β} (f_strict_mono : StrictMono f) {t} (h : Valid t) :
    Valid (map f t) :=
  (Valid'.map_aux f_strict_mono h).1
#align ordnode.map.valid Ordnode.map.valid
-/

#print Ordnode.Valid'.erase_aux /-
theorem Valid'.erase_aux [@DecidableRel α (· ≤ ·)] (x : α) {t a₁ a₂} (h : Valid' a₁ t a₂) :
    Valid' a₁ (erase x t) a₂ ∧ Raised (erase x t).size t.size :=
  by
  induction t generalizing a₁ a₂
  · simp [erase, raised]; exact h
  · simp [erase]
    have t_ih_l' := t_ih_l h.left
    have t_ih_r' := t_ih_r h.right
    clear t_ih_l t_ih_r
    cases' t_ih_l' with t_l_valid t_l_size
    cases' t_ih_r' with t_r_valid t_r_size
    cases cmpLE x t_x <;> simp [erase._match_1] <;> rw [h.sz.1]
    · suffices h_balanceable
      constructor
      · exact valid'.balance_r t_l_valid h.right h_balanceable
      · rw [size_balance_r t_l_valid.bal h.right.bal t_l_valid.sz h.right.sz h_balanceable]
        repeat' apply raised.add_right
        exact t_l_size
      · left; exists t_l.size; exact And.intro t_l_size h.bal.1
    · have h_glue := valid'.glue h.left h.right h.bal.1
      cases' h_glue with h_glue_valid h_glue_sized
      constructor
      · exact h_glue_valid
      · right; rw [h_glue_sized]
    · suffices h_balanceable
      constructor
      · exact valid'.balance_l h.left t_r_valid h_balanceable
      · rw [size_balance_l h.left.bal t_r_valid.bal h.left.sz t_r_valid.sz h_balanceable]
        apply raised.add_right
        apply raised.add_left
        exact t_r_size
      · right; exists t_r.size; exact And.intro t_r_size h.bal.1
#align ordnode.valid'.erase_aux Ordnode.Valid'.erase_aux
-/

#print Ordnode.erase.valid /-
theorem erase.valid [@DecidableRel α (· ≤ ·)] (x : α) {t} (h : Valid t) : Valid (erase x t) :=
  (Valid'.erase_aux x h).1
#align ordnode.erase.valid Ordnode.erase.valid
-/

#print Ordnode.size_erase_of_mem /-
theorem size_erase_of_mem [@DecidableRel α (· ≤ ·)] {x : α} {t a₁ a₂} (h : Valid' a₁ t a₂)
    (h_mem : x ∈ t) : size (erase x t) = size t - 1 :=
  by
  induction t generalizing a₁ a₂ h h_mem
  · contradiction
  · have t_ih_l' := t_ih_l h.left
    have t_ih_r' := t_ih_r h.right
    clear t_ih_l t_ih_r
    unfold Membership.Mem mem at h_mem 
    unfold erase
    cases cmpLE x t_x <;> simp [mem._match_1] at h_mem  <;> simp [erase._match_1]
    · have t_ih_l := t_ih_l' h_mem
      clear t_ih_l' t_ih_r'
      have t_l_h := valid'.erase_aux x h.left
      cases' t_l_h with t_l_valid t_l_size
      rw [size_balance_r t_l_valid.bal h.right.bal t_l_valid.sz h.right.sz
          (Or.inl (Exists.intro t_l.size (And.intro t_l_size h.bal.1)))]
      rw [t_ih_l, h.sz.1]
      have h_pos_t_l_size := pos_size_of_mem h.left.sz h_mem
      cases' t_l.size with t_l_size; · cases h_pos_t_l_size
      simp [Nat.succ_add]
    · rw [(valid'.glue h.left h.right h.bal.1).2, h.sz.1]; rfl
    · have t_ih_r := t_ih_r' h_mem
      clear t_ih_l' t_ih_r'
      have t_r_h := valid'.erase_aux x h.right
      cases' t_r_h with t_r_valid t_r_size
      rw [size_balance_l h.left.bal t_r_valid.bal h.left.sz t_r_valid.sz
          (Or.inr (Exists.intro t_r.size (And.intro t_r_size h.bal.1)))]
      rw [t_ih_r, h.sz.1]
      have h_pos_t_r_size := pos_size_of_mem h.right.sz h_mem
      cases' t_r.size with t_r_size; · cases h_pos_t_r_size
      simp [Nat.succ_add, Nat.add_succ]
#align ordnode.size_erase_of_mem Ordnode.size_erase_of_mem
-/

end

end Ordnode

#print Ordset /-
/-- An `ordset α` is a finite set of values, represented as a tree. The operations on this type
maintain that the tree is balanced and correctly stores subtree sizes at each level. The
correctness property of the tree is baked into the type, so all operations on this type are correct
by construction. -/
def Ordset (α : Type _) [Preorder α] :=
  { t : Ordnode α // t.valid }
#align ordset Ordset
-/

namespace Ordset

open Ordnode

variable [Preorder α]

#print Ordset.nil /-
/-- O(1). The empty set. -/
def nil : Ordset α :=
  ⟨nil, ⟨⟩, ⟨⟩, ⟨⟩⟩
#align ordset.nil Ordset.nil
-/

#print Ordset.size /-
/-- O(1). Get the size of the set. -/
def size (s : Ordset α) : ℕ :=
  s.1.size
#align ordset.size Ordset.size
-/

#print Ordset.singleton /-
/-- O(1). Construct a singleton set containing value `a`. -/
protected def singleton (a : α) : Ordset α :=
  ⟨singleton a, valid_singleton⟩
#align ordset.singleton Ordset.singleton
-/

instance : EmptyCollection (Ordset α) :=
  ⟨nil⟩

instance : Inhabited (Ordset α) :=
  ⟨nil⟩

instance : Singleton α (Ordset α) :=
  ⟨Ordset.singleton⟩

#print Ordset.Empty /-
/-- O(1). Is the set empty? -/
def Empty (s : Ordset α) : Prop :=
  s = ∅
#align ordset.empty Ordset.Empty
-/

#print Ordset.empty_iff /-
theorem empty_iff {s : Ordset α} : s = ∅ ↔ s.1.Empty :=
  ⟨fun h => by cases h <;> exact rfl, fun h => by cases s <;> cases s_val <;> [exact rfl; cases h]⟩
#align ordset.empty_iff Ordset.empty_iff
-/

instance : DecidablePred (@Empty α _) := fun s => decidable_of_iff' _ empty_iff

#print Ordset.insert /-
/-- O(log n). Insert an element into the set, preserving balance and the BST property.
  If an equivalent element is already in the set, this replaces it. -/
protected def insert [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (x : α) (s : Ordset α) :
    Ordset α :=
  ⟨Ordnode.insert x s.1, insert.valid _ s.2⟩
#align ordset.insert Ordset.insert
-/

instance [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] : Insert α (Ordset α) :=
  ⟨Ordset.insert⟩

#print Ordset.insert' /-
/-- O(log n). Insert an element into the set, preserving balance and the BST property.
  If an equivalent element is already in the set, the set is returned as is. -/
def insert' [IsTotal α (· ≤ ·)] [@DecidableRel α (· ≤ ·)] (x : α) (s : Ordset α) : Ordset α :=
  ⟨insert' x s.1, insert'.valid _ s.2⟩
#align ordset.insert' Ordset.insert'
-/

section

variable [@DecidableRel α (· ≤ ·)]

#print Ordset.mem /-
/-- O(log n). Does the set contain the element `x`? That is,
  is there an element that is equivalent to `x` in the order? -/
def mem (x : α) (s : Ordset α) : Bool :=
  x ∈ s.val
#align ordset.mem Ordset.mem
-/

#print Ordset.find /-
/-- O(log n). Retrieve an element in the set that is equivalent to `x` in the order,
  if it exists. -/
def find (x : α) (s : Ordset α) : Option α :=
  Ordnode.find x s.val
#align ordset.find Ordset.find
-/

instance : Membership α (Ordset α) :=
  ⟨fun x s => mem x s⟩

#print Ordset.mem.decidable /-
instance mem.decidable (x : α) (s : Ordset α) : Decidable (x ∈ s) :=
  Bool.decidableEq _ _
#align ordset.mem.decidable Ordset.mem.decidable
-/

#print Ordset.pos_size_of_mem /-
theorem pos_size_of_mem {x : α} {t : Ordset α} (h_mem : x ∈ t) : 0 < size t :=
  by
  simp [Membership.Mem, mem] at h_mem 
  apply Ordnode.pos_size_of_mem t.property.sz h_mem
#align ordset.pos_size_of_mem Ordset.pos_size_of_mem
-/

end

#print Ordset.erase /-
/-- O(log n). Remove an element from the set equivalent to `x`. Does nothing if there
is no such element. -/
def erase [@DecidableRel α (· ≤ ·)] (x : α) (s : Ordset α) : Ordset α :=
  ⟨Ordnode.erase x s.val, Ordnode.erase.valid x s.property⟩
#align ordset.erase Ordset.erase
-/

#print Ordset.map /-
/-- O(n). Map a function across a tree, without changing the structure. -/
def map {β} [Preorder β] (f : α → β) (f_strict_mono : StrictMono f) (s : Ordset α) : Ordset β :=
  ⟨Ordnode.map f s.val, Ordnode.map.valid f_strict_mono s.property⟩
#align ordset.map Ordset.map
-/

end Ordset

