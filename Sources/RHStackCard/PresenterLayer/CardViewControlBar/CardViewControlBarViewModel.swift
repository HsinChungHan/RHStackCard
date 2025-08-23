//
//  CardViewControlBarViewModel.swift
//
//
//  Created by Chung Han Hsin on 2025/8/23.
//

import UIKit

public protocol CardViewControlBarViewModelDelegate: AnyObject {
    func controlBarVM(_ vm: CardViewControlBarViewModel, didUpdate state: CardViewControlBarViewModel.State)
    func controlBarVM(_ vm: CardViewControlBarViewModel, didSetControlsEnabled enabled: Bool)
}

public final class CardViewControlBarViewModel {

    public struct State {
        public var alpha: [CardViewAction: CGFloat]   // 0...1
        public var scale: [CardViewAction: CGFloat]   // 1...2(*1 to *2)

        public static let hidden: State = .init(
            alpha: [.nope: 0, .like: 0, .superLike: 0],
            scale: [.nope: 1, .like: 1, .superLike: 1]
        )
    }

    public weak var delegate: CardViewControlBarViewModelDelegate?

    public var controlsEnabled: Bool = true {
        didSet { delegate?.controlBarVM(self, didSetControlsEnabled: controlsEnabled) }
    }

    public func handle(slidingEvent: ObservableEvents.CardViewEvents.SlidingEvent) {
        guard let action = slidingEvent.action else {
            delegate?.controlBarVM(self, didUpdate: .hidden)
            return
        }

        // it's not sliding → reset
        if slidingEvent.status != .sliding {
            delegate?.controlBarVM(self, didUpdate: .hidden)
            return
        }

        let tx = slidingEvent.translation.x
        let ty = slidingEvent.translation.y

        // calculate alpha（0...1）and scale（1...2）
        func clamp(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat { max(lo, min(hi, v)) }
        var alpha: CGFloat = 0

        switch action {
        case .superLike:
            alpha = (-ty - abs(tx) * 1) / 100
        case .like:
            alpha = tx / 100
        case .nope:
            alpha = -tx / 100
        default:
            alpha = 0
        }
        alpha = clamp(alpha, 0, 1)
        let factor = clamp(1 + alpha, 1, 2)

        // reset
        var next = State.hidden
        switch action {
        case .superLike:
            next.alpha[.superLike] = alpha
            next.scale[.superLike] = factor
        case .like:
            next.alpha[.like] = alpha
            next.scale[.like] = factor
        case .nope:
            next.alpha[.nope] = alpha
            next.scale[.nope] = factor
        default:
            break
        }

        delegate?.controlBarVM(self, didUpdate: next)
    }

    public func resetVisual() {
        delegate?.controlBarVM(self, didUpdate: .hidden)
    }
}
