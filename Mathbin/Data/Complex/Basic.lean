/-
Copyright (c) 2017 Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard, Mario Carneiro

! This file was ported from Lean 3 source module data.complex.basic
! leanprover-community/mathlib commit 5a3e819569b0f12cbec59d740a2613018e7b8eec
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Real.Sqrt

/-!
# The complex numbers

The complex numbers are modelled as ℝ^2 in the obvious way and it is shown that they form a field
of characteristic zero. The result that the complex numbers are algebraically closed, see
`field_theory.algebraic_closure`.
-/


open BigOperators

open Set Function

/-! ### Definition and basic arithmmetic -/


/-- Complex numbers consist of two `real`s: a real part `re` and an imaginary part `im`. -/
structure Complex : Type where
  re : ℝ
  im : ℝ
#align complex Complex

-- mathport name: exprℂ
notation "ℂ" => Complex

namespace Complex

open ComplexConjugate

noncomputable instance : DecidableEq ℂ :=
  Classical.decEq _

/-- The equivalence between the complex numbers and `ℝ × ℝ`. -/
@[simps apply]
def equivRealProd : ℂ ≃ ℝ × ℝ where
  toFun z := ⟨z.re, z.im⟩
  invFun p := ⟨p.1, p.2⟩
  left_inv := fun ⟨x, y⟩ => rfl
  right_inv := fun ⟨x, y⟩ => rfl
#align complex.equiv_real_prod Complex.equivRealProd

@[simp]
theorem eta : ∀ z : ℂ, Complex.mk z.re z.im = z
  | ⟨a, b⟩ => rfl
#align complex.eta Complex.eta

@[ext]
theorem ext : ∀ {z w : ℂ}, z.re = w.re → z.im = w.im → z = w
  | ⟨zr, zi⟩, ⟨_, _⟩, rfl, rfl => rfl
#align complex.ext Complex.ext

theorem ext_iff {z w : ℂ} : z = w ↔ z.re = w.re ∧ z.im = w.im :=
  ⟨fun H => by simp [H], And.ndrec ext⟩
#align complex.ext_iff Complex.ext_iff

theorem re_surjective : Surjective re := fun x => ⟨⟨x, 0⟩, rfl⟩
#align complex.re_surjective Complex.re_surjective

theorem im_surjective : Surjective im := fun y => ⟨⟨0, y⟩, rfl⟩
#align complex.im_surjective Complex.im_surjective

@[simp]
theorem range_re : range re = univ :=
  re_surjective.range_eq
#align complex.range_re Complex.range_re

@[simp]
theorem range_im : range im = univ :=
  im_surjective.range_eq
#align complex.range_im Complex.range_im

instance : Coe ℝ ℂ :=
  ⟨fun r => ⟨r, 0⟩⟩

@[simp, norm_cast]
theorem of_real_re (r : ℝ) : (r : ℂ).re = r :=
  rfl
#align complex.of_real_re Complex.of_real_re

@[simp, norm_cast]
theorem of_real_im (r : ℝ) : (r : ℂ).im = 0 :=
  rfl
#align complex.of_real_im Complex.of_real_im

theorem of_real_def (r : ℝ) : (r : ℂ) = ⟨r, 0⟩ :=
  rfl
#align complex.of_real_def Complex.of_real_def

@[simp, norm_cast]
theorem of_real_inj {z w : ℝ} : (z : ℂ) = w ↔ z = w :=
  ⟨congr_arg re, congr_arg _⟩
#align complex.of_real_inj Complex.of_real_inj

theorem of_real_injective : Function.Injective (coe : ℝ → ℂ) := fun z w => congr_arg re
#align complex.of_real_injective Complex.of_real_injective

instance canLift : CanLift ℂ ℝ coe fun z => z.im = 0 where prf z hz := ⟨z.re, ext rfl hz.symm⟩
#align complex.can_lift Complex.canLift

/-- The product of a set on the real axis and a set on the imaginary axis of the complex plane,
denoted by `s ×ℂ t`. -/
def Set.reProdIm (s t : Set ℝ) : Set ℂ :=
  re ⁻¹' s ∩ im ⁻¹' t
#align set.re_prod_im Set.reProdIm

-- mathport name: «expr ×ℂ »
infixl:72 " ×ℂ " => Set.reProdIm

theorem mem_re_prod_im {z : ℂ} {s t : Set ℝ} : z ∈ s ×ℂ t ↔ z.re ∈ s ∧ z.im ∈ t :=
  Iff.rfl
#align complex.mem_re_prod_im Complex.mem_re_prod_im

instance : Zero ℂ :=
  ⟨(0 : ℝ)⟩

instance : Inhabited ℂ :=
  ⟨0⟩

@[simp]
theorem zero_re : (0 : ℂ).re = 0 :=
  rfl
#align complex.zero_re Complex.zero_re

@[simp]
theorem zero_im : (0 : ℂ).im = 0 :=
  rfl
#align complex.zero_im Complex.zero_im

@[simp, norm_cast]
theorem of_real_zero : ((0 : ℝ) : ℂ) = 0 :=
  rfl
#align complex.of_real_zero Complex.of_real_zero

@[simp]
theorem of_real_eq_zero {z : ℝ} : (z : ℂ) = 0 ↔ z = 0 :=
  of_real_inj
#align complex.of_real_eq_zero Complex.of_real_eq_zero

theorem of_real_ne_zero {z : ℝ} : (z : ℂ) ≠ 0 ↔ z ≠ 0 :=
  not_congr of_real_eq_zero
#align complex.of_real_ne_zero Complex.of_real_ne_zero

instance : One ℂ :=
  ⟨(1 : ℝ)⟩

@[simp]
theorem one_re : (1 : ℂ).re = 1 :=
  rfl
#align complex.one_re Complex.one_re

@[simp]
theorem one_im : (1 : ℂ).im = 0 :=
  rfl
#align complex.one_im Complex.one_im

@[simp, norm_cast]
theorem of_real_one : ((1 : ℝ) : ℂ) = 1 :=
  rfl
#align complex.of_real_one Complex.of_real_one

@[simp]
theorem of_real_eq_one {z : ℝ} : (z : ℂ) = 1 ↔ z = 1 :=
  of_real_inj
#align complex.of_real_eq_one Complex.of_real_eq_one

theorem of_real_ne_one {z : ℝ} : (z : ℂ) ≠ 1 ↔ z ≠ 1 :=
  not_congr of_real_eq_one
#align complex.of_real_ne_one Complex.of_real_ne_one

instance : Add ℂ :=
  ⟨fun z w => ⟨z.re + w.re, z.im + w.im⟩⟩

@[simp]
theorem add_re (z w : ℂ) : (z + w).re = z.re + w.re :=
  rfl
#align complex.add_re Complex.add_re

@[simp]
theorem add_im (z w : ℂ) : (z + w).im = z.im + w.im :=
  rfl
#align complex.add_im Complex.add_im

@[simp]
theorem bit0_re (z : ℂ) : (bit0 z).re = bit0 z.re :=
  rfl
#align complex.bit0_re Complex.bit0_re

@[simp]
theorem bit1_re (z : ℂ) : (bit1 z).re = bit1 z.re :=
  rfl
#align complex.bit1_re Complex.bit1_re

@[simp]
theorem bit0_im (z : ℂ) : (bit0 z).im = bit0 z.im :=
  Eq.refl _
#align complex.bit0_im Complex.bit0_im

@[simp]
theorem bit1_im (z : ℂ) : (bit1 z).im = bit0 z.im :=
  add_zero _
#align complex.bit1_im Complex.bit1_im

@[simp, norm_cast]
theorem of_real_add (r s : ℝ) : ((r + s : ℝ) : ℂ) = r + s :=
  ext_iff.2 <| by simp
#align complex.of_real_add Complex.of_real_add

@[simp, norm_cast]
theorem of_real_bit0 (r : ℝ) : ((bit0 r : ℝ) : ℂ) = bit0 r :=
  ext_iff.2 <| by simp [bit0]
#align complex.of_real_bit0 Complex.of_real_bit0

@[simp, norm_cast]
theorem of_real_bit1 (r : ℝ) : ((bit1 r : ℝ) : ℂ) = bit1 r :=
  ext_iff.2 <| by simp [bit1]
#align complex.of_real_bit1 Complex.of_real_bit1

instance : Neg ℂ :=
  ⟨fun z => ⟨-z.re, -z.im⟩⟩

@[simp]
theorem neg_re (z : ℂ) : (-z).re = -z.re :=
  rfl
#align complex.neg_re Complex.neg_re

@[simp]
theorem neg_im (z : ℂ) : (-z).im = -z.im :=
  rfl
#align complex.neg_im Complex.neg_im

@[simp, norm_cast]
theorem of_real_neg (r : ℝ) : ((-r : ℝ) : ℂ) = -r :=
  ext_iff.2 <| by simp
#align complex.of_real_neg Complex.of_real_neg

instance : Sub ℂ :=
  ⟨fun z w => ⟨z.re - w.re, z.im - w.im⟩⟩

instance : Mul ℂ :=
  ⟨fun z w => ⟨z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re⟩⟩

@[simp]
theorem mul_re (z w : ℂ) : (z * w).re = z.re * w.re - z.im * w.im :=
  rfl
#align complex.mul_re Complex.mul_re

@[simp]
theorem mul_im (z w : ℂ) : (z * w).im = z.re * w.im + z.im * w.re :=
  rfl
#align complex.mul_im Complex.mul_im

@[simp, norm_cast]
theorem of_real_mul (r s : ℝ) : ((r * s : ℝ) : ℂ) = r * s :=
  ext_iff.2 <| by simp
#align complex.of_real_mul Complex.of_real_mul

theorem of_real_mul_re (r : ℝ) (z : ℂ) : (↑r * z).re = r * z.re := by simp
#align complex.of_real_mul_re Complex.of_real_mul_re

theorem of_real_mul_im (r : ℝ) (z : ℂ) : (↑r * z).im = r * z.im := by simp
#align complex.of_real_mul_im Complex.of_real_mul_im

theorem of_real_mul' (r : ℝ) (z : ℂ) : ↑r * z = ⟨r * z.re, r * z.im⟩ :=
  ext (of_real_mul_re _ _) (of_real_mul_im _ _)
#align complex.of_real_mul' Complex.of_real_mul'

/-! ### The imaginary unit, `I` -/


/-- The imaginary unit. -/
def i : ℂ :=
  ⟨0, 1⟩
#align complex.I Complex.i

@[simp]
theorem I_re : i.re = 0 :=
  rfl
#align complex.I_re Complex.I_re

@[simp]
theorem I_im : i.im = 1 :=
  rfl
#align complex.I_im Complex.I_im

@[simp]
theorem I_mul_I : I * I = -1 :=
  ext_iff.2 <| by simp
#align complex.I_mul_I Complex.I_mul_I

theorem I_mul (z : ℂ) : I * z = ⟨-z.im, z.re⟩ :=
  ext_iff.2 <| by simp
#align complex.I_mul Complex.I_mul

theorem I_ne_zero : (i : ℂ) ≠ 0 :=
  mt (congr_arg im) zero_ne_one.symm
#align complex.I_ne_zero Complex.I_ne_zero

theorem mk_eq_add_mul_I (a b : ℝ) : Complex.mk a b = a + b * I :=
  ext_iff.2 <| by simp
#align complex.mk_eq_add_mul_I Complex.mk_eq_add_mul_I

@[simp]
theorem re_add_im (z : ℂ) : (z.re : ℂ) + z.im * I = z :=
  ext_iff.2 <| by simp
#align complex.re_add_im Complex.re_add_im

theorem mul_I_re (z : ℂ) : (z * I).re = -z.im := by simp
#align complex.mul_I_re Complex.mul_I_re

theorem mul_I_im (z : ℂ) : (z * I).im = z.re := by simp
#align complex.mul_I_im Complex.mul_I_im

theorem I_mul_re (z : ℂ) : (I * z).re = -z.im := by simp
#align complex.I_mul_re Complex.I_mul_re

theorem I_mul_im (z : ℂ) : (I * z).im = z.re := by simp
#align complex.I_mul_im Complex.I_mul_im

@[simp]
theorem equiv_real_prod_symm_apply (p : ℝ × ℝ) : equivRealProd.symm p = p.1 + p.2 * I := by
  ext <;> simp [equiv_real_prod]
#align complex.equiv_real_prod_symm_apply Complex.equiv_real_prod_symm_apply

/-! ### Commutative ring instance and lemmas -/


/- We use a nonstandard formula for the `ℕ` and `ℤ` actions to make sure there is no
diamond from the other actions they inherit through the `ℝ`-action on `ℂ` and action transitivity
defined in `data.complex.module.lean`. -/
instance : Nontrivial ℂ :=
  pullback_nonzero re rfl rfl

