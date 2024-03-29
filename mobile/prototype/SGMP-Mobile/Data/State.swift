import Foundation
import SwiftUI
import Defaults
import Combine

/**
 An environment object holding properties that will be supplied as `EnvironmentObject` to SwiftUI views
 */
class Env: ObservableObject {
    
    // MARK: - User
    
    /// Is user login required, used for showing login modal view in `MainTabView`
    @Published var loginRequired : Bool = false
    
    // MARK: - AR
    @Published var arCameraTrackingState : ARCameraTrackingState = .notAvailable
    @Published var arActivelyTracking : Bool = false
    @Published var arQRDecodedString : String? = nil
    @Published var arQRCroppedImage : UIImage? = nil
    @Published var arTrackingDevice : DeviceDetail? = nil
    
    func resetAR() {
        arQRCroppedImage = nil
        arActivelyTracking = false
        arQRDecodedString = nil
        arTrackingDevice = nil
    }
    
    // MARK: - Houses
    
    /// All houses currently available to the user and maintained in the env
    @Published var houses : [House] = []
    
    /// The current selected house from `houses` to show on the dashboard
    @Published var currentDashboardHouse : House? = nil
    
    // MARK: - Devices
    
    /// The devices list of the current selected house, i.e, `currentDashboardHouse`
    @Published var currentDashboardDevices : [Device] = []
    
    // MARK: - Analytics
    
    /// The analytics list of the current selected house, i.e, `currentDashboardHouse`
    @Published var currentDashboardAnalytics : [DefinedAnalytics] = []
    
    
    /// A set of `AnyCancellable` to store all Combine subscriptions
    var cancellableSet : Set<AnyCancellable> = Set()
    
    init() {
        
        self.$currentDashboardHouse.sink { house in
            DispatchQueue.main.async {
                self.currentDashboardDevices = []
                self.updateCurrentHouseDevices()
                self.currentDashboardAnalytics = []
                self.updateCurrentHouseAnalytics()
            }
        }.store(in: &cancellableSet)
        
        self.$arActivelyTracking.sink { tracking in
            DispatchQueue.main.async {
                if !tracking {
                    self.arQRDecodedString = nil
                }
            }
        }.store(in: &cancellableSet)
        
        self.$arQRDecodedString.sink { string in
            if let string = string, let deviceIDString = URLComponents(string: string)?.queryItems?.first(where: { item in
                item.name == "deviceId" || item.name == "deviceID" || item.name == "device_id"
            })?.value, let deviceID = UInt64(deviceIDString)
            {
                NetworkManager.shared.getDeviceDetail(deviceId: deviceID) { detail, err in
                    if let detail = detail {
                        DispatchQueue.main.async {
                            self.arTrackingDevice = detail
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.arTrackingDevice = nil
                }
            }
        }.store(in: &cancellableSet)
    }
    
    func updateHouses(callback: (([House], Error?) -> Void)? = nil) -> Void {
        NetworkManager.shared.getHouses { houses, err in
            if let err = err {
                print(err)
            }
            DispatchQueue.main.async {
                let env = EnvironmentManager.shared.env
                
                let previousHouseId = env.currentDashboardHouse?.house_id
                env.currentDashboardHouse = nil
                
                env.houses = houses
                let newHosue = env.houses.filter({ house in
                    house.house_id == previousHouseId // maintain choice
                }).first
                
                if let newHosue = newHosue { // either current house is not in refreshed list, or current house is nil
                    env.currentDashboardHouse = newHosue
                } else {
                    env.currentDashboardHouse = houses.first
                }
                callback?(houses, err)
            }
        }
    }
    
    func updateCurrentHouseDevices(callback: (([Device], Error?) -> Void)? = nil) -> Void {
        if let houseId = currentDashboardHouse?.house_id {
            NetworkManager.shared.getDevices(houseId: houseId) { devices, err in
                if let err = err {
                    print(err)
                }
                DispatchQueue.main.async {
                    let devicesUnWrapped = devices ?? []
                    self.currentDashboardDevices = devicesUnWrapped
                    callback?(devicesUnWrapped, err)
                }
            }
        } else {
            callback?([], nil)
        }
    }
    
    func updateCurrentHouseAnalytics(callback: (([DefinedAnalytics], Error?) -> Void)? = nil) -> Void {
        if let houseId = currentDashboardHouse?.house_id {
            NetworkManager.shared.getDefinedAnalytics(houseId: houseId) { analytics, err in
                if let err = err {
                    print(err)
                }
                DispatchQueue.main.async {
                    let analyticsUnWrapped = analytics ?? []
                    self.currentDashboardAnalytics = analyticsUnWrapped
                    callback?(analyticsUnWrapped, err)
                }
            }
        } else {
            callback?([], nil)
        }
    }
}

/**
 Extension to `Defaults.Keys` to add custom keys for `UserDefaults`
 */
extension Defaults.Keys {
    // MARK: - Debug
    
    /// Debug mode, affect UI behaviors
    static let debugMode = Key<Bool>("debugMode", default: false)
    
    /// Mock mode, not used at the moment but reserved for future
    static let mockMode = Key<Bool>("mockMode", default: false)
    
    /// Enable crash / events analytics SDK
    static let crashAnalytics = Key<Bool>("crashAnalytics", default: false)
    
    // MARK: - User
    
    /// User profile
    static let userProfile = Key<UserProfile?>("userProfile", default: nil)
    
    // MARK: - UI
    
    /// Expand rows in the dashboard view
    static let expandRowsInDashboard = Key<Bool>("expandRowsInDashboard", default: true)
    
    /// Show icons in the device list view
    static let showIconInDeviceList = Key<Bool>("showIconInDeviceList", default: false)
    
    /// Show icons in the analytics list view
    static let showIconInAnalyticsList = Key<Bool>("showIconInAnalyticsList", default: false)
    
    /// Expand rows in the analytics list view
    static let expandRowsInAnalyticsList = Key<Bool>("expandRowsInAnalyticsList", default: false)
    
    // MARK: - Network
    
    /// Use custom root url defined in `customEndpointUrl`
    static let customEndpoint = Key<Bool>("customEndpoint", default: false)
    
    /// Custom root url
    static let customEndpointUrl = Key<String>("customEndpointUrl", default: "http://gismolab-sgmp-staging-1374415927.us-west-1.elb.amazonaws.com/")
}
