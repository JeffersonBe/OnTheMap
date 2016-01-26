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
    @IBOutlet weak var cancelButton: UIButton!
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
    var indicator = CustomUIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        linkSubmitView.hidden = true
        mapView.delegate = self

        locationTextField.delegate = self
        linkShareTextField.delegate = self

        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1

        cancelButton.layer.cornerRadius = 15
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
        guard locationTextField.text != "" else {
            locationTextField.attributedPlaceholder = NSAttributedString(string: OTMConstants.AppCopy.locationRequired, attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            return
        }

        indicator.startActivity()
        view.addSubview(indicator)

        let location: String = self.locationTextField.text!
        let geocoder: CLGeocoder = CLGeocoder()

        geocoder.geocodeAddressString(location, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) -> Void in

            guard error == nil else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.indicator.stopActivity()
                    self.indicator.removeFromSuperview()
                    self.throwFail(OTMConstants.AppCopy.unableToLoadLocation)
                    print("There was an error searching for: \(self.locationTextField.text)")
                }
                return
            }

            if (placemarks?.count > 0) {
                let topResult: CLPlacemark = (placemarks?[0])!
                let placemark: MKPlacemark = MKPlacemark(placemark: topResult)

                self.latitude = CLLocationDegrees((placemark.location?.coordinate.latitude)!)
                self.longitude = CLLocationDegrees((placemark.location?.coordinate.longitude)!)
                if let street = (placemark.addressDictionary?["Street"]) as? String {
                    self.street = street
                }
                self.city = (placemark.addressDictionary?["City"])! as! String
                self.country =  (placemark.addressDictionary?["Country"])! as! String
                self.mapString = "\(self.street), \(self.city), \(self.country)"
                self.mapView.addAnnotation(placemark)

                var annotations = [MKPointAnnotation]()
                let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotations.append(annotation)

                dispatch_async(dispatch_get_main_queue()) {
                    self.mapView.addAnnotations(annotations)
                    self.mapView.reloadInputViews()
                    self.mapView.showAnnotations(self.mapView.annotations, animated: true)
                    self.locationSubmitView.hidden = true
                    self.linkSubmitView.hidden = false
                    self.indicator.stopActivity()
                    self.indicator.removeFromSuperview()
                }
            }
        })
    }

    @IBAction func submitLocationAndLink(sender: AnyObject) {
        indicator.startActivity()
        view.addSubview(indicator)
        guard linkShareTextField.text != "" else {
            linkShareTextField.attributedPlaceholder = NSAttributedString(string: OTMConstants.AppCopy.linkRequired, attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
            return
        }

        if MethodType == "POST" {
            OTMClient.sharedInstance().postLocations(mapString, mediaURL: linkShareTextField.text!, latitude: latitude, longitude: longitude) { success, errorString in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.indicator.stopActivity()
                        self.indicator.removeFromSuperview()
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
                        self.indicator.stopActivity()
                        self.indicator.removeFromSuperview()
                        self.throwFail(errorString!)
                    }
                }
            }
        }
    }
    @IBAction func cancelAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func throwFail(title: String) {
        let errorAlert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        errorAlert.addAction(UIAlertAction(title: OTMConstants.AppCopy.dismiss, style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(errorAlert, animated: true, completion: nil)
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