instance : AddCommGroup ℂ := by
  refine_struct { zero := (0 : ℂ)
                  add := (· + ·)
                  neg := Neg.neg
                  sub := Sub.sub
                  nsmul := fun n z => ⟨n • z.re - 0 * z.im, n • z.im + 0 * z.re⟩
                  zsmul := fun n z => ⟨n • z.re - 0 * z.im, n • z.im + 0 * z.re⟩ } <;> intros <;>
            try rfl <;> apply ext_iff.2 <;> constructor <;> simp <;> · first |ring1|ring_nf

instance : AddGroupWithOne ℂ :=
  { Complex.addCommGroup with
    natCast := fun n => ⟨n, 0⟩
    nat_cast_zero := by ext <;> simp [Nat.cast]
    nat_cast_succ := fun _ => by ext <;> simp [Nat.cast]
    intCast := fun n => ⟨n, 0⟩
    int_cast_of_nat := fun _ => by ext <;> simp [fun n => show @coe ℕ ℂ ⟨_⟩ n = ⟨n, 0⟩ from rfl]
    int_cast_neg_succ_of_nat := fun _ => by
      ext <;> simp [fun n => show @coe ℕ ℂ ⟨_⟩ n = ⟨n, 0⟩ from rfl]
    one := 1 }

instance : CommRing ℂ := by
  refine_struct
                { Complex.addGroupWithOne with
                  zero := (0 : ℂ)
                  add := (· + ·)
                  one := 1
                  mul := (· * ·)
                  npow := @npowRec _ ⟨(1 : ℂ)⟩ ⟨(· * ·)⟩ } <;>
              intros <;>
            try rfl <;>
          apply ext_iff.2 <;>
        constructor <;>
      simp <;>
    · first |ring1|ring_nf

/-- This shortcut instance ensures we do not find `ring` via the noncomputable `complex.field`
instance. -/
instance : Ring ℂ := by infer_instance

/-- This shortcut instance ensures we do not find `comm_semiring` via the noncomputable
`complex.field` instance. -/
instance : CommSemiring ℂ :=
  inferInstance

/-- The "real part" map, considered as an additive group homomorphism. -/
def reAddGroupHom : ℂ →+ ℝ where
  toFun := re
  map_zero' := zero_re
  map_add' := add_re
#align complex.re_add_group_hom Complex.reAddGroupHom

@[simp]
theorem coe_re_add_group_hom : (reAddGroupHom : ℂ → ℝ) = re :=
  rfl
#align complex.coe_re_add_group_hom Complex.coe_re_add_group_hom

/-- The "imaginary part" map, considered as an additive group homomorphism. -/
def imAddGroupHom : ℂ →+ ℝ where
  toFun := im
  map_zero' := zero_im
  map_add' := add_im
#align complex.im_add_group_hom Complex.imAddGroupHom

@[simp]
theorem coe_im_add_group_hom : (imAddGroupHom : ℂ → ℝ) = im :=
  rfl
#align complex.coe_im_add_group_hom Complex.coe_im_add_group_hom

