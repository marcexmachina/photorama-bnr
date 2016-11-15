//
//  PhotoStore.swift
//  Photorama
//
//  Created by Marc O'Neill on 02/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import UIKit
import CoreData

enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum PhotoError: ErrorType {
    case ImageCreationError
}

class PhotoStore {
    
    let coreDataStack = CoreDataStack(modelName: "Photorama")
    let imageStore = ImageStore()
    
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    //Function returns array of Photos if successful, otherwise returns an error
    func fetchRecentPhotos(completion completion: (PhotosResult) -> Void) {
        let url = FlickrApi.recentPhotosUrl()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
        
            var result = self.processRecentPhotosRequest(data: data, error: error)
            
            if case let .Success(photos) = result {
                let mainQueueContext = self.coreDataStack.mainQueueContext
                mainQueueContext.performBlockAndWait() {
                    try! mainQueueContext.obtainPermanentIDsForObjects(photos)
                }
                let objectIDs = photos.map{$0.objectID}
                let predicate = NSPredicate(format: "self IN %@", objectIDs)
                let sortByDateTaken = NSSortDescriptor(key: "dateTaken", ascending: true)
                
                do {
                    try self.coreDataStack.saveChanges()
                    let mainQueuePhotos = try self.fetchMainQueuePhotos(predicate: predicate, sortDescriptors: [sortByDateTaken])
                    result = .Success(mainQueuePhotos)
                }
                catch let error {
                    result = .Failure(error)
                }
            }
            
            completion(result)
        }
        task.resume()
    }
    
    func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let jsonData = data else {
            return PhotosResult.Failure(error!)
        }
        return FlickrApi.photosFromJSONData(jsonData, inContext: self.coreDataStack.mainQueueContext)
    }
    
    //Function to fetch image from server
    func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
        
        //Return image if it already exists
        let photoKey = photo.photoKey
        if let image = self.imageStore.imageForKey(photoKey) {
            photo.image = image
            completion(.Success(image))
            return
        }
        
        let photoURL = photo.remoteURL
        let request = NSURLRequest(URL: photoURL)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
            let result = self.processImageRequest(data, error: error)
            // Commenting this out as it's clogging console
//            if let httpResponse = response as? NSHTTPURLResponse {
//                print("Status Code: \(httpResponse.statusCode)")
//                print("Header Fields: \(httpResponse.allHeaderFields)")
//            }
            if case let .Success(image) = result {
                photo.image = image
                self.imageStore.setImage(image, forKey: photoKey)
            }
            completion(result)
        }
        task.resume()
    }
    
    func processImageRequest(data: NSData?, error: NSError?) -> ImageResult {
        guard let
            imageData = data,
            image = UIImage(data: imageData) else {
                
                //Couldn't create an image
                if data == nil {
                    return .Failure(error!)
                } else {
                    return .Failure(PhotoError.ImageCreationError)
                }
        }
        return .Success(image)
    }
    
    //Fetch photos from main queue context
    func fetchMainQueuePhotos(predicate predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Photo] {
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        var mainQueuePhotos: [Photo]?
        var fetchRequestError: ErrorType?
        mainQueueContext.performBlockAndWait() {
            do {
                mainQueuePhotos = try mainQueueContext.executeFetchRequest(fetchRequest) as? [Photo]
            }
            catch let error {
                fetchRequestError = error
            }
        }
        
        guard let photos = mainQueuePhotos else {
            throw fetchRequestError!
        }
        
        return photos
    }
    
    
    
    
    
    
    
}
