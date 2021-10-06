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
    
    init(viewSize : CGSize, planeSize : CGSize, view : Content) {
        self.view = view
        self.viewSize = viewSize
        self.planeSize = planeSize
        super.init()
        postInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func postInit() {
        let plane = SCNPlane(width: planeSize.width,
                             height: planeSize.height)
        let tempMaterial = SCNMaterial()
        tempMaterial.lightingModel = .constant
        tempMaterial.diffuse.contents = UIColor.clear
        plane.materials = [tempMaterial]
        let container = SCNNode(geometry: plane)
        container.eulerAngles.x = -.pi / 2
        container.opacity = 0
        DispatchQueue.main.async {
            let vc = UIHostingController(rootView: self.view?.environmentObject(EnvironmentManager.shared.env))
            vc.view.backgroundColor = .clear
            vc.view.frame = CGRect.init(origin: .zero, size: self.viewSize)
            vc.view.isOpaque = false
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.isDoubleSided = true
            material.diffuse.contents = vc.view
            plane.materials = [material]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                SCNTransaction.animationDuration = 1
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                container.opacity = 1
            }
        }
        self.addChildNode(container)
    }
}
