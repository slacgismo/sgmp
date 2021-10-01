//
//  UserManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/29/21.
//

import Foundation
import Amplify
import AWSCognitoAuthPlugin

class UserManager : BaseManager {
    
    override func setup() {
        do {
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
                try Amplify.configure()
                print("Amplify configured with auth plugin")
            } catch {
                print("Failed to initialize Amplify with \(error)")
            }
    }
    
    func login(userName : String, password : String, callback: @escaping ((Bool) -> Void)) -> Void {
        Amplify.Auth.signIn(username: userName, password: password) { result in
                switch result {
                case .success:
                    print("Sign in succeeded")
                    callback(true)
                case .failure(let error):
                    print("Sign in failed \(error)")
                    callback(false)
                }
            }
    }
    
    override func destroy() {
        
    }
    
}
