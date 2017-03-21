
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

extension UIApplication {
    
    // universal OpenURL method
    func openURLSafely(_ url: URL) {
        if self.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                self.open(url, options: [:], completionHandler: nil)
            } else {
                self.openURL(url)
            }
        }
    }
    
    func appVersionInfoString() -> String {
        let appDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? ""
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return appDisplayName + " version " + appVersion + " build " + appBuildVersion
    }
}
