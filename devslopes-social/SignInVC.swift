//
//  SignInVC.swift
//  devslopes-social
//
//  Created by Edgar KAMDEM on 14/07/2017.
//  Copyright © 2017 Edgar KAMDEM. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
       
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self){ (result, error) in
            if error != nil {
                print("EDGAR: Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("EDGAR: User cancelled Facebook authentication")
            } else{
                print("EDGAR: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    
    func firebaseAuth(_ credential: AuthCredential){
        Auth.auth().signIn(with: credential){ (user, error) in
            if error != nil{
                print("EDGAR: Unable to authenticate with Facebook - \(String(describing: error))")
            } else {
                print("EDGAR: Successfully sign in with Firebase")
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text{
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil{
                    print("EDGAR: Email authentication with Firebase")
                } else{
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil{
                            print("EDGAR: Unable to authenticate with Firebase using email")
                        } else{
                            print("EDGAR: Successfully authenticated with Firebase")
                        }})
                }
            })
        }
    }

}

