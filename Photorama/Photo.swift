//
//  Photo.swift
//  Photorama
//
//  Created by Marc O'Neill on 09/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import UIKit
import CoreData


class Photo: NSManagedObject {

    var image: UIImage?
    
    override func awakeFromInsert() {
        super.awakeFromInsert()
        // Give the properties their initial values
        title = ""
        photoId = ""
        photoKey = NSUUID().UUIDString
        remoteURL = NSURL()
        dateTaken = NSDate()
    }
}
