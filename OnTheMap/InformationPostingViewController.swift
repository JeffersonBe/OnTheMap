//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 12/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationSearchButton: UIButton!
    @IBOutlet weak var linkShareTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var MethodType: String = ""
    var mapString: String = ""
    var mediaURL: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var street: String = ""
    var city: String = ""
    var country: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func updateMapView(sender: AnyObject) {
        guard locationTextField.text != nil else {
            return
        }

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "\(locationTextField.text)"
        request.region = mapView.region
        let search = MKLocalSearch(request: request)

        search.startWithCompletionHandler { response, error in
            guard let response = response else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.throwFail("We're not able to found your location, please check it")
                    print("There was an error searching for: \(request.naturalLanguageQuery) error: \(error)")
                }
                return
            }

            if let firstResult = response.mapItems.first {
                self.latitude = CLLocationDegrees((firstResult.placemark.location?.coordinate.latitude)!)
                self.longitude = CLLocationDegrees((firstResult.placemark.location?.coordinate.longitude)!)
                self.street = (firstResult.placemark.addressDictionary?["Street"])! as! String
                self.city = (firstResult.placemark.addressDictionary?["City"])! as! String
                self.country =  (firstResult.placemark.addressDictionary?["Country"])! as! String
                self.mapString = "\(self.street), \(self.city), \(self.country)"
                print(self.mapString)
            }

            var annotations = [MKPointAnnotation]()
            let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotations.append(annotation)

            dispatch_async(dispatch_get_main_queue()) {
                self.mapView.addAnnotations(annotations)
                self.mapView.reloadInputViews()
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
    }
    
    @IBAction func submitLocationAndLink(sender: AnyObject) {
        guard linkShareTextField.text != nil else {
            return
        }

        if MethodType == "POST" {
            ParseClient.sharedInstance().postLocations(mapString, mediaURL: linkShareTextField.text!, latitude: latitude, longitude: longitude) { success, errorString in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    print(errorString)
                }
            }

        } else {
            ParseClient.sharedInstance().updateLocations(mapString, mediaURL: linkShareTextField.text!, latitude: latitude, longitude: longitude) { success, errorString in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    print(errorString)
                }
            }
        }
    }

    func throwFail(title: String) {
        let errorAlert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(errorAlert, animated: true, completion: nil)
    }
}
