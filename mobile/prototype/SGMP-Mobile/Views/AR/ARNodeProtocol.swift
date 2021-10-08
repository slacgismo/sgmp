//
//  ARNodeUpdateProtocol.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/20/21.
//

import Foundation
import ARKit

protocol ARNodeAnchorProtocol {
    func didAddToScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) -> Void
    func didRemoveFromScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) -> Void
    func didUpdateInScene(_ renderer: SCNSceneRenderer, view: ARSCNView, anchor: ARAnchor) -> Void
}

protocol ARNodeUpdateProtocol {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
}
