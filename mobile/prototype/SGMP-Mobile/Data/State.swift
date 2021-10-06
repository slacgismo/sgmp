import Foundation
import SwiftUI
import Defaults
import Amplify

class Env: ObservableObject {
    
    // MARK: - User
    @Published var authState : AuthStates? = nil {
        didSet {
            
        }
    }
    @Published var authUser : AuthUser? = nil
    
    // MARK: - AR
    @Published var arCameraTrackingState : ARCameraTrackingState = .notAvailable
    
    init() {
        
    }
}

extension Defaults.Keys {
    static let debugMode = Key<Bool>("debugMode", default: false)
}
