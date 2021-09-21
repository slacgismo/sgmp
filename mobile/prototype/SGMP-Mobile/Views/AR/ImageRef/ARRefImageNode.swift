//
//  ARRefImageNode.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/20/21.
//

import Foundation
import ARKit
import SceneKit
import SwiftUI

class ARRefImageNode : SCNNode, ARNodeUpdateProtocol {
    var anchor : ARImageAnchor? = nil
    
    init(anchor : ARImageAnchor) {
        super.init()
        self.anchor = anchor
        self.name = anchor.identifier.uuidString
        
        
        let plane = SCNPlane(width: anchor.referenceImage.physicalSize.width,
                             height: anchor.referenceImage.physicalSize.height)
        let planeNode = SCNNode(geometry: plane)
        planeNode.eulerAngles.x = -.pi / 2
        
        DispatchQueue.main.async {
            let view : UIView = UIHostingController(rootView: ARRefImageCoverView()).view
            view.backgroundColor = UIColor.clear
            view.frame = CGRect.init(x: 0, y: 0, width: 300, height: 300)
            let parentView = UIView(frame: view.bounds)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            parentView.addSubview(view)
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.diffuse.contents = parentView
            planeNode.geometry?.materials = [material]
        }
        
        addChildNode(planeNode)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - ARNodeUpdateProtocol
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
    }
}
