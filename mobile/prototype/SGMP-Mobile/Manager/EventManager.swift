//
//  EventManager.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/6/21.
//

import Foundation
import Sentry
import Defaults

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
    
    override func setup() {
        _ = Defaults.publisher(.crashAnalytics).sink { changed in
            if changed.oldValue == true {
                SentrySDK.start { options in
                        options.dsn = "https://e3944001a8194fbd9969258edb9df771@o198829.ingest.sentry.io/5996163"
                        options.debug = true // Enabled debug when first installing is always helpful
                }
            } else {
                SentrySDK.close()
            }
        }
    }
    
}
