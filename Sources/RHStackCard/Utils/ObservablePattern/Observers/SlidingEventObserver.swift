//
//  SlidingEventObserver.swift
//
//
//  Created by Chung Han Hsin on 2024/3/30.
//

import Foundation

public class SlidingEventObserver: RHObserver {
    public var didUpdateValue: ((ObservableEvents.CardViewEvents.SlidingEvent) -> Void)? = nil
    
    public func update(_ value: Any) {
        guard let value = value as? ObservableEvents.CardViewEvents.SlidingEvent else { return }
        didUpdateValue?(value)
    }
}
