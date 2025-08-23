//
//  HightlightedButton.swift
//  Tinder
//
//  Created by Chung Han Hsin on 2023/6/7.
//

import UIKit

class HightlightedButton: UIButton {
    let hightlightedColor: UIColor
    let normalColor: UIColor
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? hightlightedColor : normalColor
            if isHighlighted {
                setSizeAnimation(scaleX: 2)
            } else {
                transform = .identity
            }
        }
    }
    
    init(normalColor: UIColor, hightlightedColor: UIColor) {
        self.normalColor = normalColor
        self.hightlightedColor = hightlightedColor
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSizeAnimation(scaleX: CGFloat, duration: TimeInterval = 0.1) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            let sizeTransformation = CGAffineTransform(scaleX: scaleX, y: scaleX)
            self.transform = sizeTransformation
        })
    }
    
    func setIdentityAnimation(duration: TimeInterval = 0.25, completion: @escaping () -> Void) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            self.transform = .identity
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(0)
        }, completion: { isFinished in
            if isFinished {
                completion()
            }
        })
    }
}
