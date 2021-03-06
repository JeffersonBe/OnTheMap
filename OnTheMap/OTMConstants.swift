//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation

class OTMConstants: NSObject {

    // MARK: Constants
    struct Constants {

        // MARK: API Key
        static let ParseApiKey: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        // MARK: URLs
        static let ParseBaseUrl : String = "https://api.parse.com/1/classes/StudentLocation"
        static let UdacityBaseUrl : String = "https://www.udacity.com/api"
    }

    // MARK: Methods
    struct Methods {

        // MARK: Account
        static let Account = "/users"

        // MARK: Authentication
        static let AuthenticationSessionNew = "/session"

        // MARK: Config
        static let Config = "configuration"

    }

    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }

    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let Query = "query"
    }

    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let facebookMobile = "facebook_mobile"
        static let accessToken = "access_token"
        static let uniqueKey = "uniqueKey"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
    }

    // MARK: JSON Response Keys
    struct JSONResponseKeys {

        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"

        // MARK: Authorization
        static let SessionID = "session_id"

        // MARK: Account
        static let UserID = "id"

        static let LocationsResult = "results"

        // JSON
        static let createdAt = "createdAt"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
    }

    struct AppCopy {
        static let emailRequired = "Please enter your email"
        static let passwordRequired = "Please enter your password"
        static let locationRequired = "Please enter a location"
        static let linkRequired = "Please enter a link to share"
        static let unableToLoadLocation = "Sorry, we're unable to load locations"
        static let unableToLogout = "Sorry, we're unable to log you out"
        static let overwriteLocation = "Overwrite your location?"
        static let dismiss = "Dismiss"
        static let overwrite = "Overwrite"
        static let cancel = "Cancel"
    }
}
