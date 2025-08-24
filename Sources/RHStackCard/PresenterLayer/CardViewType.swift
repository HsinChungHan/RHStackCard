//
//  CardViewTypeManager.swift
//
//
//  Created by Chung Han Hsin on 2024/3/29.
//


struct CardViewType {
    private static var types: [String: CardView.Type] = [:]

    static func register(withCardViewID cardViewID: String, cardViewType: CardView.Type) {
        types[cardViewID] = cardViewType
    }

//    static func type(ofCardView cardView: CardView) -> CardView.Type? {
//        let typeName = String(describing: Swift.type(of: cardView))
//        return types[typeName]
//    }
//    
//    static func type(ofTypeName typeName: String) -> CardView.Type? {
//        return types[typeName]
//    }
    
    static func type(ofCardViewID cardViewID: String) -> CardView.Type? {
        return types[cardViewID]
    }
}
