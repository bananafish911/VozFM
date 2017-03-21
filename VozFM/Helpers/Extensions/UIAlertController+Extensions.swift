
//**********************************************************************
//
//                      Custom extensions pack
//
//                       Created by Victor D.
//          Copyright © 2017 Bananaapps. All rights reserved.
//
//**********************************************************************

import Foundation
import UIKit

extension UIAlertController {
    
    class func okayAlert(title: String?, message: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alertController
    }
    
    /// Presents on current visible ViewController (keyWindow -> rootViewController)
    func presentOnAppRootVC() {
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        DispatchQueue.main.async {
            rootViewController?.present(self, animated: true, completion: nil)
        }
    }
}
