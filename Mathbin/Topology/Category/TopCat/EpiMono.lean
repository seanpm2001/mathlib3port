/-
Copyright (c) 2019 Reid Barton. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Reid Barton
-/
import Mathbin.Topology.Category.TopCat.Adjunctions

/-!
# Epi- and monomorphisms in `Top`

This file shows that a continuous function is an epimorphism in the category of topological spaces
if and only if it is surjective, and that a continuous function is a monomorphism in the category of
topological spaces if and only if it is injective.
-/


universe u

open CategoryTheory

open TopCat

namespace TopCat

theorem epi_iff_surjective {X Y : TopCat.{u}} (f : X ⟶ Y) : Epi f ↔ Function.Surjective f := by
  suffices epi f ↔ epi ((forget TopCat).map f) by
    rw [this, CategoryTheory.epi_iff_surjective]
    rfl
  constructor
  · intro
    infer_instance
    
  · apply functor.epi_of_epi_map
    
#align Top.epi_iff_surjective TopCat.epi_iff_surjective

theorem mono_iff_injective {X Y : TopCat.{u}} (f : X ⟶ Y) : Mono f ↔ Function.Injective f := by
  suffices mono f ↔ mono ((forget TopCat).map f) by
    rw [this, CategoryTheory.mono_iff_injective]
    rfl
  constructor
  · intro
    infer_instance
    
  · apply functor.mono_of_mono_map
    
#align Top.mono_iff_injective TopCat.mono_iff_injective

end TopCat

