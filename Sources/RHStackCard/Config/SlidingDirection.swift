//
//  SlidingAction.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/28.
//

import Foundation
public enum SlidingDirection {
    case toLeft
    case toRight
    case toTop
    case backToIdentity
    case none
    
    enum Constant {
        enum Slide {
            static let xThrehold: CGFloat = 80
            static let yThrehold: CGFloat = 140 // superLike 需要的 threhold 比較大
        }
    }
    
    public static func getSwipeAwayDirection(with translation: CGPoint) -> Self {
        let translationXDirection = translation.x
        let translationYDirection = translation.y
        
        let shouldDismissedCard = abs(translationXDirection) > Constant.Slide.xThrehold || abs(translationYDirection) > Constant.Slide.yThrehold
        
        if shouldDismissedCard {
            return SlidingDirection.getSlideDirection(with: translation)
        }
        return .backToIdentity
    }
    
    public static func getSlideDirection(with translation: CGPoint) -> Self {
        let translationXDirection = translation.x
        let translationYDirection = translation.y
        if translationYDirection < -15  && abs(translationXDirection) < 100 { return .toTop }
        if translationXDirection > 15 { return .toRight }
        if translationXDirection < -15 { return .toLeft }
        return .backToIdentity
    }
    
    var swipeAwayTranslationValue: CGPoint {
        switch self {
        case .toRight:
            return .init(x: 700, y: 0)
        case .toTop:
            return .init(x: 0, y: -300)
        case .toLeft:
            return .init(x: -300, y: 0)
        case .backToIdentity, .none:
            return .init(x: 0, y: 0)
        }
    }
}
