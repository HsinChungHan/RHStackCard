//
//  CardViewManager.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/24.
//

import Foundation

protocol CardViewsManagerUseCaseProtocol: AnyObject {
    func popCardView(presentingCardViewsCount: Int)
    func addNewCards(with cards: [Card])
    
    var delegate: CardViewsManagerUseCaseDelegate? { get set }
    var presentingCards: [any Card] { get }
}

protocol CardViewsManagerUseCaseDelegate: AnyObject {
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, prepareDistributeCardViews cards: [Card])
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, prepareDistributeCardView card: Card)

    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didGenerateAllCards: Bool)
}

class CardViewsManagerUseCase: NSObject, CardViewsManagerUseCaseProtocol {
    
    
    // MARK: - CardsRepository
    private lazy var cardsRepo = CardsRepository()
    private var cards: [any Card] { cardsRepo.cards }
    var presentingCards: [any Card] { cardsRepo.presentingCards }
    private var popedCards: [any Card] { cardsRepo.popedCards }
    
    private let MAX_PRESENTATION_CARDS = 3
    
    weak var _delegate: CardViewsManagerUseCaseDelegate?
    var delegate: CardViewsManagerUseCaseDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    
    init(delegate: CardViewsManagerUseCaseDelegate?=nil) {
        super.init()
        self.delegate = delegate
    }
}

// MARK: - Internal Methods
extension CardViewsManagerUseCase {
    func addNewCards(with cards: [Card]) {
        cardsRepo.addNewCards(with: cards)
        delegate?.cardViewsManager(self, prepareDistributeCardViews: cards)
    }
    
    func popCardView(presentingCardViewsCount: Int) {
        cardsRepo.popPresentingCard()
        willUpdateCardRepo()
    }
}

// MARK: - Helpers
extension CardViewsManagerUseCase {
    func willUpdateCardRepo() {
        let isGeneratedAllCards = cards.isEmpty
        if isGeneratedAllCards {
            delegate?.cardViewsManager(self, didGenerateAllCards: true)
            return
        }
        
        while !cards.isEmpty && cardsRepo.presentingCards.count < MAX_PRESENTATION_CARDS {
            let card = cardsRepo.removeFirstCard()
            delegate?.cardViewsManager(self, prepareDistributeCardView: card)
        }
    }
}
