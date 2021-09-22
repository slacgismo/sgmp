//
//  ARNodeUpdateProtocol.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/20/21.
//

import Foundation
import ARKit

protocol ARNodeUpdateProtocol {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
}
