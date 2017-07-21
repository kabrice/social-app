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
    
    var posts = [Post]()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //This is a listener for instant update
        DataService.ds.REF_POSTS.observe(.value, with: { (snapchot) in
            self.posts = [] 
            if let snapchot = snapchot.children.allObjects as? [DataSnapshot]{
                for snap in snapchot{
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, Any>{
                        let key = snap.key
                        let post = Post(postkey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell{
            cell.configureCell(post: post)
            return cell
        } else{
            return PostCell()
        }
        
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
