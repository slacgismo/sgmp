//
//  SGMP_AR_SamplesApp.swift
//  SGMP-AR-Samples
//
//  Created by fincher on 9/15/21.
//

import Foundation
import SwiftUI
import Amplify

@main
//struct SgmpApp: App {
//
//    @UIApplicationDelegateAdaptor(SgmpAppDelegate.self) var appDelegate
//
//    var body: some Scene {
//        WindowGroup {
////            ScaffoldView()
//            ARGridViewControllerRepresentable()
//                .environmentObject(EnvironmentManager.shared.env)
//        }
//    }
//}

class SgmpAppDelegate : UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        return true
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        do {
            try Amplify.configure()
        } catch (let error) {
            print (error.localizedDescription)
        }
        setupAllBaseManagers()
        return true
    }
}

struct RootView: View {
    var body: some View {
        ScaffoldView().environmentObject(EnvironmentManager.shared.env)
    }
}

class SgmpHostingController : UIHostingController<RootView> {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: RootView());
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
