import Foundation
import SwiftUI
import Defaults
import Amplify

class Env: ObservableObject {
    
    // MARK: - User
    @Published var authState : AuthStates? = nil
    @Published var authUser : AuthUser? = nil
    
    // MARK: - AR
    @Published var arCameraTrackingState : ARCameraTrackingState = .notAvailable
    @Published var arDebugInfo : ARDebugDataModel? = nil
    
    // MARK: - Houses
    @Published var houses : [House] = []
    
    // MARK: - Devices
    @Published var devices : [Device] = []
    
    init() {
    }
}

extension Defaults.Keys {
    static let debugMode = Key<Bool>("debugMode", default: false)
    static let mockMode = Key<Bool>("mockMode", default: false)
    static let crashAnalytics = Key<Bool>("crashAnalytics", default: false)
}
