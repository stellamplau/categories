{-# OPTIONS --universe-polymorphism #-}
module Categories.Grothendieck where

open import Relation.Binary using (Rel)
open import Data.Product using (Σ; _,_; proj₂)

open import Categories.Support.PropositionalEquality
open import Categories.Support.IProduct
open import Categories.Category
open import Categories.Functor using (Functor; module Functor)
open import Categories.Agda

-- TODO: don't use sigmas
-- Break into modules Strict and Weak using Sets and Setoids?
Grothendieckᵉ : ∀ {o a o′} {C : Category o a} → Functor C (Sets o′) → EasyCategory _ _ _
Grothendieckᵉ {o′ = o′} {C = C} F = record 
  { Obj = Obj′
  ; _⇒_ = Hom′
  ; _≡_ = _≡′_
  ; _∘_ = _∘′_
  ; id = id , ≣-app identity _
  ; assoc = assoc
  ; identityˡ = identityˡ
  ; identityʳ = identityʳ
  ; promote = promote′
  ; REFL = refl
  }
  where
  open Category C
  open Equiv
  open Functor F

  Obj′ = Σ Obj F₀
  
  Hom′ : Rel Obj′ _
  Hom′ (c₁ , x₁) (c₂ , x₂) = Σ′ (c₁ ⇒ c₂) (λ f → F₁ f x₁ ≣ x₂)

  _≡′_ : ∀ {X Y} → Rel (Hom′ X Y) _
  (f , pf₁) ≡′ (g , pf₂) = f ≡ g

  _∘′_ : ∀ {X Y Z} → Hom′ Y Z → Hom′ X Y → Hom′ X Z
  _∘′_ {X} {Y} {Z} (f , pf₁) (g , pf₂) = (f ∘ g) , pf
    where
    -- This could be a lot prettier...
    .pf : F₁ (f ∘ g) (proj₂ X) ≣ proj₂ Z
    pf = ≣-trans (≣-app homomorphism _) (≣-sym (≣-trans (≣-sym pf₁) (≣-cong (F₁ f) (≣-sym pf₂))))

  promote′ : ∀ {X Y} (f g : Hom′ X Y) → f ≡′ g → f ≣ g
  promote′ (f , _) (.f , _) ≣-refl = ≣-refl

Grothendieck : ∀ {o a o′} {C : Category o a} → Functor C (Sets o′) → Category _ _
Grothendieck F = EASY Grothendieckᵉ F
