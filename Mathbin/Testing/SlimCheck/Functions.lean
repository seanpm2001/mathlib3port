/-
Copyright (c) 2020 Simon Hudon. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Simon Hudon

! This file was ported from Lean 3 source module testing.slim_check.functions
! leanprover-community/mathlib commit 44b58b42794e5abe2bf86397c38e26b587e07e59
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.List.Sigma
import Mathbin.Data.Int.Range
import Mathbin.Data.Finsupp.Defs
import Mathbin.Data.Finsupp.ToDfinsupp
import Mathbin.Tactic.PrettyCases
import Mathbin.Testing.SlimCheck.Sampleable
import Mathbin.Testing.SlimCheck.Testable

/-!
## `slim_check`: generators for functions

This file defines `sampleable` instances for `α → β` functions and
`ℤ → ℤ` injective functions.

Functions are generated by creating a list of pairs and one more value
using the list as a lookup table and resorting to the additional value
when a value is not found in the table.

Injective functions are generated by creating a list of numbers and
a permutation of that list. The permutation insures that every input
is mapped to a unique output. When an input is not found in the list
the input itself is used as an output.

Injective functions `f : α → α` could be generated easily instead of
`ℤ → ℤ` by generating a `list α`, removing duplicates and creating a
permutations. One has to be careful when generating the domain to make
if vast enough that, when generating arguments to apply `f` to,
they argument should be likely to lie in the domain of `f`. This is
the reason that injective functions `f : ℤ → ℤ` are generated by
fixing the domain to the range `[-2*size .. -2*size]`, with `size`
the size parameter of the `gen` monad.

Much of the machinery provided in this file is applicable to generate
injective functions of type `α → α` and new instances should be easy
to define.

Other classes of functions such as monotone functions can generated using
similar techniques. For monotone functions, generating two lists, sorting them
and matching them should suffice, with appropriate default values.
Some care must be taken for shrinking such functions to make sure
their defining property is invariant through shrinking. Injective
functions are an example of how complicated it can get.
-/


universe u v w

variable {α : Type u} {β : Type v} {γ : Sort w}

namespace SlimCheck

/-- Data structure specifying a total function using a list of pairs
and a default value returned when the input is not in the domain of
the partial function.

`with_default f y` encodes `x ↦ f x` when `x ∈ f` and `x ↦ y`
otherwise.

We use `Σ` to encode mappings instead of `×` because we
rely on the association list API defined in `data.list.sigma`.
 -/
inductive TotalFunction (α : Type u) (β : Type v) : Type max u v
  | with_default : List (Σ_ : α, β) → β → total_function
#align slim_check.total_function SlimCheck.TotalFunction

instance TotalFunction.inhabited [Inhabited β] : Inhabited (TotalFunction α β) :=
  ⟨TotalFunction.with_default ∅ default⟩
#align slim_check.total_function.inhabited SlimCheck.TotalFunction.inhabited

namespace TotalFunction

/-- Apply a total function to an argument. -/
def apply [DecidableEq α] : TotalFunction α β → α → β
  | total_function.with_default m y, x => (m.lookup x).getOrElse y
#align slim_check.total_function.apply SlimCheck.TotalFunction.apply

/-- Implementation of `has_repr (total_function α β)`.

Creates a string for a given `finmap` and output, `x₀ ↦ y₀, .. xₙ ↦ yₙ`
for each of the entries. The brackets are provided by the calling function.
-/
def reprAux [Repr α] [Repr β] (m : List (Σ_ : α, β)) : String :=
  String.join <|
    List.qsort (fun x y => x < y)
      (m.map fun x => s!"{(repr <| Sigma.fst x)} ↦ {repr <| Sigma.snd x}, ")
#align slim_check.total_function.repr_aux SlimCheck.TotalFunction.reprAux

