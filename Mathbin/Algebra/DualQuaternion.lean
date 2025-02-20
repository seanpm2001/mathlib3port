/-
Copyright (c) 2023 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module algebra.dual_quaternion
! leanprover-community/mathlib commit 38df578a6450a8c5142b3727e3ae894c2300cae0
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.Algebra.DualNumber
import Mathbin.Algebra.Quaternion

/-!
# Dual quaternions

> THIS FILE IS SYNCHRONIZED WITH MATHLIB4.
> Any changes to this file require a corresponding PR to mathlib4.

Similar to the way that rotations in 3D space can be represented by quaternions of unit length,
rigid motions in 3D space can be represented by dual quaternions of unit length.

## Main results

* `quaternion.dual_number_equiv`: quaternions over dual numbers or dual
  numbers over quaternions are equivalent constructions.

## References

* <https://en.wikipedia.org/wiki/Dual_quaternion>
-/


variable {R : Type _} [CommRing R]

namespace Quaternion

#print Quaternion.dualNumberEquiv /-
/-- The dual quaternions can be equivalently represented as a quaternion with dual coefficients,
or as a dual number with quaternion coefficients.

See also `matrix.dual_number_equiv` for a similar result. -/
def dualNumberEquiv : Quaternion (DualNumber R) ≃ₐ[R] DualNumber (Quaternion R)
    where
  toFun q :=
    (⟨q.re.fst, q.imI.fst, q.imJ.fst, q.imK.fst⟩, ⟨q.re.snd, q.imI.snd, q.imJ.snd, q.imK.snd⟩)
  invFun d :=
    ⟨(d.fst.re, d.snd.re), (d.fst.imI, d.snd.imI), (d.fst.imJ, d.snd.imJ), (d.fst.imK, d.snd.imK)⟩
  left_inv := fun ⟨⟨r, rε⟩, ⟨i, iε⟩, ⟨j, jε⟩, ⟨k, kε⟩⟩ => rfl
  right_inv := fun ⟨⟨r, i, j, k⟩, ⟨rε, iε, jε, kε⟩⟩ => rfl
  map_mul' := by
    rintro ⟨⟨xr, xrε⟩, ⟨xi, xiε⟩, ⟨xj, xjε⟩, ⟨xk, xkε⟩⟩
    rintro ⟨⟨yr, yrε⟩, ⟨yi, yiε⟩, ⟨yj, yjε⟩, ⟨yk, ykε⟩⟩
    ext : 1
    · rfl
    · dsimp
      congr 1 <;> ring
  map_add' := by
    rintro ⟨⟨xr, xrε⟩, ⟨xi, xiε⟩, ⟨xj, xjε⟩, ⟨xk, xkε⟩⟩
    rintro ⟨⟨yr, yrε⟩, ⟨yi, yiε⟩, ⟨yj, yjε⟩, ⟨yk, ykε⟩⟩
    rfl
  commutes' r := rfl
#align quaternion.dual_number_equiv Quaternion.dualNumberEquiv
-/

/-! Lemmas characterizing `quaternion.dual_number_equiv`. -/


#print Quaternion.re_fst_dualNumberEquiv /-
-- `simps` can't work on `dual_number` because it's not a structure
@[simp]
theorem re_fst_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).fst.re = q.re.fst :=
  rfl
#align quaternion.re_fst_dual_number_equiv Quaternion.re_fst_dualNumberEquiv
-/

#print Quaternion.imI_fst_dualNumberEquiv /-
@[simp]
theorem imI_fst_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).fst.imI = q.imI.fst :=
  rfl
#align quaternion.im_i_fst_dual_number_equiv Quaternion.imI_fst_dualNumberEquiv
-/

#print Quaternion.imJ_fst_dualNumberEquiv /-
@[simp]
theorem imJ_fst_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).fst.imJ = q.imJ.fst :=
  rfl
#align quaternion.im_j_fst_dual_number_equiv Quaternion.imJ_fst_dualNumberEquiv
-/

