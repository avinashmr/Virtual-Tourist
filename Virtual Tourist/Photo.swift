//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/28/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {

    struct Keys {
        static let ImagePathURL = "imagePathURL"
//        static let Index = "Index"
        static let LocalFileURL = "localFileURL"
    }

    @NSManaged var imagePathURL: String
    @NSManaged var localFileURL: String
    @NSManaged var location: Pin

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(imageURL: String, pin: Pin, context: NSManagedObjectContext) {

        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Dictionary
        self.imagePathURL = imageURL

    }

    var flickrImage: UIImage? {

        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(localFileURL)
        }

        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: localFileURL)
        }
    }


}
