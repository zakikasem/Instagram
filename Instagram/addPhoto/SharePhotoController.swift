//
//  SharePhotoController.swift
//  Instagram
//
//  Created by zaki kasem  on 2/3/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
import Firebase
class SharePhotoController : UIViewController {
    var selectedImage : UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    static let updateFeedNotificationName = NSNotification.Name("updateFeed")
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextViews()
    }
    let imageView : UIImageView = {
       let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    let textView : UITextView = {
       let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        return tv
    }()
    fileprivate func setupImageAndTextViews() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        view.addSubview(containerView)
        containerView.setAnchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0, height: 100, width: 0)
        containerView.addSubview(imageView)
        imageView.setAnchor(top: containerView.topAnchor, left: containerView.leftAnchor, right: nil, bottom: containerView.bottomAnchor, paddingBottom: 8, paddingLeft: 8, paddingRight: 0, paddingTop: 8, height: 0, width: 84)
        containerView.addSubview(textView)
        textView.setAnchor(top: containerView.topAnchor, left: imageView.rightAnchor, right: containerView.rightAnchor, bottom: containerView.bottomAnchor, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, paddingTop: 0, height: 0, width: 0)
    }

    @objc func handleShare () {
        guard let image = selectedImage else {return}
        guard let uploadData = image.jpegData(compressionQuality: 0.5 ) else {return}
        navigationItem.rightBarButtonItem?.isEnabled = false
        let filename = NSUUID().uuidString
        let storageImageRef = Storage.storage().reference().child("posts").child(filename)
            
            storageImageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print("Failed to upload post image ",err.localizedDescription)
                return
            }
                storageImageRef.downloadURL { (url, err) in
                    if let imageURL = url?.absoluteString {
                        print("Successfully uploaded image",imageURL)
                        self.saveToDataBaseWithImageURL(imageURL: imageURL)
                    }
                }
            
        }
    }
    fileprivate func saveToDataBaseWithImageURL(imageURL:String) {
       guard let caption = textView.text else {return}
        guard let postImage = selectedImage else {return}
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        let values = ["imageURL":imageURL,"caption":caption,"imageWidth":postImage.size.width,"imageHeight":postImage.size.height,"creationData":Date().timeIntervalSince1970] as [String : Any]
        ref.updateChildValues(values) { (err, ref) in
            if let err = err {
                print ("Failed to save to Database",err.localizedDescription)
                return
            }
            print("Successfully saved post to DB ")
            self.dismiss(animated: true, completion: nil)
            NotificationCenter.default.post(name: SharePhotoController.updateFeedNotificationName, object: nil)
            
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
