//
//  CardViewTypeManager.swift
//
//
//  Created by Chung Han Hsin on 2024/3/29.
//


struct CardViewTypeManager {
    private static var types: [String: CardView.Type] = [:]

    static func register<T: CardView>(type: T.Type) {
        let typeName = String(describing: type)
        types[typeName] = type
    }

    static func type(ofCardView cardView: CardView) -> CardView.Type? {
        let typeName = String(describing: Swift.type(of: cardView))
        return types[typeName]
    }
    
    static func type(ofTypeName typeName: String) -> CardView.Type? {
        return types[typeName]
    }
}
