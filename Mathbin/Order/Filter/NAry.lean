/-
Copyright (c) 2022 Yaël Dillies. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yaël Dillies

! This file was ported from Lean 3 source module order.filter.n_ary
! leanprover-community/mathlib commit 78f647f8517f021d839a7553d5dc97e79b508dea
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Order.Filter.Prod

/-!
# N-ary maps of filter

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

This file defines the binary and ternary maps of filters. This is mostly useful to define pointwise
operations on filters.

## Main declarations

* `filter.map₂`: Binary map of filters.
* `filter.map₃`: Ternary map of filters.

## Notes

This file is very similar to `data.set.n_ary`, `data.finset.n_ary` and `data.option.n_ary`. Please
keep them in sync.
-/


open Function Set

open scoped Filter

namespace Filter

variable {α α' β β' γ γ' δ δ' ε ε' : Type _} {m : α → β → γ} {f f₁ f₂ : Filter α}
  {g g₁ g₂ : Filter β} {h h₁ h₂ : Filter γ} {s s₁ s₂ : Set α} {t t₁ t₂ : Set β} {u : Set γ}
  {v : Set δ} {a : α} {b : β} {c : γ}

#print Filter.map₂ /-
/-- The image of a binary function `m : α → β → γ` as a function `filter α → filter β → filter γ`.
Mathematically this should be thought of as the image of the corresponding function `α × β → γ`. -/
def map₂ (m : α → β → γ) (f : Filter α) (g : Filter β) : Filter γ
    where
  sets := {s | ∃ u v, u ∈ f ∧ v ∈ g ∧ image2 m u v ⊆ s}
  univ_sets := ⟨univ, univ, univ_sets _, univ_sets _, subset_univ _⟩
  sets_of_superset s t hs hst :=
    Exists₂.imp (fun u v => And.imp_right <| And.imp_right fun h => Subset.trans h hst) hs
  inter_sets s t := by
    simp only [exists_prop, mem_set_of_eq, subset_inter_iff]
    rintro ⟨s₁, s₂, hs₁, hs₂, hs⟩ ⟨t₁, t₂, ht₁, ht₂, ht⟩
    exact
      ⟨s₁ ∩ t₁, s₂ ∩ t₂, inter_sets f hs₁ ht₁, inter_sets g hs₂ ht₂,
        (image2_subset (inter_subset_left _ _) <| inter_subset_left _ _).trans hs,
        (image2_subset (inter_subset_right _ _) <| inter_subset_right _ _).trans ht⟩
#align filter.map₂ Filter.map₂
-/

#print Filter.mem_map₂_iff /-
@[simp]
theorem mem_map₂_iff : u ∈ map₂ m f g ↔ ∃ s t, s ∈ f ∧ t ∈ g ∧ image2 m s t ⊆ u :=
  Iff.rfl
#align filter.mem_map₂_iff Filter.mem_map₂_iff
-/

#print Filter.image2_mem_map₂ /-
theorem image2_mem_map₂ (hs : s ∈ f) (ht : t ∈ g) : image2 m s t ∈ map₂ m f g :=
  ⟨_, _, hs, ht, Subset.rfl⟩
#align filter.image2_mem_map₂ Filter.image2_mem_map₂
-/

#print Filter.map_prod_eq_map₂ /-
theorem map_prod_eq_map₂ (m : α → β → γ) (f : Filter α) (g : Filter β) :
    Filter.map (fun p : α × β => m p.1 p.2) (f ×ᶠ g) = map₂ m f g :=
  by
  ext s
  simp [mem_prod_iff, prod_subset_iff]
#align filter.map_prod_eq_map₂ Filter.map_prod_eq_map₂
-/

#print Filter.map_prod_eq_map₂' /-
theorem map_prod_eq_map₂' (m : α × β → γ) (f : Filter α) (g : Filter β) :
    Filter.map m (f ×ᶠ g) = map₂ (fun a b => m (a, b)) f g :=
  (congr_arg₂ _ (uncurry_curry m).symm rfl).trans (map_prod_eq_map₂ _ _ _)
#align filter.map_prod_eq_map₂' Filter.map_prod_eq_map₂'
-/

#print Filter.map₂_mk_eq_prod /-
@[simp]
theorem map₂_mk_eq_prod (f : Filter α) (g : Filter β) : map₂ Prod.mk f g = f ×ᶠ g := by
  simp only [← map_prod_eq_map₂, Prod.mk.eta, map_id']
#align filter.map₂_mk_eq_prod Filter.map₂_mk_eq_prod
-/

#print Filter.map₂_mono /-
-- lemma image2_mem_map₂_iff (hm : injective2 m) : image2 m s t ∈ map₂ m f g ↔ s ∈ f ∧ t ∈ g :=
-- ⟨by { rintro ⟨u, v, hu, hv, h⟩, rw image2_subset_image2_iff hm at h,
--   exact ⟨mem_of_superset hu h.1, mem_of_superset hv h.2⟩ }, λ h, image2_mem_map₂ h.1 h.2⟩
theorem map₂_mono (hf : f₁ ≤ f₂) (hg : g₁ ≤ g₂) : map₂ m f₁ g₁ ≤ map₂ m f₂ g₂ :=
  fun _ ⟨s, t, hs, ht, hst⟩ => ⟨s, t, hf hs, hg ht, hst⟩
#align filter.map₂_mono Filter.map₂_mono
-/

#print Filter.map₂_mono_left /-
theorem map₂_mono_left (h : g₁ ≤ g₂) : map₂ m f g₁ ≤ map₂ m f g₂ :=
  map₂_mono Subset.rfl h
#align filter.map₂_mono_left Filter.map₂_mono_left
-/

#print Filter.map₂_mono_right /-
theorem map₂_mono_right (h : f₁ ≤ f₂) : map₂ m f₁ g ≤ map₂ m f₂ g :=
  map₂_mono h Subset.rfl
#align filter.map₂_mono_right Filter.map₂_mono_right
-/

#print Filter.le_map₂_iff /-
@[simp]
theorem le_map₂_iff {h : Filter γ} :
    h ≤ map₂ m f g ↔ ∀ ⦃s⦄, s ∈ f → ∀ ⦃t⦄, t ∈ g → image2 m s t ∈ h :=
  ⟨fun H s hs t ht => H <| image2_mem_map₂ hs ht, fun H u ⟨s, t, hs, ht, hu⟩ =>
    mem_of_superset (H hs ht) hu⟩
#align filter.le_map₂_iff Filter.le_map₂_iff
-/

#print Filter.map₂_bot_left /-
@[simp]
theorem map₂_bot_left : map₂ m ⊥ g = ⊥ :=
  empty_mem_iff_bot.1 ⟨∅, univ, trivial, univ_mem, image2_empty_left.Subset⟩
#align filter.map₂_bot_left Filter.map₂_bot_left
-/

#print Filter.map₂_bot_right /-
@[simp]
theorem map₂_bot_right : map₂ m f ⊥ = ⊥ :=
  empty_mem_iff_bot.1 ⟨univ, ∅, univ_mem, trivial, image2_empty_right.Subset⟩
#align filter.map₂_bot_right Filter.map₂_bot_right
-/

#print Filter.map₂_eq_bot_iff /-
@[simp]
theorem map₂_eq_bot_iff : map₂ m f g = ⊥ ↔ f = ⊥ ∨ g = ⊥ :=
  by
  simp only [← empty_mem_iff_bot, mem_map₂_iff, subset_empty_iff, image2_eq_empty_iff]
  constructor
  · rintro ⟨s, t, hs, ht, rfl | rfl⟩
    · exact Or.inl hs
    · exact Or.inr ht
  · rintro (h | h)
    · exact ⟨_, _, h, univ_mem, Or.inl rfl⟩
    · exact ⟨_, _, univ_mem, h, Or.inr rfl⟩
#align filter.map₂_eq_bot_iff Filter.map₂_eq_bot_iff
-/

#print Filter.map₂_neBot_iff /-
@[simp]
theorem map₂_neBot_iff : (map₂ m f g).ne_bot ↔ f.ne_bot ∧ g.ne_bot := by simp_rw [ne_bot_iff];
  exact map₂_eq_bot_iff.not.trans not_or
#align filter.map₂_ne_bot_iff Filter.map₂_neBot_iff
-/

#print Filter.NeBot.map₂ /-
theorem NeBot.map₂ (hf : f.ne_bot) (hg : g.ne_bot) : (map₂ m f g).ne_bot :=
  map₂_neBot_iff.2 ⟨hf, hg⟩
#align filter.ne_bot.map₂ Filter.NeBot.map₂
-/

#print Filter.NeBot.of_map₂_left /-
theorem NeBot.of_map₂_left (h : (map₂ m f g).ne_bot) : f.ne_bot :=
  (map₂_neBot_iff.1 h).1
#align filter.ne_bot.of_map₂_left Filter.NeBot.of_map₂_left
-/

#print Filter.NeBot.of_map₂_right /-
theorem NeBot.of_map₂_right (h : (map₂ m f g).ne_bot) : g.ne_bot :=
  (map₂_neBot_iff.1 h).2
#align filter.ne_bot.of_map₂_right Filter.NeBot.of_map₂_right
-/

#print Filter.map₂_sup_left /-
theorem map₂_sup_left : map₂ m (f₁ ⊔ f₂) g = map₂ m f₁ g ⊔ map₂ m f₂ g :=
  by
  ext u
  constructor
  · rintro ⟨s, t, ⟨h₁, h₂⟩, ht, hu⟩
    exact ⟨mem_of_superset (image2_mem_map₂ h₁ ht) hu, mem_of_superset (image2_mem_map₂ h₂ ht) hu⟩
  · rintro ⟨⟨s₁, t₁, hs₁, ht₁, hu₁⟩, s₂, t₂, hs₂, ht₂, hu₂⟩
    refine' ⟨s₁ ∪ s₂, t₁ ∩ t₂, union_mem_sup hs₁ hs₂, inter_mem ht₁ ht₂, _⟩
    rw [image2_union_left]
    exact
      union_subset ((image2_subset_left <| inter_subset_left _ _).trans hu₁)
        ((image2_subset_left <| inter_subset_right _ _).trans hu₂)
#align filter.map₂_sup_left Filter.map₂_sup_left
-/

#print Filter.map₂_sup_right /-
theorem map₂_sup_right : map₂ m f (g₁ ⊔ g₂) = map₂ m f g₁ ⊔ map₂ m f g₂ :=
  by
  ext u
  constructor
  · rintro ⟨s, t, hs, ⟨h₁, h₂⟩, hu⟩
    exact ⟨mem_of_superset (image2_mem_map₂ hs h₁) hu, mem_of_superset (image2_mem_map₂ hs h₂) hu⟩
  · rintro ⟨⟨s₁, t₁, hs₁, ht₁, hu₁⟩, s₂, t₂, hs₂, ht₂, hu₂⟩
    refine' ⟨s₁ ∩ s₂, t₁ ∪ t₂, inter_mem hs₁ hs₂, union_mem_sup ht₁ ht₂, _⟩
    rw [image2_union_right]
    exact
      union_subset ((image2_subset_right <| inter_subset_left _ _).trans hu₁)
        ((image2_subset_right <| inter_subset_right _ _).trans hu₂)
#align filter.map₂_sup_right Filter.map₂_sup_right
-/

#print Filter.map₂_inf_subset_left /-
theorem map₂_inf_subset_left : map₂ m (f₁ ⊓ f₂) g ≤ map₂ m f₁ g ⊓ map₂ m f₂ g :=
  le_inf (map₂_mono_right inf_le_left) (map₂_mono_right inf_le_right)
#align filter.map₂_inf_subset_left Filter.map₂_inf_subset_left
-/

#print Filter.map₂_inf_subset_right /-
theorem map₂_inf_subset_right : map₂ m f (g₁ ⊓ g₂) ≤ map₂ m f g₁ ⊓ map₂ m f g₂ :=
  le_inf (map₂_mono_left inf_le_left) (map₂_mono_left inf_le_right)
#align filter.map₂_inf_subset_right Filter.map₂_inf_subset_right
-/

#print Filter.map₂_pure_left /-
@[simp]
theorem map₂_pure_left : map₂ m (pure a) g = g.map fun b => m a b :=
  Filter.ext fun u =>
    ⟨fun ⟨s, t, hs, ht, hu⟩ =>
      mem_of_superset (image_mem_map ht) ((image_subset_image2_right <| mem_pure.1 hs).trans hu),
      fun h => ⟨{a}, _, singleton_mem_pure, h, by rw [image2_singleton_left, image_subset_iff]⟩⟩
#align filter.map₂_pure_left Filter.map₂_pure_left
-/

#print Filter.map₂_pure_right /-
@[simp]
theorem map₂_pure_right : map₂ m f (pure b) = f.map fun a => m a b :=
  Filter.ext fun u =>
    ⟨fun ⟨s, t, hs, ht, hu⟩ =>
      mem_of_superset (image_mem_map hs) ((image_subset_image2_left <| mem_pure.1 ht).trans hu),
      fun h => ⟨_, {b}, h, singleton_mem_pure, by rw [image2_singleton_right, image_subset_iff]⟩⟩
#align filter.map₂_pure_right Filter.map₂_pure_right
-/

#print Filter.map₂_pure /-
theorem map₂_pure : map₂ m (pure a) (pure b) = pure (m a b) := by rw [map₂_pure_right, map_pure]
#align filter.map₂_pure Filter.map₂_pure
-/

#print Filter.map₂_swap /-
theorem map₂_swap (m : α → β → γ) (f : Filter α) (g : Filter β) :
    map₂ m f g = map₂ (fun a b => m b a) g f := by ext u;
  constructor <;> rintro ⟨s, t, hs, ht, hu⟩ <;> refine' ⟨t, s, ht, hs, by rwa [image2_swap]⟩
#align filter.map₂_swap Filter.map₂_swap
-/

#print Filter.map₂_left /-
@[simp]
theorem map₂_left (h : g.ne_bot) : map₂ (fun x y => x) f g = f :=
  by
  ext u
  refine' ⟨_, fun hu => ⟨_, _, hu, univ_mem, (image2_left <| h.nonempty_of_mem univ_mem).Subset⟩⟩
  rintro ⟨s, t, hs, ht, hu⟩
  rw [image2_left (h.nonempty_of_mem ht)] at hu 
  exact mem_of_superset hs hu
#align filter.map₂_left Filter.map₂_left
-/

#print Filter.map₂_right /-
@[simp]
theorem map₂_right (h : f.ne_bot) : map₂ (fun x y => y) f g = g := by rw [map₂_swap, map₂_left h]
#align filter.map₂_right Filter.map₂_right
-/

#print Filter.map₃ /-
/-- The image of a ternary function `m : α → β → γ → δ` as a function
`filter α → filter β → filter γ → filter δ`. Mathematically this should be thought of as the image
of the corresponding function `α × β × γ → δ`. -/
def map₃ (m : α → β → γ → δ) (f : Filter α) (g : Filter β) (h : Filter γ) : Filter δ
    where
  sets := {s | ∃ u v w, u ∈ f ∧ v ∈ g ∧ w ∈ h ∧ image3 m u v w ⊆ s}
  univ_sets := ⟨univ, univ, univ, univ_sets _, univ_sets _, univ_sets _, subset_univ _⟩
  sets_of_superset s t hs hst :=
    Exists₃.imp
      (fun u v w => And.imp_right <| And.imp_right <| And.imp_right fun h => Subset.trans h hst) hs
  inter_sets s t := by
    simp only [exists_prop, mem_set_of_eq, subset_inter_iff]
    rintro ⟨s₁, s₂, s₃, hs₁, hs₂, hs₃, hs⟩ ⟨t₁, t₂, t₃, ht₁, ht₂, ht₃, ht⟩
    exact
      ⟨s₁ ∩ t₁, s₂ ∩ t₂, s₃ ∩ t₃, inter_mem hs₁ ht₁, inter_mem hs₂ ht₂, inter_mem hs₃ ht₃,
        (image3_mono (inter_subset_left _ _) (inter_subset_left _ _) <| inter_subset_left _ _).trans
          hs,
        (image3_mono (inter_subset_right _ _) (inter_subset_right _ _) <|
              inter_subset_right _ _).trans
          ht⟩
#align filter.map₃ Filter.map₃
-/

#print Filter.map₂_map₂_left /-
theorem map₂_map₂_left (m : δ → γ → ε) (n : α → β → δ) :
    map₂ m (map₂ n f g) h = map₃ (fun a b c => m (n a b) c) f g h :=
  by
  ext w
  constructor
  · rintro ⟨s, t, ⟨u, v, hu, hv, hs⟩, ht, hw⟩
    refine' ⟨u, v, t, hu, hv, ht, _⟩
    rw [← image2_image2_left]
    exact (image2_subset_right hs).trans hw
  · rintro ⟨s, t, u, hs, ht, hu, hw⟩
    exact ⟨_, u, image2_mem_map₂ hs ht, hu, by rwa [image2_image2_left]⟩
#align filter.map₂_map₂_left Filter.map₂_map₂_left
-/

#print Filter.map₂_map₂_right /-
theorem map₂_map₂_right (m : α → δ → ε) (n : β → γ → δ) :
    map₂ m f (map₂ n g h) = map₃ (fun a b c => m a (n b c)) f g h :=
  by
  ext w
  constructor
  · rintro ⟨s, t, hs, ⟨u, v, hu, hv, ht⟩, hw⟩
    refine' ⟨s, u, v, hs, hu, hv, _⟩
    rw [← image2_image2_right]
    exact (image2_subset_left ht).trans hw
  · rintro ⟨s, t, u, hs, ht, hu, hw⟩
    exact ⟨s, _, hs, image2_mem_map₂ ht hu, by rwa [image2_image2_right]⟩
#align filter.map₂_map₂_right Filter.map₂_map₂_right
-/

#print Filter.map_map₂ /-
theorem map_map₂ (m : α → β → γ) (n : γ → δ) :
    (map₂ m f g).map n = map₂ (fun a b => n (m a b)) f g := by
  rw [← map_prod_eq_map₂, ← map_prod_eq_map₂, map_map]
#align filter.map_map₂ Filter.map_map₂
-/

#print Filter.map₂_map_left /-
theorem map₂_map_left (m : γ → β → δ) (n : α → γ) :
    map₂ m (f.map n) g = map₂ (fun a b => m (n a) b) f g :=
  by
  rw [← map_prod_eq_map₂, ← map_prod_eq_map₂, ← @map_id _ g, prod_map_map_eq, map_map, map_id]
  rfl
#align filter.map₂_map_left Filter.map₂_map_left
-/

#print Filter.map₂_map_right /-
theorem map₂_map_right (m : α → γ → δ) (n : β → γ) :
    map₂ m f (g.map n) = map₂ (fun a b => m a (n b)) f g := by
  rw [map₂_swap, map₂_map_left, map₂_swap]
#align filter.map₂_map_right Filter.map₂_map_right
-/

#print Filter.map₂_curry /-
@[simp]
theorem map₂_curry (m : α × β → γ) (f : Filter α) (g : Filter β) :
    map₂ (curry m) f g = (f ×ᶠ g).map m :=
  (map_prod_eq_map₂' _ _ _).symm
#align filter.map₂_curry Filter.map₂_curry
-/

#print Filter.map_uncurry_prod /-
@[simp]
theorem map_uncurry_prod (m : α → β → γ) (f : Filter α) (g : Filter β) :
    (f ×ᶠ g).map (uncurry m) = map₂ m f g := by rw [← map₂_curry, curry_uncurry]
#align filter.map_uncurry_prod Filter.map_uncurry_prod
-/

/-!
### Algebraic replacement rules

A collection of lemmas to transfer associativity, commutativity, distributivity, ... of operations
to the associativity, commutativity, distributivity, ... of `filter.map₂` of those operations.

The proof pattern is `map₂_lemma operation_lemma`. For example, `map₂_comm mul_comm` proves that
`map₂ (*) f g = map₂ (*) g f` in a `comm_semigroup`.
-/


#print Filter.map₂_assoc /-
theorem map₂_assoc {m : δ → γ → ε} {n : α → β → δ} {m' : α → ε' → ε} {n' : β → γ → ε'}
    {h : Filter γ} (h_assoc : ∀ a b c, m (n a b) c = m' a (n' b c)) :
    map₂ m (map₂ n f g) h = map₂ m' f (map₂ n' g h) := by
  simp only [map₂_map₂_left, map₂_map₂_right, h_assoc]
#align filter.map₂_assoc Filter.map₂_assoc
-/

#print Filter.map₂_comm /-
theorem map₂_comm {n : β → α → γ} (h_comm : ∀ a b, m a b = n b a) : map₂ m f g = map₂ n g f :=
  (map₂_swap _ _ _).trans <| by simp_rw [h_comm]
#align filter.map₂_comm Filter.map₂_comm
-/

#print Filter.map₂_left_comm /-
theorem map₂_left_comm {m : α → δ → ε} {n : β → γ → δ} {m' : α → γ → δ'} {n' : β → δ' → ε}
    (h_left_comm : ∀ a b c, m a (n b c) = n' b (m' a c)) :
    map₂ m f (map₂ n g h) = map₂ n' g (map₂ m' f h) := by rw [map₂_swap m', map₂_swap m];
  exact map₂_assoc fun _ _ _ => h_left_comm _ _ _
#align filter.map₂_left_comm Filter.map₂_left_comm
-/

#print Filter.map₂_right_comm /-
theorem map₂_right_comm {m : δ → γ → ε} {n : α → β → δ} {m' : α → γ → δ'} {n' : δ' → β → ε}
    (h_right_comm : ∀ a b c, m (n a b) c = n' (m' a c) b) :
    map₂ m (map₂ n f g) h = map₂ n' (map₂ m' f h) g := by rw [map₂_swap n, map₂_swap n'];
  exact map₂_assoc fun _ _ _ => h_right_comm _ _ _
#align filter.map₂_right_comm Filter.map₂_right_comm
-/

#print Filter.map_map₂_distrib /-
theorem map_map₂_distrib {n : γ → δ} {m' : α' → β' → δ} {n₁ : α → α'} {n₂ : β → β'}
    (h_distrib : ∀ a b, n (m a b) = m' (n₁ a) (n₂ b)) :
    (map₂ m f g).map n = map₂ m' (f.map n₁) (g.map n₂) := by
  simp_rw [map_map₂, map₂_map_left, map₂_map_right, h_distrib]
#align filter.map_map₂_distrib Filter.map_map₂_distrib
-/

#print Filter.map_map₂_distrib_left /-
/-- Symmetric statement to `filter.map₂_map_left_comm`. -/
theorem map_map₂_distrib_left {n : γ → δ} {m' : α' → β → δ} {n' : α → α'}
    (h_distrib : ∀ a b, n (m a b) = m' (n' a) b) : (map₂ m f g).map n = map₂ m' (f.map n') g :=
  map_map₂_distrib h_distrib
#align filter.map_map₂_distrib_left Filter.map_map₂_distrib_left
-/

#print Filter.map_map₂_distrib_right /-
/-- Symmetric statement to `filter.map_map₂_right_comm`. -/
theorem map_map₂_distrib_right {n : γ → δ} {m' : α → β' → δ} {n' : β → β'}
    (h_distrib : ∀ a b, n (m a b) = m' a (n' b)) : (map₂ m f g).map n = map₂ m' f (g.map n') :=
  map_map₂_distrib h_distrib
