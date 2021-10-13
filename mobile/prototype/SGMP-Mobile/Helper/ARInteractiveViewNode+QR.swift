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
import Defaults

extension ARInteractiveViewNode {
    func scanForQRImage(_ renderer: SCNSceneRenderer, view: ARSCNView) -> String? {
//        print("self.position \(self.presentation.position)")
//        print("self.boundingBox.max \(self.presentation.boundingBox.max)")
//        print("self.boundingBox.min \(self.presentation.boundingBox.min)")
        let worldSpaceBoundingBoxMax : SCNVector3 = self.convertPosition(self.boundingBox.max, to: nil)
        let worldSpaceBoundingBoxMin : SCNVector3 = self.convertPosition(self.boundingBox.min, to: nil)
//        print("worldSpaceBoundingBoxMax \(worldSpaceBoundingBoxMax)")
//        print("worldSpaceBoundingBoxMin \(worldSpaceBoundingBoxMin)")
        let screenSpaceBoundingBoxMax = renderer.projectPoint(worldSpaceBoundingBoxMax)
        let screenSpaceBoundingBoxMin = renderer.projectPoint(worldSpaceBoundingBoxMin)
//        print("screenSpaceBoundingBoxMax \(screenSpaceBoundingBoxMax)")
//        print("screenSpaceBoundingBoxMin \(screenSpaceBoundingBoxMin)")
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
            
            if Defaults[.debugMode] == true {
                DispatchQueue.main.async {
                    EnvironmentManager.shared.env.arDebugInfo = ARDebugDataModel(croppedImage: UIImage(cgImage: croppedImage), decodeString: str ?? "")
                }
            }
            return str
        }
        return nil
    }
}
