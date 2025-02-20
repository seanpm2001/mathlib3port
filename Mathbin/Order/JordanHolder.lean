/-
Copyright (c) 2021 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes

! This file was ported from Lean 3 source module order.jordan_holder
! leanprover-community/mathlib commit 69c6a5a12d8a2b159f20933e60115a4f2de62b58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Lattice
import Mathbin.Data.List.Sort
import Mathbin.Logic.Equiv.Fin
import Mathbin.Logic.Equiv.Functor
import Mathbin.Data.Fintype.Card

/-!
# Jordan-Hölder Theorem

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file proves the Jordan Hölder theorem for a `jordan_holder_lattice`, a class also defined in
this file. Examples of `jordan_holder_lattice` include `subgroup G` if `G` is a group, and
`submodule R M` if `M` is an `R`-module. Using this approach the theorem need not be proved
seperately for both groups and modules, the proof in this file can be applied to both.

## Main definitions
The main definitions in this file are `jordan_holder_lattice` and `composition_series`,
and the relation `equivalent` on `composition_series`

A `jordan_holder_lattice` is the class for which the Jordan Hölder theorem is proved. A
Jordan Hölder lattice is a lattice equipped with a notion of maximality, `is_maximal`, and a notion
of isomorphism of pairs `iso`. In the example of subgroups of a group, `is_maximal H K` means that
`H` is a maximal normal subgroup of `K`, and `iso (H₁, K₁) (H₂, K₂)` means that the quotient
`H₁ / K₁` is isomorphic to the quotient `H₂ / K₂`. `iso` must be symmetric and transitive and must
satisfy the second isomorphism theorem `iso (H, H ⊔ K) (H ⊓ K, K)`.

A `composition_series X` is a finite nonempty series of elements of the lattice `X` such that
each element is maximal inside the next. The length of a `composition_series X` is
one less than the number of elements in the series. Note that there is no stipulation
that a series start from the bottom of the lattice and finish at the top.
For a composition series `s`, `s.top` is the largest element of the series,
and `s.bot` is the least element.

Two `composition_series X`, `s₁` and `s₂` are equivalent if there is a bijection
`e : fin s₁.length ≃ fin s₂.length` such that for any `i`,
`iso (s₁ i, s₁ i.succ) (s₂ (e i), s₂ (e i.succ))`

## Main theorems

The main theorem is `composition_series.jordan_holder`, which says that if two composition
series have the same least element and the same largest element,
then they are `equivalent`.

## TODO

Provide instances of `jordan_holder_lattice` for both submodules and subgroups, and potentially
for modular lattices.

It is not entirely clear how this should be done. Possibly there should be no global instances
of `jordan_holder_lattice`, and the instances should only be defined locally in order to prove
the Jordan-Hölder theorem for modules/groups and the API should be transferred because many of the
theorems in this file will have stronger versions for modules. There will also need to be an API for
mapping composition series across homomorphisms. It is also probably possible to
provide an instance of `jordan_holder_lattice` for any `modular_lattice`, and in this case the
Jordan-Hölder theorem will say that there is a well defined notion of length of a modular lattice.
However an instance of `jordan_holder_lattice` for a modular lattice will not be able to contain
the correct notion of isomorphism for modules, so a separate instance for modules will still be
required and this will clash with the instance for modular lattices, and so at least one of these
instances should not be a global instance.
-/


universe u

open Set

#print JordanHolderLattice /-
/-- A `jordan_holder_lattice` is the class for which the Jordan Hölder theorem is proved. A
Jordan Hölder lattice is a lattice equipped with a notion of maximality, `is_maximal`, and a notion
of isomorphism of pairs `iso`. In the example of subgroups of a group, `is_maximal H K` means that
`H` is a maximal normal subgroup of `K`, and `iso (H₁, K₁) (H₂, K₂)` means that the quotient
`H₁ / K₁` is isomorphic to the quotient `H₂ / K₂`. `iso` must be symmetric and transitive and must
satisfy the second isomorphism theorem `iso (H, H ⊔ K) (H ⊓ K, K)`.
Examples include `subgroup G` if `G` is a group, and `submodule R M` if `M` is an `R`-module.
-/
class JordanHolderLattice (X : Type u) [Lattice X] where
  IsMaximal : X → X → Prop
  lt_of_isMaximal : ∀ {x y}, is_maximal x y → x < y
  sup_eq_of_isMaximal : ∀ {x y z}, is_maximal x z → is_maximal y z → x ≠ y → x ⊔ y = z
  isMaximal_inf_left_of_isMaximal_sup :
    ∀ {x y}, is_maximal x (x ⊔ y) → is_maximal y (x ⊔ y) → is_maximal (x ⊓ y) x
  Iso : X × X → X × X → Prop
  iso_symm : ∀ {x y}, iso x y → iso y x
  iso_trans : ∀ {x y z}, iso x y → iso y z → iso x z
  second_iso : ∀ {x y}, is_maximal x (x ⊔ y) → iso (x, x ⊔ y) (x ⊓ y, y)
#align jordan_holder_lattice JordanHolderLattice
-/

namespace JordanHolderLattice

variable {X : Type u} [Lattice X] [JordanHolderLattice X]

#print JordanHolderLattice.isMaximal_inf_right_of_isMaximal_sup /-
theorem isMaximal_inf_right_of_isMaximal_sup {x y : X} (hxz : IsMaximal x (x ⊔ y))
    (hyz : IsMaximal y (x ⊔ y)) : IsMaximal (x ⊓ y) y :=
  by
  rw [inf_comm]
  rw [sup_comm] at hxz hyz 
  exact is_maximal_inf_left_of_is_maximal_sup hyz hxz
#align jordan_holder_lattice.is_maximal_inf_right_of_is_maximal_sup JordanHolderLattice.isMaximal_inf_right_of_isMaximal_sup
-/

#print JordanHolderLattice.isMaximal_of_eq_inf /-
theorem isMaximal_of_eq_inf (x b : X) {a y : X} (ha : x ⊓ y = a) (hxy : x ≠ y) (hxb : IsMaximal x b)
    (hyb : IsMaximal y b) : IsMaximal a y :=
  by
  have hb : x ⊔ y = b := sup_eq_of_is_maximal hxb hyb hxy
  substs a b
  exact is_maximal_inf_right_of_is_maximal_sup hxb hyb
#align jordan_holder_lattice.is_maximal_of_eq_inf JordanHolderLattice.isMaximal_of_eq_inf
-/

