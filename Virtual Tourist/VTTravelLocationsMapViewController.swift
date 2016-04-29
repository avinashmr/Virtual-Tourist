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

    var annotation: MKPointAnnotation!
    var pins = [Pin]()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var debugTextLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        restoreMapRegion()

        do {
            try fetchedResultsController.performFetch()
        } catch {}

        fetchedResultsController.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // Restore Pins
        retrievePinsFromCoreData()
    }

    // Mark: - IBAction

    // Long Press Action
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
            dispatch_async(dispatch_get_main_queue(), {
                self.savePinToCoreData(self.annotation)
            })
        }
    }

    // MARK: - Core Data

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Pin")

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "longitude", ascending: true)]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()

    // Saves Pin to Core Data when a Pin is dropped into the map.
    func savePinToCoreData(annotation: MKPointAnnotation!) {
        if let newAnnotation = annotation {
            print(newAnnotation.coordinate.latitude)
            print(newAnnotation.coordinate.longitude)
//
//
//            let city = CLGeocoder()
//            var cityName: String?
//
//            city.reverseGeocodeLocation(CLLocation(latitude: newAnnotation.coordinate.latitude, longitude: newAnnotation.coordinate.longitude)) { (placemark, error) in
//                if (error == nil) {
//                    print(placemark![0].locality)
//                    let cityName = placemark![0].locality
//                } else {
//                    cityName = nil
//                }
//            }

            let dictionary: [String:AnyObject] = [
                Pin.Keys.Latitude   : newAnnotation.coordinate.latitude,
                Pin.Keys.Longitude  : newAnnotation.coordinate.longitude,
            ]

            let _ = Pin(dictionary: dictionary, context: sharedContext)

            CoreDataStackManager.sharedInstance().saveContext()
            print("pincdsave")
        }
    }

    func retrievePinsFromCoreData() {

        let data = fetchedResultsController.sections![0]

        // Confusing IF statement translation: Is the number of objects not empty?
        if !(data.objects?.isEmpty)! {
            pins = data.objects as! [Pin]
            for p in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: p.latitude, longitude: p.longitude)
                mapView.addAnnotation(annotation)
            }
            debugTextLabel.text = "restored"
        }
    }

    // MARK: - Map Region Save/Restore

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
