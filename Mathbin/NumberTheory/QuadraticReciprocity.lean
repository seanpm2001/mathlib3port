import Mathbin.FieldTheory.Finite.Basic
import Mathbin.Data.Zmod.Basic
import Mathbin.Data.Nat.Parity

/-!
# Quadratic reciprocity.

This file contains results about quadratic residues modulo a prime number.

The main results are the law of quadratic reciprocity, `quadratic_reciprocity`, as well as the
interpretations in terms of existence of square roots depending on the congruence mod 4,
`exists_sq_eq_prime_iff_of_mod_four_eq_one`, and
`exists_sq_eq_prime_iff_of_mod_four_eq_three`.

Also proven are conditions for `-1` and `2` to be a square modulo a prime,
`exists_sq_eq_neg_one_iff_mod_four_ne_three` and
`exists_sq_eq_two_iff`

## Implementation notes

The proof of quadratic reciprocity implemented uses Gauss' lemma and Eisenstein's lemma
-/


open Function Finset Nat FiniteField Zmod

open_locale BigOperators Nat

namespace Zmod

variable (p q : ℕ) [Fact p.prime] [Fact q.prime]

/-- Euler's Criterion: A unit `x` of `zmod p` is a square if and only if `x ^ (p / 2) = 1`. -/
theorem euler_criterion_units (x : (Zmod p)ˣ) : (∃ y : (Zmod p)ˣ, y ^ 2 = x) ↔ x ^ (p / 2) = 1 := by
  cases' Nat.Prime.eq_two_or_odd (Fact.out p.prime) with hp2 hp_odd
  · subst p
    refine' iff_of_true ⟨1, _⟩ _ <;> apply Subsingleton.elimₓ
    
  obtain ⟨g, hg⟩ := IsCyclic.exists_generator (Zmod p)ˣ
  obtain ⟨n, hn⟩ : x ∈ Submonoid.powers g := by
    rw [mem_powers_iff_mem_zpowers]
    apply hg
  constructor
  · rintro ⟨y, rfl⟩
    rw [← pow_mulₓ, two_mul_odd_div_two hp_odd, units_pow_card_sub_one_eq_one]
    
  · subst x
    intro h
    have key : 2 * (p / 2) ∣ n * (p / 2) := by
      rw [← pow_mulₓ] at h
      rw [two_mul_odd_div_two hp_odd, ← card_units, ← order_of_eq_card_of_forall_mem_zpowers hg]
      apply order_of_dvd_of_pow_eq_one h
    have : 0 < p / 2 :=
      Nat.div_pos (Fact.out (1 < p))
        (by
          decide)
    obtain ⟨m, rfl⟩ := dvd_of_mul_dvd_mul_right this key
    refine' ⟨g ^ m, _⟩
    rw [mul_comm, pow_mulₓ]
    

/-- Euler's Criterion: a nonzero `a : zmod p` is a square if and only if `x ^ (p / 2) = 1`. -/
theorem euler_criterion {a : Zmod p} (ha : a ≠ 0) : (∃ y : Zmod p, y ^ 2 = a) ↔ a ^ (p / 2) = 1 := by
  apply
    (iff_congr _
          (by
            simp [Units.ext_iff])).mp
      (euler_criterion_units p (Units.mk0 a ha))
  simp only [Units.ext_iff, sq, Units.coe_mk0, Units.coe_mul]
  constructor
  · rintro ⟨y, hy⟩
    exact ⟨y, hy⟩
    
  · rintro ⟨y, rfl⟩
    have hy : y ≠ 0 := by
      rintro rfl
      simpa [zero_pow] using ha
    refine' ⟨Units.mk0 y hy, _⟩
    simp
    

theorem exists_sq_eq_neg_one_iff_mod_four_ne_three : (∃ y : Zmod p, y ^ 2 = -1) ↔ p % 4 ≠ 3 := by
  cases' Nat.Prime.eq_two_or_odd (Fact.out p.prime) with hp2 hp_odd
  · subst p
    exact by
      decide
    
  have := Fact.mk hp_odd
  have neg_one_ne_zero : (-1 : Zmod p) ≠ 0 := mt neg_eq_zero.1 one_ne_zero
  rw [euler_criterion p neg_one_ne_zero, neg_one_pow_eq_pow_mod_two]
  cases' mod_two_eq_zero_or_one (p / 2) with p_half_even p_half_odd
  · rw [p_half_even, pow_zeroₓ, eq_self_iff_true, true_iffₓ]
    contrapose! p_half_even with hp
    rw [← Nat.mod_mul_right_div_self, show 2 * 2 = 4 from rfl, hp]
    exact by
      decide
    
  · rw [p_half_odd, pow_oneₓ, iff_false_intro (ne_neg_self p one_ne_zero).symm, false_iffₓ, not_not]
    rw [← Nat.mod_mul_right_div_self, show 2 * 2 = 4 from rfl] at p_half_odd
    rw [← Nat.mod_mul_left_mod _ 2, show 2 * 2 = 4 from rfl] at hp_odd
    have hp : p % 4 < 4 :=
      Nat.mod_ltₓ _
        (by
          decide)
    revert hp hp_odd p_half_odd
    generalize p % 4 = k
    decide!
    

