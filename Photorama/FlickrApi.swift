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

struct FlickrApi {
    
    private static let baseUrlString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    private static func flickrUrl(method: Method, parameters: [String:String]?) -> NSURL {
        
        let components = NSURLComponents(string: baseUrlString)
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

        components!.queryItems = queryItems
        return (components?.URL!)!
    }
    
    static func recentPhotosUrl() -> NSURL {
        return flickrUrl(Method.RecentPhotos, parameters: ["extras":"url_h,date_taken"])
    }
    
}