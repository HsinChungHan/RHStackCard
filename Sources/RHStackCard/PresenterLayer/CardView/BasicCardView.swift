//
//  BasicCardView.swift
//
//
//  Created by Chung Han Hsin on 2024/3/29.
//

import Foundation
open class BasicCardView: CardView {
    open override func setupLayout() {
        super.setupLayout()
        uidLabel.removeFromSuperview()
    }
}
