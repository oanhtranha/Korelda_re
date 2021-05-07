//
//  LocationSetupViewModel.swift
//  Koleda
//
//  Created by Oanh tran on 7/4/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import RxSwift

protocol LocationSetupViewModelProtocol: BaseViewModelProtocol {
    func declineLocationService()
    func requestAccessLocationService(completion: @escaping () -> Void)
    var showLocationDisabledPopUp: Variable<Bool> { get }
}
class LocationSetupViewModel: BaseViewModel, LocationSetupViewModelProtocol {
    
    let router: BaseRouterProtocol
    private let geoLocationManager: GeoLocationManager
    let showLocationDisabledPopUp = Variable<Bool>(false)
    
    init(router: BaseRouterProtocol, managerProvider: ManagerProvider = .sharedInstance ) {
        self.router =  router
        self.geoLocationManager = managerProvider.geoLocationManager
        super.init(managerProvider: managerProvider)
    }
    
    private func showNextScreen() {
        let userType = UserType.init(fromString: UserDataManager.shared.currentUser?.userType ?? "")
        if userType == .Master {
            router.enqueueRoute(with: LocationSetupRouter.RouteType.wifiSetup)
        } else {
            router.enqueueRoute(with: LocationSetupRouter.RouteType.welcomeJoinHome)
        }
    }
    
    func declineLocationService() {
        router.enqueueRoute(with: LocationSetupRouter.RouteType.decline)
    }
    
    func requestAccessLocationService(completion: @escaping () -> Void) {
        requestlocationService(completion: {
            completion()
        })
    }
    
    private func requestlocationService(completion: @escaping () -> Void) {
        geoLocationManager.requestAlwaysAuthorization {  [weak self] autorizationStatus in
            guard let `self` = self else {
                return
            }
            
            switch autorizationStatus {
            case .authorizedAlways:
                log.info("authorizedAlways")
                self.showNextScreen()
                completion()
            case .authorizedWhenInUse:
                log.info("authorizedWhenInUse")
                self.showNextScreen()
                completion()
            case .notDetermined:
                log.info("notDetermined")
                self.showLocationDisabledPopUp.value = true
                completion()
            case .restricted:
                log.info("restricted")
                self.showLocationDisabledPopUp.value = true
                completion()
            case .denied:
                self.showLocationDisabledPopUp.value = true
                log.info("denied")
                completion()
            }
        }
    }
    
//    private func getCurrentLocation(completion: @escaping () -> Void) {
//        geoLocationManager.currentGeoLocation { [weak self] currentGeoLocation in
//            let currentLocation = currentGeoLocation.dictionary
//            log.info(currentLocation.description)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                completion()
//                self?.showWifiScreen()
//            }
//        }
//    }
}