theorem pow_div_two_eq_neg_one_or_one {a : Zmod p} (ha : a ≠ 0) : a ^ (p / 2) = 1 ∨ a ^ (p / 2) = -1 := by
  cases' Nat.Prime.eq_two_or_odd (Fact.out p.prime) with hp2 hp_odd
  · subst p
    revert a ha
    exact by
      decide
    
  rw [← mul_self_eq_one_iff, ← pow_addₓ, ← two_mul, two_mul_odd_div_two hp_odd]
  exact pow_card_sub_one_eq_one ha

/-- **Wilson's Lemma**: the product of `1`, ..., `p-1` is `-1` modulo `p`. -/
@[simp]
theorem wilsons_lemma : ((p - 1)! : Zmod p) = -1 := by
  refine'
    calc
      ((p - 1)! : Zmod p) = ∏ x in Ico 1 (succ (p - 1)), x := by
        rw [← Finset.prod_Ico_id_eq_factorial, prod_nat_cast]
      _ = ∏ x : (Zmod p)ˣ, x := _
      _ = -1 := by
        simp_rw [← Units.coe_hom_apply, ← (Units.coeHom (Zmod p)).map_prod, prod_univ_units_id_eq_neg_one,
          Units.coe_hom_apply, Units.coe_neg, Units.coe_one]
      
  have hp : 0 < p := (Fact.out p.prime).Pos
  symm
  refine' prod_bij (fun a _ => (a : Zmod p).val) _ _ _ _
  · intro a ha
    rw [mem_Ico, ← Nat.succ_subₓ hp, Nat.succ_sub_one]
    constructor
    · apply Nat.pos_of_ne_zeroₓ
      rw [← @val_zero p]
      intro h
      apply Units.ne_zero a (val_injective p h)
      
    · exact val_lt _
      
    
  · intro a ha
    simp only [cast_id, nat_cast_val]
    
  · intro _ _ _ _ h
    rw [Units.ext_iff]
    exact val_injective p h
    
  · intro b hb
    rw [mem_Ico, Nat.succ_le_iff, ← succ_sub hp, succ_sub_one, pos_iff_ne_zero] at hb
    refine' ⟨Units.mk0 b _, Finset.mem_univ _, _⟩
    · intro h
      apply hb.1
      apply_fun val  at h
      simpa only [val_cast_of_lt hb.right, val_zero] using h
      
    · simp only [val_cast_of_lt hb.right, Units.coe_mk0]
      
    

@[simp]
theorem prod_Ico_one_prime : (∏ x in Ico 1 p, (x : Zmod p)) = -1 := by
  conv in Ico 1 p => rw [← succ_sub_one p, succ_sub (Fact.out p.prime).Pos]
  rw [← prod_nat_cast, Finset.prod_Ico_id_eq_factorial, wilsons_lemma]

end Zmod

/-- The image of the map sending a non zero natural number `x ≤ p / 2` to the absolute value
  of the element of interger in the interval `(-p/2, p/2]` congruent to `a * x` mod p is the set
  of non zero natural numbers `x` such that `x ≤ p / 2` -/
