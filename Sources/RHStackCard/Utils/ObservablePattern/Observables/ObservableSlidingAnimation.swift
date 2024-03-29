//
//  ObservableSlidingAnimation.swift
//
//
//  Created by Chung Han Hsin on 2024/3/30.
//

import Foundation

public class ObservableSlidingAnimation: RHObservable {
    public static let shared = ObservableSlidingAnimation.init()
    public var observers: [WeakWrapper<RHObserver>] = []
    private init() {}
}
