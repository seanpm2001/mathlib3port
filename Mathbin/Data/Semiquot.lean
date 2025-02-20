/-
Copyright (c) 2018 Mario Carneiro. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Mario Carneiro

! This file was ported from Lean 3 source module data.semiquot
! leanprover-community/mathlib commit c3291da49cfa65f0d43b094750541c0731edc932
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Set.Lattice

/-! # Semiquotients

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

A data type for semiquotients, which are classically equivalent to
nonempty sets, but are useful for programming; the idea is that
a semiquotient set `S` represents some (particular but unknown)
element of `S`. This can be used to model nondeterministic functions,
which return something in a range of values (represented by the
predicate `S`) but are not completely determined.
-/


/-- A member of `semiquot α` is classically a nonempty `set α`,
  and in the VM is represented by an element of `α`; the relation
  between these is that the VM element is required to be a member
  of the set `s`. The specific element of `s` that the VM computes
  is hidden by a quotient construction, allowing for the representation
  of nondeterministic functions. -/
structure Semiquot.{u} (α : Type _) where mk' ::
  s : Set α
  val : Trunc ↥s
#align semiquot Semiquotₓ

namespace Semiquot

variable {α : Type _} {β : Type _}

instance : Membership α (Semiquot α) :=
  ⟨fun a q => a ∈ q.s⟩

#print Semiquot.mk /-
/-- Construct a `semiquot α` from `h : a ∈ s` where `s : set α`. -/
def mk {a : α} {s : Set α} (h : a ∈ s) : Semiquot α :=
  ⟨s, Trunc.mk ⟨a, h⟩⟩
#align semiquot.mk Semiquot.mk
-/

#print Semiquot.ext_s /-
theorem ext_s {q₁ q₂ : Semiquot α} : q₁ = q₂ ↔ q₁.s = q₂.s :=
  by
  refine' ⟨congr_arg _, fun h => _⟩
  cases q₁
  cases q₂
  cc
#align semiquot.ext_s Semiquot.ext_s
-/

#print Semiquot.ext /-
theorem ext {q₁ q₂ : Semiquot α} : q₁ = q₂ ↔ ∀ a, a ∈ q₁ ↔ a ∈ q₂ :=
  ext_s.trans Set.ext_iff
#align semiquot.ext Semiquot.ext
-/

#print Semiquot.exists_mem /-
theorem exists_mem (q : Semiquot α) : ∃ a, a ∈ q :=
  let ⟨⟨a, h⟩, h₂⟩ := q.2.exists_rep
  ⟨a, h⟩
#align semiquot.exists_mem Semiquot.exists_mem
-/

#print Semiquot.eq_mk_of_mem /-
theorem eq_mk_of_mem {q : Semiquot α} {a : α} (h : a ∈ q) : q = @mk _ a q.1 h :=
  ext_s.2 rfl
#align semiquot.eq_mk_of_mem Semiquot.eq_mk_of_mem
-/

#print Semiquot.nonempty /-
theorem nonempty (q : Semiquot α) : q.s.Nonempty :=
  q.exists_mem
#align semiquot.nonempty Semiquot.nonempty
-/

#print Semiquot.pure /-
/-- `pure a` is `a` reinterpreted as an unspecified element of `{a}`. -/
protected def pure (a : α) : Semiquot α :=
  mk (Set.mem_singleton a)
#align semiquot.pure Semiquot.pure
-/

#print Semiquot.mem_pure' /-
@[simp]
theorem mem_pure' {a b : α} : a ∈ Semiquot.pure b ↔ a = b :=
  Set.mem_singleton_iff
#align semiquot.mem_pure' Semiquot.mem_pure'
-/

#print Semiquot.blur' /-
/-- Replace `s` in a `semiquot` with a superset. -/
def blur' (q : Semiquot α) {s : Set α} (h : q.s ⊆ s) : Semiquot α :=
  ⟨s, Trunc.lift (fun a : q.s => Trunc.mk ⟨a.1, h a.2⟩) (fun _ _ => Trunc.eq _ _) q.2⟩
