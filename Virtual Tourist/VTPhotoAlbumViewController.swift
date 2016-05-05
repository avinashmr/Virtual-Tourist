//
//  VTPhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/29/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class VTPhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {


    internal enum UIState {
        case NoImages
    }

    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()

    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var albumNavigationController: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - Variables
    
    var annotationView: MKAnnotationView? = nil
    var oldMapView: MKMapView? = nil
    var pin: Pin!

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.setRegion((oldMapView?.region)!, animated: false)

        pin.coordinate.latitude = 12.972081
        pin.coordinate.longitude = 77.593324

        collectionView.delegate = self
        collectionView.dataSource = self

        do {
            try fetchedResultsController.performFetch()
        } catch {}

        fetchedResultsController.delegate = self

        if fetchedResultsController.fetchedObjects?.count == 0 {
            setupUI(.NoImages)

        }
        getPhotoCollection()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        setupMapAndPin()
    }

    private func setupUI(state: UIState) {
        switch state {
        case .NoImages:
            print("no images")
        }
    }

    // Layout the collection view

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }

    // MARK: - Core Data Convenience

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }


    // Mark: - Fetched Results Controller

    lazy var fetchedResultsController: NSFetchedResultsController = {

        let fetchRequest = NSFetchRequest(entityName: "Photo")

        fetchRequest.sortDescriptors = [/*NSSortDescriptor(key: "title", ascending: true)*/]
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin!);

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.sharedContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        return fetchedResultsController
        
    }()

    func getPhotoCollection() {

        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
        CoreDataStackManager.sharedInstance().saveContext()

        FlickrClient.sharedInstance().searchByLatLon(pin!) { (success, error) in
            if let error = error {
                print("error in getPhotoCollection")
            } else if success {
                dispatch_async(dispatch_get_main_queue(), {
                    print("success photos")
                    CoreDataStackManager.sharedInstance().saveContext()
                })
            }
        }
    }

    // MARK: - Configure Cell

    func configureCell(cell: VTPhotoCell, photo: Photo, atIndexPath indexPath: NSIndexPath) {

        var image: UIImage

        if photo.flickrImage != nil {
            image = photo.flickrImage!
            cell.imageView.image = image
        } else {
            let task = FlickrClient.sharedInstance().taskForIMAGE(photo.imagePathURL, completionHandler: { (imageData, error) in
                if let error = error {
                    print("flickr download error")
                } else if let imageData = imageData {
                    let image = UIImage(data: imageData)

                    photo.flickrImage = image

                    dispatch_async(dispatch_get_main_queue()) {
                        cell.imageView.image = image
                    }
                }
            })
        }


        if let _ = selectedIndexes.indexOf(indexPath) {
            cell.imageView.alpha = 0.05
        } else {
            cell.imageView.alpha = 1.0
        }

    }


    //MARK: - Private Functions
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
        // TODO: Do this better so the navigation controller doesn't refresh the name until reverseGeocode is done
        self.albumNavigationController.title = "Photos"
        city.reverseGeocodeLocation(CLLocation(latitude: (center?.latitude)!, longitude: (center?.longitude)!)) { (placemark, error) in
            if (error == nil) {
                let cityName: String = placemark![0].locality!
                if !cityName.isEmpty {
                    self.albumNavigationController.title = cityName + " Photos"
                }
            }
        }
    }
}

extension VTPhotoAlbumViewController: UICollectionViewDelegate {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]

        // print("number Of Cells: \(sectionInfo.numberOfObjects)")
        return sectionInfo.numberOfObjects
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VTPhotoCell", forIndexPath: indexPath) as! VTPhotoCell

        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo



        self.configureCell(cell, photo: photo, atIndexPath: indexPath)

        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! VTPhotoCell

        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }

        // Then reconfigure the cell
//        configureCell(cell, atIndexPath: indexPath)

        // And update the buttom button
//        updateBottomButton()
    }

}

// MARK: - Fetched Results Controller Delegate
extension VTPhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    // MARK: - Fetched Results Controller Delegate

    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()

//        print("in controllerWillChangeContent")
    }

    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the incex paths into the three arrays.
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {

        switch type{

        case .Insert:
            // print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .Delete:
            // print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            // print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            // print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }


    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {

//        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")

        collectionView.performBatchUpdates({() -> Void in

            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }

            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }

            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }

            }, completion: nil)
    }

}
