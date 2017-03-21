//
//  GradientView.swift
//  VozFM
//
//  Created by Victor on 10/29/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import Foundation
import UIKit

/// Linear gradient UIView
@IBDesignable class GradientView: UIView {
    
    @IBInspectable var topColor: UIColor = UIColor.white.withAlphaComponent(0)
    @IBInspectable var bottomColor: UIColor = UIColor.white.withAlphaComponent(1)
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
}
