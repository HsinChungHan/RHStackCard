//
//  Card.swift
//
//
//  Created by Chung Han Hsin on 2024/3/28.
//

import Foundation

public struct Card: Equatable {
    public let uid: String
    public var imageNames: [String] = []
    public var imageURLs: [URL] = []
    public init(uid: String, imageNames: [String], imageURLs: [URL]) {
        self.uid = uid
        self.imageNames = imageNames
        self.imageURLs = imageURLs
    }
    
    static public func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uid == rhs.uid
    }
}
