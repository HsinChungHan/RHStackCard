//
//  SlidingAnimationController.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/22.
//

import UIKit

protocol SlidingAnimationControllerDataSource: AnyObject {
    var cardView: CardView { get }
}

protocol SlidingAnimationControllerDelegate: AnyObject {
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, didSlideChanged direction: SlidingDirection, withTransaltion translation: CGPoint)
        
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, willPerformCardViewAction direction: SlidingDirection)
    
    func slidingAnimationController(_ slidingAnimationController: SlidingAnimationController, didFinishSwipeAwayAnimation: Bool)
}

class SlidingAnimationController {
    private var cardView: CardView {
        guard let dataSource else { fatalError() }
        return dataSource.cardView
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
            guard let self else { return }
            self.cardView.removeFromSuperview()
            self.cardView.transform = .identity
            self.cardView.layer.removeAllAnimations()
            self.delegate?.slidingAnimationController(self, didFinishSwipeAwayAnimation: true)
            
            let slideEvent = ObservableEvents.CardViewEvents.SlidingEvent(status: .didPerformSlidingAction, translation: direction.swipeAwayTranslationValue)
            ObservableSlidingAnimation.shared.notify(with: slideEvent)
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
        translationAnimation.duration = 0.5
        translationAnimation.fillMode = .forwards
        translationAnimation.isRemovedOnCompletion = false
        translationAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        cardView.layer.add(translationAnimation, forKey: "translation")
    }
    
     func addRotationAnimation(angle: CGFloat) {
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = 0.5
        cardView.layer.add(rotationAnimation, forKey: "rotation")
    }
    
    func handleBegan(_ gesture: UIPanGestureRecognizer) {
        cardView.layer.removeAllAnimations()
    }
    
    func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degrees: CGFloat = translation.x / 20
        let angle: CGFloat = -degrees * .pi / 180
        let rotationTransformation = CGAffineTransform.init(rotationAngle: angle)
        cardView.transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
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
            performSwipAnimation(swipeAway: .toLeft, translation: direction.swipeAwayTranslationValue, angle: 15)
        case .toRight:
            performSwipAnimation(swipeAway: .toRight, translation: direction.swipeAwayTranslationValue, angle: -15)
        case .toTop:
            performSwipAnimation(swipeAway: .toTop, translation: direction.swipeAwayTranslationValue)
        case .backToIdentity:
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {[unowned self] in
                self.cardView.transform = .identity
            }
        }
        
        let slideEvent = ObservableEvents.CardViewEvents.SlidingEvent(status: .willPerformSlidingAction, translation: direction.swipeAwayTranslationValue)
        ObservableSlidingAnimation.shared.notify(with: slideEvent)
    }
}