theorem Ico_map_val_min_abs_nat_abs_eq_Ico_map_id (p : ℕ) [hp : Fact p.prime] (a : Zmod p) (hap : a ≠ 0) :
    ((Ico 1 (p / 2).succ).1.map fun x => (a * x).valMinAbs.natAbs) = (Ico 1 (p / 2).succ).1.map fun a => a := by
  have he : ∀ {x}, x ∈ Ico 1 (p / 2).succ → x ≠ 0 ∧ x ≤ p / 2 := by
    simp (config := { contextual := true })[Nat.lt_succ_iffₓ, Nat.succ_le_iff, pos_iff_ne_zero]
  have hep : ∀ {x}, x ∈ Ico 1 (p / 2).succ → x < p := fun x hx =>
    lt_of_le_of_ltₓ (he hx).2
      (Nat.div_lt_selfₓ hp.1.Pos
        (by
          decide))
  have hpe : ∀ {x}, x ∈ Ico 1 (p / 2).succ → ¬p ∣ x := fun x hx hpx =>
    not_lt_of_geₓ (le_of_dvd (Nat.pos_of_ne_zeroₓ (he hx).1) hpx) (hep hx)
  have hmem : ∀ x : ℕ hx : x ∈ Ico 1 (p / 2).succ, (a * x : Zmod p).valMinAbs.natAbs ∈ Ico 1 (p / 2).succ := by
    intro x hx
    simp [hap, CharP.cast_eq_zero_iff (Zmod p) p, hpe hx, lt_succ_iff, succ_le_iff, pos_iff_ne_zero,
      nat_abs_val_min_abs_le _]
  have hsurj : ∀ b : ℕ hb : b ∈ Ico 1 (p / 2).succ, ∃ x ∈ Ico 1 (p / 2).succ, b = (a * x : Zmod p).valMinAbs.natAbs :=
    by
    intro b hb
    refine' ⟨(b / a : Zmod p).valMinAbs.natAbs, mem_Ico.mpr ⟨_, _⟩, _⟩
    · apply Nat.pos_of_ne_zeroₓ
      simp only [div_eq_mul_inv, hap, CharP.cast_eq_zero_iff (Zmod p) p, hpe hb, not_false_iff, val_min_abs_eq_zero,
        inv_eq_zero, Int.nat_abs_eq_zero, Ne.def, mul_eq_zero, or_selfₓ]
      
    · apply lt_succ_of_le
      apply nat_abs_val_min_abs_le
      
    · rw [nat_cast_nat_abs_val_min_abs]
      split_ifs
      · erw [mul_div_cancel' _ hap, val_min_abs_def_pos, val_cast_of_lt (hep hb),
          if_pos (le_of_lt_succ (mem_Ico.1 hb).2), Int.nat_abs_of_nat]
        
      · erw [mul_neg_eq_neg_mul_symm, mul_div_cancel' _ hap, nat_abs_val_min_abs_neg, val_min_abs_def_pos,
          val_cast_of_lt (hep hb), if_pos (le_of_lt_succ (mem_Ico.1 hb).2), Int.nat_abs_of_nat]
        
      
  exact
    Multiset.map_eq_map_of_bij_of_nodup _ _ (Finset.nodup _) (Finset.nodup _)
      (fun x _ => (a * x : Zmod p).valMinAbs.natAbs) hmem (fun _ _ => rfl)
      (inj_on_of_surj_on_of_card_le _ hmem hsurj (le_reflₓ _)) hsurj

private theorem gauss_lemma_aux₁ (p : ℕ) [Fact p.prime] [Fact (p % 2 = 1)] {a : ℕ} (hap : (a : Zmod p) ≠ 0) :
    (a ^ (p / 2) * (p / 2)! : Zmod p) =
      -1 ^ ((Ico 1 (p / 2).succ).filter fun x : ℕ => ¬(a * x : Zmod p).val ≤ p / 2).card * (p / 2)! :=
  calc
    (a ^ (p / 2) * (p / 2)! : Zmod p) = ∏ x in Ico 1 (p / 2).succ, a * x := by
      rw [prod_mul_distrib, ← prod_nat_cast, ← prod_nat_cast, prod_Ico_id_eq_factorial, prod_const, card_Ico,
          succ_sub_one] <;>
        simp
    _ = ∏ x in Ico 1 (p / 2).succ, (a * x : Zmod p).val := by
      simp
    _ =
        ∏ x in Ico 1 (p / 2).succ,
          (if (a * x : Zmod p).val ≤ p / 2 then 1 else -1) * (a * x : Zmod p).valMinAbs.natAbs :=
      prod_congr rfl $ fun _ _ => by
        simp only [nat_cast_nat_abs_val_min_abs]
        split_ifs <;> simp
    _ =
        -1 ^ ((Ico 1 (p / 2).succ).filter fun x : ℕ => ¬(a * x : Zmod p).val ≤ p / 2).card *
          ∏ x in Ico 1 (p / 2).succ, (a * x : Zmod p).valMinAbs.natAbs :=
      by
      have :
        (∏ x in Ico 1 (p / 2).succ, if (a * x : Zmod p).val ≤ p / 2 then (1 : Zmod p) else -1) =
          ∏ x in (Ico 1 (p / 2).succ).filter fun x : ℕ => ¬(a * x : Zmod p).val ≤ p / 2, -1 :=
        prod_bij_ne_one (fun x _ _ => x)
          (fun x => by
            split_ifs <;> simp_all (config := { contextual := true }))
          (fun _ _ _ _ _ _ => id)
          (fun b h _ =>
            ⟨b, by
              simp_all [-not_leₓ]⟩)
          (by
            intros <;> split_ifs  at * <;> simp_all )
      rw [prod_mul_distrib, this] <;> simp
    _ = -1 ^ ((Ico 1 (p / 2).succ).filter fun x : ℕ => ¬(a * x : Zmod p).val ≤ p / 2).card * (p / 2)! := by
      rw [← prod_nat_cast, Finset.prod_eq_multiset_prod, Ico_map_val_min_abs_nat_abs_eq_Ico_map_id p a hap, ←
        Finset.prod_eq_multiset_prod, prod_Ico_id_eq_factorial]
    

