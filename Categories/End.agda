open import Categories.Category

module Categories.End {o ℓ e o′ ℓ′ e′} {C : Category o ℓ e} {V : Category o′ ℓ′ e′} where

module C = Category C
module V = Category V
open import Categories.Bifunctor using (Bifunctor; Functor; module Functor)
open import Categories.DinaturalTransformation
open DinaturalTransformation using (α)
open import Categories.Functor.Constant
open import Level

record End-data (F : Bifunctor C.op C V) : Set (o ⊔ ℓ ⊔ e ⊔ o′ ⊔ ℓ′ ⊔ e′) where
  field
    E : V.Obj
    π : DinaturalTransformation {C = C} (Constant E) F
    

record End (F : Bifunctor C.op C V) : Set (o ⊔ ℓ ⊔ e ⊔ o′ ⊔ ℓ′ ⊔ e′) where
  field
    Data : End-data F

  open End-data Data

  IsUni : (Q : End-data F) → (u : End-data.E Q V.⇒ E) → Set _
  IsUni Q u = ∀ c → α π c V.∘ u V.≡ α (End-data.π Q) c

  field
    universal : (Q : End-data F) → End-data.E Q V.⇒ E

    .π[c]∘universal≡δ[c] : {Q : End-data F} → IsUni Q (universal Q)

    .universal-unique : {Q : End-data F} → ∀ u → IsUni Q u → u V.≡ universal Q

  open End-data Data public

open import Data.Product
open import Categories.Product
open import Categories.FunctorCategory
import Categories.NaturalTransformation as NT
open NT.NaturalTransformation using (η)

endF : ∀ {o ℓ e} {A : Category o ℓ e}(F : Functor A (Functors (Product C.op C) V)) 
        → (∀ a → End (Functor.F₀ F a)) → Functor A V
endF {A = A} F mke = record {
                   F₀ = λ a → End.E (mke a);
                   F₁ = λ {a b} → F₁ {a} {b} ;
                   identity = λ {a} → V.Equiv.sym (End.universal-unique (mke a) V.id (λ c → 
                     begin α (End.π (mke a)) c ∘ id                    ↓⟨ identityʳ ⟩ 
                           α (End.π (mke a)) c                         ↑⟨ identityˡ ⟩ 
                           id ∘ α (End.π (mke a)) c                    ↑⟨ F.identity ⟩∘⟨ Equiv.refl ⟩ 
                           η (F.F₁ A.id) (c , c) ∘ α (End.π (mke a)) c ∎)) ;
                   homomorphism = λ {X Y Z f g} → V.Equiv.sym (End.universal-unique (mke Z) _ (λ c → 
                       begin α (End.π (mke Z)) c ∘ F₁ g ∘ F₁ f 
                                   ↑⟨ assoc ⟩ 
                             (α (End.π (mke Z)) c ∘ F₁ g) ∘ F₁ f
                                   ↓⟨ End.π[c]∘universal≡δ[c] (mke Z) {record {π = F.F₁ g <∘ End.π (mke Y)}} c ⟩∘⟨ Equiv.refl ⟩ 
                             (η (F.F₁ g) (c , c) ∘ α (End.π (mke Y)) c) ∘ F₁ f 
                                   ↓⟨ assoc ⟩ 
                             η (F.F₁ g) (c , c) ∘ α (End.π (mke Y)) c ∘ F₁ f
                                   ↓⟨ Equiv.refl ⟩∘⟨ End.π[c]∘universal≡δ[c] (mke Y) {record {π = F.F₁ f <∘ End.π (mke X)}} c ⟩ 
                             η (F.F₁ g) (c , c) ∘ η (F.F₁ f) (c , c) ∘ α (End.π (mke X)) c 
                                   ↑⟨ assoc ⟩ 
                             η (Functors (Product C.op C) V [ F.F₁ g ∘ F.F₁ f ]) (c , c) ∘ α (End.π (mke X)) c 
                                   ↑⟨ F.homomorphism ⟩∘⟨ Equiv.refl ⟩ 
                             η (F.F₁ (A [ g ∘ f ])) (c , c) ∘ α (End.π (mke X)) c 
                                                                                   ∎));
                   F-resp-≡ = λ {a b f g} f≡g → End.universal-unique (mke b) _ (λ c → 
                       begin α (End.π (mke b)) c ∘ F₁ f               ↓⟨ End.π[c]∘universal≡δ[c] (mke b) c ⟩ 
                             η (F.F₁ f) (c , c) ∘ α (End.π (mke a)) c ↓⟨ F.F-resp-≡ f≡g ⟩∘⟨ Equiv.refl ⟩ 
                             η (F.F₁ g) (c , c) ∘ α (End.π (mke a)) c ∎)} 
 where
  module A = Category A
  module F = Functor F
  open V
  open V.HomReasoning
  F₁ = λ {a b} f → End.universal (mke b) (record { E = _; π = (F.F₁ f) <∘ (End.π (mke a)) })
