//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 10/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var locations: [OTMLocation] = [OTMLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()

        mapView.delegate = self

        OTMClient.sharedInstance().getLocations { success, locations, error in
            if success {
                self.locations = locations!
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.reloadInputViews()
                    self.populateMap(self.locations)
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    let errorAlert = UIAlertController(title: "Unable to load locations", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }

    func populateMap(locations: [OTMLocation]) {
        var annotations = [MKPointAnnotation]()
        for item in locations {
            let lat = CLLocationDegrees(item.latitude)
            let long = CLLocationDegrees(item.longitude)

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

            let first = item.firstName
            let last = item.lastName
            let mediaURL = item.mediaURL

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL

            annotations.append(annotation)
        }

        mapView.addAnnotations(annotations)
    }

    // MARK: - MKMapViewDelegate
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            let button = UIButton(type: UIButtonType.DetailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }

    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let link = annotationView.annotation?.subtitle {
                app.openURL(NSURL(string: link!)!)
            }
        }
    }

    func refreshLocation() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        OTMClient.sharedInstance().getLocations { success, locations, error in
            if success {
                self.locations = locations!
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    self.mapView.reloadInputViews()
                    self.populateMap(self.locations)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    let errorAlert = UIAlertController(title: "Unable to load locations", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }

    func logout(){
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        OTMClient.sharedInstance().logoutAndDeleteSession { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                let errorAlert = UIAlertController(title: "Unable to logout", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            }
        }
    }

    func addLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
