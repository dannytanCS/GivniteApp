//
//  ViewController.swift
//  Givnite
//
//  Created by Danny Tan  on 7/2/16.
//  Copyright © 2016 Givnite. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase



class ViewController: UIViewController {


    @IBOutlet weak var facebookLoginButton: ZFRippleButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        //sign out
        //try! FIRAuth.auth()!.signOut()
        //FBSDKAccessToken.setCurrentAccessToken(nil)
        

        let dataRef = FIRDatabase.database().referenceFromURL("https://givniteapp.firebaseio.com/")
        
        
        
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                dataRef.child("user").child(user.uid).child("graduation year").observeSingleEventOfType(.Value, withBlock: { (snapshot)
                    in
                    
                    if let login = snapshot.value! as? NSString {
                        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let profileViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("profile")
                        self.presentViewController(profileViewController, animated: false, completion: nil)
                    }
                })
            }
            else {
                self.facebookLogin()
            }
        }

    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        loginButtonClicked()
    }
    
    func facebookLogin(){
        // Handle clicks on the button
        
        facebookLoginButton.addTarget(self, action: #selector(loginButtonClicked), forControlEvents: .TouchDown)
    }
    
    // Once the button is clicked, show the login dialog
    func loginButtonClicked() {
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile", "email"], fromViewController:self, handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                print("Process error")
                print(error)
            }
            else if result.isCancelled {
                print("Cancelled")
            }
            else {
                print("Logged in")
                self.firebaseLogin()
                //goes to next view controller
                let nextViewController = self.storyboard!.instantiateViewControllerWithIdentifier("school_name")
                self.presentViewController(nextViewController, animated: true, completion: nil)
            }
        })
    }
    
    //logins into firebase
    func firebaseLogin(){
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            print ("User logged into Firebase")
        }
        
    }
    
    
}





