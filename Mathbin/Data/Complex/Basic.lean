/-
Copyright (c) 2017 Kevin Buzzard. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Buzzard, Mario Carneiro

! This file was ported from Lean 3 source module data.complex.basic
! leanprover-community/mathlib commit 31c24aa72e7b3e5ed97a8412470e904f82b81004
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Data.Real.Sqrt

/-!
# The complex numbers

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

The complex numbers are modelled as ℝ^2 in the obvious way and it is shown that they form a field
of characteristic zero. The result that the complex numbers are algebraically closed, see
`field_theory.algebraic_closure`.
-/


open scoped BigOperators

open Set Function

/-! ### Definition and basic arithmmetic -/


#print Complex /-
/-- Complex numbers consist of two `real`s: a real part `re` and an imaginary part `im`. -/
structure Complex : Type where
  re : ℝ
  im : ℝ
#align complex Complex
-/

notation "ℂ" => Complex

namespace Complex

open scoped ComplexConjugate

noncomputable instance : DecidableEq ℂ :=
  Classical.decEq _

#print Complex.equivRealProd /-
/-- The equivalence between the complex numbers and `ℝ × ℝ`. -/
@[simps apply]
def equivRealProd : ℂ ≃ ℝ × ℝ where
  toFun z := ⟨z.re, z.im⟩
  invFun p := ⟨p.1, p.2⟩
  left_inv := fun ⟨x, y⟩ => rfl
  right_inv := fun ⟨x, y⟩ => rfl
#align complex.equiv_real_prod Complex.equivRealProd
-/

#print Complex.eta /-
@[simp]
theorem eta : ∀ z : ℂ, Complex.mk z.re z.im = z
  | ⟨a, b⟩ => rfl
#align complex.eta Complex.eta
-/

#print Complex.ext /-
@[ext]
theorem ext : ∀ {z w : ℂ}, z.re = w.re → z.im = w.im → z = w
  | ⟨zr, zi⟩, ⟨_, _⟩, rfl, rfl => rfl
#align complex.ext Complex.ext
-/

#print Complex.ext_iff /-
theorem ext_iff {z w : ℂ} : z = w ↔ z.re = w.re ∧ z.im = w.im :=
  ⟨fun H => by simp [H], fun h => ext h.1 h.2⟩
#align complex.ext_iff Complex.ext_iff
-/

#print Complex.re_surjective /-
theorem re_surjective : Surjective re := fun x => ⟨⟨x, 0⟩, rfl⟩
#align complex.re_surjective Complex.re_surjective
-/

#print Complex.im_surjective /-
theorem im_surjective : Surjective im := fun y => ⟨⟨0, y⟩, rfl⟩
#align complex.im_surjective Complex.im_surjective
-/

#print Complex.range_re /-
@[simp]
theorem range_re : range re = univ :=
  re_surjective.range_eq
#align complex.range_re Complex.range_re
-/

#print Complex.range_im /-
@[simp]
theorem range_im : range im = univ :=
  im_surjective.range_eq
#align complex.range_im Complex.range_im
-/

instance : Coe ℝ ℂ :=
  ⟨fun r => ⟨r, 0⟩⟩

#print Complex.ofReal_re /-
@[simp, norm_cast]
theorem ofReal_re (r : ℝ) : (r : ℂ).re = r :=
  rfl
#align complex.of_real_re Complex.ofReal_re
-/

#print Complex.ofReal_im /-
@[simp, norm_cast]
theorem ofReal_im (r : ℝ) : (r : ℂ).im = 0 :=
  rfl
#align complex.of_real_im Complex.ofReal_im
-/

#print Complex.ofReal_def /-
theorem ofReal_def (r : ℝ) : (r : ℂ) = ⟨r, 0⟩ :=
  rfl
#align complex.of_real_def Complex.ofReal_def
-/

#print Complex.ofReal_inj /-
@[simp, norm_cast]
theorem ofReal_inj {z w : ℝ} : (z : ℂ) = w ↔ z = w :=
  ⟨congr_arg re, congr_arg _⟩
#align complex.of_real_inj Complex.ofReal_inj
-/

#print Complex.ofReal_injective /-
theorem ofReal_injective : Function.Injective (coe : ℝ → ℂ) := fun z w => congr_arg re
#align complex.of_real_injective Complex.ofReal_injective
-/

#print Complex.canLift /-
instance canLift : CanLift ℂ ℝ coe fun z => z.im = 0 where prf z hz := ⟨z.re, ext rfl hz.symm⟩
#align complex.can_lift Complex.canLift
-/

#print Complex.Set.reProdIm /-
/-- The product of a set on the real axis and a set on the imaginary axis of the complex plane,
denoted by `s ×ℂ t`. -/
def Complex.Set.reProdIm (s t : Set ℝ) : Set ℂ :=
  re ⁻¹' s ∩ im ⁻¹' t
#align set.re_prod_im Complex.Set.reProdIm
-/

infixl:72 " ×ℂ " => Complex.Set.reProdIm

#print Complex.mem_reProdIm /-
theorem mem_reProdIm {z : ℂ} {s t : Set ℝ} : z ∈ s ×ℂ t ↔ z.re ∈ s ∧ z.im ∈ t :=
  Iff.rfl
#align complex.mem_re_prod_im Complex.mem_reProdIm
-/

instance : Zero ℂ :=
  ⟨(0 : ℝ)⟩

instance : Inhabited ℂ :=
  ⟨0⟩

#print Complex.zero_re /-
@[simp]
theorem zero_re : (0 : ℂ).re = 0 :=
  rfl
#align complex.zero_re Complex.zero_re
-/

#print Complex.zero_im /-
@[simp]
theorem zero_im : (0 : ℂ).im = 0 :=
  rfl
#align complex.zero_im Complex.zero_im
-/

#print Complex.ofReal_zero /-
@[simp, norm_cast]
theorem ofReal_zero : ((0 : ℝ) : ℂ) = 0 :=
  rfl
#align complex.of_real_zero Complex.ofReal_zero
-/

#print Complex.ofReal_eq_zero /-
@[simp]
theorem ofReal_eq_zero {z : ℝ} : (z : ℂ) = 0 ↔ z = 0 :=
  ofReal_inj
#align complex.of_real_eq_zero Complex.ofReal_eq_zero
-/

#print Complex.ofReal_ne_zero /-
theorem ofReal_ne_zero {z : ℝ} : (z : ℂ) ≠ 0 ↔ z ≠ 0 :=
  not_congr ofReal_eq_zero
#align complex.of_real_ne_zero Complex.ofReal_ne_zero
-/

instance : One ℂ :=
  ⟨(1 : ℝ)⟩

#print Complex.one_re /-
@[simp]
theorem one_re : (1 : ℂ).re = 1 :=
  rfl
#align complex.one_re Complex.one_re
-/

#print Complex.one_im /-
@[simp]
theorem one_im : (1 : ℂ).im = 0 :=
  rfl
#align complex.one_im Complex.one_im
-/

#print Complex.ofReal_one /-
@[simp, norm_cast]
theorem ofReal_one : ((1 : ℝ) : ℂ) = 1 :=
  rfl
#align complex.of_real_one Complex.ofReal_one
-/

#print Complex.ofReal_eq_one /-
@[simp]
theorem ofReal_eq_one {z : ℝ} : (z : ℂ) = 1 ↔ z = 1 :=
  ofReal_inj
#align complex.of_real_eq_one Complex.ofReal_eq_one
-/

#print Complex.ofReal_ne_one /-
theorem ofReal_ne_one {z : ℝ} : (z : ℂ) ≠ 1 ↔ z ≠ 1 :=
  not_congr ofReal_eq_one
#align complex.of_real_ne_one Complex.ofReal_ne_one
-/

instance : Add ℂ :=
  ⟨fun z w => ⟨z.re + w.re, z.im + w.im⟩⟩

#print Complex.add_re /-
@[simp]
theorem add_re (z w : ℂ) : (z + w).re = z.re + w.re :=
  rfl
#align complex.add_re Complex.add_re
-/

#print Complex.add_im /-
@[simp]
theorem add_im (z w : ℂ) : (z + w).im = z.im + w.im :=
  rfl