#print JordanHolderLattice.second_iso_of_eq /-
theorem second_iso_of_eq {x y a b : X} (hm : IsMaximal x a) (ha : x ⊔ y = a) (hb : x ⊓ y = b) :
    Iso (x, a) (b, y) := by substs a b <;> exact second_iso hm
#align jordan_holder_lattice.second_iso_of_eq JordanHolderLattice.second_iso_of_eq
-/

#print JordanHolderLattice.IsMaximal.iso_refl /-
theorem IsMaximal.iso_refl {x y : X} (h : IsMaximal x y) : Iso (x, y) (x, y) :=
  second_iso_of_eq h (sup_eq_right.2 (le_of_lt (lt_of_isMaximal h)))
    (inf_eq_left.2 (le_of_lt (lt_of_isMaximal h)))
#align jordan_holder_lattice.is_maximal.iso_refl JordanHolderLattice.IsMaximal.iso_refl
-/

end JordanHolderLattice

open JordanHolderLattice

attribute [symm] iso_symm

attribute [trans] iso_trans

#print CompositionSeries /-
/-- A `composition_series X` is a finite nonempty series of elements of a
`jordan_holder_lattice` such that each element is maximal inside the next. The length of a
`composition_series X` is one less than the number of elements in the series.
Note that there is no stipulation that a series start from the bottom of the lattice and finish at
the top. For a composition series `s`, `s.top` is the largest element of the series,
and `s.bot` is the least element.
-/
structure CompositionSeries (X : Type u) [Lattice X] [JordanHolderLattice X] : Type u where
  length : ℕ
  series : Fin (length + 1) → X
  step' : ∀ i : Fin length, IsMaximal (series i.cast_succ) (series i.succ)
#align composition_series CompositionSeries
-/

namespace CompositionSeries

variable {X : Type u} [Lattice X] [JordanHolderLattice X]

instance : CoeFun (CompositionSeries X) fun x => Fin (x.length + 1) → X
    where coe := CompositionSeries.series

