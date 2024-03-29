//
//  ScaleAnimationController.swift
//
//
//  Created by Chung Han Hsin on 2024/3/29.
//

import UIKit

protocol ScaleSizeAnimationControllerDataSource: AnyObject {
    var cardView: CardView { get }
}

class ScaleSizeAnimationController {
    private let MINIMUM_SIZE_RATE = 0.8
    
   
    private var _cardView: CardView {
        guard let cardView = dataSource?.cardView else { fatalError() }
        return cardView
    }
    
    private weak var dataSource: ScaleSizeAnimationControllerDataSource?
    init(dataSource: ScaleSizeAnimationControllerDataSource) {
        self.dataSource = dataSource
    }
    
    private func scale(to rate: Double) {
        self._cardView.transform = CGAffineTransform(scaleX: rate, y: rate)
    }
    
    func scaleDuringPaning(with translation: CGPoint) {
        let distance = sqrt(translation.x * translation.x + translation.y * translation.y)
        let rate = min(1.0, max(MINIMUM_SIZE_RATE, MINIMUM_SIZE_RATE + distance / 1000))
        scale(to: rate)
    }
    
    func scaleToMinimumSize() {
        scale(to: MINIMUM_SIZE_RATE)
    }
    
    func scaleToNormalSize() {
        scale(to: 1.0)
    }
}
