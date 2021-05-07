//
//  Logger.swift
//  Koleda
//
//  Created by Oanh tran on 7/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation

enum LogLevel {
    case off
    case error
    case warning
    case info
    case debug
    case verbose
    case all
}

protocol AssertRecording {
    func recordAssertionFailure(_ error: NSError, additionalInfo: [String: Any]?)
}

protocol Logger {
    var assertsEnabled: Bool { get set }
    
    func verbose(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt)
    func debug(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt)
    func info(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt)
    func warning(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt)
    func error(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt)
    
    /**
     Logs message with "error" log level and, if "assertsEnabled" property is true, throws assert.
     Also additional services can be used in this function to record assert (e.g. Crashlytics non-fatals)
     - parameter message: message for logging.
     - parameter assertId: id which should be unique within file. This id and filename can be used to group asserts.
     - parameter userInfo: optional key value data.
     - parameter file: file name.
     - parameter function: function name.
     - parameter line: line number.
     */
    func errorWithAssert(_ message: String,
                         _ assertId: String,
                         _ userInfo: [String: Any]?,
                         _ file: StaticString,
                         _ function: StaticString,
                         _ line: UInt)
    func flushLog()
}

extension Logger {
    func verbose(_ message: String,
                 _ file: StaticString = #file,
                 _ function: StaticString = #function,
                 _ line: UInt = #line)
    {
        verbose(message, file, function, line)
    }
    
    func debug(_ message: String,
               _ file: StaticString = #file,
               _ function: StaticString = #function,
               _ line: UInt = #line)
    {
        debug(message, file, function, line)
    }
    
    func info(_ message: String,
              _ file: StaticString = #file,
              _ function: StaticString = #function,
              _ line: UInt = #line)
    {
        info(message, file, function, line)
    }
    
    func warning(_ message: String,
                 _ file: StaticString = #file,
                 _ function: StaticString = #function,
                 _ line: UInt = #line)
    {
        warning(message, file, function, line)
    }
    
    func error(_ message: String,
               _ file: StaticString = #file,
               _ function: StaticString = #function,
               _ line: UInt = #line)
    {
        error(message, file, function, line)
    }
    
    func errorWithAssert(_ message: String,
                         _ assertId: String,
                         _ userInfo: [String: Any]? = nil,
                         _ file: StaticString = #file,
                         _ function: StaticString = #function,
                         _ line: UInt = #line)
    {
        if assertsEnabled {
            errorWithAssert(message, assertId, userInfo, file, function, line)
        } else{
            error(message, file, function, line)
        }
    }
}
