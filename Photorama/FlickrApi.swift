//
//  FlickrApi.swift
//  Photorama
//
//  Created by Marc O'Neill on 02/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import Foundation

enum Method: String {
    case RecentPhotos = "flickr.photos.getRecent"
}

enum PhotosResult {
    case Success([Photo])
    case Failure(ErrorType)
}

enum FlickrError: ErrorType {
    case InvalidJsonData
}

struct FlickrApi {
    
    private static let baseUrlString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    private static let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    private static func flickrUrl(method: Method, parameters: [String:String]?) -> NSURL {
        
        //Need to force unwrap the string
        let components = NSURLComponents(string: baseUrlString)!
        var queryItems = [NSURLQueryItem]()
        
        let baseParams = [
            "method" : method.rawValue,
            "format" : "json",
            "nojsoncallback" : "1",
            "api_key" : apiKey
        ]
        
        for (key, value) in baseParams {
            let item = NSURLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let params = parameters {
            for (key, value) in params {
                let item = NSURLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }

        components.queryItems = queryItems
        return components.URL!
    }
    
    static func recentPhotosUrl() -> NSURL {
        return flickrUrl(Method.RecentPhotos, parameters: ["extras":"url_h,date_taken"])
    }
    
    static func photosFromJSONData(data: NSData) -> PhotosResult {
        do {
            let jsonObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            
            guard let jsonDictionary = jsonObject as? [NSObject:AnyObject],
            photos = jsonDictionary["photos"] as? [String:AnyObject],
            photosArray = photos["photo"] as? [[String:AnyObject]] else {
                //The json structure doesn't match our expectation
                return .Failure(FlickrError.InvalidJsonData)
            }
            
            var finalPhotos = [Photo]()
            for photoJSON in photosArray {
                if let photo = photoFromJSONObject(photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            
            if finalPhotos.count == 0 && photosArray.count > 0 {
                //We weren't able to parse any of the photos
                //Maybe the JSON format for photos has changed
                return .Failure(FlickrError.InvalidJsonData)
            }
            
            return .Success(finalPhotos)
            
        } catch let error {
            return .Failure(error)
        }
    }
    
    private static func photoFromJSONObject(json: [String : AnyObject]) -> Photo? {
        do {
            guard let
            photoID = json["id"] as? String,
            title = json["title"] as? String,
            dateString = json["datetaken"] as? String,
            photoURLString = json["url_h"] as? String,
            url = NSURL(string: photoURLString),
            dateTaken = dateFormatter.dateFromString(dateString) else {
                //Don't have enough info to form a photo
                return nil
            }
            return Photo(title: title, remoteUrl: url, photoID: photoID, dateTaken: dateTaken)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}