//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {

    // MARK: - Variables

    var username: String = ""
    var password: String = ""
    var uniqueKey: String = ""
    var userFirstName: String = ""
    var userLastName: String = ""
    var session: NSURLSession

    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }

    // MARK: - API Functions

    // Login to Udacity with user-supplied credentials
    func loginAndCreateSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: OTMConstants.Constants.AuthorizationURL + OTMConstants.Methods.AuthenticationSessionNew )!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }

                guard let registered = parsedResult["account"] as? NSDictionary else {
                    completionHandler(success: false, errorString: "Wrong email or password")
                    return
                }

                self.uniqueKey = registered["key"] as! String
                self.getUserData()
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }

    // logout and destroy session
    func logoutAndDeleteSession(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: OTMConstants.Constants.AuthorizationURL + OTMConstants.Methods.AuthenticationSessionNew )!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "The internet connection appears to be offline")
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                guard parsedResult["session"] != nil else {
                    completionHandler(success: false, errorString: "Could not logout")
                    return
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }

    // get user first name and last name
    func getUserData() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(uniqueKey)")!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                return
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                } catch {
                    parsedResult = nil
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }

                guard let user = parsedResult["user"] as? NSDictionary else {
                    print("Couldn't find the user")
                    return
                }

                self.userFirstName = user["first_name"] as! String
                self.userLastName = user["last_name"] as! String
            }
        }
        task.resume()
    }

    // MARK: - Shared Instance

    // make this class a singleton to share across classes
    class func sharedInstance() -> UdacityClient {

        struct Singleton {
            static var sharedInstance = UdacityClient()
        }

        return Singleton.sharedInstance
    }

}
