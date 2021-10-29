import Foundation
import ARKit

enum ARCameraTrackingState {
    
    case notAvailable
    case limited(ARCamera.TrackingState.Reason)
    case normal
    
    init(from state : ARCamera.TrackingState) {
        switch state {
        case .notAvailable:
            self = .notAvailable
        case .normal:
            self = .normal
        case .limited(let reason):
            self = .limited(reason)
        }
    }
    
    var desc : String {
        switch self {
        case .notAvailable:
            return "Not Available"
        case .normal:
            return "Normal"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "Limited due to Excessive Motion"
            case .relocalizing:
                return "Limited due to Relocalizing"
            case .insufficientFeatures:
                return "Limited due to Insufficient Features"
            case .initializing:
                return "Limited due to Initializing"
            @unknown default:
                return "Unknown"
            }
        }
   }
}
