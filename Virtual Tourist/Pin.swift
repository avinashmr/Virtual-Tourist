//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/28/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import CoreData
import MapKit

class Pin: NSManagedObject, MKAnnotation {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]

    // Set/get created to conform to MKAnnotation Protocol
    var coordinate: CLLocationCoordinate2D {
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
    }

    // Standard Core Data init method.
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    // Initialize a Pin object by sending an Annotation
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {

        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!

        super.init(entity: entity,insertIntoManagedObjectContext: context)

        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}
