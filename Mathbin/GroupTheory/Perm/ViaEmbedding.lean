/-
Copyright (c) 2015 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura, Mario Carneiro
-/
import Mathbin.GroupTheory.Perm.Basic
import Mathbin.Logic.Equiv.Set

/-!
# `equiv.perm.via_embedding`, a noncomputable analogue of `equiv.perm.via_fintype_embedding`.
-/


variable {α β : Type _}

namespace Equiv

namespace Perm

variable (e : Perm α) (ι : α ↪ β)

open Classical

/-- Noncomputable version of `equiv.perm.via_fintype_embedding` that does not assume `fintype` -/
noncomputable def viaEmbedding : Perm β :=
  extendDomain e (ofInjective ι.1 ι.2)
#align equiv.perm.via_embedding Equiv.Perm.viaEmbedding

theorem via_embedding_apply (x : α) : e.viaEmbedding ι (ι x) = ι (e x) :=
  extend_domain_apply_image e (ofInjective ι.1 ι.2) x
#align equiv.perm.via_embedding_apply Equiv.Perm.via_embedding_apply

theorem via_embedding_apply_of_not_mem (x : β) (hx : x ∉ Set.Range ι) : e.viaEmbedding ι x = x :=
  extend_domain_apply_not_subtype e (ofInjective ι.1 ι.2) hx
#align equiv.perm.via_embedding_apply_of_not_mem Equiv.Perm.via_embedding_apply_of_not_mem

/-- `via_embedding` as a group homomorphism -/
noncomputable def viaEmbeddingHom : Perm α →* Perm β :=
  extendDomainHom (ofInjective ι.1 ι.2)
#align equiv.perm.via_embedding_hom Equiv.Perm.viaEmbeddingHom

theorem via_embedding_hom_apply : viaEmbeddingHom ι e = viaEmbedding e ι :=
  rfl
#align equiv.perm.via_embedding_hom_apply Equiv.Perm.via_embedding_hom_apply

theorem via_embedding_hom_injective : Function.Injective (viaEmbeddingHom ι) :=
  extend_domain_hom_injective (ofInjective ι.1 ι.2)
#align equiv.perm.via_embedding_hom_injective Equiv.Perm.via_embedding_hom_injective

end Perm

end Equiv

