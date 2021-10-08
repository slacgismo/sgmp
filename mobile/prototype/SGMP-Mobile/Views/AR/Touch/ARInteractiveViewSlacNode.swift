//
//  ARInteractiveViewSlacNode.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import SceneKit
import ARKit

class ARInteractiveViewSlacNode : ARInteractiveSwiftUINode<ARRefImageSlacView>
{
    var isTracked : Bool = false
    var isParsed : Bool = false
    var scannedResult : String? = nil
    
    init(planeSize: CGSize) {
        super.init(viewSize: ARRefImageSlacView.preferredSize, planeSize: planeSize, view: ARRefImageSlacView())
        containerPlaneNode.opacity = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - ARNodeAnchorProtocol
    override func didAddToScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) {
        super.didAddToScene(renderer, view: view, anchor: anchor)
    }
    
    override func didUpdateInScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) {
        super.didUpdateInScene(renderer, view: view, anchor: anchor)
        if let anchor = anchor as? ARImageAnchor {
            if isTracked != anchor.isTracked {
                isTracked = anchor.isTracked
                if isTracked {
                    
                } else {
                    scannedResult = nil
                    containerPlaneNode.opacity = 0
                }
            }
            
            if scannedResult == nil && isTracked {
                scannedResult = scanForQRImage(renderer, view: view)
                if let scannedResult = scannedResult {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        SCNTransaction.animationDuration = 1
                        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                        self.containerPlaneNode.opacity = 1
                    }
                }
            }
        }
    }
}
