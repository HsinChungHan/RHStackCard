//
//  CardStackSchedulerUseCase.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/24.
//

import Foundation

protocol CardStackSchedulerUseCaseProtocol: AnyObject {
    func popCardView(presentingCardViewsCount: Int)
    func addNewCards(with cards: [Card])
    
    var presentingCards: [any Card] { get }
}

protocol CardStackSchedulerUseCaseDelegate: AnyObject {
    func cardStackSchedulerUseCase(_ cardStackSchedulerUseCase: CardStackSchedulerUseCase, prepareDistributeCardViews cards: [Card])
    func cardStackSchedulerUseCase(_ cardStackSchedulerUseCase: CardStackSchedulerUseCase, prepareDistributeCardView card: Card)
    func cardStackSchedulerUseCase(_ cardStackSchedulerUseCase: CardStackSchedulerUseCase, didGenerateAllCards: Bool)
}

class CardStackSchedulerUseCase: NSObject, CardStackSchedulerUseCaseProtocol {
    
    
    // MARK: - CardsRepository
    private lazy var cardsRepo = CardsRepository()
    private var cards: [any Card] { cardsRepo.cards }
    var presentingCards: [any Card] { cardsRepo.presentingCards }
    private var popedCards: [any Card] { cardsRepo.popedCards }
    
    private let MAX_PRESENTATION_CARDS = 3
    
    weak var delegate: CardStackSchedulerUseCaseDelegate?
    
    init(delegate: CardStackSchedulerUseCaseDelegate?=nil) {
        super.init()
        self.delegate = delegate
    }
}

// MARK: - Internal Methods
extension CardStackSchedulerUseCase {
    func addNewCards(with cards: [Card]) {
        cardsRepo.addNewCards(with: cards)
        delegate?.cardStackSchedulerUseCase(self, prepareDistributeCardViews: cards)
    }
    
    func popCardView(presentingCardViewsCount: Int) {
        cardsRepo.popPresentingCard()
        willUpdateCardRepo()
    }
}

// MARK: - Helpers
extension CardStackSchedulerUseCase {
    func willUpdateCardRepo() {
        let isGeneratedAllCards = cards.isEmpty
        if isGeneratedAllCards {
            delegate?.cardStackSchedulerUseCase(self, didGenerateAllCards: true)
            return
        }
        
        while !cards.isEmpty && cardsRepo.presentingCards.count < MAX_PRESENTATION_CARDS {
            let card = cardsRepo.removeFirstCard()
            delegate?.cardStackSchedulerUseCase(self, prepareDistributeCardView: card)
        }
    }
}
