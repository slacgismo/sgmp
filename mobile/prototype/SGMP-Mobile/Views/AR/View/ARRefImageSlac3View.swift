//
//  ARRefImageSlac3View.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import UIKit
import SwiftUI

class ARRefImageSlac3View: UIView {
    static let preferredSize : CGSize = CGSize.init(width: 1300.0/4, height: 500.0/4)
    
    init() {
        super.init(frame: CGRect.init(origin: .zero, size: ARRefImageSlac3View.preferredSize))
        postInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        postInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        postInit()
    }
    
    override var alignmentRectInsets: UIEdgeInsets {
        return .zero
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return .zero
    }
    
    
    func postInit() {
        self.backgroundColor = .clear
        self.isOpaque = false
        self.insetsLayoutMarginsFromSafeArea = false
        let vc = ARSwiftUIHostingController(rootView: ARRefImageSlacView().ignoresSafeArea().edgesIgnoringSafeArea(.all))
        vc.view.insetsLayoutMarginsFromSafeArea = false
        self.addSubview(vc.view)
        vc.view.backgroundColor = .clear
        vc.view.isOpaque = false
        vc.view.frame = self.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
