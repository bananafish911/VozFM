
//**********************************************************************
//
//                      Custom extensions pack
//
//                       Created by Victor D.
//          Copyright © 2017 Bananaapps. All rights reserved.
//
//**********************************************************************

import Foundation

/// See more http://stackoverflow.com/a/30593673/4049469
extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
