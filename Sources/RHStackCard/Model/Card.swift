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
    
    static public func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uid == rhs.uid
    }
}
