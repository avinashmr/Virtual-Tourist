//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/28/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import Foundation

extension FlickrClient {

    struct Constants {
        // MARK: - URLs
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"

//        static let SearchBBoxHalfWidth = 1.0
//        static let SearchBBoxHalfHeight = 1.0
//        static let SearchLatRange = (-90.0, 90.0)
//        static let SearchLonRange = (-180.0, 180.0)
//

        static let PageLimit = 3


    }

    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let Page = "page"
        static let PhotosPerPage = "per_page"
    }

    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "7a5bd9fb55db09450a62720f77f19537" /* This is my API Key, remove when posting to GitHub */
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = 21
    }

    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Message = "message"

        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }

    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let Fail = "fail"
        static let OKStatus = "ok"
    }
}