//
//  CardViewsAnimationManagerUseCase.swift
//
//
//  Created by Chung Han Hsin on 2024/3/30.
//

import UIKit

class CardViewsAnimationManagerUseCase {
    
    var presentingCardViews = [CardView]()
    
    var waitingToPresentCardViews: [CardView] {
        if presentingCardViews.count >= 2 {
            return (1...presentingCardViews.count - 1).map { presentingCardViews[$0] }
        }
        return []
    }
    
    var nextPresentingCardView: CardView? {
        if presentingCardViews.count >= 2 {
            return presentingCardViews[1]
        }
        return nil
    }
    
    func paningCurrentPresentingCardView(withTranslation translation: CGPoint) {
        nextPresentingCardView?.scaleDuringPaning(withTranslation: translation)
    }
    
    func scaleWaitingCardViews() {
        waitingToPresentCardViews.forEach { $0.scaleToMinimumSize() }
    }
}
