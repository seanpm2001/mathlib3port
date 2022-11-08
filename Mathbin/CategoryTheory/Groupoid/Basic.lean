/-
Copyright (c) 2022 Rémi Bottinelli. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Rémi Bottinelli
-/
import Mathbin.CategoryTheory.Groupoid
import Mathbin.CategoryTheory.IsConnected
import Mathbin.Combinatorics.Quiver.Basic

/-!
This file defines a few basic properties of groupoids.
-/


namespace CategoryTheory

namespace Groupoid

variable (C : Type _) [Groupoid C]

section Thin

theorem is_thin_iff : Quiver.IsThin C ↔ ∀ c : C, Subsingleton (c ⟶ c) := by
  refine' ⟨fun h c => h c c, fun h c d => Subsingleton.intro fun f g => _⟩
  haveI := h d
  calc
    f = f ≫ inv g ≫ g := by simp only [inv_eq_inv, is_iso.inv_hom_id, category.comp_id]
    _ = f ≫ inv f ≫ g := by congr
    _ = g := by simp only [inv_eq_inv, is_iso.hom_inv_id_assoc]
    

end Thin

section Disconnected

/-- A subgroupoid is totally disconnected if it only has loops. -/
def IsTotallyDisconnected :=
  ∀ c d : C, (c ⟶ d) → c = d

end Disconnected

end Groupoid

end CategoryTheory

