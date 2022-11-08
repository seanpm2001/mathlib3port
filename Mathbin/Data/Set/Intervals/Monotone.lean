/-
Copyright (c) 2021 Yury Kudryashov. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Yury Kudryashov
-/
import Mathbin.Data.Set.Intervals.Disjoint
import Mathbin.Order.ConditionallyCompleteLattice
import Mathbin.Order.SuccPred.Basic
import Mathbin.Tactic.FieldSimp

/-!
# Monotonicity on intervals

In this file we prove that a function is (strictly) monotone (or antitone) on a linear order `α`
provided that it is (strictly) monotone on `(-∞, a]` and on `[a, +∞)`. This is a special case
of a more general statement where one deduces monotonicity on a union from monotonicity on each
set.

We deduce in `monotone_on.exists_monotone_extension` that a function which is monotone on a set
with a smallest and a largest element admits a monotone extension to the whole space.

We also provide an order isomorphism `order_iso_Ioo_neg_one_one` between the open
interval `(-1, 1)` in a linear ordered field and the whole field.
-/


open Set

section

variable {α β : Type _} [LinearOrder α] [Preorder β] {a : α} {f : α → β}

/-- If `f` is strictly monotone both on `s` and `t`, with `s` to the left of `t` and the center
point belonging to both `s` and `t`, then `f` is strictly monotone on `s ∪ t` -/
protected theorem StrictMonoOn.union {s t : Set α} {c : α} (h₁ : StrictMonoOn f s) (h₂ : StrictMonoOn f t)
    (hs : IsGreatest s c) (ht : IsLeast t c) : StrictMonoOn f (s ∪ t) := by
  have A : ∀ x, x ∈ s ∪ t → x ≤ c → x ∈ s := by
    intro x hx hxc
    cases hx
    · exact hx
      
    rcases eq_or_lt_of_le hxc with (rfl | h'x)
    · exact hs.1
      
    exact (lt_irrefl _ (h'x.trans_le (ht.2 hx))).elim
  have B : ∀ x, x ∈ s ∪ t → c ≤ x → x ∈ t := by
    intro x hx hxc
    cases hx
    swap
    · exact hx
      
    rcases eq_or_lt_of_le hxc with (rfl | h'x)
    · exact ht.1
      
    exact (lt_irrefl _ (h'x.trans_le (hs.2 hx))).elim
  intro x hx y hy hxy
  rcases lt_or_le x c with (hxc | hcx)
  · have xs : x ∈ s := A _ hx hxc.le
    rcases lt_or_le y c with (hyc | hcy)
    · exact h₁ xs (A _ hy hyc.le) hxy
      
    · exact (h₁ xs hs.1 hxc).trans_le (h₂.monotone_on ht.1 (B _ hy hcy) hcy)
      
    
  · have xt : x ∈ t := B _ hx hcx
    have yt : y ∈ t := B _ hy (hcx.trans hxy.le)
    exact h₂ xt yt hxy
    

/-- If `f` is strictly monotone both on `(-∞, a]` and `[a, ∞)`, then it is strictly monotone on the
whole line. -/
protected theorem StrictMonoOn.Iic_union_Ici (h₁ : StrictMonoOn f (IicCat a)) (h₂ : StrictMonoOn f (IciCat a)) :
    StrictMono f := by
  rw [← strict_mono_on_univ, ← @Iic_union_Ici _ _ a]
  exact StrictMonoOn.union h₁ h₂ is_greatest_Iic is_least_Ici

/-- If `f` is strictly antitone both on `s` and `t`, with `s` to the left of `t` and the center
point belonging to both `s` and `t`, then `f` is strictly antitone on `s ∪ t` -/
protected theorem StrictAntiOn.union {s t : Set α} {c : α} (h₁ : StrictAntiOn f s) (h₂ : StrictAntiOn f t)
    (hs : IsGreatest s c) (ht : IsLeast t c) : StrictAntiOn f (s ∪ t) :=
  (h₁.dual_right.union h₂.dual_right hs ht).dual_right

/-- If `f` is strictly antitone both on `(-∞, a]` and `[a, ∞)`, then it is strictly antitone on the
whole line. -/
protected theorem StrictAntiOn.Iic_union_Ici (h₁ : StrictAntiOn f (IicCat a)) (h₂ : StrictAntiOn f (IciCat a)) :
    StrictAnti f :=
  (h₁.dual_right.Iic_union_Ici h₂.dual_right).dual_right

/-- If `f` is monotone both on `s` and `t`, with `s` to the left of `t` and the center
point belonging to both `s` and `t`, then `f` is monotone on `s ∪ t` -/
protected theorem MonotoneOn.union_right {s t : Set α} {c : α} (h₁ : MonotoneOn f s) (h₂ : MonotoneOn f t)
    (hs : IsGreatest s c) (ht : IsLeast t c) : MonotoneOn f (s ∪ t) := by
  have A : ∀ x, x ∈ s ∪ t → x ≤ c → x ∈ s := by
    intro x hx hxc
    cases hx
    · exact hx
      
    rcases eq_or_lt_of_le hxc with (rfl | h'x)
    · exact hs.1
      
    exact (lt_irrefl _ (h'x.trans_le (ht.2 hx))).elim
  have B : ∀ x, x ∈ s ∪ t → c ≤ x → x ∈ t := by
    intro x hx hxc
    cases hx
    swap
    · exact hx
      
    rcases eq_or_lt_of_le hxc with (rfl | h'x)
    · exact ht.1
      
    exact (lt_irrefl _ (h'x.trans_le (hs.2 hx))).elim
  intro x hx y hy hxy
  rcases lt_or_le x c with (hxc | hcx)
  · have xs : x ∈ s := A _ hx hxc.le
    rcases lt_or_le y c with (hyc | hcy)
    · exact h₁ xs (A _ hy hyc.le) hxy
      
    · exact (h₁ xs hs.1 hxc.le).trans (h₂ ht.1 (B _ hy hcy) hcy)
      
    
  · have xt : x ∈ t := B _ hx hcx
    have yt : y ∈ t := B _ hy (hcx.trans hxy)
    exact h₂ xt yt hxy
    

/-- If `f` is monotone both on `(-∞, a]` and `[a, ∞)`, then it is monotone on the whole line. -/
protected theorem MonotoneOn.Iic_union_Ici (h₁ : MonotoneOn f (IicCat a)) (h₂ : MonotoneOn f (IciCat a)) : Monotone f :=
  by
  rw [← monotone_on_univ, ← @Iic_union_Ici _ _ a]
  exact MonotoneOn.union_right h₁ h₂ is_greatest_Iic is_least_Ici

/-- If `f` is antitone both on `s` and `t`, with `s` to the left of `t` and the center
point belonging to both `s` and `t`, then `f` is antitone on `s ∪ t` -/
protected theorem AntitoneOn.union_right {s t : Set α} {c : α} (h₁ : AntitoneOn f s) (h₂ : AntitoneOn f t)
    (hs : IsGreatest s c) (ht : IsLeast t c) : AntitoneOn f (s ∪ t) :=
  (h₁.dual_right.unionRight h₂.dual_right hs ht).dual_right

/-- If `f` is antitone both on `(-∞, a]` and `[a, ∞)`, then it is antitone on the whole line. -/
protected theorem AntitoneOn.Iic_union_Ici (h₁ : AntitoneOn f (IicCat a)) (h₂ : AntitoneOn f (IciCat a)) : Antitone f :=
  (h₁.dual_right.Iic_union_Ici h₂.dual_right).dual_right

/-- If a function is monotone on a set `s`, then it admits a monotone extension to the whole space
provided `s` has a least element `a` and a greatest element `b`. -/
theorem MonotoneOn.exists_monotone_extension {β : Type _} [ConditionallyCompleteLinearOrder β] {f : α → β} {s : Set α}
    (h : MonotoneOn f s) {a b : α} (ha : IsLeast s a) (hb : IsGreatest s b) : ∃ g : α → β, Monotone g ∧ EqOn f g s := by
  /- The extension is defined by `f x = f a` for `x ≤ a`, and `f x` is the supremum of the values
    of `f`  to the left of `x` for `x ≥ a`. -/
  have aleb : a ≤ b := hb.2 ha.1
  have H : ∀ x ∈ s, f x = Sup (f '' (Icc a x ∩ s)) := by
    intro x xs
    have xmem : x ∈ Icc a x ∩ s := ⟨⟨ha.2 xs, le_rfl⟩, xs⟩
    have H : ∀ z, z ∈ f '' (Icc a x ∩ s) → z ≤ f x := by
      rintro _ ⟨z, ⟨⟨az, zx⟩, zs⟩, rfl⟩
      exact h zs xs zx
    apply le_antisymm
    · exact le_cSup ⟨f x, H⟩ (mem_image_of_mem _ xmem)
      
    · exact cSup_le (nonempty_image_iff.2 ⟨x, xmem⟩) H
      
  let g x := if x ≤ a then f a else Sup (f '' (Icc a x ∩ s))
  have hfg : eq_on f g s := by
    intro x xs
    dsimp only [g]
    by_cases hxa:x ≤ a
    · have : x = a := le_antisymm hxa (ha.2 xs)
      simp only [if_true, this, le_refl]
      
    rw [if_neg hxa]
    exact H x xs
  have M1 : MonotoneOn g (Iic a) := by
    rintro x (hx : x ≤ a) y (hy : y ≤ a) hxy
    dsimp only [g]
    simp only [hx, hy, if_true]
  have g_eq : ∀ x ∈ Ici a, g x = Sup (f '' (Icc a x ∩ s)) := by
    rintro x ax
    dsimp only [g]
    by_cases hxa:x ≤ a
    · have : x = a := le_antisymm hxa ax
      simp_rw [hxa, if_true, H a ha.1, this]
      
    simp only [hxa, if_false]
  have M2 : MonotoneOn g (Ici a) := by
    rintro x ax y ay hxy
    rw [g_eq x ax, g_eq y ay]
    apply cSup_le_cSup
    · refine' ⟨f b, _⟩
      rintro _ ⟨z, ⟨⟨az, zy⟩, zs⟩, rfl⟩
      exact h zs hb.1 (hb.2 zs)
      
    · exact ⟨f a, mem_image_of_mem _ ⟨⟨le_rfl, ax⟩, ha.1⟩⟩
      
    · apply image_subset
      apply inter_subset_inter_left
      exact Icc_subset_Icc le_rfl hxy
      
  exact ⟨g, M1.Iic_union_Ici M2, hfg⟩

/-- If a function is antitone on a set `s`, then it admits an antitone extension to the whole space
provided `s` has a least element `a` and a greatest element `b`. -/
theorem AntitoneOn.exists_antitone_extension {β : Type _} [ConditionallyCompleteLinearOrder β] {f : α → β} {s : Set α}
    (h : AntitoneOn f s) {a b : α} (ha : IsLeast s a) (hb : IsGreatest s b) : ∃ g : α → β, Antitone g ∧ EqOn f g s :=
  h.dual_right.exists_monotone_extension ha hb

end

section OrderedGroup

variable {G H : Type _} [LinearOrderedAddCommGroup G] [OrderedAddCommGroup H]

theorem strict_mono_of_odd_strict_mono_on_nonneg {f : G → H} (h₁ : ∀ x, f (-x) = -f x)
    (h₂ : StrictMonoOn f (IciCat 0)) : StrictMono f := by
  refine' StrictMonoOn.Iic_union_Ici (fun x hx y hy hxy => neg_lt_neg_iff.1 _) h₂
  rw [← h₁, ← h₁]
  exact h₂ (neg_nonneg.2 hy) (neg_nonneg.2 hx) (neg_lt_neg hxy)

theorem monotone_of_odd_of_monotone_on_nonneg {f : G → H} (h₁ : ∀ x, f (-x) = -f x) (h₂ : MonotoneOn f (IciCat 0)) :
    Monotone f := by
  refine' MonotoneOn.Iic_union_Ici (fun x hx y hy hxy => neg_le_neg_iff.1 _) h₂
  rw [← h₁, ← h₁]
  exact h₂ (neg_nonneg.2 hy) (neg_nonneg.2 hx) (neg_le_neg hxy)

end OrderedGroup

/-- In a linear ordered field, the whole field is order isomorphic to the open interval `(-1, 1)`.
We consider the actual implementation to be a "black box", so it is irreducible.
-/
irreducible_def orderIsoIooNegOneOne (k : Type _) [LinearOrderedField k] : k ≃o IooCat (-1 : k) 1 := by
  refine' StrictMono.orderIsoOfRightInverse _ _ (fun x => x / (1 - |x|)) _
  · refine' cod_restrict (fun x => x / (1 + |x|)) _ fun x => abs_lt.1 _
    have H : 0 < 1 + |x| := (abs_nonneg x).trans_lt (lt_one_add _)
    calc
      |x / (1 + |x|)| = |x| / (1 + |x|) := by rw [abs_div, abs_of_pos H]
      _ < 1 := (div_lt_one H).2 (lt_one_add _)
      
    
  · refine' (strict_mono_of_odd_strict_mono_on_nonneg _ _).codRestrict _
    · intro x
      simp only [abs_neg, neg_div]
      
    · rintro x (hx : 0 ≤ x) y (hy : 0 ≤ y) hxy
      simp [abs_of_nonneg, mul_add, mul_comm x y, div_lt_div_iff, hx.trans_lt (lt_one_add _),
        hy.trans_lt (lt_one_add _), *]
      
    
  · refine' fun x => Subtype.ext _
    have : 0 < 1 - |(x : k)| := sub_pos.2 (abs_lt.2 x.2)
    field_simp [abs_div, this.ne', abs_of_pos this]
    

section IxxCat

variable {α β : Type _} [Preorder α] [Preorder β] {f g : α → β} {s : Set α}

theorem antitone_Ici : Antitone (IciCat : α → Set α) := fun _ _ => Ici_subset_Ici.2

theorem monotone_Iic : Monotone (IicCat : α → Set α) := fun _ _ => Iic_subset_Iic.2

theorem antitone_Ioi : Antitone (IoiCat : α → Set α) := fun _ _ => Ioi_subset_Ioi

theorem monotone_Iio : Monotone (IioCat : α → Set α) := fun _ _ => Iio_subset_Iio

protected theorem Monotone.Ici (hf : Monotone f) : Antitone fun x => IciCat (f x) :=
  antitone_Ici.comp_monotone hf

protected theorem MonotoneOn.Ici (hf : MonotoneOn f s) : AntitoneOn (fun x => IciCat (f x)) s :=
  antitone_Ici.comp_monotone_on hf

protected theorem Antitone.Ici (hf : Antitone f) : Monotone fun x => IciCat (f x) :=
  antitone_Ici.comp hf

protected theorem AntitoneOn.Ici (hf : AntitoneOn f s) : MonotoneOn (fun x => IciCat (f x)) s :=
  antitone_Ici.comp_antitone_on hf

protected theorem Monotone.Iic (hf : Monotone f) : Monotone fun x => IicCat (f x) :=
  monotone_Iic.comp hf

protected theorem MonotoneOn.Iic (hf : MonotoneOn f s) : MonotoneOn (fun x => IicCat (f x)) s :=
  monotone_Iic.comp_monotone_on hf

protected theorem Antitone.Iic (hf : Antitone f) : Antitone fun x => IicCat (f x) :=
  monotone_Iic.comp_antitone hf

protected theorem AntitoneOn.Iic (hf : AntitoneOn f s) : AntitoneOn (fun x => IicCat (f x)) s :=
  monotone_Iic.comp_antitone_on hf

protected theorem Monotone.Ioi (hf : Monotone f) : Antitone fun x => IoiCat (f x) :=
  antitone_Ioi.comp_monotone hf

protected theorem MonotoneOn.Ioi (hf : MonotoneOn f s) : AntitoneOn (fun x => IoiCat (f x)) s :=
  antitone_Ioi.comp_monotone_on hf

protected theorem Antitone.Ioi (hf : Antitone f) : Monotone fun x => IoiCat (f x) :=
  antitone_Ioi.comp hf

protected theorem AntitoneOn.Ioi (hf : AntitoneOn f s) : MonotoneOn (fun x => IoiCat (f x)) s :=
  antitone_Ioi.comp_antitone_on hf

protected theorem Monotone.Iio (hf : Monotone f) : Monotone fun x => IioCat (f x) :=
  monotone_Iio.comp hf

protected theorem MonotoneOn.Iio (hf : MonotoneOn f s) : MonotoneOn (fun x => IioCat (f x)) s :=
  monotone_Iio.comp_monotone_on hf

protected theorem Antitone.Iio (hf : Antitone f) : Antitone fun x => IioCat (f x) :=
  monotone_Iio.comp_antitone hf

protected theorem AntitoneOn.Iio (hf : AntitoneOn f s) : AntitoneOn (fun x => IioCat (f x)) s :=
  monotone_Iio.comp_antitone_on hf

protected theorem Monotone.Icc (hf : Monotone f) (hg : Antitone g) : Antitone fun x => IccCat (f x) (g x) :=
  hf.IciCat.inter hg.IicCat

protected theorem MonotoneOn.Icc (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => IccCat (f x) (g x)) s :=
  hf.IciCat.inter hg.IicCat

protected theorem Antitone.Icc (hf : Antitone f) (hg : Monotone g) : Monotone fun x => IccCat (f x) (g x) :=
  hf.IciCat.inter hg.IicCat

protected theorem AntitoneOn.Icc (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => IccCat (f x) (g x)) s :=
  hf.IciCat.inter hg.IicCat

protected theorem Monotone.Ico (hf : Monotone f) (hg : Antitone g) : Antitone fun x => IcoCat (f x) (g x) :=
  hf.IciCat.inter hg.IioCat

protected theorem MonotoneOn.Ico (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => IcoCat (f x) (g x)) s :=
  hf.IciCat.inter hg.IioCat

protected theorem Antitone.Ico (hf : Antitone f) (hg : Monotone g) : Monotone fun x => IcoCat (f x) (g x) :=
  hf.IciCat.inter hg.IioCat

protected theorem AntitoneOn.Ico (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => IcoCat (f x) (g x)) s :=
  hf.IciCat.inter hg.IioCat

protected theorem Monotone.Ioc (hf : Monotone f) (hg : Antitone g) : Antitone fun x => IocCat (f x) (g x) :=
  hf.IoiCat.inter hg.IicCat

protected theorem MonotoneOn.Ioc (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => IocCat (f x) (g x)) s :=
  hf.IoiCat.inter hg.IicCat

protected theorem Antitone.Ioc (hf : Antitone f) (hg : Monotone g) : Monotone fun x => IocCat (f x) (g x) :=
  hf.IoiCat.inter hg.IicCat

protected theorem AntitoneOn.Ioc (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => IocCat (f x) (g x)) s :=
  hf.IoiCat.inter hg.IicCat

protected theorem Monotone.Ioo (hf : Monotone f) (hg : Antitone g) : Antitone fun x => IooCat (f x) (g x) :=
  hf.IoiCat.inter hg.IioCat

protected theorem MonotoneOn.Ioo (hf : MonotoneOn f s) (hg : AntitoneOn g s) :
    AntitoneOn (fun x => IooCat (f x) (g x)) s :=
  hf.IoiCat.inter hg.IioCat

protected theorem Antitone.Ioo (hf : Antitone f) (hg : Monotone g) : Monotone fun x => IooCat (f x) (g x) :=
  hf.IoiCat.inter hg.IioCat

protected theorem AntitoneOn.Ioo (hf : AntitoneOn f s) (hg : MonotoneOn g s) :
    MonotoneOn (fun x => IooCat (f x) (g x)) s :=
  hf.IoiCat.inter hg.IioCat

end IxxCat

section UnionCat

variable {α β : Type _} [SemilatticeSup α] [LinearOrder β] {f g : α → β} {a b : β}

theorem Union_Ioo_of_mono_of_is_glb_of_is_lub (hf : Antitone f) (hg : Monotone g) (ha : IsGlb (Range f) a)
    (hb : IsLub (Range g) b) : (⋃ x, IooCat (f x) (g x)) = IooCat a b :=
  calc
    (⋃ x, IooCat (f x) (g x)) = (⋃ x, IoiCat (f x)) ∩ ⋃ x, IioCat (g x) := Union_inter_of_monotone hf.IoiCat hg.IioCat
    _ = IoiCat a ∩ IioCat b := congr_arg₂ (· ∩ ·) ha.Union_Ioi_eq hb.Union_Iio_eq
    

end UnionCat

section SuccOrder

open Order

variable {α β : Type _} [PartialOrder α]

theorem StrictMonoOn.Iic_id_le [SuccOrder α] [IsSuccArchimedean α] [OrderBot α] {n : α} {φ : α → α}
    (hφ : StrictMonoOn φ (Set.IicCat n)) : ∀ m ≤ n, m ≤ φ m := by
  revert hφ
  refine' Succ.rec_bot (fun n => StrictMonoOn φ (Set.IicCat n) → ∀ m ≤ n, m ≤ φ m) (fun _ _ hm => hm.trans bot_le) _ _
  rintro k ih hφ m hm
  by_cases hk:IsMax k
  · rw [succ_eq_iff_is_max.2 hk] at hm
    exact ih (hφ.mono <| Iic_subset_Iic.2 (le_succ _)) _ hm
    
  obtain rfl | h := le_succ_iff_eq_or_le.1 hm
  · specialize ih (StrictMonoOn.mono hφ fun x hx => le_trans hx (le_succ _)) k le_rfl
    refine' le_trans (succ_mono ih) (succ_le_of_lt (hφ (le_succ _) le_rfl _))
    rw [lt_succ_iff_eq_or_lt_of_not_is_max hk]
    exact Or.inl rfl
    
  · exact ih (StrictMonoOn.mono hφ fun x hx => le_trans hx (le_succ _)) _ h
    

theorem StrictMonoOn.Iic_le_id [PredOrder α] [IsPredArchimedean α] [OrderTop α] {n : α} {φ : α → α}
    (hφ : StrictMonoOn φ (Set.IciCat n)) : ∀ m, n ≤ m → φ m ≤ m :=
  @StrictMonoOn.Iic_id_le αᵒᵈ _ _ _ _ _ _ fun i hi j hj hij => hφ hj hi hij

variable [Preorder β] {ψ : α → β}

/-- A function `ψ` on a `succ_order` is strictly monotone before some `n` if for all `m` such that
`m < n`, we have `ψ m < ψ (succ m)`. -/
theorem strict_mono_on_Iic_of_lt_succ [SuccOrder α] [IsSuccArchimedean α] {n : α} (hψ : ∀ m, m < n → ψ m < ψ (succ m)) :
    StrictMonoOn ψ (Set.IicCat n) := by
  intro x hx y hy hxy
  obtain ⟨i, rfl⟩ := hxy.le.exists_succ_iterate
  induction' i with k ih
  · simpa using hxy
    
  cases k
  · exact hψ _ (lt_of_lt_of_le hxy hy)
    
  rw [Set.mem_Iic] at *
  simp only [Function.iterate_succ', Function.comp_apply] at ih hxy hy⊢
  by_cases hmax:IsMax ((succ^[k]) x)
  · rw [succ_eq_iff_is_max.2 hmax] at hxy⊢
    exact ih (le_trans (le_succ _) hy) hxy
    
  by_cases hmax':IsMax (succ ((succ^[k]) x))
  · rw [succ_eq_iff_is_max.2 hmax'] at hxy⊢
    exact ih (le_trans (le_succ _) hy) hxy
    
  refine'
    lt_trans (ih (le_trans (le_succ _) hy) (lt_of_le_of_lt (le_succ_iterate k _) (lt_succ_iff_not_is_max.2 hmax))) _
  rw [← Function.comp_apply succ, ← Function.iterate_succ']
  refine' hψ _ (lt_of_lt_of_le _ hy)
  rwa [Function.iterate_succ', Function.comp_apply, lt_succ_iff_not_is_max]

theorem strict_anti_on_Iic_of_succ_lt [SuccOrder α] [IsSuccArchimedean α] {n : α} (hψ : ∀ m, m < n → ψ (succ m) < ψ m) :
    StrictAntiOn ψ (Set.IicCat n) := fun i hi j hj hij =>
  @strict_mono_on_Iic_of_lt_succ α βᵒᵈ _ _ ψ _ _ n hψ i hi j hj hij

theorem strict_mono_on_Iic_of_pred_lt [PredOrder α] [IsPredArchimedean α] {n : α} (hψ : ∀ m, n < m → ψ (pred m) < ψ m) :
    StrictMonoOn ψ (Set.IciCat n) := fun i hi j hj hij =>
  @strict_mono_on_Iic_of_lt_succ αᵒᵈ βᵒᵈ _ _ ψ _ _ n hψ j hj i hi hij

theorem strict_anti_on_Iic_of_lt_pred [PredOrder α] [IsPredArchimedean α] {n : α} (hψ : ∀ m, n < m → ψ m < ψ (pred m)) :
    StrictAntiOn ψ (Set.IciCat n) := fun i hi j hj hij =>
  @strict_anti_on_Iic_of_succ_lt αᵒᵈ βᵒᵈ _ _ ψ _ _ n hψ j hj i hi hij

end SuccOrder

