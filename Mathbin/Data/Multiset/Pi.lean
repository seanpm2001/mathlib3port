/-
Copyright (c) 2018 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl

! This file was ported from Lean 3 source module data.multiset.pi
! leanprover-community/mathlib commit b2c89893177f66a48daf993b7ba5ef7cddeff8c9
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Multiset.Nodup

/-!
# The cartesian product of multisets

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.
-/


namespace Multiset

section Pi

variable {α : Type _}

open Function

#print Multiset.Pi.empty /-
/-- Given `δ : α → Type*`, `pi.empty δ` is the trivial dependent function out of the empty
multiset. -/
def Pi.empty (δ : α → Sort _) : ∀ a ∈ (0 : Multiset α), δ a :=
  fun.
#align multiset.pi.empty Multiset.Pi.empty
-/

variable [DecidableEq α] {β : α → Type _} {δ : α → Sort _}

#print Multiset.Pi.cons /-
/-- Given `δ : α → Type*`, a multiset `m` and a term `a`, as well as a term `b : δ a` and a
function `f` such that `f a' : δ a'` for all `a'` in `m`, `pi.cons m a b f` is a function `g` such
that `g a'' : δ a''` for all `a''` in `a ::ₘ m`. -/
def Pi.cons (m : Multiset α) (a : α) (b : δ a) (f : ∀ a ∈ m, δ a) : ∀ a' ∈ a ::ₘ m, δ a' :=
  fun a' ha' => if h : a' = a then Eq.ndrec b h.symm else f a' <| (mem_cons.1 ha').resolve_left h
#align multiset.pi.cons Multiset.Pi.cons
-/

#print Multiset.Pi.cons_same /-
theorem Pi.cons_same {m : Multiset α} {a : α} {b : δ a} {f : ∀ a ∈ m, δ a} (h : a ∈ a ::ₘ m) :
    Pi.cons m a b f a h = b :=
  dif_pos rfl
#align multiset.pi.cons_same Multiset.Pi.cons_same
-/

#print Multiset.Pi.cons_ne /-
theorem Pi.cons_ne {m : Multiset α} {a a' : α} {b : δ a} {f : ∀ a ∈ m, δ a} (h' : a' ∈ a ::ₘ m)
    (h : a' ≠ a) : Pi.cons m a b f a' h' = f a' ((mem_cons.1 h').resolve_left h) :=
  dif_neg h
#align multiset.pi.cons_ne Multiset.Pi.cons_ne
-/

#print Multiset.Pi.cons_swap /-
theorem Pi.cons_swap {a a' : α} {b : δ a} {b' : δ a'} {m : Multiset α} {f : ∀ a ∈ m, δ a}
    (h : a ≠ a') :
    HEq (Pi.cons (a' ::ₘ m) a b (Pi.cons m a' b' f)) (Pi.cons (a ::ₘ m) a' b' (Pi.cons m a b f)) :=
  by
  apply hfunext rfl
  rintro a'' _ rfl
  refine' hfunext (by rw [cons_swap]) fun ha₁ ha₂ _ => _
  rcases ne_or_eq a'' a with (h₁ | rfl)
  rcases eq_or_ne a'' a' with (rfl | h₂)
  all_goals simp [*, pi.cons_same, pi.cons_ne]
#align multiset.pi.cons_swap Multiset.Pi.cons_swap
-/

#print Multiset.pi.cons_eta /-
@[simp]
theorem pi.cons_eta {m : Multiset α} {a : α} (f : ∀ a' ∈ a ::ₘ m, δ a') :
    (Pi.cons m a (f _ (mem_cons_self _ _)) fun a' ha' => f a' (mem_cons_of_mem ha')) = f :=
  by
  ext a' h'
  by_cases a' = a
  · subst h; rw [pi.cons_same]
  · rw [pi.cons_ne _ h]
#align multiset.pi.cons_eta Multiset.pi.cons_eta
-/

#print Multiset.Pi.cons_injective /-
theorem Pi.cons_injective {a : α} {b : δ a} {s : Multiset α} (hs : a ∉ s) :
    Function.Injective (Pi.cons s a b) := fun f₁ f₂ eq =>
  funext fun a' =>
    funext fun h' =>
      have ne : a ≠ a' := fun h => hs <| h.symm ▸ h'
      have : a' ∈ a ::ₘ s := mem_cons_of_mem h'
      calc
        f₁ a' h' = Pi.cons s a b f₁ a' this := by rw [pi.cons_ne this Ne.symm]
        _ = Pi.cons s a b f₂ a' this := by rw [Eq]
        _ = f₂ a' h' := by rw [pi.cons_ne this Ne.symm]
#align multiset.pi.cons_injective Multiset.Pi.cons_injective
-/

#print Multiset.pi /-
/-- `pi m t` constructs the Cartesian product over `t` indexed by `m`. -/
def pi (m : Multiset α) (t : ∀ a, Multiset (β a)) : Multiset (∀ a ∈ m, β a) :=
  m.recOn {Pi.empty β}
    (fun a m (p : Multiset (∀ a ∈ m, β a)) => (t a).bind fun b => p.map <| Pi.cons m a b)
    (by
      intro a a' m n
      by_cases eq : a = a'
      · subst Eq
      · simp [map_bind, bind_bind (t a') (t a)]
        apply bind_hcongr; · rw [cons_swap a a']
        intro b hb
        apply bind_hcongr; · rw [cons_swap a a']
        intro b' hb'
        apply map_hcongr; · rw [cons_swap a a']
        intro f hf
        exact pi.cons_swap Eq)
#align multiset.pi Multiset.pi
-/

#print Multiset.pi_zero /-
@[simp]
theorem pi_zero (t : ∀ a, Multiset (β a)) : pi 0 t = {Pi.empty β} :=
  rfl
#align multiset.pi_zero Multiset.pi_zero
-/

#print Multiset.pi_cons /-
@[simp]
theorem pi_cons (m : Multiset α) (t : ∀ a, Multiset (β a)) (a : α) :
    pi (a ::ₘ m) t = (t a).bind fun b => (pi m t).map <| Pi.cons m a b :=
  recOn_cons a m
#align multiset.pi_cons Multiset.pi_cons
-/

#print Multiset.card_pi /-
theorem card_pi (m : Multiset α) (t : ∀ a, Multiset (β a)) :
    card (pi m t) = prod (m.map fun a => card (t a)) :=
  Multiset.induction_on m (by simp) (by simp (config := { contextual := true }) [mul_comm])
#align multiset.card_pi Multiset.card_pi
-/

#print Multiset.Nodup.pi /-
protected theorem Nodup.pi {s : Multiset α} {t : ∀ a, Multiset (β a)} :
    Nodup s → (∀ a ∈ s, Nodup (t a)) → Nodup (pi s t) :=
  Multiset.induction_on s (fun _ _ => nodup_singleton _)
    (by
      intro a s ih hs ht
      have has : a ∉ s := by simp at hs  <;> exact hs.1
      have hs : nodup s := by simp at hs  <;> exact hs.2
      simp
      refine'
        ⟨fun b hb => (ih hs fun a' h' => ht a' <| mem_cons_of_mem h').map (pi.cons_injective has),
          _⟩
      refine' (ht a <| mem_cons_self _ _).Pairwise _
      exact fun b₁ hb₁ b₂ hb₂ neb =>
        disjoint_map_map.2 fun f hf g hg eq =>
          have : pi.cons s a b₁ f a (mem_cons_self _ _) = pi.cons s a b₂ g a (mem_cons_self _ _) :=
            by rw [Eq]
          neb <| show b₁ = b₂ by rwa [pi.cons_same, pi.cons_same] at this )
#align multiset.nodup.pi Multiset.Nodup.pi
-/

#print Multiset.mem_pi /-
theorem mem_pi (m : Multiset α) (t : ∀ a, Multiset (β a)) :
    ∀ f : ∀ a ∈ m, β a, f ∈ pi m t ↔ ∀ (a) (h : a ∈ m), f a h ∈ t a :=
  by
  intro f
  induction' m using Multiset.induction_on with a m ih
  · simpa using show f = pi.empty β by funext a ha <;> exact ha.elim
  simp_rw [pi_cons, mem_bind, mem_map, ih]
  constructor
  · rintro ⟨b, hb, f', hf', rfl⟩ a' ha'
    by_cases a' = a
    · subst h; rwa [pi.cons_same]
    · rw [pi.cons_ne _ h]; apply hf'
  · intro hf
    refine' ⟨_, hf a (mem_cons_self _ _), _, fun a ha => hf a (mem_cons_of_mem ha), _⟩
    rw [pi.cons_eta]
#align multiset.mem_pi Multiset.mem_pi
-/

end Pi

end Multiset

