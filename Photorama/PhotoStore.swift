//
//  PhotoStore.swift
//  Photorama
//
//  Created by Marc O'Neill on 02/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import Foundation

class PhotoStore {
    
    let session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config)
    }()
    
    func fetchRecentPhotos() {
        let url = FlickrApi.recentPhotosUrl()
        let request = NSURLRequest(URL: url)
        let task = session.dataTaskWithRequest(request) {
            (data, response, error) -> Void in
        
            if let jsonData = data {
                if let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
                    print("\(jsonString)")
                }
            } else if let requestError = error {
                print("Error fetching recent photos: \(requestError)")
            } else {
                print("Unexpected error with the request")
            }
        }
        task.resume()
    }
    
}
