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
    var indicator = CustomUIActivityIndicatorView()


    var locations: [OTMLocation] = [OTMLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        indicator.startActivity()
        view.addSubview(indicator)
        refreshLocation()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshLocation()
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

    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        indicator.stopActivity()
        indicator.removeFromSuperview()
    }

    func refreshLocation() {
        OTMClient.sharedInstance().getLocations { success, locations, error in
            if success {
                self.locations = locations!
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.reloadInputViews()
                    self.populateMap(self.locations)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator.stopActivity()
                    self.indicator.removeFromSuperview()
                    let errorAlert = UIAlertController(title: "Unable to load locations", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }

    func logout(){
        self.indicator.startActivity()
        view.addSubview(indicator)
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
                let errorAlert = UIAlertController(title: "Unable to logout", message: error, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }

    func addLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
