//
//  VTTravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/27/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VTTravelLocationsMapViewController : UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        restoreMapRegion()

        // Restore Pins
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {}
    }

    // Mark: - IBAction

    // Long Press Action

    var annotation: MKPointAnnotation!

    @IBAction func handleLongPress(gesture: UILongPressGestureRecognizer) {

        let touchpoint = gesture.locationInView(mapView)
        let touchMapCoordinate = mapView.convertPoint(touchpoint, toCoordinateFromView: mapView)

        if gesture.state == .Began {
            annotation = MKPointAnnotation()
            annotation.coordinate = touchMapCoordinate
            mapView.addAnnotation(annotation)
        }

        if gesture.state == .Changed {
            annotation.coordinate = touchMapCoordinate
        }

        if gesture.state == .Ended {
            let city = CLGeocoder()
            city.reverseGeocodeLocation(CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)) { (placemark, error) in
                if (error == nil) {
                    print(placemark![0].locality)
                }
            }
        }
    }

    // MARK: - Core Data

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Pin")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()

    // MARK: - Save Map Region

    // Saves the Map region to restore state using NSUserDefaults
    private func saveMapRegion() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(mapView.region.center.latitude,      forKey: "centerLatitude")
        defaults.setObject(mapView.region.center.longitude,     forKey: "centerLongitude")
        defaults.setObject(mapView.region.span.latitudeDelta,   forKey: "latitudeDelta")
        defaults.setObject(mapView.region.span.longitudeDelta,  forKey: "longitudeDelta")
    }

    // Restores Map Region
    private func restoreMapRegion() {
        let defaults = NSUserDefaults.standardUserDefaults()

        if let centerLatitude   = defaults.objectForKey("centerLatitude")   as? Double,
            let centerLongitude = defaults.objectForKey("centerLongitude")  as? Double?,
            let latitudeDelta   = defaults.objectForKey("latitudeDelta")    as? Double?,
            let longitudeDelta  = defaults.objectForKey("longitudeDelta")   as? Double? {

            mapView.region = MKCoordinateRegionMake(
                CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude!),
                MKCoordinateSpan(latitudeDelta: latitudeDelta!, longitudeDelta: longitudeDelta!)
            )
        }
    }
}

    // MARK: - MKMapViewDelegate Functions

    extension VTTravelLocationsMapViewController: MKMapViewDelegate {

        func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            saveMapRegion()
        }

        // Source from: http://stackoverflow.com/questions/6808876/how-do-i-animate-mkannotationview-drop
        func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {

            for view in views {

                // Check if current annotation is inside visible map rect, else go to next one
                let point =  MKMapPointForCoordinate(view.annotation!.coordinate)
                if !MKMapRectContainsPoint(self.mapView.visibleMapRect, point) {
                    continue
                }

                let frame = view.frame

                // Move annotation out of view
                view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y - self.view.frame.size.height, view.frame.size.width, view.frame.size.height)

                // Animate drop
                UIView.animateWithDuration(0.5, delay: 0.04 * Double(views.indexOf(view)!), options: .CurveLinear, animations: {
                    view.frame = frame
                    }, completion: nil)
            }
        }



    }
