
//**********************************************************************
//
//                      Custom extensions pack
//
//                       Created by Victor D.
//          Copyright © 2017 Bananaapps. All rights reserved.
//
//**********************************************************************

import Foundation
import AVFoundation

extension AVMetadataItem {
    
    /// stringValue: ISO-8859-1 → UTF-8
    var utf8String: String? {
        guard let data = stringValue?.data(using: String.Encoding.isoLatin1, allowLossyConversion: true) else {
            return nil
        }
        return String(data: data as Data, encoding: String.Encoding.utf8)
    }
}
