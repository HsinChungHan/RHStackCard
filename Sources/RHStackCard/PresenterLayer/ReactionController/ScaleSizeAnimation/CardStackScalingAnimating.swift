//
//  CardStackScalingAnimating.swift
//
//
//  Created by Chung Han Hsin on 2025/8/23.
//

import Foundation
public protocol CardStackScalingAnimating: AnyObject {
    /// The card views currently being presented (index 0 = topmost).
    var presentingCardViews: [CardView] { get set }

    /// While panning the top card, drive the scaling of the next card.
    func paningCurrentPresentingCardView(withTranslation translation: CGPoint)

    /// Scale all waiting (index >= 1) cards down to the minimum size.
    func scaleWaitingCardViews()

    /// Restore the top card to normal (identity) scale.
    func scaleCurrentPresentCardView()

    /// Reset the transform of all cards to identity. Optionally animated.
    func resetAllScales(animated: Bool)
}
