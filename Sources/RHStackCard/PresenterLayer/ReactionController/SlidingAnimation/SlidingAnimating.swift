//
//  SlidingAnimating.swift
//
//
//  Created by Chung Han Hsin on 2025/8/23.
//

import Foundation
/// Gesture phase independent of UIKit.
public enum SlidingPanPhase: Equatable {
    case began, changed, ended, cancelled, failed
}

/// Pan event payload passed into the animator.
public struct SlidingPanEvent: Equatable {
    public let phase: SlidingPanPhase
    public let translation: CGPoint
    public let velocity: CGPoint
    public init(phase: SlidingPanPhase, translation: CGPoint, velocity: CGPoint) {
        self.phase = phase
        self.translation = translation
        self.velocity = velocity
    }
}

public protocol SlidingAnimating: AnyObject {
    func handlePan(_ event: SlidingPanEvent)
    func performAction(_ direction: SlidingDirection)
}
