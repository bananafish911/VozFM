//
//  Constants.swift
//  VozFM
//
//  Created by Victor on 10/29/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Constants

struct Constants {
    
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    struct Storyboards {
        static let main = UIStoryboard(name: "Main", bundle: nil)
    }
    
    struct Api {
        static let AudioStreamURL = URL(string: "http://eu.radioboss.fm/proxy/kekzuqf8e?mp=/stream")!
        struct RecentSongs {
            static let url = URL(string: "https://eu.radioboss.fm:2199/external/rpc.php")!
            static let params = [
                "m":"recenttracks.get",
                "username":"kekzuqf8e",
                "charset":"null",
                "since":"0",
                "mountpoint":"null",
                "rid":"kekzuqf8e",
                "_":"1458812223049",]
        }
    }
    
    // For aboutUS viewController
    struct Feedback {
        static let developerDisplayName = "Victor Dombrovskiy"
        static let developerURL = URL(string: "https://ua.linkedin.com/in/victor-dombrovskiy")!
        
        static let designerDisplayName = "Dizzzup"
        static let designerURL = URL(string: "https://www.weblancer.net/users/TSpell/")!
    }
    
    static let smoochApiToken = "bqllym4xy8aeybfh3y28eua5q"
}

// MARK: - Colors

extension UIColor {
    
    class func appMainColor() -> UIColor {
        return UIColor(hex: 0xE55D90)
    }
    
}


