/-
Copyright (c) 2019 Chris Hughes. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Chris Hughes
-/
import Mathbin.Order.WellFounded
import Mathbin.Algebra.Group.Pi
import Mathbin.Algebra.Order.Group.Basic
import Mathbin.Order.MinMax

/-!
# Lexicographic order on Pi types

This file defines the lexicographic order for Pi types. `a` is less than `b` if `a i = b i` for all
`i` up to some point `k`, and `a k < b k`.

## Notation

* `Πₗ i, α i`: Pi type equipped with the lexicographic order. Type synonym of `Π i, α i`.

## See also

Related files are:
* `data.finset.colex`: Colexicographic order on finite sets.
* `data.list.lex`: Lexicographic order on lists.
* `data.sigma.order`: Lexicographic order on `Σₗ i, α i`.
* `data.psigma.order`: Lexicographic order on `Σₗ' i, α i`.
* `data.prod.lex`: Lexicographic order on `α × β`.
-/


variable {ι : Type _} {β : ι → Type _} (r : ι → ι → Prop) (s : ∀ {i}, β i → β i → Prop)

namespace Pi

instance {α : Type _} : ∀ [Inhabited α], Inhabited (Lex α) :=
  id

/-- The lexicographic relation on `Π i : ι, β i`, where `ι` is ordered by `r`,
  and each `β i` is ordered by `s`. -/
protected def Lex (x y : ∀ i, β i) : Prop :=
  ∃ i, (∀ j, r j i → x j = y j) ∧ s (x i) (y i)

-- mathport name: «exprΠₗ , »
notation3"Πₗ "/- This unfortunately results in a type that isn't delta-reduced, so we keep the notation out of the
basic API, just in case -/
(...)", "r:(scoped p => Lex ∀ i, p i) => r

@[simp]
theorem to_lex_apply (x : ∀ i, β i) (i : ι) : toLex x i = x i :=
  rfl

@[simp]
theorem of_lex_apply (x : Lex (∀ i, β i)) (i : ι) : ofLex x i = x i :=
  rfl

theorem lex_lt_of_lt_of_preorder [∀ i, Preorder (β i)] {r} (hwf : WellFounded r) {x y : ∀ i, β i} (hlt : x < y) :
    ∃ i, (∀ j, r j i → x j ≤ y j ∧ y j ≤ x j) ∧ x i < y i :=
  let h' := Pi.lt_def.1 hlt
  let ⟨i, hi, hl⟩ := hwf.has_min _ h'.2
  ⟨i, fun j hj => ⟨h'.1 j, not_not.1 fun h => hl j (lt_of_le_not_le (h'.1 j) h) hj⟩, hi⟩

theorem lex_lt_of_lt [∀ i, PartialOrder (β i)] {r} (hwf : WellFounded r) {x y : ∀ i, β i} (hlt : x < y) :
    Pi.Lex r (fun i => (· < ·)) x y := by
  simp_rw [Pi.Lex, le_antisymm_iff]
  exact lex_lt_of_lt_of_preorder hwf hlt

theorem is_trichotomous_lex [∀ i, IsTrichotomous (β i) s] (wf : WellFounded r) :
    IsTrichotomous (∀ i, β i) (Pi.Lex r @s) :=
  { trichotomous := fun a b => by
      cases' eq_or_ne a b with hab hab
      · exact Or.inr (Or.inl hab)
        
      · rw [Function.ne_iff] at hab
        let i := wf.min _ hab
        have hri : ∀ j, r j i → a j = b j := by
          intro j
          rw [← not_imp_not]
          exact fun h' => wf.not_lt_min _ _ h'
        have hne : a i ≠ b i := wf.min_mem _ hab
        cases' trichotomous_of s (a i) (b i) with hi hi
        exacts[Or.inl ⟨i, hri, hi⟩, Or.inr <| Or.inr <| ⟨i, fun j hj => (hri j hj).symm, hi.resolve_left hne⟩]
         }

instance [LT ι] [∀ a, LT (β a)] : LT (Lex (∀ i, β i)) :=
  ⟨Pi.Lex (· < ·) fun _ => (· < ·)⟩

