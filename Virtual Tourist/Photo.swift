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
        static let ImagePath = "imagePath"
        static let Index = "Index"
    }

    @NSManaged var imagePath: String
    @NSManaged var index: Int64
    @NSManaged var pins: Pin?

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {

        // Core Data
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)

        // Dictionary
        imagePath = dictionary[Keys.ImagePath] as! String
        index = dictionary[Keys.Index] as! Int64
    }

    var posterImage: UIImage? {

        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(imagePath)
        }

        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: imagePath)
        }
    }


}
