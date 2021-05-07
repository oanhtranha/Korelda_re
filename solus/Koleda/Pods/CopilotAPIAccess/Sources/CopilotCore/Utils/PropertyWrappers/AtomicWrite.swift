//
//  AtomicWrite.swift
//  ZemingoBLELayer
//
//  Created by Elad on 07/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

@propertyWrapper

struct AtomicWrite<Value> {
    
    let queue = DispatchQueue(label: "Atomic write access queue", attributes: .concurrent)
    var value: Value
        
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        
        set {
            queue.sync(flags: .barrier) { value = newValue }
        }
    }
    
    mutating func mutate(_ mutation: (inout Value) throws -> Void) rethrows {
        return try queue.sync(flags: .barrier) {
            try mutation(&value)
        }
    }
}
