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

        refreshLocation()

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshLocation", forControlEvents: UIControlEvents.ValueChanged)
        table.addSubview(refreshControl)
    }
    
    // MARK: UITableViewController

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        /* Get cell type */
        let cellReuseIdentifier = "locationCell"
        let location = locations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaURL
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = locations[indexPath.row]
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: location.mediaURL)!)
    }

    func refreshLocation() {
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
    }
}
