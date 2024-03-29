//
//  ObservableEvents.swift
//
//
//  Created by Chung Han Hsin on 2024/3/30.
//

import Foundation
public struct ObservableEvents {
    public struct CardViewEvents {
        public enum Status {
            case sliding
            case endSlide
            case willPerformSlidingAction
            case didPerformSlidingAction
        }
        
        public struct SlidingEvent {
            public let status: CardViewEvents.Status
            public let translation: CGPoint
            public var direction: SlidingDirection {
                .getSlideDirection(with: translation)
            }
            public var action: CardViewAction? {
                .getAction(by: direction)
            }
        }
    }
    
    
}
