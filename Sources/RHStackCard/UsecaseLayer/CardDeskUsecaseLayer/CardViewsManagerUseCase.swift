//
//  CardViewManager.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/24.
//

import Foundation

protocol CardViewsManagerUseCaseProtocol: AnyObject {
    func popCardView()
    func addNewCards(with cards: [BasicCard])
    func updateCardURLImages(with imageData: Data, at index: Int, for card: BasicCard)
    
    var delegate: CardViewsManagerUseCaseDelegate? { get set }
    var presentingCardViews: [CardView] { get set }
}

protocol CardViewsManagerUseCaseDelegate: AnyObject {
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, withAddedCards cards: [BasicCard])
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardView: Bool, cardView: CardView, card: BasicCard)
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didGenerateAllCards: Bool)
}

class CardViewsManagerUseCase: NSObject, CardViewsManagerUseCaseProtocol {
    enum CardImageSourceType {
        case fromAsset
        case fromURL
        
        static func getType(with card: BasicCard) -> Self {
            return card.imageNames.isEmpty ? .fromURL : .fromAsset
        }
    }
    
    let MAX_PRESENTATION_CARDS = 3
    var presentingCardViews = [CardView]()
//    var cardViewsPool: [CardView] = [
//        .init(uid: "0"),
//        .init(uid: "1"),
//        .init(uid: "2")
//    ]
    
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
    
    func updateCardURLImages(with imageData: Data, at index: Int, for card: BasicCard) {
        self.presentingCardViews.forEach {
            if $0.card == card {
                $0.updateCardImage(with: imageData, at: index)
            }
        }
    }
    
    func addNewCards(with cards: [BasicCard]) {
        initCardViewsPool(with: cards)
        self.cards += cards
        distributeCardView()
        delegate?.cardViewsManager(self, withAddedCards: cards)
    }
    
    var myCardViewsPool = [CardViewType: [CardView]]()
    private func initCardViewsPool(with cards: [BasicCard]) {
        var cardViewTypes = Set<CardViewType>()
        cards.forEach {
            cardViewTypes.insert($0.cardViewType)
        }
        
        for cardViewType in cardViewTypes {
            myCardViewsPool[cardViewType] = [
                cardViewType.viewType.init(uid: "0"),
                cardViewType.viewType.init(uid: "1"),
                cardViewType.viewType.init(uid: "2"),
            ]
        }
    }
    
    private func distributeCardView() {
        while !cards.isEmpty && presentingCardViews.count < MAX_PRESENTATION_CARDS {
            let targetCard = cards.removeFirst()
            let targetCardViewType = targetCard.cardViewType
            let targetCardView = myCardViewsPool[targetCardViewType]!.removeFirst()
            
            setupCardView(with: targetCard, on: targetCardView)
            presentingCardViews.append(targetCardView)
            presentingCards.append(targetCard)
            delegate?.cardViewsManager(self, didDistributeCardView: true, cardView: targetCardView, card: targetCard)
        }
    }
    
    func popCardView() {
        let popedCardView = presentingCardViews.removeFirst()
        popedCardView.reset()
        let popedCardViewType = CardViewType.type(of: popedCardView)!
        myCardViewsPool[popedCardViewType]!.append(popedCardView)
//        cardViewsPool.append(popedCardView)
        let popedCard = presentingCards.removeFirst()
        popedCards.append(popedCard)
        if cards.isEmpty {
            delegate?.cardViewsManager(self, didGenerateAllCards: true)
            return
        }
        distributeCardView()
    }
    
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