instance [Inhabited X] : Inhabited (CompositionSeries X) :=
  ⟨{  length := 0
      series := default
      step' := fun x => x.elim0ₓ }⟩

variable {X}

#print CompositionSeries.step /-
theorem step (s : CompositionSeries X) : ∀ i : Fin s.length, IsMaximal (s i.cast_succ) (s i.succ) :=
  s.step'
#align composition_series.step CompositionSeries.step
-/

#print CompositionSeries.coeFn_mk /-
@[simp]
theorem coeFn_mk (length : ℕ) (series step) :
    (@CompositionSeries.mk X _ _ length series step : Fin length.succ → X) = series :=
  rfl
#align composition_series.coe_fn_mk CompositionSeries.coeFn_mk
-/

#print CompositionSeries.lt_succ /-
theorem lt_succ (s : CompositionSeries X) (i : Fin s.length) : s i.cast_succ < s i.succ :=
  lt_of_isMaximal (s.step _)
#align composition_series.lt_succ CompositionSeries.lt_succ
-/

#print CompositionSeries.strictMono /-
protected theorem strictMono (s : CompositionSeries X) : StrictMono s :=
  Fin.strictMono_iff_lt_succ.2 s.lt_succ
#align composition_series.strict_mono CompositionSeries.strictMono
-/

#print CompositionSeries.injective /-
protected theorem injective (s : CompositionSeries X) : Function.Injective s :=
  s.StrictMono.Injective
#align composition_series.injective CompositionSeries.injective
-/

#print CompositionSeries.inj /-
@[simp]
protected theorem inj (s : CompositionSeries X) {i j : Fin s.length.succ} : s i = s j ↔ i = j :=
  s.Injective.eq_iff
#align composition_series.inj CompositionSeries.inj
-/

instance : Membership X (CompositionSeries X) :=
  ⟨fun x s => x ∈ Set.range s⟩

#print CompositionSeries.mem_def /-
theorem mem_def {x : X} {s : CompositionSeries X} : x ∈ s ↔ x ∈ Set.range s :=
  Iff.rfl
#align composition_series.mem_def CompositionSeries.mem_def
-/

#print CompositionSeries.total /-
theorem total {s : CompositionSeries X} {x y : X} (hx : x ∈ s) (hy : y ∈ s) : x ≤ y ∨ y ≤ x :=
  by
  rcases Set.mem_range.1 hx with ⟨i, rfl⟩
  rcases Set.mem_range.1 hy with ⟨j, rfl⟩
  rw [s.strict_mono.le_iff_le, s.strict_mono.le_iff_le]
  exact le_total i j
#align composition_series.total CompositionSeries.total
-/

#print CompositionSeries.toList /-
/-- The ordered `list X` of elements of a `composition_series X`. -/
def toList (s : CompositionSeries X) : List X :=
  List.ofFn s
#align composition_series.to_list CompositionSeries.toList
-/

#print CompositionSeries.ext_fun /-
/-- Two `composition_series` are equal if they are the same length and
have the same `i`th element for every `i` -/
theorem ext_fun {s₁ s₂ : CompositionSeries X} (hl : s₁.length = s₂.length)
    (h : ∀ i, s₁ i = s₂ (Fin.cast (congr_arg Nat.succ hl) i)) : s₁ = s₂ :=
  by
  cases s₁; cases s₂
  dsimp at *
  subst hl
  simpa [Function.funext_iff] using h
#align composition_series.ext_fun CompositionSeries.ext_fun
-/

#print CompositionSeries.length_toList /-
@[simp]
theorem length_toList (s : CompositionSeries X) : s.toList.length = s.length + 1 := by
  rw [to_list, List.length_ofFn]
#align composition_series.length_to_list CompositionSeries.length_toList
-/

#print CompositionSeries.toList_ne_nil /-
theorem toList_ne_nil (s : CompositionSeries X) : s.toList ≠ [] := by
  rw [← List.length_pos_iff_ne_nil, length_to_list] <;> exact Nat.succ_pos _
#align composition_series.to_list_ne_nil CompositionSeries.toList_ne_nil
-/

#print CompositionSeries.toList_injective /-
theorem toList_injective : Function.Injective (@CompositionSeries.toList X _ _) :=
  fun s₁ s₂ (h : List.ofFn s₁ = List.ofFn s₂) =>
  by
  have h₁ : s₁.length = s₂.length :=
    Nat.succ_injective
      ((List.length_ofFn s₁).symm.trans <| (congr_arg List.length h).trans <| List.length_ofFn s₂)
  have h₂ : ∀ i : Fin s₁.length.succ, s₁ i = s₂ (Fin.cast (congr_arg Nat.succ h₁) i) :=
    by
    intro i
    rw [← List.nthLe_ofFn s₁ i, ← List.nthLe_ofFn s₂]
    simp [h]
  cases s₁
  cases s₂
  dsimp at *
  subst h₁
  simp only [heq_iff_eq, eq_self_iff_true, true_and_iff]
  simp only [Fin.cast_refl] at h₂ 
  exact funext h₂
#align composition_series.to_list_injective CompositionSeries.toList_injective
-/

#print CompositionSeries.chain'_toList /-
theorem chain'_toList (s : CompositionSeries X) : List.Chain' IsMaximal s.toList :=
  List.chain'_iff_nthLe.2
    (by
      intro i hi
      simp only [to_list, List.nthLe_ofFn']
      rw [length_to_list] at hi 
      exact s.step ⟨i, hi⟩)
#align composition_series.chain'_to_list CompositionSeries.chain'_toList
-/

#print CompositionSeries.toList_sorted /-
theorem toList_sorted (s : CompositionSeries X) : s.toList.Sorted (· < ·) :=
  List.pairwise_iff_nthLe.2 fun i j hi hij =>
    by
    dsimp [to_list]
    rw [List.nthLe_ofFn', List.nthLe_ofFn']
    exact s.strict_mono hij
#align composition_series.to_list_sorted CompositionSeries.toList_sorted
-/

#print CompositionSeries.toList_nodup /-
theorem toList_nodup (s : CompositionSeries X) : s.toList.Nodup :=
  s.toList_sorted.Nodup
#align composition_series.to_list_nodup CompositionSeries.toList_nodup
-/

#print CompositionSeries.mem_toList /-
@[simp]
theorem mem_toList {s : CompositionSeries X} {x : X} : x ∈ s.toList ↔ x ∈ s := by
  rw [to_list, List.mem_ofFn, mem_def]
#align composition_series.mem_to_list CompositionSeries.mem_toList
-/

#print CompositionSeries.ofList /-
/-- Make a `composition_series X` from the ordered list of its elements. -/
def ofList (l : List X) (hl : l ≠ []) (hc : List.Chain' IsMaximal l) : CompositionSeries X
    where
  length := l.length - 1
  series i :=
    l.nthLe i
      (by
        conv_rhs => rw [← tsub_add_cancel_of_le (Nat.succ_le_of_lt (List.length_pos_of_ne_nil hl))]
        exact i.2)
  step' := fun ⟨i, hi⟩ => List.chain'_iff_nthLe.1 hc i hi
#align composition_series.of_list CompositionSeries.ofList
-/

#print CompositionSeries.length_ofList /-
theorem length_ofList (l : List X) (hl : l ≠ []) (hc : List.Chain' IsMaximal l) :
    (ofList l hl hc).length = l.length - 1 :=
  rfl
#align composition_series.length_of_list CompositionSeries.length_ofList
-/

#print CompositionSeries.ofList_toList /-
theorem ofList_toList (s : CompositionSeries X) :
    ofList s.toList s.toList_ne_nil s.chain'_toList = s :=
  by
  refine' ext_fun _ _
  · rw [length_of_list, length_to_list, Nat.succ_sub_one]
  · rintro ⟨i, hi⟩
    dsimp [of_list, to_list]
    rw [List.nthLe_ofFn']
#align composition_series.of_list_to_list CompositionSeries.ofList_toList
-/

#print CompositionSeries.ofList_toList' /-
@[simp]
theorem ofList_toList' (s : CompositionSeries X) :
    ofList s.toList s.toList_ne_nil s.chain'_toList = s :=
  ofList_toList s
#align composition_series.of_list_to_list' CompositionSeries.ofList_toList'
-/

#print CompositionSeries.toList_ofList /-
@[simp]
theorem toList_ofList (l : List X) (hl : l ≠ []) (hc : List.Chain' IsMaximal l) :
    toList (ofList l hl hc) = l := by
  refine' List.ext_nthLe _ _
  ·
    rw [length_to_list, length_of_list,
      tsub_add_cancel_of_le (Nat.succ_le_of_lt <| List.length_pos_of_ne_nil hl)]
  · intro i hi hi'
    dsimp [of_list, to_list]
    rw [List.nthLe_ofFn']
    rfl
#align composition_series.to_list_of_list CompositionSeries.toList_ofList
-/

#print CompositionSeries.ext /-
/-- Two `composition_series` are equal if they have the same elements. See also `ext_fun`. -/
@[ext]
theorem ext {s₁ s₂ : CompositionSeries X} (h : ∀ x, x ∈ s₁ ↔ x ∈ s₂) : s₁ = s₂ :=
  toList_injective <|
    List.eq_of_perm_of_sorted
      (by
        classical exact
          List.perm_of_nodup_nodup_toFinset_eq s₁.to_list_nodup s₂.to_list_nodup
            (Finset.ext <| by simp [*]))
      s₁.toList_sorted s₂.toList_sorted
#align composition_series.ext CompositionSeries.ext
-/

#print CompositionSeries.top /-
/-- The largest element of a `composition_series` -/
def top (s : CompositionSeries X) : X :=
  s (Fin.last _)
#align composition_series.top CompositionSeries.top
-/

#print CompositionSeries.top_mem /-
theorem top_mem (s : CompositionSeries X) : s.top ∈ s :=
  mem_def.2 (Set.mem_range.2 ⟨Fin.last _, rfl⟩)
#align composition_series.top_mem CompositionSeries.top_mem
-/

#print CompositionSeries.le_top /-
@[simp]
theorem le_top {s : CompositionSeries X} (i : Fin (s.length + 1)) : s i ≤ s.top :=
  s.StrictMono.Monotone (Fin.le_last _)
#align composition_series.le_top CompositionSeries.le_top
-/

#print CompositionSeries.le_top_of_mem /-
theorem le_top_of_mem {s : CompositionSeries X} {x : X} (hx : x ∈ s) : x ≤ s.top :=
  let ⟨i, hi⟩ := Set.mem_range.2 hx
  hi ▸ le_top _
#align composition_series.le_top_of_mem CompositionSeries.le_top_of_mem
-/

#print CompositionSeries.bot /-
/-- The smallest element of a `composition_series` -/
def bot (s : CompositionSeries X) : X :=
  s 0
#align composition_series.bot CompositionSeries.bot
-/

#print CompositionSeries.bot_mem /-
theorem bot_mem (s : CompositionSeries X) : s.bot ∈ s :=
  mem_def.2 (Set.mem_range.2 ⟨0, rfl⟩)
#align composition_series.bot_mem CompositionSeries.bot_mem
-/

#print CompositionSeries.bot_le /-
@[simp]
theorem bot_le {s : CompositionSeries X} (i : Fin (s.length + 1)) : s.bot ≤ s i :=
  s.StrictMono.Monotone (Fin.zero_le _)
#align composition_series.bot_le CompositionSeries.bot_le
-/

#print CompositionSeries.bot_le_of_mem /-
theorem bot_le_of_mem {s : CompositionSeries X} {x : X} (hx : x ∈ s) : s.bot ≤ x :=
  let ⟨i, hi⟩ := Set.mem_range.2 hx
  hi ▸ bot_le _
#align composition_series.bot_le_of_mem CompositionSeries.bot_le_of_mem
-/

#print CompositionSeries.length_pos_of_mem_ne /-
theorem length_pos_of_mem_ne {s : CompositionSeries X} {x y : X} (hx : x ∈ s) (hy : y ∈ s)
    (hxy : x ≠ y) : 0 < s.length :=
  let ⟨i, hi⟩ := hx
  let ⟨j, hj⟩ := hy
  have hij : i ≠ j := mt s.inj.2 fun h => hxy (hi ▸ hj ▸ h)
  hij.lt_or_lt.elim
    (fun hij => lt_of_le_of_lt (zero_le i) (lt_of_lt_of_le hij (Nat.le_of_lt_succ j.2))) fun hji =>
    lt_of_le_of_lt (zero_le j) (lt_of_lt_of_le hji (Nat.le_of_lt_succ i.2))
#align composition_series.length_pos_of_mem_ne CompositionSeries.length_pos_of_mem_ne
-/

#print CompositionSeries.forall_mem_eq_of_length_eq_zero /-
theorem forall_mem_eq_of_length_eq_zero {s : CompositionSeries X} (hs : s.length = 0) {x y}
    (hx : x ∈ s) (hy : y ∈ s) : x = y :=
  by_contradiction fun hxy => pos_iff_ne_zero.1 (length_pos_of_mem_ne hx hy hxy) hs
#align composition_series.forall_mem_eq_of_length_eq_zero CompositionSeries.forall_mem_eq_of_length_eq_zero
-/

#print CompositionSeries.eraseTop /-
/-- Remove the largest element from a `composition_series`. If the series `s`
has length zero, then `s.erase_top = s` -/
@[simps]
def eraseTop (s : CompositionSeries X) : CompositionSeries X
    where
  length := s.length - 1
  series i := s ⟨i, lt_of_lt_of_le i.2 (Nat.succ_le_succ tsub_le_self)⟩
  step' i := by
    have := s.step ⟨i, lt_of_lt_of_le i.2 tsub_le_self⟩
    cases i
    exact this
#align composition_series.erase_top CompositionSeries.eraseTop
-/

#print CompositionSeries.top_eraseTop /-
theorem top_eraseTop (s : CompositionSeries X) :
    s.eraseTop.top = s ⟨s.length - 1, lt_of_le_of_lt tsub_le_self (Nat.lt_succ_self _)⟩ :=
  show s _ = s _ from
    congr_arg s
      (by
        ext
        simp only [erase_top_length, Fin.val_last, Fin.coe_castSucc, Fin.coe_ofNat_eq_mod,
          Fin.val_mk, coe_coe])
#align composition_series.top_erase_top CompositionSeries.top_eraseTop
-/

#print CompositionSeries.eraseTop_top_le /-
theorem eraseTop_top_le (s : CompositionSeries X) : s.eraseTop.top ≤ s.top := by
  simp [erase_top, top, s.strict_mono.le_iff_le, Fin.le_iff_val_le_val, tsub_le_self]
#align composition_series.erase_top_top_le CompositionSeries.eraseTop_top_le
-/

#print CompositionSeries.bot_eraseTop /-
@[simp]
theorem bot_eraseTop (s : CompositionSeries X) : s.eraseTop.bot = s.bot :=
  rfl
#align composition_series.bot_erase_top CompositionSeries.bot_eraseTop
-/

#print CompositionSeries.mem_eraseTop_of_ne_of_mem /-
theorem mem_eraseTop_of_ne_of_mem {s : CompositionSeries X} {x : X} (hx : x ≠ s.top) (hxs : x ∈ s) :
    x ∈ s.eraseTop := by
  rcases hxs with ⟨i, rfl⟩
  have hi : (i : ℕ) < (s.length - 1).succ :=
    by
    conv_rhs => rw [← Nat.succ_sub (length_pos_of_mem_ne ⟨i, rfl⟩ s.top_mem hx), Nat.succ_sub_one]
    exact lt_of_le_of_ne (Nat.le_of_lt_succ i.2) (by simpa [top, s.inj, Fin.ext_iff] using hx)
  refine' ⟨i.cast_succ, _⟩
  simp [Fin.ext_iff, Nat.mod_eq_of_lt hi]
#align composition_series.mem_erase_top_of_ne_of_mem CompositionSeries.mem_eraseTop_of_ne_of_mem
-/

#print CompositionSeries.mem_eraseTop /-
theorem mem_eraseTop {s : CompositionSeries X} {x : X} (h : 0 < s.length) :
    x ∈ s.eraseTop ↔ x ≠ s.top ∧ x ∈ s :=
  by
  simp only [mem_def]
  dsimp only [erase_top, coe_fn_mk]
  constructor
  · rintro ⟨i, rfl⟩
    have hi : (i : ℕ) < s.length :=
      by
      conv_rhs => rw [← Nat.succ_sub_one s.length, Nat.succ_sub h]
      exact i.2
    simp [top, Fin.ext_iff, ne_of_lt hi]
  · intro h
    exact mem_erase_top_of_ne_of_mem h.1 h.2
#align composition_series.mem_erase_top CompositionSeries.mem_eraseTop
-/

#print CompositionSeries.lt_top_of_mem_eraseTop /-
theorem lt_top_of_mem_eraseTop {s : CompositionSeries X} {x : X} (h : 0 < s.length)
    (hx : x ∈ s.eraseTop) : x < s.top :=
  lt_of_le_of_ne (le_top_of_mem ((mem_eraseTop h).1 hx).2) ((mem_eraseTop h).1 hx).1
#align composition_series.lt_top_of_mem_erase_top CompositionSeries.lt_top_of_mem_eraseTop
-/

#print CompositionSeries.isMaximal_eraseTop_top /-
theorem isMaximal_eraseTop_top {s : CompositionSeries X} (h : 0 < s.length) :
    IsMaximal s.eraseTop.top s.top :=
  by
  have : s.length - 1 + 1 = s.length := by
    conv_rhs => rw [← Nat.succ_sub_one s.length] <;> rw [Nat.succ_sub h]
  rw [top_erase_top, top]
  convert s.step ⟨s.length - 1, Nat.sub_lt h zero_lt_one⟩ <;> ext <;> simp [this]
#align composition_series.is_maximal_erase_top_top CompositionSeries.isMaximal_eraseTop_top
-/

section FinLemmas

-- TODO: move these to `vec_notation` and rename them to better describe their statement
variable {α : Type _} {m n : ℕ} (a : Fin m.succ → α) (b : Fin n.succ → α)

#print CompositionSeries.append_castAdd_aux /-
theorem append_castAdd_aux (i : Fin m) :
    Matrix.vecAppend (Nat.add_succ _ _).symm (a ∘ Fin.castSucc) b (Fin.castAdd n i).cast_succ =
      a i.cast_succ :=
  by cases i; simp [Matrix.vecAppend_eq_ite, *]
#align composition_series.append_cast_add_aux CompositionSeries.append_castAdd_aux
-/

#print CompositionSeries.append_succ_castAdd_aux /-
theorem append_succ_castAdd_aux (i : Fin m) (h : a (Fin.last _) = b 0) :
    Matrix.vecAppend (Nat.add_succ _ _).symm (a ∘ Fin.castSucc) b (Fin.castAdd n i).succ =
      a i.succ :=
  by
  cases' i with i hi
  simp only [Matrix.vecAppend_eq_ite, hi, Fin.succ_mk, Function.comp_apply, Fin.castSucc_mk,
    Fin.val_mk, Fin.castAdd_mk]
  split_ifs
  · rfl
  · have : i + 1 = m := le_antisymm hi (le_of_not_gt h_1)
    calc
      b ⟨i + 1 - m, by simp [this]⟩ = b 0 := congr_arg b (by simp [Fin.ext_iff, this])
      _ = a (Fin.last _) := h.symm
      _ = _ := congr_arg a (by simp [Fin.ext_iff, this])
#align composition_series.append_succ_cast_add_aux CompositionSeries.append_succ_castAdd_aux
-/

#print CompositionSeries.append_natAdd_aux /-
theorem append_natAdd_aux (i : Fin n) :
    Matrix.vecAppend (Nat.add_succ _ _).symm (a ∘ Fin.castSucc) b (Fin.natAdd m i).cast_succ =
      b i.cast_succ :=
  by
  cases i
  simp only [Matrix.vecAppend_eq_ite, Nat.not_lt_zero, Fin.natAdd_mk, add_lt_iff_neg_left,
    add_tsub_cancel_left, dif_neg, Fin.castSucc_mk, not_false_iff, Fin.val_mk]
#align composition_series.append_nat_add_aux CompositionSeries.append_natAdd_aux
-/

#print CompositionSeries.append_succ_natAdd_aux /-
theorem append_succ_natAdd_aux (i : Fin n) :
    Matrix.vecAppend (Nat.add_succ _ _).symm (a ∘ Fin.castSucc) b (Fin.natAdd m i).succ =
      b i.succ :=
  by
  cases' i with i hi
  simp only [Matrix.vecAppend_eq_ite, add_assoc, Nat.not_lt_zero, Fin.natAdd_mk,
    add_lt_iff_neg_left, add_tsub_cancel_left, Fin.succ_mk, dif_neg, not_false_iff, Fin.val_mk]
#align composition_series.append_succ_nat_add_aux CompositionSeries.append_succ_natAdd_aux
-/

end FinLemmas

#print CompositionSeries.append /-
/-- Append two composition series `s₁` and `s₂` such that
the least element of `s₁` is the maximum element of `s₂`. -/
@[simps length]
def append (s₁ s₂ : CompositionSeries X) (h : s₁.top = s₂.bot) : CompositionSeries X
    where
  length := s₁.length + s₂.length
  series := Matrix.vecAppend (Nat.add_succ _ _).symm (s₁ ∘ Fin.castSucc) s₂
  step' i := by
    refine' Fin.addCases _ _ i
    · intro i
      rw [append_succ_cast_add_aux _ _ _ h, append_cast_add_aux]
      exact s₁.step i
    · intro i
      rw [append_nat_add_aux, append_succ_nat_add_aux]
      exact s₂.step i
#align composition_series.append CompositionSeries.append
-/

#print CompositionSeries.coe_append /-
theorem coe_append (s₁ s₂ : CompositionSeries X) (h) :
    ⇑(s₁.append s₂ h) = Matrix.vecAppend (Nat.add_succ _ _).symm (s₁ ∘ Fin.castSucc) s₂ :=
  rfl
#align composition_series.coe_append CompositionSeries.coe_append
-/

#print CompositionSeries.append_castAdd /-
@[simp]
theorem append_castAdd {s₁ s₂ : CompositionSeries X} (h : s₁.top = s₂.bot) (i : Fin s₁.length) :
    append s₁ s₂ h (Fin.castAdd s₂.length i).cast_succ = s₁ i.cast_succ := by
  rw [coe_append, append_cast_add_aux _ _ i]
#align composition_series.append_cast_add CompositionSeries.append_castAdd
-/

#print CompositionSeries.append_succ_castAdd /-
@[simp]
theorem append_succ_castAdd {s₁ s₂ : CompositionSeries X} (h : s₁.top = s₂.bot)
    (i : Fin s₁.length) : append s₁ s₂ h (Fin.castAdd s₂.length i).succ = s₁ i.succ := by
  rw [coe_append, append_succ_cast_add_aux _ _ _ h]
#align composition_series.append_succ_cast_add CompositionSeries.append_succ_castAdd
-/

#print CompositionSeries.append_natAdd /-
@[simp]
theorem append_natAdd {s₁ s₂ : CompositionSeries X} (h : s₁.top = s₂.bot) (i : Fin s₂.length) :
    append s₁ s₂ h (Fin.natAdd s₁.length i).cast_succ = s₂ i.cast_succ := by
  rw [coe_append, append_nat_add_aux _ _ i]
#align composition_series.append_nat_add CompositionSeries.append_natAdd
-/

#print CompositionSeries.append_succ_natAdd /-
@[simp]
theorem append_succ_natAdd {s₁ s₂ : CompositionSeries X} (h : s₁.top = s₂.bot) (i : Fin s₂.length) :
    append s₁ s₂ h (Fin.natAdd s₁.length i).succ = s₂ i.succ := by
  rw [coe_append, append_succ_nat_add_aux _ _ i]
#align composition_series.append_succ_nat_add CompositionSeries.append_succ_natAdd
-/

#print CompositionSeries.snoc /-
/-- Add an element to the top of a `composition_series` -/
@[simps length]
def snoc (s : CompositionSeries X) (x : X) (hsat : IsMaximal s.top x) : CompositionSeries X
    where
  length := s.length + 1
  series := Fin.snoc s x
  step' i := by
    refine' Fin.lastCases _ _ i
    · rwa [Fin.snoc_castSucc, Fin.succ_last, Fin.snoc_last, ← top]
    · intro i
      rw [Fin.snoc_castSucc, ← Fin.castSucc_fin_succ, Fin.snoc_castSucc]
      exact s.step _
#align composition_series.snoc CompositionSeries.snoc
-/

#print CompositionSeries.top_snoc /-
@[simp]
theorem top_snoc (s : CompositionSeries X) (x : X) (hsat : IsMaximal s.top x) :
    (snoc s x hsat).top = x :=
  Fin.snoc_last _ _
#align composition_series.top_snoc CompositionSeries.top_snoc
-/

#print CompositionSeries.snoc_last /-
@[simp]
theorem snoc_last (s : CompositionSeries X) (x : X) (hsat : IsMaximal s.top x) :
    snoc s x hsat (Fin.last (s.length + 1)) = x :=
  Fin.snoc_last _ _
#align composition_series.snoc_last CompositionSeries.snoc_last
-/

#print CompositionSeries.snoc_castSucc /-
@[simp]
theorem snoc_castSucc (s : CompositionSeries X) (x : X) (hsat : IsMaximal s.top x)
    (i : Fin (s.length + 1)) : snoc s x hsat i.cast_succ = s i :=
  Fin.snoc_castSucc _ _ _
#align composition_series.snoc_cast_succ CompositionSeries.snoc_castSucc
-/

#print CompositionSeries.bot_snoc /-
@[simp]
theorem bot_snoc (s : CompositionSeries X) (x : X) (hsat : IsMaximal s.top x) :
    (snoc s x hsat).bot = s.bot := by rw [bot, bot, ← snoc_cast_succ s _ _ 0, Fin.castSucc_zero]
#align composition_series.bot_snoc CompositionSeries.bot_snoc
-/

#print CompositionSeries.mem_snoc /-
theorem mem_snoc {s : CompositionSeries X} {x y : X} {hsat : IsMaximal s.top x} :
    y ∈ snoc s x hsat ↔ y ∈ s ∨ y = x :=
  by
  simp only [snoc, mem_def]
  constructor
  · rintro ⟨i, rfl⟩
    refine' Fin.lastCases _ (fun i => _) i
    · right; simp
    · left; simp
  · intro h
    rcases h with (⟨i, rfl⟩ | rfl)
    · use i.cast_succ; simp
    · use Fin.last _; simp
#align composition_series.mem_snoc CompositionSeries.mem_snoc
-/

#print CompositionSeries.eq_snoc_eraseTop /-
theorem eq_snoc_eraseTop {s : CompositionSeries X} (h : 0 < s.length) :
    s = snoc (eraseTop s) s.top (isMaximal_eraseTop_top h) :=
  by
  ext x
  simp [mem_snoc, mem_erase_top h]
  by_cases h : x = s.top <;> simp [*, s.top_mem]
#align composition_series.eq_snoc_erase_top CompositionSeries.eq_snoc_eraseTop
-/

#print CompositionSeries.snoc_eraseTop_top /-
@[simp]
theorem snoc_eraseTop_top {s : CompositionSeries X} (h : IsMaximal s.eraseTop.top s.top) :
    s.eraseTop.snoc s.top h = s :=
  have h : 0 < s.length :=
    Nat.pos_of_ne_zero
      (by
        intro hs
        refine' ne_of_gt (lt_of_is_maximal h) _
        simp [top, Fin.ext_iff, hs])
  (eq_snoc_eraseTop h).symm
#align composition_series.snoc_erase_top_top CompositionSeries.snoc_eraseTop_top
-/

#print CompositionSeries.Equivalent /-
/-- Two `composition_series X`, `s₁` and `s₂` are equivalent if there is a bijection
`e : fin s₁.length ≃ fin s₂.length` such that for any `i`,
`iso (s₁ i) (s₁ i.succ) (s₂ (e i), s₂ (e i.succ))` -/
def Equivalent (s₁ s₂ : CompositionSeries X) : Prop :=
  ∃ f : Fin s₁.length ≃ Fin s₂.length,
    ∀ i : Fin s₁.length, Iso (s₁ i.cast_succ, s₁ i.succ) (s₂ (f i).cast_succ, s₂ (f i).succ)
#align composition_series.equivalent CompositionSeries.Equivalent
-/

namespace Equivalent

#print CompositionSeries.Equivalent.refl /-
@[refl]
theorem refl (s : CompositionSeries X) : Equivalent s s :=
  ⟨Equiv.refl _, fun _ => (s.step _).iso_refl⟩
#align composition_series.equivalent.refl CompositionSeries.Equivalent.refl
-/

#print CompositionSeries.Equivalent.symm /-
@[symm]
theorem symm {s₁ s₂ : CompositionSeries X} (h : Equivalent s₁ s₂) : Equivalent s₂ s₁ :=
  ⟨h.some.symm, fun i => iso_symm (by simpa using h.some_spec (h.some.symm i))⟩
#align composition_series.equivalent.symm CompositionSeries.Equivalent.symm
-/

#print CompositionSeries.Equivalent.trans /-
@[trans]
theorem trans {s₁ s₂ s₃ : CompositionSeries X} (h₁ : Equivalent s₁ s₂) (h₂ : Equivalent s₂ s₃) :
    Equivalent s₁ s₃ :=
  ⟨h₁.some.trans h₂.some, fun i => iso_trans (h₁.choose_spec i) (h₂.choose_spec (h₁.some i))⟩
#align composition_series.equivalent.trans CompositionSeries.Equivalent.trans
-/

#print CompositionSeries.Equivalent.append /-
theorem append {s₁ s₂ t₁ t₂ : CompositionSeries X} (hs : s₁.top = s₂.bot) (ht : t₁.top = t₂.bot)
    (h₁ : Equivalent s₁ t₁) (h₂ : Equivalent s₂ t₂) :
    Equivalent (append s₁ s₂ hs) (append t₁ t₂ ht) :=
  let e : Fin (s₁.length + s₂.length) ≃ Fin (t₁.length + t₂.length) :=
    calc
      Fin (s₁.length + s₂.length) ≃ Sum (Fin s₁.length) (Fin s₂.length) := finSumFinEquiv.symm
      _ ≃ Sum (Fin t₁.length) (Fin t₂.length) := (Equiv.sumCongr h₁.some h₂.some)
      _ ≃ Fin (t₁.length + t₂.length) := finSumFinEquiv
  ⟨e, by
    intro i
    refine' Fin.addCases _ _ i
    · intro i
      simpa [top, bot] using h₁.some_spec i
    · intro i
      simpa [top, bot] using h₂.some_spec i⟩
#align composition_series.equivalent.append CompositionSeries.Equivalent.append
-/

#print CompositionSeries.Equivalent.snoc /-
protected theorem snoc {s₁ s₂ : CompositionSeries X} {x₁ x₂ : X} {hsat₁ : IsMaximal s₁.top x₁}
    {hsat₂ : IsMaximal s₂.top x₂} (hequiv : Equivalent s₁ s₂)
    (htop : Iso (s₁.top, x₁) (s₂.top, x₂)) : Equivalent (s₁.snoc x₁ hsat₁) (s₂.snoc x₂ hsat₂) :=
  let e : Fin s₁.length.succ ≃ Fin s₂.length.succ :=
    calc
      Fin (s₁.length + 1) ≃ Option (Fin s₁.length) := finSuccEquivLast
      _ ≃ Option (Fin s₂.length) := (Functor.mapEquiv Option hequiv.some)
      _ ≃ Fin (s₂.length + 1) := finSuccEquivLast.symm
  ⟨e, fun i => by
    refine' Fin.lastCases _ _ i
    · simpa [top] using htop
    · intro i
      simpa [Fin.succ_castSucc] using hequiv.some_spec i⟩
#align composition_series.equivalent.snoc CompositionSeries.Equivalent.snoc
-/

#print CompositionSeries.Equivalent.length_eq /-
theorem length_eq {s₁ s₂ : CompositionSeries X} (h : Equivalent s₁ s₂) : s₁.length = s₂.length := by
  simpa using Fintype.card_congr h.some
#align composition_series.equivalent.length_eq CompositionSeries.Equivalent.length_eq
-/

#print CompositionSeries.Equivalent.snoc_snoc_swap /-
theorem snoc_snoc_swap {s : CompositionSeries X} {x₁ x₂ y₁ y₂ : X} {hsat₁ : IsMaximal s.top x₁}
    {hsat₂ : IsMaximal s.top x₂} {hsaty₁ : IsMaximal (snoc s x₁ hsat₁).top y₁}
    {hsaty₂ : IsMaximal (snoc s x₂ hsat₂).top y₂} (hr₁ : Iso (s.top, x₁) (x₂, y₂))
    (hr₂ : Iso (x₁, y₁) (s.top, x₂)) :
    Equivalent (snoc (snoc s x₁ hsat₁) y₁ hsaty₁) (snoc (snoc s x₂ hsat₂) y₂ hsaty₂) :=
  let e : Fin (s.length + 1 + 1) ≃ Fin (s.length + 1 + 1) :=
    Equiv.swap (Fin.last _) (Fin.castSucc (Fin.last _))
  have h1 : ∀ {i : Fin s.length}, i.cast_succ.cast_succ ≠ (Fin.last _).cast_succ := fun _ =>
    ne_of_lt (by simp [Fin.castSucc_lt_last])
  have h2 : ∀ {i : Fin s.length}, i.cast_succ.cast_succ ≠ Fin.last _ := fun _ =>
    ne_of_lt (by simp [Fin.castSucc_lt_last])
  ⟨e, by
    intro i
    dsimp only [e]
    refine' Fin.lastCases _ (fun i => _) i
    · erw [Equiv.swap_apply_left, snoc_cast_succ, snoc_last, Fin.succ_last, snoc_last,
        snoc_cast_succ, snoc_cast_succ, Fin.succ_castSucc, snoc_cast_succ, Fin.succ_last, snoc_last]
      exact hr₂
    · refine' Fin.lastCases _ (fun i => _) i
      · erw [Equiv.swap_apply_right, snoc_cast_succ, snoc_cast_succ, snoc_cast_succ,
          Fin.succ_castSucc, snoc_cast_succ, Fin.succ_last, snoc_last, snoc_last, Fin.succ_last,
          snoc_last]
        exact hr₁
      · erw [Equiv.swap_apply_of_ne_of_ne h2 h1, snoc_cast_succ, snoc_cast_succ, snoc_cast_succ,
          snoc_cast_succ, Fin.succ_castSucc, snoc_cast_succ, Fin.succ_castSucc, snoc_cast_succ,
          snoc_cast_succ, snoc_cast_succ]
        exact (s.step i).iso_refl⟩
#align composition_series.equivalent.snoc_snoc_swap CompositionSeries.Equivalent.snoc_snoc_swap
-/

end Equivalent

#print CompositionSeries.length_eq_zero_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero /-
theorem length_eq_zero_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero {s₁ s₂ : CompositionSeries X}
    (hb : s₁.bot = s₂.bot) (ht : s₁.top = s₂.top) (hs₁ : s₁.length = 0) : s₂.length = 0 :=
  by
  have : s₁.bot = s₁.top := congr_arg s₁ (Fin.ext (by simp [hs₁]))
  have : Fin.last s₂.length = (0 : Fin s₂.length.succ) :=
    s₂.injective (hb.symm.trans (this.trans ht)).symm
  simpa [Fin.ext_iff]
#align composition_series.length_eq_zero_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero CompositionSeries.length_eq_zero_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero
-/

#print CompositionSeries.length_pos_of_bot_eq_bot_of_top_eq_top_of_length_pos /-
theorem length_pos_of_bot_eq_bot_of_top_eq_top_of_length_pos {s₁ s₂ : CompositionSeries X}
    (hb : s₁.bot = s₂.bot) (ht : s₁.top = s₂.top) : 0 < s₁.length → 0 < s₂.length :=
  not_imp_not.1
    (by
      simp only [pos_iff_ne_zero, Ne.def, not_iff_not, Classical.not_not]
      exact length_eq_zero_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero hb.symm ht.symm)
#align composition_series.length_pos_of_bot_eq_bot_of_top_eq_top_of_length_pos CompositionSeries.length_pos_of_bot_eq_bot_of_top_eq_top_of_length_pos
-/

#print CompositionSeries.eq_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero /-
theorem eq_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero {s₁ s₂ : CompositionSeries X}
    (hb : s₁.bot = s₂.bot) (ht : s₁.top = s₂.top) (hs₁0 : s₁.length = 0) : s₁ = s₂ :=
  by
  have : ∀ x, x ∈ s₁ ↔ x = s₁.top := fun x =>
    ⟨fun hx => forall_mem_eq_of_length_eq_zero hs₁0 hx s₁.top_mem, fun hx => hx.symm ▸ s₁.top_mem⟩
  have : ∀ x, x ∈ s₂ ↔ x = s₂.top := fun x =>
    ⟨fun hx =>
      forall_mem_eq_of_length_eq_zero
        (length_eq_zero_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero hb ht hs₁0) hx s₂.top_mem,
      fun hx => hx.symm ▸ s₂.top_mem⟩
  ext
  simp [*]
#align composition_series.eq_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero CompositionSeries.eq_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero
-/

#print CompositionSeries.exists_top_eq_snoc_equivalant /-
/-- Given a `composition_series`, `s`, and an element `x`
such that `x` is maximal inside `s.top` there is a series, `t`,
such that `t.top = x`, `t.bot = s.bot`
and `snoc t s.top _` is equivalent to `s`. -/
theorem exists_top_eq_snoc_equivalant (s : CompositionSeries X) (x : X) (hm : IsMaximal x s.top)
    (hb : s.bot ≤ x) :
    ∃ t : CompositionSeries X,
      t.bot = s.bot ∧
        t.length + 1 = s.length ∧ ∃ htx : t.top = x, Equivalent s (snoc t s.top (htx.symm ▸ hm)) :=
  by
  induction' hn : s.length with n ih generalizing s x
  ·
    exact
      (ne_of_gt (lt_of_le_of_lt hb (lt_of_is_maximal hm))
          (forall_mem_eq_of_length_eq_zero hn s.top_mem s.bot_mem)).elim
  · have h0s : 0 < s.length := hn.symm ▸ Nat.succ_pos _
    by_cases hetx : s.erase_top.top = x
    · use s.erase_top
      simp [← hetx, hn]
    · have imxs : is_maximal (x ⊓ s.erase_top.top) s.erase_top.top :=
        is_maximal_of_eq_inf x s.top rfl (Ne.symm hetx) hm (is_maximal_erase_top_top h0s)
      have := ih _ _ imxs (le_inf (by simpa) (le_top_of_mem s.erase_top.bot_mem)) (by simp [hn])
      rcases this with ⟨t, htb, htl, htt, hteqv⟩
      have hmtx : is_maximal t.top x :=
        is_maximal_of_eq_inf s.erase_top.top s.top (by rw [inf_comm, htt]) hetx
          (is_maximal_erase_top_top h0s) hm
      use snoc t x hmtx
      refine' ⟨by simp [htb], by simp [htl], by simp, _⟩
      have :
        s.equivalent
          ((snoc t s.erase_top.top (htt.symm ▸ imxs)).snoc s.top
            (by simpa using is_maximal_erase_top_top h0s)) :=
        by
        conv_lhs => rw [eq_snoc_erase_top h0s]
        exact equivalent.snoc hteqv (by simpa using (is_maximal_erase_top_top h0s).iso_refl)
      refine' this.trans _
      refine' equivalent.snoc_snoc_swap _ _
      ·
        exact
          iso_symm
            (second_iso_of_eq hm
              (sup_eq_of_is_maximal hm (is_maximal_erase_top_top h0s) (Ne.symm hetx)) htt.symm)
      ·
        exact
          second_iso_of_eq (is_maximal_erase_top_top h0s)
            (sup_eq_of_is_maximal (is_maximal_erase_top_top h0s) hm hetx) (by rw [inf_comm, htt])
#align composition_series.exists_top_eq_snoc_equivalant CompositionSeries.exists_top_eq_snoc_equivalant
-/

#print CompositionSeries.jordan_holder /-
/-- The **Jordan-Hölder** theorem, stated for any `jordan_holder_lattice`.
If two composition series start and finish at the same place, they are equivalent. -/
theorem jordan_holder (s₁ s₂ : CompositionSeries X) (hb : s₁.bot = s₂.bot) (ht : s₁.top = s₂.top) :
    Equivalent s₁ s₂ :=
  by
  induction' hle : s₁.length with n ih generalizing s₁ s₂
  · rw [eq_of_bot_eq_bot_of_top_eq_top_of_length_eq_zero hb ht hle]
  · have h0s₂ : 0 < s₂.length :=
      length_pos_of_bot_eq_bot_of_top_eq_top_of_length_pos hb ht (hle.symm ▸ Nat.succ_pos _)
    rcases exists_top_eq_snoc_equivalant s₁ s₂.erase_top.top
        (ht.symm ▸ is_maximal_erase_top_top h0s₂)
        (hb.symm ▸ s₂.bot_erase_top ▸ bot_le_of_mem (top_mem _)) with
      ⟨t, htb, htl, htt, hteq⟩
    have := ih t s₂.erase_top (by simp [htb, ← hb]) htt (Nat.succ_inj'.1 (htl.trans hle))
    refine' hteq.trans _
    conv_rhs => rw [eq_snoc_erase_top h0s₂]
    simp only [ht]
    exact equivalent.snoc this (by simp [htt, (is_maximal_erase_top_top h0s₂).iso_refl])
#align composition_series.jordan_holder CompositionSeries.jordan_holder
-/

end CompositionSeries

