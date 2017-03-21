
//**********************************************************************
//
//                      Custom extensions pack
//
//                       Created by Victor D.
//          Copyright © 2017 Bananaapps. All rights reserved.
//
//**********************************************************************

import Foundation

extension NotificationCenter {
    
    /// Posts notification using DispatchQueue.main.async
    ///
    /// - Parameters:
    ///   - name: Notification name
    ///   - userInfo: optional Sender
    ///   - userInfo: optional Dictionary
    func postOnMainQueue(_ name: Notification.Name, sender: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: name, object: sender, userInfo: userInfo)
        }
    }
    
    /// Adds an entry to the receiver’s dispatch table with a block to add to the queue.
    ///
    /// - Parameters:
    ///   - name: The name of the notification
    ///   - block: The block to be executed when the notification is received. The block is run synchronously on the posting thread.
    func addObserver(forName name: Notification.Name, block: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil, using: block)
    }
}
