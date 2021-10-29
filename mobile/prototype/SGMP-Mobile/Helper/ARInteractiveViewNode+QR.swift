//
//  ARInteractiveViewNode+QR.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import SceneKit
import ARKit
import VideoToolbox

extension ARInteractiveViewNode {
    func scanForQRImage(_ renderer: SCNSceneRenderer, view: ARSCNView) -> (UIImage?, String?) {
        let worldSpaceBoundingBoxMax : SCNVector3 = self.convertPosition(self.boundingBox.max, to: nil)
        let worldSpaceBoundingBoxMin : SCNVector3 = self.convertPosition(self.boundingBox.min, to: nil)
        let screenSpaceBoundingBoxMax = renderer.projectPoint(worldSpaceBoundingBoxMax)
        let screenSpaceBoundingBoxMin = renderer.projectPoint(worldSpaceBoundingBoxMin)
        let path = CGMutablePath()
        path.addLines(between: [
            CGPoint.init(x: CGFloat(screenSpaceBoundingBoxMax.x), y: CGFloat(screenSpaceBoundingBoxMax.y)),
            CGPoint.init(x: CGFloat(screenSpaceBoundingBoxMin.x), y: CGFloat(screenSpaceBoundingBoxMin.y))
        ])
        let uiSpaceBoundingBox = path.boundingBoxOfPath
        let viewImage = view.snapshot()
        if let croppedImage = viewImage.cropToCG(rect: uiSpaceBoundingBox, scale: UIScreen.main.scale)
        {
            let vnImageRequest = VNImageRequestHandler(cgImage: croppedImage, options: [:])
            let vnQrRequest = VNDetectBarcodesRequest()
            vnQrRequest.symbologies = [.qr]
            do {
                try vnImageRequest.perform([vnQrRequest])
            } catch (let err) {
                print("err \(err)")
            }
            let str = vnQrRequest.results?.compactMap({ ob in
                ob.payloadStringValue
            }).first
            
            return (UIImage(cgImage: croppedImage), str)
        }
        return (nil, nil)
    }
}