private theorem gauss_lemma_aux₂ (p : ℕ) [hp : Fact p.prime] [Fact (p % 2 = 1)] {a : ℕ} (hap : (a : Zmod p) ≠ 0) :
    (a ^ (p / 2) : Zmod p) = -1 ^ ((Ico 1 (p / 2).succ).filter fun x : ℕ => p / 2 < (a * x : Zmod p).val).card :=
  (mul_left_inj'
        (show ((p / 2)! : Zmod p) ≠ 0 by
          rw [Ne.def, CharP.cast_eq_zero_iff (Zmod p) p, hp.1.dvd_factorial, not_leₓ] <;>
            exact
              Nat.div_lt_selfₓ hp.1.Pos
                (by
                  decide))).1 $
    by
    simpa using gauss_lemma_aux₁ p hap

private theorem eisenstein_lemma_aux₁ (p : ℕ) [Fact p.prime] [hp2 : Fact (p % 2 = 1)] {a : ℕ} (hap : (a : Zmod p) ≠ 0) :
    ((∑ x in Ico 1 (p / 2).succ, a * x : ℕ) : Zmod 2) =
      (((Ico 1 (p / 2).succ).filter fun x : ℕ => p / 2 < (a * x : Zmod p).val).card + ∑ x in Ico 1 (p / 2).succ, x) +
        (∑ x in Ico 1 (p / 2).succ, a * x / p : ℕ) :=
  have hp2 : (p : Zmod 2) = (1 : ℕ) := (eq_iff_modeq_nat _).2 hp2.1
  calc
    ((∑ x in Ico 1 (p / 2).succ, a * x : ℕ) : Zmod 2) =
        ((∑ x in Ico 1 (p / 2).succ, a * x % p + p * (a * x / p) : ℕ) : Zmod 2) :=
      by
      simp only [mod_add_div]
    _ = (∑ x in Ico 1 (p / 2).succ, ((a * x : ℕ) : Zmod p).val : ℕ) + (∑ x in Ico 1 (p / 2).succ, a * x / p : ℕ) := by
      simp only [val_nat_cast] <;> simp [sum_add_distrib, mul_sum.symm, Nat.cast_add, Nat.cast_mul, Nat.cast_sum, hp2]
    _ = _ :=
      congr_arg2ₓ (· + ·)
        (calc
          ((∑ x in Ico 1 (p / 2).succ, ((a * x : ℕ) : Zmod p).val : ℕ) : Zmod 2) =
              ∑ x in Ico 1 (p / 2).succ,
                (((a * x : Zmod p).valMinAbs + if (a * x : Zmod p).val ≤ p / 2 then 0 else p : ℤ) : Zmod 2) :=
            by
            simp only [(val_eq_ite_val_min_abs _).symm] <;> simp [Nat.cast_sum]
          _ =
              ((Ico 1 (p / 2).succ).filter fun x : ℕ => p / 2 < (a * x : Zmod p).val).card +
                (∑ x in Ico 1 (p / 2).succ, (a * x : Zmod p).valMinAbs.natAbs : ℕ) :=
            by
            simp [ite_cast, add_commₓ, sum_add_distrib, Finset.sum_ite, hp2, Nat.cast_sum]
          _ = _ := by
            rw [Finset.sum_eq_multiset_sum, Ico_map_val_min_abs_nat_abs_eq_Ico_map_id p a hap, ←
                Finset.sum_eq_multiset_sum] <;>
              simp [Nat.cast_sum]
          )
        rfl
    

private theorem eisenstein_lemma_aux₂ (p : ℕ) [Fact p.prime] [Fact (p % 2 = 1)] {a : ℕ} (ha2 : a % 2 = 1)
    (hap : (a : Zmod p) ≠ 0) :
    ((Ico 1 (p / 2).succ).filter fun x : ℕ => p / 2 < (a * x : Zmod p).val).card ≡
      ∑ x in Ico 1 (p / 2).succ, x * a / p [MOD 2] :=
  have ha2 : (a : Zmod 2) = (1 : ℕ) := (eq_iff_modeq_nat _).2 ha2
  (eq_iff_modeq_nat 2).1 $
    sub_eq_zero.1 $ by
      simpa [add_left_commₓ, sub_eq_add_neg, finset.mul_sum.symm, mul_comm, ha2, Nat.cast_sum,
        add_neg_eq_iff_eq_add.symm, neg_eq_self_mod_two, add_assocₓ] using Eq.symm (eisenstein_lemma_aux₁ p hap)

