//
//  Photo.swift
//  Photorama
//
//  Created by Marc O'Neill on 02/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import Foundation

class Photo {
    
    var title: String
    var remoteUrl: NSURL
    var photoID: String
    var dateTaken: NSDate
    
    init(title: String, remoteUrl: NSURL, photoID: String, dateTaken: NSDate) {
        self.title = title
        self.remoteUrl = remoteUrl
        self.photoID = photoID
        self.dateTaken = dateTaken
    }
}
