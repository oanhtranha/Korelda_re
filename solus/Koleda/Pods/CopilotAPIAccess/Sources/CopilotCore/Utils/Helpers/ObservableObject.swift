//
//  ObservableObject.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol ObservableObject {
    associatedtype observer
    func add(observer: observer)
    func remove(observer: observer)
    func invoke(invocation: (observer?) -> ())
    var observers: WeakObservers<observer> { get set }
}

extension ObservableObject {
    func add(observer: observer) {
        observers.observers = observers.observers.filter { $0.value != nil && $0.value !== (observer as AnyObject) }
        observers.observers.append(WeakWrapper(value: observer as AnyObject))
    }
    func remove(observer: observer) {
        observers.observers = observers.observers.filter { $0.value != nil && $0.value !== (observer as AnyObject) }
    }
    func invoke(invocation: (observer?) -> ()) {
        observers.observers.forEach { invocation($0.value as? observer) }
    }
}

class WeakObservers<T>: ExpressibleByArrayLiteral {
    required init(arrayLiteral: T...) {
        for observer in arrayLiteral as [AnyObject] {
            observers.append(WeakWrapper(value: observer))
        }
    }
    fileprivate var observers = [WeakWrapper]()
}

extension WeakObservers: Collection {
    var startIndex: Int { return observers.startIndex }
    var endIndex: Int { return observers.endIndex }
    subscript(_ index: Int) -> T? {
        return observers[index].value as? T
    }
    func index(after idx: Int) -> Int {
        return observers.index(after: idx)
    }
}

private class WeakWrapper {
    weak var value: AnyObject?
    init(value: AnyObject) {
        self.value = value
    }
}
