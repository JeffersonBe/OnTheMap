//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation

class ParseClient: NSObject {

    var locations: [OTMLocation] = [OTMLocation]()
    var session: NSURLSession
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil

    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }

    func getLocations(completionHandler: (success: Bool, locations: [OTMLocation]?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.Constants.BaseUrl)!)
        request.addValue(UdacityClient.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityClient.Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, locations: nil, errorString: "The internet connection appears to be offline")
            } else {

                guard let data = data else {
                    print("No data have been returned")
                    return
                }

                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                    completionHandler(success: false, locations: nil, errorString: nil)
                    return
                }
                self.locations = OTMLocation.locationsFromResults(results)
                completionHandler(success: true, locations: self.locations, errorString: nil)
            }
        }
        task.resume()
    }

    func postLocations(mapString: String, mediaURL: String, latitude: String, longitude: String,completionHandler: (success: Bool, locations: [OTMLocation]?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: UdacityClient.Constants.BaseUrl)!)
        request.addValue(UdacityClient.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(UdacityClient.Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"firstName\": \"John\", \"lastName\": \"Doe\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.386052, \"longitude\": -122.083851}".dataUsingEncoding(NSUTF8StringEncoding)

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, locations: nil, errorString: "The internet connection appears to be offline")
            } else {

                guard let data = data else {
                    print("No data have been returned")
                    return
                }

                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                    completionHandler(success: false, locations: nil, errorString: nil)
                    return
                }
                self.locations = OTMLocation.locationsFromResults(results)
                completionHandler(success: true, locations: self.locations, errorString: nil)
            }
        }
        task.resume()
    }

    class func sharedInstance() -> ParseClient {

        struct Singleton {
            static var sharedInstance = ParseClient()
        }

        return Singleton.sharedInstance
    }
}