//
//  ARTouchViewNode.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/21/21.
//

import Foundation
import SceneKit
import UIKit
import SwiftUI

class ARInteractiveUIViewNode : SCNNode {
    var viewSize : CGSize = CGSize.zero
    var planeSize : CGSize = CGSize.zero
    var view : UIView = UIView()
    
    init(viewSize : CGSize, planeSize : CGSize, view : UIView) {
        super.init()
        self.view = view
        self.viewSize = viewSize
        self.planeSize = planeSize
        postInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func postInit() {
        let plane = SCNPlane(width: planeSize.width,
                             height: planeSize.height)
        DispatchQueue.main.async {
            self.view.frame = CGRect.init(origin: .zero, size: self.viewSize)
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.diffuse.contents = self.view
            plane.materials = [material]
        }
        let container = SCNNode(geometry: plane)
        container.eulerAngles.x = -.pi / 2
        self.addChildNode(container)
    }
}

class ARInteractiveSwiftUINode<Content> : SCNNode where Content : View {
    var viewSize : CGSize = CGSize.zero
    var planeSize : CGSize = CGSize.zero
    var view : Content?
    var controller : UIViewController?
    
    init(viewSize : CGSize, planeSize : CGSize, view : Content, controller : UIViewController) {
        self.view = view
        self.viewSize = viewSize
        self.planeSize = planeSize
        self.controller = controller
        super.init()
        postInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func postInit() {
        let plane = SCNPlane(width: planeSize.width,
                             height: planeSize.height)
        DispatchQueue.main.async {
            let vc = UIHostingController(rootView: self.view)
            if let controller = self.controller {
                vc.willMove(toParent: controller)
                controller.addChild(vc)
                controller.view.addSubview(vc.view)
            }
            vc.view.backgroundColor = .clear
            vc.view.frame = CGRect.init(origin: .zero, size: self.viewSize)
            vc.view.isOpaque = false
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.diffuse.contents = vc.view
            plane.materials = [material]
        }
        let container = SCNNode(geometry: plane)
        container.eulerAngles.x = -.pi / 2
        self.addChildNode(container)
    }
}
