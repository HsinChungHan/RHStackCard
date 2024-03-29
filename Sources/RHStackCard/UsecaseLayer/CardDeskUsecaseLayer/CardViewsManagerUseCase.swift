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
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, withAddedCards cards: [Card], presentingCardViews: [CardView])
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardView: Bool, cardView: CardView, card: Card)

    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didGenerateAllCards: Bool)
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didPopPresentingCardView: Bool, presentingCardViews: [CardView])
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didChangePresentingCardViews cardViews: [CardView])
}

class CardViewsManagerUseCase: NSObject, CardViewsManagerUseCaseProtocol {
    enum CardImageSourceType {
        case fromAsset
        case fromURL
        
        static func getType<T: Card>(with card: T) -> Self {
            return card.imageNames.isEmpty ? .fromURL : .fromAsset
        }
    }
    
    let MAX_PRESENTATION_CARDS = 3
    var presentingCardViews = [CardView]() {
        didSet {
            delegate?.cardViewsManager(self, didChangePresentingCardViews: presentingCardViews)
        }
    }
    var waitingToPresentCardViews: [CardView] {
        (1...presentingCardViews.count - 1).map { presentingCardViews[$0] }
    }
    var nextPresentingCardView: CardView? {
        presentingCardViews[1]
    }
    
    var cardViewsPool = [String: [CardView]]()
    
    var cards = [any Card]()
    lazy var presentingCards = [any Card]()
    var popedCards = [any Card]()
    
    weak var _delegate: CardViewsManagerUseCaseDelegate?
    var delegate: CardViewsManagerUseCaseDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    init(delegate: CardViewsManagerUseCaseDelegate?=nil) {
        super.init()
        self.delegate = delegate
    }
    
    func updateCardURLImages(with imageData: Data, at index: Int, for card: Card) {
        self.presentingCardViews.forEach {
            if $0.card?.uid == card.uid {
                $0.updateCardImage(with: imageData, at: index)
            }
        }
    }
    
    func addNewCards(with cards: [Card]) {
        initCardViewsPool(with: cards)
        self.cards += cards
        distributeCardView()
        delegate?.cardViewsManager(self, withAddedCards: cards, presentingCardViews: presentingCardViews)
    }
    
    private func initCardViewsPool(with cards: [Card]) {
        var cardViewTypeIDs = Set<String>()
        cards.forEach {
            cardViewTypeIDs.insert($0.cardViewTypeName)
        }
        
        for cardViewTypeID in cardViewTypeIDs {
            cardViewsPool[cardViewTypeID] = [
                CardViewTypeManager.type(ofCardViewID: cardViewTypeID)!.init(uid: "0"),
                CardViewTypeManager.type(ofCardViewID: cardViewTypeID)!.init(uid: "1"),
                CardViewTypeManager.type(ofCardViewID: cardViewTypeID)!.init(uid: "2"),
            ]
        }
    }
    
    private func distributeCardView() {
        while !cards.isEmpty && presentingCardViews.count < MAX_PRESENTATION_CARDS {
            let targetCard = cards.removeFirst()
            let targetCardViewType = targetCard.cardViewTypeName
            let targetCardView = cardViewsPool[targetCardViewType]!.removeFirst()
            
            setupCardView(with: targetCard, on: targetCardView)
            presentingCardViews.append(targetCardView)
            presentingCards.append(targetCard)
            delegate?.cardViewsManager(self, didDistributeCardView: true, cardView: targetCardView, card: targetCard)
        }
    }
    
    func popCardView() {
        let popedCardView = presentingCardViews.removeFirst()
        let popedCardViewTypeName = popedCardView.card!.cardViewTypeName
        cardViewsPool[popedCardViewTypeName]!.append(popedCardView)
        popedCardView.reset()
        let popedCard = presentingCards.removeFirst()
        popedCards.append(popedCard)
        if cards.isEmpty {
            delegate?.cardViewsManager(self, didGenerateAllCards: true)
            return
        }
        distributeCardView()
        delegate?.cardViewsManager(self, didPopPresentingCardView: true, presentingCardViews: presentingCardViews)
    }
    
    private func setupCardView(with card: Card, on cardView: CardView) {
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