theorem div_eq_filter_card {a b c : ℕ} (hb0 : 0 < b) (hc : a / b ≤ c) :
    a / b = ((Ico 1 c.succ).filter fun x => x * b ≤ a).card :=
  calc
    a / b = (Ico 1 (a / b).succ).card := by
      simp
    _ = ((Ico 1 c.succ).filter fun x => x * b ≤ a).card :=
      congr_argₓ _ $
        Finset.ext $ fun x => by
          have : x * b ≤ a → x ≤ c := fun h =>
            le_transₓ
              (by
                rwa [le_div_iff_mul_le _ _ hb0])
              hc
          simp [lt_succ_iff, le_div_iff_mul_le _ _ hb0] <;> tauto
    

/-- The given sum is the number of integer points in the triangle formed by the diagonal of the
  rectangle `(0, p/2) × (0, q/2)`  -/
private theorem sum_Ico_eq_card_lt {p q : ℕ} :
    (∑ a in Ico 1 (p / 2).succ, a * q / p) =
      (((Ico 1 (p / 2).succ).product (Ico 1 (q / 2).succ)).filter fun x : ℕ × ℕ => x.2 * p ≤ x.1 * q).card :=
  if hp0 : p = 0 then by
    simp [hp0, Finset.ext_iff]
  else
    calc
      (∑ a in Ico 1 (p / 2).succ, a * q / p) =
          ∑ a in Ico 1 (p / 2).succ, ((Ico 1 (q / 2).succ).filter fun x => x * p ≤ a * q).card :=
        Finset.sum_congr rfl $ fun x hx =>
          div_eq_filter_card (Nat.pos_of_ne_zeroₓ hp0)
            (calc
              x * q / p ≤ p / 2 * q / p :=
                Nat.div_le_div_right (mul_le_mul_of_nonneg_right (le_of_lt_succ $ (mem_Ico.mp hx).2) (Nat.zero_leₓ _))
              _ ≤ _ := Nat.div_mul_div_le_div _ _ _
              )
      _ = _ := by
        rw [← card_sigma] <;>
          exact
            card_congr (fun a _ => ⟨a.1, a.2⟩)
              (by
                simp (config := { contextual := true })only [mem_filter, mem_sigma, and_selfₓ, forall_true_iff,
                  mem_product])
              (fun ⟨_, _⟩ ⟨_, _⟩ => by
                simp (config := { contextual := true })only [Prod.mk.inj_iffₓ, eq_self_iff_true, and_selfₓ, heq_iff_eq,
                  forall_true_iff])
              fun ⟨b₁, b₂⟩ h =>
              ⟨⟨b₁, b₂⟩, by
                revert h <;>
                  simp (config := { contextual := true })only [mem_filter, eq_self_iff_true, exists_prop_of_true,
                    mem_sigma, and_selfₓ, forall_true_iff, mem_product]⟩
      

/-- Each of the sums in this lemma is the cardinality of the set integer points in each of the
  two triangles formed by the diagonal of the rectangle `(0, p/2) × (0, q/2)`. Adding them
  gives the number of points in the rectangle. -/
