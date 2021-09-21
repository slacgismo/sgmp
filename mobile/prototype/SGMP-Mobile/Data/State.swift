import Foundation
import SwiftUI
import Defaults

class Env: ObservableObject {
    var showLogin = true
    
    init() {
        Defaults.observe(.loginEmailAddress) { change in
            print("loginEmailAddress \(change.oldValue) - \(change.newValue) - showLogin \(change.newValue.isEmpty)")
            self.showLogin = change.newValue.isEmpty
        }.tieToLifetime(of: self)
    }
}

extension Defaults.Keys {
    static let loginEmailAddress = Key<String>("loginEmailAddress", default: "")
}
