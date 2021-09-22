//
//  SGMP_AR_SamplesApp.swift
//  SGMP-AR-Samples
//
//  Created by fincher on 9/15/21.
//

import Foundation
import SwiftUI

@main
struct SgmpApp: App {
    
    @UIApplicationDelegateAdaptor(SgmpAppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ScaffoldView()
                .environmentObject(EnvironmentManager.shared.env)
        }
    }
}

class SgmpAppDelegate : UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        setupAllBaseManagers()
        return true
    }
}
