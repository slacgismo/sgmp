//
//  ARRefImageSlacViewHostingController.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/8/21.
//

import Foundation
import SwiftUI

class ARRefImageSlacViewHostingController: UIHostingController<ARRefImageSlacView> {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: ARRefImageSlacView())
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let position = touch.location(in: view)
            print(position)
        }
        super.touchesBegan(touches, with: event)
    }
}
