//
//  CardViewManager.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/24.
//

import Foundation

protocol CardViewsManagerUseCaseProtocol: AnyObject {
    func popCardView()
    func addNewCards(with cards: [Card])
    func updateCardURLImages(with imageData: Data, at index: Int, for card: Card)
    
    var delegate: CardViewsManagerUseCaseDelegate? { get set }
    var presentingCardViews: [CardView] { get set }
}

protocol CardViewsManagerUseCaseDelegate: AnyObject {
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, withAddedCards cards: [Card])
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardView: Bool, cardView: CardView, card: Card)
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didGenerateAllCards: Bool)
}

class CardViewsManagerUseCase: NSObject, CardViewsManagerUseCaseProtocol {
    enum CardImageSourceType {
        case fromAsset
        case fromURL
        
        static func getType(with card: Card) -> Self {
            return card.imageNames.isEmpty ? .fromURL : .fromAsset
        }
    }
    
    let MAX_PRESENTATION_CARDS = 3
    var presentingCardViews = [CardView]()
    var cardViewsPool: [CardView] = [
        .init(uid: "0"),
        .init(uid: "1"),
        .init(uid: "2")
    ]
    
    var cards = [Card]()
    lazy var presentingCards = [Card]()
    var cards = [BasicCard]()
    lazy var presentingCards = [BasicCard]()
    var popedCards = [BasicCard]()
    
    weak var _delegate: CardViewsManagerUseCaseDelegate?
    var delegate: CardViewsManagerUseCaseDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    init(delegate: CardViewsManagerUseCaseDelegate?=nil) {
        super.init()
        self.delegate = delegate
    }
    
    func popCardView() {
        let popedCardView = presentingCardViews.removeFirst()
        popedCardView.reset()
        cardViewsPool.append(popedCardView)
        let popedCard = presentingCards.removeFirst()
        popedCards.append(popedCard)
        if cards.isEmpty {
            delegate?.cardViewsManager(self, didGenerateAllCards: true)
            return
        }
        distributeCardView()
    }
    
    func updateCardURLImages(with imageData: Data, at index: Int, for card: Card) {
    func updateCardURLImages(with imageData: Data, at index: Int, for card: BasicCard) {
        self.presentingCardViews.forEach {
            if $0.card == card {
                $0.updateCardImage(with: imageData, at: index)
            }
        }
    }
    
    func addNewCards(with cards: [Card]) {
        addNewImageURLsCards(with: cards)
    }
    
    
    private func addNewImageNamesCards(with cards: [Card]) {
        self.cards += cards
        distributeCardView()
        delegate?.cardViewsManager(self, withAddedCards: cards)
    }
    
    private func addNewImageURLsCards(with cards: [Card]) {
        self.cards += cards
        distributeCardView()
        delegate?.cardViewsManager(self, withAddedCards: cards)
    }
    
    private func distributeCardView() {
        while !cards.isEmpty && presentingCardViews.count < MAX_PRESENTATION_CARDS {
            let targetCardView = cardViewsPool.removeFirst()
            let targetCard = cards.removeFirst()
            setupCardView(with: targetCard, on: targetCardView)
            presentingCardViews.append(targetCardView)
            presentingCards.append(targetCard)
            delegate?.cardViewsManager(self, didDistributeCardView: true, cardView: targetCardView, card: targetCard)
        }
    }
    
    private func setupCardView(with card: Card, on cardView: CardView) {
    private func setupCardView(with card: BasicCard, on cardView: CardView) {
        switch CardImageSourceType.getType(with: card) {
        case .fromAsset:
            cardView.setupImageNamesCard(with: card)
        case .fromURL:
            cardView.setupImageURLsCard(with: card)

        }
    }
    
    override var description: String {
        let cardViewsInfo = presentingCardViews.map { $0.uid }
        return "cardViewsInfo: \(cardViewsInfo)"
    }
}
