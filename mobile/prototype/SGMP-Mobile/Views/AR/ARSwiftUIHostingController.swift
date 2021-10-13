//
//  ARSwiftUIHostingController.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import SwiftUI

class ARSwiftUIHostingController<Content> : UIHostingController<Content> where Content : View {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first {
//            let position = touch.location(in: view)
//            print(position)
//        }
        super.touchesBegan(touches, with: event)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
    }
}
