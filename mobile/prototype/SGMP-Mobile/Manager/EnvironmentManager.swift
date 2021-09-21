//
//  EnvironmentManager.swift
//  Transcribe
//
//  Created by fincher on 7/3/21.
//

import Foundation

class EnvironmentManager : BaseManager {
    
    static let instance = EnvironmentManager()
    
    override class var shared: EnvironmentManager {
        return instance
    }
    
    let env : Env = Env()
}