#align semiquot.blur' Semiquot.blur'
-/

#print Semiquot.blur /-
/-- Replace `s` in a `q : semiquot α` with a union `s ∪ q.s` -/
def blur (s : Set α) (q : Semiquot α) : Semiquot α :=
  blur' q (Set.subset_union_right s q.s)
#align semiquot.blur Semiquot.blur
-/

#print Semiquot.blur_eq_blur' /-
theorem blur_eq_blur' (q : Semiquot α) (s : Set α) (h : q.s ⊆ s) : blur s q = blur' q h := by
  unfold blur <;> congr <;> exact Set.union_eq_self_of_subset_right h
#align semiquot.blur_eq_blur' Semiquot.blur_eq_blur'
-/

#print Semiquot.mem_blur' /-
@[simp]
theorem mem_blur' (q : Semiquot α) {s : Set α} (h : q.s ⊆ s) {a : α} : a ∈ blur' q h ↔ a ∈ s :=
  Iff.rfl
#align semiquot.mem_blur' Semiquot.mem_blur'
-/

#print Semiquot.ofTrunc /-
/-- Convert a `trunc α` to a `semiquot α`. -/
def ofTrunc (q : Trunc α) : Semiquot α :=
  ⟨Set.univ, q.map fun a => ⟨a, trivial⟩⟩
#align semiquot.of_trunc Semiquot.ofTrunc
-/

#print Semiquot.toTrunc /-
/-- Convert a `semiquot α` to a `trunc α`. -/
def toTrunc (q : Semiquot α) : Trunc α :=
  q.2.map Subtype.val
#align semiquot.to_trunc Semiquot.toTrunc
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (a b «expr ∈ » q) -/
#print Semiquot.liftOn /-
/-- If `f` is a constant on `q.s`, then `q.lift_on f` is the value of `f`
at any point of `q`. -/
def liftOn (q : Semiquot α) (f : α → β) (h : ∀ (a) (_ : a ∈ q) (b) (_ : b ∈ q), f a = f b) : β :=
  Trunc.liftOn q.2 (fun x => f x.1) fun x y => h _ x.2 _ y.2
#align semiquot.lift_on Semiquot.liftOn
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (a b «expr ∈ » q) -/
#print Semiquot.liftOn_ofMem /-
theorem liftOn_ofMem (q : Semiquot α) (f : α → β) (h : ∀ (a) (_ : a ∈ q) (b) (_ : b ∈ q), f a = f b)
    (a : α) (aq : a ∈ q) : liftOn q f h = f a := by
  revert h <;> rw [eq_mk_of_mem aq] <;> intro <;> rfl
#align semiquot.lift_on_of_mem Semiquot.liftOn_ofMem
-/

#print Semiquot.map /-
/-- Apply a function to the unknown value stored in a `semiquot α`. -/
def map (f : α → β) (q : Semiquot α) : Semiquot β :=
  ⟨f '' q.1, q.2.map fun x => ⟨f x.1, Set.mem_image_of_mem _ x.2⟩⟩
#align semiquot.map Semiquot.map
-/

#print Semiquot.mem_map /-
@[simp]
theorem mem_map (f : α → β) (q : Semiquot α) (b : β) : b ∈ map f q ↔ ∃ a, a ∈ q ∧ f a = b :=
  Set.mem_image _ _ _
#align semiquot.mem_map Semiquot.mem_map
-/

#print Semiquot.bind /-
/-- Apply a function returning a `semiquot` to a `semiquot`. -/
def bind (q : Semiquot α) (f : α → Semiquot β) : Semiquot β :=
  ⟨⋃ a ∈ q.1, (f a).1, q.2.bind fun a => (f a.1).2.map fun b => ⟨b.1, Set.mem_biUnion a.2 b.2⟩⟩
#align semiquot.bind Semiquot.bind
-/

