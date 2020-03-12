//
//  EditProfile.swift
//  Instagram
//
//  Created by zaki kasem  on 2/16/20.
//  Copyright © 2020 zaki kasem . All rights reserved.
//

import UIKit
import Firebase
class EditProfileController :UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    static let updateUserData = NSNotification.Name("updateFeed")
    var profileImageString:String? {
        didSet{
            guard let profileImg = profileImageString else {return}
            guard let profileImageURL = URL(string: profileImg) else {return}
            URLSession.shared.dataTask(with: profileImageURL ) { (data, response, err) in
                       if let err = err {
                           print("Failed to fetch post image",err.localizedDescription)
                           return
                       }
                       guard let imageData = data else {return}
                       let photoImage = UIImage(data: imageData)
                       DispatchQueue.main.async { [weak self] in
                        self?.profileImageView.setImage(photoImage, for: .normal)
                       }
                       }.resume()
        }
    }
    let loadingIndicator:UIActivityIndicatorView = {
       let loadingIndicatorView = UIActivityIndicatorView()
        loadingIndicatorView.tintColor = .gray
        return loadingIndicatorView
    }()
    let profileImageView : UIButton = {
    let button = UIButton()
        button.imageView?.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(handleProfileImageButton), for: .touchUpInside)
        return button
    }()
    let changeYourProfilePhotoLabel :UILabel = {
       let label = UILabel()
        label.text = "Change your profile photo"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.rgb(red: 17, green: 154, blue: 237)
        label.numberOfLines = 0
        return label
    }()
    let usernameLabel:UILabel = {
       let label = UILabel()
        label.text = "Username"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    let usernameTextField :UITextField = {
       let tf = UITextField()
        tf.placeholder = "Update your username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        return tf
    }()
    @objc func handleProfileImageButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            profileImageView.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
        else if let editedImage =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "✔", style: .plain, target: self, action: #selector(addTapped))
        
        self.hideKeyboardWhenTappedAround()
        navigationController?.navigationBar.isTranslucent = false
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(usernameLabel)
        view.addSubview(usernameTextField)
        view.addSubview(changeYourProfilePhotoLabel)
        view.addSubview(loadingIndicator)
        profileImageView.setAnchor(top: view.topAnchor, left: nil, right:nil, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 30, height: 100, width: 100)
        usernameLabel.setAnchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 10, paddingRight: 0, paddingTop: 100, height: 0, width: 100)
        usernameTextField.setAnchor(top: usernameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 10, paddingRight: 10, paddingTop: 10, height: 0, width:0)
        changeYourProfilePhotoLabel.setAnchor(top: profileImageView.bottomAnchor, left: nil , right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 10, height: 0, width: 0)
        loadingIndicator.setAnchor(top: usernameTextField.bottomAnchor, left: nil, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 20, height: 50, width: 50)
        NSLayoutConstraint.activate([loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),changeYourProfilePhotoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.layer.cornerRadius = 50
        profileImageView.clipsToBounds = true
        
    }
    @objc func addTapped() {
        print("Changed")
        saveProfileImageToStorage()
        saveUsernameToDatabase()
    }
    func saveUsernameToDatabase() {
            usernameTextField.resignFirstResponder()
            loadingIndicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                if self?.usernameTextField.text?.isEmpty ?? false {
                    self?.navigationController?.popViewController(animated: true)

                } else {
                guard let usernameTxt = self?.usernameTextField.text else {return}
            if usernameTxt.isEmpty {
                self?.navigationItem.rightBarButtonItem?.isEnabled = false
            }else {
                let username = usernameTxt
                guard let uid = Auth.auth().currentUser?.uid else {return}
                let values = ["username":username]
                Database.database().reference().child("users").child(uid).updateChildValues(values) { (err, ref) in
                    if let err = err {
                        print("Failed to update username",err)
                        return
                    }
                    print("Successfully updated username")
                    NotificationCenter.default.post(name: EditProfileController.updateUserData, object: nil)
                }
                    self?.navigationController?.popViewController(animated: true)
                
            }
        }
        }

    }
    func saveProfileImageToStorage() {
            guard let image = self.profileImageView.imageView?.image else {return}
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
            let filename = NSUUID().uuidString
            Storage.storage().reference().child("profile_images").child(filename).putData(uploadData, metadata: nil) { (metaData, err) in
                if let err = err {
                    print("Failed to upload profile image",err)
                    return
                    
                }
                print("Successfully uploaded")
                guard let userID = Auth.auth().currentUser?.uid else {return}
                let storageImageRef = Storage.storage().reference().child("profile_images").child(filename)
                storageImageRef.downloadURL { (url, err) in
                    if let profileImageURL = url?.absoluteString {
                        let dictionaryValues = ["profileImageURL":profileImageURL]
                        Database.database().reference().child("users").child(userID).updateChildValues(dictionaryValues) { (err, ref) in
                            if let err = err {
                                print ("Failed",err)
                                return
                            }
                            print("Successfully updated a user")
                            NotificationCenter.default.post(name: EditProfileController.updateUserData, object: nil)
    }
                    }
                }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }
}
