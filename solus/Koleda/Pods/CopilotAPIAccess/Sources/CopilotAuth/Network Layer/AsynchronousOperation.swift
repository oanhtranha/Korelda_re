//
//  AsynchronousOperation.swift
//  CopilotAPIAccess
//
//  Created by Elad on 12/04/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class AsynchronousOperation : Operation {

    private let stateLock = NSLock()

    private var _executing: Bool = false
    override private(set) public var isExecuting: Bool {
        get {
            return stateLock.withCriticalScope { _executing }
        }
        set {
            willChangeValue(forKey: "isExecuting")
            stateLock.withCriticalScope { _executing = newValue }
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var _finished: Bool = false
    override private(set) public var isFinished: Bool {
        get {
            return stateLock.withCriticalScope { _finished }
        }
        set {
            willChangeValue(forKey: "isFinished")
            stateLock.withCriticalScope { _finished = newValue }
            didChangeValue(forKey: "isFinished")
        }
    }

    /// Complete the operation
    ///
    /// This will result in the appropriate KVN of isFinished and isExecuting

    public func completeOperation() {
        if isExecuting {
            isExecuting = false
        }

        if !isFinished {
            isFinished = true
        }
    }

    override public func start() {
        if isCancelled {
            isFinished = true
            return
        }

        isExecuting = true

        main()
    }

    override public func main() {
        fatalError("subclasses must override `main`")
    }
}

/*
 Abstract:
 An extension to `NSLocking` to simplify executing critical code.

 Adapted from Advanced NSOperations sample code in WWDC 2015 https://developer.apple.com/videos/play/wwdc2015/226/
 Adapted from https://developer.apple.com/sample-code/wwdc/2015/downloads/Advanced-NSOperations.zip
 */

import Foundation

extension NSLocking {

    /// Perform closure within lock.
    ///
    /// An extension to `NSLocking` to simplify executing critical code.
    ///
    /// - parameter block: The closure to be performed.

    func withCriticalScope<T>(block: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try block()
    }
}
