//
//  SessionNotifier.swift
//  CopilotAPIAccess
//
//  Created by Elad on 27/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

protocol Notifier {
    associatedtype observerType
    func registerObserver(observer:observerType)
    func unregisterObserver(observer:observerType)
}

class SessionNotifier {
    typealias observerType = SessionLifeTimeObserver
    private var delegates: [observerType]? = []
}

extension SessionNotifier: SessionLifeTimeObserver {
    func sessionStarted(_ userId: String?) { delegates?.forEach({ $0.sessionStarted(userId) }) }
    func sessionEnded() { delegates?.forEach({ $0.sessionEnded() }) }
}

extension SessionNotifier: Notifier {    
    func registerObserver(observer : observerType){ delegates?.append(observer) }
    func unregisterObserver(observer : observerType){ delegates = delegates?.filter({ $0 === observer }) }
}
