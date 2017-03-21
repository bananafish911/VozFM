//
//  UILabel+extensions.swift
//  VozFM
//
//  Created by Victor on 10/29/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    // Kerning
    @IBInspectable var kerning: Float {
        get {
            var range = NSMakeRange(0, (text ?? "").characters.count)
            guard let kern = attributedText?.attribute(NSKernAttributeName, at: 0, effectiveRange: &range),
                let value = kern as? NSNumber
                else {
                    return 0
            }
            return value.floatValue
        }
        set {
            var attText:NSMutableAttributedString
            
            if let attributedText = attributedText {
                attText = NSMutableAttributedString(attributedString: attributedText)
            } else if let text = text {
                attText = NSMutableAttributedString(string: text)
            } else {
                attText = NSMutableAttributedString(string: "")
            }
            
            let range = NSMakeRange(0, attText.length)
            attText.addAttribute(NSKernAttributeName, value: NSNumber(value: newValue), range: range)
            self.attributedText = attText
        }
    }
}
