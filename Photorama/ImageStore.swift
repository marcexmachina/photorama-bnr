//
//  ImageStore.swift
//  Homepwner
//
//  Created by Marc O'Neill on 05/09/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import UIKit

class ImageStore {
    
    let cache = NSCache()
    
    func setImage(image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key)
        
        //create full URL for image
        let imageUrl = imageUrlForKey(key)
        
        //turn image into JPEG representation
        if let data = UIImagePNGRepresentation(image) {
            //write data to URL
            data.writeToURL(imageUrl, atomically: true)
        }
        
        
    }
    
    //function to load image
    // - Check cache for image with key and return if it exists
    // - otherwise create image url, get image from disk at url
    // - set object in cache for key and return image
    func imageForKey(key: String) -> UIImage? {
        if let existingImage = cache.objectForKey(key) as? UIImage{
            return existingImage
        }
        
        let imageUrl = imageUrlForKey(key)
        guard let imageFromDisk = UIImage(contentsOfFile: imageUrl.path!) else {
            return nil
        }
        cache.setObject(imageFromDisk, forKey: key)
        return imageFromDisk
    }
    
    func deleteImageForKey(key: String) {
        cache.removeObjectForKey(key)
        
        let imageUrl = imageUrlForKey(key)
        do {
            try NSFileManager.defaultManager().removeItemAtURL(imageUrl)
        }
        catch let deleteError{
            print("Error removing image from disk: \(deleteError)")
        }
    }
    
    //function to create URL for an image, by appending image key to document directory URL
    func imageUrlForKey(key: String) -> NSURL{
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory  = documentsDirectories.first!
        return documentDirectory.URLByAppendingPathComponent(key)
    }
    
    
    
    
}
