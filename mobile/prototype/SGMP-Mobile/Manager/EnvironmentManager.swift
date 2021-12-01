//
//  EnvironmentManager.swift
//  Transcribe
//
//  Created by fincher on 7/3/21.
//

import Foundation

/**
 Environment Manager as a singleton holds a global`Env` object that will be fed into SwiftUI views
 */
class EnvironmentManager : BaseManager {
    
    static let instance = EnvironmentManager()
    
    override class var shared: EnvironmentManager {
        return instance
    }
    
    
    /// The environment object. Adding this to SwiftUI require adding `.environmentObject(EnvironmentManager.instance.env)` to the view
    let env : Env = Env()
}
