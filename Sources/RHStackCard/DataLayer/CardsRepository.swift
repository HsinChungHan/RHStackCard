//
//  CardsRepository.swift
//
//
//  Created by Chung Han Hsin on 2025/8/24.
//

import Foundation

class CardsRepository {
    var cards = [any Card]()
    var presentingCards = [any Card]()
    var popedCards = [any Card]()
    
    func addNewCards(with cards: [Card]) {
        self.cards += cards
    }
    
    @discardableResult
    func removeFirstCard() -> Card {
        let removedCard = cards.removeFirst()
        presentingCards.append(removedCard)
        return removedCard
    }
    
    @discardableResult
    func popPresentingCard() -> Card {
        let popedCard = presentingCards.removeFirst()
        popedCards.append(popedCard)
        return popedCard
    }
}
