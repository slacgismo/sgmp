//
//  ARTouchViewNode.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/21/21.
//

import Foundation
import SceneKit

class ARInteractiveViewNode : SCNNode, ARNodeTouchProtocol {
    let viewSize : CGSize = CGSize.zero
    let planeSize : CGSize = CGSize.zero
    
    func hit(hitResult: SCNHitTestResult) {
        
    }
}
