//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Marc O'Neill on 02/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        store.fetchRecentPhotos() {
            (photosResult) -> Void in
            switch photosResult {
            case let .Success(photos):
                print("Successfully found \(photos.count) photos")
            case let .Failure(error):
                print("Error fetching recent photos: \(error)")
            }
        }
    }
    
}
