//
//  UIImage+Crop.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import UIKit
import VideoToolbox

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        guard let cgImage = cgImage else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    func cropToCG(rect: CGRect, scale: CGFloat) -> CGImage? {
        return self.cgImage?.cropping(to: rect, scale: scale)
    }
}

extension CGImage {
    
    func cropping(to rect: CGRect, scale: CGFloat) -> CGImage? {
        var rect = rect
        rect.origin.x*=scale
        rect.origin.y*=scale
        rect.size.width*=scale
        rect.size.height*=scale
        return self.cropping(to: rect)
    }
}
