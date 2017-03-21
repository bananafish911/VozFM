//
//  Track.swift
//  VozFM
//
//  Created by Victor on 10/29/16.
//  Copyright © 2016 Victor. All rights reserved.
//

import Foundation
import UIKit

import Kingfisher
import SwiftyJSON

import RxSwift
import RxCocoa

class Track {
    
    let title: String!
    let artist: String!
    let timeStamp: Int!
    let artworkURL: String!
    let image: Variable<UIImage> = Variable(#imageLiteral(resourceName: "albumArtPlaceholder"))
    
    // MARK: -
    
    init(json: JSON) {
        title = json["title"].string ?? ""
        artist = json["artist"].string ?? ""
        timeStamp = json["time"].intValue
        artworkURL = json["image"].string ?? ""
        
        debugPrint("Init track: \(self)")
        
        loadImageAsync()
    }
}

extension Track: Hashable {
    
    // MARK: Hashable
    
    var hashValue: Int {
        return self.timeStamp.hashValue
    }
    
    static func == (lhs: Track, rhs: Track) -> Bool {
        return lhs.timeStamp == rhs.timeStamp
    }
}

extension Track: CustomStringConvertible {
    var description: String {
        return "\(title!) \(artist!) \(timeStamp!) \(artworkURL!)"
    }
}

extension Track: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(title!) \(artist!) \(timeStamp!) \(artworkURL!)"
    }
}

fileprivate extension Track {
    
    // MARK: - Image loader
    
    func loadImageAsync() {
        
        // don't use server response "nocover.png"
        if artworkURL.contains("nocover") {
            return
        }
        
        // generate utf8 url
        guard let imageLink = artworkURL.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let url = URL(string: imageLink) else {
                debugPrint("load image failed: wrong url")
                return
        }
        
        ImageDownloader.default.downloadImage(with: url, options: [], progressBlock: nil) { [weak self] (image, err, url, data) in
            if let image = image {
                self?.image.value = image
            } else {
                debugPrint("ImageDownloader.default.downloadImage: can't load logo for url \(url), error \(err)")
            }
        }
    }
}
