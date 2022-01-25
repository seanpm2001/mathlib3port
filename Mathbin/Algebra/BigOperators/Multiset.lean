import Mathbin.Algebra.GroupWithZero.Power
import Mathbin.Data.List.ProdMonoid
import Mathbin.Data.Multiset.Basic

/-!
# Sums and products over multisets

In this file we define products and sums indexed by multisets. This is later used to define products
and sums indexed by finite sets.

## Main declarations

* `multiset.prod`: `s.prod f` is the product of `f i` over all `i ∈ s`. Not to be mistaken with
  the cartesian product `multiset.product`.
* `multiset.sum`: `s.sum f` is the sum of `f i` over all `i ∈ s`.
-/


variable {ι α β γ : Type _}

namespace Multiset

section CommMonoidₓ

variable [CommMonoidₓ α] {s t : Multiset α} {a : α} {m : Multiset ι} {f g : ι → α}

/-- Product of a multiset given a commutative monoid structure on `α`.
  `prod {a, b, c} = a * b * c` -/
@[to_additive "Sum of a multiset given a commutative additive monoid structure on `α`.\n  `sum {a, b, c} = a + b + c`"]
def Prod : Multiset α → α :=
  foldr (· * ·)
    (fun x y z => by
      simp [mul_left_commₓ])
    1

@[to_additive]
theorem prod_eq_foldr (s : Multiset α) :
    Prod s =
      foldr (· * ·)
        (fun x y z => by
          simp [mul_left_commₓ])
        1 s :=
  rfl

@[to_additive]
theorem prod_eq_foldl (s : Multiset α) :
    Prod s =
      foldl (· * ·)
        (fun x y z => by
          simp [mul_right_commₓ])
        1 s :=
  (foldr_swap _ _ _ _).trans
    (by
      simp [mul_comm])

@[simp, norm_cast, to_additive]
theorem coe_prod (l : List α) : Prod (↑l) = l.prod :=
  prod_eq_foldl _

@[simp, to_additive]
theorem prod_to_list (s : Multiset α) : s.to_list.prod = s.prod := by
  conv_rhs => rw [← coe_to_list s]
  rw [coe_prod]

@[simp, to_additive]
theorem prod_zero : @Prod α _ 0 = 1 :=
  rfl

@[simp, to_additive]
theorem prod_cons (a : α) s : Prod (a ::ₘ s) = a * Prod s :=
  foldr_cons _ _ _ _ _

@[simp, to_additive]
theorem prod_singleton (a : α) : Prod {a} = a := by
  simp only [mul_oneₓ, prod_cons, singleton_eq_cons, eq_self_iff_true, prod_zero]

@[simp, to_additive]
theorem prod_add (s t : Multiset α) : Prod (s + t) = Prod s * Prod t :=
  Quotientₓ.induction_on₂ s t $ fun l₁ l₂ => by
    simp

theorem prod_nsmul (m : Multiset α) : ∀ n : ℕ, (n • m).Prod = m.prod ^ n
  | 0 => by
    rw [zero_nsmul, pow_zeroₓ]
    rfl
  | n + 1 => by
    rw [add_nsmul, one_nsmul, pow_addₓ, pow_oneₓ, prod_add, prod_nsmul n]

@[simp, to_additive]
theorem prod_repeat (a : α) (n : ℕ) : (repeat a n).Prod = a ^ n := by
  simp [repeat, List.prod_repeat]

@[to_additive nsmul_count]
theorem pow_count [DecidableEq α] (a : α) : a ^ s.count a = (s.filter (Eq a)).Prod := by
  rw [filter_eq, prod_repeat]

@[to_additive]
theorem prod_hom [CommMonoidₓ β] (s : Multiset α) (f : α →* β) : (s.map f).Prod = f s.prod :=
  Quotientₓ.induction_on s $ fun l => by
    simp only [l.prod_hom f, quot_mk_to_coe, coe_map, coe_prod]

@[to_additive]
theorem prod_hom' [CommMonoidₓ β] (s : Multiset ι) (f : α →* β) (g : ι → α) :
    (s.map $ fun i => f $ g i).Prod = f (s.map g).Prod := by
  convert (s.map g).prod_hom f
  exact (map_map _ _ _).symm

