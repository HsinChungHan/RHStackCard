//
//  UIKitHapticsAdapter.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/23.
//

import UIKit

final class UIKitHapticsAdapter: HapticsPort {
    private var cache: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]  
}

// MARK: - Internal APIs
extension UIKitHapticsAdapter {
    func prepare(_ style: HapticStyle) {
        runOnMain { [weak self] in
            _ = self?.generator(for: style).prepare()
        }
    }

    
    func impact(_ style: HapticStyle, intensity: Float?) {
        runOnMain { [weak self] in
            guard let self else { return }
            let gen = self.generator(for: style)
            if let v = intensity {
                gen.impactOccurred(intensity: CGFloat(max(0, min(1, v))))
            } else {
                gen.impactOccurred()
            }
        }
    }
}

private extension UIKitHapticsAdapter {
    // MARK: - Mapping
    private func generator(for style: HapticStyle) -> UIImpactFeedbackGenerator {
        let ui = uiStyle(from: style)
        if let g = cache[ui] { return g }
        let g = UIImpactFeedbackGenerator(style: ui)
        cache[ui] = g
        return g
    }

    private func uiStyle(from style: HapticStyle) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch style {
        case .light:  return .light
        case .medium: return .medium
        case .heavy:  return .heavy
        case .rigid:  return .rigid
        case .soft:   return .soft
        }
    }
}

@inline(__always)
private func runOnMain(_ work: @escaping () -> Void) {
    if Thread.isMainThread { work() } else { DispatchQueue.main.async(execute: work) }
}
