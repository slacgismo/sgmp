//
//  SGMP_AR_SamplesApp.swift
//  SGMP-AR-Samples
//
//  Created by fincher on 9/15/21.
//

import Foundation
import SwiftUI
import Sentry
import Defaults

/**
 SGMP App Delegate
 */
@main
class SgmpAppDelegate : UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    /// Called after the app finishes launching
    /// - Parameters:
    ///   - application: application
    ///   - launchOptions: options
    /// - Returns: if the app finishes launching
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupAllBaseManagers()
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SessionManager.shared.scheduleRefreshTokenTask()
    }
}


/**
 Root View, the only content is a `ScaffoldView` with an `Env` from `EnvironmentManager`
 */
struct RootView: View {
    var body: some View {
        ScaffoldView().environmentObject(EnvironmentManager.shared.env)
    }
}

/**
 Hosting controller for the SwiftUI based `RootView` to use in UIKit
 */
class SgmpHostingController : UIHostingController<RootView> {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: RootView());
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
