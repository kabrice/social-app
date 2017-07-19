//
//  FeedVC.swift
//  devslopes-social
//
//  Created by Edgar KAMDEM on 15/07/2017.
//  Copyright © 2017 Edgar KAMDEM. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapchot) in
            print(snapchot.value)})
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
    }

    @IBAction func signOutTapped(_ sender: Any){
       do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
            KeychainWrapper.standard.removeObject(forKey: KEY_UID) ? print("EDGAR: user is removed from keychain") : print("EDGAR: user is not removed from keychain")
        } catch {
            print("EDGAR: Sign Out impossible now")
        }
    }
    

}
