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
    var manager = OTMLocationManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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

    // MARK: MapKit Delegate

    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        indicator.startActivity()
        view.insertSubview(indicator, atIndex: 100)
    }

    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        indicator.stopActivity()
        indicator.removeFromSuperview()
    }

    func refreshLocation() {
        manager.locationArray.removeAll()
        OTMClient.sharedInstance().getLocations { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.reloadInputViews()
                    self.populateMap(self.manager.locationArray)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let errorAlert = UIAlertController(title: OTMConstants.AppCopy.unableToLoadLocation, message: error, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: OTMConstants.AppCopy.dismiss, style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }

    func logout(){
        OTMClient.sharedInstance().logoutAndDeleteSession { success, error in
            if success {
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                let errorAlert = UIAlertController(title: OTMConstants.AppCopy.unableToLogout, message: error, preferredStyle: UIAlertControllerStyle.Alert)
                errorAlert.addAction(UIAlertAction(title: OTMConstants.AppCopy.dismiss, style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
}
