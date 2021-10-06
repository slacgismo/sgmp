import Foundation
import SwiftUI
import Defaults
import Amplify

class Env: ObservableObject {
    
    @Published var authState : AuthStates? = nil
    @Published var authUser : AuthUser? = nil
    
    init() {
        
    }
}

extension Defaults.Keys {
    static let debugMode = Key<Bool>("debugMode", default: false)
}
