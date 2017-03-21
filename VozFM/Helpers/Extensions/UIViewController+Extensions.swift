//
//  UIViewController+Extensions.swift
//  LapzeroTimer
//
//  Created by Victor on 9/22/16.
//  Copyright © 2016 Bananaapps. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension UIViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message:message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{ (ACTION :UIAlertAction!)in
            debugPrint("User click Ok button")
        }))
        alert.view.tintColor = UIColor.appMainColor()
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertUnderDevelopment() -> Any {
        let alert = UIAlertController(title: "Under development", message:"!!!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:nil))
        self.present(alert, animated: true, completion: nil)
        return "just to generate warning for this function"
    }
}

extension UIViewController {
    
    func presentActivityShareMenu(activityItems: [Any], sourceView: UIView) {
        let shareVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        shareVC.popoverPresentationController?.sourceView = sourceView
        self.present(shareVC, animated: true, completion: nil)
    }
}
