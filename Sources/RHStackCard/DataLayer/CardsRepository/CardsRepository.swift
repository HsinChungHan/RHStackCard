//
//  CardsRepository.swift
//
//
//  Created by Chung Han Hsin on 2025/8/24.
//

import Foundation
protocol CardsRepositoryProtocol {
    var cards: [any Card] { get }
    var presentingCards: [any Card] { get }
    var popedCards: [any Card] { get }
    
    func addNewCards(with cards: [Card])
    func removeFirstCard() -> Card
    func popPresentingCard() -> Card
}


final class CardsRepository: CardsRepositoryProtocol {
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