@[to_additive]
theorem prod_hom₂ [CommMonoidₓ β] [CommMonoidₓ γ] (s : Multiset ι) (f : α → β → γ)
    (hf : ∀ a b c d, f (a * b) (c * d) = f a c * f b d) (hf' : f 1 1 = 1) (f₁ : ι → α) (f₂ : ι → β) :
    (s.map $ fun i => f (f₁ i) (f₂ i)).Prod = f (s.map f₁).Prod (s.map f₂).Prod :=
  Quotientₓ.induction_on s $ fun l => by
    simp only [l.prod_hom₂ f hf hf', quot_mk_to_coe, coe_map, coe_prod]

@[to_additive]
theorem prod_hom_rel [CommMonoidₓ β] (s : Multiset ι) {r : α → β → Prop} {f : ι → α} {g : ι → β} (h₁ : r 1 1)
    (h₂ : ∀ ⦃a b c⦄, r b c → r (f a * b) (g a * c)) : r (s.map f).Prod (s.map g).Prod :=
  Quotientₓ.induction_on s $ fun l => by
    simp only [l.prod_hom_rel h₁ h₂, quot_mk_to_coe, coe_map, coe_prod]

@[to_additive]
theorem prod_map_one : Prod (m.map fun i => (1 : α)) = 1 := by
  rw [map_const, prod_repeat, one_pow]

@[simp, to_additive]
theorem prod_map_mul : (m.map $ fun i => f i * g i).Prod = (m.map f).Prod * (m.map g).Prod :=
  m.prod_hom₂ (· * ·) mul_mul_mul_commₓ (mul_oneₓ _) _ _

@[to_additive sum_map_nsmul]
theorem prod_map_pow {n : ℕ} : (m.map $ fun i => f i ^ n).Prod = (m.map f).Prod ^ n :=
  m.prod_hom' (powMonoidHom n) _

@[to_additive]
theorem prod_map_prod_map (m : Multiset β) (n : Multiset γ) {f : β → γ → α} :
    Prod (m.map $ fun a => Prod $ n.map $ fun b => f a b) = Prod (n.map $ fun b => Prod $ m.map $ fun a => f a b) :=
  Multiset.induction_on m
    (by
      simp )
    fun a m ih => by
    simp [ih]

@[to_additive]
theorem prod_induction (p : α → Prop) (s : Multiset α) (p_mul : ∀ a b, p a → p b → p (a * b)) (p_one : p 1)
    (p_s : ∀, ∀ a ∈ s, ∀, p a) : p s.prod := by
  rw [prod_eq_foldr]
  exact
    foldr_induction (· * ·)
      (fun x y z => by
        simp [mul_left_commₓ])
      1 p s p_mul p_one p_s

@[to_additive]
theorem prod_induction_nonempty (p : α → Prop) (p_mul : ∀ a b, p a → p b → p (a * b)) (hs : s ≠ ∅)
    (p_s : ∀, ∀ a ∈ s, ∀, p a) : p s.prod := by
  revert s
  refine' Multiset.induction _ _
  · intro h
    exfalso
    simpa using h
    
  intro a s hs hsa hpsa
  rw [prod_cons]
  by_cases' hs_empty : s = ∅
  · simp [hs_empty, hpsa a]
    
  have hps : ∀ x, x ∈ s → p x := fun x hxs => hpsa x (mem_cons_of_mem hxs)
  exact p_mul a s.prod (hpsa a (mem_cons_self a s)) (hs hs_empty hps)

theorem dvd_prod : a ∈ s → a ∣ s.prod :=
  Quotientₓ.induction_on s
    (fun l a h => by
      simpa using List.dvd_prod h)
    a

theorem prod_dvd_prod (h : s ≤ t) : s.prod ∣ t.prod := by
  obtain ⟨z, rfl⟩ := Multiset.le_iff_exists_add.1 h
  simp only [prod_add, dvd_mul_right]

end CommMonoidₓ

section AddCommMonoidₓ

variable [AddCommMonoidₓ α]

/-- `multiset.sum`, the sum of the elements of a multiset, promoted to a morphism of
`add_comm_monoid`s. -/
def sum_add_monoid_hom : Multiset α →+ α where
  toFun := Sum
  map_zero' := sum_zero
  map_add' := sum_add

@[simp]
theorem coe_sum_add_monoid_hom : (sum_add_monoid_hom : Multiset α → α) = Sum :=
  rfl

end AddCommMonoidₓ

section CommMonoidWithZero

variable [CommMonoidWithZero α]

theorem prod_eq_zero {s : Multiset α} (h : (0 : α) ∈ s) : s.prod = 0 := by
  rcases Multiset.exists_cons_of_mem h with ⟨s', hs'⟩
  simp [hs', Multiset.prod_cons]

variable [NoZeroDivisors α] [Nontrivial α] {s : Multiset α}

theorem prod_eq_zero_iff : s.prod = 0 ↔ (0 : α) ∈ s :=
  Quotientₓ.induction_on s $ fun l => by
    rw [quot_mk_to_coe, coe_prod]
    exact List.prod_eq_zero_iff

theorem prod_ne_zero (h : (0 : α) ∉ s) : s.prod ≠ 0 :=
  mt prod_eq_zero_iff.1 h

end CommMonoidWithZero

section CommGroupₓ

variable [CommGroupₓ α] {m : Multiset ι} {f g : ι → α}

@[simp, to_additive]
theorem prod_map_inv' : (m.map $ fun i => f i⁻¹).Prod = (m.map f).Prod⁻¹ := by
  convert (m.map f).prod_hom CommGroupₓ.invMonoidHom
  rw [map_map]
  rfl

@[simp, to_additive]
theorem prod_map_div : (m.map $ fun i => f i / g i).Prod = (m.map f).Prod / (m.map g).Prod :=
  m.prod_hom₂ (· / ·) mul_div_comm' (div_one' _) _ _

@[to_additive]
theorem prod_map_zpow {n : ℤ} : (m.map $ fun i => f i ^ n).Prod = (m.map f).Prod ^ n := by
  convert (m.map f).prod_hom (zpowGroupHom _)
  rw [map_map]
  rfl

@[simp]
theorem coe_inv_monoid_hom : (CommGroupₓ.invMonoidHom : α → α) = HasInv.inv :=
  rfl

@[simp, to_additive]
theorem prod_map_inv (m : Multiset α) : (m.map HasInv.inv).Prod = m.prod⁻¹ :=
  m.prod_hom CommGroupₓ.invMonoidHom

end CommGroupₓ

section CommGroupWithZero

variable [CommGroupWithZero α] {m : Multiset ι} {f g : ι → α}

@[simp]
theorem prod_map_inv₀ : (m.map $ fun i => f i⁻¹).Prod = (m.map f).Prod⁻¹ := by
  convert (m.map f).prod_hom inv_monoid_with_zero_hom.to_monoid_hom
  rw [map_map]
  rfl

@[simp]
theorem prod_map_div₀ : (m.map $ fun i => f i / g i).Prod = (m.map f).Prod / (m.map g).Prod :=
  m.prod_hom₂ (· / ·) (fun _ _ _ _ => (div_mul_div _ _ _ _).symm) (div_one _) _ _

theorem prod_map_zpow₀ {n : ℤ} : Prod (m.map $ fun i => f i ^ n) = (m.map f).Prod ^ n := by
  convert (m.map f).prod_hom (zpowGroupHom₀ _)
  rw [map_map]
  rfl

end CommGroupWithZero

section Semiringₓ

variable [Semiringₓ α] {a : α} {s : Multiset ι} {f : ι → α}

theorem sum_map_mul_left : Sum (s.map fun i => a * f i) = a * Sum (s.map f) :=
  Multiset.induction_on s
    (by
      simp )
    fun i s ih => by
    simp [ih, mul_addₓ]

theorem sum_map_mul_right : Sum (s.map fun i => f i * a) = Sum (s.map f) * a :=
  Multiset.induction_on s
    (by
      simp )
    fun a s ih => by
    simp [ih, add_mulₓ]

end Semiringₓ

section CommSemiringₓ

variable [CommSemiringₓ α]

theorem dvd_sum {a : α} {s : Multiset α} : (∀, ∀ x ∈ s, ∀, a ∣ x) → a ∣ s.sum :=
  Multiset.induction_on s (fun _ => dvd_zero _) fun x s ih h => by
    rw [sum_cons]
    exact dvd_add (h _ (mem_cons_self _ _)) (ih $ fun y hy => h _ $ mem_cons.2 $ Or.inr hy)

end CommSemiringₓ

/-! ### Order -/


section OrderedCommMonoid

variable [OrderedCommMonoid α] {s t : Multiset α} {a : α}

@[to_additive sum_nonneg]
theorem one_le_prod_of_one_le : (∀, ∀ x ∈ s, ∀, (1 : α) ≤ x) → 1 ≤ s.prod :=
  Quotientₓ.induction_on s $ fun l hl => by
    simpa using List.one_le_prod_of_one_le hl

@[to_additive]
theorem single_le_prod : (∀, ∀ x ∈ s, ∀, (1 : α) ≤ x) → ∀, ∀ x ∈ s, ∀, x ≤ s.prod :=
  Quotientₓ.induction_on s $ fun l hl x hx => by
    simpa using List.single_le_prod hl x hx

@[to_additive]
theorem prod_le_of_forall_le (s : Multiset α) (n : α) (h : ∀, ∀ x ∈ s, ∀, x ≤ n) : s.prod ≤ n ^ s.card := by
  induction s using Quotientₓ.induction_on
  simpa using List.prod_le_of_forall_le _ _ h

@[to_additive all_zero_of_le_zero_le_of_sum_eq_zero]
theorem all_one_of_le_one_le_of_prod_eq_one : (∀, ∀ x ∈ s, ∀, (1 : α) ≤ x) → s.prod = 1 → ∀, ∀ x ∈ s, ∀, x = (1 : α) :=
  by
  apply Quotientₓ.induction_on s
  simp only [quot_mk_to_coe, coe_prod, mem_coe]
  exact fun l => List.all_one_of_le_one_le_of_prod_eq_one

@[to_additive]
theorem prod_le_prod_of_rel_le (h : s.rel (· ≤ ·) t) : s.prod ≤ t.prod := by
  induction' h with _ _ _ _ rh _ rt
  · rfl
    
  · rw [prod_cons, prod_cons]
    exact mul_le_mul' rh rt
    

@[to_additive]
theorem prod_map_le_prod (f : α → α) (h : ∀ x, x ∈ s → f x ≤ x) : (s.map f).Prod ≤ s.prod :=
  prod_le_prod_of_rel_le $ rel_map_left.2 $ rel_refl_of_refl_on h

@[to_additive]
theorem prod_le_sum_prod (f : α → α) (h : ∀ x, x ∈ s → x ≤ f x) : s.prod ≤ (s.map f).Prod :=
  @prod_map_le_prod (OrderDual α) _ _ f h

@[to_additive card_nsmul_le_sum]
theorem pow_card_le_prod (h : ∀, ∀ x ∈ s, ∀, a ≤ x) : a ^ s.card ≤ s.prod := by
  rw [← Multiset.prod_repeat, ← Multiset.map_const]
  exact prod_map_le_prod _ h

@[to_additive sum_le_card_nsmul]
theorem prod_le_pow_card (h : ∀, ∀ x ∈ s, ∀, x ≤ a) : s.prod ≤ a ^ s.card :=
  @pow_card_le_prod (OrderDual α) _ _ _ h

end OrderedCommMonoid

theorem prod_nonneg [OrderedCommSemiring α] {m : Multiset α} (h : ∀, ∀ a ∈ m, ∀, (0 : α) ≤ a) : 0 ≤ m.prod := by
  revert h
  refine' m.induction_on _ _
  · rintro -
    rw [prod_zero]
    exact zero_le_one
    
  intro a s hs ih
  rw [prod_cons]
  exact mul_nonneg (ih _ $ mem_cons_self _ _) (hs $ fun a ha => ih _ $ mem_cons_of_mem ha)

@[to_additive]
theorem prod_eq_one_iff [CanonicallyOrderedMonoid α] {m : Multiset α} : m.prod = 1 ↔ ∀, ∀ x ∈ m, ∀, x = (1 : α) :=
  Quotientₓ.induction_on m $ fun l => by
    simpa using List.prod_eq_one_iff l

@[to_additive]
theorem le_prod_of_mem [CanonicallyOrderedMonoid α] {m : Multiset α} {a : α} (h : a ∈ m) : a ≤ m.prod := by
  obtain ⟨m', rfl⟩ := exists_cons_of_mem h
  rw [prod_cons]
  exact _root_.le_mul_right (le_reflₓ a)

@[to_additive le_sum_of_subadditive_on_pred]
theorem le_prod_of_submultiplicative_on_pred [CommMonoidₓ α] [OrderedCommMonoid β] (f : α → β) (p : α → Prop)
    (h_one : f 1 = 1) (hp_one : p 1) (h_mul : ∀ a b, p a → p b → f (a * b) ≤ f a * f b)
    (hp_mul : ∀ a b, p a → p b → p (a * b)) (s : Multiset α) (hps : ∀ a, a ∈ s → p a) : f s.prod ≤ (s.map f).Prod := by
  revert s
  refine' Multiset.induction _ _
  · simp [le_of_eqₓ h_one]
    
  intro a s hs hpsa
  have hps : ∀ x, x ∈ s → p x := fun x hx => hpsa x (mem_cons_of_mem hx)
  have hp_prod : p s.prod := prod_induction p s hp_mul hp_one hps
  rw [prod_cons, map_cons, prod_cons]
  exact (h_mul a s.prod (hpsa a (mem_cons_self a s)) hp_prod).trans (mul_le_mul_left' (hs hps) _)

@[to_additive le_sum_of_subadditive]
theorem le_prod_of_submultiplicative [CommMonoidₓ α] [OrderedCommMonoid β] (f : α → β) (h_one : f 1 = 1)
    (h_mul : ∀ a b, f (a * b) ≤ f a * f b) (s : Multiset α) : f s.prod ≤ (s.map f).Prod :=
  le_prod_of_submultiplicative_on_pred f (fun i => True) h_one trivialₓ (fun x y _ _ => h_mul x y)
    (by
      simp )
    s
    (by
      simp )

@[to_additive le_sum_nonempty_of_subadditive_on_pred]
theorem le_prod_nonempty_of_submultiplicative_on_pred [CommMonoidₓ α] [OrderedCommMonoid β] (f : α → β) (p : α → Prop)
    (h_mul : ∀ a b, p a → p b → f (a * b) ≤ f a * f b) (hp_mul : ∀ a b, p a → p b → p (a * b)) (s : Multiset α)
    (hs_nonempty : s ≠ ∅) (hs : ∀ a, a ∈ s → p a) : f s.prod ≤ (s.map f).Prod := by
  revert s
  refine' Multiset.induction _ _
  · intro h
    exfalso
    exact h rfl
    
  rintro a s hs hsa_nonempty hsa_prop
  rw [prod_cons, map_cons, prod_cons]
  by_cases' hs_empty : s = ∅
  · simp [hs_empty]
    
  have hsa_restrict : ∀ x, x ∈ s → p x := fun x hx => hsa_prop x (mem_cons_of_mem hx)
  have hp_sup : p s.prod := prod_induction_nonempty p hp_mul hs_empty hsa_restrict
  have hp_a : p a := hsa_prop a (mem_cons_self a s)
  exact (h_mul a _ hp_a hp_sup).trans (mul_le_mul_left' (hs hs_empty hsa_restrict) _)

@[to_additive le_sum_nonempty_of_subadditive]
theorem le_prod_nonempty_of_submultiplicative [CommMonoidₓ α] [OrderedCommMonoid β] (f : α → β)
    (h_mul : ∀ a b, f (a * b) ≤ f a * f b) (s : Multiset α) (hs_nonempty : s ≠ ∅) : f s.prod ≤ (s.map f).Prod :=
  le_prod_nonempty_of_submultiplicative_on_pred f (fun i => True)
    (by
      simp [h_mul])
    (by
      simp )
    s hs_nonempty
    (by
      simp )

@[simp]
theorem sum_map_singleton (s : Multiset α) : (s.map fun a => ({a} : Multiset α)).Sum = s :=
  Multiset.induction_on s
    (by
      simp )
    (by
      simp [singleton_eq_cons])

theorem abs_sum_le_sum_abs [LinearOrderedAddCommGroup α] {s : Multiset α} : abs s.sum ≤ (s.map abs).Sum :=
  le_sum_of_subadditive _ abs_zero abs_add s

end Multiset

@[to_additive]
theorem MonoidHom.map_multiset_prod [CommMonoidₓ α] [CommMonoidₓ β] (f : α →* β) (s : Multiset α) :
    f s.prod = (s.map f).Prod :=
  (s.prod_hom f).symm

