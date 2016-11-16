//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Marc O'Neill on 08/11/2016.
//  Copyright © 2016 marcondev. All rights reserved.
//

import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView?
    
    var photo: Photo! {
        didSet{
            updatePhotoSelectionCount(photo)
        }
    }
    
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImageForPhoto(photo) {
            (result) -> Void in
            switch result {
            case let .Success(image):
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.imageView?.image = image
                }
            case let .Failure(error):
                print("Error fetching image: \(error)")
            }
        }
    }
    
    func updatePhotoSelectionCount(photo: Photo) {
        var count = photo.selectionCount.intValue
        count += 1
        photo.selectionCount = NSNumber(integer: Int(count))
        
        do {
            try self.store.coreDataStack.saveChanges()
        } catch let error {
            print("Error saving core data: \(error)")
        }
        
        navigationItem.title = "\(photo.title) : \(count) views"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTags" {
            let navController = segue.destinationViewController as! UINavigationController
            let tagController = navController.topViewController as! TagsViewController
            tagController.store = store
            tagController.photo = photo
        }
    }
    
    
}
