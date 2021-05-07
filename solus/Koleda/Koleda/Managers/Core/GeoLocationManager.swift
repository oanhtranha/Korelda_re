//
//  GeoLocationManager.swift
//  Koleda
//
//  Created by Oanh tran on 7/5/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import CoreLocation
import UIKit

struct GeoLocation {
    let deviceId: String
    let latitude: Double?
    let longitude: Double?
    let accuracy: Double?
    let bearing: Double?
    
    var dictionary: [String: Any] {
        var dictionary: [String: Any] = ["deviceId": deviceId]
        if let latitude = latitude {
            dictionary["latitude"] = String(describing: latitude)
        }
        if let longitude = longitude {
            dictionary["longitude"] = String(describing: longitude)
        }
        if let accuracy = accuracy {
            dictionary["accuracy"] = String(describing: accuracy)
        }
        if let bearing = bearing {
            dictionary["bearing"] = String(describing: bearing)
        }
        return dictionary
    }
}

struct Country {
    let name: String
    let isoCode: String
    let currencyCode: String
    
    init?(isoCode: String) {
        guard let name = Locale.app_currentOrDefault.localizedString(forRegionCode: isoCode), let currencyCode = Locale.currencyCode(forCountryIsoCode: isoCode) else {
                return nil
        }
        self.name = name
        self.currencyCode = currencyCode
        self.isoCode = isoCode
    }
}

class GeoLocationManager: NSObject, CLLocationManagerDelegate {
    
    typealias AutorizationCompletion = (CLAuthorizationStatus) -> Void
    typealias CLLocationCompletion = (WSResult<CLLocation>) -> Void
    typealias GeoLocationCompletion = (GeoLocation) -> Void
    
    private lazy var deviceIdentifier: String = {
        if let identifierForVendor = UIDevice.current.identifierForVendor?.uuidString {
            return identifierForVendor
        } else {
            log.error("Failed getting device id")
            return UUID().uuidString
        }
    }()
    private let startUpdatesLock = NSLock()
    private let locationManager: CLLocationManager
    private lazy var geocoder = { return CLGeocoder() }()
    
    private var autorizationCompletion: AutorizationCompletion?
    private var geoLocationCompletions = [CLLocationCompletion]()
    
    private var isUpdatingLocation = false
    
    var isGeoLocationEnabled: Bool {
        return CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse)
    }
    
    var isMonitoringGeoLocationEnabled: Bool {
        return CLLocationManager.locationServicesEnabled() &&
            (CLLocationManager.authorizationStatus() == .authorizedAlways ||
                CLLocationManager.authorizationStatus() == .authorizedWhenInUse) &&
            CLLocationManager.significantLocationChangeMonitoringAvailable()
    }
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestAlwaysAuthorization(completion: @escaping AutorizationCompletion) {
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.authorizationStatus() == .notDetermined {
            autorizationCompletion = completion
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        } else {
            DispatchQueue.main.async {
                completion(CLLocationManager.authorizationStatus())
            }
        }
    }
    
    func currentGeoLocation(completion: @escaping GeoLocationCompletion) {
        let deviceId = deviceIdentifier
        currentLocation { result in
            switch result {
            case .success(let location):
                let geoLocation = GeoLocation(deviceId: deviceId,
                                              latitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              accuracy: location.verticalAccuracy,
                                              bearing: location.course)
                completion(geoLocation)
            case  .failure(_):
                let geoLocation = GeoLocation(deviceId: deviceId,
                                              latitude: nil,
                                              longitude: nil,
                                              accuracy: nil,
                                              bearing: nil)
                completion(geoLocation)
                log.error("Geolocation obtaining failed")
            }
        }
    }
    
    // MARK: - Private methods
    
    private func storeLastKnownDeviceCountry(_ country: Country) {
        log.info("Last known device country updated")
        UserDefaultsManager.lastKnownDeviceLocationCountryCode.value = country.isoCode
    }
    
    private func currentLocation(completion: @escaping CLLocationCompletion) {
        guard isGeoLocationEnabled else {
            completion(WSResult.failure(WSError.locationServicesUnavailable))
            return
        }
        
        startUpdatesLock.lock()
        defer { startUpdatesLock.unlock() }
        
        geoLocationCompletions.append(completion)
        
        guard !isUpdatingLocation else { return }
        isUpdatingLocation = true
        
        locationManager.requestLocation()
    }
    
    private func finishUpdating(location: CLLocation?) {
        startUpdatesLock.lock()
        defer { startUpdatesLock.unlock() }
        
        isUpdatingLocation = false
        geoLocationCompletions.forEach { location != nil ? $0(WSResult.success(location!)) : $0(WSResult.failure(WSError.locationServicesUnavailable)) }
        geoLocationCompletions.removeAll()
        
        if let location = location {
            geocoder.reverseGeocodeLocation(location, completionHandler: { [weak self] placemarks, error in
                guard let currentPlacemark = placemarks?.first, let countryCode = currentPlacemark.isoCountryCode, let country = Country(isoCode: countryCode), let strongSelf = self else {
                    log.error("Reverse Geocoding error - \(error?.localizedDescription ?? "Parsing")")
                    return
                }
                strongSelf.storeLastKnownDeviceCountry(country)
            })
        } else {
            log.error("can't verify current location")
        }
    }
    
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            log.error("Failed retrieving geolocation")
            finishUpdating(location: nil)
            return
        }
        
        finishUpdating(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.error(error.localizedDescription)
        finishUpdating(location: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var allow: String? = nil
        switch status {
        case .restricted:
            allow = "restricted"
        case .denied:
            allow = "denied"
        case .authorizedAlways:
            allow = "authorized_always"
        case .authorizedWhenInUse:
            allow = "authorized_when_in_use"
        default:
            break
        }
        
        autorizationCompletion?(status)
        autorizationCompletion = nil
    }
}