#align complex.add_im Complex.add_im
-/

#print Complex.bit0_re /-
@[simp]
theorem bit0_re (z : ℂ) : (bit0 z).re = bit0 z.re :=
  rfl
#align complex.bit0_re Complex.bit0_re
-/

#print Complex.bit1_re /-
@[simp]
theorem bit1_re (z : ℂ) : (bit1 z).re = bit1 z.re :=
  rfl
#align complex.bit1_re Complex.bit1_re
-/

#print Complex.bit0_im /-
@[simp]
theorem bit0_im (z : ℂ) : (bit0 z).im = bit0 z.im :=
  Eq.refl _
#align complex.bit0_im Complex.bit0_im
-/

#print Complex.bit1_im /-
@[simp]
theorem bit1_im (z : ℂ) : (bit1 z).im = bit0 z.im :=
  add_zero _
#align complex.bit1_im Complex.bit1_im
-/

#print Complex.ofReal_add /-
@[simp, norm_cast]
theorem ofReal_add (r s : ℝ) : ((r + s : ℝ) : ℂ) = r + s :=
  ext_iff.2 <| by simp
#align complex.of_real_add Complex.ofReal_add
-/

#print Complex.ofReal_bit0 /-
@[simp, norm_cast]
theorem ofReal_bit0 (r : ℝ) : ((bit0 r : ℝ) : ℂ) = bit0 r :=
  ext_iff.2 <| by simp [bit0]
#align complex.of_real_bit0 Complex.ofReal_bit0
-/

#print Complex.ofReal_bit1 /-
@[simp, norm_cast]
theorem ofReal_bit1 (r : ℝ) : ((bit1 r : ℝ) : ℂ) = bit1 r :=
  ext_iff.2 <| by simp [bit1]
#align complex.of_real_bit1 Complex.ofReal_bit1
-/

instance : Neg ℂ :=
  ⟨fun z => ⟨-z.re, -z.im⟩⟩

#print Complex.neg_re /-
@[simp]
theorem neg_re (z : ℂ) : (-z).re = -z.re :=
  rfl
#align complex.neg_re Complex.neg_re
-/

#print Complex.neg_im /-
@[simp]
theorem neg_im (z : ℂ) : (-z).im = -z.im :=
  rfl
#align complex.neg_im Complex.neg_im
-/

#print Complex.ofReal_neg /-
@[simp, norm_cast]
theorem ofReal_neg (r : ℝ) : ((-r : ℝ) : ℂ) = -r :=
  ext_iff.2 <| by simp
#align complex.of_real_neg Complex.ofReal_neg
-/

instance : Sub ℂ :=
  ⟨fun z w => ⟨z.re - w.re, z.im - w.im⟩⟩

instance : Mul ℂ :=
  ⟨fun z w => ⟨z.re * w.re - z.im * w.im, z.re * w.im + z.im * w.re⟩⟩

#print Complex.mul_re /-
@[simp]
theorem mul_re (z w : ℂ) : (z * w).re = z.re * w.re - z.im * w.im :=
  rfl
#align complex.mul_re Complex.mul_re
-/

#print Complex.mul_im /-
@[simp]
theorem mul_im (z w : ℂ) : (z * w).im = z.re * w.im + z.im * w.re :=
  rfl
#align complex.mul_im Complex.mul_im
-/

#print Complex.ofReal_mul /-
@[simp, norm_cast]
theorem ofReal_mul (r s : ℝ) : ((r * s : ℝ) : ℂ) = r * s :=
  ext_iff.2 <| by simp
#align complex.of_real_mul Complex.ofReal_mul
-/

#print Complex.ofReal_mul_re /-
theorem ofReal_mul_re (r : ℝ) (z : ℂ) : (↑r * z).re = r * z.re := by simp
#align complex.of_real_mul_re Complex.ofReal_mul_re
-/

#print Complex.ofReal_mul_im /-
theorem ofReal_mul_im (r : ℝ) (z : ℂ) : (↑r * z).im = r * z.im := by simp
#align complex.of_real_mul_im Complex.ofReal_mul_im
-/

#print Complex.ofReal_mul' /-
theorem ofReal_mul' (r : ℝ) (z : ℂ) : ↑r * z = ⟨r * z.re, r * z.im⟩ :=
  ext (ofReal_mul_re _ _) (ofReal_mul_im _ _)
#align complex.of_real_mul' Complex.ofReal_mul'
-/

/-! ### The imaginary unit, `I` -/


#print Complex.I /-
/-- The imaginary unit. -/
def I : ℂ :=
  ⟨0, 1⟩
#align complex.I Complex.I
-/

#print Complex.I_re /-
@[simp]
theorem I_re : I.re = 0 :=
  rfl
#align complex.I_re Complex.I_re
-/

#print Complex.I_im /-
@[simp]
theorem I_im : I.im = 1 :=
  rfl
#align complex.I_im Complex.I_im
-/

#print Complex.I_mul_I /-
@[simp]
theorem I_mul_I : I * I = -1 :=
  ext_iff.2 <| by simp
#align complex.I_mul_I Complex.I_mul_I
-/

#print Complex.I_mul /-
theorem I_mul (z : ℂ) : I * z = ⟨-z.im, z.re⟩ :=
  ext_iff.2 <| by simp
#align complex.I_mul Complex.I_mul
-/

#print Complex.I_ne_zero /-
theorem I_ne_zero : (I : ℂ) ≠ 0 :=
  mt (congr_arg im) zero_ne_one.symm
#align complex.I_ne_zero Complex.I_ne_zero
-/

#print Complex.mk_eq_add_mul_I /-
theorem mk_eq_add_mul_I (a b : ℝ) : Complex.mk a b = a + b * I :=
  ext_iff.2 <| by simp
#align complex.mk_eq_add_mul_I Complex.mk_eq_add_mul_I
-/

#print Complex.re_add_im /-
@[simp]
theorem re_add_im (z : ℂ) : (z.re : ℂ) + z.im * I = z :=
  ext_iff.2 <| by simp
#align complex.re_add_im Complex.re_add_im
-/

#print Complex.mul_I_re /-
theorem mul_I_re (z : ℂ) : (z * I).re = -z.im := by simp
#align complex.mul_I_re Complex.mul_I_re
-/

#print Complex.mul_I_im /-
theorem mul_I_im (z : ℂ) : (z * I).im = z.re := by simp
#align complex.mul_I_im Complex.mul_I_im
-/

#print Complex.I_mul_re /-
theorem I_mul_re (z : ℂ) : (I * z).re = -z.im := by simp
#align complex.I_mul_re Complex.I_mul_re
-/

#print Complex.I_mul_im /-
theorem I_mul_im (z : ℂ) : (I * z).im = z.re := by simp
#align complex.I_mul_im Complex.I_mul_im
-/

#print Complex.equivRealProd_symm_apply /-
@[simp]
theorem equivRealProd_symm_apply (p : ℝ × ℝ) : equivRealProd.symm p = p.1 + p.2 * I := by
  ext <;> simp [equiv_real_prod]
#align complex.equiv_real_prod_symm_apply Complex.equivRealProd_symm_apply
-/

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
            try rfl <;> apply ext_iff.2 <;> constructor <;> simp <;>
    ·
      first
      | ring1
      | ring_nf

