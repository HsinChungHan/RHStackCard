//
//  SlidingAnimationController.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/22.
//

import UIKit

protocol SlidingAnimationControllerDataSource: AnyObject {
    var cardView: CardView? { get }
}

protocol SlidingAnimationControllerDelegate: AnyObject {
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, didSlideChanged direction: SlidingDirection, withTransaltion translation: CGPoint)
        
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, willPerformCardViewAction direction: SlidingDirection)
    
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, cardViewDidPerformSwipeActionAnimation direction: SlidingDirection)
}

class SlidingAnimationController {
    var cardView: CardView? {
        return dataSource?.cardView
    }
    
    private weak var dataSource: SlidingAnimationControllerDataSource?
    private weak var delegate: SlidingAnimationControllerDelegate?
    
    
    init(dataSource: SlidingAnimationControllerDataSource, delegate: SlidingAnimationControllerDelegate? = nil) {
        self.dataSource = dataSource
        self.delegate = delegate
    }
}

// MARK: - Pan gesture
fileprivate extension SlidingAnimationController {
    func performSwipAnimation(swipeAway direction: SlidingDirection, translation: CGPoint, angle: CGFloat = 0, completionHandler: (() -> Void)? = nil) {
        CATransaction.setCompletionBlock {[weak self] in
            guard let self, let cardView = self.cardView else { return }
            
            cardView.removeFromSuperview()
            cardView.transform = .identity
            cardView.layer.removeAllAnimations()
            self.delegate?.slidingAnimationController(self, cardViewDidPerformSwipeActionAnimation: direction)
            notifyDidPerformSlidingActionEvent()
        }
        addTranslationAnimation(swipeAway: direction, translation: translation)
        addRotationAnimation(angle: angle)
        CATransaction.commit()
    }
    
    func addTranslationAnimation(swipeAway direction: SlidingDirection, translation: CGPoint) {
        let keyPath = (direction == .toTop) ? "position.y" : "position.x"
        let translationAnimation = CABasicAnimation.init(keyPath: keyPath)
        let toValue = (direction == .toTop) ? Double(translation.y) : Double(translation.x)
        translationAnimation.toValue = toValue
        translationAnimation.duration = 0.25
        translationAnimation.fillMode = .forwards
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        cardView?.layer.add(translationAnimation, forKey: "translation")
    }
    
     func addRotationAnimation(angle: CGFloat) {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = 0.25
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
    }
    
    func handleBegan(_ gesture: UIPanGestureRecognizer) {
        cardView?.layer.removeAllAnimations()
    }
    
    func handleChanged(_ gesture: UIPanGestureRecognizer) {
//        print("x:\(cardView.frame.minX), y:\(cardView.frame.minY)")
        let translation = gesture.translation(in: nil)
        //convert degrees into radians
        let degrees: CGFloat = translation.x / 20
        let angle: CGFloat = -degrees * .pi / 180
        let rotationTransformation = CGAffineTransform.init(rotationAngle: angle)
        cardView?.transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
        delegate?.slidingAnimationController(self, didSlideChanged: .getSlideDirection(with: translation), withTransaltion: translation)
        
        let slideEvent = ObservableEvents.CardViewEvents.SlidingEvent(status: .sliding, translation: translation)
        ObservableSlidingAnimation.shared.notify(with: slideEvent)
    }
    
    func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationX = gesture.translation(in: nil).x
        let translationY = gesture.translation(in: nil).y
        let translation = CGPoint(x: translationX, y: translationY)
        let direction = SlidingDirection.getSwipeAwayDirection(with: translation)
        
        let slideEvent = ObservableEvents.CardViewEvents.SlidingEvent(status: .endSlide, translation: translation)
        ObservableSlidingAnimation.shared.notify(with: slideEvent)
        
        performCardViewActionAnimation(with: direction)
        delegate?.slidingAnimationController(self, willPerformCardViewAction: direction)
    }
}

// MARK: - Internal methods
extension SlidingAnimationController {
    func handlePan(gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            handleBegan(gesture)
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            return
        }
    }
    
    func performCardViewActionAnimation(with direction: SlidingDirection) {
        switch direction {
        case .toLeft:
            notifyWillPerformSlidingActionEvent(with: direction)
            performSwipAnimation(swipeAway: .toLeft, translation: direction.swipeAwayTranslationValue, angle: 15)
        case .toRight:
            notifyWillPerformSlidingActionEvent(with: direction)
            performSwipAnimation(swipeAway: .toRight, translation: direction.swipeAwayTranslationValue, angle: -15)
        case .toTop:
            notifyWillPerformSlidingActionEvent(with: direction)
            performSwipAnimation(swipeAway: .toTop, translation: direction.swipeAwayTranslationValue)
        case .backToIdentity:
            notifyBackToIdentity()
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseInOut) {
                self.cardView?.transform = .identity
            } completion: { _ in
                guard let cardView = self.cardView else { return }
                self.delegate?.slidingAnimationController(self, cardViewDidPerformSwipeActionAnimation: direction)
            }
        }
    }
    
    private func notifyBackToIdentity() {
        let event = ObservableEvents.CardViewEvents.SlidingEvent(status: .willDoBackToIdentity, translation: .init(x: 0, y: 0))
        ObservableSlidingAnimation.shared.notify(with: event)
    }
    
    private func notifyWillPerformSlidingActionEvent(with direction: SlidingDirection) {
        let event = ObservableEvents.CardViewEvents.SlidingEvent(status: .willDoSwipeAction, translation: direction.swipeAwayTranslationValue)
        ObservableSlidingAnimation.shared.notify(with: event)
    }
    
    private func notifyDidPerformSlidingActionEvent() {
        let event = ObservableEvents.CardViewEvents.SlidingEvent(status: .didDoSwipeAction, translation: .init(x: 0, y: 0))
        ObservableSlidingAnimation.shared.notify(with: event)
    }
}
