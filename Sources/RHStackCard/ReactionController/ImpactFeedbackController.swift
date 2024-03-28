//
//  ImpactFeedbackController.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

class ImpactFeedbackController {
    static func startImpactFeedback(with style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactGenerator = UIImpactFeedbackGenerator(style: style)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    }
}
