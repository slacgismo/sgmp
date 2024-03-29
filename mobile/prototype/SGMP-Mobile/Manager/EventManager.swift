//
//  EventManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/6/21.
//

import Foundation
import Sentry
import Defaults

/**
 A singleton for event tracking, mainly for Sentry SDK for now.
 */
class EventManager : BaseManager {
    
    static let instance = EventManager()
      
    override class var shared: EventManager {
        return instance
    }
    
    func log (message : String) -> Void {
        
    }
    
    func capture (err : Error) -> Void {
        SentrySDK.capture(error: err)
    }
    
    /// Setup event tracking SDK and related UserDefaults listeners to toggle the SDK on or off
    override func setup() {
        _ = Defaults.publisher(.crashAnalytics).sink { changed in
            if changed.oldValue == true {
                SentrySDK.start { options in
                        options.dsn = SentryDSN
                        options.debug = false // Enabled debug when first installing is always helpful
                }
            } else {
                SentrySDK.close()
            }
        }
    }
    
}
