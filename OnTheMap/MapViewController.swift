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
    var locations: [OTMLocation] = [OTMLocation]()

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        ParseClient.sharedInstance().getLocations { success, locations, error in
            if let location = locations {
                self.locations = location
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.reloadInputViews()
                    self.populateMap(self.locations)
                }
            } else {
                print(error)
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

        self.mapView.addAnnotations(annotations)
    }

    // MARK: - MKMapViewDelegate

    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
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


    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let link = annotationView.annotation?.subtitle {
                app.openURL(NSURL(string: link!)!)
            }
        }
    }

    func refreshLocation() {
        ParseClient.sharedInstance().getLocations { success, locations, error in
            if let location = locations {
                self.locations = location
                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.reloadInputViews()
                    self.populateMap(self.locations)
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

    func addLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
}
