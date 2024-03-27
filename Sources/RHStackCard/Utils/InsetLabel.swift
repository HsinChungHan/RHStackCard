//
//  InsetLabel.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/22.
//

import UIKit

class InsetLabel: UILabel {
    var textInsets: UIEdgeInsets
    
    init(textInsets: UIEdgeInsets) {
        self.textInsets = textInsets
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
   override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
       guard text != nil else {
           return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
       }
       
       let insetRect = bounds.inset(by: textInsets)
       let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
       let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                         left: -textInsets.left,
                                         bottom: -textInsets.bottom,
                                         right: -textInsets.right)
       return textRect.inset(by: invertedInsets)
   }
   
   override func drawText(in rect: CGRect) {
       super.drawText(in: rect.inset(by: textInsets))
   }
}