#align filter.map_map₂_distrib_right Filter.map_map₂_distrib_right
-/

#print Filter.map₂_map_left_comm /-
/-- Symmetric statement to `filter.map_map₂_distrib_left`. -/
theorem map₂_map_left_comm {m : α' → β → γ} {n : α → α'} {m' : α → β → δ} {n' : δ → γ}
    (h_left_comm : ∀ a b, m (n a) b = n' (m' a b)) : map₂ m (f.map n) g = (map₂ m' f g).map n' :=
  (map_map₂_distrib_left fun a b => (h_left_comm a b).symm).symm
#align filter.map₂_map_left_comm Filter.map₂_map_left_comm
-/

#print Filter.map_map₂_right_comm /-
/-- Symmetric statement to `filter.map_map₂_distrib_right`. -/
theorem map_map₂_right_comm {m : α → β' → γ} {n : β → β'} {m' : α → β → δ} {n' : δ → γ}
    (h_right_comm : ∀ a b, m a (n b) = n' (m' a b)) : map₂ m f (g.map n) = (map₂ m' f g).map n' :=
  (map_map₂_distrib_right fun a b => (h_right_comm a b).symm).symm
#align filter.map_map₂_right_comm Filter.map_map₂_right_comm
-/

#print Filter.map₂_distrib_le_left /-
/-- The other direction does not hold because of the `f`-`f` cross terms on the RHS. -/
theorem map₂_distrib_le_left {m : α → δ → ε} {n : β → γ → δ} {m₁ : α → β → β'} {m₂ : α → γ → γ'}
    {n' : β' → γ' → ε} (h_distrib : ∀ a b c, m a (n b c) = n' (m₁ a b) (m₂ a c)) :
    map₂ m f (map₂ n g h) ≤ map₂ n' (map₂ m₁ f g) (map₂ m₂ f h) :=
  by
  rintro s ⟨t₁, t₂, ⟨u₁, v, hu₁, hv, ht₁⟩, ⟨u₂, w, hu₂, hw, ht₂⟩, hs⟩
  refine' ⟨u₁ ∩ u₂, _, inter_mem hu₁ hu₂, image2_mem_map₂ hv hw, _⟩
  refine' (image2_distrib_subset_left h_distrib).trans ((image2_subset _ _).trans hs)
  · exact (image2_subset_right <| inter_subset_left _ _).trans ht₁
  · exact (image2_subset_right <| inter_subset_right _ _).trans ht₂
#align filter.map₂_distrib_le_left Filter.map₂_distrib_le_left
-/

#print Filter.map₂_distrib_le_right /-
/-- The other direction does not hold because of the `h`-`h` cross terms on the RHS. -/
theorem map₂_distrib_le_right {m : δ → γ → ε} {n : α → β → δ} {m₁ : α → γ → α'} {m₂ : β → γ → β'}
    {n' : α' → β' → ε} (h_distrib : ∀ a b c, m (n a b) c = n' (m₁ a c) (m₂ b c)) :
    map₂ m (map₂ n f g) h ≤ map₂ n' (map₂ m₁ f h) (map₂ m₂ g h) :=
  by
  rintro s ⟨t₁, t₂, ⟨u, w₁, hu, hw₁, ht₁⟩, ⟨v, w₂, hv, hw₂, ht₂⟩, hs⟩
  refine' ⟨_, w₁ ∩ w₂, image2_mem_map₂ hu hv, inter_mem hw₁ hw₂, _⟩
  refine' (image2_distrib_subset_right h_distrib).trans ((image2_subset _ _).trans hs)
  · exact (image2_subset_left <| inter_subset_left _ _).trans ht₁
  · exact (image2_subset_left <| inter_subset_right _ _).trans ht₂
#align filter.map₂_distrib_le_right Filter.map₂_distrib_le_right
-/

#print Filter.map_map₂_antidistrib /-
theorem map_map₂_antidistrib {n : γ → δ} {m' : β' → α' → δ} {n₁ : β → β'} {n₂ : α → α'}
    (h_antidistrib : ∀ a b, n (m a b) = m' (n₁ b) (n₂ a)) :
    (map₂ m f g).map n = map₂ m' (g.map n₁) (f.map n₂) := by rw [map₂_swap m];
  exact map_map₂_distrib fun _ _ => h_antidistrib _ _
#align filter.map_map₂_antidistrib Filter.map_map₂_antidistrib
-/

#print Filter.map_map₂_antidistrib_left /-
/-- Symmetric statement to `filter.map₂_map_left_anticomm`. -/
theorem map_map₂_antidistrib_left {n : γ → δ} {m' : β' → α → δ} {n' : β → β'}
    (h_antidistrib : ∀ a b, n (m a b) = m' (n' b) a) : (map₂ m f g).map n = map₂ m' (g.map n') f :=
  map_map₂_antidistrib h_antidistrib
#align filter.map_map₂_antidistrib_left Filter.map_map₂_antidistrib_left
-/

#print Filter.map_map₂_antidistrib_right /-
/-- Symmetric statement to `filter.map_map₂_right_anticomm`. -/
theorem map_map₂_antidistrib_right {n : γ → δ} {m' : β → α' → δ} {n' : α → α'}
    (h_antidistrib : ∀ a b, n (m a b) = m' b (n' a)) : (map₂ m f g).map n = map₂ m' g (f.map n') :=
  map_map₂_antidistrib h_antidistrib
