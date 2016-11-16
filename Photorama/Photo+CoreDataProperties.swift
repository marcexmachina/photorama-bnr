//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Marc O'Neill on 16/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var dateTaken: NSDate
    @NSManaged var photoId: String
    @NSManaged var photoKey: String
    @NSManaged var remoteURL: NSURL
    @NSManaged var title: String
    @NSManaged var selectionCount: NSNumber
    @NSManaged var tags: Set<NSManagedObject>
}
