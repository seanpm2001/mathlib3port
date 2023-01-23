/-
Copyright (c) 2021 Eric Wieser. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Eric Wieser

! This file was ported from Lean 3 source module group_theory.subgroup.actions
! leanprover-community/mathlib commit 1f0096e6caa61e9c849ec2adbd227e960e9dff58
! Please do not edit these lines, except to modify the commit id
! if you have ported upstream changes.
-/
import Mathbin.GroupTheory.Subgroup.Basic

/-!
# Actions by `subgroup`s

These are just copies of the definitions about `submonoid` starting from `submonoid.mul_action`.

## Tags
subgroup, subgroups

-/


namespace Subgroup

variable {G : Type _} [Group G]

variable {α β : Type _}

/-- The action by a subgroup is the action by the underlying group. -/
@[to_additive "The additive action by an add_subgroup is the action by the underlying\nadd_group. "]
instance [MulAction G α] (S : Subgroup G) : MulAction S α :=
  S.toSubmonoid.MulAction

@[to_additive]
theorem smul_def [MulAction G α] {S : Subgroup G} (g : S) (m : α) : g • m = (g : G) • m :=
  rfl
#align subgroup.smul_def Subgroup.smul_def
#align add_subgroup.vadd_def AddSubgroup.vadd_def

@[to_additive]
instance sMulCommClass_left [MulAction G β] [SMul α β] [SMulCommClass G α β] (S : Subgroup G) :
    SMulCommClass S α β :=
  S.toSubmonoid.smul_comm_class_left
#align subgroup.smul_comm_class_left Subgroup.sMulCommClass_left
#align add_subgroup.vadd_comm_class_left AddSubgroup.vadd_comm_class_left

@[to_additive]
instance sMulCommClass_right [SMul α β] [MulAction G β] [SMulCommClass α G β] (S : Subgroup G) :
    SMulCommClass α S β :=
  S.toSubmonoid.smul_comm_class_right
#align subgroup.smul_comm_class_right Subgroup.sMulCommClass_right
#align add_subgroup.vadd_comm_class_right AddSubgroup.vadd_comm_class_right

/-- Note that this provides `is_scalar_tower S G G` which is needed by `smul_mul_assoc`. -/
instance [SMul α β] [MulAction G α] [MulAction G β] [IsScalarTower G α β] (S : Subgroup G) :
    IsScalarTower S α β :=
  S.toSubmonoid.IsScalarTower

instance [MulAction G α] [FaithfulSMul G α] (S : Subgroup G) : FaithfulSMul S α :=
  S.toSubmonoid.HasFaithfulSmul

/-- The action by a subgroup is the action by the underlying group. -/
instance [AddMonoid α] [DistribMulAction G α] (S : Subgroup G) : DistribMulAction S α :=
  S.toSubmonoid.DistribMulAction

/-- The action by a subgroup is the action by the underlying group. -/
instance [Monoid α] [MulDistribMulAction G α] (S : Subgroup G) : MulDistribMulAction S α :=
  S.toSubmonoid.MulDistribMulAction

/-- The center of a group acts commutatively on that group. -/
instance center.sMulCommClass_left : SMulCommClass (center G) G G :=
  Submonoid.center.smulCommClass_left
#align subgroup.center.smul_comm_class_left Subgroup.center.sMulCommClass_left

/-- The center of a group acts commutatively on that group. -/
instance center.sMulCommClass_right : SMulCommClass G (center G) G :=
  Submonoid.center.smulCommClass_right
#align subgroup.center.smul_comm_class_right Subgroup.center.sMulCommClass_right

end Subgroup