#align filter.map_map₂_antidistrib_right Filter.map_map₂_antidistrib_right
-/

#print Filter.map₂_map_left_anticomm /-
/-- Symmetric statement to `filter.map_map₂_antidistrib_left`. -/
theorem map₂_map_left_anticomm {m : α' → β → γ} {n : α → α'} {m' : β → α → δ} {n' : δ → γ}
    (h_left_anticomm : ∀ a b, m (n a) b = n' (m' b a)) :
    map₂ m (f.map n) g = (map₂ m' g f).map n' :=
  (map_map₂_antidistrib_left fun a b => (h_left_anticomm b a).symm).symm
#align filter.map₂_map_left_anticomm Filter.map₂_map_left_anticomm
-/

#print Filter.map_map₂_right_anticomm /-
/-- Symmetric statement to `filter.map_map₂_antidistrib_right`. -/
theorem map_map₂_right_anticomm {m : α → β' → γ} {n : β → β'} {m' : β → α → δ} {n' : δ → γ}
    (h_right_anticomm : ∀ a b, m a (n b) = n' (m' b a)) :
    map₂ m f (g.map n) = (map₂ m' g f).map n' :=
  (map_map₂_antidistrib_right fun a b => (h_right_anticomm b a).symm).symm
#align filter.map_map₂_right_anticomm Filter.map_map₂_right_anticomm
-/

#print Filter.map₂_left_identity /-
/-- If `a` is a left identity for `f : α → β → β`, then `pure a` is a left identity for
`filter.map₂ f`. -/
theorem map₂_left_identity {f : α → β → β} {a : α} (h : ∀ b, f a b = b) (l : Filter β) :
    map₂ f (pure a) l = l := by rw [map₂_pure_left, show f a = id from funext h, map_id]
#align filter.map₂_left_identity Filter.map₂_left_identity
-/

#print Filter.map₂_right_identity /-
/-- If `b` is a right identity for `f : α → β → α`, then `pure b` is a right identity for
`filter.map₂ f`. -/
theorem map₂_right_identity {f : α → β → α} {b : β} (h : ∀ a, f a b = a) (l : Filter α) :
    map₂ f l (pure b) = l := by rw [map₂_pure_right, funext h, map_id']
#align filter.map₂_right_identity Filter.map₂_right_identity
-/

end Filter

