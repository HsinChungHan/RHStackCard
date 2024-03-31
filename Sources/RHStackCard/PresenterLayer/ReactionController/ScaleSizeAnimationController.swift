//
//  ScaleAnimationController.swift
//
//
//  Created by Chung Han Hsin on 2024/3/29.
//

import UIKit
class ScaleSizeAnimationController {
    var presentingCardViews = [CardView]()
    
    private let MINIMUM_SIZE_RATE = 0.95
    private var waitingToPresentCardViews: [CardView] {
        if presentingCardViews.count >= 2 {
            return (1...presentingCardViews.count - 1).map { presentingCardViews[$0] }
        }
        return []
    }
    
    private var nextPresentingCardView: CardView? {
        if presentingCardViews.count >= 2 {
            return presentingCardViews[1]
        }
        return nil
    }
}

// MARK: - Internal Methods
extension ScaleSizeAnimationController {
    func paningCurrentPresentingCardView(withTranslation translation: CGPoint) {
        guard let nextPresentingCardView else { return }
        scaleDuringPaning(nextPresentingCardView, with: translation)
    }
    
    func scaleWaitingCardViews() {
        waitingToPresentCardViews.forEach { scaleToMinimumSize($0) }
    }
    
    func scaleCurrentPresentCardView() {
        guard let currntPresentingCardView = presentingCardViews.first else { return }
        scaleToNormalSize(currntPresentingCardView)
    }
}

// MARK: - Helpers
private extension ScaleSizeAnimationController {
    func scale(_ cardView: CardView, to rate: Double) {
        cardView.transform = CGAffineTransform(scaleX: rate, y: rate)
    }
    
    func scaleDuringPaning(_ cardView: CardView, with translation: CGPoint) {
        let distance = sqrt(translation.x * translation.x + translation.y * translation.y)
        let rate = min(1.0, max(MINIMUM_SIZE_RATE, MINIMUM_SIZE_RATE + distance / 1000))
        scale(cardView, to: rate)
    }
    
    func scaleToMinimumSize(_ cardView: CardView) {
        scale(cardView, to: MINIMUM_SIZE_RATE)
    }
    
    func scaleToNormalSize(_ cardView: CardView) {
        UIView.animate(withDuration: 0.15) {
            self.scale(cardView, to: 1.0)
        }
    }
}
