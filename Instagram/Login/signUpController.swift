//
//  ViewController.swift
//  Instagram
//
//  Created by AHMED on 1/11/20.
//  Copyright © 2020 AHMED. All rights reserved.
//

import UIKit
import Firebase
class signUpController: UIViewController , UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    let loadingIndicator:UIActivityIndicatorView = {
        let LI = UIActivityIndicatorView()
        LI.tintColor = .gray
        return LI
    }()
    let plusButtonPhoto: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        button.clipsToBounds = true
        return button
    }()
    let signUpButton :UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("SignUp", for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    let alreadyHaveAccountButton:UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.lightGray])
        button.setAttributedTitle(attributedTitle, for: .normal)
        attributedTitle.append(NSAttributedString(string: " Sign in", attributes: [NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor:UIColor.rgb(red: 17, green: 154, blue: 237 )]))
        button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        return button
    }()
    @objc func handleAlreadyHaveAccount() {
        navigationController?.popViewController(animated: true)
    }
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            plusButtonPhoto.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
            
        }
        else if let editedImage =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            plusButtonPhoto.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusButtonPhoto.layer.cornerRadius = plusButtonPhoto.layer.frame.width/2
        //        plusButtonPhoto.layer.masksToBounds = true
        plusButtonPhoto.layer.borderWidth = 1
        plusButtonPhoto.layer.borderColor = UIColor.black.cgColor
        plusButtonPhoto.contentMode = .scaleAspectFill
        
        dismiss(animated: true, completion: nil)
        
    }
    @objc func handleSignUp() {
        loadingIndicator.startAnimating()
        guard let email = emailTextField.text , email.isEmpty == false  else {return}
        guard let username = usernameTextField.text , username.isEmpty == false  else {return}
        guard let password = passwordTextField.text , password.isEmpty == false  else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self]  (user , error) in
            if let err = error {
                print("Failed to create a user",err)
                return
            }
            print("Successfully created")
            
            guard let self = self else {return}
            guard let image = self.plusButtonPhoto.imageView?.image else {return}
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
                        let dictionaryValues = ["username":username,"profileImageURL":profileImageURL]
                        let values = [userID:dictionaryValues]
                        Database.database().reference().child("users").updateChildValues(values) { (err, ref) in
                            if let err = err {
                                print ("Failed",err)
                                return
                            }
                            print("Successfully created a user")
                            do {
                                try Auth.auth().signOut()
                            } catch {
                                
                            }
                            self.navigationController?.popViewController(animated: true)
                            self.loadingIndicator.stopAnimating()
                        }
                    }
                }
                
                
            }
        }
    }
    
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    @objc func handleTextInputChange() {
        let isFormValid = emailTextField.text!.count > 0 && usernameTextField.text!.count > 0 && passwordTextField.text!.count > 0
        if isFormValid {
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = .mainBlue()
            
        }
        else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    
    
    let usernameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        view.backgroundColor = .white
        view.addSubview(plusButtonPhoto)
        view.addSubview(alreadyHaveAccountButton)
        plusButtonPhoto.setAnchor(top: view.topAnchor, left: nil, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 40, height: 140, width: 140)
        plusButtonPhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        alreadyHaveAccountButton.setAnchor(top: nil , left: view.leftAnchor, right: view.rightAnchor, bottom: view.bottomAnchor, paddingBottom: 10, paddingLeft: 0, paddingRight: 0, paddingTop: 20, height: 0, width: 0)
        
        setupInputFields()
        
    }
    fileprivate func setupInputFields() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField,usernameTextField,passwordTextField,signUpButton])
        view.addSubview(stackView)
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.setAnchor(top: plusButtonPhoto.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, bottom: nil, paddingBottom: 0, paddingLeft: 40, paddingRight: 40, paddingTop: 20, height: 200, width: 0)
        view.addSubview(loadingIndicator)
        loadingIndicator.setAnchor(top: stackView.bottomAnchor, left: nil, right: nil, bottom: nil, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 50, height: 50, width: 50)
        loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
}

















