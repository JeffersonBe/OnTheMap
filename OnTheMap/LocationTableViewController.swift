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
    var manager = OTMLocationManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self

        refresh(true)

        refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        refresh(true)
    }
    
    // MARK: UITableViewController

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        /* Get cell type */
        let cellReuseIdentifier = "locationCell"
        let location = manager.locationArray[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        cell.textLabel?.text = "\(location.firstName) \(location.lastName)"
        cell.detailTextLabel?.text = location.mediaURL
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.locationArray.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let location = manager.locationArray[indexPath.row]
        let app = UIApplication.sharedApplication()
        app.openURL(NSURL(string: location.mediaURL)!)
    }

    func refresh(sender:AnyObject) {
        manager.locationArray.removeAll()
        indicator.startActivity()
        view.addSubview(indicator)
        OTMClient.sharedInstance().getLocations { success, error in
            if success {
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
                    let errorAlert = UIAlertController(title: OTMConstants.AppCopy.unableToLoadLocation, message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: OTMConstants.AppCopy.dismiss, style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