/-- Produce a string for a given `total_function`.
The output is of the form `[x₀ ↦ f x₀, .. xₙ ↦ f xₙ, _ ↦ y]`.
-/
protected def repr [Repr α] [Repr β] : TotalFunction α β → String
  | total_function.with_default m y => s!"[{(reprAux m)}_ ↦ {Repr.repr y}]"
#align slim_check.total_function.repr SlimCheck.TotalFunction.repr

instance (α : Type u) (β : Type v) [Repr α] [Repr β] : Repr (TotalFunction α β) :=
  ⟨TotalFunction.repr⟩

/-- Create a `finmap` from a list of pairs. -/
def List.toFinmap' (xs : List (α × β)) : List (Σ_ : α, β) :=
  xs.map Prod.toSigma
#align slim_check.total_function.list.to_finmap' SlimCheck.TotalFunction.List.toFinmap'

section

variable [Sampleable α] [Sampleable β]

/-- Redefine `sizeof` to follow the structure of `sampleable` instances. -/
def Total.sizeof : TotalFunction α β → ℕ
  | ⟨m, x⟩ => 1 + @SizeOf.sizeOf _ Sampleable.wf m + SizeOf.sizeOf x
#align slim_check.total_function.total.sizeof SlimCheck.TotalFunction.Total.sizeof

instance (priority := 2000) : SizeOf (TotalFunction α β) :=
  ⟨Total.sizeof⟩

variable [DecidableEq α]

