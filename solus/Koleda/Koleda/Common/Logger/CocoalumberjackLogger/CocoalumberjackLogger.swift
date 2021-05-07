//
//  CocoalumberjackLogger.swift
//  Koleda
//
//  Created by Oanh tran on 7/3/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import CocoaLumberjack

typealias GenericAction = () -> Void

func performOnMain(_ action: @escaping GenericAction) {
    DispatchQueue.main.async {
        action()
    }
}

func isRunningTests() -> Bool {
    return NSClassFromString("XCTest") != nil
}


class CocoalumberjackLogger: Logger {
    
    enum LogDestination {
        case file(config: FileLogConfig)
        case crashlytics
        case asl
        case tty
        case os
    }
    
    struct FileLogConfig {
        let rollingFrequency: TimeInterval
        let maxNumOfLogFiles: UInt
        let maxFileSize: UInt64
    }
    
    static let defaultLogDestinations: [LogDestination] = {
        if #available(iOS 10.0, *) {
            return [.os, .crashlytics, .file(config: defaultFileLogConfig)]
        } else {
            return [.asl, .tty, .crashlytics, .file(config: defaultFileLogConfig)]
        }
    }()
    
    static let defaultLogLevel: LogLevel = {
        #if PRODUCTION
        return .info
        #else
        return .verbose
        #endif
    }()
    
    static let defaultFileLogConfig = FileLogConfig(rollingFrequency: TimeInterval(60 * 60 * 24),
                                                    maxNumOfLogFiles: 5,
                                                    maxFileSize: UInt64(2 * 1024 * 1024))
    
    var assertsEnabled = !isRunningTests()
    
    init(logDestinations: [LogDestination] = defaultLogDestinations, logLevel: LogLevel = defaultLogLevel) {
        logDestinations.forEach { enumeratedLogDestination in
            let ddLogLevel = cocoalumberjackLogLevel(for: logLevel)
            switch enumeratedLogDestination {
            case .file(let config):
                let fileLogger = DDFileLogger()
                fileLogger.rollingFrequency = config.rollingFrequency
                fileLogger.logFileManager.maximumNumberOfLogFiles = config.maxNumOfLogFiles
                fileLogger.maximumFileSize = config.maxFileSize
                DDLog.add(fileLogger, with: ddLogLevel)
            case .crashlytics:
                DDLog.add(DDOSLogger.sharedInstance, with: ddLogLevel)
            case .asl:
                DDLog.add(DDOSLogger.sharedInstance, with: ddLogLevel)
            case .tty:
                DDLog.add(DDTTYLogger.sharedInstance!, with: ddLogLevel)
            case .os:
                if #available(iOS 10.0, *) {
                    DDLog.add(DDOSLogger.sharedInstance, with: ddLogLevel)
                } else {
                    log.error("Trying to enable os logger for iOS earlier then 10.0")
                }
            }
        }
    }
    
    func verbose(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        DDLogVerbose(message, file: file, function: function, line: line)
    }
    
    func debug(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        DDLogDebug(message, file: file, function: function, line: line)
    }
    
    func info(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        DDLogInfo(message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        DDLogWarn(message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, _ file: StaticString, _ function: StaticString, _ line: UInt) {
        DDLogError(message, file: file, function: function, line: line)
    }
    
    func errorWithAssert(_ message: String,
                         _ assertId: String,
                         _ userInfo: [String: Any]?,
                         _ file: StaticString,
                         _ function: StaticString,
                         _ line: UInt)
    {
        error(message, file, function, line)
        DDLog.allLoggers.forEach { enumeratedLogger in
            if let assertRecordingLogger = enumeratedLogger as? AssertRecording {
                let fileLastPathComponent = (String(file) as NSString).lastPathComponent
                let errorInfo = [Constants.messageKey: message,
                                 Constants.fileKey: fileLastPathComponent,
                                 Constants.functionKey: function,
                                 Constants.lineKey: line] as [String: Any]
                let error = NSError(domain: "assert \(fileLastPathComponent) \(assertId)", code: 0, userInfo: errorInfo)
                
                assertRecordingLogger.recordAssertionFailure(error, additionalInfo: userInfo)
            }
        }
        assertionFailure(message)
    }
    
    func flushLog() {
        DDLog.flushLog()
    }
    
    private func cocoalumberjackLogLevel(for logLevel: LogLevel) -> DDLogLevel {
        switch logLevel {
        case .off: return DDLogLevel.off
        case .error: return DDLogLevel.error
        case .warning: return DDLogLevel.warning
        case .info: return DDLogLevel.info
        case .debug: return DDLogLevel.debug
        case .verbose: return DDLogLevel.verbose
        case .all: return DDLogLevel.all
        }
    }
}

extension CocoalumberjackLogger {
    struct Constants {
        static let messageKey = "_message"
        static let fileKey = "_file"
        static let functionKey = "_function"
        static let lineKey = "_line"
    }
}