private theorem sum_mul_div_add_sum_mul_div_eq_mul (p q : ℕ) [hp : Fact p.prime] (hq0 : (q : Zmod p) ≠ 0) :
    ((∑ a in Ico 1 (p / 2).succ, a * q / p) + ∑ a in Ico 1 (q / 2).succ, a * p / q) = p / 2 * (q / 2) := by
  have hswap :
    (((Ico 1 (q / 2).succ).product (Ico 1 (p / 2).succ)).filter fun x : ℕ × ℕ => x.2 * q ≤ x.1 * p).card =
      (((Ico 1 (p / 2).succ).product (Ico 1 (q / 2).succ)).filter fun x : ℕ × ℕ => x.1 * q ≤ x.2 * p).card :=
    card_congr (fun x _ => Prod.swap x)
      (fun ⟨_, _⟩ => by
        simp (config := { contextual := true })only [mem_filter, and_selfₓ, Prod.swap_prod_mkₓ, forall_true_iff,
          mem_product])
      (fun ⟨_, _⟩ ⟨_, _⟩ => by
        simp (config := { contextual := true })only [Prod.mk.inj_iffₓ, eq_self_iff_true, and_selfₓ, Prod.swap_prod_mkₓ,
          forall_true_iff])
      fun ⟨x₁, x₂⟩ h =>
      ⟨⟨x₂, x₁⟩, by
        revert h <;>
          simp (config := { contextual := true })only [mem_filter, eq_self_iff_true, and_selfₓ, exists_prop_of_true,
            Prod.swap_prod_mkₓ, forall_true_iff, mem_product]⟩
  have hdisj :
    Disjoint (((Ico 1 (p / 2).succ).product (Ico 1 (q / 2).succ)).filter fun x : ℕ × ℕ => x.2 * p ≤ x.1 * q)
      (((Ico 1 (p / 2).succ).product (Ico 1 (q / 2).succ)).filter fun x : ℕ × ℕ => x.1 * q ≤ x.2 * p) :=
    by
    apply disjoint_filter.2 fun x hx hpq hqp => _
    have hxp : x.1 < p :=
      lt_of_le_of_ltₓ
        (show x.1 ≤ p / 2 by
          simp_all only [lt_succ_iff, mem_Ico, mem_product] <;> tauto)
        (Nat.div_lt_selfₓ hp.1.Pos
          (by
            decide))
    have : (x.1 : Zmod p) = 0 := by
      simpa [hq0] using congr_argₓ (coe : ℕ → Zmod p) (le_antisymmₓ hpq hqp)
    apply_fun Zmod.val  at this
    rw [val_cast_of_lt hxp, val_zero] at this
    simpa only [this, nonpos_iff_eq_zero, mem_Ico, one_ne_zero, false_andₓ, mem_product] using hx
  have hunion :
    ((((Ico 1 (p / 2).succ).product (Ico 1 (q / 2).succ)).filter fun x : ℕ × ℕ => x.2 * p ≤ x.1 * q) ∪
        ((Ico 1 (p / 2).succ).product (Ico 1 (q / 2).succ)).filter fun x : ℕ × ℕ => x.1 * q ≤ x.2 * p) =
      (Ico 1 (p / 2).succ).product (Ico 1 (q / 2).succ) :=
    Finset.ext fun x => by
      have := le_totalₓ (x.2 * p) (x.1 * q) <;> simp only [mem_union, mem_filter, mem_Ico, mem_product] <;> tauto
  rw [sum_Ico_eq_card_lt, sum_Ico_eq_card_lt, hswap, ← card_disjoint_union hdisj, hunion, card_product]
  simp only [card_Ico, tsub_zero, succ_sub_succ_eq_sub]

variable (p q : ℕ) [Fact p.prime] [Fact q.prime]

namespace Zmod

/-- The Legendre symbol of `a` and `p` is an integer defined as

* `0` if `a` is `0` modulo `p`;
* `1` if `a ^ (p / 2)` is `1` modulo `p`
   (by `euler_criterion` this is equivalent to “`a` is a square modulo `p`”);
* `-1` otherwise.

-/
def legendre_sym (a p : ℕ) : ℤ :=
  if (a : Zmod p) = 0 then 0 else if (a : Zmod p) ^ (p / 2) = 1 then 1 else -1

theorem legendre_sym_eq_pow (a p : ℕ) [hp : Fact p.prime] : (legendre_sym a p : Zmod p) = a ^ (p / 2) := by
  rw [legendre_sym]
  by_cases' ha : (a : Zmod p) = 0
  · simp only [if_pos, ha, zero_pow (Nat.div_pos hp.1.two_le (succ_pos 1)), Int.cast_zero]
    
  cases' hp.1.eq_two_or_odd with hp2 hp_odd
  · subst p
    generalize (a : Zmod 2) = b
    revert b
    decide
    
  · have := Fact.mk hp_odd
    rw [if_neg ha]
    have : (-1 : Zmod p) ≠ 1 := (ne_neg_self p one_ne_zero).symm
    cases' pow_div_two_eq_neg_one_or_one p ha with h h
    · rw [if_pos h, h, Int.cast_one]
      
    · rw [h, if_neg this, Int.cast_neg, Int.cast_one]
      
    

theorem legendre_sym_eq_one_or_neg_one (a p : ℕ) (ha : (a : Zmod p) ≠ 0) :
    legendre_sym a p = -1 ∨ legendre_sym a p = 1 := by
  unfold legendre_sym <;> split_ifs <;> simp_all only [eq_self_iff_true, or_trueₓ, true_orₓ]

theorem legendre_sym_eq_zero_iff (a p : ℕ) : legendre_sym a p = 0 ↔ (a : Zmod p) = 0 := by
  constructor
  · classical
    contrapose
    intro ha
    cases' legendre_sym_eq_one_or_neg_one a p ha with h h
    all_goals
      rw [h]
      norm_num
    
  · intro ha
    rw [legendre_sym, if_pos ha]
    

/-- Gauss' lemma. The legendre symbol can be computed by considering the number of naturals less
  than `p/2` such that `(a * x) % p > p / 2` -/