#print Semiquot.mem_bind /-
@[simp]
theorem mem_bind (q : Semiquot α) (f : α → Semiquot β) (b : β) : b ∈ bind q f ↔ ∃ a ∈ q, b ∈ f a :=
  Set.mem_iUnion₂
#align semiquot.mem_bind Semiquot.mem_bind
-/

instance : Monad Semiquot where
  pure := @Semiquot.pure
  map := @Semiquot.map
  bind := @Semiquot.bind

#print Semiquot.map_def /-
@[simp]
theorem map_def {β} : ((· <$> ·) : (α → β) → Semiquot α → Semiquot β) = map :=
  rfl
#align semiquot.map_def Semiquot.map_def
-/

#print Semiquot.bind_def /-
@[simp]
theorem bind_def {β} : ((· >>= ·) : Semiquot α → (α → Semiquot β) → Semiquot β) = bind :=
  rfl
#align semiquot.bind_def Semiquot.bind_def
-/

#print Semiquot.mem_pure /-
@[simp]
theorem mem_pure {a b : α} : a ∈ (pure b : Semiquot α) ↔ a = b :=
  Set.mem_singleton_iff
#align semiquot.mem_pure Semiquot.mem_pure
-/

#print Semiquot.mem_pure_self /-
theorem mem_pure_self (a : α) : a ∈ (pure a : Semiquot α) :=
  Set.mem_singleton a
#align semiquot.mem_pure_self Semiquot.mem_pure_self
-/

#print Semiquot.pure_inj /-
@[simp]
theorem pure_inj {a b : α} : (pure a : Semiquot α) = pure b ↔ a = b :=
  ext_s.trans Set.singleton_eq_singleton_iff
#align semiquot.pure_inj Semiquot.pure_inj
-/

instance : LawfulMonad Semiquot
    where
  pure_bind α β x f := ext.2 <| by simp
  bind_assoc α β γ s f g :=
    ext.2 <| by
      simp <;>
        exact fun c =>
          ⟨fun ⟨b, ⟨a, as, bf⟩, cg⟩ => ⟨a, as, b, bf, cg⟩, fun ⟨a, as, b, bf, cg⟩ =>
            ⟨b, ⟨a, as, bf⟩, cg⟩⟩
  id_map α q := ext.2 <| by simp
  bind_pure_comp α β f s := ext.2 <| by simp [eq_comm]

instance : LE (Semiquot α) :=
  ⟨fun s t => s.s ⊆ t.s⟩

instance : PartialOrder (Semiquot α)
    where
  le s t := ∀ ⦃x⦄, x ∈ s → x ∈ t
  le_refl s := Set.Subset.refl _
  le_trans s t u := Set.Subset.trans
  le_antisymm s t h₁ h₂ := ext_s.2 (Set.Subset.antisymm h₁ h₂)

instance : SemilatticeSup (Semiquot α) :=
  { Semiquot.partialOrder with
    sup := fun s => blur s.s
    le_sup_left := fun s t => Set.subset_union_left _ _
    le_sup_right := fun s t => Set.subset_union_right _ _
    sup_le := fun s t u => Set.union_subset }

#print Semiquot.pure_le /-
@[simp]
theorem pure_le {a : α} {s : Semiquot α} : pure a ≤ s ↔ a ∈ s :=
  Set.singleton_subset_iff
#align semiquot.pure_le Semiquot.pure_le
-/

/- ./././Mathport/Syntax/Translate/Basic.lean:638:2: warning: expanding binder collection (a b «expr ∈ » q) -/
#print Semiquot.IsPure /-
/-- Assert that a `semiquot` contains only one possible value. -/
def IsPure (q : Semiquot α) : Prop :=
  ∀ (a) (_ : a ∈ q) (b) (_ : b ∈ q), a = b
#align semiquot.is_pure Semiquot.IsPure
-/