@[simp]
theorem I_pow_bit0 (n : ℕ) : I ^ bit0 n = (-1) ^ n := by rw [pow_bit0', I_mul_I]
#align complex.I_pow_bit0 Complex.I_pow_bit0

@[simp]
theorem I_pow_bit1 (n : ℕ) : I ^ bit1 n = (-1) ^ n * I := by rw [pow_bit1', I_mul_I]
#align complex.I_pow_bit1 Complex.I_pow_bit1

/-! ### Complex conjugation -/


/-- This defines the complex conjugate as the `star` operation of the `star_ring ℂ`. It
is recommended to use the ring endomorphism version `star_ring_end`, available under the
notation `conj` in the locale `complex_conjugate`. -/
instance : StarRing ℂ where
  star z := ⟨z.re, -z.im⟩
  star_involutive x := by simp only [eta, neg_neg]
  star_mul a b := by ext <;> simp [add_comm] <;> ring
  star_add a b := by ext <;> simp [add_comm]

@[simp]
theorem conj_re (z : ℂ) : (conj z).re = z.re :=
  rfl
#align complex.conj_re Complex.conj_re

@[simp]
theorem conj_im (z : ℂ) : (conj z).im = -z.im :=
  rfl
#align complex.conj_im Complex.conj_im

theorem conj_of_real (r : ℝ) : conj (r : ℂ) = r :=
  ext_iff.2 <| by simp [conj]
#align complex.conj_of_real Complex.conj_of_real

@[simp]
theorem conj_I : conj i = -I :=
  ext_iff.2 <| by simp
#align complex.conj_I Complex.conj_I

theorem conj_bit0 (z : ℂ) : conj (bit0 z) = bit0 (conj z) :=
  ext_iff.2 <| by simp [bit0]
#align complex.conj_bit0 Complex.conj_bit0

theorem conj_bit1 (z : ℂ) : conj (bit1 z) = bit1 (conj z) :=
  ext_iff.2 <| by simp [bit0]
#align complex.conj_bit1 Complex.conj_bit1

@[simp]
theorem conj_neg_I : conj (-I) = I :=
  ext_iff.2 <| by simp
#align complex.conj_neg_I Complex.conj_neg_I

theorem eq_conj_iff_real {z : ℂ} : conj z = z ↔ ∃ r : ℝ, z = r :=
  ⟨fun h => ⟨z.re, ext rfl <| eq_zero_of_neg_eq (congr_arg im h)⟩, fun ⟨h, e⟩ => by
    rw [e, conj_of_real]⟩
#align complex.eq_conj_iff_real Complex.eq_conj_iff_real

theorem eq_conj_iff_re {z : ℂ} : conj z = z ↔ (z.re : ℂ) = z :=
  eq_conj_iff_real.trans ⟨by rintro ⟨r, rfl⟩ <;> simp, fun h => ⟨_, h.symm⟩⟩
#align complex.eq_conj_iff_re Complex.eq_conj_iff_re

theorem eq_conj_iff_im {z : ℂ} : conj z = z ↔ z.im = 0 :=
  ⟨fun h => add_self_eq_zero.mp (neg_eq_iff_add_eq_zero.mp (congr_arg im h)), fun h =>
    ext rfl (neg_eq_iff_add_eq_zero.mpr (add_self_eq_zero.mpr h))⟩
#align complex.eq_conj_iff_im Complex.eq_conj_iff_im

-- `simp_nf` complains about this being provable by `is_R_or_C.star_def` even
-- though it's not imported by this file.
@[simp, nolint simp_nf]
theorem star_def : (HasStar.star : ℂ → ℂ) = conj :=
  rfl
#align complex.star_def Complex.star_def

/-! ### Norm squared -/


/-- The norm squared function. -/
@[pp_nodot]
def normSq : ℂ →*₀ ℝ where
  toFun z := z.re * z.re + z.im * z.im
  map_zero' := by simp
  map_one' := by simp
  map_mul' z w := by
    dsimp
    ring
#align complex.norm_sq Complex.normSq

theorem norm_sq_apply (z : ℂ) : normSq z = z.re * z.re + z.im * z.im :=
  rfl
#align complex.norm_sq_apply Complex.norm_sq_apply

@[simp]
theorem norm_sq_of_real (r : ℝ) : normSq r = r * r := by simp [norm_sq]
#align complex.norm_sq_of_real Complex.norm_sq_of_real

@[simp]
theorem norm_sq_mk (x y : ℝ) : normSq ⟨x, y⟩ = x * x + y * y :=
  rfl
#align complex.norm_sq_mk Complex.norm_sq_mk

theorem norm_sq_add_mul_I (x y : ℝ) : normSq (x + y * I) = x ^ 2 + y ^ 2 := by
  rw [← mk_eq_add_mul_I, norm_sq_mk, sq, sq]
#align complex.norm_sq_add_mul_I Complex.norm_sq_add_mul_I

theorem norm_sq_eq_conj_mul_self {z : ℂ} : (normSq z : ℂ) = conj z * z := by
  ext <;> simp [norm_sq, mul_comm]
#align complex.norm_sq_eq_conj_mul_self Complex.norm_sq_eq_conj_mul_self

@[simp]
theorem norm_sq_zero : normSq 0 = 0 :=
  normSq.map_zero
#align complex.norm_sq_zero Complex.norm_sq_zero

@[simp]
theorem norm_sq_one : normSq 1 = 1 :=
  normSq.map_one
#align complex.norm_sq_one Complex.norm_sq_one

@[simp]
theorem norm_sq_I : normSq i = 1 := by simp [norm_sq]
#align complex.norm_sq_I Complex.norm_sq_I

theorem norm_sq_nonneg (z : ℂ) : 0 ≤ normSq z :=
  add_nonneg (mul_self_nonneg _) (mul_self_nonneg _)
#align complex.norm_sq_nonneg Complex.norm_sq_nonneg

@[simp]
theorem range_norm_sq : range normSq = Ici 0 :=
  (Subset.antisymm (range_subset_iff.2 norm_sq_nonneg)) fun x hx =>
    ⟨Real.sqrt x, by rw [norm_sq_of_real, Real.mul_self_sqrt hx]⟩
#align complex.range_norm_sq Complex.range_norm_sq

theorem norm_sq_eq_zero {z : ℂ} : normSq z = 0 ↔ z = 0 :=
  ⟨fun h =>
    ext (eq_zero_of_mul_self_add_mul_self_eq_zero h)
      (eq_zero_of_mul_self_add_mul_self_eq_zero <| (add_comm _ _).trans h),
    fun h => h.symm ▸ norm_sq_zero⟩
#align complex.norm_sq_eq_zero Complex.norm_sq_eq_zero

@[simp]
theorem norm_sq_pos {z : ℂ} : 0 < normSq z ↔ z ≠ 0 :=
  (norm_sq_nonneg z).lt_iff_ne.trans <| not_congr (eq_comm.trans norm_sq_eq_zero)
#align complex.norm_sq_pos Complex.norm_sq_pos

@[simp]
theorem norm_sq_neg (z : ℂ) : normSq (-z) = normSq z := by simp [norm_sq]
#align complex.norm_sq_neg Complex.norm_sq_neg

@[simp]
theorem norm_sq_conj (z : ℂ) : normSq (conj z) = normSq z := by simp [norm_sq]
#align complex.norm_sq_conj Complex.norm_sq_conj

theorem norm_sq_mul (z w : ℂ) : normSq (z * w) = normSq z * normSq w :=
  normSq.map_mul z w
#align complex.norm_sq_mul Complex.norm_sq_mul

theorem norm_sq_add (z w : ℂ) : normSq (z + w) = normSq z + normSq w + 2 * (z * conj w).re := by
  dsimp [norm_sq] <;> ring
#align complex.norm_sq_add Complex.norm_sq_add

theorem re_sq_le_norm_sq (z : ℂ) : z.re * z.re ≤ normSq z :=
  le_add_of_nonneg_right (mul_self_nonneg _)
#align complex.re_sq_le_norm_sq Complex.re_sq_le_norm_sq

theorem im_sq_le_norm_sq (z : ℂ) : z.im * z.im ≤ normSq z :=
  le_add_of_nonneg_left (mul_self_nonneg _)
#align complex.im_sq_le_norm_sq Complex.im_sq_le_norm_sq

theorem mul_conj (z : ℂ) : z * conj z = normSq z :=
  ext_iff.2 <| by simp [norm_sq, mul_comm, sub_eq_neg_add, add_comm]
#align complex.mul_conj Complex.mul_conj

theorem add_conj (z : ℂ) : z + conj z = (2 * z.re : ℝ) :=
  ext_iff.2 <| by simp [two_mul]
#align complex.add_conj Complex.add_conj

/-- The coercion `ℝ → ℂ` as a `ring_hom`. -/
def ofReal : ℝ →+* ℂ :=
  ⟨coe, of_real_one, of_real_mul, of_real_zero, of_real_add⟩
#align complex.of_real Complex.ofReal

@[simp]
theorem of_real_eq_coe (r : ℝ) : ofReal r = r :=
  rfl
#align complex.of_real_eq_coe Complex.of_real_eq_coe

@[simp]
theorem I_sq : I ^ 2 = -1 := by rw [sq, I_mul_I]
#align complex.I_sq Complex.I_sq

@[simp]
theorem sub_re (z w : ℂ) : (z - w).re = z.re - w.re :=
  rfl
#align complex.sub_re Complex.sub_re

@[simp]
theorem sub_im (z w : ℂ) : (z - w).im = z.im - w.im :=
  rfl
#align complex.sub_im Complex.sub_im

@[simp, norm_cast]
theorem of_real_sub (r s : ℝ) : ((r - s : ℝ) : ℂ) = r - s :=
  ext_iff.2 <| by simp
#align complex.of_real_sub Complex.of_real_sub

@[simp, norm_cast]
theorem of_real_pow (r : ℝ) (n : ℕ) : ((r ^ n : ℝ) : ℂ) = r ^ n := by
  induction n <;> simp [*, of_real_mul, pow_succ]
#align complex.of_real_pow Complex.of_real_pow

theorem sub_conj (z : ℂ) : z - conj z = (2 * z.im : ℝ) * I :=
  ext_iff.2 <| by simp [two_mul, sub_eq_add_neg]
#align complex.sub_conj Complex.sub_conj

theorem norm_sq_sub (z w : ℂ) : normSq (z - w) = normSq z + normSq w - 2 * (z * conj w).re :=
  by
  rw [sub_eq_add_neg, norm_sq_add]
  simp only [RingHom.map_neg, mul_neg, neg_re, Tactic.Ring.add_neg_eq_sub, norm_sq_neg]
#align complex.norm_sq_sub Complex.norm_sq_sub

/-! ### Inversion -/


noncomputable instance : Inv ℂ :=
  ⟨fun z => conj z * ((normSq z)⁻¹ : ℝ)⟩

theorem inv_def (z : ℂ) : z⁻¹ = conj z * ((normSq z)⁻¹ : ℝ) :=
  rfl
#align complex.inv_def Complex.inv_def

@[simp]
theorem inv_re (z : ℂ) : z⁻¹.re = z.re / normSq z := by simp [inv_def, division_def]
#align complex.inv_re Complex.inv_re

@[simp]
theorem inv_im (z : ℂ) : z⁻¹.im = -z.im / normSq z := by simp [inv_def, division_def]
#align complex.inv_im Complex.inv_im

@[simp, norm_cast]
theorem of_real_inv (r : ℝ) : ((r⁻¹ : ℝ) : ℂ) = r⁻¹ :=
  ext_iff.2 <| by simp
#align complex.of_real_inv Complex.of_real_inv

protected theorem inv_zero : (0⁻¹ : ℂ) = 0 := by rw [← of_real_zero, ← of_real_inv, inv_zero]
#align complex.inv_zero Complex.inv_zero

protected theorem mul_inv_cancel {z : ℂ} (h : z ≠ 0) : z * z⁻¹ = 1 := by
  rw [inv_def, ← mul_assoc, mul_conj, ← of_real_mul, mul_inv_cancel (mt norm_sq_eq_zero.1 h),
    of_real_one]
#align complex.mul_inv_cancel Complex.mul_inv_cancel

/-! ### Field instance and lemmas -/


noncomputable instance : Field ℂ :=
  { Complex.commRing, Complex.nontrivial with
    inv := Inv.inv
    mul_inv_cancel := @Complex.mul_inv_cancel
    inv_zero := Complex.inv_zero }

@[simp]
theorem I_zpow_bit0 (n : ℤ) : I ^ bit0 n = (-1) ^ n := by rw [zpow_bit0', I_mul_I]
#align complex.I_zpow_bit0 Complex.I_zpow_bit0

@[simp]
theorem I_zpow_bit1 (n : ℤ) : I ^ bit1 n = (-1) ^ n * I := by rw [zpow_bit1', I_mul_I]
#align complex.I_zpow_bit1 Complex.I_zpow_bit1

theorem div_re (z w : ℂ) : (z / w).re = z.re * w.re / normSq w + z.im * w.im / normSq w := by
  simp [div_eq_mul_inv, mul_assoc, sub_eq_add_neg]
#align complex.div_re Complex.div_re

theorem div_im (z w : ℂ) : (z / w).im = z.im * w.re / normSq w - z.re * w.im / normSq w := by
  simp [div_eq_mul_inv, mul_assoc, sub_eq_add_neg, add_comm]
#align complex.div_im Complex.div_im

theorem conj_inv (x : ℂ) : conj x⁻¹ = (conj x)⁻¹ :=
  star_inv' _
#align complex.conj_inv Complex.conj_inv

@[simp, norm_cast]
theorem of_real_div (r s : ℝ) : ((r / s : ℝ) : ℂ) = r / s :=
  map_div₀ ofReal r s
#align complex.of_real_div Complex.of_real_div

@[simp, norm_cast]
theorem of_real_zpow (r : ℝ) (n : ℤ) : ((r ^ n : ℝ) : ℂ) = (r : ℂ) ^ n :=
  map_zpow₀ ofReal r n
#align complex.of_real_zpow Complex.of_real_zpow

@[simp]
theorem div_I (z : ℂ) : z / I = -(z * I) :=
  (div_eq_iff_mul_eq I_ne_zero).2 <| by simp [mul_assoc]
#align complex.div_I Complex.div_I

@[simp]
theorem inv_I : I⁻¹ = -I := by simp [inv_eq_one_div]
#align complex.inv_I Complex.inv_I

@[simp]
theorem norm_sq_inv (z : ℂ) : normSq z⁻¹ = (normSq z)⁻¹ :=
  map_inv₀ normSq z
#align complex.norm_sq_inv Complex.norm_sq_inv

@[simp]
theorem norm_sq_div (z w : ℂ) : normSq (z / w) = normSq z / normSq w :=
  map_div₀ normSq z w
#align complex.norm_sq_div Complex.norm_sq_div

/-! ### Cast lemmas -/


@[simp, norm_cast]
theorem of_real_nat_cast (n : ℕ) : ((n : ℝ) : ℂ) = n :=
  map_nat_cast ofReal n
#align complex.of_real_nat_cast Complex.of_real_nat_cast

@[simp, norm_cast]
theorem nat_cast_re (n : ℕ) : (n : ℂ).re = n := by rw [← of_real_nat_cast, of_real_re]
#align complex.nat_cast_re Complex.nat_cast_re

@[simp, norm_cast]
theorem nat_cast_im (n : ℕ) : (n : ℂ).im = 0 := by rw [← of_real_nat_cast, of_real_im]
#align complex.nat_cast_im Complex.nat_cast_im

@[simp, norm_cast]
theorem of_real_int_cast (n : ℤ) : ((n : ℝ) : ℂ) = n :=
  map_int_cast ofReal n
#align complex.of_real_int_cast Complex.of_real_int_cast

@[simp, norm_cast]
theorem int_cast_re (n : ℤ) : (n : ℂ).re = n := by rw [← of_real_int_cast, of_real_re]
#align complex.int_cast_re Complex.int_cast_re

@[simp, norm_cast]
theorem int_cast_im (n : ℤ) : (n : ℂ).im = 0 := by rw [← of_real_int_cast, of_real_im]
#align complex.int_cast_im Complex.int_cast_im

@[simp, norm_cast]
theorem of_real_rat_cast (n : ℚ) : ((n : ℝ) : ℂ) = n :=
  map_ratCast ofReal n
#align complex.of_real_rat_cast Complex.of_real_rat_cast

@[simp, norm_cast]
theorem rat_cast_re (q : ℚ) : (q : ℂ).re = q := by rw [← of_real_rat_cast, of_real_re]
#align complex.rat_cast_re Complex.rat_cast_re

@[simp, norm_cast]
theorem rat_cast_im (q : ℚ) : (q : ℂ).im = 0 := by rw [← of_real_rat_cast, of_real_im]
#align complex.rat_cast_im Complex.rat_cast_im

/-! ### Characteristic zero -/


instance char_zero_complex : CharZero ℂ :=
  charZero_of_inj_zero fun n h => by
    rwa [← of_real_nat_cast, of_real_eq_zero, Nat.cast_eq_zero] at h
#align complex.char_zero_complex Complex.char_zero_complex

/-- A complex number `z` plus its conjugate `conj z` is `2` times its real part. -/
theorem re_eq_add_conj (z : ℂ) : (z.re : ℂ) = (z + conj z) / 2 := by
  simp only [add_conj, of_real_mul, of_real_one, of_real_bit0,
    mul_div_cancel_left (z.re : ℂ) two_ne_zero]
#align complex.re_eq_add_conj Complex.re_eq_add_conj

/-- A complex number `z` minus its conjugate `conj z` is `2i` times its imaginary part. -/
theorem im_eq_sub_conj (z : ℂ) : (z.im : ℂ) = (z - conj z) / (2 * I) := by
  simp only [sub_conj, of_real_mul, of_real_one, of_real_bit0, mul_right_comm,
    mul_div_cancel_left _ (mul_ne_zero two_ne_zero I_ne_zero : 2 * I ≠ 0)]
#align complex.im_eq_sub_conj Complex.im_eq_sub_conj

/-! ### Absolute value -/


namespace AbsTheory

-- mathport name: abs
-- We develop enough theory to bundle `abs` into an `absolute_value` before making things public;
-- this is so there's not two versions of it hanging around.
local notation "abs" z => (normSq z).sqrt

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [(Command.private "private")] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `mul_self_abs [])
      (Command.declSig
       [(Term.explicitBinder "(" [`z] [":" (Data.Complex.Basic.termℂ "ℂ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         («term_*_»
          (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
          "*"
          (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))
         "="
         (Term.app `normSq [`z]))))
      (Command.declValSimple
       ":="
       (Term.app `Real.mul_self_sqrt [(Term.app `norm_sq_nonneg [(Term.hole "_")])])
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Real.mul_self_sqrt [(Term.app `norm_sq_nonneg [(Term.hole "_")])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `norm_sq_nonneg [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `norm_sq_nonneg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `norm_sq_nonneg [(Term.hole "_")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Real.mul_self_sqrt
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       («term_*_»
        (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
        "*"
        (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))
       "="
       (Term.app `normSq [`z]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `normSq [`z])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `z
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `normSq
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 51 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 50, term))
      («term_*_»
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
       "*"
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
private
  theorem mul_self_abs ( z : ℂ ) : abs z * abs z = normSq z := Real.mul_self_sqrt norm_sq_nonneg _
#align complex.abs_theory.mul_self_abs complex.abs_theory.mul_self_abs

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [(Command.private "private")] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `abs_nonneg' [])
      (Command.declSig
       [(Term.explicitBinder "(" [`z] [":" (Data.Complex.Basic.termℂ "ℂ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_≤_» (num "0") "≤" (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))))
      (Command.declValSimple ":=" (Term.app `Real.sqrt_nonneg [(Term.hole "_")]) [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Real.sqrt_nonneg [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Real.sqrt_nonneg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_≤_» (num "0") "≤" (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
private theorem abs_nonneg' ( z : ℂ ) : 0 ≤ abs z := Real.sqrt_nonneg _
#align complex.abs_theory.abs_nonneg' complex.abs_theory.abs_nonneg'

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `abs_conj [])
      (Command.declSig
       [(Term.explicitBinder "(" [`z] [":" (Data.Complex.Basic.termℂ "ℂ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Complex.AbsTheory.Data.Complex.Basic.abs
          "abs"
          (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`z]))
         "="
         (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq (Tactic.tacticSeq1Indented [(Tactic.simp "simp" [] [] [] [] [])])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq (Tactic.tacticSeq1Indented [(Tactic.simp "simp" [] [] [] [] [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.simp "simp" [] [] [] [] [])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       (Complex.AbsTheory.Data.Complex.Basic.abs
        "abs"
        (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`z]))
       "="
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem abs_conj ( z : ℂ ) : abs conj z = abs z := by simp
#align complex.abs_theory.abs_conj Complex.AbsTheory.abs_conj

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [(Command.private "private")] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `abs_re_le_abs [])
      (Command.declSig
       [(Term.explicitBinder "(" [`z] [":" (Data.Complex.Basic.termℂ "ℂ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_≤_»
         («term|___|» (group "|") (Term.proj `z "." `re) (group) "|")
         "≤"
         (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule
               []
               (Term.app
                `mul_self_le_mul_self_iff
                [(Term.app `abs_nonneg [`z.re]) (Term.app `abs_nonneg' [(Term.hole "_")])]))
              ","
              (Tactic.rwRule [] `abs_mul_abs_self)
              ","
              (Tactic.rwRule [] `mul_self_abs)]
             "]")
            [])
           []
           (Tactic.apply "apply" `re_sq_le_norm_sq)])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule
              []
              (Term.app
               `mul_self_le_mul_self_iff
               [(Term.app `abs_nonneg [`z.re]) (Term.app `abs_nonneg' [(Term.hole "_")])]))
             ","
             (Tactic.rwRule [] `abs_mul_abs_self)
             ","
             (Tactic.rwRule [] `mul_self_abs)]
            "]")
           [])
          []
          (Tactic.apply "apply" `re_sq_le_norm_sq)])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.apply "apply" `re_sq_le_norm_sq)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `re_sq_le_norm_sq
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule
          []
          (Term.app
           `mul_self_le_mul_self_iff
           [(Term.app `abs_nonneg [`z.re]) (Term.app `abs_nonneg' [(Term.hole "_")])]))
         ","
         (Tactic.rwRule [] `abs_mul_abs_self)
         ","
         (Tactic.rwRule [] `mul_self_abs)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mul_self_abs
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `abs_mul_abs_self
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `mul_self_le_mul_self_iff
       [(Term.app `abs_nonneg [`z.re]) (Term.app `abs_nonneg' [(Term.hole "_")])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `abs_nonneg' [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_nonneg'
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `abs_nonneg' [(Term.hole "_")])
     ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `abs_nonneg [`z.re])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `z.re
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_nonneg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `abs_nonneg [`z.re]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `mul_self_le_mul_self_iff
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_≤_»
       («term|___|» (group "|") (Term.proj `z "." `re) (group) "|")
       "≤"
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
private
  theorem
    abs_re_le_abs
    ( z : ℂ ) : | z . re | ≤ abs z
    :=
      by
        rw
            [
              mul_self_le_mul_self_iff abs_nonneg z.re abs_nonneg' _
                ,
                abs_mul_abs_self
                ,
                mul_self_abs
              ]
          apply re_sq_le_norm_sq
#align complex.abs_theory.abs_re_le_abs complex.abs_theory.abs_re_le_abs

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [(Command.private "private")] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `re_le_abs [])
      (Command.declSig
       [(Term.explicitBinder "(" [`z] [":" (Data.Complex.Basic.termℂ "ℂ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_≤_» (Term.proj `z "." `re) "≤" (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))))
      (Command.declValSimple
       ":="
       (Term.proj
        (Term.app
         (Term.proj `abs_le "." (fieldIdx "1"))
         [(Term.app `abs_re_le_abs [(Term.hole "_")])])
        "."
        (fieldIdx "2"))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj
       (Term.app
        (Term.proj `abs_le "." (fieldIdx "1"))
        [(Term.app `abs_re_le_abs [(Term.hole "_")])])
       "."
       (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app
       (Term.proj `abs_le "." (fieldIdx "1"))
       [(Term.app `abs_re_le_abs [(Term.hole "_")])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `abs_re_le_abs [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_re_le_abs
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `abs_re_le_abs [(Term.hole "_")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `abs_le "." (fieldIdx "1"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `abs_le
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app
      (Term.proj `abs_le "." (fieldIdx "1"))
      [(Term.paren "(" (Term.app `abs_re_le_abs [(Term.hole "_")]) ")")])
     ")")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_≤_» (Term.proj `z "." `re) "≤" (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
private theorem re_le_abs ( z : ℂ ) : z . re ≤ abs z := abs_le . 1 abs_re_le_abs _ . 2
#align complex.abs_theory.re_le_abs complex.abs_theory.re_le_abs

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [(Command.private "private")] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `abs_mul [])
      (Command.declSig
       [(Term.explicitBinder "(" [`z `w] [":" (Data.Complex.Basic.termℂ "ℂ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_=_»
         (Complex.AbsTheory.Data.Complex.Basic.abs "abs" («term_*_» `z "*" `w))
         "="
         («term_*_»
          (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
          "*"
          (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w)))))
      (Command.declValSimple
       ":="
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] `norm_sq_mul)
              ","
              (Tactic.rwRule
               []
               (Term.app `Real.sqrt_mul [(Term.app `norm_sq_nonneg [(Term.hole "_")])]))]
             "]")
            [])])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `norm_sq_mul)
             ","
             (Tactic.rwRule
              []
              (Term.app `Real.sqrt_mul [(Term.app `norm_sq_nonneg [(Term.hole "_")])]))]
            "]")
           [])])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `norm_sq_mul)
         ","
         (Tactic.rwRule
          []
          (Term.app `Real.sqrt_mul [(Term.app `norm_sq_nonneg [(Term.hole "_")])]))]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `Real.sqrt_mul [(Term.app `norm_sq_nonneg [(Term.hole "_")])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `norm_sq_nonneg [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `norm_sq_nonneg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `norm_sq_nonneg [(Term.hole "_")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `Real.sqrt_mul
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `norm_sq_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_=_»
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" («term_*_» `z "*" `w))
       "="
       («term_*_»
        (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
        "*"
        (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_*_»
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
       "*"
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
private
  theorem
    abs_mul
    ( z w : ℂ ) : abs z * w = abs z * abs w
    := by rw [ norm_sq_mul , Real.sqrt_mul norm_sq_nonneg _ ]
#align complex.abs_theory.abs_mul complex.abs_theory.abs_mul

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [(Command.private "private")] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `abs_add [])
      (Command.declSig
       [(Term.explicitBinder "(" [`z `w] [":" (Data.Complex.Basic.termℂ "ℂ")] [] ")")]
       (Term.typeSpec
        ":"
        («term_≤_»
         (Complex.AbsTheory.Data.Complex.Basic.abs "abs" («term_+_» `z "+" `w))
         "≤"
         («term_+_»
          (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
          "+"
          (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w)))))
      (Command.declValSimple
       ":="
       («term_<|_»
        (Term.proj
         (Term.app
          `mul_self_le_mul_self_iff
          [(Term.app `abs_nonneg' [(«term_+_» `z "+" `w)])
           (Term.app `add_nonneg [(Term.app `abs_nonneg' [`z]) (Term.app `abs_nonneg' [`w])])])
         "."
         (fieldIdx "2"))
        "<|"
        (Term.byTactic
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Tactic.rwSeq
             "rw"
             []
             (Tactic.rwRuleSeq
              "["
              [(Tactic.rwRule [] `mul_self_abs)
               ","
               (Tactic.rwRule [] `add_mul_self_eq)
               ","
               (Tactic.rwRule [] `mul_self_abs)
               ","
               (Tactic.rwRule [] `mul_self_abs)
               ","
               (Tactic.rwRule [] `add_right_comm)
               ","
               (Tactic.rwRule [] `norm_sq_add)
               ","
               (Tactic.rwRule [] `add_le_add_iff_left)
               ","
               (Tactic.rwRule [] `mul_assoc)
               ","
               (Tactic.rwRule
                []
                (Term.app
                 `mul_le_mul_left
                 [(Term.app `zero_lt_two' [(Data.Real.Basic.termℝ "ℝ")])]))
               ","
               (Tactic.rwRule
                [(patternIgnore (token.«← » "←"))]
                («term_<|_» `Real.sqrt_mul "<|" (Term.app `norm_sq_nonneg [`z])))
               ","
               (Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `norm_sq_conj [`w]))
               ","
               (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `map_mul)]
              "]")
             [])
            []
            (Tactic.exact
             "exact"
             (Term.app
              `re_le_abs
              [(«term_*_»
                `z
                "*"
                (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w]))]))]))))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_<|_»
       (Term.proj
        (Term.app
         `mul_self_le_mul_self_iff
         [(Term.app `abs_nonneg' [(«term_+_» `z "+" `w)])
          (Term.app `add_nonneg [(Term.app `abs_nonneg' [`z]) (Term.app `abs_nonneg' [`w])])])
        "."
        (fieldIdx "2"))
       "<|"
       (Term.byTactic
        "by"
        (Tactic.tacticSeq
         (Tactic.tacticSeq1Indented
          [(Tactic.rwSeq
            "rw"
            []
            (Tactic.rwRuleSeq
             "["
             [(Tactic.rwRule [] `mul_self_abs)
              ","
              (Tactic.rwRule [] `add_mul_self_eq)
              ","
              (Tactic.rwRule [] `mul_self_abs)
              ","
              (Tactic.rwRule [] `mul_self_abs)
              ","
              (Tactic.rwRule [] `add_right_comm)
              ","
              (Tactic.rwRule [] `norm_sq_add)
              ","
              (Tactic.rwRule [] `add_le_add_iff_left)
              ","
              (Tactic.rwRule [] `mul_assoc)
              ","
              (Tactic.rwRule
               []
               (Term.app `mul_le_mul_left [(Term.app `zero_lt_two' [(Data.Real.Basic.termℝ "ℝ")])]))
              ","
              (Tactic.rwRule
               [(patternIgnore (token.«← » "←"))]
               («term_<|_» `Real.sqrt_mul "<|" (Term.app `norm_sq_nonneg [`z])))
              ","
              (Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `norm_sq_conj [`w]))
              ","
              (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `map_mul)]
             "]")
            [])
           []
           (Tactic.exact
            "exact"
            (Term.app
             `re_le_abs
             [(«term_*_»
               `z
               "*"
               (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w]))]))]))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Tactic.rwSeq
           "rw"
           []
           (Tactic.rwRuleSeq
            "["
            [(Tactic.rwRule [] `mul_self_abs)
             ","
             (Tactic.rwRule [] `add_mul_self_eq)
             ","
             (Tactic.rwRule [] `mul_self_abs)
             ","
             (Tactic.rwRule [] `mul_self_abs)
             ","
             (Tactic.rwRule [] `add_right_comm)
             ","
             (Tactic.rwRule [] `norm_sq_add)
             ","
             (Tactic.rwRule [] `add_le_add_iff_left)
             ","
             (Tactic.rwRule [] `mul_assoc)
             ","
             (Tactic.rwRule
              []
              (Term.app `mul_le_mul_left [(Term.app `zero_lt_two' [(Data.Real.Basic.termℝ "ℝ")])]))
             ","
             (Tactic.rwRule
              [(patternIgnore (token.«← » "←"))]
              («term_<|_» `Real.sqrt_mul "<|" (Term.app `norm_sq_nonneg [`z])))
             ","
             (Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `norm_sq_conj [`w]))
             ","
             (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `map_mul)]
            "]")
           [])
          []
          (Tactic.exact
           "exact"
           (Term.app
            `re_le_abs
            [(«term_*_»
              `z
              "*"
              (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w]))]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.exact
       "exact"
       (Term.app
        `re_le_abs
        [(«term_*_»
          `z
          "*"
          (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w]))]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `re_le_abs
       [(«term_*_»
         `z
         "*"
         (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w]))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_*_»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_*_»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_*_» `z "*" (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `w
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 71 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 70, term))
      `z
[PrettyPrinter.parenthesize] ...precedences are 70 >? 1024, (none, [anonymous]) <=? (some 70, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 70, (some 71, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_*_» `z "*" (Term.app (ComplexConjugate.Algebra.Star.Basic.star_ring_end "conj") [`w]))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `re_le_abs
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Tactic.rwSeq
       "rw"
       []
       (Tactic.rwRuleSeq
        "["
        [(Tactic.rwRule [] `mul_self_abs)
         ","
         (Tactic.rwRule [] `add_mul_self_eq)
         ","
         (Tactic.rwRule [] `mul_self_abs)
         ","
         (Tactic.rwRule [] `mul_self_abs)
         ","
         (Tactic.rwRule [] `add_right_comm)
         ","
         (Tactic.rwRule [] `norm_sq_add)
         ","
         (Tactic.rwRule [] `add_le_add_iff_left)
         ","
         (Tactic.rwRule [] `mul_assoc)
         ","
         (Tactic.rwRule
          []
          (Term.app `mul_le_mul_left [(Term.app `zero_lt_two' [(Data.Real.Basic.termℝ "ℝ")])]))
         ","
         (Tactic.rwRule
          [(patternIgnore (token.«← » "←"))]
          («term_<|_» `Real.sqrt_mul "<|" (Term.app `norm_sq_nonneg [`z])))
         ","
         (Tactic.rwRule [(patternIgnore (token.«← » "←"))] (Term.app `norm_sq_conj [`w]))
         ","
         (Tactic.rwRule [(patternIgnore (token.«← » "←"))] `map_mul)]
        "]")
       [])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `map_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `norm_sq_conj [`w])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `w
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `norm_sq_conj
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_<|_» `Real.sqrt_mul "<|" (Term.app `norm_sq_nonneg [`z]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `norm_sq_nonneg [`z])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `z
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `norm_sq_nonneg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 10 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 10, term))
      `Real.sqrt_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 10, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 10, (some 10, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `mul_le_mul_left [(Term.app `zero_lt_two' [(Data.Real.Basic.termℝ "ℝ")])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `zero_lt_two' [(Data.Real.Basic.termℝ "ℝ")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Data.Real.Basic.termℝ', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Data.Real.Basic.termℝ', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Data.Real.Basic.termℝ "ℝ")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `zero_lt_two'
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `zero_lt_two' [(Data.Real.Basic.termℝ "ℝ")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `mul_le_mul_left
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mul_assoc
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `add_le_add_iff_left
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `norm_sq_add
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `add_right_comm
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mul_self_abs
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mul_self_abs
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `add_mul_self_eq
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `mul_self_abs
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 10 >? 1022, (some 0, tactic) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 10, term))
      (Term.proj
       (Term.app
        `mul_self_le_mul_self_iff
        [(Term.app `abs_nonneg' [(«term_+_» `z "+" `w)])
         (Term.app `add_nonneg [(Term.app `abs_nonneg' [`z]) (Term.app `abs_nonneg' [`w])])])
       "."
       (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app
       `mul_self_le_mul_self_iff
       [(Term.app `abs_nonneg' [(«term_+_» `z "+" `w)])
        (Term.app `add_nonneg [(Term.app `abs_nonneg' [`z]) (Term.app `abs_nonneg' [`w])])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `add_nonneg [(Term.app `abs_nonneg' [`z]) (Term.app `abs_nonneg' [`w])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `abs_nonneg' [`w])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `w
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_nonneg'
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `abs_nonneg' [`w]) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `abs_nonneg' [`z])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `z
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_nonneg'
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `abs_nonneg' [`z]) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `add_nonneg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app
      `add_nonneg
      [(Term.paren "(" (Term.app `abs_nonneg' [`z]) ")")
       (Term.paren "(" (Term.app `abs_nonneg' [`w]) ")")])
     ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `abs_nonneg' [(«term_+_» `z "+" `w)])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_+_»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_+_»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_+_» `z "+" `w)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `w
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      `z
[PrettyPrinter.parenthesize] ...precedences are 65 >? 1024, (none, [anonymous]) <=? (some 65, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 65, (some 66, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" («term_+_» `z "+" `w) ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_nonneg'
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app `abs_nonneg' [(Term.paren "(" («term_+_» `z "+" `w) ")")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `mul_self_le_mul_self_iff
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app
      `mul_self_le_mul_self_iff
      [(Term.paren "(" (Term.app `abs_nonneg' [(Term.paren "(" («term_+_» `z "+" `w) ")")]) ")")
       (Term.paren
        "("
        (Term.app
         `add_nonneg
         [(Term.paren "(" (Term.app `abs_nonneg' [`z]) ")")
          (Term.paren "(" (Term.app `abs_nonneg' [`w]) ")")])
        ")")])
     ")")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 10, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 10, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      («term_≤_»
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" («term_+_» `z "+" `w))
       "≤"
       («term_+_»
        (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
        "+"
        (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_+_»
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `z)
       "+"
       (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `w)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
private
  theorem
    abs_add
    ( z w : ℂ ) : abs z + w ≤ abs z + abs w
    :=
      mul_self_le_mul_self_iff abs_nonneg' z + w add_nonneg abs_nonneg' z abs_nonneg' w . 2
        <|
        by
          rw
              [
                mul_self_abs
                  ,
                  add_mul_self_eq
                  ,
                  mul_self_abs
                  ,
                  mul_self_abs
                  ,
                  add_right_comm
                  ,
                  norm_sq_add
                  ,
                  add_le_add_iff_left
                  ,
                  mul_assoc
                  ,
                  mul_le_mul_left zero_lt_two' ℝ
                  ,
                  ← Real.sqrt_mul <| norm_sq_nonneg z
                  ,
                  ← norm_sq_conj w
                  ,
                  ← map_mul
                ]
            exact re_le_abs z * conj w
#align complex.abs_theory.abs_add complex.abs_theory.abs_add

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "The complex absolute value function, defined as the square root of the norm squared. -/")]
      []
      []
      [(Command.noncomputable "noncomputable")]
      []
      [])
     (Command.def
      "def"
      (Command.declId `Complex.abs [])
      (Command.optDeclSig
       []
       [(Term.typeSpec
         ":"
         (Term.app `AbsoluteValue [(Data.Complex.Basic.termℂ "ℂ") (Data.Real.Basic.termℝ "ℝ")]))])
      (Command.whereStructInst
       "where"
       [(Command.whereStructField
         (Term.letDecl
          (Term.letIdDecl `toFun [`x] [] ":=" (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `x))))
        []
        (Command.whereStructField (Term.letDecl (Term.letIdDecl `map_mul' [] [] ":=" `abs_mul)))
        []
        (Command.whereStructField (Term.letDecl (Term.letIdDecl `nonneg' [] [] ":=" `abs_nonneg')))
        []
        (Command.whereStructField
         (Term.letDecl
          (Term.letIdDecl
           `eq_zero'
           [(Term.hole "_")]
           []
           ":="
           (Term.app
            (Term.proj
             («term_<|_» `Real.sqrt_eq_zero "<|" (Term.app `norm_sq_nonneg [(Term.hole "_")]))
             "."
             `trans)
            [`norm_sq_eq_zero]))))
        []
        (Command.whereStructField (Term.letDecl (Term.letIdDecl `add_le' [] [] ":=" `abs_add)))]
       [])
      []
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.whereStructInst', expected 'Lean.Parser.Command.declValSimple'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.whereStructInst', expected 'Lean.Parser.Command.declValEqns'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `abs_add
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.proj
        («term_<|_» `Real.sqrt_eq_zero "<|" (Term.app `norm_sq_nonneg [(Term.hole "_")]))
        "."
        `trans)
       [`norm_sq_eq_zero])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `norm_sq_eq_zero
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj
       («term_<|_» `Real.sqrt_eq_zero "<|" (Term.app `norm_sq_nonneg [(Term.hole "_")]))
       "."
       `trans)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      («term_<|_» `Real.sqrt_eq_zero "<|" (Term.app `norm_sq_nonneg [(Term.hole "_")]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `norm_sq_nonneg [(Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `norm_sq_nonneg
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 10 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 10, term))
      `Real.sqrt_eq_zero
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 10, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 10, (some 10, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_<|_» `Real.sqrt_eq_zero "<|" (Term.app `norm_sq_nonneg [(Term.hole "_")]))
     ")")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'ident'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `abs_nonneg'
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `abs_mul
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.AbsTheory.Data.Complex.Basic.abs "abs" `x)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.AbsTheory.Data.Complex.Basic.abs', expected 'Complex.AbsTheory.Data.Complex.Basic.abs._@.Data.Complex.Basic._hyg.978'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.letIdDecl', expected 'Lean.Parser.Term.letPatDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.letIdDecl', expected 'Lean.Parser.Term.letEqnsDecl'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.theorem'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/-- The complex absolute value function, defined as the square root of the norm squared. -/
    noncomputable
  def
    Complex.abs
    : AbsoluteValue ℂ ℝ
    where
      toFun x := abs x
        map_mul' := abs_mul
        nonneg' := abs_nonneg'
        eq_zero' _ := Real.sqrt_eq_zero <| norm_sq_nonneg _ . trans norm_sq_eq_zero
        add_le' := abs_add
#align complex.abs Complex.abs

end AbsTheory

theorem abs_def : (abs : ℂ → ℝ) = fun z => (normSq z).sqrt :=
  rfl
#align complex.abs_def Complex.abs_def

theorem abs_apply {z : ℂ} : abs z = (normSq z).sqrt :=
  rfl
#align complex.abs_apply Complex.abs_apply

@[simp, norm_cast]
theorem abs_of_real (r : ℝ) : abs r = |r| := by
  simp [abs, norm_sq_of_real, Real.sqrt_mul_self_eq_abs]
#align complex.abs_of_real Complex.abs_of_real

theorem abs_of_nonneg {r : ℝ} (h : 0 ≤ r) : abs r = r :=
  (abs_of_real _).trans (abs_of_nonneg h)
#align complex.abs_of_nonneg Complex.abs_of_nonneg

theorem abs_of_nat (n : ℕ) : Complex.abs n = n :=
  calc
    Complex.abs n = Complex.abs (n : ℝ) := by rw [of_real_nat_cast]
    _ = _ := abs_of_nonneg (Nat.cast_nonneg n)
    
#align complex.abs_of_nat Complex.abs_of_nat

theorem mul_self_abs (z : ℂ) : abs z * abs z = normSq z :=
  Real.mul_self_sqrt (norm_sq_nonneg _)
#align complex.mul_self_abs Complex.mul_self_abs

theorem sq_abs (z : ℂ) : abs z ^ 2 = normSq z :=
  Real.sq_sqrt (norm_sq_nonneg _)
#align complex.sq_abs Complex.sq_abs

@[simp]
theorem sq_abs_sub_sq_re (z : ℂ) : abs z ^ 2 - z.re ^ 2 = z.im ^ 2 := by
  rw [sq_abs, norm_sq_apply, ← sq, ← sq, add_sub_cancel']
#align complex.sq_abs_sub_sq_re Complex.sq_abs_sub_sq_re

@[simp]
theorem sq_abs_sub_sq_im (z : ℂ) : abs z ^ 2 - z.im ^ 2 = z.re ^ 2 := by
  rw [← sq_abs_sub_sq_re, sub_sub_cancel]
#align complex.sq_abs_sub_sq_im Complex.sq_abs_sub_sq_im

@[simp]
theorem abs_I : abs i = 1 := by simp [abs]
#align complex.abs_I Complex.abs_I

@[simp]
theorem abs_two : abs 2 = 2 :=
  calc
    abs 2 = abs (2 : ℝ) := by rw [of_real_bit0, of_real_one]
    _ = (2 : ℝ) := abs_of_nonneg (by norm_num)
    
#align complex.abs_two Complex.abs_two

@[simp]
theorem range_abs : range abs = Ici 0 :=
  (Subset.antisymm (range_subset_iff.2 abs.Nonneg)) fun x hx => ⟨x, abs_of_nonneg hx⟩
#align complex.range_abs Complex.range_abs

@[simp]
theorem abs_conj (z : ℂ) : abs (conj z) = abs z :=
  AbsTheory.abs_conj z
#align complex.abs_conj Complex.abs_conj

@[simp]
theorem abs_prod {ι : Type _} (s : Finset ι) (f : ι → ℂ) :
    abs (s.Prod f) = s.Prod fun i => abs (f i) :=
  map_prod abs _ _
#align complex.abs_prod Complex.abs_prod

@[simp]
theorem abs_pow (z : ℂ) (n : ℕ) : abs (z ^ n) = abs z ^ n :=
  map_pow abs z n
#align complex.abs_pow Complex.abs_pow

@[simp]
theorem abs_zpow (z : ℂ) (n : ℤ) : abs (z ^ n) = abs z ^ n :=
  map_zpow₀ abs z n
#align complex.abs_zpow Complex.abs_zpow

theorem abs_re_le_abs (z : ℂ) : |z.re| ≤ abs z :=
  Real.abs_le_sqrt <| by
    rw [norm_sq_apply, ← sq]
    exact le_add_of_nonneg_right (mul_self_nonneg _)
#align complex.abs_re_le_abs Complex.abs_re_le_abs

theorem abs_im_le_abs (z : ℂ) : |z.im| ≤ abs z :=
  Real.abs_le_sqrt <| by
    rw [norm_sq_apply, ← sq, ← sq]
    exact le_add_of_nonneg_left (sq_nonneg _)
#align complex.abs_im_le_abs Complex.abs_im_le_abs

theorem re_le_abs (z : ℂ) : z.re ≤ abs z :=
  (abs_le.1 (abs_re_le_abs _)).2
#align complex.re_le_abs Complex.re_le_abs

theorem im_le_abs (z : ℂ) : z.im ≤ abs z :=
  (abs_le.1 (abs_im_le_abs _)).2
#align complex.im_le_abs Complex.im_le_abs

@[simp]
theorem abs_re_lt_abs {z : ℂ} : |z.re| < abs z ↔ z.im ≠ 0 := by
  rw [abs, AbsoluteValue.coe_mk, MulHom.coe_mk, Real.lt_sqrt (abs_nonneg _), norm_sq_apply,
    _root_.sq_abs, ← sq, lt_add_iff_pos_right, mul_self_pos]
#align complex.abs_re_lt_abs Complex.abs_re_lt_abs

@[simp]
theorem abs_im_lt_abs {z : ℂ} : |z.im| < abs z ↔ z.re ≠ 0 := by simpa using @abs_re_lt_abs (z * I)
#align complex.abs_im_lt_abs Complex.abs_im_lt_abs

@[simp]
theorem abs_abs (z : ℂ) : |abs z| = abs z :=
  abs_of_nonneg (abs.Nonneg _)
#align complex.abs_abs Complex.abs_abs

theorem abs_le_abs_re_add_abs_im (z : ℂ) : abs z ≤ |z.re| + |z.im| := by
  simpa [re_add_im] using abs.add_le z.re (z.im * I)
#align complex.abs_le_abs_re_add_abs_im Complex.abs_le_abs_re_add_abs_im

theorem abs_le_sqrt_two_mul_max (z : ℂ) : abs z ≤ Real.sqrt 2 * max (|z.re|) (|z.im|) :=
  by
  cases' z with x y
  simp only [abs, norm_sq_mk, ← sq]
  wlog (discharger := tactic.skip) hle : |x| ≤ |y| := le_total (|x|) (|y|) using x y, y x
  · simp only [AbsoluteValue.coe_mk, MulHom.coe_mk, norm_sq_mk, ← sq]
    calc
      Real.sqrt (x ^ 2 + y ^ 2) ≤ Real.sqrt (y ^ 2 + y ^ 2) :=
        Real.sqrt_le_sqrt (add_le_add_right (sq_le_sq.2 hle) _)
      _ = Real.sqrt 2 * max (|x|) (|y|) := by
        rw [max_eq_right hle, ← two_mul, Real.sqrt_mul two_pos.le, Real.sqrt_sq_eq_abs]
      
  · dsimp
    rwa [add_comm, max_comm]
#align complex.abs_le_sqrt_two_mul_max Complex.abs_le_sqrt_two_mul_max

theorem abs_re_div_abs_le_one (z : ℂ) : |z.re / z.abs| ≤ 1 :=
  if hz : z = 0 then by simp [hz, zero_le_one]
  else by simp_rw [_root_.abs_div, abs_abs, div_le_iff (abs.pos hz), one_mul, abs_re_le_abs]
#align complex.abs_re_div_abs_le_one Complex.abs_re_div_abs_le_one

theorem abs_im_div_abs_le_one (z : ℂ) : |z.im / z.abs| ≤ 1 :=
  if hz : z = 0 then by simp [hz, zero_le_one]
  else by simp_rw [_root_.abs_div, abs_abs, div_le_iff (abs.pos hz), one_mul, abs_im_le_abs]
#align complex.abs_im_div_abs_le_one Complex.abs_im_div_abs_le_one

@[simp, norm_cast]
theorem abs_cast_nat (n : ℕ) : abs (n : ℂ) = n := by
  rw [← of_real_nat_cast, abs_of_nonneg (Nat.cast_nonneg n)]
#align complex.abs_cast_nat Complex.abs_cast_nat

@[simp, norm_cast]
theorem int_cast_abs (n : ℤ) : ↑(|n|) = abs n := by
  rw [← of_real_int_cast, abs_of_real, Int.cast_abs]
#align complex.int_cast_abs Complex.int_cast_abs

theorem norm_sq_eq_abs (x : ℂ) : normSq x = abs x ^ 2 := by
  simp [abs, sq, Real.mul_self_sqrt (norm_sq_nonneg _)]
#align complex.norm_sq_eq_abs Complex.norm_sq_eq_abs

/-- We put a partial order on ℂ so that `z ≤ w` exactly if `w - z` is real and nonnegative.
Complex numbers with different imaginary parts are incomparable.
-/
protected def partialOrder : PartialOrder ℂ
    where
  le z w := z.re ≤ w.re ∧ z.im = w.im
  lt z w := z.re < w.re ∧ z.im = w.im
  lt_iff_le_not_le z w := by
    dsimp
    rw [lt_iff_le_not_le]
    tauto
  le_refl x := ⟨le_rfl, rfl⟩
  le_trans x y z h₁ h₂ := ⟨h₁.1.trans h₂.1, h₁.2.trans h₂.2⟩
  le_antisymm z w h₁ h₂ := ext (h₁.1.antisymm h₂.1) h₁.2
#align complex.partial_order Complex.partialOrder

section ComplexOrder

scoped[ComplexOrder] attribute [instance] Complex.partialOrder

theorem le_def {z w : ℂ} : z ≤ w ↔ z.re ≤ w.re ∧ z.im = w.im :=
  Iff.rfl
#align complex.le_def Complex.le_def

theorem lt_def {z w : ℂ} : z < w ↔ z.re < w.re ∧ z.im = w.im :=
  Iff.rfl
#align complex.lt_def Complex.lt_def

@[simp, norm_cast]
theorem real_le_real {x y : ℝ} : (x : ℂ) ≤ (y : ℂ) ↔ x ≤ y := by simp [le_def]
#align complex.real_le_real Complex.real_le_real

@[simp, norm_cast]
theorem real_lt_real {x y : ℝ} : (x : ℂ) < (y : ℂ) ↔ x < y := by simp [lt_def]
#align complex.real_lt_real Complex.real_lt_real

@[simp, norm_cast]
theorem zero_le_real {x : ℝ} : (0 : ℂ) ≤ (x : ℂ) ↔ 0 ≤ x :=
  real_le_real
#align complex.zero_le_real Complex.zero_le_real

@[simp, norm_cast]
theorem zero_lt_real {x : ℝ} : (0 : ℂ) < (x : ℂ) ↔ 0 < x :=
  real_lt_real
#align complex.zero_lt_real Complex.zero_lt_real

theorem not_le_iff {z w : ℂ} : ¬z ≤ w ↔ w.re < z.re ∨ z.im ≠ w.im := by
  rw [le_def, not_and_or, not_le]
#align complex.not_le_iff Complex.not_le_iff

theorem not_lt_iff {z w : ℂ} : ¬z < w ↔ w.re ≤ z.re ∨ z.im ≠ w.im := by
  rw [lt_def, not_and_or, not_lt]
#align complex.not_lt_iff Complex.not_lt_iff

theorem not_le_zero_iff {z : ℂ} : ¬z ≤ 0 ↔ 0 < z.re ∨ z.im ≠ 0 :=
  not_le_iff
#align complex.not_le_zero_iff Complex.not_le_zero_iff

theorem not_lt_zero_iff {z : ℂ} : ¬z < 0 ↔ 0 ≤ z.re ∨ z.im ≠ 0 :=
  not_lt_iff
#align complex.not_lt_zero_iff Complex.not_lt_zero_iff

theorem eq_re_of_real_le {r : ℝ} {z : ℂ} (hz : (r : ℂ) ≤ z) : z = z.re :=
  by
  ext
  rfl
  simp only [← (Complex.le_def.1 hz).2, Complex.zero_im, Complex.of_real_im]
#align complex.eq_re_of_real_le Complex.eq_re_of_real_le

/-- With `z ≤ w` iff `w - z` is real and nonnegative, `ℂ` is a strictly ordered ring.
-/
protected def strictOrderedCommRing : StrictOrderedCommRing ℂ :=
  { Complex.partialOrder, Complex.commRing,
    Complex.nontrivial with
    zero_le_one := ⟨zero_le_one, rfl⟩
    add_le_add_left := fun w z h y => ⟨add_le_add_left h.1 _, congr_arg₂ (· + ·) rfl h.2⟩
    mul_pos := fun z w hz hw => by
      simp [lt_def, mul_re, mul_im, ← hz.2, ← hw.2, mul_pos hz.1 hw.1] }
#align complex.strict_ordered_comm_ring Complex.strictOrderedCommRing

scoped[ComplexOrder] attribute [instance] Complex.strictOrderedCommRing

/-- With `z ≤ w` iff `w - z` is real and nonnegative, `ℂ` is a star ordered ring.
(That is, a star ring in which the nonnegative elements are those of the form `star z * z`.)
-/
protected def starOrderedRing : StarOrderedRing ℂ :=
  { Complex.strictOrderedCommRing with
    nonneg_iff := fun r =>
      by
      refine' ⟨fun hr => ⟨Real.sqrt r.re, _⟩, fun h => _⟩
      · have h₁ : 0 ≤ r.re := by
          rw [le_def] at hr
          exact hr.1
        have h₂ : r.im = 0 := by
          rw [le_def] at hr
          exact hr.2.symm
        ext
        ·
          simp only [of_real_im, star_def, of_real_re, sub_zero, conj_re, mul_re, mul_zero, ←
            Real.sqrt_mul h₁ r.re, Real.sqrt_mul_self h₁]
        ·
          simp only [h₂, add_zero, of_real_im, star_def, zero_mul, conj_im, mul_im, mul_zero,
            neg_zero]
      · obtain ⟨s, rfl⟩ := h
        simp only [← norm_sq_eq_conj_mul_self, norm_sq_nonneg, zero_le_real, star_def] }
#align complex.star_ordered_ring Complex.starOrderedRing

scoped[ComplexOrder] attribute [instance] Complex.starOrderedRing

end ComplexOrder

/-! ### Cauchy sequences -/


-- mathport name: exprabs'
local notation "abs'" => Abs.abs

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `is_cau_seq_re [])
      (Command.declSig
       [(Term.explicitBinder
         "("
         [`f]
         [":" (Term.app `CauSeq [(Data.Complex.Basic.termℂ "ℂ") `abs])]
         []
         ")")]
       (Term.typeSpec
        ":"
        (Term.app
         `IsCauSeq
         [(Complex.Data.Complex.Basic.termabs' "abs'")
          (Term.fun "fun" (Term.basicFun [`n] [] "=>" (Term.proj (Term.app `f [`n]) "." `re)))])))
      (Command.declValSimple
       ":="
       (Term.fun
        "fun"
        (Term.basicFun
         [`ε `ε0]
         []
         "=>"
         (Term.app
          (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
          [(Term.fun
            "fun"
            (Term.basicFun
             [`i `H `j `ij]
             []
             "=>"
             (Term.app
              `lt_of_le_of_lt
              [(Term.byTactic
                "by"
                (Tactic.tacticSeq
                 (Tactic.tacticSeq1Indented
                  [(Std.Tactic.Simpa.simpa
                    "simpa"
                    []
                    []
                    (Std.Tactic.Simpa.simpaArgsRest
                     []
                     []
                     []
                     []
                     ["using"
                      (Term.app
                       `abs_re_le_abs
                       [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
               (Term.app `H [(Term.hole "_") `ij])])))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`ε `ε0]
        []
        "=>"
        (Term.app
         (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
         [(Term.fun
           "fun"
           (Term.basicFun
            [`i `H `j `ij]
            []
            "=>"
            (Term.app
             `lt_of_le_of_lt
             [(Term.byTactic
               "by"
               (Tactic.tacticSeq
                (Tactic.tacticSeq1Indented
                 [(Std.Tactic.Simpa.simpa
                   "simpa"
                   []
                   []
                   (Std.Tactic.Simpa.simpaArgsRest
                    []
                    []
                    []
                    []
                    ["using"
                     (Term.app
                      `abs_re_le_abs
                      [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
              (Term.app `H [(Term.hole "_") `ij])])))])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
       [(Term.fun
         "fun"
         (Term.basicFun
          [`i `H `j `ij]
          []
          "=>"
          (Term.app
           `lt_of_le_of_lt
           [(Term.byTactic
             "by"
             (Tactic.tacticSeq
              (Tactic.tacticSeq1Indented
               [(Std.Tactic.Simpa.simpa
                 "simpa"
                 []
                 []
                 (Std.Tactic.Simpa.simpaArgsRest
                  []
                  []
                  []
                  []
                  ["using"
                   (Term.app
                    `abs_re_le_abs
                    [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
            (Term.app `H [(Term.hole "_") `ij])])))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`i `H `j `ij]
        []
        "=>"
        (Term.app
         `lt_of_le_of_lt
         [(Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Std.Tactic.Simpa.simpa
               "simpa"
               []
               []
               (Std.Tactic.Simpa.simpaArgsRest
                []
                []
                []
                []
                ["using"
                 (Term.app
                  `abs_re_le_abs
                  [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
          (Term.app `H [(Term.hole "_") `ij])])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `lt_of_le_of_lt
       [(Term.byTactic
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Std.Tactic.Simpa.simpa
             "simpa"
             []
             []
             (Std.Tactic.Simpa.simpaArgsRest
              []
              []
              []
              []
              ["using"
               (Term.app
                `abs_re_le_abs
                [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
        (Term.app `H [(Term.hole "_") `ij])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `H [(Term.hole "_") `ij])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ij
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `H
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `H [(Term.hole "_") `ij]) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.byTactic', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.byTactic', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.Simpa.simpa
           "simpa"
           []
           []
           (Std.Tactic.Simpa.simpaArgsRest
            []
            []
            []
            []
            ["using"
             (Term.app
              `abs_re_le_abs
              [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.Simpa.simpa
       "simpa"
       []
       []
       (Std.Tactic.Simpa.simpaArgsRest
        []
        []
        []
        []
        ["using"
         (Term.app `abs_re_le_abs [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `abs_re_le_abs [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_-_»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_-_»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `f [`i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      (Term.app `f [`j])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `j
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 65 >? 1022, (some 1023, term) <=? (some 65, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 65, (some 66, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_re_le_abs
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 0, tactic) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.byTactic
      "by"
      (Tactic.tacticSeq
       (Tactic.tacticSeq1Indented
        [(Std.Tactic.Simpa.simpa
          "simpa"
          []
          []
          (Std.Tactic.Simpa.simpaArgsRest
           []
           []
           []
           []
           ["using"
            (Term.app
             `abs_re_le_abs
             [(Term.paren "(" («term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i])) ")")])]))])))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `lt_of_le_of_lt
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ij
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `j
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `H
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app (Term.proj `f "." `cauchy) [`ε0])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ε0
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `f "." `cauchy)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app (Term.proj `f "." `cauchy) [`ε0])
     ")")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ε0
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `ε
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.app
       `IsCauSeq
       [(Complex.Data.Complex.Basic.termabs' "abs'")
        (Term.fun "fun" (Term.basicFun [`n] [] "=>" (Term.proj (Term.app `f [`n]) "." `re)))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun "fun" (Term.basicFun [`n] [] "=>" (Term.proj (Term.app `f [`n]) "." `re)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj (Term.app `f [`n]) "." `re)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `f [`n])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `f [`n]) ")")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      (Complex.Data.Complex.Basic.termabs' "abs'")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Complex.Data.Complex.Basic.termabs'._@.Data.Complex.Basic._hyg.1027'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  is_cau_seq_re
  ( f : CauSeq ℂ abs ) : IsCauSeq abs' fun n => f n . re
  :=
    fun
      ε ε0
        =>
        f . cauchy ε0 . imp
          fun i H j ij => lt_of_le_of_lt by simpa using abs_re_le_abs f j - f i H _ ij
#align complex.is_cau_seq_re Complex.is_cau_seq_re

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `is_cau_seq_im [])
      (Command.declSig
       [(Term.explicitBinder
         "("
         [`f]
         [":" (Term.app `CauSeq [(Data.Complex.Basic.termℂ "ℂ") `abs])]
         []
         ")")]
       (Term.typeSpec
        ":"
        (Term.app
         `IsCauSeq
         [(Complex.Data.Complex.Basic.termabs' "abs'")
          (Term.fun "fun" (Term.basicFun [`n] [] "=>" (Term.proj (Term.app `f [`n]) "." `im)))])))
      (Command.declValSimple
       ":="
       (Term.fun
        "fun"
        (Term.basicFun
         [`ε `ε0]
         []
         "=>"
         (Term.app
          (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
          [(Term.fun
            "fun"
            (Term.basicFun
             [`i `H `j `ij]
             []
             "=>"
             (Term.app
              `lt_of_le_of_lt
              [(Term.byTactic
                "by"
                (Tactic.tacticSeq
                 (Tactic.tacticSeq1Indented
                  [(Std.Tactic.Simpa.simpa
                    "simpa"
                    []
                    []
                    (Std.Tactic.Simpa.simpaArgsRest
                     []
                     []
                     []
                     []
                     ["using"
                      (Term.app
                       `abs_im_le_abs
                       [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
               (Term.app `H [(Term.hole "_") `ij])])))])))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`ε `ε0]
        []
        "=>"
        (Term.app
         (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
         [(Term.fun
           "fun"
           (Term.basicFun
            [`i `H `j `ij]
            []
            "=>"
            (Term.app
             `lt_of_le_of_lt
             [(Term.byTactic
               "by"
               (Tactic.tacticSeq
                (Tactic.tacticSeq1Indented
                 [(Std.Tactic.Simpa.simpa
                   "simpa"
                   []
                   []
                   (Std.Tactic.Simpa.simpaArgsRest
                    []
                    []
                    []
                    []
                    ["using"
                     (Term.app
                      `abs_im_le_abs
                      [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
              (Term.app `H [(Term.hole "_") `ij])])))])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
       [(Term.fun
         "fun"
         (Term.basicFun
          [`i `H `j `ij]
          []
          "=>"
          (Term.app
           `lt_of_le_of_lt
           [(Term.byTactic
             "by"
             (Tactic.tacticSeq
              (Tactic.tacticSeq1Indented
               [(Std.Tactic.Simpa.simpa
                 "simpa"
                 []
                 []
                 (Std.Tactic.Simpa.simpaArgsRest
                  []
                  []
                  []
                  []
                  ["using"
                   (Term.app
                    `abs_im_le_abs
                    [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
            (Term.app `H [(Term.hole "_") `ij])])))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`i `H `j `ij]
        []
        "=>"
        (Term.app
         `lt_of_le_of_lt
         [(Term.byTactic
           "by"
           (Tactic.tacticSeq
            (Tactic.tacticSeq1Indented
             [(Std.Tactic.Simpa.simpa
               "simpa"
               []
               []
               (Std.Tactic.Simpa.simpaArgsRest
                []
                []
                []
                []
                ["using"
                 (Term.app
                  `abs_im_le_abs
                  [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
          (Term.app `H [(Term.hole "_") `ij])])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `lt_of_le_of_lt
       [(Term.byTactic
         "by"
         (Tactic.tacticSeq
          (Tactic.tacticSeq1Indented
           [(Std.Tactic.Simpa.simpa
             "simpa"
             []
             []
             (Std.Tactic.Simpa.simpaArgsRest
              []
              []
              []
              []
              ["using"
               (Term.app
                `abs_im_le_abs
                [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
        (Term.app `H [(Term.hole "_") `ij])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `H [(Term.hole "_") `ij])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ij
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `H
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `H [(Term.hole "_") `ij]) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.byTactic', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.byTactic', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.byTactic
       "by"
       (Tactic.tacticSeq
        (Tactic.tacticSeq1Indented
         [(Std.Tactic.Simpa.simpa
           "simpa"
           []
           []
           (Std.Tactic.Simpa.simpaArgsRest
            []
            []
            []
            []
            ["using"
             (Term.app
              `abs_im_le_abs
              [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))])))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Tactic.tacticSeq1Indented', expected 'Lean.Parser.Tactic.tacticSeqBracketed'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Std.Tactic.Simpa.simpa
       "simpa"
       []
       []
       (Std.Tactic.Simpa.simpaArgsRest
        []
        []
        []
        []
        ["using"
         (Term.app `abs_im_le_abs [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `abs_im_le_abs [(«term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_-_»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_-_»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `f [`i])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 66 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 65, term))
      (Term.app `f [`j])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `j
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 65 >? 1022, (some 1023, term) <=? (some 65, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 65, (some 66, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     («term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i]))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `abs_im_le_abs
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 0, tactic) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.byTactic
      "by"
      (Tactic.tacticSeq
       (Tactic.tacticSeq1Indented
        [(Std.Tactic.Simpa.simpa
          "simpa"
          []
          []
          (Std.Tactic.Simpa.simpaArgsRest
           []
           []
           []
           []
           ["using"
            (Term.app
             `abs_im_le_abs
             [(Term.paren "(" («term_-_» (Term.app `f [`j]) "-" (Term.app `f [`i])) ")")])]))])))
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `lt_of_le_of_lt
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ij
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `j
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `H
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `i
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj (Term.app (Term.proj `f "." `cauchy) [`ε0]) "." `imp)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app (Term.proj `f "." `cauchy) [`ε0])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ε0
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `f "." `cauchy)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app (Term.proj `f "." `cauchy) [`ε0])
     ")")
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ε0
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `ε
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.app
       `IsCauSeq
       [(Complex.Data.Complex.Basic.termabs' "abs'")
        (Term.fun "fun" (Term.basicFun [`n] [] "=>" (Term.proj (Term.app `f [`n]) "." `im)))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.fun', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun "fun" (Term.basicFun [`n] [] "=>" (Term.proj (Term.app `f [`n]) "." `im)))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj (Term.app `f [`n]) "." `im)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app `f [`n])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `f [`n]) ")")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `n
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      (Complex.Data.Complex.Basic.termabs' "abs'")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Complex.Data.Complex.Basic.termabs'._@.Data.Complex.Basic._hyg.1027'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  is_cau_seq_im
  ( f : CauSeq ℂ abs ) : IsCauSeq abs' fun n => f n . im
  :=
    fun
      ε ε0
        =>
        f . cauchy ε0 . imp
          fun i H j ij => lt_of_le_of_lt by simpa using abs_im_le_abs f j - f i H _ ij
#align complex.is_cau_seq_im Complex.is_cau_seq_im

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "The real part of a complex Cauchy sequence, as a real Cauchy sequence. -/")]
      []
      []
      [(Command.noncomputable "noncomputable")]
      []
      [])
     (Command.def
      "def"
      (Command.declId `cauSeqRe [])
      (Command.optDeclSig
       [(Term.explicitBinder
         "("
         [`f]
         [":" (Term.app `CauSeq [(Data.Complex.Basic.termℂ "ℂ") `abs])]
         []
         ")")]
       [(Term.typeSpec
         ":"
         (Term.app
          `CauSeq
          [(Data.Real.Basic.termℝ "ℝ") (Complex.Data.Complex.Basic.termabs' "abs'")]))])
      (Command.declValSimple
       ":="
       (Term.anonymousCtor "⟨" [(Term.hole "_") "," (Term.app `is_cau_seq_re [`f])] "⟩")
       [])
      []
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [(Term.hole "_") "," (Term.app `is_cau_seq_re [`f])] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `is_cau_seq_re [`f])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `is_cau_seq_re
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.app `CauSeq [(Data.Real.Basic.termℝ "ℝ") (Complex.Data.Complex.Basic.termabs' "abs'")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.Data.Complex.Basic.termabs' "abs'")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Complex.Data.Complex.Basic.termabs'._@.Data.Complex.Basic._hyg.1027'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.theorem'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/-- The real part of a complex Cauchy sequence, as a real Cauchy sequence. -/ noncomputable
  def cauSeqRe ( f : CauSeq ℂ abs ) : CauSeq ℝ abs' := ⟨ _ , is_cau_seq_re f ⟩
#align complex.cau_seq_re Complex.cauSeqRe

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "The imaginary part of a complex Cauchy sequence, as a real Cauchy sequence. -/")]
      []
      []
      [(Command.noncomputable "noncomputable")]
      []
      [])
     (Command.def
      "def"
      (Command.declId `cauSeqIm [])
      (Command.optDeclSig
       [(Term.explicitBinder
         "("
         [`f]
         [":" (Term.app `CauSeq [(Data.Complex.Basic.termℂ "ℂ") `abs])]
         []
         ")")]
       [(Term.typeSpec
         ":"
         (Term.app
          `CauSeq
          [(Data.Real.Basic.termℝ "ℝ") (Complex.Data.Complex.Basic.termabs' "abs'")]))])
      (Command.declValSimple
       ":="
       (Term.anonymousCtor "⟨" [(Term.hole "_") "," (Term.app `is_cau_seq_im [`f])] "⟩")
       [])
      []
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [(Term.hole "_") "," (Term.app `is_cau_seq_im [`f])] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `is_cau_seq_im [`f])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `f
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `is_cau_seq_im
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.app `CauSeq [(Data.Real.Basic.termℝ "ℝ") (Complex.Data.Complex.Basic.termabs' "abs'")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.Data.Complex.Basic.termabs' "abs'")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Complex.Data.Complex.Basic.termabs'._@.Data.Complex.Basic._hyg.1027'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.theorem'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/-- The imaginary part of a complex Cauchy sequence, as a real Cauchy sequence. -/ noncomputable
  def cauSeqIm ( f : CauSeq ℂ abs ) : CauSeq ℝ abs' := ⟨ _ , is_cau_seq_im f ⟩
#align complex.cau_seq_im Complex.cauSeqIm

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers [] [] [] [] [] [])
     (Command.theorem
      "theorem"
      (Command.declId `is_cau_seq_abs [])
      (Command.declSig
       [(Term.implicitBinder
         "{"
         [`f]
         [":" (Term.arrow (termℕ "ℕ") "→" (Data.Complex.Basic.termℂ "ℂ"))]
         "}")
        (Term.explicitBinder "(" [`hf] [":" (Term.app `IsCauSeq [`abs `f])] [] ")")]
       (Term.typeSpec
        ":"
        (Term.app
         `IsCauSeq
         [(Complex.Data.Complex.Basic.termabs' "abs'") («term_∘_» `abs "∘" `f)])))
      (Command.declValSimple
       ":="
       (Term.fun
        "fun"
        (Term.basicFun
         [`ε `ε0]
         []
         "=>"
         (Term.let
          "let"
          (Term.letDecl
           (Term.letPatDecl
            (Term.anonymousCtor "⟨" [`i "," `hi] "⟩")
            []
            []
            ":="
            (Term.app `hf [`ε `ε0])))
          []
          (Term.anonymousCtor
           "⟨"
           [`i
            ","
            (Term.fun
             "fun"
             (Term.basicFun
              [`j `hj]
              []
              "=>"
              (Term.app
               `lt_of_le_of_lt
               [(Term.app
                 (Term.proj `abs "." `abs_abv_sub_le_abv_sub)
                 [(Term.hole "_") (Term.hole "_")])
                (Term.app `hi [`j `hj])])))]
           "⟩"))))
       [])
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.def'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`ε `ε0]
        []
        "=>"
        (Term.let
         "let"
         (Term.letDecl
          (Term.letPatDecl
           (Term.anonymousCtor "⟨" [`i "," `hi] "⟩")
           []
           []
           ":="
           (Term.app `hf [`ε `ε0])))
         []
         (Term.anonymousCtor
          "⟨"
          [`i
           ","
           (Term.fun
            "fun"
            (Term.basicFun
             [`j `hj]
             []
             "=>"
             (Term.app
              `lt_of_le_of_lt
              [(Term.app
                (Term.proj `abs "." `abs_abv_sub_le_abv_sub)
                [(Term.hole "_") (Term.hole "_")])
               (Term.app `hi [`j `hj])])))]
          "⟩"))))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.let
       "let"
       (Term.letDecl
        (Term.letPatDecl
         (Term.anonymousCtor "⟨" [`i "," `hi] "⟩")
         []
         []
         ":="
         (Term.app `hf [`ε `ε0])))
       []
       (Term.anonymousCtor
        "⟨"
        [`i
         ","
         (Term.fun
          "fun"
          (Term.basicFun
           [`j `hj]
           []
           "=>"
           (Term.app
            `lt_of_le_of_lt
            [(Term.app
              (Term.proj `abs "." `abs_abv_sub_le_abv_sub)
              [(Term.hole "_") (Term.hole "_")])
             (Term.app `hi [`j `hj])])))]
        "⟩"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [`i
        ","
        (Term.fun
         "fun"
         (Term.basicFun
          [`j `hj]
          []
          "=>"
          (Term.app
           `lt_of_le_of_lt
           [(Term.app
             (Term.proj `abs "." `abs_abv_sub_le_abv_sub)
             [(Term.hole "_") (Term.hole "_")])
            (Term.app `hi [`j `hj])])))]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.fun
       "fun"
       (Term.basicFun
        [`j `hj]
        []
        "=>"
        (Term.app
         `lt_of_le_of_lt
         [(Term.app (Term.proj `abs "." `abs_abv_sub_le_abv_sub) [(Term.hole "_") (Term.hole "_")])
          (Term.app `hi [`j `hj])])))
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app
       `lt_of_le_of_lt
       [(Term.app (Term.proj `abs "." `abs_abv_sub_le_abv_sub) [(Term.hole "_") (Term.hole "_")])
        (Term.app `hi [`j `hj])])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `hi [`j `hj])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hj
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `j
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `hi
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" (Term.app `hi [`j `hj]) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.app', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Term.app (Term.proj `abs "." `abs_abv_sub_le_abv_sub) [(Term.hole "_") (Term.hole "_")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.hole', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, term))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1023, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      (Term.proj `abs "." `abs_abv_sub_le_abv_sub)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `abs
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1022, (some 1023,
     term) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesized: (Term.paren
     "("
     (Term.app (Term.proj `abs "." `abs_abv_sub_le_abv_sub) [(Term.hole "_") (Term.hole "_")])
     ")")
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `lt_of_le_of_lt
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hj
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `j
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.letPatDecl', expected 'Lean.Parser.Term.letIdDecl'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `hf [`ε `ε0])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ε0
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `ε
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `hf
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor "⟨" [`i "," `hi] "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `hi
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `i
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `ε0
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.strictImplicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.implicitBinder'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'ident', expected 'Lean.Parser.Term.instBinder'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `ε
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (some 0, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.app `IsCauSeq [(Complex.Data.Complex.Basic.termabs' "abs'") («term_∘_» `abs "∘" `f)])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_∘_»', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind '«term_∘_»', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      («term_∘_» `abs "∘" `f)
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      `f
[PrettyPrinter.parenthesize] ...precedences are 90 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 90, term))
      `abs
[PrettyPrinter.parenthesize] ...precedences are 91 >? 1024, (none, [anonymous]) <=? (some 90, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 90, (some 90, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesized: (Term.paren "(" («term_∘_» `abs "∘" `f) ")")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      (Complex.Data.Complex.Basic.termabs' "abs'")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Complex.Data.Complex.Basic.termabs'._@.Data.Complex.Basic._hyg.1027'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.theorem', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
theorem
  is_cau_seq_abs
  { f : ℕ → ℂ } ( hf : IsCauSeq abs f ) : IsCauSeq abs' abs ∘ f
  :=
    fun
      ε ε0
        =>
        let
          ⟨ i , hi ⟩ := hf ε ε0
          ⟨ i , fun j hj => lt_of_le_of_lt abs . abs_abv_sub_le_abv_sub _ _ hi j hj ⟩
#align complex.is_cau_seq_abs Complex.is_cau_seq_abs

/-- The limit of a Cauchy sequence of complex numbers. -/
noncomputable def limAux (f : CauSeq ℂ abs) : ℂ :=
  ⟨CauSeq.lim (cauSeqRe f), CauSeq.lim (cauSeqIm f)⟩
#align complex.lim_aux Complex.limAux

theorem equiv_lim_aux (f : CauSeq ℂ abs) : f ≈ CauSeq.const abs (limAux f) := fun ε ε0 =>
  (exists_forall_ge_and (CauSeq.equiv_lim ⟨_, is_cau_seq_re f⟩ _ (half_pos ε0))
        (CauSeq.equiv_lim ⟨_, is_cau_seq_im f⟩ _ (half_pos ε0))).imp
    fun i H j ij => by
    cases' H _ ij with H₁ H₂
    apply lt_of_le_of_lt (abs_le_abs_re_add_abs_im _)
    dsimp [lim_aux] at *
    have := add_lt_add H₁ H₂
    rwa [add_halves] at this
#align complex.equiv_lim_aux Complex.equiv_lim_aux

instance : CauSeq.IsComplete ℂ abs :=
  ⟨fun f => ⟨limAux f, equiv_lim_aux f⟩⟩

open CauSeq

theorem lim_eq_lim_im_add_lim_re (f : CauSeq ℂ abs) :
    lim f = ↑(lim (cauSeqRe f)) + ↑(lim (cauSeqIm f)) * I :=
  lim_eq_of_equiv_const <|
    calc
      f ≈ _ := equiv_lim_aux f
      _ = CauSeq.const abs (↑(lim (cauSeqRe f)) + ↑(lim (cauSeqIm f)) * I) :=
        CauSeq.ext fun _ =>
          Complex.ext (by simp [lim_aux, cau_seq_re]) (by simp [lim_aux, cau_seq_im])
      
#align complex.lim_eq_lim_im_add_lim_re Complex.lim_eq_lim_im_add_lim_re

theorem lim_re (f : CauSeq ℂ abs) : lim (cauSeqRe f) = (lim f).re := by
  rw [lim_eq_lim_im_add_lim_re] <;> simp
#align complex.lim_re Complex.lim_re

theorem lim_im (f : CauSeq ℂ abs) : lim (cauSeqIm f) = (lim f).im := by
  rw [lim_eq_lim_im_add_lim_re] <;> simp
#align complex.lim_im Complex.lim_im

theorem is_cau_seq_conj (f : CauSeq ℂ abs) : IsCauSeq abs fun n => conj (f n) := fun ε ε0 =>
  let ⟨i, hi⟩ := f.2 ε ε0
  ⟨i, fun j hj => by rw [← RingHom.map_sub, abs_conj] <;> exact hi j hj⟩
#align complex.is_cau_seq_conj Complex.is_cau_seq_conj

/-- The complex conjugate of a complex Cauchy sequence, as a complex Cauchy sequence. -/
noncomputable def cauSeqConj (f : CauSeq ℂ abs) : CauSeq ℂ abs :=
  ⟨_, is_cau_seq_conj f⟩
#align complex.cau_seq_conj Complex.cauSeqConj

theorem lim_conj (f : CauSeq ℂ abs) : lim (cauSeqConj f) = conj (lim f) :=
  Complex.ext (by simp [cau_seq_conj, (lim_re _).symm, cau_seq_re])
    (by simp [cau_seq_conj, (lim_im _).symm, cau_seq_im, (lim_neg _).symm] <;> rfl)
#align complex.lim_conj Complex.lim_conj

/- failed to parenthesize: parenthesize: uncaught backtrack exception
[PrettyPrinter.parenthesize.input] (Command.declaration
     (Command.declModifiers
      [(Command.docComment
        "/--"
        "The absolute value of a complex Cauchy sequence, as a real Cauchy sequence. -/")]
      []
      []
      [(Command.noncomputable "noncomputable")]
      []
      [])
     (Command.def
      "def"
      (Command.declId `cauSeqAbs [])
      (Command.optDeclSig
       [(Term.explicitBinder
         "("
         [`f]
         [":" (Term.app `CauSeq [(Data.Complex.Basic.termℂ "ℂ") `abs])]
         []
         ")")]
       [(Term.typeSpec
         ":"
         (Term.app
          `CauSeq
          [(Data.Real.Basic.termℝ "ℝ") (Complex.Data.Complex.Basic.termabs' "abs'")]))])
      (Command.declValSimple
       ":="
       (Term.anonymousCtor
        "⟨"
        [(Term.hole "_") "," (Term.app `is_cau_seq_abs [(Term.proj `f "." (fieldIdx "2"))])]
        "⟩")
       [])
      []
      []
      []))
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.abbrev'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.anonymousCtor
       "⟨"
       [(Term.hole "_") "," (Term.app `is_cau_seq_abs [(Term.proj `f "." (fieldIdx "2"))])]
       "⟩")
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.app `is_cau_seq_abs [(Term.proj `f "." (fieldIdx "2"))])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Term.proj', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.proj `f "." (fieldIdx "2"))
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1024, term))
      `f
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none, [anonymous]) <=? (some 1024, term)
[PrettyPrinter.parenthesize] ...precedences are 1023 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1022, term))
      `is_cau_seq_abs
[PrettyPrinter.parenthesize] ...precedences are 1024 >? 1024, (none,
     [anonymous]) <=? (some 1022, term)
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1022, (some 1023, term) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Term.hole "_")
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] ...precedences are 0 >? 1024, (none,
     [anonymous]) <=? (none, [anonymous])
[PrettyPrinter.parenthesize] parenthesizing (cont := (some 1023, [anonymous]))
      (Term.app `CauSeq [(Data.Real.Basic.termℝ "ℝ") (Complex.Data.Complex.Basic.termabs' "abs'")])
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.namedArgument'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Lean.Parser.Term.ellipsis'
[PrettyPrinter.parenthesize] parenthesizing (cont := (none, [anonymous]))
      (Complex.Data.Complex.Basic.termabs' "abs'")
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Complex.Data.Complex.Basic.termabs'', expected 'Complex.Data.Complex.Basic.termabs'._@.Data.Complex.Basic._hyg.1027'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.theorem'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.opaque'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.instance'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.axiom'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.example'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.inductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.classInductive'
[PrettyPrinter.parenthesize.backtrack] unexpected node kind 'Lean.Parser.Command.def', expected 'Lean.Parser.Command.structure'-/-- failed to format: format: uncaught backtrack exception
/-- The absolute value of a complex Cauchy sequence, as a real Cauchy sequence. -/ noncomputable
  def cauSeqAbs ( f : CauSeq ℂ abs ) : CauSeq ℝ abs' := ⟨ _ , is_cau_seq_abs f . 2 ⟩
#align complex.cau_seq_abs Complex.cauSeqAbs

theorem lim_abs (f : CauSeq ℂ abs) : lim (cauSeqAbs f) = abs (lim f) :=
  lim_eq_of_equiv_const fun ε ε0 =>
    let ⟨i, hi⟩ := equiv_lim f ε ε0
    ⟨i, fun j hj => lt_of_le_of_lt (abs.abs_abv_sub_le_abv_sub _ _) (hi j hj)⟩
#align complex.lim_abs Complex.lim_abs

variable {α : Type _} (s : Finset α)

@[simp, norm_cast]
theorem of_real_prod (f : α → ℝ) : ((∏ i in s, f i : ℝ) : ℂ) = ∏ i in s, (f i : ℂ) :=
  RingHom.map_prod ofReal _ _
#align complex.of_real_prod Complex.of_real_prod

@[simp, norm_cast]
theorem of_real_sum (f : α → ℝ) : ((∑ i in s, f i : ℝ) : ℂ) = ∑ i in s, (f i : ℂ) :=
  RingHom.map_sum ofReal _ _
#align complex.of_real_sum Complex.of_real_sum

@[simp]
theorem re_sum (f : α → ℂ) : (∑ i in s, f i).re = ∑ i in s, (f i).re :=
  reAddGroupHom.map_sum f s
#align complex.re_sum Complex.re_sum

@[simp]
theorem im_sum (f : α → ℂ) : (∑ i in s, f i).im = ∑ i in s, (f i).im :=
  imAddGroupHom.map_sum f s
#align complex.im_sum Complex.im_sum

end Complex

