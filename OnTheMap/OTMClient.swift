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
    var locations: [OTMLocation] = [OTMLocation]()
    var objectId: String = ""
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil

    // MARK: Initializers
    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }


    // MARK: GET

    func taskForGETMethod(method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[OTMConstants.Constants.ParseApiKey] = OTMConstants.Constants.ParseApiKey

        /* 2/3. Build the URL and configure the request */
        let urlString = OTMConstants.Constants.BaseUrl + method + OTMClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }

        /* 7. Start the request */
        task.resume()

        return task
    }

    // MARK: POST

    func taskForPOSTMethod(method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {

        /* 1. Set the parameters */
        var mutableParameters = parameters
        mutableParameters[OTMConstants.Constants.ParseApiKey] =  OTMConstants.Constants.ParseApiKey

        /* 2/3. Build the URL and configure the request */
        let urlString = OTMConstants.Constants.BaseUrl + method + OTMClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }

        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in

            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }

            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }

            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }

            /* 5/6. Parse the data and use the data (happens in completion handler) */
            OTMClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }

        /* 7. Start the request */
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
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {

        var parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
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