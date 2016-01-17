//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 12/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        let addButton = UIBarButtonItem(image: UIImage(named: "PinIcon"), style: .Plain, target: self, action: "checkIfAlreadyPostLocation")
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "handleRefresh")
        let rightButtons = [refreshButton, addButton]
        navigationItem.rightBarButtonItems = rightButtons
        navigationItem.leftBarButtonItem = logoutButton
        title = "On The Map"
    }

    func logout(){
        if UdacityClient.sharedInstance().facebookAccessToken == "" {
        UdacityClient.sharedInstance().logoutAndDeleteSession { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
        } else {
            UdacityClient.sharedInstance().facebookAccessToken = ""
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            let loginViewController = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.presentViewController(loginViewController, animated: true, completion: nil)
        }

    }

    func handleRefresh() {
        if self.selectedIndex == 0 {
            let mapVC = viewControllers![0] as! MapViewController
            mapVC.refreshLocation()
        } else if self.selectedIndex == 1 {
            let tableVC = viewControllers![1] as! LocationTableViewController
            tableVC.refreshLocation()
        }
    }

    func checkIfAlreadyPostLocation() {
        ParseClient.sharedInstance().queryLocations() { success, errorString in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let errorAlert = UIAlertController(title: "Add your location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    errorAlert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: { action in
                        self.addLocation("PUT")
                    }))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            } else {
                self.addLocation("POST")
            }
        }
    }

    func addLocation(MethodType: String) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        controller.MethodType = MethodType
        presentViewController(controller, animated: true, completion: nil)
    }
    
}
