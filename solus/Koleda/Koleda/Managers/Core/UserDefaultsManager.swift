//
//  UserDefaultsManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/2/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import Foundation
import RxSwift

private enum ValueKeys: String {
    case biometricID = "touchID"
    case loggedIn = "login.loggedIn"
    case termAndConditionAcceptedUser = "termAndCondition.accepted.user"
    case lastKnownDeviceLocationCountryCode = "app.lastKnownDeviceLocationCountryCode"
    case wifiSsid = "app.wifiSsid"
    case wifiPass = "app.wifiPass"
}

class SettingsItem {
    fileprivate let key: String
    
    var exist: Bool {
        return UserDefaultsManager.restoreValue(key: key) != nil
    }
    
    fileprivate init(_ key: ValueKeys) {
        self.key = key.rawValue
    }
}

final class BoolSettingsItem: SettingsItem {
    
    static let defaultValue = false
    
    var enabled: Bool {
        get {
            guard let value = UserDefaultsManager.restoreValue(key: key) as? Bool else {
                return BoolSettingsItem.defaultValue
            }
            return value
        }
        set {
            UserDefaultsManager.storeValue(value: newValue, key: key)
        }
    }
    
    var asObservable: Observable<Bool> {
        return UserDefaultsManager.userDefaults
            .observeValue(forKey: key)
            .map { return ($0 as? Bool) ?? BoolSettingsItem.defaultValue }
    }
}

final class StringSettingsItem: SettingsItem {
    var value: String? {
        get {
            return UserDefaultsManager.restoreValue(key: key) as? String
        }
        set {
            UserDefaultsManager.storeValue(value: newValue, key: key)
        }
    }
}

final class UserDefaultsManager {
    
    // Store value to user defaults
    class func storeValue(value: Any?, key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    // Return stored value from user defaults
    class func restoreValue(key: String) -> Any? {
        return userDefaults.value(forKey: key)
    }
    
    static var userDefaultsOverride: UserDefaultsProtocol? = nil
    
    class var userDefaults: UserDefaultsProtocol {
        return userDefaultsOverride ?? UserDefaults.standard
    }
    
    private static func removeValue(key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    private static func removeValue(key: ValueKeys) {
        userDefaults.removeObject(forKey: key.rawValue)
        userDefaults.synchronize()
    }
    
    private static func removeValues(_ keys: ValueKeys...) {
        keys.forEach(removeValue)
    }
    
    static func removeUserValues() {
        removeValues(
            .biometricID,
            .loggedIn,
            .lastKnownDeviceLocationCountryCode
        )
    }
    
    static func synchronize() {
        self.userDefaults.synchronize()
    }
    
    static let biometricID = BoolSettingsItem(.biometricID)
    static let loggedIn = BoolSettingsItem(.loggedIn)
    static let termAndConditionAcceptedUser = StringSettingsItem(.termAndConditionAcceptedUser)
    static let lastKnownDeviceLocationCountryCode = StringSettingsItem(.lastKnownDeviceLocationCountryCode)
    static let wifiSsid = StringSettingsItem(.wifiSsid)
    static let wifiPass = StringSettingsItem(.wifiPass)
}
/*
 * Captures subset of UserDefaults interface that we use for mocking.
 */
protocol UserDefaultsProtocol : AnyObject {
    func removeObject(forKey defaultName: String)
    
    func value(forKey key: String) -> Any?
    func string(forKey defaultName: String) -> String?
    
    func set(_ value: Any?, forKey defaultName: String)
    
    /** Provides initial value for the underlying variable. */
    func observeValue(forKey key: String) -> Observable<Any?>
    
    @discardableResult
    func synchronize() -> Bool
}

extension UserDefaultsProtocol {
    
    func codable<T: Codable>(forKey key: String, type: T.Type) -> T? {
        guard let data = value(forKey: key) as? Data else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func setCodable<T: Codable>(_ value: T?, forKey key: String) {
        if let value = value {
            guard let data = try? JSONEncoder().encode(value) else {
                assertionFailure()
                return
            }
            set(data, forKey: key)
        } else {
            removeObject(forKey: key)
        }
        synchronize()
    }
    
    func codableObservable<T: Codable>(for key: String, type: T.Type) -> Observable<T?> {
        return observeValue(forKey: key).map { value in
            guard let data = value as? Data else { return nil }
            let result = try? JSONDecoder().decode(T.self, from: data)
            return result
        }
    }
}

extension UserDefaults : UserDefaultsProtocol {
    func observeValue(forKey key: String) -> Observable<Any?> {
        return rx.observe(Any.self, key, options: [.new, .initial])
    }
}
