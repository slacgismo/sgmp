import Foundation
import ARKit
import UIKit
import SwiftUI
import Defaults


/**
 The `UIViewController` that contains the AR view and shown in SwiftUI using `ARGridViewControllerRepresentable`
 */
class ARGridViewController : UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    /// AR View
    var arView : ARSCNView = ARSCNView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(arView)
        EnvironmentManager.shared.env.resetAR()
        arView.frame = self.view.bounds
        arView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        arView.delegate = self
        arView.session = ARSession()
        arView.session.delegate = self
        arView.isUserInteractionEnabled = true
        arView.isMultipleTouchEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let config = ARWorldTrackingConfiguration()
        config.maximumNumberOfTrackedImages = 4
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "ARResources", bundle: nil) {
            config.detectionImages = referenceImages
        } else {
            print("ARResources not found")
        }
        arView.session.run(config, options: [])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        arView.session.pause()
        UIApplication.shared.windows.forEach { window in
            if window != UIApplication.shared.keyWindow {
                window.isHidden = true
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - renderer: <#renderer description#>
    ///   - anchor: <#anchor description#>
    /// - Returns: <#description#>
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        if let anchor = anchor as? ARImageAnchor {
            if anchor.name == "slac" {
                let node = ARInteractiveViewSlacNode(planeSize: .init(
                    width: anchor.referenceImage.physicalSize.width * anchor.estimatedScaleFactor,
                    height: anchor.referenceImage.physicalSize.height * anchor.estimatedScaleFactor
                ))
                return node
            }
        }
        return nil
    }
    
    
    /// <#Description#>
    /// - Parameters:
    ///   - renderer: <#renderer description#>
    ///   - node: <#node description#>
    ///   - anchor: <#anchor description#>
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        node.simdTransform = anchor.transform
        if let anchor = anchor as? ARImageAnchor, anchor.name == "slac" {
            if let anchorNode = node as? ARNodeAnchorProtocol {
                anchorNode.didAddToScene(renderer, view: self.arView, anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARImageAnchor, anchor.name == "slac" {
            if let anchorNode = node as? ARNodeAnchorProtocol {
                anchorNode.didRemoveFromScene(renderer, view: self.arView, anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARImageAnchor, anchor.name == "slac" {
            if let anchorNode = node as? ARNodeAnchorProtocol {
                anchorNode.didUpdateInScene(renderer, view: self.arView, anchor: anchor)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        self.arView.session.currentFrame?.anchors
            .compactMap({ anchor in
                anchor as? ARNodeUpdateProtocol
            })
            .forEach({ node in
                node.renderer(renderer, updateAtTime: time)
            })
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        DispatchQueue.main.async {
            EnvironmentManager.shared.env.arCameraTrackingState = .init(from: camera.trackingState)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
    }
}

struct ARGridViewControllerRepresentable : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARGridViewController {
        return ARGridViewController()
    }
    
    func updateUIViewController(_ uiViewController: ARGridViewController, context: Context) {
        
    }
    
    static func dismantleUIViewController(_ uiViewController: ARGridViewController, coordinator: ()) {

    }
    
    typealias UIViewControllerType = ARGridViewController
}
