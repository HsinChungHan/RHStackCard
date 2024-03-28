//
//  VibrationAnimationController.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

protocol VibrationAnimationControllerDataSource: AnyObject {
    var targetView: UIView { get }
}

protocol VibrationAnimationControllerDelegate: AnyObject {
    func vibrationAnimationController(_ vibrationAnimationController: VibrationAnimationController, didEndVibrationAnimation: Bool)
}

class VibrationAnimationController {
    let heavyGenerator = UIImpactFeedbackGenerator(style: .heavy)
    let mediumGenerator = UIImpactFeedbackGenerator(style: .medium)
    var tapAnimator: UIViewPropertyAnimator?
    
    private var targetView: UIView {
        guard let dataSource else { fatalError() }
        return dataSource.targetView
    }
    
    private weak var dataSource: VibrationAnimationControllerDataSource?
    private weak var delegate: VibrationAnimationControllerDelegate?
    
    init(dataSource: VibrationAnimationControllerDataSource, delegate: VibrationAnimationControllerDelegate?) {
        self.dataSource = dataSource
        self.delegate = delegate
    }
    
    private func startBriefVibration(view: UIView, angle: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: 0.4, curve: .linear)
        var transform = CATransform3DIdentity
        transform.m34 = -1/500
        let flipAngle: CGFloat = angle * (.pi / 180)
        // 創建轉向目標位置的轉換
        let rotatedTransform = CATransform3DRotate(transform, flipAngle, 0, 1, 0)
        
        animator.addAnimations {
            UIView.animateKeyframes(withDuration: 0.15, delay: 0, animations: {
                   UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.7) {
                       view.layer.transform = rotatedTransform
                   }
                   UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 0.3) {
                       view.layer.transform = CATransform3DIdentity
                   }
               })
        }
        
        animator.addCompletion { position in
            if position == .end {
                self.delegate?.vibrationAnimationController(self, didEndVibrationAnimation: true)
            }
        }
        animator.startAnimation()
        tapAnimator = animator
    }
}

// MARK: Internal Methods
extension VibrationAnimationController {
    func doBriefVibration(angle: CGFloat) {
        guard
            let tapAnimator,
            tapAnimator.isRunning
        else {
            startBriefVibration(view: targetView, angle: angle)
            return
        }
        tapAnimator.pauseAnimation()
        let timing = UICubicTimingParameters(animationCurve: .linear)
        tapAnimator.continueAnimation(withTimingParameters: timing, durationFactor: 0.15)
        tapAnimator.addCompletion{ _ in
            self.startBriefVibration(view: self.targetView, angle: angle)
        }
    }
}
