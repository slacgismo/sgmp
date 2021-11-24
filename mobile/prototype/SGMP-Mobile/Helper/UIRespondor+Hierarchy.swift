//
//  UIRespondor+Hierarchy.swift
//  SGMP-Mobile
//
//  Created by fincher on 9/22/21.
//

import UIKit
import Foundation

extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}
