//
//  VTPhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/29/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit
import MapKit

class VTPhotoAlbumViewController: UIViewController, MKMapViewDelegate {

    // MARK: - IBOutlets
//    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var albumNavigationController: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var collectionView: UICollectionView!

    // MARK: - Variables
    
    var annotationView: MKAnnotationView? = nil
    var oldMapView: MKMapView? = nil
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.setRegion((oldMapView?.region)!, animated: false)
//        setupMapAndPin()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)



    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        setupMapAndPin()
    }

    private func setupMapAndPin() {

        let latitudeDelta = (oldMapView?.region.span.latitudeDelta)! * 0.05
        let longitudeDelta = (oldMapView?.region.span.longitudeDelta)! * 0.05
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)

        let center = annotationView?.annotation?.coordinate
        let region = MKCoordinateRegion(center: center!, span: span)
        mapView.setRegion(region, animated: true)

        mapView.addAnnotation((annotationView?.annotation)!)

        let city = CLGeocoder()

        // Reverse search Latitude and Longitude to find City Name and set the Navigation controller title
        // TODO: Do this better so the navigation controller doesn't refresh the name
        self.albumNavigationController.title = "Photos"
        city.reverseGeocodeLocation(CLLocation(latitude: (center?.latitude)!, longitude: (center?.longitude)!)) { (placemark, error) in
            if (error == nil) {
                print(placemark![0])
                let cityName: String = placemark![0].areasOfInterest![0]
                if !cityName.isEmpty {
                    self.albumNavigationController.title = cityName + " Photos"
                }

            }
        }

    }

}
