//
//  SlidingAnimating.swift
//
//
//  Created by Chung Han Hsin on 2025/8/23.
//

import Foundation

/// Gesture phase independent of UIKit.
enum SlidingPanPhase: Equatable {
    case began, changed, ended, cancelled, failed
}

/// Pan event payload passed into the animator.
struct SlidingPanEvent: Equatable {
    let phase: SlidingPanPhase
    let translation: CGPoint
    let velocity: CGPoint
    init(phase: SlidingPanPhase, translation: CGPoint, velocity: CGPoint) {
        self.phase = phase
        self.translation = translation
        self.velocity = velocity
    }
}

protocol SlidingAnimating: AnyObject {
    func handlePan(_ event: SlidingPanEvent)
    func performAction(_ direction: SlidingDirection)
}
