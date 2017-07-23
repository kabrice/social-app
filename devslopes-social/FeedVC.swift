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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()

    override func viewDidLoad() {
        
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
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
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString){
                cell.configureCell(post: post, img: img)
                print("EDGAR: A")
            }else{
               cell.configureCell(post: post, img: nil)
                print("EDGAR: B")
            }
            
            return cell
        } else{
            return PostCell()
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            imageAdd.image = image
        } else{
            print("EDGAR: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
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
