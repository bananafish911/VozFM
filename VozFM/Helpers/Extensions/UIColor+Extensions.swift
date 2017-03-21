//
//  Color+Extensions.swift
//  LapzeroTimer
//
//  Created by Victor on 9/19/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
}
