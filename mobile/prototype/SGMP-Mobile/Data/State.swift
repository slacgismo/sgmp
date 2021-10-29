import Foundation
import SwiftUI
import Defaults
import Combine

class Env: ObservableObject {
    
    // MARK: - User
    @Published var loginRequired : Bool = false
    
    // MARK: - AR
    @Published var arCameraTrackingState : ARCameraTrackingState = .notAvailable
    @Published var arActivelyTracking : Bool = false
    @Published var arQRDecodedString : String? = nil
    @Published var arQRCroppedImage : UIImage? = nil
    @Published var arTrackingDevice : DeviceDetail? = nil
    
    // MARK: - Houses
    @Published var houses : [House] = []
    @Published var currentDashboardHouse : House? = nil
    
    // MARK: - Devices
    @Published var currentDashboardDevices : [Device] = []
    
    var cancellableSet : Set<AnyCancellable> = Set()
    
    init() {
        Defaults.observe(.userProfile) { change in
            DispatchQueue.main.async {
                self.loginRequired = change.newValue == nil
            }
        }.tieToLifetime(of: self)
        
        self.$currentDashboardHouse.sink { house in
            DispatchQueue.main.async {
                self.currentDashboardDevices = []
                self.updateCurrentHouseDevices { devices, err in
                    if let err = err {
                        print(err)
                    }
                }
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
            })?.value, let deviceID = Int64(deviceIDString)
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
                env.houses = houses
                if env.currentDashboardHouse == nil {
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
}

extension Defaults.Keys {
    static let debugMode = Key<Bool>("debugMode", default: false)
    static let mockMode = Key<Bool>("mockMode", default: false)
    static let crashAnalytics = Key<Bool>("crashAnalytics", default: false)
    static let userProfile = Key<UserProfile?>("userProfile", default: nil)
}