instance : AddGroupWithOne ℂ :=
  { Complex.addCommGroup with
    natCast := fun n => ⟨n, 0⟩
    natCast_zero := by ext <;> simp [Nat.cast]
    natCast_succ := fun _ => by ext <;> simp [Nat.cast]
    intCast := fun n => ⟨n, 0⟩
    intCast_ofNat := fun _ => by ext <;> simp [fun n => show @coe ℕ ℂ ⟨_⟩ n = ⟨n, 0⟩ from rfl]
    intCast_negSucc := fun _ => by ext <;> simp [fun n => show @coe ℕ ℂ ⟨_⟩ n = ⟨n, 0⟩ from rfl]
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
    ·
      first
      | ring1
      | ring_nf

/-- This shortcut instance ensures we do not find `ring` via the noncomputable `complex.field`
instance. -/
instance : Ring ℂ := by infer_instance

/-- This shortcut instance ensures we do not find `comm_semiring` via the noncomputable
`complex.field` instance. -/
instance : CommSemiring ℂ :=
  inferInstance

#print Complex.reAddGroupHom /-
/-- The "real part" map, considered as an additive group homomorphism. -/
def reAddGroupHom : ℂ →+ ℝ where
  toFun := re
  map_zero' := zero_re
  map_add' := add_re
#align complex.re_add_group_hom Complex.reAddGroupHom
-/

#print Complex.coe_reAddGroupHom /-
@[simp]
theorem coe_reAddGroupHom : (reAddGroupHom : ℂ → ℝ) = re :=
  rfl
#align complex.coe_re_add_group_hom Complex.coe_reAddGroupHom
-/

#print Complex.imAddGroupHom /-
/-- The "imaginary part" map, considered as an additive group homomorphism. -/
def imAddGroupHom : ℂ →+ ℝ where
  toFun := im
  map_zero' := zero_im
  map_add' := add_im
#align complex.im_add_group_hom Complex.imAddGroupHom
-/

#print Complex.coe_imAddGroupHom /-
@[simp]
theorem coe_imAddGroupHom : (imAddGroupHom : ℂ → ℝ) = im :=
  rfl
#align complex.coe_im_add_group_hom Complex.coe_imAddGroupHom
-/

#print Complex.I_pow_bit0 /-
@[simp]
theorem I_pow_bit0 (n : ℕ) : I ^ bit0 n = (-1) ^ n := by rw [pow_bit0', I_mul_I]
#align complex.I_pow_bit0 Complex.I_pow_bit0
-/

#print Complex.I_pow_bit1 /-
@[simp]
theorem I_pow_bit1 (n : ℕ) : I ^ bit1 n = (-1) ^ n * I := by rw [pow_bit1', I_mul_I]
#align complex.I_pow_bit1 Complex.I_pow_bit1
-/

/-! ### Complex conjugation -/


/-- This defines the complex conjugate as the `star` operation of the `star_ring ℂ`. It
is recommended to use the ring endomorphism version `star_ring_end`, available under the
notation `conj` in the locale `complex_conjugate`. -/
instance : StarRing ℂ where
  unit z := ⟨z.re, -z.im⟩
  star_involutive x := by simp only [eta, neg_neg]
  star_mul a b := by ext <;> simp [add_comm] <;> ring
  star_add a b := by ext <;> simp [add_comm]

#print Complex.conj_re /-
@[simp]
theorem conj_re (z : ℂ) : (conj z).re = z.re :=
  rfl
#align complex.conj_re Complex.conj_re
-/

#print Complex.conj_im /-
@[simp]
theorem conj_im (z : ℂ) : (conj z).im = -z.im :=
  rfl
#align complex.conj_im Complex.conj_im
-/

#print Complex.conj_ofReal /-
theorem conj_ofReal (r : ℝ) : conj (r : ℂ) = r :=
  ext_iff.2 <| by simp [conj]
#align complex.conj_of_real Complex.conj_ofReal
-/

#print Complex.conj_I /-
@[simp]
theorem conj_I : conj I = -I :=
  ext_iff.2 <| by simp
#align complex.conj_I Complex.conj_I
-/

#print Complex.conj_bit0 /-
theorem conj_bit0 (z : ℂ) : conj (bit0 z) = bit0 (conj z) :=
  ext_iff.2 <| by simp [bit0]
#align complex.conj_bit0 Complex.conj_bit0
-/

#print Complex.conj_bit1 /-
theorem conj_bit1 (z : ℂ) : conj (bit1 z) = bit1 (conj z) :=
  ext_iff.2 <| by simp [bit0]
#align complex.conj_bit1 Complex.conj_bit1
-/

#print Complex.conj_neg_I /-
@[simp]
theorem conj_neg_I : conj (-I) = I :=
  ext_iff.2 <| by simp
#align complex.conj_neg_I Complex.conj_neg_I
-/

#print Complex.conj_eq_iff_real /-
theorem conj_eq_iff_real {z : ℂ} : conj z = z ↔ ∃ r : ℝ, z = r :=
  ⟨fun h => ⟨z.re, ext rfl <| eq_zero_of_neg_eq (congr_arg im h)⟩, fun ⟨h, e⟩ => by
    rw [e, conj_of_real]⟩
#align complex.conj_eq_iff_real Complex.conj_eq_iff_real
-/

#print Complex.conj_eq_iff_re /-
theorem conj_eq_iff_re {z : ℂ} : conj z = z ↔ (z.re : ℂ) = z :=
  conj_eq_iff_real.trans ⟨by rintro ⟨r, rfl⟩ <;> simp, fun h => ⟨_, h.symm⟩⟩
#align complex.conj_eq_iff_re Complex.conj_eq_iff_re
-/

#print Complex.conj_eq_iff_im /-
theorem conj_eq_iff_im {z : ℂ} : conj z = z ↔ z.im = 0 :=
  ⟨fun h => add_self_eq_zero.mp (neg_eq_iff_add_eq_zero.mp (congr_arg im h)), fun h =>
    ext rfl (neg_eq_iff_add_eq_zero.mpr (add_self_eq_zero.mpr h))⟩
#align complex.conj_eq_iff_im Complex.conj_eq_iff_im
-/

#print Complex.star_def /-
-- `simp_nf` complains about this being provable by `is_R_or_C.star_def` even
-- though it's not imported by this file.
@[simp, nolint simp_nf]
theorem star_def : (Star.star : ℂ → ℂ) = conj :=
  rfl
#align complex.star_def Complex.star_def
-/

/-! ### Norm squared -/


#print Complex.normSq /-
/-- The norm squared function. -/
@[pp_nodot]
def normSq : ℂ →*₀ ℝ where
  toFun z := z.re * z.re + z.im * z.im
  map_zero' := by simp
  map_one' := by simp
  map_mul' z w := by dsimp; ring
#align complex.norm_sq Complex.normSq
-/

#print Complex.normSq_apply /-
theorem normSq_apply (z : ℂ) : normSq z = z.re * z.re + z.im * z.im :=
  rfl
#align complex.norm_sq_apply Complex.normSq_apply
-/

#print Complex.normSq_ofReal /-
@[simp]
theorem normSq_ofReal (r : ℝ) : normSq r = r * r := by simp [norm_sq]
#align complex.norm_sq_of_real Complex.normSq_ofReal
-/

#print Complex.normSq_mk /-
@[simp]
theorem normSq_mk (x y : ℝ) : normSq ⟨x, y⟩ = x * x + y * y :=
  rfl
#align complex.norm_sq_mk Complex.normSq_mk
-/

#print Complex.normSq_add_mul_I /-
theorem normSq_add_mul_I (x y : ℝ) : normSq (x + y * I) = x ^ 2 + y ^ 2 := by
  rw [← mk_eq_add_mul_I, norm_sq_mk, sq, sq]
#align complex.norm_sq_add_mul_I Complex.normSq_add_mul_I
-/

#print Complex.normSq_eq_conj_mul_self /-
theorem normSq_eq_conj_mul_self {z : ℂ} : (normSq z : ℂ) = conj z * z := by
  ext <;> simp [norm_sq, mul_comm]
#align complex.norm_sq_eq_conj_mul_self Complex.normSq_eq_conj_mul_self
-/

#print Complex.normSq_zero /-
@[simp]
theorem normSq_zero : normSq 0 = 0 :=
  normSq.map_zero
#align complex.norm_sq_zero Complex.normSq_zero
-/

#print Complex.normSq_one /-
@[simp]
theorem normSq_one : normSq 1 = 1 :=
  normSq.map_one
#align complex.norm_sq_one Complex.normSq_one
-/

#print Complex.normSq_I /-
@[simp]
theorem normSq_I : normSq I = 1 := by simp [norm_sq]
#align complex.norm_sq_I Complex.normSq_I
-/

#print Complex.normSq_nonneg /-
theorem normSq_nonneg (z : ℂ) : 0 ≤ normSq z :=
  add_nonneg (mul_self_nonneg _) (mul_self_nonneg _)
#align complex.norm_sq_nonneg Complex.normSq_nonneg
-/

#print Complex.range_normSq /-
@[simp]
theorem range_normSq : range normSq = Ici 0 :=
  Subset.antisymm (range_subset_iff.2 normSq_nonneg) fun x hx =>
    ⟨Real.sqrt x, by rw [norm_sq_of_real, Real.mul_self_sqrt hx]⟩
#align complex.range_norm_sq Complex.range_normSq
-/

#print Complex.normSq_eq_zero /-
theorem normSq_eq_zero {z : ℂ} : normSq z = 0 ↔ z = 0 :=
  ⟨fun h =>
    ext (eq_zero_of_mul_self_add_mul_self_eq_zero h)
      (eq_zero_of_mul_self_add_mul_self_eq_zero <| (add_comm _ _).trans h),
    fun h => h.symm ▸ normSq_zero⟩
#align complex.norm_sq_eq_zero Complex.normSq_eq_zero
-/

#print Complex.normSq_pos /-
@[simp]
theorem normSq_pos {z : ℂ} : 0 < normSq z ↔ z ≠ 0 :=
  (normSq_nonneg z).lt_iff_ne.trans <| not_congr (eq_comm.trans normSq_eq_zero)
#align complex.norm_sq_pos Complex.normSq_pos
-/

#print Complex.normSq_neg /-
@[simp]
theorem normSq_neg (z : ℂ) : normSq (-z) = normSq z := by simp [norm_sq]
#align complex.norm_sq_neg Complex.normSq_neg
-/

#print Complex.normSq_conj /-
@[simp]
theorem normSq_conj (z : ℂ) : normSq (conj z) = normSq z := by simp [norm_sq]
#align complex.norm_sq_conj Complex.normSq_conj
-/

#print Complex.normSq_mul /-
theorem normSq_mul (z w : ℂ) : normSq (z * w) = normSq z * normSq w :=
  normSq.map_mul z w
#align complex.norm_sq_mul Complex.normSq_mul
-/

#print Complex.normSq_add /-
theorem normSq_add (z w : ℂ) : normSq (z + w) = normSq z + normSq w + 2 * (z * conj w).re := by
  dsimp [norm_sq] <;> ring
#align complex.norm_sq_add Complex.normSq_add
-/

#print Complex.re_sq_le_normSq /-
theorem re_sq_le_normSq (z : ℂ) : z.re * z.re ≤ normSq z :=
  le_add_of_nonneg_right (mul_self_nonneg _)
#align complex.re_sq_le_norm_sq Complex.re_sq_le_normSq
-/

#print Complex.im_sq_le_normSq /-
theorem im_sq_le_normSq (z : ℂ) : z.im * z.im ≤ normSq z :=
  le_add_of_nonneg_left (mul_self_nonneg _)
#align complex.im_sq_le_norm_sq Complex.im_sq_le_normSq
-/

#print Complex.mul_conj /-
theorem mul_conj (z : ℂ) : z * conj z = normSq z :=
  ext_iff.2 <| by simp [norm_sq, mul_comm, sub_eq_neg_add, add_comm]
#align complex.mul_conj Complex.mul_conj
-/

#print Complex.add_conj /-
theorem add_conj (z : ℂ) : z + conj z = (2 * z.re : ℝ) :=
  ext_iff.2 <| by simp [two_mul]
#align complex.add_conj Complex.add_conj
-/

#print Complex.ofReal /-
/-- The coercion `ℝ → ℂ` as a `ring_hom`. -/
def ofReal : ℝ →+* ℂ :=
  ⟨coe, ofReal_one, ofReal_mul, ofReal_zero, ofReal_add⟩
#align complex.of_real Complex.ofReal
-/

#print Complex.ofReal_eq_coe /-
@[simp]
theorem ofReal_eq_coe (r : ℝ) : ofReal r = r :=
  rfl
#align complex.of_real_eq_coe Complex.ofReal_eq_coe
-/

#print Complex.I_sq /-
@[simp]
theorem I_sq : I ^ 2 = -1 := by rw [sq, I_mul_I]
#align complex.I_sq Complex.I_sq
-/

#print Complex.sub_re /-
@[simp]
theorem sub_re (z w : ℂ) : (z - w).re = z.re - w.re :=
  rfl
#align complex.sub_re Complex.sub_re
-/

#print Complex.sub_im /-
@[simp]
theorem sub_im (z w : ℂ) : (z - w).im = z.im - w.im :=
  rfl
#align complex.sub_im Complex.sub_im
-/

#print Complex.ofReal_sub /-
@[simp, norm_cast]
theorem ofReal_sub (r s : ℝ) : ((r - s : ℝ) : ℂ) = r - s :=
  ext_iff.2 <| by simp
#align complex.of_real_sub Complex.ofReal_sub
-/

#print Complex.ofReal_pow /-
@[simp, norm_cast]
theorem ofReal_pow (r : ℝ) (n : ℕ) : ((r ^ n : ℝ) : ℂ) = r ^ n := by
  induction n <;> simp [*, of_real_mul, pow_succ]
#align complex.of_real_pow Complex.ofReal_pow
-/

#print Complex.sub_conj /-
theorem sub_conj (z : ℂ) : z - conj z = (2 * z.im : ℝ) * I :=
  ext_iff.2 <| by simp [two_mul, sub_eq_add_neg]
#align complex.sub_conj Complex.sub_conj
-/

#print Complex.normSq_sub /-
theorem normSq_sub (z w : ℂ) : normSq (z - w) = normSq z + normSq w - 2 * (z * conj w).re :=
  by
  rw [sub_eq_add_neg, norm_sq_add]
  simp only [RingHom.map_neg, mul_neg, neg_re, Tactic.Ring.add_neg_eq_sub, norm_sq_neg]
#align complex.norm_sq_sub Complex.normSq_sub
-/

/-! ### Inversion -/


noncomputable instance : Inv ℂ :=
  ⟨fun z => conj z * ((normSq z)⁻¹ : ℝ)⟩

#print Complex.inv_def /-
theorem inv_def (z : ℂ) : z⁻¹ = conj z * ((normSq z)⁻¹ : ℝ) :=
  rfl
#align complex.inv_def Complex.inv_def
-/

#print Complex.inv_re /-
@[simp]
theorem inv_re (z : ℂ) : z⁻¹.re = z.re / normSq z := by simp [inv_def, division_def]
#align complex.inv_re Complex.inv_re
-/

#print Complex.inv_im /-
@[simp]
theorem inv_im (z : ℂ) : z⁻¹.im = -z.im / normSq z := by simp [inv_def, division_def]
#align complex.inv_im Complex.inv_im
-/

#print Complex.ofReal_inv /-
@[simp, norm_cast]
theorem ofReal_inv (r : ℝ) : ((r⁻¹ : ℝ) : ℂ) = r⁻¹ :=
  ext_iff.2 <| by simp
#align complex.of_real_inv Complex.ofReal_inv
-/

#print Complex.inv_zero /-
protected theorem inv_zero : (0⁻¹ : ℂ) = 0 := by rw [← of_real_zero, ← of_real_inv, inv_zero]
#align complex.inv_zero Complex.inv_zero
-/

#print Complex.mul_inv_cancel /-
protected theorem mul_inv_cancel {z : ℂ} (h : z ≠ 0) : z * z⁻¹ = 1 := by
  rw [inv_def, ← mul_assoc, mul_conj, ← of_real_mul, mul_inv_cancel (mt norm_sq_eq_zero.1 h),
    of_real_one]
#align complex.mul_inv_cancel Complex.mul_inv_cancel
-/

/-! ### Field instance and lemmas -/


noncomputable instance : Field ℂ :=
  { Complex.commRing, Complex.nontrivial with
    inv := Inv.inv
    mul_inv_cancel := @Complex.mul_inv_cancel
    inv_zero := Complex.inv_zero }

#print Complex.I_zpow_bit0 /-
@[simp]
theorem I_zpow_bit0 (n : ℤ) : I ^ bit0 n = (-1) ^ n := by rw [zpow_bit0', I_mul_I]
#align complex.I_zpow_bit0 Complex.I_zpow_bit0
-/

#print Complex.I_zpow_bit1 /-
@[simp]
theorem I_zpow_bit1 (n : ℤ) : I ^ bit1 n = (-1) ^ n * I := by rw [zpow_bit1', I_mul_I]
#align complex.I_zpow_bit1 Complex.I_zpow_bit1
-/

#print Complex.div_re /-
theorem div_re (z w : ℂ) : (z / w).re = z.re * w.re / normSq w + z.im * w.im / normSq w := by
  simp [div_eq_mul_inv, mul_assoc, sub_eq_add_neg]
#align complex.div_re Complex.div_re
-/

#print Complex.div_im /-
theorem div_im (z w : ℂ) : (z / w).im = z.im * w.re / normSq w - z.re * w.im / normSq w := by
  simp [div_eq_mul_inv, mul_assoc, sub_eq_add_neg, add_comm]
#align complex.div_im Complex.div_im
-/

#print Complex.conj_inv /-
theorem conj_inv (x : ℂ) : conj x⁻¹ = (conj x)⁻¹ :=
  star_inv' _
#align complex.conj_inv Complex.conj_inv
-/

#print Complex.ofReal_div /-
@[simp, norm_cast]
theorem ofReal_div (r s : ℝ) : ((r / s : ℝ) : ℂ) = r / s :=
  map_div₀ ofReal r s
#align complex.of_real_div Complex.ofReal_div
-/

#print Complex.ofReal_zpow /-
@[simp, norm_cast]
theorem ofReal_zpow (r : ℝ) (n : ℤ) : ((r ^ n : ℝ) : ℂ) = (r : ℂ) ^ n :=
  map_zpow₀ ofReal r n
#align complex.of_real_zpow Complex.ofReal_zpow
-/

#print Complex.div_I /-
@[simp]
theorem div_I (z : ℂ) : z / I = -(z * I) :=
  (div_eq_iff_mul_eq I_ne_zero).2 <| by simp [mul_assoc]
#align complex.div_I Complex.div_I
-/

#print Complex.inv_I /-
@[simp]
theorem inv_I : I⁻¹ = -I := by simp [inv_eq_one_div]
#align complex.inv_I Complex.inv_I
-/

#print Complex.normSq_inv /-
@[simp]
theorem normSq_inv (z : ℂ) : normSq z⁻¹ = (normSq z)⁻¹ :=
  map_inv₀ normSq z
#align complex.norm_sq_inv Complex.normSq_inv
-/

#print Complex.normSq_div /-
@[simp]
theorem normSq_div (z w : ℂ) : normSq (z / w) = normSq z / normSq w :=
  map_div₀ normSq z w
#align complex.norm_sq_div Complex.normSq_div
-/

/-! ### Cast lemmas -/


#print Complex.ofReal_nat_cast /-
@[simp, norm_cast]
theorem ofReal_nat_cast (n : ℕ) : ((n : ℝ) : ℂ) = n :=
  map_natCast ofReal n
#align complex.of_real_nat_cast Complex.ofReal_nat_cast
-/

#print Complex.nat_cast_re /-
@[simp, norm_cast]
theorem nat_cast_re (n : ℕ) : (n : ℂ).re = n := by rw [← of_real_nat_cast, of_real_re]
#align complex.nat_cast_re Complex.nat_cast_re
-/

#print Complex.nat_cast_im /-
@[simp, norm_cast]
theorem nat_cast_im (n : ℕ) : (n : ℂ).im = 0 := by rw [← of_real_nat_cast, of_real_im]
#align complex.nat_cast_im Complex.nat_cast_im
-/

#print Complex.ofReal_int_cast /-
@[simp, norm_cast]
theorem ofReal_int_cast (n : ℤ) : ((n : ℝ) : ℂ) = n :=
  map_intCast ofReal n
#align complex.of_real_int_cast Complex.ofReal_int_cast
-/

#print Complex.int_cast_re /-
@[simp, norm_cast]
theorem int_cast_re (n : ℤ) : (n : ℂ).re = n := by rw [← of_real_int_cast, of_real_re]
#align complex.int_cast_re Complex.int_cast_re
-/

#print Complex.int_cast_im /-
@[simp, norm_cast]
theorem int_cast_im (n : ℤ) : (n : ℂ).im = 0 := by rw [← of_real_int_cast, of_real_im]
#align complex.int_cast_im Complex.int_cast_im
-/

#print Complex.ofReal_rat_cast /-
@[simp, norm_cast]
theorem ofReal_rat_cast (n : ℚ) : ((n : ℝ) : ℂ) = n :=
  map_ratCast ofReal n
#align complex.of_real_rat_cast Complex.ofReal_rat_cast
-/

#print Complex.rat_cast_re /-
@[simp, norm_cast]
theorem rat_cast_re (q : ℚ) : (q : ℂ).re = q := by rw [← of_real_rat_cast, of_real_re]
#align complex.rat_cast_re Complex.rat_cast_re
-/

#print Complex.rat_cast_im /-
@[simp, norm_cast]
theorem rat_cast_im (q : ℚ) : (q : ℂ).im = 0 := by rw [← of_real_rat_cast, of_real_im]
#align complex.rat_cast_im Complex.rat_cast_im
-/

/-! ### Characteristic zero -/


#print Complex.charZero /-
instance charZero : CharZero ℂ :=
  charZero_of_inj_zero fun n h => by
    rwa [← of_real_nat_cast, of_real_eq_zero, Nat.cast_eq_zero] at h 
#align complex.char_zero_complex Complex.charZero
-/

#print Complex.re_eq_add_conj /-
/-- A complex number `z` plus its conjugate `conj z` is `2` times its real part. -/
theorem re_eq_add_conj (z : ℂ) : (z.re : ℂ) = (z + conj z) / 2 := by
  simp only [add_conj, of_real_mul, of_real_one, of_real_bit0,
    mul_div_cancel_left (z.re : ℂ) two_ne_zero]
#align complex.re_eq_add_conj Complex.re_eq_add_conj
-/

#print Complex.im_eq_sub_conj /-
/-- A complex number `z` minus its conjugate `conj z` is `2i` times its imaginary part. -/
theorem im_eq_sub_conj (z : ℂ) : (z.im : ℂ) = (z - conj z) / (2 * I) := by
  simp only [sub_conj, of_real_mul, of_real_one, of_real_bit0, mul_right_comm,
    mul_div_cancel_left _ (mul_ne_zero two_ne_zero I_ne_zero : 2 * I ≠ 0)]
#align complex.im_eq_sub_conj Complex.im_eq_sub_conj
-/

/-! ### Absolute value -/


namespace AbsTheory

-- We develop enough theory to bundle `abs` into an `absolute_value` before making things public;
-- this is so there's not two versions of it hanging around.
local notation "abs" z => (normSq z).sqrt

private theorem mul_self_abs (z : ℂ) : ((abs z) * abs z) = normSq z :=
  Real.mul_self_sqrt (normSq_nonneg _)

private theorem abs_nonneg' (z : ℂ) : 0 ≤ abs z :=
  Real.sqrt_nonneg _

#print Complex.AbsTheory.abs_conj /-
theorem abs_conj (z : ℂ) : (abs conj z) = abs z := by simp
#align complex.abs_theory.abs_conj Complex.AbsTheory.abs_conj
-/

private theorem abs_re_le_abs (z : ℂ) : |z.re| ≤ abs z :=
  by
  rw [mul_self_le_mul_self_iff (abs_nonneg z.re) (abs_nonneg' _), abs_mul_abs_self, mul_self_abs]
  apply re_sq_le_norm_sq

private theorem re_le_abs (z : ℂ) : z.re ≤ abs z :=
  (abs_le.1 (abs_re_le_abs _)).2

private theorem abs_mul (z w : ℂ) : (abs z * w) = (abs z) * abs w := by
  rw [norm_sq_mul, Real.sqrt_mul (norm_sq_nonneg _)]

private theorem abs_add (z w : ℂ) : (abs z + w) ≤ (abs z) + abs w :=
  (mul_self_le_mul_self_iff (abs_nonneg' (z + w)) (add_nonneg (abs_nonneg' z) (abs_nonneg' w))).2 <|
    by
    rw [mul_self_abs, add_mul_self_eq, mul_self_abs, mul_self_abs, add_right_comm, norm_sq_add,
      add_le_add_iff_left, mul_assoc, mul_le_mul_left (zero_lt_two' ℝ), ←
      Real.sqrt_mul <| norm_sq_nonneg z, ← norm_sq_conj w, ← map_mul]
    exact re_le_abs (z * conj w)

#print Complex.abs /-
/-- The complex absolute value function, defined as the square root of the norm squared. -/
noncomputable def Complex.abs : AbsoluteValue ℂ ℝ
    where
  toFun x := abs x
  map_mul' := abs_mul
  nonneg' := abs_nonneg'
  eq_zero' _ := (Real.sqrt_eq_zero <| normSq_nonneg _).trans normSq_eq_zero
  add_le' := abs_add
#align complex.abs Complex.abs
-/

end AbsTheory

#print Complex.abs_def /-
theorem abs_def : (abs : ℂ → ℝ) = fun z => (normSq z).sqrt :=
  rfl
#align complex.abs_def Complex.abs_def
-/

#print Complex.abs_apply /-
theorem abs_apply {z : ℂ} : abs z = (normSq z).sqrt :=
  rfl
#align complex.abs_apply Complex.abs_apply
-/

#print Complex.abs_ofReal /-
@[simp, norm_cast]
theorem abs_ofReal (r : ℝ) : abs r = |r| := by
  simp [abs, norm_sq_of_real, Real.sqrt_mul_self_eq_abs]
#align complex.abs_of_real Complex.abs_ofReal
-/

#print Complex.abs_of_nonneg /-
theorem abs_of_nonneg {r : ℝ} (h : 0 ≤ r) : abs r = r :=
  (abs_ofReal _).trans (abs_of_nonneg h)
#align complex.abs_of_nonneg Complex.abs_of_nonneg
-/

#print Complex.abs_of_nat /-
theorem abs_of_nat (n : ℕ) : Complex.abs n = n :=
  calc
    Complex.abs n = Complex.abs (n : ℝ) := by rw [of_real_nat_cast]
    _ = _ := abs_of_nonneg (Nat.cast_nonneg n)
#align complex.abs_of_nat Complex.abs_of_nat
-/

#print Complex.mul_self_abs /-
theorem mul_self_abs (z : ℂ) : abs z * abs z = normSq z :=
  Real.mul_self_sqrt (normSq_nonneg _)
#align complex.mul_self_abs Complex.mul_self_abs
-/

#print Complex.sq_abs /-
theorem sq_abs (z : ℂ) : abs z ^ 2 = normSq z :=
  Real.sq_sqrt (normSq_nonneg _)
#align complex.sq_abs Complex.sq_abs
-/

#print Complex.sq_abs_sub_sq_re /-
@[simp]
theorem sq_abs_sub_sq_re (z : ℂ) : abs z ^ 2 - z.re ^ 2 = z.im ^ 2 := by
  rw [sq_abs, norm_sq_apply, ← sq, ← sq, add_sub_cancel']
#align complex.sq_abs_sub_sq_re Complex.sq_abs_sub_sq_re
-/

#print Complex.sq_abs_sub_sq_im /-
@[simp]
theorem sq_abs_sub_sq_im (z : ℂ) : abs z ^ 2 - z.im ^ 2 = z.re ^ 2 := by
  rw [← sq_abs_sub_sq_re, sub_sub_cancel]
#align complex.sq_abs_sub_sq_im Complex.sq_abs_sub_sq_im
-/

#print Complex.abs_I /-
@[simp]
theorem abs_I : abs I = 1 := by simp [abs]
#align complex.abs_I Complex.abs_I
-/

#print Complex.abs_two /-
@[simp]
theorem abs_two : abs 2 = 2 :=
  calc
    abs 2 = abs (2 : ℝ) := by rw [of_real_bit0, of_real_one]
    _ = (2 : ℝ) := abs_of_nonneg (by norm_num)
#align complex.abs_two Complex.abs_two
-/

#print Complex.range_abs /-
@[simp]
theorem range_abs : range abs = Ici 0 :=
  Subset.antisymm (range_subset_iff.2 abs.NonNeg) fun x hx => ⟨x, abs_of_nonneg hx⟩
#align complex.range_abs Complex.range_abs
-/

#print Complex.abs_conj /-
@[simp]
theorem abs_conj (z : ℂ) : abs (conj z) = abs z :=
  AbsTheory.abs_conj z
#align complex.abs_conj Complex.abs_conj
-/

#print Complex.abs_prod /-
@[simp]
theorem abs_prod {ι : Type _} (s : Finset ι) (f : ι → ℂ) :
    abs (s.Prod f) = s.Prod fun i => abs (f i) :=
  map_prod abs _ _
#align complex.abs_prod Complex.abs_prod
-/

#print Complex.abs_pow /-
@[simp]
theorem abs_pow (z : ℂ) (n : ℕ) : abs (z ^ n) = abs z ^ n :=
  map_pow abs z n
#align complex.abs_pow Complex.abs_pow
-/

#print Complex.abs_zpow /-
@[simp]
theorem abs_zpow (z : ℂ) (n : ℤ) : abs (z ^ n) = abs z ^ n :=
  map_zpow₀ abs z n
#align complex.abs_zpow Complex.abs_zpow
-/

#print Complex.abs_re_le_abs /-
theorem abs_re_le_abs (z : ℂ) : |z.re| ≤ abs z :=
  Real.abs_le_sqrt <| by rw [norm_sq_apply, ← sq]; exact le_add_of_nonneg_right (mul_self_nonneg _)
#align complex.abs_re_le_abs Complex.abs_re_le_abs
-/

#print Complex.abs_im_le_abs /-
theorem abs_im_le_abs (z : ℂ) : |z.im| ≤ abs z :=
  Real.abs_le_sqrt <| by rw [norm_sq_apply, ← sq, ← sq]; exact le_add_of_nonneg_left (sq_nonneg _)
#align complex.abs_im_le_abs Complex.abs_im_le_abs
-/

#print Complex.re_le_abs /-
theorem re_le_abs (z : ℂ) : z.re ≤ abs z :=
  (abs_le.1 (abs_re_le_abs _)).2
#align complex.re_le_abs Complex.re_le_abs
-/

#print Complex.im_le_abs /-
theorem im_le_abs (z : ℂ) : z.im ≤ abs z :=
  (abs_le.1 (abs_im_le_abs _)).2
#align complex.im_le_abs Complex.im_le_abs
-/

#print Complex.abs_re_lt_abs /-
@[simp]
theorem abs_re_lt_abs {z : ℂ} : |z.re| < abs z ↔ z.im ≠ 0 := by
  rw [abs, AbsoluteValue.coe_mk, MulHom.coe_mk, Real.lt_sqrt (abs_nonneg _), norm_sq_apply,
    _root_.sq_abs, ← sq, lt_add_iff_pos_right, mul_self_pos]
#align complex.abs_re_lt_abs Complex.abs_re_lt_abs
-/

#print Complex.abs_im_lt_abs /-
@[simp]
theorem abs_im_lt_abs {z : ℂ} : |z.im| < abs z ↔ z.re ≠ 0 := by simpa using @abs_re_lt_abs (z * I)
#align complex.abs_im_lt_abs Complex.abs_im_lt_abs
-/

#print Complex.abs_abs /-
@[simp]
theorem abs_abs (z : ℂ) : |abs z| = abs z :=
  abs_of_nonneg (abs.NonNeg _)
#align complex.abs_abs Complex.abs_abs
-/

#print Complex.abs_le_abs_re_add_abs_im /-
theorem abs_le_abs_re_add_abs_im (z : ℂ) : abs z ≤ |z.re| + |z.im| := by
  simpa [re_add_im] using abs.add_le z.re (z.im * I)
#align complex.abs_le_abs_re_add_abs_im Complex.abs_le_abs_re_add_abs_im
-/

#print Complex.abs_le_sqrt_two_mul_max /-
theorem abs_le_sqrt_two_mul_max (z : ℂ) : abs z ≤ Real.sqrt 2 * max (|z.re|) (|z.im|) :=
  by
  cases' z with x y
  simp only [abs_apply, norm_sq_mk, ← sq]
  wlog hle : |x| ≤ |y|
  · rw [add_comm, max_comm]; exact this _ _ (le_of_not_le hle)
  calc
    Real.sqrt (x ^ 2 + y ^ 2) ≤ Real.sqrt (y ^ 2 + y ^ 2) :=
      Real.sqrt_le_sqrt (add_le_add_right (sq_le_sq.2 hle) _)
    _ = Real.sqrt 2 * max (|x|) (|y|) := by
      rw [max_eq_right hle, ← two_mul, Real.sqrt_mul two_pos.le, Real.sqrt_sq_eq_abs]
#align complex.abs_le_sqrt_two_mul_max Complex.abs_le_sqrt_two_mul_max
-/

#print Complex.abs_re_div_abs_le_one /-
theorem abs_re_div_abs_le_one (z : ℂ) : |z.re / z.abs| ≤ 1 :=
  if hz : z = 0 then by simp [hz, zero_le_one]
  else by simp_rw [_root_.abs_div, abs_abs, div_le_iff (abs.pos hz), one_mul, abs_re_le_abs]
#align complex.abs_re_div_abs_le_one Complex.abs_re_div_abs_le_one
-/

#print Complex.abs_im_div_abs_le_one /-
theorem abs_im_div_abs_le_one (z : ℂ) : |z.im / z.abs| ≤ 1 :=
  if hz : z = 0 then by simp [hz, zero_le_one]
  else by simp_rw [_root_.abs_div, abs_abs, div_le_iff (abs.pos hz), one_mul, abs_im_le_abs]
#align complex.abs_im_div_abs_le_one Complex.abs_im_div_abs_le_one
-/

#print Complex.abs_cast_nat /-
@[simp, norm_cast]
theorem abs_cast_nat (n : ℕ) : abs (n : ℂ) = n := by
  rw [← of_real_nat_cast, abs_of_nonneg (Nat.cast_nonneg n)]
#align complex.abs_cast_nat Complex.abs_cast_nat
-/

#print Complex.int_cast_abs /-
@[simp, norm_cast]
theorem int_cast_abs (n : ℤ) : ↑(|n|) = abs n := by
  rw [← of_real_int_cast, abs_of_real, Int.cast_abs]
#align complex.int_cast_abs Complex.int_cast_abs
-/

#print Complex.normSq_eq_abs /-
theorem normSq_eq_abs (x : ℂ) : normSq x = abs x ^ 2 := by
  simp [abs, sq, Real.mul_self_sqrt (norm_sq_nonneg _)]
#align complex.norm_sq_eq_abs Complex.normSq_eq_abs
-/

#print Complex.partialOrder /-
/-- We put a partial order on ℂ so that `z ≤ w` exactly if `w - z` is real and nonnegative.
Complex numbers with different imaginary parts are incomparable.
-/
protected def partialOrder : PartialOrder ℂ
    where
  le z w := z.re ≤ w.re ∧ z.im = w.im
  lt z w := z.re < w.re ∧ z.im = w.im
  lt_iff_le_not_le z w := by dsimp; rw [lt_iff_le_not_le]; tauto
  le_refl x := ⟨le_rfl, rfl⟩
  le_trans x y z h₁ h₂ := ⟨h₁.1.trans h₂.1, h₁.2.trans h₂.2⟩
  le_antisymm z w h₁ h₂ := ext (h₁.1.antisymm h₂.1) h₁.2
#align complex.partial_order Complex.partialOrder
-/

section ComplexOrder

scoped[ComplexOrder] attribute [instance] Complex.partialOrder

#print Complex.le_def /-
theorem le_def {z w : ℂ} : z ≤ w ↔ z.re ≤ w.re ∧ z.im = w.im :=
  Iff.rfl
#align complex.le_def Complex.le_def
-/

#print Complex.lt_def /-
theorem lt_def {z w : ℂ} : z < w ↔ z.re < w.re ∧ z.im = w.im :=
  Iff.rfl
#align complex.lt_def Complex.lt_def
-/

#print Complex.real_le_real /-
@[simp, norm_cast]
theorem real_le_real {x y : ℝ} : (x : ℂ) ≤ (y : ℂ) ↔ x ≤ y := by simp [le_def]
#align complex.real_le_real Complex.real_le_real
-/

#print Complex.real_lt_real /-
@[simp, norm_cast]
theorem real_lt_real {x y : ℝ} : (x : ℂ) < (y : ℂ) ↔ x < y := by simp [lt_def]
#align complex.real_lt_real Complex.real_lt_real
-/

#print Complex.zero_le_real /-
@[simp, norm_cast]
theorem zero_le_real {x : ℝ} : (0 : ℂ) ≤ (x : ℂ) ↔ 0 ≤ x :=
  real_le_real
#align complex.zero_le_real Complex.zero_le_real
-/

#print Complex.zero_lt_real /-
@[simp, norm_cast]
theorem zero_lt_real {x : ℝ} : (0 : ℂ) < (x : ℂ) ↔ 0 < x :=
  real_lt_real
#align complex.zero_lt_real Complex.zero_lt_real
-/

#print Complex.not_le_iff /-
theorem not_le_iff {z w : ℂ} : ¬z ≤ w ↔ w.re < z.re ∨ z.im ≠ w.im := by
  rw [le_def, not_and_or, not_le]
#align complex.not_le_iff Complex.not_le_iff
-/

#print Complex.not_lt_iff /-
theorem not_lt_iff {z w : ℂ} : ¬z < w ↔ w.re ≤ z.re ∨ z.im ≠ w.im := by
  rw [lt_def, not_and_or, not_lt]
#align complex.not_lt_iff Complex.not_lt_iff
-/

#print Complex.not_le_zero_iff /-
theorem not_le_zero_iff {z : ℂ} : ¬z ≤ 0 ↔ 0 < z.re ∨ z.im ≠ 0 :=
  not_le_iff
#align complex.not_le_zero_iff Complex.not_le_zero_iff
-/

#print Complex.not_lt_zero_iff /-
theorem not_lt_zero_iff {z : ℂ} : ¬z < 0 ↔ 0 ≤ z.re ∨ z.im ≠ 0 :=
  not_lt_iff
#align complex.not_lt_zero_iff Complex.not_lt_zero_iff
-/

#print Complex.eq_re_ofReal_le /-
theorem eq_re_ofReal_le {r : ℝ} {z : ℂ} (hz : (r : ℂ) ≤ z) : z = z.re := by ext; rfl;
  simp only [← (Complex.le_def.1 hz).2, Complex.zero_im, Complex.ofReal_im]
#align complex.eq_re_of_real_le Complex.eq_re_ofReal_le
-/

#print Complex.strictOrderedCommRing /-
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
-/

scoped[ComplexOrder] attribute [instance] Complex.strictOrderedCommRing

#print Complex.starOrderedRing /-
/-- With `z ≤ w` iff `w - z` is real and nonnegative, `ℂ` is a star ordered ring.
(That is, a star ring in which the nonnegative elements are those of the form `star z * z`.)
-/
protected def starOrderedRing : StarOrderedRing ℂ :=
  StarOrderedRing.ofNonnegIff' (fun _ _ => add_le_add_left) fun r =>
    by
    refine' ⟨fun hr => ⟨Real.sqrt r.re, _⟩, fun h => _⟩
    · have h₁ : 0 ≤ r.re := by rw [le_def] at hr ; exact hr.1
      have h₂ : r.im = 0 := by rw [le_def] at hr ; exact hr.2.symm
      ext
      ·
        simp only [of_real_im, star_def, of_real_re, sub_zero, conj_re, mul_re,
          MulZeroClass.mul_zero, ← Real.sqrt_mul h₁ r.re, Real.sqrt_mul_self h₁]
      ·
        simp only [h₂, add_zero, of_real_im, star_def, MulZeroClass.zero_mul, conj_im, mul_im,
          MulZeroClass.mul_zero, neg_zero]
    · obtain ⟨s, rfl⟩ := h
      simp only [← norm_sq_eq_conj_mul_self, norm_sq_nonneg, zero_le_real, star_def]
#align complex.star_ordered_ring Complex.starOrderedRing
-/

scoped[ComplexOrder] attribute [instance] Complex.starOrderedRing

end ComplexOrder

/-! ### Cauchy sequences -/


local notation "abs'" => Abs.abs

#print Complex.isCauSeq_re /-
theorem isCauSeq_re (f : CauSeq ℂ abs) : IsCauSeq abs' fun n => (f n).re := fun ε ε0 =>
  (f.Cauchy ε0).imp fun i H j ij =>
    lt_of_le_of_lt (by simpa using abs_re_le_abs (f j - f i)) (H _ ij)
#align complex.is_cau_seq_re Complex.isCauSeq_re
-/

#print Complex.isCauSeq_im /-
theorem isCauSeq_im (f : CauSeq ℂ abs) : IsCauSeq abs' fun n => (f n).im := fun ε ε0 =>
  (f.Cauchy ε0).imp fun i H j ij =>
    lt_of_le_of_lt (by simpa using abs_im_le_abs (f j - f i)) (H _ ij)
#align complex.is_cau_seq_im Complex.isCauSeq_im
-/

#print Complex.cauSeqRe /-
/-- The real part of a complex Cauchy sequence, as a real Cauchy sequence. -/
noncomputable def cauSeqRe (f : CauSeq ℂ abs) : CauSeq ℝ abs' :=
  ⟨_, isCauSeq_re f⟩
#align complex.cau_seq_re Complex.cauSeqRe
-/

#print Complex.cauSeqIm /-
/-- The imaginary part of a complex Cauchy sequence, as a real Cauchy sequence. -/
noncomputable def cauSeqIm (f : CauSeq ℂ abs) : CauSeq ℝ abs' :=
  ⟨_, isCauSeq_im f⟩
#align complex.cau_seq_im Complex.cauSeqIm
-/

#print Complex.isCauSeq_abs /-
theorem isCauSeq_abs {f : ℕ → ℂ} (hf : IsCauSeq abs f) : IsCauSeq abs' (abs ∘ f) := fun ε ε0 =>
  let ⟨i, hi⟩ := hf ε ε0
  ⟨i, fun j hj => lt_of_le_of_lt (abs.abs_abv_sub_le_abv_sub _ _) (hi j hj)⟩
#align complex.is_cau_seq_abs Complex.isCauSeq_abs
-/

#print Complex.limAux /-
/-- The limit of a Cauchy sequence of complex numbers. -/
noncomputable def limAux (f : CauSeq ℂ abs) : ℂ :=
  ⟨CauSeq.lim (cauSeqRe f), CauSeq.lim (cauSeqIm f)⟩
#align complex.lim_aux Complex.limAux
-/

#print Complex.equiv_limAux /-
theorem equiv_limAux (f : CauSeq ℂ abs) : f ≈ CauSeq.const abs (limAux f) := fun ε ε0 =>
  (exists_forall_ge_and (CauSeq.equiv_lim ⟨_, isCauSeq_re f⟩ _ (half_pos ε0))
        (CauSeq.equiv_lim ⟨_, isCauSeq_im f⟩ _ (half_pos ε0))).imp
    fun i H j ij => by
    cases' H _ ij with H₁ H₂
    apply lt_of_le_of_lt (abs_le_abs_re_add_abs_im _)
    dsimp [lim_aux] at *
    have := add_lt_add H₁ H₂
    rwa [add_halves] at this 
#align complex.equiv_lim_aux Complex.equiv_limAux
-/

instance : CauSeq.IsComplete ℂ abs :=
  ⟨fun f => ⟨limAux f, equiv_limAux f⟩⟩

open CauSeq

#print Complex.lim_eq_lim_im_add_lim_re /-
theorem lim_eq_lim_im_add_lim_re (f : CauSeq ℂ abs) :
    limUnder f = ↑(limUnder (cauSeqRe f)) + ↑(limUnder (cauSeqIm f)) * I :=
  lim_eq_of_equiv_const <|
    calc
      f ≈ _ := equiv_limAux f
      _ = CauSeq.const abs (↑(limUnder (cauSeqRe f)) + ↑(limUnder (cauSeqIm f)) * I) :=
        CauSeq.ext fun _ =>
          Complex.ext (by simp [lim_aux, cau_seq_re]) (by simp [lim_aux, cau_seq_im])
#align complex.lim_eq_lim_im_add_lim_re Complex.lim_eq_lim_im_add_lim_re
-/

#print Complex.lim_re /-
theorem lim_re (f : CauSeq ℂ abs) : limUnder (cauSeqRe f) = (limUnder f).re := by
  rw [lim_eq_lim_im_add_lim_re] <;> simp
#align complex.lim_re Complex.lim_re
-/

#print Complex.lim_im /-
theorem lim_im (f : CauSeq ℂ abs) : limUnder (cauSeqIm f) = (limUnder f).im := by
  rw [lim_eq_lim_im_add_lim_re] <;> simp
#align complex.lim_im Complex.lim_im
-/

#print Complex.isCauSeq_conj /-
theorem isCauSeq_conj (f : CauSeq ℂ abs) : IsCauSeq abs fun n => conj (f n) := fun ε ε0 =>
  let ⟨i, hi⟩ := f.2 ε ε0
  ⟨i, fun j hj => by rw [← RingHom.map_sub, abs_conj] <;> exact hi j hj⟩
#align complex.is_cau_seq_conj Complex.isCauSeq_conj
-/

#print Complex.cauSeqConj /-
/-- The complex conjugate of a complex Cauchy sequence, as a complex Cauchy sequence. -/
noncomputable def cauSeqConj (f : CauSeq ℂ abs) : CauSeq ℂ abs :=
  ⟨_, isCauSeq_conj f⟩
#align complex.cau_seq_conj Complex.cauSeqConj
-/

#print Complex.lim_conj /-
theorem lim_conj (f : CauSeq ℂ abs) : limUnder (cauSeqConj f) = conj (limUnder f) :=
  Complex.ext (by simp [cau_seq_conj, (lim_re _).symm, cau_seq_re])
    (by simp [cau_seq_conj, (lim_im _).symm, cau_seq_im, (lim_neg _).symm] <;> rfl)
#align complex.lim_conj Complex.lim_conj
-/

#print Complex.cauSeqAbs /-
/-- The absolute value of a complex Cauchy sequence, as a real Cauchy sequence. -/
noncomputable def cauSeqAbs (f : CauSeq ℂ abs) : CauSeq ℝ abs' :=
  ⟨_, isCauSeq_abs f.2⟩
#align complex.cau_seq_abs Complex.cauSeqAbs
-/

#print Complex.lim_abs /-
theorem lim_abs (f : CauSeq ℂ abs) : limUnder (cauSeqAbs f) = abs (limUnder f) :=
  lim_eq_of_equiv_const fun ε ε0 =>
    let ⟨i, hi⟩ := equiv_lim f ε ε0
    ⟨i, fun j hj => lt_of_le_of_lt (abs.abs_abv_sub_le_abv_sub _ _) (hi j hj)⟩
#align complex.lim_abs Complex.lim_abs
-/

variable {α : Type _} (s : Finset α)

#print Complex.ofReal_prod /-
@[simp, norm_cast]
theorem ofReal_prod (f : α → ℝ) : ((∏ i in s, f i : ℝ) : ℂ) = ∏ i in s, (f i : ℂ) :=
  RingHom.map_prod ofReal _ _
#align complex.of_real_prod Complex.ofReal_prod
-/

#print Complex.ofReal_sum /-
@[simp, norm_cast]
theorem ofReal_sum (f : α → ℝ) : ((∑ i in s, f i : ℝ) : ℂ) = ∑ i in s, (f i : ℂ) :=
  RingHom.map_sum ofReal _ _
#align complex.of_real_sum Complex.ofReal_sum
-/

#print Complex.re_sum /-
@[simp]
theorem re_sum (f : α → ℂ) : (∑ i in s, f i).re = ∑ i in s, (f i).re :=
  reAddGroupHom.map_sum f s
#align complex.re_sum Complex.re_sum
-/

#print Complex.im_sum /-
@[simp]
theorem im_sum (f : α → ℂ) : (∑ i in s, f i).im = ∑ i in s, (f i).im :=
  imAddGroupHom.map_sum f s
#align complex.im_sum Complex.im_sum
-/

end Complex

