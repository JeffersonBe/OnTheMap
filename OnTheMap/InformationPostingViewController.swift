//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 12/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var locationSearchButton: UIButton!
    @IBOutlet weak var linkShareTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var locationSubmitView: UIView!
    @IBOutlet weak var linkSubmitView: UIView!
    
    var MethodType: String = ""
    var mapString: String = ""
    var mediaURL: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var street: String = ""
    var city: String = ""
    var country: String = ""

    var tapRecognizer: UITapGestureRecognizer? = nil
    var keyboardAdjusted = false
    var lastKeyboardOffset : CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        linkSubmitView.hidden = true
        activityIndicator.hidden = true

        locationTextField.delegate = self
        linkShareTextField.delegate = self

        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        /* Add tap recognizer to dismiss keyboard */
        self.addKeyboardDismissRecognizer()

        /* Subscribe to keyboard events so we can adjust the view to show hidden controls */
        self.subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

        /* Remove tap recognizer */
        self.removeKeyboardDismissRecognizer()

        /* Unsubscribe to all keyboard events */
        self.unsubscribeToKeyboardNotifications()
    }

    @IBAction func updateMapView(sender: AnyObject) {
        guard locationTextField.text != nil else {
            return
        }

        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "\(locationTextField.text)"
        request.region = mapView.region
        let search = MKLocalSearch(request: request)

        activityIndicator.hidden = false
        activityIndicator.startAnimating()

        search.startWithCompletionHandler { response, error in
            guard let response = response else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.throwFail("We're not able to found your location, please check it")
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
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
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                self.locationSubmitView.hidden = true
                self.linkSubmitView.hidden = false
            }
        }
    }
    
    @IBAction func submitLocationAndLink(sender: AnyObject) {
        guard linkShareTextField.text != nil else {
            return
        }

        activityIndicator.hidden = false
        activityIndicator.startAnimating()

        if MethodType == "POST" {
            OTMClient.sharedInstance().postLocations(mapString, mediaURL: linkShareTextField.text!, latitude: latitude, longitude: longitude) { success, errorString in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.hidden = true
                        self.activityIndicator.stopAnimating()
                        self.throwFail(errorString!)
                    }
                }
            }

        } else {
            OTMClient.sharedInstance().updateLocations(mapString, mediaURL: linkShareTextField.text!, latitude: latitude, longitude: longitude) { success, errorString in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.activityIndicator.hidden = true
                        self.activityIndicator.stopAnimating()
                        self.throwFail(errorString!)
                    }
                }
            }
        }
    }

    func throwFail(title: String) {
        let errorAlert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(errorAlert, animated: true, completion: nil)
    }


    // Keyboard Management

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension InformationPostingViewController {

    // MARK: Show/Hide Keyboard

    func addKeyboardDismissRecognizer() {
        view.addGestureRecognizer(tapRecognizer!)
    }

    func removeKeyboardDismissRecognizer() {
        view.removeGestureRecognizer(tapRecognizer!)
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    func keyboardWillShow(notification: NSNotification) {
        if keyboardAdjusted == false {
            lastKeyboardOffset = getKeyboardHeight(notification) / 2
            view.superview?.frame.origin.y -= lastKeyboardOffset
            keyboardAdjusted = true
        }
    }

    func keyboardWillHide(notification: NSNotification) {

        if keyboardAdjusted == true {
            view.superview?.frame.origin.y += lastKeyboardOffset
            keyboardAdjusted = false
        }
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
