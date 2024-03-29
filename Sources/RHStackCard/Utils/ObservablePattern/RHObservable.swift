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





