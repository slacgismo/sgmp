import Foundation
import SwiftUI
import Defaults
import Amplify

class Env: ObservableObject {
    
    @Published var authState : AuthStates? = nil
    
//    @Published var showDecorationView : Bool = false
//    @Published var decorationView : AnyView = AnyView(Color.clear)

//    func showDecoration(view: AnyView, forTime: DispatchTimeInterval) -> Void {
//        DispatchQueue.main.async {
//            self.showDecorationView = true
//            self.decorationView = view
//            DispatchQueue.global(qos: .background).async {
//                DispatchQueue.main.asyncAfter(deadline: .now() + forTime) {
//                    self.showDecorationView = false
//                }
//            }
//        }
//    }
//    func showDecoration(view: AnyView) -> Void {
//        DispatchQueue.main.async {
//            self.showDecorationView = true
//            self.decorationView = view
//        }
//    }
//    func removeDecoration() -> Void {
//        DispatchQueue.main.async {
//            self.showDecorationView = false
//        }
//    }
    
    init() {
        
    }
}

extension Defaults.Keys {
    static let debugMode = Key<Bool>("debugMode", default: false)
}
