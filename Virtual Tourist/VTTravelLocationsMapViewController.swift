//
//  VTTravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/27/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit
import MapKit

class VTTravelLocationsMapViewController : UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()


        mapView.delegate = self
        restoreMapRegion()
    }

    @IBAction func addAPin(sender: AnyObject) {

    }


    // MARK: - Saving the Map region to restore state

    private func saveMapRegion() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(mapView.region.center.latitude, forKey: "centerLatitude")
        defaults.setObject(mapView.region.center.longitude, forKey: "centerLongitude")
        defaults.setObject(mapView.region.span.latitudeDelta, forKey: "latitudeDelta")
        defaults.setObject(mapView.region.span.longitudeDelta, forKey: "longitudeDelta")
    }

    private func restoreMapRegion() {
        let defaults = NSUserDefaults.standardUserDefaults()

        if let centerLatitude = defaults.objectForKey("centerLatitude") as? Double,
            let centerLongitude = defaults.objectForKey("centerLongitude") as? Double?,
            let latitudeDelta = defaults.objectForKey("latitudeDelta") as? Double?,
            let longitudeDelta = defaults.objectForKey("longitudeDelta") as? Double? {

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
//
//        func mapView(
    }
