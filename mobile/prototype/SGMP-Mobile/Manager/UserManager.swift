//
//  UserManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/29/21.
//

import Combine
import Foundation
import Amplify
import AWSCognitoAuthPlugin


class UserManager : BaseManager {
    
    static let instance = UserManager()
      
    override class var shared: UserManager {
        return instance
    }
    
    let authListnerAnyCancellable : AnyCancellable = Amplify.Hub
        .publisher(for: .auth)
        .sink { payload in
            switch payload.eventName {
                case HubPayload.EventName.Auth.signedIn:
                    print("User signed in")
                    // Update UI

                case HubPayload.EventName.Auth.sessionExpired:
                    print("Session expired")
                    // Re-authenticate the user

                case HubPayload.EventName.Auth.signedOut:
                    print("User signed out")
                    // Update UI
                default:
                    break
            }
        }
    
    override func setup() {
        do {
            Amplify.Logging.logLevel = .verbose
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            _ = Amplify.Auth.fetchAuthSession { result in
                switch result {
                case .success(let session):
                    print("Is user signed in - \(session.isSignedIn)")
                    EnvironmentManager.shared.env.authState = session.isSignedIn ? nil : .login
                case .failure(let error):
                    print("Fetch session failed with error \(error)")
                    EnvironmentManager.shared.env.authState = .login
                }
            }
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
   
    
    override func destroy() {
        
    }
    
}
