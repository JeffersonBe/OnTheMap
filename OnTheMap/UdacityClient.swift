//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation

extension OTMClient {

    // MARK: - API Functions

    // Login to Udacity with user-supplied credentials
    func loginAndCreateSession(completionHandler: (success: Bool, errorString: String?) -> Void) {

        let urlString = OTMConstants.Constants.UdacityBaseUrl + OTMConstants.Methods.AuthenticationSessionNew
        let jsonBody : [String:AnyObject] = [
            OTMConstants.JSONBodyKeys.Udacity : [
                OTMConstants.JSONBodyKeys.Username: username,
                OTMConstants.JSONBodyKeys.Password: password,
            ]
        ]

        taskForPOSTMethod("Udacity", HTTPMethod: "POST", urlString: urlString, parameters: ["":""], jsonBody: jsonBody) { results, error in

            guard (error == nil) else {
                completionHandler(success: false, errorString: error!.localizedDescription)
                print("There was an error with your request: \(error)")
                return
            }

            guard let result = results["account"] as? NSDictionary else {
                completionHandler(success: false, errorString: "Wrong email or password")
                return
            }

            self.uniqueKey = result["key"] as! String
            self.getUserData()
            completionHandler(success: true, errorString: nil)
        }
    }

    // logout and destroy session
    func logoutAndDeleteSession(completionHandler: (success: Bool, errorString: String?) -> Void) {

        let urlString = OTMConstants.Constants.UdacityBaseUrl + OTMConstants.Methods.AuthenticationSessionNew

        taskForPOSTMethod("Udacity", HTTPMethod: "DELETE", urlString: urlString, parameters: ["":""], jsonBody: ["":""]) { JSONResult, error in

            guard (error == nil) else {
                completionHandler(success: false, errorString: error!.localizedDescription)
                print("There was an error with your request: \(error)")
                return
            }

            guard JSONResult["session"] != nil else {
                completionHandler(success: false, errorString: "Could not logout")
                return
            }
            completionHandler(success: true, errorString: nil)
        }
    }

    // get user first name and last name
    func getUserData() {

        let urlString =
        OTMConstants.Constants.UdacityBaseUrl
            + OTMConstants.Methods.Account
            + "/\(uniqueKey)"

        taskForGETMethod("Udacity", urlString: urlString, parameters: ["":""]) { result, error in

            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }

            guard let user = result["user"] as? NSDictionary else {
                print("Couldn't find the user")
                return
            }

            self.userFirstName = user["first_name"] as! String
            self.userLastName = user["last_name"] as! String
        }
    }

    func sessionWithFacebookAuthentication(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let urlString = OTMConstants.Constants.UdacityBaseUrl + OTMConstants.Methods.AuthenticationSessionNew

        let jsonBody : [String:AnyObject] = [
            OTMConstants.JSONBodyKeys.facebookMobile: [
                OTMConstants.JSONBodyKeys.accessToken: facebookAccessToken
            ]
        ]

        taskForPOSTMethod("Udacity", HTTPMethod: "POST", urlString: urlString, parameters: ["":""], jsonBody: jsonBody) { results, error in

            guard (error == nil) else {
                completionHandler(success: false, errorString: error!.localizedDescription)
                print("There was an error with your request: \(error)")
                return
            }

            guard let result = results["account"] as? NSDictionary else {
                completionHandler(success: false, errorString: "Wrong email or password")
                return
            }

            self.uniqueKey = result["key"] as! String
            self.getUserData()
            completionHandler(success: true, errorString: nil)
        }
    }
}
