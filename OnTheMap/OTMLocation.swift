//
//  OTMLocation.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation

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
        createdAt = dictionary[OTMConstants.JSONResponseKeys.createdAt] as! String
        firstName = dictionary[OTMConstants.JSONResponseKeys.firstName] as! String
        lastName = dictionary[OTMConstants.JSONResponseKeys.lastName] as! String
        latitude = dictionary[OTMConstants.JSONResponseKeys.latitude] as! Double
        longitude = dictionary[OTMConstants.JSONResponseKeys.longitude] as! Double
        mapString = dictionary[OTMConstants.JSONResponseKeys.mapString] as! String
        mediaURL = dictionary[OTMConstants.JSONResponseKeys.mediaURL] as! String
        objectId = dictionary[OTMConstants.JSONResponseKeys.objectId] as! String
        uniqueKey = dictionary[OTMConstants.JSONResponseKeys.uniqueKey] as! String
        updatedAt = dictionary[OTMConstants.JSONResponseKeys.updatedAt] as! String
    }
}
