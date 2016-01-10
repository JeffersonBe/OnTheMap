//
//  OTMConstants.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation

extension UdacityClient {

    // MARK: Constants
    struct Constants {

        // MARK: API Key
        static let ParseApiKey: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let RestApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        // MARK: URLs
        static let BaseUrl : String = "https://api.parse.com/1/classes/StudentLocation"
        static let AuthorizationURL : String = "https://www.udacity.com/api"
    }

    // MARK: Methods
    struct Methods {

        // MARK: Account
        static let Account = "users"

        // MARK: Authentication
        static let AuthenticationSessionNew = "/session"

        // MARK: Search
        static let SearchMovie = "search/movie"

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
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
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
    }
}
