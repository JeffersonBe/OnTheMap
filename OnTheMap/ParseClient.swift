//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation

extension OTMClient {

    func getLocations(completionHandler: (success: Bool, locations: [OTMLocation]?, errorString: String?) -> Void) {

        let urlString = OTMConstants.Constants.ParseBaseUrl
        let parameters = ["limit": 100, "order":"-updatedAt"]

        /* 2. Make the request */
        taskForGETMethod("Parse", urlString: urlString, parameters: parameters) { results, error in

                guard let results = results["results"] as? [[String:AnyObject]] else {
                    completionHandler(success: false, locations: nil, errorString: nil)
                    return
                }

                self.locations = OTMLocation.locationsFromResults(results)
                completionHandler(success: true, locations: self.locations, errorString: nil)
        }
    }

    func postLocations(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {

        let urlString = OTMConstants.Constants.ParseBaseUrl + "/\(uniqueKey)"
        let jsonBody: [String:AnyObject] = [
            OTMConstants.JSONBodyKeys.uniqueKey: uniqueKey,
            OTMConstants.JSONBodyKeys.firstName: userFirstName,
            OTMConstants.JSONBodyKeys.lastName: userLastName,
            OTMConstants.JSONBodyKeys.mapString: mapString,
            OTMConstants.JSONBodyKeys.mediaURL: mediaURL,
            OTMConstants.JSONBodyKeys.latitude: latitude,
            OTMConstants.JSONBodyKeys.longitude: longitude
        ]


        taskForPOSTMethod("Parse", HTTPMethod: "POST", urlString: urlString, parameters: ["":""], jsonBody: jsonBody) { results, error in

            guard results["createdAt"] != nil else {
                completionHandler(success: false, errorString: nil)
                return
            }
            completionHandler(success: true, errorString: nil)

        }
    }

    func updateLocations(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {

        let urlString = OTMConstants.Constants.ParseBaseUrl + "/\(objectId)"
        let jsonBody: [String:AnyObject] = [
            OTMConstants.JSONBodyKeys.uniqueKey: uniqueKey,
            OTMConstants.JSONBodyKeys.firstName: userFirstName,
            OTMConstants.JSONBodyKeys.lastName: userLastName,
            OTMConstants.JSONBodyKeys.mapString: mapString,
            OTMConstants.JSONBodyKeys.mediaURL: mediaURL,
            OTMConstants.JSONBodyKeys.latitude: latitude,
            OTMConstants.JSONBodyKeys.longitude: longitude
        ]


        taskForPOSTMethod("Parse", HTTPMethod: "PUT", urlString: urlString, parameters: ["":""], jsonBody: jsonBody) { results, error in

            guard results["updatedAt"] != nil else {
                completionHandler(success: false, errorString: nil)
                return
            }
            completionHandler(success: true, errorString: nil)

        }
    }

    func queryLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {

        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"

        // let parameters = ["where": ["uniqueKey":uniqueKey]]

        /* 2. Make the request */
        taskForGETMethod("Parse", urlString: urlString, parameters: ["":""]) { results, error in

            guard let results = results["results"] as? [[String:AnyObject]] else {
                completionHandler(success: false, errorString: nil)

                return
            }

            guard let objectId = results.first!["objectId"] as? String else {
                return
            }

            self.objectId = objectId
            completionHandler(success: true, errorString: nil)
        }
    }
}