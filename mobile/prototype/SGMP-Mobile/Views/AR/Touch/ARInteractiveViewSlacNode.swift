//
//  ARInteractiveViewSlacNode.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import SceneKit
import ARKit
import Defaults

class ARInteractiveViewSlacNode : ARInteractiveSwiftUINode<ARRefImageSlacView>
{
    var isTracked : Bool = false
    var isParsed : Bool = false
    
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
                if !isTracked {
                    containerPlaneNode.opacity = 0
                }
                DispatchQueue.main.async {
                    EnvironmentManager.shared.env.arActivelyTracking = self.isTracked
                }
            }
            
            if EnvironmentManager.shared.env.arQRDecodedString == nil && isTracked {
                let (img, str) = scanForQRImage(renderer, view: view)
                DispatchQueue.main.async {
                    EnvironmentManager.shared.env.arQRCroppedImage = Defaults[.debugMode] ? img : nil
                    EnvironmentManager.shared.env.arQRDecodedString = str ?? nil
                    if let _ = EnvironmentManager.shared.env.arQRDecodedString {
                        self.view = ARRefImageSlacView()
                        SCNTransaction.animationDuration = 1
                        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                        self.containerPlaneNode.opacity = 1
                    }
                }
            }
        }
    }
}