#print Quaternion.imK_fst_dualNumberEquiv /-
@[simp]
theorem imK_fst_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).fst.imK = q.imK.fst :=
  rfl
#align quaternion.im_k_fst_dual_number_equiv Quaternion.imK_fst_dualNumberEquiv
-/

#print Quaternion.re_snd_dualNumberEquiv /-
@[simp]
theorem re_snd_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).snd.re = q.re.snd :=
  rfl
#align quaternion.re_snd_dual_number_equiv Quaternion.re_snd_dualNumberEquiv
-/

#print Quaternion.imI_snd_dualNumberEquiv /-
@[simp]
theorem imI_snd_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).snd.imI = q.imI.snd :=
  rfl
#align quaternion.im_i_snd_dual_number_equiv Quaternion.imI_snd_dualNumberEquiv
-/

#print Quaternion.imJ_snd_dualNumberEquiv /-
@[simp]
theorem imJ_snd_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).snd.imJ = q.imJ.snd :=
  rfl
#align quaternion.im_j_snd_dual_number_equiv Quaternion.imJ_snd_dualNumberEquiv
-/

#print Quaternion.imK_snd_dualNumberEquiv /-
@[simp]
theorem imK_snd_dualNumberEquiv (q : Quaternion (DualNumber R)) :
    (dualNumberEquiv q).snd.imK = q.imK.snd :=
  rfl
#align quaternion.im_k_snd_dual_number_equiv Quaternion.imK_snd_dualNumberEquiv
-/

#print Quaternion.fst_re_dualNumberEquiv_symm /-
@[simp]
theorem fst_re_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).re.fst = d.fst.re :=
  rfl
#align quaternion.fst_re_dual_number_equiv_symm Quaternion.fst_re_dualNumberEquiv_symm
-/

#print Quaternion.fst_imI_dualNumberEquiv_symm /-
@[simp]
theorem fst_imI_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).imI.fst = d.fst.imI :=
  rfl
#align quaternion.fst_im_i_dual_number_equiv_symm Quaternion.fst_imI_dualNumberEquiv_symm
-/

#print Quaternion.fst_imJ_dualNumberEquiv_symm /-
@[simp]
theorem fst_imJ_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).imJ.fst = d.fst.imJ :=
  rfl
#align quaternion.fst_im_j_dual_number_equiv_symm Quaternion.fst_imJ_dualNumberEquiv_symm
-/

#print Quaternion.fst_imK_dualNumberEquiv_symm /-
@[simp]
theorem fst_imK_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).imK.fst = d.fst.imK :=
  rfl
#align quaternion.fst_im_k_dual_number_equiv_symm Quaternion.fst_imK_dualNumberEquiv_symm
-/

#print Quaternion.snd_re_dualNumberEquiv_symm /-
@[simp]
theorem snd_re_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).re.snd = d.snd.re :=
  rfl
#align quaternion.snd_re_dual_number_equiv_symm Quaternion.snd_re_dualNumberEquiv_symm
-/

#print Quaternion.snd_imI_dualNumberEquiv_symm /-
@[simp]
theorem snd_imI_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).imI.snd = d.snd.imI :=
  rfl
#align quaternion.snd_im_i_dual_number_equiv_symm Quaternion.snd_imI_dualNumberEquiv_symm
-/

#print Quaternion.snd_imJ_dualNumberEquiv_symm /-
@[simp]
theorem snd_imJ_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).imJ.snd = d.snd.imJ :=
  rfl
#align quaternion.snd_im_j_dual_number_equiv_symm Quaternion.snd_imJ_dualNumberEquiv_symm
-/

#print Quaternion.snd_imK_dualNumberEquiv_symm /-
@[simp]
theorem snd_imK_dualNumberEquiv_symm (d : DualNumber (Quaternion R)) :
    (dualNumberEquiv.symm d).imK.snd = d.snd.imK :=
  rfl
#align quaternion.snd_im_k_dual_number_equiv_symm Quaternion.snd_imK_dualNumberEquiv_symm
-/

end Quaternion

