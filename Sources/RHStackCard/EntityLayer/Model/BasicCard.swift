//
//  Card.swift
//
//
//  Created by Chung Han Hsin on 2024/3/28.
//

import Foundation
public protocol Card {
    var uid: String { get }
    var cardViewType: CardViewType { get }
    var imageNames: [String] { get }
    var imageURLs: [URL] { get }
}

public struct BasicCard: Card {
    public let cardViewType: CardViewType = .basicCardView
    public let uid: String
    public let imageNames: [String]
    public let imageURLs: [URL]
    public init(uid: String, imageNames: [String] = [], imageURLs: [URL] = []) {
        self.uid = uid
        self.imageNames = imageNames
        self.imageURLs = imageURLs
    }
}
