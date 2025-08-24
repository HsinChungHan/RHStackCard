//
//  CardViewPoolService.swift
//
//
//  Created by Chung Han Hsin on 2025/8/24.
//

import Foundation

class CardViewPoolService {
    var cardViewPool = [String: [CardView]]()
    var presentingCardViews = [CardView]()
    
    func initCardViewsPool(with cards: [Card]) {
        var cardViewTypeIDs = Set<String>()
        cards.forEach { cardViewTypeIDs.insert($0.cardViewTypeName) }
        cardViewTypeIDs.map { typeID in
            cardViewPool[typeID] = (0...2).map { CardViewType.type(ofCardViewID: typeID)!.init(uid: "\($0)") }
        }
    }
    
    // if the card is swiped away, we need to recycle it
    func enqueCardView() {
        let cardView = presentingCardViews.removeFirst()
        let cardViewType = cardView.card!.cardViewTypeName
        cardViewPool[cardViewType]!.append(cardView)
        cardView.reset()
    }
    
    // if the card is gonna show in the card stacks on the screen, we need to asign a CardView for this card
    func dequeCardView(with viewTypeID: String) -> CardView {
        let cardView = cardViewPool[viewTypeID]!.removeFirst()
        presentingCardViews.append(cardView)
        return cardView
        
    }
}
