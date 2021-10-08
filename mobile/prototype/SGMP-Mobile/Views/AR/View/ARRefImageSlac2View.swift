//
//  ARRefImageSlac2View.swift
//  SGMP-Mobile
//
//  Created by fincher on 10/7/21.
//

import Foundation
import UIKit

class ARRefImageSlac2View: UIView {
    static let preferredSize : CGSize = CGSize.init(width: 1300.0/4, height: 500.0/4)
    @IBOutlet var contentView: UIView!
    let xibName = "ARRefImageSlac2View"
    
    init() {
        super.init(frame: CGRect.init(origin: .zero, size: ARRefImageSlac2View.preferredSize))
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
    
    func postInit() {
        self.backgroundColor = .clear
        self.isOpaque = false
        Bundle.main.loadNibNamed(xibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
