//
//  ViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 07/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var informationLabel: UILabel!

    var tapRecognizer: UITapGestureRecognizer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self

        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email"]

        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if let token = FBSDKAccessToken.currentAccessToken()?.tokenString {
            facebookLogin(token)
        }

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

    @IBAction func login(sender: AnyObject) {

        guard emailTextField.text != "" else {
            informationLabel.textColor = UIColor.redColor()
            informationLabel.text = "Please enter your email"
            return
        }
        guard passwordTextField.text != "" else {
            informationLabel.textColor = UIColor.redColor()
            informationLabel.text = "Please enter your password"
            return
        }
        UdacityClient.sharedInstance().username = emailTextField.text!
        UdacityClient.sharedInstance().password = passwordTextField.text!
        UdacityClient.sharedInstance().loginAndCreateSession() { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let errorAlert = UIAlertController(title: errorString!, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                    errorAlert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                })
            }
        }
    }

    // finish login if UdacityClient API call was successful
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            let rootNavVC = self.storyboard!.instantiateViewControllerWithIdentifier("rootNavVC") as! UINavigationController
            self.presentViewController(rootNavVC, animated: true, completion: nil)
        })
    }

    // Facebook Delegate Methods

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if ((error) != nil) {
            // Process error
            print("Error")
        }
        else if result.isCancelled {
            // Handle cancellations
            print("Is cancelled")
        }
        else {
            facebookLogin(result.token.tokenString)
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }

    func facebookLogin(tokenString: String) {
        UdacityClient.sharedInstance().facebookAccessToken = tokenString
        UdacityClient.sharedInstance().sessionWithFacebookAuthentication() { success, errorString in
            if success {
                let rootNavVC = self.storyboard!.instantiateViewControllerWithIdentifier("rootNavVC") as! UINavigationController
                self.presentViewController(rootNavVC, animated: true, completion: nil)
            }
        }
    }

    // Keyboard Management

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController {

    // MARK: Show/Hide Keyboard

    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }

    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }

    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
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
        if view.frame.origin.y == 0.0 {
            view.frame.origin.y -= self.getKeyboardHeight(notification) / 2
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0.0 {
            view.frame.origin.y += self.getKeyboardHeight(notification) / 2
        }
    }

    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
}
