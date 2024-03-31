//
//  Observable.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/26.
//

import Foundation

public class WeakWrapper<T> {
    private weak var _value: AnyObject?
    var value: T? {
        get {
            return _value as? T
        }
        set {
            _value = newValue as? AnyObject
        }
    }
}

public protocol RHObserver: AnyObject {
    func update(_ event: Any)
}

public protocol RHObservable: AnyObject {
    var observers: [WeakWrapper<RHObserver>] { get set }
    func addObserver(_ observer: RHObserver)
    func removeObserver(_ observer: RHObserver)
    func notify(with event: Any)
}

// concrete observed class
extension RHObservable {
    public func addObserver(_ observer: RHObserver) {
        cleanObservers()
        let weakObserver: WeakWrapper<RHObserver> = .init()
        weakObserver.value = observer
        observers.append(weakObserver)
    }
    
    public func removeObserver(_ observer: RHObserver) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    public func notify(with event: Any) {
        cleanObservers()
        observers.forEach {
            let observer = $0.value
            observer?.update(event)
        }
    }
    
    private func cleanObservers() {
        observers = observers.compactMap { $0 }
    }
}

public class ObservableSlidingAnimation: RHObservable {
    public static let shared = ObservableSlidingAnimation.init()
    public var observers: [WeakWrapper<RHObserver>] = []
    private init() {}
}

public struct ObservableEvents {
    public struct CardViewEvents {
        public enum Status {
            case sliding
            case endSlide
            case willDoSwipeAction
            case willDoBackToIdentity
            case didDoSwipeAction
        }
        
        public struct SlidingEvent {
            public let status: CardViewEvents.Status
            public let translation: CGPoint
            public var direction: SlidingDirection {
                .getSlideDirection(with: translation)
            }
            public var action: CardViewAction? {
                .getAction(by: direction)
            }
        }
    }
}

public class SlidingEventObserver: RHObserver {
    public var didUpdateValue: ((ObservableEvents.CardViewEvents.SlidingEvent) -> Void)? = nil
    
    public func update(_ value: Any) {
        guard let value = value as? ObservableEvents.CardViewEvents.SlidingEvent else { return }
        didUpdateValue?(value)
    }
}
