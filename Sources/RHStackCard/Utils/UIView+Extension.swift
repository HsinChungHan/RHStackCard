//
//  UIView+Extension.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

extension UIView {
    func rotate(degrees: CGFloat) {
        let radiansToRotate = degrees * (.pi / 180)
        transform = CGAffineTransform(rotationAngle: radiansToRotate)
    }
    
    static func findView<T: UIView>(ofType type: T.Type, in view: UIView) -> T? {
        for subview in view.subviews {
            if let subview = subview as? T {
                return subview
            } else if let foundView = findView(ofType: type, in: subview) {
                return foundView
            }
        }
        return nil
    }
    
    static func findTopMostSuperView(of view: UIView) -> UIView {
        var currentView = view
        while let superview = currentView.superview {
            currentView = superview
        }
        return currentView
    }
    
    static func findBottomMostSubview(of view: UIView) -> UIView? {
        return view.subviews.first
    }
}
