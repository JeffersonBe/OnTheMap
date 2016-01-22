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
    var objectId: String = ""
    var session: NSURLSession
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil

    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }

    func getLocations(completionHandler: (success: Bool, locations: [OTMLocation]?, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!)
        request.addValue(OTMConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMConstants.Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

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

    func postLocations(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        // let request = NSMutableURLRequest(URL: NSURL(string: OTMConstants.Constants.BaseUrl)!)
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(UdacityClient.sharedInstance().uniqueKey)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue(OTMConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMConstants.Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().uniqueKey)\", \"firstName\": \"\(UdacityClient.sharedInstance().userFirstName)\", \"lastName\": \"\(UdacityClient.sharedInstance().userLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\", \"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
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
                guard parsedResult["createdAt"] != nil else {
                    completionHandler(success: false, errorString: nil)
                    return
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }

    func updateLocations(mapString: String, mediaURL: String, latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation/\(objectId)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue(OTMConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMConstants.Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().uniqueKey)\", \"firstName\": \"\(UdacityClient.sharedInstance().userFirstName)\", \"lastName\": \"\(UdacityClient.sharedInstance().userLastName)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(Float(latitude)), \"longitude\": \(Float(longitude))}".dataUsingEncoding(NSUTF8StringEncoding)
        // request.HTTPBody = "{\"uniqueKey\": \"\(UdacityClient.sharedInstance().uniqueKey)\", \"firstName\": \"\(UdacityClient.sharedInstance().userFirstName)\", \"lastName\": \"\(UdacityClient.sharedInstance().userLastName)\",\"mapString\": \"Cupertino, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": 37.322998, \"longitude\": -122.032182}".dataUsingEncoding(NSUTF8StringEncoding)

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
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
                print(parsedResult)
                guard parsedResult["updatedAt"] != nil else {
                    completionHandler(success: false, errorString: nil)
                    return
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }

    func queryLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(UdacityClient.sharedInstance().uniqueKey)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(OTMConstants.Constants.ParseApiKey, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(OTMConstants.Constants.RestApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")

        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
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

                guard parsedResult["results"] != nil else {
                    completionHandler(success: false, errorString: nil)
                    return
                }

                guard let results = parsedResult["results"] as? [[String:AnyObject]] else {
                    return
                }

                guard let objectId = results.first!["objectId"] as? String else {
                    return
                }

                self.objectId = objectId
                completionHandler(success: true, errorString: nil)
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