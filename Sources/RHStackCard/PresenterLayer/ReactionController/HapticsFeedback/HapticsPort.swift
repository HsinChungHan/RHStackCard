//
//  HapticsPort.swift
//
//
//  Created by Chung Han Hsin on 2025/8/23.
//

import Foundation

enum HapticStyle {
    case light, medium, heavy, rigid, soft
}

protocol HapticsPort {
    func prepare(_ style: HapticStyle)
    func impact(_ style: HapticStyle, intensity: Float?)
}