theorem gauss_lemma {a : ℕ} [Fact (p % 2 = 1)] (ha0 : (a : Zmod p) ≠ 0) :
    legendre_sym a p = -1 ^ ((Ico 1 (p / 2).succ).filter fun x : ℕ => p / 2 < (a * x : Zmod p).val).card := by
  have :
    (legendre_sym a p : Zmod p) =
      ((-1 ^ ((Ico 1 (p / 2).succ).filter fun x : ℕ => p / 2 < (a * x : Zmod p).val).card : ℤ) : Zmod p) :=
    by
    rw [legendre_sym_eq_pow, gauss_lemma_aux₂ p ha0] <;> simp
  cases legendre_sym_eq_one_or_neg_one a p ha0 <;>
    cases neg_one_pow_eq_or ℤ ((Ico 1 (p / 2).succ).filter fun x : ℕ => p / 2 < (a * x : Zmod p).val).card <;>
      simp_all [ne_neg_self p one_ne_zero, (ne_neg_self p one_ne_zero).symm]

theorem legendre_sym_eq_one_iff {a : ℕ} (ha0 : (a : Zmod p) ≠ 0) : legendre_sym a p = 1 ↔ ∃ b : Zmod p, b ^ 2 = a := by
  rw [euler_criterion p ha0, legendre_sym, if_neg ha0]
  split_ifs
  · simp only [h, eq_self_iff_true]
    
  · simp only [h, iff_falseₓ]
    tauto
    

theorem eisenstein_lemma [Fact (p % 2 = 1)] {a : ℕ} (ha1 : a % 2 = 1) (ha0 : (a : Zmod p) ≠ 0) :
    legendre_sym a p = -1 ^ ∑ x in Ico 1 (p / 2).succ, x * a / p := by
  rw [neg_one_pow_eq_pow_mod_two, gauss_lemma p ha0, neg_one_pow_eq_pow_mod_two,
    show _ = _ from eisenstein_lemma_aux₂ p ha1 ha0]

/-- **Quadratic reciprocity theorem** -/
theorem quadratic_reciprocity [hp1 : Fact (p % 2 = 1)] [hq1 : Fact (q % 2 = 1)] (hpq : p ≠ q) :
    legendre_sym p q * legendre_sym q p = -1 ^ (p / 2 * (q / 2)) := by
  have hpq0 : (p : Zmod q) ≠ 0 := prime_ne_zero q p hpq.symm
  have hqp0 : (q : Zmod p) ≠ 0 := prime_ne_zero p q hpq
  rw [eisenstein_lemma q hp1.1 hpq0, eisenstein_lemma p hq1.1 hqp0, ← pow_addₓ,
    sum_mul_div_add_sum_mul_div_eq_mul q p hpq0, mul_comm]

attribute [local instance] Nat.fact_prime_two

theorem legendre_sym_two [hp1 : Fact (p % 2 = 1)] : legendre_sym 2 p = -1 ^ (p / 4 + p / 2) := by
  have hp2 : p ≠ 2 :=
    mt (congr_argₓ (· % 2))
      (by
        simpa using hp1.1)
  have hp22 : p / 2 / 2 = _ :=
    div_eq_filter_card
      (show 0 < 2 by
        decide)
      (Nat.div_le_selfₓ (p / 2) 2)
  have hcard : (Ico 1 (p / 2).succ).card = p / 2 := by
    simp
  have hx2 : ∀, ∀ x ∈ Ico 1 (p / 2).succ, ∀, (2 * x : Zmod p).val = 2 * x := fun x hx => by
    have h2xp : 2 * x < p :=
      calc
        2 * x ≤ 2 * (p / 2) :=
          mul_le_mul_of_nonneg_left (le_of_lt_succ $ (mem_Ico.mp hx).2)
            (by
              decide)
        _ < _ := by
          conv_rhs => rw [← div_add_mod p 2, hp1.1] <;> exact lt_succ_self _
        
    rw [← Nat.cast_two, ← Nat.cast_mul, val_cast_of_lt h2xp]
  have hdisj :
    Disjoint ((Ico 1 (p / 2).succ).filter fun x => p / 2 < ((2 : ℕ) * x : Zmod p).val)
      ((Ico 1 (p / 2).succ).filter fun x => x * 2 ≤ p / 2) :=
    disjoint_filter.2 fun x hx => by
      simp [hx2 _ hx, mul_comm]
  have hunion :
    (((Ico 1 (p / 2).succ).filter fun x => p / 2 < ((2 : ℕ) * x : Zmod p).val) ∪
        (Ico 1 (p / 2).succ).filter fun x => x * 2 ≤ p / 2) =
      Ico 1 (p / 2).succ :=
    by
    rw [filter_union_right]
    conv_rhs => rw [← @filter_true _ (Ico 1 (p / 2).succ)]
    exact
      filter_congr fun x hx => by
        simp [hx2 _ hx, lt_or_leₓ, mul_comm]
  rw [gauss_lemma p (prime_ne_zero p 2 hp2), neg_one_pow_eq_pow_mod_two,
    @neg_one_pow_eq_pow_mod_two _ _ (p / 4 + p / 2)]
  refine' congr_arg2ₓ _ rfl ((eq_iff_modeq_nat 2).1 _)
  rw [show 4 = 2 * 2 from rfl, ← Nat.div_div_eq_div_mulₓ, hp22, Nat.cast_add, ← sub_eq_iff_eq_add', sub_eq_add_neg,
    neg_eq_self_mod_two, ← Nat.cast_add, ← card_disjoint_union hdisj, hunion, hcard]

