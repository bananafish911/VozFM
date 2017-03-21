//
//  Macros.swift
//  JustRadio
//
//  Created by Victor on 1/5/17.
//  Copyright © 2017 Bananaapps. All rights reserved.
//

import Foundation
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

struct Storyboards {
    static let main = UIStoryboard(name: "Main", bundle: nil)
}

struct Queues {
    static let main = DispatchQueue.main
    static let utility = DispatchQueue.global(qos: .utility)
    static let background = DispatchQueue.global(qos: .background)
    //    //memo:
    //    * DISPATCH_QUEUE_PRIORITY_HIGH:         .userInitiated
    //    * DISPATCH_QUEUE_PRIORITY_DEFAULT:      .default
    //    * DISPATCH_QUEUE_PRIORITY_LOW:          .utility
    //    * DISPATCH_QUEUE_PRIORITY_BACKGROUND:   .background
}

// MARK: - Macro:

public enum TaskState {
    case pending, progress, success, failed
}

public func toString(_ cls: AnyClass) -> String {
    return String(describing: cls)
}

public func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}
