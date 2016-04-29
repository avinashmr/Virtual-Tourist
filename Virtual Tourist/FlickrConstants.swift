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
        static let ApiKey = "3c534dc71a2f9d28e9594e5773abcc93"
        static let BaseUrl = "http://api.themoviedb.org/3/"
        static let BaseUrlSSL = "https://api.themoviedb.org/3/"
        static let BaseImageUrl = "http://image.tmdb.org/t/p/"
    }

    struct Resources {


    }

    struct Keys {
        static let ID = "id"
        static let ErrorStatusMessage = "status_message"
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
    }

    struct Values {

    }
}