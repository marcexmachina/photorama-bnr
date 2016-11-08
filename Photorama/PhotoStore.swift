//
//  PhotoStore.swift
//  Photorama
//
//  Created by Marc O'Neill on 02/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import UIKit

enum ImageResult {
    case Success(UIImage)
    case Failure(ErrorType)
}

enum PhotoError: ErrorType {
    case ImageCreationError
}

class PhotoStore {
    
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
        
            let result = self.processRecentPhotosRequest(data: data, error: error)
            completion(result)
        }
        task.resume()
    }
    
    func processRecentPhotosRequest(data data: NSData?, error: NSError?) -> PhotosResult {
        guard let jsonData = data else {
            return PhotosResult.Failure(error!)
        }
        return FlickrApi.photosFromJSONData(jsonData)
    }
    
    //Function to fetch image from server
    func fetchImageForPhoto(photo: Photo, completion: (ImageResult) -> Void) {
        
        //Return image if it already exists
        if let image = photo.image {
            completion(.Success(image))
            return
        }
        
        let photoURL = photo.remoteUrl
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
    
    
    
    
    
    
    
    
    
}