theorem exists_sq_eq_two_iff [hp1 : Fact (p % 2 = 1)] : (∃ a : Zmod p, a ^ 2 = 2) ↔ p % 8 = 1 ∨ p % 8 = 7 := by
  have hp2 : ((2 : ℕ) : Zmod p) ≠ 0 :=
    prime_ne_zero p 2 fun h => by
      simpa [h] using hp1.1
  have hpm4 : p % 4 = p % 8 % 4 := (Nat.mod_mul_left_mod p 2 4).symm
  have hpm2 : p % 2 = p % 8 % 2 := (Nat.mod_mul_left_mod p 4 2).symm
  rw
    [show (2 : Zmod p) = (2 : ℕ) by
      simp ,
    ← legendre_sym_eq_one_iff p hp2, legendre_sym_two p,
    neg_one_pow_eq_one_iff_even
      (show (-1 : ℤ) ≠ 1 by
        decide),
    even_add, even_div, even_div]
  have :=
    Nat.mod_ltₓ p
      (show 0 < 8 by
        decide)
  skip
  rw [fact_iff] at hp1
  revert this hp1
  erw [hpm4, hpm2]
  generalize hm : p % 8 = m
  clear! p
  decide!

theorem exists_sq_eq_prime_iff_of_mod_four_eq_one (hp1 : p % 4 = 1) [hq1 : Fact (q % 2 = 1)] :
    (∃ a : Zmod p, a ^ 2 = q) ↔ ∃ b : Zmod q, b ^ 2 = p :=
  if hpq : p = q then by
    subst hpq
  else by
    have h1 : p / 2 * (q / 2) % 2 = 0 :=
      (dvd_iff_mod_eq_zero _ _).1
        (dvd_mul_of_dvd_left
          ((dvd_iff_mod_eq_zero _ _).2 $ by
            rw [← mod_mul_right_div_self, show 2 * 2 = 4 from rfl, hp1] <;> rfl)
          _)
    have hp_odd : Fact (p % 2 = 1) := ⟨odd_of_mod_four_eq_one hp1⟩
    have hpq0 : (p : Zmod q) ≠ 0 := prime_ne_zero q p (Ne.symm hpq)
    have hqp0 : (q : Zmod p) ≠ 0 := prime_ne_zero p q hpq
    have := quadratic_reciprocity p q hpq
    rw [neg_one_pow_eq_pow_mod_two, h1, legendre_sym, legendre_sym, if_neg hqp0, if_neg hpq0] at this
    rw [euler_criterion q hpq0, euler_criterion p hqp0]
    split_ifs  at this <;> simp [*] <;> contradiction

theorem exists_sq_eq_prime_iff_of_mod_four_eq_three (hp3 : p % 4 = 3) (hq3 : q % 4 = 3) (hpq : p ≠ q) :
    (∃ a : Zmod p, a ^ 2 = q) ↔ ¬∃ b : Zmod q, b ^ 2 = p := by
  have h1 : p / 2 * (q / 2) % 2 = 1 :=
    Nat.odd_mul_odd
      (by
        rw [← mod_mul_right_div_self, show 2 * 2 = 4 from rfl, hp3] <;> rfl)
      (by
        rw [← mod_mul_right_div_self, show 2 * 2 = 4 from rfl, hq3] <;> rfl)
  have hp_odd : Fact (p % 2 = 1) := ⟨odd_of_mod_four_eq_three hp3⟩
  have hq_odd : Fact (q % 2 = 1) := ⟨odd_of_mod_four_eq_three hq3⟩
  have hpq0 : (p : Zmod q) ≠ 0 := prime_ne_zero q p (Ne.symm hpq)
  have hqp0 : (q : Zmod p) ≠ 0 := prime_ne_zero p q hpq
  have := quadratic_reciprocity p q hpq
  rw [neg_one_pow_eq_pow_mod_two, h1, legendre_sym, legendre_sym, if_neg hpq0, if_neg hqp0] at this
  rw [euler_criterion q hpq0, euler_criterion p hqp0]
  split_ifs  at this <;> simp [*] <;> contradiction

end Zmod