instance Lex.is_strict_order [LinearOrder ι] [∀ a, PartialOrder (β a)] : IsStrictOrder (Lex (∀ i, β i)) (· < ·) where
  irrefl := fun a ⟨k, hk₁, hk₂⟩ => lt_irrefl (a k) hk₂
  trans := by
    rintro a b c ⟨N₁, lt_N₁, a_lt_b⟩ ⟨N₂, lt_N₂, b_lt_c⟩
    rcases lt_trichotomy N₁ N₂ with (H | rfl | H)
    exacts[⟨N₁, fun j hj => (lt_N₁ _ hj).trans (lt_N₂ _ <| hj.trans H), lt_N₂ _ H ▸ a_lt_b⟩,
      ⟨N₁, fun j hj => (lt_N₁ _ hj).trans (lt_N₂ _ hj), a_lt_b.trans b_lt_c⟩,
      ⟨N₂, fun j hj => (lt_N₁ _ (hj.trans H)).trans (lt_N₂ _ hj), (lt_N₁ _ H).symm ▸ b_lt_c⟩]

instance [LinearOrder ι] [∀ a, PartialOrder (β a)] : PartialOrder (Lex (∀ i, β i)) :=
  partialOrderOfSO (· < ·)

/-- `Πₗ i, α i` is a linear order if the original order is well-founded. -/
noncomputable instance [LinearOrder ι] [IsWellOrder ι (· < ·)] [∀ a, LinearOrder (β a)] :
    LinearOrder (Lex (∀ i, β i)) :=
  @linearOrderOfSTO (Πₗ i, β i) (· < ·) { to_is_trichotomous := is_trichotomous_lex _ _ IsWellFounded.wf }
    (Classical.decRel _)

theorem to_lex_monotone [LinearOrder ι] [IsWellOrder ι (· < ·)] [∀ a, PartialOrder (β a)] :
    Monotone (@toLex (∀ i, β i)) := fun a b h =>
  or_iff_not_imp_left.2 fun hne =>
    let ⟨i, hi, hl⟩ := IsWellFounded.wf.has_min { i | a i ≠ b i } (Function.ne_iff.1 hne)
    ⟨i, fun j hj => by
      contrapose! hl
      exact ⟨j, hl, hj⟩, (h i).lt_of_ne hi⟩

instance [LinearOrder ι] [IsWellOrder ι (· < ·)] [∀ a, PartialOrder (β a)] [∀ a, OrderBot (β a)] :
    OrderBot (Lex (∀ a, β a)) where
  bot := toLex ⊥
  bot_le f := to_lex_monotone bot_le

instance [LinearOrder ι] [IsWellOrder ι (· < ·)] [∀ a, PartialOrder (β a)] [∀ a, OrderTop (β a)] :
    OrderTop (Lex (∀ a, β a)) where
  top := toLex ⊤
  le_top f := to_lex_monotone le_top

instance [LinearOrder ι] [IsWellOrder ι (· < ·)] [∀ a, PartialOrder (β a)] [∀ a, BoundedOrder (β a)] :
    BoundedOrder (Lex (∀ a, β a)) :=
  { Pi.Lex.orderBot, Pi.Lex.orderTop with }

--we might want the analog of `pi.ordered_cancel_comm_monoid` as well in the future
@[to_additive]
instance Lex.orderedCommGroup [LinearOrder ι] [∀ a, OrderedCommGroup (β a)] : OrderedCommGroup (Lex (∀ i, β i)) :=
  { Pi.Lex.partialOrder, Pi.commGroup with
    mul_le_mul_left := fun x y hxy z =>
      hxy.elim (fun hxyz => hxyz ▸ le_rfl) fun ⟨i, hi⟩ =>
        Or.inr ⟨i, fun j hji => show z j * x j = z j * y j by rw [hi.1 j hji], mul_lt_mul_left' hi.2 _⟩ }

/-- If we swap two strictly decreasing values in a function, then the result is lexicographically
smaller than the original function. -/
theorem lex_desc {α} [Preorder ι] [DecidableEq ι] [Preorder α] {f : ι → α} {i j : ι} (h₁ : i < j) (h₂ : f j < f i) :
    toLex (f ∘ Equiv.swap i j) < toLex f :=
  ⟨i, fun k hik => congr_arg f (Equiv.swap_apply_of_ne_of_ne hik.Ne (hik.trans h₁).Ne), by
    simpa only [Pi.to_lex_apply, Function.comp_app, Equiv.swap_apply_left] using h₂⟩

end Pi