#print Semiquot.get /-
/-- Extract the value from a `is_pure` semiquotient. -/
def get (q : Semiquot α) (h : q.IsPure) : α :=
  liftOn q id h
#align semiquot.get Semiquot.get
-/

#print Semiquot.get_mem /-
theorem get_mem {q : Semiquot α} (p) : get q p ∈ q :=
  by
  let ⟨a, h⟩ := exists_mem q
  unfold get <;> rw [lift_on_of_mem q _ _ a h] <;> exact h
#align semiquot.get_mem Semiquot.get_mem
-/

#print Semiquot.eq_pure /-
theorem eq_pure {q : Semiquot α} (p) : q = pure (get q p) :=
  ext.2 fun a => by simp <;> exact ⟨fun h => p _ h _ (get_mem _), fun e => e.symm ▸ get_mem _⟩
#align semiquot.eq_pure Semiquot.eq_pure
-/

#print Semiquot.pure_isPure /-
@[simp]
theorem pure_isPure (a : α) : IsPure (pure a)
  | b, ab, c, ac => by rw [mem_pure] at ab ac ; cc
#align semiquot.pure_is_pure Semiquot.pure_isPure
-/

#print Semiquot.isPure_iff /-
theorem isPure_iff {s : Semiquot α} : IsPure s ↔ ∃ a, s = pure a :=
  ⟨fun h => ⟨_, eq_pure h⟩, fun ⟨a, e⟩ => e.symm ▸ pure_isPure _⟩
#align semiquot.is_pure_iff Semiquot.isPure_iff
-/

#print Semiquot.IsPure.mono /-
theorem IsPure.mono {s t : Semiquot α} (st : s ≤ t) (h : IsPure t) : IsPure s
  | a, as, b, bs => h _ (st as) _ (st bs)
#align semiquot.is_pure.mono Semiquot.IsPure.mono
-/

#print Semiquot.IsPure.min /-
theorem IsPure.min {s t : Semiquot α} (h : IsPure t) : s ≤ t ↔ s = t :=
  ⟨fun st =>
    le_antisymm st <| by
      rw [eq_pure h, eq_pure (h.mono st)] <;> simp <;> exact h _ (get_mem _) _ (st <| get_mem _),
    le_of_eq⟩
#align semiquot.is_pure.min Semiquot.IsPure.min
-/

#print Semiquot.isPure_of_subsingleton /-
theorem isPure_of_subsingleton [Subsingleton α] (q : Semiquot α) : IsPure q
  | a, b, aq, bq => Subsingleton.elim _ _
#align semiquot.is_pure_of_subsingleton Semiquot.isPure_of_subsingleton
-/

#print Semiquot.univ /-
/-- `univ : semiquot α` represents an unspecified element of `univ : set α`. -/
def univ [Inhabited α] : Semiquot α :=
  mk <| Set.mem_univ default
#align semiquot.univ Semiquot.univ
-/

instance [Inhabited α] : Inhabited (Semiquot α) :=
  ⟨univ⟩

#print Semiquot.mem_univ /-
@[simp]
theorem mem_univ [Inhabited α] : ∀ a, a ∈ @univ α _ :=
  @Set.mem_univ α
#align semiquot.mem_univ Semiquot.mem_univ
-/

#print Semiquot.univ_unique /-
@[congr]
theorem univ_unique (I J : Inhabited α) : @univ _ I = @univ _ J :=
  ext.2 <| by simp
#align semiquot.univ_unique Semiquot.univ_unique
-/

#print Semiquot.isPure_univ /-
@[simp]
theorem isPure_univ [Inhabited α] : @IsPure α univ ↔ Subsingleton α :=
  ⟨fun h => ⟨fun a b => h a trivial b trivial⟩, fun ⟨h⟩ a _ b _ => h a b⟩
#align semiquot.is_pure_univ Semiquot.isPure_univ
-/

instance [Inhabited α] : OrderTop (Semiquot α)
    where
  top := univ
  le_top s := Set.subset_univ _

end Semiquot

