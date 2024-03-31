//
//  CardViewAction.swift
//  SlidingCard
// 
//  Created by Chung Han Hsin on 2024/3/22.
//


import RHUIComponent
import UIKit

public enum CardViewAction: CaseIterable {
    
    case rewind, nope, superLike, like, refresh
    
    var iconName: String {
        switch self {
        case .rewind: return "rewind"
        case .superLike: return "superLike"
        case .like: return "like"
        case .nope: return "nope"
        case .refresh: return "refresh"
        }
    }
    
    var title: String {
        switch self {
        case .superLike: return "Super\nLike"
        case .like: return "Like"
        case .nope: return "Nope"
        case .rewind: return "Rewind"
        case .refresh: return "Refresh"
        }
    }
    
    var color: UIColor {
        switch self {
        case .superLike: return Color.Yellow.v500
        case .like: return Color.Green.v500
        case .nope: return Color.Red.v500
        case .rewind: return Color.Blue.v500
        case .refresh: return Color.Neutral.v500
        }
    }
    
    static func getAction(by cardViewDirection: SlidingDirection) -> Self? {
        switch cardViewDirection {
        case .toLeft:
            return .nope
        case .toRight:
            return .like
        case .toTop:
            return .superLike
        default:
            return nil
        }
    }
    
    public var cardViewDirection: SlidingDirection {
        switch self {
        case .like:
            return .toRight
        case .nope:
            return .toLeft
        case .superLike:
            return .toTop
        case .refresh:
            return .none
        default:
            return .backToIdentity
        }
    }
}
