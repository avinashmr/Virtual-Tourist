//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/28/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject {

    @NSManaged var annotation: MKPointAnnotation
    @NSManaged var photos: [Photo]

    // Standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    init(annotation: MKPointAnnotation, context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!

        super.init(entity: entity,insertIntoManagedObjectContext: context)

        self.annotation = annotation
    }

    convenience init(insertIntoMangedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)

        annotation = MKPointAnnotation()
    }
}
