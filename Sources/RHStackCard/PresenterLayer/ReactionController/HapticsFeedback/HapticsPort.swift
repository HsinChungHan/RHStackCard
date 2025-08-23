//
//  HapticsPort.swift
//
//
//  Created by Chung Han Hsin on 2025/8/23.
//

import Foundation

public enum HapticStyle {
    case light, medium, heavy, rigid, soft
}

public protocol HapticsPort {
    func prepare(_ style: HapticStyle)
    func impact(_ style: HapticStyle, intensity: Float?)
}
