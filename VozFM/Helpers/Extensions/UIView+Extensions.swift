//
//  UIView+Extensions.swift
//  VozFM
//
//  Created by Victor on 11/1/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func containsSuperviewPoint(_ point: CGPoint) -> Bool {
        let locationInView = self.convert(point, from: self.superview)
        if self.bounds.contains(locationInView) {
            return true
        } else {
            return false
        }
    }
    
}
