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
    @IBOutlet weak var refreshControl: UIRefreshControl!
    var indicator = CustomUIActivityIndicatorView()

    var locations: [OTMLocation] = [OTMLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self

        refresh(true)

        refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
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

    func refresh(sender:AnyObject) {
        indicator.startActivity()
        view.addSubview(indicator)
        OTMClient.sharedInstance().getLocations { success, locations, error in
            if success {
                self.locations = locations!
                dispatch_async(dispatch_get_main_queue()) {
                    self.table.reloadData()
                    self.refreshControl?.endRefreshing()
                    self.indicator.stopActivity()
                    self.indicator.removeFromSuperview()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator.stopActivity()
                    self.indicator.removeFromSuperview()
                    self.refreshControl?.endRefreshing()
                    let errorAlert = UIAlertController(title: "Unable to load locations", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
