//
//  LocationTableViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import UIKit

class LocationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var table: UITableView!

    var locations: [OTMLocation] = [OTMLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        ParseClient.sharedInstance().getLocations { success, locations, error in
            if let location = locations {
                self.locations = location
                dispatch_async(dispatch_get_main_queue()) {
                    self.table.reloadData()
                }
            } else {
                print(error)
            }
        }
        parentViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")
        parentViewController?.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Add", style: .Plain, target: self, action: "logout"), UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "logout")]
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        table.addSubview(refreshControl)
    }
    
    // MARK: UITableViewController

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        /* Get cell type */
        let cellReuseIdentifier = "locationCell"
        let location = locations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!

        /* Set cell defaults */
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaURL
        return cell

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        /* Push the movie detail view */
//        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
//        controller.movie = movies[indexPath.row]
//        self.navigationController!.pushViewController(controller, animated: true)
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        ParseClient.sharedInstance().getLocations { success, locations, error in
            if let location = locations {
                self.locations = location
                print(self.locations)
                dispatch_async(dispatch_get_main_queue()) {
                    self.table.reloadData()
                    refreshControl.endRefreshing()
                }
            } else {
                print(error)
            }
        }
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
}
