//
//  Storyboards.swift
//  Koleda
//
//  Created by Oanh tran on 5/23/19.
//  Copyright © 2019 koleda. All rights reserved.
//

import Foundation
import UIKit

private final class BundleToken {}

protocol StoryboardSceneType {
    static var storyboardName: String { get }
}

extension UIViewController {
    func perform<S: StoryboardSegueType>(segue: S, sender: Any? = nil) where S.RawValue == String {
        performSegue(withIdentifier: segue.rawValue, sender: sender)
    }
}

extension StoryboardSceneType {
    static func storyboard() -> UIStoryboard {
        return UIStoryboard(name: self.storyboardName, bundle: Bundle(for: BundleToken.self))
    }
    
    static func initialViewController() -> UIViewController {
        guard let vc = storyboard().instantiateInitialViewController() else {
            fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
        }
        return vc
    }
}

extension StoryboardSceneType where Self: RawRepresentable, Self.RawValue == String {
    
    func viewController() -> UIViewController {
        return Self.storyboard().instantiateViewController(withIdentifier: self.rawValue)
    }
    static func viewController(identifier: Self) -> UIViewController {
        return identifier.viewController()
    }
}


// MARK - enum Storyboard
protocol StoryboardSegueType: RawRepresentable { }
enum StoryboardScene {
    enum LaunchScreen: StoryboardSceneType {
        static let storyboardName = "LaunchScreen"
    }
    
    enum Onboarding: String, StoryboardSceneType {
        static let storyboardName = "Onboarding"
        
        case navigationControllerScene = "NavigationController"
        static func instantiateNavigationController() -> UINavigationController {
            guard let vc = StoryboardScene.Onboarding.navigationControllerScene.viewController() as? UINavigationController
                else {
                    fatalError("ViewController 'NavigationController' is not of the expected class UINavigationController.")
            }
            return vc
        }
		
		case JoinHomeViewController = "JoinHomeViewController"
		static func instantiateJoinHomeViewController() -> UIViewController {
			guard let vc = StoryboardScene.Onboarding.JoinHomeViewController.viewController() as? JoinHomeViewController
				else {
					fatalError("ViewController 'JoinHomeViewController' is not of the expected class JoinHomeViewController.")
			}
			return vc
		}
        
        case WelcomeJoinHomeViewController = "WelcomeJoinHomeViewController"
        static func instantiateWelcomeJoinHomeViewController() -> UIViewController {
            guard let vc = StoryboardScene.Onboarding.WelcomeJoinHomeViewController.viewController() as? WelcomeJoinHomeViewController
                else {
                    fatalError("ViewController 'WelcomeJoinHomeViewController' is not of the expected class WelcomeJoinHomeViewController.")
            }
            return vc
        }
    }
    
    enum Login: StoryboardSceneType {
        static let storyboardName = "Login"
        static func initialNavigationViewController() -> UINavigationController {
            guard let vc = StoryboardScene.Onboarding.navigationControllerScene.viewController() as? UINavigationController
                else {
                    fatalError("ViewController 'NavigationController' is not of the expected class UINavigationController.")
            }
            return vc
        }
        static func initialViewController() -> UIViewController {
            guard let vc = storyboard().instantiateInitialViewController() as? LoginViewController else {
                fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
            }
            return vc
        }
    }
    
    enum Guide: StoryboardSceneType {
        static let storyboardName = "Guide"
        static func initialViewController() -> UIViewController {
            guard let vc = storyboard().instantiateInitialViewController() as? GuideViewController else {
                fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
            }
            return vc
        }
    }
    
    enum Setup: String, StoryboardSceneType {
        static let storyboardName = "Setup"
        static func initialViewController() -> UIViewController {
            guard let vc = storyboard().instantiateInitialViewController() as? SyncViewController else {
                fatalError("Failed to instantiate initialViewController for \(self.storyboardName)")
            }
            return vc
        }
        
