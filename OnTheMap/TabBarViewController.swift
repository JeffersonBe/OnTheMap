//
//  TabBarViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 12/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        let logoutButton = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addLocation")
        let refreshButton = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "handleRefresh")
        let rightButtons = [refreshButton, addButton]
        self.navigationItem.rightBarButtonItems = rightButtons
        self.navigationItem.leftBarButtonItem = logoutButton
        self.title = "On The Map"
    }

    func logout(){
        UdacityClient.sharedInstance().logoutAndDeleteSession { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            }
        }
    }

    func handleRefresh() {
        if self.selectedIndex == 0 {
            let mapVC = self.viewControllers![0] as! MapViewController
            mapVC.refreshLocation()
        } else if self.selectedIndex == 1 {
            let tableVC = self.viewControllers![1] as! LocationTableViewController
            tableVC.refreshLocation()
        }
    }

    func addLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
}
