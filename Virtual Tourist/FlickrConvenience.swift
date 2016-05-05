//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 5/3/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import MapKit
import CoreData

extension FlickrClient {

    // Search By Latitude and Longitude and then search again with a random Page Number
    func searchByLatLon(pin: Pin, completionHandler: (success: Bool, error: NSError?) -> Void) {

        let parameters: [String: AnyObject] = [
            FlickrParameterKeys.Method:     FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.APIKey:     FlickrParameterValues.APIKey, // Move this to FlickrClient
            FlickrParameterKeys.Latitude:   pin.latitude,
            FlickrParameterKeys.Longitude:  pin.longitude,
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.Extras:     FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format:     FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.PhotosPerPage: FlickrParameterValues.PhotosPerPage
        ]

        taskForGET(parameters) { (result, error) in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let photosDictionary = result.valueForKey(FlickrResponseKeys.Photos) as? [String:AnyObject],
                          numberOfPages = photosDictionary[FlickrResponseKeys.Pages] as? Int {
//                    print("Pages of Search: \(numberOfPages)")

                    // Find a Random Page to search in
                    let pageLimit = min(numberOfPages, Constants.PageLimit)
                    let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
//                    print("found number of pages, now starting another search on page \(randomPage)")

                    // Perform request again with Random Page
                    self.searchByLatLon(pin, parameters: parameters, pageNumber: randomPage, completionHandler: { (success, error) in
                        if let error = error {
                            completionHandler(success: false, error: error)
                        } else {
//                            print("done 2nd search success")
                            completionHandler(success: true, error: nil)
                        }
                    })
                }
            }
        }
    }

    // Search By Latitude, Longitude, and a Page Number then download those photos
    func searchByLatLon(pin: Pin, parameters: [String:AnyObject], pageNumber: Int,
                        completionHandler: (success: Bool, error: NSError?) -> Void) {

        var parametersWithPage = parameters
        parametersWithPage[FlickrParameterKeys.Page] = pageNumber

//        print("here in 2nd search")

        taskForGET(parametersWithPage) { (result, error) in
            if let error = error {
                completionHandler(success: false, error: error)
            } else {
                if let photosDictionary = result.valueForKey(FlickrResponseKeys.Photos) as? [String:AnyObject],
                            photosArray = photosDictionary[FlickrResponseKeys.Photo] as? [[String:AnyObject]] {

                    for photo in photosArray {
                        let imageURL = photo[FlickrParameterValues.MediumURL] as! String
                        // Create a new Photo object
                        let newPhoto = Photo(imageURL: imageURL, pin: pin, context: self.sharedContext)

                        CoreDataStackManager.sharedInstance().saveContext()
                    }
                }
            }
        }
    }



    // Download the Photo given the URL
//    func downloadPhoto(photo: Photo, completionHandler: (success: Bool, error: NSError?) -> Void) {
//
//        let url = photo.imagePathURL
//
//        taskForURL(url) { (result, error) in
//            if let error = error {
//                completionHandler(success: false, error: error)
//            } else {
//                if let result = result {
//                    /* Clean up */
//                    let fileName = NSURL.fileURLWithPath(url).lastPathComponent!
//                    let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
//                    let pathArray = [dirPath, fileName]
//                    let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
//                    print(fileURL)
//
//                    NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: result as? NSData, attributes: nil)
//
//                    photo.localFileURL = fileURL.path!
//
//                    completionHandler(success: true, error: nil)
//                    /* Clean up */
//                }
//            }
//        }
//    }

    
    // MARK: - Core Data

    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }

    // MARK: - Shared Image Cache

    struct Caches {
        static let imageCache = ImageCache()
    }
}

