//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 22/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation
import UIKit

class OTMClient: NSObject {

    // MARK: Properties

    /* Shared session */
    var session: NSURLSession

    /* Udacity Client Values */
    var username = ""
    var password = ""
    var uniqueKey = ""
    var userFirstName = ""
    var userLastName = ""
    var facebookAccessToken = ""

    /* Parse Client Values */
    var objectId: String = ""
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil

    /* Model */
    var manager = OTMLocationManager.sharedInstance

    // MARK: Initializers
    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }

    // MARK: GET

    func taskForGETMethod(Api: String, urlString: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        var urlComposed = urlString

        if parameters.keys.first != "" {
            urlComposed = urlString + OTMClient.escapedParameters(parameters)
        }

        let request = NSMutableURLRequest(URL: NSURL(string: urlComposed)!)

        if Api == "Parse" {
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        }

        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(result: nil, error: error)
                print("No data was returned by the request!")
                return
            }

            /* Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(Api, data: data, completionHandler: completionHandler)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    // MARK: POST

    func taskForPOSTMethod(Api: String, HTTPMethod: String, urlString: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        var urlComposed = urlString

        if parameters.keys.first != "" {
            urlComposed = urlString + OTMClient.escapedParameters(parameters)
        }

        let request = NSMutableURLRequest(URL: NSURL(string: urlComposed)!)

        if HTTPMethod != "" {
            request.HTTPMethod = HTTPMethod
        }

        if HTTPMethod == "DELETE" {
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }

        }

        if HTTPMethod != "DELETE" && Api == "Udacity" {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if HTTPMethod != "DELETE" && Api == "Parse" {
            request.addValue(OTMConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(OTMConstants.Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        }

        if jsonBody.keys.first != "" {
            do {
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
            }
        }

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(result: nil, error: error)
                print("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(result: nil, error: error)
                print("No data was returned by the request!")
                return
            }

            /* Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(Api, data: data, completionHandler: completionHandler)
        }

        task.resume()
        return task
    }

    // MARK: Helpers

    /* Helper: Substitute the key for the value that is contained within the method name */
    class func substituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(Api: String, data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {

        var newData: NSData!
        if Api == "Udacity" {
            newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
        } else {
            newData = data
        }

        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(result: nil, error: NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completionHandler(result: parsedResult, error: nil)
    }

    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()

        for (key, value) in parameters {
            /* Make sure that it is a string value */
            let stringValue = "\(value)"

            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}
