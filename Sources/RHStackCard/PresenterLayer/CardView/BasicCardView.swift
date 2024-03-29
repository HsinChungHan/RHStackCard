//
//  BasicCardView.swift
//
//
//  Created by Chung Han Hsin on 2024/3/29.
//

import Foundation
class BasicCardView: CardView {
    override func setupLayout() {
        super.setupLayout()
        uidLabel.removeFromSuperview()
    }
}