        case TermAndConditionViewController = "TermAndConditionViewController"
        static func instantiateTermAndConditionViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.TermAndConditionViewController.viewController() as? TermAndConditionViewController
                else {
                    fatalError("ViewController 'TermAndConditionViewController' is not of the expected class TermAndConditionViewController.")
            }
            return vc
        }
        
        case LocationSetupViewController = "LocationSetupViewController"
        static func instantiateLocationSetupViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.LocationSetupViewController.viewController() as? LocationSetupViewController
                else {
                    fatalError("ViewController 'LocationSetupViewController' is not of the expected class LocationSetupViewController.")
            }
            return vc
        }
        
        case WifiSetupViewController = "WifiSetupViewController"
        static func instantiateWifiSetupViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.WifiSetupViewController.viewController() as? WifiSetupViewController
                else {
                    fatalError("ViewController 'WifiSetupViewController' is not of the expected class WifiSetupViewController.")
            }
            return vc
        }
        
        case WifiDetailViewController = "WifiDetailViewController"
        static func instantiateWifiDetailViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.WifiDetailViewController.viewController() as? WifiDetailViewController
                else {
                    fatalError("ViewController 'WifiDetailViewController' is not of the expected class WifiDetailViewController.")
            }
            return vc
        }
        
        case EnergyTariffViewController = "EnergyTariffViewController"
        static func instantiateEnergyTariffViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.EnergyTariffViewController.viewController() as? EnergyTariffViewController
                else {
                    fatalError("ViewController 'EnergyTariffViewController' is not of the expected class EnergyTariffViewController.")
            }
            return vc
        }
        
        case MenuSettingsViewController = "MenuSettingsViewController"
        static func instantiateMenuSettingsViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.MenuSettingsViewController.viewController() as? MenuSettingsViewController
                else {
                    fatalError("ViewController 'MenuSettingsViewController' is not of the expected class MenuSettingsViewController.")
            }
            return vc
        }
        
        case TemperatureUnitViewController = "TemperatureUnitViewController"
        static func instantiateTemperatureUnitViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.TemperatureUnitViewController.viewController() as? TemperatureUnitViewController
                else {
                    fatalError("ViewController 'TemperatureUnitViewController' is not of the expected class TemperatureUnitViewController.")
            }
            return vc
        }
        
        case ModifyModesViewController = "ModifyModesViewController"
        static func instantiateModifyModesViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.ModifyModesViewController.viewController() as? ModifyModesViewController
                else {
                    fatalError("ViewController 'ModifyModesViewController' is not of the expected class ModifyModesViewController.")
            }
            return vc
        }
        
        case DetailModeViewController = "DetailModeViewController"
        static func instantiateDetailModeViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.DetailModeViewController.viewController() as? DetailModeViewController
                else {
                    fatalError("ViewController 'DetailModeViewController' is not of the expected class DetailModeViewController.")
            }
            return vc
        }
        
		case InviteFriendsViewController = "InviteFriendsViewController"
		static func instantiateInviteFriendsViewController() -> UIViewController {
			guard let vc = StoryboardScene.Setup.InviteFriendsViewController.viewController() as? InviteFriendsViewController
				else {
					fatalError("ViewController 'InviteFriendsViewController' is not of the expected class InviteFriendsViewController.")
			}
			return vc
		}
		
		case InviteFriendsDetailViewController = "InviteFriendsDetailViewController"
		static func instantiateInviteFriendsDetailViewController() -> UIViewController {
			guard let vc = StoryboardScene.Setup.InviteFriendsDetailViewController.viewController() as? InviteFriendsDetailViewController
				else {
					fatalError("ViewController 'InviteFriendsDetailViewController' is not of the expected class InviteFriendsDetailViewController.")
			}
			return vc
		}
		
		case InviteFriendsFinishedViewController = "InviteFriendsFinishedViewController"
		static func instantiateInviteFriendsFinishedViewController() -> UIViewController {
			guard let vc = StoryboardScene.Setup.InviteFriendsFinishedViewController.viewController() as? InviteFriendsFinishedViewController
				else {
					fatalError("ViewController 'InviteFriendsFinishedViewController' is not of the expected class InviteFriendsFinishedViewController.")
			}
			return vc
		}
		
		case CreateHomeViewController = "CreateHomeViewController"
		static func instantiateCreateHomeViewController() -> UIViewController {
			guard let vc = StoryboardScene.Setup.CreateHomeViewController.viewController() as? CreateHomeViewController
				else {
					fatalError("ViewController 'CreateHomeViewController' is not of the expected class CreateHomeViewController.")
			}
			return vc
		}
        
        case LegalViewController = "LegalViewController"
        static func instantiateLegalViewController() -> UIViewController {
            guard let vc = StoryboardScene.Setup.LegalViewController.viewController() as? LegalViewController
            else {
                fatalError("ViewController 'LegalViewController' is not of the expected class LegalViewController.")
            }
            return vc
        }
    }
    
    enum SmartSchedule: String, StoryboardSceneType {
        static let storyboardName = "SmartSchedule"
        case SmartSchedulingViewController = "SmartSchedulingViewController"
        static func instantiateSmartSchedulingViewController() -> UIViewController {
            guard let vc = StoryboardScene.SmartSchedule.SmartSchedulingViewController.viewController() as? SmartSchedulingViewController
                else {
                    fatalError("ViewController 'SmartSchedulingViewController' is not of the expected class SmartSchedulingViewController.")
            }
            return vc
        }
        
        case ScheduleViewController = "ScheduleViewController"
        static func instantiateScheduleViewController() -> UIViewController {
            guard let vc = StoryboardScene.SmartSchedule.ScheduleViewController.viewController() as? ScheduleViewController
                else {
                    fatalError("ViewController 'ScheduleViewController' is not of the expected class ScheduleViewController.")
            }
            return vc
        }
        
        case TabContentViewController = "TabContentViewController"
        static func instantiateTabContentViewController() -> UIViewController {
            guard let vc = StoryboardScene.SmartSchedule.TabContentViewController.viewController() as? TabContentViewController
                else {
                    fatalError("ViewController 'TabContentViewController' is not of the expected class TabContentViewController.")
            }
            return vc
        }
        
        case SmartScheduleDetailViewController = "SmartScheduleDetailViewController"
        static func instantiateSmartScheduleDetailViewController() -> UIViewController {
            guard let vc = StoryboardScene.SmartSchedule.SmartScheduleDetailViewController.viewController() as? SmartScheduleDetailViewController
                else {
                    fatalError("ViewController 'SmartScheduleDetailViewController' is not of the expected class SmartScheduleDetailViewController.")
            }
            return vc
        }
        
        case DetailRoomsPopoverView = "DetailRoomsPopoverView"
        static func instantiateDetailRoomsPopoverView() -> UIViewController {
            guard let vc = StoryboardScene.SmartSchedule.DetailRoomsPopoverView.viewController() as? DetailRoomsPopoverView
                else {
                    fatalError("ViewController 'DetailRoomsPopoverView' is not of the expected class DetailRoomsPopoverView.")
            }
            return vc
        }
    }
    
    enum Home: String, StoryboardSceneType {
        static let storyboardName = "Home"
        case navigationControllerScene = "NavigationController"
        static func instantiateNavigationController() -> UINavigationController {
            guard let vc = StoryboardScene.Home.navigationControllerScene.viewController() as? UINavigationController
                else {
                    fatalError("ViewController 'NavigationController' is not of the expected class UINavigationController.")
            }
            return vc
        }
        case SelectedRoomViewController = "SelectedRoomViewController"
        static func instantiateSelectedRoomViewController() -> UIViewController {
            guard let vc = StoryboardScene.Home.SelectedRoomViewController.viewController() as? SelectedRoomViewController
                else {
                    fatalError("ViewController 'SelectedRoomViewController' is not of the expected class SelectedRoomViewController.")
            }
            return vc
        }
        
        case ConfigurationRoomViewController = "ConfigurationRoomViewController"
        static func instantiateConfigurationRoomViewController() -> UIViewController {
            guard let vc = StoryboardScene.Home.ConfigurationRoomViewController.viewController() as? ConfigurationRoomViewController
                else {
                    fatalError("ViewController 'ConfigurationRoomViewController' is not of the expected class ConfigurationRoomViewController.")
            }
            return vc
        }
        
        case ManualBoostViewController = "ManualBoostViewController"
        static func instantiateManualBoostViewController() -> UIViewController {
            guard let vc = StoryboardScene.Home.ManualBoostViewController.viewController() as? ManualBoostViewController
                else {
                    fatalError("ViewController 'ManualBoostViewController' is not of the expected class ManualBoostViewController.")
            }
            return vc
        }
    }
    
    enum Room: String, StoryboardSceneType {
        static let storyboardName = "Room"
        case RoomDetailViewController = "RoomDetailViewController"
        static func instantiateRoomDetailViewController() -> UIViewController {
            guard let vc = StoryboardScene.Room.RoomDetailViewController.viewController() as? RoomDetailViewController
                else {
                    fatalError("ViewController 'RoomDetailViewController' is not of the expected class RoomDetailViewController.")
            }
            return vc
        }
    }
    
    enum Sensor: String, StoryboardSceneType {
        static let storyboardName = "Sensor"
        case SensorManagementViewController = "SensorManagementViewController"
        static func instantiateSensorManagementViewController() -> UIViewController {
            guard let vc = StoryboardScene.Sensor.SensorManagementViewController.viewController() as? SensorManagementViewController
                else {
                    fatalError("ViewController 'SensorManagementViewController' is not of the expected class SensorManagementViewController.")
            }
            return vc
        }
        case EditSensorViewController = "EditSensorViewController"
        static func instantiateEditSensorViewController() -> UIViewController {
            guard let vc = StoryboardScene.Sensor.EditSensorViewController.viewController() as? EditSensorViewController
                else {
                    fatalError("ViewController 'EditSensorViewController' is not of the expected class EditSensorViewController.")
            }
            return vc
        }
    }
    
    enum Heater: String, StoryboardSceneType {
        static let storyboardName = "Heater"
        case AddHeaterViewController = "AddHeaterViewController"
        static func instantiateAddHeaterViewController() -> UIViewController {
            guard let vc = StoryboardScene.Heater.AddHeaterViewController.viewController() as? AddHeaterViewController
                else {
                    fatalError("ViewController 'AddHeaterViewController' is not of the expected class AddHeaterViewController.")
            }
            return vc
        }
        case HeatersManagementViewController = "HeatersManagementViewController"
        static func instantiateHeatersManagementViewController() -> UIViewController {
            guard let vc = StoryboardScene.Heater.HeatersManagementViewController.viewController() as? HeatersManagementViewController
                else {
                    fatalError("ViewController 'HeatersManagementViewController' is not of the expected class HeatersManagementViewController.")
            }
            return vc
        }
    }
    
    enum OfflineAlert: String, StoryboardSceneType {
        static let storyboardName = "OfflineAlertViewController"
        case OfflineAlertViewController = "OfflineAlertViewController"
        static func instantiateOfflineAlertViewController() -> UIViewController {
            guard let vc = StoryboardScene.OfflineAlert.OfflineAlertViewController.viewController() as? OfflineAlertViewController
                else {
                    fatalError("ViewController 'OfflineAlertViewController' is not of the expected class OfflineAlertViewController.")
            }
            return vc
        }
    }
    
    
    
}
