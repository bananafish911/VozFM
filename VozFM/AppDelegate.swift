//
//  AppDelegate.swift
//  VozFM
//
//  Created by Victor on 10/29/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

// FIXME: APNs
// FIXME: playerItemPlaybackStalled event (ply)
// FIXME: update smooch API key

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: - App lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.configureAppearence()
        
        // crash reporting
        Fabric.with([Crashlytics.self])
        
        // feedback module
        let smoochSettings = SKTSettings(appToken: Constants.smoochApiToken)
        smoochSettings.conversationAccentColor = UIColor.appMainColor()
        Smooch.initWith(smoochSettings)
        
        
        // MPNowPlayingInfoCenter
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        return true
    }
    
    // MARK: - Appearence
    
    fileprivate func configureAppearence() {
        // If you targeting iOS 9 - dont change this:
//        UIApplication.shared.setStatusBarStyle(.lightContent, animated: false)
        
        // Appearence proxies:
        
        // UINavigationBar
        // no shadow
        UINavigationBar.appearance().shadowImage = UIImage()
        // make it transparent
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().barTintColor = UIColor.clear
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // buttons color
        UINavigationBar.appearance().tintColor = UIColor.appMainColor()
        // title
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
    }
}
