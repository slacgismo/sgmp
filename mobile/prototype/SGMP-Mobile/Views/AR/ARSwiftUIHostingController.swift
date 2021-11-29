//
//  ARSwiftUIHostingController.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import SwiftUI

class ARSwiftUIHostingController<Content> : UIHostingController<Content> where Content : View {    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
    }
}