/-- Shrink a total function by shrinking the lists that represent it. -/
protected def shrink : ShrinkFn (TotalFunction α β)
  | ⟨m, x⟩ =>
    (Sampleable.shrink (m, x)).map fun ⟨⟨m', x'⟩, h⟩ =>
      ⟨⟨List.dedupkeys m', x'⟩,
        lt_of_le_of_lt
          (by unfold_wf <;> refine' @List.sizeof_dedupkeys _ _ _ (@sampleable.wf _ _) _) h⟩
#align slim_check.total_function.shrink SlimCheck.TotalFunction.shrink

variable [Repr α] [Repr β]

instance Pi.sampleableExt : SampleableExt (α → β)
    where
  ProxyRepr := TotalFunction α β
  interp := TotalFunction.apply
  sample := do
    let xs ← (Sampleable.sample (List (α × β)) : Gen (List (α × β)))
    let ⟨x⟩ ← (Uliftable.up <| sample β : Gen (ULift.{max u v} β))
    pure <| total_function.with_default (list.to_finmap' xs) x
  shrink := TotalFunction.shrink
#align slim_check.total_function.pi.sampleable_ext SlimCheck.TotalFunction.Pi.sampleableExt

end

section Finsupp

variable [Zero β]

/-- Map a total_function to one whose default value is zero so that it represents a finsupp. -/
@[simp]
def zeroDefault : TotalFunction α β → TotalFunction α β
  | with_default A y => with_default A 0
#align slim_check.total_function.zero_default SlimCheck.TotalFunction.zeroDefault

variable [DecidableEq α] [DecidableEq β]

/-- The support of a zero default `total_function`. -/
@[simp]
def zeroDefaultSupp : TotalFunction α β → Finset α
  | with_default A y =>
    List.toFinset <| (A.dedupkeys.filter fun ab => Sigma.snd ab ≠ 0).map Sigma.fst
#align slim_check.total_function.zero_default_supp SlimCheck.TotalFunction.zeroDefaultSupp

/-- Create a finitely supported function from a total function by taking the default value to
zero. -/
def applyFinsupp (tf : TotalFunction α β) : α →₀ β
    where
  support := zeroDefaultSupp tf
  toFun := tf.zeroDefault.apply
  mem_support_to_fun := by
    intro a
    rcases tf with ⟨A, y⟩
    simp only [apply, zero_default_supp, List.mem_map, List.mem_filter, exists_and_right,
      List.mem_to_finset, exists_eq_right, Sigma.exists, Ne.def, zero_default]
    constructor
    · rintro ⟨od, hval, hod⟩
      have := List.mem_lookup (List.nodupkeys_dedupkeys A) hval
      rw [(_ : List.lookup a A = od)]
      · simpa
      · simpa [List.lookup_dedupkeys, WithTop.some_eq_coe]
    · intro h
      use (A.lookup a).getOrElse (0 : β)
      rw [← List.lookup_dedupkeys] at h⊢
      simp only [h, ← List.mem_lookup_iff A.nodupkeys_dedupkeys, and_true_iff, not_false_iff,
        Option.mem_def]
      cases List.lookup a A.dedupkeys
      · simpa using h
      · simp
#align slim_check.total_function.apply_finsupp SlimCheck.TotalFunction.applyFinsupp

variable [Sampleable α] [Sampleable β]

instance Finsupp.sampleableExt [Repr α] [Repr β] : SampleableExt (α →₀ β)
    where
  ProxyRepr := TotalFunction α β
  interp := TotalFunction.applyFinsupp
  sample := do
    let xs ← (Sampleable.sample (List (α × β)) : Gen (List (α × β)))
    let ⟨x⟩ ← (Uliftable.up <| sample β : Gen (ULift.{max u v} β))
    pure <| total_function.with_default (list.to_finmap' xs) x
  shrink := TotalFunction.shrink
#align
  slim_check.total_function.finsupp.sampleable_ext SlimCheck.TotalFunction.Finsupp.sampleableExt

-- TODO: support a non-constant codomain type
instance Dfinsupp.sampleableExt [Repr α] [Repr β] : SampleableExt (Π₀ a : α, β)
    where
  ProxyRepr := TotalFunction α β
  interp := Finsupp.toDfinsupp ∘ total_function.apply_finsupp
  sample := do
    let xs ← (Sampleable.sample (List (α × β)) : Gen (List (α × β)))
    let ⟨x⟩ ← (Uliftable.up <| sample β : Gen (ULift.{max u v} β))
    pure <| total_function.with_default (list.to_finmap' xs) x
  shrink := TotalFunction.shrink
#align
  slim_check.total_function.dfinsupp.sampleable_ext SlimCheck.TotalFunction.Dfinsupp.sampleableExt

end Finsupp

section SampleableExt

open SampleableExt

instance (priority := 2000) PiPred.sampleableExt [SampleableExt (α → Bool)] :
    SampleableExt.{u + 1} (α → Prop)
    where
  ProxyRepr := ProxyRepr (α → Bool)
  interp m x := interp (α → Bool) m x
  sample := sample (α → Bool)
  shrink := shrink
#align slim_check.total_function.pi_pred.sampleable_ext SlimCheck.TotalFunction.PiPred.sampleableExt

instance (priority := 2000) PiUncurry.sampleableExt [SampleableExt (α × β → γ)] :
    SampleableExt.{imax (u + 1) (v + 1) w} (α → β → γ)
    where
  ProxyRepr := ProxyRepr (α × β → γ)
  interp m x y := interp (α × β → γ) m (x, y)
  sample := sample (α × β → γ)
  shrink := shrink
#align
  slim_check.total_function.pi_uncurry.sampleable_ext SlimCheck.TotalFunction.PiUncurry.sampleableExt

end SampleableExt

end TotalFunction

/-- Data structure specifying a total function using a list of pairs
and a default value returned when the input is not in the domain of
the partial function.

`map_to_self f` encodes `x ↦ f x` when `x ∈ f` and `x ↦ x`,
i.e. `x` to itself, otherwise.

We use `Σ` to encode mappings instead of `×` because we
rely on the association list API defined in `data.list.sigma`.
-/
inductive InjectiveFunction (α : Type u) : Type u
  |
  map_to_self (xs : List (Σ_ : α, α)) :
    xs.map Sigma.fst ~ xs.map Sigma.snd → List.Nodup (xs.map Sigma.snd) → injective_function
#align slim_check.injective_function SlimCheck.InjectiveFunction

instance : Inhabited (InjectiveFunction α) :=
  ⟨⟨[], List.Perm.nil, List.nodup_nil⟩⟩

namespace InjectiveFunction

/-- Apply a total function to an argument. -/
def apply [DecidableEq α] : InjectiveFunction α → α → α
  | injective_function.map_to_self m _ _, x => (m.lookup x).getOrElse x
#align slim_check.injective_function.apply SlimCheck.InjectiveFunction.apply

/-- Produce a string for a given `total_function`.
The output is of the form `[x₀ ↦ f x₀, .. xₙ ↦ f xₙ, x ↦ x]`.
Unlike for `total_function`, the default value is not a constant
but the identity function.
-/
protected def repr [Repr α] : InjectiveFunction α → String
  | injective_function.map_to_self m _ _ => s! "[{TotalFunction.reprAux m}x ↦ x]"
#align slim_check.injective_function.repr SlimCheck.InjectiveFunction.repr

instance (α : Type u) [Repr α] : Repr (InjectiveFunction α) :=
  ⟨InjectiveFunction.repr⟩

/-- Interpret a list of pairs as a total function, defaulting to
the identity function when no entries are found for a given function -/
def List.applyId [DecidableEq α] (xs : List (α × α)) (x : α) : α :=
  ((xs.map Prod.toSigma).lookup x).getOrElse x
#align slim_check.injective_function.list.apply_id SlimCheck.InjectiveFunction.List.applyId

/- ./././Mathport/Syntax/Translate/Expr.lean:177:8: unsupported: ambiguous notation -/
@[simp]
theorem List.apply_id_cons [DecidableEq α] (xs : List (α × α)) (x y z : α) :
    List.applyId ((y, z)::xs) x = if y = x then z else List.applyId xs x := by
  simp only [list.apply_id, List.lookup, eq_rec_constant, Prod.toSigma, List.map] <;> split_ifs <;>
    rfl
#align
  slim_check.injective_function.list.apply_id_cons SlimCheck.InjectiveFunction.List.apply_id_cons

open Function _Root_.List

open _Root_.Prod (toSigma)

open _Root_.Nat

theorem List.apply_id_zip_eq [DecidableEq α] {xs ys : List α} (h₀ : List.Nodup xs)
    (h₁ : xs.length = ys.length) (x y : α) (i : ℕ) (h₂ : xs.nth i = some x) :
    List.applyId.{u} (xs.zip ys) x = y ↔ ys.nth i = some y :=
  by
  induction xs generalizing ys i
  case nil ys i h₁ h₂ => cases h₂
  case cons x' xs xs_ih ys i h₁ h₂ =>
    cases i
    · injection h₂ with h₀ h₁
      subst h₀
      cases ys
      · cases h₁
      ·
        simp only [list.apply_id, to_sigma, Option.get_or_else_some, nth, lookup_cons_eq,
          zip_cons_cons, List.map]
    · cases ys
      · cases h₁
      · cases' h₀ with _ _ h₀ h₁
        simp only [nth, zip_cons_cons, list.apply_id_cons] at h₂⊢
        rw [if_neg]
        · apply xs_ih <;> solve_by_elim [succ.inj]
        · apply h₀
          apply nth_mem h₂
#align
  slim_check.injective_function.list.apply_id_zip_eq SlimCheck.InjectiveFunction.List.apply_id_zip_eq

/- ./././Mathport/Syntax/Translate/Tactic/Lean3.lean:564:6: unsupported: specialize @hyp -/
theorem apply_id_mem_iff [DecidableEq α] {xs ys : List α} (h₀ : List.Nodup xs) (h₁ : xs ~ ys)
    (x : α) : List.applyId.{u} (xs.zip ys) x ∈ ys ↔ x ∈ xs :=
  by
  simp only [list.apply_id]
  cases h₃ : lookup x (map Prod.toSigma (xs.zip ys))
  · dsimp [Option.getD]
    rw [h₁.mem_iff]
  · have h₂ : ys.nodup := h₁.nodup_iff.1 h₀
    replace h₁ : xs.length = ys.length := h₁.length_eq
    dsimp
    induction xs generalizing ys
    case nil ys h₃ h₂ h₁ => contradiction
    case cons x' xs xs_ih ys h₃ h₂ h₁ =>
      cases' ys with y ys
      · cases h₃
      dsimp [lookup] at h₃; split_ifs  at h₃
      · subst x'
        subst val
        simp only [mem_cons_iff, true_or_iff, eq_self_iff_true]
      · cases' h₀ with _ _ h₀ h₅
        cases' h₂ with _ _ h₂ h₄
        have h₆ := Nat.succ.inj h₁
        specialize xs_ih h₅ ys h₃ h₄ h₆
        simp only [Ne.symm h, xs_ih, mem_cons_iff, false_or_iff]
        suffices : val ∈ ys
        tauto
        erw [← Option.mem_def, mem_lookup_iff] at h₃
        simp only [to_sigma, mem_map, heq_iff_eq, Prod.exists] at h₃
        rcases h₃ with ⟨a, b, h₃, h₄, h₅⟩
        subst a
        subst b
        apply (mem_zip h₃).2
        simp only [nodupkeys, keys, comp, Prod.fst_toSigma, map_map]
        rwa [map_fst_zip _ _ (le_of_eq h₆)]
#align slim_check.injective_function.apply_id_mem_iff SlimCheck.InjectiveFunction.apply_id_mem_iff

theorem List.apply_id_eq_self [DecidableEq α] {xs ys : List α} (x : α) :
    x ∉ xs → List.applyId.{u} (xs.zip ys) x = x :=
  by
  intro h
  dsimp [list.apply_id]
  rw [lookup_eq_none.2]; rfl
  simp only [keys, not_exists, to_sigma, exists_and_right, exists_eq_right, mem_map, comp_app,
    map_map, Prod.exists]
  intro y hy
  exact h (mem_zip hy).1
#align
  slim_check.injective_function.list.apply_id_eq_self SlimCheck.InjectiveFunction.List.apply_id_eq_self

theorem apply_id_injective [DecidableEq α] {xs ys : List α} (h₀ : List.Nodup xs) (h₁ : xs ~ ys) :
    Injective.{u + 1, u + 1} (List.applyId (xs.zip ys)) :=
  by
  intro x y h
  by_cases hx : x ∈ xs <;> by_cases hy : y ∈ xs
  · rw [mem_iff_nth] at hx hy
    cases' hx with i hx
    cases' hy with j hy
    suffices some x = some y by injection this
    have h₂ := h₁.length_eq
    rw [list.apply_id_zip_eq h₀ h₂ _ _ _ hx] at h
    rw [← hx, ← hy]
    congr
    apply nth_injective _ (h₁.nodup_iff.1 h₀)
    · symm
      rw [h]
      rw [← list.apply_id_zip_eq] <;> assumption
    · rw [← h₁.length_eq]
      rw [nth_eq_some] at hx
      cases' hx with hx hx'
      exact hx
  · rw [← apply_id_mem_iff h₀ h₁] at hx hy
    rw [h] at hx
    contradiction
  · rw [← apply_id_mem_iff h₀ h₁] at hx hy
    rw [h] at hx
    contradiction
  · rwa [list.apply_id_eq_self, list.apply_id_eq_self] at h <;> assumption
#align
  slim_check.injective_function.apply_id_injective SlimCheck.InjectiveFunction.apply_id_injective

open TotalFunction (list.to_finmap')

open Sampleable

/-- Remove a slice of length `m` at index `n` in a list and a permutation, maintaining the property
that it is a permutation.
-/
def Perm.slice [DecidableEq α] (n m : ℕ) :
    (Σ'xs ys : List α, xs ~ ys ∧ ys.Nodup) → Σ'xs ys : List α, xs ~ ys ∧ ys.Nodup
  | ⟨xs, ys, h, h'⟩ =>
    let xs' := List.dropSlice n m xs
    have h₀ : xs' ~ ys.inter xs' := Perm.slice_inter _ _ h h'
    ⟨xs', ys.inter xs', h₀, h'.inter _⟩
#align slim_check.injective_function.perm.slice SlimCheck.InjectiveFunction.Perm.slice

/-- A lazy list, in decreasing order, of sizes that should be
sliced off a list of length `n`
-/
def sliceSizes : ℕ → LazyList ℕ+
  | n =>
    if h : 0 < n then
      have : n / 2 < n := div_lt_self h (by decide)
      LazyList.cons ⟨_, h⟩ (slice_sizes <| n / 2)
    else LazyList.nil
#align slim_check.injective_function.slice_sizes SlimCheck.InjectiveFunction.sliceSizes

/-- Shrink a permutation of a list, slicing a segment in the middle.

The sizes of the slice being removed start at `n` (with `n` the length
of the list) and then `n / 2`, then `n / 4`, etc down to 1. The slices
will be taken at index `0`, `n / k`, `2n / k`, `3n / k`, etc.
-/
protected def shrinkPerm {α : Type} [DecidableEq α] [SizeOf α] :
    ShrinkFn (Σ'xs ys : List α, xs ~ ys ∧ ys.Nodup)
  | xs => do
    let k := xs.1.length
    let n ← sliceSizes k
    let i ← LazyList.ofList <| List.finRange <| k / n
    have : ↑i * ↑n < xs.1.length :=
        Nat.lt_of_div_lt_div
          (lt_of_le_of_lt (by simp only [Nat.mul_div_cancel, gt_iff_lt, Fin.val_eq_coe, PNat.pos])
            i.2)
      pure
        ⟨perm.slice (i * n) n xs, by
          rcases xs with ⟨a, b, c, d⟩ <;> dsimp [sizeof_lt] <;> unfold_wf <;>
                simp only [perm.slice] <;>
              unfold_wf <;>
            apply List.sizeof_slice_lt _ _ n.2 _ this⟩
#align slim_check.injective_function.shrink_perm SlimCheck.InjectiveFunction.shrinkPerm

instance [SizeOf α] : SizeOf (InjectiveFunction α) :=
  ⟨fun ⟨xs, _, _⟩ => SizeOf.sizeOf (xs.map Sigma.fst)⟩

/-- Shrink an injective function slicing a segment in the middle of the domain and removing
the corresponding elements in the codomain, hence maintaining the property that
one is a permutation of the other.
-/
protected def shrink {α : Type} [SizeOf α] [DecidableEq α] : ShrinkFn (InjectiveFunction α)
  | ⟨xs, h₀, h₁⟩ => do
    let ⟨⟨xs', ys', h₀, h₁⟩, h₂⟩ ← InjectiveFunction.shrinkPerm ⟨_, _, h₀, h₁⟩
    have h₃ : xs' ≤ ys' := le_of_eq (perm.length_eq h₀)
      have h₄ : ys' ≤ xs' := le_of_eq (perm.length_eq h₀)
      pure
        ⟨⟨(List.zip xs' ys').map Prod.toSigma, by
            simp only [comp, map_fst_zip, map_snd_zip, *, Prod.fst_toSigma, Prod.snd_toSigma,
              map_map],
            by simp only [comp, map_snd_zip, *, Prod.snd_toSigma, map_map]⟩,
          by
          revert h₂ <;> dsimp [sizeof_lt] <;> unfold_wf <;>
                  simp only [has_sizeof._match_1, map_map, comp, map_fst_zip, *,
                    Prod.fst_toSigma] <;>
                unfold_wf <;>
              intro h₂ <;>
            convert h₂⟩
#align slim_check.injective_function.shrink SlimCheck.InjectiveFunction.shrink

/-- Create an injective function from one list and a permutation of that list. -/
protected def mk (xs ys : List α) (h : xs ~ ys) (h' : ys.Nodup) : InjectiveFunction α :=
  have h₀ : xs.length ≤ ys.length := le_of_eq h.length_eq
  have h₁ : ys.length ≤ xs.length := le_of_eq h.length_eq.symm
  InjectiveFunction.map_to_self (List.toFinmap' (xs.zip ys))
    (by
      simp only [list.to_finmap', comp, map_fst_zip, map_snd_zip, *, Prod.fst_toSigma,
        Prod.snd_toSigma, map_map])
    (by simp only [list.to_finmap', comp, map_snd_zip, *, Prod.snd_toSigma, map_map])
#align slim_check.injective_function.mk SlimCheck.InjectiveFunction.mk

protected theorem injective [DecidableEq α] (f : InjectiveFunction α) : Injective (apply f) :=
  by
  cases' f with xs hperm hnodup
  generalize h₀ : map Sigma.fst xs = xs₀
  generalize h₁ : xs.map (@id ((Σ_ : α, α) → α) <| @Sigma.snd α fun _ : α => α) = xs₁
  dsimp [id] at h₁
  have hxs : xs = total_function.list.to_finmap' (xs₀.zip xs₁) :=
    by
    rw [← h₀, ← h₁, list.to_finmap']
    clear h₀ h₁ xs₀ xs₁ hperm hnodup
    induction xs
    case nil => simp only [zip_nil_right, map_nil]
    case
      cons xs_hd xs_tl xs_ih =>
      simp only [true_and_iff, to_sigma, eq_self_iff_true, Sigma.eta, zip_cons_cons, List.map]
      exact xs_ih
  revert hperm hnodup
  rw [hxs]
  intros
  apply apply_id_injective
  · rwa [← h₀, hxs, hperm.nodup_iff]
  · rwa [← hxs, h₀, h₁] at hperm
#align slim_check.injective_function.injective SlimCheck.InjectiveFunction.injective

instance PiInjective.sampleableExt : SampleableExt { f : ℤ → ℤ // Function.Injective f }
    where
  ProxyRepr := InjectiveFunction ℤ
  interp f := ⟨apply f, f.Injective⟩
  sample :=
    gen.sized fun sz => do
      let xs' := Int.range (-(2 * sz + 2)) (2 * sz + 2)
      let ys ← Gen.permutationOf xs'
      have Hinj : injective fun r : ℕ => -(2 * sz + 2 : ℤ) + ↑r := fun x y h =>
          Int.ofNat.inj (add_right_injective _ h)
        let r : injective_function ℤ :=
          InjectiveFunction.mk.{0} xs' ys.1 ys.2 (ys.2.nodup_iff.1 <| (nodup_range _).map Hinj)
        pure r
  shrink := @InjectiveFunction.shrink ℤ _ _
#align
  slim_check.injective_function.pi_injective.sampleable_ext SlimCheck.InjectiveFunction.PiInjective.sampleableExt

end InjectiveFunction

open Function

instance Injective.testable (f : α → β)
    [I :
      Testable
        (NamedBinder "x" <|
          ∀ x : α, NamedBinder "y" <| ∀ y : α, NamedBinder "H" <| f x = f y → x = y)] :
    Testable (Injective f) :=
  I
#align slim_check.injective.testable SlimCheck.Injective.testable

instance Monotone.testable [Preorder α] [Preorder β] (f : α → β)
    [I :
      Testable
        (NamedBinder "x" <|
          ∀ x : α, NamedBinder "y" <| ∀ y : α, NamedBinder "H" <| x ≤ y → f x ≤ f y)] :
    Testable (Monotone f) :=
  I
#align slim_check.monotone.testable SlimCheck.Monotone.testable

instance Antitone.testable [Preorder α] [Preorder β] (f : α → β)
    [I :
      Testable
        (NamedBinder "x" <|
          ∀ x : α, NamedBinder "y" <| ∀ y : α, NamedBinder "H" <| x ≤ y → f y ≤ f x)] :
    Testable (Antitone f) :=
  I
#align slim_check.antitone.testable SlimCheck.Antitone.testable

end SlimCheck

