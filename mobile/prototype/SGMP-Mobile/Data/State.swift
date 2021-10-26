import Foundation
import SwiftUI
import Defaults

class Env: ObservableObject {
    
    // MARK: - User
    @Published var loginRequired : Bool = false
    
    // MARK: - AR
    @Published var arCameraTrackingState : ARCameraTrackingState = .notAvailable
    @Published var arDebugInfo : ARDebugDataModel? = nil
    
    // MARK: - Houses
    @Published var houses : [House] = []
    @Published var currentDashboardHouse : House? = nil
    
    // MARK: - Devices
    @Published var devices : [Device] = []
    
    init() {
        Defaults.observe(.userProfile) { change in
            DispatchQueue.main.async {
                self.loginRequired = change.newValue == nil
            }
        }.tieToLifetime(of: self)
    }
}

extension Defaults.Keys {
    static let debugMode = Key<Bool>("debugMode", default: false)
    static let mockMode = Key<Bool>("mockMode", default: false)
    static let crashAnalytics = Key<Bool>("crashAnalytics", default: false)
    static let userProfile = Key<UserProfile?>("userProfile", default: nil)
}
