//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Avinash Mudivedu on 4/28/16.
//  Copyright © 2016 Avinash Mudivedu. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {

    typealias CompletionHander = (result: AnyObject!, error: NSError?) -> Void

    var session: NSURLSession
//
//    var config = Config.unarchivedInstance() ?? Config()

    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }


    // MARK: - All purpose task method for data

    func taskForGET(parameters: [String: AnyObject], completionHandler: CompletionHander) -> NSURLSessionDataTask {

        let request = NSMutableURLRequest(URL: flickrURLFromParameters(parameters))

//        print(flickrURLFromParameters(parameters))

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in

            if let error = downloadError {
                let newError = FlickrClient.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
//                print("Step 3 - taskForResource's completionHandler is invoked.")
                FlickrClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }

        task.resume()

        return task
    }

    // MARK: - All purpose task method for images

    func taskForIMAGE(imageURL: String, completionHandler: (imageData: NSData?, error: NSError?) ->  Void) -> NSURLSessionTask {

        let url = NSURL(string: imageURL)

//        print(url)

        let request = NSURLRequest(URL: url!)

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in

            if let error = downloadError {
                let newError = FlickrClient.errorForData(data, response: response, error: error)
                completionHandler(imageData: nil, error: newError)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }

        task.resume()
        
        return task
    }

//    func taskForURL(url: String, completionHandler: CompletionHander) -> Void {
//
//        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
//
//        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) in
//            if let error = downloadError {
//                let newError = FlickrClient.errorForData(data, response: response, error: error)
//                completionHandler(result: nil, error: newError)
//            } else {
//                completionHandler(result: data, error: nil)
//            }
//        }
//
//        task.resume()
//    }

    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> NSURL {

        let components = NSURLComponents()
        components.scheme =  Constants.APIScheme
        components.host = Constants.APIHost
        components.path = Constants.APIPath
        components.queryItems = [NSURLQueryItem]()

        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }

        return components.URL!
    }


    // MARK: - Helpers


    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error

    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {

        if data == nil {
            return error
        }

        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)

            if let parsedResult = parsedResult as? [String : AnyObject],
                status = parsedResult[FlickrResponseKeys.Status] as? String,
                errorMessage = parsedResult[FlickrResponseKeys.Message] as? String
            {
                if status == FlickrResponseValues.Fail {
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    return NSError(domain: "Flickr Error", code: 1, userInfo: userInfo)
                }
            }
        } catch _ {}
        return error
    }
    
    // Parsing the JSON

    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: CompletionHander) {
        var parsingError: NSError? = nil

        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }

        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
//            print("Step 4 - parseJSONWithCompletionHandler is invoked.")
            completionHandler(result: parsedResult, error: nil)
        }
    }

    // MARK: - Shared Instance

    class func sharedInstance() -> FlickrClient {

        struct Singleton {
            static var sharedInstance = FlickrClient()
        }

        return Singleton.sharedInstance
    }
}