{-# OPTIONS --universe-polymorphism #-}

module Categories.NaturalIsomorphism where

open import Level
open import Relation.Binary using (IsEquivalence)

open import Categories.Support.PropositionalEquality
open import Categories.Support.Equivalence
open import Categories.Category
open import Categories.Functor hiding (id; equiv) renaming (_∘_ to _∘F_; _≡_ to _≡F_)
open import Categories.NaturalTransformation.Core hiding (_≡_; equiv; setoid)
import Categories.Morphisms as Morphisms

record NaturalIsomorphism {o ℓ e o′ ℓ′ e′}
                          {C : Category o ℓ e}
                          {D : Category o′ ℓ′ e′}
                          (F G : Functor C D) : Set (o ⊔ ℓ ⊔ e ⊔ o′ ⊔ ℓ′ ⊔ e′) where
  private module C = Category C
  private module D = Category D
  private module F = Functor F
  private module G = Functor G
  open F
  open G renaming (F₀ to G₀; F₁ to G₁)

  field
    F⇒G : NaturalTransformation F G
    F⇐G : NaturalTransformation G F

  module ⇒ = NaturalTransformation F⇒G
  module ⇐ = NaturalTransformation F⇐G

  open Morphisms D

  field
    .iso : ∀ X → Iso (⇒.η X) (⇐.η X)

equiv : ∀ {o ℓ e o′ ℓ′ e′} {C : Category o ℓ e} {D : Category o′ ℓ′ e′} → IsEquivalence (NaturalIsomorphism {C = C} {D})
equiv {C = C} {D} = record 
  { refl = record
    { F⇒G = id
    ; F⇐G = id
    ; iso = λ _ → record 
      { isoˡ = D.identityˡ
      ; isoʳ = D.identityˡ
      }
    }
  ; sym = λ X → record
    { F⇒G = NaturalIsomorphism.F⇐G X
    ; F⇐G = NaturalIsomorphism.F⇒G X
    ; iso = λ Y → record 
      { isoˡ = Morphisms.Iso.isoʳ D (NaturalIsomorphism.iso X Y)
      ; isoʳ = Morphisms.Iso.isoˡ D (NaturalIsomorphism.iso X Y)
      }
    }
  ; trans = trans′
  }
  where
  module C = Category C
  module D = Category D
  open D hiding (id)

  trans′ : {x y z : Functor C D} → NaturalIsomorphism x y → NaturalIsomorphism y z → NaturalIsomorphism x z
  trans′ X Y = record 
    { F⇒G = F⇒G′
    ; F⇐G = F⇐G′
    ; iso = iso′
    }
    where
    F⇒G′ = NaturalIsomorphism.F⇒G Y ∘₁ NaturalIsomorphism.F⇒G X
    F⇐G′ = NaturalIsomorphism.F⇐G X ∘₁ NaturalIsomorphism.F⇐G Y

    .iso′ : (X : C.Obj) → _
    iso′ Z = record 
      { isoˡ = isoˡ′
      ; isoʳ = isoʳ′
      }
      where
      open NaturalIsomorphism
      open NaturalTransformation

      isoˡ′ : (η (F⇐G X) Z ∘ η (F⇐G Y) Z) ∘ (η (F⇒G Y) Z ∘ η (F⇒G X) Z) ≡ D.id
      isoˡ′ = begin
                (η (F⇐G X) Z ∘ η (F⇐G Y) Z) ∘ (η (F⇒G Y) Z ∘ η (F⇒G X) Z)
              ↓⟨ D.assoc ⟩
                η (F⇐G X) Z ∘ (η (F⇐G Y) Z ∘ (η (F⇒G Y) Z ∘ η (F⇒G X) Z))
              ↑⟨ D.∘-resp-≡ʳ D.assoc ⟩
                η (F⇐G X) Z ∘ ((η (F⇐G Y) Z ∘ η (F⇒G Y) Z) ∘ η (F⇒G X) Z)
              ↓⟨ D.∘-resp-≡ʳ (D.∘-resp-≡ˡ (Morphisms.Iso.isoˡ D (iso Y Z))) ⟩
                η (F⇐G X) Z ∘ (D.id ∘ η (F⇒G X) Z)
              ↓⟨ D.∘-resp-≡ʳ D.identityˡ ⟩
                η (F⇐G X) Z ∘ η (F⇒G X) Z
              ↓⟨ Morphisms.Iso.isoˡ D (iso X Z) ⟩
                D.id
              ∎
        where
        open D.HomReasoning

      isoʳ′ : (η (F⇒G Y) Z ∘ η (F⇒G X) Z) ∘ (η (F⇐G X) Z ∘ η (F⇐G Y) Z) ≡ D.id
      isoʳ′ = begin
                (η (F⇒G Y) Z ∘ η (F⇒G X) Z) ∘ (η (F⇐G X) Z ∘ η (F⇐G Y) Z)
              ↓⟨ D.assoc ⟩
                η (F⇒G Y) Z ∘ (η (F⇒G X) Z ∘ (η (F⇐G X) Z ∘ η (F⇐G Y) Z))
              ↑⟨ D.∘-resp-≡ʳ D.assoc ⟩
                η (F⇒G Y) Z ∘ ((η (F⇒G X) Z ∘ η (F⇐G X) Z) ∘ η (F⇐G Y) Z)
              ↓⟨ D.∘-resp-≡ʳ (D.∘-resp-≡ˡ (Morphisms.Iso.isoʳ D (iso X Z))) ⟩
                η (F⇒G Y) Z ∘ (D.id ∘ η (F⇐G Y) Z)
              ↓⟨ D.∘-resp-≡ʳ D.identityˡ ⟩
                η (F⇒G Y) Z ∘ η (F⇐G Y) Z
              ↓⟨ Morphisms.Iso.isoʳ D (iso Y Z) ⟩
                D.id
              ∎
        where
        open D.HomReasoning

setoid : ∀ {o ℓ e o′ ℓ′ e′} {C : Category o ℓ e} {D : Category o′ ℓ′ e′} → Setoid _ _
setoid {C = C} {D} = record 
  { Carrier = Functor C D
  ; _≈_ = NaturalIsomorphism
  ; isEquivalence = equiv {C = C} {D}
  }

≡→iso : ∀ {o ℓ e o′ ℓ′ e′} {C : Category o ℓ e} {D : Category o′ ℓ′ e′} (F G : Functor C D) → F ≡F G → NaturalIsomorphism F G
≡→iso {C = C} {D} F G F≡G =
  record
  { F⇒G = oneway F G F≡G
  ; F⇐G = oneway G F (my-sym F G F≡G)
  ; iso = λ X → record
    { isoˡ = my-iso G F (my-sym F G F≡G) F≡G X
    ; isoʳ = my-iso F G F≡G (my-sym F G F≡G) X
    }
  }
  where
  module C = Category C
  module D = Category D
  _©_ : ∀ {F G : Functor C D} → NaturalTransformation F G → (x : C.Obj) → D [ Functor.F₀ F x , Functor.F₀ G x ]
  _©_ = NaturalTransformation.η

  my-sym : (F G : Functor C D) → F ≡F G → G ≡F F
  my-sym _ _ F≡G X = Heterogeneous.sym D (F≡G X)

  oneway : (F G : Functor C D) → F ≡F G → NaturalTransformation F G
  oneway F G F≡G =
    record
    { η = my-η
    ; commute = my-commute
    }
    where
    module F = Functor F
    module G = Functor G
    open Heterogeneous D
    same-Objs : ∀ A → F.F₀ A ≣ G.F₀ A
    same-Objs A = helper (F≡G (C.id {A}))
      where
      helper : ∀ {A B} {f : D [ A , A ]} {g : D [ B , B ]} → f ∼ g → A ≣ B
      helper (Heterogeneous.≡⇒∼ _) = ≣-refl
    my-η : ∀ X → D [ F.F₀ X , G.F₀ X ]
    my-η X with F.F₀ X | G.F₀ X | same-Objs X
    my-η X | _ | ._ | ≣-refl = D.id
    my-commute : ∀ {X Y} (f : C [ X , Y ]) → D [ D [ my-η Y ∘ F.F₁ f ] ≡ D [ G.F₁ f ∘ my-η X ] ]
    my-commute {X} {Y} f with helper₃
      where
      helper₁ : D [ my-η Y ∘ F.F₁ f ] ∼ F.F₁ f 
      helper₁ with F.F₀ Y | G.F₀ Y | same-Objs Y | F.F₁ f
      helper₁ | _ | ._ | ≣-refl | f′ = ≡⇒∼ D.identityˡ
      helper₂ : G.F₁ f ∼ D [ G.F₁ f ∘ my-η X ]
      helper₂ with F.F₀ X | G.F₀ X | same-Objs X | G.F₁ f
      helper₂ | _ | ._ | ≣-refl | f′ = ≡⇒∼ (D.Equiv.sym D.identityʳ)
      helper₃ : D [ my-η Y ∘ F.F₁ f ] ∼ D [ G.F₁ f ∘ my-η X ]
      helper₃ = trans helper₁ (trans (F≡G f) helper₂)
    my-commute f | Heterogeneous.≡⇒∼ y = y

  open Heterogeneous D

  .my-iso : (F G : Functor C D) (F≡G : F ≡F G) (G≡F : G ≡F F) (x : C.Obj) → D [ D [ oneway F G F≡G © x ∘ oneway G F G≡F © x ] ≡ D.id ]
  my-iso F G F≡G G≡F x with F.F₀ x | G.F₀ x | F.F₁ k | G.F₁ k | F≡G k | G≡F k
    where
    k = C.id {x}
    module F = Functor F
    module G = Functor G
  my-iso F G F≡G G≡F x | _ | ._ | _ | _ | ≡⇒∼ _ | ≡⇒∼ _ = D.identityʳ