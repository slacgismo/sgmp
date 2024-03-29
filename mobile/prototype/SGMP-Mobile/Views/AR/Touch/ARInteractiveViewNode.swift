//
//  ARTouchViewNode.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/21/21.
//

import Foundation
import SceneKit
import UIKit
import ARKit
import SwiftUI
import Vision
import Defaults

class ARInteractiveViewNode : SCNNode, ARNodeAnchorProtocol {
    
    var viewSize : CGSize = CGSize.zero
    var planeSize : CGSize = CGSize.zero
    var containerPlaneNode : SCNNode = SCNNode()
    
    init(viewSize : CGSize, planeSize : CGSize) {
        super.init()
        self.viewSize = viewSize
        self.planeSize = planeSize
        let plane = SCNPlane(width: planeSize.width, height: planeSize.height)
        let tempMaterial = SCNMaterial()
        tempMaterial.lightingModel = .constant
        tempMaterial.diffuse.contents = UIColor.clear
        plane.materials = [tempMaterial]
        containerPlaneNode = SCNNode(geometry: plane)
        containerPlaneNode.eulerAngles.x = -.pi / 2
        self.addChildNode(containerPlaneNode)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - ARNodeAnchorProtocol
    func didAddToScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) {
        
    }
    
    func didUpdateInScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) {
        
    }
    
    func didRemoveFromScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) {
        
    }
}

class ARInteractiveUIViewNode : ARInteractiveViewNode {
    var view : UIView? {
        willSet {
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.diffuse.contents = newValue
            self.containerPlaneNode.geometry!.materials = [material]
        }
    }
    
    init(viewSize : CGSize, planeSize : CGSize, view : UIView?) {
        super.init(viewSize: viewSize, planeSize: planeSize)
        DispatchQueue.main.async {
            self.view = view
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class ARInteractiveSwiftUINode<Content> : ARInteractiveViewNode where Content : View {
    var view : Content?
    {
        willSet {
            hostingController?.rootView = newValue
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.diffuse.contents = hostingController?.view
            self.containerPlaneNode.geometry!.materials = [material]
        }
    }
    
    var hostingController : ARSwiftUIHostingController<Content?>?
    
    init(viewSize : CGSize, planeSize : CGSize, view : Content?) {
        super.init(viewSize: viewSize, planeSize: planeSize)
        DispatchQueue.main.async {
            self.hostingController = ARSwiftUIHostingController(rootView: nil)
            self.hostingController?.view.insetsLayoutMarginsFromSafeArea = false
            self.hostingController?.view.backgroundColor = .clear
            self.hostingController?.view.frame = CGRect.init(origin: .zero, size: self.viewSize)
            self.hostingController?.view.isOpaque = false
//            if let parentVC = parentVC, let hostingVC = self.hostingController {
//                parentVC.add(hostingVC)
//            }
            self.view = view
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
