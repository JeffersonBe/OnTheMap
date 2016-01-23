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

    var indicator = CustomUIActivityIndicatorView()

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
        indicator.startActivity()
        view.addSubview(indicator)
        if OTMClient.sharedInstance().facebookAccessToken == "" {
            OTMClient.sharedInstance().logoutAndDeleteSession { success, error in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.indicator.stopActivity()
                        self.indicator.removeFromSuperview()
                        self.throwFail(error.debugDescription)
                    }
                }
            }
        } else {
            OTMClient.sharedInstance().facebookAccessToken = ""
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            let loginViewController = storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            presentViewController(loginViewController, animated: true, completion: nil)
        }

    }

    func handleRefresh() {
        if selectedIndex == 0 {
            let mapVC = viewControllers![0] as! MapViewController
            mapVC.refreshLocation()
        } else if selectedIndex == 1 {
            let tableVC = viewControllers![1] as! LocationTableViewController
            tableVC.refresh(true)
        }
    }

    func checkIfAlreadyPostLocation() {
        indicator.startActivity()
        view.addSubview(indicator)
        OTMClient.sharedInstance().queryLocations() { success, errorString in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator.stopActivity()
                    self.indicator.removeFromSuperview()
                    let propositionAlert = UIAlertController(title: "Add your location", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    propositionAlert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: { action in
                        self.addLocation("PUT")
                    }))
                    propositionAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
                    self.presentViewController(propositionAlert, animated: true, completion: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator.stopActivity()
                    self.indicator.removeFromSuperview()
                    self.addLocation("POST")
                }
            }
        }
    }

    func addLocation(MethodType: String) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        controller.MethodType = MethodType
        presentViewController(controller, animated: true, completion: nil)
    }

    func throwFail(title: String) {
        let errorAlert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(errorAlert, animated: true, completion: nil)
    }
}
