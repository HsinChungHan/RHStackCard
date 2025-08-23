//
//  ScaleAnimationController.swift
//
//
//  Created by Chung Han Hsin on 2024/3/29.
//

import UIKit

final class ScaleSizeAnimationController: CardStackScalingAnimating {
    /// Minimum scale applied to waiting cards and lower bound during panning.
    private let MINIMUM_SIZE_RATE: CGFloat = 0.95
    
    var presentingCardViews = [CardView]()
    
    // MARK: - Internal APIs
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

    func resetAllScales(animated: Bool) {
        let work = { [weak self] in
            guard let self else { return }
            for v in self.presentingCardViews {
                v.transform = .identity
            }
        }
        if animated {
            runOnMain { UIView.animate(withDuration: 0.15, animations: work) }
        } else {
            runOnMain(work)
        }
    }
}

// MARK: - Helpers
private extension ScaleSizeAnimationController {
    /// Apply a uniform scale transform to the given card view.
    func scale(_ cardView: CardView, to rate: CGFloat) {
        runOnMain {
            cardView.transform = CGAffineTransform(scaleX: rate, y: rate)
        }
    }

    /// Interpolate scale in [MINIMUM_SIZE_RATE, 1.0] based on pan distance.
    func scaleDuringPaning(_ cardView: CardView, with translation: CGPoint) {
        let distance = hypot(translation.x, translation.y)
        let raw = MINIMUM_SIZE_RATE + distance / 1000.0
        let rate = min(1.0, max(MINIMUM_SIZE_RATE, raw))
        scale(cardView, to: rate)
    }

    /// Scale a waiting card to the minimum size.
    func scaleToMinimumSize(_ cardView: CardView) {
        scale(cardView, to: MINIMUM_SIZE_RATE)
    }

    /// Animate the given card back to identity scale.
    func scaleToNormalSize(_ cardView: CardView) {
        runOnMain {
            UIView.animate(withDuration: 0.15) {
                cardView.transform = .identity
            }
        }
    }

    /// All cards except the top one (index 1 ... end). Empty if fewer than 2.
    private var waitingToPresentCardViews: [CardView] {
        if presentingCardViews.count >= 2 {
            return (1...presentingCardViews.count - 1).map { presentingCardViews[$0] }
        }
        return []
    }

    /// The next card that will be presented (index 1) if available.
    private var nextPresentingCardView: CardView? {
        if presentingCardViews.count >= 2 {
            return presentingCardViews[1]
        }
        return nil
    }
}

/// Execute work on the main thread (dispatch if needed).
@inline(__always)
private func runOnMain(_ work: @escaping () -> Void) {
    if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
}
