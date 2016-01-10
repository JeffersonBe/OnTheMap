//
//  OTMLocation.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

struct OTMLocation {

    // MARK: Properties

    var createdAt = ""
    var firstName = ""
    var lastName = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var mapString = ""
    var mediaURL = ""
    var objectId = ""
    var uniqueKey = ""
    var updatedAt = ""

    // MARK: Initializers

    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        createdAt = dictionary[UdacityClient.JSONResponseKeys.createdAt] as! String
        firstName = dictionary[UdacityClient.JSONResponseKeys.firstName] as! String
        lastName = dictionary[UdacityClient.JSONResponseKeys.lastName] as! String
        latitude = dictionary[UdacityClient.JSONResponseKeys.latitude] as! Double
        longitude = dictionary[UdacityClient.JSONResponseKeys.longitude] as! Double
        mapString = dictionary[UdacityClient.JSONResponseKeys.mapString] as! String
        mediaURL = dictionary[UdacityClient.JSONResponseKeys.mediaURL] as! String
        objectId = dictionary[UdacityClient.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[UdacityClient.JSONResponseKeys.uniqueKey] as! String
        updatedAt = dictionary[UdacityClient.JSONResponseKeys.updatedAt] as! String
    }

    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func locationsFromResults(results: [[String : AnyObject]]) -> [OTMLocation] {
        var locations = [OTMLocation]()
        for result in results {
            locations.append(OTMLocation(dictionary: result))
        }
        return locations
    }
}
