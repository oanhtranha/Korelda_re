//
//  SessionLifeTimeProvider.swift
//  CopilotAPIAccess
//
//  Created by Elad on 19/01/2020.
//  Copyright © 2020 Zemingo. All rights reserved.
//

import Foundation

class SessionLifeTimeProvider: ObservableObject {
    typealias observer = SessionLifeTimeObserver
    var observers = WeakObservers<SessionLifeTimeObserver>()
}
