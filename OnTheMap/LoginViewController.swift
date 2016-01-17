//
//  ViewController.swift
//  OnTheMap
//
//  Created by Jefferson Bonnaire on 07/01/2016.
//  Copyright © 2016 Jefferson Bonnaire. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var informationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        facebookLoginButton.delegate = self
        facebookLoginButton.readPermissions = ["public_profile", "email"]
        UdacityClient.sharedInstance().facebookAccessToken = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
            UdacityClient.sharedInstance().facebookAccessToken = result.token.tokenString
            UdacityClient.sharedInstance().sessionWithFacebookAuthentication() { success, errorString in
                if success {
                    let rootNavVC = self.storyboard!.instantiateViewControllerWithIdentifier("rootNavVC") as! UINavigationController
                    self.presentViewController(rootNavVC, animated: true, completion: nil)
                }
            }
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}
