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
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardViews presentingCardViews: [CardView], whenAddNewCards cards: [Card])
    
    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didDistributeCardView cardView: CardView, forSingleCard card: Card)

    func cardViewsManager(_ cardViewsManager: CardViewsManagerUseCase, didGenerateAllCards: Bool)
}

class CardViewsManagerUseCase: NSObject, CardViewsManagerUseCaseProtocol {
    private enum CardImageSourceType {
        case fromAsset
        case fromURL
        
        static func getType<T: Card>(with card: T) -> Self {
            return card.imageNames.isEmpty ? .fromURL : .fromAsset
        }
    }
    
    private let MAX_PRESENTATION_CARDS = 3
    var presentingCardViews = [CardView]()
    private var cardViewsPool = [String: [CardView]]()
    
    private var cards = [any Card]()
    private lazy var presentingCards = [any Card]()
    private var popedCards = [any Card]()
    
    weak var _delegate: CardViewsManagerUseCaseDelegate?
    var delegate: CardViewsManagerUseCaseDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    init(delegate: CardViewsManagerUseCaseDelegate?=nil) {
        super.init()
        self.delegate = delegate
    }
    
    override var description: String {
        let cardViewsInfo = presentingCardViews.map { $0.uid }
        return "cardViewsInfo: \(cardViewsInfo)"
    }
}

// MARK: - Internal Methods
extension CardViewsManagerUseCase {
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
        distributeCardViews()
        delegate?.cardViewsManager(self, didDistributeCardViews: presentingCardViews, whenAddNewCards: cards)
    }
    
    func popCardView() {
        let isGeneratedAllCards = !presentingCardViews.isEmpty && !presentingCards.isEmpty
        
        if !isGeneratedAllCards {
            let popedCardView = presentingCardViews.removeFirst()
            let popedCardViewTypeName = popedCardView.card!.cardViewTypeName
            cardViewsPool[popedCardViewTypeName]!.append(popedCardView)
            popedCardView.reset()
            let popedCard = presentingCards.removeFirst()
            popedCards.append(popedCard)
            distributeCardViews()
        } else {
            delegate?.cardViewsManager(self, didGenerateAllCards: true)
        }
    }
}

// MARK: - Helpers

private extension CardViewsManagerUseCase {
    func initCardViewsPool(with cards: [Card]) {
        var cardViewTypeIDs = Set<String>()
        cards.forEach {
            cardViewTypeIDs.insert($0.cardViewTypeName)
        }
        
        for cardViewTypeID in cardViewTypeIDs {
            cardViewsPool[cardViewTypeID] = (0...2).map { CardViewTypeManager.type(ofCardViewID: cardViewTypeID)!.init(uid: "\($0)") }
        }
    }
    
    func distributeCardViews() {
        let isGeneratedAllCards = cards.isEmpty
        if isGeneratedAllCards {
            delegate?.cardViewsManager(self, didGenerateAllCards: true)
        }
        
        while !cards.isEmpty && presentingCardViews.count < MAX_PRESENTATION_CARDS {
            let targetCard = cards.removeFirst()
            let targetCardViewType = targetCard.cardViewTypeName
            let targetCardView = cardViewsPool[targetCardViewType]!.removeFirst()
            
            setupCardView(with: targetCard, on: targetCardView)
            presentingCardViews.append(targetCardView)
            presentingCards.append(targetCard)
            delegate?.cardViewsManager(self, didDistributeCardView: targetCardView, forSingleCard: targetCard)
        }
    }
    
    func setupCardView(with card: Card, on cardView: CardView) {
        switch CardImageSourceType.getType(with: card) {
        case .fromAsset:
            cardView.setupImageNamesCard(with: card)
        case .fromURL:
            cardView.setupImageURLsCard(with: card)
        }
    }
}
