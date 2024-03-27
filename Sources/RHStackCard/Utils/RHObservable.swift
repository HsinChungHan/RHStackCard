//
//  Observable.swift
//  SlidingCard
//
//  Created by Chung Han Hsin on 2024/3/26.
//

import Foundation

class WeakWrapper<T> {
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

protocol RHObserver: AnyObject {
    func update(_ event: Any)
}

protocol RHObservable: AnyObject {
    var observers: [WeakWrapper<RHObserver>] { get set }
    func addObserver(_ observer: RHObserver)
    func removeObserver(_ observer: RHObserver)
    func notify(with event: Any)
}

// concrete observed class
extension RHObservable {
    func addObserver(_ observer: RHObserver) {
        cleanObservers()
        let weakObserver: WeakWrapper<RHObserver> = .init()
        weakObserver.value = observer
        observers.append(weakObserver)
    }
    
    func removeObserver(_ observer: RHObserver) {
        if let index = observers.firstIndex(where: { $0 === observer }) {
            observers.remove(at: index)
        }
    }
    
    func notify(with event: Any) {
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

class ObservableSlidingAnimation: RHObservable {
    static let shared = ObservableSlidingAnimation.init()
    var observers: [WeakWrapper<RHObserver>] = []
    private init() {}
}

struct ObservableEvents {
    struct CardViewEvents {
        enum Status {
            case sliding
            case endSlide
            case performSlidingAction
        }
        
        struct SlidingEvent {
            typealias CardViewDirection = SlidingDirection
            
            let status: CardViewEvents.Status
            let translation: CGPoint
            var direction: CardViewDirection {
                CardViewDirection.getSlideDirection(with: translation)
            }
            var action: CardViewAction? {
                CardViewAction.getAction(by: direction)
            }
        }
    }
}

class SlidingEventObserver: RHObserver {
    var didUpdateValue: ((ObservableEvents.CardViewEvents.SlidingEvent) -> Void)? = nil
    
    func update(_ value: Any) {
        guard let value = value as? ObservableEvents.CardViewEvents.SlidingEvent else { return }
        didUpdateValue?(value)
    }
}
