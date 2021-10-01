import Foundation
import SwiftUI
import Defaults

class Env: ObservableObject {
    var showLogin = true
    
    @Published var showDecorationView : Bool = false
    @Published var decorationView : AnyView = AnyView(Color.clear)

    func showDecoration(view: AnyView, forTime: DispatchTimeInterval) -> Void {
        self.showDecorationView = true
        self.decorationView = view
        DispatchQueue.global(qos: .background).async {
            DispatchQueue.main.asyncAfter(deadline: .now() + forTime) {
                self.showDecorationView = false
            }
        }
    }
    func showDecoration(view: AnyView) -> Void {
        self.showDecorationView = true
        self.decorationView = view
    }
    func removeDecoration() -> Void {
        self.showDecorationView = false
    }
    
    init() {
        Defaults.observe(.loginEmailAddress) { change in
            print("loginEmailAddress \(change.oldValue) - \(change.newValue) - showLogin \(change.newValue.isEmpty)")
            self.showLogin = change.newValue.isEmpty
        }.tieToLifetime(of: self)
    }
}

extension Defaults.Keys {
    static let debugMode = Key<Bool>("debugMode", default: false)
    static let loginEmailAddress = Key<String>("loginEmailAddress", default: "")
}
