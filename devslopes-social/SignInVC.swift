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
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var pwdField: FancyField!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID){
            print("EDGAR: ID found in keychain")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
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
                print("EDGAR: Unable to authenticate with Firebase - \(String(describing: error))")
            } else {
                print("EDGAR: Successfully sign in with Firebase")
                if let user = user{
                    let userData = ["provider": credential.provider]
                    self.completeSiginIn(id: user.uid, userData: userData)
                }
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailField.text, let pwd = pwdField.text{
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil{
                    print("EDGAR: Email authentication with Firebase")
                    if let user = user{
                        let userData = ["provider": user.providerID]
                        self.completeSiginIn(id: user.uid, userData: userData)
                    }
                } else{
                    Auth.auth().createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil{
                            print("EDGAR: Unable to authenticate with Firebase using email")
                        } else{
                            print("EDGAR: Successfully authenticated with Firebase")
                            if let user = user{
                                let userData = ["provider": user.providerID]
                                self.completeSiginIn(id: user.uid, userData: userData)
                            }
                        }})
                }
            })
        }
    }
    
    func completeSiginIn(id: String, userData: Dictionary<String, String>){
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keyChainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("EDGAR: Data saved to keychain \(keyChainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }

}

